#INCLUDE "totvs.ch"
#INCLUDE "PCPA145DEF.ch"
#INCLUDE "PCPA145.ch"

/*/{Protheus.doc} PCPA145Trf
Fun��o respons�vel por gerar as transfer�ncias de estoque quando existentes para o ticket.

@type  Function
@author lucas.franca
@since 18/11/2020
@version P12
@param 01 cTicket  , Character, N�mero do ticket de processamento
@param 02 cCodUsr  , Character, C�digo do usu�rio que est� executando a rotina
@param 03 cErrorUID, Character, C�digo identificador do controle de erros multi-thread
@return Nil
/*/
Function PCPA145Trf(cTicket, cCodUsr, cErrorUID)
	Local aNames     := {}
	Local aRegs      := {}
	Local aUsados    := {}
	Local cFilBkp    := cFilAnt
	Local cLocal     := ""
	Local cProduto   := ""
	Local cTesEntra  := ""
	Local cTesSaida  := ""
	Local cMsg       := ""
	Local lLoteDesOr := SuperGetMV("MV_LTDESOR")
	Local lRet       := .T.	
	Local nStart     := MicroSeconds()
	Local nIndex     := 0
	Local nIndUsado  := 0
	Local nTamRegs   := 0
	Local nTamFilial := FwSizeFilial()
	Local nTamLoc    := GetSX3Cache("B1_LOCPAD", "X3_TAMANHO")
	Local nTamPrd    := GetSX3Cache("B1_COD"   , "X3_TAMANHO")
	Local nTotFils   := 0
	Local nTotUsado  := 0
	Local oCachePrd  := JsonObject():New()
	Local oJson      := Nil
	Local oMdlNNS    := Nil
	Local oMdlNNT    := Nil
	Local oModel     := Nil
	Local oProcesso  := ProcessaDocumentos():New(cTicket, .T., , cCodUsr)
	Local oSugestObj := JsonObject():New()

	//MATA311 usa essas vari�veis
	Private INCLUI := .T.
	Private ALTERA := .F.

	aRegs := MrpGetSMA(cTicket, "0", .T.)

	If aRegs[1]
		oProcesso:msgLog(STR0024) //"In�cio do processamento das transfer�ncias."

		oJson    := aRegs[2]
		nTamRegs := Len(oJson["items"])

		//Seta o total de registros que ser�o processados
		oProcesso:initCount("TRANSF_TOTAL", nTamRegs)

		//Busca o Tipo de Entrada/Sa�da para cria��o das transfer�ncias.
		buscaTES(@cTesEntra, @cTesSaida)

		//Carrega vari�veis do MATA311 para utiliza��o no processo.
		oModel   := FwLoadModel("MATA311")
		oMdlNNS  := oModel:GetModel('NNSMASTER')
		oMdlNNT  := oModel:GetModel('NNTDETAIL')

		SB1->(dbSetOrder(1))

		For nIndex := 1 To nTamRegs
			lRet     := .T.
			cMsg     := ""

			If !oProcesso:dataValida(oJson["items"][nIndex]["receiptDate"], IIF(oJson["items"][nIndex]["level"] <> "99","OP","SC")) .Or.;
				(SUBSTR(oJson["items"][nIndex]["document"] , 0, 5) == "TRANF" .And. !oProcesso:dataValida(oJson["items"][nIndex]["transferenceDate"], "OP"))
				//Atualiza o status da tabela SMA.
				MrpUpStSMA(oJson["items"][nIndex]["recordNumber"], "1", "")
				//Incrementa contador de registros processados.
				oProcesso:incCount("TRANSF_PROCESSADO")
				Loop
			EndIf

			cFilAnt  := PadR(oJson["items"][nIndex]["originBranchId"], nTamFilial)
			cProduto := PadR(oJson["items"][nIndex]["product"]       , nTamPrd)

			If oProcesso:lSugEmpenho .And. !oSugestObj:hasProperty(cFilAnt)
				oSugestObj[cFilAnt] := SugestaoLotesEnderecos():New(NIL, oProcesso:lDeTerceiros, oProcesso:lEmTerceiros, , cErrorUID, cTicket, "PCPA151TRF_" + AllTrim(cFilAnt) + "_")
			EndIf

			//Busca a unidade de medida do produto
			If !oCachePrd:hasProperty(cProduto)
				oCachePrd[cProduto] := JsonObject():New()
				oCachePrd[cProduto]["B1_UM"]      := ""
				oCachePrd[cProduto]["B1_RASTRO"]  := ""
				oCachePrd[cProduto]["B1_LOCALIZ"] := ""

				If SB1->(dbSeek(xFilial("SB1") + cProduto))
					oCachePrd[cProduto]["B1_UM"]      := SB1->B1_UM
					oCachePrd[cProduto]["B1_RASTRO"]  := SB1->B1_RASTRO
					oCachePrd[cProduto]["B1_LOCALIZ"] := SB1->B1_LOCALIZ
				EndIf
			EndIf

			cLocal := PadR(oJson["items"][nIndex]["originWarehouse"],nTamLoc)

			oProcesso:criaSB2(cFilAnt,cProduto,cLocal,.F.)
			oProcesso:criaSB2(PadR(oJson["items"][nIndex]["destinyBranchId"], nTamFilial),cProduto,PadR(oJson["items"][nIndex]["destinyWarehouse"],nTamLoc),.F.)

			//Seta opera��o de Inclus�o
			oModel:SetOperation(3)
			//Ativa o modelo
			oModel:Activate()

			//Campos mestre da transfer�ncia
			lRet := lRet .And. oMdlNNS:SetValue("NNS_DATA"   , oJson["items"][nIndex]["transferenceDate"])
			lRet := lRet .And. oMdlNNS:SetValue("NNS_STATUS" , "1")
			lRet := lRet .And. oMdlNNS:SetValue("NNS_CLASS"  , "1")
			lRet := lRet .And. oMdlNNS:SetValue("NNS_SOLICT" , oProcesso:cCodUsr)

			//Campos detalhe da transfer�ncia
			lRet := setValNNT(oMdlNNT                                                    ,;
			                  cFilAnt                                                    ,;
			                  cProduto                                                   ,;
			                  oCachePrd[cProduto]["B1_UM"]                               ,;
			                  cLocal                                                     ,;
			                  PadR(oJson["items"][nIndex]["destinyBranchId"], nTamFilial),;
			                  cProduto                                                   ,;
			                  oCachePrd[cProduto]["B1_UM"]                               ,;
			                  PadR(oJson["items"][nIndex]["destinyWarehouse"], nTamLoc)  ,;
			                  cTesSaida                                                  ,;
			                  cTesEntra                                                  ,;
			                  oJson["items"][nIndex]["ticket"])

			//Sugest�o de lote e endere�o
			If lRet .And. oProcesso:lSugEmpenho
				aUsados  := oSugestObj[cFilAnt]:retornaSugestao(cProduto                                      , ;
																cLocal                                        , ;
																oJson["items"][nIndex]["transferenceQuantity"], ;
																oCachePrd[cProduto]["B1_RASTRO"]              , ;
																oCachePrd[cProduto]["B1_LOCALIZ"]             , ;
																oJson["items"][nIndex]["transferenceDate"]    , ;
																oProcesso:getTipoDocumento()                  , ;
																.F.)

				nTotUsado := Len(aUsados)
				If nTotUsado > 0
					For nIndUsado := 1 To nTotUsado
						If nIndUsado > 1
							lRet := IIf(nIndUsado == oMdlNNT:AddLine(), .T., .F.)
							lRet := lRet .And. setValNNT(oMdlNNT                                                    ,;
							                             cFilAnt                                                    ,;
							                             cProduto                                                   ,;
							                             oCachePrd[cProduto]["B1_UM"]                               ,;
							                             cLocal                                                     ,;
							                             PadR(oJson["items"][nIndex]["destinyBranchId"], nTamFilial),;
							                             cProduto                                                   ,;
							                             oCachePrd[cProduto]["B1_UM"]                               ,;
							                             PadR(oJson["items"][nIndex]["destinyWarehouse"], nTamLoc)  ,;
							                             cTesSaida                                                  ,;
							                             cTesEntra                                                  ,;
							                             oJson["items"][nIndex]["ticket"])
						EndIf

						lRet := lRet .And. oMdlNNT:SetValue("NNT_QUANT" , aUsados[nIndUsado][PCPA151Cnt("xPOS_aUsados_QUANTIDADE")])
						lRet := lRet .And. oMdlNNT:SetValue("NNT_LOTECT", aUsados[nIndUsado][PCPA151Cnt("xPOS_aUsados_LOTE")])
						lRet := lRet .And. oMdlNNT:SetValue("NNT_NUMLOT", aUsados[nIndUsado][PCPA151Cnt("xPOS_aUsados_SUBLOTE")])
						lRet := lRet .And. oMdlNNT:SetValue("NNT_LOCALI", aUsados[nIndUsado][PCPA151Cnt("xPOS_aUsados_LOCALIZACAO")])
						lRet := lRet .And. oMdlNNT:SetValue("NNT_NSERIE", aUsados[nIndUsado][PCPA151Cnt("xPOS_aUsados_NUM_SERIE")])

						If lRet .And. lLoteDesOr
							lRet := lRet .And. oMdlNNT:SetValue("NNT_LOTED", aUsados[nIndUsado][PCPA151Cnt("xPOS_aUsados_LOTE")])
							lRet := lRet .And. oMdlNNT:SetValue("NNT_DTVALD", aUsados[nIndUsado][PCPA151Cnt("xPOS_aUsados_VALIDADE")])
						EndIf

						If !lRet .Or. !oMdlNNT:VldLineData(.F.)
							Exit
						EndIf
					Next nIndUsado

					aSize(aUsados, 0)
				Else
					lRet := lRet .And. oMdlNNT:SetValue("NNT_QUANT" , oJson["items"][nIndex]["transferenceQuantity"])
				EndIf
			Else
				lRet := lRet .And. oMdlNNT:SetValue("NNT_QUANT" , oJson["items"][nIndex]["transferenceQuantity"])
			EndIf

			//Se conseguiu setar os valores no modelo, faz a valida��o dos dados e commit.
			If lRet
				//Faz a valida��o dos dados
				If ( lRet := oModel:VldData() )
					//Realiza o commit
					lRet := oModel:CommitData()
				EndIf
			EndIf

			//Se ocorreu algum erro, recupera a mensagem de erro.
			If !lRet
				cMsg := STR0026 + ": " + oModel:GetErrorMessage()[6] //Erro: XXXX
				If !Empty(oModel:GetErrorMessage()[7])
					cMsg += " " + STR0027 + ": " + oModel:GetErrorMessage()[7] // Solu��o: XXXX
				EndIf
				oProcesso:incCount("TRANSF_ERROS")
			Else
				//Processado com sucesso, recupera o ID da transfer�ncia.
				cMsg := oMdlNNS:GetValue("NNS_COD")
			EndIf

			//Atualiza o status da tabela SMA.
			MrpUpStSMA(oJson["items"][nIndex]["recordNumber"], Iif(lRet, "1", "2"), cMsg)

			//Destivar o modelo de dados.
			oModel:DeActivate()

			//Incrementa contador de registros processados.
			oProcesso:incCount("TRANSF_PROCESSADO")
		Next nIndex

		If oProcesso:lSugEmpenho
			aNames   := oSugestObj:GetNames()
			nTotFils := Len(aNames)

			For nIndex := 1 To nTotFils
				oSugestObj[aNames[nIndex]]:Destroy()
				FreeObj(oSugestObj[aNames[nIndex]])
			Next nIndex

			FreeObj(oSugestObj)
			aSize(aNames, 0)
		EndIf

		//Limpa os dados da mem�ria
		aSize(oJson["items"], 0)
		FreeObj(oJson)
		oProcesso:msgLog(STR0025 + cValToChar(MicroSeconds()-nStart)) //"T�rmino do processamento das transfer�ncias. Tempo total: "
	Else
		oProcesso:initCount("TRANSF_TOTAL", 0)
	EndIf

	aSize(aRegs, 0)
	FreeObj(oCachePrd)

	If cFilAnt != cFilBkp
		cFilAnt := cFilBkp
	EndIf

	//Incrementa contador para identificar que a thread foi finalizada.
	oProcesso:incCount("TRANSF_FIM")
