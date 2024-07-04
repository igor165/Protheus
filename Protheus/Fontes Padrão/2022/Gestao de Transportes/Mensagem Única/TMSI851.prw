#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TMSI851.CH"

#DEFINE DTMS851ROT "TMSA851"
#DEFINE DTMS851MSG "TRANSPORTINVOICE"
#DEFINE DTMS851VER "1.000|1.001|2.000|2.001"

/*/{Protheus.doc} Tmsi851
Adapter de Integração SIGATMS x Contas a Receber. 
 Mensagem Única: TransportInvoice.
 Preparado e habilitado apenas para o método Síncrono. 
 Validação realizada na função IntegDef do TMSA851.
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cXml], Caracter, XML recebido pelo EAI Protheus
@param [cType], Caracter, Tipo de transação
@param [cTypeMessage], Caracter, Tipo da mensagem do EAI
@param [cVersion], Caracter, Versão da Mensagem Única TOTVS
@param [cTransaction], Caracter, Nome da mensagem iniciada no adapter
@return Array Informações de retorno
@obs Informações de retorno:
@obs Array[1] - Processamento foi executado com sucesso (.T.) ou não (.F.)
@obs Array[2] - Uma string contendo informações sobre o processamento
@obs Array[3] - Uma string com o nome da mensagem única desta mensagem
/*/
Function Tmsi851(cXml, cType, cTypeMessage, cVersion, cTransaction)

	Local aArea      := GetArea()
	Local aRet       := {} //-- Array de retorno
	Local aMessages  := {} //-- Mensagens de erros do processamento
	Local aVersion   := {} //-- Versoes suportadas pelo Adapter
	Local aLisMsg    := {} //-- Lista de Erros (ListOfMessages)
	Local aLisInt    := {} //-- Lista de InternalId (ListOfInternalId)
	Local aSepFat    := {} //-- Array com InternalId separado pelo |
	Local cErroXml   := "" //-- Erro no parser do XML
	Local cWarnXml   := "" //-- Alerta no parser do XML
	Local cEntity    := "" //-- Transacao da msg de resposta
	Local cProduct   := "" //-- Produto que enviou a resposta
	Local cDRTValInt := "" //-- InternalId da fatura
	Local cEvent     := "" //-- Evento da mensagem
	Local cXmlRet    := "" //-- XML de retorno
	Local cFilFat    := "" //-- Filial da fatura (InternalId)
	Local cNumFat    := "" //-- Numero da fatura (InternalId)
	Local cOrigFat   := "" //-- Origin (InternalId)
	Local cDestFat   := "" //-- Destination (InternalId)
	Local cUUID      := "" //-- UUID da mensagem
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local cDtTrans   := "" //-- Data de transacao
	Local cHisTit    := "" //-- Montagem chave do titulo para historico
	Local cHistor    := "" //-- Historico da fatura
	Local cDtsEst    := "" //-- Retorno datasul -> Estabelecimento
	Local cDtsEsp    := "" //-- Retorno datasul -> Especie
	Local cDtsSer    := "" //-- Retorno datasul -> Serie
	Local cDtsTit    := "" //-- Retorno datasul -> Titulo
	Local cDtsPar    := "" //-- Retorno datasul -> Parcela
	Local cDtsCob    := "" //-- Retorno datasul -> Tipo cobranca
	Local cDtsBan    := "" //-- Retorno datasul -> Banco
	Local cDtsAge    := "" //-- Retorno datasul -> Agencia
	Local cDtsCta    := "" //-- Retorno datasul -> Conta corrente
	Local nDtsVal    := 0  //-- Retorno datasul -> Valor do titulo
	Local nDtsJur    := 0  //-- Retorno datasul -> Juros por dia de atraso
	Local nDtsDes    := 0  //-- Retorno datasul -> Valor de desconto
	Local nCount     := 0
	Local dDtsVen    := Nil //-- Retorno datasul -> Data de vencimento
	Local dDtsLim    := Nil //-- Retorno datasul -> Data limine para desconto
	Local lVersVal   := .F. //-- Versao valida
	Local oXml
	Local oXmlOrig

	//-- Informacoes de retorno
	Aadd(aRet, .T.)
	Aadd(aRet, "")
	Aadd(aRet, DTMS851MSG)
	
	//-- Recupera versao do cabecalho da mensagem e efetua algumas validacoes
	If cType == TRANS_RECEIVE  .And.;//-- Recebimento
	  (cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE)

		cVersion := "" //-- Ignora versao do adapter para recuperar versao do cabecalho da mensagem
		oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

		If oXml != Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)

			If XmlChildEx(oXml:_TOTVSMessage, '_MESSAGEINFORMATION' ) != Nil
				If XmlChildEx(oXml:_TOTVSMessage:_MessageInformation, '_VERSION' ) != Nil
					cVersion := oXml:_TOTVSMessage:_MessageInformation:_version:Text
				ElseIf XmlChildEx(oXml:_TOTVSMessage:_MessageInformation, '_STANDARDVERSION' ) != Nil
					cVersion := oXml:_TOTVSMessage:_MessageInformation:_StandardVersion:Text
				EndIf
				
				//-- Entidade/Transacao deve ser valida
				If XmlChildEx(oXml:_TOTVSMessage:_MessageInformation, '_TRANSACTION' ) != Nil .And.;
				   !Empty(oXml:_TOTVSMessage:_MessageInformation:_Transaction:Text)
					cEntity := oXml:_TOTVSMessage:_MessageInformation:_Transaction:Text
				Else
					aRet[1] := .F.
					//-- "Erro no retorno. Entidade/Transacao nao informada ou invalida!"
					Aadd(aMessages, {STR0006, 1, "TMSI851004"})
				EndIf
				
				//-- Verifica se a marca foi informada
				If XmlChildEx(oXml:_TOTVSMessage:_MessageInformation, '_PRODUCT' )       != Nil .And.;
				   XmlChildEx(oXml:_TOTVSMessage:_MessageInformation:_Product, '_NAME' ) != Nil .And.;
				   !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					aRet[1] := .F.
					//-- "Erro no retorno. O elemento Product eh obrigatorio!"
					Aadd(aMessages, {STR0005, 1, "TMSI851005"})
				EndIf
			EndIf
			
			If Empty(cVersion)
				aRet[1] := .F.
				//-- "Versao da mensagem nao informada!"
				Aadd(aMessages, {STR0001, 1, "TMSI852002"})
			EndIf
			
			If cTypeMessage == EAI_MESSAGE_RESPONSE
			
				//-- Recupera o evento
				If XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
				   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_RECEIVEDMESSAGE' ) != Nil .And.;
				   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage, '_EVENT' ) != Nil .And.;
				   !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text)
					cEvent := Upper(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text)
				EndIf
				
				//-- Verifica se o UUID da mensagem origem foi informado (Enquanto o Datasul nao eh corrigido)
				If XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
				   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_RECEIVEDMESSAGE' ) != Nil .And.;
				   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage, '_UUID' ) != Nil .And.;
				   !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_UUID:Text)
					cUUID := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_UUID:Text
				Else
					aRet[1] := .F.
					//-- "Erro no retorno. O elemento UUID nao foi retornado!"
					Aadd(aMessages, {STR0010, 1, "TMSI851006"})
				EndIf
			EndIf
		Else
			aRet[1] := .F.
			//-- "Erro no parser do XML recebido!"
			Aadd(aMessages, {STR0002 + " [ERROR: " + cErroXml + ", WARNING: " + cWarnXml + "] ", 1, "TMSI851001"})
		EndIf
	EndIf
	
	If cTypeMessage != EAI_MESSAGE_WHOIS .And. ! Empty(cVersion)
		aVersion := Separa(DTMS851VER, "|")
		For nCount := 1 To Len(aVersion)
			//-- Compara apenas a versao, sem considerar release
			If AllTrim(StrTokArr(cVersion, ".")[1]) == AllTrim(StrTokArr(aVersion[nCount], ".")[1])
				lVersVal := .T. //-- Versao valida
				Exit
			EndIf
		Next nCount
		
		If ! lVersVal
			aRet[1] := .F.
			//-- "A versao da mensagem informada nao foi implementada!"
			Aadd(aMessages, {STR0003 + " (" + AllTrim(cVersion) + ")", 1, "TMSI851003"})
		EndIf
	EndIf
	
	If aRet[1] //-- Se nao houver erros ate o momento, processa a mensagem
	
		Do Case
		Case (cType == TRANS_RECEIVE) //-- Recebimento
		
			Do Case
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
				
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE)
			
				//-- Monta um array com base na TAG ListOfInternalId
				aLisInt := T851LisInt(oXml)
				
				//-- Tratamentos relacionados aos InternalIds recebidos
				For nCount := 1 To Len(aLisInt)
					Do Case
					Case (! Empty(aLisInt[nCount, 1]) .And.; 
					       (Upper(aLisInt[nCount, 1]) == "INTERNALID" .Or.;
					        Upper(aLisInt[nCount, 1]) == "TRANSPORTINVOICEINTERNALID"))
               		aSepFat := Separa(aLisInt[nCount, 2], "|")
						If ! Empty(aSepFat) .And. Len(aSepFat) >= 2
							cFilFat  := aSepFat[1]
							cNumFat  := aSepFat[2]
							cOrigFat := aLisInt[nCount, 2]
							cDestFat := aLisInt[nCount, 3]
						EndIf
					EndCase
				Next nCount

				//-- Recupera evento do XML origem (Enquanto o Datasul nao eh corrigido)
				If Empty(cEvent)

					oXmlOrig := T851GetMsg(cUUID)
					
					If XmlChildEx(oXmlOrig:_TOTVSMessage, '_BUSINESSMESSAGE' ) != Nil .And.;
					   XmlChildEx(oXmlOrig:_TOTVSMessage:_BusinessMessage, '_BUSINESSEVENT' ) != Nil .And.;
					   XmlChildEx(oXmlOrig:_TOTVSMessage:_BusinessMessage:_BusinessEvent, '_EVENT' ) != Nil
						cEvent := Upper(oXmlOrig:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
					EndIf
				EndIf
	
				//-- Mensagens no padrao ListOfMessages
				aLisMsg := T851LisMsg(oXml)
				
				//-- Se nao houve erros na resposta
				If XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
				   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_PROCESSINGINFORMATION' ) != Nil .And.;
				   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation, '_STATUS' ) != Nil .And.;
				   Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
	
					//-- Realiza a atualizacao do status da fatura para integrada e do historico com
					//-- as informacoes chaves dos titulos gerados no financeiro
					If Upper(cEntity) == DTMS851MSG .And. aRet[1]
	
						//-- Cria ou elimina de-para
						If ! Empty(cDestFat) .And. ! Empty(cOrigFat) .And. cEvent == "UPSERT"
							CFGA070Mnt(cProduct, "DRT", "DRT_NUM", cDestFat, cOrigFat, .F.)
						EndIf
	
						//-- Lista de titulos (AccountReceivableDocument) recebidos
						If cEvent == "UPSERT" .And.;
						   XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
						   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_RETURNCONTENT' ) != Nil .And.;
						   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent, '_LISTOFACCOUNTRECEIVABLEDOCUMENT' ) != Nil .And.;
						   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument, '_ACCOUNTRECEIVABLEDOCUMENT' ) != Nil
		
							//-- Se nao for array
							If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument) != "A"
								//-- Transforma em array
								XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument, "_AccountReceivableDocument")
							EndIf

							cHisTit := ""

							//-- Tratamentos relacionados aos titulos (AccountReceivableDocument) recebidos
							For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument)
								
								cDtsEst := ""
								cDtsEsp := ""
								cDtsSer := ""
								cDtsTit := ""
								cDtsPar := ""
								cDtsCob := ""
								cDtsBan := ""
								cDtsAge := ""
								cDtsCta := ""
								dDtsVen := Nil
								dDtsLim := Nil
								nDtsVal := 0
								nDtsJur := 0
								nDtsDes := 0

								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_BRANCHID' ) != Nil
									cDtsEst := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_BranchId:Text
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_DOCUMENTTYPECODE' ) != Nil
									cDtsEsp := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_DocumentTypeCode:Text
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_DOCUMENTPREFIX' ) != Nil
									cDtsSer := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_DocumentPrefix:Text
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_DOCUMENTNUMBER' ) != Nil
									cDtsTit := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_DocumentNumber:Text
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_DOCUMENTPARCEL' ) != Nil
									cDtsPar := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_DocumentParcel:Text
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_DUEDATE' ) != Nil
									dDtsVen := SToD(StrTran(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_DueDate:Text, "-", ""))
								EndIf	
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_REALVALUE' ) != Nil
									nDtsVal := Val(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_RealValue:Text)
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_HOLDERTYPE' ) != Nil
									cDtsCob := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_HolderType:Text
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_ASSESSMENTVALUE' ) != Nil
									nDtsJur := Val(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_AssessmentValue:Text)
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_DISCOUNTDATE' ) != Nil
									dDtsLim := SToD(StrTran(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_DiscountDate:Text, "-", ""))
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_DISCOUNTVALUE' ) != Nil
									nDtsDes := Val(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_DiscountValue:Text)
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_HOLDERCODE' ) != Nil
									cDtsBan := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_HolderCode:Text
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_AGENCYNUMBER' ) != Nil
									cDtsAge := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_AgencyNumber:Text
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_ACCOUNTNUMBER' ) != Nil
									cDtsCta := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_AccountNumber:Text
								EndIf
								
								If ! Empty(cHisTit)
									cHisTit += chr(10)
								EndIf
								
								cHisTit += cDtsEst + " , " + ;
								           cDtsEsp + " , " + ;
								           cDtsSer + " , " + ;
								           cDtsTit + " / " + ;
								           cDtsPar + " , "
								If ! Empty(dDtsVen) .And. ValType(dDtsVen) == "D"
									cHisTit += Dtoc(dDtsVen) + " , "
								EndIf
								If ! Empty(nDtsVal) .And. ValType(nDtsVal) == "N"
									cHisTit += Transform(nDtsVal, "@E 999,999,999.99")
								EndIf
	
							Next nCount
						EndIf
						
						//-- Atualizacao do status e historico da fatura quando o evento eh UPSERT
						If cEvent == "UPSERT"
							DbSelectArea("DRT")
							DRT->(dbSetOrder(1))
							If DRT->(MsSeek(Padr(cFilFat, Len(DRT_FILIAL)) + Padr(cNumFat, Len(DRT_NUM))))
								RecLock('DRT',.F.)
								DRT->DRT_STATUS := '1' //-- Fatura integrada
								DRT->DRT_DTVENC := dDtsVen
								DRT->DRT_TIPCOB := cDtsCob
								DRT->DRT_VALJUR := nDtsJur
								DRT->DRT_LIMDES := dDtsLim
								DRT->DRT_VALDES := nDtsDes
								DRT->DRT_BANCO  := cDtsBan
								DRT->DRT_AGENC  := cDtsAge
								DRT->DRT_CTACOR := cDtsCta
								cHistor := STR0008 + chr(10) + STR0011 + chr(10) + cHisTit //-- "Integracao realizada com sucesso!"
								MSMM(Iif(!Empty(DRT->DRT_CODHIS),DRT->DRT_CODHIS,),80,,cHistor,1,,,"DRT","DRT_CODHIS")
								DRT->(MsUnLock())
							EndIf
						ElseIf cEvent == "DELETE"
						
							cHistor := ""
							
							//-- Atualiza o historico com mensagens de informacao que podem ser
							//-- retornadas da integracao com o contas a receber
							If Len(aLisMsg) > 0
								For nCount := 1 To Len(aLisMsg)
									If aLisMsg[nCount, 2] == 3
										cHistor += aLisMsg[nCount, 1] + chr(10)
									EndIf
								Next nCount
								If ! Empty(cHistor)
									cHistor := chr(10) + STR0012 + cHistor
									RecLock('DRT',.F.)
									MSMM(Iif(!Empty(DRT->DRT_CODHIS),DRT->DRT_CODHIS,),80,,cHistor,1,,,"DRT","DRT_CODHIS")
									DRT->(MsUnLock())
								EndIf
							EndIf
						EndIf
					EndIf
				Else
				
					aRet[1] := .F.
					
					//-- Guarda na variavel um conteudo para ser atualizado o historico
					//-- quando houver tratamento para execucao assincrona
					cHistor := STR0007 //-- "Erro durante a integracao!"
					
					If Len(aLisMsg) <= 0
						//-- "Erros nao identificados, pois nao estao no padrao de retorno EAI!"
						Aadd(aMessages, {STR0004, 1, "TMSI851007"})
					Else
						For nCount := 1 To Len(aLisMsg)
							cHistor += chr(10) + aLisMsg[nCount, 1]
							Aadd(aMessages, aLisMsg[nCount])
						Next nCount
					EndIf
				EndIf
			
			Case (cTypeMessage == EAI_MESSAGE_RECEIPT)
			
			Case (cTypeMessage == EAI_MESSAGE_WHOIS)
				aRet[2] := DTMS851VER //-- Retorna as versoes validas
			EndCase
	
		Case (cType == TRANS_SEND) //-- Envio

			//-- InternalId da fatura de transporte
			cDRTValInt := T851CalInt(, DRT->DRT_NUM)
			
			//-- Data de transacao
			cDtTrans := Transform(dToS(dDataBase),"@R 9999-99-99")
			
			If !INCLUI .AND. !ALTERA
				cEvent := "DELETE"
				//-- Elimina de-para da fatura (Se houver erro eh feito o disarmTransaction)
				CFGA070Mnt(, "DRT", "DRT_NUM", , cDRTValInt, .T.)
			Else
				cEvent := "UPSERT"
			EndIf

			cXmlRet := FWEAIBusEvent(DTMS851MSG,;
			                         Iif(cEvent == "UPSERT", 3, 5),;
			                         { {"CompanyId"  , cEmpAnt},;
			                           {"BranchId"   , cFilAnt},;
			                           {"InvoiceCode", AllTrim(DRT->DRT_NUM)}})
			cXmlRet += "<BusinessContent>"
			cXmlRet +=     "<CompanyId>" + cEmpAnt + "</CompanyId>"
			cXmlRet +=     "<BranchId>" + cFilAnt + "</BranchId>"
			cXmlRet +=     "<BranchIdInternalId>" + cEmpAnt + "|" + cFilAnt + "</BranchIdInternalId>"
			cXmlRet +=     "<CompanyInternalId>" + cEmpAnt + "|" + cFilAnt + "</CompanyInternalId>"
			cXmlRet +=     "<InvoiceCode>" + AllTrim(DRT->DRT_NUM) + "</InvoiceCode>"
			cXmlRet +=     "<InternalId>" + cDRTValInt + "</InternalId>"
			cXmlRet +=     "<TransactionDate>" + cDtTrans + "</TransactionDate>"
			
			If cEvent == "UPSERT" //-- Somente para o evento de UPSERT
			
				cXmlRet += "<DebitBranch>" + AllTrim(DRT->DRT_FILDEB) + "</DebitBranch>"
				cXmlRet += "<DebitBranchInternalId>" + cEmpAnt + "|" + DRT->DRT_FILDEB + "</DebitBranchInternalId>"
				cXmlRet += "<CustomerCode>" + AllTrim(DRT->DRT_CLIFAT) + "</CustomerCode>"
				cXmlRet += "<CustomerInternalId>" + DRT->DRT_CLIFAT + "|" + DRT->DRT_LOJFAT + "</CustomerInternalId>"

				//-- GovernmentalInformation do cliente
				cXmlRet += T851GovCli(DRT->DRT_CLIFAT, DRT->DRT_LOJFAT)
				
				cXmlRet += "<InvoiceIssueDate>" + Transform(dToS(DRT->DRT_DTEMIS), "@R 9999-99-99") + "</InvoiceIssueDate>"
				If ! Empty(DRT->DRT_DTVENC)
					cXmlRet += "<InvoiceDueDate>" + Transform(dToS(DRT->DRT_DTVENC), "@R 9999-99-99") + "</InvoiceDueDate>"
				EndIf
				cXmlRet += "<InvoiceValue>" + cValToChar(DRT->DRT_VALOR) + "</InvoiceValue>"
				cXmlRet += "<CurrencyCode>" + cValToChar(DRT->DRT_MOEDA) + "</CurrencyCode>"
				cXmlRet += "<CurrencyInternalId>" + cFilAnt + "|" + cValToChar(DRT->DRT_MOEDA) + "</CurrencyInternalId>"

				//-- Conhecimentos da fatura
				cQuery := "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_DOCTMS " 
				cQuery += "  FROM " + RetSqlName("DT6")
				cQuery += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQuery += "   AND DT6_PREFIX = '" + Space(Len(DT6->DT6_PREFIX)) + "' "
				cQuery += "   AND DT6_NUM    = '" + DRT->DRT_NUM                + "' "
				cQuery += "   AND DT6_TIPO   = '" + Space(Len(DT6->DT6_TIPO))   + "' "
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
				If (cAliasQry)->(!Eof())
					cXmlRet += "<ListOfTransportDocuments>"
					While (cAliasQry)->(!Eof())
						cXmlRet += "<TransportDocument>"
						cXmlRet += "<BranchDocument>" + AllTrim((cAliasQry)->DT6_FILDOC) + "</BranchDocument>"
						cXmlRet += "<BranchDocumentInternalId>" + cEmpAnt + "|" + (cAliasQry)->DT6_FILDOC + "</BranchDocumentInternalId>"
						cXmlRet += "<DocumentNumber>" + AllTrim((cAliasQry)->DT6_DOC)    + "</DocumentNumber>"
						cXmlRet += "<DocumentSeries>" + AllTrim((cAliasQry)->DT6_SERIE)  + "</DocumentSeries>"
						cXmlRet += "<DocumentType>"   + AllTrim((cAliasQry)->DT6_DOCTMS) + "</DocumentType>"
						cXmlRet += "</TransportDocument>"
						(cAliasQry)->(DbSkip())
					EndDo
					cXmlRet += "</ListOfTransportDocuments>"
				EndIf
				(cAliasQry)->(DbCloseArea())

			Endif

			cXmlRet += "</BusinessContent>"
			aRet[2] := cXmlRet
			
		EndCase
	EndIf

	//-- Se gerar mensagens de erro, adiciona ao retorno
	If Len(aMessages) >= 1
		aRet[2] += FWEAILOfMessages(aMessages)
	EndIf

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T851CalInt
Monta o InternalId da fatura
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cFilFat], Caracter, Filial
@param [cNumFat], Caracter, Número da Fatura
@return cRetCode "Filial | Nr Fatura"
/*/
//-------------------------------------------------------------------------------------------------
Function T851CalInt(cFilFat, cNumFat)

	Local cRetCode := ""
	Local cFilX    := ""
	
	Default cFilFat := cFilAnt
	Default cNumFat := ""

	cFilX    := xFilial("DRT", cFilFat)
	cRetCode := AllTrim(cFilX) + '|' + AllTrim(cNumFat)

Return cRetCode

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T851GetInt
Recebe um código, busca seu InternalId e faz a quebra da chave
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cCodigo], Caracter, Código externo para busca do código interno
@param [cMarca], Caracter, Produto que enviou a mensagem
@return aRetorno Array contendo status, campos da chave primaria: Filial, Nr. Fatura e o seu InternalId
/*/
//-------------------------------------------------------------------------------------------------
Function T851GetInt(cCodigo, cMarca)

	Local cValInt  := ""
	Local aRetorno := {}
	Local aSepInt  := {}
	Local aCampos  := {"DRT_FILIAL", "DRT_NUM"}
	Local nX		 := 0

	Default cCodigo := ""
	Default cMarca  := ""

	cValInt := CFGA070Int(cMarca, "DRT", "DRT_NUM", cCodigo)

	If ! Empty(cValInt)
		
		aSepInt := Separa(cValInt, "|")
	
		Aadd(aRetorno, .T.)
		Aadd(aRetorno, aSepInt)
		Aadd(aRetorno, cValInt)

		For nX := 1 To Len(aRetorno[2]) //-- Corrigindo o tamanho dos campos
			aRetorno[2][nX] := Padr(aRetorno[2][nX], TamSX3(aCampos[nX])[1])
		Next nX
	Else
		Aadd(aRetorno, .F.)
		Aadd(aRetorno, STR0009 + " -> " + cCodigo)
	EndIf

