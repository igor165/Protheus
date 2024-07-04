#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ SE1811	³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 11.12.03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Normaliza os processos de liquidacao e reliquidacao adequan-³±±
±±³          ³ do os processos as exigencias da nova versão (8.11)         |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SE1811( )
Local aSaveArea	:= GetArea()
Local cFile		:= "SE1"+cEmpAnt+"UPD.log"
Local nHdlFile	:= 0
Local cQuery		:= ""
Local lContinua	:= .T.

//-------------------------------------------------------
// Tratamento para executar somente se a versao base é 7
//-------------------------------------------------------
If _UPD811 .Or. _UPD101
	lContinua := .F.	
EndIf

If lContinua

	DbSelectArea("SE1")
	DbSetOrder(1)
	If Empty(xFilial("SE1")) .and. File(cFile)
		Return .T.				/// SE O ARQUIVO É COMPARTILHADO E O ARQUIVO LOG JA EXISTE (JA RODOU) CANCELA.
	Endif

	#IFDEF TOP
		If TcSrvType()<>"AS/400"
			cQuery := "UPDATE "
			cQuery += RetSqlName("SE1")+" "
			cQuery += " SET E1_NUMLIQ = '     ' "
			cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'"
			cQuery += " AND E1_NUMLIQ <> '"+ Space(Len(E1_NUMLIQ))+"'" 
			cQuery += " AND E1_BCOCHQ = '"+ Space(Len(E1_BCOCHQ))+"'" 
			cQuery += " AND E1_STATUS <> 'R' "
			cQuery += " AND D_E_L_E_T_= ' ' "
	
			TcSqlExec(cQuery)
		Endif
	#ELSE
		cIndex	:= CriaTrab(nil,.f.)
		cFiltro  := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'	
		cFiltro	+= "E1_NUMLIQ <> '" + Space(Len(E1_NUMLIQ))+"'.and."
		cFiltro	+= "Empty(E1_BCOCHQ)"
		IndRegua("SE1",cIndex,IndexKey(1),,cFiltro,"Selecionando Registros...")
		nIndex	:= RetIndex("SE1")
		dbSetIndex(cIndex+OrdBagExt())
		dbSetOrder(nIndex+1)
		cAlias := "SE1"
	
		dbSelectArea(cAlias)
		DbGoTop()
		UpdSet01(LastRec())
		While (cAlias)->(!Eof())
			UpdInc01("Updating SE1 - Liquidacoes",.T.)
			//Titulo gerador de Liquidacao
			dbSelectArea("SE1")
			If !Empty(E1_NUMLIQ) .and. Empty(E1_BCOCHQ) .and. E1_STATUS != "R"
				If Reclock("SE1",.F.)
					REPLACE E1_NUMLIQ With Space(6)
					MsUnLock()			
				Endif
			EndIf
			DbSelectArea(cAlias)
			DbSkip()
		EndDo 
	
		dbSelectArea("SE1")
		dbClearFil()
		RetIndex( "SE1" )
		If !Empty(cIndex)
			FErase (cIndex+OrdBagExt())
		Endif
		dbSetOrder(1)
	#ENDIF

	If Empty(xFilial("SE1")) .and. !File(cFile)		/// SE O SE1 ESTIVER COMPARTILHADO E NÃO EXISTIR O ARQUIVO DE LOG EM DISCO
		nHdlFile := MsFCreate(cFile,0)				/// CRIA O ARQUIVO DE LOG (FLAG) PARA INDICAR QUE NÃO DEVE PROCESSAR NOVAMENTE.
		If nHdlFile > 0
			FWRITE(nHdlFile,"Este arquivo pode ser excluido apos a atualizacao de versao."+CHR(13)+CHR(10)+;
							"This file can be erased after the version update."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							"Arquivo SE1 - Empresa "+cEmpAnt +" - compartilhado - concluido."+CHR(13)+CHR(10)+;
							"SE1 File - Company "+cEmpAnt +" - shared - finished."+CHR(13)+CHR(10),312)
			FClose(nHdlFile)
		EndIf
	EndIf     

EndIf

RestArea(aSaveArea)

Return .T.