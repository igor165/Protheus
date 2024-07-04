#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "FINI040CAN.CH"

/*/{Protheus.doc} IntegDef
Função para chamada do adapter ao receber/enviar a mensagem única de verificação de cancelamento de título a receber

@param	cXml       - XML recebido pelo EAI Protheus
		cTypeTrans - Tipo de transação
					"0" = TRANS_RECEIVE
					"1" = TRANS_SEND
		cTypeMsg   - Tipo da mensagem do EAI
					"20" = EAI_MESSAGE_BUSINESS
					"21" = EAI_MESSAGE_RESPONSE
					"22" = EAI_MESSAGE_RECEIPT
					"23" = EAI_MESSAGE_WHOIS
		cVersion   - Versão da Mensagem Única TOTVS
		cTransac   - Nome da mensagem iniciada no adapter.

@author  Pedro Alencar
@since   17/01/2017
@version P12.1.16
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return FINI040CAN(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

/*/{Protheus.doc} FINI040CAN
Adapter de verificação de cancelamento de fatura

@return lRet, Indica se a mensagem foi processada com sucesso
@return cXmlRet, XML de retorno do adapter

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
Function FINI040CAN(cXml, cTypeTrans, cTypeMessage, cVersion, cTransac)

	Local aArea := GetArea()
	Local lRet := .T.
	Local cXMLRet := ""

	If ( cTypeTrans == TRANS_RECEIVE )
		If ( cTypeMessage == EAI_MESSAGE_WHOIS )
			cXmlRet := "1.000"
		ElseIf ( cTypeMessage == EAI_MESSAGE_BUSINESS )
			lRet := RecBusXML( cXml, @cXMLRet )
		EndIf
	ElseIF cTypeTrans == TRANS_SEND
		lRet := .F.
		cXmlRet := STR0001 //"Operação de envio não implementada."
	Endif

	RestArea( aArea )

Return {lRet, cXmlRet, "AccountReceivableCancellationAllowance"}

/*/{Protheus.doc} RecBusXML
Função para tratar o XML recebido na mensagem de Business

@param cXml, XML recebido
@param cXMLRet, Variável com a mensagem de resposta. Passada por referência.
@return lRet, Indica se processou a mensagem recebida com sucesso

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
Static Function RecBusXML( cXml, cXMLRet )
	Local lRet := .T.
	Local lCancel := .T.
	Local oXML := Nil
	Local cMarca := ""
	Local cExtTit := ""
	Local aRetTit := {}
	Local cPathBC := "/TOTVSMessage/BusinessMessage/BusinessContent/"
	Local cFilTit := ""
	Local cPrefixo := ""
	Local cNumDoc  := ""
	Local cParcela := ""
	Local cTipoDoc := ""
	Local cChaveTit := ""
	Local cErroRet := ""

	oXML := tXMLManager():New()
	lRet := oXML:Parse( cXml )

	If lRet
		cMarca := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )

		cExtTit := oXml:XPathGetNodeValue( cPathBC + "AccountReceivableDocumentInternalId" )
		If ! Empty( cExtTit )
			aRetTit := IntTRcInt( cExtTit, cMarca )
			If aRetTit[1] //Se o registro foi encontrado na tabela de de/para
				cFilTit := PadR( aRetTit[2][2], TamSX3("E1_FILIAL")[1] )
				cPrefixo := PadR( aRetTit[2][3], TamSX3("E1_PREFIXO")[1] )
				cNumDoc  := PadR( aRetTit[2][4], TamSX3("E1_NUM")[1] )
				cParcela := PadR( aRetTit[2][5], TamSX3("E1_PARCELA")[1] )
				cTipoDoc := PadR( aRetTit[2][6], TamSX3("E1_TIPO")[1] )

				cChaveTit := cFilTit + cPrefixo + cNumDoc + cParcela + cTipoDoc
			Else
				lRet := .F.
				cXmlRet := STR0002 + cExtTit //"O título a receber informado não foi encontrado no de/para Protheus: "
			EndIf
		Else
			aAdd( aRetTit, .F. )
			lRet := .F.
			cXmlRet := STR0003 //"É obrigatório informar um valor na tag 'AccountReceivableDocumentInternalId'"
		EndIf
	Else
		cXmlRet := STR0004 //"Houve um erro no tratamento do XML. Verifique se o mesmo está sendo informado corretamente."
	EndIf

	If lRet
		//Verifica se pode excluir o título a receber
		lCancel := VerifCanCR( cChaveTit, 1, @cErroRet, .F. )

		If lCancel
			cXMLRet := "<IsCancellable>true</IsCancellable>"
			cXMLRet += "<Message></Message>"
		Else
			cXMLRet := "<IsCancellable>false</IsCancellable>"
			cXMLRet += "<Message>" + AllTrim( cErroRet ) + "</Message>"
		Endif
	Endif

	aSize ( aRetTit, 0 )
	aRetTit := Nil

	oXML := Nil
	DelClassIntF()

Return lRet

/*/{Protheus.doc} VerifCanCR
Função que verifica se pode excluir um título financeiro a receber

