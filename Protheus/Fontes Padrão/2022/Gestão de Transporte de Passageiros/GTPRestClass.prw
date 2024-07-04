#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RESTFUL.CH"
#include 'parmtype.ch' 

/*/{Protheus.doc} GTPRestClass (Heritage: FWRest)
    Classe GTP do REST, herda de FWRest
    @type  Class
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param  
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Class GTPRestClass from FWRest

    Data cBearerToken   as character
    Data cHostRest      as character
    Data cURLRest       as character
    Data cJsonToken     as character
    Data cURLToken      as character
    Data cPathToken     as character
    Data cTokenAccess   as character
    Data cTokenRefresh  as character
    Data cScopeToken    as character
    Data cTokenType     as character
    Data cIdUserRest    as character
    Data cUserRest      as character
    Data cPswUser       as character
    Data cJSonRest      as character

    Data nTokenExpires  as numeric
    Data nSecIni        as numeric
    Data nSecFim        as numeric
    Data nLenJson       as numeric
    Data nByteLidos     as numeric

    Data aBaseHeader    as array
    Data aJsonToken     as array
    Data aJsonRest      as array

    Data lToken         as logical
    Data lBasicAuthON   as logical
    Data lNoAuth        as logical

    Data oJsonToken     as object
    Data oJsonRest      as object
    Data oJTokenHash    as object
    Data oJRestHash      as object

    Method New() CONSTRUCTOR
    
    Method addHeader()
    Method delHeader()
    Method changeAuthMethod()
    Method getToken()
    Method get()
    Method getJsonValue()
    Method getPswUser()
    Method setBaseHeader()
    Method setBasicAuth()
    Method setToken()
    Method setNoAuth()
    Method tokenOff()
    Method basicAuthOff()
    Method validedAuth()

EndClass

/*/{Protheus.doc} New 
    Construtor de instância da classe
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param  
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Method New(cAPI,lToken) Class GTPRestClass

    Default cAPI    := ""
    Default lToken  := .F.

    self:cHostRest      := GTPGetRules("PATHREST",,,"http://localhost:12173/rest")    
    self:cURLRest       := self:cHostRest + "/" + cAPI
    self:cIdUserRest    := RetCodUsr()
    self:cUserRest      := Alltrim(FWUserName(RetCodUsr()))
    self:cPswUser       := ""
    self:cJsonRest      := ""
    
    self:nLenJson       := 0
    self:nByteLidos     := 0

    self:lToken         := .F.
    self:lBasicAuthON   := .F.
    self:lNoAuth        := .F.
    
    self:aJsonRest      := {}

    _Super:New(self:cURLRest)

    self:setBaseHeader()

    self:changeAuthMethod(IIf(lToken,"TOKEN","BASIC"))

Return()

