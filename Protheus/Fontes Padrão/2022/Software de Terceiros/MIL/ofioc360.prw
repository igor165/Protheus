#Include "Protheus.ch"
#Include "OFIOC360.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC360 ³ Autor ³ Thiago Aprile         ³ Data ³02/04/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Consulta de itens deletados do Orcamento pelo cliente       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC360()

Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
Local aTitles  := {"Pecas","Servicos"}
Private dDataIni := CtoD("")
Private cOrcam := space(8)
Private dDataFin := dDataBase
Private aItens := {{"",CtoD(""),0,"","",0,0,"",""}}
Private aSrv   := {{"",CtoD(""),0,"","","",0,"",""}}
Private nQtd   := 0
Private nSoma  := 0
Private nSomaS := 0
Private cNomcli := Space(50)
Private lVisible := .f.
Private nSomSer  := 0

FS_PESQUISAR(0)
FS_AtuSXB()

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 000, 029 , .T. , .F. } )//cabecalho
AAdd( aObjects, { 000, 000 , .T. , .T. } )//listbox
AAdd( aObjects, { 000, 022 , .T. , .F. } )//rodape

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0001 OF oMainWnd PIXEL //Consulta Itens cortados do orcamento

@ aPos[2,1],aPos[2,2] FOLDER oFolder SIZE aPos[2,4]-aPos[2,2],aPos[2,3]-aPos[2,1] OF oDlg PROMPTS aTitles[1],aTitles[2] PIXEL
FG_INIFOLDER("oFolder")

@ aPos[1,1],aPos[1,2] TO aPos[1,3],aPos[1,4] LABEL "" OF oDlg PIXEL  //valores
@ aPos[1,1],aPos[1,4]-110 TO aPos[1,3],aPos[1,4]-55 LABEL "" OF oDlg PIXEL  //valores

@ aPos[1,1]+005,aPos[1,2]+007 SAY   STR0002  SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE  //Data Inicial
@ aPos[1,1]+005,aPos[1,2]+037 MSGET oDataIni VAR dDataIni PICTURE "@D" VALID FS_VALDATA(1) SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+005,aPos[1,2]+100 SAY   STR0003  SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE 	//Data Final
@ aPos[1,1]+005,aPos[1,2]+127 MSGET oDataFin VAR dDataFin PICTURE "@D" VALID FS_VALDATA(2) SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLUE
@ aPos[1,1]+016,aPos[1,2]+007 SAY   STR0004  SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE   //Orcamento
@ aPos[1,1]+016,aPos[1,2]+037 MSGET oOrcam VAR cOrcam PICTURE "@!" F3 "VPJ" VALID FS_ORCAM() SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLUE

If VPJ->(FieldPos("VPJ_NOMCLI")) <> 0
	@ aPos[1,1]+016,aPos[1,2]+100 SAY   STR0026 SIZE 100,08 OF oDlg PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+016,aPos[1,2]+127 MSGET oNomCli VAR cNomcli PICTURE "@!" F3 "VSA1"  SIZE 135,08 OF oDlg PIXEL COLOR CLR_BLUE
EndIf

@ aPos[1,1]+007,aPos[1,4]-107 BUTTON oPesq PROMPT STR0005 OF oDlg SIZE 48,10 PIXEL ACTION FS_PESQUISAR(1) //  <<< Pesquisar >>>
@ aPos[1,1]+002,aPos[1,4]-052 BUTTON oImpr PROMPT STR0006 OF oDlg SIZE 48,10 PIXEL ACTION FS_IMPRIMIR() // <<IMPRIMIR>>
@ aPos[1,1]+014,aPos[1,4]-052 BUTTON oSair PROMPT STR0007 OF oDlg SIZE 48,10 PIXEL ACTION oDlg:End() // <<< SAIR >>>

