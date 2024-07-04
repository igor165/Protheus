// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 30     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "OFIOC160.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ OFIOC160 ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Consulta da Nota Fiscal                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC160(cImp)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local OXvermelho
Local OXverde
Private nAutoAdt := 0
Private overde   := LoadBitmap( GetResources(), "BR_verde")
Private overmelho:= LoadBitmap( GetResources(), "BR_vermelho")
Private cCadastro:= OemToAnsi(STR0001)
Private cTipAva  := "2"
Private aErrAva  := {}
Private cTipoNF  := ""
Private aTipNF   := {}
Private cTipNF   := ""
Private nQtdNFV  := 0
Private nQtdNFC  := 0
Private dDtI := dDataBase
Private dDtF := dDataBase
Private cNF  := Space(TamSX3("F2_DOC")[1])
Private cSer := Space(TamSX3("F2_SERIE")[1])
Private cCli := Space(TamSX3("A1_COD")[1])
Private cLoj := Space(TamSX3("A1_LOJA")[1])
Private cNom := Space(TamSX3("A1_NOME")[1])
Private aNF  := {}
Private lTem := .t.
Private lImp := If(cImp=="S",.t.,.f.)
Private cPPrefBAL := GetNewPar("MV_PREFBAL","BAL")
Private cPPrefOFI := GetNewPar("MV_PREFOFI","OFI")
Private cPPrefVEI := GetNewPar("MV_PREFVEI","VEI")
Private lUserImpr := .f.
If __CUSERID $ GetNewPar("MV_IMPNFCA","") // Usuarios que podem Imprimir NF Canceladas
	lUserImpr := .t.
EndIf
ALTERA := .f. // 09/04/08 - Andre Luis Almeida -> Atribui para nao dar ERRO no MATA410
INCLUI := .f. // 09/04/08 - Andre Luis Almeida -> Atribui para nao dar ERRO no MATA410

DbSelectArea("SF2")
DbClearFilter()

//nModulo := 11		Codigo do Modulo Veiculos
//nModulo := 14      Codigo do Modulo Oficina
if nModulo == 11
	aTipNF := {OemToAnsi(STR0002)}
	cTipNF := OemToAnsi(STR0002)
Else
	aTipNF := {OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005)}
	cTipNF := OemToAnsi(STR0005)
Endif

Processa( {|| FS_Filtro(1) } )


// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 51 , .T., .F. } ) //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box inferior
//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
//AAdd( aObjects, { 10, 10, .T. , .F. } ) //list box inferior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlgNF TITLE OemtoAnsi(STR0001) From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL //CONSULTA IMPRESSAO DE PRE NOTA

@ aPosObj[1,1]+006,aPosObj[1,2]+006 SAY (STR0017+":") SIZE 40,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+005,aPosObj[1,2]+028 MSCOMBOBOX oTipoNF VAR cTipNF SIZE 50,08 ITEMS aTipNF OF oDlgNF PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+017,aPosObj[1,2]+006 SAY (STR0007+":") SIZE 40,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+016,aPosObj[1,2]+028 MSGET oDtI VAR dDtI PICTURE "@D" SIZE 45,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+017,aPosObj[1,2]+074 SAY STR0008 SIZE 20,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+016,aPosObj[1,2]+084 MSGET oDtF VAR dDtF PICTURE "@D" VALID (dDtF >= dDtI) SIZE 45,08 OF oDlgNF PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+028,aPosObj[1,2]+006 SAY (STR0019+":") SIZE 40,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+027,aPosObj[1,2]+028 MSGET oCli VAR cCli PICTURE PesqPict("SA1","A1_COD") F3 "SA1" VALID FS_VAL_CLI("CLI") SIZE 30,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+027,aPosObj[1,2]+064 MSGET oLoj VAR cLoj PICTURE PesqPict("SA1","A1_LOJA") VALID FS_VAL_CLI("LOJ") SIZE 07,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+028,aPosObj[1,2]+083 SAY cNom SIZE 200,08 OF oDlgNF PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+039,aPosObj[1,2]+006 SAY (STR0016+":") SIZE 40,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+038,aPosObj[1,2]+028 MSGET oNF  VAR cNF  PICTURE PesqPict("SF2","F2_DOC") F3 "SF2" VALID (cSer:=Space(TamSX3("F2_SERIE")[1]),FS_VAL_NF()) SIZE 30,08 OF oDlgNF PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+038,aPosObj[1,2]+073 MSGET oSer VAR cSer PICTURE PesqPict("SF2","F2_SERIE") VALID FS_VAL_NF() SIZE 10,08 OF oDlgNF PIXEL COLOR CLR_BLUE

//@ 038,127 BITMAP OXverde RESOURCE "BR_verde"  OF oDlgNF PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[1,3]-10,aPosObj[1,4]-250 BITMAP OXverde RESOURCE "BR_verde"  OF oDlgNF PIXEL NOBORDER SIZE 10,10 when .f.
//@ 038,138 SAY (Transform(nQtdNFV,"@E 99,999,999")+" "+STR0031) SIZE 80,08 OF oDlgNF PIXEL COLOR CLR_GREEN
@ aPosObj[1,3]-10,aPosObj[1,4]-239 SAY (Transform(nQtdNFV,"@E 99,999,999")+" "+STR0031) SIZE 80,08 OF oDlgNF PIXEL COLOR CLR_GREEN
//@ 038,215 BITMAP OXvermelho RESOURCE "BR_vermelho" OF oDlgNF PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[1,3]-10,aPosObj[1,4]-166 BITMAP OXvermelho RESOURCE "BR_vermelho" OF oDlgNF PIXEL NOBORDER SIZE 10,10 when .f.
//@ 038,226 SAY (Transform(nQtdNFC,"@E 99,999,999")+" "+STR0032) SIZE 80,08 OF oDlgNF PIXEL COLOR CLR_RED
@ aPosObj[1,3]-10,aPosObj[1,4]-155 SAY (Transform(nQtdNFC,"@E 99,999,999")+" "+STR0032) SIZE 80,08 OF oDlgNF PIXEL COLOR CLR_RED

//@ 002,002 TO 048,297 LABEL "" OF oDlgNF PIXEL
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-83 LABEL "" OF oDlgNF PIXEL
//@ 035,114 TO 048,297 LABEL "" OF oDlgNF PIXEL
@ aPosObj[1,3]-15,aPosObj[1,4]-260 TO aPosObj[1,3],aPosObj[1,4]-83 LABEL "" OF oDlgNF PIXEL

@ aPosObj[1,1]+002,aPosObj[1,4]-152 BUTTON oFiltro    PROMPT OemToAnsi(STR0012) OF oDlgNF SIZE 65,10 PIXEL ACTION ( Processa( {|| FS_Filtro(2) } ) , oNFLx:SetFocus() )
@ aPosObj[1,1]+002,aPosObj[1,4]-079 BUTTON oSair      PROMPT OemToAnsi(STR0013) OF oDlgNF SIZE 77,10 PIXEL ACTION ( oDlgNF:End() )
@ aPosObj[1,1]+014,aPosObj[1,4]-079 BUTTON oConsultar PROMPT OemToAnsi(STR0014) OF oDlgNF SIZE 77,10 PIXEL ACTION ( FS_ConsImp(aNF[oNFLx:nAt,1]+aNF[oNFLx:nAt,2],2,aNF[oNFLx:nAt,8]) ) WHEN lTem // .and. aNF[oNFLx:nAt,8]
@ aPosObj[1,1]+026,aPosObj[1,4]-079 BUTTON oImprimir  PROMPT OemToAnsi(STR0015) OF oDlgNF SIZE 77,10 PIXEL ACTION ( FS_ConsImp(aNF[oNFLx:nAt,1]+aNF[oNFLx:nAt,2],If(lImp,3,4),aNF[oNFLx:nAt,8]) ) WHEN lTem // .and. aNF[oNFLx:nAt,8]
@ aPosObj[1,1]+038,aPosObj[1,4]-079 BUTTON oImpRelac  PROMPT OemToAnsi(STR0030) OF oDlgNF SIZE 77,10 PIXEL ACTION ( FS_ConsImp(aNF[oNFLx:nAt,1]+aNF[oNFLx:nAt,2],10,aNF[oNFLx:nAt,8]) ) WHEN lTem

