#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH" 
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"    

/*/{Protheus.doc} G001Cancel   
    Cancela  CTEOS junto ao sefaz
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 02/10/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPC854Cancel()

If H61->H61_STATRA $ '2|4' .AND. H61->H61_STATUS != '4'
	H61Cancel()	
Else
	FwAlertHelp("CANCELAMENTO","Apenas CTEOS com documento de saida excluido e que ainda não tenha sido enviado o cancelamento podem ser transmitido o cancelamento.") 		
Endif

Return()

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} H61Cancelamento
Impressão do CTeOS

@param	cAlias  Alias do Browse
@param	nReg    Recno do Registro
@param	nOpc    Opcao da operção

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function H61Cancel(cAlias, nReg, nOpc) 

    local cError         := ""
    local cEntidade      := getCfgEntidade(@cError)
    local lContinua      := .T.
    local cChaveCte
    local oFont
    local oWizard
    local cLbStatus      := ""
    local oImgStatus
    local cJustificativa := ""
    local cBtmStatus     := ""
    local cRetorno       := ""
    local oSay
    local cId

    lContinua := !empty(cEntidade)

    if(lContinua)

        cChaveCte := getKeyCteOS()
        cId       := (alltrim(H61->H61_SERIE) + alltrim(H61_NOTA))

        cTexto := "A seguir, Informe a Justificativa para o cancelamento do CTeOS"

        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD

        oWizard := APWizard():new( "Evento de Cancelamento","Assistente para transmissão",;
                                   "CTeOS - Carta de Correção " + CRLF,cTexto,,,,,,.F.)

        oWizard:NewPanel ( "Justificativa do Cancelamento" ,"" , {||.T.} ,;
            {|| processa({|| procCTEosCanc(cEntidade, cId, cChaveCTe, cJustificativa, @cLbStatus, @oImgStatus, @cRetorno) }), .T.} , {|| .T.})

        @000,000 GET cJustificativa MEMO SIZE 299, 138 PIXEL OF oWizard:oMPanel[2]

        oWizard:NewPanel ( "Finalizado Processo de Cancelamento" , cRetorno , {|| .T.} , {|| .T.} , {|| .T.})

        oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[3], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
        @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[3] PIXEL FONT oFont SIZE 150, 015
        @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[3]

        ACTIVATE WIZARD oWizard CENTERED
    else
        aviso("CTeOS - Cancelamento", cError, {STR0004}, 3)
    endif

return nil

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} procCanc
Processa Cancelamento(Transmissão e consulta)

@param	cEntidade       Codigo da Entidade cadastrada no TSS
@param	cChaCTe         Serie do CTeOS
@param	cProtocolo      Protocolo do CTe OS
@param	cJustificativa  Justificativa do cancelamento
@param	cLbStatus          Lable para Status do Processamento
@param	oImgStatus        Imagem para indicação do Status do processamento
@param	cError          Referencia para retorno de erro
@param	cRetorno        Referencia para Retorno

@return	oResp           Objeto com resposta do Processamento

@author  Renato Nagib
@since   22/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function procCTEosCanc(cEntidade, cID, cChave, cJustificativa, cLbStatus, oImgStatus, cRetorno)

    local oReq
    local oResp
    local cReq
    local lValid

    lValid := validaJustificativa(cJustificativa)

    if(lValid)

        cReq := '{ "msg": {"entidade": "' + cEntidade +'", "notas": ['
        cReq += '{"id": "' + cID + '", "chave":"' + cChave + '","justificativa": "' + cJustificativa + '"} ] } }'

        if(fwJsonDeserialize(cReq, @oReq) )

            CTeOSTCanc(oReq, @oResp)

            if(oResp:error == nil)

                cReq := '{ "msg":{'
                cReq += ' "entidade": "' + cEntidade + '"'
                cReq += ', "modelo": "67"'
                cReq += ', "id": "' + cID + '"'
                cReq += ', "serie": "'+ H61->H61_SERIE + '"'
                cReq += ', "nota": "'+ H61->H61_NOTA + '" }}'

                if(fwJsonDeserialize(cReq, @oReq))

                    CTeOSMnt(oReq, @oResp)

                    if(oResp:error == nil)
                        cRetorno := "Id: "           + oResp:response:id + CRLF
                        cRetorno += "Protocolo: "    + oResp:response:protocolo + CRLF
                        cRetorno += "Situação: "     + oResp:response:situacao + CRLF
                        cRetorno += "Status Sefaz: " + oResp:response:statusSef
                        cRetorno += " - "            + oResp:response:descSef + CRLF

                        if(oResp:response:status == "3")
                            //GTPA850MStatus("2", "5")
                            oImgStatus:setBmp("qmt_ok.png")

                        elseif(oResp:response:status $ "1|2")
                            oImgStatus:setBmp("qmt_cond.png")
                            cLbStatus := "Cancelamento não Processado"
                        elseif(oResp:response:status == "4")
                            oImgStatus:setBmp("qmt_no.png")
                            //GTPA850MStatus('3','5')

                        endif

                        cLbStatus := oResp:response:descSef

                    else
                        cRetorno := decode64(oResp:error)
                        oImgStatus:setBmp("qmt_no.png")
                        cLbStatus := "Falha na Consulta do Cancelamento."
                    endif

                else
                    cRetorno  := "Requisicao inválida:" +CRLF + cReq
                    oImgStatus:setBmp("qmt_no.png")
                    cLbStatus := "Falha na Consulta do Cancelamento."

                endif

            else
                cRetorno := decode64(oResp:error)
                oImgStatus:setBmp("qmt_no.png")
                cLbStatus := "Falha na Transmissão do Cancelamento"

            endif
        else
            oImgStatus:setBmp("qmt_no.png")
            cLbStatus := "Falha na Transmissão do Cancelamento."
            cRetorno := "Requisicao inválida:" +CRLF + cReq
        endif

        oImgStatus:refresh()
    endif

return lValid

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getChaveCteOS
Retorna Cahave para o documetno

@param cAutorizado  Indica se o CTe foi autorizado
@param cRetorno     String com Retorno da Transmissão
@param cXmlProt     XML Prot de Distribuição do CTe

@return	nil

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function getKeyCteOS()

    local cChaCTe := ""
    local oCteOS
    local oProtCTeOS
    local cError := ""

    if(!getCTeOS(@oCTeOS, @oProtCTeOS, @cError))

        cChaCTe += getUFCode(SM0->M0_ESTCOB)
        cChaCTe += substr(dtos(date()), 3, 2)
        cChaCTe += substr(dtos(date()), 5, 2)
        cChaCTe += SM0->M0_CGC
        cChaCTe += "67"
        cChaCTe += strZero(val(H61->H61_SERIE), 3)
        cChaCTe += strZero(val(H61->H61_NOTA), 9)
        cChaCTe += "1"
        cChaCTe += strZero(val(H61->H61_NOTA), 8)
        cChaveCTe := cChaCTe + modulo11(cChaCTe)

    else
        cChaveCte  := oProtCTeOS:_infProt:_chCTe:text

    endif

return cChaveCTe

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCTeOS
Retorna objeto Xml do CTeOS gravado na tabela H61

@param	oRetorno    Referencia para retorno do Objeto
@param	cChaveCTe   Referencia para retorno de error na execução

@return	lGet        Indica se o Objeto foi criado

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
static function getCTeOS(oCTeOS, oProtCTeOS, cError)

    local cErro  := ""
    local cAviso := ""
    Local cEveCteos := ""
    Local lOk   := .F.
    private oXml

    //0=Normal;1=Complemento;2=Anulacao;3=Substituicao;4=Documento excluído;5=Cancelamento
    If H61->H61_STATUS == '0'
        cEveCteos := "00"
    ElseIf H61->H61_STATUS == '1'
        //cEveCteos := "03"
    ElseIf H61->H61_STATUS == '2'
        //cEveCteos := "01"
    ElseIf H61->H61_STATUS == '3'
        //cEveCteos := "02"
    EndIf

    H62->(DbSetOrder(1))
    H62->(DbSeek(H61->H61_FILIAL + H61->H61_CODIGO + cEveCteos))

    if(empty(H62->H62_XMLCTE))
        cError := "Protocolo não localizado"
    else
        oXml := XmlParser(H62->H62_XMLCTE, "_", @cErro, @cAviso)

        if(oXml <> nil)

            if( type("oXml:_cteProc:_protCTe:_infProt") <> "U")
                oProtCTeOS := oXml:_cteProc:_protCTe
                lOk := .T.
            elseif( type("oXml:_cteOsProc:_protCTe:_infProt") <> "U")
                oProtCTeOS := oXml:_cteOsProc:_protCTe
                lOk := .T.
            endif

            if( type("oXml:_cteProc:_CTEOS:_infCte") <> "U")
                oCTeOS := oXml:_cteProc:_CTEOS
                lOk := .T.
            elseif( type("oXml:_cteOsProc:_CTEOS:_infCte") <> "U")
                oCTeOS := oXml:_cteOsProc:_CTEOS
                lOk := .T.
            endif

        else
            cError := cErro + cAviso
        endif
    endif 
return lOk

/*/{Protheus.doc} GetUFCode
    (long_description)
    @type  Static Function
    @author user
    @since 25/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function GetUFCode(cUF,lForceUF)

    Local nX         := 0
    Local cRetorno   := ""
    Local aUF        := {}
    
    DEFAULT lForceUF := .F.

    aadd(aUF,{"RO","11"})
    aadd(aUF,{"AC","12"})
    aadd(aUF,{"AM","13"})
    aadd(aUF,{"RR","14"})
    aadd(aUF,{"PA","15"})
    aadd(aUF,{"AP","16"})
    aadd(aUF,{"TO","17"})
    aadd(aUF,{"MA","21"})
    aadd(aUF,{"PI","22"})
    aadd(aUF,{"CE","23"})
    aadd(aUF,{"RN","24"})
    aadd(aUF,{"PB","25"})
    aadd(aUF,{"PE","26"})
    aadd(aUF,{"AL","27"})
    aadd(aUF,{"SE","28"})
    aadd(aUF,{"BA","29"})
    aadd(aUF,{"MG","31"})
    aadd(aUF,{"ES","32"})
    aadd(aUF,{"RJ","33"})
    aadd(aUF,{"SP","35"})
    aadd(aUF,{"PR","41"})
    aadd(aUF,{"SC","42"})
    aadd(aUF,{"RS","43"})
    aadd(aUF,{"MS","50"})
    aadd(aUF,{"MT","51"})
    aadd(aUF,{"GO","52"})
    aadd(aUF,{"DF","53"})

    If !Empty(cUF)
    	nX := aScan(aUF,{|x| x[1] == cUF})
    	If nX == 0
    		nX := aScan(aUF,{|x| x[2] == cUF})
    		If nX <> 0
    			cRetorno := aUF[nX][1]
    		EndIf
    	Else
    		cRetorno := aUF[nX][IIF(!lForceUF,2,1)]
    	EndIf
    Else
    	cRetorno := aUF
    EndIf

