#INCLUDE "MATA650.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "fwlibversion.ch"

Static _lNewMRP     := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A650Automa³ Autor ³ Claudinei M. Benzi    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para escolha de pedidos a gerar OP                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A650Automa(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata650                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA650C(cAlias,nReg,nOpc,lAuto,aParams) //Qweasdzxc
Local cMarca
Local cCondMark   := ""
Local cCondMrkPE  := ""
Local nZ          := 0
Local ni          := 0
Local lRet        := .T.
Local lConsEst    := (SuperGetMV("MV_CONSEST") == "S")
Local lAtuSGJ 	  := SuperGetMV("MV_PVCOMOP",.F.,.F.)
Local nLoop		  := 0
Local aFornecedor := {}
Local nPrc		  := 0
Local aDocs		  := {}
Local aResultados := {}
Local aDatasNec	  := {}
Local aCampos	  := {}
Local nX    	  := 0
Local nPos   	  := 0

Default lAuto := .F.
Default aParams := {}

Private aRetorOpc := {}
Private cOp       := "" // Variavel private para utilizacao do P.E.
Private lAltEsp	  := .F. // Indica se ‚ a 1a. Entrada ap¢s alteracao especificacao
Private lAllMark  := .F. //Controle para o allmark do markbrowser.
Private lAllHelp  := .F. //Controle de help para o allmark do markbrowser.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array criado p/ substituir parametros                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aSav651 := Array(26)

Private cSeqC2   := "000"
Private Inclui   := .T.
Private l651Auto := lAuto

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0014) //"OP por Pedido de Venda"
Private oMarkBrw

If l651Auto
	Pergunte("MTA651",.F.)
	For ni := 1 to 26
		//Verifica se o parâmetro foi enviado no execauto.
		nPos := ASCAN(aParams, { |x|  Alltrim(Upper(x[1])) == "MV_PAR"+StrZero(ni,2)})
		IF nPos == 0
			aSav651[ni] := &("mv_par"+StrZero(ni,2)) //Padrão
		ELSE
			IF VALTYPE(aParams[nPos,2]) <> VALTYPE(&("mv_par"+StrZero(ni,2))) //Verifica se o tipo da variavel esta correto
				aSav651[ni] := &("mv_par"+StrZero(ni,2)) //Padrão
			ELSE
				aSav651[ni] := aParams[nPos,2] //ExecAuto
			ENDIF
		ENDIF
	Next ni

	Private aSav650     := Array(20)
	Pergunte("MTA650",.F.)
	For ni := 1 to 20
		aSav650[ni] := &("mv_par"+StrZero(ni,2))
	Next ni
	Private aRotina     := {}
	Private cFilA650    := ""
	Private lConsTerc   := .F.
	Private lEnd        := .F.
	Private lConsTerc   := !(aSav650[15] == 1)
	Private lConsNPT    := (aSav650[14] == 1)
	Private lProj711    := .F.
	Private lMata712    := .F.
	Private lPCPA107    := .F.
	Private lZrHeader   := .T.
	Private aAltSaldo   := {}
	Private lOpVendas   := .T.
	Private aDataOPC1   := {}
	Private aDataOPC7   := {}
	Private aOPC1       := {}
	Private aOPC7       := {}
	Private aOPC7Local  := {}
	Private aOPOpc      := {}
	Private aLotesUsado := {}
	Private aPedAut     := {}

EndIf

aOPOpc := {}

