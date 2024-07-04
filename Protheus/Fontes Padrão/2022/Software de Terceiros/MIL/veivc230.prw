// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 3      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEIVC230.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC230 ³ Autor ³  Thiago				³ Data ³ 03/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta Demonstrativo das Despesas com despachante        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Concessionarias                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VEIVC230()

Local aObjects := {} , aInfo := {}, aPos := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private cChassiDe := space(30)
Private cChassiAte := space(30)
Private cDias      := 0
Private cAnoDe       := space(4)
Private cAnoAte       := space(4)
Private aDespesa := {{"","","","","",stod("  /  /  "),0,stod("  /  /  "),""}}

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 25 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 05, 25, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0001) FROM  aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3]+014,aPosObj[1,4] LABEL STR0002 OF oDlg1 PIXEL
//@ aPosObj[1,1],aPosObj[1,2]+400 TO aPosObj[1,3]+014,aPosObj[1,4] LABEL STR0003 OF oDlg1 PIXEL
nTam := ( aPosObj[1,4] / 6) //varaivel que armazena o resutlado da divisao da tela.
@ aPosObj[1,1]+007,aPosObj[1,2]+003 SAY STR0004 SIZE 70,40  Of oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+007,aPosObj[1,2]+040 MSGET oChassiDe VAR cChassiDe PICTURE "@!" F3 "VV1" SIZE 75,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+007,aPosObj[1,2]+130 SAY STR0005 SIZE 70,40  Of oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+007,aPosObj[1,2]+165 MSGET oChassiAte VAR cChassiAte PICTURE "@!" F3 "VV1" SIZE 75,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+007,aPosObj[1,2]+250 SAY STR0006 SIZE 70,40  Of oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+007,aPosObj[1,2]+290 MSGET oDias VAR cDias PICTURE "99999" F3 "VV1" SIZE 25,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+023,aPosObj[1,2]+003 SAY STR0007 SIZE 70,40  Of oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+023,aPosObj[1,2]+040 MSGET oAnoDe VAR cAnoDe PICTURE "@R 9999"  SIZE 25,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+023,aPosObj[1,2]+080 SAY STR0008 SIZE 70,40  Of oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+023,aPosObj[1,2]+120 MSGET oAnoAte VAR cAnoAte PICTURE "@!"  SIZE 25,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+023,aPosObj[1,2]+330 BUTTON oFiltro    PROMPT OemToAnsi(STR0009) OF oDlg1 SIZE 65,10 PIXEL ACTION (FS_FILTRO())
@ aPosObj[1,1]+007,aPosObj[1,4]-070 BUTTON oFiltro    PROMPT OemToAnsi(STR0010) OF oDlg1 SIZE 65,10 PIXEL ACTION (FS_IMPRIMIR())
@ aPosObj[1,1]+023,aPosObj[1,4]-070 BUTTON oFiltro    PROMPT OemToAnsi(STR0011) OF oDlg1 SIZE 65,10 PIXEL ACTION (FS_SAIR())

@ aPosObj[2,1]+13,aPosObj[2,2] LISTBOX oLbAnalit FIELDS HEADER STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0020  COLSIZES 40,60,40,40,110,40,40,40,200 SIZE aPosObj[2,4],aPosObj[2,3]-50 OF oDlg1 PIXEL

oLbAnalit:SetArray(aDespesa)
oLbAnalit:bLine := { || { aDespesa[oLbAnalit:nAt,1] ,;
aDespesa[oLbAnalit:nAt,2] ,;
aDespesa[oLbAnalit:nAt,3] ,;
aDespesa[oLbAnalit:nAt,4] ,;
aDespesa[oLbAnalit:nAt,5] ,;
transform(aDespesa[oLbAnalit:nAt,6],"@D" ),;
transform(aDespesa[oLbAnalit:nAt,7],"@E 99,999,999.99"),;
transform(aDespesa[oLbAnalit:nAt,8],"@D" ),;
aDespesa[oLbAnalit:nAt,9]}}

ACTIVATE MSDIALOG oDlg1 CENTER

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRO³ Autor ³  Thiago				³ Data ³ 03/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro												      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Concessionarias                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FS_FILTRO()
Local cAliasVD0 := "SQLVD0"
aDespesa := {}

cQuery := "SELECT VD0.VD0_CHAINT,VV1.VV1_CHASSI,VD0.VD0_ANOREF,VD0.VD0_CODDES,VD0.VD0_DATVEN,VD0.VD0_VALDES,VD0.VD0_DTEFPG,VD0.VD0_OBSERV "
cQuery += "FROM "
cQuery += RetSqlName( "VD0" ) + " VD0 "
cQuery += "INNER JOIN "+RetSQLName("VV1")+" VV1 ON  VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = VD0.VD0_CHAINT AND VV1.D_E_L_E_T_=' ' "
cQuery += "WHERE "
cQuery += "VD0.VD0_FILIAL='"+ xFilial("VD0")+ "' AND VV1.VV1_CHAINT <> '      ' AND "
if !Empty(cChassiDe+cChassiAte)
	cQuery += "VV1.VV1_CHASSI >= '"+cChassiDe+"' AND VV1.VV1_CHASSI <= '"+cChassiAte+"' AND "
