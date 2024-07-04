#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH" 
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH" 

/*/{Protheus.doc} GTPC852   
    chama o wizard de transmissão
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 22/09/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPC852()

	Local cStatus	:= H61->H61_STATUS

	If cStatus $ '0'

		If(!GTPC852Cons()[1])
			If H62->H62_EVENTO=='01' //Anula
				GTPC852Rem(,,,'A')
			ElseIf H62->H62_EVENTO=='02' //SUBSTITUI
				GTPC852Rem(,,,'S')
			ElseIf H62->H62_EVENTO=='03' //Complementar
				GTPC852Rem(,,,'C')
			Else
				GTPC852Rem()
			Endif
		Else
            FwAlertHelp("STATUS","CTEOS foi atualizado com sucesso, não precisando ser retransmitido.")
        Endif

	Else
		FwAlertHelp("STATUS","Apenas CTEOS pendentes de transmissão ou que irão ser retransmitidos podem utilizar essa função.")
	Endif

Return()

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPC852Cons
Verifica se a Nota esta autorizada no TSS

@param nil

@return	nil

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function GTPC852Cons(cAlias, nReg, nOpc)

    local cError      := ""
    local cEntidade   := getCfgEntidade(@cError)
    local cReq
    local oReq
    local oResp
    local cRetorno    := ""
    local lAutorizado := .F.
    
    cReq := '{ "msg": { "entidade": "' + cEntidade + '", "cteos": [ {"id":"' + H61->H61_SERIE + H61->H61_NOTA +'" }]}}'

    if(!fwJsonDeserialize(cReq, @oReq))
        cRetorno := "Falha na requisição:" + CRLF + cReq
    else

        //Retorno do XML do CTeOS e XML PRotocolo
        CTeOSRet(oReq, @oResp )

        //Atualiza status da H61 e monta mensagem de Retorno para a Dialog
        ProcRemRet(oResp, @lAutorizado, @cRetorno, "2", H61->H61_SERIE, H61->H61_NOTA, H61->H61_CLIENT, H61->H61_LOJA)

   endif

return {lAutorizado, cRetorno}

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcRemRet
Processa Retorno da Remessa para atualização da H61 e view do Browser

@param oResp        Retorno da Transmissão do CTeOS
@param lAutorizado  Indica se o CteOS foi autorizado
@param cRetorno     Referencia para retorno da String para apresentação da view da transmissão
@cH61Status         status para atualização da H61

@return	nil

@author  Renato Nagib
@since   30/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function ProcRemRet(oResp, lAutorizado, cRetorno, cTpRet, cSerie, cNota, cCliente, cLoja, cEvento, lAut)

    local oXml
    local cErro  := ""
    local cAviso := ""
    local cXml   := ""
    local cChaveCte := ""
    local cXmlSig   := ""
    local cXmlProt  := ""
    local cProtocolo := ""
    local cStat := ''
    Default cEvento := ''
    Default lAut    := .F.

    if !lAut
        if(oResp:error <> nil)
            cRetorno := decode64(oResp:error)
        elseif(!empty(oResp:response:cteos) )

            cRetorno := "Id: " + oResp:response:cteos[1]:id + CRLF

            if(!empty(oResp:response:cteos[1]:xmlProt) )

                lAutorizado := .T.
                cXmlSig := decode64(oResp:response:cteos[1]:xml)
                cXmlProt := decode64(oResp:response:cteos[1]:xmlProt)

                //Monta Xml de distribuição do CTeOS
                cXml := RtProtCte(cXmlSig, cXmlProt, "3.00")
                oXml := XmlParser(cXmlProt, "_", @cErro, @cAviso)

                if(oXml <> nil)
                    cChaveCTe := oXml:_protCTe:_infProt:_chCTe:text
                    cProtocolo := oXml:_protCTe:_infProt:_nProt:text
                    cRetorno  += "Status: "       + oXml:_protCTe:_infProt:_cStat:text + "-" + oXml:_protCTe:_infProt:_xMotivo:text + CRLF
                    cRetorno  += "Chave do CTe: " + oXml:_protCTe:_infProt:_chCTe:text + CRLF
                    cRetorno  += "Recebimento: "  + oXml:_protCTe:_infProt:_dhRecbto:text + CRLF
                    cRetorno  += "Protocolo: "    + oXml:_protCTe:_infProt:_nProt:text + CRLF
                    cStat := oXml:_protCTe:_infProt:_cStat:text

                endif

            else

                if(oResp:response:cteos[1]:rejeicao <> nil)
                    cRetorno += "Rejeição: " + oResp:response:cteos[1]:rejeicao:codigo + CRLF
                    cRetorno += decode64(oResp:response:cteos[1]:rejeicao:descricao)
                else
                    cRetorno += "Verifique legenda ou Retransmita o Documento"
                endif

            endif

            //Atualizacao da tabela H61
            GTPA850Atu(cTpRet, cXml, lAutorizado, cRetorno, cChaveCte,cProtocolo, cSerie, cNota, cCliente, cLoja, cEvento,cStat)

        endif
    endif

return nil

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} retProtCte
Monta XML de deistribuição do CTe

@param cXmlCte      XML assinado 
@param cXmlProt     XML Protocolo
@param cVersao      Vesao do CTeOS

@return	cXml        Xml de Distribuição

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
function RtProtCte(cXMLCte, cXMLProt, cVersao)

    local nAt       := 0      
    local cXml      := ""

    nAt := At("?>",cXmlProt)

    if nAt > 0
        nAt += 2
    else
        nAt := 1
    endIf

    if !Empty(cXMLCte)
        cXml := '<?xml version="1.0" encoding="UTF-8"?>'
        cXml += '<cteOSProc xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVersao + '">'
        cXml += cXMLCte
    endif
    
    do case
        case "retConsSitCTe" $ cXmlProt				
            if("protCTe" $ cXmlProt)
                nAt := At("<protCTe",cXmlProt)
                cXml += StrTran(SubStr(cXmlProt,nAt),"</retConsSitCTe>","")
            else	
                cXml += StrTran(SubStr(cXmlProt,nAt),"retConsSitCTe","protCTe")
            endif
        case "retCancCTe" $ cXmlProt
            cXml += cXmlProt
        case "retInutCTe" $ cXmlProt
            cXml += cXmlProt
        case "protCTe" $ cXmlProt
            cXml += cXmlProt
        otherWise

            cXml += "<protCTe>"
            cXml += cXmlProt
            cXml += "</protCTe>"
    endCase
    
    if( !empty(cXMLCte) )
        cXml += '</cteOSProc>
    endif	

return(allTrim(cXml))

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPC852Rem
Wizard de transmissão do CTeOS

@param	cAlias  Alias do Browse
@param  cReq    Recno do Alias
@param  nOpc    Opção do Browse

@return	nil

@author  Renato Nagib
@since   22/09/2017
@version 12.1.18

/*/
//-------------------------------------------------------------------
function GTPC852Rem(cAlias, nRec, nOpc,cEvento, lAut)

    local cSerie
    local cNota
    local cCliente
    local cLoja
	local cError	   := ""
	Local cEntidade    := ""
	Local cAmbiente    := ""
	local cModelo      := "67"
	Local lOk          := .F.
	local cVersaoTSS   := ""
	Local cModalidade  := ""
	Local cVersaoCTeOS := ""
    local nTempo       := 0
	Local cMsg         := ""
	Local oWizard
    local cRetorno     := ""
    local aCfgVerao    := {}
    local cHorario     := ""
    local cHrVerao     := ""
    local lAutorizado  := .F.
    local cMsgPrint    := ""
    local oFont
    local oSay
    local cBtmStatus  := "qmt_no.png"
    local cLbStatus   := ""
    local cReq        := ""
    local cModal      := ""
    local oReq
    local oResp
    
    Default cEvento := ''
    Default lAut    := .F.
    
    cSerie   := H61->H61_SERIE
    cNota    := H61->H61_NOTA
    cCliente := H61->H61_CLIENT
    cLoja    := H61->H61_LOJA
    cModal   := H61->H61_MODAL

    if(!isConnTSS(@cError) )
        cError := "Falha de comunicação com TSS. Realize a configuração."
        aviso("CTeOS", cError, {STR0004}, 3)
        if !isBlind()
            spedNFeCfg()
        endif
        cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
    endif

    lOk := Iif(lAut,lAut,empty(cError))

    if(lOk)
        cEntidade := getCfgEntidade(@cError)
        lOk := Iif(lAut,lAut,empty(cError))
    endif


    if(lOk)
        lOk := Iif(lAut,lAut,isCFGReady(cEntidade, @cError))
    endif

    if(lOk)
        lOk := Iif(lAut,lAut,isValidCert(cEntidade, @cError))
    endif

    if(lOk)
        cAmbiente := getCfgAmbiente(@cError, cEntidade, cModelo)
    endif

    if(empty(cError))
        cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo), 30)
    endif

    if(empty(cError))
        cVersaoCTeOS := getCfgVersao(@cError, cEntidade, '67')
    endif

    if(empty(cError))
        aCfgVerao :=  getCfgEpecCte(@cError)
        cHrVerao := substr(aCfgVerao[12], 3)
        cHorario := substr(aCfgVerao[11], 3)
    endif

    if(empty(cError))
        nTempo := getCfgEspera(@cError, cEntidade)
    endif

    if(lOk)
	    cVersaoTSS := getVersaoTSS(@cError)
		lOk := Iif(lAut,lAut,empty(cError))
	endif

    //String da Requisição
	cReq := '{ "msg": {'
    cReq += '"entidade":"' + cEntidade + '", '
    cReq += '"ambiente":"' + substr(cAmbiente, 1, 1) +'", '
    cReq += '"modalidade": "' + substr(cModalidade, 1, 1) + '", '
    cReq += '"versao":"' + cVersaoCTeOS + '", '
    cReq += '"modal":"' + cModal + '", '
    cReq += '"documento": { "nota": "'+ alltrim(cNota) + '", "serie":"' + alltrim(cSerie) +'", "cliente":"' + cCliente + '", "loja": "' + cLoja +'" }}}'
    
    if(!fwJsonDeserialize(cReq, @oReq) )
        lOk := .F.
        cError := "Requisição Invalida. " + CRLF + cReq
    endif

    if (!lOk)
		 aviso("CTe OS", cError, {STR0004}, 3)
    else

        cMsg := "Esta rotina tem como objetivo auxiliá-lo na transmissão do CTe de passageiros para o serviço TSS. "
        cMsg += "Neste momento o TSS está operando com o serviço CTeOS com a seguinte configuração:" + CRLF + CRLF
        cMsg += "Ambiente: " + substr(cAmbiente, 3) + CRLF + CRLF
        cMsg += "Modalidade de emissão: " + substr(cModalidade, 3) + CRLF	+ CRLF
        cMsg += "Horário: "  + cHorario + CRLF + CRLF
        cMsg += "Horario de Verão: " + cHrVerao + CRLF	+ CRLF
        cMsg += "Tempo de espera para entrada em Contingência: " + alltrim(str(nTempo)) + CRLF	+ CRLF
        cMsg += "Versão CTe OS: " + cVersaoCTeOS + CRLF + CRLF
        cMsg += "Release TSS: " + cVersaoTSS + CRLF + CRLF

        cMsgPrint := "Imprimir DACTe OS?" + CRLF + CRLF
        cMsgPrint += "A impressão poderá ser feita a qualquer momento através da opcão 'Imprimir DACTE-OS'."

        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD

    endif

    if(lOk) .And. !lAut

        /*---------------------------------------------------------------------
                                WIZARD DE TRANSMISSAO
        ----------------------------------------------------------------------*/
        oWizard := APWizard():new( STR0003,; // Atenção
            "Certifique-se das configurações antes da trasmissão do documento",;
            "Assitente de Transmissão de CTe OS",;
            cMsg,;
            {|| processa({||GTPC851TRAN(oReq, @oResp, cEvento)}),;
                            ProcRemRet(oResp, @lAutorizado, @cRetorno, "1", cSerie, cNota, cCliente, cLoja, cEvento),;
                            if(lAutorizado, (cLbStatus := "Documento Autorizado!", oImgStatus:setBmp("qmt_ok.png")),;
                            (cLbStatus := "Documento Não autorizado.", oImgStatus:setBmp("qmt_no.png"))),;
                            oImgStatus:refresh(), .T. })
        
        @ 010,010 GET cMsg MEMO SIZE 280, 125 READONLY PIXEL OF oWizard:oMPanel[1]

        CREATE PANEL oWizard ;
            HEADER "Finalizada Transmissão para  o TSS";
            MESSAGE "";
            BACK {|| .F. };
            FINISH {|| if(lAutorizado .and. msgYesNo(cMsgPrint, "Impressão do DACTe OS"),;
                         H61PRINT(Alias(), recno(), 4), .T. ), .T. } ;
            PANEL

        oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[2], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
        @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[2] PIXEL FONT oFont SIZE 150, 015
        @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[2]

        ACTIVATE WIZARD oWizard CENTERED

    endif

return nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CTeOSTransmissao
Transmissão do CTeOS

@param	oReq    {"msg": {"entidade":"","ambiente":"","modalidade": "","versao":"","documento": { "nota": "", "serie":"", "cliente":"", "loja": "" }}}
@param	oResp   {"response":{"cteos":[{"id":"","xml": "","rejeicao":{"codigo":"","descricao":""},"xmlProt": null,"xmlProt": ""}]},"error":null}

@return	Retorno logico indicando se o retorno foi gerado

@author  Renato Nagib
@since   22/09/2017
@version 12.1.18

/*/
//-----------------------------------------------------------------------------
Function GTPC851TRAN(oReq, oResp, cEvento, lAut)
    
    local aRetorno  
    local cXml        := ""
	Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"), 250)
	Local cModelo     := "67"
	local cTimeZone   := ""
    local cChaveCte   := ""
    local lTransmite  := .F.
    local cTipoNota   := "1"
    local cJsonRet
    local cError  
    Default cEvento := ''
    Default lAut := .F.
    
    private  oWS
	
    if !lAut
        cTimeZone := getUTC(oReq:msg:entidade)
	EndIf

    oWs:= wsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
    if !lAut
	    oWs:cID_ENT    := oReq:msg:entidade
    else
        oWs:cID_ENT    := ''
    EndIf
	oWS:_URL       := AllTrim(cURL) + "/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()


	if( existBlock("GTPXmlCTeOS", , .T.) )
        if(oReq:msg:versao <> "3.00")
            cError := "Nenhum RdMake compilado para versão " + oReq:msg:versao
        else
        
            aRetorno  := ExecBlock("GTPXmlCTeOS", .F., .F.,; 
                                                {cTipoNota,;                    //1
                                                oReq:msg:documento:serie,;      //2
                                                oReq:msg:documento:nota,;       //3
                                                oReq:msg:documento:cliente,;    //4
                                                oReq:msg:documento:loja,;       //5                                                 
                                                oReq:msg:ambiente,;             //6
                                                oReq:msg:versao,;               //7
                                                oReq:msg:modalidade,;           //8                                                
                                                cTimeZone,;                     //9
                                                oReq:msg:modal,;				//10
                                                cEvento })                		//11
                                                            
            cXml      := aRetorno[1]
            cChaveCte := aRetorno[2]        
            
            aSize(aRetorno,0)
            aRetorno := nil
            
            lTransmite := !empty(cXml)
            
            if(!lTransmite)
                cError := "Xml Inválido para Transmissão"
            endif
        endif    
	else
        cError := 'RdMake "GTPXmlCTeOS" não compilado'        
    endif

	if(lTransmite) .or. lAut					
		oWs:oWsRemessa3EnvNotas:oWSNOTAS := NFESBRA_ARRAYOFREMESSA3ENVNOTA():new()
		aadd(oWs:oWsRemessa3EnvNotas:oWSNOTAS:oWSREMESSA3ENVNOTA, NFESBRA_REMESSA3ENVNOTA():new())
		oWs:oWsRemessa3EnvNotas:oWSNOTAS:oWSREMESSA3ENVNOTA[1]:cID     := iif(lAut, '', oReq:msg:documento:serie + oReq:msg:documento:nota)
		oWs:oWsRemessa3EnvNotas:oWSNOTAS:oWSREMESSA3ENVNOTA[1]:cMODELO := cModelo
		oWs:oWsRemessa3EnvNotas:oWSNOTAS:oWSREMESSA3ENVNOTA[1]:cXML    := cXml
	
        if( oWS:Remessa3() )
            
            cJsonRet := '{ "cteos": [{'            
                
            cJsonRet += '"id":"' + oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cID + '"'        
            
            if(type("oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cXmlSig") <>"U" )
                cJsonRet += ',"xml": "' + encode64(oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cXmlSig)  + '"' 
            endif
            
            if( type("oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:oWSrejeicao" ) <> "U")			     
                cJsonRet += ', "rejeicao":{'
                cJsonRet += '"codigo": "'    + oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:oWSrejeicao:cCodigo + '"'
                cJsonRet += ',"descricao":"' + encode64(oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:oWSrejeicao:cDescricao) + '"}'                    
                cJsonRet += ',"xmlProt": null'
            endif    
            
            if(type("oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cXmlProt" ) <> "U" )                                                
                cJsonRet += ',"xmlProt": "' + encode64(oWS:oWSREMESSA3RESULT:oWSNotas:oWSremessa3RetNota[1]:cXmlProt) + '"'                
            endif
            
            cJsonRet += '}]}'    
        else
            cError := "" + iif( empty(getWscError(3)), getWscError(1), getWscError(3))        
        endif
    endif   

    freeObj(oWS)
    oWS := nil
    
    oResp := getJsonResponse(cJsonRet, cError)
    
return oResp <> nil

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} getUTC
Calcula Hoario UTC

@param cEntidade      Codgo da Entidade

@return	cRet        UTC

@author  Renato Nagib
@since   24/09/2017
@version 12.1.18

/*/
//------------------------------------------------------------------------------------------------
Static Function getUTC(cEntidade)

    Local cError  := ""
    Local cRet 	  := ""
    local aCfgCTe := getCfgEpecCte(@cError, cEntidade)
        
    if(empty(cError) )
        
        //Horario de Verão 
        if(left(aCfgCTe[12],1) == "1") 
            //Fernando de Noronha
            if(left(aCfgCTe[11], 1) == "1")		
                cRet := "-01:00"
            //Brasilia
            elseif(substr(aCfgCTe[11], 1, 1) == "2")	
                cRet := "-02:00"
            //Acre
            elseif(substr(aCfgCTe[11], 1, 1) == "4")	
                cRet := "-04:00"
            //Manaus
            else
                cRet := "-03:00"
            endif
        else
            //Fernando de Noronha
            if Substr(aCfgCTe[11], 1, 1) == "1"		
                cRet := "-02:00"
            //Brasilia
            elseIf Substr(aCfgCTe[11], 1, 1) == "2"	
                cRet := "-03:00"
            //Acre
            elseif	Substr(aCfgCTe[11], 1, 1) == "4"	
                cRet := "-05:00"
            //Manaus
            else
                cRet := "-04:00"						
            endif
        endif
    endif   
