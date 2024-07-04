// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 61     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "ofiom16c.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM160C³ Autor ³  Emilton              ³ Data ³ 30/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fechamento de Ordem de Servico (Segmento Fecto Agrupado)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM16C()

Local _xxi
Local nValControle := 0 , nParcelas:=0
Local cNumPed
Local x_	  := 0
Local ixi	  := 0
Local i		  := 0
Local ixa	  := 0
Local nSelect := 0
Local nValorFin := 0
Local cQuery  := ""
Local cQAlTES := "SQLTES"
Local cQAlVS1  := "SQLVS1"
Local cTES    := ""
Private lVAMCid  := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private cPrefNF  := ""
Private cPrefixo := GetNewPar("MV_PREFOFI","OFI")
Private aCabPV  := {}
Private aIte    := {}

cKeyAce := cParam02+cParam03  // Codigo do Cliente / Loja
FG_SEEK("SA1","cKeyAce")
if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
Endif

//cKeyAce := __cUserID
//FG_SEEK("VAI","cKeyAce",4,.f.)
VAI->(dbSetOrder(1))
VAI->(dbSeek(xFilial("VAI")+VO1->VO1_FUNABE))
SA3->(dbSetOrder(1))
SA3->(dbSeek(xFilial("SA3")+VAI->VAI_CODVEN))
cKeyAce := __cUserID
FG_SEEK("VAI","cKeyAce",4,.f.)

cKeyAce := cParam04
FG_SEEK("VOI","cKeyAce",1,.f.)

Do Case
	Case VOI->VOI_SITTPO == "3"   // Interno
		ProcRegua(5)
	Case VOI->VOI_SITTPO $ "2/4"  // Garantia & Revisao
		ProcRegua(7)
	OtherWise
		ProcRegua(6)
EndCase

If cPaisLoc == "BRA" // Manoel - 12/05/2009
	lIntegLoja := .f.
	If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"	//nao Integrado com o Sigaloja ?
		cNumPed  := CriaVar("C5_NUM")
		IncProc(STR0001) //"Preparando Dados da NF"
		If lAbortPrint
			If MsgYesNo(OemToAnsi(STR0002),OemToAnsi(STR0003)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
				Help("  ",1,"M160PROABO")
				lRetFech := .f.
				DisarmTransaction()
				Break
			Else
				lAbortPrint := .F.
			EndIf
		EndIf

		//Cabecalho do Pedido
		Private cCliPad := ""
		Private cLojPad := ""

		//if SA1->A1_PESSOA == "J" .and. !Empty(SA1->A1_INSCR) .and. FS_VLCIDEST(1)[2] <> GETMV("MV_ESTADO")
		//   cCliPad := ""
		//   cLojPad := ""
		//Else
		//   cCliPad := GetMv("MV_CLIPAD")
		//   cLojPad := GetMv("MV_LOJAPAD")
		//Endif

		aAdd(aCabPV,{"C5_NUM"    ,cNumPed         ,Nil}) // Numero do pedido
		aAdd(aCabPV,{"C5_TIPO"   ,"N"             ,Nil}) // Tipo de pedido
		aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD     ,Nil}) // Codigo do cliente
		aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA    ,Nil}) // Loja do cliente
		//If !Empty(cCliPad)
		//	aAdd(aCabPV,{"C5_CLIENT" ,cCliPad         ,Nil}) // Codigo do cliente
		//	aAdd(aCabPV,{"C5_LOJAENT",cLojPad         ,Nil}) // Loja para entrada
		//Endif
		aAdd(aCabPV,{"C5_EMISSAO",dDataBase       ,Nil}) // Data de emissao
		aAdd(aCabPV,{"C5_CONDPAG",RetCondVei()    ,Nil}) // Codigo da condicao de pagamanto
		aAdd(aCabPV,{"C5_DESC1"  ,0               ,Nil}) // Percentual do Desconto Geral
		aAdd(aCabPV,{"C5_INCISS" ,"S"             ,Nil}) // ISS Incluso
		aAdd(aCabPV,{"C5_TIPLIB" ,"2"             ,Nil}) // Tipo de Liberacao
		aAdd(aCabPV,{"C5_MOEDA"  ,1               ,Nil}) // Moeda
		aAdd(aCabPV,{"C5_LIBEROK","S"             ,Nil}) // Liberacao Total
		aAdd(aCabPV,{"C5_VEND1"  ,VAI->VAI_CODVEN ,Nil}) // Codigo do vendedor
		aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO    ,Nil}) // Tipo do Cliente
		aAdd(aCabPV,{"C5_BANCO"  ,cCodBco         ,Nil}) // Codigo do Banco
		aAdd(aCabPV,{"C5_COMIS1" ,0               ,Nil}) // Percentual de Comissao
		aAdd(aCabPV,{"C5_DESPESA",M->VSF_DESACE   ,Nil}) // Despesa Adicionais

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("SC5")
		While !Eof().and.(x3_arquivo=="SC5")
			wVar := "M->"+x3_campo
			&wVar:= CriaVar(x3_campo)
			dbSkip()
		EndDo

		For x_:=1 to Len(aCabPV)
			Private &("M->"+aCabPV[x_,1]) := aCabPV[x_,2]
		Next

		cTipPed := "N"  // Saida Normal
		cCont := "00"

		//Pecas

		For ixi := 1 to len(aColsFEC[2])
			If Empty(aColsFEC[2,ixi,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
				loop
			EndIf

			nValControle += aColsFEC[2,ixi,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
			cNumIte := cCont := Soma1( cCont , 2 )
			aItePV       := {}

			cKeyAce := aColsFEC[2,ixi,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixi,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			FG_SEEK("SB1","cKeyAce",7,.f.)
			SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
			cOrigB1 := Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB
			FG_SEEK("SB5","SB1->B1_COD")
			FG_SEEK("SB2","SB1->B1_COD")
			cKey := aColsFEC[2,ixi,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]
			FG_SEEK("SF4","cKey")

			cCFiscal := FG_CLAFIS(FG_TABTRIB(VOI->VOI_CODOPE,cOrigB1,aColsFEC[2,ixi,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]))

			//Itens
			nDescont := aColsFEC[2,ixi,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]

			// Numero do Pedido
			aAdd(aItePV,{"C6_NUM"    ,cNumPed,Nil})
			// Numero do Item no Pedido
			aAdd(aItePV,{"C6_ITEM"   ,cNumIte,Nil})
			// Codigo do Produto
			aAdd(aItePV,{"C6_PRODUTO",SB1->B1_COD,Nil})
			// Quantidade Vendida
			aAdd(aItePV,{"C6_QTDVEN" ,aColsFEC[2,ixi,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],Nil})
			// Preco Unitario Liquido
			//aAdd(aItePV,{"C6_PRUNIT" ,(aColsFEC[2,ixi,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]/aColsFEC[2,ixi,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]),Nil})
			aAdd(aItePV,{"C6_PRUNIT" ,Round((aColsFEC[2,ixi,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]-nDescont)/aColsFEC[2,ixi,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],2),Nil})
			// Preco Venda
			aAdd(aItePV,{"C6_PRCVEN" ,Round((aColsFEC[2,ixi,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]-nDescont)/aColsFEC[2,ixi,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],2),Nil})
			// Valor Total do Item
			//		aAdd(aItePV,{"C6_VALOR"  ,Round((aColsFEC[2,ixi,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]-nDescont) ,2) ,Nil})
			aAdd(aItePV,{"C6_VALOR"  ,Round( ( aItePV[Ascan(aItePV,{ |x| x[1] == "C6_PRUNIT" }),2] * aItePV[Ascan(aItePV,{ |x| x[1] == "C6_QTDVEN" }),2] ) ,2) ,Nil})
			// Data da Entrega
			aAdd(aItePV,{"C6_ENTREG" ,dDataBase,Nil})
			// Unidade de Medida Primar.
			aAdd(aItePV,{"C6_UM"     ,SB1->B1_UM,Nil})
			// Tipo de Saida do Item
			aAdd(aItePV,{"C6_TES"    ,FG_TABTRIB(VOI->VOI_CODOPE,cOrigB1,aColsFEC[2,ixi,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]),Nil})
			// Almoxarifado
			aAdd(aItePV,{"C6_LOCAL"  ,VOI->VOI_CODALM,Nil})

			if !Empty(VOI->VOI_LOCALI) .and. localiza(SB1->B1_COD)
				aAdd(aItePV,{"C6_LOCALIZ"  ,VOI->VOI_LOCALI,Nil})
			Endif

			// Controle de rastro
			If Rastro(SB1->B1_COD)
				aAdd(aItePV,{"C6_LOTECTL"  , aColsFEC[2,ixi,FS_POSVAR("VO3_LOTECT","aHeaderFEC",2)] ,Nil})
				aAdd(aItePV,{"C6_NUMLOTE"  , aColsFEC[2,ixi,FS_POSVAR("VO3_NUMLOT","aHeaderFEC",2)] ,Nil})
				aAdd(aItePV,{"C6_NUMSERI"  , aColsFEC[2,ixi,FS_POSVAR("VO3_NUMSER","aHeaderFEC",2)] ,Nil})
			Endif
			// CFO
			aAdd(aItePV,{"C6_CF"     ,cCFiscal       ,Nil})
			// Valor do Desconto
			aAdd(aItePV,{"C6_VALDESC",0          ,Nil})

			// Comissao Vendedor
			// aAdd(aItePV,{"C6_COMIS1" ,nComVend       ,Nil})

			// Descricao do Produto
			aAdd(aItePV,{"C6_DESCRI" ,SB1->B1_DESC   ,Nil})
			// Cliente
			aAdd(aItePV,{"C6_CLI"    ,SA1->A1_COD    ,Nil})
			// Loja do Cliente
			aAdd(aItePV,{"C6_LOJA"   ,SA1->A1_LOJA   ,Nil})
			// Quantidade Empenhada
			aAdd(aItePV,{"C6_QTDEMP" ,aColsFEC[2,ixi,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],Nil})
			// Quantidade Liberada
			//		aAdd(aItePV,{"C6_QTDLIB" ,aColsFEC[2,ixi,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],Nil})

			aAdd(aIte,aClone(aItePV))

		Next

		//Servicos

		If VOI->VOI_SITTPO != "3" // Tipo de Tempo Interno

			For ixi := 1 to len(aColsFEC[3])

				If Empty(aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]) .Or. aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] == 0
					loop
				EndIf

				nValControle += aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
				cKeyAce      := aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]

				VOK->(dbSetOrder(1))
				VOK->(dbSeek( xFilial("VOK") + aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] ))
				// Servico de Mao de Obra Gratuita ...
				If VOK->VOK_INCMOB == "0"
					Loop
				EndIf

				FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
				FG_SEEK("SB5","SB1->B1_COD")
				FG_SEEK("SB2","SB1->B1_COD")
				cKey := aColsFEC[3,ixi,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)]
				FG_SEEK("SF4","cKey")

				cCFiscal := FG_CLAFIS(aColsFEC[3,ixi,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)])

				cNumIte := cCont := Soma1( cCont , 2 )

				//Items
				aItePv := {}

				// Numero do Pedido
				aAdd(aItePV,{"C6_NUM"    ,cNumPed,Nil})
				// Numero do Item no Pedido
				aAdd(aItePV,{"C6_ITEM"   ,cNumIte,Nil})
				// Codigo do Produto
				aAdd(aItePV,{"C6_PRODUTO",SB1->B1_COD,Nil})
				// Quantidade Vendida
				aAdd(aItePV,{"C6_QTDVEN" ,1,Nil})
				// Preco Unitario Liquido                 ???????????????
				aAdd(aItePV,{"C6_PRUNIT" ,aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)],Nil})
				// Preco Venda
				aAdd(aItePV,{"C6_PRCVEN" ,aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)],Nil})
				// Valor Total do Item
				aAdd(aItePV,{"C6_VALOR"  ,aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)],Nil})
				// Data da Entrega
				aAdd(aItePV,{"C6_ENTREG" ,dDataBase,Nil})
				// Unidade de Medida Primar.
				aAdd(aItePV,{"C6_UM"     ,SB1->B1_UM,Nil})
				// Tipo de Saida do Item
				aAdd(aItePV,{"C6_TES"    ,aColsFEC[3,ixi,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)],Nil})
				// Almoxarifado
				aAdd(aItePV,{"C6_LOCAL"  ,SB1->B1_LOCPAD,Nil})
				// CFO
				aAdd(aItePV,{"C6_CF"     ,cCFiscal,Nil})
				// Valor do Desconto
				//			aAdd(aItePV,{"C6_VALDESC",aColsFEC[3,ixi,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)],Nil})
				aAdd(aItePV,{"C6_VALDESC",0,Nil})

				// Comissao Vendedor
				// aAdd(aItePV,{"C6_COMIS1" ,nComVend       ,Nil})
				// Descricao do Produto
				aAdd(aItePV,{"C6_DESCRI" ,SB1->B1_DESC   ,Nil})
				// Cliente
				aAdd(aItePV,{"C6_CLI"    ,SA1->A1_COD    ,Nil})
				// Loja do Cliente
				aAdd(aItePV,{"C6_LOJA"   ,SA1->A1_LOJA   ,Nil})
				// Quantidade Empenhada
				aAdd(aItePV,{"C6_QTDEMP" ,1,Nil})
				// Quantidade Liberada
				//			aAdd(aItePV,{"C6_QTDLIB" ,1,Nil})

				aAdd(aIte,aClone(aItePV))

			Next

		EndIf

		//Efetua a Liberacao do Pedido se LiberOk == "S" e QtdLib = QtdEmp

		lMSHelpAuto := .t.

		lMsErroAuto := .f. // se retornar .t. deu erro

		If len(aIte) > 0 .and. nValControle > 0
