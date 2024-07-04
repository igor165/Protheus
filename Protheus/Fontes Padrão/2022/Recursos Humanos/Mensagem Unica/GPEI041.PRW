#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'FWADAPTEREAI.CH' 
#INCLUDE "FWMVCDEF.CH"

Static cVerSend 	:= "1.000"
Static nAfastEAI	:= SuperGetMV("MV_AFASEAI", , 0) // Quantidade mínima de dias para enviar o afastamento via EAI

/*/{Protheus.doc} GPEI041
Funcao de integracao com o adapter EAI para envio e recebimento de
alteracoes no campo RA_SITFOLH do cadastro de funcionários (SRA)
 utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@version P11
@since   28/12/2014
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caracter) Mensagem Xml para envio

/*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEI041    ³Autor  ³Alberto M.         v.I         ³ Data ³06/01/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mensagem Unica EmployeeSituation - Integracao PROTHEUS X PIMS        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA240 - Inclusao de Afastamentos.                                  ³±±
±±³          ³ GPEM040 - Calculo de Rescisao.                                       ³±±
±±³          ³ GPEM630 - Calculo de Rescisao Coletiva.                              ³±±
±±³          ³ GPEM030 - Calculo de Ferias.                                         ³±±
±±³          ³ GPEM060 - Calculo de Ferias Coletivas.                               ³±±
±±³          ³ GPEA810 - Reintegracao de funcionario.                               ³±±
±±³          ³ GPEA010 - Funcionario.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÏÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Function GPEI041( cXml, nType, cTypeMsg, cVersaoMsg )

Local lRet        := .T.
Local cEvent      := ''
Local cOrigem     := ''
Local nTypeTrans  := nType
Local cXMLRet     := ''
Local cError      := ''
Local cWarning    := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para a gravacao da tabela XXF(de/para).                    	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cProduct      := ''
Local cValInt       := ''
Local cValExt       := ''
Local cXmlContent   := ''
Local cAliasXXF     := 'SRA'
Local cField        := 'RA_SITFOLH'
Local oModel
Local nOperacao

Default cXml        := ''
Default nType       := 1
Default cTypeMsg    := '' 
Default cVersaoMsg  := ''

Private oGridSR8 	:= Nil
Private aCodFol		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento da recepcao das mensagens.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTypeTrans == TRANS_RECEIVE
	Do Case

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da mensagem que solicita as versoes permitidas.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTypeMsg == EAI_MESSAGE_WHOIS
			lRet := .T.
			cXMLRet := cVerSend

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		Case cTypeMsg == EAI_MESSAGE_RECEIPT


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da mensagem enviada pelo PIMS.                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTypeMsg == EAI_MESSAGE_BUSINESS

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da response message enviada pelo PIMS, verifica se houve     ³ 
		//algum erro na gravação do lado do PIMS.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTypeMsg == EAI_MESSAGE_RESPONSE
		
			oXml := XmlParser(cXml, "_", @cError, @cWarning)
		
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o Parse foi efetuado corretamente.                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If(Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK")
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificação do produto                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If(Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. ;
			   			 !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text))
				
					cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				EndIf
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//Verificação do InternalID                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. (Type("oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") != "U" .And.;
				 				      !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text))
				
					cValInt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
				EndIf
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				////Verificação do InternalID Destination.                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. (Type("oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") != "U" .And. ;
				 					   !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text))
				
					cValExt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
				EndIf
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//Verificação da ContentMessage.                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. (Type("oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. ;
				 					   !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text))
				
					cXmlContent := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//Insere / Atualiza o registro na tabela XXF (de/para)                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If lRet
					CFGA070Mnt(cProduct, cAliasXXF, cField, cValExt, cValInt, .F.,)
				EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//Tratamento para o erro no arquivo de XML recebido.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Else
			cAux := "Operação não realizada - Problemas na integração: "
			If IsInCallStack('GPEA240')
				lErroInt := .T.
			EndIf
			//Verifica o erro que aconteceu na integracao.
			cAux += oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message:Text
			Alert(cAux)
		EndIf
		
	EndCase
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento do envio da mesagem EmployeeSituation.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf nTypeTrans == TRANS_SEND

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica de onde foi chamada a FwIntegDef e se foi exclusao ou inclusao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IsInCallStack('GPEM630')
		cOrigem   := 'GPEM630'
		cEvent    :=  'upsert'
			
	Else
	
		Do Case
			//Afastamento
			Case IsInCallStack('GPEA240') .OR. IsInCallStack('MDTA410')	//MDTA = ROTINA DE ATESTADO MEDIDO DO SIGAMDT
				cOrigem   	:= 'GPEA240'
				oModel 		:= FWModelActive()  
				nOperacao  	:= oModel:GetOperation()
				oGridSr8 	:= oModel:GetModel('GPEA240_SR8') 
				cEvent    	:= If(nOperacao == MODEL_OPERATION_DELETE .Or. lExcAfastPIMS , 'delete' , 'upsert' )
				If !FP_CodFol( @aCodFol , xFilial("SRV"))
					aCodFol := {}
				EndIf	
			//Rescisao
			Case IsInCallStack('GPEM040')
				cOrigem   := 'GPEM040'
				oModel := FWModelActive()  
				nOperacao  	:= oModel:GetOperation()  
				cEvent    := If(nOperacao == MODEL_OPERATION_DELETE  , 'delete' , 'upsert' )
				dbSelectArea("SRA")
				SRA->(dbSetOrder(1))
				SRA->(dbSeek(SRG->RG_FILIAL+SRG->RG_MAT))
				cFilAnt := SRA->RA_FILIAL
			//Ferias
			Case IsInCallStack('GPEM030')
				cOrigem   := 'GPEM030'
				cEvent    := If(lExcFerPIMS , 'delete' , 'upsert' )
				
			//Ferias Coletivas.
			Case IsInCallStack('GPEM060')
				cOrigem   := 'GPEM060'
				
				If Type('lExcFerPIMS') <> "U" 
					cEvent := If(lExcFerPIMS , 'delete' , 'upsert' )
				Else
					cEvent := 'upsert'
				EndIf
			
			//Reintegracao.	
			Case IsInCallStack('GPEA810')
				cOrigem   := 'GPEA810'
				cEvent    := 'upsert'
				
			//Alteração
			Case IsInCallStack('GPEA010')
				cOrigem   := 'GPEA010'
				cEvent    := 'upsert'
			Otherwise
				cOrigem   := 'GPEM040'
				cEvent    := 'upsert'
				dbSelectArea("SRA")
				SRA->(dbSetOrder(1))
				SRA->(dbSeek(SRG->RG_FILIAL+SRG->RG_MAT))
				cFilAnt := SRA->RA_FILIAL
		EndCase
	EndIf

	If cEvent == 'delete'
	
			//Exclusao da tabela XXF(de/para)
			CFGA070Mnt(Nil,;//Marca
			 	       cAliasXXF,;//Alias
			 	       cField,;//Campo
			 	       Nil,;//Id Externo
			 	       InternalID(cOrigem),;//InternalId.
			 	       .T.)//.T. para exclusao.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Construcao do XML de envio(Informacoes do evento).                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cXMLRet += '<BusinessEvent>'
	cXMLRet +=    '<Entity>EmployeeSituations</Entity>'
	cXMLRet +=    '<Event>' + cEvent+ '</Event>'
	cXMLRet += 	'<Identification>'
	cXMLRet += 		'<key name="InternalID"></key>' 
	cXMLRet += 	'</Identification>'
	cXMLRet += '</BusinessEvent>'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Construcao do XML de envio(Conteudo do negocio).                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cXMLRet += '<BusinessContent>'
	cXMLRet += '<Situation>'
	cXMLRet += 	'<ListOfEmployee>'
	cXMLRet += 		'<Employee>'
	cXMLRet += 			'<CompanyId>' + cEmpAnt + '</CompanyId>' //Empresa. 
	cXMLRet += 			'<BranchId>' + cFilAnt + '</BranchId>'//Filial.
	cXMLRet += 			'<CompanyInternalId>' + cEmpAnt + "|" + /*AllTrim*/(cFilAnt) + '</CompanyInternalId>'//InternalId da chave completa de empresa do produto.
	cXMLRet += 			'<InternalId>' + InternalID(cOrigem) + '</InternalId>'//InternalId do Code.
	cXMLRet += 			'<EmployeeCode>' + SRA->RA_MAT + '</EmployeeCode>'//Código do Funcionário.
	cXMLRet += 			'<WorkCenterCode></WorkCenterCode>'//Centro de Trabalho.
	cXMLRet += 			'<SiteCode></SiteCode>'//Código do Estabelecimento do Funcionário.
	cXMLRet += 			'<ListOfSituation>'
	cXMLRet +=				'<Situation>'
	cXMLRet += 					'<CommencementDate>' + CommencDate(cOrigem) + '</CommencementDate>'//Data de início da situação.
	cXMLRet += 					'<SituationLastDay>' + SitLastDay(cOrigem) + '</SituationLastDay>'//Data do último dia da situação.
	cXMLRet += 					'<INSSPaymentCommencement>' + /*INSSPayCom(cOrigem)*/'</INSSPaymentCommencement>'
	cXMLRet += 					'<OriginSituation>' + OriginSitu(cOrigem) + '</OriginSituation>'//Origem da Situação.
	cXMLRet += 					'<SituationDay>' + SituatDay(cOrigem) + '</SituationDay>'//Número de dias em que o funcionário se encontra na situação.
	cXMLRet += 					'<SituationTime></SituationTime>'//Quantidade de horas na situação.
	cXMLRet += 					'<SituationScheduleEnd></SituationScheduleEnd>'//Número Horario Termino Situacao Afastamento.
	cXMLRet += 					'<CIDCode>' + CIDCode(cOrigem) + '</CIDCode>'//Código do acidente ou doença para as situações de afastamento por doença.
	cXMLRet += 					'<CommencementSchedule></CommencementSchedule>'//Número Horario Inicio Situacao Afastamento.
	cXMLRet += 					'<SituationInformation>'
	cXMLRet +=                     '<SituationCode>' + SitCode(cOrigem) + '</SituationCode>'
	cXMLRet += 						'<SituationMeaning>' + SituatMean(cOrigem,cEvent) + '</SituationMeaning>'
	cXMLRet += 						'<AbsenteeismType>' + AbseentType(cOrigem) + '</AbsenteeismType>'
	cXMLRet +=                  '</SituationInformation>'
	cXMLRet +=				'</Situation>'			
	cXMLRet += 			'</ListOfSituation>'	
	cXMLRet += 		'</Employee>'
	cXMLRet += 	'</ListOfEmployee>'
	cXMLRet += '</Situation>'
	cXMLRet += '</BusinessContent>'
