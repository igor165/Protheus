// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 3      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "Protheus.ch"
#include "OFIOC460.CH"
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIOC460   | Autor |  Thiago               | Data | 17/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Consulta Pecas em Andamento                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIOC460(cCodFil,cNroOS,cGruite,cCodIte)

Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local nTam :=0 //controla posicao da legenda na tela
Local aSizeAut   := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aFilAtu    := FWArrFilAtu()
Local aCopFil    := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Private oBran    := LoadBitmap( GetResources(), "BR_BRANCO" )
Private oVerd    := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVerm    := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oVerdN   := LoadBitmap( GetResources(), "BPMSEDT3" )
Private oVermN   := LoadBitmap( GetResources(), "BPMSEDT1" )
Private aListOS  := {{"","","","","",0,"",""}}
Private aListOSa := {{"","","","","",0,"",""}}
Private cCopFil  := ""
Private cCopOS   := ""
Private cCopGIte := ""
Private cCopCIte := ""
Private aRotina  := { { "" ,"axPesqui", 0 , 1},;	// Pesquisar
{ "" ,"OC060"   , 0 , 2}}	// Visualizar
Private cCadastro := STR0022	// Consulta OS
Private cCampo, nOpc := 2 , inclui := .f.
Private nQtdPen := 0
Private nQtdReq := 0
Private nTotGer := 0
default cCodFil := space(TamSX3("VO1_FILIAL")[1])
default cNroOS  := space(TamSX3("VO1_NUMOSV")[1])
default cGruite := space(TamSX3("VO3_GRUITE")[1])
default cCodIte := space(TamSX3("VO3_CODITE")[1])

aAdd(aCopFil,"")
aSort(aCopFil)

cCopFil  := cCodFil
cCopOS   := cNroOS
cCopGIte := cGruite
cCopCIte := cCodIte
lAchou := .t.
if !Empty(cCopFil) .or. !Empty(cCopOS) .or. !Empty(cCopGIte) .or. !Empty(cCopCIte)
	lAchou := .f.
