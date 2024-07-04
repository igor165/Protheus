#INCLUDE "HHxfun.ch"
#include "protheus.ch"
#include "Fileio.ch"

#define VM_INSERT 08192   // Inclusao de Registro
#define VM_UPDATE 16384   // Alteracao de Registro
#define VM_DELETE 32768   // Exclusao de Registro
#DEFINE KB_ENTER Chr(13)+Chr(10)

#define PSYSFILE  "HCADSYS"
#define PTBLFILE  "HCADTBL"
#define PUFILE	   "HCADHH"
#define PSFILE	   "HCADSRV"
#define PGFILE	   "HCADGRP"
#define PGHFILE   "HGRPHH"
#define PGSFILE   "HGRPSRV"
#define PSTFILE   "HSRVTBL"
#define PHHFILE   "HHFILE"
#define PGENFILE  "HHGEN"
#define PCTRFILE  "HHCTR"
#define PLFILE	   "HHLOG"
#define PTFILE	   "HHTIME"
#define PTRGFILE  "HHTRG"                                                          	

#define PSYSALIAS "HHS"
#define PTBLALIAS "HHT"
#define PUALIAS	   "HHU"
#define PSALIAS	   "HHR"
#define PSTALIAS  "HST"
#define PGALIAS   "HHG"
#define PGHALIAS  "HGU"
#define PGSALIAS  "HGS"
#define PLALIAS	   "HHL"
#define PHHALIAS  "HHFILE"
#define PGENALIAS "HHGEN"
#define PCTRALIAS "HHCTR"
#define PTALIAS	   "PALMTIME"
#define PFALIAS	   "PALMFILE"
#define PTRGALIAS "HHTRG"
#IFNDEF TOP
	#define RetSqlName RetDbfName
#ENDIF
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

Static __PError
Static __HHInJob := .F.
Static __nHdl
Static __LogID
Static cLastLog := Replicate("0",10)
Static PALMDIR  := GetSrvProfString("HHTrgDir","\HHTRG\")

/*
*************************************************
* Funcoes p/ abertura dos arquivos do palm		*
*************************************************
*************************************************
* HHOpenTime()									*
* verifica se a tabela PALMTIME e seus indices	*
* existem e cria se necessario;					*
* abre a tabela e indices						*
*************************************************
*/
Function HHOpenTime()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PTFILE
Local nTrys := 3
Local nTimes := 0
Local cDriver := GetLocalDriver()

If ( Select(PTALIAS) == 0 )
	//If ( !MsFile(cFile+ ".DBF",,__LocalDriver) )
	If ( !MsFile(cFile+ GetDBExtension(),,cDriver) )
		aStru := {}
		Aadd(aStru,{"HH_GRUPO"  ,"C", 06,0})
		Aadd(aStru,{"HH_SERIE"  ,"C", 20,0})
		Aadd(aStru,{"HH_SRV"    ,"C", 06,0})		
		Aadd(aStru,{"HH_TIME"   ,"C", 16,0})
		Aadd(aStru,{"HH_RANGE"  ,"C", 08,0})
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	While Select(PTALIAS) = 0 .And. nTimes <= nTrys
		//DbUseArea(.T.,cDriver,cFile+".DBF",PTALIAS,.T.)
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PTALIAS,.T.)
		Sleep(2000)
		nTimes++
	EndDo
	If Select(PTALIAS) == 0
		ConOut(STR0001) //"PALMJOB: Falhou Abertura da tabela HHTIME."
	EndIf
	cIndex := PTFILE+"1"
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HH_GRUPO + HH_SERIE + HH_TIME TAG &cIndex TO &cFile
		DbClearInd()
	EndIf
	DbSetIndex(cFile)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PTALIAS
/*
*************************************************
* POpenHHGen()									*
*************************************************
*/
Function POpenHHGen()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PGENFILE //PALMDIR+
Local nTrys := 3
Local nTimes := 0

If ( Select(PGENALIAS) == 0 )
	If ( !MsFile(cFile,,__cRdd) )
		aStru := {}
		Aadd(aStru,{"USERID"     ,"C", 10,0})
		Aadd(aStru,{"TABLENAME"  ,"C", 20,0})
		Aadd(aStru,{"VERSION"    ,"N", 10,0})
//		Aadd(aStru,{"LASTKEY"    ,"C", 50,0})
		Aadd(aStru,{"MAXVERSION" ,"N", 10,0})
		Aadd(aStru,{"OPER"       ,"C", 01,0})
		Aadd(aStru,{"EMP"        ,"C", 02,0})
		Aadd(aStru,{"FIELDVER"   ,"C", 10,0})
		Aadd(aStru,{"FIELDCTRL"  ,"C", 10,0})
      MsCreate(cFile,aStru,__cRdd)
	EndIf
	While Select(PGENALIAS) = 0 .And. nTimes <= nTrys 
		DbUseArea(.T.,__cRdd,cFile,PGENALIAS,.T.)
		Sleep(1000)
		nTimes++
	EndDo
	If Select(PGENALIAS) = 0
		ConOut(STR0002 + PGENFILE + ".") //"PALMJOB: Falhou Abertura da tabela "
	EndIf
	cIndex := PGENFILE+"1"
	If ( !MsFile(cFile,cIndex, __cRdd) )
		DbCreateInd(cIndex,"USERID + TABLENAME",{|| "USERID + TABLENAME" })
		cIndex := PGENFILE+"2"
		DbCreateInd(cIndex,"TABLENAME + USERID",{|| "TABLENAME + USERID" })
		cIndex := PGENFILE+"3"
		DbCreateInd(cIndex,"EMP + USERID + TABLENAME",{|| "EMP + USERID + TABLENAME" })	
		DbClearInd()
	EndIf
	cIndex := PGENFILE+"1"
	DbSetIndex(cIndex)
	cIndex := PGENFILE+"2"
	DbSetIndex(cIndex)
	cIndex := PGENFILE+"3"
	DbSetIndex(cIndex)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PGENALIAS


/*
*************************************************
* POpenHHCtr()									*
*************************************************
*/
Function POpenHHCtr()
Local cIndex
Local aStru
Local cSvAlias	:= Alias()
Local cFile 	:= PCTRFILE //PALMDIR+
Local nTrys		:= 3
Local nTimes	:= 0
Local cFileExt	:= ""
Local cIndexExt	:= ""

If ( Select(PCTRALIAS) == 0 )
	#IFNDEF TOP 
		cFileExt := GetDBExtension()
	#ENDIF
	If ( !MsFile(cFile+cFileExt,,__cRdd) )
		aStru := {}
		Aadd(aStru,{"USERID"     ,"C", 010,0})
		Aadd(aStru,{"TABLENAME"  ,"C", 020,0})
		Aadd(aStru,{"VERSION"    ,"N", 010,0})
		Aadd(aStru,{"MAXVERSION" ,"N", 010,0})
		Aadd(aStru,{"AMNT"       ,"N", 010,0})
		Aadd(aStru,{"GENERIC"    ,"C", 001,0})
		Aadd(aStru,{"FIELDVER"   ,"C", 010,0})
		Aadd(aStru,{"FIELDCTRL"  ,"C", 010,0})
		Aadd(aStru,{"OPER"       ,"C", 001,0})
		Aadd(aStru,{"EMP"        ,"C", 002,0})
		MsCreate(cFile,aStru,__cRdd)
	EndIf
	While Select(PCTRALIAS) = 0 .And. nTimes <= nTrys 
		DbUseArea(.T.,__cRdd,cFile,PCTRALIAS,.T.)
		Sleep(1000)
		nTimes++
	EndDo
	If Select(PCTRALIAS) = 0
		ConOut(STR0002 + PCTRALIAS + ".") //"PALMJOB: Falhou Abertura da tabela "
	EndIf
	cIndex := PCTRALIAS+"1"
	#IFNDEF TOP
		cIndexExt := ".CDX"
	#ENDIF
	If ( !MsFile(cFile+cFileExt,cIndex+cIndexExt, __cRdd) )
		DbCreateInd(cIndex,"USERID + TABLENAME",{|| "USERID + TABLENAME" })
		cIndex := PCTRALIAS+"2"
		#IFNDEF TOP
			cIndex += ".CDX"
		#ENDIF
		DbCreateInd(cIndex,"TABLENAME + USERID",{|| "TABLENAME + USERID" })
		cIndex := PCTRALIAS+"3"
		#IFNDEF TOP
			cIndex += ".CDX"
		#ENDIF
		DbCreateInd(cIndex,"EMP + USERID + TABLENAME",{|| "EMP + USERID + TABLENAME" })
		DbClearInd()
	EndIf
	cIndex := PCTRALIAS+"1"
	DbSetIndex(cIndex)
	cIndex := PCTRALIAS+"2"
	DbSetIndex(cIndex)
	cIndex := PCTRALIAS+"3"

	DbSetIndex(cIndex)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PCTRALIAS


/*
*************************************************
* HHOpenLog()									*
* verifica se a tabela PALMLOG e seus indices	*
* existem e cria se necessario;					*
* abre a tabela e indices e procura pelo ultimo *
* LOGID											*
*************************************************
*/
Function HHOpenLog()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PLFILE
Local cDriver := GetLocalDriver()