EndIf	

Return({lRet,cXMLRet})


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ InternalID ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <InternalID> da mensagem               ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function InternalID (cOrigem)

Local cTag := ''
Default cOrigem := ''

Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
		cTag := cEmpAnt + '|' + xFilial("SR8") + '|' + SR8->R8_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + oGridSr8:GetValue("R8_SEQ")
	Case cOrigem == 'GPEM040'//Rescisão.
		cTag := cEmpAnt + '|' + xFilial("SRG") + '|' + SRG->RG_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + '1'
	Case cOrigem == 'GPEM630'//Rescisão Coletiva.
		cTag := cEmpAnt + '|' + xFilial("SRA") + '|' + SRA->RA_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + '1'
	Case cOrigem == 'GPEM030'//Férias.
		cTag := cEmpAnt + '|' + xFilial("SRH") + '|' + SRH->RH_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + SR8->R8_SEQ
	Case cOrigem == 'GPEM060'//Férias Coletivas.
		cTag := cEmpAnt + '|' + xFilial("SRH") + '|' + SRH->RH_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + SR8->R8_SEQ
	Case cOrigem == 'GPEA810'//Reintegração.
		cTag := cEmpAnt + '|' + xFilial("SRA") + '|' + SRA->RA_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + '1'
	Case cOrigem == 'GPEA010'//Alteração.
		cTag := cEmpAnt + '|' + xFilial("SRA") + '|' + SRA->RA_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + '1'
