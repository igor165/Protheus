#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'   //Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH'       //Include para rotinas com MVC
#Include 'MATI360.CH'

Function MATI360( cXml, nTypeTrans, cTypeMsg, cVersion, cTransaction )
   Local cError   := ""
   Local cWarning := ""
   Local cVersao  := ""
   Local lRet     := .T.
   Local cXmlRet  := ""
   Local aRet     := {}

   Private oXML   := Nil

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      If cTypeMsg == EAI_MESSAGE_BUSINESS .Or. cTypeMsg == EAI_MESSAGE_RESPONSE
         oXml := xmlParser(cXml, "_", @cError, @cWarning)

         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            // Versão da mensagem
            If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
               cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
            Else
               lRet := .F.
               cXmlRet := STR0006 // "Versão da mensagem não informada!"
               Return {lRet, cXmlRet}
            EndIf
         Else
            lRet := .F.
            cXmlRet := STR0007 // "Erro no parser!"
            Return {lRet, cXmlRet}
         EndIf

         Do Case
            Case cVersao == "1"
               aRet := v1000(cXml, nTypeTrans, cTypeMsg)
            Case cVersao == "2"
               aRet := v2000(cXml, nTypeTrans, cTypeMsg, oXml)
            Case cVersao == "3"
               aRet := v3000(cXml, nTypeTrans, cTypeMsg, oXml)         
            OtherWise
               lRet    := .F.
               cXmlRet := STR0005 // "A versão da mensagem informada não foi implementada!"
               Return {lRet, cXmlRet}
         EndCase
      ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
         aRet := v2000(cXml, nTypeTrans, cTypeMsg, oXml)
      EndIf
   ElseIf nTypeTrans == TRANS_SEND

      If Empty( cTransaction )
         lRet := .F.
         cXmlRet := STR0031 //"Adapter não encontrado!"
         Return {lRet, cXmlRet}
      Else
         If Empty( cVersion )
            lRet := .F.
            cXmlRet := STR0030 //"Versão não informada no cadastro do adapter."
            Return {lRet, cXmlRet}   
         Else
            cVersao := StrToKarr( cVersion, "." )[1]
         EndIf
      EndIf

      Do Case
      Case cVersao == "1"
         aRet := v1000(cXml, nTypeTrans, cTypeMsg)
      Case cVersao == "2"
         aRet := v2000(cXml, nTypeTrans, cTypeMsg, oXml)
      Case cVersao == "3"
         aRet := v3000(cXml, nTypeTrans, cTypeMsg, oXml)         
      OtherWise
         lRet := .F.
         cXmlRet := STR0005 // "A versão da mensagem informada não foi implementada!"
         Return {lRet, cXmlRet}
      EndCase
      
   EndIf

   lRet    := aRet[1]
   cXMLRet := aRet[2]
Return {lRet, cXmlRet}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ v1000       º Autor ³ Danilo Dias       º Data ³ 16/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para envio e          º±±
±±º          ³ recebimento do cadastro de condicoes de pagamento (SE4)      º±±
±±º          ³ utilizando o conceito de mensagem unica.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Param.   ³ cXML - Variavel com conteudo xml para envio/recebimento.     º±±
±±º          ³ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          º±±
±±º          ³ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ aRet - Array contendo o resultado da execucao e a mensagem   º±±
±±º          ³        Xml de retorno.                                       º±±
±±º          ³ aRet[1] - (boolean) Indica o resultado da execução da função º±±
±±º          ³ aRet[2] - (caracter) Mensagem Xml para envio                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ MATA360                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function v1000( cXml, nTypeTrans, cTypeMsg )

Local aArea 		:= GetArea()			//Salva contexto atual
Local lRet 		:= .T.					//Retorna se a execucao foi bem sucedida ou nao
Local lAchou		:= .T.					//Indica se encontrou o registro no banco
Local lUpsert     := .F. 					// Indica se e inclusão|alteração ou exclusão
Local cXmlRet		:= ''					//Xml de retorno da IntegDef
Local cEvent 		:= 'upsert'			//Evento da transacao ( Upsert/Delete )
Local cError 		:= ''					//Mensagem de erro do parse
Local cWarning 	:= ''					//Mensagem de warning do parse
Local nOpc			:= 0					//Operacao executada
Local aMsgErro		:= {}					//Array com erro na validação do Model
Local cLogErro		:= ""					//Log de erro
Local nI, nL								//Contadores de uso geral

Local aParcelas		:= {}					//Array com regras do campo E4_COND
Local cDias			:= ''					//Dias para o vencimento da primeira parcela
Local cParcelas		:= ''					//Quantidade de parcelas
Local cIntervalo	:= ''					//Intervalo entre cada parcela
Local cCondicao		:= ''					//Guarda o campo E4_COND
Local cDescriCon	:= ''					//Guarda o campo E4_DESCRI
Local cDiaDesc		:= ''					// Guarda o campo E4_DIADESC
Local cDescFin    := ''					// Guarda o campo E4_DESCFIN
Local cAcrsFin    := ''					// Guarda o campo E4_ACRSFIN
Local cDiaSemana	:= ''					//Dia da semana para o vencimento das parcelas
Local cDiaMes		:= ''					//Dia do mês para o vencimento das parcelas
Local cDiasDesc		:= ''					//Dias para desconto da parcela
Local cCodCond		:= ''					//Codigo da condição de pagamento
Local nMult			:= 0					//Multiplicador para o tipo 2

Local lMktPlace 	:= SuperGetMv("MV_MKPLACE",.F.,.F.)

Local oModel		:= Nil					//Model completo do MATA360
Local oModelSE4	:= Nil					//Model com a master apenas
Local oXml			:= Nil					//Objeto Xml completo
Local oXmlEvent	:= Nil					//Objeto Xml com o conteudo da BusinessEvent apenas
Local oXmlContent	:= Nil					//Objeto Xml com o conteudo da BusinessContent apenas

