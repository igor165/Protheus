#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "CTBI040.CH"
#INCLUDE "FWMVCDEF.CH"

Static cMessage := "Departament"

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
Function CTBI040(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

	Local cXmlRet 		:= ""
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
	Local aGetInt		:= {}
	Local nI			:= 0

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
	               cXmlRet := STR0003 // "Versão da mensagem não informada!"
	               Return {lRet, cXmlRet}
				EndIf

				If ( cVersion $ cVersoesOk )
		    		If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") <> Nil
		    			cEvento := oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text

		    			//aadd(aItemCon, {"CTD_FILIAL", xFilial("CTD"), NIL})

		    			// Essa informação não trafega pela mensagem única e será
		    			// sempre considerada como '2' (analítica)
    					aadd(aItemCon, {"CTD_CLASSE", "2", NIL})

	    				If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text") <> Nil
	    					//aadd(aItemContabil, {"CTD_ITEM", oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_CompanyId:Text, NIL})
	    				EndIf

	    				If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text") <> Nil
	    					//aadd(aItemContabil, {"CTD_FILIAL", xFilial("CTD"), NIL})
	    				EndIf

	    				If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyInternalId:Text") <> Nil
	    					//aadd(aItemContabil, {"CTD_ITEM", oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_CompanyInternalId:Text, NIL})
	    				EndIf

	    				If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") <> Nil
    						cCodigo := oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
	    				EndIf

	    				If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") <> Nil
							cValExt := oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
	    				EndIf

	    				If Type("oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") <> Nil
	    					aadd(aItemCon, {"CTD_DESC01", oXml040:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, NIL})
	    				EndIf

						If FindFunction("CFGA070INT")

							aGetInt := C040GetInt(cValExt,cMarca)
							If !aGetInt[1]
								cCodigo := padL(allTrim(cCodigo), TamSX3("CTD_ITEM")[1], "0")
								cValInt := C040MntInt(,cCodigo)
								aadd(aItemCon, {"CTD_ITEM", cCodigo, NIL})

								lInclusao := .T.
							Else
								aadd(aItemCon, {"CTD_ITEM", aGetInt[2][3], NIL})
								cValInt := aGetInt[3]
							EndIf

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
			    				cXMLRet := STR0001 // "Operação de inserção, alteraçã, exclusao e chave interna são inexistentes"
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
									lRet := .F.
					            Else
					               // Monta o XML de retorno
									If Upper(oXml040:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
										cXMLRet := "<ListOfInternalId>"
										cXMLRet +=     "<InternalId>"
										cXMLRet +=         "<Name>AreaAndLineOfBusiness</Name>"
										cXMLRet +=         "<Origin>" + cValExt + "</Origin>" // Valor recebido na tag
										cXMLRet +=         "<Destination>" + cValInt + "</Destination>" // Valor XXF gerado
										cXMLRet +=     "</InternalId>"
										cXMLRet += "</ListOfInternalId>"
									EndIf
					            EndIf
			    			EndIf
						Else
							lRet   := .F.
							cXMLRet:= STR0004	//-- Atualize EAI
							ConOut(STR0004)	//-- Atualize EAI
							BREAK
						EndIf
					EndIf
				Else
					lRet := .F.
	        		cXmlRet := STR0002 + cVersoesOk // "Versão da mensagem não tratada pelo Protheus, as possíveis são: "
				EndIf
			Else
				lRet := .F.
	        	cXMLRet	:= STR0003 + cXmlError + "|" + cXmlWarning // "Xml mal formatado "
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
	        		cXMLRet	:= STR0003 + cXmlError + "|" + cXmlWarning // "Xml mal formatado "
				EndIf
			Else
				lRet := .F.
	        	cXMLRet	:= STR0003 + cXmlError + "|" + cXmlWarning // "Xml mal formatado "
			EndIf
		ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
			cXmlRet := cVersoesOk
		EndIf

	ElseIf cTypeTrans == TRANS_SEND

		cValInt := cEmpAnt + '|' + xFilial("CTD") + '|' + CTD->CTD_ITEM

		If !Inclui .And. !Altera
			cEvento := "delete"

			M->CTD_FILIAL := CTD->CTD_FILIAL
			M->CTD_ITEM   := CTD->CTD_ITEM
			M->CTD_CLASSE := CTD->CTD_CLASSE
			M->CTD_DESC01 := CTD->CTD_DESC01

			CFGA070Mnt(,'CTD','CTD_ITEM',,cValInt,.T.)
		EndIf

		cXMLRet += '<BusinessEvent>'
		cXMLRet +=    '<Entity>' + cMessage + '</Entity>'
		cXMLRet += '<Event>' + cEvento + '</Event>'
		cXMLRet +=    '<Identification>'
		cXMLRet +=       '<key name="InternalID">' + cValInt + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + "|" + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=    '<Code>' + CTD->CTD_ITEM + '</Code>'
		cXMLRet +=    '<InternalID>' + cValInt + '</InternalID>'
		cXMLRet +=    '<Description>' + CTD->CTD_DESC01 + '</Description>'
		cXMLRet +=    '<Classe>' + CTD->CTD_CLASSE + '</Classe>'
		cXMLRet += '</BusinessContent>'

	EndIf
Return {lRet, cXmlRet, cMessage}

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
Function C040GetInt(cCodigo, cMarca, cVersao)
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
			aResult[2][nX] := Padr(aResult[2][nX],TamSX3(aCampos[nX])[1])
		Next nX
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0011 + Chr(10) + STR0012) //"Versão da mensagem Item Contábil não suportada." + "A versão suportada é: 1.000"
	EndIf
EndIf

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} C040MntInt
monta chave para o internalID

@param cCodigo - codigo do item que sera usado
@param cIntFil - filial que sera usada para o de/para

@version P11.8
@since 02/02/2016
@return	cRetCode string contendo o internalID montado
@sample	exemplo de retorno - 'T1|D MG 01|001'
/*/
//-------------------------------------------------------------------
Function C040MntInt(cIntFil,cCodClVl)
Local cRetCode	:= ''
Default cIntFil	:= xFilial('CTD')

cIntFil	:= xFilial("CTD",cIntFil)

cRetCode := cEmpAnt + '|' + cIntFil + '|' + AllTrim(cCodClVl)

Return cRetCode