/*/{Protheus.doc} setBasicAuth 
    Configura o tipo de autenticação REST para básico
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param  
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Method setBasicAuth() Class GTPRestClass
    
    Local lPassGot  := .F.

    If ( !self:lToken )

        self:basicAuthOff()

        lPassGot := self:getPswUser()
        
        If (lPassGot)
        
            self:lBasicAuthON   := .T.
            self:setBaseHeader()
            self:addHeader("Authorization: Basic " + Encode64(self:cUserRest + ":" + Decode64(Self:cPswUser)))
            
        EndIf

    EndIf

Return()

/*/{Protheus.doc} setToken 
    Configura o tipo de autenticação REST para Bearer Token
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param  lForce, lógico, .t. força o reset do token.  
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Method setToken(lForce) Class GTPRestClass

    Local nByteLido := 0

    Local oRestToken

    Local lPassGot  := .F.

    Local xGet      := Nil

    Default lForce  := .F.
    
    If ( !self:lBasicAuthON )

        If ( lForce .Or. !(self:ValidedAuth()) )
            
            self:TokenOff()

            lPassGot := self:getPswUser()

            If ( lPassGot )
                
                self:cURLToken := self:cHostRest + "/api/oauth2/v1"
                self:cPathToken:= "/token?username=" + self:cUserRest + "&password=" + Alltrim(Decode64(self:cPswUser)) + "&grant_type=password"
                
                oRestToken := FWRest():New(self:cURLToken)
                oRestToken:SetPath(self:cPathToken)

                If ( oRestToken:Post(self:aBaseHeader) )
                    
                    self:nSecIni    := Seconds()
                    self:cJsonToken := oRestToken:GetResult()
                    self:lToken     := .T.
                    self:aJsonToken := {}

                    self:oJsonToken := TJsonParser():New()
                    self:oJsonToken:Json_Hash(self:cJsonToken,Len(self:cJsonToken),self:aJsonToken,@nByteLido,self:oJTokenHash)
                    
                    self:cTokenAccess   := IIf(HMGet(self:oJTokenHash, "access_token", @xGet),xGet,"")
                    self:cTokenRefresh  := IIf(HMGet(self:oJTokenHash, "refresh_token", @xGet),xGet,"")
                    self:cScopeToken    := IIf(HMGet(self:oJTokenHash, "scope", @xGet),xGet,"")
                    self:cTokenType     := IIf(HMGet(self:oJTokenHash, "token_type", @xGet),xGet,"")
                    self:nTokenExpires  := IIf(HMGet(self:oJTokenHash, "expires_in", @xGet),xGet,"")
                    self:cBearerToken   := self:cTokenRefresh
                    self:nSecFim    := self:nSecIni + self:nTokenExpires

                    self:addHeader("Authorization: Bearer " + Alltrim(self:getToken()))

                Else
                    self:cJsonToken := oRestToken:GetLastError()
                    self:lToken := .F.
                EndIf

            EndIf
        
        EndIf
    
    EndIf

Return()

/*/{Protheus.doc} getPswUser 
    Pega a senha de usuário e faz seu encoding 64. 
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method getPswUser() Class GTPRestClass
    
    Local cPass     := space(40)

    Local aParam    := {}
    Local aRetPar   := {}

    Local lRet      := .F.
    
    If ( Empty(self:cIdUserRest) )     
        self:cIdUserRest    := RetCodUsr()
    EndIf    

    If ( Empty(self:cUserRest) )
        self:cUserRest      := Alltrim(FWUserName(self:cIdUserRest))        
    EndIf
    
    If ( Empty(self:cPswUser) )

        AAdd( aParam ,{9,"Geração do Token de acesso",80,10,.t.})
        AAdd( aParam ,{9,"Usuário " + self:cUserRest,70,10,.t.})
        AAdd( aParam ,{8,"Senha" ,cPass,"@",".T.",,".T.",60,.F.})
        
        ParamBox(aParam ,"Gerador de Token REST",aRetPar)

        If ( Len(aRetPar) > 0 )
            self:cPswUser := Encode64(aRetpar[3])
            lRet := !Empty(self:cPswUser)
        EndIf

    Else
        lRet := .t.
    EndIf

Return(lRet)            

/*/{Protheus.doc} TokenOff()
    (long_description)
    @author user
    @since 26/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method TokenOff() Class GTPRestClass
    
    self:cURLToken  := "" 
    self:cPathToken := ""
    self:nSecIni    := 0
    self:nSecFim    := 0
    self:nTokenExpires  := 0
    self:cJsonToken := ""
    self:lToken     := .F.
    
    self:aJsonToken := {}
    self:oJsonToken := Nil

    self:cTokenAccess   := ""
    self:cTokenRefresh  := ""
    self:cScopeToken    := ""
    self:cTokenType     := ""

Return()