//Verifica o tipo de transacao (Envio/Recebimento)
Do Case

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata o envio de mensagem                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( nTypeTrans == TRANS_SEND )

		//Carrega Model do cadastro de Condição de Pagamento
		oModel		:= FWModelActive()
		If oModel == nil .Or. IsInCallStack("CARGAMKT")
   			oModel   := FWLoadModel( 'MATA360' )
   			oModel:Activate()
		EndIf
		oModelSE4	:= oModel:GetModel('SE4MASTER')
		nOpc		:= oModel:nOperation

		//Verica operação realizada
		If nOpc == MODEL_OPERATION_DELETE
			cEvent := 'delete'	//Exclusão
		Else
			cEvent := 'upsert'	//Alteração

			//Carrega os dados da condição de acordo com o tipo para montar o Xml
			Do Case
				Case oModelSE4:GetValue('E4_TIPO') == '1'

					cCondicao	:= AllTrim( oModelSE4:GetValue( 'E4_COND' ) )
					aParcelas	:= MontaParcelas( cCondicao )
					cParcelas 	:= cValToChar( Len( aParcelas ) )
					cDias 		:= cValToChar( Val( aParcelas[1][1] ) )

				Case oModelSE4:GetValue( 'E4_TIPO' ) == '2'

					nMult 		:= Val( AllTrim( oModelSE4:GetValue( 'E4_COND' ) ) )
					cCondicao	:= oModelSE4:GetValue( 'E4_CODIGO' )
					cDias 		:= SubStr( cCondicao, 1, 1 )
					cDias 		:= cValToChar( Val( cDias ) * nMult )
					cParcelas	:= SubStr( cCondicao, 2, 1 )
					cIntervalo	:= SubStr( cCondicao, 3, 1 )
					cIntervalo	:= cValToChar( Val( cIntervalo ) * nMult )
					aParcelas 	:= {}

				Case oModelSE4:GetValue( 'E4_TIPO' ) == '3'

				Case oModelSE4:GetValue( 'E4_TIPO' ) == '4'

					cCondicao	:= AllTrim( oModelSE4:GetValue( 'E4_COND' ) )
					aParcelas	:= MontaParcelas( cCondicao )
					cParcelas	:= aParcelas[1][1]
					cIntervalo	:= aParcelas[2][1]
					cDiaSemana	:= aParcelas[3][1]
					cDias 		:= cValToChar( Val( cIntervalo ) )
					aParcelas 	:= {}

				Case oModelSE4:GetValue( 'E4_TIPO' ) == '5'

					cCondicao	:= AllTrim( oModelSE4:GetValue( 'E4_COND' ) )
					aParcelas	:= MontaParcelas( cCondicao )
					cDias 		:= aParcelas[1][1]
					cParcelas	:= aParcelas[2][1]
					cIntervalo	:= aParcelas[3][1]
					aParcelas 	:= {}

				Case oModelSE4:GetValue( 'E4_TIPO' ) == '6'

					cCondicao	:= AllTrim( oModelSE4:GetValue( 'E4_COND' ) )
					aParcelas	:= MontaParcelas( cCondicao )
					cParcelas	:= aParcelas[1][1]
					cDias 		:= aParcelas[2][1]
					cDiaSemana	:= aParcelas[3][1]
					cIntervalo	:= aParcelas[4][1]
					aParcelas 	:= {}

				Case oModelSE4:GetValue( 'E4_TIPO' ) == '7'

				Case oModelSE4:GetValue( 'E4_TIPO' ) == '8'

				Case oModelSE4:GetValue( 'E4_TIPO' ) == '9'

				Case oModelSE4:GetValue( 'E4_TIPO' ) == 'B'

			EndCase

		EndIf

		//Montagem da mensagem de Condições de Pagamento
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>PaymentCondition</Entity>'
		If lMktPlace
			cXMLRet +=     '<Identification>'
			cXMLRet +=         '<key name="InternalID">' + xFilial('SE4') + '|' + oModelSE4:GetValue('E4_CODIGO') + '</key>'
			cXMLRet +=     '</Identification>'
		Endif
		cXMLRet +=     '<Event>' + cEvent + '</Event>'	//Tipo de evento (upsert/delete)
		cXMLRet += '</BusinessEvent>'

		cXMLRet += '<BusinessContent>'
		cXMLRet +=     '<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=     '<BranchId>' + xFilial('SE4') + '</BranchId>'
		If lMktPlace
			cXMLRet +=     '<CompanyInternalId>' + cEmpAnt + "|"+ xFilial('SE4') + '</CompanyInternalId>'
			cXMLRet +=     '<InternalId>' + cEmpAnt + "|" + xFilial('SE4') + "|" + oModelSE4:GetValue('E4_CODIGO') + '</InternalId>'
		Endif
		cXMLRet +=     '<Code>' + oModelSE4:GetValue('E4_CODIGO') + '</Code>'
		cXMLRet +=     '<Description>' + oModelSE4:GetValue('E4_DESCRI') + '</Description>'
		cXMLRet +=     '<TypePaymentCondition>' + Alltrim(oModelSE4:GetValue('E4_TIPO')) + '</TypePaymentCondition>'
		cXMLRet +=     '<DaysFirstDue>' + cDias + '</DaysFirstDue>'								//Dias para primeira parcela
		cXMLRet +=     '<QuantityPlots>' + cParcelas + '</QuantityPlots>'						//Quantidade de parcelas
		cXMLRet +=     '<RangePlots>' + cIntervalo + '</RangePlots>'							//Intervalo entre as parcelas
		cXMLRet +=     '<WeekDayFixed>' + cDiaSemana + '</WeekDayFixed>'						//Dia da semana, quando este for fixo
		cXMLRet +=     '<DayMonthFixed>' + cDiaMes + '</DayMonthFixed>'						//Dia do mês, quando este for fixo
		cXMLRet +=     '<DaysCondition>' + cDiasDesc + '</DaysCondition>'						//Contagem dos dias para as parcelas
		cXMLRet +=     '<FinancialDiscountDays>' + cValToChar( oModelSE4:GetValue('E4_DIADESC') ) + '</FinancialDiscountDays>'	//Dias para desconto financeiro
		cXMLRet +=     '<PercentageDiscountDays>' + cValToChar( oModelSE4:GetValue('E4_DESCFIN') ) + '</PercentageDiscountDays>'	//Percentual de desconto financeiro
		cXMLRet +=     '<PercentageIncrease>' + cValToChar( oModelSE4:GetValue('E4_ACRSFIN') ) + '</PercentageIncrease>'			//Percentual de acréscimo

		cXMLRet +=		'<Plots>'

		If ( Len( aParcelas ) > 0 )

			For nI := 1 To Len( aParcelas )
				cXMLRet +=			'<Due>'
				cXMLRet +=				'<DueDay>' + aParcelas[nI][1] + '</DueDay>'
				cXMLRet +=				'<Percentage>' + aParcelas[nI][2] + '</Percentage>'
				cXMLRet +=			'</Due>'
			Next nI

		EndIf

		cXMLRet +=		'</Plots>'
		cXMLRet +=	'</BusinessContent>'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata recebimento de mensagens                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( nTypeTrans == TRANS_RECEIVE )

		Do Case

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da WhoIs                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( cTypeMsg == EAI_MESSAGE_WHOIS )

				cXmlRet := "1.000|2.000|3.000"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da Response Message                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )

				cXmlRet := STR0001	//'Mensagem processada'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Receipt Message (Aviso de receb. em transmissoes assincronas)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( cTypeMsg == EAI_MESSAGE_RECEIPT )

				cXmlRet := STR0002	//'Mensagem recebida'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da Business Message                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )

				oXML := XmlParser( cXML, '_', @cError, @cWarning )

				If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )

					//Instancia objetos com conteudo parcial do Xml
					oXMLEvent 		:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
					oXMLContent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

					//Guarda o codigo da Condicao recebido na mensagem.
					//Para utilização com De/Para, altere o aqui para pegar o codigo da tabela XX5
					//Leitura do XML
					If ( XmlChildEx( oXMLContent, '_CODE' ) != Nil )
						cCodCond := oXMLContent:_Code:Text
					EndIf

					If ( XmlChildEx( oXmlContent, '_DESCRIPTION' ) != Nil )
						cDescriCon := oXmlContent:_Description:Text
					EndIf

					If ( XmlChildEx( oXmlContent, '_FINANCIALDISCOUNTDAYS' ) != Nil )
						cDiaDesc := Val( oXmlContent:_FinancialDiscountDays:Text )
					EndIf

					If ( XmlChildEx( oXmlContent, '_PERCENTAGEDISCOUNTDAYS' ) != Nil )
						cDescFin := Val( oXmlContent:_PercentageDiscountDays:Text )
					EndIf

					If ( XmlChildEx( oXmlContent, '_PERCENTAGEINCREASE' ) != Nil )
						cAcrsFin := Val( oXmlContent:_PercentageIncrease:Text )
					EndIf

					//Tratamento para parcelas informadas de forma padronizada
					If ( XmlChildEx( oXmlContent, '_QUANTITYPLOTS' ) != Nil )
						nParcelas := Val( oXmlContent:_QuantityPlots:Text )
					EndIf

					//Trata as parcelas recebidas
					If 	( XmlChildEx( oXmlContent:_Plots, '_DUE' ) != Nil )
						//Tratamento para parcelas informadas individualmente
						If ( ValType( oXmlContent:_Plots:_Due ) != 'A' )
							XmlNode2Arr( oXmlContent:_Plots:_Due, '_DUE' )
						EndIf

						cCondicao := ''

						For nI := 1 To Len( oXmlContent:_Plots:_Due )
							cCondicao += oXmlContent:_Plots:_Due[nI]:_DueDay:Text

							If ( nI < Len( oXmlContent:_Plots:_Due ) )
								cCondicao += ','
							EndIf
						Next nI
					Else
						If ( XmlChildEx( oXmlContent, '_DAYSFIRSTDUE' ) != Nil )
							cCondicao := oXmlContent:_DaysFirstDue:Text
							nL := Val( cCondicao )
							If ( nParcelas > 1 )
								cCondicao += ','

								For nI := 1 To ( nParcelas - 1 )

									nL += Val( oXmlContent:_RangePlots:Text )
									cCondicao += cValToChar( nL )

									If ( nI < ( nParcelas - 1 ) )
										cCondicao += ','
									EndIf

								Next nI
							EndIf
						EndIf
					EndIf
					
					//Dias Condição
					If ( XmlChildEx( oXmlContent, '_DAYSCONDITION' ) != Nil )
						cDaysCondition := BuscaDC(oXmlContent:_DAYSCONDITION:Text)
					EndIf

					lUpsert := ( Upper( oXMLEvent:_Event:Text ) == 'UPSERT' )

					//Posiciona tabela SE4
					dbSelectArea('SE4')
					SE4->( dbSetOrder(1) )	//Filial + Condição (E4_FILIAL + E4_CODIGO)
					lAchou := SE4->( dbSeek( xFilial('SE4') + cCodCond ) )

					//Carrega model com estrutura da Cond. de Pagamento
					oModel := FwLoadModel( 'MATA360' )

					//Verifica a operação realizada
					If lUpsert
						If ( lAchou )
							//Alteração
							oModel:SetOperation( MODEL_OPERATION_UPDATE )
						Else
							//Inclusão
							oModel:SetOperation( MODEL_OPERATION_INSERT )
						EndIf
					Else
						//Exclusão
						oModel:SetOperation( MODEL_OPERATION_DELETE )
						If ( !lAchou )
							cXMLRet := EncodeUTF8(STR0003 + " -> " + cCodCond)	//'Registro não encontrado!'
						EndIf
					EndIf

					oModel:Activate()
					oModelSE4 := oModel:GetModel('SE4MASTER')	//Model parcial da Master (SE4)

               If ( oModel:nOperation != MODEL_OPERATION_DELETE )
                  //Recebimento dos dados
                  If oModel:nOperation == MODEL_OPERATION_INSERT
                     If Empty(Posicione('SX3',2,Padr('E4_CODIGO' ,10),'X3_RELACAO'))
                        oModelSE4:SetValue( 'E4_CODIGO', cCodCond )
                     Endif
                  Else
                     oModelSE4:SetValue( 'E4_CODIGO', cCodCond )
                  Endif
                  oModelSE4:SetValue( 'E4_TIPO', '1' )	//Grava apenas tipo 1
                  oModelSE4:SetValue( 'E4_COND', cCondicao )
                  oModelSE4:SetValue( 'E4_DESCRI', cDescriCon )
                  oModelSE4:SetValue( 'E4_DIADESC', cDiaDesc )
                  oModelSE4:SetValue( 'E4_DESCFIN', cDescFin )
                  oModelSE4:SetValue( 'E4_ACRSFIN',cAcrsFin )
                  If !Empty(cDaysCondition)
                     oModelSE4:SetValue( 'E4_DDD',cDaysCondition)
                  Endif
               EndIf
               //Gravação dos dados recebidos
               If ( lRet )

                  If oModel:VldData()
                     //Executa o commit dos dados
                     oModel:CommitData()
                  Else
                     //Trata erro de gravação do model
                     lRet := .F.
                     aMsgErro := oModel:GetErrorMessage()
                     cLogErro := ''

                     For nI := 1 To Len(aMsgErro)
                        If ( ValType( aMsgErro[nI] ) == 'C' )
                           cLogErro += aMsgErro[nI] + '|'
                        EndIf
                     Next nI

                     // Monta XML de Erro de execução da rotina automatica.
                     cXMLRet := EncodeUTF8( cLogErro )
                  EndIf

               EndIf
				Else
					//Tratamento no erro do parse Xml
					lRet := .F.
					cXMLRet := STR0004	//'Erro na manipulação do Xml recebido. '
					cXMLRet += IIf ( !Empty(cError), cError, cWarning )

					cXMLRet := EncodeUTF8(cXMLRet)
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fim do recebimento da Business Message                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End Case

End Case

RestArea( aArea )

Return { lRet, cXmlRet }


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ OMSI010     º Autor ³ Danilo Dias       º Data ³ 16/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Monta array com os prazos das parcelas do campo E4_COND.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Param.   ³ cCondicao - Conteudo do campo E4_COND                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ aParcelas - Array com os valores da condição.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ MATI360                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaParcelas( cCondicao )

