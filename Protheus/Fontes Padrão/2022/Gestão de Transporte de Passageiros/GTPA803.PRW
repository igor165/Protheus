#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} GTPA803
//TODO Descrição auto-gerada.
@author osmar.junior
@since 08/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPA803()

/* 
"0=CTe Não Transmitido",
"1=CTe Aguardando",
"2=CTe Autorizado",
"3=CTe Nao Autorizado",
"4=CTe em Contingencia",
"5=CTe com Falha na Comunicacao",
"9=Documento não preparado para transmissão" 
*/      

If G99->G99_STATRA  $ '0|3|5'  
	G803Remess()	
Else
	FwAlertHelp("STATUS","Apenas CTE pendentes de transmissão ou que irão ser retransmitidos podem utilizar essa função.") 		
Endif

Return 



/*/{Protheus.doc} G803Remess
//TODO Descrição auto-gerada.
@author osmar.junior
@since 08/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, descricao
@param nRec, numeric, descricao
@param nOpc, numeric, descricao
@param cEvento, characters, descricao
@type function
/*/
function G803Remess(cAlias, nRec, nOpc,cEvento)

    local cSerie        := ""
    local cNota         := ""
    local cError	    := ""
	Local cEntidade     := ""
	Local cAmbiente     := ""
	local cModelo       := "57"
	Local lOk           := .F.
	local cVersaoTSS    := ""
	Local cModalidade   := ""
	Local cVersaoCTe    := ""
    local nTempo        := 0
	Local cMsg          := ""
	Local oWizard       := NIL
    local cRetorno      := ""
    local aCfgVerao     := {}
    local cHorario      := ""
    local cHrVerao      := ""
    local lAutorizado   := .F.   
    local oFont         := NIL
    local oSay          := NIL
    local cBtmStatus    := "qmt_no.png"
    local cLbStatus     := ""
    local cReq          := ""
	local cModal        := ""
	Local cCliente      := ""
	Local cLoja         := ""
    local oReq          := NIL
    local oResp         := NIL
	Local cFilDoc       := ""
	//local lauto         := iif(__cUserId == '000000'.And. dDataBase == StoD('20190301'),.T.,.F.)
    
    Default cEvento     := ''
    
    cSerie   := G99->G99_SERIE
    cNota    := G99->G99_NUMDOC
    cModal  := Alltrim(G99->G99_TIPCTE)
    cEvento := AllTrim(G99->G99_TIPCTE)

	If G99->(FieldPos('G99_FILDOC')) > 0
		cFilDoc := G99->G99_FILDOC
	Else
		cFilDoc := Posicione('GI6',1,xFilial('GI6')+G99->G99_CODEMI,"GI6_FILRES")
	Endif

    dbSelectArea("G99")
	dbSetOrder(2)		//G99_FILIAL+G99_SERIE+G99_NUMDOC
	If MsSeek(xFilial("G99")+cSerie+cNota+cEvento)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona NF                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cEvento == '2'
			dbSelectArea("SF1")
			dbSetOrder(1)
	        If MsSeek(cFilDoc+cNota+cSerie)        
	            cCliente := SF1->F1_FORNECE
	            cLoja    := SF1->F1_LOJA           
	        EndIf
        Else
			dbSelectArea("SF2")
			dbSetOrder(1)
	        If MsSeek(cFilDoc+cNota+cSerie)        
	            cCliente := SF2->F2_CLIENTE
	            cLoja    := SF2->F2_LOJA           
	        EndIf
        Endif
    EndIf
	//If !lAuto
		If (!isConnTSS(@cError) )
			cError := "Falha de comunicação com TSS. Realize a configuração."
			aviso("CTeOS", cError, {STR0114}, 3)
			spedNFeCfg()
			cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
		endif
	//EndIf
    lOk := empty(cError)

    if(lOk)
        cEntidade := getCfgEntidade(@cError)
        lOk := empty(cError)
    endif


    if(lOk)
        lOk := isCFGReady(cEntidade, @cError)
    endif

    if(lOk)
        lOk := isValidCert(cEntidade, @cError)
    endif

    if(lOk)
        cAmbiente := getCfgAmbiente(@cError, cEntidade, cModelo)
    endif

    if(empty(cError))
      	If AllTrim(G99->G99_TPEMIS) $ '7|8|'      	
      		cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo, Iif(AllTrim(G99->G99_TPEMIS)=='7','9','8')), 30) 
    	Else	
    		cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo,'1'), 30)
        EndIf
    endif
    
  

    if(empty(cError))
        cVersaoCTe := getCfgVersao(@cError, cEntidade, '57')
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
		lOk := empty(cError)
	endif
	
	If lOk
		If cModelo == "57"
			getCfgEpecCte()
		EndIf
	EndIf


    //String da Requisiç?o
	cReq := '{ "msg": {'
    cReq += '"entidade":"' + cEntidade + '", '
    cReq += '"ambiente":"' + substr(cAmbiente, 1, 1) +'", '
    cReq += '"modalidade": "' + substr(cModalidade, 1, 1) + '", '
    cReq += '"versao":"' + cVersaoCTe + '", '
    cReq += '"modal":"' + cModal + '", '
    cReq += '"documento": { "nota": "'+ cNota + '", "serie":"' + alltrim(cSerie) +'", "cliente":"' + cCliente + '", "loja": "' + cLoja +'" }}}'
    if(!fwJsonDeserialize(cReq, @oReq) )
        lOk := .F.
        cError := "Requisição Invalida. " + CRLF + cReq
    endif



    if (!lOk) //.OR. !lauto
		 aviso("CTe ", cError, {STR0114}, 3)

    else

        cMsg := "Esta rotina tem como objetivo auxiliá-lo na transmissão do CTe de encomendas para o serviço TSS. "
        cMsg += "Neste momento o TSS está operando com o serviço CTe com a seguinte configuração:" + CRLF + CRLF
        cMsg += "Ambiente: " + substr(cAmbiente, 3) + CRLF + CRLF
        cMsg += "Modalidade de emissão: " + substr(cModalidade, 3) + CRLF	+ CRLF
        cMsg += "Horário: "  + cHorario + CRLF + CRLF
        cMsg += "Horario de Verão: " + cHrVerao + CRLF	+ CRLF
        cMsg += "Tempo de espera para entrada em Contingência: " + alltrim(str(nTempo)) + CRLF	+ CRLF
        cMsg += "Versão CTe : " + cVersaoCTe + CRLF + CRLF
        cMsg += "Release TSS: " + cVersaoTSS + CRLF + CRLF

        DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD

    endif


    if(lOk)// .or. lauto


        /*---------------------------------------------------------------------
                                WIZARD DE TRANSMISSAO
        ----------------------------------------------------------------------*/
        oWizard := APWizard():new( STR0019,;
            "Certifique-se das configuraçôes antes da trasmissão do documento",;
            "Assitente de Transmissão de CTe",;
            cMsg,;
            {|| processa(; 
                {||;
                    GTPACTeTra(oReq, @oResp, cEvento,@lAutorizado) ,;
                    if(lAutorizado, ;
                        ProcRetCte(@lAutorizado, @cRetorno, "1", cSerie, cNota, cNota, cEvento),;
                        ),;
                    if(lAutorizado, ;
                            (cLbStatus := "Documento Autorizado! ", oImgStatus:setBmp("qmt_ok.png")),; 
                            (cLbStatus := "Documento Não autorizado. ", oImgStatus:setBmp("qmt_no.png"));
                        ),;
                    oImgStatus:refresh();
                }) ,;
                .T.;
            })

        @ 010,010 GET cMsg MEMO SIZE 280, 125 READONLY PIXEL OF oWizard:oMPanel[1]

        CREATE PANEL oWizard ;
            HEADER "Finalizada Transmissão para  o TSS";
            MESSAGE "";
            BACK {|| .F. };
            PANEL

        oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[2], {||},,.F.,.F.,,,.F.,,.T.,,.F.)
        @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[2] PIXEL FONT oFont SIZE 150, 015
        @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[2]

        ACTIVATE WIZARD oWizard CENTERED

    endif

