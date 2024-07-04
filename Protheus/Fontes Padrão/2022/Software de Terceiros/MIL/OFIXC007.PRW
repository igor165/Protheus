// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 05     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIXC007.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ OFIXC007 ³ Autor ³ Thiago                ³ Data ³ 05/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ CONSULTA/IMPRESSAO DAS LIBERACOES DE CREDITO. 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXC007(lNoBrowse)
Private aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}//
Private cCliente := space(TamSX3("A1_COD")[1])
Private cLoja := space(TamSX3("A1_LOJA")[1])
Private cNome := space(TamSX3("A1_NOME")[1])
Private cNroOrc := space(TamSX3("VSW_NUMORC")[1])
Private cDtLib := stod("  /  /  ")
Private cUsuLib := space(TamSX3("VSW_USULIB")[1])
Private aLibera := {{"","","",0,"","","","","",""}}
Private aRotina := MenuDef()

Default lNoBrowse := .f.

If !lNoBrowse
	dbSelectArea("VSW")
	mBrowse( 6, 1,22,75,"VSW",,,,,,)
Else
	OXC007C() // Chamar a consulta direto (sem browser)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ OXC007C  ³ Autor ³ Thiago                ³ Data ³ 05/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ CONSULTA DAS LIBERACOES DE CREDITO. 	  				       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXC007C()
Local nCntFor := 0
Private aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private nTam :=0 //controla posicao da legenda na tela

cNroOrc := VSW->VSW_NUMORC
FS_FILTRAR("1")


// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 000, 055 , .T. , .F. } )//cabecalho
AAdd( aObjects, { 000, 000 , .T. , .T. } )//listbox

// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.85)
Next
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oOxc007 TITLE STR0005 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

@  aPos[1,1],aPos[1,2] TO aPos[1,3],aPos[1,4]-80 LABEL STR0006 OF oOxc007 PIXEL

@ aPos[1,1]+011,aPos[1,2]+003 SAY STR0029 OF oOxc007   PIXEL COLOR CLR_BLUE
@ aPos[1,1]+011,aPos[1,2]+043 MSGET oNroOrc VAR cNroOrc PICTURE "@!" VALID FS_NOME() F3 "VSWORC" SIZE 60,8 OF oOxc007 PIXEL COLOR CLR_BLUE

@ aPos[1,1]+024,aPos[1,2]+003 SAY STR0008 OF oOxc007   PIXEL COLOR CLR_BLUE
@ aPos[1,1]+024,aPos[1,2]+043 MSGET oCliente VAR cCliente PICTURE "@!" VALID FS_NOME() F3 "SA1" SIZE 60,8 OF oOxc007 PIXEL COLOR CLR_BLUE

@ aPos[1,1]+024,aPos[1,2]+110 SAY STR0009 OF oOxc007   PIXEL COLOR CLR_BLUE
@ aPos[1,1]+024,aPos[1,2]+125 MSGET oLoja VAR cLoja PICTURE "@!" VALID FS_LOJA() SIZE 20,8 OF oOxc007 PIXEL COLOR CLR_BLUE

@ aPos[1,1]+024,aPos[1,2]+148 SAY STR0010 OF oOxc007   PIXEL COLOR CLR_BLUE
@ aPos[1,1]+024,aPos[1,2]+165 MSGET oNome VAR cNome PICTURE "@!" SIZE 100,8 OF oOxc007 PIXEL COLOR CLR_BLUE When .f.

@ aPos[1,1]+037,aPos[1,2]+003 SAY STR0011 OF oOxc007   PIXEL COLOR CLR_BLUE
@ aPos[1,1]+037,aPos[1,2]+043 MSGET oDtLib VAR cDtLib PICTURE "@!" SIZE 60,8 OF oOxc007 PIXEL COLOR CLR_BLUE

@ aPos[1,1]+037,aPos[1,2]+110 SAY STR0012 OF oOxc007   PIXEL COLOR CLR_BLUE
@ aPos[1,1]+037,aPos[1,2]+165 MSGET oUsuLib VAR cUsuLib PICTURE "@!" SIZE 100,8 OF oOxc007 PIXEL COLOR CLR_BLUE


@  aPos[1,1],aPos[1,4]-79 TO aPos[1,3],aPos[1,4] LABEL STR0013 OF oOxc007 PIXEL

@ aPos[1,1]+024,aPos[1,2]+270 BUTTON oFilt     PROMPT OemToAnsi(STR0014)      OF oOxc007 SIZE 45,10 PIXEL ACTION ( FS_FILTRAR("2") )

@ aPos[1,1]+011,aPos[1,4]-75 BUTTON oImpr      PROMPT OemToAnsi(STR0015)      OF oOxc007 SIZE 65,10 PIXEL ACTION ( FS_IMPRIMIR() )
@ aPos[1,1]+024,aPos[1,4]-75 BUTTON oSair      PROMPT OemToAnsi(STR0016)      OF oOxc007 SIZE 65,10 PIXEL ACTION ( oOxc007:End() )

@ aPos[2,1],aPos[2,2]  LISTBOX oLbox FIELDS HEADER STR0017, STR0018, STR0019,STR0020,STR0021,STR0022,STR0023,STR0024,STR0025,STR0026 COLSIZES 40,30,40,40,30,20,80,40,40,340 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1]-2 OF oOxc007 PIXEL
oLbox:SetArray(aLibera)
oLbox:bLine := { || { aLibera[oLbox:nAt,01],;
aLibera[oLbox:nAt,02],;
aLibera[oLbox:nAt,03],;
transform(aLibera[oLbox:nAt,04],"@E 9999,999.99"),;
aLibera[oLbox:nAt,05],;
aLibera[oLbox:nAt,06],;
aLibera[oLbox:nAt,07],;
aLibera[oLbox:nAt,08],;
aLibera[oLbox:nAt,09],;
aLibera[oLbox:nAt,10]}}