Local nI 			:= 1	//Controla a posicao do ponteiro que varre os prazos em cCondicao
Local nInicio 		:= 1	//Indica a posicao inicial para o SubStr separar o prazo
Local nQtde 		:= 1	//Indica a quantidade de caracteres que o SubStr deve pegar
Local aParcelas 	:= {}	//Array com os prazos da condicao

//Varre o conteudo de cCondicao com conteudo do E4_COND
For nI := 1 To Len(cCondicao)

	//Se caracter atual for uma vírgula, não faz nada
	If ( SubStr( cCondicao, nI, 1 ) != ',' )

		If ( SubStr( cCondicao, nI + 1, 1 ) == ',' ) .Or. ( (nI + 1) > Len(cCondicao) )

			//Adiciona no array o prazo de vencimento de acordo com nInicio e nQtde
			aAdd( aParcelas, { SubStr( cCondicao, nInicio, nQtde ), '01' } )
			nInicio := nI + 2	//Atualiza nInicio com a posicao inicial do proximo prazo
			nQtde := 0			//Zera nQtde para contar quantos digitos tem o proximo prazo

		EndIf

		nQtde += 1		//Incrementa a quantidade de digitos para o SubStr

	EndIf
Next nI

Return aParcelas

//-------------------------------------------------------------------
/*/{Protheus.doc} v2000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de condicoes de pagamento (SE4) utilizando o conceito de
mensagem unica.

@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 25/06/2012
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caracter) Mensagem Xml para envio

@obs
O método irá retornar um objeto do tipo TOTVSBusinessEvent caso o tipo
da mensagem seja EAI_BUSINESS_EVENT ou um tipo TOTVSBusinessRequest
caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Static Function v2000(cXml, nTypeTrans, cTypeMsg, oXml)
   Local aArea         := GetArea()                 // Salva contexto atual
   Local lRet          := .T.                       // Retorna se a execucao foi bem sucedida ou nao
   Local cXmlRet       := ""                        // Xml de retorno da IntegDef
   Local cEvent        := "upsert"                  // Evento da transacao (Upsert/Delete)
   Local cError        := ""                        // Mensagem de erro do parse
   Local cWarning      := ""                        // Mensagem de warning do parse
   Local aMsgErro      := {}                        // Array com erro na validação do Model
   Local nI            := 1                         // Contadores de uso geral
   Local aParcelas     := {}                        // Array com regras do campo E4_COND
   Local cDias         := ""                        // Dias para o vencimento da primeira parcela
   Local cParcelas     := ""                        // Quantidade de parcelas
   Local cIntervalo    := ""                        // Intervalo entre cada parcela
   Local cCondicao     := ""                        // Guarda o campo E4_COND
   Local cDiaSemana    := ""                        // Dia da semana para o vencimento das parcelas
   Local cDiaMes       := ""                        // Dia do mês para o vencimento das parcelas
   Local cDiasDesc     := ""                        // Dias para desconto da parcela
   Local cCode         := ""                        // Codigo da condição de pagamento
   Local nMult         := 0                         // Multiplicador para o tipo 2
   Local cProduct      := ""                        // Marca, Referência (RM, PROTHEUS, DATASUL etc)
   Local cValInt       := ""                        // Valor interno no Protheus
   Local cValExt       := ""                        // Valor externo
   Local cAlias        := "SE4"                     // Alias da tabela no Protheus
   Local cField        := "E4_CODIGO"               // Campo identificador no Protheus
   Local oModel        := Nil                       // Model completo do MATA360
   Local oModelSE4     := Nil                       // Model com a master apenas
   Local aCondPgto     := {}                        // Array com os valores recebidos
   Local aAux          := {}                        // Array de uso geral
   Local cTemp         := ""                        // Utilizada para montagem da condição do tipo 8
   Local nOpcx         := 0                         // Operação realizada
   Local lInc          := .F.
   Local lMktPlace     := SuperGetMv("MV_MKPLACE",.F.,.F.)

   Private lMsErroAuto := .F.

   // Se recebimento
   If nTypeTrans == TRANS_RECEIVE
      If cTypeMsg == EAI_MESSAGE_BUSINESS
         // Verifica se o InternalId foi informado
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
            cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
         Else
            lRet := .F.
            cXmlRet := STR0011 // "O código do InternalId é obrigatório!"
            Return {lRet, cXmlRet}
         EndIf

         // Verifica se a marca foi informada
         If Type("oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
            cProduct := oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text
         Else
            lRet := .F.
            cXmlRet := STR0012 // "O Produto é obrigatório!"
            Return {lRet, cXmlRet}
         EndIf

         // Verifica se a filial atual é a mesma filial de inclusão do cadastro
         aAux := IntChcEmp(oXml, cAlias, cProduct)
         If !aAux[1]
            lRet := aAux[1]
            cXmlRet := aAux[2]
            Return {lRet, cXmlRet}
         EndIf
         
         // Verifica se o código da Condição de Pagamento foi informado
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
            cCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
         Else
            lRet := .F.
            cXmlRet := STR0013 // "O Código da Condição de Pagamento é obrigatório!"
            Return {lRet, cXmlRet}
         EndIf

         // Obtém o valor interno da tabela XXF (de/para)
         aAux := IntConInt(cValExt, cProduct, /*Versão*/)

         // Se o evento é UPSERT
         If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
            If !aAux[1]
               // Inclusão
               nOpcx := 3
            Else
               // Alteração
               nOpcx := 4
            EndIf
         ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
            If aAux[1]
               // Exclusão
               nOpcx := 5
            Else
               lRet := .F.
               cXMLRet := (STR0003 + " -> " + cValExt) // Registro não encontrado!
               Return {lRet, cXmlRet}
            EndIf
         Else
            lRet := .F.
            cXmlRet := STR0014 // "O evento informado é inválido"
            Return {lRet, cXmlRet}
         EndIf
         
         dbSelectArea("SE4")
         SE4->(DbSetOrder(1)) // Filial + Condição (E4_FILIAL + E4_CODIGO)
         If nOpcx <> 3
		  		SE4->(dbSeek(xFilial("SE4") + PadR(aAux[2,3],TamSx3("E4_CODIGO")[1])))
         Endif
		  
         // Carrega model com estrutura da Cond. de Pagamento
         oModel := FwLoadModel("MATA360")
         	  
         If nOpcx == 3
            oModel:SetOperation(MODEL_OPERATION_INSERT)
         Elseif nOpcx == 4
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
         Elseif nOpcx == 5
            oModel:SetOperation(MODEL_OPERATION_DELETE)
         Endif

         If oModel:nOperation != MODEL_OPERATION_DELETE
            // Recebimento dos dados
				lInc := oModel:nOperation == MODEL_OPERATION_INSERT
            
				//Verifica se utiliza inicialização padrão 
				If lInc
					If Empty(Posicione('SX3',2,Padr('E4_CODIGO' ,10),'X3_RELACAO'))
						aAdd(aCondPgto, {"E4_CODIGO", cCode, Nil})
					Endif
				Else
					aAdd(aCondPgto, {"E4_CODIGO", cCode, Nil})
				Endif

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)
               If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text) > TamSX3("E4_DESCRI")[1]
                  lRet := .F.
                  cXmlRet := STR0015 + AllTrim(cValToChar(TamSX3("E4_DESCRI")[1])) + STR0016 // "A descrição da condição de pagamento no Protheus suporta no máximo [x] caracteres!"
                  Return {lRet, cXmlRet}
               EndIf

               aAdd(aCondPgto, {"E4_DESCRI", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil})
            Else
               lRet := .F.
               cXmlRet := STR0017 // "A descrição da condição de pagamento é obrigatória!"
               Return {lRet, cXmlRet}
            EndIf

            // Trata as parcelas recebidas
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots") != "U" .And. Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due") != "U"
               // Tratamento para parcelas informadas individualmente
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due") != "A"
                  XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due, "_DUE")
               EndIf

               For nI := 1 To Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due)
                  cCondicao += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due[nI]:_DueDay:Text
                  cTemp += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due[nI]:_Percentage:Text

                  If nI < Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due)
                     cCondicao += ','
                     cTemp += ','
                  EndIf

                  If Len(cCondicao) + 5 > TamSX3("E4_COND")[1]
                     lRet := .F.
                     cXmlRet := STR0018 + AllTrim(Str(TamSX3("E4_COND")[1])) + STR0019 // "A Condição de Pagamento para o Tipo 8 no Protheus não pode ultrapassar [x] caracteres."
                     Return {lRet, cXmlRet}
                  EndIf
               Next nI

               cCondicao := "[" + cCondicao + "],[" + cTemp + "]"

               aAdd(aCondPgto, {"E4_TIPO", "8", Nil}) // Grava apenas tipo 8
            Else
               //Tratamento para parcelas informadas de forma padronizada
               // Quantidade de parcelas
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_QuantityPlots:Text") != 'U' .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_QuantityPlots:Text)
                  cParcelas := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_QuantityPlots:Text
               Else
                  lRet    := .F.
                  cXmlRet := STR0020 // "Quantidade de parcelas não informada!"
                  Return {lRet, cXmlRet}
               EndIf

               // Quantidade de parcelas
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RangePlots:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RangePlots:Text)
                  cIntervalo += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RangePlots:Text
               Else
                  lRet := .F.
                  cXmlRet := STR0021 // "Intervalo de dias não informado!"
                  Return {lRet, cXmlRet}
               EndIf

               // Dias de carência para a primeira parcela
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysFirstDue:Text") != 'U' .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysFirstDue:Text)
                  cDias += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysFirstDue:Text
               Else
                  cDias += "0"
               EndIf

               // Dia da semana
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WeekDayFixed:Text") != 'U' .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WeekDayFixed:Text)
                  cDiaSemana += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WeekDayFixed:Text
               EndIf

               If Empty(cDiaSemana)
                  aAdd(aCondPgto, {"E4_TIPO", "5", Nil})
                  cCondicao := cDias + "," + cParcelas + "," + cIntervalo
               Else
                  aAdd(aCondPgto, {"E4_TIPO", "6", Nil})
                  cCondicao := cParcelas + "," + cDias + "," + cDiaSemana + ',' + cIntervalo
               EndIf
            EndIf

            aAdd(aCondPgto, {"E4_COND", cCondicao, Nil})

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscountDays:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscountDays:Text)
               aAdd(aCondPgto, {"E4_DIADESC", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscountDays:Text), Nil})
            EndIf

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageDiscountDays:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageDiscountDays:Text)
               aAdd(aCondPgto, {"E4_DESCFIN", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageDiscountDays:Text), Nil})
            EndIf

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageIncrease:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageIncrease:Text)
               aAdd(aCondPgto, {"E4_ACRSFIN", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageIncrease:Text), Nil})
            EndIf

            // Dias da Condição
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysCondition:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysCondition:Text)
               cDaysCondition := BuscaDC(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysCondition:Text)

               If !Empty(cDaysCondition)
                  aAdd(aCondPgto, {"E4_DDD", cDaysCondition, Nil})
               Else
                  lRet    := .F.
                  cXmlRet := STR0022 + Chr(10) + STR0023 // "Dias da condição inválido! [quebra linha] Os valores aceitos pelo Protheus são: 0=Data do Dia; 1=Fora o Dia; 7=Fora Semana;  10=Fora Dezena; 15=Fora quinzena; 30=Fora Mes"
                  Return {lRet, cXmlRet}
               EndIf
            EndIf
         Else
         		If aAux[1]
         			aAdd(aCondPgto, {"E4_CODIGO", aAux[2,3], Nil})
         		Endif
         EndIf

         oModel:Activate()
         oModelSE4 := oModel:GetModel("SE4MASTER") // Model parcial da Master (SE4)

         // Obtém a estrutura de dados
         aAux := oModelSE4:GetStruct():GetFields()

         For nI := 1 To Len(aCondPgto)
            // Verifica se os campos passados existem na estrutura do modelo
            If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aCondPgto[nI][1])}) > 0
               // É feita a atribuição do dado ao campo do Model
               If oModel:nOperation <> MODEL_OPERATION_DELETE
                  If !oModel:SetValue('SE4MASTER', aCondPgto[nI][1], aCondPgto[nI][2]) .And. (aCondPgto[nI][1] != "E4_CODIGO" .Or. oModel:nOperation != MODEL_OPERATION_UPDATE)
                     lRet := .F.
                     cXmlRet := STR0034 + AllToChar(aCondPgto[nI][2]) + STR0035 + aCondPgto[nI][1] + "." //"Não foi possível atribuir o valor " " ao campo "
                     Return {lRet, cXmlRet}
                  EndIf
               Endif
            EndIf
         Next nI

         // Se os dados não são válidos
         If !oModel:VldData()
            // Obtém o log de erros
            aMsgErro := oModel:GetErrorMessage()

            cXmlRet := STR0036 + AllToChar(aMsgErro[6]) + CRLF //"Mensagem do erro: "
            cXmlRet += STR0037 + AllToChar(aMsgErro[7]) + CRLF //"Mensagem da solução: "
            cXmlRet += STR0038 + AllToChar(aMsgErro[8]) + CRLF //"Valor atribuído: "
            cXmlRet += STR0039 + AllToChar(aMsgErro[9]) + CRLF //"Valor anterior: "
            cXmlRet += STR0040 + AllToChar(aMsgErro[1]) + CRLF //"Id do formulário de origem: "
            cXmlRet += STR0041 + AllToChar(aMsgErro[2]) + CRLF //"Id do campo de origem: "
            cXmlRet += STR0042 + AllToChar(aMsgErro[3]) + CRLF //"Id do formulário de erro: "
            cXmlRet += STR0043 + AllToChar(aMsgErro[4]) + CRLF //"Id do campo de erro: "
            cXmlRet += STR0044 + AllToChar(aMsgErro[5]) //"Id do erro: "

            lRet := .F.
            Return {lRet, cXmlRet}
         Else
            // Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
            oModel:CommitData()
            
            // Obtém o InternalId
            cValInt := IntConExt(/*Empresa*/, /*Filial*/, SE4->E4_CODIGO, /*Versão*/)[2]
         EndIf

         If lRet
	         // Se o evento é diferente de delete
	         If oModel:nOperation != MODEL_OPERATION_DELETE
	            // Grava o registro na tabela XXF (de/para)
	            CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
	         Else
	            // Exclui o registro na tabela XXF (de/para)
	            CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
	         EndIf
	
	         // Monta o XML de retorno
	         cXMLRet := "<ListOfInternalId>"
	         cXMLRet +=     "<InternalId>"
	         cXMLRet +=         "<Name>" + 'PaymentCondition' + "</Name>"
	         cXMLRet +=         "<Origin>" + cValExt + "</Origin>"
	         cXMLRet +=         "<Destination>" + cValInt + "</Destination>"
	         cXMLRet +=     "</InternalId>"
	         cXMLRet += "</ListOfInternalId>"
	      Endif
	      
      ElseIf cTypeMsg == EAI_MESSAGE_WHOIS // Recebimento da WhoIs
         cXmlRet := "1.000|2.000|3.000"
      ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE // Recebimento da Response Message
         // Se não houve erros na resposta
         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
            // Verifica se a marca foi informada
            If ValType("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet    := .F.
               cXmlRet := STR0024 // "Erro no retorno. O Product é obrigatório!"
               Return {lRet, cXmlRet}
            EndIf
			 
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") <> "U"
	            // Verifica se o código interno foi informado
	            If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
	               cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0025 // "Erro no retorno. O OriginalInternalId é obrigatório!"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Verifica se o código externo foi informado
	            If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
	               cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0026 // "Erro no retorno. O DestinationInternalId é obrigatório"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Obtém a mensagem original enviada
	            If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0027 // "Conteúdo do MessageContent vazio!"
	               Return {lRet, cXmlRet}
	            EndIf

				  // Faz o parse do XML em um objeto
	            oXML := XmlParser(cXML, "_", @cError, @cWarning)
	
	            If Empty(oXML) .And. "UTF-8" $ Upper(cXML)
	               oXML := xmlParser(EncodeUTF8(cXML), "_", @cError, @cWarning)
	            EndIf
	
	            // Se não houve erros no parse
	            If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
	               If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
	                  // Insere / Atualiza o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
	               ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
	                  // Exclui o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
	               Else
	                  lRet := .F.
	                  cXmlRet := STR0028 // "Evento do retorno inválido!"
	               EndIf
	            Else
	               lRet := .F.
	               cXmlRet := STR0029 // "Erro no parser do retorno!"
	               Return {lRet, cXmlRet}
	            EndIf
	         Endif
         Else
            // Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               // Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            // Percorre o array para obter os erros gerados
            For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + CRLF
            Next nI

            lRet := .F.
            cXmlRet := cError
         EndIf
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      //Carrega Model do cadastro de Condição de Pagamento
      oModel    := FWModelActive()
      If oModel == nil
         oModel   := FWLoadModel( 'MATA360' )
         oModel:Activate()
      EndIf
      oModelSE4 := oModel:GetModel('SE4MASTER')

      //Verica operação realizada
      Do Case
         Case oModel:nOperation == MODEL_OPERATION_INSERT
            cEvent := 'upsert' //Inclusão
         Case oModel:nOperation == MODEL_OPERATION_UPDATE
            cEvent := 'upsert' //Alteração
         Case oModel:nOperation == MODEL_OPERATION_DELETE
            cEvent := 'delete' //Exclusão
            CFGA070Mnt(,"SE4","E4_CODIGO",,IntConExt(,,oModelSE4:GetValue('E4_CODIGO'),)[2],.T.)
      EndCase

      //Verica operação realizada
      If oModel:nOperation != MODEL_OPERATION_DELETE
         //Carrega os dados da condição de acordo com o tipo para montar o Xml
         Do Case
            Case oModelSE4:GetValue('E4_TIPO') == '1'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MontaVencimentos(MntParcela(cCondicao), 1)
               cParcelas  := cValToChar(Len(aParcelas))
               cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))

            Case oModelSE4:GetValue('E4_TIPO') == '2'
               nMult      := Val(RTrim(oModelSE4:GetValue('E4_COND')))
               cCondicao  := oModelSE4:GetValue('E4_CODIGO')
               cDias      := SubStr(cCondicao, 1, 1)
               cDias      := cValToChar(Val(cDias) * nMult)
               cParcelas  := SubStr(cCondicao, 2, 1)
               cIntervalo := SubStr(cCondicao, 3, 1)
               cIntervalo := cValToChar(Val(cIntervalo) * nMult)
               aParcelas  := {}

            Case oModelSE4:GetValue('E4_TIPO') == '3'
            	cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))        
               cDias      := StrTokArr(cCondicao, ',')[2]                                                
               cParcelas  := StrTokArr(cCondicao, ',')[1]                                                
               cCondicao  := oModelSE4:GetValue('E4_CODIGO')                                                                                                                                   
               aParcelas  := Condicao(100,cCondicao,0,dDataBase,0)                                                                     
               aParcelas  := aEval(aParcelas,{|x| x[1] := AllTrim(Str(x[1]-dDataBase))}) 	//-- Altera o campo de data para string
               aParcelas  := aEval(aParcelas,{|x| x[2] := AllTrim(Str(x[2]))}) 

            Case oModelSE4:GetValue('E4_TIPO') == '4'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MntParcela(cCondicao)
               cParcelas  := aParcelas[1][1]
               cIntervalo := aParcelas[2][1]
               cDiaSemana := aParcelas[3][1]
               cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))
               aParcelas  := {}

            Case oModelSE4:GetValue('E4_TIPO') == '5'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MntParcela(cCondicao)
               cDias      := aParcelas[1][1]
               cParcelas  := aParcelas[2][1]
               cIntervalo := aParcelas[3][1]
               aParcelas  := {}

            Case oModelSE4:GetValue('E4_TIPO') == '6'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MntParcela(cCondicao)
               cParcelas  := aParcelas[1][1]
               cDias      := aParcelas[2][1]
               cDiaSemana := aParcelas[3][1]
               cIntervalo := aParcelas[4][1]
               aParcelas  := {}

            Case oModelSE4:GetValue('E4_TIPO') == '7'
            	If lMktPlace
   					cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
	   				cDias      := StrTokArr(cCondicao, ',')[2]                                                
   					cParcelas  := StrTokArr(cCondicao, ',')[1]
	   				cCondicao  := oModelSE4:GetValue('E4_CODIGO')                                                                                                                                  
		   			aParcelas  := Condicao(100,cCondicao,0,dDataBase,0)                                                                     
			   		aParcelas  := aEval(aParcelas,{|x| x[1] := AllTrim(Str(x[1]-dDataBase))}) 	//-- Altera o campo de data para string
   					aParcelas  := aEval(aParcelas,{|x| x[2] := AllTrim(Str(x[2]))})                                                 
   				Endif
            Case oModelSE4:GetValue('E4_TIPO') == '8'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MntParcela(cCondicao, 8)
               cParcelas  := cValToChar(Len(aParcelas))
               cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))

            Case oModelSE4:GetValue('E4_TIPO') == '9'

            Case oModelSE4:GetValue('E4_TIPO') == 'A'

            Case oModelSE4:GetValue('E4_TIPO') == 'B'
         EndCase
      EndIf

      //Montagem da mensagem de Condições de Pagamento
      cXMLRet := '<BusinessEvent>'
      cXMLRet +=    '<Entity>PaymentCondition</Entity>'
      cXMLRet +=    '<Identification>'
      cXMLRet +=       '<key name="InternalID">' + IntConExt(/*Empresa*/, /*Filial*/, oModelSE4:GetValue('E4_CODIGO'), /*Versão*/)[2] + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet +=    '<Event>' + cEvent + '</Event>' //Tipo de evento (upsert/delete)
      cXMLRet += '</BusinessEvent>'

      cXMLRet += '<BusinessContent>'
      cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
      cXMLRet +=    '<BranchId>' + xFilial('SE4') + '</BranchId>'
      cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + xFilial("SE4") + '</CompanyInternalId>'
      cXMLRet +=    '<Code>' + RTrim(oModelSE4:GetValue('E4_CODIGO')) + '</Code>'
      cXMLRet +=    '<InternalId>' + IntConExt(/*Empresa*/, /*Filial*/, oModelSE4:GetValue('E4_CODIGO'), /*Versão*/)[2] + '</InternalId>'
      cXMLRet +=    '<Description>' + AllTrim(oModelSE4:GetValue('E4_DESCRI')) + '</Description>'
      cXMLRet +=    '<TypePaymentCondition>' + Alltrim(oModelSE4:GetValue('E4_TIPO')) + '</TypePaymentCondition>'
      If !Empty(cDias)
         cXMLRet += '<DaysFirstDue>' + cDias + '</DaysFirstDue>' //Dias para primeira parcela
      EndIf
      If !Empty(cParcelas)
         cXMLRet += '<QuantityPlots>' + cParcelas + '</QuantityPlots>' //Quantidade de parcelas
      EndIf
      If !Empty(cIntervalo)
         cXMLRet += '<RangePlots>' + cIntervalo + '</RangePlots>' //Intervalo entre as parcelas
      EndIf
      If !Empty(cDiaSemana)
         cXMLRet += '<WeekDayFixed>' + cDiaSemana + '</WeekDayFixed>' //Dia da semana, quando este for fixo
      EndIf
      If !Empty(cDiaMes)
         cXMLRet += '<DayMonthFixed>' + cDiaMes + '</DayMonthFixed>' //Dia do mês, quando este for fixo
      EndIf
      If !Empty(cDiasDesc)
         cXMLRet += '<DaysCondition>' + cDiasDesc + '</DaysCondition>' //Contagem dos dias para as parcelas
      EndIf
      If !Empty(oModelSE4:GetValue('E4_DIADESC'))
         cXMLRet += '<FinancialDiscountDays>' + cValToChar(oModelSE4:GetValue('E4_DIADESC')) + '</FinancialDiscountDays>' //Dias para desconto financeiro
      EndIf
      If !Empty(oModelSE4:GetValue('E4_DESCFIN'))
         cXMLRet += '<PercentageDiscountDays>' + cValToChar(oModelSE4:GetValue('E4_DESCFIN')) + '</PercentageDiscountDays>' //Percentual de desconto financeiro
      EndIf
      If !Empty(oModelSE4:GetValue('E4_ACRSFIN'))
         cXMLRet += '<PercentageIncrease>' + cValToChar(oModelSE4:GetValue('E4_ACRSFIN')) + '</PercentageIncrease>' //Percentual de acréscimo
      EndIf

      If Len(aParcelas) > 0
         cXMLRet += '<Plots>'

         For nI := 1 To Len(aParcelas)
            cXMLRet += '<Due>'
            cXMLRet +=    '<DueDay>' + aParcelas[nI][1] + '</DueDay>'
            cXMLRet +=    '<Percentage>' + aParcelas[nI][2] + '</Percentage>'
            cXMLRet += '</Due>'
         Next nI

         cXMLRet += '</Plots>'
      EndIf

      cXMLRet += '</BusinessContent>'
   EndIf

   RestArea(aArea)

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} v3000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de condicoes de pagamento (SE4) utilizando o conceito de
mensagem unica.

