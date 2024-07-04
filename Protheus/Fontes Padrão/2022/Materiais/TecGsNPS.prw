#INCLUDE "PROTHEUS.CH"
//------------------------------------------------------------------------------
/*/{Protheus.doc} GsNps

@description Classe utilizada para pesquisa de NPS através do produto

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
class GsNps

data cLsID AS CHARACTER
data cProductLine AS CHARACTER
data cVersion AS CHARACTER
data cProductName AS CHARACTER
data cUserEmail AS CHARACTER
data cUserName AS CHARACTER
data nRating AS NUMBER
data cComment AS CHARACTER
data aTokenData AS ARRAY
data lCancelled AS LOGICAL
data lShareEmail AS LOGICAL
data lShareName AS LOGICAL

method new()
method canSendAnswer()
method setProductName()
method setRating()
method setUserName()
method setUserEmail()
method setComment()
method setShareEmail()
method setShareName()
method sendAnswer()
method getAuthToken()

endclass
//------------------------------------------------------------------------------
/*/{Protheus.doc} new

@description Construtor da classe GsNps

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method new() class GsNps

::cLsID := FwGetIdLSV()
::cProductLine := "Protheus"
::cProductName := ""
::cComment := ""
::cVersion  := GetRpoRelease()
::aTokenData := {}
::cUserEmail := Alltrim(UsrRetMail(__cUserId))
::cUserName := UsrRetName(__cUserId)
::nRating := 0
::lCancelled := .F.
::lShareEmail := .T.
::lShareName := .T.

return
//------------------------------------------------------------------------------
/*/{Protheus.doc} sendAnswer

@description Envio da resposta do usuário

@param, nOpc, 1 = Clicou para enviar a pesquisa (default)
              2 = Clicou no botão "cancelar" / "Não quero responder"

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method sendAnswer(nOpc) class GsNps
Local cPath := "/api/v1/nps/answers"
Local oRestClient
Local cBodyReq := ""
Local cShareEmail := "true"
Local cShareName := "true"
Local cCancelled := "false"
Local aHeadOut := {}

Default nOpc := 1

If ::getAuthToken()

    If !(::lShareEmail)
        cShareEmail := "false"
    EndIf

    If !(::lShareName)
        cShareName := "false"
    EndIf

    If nOpc == 2
        cCancelled := "true"
    EndIf

    // https://snowden.totvs.com.br/api/v1/docs/
    cBodyReq := '{"productLine":"' +::cProductLine + '",'                //Nome da linha de produto
    cBodyReq += '"productName":"' + ::cProductName + '",'                //Nome do produto
    cBodyReq += '"productVersion":"' + ::cVersion + '",'          //Versão do produto
    cBodyReq += '"productEnvironment":"' + "prod" + '",'  //Tipo de Ambiente (ex: Produção/Homologação)
    cBodyReq += '"customerTotvsId":"' + ::cLsID + '",'             //Identificação do cliente pelo License Server
    cBodyReq += '"userId":"' + __cUserId + '",'                   //Identificação do usuário
    cBodyReq += '"userEmail":"' + ::cUserEmail + '",'              //Email do usuário
    cBodyReq += '"userName":"' + ::cUserName + '",'               //Nome do usuário
    cBodyReq += '"rating":' + cValToChar(::nRating) + ','         //Avaliação do usuário entre 0 e 10
    cBodyReq += '"comment":"' + ::cComment + '",'                 //Comentário feito pelo usuário
    cBodyReq += '"cancelled":'+cCancelled+','                            //Se o usuário optou por não responder
    cBodyReq += '"answerDate": "' + FWTimeStamp(6) + '",'
    cBodyReq += '"userAcceptedShareUserEmail":'+cShareEmail+','            //Se o usuário autorizou o compartilhamento do seu e-mail.
    cBodyReq += '"userAcceptedShareUserName":'+cShareName+'}'             //Se o usuário autorizou o compartilhamento do seu nome.

    Aadd(aHeadOut, "Content-Type: application/json")
    AAdd(aHeadOut, "charset: UTF-8")
    AAdd(aHeadOut, "Authorization: Bearer " + ::aTokenData[1])

    oRestClient := FWRest():New("https://snowden.totvs.com.br")
    oRestClient:SetPath(cPath)
    oRestClient:SetPostParams(EncodeUTF8(cBodyReq))
    oRestClient:Post(aHeadOut)
EndIf

return
//------------------------------------------------------------------------------
/*/{Protheus.doc} canSendAnswer