If lRet
	aOPC1      :={}
	aOPC7      :={}
	aOPC7Local := {}
	aDataOPC1  :={}
	aDataOPC7  :={}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ mv_par01 - 1 = Mostra pedidos c/Op    2 = Nao Mostra ped c/Op³
	//³ mv_par02 - Prod. Sem Estrut. Gera: OP, SC, Nenhum            ³
	//³ mv_par03 - Cliente de                                        ³
	//³ mv_par04 - Cliente ate                                       ³
	//³ mv_par05 - Produto de                                        ³
	//³ mv_par06 - Produto ate                                       ³
	//³ mv_par07 - data de entrega de                                ³
	//³ mv_par08 - data de entrega ate                               ³
	//³ mv_par09 - TES de                                            ³
	//³ mv_par10 - TES ate                                           ³
	//³ mv_par11 - Considera Local Padr„o (1-Sim 2-N„o)              ³
	//³            (para alimentar o campo C2_LOCAL)                 ³
	//³ mv_par12 - Libera Bloqueio de Credito (1-Sim 2-Nao)          ³
	//³ mv_par13 - N£mero inicial da Op                              ³
	//³ mv_par14 - Pedido de                                         ³
	//³ mv_par15 - Pedido ate                                        ³
	//³ mv_par16 - Almoxarifado De                                   ³
	//³ mv_par17 - Almoxarifado Ate                                  ³
	//³ mv_par18 - Avalia PVs - 1 - Individualmente - 2 - Agrupados  ³
	//³ mv_par19 - Qtd a Gerar OP - 1 - LE PADRAO - 2 - SEM LE       ³
	//³                           - 3 - LES SOMADOS                  ³
	//³ mv_par20 - Sim - Exibe apenas pedidos liberados por credito  ³
	//³          no faturamento                                      ³
	//³ mv_par21 - Cons.Saldos de Armazens ?(Considera Filtros de    ³
	//³          armazens para compor saldos,usado somente se o      ³
	//³          parametro mv_par11 estiver com conteudo 2-Nao)      ³
	//³ mv_par22 - Permite selecionar pedidos de vendas que possuem  ³
	//³          faturamento parcial e que não possuam Ops ja aponta-³
	//³          das. Este parametro so é considerado se o parametro ³
	//³          "Mostra apenas PV liber. cred" estiver com o conteu-³
	//³          do igual a "Nao".                                   ³
	//³ mv_par23 - Avalia/Prioriza pedidos de vendas por ordem de    ³
	//³          data de entrega ou pelo numero do PV na geracao das ³
	//³          Ops.                                                ³
	//³ mv_par24 - Considera Estoque de Seguranca na geracao das     ³
	//³          (Ordens de Producoes/Solicitacoes de Compras) dos   ³
	//³          produtos existentes nos Pedidos de Vendas? (Sim/Nao)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If l651Auto .Or. Pergunte("MTA651",.T.)
		cOP := "04/07/"+Space(Len(SC6->C6_OP))
		//Salvar variaveis existentes
		If !l651Auto
			For ni := 1 to 26
				aSav651[ni] := &("mv_par"+StrZero(ni,2))
			Next ni

			Pergunte("MTA650",.F.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Execblock a ser executado antes da Indregua                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ExistTemplate('MA650FIL'))
			cFilA650 := ExecTemplate('MA650FIL',.F.,.F.)
		EndIf

		If (ExistBlock('MA650FIL'))
			cFilA650 := ExecBlock('MA650FIL',.F.,.F.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Indice condicional para nao mostrar pedidos               ³
		//³ que ja geraram Op. ou nao liberados por credito no faturamento ³
		//³ Escolha feita na pergunte                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		cCondicao := ''

		//se MV_CONSEST ativo, filtra pedidos com liberacao de estoque total
		//ira mostrar apenas pedidos cuja quantidade liberada (C6_QTDEMP) seja menor que a quantidade total (C6_QTDVEN)
		If lConsEst
			If lAtuSGJ
				cCondicao += '( C6_QTDVEN >= A650QLibPV() ) .And. '
			Else
				cCondicao += '(!(C6_QTDEMP==C6_QTDVEN.And.(C6_OP$"08/05  ")).Or.(C6_QTDEMP==0)).And.'
			Endif
		EndIf

		If aSav651[1] == 2
			cCondicao += 'C6_OP # "05" .And. Empty(C6_NUMOP).And.'
			cCondicao += 'Empty(C6_NUMSC) .And.'
		EndIf

		If aSav651[20] == 1
			If lConsEst
				cCondicao += 'C6_OP$"07/01".And.' //01 para exibir pedidos com OP caso aSav651[1] == 1
			Else
				cCondicao += '(C6_QTDEMP>0).And.(C6_OP$"07/01/  ").And.'// C6_QTDEMP para garantir que esteja liberado quando C6_OP branco
			Endif
		EndIf

		If aSav651[22] = 2
			cCondicao +='C6_QTDENT==0.And.'
		EndIf

		cCondicao += 'C6_CLI>="'+aSav651[3]+'".And.C6_CLI<="'+aSav651[4]+'".And.'
		cCondicao += 'C6_PRODUTO>="'+aSav651[5]+'".And.C6_PRODUTO<="'+aSav651[6]+'".And.'
		cCondicao += 'C6_TES>="'+aSav651[9]+'".And.C6_TES<="'+aSav651[10]+'".And.'
		cCondicao += 'Dtos(C6_ENTREG)>="'+Dtos(aSav651[7])+'".And.'
		cCondicao += 'Dtos(C6_ENTREG)<="'+Dtos(aSav651[8])+'".And.'
		cCondicao += 'C6_QTDVEN>C6_QTDENT .And. C6_NUM>="'+aSav651[14]+'" .And. C6_NUM<="'+aSav651[15]+'" .And. '
		cCondicao += 'C6_BLQ<>"R' +Space(TamSx3("C6_BLQ")[1]-1) +'".And.'
		cCondicao += 'C6_LOCAL>="'+aSav651[16]+'".And.C6_LOCAL<="'+aSav651[17]+'"'
		If !Empty(cFIlA650)
			cCondicao := '(' +cCondicao+ ').and.(' +cFilA650+ ')'
		EndIf

		If lAtuSGJ	//Reavaliacao do Pedido de Venda, quando houver OP vinculada
			A650ReavPV()
		Endif

		If !l651Auto
            //condicoes para legenda vermelha: PV com OP/SC ja gerada, bloqueio (C6_BLQ) ou C6_OP diferente de 07 ou branco
            cCondMark += "(C6_NUMOP+C6_NUMSC+If(Empty(C6_BLQ).Or.AllTrim(C6_BLQ)=='N','',C6_BLQ)+If(C6_OP$'07/02  ',' ','X'))"


            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ P.E. Utilizado para adicionar condicao do usuario para a  ³
            //³ a legenda vermelha, sem interferir, apenas adicionar, na  ³
            //³ condicao padrao da legenda vermelha (bloqueio).           ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If ExistBlock('A650LGVEN')
                cCondMrkPE := ExecBlock('A650LGVEN',.F.,.F.)
                If ValType(cCondMrkPE) == "C" .And. !Empty(cCondMrkPE)
                    cCondMark += "+"+cCondMrkPE
                EndIf
            EndIf

            aLegAut := {}
            aadd(aLegAut,{"ENABLE",STR0149}) 	// "Liberado para Geração OP/SC"
            aadd(aLegAut,{"DISABLE",STR0150})   // "OP/SC ja Gerada ou Bloqueado para gerar"
		EndIf

		dbSelectArea("SC6")
		dbSetOrder(1)

		If aSav651[12] == 1				// Liberando Bloqueio de Credito
			A650LibCred(cCondicao)
		EndIf

		dbGotop()
		If !l651Auto
			If Bof() .and. Eof()
				Help(" ",1,"RECNO")
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Endereca a funcao de BROWSE                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				cMarca := GetMark()

				lLegenda := IsEmpty(cCondMark)

				oMarkBrw := FWMarkBrowse():New()
				oMarkBrw:SetAlias("SC6")
				oMarkBrw:SetFieldMark("C6_OK")
				oMarkBrw:SetMark(cMarca)
				oMarkBrw:SetTopFun('xFilial("SC6")')
				oMarkBrw:SetBotFun('xFilial("SC6")')
				oMarkBrw:SetWalkThru(.F.)
				oMarkBrw:SetFilterDefault(cCondicao)
				oMarkBrw:oBrowse:SetUseCaseFilter(.F.)
				oMarkBrw:SetUseFilter(.T.)
				oMarkBrw:SetTemporary(.F.)
				oMarkBrw:SetAmbiente(.T.)
				oMarkBrw:oBrowse:SetMainProc("MATA650C")
				oMarkBrw:SetDescription(STR0014)
				oMarkBrw:SetValid({ |oMarkBrw| F650TemQip(cCondMark,oMarkBrw) } )		
				oMarkBrw:SetAllMark({ || A650AllMark(cMarca,cCondMark)} )
				oMarkBrw:AddLegend({ || AllTrim(&cCondMark) == "" }, "GREEN", OemToAnsi(STR0149)) // "Liberado para Geração OP/SC"
				oMarkBrw:AddLegend({ || AllTrim(&cCondMark) != "" }, "RED", OemToAnsi(STR0150)) // "OP/SC ja Gerada ou Bloqueado para gerar"
				oMarkBrw:Activate()

				//MarkBrow("SC6","C6_OK",cCondMark,,,cMarca,'A650AllMark("'+cMarca+'","'+cCondMark+'")',,'xFilial("SC6")','xFilial("SC6")',,,,,,,,cCondicao)
			EndIf
		Else
			A650PedAut(cCondicao)
			A650ProcOP("SC6",,,,.T.)
		EndIf

		Inclui := .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera SC's aglutinadas por OP.                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aSav650[6] == 2
			aDatasNec := {}
			For nz:=1 to Len(aOPC1)

				aQtdes := CalcLote(aOPC1[nz,1],aOPC1[nz,7],"C")
				nQuant := 0
				aEval(aQtdes,{|x| nQuant+=x})

				aFornecedor:= COMPESQFOR(aOPC1[nz,1]) //-- Retorna codigo e loja do fornecedor
				nPrc:= COMPESQPRECO(aOPC1[nz,1],cFilAnt,aFornecedor[1],aFornecedor[2])
				aCampos := {}
				Aadd(aDatasNec,aOPC1[nz,4])
				aadd(aCampos,{"DATPRF",aOPC1[nz,4]})
				aadd(aCampos,{"TPOP",aOPC1[nz,11]})
				If Type('lProj711') == "L" .And. lProj711
					aadd(aCampos,{"SEQMRP",c711NumMRP})
				EndIf

				If aOPC1[nz,7] == nQuant
					aadd(aCampos,{"OP",aOPC1[nz,3]})
					Aadd(aDocs,{aOPC1[nz,1],nQuant,cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{},aOPC1[nz,3],"",aCampos})
				Else
					Aadd(aDocs,{aOPC1[nz,1],nQuant,cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{}," ","",aCampos})
				EndIf

			Next nz
			For nz:=1 to Len(aOPC7)

				aQtdes := CalcLote(aOPC7[nz,1],aOPC7[nz,7],"C")
				nQuant := 0
				aEval(aQtdes,{|x| nQuant+=x})

				aFornecedor:= COMPESQFOR(aOPC7[nz,1]) //-- Retorna codigo e loja do fornecedor
				nPrc:= COMPESQPRECO(aOPC7[nz,1],cFilAnt,aFornecedor[1],aFornecedor[2])
				aCampos := {}
				Aadd(aDatasNec,aOPC7[nz,4])
				aadd(aCampos,{"DATPRF",aOPC7[nz,4]})
				aadd(aCampos,{"TPOP",aOPC7[nz,6]})
				If Type('lProj711') == "L" .And. lProj711
					aadd(aCampos,{"SEQMRP",c711NumMRP})
				EndIf

				If aOPC7[nz,7] == nQuant
					aadd(aCampos,{"OP",aOPC7[nz,3]})
					Aadd(aDocs,{aOPC7[nz,1],nQuant,cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{},aOPC7[nz,3],"",aCampos})
				Else
					Aadd(aDocs,{aOPC7[nz,1],nQuant,cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{}," ","",aCampos})
				EndIf

			Next nz
			If !Empty(aDocs)
				aResultados:= ComGeraDoc(aDocs,.T.,.F.,.T.,.F.,ComDtNeces(aDatasNec),"MATA650" ,/*lEnviaEmail*/,1  )
				If ExistBlock("MT650C1")
					For nLoop := 1 To Len( aResultados )
						Do Case
							//--Tipo de documento gerado pela biblioteca de compras
							Case aResultados[nLoop,1,3] == "1" //-- Solicitação de Compras
								SC1->(dbSetOrder(1)) //-- C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
								If SC1->(dbSeek(aResultados[nLoop,1,1]+aResultados[nLoop,1,2]))
									Execblock("MT650C1",.F.,.F.,{"SC1",SC1->C1_NUM,SC1->C1_ITEM,SC1->(Recno())})
								EndIf
						EndCase
					Next nLoop
				EndIf
			EndIf

		ElseIf aSav650[6] == 3
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera SC's aglutinadas por data de Necessidade.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aDatasNec := {}
			For nz:=1 to Len(aDataOPC1)
				aFornecedor:= COMPESQFOR(aDataOPC1[nz,1]) //-- Retorna codigo e loja do fornecedor
				nPrc:= COMPESQPRECO(aDataOPC1[nz,1],cFilAnt,aFornecedor[1],aFornecedor[2])
				aCampos := {}
				If aDataOPC1[nz,2] == aDataOPC1[nz,7]
					aadd(aCampos,{"OP",aDataOPC1[nz,3]})
				EndIf
				aadd(aCampos,{"DATPRF",aDataOPC1[nz,4]})
				aadd(aCampos,{"TPOP",aDataOPC1[nz,11]})
				If Type('lProj711') == "L" .And. lProj711
					aadd(aCampos,{"SEQMRP",c711NumMRP})
				EndIf
				Aadd(aDocs,{aDataOPC1[nz,1],aDataOPC1[nz,2],cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{},"","",aCampos})
				Aadd(aDatasNec,aDataOPC1[nz,4])
			Next nz
			For nz:=1 to Len(aDataOPC7)
				aFornecedor:= COMPESQFOR(aDataOPC7[nz,1]) //-- Retorna codigo e loja do fornecedor
				nPrc:= COMPESQPRECO(aDataOPC7[nz,1],cFilAnt,aFornecedor[1],aFornecedor[2])
				aCampos := {}
				If aDataOPC7[nz,2] == aDataOPC7[nz,7]
					aadd(aCampos,{"OP",aDataOPC7[nz,3]})
				EndIf
				aadd(aCampos,{"DATPRF",aDataOPC7[nz,4]})
				aadd(aCampos,{"TPOP",aDataOPC7[nz,6]})
				If Type('lProj711') == "L" .And. lProj711
					aadd(aCampos,{"SEQMRP",c711NumMRP})
				EndIf
				Aadd(aDocs,{aDataOPC7[nz,1],aDataOPC7[nz,2],cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{},"","",aCampos})
				Aadd(aDatasNec,aDataOPC7[nz,4])
			Next nz
			If !Empty(aDocs)
				aResultados:= ComGeraDoc(aDocs,.T.,.F.,.T.,.F.,ComDtNeces(aDatasNec),"MATA650"  ,/*lEnviaEmail*/,1  )
				If ExistBlock("MT650C1")
					For nLoop := 1 To Len( aResultados )
						Do Case
							//--Tipo de documento gerado pela biblioteca de compras
							Case aResultados[nLoop,1,3] == "1" //-- Solicitação de Compras
								SC1->(dbSetOrder(1)) //-- C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
								If SC1->(dbSeek(aResultados[nLoop,1,1]+aResultados[nLoop,1,2]))
									Execblock("MT650C1",.F.,.F.,{"SC1",SC1->C1_NUM,SC1->C1_ITEM,SC1->(Recno())})
								EndIf
						EndCase
					Next nLoop
				EndIf
			EndIf
		EndIf
	EndIf

	If !l651Auto
        Pergunte("MTA650",.F.)

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Restaura a integridade da janela                             ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        Inclui := .F.

        dbSelectArea(cAlias)
        dbGoTo(nReg)
    EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³13/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aRotAdic
Private aRotina := {{STR0001, "PesqBrw"  , 0 , 1},;	         //"Pesquisar"
					{STR0009, "A650ProcOP", 0 , 4},;	     //"Gera O.P."
					{STR0010, "A650Visual", 0 , 0},;	     //"Visualiza"
					{STR0011, "A650Credit", 0 , 0},;	     //"Avalia Cr‚dito"
					{STR0064, "A650LegAut", 0 , 1, 0 , .F.}} //"Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Utilizado para adicionar botoes ao Menu da opcao Vendas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("A650VMNU")
    aRotAdic := ExecBlock("A650VMNU",.F.,.F.)
    If ValType(aRotAdic) == "A"
        AEval(aRotAdic,{|x| AAdd(aRotina,x)})
    EndIf
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A650ReavPV ³ Autor ³ Sergio S. Fuzinaka   ³ Data ³ 20.04.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Reavaliacao do Pedido de Venda, quando houver OP vinculada. ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A650ReavPV()

Local aArea		:= GetArea()
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local cFiltro	:= ""
Local lConsEst	:= (SuperGetMV("MV_CONSEST") == "S")

If lConsEst
	cFiltro += '( C6_QTDVEN >= A650QLibPV() ) .And. '
EndIf

cFiltro += 'C6_PVCOMOP == "S" .And. C6_OP == "05" .And. Empty(C6_NUMOP) .And. '

If aSav651[1] == 2
	cFiltro += 'Empty(C6_NUMSC) .And. '
EndIf

If aSav651[20] == 1
	If lConsEst
		cFiltro += 'C6_OP$"07/01" .And. ' //01 para exibir pedidos com OP caso aSav651[1] == 1
	Else
		cFiltro += '(C6_QTDEMP>0) .And. (C6_OP$"07/01/  ") .And. '// C6_QTDEMP para garantir que esteja liberado quando C6_OP branco
	Endif
EndIf

If aSav651[22] = 2
	cFiltro +='C6_QTDENT == 0 .And. '
EndIf

cFiltro += 'C6_CLI>="'+aSav651[3]+'".And.C6_CLI<="'+aSav651[4]+'".And.'
cFiltro += 'C6_PRODUTO>="'+aSav651[5]+'".And.C6_PRODUTO<="'+aSav651[6]+'".And.'
cFiltro += 'C6_TES>="'+aSav651[9]+'".And.C6_TES<="'+aSav651[10]+'".And.'
cFiltro += 'Dtos(C6_ENTREG)>="'+Dtos(aSav651[7])+'".And.'
cFiltro += 'Dtos(C6_ENTREG)<="'+Dtos(aSav651[8])+'".And.'
cFiltro += '(C6_QTDVEN-C6_QTDENT)>0.And.C6_NUM>="'+aSav651[14]+'".And.C6_NUM<="'+aSav651[15]+'".And.'
cFiltro += 'C6_BLQ<>"R' +Space(TamSx3("C6_BLQ")[1]-1) +'".And.'
cFiltro += 'C6_LOCAL>="'+aSav651[16]+'".And.C6_LOCAL<="'+aSav651[17]+'"'

If !Empty(cFIlA650)
	cFiltro := '(' +cFiltro+ ').and.(' +cFilA650+ ')'
EndIf

dbSelectArea("SC6")
dbSetOrder(1)
dbSetFilter({||&cFiltro},cFiltro)
dbGoTop()
While !Eof()
	If SC6->C6_TPOP != "P" .AND. (SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) > ( A650SomaSGJ("1") + A650SldStok() ));
		.OR. (aSav651[11] == 2 .and. aSav651[21] == 2 ) 

		A650DelSGJ("E")	//Estorna o SGJ

		DbSelectArea("SB2")	
		SB2->(DbSetOrder(1))
		If SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL))
			A650AtEmpn(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE),"-",SC6->C6_TPOP)//atualiza a SB2
		EndIf		

		RecLock("SC6",.F.)
		Replace C6_OP 		With CriaVar("C6_OP")		
		Replace C6_PVCOMOP	With CriaVar("C6_PVCOMOP")	
		MsUnlock()

	Endif
	dbSelectArea("SC6")
	dbSkip()