If ( Select(PLALIAS) == 0 )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )
		aStru := {}
		Aadd(aStru,{"HHL_GRUPO"  ,"C", 06,0})
		Aadd(aStru,{"HHL_SERIE"    ,"C", 20,0})
		Aadd(aStru,{"HHL_SEQ"       ,"C", 10,0})
		Aadd(aStru,{"HHL_DATA"   ,"D",  8,0})
		Aadd(aStru,{"HHL_HORA1"  ,"C",  8,0})
		Aadd(aStru,{"HHL_OPER1"   ,"C",04,0})
		Aadd(aStru,{"HHL_HORA2"  ,"C",  8,0})
		Aadd(aStru,{"HHL_OPER2"   ,"C",04,0})
		Aadd(aStru,{"HHL_OBS"     ,"C",100,0})
        MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PLALIAS,.T.)
	cIndex := PLFILE+"1"
	cFile := PALMDIR+PLFILE
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HHL_GRUPO+HHL_SERIE+HHL_SEQ TAG &cIndex TO &cFile
		cIndex := PLFILE+"2"
		INDEX ON HHL_SERIE+DTOS(HHL_DATA)+HHL_HORA1 TAG &cIndex TO &cFile
		cIndex := PLFILE+"3"
		INDEX ON HHL_SERIE+HHL_OPER1 TAG &cIndex TO &cFile
		DbCloseArea()
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PLALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PLALIAS


/*
*************************************************
* HHOpenTrg()									*
* Cria tabela de controle de gatilhos       	*
*************************************************
*/
Function HHOpenTrg()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PTRGFILE
Local cDriver := GetLocalDriver()

MakeDir(PALMDIR)

If ( Select(PTRGALIAS) == 0 )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )
		aStru := {}
		Aadd(aStru,{"HTR_EMP"    ,"C", 02,0})
		Aadd(aStru,{"HTR_FIL"    ,"C", 02,0})
		Aadd(aStru,{"HTR_ALIAS"    ,"C", 06,0})
		Aadd(aStru,{"HTR_TABLE"    ,"C", 30,0})
		Aadd(aStru,{"HTR_TRG"    ,"C", 01,0})
        MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PTRGALIAS,.T.)
	cIndex := PTRGFILE+"1"
	cFile := PALMDIR+PTRGFILE
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HTR_EMP+HTR_FIL+HTR_ALIAS TAG &cIndex TO &cFile
		cIndex := PTRGFILE+"2"
		INDEX ON HTR_ALIAS+HTR_EMP+HTR_FIL TAG &cIndex TO &cFile
		DbCloseArea()
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PTRGALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf

If ( !Empty(cSvAlias) )
	DbSelectArea(cSvAlias)
EndIf
Return PTRGALIAS


//outras funcoes
/////////////////////
// HHExeServ - Executa o servico
/////////////////////
Function HHExeServ(nServ)

DEFAULT nServ := 0

If ( nServ > 0 .And. nServ <= Len(aServ) )
    If ( FindFunction(aServ[nServ][3]) )
		cFunc := AllTrim(aServ[nServ][3])+If(At("(",aServ[nServ][3]) == 0,"()","")
		&cFunc
	Else
		If !HHInJob()
			ConOut(STR0003,STR0004+aServ[nServ][3],STR0005) //"Erro de configuracao."###"Funcao nao encontrada - "###"Atenção"
			MsgInfo(STR0006+aServ[nServ][3],STR0005) //"Erro de configuracao.Funcao nao encontrada - "###"Atenção"
		Else
			ConOut(STR0004+aServ[nServ][3]) //"Funcao nao encontrada - "
			PUpdLog(,STR0004+aServ[nServ][3]) //"Funcao nao encontrada - "
			HHSetError(.T.)
		EndIf
	EndIf
EndIf

Return

/////////////////////
// HHExeTable - Retorna alias utilizados pelo servico
/////////////////////
Function HHExeTable(nServ)
Local cAlias    := AllTrim(aServ[nServ][4])
Local aRetAlias := {}
Local cRetAlias := ""
DEFAULT nServ := 0

If ( nServ > 0 .And. nServ <= Len(aServ) )
	If ( !Empty(cAlias) ) // Alias
		While Len(cAlias) != 0
			nPos      := At(",", cAlias)
			cRetAlias :=Subs(cAlias, 1, If(nPos !=0,nPos-1,Len(cAlias)))
			aAdd(aRetAlias,cRetAlias)
			cAlias    := If(nPos != 0, Subs(cAlias,nPos+1,Len(cAlias)), "")
		EndDo
	EndIf
EndIf
Return aClone(aRetAlias)

/////////////////////
// HHExeArq - retorna arquivos criados pelo servico
/////////////////////
Function HHExeArq(nServ)
Local cArq := AllTrim(aServ[nServ][5])
Local cRetArq := ""
Local aRetArq := {}
//Local cEmp := Subs((PGALIAS)->HHG_EMPFIL,1,2) + "0"
DEFAULT nServ := 0

If ( nServ > 0 .And. nServ <= Len(aServ) )
	If ( !Empty(cArq) )
		While Len(cArq) != 0
			nPos     := At(",", cArq)
			cRetArq  := Subs(cArq, 1, If(nPos !=0,nPos-1,Len(cArq)))// + If(nPos !=0,',"',"")
			// Verifica se utiliza a empresa no nome do arquivo
			//If aServ[nServ,9] = "1"
			//	aAdd(aRetArq, cRetArq + cEmp)
			//Else
			 	aAdd(aRetArq, cRetArq)
			//EndIf
			cArq := If(nPos != 0, Subs(cArq,nPos+1,Len(cArq)), "")
		EndDo
	EndIf
EndIf

Return Aclone(aRetArq)

/////////////////////
// HHExeInd - retorna indices dos arquivos criados pelo servico
/////////////////////
Function HHExeInd(nServ)
Local cInd := AllTrim(aServ[nServ][6])
Local cRetInd := ""
Local cAliasInd := ""
Local aRetInd := {}
Local aTempInd := {}
DEFAULT nServ := 0

If ( nServ > 0 .And. nServ <= Len(aServ) )
	If ( !Empty(cInd) )
		While Len(cInd) != 0
			nPos     := At("/", cInd)
			cAliasInd  := Subs(cInd, 1, If(nPos !=0,nPos-1,Len(cInd))) + ","
			nPosVirg := At(",", cAliasInd)
			While nPosVirg > 0
				cRetInd  := Subs(cAliasInd, 1, If(nPosVirg !=0,nPosVirg-1,Len(cAliasInd)))
				aAdd(aTempInd, cRetInd)
				cAliasInd:= If(nPosVirg != 0, Subs(cAliasInd,nPosVirg+1,Len(cAliasInd)), "")	
				nPosVirg := At(",", cAliasInd)			
			EndDo  
			aAdd(aRetInd, aTempInd)
			aTempInd := {}
			cInd     := If(nPos != 0, Subs(cInd,nPos+1,Len(cInd)), "")
		EndDo
	EndIf
EndIf
Return Aclone(aRetInd)

///////////// Verificar
Function HHInJob(lSet)
Local lRet

DEFAULT __HHInJob := .F.

lRet := __HHInJob

If ( lSet <> NIL )
	__HHInJob := lSet
EndIf
Return lRet

Function HHSetError(lSet)
Local lRet

DEFAULT __PError := .F.

lRet := __PError

If ( lSet <> NIL )
	__PError := lSet
EndIf

Return lRet

///////////// Verificar

/////////////////////
// HHGetDir - retorna diretorio utilizado pelo JOB
/////////////////////
Function HHGetDir()
Return PALMDIR

/////////////////////
// HHExistServ - verifica se o servico existe
/////////////////////
Function HHExistServ(cTipo)
Local nRet

DEFAULT cTipo := ""

cTipo := Trim(cTipo)

//PReadSVC()

nRet := Ascan(aServ,{|x| x[1] == cTipo})

Return nRet

/*
*************************************
* POpenSys()						*
* Cria ou Abre a tabela de Sistemas	*
*************************************
*/
Function POpenSys()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR + PSYSFILE
Local cDriver := GetLocalDriver()
//Local cFile := PALMDIR + "HHS" + EMPTEST + "0"

If ( Select(PSYSALIAS) == 0 )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )
		aStru := {}
		Aadd(aStru,{"HHS_COD"     ,"C", 06,0})
		Aadd(aStru,{"HHS_DESCR"   ,"C", 40,0})
		Aadd(aStru,{"HHS_TAB"     ,"C", 03,0})
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PSYSALIAS,.T.)
	cIndex := cFile+"1"
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HHS_COD TAG &cIndex TO &cFile
		dbCloseArea()
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PSYSALIAS,.T.)
		//DbCreateInd(cIndex,"HHS_COD",{|| "HHS_COD" })
		//DbClearInd()
	EndIf
	//DbSetIndex(cIndex)
	DbSetIndex(cFile)
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return PSYSALIAS

/*
*************************************
* POpenGrp()						*
* Cria ou Abre a tabela de Grupos 	*
*************************************
*/
Function POpenGrp()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR + PGFILE
Local cDriver := GetLocalDriver()
//Local cFile := PALMDIR + "HHG" + EMPTEST + "0"

// Arquivo de Grupos
If ( Select(PGALIAS) == 0 )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )	
		aStru := {}
		Aadd(aStru,{"HHG_COD"     ,"C", 06,0})
		Aadd(aStru,{"HHG_DESCR"   ,"C", 40,0})
		Aadd(aStru,{"HHG_SYS"     ,"C", 06,0})
		Aadd(aStru,{"HHG_EMPFIL"  ,"C", 04,0})
		Aadd(aStru,{"HHG_FREQ"    ,"N", 03,0})
		Aadd(aStru,{"HHG_TFREQ"   ,"C", 01,0})
		Aadd(aStru,{"HHG_SCRIPT"   ,"C", 30,0})
		Aadd(aStru,{"HHG_SUFIXO"   ,"C", 01,0})
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PGALIAS,.T.)
	cIndex := cFile+"1"
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HHG_COD  TAG &cIndex TO &cFile		
		dbCloseArea()
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PGALIAS,.T.)
		//DbCreateInd(cIndex,"HHG_COD",{|| "HHG_COD" })
		//DbClearInd()
	EndIf
	DbSetIndex(cFile)
	//DbSetIndex(cIndex)
EndIf