Endif
nCkPerg1 := 1
aObjects := {}
AAdd( aObjects, { 05, 53 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 01, 10, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

if !Empty(cCopGIte)
	dbSelectArea("SBM")
	dbSetOrder(1)
	dbSeek(xFilial("SBM")+cCopGIte)
Endif
if !Empty(cCopCIte)
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+cCopGIte+cCopCIte)
Endif
if lAchou == .f.
	FS_FILTRAR(1,"0")
	if Len(aListOS) == 0 .or. Empty(aListOS[1,3]+aListOS[1,4]+aListOS[1,7])
		Return(.f.)
	Endif
Endif
DEFINE MSDIALOG oDlg1 TITLE (STR0001) From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL ("") OF oDlg1 PIXEL

@ aPosObj[1,1]+004,aPosObj[1,2]+098 SAY  (STR0002)  SIZE 60,08 OF oDlg1 PIXEL
@ aPosObj[1,1]+003,aPosObj[1,2]+125 MSCOMBOBOX oFilial VAR cCopFil ITEMS aCopFil  SIZE 75,08 OF oDlg1 PIXEL

@ aPosObj[1,1]+016,aPosObj[1,2]+098 SAY  (STR0003)  SIZE 60,08 OF oDlg1 PIXEL
@ aPosObj[1,1]+015,aPosObj[1,2]+125 MSGET oNroOS VAR cCopOS PICTURE "@!" F3 "VO1" SIZE 60,08 OF oDlg1 PIXEL
@ aPosObj[1,1]+028,aPosObj[1,2]+098 SAY  (STR0004) SIZE 60,08 OF oDlg1 PIXEL
@ aPosObj[1,1]+027,aPosObj[1,2]+125 MSGET oGruite VAR cCopGIte F3 "SBM" VALID FS_GRUPO(cCopGIte) PICTURE "@!" SIZE 30,08 OF oDlg1 PIXEL
@ aPosObj[1,1]+040,aPosObj[1,2]+098 SAY  (STR0005)  SIZE 60,08 OF oDlg1 PIXEL
@ aPosObj[1,1]+039,aPosObj[1,2]+125 MSGET oCodIte VAR cCopCIte F3 "SB1" VALID FS_CODITE(cCopGIte,cCopCIte) PICTURE "@!" SIZE 80,08 OF oDlg1 PIXEL

@ aPosObj[1,1]+008,aPosObj[1,4]-080 BUTTON oFiltrar PROMPT (STR0006) OF oDlg1 SIZE 65,10 PIXEL ACTION (FS_FILTRAR(nCkPerg1,"1")) //FILTRAR
@ aPosObj[1,1]+021,aPosObj[1,4]-080 BUTTON oLimpar  PROMPT (STR0008) OF oDlg1 SIZE 65,10 PIXEL ACTION (FS_LIMPAR(nCkPerg1)) //LIMPAR FILTRO
@ aPosObj[1,1]+035,aPosObj[1,4]-080 BUTTON oSair    PROMPT (STR0007) OF oDlg1 SIZE 65,10 PIXEL ACTION (oDlg1:End()) //SAIR

@ aPosObj[1,1]+012,aPosObj[1,2]+003 RADIO oRadio1 VAR nCkPerg1 3D SIZE 80,10 PROMPT (STR0009),(STR0010),(STR0011) OF oDlg1 PIXEL ON CHANGE ( Processa({ || FS_FILTRAR(nCkPerg1,"1") }) )

@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLstAgen FIELDS HEADER "",(STR0012),(STR0013),(STR0014),(STR0015),(STR0016),(STR0017);
COLSIZES 10,20,45,80,120,40,60 SIZE aPosObj[2,4]-4,aPosObj[2,3]-aPosObj[1,3] OF oDlg1 PIXEL ON DBLCLICK (FS_CONSUL())
oLstAgen:SetArray(aListOS)
oLstAgen:bLine := { || {IIF(aListOS[oLstAgen:nAt,1]=="0",IIf(aListOS[oLstAgen:nAt,7]=="",oVerd,oVerdN),IIF(aListOS[oLstAgen:nAt,1]=="2",IIf(aListOS[oLstAgen:nAt,7]=="",oVerm,oVermN),oBran)),;
aListOS[oLstAgen:nAt,2],;
aListOS[oLstAgen:nAt,3],;
aListOS[oLstAgen:nAt,4],;
aListOS[oLstAgen:nAt,5],;
aListOS[oLstAgen:nAt,6],;
aListOS[oLstAgen:nAt,7]}}

@ aPosObj[1,1]+009,aPosObj[1,2]+215 BITMAP OXverd RESOURCE "BR_verde" OF oDlg1 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[1,1]+010,aPosObj[1,2]+225 SAY (STR0018) SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+009,aPosObj[1,2]+285 MSGET oQtdPen VAR nQtdPen PICTURE "@E 9999999" SIZE 40,08 OF oDlg1 PIXEL WHEN .f.

@ aPosObj[1,1]+021,aPosObj[1,2]+215 BITMAP OXverm RESOURCE "BR_VERMELHO" OF oDlg1 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[1,1]+022,aPosObj[1,2]+225 SAY (STR0011) SIZE 60,08 OF oDlg1 PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+021,aPosObj[1,2]+285 MSGET oQtdReq VAR nQtdReq PICTURE "@E 9999999" SIZE 40,08 OF oDlg1 PIXEL WHEN .f.

@ aPosObj[1,1]+037,aPosObj[1,2]+225 SAY (STR0023) SIZE 80,08 OF oDlg1 PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+036,aPosObj[1,2]+285 MSGET oQtdTot VAR nTotGer PICTURE "@E 9999999" SIZE 40,08 OF oDlg1 PIXEL WHEN .f.

ACTIVATE MSDIALOG oDlg1 CENTER

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FS_GRUPO   | Autor |  Thiago               | Data | 17/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Valida Grupo do Item                                         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_GRUPO(cCopGIte)
Local lRet := .t.
if !Empty(cCopGIte)
	dbSelectArea("SBM")
	dbSetOrder(1)
	if !dbSeek(xFilial("SBM")+cCopGIte)
		MsgInfo((STR0019),(STR0020))
		lRet := .f.
	Endif
Endif
Return(lRet)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FS_CODITE  | Autor |  Thiago               | Data | 17/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Valida Codigo do Item                                        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_CODITE(cCopGIte,cCopCIte)
Local lRet := .t.
if !Empty(cCopCIte)
	If !FG_POSSB1("cCopCIte","SB1->B1_COD","cCopGIte")
		lRet := .f.
	EndIf
Endif
Return(lRet)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FS_FILTRAR | Autor |  Thiago               | Data | 17/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Filtra / Levanta dados                                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_FILTRAR(nCkPerg1,cCond)

Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0

Local cAliasVSJ 	:= "SQLVSJ"
Local cAliasVO3 	:= "SQLVO3"
Local i := 0
aListOS := {}

nQtdPen := 0
nQtdReq := 0
nTotGer := 0
aListOSa := {}

For nCont := 1 to Len(aSM0)
	
	If !Empty(cCopFil) //Filtra Filial
		If cCopFil <> aSM0[nCont]
			Loop
		EndIf
	EndIf
	cFilAnt := aSM0[nCont]
	
	if nCkPerg1 == 1 .or. nCkPerg1 == 2
		
		cQuery := "SELECT VSJ.VSJ_FILIAL,VSJ.VSJ_GRUITE,VSJ.VSJ_CODITE,VSJ.VSJ_QTDITE,VSJ.VSJ_NUMOSV "
		cQuery += "FROM "
		cQuery += RetSqlName( "VSJ" ) + " VSJ "
		cQuery += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL=VSJ.VSJ_FILIAL AND VO1.VO1_NUMOSV=VSJ.VSJ_NUMOSV AND VO1.D_E_L_E_T_=' ') "
		cQuery += "WHERE VSJ.VSJ_FILIAL='"+xFilial("VSJ")+"' AND "
		if !Empty(cCopOS)
			cQuery += "VSJ.VSJ_NUMOSV='"+Alltrim(cCopOS)+"' AND "
		Endif
		if !Empty(cCopGIte)
			cQuery += "VSJ.VSJ_GRUITE='"+Alltrim(cCopGIte)+"' AND "
		Endif
		if !Empty(cCopCIte)
			cQuery += "VSJ.VSJ_CODITE='"+Alltrim(cCopCIte)+"' AND "
		Endif
		cQuery += "VSJ.D_E_L_E_T_=' '"
		
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVSJ, .T., .T. )
		
		Do While !( cAliasVSJ )->( Eof() )
			
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+( cAliasVSJ )->VSJ_GRUITE+( cAliasVSJ )->VSJ_CODITE)
			nPos := Ascan(aListOSa,{|x| x[1]+x[2]+x[3]+x[4] == "0"+( cAliasVSJ )->VSJ_FILIAL+( cAliasVSJ )->VSJ_GRUITE+( cAliasVSJ )->VSJ_CODITE})
			if nPos == 0
				aAdd(aListOSa,{"0",( cAliasVSJ )->VSJ_FILIAL,( cAliasVSJ )->VSJ_GRUITE,( cAliasVSJ )->VSJ_CODITE,SB1->B1_DESC,( cAliasVSJ )->VSJ_QTDITE,"",cFilAnt})
			Else
				aListOSa[nPos,6] += ( cAliasVSJ )->VSJ_QTDITE
			Endif
			nQtdPen += ( cAliasVSJ )->VSJ_QTDITE
			dbSelectArea(cAliasVSJ)
			( cAliasVSJ )->(dbSkip())
			
		Enddo
		( cAliasVSJ )->(dbCloseArea())
		
	Endif
	if nCkPerg1 == 1 .or. nCkPerg1 == 3
		
		cQuery := "SELECT DISTINCT VO3.VO3_FILIAL,VO3.VO3_GRUITE,VO3.VO3_CODITE,VO3.VO3_QTDREQ,VO3.VO3_NUMOSV,VO2.VO2_DEVOLU "
		cQuery += "FROM "
		cQuery += RetSqlName( "VO3" ) + " VO3 "
		cQuery    += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV= VO3.VO3_NUMOSV AND VO1.D_E_L_E_T_=' ') "
		cQuery    += "INNER JOIN "+RetSqlName("VO2")+" VO2 ON (VO2.VO2_FILIAL = VO3.VO3_FILIAL AND VO3.VO3_NOSNUM= VO2.VO2_NOSNUM  AND VO2.D_E_L_E_T_=' ') "
		cQuery    += "LEFT JOIN "+RetSqlName("VS1")+" VS1 ON (VS1.VS1_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV= VS1.VS1_NUMOSV AND VS1.D_E_L_E_T_=' ') "
		cQuery += "WHERE VO3.VO3_FILIAL='"+xFilial("VO3")+"' AND "
		if !Empty(cCopOS)
			cQuery += "VO3.VO3_NUMOSV = '"+Alltrim(cCopOS)+"' AND "
		Endif
		if !Empty(cCopGIte)
			cQuery += "VO3.VO3_GRUITE = '"+Alltrim(cCopGIte)+"' AND "
		Endif
		if !Empty(cCopCIte)
			cQuery += "VO3.VO3_CODITE = '"+Alltrim(cCopCIte)+"' AND "
		Endif
		cQuery += "VO3.VO3_DATFEC = '        ' AND VO3.VO3_DATCAN = '        '  AND VO3.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO3, .T., .T. )
		Do While !( cAliasVO3 )->( Eof() )
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+( cAliasVO3 )->VO3_GRUITE+( cAliasVO3 )->VO3_CODITE)
			nPos := Ascan(aListOSa,{|x| x[1]+x[2]+x[3]+x[4] == "2"+( cAliasVO3 )->VO3_FILIAL+( cAliasVO3 )->VO3_GRUITE+( cAliasVO3 )->VO3_CODITE})
			if nPos == 0
				if ( cAliasVO3 )->VO2_DEVOLU == '0'
					aAdd(aListOSa,{"2",( cAliasVO3 )->VO3_FILIAL,( cAliasVO3 )->VO3_GRUITE,( cAliasVO3 )->VO3_CODITE,SB1->B1_DESC,( ( cAliasVO3 )->VO3_QTDREQ * ( -1 ) ),"",cFilAnt})
				Else
					aAdd(aListOSa,{"2",( cAliasVO3 )->VO3_FILIAL,( cAliasVO3 )->VO3_GRUITE,( cAliasVO3 )->VO3_CODITE,SB1->B1_DESC,( cAliasVO3 )->VO3_QTDREQ,"",cFilAnt})
				Endif
			Else
				if ( cAliasVO3 )->VO2_DEVOLU == '0'
					aListOSa[nPos,6] -= ( cAliasVO3 )->VO3_QTDREQ
				Else
					aListOSa[nPos,6] += ( cAliasVO3 )->VO3_QTDREQ
				Endif
			Endif
			if ( cAliasVO3 )->VO2_DEVOLU == '0'
				nQtdReq -= ( cAliasVO3 )->VO3_QTDREQ
			Else
				nQtdReq += ( cAliasVO3 )->VO3_QTDREQ
			Endif
			dbSelectArea(cAliasVO3)
			( cAliasVO3 )->(dbSkip())
		Enddo
		( cAliasVO3 )->(dbCloseArea())
	Endif
	