@ aPosObj[2,1]+002,aPosObj[2,2]  LISTBOX oNFLx FIELDS HEADER "",STR0016,STR0017,STR0007,STR0019+"/"+STR0043,STR0020,STR0021 COLSIZES 10,45,25,35,135,32,60 SIZE aPosObj[2,4] - aPosObj[2,2], aPosObj[2,3] - aPosObj[2,1]-2 OF oDlgNF PIXEL
oNFLx:SetArray(aNF)
oNFLx:bLine := { || {If(aNF[oNFLx:nAt,8],overde,overmelho),;
aNF[oNFLx:nAt,1]+" "+aNF[oNFLx:nAt,2],;
aNF[oNFLx:nAt,3],;
aNF[oNFLx:nAt,4],;
aNF[oNFLx:nAt,5],;
aNF[oNFLx:nAt,6],;
aNF[oNFLx:nAt,7]}}

ACTIVATE MSDIALOG oDlgNF

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VAL_CLI³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Valida cliente		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL_CLI(cT)
Local lRet := .f.
cNom := space(200)
If cT == "CLI" .and. Empty(cCli)
	cLoj := Space(TamSX3("A1_LOJA")[1])
	lRet := .t.
EndIf
If !Empty(Alltrim(cCli+cLoj))
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek( xFilial("SA1") + cCli + cLoj )
		If DbSeek( xFilial("SA1") + cCli  )
			lRet := .t.
			cLoj := SA1->A1_LOJA
			cNom := SA1->A1_NOME
		EndIf
	Else
		lRet := .t.
	EndIf
Else
	lRet := .t.
EndIf
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VAL_NF ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Valida nota fiscal	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL_NF() 
if !Empty(cNF+cSer)
	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek( xFilial("SF2") + cNF + Alltrim(cSer) )
		cSer := SF2->F2_SERIE
	EndIf
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_Filtro ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Filtro nota fiscal	                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Filtro(nX)
Local cPref := ""
Local cDtOk := "1"
Local cDia  := "1"
Local	cT    := "0"
Local lCond := .t.
Local cQuery  := ""
Local cQueryDel := ""
Local cQAlSF2 := "SQLSF2"
Local cQAlSA1 := "SQLSA1"
Local cQAlSE4 := "SQLSE4"
Local cQAlVS9 := "SQLVS9"
Local cCondDesc := ""
aNF := {}
lTem := .t.
nQtdNFV := 0
nQtdNFC := 0
if nModulo <> 11
	Do Case
		Case cTipNF == STR0003
			cPref := cPPrefBAL
		Case cTipNF == STR0004
			cPref := cPPrefOFI
		Case cTipNF == STR0005
			cPref := "*"
	EndCase
Else
	cPref := cPPrefVEI
Endif
#IFDEF TOP
	cQuery := "SELECT SF2.F2_DOC , SF2.F2_SERIE , SF2.F2_PREFORI , SF2.F2_EMISSAO , SF2.F2_CLIENTE , SF2.F2_LOJA , SF2.F2_DUPL , SF2.F2_COND, SF2.F2_TIPO FROM "+RetSqlName("SF2")+" SF2 WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
	If !Empty(Alltrim(cNF+cSer))
		cQuery += "SF2.F2_DOC='"+cNF+"' AND SF2.F2_SERIE='"+cSer+"' AND "
	EndIf
	If !Empty(Alltrim(cCli+cLoj))
		cQuery += "SF2.F2_CLIENTE='"+cCli+"' AND SF2.F2_LOJA='"+cLoj+"' AND "
	EndIf
	cQuery += "SF2.F2_EMISSAO>='"+dtos(dDtI)+"' AND SF2.F2_EMISSAO<='"+dtos(dDtF)+"' AND "
	If	cPref # "*" // Prefixo Especifico (BAL/OFI/VEI)
		cQuery += "SF2.F2_PREFORI='"+cPref+"' "
	Else // TODOS Prefixos, menos Veiculos
		cQuery += "SF2.F2_PREFORI<>'"+cPPrefVEI+"' "
	EndIf
	cQueryDel := cQuery + " AND SF2.D_E_L_E_T_<>' '"
	cQuery += " AND SF2.D_E_L_E_T_=' '"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSF2, .F., .T. )
	Do While !( cQAlSF2 )->( Eof() )
		If ( cQAlSF2 )->F2_TIPO $ "BD"
			cQuery := "SELECT SA2.A2_NOME FROM "+RetSqlName("SA2")+" SA2 WHERE SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD='"+( cQAlSF2 )->( F2_CLIENTE )+"' AND SA2.A2_LOJA='"+( cQAlSF2 )->( F2_LOJA )+"' AND SA2.D_E_L_E_T_=' '"
			
		Else
			cQuery := "SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+( cQAlSF2 )->( F2_CLIENTE )+"' AND SA1.A1_LOJA='"+( cQAlSF2 )->( F2_LOJA )+"' AND SA1.D_E_L_E_T_=' '"
			
		Endif
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1, .F., .T. )
		cQuery := "SELECT SE4.E4_DESCRI FROM "+RetSqlName("SE4")+" SE4 WHERE SE4.E4_FILIAL='"+xFilial("SE4")+"' AND SE4.E4_CODIGO='"+( cQAlSF2 )->( F2_COND )+"' AND SE4.D_E_L_E_T_=' '"
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSE4, .F., .T. )
		
		
		cCondDesc := ""
		if nModulo == 11 // Veiculos
			cQuery := "SELECT DISTINCT (VS9.VS9_TIPPAG) FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VS9")+" VS9 WHERE "
			cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_NUMNFI = '"+( cQAlSF2 )->( F2_DOC )+"' AND VV0.VV0_SERNFI = '"+( cQAlSF2 )->( F2_SERIE )+"' AND  "
			cQuery += "VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE = VV0.VV0_NUMTRA AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS9, .F., .T. )
			Do While !( cQAlVS9 )->( Eof() )
				cCondDesc += ( cQAlVS9 )->( VS9_TIPPAG )+" / "
				( cQAlVS9 )->( DbSkip() )
			EndDo
			( cQAlVS9 )->( dbCloseArea() )
		EndIf
		if !Empty(cCondDesc)
			cCondDesc := "( "+Left(cCondDesc,Len(cCondDesc)-3)+" )"
		endif
		
		If ( cQAlSF2 )->F2_TIPO $ "BD"
			Aadd(aNF,{ ( cQAlSF2 )->( F2_DOC ) , ( cQAlSF2 )->( F2_SERIE ) , ( cQAlSF2 )->( F2_PREFORI ) , Transform(stod(( cQAlSF2 )->( F2_EMISSAO )),"@D") , left(STR0043+":"+( cQAlSF2 )->( F2_CLIENTE )+"-"+( cQAlSF2 )->( F2_LOJA )+" "+( cQAlSA1 )->( A2_NOME ),45) , ( cQAlSF2 )->( F2_DUPL ) , ( cQAlSF2 )->( F2_COND )+" - "+Alltrim(( cQAlSE4 )->( E4_DESCRI ))+" "+cCondDesc , .t. } )
		Else
			Aadd(aNF,{ ( cQAlSF2 )->( F2_DOC ) , ( cQAlSF2 )->( F2_SERIE ) , ( cQAlSF2 )->( F2_PREFORI ) , Transform(stod(( cQAlSF2 )->( F2_EMISSAO )),"@D") , left(STR0019+":"+( cQAlSF2 )->( F2_CLIENTE )+"-"+( cQAlSF2 )->( F2_LOJA )+" "+( cQAlSA1 )->( A1_NOME ),45) , ( cQAlSF2 )->( F2_DUPL ) , ( cQAlSF2 )->( F2_COND )+" - "+Alltrim(( cQAlSE4 )->( E4_DESCRI ))+" "+cCondDesc , .t. } )
		Endif
		( cQAlSE4 )->( dbCloseArea() )
		( cQAlSA1 )->( dbCloseArea() )
		nQtdNFV++
		( cQAlSF2 )->( DbSkip() )
	EndDo
	( cQAlSF2 )->( dbCloseArea() )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryDel ), cQAlSF2, .F., .T. )
	Do While !( cQAlSF2 )->( Eof() )
		If ( cQAlSF2 )->F2_TIPO $ "BD"
			cQuery := "SELECT SA2.A2_NOME FROM "+RetSqlName("SA2")+" SA2 WHERE SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD='"+( cQAlSF2 )->( F2_CLIENTE )+"' AND SA2.A2_LOJA='"+( cQAlSF2 )->( F2_LOJA )+"' AND SA2.D_E_L_E_T_=' '"
		Else
			cQuery := "SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+( cQAlSF2 )->( F2_CLIENTE )+"' AND SA1.A1_LOJA='"+( cQAlSF2 )->( F2_LOJA )+"' AND SA1.D_E_L_E_T_=' '"
		Endif
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1, .F., .T. )
		cQuery := "SELECT SE4.E4_DESCRI FROM "+RetSqlName("SE4")+" SE4 WHERE SE4.E4_FILIAL='"+xFilial("SE4")+"' AND SE4.E4_CODIGO='"+( cQAlSF2 )->( F2_COND )+"' AND SE4.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSE4, .F., .T. )
		
		cCondDesc := ""
		if nModulo == 11 // Veiculos
			cQuery := "SELECT DISTINCT (VS9.VS9_TIPPAG) FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VS9")+" VS9 WHERE "
			cQuery += "VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_NUMNFI = '"+( cQAlSF2 )->( F2_DOC )+"' AND VV0.VV0_SERNFI = '"+( cQAlSF2 )->( F2_SERIE )+"' AND  "
			cQuery += "VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE = VV0.VV0_NUMTRA AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS9, .F., .T. )
			Do While !( cQAlVS9 )->( Eof() )
				cCondDesc += ( cQAlVS9 )->( VS9_TIPPAG )+" / "
				( cQAlVS9 )->( DbSkip() )
			EndDo
			( cQAlVS9 )->( dbCloseArea() )
		EndIf
		if !Empty(cCondDesc)
			cCondDesc := "( "+Left(cCondDesc,Len(cCondDesc)-3)+" )"
		endif
		
		If ( cQAlSF2 )->F2_TIPO $ "BD"
			Aadd(aNF,{ ( cQAlSF2 )->( F2_DOC ) , ( cQAlSF2 )->( F2_SERIE ) , ( cQAlSF2 )->( F2_PREFORI ) , Transform(stod(( cQAlSF2 )->( F2_EMISSAO )),"@D") , left(STR0043+":"+( cQAlSF2 )->( F2_CLIENTE )+"-"+( cQAlSF2 )->( F2_LOJA )+" "+( cQAlSA1 )->( A2_NOME ),45) , ( cQAlSF2 )->( F2_DUPL ) , ( cQAlSF2 )->( F2_COND )+" - "+Alltrim(( cQAlSE4 )->( E4_DESCRI ))+" "+cCondDesc , .f. } )
		Else
			Aadd(aNF,{ ( cQAlSF2 )->( F2_DOC ) , ( cQAlSF2 )->( F2_SERIE ) , ( cQAlSF2 )->( F2_PREFORI ) , Transform(stod(( cQAlSF2 )->( F2_EMISSAO )),"@D") , left(STR0019+":"+( cQAlSF2 )->( F2_CLIENTE )+"-"+( cQAlSF2 )->( F2_LOJA )+" "+( cQAlSA1 )->( A1_NOME ),45) , ( cQAlSF2 )->( F2_DUPL ) , ( cQAlSF2 )->( F2_COND )+" - "+Alltrim(( cQAlSE4 )->( E4_DESCRI ))+" "+cCondDesc , .f. } )
		Endif
		( cQAlSE4 )->( dbCloseArea() )
		( cQAlSA1 )->( dbCloseArea() )
		nQtdNFC++
		( cQAlSF2 )->( DbSkip() )
	EndDo
	( cQAlSF2 )->( dbCloseArea() )
