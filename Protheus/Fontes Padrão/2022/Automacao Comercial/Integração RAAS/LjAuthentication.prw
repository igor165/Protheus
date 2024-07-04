#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LJAUTHENTICATION.CH"

Function LjAuthentication ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjAuthentication
Classe responsável por organizar produto e seus serviços

@type       Class
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return
/*/
//-------------------------------------------------------------------------------------
Class LjAuthentication
    Data cProduct               as Character
    Data cPos                   as Character
    
    Data oProductSettings       as Object
    Data aServicesSettings      as Array
    
    Data oAuthenticationService as Object

    Data aAuthService           as Array
    
    Data oMessageError          as Object

    Method New(cProduct, cPos)

    Method Authentication(cServiceCode, lForce)
    Method ConnectionTest(cServiceCode, lForce)
    Method GetToken(cServiceCode, lForce)                           // -- Retorna o token do serviço informado
    Method GetIntegration()
    Method SetIntegration(oProdSettings, aServicesSettings)
    Method InitialCharge()
    Method GetEnvironment(cSecret,cServiceCode,cId,cAmb)
    Method GetSecrets()

    Method GetProductComponents()                                   // -- Retorno JsonObject de componentes de produto
    Method SetProductComponents(jProductSettings)                   // -- Atualiza JsonObject de componentes de produto
    Method GetaServicesComponents(cServiceCode)                     // -- Retorna Array de JsonObject com os componentes dos serviços disponiveis para o produto
    Method SetaServicesComponents(cServiceCode, jServiceSettings)   // -- Atualiza JsonObject de componentes do serviço disponiveis para o produto

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param cProduct, Caracter, Produto atual
@param cPos, character, Codigo da estação

@return LjAuthentication, Objeto, Objeto construido.
/*/
//-------------------------------------------------------------------------------------
Method New(cProduct, cPos) Class LjAuthentication
    
    Local nTamLG_Cod        := TamSX3("MIJ_LGCOD")[1]
    Local nTamProd          := TamSX3("MIJ_PRODUT")[1]
    
    Default cPos            := ""

    Self:cProduct           := PadR(cProduct, nTamProd)
    Self:cPos               := PadR(cPos, nTamLG_Cod)
    Self:oProductSettings   := Nil
    Self:aServicesSettings  := {}
    Self:aAuthService       := {}

    Self:oMessageError      := LjMessageError():New()

    Self:InitialCharge()
    Self:GetIntegration()

Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Authentication
Metodo responsavel por autenticar o serviço recebido por parametro
@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param cServiceCode, Caracter, Codigo que indica o serviço (Ex: TPD, TFC)
@param lForce, Logico, Indica se controi novamente o objeto de autenticação (em caso de alteração dos dados de comunicação)