// Arquivo Grupos x Servico
cFile := PALMDIR + PGSFILE
//cFile := PALMDIR + "HGS" + EMPTEST + "0"
If ( Select(PGSALIAS) == 0 )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )	
		aStru := {}
		Aadd(aStru,{"HGS_GRUPO"   ,"C", 06,0})
		Aadd(aStru,{"HGS_SRV"     ,"C", 06,0})
		Aadd(aStru,{"HGS_TIPO"    ,"C", 01,0})
		Aadd(aStru,{"HGS_FREQ"    ,"N", 03,0})
		Aadd(aStru,{"HGS_TFREQ"   ,"C", 01,0})
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PGSALIAS,.T.)
	cIndex := cFile+"1"
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HGS_GRUPO +  HGS_SRV + HGS_TIPO  TAG &cIndex TO &cFile		
		//DbCreateInd(cIndex,"HGS_GRUPO + HGS_SRV + HGS_TIPO",{|| "HGS_GRUPO + HGS_SRV + HGS_TIPO" })
		cIndex := cFile+"2"
		INDEX ON HGS_SRV + HGS_TIPO  TAG &cIndex TO &cFile		
		//DbCreateInd(cIndex,"HGS_SRV + HGS_TIPO",{|| "HGS_SRV + HGS_TIPO" })
		cIndex := cFile+"3"
		INDEX ON HGS_GRUPO + HGS_TIPO +  HGS_SRV  TAG &cIndex TO &cFile		
		//DbCreateInd(cIndex,"HGS_GRUPO + HGS_TIPO",{|| "HGS_GRUPO + HGS_TIPO" })
		//DbClearInd()
		dbCloseArea()
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PGSALIAS,.T.)
	EndIf
	//cIndex := cFile+"1"
	//DbSetIndex(cIndex)
	//cIndex := cFile+"2"
	//DbSetIndex(cIndex)
	//cIndex := cFile+"3"
	//DbSetIndex(cIndex)
	DbSetIndex(cFile)
EndIf


// Arquivo Grupos x Usuarios
cFile := PALMDIR + PGHFILE
If ( Select(PGHALIAS) == 0 )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )
		aStru := {}
		Aadd(aStru,{"HGU_GRUPO"     ,"C", 06,0})
		Aadd(aStru,{"HGU_SERIE"     ,"C", 20,0})
		Aadd(aStru,{"HGU_CODBAS"    ,"C", 06,0})		
		Aadd(aStru,{"HGU_DIR"       ,"C", 06,0})
		Aadd(aStru,{"HGU_SCRIPT"   ,"C", 60,0})
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PGHALIAS,.T.)
	cIndex := cFile+"1"
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HGU_GRUPO + HGU_SERIE  TAG &cIndex TO &cFile		
		//DbCreateInd(cIndex,"HGU_GRUPO + HGU_SERIE",{|| "HGU_GRUPO + HGU_SERIE" })
		cIndex := cFile+"2"
		INDEX ON HGU_SERIE + HGU_CODBAS  TAG &cIndex TO &cFile
		//DbCreateInd(cIndex,"HGU_SERIE",{|| "HGU_SERIE" })
		//DbClearInd()
		cIndex := cFile+"3"
		INDEX ON HGU_CODBAS + HGU_GRUPO TAG &cIndex TO &cFile

		dbCloseArea()
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PGHALIAS,.T.)
	EndIf
	//cIndex := cFile+"1"
	//DbSetIndex(cIndex)
   //cIndex := cFile+"2"
	//DbSetIndex(cIndex)
	DbSetIndex(cFile)
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return PGALIAS

/*
*************************************
* POpenSrv()						*
* Cria ou Abre a tabela de Servicos	*
*************************************
*/
Function POpenSrv()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR + PSFILE
Local cDriver := GetLocalDriver()
//Local cFile := PALMDIR + "HHR" + EMPTEST + "0"

If ( Select(PSALIAS) == 0 )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )
		aStru := {}
		Aadd(aStru,{"HHR_COD"     ,"C", 006,0})
		Aadd(aStru,{"HHR_DESCR"   ,"C", 040,0})
		Aadd(aStru,{"HHR_FUNCAO"  ,"C", 015,0})
		Aadd(aStru,{"HHR_ALIAS"   ,"C", 255,0})
		Aadd(aStru,{"HHR_ARQ"     ,"C", 255,0})
		Aadd(aStru,{"HHR_TIPO"    ,"C", 001,0}) // 1)AP6 -> Handheld; 2)Handheld -> AP6
		Aadd(aStru,{"HHR_EXEC"    ,"C", 001,0}) // 1)Individual ; 2)Generica
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	MsOpenDbf(.T.,cDriver,cFile+GetDBExtension(),PSALIAS,.T.,.F.,.F.,.F.)
	cIndex := cFile+"1"
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HHR_COD  TAG &cIndex TO &cFile
		//DbCreateInd(cIndex,"HHR_COD",{|| "HHR_COD" })
		//DbClearInd()
		dbCloseArea()
		MsOpenDbf(.T.,cDriver,cFile+GetDBExtension(),PSALIAS,.T.,.F.,.F.,.F.)
	EndIf
	//DbSetIndex(cIndex)
	DbSetIndex(cFile)
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return PSALIAS


/*
*************************************
* POpenHH()		  					*
* Cria ou Abre a tabela de Handhelds*
*************************************
*/
Function POpenHH()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR+PUFILE
Local cDriver := GetLocalDriver()

If ( Select(PUALIAS) == 0 )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
		aStru := {}
		Aadd(aStru,{"HHU_SERIE"   ,"C", 15,0})
		Aadd(aStru,{"HHU_NOMUSR"  ,"C", 40,0})
		Aadd(aStru,{"HHU_CODUSR"  ,"C", 06,0})
		Aadd(aStru,{"HHU_DEVICE"  ,"C", 01,0}) //1)Palm OS; 2)Pocket
		Aadd(aStru,{"HHU_LOCK"    ,"C", 01,0}) //J=Job; H=Handheld; B=Bloqueado
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	MsOpenDbf(.T.,cDriver,cFile+GetDBExtension(),PUALIAS,.T.,.F.,.F.,.F.)
	cIndex := cFile+"1"
	If ( !MsFile(cFile,cIndex, cDriver) )
		INDEX ON HHU_SERIE  TAG &cIndex TO &cFile
		//DbCreateInd(cIndex,"HHU_SERIE",{|| "HHU_SERIE" })
		//DbClearInd()
		dbCloseArea()
		MsOpenDbf(.T.,cDriver,cFile+GetDBExtension(),PUALIAS,.T.,.F.,.F.,.F.)
	EndIf
	//DbSetIndex(cIndex)
	DbSetIndex(cFile)
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return PUALIAS


/*
*************************************
* POpenTbl()						*
* Cria ou Abre a tabela de Tabela	*
*************************************
*/
Function POpenTbl()
Local cIndex
Local aStru
Local cSvAlias := Alias()
Local cFile := PALMDIR + PTBLFILE
Local cDriver := GetLocalDriver()

If ( Select(PTBLALIAS) == 0 )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )
		aStru := {}
		Aadd(aStru,{"HHT_COD"     ,"C", 06,0})
		Aadd(aStru,{"HHT_DESCR"   ,"C", 40,0})
		Aadd(aStru,{"HHT_ALIAS"   ,"C", 06,0})
		Aadd(aStru,{"HHT_GEN"     ,"C", 01,0})
		Aadd(aStru,{"HHT_TOHOST"   ,"C", 01,0})
		Aadd(aStru,{"HHT_FLDFIL"   ,"C", 20,0})
		Aadd(aStru,{"HHT_FILEMP"   ,"C", 01,0})
		Aadd(aStru,{"HHT_SHARE"   ,"C", 01,0})
		Aadd(aStru,{"HHT_VER"     ,"N", 10,0})
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PTBLALIAS,.T.)
	cIndex := cFile+"1"
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HHT_COD TAG &cIndex TO &cFile
		cIndex := cFile+"2"
		INDEX ON HHT_ALIAS TAG &cIndex TO &cFile
		dbCloseArea()
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PTBLALIAS,.T.)
		//DbCreateInd(cIndex,"HHS_COD",{|| "HHS_COD" })
		//DbClearInd()
	EndIf
	//DbSetIndex(cIndex)
	DbSetIndex(cFile)
EndIf

cFile := PALMDIR + PSTFILE
If ( Select(PSTALIAS) == 0 )
	//If ( !MsFile(cFile+".DBF",,cDriver) )
	If ( !MsFile(cFile+GetDBExtension(),,cDriver) )
		aStru := {}
		Aadd(aStru,{"HST_CODSRV"   ,"C", 06,0})
		Aadd(aStru,{"HST_CODTBL"   ,"C", 06,0})
		MsCreate(cFile+GetDBExtension(),aStru,cDriver)
	EndIf
	DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PSTALIAS,.T.)
	cIndex := cFile+"1"
	If ( !MsFile(cFile,cIndex,cDriver) )
		INDEX ON HST_CODSRV + HST_CODTBL TAG &cIndex TO &cFile
		cIndex := cFile+"2"
		INDEX ON HST_CODTBL TAG &cIndex TO &cFile
		dbCloseArea()
		DbUseArea(.T.,cDriver,cFile+GetDBExtension(),PSTALIAS,.T.)
	EndIf
	DbSetIndex(cFile)
EndIf


If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return PTBLALIAS