EndCase

Return(cTag)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CommencDate ³ Autor ³ Alberto M.          ³ Data ³ 31/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <CommencementDate> da mensagem         ³±±
±±³          ³ EmployeeSituation, tambem possui tratamento para auxiliar na³±±
±±³          ³ construcao da tag <InternalID>                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±³          ³ lInternalID = Caso seja preenchimento da tag<InternalID> vem³±±
±±³          ³ como verdadeiro(.T.), caso nao sera falso(.F.)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function CommencDate (cOrigem, lInternalID)

Local cTag          := ''
Local cAux          := ''

Default lInternalID := .F.
Default cOrigem     := ''

Do Case

	//Afastamento.
	Case cOrigem == 'GPEA240'
	
		If !Empty(oGridSr8:GetValue("R8_DATAINI"))
			
			If nAfastEAI > 0
				cAux := DToS(BuscaIni(oGridSr8, oGridSr8:GetLine()))
			Else
				cAux  := DtoS(oGridSr8:GetValue("R8_DATAINI"))
			EndIf
			
			//InternalID informa data sem as barras.		
			If lInternalID 
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else 
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf

	//Rescisao.
	Case cOrigem == 'GPEM040'
	
		If !Empty(SRG->RG_DATADEM)
			cAux := DtoS(SRG->RG_DATADEM)
			//InternalID informa data sem as barras.
			If lInternalID
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
			
		Else
			cTag := cAux
		EndIf
		 
	//Rescisao Coletiva.
	Case cOrigem == 'GPEM630'
	
		If !Empty(SRA->RA_DEMISSA)
			cAux := DtoS(SRA->RA_DEMISSA)
			//InternalID informa data sem as barras.
			If lInternalID
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf
	
	//Ferias.
	Case cOrigem == 'GPEM030'
	
		If !Empty(SRH->RH_DATAINI)
			cAux := DtoS(SRH->RH_DATAINI)
			//InternalID informa data sem as barras.
			If lInternalID 
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else 
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf
	
	//Ferias Coletivas.
	Case cOrigem == 'GPEM060'
		If !Empty(SRH->RH_DATAINI)
			cAux := DtoS(SRH->RH_DATAINI)
			//InternalID informa data sem as barras.
			If lInternalID
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf
	
	//Reintegracao.
	Case cOrigem == 'GPEA810'
	
		If !Empty(SRA->RA_FECREI)
			cAux := DtoS(SRA->RA_FECREI)
			 //InternalID informa data sem as barras.
			If lInternalID
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			 //Caso seja TAG CommencDate informa data com barras.
			Else
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf
	
	
	Case cOrigem == 'GPEA010'//Alteração.
		cAux := DtoS(Date())
		
		If lInternalID //InternalID informa data sem as barras.
			cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
		Else //Caso seja TAG CommencDate informa data com barras.
			cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
		EndIf

