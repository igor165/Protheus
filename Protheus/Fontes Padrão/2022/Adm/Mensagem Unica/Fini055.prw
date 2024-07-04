#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FINI055.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fini055   ºAutor  ³Jandir Deodato      º Data ³ 24/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ M.U Financiamento - Integracao Protheus X Tin              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fini055(cXml, nType, cTypeMsg)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Função para a interação com EAI                             º±±
±±º          ³Mensagem de Financiamento                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fini055(cXml, nType, cTypeMsg, cVersion, cTransac)

Local cXmlRet			:= ""
Local cErroXml			:= ""
Local cWarnXml			:= ""
Local cMarca			:= ""
Local cValMoed			:= ""
Local cValExt			:= ""
Local cVendor			:= ""
Local cLoja				:= ""
Local cTipo				:= ""
Local cParcel			:= ""
Local cPrefixo			:= ""
Local cNatureza			:= ""
local cValForn			:= ""
Local cHist				:= ""
Local cOpcVenda			:= ""
Local cTitE1E2			:= ""
local cCrtBco			:= ""
Local cSource 			:= ""
Local nCtbVenda			:= SuperGetMV("MV_CTBINTE",,1)
Local nMoeda			:= 0
Local nCount			:= 0
Local nValor			:= 0
Local nValorOrig		:= 0
Local nX				:= 0
Local nOpcExec			:= 0
Local nTotVenda			:= 0
Local dEmissao			:= CtoD("//")
Local dVencimento		:= CtoD("//")
Local lRet				:= .T.
Local lIncluir			:= .T.
Local aValMoeda			:= {}
Local aNatureza			:= {}
Local aArea				:= GetArea()
Local aErroRet 			:= {}
Local aVali				:= {}
Local aVale				:= {}
Local aAux				:= {}
Local nRmTinVer			:= SuperGetMV("MV_RMTINVE",,1)
Private oXmlFin			:= Nil
Private oXmlCab			:= Nil
Private oXmlParcel		:= Nil
Private oXmlChild		:= Nil
Private oXmlAux			:= Nil
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

cModulo := "FIN"