Next
cFilAnt := cBkpFilAnt
DbSelectArea("VO3")
For i := 1 to Len(aListOSa)
	if aListOSa[i,6] > 0
		aAdd(aListOS,{aListOSa[i,1],aListOSa[i,2],aListOSa[i,3],aListOSa[i,4],aListOSa[i,5],aListOSa[i,6],aListOSa[i,7],aListOSa[i,8]})
	Endif
Next
Asort(aListOS,,,{|x,y| x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4] } )
aListOSa := {}
if Len(aListOS) == 0
	MsgStop(STR0024,STR0020) // Nao existe dados para esta consulta! / Atencao
	aListOS := {{"","","","","",0,"",""}}
Endif
nTotGer += nQtdPen+nQtdReq
if lAchou .or. cCond == "1"
	oLstAgen:SetArray(aListOS)
	oLstAgen:bLine := { || {IIF(aListOS[oLstAgen:nAt,1]=="0",IIf(aListOS[oLstAgen:nAt,7]=="",oVerd,oVerdN),IIF(aListOS[oLstAgen:nAt,1]=="2",IIf(aListOS[oLstAgen:nAt,7]=="",oVerm,oVermN),oBran)),;
	aListOS[oLstAgen:nAt,2],;
	aListOS[oLstAgen:nAt,3],;
	aListOS[oLstAgen:nAt,4],;
	aListOS[oLstAgen:nAt,5],;
	aListOS[oLstAgen:nAt,6],;
	aListOS[oLstAgen:nAt,7]}}
	oLstAgen:Refresh()
	oQtdPen:Refresh()
	oQtdTot:Refresh()
	oQtdReq:Refresh()