@return Caractere, Token retornado pelo autenticação
/*/
//-------------------------------------------------------------------------------------
Method Authentication(cServiceCode, lForce) Class LjAuthentication

    Local oAuthService  := Nil
    Local cToken        := ""
    Local aParans       := {}
    Local nPOS          := 0
    Local nPosTenent    := 0
    Local nPosUser      := 0
    Local nPosPassword  := 0
    Local nPosService   := 0
    Local cEnvironment  := ""
    Local nPosAmb       := 0
    
    Default lForce := .F.
        
    nPOS := aScan(Self:aAuthService,{|X| x[1] == cServiceCode})
    
    If nPOS == 0 .OR. lForce

        DO CASE
        CASE Self:oProductSettings:JPRODUCTSETTINGS["Protocol"] == "OAuth2.0"
            DO CASE 
            CASE Self:oProductSettings:JPRODUCTSETTINGS["AuthenticationService"] == "RAC"
                
                aParans := Array(6)
                
                nPosTenent   := aScan(Self:oProductSettings:JPRODUCTSETTINGS["Components"],{|x| x["IdComponent"] == "Tenent" })
                nPosUser     := aScan(Self:oProductSettings:JPRODUCTSETTINGS["Components"],{|x| x["IdComponent"] == "User" })
                nPosPassword := aScan(Self:oProductSettings:JPRODUCTSETTINGS["Components"],{|x| x["IdComponent"] == "Password" })
                nPosService  := aScan(Self:aServicesSettings,{|x|x:cServiceCode  == cServiceCode })
                
                If nPosService > 0
                    nPosAmb := aScan(Self:aServicesSettings[nPosService]:JSERVICESETTINGS["Components"],{|x| x["IdComponent"] == "Environment" })
                EndIf 

                If (nPosTenent + nPosUser + nPosPassword + nPosService + nPosAmb) >= 6
                    aParans[1] := Self:oProductSettings:JPRODUCTSETTINGS["Components"][nPosTenent]["ComponentContent"]
                    aParans[2] := Self:oProductSettings:JPRODUCTSETTINGS["Components"][nPosUser]["ComponentContent"]
                    aParans[3] := Self:oProductSettings:JPRODUCTSETTINGS["Components"][nPosPassword]["ComponentContent"]
                    aParans[4] := ""
                    aParans[5] := ""
                    aParans[6] := Self:aServicesSettings[nPosService]:JSERVICESETTINGS["Components"][nPosAmb]["ComponentContent"]
                EndIf 

                cEnvironment := Self:GetEnvironment(@aParans[5],"",@aParans[4],aParans[6])
                oAuthService := LjRac():New(aParans[1],aParans[2],aParans[3],aParans[4],aParans[5],cEnvironment)
                cToken := oAuthService:GetToken()
                
            OTHERWISE
                Self:oMessageError:SetError(GetClassName(Self), I18n(STR0001, { AllTrim(Self:oProductSettings:JPRODUCTSETTINGS["AuthenticationService"]) } ) )  //"Serviço de autenticação #1 não implementado."
            ENDCASE
        OTHERWISE 
            Self:oMessageError:SetError(GetClassName(Self), I18n(STR0002, { Self:oProductSettings:JPRODUCTSETTINGS["Protocol"] } ) ) 
        ENDCASE

        // -- Se consegui autenticar guardo objeto para proximas consultas
        If oAuthService:oMessageError:GetStatus() .AND. !Empty(cToken)
            If nPOS > 0
                FreeObj( Self:aAuthService[nPOS][2]) 
                Self:aAuthService[nPOS][2] := oAuthService
                Self:aAuthService[nPOS][3] := cEnvironment
            Else
                aadd(Self:aAuthService,{cServiceCode,oAuthService,cEnvironment})
            EndIf 
        Else
            Self:oMessageError:SetError(GetClassName(Self),oAuthService:oMessageError:GetMessage()) 
            FreeObj(oAuthService)
        EndIf 

        oAuthService := Nil
    Else
        cToken := Self:aAuthService[nPOS][2]:GetToken()
    EndIf 

Return cToken

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConnectionTest
Metodo responsavel por testar comunicação com serviço de autenticação
@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method ConnectionTest(cServiceCode, lForce) Class LjAuthentication
return !Empty(self:Authentication(cServiceCode,lForce))

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetIntegration
Metodo responsavel por carregar o produto e serviço do banco de dados para o objeto de memoria

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method GetIntegration() Class LjAuthentication

    Local oProdSettings := LjProductSettings():New(Self:cProduct)
    Local oUtilServices := LjServicesSettings():New()
    Local oServSettings := Nil
    Local nX            := 0

    If oProdSettings:GetProduct()
        
        Self:oProductSettings := oProdSettings
        
        aServices :=  oUtilServices:Services(Self:cProduct,Self:cPos)
       
        For nX := 1 To Len(aServices)
            oServSettings := LjServicesSettings():New(aServices[nX][4]) // MIJ - Recno
        
            If oServSettings:GetService()
                AAdd(Self:aServicesSettings,oServSettings)
            Else
                Self:oMessageError:SetError(GetClassName(Self),oServSettings:oMessageError:GetMessage()) 
            EndIf 
            
            oServSettings := Nil
        Next

    Else
        Self:oMessageError:SetError(GetClassName(Self),oProdSettings:oMessageError:GetMessage())
    EndIf

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetIntegration
Metodo responsavel por persistir os dados do objeto de memoria ou informado pelos parametros no banco de dados

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@param oProdSettings, Object, Objeto opcional para persistencia no banco de dados (caso não seja informado será gravado o conteudo atual do objeto)
@param aServicesSettings, Array,  Lista contendo objetos que representam um serviço (caso não seja informado será gravado o conteudo atual do objeto)

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method SetIntegration(oProdSettings, aServicesSettings) Class LjAuthentication
    Local nX        := 1 

    Default oProdSettings       := Self:oProductSettings
    Default aServicesSettings   := Self:aServicesSettings

    If oProdSettings == Nil .Or. oProdSettings:SetProduct()

        For nX := 1 To len(aServicesSettings)
           If !aServicesSettings[nX]:SetService()
                Self:oMessageError:SetError(GetClassName(Self),aServicesSettings[nX]:oMessageError:GetMessage()) 
                Exit
           EndIf 
        Next
    Else
       Self:oMessageError:SetError(GetClassName(Self),oProdSettings:oMessageError:GetMessage()) 
    EndIf 

Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} InitialCharge
Metodo responsavel por realizar a carga inicial dos serviços e produtos
@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2021
@version    12.1.33

@return Logico, indica se o metodo foi executado com sucesso
/*/
//-------------------------------------------------------------------------------------
Method InitialCharge() Class LjAuthentication
    
    Local oProdSettings := LjProductSettings():New(Self:cProduct)
    Local oServSettings := LjServicesSettings():New()
    Local aServices     := {}
    Local nX            := 1
        
    If oProdSettings:InitialCharge()
        aServices := oServSettings:Services()
        For nX := 1 To Len(aServices)
           If !oServSettings:InitialCharge(,Self:cPos,Self:cProduct,aServices[nX][1],aServices[nX][2],aServices[nX][3]) 
                Self:oMessageError:SetError(GetClassName(Self),oServSettings:oMessageError:GetMessage()) 
                Exit
           EndIf 
        Next
    Else
        Self:oMessageError:SetError(GetClassName(Self),oProdSettings:oMessageError:GetMessage()) 
    EndIf 
