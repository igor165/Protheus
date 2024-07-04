#include "protheus.ch"
#include "Fileio.ch"

#define PUALIAS	"PALMUSER"
#define PSALIAS	"PALMSERV"
#define PCALIAS	"PALMCOND"
#define PLALIAS	"PALMLOG"
#define PTALIAS	"PALMTIME"
#define PFALIAS"PALMFILE"

#define PUFILE	"HHUSER"
#define PSFILE	"HHSERV"
#define PCFILE	"HHCOND"
#define PLFILE	"HHLOG"
#define PTFILE	"HHTIME"
#define PFFILE	"HHFILE"

//#define PDRIVER	"BTVCDX"
#define PDRIVER "DBFCDX"
//#define PALMDIR "\HANDHELD\"
#define DBFEXT ".DBF"
#define PEXTARQ ".DTC"
#define PEXTIND ".INT"

/*
*************************************************
* PALMUSER: (arquivo de usuarios)				*
* P_SERIE		C	20							*
* P_USER		C	30							*
* P_MAIL		C	120							*
* P_USERID		C	6							*
* P_CODVEND		C	6							*
* P_FREQ		N	3							*
* P_FTIPO		C	1							*
* P_DEVICE		C	1							*
* P_SISTEMA		C	1							*
* P_LOCK		C	1							*
*************************************************

*************************************************
* PALMSERV: (arquivo de servicos)				*
* P_ID			C	10							*
* P_SERIE		C	20							*
* P_EMPFI		C	4							*
* P_TIPO		C	10							*
* P_CLASSE		C	1							*
*************************************************

*************************************************
* PALMLOG: (arquivo de log)						*
* P_SERIE		C	20							*
* P_ID			C	10							*
* P_LOGID		C	10							*
* P_DATA		D	8							*
* P_HRINI		C	6							*
* P_HRFIM		C	6							*
* P_DESC		C	255							*
*************************************************

*************************************************
* PALMTIME: (arquivo de controle de tempo)		*
* P_SERIE		C	20							*
* P_TIME		C	8							*
* P_RANGE		C	8							*
*************************************************

*************************************************
* aPTipos										*
* [1] -> descricao								*
* [2] -> servico								*
* [3] -> funcao que retorna alias usados		*
* [4] -> funcao que retorna indices usados		*
* [5] -> funcao que retorna o nome fisico das	*
*	     tabelas								*
* [6] -> classe									*
* [7] -> alias 									*
* [8] -> indices								*
* [9] -> nome fisico							*
*************************************************
*/