EndCase

Return(cTag)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SitLastDay ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <SituationLastDay> da mensagem         ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function SitLastDay (cOrigem)

Local cTag := ''
Local cAux := ''

Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
	
		If !Empty(oGridSr8:GetValue("R8_DATAFIM"))
			cAux := DtoS(oGridSr8:GetValue("R8_DATAFIM"))
			cAux := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
		EndIf
		
		cTag := cAux
		 
	Case cOrigem == 'GPEM040'//Rescisão.
		cTag := cAux
	Case cOrigem == 'GPEM630'//Rescisão Coletiva.
		cTag := cAux
	Case cOrigem == 'GPEM030'//Férias.
	
		If !Empty(SRH->RH_DATAFIM)
			cAux := DtoS(SRH->RH_DATAFIM)
			cAux := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
		EndIf
	
		cTag := cAux
		
	Case cOrigem == 'GPEM060'//Férias Coletivas.
	
		If !Empty(SRH->RH_DATAFIM)
			cAux := DtoS(SRH->RH_DATAFIM)
			cAux := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
		EndIf

		cTag := cAux
		
	Case cOrigem == 'GPEA810'//Reintegração.
		cTag := ''
	Case cOrigem == 'GPEA010'//Alteração.
		cTag := ''
EndCase

Return(cTag)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ INSSPayCom ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <INSSPaymentCommencement> da mensagem  ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <INSSPaymentCommencement>.
Static function INSSPayCom (cOrigem)

