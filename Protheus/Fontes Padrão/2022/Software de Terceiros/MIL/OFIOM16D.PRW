// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 44     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "ofiom16d.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM160D³ Autor ³  Emilton              ³ Data ³ 30/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fechamento de Ordem de Servico (Segmento Fecto Kilometro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM16D()
Local _xxi

Local nParcelas:=0
Local aPiscof := {}
Local x_	  := 0
Local ixi	  := 0
Local i		  := 0
Local nSelect := 0
Local nValorFin := 0  
Local cNatSC5   := ""
Private cPrefNF  := ""
Private cPrefixo := GetNewPar("MV_PREFOFI","OFI")

VAI->(dbSetOrder(1))
VAI->(dbSeek(xFilial("VAI")+VO1->VO1_FUNABE))
SA3->(dbSetOrder(1))
SA3->(dbSeek(xFilial("SA3")+VAI->VAI_CODVEN))
VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI")+__cUserID))

ProcRegua(6)

If cPaisLoc == "BRA" // Manoel - 12/05/2009
	If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"	//nao Integrado com o Sigaloja ?
		IncProc(STR0001) //"Atualizando Modulo Financeiro"
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
		
		cKeyAce := cParam02+cParam03
		FG_SEEK("SA1","cKeyAce")
		FG_SEEK("VOI","cParam04",1,.f.)
		
		cNumPed  := CriaVar("C5_NUM")
		IncProc(STR0004) //"Preparando Dados da NF"
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
		//if SA1->A1_PESSOA == "J" .and. !Empty(SA1->A1_INSCR) .and. VAM->VAM_ESTADO <> GETMV("MV_ESTADO")
		//   cCliPad := ""
		//   cLojPad := ""
		//Else
		//   cCliPad := GetMv("MV_CLIPAD")
		//   cLojPad := GetMv("MV_LOJAPAD")
		//Endif

		FG_SEEK("SE4","cTipPag",1)      
		
		if !Empty(cVO1_NATURE) 
			cNatSC5 := cVO1_NATURE
		Else
			cNatSC5 := cVO1_NATSRV
		Endif		
		
		aAdd(aCabPV,{"C5_NUM"    ,cNumPed         ,Nil}) // Numero do pedido
		aAdd(aCabPV,{"C5_TIPO"   ,cTipPed         ,Nil}) // Tipo de pedido
		aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD     ,Nil}) // Codigo do cliente
		aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA    ,Nil}) // Loja do cliente
		//If !Empty(cCliPad)
		//	aAdd(aCabPV,{"C5_CLIENT" ,cCliPad         ,Nil}) // Codigo do cliente
		//	aAdd(aCabPV,{"C5_LOJAENT",cLojPad         ,Nil}) // Loja para entrada
		//Endif
		
		aAdd(aCabPV,{"C5_CONDPAG", IIf( SE4->E4_TIPO == "A" , RetCondVei() , SE4->E4_CODIGO ) ,Nil}) // Codigo da condicao de pagamanto
		aAdd(aCabPV,{"C5_VEND1"  ,SA3->A3_COD     ,Nil}) // Codigo do vendedor
		aAdd(aCabPV,{"C5_EMISSAO",dDataBase       ,Nil}) // Data de emissao
		aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO    ,Nil}) // Tipo do Cliente
		aAdd(aCabPV,{"C5_DESC1"  ,0               ,Nil}) // Percentual de Desconto
		aAdd(aCabPV,{"C5_BANCO"  ,cCodBco         ,Nil}) // Codigo do Banco
		aAdd(aCabPV,{"C5_INCISS" ,"S"             ,Nil}) // ISS Incluso
		aAdd(aCabPV,{"C5_TIPLIB" ,"2"             ,Nil}) // Tipo de Liberacao
		aAdd(aCabPV,{"C5_MOEDA"  ,1               ,Nil}) // Moeda
		aAdd(aCabPV,{"C5_LIBEROK","S"             ,Nil}) // Liberacao Total
		aAdd(aCabPV,{"C5_COMIS1" ,0               ,Nil}) // Percentual de Comissao
		aAdd(aCabPV,{"C5_DESPESA",M->VSF_DESACE   ,Nil}) // Despesa Adicionais
		aAdd(aCabPV,{"C5_NATUREZ",cNatSC5		   ,Nil}) // Naturez
		
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
		
		//Servicos
		
		cCont := "00"
		For ixi := 1 to len(aColsFEC[3])
			
			If Empty(aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]) .or. aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] == 0
				Loop
			EndIf
			
			cKeyAce := aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]
			FG_SEEK("VOK","cKeyAce",1,.f.)
			
			//            If VOK->VOK_TIPHOR # "1"
			//            	 Loop
			//            EndIf
			
			FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
			FG_SEEK("SB5","SB1->B1_COD")
			FG_SEEK("SB2","SB1->B1_COD")
			cKey := aColsFEC[3,ixi,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)]
			FG_SEEK("SF4","cKey")
			
			cCFiscal := FG_CLAFIS(VOI->VOI_CODTES)
			cNumIte := cCont := Soma1( cCont , 2 )
			
			//Items
			nDescont := round(aColsFEC[3,ixi,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)],2)
			
			aItePv := {}
			
			// Numero do Pedido
			aAdd(aItePV,{"C6_NUM"    ,cNumPed,Nil})
			// Numero do Item no Pedido
			aAdd(aItePV,{"C6_ITEM"   ,cNumIte,Nil})
			// Codigo do Produto
			aAdd(aItePV,{"C6_PRODUTO",SB1->B1_COD,Nil})
			// Quantidade Vendida
			aAdd(aItePV,{"C6_QTDVEN" ,1,Nil})
			// Preco Unitario Liquido
			//		aAdd(aItePV,{"C6_PRUNIT" ,round(aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]-nDescont,2),Nil})
			aAdd(aItePV,{"C6_PRUNIT" ,round(aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)],2),Nil})
			// Preco Unitario Liquido
			//		aAdd(aItePV,{"C6_PRCVEN" ,round(aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]-nDescont,2),Nil})
			aAdd(aItePV,{"C6_PRCVEN" ,round(aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)],2),Nil})
			// Valor Total do Item
			//		aAdd(aItePV,{"C6_VALOR"  ,round(aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]-nDescont,2),Nil})
			aAdd(aItePV,{"C6_VALOR"  ,round(aColsFEC[3,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)],2),Nil})
			// Data da Entrega
			aAdd(aItePV,{"C6_ENTREG" ,dDataBase,Nil})
			// Unidade de Medida Primar.
			aAdd(aItePV,{"C6_UM"     ,SB1->B1_UM,Nil})
			// Tipo de Saida do Item
			aAdd(aItePV,{"C6_TES"    ,VOI->VOI_CODTES,Nil})
			// Armazem
			aAdd(aItePV,{"C6_LOCAL"  ,SB1->B1_LOCPAD,Nil})
			// CFO
			aAdd(aItePV,{"C6_CF"     ,cCFiscal    ,Nil})
			// Valor do Desconto
			aAdd(aItePV,{"C6_VALDESC",0,Nil})
			// Comissao Vendedor
			// aAdd(aItePV,{"C6_COMIS1" ,nComVend       ,Nil})
			// Descricao do Produto
			aAdd(aItePV,{"C6_DESCRI" ,SB1->B1_DESC   ,Nil})
			// Cliente
			aAdd(aItePV,{"C6_CLI"    ,SC5->C5_CLIENTE,Nil})
			// Loja do Cliente
			aAdd(aItePV,{"C6_LOJA"   ,SC5->C5_LOJACLI,Nil})
			If GetVersao(.f.) == "P10"
				// Quantidade Empenhada
				aAdd(aItePV,{"C6_QTDEMP" ,1,Nil})
			EndIf
			// Quantidade Liberada
			//		aAdd(aItePV,{"C6_QTDLIB" ,1,Nil})
			
			aAdd(aIte,aClone(aItePV))
			
			//            If !FS_VFBSRV(VV1->VV1_PROATU,VV1->VV1_LJPATU,VV1->VV1_CHAINT,"S",aColsFEC[4,ixi,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)],VO1->VO1_NUMOSV,VO1->VO1_KILOME,VO2->VO2_NOSNUM,"")
			//		If !FS_VFBSRV(VV1->VV1_PROATU,VV1->VV1_LJPATU,VV1->VV1_CHAINT,VO1->VO1_NUMOSV,VO1->VO1_KILOME,VO2->VO2_NOSNUM,"K",cParam04,aColsFEC[3,ixi,FS_POSVAR("VO4_CODSER","aHeaderFEC",3)])
			If !FS_VFBSRV(VV1->VV1_PROATU,VV1->VV1_LJPATU,VV1->VV1_CHAINT,VO1->VO1_NUMOSV,VO1->VO1_KILOME,VO2->VO2_NOSNUM,"K",cParam04,)
				Help("  ",1,"REGNLOCK")
				lRetFech := .f.
				DisarmTransaction()
				Break
			EndIf
			
		Next
		
		//Efetua a Liberacao do Pedido se LiberOk == "S" e QtdLib = QtdEmp
		
		
		lMSHelpAuto := .t.
		
		lMsErroAuto := .f. // se retornar .t. deu erro
		If ExistBlock("PEOM160ANP")
			ExecBlock("PEOM160ANP",.f.,.f.)
		Endif
		MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aIte,3)
		
		if LMsErroAuto
			DisarmTransaction()
			Break
		Endif
		
		
		IncProc(STR0005) //"Gerando NF"
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
		
		dbSelectArea("SC9")
		dbSetOrder(1)
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+cNumPed+"01")
		While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
			dbSelectArea("SC9")
			if !dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM)
				nQtdLib := SC6->C6_QTDVEN
				nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
			Endif
			dbSelectArea("SC6")
			dbSkip()
		Enddo
		
		dbSelectArea("SC9")
		dbSeek(xFilial("SC9")+cNumPed+"01")
		While SC9->C9_PEDIDO == cNumPed .and. SC9->C9_FILIAL == xFilial("SC9") .and. !Eof()
			
			If Empty(SC9->C9_BLCRED) .AND. Empty(SC9->C9_BLEST)  // Pendente com Valdir
				
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
				FG_X3ORD("C",,aCabPv)
				FG_X3ORD("I",,aIte)
				MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aIte,5)
				
				if LMsErroAuto
					DisarmTransaction()
					Break
				Endif
				
			EndIf
			dbSkip()
			
		Enddo
		
		
		FG_SEEK("SE4","cTipPag",1)  //Tem que ser Tipo A para nao criar E1 automatico
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		PERGUNTE("MT460A",.f.)
		cNota   := MaPvlNfs(aPvlNfs,cSerie, (mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
		//   cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
		cNota := LEFT(cNota+sPACE(15),TamSx3("F2_DOC")[1])
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+cNumPed))
			RecLock("SC5",.f.)
			SC5->C5_CONDPAG := cTipPag
			MsUnlock()
		Endif
		
		
		//	cPrefNF := iif(nCheck==1,&(GetNewPar("MV_1DUPREF","cSerie")),SuperGetMv("MV_SERCUP"))
		
		cNumIte := "00"
		_nDescMIL := 0
		//Servicos
		For ixi := 1 to len(aColsFEC[3])
			If Empty(aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)])
				loop
			EndIf
			
			cKeyAce := aColsFEC[3,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]
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
		if FieldPos("F2_SDOC") > 0
			SF2->F2_SDOC := FGX_UFSNF(cSerie)
		EndIf
		SF2->F2_PREFORI:= cPrefixo
		SF2->F2_VALFAT := nTotTTP
		SF2->F2_DESCONT:= nTotDes
		
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
		
		FG_SEEK("SE4","cTipPag",1)  //Tem que ser Tipo A para nao criar E1 automatico
		FG_Seek("SA6","cCodBco",1,.f.)
		if SA6->A6_BORD == "0"
			cNumBord := "BCO"+SA6->A6_COD
			dDatBord := dDataBase
		Endif
		
		if (Len(aColsC) = 1) .and. (Empty(aColsC[1,1])) .and. (Empty(aIteParc[1,1]))
			aColsC[Len(aColsC),1] := "DP"
			aColsC[Len(aColsC),2] := "DUPLICATA"
			aColsC[Len(aColsC),3] := dDataBase
			aColsC[Len(aColsC),4] := nTotTTp+M->VSF_DESACE
		Endif
		
		aColsSlvC := aClone(aColsC)
		
		// Geracao de Titulos para o Contas a Receber
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
		
		nParcelas:=0
		
		if SE4->E4_TIPO == "A"
			For i:=1 to len(aColsC)
				
				if Empty(aColsC[1,1])
					Loop
				Endif
				if aColsC[i,Len(aColsC[i])] == .t.
					Loop
				Endif
				
				cCodBco2 := cCodBco
				//			cNumBord2 := "BCO"+SA6->A6_COD
				//			dDatBord2 := cTod("")
				if !Empty(aColsC[i,FG_POSVAR('VS9_PORTAD',"aHeaderC")])
					cCodBco2 := aColsC[i,FG_POSVAR('VS9_PORTAD',"aHeaderC")]
				Endif
				FG_Seek("SA6","cCodBco2",1,.f.)
				//			if SA6->A6_BORD == "0"
				//				cNumBord2 := "BCO"+SA6->A6_COD
				//				dDatBord2 := dDataBase
				//			Endif
				
				cNatureza := ""
				
				/*
				if !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
				If "P" $ _cPecSrv // Natureza de Pecas
				nPosVirg := AT(",",GETMV("MV_NATPER"))
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
					cTipTit   :=   GETMV("MV_TIPPER")    // Tipo de titulo a ser gerado
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
				{"E1_SERIE"  , cSerie                 ,nil} ,;
				{"E1_ORIGEM" , "MATA460"              ,nil} }
				
				//			{"E1_NUMBOR"  ,cNumBord2             ,Nil},;
				//			{"E1_DATABOR" ,dDatBord2             ,Nil},;
				
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
						{"E1_NUM"      ,cNota             ,Nil},;
						{"E1_PARCELA"  ,cParcela          ,Nil},;
						{"E1_NATUREZ",cVO1_NATURE         ,Nil},;
						{"E1_TIPO"     ,aColsC[i,1]       ,Nil},;
						{"AUTMOTBX"    ,"NOR"             ,Nil},;
						{"AUTDTBAIXA"  ,dDataBase         ,Nil},;
						{"AUTDTCREDITO",dDataBase         ,Nil},;
						{"AUTHIST"     ,STR0006,Nil},; //'Baixa Automatica'
						{"AUTVALREC"   ,aColsC[i,4]       ,Nil }}
						
						lMSHelpAuto := .t.
						lMsErroAuto := .f.
						MSExecAuto({|x| FINA070(x)},aBaixa)
						
						If LMsErroAuto
							DisarmTransaction()
							Break
						Endif
					EndIf
				EndIf
				
			Next
		Endif	
		aColsC := aClone(aColsSlvC)
		
		// Financiamento - Integracao com Microsiga
		
		nParcelas:=0
		
		if SE4->E4_TIPO == "A"
			For i:=1 to Len(aIteParc)
				
				if Empty(aIteParc[i,1]) .or. aIteParc[i,2] == 0
					Loop
				Endif
				
				cNatureza := ""
				/*
				if !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
				nPosVirg := AT(",",GETMV("MV_NATPER"))
				If "P" $ _cPecSrv // Natureza de Pecas
				cNatureza   := If(nPosVirg>0,Left(GETMV("MV_NATPER"),nPosVirg-1),GETMV("MV_NATPER"))
				Else //If "S" $ _cPecSrv // Natureza de Servicos
				cNatureza := If(nPosVirg>0,Alltrim(Subs(GETMV("MV_NATPER"),nPosVirg+1)),GETMV("MV_NATPER"))   // Codigo da natureza dos titulos a serem gerados
				Endif
				Else
				cTipTit   := "DP"
				cNatureza := SA1->A1_NATUREZ
				Endif
				*/
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
				{"E1_TIPO"   ,cTipTit                  ,Nil},;
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
				{"E1_PREFORI",cPrefixo                  ,Nil},;
				{"E1_VEND1"  , SA3->A3_COD            ,nil},;
				{"E1_COMIS1" , SA3->A3_COMIS          ,nil},;
				{"E1_BASCOM1", aIteParc[i,2]          ,nil},;
				{"E1_PEDIDO" , cNumPed                ,nil},;
				{"E1_NUMNOTA", cNota                  ,nil},;
				{"E1_SERIE"  , cSerie                 ,nil} ,;
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
				
				if LMsErroAuto
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
	EndIf
