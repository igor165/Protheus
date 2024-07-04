#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145.ch"
#INCLUDE "PCPA145DEF.ch"

Static _cLoteCtl := CriaVar("D4_LOTECTL")
Static _cNumLote := CriaVar("D4_NUMLOTE")
Static _oFilSD4  := JsonObject():New()

/*/{Protheus.doc} PCPA145Emp
Função para geração dos empenhos.

@type  Function
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param oProcesso , Object, Instância da classe ProcessaDocumentos
@param aDados    , Array , Array com as informações do rastreio que serão processados.
                           As posições deste array são acessadas através das constantes iniciadas
                           com o nome RASTREIO_POS. Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param aDocPaiERP, Array , Lista dos documentos gerados pelo Protheus
                           Estrutura do array:
                           aDocPaiERP[nIndex][1] - Documento gerado no ERP Protheus
                           aDocPaiERP[nIndex][2] - Quantidade de empenho necessário para o documento
@param lApropInd , Logic , Indica se o produto que está sendo processado possui apropriação indireta
@return Nil
/*/
Function PCPA145Emp(oProcesso, aDados, aDocPaiERP, lApropInd)
	Local aDadosEmp  := {}
	Local aDadosOP   := {}
	Local aQtdSaldo  := Array(2)
	Local cTicket    := oProcesso:cTicket
	Local cProdOrig  := " "
	Local cRoteiro   := ""
	Local cOperacao  := ""
	Local cProdPai   := ""
	Local cLocEmp    := aDados[RASTREIO_POS_LOCAL]
	Local dDataEmp   := aDados[RASTREIO_POS_DATA_ENTREGA]
	Local lAglutina  := oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
	Local nBaixaEst  := aDados[RASTREIO_POS_BAIXA_EST]
	Local nQtdEmpEst := 0
	Local nPos       := 0
	Local nPosSaldo  := 0
	Local nSaldo     := 0
	Local nIndexDoc  := 0
	Local nTipo      := 0
	Local nTotalDoc  := Len(aDocPaiERP)

	//Se possui chave de substituição, é necessário buscar qual o produto origem
	If Empty(aDados[RASTREIO_POS_CHAVE_SUBST])
		cProdOrig := " "
	Else
		cProdOrig := retProOrig(aDados[RASTREIO_POS_CHAVE_SUBST], cTicket, aDados[RASTREIO_POS_DOCPAI])
	EndIf

	If _oFilSD4[cFilAnt] == Nil
		_oFilSD4[cFilAnt] := xFilial("SD4")
	EndIf

	/*
		aQtdSaldo - Array de duas posições, armazenas as quantidades de saldo para atualização da SB2, sendo:
		aQtdSaldo[1] - Quantidade de empenho vinculado a OP Firme
		aQtdSaldo[2] - Quantidade de empenho vinculado a OP Prevista
	*/
	aQtdSaldo[1] := 0
	aQtdSaldo[2] := 0

	If lApropInd
		cLocEmp := oProcesso:getLocProcesso()
	EndIf

	For nIndexDoc := 1 To nTotalDoc
		If aDocPaiERP[nIndexDoc][2] == 0
			Loop
		EndIf
		nQtdEmpEst := 0

		aDadosOP  := oProcesso:getDadosOP(cFilAnt, aDocPaiERP[nIndexDoc][1])
		cProdPai  := aDadosOP[1]
		nPosSaldo := Iif(aDadosOP[3] == "F", 1, 2)
		dDataEmp  := aDadosOP[4]
		If Empty(aDados[RASTREIO_POS_OPERACAO]) .Or. Empty(aDados[RASTREIO_POS_ROTEIRO])
			cRoteiro := aDadosOP[2]

			If !Empty(cRoteiro)
				cOperacao := oProcesso:getOperacaoComp(cFilAnt, cProdPai, cRoteiro, aDados[RASTREIO_POS_PRODUTO], aDados[RASTREIO_POS_TRT])
			Else
				cOperacao := ""
			EndIf
		Else
			cRoteiro  := aDados[RASTREIO_POS_ROTEIRO ]
			cOperacao := aDados[RASTREIO_POS_OPERACAO]
		EndIf
		aSize(aDadosOP, 0)

		// Caso não haja roteiro, é definido o valor 01
		If Empty(cRoteiro)
			cRoteiro  := "01"
		EndIf

		//Verifca o nível, se for nivel 99, gera o registro do empenho com o valor total e finaliza o processo.
		//Se não for nível 99, é necessário quebrar o empenho, gerando 1 registro com o valor da necessidade
		//e outro registro com o valor utilizado de estoque, se houver.
		If aDados[RASTREIO_POS_NIVEL] == "99"
			//Inclui a linha do Array
			Aadd(aDadosEmp,{})
			nPos := Len(aDadosEmp)

			aDadosEmp[nPos] := Array(EMPENHO_TAMANHO)
			aDadosEmp[nPos,EMPENHO_POS_FILIAL         ] := _oFilSD4[cFilAnt]
			aDadosEmp[nPos,EMPENHO_POS_ORDEM_PRODUCAO ] := aDocPaiERP[nIndexDoc][1]
			aDadosEmp[nPos,EMPENHO_POS_DATA_EMPENHO   ] := dDataEmp
			aDadosEmp[nPos,EMPENHO_POS_PRODUTO        ] := aDados[RASTREIO_POS_PRODUTO     ]
			aDadosEmp[nPos,EMPENHO_POS_LOCAL          ] := cLocEmp
			aDadosEmp[nPos,EMPENHO_POS_QUANTIDADE     ] := aDocPaiERP[nIndexDoc][2]
			aDadosEmp[nPos,EMPENHO_POS_QTD_ORIGINAL   ] := aDocPaiERP[nIndexDoc][2]
			aDadosEmp[nPos,EMPENHO_POS_TRT            ] := aDados[RASTREIO_POS_TRT         ]
			aDadosEmp[nPos,EMPENHO_POS_ROTEIRO        ] := cRoteiro
			aDadosEmp[nPos,EMPENHO_POS_OPERACAO       ] := cOperacao
			aDadosEmp[nPos,EMPENHO_POS_QTD_SEGUNDA_UM ] := oProcesso:ConvUm(aDados[RASTREIO_POS_PRODUTO], aDocPaiERP[nIndexDoc][2], 0, 2)
			aDadosEmp[nPos,EMPENHO_POS_OP_ORIGEM      ] := " "
			aDadosEmp[nPos,EMPENHO_POS_PRODUTO_PAI    ] := cProdPai
			aDadosEmp[nPos,EMPENHO_POS_PRODUTO_ORIGEM ] := cProdOrig

			//Armazena qtd de saldo para atualização da SB2 de acordo com o tipo da OP (Firme/Prevista)
			aQtdSaldo[nPosSaldo] += aDocPaiERP[nIndexDoc][2]
		Else
			//Verifica se houve baixa do estoque e, caso exista, gerar um registro com o valor baixado,
			//com o campo D4_OPORIG em branco
			//Quando parametrizado para aglutinar, não irá fazer a quebra do empenho.
			If nBaixaEst > 0 .And. !lAglutina
				//Inclui a linha do Array
				Aadd(aDadosEmp,{})
				nPos := Len(aDadosEmp)

				aDadosEmp[nPos] := Array(EMPENHO_TAMANHO)
				aDadosEmp[nPos,EMPENHO_POS_FILIAL         ] := _oFilSD4[cFilAnt]
				aDadosEmp[nPos,EMPENHO_POS_ORDEM_PRODUCAO ] := aDocPaiERP[nIndexDoc][1]
				aDadosEmp[nPos,EMPENHO_POS_DATA_EMPENHO   ] := dDataEmp
				aDadosEmp[nPos,EMPENHO_POS_PRODUTO        ] := aDados[RASTREIO_POS_PRODUTO     ]
				aDadosEmp[nPos,EMPENHO_POS_LOCAL          ] := cLocEmp

				//Verifica se a qtd. de estoque atende totalmente ou parcialmente
				//o empenho do documento corrente (aDocPaiERP)
				If nBaixaEst >= aDocPaiERP[nIndexDoc][2]
					aDadosEmp[nPos,EMPENHO_POS_QUANTIDADE  ] := aDocPaiERP[nIndexDoc][2]
					aDadosEmp[nPos,EMPENHO_POS_QTD_ORIGINAL] := aDocPaiERP[nIndexDoc][2]
					nBaixaEst -= aDocPaiERP[nIndexDoc][2]

					//Armazena qtd de saldo para atualização da SB2 de acordo com o tipo da OP (Firme/Prevista)
					aQtdSaldo[nPosSaldo] += aDocPaiERP[nIndexDoc][2]
				Else
					aDadosEmp[nPos,EMPENHO_POS_QUANTIDADE  ] := nBaixaEst
					aDadosEmp[nPos,EMPENHO_POS_QTD_ORIGINAL] := nBaixaEst

					//Armazena qtd de saldo para atualização da SB2 de acordo com o tipo da OP (Firme/Prevista)
					aQtdSaldo[nPosSaldo] += nBaixaEst

					nBaixaEst := 0
				EndIf

				aDadosEmp[nPos,EMPENHO_POS_TRT            ] := aDados[RASTREIO_POS_TRT         ]
				aDadosEmp[nPos,EMPENHO_POS_ROTEIRO        ] := cRoteiro
				aDadosEmp[nPos,EMPENHO_POS_OPERACAO       ] := cOperacao
				aDadosEmp[nPos,EMPENHO_POS_QTD_SEGUNDA_UM ] := oProcesso:ConvUm(aDados[RASTREIO_POS_PRODUTO], aDadosEmp[nPos,EMPENHO_POS_QUANTIDADE], 0, 2)
				aDadosEmp[nPos,EMPENHO_POS_OP_ORIGEM      ] := " "
				aDadosEmp[nPos,EMPENHO_POS_PRODUTO_PAI    ] := cProdPai
				aDadosEmp[nPos,EMPENHO_POS_PRODUTO_ORIGEM ] := cProdOrig

				//Controle de qtd. de empenho gerado pela baixa de estoque
				nQtdEmpEst := aDadosEmp[nPos,EMPENHO_POS_QUANTIDADE]
			EndIf

			//Verifica se há saldo ainda a ser empenhado.
			nSaldo := aDocPaiERP[nIndexDoc][2] - nQtdEmpEst

			//Caso exista, gera um novo registro na SD4, com o valor restante
			If nSaldo != 0
				//Inclui a linha do Array
				Aadd(aDadosEmp,{})
				nPos := Len(aDadosEmp)

				aDadosEmp[nPos] := Array(EMPENHO_TAMANHO)
				aDadosEmp[nPos,EMPENHO_POS_FILIAL         ] := _oFilSD4[cFilAnt]
				aDadosEmp[nPos,EMPENHO_POS_ORDEM_PRODUCAO ] := aDocPaiERP[nIndexDoc][1]
				aDadosEmp[nPos,EMPENHO_POS_DATA_EMPENHO   ] := dDataEmp
				aDadosEmp[nPos,EMPENHO_POS_PRODUTO        ] := aDados[RASTREIO_POS_PRODUTO     ]
				aDadosEmp[nPos,EMPENHO_POS_LOCAL          ] := cLocEmp
				aDadosEmp[nPos,EMPENHO_POS_TRT            ] := aDados[RASTREIO_POS_TRT         ]
				aDadosEmp[nPos,EMPENHO_POS_ROTEIRO        ] := cRoteiro
				aDadosEmp[nPos,EMPENHO_POS_OPERACAO       ] := cOperacao
				aDadosEmp[nPos,EMPENHO_POS_QUANTIDADE     ] := nSaldo
				aDadosEmp[nPos,EMPENHO_POS_QTD_ORIGINAL   ] := nSaldo
				aDadosEmp[nPos,EMPENHO_POS_QTD_SEGUNDA_UM ] := oProcesso:ConvUm(aDados[RASTREIO_POS_PRODUTO], nSaldo, 0, 2)
				aDadosEmp[nPos,EMPENHO_POS_PRODUTO_PAI    ] := cProdPai
				aDadosEmp[nPos,EMPENHO_POS_PRODUTO_ORIGEM ] := cProdOrig
				If lAglutina
					aDadosEmp[nPos,EMPENHO_POS_OP_ORIGEM  ] := " "
				Else
					aDadosEmp[nPos,EMPENHO_POS_OP_ORIGEM  ] := oProcesso:getDocumentoDePara(aDados[RASTREIO_POS_DOCFILHO], cFilAnt)[2]
					If aDadosEmp[nPos,EMPENHO_POS_OP_ORIGEM] == Nil
						aDadosEmp[nPos,EMPENHO_POS_OP_ORIGEM] := " "
					EndIf
				EndIf

				//Armazena qtd de saldo para atualização da SB2 de acordo com o tipo da OP (Firme/Prevista)
				aQtdSaldo[nPosSaldo] += nSaldo
			EndIf
		EndIf
	Next nIndexDoc

	//Grava os dados na tabela SD4
	gravaSD4(oProcesso,aDadosEmp,lAglutina,aDados[RASTREIO_POS_NIVEL])

	//Grava dados de saldo em memória
	nTipo := Iif(aDados[RASTREIO_POS_EMPENHO] < 0, 1, 2)
	For nPosSaldo := 1 To 2 
		If aQtdSaldo[nPosSaldo] == 0
			Loop
		EndIf

		//Se for empenho negativo, transforma a qtd em positivo para atualizar corretamente o saldo.
		If nTipo == 1
			aQtdSaldo[nPosSaldo] := Abs(aQtdSaldo[nPosSaldo])
		EndIf

		//Atualiza tabela temporária para atualização de estoques
		oProcesso:atualizaSaldo(aDados[RASTREIO_POS_PRODUTO],;
								cLocEmp                     ,;
								aDados[RASTREIO_POS_NIVEL]  ,;
								aQtdSaldo[nPosSaldo]        ,;
								nTipo                       ,; //Tipo 1 = Entrada; 2 = Saída
								Iif(nPosSaldo == 2,.T.,.F.) ,; //Documento Previsto
								cFilAnt                      )

	Next nPosSaldo

	aSize(aQtdSaldo, 0)