Enddo
dbClearFilter()

SB2->(DbCloseArea())

RestArea( aAreaSC6 )
RestArea( aAreaSB2 )
RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A650SldStok³ Autor ³ Sergio S. Fuzinaka   ³ Data ³ 20.04.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Saldo em Estoque do Produto                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A650SldStok()
Local aArea		:= GetArea()
Local aAreaSB2	:= SB2->(GetArea())
Local nSaldo	:= 0
Local nQtdPrj	:= 0
Local lEmpPrj   := SuperGetMV("MV_EMPPRJ",.F.,.T.)

DbSelectArea("SB2")
SB2->(dbSetOrder(1))
If SB2->(dbSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL)))
	If !lEmpPrj
		nQtdPrj := SB2->B2_QEMPPRJ
	EndIf	
	nSaldo := SaldoSB2(.T.,,,lConsTerc,lConsNPT,,,nQtdPrj)+SB2->B2_SALPEDI-SB2->B2_QEMPN+AvalQtdPre("SB2",2)
	nSaldo += A650Prev(SB2->B2_COD)
Endif

SB2->(DbCloseArea())

RestArea( aAreaSB2 )
RestArea( aArea )

Return( nSaldo )


Function A650PedAut(cCondicao)
Local aArea		:= GetArea()
Local aAreaSC6	:= SC6->(GetArea())
dbSelectArea("SC6")
dbSetOrder(1)
dbSetFilter({||&cCondicao},cCondicao)
dbGoTop()
While !Eof()
	aAdd(aPedAut,SC6->(Recno()))
	dbSkip()
Enddo
dbClearFilter()
RestArea( aAreaSC6 )
RestArea( aArea )
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A650ProcOP  ³ Autor ³ Rodrigo de A. Sartorio³Data  ³29/12/95³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera OPs atraves dos PVs                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A650ProcOP(cAlias,cCampo,nOpcE,cMarca,lInverte)

Local lRet       := .T.

Private nMetricOP := 0

lRet := fC5IsBlock() //Verifica se o pedido de venda esta em edição e não permite a geração da Op por vendas.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. executado antes da geracao das OP's    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. ExistBlock("MTA650POK")
	lRet := ExecBlock("MTA650POK",.F.,.F.,{cAlias,cMarca})
EndIf

If lRet
	If Type('lOpVendas') == "L"
		lOpVendas := .T.
	EndIf
	If !l651Auto
		Processa({|lEnd| A650GeraOP(@lEnd,cAlias,cCampo,nOpcE,cMarca,lInverte)},STR0012,OemToAnsi(STR0013),.F.) //"Gera‡„o de OPs"###"Gerando OPs..."
		CloseBrowse()
	Else
		A650GeraOP(@lEnd,cAlias,cCampo,nOpcE,cMarca,lInverte)
	EndIf

	If nMetricOP > 0
		//ID de métricas - OP por Vendas
		If Findfunction("PCPMETRIC")
			PCPMETRIC("MATA650C", {{"planejamento-e-controle-da-producao-protheus_qtd-op-geradas-por-pedido-manual_total", nMetricOP }})
		EndIf
	EndIf

Endif

If Type('lOpVendas') == "L"
	lOpVendas := .F.
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A650GeraOP³ Autor ³ Claudinei M. Benzi    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de geracao de OP's a partir de pedidos selecionados³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A650GeraOp(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Mata650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A650GeraOp(lEnd,cAlias,cCampo,nOpcE,cMarca,lInverte)
Local aDatasNec		:= {}
Local aDocs			:= {}
Local aFornecedor	:= {}
Local aMRPxJson		:= {}
Local aOPInt		:= {} //Vetor para armazenar as OP's intermediarias
Local aPedidos		:= {}
Local aPedOP   		:= {}
Local aPedOP1  		:= {}
Local aPedSC1  		:= {}
Local aQtdeSB2 		:= {}
Local aResultados	:= {}
Local cArqNtx2  	:= CriaTrab(NIL,.F.)
Local cFilSB1   	:= xFilial("SB1")
Local cFilSC6   	:= xFilial("SC6")
Local cNumOPAtu 	:= aSav651[13]
Local cNumPVAnt 	:= ""
Local cPvComOP  	:= CriaVar("C6_PVCOMOP")
Local lAtuSGJ   	:= SuperGetMV("MV_PVCOMOP",.F.,.F.)
Local lBLOESP   	:= If(SuperGetMV("MV_QBLOESP",.F.,"2") == "2",.F.,.T.)//Devido a integracao do PCP com o QIP, bloqueia se nao tiver Especifacao. 1 = Sim/ 2 =Nao
Local lConsEst  	:= (SuperGetMV("MV_CONSEST") == "S")
Local lDelTBMRP 	:= _lNewMRP == NIL
Local lIntNewMRP	:= Iif(_lNewMRP  == Nil, FindFunction("Ma650MrpOn") .AND. Ma650MrpOn(@_lNewMRP),_lNewMRP)
Local lIntQIPMAT	:= If(SuperGetMV("MV_QIPMAT",.F.,"N")=="N",.F.,.T.)//Integracao do QIP com Materiais
Local lMA650QTD 	:= ExistBlock("MA650QTD")
Local lMT650QIP 	:= If(ExistBlock("MT650QIP"),ExecBlock("MT650QIP",.F.,.F.),.T.)//ponto de entrada para validar ou nao a integracao com SIGAQIP
Local lNewOpc   	:= GetNewPar("MV_REPGOPC","N") == "S" // Indica se permite repeir o mesmo grupo de opcionais em varios niveis ou nao
Local lPEGrava  	:= ExistBlock('MA650GRPV')
Local lSomaNumOP	:= .T.
Local nCont     	:= 0
Local nIndex		:= 0
Local nPrc       	:= 0
Local nQtdAval		:= 0
Local nQuantItem 	:= 0
Local nReg			:= 0
Local nSeek      	:= 0
Local nx			:= 0
Local uRet       	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para controle da Grade                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nIncGrd  := 0
Private cNumOPAnt
Private cObs     := ""

aMRPxJson		:= Iif(lIntNewMRP, {{}, JsonObject():New()}, Nil) //{aDados para commit, JsonObject() com RECNOS} - Integracao Novo MRP - APONTAMENTOS
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna os indices e cria a 2a IndRegua.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC6")
RetIndex("SC6")
dbClearFilter()
If aSav651[18]==1
	If aSav651[23]==1
		cIndice:="C6_FILIAL+C6_NUM+C6_ITEM"
	Else
		cIndice:="C6_FILIAL+DTOS(C6_ENTREG)+C6_NUM+C6_ITEM"
	EndIf
ElseIf aSav651[18]==2
	If aSav651[23]==1
		cIndice:="C6_FILIAL+C6_PRODUTO+C6_OPC+C6_TPOP+C6_REVISAO+C6_NUM+C6_ITEM"
	Else
		cIndice:="C6_FILIAL+C6_PRODUTO+C6_OPC+C6_TPOP+C6_REVISAO+DTOS(C6_ENTREG)+C6_NUM+C6_ITEM"
	EndIf
EndIf
If !lInverte
	cCondicao += '.And.C6_OK == "'+SUBSTR(cMarca,1,Len(C6_OK))+'"'