Return Nil

/*/{Protheus.doc} buscaTES
Busca as TES de entrada e sa�da para utiliza��o nas transfer�ncias.

@type  Static Function
@author lucas.franca
@since 19/11/2020
@version P12
@param cTesEntra, Character, TES de entrada, ir� retornar por refer�ncia
@param cTesSaida, Character, TES de sa�da, ir� retornar por refer�ncia.
@return Nil
/*/
Static Function buscaTES(cTesEntra, cTesSaida)
	Local cGrupo     := cEmpAnt
	Local cEmp       := FWCompany()
	Local cUnid      := FWUnitBusiness()
	Local cFil       := FwFilial()
	Local nTamOPGE   := GetSx3Cache("OP_CDEPGR", "X3_TAMANHO")
	Local nTamOPEmp  := GetSx3Cache("OP_EMPRGR", "X3_TAMANHO")
	Local nTamOPUnid := GetSx3Cache("OP_UNIDGR", "X3_TAMANHO")
	Local nTamOPFil  := GetSx3Cache("OP_CDESGR", "X3_TAMANHO")

	cGrupo := PadR(cGrupo, nTamOPGE)
	cEmp   := PadR(cEmp  , nTamOPEmp)
	cUnid  := PadR(cUnid , nTamOPUnid)
	cFil   := PadR(cFil  , nTamOPFil)

	SOO->(dbSetOrder(2))
	If SOO->(dbSeek(xFilial("SOO")+cGrupo+cEmp+cUnid+cFil))
		cTesEntra := SOO->OO_TE
		cTesSaida := SOO->OO_TS
	EndIf