#ENDIF
If len(aNF) == 0
	lTem := .f.
	Aadd(aNF,{ " " , " " , " " , " " , " " , " " , " " , .f. } )
Else
	aSort(aNF,1,,{|x,y| x[1] > y[1] })
EndIf
If nX # 1
	oNFLx:nAt := 1
	oNFLx:SetArray(aNF)
	oNFLx:bLine := { || { If(aNF[oNFLx:nAt,8],overde,overmelho),;
	aNF[oNFLx:nAt,1]+" "+aNF[oNFLx:nAt,2],;
	aNF[oNFLx:nAt,3],;
	aNF[oNFLx:nAt,4],;
	aNF[oNFLx:nAt,5],;
	aNF[oNFLx:nAt,6],;
	aNF[oNFLx:nAt,7]}}
	oNFLx:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_ConsImp³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Impressao do relatorio                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ConsImp(cT,nT,lT)
Local oReport

Private cDesc1    := STR0023+"( "+STR0024+" "+substr(cT,1,9)+"-"+substr(cT,10,3)+" )"
Private cDesc2    := ""
Private cDesc3    := ""
Private cAlias    := "SD2"
Private aReturn   := {STR0025,1,STR0026,2,2,1,"",1}
Private nLin      := 0
Private Tamanho  := "G" // P/M/G
Private Limite    := 220 // 80/132/220
Private cTitulo   := STR0023+"( "+STR0024+" "+substr(cT,1,9)+"-"+substr(cT,10,3)+" )"
Private cNomeRel  := "OFIOC160"
Private nLastKey  := 0
Private nCaracter := 15
Private cabec1    := STR0028
Private cabec2    := STR0029
Private lAbortPrint := .f.
Private cbTxt    := Space(10)
Private cbCont   := 0
Private cString  := "SD2"
Private Li       := 220
Private m_Pag    := 1
Private cPerg    := nil
Private cCGC     := ""
Private cNom     := ""
Private cMun     := ""
Private cEst     := ""
Private cNota    := "INICIAL"
Private nTipRel  := nT
If nTipRel <> 10
	If !lT
		Set Delete Off // Utiliza todos os registros ( VALIDOS e DELETADOS )
	EndIf
EndIf
DbSelectArea("SF2")
DbSetOrder(1)
DbSeek( xFilial("SF2") + cT )
If nT < 4
	cTipoNF := "T"
	If nT # 3
		ImpNotaPS(0,nT,2) // Consultar NF
	Else
		If !lT .and. !lUserImpr
			MsgAlert(STR0040+" ('"+__CUSERID+"') "+STR0041,STR0042+" MV_IMPNFCA")  //Usuario # sem permissao para reimprimir NF cancelada! # Atencao
		Else
			ImpNotaPS(0,nT,1) // Imprimir NF
		EndIf
	EndIf
Else // Impressao de NFs Validas
	oReport := ReportDef() // Nesta função nós definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
	oReport:SetLandscape() // Define orientação de página do relatório como paisagem.
	oReport:PrintDialog()  // Essa função serve para disparar a impressão do TReport, ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
EndIf
If nTipRel <> 10
	If !lT
		Set Delete On // Utiliza apenas os registros VALIDOS (nao utiliza os registros DELETADOS)
	EndIf
EndIf
Return()

Static function ReportDef()
Local cDesc := "" 
Local oReport
Local oSection1
Local oSection2

// Variaveis de Impressao
dTR_DtEmis := Ctod("")
cTR_Doc    := ""
cTR_Serie  := ""
cTR_CGCCli := ""
cTR_NomCli := ""
cTR_Vended := ""
cTR_NomVen := ""
nTR_ValBru := 0
nTR_VlrTot := 0
nTR_QtdNFs := 0
cTR_TotQtdVlr := ""
nTR_TotQtdVlr := 0

// Descrição
cDesc := cDesc1

// TReport
oReport := TReport():New(           ;
	cNomeRel,                       ;
	cTitulo,                        ;
	,                               ;
	{|oReport| FS_RELATORIO(oReport)},;
	cDesc)

