#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FINI100.CH'

Static cMessage   := "BankTransaction"

/*/{Protheus.doc} FINI100
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de movimentos banc�rios utilizando o conceito de mensagem unica.

@param   cXml          Vari�vel com conte�do XML para envio/recebimento.
@param   cTypeTrans    Tipo de transa��o (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Vers�o da mensagem.
@param   cTransac      Nome da transa��o.

@return  aRet   - (array)   Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@author	marylly.araujo
@since 28/08/2013
@version MP11.90
/*/
Function FINI100(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {}

If (cTypeMsg == EAI_MESSAGE_WHOIS)
	lRet    := .T.
	cXmlRet := '2.000|2.001|3.000'

ElseIf (cTypeTrans == TRANS_SEND .or. cTypeTrans == TRANS_RECEIVE)
	If cVersion = "2."
		aRet    := v2000(cXml, cTypeTrans, cTypeMsg)
		lRet    := aRet[1]
		cXmlRet := aRet[2]
	ElseIf cVersion = "3."
		aRet    := v3000(cXml, cTypeTrans, cTypeMsg)
		lRet    := aRet[1]
		cXmlRet := aRet[2]
	Else
		lRet    := .F.
		cXmlRet := _NoTags(STR0012) // "A vers�o da mensagem informada n�o foi implementada!"
	Endif
Endif

Return {lRet, cXmlRet, cMessage}


/*/{Protheus.doc} v2000
Vers�o 2.x da mensagem (recebimento e envio).

@author  marylly.araujo
@since   28/08/2013
/*/
Static Function v2000(cXml, cTypeTrans, cTypeMsg)

	Local cXmlRet := ''
	Local cErroXml := ''
	Local cWarnXml := ''
	Local aErroAuto := {}
	Local cLogErro := ''
	Local nCount := 0
	Local lRet := .T.
	Local cSA6ValInt := ''
	Local cSE5ValInt := ''
	Local aSEDValInt := {}
	Local aSE5ValInt := {}
	Local cValExt := ''
	Local cEvent := 'upsert'
	Local cMarca := ''
	Local aCab := {}
	Local nOpcExec := 0
	Local cSE5IdMov := '66'
	Local cCarteira := ''
	Local cNaturez := ''
	Local aXX4Area := {}
	Local cOperation := CVALTOCHAR(GetMsgOpc())
	Local cTpMoeda := ''
	Local lHotel := SuperGetMV( "MV_INTHTL", , .F. )
	Local cNatHotel := SuperGetMV( "MV_HTLNAMB", , "" )
	Local aAux := {}
	Local cValExtTit := ""
	Local cPrefix := ""
	Local cNum := ""
	Local cParcela := ""
	Local cTipo := ""
	Local cChaveTit := ""
	Local aAreaSE1 := {}
	Local cBanco := ""
	Local cAgencia := ""
	Local cConta := ""

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private oXmlFIN100 := Nil

	DbSelectArea("SE5")
	SE5->( DbSetOrder(19) ) //Filial + Id do Movimento Financeiro

	DbSelectArea("XX4")

	Do Case
		//Verifica��o do tipo de transa��o recebimento ou envio
		//Trata o envio
		Case cTypeTrans == TRANS_SEND

			//InternalId do Cadastro de Bancos
			cSA6ValInt := M70MontInt( cFilAnt, SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA )

			//InternalId do Movimento Financeiro
			cSE5ValInt := F100MntInt( cFilAnt, SE5->E5_IDMOVI )

			cXMLRet := '<BusinessEvent>'
			cXMLRet +=     '<Entity>BankTransaction</Entity>'
			cXMLRet +=     '<Event>' + cEvent + '</Event>'
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="InternalId">' + cSE5ValInt + '</key>'
			cXMLRet +=     '</Identification>'
			cXMLRet += '</BusinessEvent>'

			cXMLRet += '<BusinessContent>'
			cXMLRet +=	  '<InternalId>' + cSE5ValInt + '</InternalId>'
			cXMLRet +=	  '<OperationType>' + cOperation + '</OperationType>'
			cXMLRet +=	  '<CompanyId>' + cEmpAnt + '</CompanyId>'
			cXMLRet +=	  '<BranchId>' + cFilAnt + '</BranchId>'

			//Tratamento dos dados banc�rios, utilizando ou n�o a msg MATI070 - Bancos
			aXX4Area := XX4->( GetArea() ) //Guardando a �rea da mensagem posicionada nos movimentos banc�rios
			If FWHasEAI( "MATA070", .T.,, .T. )
				cXMLRet += '<BankInternalId>' + cSA6ValInt + '</BankInternalId>'
			Else
				cXMLRet += '<BankCode>' + SE5->E5_BANCO + '</BankCode>'
				cXMLRet += '<Agency>' + SE5->E5_AGENCIA + '</Agency>'
				cXMLRet += '<NumberAccount>' + SE5->E5_CONTA + '</NumberAccount>'
			EndIf
			RestArea( aXX4Area ) //Restaurando a �rea da mensagem do cadastro de naturezas para os movimentos banc�rios

			cXMLRet +=	  '<MovementDate>' + Transform( dToS( SE5->E5_DATA ), "@R 9999-99-99" ) + '</MovementDate>'
			cXMLRet +=	  '<EntryValue>' + CVALTOCHAR( SE5->E5_VALOR ) + '</EntryValue>'
			If SE5->E5_RECPAG == 'R'
				cXMLRet += '<MovementType>2</MovementType>'
			ElseIf SE5->E5_RECPAG == 'P'
				cXMLRet += '<MovementType>1</MovementType>'
			EndIf
			cXMLRet +=	   '<ComplementaryHistory>' + SE5->E5_HISTOR + '</ComplementaryHistory>'

			//Quando a movimenta��o � por cheque, a identifica��o do documento � o n�mero do cheque
			If SE5->E5_MOEDA == 'CH'
				cXMLRet += '<DocumentNumber>' + SE5->E5_NUMCHEQ + '</DocumentNumber>'
			Else
				cXMLRet += '<DocumentNumber>' + SE5->E5_DOCUMEN + '</DocumentNumber>'
			EndIf

			//Tratamento da natureza financeira, utilizando ou n�o a msg FINI010 - Naturezas Financeiras
			aXX4Area := XX4->( GetArea() ) // Guardando a �rea da mensagem posicionada nos movimentos banc�rios
			If FWHasEAI("FINA010",.T.,,.T.)
				cNaturez := F10MontInt( XFILIAL('SED'), SE5->E5_NATUREZ )
				cXMLRet += '<FinancialCode>' + cNaturez + '</FinancialCode>'
			Else
				cXMLRet += '<FinancialCode>' + SE5->E5_NATUREZ + '</FinancialCode>'
			EndIf
			RestArea( aXX4Area ) //Restaurando a �rea da mensagem do cadastro de naturezas para os movimentos banc�rios

			If SE5->E5_MOEDA == 'CC'
				cXMLRet += '<CurrencyType>1</CurrencyType>'
			ElseIf SE5->E5_MOEDA == 'CD'
				cXMLRet += '<CurrencyType>2</CurrencyType>'
			ElseIf SE5->E5_MOEDA == 'CH'
				cXMLRet += '<CurrencyType>3</CurrencyType>'
			ElseIf SE5->E5_MOEDA == 'R$'
				cXMLRet += '<CurrencyType>4</CurrencyType>'
			EndIf

			cXMLRet +=	  '<TypingDate>' + Transform( dToS( SE5->E5_DTDIGIT ), "@R 9999-99-99" ) + '</TypingDate>'
			cXMLRet +=	  '<AvailabilityDate>' + Transform( dToS( SE5->E5_DTDISPO ), "@R 9999-99-99" ) + '</AvailabilityDate>'
			cXMLRet +=	  '<OriginalBranchId>' + SE5->E5_FILORIG + '</OriginalBranchId>'
			cXMLRet += '</BusinessContent>'

		Case cTypeTrans == TRANS_RECEIVE

			If cTypeMsg == EAI_MESSAGE_BUSINESS

				oXmlFIN100 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

				If oXmlFIN100 <> Nil .AND. Empty(cErroXml) .AND. Empty(cWarnXml)
					If ( XmlChildEx( oXmlFIN100:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )
						//Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
						If XmlChildEx( oXmlFIN100:_TOTVSMessage:_MessageInformation:_Product, '_NAME' ) <> Nil
							cMarca := oXmlFIN100:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
						EndIf

						//Recebe o codigo da Conta no Cadastro externo e guarda na variavel cValExt
					   	If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage, '_BUSINESSEVENT' ) <> Nil

					   		If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessEvent, '_IDENTIFICATION' ) <> Nil
					   			cSE5ValExt := oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text

								//Apenas verifica se existe o Registro no XXF para saber se � Inclus�o, Altera��o ou Exclus�o
					   			aSE5ValInt := F100GetInt( cSE5ValExt, cMarca )
					   			If aSE5ValInt[1] // Registro encontrado na integra��o
					   				cSE5ValInt := aSE5ValInt[3]
					   			EndIf
					   		EndIf

					   		If Upper( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text ) == "UPSERT"
					   			If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_OPERATIONTYPE' ) <> Nil
					   				nOpcExec := Val( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OperationType:Text )
								EndIf
							EndIf

							//Verifica��o da exist�ncia do conte�do da mensagem de neg�cio
							If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage, '_BUSINESSCONTENT' ) <> Nil

								//Filial do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_BRANCHID' ) <> Nil
									Aadd( aCab, { "E5_FILIAL", xFilial("SE5"), Nil } )
								EndIf

								//Data do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_MOVEMENTDATE') <> Nil
									Aadd( aCab, { "E5_DATA" ,StoD( StrTran(oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_MovementDate:Text, '-', '' ) ), Nil } )
								EndIf

								//Tipo de Moeda do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_CURRENCYTYPE' ) <> Nil
									cTpMoeda := oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyType:Text
									If cTpMoeda == '1'
										Aadd( aCab, { "E5_MOEDA" ,'CC', Nil } )
									ElseIf cTpMoeda == '2'
										Aadd( aCab, { "E5_MOEDA" ,'CD', Nil } )
									ElseIf cTpMoeda == '3'
										Aadd( aCab, { "E5_MOEDA" ,'CH', Nil } )
									ElseIf cTpMoeda == '4'
										Aadd( aCab, { "E5_MOEDA" ,'R$', Nil } )
									EndIf
								EndIf

								//Valor do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_ENTRYVALUE' ) <> Nil
									Aadd( aCab, { "E5_VALOR", Val(oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntryValue:Text), Nil } )
								EndIf

								//Tipo do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_MOVEMENTTYPE' ) <> Nil
									If Val( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_MovementType:Text ) == 1 //Carteira a Pagar
										cCarteira := 'P'
									ElseIf Val( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_MovementType:Text ) == 2 //Carteira a Receber
										cCarteira := 'R'
									EndIf

									If nOpcExec == 5 .OR. nOpcExec == 6
										If cCarteira == 'R'
											cCarteira := 'P'
											nOpcExec := 3
										ElseIf cCarteira == 'P'
											cCarteira := 'R'
											nOpcExec := 4
										EndIf
									EndIf

									Aadd( aCab, { "E5_RECPAG", cCarteira, Nil } )
								EndIf

								//Natureza Financeira do Documento do Movimento Financeiro
								If lHotel
									Aadd( aCab, { "E5_NATUREZ", cNatHotel, Nil } )
								Else
									If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_FINANCIALCODE' ) <> Nil
										cNaturez := oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialCode:Text

										//Verifica se o ambiente trabalha com a mensagem �nica do cadastro de naturezas financeiras para tratar o InternalId
										aXX4Area := XX4->( GetArea() ) // Guardando a �rea da mensagem posicionada nos movimentos banc�rios
										If FWHasEAI( "FINA010",, .T., .T. )
											aSEDValInt := F10GetInt( cNaturez, cMarca )

											If Len(aSEDValInt) > 0
												If aSEDValInt[1]
													Aadd( aCab, { "E5_NATUREZ", aSEDValInt[2][3], Nil } )
												Else
													lRet := .F.
													cLogErro += '<Message type="ERROR" code="c2">' + STR0003 + '</Message>' //"Natureza financeira n�o existente."
												EndIf
											Else
												lRet := .F.
												cLogErro += '<Message type="ERROR" code="c2">' + STR0003 + '</Message>' //"Natureza financeira n�o existente."
											EndIf
										Else
											cNaturez := oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialCode:Text
											If EMPTY(cNaturez)
												lRet := .F.
												cLogErro += '<Message type="ERROR" code="c2">' + STR0004 + '</Message>' //Natureza financeira n�o definida.
											Else
												Aadd( aCab, { "E5_NATUREZ", cNaturez, Nil } )
											EndIf
										EndIf
										RestArea( aXX4Area ) //Restaurando a �rea da mensagem do cadastro de naturezas para os movimentos banc�rios
									Else
										If cCarteira == 'R'
											cNaturez := GETMV( "MV_SLMNATR", .T., "" )
											If !Empty( cNaturez )
												Aadd( aCab, { "E5_NATUREZ", cNaturez, Nil } )
											Else
												lRet := .F.
												cLogErro += '<Message type="ERROR" code="c2">' + STR0004 + '</Message>' //Natureza financeira n�o definida.
											EndIf
										ElseIf cCarteira == 'P'
											cNaturez := GETMV( "MV_SLMNATP", .T., "" )
											If !EMPTY(cNaturez)
												Aadd( aCab, { "E5_NATUREZ", cNaturez, Nil } )
											Else
												lRet := .F.
												cLogErro += '<Message type="ERROR" code="c2">' + STR0004 + '</Message>' //Natureza financeira n�o definida.
											EndIf
										EndIf
									EndIf
								EndIf

								//Encontra o banco, ag�ncia e conta no protheus atrav�s do internalid de banco recebido
					        	If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_BANKINTERNALID' ) <> Nil .AND. ;
					        	! Empty( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BankInternalId:Text )

									aSA6ValInt := M70GetInt( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BankInternalId:Text, cMarca )

									If Len(aSA6ValInt) > 0
										If aSA6ValInt[1]
											cBanco := aSA6ValInt[2][3]
											cAgencia := aSA6ValInt[2][4]
											cConta := aSA6ValInt[2][5]
										Else
											lRet := .F.
										EndIf
									Else
										lRet := .F.
									EndIf

								Else

									//Se for integra��o com hotelaria, ent�o verifica o banco atrav�s do RA informado na mensagem
									If lHotel .AND. Upper( AllTrim( cMarca ) ) == "BEMATECH"

										//Encontra o banco, ag�ncia e conta no protheus atrav�s do internalid de banco recebido
										If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_ACCOUNTRECEIVABLEDOCUMENTINTERNALID' ) <> Nil
											cValExtTit := oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AccountReceivableDocumentInternalId:Text

											If !Empty( cValExtTit )
												aAux := IntTRcInt( cValExtTit, cMarca )
												If aAux[1]

													cPrefix	:= Padr( aAux[2][3], TamSX3("E1_PREFIXO")[1] )
													cNum := Padr( aAux[2][4], TamSX3("E1_NUM")[1] )
													cParcela := Padr( aAux[2][5], TamSX3("E1_PARCELA")[1] )
													cTipo := Padr( aAux[2][6], TamSX3("E1_TIPO")[1] )

													cChaveTit := FWxFilial("SE1") + cPrefix + cNum + cParcela + cTipo
												Else
													lRet := .F.
													cLogErro += '<Message type="ERROR" code="c2">' + STR0008 + AllTrim(cValExtTit) + '</Message>' //"O t�tulo a receber informado n�o foi encontrado no de/para do Protheus: "
												Endif
											Else
												lRet := .F.
												cLogErro += '<Message type="ERROR" code="c2">' + STR0009 + "'AccountReceivableDocumentInternalId'." + '</Message>' //"Valor n�o informado na tag "
											Endif
										Else
											lRet := .F.
											cLogErro += '<Message type="ERROR" code="c2">' + STR0010 + "'AccountReceivableDocumentInternalId'." + '</Message>' //"Tag n�o encontrada no XML: "
										Endif

										//Procura o t�tulo informado e pega o banco do mesmo
										If lRet .AND. !Empty( cChaveTit )
											aAreaSE1 := SE1->( GetArea() )
											SE1->( dbSetOrder( 1 ) )

											If SE1->( msSeek( cChaveTit ) )
												cBanco := SE1->E1_PORTADO
												cAgencia := SE1->E1_AGEDEP
												cConta := SE1->E1_CONTA
											Endif

											RestArea( aAreaSE1 )
											aSize ( aAreaSE1, 0 )
											aAreaSE1 := Nil
										Endif

									Else //Se n�o tem internalId e n�o for hotelaria, ent�o pega as informa��es nas tags individuais

										If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_BANKCODE' ) <> Nil
											cBanco := oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BankCode:Text
										EndIf

										If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_AGENCY' ) <> Nil
											cAgencia := oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Agency:Text
										EndIf

										If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_NUMBERACCOUNT') <> Nil
											cConta := oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_NumberAccount:Text
										EndIf

									Endif

								EndIf

								If !Empty(cBanco) .AND. !Empty(cAgencia) .AND. !Empty(cConta)
									Aadd( aCab, { "E5_BANCO", cBanco, Nil } )
									Aadd( aCab, { "E5_AGENCIA", cAgencia, Nil } )
									Aadd( aCab, { "E5_CONTA", cConta, Nil } )
								Else
									lRet := .F.
									cLogErro += '<Message type="ERROR" code="c2">' + STR0011 + '</Message>' //"Banco, ag�ncia e conta n�o informados corretamente para realiza��o do movimento."
								Endif

								//Identifica��o do Documento do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_DOCUMENTNUMBER' ) <> Nil
									If cTpMoeda == '3' // Quando o movimento � por cheque, a identifica��o do documento � o n�mero do cheque
										Aadd( aCab, { "E5_NUMCHEQ", oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text, Nil } )
										Aadd( aCab, { "E5_MODSPB", "3", Nil } )
									Else
										Aadd( aCab, { "E5_DOCUMEN" ,oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DocumentNumber:Text, Nil } )
									EndIf
								EndIf

								//Hist�rico do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_COMPLEMENTARYHISTORY' ) <> Nil
									If nOpcExec == 5
										Aadd( aCab, { "E5_HISTOR", STR0001, Nil } ) //"CANCELAMENTO"
									ElseIf nOpcExec == 6
										Aadd( aCab, { "E5_HISTOR", STR0002, Nil } ) //"ESTORNO"
									Else
										Aadd( aCab, { "E5_HISTOR", oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ComplementaryHistory:Text, Nil } )
									EndIf
								EndIf

								//Data de Digita��o do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_TYPINGDATE') <> Nil
									Aadd( aCab, { "E5_DTDIGIT" ,stod(StrTran(oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TypingDate:Text, '-', '' ) ), Nil } )
								EndIf

								//Data de Disponibilidade do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_AVAILABILITYDATE' ) <> Nil
									Aadd( aCab, { "E5_DTDISPO" ,stod(StrTran(oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AvailabilityDate:Text, '-', '') ), Nil } )
								EndIf

								//Filial de Origem do Movimento Financeiro
								If XmlChildEx( oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_ORIGINALBRANCHID' ) <> Nil
									Aadd( aCab, { "E5_FILORIG", oXmlFIN100:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OriginalBranchId:Text, Nil } )
								EndIf
							EndIf

							//Inclus�o de movimento a pagar ou a receber
							If lRet
								MSExecAuto( {|x,y,z,w| FINA100(x,y,z,w), cSE5IdMov := SE5->E5_IDMOVI },, aCab, nOpcExec )

								If aSE5ValInt[1] .AND. !EMPTY(cSE5IdMov)
									SE5->( DbSetOrder(19) ) //Filial + Id do Movimento Financeiro
									If !SE5->( DbSeek( XFILIAL('SE5') + aSE5ValInt[2][2] + aSE5ValInt[2][3] ) )
										cSE5ValInt := F100MntInt( , cSE5IdMov )
									EndIf
								EndIf

								If lMsErroAuto
									aErroAuto := GetAutoGRLog()
									For nCount := 1 To Len(aErroAuto)
										cLogErro += '<Message type="ERROR" code="c2">' + StrTran(StrTran(StrTran( aErroAuto[nCount], "<", " "), "-", " "), "/", " ") + " " + '</Message>'
									Next nCount
									//Monta XML de Erro de execu��o da rotina automatica.
									lRet := .F.
									cXMLRet := cLogErro
								Else
									cSE5ValInt := F100MntInt( , cSE5IdMov )

									If !Empty(cSE5ValExt)	.And.!Empty(cSE5ValInt)
											CFGA070Mnt( cMarca, "SE5", "E5_IDMOVI", cSE5ValExt, cSE5ValInt )
											//Monta xml com status do processamento da rotina automatica OK.
											cXMLRet := "<ListOfInternalId>"
								            cXMLRet +=     "<InternalId>"
								            cXMLRet +=         "<Name>BankTransaction</Name>"
								            cXMLRet +=         "<Origin>" 		+ cSE5ValExt + "</Origin>" //Valor recebido na tag
								            cXMLRet +=         "<Destination>" 	+ cSE5ValInt + "</Destination>" //Valor XXF gerado
								            cXMLRet +=     "</InternalId>"
								            cXMLRet += "</ListOfInternalId>"
									EndIf
								EndIf
							Else
								cXMLRet := cLogErro
							EndIf
						EndIf
					EndIf
				EndIf
			ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

				oXmlFIN100 := XmlParser( cXml, "_", @cErroXml, @cWarnXml )
				//Se n�o houve erros na resposta
				If Upper( oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text ) == "OK"
					//Verifica se a marca foi informada
					If Type( "oXmlFIN100:_TOTVSMessage:_MessageInformation:_Product:_name:Text" ) != "U" .And. ;
		            	 !Empty(oXmlFIN100:_TOTVSMessage:_MessageInformation:_Product:_name:Text)

		               cProduct := oXmlFIN100:_TOTVSMessage:_MessageInformation:_Product:_name:Text
		            Else
		               lRet := .F.
		               cXmlRet := STR0005 + "|" //"Erro no retorno. O Product � obrigat�rio!"
		               Return { lRet, cXmlRet }
		            EndIf

		            //Se n�o for array e existir, transforma a estrutura em array
		            cEvent := Type( "oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId" )
		            If cEvent <> "U" .And. cEvent <> "A"
		               //Transforma em array
		               XmlNode2Arr( oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId" )

			            //Verifica se o c�digo interno foi informado
			            If Type( "oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text" ) != "U" .And. ;
			            	 !Empty( oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text )

			               cValInt := oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text
			            Else
			               lRet := .F.
			               cXmlRet := STR0006 //"Erro no retorno. O OriginalInternalId � obrigat�rio!"
			               Return { lRet, cXmlRet }
			            EndIf

			            //Verifica se o c�digo externo foi informado
			            If Type( "oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text" ) != "U" .And. ;
			                 !Empty( oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text )

			               cValExt := oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text
			            Else
			               lRet := .F.
			               cXmlRet := STR0007 //"Erro no retorno. O DestinationInternalId � obrigat�rio"
			               Return { lRet, cXmlRet }
			            EndIf

						If !Empty( cProduct ) .And. !Empty( cValInt ) .And. !Empty( cValExt )

							CFGA070Mnt( cProduct, "SE5", "E5_IDMOVI", cValExt, cValInt )

						EndIf
					EndIf
		         Else
		            //Se n�o for array
		            If Type("oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
		               //Transforma em array
		               XmlNode2Arr( oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message" )
		            EndIf

		            //Percorre o array para obter os erros gerados
		            For nCount := 1 To Len(oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
		               cError := oXmlFIN100:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + "|"
		            Next nCount

		            lRet := .F.
		            cXmlRet := cError
		         EndIf
			EndIf
	EndCase

Return {lRet, cXmlRet}

/*/{Protheus.doc} v3000
Vers�o 3.x da mensagem (recebimento e envio).

@author  Felipe Raposo
@since   05/04/2019
/*/
Static Function v3000(cXml, cTypeTrans, cTypeMsg)

Local lRet       := .F.
Local cXmlRet    := ""
Local aArea      := GetArea()
Local aSE5Area   := {}
Local dDataAnt   := dDataBase
Local nX, nY

Local oXml, cRefer, cEvent
Local aErro, cErro
Local cNodePath  := ""
Local lFound     := .F.
Local aIntID     := {}
Local cValInt    := ""
Local cValExt    := ""

Local nMsgOpc    := 0
Local cBreak     := ""

Local nAutoOper  := 0
Local aCabAuto   := {}
Local aExecAuto  := {}

Local aTransact  := {}
Local dMovDate   := stod("")
Local cMovType   := ""
Local cMoeda     := ""

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

If (cTypeTrans == TRANS_SEND)
	If (cTypeMsg == EAI_MESSAGE_BUSINESS)
		lRet    := .T.
		cValInt := F100MntInt(, SE5->E5_IDMOVI)
		nMsgOpc := GetMsgOpc()

		cXMLRet := '<BusinessEvent>'
		cXMLRet += ' <Entity>' + cMessage + '</Entity>'
		cXMLRet += ' <Event>' + If(nMsgOpc = 2 .or. nMsgOpc = 5 .or. nMsgOpc = 6, 'delete', 'upsert') + '</Event>'
		cXMLRet += ' <Identification><key name="InternalId">' + cValInt + '</key></Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet += ' <CompanyId>' + _NoTags(cEmpAnt) + '</CompanyId>'
		cXMLRet += ' <BranchId>' + _NoTags(cFilAnt) + '</BranchId>'
		cXMLRet += ' <CompanyInternalId>' + _NoTags(cEmpAnt + '|' + cFilAnt) + '</CompanyInternalId>'
		cXMLRet += ' <InternalId>' + cValInt + '</InternalId>'
		cXMLRet += ' <MovementDate>' + Transform(dtos(SE5->E5_DATA), "@R 9999-99-99") + '</MovementDate>'
		cXMLRet += ' <OperationType>' + cValToChar(nMsgOpc) + '</OperationType>'

		cXMLRet += ' <ListOfTransaction>'

		aSE5Area := SE5->(GetArea())
		cBreak := SE5->(E5_FILIAL + E5_IDMOVI)
		SE5->(dbSetOrder(19))  // E5_FILIAL, E5_IDMOVI.
		SE5->(dbSeek(cBreak, .F.))
		Do While SE5->(!eof() .and. E5_FILIAL + E5_IDMOVI == cBreak)

			// Se for cancelamento (nMsgOpc = 6), pega somente o registro de estorno (E5_SITUACA = 'E').
			If nMsgOpc <> 6 .or. SE5->E5_SITUACA = 'E'
				cXMLRet += ' <Transaction>'
				If SE5->E5_RECPAG == 'P'
					cXMLRet += '  <MovementType>1</MovementType>'
				ElseIf SE5->E5_RECPAG == 'R'
					cXMLRet += '  <MovementType>2</MovementType>'
				EndIf
				cXMLRet += '  <BankCode>' + _NoTags(RTrim(SE5->E5_BANCO)) + '</BankCode>'
				cXMLRet += '  <Agency>' + _NoTags(RTrim(SE5->E5_AGENCIA)) + '</Agency>'
				cXMLRet += '  <BankAccount>' + _NoTags(RTrim(SE5->E5_CONTA)) + '</BankAccount>'
				cXMLRet += '  <BankInternalId>' + _NoTags(M70MontInt(, SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA)) + '</BankInternalId>'
				cXMLRet += '  <EntryValue>' + cValToChar(SE5->E5_VALOR) + '</EntryValue>'
				cXMLRet += '  <ComplementaryHistory>' + _NoTags(RTrim(SE5->E5_HISTOR)) + '</ComplementaryHistory>'
				If nMsgOpc = 1 .or. nMsgOpc = 2  // Transfer�ncia.
					cXMLRet += '  <DocumentType>6</DocumentType>'
				Endif
				If SE5->E5_MOEDA == 'CH' .or. ((nMsgOpc = 7 .or. nMsgOpc = 8) .and. !empty(SE5->E5_NUMCHEQ))
					cXMLRet += '  <DocumentNumber>' + _NoTags(RTrim(SE5->E5_NUMCHEQ)) + '</DocumentNumber>'
				Else
					cXMLRet += '  <DocumentNumber>' + _NoTags(RTrim(SE5->E5_DOCUMEN)) + '</DocumentNumber>'
				EndIf
				If empty(SE5->E5_NATUREZ)
					cXMLRet += '  <FinancialCode/>'
					cXMLRet += '  <FinancialInternalId/>'
				Else
					cXMLRet += '  <FinancialCode>' + _NoTags(RTrim(SE5->E5_NATUREZ)) + '</FinancialCode>'
					cXMLRet += '  <FinancialInternalId>' + _NoTags(F10MontInt(xFilial('SED'), SE5->E5_NATUREZ)) + '</FinancialInternalId>'
				Endif
				If SE5->E5_MOEDA == 'CC'
					cXMLRet += '  <CurrencyType>1</CurrencyType>'
				ElseIf SE5->E5_MOEDA == 'CD'
					cXMLRet += '  <CurrencyType>2</CurrencyType>'
				ElseIf SE5->E5_MOEDA == 'CH'
					cXMLRet += '  <CurrencyType>3</CurrencyType>'
				ElseIf SE5->E5_MOEDA == 'R$'
					cXMLRet += '  <CurrencyType>4</CurrencyType>'
				Endif
				cXMLRet += '  <TypingDate>' + Transform(dtos(SE5->E5_DTDIGIT), "@R 9999-99-99") + '</TypingDate>'
				cXMLRet += '  <AvailabilityDate>' + Transform(dtos(SE5->E5_DTDISPO), "@R 9999-99-99") + '</AvailabilityDate>'
				cXMLRet += '  <OriginalBranchId>' + _NoTags(RTrim(SE5->E5_FILORIG)) + '</OriginalBranchId>'
				cXMLRet += ' </Transaction>'
			Endif

			SE5->(dbSkip())
		EndDo
		RestArea(aSE5Area)

		cXMLRet += ' </ListOfTransaction>'
		cXMLRet += '</BusinessContent>'
	Endif

ElseIf (cTypeTrans == TRANS_RECEIVE)
	If (cTypeMsg == EAI_MESSAGE_RESPONSE)  // Resposta da mensagem �nica TOTVS.
		// Gravo o de/para local, caso tenha sido gravado o dado no sistema remoto.
		lRet := .T.
		oXml := tXmlManager():New()
		oXml:Parse(cXml)
		If Empty(cErro := oXml:Error())
			If upper(oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ProcessingInformation/Status')) = "OK"
				cRefer := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				cEvent := AllTrim(Upper(oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReceivedMessage/Event')))
				aIntID := oXml:XPathGetChildArray('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
				For nX := 1 to len(aIntID)
					cValExt := oXml:xPathGetNodeValue(aIntID[nX, 2] + '/Destination')
					cValInt := oXml:xPathGetNodeValue(aIntID[nX, 2] + '/Origin')
					If cEvent = 'DELETE' .and. !empty(cValInt)
						CFGA070Mnt(cRefer, "SE5", "E5_IDMOVI", nil, cValInt, .T.)
					ElseIf !empty(cValInt) .and. !empty(cValExt)
						CFGA070Mnt(cRefer, "SE5", "E5_IDMOVI", cValExt, cValInt)
					Else
						lRet  := .F.
						cErro := STR0013 + "|"  // "Erro no processamento pela outra aplica��o"
						cErro += STR0014        // "Erro ao processar de/para de c�digos."
					Endif
				Next nX
			Else
				lRet  := .F.
				cErro := STR0013 + "|"  // "Erro no processamento pela outra aplica��o"
				aErro := oXml:XPathGetChildArray('/TOTVSMessage/ResponseMessage/ProcessingInformation/ListOfMessages')
				For nX := 1 To len(aErro)
					cErro += oXml:xPathGetAtt(aErro[nX, 2], 'type') + ": " + Alltrim(oXml:xPathGetNodeValue(aErro[nX, 2])) + "|"
				Next nX
			Endif
		Endif
		oXml := nil

	ElseIf (cTypeMsg == EAI_MESSAGE_RECEIPT)  // Recibo.
		// N�o realiza nenhuma a��o.

	ElseIf (cTypeMsg == EAI_MESSAGE_BUSINESS)  // Chegada de mensagem de neg�cios.
		oXml := tXmlManager():New()
		oXml:Parse(cXml)
		If Empty(cErro := oXml:Error())
			lRet    := .T.
			cRefer  := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
			cEvent  := AllTrim(Upper(oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event')))
			cValExt := oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InternalId')

			// Verifica se encontrou uma chave no de/para.
			aValInt := F100GetInt(cValExt, cRefer)
			If aValInt[1]
				SE5->(dbSetOrder(19))  // E5_FILIAL, E5_IDMOVI.
				lFound  := SE5->(dbSeek(aValInt[2, 2] + aValInt[2, 3], .F.))
				cValInt := aValInt[3]
			Endif

			// Verifica o evento da mensagem.
			If lFound
				If cEvent == 'UPSERT'
					lRet  := .F.
					cErro := STR0017  // "Movimento banc�rio j� importado para o Protheus."
				ElseIf cEvent == 'DELETE'
					lRet  := .T.
				Else
					lRet  := .F.
					cErro := STR0015  // "Opera��o inv�lida. Somente s�o permitidas as opera��es UPSERT e DELETE."
				Endif
			Else
				If cEvent == 'UPSERT'
					lRet  := .T.
				ElseIf cEvent == 'DELETE'
					lRet  := .F.
					cErro := STR0016  // "Registro n�o encontrado no Protheus."
				Else
					lRet  := .F.
					cErro := STR0015  // "Opera��o inv�lida. Somente s�o permitidas as opera��es UPSERT e DELETE."
				Endif
			Endif

			If lRet
				// Caminho do Business Content.
				cNodePath := '/TOTVSMessage/BusinessMessage/BusinessContent/'

				// Tipo de opera��o realizada.
				nAutoOper := val(oXml:xPathGetNodeValue(cNodePath + 'OperationType'))

				If oXml:xPathHasNode(cNodePath + 'MovementDate')
					dMovDate := stod(StrTran(oXml:xPathGetNodeValue(cNodePath + 'MovementDate'), "-", ""))
				Else
					dMovDate := stod("")
				Endif

				// Processa todas as transa��es.
				aTransact := oXml:XPathGetChildArray(cNodePath + "ListOfTransaction")
				For nX := 1 to len(aTransact)
					cNodePath := aTransact[nX, 2] + '/'
					cMoeda    := ""

					If nAutoOper = 7  // 7 = Transfer�ncia.
						cMovType := oXml:xPathGetNodeValue(cNodePath + 'MovementType')

						If cMovType = '1'  // D�bito.
							If oXml:xPathHasNode(cNodePath + 'BankInternalId')
								aIntID := M70GetInt(oXml:xPathGetNodeValue(cNodePath + 'BankInternalId'), cRefer)
								If ValType(aIntID) = "A" .and. aIntID[1]
									aAdd(aCabAuto, {'CBCOORIG',  aIntID[2, 3], nil})
									aAdd(aCabAuto, {'CAGENORIG', aIntID[2, 4], nil})
									aAdd(aCabAuto, {'CCTAORIG',  aIntID[2, 5], nil})
								Endif
							Endif
							If oXml:xPathHasNode(cNodePath + 'FinancialInternalId')
								aIntID := F10GetInt(oXml:xPathGetNodeValue(cNodePath + 'FinancialInternalId'), cRefer)
								If ValType(aIntID) = "A"  .and. aIntID[1]
									aAdd(aCabAuto, {'CNATURORI', aIntID[2, 3], nil})
								Endif
							Endif
						ElseIf cMovType = '2'  // Cr�dito.
							If oXml:xPathHasNode(cNodePath + 'BankInternalId')
								aIntID := M70GetInt(oXml:xPathGetNodeValue(cNodePath + 'BankInternalId'), cRefer)
								If ValType(aIntID) = "A" .and. aIntID[1]
									aAdd(aCabAuto, {'CBCODEST',  aIntID[2, 3], nil})
									aAdd(aCabAuto, {'CAGENDEST', aIntID[2, 4], nil})
									aAdd(aCabAuto, {'CCTADEST',  aIntID[2, 5], nil})
								Endif
							Endif
							If oXml:xPathHasNode(cNodePath + 'FinancialInternalId')
								aIntID := F10GetInt(oXml:xPathGetNodeValue(cNodePath + 'FinancialInternalId'), cRefer)
								If ValType(aIntID) = "A"  .and. aIntID[1]
									aAdd(aCabAuto, {'CNATURDES', aIntID[2, 3], nil})
								Endif
							Endif
							If aScan(aCabAuto, {|x| x[1] == "DDATACRED"}) = 0 .and. oXml:xPathHasNode(cNodePath + 'AvailabilityDate')
								aAdd(aCabAuto, {'DDATACRED', stod(StrTran(oXml:xPathGetNodeValue(cNodePath + 'AvailabilityDate'), "-", "")), nil})
							Endif
						Endif

						If aScan(aCabAuto, {|x| x[1] == "CTIPOTRAN"}) = 0 .and. oXml:xPathHasNode(cNodePath + 'CurrencyType')
							cMoeda := oXml:xPathGetNodeValue(cNodePath + 'CurrencyType')
							If cMoeda = '1'
								aAdd(aCabAuto, {'CTIPOTRAN', 'CC', nil})
							ElseIf cMoeda = '2'
								aAdd(aCabAuto, {'CTIPOTRAN', 'CD', nil})
							ElseIf cMoeda = '3'
								aAdd(aCabAuto, {'CTIPOTRAN', 'CH', nil})
							ElseIf cMoeda = '4'
								aAdd(aCabAuto, {'CTIPOTRAN', 'R$', nil})
							Endif
						Endif

						If aScan(aCabAuto, {|x| x[1] == "CDOCTRAN"}) = 0 .and. oXml:xPathHasNode(cNodePath + 'DocumentNumber')
							aAdd(aCabAuto, {'CDOCTRAN', oXml:xPathGetNodeValue(cNodePath + 'DocumentNumber'), nil})
						Endif

						If aScan(aCabAuto, {|x| x[1] == "NVALORTRAN"}) = 0 .and. oXml:xPathHasNode(cNodePath + 'EntryValue')
							aAdd(aCabAuto, {'NVALORTRAN', val(oXml:xPathGetNodeValue(cNodePath + 'EntryValue')), nil})
						Endif

						If aScan(aCabAuto, {|x| x[1] == "CHIST100"}) = 0 .and. oXml:xPathHasNode(cNodePath + 'ComplementaryHistory')
							aAdd(aCabAuto, {'CHIST100', oXml:xPathGetNodeValue(cNodePath + 'ComplementaryHistory'), nil})
						Endif

						// Rotina FINA100 usa a database para efetuar transfer�ncia.
						dDataBase := dMovDate

					ElseIf nAutoOper = 8  // 8 = Estorno de transfer�ncia.
						cMovType := oXml:xPathGetNodeValue(cNodePath + 'MovementType')

						If cMovType = '2'  // Cr�dito.
							If oXml:xPathHasNode(cNodePath + 'DocumentNumber')
								aAdd(aCabAuto, {'AUTNRODOC', oXml:xPathGetNodeValue(cNodePath + 'DocumentNumber'), nil})
							Endif

							aAdd(aCabAuto, {'AUTDTMOV',  dMovDate, nil})

							If oXml:xPathHasNode(cNodePath + 'BankInternalId')
								aIntID := M70GetInt(oXml:xPathGetNodeValue(cNodePath + 'BankInternalId'), cRefer)
								If ValType(aIntID) = "A" .and. aIntID[1]
									aAdd(aCabAuto, {'AUTBANCO',   aIntID[2, 3], nil})
									aAdd(aCabAuto, {'AUTAGENCIA', aIntID[2, 4], nil})
									aAdd(aCabAuto, {'AUTCONTA',   aIntID[2, 5], nil})
								Endif
							Endif
						Endif

					Else  // Se for um movimento a pagar ou a receber.
						aCabAuto := {}
						aAdd(aCabAuto, {'E5_DATA', dMovDate, nil})

						If oXml:xPathHasNode(cNodePath + 'BankInternalId')
							aIntID := M70GetInt(oXml:xPathGetNodeValue(cNodePath + 'BankInternalId'), cRefer)
							If ValType(aIntID) = "A" .and. aIntID[1]
								aAdd(aCabAuto, {'E5_BANCO',   aIntID[2, 3], nil})
								aAdd(aCabAuto, {'E5_AGENCIA', aIntID[2, 4], nil})
								aAdd(aCabAuto, {'E5_CONTA',   aIntID[2, 5], nil})
							Endif
						Endif

						If oXml:xPathHasNode(cNodePath + 'EntryValue')
							aAdd(aCabAuto, {'E5_VALOR',   val(oXml:xPathGetNodeValue(cNodePath + 'EntryValue')), nil})
						Endif

						If oXml:xPathHasNode(cNodePath + 'CurrencyType')
							cMoeda := oXml:xPathGetNodeValue(cNodePath + 'CurrencyType')
							If cMoeda = '1'
								aAdd(aCabAuto, {'E5_MOEDA', 'CC', nil})
							ElseIf cMoeda = '2'
								aAdd(aCabAuto, {'E5_MOEDA', 'CD', nil})
							ElseIf cMoeda = '3'
								aAdd(aCabAuto, {'E5_MOEDA', 'CH', nil})
							ElseIf cMoeda = '4'
								aAdd(aCabAuto, {'E5_MOEDA', 'R$', nil})
							Endif
						Endif

						If oXml:xPathHasNode(cNodePath + 'ComplementaryHistory')
							aAdd(aCabAuto, {'E5_HISTOR',  oXml:xPathGetNodeValue(cNodePath + 'ComplementaryHistory'), nil})
						Endif

						If oXml:xPathHasNode(cNodePath + 'DocumentNumber')
							If cMoeda = '3'
								aAdd(aCabAuto, {'E5_NUMCHEQ', oXml:xPathGetNodeValue(cNodePath + 'DocumentNumber'), nil})
							Else
								aAdd(aCabAuto, {'E5_DOCUMEN', oXml:xPathGetNodeValue(cNodePath + 'DocumentNumber'), nil})
							Endif
						Endif

						If oXml:xPathHasNode(cNodePath + 'FinancialInternalId')
							aIntID := F10GetInt(oXml:xPathGetNodeValue(cNodePath + 'FinancialInternalId'), cRefer)
							If ValType(aIntID) = "A"  .and. aIntID[1]
								aAdd(aCabAuto, {'E5_NATUREZ', aIntID[2, 3], nil})
							Endif
						Endif

						If oXml:xPathHasNode(cNodePath + 'TypingDate')
							aAdd(aCabAuto, {'E5_DTDIGIT', stod(StrTran(oXml:xPathGetNodeValue(cNodePath + 'TypingDate'), "-", "")), nil})
						Endif

						If oXml:xPathHasNode(cNodePath + 'AvailabilityDate')
							aAdd(aCabAuto, {'E5_DTDISPO', stod(StrTran(oXml:xPathGetNodeValue(cNodePath + 'AvailabilityDate'), "-", "")), nil})
						Endif

						// Para o FINA100 encontrar o registro.
						If cEvent == 'DELETE'
							aAdd(aCabAuto, {'E5_IDMOVI', SE5->E5_IDMOVI, "#"})
							aAdd(aCabAuto, {'INDEX', 19})  // SE5 - �ndice 19 -> E5_FILIAL, E5_IDMOVI.
						Endif

						aAdd(aExecAuto, aCabAuto)
					Endif
				Next nX

				// Se for transfer�ncia ou estorno de transfer�ncia, s� h� um item da matriz a processar.
				If nAutoOper = 7 .or. nAutoOper = 8
					aAdd(aExecAuto, aCabAuto)
				Endif

				Begin Transaction

				aIntID := {}
				For nX := 1 to len(aExecAuto)
					aCabAuto := aExecAuto[nX]

					// Executa rotina.
					msExecAuto({|x, y| FINA100(nil, x, y)}, aCabAuto, nAutoOper)

					If lMsErroAuto
						Do While __lSX8
							RollBackSX8()
						EndDo

						cErro := STR0018  // "A integra��o n�o foi bem sucedida. "
						aErro := GetAutoGRLog()
						If !Empty(aErro)
							cErro += STR0019 + CRLF // "Foi retornado o seguinte erro: "
							For nY := 1 To Len(aErro)
								cErro += aErro[nY] + CRLF
							Next nY
						Else
							cErro += STR0020  // "Verifique os dados enviados."
						Endif

						lRet := .F.
						Exit
					Else
						Do While __lSX8
							ConfirmSX8()
						EndDo

						// Se for inclus�o de movimento, monta o InternalId para inclus�o no de/para.
						If cEvent == 'UPSERT'
							cValInt := F100MntInt(nil, SE5->E5_IDMOVI)
						Endif
						aAdd(aIntID, {cValExt, cValInt})
					Endif
				Next nX

				// Se gravou certo, retorna os c�digos gravados.
				If lRet
					cXmlRet := '<ListOfInternalId>'
					For nX := 1 to len(aIntID)
						cValExt := aIntID[nX, 1]
						cValInt := aIntID[nX, 2]

						// Atualiza o de/para local.
						If cEvent == 'UPSERT'
							CFGA070Mnt(cRefer, "SE5", "E5_IDMOVI", cValExt, cValInt)
						Endif

						cXmlRet += ' <InternalId>'
						cXmlRet += '  <Name>BankTransaction</Name>'
						cXmlRet += '  <Origin>' + cValExt + '</Origin>'
						cXmlRet += '  <Destination>' + cValInt + '</Destination>'
						cXmlRet += ' </InternalId>'
					Next nX
					cXmlRet += '</ListOfInternalId>'
				Else
					DisarmTransaction()
				Endif

				End Transaction
			Endif
		Else
			lRet := .F.
		Endif
		oXml := nil
	Endif
Endif

// Se deu erro no processamento.
If !empty(cErro)
	lRet    := .F.
	cXmlRet := _NoTags(cErro)
Endif

RestArea(aArea)
dDataBase := dDataAnt

Return {lRet, cXmlRet}

/*/{Protheus.doc} F100MntInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cFil	Filial do Registro
@param		cCod	Codigo de Identifica��o do Movimento Financeiro

@author	marylly.araujo
@version	MP11.90
@since		28/08/13
@return	cRetorno - Retorna o InternalId do registro
@sample	exemplo de retorno - Empresa|xFilial|Codigo
/*/
Function F100MntInt(cIntFil, cCodigo)
Return (cEmpAnt + '|' + RTrim(xFilial("SE5", cIntFil)) + '|' + RTrim(cCodigo))

/*/{Protheus.doc} F100GetInt
Recebe um codigo, busca seu InternalId e faz a quebra da chave

@param		cCode	InternalID recebido na mensagem.
@param		cMarca	Produto que enviou a mensagem

@author	marylly.araujo
@version MP11.90
@since 28/08/13
@return	aRetorno Array contendo os campos da chave primaria da natureza e o seu internalid.
@sample	exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Codigo'}, InternalId}
/*/
Function F100GetInt(cCodigo, cMarca)

	Local cValInt := ''
	Local aRetorno := {}
	Local aAux := {}
	Local nX := 0
	Local aCampos := {cEmpAnt, 'E5_FILIAL', 'E5_IDMOVI'}

	cValInt := CFGA070Int(cMarca, 'SE5', 'E5_IDMOVI', cCodigo)
	If !Empty(cValInt)
		aAux := Separa(cValInt, '|')

		// Acerta o tamanho dos campos.
		aAux[1] := Padr(aAux[1], Len(cEmpAnt))
		For nX := 2 to Len(aAux)
			aAux[nX] := Padr(aAux[nX], TamSX3(aCampos[nX])[1])
		Next nX

		aAdd(aRetorno, .T.)
		aAdd(aRetorno, aAux)
		aAdd(aRetorno, cValInt)
	Else
		aAdd(aRetorno, .F.)
	EndIf

Return aRetorno

/*/{Protheus.doc} SetIdMov
Fun��o para defini��o do modo de edi��o da mensagem �nica de  movimentos financeiros

@param cOpc Modo de edi��o do processo

@author marylly.araujo
@since 28/08/2013
@version MP11.90
/*/
Function SetIdMov(nIdMov)
	cSE5IdMov := nIdMov
Return Nil