Do Case
	// verificação do tipo de transação recebimento ou envio
	// trata o envio
	Case  nType == TRANS_SEND  //Nesta mensagem nao sera tratado o envio, apenas o recebimento.

	Case  nType == TRANS_RECEIVE
		If (cTypeMsg == EAI_MESSAGE_WHOIS )
				cXmlRet := '1.000|1.001|1.002'
		ElseIF ( cTypeMsg == EAI_MESSAGE_BUSINESS )
			oXmlFin := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

			If Empty(oXmlFin) .AND. "UTF-8" $ UPPER(cXML)
				cXML := EncodeUTF8( cXML )
				oXmlFin := XmlParser( cXML, "_", @cErroXml, @cWarnXml )
			EndIf

			If oXmlFin <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				If Type("oXmlFin:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
					cMarca :=  oXmlFin:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				Else
					lRet:=.F.
					AADD(aErroRet,STR0029)//"não foi enviado o produto que está integrando.
				Endif

				If Type ("oXmlFin:_TotvsMessage:_BusinessMessage:_BusinessContent:_ContractHeader")<>"U"
					oXmlCab:= oXmlFin:_TotvsMessage:_BusinessMessage:_BusinessContent:_ContractHeader
				Else
					lRet:=.F.
					AADD(aErroRet,STR0025)//"Não foram enviadas parcelas."
				Endif

				If Type ("oXmlCab:_CompanyId:Text")# "U" .And. !Empty (oXmlCab:_CompanyId:Text)
					If Type ("oXmlCab:_DocumentTypeCode:Text") # "U"
						If Empty (oXmlCab:_DocumentTypeCode:Text)
							cTipo := padr("NF",TamSX3("E1_TIPO")[1])
						Else
							cTipo := PadR(oXmlCab:_DocumentTypeCode:Text,TamSX3("E1_TIPO")[1])
						Endif
					Else
						cTipo := padr("NF",TamSX3("E1_TIPO")[1])
					Endif
				Else
					lRet:= .F.
					AADD(aErroRet,STR0001)//"Empresa Vazia ou inexistente"
				Endif

				If lRet .and. Type("oXmlFin:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfContractParcel") #"U"
					oXmlParcel:=oXmlFin:_TotvsMessage:_BusinessMessage:_BusinessContent:_ListOfContractParcel

					If Type("oXmlParcel:_ContractParcel[1]") # "U"
						nCount := Len(oXmlParcel:_ContractParcel)
					ElseIf  Type("oXmlParcel:_ContractParcel") # "U"
						nCount :=1
					Else
						lRet:=.F.
						AADD(aErroRet,STR0025)//"Não foram enviadas parcelas."
					Endif

					BeginTran()
					For nX :=1 to nCount
						If !lRet .Or. !lIncluir
							Exit
						Endif
                        nValorOrig	:= 0
						nValor		:= 0
						cValForn	:= ''
						cPrefixo	:= ''
						cParcel		:= ''
						nJuros		:= 0
						nPorcJur	:= 0
						cHist		:=''

						If Type("oXmlFin:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text") #"U"
							If upper(AllTrim(oXmlFin:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text))=='UPSERT'
								nOpcExec:= 3
							ElseIf upper(AllTrim(oXmlFin:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text))=='DELETE'
								nOpcExec:= 5
							Else
								lIncluir := .F.
								lRet:=.F.
								AADD(aErroRet,STR0013+" " + cValToChar(nX))//"Tipo de Evento Inexistente------Item"
							Endif
						Else
							lIncluir := .F.
							lRet:=.F.
							AADD(aErroRet,STR0014+" " + cValToChar(nX))//"Tipo de Evento vazio ou não enviado------Item"
						Endif

						If lIncluir
							If nCount >1
								oXmlChild:= oXmlParcel:_ContractParcel[nX]
							Else
								oXmlChild:= oXmlParcel:_ContractParcel
							Endif

							If Type ("oXmlChild:_InternalId:Text") # "U" .And. !Empty(oXmlChild:_InternalId:Text)
								cValExt:= oXmlChild:_InternalId:Text
							Else
								lRet:= .F.
								lIncluir:=.F.
								AADD(aErroRet,STR0002+" " + cValToChar(nX))//"InternalId não enviado------Item"
							Endif

							If Type("oXmlChild:_Source:Text") # "U"
									cSource := oXmlChild:_Source:Text
							Endif

							If nOpcExec # 5
								If Type("oXmlChild:_CustomerVendorId:Text") # "U" .And. !Empty (oXmlChild:_CustomerVendorId:Text)
									If Type("oxmlChild:_Type:Text")#"U" .and. AllTrim(Upper(oxmlChild:_Type:Text)) == "RECEIVABLE"
										aAux := IntCliInt(oXmlChild:_CustomerVendorId:Text, cMarca, MsgUVer('MATA030', 'CUSTOMERVENDOR'))

										IF aAux[1]//se achou
											If Len(aAux[2])>2
												cValForn:=Padr(aAux[2][3],TamSX3("A1_COD")[1])+Padr(aAux[2][4],TamSX3("A1_LOJA")[1])//forn+loja
											Else
												cValForn:=aAux[2][1]+aAux[2][2]
											Endif
										Else
											cValforn:=''
										Endif
									ElseIf Type("oxmlChild:_Type:Text")#"U" .and. AllTrim(Upper(oxmlChild:_Type:Text)) == "PAYABLE"
										aAux := IntForInt(oXmlChild:_CustomerVendorId:Text, cMarca, MsgUVer('MATA020', 'CUSTOMERVENDOR'))
										IF aAux[1]//se achou
											If Len(aAux[2])>2
												cValForn:=Padr(aAux[2][3],TamSx3("A2_COD")[1])+Padr(aAux[2][4],TamSX3("A2_LOJA")[1])//forn+loja
											Else
												cValForn:=aAux[2][1]+aAux[2][2]//forn+loja
											Endif
										Else
											cValforn:=''
										Endif
										If Empty (cValforn)
											IncluiSA2(@cValForn,cMarca,@lRet,@lIncluir,@aErroRet)
										Endif
									Else
										lIncluir:=.F.
										lREt:= .F.
										AADD(aErroRet,STR0004+" " + cValToChar(nX))//"Tipo do documento Informado não existe------Item"
									Endif

									If lRet
										If !Empty (cValForn)
											cVendor :=SubStr(cValForn,1,TamSX3("A2_COD")[1])
											cLoja := SubStr(cvalForn,TamSX3("A2_COD")[1]+1,TamSX3("A2_LOJA")[1])
										Else
											lRet:= .F.
											lIncluir:= .F.
											AADD(aErroRet,STR0005 +" " + cValToChar(nX))//Cliente/Fornecedor invãlido------Item
										Endif
									Endif
								Else
									lRet:= .F.
									lIncluir:= .F.
									AADD(aErroRet,STR0005+" " + cValToChar(nX))//"Cliente/Fornecedor invãlido------Item
								Endif

								If Type("oXmlChild:_DocumentPrefix:Text") # "U"
									cPrefixo := Padr(oXmlChild:_DocumentPrefix:Text,TamSx3("E1_PREFIXO")[1])
								Endif

								If Type("oXmlChild:_DocParcel:Text") #"U"
									cParcel:= Padr(oXmlChild:_DocParcel:Text,TamSx3("E1_PARCELA")[1])
								Endif

								If Type("oXmlChild:_MCMVContract:Text") # "U"
									cCrtBco := Padr(oXmlChild:_MCMVContract:Text,TamSx3("E1_CTRBCO")[1])
								Endif

								If Type("oXmlChild:_IssueDate:Text") # "U" .And. !Empty (oXmlChild:_IssueDate:Text)
									dEmissao:= SubStr(oXmlChild:_IssueDate:Text,1,4)+Substr(oXmlChild:_IssueDate:Text,6,2)+SubStr(oXmlChild:_IssueDate:Text,9,2)
									dEmissao:=StoD(dEmissao)
								Else
									lRet:= .F.
									lIncluir:=.F.
									AADD(aErroRet,STR0006+" " + cValToChar(nX))//"Data de Emissão vazia ou inválida------Item"
								Endif

								If Type ("oXmlChild:_DueDate:Text") # "U" .And. !Empty(oXmlChild:_DueDate:Text)
									dVencimento:= SubStr(oXmlChild:_DueDate:Text,1,4)+Substr(oXmlChild:_DueDate:Text,6,2)+SubStr(oXmlChild:_DueDate:Text,9,2)
									dVencimento:=StoD(dVencimento)
								Else
									lRet:= .F.
									lIncluir:=.F.
									AADD(aErroRet,STR0007+" " + cValToChar(nX))//"Data de Vencimento vazia ou inválida------Item"
								Endif

								If dEmissao > dVencimento
									lRet:= .F.
									lIncluir:=.F.
									AADD(aErroRet,STR0008+" " + cValToChar(nX)) //"Data de vencimento menor que a data de emissão------Item"
								Endif

								If Empty(dEmissao)
									lRet:= .F.
									lIncluir:=.F.
									AADD(aErroRet,STR0019+" " + cValToChar(nX)) //"Data de Emissão vazia ou inválida------Item"
								Endif

								If Empty(dVencimento)
									lRet:= .F.
									lIncluir:=.F.
									AADD(aErroRet,STR0020+" " + cValToChar(nX)) //"Data de Vencimento vazia ou inválida-----Item"
								Endif

								If Type ("oXmlChild:_NetValue:Text") # "U" .And. !Empty(oXmlChild:_NetValue:Text)
									nValor:= Val(oXmlChild:_NetValue:Text)
								Else
									lIncluir := .F.
									lRet:=.F.
									AADD(aErroRet,STR0009+" " + cValToChar(nX))//"Valor do Título inválido------Item"
								Endif

								If nRmTinVer > 1 //Tag GrossValue para o EAI versão 2 do TIN
									If Type ("oXmlChild:_GrossValue:Text") # "U" .And. !Empty(oXmlChild:_GrossValue:Text)
										nValorOrig:= Val(oXmlChild:_GrossValue:Text)
									Else
										lIncluir := .F.
										lRet:=.F.
										AADD(aErroRet,STR0033+" "+ cValToChar(nX))//"Valor Original do Título inválido <GrossValue>------Item"
									Endif
								EndIf

								If Type ("oXmlChild:_CurrencyCode:Text") # "U" .And. !Empty (oXmlChild:_CurrencyCode:Text)

									aValMoeda := IntMoeInt(oXmlChild:_CurrencyCode:Text, cMarca, MsgUVer("CTBA140", "CURRENCY"))

									If aValMoeda[1]
										cValMoed:= aValMoeda[2][Len(aValMoeda[2])]
									Endif

									IF Empty(cValMoed)
										lIncluir := .F.
										lRet:=.F.
										AADD(aErroRet,STR0010+" " + cValToChar(nX))//"Moeda Inválida------Item"
										AADD(aErroRet,aValMoeda[2])//"Moeda Inválida------Item"
									Else
										nMoeda:=Val(cValMoed)
									Endif
								Else
									lIncluir := .F.
									lRet:=.F.
									AADD(aErroRet,STR0011+" " + cValToChar(nX)) //"Moeda em branco ou não enviada------Item"
								Endif

								If Type ("oXmlChild:_History:Text") # "U"
									cHist:=oXmlChild:_History:Text
								Endif

								If Type ("oXmlChild:_FinancialCode:Text") # "U" .And.  !Empty (oXmlChild:_FinancialCode:Text)
									aNatureza:=F10GetInt(oXmlChild:_FinancialCode:Text, cMarca)

									If aNatureza[1]
										cNatureza:=aNatureza[2][3]
									Endif

									If Empty (cNatureza)
										lIncluir := .F.
										lRet:=.F.
										AADD(aErroRet,STR0022+" " + cValToChar(nX))//"Código da Natureza não cadastrado no Protheus------Item"
									Endif
								Else
									lIncluir := .F.
									lRet:=.F.
									AADD(aErroRet,STR0012+" " + cValToChar(nX))//"Código da Natureza vazio ou não enviado------Item"
								Endif
							Else //Quando for exclusão pegar Valor e Historico para caso haja contabilização online.
								If Type ("oXmlChild:_NetValue:Text") # "U" .And. !Empty(oXmlChild:_NetValue:Text)
									nValor:= Val(oXmlChild:_NetValue:Text)
								Else
									lIncluir := .F.
									lRet:=.F.
									AADD(aErroRet,STR0009+" " + cValToChar(nX))//"Valor do Título inválido------Item"
								Endif

								If Type ("oXmlChild:_History:Text") # "U"
									cHist:=oXmlChild:_History:Text
								Endif
							Endif

							If lIncluir
								If Type ("oXmlChild:_Type:Text") # "U"  .and. AllTrim(Upper(oxmlChild:_Type:Text)) $ "RECEIVABLE|PAYABLE"
									If AllTrim(Upper(oxmlChild:_Type:Text)) == "RECEIVABLE"
										IncluiSE1(cTipo,cMarca,cValExt,@lRet,@lIncluir,@aErroRet,@aValI,@aValE,nOpcExec,cVendor,cLoja,cPrefixo,cParcel,dEmissao,dVencimento,nValor,nValorOrig,nMoeda,cNatureza,nX,cHist,@cTitE1E2,@nTotVenda,nCtbVenda,@cOpcVenda,cCrtBco,cSource)
									ElseIf AllTrim(Upper(oxmlChild:_Type:Text)) == "PAYABLE"
										IncluiSE2(cTipo,cMarca,cValExt,@lRet,@lIncluir,@aErroRet,@aValI,@aValE,nOpcExec,cVendor,cLoja,cPrefixo,cParcel,dEmissao,dVencimento,nValor,nMoeda,cNatureza,nX,cHist,@cTitE1E2)
									Endif

									If lIncluir
										If ExistBlock("F055IT")
											ExecBlock("F055IT",.F.,.F.,{cValExt,cHist,cTitE1E2})
										Endif
									Endif
								Else
									lIncluir:=.F.
									lREt:= .F.
									AADD(aErroRet,STR0016+" " + cValToChar(nX)) //"Tipo do documento não informado ou vazio------Item"
								Endif
							Endif
						Endif
					Next nX

					If lIncluir == .F.
						DisarmTransaction()
						lRet:=.F.
					Else
						If nCtbVenda == 2 //Contabilização por venda
							If nOpcExec == 5 //Deletar
								lRet := CtbVenda("D",nTotVenda,cHist,cTitE1E2,cOpcVenda)
							Else
								If nTotVenda > 0
									lRet := CtbVenda("I",nTotVenda,cHist,cTitE1E2,cOpcVenda)
								Elseif nTotVenda < 0
									nTotVenda := Abs(nTotVenda)
									lRet := CtbVenda("I",nTotVenda,cHist,cTitE1E2,cOpcVenda)
								Endif
							Endif

							If !lRet
								lIncluir := .F.
								DisarmTransaction()
							Else
								EndTran()
							Endif
						Else
							EndTran()
						Endif
					Endif
				Endif
			Else
				lRet:= .F.
				AADD(aErroRet,STR0017)//"Erro no XML Recebido"
			EndIf

			If lRet == .T.
				If( nRmTinVer >= 2 )
					cXmlRet += "<ListOfInternalId>"
				Else
					cXmlRet += "<ListInternalId>"
				EndIf
				For nX:=1 to len(aVale)
					cXmlRet += "<InternalId>"
					If( nRmTinVer >= 2 )
						cXMLRet += "<Destination>"+ aValI[nX] +"</Destination>"
						cXMLRet += "<Name>FINANCING</Name>"
						cXMLRet += "<Origin>" + aValE[nX] + "</Origin>"
					Else
						cXMLRet += "<DestinationInternalId>" + aValI[nX] + "</DestinationInternalId>"
						cXMLRet += "<OriginInternalId>" + aValE[nX] + "</OriginInternalId>"
					EndIf
					cXmlRet += "</InternalId>"
				Next nX
				If( nRmTinVer >= 2 )
					cXmlRet += "</ListOfInternalId>"
				Else
					cXmlRet += "</ListInternalId>"
				EndIf

			Else
				For nX:=1 to len(aErroRet)
					cXmlRet+='<Message type="ERROR" code="c2">'+aErroRet[nX]+'</Message>'
				Next
			Endif
		EndIf
EndCase

msUnlockAll()
RestArea(aArea)

cXmlret := FwnoAccent(cXmlRet)
cXmlRet := EncodeUTF8(cXmlRet)

Return { lRet, cXmlRet, "FINANCING" }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IncluiSE1 ºAutor  ³Jandir Deodato      º Data ³ 21/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Rotina de atualização de titulos a receber                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IncluiSE1(cValForn,oXmlChild,cMarca,lRet,lIncluir,aErroRet)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Rotina que inclui ou exclui ou faz a substituição de titulosº±±
±±º          ³a receber.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fini055                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function IncluiSE1(cTipo,cMarca,cValExt,lRet,lIncluir,aErroRet,aValI,aValE,nOpcExec,cVendor,cLoja,cPrefixo,cParcel,dEmissao,dVencimento,nValor,nValorOrig,nMoeda,cNatureza,nX,cHist,cTitE1E2,nTotVenda,nCtbVenda,cOpcVenda,cCrtBco,cSource)

Local cAlias		:= "SE1"
Local cCampo		:= "E1_NUM"
Local aValInt		:= F55GetInt(cValExt, cMarca,cAlias)
Local cValInt		:= IIf(aValInt[1],RTrim(aValInt[3]),'')
local cCompDesc		:= ''
Local cCompCod		:= ''
Local cAliasTMP		:= ''
Local cNum			:= CriaVar("E1_NUM")
Local cTpParcel		:= CriaVar("E1_TIPO")
Local nCount2		:= 0
Local nCompVal		:= 0
Local nCountCc		:= 0
Local nXaux			:= 0
Local nPorcJur		:= 0
Local nJuros		:= 0
Local nReg			:= 0
Local nCC			:= 0
Local aAreaFRU		:= {}
Local aArea			:= GetArea()
Local aAreaSE1		:= {}
Local aCab			:= {}
Local aAltera		:= {}
Local aErroAuto 	:= {}
Local aVetor 		:= {}
Local aRatEvEz		:= {}
Local aRetPe		:= {}
Local lFRU			:= .T.
Local lAcres		:= .F.
Local lBaixa		:= .F.
Local lXenum		:= .F.
Local nVlrDeAc		:= 0
Local aVaValInt		:= {}
Local nCntCmp		:= 0
Local aVaAut		:= {}
Local nRmTinVer		:= SuperGetMV("MV_RMTINVE",, 1)
Local oXmlCmp		:= Nil

If lFRU
	dbSelectArea("FRU")
	aAreaFRU:=FRU->(GetArea())
	FRU->(dbSetOrder(1))
Endif

dbSelectArea("SE1")
aAreaSE1:=SE1->(GetArea())
SE1->(dbSetOrder(1))//FILIAL+PREFIXO+NUM+PARCELA+TIPO

If aValInt[1]
	cTpParcel:=aValInt[2][6]

	If nOpcExec == 3
		nOpcExec :=4
	Endif
Else
	If nOpcExec == 5
		lIncluir := .F.
		lREt:= .F.
		AADD(aErroRet,STR0015+" " + cValToChar(nX))//"Tentativa de exclusão com erro. Título nao existe no Protheus------Item"
	Endif
Endif

If nOpcExec <> 5
	If lRet .and. Type("oXmlChild:_FlagAccount:Text") # "U" .And.(AllTrim(oXmlChild:_FlagAccount:Text)) $ "0|1"
		If AllTrim(oXmlChild:_FlagAccount:Text) == "1"
			cTpParcel:=cTipo
		ElseIf AllTrim(oXmlChild:_FlagAccount:Text) =='0'
			cTpParcel:= PadR("PR",TamSX3("E1_TIPO")[1])
		Endif
	ElseIf lRet .and.!aValInt[1]
		lRet:= .F.
		lIncluir := .F.
		AADD(aErroRet,STR0003+" " + cValToChar(nX))//"Tipo da Parcela não informado------Item"
	Endif
Endif

//Integração RM TIN EAI 2.0  Valores acessórios
If ( nRmTinVer >= 2 )
	lFRU := .F. //Integração RM TIN EAI 2.0 não controla FRU
	If Type ("oXmlChild:_ListOfComponent:_Component[1]")# "U"
		oXmlCmp := oXmlChild:_ListOfComponent:_Component
		For nCntCmp := 1 to Len(oXmlCmp)
			aVaValInt := {}
			aVaValInt := F035GetInt(oXmlCmp[nCntCmp]:_CODE:TEXT,cMarca)
			If aVaValInt[1] 
				AADD(aVaAut,{aVaValInt[2][3],VAL(oXmlCmp[nCntCmp]:_VALUE:TEXT)})			
			Else
				lRet := .F.
				lInclui := .F.
				AADD(aErroRet,STR0032+" "+ oXmlCmp[nCntCmp]:_CODE:TEXT)//Não foi localizado o de/para para o valor acessório xxxxxxxxxxx		
			EndIf
		Next
	ElseIf Type("oXmlChild:_ListOfComponent:_Component") # "U"	// Apenas 1 :_Componente
		oXmlCmp := oXmlChild:_ListOfComponent:_Component
		aVaValInt := {}
		aVaValInt := F035GetInt(oXmlCmp:_CODE:TEXT,cMarca)
		If aVaValInt[1]
			AADD(aVaAut,{aVaValInt[2][3],VAL(oXmlCmp:_VALUE:TEXT)})		
		Else			
			lRet :=.F.
			lInclui :=.F.
			AADD(aErroRet,STR0032+" "+ oXmlCmp:_CODE:TEXT)//Não foi localizado o de/para para o valor acessório xxxxxxxxxxx			
		EndIf
	EndIf
EndIf

If lIncluir
	If aValInt[1]
		cNum := aValInt[2][4]
		If nOpcExec # 5
			If Alltrim (ctpParcel)== AllTrim(cTipo) .and. AllTrim(aValInt[2][6])== "PR";
					.And. SE1->(dbSeek(xFilial("SE1")+padr(cPrefixo,TamSx3("E1_PREFIXO")[1])+cNum+padr(cPARCEL,TamSx3("E1_PARCELA")[1])+padr("PR",TamSX3("E1_TIPO")[1])));
					.And. Empty (SE1->E1_BAIXA)
				nOpcExec :=6
				nReg:=SE1->(Recno())
			ElseIf Alltrim (ctpParcel)== AllTrim(cTipo) .And. SE1->(dbSeek(xFilial("SE1")+padr(cPrefixo,TamSx3("E1_PREFIXO")[1])+cNum+padr(cPARCEL,TamSx3("E1_PARCELA")[1])+cTpParcel))

				If Alltrim(SE1->E1_STATUS) == "A" .and. Empty(SE1->E1_BAIXA) .and. SE1->E1_LA == " "
					lAcres:= .F.
					lXeNum:=.T.
				Else
					lAcres:= .T.
				Endif

			Endif
		Else
			cPrefixo:= aValInt[2][3]
			cParcel:=aValInt[2][5]
			cTpParcel:=aValInt[2][6]
			If Alltrim (ctpParcel)== AllTrim(cTipo) .And. SE1->(dbSeek(xFilial("SE1")+padr(cPrefixo,TamSx3("E1_PREFIXO")[1])+cNum+padr(cPARCEL,TamSx3("E1_PARCELA")[1])+ctpParcel))
				lBaixa:=.T.
			Endif
		Endif

		//Se parametro de versão RM e se a versão é diferente de 2 (versão 1.0 da integração)
		If nRmTinVer <> 2
			// Carteira não pode ser diferente de '0'
			If AllTrim(SE1->E1_SITUACA) <> "0"
				If nOpcExec <> 5
					AAdd(aErroRet, STR0030) //"Venda não pode ser alterada, pois possui títulos em banco."
				Else
					AAdd(aErroRet, STR0031) //"Venda não pode ser excluida, pois possui títulos em banco."
				EndIf
				lIncluir 	:= .F.
				lRet		:= .F.
			EndIf
		EndIf
	Else
		cNum:=getsxenum("SE1","E1_NUM")
		lXeNum:=.T.

		While .T.
			If SE1->(dbseek(xFilial("SE1")+cPrefixo+cNum))
				ConfirmSX8()
				cNum:=getsxenum("SE1","E1_NUM")
			Else
				Exit
			Endif
		Enddo
	Endif

	If !lBaixa .And. lIncluir

		cParcel   := PadR(cParcel  , TamSx3("E1_PARCELA")[1])
		cPrefixo  := PadR(cPrefixo , TamSx3("E1_PREFIXO")[1])
		cNum      := PadR(cNum     , TamSx3("E1_NUM"    )[1])
		cTpParcel := PadR(cTpParcel, TamSx3("E1_TIPO"   )[1])
		cNatureza := PadR(cNatureza, TamSx3("E1_NATUREZ")[1])
		cVendor   := PadR(cVendor  , TamSx3("E1_CLIENTE")[1])
		cLoja     := PadR(cLoja    , TamSx3("E1_LOJA"   )[1])

		If nOpcExec == 6
			While .T.
				If SE1->(dbseek(xFilial("SE1")+cPrefixo+cNum))
					cNum:=Soma1(cNum)
				Else
					Exit
				Endif
			Enddo
		Endif

        If Empty(cParcel)
            cParcel := padr(cPARCEL,TamSx3("E1_PARCELA")[1])
        EndIf

        aadd( aCab ,{"E1_FILIAL" , xFilial("SE1")	, Nil })
		aadd( aCab ,{"E1_PREFIXO" , cPrefixo	, Nil })
		aadd( aCab ,{"E1_NUM" , cNum, Nil })
		aadd( aCab ,{"E1_PARCELA" , cParcel, Nil })
		aadd( aCab ,{"E1_TIPO" , cTpParcel, Nil })

		//Titulo a ser utilizado no P.E
		cTitE1E2 := "SE1|"+cPrefixo+"|"+cNum+"|"+cParcel+"|"+cTpParcel

		If nOpcExec # 5
			aadd( aCab ,{"E1_NATUREZ" , cNatureza, Nil })
			aadd( aCab ,{"E1_CLIENTE" , cVendor, Nil })
			aadd( aCab ,{"E1_LOJA" , cLoja, Nil })

			If nOpcExec <> 4
				aadd( aCab ,{"E1_EMISSAO" 	, dEmissao		, Nil })
			Endif

			aadd( aCab ,{"E1_VENCTO" , dVencimento, Nil })

			If lAcres .and. nRmTinVer < 2  //Contabilização por titulo
				If nValor <> SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE
					IF nValor > SE1->E1_SALDO
						nVlrDeAc := nValor - SE1->E1_SALDO
						AADD(aCab,{"E1_DECRESC"	,0							,nil})
						AADD(aCab,{"E1_ACRESC"	,nVlrDeAc					,nil})
					ELSEIF SE1->E1_SALDO > nValor
						nVlrDeAc := SE1->E1_SALDO - nValor
						AADD(aCab,{"E1_ACRESC"	,0							,nil})
						AADD(aCab,{"E1_DECRESC"	,nVlrDeAc					,nil})
					Else
						AADD(aCab,{"E1_DECRESC"	,0							,nil})
						AADD(aCab,{"E1_ACRESC"	,0							,nil})
					Endif
				Endif
			Else
				If lXeNum
					If ( nRmTinVer < 2 )
						aadd(aCab,{"E1_VALOR"  ,nValor ,Nil })
					Else
						aadd(aCab,{"E1_VALOR"  ,nValorOrig ,Nil })
					EndIf
					AADD(aCab,{"E1_DECRESC"	,0 ,nil})
					AADD(aCab,{"E1_ACRESC"	,0 ,nil})
				Endif

				//Soma do contrato ou diferença
						If nOpcExec <> 4
							nTotVenda += nValor
							If nOpcExec == 3
								If Empty(cSource)
									cOpcVenda := "IV"
								Else
									If cSource == "0"
										cOpcVenda := "IV"
									Elseif 	cSource == "1"
										cOpcVenda := "IR"
									Elseif 	cSource == "2"
										cOpcVenda := "IA"
									Elseif 	cSource == "3"
										cOpcVenda := "ID"
									Endif
								Endif
							Elseif nOpcExec == 5
								If Empty(cSource)
										cOpcVenda := "EV"
								Else
									If cSource == "0"
										cOpcVenda := "EV"
									Elseif 	cSource == "1"
										cOpcVenda := "ER"
									Elseif 	cSource == "2"
										cOpcVenda := "EA"
									Elseif 	cSource == "3"
										cOpcVenda := "ED"
									Endif
								Endif
							Endif
						Else
							If SE1->E1_VALOR <> nValor
								If nValor > SE1->E1_VALOR
									nTotVenda += nValor - SE1->E1_VALOR
									If Empty(cSource)
										cOpcVenda := "IR"
									Else
										If cSource == "0"
											cOpcVenda := "IV"
										Elseif 	cSource == "1"
											cOpcVenda := "IR"
										Elseif 	cSource == "2"
											cOpcVenda := "IA"
										Elseif 	cSource == "3"
											cOpcVenda := "ID"
										Endif
									Endif

								Elseif SE1->E1_VALOR > nValor
									nTotVenda += SE1->E1_VALOR - nValor
									If Empty(cSource)
										cOpcVenda := "ER"
									Else
										If cSource == "0"
											cOpcVenda := "EV"
										Elseif 	cSource == "1"
											cOpcVenda := "ER"
										Elseif 	cSource == "2"
											cOpcVenda := "EA"
										Elseif 	cSource == "3"
											cOpcVenda := "ED"
										Endif
									Endif
								Endif
							Endif
						Endif
			Endif

			If Type("oXmlChild:_Interest:Text") #"U"
				nJuros:= Val(oXmlChild:_Interest:Text)
				aadd( aCab ,{"E1_VALJUR" , nJuros, Nil })
			Endif

			If Type("oXmlChild:_Fine:Text") #"U"
				nPorcJur:= Val(oXmlChild:_Fine:Text)
				If nPorcJur >= 100
					lRet:= .F.
					lIncluir:=.F.
					AADD(aErroRet,STR0028+" " + cValToChar(nX))//'Porcentagem de juros não pode ser igual ou superior a 100% --------Item'
				Else
					aadd( aCab ,{"E1_PORCJUR" , nPorcJur, Nil })
				Endif
			Endif

			aadd( aCab ,{"E1_MOEDA" , nMoeda, Nil })

			aadd( aCab ,{"E1_HIST" , SubSTR(cHist,1,TamSX3("E1_HIST")[1]), Nil })
			aadd( aCab ,{"E1_ORIGEM" , "FINI055", Nil })
			aadd( aCab ,{"E1_CTRBCO" , cCrtBco, Nil })

			If nOpcExec == 3 .or. nOpcExec==6
				IncluiSEV(@aRatEvEz,cMarca,cNatureza,Iif(nRmTinVer >= 2, nValorOrig , nValor),@nCC,@lRet,@lIncluir,@aErroRet)
				If !Empty(aRatEvEz) .And. nCC >= 1
					aadd( aCab ,{"E1_MULTNAT" , "1", Nil })
				Else
					aadd( aCab ,{"E1_MULTNAT" , "2", Nil })
				Endif
			Endif

			If nOpcExec ==6 .and. lRet
				SE1->(dbGoTo(nReg))
				aadd( aAltera ,{ {"E1_FILIAL" , xFilial("SE1")	, Nil };
					,{"E1_PREFIXO" , SE1->E1_PREFIXO	, Nil };
					,{"E1_NUM" , SE1->E1_NUM, Nil };
					,{"E1_PARCELA" , SE1->E1_PARCELA, Nil };
					,{"E1_TIPO" , SE1->E1_TIPO, Nil };
					,{"E1_NATUREZ" , SE1->E1_NATUREZ, Nil };
					,{"E1_CLIENTE" , SE1->E1_CLIENTE, Nil };
					,{"E1_LOJA" , SE1->E1_LOJA, Nil };
					,{"E1_EMISSAO" , SE1->E1_EMISSAO, Nil };
					,{"E1_VENCTO" , SE1->E1_VENCTO, Nil };
					,{"E1_VALOR" , SE1->E1_VALOR, Nil };
					,{"E1_MOEDA" , SE1->E1_MOEDA, Nil };
					,{"E1_ORIGEM" , "FINI055", Nil } })
			Endif
		ELSE
			nTotVenda += SE1->E1_VALOR
			cOpcVenda := "ER"
		Endif

		SetFunName('FINA040')

		If nOpcExec == 3 .and. ExistBlock("F055E1")
			aRetPe := ExecBlock("F055E1",.F.,.F.,{aCab,aRatEvEz})
			If ValType(aRetPe) == "A" .And. Len(aRetPe) > 0
				lIncluir := .T.
				lRet := .T.
				If ValType(aRetPe[1]) == "A"
					aCab		:= aClone(aRetPe[1])
				EndIf
				If ValType(aRetPe[2]) == "A"
					aRatEvEz	:= aClone(aRetPe[2])
				EndIf
			EndIf
		EndIf

		If lRet .and. lIncluir
			aParam := {}
			aAdd(aParam,{"MV_PAR01", 2 })

			MsExecAuto( { |x,y,z,a,b,c| FINA040(x,y,z,a,b,,,c)} , aCab, nOpcExec,aAltera,aRatEvEz,aParam,aVaAut)

			If lMsErroAuto
				aErroAuto := GetAutoGRLog()

				For nCount2 := 1 To Len(aErroAuto)
					AADD(aErroRet,StrTran(StrTran(StrTran(aErroAuto[nCount2],"<"," "),"-"," "),"/"," ")+" ")
				Next nCount2

				lIncluir:=.F.
				lRet:=.F.
			Else
				ConfirmSX8()
				If lFRU .And. nOpcExec # 5

					If Type ("oXmlChild:_ListOfComponent:_Component[1]")# "U"
						nCountCc:=len(oXmlChild:_ListOfComponent:_Component)
					ElseIF Type ("oXmlChild:_ListOfComponent:_Component")# "U"
						nCountCc:=1
					Else
						nCountCc:=0
					Endif

					cCompDesc:=''
					cCompCod:=''
					nCompVal:=0

					For nXaux:=1 to nCountCc
						If nCountCc>1
							oXmlAux:=oXmlChild:_ListOfComponent:_Component[nXaux]
						Else
							oXmlAux:=oXmlChild:_ListOfComponent:_Component
						Endif

						If Type ("oXmlAux:_Code:Text")#"U" .and.!Empty(oXmlAux:_Code:Text)
							cCompCod:=Padr(oXmlAux:_Code:Text,TamSx3("FRU_COD")[1])
						Endif

						If Type ("oXmlAux:_Value:Text")#"U" .and.!Empty(oXmlAux:_Value:Text)
							nCompVal:=Val(oXmlAux:_Value:Text)
						Endif

						If Type ("oXmlAux:_Name:Text")#"U" .and.!Empty(oXmlAux:_Name:Text)
							cCompDesc:=Padr(oXmlAux:_Name:Text,TamSx3("FRU_DESC")[1])
						Endif

						If !Empty(cCompCod) .and. !Empty(cCompDesc) .and. nCompVal <> 0
							If nOpcExec == 3 .or. nOpcExec ==6
								RecLock("FRU",.T.)
							ElseIf nOpcExec==4
								If FRU->(dbSeek(xFilial("FRU")+cCompCod+cPrefixo+cNum+cParcel+cTpParcel))
									RecLock("FRU",.F.)
								Else
									RecLock("FRU",.T.)
								Endif
							Endif
							FRU->FRU_FILIAL:=xFilial("FRU")
							FRU->FRU_COD:=cCompCod
							FRU->FRU_PREFIX:=cPrefixo
							FRU->FRU_NUM:=cNum
							FRU->FRU_PARCEL:=cParcel
							FRU->FRU_TIPO:=cTpParcel
							FRU->FRU_DESC:=cCompDesc
							FRU->FRU_VALOR:=nCompVal
							FRU->(MsUnlock())
						ElseIf (Empty(cCompDesc) .and. !Empty(cCompCod)) .or. (!empty(Ccompdesc) .and. Empty(Ccompcod))
							lRet:=.F.
							lInclui:=.F.
							AADD(aErroRet,STR0023+" "+ cValToChar(nX))//"Problemas com o envio dos componentes da parcela------------item "
						Endif
					Next nCountCc
				ElseIf lFRU .and. nOpcExec==5
					cAliasTMP:=GetNextAlias()

					cQuery:="Select * From " + RetSqlName("FRU")
					cQuery+=" where FRU_PREFIX = '"+cPrefixo+"' and FRU_NUM ='" +cNum +"'"
					cQuery+=" and FRU_PARCEL ='"+cParcel+"' and FRU_TIPO ='"+cTpParcel+"' and FRU_FILIAL='"+xFilial("FRU")+"'"
					cQuery:=ChangeQuery(cQuery)

					If Select(cAliasTMP)>0
						(cAliasTMP)->(dbCloseArea())
					Endif

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

					If Select(cAliasTMP)>0
						(cAliasTMP)->(dbGoTop())
						While (cAliasTmp)->(!EOF())
							If FRU->(dbSeek(xFilial("FRU")+(cAliasTmp)->FRU_COD+(cAliasTMP)->FRU_PREFIX+(cAliasTMP)->FRU_NUM+(cAliasTMP)->FRU_PARCEL+(cAliasTMP)->FRU_TIPO))
								RecLock("FRU")
								FRU->(dbDelete())
								FRU->(MsUnlock())
							Endif
							(cAliasTMP)->(dbSkip())
						EndDo
						(cAliasTMP)->(dbCloseArea())
					Endif
				Endif

				If !aValInt[1]
					cValInt:= F55MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,,,'SE1')//(SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
				Endif

				If nOpcExec==6
					CFGA070Mnt(, cAlias,cCampo,, cValInt,.T. )
					SE1->(dbSeek(xFilial("SE1")+padr(cPrefixo,TamSx3("E1_PREFIXO")[1])+cNum+padr(cPARCEL,TamSx3("E1_PARCELA")[1])+cTpParcel))
					cValInt:= F55MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,,,'SE1')//(SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
				Endif

				If nOpcExec== 3 .Or. nOpcExec==6//subst. automatica
					CFGA070Mnt( cMarca, cAlias,cCampo, cValExt, cValInt )
					AADD(aVale,cValExt)
					AADD(aVali,cValInt)
				ElseIf nOpcExec == 5
					CFGA070Mnt(, cAlias,cCampo,, cValInt,.T. )
					AADD(aVale,cValExt)
					AADD(aVali,cValInt)
				Endif
			Endif
		EndIf
	Else
		aVetor := {{"E1_PREFIXO"	, cPrefixo 		,Nil},;
			{"E1_NUM"		, cNum       	,Nil},;
			{"E1_PARCELA"	, cParcel 		,Nil},;
			{"E1_TIPO"	    , cTpParcel     		,Nil},;
			{"AUTMOTBX"	    , "TIN"             	,Nil},;
			{"AUTDTBAIXA"	, dDataBase				,Nil},;
			{"AUTDTCREDITO" , dDataBase				,Nil},;
			{"AUTHIST"	    , STR0021,Nil},;  //"Baixa realizada pelo Tin"
		{"AUTTXMOEDA"	, RecMoeda(dDataBase,SE1->E1_MOEDA) ,Nil}}
		//Titulo a ser utilizado no P.E
		cTitE1E2 := "SE1|"+cPrefixo+"|"+cNum+"|"+cParcel+"|"+cTpParcel

		If nCtbVenda == 2 //Contabilização por venda
			If nOpcExec <> 4
				nTotVenda += nValor
				If nOpcExec == 3
					If Empty(cSource)
						cOpcVenda := "IV"
					Else
						If cSource == "0"
							cOpcVenda := "IV"
						Elseif 	cSource == "1"
							cOpcVenda := "IR"
						Elseif 	cSource == "2"
							cOpcVenda := "IA"
						Elseif 	cSource == "3"
							cOpcVenda := "ID"
						Endif
					Endif
				Elseif nOpcExec == 5
					If Empty(cSource)
							cOpcVenda := "EV"
					Else
						If cSource == "0"
							cOpcVenda := "EV"
						Elseif 	cSource == "1"
							cOpcVenda := "ER"
						Elseif 	cSource == "2"
							cOpcVenda := "EA"
						Elseif 	cSource == "3"
							cOpcVenda := "ED"
						Endif
					Endif
				Endif
			Else
				If SE1->E1_VALOR <> nValor
					If nValor > SE1->E1_VALOR
						nTotVenda += nValor - SE1->E1_VALOR
						If Empty(cSource)
							cOpcVenda := "IR"
						Else
							If cSource == "0"
								cOpcVenda := "IV"
							Elseif 	cSource == "1"
								cOpcVenda := "IR"
							Elseif 	cSource == "2"
								cOpcVenda := "IA"
							Elseif 	cSource == "3"
								cOpcVenda := "ID"
							Endif
						Endif

					Elseif SE1->E1_VALOR > nValor
						nTotVenda += SE1->E1_VALOR - nValor
						If Empty(cSource)
							cOpcVenda := "ER"
						Else
							If cSource == "0"
								cOpcVenda := "EV"
							Elseif 	cSource == "1"
								cOpcVenda := "ER"
							Elseif 	cSource == "2"
								cOpcVenda := "EA"
							Elseif 	cSource == "3"
								cOpcVenda := "ED"
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif

		aParam := {}
		aAdd(aParam,{"MV_PAR01", 2 })

		MSExecAuto({|a,b,c,d,e,f,g| Fina070(a,b,c,d,e,f,g)},aVetor,3,Nil,Nil,Nil,aParam,.T.)

		If lMsErroAuto
			aErroAuto := GetAutoGRLog()

			For nCount2 := 1 To Len(aErroAuto)
				AADD(aErroRet,StrTran(StrTran(StrTran(aErroAuto[nCount2],"<"," "),"-"," "),"/"," ")+" ")
			Next nCount2

			lIncluir:=.F.
			lRet:=.F.
		Else
			CFGA070Mnt(, cAlias,cCampo,, cValInt,.T. )
			AADD(aVale,cValExt)
			AADD(aVali,cValInt)
		Endif
	Endif