return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA850Atu()
	Pega e grava o retorno da transmissão
	
@param cXML   			xml enviado para sefaz
@param lAutorizado   	variavel logica que diz se foi autorizado ou não	
@param cRetorno   		msg de retorno		

@author Fernando Amorim(Cafu)
@since		23/09/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function GTPA850Atu(cTp,cXML,lAutorizado,cRetorno,cChaveCte, cProtocolo, cSerie, cNota, cCliente, cLoja, cEvento, cStat)

Local lRet  		:= .T.
Local lAlter        := .T.
Local cTpMov		:= 'S'
Local cStatus		:= ''

Default cEvento := ''
Default cStat := ''

cStatus := GetStatus(cEvento)

H62->(DbSetOrder(1))
If H62->(DbSeek(H61->H61_FILIAL + H61->H61_CODIGO + cStatus))
    lAlter := .F.
EndIf

If cEvento == '01'
	cTpMov := 'E'
EndIf	

If cTp =='1'//Se for transmissão
	If lAutorizado

		H62->(RecLock(("H62"),lAlter))
		H62->H62_XMLCTE := cXML		
		H62->H62_XMLAUT := cRetorno
		H62->H62_XMLERR := ' '
        H62->H62_PROTOC := cProtocolo
        H62->H62_CHVCTE := cChaveCte
		H62->(MsUnlock())
		
        H61->(RecLock(("H61"),.F.))
		H61->H61_STATRA := '2'		
		H61->(MsUnlock())
	Else
		H62->(RecLock(("H62"),lAlter))
		H62->H62_XMLCTE := cXML		
		H62->H62_XMLERR := cRetorno	
		H62->(MsUnlock())

        H61->(RecLock(("H61"),.F.))
		H61->H61_STATRA := '3'		
		H61->(MsUnlock())
	Endif