@param Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Objeto, oXml, Objeto xml com a mensagem recebida.

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 25/06/2012
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caracter) Mensagem Xml para envio

@obs
O método irá retornar um objeto do tipo TOTVSBusinessEvent caso o tipo
da mensagem seja EAI_BUSINESS_EVENT ou um tipo TOTVSBusinessRequest
caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Static Function v3000(cXml, nTypeTrans, cTypeMsg, oXml)
   Local aArea         := GetArea()                 // Salva contexto atual
   Local lRet          := .T.                       // Retorna se a execucao foi bem sucedida ou nao
   Local cXmlRet       := ""                        // Xml de retorno da IntegDef
   Local cEvent        := "upsert"                  // Evento da transacao (Upsert/Delete)
   Local cError        := ""                        // Mensagem de erro do parse
   Local cWarning      := ""                        // Mensagem de warning do parse
   Local aMsgErro      := {}                        // Array com erro na validação do Model
   Local nI            := 1                         // Contadores de uso geral
   Local aParcelas     := {}                        // Array com regras do campo E4_COND
   Local cDias         := ""                        // Dias para o vencimento da primeira parcela
   Local cParcelas     := ""                        // Quantidade de parcelas
   Local cIntervalo    := ""                        // Intervalo entre cada parcela
   Local cCondicao     := ""                        // Guarda o campo E4_COND
   Local cDiaSemana    := ""                        // Dia da semana para o vencimento das parcelas
   Local cDiaMes       := ""                        // Dia do mês para o vencimento das parcelas
   Local cDiasDesc     := ""                        // Dias para desconto da parcela
   Local cCode         := ""                        // Codigo da condição de pagamento
   Local nMult         := 0                         // Multiplicador para o tipo 2
   Local cProduct      := ""                        // Marca, Referência (RM, PROTHEUS, DATASUL etc)
   Local cValInt       := ""                        // Valor interno no Protheus
   Local cValExt       := ""                        // Valor externo
   Local cAlias        := "SE4"                     // Alias da tabela no Protheus
   Local cField        := "E4_CODIGO"               // Campo identificador no Protheus
   Local oModel        := Nil                       // Model completo do MATA360
   Local oModelSE4     := Nil                       // Model com a master apenas
   Local aCondPgto     := {}                        // Array com os valores recebidos
   Local aAux          := {}                        // Array de uso geral
   Local cTemp         := ""                        // Utilizada para montagem da condição do tipo 8
   Local nOpcx         := 0                         // Operação realizada
   Local lInc          := .F.
   Local lMktPlace     := SuperGetMv("MV_MKPLACE",.F.,.F.)
   Local cCodSE4       := ''

   Private lMsErroAuto := .F.
   Private lMsHelpAuto := .T.

   // Se recebimento
   If nTypeTrans == TRANS_RECEIVE
      If cTypeMsg == EAI_MESSAGE_BUSINESS
         // Verifica se o InternalId foi informado
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
            cValExt := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
         Else
            lRet := .F.
            cXmlRet := STR0011 // "O código do InternalId é obrigatório!"
            Return {lRet, cXmlRet}
         EndIf

         // Verifica se a marca foi informada
         If Type("oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
            cProduct := oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text
         Else
            lRet := .F.
            cXmlRet := STR0012 // "O Produto é obrigatório!"
            Return {lRet, cXmlRet}
         EndIf

         // Verifica se a filial atual é a mesma filial de inclusão do cadastro
         aAux := IntChcEmp(oXml, cAlias, cProduct)
         If !aAux[1]
            lRet := aAux[1]
            cXmlRet := aAux[2]
            Return {lRet, cXmlRet}
         EndIf
         
         // Verifica se o código da Condição de Pagamento foi informado
         If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
            cCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
         Else
            lRet := .F.
            cXmlRet := STR0013 // "O Código da Condição de Pagamento é obrigatório!"
            Return {lRet, cXmlRet}
         EndIf

         // Obtém o valor interno da tabela XXF (de/para)
         aAux := IntConInt(cValExt, cProduct, /*Versão*/)

         // Se o evento é UPSERT
         If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
            If !aAux[1]
               // Inclusão
               nOpcx := 3
            Else
               // Alteração
               nOpcx := 4
            EndIf
         ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
            If aAux[1]
               // Exclusão
               nOpcx := 5
            Else
               lRet := .F.
               cXMLRet := (STR0003 + " -> " + cValExt) // Registro não encontrado!
               Return {lRet, cXmlRet}
            EndIf
         Else
            lRet := .F.
            cXmlRet := STR0014 // "O evento informado é inválido"
            Return {lRet, cXmlRet}
         EndIf
         
         dbSelectArea("SE4")
         SE4->(DbSetOrder(1)) // Filial + Condição (E4_FILIAL + E4_CODIGO)
         If nOpcx <> 3
		  		SE4->(dbSeek(xFilial("SE4") + PadR(aAux[2,3],TamSx3("E4_CODIGO")[1])))
            cCodSE4 := IIf( SE4->(Found() ), SE4->E4_CODIGO, cCode )
         Endif
		  
         // Carrega model com estrutura da Cond. de Pagamento
         oModel := FwLoadModel("MATA360")
         	  
         If nOpcx == 3
            oModel:SetOperation(MODEL_OPERATION_INSERT)
         Elseif nOpcx == 4
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
         Elseif nOpcx == 5
            oModel:SetOperation(MODEL_OPERATION_DELETE)
         Endif

         If oModel:nOperation != MODEL_OPERATION_DELETE
            // Recebimento dos dados
				lInc := oModel:nOperation == MODEL_OPERATION_INSERT
            
				//Verifica se utiliza inicialização padrão 
				If lInc
               cCodSE4 := I360GetCod( cCode )
               If !( Empty( cCodSE4 ) )
					   aAdd(aCondPgto, {"E4_CODIGO", cCodSE4, Nil})
					EndIf
				Else
					aAdd(aCondPgto, {"E4_CODIGO", cCodSE4, Nil})
				Endif

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)
               If Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text) > TamSX3("E4_DESCRI")[1]
                  lRet := .F.
                  cXmlRet := STR0015 + AllTrim(cValToChar(TamSX3("E4_DESCRI")[1])) + STR0016 // "A descrição da condição de pagamento no Protheus suporta no máximo [x] caracteres!"
                  Return {lRet, cXmlRet}
               EndIf

               aAdd(aCondPgto, {"E4_DESCRI", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil})
            Else
               lRet := .F.
               cXmlRet := STR0017 // "A descrição da condição de pagamento é obrigatória!"
               Return {lRet, cXmlRet}
            EndIf

            // Trata as parcelas recebidas
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots") != "U" .And. Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due") != "U"
               // Tratamento para parcelas informadas individualmente
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due") != "A"
                  XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due, "_DUE")
               EndIf

               For nI := 1 To Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due)
                  cCondicao += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due[nI]:_DueDay:Text
                  cTemp += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due[nI]:_Percentage:Text

                  If nI < Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Plots:_Due)
                     cCondicao += ','
                     cTemp += ','
                  EndIf

                  If Len(cCondicao) + 5 > TamSX3("E4_COND")[1]
                     lRet := .F.
                     cXmlRet := STR0018 + AllTrim(Str(TamSX3("E4_COND")[1])) + STR0019 // "A Condição de Pagamento para o Tipo 8 no Protheus não pode ultrapassar [x] caracteres."
                     Return {lRet, cXmlRet}
                  EndIf
               Next nI

               cCondicao := "[" + cCondicao + "],[" + cTemp + "]"

               aAdd(aCondPgto, {"E4_TIPO", "8", Nil}) // Grava apenas tipo 8
            Else
               //Tratamento para parcelas informadas de forma padronizada
               // Quantidade de parcelas
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_QuantityPlots:Text") != 'U' .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_QuantityPlots:Text)
                  cParcelas := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_QuantityPlots:Text
               Else
                  lRet    := .F.
                  cXmlRet := STR0020 // "Quantidade de parcelas não informada!"
                  Return {lRet, cXmlRet}
               EndIf

               // Quantidade de parcelas
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RangePlots:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RangePlots:Text)
                  cIntervalo += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RangePlots:Text
               Else
                  lRet := .F.
                  cXmlRet := STR0021 // "Intervalo de dias não informado!"
                  Return {lRet, cXmlRet}
               EndIf

               // Dias de carência para a primeira parcela
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysFirstDue:Text") != 'U' .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysFirstDue:Text)
                  cDias += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysFirstDue:Text
               Else
                  cDias += "0"
               EndIf

               // Dia da semana
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WeekDayFixed:Text") != 'U' .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WeekDayFixed:Text)
                  cDiaSemana += oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_WeekDayFixed:Text
               EndIf

               If Empty(cDiaSemana)
                  aAdd(aCondPgto, {"E4_TIPO", "5", Nil})
                  cCondicao := cDias + "," + cParcelas + "," + cIntervalo
               Else
                  aAdd(aCondPgto, {"E4_TIPO", "6", Nil})
                  cCondicao := cParcelas + "," + cDias + "," + cDiaSemana + ',' + cIntervalo
               EndIf
            EndIf

            aAdd(aCondPgto, {"E4_COND", cCondicao, Nil})

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscountDays:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscountDays:Text)
               aAdd(aCondPgto, {"E4_DIADESC", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FinancialDiscountDays:Text), Nil})
            EndIf

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageDiscountDays:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageDiscountDays:Text)
               aAdd(aCondPgto, {"E4_DESCFIN", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageDiscountDays:Text), Nil})
            EndIf

            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageIncrease:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageIncrease:Text)
               aAdd(aCondPgto, {"E4_ACRSFIN", Val(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageIncrease:Text), Nil})
            EndIf

            // Dias da Condição
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysCondition:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysCondition:Text)
               cDaysCondition := BuscaDC(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DaysCondition:Text)

               If !Empty(cDaysCondition)
                  aAdd(aCondPgto, {"E4_DDD", cDaysCondition, Nil})
               Else
                  lRet    := .F.
                  cXmlRet := STR0022 + Chr(10) + STR0023 // "Dias da condição inválido! [quebra linha] Os valores aceitos pelo Protheus são: 0=Data do Dia; 1=Fora o Dia; 7=Fora Semana;  10=Fora Dezena; 15=Fora quinzena; 30=Fora Mes"
                  Return {lRet, cXmlRet}
               EndIf
            EndIf
         Else
         		If aAux[1]
         			aAdd(aCondPgto, {"E4_CODIGO", aAux[2,3], Nil})
         		Endif
         EndIf

         oModel:Activate()
         oModelSE4 := oModel:GetModel("SE4MASTER") // Model parcial da Master (SE4)

         // Obtém a estrutura de dados
         aAux := oModelSE4:GetStruct():GetFields()

         For nI := 1 To Len(aCondPgto)
            // Verifica se os campos passados existem na estrutura do modelo
            If aScan(aAux, {|x| AllTrim(x[3]) == AllTrim(aCondPgto[nI][1])}) > 0
               // É feita a atribuição do dado ao campo do Model
               If oModel:nOperation <> MODEL_OPERATION_DELETE
                  If !oModel:SetValue('SE4MASTER', aCondPgto[nI][1], aCondPgto[nI][2]) .And. (aCondPgto[nI][1] != "E4_CODIGO" .Or. oModel:nOperation != MODEL_OPERATION_UPDATE)
                     lRet := .F.
                     cXmlRet := STR0034 + AllToChar(aCondPgto[nI][2]) + STR0035 + aCondPgto[nI][1] + "." //"Não foi possível atribuir o valor " " ao campo "
                     Return {lRet, cXmlRet}
                  EndIf
               Endif
            EndIf
         Next nI

         // Se os dados não são válidos
         If !oModel:VldData()
            // Obtém o log de erros
            aMsgErro := oModel:GetErrorMessage()

            cXmlRet := STR0036 + AllToChar(aMsgErro[6]) + CRLF //"Mensagem do erro: "
            cXmlRet += STR0037 + AllToChar(aMsgErro[7]) + CRLF //"Mensagem da solução: "
            cXmlRet += STR0038 + AllToChar(aMsgErro[8]) + CRLF //"Valor atribuído: "
            cXmlRet += STR0039 + AllToChar(aMsgErro[9]) + CRLF //"Valor anterior: "
            cXmlRet += STR0040 + AllToChar(aMsgErro[1]) + CRLF //"Id do formulário de origem: "
            cXmlRet += STR0041 + AllToChar(aMsgErro[2]) + CRLF //"Id do campo de origem: "
            cXmlRet += STR0042 + AllToChar(aMsgErro[3]) + CRLF //"Id do formulário de erro: "
            cXmlRet += STR0043 + AllToChar(aMsgErro[4]) + CRLF //"Id do campo de erro: "
            cXmlRet += STR0044 + AllToChar(aMsgErro[5]) //"Id do erro: "

            lRet := .F.
            Return {lRet, cXmlRet}
         Else
            // Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
            oModel:CommitData()
            
            // Obtém o InternalId
            cValInt := IntConExt(/*Empresa*/, /*Filial*/, SE4->E4_CODIGO, /*Versão*/)[2]
         EndIf

         If lRet
	         // Se o evento é diferente de delete
	         If oModel:nOperation != MODEL_OPERATION_DELETE
	            // Grava o registro na tabela XXF (de/para)
	            CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
	         Else
	            // Exclui o registro na tabela XXF (de/para)
	            CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
	         EndIf
	
	         // Monta o XML de retorno
	         cXMLRet := "<ListOfInternalId>"
	         cXMLRet +=     "<InternalId>"
	         cXMLRet +=         "<Name>" + 'PaymentCondition' + "</Name>"
	         cXMLRet +=         "<Origin>" + cValExt + "</Origin>"
	         cXMLRet +=         "<Destination>" + cValInt + "</Destination>"
	         cXMLRet +=     "</InternalId>"
	         cXMLRet += "</ListOfInternalId>"
	      Endif
	      
      ElseIf cTypeMsg == EAI_MESSAGE_WHOIS // Recebimento da WhoIs
         cXmlRet := "1.000|2.000|3.000"
      ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE // Recebimento da Response Message
         // Se não houve erros na resposta
         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
            // Verifica se a marca foi informada
            If ValType("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cProduct := Upper( oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text )
            Else
               lRet    := .F.
               cXmlRet := STR0024 // "Erro no retorno. O Product é obrigatório!"
               Return {lRet, cXmlRet}
            EndIf
			 
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") <> "U"
	            // Verifica se o código interno foi informado
	            If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
	               cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0025 // "Erro no retorno. O OriginalInternalId é obrigatório!"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Verifica se o código externo foi informado
	            If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
	               cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0026 // "Erro no retorno. O DestinationInternalId é obrigatório"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Obtém a mensagem original enviada
	            If ValType("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0027 // "Conteúdo do MessageContent vazio!"
	               Return {lRet, cXmlRet}
	            EndIf

				  // Faz o parse do XML em um objeto
	            oXML := XmlParser(cXML, "_", @cError, @cWarning)
	
	            If Empty(oXML) .And. "UTF-8" $ Upper(cXML)
	               oXML := xmlParser(EncodeUTF8(cXML), "_", @cError, @cWarning)
	            EndIf
	
	            // Se não houve erros no parse
	            If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
	               If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
	                  // Insere / Atualiza o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
	               ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
	                  // Exclui o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
	               Else
	                  lRet := .F.
	                  cXmlRet := STR0028 // "Evento do retorno inválido!"
	               EndIf
	            Else
	               lRet := .F.
	               cXmlRet := STR0029 // "Erro no parser do retorno!"
	               Return {lRet, cXmlRet}
	            EndIf
	         Endif
         Else
            // Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               // Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            // Percorre o array para obter os erros gerados
            For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + CRLF
            Next nI

            lRet := .F.
            cXmlRet := cError
         EndIf
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      //Carrega Model do cadastro de Condição de Pagamento
      oModel    := FWModelActive()
      If oModel == nil
         oModel   := FWLoadModel( 'MATA360' )
         oModel:Activate()
      EndIf
      oModelSE4 := oModel:GetModel('SE4MASTER')

      //Verica operação realizada
      Do Case
         Case oModel:nOperation == MODEL_OPERATION_INSERT
            cEvent := 'upsert' //Inclusão
         Case oModel:nOperation == MODEL_OPERATION_UPDATE
            cEvent := 'upsert' //Alteração
         Case oModel:nOperation == MODEL_OPERATION_DELETE
            cEvent := 'delete' //Exclusão
            CFGA070Mnt(,"SE4","E4_CODIGO",,IntConExt(,,oModelSE4:GetValue('E4_CODIGO'),)[2],.T.)
      EndCase

      //Verica operação realizada
      If oModel:nOperation != MODEL_OPERATION_DELETE
         //Carrega os dados da condição de acordo com o tipo para montar o Xml
         Do Case
            Case oModelSE4:GetValue('E4_TIPO') == '1'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MontaVencimentos(MntParcela(cCondicao), 1)
               cParcelas  := cValToChar(Len(aParcelas))
               cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))

            Case oModelSE4:GetValue('E4_TIPO') == '2'
               nMult      := Val(RTrim(oModelSE4:GetValue('E4_COND')))
               cCondicao  := oModelSE4:GetValue('E4_CODIGO')
               cDias      := SubStr(cCondicao, 1, 1)
               cDias      := cValToChar(Val(cDias) * nMult)
               cParcelas  := SubStr(cCondicao, 2, 1)
               cIntervalo := SubStr(cCondicao, 3, 1)
               cIntervalo := cValToChar(Val(cIntervalo) * nMult)
               aParcelas  := {}

            Case oModelSE4:GetValue('E4_TIPO') == '3'
            	cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))        
               cDias      := StrTokArr(cCondicao, ',')[2]                                                
               cParcelas  := StrTokArr(cCondicao, ',')[1]                                                
               cCondicao  := oModelSE4:GetValue('E4_CODIGO')                                                                                                                                   
               aParcelas  := Condicao(100,cCondicao,0,dDataBase,0)                                                                     
               aParcelas  := aEval(aParcelas,{|x| x[1] := AllTrim(Str(x[1]-dDataBase))}) 	//-- Altera o campo de data para string
               aParcelas  := aEval(aParcelas,{|x| x[2] := AllTrim(Str(x[2]))}) 

            Case oModelSE4:GetValue('E4_TIPO') == '4'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MntParcela(cCondicao)
               cParcelas  := aParcelas[1][1]
               cIntervalo := aParcelas[2][1]
               cDiaSemana := aParcelas[3][1]
               cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))
               aParcelas  := {}

            Case oModelSE4:GetValue('E4_TIPO') == '5'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MntParcela(cCondicao)
               cDias      := aParcelas[1][1]
               cParcelas  := aParcelas[2][1]
               cIntervalo := aParcelas[3][1]
               aParcelas  := {}

            Case oModelSE4:GetValue('E4_TIPO') == '6'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MntParcela(cCondicao)
               cParcelas  := aParcelas[1][1]
               cDias      := aParcelas[2][1]
               cDiaSemana := aParcelas[3][1]
               cIntervalo := aParcelas[4][1]
               aParcelas  := {}

            Case oModelSE4:GetValue('E4_TIPO') == '7'
            	If lMktPlace
   					cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
	   				cDias      := StrTokArr(cCondicao, ',')[2]                                                
   					cParcelas  := StrTokArr(cCondicao, ',')[1]
	   				cCondicao  := oModelSE4:GetValue('E4_CODIGO')                                                                                                                                  
		   			aParcelas  := Condicao(100,cCondicao,0,dDataBase,0)                                                                     
			   		aParcelas  := aEval(aParcelas,{|x| x[1] := AllTrim(Str(x[1]-dDataBase))}) 	//-- Altera o campo de data para string
   					aParcelas  := aEval(aParcelas,{|x| x[2] := AllTrim(Str(x[2]))})                                                 
   				Endif
            Case oModelSE4:GetValue('E4_TIPO') == '8'
               cCondicao  := RTrim(oModelSE4:GetValue('E4_COND'))
               aParcelas  := MntParcela(cCondicao, 8)
               cParcelas  := cValToChar(Len(aParcelas))
               cDias      := DiasDaCond(oModelSE4:GetValue('E4_DDD'))

            Case oModelSE4:GetValue('E4_TIPO') == '9'

            Case oModelSE4:GetValue('E4_TIPO') == 'A'

            Case oModelSE4:GetValue('E4_TIPO') == 'B'
         EndCase
      EndIf

      //Montagem da mensagem de Condições de Pagamento
      cXMLRet := '<BusinessEvent>'
      cXMLRet +=    '<Entity>PaymentCondition</Entity>'
      cXMLRet +=    '<Identification>'
      cXMLRet +=       '<key name="InternalID">' + IntConExt(/*Empresa*/, /*Filial*/, oModelSE4:GetValue('E4_CODIGO'), /*Versão*/)[2] + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet +=    '<Event>' + cEvent + '</Event>' //Tipo de evento (upsert/delete)
      cXMLRet += '</BusinessEvent>'

      cXMLRet += '<BusinessContent>'
      cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
      cXMLRet +=    '<BranchId>' + xFilial('SE4') + '</BranchId>'
      cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + xFilial("SE4") + '</CompanyInternalId>'
      cXMLRet +=    '<Code>' + RTrim(oModelSE4:GetValue('E4_CODIGO')) + '</Code>'
      cXMLRet +=    '<InternalId>' + IntConExt(/*Empresa*/, /*Filial*/, oModelSE4:GetValue('E4_CODIGO'), /*Versão*/)[2] + '</InternalId>'
      cXMLRet +=    '<Description>' + AllTrim(oModelSE4:GetValue('E4_DESCRI')) + '</Description>'
      cXMLRet +=    '<TypePaymentCondition>' + Alltrim(oModelSE4:GetValue('E4_TIPO')) + '</TypePaymentCondition>'
      If !Empty(cDias)
         cXMLRet += '<DaysFirstDue>' + cDias + '</DaysFirstDue>' //Dias para primeira parcela
      EndIf
      If !Empty(cParcelas)
         cXMLRet += '<QuantityPlots>' + cParcelas + '</QuantityPlots>' //Quantidade de parcelas
      EndIf
      If !Empty(cIntervalo)
         cXMLRet += '<RangePlots>' + cIntervalo + '</RangePlots>' //Intervalo entre as parcelas
      EndIf
      If !Empty(cDiaSemana)
         cXMLRet += '<WeekDayFixed>' + cDiaSemana + '</WeekDayFixed>' //Dia da semana, quando este for fixo
      EndIf
      If !Empty(cDiaMes)
         cXMLRet += '<DayMonthFixed>' + cDiaMes + '</DayMonthFixed>' //Dia do mês, quando este for fixo
      EndIf
      If !Empty(cDiasDesc)
         cXMLRet += '<DaysCondition>' + cDiasDesc + '</DaysCondition>' //Contagem dos dias para as parcelas
      EndIf
      If !Empty(oModelSE4:GetValue('E4_DIADESC'))
         cXMLRet += '<FinancialDiscountDays>' + cValToChar(oModelSE4:GetValue('E4_DIADESC')) + '</FinancialDiscountDays>' //Dias para desconto financeiro
      EndIf
      If !Empty(oModelSE4:GetValue('E4_DESCFIN'))
         cXMLRet += '<PercentageDiscountDays>' + cValToChar(oModelSE4:GetValue('E4_DESCFIN')) + '</PercentageDiscountDays>' //Percentual de desconto financeiro
      EndIf
      If !Empty(oModelSE4:GetValue('E4_ACRSFIN'))
         cXMLRet += '<PercentageIncrease>' + cValToChar(oModelSE4:GetValue('E4_ACRSFIN')) + '</PercentageIncrease>' //Percentual de acréscimo
      EndIf

      If Len(aParcelas) > 0
         cXMLRet += '<Plots>'

         For nI := 1 To Len(aParcelas)
            cXMLRet += '<Due>'
            cXMLRet +=    '<DueDay>' + aParcelas[nI][1] + '</DueDay>'
            cXMLRet +=    '<Percentage>' + aParcelas[nI][2] + '</Percentage>'
            cXMLRet += '</Due>'
         Next nI

         cXMLRet += '</Plots>'
      EndIf

      cXMLRet += '</BusinessContent>'
   EndIf

   RestArea(aArea)

