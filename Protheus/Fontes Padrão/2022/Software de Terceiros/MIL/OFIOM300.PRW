// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 11     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "rwmake.ch"
#INCLUDE "OFIOM300.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM300 | Autor ³  Renata               ³ Data ³02/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao:³ Atualiza preco por percentual por grupo, escolha qual preco³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM300

Private lMSHelpAuto := .t. , lMSErroAuto := .f. , lRet := .t.

cPerg    := "ATUPRE"
nLastKey := 0

DbSelectArea("SB1")
DbSetOrder(7)
DbSelectArea("SB5")
DbSetOrder(1)

ValidPerg(cPerg)

If Pergunte(cPerg,.T.)
	While Empty(mv_par02)
		msginfo(STR0016)
		if !Pergunte(cPerg,.T.)
			Return(.f.)
		Endif
	Enddo
	If nLastKey == 27
		Return
	Endif
	Processa({|| FS_GRVATUPRE()})
	If !lRet
		MostraErro()
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRVATUPºAutor  ³Microsiga           º Data ³  03/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava atualizacao                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRVATUPRE

Local nPrv1 := 0, nPrv2 := 0, nPrv3 := 0

Local lBZ_PRV1   := ( SBZ->(FieldPos("BZ_PRV1")) > 0 )
Local cQuery     := ""
Local nRecSBZ    := 0
Local cDadosProd := SuperGetMV("MV_ARQPROD",.F.,"SB1")

DbSelectArea("SBM")
DbSetOrder(1)

DbSelectArea("SB1")
dbGoTop()
DbSeek(xFilial("SB1")+left(MV_PAR02,len(SB1->B1_GRUPO)),.T.)
ProcRegua(RecCount())

Begin Transaction