return nil



/*/{Protheus.doc} GTPACTeTra
//TODO Descrição auto-gerada.
@author osmar.junior
@since 08/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oReq, object, descricao
@param oResp, object, descricao
@param cEvento, characters, descricao
@type function
/*/
Function GTPACTeTra(oReq, oResp, cEvento,lAutorizado,lAuto)
    
    local aRetorno      := {}
    local cXml          := ""
	Local cURL          := PadR(GetNewPar("MV_SPEDURL","http://"), 250)
	local cTimeZone     := ""	
    local lTransmite    := .F.
    local cJsonRet      := ""
    local cError        := ""
    Local cIdEnt        := oReq:msg:entidade
    Local cID 		    := oReq:msg:documento:serie + oReq:msg:documento:nota
    Local cErroSche     := ''
    Default cEvento     := ''
    Default lAutorizado := .F.
    Default lAuto	    := .F.
    
    private  oWS
	
    cTimeZone := getUTC(oReq:msg:entidade)
	
    oWs:= wsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL) + "/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()


	if( existBlock("GTPCTEXML", , .T.) )
        if(oReq:msg:versao <> "3.00")
            cError := "Nenhum RdMake compilado para versão " + oReq:msg:versao
        else
            aRetorno  := ExecBlock("GTPCTEXML", .F., .F.,; 
                                    {oReq:msg:documento:serie,;     //1
                                    oReq:msg:documento:nota,;       //2
                                    oReq:msg:documento:cliente,;    //3
                                    oReq:msg:documento:loja,;       //4                                                 
                                    oReq:msg:ambiente,;             //5
                                    oReq:msg:versao,;               //6
                                    oReq:msg:modalidade,;           //7                                                
                                    cTimeZone,;                     //8                                    
                                    cEvento })                		//9
                                                            
            cChave	  := aRetorno[1] 
            cXml      := aRetorno[2]                   
            
            aSize(aRetorno,0)
            aRetorno := nil
            
            lTransmite := !empty(cXml)
            
            if(!lTransmite)
                cError := "Xml Inválido para Transmissão"
            endif
        endif    
	else
        lAutorizado := .F.
        cError := 'RdMake "GTPCTEXML" não compilado'        
    endif

	if(lTransmite)						
		
		aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())
		oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cID := cID
		oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cXML:= cXml
	
        if( oWS:Remessa() ) 
        	lAutorizado := .T.
	        If Len(oWs:oWsRemessaResult:oWSID:cString) <> 1
	        	
	        	oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN        := "TOTVS"
				oWS:cID_ENT           := cIdEnt
				oWS:oWSNFEID          := NFESBRA_NFES2():New()
				oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
				aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
				Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := cID
				oWS:nDIASPARAEXCLUSAO := 0
				oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
				        		        	
	        	If oWS:RETORNANOTAS()
	        		If Len(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
	        			lAutorizado := .F.
	        			cMsg := AllTrim(oWs:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML)
	        			
	        			If !Empty(cMsg) 
						    oWS:= WSNFeSBRA():New()
							oWS:cUSERTOKEN     := "TOTVS"
							oWS:cID_ENT        := cIdEnt
							oWs:oWsNFe:oWSNOTAS:=  NFeSBRA_ARRAYOFNFeS():New()
							aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())
							oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cID := cID
							oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cXML:= EncodeUtf8(cMsg)
							oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
  
							If oWS:Schema()
								If Empty(oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM)
									//If !lAuto
										Aviso("SPED",STR0091) //schema valido   
									//EndIf                               
              
								Else
                                    lAutorizado := .F.
                                    //If !lAuto
	                                    If Len(oWS:oWSSCHEMARESULT:oWSNFES4[1]:oWsSchemaMsg:oWsSchemaError) > 0 .and.; 
	                                        ( MsgYesNo("Schema com erro. Deseja visualizar as possibilidades que podem ter causado o erro?"))
											ViewSchemaMsg( oWS:oWSSCHEMARESULT:oWSNFES4[1]:oWsSchemaMsg:oWsSchemaError )
										Else
											Aviso("SPED",oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM,{"Ok"},3)								
										EndIf										
									//EndIf
									cErroSche := oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf			
			
            RecLock('G99',.F.)
            
            G99->G99_XMLENV := cXml
            
            If G99->G99_TIPCTE $ '0|1'
            	G99->G99_CHVCTE := cChave 
            ElseIf G99->G99_TIPCTE == '2'
				G99->G99_CHVANU := cChave 
			ElseIf G99->G99_TIPCTE == '3'
				G99->G99_CHVSUB := cChave
            Endif
            
            If !Empty(cErroSche)
            	G99->G99_MOTREJ := cErroSche
            EndIf
            
            G99->(MsUnLock()) 
		Else
			lAutorizado := .F.
			cError := "" + iif( empty(getWscError(3)), getWscError(1), getWscError(3))  
		EndIf           
      
    Else
        lAutorizado := .F.
        cError := "" + iif( empty(getWscError(3)), getWscError(1), getWscError(3))        
    EndIf

    freeObj(oWS)
    oWS := nil
    
    oResp := getJsonResponse(cJsonRet, cError)
    