EndIf
IndRegua("SC6",cArqNtx2,cIndice,,cCondicao,STR0061,If(l651Auto,.F.,.T.)) //"Selecionando Registros..."
nIndex:=RetIndex("SC6")
dbSetOrder(nIndex+1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha o cursor e o salva para poder movimenta'-lo          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
ProcRegua(LastRec(),21,5)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa leitura a partir da filial selecionada            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC2")
dbSetOrder(1)
dbSelectArea(cAlias)
dbSeek(cFilSC6)
While !Eof() .And. C6_FILIAL == cFilSC6    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Caso nao exista cria array que registra todos os niveis da estrutura     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("aRetorOpc") <> "A"
		aRetorOpc:={}
	EndIf
	If lNewOpc
		aRetorOpc:=STR2Array(SC6->C6_MOPC,.F.)
	EndIf
	cNumPVAnt := If(aSav651[18]==1,SC6->C6_NUM,SC6->C6_PRODUTO+SC6->C6_OPC+SC6->C6_TPOP+SC6->C6_REVISAO)
	dbSkip()
	nCont := 1

	While !Eof() .And. C6_FILIAL == cFilSC6
   		If !AvalTES(SC6->C6_TES, 'S')
   		 	(cAlias)->(dbSkip())
   		 	nCont += 1
   			Loop
   		Else
   			Exit
   		EndIf
 	End

	lSomaNumOP := !(cNumPVAnt==If(aSav651[18]==1,SC6->C6_NUM,SC6->C6_PRODUTO+SC6->C6_OPC+SC6->C6_TPOP+SC6->C6_REVISAO))	
	nReg := Recno()
	dbSkip(-nCont)
	Begin Transaction
		lSomaNumOP := AvalMarca(cAlias,cMarca,lInverte,@cNumOPAtu,@nQtdAval,@aPedidos,lPEGrava,nIncGrd, @aPedOP, @aPedOP1) .And. lSomaNumOP
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera OPs / SCs aglutinadas por produto e grava PVs            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSomaNumOp
			nIncGrd  :=  0  
			If aSav651[18]==2 .And. QtdComp(nQtdAval) > QtdComp(0) .And. Len(aPedidos) > 0
				SC6->(dbGoto(aPedidos[1,1]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Numeracao da OP                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumOP   := cNumOpAtu
				cItemOp  := "01"
				cSeqC2   := "000"
				cItemGrd := Space(Len(SC2->C2_ITEMGRD))
				cGrade   := Space(Len(SC2->C2_GRADE))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Avalia se o programa pode utilizar este n£mero de OP         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC2")
				If dbSeek(xFilial("SC2")+cNumOp+cItemOp)
					cNumOp:=GetNumSC2()
				EndIf
				If !(cNumOP==cNumOPAtu)
					cNumOPAtu := cNumOP
				EndIf
				cNumOPAnt := cNumOPAtu
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nao amarra a OP a um unico pedido para evitar erros de       ³
				//³ interpretacao do usuario                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cPedido := ""
				cItemPV := ""
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o produto.                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SB1")
				dbSetOrder(1)
				If SB1->B1_FILIAL+SB1->B1_COD != cFilSB1+SC6->C6_PRODUTO
					MsSeek(cFilSB1+SC6->C6_PRODUTO)
				EndIf
				cRoteiro:= SB1->B1_OPERPAD
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para manipular a quantidade total do item   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMA650QTD
					uRet := ExecBlock("MA650QTD",.F.,.F., { (nQtdAval) } )
					If ValType(uRet) == "N" // retorno eh numerico
						nQtdAval := uRet
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula a qtd a ter a OP ou SC gerada                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aSav651[19] == 1 .Or. aSav651[19] == 3
					aQtdes := CalcLote(SC6->C6_PRODUTO,nQtdAval,"F")
				ElseIf aSav651[19] == 2
					aQtdes := {nQtdAval}
				EndIf
				If aSav651[19] == 3
					nQtdBack:=0
					For nX := 1 To Len(aQtdes)
						nQtdBack+=aQtdes[nX]
					Next nX
					aQtdes := {nQtdBack}
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera as OPs ou SCs                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aPedidos[1,2] .Or. aSav651[2] == 1
					For nX := 1 To Len(aQtdes)
						cSeqC2:=Soma1(cSeqC2,Len(SC2->C2_SEQUEN))
						A650GeraC2(SC6->C6_PRODUTO,aQtdes[nX],,SC6->C6_ENTREG,,,,,IIf(aSav651[11]==1,.T.,.F.),.T.,SC6->C6_LOCAL,IIf(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),SC6->C6_TPOP,SC6->C6_REVISAO,NIL,cNumOp,cItemOp,cSeqC2,cRoteiro,cObs,SC6->C6_OPC,@aMRPxJson)
						AADD(aOPInt, {SC2->C2_PRODUTO, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD, (SC2->C2_QUANT - nQuantItem) } )
						MontEstru(SC6->C6_PRODUTO,aQtdes[nX],SC2->C2_DATPRI,,cSeqC2,SC2->C2_PRIOR,lConsEst,IIf(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),.F.,SC6->C6_TPOP,SC2->C2_REVISAO,SC6->C6_PRODUTO, @aOPInt,SC6->C6_PRODUTO)
						If ( __lSx8 )
							ConfirmSx8()
						EndIf
						Aadd(aQtdeSB2,{aQtdes[nX], .F., SC2->(Recno()),SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO})	
					Next nX
				ElseIf aSav651[2] == 2
					If ( __lSx8 )
						RollBackSx8()
					EndIf
					cNumOp  := ""
					cItemOp := ""
					cPedido := SC6->C6_NUM
					cItemPV := SC6->C6_ITEM
					//aFornecedor:= COMPESQFOR(SC6->C6_PRODUTO) //-- Retorna codigo e loja do fornecedor
					//nPrc:= COMPESQPRECO(SC6->C6_PRODUTO,cFilAnt,aFornecedor[1],aFornecedor[2])
					//Aadd(aDatasNec,SC6->C6_ENTREG)
					For nX := 1 to Len(aQtdes)
						//Aadd(aDocs,{SC6->C6_PRODUTO,aQtdes[nX],cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{},SC6->C6_NUMOP,""})
                     A650GeraC1(SC6->C6_PRODUTO,aQtdes[nX],Space(TamSX3("C1_OP")[1]),SC6->C6_ENTREG,,,0,SC6->C6_LOCAL,SC6->C6_TPOP,cPedido,cItemPv,aPedidos)
                     If (Ascan(aPedSC1, {|x| x[1]+x[2]+x[3]+x[4] == SC6->C6_PRODUTO+Iif(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC)+SC6->C6_TPOP+SC6->C6_REVISAO}))==0
                     	AADD(aPedSC1, {SC6->C6_PRODUTO,Iif(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),SC6->C6_TPOP,SC6->C6_REVISAO,SC1->C1_NUM,SC1->C1_ITEM})
                     EndIF
					Next
					//If !Empty(aDocs)
					//	aResultados:= ComGeraDoc(aDocs,.T.,.F.,.F.,.T.,ComDtNeces(aDatasNec),"MATA650"  ,/*lEnviaEmail*/,1  )
					//EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava as informacoes referentes as OPs nos PVs               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAtuSGJ .And. SC6->C6_PVCOMOP <> "S"
					cPvComOP := "S"		
				Endif

				For nx:=1 to Len(aPedidos)
					SC6->(dbGoto(aPedidos[nx,1]))
					Reclock("SC6",.F.)
					Replace C6_OP		With "01"
					Replace C6_NUMOP	With cNumOp
					Replace C6_ITEMOP	With cItemOP
					Replace C6_OK     	With ""
					Replace C6_PVCOMOP	With cPvComOP
					If Empty(SC6->C6_NUMSC)
						If (nSeek:=Ascan(aPedSC1, {|x| x[1]+x[2]+x[3]+x[4] == SC6->C6_PRODUTO+SC6->C6_OPC+SC6->C6_TPOP+SC6->C6_REVISAO})) > 0
							Replace C6_NUMSC  With aPedSC1[nSeek][5]
							Replace C6_ITEMSC With aPedSC1[nSeek][6]
						EndIf
					EndIf
					aPedidos[nx,3]:=cNumOp
					aPedidos[nx,4]:=cItemOP
					
					MsUnlock()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no arquivo de saldos.                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SB2")
					dbSetOrder(1)
					MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+IIF(aSav651[11]==1,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),SC6->C6_LOCAL))
					If !Found()
						CriaSB2(SC6->C6_PRODUTO,IIF(aSav651[11]==1,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),SC6->C6_LOCAL))
						MsUnLock()
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza saldos fisicos de empenho e pedidos de vendas.       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					A650AtEmpn(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - A650QLibPv(),"+",SC6->C6_TPOP)	

         			If lAtuSGJ
					 	If MAT650OPLE(cNumOp,cItemOP,SC6->C6_PRODUTO) //Verifica se a OP tem LE									
							M650ATUSGJ(aQtdeSB2,.T.)
						Else
							M650ATUSGJ({{SC2->C2_QUANT,.F.,SC2->(Recno()),SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO}},.T.)							
						EndIf
					Endif
					
					AADD(aPedOP,{cNumOp})
					AADD(aPedOP1,{cNumOp,cItemOP,cSeqC2})
					// Chama ponto de entrada para gravacao no SC6
					If lPEGrava
						ExecBlock('MA650GRPV',.F.,.F.,)
					EndIf
				Next nx
				nQtdAval:=0
				aPedidos:={}
			EndIf
		Else
			cNumOPAnt := cNumOPAtu
		EndIf
		cNumOPAtu := If(!Empty(aSav651[13]),If(lSomaNumOP,Soma1(cNumOPAtu,Len(cNumOPAtu)),cNumOPAtu),'')
	End Transaction	  
    dbSelectArea(cAlias)
	dbSetOrder(nIndex+1) 
	dbGoto(nReg)
	
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera OPs / SCs aglutinadas por produto e grava PVs            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	QtdComp(nQtdAval) > QtdComp(0) .And. Len(aPedidos) > 0
	nIncGrd  :=  0
	SC6->(dbGoto(aPedidos[1,1]))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Numeracao da OP                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNumOP   := cNumOpAtu
	cItemOp  := "01"
	cSeqC2   := "000"
	cItemGrd := Space(Len(SC2->C2_ITEMGRD))
	cGrade   := Space(Len(SC2->C2_GRADE))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avalia se o programa pode utilizar este n£mero de OP         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC2")
	If dbSeek(xFilial("SC2")+cNumOp+cItemOp)
		cNumOp:=GetNumSC2()
	EndIf
	If !(cNumOP==cNumOPAtu)
		cNumOPAtu := cNumOP
	EndIf
	cNumOPAnt := cNumOPAtu
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao amarra a OP a um unico pedido para evitar erros de       ³
	//³ interpretacao do usuario                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aSav651[2] == 2 .And. (SC6->C6_QTDEMP > 0)
		cPedido := SC6->C6_NUM
		cItemPV := SC6->C6_ITEM
	Else
		cPedido := ""
		cItemPV := ""
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o produto.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSetOrder(1)
	If SB1->B1_FILIAL+SB1->B1_COD != cFilSB1+SC6->C6_PRODUTO
		MsSeek(cFilSB1+SC6->C6_PRODUTO)
	EndIf
	cRoteiro:= SB1->B1_OPERPAD
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para manipular a quantidade total do item   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMA650QTD
		uRet := ExecBlock("MA650QTD",.F.,.F., { (nQtdAval) } )
		If ValType(uRet) == "N" // retorno eh numerico
			nQtdAval := uRet
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula a qtd a ter a OP ou SC gerada                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aSav651[19] == 1 .Or. aSav651[19] == 3
		aQtdes := CalcLote(SC6->C6_PRODUTO,nQtdAval,"F")
	ElseIf aSav651[19] == 2
		aQtdes := {nQtdAval}
	EndIf
	If aSav651[19] == 3
		nQtdBack:=0
		For nX := 1 To Len(aQtdes)
			nQtdBack+=aQtdes[nX]
		Next nX
		aQtdes := {nQtdBack}
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera as OPs ou SCs                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
		If aPedidos[1,2] .Or. aSav651[2] == 1
			For nX := 1 To Len(aQtdes)
				cSeqC2:=Soma1(cSeqC2,Len(SC2->C2_SEQUEN))
				A650GeraC2(SC6->C6_PRODUTO,aQtdes[nX],,SC6->C6_ENTREG,,,,,IIf(aSav651[11]==1,.T.,.F.),.T.,SC6->C6_LOCAL,IIf(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),SC6->C6_TPOP,SC6->C6_REVISAO,NIL,cNumOp,cItemOp,cSeqC2,cRoteiro,cObs,Nil,@aMRPxJson)
				AADD(aOPInt, {SC2->C2_PRODUTO, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD, (SC2->C2_QUANT - nQuantItem) } )
				MontEstru(SC6->C6_PRODUTO,aQtdes[nX],SC2->C2_DATPRI,,cSeqC2,SC2->C2_PRIOR,lConsEst,IIf(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),.F.,SC6->C6_TPOP,SC2->C2_REVISAO,SC6->C6_PRODUTO, @aOPInt, SC6->C6_PRODUTO)
				If ( __lSx8 )
					ConfirmSx8()
				EndIf
			Next nX
		ElseIf aSav651[2] == 2
			If ( __lSx8 )
				RollBackSx8()
			EndIf
			cNumOp  := ""
			cItemOp := ""
			//aFornecedor:= COMPESQFOR(SC6->C6_PRODUTO) //-- Retorna codigo e loja do fornecedor
			//nPrc:= COMPESQPRECO(SC6->C6_PRODUTO,cFilAnt,aFornecedor[1],aFornecedor[2])
			//Aadd(aDatasNec,SC6->C6_ENTREG)
			For nX := 1 to Len(aQtdes)
				//Aadd(aDocs,{SC6->C6_PRODUTO,aQtdes[nX],cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{},SC6->C6_NUMOP,""})
				A650GeraC1(SC6->C6_PRODUTO,aQtdes[nX],Space(TamSX3("C1_OP")[1]),SC6->C6_ENTREG,,,0,SC6->C6_LOCAL,SC6->C6_TPOP,cPedido,cItemPv)
			Next
			//If !Empty(aDocs)
			//	aResultados:= ComGeraDoc(aDocs,.T.,.F.,.F.,.T.,ComDtNeces(aDatasNec),"MATA650"  ,/*lEnviaEmail*/,1  )
			//EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava as informacoes referentes as OPs nos PVs               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtuSGJ .And. SC6->C6_PVCOMOP <> "S"
			cPvComOP := "S"
		Endif

		For nx:=1 to Len(aPedidos)
			SC6->(dbGoto(aPedidos[nx,1]))
			Reclock("SC6",.F.)
			Replace C6_OP 		With "01"
			Replace C6_NUMOP  	With cNumOp
			Replace C6_ITEMOP 	With cItemOP
			Replace C6_OK     	With ""
			Replace C6_PVCOMOP	With cPvComOP
			aPedidos[nx,3]:=cNumOp
			aPedidos[nx,4]:=cItemOP
			MsUnlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no arquivo de saldos.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SB2")
			dbSetOrder(1)
			MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+IIF(aSav651[11]==1,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),SC6->C6_LOCAL))
			If !Found()
				CriaSB2(SC6->C6_PRODUTO,IIF(aSav651[11]==1,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),SC6->C6_LOCAL))
				MsUnLock()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza saldos fisicos de empenho e pedidos de vendas.       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAtuSGJ .And. A650SomaSGJ("1") > 0
				A650AtEmpn(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - A650SomaSGJ("1"),"+",SC6->C6_TPOP)
			Else
				A650AtEmpn(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - A650QLibPv(),"+",SC6->C6_TPOP)
			Endif
		   	AADD(aPedOP,{cNumOp})
			AADD(aPedOP1,{cNumOp,cItemOP,cSeqC2})
			// Chama ponto de entrada para gravacao no SC6
			If lPEGrava
				ExecBlock('MA650GRPV',.F.,.F.,)
			EndIf
		Next nx
	End Transaction
	nQtdAval:=0
	aPedidos:={}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada MT650PV, apos a geração da OP's.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("MT650OPPV"))
	ExecBlock("MT650OPPV",.F.,.F.,{aPedOP,aPedOP1})