While !EOF() .and. SB1->B1_GRUPO >= left(MV_PAR02,len(SB1->B1_GRUPO)) .and. SB1->B1_GRUPO <= left(MV_PAR03,len(SB1->B1_GRUPO))
	
	SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
	
	If Alltrim(SBM->BM_TIPGRU) # "1"    // Diferente de Peças
		DbSelectArea("SB1")
		dbskip()
		loop
	Endif
	
	if !empty(MV_PAR04)
		if alltrim(SB1->B1_GRUDES) # alltrim(MV_PAR04)    //GRUPO
			DbSelectArea("SB1")
			dbskip()
			loop
		endif
	endif
	if SuperGetMV("MV_ARQPROD",.F.,"SB1") <> "SBZ"
		nPRV1 := SB1->B1_PRV1
	Else
		nPRV1 := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")
	EndIf
	if !empty(MV_PAR08) .and. empty(MV_PAR09)
		if nPRV1 < MV_PAR08    //Preco
			DbSelectArea("SB1")
			dbskip()
			loop
		endif
	endif
	if !empty(MV_PAR09) .and. empty(MV_PAR08)
		if nPRV1 > MV_PAR09   //Preco
			DbSelectArea("SB1")
			dbskip()
			loop
		endif
	endif
	if !empty(MV_PAR08) .and. !empty(MV_PAR09)
		if nPRV1 < MV_PAR08 .OR. nPRV1 > MV_PAR09   //Preco
			DbSelectArea("SB1")
			dbskip()
			loop
		endif
	endif
	nPrv1 := ( nPRV1 * (1 + (MV_PAR05/100)) )
	Do Case
		Case MV_PAR01 == 1 // VENDA
			If cDadosProd == "SBZ" .and. lBZ_PRV1
				cQuery := "SELECT SBZ.R_E_C_N_O_ AS RECSBZ FROM "+RetSQLName("SBZ")+" SBZ WHERE "
				cQuery += "SBZ.BZ_FILIAL='"+xFilial("SBZ")+"' AND SBZ.BZ_COD='"+SB1->B1_COD+"' AND SBZ.D_E_L_E_T_=' '"
				nRecSBZ := FM_SQL(cQuery)
				If nRecSBZ > 0
					DbSelectArea("SBZ")
					DbGoTo(nRecSBZ)
					Reclock("SBZ",.F.)  // trava o registro para atualizacao.
					SBZ->BZ_PRV1 := nPrv1
					MsUnLock()
				Else
					DbSelectArea("SB1")
					reclock("SB1",.f.)
					SB1->B1_PRV1:= nPrv1
					msunlock()
				EndIf
			Else
				DbSelectArea("SB1")
				reclock("SB1",.f.)
				SB1->B1_PRV1:= nPrv1
				msunlock()
			EndIf
		Case MV_PAR01 == 2 // REPOSICAO
			DbSelectArea("SB5")
			dbgotop()
			if  DbSeek(xfilial("SB5")+SB1->B1_COD)
				nPrv2 := SB5->B5_PRV2 * (1 + (MV_PAR06/100))
				reclock("SB5",.f.)
				SB5->B5_PRV2:= nPrv2
				msunlock()
			endif
		Case MV_PAR01 == 3 // GARANTIA
			DbSelectArea("SB5")
			dbgotop()
			if  DbSeek(xFilial("SB5")+SB1->B1_COD)
				nPrv3 := SB5->B5_PRV3 * (1 + (MV_PAR07/100))
				reclock("SB5",.f.)
				SB5->B5_PRV3:= nPrv3
				msunlock()
			endif
		Case MV_PAR01 == 4 // TODOS
			If cDadosProd == "SBZ" .and. lBZ_PRV1
				cQuery := "SELECT SBZ.R_E_C_N_O_ AS RECSBZ FROM "+RetSQLName("SBZ")+" SBZ WHERE "
				cQuery += "SBZ.BZ_FILIAL='"+xFilial("SBZ")+"' AND SBZ.BZ_COD='"+SB1->B1_COD+"' AND SBZ.D_E_L_E_T_=' '"
				nRecSBZ := FM_SQL(cQuery)
				If nRecSBZ > 0
					DbSelectArea("SBZ")
					DbGoTo(nRecSBZ)
					Reclock("SBZ",.F.)  // trava o registro para atualizacao.
					SBZ->BZ_PRV1 := nPrv1
					MsUnLock()
				Else
					DbSelectArea("SB1")
					reclock("SB1",.f.)
					SB1->B1_PRV1:= nPrv1
					msunlock()
				EndIf
			Else
				DbSelectArea("SB1")
				reclock("SB1",.f.)
				SB1->B1_PRV1:= nPrv1
				msunlock()
			EndIf
			DbSelectArea("SB5")
			dbgotop()
			if  DbSeek(xfilial("SB5")+SB1->B1_COD)
				nPrv2 := SB5->B5_PRV2 * (1 + (MV_PAR06/100))
				nPrv3 := SB5->B5_PRV3 * (1 + (MV_PAR07/100))
				reclock("SB5",.f.)
				SB5->B5_PRV2:= nPrv2
				SB5->B5_PRV3:= nPrv3
				msunlock()
			endif
	EndCase
	
	IncProc(STR0001)
	
	If lMsErroAuto
		&& Cancela Gravacao
		DisarmTransaction()
		Break
	EndIf
	
	DbSelectArea("SB1")
	dbskip()
EndDo

End Transaction

MsgAlert(STR0008,STR0009) // Fim da atualizacao de preco / Atencao

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Microsiga           º Data ³  03/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criacao do SX1                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function ValidPerg

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

cPerg := PADR(cPerg,len(SX1->X1_GRUPO))
DbSelectArea("SX1")
DbSetOrder(1)
if DbSeek(cPerg+"02")
	if Alltrim(SX1->X1_PERGUNT) <>  Alltrim(STR0003)
		DbSeek(cPerg)
		While SX1->X1_GRUPO == cPerg
			RecLock("SX1",.F.,.T.)
			dbdelete()
			MsUnlock()
			dbSkip()
		Enddo
	Endif
Endif

DbSelectArea("SX1")
DbSetOrder(1)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01",STR0002,"","","mv_ch1","N",1,0,0,"C","","MV_PAR01",STR0010,"","","","",STR0011,"","","","",STR0012,"","","","",STR0013,"","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02",STR0003,"","","mv_ch2","C",4,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
aAdd(aRegs,{cPerg,"03",STR0017,"","","mv_ch3","C",4,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
aAdd(aRegs,{cPerg,"04",STR0004,"","","mv_ch4","C",3,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","VE5",""})
aAdd(aRegs,{cPerg,"05",STR0005,"","","mv_ch5","N",5,2,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06",STR0006,"","","mv_ch6","N",5,2,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07",STR0007,"","","mv_ch7","N",5,2,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08",STR0014,"","","mv_ch8","N",12,2,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09",STR0015,"","","mv_ch9","N",12,2,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
For i:=1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

DbSelectArea(_sAlias)

Return