// Cabeçalho
oSection1 := TRSection():New(oReport, "oCabecDados")

	/*,;
	,,,,,                                           ;
	.f.,                                            ; // lTotalInLine - Imprime as células no formato linha
	.t.,                                            ; // lHeaderPage  - Imprime cabeçalho da seção no topo da página
	.t.,                                            ; // lHeaderBreak - Imprime cabeçalho da seção na quebra de impressão (TRBreak)
	.t.,                                            ; // lPageBreak   - Quebra página após a impressão do totalizador
	.t.,                                            ; // lLineBreak   - Aponta que a impressão da seção quebra linhas no caso das colunas não couberem em uma linha
	 0,                                             ; // nLeftMargin  - Tamanho da margem a esquerda
	.f.,                                            ; // lLineStyle   - Impressão em linhas
	 0,                                             ; // nColSpace    - Espaçamento entre as colunas
	,,,,,,)
	*/

TRCell():New(oSection1, "oDtEmis"    ,, RetTitle("VS1_VLBRNF"), "@D", 12,, {||dTR_DtEmis },,,,) 
TRCell():New(oSection1, "oDoc"       ,, RetTitle("VS1_NUMNFI"), "@!", 12,, {||cTR_Doc    },,,,) 
TRCell():New(oSection1, "oSerie"     ,, RetTitle("VS1_SERNFI"), "@!", 12,, {||cTR_Serie  },,,,) 
TRCell():New(oSection1, "oCGCCli"    ,, RetTitle("A1_CGC"),     "@!", 15,, {||cTR_CGCCli },,,,) 
TRCell():New(oSection1, "oNomCli"    ,, RetTitle("VS1_NCLIFT"), "@!", 33,, {||cTR_NomCli },,,,) 
TRCell():New(oSection1, "oCodVen"    ,, RetTitle("VS1_CODVEN"), "@!", 15,, {||cTR_CodVen },,,,) 
TRCell():New(oSection1, "oNomVen"    ,, RetTitle("VS1_NOMVEN"), "@!", 33,, {||cTR_NomVen },,,,) 
TRCell():New(oSection1, "oValBru"    ,, RetTitle("VS1_VLBRNF"), "@E 999,999,999.99", 20,, {||nTR_ValBru },,,,) 

oSection2 := TRSection():New(oReport, "oTotNotas")
TRCell():New(oSection2, "oColVazia1" ,,  ""                    , "@!", 12,, {|| },,,,) 
TRCell():New(oSection2, "oColVazia2" ,,  ""                    , "@!", 12,, {|| },,,,) 
TRCell():New(oSection2, "oColVazia3" ,,  ""                    , "@!", 12,, {|| },,,,) 
TRCell():New(oSection2, "oColVazia4" ,,  ""                    , "@!", 15,, {|| },,,,) 
TRCell():New(oSection2, "cDescTotal" ,,  ""                    , "@!", 33,, {|| cTR_TotQtdVlr },,,,) 
TRCell():New(oSection2, "oColVazia5" ,,  ""                    , "@!", 15,, {|| },,,,) 
TRCell():New(oSection2, "oColVazia6" ,,  ""                    , "@!", 33,, {|| },,,,) 
TRCell():New(oSection2, "oVlrTotal"  ,,  ""                    , "@E 999,999,999.99", 20,, {||nTR_TotQtdVlr },,,,) 

Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_RELATORIO ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Relatorio                     				                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RELATORIO(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local ni        := 0

nTR_VlrTot := 0
nTR_QtdNFs    := 0

oSection1:Init()
For ni := 1 to Len(aNF)
	If aNF[ni,8]
		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek( xFilial("SF2") + aNF[ni,1] + aNF[ni,2] )
		If !SF2->F2_TIPO $ "BD"
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA )
			cTR_CGCCli := left(Transform(SA1->A1_CGC,If(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))+space(18),18)
			cTR_NomCli := left(STR0019+":"+SF2->F2_CLIENTE+"-"+ SF2->F2_LOJA+" "+SA1->A1_NOME,40)
		Else
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA )
			cTR_CGCCli := left(Transform(SA2->A2_CGC,If(Len(Alltrim(SA2->A2_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))+space(18),18)
			cTR_NomCli := left(STR0043+":"+SF2->F2_CLIENTE+"-"+ SF2->F2_LOJA+" "+SA2->A2_NOME,40)
		Endif
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek( xFilial("SA3") + SF2->F2_VEND1 )
		nTR_VlrTot += SF2->F2_VALBRUT
		nTR_QtdNFs++
		
		// variaveis do tReport
		dTR_DtEmis := SF2->F2_EMISSAO
		cTR_Doc    := SF2->F2_DOC
		cTR_Serie  := SF2->F2_SERIE
		cTR_CodVen := SF2->F2_VEND1
		cTR_NomVen := SA3->A3_NOME
		nTR_ValBru := SF2->F2_VALBRUT
		oSection1:PrintLine()
	EndIf
Next

oSection1:Finish()

// Imprime Total
oSection2:Init()
cTR_TotQtdVlr := STR0010
nTR_TotQtdVlr := nTR_VlrTot
oSection2:PrintLine()
cTR_TotQtdVlr := STR0031
nTR_TotQtdVlr := nTR_QtdNFs
oSection2:PrintLine()
oSection2:Finish()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ImpNotaP2    ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Imprime nota fiscal             				                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpNotaP2(cAlias,nReg,nOpc)

Local bCampo := { |nCPO| Field(nCPO) }
Local aPages := {}, aVar:={}
Local nPar := 1
Local ni  := 0 , _ni := 0
Local nPosRecNF := nPosRecC := 0
Local cPrefBAL := GetNewPar("MV_PREFBAL","BAL")
Local cPrefOFI := GetNewPar("MV_PREFOFI","OFI")
Local cPrefVEI := GetNewPar("MV_PREFVEI","VEI")
Private aNewBot := {}
aadd(aNewBot,{"RELATORIO" ,"Mc090Cons(1,aPedidos)",STR0036})
if nModulo == 11
	aadd(aNewBot,{"NOVACELULA","FS_MEMO2()",STR0037})
Endif
aadd(aNewBot,{"PRECO"     ,"FS_AVALIACAO()",STR0039})
For ni := 1 to Len(aNewBot)
	Private cFunc&(alltrim(Str(ni))) := aNewBot[ni,2]
Next
Private cFcBot
Private cCodVen
Private oLbEntIte
Private aTELA[0][0], aGETS[0], aHeader[0]
Private lConsulta   := .f.
Private cNumPed     := ""
Private aPedidos    := {}
Private nTotDes     := 0
Private nTotOrc     := 0
Private nTotPec     := 0
Private nTotSrv     := 0
Private nC          := 1
Private nNF         := 1
Private lPri        := .t.
Private aCabPV      := {}
Private aItePV      := {}
Private lAbortPrint := .f.
Private cNumIde	  := ""
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTitulo        := STR0038
cAliasEnchoice := "SF2"
cLinOk         := "AllwaysTrue()"
cTudoOk        := "AllwaysTrue()"
cFieldOk       := "FG_MEMVAR()"

nOpc :=2
nOpcE:=2
nOpcG:=2

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Variavel interna para funcionamento correto dos campos MEMOS na Visualizacao por outras Rotinas //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If nOpc == 2 .and. FunName() != "OFIOC160" // Necessario utilizar a funcao FUNNAME (chamada no MENU)
	SetStartMod(.t.)	
Endif
/////////////////////////////////////////////////////////////////////////////////////////////////////

nOpca:=0

lRefresh := .t.
Inclui   := .f.
lVirtual := .f.
nLinhas  := 99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posciona no Tipos de Condicao de Pagamento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE4")
DbSeek(xFilial("SE4")+SF2->F2_COND)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posciona no cliente                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("SF2",.T.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SF2")
While !Eof().and.(x3_arquivo=="SF2")
	If X3USO(x3_usado).and.x3_nivel>0  // .and. ( AllTrim(x3_campo) $ [F2_DOC#F2_SERIE#F2_CLIENTE#F2_LOJA#F2_EMISSAO#F2_VALBRUT])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+Alltrim(x3_campo)) := &(x3_campo)
	dbSkip()
End

DbSelectArea("SF2")
For ni:=1 to fCount()
	&("M->"+FieldName(ni)) := &("SF2->"+FieldName(ni))
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Pecas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoNF:=0
dbSelectArea("SX3")
dbSeek("SD2")
aHeaderNF:={}
While !Eof().And.(x3_arquivo=="SD2")
	If X3USO(x3_usado) // .and. ( AllTrim(SX3->X3_CAMPO) $ "D2_ITEM#D2_COD#D2_QUANT#D2_PRCVEN#D2_TOTAL#D2_TES#D2_PEDIDO#" )
		nUsadoNF++
		Aadd(aHeaderNF,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("SD2")
ADHeadRec("SD2",aHeaderNF)
// Posicao do registro
nPosRecNF:=Len(aHeaderNF)
nUsadoNF :=Len(aHeaderNF)

aColsNF := {}
DbSelectArea("SD2")
dbSetOrder(3)
Fg_Seek("SD2","SF2->F2_DOC+SF2->F2_SERIE",3,.F.)
While SD2->D2_DOC == SF2->F2_DOC .and. SD2->D2_SERIE == SF2->F2_SERIE .and. !eof()
	AADD(aColsNF,Array(nUsadoNF+1))
	For _ni:=1 to nUsadoNF
		If IsHeadRec(aHeaderNF[_ni,2])
			aColsNF[Len(aColsNF),_ni] := SD2->(RecNo())
		ElseIf IsHeadAlias(aHeaderNF[_ni,2])
			aColsNF[Len(aColsNF),_ni] := "SD2"
		Else
			aColsNF[Len(aColsNF),_ni]:=If(aHeaderNF[_ni,10] # "V",FieldGet(FieldPos(aHeaderNF[_ni,2])),CriaVar(aHeaderNF[_ni,2]))
		EndIf
	Next
	if aScan(aPedidos,SD2->D2_PEDIDO) = 0
		aAdd(aPedidos,SD2->D2_PEDIDO)
	Endif
	aColsNF[Len(aColsNF),nUsadoNF+1]:=.F.
	//cNumPed := SD2->D2_PEDIDO
	dbSkip()
EndDo
cNumPed := SF2->F2_DUPL // Devido a mudanca do numero do titulo se tornou o número da nota

if Len(aColsNF) == 0
	aColsNF:={Array(nUsadoNF+1)}
	aColsNF[1,nUsadoNF+1]:=.F.
	For _ni:=1 to nUsadoNF
		If IsHeadRec(aHeaderNF[_ni,2])
			aColsNF[Len(aColsNF),_ni] := 0
		ElseIf IsHeadAlias(aHeaderNF[_ni,2])
			aColsNF[Len(aColsNF),_ni] := "SD2"
		Else
			aColsNF[1,_ni]:=CriaVar(aHeaderNF[_ni,2])
		EndIf
	Next
Endif

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

nTotPec := SF2->F2_VALBRUT
nTotDes := SF2->F2_DESCONT
nTotOrc := SF2->F2_VALBRUT-SF2->F2_DESCONT

aEntrada := {}
aDescEnt := {}
aIteParc := {}

DbSelectarea("VS1")
DbSetOrder(3)
DbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)
if cTipoNF == "T"
	if !VS1->( Found() )
		DbSelectarea("VV0")
		DbSetOrder(4)
		if !DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
			DbSelectarea("VOO")
			DbSetOrder(4)
			if DbSeek(xFilial("VOO")+SF2->F2_DOC+SF2->F2_SERIE)
				DbSelectarea("SE1")
				DbSetOrder(1)
				DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed)
				cNumIde := cNumPed+space(TamSx3("VS9_NUMIDE")[1]-Len(AllTrim(cNumPed)))
				cTipoNF := "O"
			Endif
		Else
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+VV0->VV0_NUMTRA)
			cNumIde := VV0->VV0_NUMTRA
			cTipoNF := "V"
		Endif
	Else
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed)
		cNumIde := "OR"+VS1->VS1_NUMORC
		cTipoNF := "B"
	Endif
Elseif cTipoNF == "B"
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed)
	cNumIde := "OR"+VS1->VS1_NUMORC
