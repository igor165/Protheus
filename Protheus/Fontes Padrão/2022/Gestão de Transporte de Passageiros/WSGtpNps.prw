#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL WsGtpNps DESCRIPTION  "WebService Metricas GTP"
    WSDATA nGrade       AS INTEGER
    WSDATA cComment     AS STRING
    WSDATA nAction     	AS INTEGER
    WSDATA lSendEmail   AS BOOLEAN 
    WSDATA cProduct     AS STRING

	WSMETHOD GET MetricNPS DESCRIPTION "Métrica de NPS" PATH "nps" PRODUCES APPLICATION_JSON 
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} MetricNPS
Recebe os dados de NPS 

@param nGrade     - Nota de 0 a 10
@param cComment   - Comentário do Usuário
@param nAction    - Tipo de ação de envio 
                    [1] - Confirmação de dados e envio
                    [2] - Envia sem a nota
@param lSendEmail - Envia do usuário
@param cProduct   - Produto no Snowden

@author SIGAGTP
@since 18/01/2022
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET MetricNPS WSRECEIVE nGrade, cComment, nAction, lSendEmail, cProduct  WSREST WsGtpNps
Local cResponse         := ""
Local nNota             := Self:nGrade
Local cComentario       := Self:cComment
Local nOpc              := Self:nAction
Local lEmail            := Self:lSendEmail
Local cProduto          := Self:cProduct
Local oGsNps            := GsNps():New()

    // Informações enviadas pelo Usuário
    oGsNps:setRating(nNota)
    oGsNps:setShareEmail(lEmail)
    oGsNps:setShareName(lEmail)
    oGsNps:setComment(cComentario)

    oGsNps:setProductName(cProduto) //Tag do Produto no Snowden
    oGsNps:sendAnswer(nOpc)

    cResponse := '{"total": "'+cValToChar(10)+'" }'
    Self:SetResponse( EncodeUTF8(cResponse) )
Return .T.