@ aPos[3,1]+005,aPos[1,4]-300 SAY STR0035+ " - " +transform(nSoma,"@E 999,999,999.99")  SIZE 70,08 OF oDlg PIXEL COLOR CLR_RED   //Soma Pecas:
@ aPos[3,1]+005,aPos[1,4]-200 SAY STR0034+ " - " +transform(nSomSer,"@E 999,999,999.99")  SIZE 70,08 OF oDlg PIXEL COLOR CLR_RED  //Soma Servico:
@ aPos[3,1]+005,aPos[1,4]-100 SAY STR0036+ " - " +transform(nSoma+nSomSer,"@E 999,999,999.99")  SIZE 70,08 OF oDlg PIXEL COLOR CLR_RED  //Soma Servico:

@ 001,aPos[2,2]+002 LISTBOX oLbx1 FIELDS HEADER STR0004,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0027,STR0010 COLSIZES 40,40,30,30,45,30,40,100,100 SIZE aPos[2,4]-008,aPos[2,3]-aPos[1,3]-017 OF oFolder:aDialogs[1] oDlg PIXEL  //Orcamento ### Dta Cancel. ### Hra Cancel. ### Grupo ### Codigo do item ### Qtdade ### Valor ### Motivo
oLbx1:SetArray(aItens)
oLbx1:bLine := { || {  aItens[oLbx1:nAt,1],;
						transform(aItens[oLbx1:nAt,2],"@D"),;
						transform(aItens[oLbx1:nAt,3],"99:99"),;
						aItens[oLbx1:nAt,4],;
						aItens[oLbx1:nAt,5],;
						transform(aItens[oLbx1:nAt,6],"99999"),;
						transform(aItens[oLbx1:nAt,7],"@E 999,999,999.99"),;
						aItens[oLbx1:nAt,9],;
						aItens[oLbx1:nAt,8]}}

@ 001,aPos[2,2]+002 LISTBOX oLbx2 FIELDS HEADER  STR0004,STR0011,STR0012,STR0028,STR0029,STR0030,STR0016,STR0027,STR0010 COLSIZES 40,40,30,30,45,30,40,100,100 SIZE aPos[2,4]-008,aPos[2,3]-aPos[1,3]-017 OF oFolder:aDialogs[2] oDlg PIXEL  //Orcamento ### Dta Cancel. ### Hra Cancel. ### Grupo ### Codigo do item ### Qtdade ### Valor ### Motivo
oLbx2:SetArray(aSrv)
oLbx2:bLine := { || {  aSrv[oLbx2:nAt,1],;
						transform(aSrv[oLbx2:nAt,2],"@D"),;
						transform(aSrv[oLbx2:nAt,3],"99:99"),;
						aSrv[oLbx2:nAt,4],;
						aSrv[oLbx2:nAt,5],;
						aSrv[oLbx2:nAt,6],;
						transform(aSrv[oLbx2:nAt,7],"@E 999,999,999.99"),;
						aSrv[oLbx2:nAt,9],;
						aSrv[oLbx2:nAt,8]}}
						oLbx1:Refresh()
						oLbx2:Refresh()
ACTIVATE MSDIALOG oDlg

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQUISAR³ Autor ³ Thiago Aprile       ³ Data ³02/04/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa/Levanta VPJ                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQUISAR(nTp)
Local cAliasVPJ := "SQLVPJ"
Local cAliasVPM := "SQLVPM"
If Empty(dDataFin)
	dDataFin := dDataBase
EndIf
aItens := {}
aSrv   := {}
nQtd   := 0
nSoma  := 0
nSomaS := 0
cQuery := "SELECT * FROM " + RetSqlName( "VPJ" ) + " VPJ WHERE "
cQuery += "VPJ.VPJ_FILIAL='"+ xFilial("VPJ")+ "' AND VPJ.VPJ_DATCAN >= '"+dtos(dDataIni)+"' AND VPJ.VPJ_DATCAN <= '"+dtos(dDataFin)+"' AND "
If !Empty(cOrcam)
	cQuery += "VPJ.VPJ_NUMORC = '"+cOrcam+"' AND "