Return {lRet, cXmlRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} MntParcela
Monta array com os prazos das parcelas do campo E4_COND.

@param Caracter, cCondicao, Conteudo do campo E4_COND
@param Numérico, nTipo, Tipo da condição de pagamento (E4_TIPO)

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 25/06/2012

@return Array, Array com os valores da condição.

@obs
Alterado para contemplar o tipo 8
Mateus Gustavo de Freitas e Silva 19/07/2012
/*/
//-------------------------------------------------------------------
Static Function MntParcela(cCondicao, nTipo)
   Local nI           := 1  //Controla a posicao do ponteiro que varre os prazos em cCondicao
   Local nInicio      := 1  //Indica a posicao inicial para o SubStr separar o prazo
   Local nQtde        := 1  //Indica a quantidade de caracteres que o SubStr deve pegar
   Local aParcelas    := {} //Array com os prazos da condicao
   local aVencimentos := {} //Array com as datas de vencimento
   Local aPercentuais := {} //Array com os percentuais das parcelas

   If Empty(nTipo) //Parâmetro não informado
      //Varre o conteudo de cCondicao com conteudo do E4_COND
      For nI := 1 To Len(cCondicao)
         //Se caracter atual for uma vírgula, não faz nada
         If (SubStr(cCondicao, nI, 1) != ',')
            If (SubStr(cCondicao, nI + 1, 1) == ',') .Or. ((nI + 1) > Len(cCondicao))
               //Adiciona no array o prazo de vencimento de acordo com nInicio e nQtde
               aAdd(aParcelas, {SubStr(cCondicao, nInicio, nQtde), ''})
               nInicio := nI + 2   //Atualiza nInicio com a posicao inicial do proximo prazo
               nQtde := 0          //Zera nQtde para contar quantos digitos tem o proximo prazo
            EndIf

            nQtde += 1             //Incrementa a quantidade de digitos para o SubStr
         EndIf
      Next nI
   ElseIf nTipo = 8
      For nI := 1 To Len(AllTrim(cCondicao))
         If (SubStr(cCondicao, nI, 1) != '[')
            If (SubStr(cCondicao, nI + 1, 1) == ']') .Or. ((nI + 1) > Len(cCondicao))
               If Empty(aVencimentos)
                  aVencimentos := StrTokArr(SubStr(cCondicao, nInicio, nQtde), ',')
               Else
                  aPercentuais := StrTokArr(SubStr(cCondicao, nInicio, nQtde - 2), ',')
                  Exit
               EndIf

               nQtde := 0
            EndIf

            nQtde += 1
         Else
            nInicio := nI + 1
         EndIf
      Next nI

      For nI := 1 To Len(aVencimentos)
         aAdd(aParcelas, {aVencimentos[nI], aPercentuais[nI]})
      Next nI
   EndIf
Return aParcelas

//-------------------------------------------------------------------
/*/{Protheus.doc} DiasDaCond
Funcao que retorna o número de dias de prazo para o início da primeira
parcela da condição conforme o campo E4_DDD.