//			FG_X3ORD("C",,aCabPv)
//			FG_X3ORD("I",,aIte)
			If ExistBlock("PEOM160ANP")
				ExecBlock("PEOM160ANP",.f.,.f.)
			Endif
 			MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aIte,3)

			if LMsErroAuto
				DisarmTransaction()
				Break
			Endif

			IncProc(STR0004) //"Gerando NF"
			If lAbortPrint
				If MsgYesNo(OemToAnsi(STR0002),OemToAnsi(STR0003)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
					Help("  ",1,"M160PROABO")
					lRetFech := .f.
					DisarmTransaction()
					Break
				Else
					lAbortPrint := .F.
				EndIf
			EndIf

			lCredito := .t.
			lEstoque := .t.
			lLiber   := .t.
			lTransf  := .f.
			lEstNeg  := (GetMV("MV_ESTNEG") == "S")

			dbSelectArea("SC9")
			dbSetOrder(1)

			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+cNumPed+"01")
			While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
				dbSelectArea("SC9")
				if !dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM)
					nQtdLib := SC6->C6_QTDVEN
					nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,(!lESTNEG),lLiber,lTransf)
				Endif
				dbSelectArea("SC6")
				dbSkip()
			Enddo

			dbSelectArea("SC9")
			dbSeek(xFilial("SC9")+cNumPed+"01")
			While SC9->C9_PEDIDO == cNumPed .and. SC9->C9_FILIAL == xFilial("SC9") .and. !Eof()

				If Empty(SC9->C9_BLCRED) .AND. Empty(SC9->C9_BLEST)

					FG_SEEK("SB1","SC9->C9_PRODUTO",1)
					FG_SEEK("SC5","SC9->C9_PEDIDO",1,.F.)
					FG_SEEK("SC6","SC9->C9_PEDIDO+SC9->C9_ITEM",1)
					FG_SEEK("SB5","SB1->B1_COD")
					FG_SEEK("SB2","SB1->B1_COD")
					FG_SEEK("SF4","SC6->C6_TES")
					FG_SEEK("SE4","cTipPag",1)

					aAdd(aPvlNfs,{C9_PEDIDO,;
					C9_ITEM,;
					C9_SEQUEN,;
					C9_QTDLIB,;
					C9_PRCVEN,;
					C9_PRODUTO,;
					SF4->F4_ISS=="S",;
					SC9->(RecNo()),;
					SC5->(RecNo()),;
					SC6->(RecNo()),;
					SE4->(RecNo()),;
					SB1->(RecNo()),;
					SB2->(RecNo()),;
					SF4->(RecNo())})
				Else
					MsgStop(STR0011)	// "Existe um ou mais itens bloqueados por crédito/estoque"
					lRetFech := .f.
					DisarmTransaction()
					Break
				EndIf
				dbSkip()

			Enddo

			FG_SEEK("SE4","cTipPag",1)  //Tem que ser Tipo A para nao criar E1 automatico

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			PERGUNTE("MT460A",.f.)
			cNota   := MaPvlNfs(aPvlNfs,cSerie, (mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
			//	   cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
			if Empty(cNota) .and. SF2->F2_SERIE == iif(nCheck==1,cSerie,SuperGetMv("MV_SERCUP"))
				cNota := SF2->F2_DOC
			Endif
			cNota := LEFT(cNota+sPACE(15),TamSx3("F2_DOC")[1])
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			if SC5->(DbSeek(xFilial("SC5")+cNumPed))
				RecLock("SC5",.f.)
				SC5->C5_CONDPAG := cTipPag
				MsUnlock()
			Endif


			//		cPrefNF := iif(nCheck==1,&(GetNewPar("MV_1DUPREF","cSerie")),SuperGetMv("MV_SERCUP"))
			_nDescMIL := 0

			//Pecas
			dbSelectArea("SD2")
			dbSetOrder(3)
			cNumIte := "00"
			For ixi := 1 to len(aColsFEC[2])
				If Empty(aColsFEC[2,ixi,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
					loop
				EndIf
				cNumIte := Soma1( cNumIte , 2 )
				cKeyAce      := aColsFEC[2,ixi,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixi,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
				FG_SEEK("SB1","cKeyAce",7,.f.)
				dbSelectArea("SD2")
				if dbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+SB1->B1_COD+cNumIte)
					RecLock("SD2",.f.)
					SD2->D2_DESC   := aColsFEC[2,ixi,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
					SD2->D2_DESCON := aColsFEC[2,ixi,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
					MsUnlock()
					_nDescMIL += SD2->D2_DESCON
				Endif
			Next

			//Servicos
			For ixi := 1 to len(aColsFEC[3])
				If Empty(aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)])
					loop
				EndIf

				cKeyAce      := aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]
				FG_SEEK("VOK","cKeyAce",1,.f.)

				FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
				cNumIte := Soma1( cNumIte , 2 )

				dbSelectArea("SD2")
				if dbSeek(xFilial("SD2")+cNota+cSerie+SA1->A1_COD+SA1->A1_LOJA+SB1->B1_COD+cNumIte)
					RecLock("SD2",.f.)
					SD2->D2_DESC   := aColsFEC[3,ixi,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)]
					SD2->D2_DESCON := aColsFEC[3,ixi,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)]
					MsUnlock()
					_nDescMIL += SD2->D2_DESCON
				Endif
			Next
			RecLock("SF2",.f.)
			SF2->F2_COND   := cTipPag
			SF2->F2_DUPL   := cNota
			SF2->F2_SERIE  := cSerie
			SF2->F2_PREFORI:= cPrefixo
			SF2->F2_VALFAT := nTotTTP
			SF2->F2_DESCONT:= _nDescMIL

			&& Grava a observacao da nota fiscal
			If ( Type("cObsNF") # "U" .And. SF2->(FieldPos("F2_OBSMEM")) # 0 )
				aMemos  := {{"F2_OBSMEM","cObsNF"}}
				MSMM(,TamSx3("F2_OBSERV")[1],,&(aMemos[1][2]),1,,,"SF2","F2_OBSMEM")
			EndIf

			MsUnlock()

			cPrefNF := iif(nCheck==1,&(GetNewPar("MV_1DUPREF","cSerie")),SuperGetMv("MV_SERCUP"))

			RecLock("SF2",.f.)
			SF2->F2_PREFIXO:= cPrefNF
			MsUnlock()

		EndIf

		// Verificacao para geracao do Financeiro - FNC 21433/2010 - Manoel - 22/10/2010
	   lGerFina := .f.
		dbSelectArea("SD2")
		If dbSeek(xFilial("SD2")+cNota+cSerie)
			dbSelectArea("SF4")
			If dbSeek(xFilial("SF4")+SD2->D2_TES)
				If SF4->F4_DUPLIC == "S"
				   lGerFina := .t.
				Endif
			Endif

		Endif

		If VOI->VOI_SITTPO != "3" .and. lGerFina

			IncProc(STR0005) //"Atualizando Modulo Financeiro"
			If lAbortPrint
				If MsgYesNo(OemToAnsi(STR0002),OemToAnsi(STR0003)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
					Help("  ",1,"M160PROABO")
					lRetFech := .f.
					DisarmTransaction()
					Break
				Else
					lAbortPrint := .F.
				EndIf
			EndIf

			if (Len(aColsC) = 1) .and. (Empty(aColsC[1,1])) .and. (Empty(aIteParc[1,1]))
				aColsC[Len(aColsC),1] := "DP"
				aColsC[Len(aColsC),2] := "DUPLICATA"
				aColsC[Len(aColsC),3] := dDataBase
				aColsC[Len(aColsC),4] := nTotTTp+M->VSF_DESACE
			Endif

			aColsSlvC := aClone(aColsC)

			//Geracao de Titulos para o Contas a Receber

			if Empty(cCodBco)
				cCodBco := GetMv("MV_BCOCXA")
			Endif
			cKeyAce := cParam02+cParam03
			FG_SEEK("SA1","cKeyAce")
			FG_SEEK("SE4","cTipPag",1)  //Tem que ser Tipo A para nao criar E1 automatico
			FG_Seek("SA6","cCodBco",1,.f.)
			if SA6->A6_BORD == "0"
				cNumBord := "BCO"+SA6->A6_COD
				dDatBord := dDataBase
			Endif
			nSTMil := 0
			For _xxi:=1 to Len(aColsC)
				If !aColsC[_xxi,Len(aColsC[_xxi])] .and. !Empty(aColsC[_xxi,1])
					nSTMil := nSTMil + aColsC[_xxi,4]
				Endif
			Next

			For _xxi:=1 to Len(aIteParc)
				nSTMil := nSTMil + aIteParc[_xxi,2]
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Cliente recolhe ISS para nao considerar ³
			//³ no comparativo do Financeiro com a Nota Fiscal        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF SC5->(FieldPos("C5_RECISS")) <> 0 .and. SC5->C5_RECISS == "1" .and. ( SC5->(FieldPos("C5_INCISS")) == 0 .or. ( SC5->(FieldPos("C5_INCISS")) <> 0 .and. SC5->C5_INCISS == "N" ))
				If nSTMil <> (SF2->F2_VALBRUT - SF2->F2_VALISS) .and. ABS(nSTMil - SF2->F2_VALBRUT - SF2->F2_VALISS) > 0.01 //nTotTTp+M->VSF_DESACE
					Help(" ",1,"M160BATTOT")   // A soma da entrada e financiamento nao bate com o valor do fechamento
					lRetFech := .f.
					DisarmTransaction()
					Break
				endif
			Else
				If nSTMil <> SF2->F2_VALBRUT .and. ABS(nSTMil - SF2->F2_VALBRUT) > 0.01 //nTotTTp+M->VSF_DESACE
					Help(" ",1,"M160BATTOT")   // A soma da entrada e financiamento nao bate com o valor do fechamento
					lRetFech := .f.
					DisarmTransaction()
					Break
				endif
			endif
			//

			nParcelas:=0
			For i:=1 to len(aColsC)

				if Empty(aColsC[1,1]) .Or. aColsC[i,Len(aColsC[i])] == .t.
					Loop
				Endif

				cCodBco2 := cCodBco
//				cNumBord2 := "BCO"+SA6->A6_COD
//				dDatBord2 := cTod("")
				if !Empty(aColsC[i,FG_POSVAR('VS9_PORTAD',"aHeaderC")])
					cCodBco2 := aColsC[i,FG_POSVAR('VS9_PORTAD',"aHeaderC")]
				Endif
				FG_Seek("SA6","cCodBco2",1,.f.)

				cNatureza := ""

//				if SA6->A6_BORD == "0"
//					cNumBord2 := "BCO"+SA6->A6_COD
//					dDatBord2 := dDataBase
//				Endif

/*
				if !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
					nPosVirg := AT(",",GETMV("MV_NATPER"))
					If "P" $ _cPecSrv // Natureza de Pecas
						cNatureza   := If(nPosVirg>0,Left(GETMV("MV_NATPER"),nPosVirg-1),GETMV("MV_NATPER"))
					Else//If "S" $ _cPecSrv // Natureza de Servicos
						cNatureza := If(nPosVirg>0,Alltrim(Subs(GETMV("MV_NATPER"),nPosVirg+1)),GETMV("MV_NATPER"))   // Codigo da natureza dos titulos a serem gerados
					Endif
				Else
					cTipTit   := aColsC[i,1]
					cNatureza := SA1->A1_NATUREZ
				Endif
*/
				if !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
					cTipTit   := GETMV("MV_TIPPER")    // Tipo de titulo a ser gerado
				Else
					cTipTit   := aColsC[i,1]
				Endif

				If "P" $ _cPecSrv // Natureza de Pecas
			      If FG_POSVAR("VS9_NATURE","aHeaderC") > 0
						 if !Empty(aColsC[i,FG_POSVAR("VS9_NATURE","aHeaderC")])
						    cNatureza := aColsC[i,FG_POSVAR("VS9_NATURE","aHeaderC")]
						 Endif
					Endif
				Else //If "S" $ _cPecSrv // Natureza de Servicos
			      If FG_POSVAR("VS9_NATSRV","aHeaderC") > 0
						 if !Empty(aColsC[i,FG_POSVAR("VS9_NATSRV","aHeaderC")])
						    cNatureza := aColsC[i,FG_POSVAR("VS9_NATSRV","aHeaderC")]
						 Endif
					Endif
				Endif

				If Empty(cNatureza)
					If lVO1_NATURE // Existe o campo VO1->VO1_NATURE
						If "P" $ _cPecSrv // Natureza de Pecas
							if !Empty(cVO1_NATURE)
								cNatureza := cVO1_NATURE
							Else
								cNatureza := SA1->A1_NATUREZ
							Endif
						ElseIf "S" $ _cPecSrv // Natureza de Servicos
							if !Empty(cVO1_NATSRV)
								cNatureza := cVO1_NATSRV
							Else
								cNatureza := SA1->A1_NATUREZ
							Endif
						Endif
					EndIf
				EndIf

				nParcelas++
				if TamSx3("E1_PARCELA")[1] = 1
					cParcela := ConvPN2PC(nParcelas)
				Else
					cParcela := Soma1( strZERO(nParcelas-1,TamSx3("E1_PARCELA")[1]) )
				Endif

				aTitulo := {{"E1_PREFIXO",cPrefNF                ,Nil},;
				{"E1_NUM"    ,cNota                  ,Nil},;
				{"E1_PARCELA",cParcela               ,Nil},;
				{"E1_TIPO"   ,cTipTit                ,Nil},;
				{"E1_NATUREZ",cNatureza              ,Nil},;
				{"E1_SITUACA",cTipCob                 ,Nil},;
				{"E1_CLIENTE",SA1->A1_COD            ,Nil},;
				{"E1_LOJA"   ,SA1->A1_LOJA           ,Nil},;
				{"E1_EMISSAO",dDataBase              ,Nil},;
				{"E1_VENCTO" ,aColsC[i,3]            ,Nil},;
				{"E1_VENCREA",DataValida(aColsC[i,3]),Nil},;
				{"E1_VALOR"  ,aColsC[i,4]            ,Nil },;
				{"E1_PORTADO",cCodBco2               ,Nil},;
				{"E1_PREFORI",cPrefixo               ,Nil},;
				{"E1_VEND1"  , SA3->A3_COD            ,nil},;
				{"E1_COMIS1" , SA3->A3_COMIS          ,nil},;
				{"E1_BASCOM1", aColsC[i,4]           ,nil},;
				{"E1_PEDIDO" , cNumPed                ,nil},;
				{"E1_NUMNOTA", cNota                  ,nil},;
				{"E1_SERIE"  , cSerie                 ,nil},;
				{"E1_ORIGEM" , "MATA460"              ,nil} }

//				{"E1_NUMBOR"  ,cNumBord2             ,Nil},;
//				{"E1_DATABOR" ,dDatBord2             ,Nil},;

				lMSHelpAuto := .t.
				lMsErroAuto := .f.

				dbSelectArea("SX1")
				dbSetOrder(1)
				if dbSeek("FIN04003")
					nSelect := SX1->X1_PRESEL
					RecLock("SX1",.F.)
					SX1->X1_PRESEL := 2
					MsUnlock()
				Endif
				Pergunte("FIN040",.F.)

				aSalvaCols   := aClone(aCols)
				aSalvaHeader := aClone(aHeader)
				aCols        := NIL
				aHeader      := NIL

				_nRecSA1 := SA1->(Recno())

				MSExecAuto({|x| FINA040(x)},aTitulo)

				SA1->(Dbgoto(_nRecSA1))

				aCols   := aClone(aSalvaCols)
				aHeader := aClone(aSalvaHeader)

				if lMsErroAuto
					DisarmTransaction()
					Break
				Endif

				If GetMV("MV_BXSER") == "S"

					If DTOS(aColsC[i,3]) == DTOS(dDataBase)   // Se for a Vista <Baixa>

						aBaixa  := {{"E1_PREFIXO"  ,cPrefNF+space(TamSx3("E1_PREFIXO")[1]-Len(cPrefNF)),Nil},;
						{"E1_NUM"      ,cNota              ,Nil},;
						{"E1_PARCELA" ,cParcela            ,Nil},;
						{"E1_NATUREZ",cVO1_NATURE          ,Nil},;
						{"E1_TIPO"     ,aColsC[i,1]       ,Nil},;
						{"AUTMOTBX"    ,"NOR"             ,Nil},;
						{"AUTDTBAIXA"  ,dDataBase         ,Nil},;
						{"AUTDTCREDITO",dDataBase         ,Nil},;
						{"AUTHIST"     ,STR0006,Nil},; //'Baixa Automatica'
						{"AUTVALREC"   ,aColsC[i,4]       ,Nil }}

						lMSHelpAuto := .t.

						lMsErroAuto := .f.
						MSExecAuto({|x| FINA070(x)},aBaixa)

						If lMsErroAuto
							DisarmTransaction()
							Break
						Endif
					EndIf
				EndIf

			Next

			aColsC := aClone(aColsSlvC)

			//Financiamento - Integracao com Microsiga

			nParcelas:=0

			For i:=1 to Len(aIteParc)

				if Empty(aIteParc[i,1]) .or. aIteParc[i,2] == 0
					Loop
				Endif
/*
				if !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
					If "P" $ _cPecSrv // Natureza de Pecas
						nPosVirg := AT(",",GETMV("MV_NATPER"))
						cNatureza   := If(nPosVirg>0,Left(GETMV("MV_NATPER"),nPosVirg-1),GETMV("MV_NATPER"))
					Else //If "S" $ _cPecSrv // Natureza de Servicos
						cNatureza := If(nPosVirg>0,Alltrim(Subs(GETMV("MV_NATPER"),nPosVirg+1)),GETMV("MV_NATPER"))   // Codigo da natureza dos titulos a serem gerados
					Endif
				Else
					cTipTit   := "DP"
					cNatureza := SA1->A1_NATUREZ
				Endif
*/

				cNatureza := ""

				if !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
					cTipTit   := GETMV("MV_TIPPER")    // Tipo de titulo a ser gerado
				Else
					cTipTit   := "DP"
				Endif

 				If lVO1_NATURE // Existe o campo VO1->VO1_NATURE
					If "P" $ _cPecSrv // Natureza de Pecas
						if !Empty(cVO1_NATURE)
							cNatureza := cVO1_NATURE
						Endif
					Else //If "S" $ _cPecSrv // Natureza de Servicos
						if !Empty(cVO1_NATSRV)
							cNatureza := cVO1_NATSRV
						Endif
					Endif
				EndIf

   			If Empty(cNatureza)
					cNatureza := SA1->A1_NATUREZ
				Endif

				nParcelas++
				if TamSx3("E1_PARCELA")[1] = 1
					cParcela := ConvPN2PC(nParcelas)
				Else
					cParcela := Soma1( strZERO(nParcelas-1,TamSx3("E1_PARCELA")[1]) )
				Endif

				aTitulo := {{"E1_PREFIXO",cPrefNF                  ,Nil},;
				{"E1_NUM"    ,cNota                    ,Nil},;
				{"E1_PARCELA",cParcela                 ,Nil},;
				{"E1_TIPO"   ,cTipTit                ,Nil},;
				{"E1_NATUREZ",cNatureza              ,Nil},;
				{"E1_SITUACA",cTipCob                  ,Nil},;
				{"E1_CLIENTE",SA1->A1_COD              ,Nil},;
				{"E1_LOJA"   ,SA1->A1_LOJA             ,Nil},;
				{"E1_EMISSAO",dDataBase                ,Nil},;
				{"E1_VENCTO" ,aIteParc[i,1]            ,Nil},;
				{"E1_VENCREA",DataValida(aIteParc[i,1]),Nil},;
				{"E1_NUMBOR"  ,cNumBord                ,Nil},;
				{"E1_DATABOR" ,dDatBord                ,Nil},;
				{"E1_PORTADO",cCodBco                  ,Nil},;
				{"E1_VALOR"  ,aIteParc[i,2]            ,Nil },;
				{"E1_PREFORI",cPrefixo                 ,Nil},;
				{"E1_VEND1"  , SA3->A3_COD            ,nil},;
				{"E1_COMIS1" , SA3->A3_COMIS          ,nil},;
				{"E1_BASCOM1", aIteParc[i,2]          ,nil},;
				{"E1_PEDIDO" , cNumPed                ,nil},;
				{"E1_NUMNOTA", cNota                  ,nil},;
				{"E1_SERIE"  , cSerie                 ,nil},;
				{"E1_ORIGEM" , "MATA460"              ,nil} }

				lMSHelpAuto := .t.
				lMsErroAuto := .f.

				dbSelectArea("SX1")
				dbSetOrder(1)
				if dbSeek("FIN04003")
					if nSelect == 0
						nSelect := SX1->X1_PRESEL
					Endif
					RecLock("SX1",.F.)
					SX1->X1_PRESEL := 2
					MsUnlock()
				Endif
				Pergunte("FIN040",.F.)

				aSalvaCols   := aClone(aCols)
				aSalvaHeader := aClone(aHeader)
				aCols        := NIL
				aHeader      := NIL

				_nRecSA1 := SA1->(Recno())

				MSExecAuto({|x| FINA040(x)},aTitulo)

				SA1->(Dbgoto(_nRecSA1))

				aCols   := aClone(aSalvaCols)
				aHeader := aClone(aSalvaHeader)

				If lMsErroAuto
					DisarmTransaction()
					Break
				Endif

				If GetMV("MV_BXSER") == "S"

					If DTOS(aIteParc[i,1]) == DTOS(dDataBase)   // Se for a Vista <Baixa>

						aBaixa  := {{"E1_PREFIXO"  ,cPrefNF+space(TamSx3("E1_PREFIXO")[1]-Len(cPrefNF)),Nil},;
						{"E1_NUM"      ,cNota                ,Nil},;
						{"E1_PARCELA"  ,cParcela             ,Nil},;
						{"E1_NATUREZ",cVO1_NATURE            ,Nil},;
						{"E1_TIPO"     ,"DP "                ,Nil},;
						{"AUTMOTBX"    ,"NOR"                ,Nil},;
						{"AUTDTBAIXA"  ,dDataBase            ,Nil},;
						{"AUTDTCREDITO",dDataBase            ,Nil},;
						{"AUTHIST"     ,STR0006              ,Nil},; //"Baixa Automatica"
						{"AUTVALREC"   ,aIteParc[i,2]        ,Nil }}

						lMSHelpAuto := .t.

						lMsErroAuto := .f.
						MSExecAuto({|x| FINA070(x)},aBaixa)

						if LMsErroAuto
							DisarmTransaction()
							Break
						Endif
					EndIf

				EndIf

			Next

		Endif

		if nSelect <> 0
			dbSelectArea("SX1")
			dbSetOrder(1)
			if dbSeek("FIN04003")
				RecLock("SX1",.F.)
				SX1->X1_PRESEL := nSelect
				MsUnlock()
			Endif
		Endif

		//Gravacao dos Dados dos Tipos de Pagamentos digitados na Entrada

		FS_SALVAFPG()

		//Gravacao de Contrato de CDCI e Titulo Correspondente

		if !Empty(cCodCDCI )
			cContrato := GetSxENum("SEM","EM_CONTRAT")
			ConfirmSx8()
			DbSelectArea("SEN")
			DbSeek(xFilial("SEN")+cCodCDCI)
			GTitCDCI(aIteParc,cParam02,cParam03,cContrato)

			For i:=1 to Len(aIteParc)
				nValorFin += Round(val(Transform(aIteParc[i,2],"999999.99")),2)
			Next

			GContCDCI(cContrato,cParam02,cParam03,cNota,cSerie,dDataBase,nTotTTp+M->VSF_DESACE,nTotalEnt,(nTotTTp+M->VSF_DESACE)-nTotalEnt,(nValorFin+M->VSF_DESACE+nTotalEnt),aIteParc[1,2],aIteParc[1,1],cCodCDCI,0,SEN->EN_COEF,SEN->EN_IOC )
		EndIf

		IncProc(STR0007) //"Atualizando Historico do Veiculo"
		If lAbortPrint
			If MsgYesNo(OemToAnsi(STR0002),OemToAnsi(STR0003)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
				Help("  ",1,"M160PROABO")
				lRetFech := .f.
				DisarmTransaction()
				Break
			Else
				lAbortPrint := .F.
			EndIf
		EndIf
	Else
		lIntegLoja := .t.
		cKeyAce := aVetOsv[1,1]+cParam04
		FG_SEEK("VOO","cKeyAce",1,.f.)
		cKeyAce := cParam04
		FG_SEEK("VOI","cKeyAce",1,.f.)
		if !(VOI->VOI_SITTPO == "3" .and. nTotPec <= 0)  // Interno
			FS_INTLJC()
		Endif
	EndIf
Else
	lIntegLoja := .t.
	cKeyAce := aVetOsv[1,1]+cParam04
	FG_SEEK("VOO","cKeyAce",1,.f.)
	cKeyAce := cParam04
	FG_SEEK("VOI","cKeyAce",1,.f.)
	if !(VOI->VOI_SITTPO == "3" .and. nTotPec <= 0)  // Interno
		FS_INTLJC()
	Endif
EndIf

cComCon := FS_COMCON(cParam04)

If len(aArrPec) > 0

	cOsvAnt := aArrPec[1,01]

	For ixi := 1 to Len(aArrPec)

		If Empty(aArrPec[ixi,01]) .or. aArrPec[ixi,04] == 0
			loop
		EndIf

		cKeyAce := aArrPec[ixi,01]
		FG_SEEK("VO1","cKeyAce",1,.f.)
		FG_SEEK("VV1","VO1->VO1_CHAINT",1,.f.)
		FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
		FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
		FG_SEEK("VE4","VO1->VO1_CODMAR",1,.f.)
		FG_SEEK("VOI","VE4->VE4_TEMINT",1,.f.)
		nVlrInt := VOI->VOI_VALHOR

		cKeyAce := cParam04
		FG_SEEK("VOI","cKeyAce",1,.f.)

		If !FS_VFBPEC(VV1->VV1_PROATU,VV1->VV1_LJPATU,VV1->VV1_CHAINT,VO1->VO1_NUMOSV,cParam04)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+aArrPec[ixi,02]+aArrPec[ixi,03])
		DbSelectArea("SB2")
		DbSeek(xFilial("SB2")+SB1->B1_COD+VOI->VOI_CODALM)

		cKeyAce := cParam04
		FG_SEEK("VOI","cKeyAce",1,.f.)

		ix1 := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == SB1->B1_GRUPO+SB1->B1_CODITE } )

		SF4->(dbSetOrder(1))
		If ix1 > 0 .and. FS_POSVAR("VO3_CODTES","aHeaderFEC",2) > 0
			SF4->(dbSeek(xFilial("SF4")+aColsFEC[2,ix1,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]))
		Else
			SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
		Endif

		DbSelectArea("VEC")
		If !RecLock("VEC",.t.)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

		aPisCof := CalcPisCofSai(aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])

		VEC_FILIAL := xFilial("VEC")
		VEC_NUMREL := GetSXENum("VEC","VEC_NUMREL")
		ConfirmSx8()
		VEC_NUMIDE := GetSXENum("VEC","VEC_NUMIDE")
		ConfirmSx8()
		VEC_PECINT := SB1->B1_COD
		VEC_CODMAR := VO1->VO1_CODMAR
		VEC_TIPTEM := cParam04
		VEC_DATVEN := dDataBase
		VEC_MODVEI := VV1->VV1_MODVEI
		VEC_GRUITE := aColsFEC[2,ix1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
		VEC_CODITE := aColsFEC[2,ix1,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]

		VEC_NUMNFI := cNota
		VEC_SERNFI := cSerie
		If VEC->(FieldPos("VEC_PEDXML")) <> 0 .and. VO3->(FieldPos("VO3_PEDXML")) <> 0
			VEC_PEDXML := aColsFEC[2,ix1,FS_POSVAR("VO3_PEDXML","aHeaderFEC",2)]
			VEC_ITEXML := aColsFEC[2,ix1,FS_POSVAR("VO3_ITEXML","aHeaderFEC",2)]
		Endif

		If VEC->(FieldPos("VEC_LIBVOO")) <> 0
			VOO->(dbSetOrder(1))
			If VOO->(dbSeek( xFilial("VOO") + aArrPec[ixi,01] + cParam04 ))
				VEC->VEC_LIBVOO := VOO->VOO_LIBVOO
			EndIf
		EndIf

		VEC_QTDITE := aArrPec[ixi,04] // aColsFEC[2,i,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
		VEC_VALDES := ( ( aColsFEC[2,ix1,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ) * aArrPec[ixi,04] )

		FG_SEEK("SD2","VEC->VEC_NUMNFI+VEC->VEC_SERNFI+SF2->F2_CLIENTE+SF2->F2_LOJA+VEC->VEC_PECINT",3,.f.)
		nQtd := SD2->D2_QUANT
		nValPrinc := SD2->D2_TOTAL + SD2->D2_VALFRE + SD2->D2_SEGURO + SD2->D2_VALIPI + SD2->D2_ICMSRET

		// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
		VEC->VEC_CUSMED := (SD2->D2_CUSTO1/nQtd) * VEC->VEC_QTDITE
		VEC->VEC_VALVDA := ((SD2->D2_TOTAL)/nQtd)  * VEC->VEC_QTDITE
		VEC->VEC_VALBRU := (((nValPrinc)/nQtd)* VEC->VEC_QTDITE ) + VEC->VEC_VALDES
		VEC->VEC_JUREST := 0
		VEC->VEC_CUSTOT := VEC->VEC_CUSMED + VEC->VEC_JUREST
		VEC->VEC_VALFRE := (SD2->D2_VALFRE / nQtd) * VEC->VEC_QTDITE
		VEC->VEC_VALSEG := (SD2->D2_SEGURO / nQtd) * VEC->VEC_QTDITE
		if VEC->(FieldPos("VEC_DESACE"))#0
			VEC->VEC_DESACE := (SD2->D2_DESPESA / nQtd) * VEC->VEC_QTDITE
		Endif
		if VEC->(FieldPos("VEC_ICMSRT"))#0
			VEC->VEC_ICMSRT := (SD2->D2_ICMSRET / nQtd) * VEC->VEC_QTDITE
		Endif
		if VEC->(FieldPos("VEC_VALIPI"))#0
			VEC->VEC_VALIPI := (SD2->D2_VALIPI / nQtd) * VEC->VEC_QTDITE
		Endif
		//		VEC_CUSMED := SB2->B2_CM1 * VEC_QTDITE    // Conforme Sr Farinelli em 25/06/2001 as 18:10
		//		VEC_VALVDA := ( ( aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ) * aArrPec[ixi,04] )
		//		VEC_VALBRU := ( ( aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ) * aArrPec[ixi,04] )
		//		VEC_JUREST := FG_JUREST(,SB1->B1_COD,SB1->B1_UCOM,dDataBase,"P")
		//		VEC_CUSTOT := VEC_CUSMED + VEC_JUREST

		// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
		VEC_VALICM := 0
		VEC_ALQICM := 0
		If SF4->F4_CREDICM == "S"
			VEC_VALICM := (SD2->D2_VALICM/nQtd) * VEC->VEC_QTDITE //aColsFEC[2,ixi,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)]
			VEC_ALQICM := aColsFEC[2,ix1,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)]
		Endif

		// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
		if SF4->F4_PISCRED = "2" // tributada
			if SF4->F4_PISCOF $ "1/3"  //PIS
				VEC->VEC_VALPIS := SD2->D2_VALIMP6
			endif
			if SF4->F4_PISCOF $ "2/3"  //COFINS
				VEC->VEC_VALCOF := SD2->D2_VALIMP5
			endif
			if SF4->F4_PISCOF = "4"
				VEC->VEC_VALPIS := 0
				VEC->VEC_VALCOF := 0
			endif
		elseif SF4->F4_PISCRED # "2"  //isenta
			VEC->VEC_VALPIS := 0
			VEC->VEC_VALCOF := 0
		endif

		//		VEC_VALICM := 0
		//		VEC_ALQICM := 0
		//		If SF4->F4_CREDICM == "S"
		//			VEC_VALICM := ( ( aColsFEC[2,ix1,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ) * aArrPec[ixi,04] )
		//			VEC_ALQICM := aColsFEC[2,ix1,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)]
		//		Endif
		//		VEC_VALCOF := aPisCof[1,2] // aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] * nAliCof
		//		VEC_VALPIS := aPisCof[1,1] //aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] * nAliPis

		VEC_TOTIMP := VEC_VALICM + VEC_VALCOF + VEC_VALPIS

		aVetTra    := aClone(aBoqPec)

		Do Case
			Case cComCon == "1"
				aAdd(aVetTra,{VO1->VO1_FUNABE,0})
			Case cComCon == "2"
				nRegVAI := VAI->(RecNo())
				cKeyAce := __cUserID
				FG_SEEK("VAI","cKeyAce",4,.f.)
				aAdd(aVetTra,{VAI->VAI_CODTEC,0})
				VAI->(DbGoTo(nRegVAI))
			Case cComCon == "3"
				aAdd(aVetTra,{VO1->VO1_FUNABE,0})
				nRegVAI := VAI->(RecNo())
				cKeyAce := __cUserID
				FG_SEEK("VAI","cKeyAce",4,.f.)
				aAdd(aVetTra,{VAI->VAI_CODTEC,0})
				VAI->(DbGoTo(nRegVAI))
		EndCase

		aValCom    := FG_COMISS("P",aVetTra,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"T",VEC_NUMIDE)
		VEC_COMVEN := aValCom[1]
		VEC_COMGER := aValCom[2]
		VEC_DESVAR := VEC_COMVEN + VEC_COMGER

		// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
		VEC->VEC_LUCBRU := (VEC->VEC_VALBRU-VEC->VEC_VALDES) - VEC->VEC_TOTIMP - VEC->VEC_CUSMED - iif(VEC->(FieldPos("VEC_ICMSRT"))#0,VEC->VEC_ICMSRT,0) + iif(VEC->(FieldPos("VEC_ICMSST"))#0,VEC->VEC_ICMSST,0) + iif(VEC->(FieldPos("VEC_DCLBST"))#0,VEC->VEC_DCLBST,0) + iif(VEC->(FieldPos("VEC_COPIST"))#0,VEC->VEC_COPIST,0)
		VEC->VEC_LUCLIQ := VEC->VEC_LUCBRU - VEC->VEC_JUREST - VEC->VEC_DESVAR - VEC->VEC_DESDEP - VEC->VEC_DESADM - VEC->VEC_DESFIX  //LUCRO MARGINAL
		VEC->VEC_RESFIN := VEC->VEC_LUCLIQ - VEC->VEC_CUSFIX  //LAIR
		//		VEC_LUCBRU := VEC_VALVDA - VEC_TOTIMP - VEC_CUSTOT
		//		VEC_LUCLIQ := VEC_LUCBRU - VEC_DESVAR
		//		VEC_RESFIN := VEC_LUCLIQ - VEC_DESFIX - VEC_CUSFIX - VEC_DESDEP - VEC_DESADM

		VEC_DESFIX := 0
		VEC_CUSFIX := 0
		VEC_DESDEP := 0
		VEC_DESADM := 0
		VEC_BALOFI := "O" // Oficina
		If VOI->VOI_SITTPO == "3"
			VEC_DEPVEN := aColsFEC[2,ix1,FS_POSVAR("VO3_DEPINT","aHeaderFEC",2)]
		EndIf
		If VOI->VOI_SITTPO == "2"
			VEC_DEPVEN := aColsFEC[2,ix1,FS_POSVAR("VO3_DEPGAR","aHeaderFEC",2)]
		EndIf
		VEC_NUMOSV := aArrPec[ixi,01]

		nRazIte := VEC_VALBRU / (nTotTTp-M->VSF_DESACE)
		VEC_DESACE := M->VSF_DESACE  * nRazIte
		VEC_VALBRU := VEC_VALBRU + (M->VSF_DESACE*nRazIte)

		VEC_VMFBRU := FG_CALCMF(FG_RETVDCP(cNota,cPrefNF,"S",VEC_VALBRU))
		VEC_VMFVDA := VEC_VMFBRU - FG_CALCMF( {{dDataBase,VEC_VALDES}} )
		VEC_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VEC_VALICM} })
		VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_VALPIS} })
		VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
		VEC_TMFIMP := VEC_VMFICM + VEC_VMFCOF + VEC_VMFPIS

		VEC_CMFMED := FG_CALCMF( { {dDataBase,SB1->B1_CUSTD} }) * VEC_QTDITE
		VEC_JMFEST := FG_CALCMF( { {dDataBase,VEC_JUREST} })
		VEC_CMFTOT := VEC_CMFMED + VEC_JMFEST
		VEC_LMFBRU := VEC_VMFVDA - VEC_TMFIMP - VEC_CMFTOT

		aValCom    := FG_COMISS("P",aVetTra,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"D")
		VEC_CMFVEN := FG_CALCMF(aValCom[1])
		VEC_CMFGER := FG_CALCMF(aValCom[2])
		VEC_DMFVAR := VEC_CMFVEN + VEC_CMFGER
		VEC_LMFLIQ := VEC_LMFBRU - VEC_DMFVAR
		VEC_DMFFIX := 0
		VEC_CMFFIX := 0
		VEC_CMFDEP := 0
		VEC_DMFADM := 0
		VEC_RMFFIN := VEC_LMFLIQ - VEC_DMFFIX - VEC_CMFFIX - VEC_DMFDEP - VEC_DMFADM

		MsUnlock()

		DbSelectArea("VEC")

		If cOsvAnt != aArrPec[ixi,01]

			&& Grava o Numero e Serie da nota no VS1 - Balcao
			DbSelectArea("VS1")
			DbSetOrder(6)
			DbSeek( xFilial("VS1") + cOsvAnt )
			Do While !Eof() .And. VS1->VS1_FILIAL+VS1->VS1_NUMOSV == xFilial("VS1") + cOsvAnt

				If ( Empty(VS1->VS1_NUMNFI) .And. ( Empty(VS1->VS1_TIPTEM) .Or. VS1->VS1_TIPTEM == cParam04 ) )

					If !RecLock("VS1",.f.)
						Help("  ",1,"REGNLOCK")
						lRetFech := .f.
						DisarmTransaction()
						Break
					EndIf

					VS1->VS1_NUMNFI := cNota
					VS1->VS1_SERNFI := cSerie
					MsUnlock()

				EndIf

				DbSelectArea("VS1")
				DbSkip()

			EndDo

			DbSelectArea("VOO")
			DbSetOrder(1)
			If DbSeek( xFilial("VOO") + cOsvAnt + cParam04 )

				If !RecLock("VOO",.f.)
					Help("  ",1,"REGNLOCK")
					lRetFech := .f.
					DisarmTransaction()
					Break
				EndIf

				//        If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
				If !(VOI->VOI_SITTPO == "3" .and. nTotPcs == 0) //so grava VOO_NUMNFI se TT # Interno ou Pecas Interno
					VOO->VOO_NUMNFI := cNota
					VOO->VOO_SERNFI := cSerie
				Endif
				VOO->VOO_TOTPEC := nTotPcs
				VOO->VOO_CONDPG := cTipPag
				If !Empty(cCodCDCI)
					VOO->VOO_CONTCD := cContrato
				EndIf
				MsUnlock()

			EndIf

			nTotPec := 0
			nTotPcs := 0
			cOsvAnt := aArrPec[ixi,01]

		EndIf

		nTotPcs += VEC->VEC_VALVDA

		//Gravacao do VVD (Despesas com Veiculos no Estoque)
		if VOI->VOI_SITTPO == "3" .and. VOI->VOI_DESVEI == "1" //Interno
			if VV1->VV1_SITVEI == "0" //Estoque
				dbSelectArea("VV5")
				dbSetOrder(1)
				if !dbSeek(xFilial("VV5")+VEC->VEC_GRUITE+VEC->VEC_CODITE)
					dbSelectArea("SB1")
					dbSetOrder(7)
					dbSeek(xFilial("SB1")+VEC->VEC_GRUITE+VEC->VEC_CODITE)
					RecLock("VV5",.t.)
					VV5->VV5_FILIAL := xFilial("VV5")
					VV5->VV5_TIPOPE := "1"
					VV5->VV5_CODIGO := VEC->VEC_GRUITE+VEC->VEC_CODITE
					VV5->VV5_DESCRI := SB1->B1_DESC
					MsUnlock()
				Endif
				dbSelectArea("VVD")
				RecLock("VVD",.t.)
				VVD->VVD_FILIAL := xFilial("VVD")
				VVD->VVD_TIPOPE := "0" //Despesa
				VVD->VVD_TRACPA := VV1->VV1_TRACPA
				VVD->VVD_CHAINT := VV1->VV1_CHAINT
				VVD->VVD_DATADR := dDataBase
				VVD->VVD_DATVEN := dDataBase
				VVD->VVD_CODFOR := ""
				VVD->VVD_LOJA   := ""
				VVD->VVD_CODCLI := ""
				VVD->VVD_LOJACL := ""
				VVD->VVD_NUMNFI := VEC->VEC_NUMNFI
				VVD->VVD_SERNFI := VEC->VEC_SERNFI
				VVD->VVD_NUMTIT := ""
				VVD->VVD_TIPTIT := ""
				VVD->VVD_NATURE := ""
				VVD->VVD_NUMOSV := VEC->VEC_NUMOSV
				VVD->VVD_CODIGO := VV5->VV5_CODIGO
				VVD->VVD_VALOR  := VEC->VEC_VALVDA
				VVD->VVD_ATUCUS := "0"
				MsUnlock()
			Endif
		Endif

		If !FS_PREVF3("P")
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

	Next

	DbSelectArea("VOO")
	DbSetOrder(1)
	If DbSeek( xFilial("VOO") + cOsvAnt + cParam04 )

		If !RecLock("VOO",.f.)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

		//    If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
		If !(VOI->VOI_SITTPO == "3" .and. nTotPcs == 0) //so grava VOO_NUMNFI se TT # Interno ou Pecas Interno
			VOO->VOO_NUMNFI := cNota
			VOO->VOO_SERNFI := cSerie
		Endif
		VOO->VOO_TOTPEC := nTotPcs

		MsUnlock()

	EndIf

