#include 'protheus.ch'
#include 'fileio.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCAMeuChecklist()
Classe criada para comunicação com Meu Checklist

@author Caio Murakami
@since 07/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS TMSBCAMeuChecklist

    //-- Informações Token
    DATA url_token      AS CHARACTER
    DATA access_token   AS CHARACTER
    DATA grant_type     AS CHARACTER
    DATA client_id      AS CHARACTER
    DATA client_secret  AS CHARACTER
    DATA acr_values     AS CHARACTER
    DATA scope          AS CHARACTER 
    DATA username       AS CHARACTER
    DATA password       AS CHARACTER
    DATA last_error     AS CHARACTER
    DATA time_token     AS CHARACTER
    DATA data_token     AS DATA
    DATA time_expire    AS NUMERIC 
    
    DATA rest_client    AS OBJECT 
    DATA json_object    AS OBJECT 
    DATA error          AS CHARACTER
    DATA error_description  AS CHARACTER

    METHOD New()    Constructor
    METHOD GetToken()
    METHOD IsTokenActive()
    METHOD GetLastError()
    METHOD GetErrorDescription()
    METHOD GravaToken()
    METHOD Post()
    METHOD Get()
    METHOD Put()
    METHOD Delete()
    METHOD Destroy()

END CLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Caio Murakami
@since 07/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD New() CLASS TMSBCAMeuChecklist

::url_token     := ""
::access_token  := ""
::grant_type    := ""
::client_id     := ""
::client_secret := ""
::acr_values    := ""
::scope         := ""
::username      := ""
::password      := ""
::rest_client   := Nil
::json_object   := JsonObject():new()
::last_error    := ""
::error_description := ""
::data_token    := CToD("")
::time_token    := ""

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetToken()

@author Caio Murakami
@since 07/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetToken( cUrlToken , cClientId , cSecret , cAcrValues , cUser , cPassword , cSequen ) CLASS TMSBCAMeuChecklist
Local lRet          := .F. 
Local aHeaderStr    := {} 
Local cResult       := ""
Local cParams       := ""
Local oResult       := Nil 
Local aTokActive    := {} 
Local lTokActive    := .F. 

Default cUrlToken   := ""
Default cClientId   := ""
Default cSecret     := ""
Default cAcrValues  := ""
Default cUser       := ""
Default cPassword   := ""
Default cSequen     := ""

::url_token     := RTrim( cUrlToken )
::grant_type    := "password"
::client_id     := RTrim( cClientId )
::client_secret := RTrim( cSecret ) 
::acr_values    := RTrim( cAcrValues )
::scope         := "authorization_api"
::username      := RTrim( cUser )
::password      := RTrim( cPassword )
::rest_client   := FwRest():New(::url_token)

cParams := "grant_type="    + ::grant_type
cParams += "&client_id="    + ::client_id
cParams += "&client_secret="+ ::client_secret
cParams += "&acr_values="   + Escape( ::acr_values )
cParams += "&scope="        + ::scope
cParams += "&username="     + Lower( ::username )
cParams += "&password="     + ::password

Aadd(aHeaderStr, "Content-Type: application/x-www-form-urlencoded")

//-- Busca token ativo
aTokActive  := ::IsTokenActive( cSequen )

If Len(aTokActive) > 0 
    lRet    := .T. 
    lTokActive      := aTokActive[1]
    ::access_token  := aTokActive[2]
EndIf

//-- Busca token no app Meu Check-List
If !lTokActive

    ::rest_client:SetPath("token")
    ::rest_client:SetPostParams( EncodeUTF8(cParams) )

    ::data_token    := dDataBase
    ::time_token    := Time()

    lRet    := ::rest_client:Post( aHeaderStr ) 

    If lRet
        cResult     := ::rest_client:GetResult()
        
        If FWJsonDeserialize(cResult,@oResult)
            If AttIsMemberOf(oResult,"access_token")
                ::access_token  := oResult:access_token
                
                //-- Tempo de expiração
                If AttIsMemberOf(oResult,"expires_in")
                    ::time_expire := oResult:expires_in
                    ::GravaToken(cSequen)
                EndIf
            
            EndIf 
        EndIf

    Else
        ::last_error    := AllTrim( ::rest_client:GetLastError() )
        cResult         := ::rest_client:GetResult()

        If FWJsonDeserialize(cResult,@oResult)
            If AttIsMemberOf(oResult,"error")
                ::error_description  += oResult:error + chr(10) + chr(13)
            EndIf
            
            If AttIsMemberOf(oResult,"error_description")
                ::error_description += oResult:error_description
            EndIf
        EndIf
    EndIf
EndIf

//-- Limpa cache de 
FwFreeArray(aTokActive)
FwFreeArray(aHeaderStr)
FwFreeObj(oResult)

Return ::access_token