Endif
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FS_LIMPAR  | Autor |  Thiago               | Data | 17/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Limpa campos na tela                                         |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_LIMPAR(nCkPerg1)

aListOS  := {}
aListOS  := {{"","","","","",0,"",""}}
cCopFil  := space(TamSX3("VO1_FILIAL")[1])
cCopOS   := space(TamSX3("VO1_NUMOSV")[1])
cCopGIte := space(TamSX3("VO3_GRUITE")[1])
cCopCIte := space(TamSX3("VO3_CODITE")[1])
oLstAgen:SetArray(aListOS)
oLstAgen:bLine := { || {IIF(aListOS[oLstAgen:nAt,1]=="0",IIf(aListOS[oLstAgen:nAt,7]=="",oVerd,oVerdN),IIF(aListOS[oLstAgen:nAt,1]=="2",IIf(aListOS[oLstAgen:nAt,7]=="",oVerm,oVermN),oBran)),;
aListOS[oLstAgen:nAt,2],;
aListOS[oLstAgen:nAt,3],;
aListOS[oLstAgen:nAt,4],;
aListOS[oLstAgen:nAt,5],;
aListOS[oLstAgen:nAt,6],;
aListOS[oLstAgen:nAt,7]}}
oLstAgen:Refresh()
oFilial:Refresh()
oNroOS:Refresh()
oCodIte:Refresh()

Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FS_CONSUL  | Autor |  Thiago               | Data | 17/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Consulta VSJ                                                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_CONSUL()
Local cBkpFilAnt := cFilAnt
Local i          := 0
Local cAliasVSJ  := "SQLVSJ"
Local cAliasVO3  := "SQLVO3"
aListOSa := {}