EndIf

cComCon := FS_COMCON(cParam04)
aVetTra := {}

cKeyAce := cParam02+cParam03
FG_SEEK("SA1","cKeyAce")

If len(aVetMec) > 0

	aSort(aVetMec,1,,{ |x,y| x[1] < y[1]})  // Ordena por Ordem de Servico

	cOsvAnt := aVetMec[1,1]

	For ixa := 1 to Len(aVetMec)

		cKeyAce := aVetMec[ixa,01]
		FG_SEEK("VO1","cKeyAce",1,.f.)
		FG_SEEK("VV1","VO1->VO1_CHAINT",1,.f.)
		FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
		FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
		FG_SEEK("VE4","VO1->VO1_CODMAR",1,.f.)
		FG_SEEK("VOI","VE4->VE4_TEMINT",1,.f.)

		nVlrInt := VOI->VOI_VALHOR

		cKeyAce := cParam04
		FG_SEEK("VOI","cKeyAce",1,.f.)

		If !FS_VFBSRV(VV1->VV1_PROATU,VV1->VV1_LJPATU,VV1->VV1_CHAINT,VO1->VO1_NUMOSV,,,"",cParam04,)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

		dbSelectArea("VO4")
		dbGoTo(aVetMec[ixa,19])

		If !RecLock("VO4",.f.)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

		&& Levanta o valor da hora interna
		VO2->(DbSetOrder(2))
		VO2->(DbSeek(xFilial("VO2")+VO4->VO4_NOSNUM))
		nVlrInt := FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)

		cKeyAce := aVetMec[ixa,02]
		FG_SEEK("VOK","cKeyAce",1,.f.)
		FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
		cKeyAce := FG_MARSRV(VO1->VO1_CODMAR,aVetMec[ixa,03])+aVetMec[ixa,03]

		nAliIssP := FM_SQL("SELECT SFT.FT_ALIQICM FROM "+RetSqlName("SFT")+" SFT WHERE SFT.FT_FILIAL = '"+xFilial("SFT")+"'"+;
		" AND SFT.FT_NFISCAL = '"+cNota+"' AND SFT.FT_SERIE = '"+cSerie+"' AND SFT.FT_CLIEFOR = '"+SA1->A1_COD+"' AND SFT.FT_LOJA = '"+SA1->A1_LOJA+"'"+;
		" AND SFT.FT_PRODUTO = '"+SB1->B1_COD+"' AND SFT.D_E_L_E_T_=' '") / 100
		If nAliIssP <> 0
		   nAliIss := nAliIssP
		Endif

		//		cKeyAce := VO1->VO1_CODMAR+aVetMec[ixa,03]
		FG_SEEK("VO6","cKeyAce",2,.f.)

		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+VOI->VOI_CODTES))

		Do Case
			Case VOK->VOK_INCTEM $ "124"

				VO4->VO4_TEMVEN := VO4->VO4_TEMPAD
				VO4->VO4_TEMCOB := aVetMec[ixa,20]

			Case VOK->VOK_INCTEM == "3"

				VO4->VO4_TEMVEN := VO4->VO4_TEMTRA
				VO4->VO4_TEMCOB := VO4->VO4_TEMTRA

		EndCase

		If VOI->VOI_SITTPO == "3"            // Tipo de Tempo Interno
			If VOK->VOK_INCMOB $ "1/3/4"
				If VOK->VOK_INCTEM $ "1/2/3/4" // Fabrica/Concessionaria/Informado/Trabalhado
					// Verifica se foi alterado o valor na negociacao
					VZ1->(dbSetOrder(2))
					If VZ1->(dbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV+VOI->VOI_TIPTEM+"S"+strzero(cParam01,1)+VO4->VO4_TIPSER+VO4->VO4_GRUSER+VO4->VO4_CODSER)) .and. (VZ1->VZ1_VALBRU - VZ1->VZ1_VALDES <> 0)
						nVlrInt := VZ1->VZ1_VALBRU - VZ1->VZ1_VALDES
						VO4->VO4_VALINT := nVlrInt * aVetMec[ixa,10]
					Else
						VO4->VO4_VALINT := (nVlrInt * (aVetMec[ixa,05]/100)) * aVetMec[ixa,10]
					endif
					//
				EndIf
			ElseIf VOK->VOK_INCMOB == "2" // Servicos de Terceiros
				VO4->VO4_VALINT := VO4->VO4_VALCUS
			EndIf
			If VOK->VOK_INCMOB == "5"
			EndIf
		EndIf
		MsUnlock()
		ix1 := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] == aVetMec[ixa,03] } )

		DbSelectArea("VSC")

		If !RecLock("VSC",.t.)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

		VSC_FILIAL := xFilial("VSC")
		VSC_NUMIDE := GetSXENum("VSC","VSC_NUMIDE")
		ConfirmSx8()
		VSC_NUMOSV := aVetMec[ixa,01]
		VSC_MODVEI := VV1->VV1_MODVEI
		VSC_CODSER := aVetMec[ixa,03]
		VSC_TIPSER := aVetMec[ixa,02]
		VSC_TIPTEM := cParam04
		//VSC_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
		VSC_TEMPAD := aVetMec[ixa,05]
		VSC_TEMTRA := aVetMec[ixa,06]
		VSC_TEMCOB := VO4->VO4_TEMCOB
		VSC_TEMVEN := VO4->VO4_TEMVEN
		VSC_GRUSER := aColsFEC[4,ix1,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]
		VSC_CODPRO := aVetMec[ixa,04]
		VSC_CODSEC := VO4->VO4_CODSEC
		VSC_DATVEN := dDataBase

		If VSC->(FieldPos("VSC_LIBVOO")) <> 0
			VOO->(dbSetOrder(1))
			If VOO->(dbSeek( xFilial("VOO") + aVetMec[ixa,01] + cParam04 ))
				VSC->VSC_LIBVOO := VOO->VOO_LIBVOO
			EndIf
		EndIf

		aVetTra := {}
		If VOK->VOK_INCMOB != "2"
			aAdd(aVetTra,{aVetMec[ixa,04],0})
		EndIf

		Do Case
			Case cComCon == "1"
				aAdd(aVetTra,{VO1->VO1_FUNABE,0})
			Case cComCon == "2"
				nRegVAI := VAI->(RecNo())
				cKeyAce := __cUserID
				FG_SEEK("VAI","cKeyAce",4,.f.)
				aAdd(aVetTra,{VAI->VAI_CODTEC,0})
				VAI->(DbGoTo(nRegVAI))
			Case cComCon == "3"
				aAdd(aVetTra,{VO1->VO1_FUNABE,0})
				nRegVAI := VAI->(RecNo())
				cKeyAce := __cUserID
				FG_SEEK("VAI","cKeyAce",4,.f.)
				aAdd(aVetTra,{VAI->VAI_CODTEC,0})
				VAI->(DbGoTo(nRegVAI))
		EndCase

		If VOI->VOI_SITTPO == "3"            // Tipo de Tempo Interno

			Do Case
				Case VOK->VOK_INCMOB == "0"    // Mao-de-Obra Gratuita

					VSC_VALBRU := 0
					VSC_VALDES := 0
					VSC_VALSER := 0
					VSC_CUSSER := 0 //FS_CUSDIR(VSC_CODPRO,dDataBase - 30,VSC_TEMTRA) + FS_CUSIND(dDataBase - 30,VSC_TEMTRA)
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VO4->VO4_VALINT,"T",VSC_NUMIDE)
					VSC_COMVEN := aValCom[1]
					VSC_COMGER := aValCom[2]
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VO4->VO4_VALINT,"D",VSC_NUMIDE)
					VSC_CMFVEN := FG_CALCMF(aValCom[1])
					VSC_CMFGER := FG_CALCMF(aValCom[2])

				Case VOK->VOK_INCMOB == "1"    // Por Mao-de-Obra

					// Para Tipo de Tempo Interno a comissao sera paga apenas para o mecanico
					// Podendo ser alterado para os demais no futuro
					VSC_VALBRU := 0
					VSC_VALDES := 0
					VSC_VALSER := 0
					VSC_CUSSER := 0 //FS_CUSDIR(VSC_CODPRO,dDataBase - 30,VSC_TEMTRA) + FS_CUSIND(dDataBase - 30,VSC_TEMTRA)
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VO4->VO4_VALINT,"T",VSC_NUMIDE)
					VSC_COMVEN := aValCom[1]
					VSC_COMGER := aValCom[2]
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VO4->VO4_VALINT,"D",VSC_NUMIDE)
					VSC_CMFVEN := FG_CALCMF(aValCom[1])
					VSC_CMFGER := FG_CALCMF(aValCom[2])

				Case VOK->VOK_INCMOB == "2"    // Nao pagar comissao para servico de terceiro em OS Interna

					VSC_VALBRU := 0
					VSC_VALDES := 0
					VSC_VALSER := 0
					VSC_CUSSER := VO4->VO4_VALCUS
					aVetTra := {}

				Case VOK->VOK_INCMOB == "3"    // Valor Livre com Base na Tabela

					// Para Tipo de Tempo Interno a comissao sera paga apenas para o mecanico
					// Podendo ser alterado para os demais no futuro
					VSC_VALBRU := 0
					VSC_VALDES := 0
					VSC_VALSER := 0
					VSC_CUSSER := 0 //FS_CUSDIR(VSC_CODPRO,dDataBase - 30,VSZ_TEMTRA) + FS_CUSIND(dDataBase - 30,VSC_TEMTRA)
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VO4->VO4_VALINT,"T",VSC_NUMIDE)
					VSC_COMVEN := aValCom[1]
					VSC_COMGER := aValCom[2]
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VO4->VO4_VALINT,"D",VSC_NUMIDE)
					VSC_CMFVEN := FG_CALCMF(aValCom[1])
					VSC_CMFGER := FG_CALCMF(aValCom[2])

				Case VOK->VOK_INCMOB == "4"  // Re-Servico, tirara comissao do executor inicial e atribuira para o executor deste momento
					// Aqui o sistema podera gerar comissao negativa para o mecanico que executou o servico com defeito e
					// transferir a comissao para o mecanico que esta executando o re-servico

				Case VOK->VOK_INCMOB == "5"  // Socorro

					VSC_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]

			EndCase

		Else             // Tipo de Tempo NAO Interno

			Do Case
				Case VOK->VOK_INCMOB == "0"    // Mao-de-Obra Gratuita

					VSC_VALBRU := 0
					VSC_VALDES := 0
					VSC_VALSER := 0
					VSC_CUSSER := 0 //FS_CUSDIR(VSC_CODPRO,dDataBase - 30,VSC_TEMTRA) + FS_CUSIND(dDataBase - 30,VSC_TEMTRA)
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VO4->VO4_VALINT,"T",VSC_NUMIDE)
					VSC_COMVEN := aValCom[1]
					VSC_COMGER := aValCom[2]
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VO4->VO4_VALINT,"D",VSC_NUMIDE)
					VSC_CMFVEN := FG_CALCMF(aValCom[1])
					VSC_CMFGER := FG_CALCMF(aValCom[2])

				Case VOK->VOK_INCMOB == "1"    // Por Mao-de-Obra

					VSC_VALBRU := aVetMec[ixa,14]
					VSC_VALDES := aVetMec[ixa,14] - aVetMec[ixa,15]
					VSC_VALSER := aVetMec[ixa,15]
					VSC_CUSSER := 0 //FS_CUSDIR(VSC_CODPRO,dDataBase - 30,VSC_TEMTRA) + FS_CUSIND(dDataBase - 30,VSC_TEMTRA)
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"T",VSC_NUMIDE)
					VSC_COMVEN := aValCom[1]
					VSC_COMGER := aValCom[2]
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"D",VSC_NUMIDE)
					VSC_CMFVEN := FG_CALCMF(aValCom[1])
					VSC_CMFGER := FG_CALCMF(aValCom[2])

				Case VOK->VOK_INCMOB == "2"    // Servico de Terceiro

					VSC_VALBRU := aVetMec[ixa,14]
					VSC_VALDES := aVetMec[ixa,14] - aVetMec[ixa,15]
					VSC_VALSER := aVetMec[ixa,15]
					VSC_CUSSER := VO4->VO4_VALCUS
					If VOK->VOK_CMSR3R == "1" // Pagar comissao sobre Servico de Terceiro
						aValCom    := FG_COMISS("S",aVetTra,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"T",VSC_NUMIDE)
						VSC_COMVEN := aValCom[1]
						VSC_COMGER := aValCom[2]
						aValCom    := FG_COMISS("S",aVetTra,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"D",VSC_NUMIDE)
						VSC_CMFVEN := FG_CALCMF(aValCom[1])
						VSC_CMFGER := FG_CALCMF(aValCom[2])
					EndIf

				Case VOK->VOK_INCMOB == "3"    // Valor Livre com Base na Tabela

					VSC_VALBRU := aVetMec[ixa,14]
					VSC_VALDES := aVetMec[ixa,14] - aVetMec[ixa,15]
					VSC_VALSER := aVetMec[ixa,15]   // Se for interno este valor sera zero
					VSC_CUSSER := 0 //FS_CUSDIR(VSC_CODPRO,dDataBase - 30,VSC_TEMTRA) + FS_CUSIND(dDataBase - 30,VSC_TEMTRA)
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"T",VSC_NUMIDE)
					VSC_COMVEN := aValCom[1]
					VSC_COMGER := aValCom[2]
					aValCom    := FG_COMISS("S",VSC_CODPRO,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"D",VSC_NUMIDE)
					VSC_CMFVEN := FG_CALCMF(aValCom[1])
					VSC_CMFGER := FG_CALCMF(aValCom[2])

				Case VOK->VOK_INCMOB == "4"  // Re-Servico, tirara comissao do executor inicial e atribuira para o executor deste momento
					// Aqui o sistema podera gerar comissao negativa para o mecanico que executou o servico com defeito e
					// transferir a comissao para o mecanico que esta executando o re-servico

				Case VOK->VOK_INCMOB == "5"  // Socorro