Return Nil

/*/{Protheus.doc} setValNNT
Seta os campos da tabela NNT que n�o se alteram com a sugest�o de lote

@type Static Function
@author marcelo.neumann
@since 15/03/2022
@version P12
@param 01 oMdlNNT  , Object   , inst�ncia do modelo a serem setados os valores
@param 02 cFilOri  , Character, filial origem
@param 03 cProdOri , Character, produto origem
@param 04 cUMOri   , Character, unidade de medida origem
@param 05 cLocalOri, Character, local origem
@param 06 cFilDes  , Character, filial destino
@param 07 cProdDes , Character, produto destino
@param 08 cUMDes   , Character, unidade de medida destino
@param 09 cLocalDes, Character, local destino
@param 10 cTesSaida, Character, TES de entrada
@param 11 cTesEntra, Character, TES de sa�da
@param 12 cTicket  , Character, ticket do MRP
@return   lRet     , Logic    , indica se conseguiu setar corretamente todos os valores no modelo
/*/
Static Function setValNNT(oMdlNNT, cFilOri, cProdOri, cUMOri, cLocalOri, cFilDes, cProdDes, cUMDes, cLocalDes, cTesSaida, cTesEntra, cTicket)
	Local lRet := .T.

	lRet := lRet .And. oMdlNNT:SetValue("V_EXEC_MRP", "1")
	lRet := lRet .And. oMdlNNT:SetValue("NNT_FILORI", cFilOri)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_PROD"  , cProdOri)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_UM"    , cUMOri)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_LOCAL" , cLocalOri)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_FILDES", cFilDes)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_PRODD" , cProdDes)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_UMD"   , cUMDes)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_LOCLD" , cLocalDes)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_TS"    , cTesSaida)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_TE"    , cTesEntra)
	lRet := lRet .And. oMdlNNT:SetValue("NNT_OBS"   , "MRP " + cTicket)

Return lRet

