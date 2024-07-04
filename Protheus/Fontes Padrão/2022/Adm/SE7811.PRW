#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ SE7811	³ Autor ³ Nilton Pereura        ³ Data ³ 11.03.04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Normaliza os processos de orcamento adequando os processos  ³±±
±±³          ³ as exigencias da nova versão (8.11)                         |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SE7811()
Local aSaveArea	:= GetArea()
Local cFiltro
Local cAlias
Local lContinua	:= .T.
#IFDEF TOP
	Local aStru
#ENDIF

//-------------------------------------------------------
// Tratamento para executar somente se a versao base é 7
//-------------------------------------------------------
If _UPD811 .Or. _UPD101
	lContinua := .F.	
EndIf

If lContinua

	DbSelectArea("SE7")
	#IFDEF TOP
		aStru := SE7->(DbStruct())
		cFiltro := "SELECT R_E_C_N_O_ SE7RECNO "
		cFiltro += "  FROM "+	RetSqlName("SE7")
		cFiltro += " WHERE E7_FILIAL = '"+xFilial("SE7")+"'"
		cFiltro += " AND D_E_L_E_T_ <> '*' "
		cFiltro := ChangeQuery(cFiltro)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "TRBSE7", .F., .T.)
		aEval(aStru, {|e| If(e[2] != "C", TCSetField("TRBSE7", e[1], e[2],e[3],e[4]),Nil)})
		cAlias := "TRBSE7"
	#ELSE
		cIndex	:= CriaTrab(nil,.f.)
		cFiltro  := 'E7_FILIAL=="'+xFilial("SE7")+'"'	
		IndRegua("SE7",cIndex,IndexKey(1),,cFiltro,"Selecionando Registros...")
		nIndex	:= RetIndex("SE7")
		dbSetIndex(cIndex+OrdBagExt())
		dbSetOrder(nIndex+1)
		cAlias := "SE7"
	#ENDIF	

	dbSelectArea(cAlias)
	DbGoTop()
	UpdSet01(LastRec())
	While (cAlias)->(!Eof())
		UpdInc01("Updating SE7 - Orcamentos",.T.)
		#IFDEF TOP
			//Posiciono no SE7
			SE7->(DBGOTO((cAlias)->SE7RECNO))
		#ENDIF
		//Titulo gerador de Liquidacao
		dbSelectArea("SE7")
		If Reclock("SE7",.F.)
			Replace SE7->E7_CMOEDA With StrZero(SE7->E7_MOEDA,2)
			MsUnLock()			
		Endif
		DbSelectArea(cAlias)
		DbSkip()
	EndDo 
	#IFNDEF TOP
		dbSelectArea("SE7")
		dbClearFil()
		RetIndex( "SE7" )
		If !Empty(cIndex)
			FErase (cIndex+OrdBagExt())
		Endif
		dbSetOrder(1)
	#ELSE
		dbSelectArea("TRBSE7")
		dbCloseArea()
		dbSelectArea("SE7")
		dbSetOrder(1)
	#ENDIF

EndIf

RestArea(aSaveArea)
Return .T.