//					VSC_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
					If VOI->VOI_TPOKLM == "S"
						VSC_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
					Else
						VSC_KILROD := aColsFEC[4,ix1,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
						VSC_VALBRU := aVetMec[ixa,14]
						VSC_VALDES := aVetMec[ixa,14] - aVetMec[ixa,15]
						VSC_VALSER := aVetMec[ixa,15]
						If VOK->VOK_CMSR3R == "1" // Pagar comissao sobre Servico de Terceiro
							aValCom    := FG_COMISS("S",aVetTra,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"T",VSC_NUMIDE)
							VSC_COMVEN := aValCom[1]
							VSC_COMGER := aValCom[2]
							aValCom    := FG_COMISS("S",aVetTra,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"D",VSC_NUMIDE)
							VSC_CMFVEN := FG_CALCMF(aValCom[1])
							VSC_CMFGER := FG_CALCMF(aValCom[2])
						EndIf
					Endif

			EndCase

		EndIf

		aPisCof := CalcPisCofSai(Vsc->Vsc_ValSer)

		VSC_VALISS := VSC_VALSER * nAliIss
		VSC_VALPIS := aPisCof[1,1] //VSC_VALSER * nAliPis
		VSC_VALCOF := aPisCof[1,2] //VSC_VALSER * nAliCof

		VSC_TOTIMP := VSC_VALISS + VSC_VALCOF + VSC_VALPIS

		VSC_RECLIQ := 0
		VSC_CUSTOT := VSC_CUSSER

		// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
		VSC->VSC_LUCBRU := VSC->VSC_VALSER - VSC->VSC_TOTIMP - VSC->VSC_CUSTOT
		VSC->VSC_LUCLIQ := VSC->VSC_LUCBRU - VSC->VSC_DESVAR - VSC->VSC_DESFIX - VSC->VSC_DESDEP - VSC->VSC_DESADM //LUCRO MARGINAL
		VSC->VSC_RESFIN := VSC->VSC_LUCLIQ - VSC->VSC_CUSFIX //LAIR
		//		VSC_LUCBRU := VSC_VALSER - VSC_TOTIMP - VSC_CUSTOT
		//		VSC_LUCLIQ := VSC_LUCBRU - VSC_DESVAR
		//		VSC_RESFIN := VSC_LUCLIQ - VSC_CUSFIX - VSC_DESFIX - VSC_DESADM - VSC_DESDEP

		VSC_DESVAR := VSC_COMVEN + VSC_COMGER

		VSC_DESFIX := 0
		VSC_CUSFIX := 0
		VSC_DESADM := 0
		VSC_DESDEP := 0
		If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
			VSC_NUMNFI := cNota
			VSC_SERNFI := cSerie
		Endif
		VSC_CODMAR := VO1->VO1_CODMAR

		FG_SEEK("VO6","FG_MARSRV(VSC->VSC_CODMAR,VSC->VSC_CODSER)+VSC->VSC_CODSER",2,.f.)
		//		FG_SEEK("VO6","VSC->VSC_CODMAR+VSC->VSC_CODSER",2,.f.)

		VSC_SERINT := VO6->VO6_SERINT
		VSC_SERNFI := cSerie
		VSC_RECVO4 := StrZero(aVetMec[ixa,19],9)

		// Gravacao da Despesa Acessoria apenas para os Registros do VSC referentes ao registro do SD2 onde a Despesa foi Gravada
		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1")+VOK->VOK_GRUITE+VOK->VOK_CODITE))
		SB1->(dbSetOrder(1))
		SD2->(dbSetOrder(3))
		SD2->(dbSeek(xFilial("SD2")+VSC->VSC_NUMNFI+VSC->VSC_SERNFI+SA1->A1_COD+SA1->A1_LOJA+SB1->B1_COD))
		SD2->(dbSetOrder(1))
		nRazIte  := VSC->VSC_VALSER / (SD2->D2_TOTAL)
		VSC_VALBRU := VSC_VALBRU + (SD2->D2_DESPESA*nRazIte)
		VSC_VMFBRU := FG_CALCMF(FG_RETVDCP(cNota,cPrefNF,"S",VSC_VALBRU))
		VSC_DESACE := (SD2->D2_DESPESA*nRazIte)
		//

		VSC_VMFSER := VSC_VMFBRU - FG_CALCMF({{dDataBase,VSC_VALDES}} )
		VSC_VMFISS := FG_CALCMF({{FG_RTDTIMP("ISS",dDataBase),VSC_VALISS}})
		VSC_VMFPIS := FG_CALCMF({{FG_RTDTIMP("PIS",dDataBase),VSC_VALPIS}})
		VSC_VMFCOF := FG_CALCMF({{FG_RTDTIMP("COF",dDataBase),VSC_VALCOF}})

		VSC_TMFIMP := VSC_VMFPIS + VSC_VMFISS + VSC_VMFCOF
		VSC_CMFSER := FG_CALCMF( { {dDataBase,VSC_CUSSER} })
		VSC_CMFTOT := VSC_CMFSER
		VSC_LMFBRU := VSC_VMFSER - VSC_TMFIMP - VSC_CMFTOT

		VSC_DMFVAR := VSC_CMFVEN + VSC_CMFGER
		VSC_LMFLIQ := VSC_LMFBRU - VSC_DMFVAR
		VSC_CMFFIX := 0
		VSC_DMFFIX := 0
		VSC_DMFADM := 0
		VSC_DMFDEP := 0
		VSC_RMFFIN := VSC_LMFLIQ - VSC_CMFFIX - VSC_DMFFIX - VSC_DMFADM - VSC_DMFDEP
		VSC_DEPINT := VO4->VO4_DEPINT
		VSC_DEPGAR := VO4->VO4_DEPGAR

		MsUnlock()

		If cOsvAnt != aVetMec[ixa,1]

			DbSelectArea("VOO")
			DbSetOrder(1)
			If DbSeek( xFilial("VOO") + cOsvAnt + cParam04 )

				If !RecLock("VOO",.f.)
					Help("  ",1,"REGNLOCK")
					lRetFech := .f.
					DisarmTransaction()
					Break
				EndIf

				If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
					VOO->VOO_NUMNFI := cNota
					VOO->VOO_SERNFI := cSerie
				Endif
				VOO->VOO_TOTSRV := nTotSer
				MsUnlock()

			EndIf

			nTotSer          :=0
			cOSvAnt          := aVetMec[ixa,1]

		EndIf

		nTotSer += VSC->VSC_VALSER

		//Gravacao do VVD (Despesas com Veiculos no Estoque)

		if VOI->VOI_SITTPO == "3" .and. VOI->VOI_DESVEI == "1" //Interno
			if VV1->VV1_SITVEI == "0" //Estoque
				dbSelectArea("VV5")
				dbSetOrder(1)
				if !dbSeek(xFilial("VV5")+VSC->VSC_GRUSER+VSC->VSC_CODSER)
					dbSelectArea("SB1")
					dbSetOrder(7)
					dbSeek(xFilial("SB1")+VSC->VSC_GRUSER+VSC->VSC_CODSER)
					RecLock("VV5",.t.)
					VV5->VV5_FILIAL := xFilial("VV5")
					VV5->VV5_TIPOPE := "1"
					VV5->VV5_CODIGO := VSC->VSC_GRUSER+VSC->VSC_CODSER
					VV5->VV5_DESCRI := SB1->B1_DESC
					MsUnlock()
				Endif
				dbSelectArea("VVD")
				RecLock("VVD",.t.)
				VVD->VVD_FILIAL := xFilial("VVD")
				VVD->VVD_TIPOPE := "0" //Despesa
				VVD->VVD_TRACPA := VV1->VV1_TRACPA
				VVD->VVD_CHAINT := VV1->VV1_CHAINT
				VVD->VVD_DATADR := dDataBase
				VVD->VVD_DATVEN := dDataBase
				VVD->VVD_CODFOR := ""
				VVD->VVD_LOJA   := ""
				VVD->VVD_CODCLI := ""
				VVD->VVD_LOJACL := ""
				VVD->VVD_NUMNFI := VSC->VSC_NUMNFI
				VVD->VVD_SERNFI := VSC->VSC_SERNFI
				VVD->VVD_NUMTIT := ""
				VVD->VVD_TIPTIT := ""
				VVD->VVD_NATURE := ""
				VVD->VVD_NUMOSV := VSC->VSC_NUMOSV
				VVD->VVD_CODIGO := VV5->VV5_CODIGO
				VVD->VVD_VALOR  := VO4->VO4_VALINT // VSC->VSC_VALSER
				VVD->VVD_ATUCUS := "0"
				MsUnlock()
			Endif
		Endif

		FS_CONCOR()

		If !FS_PREVF3("S",nVlrInt)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

	Next

	DbSelectArea("VOO")
	DbSetOrder(1)
	If DbSeek( xFilial("VOO") + cOsvAnt + cParam04 )

		If !RecLock("VOO",.f.)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf

		If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
			VOO->VOO_NUMNFI := cNota
			VOO->VOO_SERNFI := cSerie
		Endif
		VOO->VOO_TOTSRV := nTotSer
		MsUnlock()

	EndIf

EndIf

For i := 1 to len(aVetOsv)

	cKeyAce := aVetOsv[i,1]
	FG_SEEK("VO1","cKeyAce",1,.f.)

	//Grava Fechamento nas Requisicoes

	dbSelectArea("VO2")
	DbSetOrder(1)

	If FG_SEEK("VO2","VO1->VO1_NUMOSV",1,.f.)

		While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. VO2->VO2_FILIAL == xFilial("VO2") .and. !eof()

			If VO2->VO2_TIPREQ == "P"     // Requisicao de Pecas

				dbSelectArea("VO3")
				DbSetOrder(1)

				If FG_SEEK("VO3","VO2->VO2_NOSNUM",1,.f.)

					nRegVAI := VAI->(RecNo())
					cKeyAce := __cUserID
					FG_SEEK("VAI","cKeyAce",4,.f.)

					While VO2->VO2_NOSNUM == VO3->VO3_NOSNUM .and. VO3->VO3_FILIAL == xFilial("VO3") .and. !eof()

						If cParam04 != VO3->VO3_TIPTEM
							dbSkip()
							Loop
						EndIf

						cTES := VO3->VO3_CODTES
						cQuery := "SELECT SD2.D2_TES FROM "+RetSqlName("SB1")+" SB1 "
						cQuery += "INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC='"+cNota+"' AND SD2.D2_SERIE='"+cSerie+"' AND SD2.D2_COD=SB1.B1_COD AND SD2.D_E_L_E_T_=' ' "
						cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+VO3->VO3_GRUITE+"' AND SB1.B1_CODITE='"+VO3->VO3_CODITE+"' AND SB1.D_E_L_E_T_=' ' "
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlTES, .F., .T. )
						If !( cQAlTES )->( Eof() )
							cTES := ( cQAlTES )->( D2_TES )
						EndIf
						( cQAlTES )->( dbCloseArea() )
						DbSelectArea("VO3")
						If !RecLock("VO3",.f.)
							Help("  ",1,"REGNLOCK")
							lRetFech := .f.
							DisarmTransaction()
							Break
						EndIf
						VO3->VO3_NUMNFI := cNota
						VO3->VO3_SERNFI := cSerie
						// Data de fechamento sera gravada no momento da finalizacao
						// do ORCAMENTO no SIGALOJA por integracao
						If !lIntegLoja .or. !Empty(cNota)
							VO3->VO3_DATFEC := dDataBase
							VO3->VO3_HORFEC := val(left(time(),2)+substr(time(),4,2))
						EndIf
						VO3->VO3_FUNFEC := VAI->VAI_CODTEC
						VO3->VO3_CODTES := cTES
						MsUnlock()
						If !FS_VFBPEC(cParam02,cParam03,VO1->VO1_CHAINT,cParam04,VO1->VO1_NUMOSV)
							Help("  ",1,"REGNLOCK")
							lRetFech := .f.
							DisarmTransaction()
							Break
						EndIf

						dbSelectArea("VO3")
						dbSkip()

					EndDo

					VAI->(DbGoTo(nRegVAI))

				EndIf

			Else

				dbSelectArea("VO4")
				dbSetOrder(1)

				If FG_SEEK("VO4","VO2->VO2_NOSNUM",1,.f.)

					nRegVAI := VAI->(RecNo())
					cKeyAce := __cUserID
					FG_SEEK("VAI","cKeyAce",4,.f.)

					While VO2->VO2_NOSNUM == VO4->VO4_NOSNUM .and. VO4->VO4_FILIAL == xFilial("VO4") .and. !eof()

						If cParam04 != VO4->VO4_TIPTEM
							dbSkip()
							Loop
						EndIf

						FG_SEEK("VOK","VO4->VO4_TIPSER",1,.f.)

						If !RecLock("VO4",.f.)
							Help("  ",1,"REGNLOCK")
							lRetFech := .f.
							DisarmTransaction()
							Break
						EndIf

						If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
							VO4->VO4_NUMNFI := cNota
							VO4->VO4_SERNFI := cSerie
							// Data de fechamento sera gravada no momento da finalizacao
							// do ORCAMENTO no SIGALOJA por integracao
							If !lIntegLoja
								VO4->VO4_DATFEC := dDataBase
								VO4->VO4_HORFEC := val(left(time(),2)+substr(time(),4,2))
							Endif
							//
						Else
							VO4->VO4_DATFEC := dDataBase
							VO4->VO4_HORFEC := val(left(time(),2)+substr(time(),4,2))
						Endif
						VO4->VO4_FUNFEC := VAI->VAI_CODTEC
						MsUnlock()

						If !Empty(VO4->VO4_CODPRO)
							FS_HABPRO()
						EndIf

						dbSelectArea("VO4")
						dbSkip()

					EndDo

					VAI->(DbGoTo(nRegVAI))

				EndIf

			EndIf

			dbSelectArea("VO2")
			dbSkip()

		EndDo

	EndIf

	If !RecLock("VO1",.f.)
		Help("  ",1,"REGNLOCK")
		lRetFech := .f.
		DisarmTransaction()
		Break
	EndIf

	VO1->VO1_TEMFEC := "S"
	// So atualiza o Status da OS, quando não estiver integrado com o SIGALOJA,
	// pois do contrario a atualizacao sera feita no fechamento do Orcamento no Loja
	If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"
		VO1->VO1_TEMLIB := FS_STATUS(VO1->VO1_NUMOSV,cParam04,"D")
		VO1->VO1_STATUS := FS_STATUS(VO1->VO1_NUMOSV,cParam04,"F")
	EndIf
	MSUnlock()

	// tratamento de controle de status de veiculos soh se estiver abrindo OS para um veiculo que esta no estoque
	If VO1->VO1_STATUS == "F" // somente para fechamento total da OS
		VV1->(DbsetOrder(1))
		VV1->(Dbseek(xFilial("VV1")+VO1->VO1_CHAINT))
		If FG_STATUS(,"X") .and. VV1->VV1_SITVEI $ "0 "
			FG_STATUS(VO1->VO1_CHAINT,"O")
		Endif
		If FindFunction("OM350STATUS")
		    if VS1->(FieldPos("VS1_NUMAGE")) # 0
		    	cQuery := "SELECT VS1.VS1_NUMAGE FROM "+RetSqlName("VS1")+" VS1 WHERE "
				cQuery += "VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_NUMOSV='"+VO1->VO1_NUMOSV+"' AND VS1.VS1_NUMAGE<>' ' AND VS1.D_E_L_E_T_=' ' "
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVS1, .F., .T. )
				While !( cQAlVS1 )->( Eof() )
					OM350STATUS(( cQAlVS1 )->( VS1_NUMAGE ),"1","3") // Finaliza Agendamento
					( cQAlVS1 )->( DbSkip() )
				EndDo
				( cQAlVS1 )->( dbCloseArea() )
				DbSelectArea("VO1")
			Endif
		EndIf
	Endif

	//   if VOI->VOI_SITTPO == "3" .and. nTotPec <= 0  // Interno
	//      FS_GRNFINT()
	//   Endif

	FS_IMPGAR(VO1->VO1_NUMOSV)

	&& Grava o Custo do veiculo em estoque
	VV1->(DbSetOrder(1))
	VV1->(DbSeek( xFilial("VV1") + VO1->VO1_CHAINT ))

	FS_160CUSVEI("0",VOI->VOI_TIPTEM,VV1->VV1_TRACPA,VV1->VV1_CHAINT,VO1->VO1_NUMOSV,cNota,cSerie,nTotTTp)

