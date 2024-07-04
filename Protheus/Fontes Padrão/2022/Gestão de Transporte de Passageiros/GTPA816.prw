#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'GTPA816.CH'

/*/{Protheus.doc} GTPA816ENV
//TODO Descrição auto-gerada.
@author osmar.junior
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPA816ENV()

	Local aXML        := {}
	Local cModel      := '58'  //MDFe
	Local cIdEnt      := ""
	Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cAmbiente   := ""
	Local cModalidade := ""
	Local cVerLayEven := ""
	Local cVerLayout  := ""
	Local cVersaoMDFE := ""
	Local aRet        := {}
	Local lRet        := .T.
	Local nXmlSize2   := 0
	Local cDesc       := ''
	Local aArea       := GetArea()
	Local aRetNotas   := {}
	Local aRetCol     := {}
	Local aErro       := {}
	Local cErro       := ""
	Local lRetorno    := .T.
	Local nX          := 0
	Local nY          := 0
	Local nNFes       := 0
	Local nXmlSize    := 0
	Local oWs
	Local cXML        := ""
	Local cSeek       := ""
	Local cMun        := ""
	Local cJustific   := Space(255)
	Local cChvMDF     := ""
	Local lGeraXML    := .F.
	Local aDoctos     := {}
	Local cAliasQry   := ""
	Local aAreaDTX    := {}
	Local aAreaDYN    := {}
	Local lProcXML    := .F.
	Local lHVerao     := SuperGetMV("MV_TMSHRVR",.F.,.F.) //-- Define se encontra-se no periodo de horario de verao.
	Local cHVerFil    := SuperGetMV("MV_TMSHRFL",.F.,"" ) //-- Define Filiais que nao aderiram ao horario de verao e/ou possuem diferenca de fuso.
	Local cUF         := SuperGetMV("MV_ESTADO" ,.F.,"" ) //-- Define o estado da filial
	Local aDataBase   := {}
	Local dDatMan     := ""
	Local cGrupo      := FWGrpCompany() //Retorna o grupo
	Local cFil        := FWCodFil()     //Retorna o código da filial
	Local cAviso      := ""
	Local cMsgErr     := ""
	Local cChavesMsg  := ""
	Local cMsgManif   := ""
	Local cIdEven     := ""
	Local aNfe        := {}
	Local lRetOk      := .T.
	Local cCondut     := ""
	Local nIncCond    := 0
	Local cProt       := ""
	Local cNomeDA4    := ""
	Local cCGCDA4     := ""
	Local cUTC		  := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := RetIdEnti(.F.)
	cUTC	:= TZoneUTC(cIdEnt)			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o ambiente de execucao do Totvs Services SPED                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cIdEnt)
		oWS :=  WsSpedCfgNFe():New()
		oWS:cUSERTOKEN      := "TOTVS"
		oWS:cID_ENT         := cIdEnt
		oWS:nAmbienteMDFE   := 0 //Val(SubStr(cAmbiente,1,1))
		oWS:cVersaoMDFE     := "0.00"
		oWS:nModalidadeMDFE := Val(GI9->GI9_TPEMIS)// (1-Nomal ou 2-Contingencia)
		oWS:cVERMDFELAYOUT  := "0.00"
		oWS:cVERMDFELAYEVEN := "0.00"
		oWS:nSEQLOTEMDFE    := 0
		oWS:cHORAVERAOMDFE  := '0'
		oWS:cHORARIOMDFE    := '0'
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cModelo         := cModel
		lRet:= oWS:CFGMDFE()

		cAmbiente  := oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
		cModalidade:= SubStr(oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE,1,1)
		cVerLayEven:= oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN
		cVerLayout := oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT
		cVersaoMDFE:= oWS:OWSCFGMDFERESULT:CVERSAOMDFE

	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		lRet:= .F.
	EndIf
		

	If lRet
				
		oWs:= WsNFeSBra():New()
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cModelo    := '58'
		oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
		
		SetDtHr()
		
		If( existBlock("MdfeGTP3", , .T.) )
			aXml := ExecBlock("MdfeGTP3",.F.,.F.,{GI9->GI9_FILIAL, GI9->GI9_SERIE, GI9->GI9_NUMERO,SubStr(cAmbiente,1,1),cVersaoMDFE,GI9->GI9_TPEMIS,'E', cUTC ,GI9->GI9_CODIGO})
		
	
			aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())		
			oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cID := GI9->GI9_SERIE+ GI9->GI9_NUMERO //'58' + GI9->GI9_SERIE+ GI9->GI9_NUMERO   //Serie + Manifesto
			oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cXML:= aXML[2]
			
			//(oWs,cErro,cSerie,cNumDoc,cIdEnt,cURL)
			MDFEStatus('0',aXML[1],aXML[2],'','','','')
			WsMDFeGTP(cIdent, GI9->GI9_SERIE, GI9->GI9_NUMERO, GI9->GI9_NUMERO, .F.)
			lRetorno := XMLRemMDF(@oWs,@cErro,GI9->GI9_SERIE,GI9->GI9_NUMERO,cIdEnt,cURL)			
			
			//---------- Gravacao dos Dados do retorno da SEFAZ --------
			If lRetorno			
				Sleep(10000)	
				WsMDFeGTP(cIdent, GI9->GI9_SERIE, GI9->GI9_NUMERO, GI9->GI9_NUMERO, .F.)		
			Else
			//-- Rotina responsavel por gravar o status e descricao do doc. " Nao Transmitido, falha de comunicacao."
				If Empty(cErro)
					cDesc := STR0001 // -- "Documento com Falha na Comunicação"
					MDFEStatus('5',aXML[1],aXML[2],'','',cDesc,'')
				Else
					cDesc := cErro
					MDFEStatus('5',aXML[1],aXML[2],'','',cDesc,'')
				EndIf
				lRet:= .F.
			EndIf	
		Else
			FwAlertHelp("RdMke não compilado", "Compile o rdmake MdfeGTP3 para prosseguir",)
		EndIf
	EndIf

	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} XMLRemMDF
//TODO Descrição auto-gerada.
@author osmar.junior
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oWs, object, descricao
@param cErro, characters, descricao
@param cSerie, characters, descricao
@param cNumDoc, characters, descricao
@param cIdEnt, characters, descricao
@param cURL, characters, descricao
@type function
/*/
Static Function XMLRemMDF(oWs,cErro,cSerie,cNumDoc,cIdEnt,cURL)
	Local lRetorno := .T.
	Local cXml := oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cXML

	If oWs:Remessa()
		If Len(oWs:oWsRemessaResult:oWSID:cString) == 0
			
			ValidaSchema(cURL,cIdEnt,cSerie+cNumDoc,cXml)

			cErro := STR0002+CRLF+CRLF //"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
			lRetorno := .F.
		ElseIf aScan(oWs:oWsRemessaResult:oWSID:cString,cSerie+cNumDoc)==0
			cErro += "MDFe: "+cSerie+cNumDoc+CRLF
			lRetorno := .F.
		EndIf
		
		

		oWs:Reset()	
		
	Else
		cErro := GetWscError(3)
		DEFAULT cErro := STR0003 //"Erro indeterminado"
		lRetorno := .F.
	EndIf