Return(cRetorno)

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} validaJustificativa
Valida Justificativa

@param cJustificativa  texto da Justificativa

@return	lValid          Indica se o texto esta válido

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------

static function  validaJustificativa(cJustificativa)

    local lValid := .T.
    
    cJustificativa := Alltrim(cJustificativa)
    cJustificativa := StrTran(cJustificativa,Chr(10),"")
    cJustificativa := StrTran(cJustificativa,Chr(13),"")
    cJustificativa := StrTran(cJustificativa,Chr(135),"&Amp;")
    cJustificativa := StrTran(cJustificativa,Chr(198),"&atilde;")

    if( Len(cJustificativa) < 15 )
        lValid := .F.
        cJustificativa := "A Correção deve ter o mínimo de 15 caracteres"
    elseif(len(cJustificativa) > 255)
        cJustificativa := "A Correção deve ter o máximo de 255 caracteres"
        lValid := .F.
    endif

    if(!lValid)
        aviso("CTeOS - Cancelamento", cJustificativa, {STR0004}, 3) //ok
    endif

return lValid

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSCancelamento
Transmite um cancelamento de CTeOS para o TSS

@param	oReq    {{"msg":{"entidade": "","canc":[{"chaveCTe":"","protocolo":"","justificativa":""}]} }
@param	oResp   {"response":{"motivo": "Cancelamento Transmitido com Sucesso","idEvento":[{"id": ""}]}, "error":null}

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------------------------
function CTeOSTCanc(oReq, oResp, lAut)

    Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    local cJsonRet
    local cXml        := ""
    local cError    
    local oWs
    local nNotas
    Default lAut := .F.

    oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
    if !lAut
	    oWs:cID_ENT    := oReq:msg:entidade
    Else
        oWs:cID_ENT    := ''
    EndIf
	oWS:_URL       := AllTrim(cURL) + "/NFeSBRA.apw"
	oWs:oWsNFe:oWsNotas :=  NFESBRA_ARRAYOFNFES():New()
	
    if !lAut
        for nNotas := 1 to len(oReq:msg:notas)

            cXml += '<cancelamento Id="' + oReq:msg:notas[nNotas]:chave + '">'
            cXml += '<xJust>' + oReq:msg:notas[nNotas]:justificativa + '</xJust>
            cXml += '</cancelamento>'

            aadd(oWs:oWsNFe:oWsNotas:oWSNFES,NFESBRA_NFES():New())	
            oWs:oWsNFe:oWsNotas:oWSNFES[nNotas]:cID := oReq:msg:notas[nNotas]:id
	        oWs:oWsNFe:oWsNotas:oWSNFES[nNotas]:cXML:= cXml
        next
    EndIf

    if(oWS:cancelanotas()) 
    
        cJsonRet := '{ "motivo": "Cancelamento Transmitido com Sucesso", "id": ['  
        
        for nNotas := 1 to len(oWS:oWSCANCELANOTASRESULT:oWSID:cSTRING)        
            cJsonRet += '{"id": "' + oWS:oWSCANCELANOTASRESULT:oWSID:cSTRING[nNotas] + '"}'
        next
        
        cJsonRet += ']}'
        
        //Atualização do Status da H61
        GTPA850MStatus('2','5')
    
    endif    
    
    freeObj(oWs)
    oWS := nil

    oResp :=  getJsonResponse(cJsonRet, cError) 
    
return (oResp <> nil)