Endif

//Integração de ordens de produção com o novo MRP. Inclusão/Alteração de ordens
If lIntNewMRP
	enviaOpMrp("INSERT", @aMRPxJson, lDelTBMRP)
EndIf

If lIntQIPMAT //Define a integracao com o QIP
	If GetNewPar("MV_QPIMPPL",.F.,"S") == "S"
		If Type("l650Auto") # "L" .or. !l650Auto .or. !l651Auto
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a Impressao da Ficha de Produto  -  USO                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Pergunte("QPR041",.T.) .And. mv_par01 == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada para execucao do relatorio Customizado                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("QIPR041")
					ExecBlock("QIPR041",.F.,.F.,{"MATA650",SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN})
				Else
					QIPR040("MATA650",SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorna a pergunta Original                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Pergunte("MTA650",.F.)
		EndIf
	EndIf
EndIf

RETURN

/*/{Protheus.doc} M650ATUSGJ
	Logica para gravação da tabela SGJ
	@type  Static Function
	@author mauricio.joao
	@since 21/07/2021
	@version 1.0
	@param aQtdeSB2, array, quantidades geradas pela ordem de produção.
	@param lAgrupado, logical, geração do OP por Vendas de forma agrupada..
	@param lSemOp, logical, identifica se a geração é apenas de pedido, C6_OP = 05
/*/

Static Function M650ATUSGJ(aQtdeSB2,lAgrupado,lSemOp)
Local aAreaSC2 		:= SC2->(GetArea())
Local nQtdGer	 	:= 0 //variável para controlar a inclusão do sb2/sgj.
Local nQtdVen	 	:= 0 //variável para controlar a quantidade vendida

Default lAgrupado	:= .F.
DEfault lSemOp 		:= .F.

	//quantidade vendida total.
	nQtdVen := SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) 
	cProdPV := SC6->C6_PRODUTO

	If lSemOp
		A650AtuSGJ(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE), SC6->C6_TPOP)
		Return
	EndIf

	For nQtdGer := 1 to len(aQtdeSB2)
		//valida se já chegou no fim da geração
		If (nQtdVen <= 0)
			Exit
		EndIf
		//pula quando a posição já foi gerada
		If aQtdeSB2[nQtdGer,2] == .T. .or. cProdPV != aQtdeSB2[nQtdGer,6] 
			Loop
		Else
			SC2->(dbGoto(aQtdeSB2[nQtdGer,3]))
		EndIf
		
		//tratamento da quantidade.	
		If (aQtdeSB2[nQtdGer,1] < (nQtdVen))
			nQtdSB2 := aQtdeSB2[nQtdGer,1] 
		Else
			nQtdSB2 := nQtdVen
		EndIf				
		
		A650AtuSGJ(nQtdSB2, SC6->C6_TPOP)		
			
		//atualiza o array para não gerar novamente.
		If lAgrupado
			aQtdeSB2[nQtdGer,1] -= nQtdSB2
			If aQtdeSB2[nQtdGer,1] <= 0
				aQtdeSB2[nQtdGer,2] := .T.
			EndIf
		Else
			aQtdeSB2[nQtdGer,2] := .T. 			
		EndIf

		nQtdVen -= nQtdSB2
	
	Next nQtdGer

RestArea(aAreaSC2)
Return 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A650AllMark³ Autor ³ Marcos V. Ferreira  ³ Data ³ 21/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca todos os Registros da MarkBrowse()                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cMarca    = Caracter de Marcacao                            ³±±
±±³          ³cCondicao = Condicao de Filtragem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A650AllMark(cMarca,cCondicao)
Local aArea  := GetArea()
Local cAlias := Alias()

lAllMark := .T.
lAllHelp := .F.

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1))
(cAlias)->(dbGoTop())

While (cAlias)->(!Eof())

	If F650TemQip(cCondicao,oMarkBrw)
		oMarkBrw:Markrec()
	EndIf

	(cAlias)->(DbSkip())
End

//Se houver erro, mostrar a msg
If lAllHelp
	Help(" ",1,"C650NOREV")//"Nao existe especificação para esse Produto/Roteiro."					
EndIf

lAllMark := .F.

oMarkBrw:Refresh(.F.)
oMarkBrw:GoTop(.T.)

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AvalMarca³ Autor ³ Claudinei M. Benzi    ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Se o pedido estiver marcado ele gerara' a OP               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AvalMarca(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function AvalMarca(cAlias,cMarca,lInverte,cNumOPAtu,nQtdAval,aPedidos,lPEGrava,nInc,aPedOP,aPedOP1)
Static lBlockVld  := NIL
Local nToler,nQtdeTot,aQtdes:={},nX,nRegSB2,nQtdStok,nQtdBack,cOpMarca,nPosSC2
Local lConsEst := (SuperGetMV("MV_CONSEST") == "S")
Local cItem    :="00"
Local lExistBlkT   :=ExistTemplate("A650SALDO")
Local lExistBlock  :=ExistBlock("A650SALDO")
Local lA650SLDPV   :=ExistBlock("A650SLDPV")
Local lRetornoBlock:=.T.
Local lRet      :=.F.
Local lQuery    := .F.
Local bCond     := { || .T. }
Local cQuery	:= ""
Local cAliasSC9 := ""
Local nEstSeg   := 0
Local lEmpPrj   := SuperGetMV("MV_EMPPRJ",.F.,.T.)
Local nQtdPrj   := 0
Local nQtdPV    := 0
Local nQtdPVBk  := 0
Local lMA650QTD := ExistBlock("MA650QTD")
Local uRet      := Nil
Local lAtuSGJ	:= SuperGetMV("MV_PVCOMOP",.F.,.F.)
Local aOPInt    :={}
Local lQIPMAT := If(SuperGetMV("MV_QIPMAT",.F.,"N")=="N",.F.,.T.)//Integracao do QIP com Materiais
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto tem estrutura.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lFoundSG1:=SG1->(MsSeek(xFilial("SG1")+SC6->C6_PRODUTO))

Local lGrade    := SuperGetMV("MV_GRADE")
Local aAreaSC6  := SC6->(GetArea())
Local lExitGrad := .F.
Local nOpPed    := 0
Local nItPed    := 0
Local aFornecedor	:= {}
Local nPrc			:= 0
Local aDocs		:= {}
Local aResultados	:= {}
Local aDatasNec	:= {}
local aQtdeSB2 := {} //array para controlar a inclusão de sgj.
Local nRetQtLib := 0
Local cFilSC6 := xFilial("SC6")
Local cFilSB1 := ""
Local cFilSB2 := ""
Local cFilSC2 := ""

Local lDelTBMRP  := _lNewMRP == NIL
Local lIntNewMRP := Iif(_lNewMRP  == Nil, FindFunction("Ma650MrpOn") .AND. Ma650MrpOn(@_lNewMRP),_lNewMRP)
Local aMRPxJson  := Iif(lIntNewMRP, {{}, JsonObject():New()}, Nil) //{aDados para commit, JsonObject() com RECNOS} - Integracao Novo MRP - APONTAMENTOS

Static lQEmpNF	:= SuperGetMV("MV_QEMPNF",.F.,.F.)	//Considera o campo B2_QEMPN no calculo do Saldo

//Regra da SB2 - Deverá ser mantida aqui também.
If lAtuSGJ
	lQEmpNF	:= .F.
Endif

If lQIPMAT .and. !lFoundSG1 .and. (iif(len(aSav651) > 0,aSav651[02]==1,.F.))
	MsgAlert(STR0157+SC6->C6_PRODUTO)
Endif

Private cObs:=""

Default aPedOP1 := {}


