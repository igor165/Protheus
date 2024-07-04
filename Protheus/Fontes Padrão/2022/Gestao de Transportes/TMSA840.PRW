#INCLUDE "TMSA840.ch"
#include 'Protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA840  ³ Autor ³Patricia A. Salomao    ³ Data ³28.10.2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Contabilizacao OFF LINE (SDG)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA840()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA840()

Local aSays          := {}
Local aButtons       := {}
Local nOpca          := 0
Local bProcesso      := { |oSelf| TMSA840Proc(oSelf) }
Local oTProces
Private lVersao101   := GetRpoRelease() >= "R1.1"
Private cCadastro    := STR0001 //"Contabilizacao OFF LINE dos Custos de Transporte"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Mostra Lancamentos Contabeis ?  Sim Nao           ³
//³ mv_par02 - Aglutina Lancamentos         ?  Sim Nao           ³
//³ mv_par03 - Data Inicial   ?                                  ³
//³ mv_par04 - Data Final     ?                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("TMA840",.F.)

If lVersao101
	oTProces := tNewProcess():New( "TMA840" , cCadastro, bProcesso , cCadastro, "TMA840",,,,,.T.,.T.  )
	oTProces:SaveLog(OemToAnsi(STR0004))
Else
	Aadd( aSays, STR0002 ) //"Este programa tem como finalidade gerar a Contabilizacao OFF LINE"
	Aadd( aSays, STR0003 ) //"dos movimentos de Custo de Transporte (SDG) ... "
	Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
	Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
	Aadd( aButtons, { 5, .T., {|| Pergunte("TMA840",.T.) } } )

	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1
		Begin Transaction
			Processa({|lEnd| TMSA840Proc(,)},"","",.F.)
		End Transaction
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA840Proc ³ Autor ³ Patricia A. Salomao ³ Data ³28.10.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa Contabilizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA850                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA840Proc(oSelf)

Local cQuery      := ''
Local cAliasNew   := ''
Local cArqTRB     := ''
Local cOriLanc    := ''
Local lCriaHead   := .T.
Local aRecSDGBai  := {}
Local aRecSDGEmi  := {}
Local aOrigLan    := {}
Local nCntFor     := 0
Local aArea       := GetArea()
Local lDigita     := .F.
Local lAglutina   := .F.
Local dData       := dDataBase
Local cFil        := ''
Local lExclusivo  := Iif(FWModeAccess ("SDG",3)=="E",.T.,.F.)
Local cFilBkp     := ''

Private nHdlPrv            // Endereco do arquivo de contra prova dos lanctos cont.
Private lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
Private cLoteTMS           // Numero do lote para lancamentos do TMS
Private nTotal := 0        // Total dos lancamentos contabeis
Private cArquivo           // Nome do arquivo contra prova

//-- Ponto de Entrada para tratar as origens que deverao ser contabilizadas
If ExistBlock('TM840LANC')
	aOrigLan := ExecBlock('TM840LANC',.F.,.F.)
	If ValType(aOrigLan) <> 'A'
		aOrigLan := {}
	EndIf
	If Len(aOrigLan) > 0
		For nCntFor := 1 To Len(aOrigLan)
			cOriLanc += "'" + aOrigLan[nCntFor] + "',"
		Next
		cOriLanc := Substr(cOriLanc,1,Len(cOriLanc) - 1)
	EndIf
EndIf

