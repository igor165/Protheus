#INCLUDE "cfgx061A.ch"

#include "protheus.ch"
#include "dbtree.ch"
#INCLUDE "msgraphi.ch"


Function CFGX061A()
Local i
Local cSvAlias   := Alias()
Local aBtn       := Array(10)
Local cJobStatus := ""
Local oBmp
Private oDlg61

PALMDIR := HHGetDir()

//cria diretorio do palm
MakeDir(PALMDIR)
MakeDir(PALMDIR+ "\Logs\")
MakeDir(PALMDIR+ "\LOGJOB\")

// Grava Sistemas e Servicos iniciais
MsgRun(STR0001,,{ || PInitHH()}) // //"Verificando Sistemas e Servi็os padrใo."

// Cria Tabela HHTIME
MsgRun(STR0002,,{ || HHOpenTime()}) // //"Criando tabela de controle de tempo."
PALMTIME->(dbCloseArea())

// Verifica Status do PalmJob()
MsgRun(STR0003,,{ || cJobStatus := CheckPalmJob()}) // //"Verificando status do JOB."

//Reinicia array de controle de geracao de tabelas genericas
HHRstMobExp()

DEFINE MSDIALOG oDlg61 TITLE STR0004 FROM 0,0 TO 238,450 OF oMainWnd PIXEL // //"Manuten็ใo Handheld"

@00,02 TO 120,225 PIXEL OF oDlg61

@05,05 BUTTON aBtn[1] PROMPT STR0005 SIZE 35,11 PIXEL ; // //"S&istemas"
ACTION PMntSys()

@05,50 BUTTON aBtn[8] PROMPT STR0006 SIZE 35,11 PIXEL; // //"&Tabelas"
ACTION PMntTbl()

@05,95 BUTTON aBtn[2] PROMPT STR0007 SIZE 35,11 PIXEL; // //"S&ervi็os"
ACTION PMntSrv()

@05,140 BUTTON aBtn[3] PROMPT STR0008 SIZE 35,11 PIXEL; // //"&Usuแrios"
ACTION PMntHH()

@05,185 BUTTON aBtn[4] PROMPT STR0009 SIZE 35,11 PIXEL; // //"&Grupo"
ACTION PMntGrp()

@18,05 BUTTON aBtn[6] PROMPT STR0010 SIZE 35,11 PIXEL; // //"&Controle"
ACTION PShowControl()

@18,50 BUTTON aBtn[7] PROMPT STR0011 SIZE 35,11 PIXEL; // //"&Auditor"
ACTION HHAudit()

@18,95 BUTTON aBtn[8] PROMPT STR0268 SIZE 35,11 PIXEL; // //"&Wizard"
ACTION HHWizSFA()

@18,140 BUTTON aBtn[8] PROMPT STR0013 SIZE 35,11 PIXEL; // //"Atualizar"
ACTION (cJobStatus := CheckPalmJob(), oDlg61:Refresh())

@18,185 BUTTON aBtn[9] PROMPT STR0014 SIZE 35,11 PIXEL ACTION oDlg61:End() // //"&Sair"

@ 31,05 GET cJobStatus PIXEL SIZE 125,85 MULTILINE WHEN .F.

@ 31, 130 BITMAP oBmp RESNAME STR0015 oF oDlg61 SIZE 190, 173 NOBORDER WHEN .F. PIXEL // //"HANDHELD"

ACTIVATE DIALOG oDlg61 CENTERED


DbSelectArea(cSvAlias)
Return NIL

//////////////////////////////////////////////////////////////////////////////  SISTEMA //////////////////////////////////////////////////////////////////////////////
/*
Funcoes para o Cadastro de Sistemas
***********************************
* PMntSys()						  *
* tela p/ cadastro de Sistemas	  *
***********************************
/*/
Function PMntSys()
Local i
Local cSysCod := ""
Local cSvAlias := Alias()
Local oSys
Local nSys    := 1
Local aBtn    := Array(4)
Private aSys    := {{},{}}
Private oDlg

POpenSys()

//carrega Sistemas na memoria
DbSelectArea("HHS")
DbSetOrder(1)
DbGoTop()
While !Eof()
	Aadd(aSys[1],HHS->HHS_COD)
	Aadd(aSys[2],HHS->HHS_DESCR)
	DbSkip()
End

//procura pelo ultimo ID de servico e carrega servicos na memoria
DEFINE MSDIALOG oDlg TITLE STR0016 FROM 0,0 TO 218,300 PIXEL // //"Sistemas Handheld"

@01,05 SAY STR0017 PIXEL // //"Sistemas:"
@10,05 LISTBOX oSys VAR nSys ITEMS aSys[2] PIXEL SIZE 100,90
oSys:bChange := {|| oSys:Refresh()}

@10,110 BUTTON aBtn[1] PROMPT STR0018 SIZE 35,11 PIXEL ; // //"&Incluir"
ACTION (PCadSys(3,),PUpdUObj(oSys,aSys,2),nSys := 1)

@23,110 BUTTON aBtn[2] PROMPT STR0019 SIZE 35,11 PIXEL WHEN Len(aSys[1])>0 ; // //"&Alterar"
ACTION (PCadSys(4, nSys),PUpdUObj(oSys,aSys,2),nSys := 1)

@36,110 BUTTON aBtn[3] PROMPT STR0020 SIZE 35,11 PIXEL WHEN Len(aSys[1])>0 ; // //"&Excluir"
ACTION (PCadSys(5,nSys),PUpdUObj(oSys,aSys,2),nSys := 1)

@49,110 BUTTON aBtn[4] PROMPT STR0014 SIZE 35,11 PIXEL ACTION oDlg:End() // //"&Sair"

ACTIVATE DIALOG oDlg CENTERED

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf

Return

/*
*************************************************
* PCadSys(nOper, cCod)									*
* tela p/ cadastro de Sistema					*
*************************************************
*/
Function PCadSys(nOper, nSys)
Local oDlgSys
Local aInfo := {}
Local nPos := 0
Local lRet := .F.
Local cCod := If(nOper != 3, aSys[1,nSys], "")

// Posiciona Sistema
If nOper <> 3
	dbSelectArea("HHS")
	dbSetOrder(1)
	If HHS->(dbSeek(cCod))
		aAdd(aInfo,{HHS->HHS_COD,HHS->HHS_DESCR,HHS->HHS_TAB})
	EndIf
Else
	dbSelectArea("HHS")
	dbSetOrder(1)
	dbGoBottom()
	cSysCod := StrZero(Val(HHS->HHS_COD) + 1, 6)
	aAdd(aInfo,{cSysCod,Space(40),Space(3)})
EndIf

// Apaga registro do Sistema
If nOper == 5
	If MsgYesNo(STR0021 + AllTrim(HHS->HHS_DESCR) + " ?", STR0022) //### //"Deseja excluir o sistema "###"Sistema Handheld"
		RecLock("HHS", .F.)
		dbDelete()
		HHS->(MsUnlock())
		nPos := aScan(aSys[1],{|x| x == cCod})
		If nPos > 0
			aDel(aSys[1],nPos)
			aDel(aSys[2],nPos)
			aSize(aSys[1], Len(aSys[1])-1)
			aSize(aSys[2], Len(aSys[2])-1)
		EndIf
	EndIf
	Return .T.
EndIf

DEFINE MSDIALOG oDlgSys TITLE STR0023 FROM 0,0 TO 195,430 PIXEL OF oDlg // //"Cadastro de Sistemas Handheld"

@07,05 SAY STR0024 PIXEL // //"C๓digo:"
@07,50 GET aInfo[1,1] PIXEL SIZE 40,10 WHEN nOper == 3;
VALID (!Empty(aInfo[1,1]))

@22,05 SAY STR0025 PIXEL // //"Descricao:"
@22,50 GET aInfo[1,2] PIXEL SIZE 120,10

@37,05 SAY STR0026 PIXEL // //"Tabela Base:"
@37,50 GET aInfo[1,3] PIXEL SIZE 25,10

@05,180 BUTTON STR0027 SIZE 28,11 PIXEL ; // //"&OK"
ACTION If(PAddSys(nOper,aInfo),oDlgSys:End(),)

@18,180 BUTTON STR0028 SIZE 28,11 PIXEL ACTION oDlgSys:End() // //"&Cancelar"

ACTIVATE DIALOG oDlgSys CENTERED

Return lRet

/*
*******************************************
* PAddSys()						   * 
* adiciona/altera Sistema Handheld *
******************************************
*/
Function PAddSys(nOper,aInfo)
Local i
Local lRet := .F.
Local nPos

//Codigo em branco
If Empty(aInfo[1,1])
	MsgStop(STR0029,STR0030) //### //"Informe um Codigo."###"Aten็ใo"
ElseIf nOper == 3 .And. HHS->(dbSeek(aInfo[1,1]))
	MsgStop(STR0031,STR0030) //### //"Codigo jแ Existe"###"Aten็ใo"
Else
	lRet := .T.
EndIf

If lRet
	If nOper == 3
		RecLock("HHS", .T.)
	Else
		RecLock("HHS", .F.)
	EndIf
	HHS->HHS_COD   := aInfo[1,1]
	HHS->HHS_DESCR := aInfo[1,2]
	HHS->HHS_TAB   := aInfo[1,3]
	HHS->(MsUnlock())
	// Atualiza Arrays da Tela
	If nOper = 3
//		Aadd(aSysCbo,HCADSYS->HSY_COD + " - " + HCADSYS->HSY_DESCR)
		Aadd(aSys[1],HHS->HHS_COD)
		Aadd(aSys[2],HHS->HHS_DESCR)
	Else
		nPos := aScan(aSys[1],{|x| x == aInfo[1,1]})
		If nPos > 0
			aSys[1, nPos] := HHS->HHS_COD
			aSys[2, nPos] := HHS->HHS_DESCR
		EndIf
	EndIf
EndIf
HHSaveLog("",  "HHS" + HHS->HHS_COD, 2060, .T., STR0032 + Str(nOper,1,0) + ") " + HHS->HHS_COD ) // //"Manutencao Sistema("
Return lRet

//////////////////////////////////////////////////////////////////////////////  SISTEMA //////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////  TABELAS //////////////////////////////////////////////////////////////////////////////
/*
Funcoes para o Cadastro de Tabelas Handheld
*******************************************
* PMntTbl()						  *
* tela p/ cadastro de Sistemas	  *
***************8***************************
/*/
Function PMntTbl()
Local i
Local cTblCod := ""
Local cSvAlias := Alias()
Local oTbl
Local nTbl    := 1
Local aBtn    := Array(4)
Private aTbl    := {{},{}}
Private oDlg

POpenTbl()

//carrega Tabelas na memoria
DbSelectArea("HHT")
DbSetOrder(1)
DbGoTop()
While !Eof()
	Aadd(aTbl[1],HHT->HHT_COD)
	Aadd(aTbl[2],HHT->HHT_DESCR)
	DbSkip()
End

//procura pelo ultimo ID de servico e carrega servicos na memoria
DEFINE MSDIALOG oDlg TITLE STR0033 FROM 0,0 TO 218,300 PIXEL // //"Tabelas Handheld"

@01,05 SAY STR0034 PIXEL // //"Tabelas:"
@10,05 LISTBOX oTbl VAR nTbl ITEMS aTbl[2] PIXEL SIZE 100,90
oTbl:bChange := {|| oTbl:Refresh()}

@10,110 BUTTON aBtn[1] PROMPT STR0018 SIZE 35,11 PIXEL ; // //"&Incluir"
ACTION (PCadTbl(3,),PUpdUObj(oTbl,aTbl,2),nTbl := 1)

@23,110 BUTTON aBtn[2] PROMPT STR0019 SIZE 35,11 PIXEL WHEN Len(aTbl[1])>0 ; // //"&Alterar"
ACTION (PCadTbl(4, nTbl),PUpdUObj(oTbl,aTbl,2),nTbl := 1)

@36,110 BUTTON aBtn[3] PROMPT STR0020 SIZE 35,11 PIXEL WHEN Len(aTbl[1])>0 ; // //"&Excluir"
ACTION (PCadTbl(5,nTbl),PUpdUObj(oTbl,aTbl,2),nTbl := 1)

@49,110 BUTTON aBtn[4] PROMPT STR0014 SIZE 35,11 PIXEL ACTION oDlg:End() // //"&Sair"

ACTIVATE DIALOG oDlg CENTERED

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf

Return

/*
*************************************************
* PCadTbl(nOper, cCod)									*
* tela p/ cadastro de Sistema					*
*************************************************
*/
Function PCadTbl(nOper, nTbl)
Local oDlgTbl
Local aInfo    := {}
Local nPos     := 0
Local lRet     := .F.
Local cCod     := If(nOper != 3, aTbl[1,nTbl], "")
Local aGen     := {STR0035, STR0036} //### //"1-Sim"###"2-Nใo"
Local cGen     := STR0036 // //"2-Nใo"
Local lFilEmp  := .F.
Local lRetorna := .F.
Local lShare   := .F.
// Posiciona Sistema
If nOper <> 3
	dbSelectArea("HHT")
	dbSetOrder(1)
	If HHT->(dbSeek(cCod))
		aAdd(aInfo,{HHT->HHT_COD,HHT->HHT_DESCR,HHT->HHT_ALIAS,HHT->HHT_GEN,HHT->HHT_VER, HHT->HHT_TOHOST, HHT->HHT_FLDFIL, HHT->HHT_FILEMP, HHT->HHT_SHARE})
		lRetorna := If(HHT->HHT_TOHOST== "T", .T., .F.)
		lFilEmp  := If(HHT->HHT_FILEMP== "T", .T., .F.)
		lShare   := If(HHT->HHT_SHARE == "T", .T., .F.)
	EndIf
	cGen := aGen[Val(HHT->HHT_GEN)]
Else
	dbSelectArea("HHT")
	dbSetOrder(1)
	dbGoBottom()
	cTblCod := StrZero(Val(HHT->HHT_COD) + 1, 6)
	aAdd(aInfo,{cTblCod,Space(40),Space(3),"2",0,"F", "", "F", "F"})
EndIf                                                   

// Apaga registro do Sistema
If nOper == 5
	If MsgYesNo(STR0037 + AllTrim(HHT->HHT_DESCR) + " ?", STR0038) //### //"Deseja excluir a tabela "###"Tabela Handheld"
		RecLock("HHT", .F.)
		dbDelete()
		HHT->(MsUnlock())
		nPos := aScan(aTbl[1],{|x| x == cCod})
		If nPos > 0
			aDel(aTbl[1],nPos)
			aDel(aTbl[2],nPos)
			aSize(aTbl[1], Len(aTbl[1])-1)
			aSize(aTbl[2], Len(aTbl[2])-1)
		EndIf
		HHSaveLog("",  "HHT" + HHT->HHT_COD, 2040, .T., STR0039 + Str(nOper,1,0) + ") " + HHT->HHT_COD ) // //"Manutencao Tabela("
	EndIf
	Return .T.
EndIf

DEFINE MSDIALOG oDlgTbl TITLE STR0040 FROM 0,0 TO 190,470 PIXEL OF oDlg // //"Cadastro de Tabelas Handheld"

@07,05 SAY STR0024 PIXEL // //"C๓digo:"
@07,50 GET aInfo[1,1] PIXEL SIZE 40,10 WHEN nOper == 3;
VALID (!Empty(aInfo[1,1]))

@22,05 SAY STR0025 PIXEL // //"Descricao:"
@22,50 GET aInfo[1,2] PIXEL SIZE 120,10

@37,05 SAY STR0041 PIXEL // //"Alias:"
@37,50 GET aInfo[1,3] PIXEL SIZE 25,10

@37,130 CHECKBOX lRetorna PROMPT STR0042 PIXEL SIZE 80,09; //"&Retorna // //"Retorna"
ON CHANGE aInfo[1,6] := If(lRetorna, "T", "F")

@52,05 SAY STR0043 PIXEL // //"Generico:"
@52,50 COMBOBOX oCboTipo VAR cGen ITEMS aGen PIXEL SIZE 55,10;
ON CHANGE (aInfo[1,4] := Str(oCboTipo:nAt,1,0),aInfo[1,7] := If(aInfo[1,4]="1", "", aInfo[1,7]),oDlgTbl:Refresh())
     
@52,130 CHECKBOX lFilEmp PROMPT STR0044 PIXEL SIZE 80,09; //"&Filtrar Empresa // //"Filtrar Empresa"
ON CHANGE aInfo[1,8] := If(lFilEmp, "T", "F")

@67,05 SAY STR0045 PIXEL  // //"Versใo:"
@67,50 GET aInfo[1,5] PIXEL SIZE 55,10 WHEN .F.

@82,05 SAY STR0046 PIXEL // //"Campo ID:"
@82,50 GET aInfo[1,7] PIXEL SIZE 55,10 VALID ValidFldId(aInfo) WHEN aInfo[1,4] = "2"

@67,130 CHECKBOX lShare PROMPT STR0047 PIXEL SIZE 80,09; // //"Compartilhada entre empresas" //"Compartilhada entre empresas"
ON CHANGE aInfo[1,9] := If(lShare, "T", "F")

@05,180 BUTTON STR0027 SIZE 28,11 PIXEL ; // //"&OK"
ACTION If(PAddTbl(nOper,aInfo),oDlgTbl:End(),)

@18,180 BUTTON STR0028 SIZE 28,11 PIXEL ACTION oDlgTbl:End() // //"&Cancelar"

ACTIVATE DIALOG oDlgTbl CENTERED

Return lRet

Static Function ValidFldId(aInfo)
Local lRet := .T.
Local aSX3Area := SX3->(GetArea())
If aInfo[1,4] = "2"
	If !Empty(aInfo[1,7])
		SX3->(dbSetOrder(2))
		If !SX3->(dbSeek(aInfo[1,7]))
			MsgAlert(STR0048) // //"O campo ID indicado nใo estแ cadastrado no dicionแrio de dados."
			lRet := .F.
		EndIf
	Else
		MsgAlert(STR0049) // //"O campo ID deve ser preenchido para tabelas nใo gen้ricas"
		lRet := .F.
	EndIf
EndIf
RestArea(aSX3Area)
Return lRet

// Carrega Tabelas do Servi็os
Function PLoadServTbl(nOper, cCodSrv, aTbl)
Local lTbl := .F.

If HHT->(RecCount()) = 0
	MsgStop(STR0050, STR0051) //### //"Nao existe nenhuma tabela cadastrado"###"Atencao"
	Return .F.
EndIf

dbSelectArea("HHT")
dbSetorder(1)
dbGoTop()
While !HHT->(Eof())
	dbSelectArea("HST")
	dbSetorder(1)
	If nOper != 3
		If dbSeek(cCodSrv+ HHT->HHT_COD)
			lTbl := .T.
		Else
			lTbl := .F.
		EndIf	
	EndIf
	aAdd(aTbl, {lTbl, AllTrim(HHT->HHT_COD), Alltrim(HHT->HHT_DESCR), AllTrim(HHT->HHT_ALIAS)})
	HHT->(dbSkip())
EndDo

Return .T.

// Click no Table
Function TblClick(aTbl, nLin)

If aTbl[nLin, 1]
	aTbl[nLin, 1] := .F.
Else
	aTbl[nLin, 1] := .T.
Endif

Return Nil


/*
*******************************************
* PAddTbl()						   * 
* adiciona/altera Tabela Handheld *
******************************************
*/
Function PAddTbl(nOper,aInfo)
Local i
Local lRet := .F.
Local nPos

//Codigo em branco
If Empty(aInfo[1,1])
	MsgStop(STR0029,STR0030) //### //"Informe um Codigo."###"Aten็ใo"
ElseIf nOper == 3 .And. HHT->(dbSeek(aInfo[1,1]))
	MsgStop(STR0031,STR0030) //### //"Codigo jแ Existe"###"Aten็ใo"
Else
	lRet := .T.
EndIf

If lRet
	If nOper == 3
		RecLock("HHT", .T.)
	Else
		RecLock("HHT", .F.)
	EndIf
	HHT->HHT_COD    := aInfo[1,1]
	HHT->HHT_DESCR  := aInfo[1,2]
	HHT->HHT_ALIAS  := aInfo[1,3]
	HHT->HHT_GEN    := aInfo[1,4]
	HHT->HHT_VER    := aInfo[1,5]
	HHT->HHT_TOHOST := aInfo[1,6]
	HHT->HHT_FLDFIL := aInfo[1,7]
	HHT->HHT_FILEMP := aInfo[1,8]
	HHT->HHT_SHARE  := aInfo[1,9]
	HHT->(MsUnlock())

	// Atualiza Arrays da Tela
	If nOper = 3
		Aadd(aTbl[1],HHT->HHT_COD)
		Aadd(aTbl[2],HHT->HHT_DESCR)
	Else
		nPos := aScan(aTbl[1],{|x| x == aInfo[1,1]})
		If nPos > 0
			aTbl[1, nPos] := HHT->HHT_COD
			aTbl[2, nPos] := HHT->HHT_DESCR
		EndIf
	EndIf
EndIf
HHSaveLog("", "HHT" + HHT->HHT_COD, 2040, .T., STR0039 + Str(nOper,1,0) + ") " + HHT->HHT_COD ) // //"Manutencao Tabela("
Return lRet

//////////////////////////////////////////////////////////////////////////////  TABELAS //////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////  SERVICOS  //////////////////////////////////////////////////////////////////////////////
/*
Funcoes para o Cadastro de Servicos
***********************************
* PMntSrv()						  *
* tela p/ cadastro de Servicos	  *
***********************************
*/
Function PMntSrv()
Local i
Local cSvAlias  := Alias()
Local oSrv
Local nSrv      := 1
Local aBtn      := Array(4)

Private aSrv    := {{},{}}
Private oDlg
//Cria e Abre Servicos
POpenSrv()
POpenTbl()
//carrega Sistemas na memoria
DbSelectArea("HHR")
DbSetOrder(1)
DbGoTop()
While !Eof()
	Aadd(aSrv[1],HHR->HHR_COD)
	Aadd(aSrv[2],HHR->HHR_DESCR)
	DbSkip()
End

//procura pelo ultimo ID de servico e carrega servicos na memoria
DEFINE MSDIALOG oDlg TITLE STR0052 FROM 0,0 TO 218,300 PIXEL // //"Servicos Handheld"

@01,05 SAY STR0053 PIXEL // //"Servicos:"
@10,05 LISTBOX oSrv VAR nSrv ITEMS aSrv[2] PIXEL SIZE 100,90
oSrv:bChange := {|| oSrv:Refresh()}

@10,110 BUTTON aBtn[1] PROMPT STR0018 SIZE 35,11 PIXEL ; // //"&Incluir"
ACTION (PCadSrv(3,),PUpdUObj(oSrv,aSrv,2),nSrv := 1)

@23,110 BUTTON aBtn[2] PROMPT STR0019 SIZE 35,11 PIXEL WHEN Len(aSrv[1])>0 ; // //"&Alterar"
ACTION (PCadSrv(4, nSrv),PUpdUObj(oSrv,aSrv,2),nSrv := 1)

@36,110 BUTTON aBtn[3] PROMPT STR0020 SIZE 35,11 PIXEL WHEN Len(aSrv[1])>0 ; // //"&Excluir"
ACTION (PCadSrv(5,nSrv),PUpdUObj(oSrv,aSrv,2),nSrv := 1)

@49,110 BUTTON aBtn[4] PROMPT STR0014 SIZE 35,11 PIXEL ACTION oDlg:End() // //"&Sair"

ACTIVATE DIALOG oDlg CENTERED
If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf

Return

/*
*****************************************
* PCadSrv(nOper, nSrv)					*
* tela p/ cadastro de Servicos			*
*****************************************
/*/
Function PCadSrv(nOper, nSrv)
Local oDlgSrv
Local aInfo   := {}
Local aTbl    := {}
Local aTitles := {}
Local nPos    := 0
Local lRet    := .F.
Local cSrvCod := ""
Local cCod    := If(nOper != 3, aSrv[1,nSrv], "")
Local aTipo   := {STR0054, STR0055} //### //"1 - Handheld->Protheus"###"2 - Protheus->Handheld"
Local aExec   := {STR0056, STR0057} //### //"1 - Individual"###"2 - Generico"
Local cTipo   := ""
Local cExec   := ""
Local oOk     := LoadBitmap( GetResources(), "LBOK" )
Local oNo     := LoadBitmap( GetResources(), "LBNO" )
Local oCboTipo
Local oCboExec
Local oCboRetD

// Carrega Servi็os
If !PLoadServTbl(nOper, cCod, @aTbl)
	Return Nil
EndIf

// Posiciona Sistema
If nOper <> 3
	dbSelectArea("HHR")
	dbSetOrder(1)
	If HHR->(dbSeek(cCod))
		aAdd(aInfo,{HHR->HHR_COD,HHR->HHR_DESCR,HHR->HHR_FUNCAO,HHR->HHR_ALIAS, HHR->HHR_ARQ, HHR->HHR_TIPO,HHR->HHR_EXEC})

		//Atualiza os Combos
		cTipo := aTipo[Val(HHR->HHR_TIPO)]
		cExec := aExec[Val(HHR->HHR_EXEC)]
	EndIf
Else
	dbSelectArea("HHR")
	dbSetOrder(1)
	dbGoBottom()
	cSrvCod := StrZero(Val(HHR->HHR_COD) + 1, 6)
	aAdd(aInfo,{cSrvCod,Space(40),Space(15),Space(100),"","1", "1"})
EndIf

// Apaga registro de Servico
If nOper == 5
	If MsgYesNo(STR0058 + AllTrim(HHR->HHR_DESCR) + " ?",STR0052) //### //"Deseja excluir o servico "###"Servicos Handheld"
		RecLock("HHR", .F.)
		dbDelete()
		HHR->(MsUnlock())
		nPos := aScan(aSrv[1],{|x| x == cCod})
		If nPos > 0
			aDel(aSrv[1],nPos)
			aDel(aSrv[2],nPos)
			aSize(aSrv[1], Len(aSrv[1])-1)
			aSize(aSrv[2], Len(aSrv[2])-1)
		EndIf
	EndIf
	Return .T.
EndIf

aAdd(aTitles, STR0059) // //"Tabelas"
nTables := 1

DEFINE MSDIALOG oDlgSrv TITLE STR0060 FROM 0,0 TO 390,470 PIXEL OF oDlg // //"Cadastro de Servi็os Handheld"

@07,05 SAY STR0024 PIXEL // //"C๓digo:"
@07,50 GET aInfo[1,1] PIXEL SIZE 40,10 WHEN nOper == 3;
VALID (!Empty(aInfo[1,1]))

@22,05 SAY STR0025 PIXEL // //"Descricao:"
@22,50 GET aInfo[1,2] PIXEL SIZE 139,10

@37,05 SAY STR0061 PIXEL // //"Funcao:"
@37,50 GET aInfo[1,3] PIXEL SIZE 139,10

@52,05 SAY STR0041 PIXEL // //"Alias:"
@52,50 GET aInfo[1,4] PIXEL SIZE 139,10

@67,05 SAY STR0062 PIXEL // //"Tipo:"
@67,50 COMBOBOX oCboTipo VAR cTipo ITEMS aTipo PIXEL SIZE 55,10;
ON CHANGE aInfo[1,6] := Str(oCboTipo:nAt,1,0)

@ 82,05 FOLDER oFolder SIZE 225,110 OF oDlgSrv PROMPTS aTitles[1] PIXEL

@ .2,.2 LISTBOX oLbTbl FIELDS HEADER "", STR0063, STR0064,STR0065; //###### //"Codigo"###"Tabela"###"Alias"
COLSIZES 10,30,30,30;
SIZE 219,95 OF oFolder:aDialogs[nTables] ;
ON DBLCLICK (TblClick(@aTbl, oLbTbl:nAt), oLbTbl:Refresh())

oLbTbl:SetArray(aTbl)
oLbTbl:bLine   := { || {If(aTbl[oLbTbl:nAt,1],oOk,oNo), aTbl[oLbTbl:nAt,2], aTbl[oLbTbl:nAt,3], aTbl[oLbTbl:nAt,4]}}

@05,202 BUTTON STR0027 SIZE 28,11 PIXEL ; // //"&OK"
ACTION If(PAddSrv(nOper,aInfo,aTbl),oDlgSrv:End(),)

@18,202 BUTTON STR0028 SIZE 28,11 PIXEL ACTION oDlgSrv:End() // //"&Cancelar"

ACTIVATE DIALOG oDlgSrv CENTERED

Return lRet

/*
************************************
* PAddSrv()						   * 
* adiciona/altera Sistema Handheld *
************************************
*/
Function PAddSrv(nOper,aInfo,aTbl)
Local ni
Local lRet := .F.
Local nPos

//Codigo em branco
If Empty(aInfo[1,1])
	MsgStop(STR0029,STR0030) //### //"Informe um Codigo."###"Aten็ใo"
ElseIf nOper == 3 .And. HHR->(dbSeek(aInfo[1,1]))
	MsgStop(STR0066,STR0030) //### //"Servico ja Existe"###"Aten็ใo"
ElseIf Empty(aInfo[1,3])
	MsgStop(STR0067,STR0030) //### //"Informe uma Funcao."###"Aten็ใo"
ElseIf !FindFunction(aInfo[1,3])
	MsgStop(STR0068,STR0030) //### //"Funcao nao Encontrada no Repositorio."###"Aten็ใo"
Else
	lRet := .T.
EndIf

For ni := 1 To Len(aTbl)
	If aTbl[ni,1]
		aInfo[1,5] += aTbl[ni,4] + ","
	EndIf	
Next
aInfo[1,5] := Subs(aInfo[1,5],1,Len(aInfo[1,5])-1)

If lRet
	If nOper == 3
		RecLock("HHR", .T.)
	Else
		RecLock("HHR", .F.)
	EndIf
	HHR->HHR_COD    := aInfo[1,1]
	HHR->HHR_DESCR  := aInfo[1,2]
	HHR->HHR_FUNCAO := aInfo[1,3]
	HHR->HHR_ALIAS  := aInfo[1,4]	
	HHR->HHR_ARQ    := aInfo[1,5]
	HHR->HHR_TIPO   := aInfo[1,6]
	HHR->HHR_EXEC   := aInfo[1,7]
	HHR->(MsUnlock())

	// Atualiza Arrays da Tela
	If nOper = 3
		Aadd(aSrv[1],HHR->HHR_COD)
		Aadd(aSrv[2],HHR->HHR_DESCR)
	Else
		nPos := aScan(aSrv[1],{|x| x == aInfo[1,1]})
		If nPos > 0
			aSrv[1,nPos] := HHR->HHR_COD
			aSrv[2,nPos] := HHR->HHR_DESCR
		EndIf
	EndIf
	PSaveServTbl(aInfo, aTbl)
EndIf
HHSaveLog("", "HHR"+HHR->HHR_COD , 2070, .T., STR0069 + Str(nOper,1,0) + ") " + HHR->HHR_COD ) // //"Manutencao Servico("
Return lRet

Function PSaveServTbl(aInfo, aTbl)
Local ni := 1

dbSelectArea("HST")
dbSetOrder(1)
For ni := 1 To Len(aTbl)
	If HST->(dbSeek(aInfo[1,1] + aTbl[ni, 2]))
		RecLock("HST", .F.)
		If aTbl[ni, 1]
			HHT->(dbSetOrder(1))
			HHT->(dbSeek(aTbl[ni, 2]))
			HST->HST_CODSRV := aInfo[1,1]
			HST->HST_CODTBL := HHT->HHT_COD
		Else
			HST->(dbDelete())
		EndIf			
		HST->(MsUnlock())		
	Else
		If aTbl[ni, 1]
			HHT->(dbSetOrder(1))
			HHT->(dbSeek(aTbl[ni, 2]))
			RecLock("HST", .T.)
			HST->HST_CODSRV := aInfo[1,1]
			HST->HST_CODTBL := HHT->HHT_COD
			HST->(MsUnlock())		
		EndIf
	EndIf
Next

Return Nil


//////////////////////////////////////////////////////////////////////////////  SERVIวOS //////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////  HANDHELD //////////////////////////////////////////////////////////////////////////////
/*
Funcoes para o Cadastro de Handhelds
***********************************
* PMntHH()						  *
* tela p/ cadastro de handhelds	  *
***********************************
*/
Function PMntHH()
Local i
Local oHH
Local nHH      := 1
Local cSvAlias := Alias()
Local aBtn     := Array(4)

Private oDlg
Private aHH    := {{},{}}

POpenHH()
POpenGrp()
POpenTbl()
//Carrega Usuarios na memoria
DbSelectArea("HHU")
DbSetOrder(1)
DbGoTop()
While !Eof()
	Aadd(aHH[1],HHU->HHU_SERIE)
	Aadd(aHH[2],HHU->HHU_NOMUSR)
	DbSkip()
End

//procura pelo ultimo ID de servico e carrega servicos na memoria
DEFINE MSDIALOG oDlg TITLE STR0070 FROM 0,0 TO 218,300 PIXEL // //"Cadastro de Handheld"

@01,05 SAY STR0071 PIXEL // //"Usuarios:"
@10,05 LISTBOX oHH VAR nHH ITEMS aHH[2] PIXEL SIZE 100,90
oHH:bChange := {|| oHH:Refresh()}

@10,110 BUTTON aBtn[1] PROMPT STR0018 SIZE 35,11 PIXEL ; // //"&Incluir"
ACTION (PCadHH(3,),PUpdUObj(oHH,aHH,2),nHH := 1)

@23,110 BUTTON aBtn[2] PROMPT STR0019 SIZE 35,11 PIXEL WHEN Len(aHH[1])>0 ; // //"&Alterar"
ACTION (PCadHH(4, nHH),PUpdUObj(oHH,aHH,2),nHH := 1)

@36,110 BUTTON aBtn[3] PROMPT STR0020 SIZE 35,11 PIXEL WHEN Len(aHH[1])>0 ; // //"&Excluir"
ACTION (PCadHH(5,nHH),PUpdUObj(oHH,aHH,2),nHH := 1)

@49,110 BUTTON aBtn[4] PROMPT STR0014 SIZE 35,11 PIXEL ACTION oDlg:End() // //"&Sair"

ACTIVATE DIALOG oDlg CENTERED
If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return

/*
*****************************************
* PCadHH(nOper, nHH)					*
* tela p/ cadastro de Handhelds 		*
*****************************************
*/
Function PCadHH(nOper, nHH)
Local oDlgHH
Local aInfo   := {}
Local nPos    := 0
Local lRet    := .F.
Local cCod    := If(nOper != 3, aHH[1,nHH], "")
Local aDevice := {STR0072, STR0073, STR0074} //###### //"1 - Palm OS"###"2 - Pocket PC/ARM"###"3 - Pocket PC/SH3"
Local cDevice := ""
Local cDelGrupo := ""
Local oCboDevice

// Posiciona Sistema
If nOper <> 3
	dbSelectArea("HHU")
	dbSetOrder(1)
	If HHU->(dbSeek(cCod))
		aAdd(aInfo,{HHU->HHU_SERIE,HHU->HHU_NOMUSR,HHU->HHU_CODUSR,HHU->HHU_DEVICE})
		cDevice := aDevice[Val(HHU->HHU_DEVICE)]
	EndIf
Else
	aAdd(aInfo,{Space(15),Space(40),Space(6),"1"})
EndIf

// Apaga registro do Sistema
If nOper == 5
	If MsgYesNo(STR0075 + AllTrim(HHU->HHU_NOMUSR) + " ?",STR0015) //### //"Estแ oprera็ใo exclui o usuแrio e todos os seus cadastros nos grupos de Handheld. Confirma exclusใo do handheld "###"HANDHELD"
		HHSaveLog("",  HHU->HHU_SERIE, 2030, .T., STR0076 + Str(nOper,1,0) + ") " + HHU->HHU_SERIE ) // //"Manutencao Handheld("
		RecLock("HHU", .F.)
		dbDelete()
		HHU->(MsUnlock())
		nPos := aScan(aHH[1],{|x| x == cCod})
		If nPos > 0
			aDel(aHH[1],nPos)
			aDel(aHH[2],nPos)
			aSize(aHH[1], Len(aHH[1])-1)
			aSize(aHH[2], Len(aHH[2])-1)
		EndIf
		// Apaga referencias do Usuario no Grupo
		dbSelectArea("HGU")
		dbSetOrder(2)
		If dbSeek(HHU->HHU_SERIE)
			While !HGU->(Eof()) .And. AllTrim(HHU->HHU_SERIE) = AllTrim(HGU->HGU_SERIE)
				// Apaga base do Usuario
				HHRecreateUser(HGU->HGU_GRUPO, HGU->HGU_SERIE, .F.)

				RecLock("HGU", .F.)
				dbDelete()
				HGU->(MsUnlock())
				cDelGrupo += HGU->HGU_GRUPO+"/"			
		
				HGU->(dbSkip())
			EndDo
		EndIf
	EndIf
	Return .T.
EndIf

DEFINE MSDIALOG oDlgHH TITLE STR0077 FROM 0,0 TO 160,470 PIXEL OF oDlg // //"Cadastro de Handhelds"

@07,05 SAY STR0078 PIXEL // //"Numero de Serie:"
@07,50 GET aInfo[1,1] PIXEL SIZE 60,10 WHEN nOper == 3;
//VALID (!Empty(aInfo[1,1]))

@22,05 SAY STR0079 PIXEL // //"Nome Usuแrio:"
@22,50 GET aInfo[1,2] PIXEL SIZE 139,10

@37,05 SAY STR0080 PIXEL // //"C๓digo Usuแrio:"
@37,50 MSGET aInfo[1,3] PIXEL F3 "USR"

@52,05 SAY STR0081 PIXEL // //"Dispositivo:"
@52,50 COMBOBOX oCboDevice VAR cDevice ITEMS aDevice PIXEL SIZE 55,10;
ON CHANGE aInfo[1,4] := Str(oCboDevice:nAt,1,0)

@05,202 BUTTON STR0027 SIZE 28,11 PIXEL ; // //"&OK"
ACTION If(PAddHH(nOper,aInfo),oDlgHH:End(),) 

@18,202 BUTTON STR0028 SIZE 28,11 PIXEL ACTION oDlgHH:End() // //"&Cancelar"

ACTIVATE DIALOG oDlgHH CENTERED

Return lRet

/*
************************************
* PAddHH()						   * 
* adiciona/altera Sistema Handheld *
************************************
*/
Function PAddHH(nOper,aInfo)
Local i
Local lRet := .F.
Local nPos

//Codigo em branco
If Empty(aInfo[1,1])
	MsgStop(STR0082,STR0030) //### //"Informe um Numero de Serie."###"Aten็ใo"
ElseIf nOper == 3 .And. HHU->(dbSeek(aInfo[1,1]))
	MsgStop(STR0083,STR0030) //### //"Handheld ja Existe"###"Aten็ใo"
Else
	lRet := .T.
EndIf

If lRet
	If nOper == 3
		RecLock("HHU", .T.)
	Else
		RecLock("HHU", .F.)
	EndIf
	HHU->HHU_SERIE  := aInfo[1,1]
	HHU->HHU_NOMUSR := aInfo[1,2]
	HHU->HHU_CODUSR := aInfo[1,3]
	HHU->HHU_DEVICE := aInfo[1,4]
	HHU->(MsUnlock())
	// Atualiza Arrays da Tela
	If nOper = 3
		Aadd(aHH[1], HHU->HHU_SERIE)
		Aadd(aHH[2], HHU->HHU_NOMUSR)
	Else
		nPos := aScan(aHH[1],{|x| x == aInfo[1,1]})
		If nPos > 0
			aHH[1,nPos] := HHU->HHU_SERIE
			aHH[2,nPos] := HHU->HHU_NOMUSR
		EndIf
	EndIf
EndIf
HHSaveLog("",  HHU->HHU_SERIE, 2030, .T., STR0076 + Str(nOper,1,0) + ") " + HHU->HHU_SERIE ) // //"Manutencao Handheld("
Return lRet

//////////////////////////////////////////////////////////////////////////////  HANDHELD //////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////  GRUPO //////////////////////////////////////////////////////////////////////////////
/*
Funcoes para o Cadastro de Grupos
***********************************
* PMntGrp()						  *
* tela p/ cadastro de Grupos	  *
***********************************
*/
Function PMntGrp()
Local i
Local cSvAlias := Alias()
Local oGrp
Local nGrp  := 1
Local aBtn := Array(6)

Private aGrp    := {{},{}}
Private oDlg

POpenGrp()
POpenHH()
POpenSrv()
POpenSys()
POpenTbl()

//carrega Sistemas na memoria
DbSelectArea("HHG")
DbSetOrder(1)
DbGoTop()
While !Eof()
	Aadd(aGrp[1],HHG->HHG_COD)
	Aadd(aGrp[2],HHG->HHG_DESCR)
	DbSkip()
End

//procura pelo ultimo ID de servico e carrega servicos na memoria
DEFINE MSDIALOG oDlg TITLE STR0084 FROM 0,0 TO 218,300 PIXEL // //"Cadastro de Grupos de Handheld"

@01,05 SAY STR0085 PIXEL // //"Grupos:"
@10,05 LISTBOX oGrp VAR nGrp ITEMS aGrp[2] PIXEL SIZE 100,90
oGrp:bChange := {|| oGrp:Refresh()}

@10,110 BUTTON aBtn[1] PROMPT STR0018 SIZE 35,11 PIXEL ; // //"&Incluir"
ACTION (PCadGrp(3,),PUpdUObj(oGrp,aGrp,2))

@23,110 BUTTON aBtn[2] PROMPT STR0019 SIZE 35,11 PIXEL WHEN Len(aGrp[1])>0; // //"&Alterar"
ACTION (PCadGrp(4, nGrp),PUpdUObj(oGrp,aGrp,2))

@36,110 BUTTON aBtn[3] PROMPT STR0020 SIZE 35,11 PIXEL WHEN Len(aGrp[1])>0; // //"&Excluir"
ACTION (PCadGrp(5,nGrp),PUpdUObj(oGrp,aGrp,2))

@49,110 BUTTON aBtn[4] PROMPT STR0014 SIZE 35,11 PIXEL ACTION oDlg:End() // //"&Sair"

ACTIVATE DIALOG oDlg CENTERED
If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
EndIf
Return

/*
*****************************************
* PCadGrp(nOper, nGrp)					*
* tela p/ cadastro de Handhelds 		*
*****************************************
/*/
Function PCadGrp(nOper, nGrp)
Local oDlgGrp
Local oFolder
Local oEmp
Local oSys
Local oLbServ
Local oBtnAll
Local oBtnInv
Local oBtnApl
Local oLbHH
Local oOk      := LoadBitmap( GetResources(), "LBOK" )
Local oNo      := LoadBitmap( GetResources(), "LBNO" )
Local aInfo := {}
Local aEmp
Local aSys
Local aTitles   := {}
Local aServ := {}
Local aHH   := {}
Local nControl  := 0
Local nServico  := 0
Local nHandheld := 0
Local nPos := 0
Local cEmp := ""
Local cSys := ""
Local lRet := .F.
Local cCod := ""
Local cGrpCod := ""
Local cFreq    := ""
Local cTFreqCbo:= 1
Local cTFreq   := "1"
Local aTFreq   := {STR0086, STR0087, STR0088} //###### //"1 - Minutos"###"2 - Horas"###"3 - Dias"
Local lSufixo := GetMV("MV_HHSUFIX",,"N") = "S"
Local nHHOrd := 2 // Ordem Padrao dos usuarios
Local lSaved := .T.
If nOper != 3
	If nGrp = 0 .Or. nGrp > Len(aGrp[1])
		MsgStop(STR0089) // //"Selecione um grupo."
		Return Nil
	Else
		cCod := aGrp[1,nGrp]
	EndIf	
EndIf

// Carrega Servi็os
If !PLoadServGrp(nOper, cCod, @aServ)
	Return Nil
EndIf

//Carrega Handhelds
If !PLoadHHGrp(nOper, cCod, @aHH)
	Return Nil
EndIf

// Carrega Empresas/Filiais (aEmp)
If aEmp == NIL
	aEmp := {}
	DbSelectArea("SM0")
	nRecSav := Recno()
	DbGoTop()
	While ( !Eof() )
		Aadd(aEmp,M0_CODIGO+M0_CODFIL)
		DbSkip()
	End
	DbGoTo(nRecSav)
EndIf

// Carrega Dados do Grupo na altera็ใo
If nOper <> 3
	dbSelectArea("HHG")
	dbSetOrder(1)
	If HHG->(dbSeek(cCod))
		aAdd(aInfo,{HHG->HHG_COD,HHG->HHG_DESCR,HHG->HHG_SYS,HHG->HHG_EMPFIL,HHG->HHG_FREQ,HHG->HHG_TFREQ,HHG->HHG_SCRIPT, HHG->HHG_SUFIXO})
		DbSelectArea("HHS")
		dbSetOrder(1)
		If dbSeek(	HHG->HHG_SYS)
			cSys := HHS->HHS_DESCR
		EndIf	
		cEmp := HHG->HHG_EMPFIL
		cTFreqCbo := aTFreq[Val(HHG->HHG_TFREQ)]
	EndIf
Else
	dbSelectArea("HHG")
	dbSetOrder(1)
	dbGoBottom()
	cGrpCod := StrZero(Val(HHG->HHG_COD) + 1, 6)
	cEmp := aEmp[1]
	aAdd(aInfo,{cGrpCod,Space(40),Space(6),cEmp,0,"1",Space(30), "0"})
EndIf

// Carrega Sistemas
PLoadSys(@aSys, aInfo)

// Apaga registro de Grupo
If nOper == 5
	If MsgYesNo(STR0090) // //"Confima exclusใo do grupo ?"
		
		// Apaga Relacionamento Usuario x Grupo
		dbSelectArea("HGU")
		dbSetOrder(1)
		If dbSeek(cCod)
			While !HGU->(Eof()) .And. HGU->HGU_GRUPO = cCod
				RecLock("HGU", .F.)
				dbDelete()
				HGU->(MsUnlock())
				HGU->(dbSkip())
			EndDo
		EndIf
		
		// Apaga Relacionamento Servico x Grupo
		dbSelectArea("HGS")
		dbSetOrder(1)
		If dbSeek(cCod)
			While !HGS->(Eof()) .And. HGS->HGS_GRUPO = cCod
				RecLock("HGS", .F.)
				dbDelete()
				HGS->(MsUnlock())
				HGS->(dbSkip())
			EndDo
		EndIf
		
		RecLock("HHG", .F.)
		dbDelete()
		HHG->(MsUnlock())
		nPos := aScan(aGrp[1],{|x| x == cCod})
		If nPos > 0
			aDel(aGrp[1],nPos)
			aDel(aGrp[2],nPos)
			aSize(aGrp[1], Len(aGrp[1])-1)
			aSize(aGrp[2], Len(aGrp[2])-1)
		EndIf
	EndIf
	HHSaveLog(HHG->HHG_COD,  HHU->HHU_SERIE, 2050, .T., STR0091 + Str(nOper,1,0) + ") " + HHG->HHG_COD ) // //"Manutencao Grupo("
	Return .T.
EndIf

// Cria Titulos dos Folders
aAdd(aTitles, STR0092) // //"Servicos"
nControl++
nServico := nControl

aAdd(aTitles, STR0015) // //"HANDHELD"
nControl++
nHandHeld := nControl

DEFINE MSDIALOG oDlgGrp TITLE STR0093 FROM 0,0 TO 440,470 PIXEL OF oDlg // //"Cadastro de Grupos"

@07,05 SAY STR0094 PIXEL // //"Codigo:"
@07,50 GET aInfo[1,1] PIXEL SIZE 60,10 WHEN nOper == 3;
VALID (!Empty(aInfo[1,1]));
ON CHANGE lSaved := .F.

@22,05 SAY STR0095 PIXEL // //"Descri็ao:"
@22,50 GET aInfo[1,2] PIXEL SIZE 140,10;
ON CHANGE lSaved := .F.

@37,05 SAY STR0096 PIXEL // //"Sistema:"
@37,50 COMBOBOX oSys VAR cSys ITEMS aSys[2] PIXEL SIZE 140,10;
ON CHANGE (aInfo[1,3] := aSys[1,oSys:nAt],lSaved := .F.)

@52,05 SAY STR0097 PIXEL // //"Empresa/Filial:"
@52,50 COMBOBOX oEmp VAR cEmp ITEMS aEmp PIXEL SIZE 30,10;
ON CHANGE (aInfo[1,4] := cEmp,lSaved := .F.)

@ 52,90  SAY STR0098 SIZE 45,07 OF oDlgGrp PIXEL // //"Frequ๊ncia:"
@ 52,120 GET aInfo[1,5] Picture "999" SIZE 20, 10 OF oDlgGrp PIXEL;
ON CHANGE lSaved := .F.

@ 52,145 COMBOBOX oTFreq VAR cTFreqCbo ITEMS aTFreq SIZE 45, 10 OF oDlgGrp PIXEL;
ON CHANGE  (aInfo[1,6] := Subs(cTFreqCbo,1,1),lSaved := .F.)

@67,05 SAY STR0099 PIXEL // //"Script:"
@67,50 GET aInfo[1,7] PIXEL SIZE 70,10;
ON CHANGE lSaved := .F.

If lSufixo
	@67,125 SAY STR0100 PIXEL // //"Sufixo:"
	@67,145 GET aInfo[1,8] PIXEL SIZE 40,10;
	ON CHANGE lSaved := .F.
EndIf

@ 80,05 FOLDER oFolder SIZE 225,125 OF oDlgGrp PROMPTS aTitles[1],aTitles[2] PIXEL
oFolder:bSetOption:={|nAtu| If(nAtu==2,(HHOrd(oLbHH, nHHOrd, @nHHOrd),oBtnAll:Hide(),oBtnInv:Hide()),(oBtnAll:Show(),oBtnInv:Show()) ) }

@ .2,.2 LISTBOX oLbServ FIELDS HEADER "", STR0101,STR0102; //### //"Servi็o"###"Descricao"
COLSIZES 15,30,100;
SIZE 219,108 OF oFolder:aDialogs[nServico] ;
ON DBLCLICK (ServClick(@aServ, oLbServ:nAt), oLbServ:Refresh(),lSaved := .F.,oBtnApl:lActive:=.T.)

oLbServ:SetArray(aServ)
oLbServ:bLine   := { || {If(aServ[oLbServ:nAt,1],oOk,oNo), aServ[oLbServ:nAt,2], aServ[oLbServ:nAt,3]}}

@ .2,.2 LISTBOX oLbHH FIELDS HEADER "",STR0103,STR0104, STR0105; //###### //"No Serie"###"Nome"###"C๓digo"
COLSIZES 15,50,50,15;
SIZE 219,108 OF oFolder:aDialogs[nHandHeld] ;
ON DBLCLICK (HHClick(@aHH, oLbHH:nAt, aInfo[1,3]),oLbHH:Refresh(),lSaved := .F.,oBtnApl:lActive:=.T.)

oLbHH:SetArray(aHH)
oLbHH:bLine   := { || {If(aHH[oLbHH:nAt,1],oOk,oNo), aHH[oLbHH:nAt,2], aHH[oLbHH:nAt,3], aHH[oLbHH:nAt,4]}}
bBlockHead := &("{|oBrw,nCol| HHOrd(oBrw,nCol, @nHHOrd),oBrw:SetFocus(),oBrw:Refresh()}")
oLbHH:bHeaderClick:= bBlockHead

@ 208,005	BUTTON oBtnAll PROMPT STR0264		 SIZE 40,11 PIXEL ACTION(MarcaTodos(@aServ),oLbServ:Refresh(),lSaved := .F.) //"Marca Todos"
@ 208,048	BUTTON oBtnInv PROMPT STR0265 SIZE 45,11 PIXEL ACTION(Inv_Selecao(@aServ),oLbServ:Refresh(),lSaved := .F.) //"Inverter Sele็ใo"
@ 208,200	BUTTON oBtnApl PROMPT STR0266			 SIZE 30,11 OF oDlgGrp PIXEL ACTION( IIf(PAddGrp(nOper,aInfo, aServ, aHH,lSaved),(lSaved := .T.,nOper := 4),) ) When !lSaved //"Aplicar"

@05,202 BUTTON STR0027 SIZE 28,11 PIXEL ; // //"&OK"
ACTION If(PAddGrp(nOper,aInfo, aServ, aHH,lSaved), oDlgGrp:End(),)

@18,202 BUTTON STR0028 SIZE 28,11 PIXEL ACTION oDlgGrp:End() // //"&Cancelar"

@36,202 BUTTON STR0106 SIZE 28,11 PIXEL ACTION HHRecreateUser(aInfo[1,1], aHH[oLbHH:nAt,2]) // //"&Rec. Base"

@49,202 BUTTON STR0107 SIZE 28,11 PIXEL ACTION Processa( { || HHRecrAll(aInfo[1,1])}, STR0108, STR0109,.F.) //###### //"Rec. &Todos"###"Aguarde..."###"Recriando a base para todos os vendedores."

@62,202 BUTTON STR0110 SIZE 28,11 PIXEL ACTION HHInitImport(aInfo[1,1], aHH[oLbHH:nAt,2]) // //"&Importa็ใo"

@75,202 BUTTON STR0111 SIZE 28,11 PIXEL ACTION HHShowScript(aInfo) // //"&Visualizar"

ACTIVATE DIALOG oDlgGrp CENTERED

Return lRet

Static Function HHOrd(oBrw, nCol, nHHOrd)
Local aHHTmp   := oBrw:aArray
Local nHeaders := Len(oBrw:aHeaders)
Local cRes     := ""
Local ni		   := 1
aSort(aHHTmp,,,{|x,y| x[nCol]<y[nCol]})
For ni := 1 To nHeaders
	cRes := If(nCol == ni,"COLDOWN","COLRIGHT")
	oBrw:SetHeaderImage(ni,cRes)
Next
nHHOrd := nCol
Return Nil

// Carrega Sistemas (aSys)
Function PLoadSys(aSys, aInfo)
Local nRecSav := 0

If aSys == NIL
	aSys := {{},{}}
	DbSelectArea("HHS")
	dbSetOrder(1)
	If HHS->(RecCount()) = 0
		MsgStop(STR0112, STR0051) //### //"Nao existe nenhum sistema cadastrado"###"Atencao"
		Return .T.
	EndIf
	nRecSav := Recno()
	DbGoTop()
	While ( !Eof() )
		Aadd(aSys[1],HHS->HHS_COD)
		Aadd(aSys[2],HHS->HHS_DESCR)
		DbSkip()
	End
	cSys := aSys[2,1]
	aInfo[1,3]:= aSys[1,1]
	DbGoTo(nRecSav)
EndIf
Return Nil

// Carrega Servi็os do Grupo
Function PLoadServGrp(nOper, cCodGrp, aServ)
Local lServ := .F.

If HHR->(RecCount()) = 0
	MsgStop(STR0113, STR0051) //### //"Nao existe nenhum servi็o cadastrado"###"Atencao"
	Return .F.
EndIf

dbSelectArea("HHR")
dbSetorder(1)
dbGoTop()
While !HHR->(Eof())
	dbSelectArea("HGS")
	dbSetorder(1)
	If nOper != 3
		If dbSeek(cCodGrp+ HHR->HHR_COD)
			lServ := .T.
		Else
			lServ := .F.
		EndIf	
	EndIf
	aAdd(aServ, {lServ, HHR->HHR_COD, HHR->HHR_DESCR})
	HHR->(dbSkip())
EndDo

Return .T.

// Carrega Handhelds do Grupo
Function PLoadHHGrp(nOper, cCodGrp, aHH)
Local lHH := .F.
Local cCodBas := ""
Local aStatus := {{STR0114,STR0115,STR0116,STR0117,STR0118, STR0119}, {"L", "J","H","P","B","E"}} //############### //"1-Livre"###"2-Job"###"3-Handheld"###"4-Processando"###"5-Bloqueado"###"6-Sinc. Parcial"
Local nStatus := 0

If HHU->(RecCount()) = 0
	MsgStop(STR0120, STR0051) //### //"Nao existe nenhum handheld cadastrado"###"Atencao"
	Return .F.
EndIf

dbSelectArea("HHU")
dbSetorder(1)
dbGoTop()
While !HHU->(Eof())
	dbSelectArea("HGU")
	If nOper >= 3 .And. nOper < 6
		dbSetOrder(1)
		If HGU->(dbSeek(cCodGrp + HHU->HHU_SERIE))
			lHH := .T.
			cCodBas := HGU->HGU_CODBAS
		Else
			lHH := .F.
			cCodBas := ""
		EndIf
		// Utilizado nas Opcoes de cadastro
		aAdd(aHH, {lHH, HHU->HHU_SERIE, HHU->HHU_NOMUSR, cCodBas})
	ElseIf nOper = 6
		dbSetOrder(2)
		If HGU->(dbSeek(HHU->HHU_SERIE))
			nStatus := aScan(aStatus[2], {|x| x == HHU->HHU_LOCK})
			If nStatus = 0
				nStatus := 1
			EndIf
			cStatus := aStatus[1, nStatus]
			// Utilizado na Opcao de Controle
			aAdd(aHH, {HGU->HGU_GRUPO, HHU->HHU_SERIE, HHU->HHU_NOMUSR, HGU->HGU_CODBAS, cStatus, HHU->HHU_LOCK})
		EndIf
	EndIf
	HHU->(dbSkip())
EndDo	
Return .T.

// Click no Handheld
Function HHClick(aHH, nLin, cSys)
Local oDlgHH
Local cVend := Space(6)

If aHH[nLin, 1]
	aHH[nLin, 1] := .F.
Else
	HHS->(dbSetOrder(1))
	HHS->(dbSeek(cSys))
	DEFINE MSDIALOG oDlgHH TITLE STR0077 FROM 0,0 TO 85,200 PIXEL OF oDlg // //"Cadastro de Handhelds"
	
	@07,07 SAY STR0121 PIXEL // //"C๓digo Base:"
	@07,56 MSGET cVend PIXEL F3 HHS->HHS_TAB
	
	@25,15 BUTTON STR0027 SIZE 28,11 PIXEL ; // //"&OK"
	ACTION (aHH[nLin,4] := cVend,aHH[nLin, 1] := .T.,oDlgHH:End()) 
	
	@25,60 BUTTON STR0028 SIZE 28,11 PIXEL ACTION oDlgHH:End() // //"&Cancelar"
	
	ACTIVATE DIALOG oDlgHH CENTERED	
	
Endif

Return Nil

// Click no Servi็o
Function ServClick(aServ, nLin)

If aServ[nLin, 1]
	aServ[nLin, 1] := .F.
Else
	aServ[nLin, 1] := .T.
Endif

Return Nil

/*/
*************************************************
* PUpdUObj()									*
* atualiza objetos da tela principal			*
*************************************************
/*/
Static Function PUpdUObj(o1,aArray,nPos)
If ( o1 <> NIL )
	o1:SetItems(aArray[nPos])
	o1:nAt := aScan(aArray, aArray[nPos])
	o1:Refresh()
EndIf

Return .T.

/*/
************************************
* PAddGrp()						   * 
* adiciona/altera Sistema Handheld *
************************************
/*/
Function PAddGrp(nOper,aInfo, aServ, aHH,lSaved)
Local i
Local lRet := .F.
Local nPos
Local cLastDir := ""

If lSaved
	Return .T.
EndIf

//Codigo em branco
If Empty(aInfo[1,1])
	MsgStop(STR0029,STR0030) //### //"Informe um Codigo."###"Aten็ใo"
ElseIf Empty(aInfo[1,2])
	MsgStop(STR0267,STR0030) //"###"Aten็ใo" //"Informe a Descri็ใo"
ElseIf nOper == 3 .And. HHG->(dbSeek(aInfo[1,1]))
	MsgStop(STR0122,STR0030) //### //"Grupo ja Existe"###"Aten็ใo"
Else
	lRet := .T.
EndIf

If lRet
	If nOper == 3
		RecLock("HHG", .T.)
	Else
		RecLock("HHG", .F.)
	EndIf
	HHG->HHG_COD    := aInfo[1,1]
	HHG->HHG_DESCR  := aInfo[1,2]
	HHG->HHG_SYS    := aInfo[1,3]
	HHG->HHG_EMPFIL := aInfo[1,4]
	HHG->HHG_FREQ   := aInfo[1,5]
	HHG->HHG_TFREQ  := aInfo[1,6]
	HHG->HHG_SCRIPT  := aInfo[1,7]
	HHG->HHG_SUFIXO := aInfo[1,8]
	HHG->(MsUnlock())
	// Atualiza Arrays da Tela
	If nOper = 3
		Aadd(aGrp[1],HHG->HHG_COD)
		Aadd(aGrp[2],HHG->HHG_DESCR)
	Else
		nPos := aScan(aGrp[1],{|x| x == aInfo[1,1]})
		If nPos > 0
			aGrp[1,nPos] := HHG->HHG_COD
			aGrp[2,nPos] := HHG->HHG_DESCR
		EndIf
	EndIf
EndIf

PSaveServGrp(aInfo, aServ)
PSaveHHGrp(aInfo, aHH)

HHSaveLog(HHG->HHG_COD,  HHU->HHU_SERIE, 2050, .T., STR0091 + Str(nOper,1,0) + ") " + HHG->HHG_COD ) // //"Manutencao Grupo("
Return lRet

// Grava Servicos dos Grupo
Function PSaveServGrp(aInfo, aServ)
Local ni := 1

dbSelectArea("HGS")
dbSetOrder(1)
For ni := 1 To Len(aServ)
	If HGS->(dbSeek(aInfo[1,1] + aServ[ni, 2]))
		RecLock("HGS", .F.)
		If aServ[ni, 1]
			HHR->(dbSetOrder(1))
			HHR->(dbSeek(aServ[ni, 2]))
			HGS->HGS_GRUPO := aInfo[1,1]
			HGS->HGS_SRV   := HHR->HHR_COD
			HGS->HGS_TIPO  := HHR->HHR_TIPO
//			HGS->HGS_FREQ  := cFreq
//			HGS->HGS_TFREQ := cTFreq			
		Else
			HGS->(dbDelete())
		EndIf			
		HGS->(MsUnlock())		
	Else
		If aServ[ni, 1]
			HHR->(dbSetOrder(1))
			HHR->(dbSeek(aServ[ni, 2]))
			RecLock("HGS", .T.)
			HGS->HGS_GRUPO := aInfo[1,1]
			HGS->HGS_SRV   := HHR->HHR_COD
			HGS->HGS_TIPO  := HHR->HHR_TIPO
//			HGS->HGS_FREQ  := cFreq
//			HGS->HGS_TFREQ := cTFreq			
			HGS->(MsUnlock())		
		EndIf
	EndIf
Next

Return Nil

// Grava Handhelds dos Grupo
Function PSaveHHGrp(aInfo, aHH)
Local ni := 0

dbSelectArea("HGU")
dbSetOrder(1)
For ni := 1 To Len(aHH)
	If HGU->(dbSeek(aInfo[1,1] + aHH[ni, 2]))
		RecLock("HGU", .F.)
		If aHH[ni, 1]
			dbSelectArea("HHU")
			dbSetOrder(1)
			dbSeek(aHH[ni, 2])	
			HGU->HGU_GRUPO :=  aInfo[1,1]
			HGU->HGU_SERIE := aHH[ni,2]
			HGU->HGU_CODBAS:= aHH[ni,4]
			//HGU->(MsUnlock())
		Else
			HGU->(dbDelete())
		EndIf			
		HGU->(MsUnlock())		
	Else
		If aHH[ni, 1]
			dbSelectArea("HGU")
			dbGoBottom()
			cLastDir := HGU->HGU_DIR
			cLastDir := Soma1(cLastDir)
			RecLock("HGU", .T.)
			HGU->HGU_GRUPO :=  aInfo[1,1]
			HGU->HGU_SERIE := aHH[ni,2]
			If !Empty(cLastDir)
				HGU->HGU_DIR   := cLastDir
			EndIf
			HGU->HGU_CODBAS:= aHH[ni,4]
			HGU->(MsUnlock())
		EndIf
	EndIf
Next

Return Nil

Function HHRecreateUser(cGrupo, cSerie, linit, lPerg, lWaitExec)
Local cId          := ""
Local nWork        := Val(GetSrvProfString("HandHeldWorks","3"))
Local __nInterval  := VAL(GetSrvProfString("HHThreadTimer","5000"))
Local cHandHeldDir := GetHHDir()
Local cFileLock    := Subs(cHandHeldDir,2,Len(cHandHeldDir)-2)
Local nHdl         := 0
Local cMsg         := ""
Local cTableName   := ""
Local cEmpresa     := cEmpAnt
Local cFilDel	    := ""
Local lDelHC5X	    := SuperGetMv("MV_DELHC5X",,.T.) // Indica se os registros devem ser deletados do HC5/HC6 quando encontrado com status X (apos serem importados)
Local lUpdHHTime	 := GetMv("MV_HHUPDTM",,"T") == "T"

DEFAULT lInit		:=	.T.
DEFAULT lPerg		:=	.T.
DEFAULT lWaitExec	:=	.F.

dbSelectArea("HGU")
dbSetOrder(1)
If dbSeek(cGrupo + cSerie)
	cId := HGU->HGU_CODBAS
Else
	MsgAlert(STR0123) // //"Handheld nใo relacionado a um c๓digo base. Favor verificar cadastros de Grupo x Handheld"
	Return Nil	
EndIf

If lInit
	If lPerg
		cMsg += STR0124 + cId + STR0125 + AllTrim(cSerie) + ". " //### //"Esta altera็ใo implica na exclusใo da base de dados do usuแrio "###", Numero de Serie "
		cMsg += STR0126 + Chr(13) + Chr(10) // //"Caso existam informa็๕es nใo importadas para o Protheus estas serใo perdidas."
		cMsg += STR0127 // //"Deseja continuar ?"
	
		If !MsgNoYes(cMsg, STR0128) // //"Excluir Base"
			Return Nil
		EndIf
	EndIf			
	HHSaveLog(cGrupo, cSerie, 2060, .T.,)
EndIf

dbSelectArea("HHT")
dbSetOrder(1)
While !HHT->(Eof())
	If HHT->HHT_ALIAS = "ADVTBL"
		cTableName := "ADV_TBL"
		cEmpresa   := "@@"
	ElseIf HHT->HHT_ALIAS = "ADVCOL"
		cTableName := "ADV_COLS"
		cEmpresa   := "@@"
	ElseIf HHT->HHT_ALIAS = "ADVIND"
		cTableName := "ADV_IND"
		cEmpresa   := "@@"
	Else
		cTableName := RetSqlName(HHT->HHT_ALIAS)
		cEmpresa   := cEmpAnt
	EndIf
	If MsFile(cTableName,,__cRdd)
		cAliasDel := "HHCTR"

		If HHT->HHT_GEN = "2" // Nao Generica
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Verifica a filial a ser deletada		                     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cFilDel := xFilial(Alltrim(HHT->HHT_ALIAS))
			If !Empty(cFilDel) // Se a tabela for Exclusiva, deve deletar os dados da filial do grupo posicionado
				cFilDel := Subs(HHG->HHG_EMPFIL,3,2)
			EndIf
			
			cQuery	:= "DELETE FROM " + cTableName + " WHERE " + AllTrim(HHT->HHT_ALIAS) + "_ID = '" + cId + "'"
			cQuery	+= " AND " + AllTrim(HHT->HHT_ALIAS) + "_FILIAL = '" + cFilDel + "'"
			If HHT->HHT_FILEMP = "T"
				cQuery += " AND " + AllTrim(HHT->HHT_ALIAS) + "_EMP = '" + cEmpresa + "'"
			EndIf
			
			cQuery += " AND " + AllTrim(HHT->HHT_ALIAS) + "_INTR <> 'N'"
			If ("HC5"$cTableName .or. "HC6"$cTableName) .And. !lDelHC5X
				cQuery += " AND " + AllTrim(HHT->HHT_ALIAS) + "_INTR <> 'X'"
			EndIf
			TCSqlExec(cQuery)
		EndIf
		// Query para excluir dados da HHCTR
		cQuery := "DELETE FROM " + cAliasDel + " WHERE USERID = '" + cId + "' AND TABLENAME = '" + cTableName + "'"
		cQuery += " AND EMP = '" + cEmpresa + "'"
		TCSqlExec(cQuery)
	EndIf
	HHT->(dbSkip())
EndDo

// Inicia Job para usuario que excluiu base
If linit
	HHSaveLog(cGrupo, cSerie, 2060, .F.,STR0206 + cSerie) //"Base do usuario apagada - " 
	dbSelectArea("HHU")
	dbSetOrder(1)
	If dbSeek(cSerie)
		RecLock("HHU",.F.)
		HHU_LOCK    := "J"
		HHU->(MsUnlock())
		While nHdl <= 0
			nWork++
			nHdl := MSFCREATE("\SEMAFORO\" + cFileLock + "WK" + StrZero(nWork,3,0)+".LCK")	
		EndDo
		FClose(nHdl)
		StartJob("HHExecServ",GetEnvServer(),lWaitExec,cGrupo, cSerie, nWork, .T., lUpdHHTime)
		Sleep(__nInterval)
	EndIf
EndIf
Return Nil


Function HHInitImport(cGrupo, cSerie, linit)
Local cId          := ""
Local nWork        := Val(GetSrvProfString("HandHeldWorks","3"))
Local cHandHeldDir := GetHHDir()
Local cFileLock    := Subs(cHandHeldDir,2,Len(cHandHeldDir)-2)
Local nHdl         := 0
Local cMsg         := ""

DEFAULT lInit := .T.

dbSelectArea("HGU")
dbSetOrder(1)
If dbSeek(cGrupo + cSerie)
	cId := HGU->HGU_CODBAS
	dbSelectArea("HHU")
	dbSetOrder(1)
	If dbSeek(cSerie)
		If !Empty(HHU->HHU_LOCK)
			MsgAlert(STR0129 + cId + STR0130 + HHU->HHU_LOCK + STR0131) //###### //"Usuario "###" estแ com o status "###". A importa็ใo nใo pode ser iniciada."
			Return Nil
		EndIf
	EndIf
EndIf

If lInit
	cMsg += STR0132 + cId + STR0125 + AllTrim(cSerie) + ". " //### //"Esta rotina executa os servi็os de Importa็ใo (Handheld -> Protheus) para o usuแrio  "###", Numero de Serie "
	cMsg += STR0127 // //"Deseja continuar ?"

	If !MsgNoYes(cMsg, STR0133) // //"Iniciar Importa็๕es"
		Return Nil
	EndIf	
	HHSaveLog(cGrupo, cSerie, 2090, .T.,STR0134 + cSerie) // //"Importacao iniciada para "
EndIf

// Inicia Job para usuario executando importacoes
If linit
	dbSelectArea("HHU")
	dbSetOrder(1)
	If dbSeek(cSerie)
		RecLock("HHU",.F.)
		HHU_LOCK    := "P"
		HHU->(MsUnlock())
		While nHdl <= 0
			nWork++
			nHdl := MSFCREATE("\SEMAFORO\" + cFileLock + "WK" + StrZero(nWork,3,0)+".LCK")	
		EndDo
		FClose(nHdl)
		StartJob("HHUpdData", GetEnvServer(), .F., cGrupo, cSerie)
	EndIf
EndIf
Return Nil

//////////////////////////////////////////////////////////////////////////////  CONTROLE //////////////////////////////////////////////////////////////////////////////
Function PShowControl()
Local oDlgCtr, oFolder, oLstHH, oLstLog, oLstCon, oLstTRG, oLstStat, oBtnStat, oBtnClose
Local oBtnExpr, oCboErr, oSayErr, oSayOrd, oGetFilter
Local aTitles    := {}
Local cHDir      := GetSrvProfString("HHTrgDir","\HHTRG\") + "\LOGS\"
Local aHH        := {}
Local aLogs      := Directory(cHDir + "*.LOG")
Local aCon       := {}
Local aEmpTrg    := {}
Local nControl   := 0
Local nLog       := 0
Local nHandheld  := 0
Local nConex     := 0
Local nStat      := 0
Local nTrg       := 0
Local cCargo     := ""
Local cValue     := ""
Local lGraph     := .T.
Local ni         := 1
Local nQtdSeries := 0
Local oOk        := LoadBitmap( GetResources(), "LBOK" )
Local oNo        := LoadBitmap( GetResources(), "LBNO" )
Local aErrCode := {}
Local cErrCode := {}
Local aOrdem := {}
Local nOrdem := 1
Local aObj := {}
Local cFilter := ""
Private aStat     := {}

// Abre tabela de Handhelds
POpenHH()
POpenGrp()
POpenTbl()
HHOpenTrg()
HHOpenLog()

For nI := 1 To HHL->(DBOrderInfo(9))
	aAdd(aOrdem, HHL->(IndexKey(nI)))
Next
cOrdem := aOrdem[1]

//Carrega Handhelds
If !PLoadHHGrp(6, "", @aHH)
	Return Nil
EndIf

//Carregar Conexoes
MsgRun(STR0135,,{ || PLoadCon(@aCon, nOrdem)}) // //"Carregando Logs...."

// C๓digos de Erro do arquivo - HHLOG
aAdd(aErrCode, "0001 - HHOPEN")
aAdd(aErrCode, "0002 - HHCLOSE")
aAdd(aErrCode, STR0136) // //"0003 - Erro na Autenticacao do Usuario"
aAdd(aErrCode, STR0137) // //"1010 - Sucesso na Importa็ใo do Pedido"
aAdd(aErrCode, STR0138) // //"1011 - Erro na Importa็ใo do Pedido"
aAdd(aErrCode, STR0139) // //"1020 - Sucesso na Importa็ใo de Cliente (Inclusao)"
aAdd(aErrCode, STR0140) // //"1021 - Sucesso na Importa็ใo de Cliente (Alteracao)"
aAdd(aErrCode, STR0141) // //"1022 - Erro na Importa็ใo de Cliente"
aAdd(aErrCode, STR0142) // //"1030 - Sucesso na Importa็ใo de Contatos (Inclusao)"
aAdd(aErrCode, STR0143) // //"1031 - Sucesso na Importa็ใo de Contatos (Alteracao)"
aAdd(aErrCode, STR0144) // //"1032 - Erro na Importa็ใo de Contatos"
aAdd(aErrCode, STR0145) // //"1040 - Sucesso na Importa็ใo de Mensagem"
aAdd(aErrCode, STR0146) // //"1041 - Erro na Importa็ใo de Mensagem"
aAdd(aErrCode, STR0147) // //"1050 - Sucesso na Importa็ใo de Ocorrencias"
aAdd(aErrCode, STR0148) // //"1051 - Erro na Importa็ใo de Ocorrencia"
aAdd(aErrCode, STR0149) // //"2010 - Manutencao de Sistemas"
aAdd(aErrCode, STR0150) // //"2020 - Manutencao de Servicos"
aAdd(aErrCode, STR0151) // //"2030 - Manutencao de Usuarios"
aAdd(aErrCode, STR0152) // //"2040 - Manutencao de Tabelas"
aAdd(aErrCode, STR0153) // //"2050 - Manutencao de Grupos"
aAdd(aErrCode, STR0154) // //"2060 - Apaga base de usuario"
aAdd(aErrCode, STR0155) // //"2070 - Criacao da base do usuario"
aAdd(aErrCode, STR0156) // //"2080 - Altera็ใo de Status do Usuario"
aAdd(aErrCode, STR0157) // //"2090 - Iniciado importa็๕es manualmente"
aAdd(aErrCode, "0500 - RPC")

//Carregar Gatilhos
If !PLoadEmpTrg(@aEmpTrg)
	Return Nil
EndIf

// Limpa Array das Estatisiticas
ResetStats(aStat)

// Cria Titulos dos Folders
aAdd(aTitles, STR0015) // //"HANDHELD"
nControl++
nHandHeld := nControl

aAdd(aTitles, STR0158) // //"Conex๕es"
nControl++
nConex := nControl

aAdd(aTitles, STR0159) // //"Logs"
nControl++
nLog := nControl

aAdd(aTitles, STR0160) // //"Gatilhos"
nControl++
nTrg := nControl

aAdd(aTitles, STR0161) // //"Estatisticas"
nControl++
nStat := nControl

DEFINE MSDIALOG oDlgCtr TITLE STR0162 FROM 0,0 TO 600,760 PIXEL OF oDlg61 // //"Controle Handheld"

/// Montagem do Folder
oFolder:=TFolder():New( 01,01,aTitles,,oDlgCtr,,,,.T.,.T.,380,271)
oFolder:bSetOption := { |nAtu| ActCtrFld(nAtu, oSayOrd, oSayErr, oCboErr, oCboOrd, oGetFilter, oBtnExpr)}

// Combo da Ordem de Exibicao 
@275,01 SAY oSayOrd PROMPT STR0163 PIXEL // //"Ordem:"
@275,55 COMBOBOX oCboOrd VAR cOrdem ITEMS aOrdem PIXEL SIZE 150,11;
ON CHANGE (nOrdem := oCboOrd:nAt, HHLChangeOrd(nOrdem, aCon, oLstCon))
oSayOrd:Hide()
oCboOrd:Hide()

// Botao para Construcao do Filtro
@ 275,210 BUTTON oBtnExpr PROMPT STR0164 SIZE 28,11 PIXEL OF oDlgCtr; // //"Filtro"
ACTION HHLFilter(@aCon, oDlgCtr, oLstCon, @cFilter, nOrdem)
oBtnExpr:Hide()

// Get com o Filtro Atual
@ 275,245 GET oGetFilter VAR cFilter SIZE 130,09 PIXEL OF oDlgCtr WHEN .F.
oGetFilter:Hide()

// Combo dos Codigo de Operacao - Apenas Visual
@290,01 SAY oSayErr PROMPT STR0165 PIXEL // //"C๓digo de Opera็ใo:"
@290,55 COMBOBOX oCboErr VAR cErrCode ITEMS aErrCode PIXEL SIZE 150,10
oSayErr:Hide()
oCboErr:Hide()

// Botao para Fechar Janela
@ 290,350 BUTTON oBtnClose PROMPT STR0166 SIZE 28,11 PIXEL OF oDlgCtr ACTION oDlgCtr:End() // //"&Fechar"

// HANDHELDS
@ .2,.2 LISTBOX oLstHH FIELDS;
					    HEADER STR0167,STR0168, STR0104,STR0169,STR0170; //############ //"Grupo"###"Numero de Serie"###"Nome"###"Cod. Base"###"Status"
					    COLSIZES 40,70,70,40,30;
SIZE 375,255 OF oFolder:aDialogs[nHandHeld];
ON DBLCLICK (HHControl(aHH, oLstHH:nAt), oLstHH:Refresh())

oLstHH:SetArray(aHH)
If Len(aHH) > 0
	oLstHH:bLine := { || {aHH[oLstHH:nAt,1], aHH[oLstHH:nAt,2], aHH[oLstHH:nAt,3], aHH[oLstHH:nAt,4],aHH[oLstHH:nAt,5]}}
EndIf

// CONEXOES
@ .2,.2 LISTBOX oLstCon FIELDS;
					    HEADER STR0167,STR0168, STR0171, STR0172, STR0173, ; //############ //"Grupo"###"Numero de Serie"###"Ordem"###"Data"###"Hora 1"
					       	   STR0174, STR0175, STR0176, STR0177; //######### //"Operacao 1"###"Hora 2"###"Operacao 2"###"Observacao"
					    COLSIZES 30,60,20,30,30,33,30,33,100;
SIZE 375,255 OF oFolder:aDialogs[nConex]
oLstCon:SetArray(aCon)
If Len(aCon) > 0
	oLstCon:bLine := { || {aCon[oLstCon:nAt,1], aCon[oLstCon:nAt,2], aCon[oLstCon:nAt,3], aCon[oLstCon:nAt,4], aCon[oLstCon:nAt,5],;
					      aCon[oLstCon:nAt,6], aCon[oLstCon:nAt,7], aCon[oLstCon:nAt,8], aCon[oLstCon:nAt,9]}}
EndIf

// LOGS
@ .2,.2 LISTBOX oLstLogs FIELDS;
					    HEADER STR0178, STR0172, STR0179; //###### //"Arquivo"###"Data"###"Hora"
					    COLSIZES 100, 50, 50;
SIZE 375,255 OF oFolder:aDialogs[nLog];
ON DBLCLICK (ShowMemo(cHDir+aLogs[oLstLogs:nAt,1]), oLstHH:Refresh())
oLstLogs:SetArray(aLogs)
If Len(aLogs) > 0
	oLstLogs:bLine   := { || {aLogs[oLstLogs:nAt,1], aLogs[oLstLogs:nAt,3], aLogs[oLstLogs:nAt,4]}}
EndIf

// GATILHOS
@ .2,.2 LISTBOX oLstTRG FIELDS;
					    HEADER "",STR0180, STR0181,STR0182, STR0065, STR0064; //############ //"Empresa"###"Filial"###"Nome da Empresa"###"Alias"###"Tabela"
					    COLSIZES 10,30,30,100;
SIZE 375,255 OF oFolder:aDialogs[nTrg];
ON DBLCLICK (cEmpFil := aEmpTrg[oLstTRG:nAt,2] + aEmpTrg[oLstTRG:nAt,3], ;
			 		   HHCtrTriggerOn(aEmpTrg[oLstTRG:nAt,2], aEmpTrg[oLstTRG:nAt,3], aEmpTrg[oLstTRG:nAt,5], !aEmpTrg[oLstTRG:nAt,1]), ;
			 		   aEmpTrg[oLstTRG:nAt,1] := !aEmpTrg[oLstTRG:nAt,1],;
			 		   oLstTRG:Refresh())
oLstTRG:SetArray(aEmpTrg)
If Len(aEmpTrg) > 0			 		   
	oLstTRG:bLine   := { || {If(aEmpTrg[oLstTRG:nAt,1],oOk,oNo), aEmpTrg[oLstTRG:nAt,2], aEmpTrg[oLstTRG:nAt,3], aEmpTrg[oLstTRG:nAt,4], aEmpTrg[oLstTRG:nAt,5], aEmpTrg[oLstTRG:nAt,6]}}
EndIf

// Carrega Estatisticas
CheckStats(aCon, @aStat)

// Check que habilita a atualizacao do grafico
@ .3, 205 CHECKBOX lGraph PROMPT STR0183 PIXEL OF oFolder:aDialogs[nStat] SIZE 80,09; //"&Retorna // //"Atualiza Grแfico"

// Montagem do TREE
DEFINE DBTREE oTree FROM  2,1 TO 257,200 CARGO OF oFolder:aDialogs[nStat];
ON CHANGE (cCargo := oTree:GetCargo(), HHUpdGraph(oGraphic, aStat, cCargo, @nQtdSeries))

For ni := 1 To Len(aStat)
	If aStat[ni, 1] = "--"
		DBENDTREE oTree
	Else
		cValue := PadR(aStat[ni, 2] + If(Len(aStat[ni, 1])>2, " = " + Str(aStat[ni, 3], 6,0),""),40)
		DBADDTREE oTree PROMPT cValue;
		RESOURCE "FOLDER5","FOLDER5" CARGO aStat[ni, 1]
	EndIf
Next

// Montagem do Grafico
@ 008, 205 MSGRAPHIC oGraphic SIZE 170, 163 OF oFolder:aDialogs[nStat] TYPE BAR PIXEL
oGraphic:l3D := .F.
oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRP_SERIES, .F.)

// Botao que atualiza o grแfico
@ 245, 205 BUTTON oBtnStat PROMPT STR0013 SIZE 35,11 PIXEL OF oFolder:aDialogs[nStat] ; // //"Atualizar"
ACTION (ResetStats(aStat),CheckStats(aCon, @aStat),oTree:Refresh())

ACTIVATE DIALOG oDlgCtr CENTERED

Return Nil

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// ActCtrFld - Fun็ใo utilizada no click dos folders
////	nAtu - Indice do folder clicado
////	oSayOrd, oSayErr, oCboErr, oCboOrd, oGetFilter, oBtnExpr - Obejtos do Folder de Conexoes
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function ActCtrFld(nAtu, oSayOrd, oSayErr, oCboErr, oCboOrd, oGetFilter, oBtnExpr)
If nAtu = 2  // Folder Conex๕es
	oSayErr:Show()
	oSayOrd:Show()
	oCboErr:Show()
	oCboOrd:Show()
	oGetFilter:Show()
	oBtnExpr:Show()
Else
	oSayErr:Hide()
	oSayOrd:Hide()
	oCboErr:Hide()
	oCboOrd:Hide()
	oGetFilter:Hide()
	oBtnExpr:Hide()
EndIf
Return Nil

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// HHLFilter - Fun็ใo utilizada para criar filtros
////	aCon - Array de conexoes
////	oDlg - Objeto de janela
///	oLstCon - Listbox das conex๕es
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function HHLFilter(aCon, oDlg, oLstCon, cFilter, nOrdem)
Local aCampo := {}

// Monta campos a Serem utilizados na BuildExp
// X3_CAMPO,X3Titulo(),If(!x3Uso(X3_USADO),.f.,.t.),X3_ORDEM,X3_TAMANHO,Trim(X3_PICTURE),X3_TIPO,X3_DECIMAL}
aAdd(aCampo, {"HHL_GRUPO", STR0167, .T., 1, 6, "999999", "C",0}) // //"Grupo"
aAdd(aCampo, {"HHL_SERIE", STR0184, .T., 2, 20, "", "C",0}) // //"Num. S้rie"
aAdd(aCampo, {"HHL_DATA", STR0172, .T., 3, 8, "", "D",0}) // //"Data"
aAdd(aCampo, {"HHL_OPER1", STR0185, .T., 1, 4, "9999", "C",0}) // //"Opera็ใo"

// BuildExpr(cAlias, oWnd, cFilter, lTopFilter, bOk, oDlg, aUsado, cDesc, nRow, nCol, aCampo )
cFilter := BuildExpr("HHL", oDlg,,,,,,,,,aCampo)

Set Filter To &cFilter

PLoadCon(@aCon, nOrdem)
oLstCon:SetArray(aCon)
oLstCon:bLine := { || {aCon[oLstCon:nAt,1], aCon[oLstCon:nAt,2], aCon[oLstCon:nAt,3], aCon[oLstCon:nAt,4], aCon[oLstCon:nAt,5],;
					      aCon[oLstCon:nAt,6], aCon[oLstCon:nAt,7], aCon[oLstCon:nAt,8], aCon[oLstCon:nAt,9]}}

Return Nil

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// HHLChangeOrd - Fun็ใo utilizada para alterar a ordem de exibi็ใo
////	nOrdem - Nova Ordem a ser utilizada
////	aCon - Array de conexoes
///	oLstCon - Listbox das conex๕es
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function HHLChangeOrd(nOrdem, aCon, oLstCon)
PLoadCon(@aCon, nOrdem)
oLstCon:SetArray(aCon)
oLstCon:bLine := { || {aCon[oLstCon:nAt,1], aCon[oLstCon:nAt,2], aCon[oLstCon:nAt,3], aCon[oLstCon:nAt,4], aCon[oLstCon:nAt,5],;
					      aCon[oLstCon:nAt,6], aCon[oLstCon:nAt,7], aCon[oLstCon:nAt,8], aCon[oLstCon:nAt,9]}}
oLstCon:Refresh()
Return Nil

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// HHLChangeOrd - Fun็ใo utilizada para carregar logs (arquivo HHLOG)
////	aCon - Array de conexoes
////	nOrdem - Nova Ordem a ser utilizada
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function PLoadCon(aCon, nOrdem)
aCon := {}
dbSelectArea("HHL")
dbSetorder(nOrdem)
dbGoTop()
While !HHL->(Eof())
	aAdd(aCon, {HHL->HHL_GRUPO, HHL->HHL_SERIE, HHL->HHL_SEQ, HHL->HHL_DATA, HHL->HHL_HORA1, HHL->HHL_OPER1, HHL->HHL_HORA2, HHL->HHL_OPER2, HHL->HHL_OBS})
	HHL->(dbSkip())
EndDo	
Return .T.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// ResetStats - Reinializa o array das estatisticas
////	aStat - Array de estatisticas
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ResetStats(aStat)
aStat := {}
aAdd(aStat, {"00", STR0186, 0, ""}) // //"Estatistica"
aAdd(aStat, {"10", STR0158, 0, ""}) // //"Conex๕es"
aAdd(aStat, {"1010", STR0187, 0, ""}) // //"Total"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"1020", STR0188, 0, ""}) // //"Completas"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"1030", STR0189, 0, ""}) // //"Incompletas"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"20", STR0190, 0, ""}) // //"Importa็๕es"
aAdd(aStat, {"2010", STR0191, 0, ""}) // //"Pedidos"
aAdd(aStat, {"201001", STR0192, 0, "1010"}) // //"Com Sucesso"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"201002", STR0193, 0, "1011"}) // //"Com Erro"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"2020", STR0194, 0, ""}) // //"Ocorrencias"
aAdd(aStat, {"202001", STR0192, 0, ""}) // //"Com Sucesso"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"202002", STR0193, 0, ""}) // //"Com Erro"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"2030", STR0195, 0, ""}) // //"Clientes"
aAdd(aStat, {"203001", STR0192, 0, ""}) // //"Com Sucesso"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"203002", STR0193, 0, ""}) // //"Com Erro"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"2040", STR0196, 0, ""}) // //"Contatos"
aAdd(aStat, {"204001", STR0192, 0, ""}) // //"Com Sucesso"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"204002", STR0193, 0, ""}) // //"Com Erro"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"2050", STR0197, 0, ""}) // //"Mensagens"
aAdd(aStat, {"205001", STR0192, 0, ""}) // //"Com Sucesso"
aAdd(aStat, {"--", "", 0, ""})
aAdd(aStat, {"205002", STR0193, 0, ""}) // //"Com Erro"

If ExistBlock("HHSTAT01")
	ExecBlock("HHSTAT01", .F., .F.)
EndIf

Return Nil

// Carrega Empresas cadastradas nos Grupos
Function PLoadEmpTrg(aEmpTrg)
Local nEmpRec := SM0->(Recno())
Local lActive := .F.
Local cEmp    := ""
Local cFil    := ""
Local nStatusTrg := Val(GetSrvProfString("HHTriggerOn","0"))

dbSelectArea("HHG")
dbSetorder(1)
dbGoTop()
While !HHG->(Eof())
	cEmp := Subs(HHG->HHG_EMPFIL,1,2) 
	cFil := Subs(HHG->HHG_EMPFIL,3,2)

	// Sempre executa os triggers Ou  Verifica o Trigger por Empresa / Filial Ou Verifica o Trigger por Empresa / Filial / Alias
	If nStatusTrg = 1 .Or.  nStatusTrg = 4 
		// Posiciona a Empresa
		SM0->(dbSeek(cEmp + cFil))

		// Verifica Empresa no arquivo de Gatilho
		dbSelectArea("HHTRG")
		dbSetOrder(1)
		If !dbSeek(cEmp + cFil)
			HHG->(dbSkip())
			Loop
		EndIf

		// Verifica o gatilho para todas a filiais e alias
		While !HHTRG->(Eof()) .And. HHTRG->HTR_EMP = cEmp .And. HHTRG->HTR_FIL = cFil
			lActive := If(HHTRG->HTR_TRG = "X", .T., .F.)
			aAdd(aEmpTrg, {lActive, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, HHTRG->HTR_ALIAS, HHTRG->HTR_TABLE})
			HHTRG->(dbSkip())
		EndDo
	ElseIf  nStatusTrg = 2   // Verifica o Trigger por Empresa
		// Posiciona a Empresa
		SM0->(dbSeek(cEmp))

		// Verifica Empresa no arquivo de Gatilho
		dbSelectArea("HHTRG")
		dbSetOrder(1)
		If dbSeek(cEmp) .And. HHTRG->HTR_TRG = "X"
			lActive :=  .T.
		Else
			lActive :=  .F.
		EndIf
		aAdd(aEmpTrg, {lActive, SM0->M0_CODIGO, "", SM0->M0_NOME, "", ""})
		
	ElseIf nStatusTrg = 3
		// Posiciona a Empresa
		SM0->(dbSeek(cEmp + cFil))

		// Verifica Empresa no arquivo de Gatilho
		dbSelectArea("HHTRG")
		dbSetOrder(1)
		If dbSeek(cEmp + cFil) .And. HHTRG->HTR_TRG = "X"
			lActive :=  .T.
		Else
			lActive := .F.
		EndIf
		aAdd(aEmpTrg, {lActive, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, "", ""})
	EndIf
	HHG->(dbSkip())
EndDo	
SM0->(dbGoTo(nEmpRec))
Return .T.

Function HHCtrTriggerOn(cEmp, cFil, cAlias, lStatus)
Local nStatusTrg := Val(GetSrvProfString("HHTriggerOn","0"))
Local bWhile := { || } 
Local cTrgKey := "" 

// Sempre executa os triggers Ou  Verifica o Trigger por Empresa / Filial
If nStatusTrg = 1 .Or.  nStatusTrg = 3
	bWhile :=	{|| ( !HHTRG->(Eof()) .And. HHTRG->HTR_EMP = cEmp .And. HHTRG->HTR_FIL = cFil)}
	cTrgKey := cEmp + cFil
ElseIf  nStatusTrg = 2   // Verifica o Trigger por Empresa
	bWhile :=	{|| ( !HHTRG->(Eof()) .And. HHTRG->HTR_EMP = cEmp)}
	cTrgKey := cEmp
ElseIf  nStatusTrg = 4 // Verifica o Trigger por Empresa / Filial / Alias
	bWhile :=	{|| ( !HHTRG->(Eof()) .And. HHTRG->HTR_EMP = cEmp .And. HHTRG->HTR_FIL = cFil .And. HHTRG->HTR_ALIAS = cAlias)}
	cTrgKey := cEmp + cFil + cAlias
EndIf

// Verifica o gatilho para todas a filiais e alias
dbSelectArea("HHTRG")
dbSetorder(1)
If dbSeek(cTrgKey)
	While Eval(bWhile)
		RecLock("HHTRG", .F.)
		HHTRG->HTR_TRG = If(lStatus, "X", Space(1))
		HHTRG->(MsUnlock())
		HHTRG->(dbSkip())
	EndDo
EndIf	
Return .T.


// Click no Handheld - Control
Function HHControl(aHH, nLin)
Local oDlgCtrHH
Local cVend      := Space(6)
Local aStatus    := {{STR0114,STR0115,STR0116,STR0117,STR0118, STR0119}, {"L", "J","H","P","B","E"}} //############### //"1-Livre"###"2-Job"###"3-Handheld"###"4-Processando"###"5-Bloqueado"###"6-Sinc. Parcial"
Local nStatus    := 0
Local nNewStatus := 0
Local nOldStatus := aScan(aStatus[2], {|x| x == aHH[nLin, 6]})
Local cStatus    := aHH[nLin, 5]
                    
If nOldStatus = 0
	nOldStatus := 1
EndIf

DEFINE MSDIALOG oDlgCtrHH TITLE STR0198 FROM 0,0 TO 85,200 PIXEL OF oDlg61 // //"Altera็ao de Status"
	
@07,07 SAY STR0199 PIXEL // //"Status:"
@07,40 COMBOBOX oStatus VAR cStatus ITEMS aStatus[1] PIXEL SIZE 55,10 ;
ON CHANGE (HHChangeStatus(aHH, nLin, aStatus, nOldStatus, oStatus:nAt))
	
@25,15 BUTTON STR0027 SIZE 28,11 PIXEL ; // //"&OK"
ACTION (nNewStatus := aScan(aStatus[1], {|x| x == cStatus}), ;
		aHH[nLin,5] := aStatus[1,nNewStatus], aHH[nLin, 6] := aStatus[2,nNewStatus],oDlgCtrHH:End()) 
	
@25,60 BUTTON STR0028 SIZE 28,11 PIXEL ACTION oDlgCtrHH:End() // //"&Cancelar"
	
ACTIVATE DIALOG oDlgCtrHH CENTERED	
	
Return Nil
      
Function CheckStats(aCon, aStat)
Local ni     := 1
Local nPos   := 0
Local cNivel := ""
//aAdd(aCon, {HHL->HHL_GRUPO, HHL->HHL_SERIE, HHL->HHL_SEQ, HHL->HHL_DATA, HHL->HHL_HORA1, HHL->HHL_OPER1, HHL->HHL_HORA2, HHL->HHL_OPER2, HHL->HHL_OBS})

For ni := 1 To Len(aCon)
	If Subs(aCon[ni, 6],1,1) = "0" // Logs de conexao
		If aCon[ni, 6] = "0001" // Inicio de Conexao (HHOPEN) - HHL->HHL_OPER1
			cNivel := "10"
			If aCon[ni, 8] = "0002" // Fim de Conexao (HHCLOSE) - HHL->HHL_OPER2
				cNivel := "1020"	
			Else
				cNivel := "1030"
			EndIf
			nPos := aScan(aStat, {|x|  x[1] == cNivel})
			If nPos > 0
				aStat[nPos, 3] += 1
				aStat[3, 3] += 1  // Total de Conexoes
			EndIf
		EndIf
	ElseIf Subs(aCon[ni, 6],1,1) = "1" // Logs de Importacao
			cNivel := "20"
			nPos := aScan(aStat, {|x| x[4] == aCon[ni, 6]})
			If nPos > 0
				cNivel := aStat[nPos, 1]
				aStat[nPos, 3] += 1
			EndIf
			// Totais
			nPos := aScan(aStat, {|x|  x[1] == Subs(cNivel,1,4)})
			If nPos > 0
				aStat[nPos, 3] += 1
			EndIf			
	EndIf
Next

Return Nil

Function HHUpdGraph(oGraphic, aStat, cCargo, nQtdSeries)
Local ni   := 0
Local nSerie := 0
Local aCorSer		:= {CLR_HBLUE, CLR_HRED, CLR_HGREEN, CLR_YELLOW, CLR_BLACK, CLR_GRAY, CLR_HCYAN, CLR_HMAGENTA}
If nQtdSeries > 0
	For ni := 1 To nQtdSeries
		oGraphic:DelSerie(ni)
		nQtdSeries--
	Next                             
EndIf

nPos := aScan(aStat, {|x|  x[1] == Subs(cCargo,1,2)})
For ni := nPos To Len(aStat)
	If Subs(aStat[ni,1],1,2) == Subs(cCargo,1,2) 
		If Len(aStat[ni,1]) <= 2  // Titulo do Grafico
			oGraphic:SetTitle(aStat[ni,2] , "" , CLR_BLACK , A_LEFTJUST , GRP_TITLE)
			//oGraphic:SetTitle(aStat[ni,2] , "" , CLR_BLACK , A_LEFTJUST , GRP_FOOT)
		Else
			If Len(aStat[ni,1]) <= 4  // Series do Grafico
				nQtdSeries++
				nSerie := oGraphic:CreateSerie(nQtdSeries)
				oGraphic:Add(nSerie, aStat[ni,3], aStat[ni,2] ,aCorSer[nQtdSeries])
			EndIf
		EndIf		
	Else
		If Subs(aStat[ni,1],1,2) != "--"
			Exit
		EndIf
	EndIf
Next

oGraphic:Refresh()
Return Nil

Function HHChangeStatus(aHH, nLin, aStatus, nOldStatus, nNewStatus)
Local cMsg       := ""

If nOldStatus = 0
	nOldStatus := 1
EndIf

If nNewStatus >= 2 .And. nNewStatus <= 4
	cMsg := STR0200 + aStatus[1,nNewStatus] + STR0201 //### //"O status "###" nใo pode ser selecionado manualmente."
	MsgStop(cMsg, STR0202) // //"Handheld Status"
	cStatus := aStatus[1,nOldStatus]
Else
	If !Empty(aHH[nLin,6])
		If STR0203 $ aStatus[1,nNewStatus] // //"Livre"
			cMsg += STR0204 + aStatus[1,nOldStatus] // //"A altera็ใo do Status do vendedor de "
			cMsg += STR0205 + aStatus[1,nNewStatus] + STR0207 //" implica na recria็ใo das informa็๕es do handheld selecionado, para todas as empresas e filiais. " ###" para "
  	        cMsg += STR0126 + Chr(13) + Chr(10) //"Caso existam informa็๕es nใo importadas para o Protheus estas serใo perdidas." 
			cMsg += STR0127 //"Deseja continuar ?"
			If MsgYesNo(cMsg, STR0202 )// ""Handheld Status"
				aHH[nLin, 5] := aStatus[1,nNewStatus]
				aHH[nLin, 6] := If(aStatus[2,nNewStatus]="L", Space(1), aStatus[2, nNewStatus])

				dbSelectArea("HHU")
				dbSetOrder(1)
				If dbSeek(aHH[nLin, 2])
					RecLock("HHU", .F.)
					HHU_LOCK := If(aStatus[2,nNewStatus]="L", Space(1), aStatus[2, nNewStatus])
					MsUnlock()
				EndIf
				HHRecreateUser(aHH[nLin,1], aHH[nLin,2], .T.)
				HHSaveLog(aHH[nLin,1], aHH[nLin,2], 2080, .T.,STR0208 + aStatus[1,nOldStatus] + STR0205 + aStatus[1,nNewStatus]) //"Status alterado de "###" para "
			EndIf
		EndIf
	Else
		aHH[nLin, 5] := aStatus[1,nNewStatus]
		aHH[nLin, 6] := If(aStatus[2,nNewStatus]="L", Space(1), aStatus[2, nNewStatus])
		dbSelectArea("HHU")
		dbSetOrder(1)
		If dbSeek(aHH[nLin, 2])
			RecLock("HHU", .F.)
			HHU->HHU_LOCK := If(aStatus[2,nNewStatus]="L", Space(1), aStatus[2, nNewStatus])
			MsUnlock()
		EndIf
		HHSaveLog(aHH[nLin,1], aHH[nLin,2], 2080, .T.,STR0208 + aStatus[1,nOldStatus] + STR0205 + aStatus[1,nNewStatus]) //"Status alterado de "###" para "
	EndIf
EndIf
Return
//////////////////////////////////////////////////////////////////////////////  CONTROLE //////////////////////////////////////////////////////////////////////////////
                                                                                                                                                                                
//////////////////////////////////////////////////////////////////////////////  FUNCOES INICIAS  //////////////////////////////////////////////////////////////////////////////
Function CheckPalmJob()
Local cRet := ""
Local nPos := 0
Local __PUALIAS := POpenHH()
Local aStatus := {}
Local cHandHeldDir := GetSrvProfString("HHTrgDir","\HHTRG\")
Local cFileLock := Subs(cHandHeldDir,2,Len(cHandHeldDir)-2) + ".LCK"
Local nHdl := 0
Local ni := 1

//verifica se o job esta no ar
nHdl := FOpen('\SEMAFORO\'+cFileLock, 0)
If File('\SEMAFORO\'+cFileLock)// .And. nHdl < 0
	cRet += STR0209 + Chr(13) + Chr(10) //"JOB estแ sendo executado."
EndIf

If File('\SEMAFORO\MCSLOCK.LCK')
	cRet += STR0262 + Chr(13) + Chr(10) // "Executando servi็o gen้rico"
EndIf

//MV_HHVRJOB
//Parametro que define se a tabela de HH deve ser varrida para atualizar a tela do monitor com os status de cada HandHeld
//A habilitacao desse parametro pode deixar o monitor lento, se o numero de HandHelds cadastrados for muito grande
If GetMV("MV_HHVRJOB",,"S") == "S"
	dbSelectArea(__PUALIAS)
	dbSetOrder(1)
	DbGoTop()
	While !Eof()
		nPos := aScan(aStatus,{|x| x[1] = HHU_LOCK})
		If nPos = 0
			aAdd(aStatus, {HHU_LOCK, 1})
		Else
			aStatus[nPos,2] += 1
		EndIf
		dbSkip()
	EndDo
	
	For ni := 1 To Len(aStatus)
		If Empty(aStatus[ni, 1])
			cRet += STR0210 + Alltrim(Str(aStatus[ni,2], 3,0)) + STR0211 + Chr(13) + Chr(10) //"Existem "###" handhelds sem opera็ใo."
		ElseIf aStatus[ni, 1] = "J"
			cRet += STR0210 + Alltrim(Str(aStatus[ni,2], 3,0)) + STR0212 + Chr(13) + Chr(10) //"Existem "###" handhelds atualizando os arquivos."
		ElseIf aStatus[ni, 1] = "B"
			cRet += STR0210 + Alltrim(Str(aStatus[ni,2], 3,0)) + STR0213 + Chr(13) + Chr(10) //"Existem "###" handhelds bloqueados. Verificar !!!"
		ElseIf aStatus[ni, 1] = "H"
			cRet += STR0210 + Alltrim(Str(aStatus[ni,2], 3,0)) + STR0214 + Chr(13) + Chr(10) //"Existem "###" handhelds em sincronismo."
		ElseIf aStatus[ni, 1] = "P"
			cRet += STR0210 + Alltrim(Str(aStatus[ni,2], 3,0)) + STR0215 + Chr(13) + Chr(10) //"Existem "###" handhelds processando servi็os de importa็ใo."
		ElseIf aStatus[ni, 1] = "E"
			cRet += STR0210 + Alltrim(Str(aStatus[ni,2], 3,0)) + STR0263 + Chr(13) + Chr(10) //"Existem "###" handhelds com sincronismo parcial."
		EndIf
	Next
EndIf

If Empty(cRet)
	cRet += STR0216 + Chr(13) + Chr(10) //"JOB nใo estแ sendo executado."
EndIf

cRet += Dtoc(Date()) + " - " + Time()
(__PUALIAS)->(dbCloseArea())
Return cRet

Static Function HHShowScript(aInfo)
Local cPath := PALMDIR
Local cFile := AllTrim(aInfo[1,7])

If File(PALMDIR+"\"+cFile)
	ShowMemo(cPath+cFile)
Else
	MsgAlert(STR0217 + PALMDIR) //"Arquivo de script nใo encontrado no caminho "
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ  PInitHH  บAutor ณLiber De Esteban    บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica e faz carga inicial das tabelas do monitor         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SFA                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function PInitHH()

Local ni 		  := 1
Local __PSALIAS   := POpenSrv()
Local __PTBLALIAS := POpenTbl()
Local aAllServ 	  := SFAllServ()
Local aIniSys  	  := aClone(aAllServ[1])
Local aIniServ 	  := aClone(aAllServ[2])
Local aTblSrv  	  := aClone(aAllServ[3])
Local aIniTbl  	  := aClone(aAllServ[4])

// Cria e Abre arquivos HHS
POpenSys()

// Grava Sistemas Iniciais
dbSelectArea("HHS")
dbSetOrder(1)
If Len(aIniSys) > 0 .And. HHS->(RecCount()) <> Len(aIniSys)
	For ni := 1 to len(aIniSys)
		If !HHS->(dbSeek(aIniSys[ni, 1]))
			RecLock("HHS", .T.)
			HHS->HHS_COD   := aIniSys[ni, 1]
			HHS->HHS_DESCR := aIniSys[ni, 2]
			HHS->HHS_TAB   := aIniSys[ni, 3]
			HHS->(MsUnLock())
		EndIf
	Next
EndIf

// Servicos Iniciais
dbSelectArea(__PSALIAS)
dbSetOrder(1)
If Len(aIniServ) > 0 .And. (__PSALIAS)->(RecCount()) <> Len(aIniServ)
	For ni := 1 To Len(aIniServ)
		If !(__PSALIAS)->(dbSeek(aIniServ[ni, 1]))
			RecLock(__PSALIAS, .T.)	
			(__PSALIAS)->HHR_COD    := aIniServ[ni, 1]
			(__PSALIAS)->HHR_DESCR  := aIniServ[ni, 2]
			(__PSALIAS)->HHR_FUNCAO := aIniServ[ni, 3]
			(__PSALIAS)->HHR_ALIAS  := aIniServ[ni, 4]
			(__PSALIAS)->HHR_ARQ    := aIniServ[ni, 5]
			(__PSALIAS)->HHR_TIPO   := aIniServ[ni, 6]
			(__PSALIAS)->HHR_EXEC   := aIniServ[ni, 7]
			(__PSALIAS)->(MsUnLock()) 
		EndIf
	Next
EndIf

//Tabelas Iniciais
dbSelectArea(__PTBLALIAS)
dbSetOrder(1)
If Len(aIniTbl) > 0 .And. (__PTBLALIAS)->(RecCount()) <> Len(aIniTbl)
	For ni := 1 To Len(aIniTbl)
		If !(__PTBLALIAS)->(dbSeek(aIniTbl[ni,1]))
			RecLock(__PTBLALIAS, .T.)
			(__PTBLALIAS)->HHT_COD    := aIniTbl[ni,1]
			(__PTBLALIAS)->HHT_DESCR  := aIniTbl[ni,2]
			(__PTBLALIAS)->HHT_ALIAS  := aIniTbl[ni,3]
			(__PTBLALIAS)->HHT_GEN    := aIniTbl[ni,4]
			(__PTBLALIAS)->HHT_TOHOST := aIniTbl[ni,5]
			(__PTBLALIAS)->HHT_FLDFIL := aIniTbl[ni,6]
			(__PTBLALIAS)->HHT_SHARE  := ""
			(__PTBLALIAS)->HHT_VER    := aIniTbl[ni,7]
			(__PTBLALIAS)->HHT_FILEMP := aIniTbl[ni,8]
			(__PTBLALIAS)->(MsUnLock()) 
		EndIf
	Next
EndIf

//Servi็os x Tabelas
If Len(aTblSrv) > 0 .And. HST->(RecCount()) <> Len(aTblSrv)
	For ni := 1 To Len(aTblSrv)
		If !HST->(dbSeek(aTblSrv[ni,1]+aTblSrv[ni,2]))
			RecLock("HST", .T.)
			HST->HST_CODSRV := aTblSrv[ni,1]
			HST->HST_CODTBL := aTblSrv[ni,2]
			HST->(MsUnLock()) 
		EndIf
	Next
EndIf

(__PSALIAS)->(dbCloseArea())
(__PTBLALIAS)->(dbCloseArea())
HST->(dbCloseArea())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณHHRecrAll บAutor  ณRodrigo A. Godinho  บ Data ณ  11/14/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRecria a base de todos os vendedores do grupo selecionado.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcGrupo - grupo selecionado.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HHRecrAll(cGrupo)
Local aArea		:=	GetArea()
Local aAreaHGU	:=	HGU->(GetArea())
Local cMsg		:= ""
Local nPalm		:= 0

cMsg += STR0260 //"Esta altera็ใo implica na exclusใo da base de dados dos usuแrios pertencentes a este grupo. "
cMsg += STR0126 + Chr(13) + Chr(10) //"Caso existam informa็๕es nใo importadas para o Protheus estas serใo perdidas."
cMsg += STR0127 //"Deseja continuar ?"

If MsgNoYes(cMsg, STR0128) //"Excluir Base"
	aArea		:=	GetArea()
	aAreaHGU	:=	HGU->(GetArea())
	HGU->(dbSetOrder(1))
	If HGU->(dbSeek(AllTrim(cGrupo)))
		While !HGU->(EOF()) .And. AllTrim(HGU->HGU_GRUPO)==AllTrim(cGrupo)
			nPalm ++
			HGU->(dbSkip())
		End
		ProcRegua(nPalm)
		HGU->(dbSeek(AllTrim(cGrupo)))
		While !HGU->(EOF()) .And. AllTrim(HGU->HGU_GRUPO)==AllTrim(cGrupo)
			HHRecreateUser(HGU->HGU_GRUPO, HGU->HGU_SERIE, .T., .F., .T.)
			HGU->(dbSkip())
			IncProc()
		End
	EndIf
	
	RestArea(aAreaHGU)
	RestArea(aArea)
EndIf	

Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณMarcaTodos บAutor ณLiber De Esteban    บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarcar todas as linhas de um listbox.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SFA                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MarcaTodos(aServ)
Local nX	:=	0

for nX:=1 to Len(aServ)
	aServ[nX][1] := .T.
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณInv_SelecaoบAutor ณLiber De Esteban    บ Data ณ  18/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverter a selecao das linhas de um listbox.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SFA                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Inv_Selecao(aServ)
Local nX	:=	0

For nX:=1 to Len(aServ)
	aServ[nX][1] := !aServ[nX][1]
Next

Return
