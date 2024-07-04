#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LJRAC.CH"

Function LjRac ; Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe LjRac
Classe responsável pelo gerenciamento da autenticação com o RAC

@type    class
@author  Rafael Tenorio da Costa
@since   11/05/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class LjRac

    Data cUrl               as Character
    Data cTenent            as Character
    Data cUser              as Character
    Data cPassword          as Character
    Data cClientId          as Character
    Data cClientSecret      as Character

    Data dDateExpiration    as Date
    Data cTimeExpiration    as Character
    Data cEnvironment       as Character
    Data cToken             as Character

    Data oMessageError      as Object

    Method New(cTenent, cUser, cPassword, cClientId, cClientSecret, cEnvironment)

    Method GetToken()
    Method ExpirationDate(nTime, cTipo)
    Method OutOfDate()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@type    method
@param   cTenent, Caractere,  
@param   cUser, Caractere, Código do usuário
@param   cPassword, Caractere, Senha do usuário
@param   cClientId, Caractere, Identificação do cliente no rac
@param   cClientSecret, Caractere, Senha do cliente no rac
@param   cEnvironment, Caractere, Define o modo de conexão 1=Homologação ou 2=Produção
@return  LjRac, Objeto, Objeto instanciado
@author  Rafael Tenorio da Costa
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New(cTenent, cUser, cPassword, cClientId, cClientSecret, cEnvironment) Class LjRac

    Default cTenent     := ""
    Default cEnvironment:= "2"      //Produção

    self:cTenent        := AllTrim(cTenent      )
    self:cUser          := AllTrim(cUser        )
    self:cPassword      := AllTrim(cPassword    )
    self:cClientId      := AllTrim(cClientId    )
    self:cClientSecret  := AllTrim(cClientSecret)

    self:dDateExpiration := CtoD("")
    self:cTimeExpiration := ""
    self:cEnvironment    := cEnvironment
    self:cToken          := ""

    // -- Produção
    If cEnvironment == "2"
        self:cUrl := "https://" + self:cTenent + ".rac.totvs.app"
    
    // -- Desenvolvimento / QA
    ElseIf cEnvironment == "3"
        self:cUrl := "https://" + self:cTenent + ".rac.dev.totvs.app"
        
    // -- Homologação Staging
    Else
        self:cUrl := "https://" + self:cTenent + ".rac.staging.totvs.app"
    EndIf

    Self:oMessageError := LjMessageError():New()

Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetToken
Metodo responsavel devolver token de acesso ao RAC

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Caractere, Token retornado pela conexão.
/*/
//-------------------------------------------------------------------------------------
Method GetToken() Class LjRac

    Local cParams      := ""
    Local aHeadStr     := {}                        
    Local cResult      := ""
    Local nTokenExpire := 0
    Local oRestClient  := Nil
    Local oJson        := Nil
    Local cError       := ""

    If Empty(self:cUser) .Or. Empty(self:cPassword)
        Self:oMessageError:SetError(GetClassName(Self), STR0001)    //"Usuário e senha para autenticação não informados."
    Else

        //Fora da validade?
        If Empty(self:cToken) .Or. self:OutOfDate()

            oRestClient  := FWRest():New(self:cUrl)
            oJson        := JsonObject():new()

            AAdd( aHeadStr, "Content-Type: application/x-www-form-urlencoded" )
            AAdd( aHeadStr, "charset: UTF-8" )
            AAdd( aHeadStr, "User-Agent: Protheus " + GetBuild() )
            
            cParams := "grant_type=password"
            cParams += "&username=" + self:cUser
            cParams += "&password=" + self:cPassword
            cParams += "&scope=authorization_api"
            cParams += "&client_id=" + self:cClientId
            cParams += "&client_secret="+ self:cClientSecret
            
            oRestClient:setPath("/totvs.rac/connect/token")
            oRestClient:SetPostParams(cParams)

            If oRestClient:Post(aHeadStr)
                cResult := oJson:FromJson(oRestClient:GetResult())
                If ValType(cResult) == "U"                        // -- Nil indica que conseguiu popular o objeto com o Json
                    self:cToken     := oJson["access_token"]      // -- Chave de acesso
                    nTokenExpire    := oJson["expires_in"] / 60   // -- Expiração do token em minutos

                    self:ExpirationDate(nTokenExpire)
                Else

                    Self:oMessageError:SetError(GetClassName(Self), STR0002 + cResult)  //"Não foi possivel realizar o Parse: "
                EndIf
            Else
                cResult := oJson:FromJson(oRestClient:GetResult())
                If ValType(cResult) == "U"
                    cError := oJson["error"] + " http code: "
                EndIf 
                Self:oMessageError:SetError(GetClassName(Self), STR0003 + cError + oRestClient:GetLastError())     //"Erro ao tentar autenticar: "
            EndIf
        EndIf
    EndIf

    FwFreeObj(oRestClient)
    FwFreeObj(oJson)

Return self:cToken

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ExpirationDate
Metodo responsavel converter dias em horas

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param nTime, Numerico, tempo para conversão
@param cTipo, Caracter, tipo da conversão

@return Nil, nulo
/*/
//-------------------------------------------------------------------------------------
Method ExpirationDate(nTime, cTipo) Class LjRac

    Local cTime       := ""
    Local nHora       := 0
    Local nDias       := 0

    Default cTipo     := "M" 

    If  Upper(cTipo) = "H"
        nTime := nTime * 60
    ElseIf Upper(cTipo) = "S"
        nTime := nTime / 60
    EndIf 

    cTime := IncTime(time(),,nTime)
    nHora := Val(SubStr(cTime,1,2))

    While  nHora > 24
        nHora := nHora - 24
        nDias ++
    End

    self:cTimeExpiration := STRZero(nHora,2) + SubStr(cTime,3,Len(cTime))
    self:dDateExpiration := Date() + nDias

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OutOfDate
Metodo responsavel indicar se o token esta vencido
@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Logico, Indica se o token esta vencido.
/*/
//-------------------------------------------------------------------------------------
Method OutOfDate() Class LjRac

    Local lRet := .F.

    If !Empty(self:dDateExpiration) .AND. !Empty(self:cTimeExpiration)

        If self:dDateExpiration == Date()
    
            If Time() >= self:cTimeExpiration .Or. ElapTime(Time(),self:cTimeExpiration) <= "00:10:00"
                lRet := .T.
            EndIf
        Else
    
            If self:dDateExpiration < Date()
                lRet := .T.
            EndIf 
        EndIf
    Else

        lRet := .T.     
    EndIf 

Return lRet