/*
///////////////
/// HHOpenTransmit - Cria/Abre arquivo MCS_CTRL
///////////////

Function HHOpenTransmit(cDifsDir, cOper)
Local cIndex
Local aStru
Local cSvAlias := Alias()
//Local cFile := cDifsDir+"MCS_CTRL" 
Local cFile := cDifsDir+"HHCTR"

DEFAULT cOper := ""

If ( Select("TRANSMIT") == 0 )
	aStru := {}
	Aadd(aStru,{"TABLENAME"  ,"C", 20,0})
	Aadd(aStru,{"LASTKEY"   ,"C", 255,0})
	Aadd(aStru,{"AMNT"   ,"N", 10,0})
	Aadd(aStru,{"OPER"   ,"C", 01,0})
	Aadd(aStru,{"INTR"     ,"C", 01,0})
	
	If ( !MsFile(cFile,,__cRdd) )
        MsCreate(cFile,aStru,__cRdd)
        cOper := If(Empty(cOper), "T", cOper)
	Else
		cOper := If(Empty(cOper), "P", cOper)
	EndIf

	DbUseArea(.T.,__cRdd,cFile,"TRANSMIT",.T.)
	cIndex := "MCS_CTRL1"
	If ( !MsFile(cFile,cIndex,__cRdd) )
		DbCreateInd(cIndex,"TABLENAME",{|| "TABLENAME" })		
		//INDEX ON TBLNAME TAG &cIndex TO &cFile
		dbCloseArea()
		DbUseArea(.T.,__cRdd,cFile,"TRANSMIT",.T.)
	EndIf
	DbSetIndex(cIndex)
EndIf

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return "TRANSMIT"
*/
Function POpenMCSTbl()
Local cFileTbl   := "ADV_TBL"   // Arquivos   (SX2)
Local cFileCols  := "ADV_COLS"  // Estruturas (SX3)
Local cFileInd   := "ADV_IND"   // Indices    (SIX)
Local cAliasTbl  := "ADV_TBL"
Local cAliasCols := "ADV_COLS"
Local cAliasInd  := "ADV_IND"
Local cInvalidField := "ID#VER#INTR#EMP"
Local aAdvTbl    := {}
LOcal aAdvCols   := {}
Local aAdvInd    := {}
Local cChaveTbl  := "" 
Local cChaveInd  := "" 
Local cEmpAll    := "@@"
Local nIndexes   := 1
Local nI         := 1
Local nJ         := 1
Local nInd       := 1
Local nIndID     := 1 // ID da tabela ADV_IND, sempre 1
Local nColsID    := 0 // ID da tabela ADV_IND, sempre 0
Local cIndexKey  := ""
Local cKey       := ""
Local cUser      := HGU->HGU_CODBAS
Local nVer       := 1

If Select("HHCTR") = 0
	POpenHHCtr()
EndIf

aadd(aAdvTbl,{"TABLEID"       , "N",  04, 0}) // ID da Tabela
aadd(aAdvTbl,{"TBLNAME"       , "C",  15, 0}) // Nome da Tabela
aadd(aAdvTbl,{"DESCR"         , "C",  15, 0}) // Descricao da Tabela
aadd(aAdvTbl,{"TBLTOHOST"     , "C",  01, 0}) // T=a Tabela volta para Retaguarda, F=nao volta para retaguarda 
aadd(aAdvTbl,{"TBL_EMP"       , "C",  02, 0}) // Empresa
aadd(aAdvTbl,{"TBLTP"         , "C",  01, 0}) // Tipo da tabela (1=Padrao, 2=Compartilhada (Filiais)
aadd(aAdvTbl,{"INTR"          , "C",  01, 0}) // Intr
aadd(aAdvTbl,{"VER"           , "N",  10, 0}) // Versao

aadd(aAdvCols,{"TABLEID"      , "N",  04, 0}) // ID da Tabela
aadd(aAdvCols,{"FLDPOS"       , "C",  03, 0}) // Posicao do Campo
aadd(aAdvCols,{"FLDNAME"      , "C",  30, 0}) // Nome do Campo
aadd(aAdvCols,{"FLDTYPE"      , "C",  01, 0}) // Tipo do Campo
aadd(aAdvCols,{"FLDLEN"       , "N",  03, 0}) // Tamanho do Campo
aadd(aAdvCols,{"FLDLENDEC"    , "N",  03, 0}) // Decimais do Campo
aadd(aAdvCols,{"TBL_EMP"      , "C",  02, 0}) // Empresa
aadd(aAdvCols,{"INTR"         , "C",  01, 0}) // Intr
aadd(aAdvCols,{"VER"          , "N",  10, 0}) // Versao
 
aadd(aAdvInd,{"TABLEID"       , "N", 004, 0}) // ID da Tabela
aadd(aAdvInd,{"NOME_IDX"      , "C", 020, 0}) // nome do Indice
aadd(aAdvInd,{"EXPRE"         , "C", 250, 0}) // Expressao do Indice
aadd(aAdvInd,{"PK"            , "C", 001, 0}) // Chave do Indice
aadd(aAdvInd,{"TBL_EMP"       , "C", 002, 0}) // Empresa
aadd(aAdvInd,{"INTR"          , "C", 001, 0}) // Intr
aadd(aAdvInd,{"VER"           , "N", 010, 0}) // Versao

// Cria ADB_TVL, ADV_COLS e ADV_IND 
If !MsFile(cFileTbl,,__cRdd)
   	MsCreate(cFileTbl,aAdvTbl,__cRdd)
EndIf

If !MsFile(cFileCols,,__cRdd)
	MsCreate(cFileCols,aAdvCols,__cRdd)
Endif

If !MsFile(cFileInd,,__cRdd)
	MsCreate(cFileInd,aAdvInd,__cRdd)
Endif

//////////////// INDICES ADV_TBL
If ( Select(cAliasTbl) == 0 )
	DbUseArea(.T.,__cRdd,cFileTbl,cAliasTbl,.T.)
Endif
cIndex := cFileTbl+"1" 
If ( !MsFile(cFileTbl,cIndex,__cRdd))
	DbCreateInd(cIndex,"TBL_EMP+TBLNAME",{|| "TBL_EMP+TBLNAME" })
	cIndex := cFileTbl+"2"
	DbCreateInd(cIndex,"Str(TABLEID,4,0)",{|| "Str(TABLEID,4,0)" })
	cIndex := cFileTbl+"3"
	DbCreateInd(cIndex,"TBL_EMP+Str(TABLEID,4,0)",{|| "TBL_EMP+Str(TABLEID,4,0)" })
EndIf
DbClearInd()
cIndex := cFileTbl+"1" 
dbSetIndex(cIndex)
cIndex := cFileTbl+"2" 
dbSetIndex(cIndex)
cIndex := cFileTbl+"3" 
dbSetIndex(cIndex)

//////////////// INDICES ADV_COLS
If ( Select(cAliasCols) == 0 )
	DbUseArea(.T.,__cRdd,cFileCols,cAliasCols,.T.)
Endif

cIndex := cFileCols+"1" 
If (!MsFile(cFileCols,cIndex,__cRdd))
	DbCreateInd(cIndex,"TBL_EMP+Str(TABLEID,4,0)+FLDPOS",{|| "TBL_EMP+Str(TABLEID,4,0)+FLDPOS" })
	cIndex := cFileCols+"2" 
	DbCreateInd(cIndex,"TBL_EMP+Str(TABLEID,4,0)+FLDNAME",{|| "TBL_EMP+Str(TABLEID,4,0)+FLDNAME" })
	cIndex := cFileCols+"3" 
	DbCreateInd(cIndex,"Str(TABLEID,4,0)+FLDNAME",{|| "Str(TABLEID,4,0)+FLDNAME" })
EndIf
DbClearInd()
cIndex := cFileCols+"1" 
dbSetIndex(cIndex)
cIndex := cFileCols+"2"
dbSetIndex(cIndex)
cIndex := cFileCols+"3"
dbSetIndex(cIndex)

//////////////// INDICES ADV_IND
If ( Select(cAliasInd) == 0 ) 
	DbUseArea(.T.,__cRdd,cFileInd,cAliasInd,.T.)
Endif
cIndex := cFileInd+"1"
If ( !MsFile(cFileInd,cIndex,__cRdd) )
	DbCreateInd(cIndex,"TBL_EMP+Str(TABLEID,4,0)+NOME_IDX",{|| "TBL_EMP+Str(TABLEID,4,0)+NOME_IDX" })
	cIndex := cFileInd+"2"
	DbCreateInd(cIndex,"Str(TABLEID,4,0)+NOME_IDX",{|| "Str(TABLEID,4,0)+NOME_IDX" })
EndIf
DbClearInd()
cIndex := cFileInd+"1"
DbSetIndex(cIndex) 
cIndex := cFileInd+"2"
DbSetIndex(cIndex) 


// Grava HHCTR para ADV_TBL
dbSelectArea("HHCTR")
dbSetOrder(3)
If !dbSeek(cEmpAll + cUser + Space(10-Len(cUser)) + cFileTbl)
	RecLock("HHCTR",.T.)
	HHCTR->USERID     := cUser
	HHCTR->TABLENAME  := cFileTbl
	HHCTR->VERSION    := 0
	HHCTR->MAXVERSION := 1
	HHCTR->GENERIC    := "T"
	HHCTR->OPER       := "T"
	HHCTR->EMP        := cEmpAll
	HHCTR->FIELDVER   := "VER"
	HHCTR->FIELDCTRL  := "INTR"
	HHCTR->(MsUnlock())
Else
	RecLock("HHCTR",.F.)
	HHCTR->VERSION    := 0
	HHCTR->MAXVERSION := 1
	HHCTR->OPER       := "T" //If(HHGEN->OPER != "T", "P","T")
	HHCTR->(MsUnlock())
EndIf

// Verifica HHCTR para ADV_COLS
dbSelectArea("HHCTR")
dbSetOrder(3)
If !dbSeek(cEmpAll + cUser + Space(10-Len(cUser)) + cFileCols)
	RecLock("HHCTR",.T.)
	HHCTR->USERID     := cUser
	HHCTR->TABLENAME  := cFileCols
	HHCTR->VERSION    := 0
	HHCTR->MAXVERSION := 1
	HHCTR->GENERIC    := "T"
	HHCTR->OPER       := "T"
	HHCTR->EMP        := cEmpAll
	HHCTR->FIELDVER   := "VER"
	HHCTR->FIELDCTRL  := "INTR"
	HHCTR->(MsUnlock())