@param Caracter, CCond, Valor do campo E4_DDD.

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 25/06/2012

@return Caracter, Quantidade de dias de prazo.
/*/
//-------------------------------------------------------------------
Static Function DiasDaCond(cCond)
   Local cDias := ''

   Do Case
      Case cCond == 'D'
         cDias := '0'
      Case cCond == 'L'
         cDias := '1'
      Case cCond == 'S'
         cDias := '7'
      Case cCond == 'Q'
         cDias := '15'
      Case cCond == 'F'
         cDias := '30'
      Case cCond == 'Z'
         cDias := '10'
   EndCase
Return cDias

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaVencimentos
Monta array com os prazos das parcelas do campo E4_COND.

@param Caracter, cCondicao, Conteudo do campo E4_COND
@param Numérico, nTipo, Tipo da condição de pagamento (E4_TIPO)

@author Mateus Gustavo de Freitas e Silva
@version P11
@since 26/06/2012

@return Array, Array com os valores da condição.
/*/
//-------------------------------------------------------------------
Static Function MontaVencimentos(aParcelas, nTipo)
   Local nI            := 1
   Local nParcelas     := Len(aParcelas)
   Local nTotal        := 0
   Local nValorParcela := Round(100 / nParcelas, 2)

   Do Case
      Case nTipo == 1 .Or. nTipo == 7
         For nI := 1 To nParcelas -1
            aParcelas[nI][2] := cValToChar(nValorParcela)
            nTotal += nValorParcela
         Next nI

         aParcelas[nParcelas][2] := cValToChar(100 - nTotal)
   EndCase