return oResp <> nil


/*/{Protheus.doc} getUTC
//TODO Descrição auto-gerada.
@author osmar.junior
@since 08/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cEntidade, characters, descricao
@type function
/*/
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


/*/{Protheus.doc} ProcRetCte
//TODO Descrição auto-gerada.
@author osmar.junior
@since 08/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oResp, object, descricao
@param lAutorizado, logical, descricao
@param cRetorno, characters, descricao
@param cTpRet, characters, descricao
@param cSerie, characters, descricao
@param cNota, characters, descricao
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@param cEvento, characters, descricao
@type function
/*/
function ProcRetCte(lAutorizado, cRetorno, cTpRet, cSerie, cNotaIni, cNotaFim, cEvento)
Local aAreaSF2  := SF2->(GetArea())
Local aAreaSF3  := SF3->(GetArea())
Local aAreaSFT  := SFT->(GetArea())
Local nX        := 0
Local nY        := 0
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lOk       := .T.
Local oWS
Local oRetorno
Local cNrSerie  := ''
Local cNrDocto  := ''
Local cSitCTE   := ''
Local cCodRet   := ''
Local cIdent    := ''
Local cError    := ''
Default cRetorno := ''

Private oXml

If !(IsBlind())
	If (!isConnTSS(@cError) )
		cError := "Falha de comunicação com TSS. Realize a configuração."
		If !IsBlind()
			aviso("CTe", cError, {'ok'}, 3)
		EndIf
		spedNFeCfg()
		cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
	endif
EndIf

if empty(cError)
    cIdEnt := getCfgEntidade(@cError)
    lOk := empty(cError)
endif

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN    := "TOTVS"
oWS:cID_ENT       := cIdEnt
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
oWS:cIdInicial    := AllTrim(cSerie) + cNotaIni
oWS:cIdFinal      := AllTrim(cSerie) + cNotaFim

lOk := oWS:MONITORFAIXA()
oRetorno := oWS:oWsMonitorFaixaResult

For nX := 1 To Len(oRetorno:oWSMONITORNFE)
	nY       := Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)
	cNrSerie := SubStr(oRetorno:OWSMONITORNFE[nX]:CID,1, LEN(AllTrim(cSerie))) + SPACE(TAMSX3("G99_SERIE")[1]-LEN(AllTrim(cSerie)))
	cNrDocto := SubStr(oRetorno:OWSMONITORNFE[nX]:CID, (LEN(AllTrim(cSerie)) + 1), TamSx3("G99_NUMDOC")[1])
	cNrDocto := PADR(cNrDocto,TamSx3("G99_NUMDOC")[1])