Next

oFolderFEC:nOption := 1

Return .t.


//////////////////////
Function FS_IMPDOC2()
Local ixi := 0

If cPaisLoc == "BRA" // Manoel - 12/05/2009

	If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"	//nao Integrado com o Sigaloja ?

		IncProc(STR0008) //"Emitindo NF / Bloqueto / Ordem de Servico "

		If ( VOI->VOI_SITTPO != "3" .Or. ( Type("nTotPec") # "U" .And. nTotPec > 0 ) )

			If ExistBlock("NFPECSER")       // Emissao da Nota Fiscal
				ExecBlock("NFPECSER",.f.,.f.,{cNota,cSerie})
			EndIf

		EndIf

		If !Empty(aIteParc[1,1])
			DbSelectArea("SF2")
			DbSetOrder(1)
			DbSeek(xFilial("SF2")+cNota+cSerie)
			cObs1 := ""
			cObs2 := ""
			cObs3 := ""
			DbSelectArea("SA6")
			DbSetOrder(1)
			If DbSeek(xFilial("SA6")+cCodBco)
				if SA6->A6_BORD $ "1S"
					If ExistBlock("BLQCOB")      // Emissao do Bloqueto Bancario
						ExecBlock("BLQCOB",.f.,.f.,{cNota,,,,SF2->F2_PREFIXO,"1",cObs1,cObs2,cObs3,cCodBco})
					EndIf
				Endif
			Endif

			If !Empty(cCodCDCI)                    // Emissao de Contrato de CDCI
				If ExistBlock("CONTCDCI")
					ExecBlock("CONTCDCI",.f.,.f.,{SEM->EM_CONTRAT})     // Ponto de Entrada de Emissao de Contrato de CDCI
				Endif
			EndIf
		EndIf

		IncProc(STR0009) //"Finalizando ... "

		For ixi := 1 To Len(aVetOSv)
			FG_PEDORD(aVetOSv[ixi,1],"E",cParam04)
			FG_PEDREL(aVetOSv[ixi,1],cParam04,"E")

			If ExistBlock("RELPECE")
				ExecBlock("RELPECE",.f.,.f.,{aVetOSv[ixi,1],aVetOSv[ixi,2],"F"})  // Numero da OS/Tipo de Tempo/Emitido pelo Fechamento
			EndIf

		Next
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INTLJC ³ Autor ³Valdir F. Silva        ³ Data ³ 29/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faz integracao da venda balcao c/ o sigaloja				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Siga Veiculos (Modulo de Oficina/Pecas)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INTLJC()

Local cCFiscal
Local aCabPV  := Array(30)
Local aItePV  := {}
Local aPagPV  := {}
Local nX      := 0
Local nTotPec := 0
Local nTotSrv := 0
Local cClipad := ""
Local cLojPad := ""

IncProc( STR0010 )  //Gravando Orcamento p/ Caixa

aCabPV[01] := SA1->A1_COD            //Codigo do cliente
aCabPV[02] := SA1->A1_LOJA           //Loja para entrada
aCabPV[03] := VAI->VAI_CODVEN        //Codigo do vendedor
aCabPV[04] := dDataBase+30           //Data de emissao
aCabPV[05] := MaFisRet(,"NF_VALICM") //Valor do ICMS
aCabPV[06] := MaFisRet(,"NF_VALISS") //Valor do ISS
aCabPV[07] := 0                      //Valor do IPI
aCabPV[08] := 0                      //Valor do Desconto
aCabPV[09] := nTotTTP                //MaFisRet(,"NF_TOTAL")  //Valor Liquido(Total-Desconto)
aCabPV[10] := "2"                    //Quem esta gravando
aCabPV[11] := VOO->VOO_NUMOSV+VOO->VOO_TIPTEM        //Chave a pesquisar
//aCabPV[12] := cTipPag // Nao envia forma de pagamento, pois no cancelamento ocorria problema e cancelava a OS no Oficina
if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
endif
//If (SA1->A1_PESSOA == "J" .or. SA1->A1_PESSOA == "F" ) .and. !Empty(SA1->A1_INSCR) .and. VAM->VAM_ESTADO <> GETMV("MV_ESTADO") .AND. VOI->VOI_SITTPO <> "2"
//	cCliPad := GetMv("MV_CLIPAD")
//	cLojPad := GetMv("MV_LOJAPAD")
//Endif
//aCabPV[13] := cClipad        //Chave a pesquisar
//aCabPV[14] := cLojPad
aCabPV[15] := 0
aCabPV[16] := 0
aCabPV[17] := M->VSF_DESACE
aCabPV[18] := ddatabase
// grava campos faltantes...Thiago
aCabPV[19] :=  nTotEntr			// L1_ENTRADA - valor da entrada
aCabPV[20] :=  1				// L1_PARCELA - valor da parcela
aCabPV[21] :=  MaFisRet(,"NF_VALICM")	// L1_VALICM - valor do icm
aCabPV[22] :=  cTipPag			// L1_FORMPG - forma de pagto
aCabPV[23] := 0 				// L1_VLRDEBI - valor do cartao de debito
aCabPV[24] :=  time()			// L1_HORA - hora
aCabPV[25] :=  "0"				// L1_TIPODES - tipo de desconto (grava 0 ?)
aCabPV[26] :=  cEstacao			// L1_ESTACAO
aCabPV[27] :=  "" //Codigo do 2o vendedor
aCabPV[28] :=  "" //Codigo do 3o vendedor
aCabPV[29] :=  MaFisRet(,"NF_BASESOL")
aCabPV[30] :=  MaFisRet(,"NF_VALSOL")

//Pecas
For nX := 1 to Len(aColsFEC[2])

	If Empty(aColsFEC[2,nX,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
		Loop
	EndIf

	Aadd(aItePV,Array(29))

	cKeyAce      := aColsFEC[2,nX,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,nX,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
	//FG_SEEK("SB1","cKeyAce",7,.f.)
	//FG_SEEK("SB5","SB1->B1_COD")
	//FG_SEEK("SB2","SB1->B1_COD")
	//FG_SEEK("SF4","SB1->B1_TS")
	//FG_SEEK("VE4","VO1->VO1_CODMAR",1,.f.)

	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1")+cKeyAce))

	SB5->(dbSetOrder(1))
	SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))

	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD))

	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+aColsFEC[2,nX,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] ))

	cOrigB1 := Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB

	VE4->(dbSetOrder(1))
	VE4->(dbSeek(xFilial("VE4")+VO1->VO1_CODMAR))

	cCFiscal := FG_CLAFIS(FG_TABTRIB(VOI->VOI_CODOPE,cOrigB1,aColsFEC[2,nX,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]))

	nDescont := aColsFEC[2,nX,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]

	nTotPec  := aColsFEC[2,nX,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]-nDescont

	nPerDes  := Round((nDescont / aColsFEC[2,nX,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]) * 100,2)

	aItePV[Len(aItePV),01] := SB1->B1_COD     					                               //Codigo do Produto
	aItePV[Len(aItePV),02] := SB1->B1_DESC    					                               //Descricao do Produto
	aItePV[Len(aItePV),03] := aColsFEC[2,nX,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]            //Quantidade Vendida
	aItePV[Len(aItePV),04] := aColsFEC[2,nX,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]-nDescont   //Valor Unitario
	aItePV[Len(aItePV),05] := aColsFEC[2,nX,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]-nDescont   //Valor Total do Item
	aItePV[Len(aItePV),06] := VOI->VOI_CODALM					                               //Almoxarifado
	aItePV[Len(aItePV),07] := 	SB1->B1_UM      				                               //Unidade de Medida Primaria.
	aItePV[Len(aItePV),08] := nPerDes			 					                           //Desconto percentual
	aItePV[Len(aItePV),09] := nDescont			 					                           //Desconto Valor
	aItePV[Len(aItePV),10] := aColsFEC[2,nX,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]            //Tipo de Saida do Item
	aItePV[Len(aItePV),11] := cCFiscal        				 	                               //CFO
	aItePV[Len(aItePV),12] := 0               					                               //Valor IPI
	aItePV[Len(aItePV),13] := MaFisRet(nX,"IT_VALICM")							 			   //Valor do ICMS
	aItePV[Len(aItePV),14] := 0               					                               //Valor do ISS
	aItePV[Len(aItePV),15] := aColsFEC[2,nX,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]-nDescont   //Base ICMS
	aItePV[Len(aItePV),16] := aColsFEC[2,nX,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]            //Valor Unitario
	aItePV[Len(aItePV),17] := aColsFEC[2,nX,FS_POSVAR("VO3_NUMLOT","aHeaderFEC",2)]            //Lote
	aItePV[Len(aItePV),18] := aColsFEC[2,nX,FS_POSVAR("VO3_LOTECT","aHeaderFEC",2)]            //Sub Lote
	aItePV[Len(aItePV),19] := If(Localiza(SB1->B1_COD),VOI->VOI_LOCALI,Space(15))              //Localizacao
	aItePV[Len(aItePV),20] :=	aColsFEC[2,nX,FS_POSVAR("VO3_NUMSER","aHeaderFEC",2)]          //Numero de Serie
	// grava campos faltantes...luis
	//	nPosMaFis := aScan(aColsP,{|x| x[FG_POSVAR("VO3_GRUITE","aHeaderP")]+x[FG_POSVAR("VO3_CODITE","aHeaderP")] == VO3->VO3_GRUITE+VO3->VO3_CODITE})
	aItePV[Len(aItePV),21] :=  MaFisRet(nX,"IT_VALPIS") + MaFisRet(nX,"IT_VALPS2") // L2_VALPS2 - valor do pis -
	aItePV[Len(aItePV),22] :=  MaFisRet(nX,"IT_VALCOF") + MaFisRet(nX,"IT_VALCF2") // L2_VALCF2 - valor cofins - MaFisRet(nPos,"IT_VALCF2")
	aItePV[Len(aItePV),23] :=  MaFisRet(nX,"IT_BASEPS2") // L2_BASEPS2 - base do pis - MaFisRet(nPos,"IT_BASEPS2")
	aItePV[Len(aItePV),24] :=  MaFisRet(nX,"IT_BASECF2") // L2_BASECF2 - base do cofins - MaFisRet(nPos,"IT_BASECF2")
	aItePV[Len(aItePV),25] :=  MaFisRet(nX,"IT_ALIQPS2") // L2_ALIQPS2 - aliquota pis - MaFisRet(nPos,"ALIQPS2")
	aItePV[Len(aItePV),26] :=  MaFisRet(nX,"IT_ALIQCF2") // L2_ALIQCF2 - aliquota cofins - MaFisRet(nPos,"IT_ALIQCF2")
	aItePV[Len(aItePV),27] :=  SB1->B1_SEGUM
	aItePV[Len(aItePV),28] :=  MaFisRet(nx,"IT_BASESOL")
	aItePV[Len(aItePV),29] :=  MaFisRet(nx,"IT_VALSOL")