Local cTag    := ''


Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
		cTag := ''
	Case cOrigem == 'GPEM040'//Rescisão.
		cTag := ''
	Case cOrigem == 'GPEM630'//Rescisão Coletiva.
		cTag := ''
	Case cOrigem == 'GPEM030'//Férias.
		cTag := ''
	Case cOrigem == 'GPEM060'//Férias Coletivas.
		cTag := ''
	Case cOrigem == 'GPEA810'//Reintegração.
		cTag := ''
	Case cOrigem == 'GPEA010'//Alteração.
		cTag := ''
	
EndCase

Return(cTag)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OriginSitu ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <OriginSituation> da mensagem          ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <OriginSituation>.
Static function OriginSitu (cOrigem)

Local cTag := ''

Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
		cTag := '1'
	Case cOrigem == 'GPEM040'//Rescisão.
		cTag := '2'
	Case cOrigem == 'GPEM630'//Rescisão Coletiva.
		cTag := '2'
	Case cOrigem == 'GPEM030'//Férias.
		cTag := '2'
	Case cOrigem == 'GPEM060'//Férias Coletivas.
		cTag := '2'
	Case cOrigem == 'GPEA810'//Reintegração.
		cTag := '1'
	Case cOrigem == 'GPEA010'//Alteração.
		cTag := '1'
EndCase

Return(cTag)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SituatDay ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <SituationDay> da mensagem             ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <SituationDay>.
Static function SituatDay (cOrigem)

Local cTag 	:= ''
Local nDias := 0

Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
		If ! Empty(nAfastEAI)
			BuscaIni(oGridSr8, oGridSr8:getLine(), @nDias)
			cTag := AllTrim(Str(nDias))
		Else
			cTag := If( Empty(oGridSr8:GetValue("R8_DATAFIM")) , '0' , AllTrim(Str(oGridSr8:GetValue("R8_DURACAO"))) )
		EndIf
	Case cOrigem == 'GPEM040'//Rescisão.
		cTag := '0'
	Case cOrigem == 'GPEM630'//Rescisão Coletiva.
		cTag := '0'
	Case cOrigem == 'GPEM030'//Férias.
		cTag := AllTrim(Str(SRH->RH_DFERIAS))
	Case cOrigem == 'GPEM060'//Férias Coletivas.
		cTag := AllTrim(Str(SRH->RH_DFERIAS))
	Case cOrigem == 'GPEA810'//Reintegração.
		cTag := '0'
	Case cOrigem == 'GPEA010'//Alteração.
		cTag := '0'
EndCase

Return(cTag)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CIDCode    ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <CIDCode> da mensagem                  ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <CIDCode>.
Static function CIDCode (cOrigem)

Local cTag := ''

	If cOrigem == 'GPEA240'//Afastamento.
	
		If !Empty(oGridSr8:GetValue("R8_CID"))
			cTag := oGridSr8:GetValue("R8_CID")
		Else
			cTag := ''
		EndIf
	
	//'GPEM040' - 'GPEM630' - 'GPEM030' - 'GPEM060' - 'GPEA810' - 'GPEA010'
	Else
		cTag := ''
	EndIf

Return(cTag)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SituatMean ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <SituationMeaning> da mensagem         ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function SituatMean (cOrigem,cEvent)