Endif
If !Empty(cNomcli) .and. VPJ->(fieldPos("VPJ_NOMCLI")) <> 0
	cQuery += "VPJ.VPJ_NOMCLI LIKE '%"+alltrim(cNomcli)+"%' AND "
Endif
cQuery += "VPJ.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVPJ, .T., .T. )
Do While !( cAliasVPJ )->( Eof() )
	if Len(aItens) == 1 .and. Empty(aItens[1,1])
		aItens := {}
	Endif
	If VPJ->(fieldPos("VPJ_NOMCLI")) <> 0
		aadd(aItens,{( cAliasVPJ )->VPJ_NUMORC,stod(( cAliasVPJ )->VPJ_DATCAN),( cAliasVPJ )->VPJ_HORCAN,( cAliasVPJ )->VPJ_GRUITE,( cAliasVPJ )->VPJ_CODITE,( cAliasVPJ )->VPJ_QTDITE,( cAliasVPJ )->VPJ_VALTOT,( cAliasVPJ )->VPJ_MOTIVO,( cAliasVPJ )->VPJ_NOMCLI})
	Else
		aadd(aItens,{( cAliasVPJ )->VPJ_NUMORC,stod(( cAliasVPJ )->VPJ_DATCAN),( cAliasVPJ )->VPJ_HORCAN,( cAliasVPJ )->VPJ_GRUITE,( cAliasVPJ )->VPJ_CODITE,( cAliasVPJ )->VPJ_QTDITE,( cAliasVPJ )->VPJ_VALTOT,( cAliasVPJ )->VPJ_MOTIVO, cNomcli})
	EndIf
	nQtd += ( cAliasVPJ )->VPJ_QTDITE
	nSoma += ( cAliasVPJ )->VPJ_VALTOT
	dbSelectArea(cAliasVPJ)
	dbSkip()
Enddo
( cAliasVPJ )->( dbCloseArea() )
if Len(aItens) == 0 .or. (Len(aItens) == 1 .and. Empty(aItens[1,1]))
	aItens := {{"",CtoD(""),0,"","",0,0,"",""}}
Endif
If nTp <> 0
	oLbx1:nAt := 1
	oLbx1:SetArray(aItens)
	oLbx1:bLine := { || {  aItens[oLbx1:nAt,1],;
	transform(aItens[oLbx1:nAt,2],"@D"),;
	transform(aItens[oLbx1:nAt,3],"99:99"),;
	aItens[oLbx1:nAt,4],;
	aItens[oLbx1:nAt,5],;
	transform(aItens[oLbx1:nAt,6],"99999"),;
	transform(aItens[oLbx1:nAt,7],"@E 999,999,999.99"),;
	aItens[oLbx1:nAt,9],;
	aItens[oLbx1:nAt,8]}}
	oLbx1:Refresh()
EndIf
cQuery := "SELECT * FROM " + RetSqlName( "VPM" ) + " VPM WHERE "
cQuery += "VPM.VPM_FILIAL='"+ xFilial("VPM")+ "' AND VPM.VPM_DATCAN >= '"+dtos(dDataIni)+"' AND VPM.VPM_DATCAN <= '"+dtos(dDataFin)+"' AND "
If !Empty(cOrcam)
	cQuery += "VPM.VPM_NUMORC = '"+cOrcam+"' AND "
Endif
If !Empty(cNomcli) .and. VPM->(fieldPos("VPM_NOMCLI")) <> 0
	cQuery += "VPM.VPM_NOMCLI LIKE '%"+alltrim(cNomcli)+"%' AND "