Return aRetorno

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T851GovCli
Monta a TAG GovernmentalInformation com base nas informações do cliente
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cCli], Caracter, Cliente
@param [cLoj], Caracter, Loja
@return cGovCli TAG GovernmentalInformation do cliente
/*/
//-------------------------------------------------------------------------------------------------
Function T851GovCli(cCli, cLoj)

	Local aAreaSA1 := SA1->(GetArea())
	Local cGovCli  := "" //-- GovernmentalInformation do cliente
	Local cCNPJCPF := "" //-- Pessoa fisica ou juridica
	Local cDatAtu  := "" //-- Data atual no formato 9999-99-99

	Default cCli := ""
	Default cLoj := ""
	
	cDatAtu := Transform(dToS(dDataBase),"@R 9999-99-99")

	SA1->(DbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1") + cCli + cLoj))
		
		cCNPJCPF := Iif(AllTrim(SA1->A1_PESSOA) == "F", "CPF", "CNPJ")

		cGovCli := '<GovernmentalInformation>'
		
		cGovCli += Iif(! Empty(SA1->A1_INSCR)  , '<Id scope="State"     name="INSCRICAO ESTADUAL"  issueOn="' + cDatAtu + '">' + AllTrim(SA1->A1_INSCR)   + '</Id>', "")
		cGovCli += Iif(! Empty(SA1->A1_INSCRM) , '<Id scope="Municipal" name="INSCRICAO MUNICIPAL" issueOn="' + cDatAtu + '">' + AllTrim(SA1->A1_INSCRM)  + '</Id>', "")
		cGovCli += Iif(! Empty(SA1->A1_SUFRAMA), '<Id scope="Federal"   name="SUFRAMA"             issueOn="' + cDatAtu + '">' + AllTrim(SA1->A1_SUFRAMA) + '</Id>', "")
		cGovCli += Iif(! Empty(SA1->A1_CGC)    , '<Id scope="Federal"   name="' + cCNPJCPF + '"    issueOn="' + cDatAtu + '">' + AllTrim(SA1->A1_CGC)     + '</Id>', "")

		cGovCli += '</GovernmentalInformation>'
		
	EndIf
	
	RestArea(aAreaSA1)

Return cGovCli

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T851LisInt
Monta um array com base na TAG ListOfInternalId
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [oXml], Objeto, XML
@return aLisInt Array com os InternalId da mensagem. [X,1] - Name, [X,2] - Origin, [X,3] - Destination
/*/
//-------------------------------------------------------------------------------------------------
Function T851LisInt(oXml)

	Local aLisInt   := {}
	Local cName     := ""
	Local cOrigin   := ""
	Local cDestinat := ""
	Local nCount    := 0
	
	//-- Lista de InternalId recebidos
	If XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_RETURNCONTENT' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent, '_LISTOFINTERNALID' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId, '_INTERNALID' ) != Nil

		//-- Se nao for array
		If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId) != "A"
			//-- Transforma em array
			XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
		EndIf

		//-- Tratamentos relacionados aos InternalIds recebidos
		For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
		
			cName     := ""
			cOrigin   := ""
			cDestinat := ""
			
			//-- Verifica se o Name do InternalId foi informado
			If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount], '_NAME' ) != Nil .And.;
			  !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Name:Text)
				cName := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Name:Text
			EndIf
			
			//-- Verifica se o Origin do InternalId foi informado
			If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount], '_ORIGIN' ) != Nil .And.;
			  !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Origin:Text)
				cOrigin := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Origin:Text
			EndIf
			
			//-- Verifica se o Destination do InternalId foi informado
			If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount], '_DESTINATION' ) != Nil .And.;
			  !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Destination:Text)
				cDestinat := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nCount]:_Destination:Text
			EndIf
			
			Aadd(aLisInt, {cName, cOrigin, cDestinat})

		Next nCount
	EndIf

