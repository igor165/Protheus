#Include 'Protheus.ch'
#Include "FWADAPTEREAI.CH"
#Include 'GPEI280.ch'

/*/{Protheus.doc} GPEI281
Funcao de integracao com o adapter EAI para emissao de cheques que deve
ser integrada com o módulo TRB do Logix.
@author Gabriel de Souza Almeida
@param cXml, varchar, Variavel com conteudo xml para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage, varchar, Tipo de mensagem. (Business Type, WhoIs, etc)
@param cVersion, varchar, Versão da mensagem
@version P12
@since 03/11/2015
@return lRet, Lógico, Indica o resultado da execução da função.
@return cXmlRet, varchar, Mensagem Xml para envio.
/*/
Function GPEI281(cXml, nTypeTrans, cTypeMessage, cVersion)

	Local aArea := GetArea()
	Local lRet := .T.
	Local cVersoesOk := "1.000|"
	
	Private cXmlRet := ""

	Default cVersion := "1.000"

	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			lRet := .F.
			cXMLRet := OemToAnsi(STR0001) // Não há tratamento para recebimento dessa mensagem no Protheus
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE		
			//Tratando o Retorno
			fTrataRet( @lRet, @cXmlRet, cXml )
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXmlRet := cVersoesOk
			lRet := .T.
		EndIf
	ElseIf nTypeTrans == TRANS_SEND
		//Montando o Xml
		fGeraXml(@cXmlRet)
	EndIf
	
	RestArea(aArea)
	cXmlRet := Encodeutf8(cXmlRet)
	
Return { lRet, cXmlRet }

/*/{Protheus.doc} fTrataRet
Trata o retorno da aplicação para gravação do De/Para
@author Gabriel de Souza Almeida
@version P12
@since 03/11/2015
@param lProcOk, lógico, Status do processamento (referência)
@param cMsgRet, varchar, Mensagem de retorno do processamento (referência)
@param cXml, varchar, Mensagem da response para tratamento
/*/
Static Function fTrataRet( lProcOk, cMsgRet, cXml )

	Local nZ := 0
	Local cMarca := ""
	Local cInternIdI := ""
	Local cInternIdE := ""
	
	Private oObjXml := Nil
	Private oObjXmlInt := Nil
	Private cXmlErro := ""
	Private cXmlIErro := ""
	Private cXmlWarn := ""
	Private cXmlIWarn := ""
	Private cXmlInt := ""
	
	oObjXml := XmlParser( cXml, "_", @cXmlErro, @cXmlWarn )
	
	If oObjXml <> Nil .And. Empty( cXmlErro ) .And. Empty( cXmlWarn )
		cMarca := oObjXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		
		If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_STATUS" ) <> Nil
		
			If Upper( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_Status:Text ) == "OK"
			
				If Type("oObjXml:_TotvsMessage:_ResponseMessage:_ReceivedMessage:_MessageContent") <> "U"
					cXmlInt := oObjXml:_TotvsMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
					oObjXmlInt := XmlParser( cXmlInt, "_", @cXmlIErro, @cXmlIWarn )
					
					If oObjXmlInt <> Nil .And. Empty( cXmlIErro ) .And. Empty( cXmlIWarn )
						cInternIdI := oObjXmlInt:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text
						cInternIdE := oObjXml:_TotvsMessage:_ResponseMessage:_ReturnContent:_DocumentNumber:Text + '|' + oObjXml:_TotvsMessage:_ResponseMessage:_ReturnContent:_BatchNumber:Text + '|' + oObjXml:_TotvsMessage:_ResponseMessage:_ReturnContent:_BatchSequence:Text
						CFGA070Mnt( cMarca, 'SM3', 'M3_NUMCHEQ', cInternIdE, cInternIdI )
					Else
						lProcOk := .F.
						cMsgRet := OemToAnsi(STR0003) + " | " + cXmlIErro + " | " + cXmlIWarn
					EndIf
				Else
					lProcOk := .F.
					cMsgRet := OemToAnsi(STR0004) // "Conteúdo de retorno não enviado pela aplicação externa"
				EndIf
			Else
				lProcOk := .F.
				cMsgRet := OemToAnsi(STR0005) // "Erro no processamento da aplicação externa"
			EndIf
		Else	
			lProcOk := .F.
			cMsgRet := OemToAnsi(STR0006) // "Erro no retorno. De/Para não será gravado"
		EndIf
	Else
		lProcOk 	:= .F.
		cMsgRet 	:= OemToAnsi(STR0006) + "|" + cXmlErro + "|" + cXmlWarn // "Erro no retorno. De/Para não será gravado"
	EndIf
	
	oObjXml := Nil
	DelClassIntF()

Return Nil