cFilAnt := aListOS[oLstAgen:nAt,8]

if aListOS[oLstAgen:nAt,1] $ "0" .and. aListOS[oLstAgen:nAt,7] == ""
	cQuery := "SELECT VSJ.VSJ_FILIAL,VSJ.VSJ_GRUITE,VSJ.VSJ_CODITE,VSJ.VSJ_QTDITE,VSJ.VSJ_NUMOSV "
	cQuery += "FROM "
	cQuery += RetSqlName( "VSJ" ) + " VSJ "
	cQuery += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL=VSJ.VSJ_FILIAL AND VO1.VO1_NUMOSV=VSJ.VSJ_NUMOSV AND VO1.D_E_L_E_T_=' ') "
	cQuery += "WHERE "
	cQuery += "VSJ.VSJ_FILIAL='"+xFilial("VSJ")+ "' AND "
	cQuery += "VSJ.VSJ_GRUITE='"+aListOS[oLstAgen:nAt,3]+"' AND "
	cQuery += "VSJ.VSJ_CODITE='"+aListOS[oLstAgen:nAt,4]+"' AND "
	if !Empty(cCopOS)
		cQuery += "VSJ.VSJ_NUMOSV = '"+cCopOS+"' AND "
	Endif
	cQuery += "VSJ.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVSJ, .T., .T. )
	Do While !( cAliasVSJ )->( Eof() )
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+( cAliasVSJ )->VSJ_GRUITE+( cAliasVSJ )->VSJ_CODITE)
		nPos := Ascan(aListOSa,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == "0"+( cAliasVSJ )->VSJ_FILIAL+( cAliasVSJ )->VSJ_GRUITE+( cAliasVSJ )->VSJ_CODITE+( cAliasVSJ )->VSJ_NUMOSV})
		if nPos == 0
			aAdd(aListOSa,{"0",( cAliasVSJ )->VSJ_FILIAL,( cAliasVSJ )->VSJ_GRUITE,( cAliasVSJ )->VSJ_CODITE,SB1->B1_DESC,( cAliasVSJ )->VSJ_QTDITE,( cAliasVSJ )->VSJ_NUMOSV,cFilAnt})
		Else
			aListOSa[nPos,6] += ( cAliasVSJ )->VSJ_QTDITE
		Endif
		dbSelectArea(cAliasVSJ)
		( cAliasVSJ )->(dbSkip())
	Enddo
	( cAliasVSJ )->(dbCloseArea())
	
	For i := 1 to Len(aListOSa)
		nPos := Ascan(aListOS,{|x| x[1]+x[2]+x[3]+x[4]+x[7]  == aListOSa[i,1]+aListOSa[i,2]+aListOSa[i,3]+aListOSa[i,4]+aListOSa[i,7]})
		if nPos > 0
			aDel(aListOS,nPos)
			aSize(aListOS,len(aListOS)-1)
		Else
			if aListOSa[i,6] > 0
				aAdd(aListOS,{aListOSa[i,1],aListOSa[i,2],aListOSa[i,3],aListOSa[i,4],aListOSa[i,5],aListOSa[i,6],aListOSa[i,7],aListOSa[i,8]})
			Endif
		Endif
	Next
	Asort(aListOS,,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[7] < y[1]+y[2]+y[3]+y[4]+y[7] } )
	oLstAgen:SetArray(aListOS)
	oLstAgen:bLine := { || {IIF(aListOS[oLstAgen:nAt,1]=="0",IIf(aListOS[oLstAgen:nAt,7]=="",oVerd,oVerdN),IIF(aListOS[oLstAgen:nAt,1]=="2",IIf(aListOS[oLstAgen:nAt,7]=="",oVerm,oVermN),oBran)),;
	aListOS[oLstAgen:nAt,2],;
	aListOS[oLstAgen:nAt,3],;
	aListOS[oLstAgen:nAt,4],;
	aListOS[oLstAgen:nAt,5],;
	aListOS[oLstAgen:nAt,6],;
	aListOS[oLstAgen:nAt,7]}}
	oLstAgen:Refresh()
	oQtdPen:Refresh()
	oQtdTot:Refresh()
	oQtdReq:Refresh()