Elseif cTipoNF == "V"
	DbSelectArea("VV0")
	DbSetOrder(4)
	DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+VV0->VV0_NUMTRA)
	cNumIde := VV0->VV0_NUMTRA
Else
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed)
	cNumIde := cNumPed+space(TamSx3("VS9_NUMIDE")[1]-Len(AllTrim(cNumPed)))
Endif

&& Parcelas
DbSelectArea("SE1")
DbSetOrder(1)
Do While !EOF() .and. (E1_PREFIXO+E1_NUM == SF2->F2_PREFIXO+cNumPed)
	if (cTipoNF =="B" .and. E1_PREFORI != cPrefBAL) .or. (cTipoNF =="O" .and. E1_PREFORI != cPrefOFI) .or. (cTipoNF =="V" .and. E1_PREFORI != cPrefVEI)
		DbSkip()
		loop
	endif
	if alltrim(SE1->E1_TIPO) == "DP"
		aadd(aIteParc,{E1_VENCREA,E1_VALOR})
	Endif
	DbSkip()
Enddo
if Len(aIteParc) == 0
	aadd(aIteParc,{cTod(""),0})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols e aHeader da Condicao de Pagamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC:=0
DbSelectArea("SX3")
DbSeek("VS9")
aHeaderC:={}
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VS9")
ADHeadRec("VS9",aHeaderC)
// Posicao do registro
nPosRecC:=Len(aHeaderC)
nUsadoC :=Len(aHeaderC)

aColsC := {}
DbSelectarea("VS9")
DbSetOrder(1)
if DbSeek(xFilial("VS9")+cNumIde+cTipoNF)
	nPar := 1
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. alltrim(VS9->VS9_NUMIDE) == alltrim(cNumIde) .and. VS9->VS9_TIPOPE == cTipoNF
		lOk := .f.
		DbSelectArea("SE1")
		DbSetOrder(1)
		if DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed+Str(nPar,1)+VSE->VSE_TIPPAG)
			if Empty(SE1->E1_BAIXA)
				lOk := .f.
			Else
				lOk := .t.
			Endif
		Endif
		DbSelectArea("VS9")
		if VS9->VS9_TIPPAG == "DP"
			DbSkip()
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o aCols da Entrada                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aColsC,Array(nUsadoC+1))
		aColsC[Len(aColsC),Len(aColsC[Len(aColsC)])] := lOk
		For _ni:=1 to nUsadoC
			If IsHeadRec(aHeaderC[_ni,2])
				aColsC[Len(aColsC),_ni] := VS9->(RecNo())
			ElseIf IsHeadAlias(aHeaderC[_ni,2])
				aColsC[Len(aColsC),_ni] := "VS9"
			Else
				aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
			EndIf
		Next
		nPar++
		DbSkip()
	Enddo
Endif

if Len(aColsC) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		If IsHeadRec(aHeaderC[_ni,2])
			aColsC[Len(aColsC),_ni] := 0
		ElseIf IsHeadAlias(aHeaderC[_ni,2])
			aColsC[Len(aColsC),_ni] := "VS9"
		Else
			aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
		EndIf
	Next
Else
	DbSelectArea("VSE")
	if DbSeek(xFilial("VSE")+cNumIde+cTipoNF+aColsC[1,FG_POSVAR("VS9_TIPPAG","aHeaderC")]+aColsC[1,FG_POSVAR("VS9_SEQUEN","aHeaderC")])
		Do While !Eof() .and. alltrim(VSE->VSE_NUMIDE) == Alltrim(cNumIde) .and. VSE->VSE_TIPOPE == cTipoNF .and. VSE->VSE_TIPPAG == aColsC[1,FG_POSVAR("VS9_TIPPAG","aHeaderC")] .and. VSE->VSE_SEQUEN == aColsC[1,FG_POSVAR("VS9_SEQUEN","aHeaderC")]
			aadd(aDescEnt,{VSE->VSE_DESCCP,VSE->VSE_VALDIG})
			DbSkip()
		Enddo
	Endif