/*//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//           Estas Msg sao retornadas pelo TSS, no metodo ( Substr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,3))                          //
//	aadd(aMsg,"001 - Emissão de DANFE autorizada")                                                                                         //
//	aadd(aMsg,"002 - Não foi possível assinar a Nfe - entre em contato com o responsável")                                                 //
//	aadd(aMsg,"003 - A Nfe ainda não foi assinada - aguarde a assinatura")                                                                 //
//	aadd(aMsg,"004 - Lote ainda não transmitido, verifique o status da SEFAZ")                                                             //
//	aadd(aMsg,"005 - Lote recusado, verifique o motivo da SEFAZ")                                                                          //
//	aadd(aMsg,"006 - ")                                                                                                                    //
//	aadd(aMsg,"007 - Autorizada operação em contigência")                                                                                  //
//	aadd(aMsg,"008 - Autorizada manutenção da operação em contigência")                                                                    //
//	aadd(aMsg,"009 - Aguardar processamento do lote")                                                                                      //
//	aadd(aMsg,"010 - Lote não autorizado. Corrija o problema e retransmita as notas fiscais eletrônicas")                                  //
//	aadd(aMsg,"011 - Entre em contato com a SEFAZ, verifique a versão de layout suportada e atualize os parâmetros do sistema")            //
//	aadd(aMsg,"012 - Lote não autorizado. Verifique os motivos junto a SEFAZ")                                                             //
//	aadd(aMsg,"013 - NFe não autorizada. Verifique os motivos junto a SEFAZ")                                                              //
//	aadd(aMsg,"014 - NFe não autorizada. Corrija o problema e retransmita as notas fiscais eletrônicas")                                   //
//	aadd(aMsg,"015 - Cancelamento autorizado")                                                                                             //
//	aadd(aMsg,"016 - Cancelamento não transmitido, verifique o status da SEFAZ")                                                           //
//	aadd(aMsg,"017 - Cancelamento não autorizado. Verifique os motivos junto a SEFAZ")                                                     //
//	aadd(aMsg,"018 - Dpec autorizado. Emissão de DANFE autorizada")                                                                        //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
 /*
	100 Autorizado o uso do CT-e
	101 Cancelamento de CT-e homologado
	102 Inutilização de número homologado
	103 Lote recebido com sucesso
	104 Lote processado
	105 Lote em processamento
	106 Lote não localizado
	107 Serviço em Operação
	108 Serviço Paralisado Momentaneamente (curto prazo)
	109 Serviço Paralisado sem Previsão
	110 Uso Denegado
	111 Consulta cadastro com uma ocorrência
	112 Consulta cadastro com mais de uma ocorrência
	128 CT-e anulado pelo emissor
	129 CT-e substituído pelo emissor
	130 Apresentada Carta de Correção Eletrônica – CC-e
	131 CT-e desclassificado pelo Fisco

		0 - Nao Transmitido
		1 - Doc Aguardando
		2 - Doc Autorizado
		3 - Doc Nao Autorizado
		4 - Doc em Contingencia
		5 - Doc com Falha na Comunicacao
*/

	If (!Empty(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO))		//-- Mensagem do TSS.
		cSitCTE := oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE
		cCodRet := Substr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,3)
		cRetorno += cCodRet + ' - '
		G99->(dbSetOrder(2))  //MsSeek(xFilial("G99")+cSerie+cNota)
		If	G99->(MsSeek(xFilial('G99')+ cNrSerie + cNrDocto))	
			
				RecLock('G99',.F.)				
				
				G99->G99_PROTOC := oRetorno:OWSMONITORNFE[nX]:CPROTOCOLO
	
				If !Empty(cCodRet) .And. !(cCodRet $ '001/003/002/004/009/016/039')
					G99->G99_MOTREJ := SubStr(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CCODRETNFE;
											 + " - " +;
											  oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE,1,150)
											  
					cRetorno += 	G99->G99_MOTREJ	+ ' - '				  
				EndIf
				
				If cCodRet $ '002/016'
					G99->G99_STATRA := '0'		//-- Nao Transmitido
					cRetorno += 'Nao Transmitido'
	
				ElseIf cCodRet $ '003/004/009/039'
					G99->G99_STATRA := '1'		//-- Aguardando.....	
					cRetorno += 'Aguardando.....'
	
				ElseIf cCodRet $ '001/015'
					G99->G99_STATRA := '2'	//-- Autorizado o uso do Cte.
					G99->G99_MOTREJ := ''
					cRetorno += 'Autorizado o uso do Cte'
					lAutorizado := .T.
	
				ElseIf cCodRet $ '005/010/011/012/013/014/017/026'
					G99->G99_STATRA := '3'		//-- Nao Autorizado
					cRetorno += 'Nao Autorizado'
	
				ElseIf cCodRet $ '007/008'
					G99->G99_STATRA:= '4'		//-- Autorizado Contingencia	
					lAutorizado := .T.	
					cRetorno += ' Autorizado Contingencia'
		
				EndIf
	
				G99->(MsUnLock())
				
				If G99->G99_TOMADO == '0' //REMETENTE					
					cCliente := G99->G99_CLIREM
					cLoja	 := G99->G99_LOJREM
				ElseIf G99->G99_TOMADO == '3' //DESTINATARIO					
					cCliente := G99->G99_CLIDES
					cLoja	 := G99->G99_LOJDES
				EndIf

				If G99->G99_STATRA == '2' .AND. G99->G99_AVERBA $ ' |0' //CT-e Autorizado e não averbado
					//If MsgYesNo("Deseja efetuar a averbação do Ct-e posicionado?", "Averbação")
						GeraAverbacao()
					//EndIf
				EndIf			
				//Nota de saida	
				dbSelectArea("SF2")
				dbSetOrder(1)	//-- F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
				If SF2->(MsSeek(xFilial("SF2") + cNrDocto + cSerie + cCliente + cLoja,.T.))
					RecLock("SF2",.F.)
					SF2->F2_CHVNFE := G99->G99_CHVCTE
					SF2->(MsUnlock())
				EndIf
	
				//Livros Fiscais
				dbSelectArea("SF3")
				dbSetOrder(4) //-- F3_FILIAL+F3_CLIFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
				If SF3->(MsSeek(xFilial("SF3") + cCliente + cLoja + cNrDocto + cSerie,.T.))
					cChave := xFilial("SF3")+ cCliente + cLoja + cNrDocto + cSerie
					While cChave == xFilial("SF3") + SF3->F3_CLIEFOR + SF3->F3_LOJA + SF3->F3_NFISCAL + SF3->F3_SERIE .And. !SF3->(Eof())
						RecLock("SF3",.F.)
						SF3->F3_CHVNFE  := G99->G99_CHVCTE
						SF3->F3_CODRSEF := cSitCTE
						SF3->(MsUnLock())	
						SF3->(dbSkip())
				    EndDo
				EndIf
	
				//-- Livro Fiscal por Item de NF
				SFT->(dbSetOrder(1))
				cChave := xFilial("SFT")+"S"+ cSerie + cNrDocto + cCliente + cLoja
				If SFT->(MsSeek(xFilial("SFT")+"S"+ cSerie + cNrDocto + cCliente + cLoja ,.T.))
					If SFT->(FieldPos("FT_CHVNFE"))>0  .And. SFT->(FieldPos("FT_CODNFE"))>0
						While cChave == xFilial("SFT")+"S"+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA .And. !SFT->(Eof())
							RecLock("SFT",.F.)
							SFT->FT_CHVNFE := G99->G99_CHVCTE
							SFT->FT_CODNFE := oRetorno:OWSMONITORNFE[nX]:CPROTOCOLO
							SFT->(MsUnLock())
							SFT->(dbSkip())
						EndDo
					EndIf
				EndIf			
			
		EndIf

	EndIf