Else
	RecLock("HHCTR",.F.)
	HHCTR->VERSION    := 0
	HHCTR->MAXVERSION := 1
	HHCTR->OPER       := "T" //If(HHGEN->OPER != "T", "P","T")
	HHCTR->(MsUnlock())
EndIf

// Verifica HHCTR para ADV_IND
dbSelectArea("HHCTR")
dbSetOrder(3)
If !dbSeek(cEmpAll + cUser + Space(10-Len(cUser)) + cFileInd)
	RecLock("HHCTR",.T.)
	HHCTR->USERID     := cUser
	HHCTR->TABLENAME  := cFileInd
	HHCTR->VERSION    := 0
	HHCTR->MAXVERSION := 1
	HHCTR->GENERIC    := "T"
	HHCTR->OPER       := "T"
	HHCTR->EMP        := cEmpAll
	HHCTR->FIELDVER   := "VER"
	HHCTR->FIELDCTRL  := "INTR"
	HHCTR->(MsUnlock())
Else
	RecLock("HHCTR",.F.)
	HHCTR->VERSION    := 0
	HHCTR->MAXVERSION := 1
	HHCTR->OPER       := "T"//If(HHGEN->OPER != "T", "P",)
	HHCTR->(MsUnlock())
EndIf

// Grava ADV_COLS na ADV_TBL
aStruInd := (cAliasCols)->(dbStruct())
nCpoInd  := Len( aStruInd )

(cAliasTbl)->( dbSetOrder(1) )
If !(cAliasTbl)->(dbSeek(cEmpAll + "ADV_COLS"))
	RecLock(cAliasTbl, .T.)
Else
	RecLock(cAliasTbl, .F.)
EndIf
(cAliasTbl)->TABLEID   := nColsID
(cAliasTbl)->TBLNAME   := "ADV_COLS"
(cAliasTbl)->DESCR     := "ADV_COLS"
(cAliasTbl)->TBLTOHOST := "F"
(cAliasTbl)->TBL_EMP   := cEmpAll
(cAliasTbl)->TBLTP     := "1"
(cAliasTbl)->INTR      := "I"
(cAliasTbl)->VER       :=  1
(cAliasTbl)->(MsUnlock())

// Campo ADV_COLS na Tabela ADV_COLS
aStruInd := (cAliasCols)->(dbStruct())
nCpoInd  := Len( aStruInd )

For nInd := 1 to nCpoInd         
	// Seek na ADV_COLS
	(cAliasCols)->( dbSetOrder(2) )
	cChaveTbl := cEmpAll + Str(nColsID,4,0) + aStruInd[nInd, 1]
	nPos      := At("_", aStruInd[nInd, 1])
	If !(cAliasCols)->(dbSeek(cChaveTbl)) .And. !Subs(aStruInd[nInd, 1], nPos+1, Len(aStruInd[nInd,1])) $ cInvalidField
		RecLock(cAliasCols, .T.)
		(cAliasCols)->TABLEID   := nColsID
		(cAliasCols)->FLDPOS    := StrZero(nInd, 3)
		(cAliasCols)->FLDNAME   := aStruInd[nInd, 1]
		(cAliasCols)->FLDTYPE   := aStruInd[nInd, 2]
		(cAliasCols)->FLDLEN    := aStruInd[nInd, 3]                    
		(cAliasCols)->FLDLENDEC := aStruInd[nInd, 4]
		(cAliasCols)->TBL_EMP   := cEmpAll
		(cAliasCols)->INTR      := "I"
		(cAliasCols)->VER       :=  1
		(cAliasCols)->(MsUnlock())
	EndIf
Next nInd

//////////////////  INDICES ADV_COLS
// Grava Indices da ADV_COLS na ADV_IND
nIndexes  := 1 // Grava apenas o indice 1 //(cAliasCols)->(DBOrderInfo(9))
(cAliasCols)->(dbSetOrder(1))
For nJ := 1 To nIndexes
	cChaveInd := cEmpAll + Str(nColsID,4,0) + UPPER((cAliasCols)->(OrdBagName(nJ)))
	cIndexKey := (cAliasCols)->(IndexKey(nJ)) + "+" 
	nPos := At("+", cIndexKey)
	cKey := ""
	While nPos != 0                    	
		cField := AllTrim(Subs(cIndexKey, 1, nPos-1))
		If "STR" $ cField
			nPosStr := At(",", cField)	
			If nPosStr > 0
				cField  := Subs(cField,5,Len(cField)-nPosStr+1)
			Else
				cField  := Subs(cField,5,Len(cField)-1)
			EndIf		
			//cField  := Subs(cField,5,Len(cField)-nPosStr+1)
		EndIf
		cIndexKey := Subs(cIndexKey, nPos+1, Len(cIndexKey))
		nPos := At("_", cField)
		If !Subs(cField, nPos+1, Len(cField)) $ cInvalidField
			cKey += cField + "+"
		EndIf			
		nPos := At("+", cIndexKey)
	Enddo
	cKey := Subs(cKey,1, Len(cKey) - 1) 
	If !(cAliasInd)->(dbSeek(cChaveInd)) 
		RecLock(cAliasInd, .T.)
	Else
		RecLock(cAliasInd, .F.)
	EndIf
	(cAliasInd)->TABLEID   := nColsID
	(cAliasInd)->NOME_IDX  := UPPER((cAliasCols)->(OrdBagName(nJ)))
	(cAliasInd)->EXPRE     := cKey
	(cAliasInd)->PK        := If( nJ == 1 , "T", "F" )
	(cAliasInd)->TBL_EMP   := cEmpAll
	(cAliasInd)->INTR      := "I"
	(cAliasInd)->VER      :=  1 //HHGenericUpd(, "ADV_IND", .T.,)	
	(cAliasInd)->(MsUnlock()) 
Next

// Grava ADVTBL para ADV_IND
aStruInd := (cAliasInd)->(dbStruct())
nCpoInd  := Len( aStruInd ) - 1

(cAliasTbl)->( dbSetOrder(1) )
If !(cAliasTbl)->(dbSeek(cEmpAll + "ADV_IND"))
	RecLock(cAliasTbl, .T.)
Else
	RecLock(cAliasTbl, .F.)
EndIf
(cAliasTbl)->TABLEID   := nIndID
(cAliasTbl)->TBLNAME   := "ADV_IND"
(cAliasTbl)->DESCR     := "ADV_IND"
(cAliasTbl)->TBLTOHOST := "F"
(cAliasTbl)->TBL_EMP   := cEmpAll
(cAliasTbl)->TBLTP     := "1"
(cAliasTbl)->INTR      := "I"
(cAliasTbl)->VER       :=  1
(cAliasTbl)->(MsUnlock())
 
// Grava ADV_COLS da Tabela ADV_IND
For nInd := 1 to nCpoInd         
	/// Seek na ADV_COLS
	(cAliasCols)->( dbSetOrder(2) )
	cChaveTbl:= cEmpAll + Str(nIndID,4,0) + aStruInd[nInd, 1]
	nPos := At("_", aStruInd[nInd, 1])
	If !(cAliasCols)->(dbSeek( cChaveTbl ) ) .And. !Subs(aStruInd[nInd, 1], nPos+1, Len(aStruInd[nInd,1])) $ cInvalidField
		RecLock(cAliasCols, .T.)
		(cAliasCols)->TABLEID   := nIndID
		(cAliasCols)->FLDPOS    := StrZero(nInd, 3)
		(cAliasCols)->FLDNAME   := aStruInd[nInd, 1]
		(cAliasCols)->FLDTYPE   := aStruInd[nInd, 2]
		(cAliasCols)->FLDLEN    := aStruInd[nInd, 3]                    
		(cAliasCols)->FLDLENDEC := aStruInd[nInd, 4]
		(cAliasCols)->TBL_EMP   := cEmpAll
		(cAliasCols)->INTR      := "I"
		(cAliasCols)->VER       :=  1
		(cAliasCols)->(MsUnlock())
	EndIf
Next nInd

// Grava Indices da ADV_IND na ADV_IND
nIndexes  := 1 // Grava apena o 1 indice //(cAliasInd)->(DBOrderInfo(9))
(cAliasInd)->(dbSetOrder(1))
For nJ := 1 To nIndexes
	cChaveInd:= cEmpAll+ Str(nIndID,4,0) + UPPER((cAliasInd)->(OrdBagName(nJ)))
	cIndexKey := (cAliasInd)->(IndexKey(nJ)) + "+" 
	nPos := At("+", cIndexKey)
	cKey := ""
	While nPos != 0
		cField := AllTrim(Subs(cIndexKey, 1, nPos-1))
		If "STR" $ cField
			nPosStr := At(",", cField)
			If nPosStr > 0
				cField  := Subs(cField,5,Len(cField)-nPosStr+1)
			Else
				cField  := Subs(cField,5,Len(cField)-1)
			EndIf
		EndIf
		cIndexKey := Subs(cIndexKey, nPos+1, Len(cIndexKey))
		nPos := At("_", cField)
		If !Subs(cField, nPos+1, Len(cField)) $ cInvalidField
			cKey += cField + "+"
		EndIf			
		nPos := At("+", cIndexKey)
	Enddo
	cKey := Subs(cKey,1, Len(cKey) - 1) 
	If !(cAliasInd)->(dbSeek(cChaveInd)) 
		RecLock(cAliasInd, .T.)
		(cAliasInd)->TABLEID   := nIndID
		(cAliasInd)->NOME_IDX  := UPPER((cAliasInd)->(OrdBagName(nJ)))
		(cAliasInd)->EXPRE     := cKey
		(cAliasInd)->PK        := If( nJ == 1 , "T", "F" )
		(cAliasInd)->TBL_EMP   := cEmpAll
		(cAliasInd)->INTR      := "I"
		(cAliasInd)->VER      :=  1 //HHGenericUpd(, "ADV_IND", .T.,)	
		(cAliasInd)->(MsUnlock()) 
	EndIf