Endif

If lXenum
	FreeUsedCode(.T.)
EndIf

If lFRU
	RestArea(aAreaFRU)
Endif

RestArea(aAReaSE1)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IncluiSE2 ºAutor  ³Jandir Deodato      º Data ³ 21/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Rotina de atualização de titulos a pagar                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IncluiSE2()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Rotina que inclui ou exclui ou faz a substituição de titulosº±±
±±º          ³a pagar  .                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fini055                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IncluiSE2(cTipo,cMarca,cValExt,lRet,lIncluir,aErroRet,aValI,aValE,nOpcExec,cVendor,cLoja,cPrefixo,cParcel,dEmissao,dVencimento,nValor,nMoeda,cNatureza,Nx,cHist,cTitE1E2)

Local cAlias		:= "SE2"
Local cCampo		:= "E2_NUM"
Local aValInt		:= F55GetInt(cValExt, cMarca,cAlias)//CFGA070INT(cMarca,cAlias,cCampo,cValExt)
Local cValInt 	:= Iif(aValInt[1],aValInt[3],'')//CFGA070INT(cMarca,cAlias,cCampo,cValExt)
local cCompDesc	:= ''
Local cCompCod	:= ''
Local cNum 		:= CriaVar("E2_NUM")
Local cTpParcel	:= CriaVar("E2_TIPO")
Local cAliasTMP	:= ''
Local nCompVal	:= 0
Local nCountCc	:= 0
Local nXaux		:= 0
Local nCount2		:= 0
Local nPorcJur	:= 0
Local nJuros		:= 0
Local nCC			:= 0
Local aCab			:= {}
Local aAltera		:= {}
Local aErroAuto 	:= {}
Local aAreaFRU	:= {}
Local aArea		:= GetArea()
Local aAreaSE2	:= {}
Local aVetor		:= {}
Local aRatEvEz	:= {}
Local aRetPe		:= {}
Local lBaixa		:= .F.
Local lAcres		:= .F.
Local lFRU			:= .T.
Local lXeNum		:= .F.
Local nReg 		:= 0

