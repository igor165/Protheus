#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TMSI852.CH"

#DEFINE DTMS852ROT "TMSA852"
#DEFINE DTMS852MSG "TRANSPORTINVOICESTATUS"
#DEFINE DTMS852VER "1.000|1.001|2.000|2.001"

/*/{Protheus.doc} Tmsi852
Adapter de Integração SIGATMS x Contas a Receber. 
 Mensagem Única: TransportInvoiceStatus.
 Preparado e habilitado para o método Assíncrono. 
 Atualiza o status da fatura de transporte (DRT) conforme movimentos de baixa
 no contas a receber
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 08/11/2016
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
Function Tmsi852(cXml, cType, cTypeMessage, cVersion, cTransaction)

	Local aArea      := GetArea()
	Local aRet       := {}  //-- Array de retorno
	Local aMessages  := {}  //-- Mensagens de erros do processamento
	Local aVersion   := {}  //-- Versoes suportadas pelo Adapter
	Local aRetInt    := {}  //-- Array retorno de-para
	Local cErroXml   := ""  //-- Erro no parser do XML
	Local cWarnXml   := ""  //-- Alerta no parser do XML
	Local cEntity    := ""  //-- Transacao da msg de resposta
	Local cProduct   := ""  //-- Produto que enviou a resposta
	Local cEvent     := ""  //-- Evento: UPSERT ou DELETE
	Local cIntIdRec  := ""  //-- Id externo
	Local cFilFat    := ""  //-- Filial da fatura
	Local cNumFat    := ""  //-- Numero da fatura
	Local cBankSt    := ""  //-- Status do banco
	Local nSdoTit    := 0   //-- Saldo do titulo
	Local nOriTit    := 0   //-- Valor origem do titulo
	Local lBxaTot    := .F. //-- Baixa total do titulo?
	Local lBxaPar    := .F. //-- Baixa parcial do titulo?
	Local lProTit    := .F. //-- Titulo protestado
	Local nCount     := 0
	Local lVersVal   := .F. //-- Versao valida
	Local oXml

	//-- Informacoes de retorno
	Aadd(aRet, .T.)
	Aadd(aRet, "")
	Aadd(aRet, DTMS852MSG)
	
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
					cEntity := Upper(oXml:_TOTVSMessage:_MessageInformation:_Transaction:Text)
				Else
					aRet[1] := .F.
					//-- "Entidade/Transacao nao informada ou invalida!"
					Aadd(aMessages, {STR0006, 1, "TMSI852003"})
				EndIf
				
				//-- Verifica se a marca foi informada
				If XmlChildEx(oXml:_TOTVSMessage:_MessageInformation, '_PRODUCT' )       != Nil .And.;
				   XmlChildEx(oXml:_TOTVSMessage:_MessageInformation:_Product, '_NAME' ) != Nil .And.;
				   !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
					cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					aRet[1] := .F.
					//-- "O elemento Product eh obrigatorio!"
					Aadd(aMessages, {STR0005, 1, "TMSI852004"})
				EndIf
			EndIf
			
			If Empty(cVersion)
				aRet[1] := .F.
				//-- "Versao da mensagem nao informada!"
				Aadd(aMessages, {STR0001, 1, "TMSI852001"})
			EndIf
			
			If cTypeMessage == EAI_MESSAGE_BUSINESS .And. aRet[1]
			
				If XmlChildEx(oXml:_TOTVSMessage, '_BUSINESSMESSAGE' ) != Nil
				
					If XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage, '_BUSINESSEVENT' ) != Nil .And.;
					   XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent, '_EVENT' ) != Nil
						cEvent := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
					EndIf
					
					//-- Obtem InternalId da fatura (DestinationId que devera passar pelo DE-PARA)
					If XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage, '_BUSINESSCONTENT' ) != Nil .And.;
					   XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_INTERNALID' ) != Nil
						cIntIdRec := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
					EndIf
					
					//-- Recupera InternalId atraves do DE-PARA
					aRetInt := T851GetInt(cIntIdRec, cProduct)
					If aRetInt[1]
						cFilFat := aRetInt[2,1]
						cNumFat := aRetInt[2,2]
					Endif
				EndIf
				
				If Empty(cEvent)
					aRet[1] := .F.
					//-- "Elemento Event eh obrigatorio!"
					Aadd(aMessages, {STR0004, 1, "TMSI852005"})
				EndIf
				
				If Empty(cIntIdRec)
					aRet[1] := .F.
					//-- "Elemento InternalId eh obrigatorio!"
					Aadd(aMessages, {STR0007, 1, "TMSI852006"})
				EndIf
				
				If ! aRetInt[1]
					aRet[1] := .F.
					//-- "Fatura nao encontrada no de/para! Id externo: "
					Aadd(aMessages, {STR0008 + " " + cIntIdRec, 1, "TMSI852007"})
				EndIf
				
			EndIf
		Else
			aRet[1] := .F.
			//-- "Erro no parser do XML recebido!"
			Aadd(aMessages, {STR0002 + " [ERROR: " + cErroXml + ", WARNING: " + cWarnXml + "] ", 1, "TMSI852001"})
		EndIf
	EndIf
	
	If cTypeMessage != EAI_MESSAGE_WHOIS .And. ! Empty(cVersion)
		aVersion := Separa(DTMS852VER, "|")
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
			Aadd(aMessages, {STR0003 + " (" + AllTrim(cVersion) + ")", 1, "TMSI852002"})
		EndIf
	EndIf
	
	If aRet[1] //-- Se nao houver erros ate o momento, processa a mensagem
	
		Do Case
		Case (cType == TRANS_RECEIVE) //-- Recebimento
		
			Do Case
			Case (cTypeMessage == EAI_MESSAGE_BUSINESS)
			
				If XmlChildEx(oXml:_TOTVSMessage, '_BUSINESSMESSAGE' ) != Nil

					//-- Localiza e posiciona na fatura
					DbSelectArea("DRT")
					DRT->(dbSetOrder(1))
					If DRT->(MsSeek(Padr(cFilFat, Len(DRT_FILIAL)) + Padr(cNumFat, Len(DRT_NUM))))
						
						cStatus := DRT->DRT_STATUS //-- Status atual da fatura

						lBxaTot := .F.
						lBxaPar := .F.
						lProTit := .F.
						cBankSt := ""
						
						//-- Lista de titulos (AccountReceivableDocument) recebidos
						If XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage, '_BUSINESSCONTENT' ) != Nil .And.;
						   XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_LISTOFACCOUNTRECEIVABLEDOCUMENT' ) != Nil .And.;
						   XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument, '_ACCOUNTRECEIVABLEDOCUMENT' ) != Nil
		
							//-- Se nao for array
							If ValType(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument) != "A"
								//-- Transforma em array
								XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument, "_AccountReceivableDocument")
							EndIf

							//-- Tratamentos relacionados aos titulos (AccountReceivableDocument) recebidos
							For nCount := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument)
								
								nSdoTit := 0
								nOriTit := 0

								If XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_REALVALUE' ) != Nil
									nSdoTit := Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_RealValue:Text)
								EndIf

								If XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_GROSSVALUE' ) != Nil
									nOriTit := Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_GrossValue:Text)
								EndIf
								
								If XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount], '_DOCUMENTBANKINGSTATUS' ) != Nil
									cBankSt := AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAccountReceivableDocument:_AccountReceivableDocument[nCount]:_DocumentBankingStatus:Text)
								EndIf
								
								If ! Empty(cBankSt) .And. cBankSt == "3" //-- Titulo Protestado
									lProTit := .T.
									Exit
								EndIf
								
								Do Case
								Case ((nSdoTit < nOriTit .And. nSdoTit > 0) .Or. (nSdoTit == nOriTit .And. lBxaTot))
									lBxaPar := .T.
									lBxaTot := .F.
									Exit
								Case (nSdoTit == 0)
									lBxaTot := .T.
								EndCase
							Next nCount
						EndIf
						
						If lProTit
							cStatus := "6" //-- Fatura protestada
						Else
							If lBxaTot
								cStatus := "4" //-- Fatura totalmente baixada
							ElseIf lBxaPar
								cStatus := "3" //-- Fatura parcialmente baixada
							Else
								cStatus := "1" //-- Fatura integrada
							EndIf
						EndIf
					
						//-- Atualiza o status da fatura
						RecLock('DRT',.F.)
						DRT->DRT_STATUS := cStatus
						DRT->(MsUnLock())
					EndIf
				EndIf
				
			Case (cTypeMessage == EAI_MESSAGE_RESPONSE)
			
			Case (cTypeMessage == EAI_MESSAGE_RECEIPT)
			
			Case (cTypeMessage == EAI_MESSAGE_WHOIS)
				aRet[2] := DTMS852VER //-- Retorna as versoes validas
			EndCase
	
		Case (cType == TRANS_SEND) //-- Envio

		EndCase
	EndIf

	//-- Se gerar mensagens de erro, adiciona ao retorno
	If Len(aMessages) >= 1
		aRet[2] += FWEAILOfMessages(aMessages)
	EndIf

	RestArea(aArea)

Return aRet

/*/{Protheus.doc} IntegDef
Integração SIGATMS x Contas a Receber: chamada do adapter para processamento da mensagem
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
Static Function IntegDef(cXml, cType, cTypeMessage, cVersion, cTransaction)

	Local aRet := {}
	
	aRet := TMSI852(cXml, cType, cTypeMessage, cVersion, cTransaction)

Return aRet