Next

//Servicos
For nX := 1 to len(aColsFEC[3])
	If Empty(aColsFEC[3,nX,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)])
		Loop
	EndIf

	If VOI->VOI_SITTPO # "3"  // Tipo de Tempo Interno
		cKeyAce      := aColsFEC[3,nX,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]
		//FG_SEEK("VOK","cKeyAce",1,.f.)
		//FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
		//FG_SEEK("SB5","SB1->B1_COD")
		//FG_SEEK("SB2","SB1->B1_COD")
		//FG_SEEK("SF4","VOI->VOI_CODTES")

		VOK->(dbSetOrder(1))
		VOK->(dbSeek(xFilial("VOK")+cKeyAce))

		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1")+VOK->VOK_GRUITE+VOK->VOK_CODITE))

		SB5->(dbSetOrder(1))
		SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))

		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD))

		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+VOI->VOI_CODTES))

		cCFiscal := FG_CLAFIS(aColsFEC[3,nX,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)])

		//		Aadd(aItePV,Array(20))

		nTotSrv += aColsFEC[3,nX,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]

		nDescont := aColsFEC[3,nX,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)]

		nTotPec  := aColsFEC[3,nX,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]-nDescont

		nPerDes  := Round((nDescont / aColsFEC[3,nX,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]) * 100,2)

		Aadd(aItePV,Array(29))
		aItePV[Len(aItePV),01] := SB1->B1_COD     					                    //Codigo do Produto
		aItePV[Len(aItePV),02] := SB1->B1_DESC    					                    //Descricao do Produto
		aItePV[Len(aItePV),03] := 1             										//Quantidade Vendida
		aItePV[Len(aItePV),04] := nTotPec                                               //Valor Unitario
		aItePV[Len(aItePV),05] := nTotPec                                               //Valor Total do Item
		aItePV[Len(aItePV),06] := SB1->B1_LOCPAD  					                    //Almoxarifado
		aItePV[Len(aItePV),07] := 	SB1->B1_UM      				                    //Unidade de Medida Primaria.
		aItePV[Len(aItePV),08] := nPerDes 			 					                //Desconto percentual
		aItePV[Len(aItePV),09] := nDescont			 					                //Desconto Valor
		aItePV[Len(aItePV),10] := VOI->VOI_CODTES	                              		//Tipo de Saida do Item
		aItePV[Len(aItePV),11] := cCFiscal        				 	                    //CFO
		aItePV[Len(aItePV),12] := 0               					                    //Valor IPI
		aItePV[Len(aItePV),13] := 0														//Valor do ICMS
		aItePV[Len(aItePV),14] := aItePV[Len(aItePV),04]*nAliIss       					//Valor do ISS
		aItePV[Len(aItePV),15] := 0                                                     //Base ICMS
		aItePV[Len(aItePV),16] := aColsFEC[3,nX,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] //Valor Unitario
		aItePV[Len(aItePV),17] := "" 					              					//Lote
		aItePV[Len(aItePV),18] := "" 					              					//Sub Lote
		aItePV[Len(aItePV),19] := Space(15)                    							//Localizacao
		aItePV[Len(aItePV),20] :=	""					              					//Numero de Serie


		aItePV[Len(aItePV),21] :=  MaFisRet(nX,"IT_VALPIS") + MaFisRet(nX,"IT_VALPS2") 	// L2_VALPS2 - valor do pis -
		aItePV[Len(aItePV),22] :=  MaFisRet(nX,"IT_VALCOF") + MaFisRet(nX,"IT_VALCF2") 	// L2_VALCF2 - valor cofins - MaFisRet(nPos,"IT_VALCF2")
		aItePV[Len(aItePV),23] :=  MaFisRet(nX,"IT_BASEPS2") 	// L2_BASEPS2 - base do pis - MaFisRet(nPos,"IT_BASEPS2")
		aItePV[Len(aItePV),24] :=  MaFisRet(nX,"IT_BASECF2") 	// L2_BASECF2 - base do cofins - MaFisRet(nPos,"IT_BASECF2")
		aItePV[Len(aItePV),25] :=  MaFisRet(nX,"IT_ALIQPS2") 	// L2_ALIQPS2 - aliquota pis - MaFisRet(nPos,"ALIQPS2")
		aItePV[Len(aItePV),26] :=  MaFisRet(nX,"IT_ALIQCF2") 	// L2_ALIQCF2 - aliquota cofins - MaFisRet(nPos,"IT_ALIQCF2")
		aItePV[Len(aItePV),27] :=  SB1->B1_SEGUM
    	aItePV[Len(aItePV),28] :=  MaFisRet(nx,"IT_BASESOL")
	    aItePV[Len(aItePV),29] :=  MaFisRet(nx,"IT_VALSOL")

	EndIf