If lFRU
	dbSelectArea("FRU")
	aAreaFRU:=FRU->(GetArea())
	FRU->(dbSetOrder(1))
Endif

dbSelectArea("SE2")
aAreaSE2:=SE2->(GetArea())
SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

If aValInt[1]
	cTpParcel:=aValInt[2][6]
	If nOpcExec == 3
		nOpcExec :=4
	Endif
Else
	If nOpcExec == 5
		lIncluir := .F.
		lREt:= .F.
		AADD(aErroRet,STR0015+" " + cValToChar(nX))//"Tentativa de exclusão com erro. Título nao existe no Protheus------Item"
	Endif
Endif

If nOpcExec <> 5
	If Type("oXmlChild:_FlagAccount:Text") # "U" .And.(AllTrim(oXmlChild:_FlagAccount:Text)) $ "0|1"
		If AllTrim(oXmlChild:_FlagAccount:Text) == "1"
			cTpParcel:=cTipo
		ElseIf AllTrim(oXmlChild:_FlagAccount:Text) =='0'
			cTpParcel:= PadR("PR",TamSX3("E2_TIPO")[1])
		Endif
	ElseIf !aValInt[1]//Empty(cValInt)
		lRet:= .F.
		lIncluir := .F.
		AADD(aErroRet,STR0003+" " + cValToChar(nX))//"Tipo da Parcela não informado------Item"
	Endif