/*/{Protheus.doc} basicAuthOff 
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method basicAuthOff() Class GTPRestClass
   self:lBasicAuthON   := .F.
Return()

Method addHeader(uElement) Class GTPRestClass

    If ( Valtype(uElement) <> "U" )
        
        If ( aScan(self:aBaseHeader,uElement) == 0 )
            aAdd(self:aBaseHeader,uElement)
        EndIf

    EndIf

Return()

/*/{Protheus.doc} delHeader 
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method delHeader(uElement) Class GTPRestClass

    If ( Valtype(uElement) <> "U" )
        
        nElement := aScan(self:aBaseHeader,{|z| Lower(uElement) $ Lower(z)})
        
        If ( nElement > 0 )
            aDel(self:aBaseHeader,nElement)
            aSize(self:aBaseHeader,Len(self:aBaseHeader)-1)
        EndIf

    EndIf

Return()

/*/{Protheus.doc} ChangeAuthMethod 
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method ChangeAuthMethod(cOptMethod) Class GTPRestClass

    Default cOptMethod := "BASIC"   //Opções "BASIC" ou "TOKEN"

    If ( cOptMethod == "BASIC" )
        self:TokenOff()
        self:setBasicAuth()
    ElseIf ( cOptMethod == "TOKEN" )
        self:basicAuthOff()
        self:setToken()
    EndIf

Return()

/*/{Protheus.doc} getToken 
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method getToken(lRefreshToken) Class GTPRestClass

    Local cToken := ""

    Default lRefreshToken := .F.
    
    If ( self:ValidedAuth())
        
        cToken := IIf(lRefreshToken, self:cTokenRefresh, self:cTokenAccess)
        
        If ( Empty(self:cBearerToken) .Or. cToken <> self:cBearerToken )
            self:cBearerToken := cToken
        EndIf

    EndIf

Return(cToken)

/*/{Protheus.doc} get
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method get() Class GTPRestClass

    Local lRet := .F.

    If ( self:ValidedAuth() .And. _Super:get(self:aBaseHeader) )
        
        lRet := .T.
        
        self:cJsonRest := self:GetResult()
        self:nLenJson := Len(self:cJsonRest)

        self:oJsonRest := tJsonParser():New()
        self:oJsonRest:Json_Hash(self:cJsonRest,self:nLenJson,self:aJsonRest,@self:nByteLidos,@self:oJRestHash)

    EndIf

Return(lRet)

/*/{Protheus.doc} getJsonValue
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method getJsonValue(cKeyJson) Class GTPRestClass

    Local xValue     := ""

    Default cKeyJson := ""

    If ( !Empty(cKeyJson) .And. Valtype(self:oJRestHash) == "O" .And. Len(self:aJsonRest) > 0 )
        xValue :=   IIf(HMGet(self:oJRestHash, cKeyJson, @xValue),xValue,"")
    EndIf

Return(xValue)

/*/{Protheus.doc} setBaseHeader
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method setBaseHeader() Class GTPRestClass

    self:aBaseHeader := {}
    
    aAdd(self:aBaseHeader, "Content-Type: application/json; charset=UTF-8" )
    aAdd(self:aBaseHeader, "Accept: */*" )
    aAdd(self:aBaseHeader, "Connection: keep-alive" )
    aAdd(self:aBaseHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")
   
Return()

/*/{Protheus.doc} ValidedAuth
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method ValidedAuth(lNoAuth) Class GTPRestClass

    Local lValid := .F.

    Default lNoAuth := .F.
    
    If ( self:lToken )
        lValid := !Empty(self:cBearerToken) .And. Seconds() <= self:nSecFim
    ElseIf ( self:lBasicAuthON )    
        lValid := !Empty(self:cIdUserRest) .And. !Empty(self:cPswUser)
    Else
        lValid := self:lNoAuth
    EndIf

Return(lValid)

/*/{Protheus.doc} SetNoAuth
    
    @type  Método de classe
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param
    @return lRet, .t. password recuperado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Method SetNoAuth() Class GTPRestClass
    self:lNoAuth := .T.
Return()