Return lRetorno


/*/{Protheus.doc} WsMDFeGTP
//TODO Descrição auto-gerada.
@author osmar.junior
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cIdent, characters, descricao
@param cSerie, characters, descricao
@param cMdfMin, characters, descricao
@param cMdfMax, characters, descricao
@type function
/*/
Function WsMDFeGTP(cIdent, cSerie, cMdfMin, cMdfMax)

	Local aAreaDTX := DTX->(GetArea())
	Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local lOk      := .T.
	Local oWS
	Local oRetorno
	Local nTamserie := TamSx3("DT6_SERIE")[1]
	Local nTamanif  := TamSx3("DTX_MANIFE")[1]
	Local cNrSerie := ''
	Local cNrManif := ''
	Local dMDFeEmis:= CtoD("")
	Local cSitMDF  := ''
	Local cNrProt  := ''
	Local cModelo  := '58'
	Local aListBox := {}
	Local aListBox2 := {}
	Local aMsg     := {}
	Local aXML     := {}
	Local nAmbien  := 0
	Local nX       := 0
	Local nY       := 0
	Local nZ       := 0
	Local nRange   := Val(cMdfMax) - Val(cMdfMin)
	Local nLastXml := 0
	
	Local oOk      := LoadBitMap(GetResources(), "ENABLE")
	Local oNo      := LoadBitMap(GetResources(), "DISABLE")
	Local nTamRet  := TamSx3("DTX_RTIMDF")[1] 
	
	Private oXml
		
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN    := "TOTVS"
	oWS:cID_ENT       := cIdEnt
	oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"	
	oWS:cIdInicial    := cSerie + cMdfMin
	oWS:cIdFinal      := cSerie + cMdfMax
	oWS:cModelo       := cModelo
	lOk := oWS:MONITORFAIXA()
	oRetorno := oWS:oWsMonitorFaixaResult

	For nX := 1 To Len(oRetorno:oWSMONITORNFE)
		
		aMsg := {}
		oXml := oRetorno:oWSMONITORNFE[nX]
		If Type("oXml:OWSERRO:OWSLOTENFE")<>"U"
			nLastRet := Len(oXml:OWSERRO:OWSLOTENFE)
			For nY := 1 To Len(	oXml:OWSERRO:OWSLOTENFE)
				If oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE<>0
					aadd(aMsg,{oXml:OWSERRO:OWSLOTENFE[nY]:NLOTE,oXml:OWSERRO:OWSLOTENFE[nY]:DDATALOTE,oXml:OWSERRO:OWSLOTENFE[nY]:CHORALOTE,;
						oXml:OWSERRO:OWSLOTENFE[nY]:NRECIBOSEFAZ,;
						oXml:OWSERRO:OWSLOTENFE[nY]:CCODENVLOTE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGENVLOTE,50),;
						oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETRECIBO,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETRECIBO,50),;
						oXml:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE,PadR(oXml:OWSERRO:OWSLOTENFE[nY]:CMSGRETNFE,5000)})
				EndIf
			Next nY
			If oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE=='100'
				MDFEStatus('2','','','',oXml:OWSERRO:OWSLOTENFE[nLastRet]:CCODRETNFE, '',ALLTRIM(STR(oXml:OWSERRO:OWSLOTENFE[nLastRet]:NRECIBOSEFAZ)))
			EndIF
		EndIf
	

		If Len(AllTrim(cMdfMin)) < 9
	   		nY       := Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)
			cNrSerie := Substr(oRetorno:OWSMONITORNFE[nX]:CID,Len(oRetorno:OWSMONITORNFE[nX]:CID)- (nTamserie+Len(AllTrim(cMdfMin))-1),(nTamserie))
			cNrManif := SubStr(oRetorno:OWSMONITORNFE[nX]:CID,Len(oRetorno:OWSMONITORNFE[nX]:CID)- (Len(AllTrim(cMdfMin))-1))
		Else
			nY       := Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)
	   		cNrSerie := Substr(oRetorno:OWSMONITORNFE[nX]:CID,Len(oRetorno:OWSMONITORNFE[nX]:CID)- (nTamserie+nTamanif-1),(nTamserie))
	   		cNrManif := SubStr(oRetorno:OWSMONITORNFE[nX]:CID,Len(oRetorno:OWSMONITORNFE[nX]:CID)- (nTamanif-1))
		EndIf