Elseif aListOS[oLstAgen:nAt,1] == '2' .and. aListOS[oLstAgen:nAt,7] == ""
	cQuery := "SELECT DISTINCT VO3.VO3_FILIAL,VO3.VO3_GRUITE,VO3.VO3_CODITE,VO3.VO3_QTDREQ,VO3.VO3_NUMOSV,VO2.VO2_DEVOLU "
	cQuery += "FROM "
	cQuery += RetSqlName( "VO3" ) + " VO3 "
	cQuery    += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO3.VO3_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV= VO3.VO3_NUMOSV AND VO1.D_E_L_E_T_=' ') "
	cQuery    += "INNER JOIN "+RetSqlName("VO2")+" VO2 ON (VO2.VO2_FILIAL = VO3.VO3_FILIAL AND VO3.VO3_NOSNUM= VO2.VO2_NOSNUM  AND VO2.D_E_L_E_T_=' ') "
	cQuery    += "LEFT JOIN "+RetSqlName("VS1")+" VS1 ON (VS1.VS1_FILIAL = VO1.VO1_FILIAL AND VO1.VO1_NUMOSV= VS1.VS1_NUMOSV AND VS1.D_E_L_E_T_=' ') "
	cQuery += "WHERE "
	cQuery += "VO3.VO3_FILIAL='"+ xFilial("VO3")+"' AND "
	cQuery += "VO3.VO3_GRUITE='"+aListOS[oLstAgen:nAt,3]+"' AND "
	cQuery += "VO3.VO3_CODITE='"+aListOS[oLstAgen:nAt,4]+"' AND "
	if !Empty(cCopOS)
		cQuery += "VO3.VO3_NUMOSV = '"+cCopOS+"' AND "
	Endif
	cQuery += "VO3.VO3_DATFEC = '        ' AND VO3.VO3_DATCAN = '        '  AND VO3.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVO3, .T., .T. )
	nQtd := 0
	Do While !( cAliasVO3 )->( Eof() )
		
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+( cAliasVO3 )->VO3_GRUITE+( cAliasVO3 )->VO3_CODITE)
		nPos := Ascan(aListOSa,{|x| x[1]+x[2]+x[3]+x[4]+x[7] == "2"+( cAliasVO3 )->VO3_FILIAL+( cAliasVO3 )->VO3_GRUITE+( cAliasVO3 )->VO3_CODITE+( cAliasVO3 )->VO3_NUMOSV})
		if nPos == 0
			if ( cAliasVO3 )->VO2_DEVOLU == '0'
				nQtd -= ( cAliasVO3 )->VO3_QTDREQ
				aAdd(aListOSa,{"2",( cAliasVO3 )->VO3_FILIAL,( cAliasVO3 )->VO3_GRUITE,( cAliasVO3 )->VO3_CODITE,SB1->B1_DESC,nQtd,( cAliasVO3 )->VO3_NUMOSV,cFilAnt})
			Else
				aAdd(aListOSa,{"2",( cAliasVO3 )->VO3_FILIAL,( cAliasVO3 )->VO3_GRUITE,( cAliasVO3 )->VO3_CODITE,SB1->B1_DESC,( cAliasVO3 )->VO3_QTDREQ,( cAliasVO3 )->VO3_NUMOSV,cFilAnt})
			Endif
		Else
			if ( cAliasVO3 )->VO2_DEVOLU == '0'
				aListOSa[nPos,6] -= ( cAliasVO3 )->VO3_QTDREQ
			Else
				aListOSa[nPos,6] += ( cAliasVO3 )->VO3_QTDREQ
			Endif
		Endif
		dbSelectArea(cAliasVO3)
		( cAliasVO3 )->(dbSkip())
		
	Enddo
	( cAliasVO3 )->(dbCloseArea())
	
	For i := 1 to Len(aListOSa)
		nPos := Ascan(aListOS,{|x| x[1]+x[2]+x[3]+x[4]+x[7]  == aListOSa[i,1]+aListOSa[i,2]+aListOSa[i,3]+aListOSa[i,4]+aListOSa[i,7]})
		if nPos > 0
			aDel(aListOS,nPos)
			aSize(aListOS,len(aListOS)-1)
		Else
			if aListOSa[i,6] > 0
				aAdd(aListOS,{aListOSa[i,1],aListOSa[i,2],aListOSa[i,3],aListOSa[i,4],aListOSa[i,5],aListOSa[i,6],aListOSa[i,7],aListOSa[i,8]})
			Endif
		Endif
	Next
	Asort(aListOS,,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[7] < y[1]+y[2]+y[3]+y[4]+y[7] } )
	
	oLstAgen:SetArray(aListOS)
	oLstAgen:bLine := { || {IIF(aListOS[oLstAgen:nAt,1]=="0",IIf(aListOS[oLstAgen:nAt,7]=="",oVerd,oVerdN),IIF(aListOS[oLstAgen:nAt,1]=="2",IIf(aListOS[oLstAgen:nAt,7]=="",oVerm,oVermN),oBran)),;
	aListOS[oLstAgen:nAt,2],;
	aListOS[oLstAgen:nAt,3],;
	aListOS[oLstAgen:nAt,4],;
	aListOS[oLstAgen:nAt,5],;
	aListOS[oLstAgen:nAt,6],;
	aListOS[oLstAgen:nAt,7]}}
	oLstAgen:Refresh()
	oQtdPen:Refresh()
	oQtdTot:Refresh()
	oQtdReq:Refresh()
	
Else
	
	if Empty(aListOS[oLstAgen:nAt,7])
		Return(.f.)
	Endif
	VO1->(dbSetOrder(1))
	If VO1->(DbSeek( xFilial("VO1") + aListOS[oLstAgen:nAt,7] ))
		OC060("VO1",VO1->(RECNO()),2)
	EndIf
	
Endif

cFilAnt := cBkpFilAnt

Return(.t.)