Endif

If lIncluir
	If aValInt[1]
		cNum := aValInt[2][4]

		If nOpcExec # 5
			If Alltrim (ctpParcel)== AllTrim(cTipo) .And. AllTrim (aValInt[2][6]) =="PR";
			.And. SE2->(dbSeek(xFilial("SE2")+padr(cPrefixo,TamSx3("E2_PREFIXO")[1])+cNum+padr(cPARCEL,TamSx3("E2_PARCELA")[1])+padr("PR",TamSX3("E2_TIPO")[1])+cVendor+cLoja)) .And. Empty (SE2->E2_BAIXA)
				nOpcExec :=6 //substituição de titulos
				nReg:=SE2->(Recno())
			ElseIf Alltrim (ctpParcel)== AllTrim(cTipo) .And. SE2->(dbSeek(xFilial("SE2")+padr(cPrefixo,TamSx3("E2_PREFIXO")[1])+cNum+padr(cPARCEL,TamSx3("E2_PARCELA")[1])+ctpParcel+cVendor+cLoja))
				If (SE2->E2_VALOR > SE2->E2_SALDO) .And. !Empty (SE2->E2_BAIXA) .And. SE2->E2_SALDO > 0
					lAcres := .T.
				ElseIf SE2->E2_VALOR == SE2->E2_SALDO .and. Empty (SE2->E2_BAIXA) .And. SE2->E2_SALDO > 0 .and. SE2->E2_RATEIO == "S"
					lAcres := .T.
				ElseIf SE2->E2_SALDO > 0 .AND. nValor <> SE2->E2_VALOR
					lAcres := .T.
				Endif
			Endif
		Else
			cPrefixo:=aValInt[2][3]
			cParcel:=aValInt[2][5]
			cTpParcel:=aValInt[2][6]
			cVendor:=aValInt[2][7]
			cLoja:=aValInt[2][8]

			If Alltrim (ctpParcel)== AllTrim(cTipo) .And. SE2->(dbSeek(xFilial("SE2")+padr(cPrefixo,TamSx3("E2_PREFIXO")[1])+cNum+padr(cPARCEL,TamSx3("E2_PARCELA")[1])+ctpParcel+cVendor+cLoja))
				lBaixa:=.T.
			Endif
		Endif
	Else
		cNum:=getsxenum("SE2","E2_NUM")
		lXeNum:=.T.

		While .T.
			If SE2->(dbseek(xFilial("SE2")+cPrefixo+cNum+cParcel+cTpParcel+cVendor+cLoja))
				cNum:=getsxenum("SE2","E2_NUM")
				ConfirmSX8()
			Else
				Exit
			Endif
		Enddo
	Endif

	If !lBaixa

		cParcel   := PadR(cParcel  , TamSx3("E2_PARCELA")[1])
		cPrefixo  := PadR(cPrefixo , TamSx3("E2_PREFIXO")[1])
		cNum      := PadR(cNum     , TamSx3("E2_NUM"    )[1])
		cTpParcel := PadR(cTpParcel, TamSx3("E2_TIPO"   )[1])
		cNatureza := PadR(cNatureza, TamSx3("E2_NATUREZ")[1])
		cVendor   := PadR(cVendor  , TamSx3("E2_FORNECE")[1])
		cLoja     := PadR(cLoja    , TamSx3("E2_LOJA"   )[1])

		If nOpcExec == 6
			While .T.
				If SE2->(dbseek(xFilial("SE2")+cPrefixo+cNum+cParcel+cTpParcel+cVendor+cLoja))
					cNum:=Soma1(cNum)
				Else
					Exit
				Endif
			Enddo
		Endif

		aadd( aCab ,{"E2_FILIAL" , xFilial("SE2")	, Nil })
		aadd( aCab ,{"E2_PREFIXO" , cPrefixo	, Nil })
		aadd( aCab ,{"E2_NUM" , cNum, Nil })
		aadd( aCab ,{"E2_PARCELA" , cParcel, Nil })
		aadd( aCab ,{"E2_TIPO" , cTpParcel, Nil })
		aadd( aCab ,{"E2_FORNECE" , cVendor, Nil })
		aadd( aCab ,{"E2_LOJA" , cLoja, Nil })

		//Titulo a ser utilizado no P.E
		cTitE1E2 := "SE2|"+cPrefixo+"|"+cNum+"|"+cParcel+"|"+cTpParcel+"|"+cVendor+"|"+cLoja

		If nOpcExec # 5
			aadd( aCab ,{"E2_NATUREZ" , cNatureza, Nil })
			aadd( aCab ,{"E2_EMISSAO" , dEmissao, Nil })
			aadd( aCab ,{"E2_VENCTO" , dVencimento, Nil })

			If lAcres
				If nValor >= SE2->E2_VALOR//caso o titulo tenha baixa parcial, sera atualizado o valor
					AADD(aCab,{"E2_DECRESC", 0,nil})//do desconto ou do acrescimo. Caso nao exista baixa
					AADD(aCab,{"E2_ACRESC",nValor - SE2->E2_VALOR,nil})//sera atualizado o valor do titulo.
				Else
					AADD(aCab,{"E2_ACRESC",0,nil})
					AADD(aCab,{"E2_DECRESC", SE2->E2_VALOR- nValor,nil})
				Endif
			Else
				aadd( aCab ,{"E2_VALOR" , nValor, Nil })
			Endif

			If Type("oXmlChild:_Interest:Text") #"U"
				nJuros:= Val(oXmlChild:_Interest:Text)
				aadd( aCab ,{"E2_VALJUR" , nJuros, Nil })
			Endif

			If Type("oXmlChild:_Fine:Text") #"U"
				nPorcJur:= Val(oXmlChild:_Fine:Text)
				If nPorcJur >= 100
					lRet:= .F.
					lIncluir:=.F.
					AADD(aErroRet,STR0028+" " + cValToChar(nX))//'Porcentagem de juros não pode ser igual ou superior a 100% --------Item'
				Else
					aadd( aCab ,{"E2_PORCJUR" , nPorcJur, Nil })
				Endif
			Endif

			aadd( aCab ,{"E2_MOEDA" , nMoeda, Nil })
			aadd( aCab ,{"E2_HIST" , SubSTR(cHist,1,TamSX3("E2_HIST")[1]), Nil })
			aadd( aCab ,{"E2_ORIGEM" , "FINI055", Nil })

			If nOpcExec == 3 .or. nOpcExec==6
				IncluiSEV(@aRatEvEz,cMarca,cNatureza,nValor,@nCC,@lRet,@lIncluir,@aErroRet)
				If !Empty(aRatEvEz) .And. nCC >= 1
					aadd(aCab,{"E2_MULTNAT" , "1", Nil })
				Else
					aadd(aCab,{"E2_MULTNAT" , "2", Nil })
				Endif
			Endif

			IF nOpcExec==6
				SE2->(dbGoto(nReg))
				aadd( aAltera ,{ {"E2_FILIAL" , xFilial("SE2")	, Nil };
					,{"E2_PREFIXO" , SE2->E2_PREFIXO	, Nil };
					,{"E2_NUM" , SE2->E2_NUM, Nil };
					,{"E2_PARCELA" , SE2->E2_PARCELA, Nil };
					,{"E2_TIPO" , SE2->E2_TIPO, Nil };
					,{"E2_NATUREZ" , SE2->E2_NATUREZ, Nil };
					,{"E2_FORNECE" , SE2->E2_FORNECE, Nil };
					,{"E2_LOJA" , SE2->E2_LOJA, Nil };
					,{"E2_EMISSAO" , SE2->E2_EMISSAO, Nil };
					,{"E2_VENCTO" , SE2->E2_VENCTO, Nil };
					,{"E2_VALOR" , SE2->E2_VALOR, Nil };
					,{"E2_MOEDA" , SE2->E2_MOEDA, Nil };
					,{"E2_ORIGEM" , "FINI055", Nil } })
			Endif
		Endif

		IF nOpcExec # 3
			SetFunName('FINA050')
		Endif

		If ExistBlock("F055E2") .and. nOpcExec == 3
			aRetPe := ExecBlock("F055E2",.F.,.F.,{aCab,aRatEvEz})
			If ValType(aRetPe) == "A" .And. Len(aRetPe) > 0
				lRet := .T.
				lIncluir := .T.
				If ValType(aRetPe[1]) == "A"
					aCab		:= aClone(aRetPe[1])
				EndIf
				If ValType(aRetPe[2]) == "A"
					aRatEvEz	:= aClone(aRetPe[2])
					If !Empty(aRatEvEz) .And. nCC >= 1
						aAdd(aCab,{"AUTRATEEV",ARatEvEz,Nil})
					Endif
				EndIf
			EndIf
		Else
			If !Empty(aRatEvEz) .And. nCC >= 1
				aAdd(aCab,{"AUTRATEEV",ARatEvEz,Nil})
			Endif
		EndIf

		If lRet
			MsExecAuto( { |x,y,z,a,b,c,d,e,f| FINA050(x,y,z,a,b,c,d,e,f)} , aCab,nOpcExec ,nOpcExec,,,,,,aAltera)

			If lMsErroAuto
				aErroAuto := GetAutoGRLog()

				For nCount2 := 1 To Len(aErroAuto)
					AADD(aErroRet,StrTran(StrTran(StrTran(aErroAuto[nCount2],"<"," "),"-"," "),"/"," ")+" ")
				Next nCount2

				lIncluir:=.F.
				lRet:=.F.
			Else
				If lFRU .And. nOpcExec # 5
					If Type ("oXmlChild:_ListOfComponent:_Component[1]")# "U"
						nCountCc:=len(oXmlChild:_ListOfComponent:_Component)
					ElseIf Type ("oXmlChild:_ListOfComponent:_Component")# "U"
						nCountCc:=1
					Else
						nCountCc:=0
					Endif

					cCompDesc:=''
					cCompCod:=''
					nCompVal:=0

					For nXaux:=1 to nCountCc
						If nCountCc>1
							oXmlAux:=oXmlChild:_ListOfComponent:_Component[nXaux]
						Else
							oXmlAux:=oXmlChild:_ListOfComponent:_Component
						Endif

						If Type ("oXmlAux:_Code:Text")#"U" .and.!Empty(oXmlAux:_Code:Text)
							cCompCod:=Padr(oXmlAux:_Code:Text,TamSx3("FRU_COD")[1])
						Endif

						If Type ("oXmlAux:_Value:Text")#"U" .and.!Empty(oXmlAux:_Value:Text)
							nCompVal:=Val(oXmlAux:_Value:Text)
						Endif

						If Type ("oXmlAux:_Name:Text")#"U" .and.!Empty(oXmlAux:_Name:Text)
							cCompDesc:=Padr(oXmlAux:_Name:Text,TamSx3("FRU_DESC")[1])
						Endif

						If !Empty(cCompCod) .and. !Empty(cCompDesc) .and. nCompVal <> 0
							If nOpcExec == 3 .or. nOpcExec ==6
								RecLock("FRU",.T.)
							ElseIf nOpcExec==4 .And. FRU->(dbSeek(xFilial("FRU")+cCompCod+cPrefixo+cNum+cParcel+cTpParcel+cVendor+cLoja))
								RecLock("FRU",.F.)
							Else
								RecLock("FRU",.T.)
							Endif
							FRU->FRU_FILIAL:=xFilial("FRU")
							FRU->FRU_COD:=cCompCod
							FRU->FRU_PREFIX:=cPrefixo
							FRU->FRU_NUM:=cNum
							FRU->FRU_PARCEL:=cParcel
							FRU->FRU_TIPO:=cTpParcel
							FRU->FRU_DESC:=cCompDesc
							FRU->FRU_VALOR:=nCompVal
							FRU->FRU_FORNEC:=cVendor
							FRU->FRU_LOJA:=cLoja
							FRU->(MsUnlock())
						ElseIf (Empty(cCompDesc) .and. !Empty(cCompCod)) .or. (!empty(Ccompdesc) .and. Empty(Ccompcod))
							lRet:=.F.
							lInclui:=.F.
							AADD(aErroRet,STR0023+ " " + cValToChar(nX))//"Problemas com o envio dos componentes da parcela------------item"
						Endif
					Next nCountCc
				ElseIf lFRU .and. nOpcExec==5
					cAliasTMP:=GetNextAlias()

					cQuery:="Select * From " + RetSqlName("FRU")
					cQuery+=" where FRU_PREFIX = '"+cPrefixo+"' and FRU_NUM ='" +cNum +"'"
					cQuery+=" and FRU_PARCEL ='"+cParcel+"' and FRU_TIPO ='"+cTpParcel+"' and FRU_FILIAL='"+xFilial("FRU")+"' And"
					cQuery+=" FRU_FORNEC='"+cvendor+"' and FRU_LOJA='"+cLoja+"'"

					cQuery:=ChangeQuery(cQuery)

					If Select(cAliasTMP)>0
						(cAliasTMP)->(dbCloseArea())
					Endif

					dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

					If Select(cAliasTMP)>0
						(cAliasTMP)->(dbGoTop())

						While (cAliasTmp)->(!EOF())
							If FRU->(dbSeek(xFilial("FRU")+(cAliasTmp)->FRU_COD+(cAliasTMP)->FRU_PREFIX+(cAliasTMP)->FRU_NUM+(cAliasTMP)->FRU_PARCEL+(cAliasTMP)->FRU_TIPO+(cAliasTMP)->FRU_FORNEC+(cAliasTMP)->FRU_LOJA))
								RecLock("FRU")
								FRU->(dbDelete())
								FRU->(MsUnlock())
							Endif
							(cAliasTMP)->(dbSkip())
						EndDo
						(cAliasTMP)->(dbCloseArea())
					Endif
				Endif

				If !aValInt[1]//Empty(cValInt)
					cValInt:= F55MontInt(,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO ,SE2->E2_FORNECE,SE2->E2_LOJA,'SE2')//(SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA)
				Endif

				If nOpcExec==6
					CFGA070Mnt(, cAlias,cCampo,, cValInt,.T. )
					SE2->(dbSeek(xFilial("SE2")+padr(cPrefixo,TamSx3("E2_PREFIXO")[1])+cNum+padr(cPARCEL,TamSx3("E2_PARCELA")[1])+cTpParcel))
					cValInt:= F55MontInt(,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO ,SE2->E2_FORNECE,SE2->E2_LOJA,'SE2')//(SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA)
				Endif

				If nOpcExec == 3 .Or. nOpcExec == 6 //substituicao automatica
					CFGA070Mnt( cMarca, cAlias,cCampo, cValExt, cValInt )
					AADD(aVale,cValExt)
					AADD(aVali,cValInt)
				ElseIf nOpcExec == 5
					CFGA070Mnt(, cAlias,cCampo,, cValInt,.T. )
				Endif
			Endif
		EndIf
	Else
		aVetor	:= 	{{"E2_PREFIXO"	, cPrefixo 		,Nil},;
				{"E2_NUM"		, cNum       	,Nil},;
				{"E2_PARCELA"	, cParcel 		,Nil},;
				{"E2_TIPO"	    , cTpParcel     		,Nil},;
				{"E2_FORNECE"	, cVendor  		,Nil},;
				{"E2_LOJA"	    , cLoja     		,Nil},;
				{"AUTMOTBX"	    , "TIN"             	,Nil},;
				{"AUTDTBAIXA"	, dDataBase				,Nil},;
				{"AUTDTDEB"		, dDataBase				,Nil},;
				{"AUTHIST"	    , STR0021,Nil},;	 //"Baixa realizada pelo TIN"
				{"AUTTXMOEDA"	, RecMoeda(dDataBase,SE2->E2_MOEDA) ,Nil}}
		//Titulo a ser utilizado no P.E
		cTitE1E2 := "SE2|"+cPrefixo+"|"+cNum+"|"+cParcel+"|"+cTpParcel+"|"+cVendor+"|"+cLoja

		MSExecAuto({|x,y| Fina080(x,y)},aVetor,3)

		If lMsErroAuto
			aErroAuto := GetAutoGRLog()

			For nCount2 := 1 To Len(aErroAuto)
				AADD(aErroRet,StrTran(StrTran(StrTran(aErroAuto[nCount2],"<"," "),"-"," "),"/"," ")+" ")
			Next nCount2

			lIncluir:=.F.
			lRet:=.F.
		Else
			CFGA070Mnt(, cAlias,cCampo,, cValInt,.T. )
		Endif
	Endif