lBlockVld  := If(ValType(lBlockVld)=="L",lBlockVld,ExistBlock("A650PRCPV"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para controle da grade                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nInc := If(nInc == NIL, 0, nInc)

If ((l651Auto .And. AsCan(aPedAut,{|x|x == SC6->(Recno())}) > 0) .Or. oMarkBrw:IsMark(cMarca)/*IsMark("C6_OK",ThisMark(),ThisInv())*/) .And. If(aSav651[2] == 3,lFoundSG1,.T.) .And. AvalTES(SC6->C6_TES, 'S')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se utiliza Ponto de Entrada valida item por item do PV       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lBlockVld
		lRetornoBlock:=ExecBlock("A650PRCPV",.F.,.F.)
		If ValType(lRetornoBlock) # "L"
			lRetornoBlock:=.T.
		EndIf
	EndIf
	If !lBlockVld .Or. (lBlockVld .And. lRetornoBlock)
		cFilSB1 := xFilial("SB1")
		cFilSB2 := xFilial("SB2")
		cFilSC2 := xFilial("SC2")
		lRet:=.T.
		cOpMarca := CriaVar("C1_OP")
		Private cSeqC2:="000",cNumOp:="",cItemOp:="",cLocal:="",cItemPV:="",cPedido:=""
		cPedido := SC6->C6_NUM
		cItemPV := SC6->C6_ITEM

		//Verificar se o parametro de grade está marcado e se não deve agrupar
		If lGrade .AND. aSav651[18]==1

			aAreaSC6  := SC6->(GetArea())

			SC6->(dbclosearea())

			//Verificar se algum produto do pedido possui grade
			lExitGrad := .F.
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbGotop()
			dbSeek(cFilSC6+cPedido)

			While !Eof() .AND. C6_FILIAL == cFilSC6 .AND. C6_NUM == cPedido
				If C6_GRADE = 'S'
					lExitGrad = .T.
					Exit
				EndIf
				dbSkip()
			EndDO

			SC6->(dbclosearea())

			If lExitGrad
			//Se algum produto possuir grade, verificar se já foi gerada alguma OP para esse pedido
			//Se existir uma OP para algum pedido deverá pegar a maior sequencia do item e acrescentar 1
				dbSelectArea("SC6")
				dbSetOrder(1)
				dbGotop()

				dbSeek(cFilSC6+cPedido)

				While !Eof() .AND. C6_FILIAL == cFilSC6 .AND. C6_NUM == cPedido
					If !Empty(C6_NUMOP)
						If Empty(nOpPed)
							nOpPed := C6_NUMOP
						EndIf

						If C6_NUMOP > nOpPed
							nOpPed := C6_NUMOP
						EndIf

						If Empty(nItPed)
							nItPed := C6_ITEMOP
						EndIf

						If C6_ITEMOP > nItPed
							nItPed := C6_ITEMOP
						EndIf
					EndIf

					dbSkip()
				EndDO

				SC6->(dbclosearea())

				If !Empty(nOpPed)
					cNumOp  := nOpPed
					cItemOp := Soma1(nItPed)

					nPosSC2 := Recno()

					dbSelectArea("SC2")

					lCont := .T.
					While lCont
						If dbSeek(cFilSC2+cNumOp+cItemOp)
				    		lCont := .T.
				    		cItemOp := Soma1(cItemOp)
				    	Else
				    		lCont := .F.
						EndIf
						dbSkip()
 					EndDO

					dbGoto(nPosSC2)

					dbSelectArea("SC6")
					dbSetOrder(1)
					dbGotop()
					RestArea(aAreaSC6)
				Else
					dbSelectArea("SC6")
					dbSetOrder(1)
					dbGotop()
					RestArea(aAreaSC6)
					cNumOp  := If(Empty(cNumOPAtu),SC6->C6_NUM,cNumOPAtu)
					cItemOp := SC6->C6_ITEM
				EndIf
			Else
				dbSelectArea("SC6")
				dbSetOrder(1)
				dbGotop()
				RestArea(aAreaSC6)

				cNumOp  := If(Empty(cNumOPAtu),SC6->C6_NUM,cNumOPAtu)
				cItemOp := SC6->C6_ITEM
			EndIf
		else
			cNumOp  := If(Empty(cNumOPAtu),SC6->C6_NUM,cNumOPAtu)
			cItemOp := SC6->C6_ITEM
		EndIF

		//cNumOp  := If(Empty(cNumOPAtu),SC6->C6_NUM,cNumOPAtu)
		//cItemOp := SC6->C6_ITEM
		cLocal  := SC6->C6_LOCAL
		cGrade  := SC6->C6_GRADE

		dbSelectArea("SC2")

		//cItemOp  := SC6->C6_ITEM
		cItemGrd := If(SC6->C6_GRADE == "S",StrZero( Val(SC6->C6_ITEMGRD), Len(SC2->C2_ITEMGRD)), Space(Len(SC2->C2_ITEMGRD)) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia se o programa pode utilizar este n£mero de OP         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosSC2 := Recno()

		If dbSeek(cFilSC2+cNumOp+cItemOp)
			If nInc == 0
				cNumOp:= GetNumSC2()
			ElseIf !EMPTY(SC6->C6_GRADE)
				cNumOp:= cNumOPAnt
			EndIf
		EndIf

		IF !EMPTY(cNumOPAtu)

			aAreaSC2 := SC2->(GetArea())
			cAliasSC2 := SC2->(GetNextAlias())
			cOpPed := ""
			cQuery    := " SELECT "
			cQuery    += " SC2.C2_PEDIDO PEDIDO,SC2.C2_ITEMPV ITEM "
			cQuery    += " FROM" + RetSqlName("SC2")+ " SC2 "
			cQuery	  += " WHERE SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
			cQuery    += "   AND SC2.C2_NUM = '"+cNumOPAtu+"' "
			cQuery	  += "   AND SC2.D_E_L_E_T_ <> '*' "
			cQuery    := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC2,.T.,.T.)
			While (cAliasSC2)->(!Eof())
				If (cAliasSC2)->PEDIDO == SC6->C6_NUM
					cOpPed := "S"
				EndIf
				If Empty(cOpPed)
					cOpPed := "N"
				EndIf
				(cAliasSC2)->(dbSkip())
			End
			(cAliasSC2)->(dbCloseArea())
			RestArea(aAreaSC2)

			If cOpPed == "N"
				If nInc == 0
					cNumOp:= GetNumSC2()
				ElseIf !EMPTY(SC6->C6_GRADE)
					cNumOp:= cNumOPAnt
				EndIF
				cNumOpAtu := cNumOP
			EndIf

			If !Empty(nOpPed) .And. !(cNumOP==cNumOPAtu)
				cNumOP := cNumOPAtu
			EndIf
		ELSE
			cNumOPAtu := cNumOP
		ENDIF

		If !EMPTY(SC6->C6_GRADE)
			nInc += 1
		EndIf

		nIncGrd := nInc

		dbGoto(nPosSC2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o produto.                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->B1_FILIAL+SB1->B1_COD != cFilSB1+SC6->C6_PRODUTO
			MsSeek(cFilSB1+SC6->C6_PRODUTO)
		Endif
		cRoteiro:=SB1->B1_OPERPAD

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|Quando C6_OP estiver igual a 05 (existia estoque na geracao anterior)|
		//|estorna quantidade ja alimentada no B2_QEMPN pois fara nova analise. |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(SC6->C6_OP) == "05"
			If !lAtuSGJ
				SB2->(dbSetOrder(1))
				SB2->(MsSeek(cFilSB2+SC6->(C6_PRODUTO+C6_LOCAL)))
				A650AtEmpn(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - A650QLibPv(),"+",SC6->C6_TPOP)
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no arquivo de saldos.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB2")
		dbSetOrder(1)
		MsSeek(cFilSB2+SC6->C6_PRODUTO+IIF(aSav651[11]==1,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),SC6->C6_LOCAL))
		If !Found()
			CriaSB2(SC6->C6_PRODUTO,IIF(aSav651[11]==1,RetFldProd(SB1->B1_COD,"B1_LOCPAD"),SC6->C6_LOCAL))
			MsUnLock()
		EndIf
		nRegSB2 := Recno()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe saldo em estoque.                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdStok := 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma o valor do pedido para corrigir ERRO.                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lConsEst
			If aSav651[11] == 2
				If aSav651[21] == 1
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso nao seja considerado o armazem padrao e seja utilizado o ³
					//³ filtro dos armazens para compor o saldo do Produto.           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SB2->(dbSeek(cFilSB2+SC6->C6_PRODUTO+aSav651[16],.T.))
					While SB2->(!Eof() .And. B2_FILIAL+B2_COD==cFilSB2+SC6->C6_PRODUTO .And. B2_LOCAL <= aSav651[17])
						If !lEmpPrj
							nQtdPrj := SB2->B2_QEMPPRJ
						EndIf
						//A validação do parâmetro lQEmpNF está correta sendo ao contrário.
						nQtdStok += SaldoSB2(.T., , ,lConsTerc,lConsNPT,,,nQtdPrj)+B2_SALPEDI/*-(Iif(!lQEmpNF,B2_QEMPN,0))*/+AvalQtdPre("SB2",2)
						nQtdStok += A650Prev(SB2->B2_COD)
						IF lQEmpNF
							nQtdStok += B2_QEMPN
						ELSE
							nQtdStok -= B2_QEMPN
						ENDIF

						If lAtuSGJ
							nQtdStok += A650SomaSGJ("1")	//Saldo Empenhado SEM OP
						Endif
						SB2->(DbSkip())
					EndDo
					SB2->(DbGoto(nRegSB2))
				EndIf
			Else
				If !lEmpPrj
					nQtdPrj := SB2->B2_QEMPPRJ
				EndIf
				//A validação do parâmetro lQEmpNF está correta sendo ao contrário.
				nQtdStok := SaldoSB2(.T., , ,lConsTerc,lConsNPT,,,nQtdPrj)+B2_SALPEDI/*-(Iif(lQEmpNF,B2_QEMPN,0))*/+AvalQtdPre("SB2",2)

				IF lQEmpNF
					nQtdStok += B2_QEMPN
				ELSE
					nQtdStok -= B2_QEMPN
				ENDIF

				nQtdStok += A650Prev(SB2->B2_COD)

				If lAtuSGJ
					nQtdStok += A650SomaSGJ("1")	//Saldo Empenhado SEM OP
				Endif

			EndIf

			// nQtdStok := Max(0,nQtdStok) -- Inibido, estava desconsiderando o estoque negativo.

			// Verifica saldo ja liberado e ainda nao faturado - DEVER SER SOMADO AO SALDO EM ESTOQUE DISPONIVEL
			If QtdComp(SB2->B2_RESERVA) > QtdComp(0)
				lQuery	  := .T.
				cAliasSC9 := "A650SC9"
				cQuery    := "SELECT "
				cQuery    += "Sum(SC9.C9_QTDLIB) QTDLIBER FROM "
				cQuery    += RetSqlName("SC9")+ " SC9 "
				cQuery	  += " WHERE "
				cQuery    += " SC9.C9_FILIAL = '" + xFilial("SC9") + "' AND "
				cQuery	  += " SC9.C9_PEDIDO = '"+SC6->C6_NUM+"' AND "
				cQuery	  += " SC9.C9_ITEM = '"+SC6->C6_ITEM+"' AND "
				cQuery	  += " SC9.C9_PRODUTO = '"+SC6->C6_PRODUTO+"' AND "
				cQuery	  += " SC9.C9_BLEST='"+Space(TamSx3("C9_BLEST")[1])+"' AND "
				cQuery	  += " SC9.C9_BLCRED='"+Space(TamSx3("C9_BLCRED")[1])+"' AND "
				cQuery	  += " SC9.C9_BLOQUEI='"+Space(TamSx3("C9_BLOQUEI")[1])+"' AND "
				cQuery	  += " SC9.C9_NFISCAL='"+Space(TamSx3("C9_NFISCAL")[1])+"' AND "
				cQuery    += " SC9.D_E_L_E_T_ <> '*' "
				cQuery    := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)

				If (cAliasSC9)->(!Eof())
					nQtdStok += (cAliasSC9)->QTDLIBER
				EndIf

				dbSelectArea(cAliasSC9)
				dbCloseArea()
				dbSelectArea(cAlias)
				If !lQuery
					SC9->(dbSetOrder(1))
					SC9->(dbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
					While !SC9->(Eof()) .And. xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM == SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM)
						// Avalia itens liberados em todos os pontos e ainda nao faturados
						If SC6->C6_PRODUTO == SC9->C9_PRODUTO .And. Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLOQUEI) .And. Empty(SC9->C9_NFISCAL)
							nQtdStok+=SC9->C9_QTDLIB
						EndIf
						SC9->(dbSkip())
					End
				EndIf
				// Avalia o Saldo do Controle de Reservas, somando ao Saldo em Estoque
				If !Empty(SC6->C6_RESERVA)
					SC0->(dbSetOrder(1))
					If SC0->(MsSeek(xFilial('SC0')+SC6->C6_RESERVA+SC6->C6_PRODUTO+SC6->C6_LOCAL))
						nQtdStok+= Min(SC0->C0_QTDPED, SC6->C6_QTDVEN - SC6->C6_QTDENT)
					EndIf
				EndIf
			EndIf

			// --- Verifica Estoque de Seguranca (B1_ESTSEG)
			If aSav651[24]==1
				nEstSeg := CalcEstSeg( RetFldProd(SB1->B1_COD,"B1_ESTFOR") )
				nQtdStok -= nEstSeg
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa P.E. para tratar saldo disponivel.                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExistBlkT
				nQtdBack:=nQtdStok
				nQtdStok:=ExecTemplate("A650SALDO",.F.,.F.,nQtdStok)
				If ValType(nQtdStok) != "N"
					nQtdStok:=nQtdBack
				EndIf
			EndIf

			If lExistBlock
				nQtdBack:=nQtdStok
				nQtdStok:=ExecBlock("A650SALDO",.F.,.F.,nQtdStok)
				If ValType(nQtdStok) != "N"
					nQtdStok:=nQtdBack
				EndIf
			EndIf

		EndIf

		If aSav651[25] == 1
			cAliasSC9 := "A650SC9"
			cQuery    := "SELECT "
			cQuery    += "Sum(SC9.C9_QTDLIB) QTDLIBER FROM "
			cQuery    += RetSqlName("SC9")+ " SC9 "
			cQuery	  += " WHERE "
			cQuery    += " SC9.C9_FILIAL = '" + xFilial("SC9") + "' AND "
			cQuery	  += " SC9.C9_PEDIDO = '"+SC6->C6_NUM+"' AND "
			cQuery	  += " SC9.C9_ITEM = '"+SC6->C6_ITEM+"' AND "
			cQuery	  += " SC9.C9_PRODUTO = '"+SC6->C6_PRODUTO+"' AND "
			//cQuery	  += " SC9.C9_BLEST='"+Space(TamSx3("C9_BLEST")[1])+"' AND "
			cQuery	  += " SC9.C9_BLCRED='"+Space(TamSx3("C9_BLCRED")[1])+"' AND "
			cQuery	  += " SC9.C9_BLOQUEI='"+Space(TamSx3("C9_BLOQUEI")[1])+"' AND "
			cQuery	  += " SC9.C9_NFISCAL='"+Space(TamSx3("C9_NFISCAL")[1])+"' AND "
			cQuery    += " SC9.D_E_L_E_T_ <> '*' "
			cQuery    := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)

			If (cAliasSC9)->(!Eof())
				nQtdPV := (cAliasSC9)->QTDLIBER
			Else
				nQtdPV := 0
			EndIf

			dbSelectArea(cAliasSC9)
			dbCloseArea()			
			dbSelectArea(cAlias)

			If nQtdPV == 0
				Return .F.
			EndIf

		Else
			nQtdPV := SC6->C6_QTDVEN-SC6->C6_QTDENT
		EndIf

		If lA650SLDPV
			nQtdPVBk:=nQtdPV
			nQtdPV:=ExecBlock("A650SLDPV",.F.,.F.,{nQtdPV})
			If ValType(nQtdPV) != "N"
				nQtdPV:=nQtdPVBk
			EndIf
		EndIf

		If aSav651[18] == 1 .Or. (aSav651[18] == 2 .And. QtdComp(nQtdAval) == QtdComp(0))
			If nQtdStok < 0
				nQtdeTot := ABS(nQtdStok)+(nQtdPV)
			Else
				nQtdeTot := If(nQtdStok >= (nQtdPV),0,(nQtdPV) - nQtdStok)
			EndIf
		ElseIf (aSav651[18] == 2 .And. QtdComp(nQtdAval) > QtdComp(0))
			nQtdeTot := (nQtdPV)
		EndIf
		nQtdAval+=nQtdeTot

		If aSav651[18] == 1 //Grava informacoes da OP caso processe individualmente cada PV
			If nQtdeTot > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada para manipular a quantidade total do item   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMA650QTD
					uRet := ExecBlock("MA650QTD",.F.,.F., { (nQtdeTot) } )
					If ValType(uRet) == "N" // retorno eh numerico
						nQtdeTot := uRet
					EndIf
				EndIf
				// Verifica a qtd a ter a OP gerada
				If aSav651[19] == 1 .Or. aSav651[19] == 3
					aQtdes := CalcLote(SC6->C6_PRODUTO,nQtdeTot,"F")
				ElseIf aSav651[19] == 2
					aQtdes := {nQtdeTot}
				EndIf
				If aSav651[19] == 3
					nQtdBack:=0
					For nX := 1 To Len(aQtdes)
						nQtdBack+=aQtdes[nX]
					Next nX
					aQtdes := {nQtdBack}
				EndIf
				If lFoundSG1 .Or. aSav651[2] == 1
					For nX := 1 To Len(aQtdes)
						cSeqC2:=Soma1(cSeqC2,Len(SC2->C2_SEQUEN))
						A650GeraC2(SC6->C6_PRODUTO,aQtdes[nX],,SC6->C6_ENTREG,,,,,IIf(aSav651[11]==1,.T.,.F.),.T.,SC6->C6_LOCAL,IIf(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),SC6->C6_TPOP,SC6->C6_REVISAO,NIL,cNumOp,cItemOp,cSeqC2,cRoteiro,cObs,SC6->C6_OPC,@aMRPxJson)
						AADD(aOPInt, {SC2->C2_PRODUTO, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD, (SC2->C2_QUANT - aQtdes[nX]) } )
						MontEstru(SC6->C6_PRODUTO,aQtdes[nX],SC2->C2_DATPRI,,cSeqC2,SC2->C2_PRIOR,lConsEst,IIf(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),.F.,SC6->C6_TPOP,SC2->C2_REVISAO,SC6->C6_PRODUTO, @aOPInt, SC6->C6_PRODUTO)
						Aadd(aQtdeSB2,{aQtdes[nX], .F., SC2->(Recno()),SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO})	
						If ( __lSx8 )
							ConfirmSx8()
						EndIf
					Next nX
				ElseIf aSav651[2] == 2
					If ( __lSx8 )
						RollBackSx8()
					EndIf
					cNumOp  := ""
					cItemOp := ""
					//aFornecedor:= COMPESQFOR(SC6->C6_PRODUTO) //-- Retorna codigo e loja do fornecedor
					//nPrc:= COMPESQPRECO(SC6->C6_PRODUTO,cFilAnt,aFornecedor[1],aFornecedor[2])
					//Aadd(aDatasNec,SC6->C6_ENTREG)
					For nX := 1 to Len(aQtdes)
						//Aadd(aDocs,{SC6->C6_PRODUTO,aQtdes[nX],cFilAnt,cFilAnt,"1",aFornecedor[1],aFornecedor[2],,nPrc,{},SC6->C6_NUMOP,""})
						A650GeraC1(SC6->C6_PRODUTO,aQtdes[nX],cOpMarca,SC6->C6_ENTREG,,,0,SC6->C6_LOCAL,SC6->C6_TPOP,cPedido,cItemPv)
					Next
					//If !Empty(aDocs)
					//	aResultados:= ComGeraDoc(aDocs,.T.,.F.,.F.,.T.,ComDtNeces(aDatasNec),"MATA650"  ,/*lEnviaEmail*/,1  )
					//EndIf
				Endif
			Else
				If ( __lSx8 )
					RollBackSx8()
				EndIf
			Endif
		
			//Persistencia SC6 X SC2
			MAT650CGRV(cPedido,cItemPv,nQtdeTot,cNumOp,cItemOP,nQtdPV,aSav651)				

			If nQtdeTot > 0
				AADD(aPedOP,{cNumOp})
				AADD(aPedOP1,{cNumOp,cItemOP,cSeqC2})
			EndIf

			//Alimenta B2_QEMPN
			dbSelectArea("SB2")
			dbGoto(nRegSB2)

			If lAtuSGJ
				M650ATUSGJ(aQtdeSB2,.F.,Iif(nQtdeTot > 0, .F., .T.))							
			EndIf
			
			If aSav651[25] == 1
				A650AtEmpn(nQtdPV,"+",SC6->C6_TPOP)
			Else
				A650AtEmpn(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - A650QLibPv(),"+",SC6->C6_TPOP)
			EndIf
		
			// Chama ponto de entrada para gravacao no SC6
			If lPEGrava
				ExecBlock('MA650GRPV',.F.,.F.)
			EndIf
			
		ElseIf aSav651[18] == 2 //Grava informacoes da OP caso processe aglutinado por produto
			If nQtdeTot > 0
				AADD(aPedidos,{SC6->(Recno()),lFoundSG1,"",""})
			Else
				If lAtuSGJ 
					M650ATUSGJ(aQtdeSB2,.T.,.T.)						
				EndIf

				Reclock("SC6",.F.)
					Replace C6_OP With "05"
				MsUnlock()			
				//atualiza o B2_QEMP
				A650AtEmpn(SC6->(C6_QTDVEN-C6_QTDENT-C6_QTDRESE) - A650QLibPv(),"+",SC6->C6_TPOP)	
			EndIf
		EndIf
	EndIf