ACTIVATE MSDIALOG oOxc007 CENTER

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³FS_FILTRAR³ Autor ³ Thiago                ³ Data ³ 05/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Filtrar registros.							 		       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(cOpcao)
Local cAliasVSW  := "SQLVSW"
Local cQuery     := ""

cQuery := "SELECT VSW.VSW_NUMORC,VSW.VSW_DATHOR,VSW.VSW_USUARI,VSW.VSW_VALCRE,VSW.VSW_CODCLI,VSW.VSW_LOJA,VSW.VSW_DTHLIB,VSW.VSW_USULIB,VSW.VSW_MOTIVO "
cQuery += "FROM "
cQuery += RetSqlName( "VSW" ) + " VSW "
cQuery += "WHERE "
cQuery += "VSW.VSW_FILIAL='"+ xFilial("VSW")+ "' AND "
if !Empty(cNroOrc)
	cQuery += "VSW.VSW_NUMORC = '"+cNroOrc+"' AND "
Endif
if !Empty(cCliente)
	cQuery += "VSW.VSW_CODCLI = '"+cCliente+"' AND "
Endif
if !Empty(cLoja)
	cQuery += "VSW.VSW_LOJA = '"+cLoja+"' AND "
Endif
if !Empty(cDtLib)
	cQuery += "( VSW.VSW_DTHLIB LIKE '"+Left(Dtoc(cDtLib),6)+Right(STR(Year(cDtLib),4),2)+"%' OR"
	cQuery += " VSW.VSW_DTHLIB LIKE '"+Left(Dtoc(cDtLib),6)+STR(Year(cDtLib),4)+"%') AND "
Endif
if !Empty(cUsuLib)
	cQuery += "UPPER(VSW.VSW_USULIB) LIKE '"+Alltrim(cUsuLib)+"%' AND "
Endif
cQuery += "VSW.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVSW, .T., .T. )

aLibera := {{"","","",0,"","","","","",""}}

Do While !( cAliasVSW )->( Eof() )
	if Empty(aLibera[1,2])
		aLibera := {}
	Endif
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+( cAliasVSW )->VSW_CODCLI+( cAliasVSW )->VSW_LOJA)
	
	aAdd(aLibera,{( cAliasVSW )->VSW_NUMORC,( cAliasVSW )->VSW_DATHOR,( cAliasVSW )->VSW_USUARI,( cAliasVSW )->VSW_VALCRE,( cAliasVSW )->VSW_CODCLI,( cAliasVSW )->VSW_LOJA,SA1->A1_NOME,( cAliasVSW )->VSW_DTHLIB,( cAliasVSW )->VSW_USULIB,( cAliasVSW )->VSW_MOTIVO})
	dbSelectArea(cAliasVSW)
	( cAliasVSW )->(dbSkip())
	
Enddo
( cAliasVSW )->( dbCloseArea() )
if cOpcao == "2"
	oLbox:nAt := 1
	oLbox:SetArray(aLibera)
	oLbox:bLine := { || { aLibera[oLbox:nAt,01],;
	aLibera[oLbox:nAt,02],;
	aLibera[oLbox:nAt,03],;
	transform(aLibera[oLbox:nAt,04],"@E 9999,999.99"),;
	aLibera[oLbox:nAt,05],;
	aLibera[oLbox:nAt,06],;
	aLibera[oLbox:nAt,07],;
	aLibera[oLbox:nAt,08],;
	aLibera[oLbox:nAt,09],;
	aLibera[oLbox:nAt,10]}}
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³FS_IMPRIMIR³ Autor ³ Thiago                ³ Data ³ 05/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Impressao.					    				 		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß±ßßßßßßßßß
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
Private cTamanho:= "G"           // P/M/G
Private Limite  := 220           // 80/132/220
Private cTitulo := STR0027
Private cNomProg:= "OFIXC007"
Private cNomeRel:= "OFIXC007"
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

@nLin++, 000 pSay STR0028
For i := 1 to Len(aLibera)
	@nLin++,000 pSay aLibera[i,1]+"   "+aLibera[i,2]+" "+aLibera[i,3]+" "+transform(aLibera[i,4],"@E 999,999,999.99")+"  "+aLibera[i,5]+"   "+aLibera[i,6]+" "+aLibera[i,7]+"   "+aLibera[i,8]+" "+aLibera[i,9]+"    "+aLibera[i,10]
	if nLin > 60
		nLin := 1
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
	Endif
Next

Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³FS_NOME	 ³ Autor ³ Thiago                ³ Data ³ 05/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao do campo nome.	        				 		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß±ßßßßßßßßß
*/
Static Function FS_NOME()

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+cCliente+cLoja)
cNome := SA1->A1_NOME
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³FS_LOJA	 ³ Autor ³ Thiago                ³ Data ³ 05/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Validacao do campo loja.	        				 		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Oficina                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß±ßßßßßßßßß
*/
Static Function FS_LOJA()

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+cCliente+cLoja)
cNome := SA1->A1_NOME
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Thiago ³ 							  Data ³ 22/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) 								                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ STR0031, "axPesqui",    0, 1},;    // "Pesquisar"
{ STR0030, "OXC007C"  , 0, 2}}    // "Consulta"
Return aRotina