Endif
cQuery += "VPM.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVPM, .T., .T. )
nQtdSer := 0
nSomSer := 0
Do While !( cAliasVPM )->( Eof() )
	if Len(aSrv) == 1 .and. Empty(aSrv[1,1])
		aSrv := {}
	Endif
	If VPM->(fieldPos("VPM_NOMCLI")) <> 0
		aadd(aSrv,{( cAliasVPM )->VPM_NUMORC,stod(( cAliasVPM )->VPM_DATCAN),( cAliasVPM )->VPM_HORCAN,( cAliasVPM )->VPM_GRUSER,( cAliasVPM )->VPM_CODSER,( cAliasVPM )->VPM_TIPSER,( cAliasVPM )->VPM_VALVEN,( cAliasVPM )->VPM_MOTIVO,( cAliasVPM )->VPM_NOMCLI})
	Else
		aadd(aSrv,{( cAliasVPM )->VPM_NUMORC,stod(( cAliasVPM )->VPM_DATCAN),( cAliasVPM )->VPM_HORCAN,( cAliasVPM )->VPM_GRUSER,( cAliasVPM )->VPM_CODSER,( cAliasVPM )->VPM_TIPSER,( cAliasVPM )->VPM_VALVEN,( cAliasVPM )->VPM_MOTIVO, cNomcli})
	EndIf
	nQtdSer += 1
	nSomSer += ( cAliasVPM )->VPM_VALVEN
	dbSelectArea(cAliasVPM)
	dbSkip()
Enddo
( cAliasVPM )->( dbCloseArea() )
if Len(aSrv) == 0 .or. (Len(aSrv) == 1 .and. Empty(aSrv[1,1]))
	aSrv := {{"",CtoD(""),0,"","",0,0,"",""}}
Endif
if (Len(aSrv) == 0 .or. (Len(aSrv) == 1 .and. Empty(aSrv[1,1]))) .and. (Len(aItens) == 0 .or. (Len(aItens) == 1 .and. Empty(aItens[1,1])))
	MsgInfo(STR0019,STR0020)    //Pesquisa nao encontrada. ### Atencao
Endif
If nTp <> 0
	oLbx2:SetArray(aSrv)
	oLbx2:bLine := { || {  aSrv[oLbx2:nAt,1],;
	transform(aSrv[oLbx2:nAt,2],"@D"),;
	transform(aSrv[oLbx2:nAt,3],"99:99"),;
	aSrv[oLbx2:nAt,4],;
	aSrv[oLbx2:nAt,5],;
	transform(aSrv[oLbx2:nAt,6],"99999"),;
	transform(aSrv[oLbx2:nAt,7],"@E 999,999,999.99"),;
	aSrv[oLbx2:nAt,9],;
	aSrv[oLbx2:nAt,8]}}
	
	oLbx2:Refresh()
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR ³ Autor ³ Thiago Aprile       ³ Data ³02/04/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do VPJ (Itens cortados no Orcamento)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local i         := 0
Local y := 0
Local z := 0
Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private aVetor := {}
Private cTamanho:= "M"           // P/M/G
Private Limite  := 132           // 80/132/220
Private cTitulo := STR0021  //Itens cortados do orcamento pelo cliente
Private cNomProg:= "OFIOC360"
Private cNomeRel:= "OFIOC360"
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


aSort(aItens,1,,{|x,y| x[1] < y[1]})
cNumOrc := "INICIO"
cPecSer := "INICIO"
nTotQTd := 0
nTotGer := 0
nTotGerS:= 0
nValGer := 0
nValGerS:= 0
nValTot := 0
nTotQTdS := 0
nTotGerS := 0
nValTotS := 0
nQtdTotS := 0
nValGerS := 0
For y := 1 to Len(aItens)
	aadd(aVetor,{aItens[y,1],aItens[y,2],aItens[y,3],aItens[y,4],aItens[y,5],aItens[y,6],aItens[y,7],aItens[y,8],aItens[y,9],"P"})
Next
if !(Len(aSrv) == 1 .and. Empty(aSrv[1,1]))
	For z := 1 to Len(aSrv)
		aadd(aVetor,{ aSrv[z,1],aSrv[z,2],aSrv[z,3],aSrv[z,4],aSrv[z,5],aSrv[z,6],aSrv[z,7],aSrv[z,8],aSrv[z,9],"S"})
	Next