/*
	100 Autorizado o uso do MDF-e
	101 Cancelamento de MDF-e homologado
	103 Arquivo recebido com sucesso
	104 Arquivo processado
	105 Arquivo em processamento
	106 Arquivo não localizado
	107 Serviço em Operação
	108 Serviço Paralisado Momentaneamente (curto prazo)
	109 Serviço Paralisado sem Previsão
	111 Consulta cadastro com uma ocorrência
	112 Consulta cadastro com mais de uma ocorrência
	132 Encerramento de MDF-e homologado
	135 Evento registrado e vinculado a MDF-e
	136 Evento registrado, mas não vinculado a MDF-e

		0 - Nao Transmitido
		1 - MDF-e Aguardando
		2 - MDF-e Autorizado
		3 - MDF-e Nao Autorizado
		4 - MDF-e em Contingencia
		5 - MDF-e com Falha na Comunicacao

*/			
		If (!Empty(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO))		//-- Mensagem do TSS.
			cSitMDF := oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[nY]:CCODRETNFE
			cCodRet := Substr(oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO,1,3)
			cNrProt := oRetorno:OWSMONITORNFE[nX]:CPROTOCOLO
			nAmbien := oRetorno:OWSMONITORNFE[nX]:NAMBIENTE
			cRecome := oRetorno:OWSMONITORNFE[nX]:CRECOMENDACAO
			cMsgRet := SubStr(	oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CCODRETNFE;
								+ " - " + ;
								oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE,1,nTamRet )
			//--> Atualizar status dos manifestos
			dMDFeEmis:= oRetorno:OWSMONITORNFE[nx]:owserro:owslotenfe[Len(oRetorno:OWSMONITORNFE[nX]:OWSERRO:OWSLOTENFE)]:DDATALOTE
			If SubStr(cRecome,1,3) <> '001' //"001 - Emissão de DAMDFE autorizada"
				MDFEStatus('3','','',cMsgRet,cCodRet,cRecome,cNrProt)
			EndIf 

		EndIf			
	
	Next nX		

	RestArea(aAreaDTX)

