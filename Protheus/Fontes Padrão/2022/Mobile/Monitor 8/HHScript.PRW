#INCLUDE "HHScript.ch"
#IFNDEF TOP
	#define RetSqlName RetDbfName
#ENDIF
Function HHScript(cGrupo, cSerie)
Local cPath         := GetSrvProfString("HHTrgDir","\HHTRG\")
Local cRootPath     := GetSrvProfString("RootPath","C:\AP7\")
Local cConnMCS      := GetMv("MV_MCSCON",,"ODBC")
Local cDsnMCS       := GetMv("MV_MCSDSN",,"SFA,siga,siga")
Local cMCSDir       := GetMv("MV_MCSDIR",,"")
Local cAliasTbl     := "ADV_TBL"
Local cAliasCols    := "ADV_COLS"
Local cAliasInd     := "ADV_IND"
Local cValidField   := "EMP"
Local cValidTable   := "ADV_COLS#ADV_IND#HHEMP"
Local cControlField := ""
Local cScrFile      := GetMv("MV_MCSSCR",, "")
Local lScrUser     := GetMv("MV_MSCRUSR",, "S") = "S" 
Local cTableSource  := ""
Local nTableId      := 0
Local cSentido      := ""
Local cSufixo       := ""
Local cEmpresa      := ""
Local cEmpFil       := ""
Local cUserEmp      := ""
Local cUserId       := ""
Local nHandle       := 0
Local nSpace        := 0
Local nI            := 1
Local nPos          := 0
Local cEmpFilter    := '"@@",'
Local cEmpScript    := "@@,"
Local cUsrFilter    := ""
Local cFilFilter    := ""
Local cFiltro       := "TBL_EMP = '@@' .Or."
Local aEmp          := {}
Local aData         := {}
Local aGenFilter    := {}
Local cGenFilter    := ""
Local cGenFld       := ""
Local nTimes        := 1
Local lInvalid      := .F.
Local lShare        := .F.
Local lSaveTable    := .F.
Local lGrScript 	:= .F.
// Ajusta RootPath
nPos := At(":", cRootPath)
If nPos > 0
	cRootPath := Subs(cRootPath, nPos + 1, If(Right(cRootPath, 1) != "\", Len(cRootPath), Len(cRootPath)-1))
EndIf
nPos := 0

If Select(cAliasTbl) = 0 .Or. Select(cAliasCols) = 0 .Or. Select(cAliasInd) = 0
	POpenMCSTbl()
EndIf

aStru    := (cAliasTbl)->(dbStruct())
aStruInd := (cAliasInd)->(dbStruct())

// Busca Empresas que o Usuario utiliza
dbSelectArea("HGU")
dbSetOrder(2)
dbSeek(cSerie)
While !HGU->(Eof()) .And. AllTrim(cSerie) = AllTrim(HGU->HGU_SERIE)
	dbSelectArea("HHG")
	dbSetOrder(1)
	If dbSeek(HGU->HGU_GRUPO)
		cUserEmp   += AllTrim(HHG_EMPFIL)
		cUserId    += AllTrim(HGU->HGU_CODBAS)
		cEmpFilter += '"' + SubStr(HHG_EMPFIL,1,2) + '",'
		cFilFilter += '"' + SubStr(HHG_EMPFIL,3,2) + '",'
		cUsrFilter += '"' + AllTrim(HGU->HGU_CODBAS) + '",'
		cEmpScript += SubStr(HHG_EMPFIL,1,2) + ','
		cFiltro    += "TBL_EMP = '" + SubStr(HHG_EMPFIL,1,2) + "' .Or. "
		aAdd(aEmp, {SubStr(HHG_EMPFIL,1,2), SubStr(HHG_EMPFIL,3,2), HHG_SUFIXO})
	EndIf
	HGU->(dbSkip())
EndDo
If Empty(cScrFile)
	If lScrUser
		cScrFile := "SCRIPT_" + cUserEmp + cUserId + ".MSCR"
	Else
		cScrFile := "SCRIPT_" + cUserEmp + ".MSCR"
	EndIf
EndIf
/*
For ni := 1 To Len(aEmp)
	cEmpFilter += '"' + aEmp[ni,1] + '",'
	cFilFilter += '"' + aEmp[ni,2] + '",'
	cFiltro    += "TBL_EMP = '" + aEmp[ni,1] + "' .Or. "
Next*/
cEmpFilter := Subs(cEmpFilter, 1, Len(cEmpFilter) - 1)
cEmpScript := '"' + Subs(cEmpScript, 1, Len(cEmpScript) - 1) + '"'
cFilFilter := Subs(cFilFilter, 1, Len(cFilFilter) - 1)
cUsrFilter := Subs(cUsrFilter, 1, Len(cUsrFilter) - 1)
cFiltro    := Subs(cFiltro, 1, Len(cFiltro) - 6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MV_CRIASCR                                    ³
//³0 = Nunca gera script                         ³
//³1 = Gera script quando não encontrar (default)³
//³2 = Sempre gera script                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Grava Cabecalho do SCRIPT
If File(cPath + cScrFile)
	If SuperGetMv("MV_CRIASCR",,"1") == "2"
		lGrScript := .T.
	EndIf
ElseIf SuperGetMv("MV_CRIASCR",,"1") <> "0"
	lGrScript := .T.
EndIf

If lGrScript
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
	FWrite(nHandle, 'SUPDATED  = "8"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'SDELETED  = "9"' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

	FWrite(nHandle, '// FORMATOS DE DATA E HORA //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'DATEHH = "YYYYMMDD"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'TIMEHH = "HH:MM"' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
	
	FWrite(nHandle, '// VARIAVEIS //' + Chr(13) + Chr(10))
	nPos := At(",", cDsnMCS)
	FWrite(nHandle, 'ODBC_DSN  = "' + Subs(cDsnMCS,1,nPos-1) + '"' + Chr(13) + Chr(10))
	cDsnMCS := Subs(cDsnMCS,nPos+1, Len(cDsnMcs))
	nPos := At(",", cDsnMCS)
	FWrite(nHandle, 'ODBC_USER = "' + Subs(cDsnMCS,1,nPos-1) +'"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'ODBC_PSW  = "' + Subs(cDsnMCS,nPos+1, Len(cDsnMcs)) + '"' + Chr(13) + Chr(10) + Chr(13) + Chr(10)) 

	// Estrutura do arquivo de Resumo
	FWrite(nHandle, '// Arquivo de Resumo //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_TBL        = "HHCTR"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_USER_ID    = "USERID"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_TABLENAME  = "TABLENAME"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_VERSION    = "VERSION"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_MAXVERSION = "MAXVERSION"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_AMNT       = "AMNT"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_GEN        = "GENERIC"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_FLDVER     = "FIELDVER"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_FLDCTR     = "FIELDCTRL"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_OPERATION  = "OPER"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_FLDEMP     = "EMP"' + Chr(13) + Chr(10))

	FWrite(nHandle, 'RESUMO_SELEMP = ' + cEmpScript + Chr(13) + Chr(10)+ Chr(13) + Chr(10))  
	
	// Parametros complementares
   	FWrite(nHandle, '// Parametros complementares //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'SUPRESSBLANK      = "NO"' + Chr(13) + Chr(10))


Else
	// Grava Nome do Script na tabela de Grupo x Handhelds
	dbSelectArea("HGU")
	dbSetOrder(1)
	If dbSeek(cGrupo+cSerie)
		RecLock("HGU", .F.)
		HGU->HGU_SCRIPT := cScrFile
		HGU->(MsUnlock())
	EndIf
	Return Nil
EndIf


// Grava Tabela de Catalogo pois ela nao esta nos registro do ADV_TBL
aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
aAdd(aData, "// Catalogo de Tabelas (ADV_TBL)" + Chr(13) + Chr(10))
aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
aAdd(aData, 'Source(' + cConnMCS + ', "ADV_TBL")' + Chr(13) + Chr(10))
aAdd(aData, "{" + Chr(13) + Chr(10))

aAdd(aData, Space(4) + 'Send("ADV_TBL", DBCREATORID, DBUSERID)' + Chr(13) + Chr(10))
aAdd(aData, Space(4) + "{" + Chr(13) + Chr(10))

aAdd(aData, Space(8) + 'primarykey("TBL_EMP+TBLNAME")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

aAdd(aData, Space(8) + 'filter("TBL_EMP", ' + cEmpFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

For nI := 1 To Len(aStru) - 2
	aAdd(aData, Space(8) + 'Field("' + AllTrim(aStru[nI,1]) + '")' + Chr(13) + Chr(10))	
Next
SaveTable(nHandle, @aData, "ADV_TBL", 1)

dbSelectArea(cAliasTbl)
(cAliasTbl)->(dbSetOrder(3)) // "TBL_EMP+TBLNAME+FLDPOS"
Set Filter To &(cFiltro)
(cAliasTbl)->(dbGoTop())
cTable     := ""
nTableId   := 0
cSentido   := 'Send("'
nSpace     := 0
lSaveTable := .T.
While !(cAliasTbl)->(Eof())
	// Carrega dados da Tabela
	cTable     := AllTrim((cAliasTbl)->TBLNAME)
	nTableId   := (cAliasTbl)->TABLEID
	cTableDesc := AllTrim((cAliasTbl)->TBLNAME)
	aData      := {}
	lSaveTable := .T.

	If cTable = "ADV_IND"
		cAlias := "ADVIND"
		cTableSource  := "ADV_IND"
		cControlField := "INTR"
	ElseIf cTable = "ADV_COLS"
		cAlias := "ADVCOL"
		cTableSource  := "ADV_COLS"
		cControlField := "INTR"
	ElseIf cTable = "HHEMP"
		cTableSource  := "HHEMP"
		cAlias := "HM0"
		cControlField := cAlias + "_INTR"
	Else
		cAlias := SubStr(cTable,1,3)
		If cEmpAnt $ cTable
			cTableSource := RetSqlName(cAlias)
		Else
			cTableSource := cTable
		EndIf
		cControlField := cAlias + "_INTR"
	EndIf
	
	cStrSource := 'Source(' + cConnMCS + ',"' + cTableSource
	
	dbSelectArea("HHT")   // Posicina Tabela
	dbSetOrder(2)
	If dbSeek(cAlias)
		lShare := If(HHT->HHT_SHARE == "T", .T., .F.) // Compartilha entre Empresas
	Else
		ConOut(STR0001 + Alltrim(cAlias) + STR0009) //"PALMJOB: Tabela nao encontrado para geracao do script de dados."
	EndIf
	
	// Definicao da Empresa / Sufixo
	If (AllTrim(cTable) $ cValidTable)
		lInvalid := .T.
		cEmpresa := "@@"
		cEmpFil  := cFilFilter
	Else
		nPos := aScan(aEmp, {|x| x[1] = Subs(cTable, 4, 2)})
		If nPos > 0
			cEmpresa := If(!lShare, aEmp[nPos, 1], "@@")
			cEmpFil  := cFilFilter
			cSufixo  := aEmp[nPos, 3]
		Else
			cEmpresa := If(!lShare, cEmpAnt, "@@")
			cEmpFil  := '"' + cFilAnt + '"'
			cSufixo  := "0"
		EndIf
	EndIf
	
	// Verifica filtro por Empresa
	If !Empty(cEmpresa) .And. HHT->HHT_FILEMP != "T"  // Filtra Empresa
		If lShare
			cStrSource += '","##")'
		Else			
			cStrSource += '","' + cEmpresa + '")'
		EndIf
	Else
		If lShare
			cStrSource += '","##")'
		Else
			cStrSource += '")'
		EndIf
	EndIf

	// Cabecalho da Tabela
	aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
	aAdd(aData, "// " + cTableDesc + "(" + cTable + ")" + Chr(13) + Chr(10))
	aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
	
	aAdd(aData, cStrSource  + Chr(13) + Chr(10))
	aAdd(aData, "{" + Chr(13) + Chr(10))
	
	aAdd(aData, Space(4) + cSentido + cTable + '", DBCREATORID, DBUSERID)' + Chr(13) + Chr(10))
	aAdd(aData, Space(4) + "{" + Chr(13) + Chr(10))

	dbSelectArea("HHT")
	dbSetOrder(2)
	If dbSeek(cAlias)
		nTimes := If(HHT->HHT_TOHOST = "T" , 2, 1)
		If HHT->HHT_GEN = "1"  // Tabela Generica
			If HHT->HHT_FILEMP = "T"    // Filtra Empresa
				If !lInvalid
					If Len(cAlias) < 3
						aAdd(aData, Space(8) + 'Filter(' +  cAlias + '_EMP, ' + cEmpFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
					Else
						aAdd(aData, Space(8) + 'Filter("TBL_EMP", ' + cEmpFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
					EndIf
				Else
					aAdd(aData, Space(8) + 'Filter("TBL_EMP", ' + cEmpFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
				EndIf
			EndIf                
		ElseIf HHT->HHT_GEN = "2" // Tabela Nao Generica
			If lShare
				aAdd(aData, Space(8) + 'Filter("' +  cAlias + "_ID" + '",' + cUsrFilter +  ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
			Else
				aAdd(aData, Space(8) + 'Filter("' +  cAlias + "_ID" + '")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
   			EndIf
			If HHT->HHT_FILEMP = "T"
				aAdd(aData, Space(8) + 'Filter(' +  cAlias + '_EMP, ' + cEmpFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
			EndIf

			aAdd(aData, Space(8) + 'Control("' +  cControlField + '")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para filtro de tabelas                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		If ExistBlock("HHSCR01")
			aGenFilter := ExecBlock("HHSCR01", .F., .F., {cTable, cAlias, cUserId,If(HHT->HHT_GEN = "1",.T.,.F.)})
			nGenFilter := Len(aGenFilter)
			If nGenFilter > 0
				cGenFilter := ""
				For nI := 2 to Len(aGenFilter)
					cGenFilter += '"' + aGenFilter[nI] + '",'
				Next
				cGenFld := aGenFilter[1]
				cGenFilter := SubStr(cGenFilter, 1, Len(cGenFilter)-1)
				aAdd(aData, Space(8) + 'Filter("' + cGenFld +'",' + cGenFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
			EndIf
		EndIf		
		If !(cTable $ "ADV_TBL#ADV_IND#ADV_COLS")
			If !lShare
				If (cAliasTbl)->TBLTP = "1"
					aAdd(aData, Space(8) + 'Filter("' +  cAlias + '_FILIAL",' + cEmpFil + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
				EndIf
			EndIf
		EndIf
	EndIf
	
	/// Procura Chave Primaria
	cNomeIdx := cTable + "1"
	dbSelectArea(cAliasInd)
	dbSetOrder(1)
	cChavePK := cEmpresa + Str(nTableId,4,0) + cNomeIdx
	If (cAliasInd)->(dbSeek(cChavePK))
		aAdd(aData, Space(8) + 'PrimaryKey("' + AllTrim((cAliasInd)->EXPRE) + '")' + Chr(13) + Chr(10))
		aAdd(aData, Chr(13) + Chr(10))
	Else
		ConOut(STR0002 + cTable + STR0003 + cEmpresa + STR0004) //"Indices da tabela "###", para a empresa "###" nao encontrados na ADV_IND."
		lSaveTable := .F.
	EndIf

	// Campos no Script	
	dbSelectArea(cAliasCols)
	dbSetOrder(1)
	If dbSeek(cEmpresa + Str(nTableId,4,0))
		While !(cAliasCols)->(Eof()) .And. nTableId = (cAliasCols)->TABLEID
			aAdd(aData, Space(8) + 'Field("' + AllTrim((cAliasCols)->FLDNAME) + '")' + Chr(13) + Chr(10))
			(cAliasCols)->(dbSkip())
		EndDo
	Else
		ConOut(STR0005 + cTable + STR0003 + cEmpresa + STR0006) //"Campos da tabela "###", para a empresa "###" nao encontrados na ADV_COLS."
		lSaveTable := .F.
	EndIf

	// Gera Script
	If lSaveTable
		SaveTable(nHandle, @aData, cTable, nTimes)
	EndIf
	(cAliasTbl)->(dbSkip())
EndDo
Set Filter To 
(cAliasTbl)->(dbCloseArea())
(cAliasInd)->(dbCloseArea())
FClose(nHandle)
ConOut(STR0007 + cRootPath + cPath + cScrFile) //"PALMJOB: Script criado com sucesso. "
//ConOut(cRootPath + cPath + cScrFile)
//ConOut(cMCSDir + cScrFile)
//CpyS2T((cRootPath + cPath + cScrFile), cMCSDir,.T.)
ConOut(STR0008) //"PALMJOB: O Arquivo deve ser copiado para o diretório de instalação do MCS Server."
/*
If !Empty(cMCSDir)
	__CopyFile((cRootPath + cPath + cScrFile), (cMCSDir + cScrFile))
	ConOut("PALMJOB: Arquivo copiado para o diretório de instalação do MCS Server, " + cMCSDir)
Else
	ConOut("PALMJOB: Arquivo não copiado para o diretório de instalação do MCS Server, configurara parâmetro MV_MCS")
EndIf*/
dbSelectArea("HGU")
dbSetOrder(1)
If dbSeek(cGrupo+cSerie)
	RecLock("HGU", .F.)
	HGU->HGU_SCRIPT := cScrFile
	HGU->(MsUnlock())
EndIf
Return
/*
Function HHScript2(cGrupo, cSerie)
Local cPath         := GetSrvProfString("HHTrgDir","\HHTRG\")
Local cRootPath     := GetSrvProfString("RootPath","C:\AP7\")
Local cConnMCS      := GetMv("MV_MCSCON",, "ODBC")
Local cMCSDir       := GetMv("MV_MCSDIR",,"")
Local cAliasTbl     := "ADV_TBL"
Local cAliasInd     := "ADV_IND"
Local cValidField   := "EMP"
Local cValidTable   := "ADV_IND#HHEMP"
Local cForAllEmp    := "HHEMP"
Local cControlField := ""
Local cScrFile      := ""
Local cTableName    := ""
Local cTableSource  := ""
Local nTableId      := 0
Local cSentido      := ""
Local cSufixo       := ""
Local cEmpresa      := ""
Local cEmpFil       := ""
Local cUserEmp      := ""
Local nHandle       := 0
Local nSpace        := 0
Local nI            := 1
Local nPos          := 0
Local cEmpFilter    := ""
Local aEmp          := {}
Local aData         := {}
Local nTimes        := 1
// Ajusta RootPath
nPos := At(":", cRootPath)
If nPos > 0
	cRootPath := Subs(cRootPath, nPos + 1, If(Right(cRootPath, 1) != "\", Len(cRootPath), Len(cRootPath)-1))
EndIf
nPos := 0

If Select(cAliasTbl) = 0 .Or. Select(cAliasInd) = 0
	POpenMCSTbl()
EndIf
aStru := (cAliasTbl)->(dbStruct())
aStruInd:=(cAliasInd)->(dbStruct())

// Busca Empresas que o Usuario utiliza
dbSelectArea("HGU")
dbSetOrder(2)
dbSeek(cSerie)
While !HGU->(Eof()) .And. AllTrim(cSerie) = AllTrim(HGU->HGU_SERIE)
	dbSelectArea("HHG")
	dbSetOrder(1)
	If dbSeek(HGU->HGU_GRUPO)
		cUserEmp += SubStr(HHG_EMPFIL,1,2)
		aAdd(aEmp, {SubStr(HHG_EMPFIL,1,2), SubStr(HHG_EMPFIL,3,2), HHG_SUFIXO})
	EndIf
	HGU->(dbSkip())
EndDo
cScrFile := "SCRIPT_" + cUserEmp + ".MSCR"

// Grava Cabecalho do SCRIPT
If !File(cPath + cScrFile) 
	nHandle := FCreate(cPath + cScrFile)
	FWrite(nHandle, Replicate('/', 80 ) + Chr(13) + Chr(10))
	FWrite(nHandle, "// Script gerado automaticamente em " + DtoC(Date()) + Chr(13) + Chr(10))
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
	FWrite(nHandle, 'SUPDATED  = "8"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'SDELETED  = "9"' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

	FWrite(nHandle, '// FORMATOS DE DATA E HORA //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'DATEHH = "YYYYMMDD"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'TIMEHH = "HH:MM"' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
	
	FWrite(nHandle, '// VARIAVEIS //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'ODBC_DSN  = "SFA"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'ODBC_USER = "siga"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'ODBC_PSW  = "siga"' + Chr(13) + Chr(10) + Chr(13) + Chr(10)) 

	// Estrutura do arquivo de Resumo
	FWrite(nHandle, '// Arquivo de Resumo //' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_TBL = "HHCTR"' + Chr(13) + Chr(10))
	FWrite(nHandle, 'RESUMO_USER_ID = "USERID"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_TABLENAME = "TABLENAME"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_VERSION = "VERSION"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_LASTKEY = "LASTKEY"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_MAXVERSION = "MAXVERSION"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_AMNT = "AMNT"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_FLDVER = "FIELDVER"' + Chr(13) + Chr(10))
    FWrite(nHandle, 'RESUMO_OPERATION = "OPER"' + Chr(13) + Chr(10)+ Chr(13) + Chr(10))
Else
	// Grava Nome do Script na tabela de Grupo x Handhelds
	dbSelectArea("HGU")
	dbSetOrder(1)
	If dbSeek(cGrupo+cSerie)
		RecLock("HGU", .F.)
		HGU->HGU_SCRIPT := cScrFile
		HGU->(MsUnlock())
	EndIf
	Return Nil
EndIf


// Grava Tabela de Catalogo pois ela nao esta nos registro do ADV_TBL
aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
aAdd(aData, "// Catalogo de Tabelas (ADV_TBL)" + Chr(13) + Chr(10))
aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
aAdd(aData, 'Source(' + cConnMCS + ', "ADV_TBL")' + Chr(13) + Chr(10))
aAdd(aData, "{" + Chr(13) + Chr(10))

aAdd(aData, Space(4) + 'Send("ADV_TBL", DBCREATORID, DBUSERID)' + Chr(13) + Chr(10))
aAdd(aData, Space(4) + "{" + Chr(13) + Chr(10))

aAdd(aData, Space(8) + 'primarykey("TBLNAME+FLDPOS")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

For ni := 1 To Len(aEmp)
	cEmpFilter += '"' + aEmp[ni,1] + '",'
Next
cEmpFilter := Subs(cEmpFilter, 1, Len(cEmpFilter) - 1)

aAdd(aData, Space(8) + 'filter("TBL_EMP", ' + cEmpFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))

For nI := 1 To Len(aStru) - 3
	aAdd(aData, Space(8) + 'Field("' + AllTrim(aStru[nI,1]) + '")' + Chr(13) + Chr(10))	
Next
SaveTable(nHandle, @aData, "ADV_TBL", 1)

//(cAliasTbl)->(dbSetOrder(3)) // "TBL_EMP+TBLNAME+FLDPOS"
//(cAliasTbl)->(dbGoTop())
cTable     := ""
cTableName := ""
nTableId   := 0
cSentido   := 'Send("'
nSpace     := 0
lTable := .F.

HHG->(dbSeek(cGrupo))    // Posiciona Grupo
HGS->(dbSeek(cGrupo))    // Posiciona Grupo x Servicos

While !HGS->(Eof()) .And. HGS->HGS_GRUPO = cGrupo
	HHR->(dbSeek(HGS->HGS_SRV))  // Posiciona Tabela de Servico
	cTables := HHR->(HHR->HHR_ARQ) // Alias criados pelo servico

	nPos := At(",", cTables)
	If nPos = 0
		cAlias := cTables
	Else
		cAlias := Subs(cTables, 1, If(nPos !=0,nPos-1,Len(cTables)))
	EndIf

	dbSelectArea(cRetAlias) 
	cTableName := RetSqlName(cRetAlias)	 // Tabela gravada no script
    
	cQueryTbl := "SELECT * FROM ADV_TBL WHERE TBLNAME = '" + cTableName + "' AND TBL_EMP = '" + cEmpAnt + "'" 
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"SCRIPT",.F.,.T.)
	SCRIPT->(dbGotop())
	aData := {}
    cEmpresa := cEmpAnt
	// Carrega dados da Proxima Tabela
	cTableDesc := AllTrim((cAliasTbl)->TBLNAME)

		// Cabecalho da Tabela
		aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
		aAdd(aData, "// " + cTableDesc + "(" + cTableName + ")" + Chr(13) + Chr(10))
		aAdd(aData, Replicate("/", 80) + Chr(13) + Chr(10))
		aAdd(aData, 'Source(' + cConnMCS + ',"' + cTable + If(!Empty(cEmpresa),'","' + cEmpresa + '")','")')  + Chr(13) + Chr(10))
		aAdd(aData, "{" + Chr(13) + Chr(10))
		
		aAdd(aData, Space(4) + cSentido + cTableName + '", DBCREATORID, DBUSERID)' + Chr(13) + Chr(10))
		aAdd(aData, Space(4) + "{" + Chr(13) + Chr(10))
      
		dbSelectArea("HHT")
		dbSetOrder(2)
		If dbSeek(cAlias)
			nTimes := If(HHT->HHT_TOHOST = "T" , 2, 1)
			If HHT->HHT_GEN = "1"  // Tabela Generica
				If HHT->HHT_FILEMP = "T"
					If !(AllTrim(cTable) $ cValidTable) 
						aAdd(aData, Space(8) + 'Filter(' +  cAlias + '_EMP, ' + cEmpFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
					Else
						aAdd(aData, Space(8) + 'Filter("TBL_EMP", ' + cEmpFilter + ')' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
					EndIf
				EndIf
			ElseIf HHT->HHT_GEN = "2" // Tabela Nao Generica
				aAdd(aData, Space(8) + 'Filter("' +  cAlias + "_ID" + '")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
				aAdd(aData, Space(8) + 'Filter("' +  cAlias + '_FILIAL","' + cEmpFil + '")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
				aAdd(aData, Space(8) + 'Control("' +  cControlField + '")' + Chr(13) + Chr(10) + Chr(13) + Chr(10))
			EndIf	
		EndIf

		cNomeIdx := cTableName + "1"
		dbSelectArea(cAliasInd)
		
 		If cTableName $ cValidTable
    		dbSetOrder(1)
	 		cChavePK := cTableName + Space(15-Len(cTableName)) + cNomeIdx
    	Else
    		dbSetOrder(2)
 			cChavePK := cEmpresa + cTableName + Space(15-Len(cTableName)) + cNomeIdx
	 	EndIf
		If (cAliasInd)->(dbSeek(cChavePK))
			While !(cAliasInd)->(Eof()) .And. (cAliasTbl)->TBLNAME = (cAliasInd)->TBLNAME
				If (cAliasInd)->PK = "T"
					aAdd(aData, Space(8) + 'PrimaryKey("' + AllTrim((cAliasInd)->EXPRE) + '")' + Chr(13) + Chr(10))
				//Else
					//aAdd(aData, Space(8) + 'Index("' + AllTrim((cAliasInd)->NOME_IDX) + '","' + AllTrim((cAliasInd)->EXPRE) + '")'  + Chr(13) + Chr(10))
				EndIf
				(cAliasInd)->(dbSkip())
			EndDo
			aAdd(aData, Chr(13) + Chr(10))			
		EndIf
	EndIf
    While !SCRIPT->(Eof())
		aAdd(aData, Space(8) + 'Field("' + AllTrim((cAliasTbl)->FLDNAME) + '")' + Chr(13) + Chr(10))
		SCRIPT->(dbSkip())
	EndDo	
	SCRIPT->(dbCloseArea())
	(cAliasTbl)->(dbSkip())
	SaveTable(nHandle, @aData, cTableName, nTimes)
EndDo
(cAliasTbl)->(dbCloseArea())
(cAliasInd)->(dbCloseArea())
FClose(nHandle)
ConOut("PALMJOB: Script criado com sucesso. " + cRootPath + cPath + cScrFile)
//ConOut(cRootPath + cPath + cScrFile)
//ConOut(cMCSDir + cScrFile)
//CpyS2T((cRootPath + cPath + cScrFile), cMCSDir,.T.)
ConOut("PALMJOB: O Arquivo deve ser copiado para o diretório de instalação do MCS Server.")
/*
If !Empty(cMCSDir)
	__CopyFile((cRootPath + cPath + cScrFile), (cMCSDir + cScrFile))
	ConOut("PALMJOB: Arquivo copiado para o diretório de instalação do MCS Server, " + cMCSDir)
Else
	ConOut("PALMJOB: Arquivo não copiado para o diretório de instalação do MCS Server, configurara parâmetro MV_MCS")
EndIf
dbSelectArea("HGU")
dbSetOrder(1)
If dbSeek(cGrupo+cSerie)
	RecLock("HGU", .F.)
	HGU->HGU_SCRIPT := cScrFile
	HGU->(MsUnlock())
EndIf
Return
*/


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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDbfNameºAutor  ³Rodrigo  A. Godinho º Data ³  02/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o nome fisico da tabela.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cAlias - alias da tabela.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³String com nome fisico da tabela.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³HHXAPI                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetDbfName(cAlias)
Local aArea		:=	GetArea()
Local aAreaSX2	:=	SX2->(GetArea())
Local cRet		:=	"" 

dbSelectArea("SX2")
SX2->(dbSetOrder(1))

If SX2->(dbSeek(cAlias))
	cRet := SX2->X2_ARQUIVO
EndIf

RestArea(aAreaSX2)
RestArea(aArea)
Return cRet
