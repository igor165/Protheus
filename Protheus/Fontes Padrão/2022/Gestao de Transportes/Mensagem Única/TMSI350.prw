#INCLUDE "PROTHEUS.CH"                
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TMSI350.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSI350
Função de envio de apontamento de chegada em Filial.

@class
@author	Paulo Henrique Corrêa Cardoso	
@version	1.0
@since		26/11/2015
@return	{lRet, cXMLRet}
@Param		cXML, nTypeTrans: Tipo de transação Envio-Recebimento, cTypeMessa: 	Tipo da mensagem.
@sample

/*/
//-------------------------------------------------------------------
Function TMSI350(cXML, nTypeTrans, cTypeMessa)

Local lRet     		:= .T.			// Recebe o Retorno
Local cXMLRet  		:= ""			// Recebe o XML de Retorno
Local cError		:= ""			// Recebe o Erro
Local cWarning 		:= ""			// Recebe o Aviso
Local cEvent		:= "upsert"		// Recebe o Evento
Local aArea			:= GetArea()	// Recebe a Area ativa
Local aAreaDUD		:= DUD->(GetArea())
Local cInternalId	:= DTW->DTW_FILIAL + "|" + DTW->DTW_FILORI + "|" + DTW->DTW_VIAGEM + "|" + DTW->DTW_SEQUEN + "|" + DTW->DTW_ATIVID
Local cAliasQry 	:= ''
Local cQuery 		:= ''
If Type("lA350IntEs") == "U"
	Private lA350IntEs := .F.
EndIf

If nTypeTrans == TRANS_SEND
	
	// Estorno
	If IsInCallStack("TmsA350Est") .OR. lA350IntEs
		cEvent := "delete"
	EndIf
		
	// Monta o XML
	cXMLRet 	:= "<BusinessEvent>"
	cXMLRet 	+=     "<Entity>POINTOPERATIONS</Entity>" 
	cXMLRet 	+=     "<Event>" + cEvent + "</Event>"
	cXMLRet 	+=     "<Identification>"
	cXMLRet		+=          "<key name='InternalId'>" + cInternalId + "</key>"
	 cXMLRet 	+=     "</Identification>"
	cXMLRet 	+= "</BusinessEvent>"

	cXMLRet += "<BusinessContent>"

	cXMLRet +=      "<CompanyId>"          + cEmpAnt     + "</CompanyId>"
	cXMLRet +=      "<BranchId>"           + cFilAnt     + "</BranchId>"
	cXMLRet +=      "<CompanyInternalId>"  + cInternalId + "</CompanyInternalId>"

	cXMLRet +=		"<BranchOfOrigin>" 	 + 	DTW->DTW_FILORI 	 + "</BranchOfOrigin>"
	cXMLRet += 		"<NumberOfTrip>" 	 +	DTW->DTW_VIAGEM		 + "</NumberOfTrip>"
	cXMLRet += 		"<Sequence>" 		 + 	DTW->DTW_SEQUEN 	 + "</Sequence>"
	cXMLRet += 		"<TypeOfTrip>" 		 + 	DTW->DTW_SERTMS		 + "</TypeOfTrip>"
	cXMLRet +=		"<CurrentBranch>" 	 + 	cFilAnt				 + "</CurrentBranch>"
	cXMLRet += 		"<Activity>" 		 + 	DTW->DTW_ATIVID		 + "</Activity>"
	cXMLRet += 		"<StartDate>" 		 + 	DTOS(DTW->DTW_DATINI)+ "-" +  Left(DTW->DTW_HORINI,2) + ":" + Right(DTW->DTW_HORINI,2)  + "</StartDate>"
	cXMLRet += 		"<AccomplishedDate>" + 	DTOS(DTW->DTW_DATREA)+ "-" +  Left(DTW->DTW_HORREA,2) + ":" + Right(DTW->DTW_HORREA,2)  + "</AccomplishedDate>"
	cXMLRet += 		"<ListOfTransportDocuments>"
	cAliasQry 	:= GetNextAlias()
	cQuery 		:= " SELECT DUD.DUD_FILIAL, DUD.DUD_FILORI, DUD.DUD_VIAGEM, DUD.DUD_FILDOC, DUD.DUD_DOC, DUD.DUD_SERIE, DT6.DT6_CHVCTE, DT6.DT6_DOCTMS "
	cQuery 		+= " 	FROM " + RetSqlName("DUD") + " DUD 	"
	cQuery 		+= "	INNER JOIN	" + RetSqlName("DT6") + " DT6 	"
	cQuery 		+= "		ON 	DT6.DT6_FILIAL 	= '" + FwxFilial('DT6') + "' "
	cQuery 		+= "		AND	DUD.DUD_FILDOC 	= DT6.DT6_FILDOC 	"
	cQuery 		+= "		AND DUD.DUD_DOC 	= DT6.DT6_DOC 		"
	cQuery 		+= " 		AND DUD.DUD_SERIE 	= DT6.DT6_SERIE		"
	cQuery 		+= " 		AND DT6.D_E_L_E_T_ = ' ' "
	cQuery 		+= " 	WHERE 	DUD.DUD_FILIAL  	= '" + FwxFilial('DUD') + "' "
	cQuery 		+= " 	AND 	DUD.DUD_FILORI  	= '" + DTW->DTW_FILORI 	+ "' "
	cQuery 		+= " 	AND 	DUD.DUD_VIAGEM  	= '" + DTW->DTW_VIAGEM 	+ "' "
	cQuery 		+= "   	AND 	DUD.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)	
	
	While (cAliasQry)->(!Eof())
		cXmlRet += "<TransportDocument>"
		cXmlRet += 		"<BranchDocument>" 				+ AllTrim((cAliasQry)->DUD_FILDOC) 					+ "</BranchDocument>"
		cXmlRet += 		"<BranchDocumentInternalId>" 	+ cEmpAnt + "|" + (cAliasQry)->DUD_FILDOC 			+ "</BranchDocumentInternalId>"			
		cXmlRet += 		"<DocumentNumber>" 				+ AllTrim((cAliasQry)->DUD_DOC)    					+ "</DocumentNumber>"
		cXmlRet += 		"<DocumentSeries>" 				+ AllTrim((cAliasQry)->DUD_SERIE)  					+ "</DocumentSeries>"
		cXmlRet += 		"<DocumentType>"   				+ AllTrim((cAliasQry)->DT6_DOCTMS) 					+ "</DocumentType>"
		cXmlRet += "</TransportDocument>"
		(cAliasQry)->(DbSkip())
	EndDo	
	cXmlRet += "</ListOfTransportDocuments>"		
	(cAliasQry)->(DbCloseArea())

	
	cXMLRet += "</BusinessContent>"

	

ElseIf nTypeTrans == TRANS_RECEIVE
            
	If cTypeMessage == EAI_MESSAGE_BUSINESS
   	
		// Efetua Parser Do XML
		oXmlDlg := XmlParser(cXml, "_", @cError, @cWarning)

		// Verifica Se o Objeto Está Vazio ou Se Existem Erros Ou Avisos
		If oXmlDlg <> Nil .And. Empty(cError) .And. Empty(cWarning)
			cXmlRet := "OK"
			lRet := .T.
		Else
			lRet := .T.
			cXmlRet := STR0001 //"ERRO - Xml vazio ou com erro"
		EndIf	
		       
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		
		// Efetua Parser Do XML
		oXmlDlg := XmlParser( cXml, '_', @cError, @cWarning )
		
		// Verifica Se o Objeto Está Vazio ou Se Existem Erros Ou Avisos
		If oXmlDlg <> Nil .And. Empty(cError) .And. Empty(cWarning)
			oXmlDlg := oXmlDlg:_TotvsMessage
		
				
			// Retorna Um Ou Mais Nós Da Estrutura - Verifica Se a Inclusão Pelo Parceiro Ocorreu Com Sucesso
			If XmlChildEx( oXmlDlg:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .AND. ;
				Upper(oXmlDlg:_ResponseMessage:_ProcessingInformation:_Status:Text)== 'OK'
				cXmlRet := STR0002 //"Processamento OK"
				lRet:= .T.
			
				
			// Caso Seja Retorno De Erro
			Else
				
				cXmlRet := STR0003 // "ERRO EAI - Status vazio ou com erro."
				//Help("",1,"TMSIfILIAL001",, STR0003 + STR0004 ,1,0)  // "ERRO EAI - Status vazio ou com erro." ### "O Apontamento de operações não será cadastrado no Sistema."
				lRet := .F.
						
				// Transforma Estrutura Das Mensagens De Erro Em Array Para Concatenar Com Mensagem
				If XmlChildEx( oXmlDlg:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil .And. ;
					ValType(oXmlDlg:_ResponseMessage:_ProcessingInformation:_ListOfMessages)<>'A' // Verifica se é <> de array
					XmlNode2Arr(oXmlDlg:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_LISTOFMESSAGES") // Transforma em array
				EndIf
								
			EndIf
		// Caso Objeto Esteja Vazio E Tenha Erro
		Else
			lRet    := .T.
			cXmlRet := STR0005 + cWarning + ' | ' + cError //"AVISO|ERRO -"
			//Help("",1,"TMSAI020002",,   STR0005 + cWarning + ' | ' + cError + STR0004 ,1,0) //"AVISO|ERRO -" ### "O Apontamento de operações não será cadastrado no Sistema."
			
		EndIf

	// Retorno De Teste De Intergração EAI
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS 
		cXMLRet := '1.000'
	EndIf
	           
EndIf    
    
// Converte String De Origem CP1252(Windows 1252) Para UTF-8 (8-bit Unicode Transf Format)
cXMLRet := EncodeUTF8( cXMLRet )

RestArea(aArea)
RestArea(aAreaDUD)

Return {lRet, cXMLRet}