Return

/*/{Protheus.doc} gravaSD4
Função que irá inserir os dados na tabela SD4

@type  Static Function
@author ricardo.prandi
@since 22/11/2019
@version P12.1.27
@param aDadosEmp, Array, Valores que serão incluídos na SD4
@param lAglutina, Logico, Indica se algutina as ordens e solicitações de compras
@param cNivel, Caracter, Indica qual o nível do produto que está sendo gerado
@return Nil
/*/
Static Function gravaSD4(oProcesso, aDadosEmp, lAglutina, cNivel)
	Local nPos   := 0
	Local nTotal := 0
	Local nRecno := 0

	//Se for aglutinação, é preciso verificar se já existe o registro na SD4.
	//Caso exista, deve somar os valores, caso não exista, incluir um novo registro.
	//Se não for aglutinação, incluir os registros separadamente.

	nTotal := Len(aDadosEmp)

	For nPos := 1 to nTotal
		If oProcesso:existEmpenho(aDadosEmp[nPos], @nRecno)
			SD4->(dbGoTo(nRecno))
			RecLock("SD4",.F.)
				Replace D4_QUANT   With D4_QUANT   + aDadosEmp[nPos,EMPENHO_POS_QUANTIDADE    ]
				Replace D4_QTDEORI With D4_QTDEORI + aDadosEmp[nPos,EMPENHO_POS_QTD_ORIGINAL  ]
				Replace D4_QTSEGUM With D4_QTSEGUM + aDadosEmp[nPos,EMPENHO_POS_QTD_SEGUNDA_UM]
			SD4->(MsUnlock())
		Else
			//Proteção identificação do próximo RECNO da T4R em Trigger
			VarBeginT("LOCK_SD4", "RecLockT")
			RecLock("SD4",.T.)
			VarEndT("LOCK_SD4", "RecLockT")
				Replace D4_FILIAL  With aDadosEmp[nPos,EMPENHO_POS_FILIAL        ]
				Replace D4_OP      With aDadosEmp[nPos,EMPENHO_POS_ORDEM_PRODUCAO]
				Replace D4_DATA    With aDadosEmp[nPos,EMPENHO_POS_DATA_EMPENHO  ]
				Replace D4_COD     With aDadosEmp[nPos,EMPENHO_POS_PRODUTO       ]
				Replace D4_LOCAL   With aDadosEmp[nPos,EMPENHO_POS_LOCAL         ]
				Replace D4_QUANT   With aDadosEmp[nPos,EMPENHO_POS_QUANTIDADE    ]
				Replace D4_QTDEORI With aDadosEmp[nPos,EMPENHO_POS_QTD_ORIGINAL  ]
				Replace D4_TRT 	   With aDadosEmp[nPos,EMPENHO_POS_TRT           ]
				Replace D4_QTSEGUM With aDadosEmp[nPos,EMPENHO_POS_QTD_SEGUNDA_UM]
				Replace D4_OPORIG  With aDadosEmp[nPos,EMPENHO_POS_OP_ORIGEM     ]
				Replace D4_PRODUTO With aDadosEmp[nPos,EMPENHO_POS_PRODUTO_PAI   ]
				Replace D4_ROTEIRO With aDadosEmp[nPos,EMPENHO_POS_ROTEIRO       ]
				Replace D4_OPERAC  With aDadosEmp[nPos,EMPENHO_POS_OPERACAO      ]
				Replace D4_PRDORG  With aDadosEmp[nPos,EMPENHO_POS_PRODUTO_ORIGEM]
				Replace D4_QTNECES With 0
				Replace D4_NUMLOTE With _cNumLote
				Replace D4_LOTECTL With _cLoteCtl
			SD4->(MsUnlock())

			oProcesso:addEmpenho(aDadosEmp[nPos], SD4->(Recno()))
		EndIf

		//Inclui dados do empenho para integração
		//O envio dos empenhos será feito somente no fim do processamento, na função PCPA145INT
		salvaEmInt(oProcesso)
	Next nPos

