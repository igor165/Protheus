#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145.ch"
#INCLUDE "PCPA145DEF.ch"

Static __lSetDoc  := FindFunction("P145SetDoc")
Static _oProcesso := Nil

/*/{Protheus.doc} PCPA145PC
Função para geração das autorizações de entrega (Pedido de compra)

@type Function
@author ricardo.prandi
@since 03/03/2020
@version P12.1.30
@param cTicket, Character, Ticket de processamento do MRP para geração dos documentos
@param cCodUsr, Character, Código do usuário logado no sistema.
@return Nil
/*/
Function PCPA145PC(cTicket, cCodUsr)
	Local aCampos    := {}
	Local aDados     := {}
	Local aGlobal    := {}
	Local aRetorno   := {}
	Local cDocGerado := ""
	Local cDocPaiERP := ""
	Local cItemSC    := ""
	Local cTipDocERP := ""
	Local cTipoOp    := ""
	Local cNumScUni  := ""
	Local cStatus    := ""
	Local lGeraSCPCP := .F.
	Local lRet       := .T.
	Local lCriaDocum := .T.
	Local nIndDados  := 0
	Local nIndRet    := 0
	Local nSaldoSC   := 0
	Local nTotReg    := 0
	
	//Verifica se é necessário instanciar a classe ProcessaDocumentos nesta thread filha para utilização dos métodos.
	If _oProcesso == Nil
		_oProcesso := ProcessaDocumentos():New(cTicket, .T., /*03*/, cCodUsr)
	EndIf

	While .T.
		//Busca os dados a serem processados
		If VarGetAA(_oProcesso:cUIDGeraAE, @aGlobal)
			
			//Se veio a TAG para encerrar a Thread, sai da repetição
			If Len(aGlobal) > 0 .And. aGlobal[1][1] == "EndPurchaseOrder"
				Exit
			EndIf

			//Ordena o array, pois a funçõa VarGetAA retorna os dados em formato FILA (First in, Last Out)
			aSort(aGlobal,,,{|x,y| x[1]<y[1]})
						
			nTotReg := Len(aGlobal)
			
			//Percorre os dados para gerar as autorizações de entrega
			For nIndDados := 1 To nTotReg
				aDados := aGlobal[nIndDados][2]

				lCriaDocum := _oProcesso:dataValida(aDados[RASTREIO_POS_DATA_ENTREGA], "SC")

				If lCriaDocum .And. aDados[RASTREIO_POS_NECESSIDADE] > 0
					If cFilAnt != aDados[RASTREIO_POS_FILIAL]
						cFilAnt := aDados[RASTREIO_POS_FILIAL]
					EndIf

					cTipoOp    := _oProcesso:getTipoDocumento(aDados[RASTREIO_POS_DATA_ENTREGA], "SC")
					cDocPaiERP := _oProcesso:getDocumentoDePara(aDados[RASTREIO_POS_DOCPAI], cFilAnt)[2]
					aCampos    := {}
					
					aAdd(aCampos, {"DATPRF", aDados[RASTREIO_POS_DATA_ENTREGA]})
					aAdd(aCampos, {"SEQMRP", cTicket                          })
					aAdd(aCampos, {"TPOP"  , cTipoOp                          })
					aAdd(aCampos, {"USER"  , cCodUsr                          })
			
					lGeraSCPCP := .F.
					nSaldoSC   := 0
					
					//Gera autorização de entrega
					aRetorno := MatGeraAE(aDados[RASTREIO_POS_PRODUTO], aDados[RASTREIO_POS_NECESSIDADE], aCampos, /*04*/, /*05*/, /*06*/, /*07*/, .T., @lGeraSCPCP, @nSaldoSC)

					//Atualiza tabela temporária para atualização de estoques
					For nIndRet := 1 To Len(aRetorno)
						_oProcesso:atualizaSaldo(aDados[RASTREIO_POS_PRODUTO],;
												aDados[RASTREIO_POS_LOCAL]  ,;
												aDados[RASTREIO_POS_NIVEL]  ,;
												aRetorno[nIndRet,1]         ,;
												1                           ,; //Tipo 1 = Entrada
												IIF(cTipoOp == "P",.T.,.F.) ,; //Documento Previsto
												cFilAnt                      )
					Next nIndRet
			
					//Se existar a necessidade de gerar solicitação de compra, função MatGeraAE irá retornar 
					//a variável lGeraSCPCP como .T. e a variável nSaldoSC como a quantidade a ser gerada.
					If lGeraSCPCP
						aDados[RASTREIO_POS_NECESSIDADE] := nSaldoSC
						cNumScUni  := _oProcesso:getDocUni("C1_NUM", cFilAnt)
						cDocGerado := PCPA145SC(@_oProcesso, @aDados, cDocPaiERP, STR0001, cNumScUni, @cItemSC) //"PRODUTO SEM CONTRATO VÁLIDO."
						cDocGerado += cItemSC
						cTipDocErp := "2"
					ElseIf !Empty(aRetorno)
						cDocGerado := aRetorno[1,2]
						cTipDocErp := "3"	
					EndIf

				EndIf
				
				//Se não gerou documento devido a seleção de datas, registra status 3 na HWC.
				cStatus := Iif(lCriaDocum, "1", "3")

				//Atualiza o status na HWC
				_oProcesso:updStatusRastreio("1"                      ,;
											cDocGerado               ,;
											cTipDocERP               ,;
											aDados[RASTREIO_POS_RECNO])

				If __lSetDoc
					P145SetDoc(_oProcesso, aDados, cTipDocERP, cDocGerado)
				EndIf

				//Apaga da variável global o registro processado
				lRet := VarDel(_oProcesso:cUIDGeraAE, aGlobal[nIndDados][1])
				_oProcesso:incCount("SAIDAPC")

				If !lRet
					_oProcesso:msgLog(STR0021) //"Não foi possível limpar a variável global na geração de pedido de compra."
				EndIf
			Next nIndDados

			//Limpa memória
			aSize(aDados  , 0)
			aSize(aGlobal , 0)
			aSize(aRetorno, 0)
		EndIf

		//Aguarda para tentar novo processamento
		Sleep(50)
	EndDo
Return Nil