Return aParcelas

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaDC
De/para para preenchimento do campo E4_DDD

@param Caracter, cTipo, Tipo recebido na mensagem

@author Leandro Luiz da Cruz
@version P11
@since 25/10/2012

@return Caracter, Valor transformado
/*/
//-------------------------------------------------------------------
Static Function BuscaDC(cTipo)
   Local cResult := ''

   Do Case
      Case cTipo == '1'
         cResult := 'D' // Data do Dia
      Case cTipo == '2'
         cResult := 'L' // Fora o Dia
      Case cTipo == '3'
         cResult := 'S' // Fora Semana
      Case cTipo == '4'
         cResult := 'Q' // Fora Quinzena
      Case cTipo == '5'
         cResult := 'F' // Fora Mês
      Case cTipo == '6'
         cResult := 'Z' // Fora Dezena
   EndCase
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntConExt
Monta o InternalID da Condição de Pagamento de acordo com o código
passado no parâmetro.

@param Caracter, cEmpresa, Código da empresa (Default cEmpAnt)
@param Caracter, cFil, Código da Filial (Default cFilAnt)
@param Caracter, cCondPgto, Código da Condição de Pagamento
@param Caracter, cVersao, Versão da mensagem única (Default 2.000)

@author Leandro Luiz da Cruz
@version P11
@since 08/02/2013
@return  Array, Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado.
No segundo parâmetro uma variável string com o InternalID
montado.

@sample
IntConExt(, , '001') irá retornar {.T., '01|01|001'}
/*/
//-------------------------------------------------------------------
Function IntConExt(cEmpresa, cFil, cCondPgto, cVersao)
   Local   aResult  := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('SE4')
   Default cVersao  := '2.000'

   Do Case
      Case cVersao == '1.000'
         aAdd(aResult, .T.)
         aAdd(aResult, PadR(cFil, TamSX3('E4_FILIAL')[1]) + '|' + PadR(cCondPgto, TamSX3('E4_CODIGO')[1]))
      Case cVersao == '2.000'
         aAdd(aResult, .T.)
         aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCondPgto))
      Case cVersao == '3.000'
         aAdd(aResult, .T.)
         aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCondPgto))      
      OtherWise
         aAdd(aResult, .F.)
         aAdd(aResult, STR0045 + Chr(10) + STR0046) //"Versão da condição de pagamento não suportada." "As versões suportadas são: 1.000, 2.000"
   EndCase
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntConInt
Recebe um InternalID e retorna o código da Condição de Pagamento.