Else//Se for atualização
	If lAutorizado
		H62->(RecLock(("H62"),lAlter))
		H62->H62_XMLCTE := cXML		
		H62->H62_XMLAUT := cRetorno
		H62->H62_XMLERR := ' '		
		H62->H62_CHVCTE := cChaveCte		
		H62->(MsUnlock())
        
        H61->(RecLock(("H61"),.F.))
		H61->H61_STATRA := '2'		
		H61->(MsUnlock())
	Endif

Endif

If lAutorizado

	SF3->(DbSetOrder(4))
	If SF3->( DbSeek(xFilial("SF3") + cCliente + padr(cLoja,tamSX3("F3_LOJA")[1] ) + PadR(cNota,TamSx3('F2_DOC')[1]) + PadR(cSerie,TamSx3('F2_SERIE')[1])) )
		reclock("SF3")
		SF3->F3_CHVNFE := cChaveCte
		SF3->F3_PROTOC := cProtocolo
		SF3->F3_CODRSEF := ALLTRIM(cStat)
		SF3->( msunLock() )
	EndIf
	SFT->(DbSetOrder(1))
	
	if(SFT->( DbSeek(xFilial("SF3")+cTpMov+PadR(cSerie,TamSx3('F2_SERIE')[1])+PadR(cNota,TamSx3('F2_DOC')[1])+cCliente + padr(cLoja,tamSX3("F3_LOJA")[1] ) ) ) )
		reclock("SFT")
		SFT->FT_CHVNFE := cChaveCte	
		SFT->(msUnLock())
	EndIf
EndIf				

Return

Static Function GetStatus(cEvento)
Local cStatus := ''

	If cEvento=='A'
		//cStatus := '01'
	ElseIf cEvento=='S'
		//cStatus := '02'
	ElseIf cEvento=='C'
		//cStatus := '03'
	Else
		cStatus := '00'
	EndIf
	
Return cStatus
