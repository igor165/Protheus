#Include 'Protheus.ch'
#Include 'FWAdapterEAI.ch'
#Include 'PMSI200.ch'
#INCLUDE "FWMVCDEF.CH"

#Define ERR 1
#Define WAR 2
#Define CRLF Chr(10) + Chr(13)

//-------------------------------------------------------------------
/*/{Protheus.doc} PMSI200A
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de contratos (ANE) utilizando o conceito de mensagem unica.
@param   cXML          Variavel com conteudo xml para envio ou recebimento
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   02/02/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function PMSI200A(cXml, nTypeTrans, cTypeMessage)

Local cAlias		:= "ANE"
Local cField		:= "ANE_CONTRA"
Local cXMLRet		:= ""
Local cProduct	:= ""
Local cValInt		:= ""
Local cValExt		:= ""
Local cProjeto	:= ""
Local cRevisa		:= ""
Local cError		:= ""
Local cWarning	:= ""
Local cFilAF8		:= ""
Local cFilAFN		:= ""
Local cFilANE		:= ""
Local cContrat		:= ""
Local aContrat		:= {}
Local nI			:= 0
Local nLength		:= 0
Local nTmContrato	:= 0
Local nTmProjeto	:= 0
Local nTmRevisa	:= 0
Local aTemp		:= {}
Local aMessages	:= {}
Local lFoundANE	:= .F.
Local lInsertANE	:= .F.
Local lAlteraANE 	:= .F.
Local lRet			:= .T.
Local lMsmContr		:= .F.
Local oModel		:= NIL

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.
Private lAuto				:= .T.	//A variável lAuto é utilizada no ModelDef/ViewDef do PMSA200

If GetNewPar("MV_PMSITMU", "0") == "1"
	If nTypeTrans == TRANS_RECEIVE
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			// Faz o parse do xml em um objeto
			oXml	:= xmlParser(cXml, "_", @cError, @cWarning)

			// Verifica se a mensagem recebida é uma mensagem de projeto ou de contrato
			If oXml != Nil .AND. Empty(cError) .AND. Empty(cWarning)

				cFilAF8		:= xFilial("AF8")
				cFilAFN		:= xFilial("AFN")
				cFilANE		:= xFilial("ANE")
				nTmContrato	:= TamSX3(cField)[1]
				nTmProjeto	:= TamSX3("AF8_PROJET")[1]
				nTmRevisa	:= TamSX3("AF8_REVISA")[1]

				// Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .AND. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cProduct	:= oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet		:= .F.
					cXmlRet	:= STR0085 //"A marca (Product) é obrigatório!"
					aAdd(aMessages, {cXMLRet, 1, Nil})
				EndIf

				// Verifica se o InternalId foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .AND. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
					cValExt	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
				Else
					lRet		:= .F.
					cXmlRet	:= STR0004 //O código do InternalId é obrigatório!
					aAdd(aMessages, {cXMLRet, 1, Nil})
				EndIf

				// Verifica se o código do contrato foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text") != "U" .AND. ! Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text)
					cNumber	:= PadR(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ContractNumber:Text, nTmContrato)
				Else
					lRet		:= .F.
					cXmlRet	:= STR0086 //"O código do contrato (ContractNumber) é obrigatório!"
					aAdd(aMessages, {cXMLRet, 1, Nil})
				EndIf

				// Verifica se o projeto foi informado
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text") != "U" .AND. ! Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text)
				
					If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT" .OR. Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
					
						aTemp	:= IntPrjInt(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ProjectInternalId:Text, cProduct)
	
						If aTemp[1]
							cProjeto	:= PadR(aTemp[2][3], nTmProjeto)
							cRevisa	:= StrZero(IIf(Len(aTemp[2]) > 3, Val(aTemp[2][4]), 1), nTmRevisa)

							AF8->(dbSetOrder(1))	//AF8_FILIAL+AF8_PROJET
							If AF8->(dbSeek(cFilAF8 + cProjeto + cRevisa))
								// Carrega o modelo MVC
								oModel		:= FWLoadModel("PMSA200")
								oModel:SetOperation(MODEL_OPERATION_UPDATE)
								oModel:Activate()
								
								// Obtém o valor interno da tabela XXF (de/para), caso este exista
								cValInt	:= RTrim(CfgA070Int(cProduct, cAlias, cField, cValExt))
							
								If !Empty(cValInt)

									aContrat	:= Strtokarr(cValInt,"|") //Monta array Contrato do De/Para

									If FwModeAccess("ANE",1)=='C' //Validação de compartilhamento da tabela ANE
										cContrat	:= RTrim(aContrat[4])
									else
										cContrat	:= RTrim(aContrat[5])
									EndIf
									
									
									//Se for deleção procura o contrato informado no xml 
									If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
										lFoundANE	:= oModel:GetModel("ANEDETAIL"):SeekLine({{cField,cNumber}}) //Busca o contrato do XML
									Else
										lFoundANE	:= oModel:GetModel("ANEDETAIL"):SeekLine({{cField,cContrat}}) //Busca o contrato do De/Para
									EndIf
									
									//Se o contrato registrado no De/Para for diferente do enviado na MSG deve verificar se pode ser alterado 
									If cContrat <> RTrim(cNumber) .OR. Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
									
										If !Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
											aValInt := Strtokarr(cValInt,"|")
											cValExtCnt := RTrim(CFGA070Ext( cProduct, cAlias, cField, aValInt[1]+"|"+aValInt[2]+"|"+aValInt[3]+"|"+aValInt[4]+"|"+cNumber))
											If !Empty(cValExtCnt) .And. cValExtCnt <> cValExt
												lRet		:= .F.
												cXmlRet	:= STR0114 //"Contrato informado ja existe no De/Para com outra chave externa."
												aAdd(aMessages, {cXMLRet, 1, Nil})
											EndIf
										EndIf
										
										If lRet
											// O contrato já possui uma Chave Interna e será analisado como um evento de UPDATE
											If	lFoundANE
												AFN->(dbSetOrder(1)) //AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM
												//Verifica se o contrato tem vinculo com documento de entrada. Caso afirmativo, não permite a alteração do registro
												If AFN->(DbSeek(cFilAFN + cProjeto + cRevisa))
													While AFN->(! Eof()) .AND. AFN->AFN_FILIAL == cFilAFN .AND. AFN->AFN_PROJET == cProjeto .AND. AFN->AFN_REVISA == cRevisa
														If AFN->AFN_CONTRA == PadR(cContrat, nTmContrato)
															lRet		:= .F.
															cXmlRet	:= STR0107 //"Contrato possui vínculo com demais tabelas e por isso não deve ser alterado."
															aAdd(aMessages, {cXMLRet, 1, Nil})
															EXIT
														EndIf
														AFN->(dbSkip())
													EndDo
												EndIf
												If lRet
													lAlteraANE :=.T.
												EndIf
											Else
												lRet		:= .F.
												cXmlRet	:= STR0089 //"Contrato não localizado."
												aAdd(aMessages, {cXMLRet, 1, Nil})
											EndIf
										EndIf
									Else
										lMsmContr := .T.
									EndIf
								Else
									If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
										lRet		:= .F.
										cXmlRet	:= STR0115 //"InternalId não localizado."
										aAdd(aMessages, {cXMLRet, 1, Nil})
									Else
										// Será analisado como um evento de INSERT, e uma Chave Interna será criada para o Contrato
										lInsertANE	:= .T.
									EndIf
								EndIf
							Else
								lRet		:= .F.
								cXmlRet	:= STR0109 + " " + STR0110 + " " + STR0111 + " " + cProjeto + " " + STR0112 + " " + cFilAF8	//"Erro Contrato:"##"O projeto não foi encontrado na filial desejada."## "Projeto:"##"Filial:"
								aAdd(aMessages, {cXMLRet, 1, Nil})
							EndIf
						Else
							lRet		:= .F.
							cXmlRet	:= aTemp[2]
							aAdd(aMessages, {cXMLRet, 1, Nil})
						EndIf
					Else
						lRet		:= .F.
						cXmlRet	:= STR0008 //"O Event informado é inválido!"
						aAdd(aMessages, {cXMLRet, 1, Nil})
					EndIf
				Else
					lRet		:= .F.
					cXmlRet	:= STR0088 //"O código do projeto (cProjectID) é obrigatório!"
					aAdd(aMessages, {cXMLRet, 1, Nil})
				EndIf
				
				If lRet .And. !lMsmContr
					If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
						If	lInsertANE
							// Adiciona o novo contrato no Grid
							oModel:GetModel("ANEDETAIL"):AddLine()
							oModel:GetModel("ANEDETAIL"):SetValue(cField, cNumber)
						ElseIf lAlteraANE
							// Altera o contrato no Grid
							oModel:GetModel("ANEDETAIL"):SetValue(cField, cNumber)
						EndIf
					Else
						// Exclui o contrato do modelo
						oModel:GetModel("ANEDETAIL"):DeleteLine()
					EndIf
					If oModel:VldData()
						If oModel:CommitData()
							If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
								If lAlteraANE
									// Exclui a Chave Interna na tabela XXF (de/para) para nova inclusão ajustada
									CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1)
								EndIf
								// Se o evento é UPSERT
								If lInsertANE .OR. lAlteraANE
									// Gera uma nova Chave Interna para o Contrato...
									cValInt	:= IntCntExt(cEmpAnt, xFilial(cAlias), cProjeto, cRevisa, cNumber)[2]
								EndIf
								// Insere a Chave Interna na tabela XXF (de/para)
								CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F., 1)
							Else
								// Exclui a Chave Interna na tabela XXF (de/para)
								CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T., 1)
							EndIf
							// Monta o XML de retorno
							cXMLRet	:= "<ListOfInternalId>"
							cXmlRet	+=     "<InternalId>"
							cXmlRet	+=         "<Name>Contract</Name>"
							cXmlRet	+=         "<Origin>" + cValExt + "</Origin>"
							cXmlRet	+=         "<Destination>" + cValInt + "</Destination>"
							cXmlRet	+=     "</InternalId>"
							cXmlRet	+= "</ListOfInternalId>"
						Else
							lRet		:= .F.
							cXmlRet	:= STR0113 //"Ocorreu um problema no momento da gravação dos contratos do Projeto."
							aAdd(aMessages, {cXMLRet, 1, Nil})
						EndIf
					Else
						lRet		:= .F.
						cXMLRet	:= oModel:GetErrorMessage()[6]
						aAdd(aMessages, {cXMLRet, 1, Nil})
					EndIf
				EndIf

			Else
				lRet		:= .F.
				cXMLRet	:= STR0010 //Erro ao parsear xml!
				aAdd(aMessages, {cXMLRet, 1, Nil})
			EndIf

		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			lRet		:= .F.
			cXMLRet	:= STR0092 //"O Contrato deve ser cadastrado no TOTVS Obras e Projetos."
			aAdd(aMessages, {cXMLRet, 1, Nil})
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet	:= '1.000'
		EndIf
	ElseIf nTypeTrans == TRANS_SEND
		lRet		:= .F.
		cXMLRet	:= STR0092 //"O Contrato deve ser cadastrado no TOTVS Obras e Projetos."
		aAdd(aMessages, {cXMLRet, 1, Nil})
	EndIf
Else
	lRet		:= .F.
	cXmlRet	:= STR0108 //"Parâmetro MV_PMSITMU desativado."
	aAdd(aMessages, {cXMLRet , 1, Nil})
EndIf

If !lRet
	cXMLRet	:= ""
	For nI := 1 To Len(aMessages)
		cXMLRet	+= aMessages[nI][1] + CRLF
	Next nI
EndIf

// Liberando a memória - aTemp
nLength	:= Len(aTemp)
For nI := 1 To nLength
	If ValType(aTemp[nI]) == "A"
		aSize(aTemp[nI], 0)
	EndIf
Next nI
aSize(aTemp, 0)

// Liberando a memória - aMessages
nLength	:= Len(aMessages)
For nI := 1 To nLength
	If ValType(aMessages[nI]) == "A"
		aSize(aMessages[nI], 0)
	EndIf
Next nI
aSize(aMessages, 0)

If	Type("oModel") == "O"
	oModel:Destroy()	// Liberando a memória - oModel
EndIf
Return {lRet, cXMLRet, "CONTRACT"}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCntExt
Monta o InternalID do Contrato do Projeto de acordo com o código passado
no parâmetro.
@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cProjeto   Código do Projeto
@param   cRevisa    Revisão do Projeto
@param   cContrato  Código do Contrato
@param   cVersao    Versão da mensagem única (Default 1.000)
@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   10/07/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntCntExt(, , '0100', '0001', '000001') irá retornar {.T., '01|01|0100|0001|000001'}
/*/
//-------------------------------------------------------------------
Function IntCntExt(cEmpresa, cFil, cProjeto, cRevisa, cContrato, cVersao)

Local aResult		:= {}

Default cEmpresa	:= cEmpAnt
Default cFil		:= xFilial('ANE')
Default cProjeto	:= ""
Default cRevisa	:= ""
Default cContrato	:= ""
Default cVersao	:= '1.000'

If cVersao == '1.000'
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cProjeto) + '|' + RTrim(cRevisa) + '|' + RTrim(cContrato))
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0096 + CRLF + STR0095) //"Versão do contrato não suportada." "As versões suportadas são: 1.000"
EndIf
Return aResult