@param Caracter, cInternalID, InternalID recebido na mensagem.
@param Caracter, cRefer, Produto que enviou a mensagem
@param Caracter, cVersao, Versão da mensagem única (Default 2.000)

@author Leandro Luiz da Cruz
@version P11
@since 08/02/2013
@return Array, Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado no de/para.
No segundo parâmetro uma variável array com a empresa,
filial e o Código da Condição de Pagamento.

@sample
IntConInt('01|01|001') irá retornar {.T., {'01', '01', '001'}}
/*/
//-------------------------------------------------------------------
Function IntConInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'SE4'
   Local   cField   := 'E4_CODIGO'
   Default cVersao  := '2.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0047 + " -> " + cInternalID) //"Registro não encontrado no de/para!"
   Else
      Do Case
         Case cVersao == '1.000'
            aAdd(aResult, .T.)
            aAdd(aTemp, SubStr(cTemp, 1, 2))
            aAdd(aTemp, SubStr(cTemp, 3, TamSX3('E4_CODIGO')[1]))
            aAdd(aResult, aTemp)
         Case cVersao == '2.000'
            aAdd(aResult, .T.)
            aTemp := Separa(cTemp, '|')
            aAdd(aResult, aTemp)
         Case cVersao == '3.000'
            aAdd(aResult, .T.)
            aTemp := Separa(cTemp, '|')
            aAdd(aResult, aTemp)         
         OtherWise
            aAdd(aResult, .F.)
            aAdd(aResult, STR0045 + Chr(10) + STR0046) //"Versão da condição de pagamento não suportada." "As versões suportadas são: 1.000, 2.000"
      EndCase
   EndIf
Return aResult

/*/{Protheus.doc} I360GetCod
   Funcao Responsavel Por Validar Tamanho do Codigo da Cond.Pagto Recebido via Integracao, sendo que se o Codigo Recebido For Maior que o Tamanho
   do Campo na Base de Dados Gera um Codigo Interno para Inclusao e Grava De/Para com Origem e Destino
   @type  Function
   @author Paulo V. Beraldo
   @since Mar/2021
   @version 1.00
   @param cCodeInteg , Caracter, Codigo da Cond.Pagto Recebido Via Integracao
   @return cReturn   , Caracter, Codigo da Cond.Pagto para Ser Usado Internamente
/*/
Function I360GetCod( cCodeInteg )
Local lRun     := .T.
Local aArea    := GetArea()
Local aAreaSE4 := SE4->( GetArea() )
Local cReturn  := ''
Local cAuxCod  := ''

Default cCodeInteg := ''

dbSelectArea( 'SE4' )
SE4->( dbSetOrder( 1 ) )

If Empty( GetSx3Cache( 'E4_CODIGO', 'X3_RELACAO' ) )
   If Len( AllTrim( cCodeInteg ) ) <= TamSx3( 'E4_CODIGO' )[1]
      cReturn := cCodeInteg
   Else
      cAuxCod := GetSx8Num( 'SE4', 'E4_CODIGO' )
      While lRun
         If SE4->( dbSeek( FWxFilial( 'SE4' ) + cAuxCod ) )
            ConfirmSx8()
            cAuxCod := GetSx8Num( 'SE4', 'E4_CODIGO' )
         Else
            cReturn := cAuxCod
            lRun := .F.
         EndIf
      End
   EndIf

EndIf

RestArea( aAreaSE4 )
RestArea( aArea )
Return cReturn