Next

Return Nil

//////////////////////////////////////////////////////////////////////////////////
// Funcao que cria o catalogo das tabelas                                       //  
//////////////////////////////////////////////////////////////////////////////////
Function HHAdvTbl(aAlias)
Local cAliasTbl  := "ADV_TBL"
Local cAliasCols := "ADV_COLS"
Local cAliasInd  := "ADV_IND"
Local cInvalidField := "ID#VER#INTR#EMP"
Local cInvalidTable := "ADV_IND#HHEMP"
Local SourceIdx     := ""
Local DestIdx       := "" 
Local cChaveTbl     := "" 
Local cChaveInd     := "" 
Local nIndexes      := 1
Local nNextID       := 1
Local nI            := 1
Local nJ            := 1
Local cIndexKey     := ""
Local cKey          := ""
Local cSufixo       := "0"
Local lInvalid      := .F.
Local lEmpShare     := .F.
LOcal lFilShare     := .F.
Local lGravaInd		:= .F. //Variavel de controle da gravacao dos indices
Local lRLock		:= .F. //Variavel de controle para informar se sera incluido um novo indice ou apenas atualizado

// Busca Sufixo do Grupo
//dbSelectArea("HHG")
//dbSetOrder(1)
//If dbSeek(HGU->HGU_GRUPO)
If !HGU->(Eof())
	cSufixo := If(!Empty(HHG->HHG_SUFIXO), HHG->HHG_SUFIXO, "0")
EndIf
//Else
//	ConOut("PALMJOB: Grupo nao encontrado, na atribuicao de usuario.")
//EndIf

If (Select(cAliasTbl) == 0) .Or. (Select(cAliasCols) == 0) .Or. (Select(cAliasInd) == 0)
	POpenMCSTbl()
EndIf

nLenAlias := Len(aAlias)

For nI := 1 To nLenAlias
	// Identifica o Proximo ID de tabela a ser utilizado
	dbSelectArea(cAliasTbl)
	dbSetOrder(2) // Indice 2 - ID 
	dbGoBottom()
	nNextId := (cAliasTbl)->TABLEID + 1
	
	dbSelectArea("HHT")
	dbSetOrder(2)
	dbSeek(aAlias[nI])

	// Tabela compartilhada entre empresas gerar apenas uma vez na ADV_TBL e ADV_IND, utilizar @@
	lEmpShare   := If(HHT->HHT_SHARE == "T", .T., .F.)
	lFilShare   := If(Empty(xFilial(aAlias[nI])), .T., .F.)

	// Grava estrutura da tabela no ADV_TBL
	dbSelectArea(aAlias[nI])
	aStru    := (aAlias[nI])->(dbStruct())
	nLenStru := Len(aStru)
	cTblname := RetSqlName(aAlias[nI])
	If !(cTblname $ cInvalidTable)
		cTblname := Stuff(cTblname, Len(cTblname), 1,cSufixo)
		If !lEmpShare
			cEmpresa := cEmpAnt
		Else
			cEmpresa := "@@"  // Tabela compartilhada entre empresas
		EndIf
		lInvalid := .F.
	Else
		lInvalid := .T.
		cEmpresa := "@@"
	EndIf

	// Verifica se a tabela ja existe
	dbSelectArea( cAliasTbl )
	(cAliasTbl)->( dbSetOrder(1) )
   If dbSeek(cEmpresa + cTblName)
		nNextId := (cAliasTbl)->TABLEID
	EndIf

	// Grava ADVTBL para tabelas
	aStruInd := (cAliasInd)->(dbStruct())
	nCpoInd  := Len( aStruInd ) - 1
	
	(cAliasTbl)->( dbSetOrder(1) )
	If !dbSeek(cEmpresa + cTblName)  // ID da ADV_IND Sempre 0
		RecLock(cAliasTbl, .T.)
	Else
		RecLock(cAliasTbl, .F.)
	EndIf
	(cAliasTbl)->TABLEID   := nNextId
	(cAliasTbl)->TBLNAME   := cTblname
	(cAliasTbl)->DESCR     := cTblname
	(cAliasTbl)->TBLTOHOST := HHT->HHT_TOHOST
	(cAliasTbl)->TBL_EMP   := cEmpresa
	(cAliasTbl)->TBLTP     := If(lFilShare, "2", "1")
	(cAliasTbl)->INTR      := "I"
	(cAliasTbl)->VER       :=  1
	(cAliasTbl)->(MsUnlock())

	For nJ := 1 To nLenStru
		nPos := At("_", aStru[nJ, 1])
		// Verifica se o campo e valido
		If !Subs(aStru[nJ, 1], nPos+1, Len(aStru[nJ,1]))  $ cInvalidField
			(cAliasCols)->(	dbSetOrder(2)) // Indice 2 - Empresa + ID + Campo
			cChaveTbl := cEmpresa + Str(nNextId,4,0) + aStru[nJ, 1]	// Empresa + ID Tabela + Campo
			If !(cAliasCols)->(dbSeek(cChaveTbl))
				RecLock(cAliasCols, .T.)
			Else
				RecLock(cAliasCols, .F.)
			EndIf
			(cAliasCols)->TABLEID   := nNextId
			(cAliasCols)->FLDPOS    := StrZero(nJ, 3)
			(cAliasCols)->FLDNAME   := aStru[nJ, 1]
			(cAliasCols)->FLDTYPE   := aStru[nJ, 2]
			(cAliasCols)->FLDLEN    := aStru[nJ, 3]
			(cAliasCols)->FLDLENDEC := aStru[nJ, 4]
			(cAliasCols)->TBL_EMP   := cEmpresa
			(cAliasCols)->INTR      := "I"
			(cAliasCols)->VER       :=  1
			(cAliasCols)->(MsUnlock())
		EndIf
	Next nJ

	dbSelectArea( cAliasTbl )     
	(cAliasTbl)->( dbSetOrder(1) ) // Indice EMPRESA + ID
	
	dbSelectArea( cAliasInd )
	(cAliasInd)->( dbSetOrder(2) ) // Indice EMPRESA + TABELA + NOME DO INDICE

	// Numero de Indices do Alias
	dbSelectArea(aAlias[nI])
	dbSetOrder(1)
	nIndexes := DBOrderInfo(9)
	For nJ := 1 To nIndexes
		// Indice na SIX
		SourceIdx := (aAlias[nI])->(OrdBagName(nJ))
		If !lInvalid
			DestIdx := Upper(Stuff(SourceIdx, Len(SourceIdx)-1,1,cSufixo))
		Else
			DestIdx := Upper(SourceIdx)
		EndIf
		
		// Expressao do Indice
		cIndexKey := (aAlias[nI])->(IndexKey(nJ)) + "+"
		nPos := At("+", cIndexKey)
		cKey := ""
		While nPos != 0                    	
			cField := AllTrim(Subs(cIndexKey, 1, nPos-1))
			If "DTOS" $ cField
				cField := Subs(cField,6,Len(cField)-6)
			EndIf
			If "STR" $ cField
				nPosStr := At(",", cField)
				If nPosStr > 0
					cField  := Subs(cField,5,nPosStr-5)
				Else
					cField  := Subs(cField,5,Len(cField)-1)
				EndIf
			EndIf
			cIndexKey := Subs(cIndexKey, nPos+1, Len(cIndexKey))
			nPos := At("_", cField)
			If !Subs(cField, nPos+1, Len(cField)) $ cInvalidField
				cKey += cField + "+"
			EndIf			
			nPos := At("+", cIndexKey)
		EndDo
		cKey := Subs(cKey, 1, Len(cKey)-1)

		dbSelectArea(cAliasInd)
		dbSetOrder(2)
		cChaveInd := Str(nNextId, 4, 0) + DestIdx //Upper(cEmpAnt + cTblname + Space(15-Len(cTblname)) + DestIdx)
		// Seek no ADV_IND
		If !dbSeek(cChaveInd) // Se indice não for encontrado sera criado um novo indice.
			lGravaInd	:=	.T.
			lRLock		:=	.T.				
		ElseIf !( AllTrim(Upper(cKey)) == AllTrim(Upper((cAliasInd)->EXPRE)) )// se a expressao de um indice existente for alterada 
			lGravaInd	:=	.T.                                                 // a expressao do indice na tabela ADV_IND tambem sera alterado.
			lRLock		:=	.F.				
		EndIf
		If lGravaInd
			RecLock(cAliasInd, lRLock)
			(cAliasInd)->TABLEID   := nNextId
			(cAliasInd)->NOME_IDX  := DestIdx
			(cAliasInd)->EXPRE     := Upper(cKey)
			(cAliasInd)->PK        := If( nJ == 1 , "T", "F" )
			(cAliasInd)->TBL_EMP   := cEmpresa //cEmpAnt
			(cAliasInd)->VER       := 1
			(cAliasInd)->INTR      := "I"
			(cAliasInd)->(MsUnlock())
		EndIf 
	Next nJ
Next nI

// Atualiza a HHCTR (Resumo)
PUpdHHCtr(HGU->HGU_CODBAS, "ADVTBL", 0)
PUpdHHCtr(HGU->HGU_CODBAS, "ADVIND", 0)
PUpdHHCtr(HGU->HGU_CODBAS, "ADVCOL", 0)

//(cAliasTbl)->(dbCloseArea())
//(cAliasInd)->(dbCloseArea())
Return

