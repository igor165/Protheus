#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "CTBI040A.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CTBI040

Funcao de integracao com o adapter EAI para recebimento do Item Contábil (CTD)
utilizando o conceito de mensagem unica.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMsg      Tipo de mensagem. (Business Type, WhoIs, etc)
@param   cVersion      Versão da mensagem

@author  Sidney de Oliveira
@version P11
@since   26/09/2013
@return  lRet - (boolean)  Indica o resultado da execução da função
          cXmlRet - (caracter) Mensagem XML para envio
/*/
//-------------------------------------------------------------------------------------------------
Function CTBI040A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local cXmlRet 		:= ""
Local cXml040
Local cXmlError		:= ""
Local cXmlWarning	:= ""
Local cAlias		:= "CTD"
Local cCampo		:= "CTD_ITEM"
Local cVersoesOk	:= "1.000"
Local lRet			:= .T.
Local aItemCon		:= {}
local aErroAuto		:= {}
Local cEvento		:= "upsert"
Local lInclusao		:= .F.
Local cProduct		:= ''
Local cDestinyId	:= ''
Local cOriginId		:= ''
Local ni			:= 0
Local aAreaSX3		:= SX3->( GetArea() )
Local cFilEAI

Default cVersion := "1.000"

Private lMsErroAuto    := .F.

If cTypeTrans == TRANS_RECEIVE
	If cTypeMsg == EAI_MESSAGE_BUSINESS
		oXml040 := XmlParser( cXML, '_', @cXmlError, @cXmlWarning)

		If oXml040 <> Nil .AND. Empty(cXmlError) .AND. Empty(cXmlWarning)
			cMarca := oXml040:_TotvsMessage:_MessageInformation:_Product:_Name:Text

			If Type("oXml040:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml040:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXml040:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				lRet    := .F.
				cXmlRet := STR0001 // "Versão da mensagem não informada!"
				Return {lRet, cXmlRet}
			EndIf

			If ( cVersion $ cVersoesOk )
				If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") <> 'U'
					cEvento := oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text

					// Recebe o codigo da Conta no Cadastro externo e guarda na variavel cValExt
					If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") <> "U"
						cValExt := oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
					EndIf

					//----------------------------------------------------------------------------------------
					//-- procura a Marca,Alias,Codigo na Tabela XXF de De/Para para ver se Existe o Código
					//----------------------------------------------------------------------------------------
	   			    //Apens verifica se existe o Registro no XXF para saber se é Inclusão, Alteração ou Exclusão
		   			cValInt := CFGA070INT( cMarca,  cAlias , cCampo, cValExt )
		   			If !Empty(cValInt)
		   				cValInt := Separa(cValInt,"|")[3]
		   			EndIf

					If Empty(cValInt)
						If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text")  <> 'U'
							aadd(aItemCon, {"CTD_ITEM", oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text, NIL})
						EndIf
					Else
						aadd(aItemCon, {"CTD_ITEM", cValInt , NIL})
					EndIf

					If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text")  <> 'U'
						aadd(aItemCon, {"CTD_DESC01", oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, NIL})
					EndIf

					If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Class:Text")  <> 'U'
						aadd(aItemCon, {"CTD_CLASSE", oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Class:Text, NIL})
					EndIf

					If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text")  <> 'U'
						cSit := Alltrim(oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text)
						If Upper(cSit) == "1"
							aadd(aItemCon, {"CTD_BLOQ", '1', NIL})
						Else
							aadd(aItemCon, {"CTD_BLOQ", '2', NIL})
						EndIf
					EndIf


					If FindFunction("CFGA070INT")
						SX3->( dbSetOrder( 02 ) )
						SX3->( dbSeek( "CTD_ITEM" ) )

						cValInt := CFGA070INT( cMarca, cAlias, cCampo, cValExt)

						If Empty(cValInt)
							cValInt := cEmpAnt + "|" + xFilial("CTD") + "|" +oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
							lInclusao := .T.
						EndIf
						//
						RestArea( aAreaSX3 )

						If Upper(oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
							If lInclusao
								// inclui na tabela de/para XXF
								CFGA070Mnt(cMarca, cAlias, cCampo, cValExt, cValInt, .F., 1)
								nOpc := 3
							Else
								nOpc := 4
							EndIf
						ElseIf Upper(oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
							nOpc := 5

							// exclui da tabela de/para
							CFGA070Mnt(cMarca, cAlias, cCampo, cValExt, cValInt, .T., 1)
						Else
							lRet := .F.
							cXMLRet := STR0008//"Operação de inserção, alteraçã, exclusao e chave interna são inexistentes"
						EndIf

						If Empty(cXmlRet)
							MSExecAuto({|x, y| CTBA040(x, y)}, aItemCon, nOpc)

							If lMsErroAuto
								// Obtém o log de erros
								aErroAuto := GetAutoGRLog()

								// Varre o array obtendo os erros em UTF-8 e quebrando a linha
								For nI := 1 to Len(aErroAuto)
									cXmlRet += aErroAuto[nI] + Chr(10)
								Next nI
								If empty(cXmlRet)
									cXmlRet := "Erro na gravação do item contábil (CTBA040)."
								EndIf

								lRet := .F.
							Else
								// Monta o XML de retorno
								If Upper(oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
									cXMLRet := "<ListOfInternalId>"
									cXMLRet +=     "<InternalId>"
									cXMLRet +=         "<Name>AccountingItem</Name>"
									cXMLRet +=         "<Origin>" + cValExt + "</Origin>" // Valor recebido na tag
									cXMLRet +=         "<Destination>" + cValInt + "</Destination>" // Valor XXF gerado
									cXMLRet +=     "</InternalId>"
									cXMLRet += "</ListOfInternalId>"
								EndIf
							EndIf
						EndIf
					Else
						lRet   := .F.
						cXMLRet:= STR0002	//-- "Atualize EAI"
						ConOut(STR0002)	//-- Atualize EAI
						BREAK
					EndIf
				EndIf
			Else
				lRet := .F.
				cXmlRet := STR0003 + cVersoesOk // "Versão da mensagem não tratada pelo Protheus, as possíveis são: "
			EndIf
		Else
			lRet := .F.
			cXMLRet	:= STR0004 + cXmlError + "|" + cXmlWarning // "Xml mal formatado "
		EndIf

	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
		//Faz o parser do XML de retorno em um objeto
		oXml040 := xmlParser(cXML, "_", @cXmlError, @cXmlWarning)

		If oXml040 != Nil .And. Empty(cXmlError) .And. Empty(cXmlWarning)
			//Se não houveram erros na resposta
			If Upper(oXml040:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
				if Upper(oXml040:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"
					// Verifica se a marca foi informada
					If Type("oXml040:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml040:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
						cProduct := oXml040:_TOTVSMessage:_MessageInformation:_Product:_name:Text
					Else
						lRet    := .F.
						cXmlRet := STR0005 + "|" // "Erro no retorno. O Product é obrigatório!"
						Return {lRet, cXmlRet}
					EndIf

					//Processo o OriginInternalId, caso tenha sido recebido
					If Type("oXml040:_TOTVSMessage:_ResponseMessage:_ReturnContent:_listofinternalid:_internalid:_Origin:Text") != "U" .And. !Empty(oXml040:_TOTVSMessage:_ResponseMessage:_ReturnContent:_listofinternalid:_internalid:_Origin:Text)
						cOriginId := oXml040:_TOTVSMessage:_ResponseMessage:_ReturnContent:_listofinternalid:_internalid:_Origin:Text
					Else
						lRet    := .F.
						cXmlRet := STR0006 + "|" // "Erro no retorno. O OriginInternalId é obrigatório!"
						Return {lRet, cXmlRet}
					EndIf

					//Processo o DestinationInternalId, caso tenha sido recebido
					If Type("oXml040:_TOTVSMessage:_ResponseMessage:_ReturnContent:_listofinternalid:_internalid:_Destination:Text") != "U" .And. !Empty(oXml040:_TOTVSMessage:_ResponseMessage:_ReturnContent:_listofinternalid:_internalid:_Destination:Text)
						cDestinyId := oXml040:_TOTVSMessage:_ResponseMessage:_ReturnContent:_listofinternalid:_internalid:_Destination:Text
					Else
						lRet    := .F.
						cXmlRet := STR0007 + "|" // "Erro no retorno. O DestinationInternalId é obrigatório!"
						Return {lRet, cXmlRet}
					EndIf

					If lRet
						CFGA070Mnt( cProduct, 'CTD', 'CTD_ITEM', cDestinyId, cOriginId,.F.)
					EndIf
				EndIf
			Else
				lRet := .F.
				cXMLRet	:= STR0004 + cXmlError + "|" + cXmlWarning // "Xml mal formatado "
			EndIf
		Else
			lRet := .F.
			cXMLRet	:= STR0004 + cXmlError + "|" + cXmlWarning // "Xml mal formatado "
		EndIf
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
		cXmlRet := "1.000"
	EndIf

ElseIf cTypeTrans == TRANS_SEND

	cValInt := cEmpAnt + "|" + xFilial("CTD") + "|" + CTD->CTD_ITEM

	If !Inclui .And. !Altera
		cEvento := "delete"

		M->CTD_FILIAL := CTD->CTD_FILIAL
		M->CTD_ITEM   := CTD->CTD_ITEM
		M->CTD_CLASSE := CTD->CTD_CLASSE
		M->CTD_DESC01 := CTD->CTD_DESC01

		CFGA070Mnt(,'CTD','CTD_ITEM',,cValInt,.T.)

	EndIf

	cXMLRet += '<BusinessEvent>'
	cXMLRet += ' <Entity>AccountingItem</Entity>'
	cXMLRet += ' <Event>' + cEvento + '</Event>'
	cXMLRet += ' <Identification>'
	cXMLRet += '  <key name="BranchId">' + cFilAnt + '</key>
	cXMLRet += '  <key name="Code">' + _NoTags( AllTrim( M->CT1_CONTA ) ) + '</key>
	cXMLRet += ' </Identification>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'
	cXMLRet += ' <CompanyId>' + cEmpAnt + '</CompanyId>'
	cXMLRet += ' <BranchId>' + cFilAnt + '</BranchId>'
	cXMLRet += ' <CompanyInternalId>' + cEmpAnt + "|" + cFilAnt + '</CompanyInternalId>'
	cXMLRet += ' <Code>' + _NoTags( AllTrim( CTD->CTD_ITEM)) + '</Code>'
	cXMLRet += ' <InternalId>' + cValInt + '</InternalId>'
	cXMLRet += ' <Description>' + _NoTags( AllTrim(CTD->CTD_DESC01)) + '</Description>'
	cXMLRet += ' <Class>' + Alltrim(CTD->CTD_CLASSE) + '</Class>'
	cXMLRet += ' <RegisterSituation>' + If(CTD->CTD_BLOQ == '1', '1', '2') + '</RegisterSituation>'
	cXMLRet += ' <TopCode>' + _NoTags( AllTrim( CTD->CTD_ITSUP)) + '</TopCode>'
	cXMLRet += '</BusinessContent>'
Endif

Return {lRet, cXmlRet, "AccountingItem"}

//-------------------------------------------------------------------
/*/{Protheus.doc} C040GetInt
Recebe um codigo, busca seu InternalId e faz a quebra da chave