@param cChaveTit, Chave do título a receber a ser verificado
@param nIndice, Indice que será utilizado para busca na tabela SE1
@param cErroRet, Variável com a mensagem de resposta. Passada por referência.
@param lVenda, Indica se está sendo chamada para validar o título gerado numa venda de varejo (RetailSales)
@return lRet, Indica se pode excluir o título

@author Pedro Alencar
@since 17/01/2017
@version P12.1.16
/*/
Function VerifCanCR( cChaveTit, nIndice, cErroRet, lVenda  )
	Local lRet := .T.
	Local aAreaSE1 := SE1->( GetArea() )
	Local aAreaSE5 := SE5->( GetArea() )
	Local aAreaFW9 := FW9->( GetArea() )
	Local lBxConc := SuperGetMV( "MV_BXCONC", , "2" ) == "1"

	Default cChaveTit := ""
	Default nIndice := 1
	Default cErroRet := ""
	Default lVenda := .F.

	SE1->( dbSetOrder( nIndice ) )
	If SE1->( MsSeek( cChaveTit ) )

		//Verifica bloqueio por situação de cobrança
		If lRet .AND. ! F023VerBlq ( "1", "0002", SE1->E1_SITUACA, .F. )
			lRet := .F.
			cErroRet := STR0005 + cChaveTit //"A situação de cobrança do título a receber não permite a realização deste processo. Título: "
		EndIf

		//Verifica se o título tá registrado no SERASA
		If lRet .AND. cPaisLoc == "BRA"
			FW9->( DbSetOrder( 3 ) )
			If FW9->( MsSeek( FWxFilial("FW9") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
				lRet := .F.
				cErroRet := STR0006 + cChaveTit //"Este título a receber não poderá ser excluído pois está registrado no SERASA: "
			EndIf
		EndIf

		//Verifica se existe movimento de AVP para o titulo informado.
		If lRet .AND. !FAVPValTit( "SE1",, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, " " )
			lRet := .F.
			cErroRet := STR0007 + cChaveTit //"Existe movimento de AVP para o título a receber informado. Efetuar o ajuste contábil ou estorno do processo de AVP. Título: "
		EndIf

		//Verifica se o título já foi conciliado
		If lRet
			SE5->( dbSetOrder( 7 ) ) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			IF SE5->( MsSeek( FWxFilial("SE5") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
				If ! Empty( SE5->E5_RECONC ) .AND. !lBxConc
					lRet := .F.
					cErroRet := STR0008 + cChaveTit //"Este título a receber já está com o movimento bancário conciliado: "
				EndIf

				//Nao permite a exclusao de RA com imposto retido em outro titulo RA
				If lRet .AND. SE5->E5_TIPO $ MVRECANT .AND. ( SE5->E5_PRETPIS == "2" .OR. SE5->E5_PRETCOF == "2" .OR. SE5->E5_PRETCSL == "2" )
					lRet := .F.
					cErroRet := STR0009 + cChaveTit + STR0010 //"Este adiantamento possui impostos retidos em outro adiantamento: ", ". É necessario cancelar primeiro o adiantamento responsavel pela retenção dos impostos."
				EndIf
			EndIf
		Endif

		//Verifica se o título já foi baixado
		If lRet .AND. !Empty( SE1->E1_BAIXA ) .AND. SE1->E1_VALOR != SE1->E1_SALDO .AND. ! ( lVenda .AND. AllTrim(SE1->E1_TIPO) == "R$" )
			lRet := .F.
			cErroRet := STR0011 + cChaveTit //"Este título a receber já possuí uma baixa: "
		EndIf

		//Veirifca se o título está fora da carteira (situação de cobrança)
		If ! ( SE1->E1_SITUACA $ " #0" )
			lRet := .F.
			cErroRet := STR0012 + cChaveTit //"Este título a receber não está em carteira: "
		EndIf

	Else

		lRet := .F.
		cErroRet := STR0013 + cChaveTit //"Este título a receber não foi encontrado no Protheus: "

	EndIf

	RestArea( aAreaFW9 )
	RestArea( aAreaSE5 )
	RestArea( aAreaSE1 )
	aSize( aAreaFW9, 0 )
	aAreaFW9 := {}
	aSize( aAreaSE5, 0 )
	aAreaSE5 := {}
	aSize( aAreaSE1, 0 )
	aAreaSE1 := {}
Return lRet