/*/{Protheus.doc} fGeraXml
Gera o Xml para envio
@author Gabriel de Souza Almeida
@version P12
@since 03/11/2015
@param cXmlRet, varchar, Mensagem de envio
/*/
Static Function fGeraXml( cXmlRet )
	Local cEvento := IIf(SM3->M3_IMPRESS == "C","Delete","Upsert")
	Local cValInt := fInternSM3(cEmpAnt,,SM3->M3_BANCO,SM3->M3_AGENCIA,SM3->M3_CONTA,SM3->M3_NUMCHEQ)
	Local cValExt := CFGA070Ext("LOGIX", "SM3", "M3_NUMCHEQ", cValInt)
	Local cBankI := M70MontInt(cFilAnt,SM3->M3_BANCO,SM3->M3_AGENCIA,SM3->M3_CONTA)
	Local cBatchNum := ""
	Local cBatchSeq := ""
	Local cCostCenter := CFGA070Ext("LOGIX", "CTD", "CTD_ITEM", SM3->M3_ITEMC) //InternalId da Item Contábil - AreaAndLineOfBusiness (CTBI040)
	Local cContaCred := CFGA070Ext("LOGIX", "CT1", "CT1_CONTA", cEmpAnt + "|" + xFilial("CT1",SM3->M3_FILIAL) + "|" + AllTrim(SM3->M3_CREDITO)) //InternalId Da Conta Contábil - ACCOUNTANTACCOUNT (CTBI020)
	Local cContaDeb := CFGA070Ext("LOGIX", "CT1", "CT1_CONTA", cEmpAnt + "|" + xFilial("CT1",SM3->M3_FILIAL) + "|" + AllTrim(SM3->M3_DEBITO)) //InternalId Da Conta Contábil
	Local cBank := CFGA070Ext("LOGIX", "SA6", "A6_COD", cBankI)
	Local cDigAge := ""
	Local cDigCta := ""
	
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	
	If SA6->(MsSeek(xFilial("SA6",cFilAnt)+SM3->M3_BANCO))
		cDigAge := SA6->A6_DVAGE
		cDigCta := SA6->A6_DVCTA
	EndIf
	
	If !(Empty(cDigAge))
		cDigAge := '-' + cDigAge
	EndIf
	
	If !(Empty(cDigCta))
		cDigCta := '-' + cDigCta
	EndIf
	
	cValExt := SubStr(cValExt, AT("|", cValExt)+1)
	cBatchNum := SubStr(cValExt, 1, AT("|", cValExt) - 1)
	cBatchSeq := SubStr(cValExt, AT("|", cValExt)+1)

	cXMLRet += '<BusinessEvent>'
	cXMLRet += 	'<Entity>GPEI281</Entity>'//BankTransactions
	cXMLRet += 	'<Event>'+ cEvento +'</Event>'
	cXMLRet += 	'<Identification>'
	cXMLRet += 		'<key name="Code">' + cValInt + '</key>'
	cXMLRet += 	'</Identification>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'
	cXMLRet += 	'<CompanyId>'  + cEmpAnt + '</CompanyId>'
	//cXMLRet += 	'<BranchId>'   + xFilial("SM3") + '</BranchId>'
	cXMLRet += 	'<BranchId>'   + cFilAnt + '</BranchId>'
	cXMLRet += 	'<Bank>'
	cXMLRet += 		'<BankCode>' + AllTrim(cBank) + '</BankCode>'
	cXMLRet += 		'<AgencyNumber>' + AllTrim(SM3->M3_AGENCIA) + cDigAge + '</AgencyNumber>'
	cXMLRet += 		'<BankAccount>' + AllTrim(SM3->M3_CONTA) + cDigCta + '</BankAccount>'
	cXMLRet += 	'</Bank>'
	cXMLRet += 	'<MovementDate>' + Transform( Dtos( SM3->M3_DTEMISS ), "@R 9999-99-99") + '</MovementDate>'
	cXMLRet += 	'<EntryValue>' + AllTrim(Str(SM3->M3_VALOR)) + '</EntryValue>'
	cXMLRet += 	'<MovementType>' + '1' + '</MovementType>' //Tipo de movimento utilizado no Logix sendo que '1' refere-se à "Débito"
	cXMLRet += 	'<ApportionmentDistribution>'
	cXMLRet += 		'<Apportionment>'
	cXMLRet += 			'<DebitAccount>' + AllTrim(cContaDeb) + '</DebitAccount>'
	cXMLRet += 			'<CreditAccount>' + AllTrim(cContaCred) + '</CreditAccount>'
	cXMLRet += 			'<CostCenterCode>' + AllTrim(cCostCenter) + '</CostCenterCode>'
	cXMLRet += 		'</Apportionment>'
	cXMLRet += 	'</ApportionmentDistribution>'
	cXMLRet += 	'<HistoryCode>' + AllTrim(SM3->M3_CODHIST) + '</HistoryCode>' //Código do histórico utilizado no Logix
	cXMLRet += 	'<ComplementaryHistory>' + OemToAnsi(STR0002) + '</ComplementaryHistory>' //Comentário padrão para os cheques integrados através do Protheus
	cXMLRet += 	'<DocumentType>' + '4' + '</DocumentType>' //Tipo de documento utilizado no Logix, sendo que '4' refere-se à "Cheque"
	cXMLRet += 	'<DocumentNumber>' + AllTrim(SM3->M3_NUMCHEQ) + '</DocumentNumber>'
	cXMLRet += 	'<BatchNumber>' + AllTrim(cBatchNum) + '</BatchNumber>'
	cXMLRet += 	'<BatchSequence>' + AllTrim(cBatchSeq) + '</BatchSequence>'
	cXMLRet += '</BusinessContent>'
Return Nil

/*/{Protheus.doc} fInternSM3
Retorna o InternalId
@author Gabriel de Souza Almeida
@version P12
@since 03/11/2015
@param cEmpresa, varchar, Empresa
@param cFilial, varchar, Filial
@param cBanco, varchar, Banco
@param cAgencia, varchar, Agencia
@param cConta, varchar, Conta
@param cNumCheq, varchar, Némero do cheque
/*/
Function fInternSM3 (cEmp,cFil,cBanco,cAgencia,cConta,cNumCheq)
	Local cRet := ""
	Default cFil := xFilial("SM3")
	
	cFil:=xFilial("SM3",cFil)
	cRet := AllTrim(cEmp) + '|' + AllTrim(cFil) + '|' + AllTrim(cBanco) + '|' + AllTrim(cAgencia) + '|' + AllTrim(cConta) + '|' + AllTrim(cNumCheq)
Return cRet