Return

/*/{Protheus.doc} retProOrig
Retorna o produto origem de um empenho de alternativo
****Essa função será substituida pela API****

@type  Static Function
@author ricardo.prandi
@since 27/11/2019
@version P12.1.27
@param cChave, Caracter, Chave do registro de substituição, vindo da tabela HWC
@return cProdOrig, Caracter, Código do produto origem
/*/
Static Function retProOrig(cChave,cTicket,cDocPai)

	Local cProdOrig := " "
	Local oJson     := Nil

	aRegs := MrpPrdOrig(cTicket, cChave, cDocPai  )
	If aRegs[1]
		oJson := JsonObject():New()
		oJson:FromJson(aRegs[2])

		If Len(oJson["items"]) > 0
			cProdOrig := oJson["items"][1]["componentCode"]
		EndIf

		aSize(oJson["items"],0)
		FreeObj(oJson)
	EndIf

Return cProdOrig

/*/{Protheus.doc} salvaEmInt
Salva em memória o RECNO do empenho posicionado na tabela SD4 para integrar posteriormente.

@type Method
@author marcelo.neumann
@since 30/08/2021
@version P12
@param oProcesso, objeto, instância da classe ProcessaDocumentos
@return Nil
/*/
Static Function salvaEmInt(oProcesso)
	Local cRecno := 0

	If !oProcesso:aIntegra[INTEGRA_OP_SFC]
		Return
	EndIf

	cRecno := Str(SD4->(Recno()))

	//Salva na seção global de empenhos a integrar.
	If !VarSetAD(oProcesso:cUIDIntEmp, cRecno, {cFilAnt})
		oProcesso:msgLog(STR0040 + cRecno)  //"Não conseguiu adicionar o empenho para integrar. "
	EndIf

Return