Endif

If lXenum
	FreeUsedCode(.T.)
EndIf

RestArea(aAreaSE2)

If lFRU
	RestArea(aAreaFRU)
Endif

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IncluiSA2 ºAutor  ³Jandir Deodato      º Data ³ 21/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Criação de fornecedor a partir de um cliente cadastrado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IncluiSA2(cValForn,cMarca,lRet,lIncluir,aErroRet)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Esta função criara um fornecedor a partir de um cliente     º±±
±±º          ³existente na base protheus, este enviado pela integraçao    º±±
±±º          ³Protheus X TIN. Nota: Nos sistemas RM não existe diferencia-º±±
±±º          ³cao entre Cliente e Fornecedor.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fini055                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IncluiSA2(cValForn,cMarca,lRet,lIncluir,aErroRet)

Local aAreaSA2	:= {}
Local aAreaSA1	:= {}
Local aArea 	:= GetARea()
Local aCab 		:= {}
Local aAux		:= {}
Local cCliVer   := ''
Local cVendor	:= ''
Local cLoja		:= ''
Local nCount2	:= 0

dbSelectArea("SA2")
aAreaSA2:=SA2->(GetArea())
SA2->(dbSetOrder(1))

dbSelectArea("SA1")
aAreaSA1:=SA1->(GetArea())
SA1->(dbSetOrder(1))