Endif
if !Empty(cDias)
	cQuery += "VD0.VD0_DATVEN >= '"+dtos(dDataBase)+"' AND VD0.VD0_DATVEN <= '"+dtos(dDataBase+cDias)+"' AND "
Endif
if !Empty(cAnoDe+cAnoAte)
	cQuery += "VD0.VD0_ANOREF >= '"+cAnoDe+"' AND VD0.VD0_ANOREF <= '"+cAnoAte+"' AND "
Endif
cQuery += "VD0.D_E_L_E_T_=' ' ORDER BY VD0.VD0_CHAINT,VD0.VD0_ANOREF,VD0.VD0_CODDES"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVD0, .T., .T. )
Do While !( cAliasVD0 )->( Eof() )
	
	dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"V6"+( cAliasVD0 )->VD0_CODDES)
	AADD(aDespesa,{( cAliasVD0 )->VD0_CHAINT,( cAliasVD0 )->VV1_CHASSI,( cAliasVD0 )->VD0_ANOREF,( cAliasVD0 )->VD0_CODDES,SX5->X5_DESCRI,stod(( cAliasVD0 )->VD0_DATVEN),( cAliasVD0 )->VD0_VALDES,stod(( cAliasVD0 )->VD0_DTEFPG),( cAliasVD0 )->VD0_OBSERV})
	
	dbSelectArea(cAliasVD0)
	( cAliasVD0 )->(dbSkip())
Enddo
( cAliasVD0 )->(dbCloseArea())

oLbAnalit:SetArray(aDespesa)
oLbAnalit:bLine := { || { aDespesa[oLbAnalit:nAt,1] ,;
aDespesa[oLbAnalit:nAt,2] ,;
aDespesa[oLbAnalit:nAt,3] ,;
aDespesa[oLbAnalit:nAt,4] ,;
aDespesa[oLbAnalit:nAt,5] ,;
transform(aDespesa[oLbAnalit:nAt,6],"@D" ),;
transform(aDespesa[oLbAnalit:nAt,7],"@E 99,999,999.99"),;
transform(aDespesa[oLbAnalit:nAt,8],"@D" ),;
aDespesa[oLbAnalit:nAt,9]}}
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SAIR  ³ Autor ³  Thiago				³ Data ³ 03/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Botao sair											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Concessionarias                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_SAIR()
oDlg1:End()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR ³ Autor ³  Thiago				³ Data ³ 03/10/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Botao sair   											    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Concessionarias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_IMPRIMIR()

Local i         := 0
Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private aVetor := {}
Private cTamanho:= "M"           // P/M/G
Private Limite  := 132           // 80/132/220
Private cTitulo := STR0021
Private cNomProg:= "VEIVC230"
Private cNomeRel:= "VEIVC230"
Private nLastKey:= 0
Private cabec1  := ""
Private cabec2  := ""
Private nCaracter:=15
Private m_Pag   := 1
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1

cVeiculo := "Inicio"
cAno := "Inicio"
nSubTot := 0
nValTot := 0
nValGer := 0
For i:=1 to Len(aDespesa)
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+aDespesa[i,1])
	dbSelectArea("VV2")
	dbSetOrder(1)
	dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
	if cVeiculo <> aDespesa[i,2]
		if cAno <> "Inicio"
			@nLin++, 034 pSay STR0022+transform(nSubTot,"@E 99,999,999.99")
			@nLin++, 034 pSay STR0023+transform(nValTot,"@E 99,999,999.99")
			nSubTot := 0
			nValTot := 0
		Endif
		nLin++
		@nLin++, 000 pSay STR0024+aDespesa[i,2]+" - "+VV2->VV2_DESMOD
		cAno := "Inicio"
	Endif
	if cAno <> aDespesa[i,3]
		if cAno <> "Inicio"
			@nLin++, 034 pSay STR0022+transform(nSubTot,"@E 99,999,999.99")
			nSubTot := 0
		Endif
		nLin++
		@nLin++, 003 pSay STR0025+aDespesa[i,3]
		nLin++
		@nLin++, 006 pSay STR0026
	Endif
	@nLin++, 006 pSay aDespesa[i,4]+"-"+substr(aDespesa[i,5],1,25)+" "+transform(aDespesa[i,6],"@D")+"     "+transform(aDespesa[i,7],"@E 99,999,999.99")+"   "+transform(aDespesa[i,8],"@D")+"  "+aDespesa[i,9]
	
	cVeiculo := aDespesa[i,2]
	cAno     := aDespesa[i,3]
	nSubTot  += aDespesa[i,7]
	nValTot  += aDespesa[i,7]
	nValGer  += aDespesa[i,7]
Next
@nLin++, 034 pSay STR0022+transform(nSubTot,"@E 99,999,999.99")
@nLin++, 034 pSay STR0023+transform(nValTot,"@E 99,999,999.99")
@ nLin++ ,34 psay Repl("-",24)
@nLin++, 034 pSay STR0027+transform(nValGer,"@E 99,999,999.99")
@ nLin++ , 34 psay Repl("-",24)

Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

Return(.t.)