EndIf

//Integração de ordens de produção com o novo MRP. Inclusão/Alteração de ordens
If lIntNewMRP
	enviaOpMrp("INSERT", @aMRPxJson, lDelTBMRP)
EndIf

IncProc()
dbSelectArea(cAlias)
Return lRet

/*/{Protheus.doc} MAT650CGRV
	Persistencia dos campos pedido de venda x ordem de produção	
	@type  Function
	@author mauricio.joao
	@since 08/10/2021
	@version 12.1.27
	@param cNumPv, char, Numero do pedido de vendas
	@param cItemPv, char, Item do pedido de vendas
	@param nQtdTot, numeric, Quantidade total
	@param cNumOp, char, Numero da ordem de produção
	@param cItemOP, char, Item da ordem de produção
	@param nQtdPv, numeric, Quantidade do pedido de venda
	@param aSav651, array, Array com os parametros do mata650.
	@return lGravou, logical, Confirmação da persistencia dos campos OP x PV.

/*/
Function MAT650CGRV(cNumPv,cItemPv,nQtdTot,cNumOp,cItemOP,nQtdPv,aSav651)
	Local aAreaSC6 	:= GetArea("SC6")
	Local cC6OP		:= CriaVar("C6_OP")
	Local cFiltro   := ""
	Local cPvComOP	:= CriaVar("C6_PVCOMOP")
	Local lAtuSGJ   := SuperGetMV("MV_PVCOMOP",.F.,.F.) 
	Local lGravou  	:= .T.

	Default cNumPv  := ''
	Default cItemPv := ''

	cFiltro := SC6->(dbFilter())

	//Posicionar o Pedido de Venda
	DbSelectArea("SC6")
	dbClearFilter()
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+cNumPv+cItemPv)) //C6_FILIAL + C6_NUM + C6_ITEM	
		//Regras
		If lAtuSGJ //.And. SC6->C6_PVCOMOP <> "S"
			cPvComOP := "S"
		Endif	

		If nQtdTot > 0
			cC6OP := "01"
		ElseIf (aSav651[25] == 1 .And. nQtdPv > 0) .Or. (aSav651[25] != 1)
			cC6OP := "05"
		EndIf

		If cC6OP $ "05" 
			cNumOp 	:= CriaVar("C6_NUMOP")
			cItemOP := CriaVar("C6_ITEMOP")			
		EndIf
		
		RecLock("SC6",.F.)	
		Replace C6_OP		With cC6OP
		Replace C6_NUMOP	With cNumOp
		Replace C6_ITEMOP	With cItemOP
		Replace C6_OK		With CriaVar("C6_OK")
		Replace C6_PVCOMOP	With cPvComOP
		MsUnlock()
	Else
		lGravou := .F.
	EndIf

	dbSetFilter({|| &cFiltro}, cFiltro)
	RestArea(aAreaSC6)