Endif
if Len(aDescEnt) == 0
	aadd(aDescEnt,{"",""})
Endif

Private aTitles  := {OemToAnsi(STR0022),OemToAnsi(STR0033)}
Private oFolder

DEFINE MSDIALOG oDlg FROM 000,000 TO 035,080 TITLE cTitulo OF oMainWnd

@ 012,001 FOLDER oFolder SIZE 316,195 OF oDlg PROMPTS aTitles[1],aTitles[2] PIXEL
@ 210,002 Say OemToAnsi(STR0019+":") SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ 210,025 Say iif(SF2->F2_TIPO$"BD",SA2->A2_NOME,SA1->A1_NOME) SIZE 55,08 OF oDlg PIXEL COLOR CLR_BLUE
@ 210,120 Say OemToAnsi(STR0021+":") SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ 210,150 Say SE4->E4_DESCRI SIZE 55,08 OF oDlg PIXEL COLOR CLR_BLUE

Zero()
oGetMGet:= MsMGet():New("SF2",0,nOpcE,,,,aCpoEnchoice,{001,002,082,312},,2,,,,oFolder:aDialogs[1],,.T.,.F.)

@ 220,002 Say OemToAnsi(STR0018) SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE
@ 220,042 msget oTotPec VAR nTotPec Picture "999,999.99" SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
@ 220,121 Say OemToAnsi(STR0035) SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE
@ 220,152 msget oTotDes VAR nTotDes Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
@ 220,235 Say OemToAnsi(STR0010) SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE
@ 220,263 msget oTotOrc VAR nTotOrc Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.

aHeader  := aClone(aHeaderNF)
aCols    := aClone(aColsNF)
oGetPecas                       := MsGetDados():New(084,002,180,312,nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[1])
oGetPecas:oBrowse:default()
oGetPecas:oBrowse:bGotFocus     := {|| aHeader := aClone(aHeaderNF),aCols := aClone(aColsNF),n := nNF, oGetPecas:oBrowse:SetFocus()}
oGetPecas:oBrowse:bLostFocus    := {|| aHeaderNF:= aClone(aHeader), aColsNF:= aClone(aCols), nNF:= n }

// Pagina 2

aHeader  := aClone(aHeaderC)
aCols    := aClone(aColsC)
oEntrada                       := MsGetDados():New(001,001,089,312,nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[2])
oEntrada:oBrowse:default()
oEntrada:oBrowse:bChange       := {|| FS_MUDATP(n,cTipoNF) }
oEntrada:oBrowse:bEditCol      := {|| .t. }
oEntrada:oBrowse:bDelete       := {|| .t. }
oEntrada:oBrowse:bGotFocus     := {|| aHeader := aClone(aHeaderC),aCols := aClone(aColsC),n := nC, oEntrada:oBrowse:SetFocus()}
oEntrada:oBrowse:bLostFocus    := {|| aHeaderC:= aClone(aHeader), aColsC:= aClone(aCols), nC:= n }

@ 092,001 LISTBOX oLbEntIte FIELDS HEADER OemToAnsi(STR0034),OemToAnsi(STR0010) COLSIZES 60,100 SIZE 200,088 OF oFolder:aDialogs[2] PIXEL

oLbEntIte:SetArray(aDescEnt)
oLbEntIte:bLine := { || { aDescEnt[oLbEntIte:nAt,1] ,;
aDescEnt[oLbEntIte:nAt,2] }}

@ 092,203 LISTBOX oLbParc FIELDS HEADER  OemToAnsi(STR0006),OemToAnsi(STR0010) COLSIZES 40,50 SIZE 110,088 OF oFolder:aDialogs[2] PIXEL

oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}

aHeader  := aClone(aHeaderNF)
aCols    := aClone(aColsNF)

ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End()},{|| nOpca := 2,oDlg:End()},,aNewBot) )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_MUDATP    ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Muda tipo de pagto             				                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MUDATP(nLin,cTipoNF)
if lPri == .t.
	lPri := .f.
	Return
Endif
aDescEnt := {}
DbSelectArea("VSE")
if DbSeek(xFilial("VSE")+cNumIde+cTipoNF+aCols[nLin,FG_POSVAR("VS9_TIPPAG","aHeaderC")]+aCols[nLin,FG_POSVAR("VS9_SEQUEN","aHeaderC")])
	Do While !Eof() .and. alltrim(VSE->VSE_NUMIDE) == Alltrim(cNumIde) .and. VSE->VSE_TIPOPE == cTipoNF .and. VSE->VSE_TIPPAG == aColsC[nLin,FG_POSVAR("VS9_TIPPAG","aHeaderC")] .and. VSE->VSE_SEQUEN == aColsC[nLin,FG_POSVAR("VS9_SEQUEN","aHeaderC")]
		aadd(aDescEnt,{VSE->VSE_DESCCP,VSE->VSE_VALDIG})
		DbSkip()
	Enddo
Endif
if Len(aDescEnt) == 0
	AADD(aDescEnt,{"",""})
Endif
oLbEntIte:SetArray(aDescEnt)
oLbEntIte:bLine := { || { aDescEnt[oLbEntIte:nAt,1] ,;
aDescEnt[oLbEntIte:nAt,2] }}
oLbEntIte:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_AVALIA2   ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Avaliacao			             				                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_AVALIA2()
Local nCont     := 0
Local aVetVal   := {}
Local aSomaStru := {}
Local bCampo    := { |nCPO| Field(nCPO) }
Local x := 0 , _ni := 0 , n_ := 0 , nCnt := 0
Local cPrefBAL := GetNewPar("MV_PREFBAL","BAL")
Local cPrefOFI := GetNewPar("MV_PREFOFI","OFI")
Local cPrefVEI := GetNewPar("MV_PREFVEI","VEI")

Do Case
	Case SF2->F2_PREFORI == cPrefBAL
		cTipoNF := "B"
	Case SF2->F2_PREFORI == cPrefOFI
		cTipoNF := "O"
	Case SF2->F2_PREFORI == cPrefVEI
		cTipoNF := "V"
EndCase