Next

//Entradas
if !Empty(cTipPag)
	For nX:=1 to Len(aColsC)
		If !aColsC[nX,Len(aColsC[nX])] .and. !Empty(aColsC[nX,1])
			Aadd(aPagPV,Array(4))
			aPagPV[Len(aPagPV),01] := aColsC[nX,3]
			aPagPV[Len(aPagPV),02] := aColsC[nX,4]
			aPagPV[Len(aPagPV),03] := aColsC[nX,1]
			aPagPV[Len(aPagPV),04] := ""
		Endif
	Next

	For nX:=1 to Len(aIteParc)
		If !Empty(aIteParc[nX,1])
			Aadd(aPagPV,Array(4))
			aPagPV[Len(aPagPV),01] := aIteParc[nX,1]
			aPagPV[Len(aPagPV),02] := aIteParc[nX,2]
			aPagPV[Len(aPagPV),03] := iif(empty(SE4->E4_FORMA),"DP",SE4->E4_FORMA)
			aPagPV[Len(aPagPV),04] := ""
		EndIf
	Next
EndIf

Asort(aPagPV,,,{|x,y| dtos(x[1])+descend(x[3]) < dtos(y[1])+descend(y[3]) })

FG_GRVLOJA(aCabPV,aItePV,aPagPV,.F.,@cOrcLoja,if(VOI->VOI_SITTPO == "3",.F.,.T.))

For nX := 1 To Len(aVetOsv)
	DbSelectArea("VOO")
	DbSetOrder(1)
	If DbSeek(xFilial("VOO")+aVetOsv[nX,1]+aVetOsv[nX,2])
		RecLock("VOO",.f.)
		VOO->VOO_PESQLJ := cOrcLoja
		VOO->VOO_CONDPG := cTipPag
		VOO->VOO_DEPTO  := cDepVOO //rafael 10/6/10
		MsUnlock()
	EndIf

	DbSelectArea("VFE")
	RecLock("VFE",.t.)
	VFE->VFE_FILIAL := xFilial("VFE")
	VFE->VFE_NUMORC := cOrcLoja
	VFE->VFE_NUMOSV := aVetOsv[nX,1]
	VFE->VFE_TIPTEM := aVetOsv[nX,2]
	MsUnlock()
Next
Return