Endif
aSort(aVetor,,,{|x,y| x[1]+x[10] < y[1]+y[10]})
For i := 1 to Len(aVetor)
	if cNumOrc <> aVetor[i,1]
		if cNumOrc <> "INICIO"
			if cPecSer == "P"
				@nLin++, 022 pSay STR0022+transform(nTotQTd,"9999")+" "+transform(nValTot,"@E 999,999,999.99")//Total Orcamento:  -    Qtd Itens:
			Else
				@nLin++, 022 pSay STR0032+"     "+transform(nValTot,"@E 999,999,999.99")//Total Orcamento:  -    Qtd Itens:
			Endif
			nLin++
			nTotQTd := 0
			nValTot := 0
			nValTotS := 0
			nQtdTotS := 0
		Endif
		@nLin++, 001 pSay STR0023+aVetor[i,1]   //Nro Orcamento:  -
		nLin++
		if aVetor[i,10] == "P"
			@nLin++, 005 pSay STR0043 // Orcamento de Pecas
			nLin++
			@nLin++, 005 pSay STR0024 // Data     Hora  Grp  Codigo do Item                Qtd      Valor Motivo
		Else
			@nLin++, 005 pSay STR0044 // Orcamento de Servicos
			nLin++
			@nLin++, 005 pSay STR0031 // Data     Hora  Grp  Codigo do Servico             Tp Servico    Valor Motivo
		Endif
	Endif
	if aVetor[i,10] == "P"
		nTotQTd += aVetor[i,6]
		nTotGer += aVetor[i,6]
		nValTot += aVetor[i,7]
		nValGer += aVetor[i,7]
		cNumOrc := aVetor[i,1]
		cPecSer := aVetor[i,10]
		@nLin++, 005 pSay left(transform(aVetor[i,2],"@D")+space(10),10)+" "+transform(aVetor[i,3],"@E 99:99")+" "+aVetor[i,4]+" "+aVetor[i,5]+" "+transform(aVetor[i,6],"99999")+" "+transform(aVetor[i,7],"@E 999,999,999.99")+" "+aVetor[i,8]
	Else
		nValTotS += aVetor[i,7]
		nQtdTotS += 1
		nTotGerS += 1
		nValGerS += aVetor[i,7]
		cNumOrc  := aVetor[i,1]
		@nLin++, 005 pSay left(transform(aVetor[i,2],"@D")+space(10),10)+" "+transform(aVetor[i,3],"@E 99:99")+" "+aVetor[i,4]+"   "+aVetor[i,5]+"       "+aVetor[i,6]+"          "+transform(aVetor[i,7],"@E 999,999,999.99")+" "+aVetor[i,8]
	Endif
Next
nLin++
if aVetor[Len(aVetor),10] == "P"
	@nLin++, 022 pSay STR0022+transform(nTotQTd,"9999")+"     "+transform(nValTot,"@E 999,999,999.99") //Total Orcamento:  -    Qtd Itens:
Else
	@nLin++, 022 pSay STR0032+transform(nQtdTotS,"9999")+" "+transform(nValTotS,"@E 999,999,999.99") //Total Orcamento:  -    Qtd Itens:
Endif
nLin++
@nLin++, 020 pSay STR0025+transform(nTotGer,"9999")+" "+transform(nValGer,"@E 999,999,999.99") //TOTAL GERAL       -    Qtd Itens:
@nLin++, 020 pSay STR0033+transform(nTotGerS,"9999")+" "+transform(nValGerS,"@E 999,999,999.99") //TOTAL GERAL       -    Qtd Itens:

Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ORCAM   ³ Autor ³ Thiago Aprile       ³ Data ³02/04/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega o nro do Orcamento com 8 posicoes (strzero)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORCAM()
if !Empty(cOrcam)
	if Len(Alltrim(cOrcam)) < 8
		cOrcam := strzero(val(cOrcam),8)
	Endif
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_AtuSXB  ³ Autor ³ Thiago Aprile       ³ Data ³02/04/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria consulta padrao SXB                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AtuSXB()