If cTipoNF == "B"  //Pecas
	
	Private aColsP
	Private aHeaderP
	Private nUsadoP
	Private cSimVda := "P" // Pecas
	Private cCodVen
	Private nTotNot,nTotDes
	Private aColsc,aIteParc
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no VS1 p/ pegar o Vendedor                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("VS1")
	DbSetOrder(3)
	DbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)
	For x:=1 to FCount()
		&("M->"+FieldName(x)) := &(FieldName(x))
	Next
	
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+VS1->VS1_CODVEN)
	cCodVen := SA3->A3_COD
	nTotDes := VS1->VS1_VALDES
	nTotNot := VS1->VS1_VTOTNF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o aCols Pecas                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsadoP:=0
	DbSelectArea("SX3")
	DbSeek("VS3")
	aHeaderP:={}
	While !Eof().And.(x3_arquivo=="VS3")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS3_NUMORC" )
			nUsadoP++
			Aadd(aHeaderP,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
		Endif
		DbSkip()
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols Pecas                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsP := {}
	DbSelectArea("VS3")
	DbSetOrder(1)
	DbGotop()
	Fg_Seek("VS3","VS1->VS1_NUMORC",1,.F.)
	While VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. !eof()
		aAdd(aColsP,Array(nUsadoP+1))
		For _ni:=1 to nUsadoP
			aColsP[Len(aColsP),_ni]:=If(aHeaderP[_ni,10] # "V",FieldGet(FieldPos(aHeaderP[_ni,2])),CriaVar(aHeaderP[_ni,2]))
		Next
		DbSkip()
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsadoC:=0
	DbSelectArea("SX3")
	DbSeek("VS9")
	aHeaderC:={}
	While !Eof().And.(x3_arquivo=="VS9")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG")
			nUsadoC++
			Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			
			&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
			
		Endif
		DbSkip()
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens do Parcelamento                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aIteParc := {{cTod(""),0}}
	
	cTipAva  := "2"
	
	FS_AVALIARES()
	
Elseif cTipoNF == "O"
	
	Private aStruP  := {}
	Private aStruS  := {}
	Private aStruO  := {}
	Private cCodMap
	Private cOutMoed
	Private cSimOMoe
	Private lCalcTot:= .f.
	Private cCpoDiv := "    1"
	Private cNumIde
	PRIVATE cTipAva := "4"
	
	If !PERGUNTE("ATDOFI")
		return .t.
	EndIf
	
	cMapPecas := Mv_Par01
	cMapSrvcs := Mv_Par02
	cMapOdSrv := Mv_Par03
	
	cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
	cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))
	
	DbSelectArea("VOO")
	DbSetOrder(4)
	DbSeek(xFilial("VOO")+SF2->F2_DOC+SF2->F2_SERIE)
	
	cNumero := VOO->VOO_NUMNFI
	cParPro := "1"
	cContChv:= "VEC_NUMORC"
	cParTem := ""
	
	*** Avaliacao de Pecas ********************************************************
	
	dbSelectArea("VEC")
	DbSetOrder(4)
	
	If FG_SEEK("VEC","VOO->VOO_NUMNFI",4,.f.)
		
		While VOO->VOO_NUMNFI == VEC_NUMNFI .and. VEC->VEC_FILIAL == xFilial("VEC") .and. !eof()
			
			DbSelectArea("VOQ")
			FG_Seek("VOQ","cMapPecas",1,.f.)
			FG_SEEK("SB1","VEC->VEC_GRUITE+VEC->VEC_CODITE",7,.f.)
			nPosVet := aScan(aStruP,{|x| x[3]+x[7] == SB1->B1_COD+VOQ_CODIGO})
			ncont := nPosVet
			while cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
				
				If VOQ_INDATI != "1" // Sim
					dbSkip()
					Loop
				Endif
				
				cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
				
				if nPosVet == 0
					aadd(aStruP,{ VEC->VEC_NUMOSV,,SB1->B1_COD,;
					VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
					aadd(aSomaStru,{0,0,0,0,0,0})
				Else
					
					aStruP[nCont,1]  := VEC->VEC_NUMOSV
					aStruP[nCont,2]  := Nil
					aStruP[nCont,3]  := SB1->B1_COD
					aStruP[nCont,4]  := VOQ_CLAAVA
					aStruP[nCont,5]  := cDescVOQ
					aStruP[nCont,6]  := VOQ_ANASIN
					aStruP[nCont,7]  := VOQ_CODIGO
					aStruP[nCont,8]  := VOQ_SINFOR
					aStruP[nCont,9]  := 0
					aStruP[nCont,10] := 0
					aStruP[nCont,11] := SB1->B1_GRUPO+" "+SB1->B1_CODITE
					aStruP[nCont,12] := 0
					aStruP[nCont,13] := 0
					aStruP[nCont,14] := .f.
					aStruP[nCont,15] := VOQ->VOQ_PRIFAI
					aStruP[nCont,16] := VOQ->VOQ_SEGFAI
					aStruP[nCont,17] := VOQ_FUNADI
					aStruP[nCont,18] := VOQ_CODIMF
					aStruP[nCont,19] := dDataBase
					aStruP[nCont,20] := 0
					aStruP[nCont,21] := 0
					
				Endif
				
				nCont++
				
				DbSkip()
				
			Enddo
			
			DbSelectArea("VEC")
			
			cNumero := VOO->VOO_NUMNFI
			aStruP := FG_CalcVlrs(aStruP,SB1->B1_COD,cCpoDiv)
			
			if nPosVet == 0
				cCpoDiv := cCpoDiv + "#" + str(len(aStruP)+1,5)
			Endif
			
			FG_Seek("VOQ","cMapPecas",1,.f.)
			FG_SEEK("SB1","VEC->VEC_GRUITE+VEC->VEC_CODITE",7,.f.)
			nPosVet := aScan(aStruP,{|x| x[3]+x[7] == SB1->B1_COD+VOQ->VOQ_CODIGO})
			If nPosVet == 0
				nPosVet := 1
			Endif
			
			For n_:=nPosVet to Len(aSomaStru)
				aSomaStru[n_,1] += aStruP[n_,9]
				aSomaStru[n_,3] += aStruP[n_,12]
				aSomaStru[n_,5] += aStruP[n_,20]
			Next
			
			For n_:=1 to Len(aSomaStru)
				aStruP[n_,9]  := aSomaStru[n_,1]
				aStruP[n_,12] := aSomaStru[n_,3]
				aStruP[n_,20] := aSomaStru[n_,5]
			Next
			
			DbSkip()
			
		EndDo
		
		lCalcTot:= .t.
		
		DbSelectArea("VOQ")
		FG_Seek("VOQ","cMapPecas",1,.f.)
		
		While cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
			
			If VOQ_INDATI != "1" // Sim
				dbSkip()
				Loop
			Endif
			
			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
			aadd(aStruP,{ VEC->VEC_NUMOSV,,STR0009,;
			VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
			
			DbSkip()                               
			
		EndDo
		
		cNumero := VOO->VOO_NUMNFI
		aStruP := FG_CalcVlrs(aStruP,STR0009,cCpoDiv)
		
	EndIf
	
	*** Avaliacao de Servicos ********************************************
	
	aSomaStru := {}
	cCpoDiv   := "    1"
	lCalcTot  := .f.
	
	If FG_SEEK("VSC","VOO->VOO_NUMNFI",6,.f.)
		
		DbSelectArea("VSC")
		DbSetOrder(6)
		
		While  VOO->VOO_NUMNFI == VSC_NUMNFI .and. VSC->VSC_FILIAL == xFilial("VSC") .and. !eof()
			
			DbSelectArea("VOQ")
			FG_Seek("VOQ","cMapSrvcs",1,.f.)
			nPosVet := aScan(aStruS,{|x| x[3]+x[7] == VSC->VSC_CODSER+VOQ_CODIGO})
			nCont := nPosVet
			
			While cMapSrvcs == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
				
				if VOQ_INDATI != "1" // Sim
					DbSkip()
					Loop
				Endif
				
				cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
				
				If nPosVet == 0
					aAdd(aStruS,{ VSC->VSC_NUMOSV,,VSC->VSC_CODSER,;
					VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSC->VSC_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
					aAdd(aSomaStru,{0,0,0,0,0,0})
				Else
					aStruS[nCont,1]  := VSC->VSC_NUMOSV
					aStruS[nCont,2]  := Nil
					aStruS[nCont,3]  := VSC->VSC_CODSER
					aStruS[nCont,4]  := VOQ_CLAAVA
					aStruS[nCont,5]  := cDescVOQ
					aStruS[nCont,6]  := VOQ_ANASIN
					aStruS[nCont,7]  := VOQ_CODIGO
					aStruS[nCont,8]  := VOQ_SINFOR
					aStruS[nCont,9]  := 0
					aStruS[nCont,10] := 0
					aStruS[nCont,11] := VSC->VSC_CODSER
					aStruS[nCont,12] := 0
					aStruS[nCont,13] := 0
					aStruS[nCont,14] := .f.
					aStruS[nCont,15] := VOQ->VOQ_PRIFAI
					aStruS[nCont,16] := VOQ->VOQ_SEGFAI
					aStruS[nCont,17] := VOQ_FUNADI
					aStruS[nCont,18] := VOQ_CODIMF
					aStruS[nCont,19] := dDataBase
					aStruS[nCont,20] := 0
					aStruS[nCont,21] := 0
				Endif
				
				nCont ++
				
				DbSkip()
				
			EndDo
			
			DbSelectArea("VSC")
			nArea := GetArea()
			
			cNumero := VOO->VOO_NUMNFI + VSC->VSC_CODSER + VSC->VSC_NUMOSV
			aStruS := FG_CalcVlrs(aStruS,VSC->VSC_CODSER,cCpoDiv)
			
			If nPosVet == 0
				cCpoDiv := cCpoDiv + "#" + str(len(aStruS)+1,5)
			Endif
			
			FG_Seek("VOQ","cMapSrvcs",1,.f.)
			nPosVet := aScan(aStruS,{|x| x[3]+x[7] == VSC->VSC_CODSER+VOQ->VOQ_CODIGO})
			If nPosVet == 0
				nPosVet := 1
			Endif
			
			For n_:=nPosVet to Len(aSomaStru)
				aSomaStru[n_,1] += aStruS[n_,9]
				aSomaStru[n_,3] += aStruS[n_,12]
				aSomaStru[n_,5] += aStruS[n_,20]
			Next
			
			For n_:=1 to Len(aSomaStru)
				aStruS[n_,9]  := aSomaStru[n_,1]
				aStruS[n_,12] := aSomaStru[n_,3]
				aStruS[n_,20] := aSomaStru[n_,5]
			Next
			
			DbSelectArea("VSC")
			RestArea(nArea)
			DbSkip()
			
		EndDo
		
		lCalcTot:= .t.
		
		DbSelectArea("VOQ")
		FG_SEEK("VOQ","cMapSrvcs",1,.f.)
		
		while cMapSrvcs == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
			
			If VOQ_INDATI != "1" // Sim
				DbSkip()
				Loop
			Endif
			
			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
			aadd(aStruS,{ VSC->VSC_NUMOSV,,STR0009,;
			VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSC->VSC_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
			DbSkip()
			
		EndDo
		
		cNumero := VOO->VOO_NUMNFI
		aStruS := FG_CalcVlrs(aStruS,STR0009,cCpoDiv)
		
	EndIf
	
	*** Avaliacao da Ordem de Servico *********************************************
	
	aSomaStru := {}
	cCpoDiv := "    1"
	
	If FG_SEEK("VEC","VOO->VOO_NUMNFI",4,.f.)
		
		DbSelectArea("VEC")
		DbSetOrder(4)
		
		While VOO->VOO_NUMNFI == VEC_NUMNFI .and. VEC->VEC_FILIAL == xFilial("VEC") .and. !eof()
			
			DbSelectArea("VOQ")
			FG_Seek("VOQ","cMapOdSrv",1,.f.)
			
			while cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
				
				If VOQ_INDATI != "1" // Sim
					dbSkip()
					Loop
				Endif
				
				FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)
				
				cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
				aadd(aStruO,{ VEC->VEC_NUMOSV,,SB1->B1_COD,;
				VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
				
				dbSkip()
				
			Enddo
			
			DbSelectArea("VEC")
			
			cNumero := VS6->VS6_NUMIDE
			aStruO := FG_CalcVlrs(aStruO,SB1->B1_GRUPO+" "+SB1->B1_CODITE,cCpoDiv)
			cCpoDiv := cCpoDiv + "#" + str(len(aStruO)+1,5)
			dbSkip()
			
		EndDo
		
	EndIf
	
	If FG_SEEK("VSC","VOO->VOO_NUMNFI",6,.f.)
		
		DbSelectArea("VSC")
		DbSetOrder(6)
		
		While VOO->VOO_NUMNFI == VSC_NUMNFI .and. VSC->VSC_FILIAL == xFilial("VSC") .and. !eof()
			
			DbSelectArea("VOQ")
			FG_Seek("VOQ","cMapOdSrv",1,.f.)
			
			While cMapOdSrv == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
				
				if VOQ_INDATI != "1" // Sim
					DbSkip()
					Loop
				Endif
				
				cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
				aadd(aStruO,{ VSC->VSC_NUMOSV,,VSC->VSC_CODSER,;
				VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSC->VSC_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
				
				DbSkip()
				
			Enddo
			
			DbSelectArea("VSC")
			
			cNumero := VOO->VOO_NUMNFI
			aStruO := FG_CalcVlrs(aStruO,VSC->VSC_CODSER,cCpoDiv)
			cCpoDiv := cCpoDiv + "#" + str(len(aStruO)+1,5)
			DbSkip()
			
		EndDo
		
	EndIf
	
	lCalcTot:= .t.
	
	DbSelectArea("VOQ")
	FG_SEEK("VOQ","cMapOdSrv",1,.f.)
	
	while cMapOdSrv == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
		
		If VOQ_INDATI != "1" // Sim
			DbSkip()
			Loop
		Endif
		
		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
		aadd(aStruO,{ VSC->VSC_NUMOSV,,STR0009,;
		VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSC->VSC_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
		
		DbSkip()
		
	EndDo
	
	cNumero := VOO->VOO_NUMNFI
	aStruO := FG_CalcVlrs(aStruO,STR0009,cCpoDiv)
	
	FG_ResAva(cOutMoed,3,"S","","OFIOM160",{aStruP,aStruS,aStruO})
	
Else
	
	// Veiculos
	cTipAva := "1"
	If !Pergunte("LIBVEI")
		Return .t.
	EndIf
	cCodMap  := Mv_Par01
	cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
	cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))
	
	DbSelectArea("VV0")
	DbSetOrder(4)
	DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
	
	DbSelectArea("VVA")
	DbSetOrder(1)
	DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	
	DbSelectArea("VV1")
	DbSetOrder(2)
	DbSeek(xFilial("VV1")+VVA->VVA_CHASSI)
	
	FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"D")
	FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"R")
	
	aStru   := {}
	cTipAva := "1"
	cCpoDiv := "    1"
	cTipFat := VV0->VV0_TIPFAT
	lCarBott:= .t.
	cSimVda := "V"
	
	DbSelectArea("VS5")
	FG_Seek("VS5","cCodMap",1,.f.)
	
	DbSelectArea("VOQ")
	FG_Seek("VOQ","cCodMap",1,.f.)
	
	while !eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
		
		If !(cTipFat $ VOQ_TIPFAT)
			DbSkip()
			Loop
		Endif
		
		If VOQ_INDATI # "1" && Sim
			DbSkip()
			Loop
		Endif
		
		If VOQ_CODMAP # cCodMap
			Exit
		Endif
		
		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
		aadd(aStru,{ VV0->VV0_NUMTRA,VV1->VV1_TRACPA,VV1->VV1_CHAINT,;
		VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VV0->VV0_DATMOV,0,0,VOQ_CTATOT})
		
		DbSkip()
		
	Enddo
	
	DbSelectArea("VV0")
	For nCnt := 1 TO FCount()
		cNome := substr(FieldName(nCnt),5)
		M->&(EVAL(bCampo,nCnt)) := &("VV0->VV0_"+cNome)
	Next
	
	DbSelectArea("VVA")
	For nCnt := 1 TO FCount()
		cNome := substr(FieldName(nCnt),5)
		M->&(EVAL(bCampo,nCnt)) := &("VVA->VVA_"+cNome)
	Next
	
	FG_CalcVlrs(aStru,VV1->VV1_CHAINT)
	FG_RESAVA(cOutMoed,3,"V","","OFIOM170")
	
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_MEMO2     ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Memo   			             				                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MEMO2()
if nModulo == 11 //Veiculo
	Private aMemos  := {{"VVA_OBSMEM","VVA_OBSERV"}}
	Private oFonte  := TFont():New( "Arial", 8,13 )
	dbSelectArea("VV0")
	dbSetOrder(4)
	dbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
	dbSelectArea("VVA")
	dbSetOrder(1)
	dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	//cObserv := MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1])    //Cria um Memo em Branco
	cObserv := E_MSMM(VVA->VVA_OBSMEM,68)
	DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0011) FROM  02,04 TO 14,56 OF oMainWnd
	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1
	@ 01,011 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL
	oObserv:oFont := oFonte
	oObserv:bRClicked := {|| AllwaysTrue() }
	oObserv:SetFocus()
	ACTIVATE MSDIALOG oDlg1 CENTER
Endif
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_PSQ160    ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Pesquisa nota fiscal            				                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PSQ160()
axPesqui()
DbSelectArea("SF2")
DbSetOrder(nIndexSF2+1)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³MenuDef      ³ Autor ³ Andre / Andre Luis Almeida ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Menu					          				                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Geral                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { " " ," " , 0, 1},;        //Pesquisar
{ " " ," " , 0, 2},;   //Visualizar
{ " " ," " , 0, 3},;   //Incluir
{ " " ," " , 0, 4},;   //Alterar
{ " " ," " , 0, 5} }   //Excluir
Return aRotina