Local cTag := ''
Local cAux := ''
Default cEvent:= ''

	Do Case
		//Afastamento.
		Case cOrigem == 'GPEA240' 
			cAux := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_TIPOAF")
			cAux := If (cAux == '4', '5' , '2')
		
		//Rescisao ou Rescisao Coletiva.
		Case cOrigem == 'GPEM040' .Or. cOrigem == 'GPEM630'
			If !cEvent == 'delete'
				cAux := '6'
			Else
				cAux := '1'
			EndIf
		//Ferias ou Ferias Coletivas.
		Case cOrigem == 'GPEM030' .Or. cOrigem == 'GPEM060'
			cAux := '5' 
		
		//Reintegraçao.
		Case cOrigem == 'GPEA810'
			cAux := '1'
		
		Case cOrigem == 'GPEA010'//Alteração.
			Do Case
				Case SRA->RA_SITFOLH == ' '
					cAux := '1'
				Case SRA->RA_SITFOLH == 'A'
					cAux := '2'
				Case SRA->RA_SITFOLH == 'D'
					cAux := '6'
				Case SRA->RA_SITFOLH == 'F'
					cAux := '5'
				Case SRA->RA_SITFOLH == 'T'
					cAux := '6'
			EndCase		
	EndCase

	cTag := cAux

Return(cTag)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AbseentType ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <AbsenteeismType> da mensagem          ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Preenchimento da TAG <AbsenteeismType>.
Static function AbseentType (cOrigem)

Local cTag := ''
Local cAux := '1'
Local cTipo := ""
Local cVerba := ""

	//Afastamento.
	If cOrigem == 'GPEA240'
		cTipo := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_CODSEF")
		cVerba := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_PD")
		cAux := Y240TIPO1(cTipo,cVerba)
	EndIf

	cTag := cAux

Return(cTag)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SitCode ³ Autor ³ Alberto M.           ³ Data ³ 31/12/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenchimento da tag <SitCode> da mensagem          ³±±
±±³          ³ EmployeeSituation.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEI041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function SitCode (cOrigem)

Local cTag := ''
Local cAux := '2'
Local cTipo := ""
Local cVerba := ""

	//Afastamento.
	If cOrigem == 'GPEA240'
		cTipo := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_CODSEF")
		cVerba := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_PD")
		cAux := Y240TIPO2(cTipo,cVerba)
	ElseIf cOrigem == 'GPEA810'
		cAux := '1'
	EndIf

	cTag := cAux

Return(cTag)

Static Function Y240TIPO1(cTipo,cVerba)
Local cAux := "1"
Local aTipoXml := { "2", "3", "4", "4", "4", "4","6","8"}
Local aTipo :=    {"P1","O1","Q1","Q4","Q5","Q6","R","X2"}
Local nPos := 0

If cAux == "1" .And. cVerba == aCodFol[103,1] //Licença Remunerada
	cAux := "7"
Endif

nPos := Ascan(aTipo,{|x| Alltrim(x)==alltrim(cTipo)})
If nPos > 0 
	cAux := aTipoXml[nPos]
EndIf

Return cAux

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Y240TIPO2º    Autor ³Christiane Vieira º Data ³  02/12/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³De/Para do campo Situation Code                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³cTipo => Código SEFIP - Protheus V12                        º±±
±±º          ³cVerb => Código Verba                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Y240TIPO2(cTipo, cVerba)
Local cAux := "A"
Local aTipoXml := {"P",  "O", "Q", "B", "6", "7","R","X"}
Local aTipo :=    {"P1","O1","Q1","Q4","Q5","Q6","R","X"}
Local nPos := 0

If cAux == "A" .And. cVerba == aCodFol[103,1] //Licença Remunerada
	cAux := "8"
Endif

nPos := Ascan(aTipo,{|x| Alltrim(x)==alltrim(cTipo)})
If nPos > 0 
	cAux := aTipoXml[nPos]
EndIf

Return cAux