Next nX

RestArea(aAreaSF2)
RestArea(aAreaSF3)
RestArea(aAreaSFT)    

return nil

/*/{Protheus.doc} GeraAverbacao
	(long_description)
	@type  Function
	@author user
	@since 07/04/2022
	@version version
	@param , param_type, param_descr
	@return  return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function GeraAverbacao()

Local lSegPadrao := GTPGetRules('USEENCSEG',,,.T.)
Local cSegPadrao := GTPGetRules('ENCSEGURA',,,)
Local cStatus    := ""
Local lGtpAtm	 := ExistBlock("GTPENVATM") .AND. GTP808ATM(cSegPadrao)
Local aArea      := GetArea()
Local cTipo		:= ''
Local cFilDoc	:= ''
Local cNumDoc	:= ''
Local cSerie	:= ''
Local cCodSeg	:= ''
Local aDadosAvb	:= {}
Local nX		:= 0
Local cStsErro	:= ''
Local cMsgErro	:= ''
	If lSegPadrao
		G99->(DbSetOrder(1))//G99_FILIAL, G99_CODIGO, R_E_C_N_O_, D_E_L_E_T_
		If G99->(DbSeek(G99->G99_FILIAL + G99->G99_CODIGO))
			GIJ->(DbSetOrder(2))//GIJ_FILIAL, GIJ_CODIGO, GIJ_MSBLQL, R_E_C_N_O_, D_E_L_E_T_
			If GIJ->(DbSeek(XFILIAL("GIJ") + G99->G99_CODIGO + "2"))
				GIJ->(Reclock('GIJ',.F.))
					GIJ->GIJ_MSBLQL := '1'//Inativa o registro
				GIJ->(MSUNLOCK())
			EndIf
			cCodSeg := GetNextSeq(G99->G99_CODIGO)
			If lGtpAtm
				cTipo 	:= '1'
				cFilDoc	:= xFilial('GIJ')
				cNumDoc := G99->G99_NUMDOC
				cSerie	:= G99->G99_SERIE
				
				aDadosAvb := ExecBlock("GTPENVATM",.F.,.F.,{cTipo, cFilDoc, cNumDoc, cSerie, cSegPadrao})
		
				
			EndIf

			GIJ->(Reclock('GIJ',.T.))
				GIJ->GIJ_FILIAL := XFILIAL('GIJ')
				GIJ->GIJ_CODIGO := G99->G99_CODIGO
				GIJ->GIJ_CODSEG := cSegPadrao
				GIJ->GIJ_TIPAVB := '1'
				GIJ->GIJ_SEQ    := cCodSeg
				GIJ->GIJ_MSBLQL := "2"
				GIJ->GIJ_DATEMI := dDataBase
				GIJ->GIJ_HOREMI := SubStr(StrTran(TIME(),":",""), 1, 4)
				
				If LEN(aDadosAvb) > 0
					If aDadosAvb[1] // Averbacao Ok
						cStatus	:= "2" //Autorizado
						GIJ->GIJ_STATUS := cStatus
						For nX := 1 To Len(aDadosAvb[2])
						
							If aDadosAvb[2][nX][2] <> Nil
							
								aDadosAvb[2][nX][1] := aDadosAvb[2][nX][2]
								
							Endif
						
						Next
						
					Else // Erro
						cStatus	:= "3" //Rejeitado
						cStsErro := Iif(aDadosAvb[2][1] $ '000/002/907/910/999','2','3') // 2=Falha de comunicacao, 3=Recusado
						
						cMsgErro := aDadosAvb[2][1] + ' - ' + aDadosAvb[2][2]
						
						GIJ->GIJ_STATUS := cStsErro
						GIJ->GIJ_MSERRO := cMsgErro
					
					Endif
				EndIf

			GIJ->(MSUNLOCK())
			
			G99->(Reclock('G99',.F.))
				G99->G99_AVERBA := cStatus
			G99->(MSUNLOCK())
		EndIf
	EndIf
RestArea(aArea)
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetNextSeq
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param cCodCte, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function GetNextSeq(cCodCte)
Local cSeq      := ""
Local cAliasTmp := GetNextAlias()


BeginSql Alias cAliasTmp
    Select 
        IsNull(Max(cast(GIJ_SEQ as int)),0) AS MAX
    From %Table:GIJ% GIJ
    Where
        GIJ.GIJ_FILIAL = %xFilial:GIJ%
        AND GIJ.GIJ_CODIGO = %Exp:cCodCte%
        AND GIJ.%NotDel%
EndSql

cSeq := StrZero((cAliasTmp)->MAX + 1, TamSx3("GIJ_SEQ")[1])

(cAliasTmp)->(DbCloseArea())


Return cSeq


/*/{Protheus.doc} ViewSchemaMsg
//TODO Descrição auto-gerada.
@author osmar.junior
@since 08/10/2019
@version 1.0
@return ${return}, ${return_description}
@param aMessages, array, descricao
@type function
/*/
Static Function ViewSchemaMsg( aMessages )

	Local cTag			:= ""
	Local cDesc			:= ""
	Local cHierarquia   := ""
	Local cDica			:= ""
	Local cErro			:= ""
	Local oTree
	Local nX
	
	DEFINE MSDIALOG oDlg TITLE "Mensagens de Schema X Possibilidades" FROM 0,0 TO 300,500 PIXEL  //"Mensagens de Schema X Possibilidades"
	
	@ 000, 000 MSPANEL oPanelLeft OF oDlg SIZE 085, 000
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ 000, 000 MSPANEL oPanelRight OF oDlg SIZE 000, 000
	oPanelRight:Align := CONTROL_ALIGN_ALLCLIENT
	
	oTree := xTree():New(000,000,000,000,oPanelLeft,,,)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
	
	oTree:AddTree(STR0336,,,"PARENT",,,) //"Mensagens"
	
	For nX := 1 to len(aMessages)
	
		cCargo := aMessages[nX]:cTag
	
		oMessage := aMessages[nX]
	
		If ( oTree:TreeSeek(cCargo) )
			oTree:addTreeItem(STR0337,"BPMSEDT3.png",cCargo+"|"+AllTrim(Str(nX)),{ || SchemaRefreshTree( @cTag, @cDesc, @cHierarquia, @cDica, @cErro, aMessages, oTree ), oTag:Refresh(), oDesc:Refresh(), oHierarquia:Refresh(), oDica:Refresh(), oErro:Refresh() }) //"Possibilidade"
		Else
			If ( nX > 1 )
				oTree:EndTree()
			EndIf
	
			oTree:AddTree(cCargo,"f10_verm.png","f10_verm.png",cCargo,,,,,)
			oTree:addTreeItem(STR0337,"BPMSEDT3.png",cCargo+"|"+AllTrim(Str(nX)),{ || SchemaRefreshTree( @cTag, @cDesc, @cHierarquia, @cDica, @cErro, aMessages, oTree ), oTag:Refresh(), oDesc:Refresh(), oHierarquia:Refresh(), oDica:Refresh(), oErro:Refresh() }) 	//"Possibilidade"
		EndIf
	
	Next nX
	
	oTree:EndTree()
	
	DEFINE FONT oFont BOLD
	
	@ 005, 010 SAY oSay PROMPT STR0334 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Tag:"
	@ 005, 024 SAY oTag PROMPT cTag OF oPanelRight PIXEL SIZE 040, 015
	
	@ 020, 010 SAY oSay PROMPT STR0297+":" OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //Descrição:
	@ 020, 042 SAY oDesc PROMPT cDesc OF oPanelRight PIXEL SIZE 110, 015
	
	@ 035, 010 SAY oSay PROMPT STR0333 OF oPanelRight PIXEL FONT oFont SIZE 040, 015   //"Hierarquia:"
	@ 035, 043 SAY oHierarquia PROMPT cHierarquia OF oPanelRight PIXEL SIZE 150, 015
	
	@ 050, 010 SAY oSay PROMPT STR0332 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Dica:"
	@ 050, 026 SAY oDica PROMPT cDica OF oPanelRight PIXEL SIZE 150, 015
	
	@ 065, 010 SAY oSay PROMPT STR0331 OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Erro Técnico:"
	@ 065, 050 SAY oErro PROMPT cErro OF oPanelRight PIXEL SIZE 100, 055
	
	@ 133, 097 BUTTON oBtn PROMPT STR0330 SIZE 030, 010 ACTION CreateLog( aMessages ) OF oPanelRight PIXEL //"Gerar Log"
	@ 133, 130 BUTTON oBtn PROMPT STR0294 SIZE 028, 010 ACTION oDlg:end() OF oPanelRight PIXEL //"Sair"
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return


/*/{Protheus.doc} SchemaRefreshTree
//TODO Descrição auto-gerada.
@author osmar.junior
@since 08/10/2019
@version 1.0
@return ${return}, ${return_description}
@param cTag, characters, descricao
@param cDesc, characters, descricao
@param cHierarquia, characters, descricao
@param cDica, characters, descricao
@param cErro, characters, descricao
@param aMessage, array, descricao
@param oTree, object, descricao
@type function
/*/
Static Function SchemaRefreshTree( cTag, cDesc, cHierarquia, cDica, cErro, aMessage, oTree )

Local nPos	:= 0

nPos := Val(Substr(oTree:GetCargo(),At("|",oTree:GetCargo())+1))

cTag		:= aMessage[nPos]:cTag
cDesc		:= aMessage[nPos]:cDesc
cHierarquia	:= aMessage[nPos]:cParent
cDica		:= aMessage[nPos]:cLog
cErro		:= aMessage[nPos]:cErro

Return .T.


Static Function G803impr()
	If ExistBlock("ENCDACTE")
		If G99->G99_STATRA == '2' .AND. G99->G99_TIPCTE $ '0|3'  //Somente autorizado e dos tipos normal e substituto
			ExecBlock("ENCDACTE", .f., .f.)
		Else
			FwAlertHelp('Somente CTE autorizado e dos tipos Normal e Substituição podem gerar DACTE.')
		EndIf
	Else
		FwAlertHelp('RdMake (GTPENCDACTE) não compilado.')
	Endif  
return 

//-----------------------------------------------------------------------
/*/{Protheus.doc} CreateLog
Função criará em disco um arquivo xml Log dos erros de schema.