Return aLisInt

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T851LisMsg
Monta um array com base na TAG ListOfMessages
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [oXml], Objeto, XML
@return aLisMsg Array com as Messages
/*/
//-------------------------------------------------------------------------------------------------
Function T851LisMsg(oXml)

	Local aLisMsg := {}
	Local cMsg    := ""
	Local cType   := ""
	Local cCode   := ""
	Local nType   := 1
	Local nCount  := 0
	
	//-- Mensagens de erro no padrao ListOfMessages
	If XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_PROCESSINGINFORMATION' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) != Nil .And.;
	   XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' ) != Nil
	   
		//-- Se nao for array
		If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
			//-- Transforma em array
			XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
		EndIf

		//-- Percorre o array para obter os erros gerados
		For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
		
			cMsg    := ""
			cType   := ""
			cCode   := ""
			nType   := 1
			
			cMsg := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text

			//-- Verifica se o tipo da mensagem foi informado
			If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount], '_TYPE' ) != Nil .And.;
			  !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_type:Text)
				cType := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_type:Text
				Do Case
				Case (Upper(cType) == "ERROR")
					nType := 1
				Case (Upper(cType) == "WARNING")
					nType := 2
				Case (Upper(cType) == "INFO")
					nType := 3
				EndCase
			EndIf

			//-- Verifica se o codigo da mensagem foi informado
			If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount], '_CODE' ) != Nil .And.;
			  !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_code:Text)
				cCode := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_code:Text
			EndIf
			
			If ! Empty(cCode)
				cMsg += " (" + cCode + ")"
			EndIf
			
			Aadd(aLisMsg, {cMsg, nType, cCode})
		Next nCount
	EndIf

Return aLisMsg

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T851GetMsg
Retorna a mensagem através do UUID
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 20/09/2016
@param [cUUID], Caracter, UUID
@return Objeto XML da mensagem
/*/
//-------------------------------------------------------------------------------------------------
Function T851GetMsg(cUUID)

	Local aAreaXX3 := XX3->(GetArea())
	Local cSeek    := ""
	Local cXml     := ""
	Local oXml     := Nil
	Local cError   := ""
	Local cWarning := ""
	
	dbSelectArea("XX3")
	
	cSeek := cFilAnt + Padr(cUUID, Len(XX3_UUID))
	
	XX3->(dbSetOrder(2))
	If XX3->(dbSeek(cSeek))
		cXml := XX3->XX3_TRANS
	EndIf
	
	oXml := XmlParser(cXml, "_", @cError, @cWarning)
	
	RestArea(aAreaXX3)

Return oXml