Return Self:oMessageError:GetStatus()

//------------------------------------------------------------------------------------
/*/{Protheus.doc} GetProductComponents
Metodo responsavel por devolver o produto atual

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@return Json Object, Objeto contendo Configurações dos produtos
/*/
//------------------------------------------------------------------------------------
Method GetProductComponents() Class LjAuthentication 
Return Self:oProductSettings:jProductSettings

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetProductComponents
Metodo responsavel "Setar" o arquivo de configurações do produto carragado no objeto

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@param jProductSettings, Character, Json de configuração do produto carregado

@return Nil, Nulo
/*/
//------------------------------------------------------------------------------------
Method SetProductComponents(jProductSettings) Class LjAuthentication
    self:oProductSettings:jProductSettings := jProductSettings
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetaServicesComponents
Metodo responsavel por devolver uma lista com totos os serviços vinculados ao produto ou serviço especifico

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@param cServiceCode, Caracter, Codigo que indica o serviço (Ex: TPD, TFC), se preenchido indica que deverá devolver serviço especifico

@return Array, Array contendo os serviços ou serviço selecionado
/*/
//------------------------------------------------------------------------------------
Method GetaServicesComponents(cServiceCode) Class LjAuthentication 

    Local nX                  := 1 
    Local aServicesComponents := {}

    Default cServiceCode := ""

    For nX := 1 To len(Self:aServicesSettings)
        If Empty(cServiceCode) .OR. Self:aServicesSettings[nX]:cServiceCode == cServiceCode
            aadd(aServicesComponents,{Self:aServicesSettings[nX]:cServiceCode,Self:aServicesSettings[nX]:cService,Self:aServicesSettings[nX]:lEnable,Self:aServicesSettings[nX]:jServiceSettings})
        Endif 
    Next