@author Henrique Brugugnoli
@since 26/01/2011
@version 1.0

@param	aMessage	Array com todas as tags e suas mensagens

/*/
//-----------------------------------------------------------------------
Static Function CreateLog( aMessage )

Local cDir		:= IIF(!IsBlind(), cGetFile( "*.xml", "Arquivo"+" XML", 1, "C:\", .T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),, .T. ), "")
Local cFile		:= "schemalog_"+DtoS(Date())+StrTran(Time(),":","")+".xml"

Local nHandle
Local nX

If ( !Empty(cDir) )

	nHandle := FCreate(cDir+cFile)

	If ( nHandle > 0 )

		FWrite(nHandle,"<schemalog>")

		For nX := 1 to len(aMessage)

			FWrite(nHandle,"<possibilidade item='"+AllTrim(Str(nX))+"'>")
			FWrite(nHandle,"<tag>")
			FWrite(nHandle,aMessage[nX]:cTag)
			FWrite(nHandle,"</tag>")
			FWrite(nHandle,"<descricao>")
			FWrite(nHandle,EncodeUTF8(aMessage[nX]:cDesc))
			FWrite(nHandle,"</descricao>")
			FWrite(nHandle,"<hierarquia>")
			FWrite(nHandle,aMessage[nX]:cParent)
			FWrite(nHandle,"</hierarquia>")
			FWrite(nHandle,"<dica>")
			FWrite(nHandle,EncodeUTF8(aMessage[nX]:cLog))
			FWrite(nHandle,"</dica>")
			FWrite(nHandle,"<erro>")
			FWrite(nHandle,aMessage[nX]:cErro)
			FWrite(nHandle,"</erro>")
			FWrite(nHandle,"</possibilidade>")

		Next nX

		FWrite(nHandle,"</schemalog>")
		FClose(nHandle)

		If ( MsgYesNo( "Arquivo de LOG gerado com sucesso em: " + cDir + cFile + CRLF + "Deseja abrir a pasta onde o arquivo foi gerado?" ) ) //"Arquivo de LOG gerado com sucesso em: " # "Deseja abrir a pasta onde o arquivo foi gerado?"
			ShellExecute ( "OPEN", cDir, "", cDir, 1 )
		EndIf

	Else
		MsgInfo("Não foi possível criar o arquivo.")
	EndIf

Else
	MsgInfo("Deve ser informado um diretório para ser salvo o arquivo de LOG.")
EndIf

Return


/*/{Protheus.doc} GTPCTEALL
//TODO Descrição auto-gerada.
@author osmar.junior
@since 30/11/2019
@version 1.0
@return ${return}, ${return_description}
@type function

