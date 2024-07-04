#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'CTBI102.CH'

Static lCTBA030 := .F.
Static lCTBA040 := .F.
Static lCTBA060 := .F.
Static lCTBA800a := .F.
Static lCTBA140 := .F.
Static lCTBA020 := .F.
Static _aSoma1 := NIL
Static nLinCT2	:= 0
Static cMessage := 'AccountingEntry' //Nome da Mensagem Única

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBI102
Funcao de integracao com o adapter EAI para envio e recebimento do cadastro de lançamentos contábeis
utilizando o conceito de mensagem unica.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@author	marylly.araujo
@since		12/11/2013
@version	MP11.90
@obs		Nenhuma observação

/*/
//-------------------------------------------------------------------
Function CTBI102(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Local cXmlRet		:= ''
Local cXmlAux 		:= ''
Local cErroXml		:= ''
Local cWarnXml		:= ''
Local aErroAuto		:= {}
Local cLogErro		:= ''
Local nCount			:= 0
Local lRet				:= .T.
Local cCT2ValInt		:= ''
Local aCT2ValInt		:= {}
Local cValExt			:= ''
Local cValInt			:= ''
Local cMarca			:= ''
Local aCT2Area		:= {}
Local aCab				:= {}
Local nOpcExec		:= 0
Local aItens			:= {}
Local cLote			:= ''
Local cSubLote		:= STRZERO(1,TamSX3("CT2_SBLOTE")[1])
Local cDoc				:= STRZERO(1,TamSX3("CT2_DOC")[1])
Local dDataLanc		:= CTOD("  \  \  ")
Local aAux				:= {}
Local cVersao			:= ''
Local cModuloAnt		:= cModulo
Local oXmlAux			:= Nil
Local cTipoNo			:= ""
Local aMoedaInt		:= {}
Local cMoeVer			:= ""
Local aItensAux		:= {}
Local nPosicao		:= 0
Local nY				:= 0
Local nX				:= 0
Local aDeletado		:= {}
Local cCT2ValExt		:= ""
Local cLock			:= "CTBI102LOCK"
Local cEntGer			:= SuperGetMV("MV_CTBCGER",.F.,"")
Local cPlano			:= ""


Local nPosHist
Local cHistAux
Local aAuxHist
Local aItensHist
Local nHist
Local nZ
Local cCampo
Local cLinAux := ""
Local cQuery := ""
Local cArqTrab := GetNextAlias()

Private lMsErroAuto	:= .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile	:= .T.
Private oXmlCTB102		:= Nil
Private CTF_LOCK		:= 0
Private lSubLote 		:= .T.

lCTBA030 		:= FWHasEAI("CTBA030",.T.,,.T.)
lCTBA040 		:= FWHasEAI("CTBA040",,,.T.)
lCTBA060 		:= FWHasEAI("CTBA060",,,.T.)
lCTBA800a 		:= FWHasEAI("CTBA800A",,,.T.)
lCTBA140		:= FWHasEAI("CTBA140",,,.T.)
lCTBA020 		:= FWHasEAI("CTBA020",,,.T.)
lCTBA102 		:= FWHasEAI("CTBA102",,,.T.)

If _aSoma1 == NIL
	RstSoma1()
EndIf

cModulo := "CTB"

DbSelectArea("CT2")
aCT2Area := CT2->(GetArea())
CT2->(DbSetOrder(1)) // Filial + Data de Movimento + Lote + SubLote + Documento

dbSelectArea("CT0")
CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID
If !Empty(cEntGer)
	If !CT0->(dbSeek(xFilial("CT0") + cEntGer))
		lRet    := .F.
		cXmlRet := STR0009 // "A entidade selecionada no parametro MV_CTBCGER não está cadastrada, verificar cadastro de entidades adicionais"
		Return {lRet, cXmlRet}
	Else
		cPlano := cEntGer
	EndIf
EndIf


//Se for envio de mensagem, somente retorna o XML informado na chamada da IntegDef, pois o XML está sendo montado
//Em outra função, quebrando o xml de acordo com um limite de linhas de lançamento.
If cTypeTrans == TRANS_SEND

	cXMLRet := cXml

ElseIf cTypeTrans == TRANS_RECEIVE
	If cTypeMsg == EAI_MESSAGE_BUSINESS
		oXmlCTB102 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

		If oXmlCTB102 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
			If ( XmlChildEx( oXmlCTB102:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )

				//Versão da Mensagem Única
				If XmlChildEx( oXmlCTB102:_TOTVSMessage:_MessageInformation, '_VERSION') <> Nil
					cVersao := StrTokArr(oXmlCTB102:_TOTVSMessage:_MessageInformation:_Version:Text, ".")[1]
				Else
					lRet    := .F.
					cXmlRet := OemToAnsi(STR0008) //"Versão da mensagem não informada!"
				EndIf

				If lRet
					//Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
					If XmlChildEx( oXmlCTB102:_TOTVSMessage:_MessageInformation:_Product, '_NAME') <> Nil
						cMarca :=  oXmlCTB102:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
					EndIf

					//Recebe o codigo da Conta no Cadastro externo e guarda na variavel cValExt
					If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage, '_BUSINESSEVENT') <> Nil

						If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage, '_BUSINESSCONTENT') <> Nil
							//Número do lote
							If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_INTERNALID') <> Nil
								cCT2ValExt := oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
							EndIf
						EndIf

						If Empty(cCT2ValExt)
							If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessEvent, '_IDENTIFICATION') <> Nil
								cCT2ValExt := oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text
							EndIf
						EndIf

						//Apenas verifica se existe o Registro no XXF para saber se é Inclusão, Alteração ou Exclusão
						If !Empty(cCT2ValExt)
							aCT2ValInt := C102GetInt(cCT2ValExt, cMarca)
							If aCT2ValInt[1] // Registro encontrado na integração
								cCT2ValInt := aCT2ValInt[3]
							EndIf
						Else
							aAdd(aCT2ValInt,.F.)
						EndIf

						//Verifica o tipo de operação a ser realizada, com base no valor da TAG <Event>
						If Upper(oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
							//Se o ID do lançamento já estiver cadastrado, é alteração(4), senão, é inclusão (3)
							IF aCT2ValInt[1]
								cData		:= AllTrim(aCT2ValInt[2][3])
								cLote		:= AllTrim(aCT2ValInt[2][4])
								cSubLote	:= AllTrim(aCT2ValInt[2][5])
								cDoc		:= AllTrim(aCT2ValInt[2][6])
								CT2->(dbSetOrder(1))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
								If CT2->(MsSeek(xFilial("CT2") + cData + cLote + cSubLote + cDoc ))
									nOpcExec := 4

									/* Tratamento para execução com mais de 1 xml
									   quando for continuação do primeiro, identificado
									   pela tag <item> 
									*/
									cQuery := " SELECT MAX(CT2_LINHA) CT2LIN FROM "  + RetSqlName("CT2")									
									cQuery += "  WHERE CT2_FILIAL  = '" + xFilial("CT2") + "' "
									cQuery += "  AND CT2_DATA = '" + cData + "' "
									cQuery += "  AND CT2_LOTE = '" + cLote + "' "
									cQuery += "  AND CT2_SBLOTE = '" + cSubLote + "' "
									cQuery += "  AND CT2_DOC = '" + cDoc + "' "									
									cQuery += "  AND D_E_L_E_T_ = ' ' "

									cQuery := ChangeQuery(cQuery)

									DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cArqTrab,.F.,.T.)
									
									nLinCT2 := DecodSoma1(Soma1((cArqTrab)->CT2LIN))

									(cArqTrab)->(dbCloseArea())
																		
								Else
									nOpcExec := 3									
								EndIf
							Else
								nOpcExec := 3								
							Endif
						ElseIf Upper(oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
							//Se o ID do lançamento não estiver cadastrado, retorna erro na exclusão
							IF aCT2ValInt[1]
								nOpcExec := 5
							Else
								lRet    := .F.
								cXmlRet := "ERROEXC001: " + OemToAnsi(STR0003) //"O lançamento a ser excluído não foi encontrado na base Protheus."
							Endif
						Else
							lRet    := .F.
							cXmlRet := OemToAnsi(STR0004) //"O tipo de operação não foi informado corretamente na tag Event."
						EndIf

						If lRet
							//Verificação da existência do conteúdo da mensagem de negócio
							If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage, '_BUSINESSCONTENT') <> Nil
								//Número do lote
								If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_BATCHNUMBER') <> Nil
									cLote := oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BatchNumber:Text
									nLote := Val(cLote)
									cLote := STRZERO(nLote,TamSX3("CT2_LOTE")[1])
								EndIf
								//Número do sublote
								If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_SUBLOT') <> Nil
									cSubLote := oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SubLot:Text
									nSubLote := Val(cSubLote)
									cSubLote := STRZERO(nSubLote,TamSX3("CT2_SBLOTE")[1])
								EndIf
								//Número do documento
								If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent,'_DOCUMENT') <> Nil
									cDoc := oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Document:Text
									//Tratamento realizado no número do documento
									if cDoc == "999999" .or. empty(cDoc)
										cDoc := "000001"
									endIf
									nDoc := Val(cDoc)
									cDoc := STRZERO(nDoc,TamSX3("CT2_DOC")[1])
								EndIf
								
								If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent, '_ENTRIES') <> Nil .AND. ;
										XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries, '_ENTRY') <> Nil

									//Tratamento para sempre trabalhar com array na lista de lançamentos contabeis
									If ValType(XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries, '_ENTRY')) <> 'A'
										XmlNode2Arr(oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry, '_Entry')
									EndIf

									For nCount := 1 To Len(oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry)
										cLinAux := ""
										aXMLItem := oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry[nCount]
										aAux := MontaItem(aXMLItem,@dDataLanc,cPlano,cMarca, cVersion, nOpcExec, nCount)

										If ValType(aAux[1]) == 'L' .and. !aAux[1]
											Return aAux
										Endif

										aAdd(aItens,aClone(aAux))

										//Verifica se a linha de lançamento ta excluída
										If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry[nCount],'_ITEMDELETED') <> Nil
											If !Empty( AllTrim( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry[nCount]:_ItemDeleted:Text ) )
												Aadd( aDeletado, oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry[nCount]:_ItemDeleted:Text )
											Else
												aAdd( aDeletado, '2' )
											Endif
										Else
											aAdd( aDeletado, '2' )
										EndIf
										nLen 	 := Iif( GetNewPar( "MV_CT5HIST" , .T. ), TamSX3("CT2_HIST")[1], TamSX3("CTK_HIST")[1])	
										nPosHist := aScan( aAux, { |x| Alltrim(x[1]) == "CT2_HIST" })  //POSICAO 1 NOME DO CAMPO - POSICAO 2 CONTEUDO DO CAMPO
										If nPosHist > 0 .And. Len(aAux[nPosHist][2]) > nLen             //neste caso deve quebrar historico se for maior que 40 e colocar no array aItens a Continuacao do Historico

											cHistAux := Alltrim( Subs(aAux[nPosHist][2],nLen+1) )

											If ! Empty(cHistAux)
												aAuxHist := {}
												While Len(cHistAux) > 0
													cComplHist := Subs(cHistAux, 1, nLen)
													aAdd(aAuxHist, cComplHist)
													cHistAux := Alltrim( Subs(cHistAux,nLen+1) )
												EndDo

												For nHist := 1 TO Len(aAuxHist)
													aItensHist := aClone(aAux)
													For nZ := 1 TO Len(aItensHist)
														cCampo := Alltrim(aItensHist[nZ,1])

														If 		cCampo == "CT2_DC"
																aitensHist[nZ,2] := '4'
														ElseIf 	cCampo == "CT2_HIST"
																aitensHist[nZ,2] := aAuxHist[nHist]
														ElseIf 	cCampo == "CT2_LINHA"
															If Empty(cLinAux)
																cLinAux := Soma1(aitensHist[nZ,2])
																nLinCT2 := DecodSoma1( cLinAux )
															EndIf
															aitensHist[nZ,2] := cLinAux
														ElseIf 	cCampo $ "CT2_ORIGEM|CT2_FILIAL|CT2_TPSALD"
																//MANTEM O GRAVADO ORIGINALMENTE
														Else    //DEMAIS CAMPOS LIMPA O CONTEUDO
															If !Empty(aitensHist[nZ,2])

																If Valtype(aitensHist[nZ,2])=="C"
																	aitensHist[nZ,2] := " "

																ElseIf Valtype(aitensHist[nZ,2])=="D"
																	aitensHist[nZ,2] := CtoD("")

																ElseIf Valtype(aitensHist[nZ,2])=="N"
																	aitensHist[nZ,2] := 0

																EndIf
															EndIf
														EndIf
													Next nZ

													If nOpcExec == 4  //alteracao
														CT2->(dbSetOrder(1))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC
														If CT2->(MsSeek(xFilial("CT2") + cData + cLote + cSubLote + cDoc + cLinAux ))
															While CT2->( CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA == xFilial("CT2") + cData + cLote + cSubLote + cDoc + cLinAux )
																Ctb102Save(CT2->( Recno() ))
																CT2->( dbSkip() )
															EndDo
														EndIf
													EndIf

													aAdd(aItens,aClone(aitensHist))

													//Verifica se a linha de lançamento ta excluída
													If XmlChildEx( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry[nCount],'_ITEMDELETED') <> Nil
														If !Empty( AllTrim( oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry[nCount]:_ItemDeleted:Text ) )
															Aadd( aDeletado, oXmlCTB102:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Entries:_Entry[nCount]:_ItemDeleted:Text )
														Else
															aAdd( aDeletado, '2' )
														Endif
													Else
														aAdd( aDeletado, '2' )
													EndIf

													cLinAux := Soma1(cLinAux)
													nLinCT2 := DecodSoma1( cLinAux )

												Next nHist
											EndIf
										Else
											If nOpcExec <> 5
												nLinCT2++
											EndIf
										EndIf
									Next nCount																		
								EndIf

								//Se for inclusão e o lote/sublote/doc não foram informados, verifica qual é o próximo documento
								//disponível do lote para efetuar os lançamentos contabéis.
								If nOpcExec == 3
									//Garante que o cModulo está definido como CTB para poder pegar o lote correto da X5,
									//caso o lote esteja vazio e depois volta o cModulo para o que era antes para evitar problemas
									//(o cModulo pode estar com um valor diferente quando a rotina é chamada pelo EAI)
									cModulo  := "CTB"
									CTF_LOCK := 0
									C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,,,,@CTF_LOCK,nOpcExec,1)
									//Exclusão ou Alteração
								ElseIf nOpcExec == 5 .OR. nOpcExec == 4

									dDataLanc := StoD(aCT2ValInt[2][3])
									cLote		:= AllTrim(aCT2ValInt[2][4])
									cSubLote	:= AllTrim(aCT2ValInt[2][5])
									cDoc		:= AllTrim(aCT2ValInt[2][6])
									aAreaCTF := getArea()
									dbSelectArea("CTF")
									dbSetOrder(1)
									If CTF->(msSeek(xFilial("CTF")+Dtos(dDataLanc)+cLote+cSubLote+cDoc))
										CtbDestrava(CTF->CTF_DATA,CTF->CTF_LOTE,CTF->CTF_SBLOTE,CTF->CTF_DOC,CTF->(recno()))
									Endif
									RestARea(aAreaCTF)

								EndIf

								aadd(aCab, {'DDATALANC' 	, dDataLanc               , NIL})
								aadd(aCab, {'CLOTE' 		, cLote					    , NIL})
								aadd(aCab, {'CSUBLOTE' 	, cSubLote					, NIL})
								aadd(aCab, {'CDOC' 		, cDoc						, NIL})

								If nOpcExec == 3 .OR. nOpcExec == 5 .OR. nOpcExec == 4																																			
									aAux := {} 
									
									//Se for exclusão, zera o aItens
									If  nOpcExec == 5
										aItens := {}																														
									ElseIf nOpcExec == 3 //Inclus?o n?o considera itens deletados										
										For nCount := 1 To Len( aItens )
											//Verifica se a linha de lançamento está habilitada
											If aDeletado[nCount] <> "1"
												aAdd(aAux, aClone(aItens[nCount]))
											EndIf
										Next nCount

										aItens := aClone(aAux)
									ElseIf nOpcExec == 4										
										aAreaCT2 := CT2->(GetArea())
										CT2->(dbSetOrder(1)) // CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC	
										For nCount := 1 To Len( aItens )
											//Se a linha de lançamento recebida já exitir na base, altera os valores ou excluí a linha
											nPosLin := aScan( aItens[nCount], { |x| Alltrim(x[1]) == "CT2_LINHA" } )
											If nPosLin > 0
												cLinha := aItens[nCount][nPosLin][2]
												//Se a linha já existir, marca para alteração
												If CT2->(MsSeek( xFilial("CT2") +  DTOS(dDataLanc) + cLote + cSubLote + cDoc + cLinha))
													AADD(aItens[nCount] , { 'LINPOS','CT2_LINHA',padr(cLinha,TamSX3("CT2_LINHA")[1])} )

													//Verifica se a linha de lançamento foi excluída
													If aDeletado[nCount] == "1"
														AADD(aItens[nCount] ,{"AUTDELETA","S",NIL})
													EndIf

													aAdd(aAux, aClone(aItens[nCount]))												
												Else
													//Verifica se a linha de lançamento está habilitada
													If aDeletado[nCount] <> "1"
														aAdd(aAux, aClone(aItens[nCount]))
													EndIf
												EndIf
											Else
												//Verifica se a linha de lançamento está habilitada
												If aDeletado[nCount] <> "1"
													aAdd(aAux, aClone(aItens[nCount]))
												EndIf	
											Endif
										Next nCount	
										RestArea(aAreaCT2)
										aItens := aClone(aAux)
										aSort(aItens,,,{|x,y| x[2][2] < y[2][2]}) //Ordena itens																											 
									Endif									
								Endif
								MSExecAuto({|x, y, z| CTBA102(x, y, z)}, aCab, aItens, nOpcExec)
								//Zera variavel statica que conta as linhas quando ela não vem no xml
								nLinCT2 := 0
								aItens := {}
							EndIf

							If lMsErroAuto
								aErroAuto := GetAutoGRLog()
								For nCount := 1 To Len(aErroAuto)
									cLogErro += aErroAuto[nCount] + CRLF
								Next nCount

								cLogErro := STRTRAN ( cLogErro , "TABELA NAO ENCONTRADA", "CT2 Lançamento Contábil" )

								// Monta XML de Erro de execução da rotina automatica.
								lRet := .F.
								cXMLRet := _noTags(cLogErro)
							Else
								If nOpcExec != 5 //Se o evento é diferente de delete
									//Grava o registro na tabela XXF (de/para)
									cCT2ValInt := C102MntInt( cFilAnt, DTOS(dDataLanc) ,cLote, cSubLote, cDoc )
									CFGA070Mnt( cMarca, "CT2", "CT2_DOC", cCT2ValExt, cCT2ValInt, .F. )
								Else
									//Exclui o registro na tabela XXF (de/para)
									CFGA070Mnt( cMarca, "CT2", "CT2_DOC", cCT2ValExt, cCT2ValInt, .T. )
								Endif

								//Monta xml com status do processamento da rotina automatica OK.
								cXMLRet := "<ListOfInternalId>"
								cXMLRet +=     "<InternalId>"
								cXMLRet +=         "<Name>AccountingEntryInternalId</Name>"
								cXMLRet +=         "<Origin>" + cCT2ValExt + "</Origin>" // Valor recebido na tag
								cXMLRet +=         "<Destination>" + cCT2ValInt + "</Destination>" // Valor XXF gerado
								cXMLRet +=     "</InternalId>"
								cXMLRet += "</ListOfInternalId>"
							EndIf

							If nOpcExec == 4  //alteracao
								Ctb102Clear()
							EndIf

						EndIf
					Endif
				EndIf
			Endif
		EndIf

	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
		oXmlCTB102 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
		// Se não houve erros na resposta
		If Upper(oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
			if Type("oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text") == "U" .Or. ;
			   Upper(oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"

				// Verifica se a marca foi informada
				If Type("oXmlCTB102:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. ;
						!Empty(oXmlCTB102:_TOTVSMessage:_MessageInformation:_Product:_name:Text)

					cMarca := oXmlCTB102:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet    := .F.
					cXmlRet := STR0001 + "|" // "Erro no retorno. O Product é obrigatório!"
				EndIf

				If lRet
					// Se não for array e existir, transforma a estrutura em array
					cTipoNo := Type("oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId")
					If cTipoNo <> "U" .And. cTipoNo <> "A"
						// Transforma em array
						XmlNode2Arr(oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")

						// Verifica se o código interno foi informado
						If Type("oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text") != "U" .And. ;
								!Empty(oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text)

							cValInt := oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text
						Else
							lRet    := .F.
							cXmlRet := STR0002 // "Erro no retorno. O OriginalInternalId é obrigatório!"
						EndIf

						If lRet
							// Verifica se o código externo foi informado
							If Type("oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text") != "U" .And. ;
									!Empty(oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text)

								cValExt := oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text
							Else
								lRet    := .F.
								cXmlRet := STR0002 //"Erro no retorno. O DestinationInternalId é obrigatório"
							EndIf

							If lRet
								//Obtém a mensagem original enviada
								If Type("oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
									cXmlAux := oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
								Else
									lRet := .F.
									cXmlRet := OemToAnsi(STR0005) //"Conteúdo do MessageContent inválido ou vazio!"
								EndIf

								If lRet
									oXmlAux := XmlParser(cXmlAux, "_", @cErroXml, @cWarnXml)
									If oXmlAux != Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)

										If Upper(oXmlAux:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
											//Insere / Atualiza o registro na tabela XXF (de/para)
											CFGA070Mnt(cMarca, "CT2", "CT2_DOC", cValExt, cValInt, .F.)
										ElseIf Upper(oXmlAux:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
											//Exclui o registro na tabela XXF (de/para)
											CFGA070Mnt(cMarca, "CT2", "CT2_DOC", cValExt, cValInt, .T.)
										Else
											lRet := .F.
											cXmlRet := OemToAnsi(STR0006) //"Evento do retorno inválido!"
										EndIf
									Else
										lRet := .F.
										cXmlRet := OemToAnsi(STR0007) //"Erro no parser do retorno!"
									Endif
								Endif
							Endif

						Endif
					EndIf
				Endif
			EndIf
		Else
			// Se não for array
			If Type("oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
				// Transforma em array
				XmlNode2Arr(oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
			EndIf

			// Percorre o array para obter os erros gerados
			For nCount := 1 To Len(oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
				cError := oXmlCTB102:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + "|"
			Next nCount

			lRet    := .F.
			cXmlRet := cError
		EndIf
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS // Informação das versões compatíveis com a mensagem única.
		cXMLRet := '2.000|2.001|2.002|2.003|2.004|3.000'
	EndIf

EndIf

If ValType(cXmlRet) <> 'C'
	cXmlRet := ''
	lRet	:= .F.
EndIf

cModulo := cModuloAnt
CT2->(RestArea(aCT2Area))


Return { lRet, cXmlRet, cMessage }

//-------------------------------------------------------------------
/*/{Protheus.doc} C102MntInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cFil	Filial do Registro
@param		cCod	Codigo de Identificação do Movimento Financeiro

@author	marylly.araujo
@version	MP11.90
@since		12/11/13
@return	cRetorno - Retorna o InternalId do registro
@sample	exemplo de retorno - {'Empresa'|'xFilial'|'DataLanc'|'Lote'|'Sublote'|'Documento'}
								//		01		02				03			04		05			06
/*/
//-------------------------------------------------------------------
Function C102MntInt(cIntFil,dData,cLote,cSubLote,cDoc)
Local cRetCode	:= ''
Default cIntFil	:= xFilial('CT2')

cIntFil	:= xFilial("CT2",cIntFil)

cRetCode	:= cEmpAnt + '|' + RTrim(cIntFil) + '|' + RTrim(dData) + '|' + RTrim(cLote)  + '|' + RTrim(cSubLote) + '|' + RTrim(cDoc)

Return cRetCode

//-------------------------------------------------------------------
/*/{Protheus.doc} C102GetInt
Recebe um codigo, busca seu InternalId e faz a quebra da chave

@param		cCodigo InternalID recebido na mensagem.
@param		cMarca	Produto que enviou a mensagem

@author	marylly.araujo
@version	MP11.90
@since		12/11/13
@return	aRetorno Array contendo os campos da chave primaria da natureza e o seu internalid.
@sample	exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Codigo' },InternalId}
/*/										//   01          02         03
//-------------------------------------------------------------------
Function C102GetInt(cCodigo, cMarca)
Local cValInt		:= ''
Local aRetorno	:= {}
Local aAux			:= {}
Local nX			:= 0
Local aCampos		:= {cEmpAnt,'CT2_FILIAL','CT2_DATA','CT2_LOTE','CT2_SBLOTE','CT2_DOC'}

cValInt := CFGA070Int(cMarca, 'CT2', 'CT2_DOC', cCodigo)
If !Empty(cValInt)
	aAux := Separa(cValInt,'|')

	aAdd(aRetorno, .T. )
	aAdd(aRetorno, aAux )
	aAdd(aRetorno, cValInt )

	aRetorno[2][1] := Padr(aRetorno[2][1],Len(cEmpAnt))

	For nX :=2 to 	Len(aRetorno[2]) //corrigindo  o tamanho dos campos
		aRetorno[2][nX] := Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
	Next nX
Else
	aAdd(aRetorno,.F.)
EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCtInt
Busca o código interno da conta contábil, com base no código externo recebido

@param		cValExt Valor externo recebido na mensagem.
@param		cMarca	Produto que enviou a mensagem

@author	Pedro Alencar
@version	MP11.90
@since		17/03/14
@return	cRet Código da Conta interna
/*/										//   01          02         03
//-------------------------------------------------------------------
Static Function GetCtInt(cValExt, cMarca)
	Local cValInt	:= ''
	Local aRetorno	:= {}
	Local aAux		:= {}
	Local nX		:= 0
	Local aCampos	:= {cEmpAnt,'CT1_FILIAL', 'CT1_CONTA'}

	cValInt := CFGA070Int(cMarca, 'CT1', 'CT1_CONTA', AllTrim(cValExt))
	If !Empty(cValInt)
		aAux := Separa(cValInt,'|')

		aAdd(aRetorno, .T. )
		aAdd(aRetorno, aAux )
		aAdd(aRetorno, cValInt )

		aRetorno[2][1] := Padr(aRetorno[2][1],Len(cEmpAnt))

		For nX := 2 To 	Len(aRetorno[2]) //corrigindo  o tamanho dos campos
			aRetorno[2][nX] := Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
		Next nX
	Else
		aAdd(aRetorno,.F.)
		aAdd(aRetorno, STR0010 + cValExt + STR0011) //"Conta Contábil " + " não encontrada no De/Para!"
	EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaItem
Função que monta o array de itens

@param	aXMLItem Nó do Item
@param	dDataLanc Data do Lançamento
@param	cEntGer Plano da conta Gerencial

@author Alvaro Camillo Neto
@version P12
@since	16/09/2014
/*/
//-------------------------------------------------------------------

Static Function MontaItem(aXMLItem,dDataLanc,cEntGer,cMarca, cVersion, nOpcExec, nCount)
Local aAux			:= {}
Local cTpSaldo	:= ''
Local nLinha		:= ""
Local cMoeda 		:= ''
Local cValExt		:= ""
Local cMoeVer		:= ""
Local aMoedaInt	:= {}
Local cValInt		:= ""
Local cCampoDeb 	:= ""
Local cCampoCred	:= ""
Local acCusto     := {}
Local cXmlRet		:= ''
Local lRet       	:= .F.
Local aAceiteDebt   := {.F.,.F.,.F.,.F.}
Local aAceiteCred   := {.F.,.F.,.F.,.F.}
Local aEntCtb       := StaticCall(CTBA102, CarrEntCtb) //array de verificação das entidades contabeis adicionais, com 5 posicoes
Local lAllEnt       := IIf(cVersion = "3.", .T., .F.) //Utiliza Todas as Entidades Adicionais ?
Local nY            := 0 //Controle de FOR

Aadd( aAux, { "CT2_FILIAL" ,xFilial("CT2"), Nil })
//Linha do Lançamento Contábil
If XmlChildEx( aXMLItem,'_ITEM') <> Nil
	nLinha := Val(aXMLItem:_Item:Text)
	//Tratamento para quando o conteudo da TAG Item estiver em braco
	If Empty(nLinha)
		//Primeiro registro sempre inicia linha para incrementar corretamente
		If nCount == 1
			nLinCT2 := nCount
		EndIf
				
		nLinha := nLinCT2						
	Else
		//Se alteracao e o primeiro item enviado no xml = 1, inicializa linha
		//Tratamento necessário para saber se altera lançamentos já existentes 
		//ou é continuaç?o de lançamentos por xml quebrado
		If nOpcExec == 4 .And. nCount == 1 .And. nLinha == 1
			nLinCT2 := nLinha
		Endif 

		If nLinha <= nLinCT2
			nLinha := nLinCT2
		EndIf
	EndIf

	nLinha := _aSoma1[nLinha]
	Aadd( aAux, { "CT2_LINHA", nLinha, Nil })
EndIf
//Tipo da Linha do Lançamento Contábil
If XmlChildEx( aXMLItem,'_ITEMTYPE') <> Nil
	Aadd( aAux, { "CT2_DC", Val(aXMLItem:_ItemType:Text), Nil })
EndIf
//Data do Lançamento Contábil
If Empty(dDataLanc)
	If XmlChildEx( aXMLItem, '_MOVEMENTDATE') <> Nil
		dDataLanc := stod(StrTran( Left(aXMLItem:_MovementDate:Text,10), '-', '') )
	EndIf
EndIf
//Tipo de Saldo a Linha do Lançamento Contábil
cTpSaldo := ''
If XmlChildEx( aXMLItem,'_BALANCETYPE') <> Nil
	cTpSaldo := aXMLItem:_BalanceType:Text
EndIf

If !Empty(cTpSaldo)
	Aadd( aAux, { "CT2_TPSALD",cTpSaldo , Nil })
EndIf

//Valor do Lançamento Contábil
If XmlChildEx( aXMLItem,'_ENTRYVALUE') <> Nil
	Aadd( aAux, { "CT2_VALOR", Val(aXMLItem:_EntryValue:Text), Nil })
EndIf
//Histórico da Linha do Lançamento Contábil
If XmlChildEx( aXMLItem,'_HISTORYCODE') <> Nil
	Aadd( aAux, { "CT2_HP", aXMLItem:_HistoryCode:Text, Nil })
EndIf
//Complemento do Histórico da Linha do Lançamento Contábil
If XmlChildEx( aXMLItem,'_COMPLEMENTARYHISTORY') <> Nil
	Aadd( aAux, { "CT2_HIST", aXMLItem:_ComplementaryHistory:Text, Nil })
EndIf

//Moeda da Linha do Lançamento Contábil
cMoeda := ''
If lCTBA140
	If XmlChildEx( aXMLItem,'_CURRENCYINTERNALID') <> Nil
		cValExt := aXMLItem:_CurrencyInternalID:Text
		//Pega a versão da mensagem de integração de moedas em uso
		cMoeVer := FWXX4Version('CURRENCY')
		//Pega o valor interno da moeda recebida
		aMoedaInt := IntMoeInt( cValExt, cMarca, AllTrim(cMoeVer) )
		If aMoedaInt[1]
			If cMoeVer='1.000'
				cValInt := aMoedaInt[2][2]  //na versão um só monta o array com 2 posiçoes(colunas) na linha 2 ao criar na função IntMoeINt
				cMoeda := cValInt			//atribui o cValInt a cMoeda com codigo da moeda com valor Interno da destino/origem
			Else
				cValInt := aMoedaInt[2][3]
				cMoeda := cValInt
			Endif
		Else
			lRet := .F.
			cXmlRet := aMoedaInt[02]
			Return {lRet, cXmlRet}
		Endif
	Endif
ElseIf XmlChildEx( aXMLItem,'_CURRENCYCODE') <> Nil
	cMoeda := aXMLItem:_CurrencyCode:Text
EndIf

If !Empty(cMoeda)
	Aadd( aAux, { "CT2_MOEDLC",cMoeda , Nil })
Else
	Aadd( aAux, { "CT2_MOEDLC",'01' , Nil })
EndIf

//Conta Contábil a Débito da Linha do Lançamento Contábil
If lCTBA020
	If XmlChildEx( aXMLItem,'_DEBITACCOUNTINTERNALID') <> Nil
		cValExt := aXMLItem:_DebitAccountInternalID:Text
		If !Empty(cValExt)
			aResult := GetCtint(cValExt, cMarca)
			If (aResult[01])
				cValInt := aResult[02, 03]
				Aadd( aAux, { "CT2_DEBITO", cValInt , Nil })
			Else
				lRet    := .F.
				cXmlRet := aResult[02]
				Return {lRet, cXmlRet}
			EndIf
		EndIf
	Endif
ElseIf XmlChildEx( aXMLItem,'_DEBITACCOUNTCODE') <> Nil
	Aadd( aAux, { "CT2_DEBITO", aXMLItem:_DebitAccountCode:Text, Nil })
EndIf

//Conta Contábil a Crédito da Linha do Lançamento Contábil
If lCTBA020
	If XmlChildEx( aXMLItem,'_CREDITACCOUNTINTERNALID') <> Nil
		cValExt := aXMLItem:_CreditAccountInternalID:Text
		If !Empty(cValExt)
			aResult := GetCtint(cValExt, cMarca)
			If (aResult[01])
				cValInt := aResult[02, 03]
				Aadd( aAux, { "CT2_CREDIT", cValInt , Nil })
			Else
				lRet    := .F.
				cXmlRet := "Conta Crédito " + cValExt + " não encontrada no De/Para!"
				Return {lRet, cXmlRet}
			EndIf
		EndIf
	Endif
ElseIf XmlChildEx( aXMLItem,'_CREDITACCOUNTCODE') <> Nil
	Aadd( aAux, { "CT2_CREDIT", aXMLItem:_CreditAccountCode:Text, Nil })
EndIf

//validação para não pegar as informações de item e classe de valor, caso o campo diga que nao e venha da RM.
IF cMarca = "RM" .and. SuperGetMv("MV_ACENTIN",,.F.)
	nTamAux :=Len(aAux)

	IF aAux[nTamAux][1] == "CT2_DEBITO"
		aAceiteDebt := VldPlanoAceite(aAux[nTamAux][2],cEntGer)
	Else
		IF aAux[nTamAux - 1][1] == "CT2_DEBITO"
			aAceiteDebt := VldPlanoAceite(aAux[nTamAux - 1][2],cEntGer)
		EndIf
		If aAux[nTamAux][1] == "CT2_CREDIT"
			aAceiteCred := VldPlanoAceite(aAux[nTamAux][2],cEntGer)
		EndIF
	EndIF
else
	afill(aAceiteDebt,.T.)
	afill(aAceiteCred,.T.)
EndIf

If aAceiteDebt[3]
//Tratamento dos centros de custos utilizando ou não a msg MATI070 - Bancos
	If lCTBA030
	//InternalId do Centro de Custo a Débito da Linha do Lançamento Contábil
		If XmlChildEx( aXMLItem,'_COSTCENTERDEBITINTERNALID') <> Nil
			If !Empty(AllTrim(aXMLItem:_CostCenterDebitInternalId:Text))
                  acCusto := IntCusInt(aXMLItem:_CostCenterDebitInternalId:Text,cMarca)
                  If acCusto[1]
                     Aadd( aAux, { "CT2_CCD", AllTrim(acCusto [2][3]), Nil })
                  Else
                     lRet := .F.
                     cXmlRet := acCusto[2]
                     Return {lRet, cXmlRet}
                  EndIf
			Endif
		EndIf
	ElseIf XmlChildEx( aXMLItem,'_COSTCENTERCODE') <> Nil
	//Centro de Custo a Débito da Linha do Lançamento Contábil
		Aadd( aAux, { "CT2_CCD", aXMLItem:_CostCenterCode:Text, Nil })
	EndIf
EndIf

If aAceiteCred[3]
//Tratamento dos centros de custos utilizando ou não a msg CTBA030 - Custos
	If lCTBA030
	//InternalId do Centro de Custo a Débito da Linha do Lançamento Contábil
		If XmlChildEx( aXMLItem,'_COSTCENTERCREDITINTERNALID') <> Nil
			If !Empty(AllTrim(aXMLItem:_CostCenterCreditInternalId:Text))
				acCusto := IntCusInt(aXMLItem:_CostCenterCreditInternalId:Text,cMarca)
				If (acCusto[1])
					Aadd( aAux, { "CT2_CCC", AllTrim(acCusto[2][3]), Nil })
				Else
					lRet := .F.
					cXmlRet := acCusto[2]
					Return {lRet, cXmlRet}
				EndIf
			Endif
		EndIf
	ElseIf XmlChildEx( aXMLItem,'_COSTCENTERCREDITCODE') <> Nil
	//Centro de Custo a Crédito da Linha do Lançamento Contábil
		Aadd( aAux, { "CT2_CCC", aXMLItem:_CostCenterCreditCode:Text, Nil })
	EndIf
EndIf

If aAceiteDebt[1]
//Item contábil a debito
	If lCTBA040
		If XmlChildEx( aXMLItem,'_ACCOUNTINGITEMDEBITINTERNALID') <> Nil .And.;
				!Empty(aXMLItem:_AccountingItemDebitInternalId:Text)
			cValExt := aXMLItem:_AccountingItemDebitInternalId:Text
			aResult := C040AGetInt(cValExt, cMarca)
			if aResult[1]
				Aadd( aAux, { "CT2_ITEMD", aResult[2][3] , Nil })
			Else
				lRet := .F.
				cXmlRet := aResult[2]
				Return {lRet, cXmlRet}
			EndIf
		Endif
	ElseIf XmlChildEx( aXMLItem,'_ACCOUNTINGITEMDEBITCODE') <> Nil
		Aadd( aAux, { "CT2_ITEMD", aXMLItem:_AccountingItemDebitCode:Text, Nil })
	EndIf
EndIf

If aAceiteCred[1]
//Item contábil a crédito
	If lCTBA040
		If XmlChildEx( aXMLItem,'_ACCOUNTINGITEMCREDITINTERNALID') <> Nil .And.;
				!Empty(aXMLItem:_AccountingItemCreditInternalId:Text)
			cValExt := aXMLItem:_AccountingItemCreditInternalId:Text
			aResult := C040AGetInt(cValExt, cMarca)
			If aResult[1]
				Aadd( aAux, { "CT2_ITEMC", aResult[2][3] , Nil })
			Else
				lRet := .F.
				cXmlRet := aResult[2]
				Return {lRet, cXmlRet}
			EndIf
		Endif
	ElseIf XmlChildEx( aXMLItem,'_ACCOUNTINGITEMCREDITCODE') <> Nil
		Aadd( aAux, { "CT2_ITEMC", aXMLItem:_AccountingItemCreditCode:Text, Nil })
	EndIf
EndIf

If aAceiteDebt[2]
//Classe de valor a débito
	If lCTBA060
		If XmlChildEx( aXMLItem,'_CLASSVALUEDEBITINTERNALID') <> Nil
			cValExt := aXMLItem:_ClassValueDebitInternalId:Text
			If !(Empty(cValExt))
				aRet := C060GetInt(cValExt, cMarca)
				If aRet[1]
					Aadd( aAux, { "CT2_CLVLDB", aRet[2][3] , Nil })
				Else
					lRet := .F.
					cXmlRet := aRet[2]
					Return {lRet, cXmlRet}
				EndIf
			EndIf
		Endif
	ElseIf XmlChildEx( aXMLItem,'_CLASSVALUEDEBITCODE') <> Nil
		Aadd( aAux, { "CT2_CLVLDB", aXMLItem:_ClassValueDebitCode:Text, Nil })
	EndIf
EndIf

If aAceiteCred[2]
//Classe de valor a crédito
	If lCTBA060
		If XmlChildEx( aXMLItem,'_CLASSVALUECREDITINTERNALID') <> Nil
			cValExt := aXMLItem:_ClassValueCreditInternalId:Text
			If !(Empty(cValExt))
				aRet := C060GetInt(cValExt, cMarca)
				If aRet[1]
					Aadd( aAux, { "CT2_CLVLCR", aRet[2][3] , Nil })
				Else
					lRet := .F.
					cXmlRet := aRet[2]
					Return {lRet, cXmlRet}
				EndIf
			EndIf
		Endif
	ElseIf XmlChildEx( aXMLItem,'_CLASSVALUECREDITCODE') <> Nil
		Aadd( aAux, { "CT2_CLVLCR", aXMLItem:_ClassValueCreditCode:Text, Nil })
	EndIf
EndIf

//Verifica se utiliza Todas as Entidades Adicionais
If lAllEnt
	//Compondo array com entidades adicionais
	For nY := 1 To Len(aEntCtb)
		//Verifica se usa a entidade adicional
		If (aEntCtb[nY, 01])
			//Campos de Débito e Crédito
			cCampoDeb  := aEntCtb[nY, 02]
			cCampoCred := aEntCtb[nY, 03]
			//Verificando existência de Tags no XML
			If aAceiteDebt[4] //Débito
				If lCTBA800A
					If XmlChildEx( aXMLItem,'_MANAGERIALACCOUNTINGENTITY' + StrZero(nY + 04, 02) + 'DEBITINTERNALID') <> Nil
						cValExt := &("aXMLItem:_ManagerialAccountingEntity" + StrZero(nY + 04, 02) + "DebitInternalId:Text")
						If !(Empty(cValExt))
							aRet := IntGerInt(cValExt, cMarca)
							If aRet[1]
								Aadd( aAux, { cCampoDeb, aRet[2][4] , Nil })
							Else
								lRet := .F.
								cXmlRet := aRet[2]
								Return {lRet, cXmlRet}
							EndIf
						EndIf
					Endif
				ElseIf XmlChildEx( aXMLItem,'_MANAGERIALACCOUNTINGENTITY' + StrZero(nY + 04, 02) + 'DEBIT') <> Nil
					Aadd( aAux, { cCampoDeb, &("aXMLItem:_ManagerialAccountingEntity" + StrZero(nY + 04, 02) + "Debit:Text"), Nil })
				EndIf
			EndIf
			If aAceiteCred[4] //Crédito
				If lCTBA800A
					If XmlChildEx( aXMLItem,'_MANAGERIALACCOUNTINGENTITY' + StrZero(nY + 04, 02) + 'CREDITINTERNALID') <> Nil
						cValExt := &("aXMLItem:_ManagerialAccountingEntity" + StrZero(nY + 04, 02) + "CreditInternalId:Text")
						If !(Empty(cValExt))
							aRet := IntGerInt(cValExt, cMarca)
							If aRet[1]
								Aadd( aAux, { cCampoCred, aRet[2][4] , Nil })
							Else
								lRet := .F.
								cXmlRet := aRet[2]
								Return {lRet, cXmlRet}
							EndIf
						EndIf
					EndIf
				ElseIf XmlChildEx( aXMLItem,'_MANAGERIALACCOUNTINGENTITY' + StrZero(nY + 04, 02) + 'CREDIT') <> Nil
					Aadd( aAux, { cCampoCred, &("aXMLItem:_ManagerialAccountingEntity" + StrZero(nY + 04, 02) + "Credit:Text"), Nil })
				EndIf
			EndIf
		EndIf
	Next nY
ElseIf !Empty(cEntGer)

	cCampoDeb := "CT2_EC"+cEntGer+"DB"
	cCampoCred:= "CT2_EC"+cEntGer+"CR"

	If aAceiteDebt[4]
	//Conta Gerencial
		If lCTBA800A
			If XmlChildEx( aXMLItem,'_MANAGERIALACCOUNTINGENTITYDEBITINTERNALID') <> Nil
				cValExt := aXMLItem:_ManagerialAccountingEntityDebitInternalId:Text
				If !(Empty(cValExt))
					aRet := IntGerInt(cValExt, cMarca)
					If aRet[1]
						Aadd( aAux, { cCampoDeb, aRet[2][4] , Nil })
					Else
						lRet := .F.
						cXmlRet := aRet[2]
						Return {lRet, cXmlRet}
					EndIf
				EndIf
			Endif
		ElseIf XmlChildEx( aXMLItem,'_MANAGERIALACCOUNTINGENTITYDEBIT') <> Nil
			Aadd( aAux, { cCampoDeb, aXMLItem:_ManagerialAccountingEntityDebit:Text, Nil })
		EndIf
	EndIf

	If aAceiteCred[4]
	//Conta Gerencial
		If lCTBA800A
			If XmlChildEx( aXMLItem,'_MANAGERIALACCOUNTINGENTITYCREDITINTERNALID') <> Nil
				cValExt := aXMLItem:_ManagerialAccountingEntityCreditInternalId:Text
				If !(Empty(cValExt))
					aRet := IntGerInt(cValExt, cMarca)
					If aRet[1]
						Aadd( aAux, { cCampoCred, aRet[2][4] , Nil })
					Else
						lRet := .F.
						cXmlRet := aRet[2]
						Return {lRet, cXmlRet}
					EndIf
				EndIf
			Endif
		ElseIf XmlChildEx( aXMLItem,'_MANAGERIALACCOUNTINGENTITYCREDIT') <> Nil
			Aadd( aAux, { cCampoCred, aXMLItem:_ManagerialAccountingEntityCredit:Text, Nil })
		EndIf
	EndIf
EndIf 

aAdd( aAux, { "CT2_ORIGEM", "CTBI102", Nil })

Return aAux

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPlanoAceite(cCodplan)
função ira verificar se o plano de contas utilizado permite o uso de item e classe de valor

@param	cMensagem Nome da Mensagem única a ser pesquisada
@return	lAceiteItem - se o Item pode ser usado
@return	lAceiteClasse - se a Classe pode ser usada

@author Caio Quiqueto
@version P11
@since	20/08/2015
/*/
//-------------------------------------------------------------------

Static function VldPlanoAceite(cCodplan,cEntGer)
local lAceiteItem 	:= .F.
local lAceiteClasse	:= .F.
local lAceiteCentro	:= .F.
Local lAceiteEntGer	:= .F. //Entidade Gerencial
Local cAceitEnt		:= ""	//Nome do campo da entidade gerencial

Local aArea:= GetArea()

	DbSelectArea("CT1")

	CT1->(dbSetOrder(1))

	If CT1->(dbSeek(xFilial("CT1")+ cCodplan))



		lAceiteItem := CT1->(CT1_ACITEM) == "1"
		lAceiteClasse := CT1->(CT1_ACCLVL) == "1"
		lAceiteCentro := CT1->(CT1_ACCUST) == "1"

		//Se tiver conta gerencial
		If !(Empty(cEntGer))
			//Pega nome do campo da entidade gerencial
			cAceitEnt := "CT1_ACET"+cEntGer

			lAceiteEntGer	:= CT1->&(cAceitEnt) == "1"
		EndIf

	EndIf


RestArea(aArea)
return {lAceiteItem,lAceiteClasse,lAceiteCentro,lAceiteEntGer}

//-------------------------------------------------------------------
/*/{Protheus.doc} RstSoma1
Converte números acima de 999 para alfanuméricos para preenchimento
do campo CT2_LINHA

@param		Número a ser convertido

@author	Totvs
@version	12.1.14
@since		27/07/2017
@return	Número alfanumérico para gravação do CT2_LINHA
/*/
//-------------------------------------------------------------------
Function RstSoma1()
Local nX
Local cLinha := STRZERO(0, TamSX3("CT2_LINHA")[1]) 

If _aSoma1 == NIL

	_aSoma1 := {}

	For nX := 1 To 35658
		cLinha := Soma1(cLinha)
		aAdd(_aSoma1, cLinha )
	Next

EndIf

Return