Return aServicesComponents

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaServicesComponents
Metodo responsavel "Setar" o arquivo de configurações de um serviço no Objeto de lista

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@param cServiceCode, Caracter, Codigo que indica o serviço (Ex: TPD, TFC)
@param jServiceSettings, Logico, Indica se controi novamente o objeto de autenticação (em caso de alteração dos dados de comunicação)

@return Nil, Nulo
/*/
//------------------------------------------------------------------------------------
Method SetaServicesComponents(cServiceCode, jServiceSettings) Class LjAuthentication

    Local nPosService := aScan(self:aServicesSettings, { |x| x:cServiceCode == cServiceCode })

    If nPosService > 0 
        self:aServicesSettings[nPosService]:jServiceSettings := jServiceSettings
    EndIf                    

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetToken
Metodo responsavel retorna o token do serviço informado

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@param cServiceCode, Caracter, Codigo que indica o serviço (Ex: TPD, TFC)
@param lForce, Logico, Indica se controi novamente o objeto de autenticação (em caso de alteração dos dados de comunicação)

@return Character, Token
/*/
//------------------------------------------------------------------------------------
Method GetToken(cServiceCode, lForce) Class LjAuthentication 
Return Self:Authentication(cServiceCode,lForce)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetEnvironment
Metodo responsavel retorna o ambiente do serviço informado

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@param cSecret, Caracter, Codigo que indica a chave de segurança
@param cServiceCode, Caracter, Codigo que indica o serviço (Ex: TPD, TFC)

@return Character, Ambiente
/*/
//------------------------------------------------------------------------------------
Method GetEnvironment(cSecret,cServiceCode,cId,cAmb) Class LjAuthentication 
    Local cEnvironment   := ""
    Local aSecrets       := {}
    Local nPOs           := 0
    Local lCachedSearch  := .F.

    Default cSecret      := ""
    Default cServiceCode := ""
    Default cId          := ""

    lCachedSearch := Empty(cSecret) .And. !Empty(cServiceCode) .And. (nPOS := aScan(Self:aAuthService,{|X| x[1] == cServiceCode})) > 0
    
    If lCachedSearch
       cEnvironment := Self:aAuthService[nPOS][3]
    Else

        If (nPOs := aScan((aSecrets := Self:GetSecrets()),{|X| x[4] == Alltrim(cAmb)})) > 0
            cEnvironment    := aSecrets[nPOs][2]
            cSecret         := aSecrets[nPOs][1]
            cId             := aSecrets[nPOs][3]
        EndIf 

    EndIf 

Return cEnvironment 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSecrets
Metodo responsavel retorna as Secrets

@type       Method
@author     Lucas Novais (lnovais@)
@since      07/05/2020
@version    12.1.33

@return Array, Retorna as secrets
/*/
//------------------------------------------------------------------------------------
Method GetSecrets() Class LjAuthentication 

    //aSecrets -- Array contendo o secret e diz se é de produção homologação ou DEV/QA 1 - Staging 2 - Prod 3 - DEV/QA
    Local aSecrets := {}

    aAdd(aSecrets,{"b9d7e988-3a05-43cc-903b-e7500038f231","1","totvs_raas_fidelity_protheus_ro","Homologação"})
    aAdd(aSecrets,{"98505f0d-98a2-4bea-a039-a70a7251f8cd","3","totvs_raas_fidelity_0d7b8d9e341444e882d85cfa9fcf58f0","Desenvolvimento"})
    aAdd(aSecrets,{"24a4783a-3f56-4245-970e-c168414b3ae7","2","totvs_raas_fidelity_protheus_ro","Produção"})

Return aSecrets