/*/
Function GTPA803ALL()
	Local cTmpAlias		:= GetNextAlias() 
	Local oReq			:= Nil
	Local oResp			:= Nil	
	Local lAutorizado	:= .F.
	Local aAreaG99      := G99->(GetArea())
	Local lErroAuto     := .F.
	
	
	
	BeginSql Alias cTmpAlias
	    SELECT G99_SERIE SERIE,G99_NUMDOC NUMDOC,R_E_C_N_O_ RECNO
	    FROM %Table:G99% G99
	    WHERE 
	    G99.G99_STATRA IN ('0','3','5') AND
	    G99.G99_FILIAL = %xFilial:G99% AND	    
	    G99.%NotDel%    	    
	EndSql
	
	If (cTmpAlias)->(!Eof())
		While (cTmpAlias)->(!Eof())
		
			G99->(DbGoTo((cTmpAlias)->RECNO))
			If ConfigCTE(@oReq,G99->G99_TIPCTE,G99->G99_TPEMIS,G99->G99_SERIE,G99->G99_NUMDOC)
                GTPACTeTra(oReq, @oResp, AllTrim(G99->G99_TIPCTE),@lAutorizado,.T.)
                If !lAutorizado
                    lErroAuto := .T.
                EndIf
                ProcRetCte(@lAutorizado, '', "1", G99->G99_SERIE, G99->G99_NUMDOC, G99->G99_NUMDOC)
            Endif
			
			(cTmpAlias)->(dbSkip())
			
		End		
	Endif
	
	(cTmpAlias)->(DbCloseArea())
	
	RestArea(aAreaG99)
	
	If lErroAuto
		FWAlertWarning(STR0282,STR0019) //"Erro de Schema" 'Atenção'
	Else
		FWAlertSuccess(STR0551,STR0590) //"Transmitido" "Retorno da Transmissão"
	Endif
	
return

/*/{Protheus.doc} ConfigCTE
//TODO Descrição auto-gerada.
@author osmar.junior
@since 30/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ConfigCTE(oReq,cModal,cTPEMIS,cSerie,cNota)
	Local cError		:= ''
	Local lOk			:= .F.
    Local cEntidade		:= ''
    Local cAmbiente     := ""
    Local cModalidade   := ""
	Local cModelo		:= '57'
	Local aCfgVerao 	:= {}
    Local cHrVerao 		:= ''
    Local cHorario 		:= ''
    Local nTempo		:= 0
    Local cVersaoTSS	:= ''
    Local cReq			:= ''
    Local cCliente      := ''
    Local cLoja         := '' 
    Local aAreaSF2      := SF2->(GetArea())
    
    dbSelectArea("SF2")
	dbSetOrder(1)
	If MsSeek(xFilial("SF2")+cNota+cSerie)        
        cCliente := SF2->F2_CLIENTE
        cLoja    := SF2->F2_LOJA           
    EndIf
    
    oReq := Nil
	If !(IsBlind())
		If (!isConnTSS(@cError) )
			cError := STR0030     
			spedNFeCfg()
			cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
		endif
	EndIf
    lOk := empty(cError)

    if(lOk)
        cEntidade   := getCfgEntidade(@cError)
        lOk         := empty(cError)
    endif


    if(lOk)
        lOk := isCFGReady(cEntidade, @cError)
    endif

   
    if(lOk)
        cAmbiente   := getCfgAmbiente(@cError, cEntidade, cModelo)
        lOk         := empty(cError)
    endif

    if(lOk)
      	If AllTrim(cTPEMIS) $ '7|8|'      	
      		cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo, Iif(AllTrim(cTPEMIS)=='7','9','8')), 30) 
    	Else	
    		cModalidade := PADR(getCfgModalidade(@cError, cEntidade, cModelo,'1'), 30)
        EndIf
        lOk := empty(cError)
    endif
    
  

    if(lOk)
        cVersaoCTe  := getCfgVersao(@cError, cEntidade, '57')
        lOk         := empty(cError)
    endif

    if(lOk)
        aCfgVerao   :=  getCfgEpecCte(@cError)
        cHrVerao    := substr(aCfgVerao[12], 3)
        cHorario    := substr(aCfgVerao[11], 3)
        lOk         := empty(cError)
    endif

    if(lOk)
        nTempo  := getCfgEspera(@cError, cEntidade)
        lOk     := empty(cError)
    endif

    if(lOk)
	    cVersaoTSS  := getVersaoTSS(@cError)
		lOk         := empty(cError)
	endif
	
	If lOk
		If cModelo == "57"
			getCfgEpecCte()
		EndIf
	EndIf

    If lOk
        //String da Requisiç?o
        cReq := '{ "msg": {'
        cReq += '"entidade":"' + cEntidade + '", '
        cReq += '"ambiente":"' + substr(cAmbiente, 1, 1) +'", '
        cReq += '"modalidade": "' + substr(cModalidade, 1, 1) + '", '
        cReq += '"versao":"' + cVersaoCTe + '", '
        cReq += '"modal":"' + Alltrim(cModal) + '", '
        cReq += '"documento": { "nota": "'+ cNota + '", "serie":"' + alltrim(cSerie) +'", "cliente":"' + cCliente + '", "loja": "' + cLoja +'" }}}'
        if(!fwJsonDeserialize(cReq, @oReq) )
            lOk     := .F.
            cError  := "Requisição Invalida. " + CRLF + cReq
        endif
    endif
    RestArea(aAreaSF2)
    
Return lOk
	