Static aPTipos
Static __PError
Static __PInJob := .F.
Static __nHdl
Static cLastLog := Replicate("0",10)
Static __LogID
Static PALMDIR := GetSrvProfString("HandHeldDir","\HANDHELD\")
Static cOper := ""

/*
*************************************************
* Funcoes p/ abertura dos arquivos do palm		*
*************************************************

*************************************************
* POpenUser()									*
* verifica se a tabela PALMUSER e seus indices	*
* existem e cria se necessario;					*
* abre a tabela e indices						*
*************************************************
*/
Function POpenUser()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PUFILE
Local nI := 0
Local nTry := 3
Local cDriver := GetLocalDBF()
/*
If ( MsFile(cFile,,"BTVCDX") )
	PUpdJob(cFile)
EndIf
*/

If ( Select(PUALIAS) == 0 )
	aStru := {}
	Aadd(aStru,{"P_SERIE"  ,"C", 20,0})
	Aadd(aStru,{"P_USER"   ,"C", 30,0})
	Aadd(aStru,{"P_MAIL"   ,"C",120,0})
	Aadd(aStru,{"P_USERID" ,"C",  6,0})
	Aadd(aStru,{"P_CODVEND","C",  6,0})
	Aadd(aStru,{"P_FREQ"   ,"N",  3,0})
	Aadd(aStru,{"P_FTIPO"  ,"C",  1,0})
	Aadd(aStru,{"P_DIR"    ,"C",  8,0})
	Aadd(aStru,{"P_DEVICE" ,"C",  1,0})
	Aadd(aStru,{"P_SISTEMA","C",  1,0})
	Aadd(aStru,{"P_LOCK"   ,"C",  1,0})
	Aadd(aStru,{"P_DELDATA"   ,"C",  1,0})
	If ( !MsFile(cFile+DBFEXT,,cDriver) )
        MsCreate(cFile+DBFEXT,aStru,cDriver,.T.)
//	Else
//		PChkStru(cFile, "P_DELDATA", aStru)
	EndIf
	DbUseArea(.T.,cDriver,cFile+DBFEXT,PUALIAS,.T.)
	If Select(PUALIAS) == 0
		For nI := 1 To nTry
			ConOut("PALMJOB: Abertura HHUSER.DBF falhou !!!")
			Sleep(1000)
			DbUseArea(.T.,cDriver,cFile+DBFEXT,PUALIAS,.T.)
			If Select(PUALIAS) != 0
				Exit
			EndIf
		Next nI	
	EndIf
	cIndex := PUFILE+"1"
	If ( !File(cFile + ".CDX") )
	//If ( !MsFile(cFile,cIndex,PDRIVER) )
		INDEX ON P_SERIE TAG &cIndex TO &cFile
		cIndex := PUFILE+"2"
		INDEX ON P_USER  TAG &cIndex TO &cFile
		cIndex := PUFILE+"3"
		INDEX ON P_DIR  TAG &cIndex TO &cFile
		cIndex := PUFILE+"4"
		INDEX ON P_LOCK  TAG &cIndex TO &cFile		
		dbCloseArea()
		DbUseArea(.T.,cDriver,cFile+DBFEXT,PUALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return PUALIAS

/*/
*************************************************
* POpenServ()									*
* verifica se a tabela PALMSERV e seus indices	*
* existem e cria se necessario;					*
* abre a tabela e indices						*
*************************************************
/*/
Function POpenServ()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PSFILE
Local cDriver := GetLocalDBF()

If ( Select(PSALIAS) == 0 )
	If ( !MsFile(cFile + DBFEXT,,cDriver) )
		aStru := {}
		Aadd(aStru,{"P_ID"     ,"C", 10,0})
		Aadd(aStru,{"P_SERIE"  ,"C", 20,0})
		Aadd(aStru,{"P_EMPFI"  ,"C",  4,0})
		Aadd(aStru,{"P_TIPO"   ,"C", 20,0})
		Aadd(aStru,{"P_CLASSE" ,"C",  1,0})
        MsCreate(cFile+DBFEXT,aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+DBFEXT,PSALIAS,.T.)
	cIndex := PSFILE+"1"
	If ( !File(cFile + ".CDX") )
	//If ( !MsFile(cFile,cIndex,PDRIVER) )
		INDEX ON P_SERIE+P_CLASSE TAG &cIndex TO &cFile
		cIndex := PSFILE+"2"
		INDEX ON P_ID+P_CLASSE TAG &cIndex TO &cFile
		DbCloseArea()
		DbUseArea(.T.,cDriver,cFile+DBFEXT,PSALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PSALIAS

/*/
*************************************************
* POpenLog()									*
* verifica se a tabela PALMLOG e seus indices	*
* existem e cria se necessario;					*
* abre a tabela e indices e procura pelo ultimo *
* LOGID											*
*************************************************
/*/
Function POpenLog()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PLFILE
Local cDriver := GetLocalDBF()

If ( Select(PLALIAS) == 0 )
	If ( !MsFile(cFile+DBFEXT,,cDriver) )
		aStru := {}
		Aadd(aStru,{"P_SERIE"  ,"C", 20,0})
		Aadd(aStru,{"P_ID"     ,"C", 10,0})
		Aadd(aStru,{"P_LOGID"  ,"C", 10,0})
		Aadd(aStru,{"P_DATA"   ,"D",  8,0})
		Aadd(aStru,{"P_HRINI"  ,"C",  8,0})
		Aadd(aStru,{"P_HRFIM"  ,"C",  8,0})
		Aadd(aStru,{"P_DESC"   ,"C",255,0})
        MsCreate(cFile+DBFEXT,aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+DBFEXT,PLALIAS,.T.)
	cIndex := PLFILE+"1"
	cFile := PALMDIR+PLFILE
	If ( !File(cFile + ".CDX") )
	//If ( !MsFile(cFile,cIndex,PDRIVER) )
		INDEX ON P_SERIE+P_ID TAG &cIndex TO &cFile
		cIndex := PLFILE+"2"
		INDEX ON P_SERIE+DTOS(P_DATA)+P_HRINI TAG &cIndex TO &cFile
		cIndex := PLFILE+"3"
		INDEX ON P_LOGID TAG &cIndex TO &cFile
		DbCloseArea()
		DbUseArea(.T.,cDriver,cFile+DBFEXT,PLALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

DbSelectArea(PLALIAS)
DbSetOrder(3)
DbGoBottom()
cLastLog := If(Eof(),cLastLog,P_LOGID)
DbGoTop()

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PLALIAS


/*
*************************************************
* POpenTime()									*
* verifica se a tabela PALMTIME e seus indices	*
* existem e cria se necessario;					*
* abre a tabela e indices						*
*************************************************
*/
Function POpenTime()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PTFILE
Local cDriver := GetLocalDBF()
/*
If ( MsFile(cFile,,"BTVCDX") )
	PUpdJob(cFile)
EndIf
*/

If ( Select(PTALIAS) == 0 )
	If ( !MsFile(cFile+DBFEXT,,cDriver) )
		aStru := {}
		Aadd(aStru,{"P_SERIE"  ,"C", 20,0})
		Aadd(aStru,{"P_TIME"   ,"C", 16,0})
		Aadd(aStru,{"P_RANGE"  ,"C",  8,0})
        MsCreate(cFile+DBFEXT,aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+DBFEXT,PTALIAS,.T.)
	cIndex := PTFILE+"1"
	If ( !File(cFile + ".CDX") )
	//If ( !MsFile(cFile,cIndex,PDRIVER) )
		INDEX ON P_SERIE TAG &cIndex TO &cFile
		DbCloseArea()
		DbUseArea(.T.,cDriver,cFile+DBFEXT,PTALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PTALIAS

/*/
*************************************************
* Funcoes p/ tratamento de log					*
*************************************************

*************************************************
* PSaveLog()									*
* inclui registro totalmente atualizado na		*
* tabela PALMLOG								*
*************************************************
/*/
Function PSaveLog(cPSERIE,cPID,dPDATA,cPHRINI,cPHRFIM,cPDESC)
Local lRet := .F.
Local cSvAlias := Alias()

If ( Select(PLALIAS) <> 0 )
	cLastLog := Soma1(cLastLog)
	DbSelectArea(PLALIAS)
	RecLock(PLALIAS,.T.)
	P_SERIE	:= cPSERIE
	P_ID   	:= cPID
	P_LOGID := cLastLog
	P_DATA	:= dPDATA
	P_HRINI := cPHRINI
	P_HRFIM := cPHRFIM
	P_DESC	:= cPDESC
	MsUnlock()
	DbCommit()
	lRet := .T.
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return lRet

/*/
*************************************************
* PAddLog()										*
* inclui registro parcialmente atualizado na	*
* tabela PALMLOG								*
*************************************************
/*/
Function PAddLog(cPSERIE,cPID)
Local cRet := ""
Local cSvAlias := Alias()

If ( Select(PLALIAS) <> 0 )
	cLastLog := Soma1(cLastLog)
	cRet := cLastLog
	__LogID := cLastLog
	DbSelectArea(PLALIAS)
	dbAppend()
	//RecLock(PLALIAS,.T.)
	P_SERIE	:= cPSERIE
	P_TIPO 	:= cPID
	P_LOGID := cLastLog
	P_DATA	:= MsDate()
	P_HRINI := Time()
	MsRUnlock()
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return cRet

/*/
*************************************************
* PUpdLog()										*
* atualiza registro incluido anteriormente na	*
* tabela PALMLOG								*
*************************************************
/*/
Function PUpdLog(cLogID,cDesc)
Local lRet := .F.
Local cSvAlias := Alias()
Local i

DEFAULT cLogID := __LogID
DEFAULT cDesc := ""

ConOut("PALMJOB: "+cDesc)

If ( Select(PLALIAS) <> 0 .And. cLogID <> NIL)
	DbSelectArea(PLALIAS)
	DbSetOrder(3)
	If ( DbSeek(cLogID) )
		For i := 1 To 10
			If MSRlock(Recno())
				P_HRFIM := Time()
				P_DESC := cDesc
				MsRUnlock(Recno())
				DbCommit()
				__LogID := NIL
				lRet := .T.
				Exit
			EndIf
			Sleep(i * 100)
		Next i
	EndIf
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return lRet

//outras funcoes

Function PReadSVC(lAgain, nSys)
Local cField
Local cLine
Local nAt
Local nLen
Local nPos

//<descricao>;<funcao>;<tabelas>;<indices>;<arquivo fisico>;<classe>;<sistema>

DEFAULT lAgain := .F.
DEFAULT nSys   := 1

If ( lAgain .Or. aPTipos == NIL )
	aPTipos := {}
	
	FT_FUSE(PALMDIR+"HANDHELD.SVC")
	FT_FGOTOP()
	
	While ( !FT_FEOF() )
		cLine := FT_FREADLN()
		If Right(cLine,1) = Str(nSys,1,0)
			If Len(aPTipos) = 0
				Aadd(aPTipos,Array(10))
			ElseIf aPTipos[nLen][1] != Nil
				Aadd(aPTipos,Array(10))
			EndIf
			nLen := Len(aPTipos)
			nPos := 1	
			
			While ( nAt := At(";",cLine) ) <> 0
				cField := Subs(cLine,1,nAt-1)
				cLine := Subs(cLine,nAt+1)
				aPTipos[nLen][nPos] := cField
				nPos += 1
			End
		EndIf
		FT_FSKIP()
	End
	
	FT_FUSE()
EndIf

Return Aclone(aPTipos)

Function PExeServ(nServ)

DEFAULT nServ := 0

If ( nServ > 0 .And. nServ <= Len(aPTipos) )
    If ( FindFunction(aPTipos[nServ][2]) )
		cFunc := aPTipos[nServ][2]+If(At("(",aPTipos[nServ][2]) == 0,"()","")
		PTInternal(1, "Executando objeto "+cFunc+" do Vendedor "+(PUALIAS)->P_USER)
		&(cFunc)
	Else
		If !PInJob()
			ConOut("Erro de configuracao.","Funcao nao encontrada - "+aPTipos[nServ][2],"Atenção")
			MsgInfo("Erro de configuracao. Funcao nao encontrada - "+aPTipos[nServ][2],"Atenção")
		Else
			ConOut("Funcao nao encontrada - "+aPTipos[nServ][2])
			PUpdLog(,"Funcao nao encontrada - "+aPTipos[nServ][2])
			PSetError(.T.)
		EndIf
	EndIf
EndIf

Return

Function PExeTable(nServ)
Local cFunc

DEFAULT nServ := 0

If ( nServ > 0 .And. nServ <= Len(aPTipos) )
	If ( Empty(aPTipos[nServ][7]) )
		cFunc := aPTipos[nServ][3]+If(At("(",aPTipos[nServ][3]) == 0,"()","")
		If ( FindFunction(aPTipos[nServ][3]) )
			aPTipos[nServ][7] := &(cFunc)
			If ( ValType(aPTipos[nServ][7]) <> "A" )
				If !PInJob()
					MsgInfo("Erro de configuracao. Retorno invalido - "+aPTipos[nServ][3],"Atenção")
				Else
					PUpdLog(,"Retorno invalido - "+aPTipos[nServ][3])
					PSetError(.T.)
				EndIf
			EndIf
		Else
			If !PInJob()
				MsgInfo("Erro de configuracao. Funcao nao encontrada - "+aPTipos[nServ][3],"Atenção")
			Else
				PUpdLog(,"Funcao nao encontrada - "+aPTipos[nServ][3])
				PSetError(.T.)
			EndIf
		EndIf
	EndIf
EndIf
Return Aclone(aPTipos[nServ][7])

Function PExeArq(nServ)
Local cFunc

DEFAULT nServ := 0

If ( nServ > 0 .And. nServ <= Len(aPTipos) )
	If ( Empty(aPTipos[nServ][9]) )
		cFunc := aPTipos[nServ][5]+If(At("(",aPTipos[nServ][5]) == 0,"()","")
		If ( FindFunction(aPTipos[nServ][5]) )
			aPTipos[nServ][9] := &(cFunc)
			If ( ValType(aPTipos[nServ][9]) <> "A" )
				If !PInJob()
					MsgInfo("Erro de configuracao. Retorno invalido - "+aPTipos[nServ][5],"Atenção")
				Else
					PUpdLog(,"Retorno invalido - "+aPTipos[nServ][5])
					PSetError(.T.)
				EndIf
			EndIf
		Else
			If !PInJob()
				MsgInfo("Erro de configuracao. Funcao nao encontrada - "+aPTipos[nServ][5],"Atenção")
			Else
				PUpdLog(,"Funcao nao encontrada - "+aPTipos[nServ][5])
				PSetError(.T.)
			EndIf
		EndIf
	EndIf
EndIf
Return Aclone(aPTipos[nServ][9])

Function PExeInd(nServ)
Local cFunc

DEFAULT nServ := 0

If ( nServ > 0 .And. nServ <= Len(aPTipos) )
	If ( Empty(aPTipos[nServ][8]) )
		cFunc := aPTipos[nServ][4]+If(At("(",aPTipos[nServ][4]) == 0,"()","")
		If ( FindFunction(aPTipos[nServ][4]) )
			aPTipos[nServ][8] := &(cFunc)
			If ( ValType(aPTipos[nServ][8]) <> "A" )
				If !PInJob()
					MsgInfo("Erro de configuracao. Retorno invalido - "+aPTipos[nServ][4],"Atenção")
				Else
				   PUpdLog(,"Retorno invalido - "+aPTipos[nServ][4])
					PSetError(.T.)
				EndIf
			EndIf
		Else
			If !PInJob()
				MsgInfo("Erro de configuracao. Funcao nao encontrada - "+aPTipos[nServ][4],"Atenção")
			Else
				PUpdLog(,"Funcao nao encontrada - "+aPTipos[nServ][4])
				PSetError(.T.)
			EndIf
		EndIf
	EndIf
EndIf
Return Aclone(aPTipos[nServ][8])

Function PInJob(lSet)
Local lRet

DEFAULT __PInJob := .F.

lRet := __PInJob

If ( lSet <> NIL )
	__PInJob := lSet
EndIf
Return lRet

Function PSetError(lSet)
Local lRet

DEFAULT __PError := .F.

lRet := __PError

If ( lSet <> NIL )
	__PError := lSet
EndIf

Return lRet

Function PGetDir()
Return PALMDIR

Function PExistServ(cTipo)
Local nRet
Local nSys

DEFAULT cTipo := ""

cTipo := Trim(cTipo)
nSys  := Val(PALMUSER->P_SISTEMA)

PReadSVC(,nSys)

nRet := Ascan(aPTipos,{|x| x[2] == cTipo})

Return nRet

/*/
*************************************************
* POpenCond()									*
* verifica se a tabela HHCOND  e seus indices	*
* existem e cria se necessario;					*
* abre a tabela e indices                       *
*************************************************
/*/

Function POpenCond()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PCFILE
Local cDriver := GetLocalDBF()
/*
If ( MsFile(cFile,,"BTVCDX") )
	PUpdJob(cFile)
EndIf
*/
If ( Select(PCALIAS) == 0 )
	If ( !MsFile(cFile+DBFEXT,,cDriver) )
		aStru := {}
		Aadd(aStru,{"P_COND"    ,"C", 03,0})
		Aadd(aStru,{"P_STCODPR" ,"C", 01,0})
		Aadd(aStru,{"P_CODPR"   ,"C", 03,0})
		Aadd(aStru,{"P_STDTENT" ,"C", 01,0})
		Aadd(aStru,{"P_DTENT"   ,"N", 03,0})
		Aadd(aStru,{"P_STIPPG"  ,"C", 01,0})
		Aadd(aStru,{"P_TIPPG"   ,"C", 03,0})
		Aadd(aStru,{"P_STTES"   ,"C", 01,0})
		Aadd(aStru,{"P_TES"     ,"C", 03,0})
		Aadd(aStru,{"P_STDESC"  ,"C", 01,0})
		Aadd(aStru,{"P_DESC"    ,"N", 05,2})
        MsCreate(cFile+DBFEXT,aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+DBFEXT,PCALIAS,.T.)
	cIndex := PCFILE+"1"
	cFile := PALMDIR+PCFILE
	If ( !File(cFile + ".CDX") )
	//If ( !MsFile(cFile,cIndex,PDRIVER) )
		INDEX ON P_COND TAG &cIndex TO &cFile
		DbCloseArea()
		DbUseArea(.T.,cDriver,cFile+DBFEXT,PCALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PCALIAS


/*/
*************************************************
* PUpdJob()									    *
* verifica os arquivos de Btrieve e converte-os *
* para DBF                      				*
*************************************************
/*/
Function PUpdJob(cArq)

//Local cRet
Local cArqDbf := cArq + ".DBF"
Local cArqBtv := cArq + ".DAT"
Local nRecBtv := 0
Local nRecDbf := 0
Local cDriver := GetLocalDBF()

DbUseArea(.T.,"BTVCDX",cArq,"ARQBTV",.F.)
While !Used()
// Abrir arquivo Btrieve
	DbUseArea(.T.,"BTVCDX",cArq,"ARQBTV",.F.)
	If Used()
		Exit
	Else
		ConOut("Arquivo " + cArq + " esta sendo utilizado")
	EndIf
EndDo	

nRecBtv = ARQBTV->(RecCount())
aStru := (PCALIAS)->(dbStruct())
ARQBTV->(dbCloseArea())

// Cria Arquivo DBF
MsCreate(cArq+DBFEXT,aStru,cDriver)
DbUseArea(.T.,cDriver,cArq+DBFEXT,"ARQDBF",.T.)

// Atualiza Arquivos DBF
Append From &cArqBtv VIA "BTVCDX" 

nRecDbf = ARQDBF->(RecCount())
If nRecDbf == nRecBtv
	ConOut("PALMJOB: Atualizacao do arquivo " + cArq + " finalizada com sucesso.")
	FRename(cArqBtv, cArq+".OLD")
Else
	ConOut("PALMJOB: Atualizacao do arquivo " + cArq + " finalizada com erro.")
	FErase(cArqDbf)
EndIf
ARQDBF->(DbCloseArea())

Return

Function PChkStru(cFile, cCampo, aNewStru)
Local aAtuStru := {}
Local nPos     := 0
Local nRegAtu  := 0
Local nRegNew  := 0
Local nTimes   := 0
Local lRet := .F.
Local cDriver := GetLocalDBF()
//Abre o arquivo Atual
DbUseArea(.T.,cDriver,cFile+DBFEXT,"ARQATU",.T.)
If Used()
	//Pack
	nRecAtu  := ARQATU->(RecCount())
	aAtuStru := ARQATU->(dbStruct())
	ARQATU->(dbCloseArea())
	nPos := aScan(aAtuStru, {|x| x[1] = cCampo})
	If nPos = 0
		FRename(cFile + ".DBF", cFile + "2.DBF")
		// Cria Arquivo DBF
		MsCreate(cFile+DBFEXT,aNewStru,cDriver)
		DbUseArea(.T.,cDriver,cFile+DBFEXT,"ARQNEW",.T.)
		cArqAtu := cFile + "2.DBF"
		Append From &cArqAtu VIA "DBFCDX"
		nRecNew = ARQNEW->(RecCount())
		ARQNEW->(dbCloseArea())
		If nRecNew = nRecAtu
	//		FErase(cArqAtu)
			FErase(cFile + ".CDX")
			ConOut("Atualizacao efetuada !")
			lRet := .T.
		Else
			ConOut("Atualizacao nao efetuada !")
			lRet := .F.
		EndIf
	EndIf
Else
	If Select("PALMUSER") != 0 
		aAtuStru := PALMUSER->(dbStruct())
		nPos := aScan(aAtuStru, {|x| x[1] = cCampo})
		If nPos = 0
			ConOut("PALMJOB: Nao foi possivel abrir o arquivo de usuarios em modo exclusivo para realizar a atualizacao.")
		EndIf
	EndIf
EndIf
//ARQATU->(dbCloseArea())
Return lRet


/*/
*************************************************
* AdJustDir(cDir)							    *
* verifica os diretorios e ajusta caso          *
* necessario                    				*
*************************************************
/*/
Function AdJustDir(cDir)
cDir := Alltrim(cDir)
IF Subs(cDir,1,1) == "\"
   cDir := Subs(cDir,2)
Endif
IF Subs(cDir,Len(cDir),1) != "\"
   cDir += "\"
Endif                   
IF "\"$Subs(cDir,1,Len(cDir)-1)
   USEREXCEPTION("INVALID GENERIC DIRECTORY - Only One Level is Permitted")
Endif

Return cDir

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ResetGen ³ Autor ³ Fabio Garbin          ³ Data ³ 10/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Forca a geracao dos arquivos no servico de produtos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ResetGen()
Local nHDL, __cDir := GetcDir(),aDir:= {"GENERIC\"}, ni
IF ExistBlock("PLMTDDIR")
   aDir := ExecBlock("PLMTDDIR",.f.,.f.)
Endif                       

For ni := 1 to Len(aDir)                 
    aDir[ni] := AdjustDir(aDir[ni])
	nHdl := MSFCREATE(__cDir+aDir[ni]+"REDO.LCK", FO_EXCLUSIVE)        
	IF nHdl >= 0
		FCLOSE(nHDL)
	Endif
Next

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PProduto ³ Autor ³ Fabio Garbin          ³ Data ³ 24/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controla os arquivos generico de Produtos.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GenericTime(dLastDateGen, cLastTimeGen)
Local nFreqGen     := ""//GetMv("MV_PLGENFR",,24)
Local nLastTimeGen := 0//If(!Empty(cLastTimeGen), HoraToInt(cLastTimeGen), 0)
Local nTimeAtu     := HoraToInt(Time())
Local cDateAtu     := Date()
Local nNextGen     := 0//nFreqGen + nLastTimeGen
Local nDays         := 0//nFreqGen / 24
Local lRet := .F.

nFreqGen     := GetMv("MV_PLGENFR",,24)
/*
ConOut("nFreqGen = " + valType(nFreqGen))
If valType(nFreqGen)= "C"
	ConOut("nFreqGen = " + nFreqGen)
ElseIf valType(nFreqGen)= "N"
	ConOut("nFreqGen = " + Str(nFreqGen,2,0))
Else
	ConOut("Nem C e NEM N")
EndIf*/
nLastTimeGen := If(!Empty(cLastTimeGen), HoraToInt(cLastTimeGen), 0)
//ConOut("nLastTimeGen = " + Str(nLastTimeGen,10,0))
nNextGen     := nFreqGen + nLastTimeGen
//ConOut("nNextGen = " + Str(nNextGen,10,0))
nDays         := nFreqGen / 24
//ConOut("nDays = " + Str(nDays,10,0))
//ConOut("Proximo = " + Str(nNextGen,8,0))
//ConOut("Hora Atual = " + Str(nTimeAtu,8,0))
//ConOut("Data Atual = " + DtoC(cDateAtu))
//ConOut("Hora Ultima Geracao = " + Str(nLastTimeGen,8,0))
//ConOut("Data Ultima Geracao = " + DtoC(dLastDateGen))
//ConOut("nDays = " + Str(nDays,8,0))
//ConOut("cDateAtu - dLastDateGen = " + Str(cDateAtu - dLastDateGen,8,0))

If (cDateAtu - dLastDateGen) > nDays
	lRet := .T.
Else
	If nNextGen > 23
		If dLastDateGen < cDateAtu .And. (nNextGen - 24) <= nTimeAtu
			lRet := .T.
		Endif
	Else
		If dLastDateGen = cDateAtu .And. nNextGen <= nTimeAtu
			lRet := .T.
		Endif
	EndIf
Endif
//ConOut(lRet)
Return lRet

Function PPRODUTO()
Local nHdl, aDir, nErr := 0, nERR1 := 0, lStop, nX, nTimeWait, __cDir := GetcDir()
Local lGeneric := (GETMV("MV_PLMPRD",,"S")) == "S"
Local nFreqGen := GetMv("MV_PLGENFR",,24)
Local cGDir    := "GENERIC\"
Local cFunGen  := GetMv("MV_PLGENPR",,"U_xPPRoduto")
Local cFilePrd := "HB1"+ cEmpAnt + "0" + ".DBF"
Local cFileGrp := "HBM"+ cEmpAnt + "0" + ".DBF"
Local cFileTbi := "HPR"+ cEmpAnt + "0" + ".DBF"
Local cFileTbc := "HTC"+ cEmpAnt + "0" + ".DBF"
Local cFileEst := "HB2"+ cEmpAnt + "0" + ".DBF"
Local lGeraGen := .T.
// Posiciona o vendedor
dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+PALMUSER->P_CODVEND)

IF !lGeneric
	&(cFunGen+"(.f.)")
	Return Nil
Endif

IF ExistBlock("PLMGNDIR")
   cGDir := ExecBlock("PLMGNDIR",.f.,.f.)
   cGDir := AdjustDir(cGDir)
Endif                       


nTimeWait := Val(GetGlbvalue("__PLMTIMEWAIT"))
IF nTimeWait == 0
   nTimeWait := Val(GetSrvProfString("PlmGenericTime","1000"))
   PutGlbValue("__PLMTIMEWAIT", StrZero(nTimeWait,8,0))
Endif


MakeDir(__cDir+cGDir)
IF !File(__cDir+cGDir+"MYMUTEX.LCK")
   nHdl := MSFCREATE(__cDir+cGDir+"MYMUTEX.LCK")
   IF nHdl < 0
      UserException("Impossible to create MyMutex.LCK")
   Endif
   FClose(nHdl)
Endif                                          
lREDO := FILE(__cDir+cGDir+"REDO.LCK")  


While !KillApp()
	aDir := DIRECTORY(__cDir+cGDir+"\START.GEN")
	If Len(aDir) > 0
		lGeraGen := GenericTime(aDir[1,3], aDir[1,4])
	EndIf
	If (lGeraGen .Or. lRedo)
//	IF (Len(aDir) == 0 .or. aDir[1,3] != Date() .OR. lRedo)
	   nHdl := FOPEN(__cDir+cGDir+"MYMUTEX.LCK", FO_EXCLUSIVE)
	   IF nHdl < 0                         
	      nERR1++
	      IF nERR1 > 2000
	         USEREXCEPTION("Probs No MYMUTEX EXCLUSIVO - " + FError())
	      Endif
	      SLeep(300)
	      Loop
	   Endif                          
	   
	   FERASE(__cDir+cGDir+"REDO.LCK")                 
	   lRedo := .f.     
	                                
	   nX := MSFCREATE(__cDir+cGDir+"START.GEN")                 // Marca Inicio
	   IF nX < 0
	      USEREXCEPTION("ERRO NA CRIACAO DO START.GEN - " + FError())
	   Endif
	   FClose(nX)
	                                                                              
	   &(cFunGen+"(,'"+cGDir+"')")
	   
	   nX := MSFCREATE(__cDir+cGDir+"END.GEN")                   //Marca FIM
	   IF nX < 0
	      USEREXCEPTION("ERRO NA CRIACAO DO END.GEN - " + FError())
	   Endif
	   FClose(nX)
	   FClose(nHdl)                                         
	   Loop
	Else
	   nHdl := -1 
	   While nHdl < 0
	        nHdl := FOPEN(__cDir+cGDir+"MYMUTEX.LCK",FO_SHARED)
			IF nHdl < 0                                 
			   IF (nERR%30) == 0
				   ConOut("PALMJOB: "+ AllTrim(PALMUSER->P_USER) + " Esperando Autorizacao de Copia..."+StrZero(nERR,6,0))
			   Endif
			   nERR++
			   IF nERR > 1000
			      UserException("Probs no MyMutex.Lck - " + FError())
			   Endif
			   Sleep(nTimeWait)
			Endif
		End           
		cDir := __cDir+"P"+Alltrim(PALMUSER->P_DIR)+"\NEW\"
		
		//IF RealRdd() == "CTREE"
		//	USEREXCEPTION("FALTA FAZER TRATAMENTO CTREE")
		If DbIsOK(cGDir)
			
			ConOut("PALMJOB: Ultima geracao de produtos foi em " + DtoC(aDir[1,3]) + " as " + aDir[1,4])
			If ExistBlock("PLMGEN01")
				ExecBlock("PLMGEN01",.f.,.f.,{__cDir,cGDir, cDir})
			Else
			    xCopyFile( (__cDir + cGDir + cFilePrd), cDir + cFilePrd)
			    xCopyFile( (__cDir + cGDir + cFileGrp), cDir + cFileGrp)
			    xCopyFile( (__cDir + cGDir + cFileTbc), cDir + cFileTbc)
			    xCopyFile( (__cDir + cGDir + cFileTbi), cDir + cFileTbi)
			    xCopyFile( (__cDir + cGDir + cFileEst), cDir + cFileEst)
		    EndIf
		 Else                                                             
			lRedo := .t.
		    FERASE(__cDir+cGDir+"START.GEN")                 
		    FClose(nHdl)
		    Loop
		 Endif
		 FClose(nHdl)
	    Exit
	Endif       
End 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DbIsOK   ³ Autor ³ Fabio Garbin          ³ Data ³ 10/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se a geracao generica foi concluida               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function DbIsOK(cGDir)                                          
Local aDir, cDtS, cDTE, __cDir := GetcDir()
aDir := Directory(__cDir+cGDir+"START.GEN")               
IF len(aDir) > 0
   cDTS := Dtos(aDir[1,3])+aDir[1,4]
Else
   Return .f.
Endif
aDir := Directory(__cDir+cGDir+"END.GEN")               
IF len(aDir) > 0
   cDTE := Dtos(aDir[1,3])+aDir[1,4]
Else
   Return .f.
Endif  
Return (cDTS<=cDTE)

Static Function xCopyFile(cOri,cDest)
ConOut("Copiando "+cOri+" Para "+cDest)
__CopyFile(cOri,cDest)
Return Nil


//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Funcao que cria o catalogo das tabelas                                       //  
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
Function HHJobTbl(aAlias)
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\Difs\"
Local cFileTbl   := "ADV_TBL"
Local cFileInd   := "ADV_IND"
Local cAliasTbl  := "ADV_TBL"
Local cAliasInd  := "ADV_IND"
Local aTbl       := {}
Local aInd       := {}
Local cChaveTbl  := "" 
Local cChaveInd  := "" 
Local nIndexes   := 1
Local nNextID    := 1
Local cDescr     :=""
Local nFk:=1
Local nInd:=1
Local nJ := 1
Local nI := 1
Local cDriver := GetLocalDBF()
Private aIndFk     :={} 

//Indices Complementares
aadd( aIndFk, { 000,"ADV_IND", "ADV_IND1", "TBLNAME+NOME_IDX", "T"  } )  
aadd( aIndFk, { 200,"HRT" + cEmpAnt + "0", "HRT" + cEmpAnt + "02", "RT_DESCR", "F"  } )  
aadd( aIndFk, { 201,"HB1" + cEmpAnt + "0", "HB1" + cEmpAnt + "02", "B1_DESC", "F"   } )  
aadd( aIndFk, { 202,"HB1" + cEmpAnt + "0", "HB1" + cEmpAnt + "03", "B1_GRUPO+B1_DESC", "F"  } )  
aadd( aIndFk, { 203,"HU5" + cEmpAnt + "0", "HU5" + cEmpAnt + "02", "U5_CLIENTE+U5_LOJA+U5_CONTAT", "F"  } )  
aadd( aIndFk, { 204,"HAT" + cEmpAnt + "0", "HAT" + cEmpAnt + "02", "AT_DATA+AT_FLGVIS+AT_CLI+AT_LOJA", "F"  } )  
aadd( aIndFk, { 205,"HC5" + cEmpAnt + "0", "HC5" + cEmpAnt + "02", "C5_CLI+C5_LOJA+C5_NUM", "F"  } )  
aadd( aIndFk, { 208,"HMT" + cEmpAnt + "0", "HMT" + cEmpAnt + "02", "MT_GRUPO+MT_PROD", "F"  } )  
aadd( aIndFk, { 209,"HMT" + cEmpAnt + "0", "HMT" + cEmpAnt + "03", "MT_PROD+MT_PROD", "F"   } )  
aadd( aIndFk, { 210,"HA1" + cEmpAnt + "0", "HA1" + cEmpAnt + "02", "A1_NOME+A1_COD+A1_LOJA", "F"  } )
aadd( aIndFk, { 211,"HIN" + cEmpAnt + "0", "HIN" + cEmpAnt + "02", "IN_CLI+IN_LOJA+IN_PROD", "F"  } )  
aadd( aIndFk, { 212,"HCP" + cEmpAnt + "0", "HCP" + cEmpAnt + "02", "ACP_CODREG+ACP_GRUPO+ACP_CODPRO+ACP_CFAIXA", "F"  } )                                                                                                         
aadd( aIndFk, { 213,"HCS" + cEmpAnt + "0", "HCS" + cEmpAnt + "02", "ACS_CODCLI+ACS_LOJA", "F"  } )  
aadd( aIndFk, { 214,"HCT" + cEmpAnt + "0", "HCT" + cEmpAnt + "02", "ACT_CODREG+ACT_ITEM+ACT_CODTAB+ACT_CONDPG+ACT_FORMPG", "F"  } )
aadd( aIndFk, { 215,"HCT" + cEmpAnt + "0", "HCT" + cEmpAnt + "03", "ACT_CODREG+ACT_CONDPG", "F"  } )
aadd( aIndFk, { 216,"HD7" + cEmpAnt + "0", "HD7" + cEmpAnt + "02", "AD7_CLI+AD7_LOJA", "F"  } )
aadd( aIndFk, { 217,"HD7" + cEmpAnt + "0", "HD7" + cEmpAnt + "03", "DTOS(AD7_DATA)+AD7_CLI+AD7_LOJA", "F"  } )

// Ponto de Entrada para inclusao de indices ao SFA
If ((ExistBlock("PLMFUN01")))
	ExecBlock("PLMFUN01",.F.,.F.)
EndIf	

ErrorBlock({|e| HHErrTbl(e)})
 
aadd(aTbl,{"TABLEID"       , "N",   5, 0}) // ID da Tabela
aadd(aTbl,{"TBLNAME"       , "C",  15, 0}) // Nome da Tabela
aadd(aTbl,{"FLDPOS"        , "C",  03, 0}) // Posicao do Campo
aadd(aTbl,{"FLDNAME"       , "C",  30, 0}) // Nome do Campo
aadd(aTbl,{"FLDTYPE"       , "C",  01, 0}) // Tipo do Campo
aadd(aTbl,{"FLDLEN"        , "N",   3, 0}) // Tamanho do Campo
aadd(aTbl,{"FLDLENDEC"     , "N",   3, 0}) // Decimais do Campo
aadd(aTbl,{"TBLTOHOST"     , "C",   1, 0}) // T=a Tabela volta para Retaguarda, F=nao volta para retaguarda 
aadd(aTbl,{"DESCR"         , "C",  15, 0}) // Descricao da Tabela
aadd(aTbl,{"INTR"          , "C",   1, 0}) // Intr
 
aadd(aInd,{"TABLEID"      , "N",   5, 0}) // ID da Tabela
aadd(aInd,{"TBLNAME"      , "C",  15, 0}) // nome do Indice
aadd(aInd,{"NOME_IDX"     , "C",  20, 0}) // nome do Indice
aadd(aInd,{"EXPRE"        , "C",  60, 0}) // Expressao do Indice
aadd(aInd,{"PK"           , "C",   1, 0}) // Chave do Indice
aadd(aInd,{"INTR"         , "C",   1, 0}) // Intr
 
If !File(cPathPalm+cFileTbl+".DBF") .And. !File(cPathPalm+cFileInd+".DBF")
	MsCreate(cPathPalm+cFileTbl+DBFEXT,aTbl,cDriver)
	MsCreate(cPathPalm+cFileInd+DBFEXT,aInd,cDriver)
	aStruInd:=dbStruct()  
EndIf
If ( Select(cAliasTbl) == 0 )
	DbUseArea(.T.,cDriver,cPathPalm+cFileTbl+DBFEXT,cAliasTbl,.F.)
Endif
cIndex := cFileTbl+"1" 
If ( !MsFile(cPathPalm+cFileTbl+DBFEXT,cIndex,cDriver) )
	INDEX ON STR(TABLEID,5,0)+FLDNAME TAG &cIndex TO &(cPathPalm+cFileTbl)   
	cIndex := cFileTbl+"2" 
	INDEX ON TBLNAME+FLDPOS TAG &cIndex TO &(cPathPalm+cFileTbl)
	DbClearInd()
EndIf             
DbSetIndex(cPathPalm+cFileTbl)
If ( Select(cAliasInd) == 0 ) 
   DbUseArea(.T.,cDriver,cPathPalm+cFileInd+DBFEXT,cAliasInd,.F.)
   aStruInd:=dbStruct()  
Endif
cIndex := cFileInd+"1"
If ( !File(cPathPalm+cFileInd + ".CDX") )
//If ( !MsFile(cPathPalm+cFileInd,cIndex,PDRIVER) )
   INDEX ON STR(TABLEID,5,0)+NOME_IDX TAG &cIndex TO &(cPathPalm+cFileInd)
   cIndex := cFileInd+"2"
   INDEX ON NOME_IDX TAG &cIndex TO &(cPathPalm+cFileInd)
   DbClearInd()
EndIf       
DbSetIndex(cPathPalm+cFileInd) 
nLenAlias := Len(aAlias) 
nCpoInd   := Len( aStruInd ) - 1
For nInd:=1 to nCpoInd         
    (cAliasTbl)->( dbSetOrder(1) )
    cChaveTbl:= STR(0,5,0) + aStruInd[nInd,1] 
    If (cAliasTbl)->(!dbSeek( cChaveTbl ) )
       RecLock(cAliasTbl, .T.)
       (cAliasTbl)->TABLEID   := 0
       (cAliasTbl)->TBLNAME   := "ADV_IND" 
       (cAliasTbl)->DESCR     := "INDICES"       
       (cAliasTbl)->FLDPOS    := StrZero(nInd, 3)
       (cAliasTbl)->FLDNAME   := aStruInd[nInd, 1]
       (cAliasTbl)->FLDTYPE   := aStruInd[nInd, 2]
       (cAliasTbl)->FLDLEN    := aStruInd[nInd, 3]                    
       (cAliasTbl)->FLDLENDEC := aStruInd[nInd, 4]
       (cAliasTbl)->TBLTOHOST := "F"  // Deve retornar .t. ou .f.
       (cAliasTbl)->INTR      := "I"
       (cAliasTbl)->(MsUnlock())
       
       For nFk:=1 to Len( aIndFk )                
           if (cAliasInd)->(!dbSeek( STR(aIndFk[nFk,1],5,0) ) ) 
              RecLock(cAliasInd, .T.)
	          (cAliasInd)->TABLEID   := aIndFk[nFk,1] 
              (cAliasInd)->TBLNAME   := aIndFk[nFk,2] 
	          (cAliasInd)->NOME_IDX  := aIndFk[nFk,3] 
	          (cAliasInd)->EXPRE     := aIndFk[nFk,4] 
	          (cAliasInd)->PK        := aIndFk[nFk,5] 
	          (cAliasInd)->INTR      := "I"
	          (cAliasInd)->(MsUnlock()) 
	       endif
       Next 
       
    Endif   
    
Next nInd
 
While (cAliasTbl)->( dbSeek( STR(nNextId,5,0) ) )
      nNextId++
Enddo

For nI := 1 To nLenAlias
    aStru := (aAlias[nI,1])->(dbStruct())
    nLenStru:=Len(aStru)                  
    
   dbSelectArea( cAliasTbl )
   (cAliasTbl)->( dbSetOrder(2) )
   if  (cAliasTbl)->(!dbSeek( aAlias[nI,2] ) )
    
    For nJ := 1 To nLenStru 
           RecLock(cAliasTbl, .T.)
           (cAliasTbl)->TABLEID   := nNextId
           (cAliasTbl)->TBLNAME   := aAlias[nI,2]
           (cAliasTbl)->FLDPOS    := StrZero(nJ, 3)
           (cAliasTbl)->FLDNAME   := aStru[nJ, 1]
           (cAliasTbl)->FLDTYPE   := aStru[nJ, 2]
           (cAliasTbl)->FLDLEN    := aStru[nJ, 3]
           (cAliasTbl)->FLDLENDEC := aStru[nJ, 4]
           (cAliasTbl)->TBLTOHOST:= Ptohost(aAlias[nI,2],@cDescr)  // Deve retornar .t. ou .f.
		   (cAliasTbl)->DESCR     := cDescr
           (cAliasTbl)->INTR      := "I"
           (cAliasTbl)->(MsUnlock())
    Next nJ
   
   endif
    
	dbSelectArea(aAlias[nI,1])
	dbSetOrder(1)
	cIndexKey := (aAlias[nI,1])->(IndexKey())
	nIndexOrd := (aAlias[nI,1])->(IndexOrd())
    dbSelectArea( cAliasTbl )     
	(cAliasTbl)->( dbSetOrder(1) )               
	
   dbSelectArea( cAliasInd )
   (cAliasInd)->( dbSetOrder(2) )        
   If (cAliasInd)->(!dbSeek( aAlias[nI,2]+ALLTRIM(STR(nIndexOrd)) ) ) 
    For nJ := 1 To nIndexes
        cChaveInd:= STR(nNextId,5,0) + aAlias[nI,2] + Str(nJ,1,0) 
	        RecLock(cAliasInd, .T.)
	        (cAliasInd)->TABLEID   := nNextId
	        (cAliasInd)->TBLNAME   := aAlias[nI,2]
	        (cAliasInd)->NOME_IDX  := aAlias[nI,2] + Str(nJ,1,0)
	        (cAliasInd)->EXPRE     := cIndexKey
	        (cAliasInd)->PK        := If( nIndexOrd==1 , "T", "F" )
	        (cAliasInd)->INTR      := "I"
	        (cAliasInd)->(MsUnlock())
    Next nJ
   Endif 
    nNextID++
Next nI

(cAliasTbl)->(dbCloseArea())
(cAliasInd)->(dbCloseArea())

Return
 
Static Function HHErrTbl(e)
Return "DEFAULTERRORPROC"

/*/
*************************************************
* POpenTabl()									*
* verifica se a tabela HHFILE  e seus indices	*
* existem e cria se necessario;					*
* abre a tabela e indices                       *
*************************************************
/*/

Function POpenTabl()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PFFILE
Local cDriver := GetLocalDBF()
/*
If ( MsFile(cFile,,"BTVCDX") )
	PUpdJob(cFile)
EndIf
*/
If ( Select(PFALIAS) == 0 )
	If ( !MsFile(cFile+DBFEXT,,cDriver) )
		aStru := {}
		Aadd(aStru,{"P_TABELA"  ,"C", 10,0})
		Aadd(aStru,{"P_DESCRI"  ,"C", 15,0})
		Aadd(aStru,{"P_EMPFI"   ,"C", 04,0})
		Aadd(aStru,{"P_TOHOST"  ,"L", 01,0})
		Aadd(aStru,{"P_TPCARGA" ,"C", 01,0})

        MsCreate(cFile+DBFEXT,aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+DBFEXT,PFALIAS,.T.)
	cIndex := PFFILE+"1"
	cFile := PALMDIR+PFFILE
	If ( !File(cFile+".CDX") )
	//If ( !MsFile(cFile,cIndex,PDRIVER) )
		INDEX ON P_TABELA TAG &cIndex TO &cFile
		DbCloseArea()
		DbUseArea(.T.,cDriver,cFile+DBFEXT,PFALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PFALIAS

/*/
*************************************************
* PDE()									        *
* verifica se a tabela e seus indices	        *
* existem e cria se necessario;					*
* abre a tabela e indices                       *
*************************************************
/*/
Function Ptohost(cNameTbl,cDescr) 
Local cRet         
cRet:=.T.

POpenTabl()

DbSelectArea(PFALIAS)
DbSetOrder(1)        
If dbSeek( cNameTbl )
   cRet:=if( (PFALIAS)->P_TOHOST, "T", "F" )
   cDescr:=(PFALIAS)->P_DESCRI
Else
   cRet:="F"
   cDescr := if( Empty((PFALIAS)->P_TABELA), cNameTbl, (PFALIAS)->P_TABELA )    
Endif

Return cRet


Function POpenTransmit(cDifsDir, cOper)
Local cIndex
Local aStru
Local cSvAlias := Alias()
//Local cFile := cDifsDir+"MCS_CTRL" 
Local cFile := cDifsDir+"HHCTR"
Local cDriver := GetLocalDBF()

DEFAULT cOper := ""

If ( Select("TRANSMIT") == 0 )
	aStru := {}
/*
	Aadd(aStru,{"TBLNAME"  ,"C", 20,0})
	Aadd(aStru,{"INTR_I"   ,"N", 05,0})
	Aadd(aStru,{"INTR_A"   ,"N", 05,0})
	Aadd(aStru,{"INTR_E"   ,"N", 05,0})
	Aadd(aStru,{"TOTREC"   ,"N", 08,0})
	Aadd(aStru,{"INTR_N"   ,"N", 05,0})
	Aadd(aStru,{"INTR"     ,"C", 01,0})
*/

	Aadd(aStru,{"TABLENAME"  ,"C", 20,0})
	Aadd(aStru,{"LASTKEY"   ,"C", 255,0})
	Aadd(aStru,{"AMNT"   ,"N", 10,0})
	Aadd(aStru,{"OPER"   ,"C", 01,0})
	Aadd(aStru,{"INTR"     ,"C", 01,0})

	If ( !MsFile(cFile + ".DBF",,cDriver) )
        MsCreate(cFile,aStru,cDriver)
        cOper := If(Empty(cOper), "T", cOper)
	Else
		cOper := If(Empty(cOper), "P", cOper)
	EndIf
	DbUseArea(.T.,cDriver,cFile+DBFEXT,"TRANSMIT",.T.)
	cIndex := "MCS_CTRL1"
	If ( !File(cFile + ".CDX") )
	//If ( !MsFile(cFile,cIndex,PDRIVER) )
		//INDEX ON TBLNAME TAG &cIndex TO &cFile    --- EFFEM
		INDEX ON TABLENAME TAG &cIndex TO &cFile
		dbCloseArea()
		DbUseArea(.T.,cDriver,cFile+DBFEXT,"TRANSMIT",.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return "TRANSMIT"

Function PUpdTransmit(cDifsDir, cFile, cAliasDif, aTransmit)
Local nTotRec := 0
Local cAlias := POpenTransmit(cDifsDir, @cOper)
Local nI := 0

cFile := Upper(Alltrim(cFile))

For nI := 1 To Len(aTransmit)
	nTotRec := nTotRec + aTransmit[nI]
Next

dbSelectArea(cAlias)
dbSetOrder(1)
If !dbSeek(cFile+(Space(Len((cAlias)->TABLENAME)-Len(cFile))))
//If !dbSeek(cFile+(Space(Len((cAlias)->TBLNAME)-Len(cFile))))
	RecLock(cAlias, .T.)
Else
	RecLock(cAlias, .F.)
EndIf
/*
(cAlias)->TBLNAME := cFile
(cAlias)->INTR_I  := aTransmit[1]
(cAlias)->INTR_A  := aTransmit[2]
(cAlias)->INTR_E  := aTransmit[3]
(cAlias)->TOTREC  := nTotRec
(cAlias)->INTR_N  := 0
(cAlias)->INTR    := If(Empty((PUALIAS)->P_DELDATA), "I", "E")
*/

(cAlias)->TABLENAME := cFile
(cAlias)->LASTKEY  := ""
(cAlias)->AMNT  := nTotRec
(cAlias)->OPER  := If((cAlias)->OPER != "T", cOper,"T")
(cAlias)->INTR    := If(Empty((PUALIAS)->P_DELDATA), "I", "E")

(cAlias)->(MsUnlock())

(cAlias)->(dbCloseArea())
Return Nil

Function CountADV()
Local cDifsDir  := PGetDir()+"P"+Trim((PUALIAS)->P_DIR)+"\DIFS\"
Local aTransmit :=  {0,0,0}   //{INTR_I, INTR_A, INTR_E}
Local cAliasTbl := "ADV_TBL"
Local cAliasInd := "ADV_IND" 
Local cDriver := GetLocalDBF()

If ( Select(cAliasTbl) == 0 )
	DbUseArea(.T.,cDriver,cDifsDir+cAliasTbl+DBFEXT,cAliasTbl,.F.)
Endif

While !(cAliasTbl)->(Eof())
	If (cAliasTbl)->INTR = "I"
		aTransmit[1] := aTransmit[1] + 1
	ElseIf (cAliasTbl)->INTR = "A"
		aTransmit[1] := aTransmit[2] + 1
	ElseIf (cAliasTbl)->INTR = "E"
		aTransmit[1] := aTransmit[3] + 1
	EndIf
	(cAliasTbl)->(dbSkip())
EndDo
PUpdTransmit(cDifsDir, cAliasTbl, cAliasTbl, aTransmit)

aTransmit :=  {0,0,0}
If ( Select(cAliasInd) == 0 )
	DbUseArea(.T.,cDriver,cDifsDir+cAliasInd+DBFEXT,cAliasInd,.F.)
Endif

While !(cAliasInd)->(Eof())
	If (cAliasInd)->INTR = "I"
		aTransmit[1] := aTransmit[1] + 1
	ElseIf (cAliasInd)->INTR = "A"
		aTransmit[1] := aTransmit[2] + 1
	ElseIf (cAliasInd)->INTR = "E"
		aTransmit[1] := aTransmit[3] + 1
	EndIf
	(cAliasInd)->(dbSkip())
EndDo
PUpdTransmit(cDifsDir, cAliasInd, cAliasInd, aTransmit)

(cAliasTbl)->(dbCloseArea())
(cAliasInd)->(dbCloseArea())
Return


/*/
*************************************************
* HHSendMail()									        *
* verifica se a tabela e seus indices	        *
* existem e cria se necessario;					*
* abre a tabela e indices                       *
*************************************************
/
Function HHSendMail(cDestin,cMensagem,cTitulo,cSubject, aFiles) // Envia email sem pilha de chamadas
Local cServer     := GetMV("MV_HHSMTP",,"")
Local cUser       := GetMv("MV_HHMAIL",,"")
Local nPosAccount := At("@", cUser)
Local nPosPass    := At("/", cUser)
Local cAccount    := SubStr(cUser,1,nPosAccount)
Local cEnvia      := SubStr(cUser,1,nPosPass)
Local cPassword   := SubStr(cUser,nPosPass, Len(cUser))
//Local aFiles      := {}
Local nI          := 1
Local nActivation := 1
Local cTos
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou
If lConectou             
	If Len(aFiles)>0     	 
		SEND MAIL FROM cEnvia;
		TO cDestin;
		SUBJECT cSubject ;		
		BODY cMensagem ;
		ATTACHMENT aFiles[1], aFiles[2];
		RESULT lEnviado
	Else
		SEND MAIL FROM cEnvia;
		TO cDestin;
		SUBJECT cSubject;
		BODY cMensagem;
		RESULT lEnviado
	Endif
	If !lEnviado
		cMensagem := ""
		GET MAIL ERROR cMensagem
		ConOut(cMensagem)

	Endif
	DISCONNECT SMTP SERVER Result lDisConectou
Else
	GravaLog()
endif
Return
*/

Function GetLocalDBF()
Local cLocalFile := ""
Local cRdd := ""
If Type("__cLocalDriver") <> "U"
	cRdd := __cLocalDriver
Else
	cLocalFile := AllTrim(Upper(GetSrvProfString("LocalFiles","ADS")))
	If cLocalFile = "ADS"
		cRdd := "DBFCDX"
	ElseIf cLocalFile = "CTREE"
		cRdd := "DBFCDXADS"
	EndIf
EndIf

Return cRdd