@description Verifica se a pesquisa deve ser realizada

@return lRet, bool, .T. = A pesquisa deve ser exibida para o usuário
                    .F. = A pesquisa não vai ser exibida para o usuário

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method canSendAnswer() class GsNps
Local oRestClient
Local lRet := .F.
local aHeadOut := {}
Local oObj
Local cUrl := "https://snowden.totvs.com.br"
Local cPath := "/api/v1/nps/" + ::cProductLine + "." + ::cProductName + "/" +;
                ::cLsID + "/" + __cUserId + "/status?userCreateDate=" +;
                TRANSFORM(VAL(FWSFALLUSERS({__cUserId}, {"USR_DTINC"})[1][3]),"@E 9999-99-99")


If ::getAuthToken()
    oRestClient := FWRest():New(cUrl)
    oRestClient:SetPath(cPath)

    Aadd(aHeadOut, "Content-Type: application/json")
    AAdd(aHeadOut, "charset: UTF-8")
    AAdd(aHeadOut, "Authorization: Bearer " + ::aTokenData[1])

    If oRestClient:Get(aHeadOut)
        If FWJsonDeserialize( oRestClient:GetResult(), @oObj )
            lRet := oObj:canSendAnswer
        EndIf
    EndIf
EndIf

return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} setUserName

@description Define o nome do usuário

@param cSetValue, String, nome do usuário (UsrRetName() por padrão)

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method setUserName(cSetValue) class GsNps

return (::cUserName := cSetValue)
//------------------------------------------------------------------------------
/*/{Protheus.doc} setUserEmail

@description Define o email do usuário

@param cSetValue, String, email do usuário (UsrRetMail() por padrão)

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method setUserEmail(cSetValue) class GsNps

return (::cUserEmail := cSetValue)
//------------------------------------------------------------------------------
/*/{Protheus.doc} setRating

@description Define a nota respondida na pesquisa

@param nSetValue, int, nota informada pelo usuário

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method setRating(nSetValue) class GsNps

return (::nRating := nSetValue)
//------------------------------------------------------------------------------
/*/{Protheus.doc} setComment

@description Define o comentário enviado pelo cliente

@param cSetValue, String, comentário do usuário

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method setComment(cSetValue) class GsNps

return ::cComment := cSetValue
//------------------------------------------------------------------------------
/*/{Protheus.doc} setShareEmail

@description Define se o usuário aceitou compartilhar a informação do seu e-mail 
    no envio da pesquisa

@param lSetValue, bool, .T. (padrão) = Aceitou ; .F. = Não aceitou

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method setShareEmail(lSetValue) class GsNps

return (::lShareEmail := lSetValue)
//------------------------------------------------------------------------------
/*/{Protheus.doc} setShareName

@description Define se o usuário aceitou compartilhar a informação do seu nome 
    no envio da pesquisa

@param lSetValue, bool, .T. (padrão) = Aceitou ; .F. = Não aceitou

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method setShareName(lSetValue) class GsNps

return (::lShareName := lSetValue)
//------------------------------------------------------------------------------
/*/{Protheus.doc} setProductName

@description Define o nome do produto

@param cSetValue, String, nome do produto (Ex: "Terceirizacao")

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method setProductName(cSetValue) class GsNps

return (::cProductName := cSetValue)
//------------------------------------------------------------------------------
/*/{Protheus.doc} getAuthToken

@description Realiza a autenticação para comunicação com a API do Snowden

@return lRet, bool, se conseguiu realizar a autenticação

@author	boiani
@since	12/11/2021
/*/
//------------------------------------------------------------------------------
method getAuthToken() class GsNps
Local aHeader := {}
Local oRest := FWRest():New("https://apimprod.totvs.com.br")
Local oObj := Nil
Local lRet := .T.

If EMPTY(::aTokenData) .OR. SubHoras(TIME(),::aTokenData[2]) >= 0.59

    ::aTokenData := {}
    lRet := .F.

    AAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")
    AAdd(aHeader, "charset: UTF-8")

    oRest:SetPath("/api/token?grant_type=client_credentials")
    oRest:SetPostParams('client_id=cMpSMcXKJGHbGRCAA0HpeMKAj3Ma&client_secret=f8w87q9zt9nnorCCvwFbGXhUZUYa')

    If oRest:Post(aHeader)
        If (lRet := FWJsonDeserialize(oRest:GetResult(),@oObj))
            AADD(::aTokenData, oObj:access_token)
            AADD(::aTokenData, TIME())
        EndIf
    EndIF
EndIf

return lRet