Return lGravou

/*/{Protheus.doc} MAT650CDEL
	Persistencia dos campos pedido de venda x ordem de produção	
	@type  Function
	@author mauricio.joao
	@since 08/10/2021
	@version 12.1.27
	@param nRecno, numeric, Recno da SC6 para alteração.
	@return lGravou, logical, Confirmação da presistencia da liberação dos campos de vinculo OP X PV.
/*/
Function MAT650CDEL(nRecno)
	Local aAreaSC6	:= GetArea("SC6")
	Local cC6OP		:= CriaVar("C6_OP")
	Local lGravou	:= .T.

	Default nRecno	:= 0

	If nRecno > 0
		//Posicionar o Pedido de Venda
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTo(nRecno))

		//Regras
		If SC6->C6_QTDEMP > 0 .And. !(SC6->C6_OP == "08")
			cC6OP := "07"
		ElseIf SC6->C6_QTDEMP > 0 .And. (SC6->C6_OP == "08")
			cC6OP := Space(2)
		Else
			cC6OP :=IIF(SC6->C6_OP=="01","  ","02")
		Endif	
	
		RecLock("SC6",.F.)	
		Replace C6_OP 		With cC6OP
		Replace C6_NUMOP  	With CriaVar("C6_NUMOP")
		Replace C6_ITEMOP 	With CriaVar("C6_ITEMOP")
		Replace C6_OK     	With CriaVar("C6_OK")	
		Replace C6_PVCOMOP	With CriaVar("C6_PVCOMOP")			
		MsUnlock()

		RestArea(aAreaSC6)
	Else
		lGravou := .F.
	EndIf
Return lGravou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A650LibCred³ Autor ³ Cristina Ogura        ³ Data ³ 03/07/97³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Libera os Pedidos de Vendas com credito bloqueado.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A650LibCred(cCondicao)

Local aAreaSc6  := GetArea('SC6')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao DbSetFilter                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SC6")
DbSetOrder(1)
DbSetFilter({|| &cCondicao}, cCondicao)

DbGotop()
While !Eof()

	If C6_OP == "04"

		RecLock("SC6",.F.)

			Replace C6_OP With "  "

		MsUnlock()

	EndIf

	DbSkip()

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao DbSetFilter e retorna os indices padroes.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbClearFilter()
RetIndex('SC6')

RestArea(aAreaSc6)

RETURN NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A650LegAut³Rev.   ³ Nilton M.K.           ³ Data ³29.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A650LegAut()
BrwLegenda(cCadastro,STR0064,aLegAut) //"Legenda"
Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A650Visual³ Autor ³ Claudinei M. Benzi    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de visualizacao de O.P.s                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void A650Visual(ExpC1,ExpN1,ExpN2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada no menu                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function A650Visual(cAlias)
Local GetList:={}, nReg:=Recno(), cNumOp, cItemOp, aOps:={}, nOpcC:=1
Local cCadastro := OemToAnsi(STR0014),oDlg,oQual	//"OP por Pedido de Venda"
Local cFilSC2 := xFilial("SC2")

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Estrutura do array de ordens de producao                             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  Seq Produto                Qtde
  99  X--------------X 9999999.99
  0        1         2         3
  1234567890123456789012345678901
*/

While .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  	//³ Verifica se esta' na filial correta                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If xFilial("SC6") != C6_FILIAL
		Help(" ",1,"A000FI")
		Exit
	EndIf

	If C6_OP $ "04#02#  "
		Help(" ",1,"A650NGOP")
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Arquivo de Ordens de Producao                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	dbGoTo(nReg)
	cNumOp :=IF(!Empty(SC6->C6_NUMOP),SC6->C6_NUMOP,SC6->C6_NUM)
	cItemOp:=IF(!Empty(SC6->C6_ITEMOP),SC6->C6_ITEMOP,SC6->C6_ITEM)

	dbSelectArea("SC2")
	dbSeek(cFilSC2+cNumOp+cItemOp)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega array (aOps) com as Ordens de Producao do pedido     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While !Eof() .And. C2_FILIAL+C2_NUM+C2_ITEM == (cFilSC2+cNumOp+cItemOp)
		If !Empty(C2_PEDIDO) .And. C2_PEDIDO # SC6->C6_NUM
			dbSkip()
			Loop
		EndIf
		If !Empty(C2_ITEMPV) .And. C2_ITEMPV # SC6->C6_ITEM
			dbSkip()
			Loop
		EndIf
		AADD(aOps,{C2_SEQUEN,C2_PRODUTO,Str(C2_QUANT,10,2)})
		dbSkip()
	EndDo

	If Empty(aOps)
		Help(" ",1,"A650NOP")
		Exit
	Else
		DEFINE MSDIALOG oDlg TITLE cCadastro From 09,0 To 20,50 OF oMainWnd
		@ 0.5,  0 TO 6, 20.0 OF oDlg
		@ 1,.7 Say OemToAnsi(STR0015)+cNumOP SIZE 110,7	//"N£mero da OP:  "
		@ 1,12 Say OemToAnsi(STR0016)+cItemOP SIZE 50,7 //"Item:  "
		@ 2,.7 LISTBOX oQual Fields HEADER OemToAnsi(STR0017),OemToAnsi(STR0018),OemToAnsi(STR0019) SIZE 150,42	//"Sequencia"###"Produto"###"Quantidade"
		oQual:SetArray(aOps)
		oQual:bLine := { || {aOps[oQual:nAT][1],aOps[oQual:nAT][2],aOps[oQual:nAT][3]}}
		DEFINE SBUTTON FROM 10  ,166  TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg
	EndIf
	Exit
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbGoTo(nReg)

Return .T.

/*/{Protheus.doc} enviaOpMrp
Envia os empenhos para o MRP

@type  Static Function
@author brunno.costa
@since 23/07/2019
@version P12.1.27
@param cOperac    , Character, Operação em execução (INSERT/DELETE)
@param aMRPxJson  , Array    , Array com os dados para enviar - APONTAMENTOS.
@param lDelTBMRP  , logico   , indica se deve excluir a tabela temporaria
@return Nil
/*/
Static Function enviaOpMrp(cOperac, aMRPxJson, lDelTBMRP)
	Local aAreaAtu   := GetArea()

	//Integra os dados com a API - APONTAMENTOS
	If _lNewMRP .and. aMRPxJson != Nil .and. Len(aMRPxJson[1]) > 0
		MATA650INT(cOperac, aMRPxJson[1])
		aSize(aMRPxJson[1], 0)
		FreeObj(aMRPxJson[2])
		aMRPxJson[2] := Nil
	EndIf

	//Inicializa variável de controle da integração com o novo mrp.
	If lDelTBMRP
		_lNewMRP := Nil
	EndIf

	RestArea(aAreaAtu)
Return Nil

/*/{Protheus.doc} fC5IsBlock
Verifica se o pedido de venda esta em edição e não permite a geração da Op por vendas.
@type  Static Function
@author rafael.kleestadt
@since 26/05/2021
@version 1.1
@param param_name, param_type, param_descr
@return lRet, logical, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fC5IsBlock()
local aAreas     := {SC5->(GetArea()), SC6->(GetArea())}
Local cNumPedido := ""
Local lRet       := .T.
Local nX         := 0

DbSelectArea("SC5")
SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
IF !l651Auto
	IF SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
		IF !SC5->(RLock()) //https://tdn.totvs.com/x/wAAqAg
			cNumPedido := ALLTRIM(SC6->C6_NUM)
		ENDIF
	ENDIF
	
ELSE
	For nX := 1 To Len(aPedAut)
		SC6->(DbGoTo(aPedAut[nX]))
		IF SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
			IF !SC5->(RLock()) //https://tdn.totvs.com/x/wAAqAg
				cNumPedido := ALLTRIM(SC6->C6_NUM)
				EXIT
			ENDIF
		ENDIF
	Next nX
ENDIF
SC5->(DbCloseArea())

IF !Empty(cNumPedido)
	lRet := .F.
	Help(NIL, NIL, STR0213, NIL, STR0214 + cNumPedido + STR0215, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0216})//"Registro Bloqueado"###"O Pedido de Vendas "###" esta bloqueado por outra rotina."###"Conclua as alterações pendentes para este pedido de vendas ou escolha outro registro."
ENDIF

aEval(aAreas, {|x| RestArea(x)})
	
Return lRet

/*/{Protheus.doc} F650TemQip
	Função que valida se o produto possui a especificação cadastrada.
	@type  Static Function
	@author maiara.cunhago
	@since 12.05.2022
	@version 1.0
	@param 	
	@return return, logico, marca ou não o produto 
	@example
	(examples)
	@see (links_or_references)
	/*/
Function F650TemQip(cCondMark, oMarkBrw)
	Local lMark := .T.	
	Local lInRefresh := IsInCallStack("LINEREFRESH")
	Local aArea     := GetArea()
	Local cAlias    := Alias()
	Local cCpoMarca := 'C6_OK'
	Local cRevProd  := ""
	Local lBLOESP   := If(SuperGetMV("MV_QBLOESP",.F.,"2") == "2",.F.,.T.)//Devido a integracao do PCP com o QIP, bloqueia se nao tiver Especifacao. 1 = Sim/ 2 =Nao
	Local lIntQIPMAT:= If(SuperGetMV("MV_QIPMAT",.F.,"N")=="N",.F.,.T.)//Integracao do QIP com Materiais
	Local lMT650QIP := If(ExistBlock("MT650QIP"),ExecBlock("MT650QIP",.F.,.F.),.T.)//ponto de entrada para validar ou nao a integracao com SIGAQIP

	IF Empty(&cCondMark) 
		If !lInRefresh 
			If lIntQIPMAT .And. lMT650QIP //necessario para não exibir a msg qdo nao houver integracao
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+SC6->C6_PRODUTO)

				M->C2_ROTEIRO := A650VldRot(SC6->C6_PRODUTO,SB1->B1_OPERPAD)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o Produto possui ensaios.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(AllTrim(M->C2_ROTEIRO))
					cRevProd := QA_UltRevEsp(SC6->C6_PRODUTO,,,,'QIP')
					If !QIPValEns(SC6->C6_PRODUTO, cRevProd, M->C2_ROTEIRO)
						If lBLOESP
							lMark := .F.
						Endif
						If (!l650Auto .Or. !lMark) .and. !lAllMark
							Help(" ",1,"C650NOREV")//"Nao existe especificação para esse Produto/Roteiro."
						ElseIf lAllMark
							lAllHelp := .T.
						EndIf
					Else 
						lAllHelp := .T.
					Endif
				Else
					If lBLOESP
						lMark := .F.
					Endif
					If !l650Auto .and. !lAllMark
						Help(" ",1,"C650NOREV")//"Nao existe especificação para esse Produto/Roteiro."
					ElseIf lAllMark
						lAllHelp := .T.
					EndIf
				Endif
			Endif		
		EndIf
	Else
		lMark := .F.		
	EndIf	
	
	RestArea(aArea)
Return lMark