Return

/*/{Protheus.doc} TZoneUTC
//TODO Descrição auto-gerada.
@author osmar.junior
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cIdEnt, characters, descricao
@type function
/*/
Static Function TZoneUTC(cIdEnt)
Local cError	:= ""
Local cRet 	:= ""

	If !Empty(cIdEnt)
		cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		oWS :=  WsSpedCfgNFe():New()
		oWS:cUSERTOKEN      := "TOTVS"
		oWS:cID_ENT         := cIdEnt
		oWS:nAmbienteMDFE   := 0
		oWS:cVersaoMDFE     := "0.00"
		oWS:nModalidadeMDFE := 0
		oWS:cVERMDFELAYOUT  := "0.00"
		oWS:cVERMDFELAYEVEN := "0.00"
		oWS:nSEQLOTEMDFE    := 0
		oWS:cHORAVERAOMDFE  := '0'
		oWS:cHORARIOMDFE    := '0'
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cModelo         := '58'
		oWS:CFGMDFE()

		If Empty(cError) .And. Valtype(oWS:OWSCFGMDFERESULT:CHORAVERAOMDFE) <> "U"
			If Left(oWS:OWSCFGMDFERESULT:CHORAVERAOMDFE,1) == "1"				//Horario de Verao -> 1-Sim ### 2-Nao
				If Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "1"		//Fernando de Noronha
					cRet := "-01:00"
				ElseIf Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "2"	//Brasilia
					cRet := "-02:00"
				ElseIf	Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "4"	//Acre
					cRet := "-04:00"
				Else
					cRet := "-03:00"						//Manaus
				Endif
			Else
				If Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "1"		//Fernando de Noronha
					cRet := "-02:00"
				ElseIf Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "2"	//Brasilia
					cRet := "-03:00"
				ElseIf	Substr(oWS:OWSCFGMDFERESULT:CHORARIOMDFE, 1, 1) == "4"	//Acre
					cRet := "-05:00"
				Else
					cRet := "-04:00"						//Manaus
				Endif
			Endif
		EndIf
	EndIf

Return( cRet )



/*/{Protheus.doc} MDFEStatus
//TODO Descrição auto-gerada.
@author osmar.junior
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cStatus, characters, descricao
@param cCHVMDF, characters, descricao
@param cXMLENV, characters, descricao
@param cXMLRET, characters, descricao
@param cCODREF, characters, descricao
@param cMOTREJ, characters, descricao
@param cPROTOC, characters, descricao
@type function
/*/
Function MDFEStatus(cStatus,cCHVMDF,cXMLENV,cXMLRET,cCODREF,cMOTREJ,cPROTOC)

	Default cStatus := ''
	Default cCHVMDF := ''
	Default cXMLENV := ''
	Default cXMLRET := ''
	Default cCODREF := ''
	Default cMOTREJ := ''
	Default cPROTOC := ''

	If GI9->GI9_STATRA <> '2'
		RecLock("GI9", .F.)	
		IIf( !Empty(cStatus),	GI9->GI9_STATRA := cStatus , )
		IIf( !Empty(cCHVMDF),	GI9->GI9_CHVMDF := cCHVMDF , )
		IIf( !Empty(cXMLENV),	GI9->GI9_XMLENV := cXMLENV , )
		IIf( !Empty(cXMLRET) .OR. cStatus=='2',	GI9->GI9_XMLRET := cXMLRET , )
		IIf( !Empty(cCODREF),	GI9->GI9_CODREF := cCODREF , )
		IIf( !Empty(cMOTREJ) .OR. cStatus=='2',	GI9->GI9_MOTREJ := cMOTREJ , )
		IIf( !Empty(cPROTOC),	GI9->GI9_PROTOC := cPROTOC , )
		MSUnlock()  
	EndIf
	
	/*
	"0= Não Transmitido"
	"1= Aguardando"
	"2= Autorizado"
	"3= Nao Autorizado"
	"4= em Contingencia"
	"5= com Falha na Comunicacao"	                                                                                                               
	*/