@param cCodigo - InternalID recebido na mensagem.
@param cMarca - Produto que enviou a mensagem

@author	Pedro Pereira Lima
@version P11.8
@since 14/10/14
@return	aRetorno Array contendo os campos da chave primaria da classe de valor e o seu internalid.
@sample	exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Codigo' },InternalId}
/*/										//   01          02         03
//-------------------------------------------------------------------
Function C040AGetInt(cCodigo, cMarca, cVersao)
Local aResult	:= {}
Local aTemp		:= {}
Local aCampos	:= {cEmpAnt,'CTD_FILIAL','CTD_ITEM'}
Local nX		:= 0
Local cTemp		:= ''

Default cVersao  := '1.000'

cTemp := CFGA070Int(cMarca, 'CTD', 'CTD_ITEM', cCodigo)

If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0009 + AllTrim(cCodigo) + STR0010) //"Item Contábil " + " não encontrado no de/para!"
Else
	If cVersao == '1.000'
		aTemp := Separa(cTemp,'|')

		aAdd(aResult, .T. )
		aAdd(aResult, aTemp )
		aAdd(aResult, cTemp )

		aResult[2][1] := Padr(aResult[2][1],Len(cEmpAnt))

		For nX := 2 To 	Len(aResult[2]) //corrigindo  o tamanho dos campos
			aResult[2][nX] := Padr(aResult[2][nX],TamSX3(aCampos[nx])[1])
		Next nX
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0011 + Chr(10) + STR0012) //"Versão da mensagem Item Contábil não suportada." + "A versão suportada é: 1.000"
	EndIf
EndIf

Return aResult