Function HHCheckID(cAliasHH, cAliasAP)
Local cRet := Space(6)

DEFAULT cAliasAP := ""

If Select("HHT") = 0
	 POpenTbl()
EndIf

If Select("HGU") = 0
	 POpenGrp()
EndIf

dbSelectArea("HHT")
dbSetOrder(2)
If dbSeek(cAliasHH)
	If 	HHT->HHT_GEN = "2"
		If !Empty(HHT->HHT_FLDFIL)
			cField := AllTrim(HHT->HHT_FLDFIL)
			dbSelectArea(cAliasAP)
			cRet := &(cAliasAP + "->" + cField)
			If Empty(cRet) .And. cAliasAP == "SE1" // Busca ID atraves cliente do titulo
				dbSelectArea("SA1")
				dbSetOrder(1)
				If dbSeek(xFilial("SA1")+SE1->E1_CLIENTE)
					cRet := SA1->A1_VEND
				EndIf
			EndIf

			// Verifica se o ID esta cadastrado em algum grupo
			// Caso nao esteja retorna a string "0"
			nHGURecno := HGU->(Recno())
			dbSelectArea("HGU")
			dbSetOrder(3)
			If !dbSeek(cRet)
				cRet := "0"
			EndIf
			Goto(nHGURecno)
		Else
			cRet := HGU->HGU_CODBAS
		EndIf
	EndIf
EndIf

If ((ExistBlock("HHTRG01")))
	cRet := ExecBlock("HHTRG01",.F.,.F., {cRet,cAliasHH,cAliasAP} )
EndIf

Return cRet

Function ChkIntr(nOper, cIntr, cAlias, lFound)
Local cIntrFld := cAlias + "->" + cAlias + "_INTR"


If nOper != VM_DELETE .And. lFound .And. &(cIntrFld) = "I"
	cIntr := "I"
Else
	If nOper = VM_INSERT
		cIntr := "I"
	ElseIf nOper = VM_UPDATE
		If !lFound
			cIntr := "I"
		Else
			cIntr := "A"
		EndIf		
	ElseIf nOper = VM_DELETE
		cIntr := "E"
	EndIf
EndIf

Return cIntr

// Atualiza os registros da HHCTR na execucao dos Gatilhos
Function HHGenericUpd(cUser, cTables, nOper)
//Local cAlias    := ""
Local cTable    := ""
Local nVer      := 0
Local nMaxVer   := 1
Local cCurAlias := Alias()
Local cAliasUpd := "HHCTR"
Local cSeek := ""
Local nOrder := 1
DEFAULT cUser := ""

If Select("HHT") = 0
	 POpenTbl()
EndIf

If Select("HHCTR") = 0
	POpenHHCtr()
EndIf

cTable := RetSqlName(cTables)
dbSelectArea("HHT")
dbSetOrder(2)
If dbSeek(cTables)
	If HHT->HHT_GEN = "2" // Tabela Nao Generica
		cSeek := cUser + Space(10-Len(cUser)) + cTable
		nOrder := 1
	Else				  // Tabela Generica
		cSeek := cTable
		nOrder := 2
	EndIf
	dbSelectArea(cAliasUpd)
	dbSetOrder(nOrder)
	If dbSeek(cSeek)
		cQuery := "SELECT MAX(VERSION) VERSION,MAX(MAXVERSION) MAXVERSION "
		cQuery += "FROM HHCTR "
		cQuery += "WHERE "
		If HHT->HHT_GEN == "2" // Tabela Nao Generica
			cQuery += "USERID='"+cUser+"' AND "
		EndIf
		cQuery += "TABLENAME='"+cTable+"'  "	

		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"HHGENUPD")

		If !HHGENUPD->(Eof())
			If HHGENUPD->VERSION < HHGENUPD->MAXVERSION
				nMaxVer := Max(HHGENUPD->MAXVERSION,nMaxVer)
			Else
				nMaxVer := Max(HHGENUPD->MAXVERSION + 1,nMaxVer)
			EndIf
		EndIf	
		dbCloseArea()
		dbSelectArea(cAliasUpd)
		//nMaxVer := (cAliasUpd)->MAXVERSION + 1
		If nMaxVer >= 9999999999
			nVer    := 0
			nMaxVer := 1
		Else
			nVer    := (cAliasUpd)->VERSION
		EndIf
	Else
		nMaxVer := 1
	EndIf
EndIf
If !Empty(cCurAlias)
	dbSelectArea(cCurAlias)
EndIf
Return nMaxVer

Function HHAtuCtr(cUser, cTables, nMaxVer)
Local cTable    := RetSqlName(cTables)
Local cAliasUpd := "HHCTR"
Local cQuery 	:= ""
Local nQtdRec	:= 0

DEFAULT cUser := Space(Len(SA3->A3_COD))

If Select("HHT") = 0
	 POpenTbl()
EndIf

If Select("HHCTR") = 0
	POpenHHCtr()
EndIf

dbSelectArea("HHT")
dbSetOrder(2)
If dbSeek(cTables)
	If HHT->HHT_GEN = "2" // Tabela Nao Generica
		cSeek := cUser + Space(10-Len(cUser)) + cTable
		nOrder := 1
	Else				  // Tabela Generica
		cSeek := cTable
		nOrder := 2
	EndIf
	dbSelectArea(cAliasUpd)
	dbSetOrder(nOrder)
	If dbSeek(cSeek)
		#IFDEF TOP
			// Qtd de Registros a serem transmitidas
			cQuery := "SELECT COUNT(*) QTDREC FROM " + cTable + Space(1) + cTables + Space(1)
			cQuery += "WHERE " + cTables + "." + cTables + "_ID = '" + If(HHT->HHT_GEN = "1",Space(6),cUser) + "' "
			cQuery += "AND " + cTables + "." + cTables + "_INTR IN ('I','A','E') "

			If !Empty(xFilial(cTables)) .And. HHT->HHT_GEN = "2"  // Verificar as filiais quando a tabela for exclusiva e nao generica
				cUsrFilial := GetIdFilial(cUser)
				cQuery += "AND "+ cTables + "." + cTables + "_FILIAL IN " + cUsrFilial
			EndIf
			
			cQuery += " AND " + cTables + "." + cTables + "_VER > " + Str((cAliasUpd)->VERSION,10,0)
	
			cQuery := ChangeQuery(cQuery)
	
			Memowrite("HHGenericUpd.txt", cQuery)
		
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QTDREC",.T.,.T.)	
			nQtdRec := QTDREC->QTDREC
			QTDREC->(dbCloseArea()) 
			
			cUpdVer := "UPDATE " + cAliasUpd + " SET "
			cUpdVer += "MAXVERSION = " + Str(nMaxVer,10,0) 
	
			// Definicao do Campo AMNT
			cUpdVer += ", AMNT = " + Str(nQtdRec, 10,0) 
	
			// Definicao do Campo OPER
			If HHT->HHT_GEN = "2"  // Tabela Nao Generica
				cUpdVer += ", OPER = '" + If((cAliasUpd)->OPER="T", "T", "P") + "'"
			Else
				cUpdVer += ", OPER = 'P'"
			EndIf
	
			cUpdVer += " WHERE TABLENAME = '" + cTable + "'"
	
			If HHT->HHT_GEN = "2"  // Tabela Nao Generica
				cUpdVer += " AND USERID = '" + cUser + "'"
			Else
				cUpdVer += " AND (OPER = 'X' OR OPER = 'P')"
			EndIf
	
			TcSqlExec(cUpdVer)
	
			If HHT->HHT_GEN = "1"  // Tabela Generica
				cUpdVer := "UPDATE " + cAliasUpd + " SET "
				cUpdVer += "MAXVERSION = " + Str(nMaxVer,10,0) 
				cUpdVer += ", AMNT = " + Str(nQtdRec, 10,0) 
				cUpdVer += " WHERE TABLENAME = '" + cTable + "'"
				cUpdVer += " AND OPER = 'T'"
				
				TCSqlExec(cUpdVer)
			EndIf
		#ELSE
			cQuery := "('" + cTables + "')->" + cTables + "_ID = '" + If(HHT->HHT_GEN = "1",Space(6),cUser) + "' "
			cQuery += ".And. ('" + cTables + "')->" + cTables + "_INTR$'I/A/E' "
			cQuery += ".And. ('" + cTables + "')->" + cTables + "_VER > " + Str((cAliasUpd)->VERSION,10,0)
			(cTables)->(dbGoTop())
			While (cTables)->(!Eof())
				If &(cQuery)
					nQtdRec ++
				EndIf
				(cTables)->(dbSkip())
			EndDo
			dbSelectArea("HHT")
			dbSetOrder(2)
			If MsSeek(cTables)
				If HHT->HHT_GEN == "2" // Tabela Nao Generica
					cSeek := cUser+cTable
					dbSelectArea("HHCTR")
					dbSetOrder(1)
				Else				  // Tabela Generica
					cSeek := cTable
					dbSelectArea("HHCTR")
					dbSetOrder(2)
				EndIf			
				dbSelectArea("HHCTR")
				If MsSeek(cSeek)
					While !Eof() .And. IIf(HHT->HHT_GEN=="2",HHCTR->USERID == cUser,.T.) .And. HHCTR->TABLENAME==RetDbfName(cTable)
						Begin Transaction
						RecLock("HHCTR")
						HHCTR->MAXVERSION := nMaxVer
						HHCTR->AMNT       := nQtdRec
						HHCTR->OPER       := IIF(HHCTR->OPER=="T","T","P")
						MsUnLock()
						End Transaction
						dbSelectArea("HHCTR")
						dbSkip()					
					EndDo
				EndIf
			EndIf
		#ENDIF
	EndIf
EndIf
Return Nil