EndIf

FS_COMCON(cParam04)

cKeyAce := cParam02+cParam03
FG_SEEK("SA1","cKeyAce")

For ixi:= 1 to Len(aColsFec[4])
	
	cKeyAce := aColsFEC[4,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
	FG_SEEK("VOK","cKeyAce",1,.f.)
	FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
	
	nAliIssP := FM_SQL("SELECT SFT.FT_ALIQICM FROM "+RetSqlName("SFT")+" SFT WHERE SFT.FT_FILIAL = '"+xFilial("SFT")+"'"+;
	" AND SFT.FT_NFISCAL = '"+cNota+"' AND SFT.FT_SERIE = '"+cSerie+"' AND SFT.FT_CLIEFOR = '"+SA1->A1_COD+"' AND SFT.FT_LOJA = '"+SA1->A1_LOJA+"'"+;
	" AND SFT.FT_PRODUTO = '"+SB1->B1_COD+"' AND SFT.D_E_L_E_T_=' '") / 100
	If nAliIssP <> 0
		nAliIss := nAliIssP
	Endif
	
	If cChaAnt != aColsFEC[4,ixi,FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)]
		
		If !FS_GRAOSV(aVetKil[aScan(aVetKil,{ |x| x[02] == aColsFEC[4,ixi,FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)] } ),01],aColsFEC[4,ixi,FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)])
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf
		
		If !FS_GRAVF4()
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf
		
		If !FS_GRAREQ("S")
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf
		
		If !FS_GRAVOO(aColsFEC[4,ixi,FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)],cCodCDCI,cContrato)
			Help("  ",1,"REGNLOCK")
			lRetFech := .f.
			DisarmTransaction()
			Break
		EndIf
		
		cChaAnt := aColsFEC[4,ixi,FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)]
		aAdd(aOSvCri,VO1->VO1_NUMOSV)
		
	EndIf
	
	cKeyAce := FG_MARSRV(VO1->VO1_CODMAR,aColsFEC[4,ixi,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)])+aColsFEC[4,ixi,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
	//	cKeyAce := VO1->VO1_CODMAR+aColsFEC[4,ixi,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
	FG_SEEK("VO6","cKeyAce",2,.f.)
	
	FS_GRAVO4(aColsFEC[4,ixi,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)],;
	aColsFEC[4,ixi,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)],;
	aColsFEC[4,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)],;
	aColsFEC[4,ixi,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)],;
	VO6->VO6_SERINT,;
	aColsFEC[4,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)])
	
	DbSelectArea("VSC")
	
	If !RecLock("VSC",.t.)
		Help("  ",1,"REGNLOCK")
		lRetFech := .f.
		DisarmTransaction()
		Break
	EndIf
	//	FG_SEEK("SF4",aColsFEC[4,ixi,FS_POSVAR("VO4_CODTES","aHeaderFEC",4)])
	//	aPisCof := CalcPisCofSai(aColsFEC[4,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)])
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+VOI->VOI_CODTES))
	aPisCof := CalcPisCofSai(aColsFEC[4,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)])
	
	VSC_FILIAL := xFilial("VSC")
	VSC_NUMIDE := GetSXENum("VSC","VSC_NUMIDE")
	ConfirmSx8()
	VSC_MODVEI := VV1->VV1_MODVEI
	VSC_CODSER := aColsFEC[4,ixi,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
	VSC_TIPSER := aColsFEC[4,ixi,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
	VSC_TIPTEM := cParam04
	VSC_KILROD := aColsFEC[4,ixi,FS_POSVAR("VO4_KILROD","aHeaderFEC",4)]
	VSC_GRUSER := aColsFEC[4,ixi,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]
	VSC_CODSEC := ""
	VSC_DATVEN := dDataBase
	VSC_VALBRU := aColsFEC[4,ixi,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
	VSC_VALDES := aColsFEC[4,ixi,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
	VSC_VALSER := aColsFEC[4,ixi,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
	VSC_VALISS := VSC_VALSER * nAliIss //(SB1->B1_ALIQISS / 100)
	VSC_VALPIS := aPisCof[1,1] //VSC_VALSER * nAliPis
	VSC_VALCOF := aPisCof[1,2] //VSC_VALSER * nAliCof
	VSC_TOTIMP := VSC_VALISS + VSC_VALCOF + VSC_VALPIS
	
	VSC_RECLIQ := 0
	VSC_CUSTOT := 0    // Kilometragem nao tem custo de servico
	VSC_CUSSER := 0    // Kilometragem nao tem custo de servico
	
	//Os de Kilometragem pagara comissao somente para o consultor, caso esteja cadastrado
	
	//aAdd(aVetTra,{VO1->VO1_FUNABE,0})
	//aValCom    := FG_COMISS("S",aVetTra,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"T",VSC_NUMIDE)
	aValCom    := FG_COMISS("S",VO1->VO1_FUNABE,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"T",VSC_NUMIDE)
	VSC_COMVEN := aValCom[1]
	VSC_COMGER := aValCom[2]
	
	VSC_DESVAR := VSC_COMVEN + VSC_COMGER
	
	// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
	VSC->VSC_LUCBRU := VSC->VSC_VALSER - VSC->VSC_TOTIMP - VSC->VSC_CUSTOT
	VSC->VSC_LUCLIQ := VSC->VSC_LUCBRU - VSC->VSC_DESVAR - VSC->VSC_DESFIX - VSC->VSC_DESDEP - VSC->VSC_DESADM //LUCRO MARGINAL
	VSC->VSC_RESFIN := VSC->VSC_LUCLIQ - VSC->VSC_CUSFIX //LAIR
	//	VSC_LUCBRU := VSC_VALSER - VSC_TOTIMP - VSC_CUSTOT
	//	VSC_LUCLIQ := VSC_LUCBRU - VSC_DESVAR
	//	VSC_RESFIN := VSC_LUCLIQ - VSC_CUSFIX - VSC_DESFIX - VSC_DESADM - VSC_DESDEP
	
	VSC_DESFIX := 0
	VSC_CUSFIX := 0
	VSC_DESADM := 0
	VSC_DESDEP := 0
	If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
		VSC_NUMNFI := cNota
		VSC_SERNFI := cSerie
		if FieldPos("VSC_SDOC") > 0
			VSC_SDOC := FGX_UFSNF( cSerie )
		EndIf
	Endif
	VSC_CODMAR := VO1->VO1_CODMAR
	
	FG_SEEK("VO6","FG_MARSRV(VSC->VSC_CODMAR,VSC->VSC_CODSER)+VSC->VSC_CODSER",2,.f.)
	//	FG_SEEK("VO6","VSC->VSC_CODMAR+VSC->VSC_CODSER",2,.f.)
	
	VSC_SERINT := VO6->VO6_SERINT
	VSC_SERNFI := cSerie
	if FieldPos("VSC_SDOC") > 0
		VSC_SDOC := FGX_UFSNF( cSerie )
	EndIf
	VSC_NUMOSV := VO1->VO1_NUMOSV
	VSC_RECVO4 := StrZero(VO4->(recno()),9)
	
	nRazIte := VSC_VALBRU / (nTotTTp+M->VSF_DESACE)
	
	If cPaisLoc == "BRA" // Manoel - 12/05/2009
		If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"	//nao Integrado com o Sigaloja ?
			VSC_VMFBRU := FG_CALCMF(FG_RETVDCP(cOrcLoja,cPrefNF,"S",nTotTTp+M->VSF_DESACE)) * nRazIte
		EndIf
	EndIf
	
	VSC_VMFSER := VSC_VMFBRU - FG_CALCMF({{dDataBase,VSC_VALDES}} )
	VSC_VMFISS := FG_CALCMF({{FG_RTDTIMP("ISS",dDataBase),VSC_VALISS}})
	VSC_VMFPIS := FG_CALCMF({{FG_RTDTIMP("PIS",dDataBase),VSC_VALPIS}})
	VSC_VMFCOF := FG_CALCMF({{FG_RTDTIMP("COF",dDataBase),VSC_VALCOF}})
	
	VSC_TMFIMP := VSC_VMFPIS + VSC_VMFISS + VSC_VMFCOF
	VSC_CMFSER := FG_CALCMF( { {dDataBase,VSC_CUSSER} })
	VSC_CMFTOT := VSC_CMFSER
	VSC_LMFBRU := VSC_VMFSER - VSC_TMFIMP - VSC_CMFTOT
	
	aValCom    := FG_COMISS("S",VO1->VO1_FUNABE,VSC_DATVEN,VSC_TIPTEM,VSC_VALSER,"D",VSC_NUMIDE)
	VSC_CMFVEN := FG_CALCMF(aValCom[1])
	VSC_CMFGER := FG_CALCMF(aValCom[2])
	VSC_DMFVAR := VSC_CMFVEN + VSC_CMFGER
	VSC_LMFLIQ := VSC_LMFBRU - VSC_DMFVAR
	VSC_CMFFIX := 0
	VSC_DMFFIX := 0
	VSC_DMFADM := 0
	VSC_DMFDEP := 0
	VSC_RMFFIN := VSC_LMFLIQ - VSC_CMFFIX - VSC_DMFFIX - VSC_DMFADM - VSC_DMFDEP
	
	MsUnlock()
	
	If !FS_PREVF3("S",nVlrInt)
		Help("  ",1,"REGNLOCK")
		lRetFech := .f.
		DisarmTransaction()
		Break
	EndIf
	
Next

If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "S"	.or. !(cPaisLoc == "BRA") // Integrado com o Sigaloja ?  // Manoel - 12/05/2009
	cKeyAce := VO1->VO1_NUMOSV+cParam04
	FG_SEEK("VOO","cKeyAce",1,.f.)
	if !(VOI->VOI_SITTPO == "3" .and. nTotPec <= 0)  // Interno
		FS_INTLJD()
	Endif
EndIf

//if VOI->VOI_SITTPO == "3" .and. nTotPec <= 0  // Interno
//   FS_GRNFINT()
//Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_IMPDOC3³ Autor ³  Emilton              ³ Data ³ 30/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Emite NF 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_IMPDOC3()

Local ixi := 0
If cPaisLoc == "BRA" // Manoel - 12/05/2009
	If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "N"	//nao Integrado com o Sigaloja ?
		IncProc(STR0008) //"Emitindo NF / Bloqueto / Ordem de Servico "
		
		//Ponto de Entrada para Emissao de Notas Fiscais
		
		If ( VOI->VOI_SITTPO != "3" .Or. ( Type("nTotPec") # "U" .And. nTotPec > 0 ) )
			
			If ExistBlock("NFPECSER")           // Emissao de Nota Fiscal
				ExecBlock("NFPECSER",.f.,.f.,{cNota,cSerie})
			Endif
			
		Endif
		
		If !Empty(aIteParc[1,1])
			
			DbSelectArea("SF2")
			DbSetOrder(1)
			DbSeek(xFilial("SF2")+cNota+cSerie)
			
			cObs1 := ""
			cObs2 := ""
			cObs3 := ""
			
			//Ponto de Entrada para Emissao de Bloquetos Bancarios
			
			DbSelectArea("SA6")
			DbSetOrder(1)
			if DbSeek(xFilial("SA6")+cCodBco)
				If ExistBlock("BLQCOB")           // Emissao de Bloquetos
					ExecBlock("BLQCOB",.f.,.f.,{cNota,,,,SF2->F2_PREFIXO,"1",cObs1,cObs2,cObs3,cCodBco})
				Endif
			Endif
			
		Endif
		
		//Ponto de Entrada para Emissao de Contrato de CDCI
		
		If !Empty(cCodCDCI)                    // Emissao de Contrato de CDCI
			If ExistBlock("CONTCDCI")
				ExecBlock("CONTCDCI",.f.,.f.,{SEM->EM_CONTRAT})     // Ponto de Entrada de Emissao de Contrato de CDCI
			Endif
		EndIf
		
		IncProc(STR0009) //"Finalizando ... "
		
		For ixi := 1 to len(aOSvCri)
			FG_PEDORD(aOSvCri[ixi],"E",cParam04) // Emissao da Ordem de Servico
		Next
	EndIf
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INTLJD ³ Autor ³Valdir F. Silva        ³ Data ³ 29/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faz integracao da venda balcao c/ o sigaloja					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Siga Veiculos (Modulo de Oficina/Pecas)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INTLJD()
Local aCabPV  := Array(30)
Local aItePV  := {}
Local aPagPV  := {}
Local nX      := 0
Local cCFiscal
Local nTotPec := 0
Local nTotSrv := 0

IncProc( STR0010 ) //Gravando Orcamento p/ Caixa

aCabPV[01] := SA1->A1_COD     //Codigo do cliente
aCabPV[02] := SA1->A1_LOJA    //Loja para entrada

//cKeyAce := __cUserID
//FG_SEEK("VAI","cKeyAce",4,.f.)

aCabPV[03] := VAI->VAI_CODVEN        //Codigo do vendedor
aCabPV[04] := dDataBase+30           //Data de emissao
aCabPV[05] := MaFisRet(,"NF_VALICM") //Valor do ICMS
aCabPV[06] := MaFisRet(,"NF_VALISS") //Valor do ISS
aCabPV[07] := 0                      //Valor do IPI
aCabPV[08] := 0                      //Valor do Desconto
aCabPV[09] := nTotTTP                //MaFisRet(,"NF_TOTAL")  //Valor Liquido(Total-Desconto)
aCabPV[10] := "2"                    //Quem esta gravando
aCabPV[11] := VO1->VO1_NUMOSV+cParam04        //Chave a pesquisar
aCabPV[12] := cTipPag

cCliPad := ""
cLojPad := ""
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

//Servicos
For nX := 1 to len(aColsFEC[4])
	If Empty(aColsFEC[4,nX,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]) .or. aColsFEC[4,nX,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] == 0
		Loop
	EndIf
	
	FG_SEEK("VOI","cParam04",1,.f.)
	
	If VOI->VOI_SITTPO # "3"  // Tipo de Tempo Interno
		cKeyAce      := aColsFEC[4,nX,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
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
		
		cCFiscal := FG_CLAFIS(VOI->VOI_CODTES)
		
		//		Aadd(aItePV,Array(20))
		
		nTotSrv += aColsFEC[4,nX,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
		
		nDescont := Round(aColsFEC[4,nX,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)],2)
		
		nPerDes  := (nDescont / aColsFEC[4,nX,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]) * 100
		
		Aadd(aItePV,Array(29))
		aItePV[Len(aItePV),01] := SB1->B1_COD     					                          		//Codigo do Produto
		aItePV[Len(aItePV),02] := SB1->B1_DESC    					                          		//Descricao do Produto
		aItePV[Len(aItePV),03] := 1             													//Quantidade Vendida
		aItePV[Len(aItePV),04] := aColsFEC[4,nX,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]-nDescont 	//Valor Unitario
		aItePV[Len(aItePV),05] := aColsFEC[4,nX,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]-nDescont 	//Valor Total do Item
		aItePV[Len(aItePV),06] := VOI->VOI_CODALM					                          		//Almoxarifado
		aItePV[Len(aItePV),07] := 	SB1->B1_UM      				                             	//Unidade de Medida Primaria.
		aItePV[Len(aItePV),08] := nPerDes			 					                          	//Desconto percentual
		aItePV[Len(aItePV),09] := nDescont        					                          		//Desconto Valor
		aItePV[Len(aItePV),10] := VOI->VOI_CODTES	                              		  			//Tipo de Saida do Item
		aItePV[Len(aItePV),11] := cCFiscal        				 	                          		//CFO
		aItePV[Len(aItePV),12] := 0               					                          		//Valor IPI
		aItePV[Len(aItePV),13] := MaFisRet(nX,"IT_VALICM")	   		 					     		//Valor do ICMS
		aItePV[Len(aItePV),14] := aItePV[Len(aItePV),04]*nAliIss       						  		//Valor do ISS
		aItePV[Len(aItePV),15] := aColsFEC[4,nX,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]-nDescont  	//Base ICMS
		aItePV[Len(aItePV),16] := aColsFEC[4,nX,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]  			//Valor Unitario
		aItePV[Len(aItePV),17] := "" 					              								//Lote
		aItePV[Len(aItePV),18] := "" 					              								//Sub Lote
		aItePV[Len(aItePV),19] := Space(15)                    									  	//Localizacao
		aItePV[Len(aItePV),20] :=	""					              								//Numero de Serie
		// grava campos faltantes...luis
		nPosMaFis := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == VO3->VO3_GRUITE+VO3->VO3_CODITE } )
		
		aItePV[Len(aItePV),21] :=  MaFisRet(nX,"IT_VALPIS") + MaFisRet(nX,"IT_VALPS2") // L2_VALPS2 - valor do pis -
		aItePV[Len(aItePV),22] :=  MaFisRet(nX,"IT_VALCOF") + MaFisRet(nX,"IT_VALCF2") // L2_VALCF2 - valor cofins - MaFisRet(nPos,"IT_VALCF2")
		aItePV[Len(aItePV),23] :=  MaFisRet(nX,"IT_BASEPS2") // L2_BASEPS2 - base do pis - MaFisRet(nPos,"IT_BASEPS2")
		aItePV[Len(aItePV),24] :=  MaFisRet(nX,"IT_BASECF2") // L2_BASECF2 - base do cofins - MaFisRet(nPos,"IT_BASECF2")
		aItePV[Len(aItePV),25] :=  MaFisRet(nX,"IT_ALIQPS2") // L2_ALIQPS2 - aliquota pis - MaFisRet(nPos,"ALIQPS2")
		aItePV[Len(aItePV),26] :=  MaFisRet(nX,"IT_ALIQCF2") // L2_ALIQCF2 - aliquota cofins - MaFisRet(nPos,"IT_ALIQCF2")
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

If DbSeek(xFilial("VOO")+VO1->VO1_NUMOSV+cParam04)
	RecLock("VOO",.f.)
	VOO->VOO_PESQLJ := cOrcLoja
	VOO->VOO_CONDPG := cTipPag
	VOO->VOO_DEPTO  := cDepVOO	//rafael 10/06/10
	MsUnlock()
EndIf

DbSelectArea("VFE")
RecLock("VFE",.t.)
VFE->VFE_FILIAL := xFilial("VFE")
VFE->VFE_NUMORC := cOrcLoja
VFE->VFE_NUMOSV := VO1->VO1_NUMOSV
VFE->VFE_TIPTEM := cParam04
MsUnlock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GRAOSV  ³ Autor ³ Emilton               ³ Data ³ 06/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Ordem de Servico                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAOSV(cChaInt,cChassi)

Local cQuery   := ""
Local cQAlVS1  := "SQLVS1"
Local ixj, nTotKil
nTotKil := 0

VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI")+__cUserID))
SA3->(dbSetOrder(1))
SA3->(dbSeek(xFilial("SA3")+VAI->VAI_CODVEN))

For ixj := 1 to len(aColsFEC[4])
	
	If cChassi == aColsFEC[4,ixj,FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)]
		nTotKil += aColsFEC[4,ixj,FS_POSVAR("VO4_KILATU","aHeaderFEC",4)]
	EndIf
	
Next

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO1")

While x3_Arquivo == "VO1" .and. !Eof()
	
	&("M->"+x3_campo) := CriaVar(x3_campo)
	
	DbSelectArea("SX3")
	DbSkip()
	
EndDo

If !RecLock("VO1",.t.)
	Return .f.
EndIf

FG_SEEK("SA1","cParam02+cParam03",1,.F.)

cKeyAce := cChaInt

FG_SEEK("VV1","cKeyAce",1,.f.)

VO5->(DbSetOrder(1))
VO5->(DbSeek( xFilial("VO5") + VV1->VV1_CHAINT ))

M->VO1_NUMOSV := GetSXENum("VO1","VO1_NUMOSV")
ConfirmSx8()

M->VO1_CHASSI := VV1->VV1_CHASSI
M->VO1_PLAVEI := VV1->VV1_PLAVEI
M->VO1_FABMOD := VV1->VV1_FABMOD
M->VO1_CODCOR := VV1->VV1_CORVEI

M->VO1_CHAINT := VV1->VV1_CHAINT
M->VO1_PROVEI := VV1->VV1_PROATU
M->VO1_LOJPRO := VV1->VV1_LJPATU
M->VO1_FATPAR := SA1->A1_COD
M->VO1_LOJA   := SA1->A1_LOJA
M->VO1_CODMAR := VV1->VV1_CODMAR
M->VO1_MODVEI := VV1->VV1_MODVEI
M->VO1_KILOME := nTotKil
M->VO1_STATUS := "F"
M->VO1_DATSAI := dDataBase
M->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
M->VO1_DATENT := dDataBase
M->VO1_HORENT := val(left(time(),2)+substr(time(),4,2))
M->VO1_TEMGAR := "N"
M->VO1_TEMLIB := "S"
M->VO1_TEMFEC := "S"
M->VO1_FUNABE := SA3->A3_COD
M->VO1_CODMOT := ""
M->VO1_NUMBOX := ""

FG_GRAVAR("VO1")

MsUnLock()

If VO1->VO1_STATUS == "F"
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
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GRAVF4  ³ Autor ³ Emilton               ³ Data ³ 11/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Numero de Ordem de Servico criado especialmente para o ³±±
±±³          ³ arquivo VF4                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVF4()
******************************************

Local i := 0

dbSelectArea("VF4")

for i:= 1 to len(aVetKil)
	
	If VO1->VO1_CHAINT == aVetKil[i,1]
		
		dbGoTo(aVetKil[i,10])
		
		If !RecLock("VF4",.f.)
			Return .f.
		EndIf
		
		VF4->VF4_NUMOSV := VO1->VO1_NUMOSV
		MsUnlock()
		
	EndIf
	
Next

MsUnLock()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GRAREQ  ³ Autor ³ Emilton               ³ Data ³ 06/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Cabecalho da Requisicao de Servicos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAREQ(cTipOpe)
**********************************

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+cTipOpe)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO2")
While x3_Arquivo == "VO2" .and. !Eof()
	
	&("M->"+x3_campo) := CriaVar(x3_campo)
	
	DbSelectArea("SX3")
	DbSkip()
	
EndDo

FG_SEEK("SA1","cParam02+cParam03",1,.F.)

If !RecLock("VO2",.t.)
	Return .f.
EndIf

M->VO2_NOSNUM := GetSXENum("VO2","VO2_NOSNUM")
ConfirmSx8()
FG_GRAVAR("VO2")
VO2->VO2_TIPREQ := cTipOpe

ConfirmSx8()
MsUnLock()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GRAVOO  ³ Autor ³ Emilton               ³ Data ³ 07/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava VOO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVOO(cChassi,cCodCDCI,cContrato)

Local ixj, nValKil
nValKil := 0

For ixj := 1 to len(aColsFEC[4])
	
	If cChassi == aColsFEC[4,ixj,FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)]
		nValKil += aColsFEC[4,ixj,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
	EndIf
	
Next

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VOO")
While x3_Arquivo == "VOO" .and. !Eof()
	
	&("M->"+x3_campo) := CriaVar(x3_campo)
	
	DbSelectArea("SX3")
	DbSkip()
	
EndDo

FG_SEEK("SA1","cParam02+cParam03",1,.F.)

If !RecLock("VOO",.t.)
	Return .f.
EndIf

FG_GRAVAR("VOO")

VOO->VOO_FILIAL := xFilial("VOO")
VOO->VOO_NUMOSV := VO1->VO1_NUMOSV
VOO->VOO_TIPTEM := cParam04
VOO->VOO_FATPAR := SA1->A1_COD
VOO->VOO_LOJA   := SA1->A1_LOJA
VOO->VOO_TOTSRV := nValKil
VOO->VOO_DEPTO  := cDepVOO
VOO->VOO_CONDPG := cTipPag
If VOO->(FieldPos("VOO_NATSRV")) <> 0
	VOO->VOO_NATSRV := cVO1_NatSRV
EndIf

If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
	VOO->VOO_SERNFI := cSerie
	if FieldPos("VOO_SDOC") > 0
		VOO->VOO_SDOC := FGX_UFSNF( cSerie )
	EndIf
	VOO->VOO_NUMNFI := cNota
Endif
If !Empty(cCodCDCI)
	VOO->VOO_CONTCD := cContrato
EndIf

MsUnlock()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GRAVO4  ³ Autor ³ Emilton               ³ Data ³ 07/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava dos kilometros rodados para manter historico           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 01 - Grupo de Servico                                        ³±±
±±³          ³ 02 - Codigo de Servico                                       ³±±
±±³          ³ 03 - Tipo de Servico                                         ³±±
±±³          ³ 04 - Kilometro rodado, que diz respeito a Fechmto de Klmtgem ³±±
±±³          ³ 05 - Codigo Interno do Servico                               ³±±
±±³          ³ 06 - Valor deste segmento do servico                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVO4(cGruSer,cCodSer,cTipSer,nKilRod,cSerInt,nValRec)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO4")
While x3_Arquivo == "VO4" .and. !Eof()
	
	&("M->"+x3_campo) := If(X3_CAMPO != "VO4_SEQUEN",CriaVar(x3_campo),"00000000")
	
	DbSelectArea("SX3")
	DbSkip()
	
EndDo

cKeyAce := cParam04
FG_SEEK("VOI","cKeyAce",1,.f.)
FG_SEEK("SA1","cParam02+cParam03",1,.F.)

If !RecLock("VO4",.t.)
	Help("  ",1,"REGNLOCK")
	lRetFech := .f.
	DisarmTransaction()
	Break
EndIf

FG_GRAVAR("VO4")

VO4->VO4_FILIAL := xFilial("VO4")
VO4->VO4_TIPTEM := cParam04
VO4->VO4_NOSNUM := VO2->VO2_NOSNUM
VO4->VO4_FATPAR := SA1->A1_COD
VO4->VO4_LOJA   := SA1->A1_LOJA
VO4->VO4_CODTES := VOI->VOI_CODTES
VO4->VO4_GRUSER := cGruSer
VO4->VO4_CODSER := cCodSer
VO4->VO4_TIPSER := cTipSer
VO4->VO4_KILROD := nKilRod
VO4->VO4_SERINT := cSerInt
VO4->VO4_FUNFEC := SA3->A3_COD
If VOI->VOI_SITTPO != "3" // Nao e'Tipo de Tempo Interno
	VO4->VO4_SERNFI := cSerie
	if FieldPos("VO4_SDOC") > 0
		VO4->VO4_SDOC := FGX_UFSNF( cSerie )
	EndIf
	VO4->VO4_NUMNFI := cNota
Endif
VO4->VO4_DATFEC := dDataBase
VO4->VO4_HORFEC := val(left(time(),2)+substr(time(),4,2))
VO4->VO4_DATDIS := dDataBase
VO4->VO4_HORDIS := val(left(time(),2)+substr(time(),4,2))

VO4->VO4_NUMOSV := VO2->VO2_NUMOSV

MsUnlock()

// FS_MOVLIMCRE(.t.,VO4->VO4_FATPAR+VO4->VO4_LOJA,nValRec)

FS_MOVVFB(.t.)

Return .t.