cArqTRB := CriaTrab(Nil,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona numero do Lote para Lancamentos do TMS             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Iif(Empty(Tabela("09","TMS",.F.)), cLoteTMS := "TMS", cLoteTMS := Tabela("09","TMS",.F.))

If mv_par05 == 2 //-- Contabiliza por baixa
	cAliasNew := GetNextAlias()
	cQuery := " SELECT DG_FILIAL, DG_DATBAI, R_E_C_N_O_ NRECNO  "
	cQuery += " FROM "
	cQuery += RetSqlName('SDG') + " SDG "

	cQuery += " WHERE "
	If lExclusivo
		cQuery += " DG_FILIAL BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "' "
	Else
		cQuery += " DG_FILIAL  = '"+xFilial("SDG")+"'"
	EndIf
	cQuery += "   AND DG_STATUS  = '"+StrZero(3,Len(SDG->DG_STATUS))+"'"
	cQuery += "   AND DG_DATBAI >= '"+DTOS(mv_par03)+"'"
	cQuery += "   AND DG_DATBAI <= '"+DTOS(mv_par04)+"'"
	cQuery += "   AND DG_DTLANC  = '' "
	If !Empty(cOriLanc) //-- Verifica quais as origens do SDG deverao ser consideradas na contabilizacao
		cQuery += "	  AND DG_ORIGEM IN ( "+cOriLanc+" )"
	EndIf
	cQuery += "   AND SDG.D_E_L_E_T_ = ' ' "
	cQuery += "   ORDER BY DG_FILIAL, DG_DATBAI "

	cQuery := ChangeQuery(cQuery)

	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

	TCSetField(cAliasNew,"DG_DATBAI","D",8,0)

	//-- Contabiliza pela Data da Baixa
	cFilBkp := cFilAnt
	While (cAliasNew)->(!Eof())

		//--Modifica a filial corrente para que os
		//--lanctos. contabeis sejam realizados conforme
		//--filial onde ocorreu o Movto. de Custo de Transp.
		cFilAnt    := If(lExclusivo, (cAliasNew)->DG_FILIAL, cFilAnt)

		cFil       := (cAliasNew)->DG_FILIAL
		dData      := (cAliasNew)->DG_DATBAI
		aRecSDGBai := {}
		lCriaHead  := .T.
		nTotal     := 0
		While (cAliasNew)->(!Eof()) .And. cFil == (cAliasNew)->DG_FILIAL .And. dData == (cAliasNew)->DG_DATBAI
			If lCriaHead  
				nHdlPrv := HeadProva(cLoteTMS,"TMSA840",cUserName,@cArquivo)
				If nHdlPrv < 0
					HELP(" ",1,"SEM_LANC") //"Nao foi possivel abrir o arquivo de Contra Prova"
					dbCloseArea()
					Exit
				EndIf
				lCriaHead  := .F.
			EndIf
			SDG->(dbGoTo((cAliasNew)->NRECNO))
    		nTotal += DetProva(nHdlPrv,"901","TMSA840",cLoteTMS,/*nLinha*/,/*lExecuta*/,/*cCriterio*/,/*lRateio*/,/*cChaveBusca*/,/*aCT5*/,/*lPosiciona*/,/*aFlagCTB*/,{"SDG",(cAliasNew)->NRECNO},/*aDadosProva*/)
			AADD(aRecSDGBai, { (cAliasNew)->NRECNO, (cAliasNew)->DG_DATBAI } )
			(cAliasNew)->(dbSkip())
		EndDo
		If nTotal > 0
			RodaProva(nHdlPrv,nTotal)
			lDigita   := Iif(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
			lAglutina := Iif(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
			//-- Envia para Lan‡amento Cont bil
			cA100Incl(cArquivo,nHdlPrv,3,cLoteTMS,lDigita,lAglutina,,dData)
			//-- Grava Data da Contabilizacao no SDG
			For nCntFor := 1 To Len(aRecSDGBai)
				SDG->(dbGoTo(aRecSDGBai[nCntFor,1]))
				RecLock('SDG',.F.)
				SDG->DG_DTLANC := aRecSDGBai[nCntFor,2]
				MsUnLock()
			Next
		EndIf
	EndDo
	cFilAnt := cFilBkp
	(cAliasNew)->(DbCloseArea())
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contabiliza pela Data da Emissao                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SDG->(FieldPos('DG_DTLAEMI')) > 0 
		cAliasNew := GetNextAlias()
		cQuery := " SELECT DG_FILIAL, DG_EMISSAO, R_E_C_N_O_ NRECNO  "
		cQuery += " FROM "
		cQuery += RetSqlName('SDG') + " SDG "

		cQuery += " WHERE "
		If lExclusivo
			cQuery += " DG_FILIAL BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "' "
		Else
			cQuery += " DG_FILIAL  = '"+xFilial("SDG")+"'"
		EndIf
		cQuery += "   AND DG_EMISSAO >= '"+DTOS(mv_par03)+"'"
		cQuery += "   AND DG_EMISSAO <= '"+DTOS(mv_par04)+"'"
		cQuery += "   AND DG_DTLAEMI  = '' "
		cQuery += "   AND DG_DTLANC   = '' "
		If !Empty(cOriLanc) //-- Verifica quais as origens do SDG deverao ser consideradas na contabilizacao
			cQuery += "   AND DG_ORIGEM IN ( "+cOriLanc+" )"
		EndIf
		cQuery += "   AND SDG.D_E_L_E_T_ = ' ' "
		cQuery += "   ORDER BY DG_FILIAL, DG_EMISSAO "

		cQuery := ChangeQuery(cQuery)

		cAliasNew := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

		TCSetField(cAliasNew,"DG_EMISSAO","D",8,0)

		cFilBkp := cFilAnt
		While (cAliasNew)->(!Eof())

			//--Modifica a filial corrente para que os
			//--lanctos. contabeis sejam realizados conforme
			//--filial onde ocorreu o Movto. de Custo de Transp.
			cFilAnt    := If(lExclusivo, (cAliasNew)->DG_FILIAL, cFilAnt)

			cFil       := (cAliasNew)->DG_FILIAL
			dData      := (cAliasNew)->DG_EMISSAO
			aRecSDGEmi := {}
			lCriaHead  := .T.
			nTotal     := 0
			While (cAliasNew)->(!Eof()) .And. cFil == (cAliasNew)->DG_FILIAL .And. dData == (cAliasNew)->DG_EMISSAO
				If lCriaHead
					nHdlPrv := HeadProva(cLoteTMS,"TMSA840",cUserName,@cArquivo)
					If nHdlPrv < 0
						HELP(" ",1,"SEM_LANC") //"Nao foi possivel abrir o arquivo de Contra Prova"
						(cAliasNew)->(dbCloseArea())
						Exit
					EndIf
					lCriaHead := .F.
				EndIf
				SDG->(dbGoTo((cAliasNew)->NRECNO))
				nTotal+=DetProva(nHdlPrv,"903","TMSA840",cLoteTMS,/*nLinha*/,/*lExecuta*/,/*cCriterio*/,/*lRateio*/,/*cChaveBusca*/,/*aCT5*/,/*lPosiciona*/,/*aFlagCTB*/,{"SDG",(cAliasNew)->NRECNO},/*aDadosProva*/)
				AADD(aRecSDGEmi, { (cAliasNew)->NRECNO, (cAliasNew)->DG_EMISSAO } )
				(cAliasNew)->(dbSkip())
			EndDo
			If nTotal > 0
				RodaProva(nHdlPrv,nTotal)
				lDigita   := Iif(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
				lAglutina := Iif(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
				//-- Envia para Lan‡amento Cont bil
				cA100Incl(cArquivo,nHdlPrv,3,cLoteTMS,lDigita,lAglutina,,dData)
				//-- Grava Data da Contabilizacao no SDG
				For nCntFor := 1 To Len(aRecSDGEmi)
					SDG->(dbGoTo(aRecSDGEmi[nCntFor,1]))
					RecLock('SDG',.F.)
					SDG->DG_DTLAEMI := aRecSDGEmi[nCntFor,2]
					MsUnLock()
				Next
			EndIf
		EndDo
		cFilAnt := cFilBkp
		(cAliasNew)->(DbCloseArea())
	EndIf
EndIf

RestArea(aArea)

Return Nil