// Cria os registros da HHCTR na execucao do JOB
Function PUpdHHCtr(cUserID, cAlias, nRecs)
Local cCtrAlias := POpenHHCtr()
Local cCurAlias := Alias()
Local cIDFld    := "USERID"
Local cCtrlFld  := "INTR"
Local nQtdRec   := 0
Local nMax_Ver  := 0
Local cEmpresa  := cEmpAnt

If Select("HHT") = 0
	 POpenTbl()
EndIf

While Len(cAlias) != 0
	nPos := At(",", cAlias)
	If nPos = 0
		cRetAlias := cAlias
	Else
		cRetAlias := Subs(cAlias, 1, If(nPos !=0,nPos-1,Len(cAlias)))
	EndIf
	
	dbSelectArea("HHT")
	dbSetOrder(2)
	dbSeek(cRetAlias)
	
	If cRetAlias = "ADVTBL"
		cTable   := "ADV_TBL"
		cEmpresa := "@@"
		cRetAlias = "ADV_TBL"
	ElseIf cRetAlias = "ADVCOL"
		cTable   := "ADV_COLS"
		cEmpresa := "@@"
		cRetAlias = "ADV_COLS"
	ElseIf cRetAlias = "ADVIND"
		cTable   := "ADV_IND"
		cEmpresa := "@@"
		cRetAlias = "ADV_IND"
	Else
		dbSelectArea(cRetAlias)
		cTable   := RetSqlName(cRetAlias)
		cIDFld   := cRetAlias + "_ID"
		cCtrlFld := cRetAlias + "_INTR"
	EndIf

	If nRecs = 0
	#IFDEF TOP
		cQuery := "SELECT COUNT(*) QTDREC FROM " + cTable + Space(1) + cRetAlias
		cQuery += " WHERE "
		If HHT->HHT_GEN = "2"
			cQuery += cRetAlias + "." + cIDFld + " = '" + cUserID + "' AND "
		EndIf
		cQuery += cRetAlias + "." + cCtrlFld + " IN ('I','A','E')"
		cQuery := ChangeQuery(cQuery)

		Memowrite("PUpdHHCtr.txt", cQuery)
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QTDREC",.F.,.F.)	
		nQtdRec := QTDREC->QTDREC
		QTDREC->(dbCloseArea())
		//Verifica a versão máxima
		If HHT->HHT_GEN = "1" .And. (cRetAlias)->(FieldPos(cRetAlias+"_VER")) > 0
			cQuery := "SELECT MAX("+cRetAlias+"_VER) MAXVER FROM " + cTable + Space(1) + cRetAlias
			cQuery += " WHERE "
			cQuery += cRetAlias + "." + cCtrlFld + " IN ('I','A','E')"
			cQuery := ChangeQuery(cQuery)
	
			Memowrite("PUpdHHCtr_maxver.txt", cQuery)
		
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"MAXVER",.F.,.F.)	
			nMax_Ver := MAXVER->MAXVER
			MAXVER->(dbCloseArea())
			
		EndIf
 
	#ELSE
		cQuery := ""
		If HHT->HHT_GEN = "2"
			cQuery := "('" + cRetAlias + "')->" + cIDFld + " = '" + cUserID + "' .And. "
		EndIf
		cQuery += "('" + cRetAlias + "')->" + cCtrlFld + "$'I/A/E'"
		dbSelectArea(cRetAlias)
		(cRetAlias)->(dbGotop())
		While !Eof() 
			If &(cQuery)	
				nQtdRec ++
			EndIf
			dbSelectArea(cRetAlias)
			(cRetAlias)->(dbSkip())
		EndDo			
	#ENDIF	
	EndIf

	If nMax_Ver = 0
		nMax_Ver := 1
	EndIf
	dbSelectArea(cCtrAlias)
	dbSetOrder(3)
	If !dbSeek(cEmpresa + cUserId + Space(10-Len(cUserId)) + cTable)
		RecLock(cCtrAlias, .T.)
	Else
		RecLock(cCtrAlias, .F.)
	EndIf
	(cCtrAlias)->USERID     := cUserID
	(cCtrAlias)->TABLENAME  := cTable
	(cCtrAlias)->AMNT       := nQtdRec //If(lFirstLoad, nQtdRec, (cCtrAlias)->AMNT + nRecs)
	(cCtrAlias)->GENERIC    := If(HHT->HHT_GEN = "2", "F", "T")
	(cCtrAlias)->OPER       := "T"
	(cCtrAlias)->VERSION    := 0
	(cCtrAlias)->MAXVERSION := nMax_Ver
	(cCtrAlias)->FIELDVER   := If(Len(cRetAlias) <= 3, cRetAlias + "_VER", "VER")
	(cCtrAlias)->FIELDCTRL  := If(Len(cRetAlias) <= 3, cRetAlias + "_INTR", "INTR")
	(cCtrAlias)->EMP        := cEmpresa
	(cCtrAlias)->(MsUnlock())
    
    // Quando recriar uma tabela generica, e necessario reenviar para todos os usuarios
	If !ExistBlock("HHTRG02")
		If HHT->HHT_GEN = "1"  // Tabela Generica
			cQuery := "UPDATE HHCTR SET VERSION = 0, MAXVERSION = "+AllTrim(Str(nMax_Ver))+", AMNT ="+  Str(nQtdRec,10,0) + ", OPER = 'T' WHERE TABLENAME = '" + cTable + "'"
			TcSqlExec(cQuery)
		EndIf                
	Else
		ExecBlock("HHTRG02",.F.,.F.)
	EndIf		
	cAlias := If(nPos != 0, Subs(cAlias,nPos+1,Len(cAlias)), "")		
EndDo

If !Empty(cCurAlias)
	dbSelectArea(cCurAlias)
EndIf
Return Nil

Function GetLocalDriver()
//Local cLocalFile := ""
Local cRdd := ""
If Type("__cLocalDriver") <> "U"
	cRdd := __cLocalDriver
Else
//	cLocalFile := AllTrim(Upper(GetSrvProfString("LocalFiles","ADS")))
//	If cLocalFile = "ADS"

	// Quando a variável __cLocalDriver não existir usar sempre DBFCDX
	cRdd := "DBFCDX"   

//	ElseIf cLocalFile = "CTREE"
//		cRdd := "CTREECDX"
//	EndIf
EndIf
Return cRdd

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
#IFNDEF TOP
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
#ENDIF


Function GetIdFilial(cId)
Local aAreaGrp := {}
Local aAreaGrh := {}
Local cRet := "('
Local cIdFilial := ""
Local nPos := 0

// Nas tabelas Genericas nao ha o Id, utiliza a filial corrente
If Empty(cId)
	cRet := "('" + cFilAnt + "')"
	Return cRet
EndIf

If Select(PGALIAS) = 0
	POpenGrp()
EndIf

aAreaGrp := (PGALIAS)->(GetArea())
aAreaGrh := (PGHALIAS)->(GetArea())

dbSelectArea(PGHALIAS)
dbSetOrder(3)
If dbSeek(cId)
	While !(PGHALIAS)->(Eof()) .And. (PGHALIAS)->HGU_CODBAS = cId
		If (PGALIAS)->(dbSeek((PGHALIAS)->HGU_GRUPO))
			cIdFilial := Subs((PGALIAS)->HHG_EMPFIL,3,2)
			If !(cIdFilial $ cRet)
				cRet += cIdFilial + "','"
			EndIf
		EndIf		
		(PGHALIAS)->(dbSkip())
	EndDo
	nPos := Rat(",", cRet)
	cRet := Subs(cRet,1,nPos-1) + ")"
Else
	cRet := "('" + cFilAnt + "')"
	ConOut("PALMJOB: Vendedor " + cId + " nao cadastrado nos grupos handhelds")
EndIf
RestArea(aAreaGrp)
RestArea(aAreaGrh)
Return cRet

Function HHCheckStru(aStru)
Local nI := 0
Local aFldMob := {}
Local aFldErp := {}
Local nLenStru := Len(aStru)
Local lFldExist := .T.
Local cMsg := ""

//aadd(aDados,{"HA1_FILIAL ","A1_FILIAL"})
For nI := 1 To nLenStru
	cMsg      := ""
	lFldExist := .T.
	aFldMob   := TamSX3(aStru[nI,1])
	aFldErp   := TamSX3(aStru[nI,2])

	If Len(aFldMob) = 0
		cMsg      += "Campo Tabela Mobile:" + aStru[nI,1] + " nao encontrado. Campo Tabela ERP   :" + aStru[nI,2] + "."
		lFldExist := .F.
	EndIf

	If Len(aFldErp) = 0
		cMsg      += "Campo Tabela ERP   :" + aStru[nI,2] + " nao encontrado. Campo Tabela Mobile:" + aStru[nI,1] + "."
		lFldExist := .F.
	EndIf

	If lFldExist = .T.
		If aFldMob[1] < aFldErp[1]  // Tamanho do Campo
			cMsg += aStru[nI,1] + "(" + Str(aFldMob[1],4,0) + ") / " + aStru[nI,2] + "(" + Str(aFldErp[1],4,0) + ") - Existem diferencas de Tamanho."
		EndIf
		If aFldMob[2] < aFldErp[2]  // Decimais do Campo
			cMsg += aStru[nI,1] + "(" + Str(aFldMob[2],4,0) + ") / " + aStru[nI,2] + "(" + Str(aFldErp[2],4,0) + ") - Existem diferencas de Decimais."
		EndIf
		If aFldMob[3] != aFldErp[3]  // Tipo do Campo
			cMsg += aStru[nI,1] + "(" + Str(aFldMob[3],4,0) + ") / " + aStru[nI,2] + "(" + Str(aFldErp[3],4,0) + ") - Existem diferencas de Tipo."
		EndIf
	EndIf

	If !Empty(cMsg)	
		GravaHHLog("HHCHECKSTRU: " + cMsg  + KB_ENTER)
	EndIf
Next

Return Nil