Return 



/*/{Protheus.doc} GTPATUMDF
//TODO Descrição auto-gerada.
@author osmar.junior
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GTPATUMDF()

	Local cTmpAlias := GetNextAlias() 
	Local cIdEnt := RetIdEnti(.F.)

	If !Empty(cIdEnt)
		BeginSql Alias cTmpAlias
		    SELECT GI9_CODIGO ,GI9_SERIE SERIE,GI9_NUMERO DOC
		    FROM %Table:GI9% GI9
		    WHERE 
		    GI9.GI9_STATRA IN ('0','1','3','5') AND
		    GI9.GI9_FILIAL = %xFilial:GI9% AND
		    GI9.%NotDel%   
		EndSql
	
		If (cTmpAlias)->(!Eof())
			While (cTmpAlias)->(!Eof())	
				dbSelectArea("GI9")
				dbSetOrder(1)	//GI9_FILIAL+GI9_CODIGO+GI9_SERIE+GI9_NUMERO 
				If dbSeek(xFilial('GI9')+(cTmpAlias)->GI9_CODIGO+(cTmpAlias)->SERIE+(cTmpAlias)->DOC)		
					WsMDFeGTP(cIdent, (cTmpAlias)->SERIE, (cTmpAlias)->DOC, (cTmpAlias)->DOC)
				Endif 				 
				(cTmpAlias)->(dbSkip())
			End	
		Endif
	Endif
		
return .T.

/*/{Protheus.doc} GTPJMDFE
//TODO Descrição auto-gerada.
@author osmar.junior
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param aParam, array, descricao
@type function
/*/
Function GTPJMDFE(aParam)

	Local lJob			:= Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
	Local cFilOk 		:= ""
	//---Inicio Ambiente

	If lJob // Schedule
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] MODULO "GTP"
	EndIf   

	cFilOk := cfilant

	GTPATUMDF()	

	cFilAnt	:= cFilOk

Return




//------------------------------------------------------------------------------
/* /{Protheus.doc} ValidaSchema

@type Static Function
@author jacomo.fernandes
@since 26/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ValidaSchema(cURL,cIdEnt,cID,cMsg)
Local oWs	:= Nil

If !Empty(cMsg) 
	oWS:= WSNFeSBRA():New()
	oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:cUSERTOKEN     := "TOTVS"
	oWS:cID_ENT        := cIdEnt
	oWs:oWsNFe:oWSNOTAS:=  NFeSBRA_ARRAYOFNFeS():New()
	aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())
	oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cID := cID
	oWs:oWsNFe:oWSNOTAS:oWsNFes[1]:cXML:= EncodeUtf8(cMsg)
	
	If oWS:Schema()
		If Empty(oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM)
			Aviso("SPED","schema valido")
		Else
			If Len(oWS:oWSSCHEMARESULT:oWSNFES4[1]:oWsSchemaMsg:oWsSchemaError) > 0 .and.; 
				( MsgYesNo("Schema com erro. Deseja visualizar as possibilidades que podem ter causado o erro?"))
				ViewSchemaMsg( oWS:oWSSCHEMARESULT:oWSNFES4[1]:oWsSchemaMsg:oWsSchemaError )
			Else
				Aviso("SPED",oWS:oWSSCHEMARESULT:oWSNFES4[1]:cMENSAGEM,{"Ok"},3)								
			EndIf
		EndIf
	EndIf
EndIf
Return 


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
	
	Local lIsSame	:= .F.
	
	Local nX
	
	DEFINE MSDIALOG oDlg TITLE "Mensagens de Schema X Possibilidades" FROM 0,0 TO 300,500 PIXEL  //"Mensagens de Schema X Possibilidades"
	
	@ 000, 000 MSPANEL oPanelLeft OF oDlg SIZE 085, 000
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ 000, 000 MSPANEL oPanelRight OF oDlg SIZE 000, 000
	oPanelRight:Align := CONTROL_ALIGN_ALLCLIENT
	
	oTree := xTree():New(000,000,000,000,oPanelLeft,,,)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
	
	oTree:AddTree("Mensagens",,,"PARENT",,,) //"Mensagens"
	
	For nX := 1 to len(aMessages)
	
		cCargo := aMessages[nX]:cTag
	
		oMessage := aMessages[nX]
	
		If ( oTree:TreeSeek(cCargo) )
			oTree:addTreeItem("Possibilidade","BPMSEDT3.png",cCargo+"|"+AllTrim(Str(nX)),{ || SchemaRefreshTree( @cTag, @cDesc, @cHierarquia, @cDica, @cErro, aMessages, oTree ), oTag:Refresh(), oDesc:Refresh(), oHierarquia:Refresh(), oDica:Refresh(), oErro:Refresh() }) //
		Else
			If ( nX > 1 )
				oTree:EndTree()
			EndIf
	
			oTree:AddTree(cCargo,"f10_verm.png","f10_verm.png",cCargo,,,,,)
			oTree:addTreeItem("Possibilidade","BPMSEDT3.png",cCargo+"|"+AllTrim(Str(nX)),{ || SchemaRefreshTree( @cTag, @cDesc, @cHierarquia, @cDica, @cErro, aMessages, oTree ), oTag:Refresh(), oDesc:Refresh(), oHierarquia:Refresh(), oDica:Refresh(), oErro:Refresh() }) 	//
		EndIf
	
	Next nX
	
	oTree:EndTree()
	
	DEFINE FONT oFont BOLD
	
	@ 005, 010 SAY oSay PROMPT "Tag:" OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //
	@ 005, 024 SAY oTag PROMPT cTag OF oPanelRight PIXEL SIZE 040, 015
	
	@ 020, 010 SAY oSay PROMPT 'Descrição'+":" OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //
	@ 020, 042 SAY oDesc PROMPT cDesc OF oPanelRight PIXEL SIZE 110, 015
	
	@ 035, 010 SAY oSay PROMPT "Hierarquia:" OF oPanelRight PIXEL FONT oFont SIZE 040, 015   //"Hierarquia:"
	@ 035, 043 SAY oHierarquia PROMPT cHierarquia OF oPanelRight PIXEL SIZE 150, 015
	
	@ 050, 010 SAY oSay PROMPT "Dica:" OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Dica:"
	@ 050, 026 SAY oDica PROMPT cDica OF oPanelRight PIXEL SIZE 150, 015
	
	@ 065, 010 SAY oSay PROMPT "Erro Técnico:" OF oPanelRight PIXEL FONT oFont SIZE 040, 015 //"Erro Técnico:"
	@ 065, 050 SAY oErro PROMPT cErro OF oPanelRight PIXEL SIZE 100, 055
	
	@ 133, 097 BUTTON oBtn PROMPT "Gerar Log" SIZE 030, 010 ACTION CreateLog( aMessages ) OF oPanelRight PIXEL //"Gerar Log"
	@ 133, 130 BUTTON oBtn PROMPT "Sair" SIZE 028, 010 ACTION oDlg:end() OF oPanelRight PIXEL //"Sair"
	
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

Local cDir		:= cGetFile( "*.xml", "Arquivo"+" XML", 1, "C:\", .T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),, .T. )
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
	

/*/
 * {Protheus.doc} SetDtHr()
 * Busca data e hora do sistema para envio
 * type    Static Function
 * author  Eduardo Ferreira
 * since   28/11/2019
 * version 12.25
 * param   Não há
 * return  Não há
/*/
Static Function SetDtHr()

RecLock('GI9', .F.)
	GI9->GI9_EMISSA := Date()
	GI9->GI9_HORAEM := Left(Time(), 5)
GI9->(MsUnLock())

Return 
