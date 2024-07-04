Function McsScript(cDir)
Local cPath := GetSrvProfString("HandHeldDir","\handheld\")
Local cRootPath := GetSrvProfString("RootPath","\HANDHELD\")
Local cTblFile   := "ADV_TBL"
Local cIndFile   := "ADV_IND"
Local cScrFile   := "SCRIPT.MSCR"
Local nTable     := ""
Local cTableName := ""
Local cSentido   := ""
Local nHandle    := 0
Local nSpace     := 0
Local nI := 1
Local aData := {}
Local cDriver := GetLocalDBF()

If !File(cPath + cScrFile) 
	nHandle := FCreate(cPath + cScrFile)
	FWrite(nHandle, Replicate('/', 80 ) + Chr(13) + Chr(10))
	FWrite(nHandle, "// Script gerado automaticamente em " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
	FWrite(nHandle, "//" + Chr(13) + Chr(10))	
	FWrite(nHandle, "// Este Script deve ser utilizado apenas com programas versao eAdvpl." + Chr(13) + Chr(10))
	FWrite(nHandle, "//" + Chr(13) + Chr(10))	
	FWrite(nHandle, "// Microsiga Software S/A - Departamento de Handheld" + Chr(13) + Chr(10))
	FWrite(nHandle, Replicate('/', 80 ) + Chr(13) + Chr(10) + Chr(13) + Chr(10))

	FWrite(nHandle, '// FLAGS //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'AINSERT   = "I"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'AUPDATE   = "A"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'ADELETE   = "E"' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

	FWrite(nHandle, 'CINSERT   = "1"' + Chr(13) + Chr(10))	
	FWrite(nHandle, 'CUPDATE   = "2"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'CDELETE   = "3"' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

	FWrite(nHandle, 'SNONE     = ""'  + Chr(13) + Chr(10))
	FWrite(nHandle, 'SNEW 	   = "N"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'SINSERTED = "7"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'SUPDATED  = "8"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'SDELETED  = "9"' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

	FWrite(nHandle, '// FORMATOS DE DATA E HORA //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'DATEHH = "YYYYMMDD"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'TIMEHH = "HH:MM"' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
	
	FWrite(nHandle, '// VARIAVEIS //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'DBASE_DIR = "' + cRootPath + cPath + 'p$(USER_ID)\DIFS\"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'DBCREATORID = ""' + Chr(13) + Chr(10))
	FWrite(nHandle, 'DBUSERID = ""' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

	// Estrutura do arquivo de Resumo
	FWrite(nHandle, 'RESUMO_TBL = "hhctr"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_TABLENAME = "TABLENAME"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_LASTKEY = "LASTKEY"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_AMNT = "AMNT"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_OPERATION = "OPER"' + Chr(13) + Chr(10)+ Chr(13) + Chr(10))

Else
	Return Nil
EndIf

dbUseArea(.T.,cDriver,cDir + "\DIFS\" + cTblFile + ".DBF","TBL",.F.)
INDEX ON Str(TABLEID,5,0)+FLDPOS TO (cDir+cTblFile)

// Grava Tabela de Catalogo pois ela nao esta nos registro do ADV_TBL
aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
aAdd(aData, "// Catalogo de Tabelas (ADV_TBL)" + Chr(13) + Chr(10))
aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
aAdd(aData, 'Source(DBASE, "adv_tbl")' + Chr(13) + Chr(10))
aAdd(aData, "{" + Chr(13) + Chr(10))

aAdd(aData, Space(4) + 'Send("ADV_TBL", DBCREATORID, DBUSERID)' + Chr(13) + Chr(10))
aAdd(aData, Space(4) + "{" + Chr(13) + Chr(10))

aAdd(aData, Space(8) + 'Control("INTR")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
aAdd(aData, Space(8) + 'primarykey("TBLNAME+FLDPOS")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

aStru := TBL->(dbStruct())
For nI := 1 To Len(aStru) - 1
	aAdd(aData, Space(8) + 'Field("' + AllTrim(aStru[nI,1]) + '")' + Chr(13) + Chr(10))	
Next
SaveTable(nHandle, @aData, "adv_tbl", 1)


dbUseArea(.T.,cDriver,cDir + "\DIFS\" + cIndFile + ".DBF","IND",.F.)
INDEX ON TBLNAME+NOME_IDX TO (cDir + cIndFile)

TBL->(dbGoTop())
nTable     := -1
cTableName := ""
nTimes     := If(TBL->TBLTOHOST = "T", 2, 1)
cSentido   := 'Send("'
nSpace     := 0
While !TBL->(Eof())
	If nTable != TBL->TABLEID
        // Salva as tabelas no Arquivo
		If !Empty(cTableName)
			SaveTable(nHandle, @aData, cTableName, nTimes)
		EndIf

		// Carrega dados da Proxima Tabela
		nTable     := TBL->TABLEID
		cTableName := AllTrim(TBL->TBLNAME)
		cTableDesc := AllTrim(TBL->TBLNAME) //AllTrim(TBL->TBLDESCR)
		nTimes     := If(TBL->TBLTOHOST = "T" , 2, 1)

		// Cabecalho da Tabela
		aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
		aAdd(aData, "// " + cTableDesc + "(" + cTableName + ")" + Chr(13) + Chr(10))
		aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
		aAdd(aData, 'Source(DBASE, "' + Lower(cTableName) + '")' + Chr(13) + Chr(10))
		aAdd(aData, "{" + Chr(13) + Chr(10))
		
		aAdd(aData, Space(4) + cSentido + cTableName + '", DBCREATORID, DBUSERID)' + Chr(13) + Chr(10))
		aAdd(aData, Space(4) + "{" + Chr(13) + Chr(10))

		aAdd(aData, Space(8) + 'Control("INTR")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
		
		dbSelectArea("IND")
		dbSetOrder(1)
		If dbSeek(TBL->TBLNAME)
			While TBL->TBLNAME == IND->TBLNAME
				If IND->PK = "T"
					aAdd(aData, Space(8) + 'PrimaryKey("' + AllTrim(IND->EXPRE) + '")' + Chr(13) + Chr(10))
				Else
					aAdd(aData, Space(8) + 'Index("' + AllTrim(IND->NOME_IDX) + '","' + AllTrim(IND->EXPRE) + '")'  + Chr(13) + Chr(10))
				EndIf
				IND->(dbSkip())
			EndDo
			aAdd(aData, Chr(13) + Chr(10))			
		EndIf
	EndIf	
	aAdd(aData, Space(8) + 'Field("' + AllTrim(TBL->FLDNAME) + '")' + Chr(13) + Chr(10))
	TBL->(dbSkip())
	If TBL->(EOF())
		SaveTable(nHandle, @aData, cTableName, nTimes)
	EndIf
EndDo
TBL->(dbCloseArea())
IND->(dbCloseArea())
FClose(nHandle)
ConOut("PALMJOB: Script criado com sucesso. " + cRootPath + cPath + cScrFile)
Return

Static Function SaveTable(nHandle, aData, cTableName, nTimes)
Local nI := 0
Local nJ := 0


For nI := 1 To nTimes
	// Altera para gravacao do Receive
	If nI = 2
		nPos := 6
		//aScan(aData, {|x| Subs(x[1],1,5) == "Send("})
		If nPos != 0
			aData[nPos] := 	Space(4) + 'Receive("' + AllTrim(cTableName) + '", DBCREATORID, DBUSERID)' + Chr(13) + Chr(10)
		EndIf
	EndIf
	For nJ := 1 To Len(aData)
		FWrite(nHandle, aData[nJ])
	Next
	FWrite(nHandle, Space(4) + "}" + Chr(13) + Chr(10))
	FWrite(nHandle, "}" + Chr(13) + Chr(10) + Chr(13) + Chr(10))
Next

aData := {}

Return Nil