Local aEstrSXB := { "XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM" }
Local aSXB     := {}
Local ni       := 0
Local nj       := 0
Local aArea	   := GetArea()

aEstrut := {'XB_ALIAS','XB_TIPO','XB_SEQ','XB_COLUNA','XB_DESCRI','XB_DESCSPA','XB_DESCENG','XB_CONTEM','XB_WCONTEM'}

Aadd(aSXB,{'VSA1','1','01','DB',STR0026,STR0026,STR0026,'SA1',''})
Aadd(aSXB,{'VSA1','2','01','01',STR0039,STR0039,STR0039,'',''})
Aadd(aSXB,{'VSA1','2','02','02',STR0027,STR0027,STR0027,'',''})
Aadd(aSXB,{'VSA1','2','03','03',STR0041,STR0041,STR0041,'',''})
Aadd(aSXB,{'VSA1','3','01','01',STR0042,STR0042,STR0042,'01',''})
Aadd(aSXB,{'VSA1','4','01','01',STR0039,STR0039,STR0039,'A1_COD',''})
Aadd(aSXB,{'VSA1','4','01','02',STR0040,STR0040,STR0040,'A1_LOJA',''})
Aadd(aSXB,{'VSA1','4','01','03',STR0027,STR0027,STR0027,'Substr(A1_NOME,1,30)',''})
Aadd(aSXB,{'VSA1','4','02','01',STR0039,STR0039,STR0039,'A1_COD',''})
Aadd(aSXB,{'VSA1','4','02','02',STR0040,STR0040,STR0040,'A1_LOJA',''})
Aadd(aSXB,{'VSA1','4','02','03',STR0027,STR0027,STR0027,'Substr(A1_NOME,1,30)',''})
Aadd(aSXB,{'VSA1','4','03','01',STR0041,STR0041,STR0041,'A1_CGC',''})
Aadd(aSXB,{'VSA1','4','03','02',STR0027,STR0027,STR0027,'Substr(A1_NOME,1,30)',''})
Aadd(aSXB,{'VSA1','5','01','  ','     ','     ','     ','SA1->A1_NOME',''})

dbSelectArea("SXB")
dbSetOrder(1)
For ni:= 1 To Len(aSXB)
	DbSeek(Left(aSXB[ni,1]+SPACE(10),len(SXB->XB_ALIAS))+aSXB[ni,2]+aSXB[ni,3]+aSXB[ni,4])
	RecLock("SXB",!Found())
	For nj:=1 To Len(aSXB[ni])
		If ( FieldPos(aEstrSXB[nj])>0 .and. aSXB[ni,nj] # NIL )
			FieldPut(FieldPos(aEstrSXB[nj]),aSXB[ni,nj])
		EndIf
	Next nj
	dbCommit()
	MsUnLock()
Next ni

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALDATA ³ Autor ³ Thiago Aprile       ³ Data ³02/04/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida digitacao da Data Inicial e Data Final              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALDATA(nTp)
Local lRet := .t.
If nTp == 1 // Data Inicial
	if !Empty(dDataFin) .and. dDataIni > dDataFin
		MsgStop(STR0037,STR0020) // Data Inicial invalida! / Atencao
		dDataIni := CtoD("")
		lRet := .f.
	Endif
Else // nTp == 2 // Data Final
	if !Empty(dDataini) .and. dDataFin < dDataIni
		MsgStop(STR0038,STR0020) // Data Final invalida / Atencao
		dDataIni := CtoD("")
		dDataFin := CtoD("")
		lRet := .f.
	Endif
EndIf
Return(lRet)