cCliVer := MsgUVer('MATA030', 'CUSTOMERVENDOR')
If !empty(cCliVer)
	aAux := IntCliInt(oXmlChild:_CustomerVendorId:Text, cMarca, cCliVer)
	If aAux[1]
		If cCliVer = '1.'
			cValForn := Padr(aAux[2][1], TamSx3("A1_COD")[1]) + Padr(aAux[2][2], TamSX3("A1_LOJA")[1])
		Else
			cValForn := Padr(aAux[2][3], TamSx3("A1_COD")[1]) + Padr(aAux[2][4], TamSX3("A1_LOJA")[1])
		Endif
	Endif

	If SA1->(dbSeek(xFilial("SA1")+cValForn))
		cLoja := SubStr(cvalForn,TamSX3("A2_COD")[1]+1,TamSX3("A2_LOJA")[1])
		cVendor :=SubStr(cValForn,1,TamSX3("A2_COD")[1])

		While .T.
			If SA2->(dbSeek (xFilial("SA2")+cVendor+cLoja))
				cVendor:=GetSxeNum("SA2","A2_COD")
				ConfirmSx8()
			Else
				Exit
			Endif
		EndDo

		AAdd(aCab,{"A2_FILIAL",xFilial("SA2"),nil})
		AAdd(aCab,{"A2_COD",cVendor,nil})
		AAdd(aCab,{"A2_LOJA",cLoja,nil})
		AAdd(aCab,{"A2_NOME",SA1->A1_NOME,nil})
		AAdd(aCab,{"A2_NREDUZ",SA1->A1_NREDUZ,nil})
		AAdd(aCab,{"A2_NOME",SA1->A1_NOME,nil})
		AAdd(aCab,{"A2_END",SA1->A1_END,nil})
		AAdd(aCab,{"A2_BAIRRO",SA1->A1_BAIRRO,nil})
		AAdd(aCab,{"A2_EST",SA1->A1_EST,nil})
		AAdd(aCab,{"A2_COD_MUN",SA1->A1_COD_MUN,nil})
		AAdd(aCab,{"A2_MUN",SA1->A1_MUN,nil})
		AAdd(aCab,{"A2_CEP",SA1->A1_CEP,nil})

		IF Empty(SA1->A1_PESSOA)
			AAdd(aCab,{"A2_TIPO",Padr("X",TAmSX3("A2_TIPO")[1]),nil})
		Else
			AAdd(aCab,{"A2_TIPO",SA1->A1_PESSOA,nil})
		Endif
		If cPaisLoc $ "BRA|COL|PER"
			AAdd(aCab,{"A2_PFISICA",SA1->A1_PFISICA,nil})
		EndIf
		AAdd(aCab,{"A2_CGC",SA1->A1_CGC,nil})
		AAdd(aCab,{"A2_DDI",SA1->A1_DDI,nil})
		AAdd(aCab,{"A2_DDD",SA1->A1_DDD,nil})
		AAdd(aCab,{"A2_TEL",SA1->A1_TEL,nil})
		AAdd(aCab,{"A2_FAX",SA1->A1_FAX,nil})
		AAdd(aCab,{"A2_INSCR",SA1->A1_INSCR,nil})
		AAdd(aCab,{"A2_INSCRM",SA1->A1_INSCRM,nil})
		AAdd(aCab,{"A2_PAIS",SA1->A1_PAIS,nil})

		MSExecAuto({|x,y| MATA020(x,y)},aCab,3)

		If lMsErroAuto
			AADD(aErroRet,STR0026 )//"Não foi encontrado um fornecedor para este título e nao foi possível inlcuir um fornecedor a partir do cliente enviado."
			aErroAuto := GetAutoGRLog()
			AADD(aErroRet,CRLF)

			For nCount2 := 1 To Len(aErroAuto)
				AADD(aErroRet,StrTran(StrTran(StrTran(aErroAuto[nCount2],"<"," "),"-"," "),"/"," ")+" ")
			Next nCount2

			lIncluir:=.F.
			lRet:=.F.
		Else
			If cCliVer = '1'
				CFGA070Mnt( cMarca, "SA2", "A2_COD", oXmlChild:_CustomerVendorId:Text, SA2->A2_COD+SA2->A2_LOJA )
			Else
				CFGA070Mnt( cMarca, "SA2", "A2_COD", oXmlChild:_CustomerVendorId:Text, IntForExt(, , SA2->A2_COD, SA2->A2_LOJA, cCliVer)[2])
			Endif
			cValForn:=SA2->A2_COD+SA2->A2_LOJA
		Endif
	Else
		AADD(aErroRet,STR0027)//"Não foi encontrado um fornecedor para este título e não foi possível encontrar um cliente com o código enviado."
	Endif
Endif

RestArea(aAreaSA2)
RestArea(aAreaSA1)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IncluiSEV ºAutor  ³Jandir Deodato      º Data ³ 24/09/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Criação do array de rateio MultiNaturezas e Centro de custo ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IncluiSEV()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fini055                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IncluiSEV(aRatEv,cMarca,cNatureza,nValor,nCC,lRet,lIncluir,aErroRet)

Local nX			:= 0
Local nCountCC	:= 0
Local cCusto		:= " "
Local aRatEz		:= {}
Local aRat			:= {}
Local aRataux		:= {}
Local aCusto		:= {}
Local nValRateio 	:= 0
local cItemCta	:= SPACE(TamSX3("EZ_ITEMCTA")[1])
Local cCLVL		:= SPACE(TamSX3("EZ_CLVL")[1])
Local cCONTA		:= SPACE(TamSX3("EZ_CONTA")[1])
Local cContaGer	:= ""
Local cVersaoCust := MsgUVer('CTBA030', 'COSTCENTER')
Local aArea		:= GetArea()
Local cEntGer		:= Alltrim(SuperGetMV("MV_CTBCGER",.F.,""))
Local cCpoGerD	:= ""
Local cCpoGerC	:= ""

Private oXmlAux	:= Nil

dbSelectArea("CT0")
CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID
If !Empty(cEntGer)
	If CT0->(dbSeek(xFilial("CT0") + cEntGer))
		cCpoGerD := "EZ_EC"+cEntGer+"DB"
		cCpoGerC := "EZ_EC"+cEntGer+"CR"
		cContaGer := SPACE(TamSX3(cCpoGerD)[1])
	EndIf
EndIf

If Type ("oXmlChild:_ApportDistribution:_Apport[1]") #"U"
	nCountCc:=Len(oXmlChild:_ApportDistribution:_Apport)
ElseIf Type ("oXmlChild:_ApportDistribution:_Apport") #"U"
	nCountCc:=1
Else
	nCountCc:=0
Endif

nCC	 := nCountCc