//-----------------------------------------------------------------
/*/{Protheus.doc} IsTokenActive()

@author Caio Murakami
@since 17/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD IsTokenActive( cSequen ) CLASS TMSBCAMeuChecklist
Local aArea         := GetArea()
Local cQuery        := ""
Local cAliasQry     := GetNextAlias()
Local cToken        := ""
Local lRet          := .F. 
Local dDtToken      := CToD("")
Local cHrToken      := ""
Local nExpire       := 0     
Local cHour         := ""
Local cMin          := ""
Local cSecs         := ""
Local cTime         := ""
Local nSecs         := 0 

Default cSequen     := ""

cQuery  := " SELECT R_E_C_N_O_ RECNODLZ , DLZ_DTTOKE ,  DLZ_HRTOKE , DLZ_EXPIRE "
cQuery  += " FROM " + RetSQLName("DLZ") + " DLZ "
cQuery  += " WHERE DLZ_FILIAL   = '" + xFilial("DLZ") + "' "
cQuery  += " AND DLZ_SEQUEN     = '" + cSequen + "' "
cQuery  += " AND DLZ_MSBLQL     = '2' "
cQuery  += " AND DLZ_TOKEN      <> '' "
cQuery  += " AND DLZ_DTTOKE     <> '' "
cQuery  += " AND DLZ_HRTOKE     <> '' "
cQuery  += " AND DLZ_EXPIRE     <> '' "
cQuery  += " AND DLZ.D_E_L_E_T_ = '' "

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

If (cAliasQry)->( !Eof() )
    
    dDtToken    := SToD( (cAliasQry)->DLZ_DTTOKE )
    cHrToken    := (cAliasQry)->DLZ_HRTOKE
    nExpire     := (cAliasQry)->DLZ_EXPIRE

    If dDataBase == dDtToken 
        cTime   := ElapTime(cHrToken,Time()) 

        cHour   := SubStr( cTime, 1, 2 ) // Resultado: 10
        cMin    := SubStr( cTime, 4, 2 ) // Resultado: 37
        cSecs   := SubStr( cTime, 7, 2 ) // Resultado: 17
        
        nSecs   := Val(cSecs) + ( Val( cMin ) * 60 ) + ( Hrs2Min(cHour) * 60 ) 


        If nExpire > nSecs
            lRet    := .T. 
            DLZ->( dbGoTo( (cAliasQry)->RECNODLZ ) )
            cToken  := DLZ->DLZ_TOKEN
        EndIf
    EndIf

EndIf

(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return { lRet , cToken } 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetLastError()

@author Caio Murakami
@since 07/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetLastError() CLASS TMSBCAMeuChecklist

Return ::last_error

//-----------------------------------------------------------------
/*/{Protheus.doc} GetErrorDescription()

@author Caio Murakami
@since 07/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetErrorDescription() CLASS TMSBCAMeuChecklist

Return ::error_description

//-----------------------------------------------------------------
/*/{Protheus.doc} ()

@author Caio Murakami
@since 07/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Post() CLASS TMSBCAMeuChecklist
Local aHeaderStr    := {}
Local cJSON         := ""
Local cPath         := ""
Local lRet          := .T. 
Local cResult       := ""

//-----------------------------------------
//-- Montagem Header
//-----------------------------------------
Aadd(aHeaderStr, "Authorization: " + "Bearer " + ::access_token )
Aadd(aHeaderStr, "Content-Type: application/json" )

cJSON   := ::json_object

::rest_client:SetPath(cPath)
::rest_client:SetPostParams( cJSON )
lRet    := ::rest_client:Post( aHeaderStr )  

If lRet 
    cResult := ::rest_client:GetResult()
Else
    cResult := AllTrim( ::rest_client:GetLastError() )
EndIf

FwFreeArray(aHeaderStr)
Return {lRet, cResult}

//-----------------------------------------------------------------
/*/{Protheus.doc} GravaToken()

Gravar token nas tabelas

@author Caio Murakami
@since 22/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GravaToken( cSequen , dData , cTime , cToken , nTimeExp ) CLASS TMSBCAMeuChecklist
Local lRet          := .F. 

Default cSequen     := ""
Default dData       := ::data_token
Default cTime       := ::time_token
Default cToken      := ::access_token
Default nTimeExp    := ::time_expire

DLZ->( dbSetOrder(1) )
If DLZ->( dbSeek( xFilial("DLZ") + cSequen ))
    RecLock("DLZ",.F.)
    DLZ->DLZ_DTTOKE     := dData
    DLZ->DLZ_HRTOKE     := cTime
    DLZ->DLZ_TOKEN      := cToken
    DLZ->DLZ_EXPIRE     := nTimeExp
    DLZ->(MsUnlock())
    lRet    := .T. 
EndIf

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} ()


@author Caio Murakami
@since 07/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Get() CLASS TMSBCAMeuChecklist


Return

//-----------------------------------------------------------------
/*/{Protheus.doc} ()


@author Caio Murakami
@since 07/04/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD Destroy() CLASS TMSBCAMeuChecklist


Return