For nX:=1 to nCountCc
	If nCountCc >1
		oXmlAux:= oXmlChild:_ApportDistribution:_Apport[nX]
	Else
		oXmlAux:=oXmlChild:_ApportDistribution:_Apport
	Endif

	cCusto :=" "
	nValRateio := 0
	aRatAux:={}

	//Centro de custo
	If Type("oXmlAux:_CostCenterInternalId:Text")#"U" .And.!Empty(oXmlAux:_CostCenterInternalId:Text)
		aCusto := IntCusInt(oXmlAux:_CostCenterInternalId:Text, cMarca, cVersaoCust)

		If aCusto[1]
			If cVersaoCust = '1'
				cCusto:=aCusto[2][2]
			Else
				cCusto:=aCusto[2][3]
			Endif
		Else
			lRet := .F.
			lIncluir := .F.
			AADD(aErroRet,aCusto[2])//"Centro de Custo não encontrado no de/para!"
		Endif
	Endif

	If Empty(cCusto) .And. Type("oXmlAux:_CostCenterCode:Text")#"U" .And.!Empty(oXmlAux:_CostCenterCode:Text)
		aCusto:=IntCusInt( oXmlAux:_CostCenterCode:Text, cMarca, cVersaoCust)

		If aCusto[1]
			If cVersaoCust = '1'
				cCusto:=aCusto[2][2]
			Else
				cCusto:=aCusto[2][3]
			Endif
		Else
			lRet := .F.
			lIncluir := .F.
			AADD(aErroRet,aCusto[2])//"Centro de Custo não encontrado no de/para!"
		Endif
	Endif

	aadd( aRataux ,{"EZ_CCUSTO" , cCusto, Nil })

	//Item Contábil
	If Type("oXmlAux:_AccountingItemInternalId:Text")#"U" .And.!Empty(oXmlAux:_AccountingItemInternalId:Text)

		cValExt := oXmlAux:_AccountingItemInternalId:Text
		aResult := C040AGetInt(cValExt, cMarca)
		If aResult[1]
			cItemCta := aResult[2][3]
		EndIf
	Endif

	If Empty(cItemCta) .And. Type("oXmlAux:_AccountingItem:Text")#"U" .And.!Empty(oXmlAux:_AccountingItem:Text)
		cItemCta := oXmlAux:_AccountingItem:Text
	EndIf

	aadd( aRataux ,{"EZ_ITEMCTA" , cItemCta , Nil })

	//Classe de Valor
	If Type("oXmlAux:_ClassValueInternalId:Text")#"U" .And.!Empty(oXmlAux:_ClassValueInternalId:Text)
		cValExt := oXmlAux:_ClassValueInternalId:Text
		aRet := C060GetInt(cValExt, cMarca)
		If aRet[1]
			cCLVL := aRet[2][3]
		EndIf
	Endif

	If Empty(cCLVL) .And. Type("oXmlAux:_ClassValue:Text")#"U" .And.!Empty(oXmlAux:_ClassValue:Text)
		cCLVL := oXmlAux:_ClassValue:Text
	EndIf
	aadd( aRataux ,{"EZ_CLVL" , cCLVL , Nil })

	//Conta Gerencial
	If !Empty(cCpoGerD)
		If Type("oXmlAux:_ManagerialAccountingEntityInternalId:Text")#"U" .And.!Empty(oXmlAux:_ManagerialAccountingEntityInternalId:Text)
			cValExt := oXmlAux:_ManagerialAccountingEntityInternalId:Text
			aRet := IntGerInt(cValExt, cMarca)
			If aRet[1]
				cContaGer := aRet[2][4]
			EndIf
		Endif

		If Empty(cContaGer) .And. Type("oXmlAux:_ManagerialAccountingEntity:Text")#"U" .And.!Empty(oXmlAux:_ManagerialAccountingEntity:Text)
			cContaGer := oXmlAux:_ManagerialAccountingEntity:Text
		EndIf
		aadd( aRataux ,{cCpoGerD, cContaGer , Nil })
		aadd( aRataux ,{cCpoGerC, cContaGer , Nil })
	EndIf

	If Type ("oXmlAux:_Value:Text")#"U" .and. !Empty(oXmlAux:_Value:Text)
		nValRateio:= Val(oXmlAux:_Value:Text)
	Endif

	aadd( aRataux ,{"EZ_VALOR" , nValRateio, Nil })

	aadd( aRataux ,{"EZ_CONTA" , cCONTA , Nil })

	aadd(aRatEz,aRatAux)
Next nX

If nCountCC >0
	aadd( aRat ,{"EV_NATUREZ" , padr(cNatureza,tamsx3("EV_NATUREZ")[1]), Nil })
	aadd( aRat ,{"EV_VALOR" , nValor, Nil })
	aadd( aRat ,{"EV_PERC" , 100, Nil })
	aadd( aRat ,{"EV_RATEICC" , "1", Nil })
	aadd( aRat,{"AUTRATEICC" , aRatEz, Nil })

	aAdd(aRatEv,aRat)
Endif

RestArea(aArea)


Return

//-------------------------------------------------------------------
/*{Protheus.doc} F55GetInt
Recebe um codigo, busca seu internalId e faz a quebra da chave

@param   cCode		 InternalID recebido na mensagem.
@param   cMarca      Produto que enviou a mensagem
@param   cAlias     	Alias do registro impactado

@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  aRetorno Array contendo os campos da chave primaria do titulo a pagar/receber e o seu internalid.
			obs: A chave unica do titulo a receber possui duas posiçoes a menos ( Fornecedor e Loja)

@sample  exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Prefixo', 'Numero', 'Parcela','Tipo','Fornecedor','Loja'},InternalId}
*/										//   01          02         03        04          05      06     07          08
//-------------------------------------------------------------------

Function F55GetInt(cCode, cMarca,cAlias)

Local cValInt	:= ''
Local cCampo	:= ''
Local aRetorno:= {}
Local aAux		:= {}
Local nX		:= 0
Local aCampos	:= {cEmpAnt,'E2_FILIAL','E2_PREFIXO','E2_NUM','E2_PARCELA','E2_TIPO','E2_FORNECE','E2_LOJA'}

Default cAlias:= "SE1"// a mensagem é usada normalmente para titulos a receber.

If AllTrim(Upper(cAlias))=="SE1"
	cCampo:="E1_NUM"
ElseIf AllTrim(Upper(cAlias))=="SE2"
	cCampo:="E2_NUM"
Endif

cValInt:= CFGA070Int(cMarca, cAlias, cCampo, cCode)

If !Empty(cValInt)
	aadd(aRetorno,.T.)

	aAux:=Separa(cValInt,'|')

	aadd(aRetorno,aAux)
	aadd(aRetorno,cValInt)

	aRetorno[2][1]:=Padr(aRetorno[2][1],Len(cEmpAnt))

	For nx:=2 to len (aRetorno[2])//corrigindo  o tamanho dos campos
		aRetorno[2][nX]:=Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
	Next nx
Else
	aadd(aRetorno,.F.)
Endif

Return aRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} F55MontInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cFil		Filial do Registro
@Param		cPrefix	Prefixo do titulo
@param		cNum		Numeo do titulo
@param		cparcel	parcela do titulo
@param		cTipo		Tipo do titulo
@param		cfornece	Fornecedor do titulo
@param		cLoja		Loja do título
@param   cAlias      alias do registro impactado.

@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  cRetorno - Retorna o InternalId do registro

@sample  exemplo de retorno - {'Empresa'|'xFilial'|'Prefixo'|'Numero'|'Parcela'|'Tipo'|'Fornecedor'|'Loja'}}
				obs: A chave unica do titulo a receber possui duas posiçoes a menos ( Fornecedor e Loja)
*/
//-------------------------------------------------------------------
Function F55MontInt(cFil,cPrefix,cNum,cParcel,cTipo,cFornece,cLoja,cAlias)

Local cRetCode	:= ''

Default cAlias	:= "SE1"
Default cFornece	:= ''
Default cLoja		:= ''
Default cFil		:= xFilial(cAlias)

cFil:=xFilial(cAlias,cFil)

If cAlias=='SE1'
	cRetCode:=cEmpAnt+'|'+RTrim(cFil)+'|'+RTrim(cPrefix)+'|'+RTrim(cNum)+'|'+RTrim(cParcel)+'|'+RTrim(cTipo)
ElseIf cAlias=='SE2'
	cRetCode:=cEmpAnt+'|'+rTrim(cFil)+'|'+RTrim(cPrefix)+'|'+RTrim(cNum)+'|'+RTrim(cParcel)+'|'+RTrim(cTipo)+'|'+rTrim(cFornece)+'|'+RTrim(cLoja)
Endif

Return cRetCode

/*/{Protheus.doc} MsgUVer
	Função que verifica a versão de uma mensagem única cadastrada no adapter EAI.

	Essa função deverá ser EXCLUÍDA e substituída pela função FwAdapterVersion()
	após sua publicação na Lib de 2019.

	@param cRotina		Rotina que possui a IntegDef da Mensagem Unica
	@param cMensagem	Nome da Mensagem única a ser pesquisada

	@author		Felipe Raposo
	@version	P12
	@since		23/11/2018
	@return		xVersion - versão da mensagem única cadastrada. Se não encontrar, retorna nulo.
/*/
Static Function MsgUVer(cRotina, cMensagem)

Local aArea    := GetArea()
Local xVersion

xVersion := FwAdapterVersion(cRotina, cMensagem)

RestArea(aArea)

Return xVersion

//-------------------------------------------------------------------
/*{Protheus.doc} CtbVenda(cOpc,nTotVenda,cHist)
	Função que contabilizara o total da venda

	@param	cOpc      Opção desejada ("D" - Deleta, "I" - Inclusão)
	@param nTotVenda Valor total a ser contabilizado
	@param	cHist     Histórico
	@param	cTitE1E2  Numero do ultimo titulo para ser posicionado
	@param	cOpcVenda Opção de contabilização (IV - Inclusão do total da venda
	                                          IR - Inclusão do valor de reajuste
	                                          EV - Exclusão do total da venda
	                                          ER - Exclusão do valor de reajuste

	@author	Rodrigo Machado Pontes
	@version	P11
	@since	17/03/2013
*/
//-------------------------------------------------------------------

Static Function CtbVenda(cOpc,nTotVenda,cHist,cTitE1E2,cOpcVenda)

Local cLPInc		:= "51B" //Lançamento Padrão (Inclusão)
Local cLPExc		:= "51C" //Lançamento Padrão (Exclusão)
Local cLP			:= ""
Local cLote		:= ""
Local cArquivo	:= ""
Local nHdlPrv		:= 0
Local nTotal		:= 0
Local lPadrao		:= Nil
Local aFlagCTB	:= {}
Local aDiario		:= {}
Local aTitE1E2	:= {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)

Pergunte("FIN040",.F.)

If !Empty(cTitE1E2)
	aTitE1E2 := Separa(cTitE1E2,"|")
	If Len(aTitE1E2) == 5 //SE1
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		SE1->(DbGotop())
		SE1->(DbSeek( xFilial("SE1") + aTitE1E2[2] + aTitE1E2[3] + aTitE1E2[4] + aTitE1E2[5]))
	Endif
Endif

__nTINVCTB := nTotVenda
__cTINHCTB := cOpcVenda + " " + Iif(cOpc=="I",cHist,SE1->E1_HIST)

If cOpc == "I"
	If cOpcVenda <> "ER"
		cLP := cLPInc
	Else
		cLP := cLPExc
	Endif
Else
	cLP := cLPExc
Endif

lPadrao := VerPadrao(cLP)
If lPadrao .And. MV_PAR03 == 1 //Contabilização Online
	If nHdlPrv <= 0
		nHdlPrv := HeadProva(cLote,"FINA040",Substr(cUsuario,7,6),@cArquivo)
	Endif

	If nHdlPrv > 0
		nTotal += DetProva( nHdlPrv, cLP, "FINA040", cLote, /*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/,;
							  /*aCT5*/,/*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
	Endif
Endif

IF lPadrao .And. nTotal  > 0 .And. MV_PAR03 == 1 //Contabilização Online

	RodaProva(nHdlPrv,nTotal)

	cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, .F. /*lDigita*/, .F. /*lAglut*/,;
	           /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, aDiario )

	aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
Endif

If lPadrao .And. MV_PAR03 == 1 //Contabilização Online
	If !lUsaFlag .and. cLP == "51B" // Contabilizacao atraves do modulo contabil.
		 Reclock("SE1")
		 Replace E1_LA With "S"
		 MsUnlock()
	Endif
Endif

Return .T.
