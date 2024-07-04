// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 061    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "MATA297M.CH"
#INCLUDE "Protheus.ch"
#INCLUDE 'TBICONN.CH'

Static cGetVersao   := GetVersao(.f.,.f.)
Static cPergMil     := "MTA297M"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Mata297M ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina p/ Cadastro de Sugestao de Compras                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Mata297()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata297M()
PRIVATE cFunc1 := ""
PRIVATE lMSErroAuto := .F.
PRIVATE lMsHelpAuto := .F.
PRIVATE cqtEstoq := SPACE(13)
PRIVATE cqtDispo := SPACE(13)
PRIVATE oEnc01
Private cGruFor := "04"
PRIVATE oEnc02
PRIVATE cCadastro := OemToAnsi(STR0001) //"Sugestao de Compras"
PRIVATE aValorPed := {}
PRIVATE aRotina := MenuDef()
PRIVATE cOk  		:= GetMark()
PRIVATE nTipPrc :=SFJ->FJ_TIPPRC
PRIVATE nQtdGer := 1
PRIVATE cSugegs :=""
PRIVATE cDescForm :=""
PRIVATE cFornComp1 := cFornComp2 := space(50)
PRIVATE cRelac1 := cRelac2 := cRelac3 := cRelac4 := ""
Private cAliasSBL   := "SQLSBL"
PRIVATE nRelac1 := nRelac2 := nRelac3 := nRelac4 := 0
PRIVATE cRelABC1 := cRelABC2 := cRelABC3 := cRelABC4 := ""
PRIVATE aVecTot := aIteRelac := {}
PRIVATE ameses:= {STR0077,STR0078,STR0079,STR0080,STR0081,STR0082,STR0083,STR0084,STR0085,STR0086,STR0087,STR0088}
PRIVATE lKIT := .f.
PRIVATE lF4_OPEMOV := .f.
PRIVATE lB1_ESTMIN := .f.
PRIVATE cCodi    := ""
Private lJohnDeere := (Alltrim(GetNewPar("MV_MIL0006","")) == "JD")
Private oGetDados
Private OBJ10
Private OBJ11
Private OBJ12
Private OBJ13
Private OBJ14
Private OBJ15
Private OBJ16
Private OBJ17
Private OBJ18
Private OBJ19
Private OBJ20
Private OBJ21
Private OBJ22
Private oDlg297
Private cDemMes1, cDemMes2, cDemMes3, cDemMes4, cDemMes5, cDemMes6, cDemMes7, cDemMes8, cDemMes9, cDemMes10, cDemMes11, cDemMes12, cDemPec
Private oSqlHlp := DMS_SqlHelper():New()
Private cQtInf  := ""
Private cVlrTot := ""
Private cPecaAtu := ""
Private cPecaDem := ""
Private cCodPecInt := ""
Private oTimer
Private cTableName := ""
Private aFilaDem := {}
Private nQtdDis  := 30 
Private nPesoTot := 0
Private lDebug := .F.
If SF4->(FieldPos("F4_OPEMOV")) # 0
	lF4_OPEMOV := .t.
EndIf
If SB1->(FieldPos("B1_ESTMIN")) # 0
	lB1_ESTMIN := .t.
EndIf

M->DF_CODITE  := CRIAVAR("DF_CODITE",.F.)
M->DF_PRODUTO := CRIAVAR("DF_PRODUTO",.F.)

MTA297MSX1()

SetKey(VK_F4, Nil)

////////////////////////////////////////////////////////////////
//   Cria indice por codigo da SUGESTAO no VE6                //
////////////////////////////////////////////////////////////////
cIndVE6 := CriaTrab(Nil, .F.)
cChave  := "VE6_FILIAL+VE6_CODIGO"
IndRegua("VE6",cIndVE6,cChave,,,OemToAnsi("Filtrando...") )
DbSelectArea("VE6")
nIndVE6 := RetIndex("VE6")
dbSetOrder(nIndVE6+1)
//
MT297MF12(.t.) // Habilita F12
//
cTableName := MATA297M2_CRIATAB()
//
If SFJ->(FieldPos("FJ_DATVAL")) > 0
	mBrowse( 6, 1,22,75,"SFJ",,"FJ_SOLICIT",20,,,,,,,,,,,(" FJ_DATVAL = ' ' OR FJ_DATVAL >='"+dtos(ddatabase)+"' "))
else
	mBrowse( 6, 1,22,75,"SFJ",,"FJ_SOLICIT",20)
endif
//
MT297MF12(.f.) // Desabilita F12
//
If File(cIndVE6+OrdBagExt())
	fErase(cIndVE6+OrdBagExt())
Endif
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MInct³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao de Sugestao de Compras			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Mata297()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MInct(cAlias,nOpcao)
Local cAnoMes
Private lGerou2
Private lGrava2  :=.F.
Private DSugest  := 0
Private ClasCust := 0
Private TipPrc   := 0
Private ABCVend  := ""
Private Impot    := 0
Private Itens    := 0
Private cGrp     := ""
Private cProdDe  := ""
Private cProdAte := ""
Private cGrpDesc := ""
Private cMarPeca := ""
Private cLinPeca := ""
Private cFamPeca := ""
Private lMLF 	 := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia
MT297MF12(.f.) // Desabilita F12

ValidPerg(cPergMil)

IF !Pergunte(cPergMil,.t.)
	MT297MF12(.t.) // Habilita F12
	Return
EndIF
DSugest  := MV_PAR01
ClasCust := MV_PAR02
TipPrc   := MV_PAR03
ABCVend  := MV_PAR04
Impot    := MV_PAR05
Itens    := MV_PAR06
cGrp     := MV_PAR07
cProdDe  := MV_PAR08
cProdAte := MV_PAR09
cGrpDesc := MV_PAR10

If lMLF // trabalha com Marca / Linha / Familia
	cMarPeca := MV_PAR13
	cLinPeca := MV_PAR14
	cFamPeca := MV_PAR15
Endif
cFormul  := MV_PAR16
IF Month(dDataBase)==1
	cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
Else
	cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
EndIF

DbSelectArea("SBL")
DBSetOrder(2)  //SBL Acum.Sugest.Compra	->BL_FILIAL+BL_ANO+BL_MES
IF !DbSeek(xFilial("SBL")+cAnoMes)
	Help(" ",1,"MTA297INC")
	MT297MF12(.t.) // Habilita F12
	Return .f.
EndIF

Processa({ || MT297MIncGt(cAlias,nOpcao) })
IF !lGrava2
	Help(" ",1,"MTA297NGER")
EndIF

MT297MF12(.t.) // Habilita F12
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MIncGt³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao de Sugestao de Compras                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297MIncGt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MIncGt(cAlias,nOpcao)
Local cAliasAnt := GetArea()
Local cABC      :=""
Local nX := 0
Local cImport
Local cTipCusto
Local cFormula
Local cCodigo   := CriaVar("FJ_CODIGO",.T.)
Local aSE       :={0,0,0}
Local cAnoMes
Local nDiasRep  :=0
Local lGeraOutra:=.F.
Local lGrava := .f.
Local nEstMin:=0
Local i       := 0
Local ni:= 0

Local lSBZ    := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )
Local cNamSB5 := RetSqlName("SB5")
Local cNamSBZ := IIf(lSBZ,RetSqlName("SBZ"),"")
Local cFilSB5 := xFilial("SB5")
Local cFilSBZ := IIf(lSBZ,xFilial("SBZ"),"")

Private lMLF  := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia

Private aConsumo := {}
Private nAtual
Private nlinha := 3
Private aVetCampos := {}
Private cPrivez := "SIM"
Private _FIL := xFilial("SDF")
Private _COD := cCodigo
Private nPagina := 1
Private cCab1TXT := STR0089+ _FIL +STR0090+ _COD +"    "+Transform(dDataBase,"@D")+STR0091+Transform(DSugest,"999")+STR0092
Private cCab2TXT := STR0093
Private cCab3TXT := ""

aadd(aVetCampos,{ "TRB_LINHA" , "C" , 132 , 0 })
oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "TRB"
oObjTempTable:aVetCampos := aVetCampos
oObjTempTable:CreateTable(.f.)

If nOpcao == 9
	lGerou2 :=.t.
EndIf

IF Month(dDataBase)==1
	cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
Else
	cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
EndIF

IF lGerou2
	Pergunte(cPergMil,.f.)
	nQtdGer++
Else
	ProcRegua(SB1->(Reccount()))
EndIF

cImport := IIF(Impot==1,STR0009,STR0010) //"S"###"N"
cTipCusto := Str(ClasCust,1)

If Empty(ABCVend)
	cABC := "AA/AB/AC/BA/BB/BC/CA/CB/CC/"
ElseIf Alltrim(ABCVend) == "*"
	cABC := "AA/AB/AC/BA/BB/BC/CA/CB/CC/"
Else
	cABC := ABCVend
EndIf

cCab3TXT += STR0094

oUtil := DMS_Util():New()
dData := dDatabase
for ni := 1 to 12
	cCab3TXT := aMeses[month(dData)] + right(strzero(year(dData),4),2) + " "
	dData := oUtil:RemoveMeses(dData, 1)
next

cCab3TXT += STR0095

DBSelectArea("SFJ")
DBSelectArea("SDF")
SDF->(DbSetOrder(2))
SM4->(DbSetOrder(1))
DBSelectArea("SB1")
DbSetOrder(1) //SB1 Produtos		    ->B1_FILIAL+B1_COD


If lB1_ESTMIN
	cQuery := "SELECT SBL.BL_PRODUTO,SBL.BL_ABCVEND,SBL.BL_ABCCUST,SBL.BL_MES,SBL.BL_ANO,SBL.BL_CODFORM,SB1.B1_COD,SB1.B1_CLASSVE,SB1.B1_IMPORT,SB1.B1_FLAGSUG,SB1.B1_GRUPO,SB1.B1_CODITE,SB1.B1_ESTMIN,SB1.B1_PE,SB1.B1_QE,SB1.B1_TIPE,SB1.B1_UPRC,SB1.B1_GRUDES,SB1.B1_PRV1 "
Else
	cQuery := "SELECT SBL.BL_PRODUTO,SBL.BL_ABCVEND,SBL.BL_ABCCUST,SBL.BL_MES,SBL.BL_ANO,SBL.BL_CODFORM,SB1.B1_COD,SB1.B1_CLASSVE,SB1.B1_IMPORT,SB1.B1_FLAGSUG,SB1.B1_GRUPO,SB1.B1_CODITE,SB1.B1_PE,SB1.B1_QE,SB1.B1_TIPE,SB1.B1_UPRC,SB1.B1_GRUDES,SB1.B1_PRV1 "
Endif
cQuery += "FROM "
cQuery += RetSqlName( "SBL" ) + " SBL , "+RetSqlName( "SB1" ) + " SB1 "

If lMLF // trabalha com Marca / Linha / Familia
	cQuery += "LEFT JOIN "+cNamSB5+" SB5 ON (SB5.B5_FILIAL='"+cFilSB5+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ') "
	If lSBZ // Utiliza SBZ
		cQuery += "LEFT JOIN "+cNamSBZ+" SBZ ON (SBZ.BZ_FILIAL='"+cFilSBZ+"' AND SB1.B1_COD=SBZ.BZ_COD AND SBZ.D_E_L_E_T_=' ') "
	Endif
Endif
cQuery += "WHERE "
cQuery += "SBL.BL_FILIAL='"+ xFilial("SBL")+ "' AND SBL.BL_ANO = '"+substr(cAnoMes,1,4)+"' AND SBL.BL_MES = '"+substr(cAnoMes,5,2)+"' AND SBL.BL_PRODUTO >= '"+cProdDe+"' AND SBL.BL_PRODUTO <= '"+cProdAte+"' AND "
IF cTipCusto # "4"
	cQuery += "SBL.BL_TIPCUST = '"+cTipCusto+"' AND "
Endif
cABCVen := ""
cParam  := cABC
if Len(cParam) > 0
	cQuery += " ( "
Endif
For i := 1 to Len(cParam)
	nPos := AT("/",cABC)
	nPos1 := nPos
	if nPos > 0
		nPos -= 1
	Else
		nPos := Len(cABC)
	Endif
	cABCVen := alltrim(Substr(cABC,1,nPos))
	if (Len(cABC) <= 3) .or. (nPos1 == 0 .and. !Empty(cABC))
		cQuery += "(SBL.BL_ABCVEND = '"+substr(cABCVen,1,1)+"' AND SBL.BL_ABCCUST = '"+substr(cABCVen,2,1)+"')) AND "
	Else
		cQuery += "(SBL.BL_ABCVEND = '"+substr(cABCVen,1,1)+"' AND SBL.BL_ABCCUST = '"+substr(cABCVen,2,1)+"') OR "
	Endif
	cABC    := alltrim(substr(cABC,nPos+2,Len(cABC)))
	if Empty(cABC)
		Exit
	Endif
Next
cQuery += "SB1.B1_COD = SBL.BL_PRODUTO AND SB1.B1_FLAGSUG = '1' AND SB1.B1_CLASSVE = '1' AND "

If lMLF // trabalha com Marca / Linha / Familia

	If lSBZ // Utiliza SBZ
		If !Empty(cMarPeca)
			If SBZ->(FieldPos("BZ_MARPEC")) > 0
				cQuery += "SBZ.BZ_MARPEC = '" + cMarPeca + "' AND "
			Else
				cQuery += "SB5.B5_MARPEC = '" + cMarPeca + "' AND "
			EndIf
		EndIf
		If !Empty(cLinPeca)
			If SBZ->(FieldPos("BZ_CODLIN")) > 0
				cQuery += "SBZ.BZ_CODLIN = '" + cLinPeca + "' AND "
			Else
				cQuery += "SB5.B5_CODLIN = '" + cLinPeca + "' AND "
			EndIf
		EndIf
		If !Empty(cFamPeca)
			If SBZ->(FieldPos("BZ_CODFAM")) > 0
				cQuery += "SBZ.BZ_CODFAM = '" + cFamPeca + "' AND "
			Else
				cQuery += "SB5.B5_CODFAM = '" + cFamPeca + "' AND "
			EndIf
		EndIf
	Else
		If !Empty(cMarPeca)
			cQuery += "SB5.B5_MARPEC = '" + cMarPeca + "' AND "
		EndIf
		If !Empty(cLinPeca)
			cQuery += "SB5.B5_CODLIN = '" + cLinPeca + "' AND "
		EndIf
		If !Empty(cFamPeca)
			cQuery += "SB5.B5_CODFAM = '" + cFamPeca + "' AND "
		EndIf
	Endif
EndIf

cQuery += "SBL.D_E_L_E_T_=' ' ORDER BY SBL.BL_PRODUTO "

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSBL, .T., .T. )

//SetRegua(LastRec())

nCSB1Tot := SB1->(Reccount())
nCSB1Atu := 1
nX:=1
Do While !( cAliasSBL )->( Eof() )
	// Verifica a qunatidade de itens p/ nao estourar a getdados
	nCSB1Atu +=1
	// Import 1=Sim 0=Nao
	IF ( cAliasSBL )->B1_IMPORT # cImport
		dbSelectArea(cAliasSBL)
		( cAliasSBL )->(dbSkip())
		Loop
	EndIF
	// Verifica se Grupo esta contido na variavel da pergunte
	If !Empty(cGrp)
		If !( ( cAliasSBL )->B1_GRUPO $ cGrp )
			dbSelectArea(cAliasSBL)
			( cAliasSBL )->(dbSkip())
			Loop
		EndIf
	EndIf
	// Verifica se Grupo de Desconto esta contido na variavel da pergunte
	IF !Empty(cGrpDesc)
		if !(( cAliasSBL )->B1_GRUDES $ AllTrim(cGrpDesc ))
			dbSelectArea(cAliasSBL)
			( cAliasSBL )->(dbSkip())
			Loop
		Endif
	Endif
	if SUBS(STR(nCSB1Atu,6),5,2)  == "00"
		Incproc(STR0096+AllTrim(str(nCSB1Atu)))
	endif
	//Verifica SE EXISTE SUGESTAO EM ABERTO
	IF SDF->(DbSeek(xFilial("SDF")+"A"+( cAliasSBL )->BL_PRODUTO))
		dbSelectArea(cAliasSBL)
		( cAliasSBL )->(dbSkip())
		Loop
	EndIF

	IF nX > 4096
		lGeraOutra :=.t.
		Exit
	Else
		IF !Empty(( cAliasSBL )->BL_CODFORM)
			//Carregando aConsumo
			aConsumo := {}// aConsumoSC( (cAliasSBL)->B1_COD )
			if (LEN(aConsumo[1]) > 5)
				return
			endif
			nAtual   :=len(aConsumo) + 1
			//  + 1  p/pegar ULTIMA DEMANDA (ref ao mes imediatamente anterior)
			aSE := SaldoEst(( cAliasSBL )->BL_PRODUTO)
			If ( cAliasSBL )->BL_CODFORM == "PES" // ESTABILIDADE
				cFormula := "aConsumo[nAtual-1]"
			ElseIf ( cAliasSBL )->BL_CODFORM == "PME" // MEDIA 3 MESES
				cFormula := "(aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3"
			ElseIf ( cAliasSBL )->BL_CODFORM == "PTE" // TENDENCIA
				cFormula := "aConsumo[nAtual-1]+(aConsumo[nAtual-1]-aConsumo[nAtual-2])"
			ElseIf ( cAliasSBL )->BL_CODFORM == "PSA" // SAZONALIDADE
				cFormula := "aConsumo[nAtual-12]*((aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/(aConsumo[nAtual-13]+aConsumo[nAtual-14]+aConsumo[nAtual-15]))"
			Else
				If SM4->(DbSeek(xFilial("SM4")+( cAliasSBL )->BL_CODFORM))
					cFormula := 0//&(SM4->M4_FORMULA)
				Else
					DBSelectArea(cAliasSBL)
					( cAliasSBL )->(DbSkip())
					Loop
				EndIf
			EndIf

			// Verifica: qtde de ultimos meses a analizar X qtde de meses com demanda
			If (MV_PAR11 > 0) .and. (MV_PAR11 >= MV_PAR12)
				nMesDem := 0
				For ni:= 1 to MV_PAR11
					If aConsumo[nAtual-ni]>0
						nMesDem++
					EndIf
				Next
				If nMesDem < MV_PAR12
					nlinha += 2
					If cPrivez == "SIM" .or. nlinha > 57
						nlinha := 5
						RecLock("TRB",.t.)
						TRB->TRB_LINHA	:= If(cPrivez=="SIM",CHR(15),CHR(12))
						MsUnlock()
						RecLock("TRB",.t.)
						TRB->TRB_LINHA	:= cCab1TXT+Transform(nPagina++,"99999")
						MsUnlock()
						RecLock("TRB",.t.)
						TRB->TRB_LINHA	:= " "
						MsUnlock()
						RecLock("TRB",.t.)
						TRB->TRB_LINHA	:= cCab2TXT
						MsUnlock()
						RecLock("TRB",.t.)
						TRB->TRB_LINHA	:= cCab3TXT
						MsUnlock()
						cPrivez := "NAO"
					EndIf
					RecLock("TRB",.t.)
					TRB->TRB_LINHA	:= " "
					MsUnlock()
					RecLock("TRB",.t.)
					TRB->TRB_LINHA	:= ( cAliasSBL )->B1_GRUPO+" "+( cAliasSBL )->B1_CODITE+STR0097+Transform(nMesDem,"@E 9999")+" < "+Transform(MV_PAR12,"@E 9999")
					MsUnlock()
					DBSelectArea(cAliasSBL)
					( cAliasSBL )->(DbSkip())
					Loop
				EndIf
			EndIf
			// Substitui Formula de TENDENCIA pela MEDIA 3 ULT.MESES

			DbSelectArea("SBL")
			DBSetOrder(1)
			IF !DbSeek(xFilial("SBL")+( cAliasSBL )->BL_PRODUTO+( cAliasSBL )->BL_ANO+( cAliasSBL )->BL_MES)
				If ( cAliasSBL )->BL_CODFORM == "PTE"
					cFormula := "(aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3"
					RecLock("SBL",.F.)
					SBL->BL_CODFORM := "PME"
					MsUnlock()
				endif
				// Substitui Formula de SAZONAL pela MEDIA 3 ULT.MESES
				If ( cAliasSBL )->BL_CODFORM == "PSA"
					cFormula := "(aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3"
					RecLock("SBL",.F.)
					SBL->BL_CODFORM := "PME"
					MsUnlock()
				endif
			Endif
			nDiasRep:=0
			IF ( cAliasSBL )->B1_TIPE == "H"
				nDiasRep:=MOD(( cAliasSBL )->B1_PE,24)
			ElseIF ( cAliasSBL )->B1_TIPE == "D"
				nDiasRep:=( cAliasSBL )->B1_PE
			ElseIF ( cAliasSBL )->B1_TIPE == "S"
				nDiasRep:=( cAliasSBL )->B1_PE*7
			ElseIF ( cAliasSBL )->B1_TIPE == "M"
				nDiasRep:=( cAliasSBL )->B1_PE*30
			ElseIF ( cAliasSBL )->B1_TIPE == "A"
				nDiasRep:=( cAliasSBL )->B1_PE*365
			EndIF
			// Grava SDF
			nEstMin:=0
			If lB1_ESTMIN
				nEstMin := ( cAliasSBL )->B1_ESTMIN
			EndIf
			_QTDSUGM := 0 // val(str(&cFormula,9,2))*(DSugest+nDiasRep)/30   // Qtd Calculada
			_QTDEST  := aSE[1] // Qtd Estoque
			_QTDPC   := aSE[2] // Qtd Pendente
			_QTDSUG  := ((_QTDSUGM-(_QTDEST+_QTDPC))+nEstMin)  // Qtd Sugerida
			If _QTDSUG > 0 .and. _QTDSUG < 1
				_QTDSUG := 1
			Endif
			///////////////////////////////////////////////////////////////////////////////////////
			//       ( ( Qtd.Sugerida - ( Qtd.Estoq + Qtd.Pendente ) ) + Qtd.Estq Minimo )       //
			///////////////////////////////////////////////////////////////////////////////////////
			IF ( ( _QTDSUGM - ( _QTDEST + _QTDPC ) ) + nEstMin ) > 0.49
				RecLock("SDF",.T.)
				SDF->DF_FILIAL  := _FIL
				SDF->DF_CODIGO  := _COD
				SDF->DF_FLAG    := "A"
				SDF->DF_PRODUTO := ( cAliasSBL )->BL_PRODUTO
				SDF->DF_QTDSUGM := _QTDSUGM
				SDF->DF_QTDEST  := aSE[1]
				SDF->DF_QTDPC   := aSE[2]
				SDF->DF_QTDSUG  := _QTDSUG
				IF ( cAliasSBL )->B1_QE > 0
					If int(SDF->DF_QTDSUG/( cAliasSBL )->B1_QE) < (SDF->DF_QTDSUG/( cAliasSBL )->B1_QE)
						SDF->DF_QTDSUG := (int(SDF->DF_QTDSUG/( cAliasSBL )->B1_QE) + 1) * ( cAliasSBL )->B1_QE
					Else
						SDF->DF_QTDSUG := int(SDF->DF_QTDSUG/( cAliasSBL )->B1_QE) * ( cAliasSBL )->B1_QE
					EndIf
				EndIF
				if !Empty(cFormul)
					If SDF->DF_QTDINF > 0
						SDF->DF_VLRTOT  := SDF->DF_QTDINF*Fg_Formula(cFormul) //(SDF->DF_QTDINF*&(VEG->VEG_FORMUL))
					Else
						SDF->DF_VLRTOT  := SDF->DF_QTDSUG*Fg_Formula(cFormul) //(SDF->DF_QTDSUG*&(VEG->VEG_FORMUL))
					EndIf
				Else
					If TipPrc == 1
						If SDF->DF_QTDINF > 0
							If (SDF->DF_QTDINF*( cAliasSBL )->B1_UPRC) > 0
								SDF->DF_VLRTOT  := (SDF->DF_QTDINF*( cAliasSBL )->B1_UPRC)
							Else
								SB1->(DbSetOrder(1))
								SB1->(dbseek(xFilial("SB1")+( cAliasSBL )->B1_COD))
								SB2->(DbSetOrder(1))
								SB2->(dbseek(xFilial("SB2")+( cAliasSBL )->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
								SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB2->B2_CM1)
							EndIf
						Else
							If (SDF->DF_QTDSUG*( cAliasSBL )->B1_UPRC) > 0
								SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*( cAliasSBL )->B1_UPRC)
							Else
								SB1->(DbSetOrder(1))
								SB1->(dbseek(xFilial("SB1")+( cAliasSBL )->B1_COD))
								SB2->(DbSetOrder(1))
								SB2->(dbseek(xFilial("SB2")+( cAliasSBL )->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
								SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB2->B2_CM1)
							EndIf
						EndIf
					ElseIf TipPrc == 2
						SBM->(DbSetOrder(1))
						SBM->(dbseek(xFilial("SBM")+( cAliasSBL )->B1_GRUPO))
						VI3->(DbSetOrder(1))
						VI3->(dbseek(xFilial("VI3")+SBM->BM_CODMAR+( cAliasSBL )->B1_CODITE))
						SB5->(DbSetOrder(1))
						SB5->(dbseek(xFilial("SB5")+( cAliasSBL )->B1_COD))
						VE5->(DbSetOrder(1))
						VE5->(dbseek(xFilial("VE5")+SBM->BM_CODMAR+( cAliasSBL )->B1_GRUDES))
						VEG->(DbSetOrder(1))
						VEG->(dbseek(xFilial("VEG")+VE5->VE5_FORPRP))
						If Empty(SB1->B1_GRUDES) .or. Empty(VE5->VE5_FORPRP) .or. Empty(VEG->VEG_FORMUL)
							If SDF->DF_QTDINF > 0
								SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB5->B5_PRV2)
							Else
								SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB5->B5_PRV2)
							EndIf
						Else
							If SDF->DF_QTDINF > 0
								SDF->DF_VLRTOT  := (SDF->DF_QTDINF*&(VEG->VEG_FORMUL))
							Else
								SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*&(VEG->VEG_FORMUL))
							EndIf
						EndIf
					Elseif TipPrc == 3 .or. TipPrc == 4
						SBM->(DbSetOrder(1))
						SBM->(dbseek(xFilial("SBM")+( cAliasSBL )->B1_GRUPO))
						VI3->(DbSetOrder(1))
						VI3->(dbseek(xFilial("VI3")+SBM->BM_CODMAR+( cAliasSBL )->B1_CODITE))
						SB5->(DbSetOrder(1))
						SB5->(dbseek(xFilial("SB5")+( cAliasSBL )->B1_COD))
						VEG->(DbSetOrder(1))
						VEG->(dbseek(xFilial("VEG")+GetMv("MV_FMLPECA")))
						If Empty(SB1->B1_GRUDES) .or. Empty(VEG->VEG_FORMUL)
							If SDF->DF_QTDINF > 0
								SDF->DF_VLRTOT  := (SDF->DF_QTDINF*( cAliasSBL )->B1_PRV1)
							Else
								SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*( cAliasSBL )->B1_PRV1)
							EndIf
						Else
							If SDF->DF_QTDINF > 0
								SDF->DF_VLRTOT  := (SDF->DF_QTDINF*&(VEG->VEG_FORMUL))
							Else
								SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*&(VEG->VEG_FORMUL))
							EndIf
						EndIf
					EndIF
				Endif
				If SDF->DF_VLRTOT < 0.01
					SDF->DF_VLRTOT := 0.01
				Endif
				SDF->DF_QTDINF  := SDF->DF_QTDSUG
				SDF->DF_M03     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3
				SDF->DF_M12     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3]+aConsumo[nAtual-4]+;
				aConsumo[nAtual-5]+aConsumo[nAtual-6]+aConsumo[nAtual-7]+aConsumo[nAtual-8]+;
				aConsumo[nAtual-9]+aConsumo[nAtual-10]+aConsumo[nAtual-11]+aConsumo[nAtual-12])/12
				SDF->DF_QE      :=If(( cAliasSBL )->B1_QE>99999,99999,IIF((cAliasSBL )->B1_QE<=0,1,(cAliasSBL )->B1_QE))
				SDF->DF_D01     :=aConsumo[nAtual-1]
				SDF->DF_D02     :=aConsumo[nAtual-2]
				SDF->DF_D03     :=aConsumo[nAtual-3]
				SDF->DF_D04     :=aConsumo[nAtual-4]
				SDF->DF_D05     :=aConsumo[nAtual-5]
				SDF->DF_D06     :=aConsumo[nAtual-6]
				SDF->DF_D07     :=aConsumo[nAtual-7]
				SDF->DF_D08     :=aConsumo[nAtual-8]
				SDF->DF_D09     :=aConsumo[nAtual-9]
				SDF->DF_D10     :=aConsumo[nAtual-10]
				SDF->DF_D11     :=aConsumo[nAtual-11]
				SDF->DF_D12     :=aConsumo[nAtual-12]
				MsUnlock()
				lGrava:=.T.
				lGrava2:=.T.
				nX++
			Else
				/*
				ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
				±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
				±±ÚÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
				±±³ Autor ³ Andre Luis Almeida                            ³ Data³23/10/02³±±
				±±ÃÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
				±±³Descric³Gera arq. \AP5\SIGAADV\SUGEST_N.TXT com os Itens nao sugeridos³±±
				±±ÀÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
				±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
				ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
				*/
				_PRODUTO := ( cAliasSBL )->BL_PRODUTO
				_QTDINF  := _QTDSUG

				if !Empty(cFormul)
//					VEG->(DbSetOrder(1))
//					VEG->(dbseek(xFilial("VEG")+cFormul))
					If _QTDINF > 0
						_VLRTOT  := _QTDINF*Fg_Formula(cFormul) //(_QTDINF*&(VEG->VEG_FORMUL))
					Else
						_VLRTOT  := _QTDSUG*Fg_Formula(cFormul) //(_QTDSUG*&(VEG->VEG_FORMUL))
					EndIf
				Else
					If TipPrc == 1
						If _QTDINF > 0
							_VLRTOT  := (_QTDINF*( cAliasSBL )->B1_UPRC)
							If _VLRTOT <= 0
								SB1->(DbSetOrder(1))
								SB1->(dbseek(xFilial("SB1")+( cAliasSBL )->B1_COD))
								SB2->(DbSetOrder(1))
								SB2->(dbseek(xFilial("SB2")+( cAliasSBL )->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
								_VLRTOT := (_QTDINF*SB2->B2_CM1)
							EndIf
						Else
							_VLRTOT  := (_QTDSUG*( cAliasSBL )->B1_UPRC)
							If _VLRTOT <= 0
								SB1->(DbSetOrder(1))
								SB1->(dbseek(xFilial("SB1")+( cAliasSBL )->B1_COD))
								SB2->(DbSetOrder(1))
								SB2->(dbseek(xFilial("SB2")+( cAliasSBL )->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")))
								_VLRTOT := (_QTDSUG*SB2->B2_CM1)
							EndIf
						EndIf
					ElseIf TipPrc == 2
						SBM->(DbSetOrder(1))
						SBM->(dbseek(xFilial("SBM")+( cAliasSBL )->B1_GRUPO))
						VI3->(DbSetOrder(1))
						VI3->(dbseek(xFilial("VI3")+SBM->BM_CODMAR+( cAliasSBL )->B1_CODITE))
						SB5->(DbSetOrder(1))
						SB5->(dbseek(xFilial("SB5")+( cAliasSBL )->B1_COD))
						VE5->(DbSetOrder(1))
						VE5->(dbseek(xFilial("VE5")+SBM->BM_CODMAR+( cAliasSBL )->B1_GRUDES))
						VEG->(DbSetOrder(1))
						VEG->(dbseek(xFilial("VEG")+VE5->VE5_FORPRP))
						If Empty(SB1->B1_GRUDES) .or. Empty(VE5->VE5_FORPRP) .or. Empty(VEG->VEG_FORMUL)
							If _QTDINF > 0
								_VLRTOT  := (_QTDINF*SB5->B5_PRV2)
							Else
								_VLRTOT  := (_QTDSUG*SB5->B5_PRV2)
							EndIf
						Else
							If _QTDINF > 0
								_VLRTOT  := (_QTDINF*&(VEG->VEG_FORMUL))
							Else
								_VLRTOT  := (_QTDSUG*&(VEG->VEG_FORMUL))
							EndIf
						EndIf
					Else
						SBM->(DbSetOrder(1))
						SBM->(dbseek(xFilial("SBM")+( cAliasSBL )->B1_GRUPO))
						VI3->(DbSetOrder(1))
						VI3->(dbseek(xFilial("VI3")+SBM->BM_CODMAR+( cAliasSBL )->B1_CODITE))
						SB5->(DbSetOrder(1))
						SB5->(dbseek(xFilial("SB5")+( cAliasSBL )->B1_COD))
						VEG->(DbSetOrder(1))
						VEG->(dbseek(xFilial("VEG")+GetMv("MV_FMLPECA")))
						If Empty(( cAliasSBL )->B1_GRUDES) .or. Empty(VEG->VEG_FORMUL)
							If _QTDINF > 0
								_VLRTOT  := (_QTDINF*( cAliasSBL )->B1_PRV1)
							Else
								_VLRTOT  := (_QTDSUG*( cAliasSBL )->B1_PRV1)
							EndIf
						Else
							If _QTDINF > 0
								_VLRTOT  := (_QTDINF*&(VEG->VEG_FORMUL))
							Else
								_VLRTOT  := (_QTDSUG*&(VEG->VEG_FORMUL))
							EndIf
						EndIf
					EndIF
				Endif
				If _VLRTOT < 0.01
					_VLRTOT := 0.01
				Endif
				_M03     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3
				_M12     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3]+aConsumo[nAtual-4]+;
				aConsumo[nAtual-5]+aConsumo[nAtual-6]+aConsumo[nAtual-7]+aConsumo[nAtual-8]+;
				aConsumo[nAtual-9]+aConsumo[nAtual-10]+aConsumo[nAtual-11]+aConsumo[nAtual-12])/12
				_QE      :=If(( cAliasSBL )->B1_QE>99999,99999,( cAliasSBL )->B1_QE)
				_D01     :=aConsumo[nAtual-1]
				_D02     :=aConsumo[nAtual-2]
				_D03     :=aConsumo[nAtual-3]
				_D04     :=aConsumo[nAtual-4]
				_D05     :=aConsumo[nAtual-5]
				_D06     :=aConsumo[nAtual-6]
				_D07     :=aConsumo[nAtual-7]
				_D08     :=aConsumo[nAtual-8]
				_D09     :=aConsumo[nAtual-9]
				_D10     :=aConsumo[nAtual-10]
				_D11     :=aConsumo[nAtual-11]
				_D12     :=aConsumo[nAtual-12]
				nlinha += 3
				If cPrivez == "SIM" .or. nlinha > 57
					nlinha := 5
					RecLock("TRB",.t.)
					TRB->TRB_LINHA	:= If(cPrivez=="SIM",CHR(15),CHR(12))
					MsUnlock()
					RecLock("TRB",.t.)
					TRB->TRB_LINHA	:= cCab1TXT+Transform(nPagina++,"99999")
					MsUnlock()
					RecLock("TRB",.t.)
					TRB->TRB_LINHA	:= " "
					MsUnlock()
					RecLock("TRB",.t.)
					TRB->TRB_LINHA	:= cCab2TXT
					MsUnlock()
					RecLock("TRB",.t.)
					TRB->TRB_LINHA	:= cCab3TXT
					MsUnlock()
					cPrivez := "NAO"
				EndIf
				RecLock("TRB",.t.)
				TRB->TRB_LINHA	:= " "
				MsUnlock()
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+_PRODUTO))
				RecLock("TRB",.t.)
				TRB->TRB_LINHA	:=  SB1->B1_GRUPO +" "+ SB1->B1_CODITE +" "+ SubStr(SB1->B1_DESC,1,30) + Transform(_VLRTOT,"@E 999,999.99") + Transform(nDiasRep,"@E 99999999") + Transform(_QTDSUGM,"@E 9999999") + Transform(_QTDEST,"9999999") + Transform(_QTDPC,"9999999") + Transform(nEstMin,"9999999")+" "+ Transform(_QTDSUGM-(_QTDEST+_QTDPC)+nEstMin,"@E 9999999")
				MsUnlock()
				RecLock("TRB",.t.)
				TRB->TRB_LINHA	:= space(5)+Transform(_M12,"999999999") + Transform(_M03,"999999999") + Transform(_QE,"99999")+"  "+IF(_D01 >0,Transform(_D01,"999999"),"     -")+IF(_D02 >0,Transform(_D02,"999999"),"     -")+IF(_D03 >0,Transform(_D03,"999999"),"     -")+IF(_D04 >0,Transform(_D04,"999999"),"     -")+IF(_D05 >0,Transform(_D05,"999999"),"     -")+IF(_D06 >0,Transform(_D06,"999999"),"     -")+IF(_D07 >0,Transform(_D07,"999999"),"     -")+IF(_D08 >0,Transform(_D08,"999999"),"     -")+IF(_D09 >0,Transform(_D09,"999999"),"     -")+IF(_D10 >0,Transform(_D10,"999999"),"     -")+IF(_D11 >0,Transform(_D11,"999999"),"     -")+IF(_D12 >0,Transform(_D12,"999999"),"     -") +"  "+ SBL->BL_CODFORM +"  "+ SBL->BL_ABCVEND + SBL->BL_ABCCUST
				MsUnlock()
				////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			EndIF
		EndIF
	EndIF
	DBSelectArea(cAliasSBL)
	( cAliasSBL )->(DbSkip())
EndDo
(cAliasSBL)->(dbCloseArea())

// Se tem registro no SB2/SBL Grava
dbSelectArea("SFJ")
IF  lGrava
	IF ( __lSx8 )
		ConfirmSX8()
	EndIF
	DbSelectArea("SFJ")
	IF ! DbSeek(xFilial("SFJ")+cCodigo)
		RecLock("SFJ",.T.)
		cSugegs+=IF(cSugegs="",+cCodigo," / "+cCodigo)
		SFJ->FJ_FILIAL  := _FIL
		SFJ->FJ_CODIGO  := _COD
		SFJ->FJ_DATREF  := dDataBase
		SFJ->FJ_DIASSUG := DSugest
		SFJ->FJ_CUSUNIT := Str(ClasCust,1)
		SFJ->FJ_TIPPRC  := Str(TipPrc,1)
		SFJ->FJ_IMPORT  := Str(Impot,1)
		SFJ->FJ_CLASSIF := cABC
		SFJ->FJ_ANO     := SubStr(cAnoMes,1,4)
		SFJ->FJ_MES     := SubStr(cAnoMes,5,2)
		SFJ->FJ_GRUPODE := Left(cGrp,4)
		SFJ->FJ_GRUPOAT := Right(cGrp,4)//strzero(MV_PAR11,2)+"x"+strzero(MV_PAR12,2)
		SFJ->FJ_SOLICIT := ""
		If SFJ->(FieldPos("FJ_GRUDESC")) > 0
			SFJ->FJ_GRUDESC := cGrpDesc
		EndIf
	EndIF
	MsUnlock()
Else
	RollBackSx8()
EndIF
SDF->(DbSetOrder(1))
IF lGeraOutra
	cCodigo := CriaVar("FJ_CODIGO",.T.)
	_COD := cCodigo
	MT297MIncGt(cAlias,9)
	Return .t.
EndIF
IF lGerou2
	MsgInfo(STR0065+Str(nQtdGer,3)+STR0066+" --> "+cSugegs)
	nQtdGer:=1
	cSugegs:=""
EndIF
///////////////////////////////////////////////////////////////////////////////////////////////////////
cItensNao := __RELDIR+"SUGEST_N.##r"
DbSelectArea("TRB")
Copy to &cItensNao sdf
DbSelectArea("TRB")
oObjTempTable:CloseTable()
//////////////////////////////////////////////////////////////////////////////////////////////////////
RestArea(cAliasAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MVist³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualizacao de Sugestao de Compras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297MVist()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MVist()
Local aAltEnChoice := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local NI	 := 0
PRIVATE nOpca   := 2
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03","DF_D04",;
"DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12","DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
PRIVATE aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_FORMUL","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE","FJ_GRUPOAT","FJ_CLASSIF","FJ_GRUDESC",;
"FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND","FJ_TIPPED","FJ_ORIPED"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

PRIVATE nUsado := 0

MT297MF12(.f.) // Desabilita F12

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
RegToMemory("SFJ",.F.)
MontaHead()
MontaCols()
lRet:=Modelo3(cCadastro,"SFJ","SDF",aCpoEnChoice,"MTA297MLit()","MTA297MOKt()",2,2,,,,aAltEnchoice,"",aAltGetDados)

MT297MF12(.t.) // Habilita F12

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MExct³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exclusao de Sugestao de Compras                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297MExct()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MExct()
Local aAltEnChoice := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local nI 	       := 0
Local lRet         := .T.

PRIVATE nOpca        := 2
PRIVATE aCols        := {}
PRIVATE aHeader      := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03","DF_D04",;
"DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12","DF_QTDEST",;
"DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
PRIVATE nUsado       := 0
PRIVATE aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_FORMUL","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE",;
"FJ_GRUPOAT","FJ_CLASSIF","FJ_GRUDESC","FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT",;
"FJ_COND","FJ_TIPPED","FJ_ORIPED"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09",;
"DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

MT297MF12(.f.) // Desabilita F12

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF !Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297EXC")
Else
	BEGIN TRANSACTION
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Boby - 06/04/2010 - Criar PE para Excluir no orcamento de oficina ³
		//³ FNC  - 7302/2010    uma peça que gerou solicitação compra         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("MT297EXC")
			ExecBlock("MT297EXC",.f.,.f.)
		EndIf

		RegToMemory("SFJ",.F.)
		MontaHead()
		MontaCols()
		lRet:=Modelo3(cCadastro,"SFJ","SDF",aCpoEnChoice,,"MTA297MOKt()",5,4,,,,aAltEnchoice,"",aAltGetDados)
		oPedido := DMS_Pedido():New()
		cMotBo := ""
		IF lRet
			SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
			While SDF->DF_CODIGO==SFJ->FJ_CODIGO .and. SDF->DF_FILIAL==xFilial("SDF") .and. ! SDF->(Eof())
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial('SB1') + SDF->DF_PRODUTO))
				If Empty(cMotBo) // só pergunta 1 vez
					cMotBo := OFA210MOT('000015',,,,.F.,)[1] // 15 => MOTIVO DO CANCELAMENTO DE BACKORDER
				EndIf
				oPedido:DelBoItem({; // pode deletar o sdf por isso a re-checagem abaixo
					{ 'VE6_SUGCOM', SFJ->FJ_CODIGO  },;
					{ 'VS3_CODITE', SB1->B1_CODITE  },;
					{ 'VS3_GRUITE', SB1->B1_GRUPO   },;
					{ 'MOTIVO'    , cMotBo          } ;
				})
				IF FM_SQL(' SELECT COUNT(*) FROM  '+RetSqlName('SDF')+" WHERE R_E_C_N_O_ = '"+AllTrim(str(SDF->(recno()) ))+"' AND D_E_L_E_T_ = '' ") > 0
					SDF->(RecLock("SDF",.F.))
					SDF->(DbDelete())
					SDF->(MsUnlock())
				EndIf
				SDF->(DbSkip())
			EndDo
			if FM_SQL('SELECT COUNT(*) FROM ' + RetSqlName('SFJ') + " WHERE FJ_FILIAL ='"+xFilial('SFJ')+"' AND D_E_L_E_T_ = ' ' AND FJ_CODIGO = '"+SFJ->FJ_CODIGO+"' ") > 0
				SFJ->(RecLock("SFJ",.F.))
				SFJ->(DbDelete())
				SFJ->(MsUnlock())
			EndIf
		EndIF


		If ! lRet
			DisarmTransaction()
		EndIF
	END TRANSACTION
EndIF

MT297MF12(.t.) // Habilita F12

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MAltt³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alteracao de Sugestao de Compras                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297MAltt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MAltt()
Local aAltEnChoice := {"FJ_TIPPRC","FJ_FORMUL","FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND","FJ_DATDIS"}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local nI
Local oPedido := DMS_Pedido():New()
PRIVATE nOpca   := 4
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {"DF_QTDINF","DF_PRODUTO","DF_CODGRP","DF_CODITE"}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03",;
"DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12",;
"DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
PRIVATE nUsado := 0
PRIVATE aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_FORMUL","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE","FJ_GRUPOAT","FJ_CLASSIF","FJ_GRUDESC",;
"FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND", "FJ_TIPPED","FJ_ORIPED"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

MT297MF12(.f.) // Desabilita F12

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF Empty(SFJ->FJ_SOLICIT)
	nTipPrc := SFJ->FJ_TIPPRC
	RegToMemory("SFJ",.F.)
	//	RegToMemory("SDF",.F.)

	If ! FJ_TIPPED == oPedido:GtTpPedBO()
		aAdd(aAltGetDados, "DF_QTDINF")
	EndIF

	MontaHead()
	MontaCols()
	SetKey(VK_F4, {|c| MATA297M_001ConsultaPecas() } )
	lRet:=Modelo3(cCadastro,"SFJ","SDF",aCpoEnChoice,"MTA297MLit()","MTA297MOKt()",4,4,"MTA297MFil()",,,aAltEnchoice,"",aAltGetDados)
	SetKey(VK_F4, Nil )
Else
	Help(" ",1,"MTA297GER")
EndIF

MT297MF12(.t.) // Habilita F12
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MImpt³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao de Sugestao de Compras                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Mt297MImpt()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MImpt()
Local cAliasAnt := GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1       := STR0012 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := STR0013 //"de acordo com os parametros informados pelo usuario."
Local cDesc3       := ""
Local nLin         := 220
Local Cabec1       := ""
Local Cabec2       := ""
Private li         := 0
Private nTamanho   := "G"
Private At_Prg     := "MATA297" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 15
Private aReturn    := {STR0014, 1, STR0015, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey   := 0
Private Titulo     := STR0001 //"Sugestao de Compras"
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "SugComp" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "SDF"
Private Limite     := 132

MT297MF12(.f.) // Desabilita F12

dbSelectArea("SDF")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//wnrel := SetPrint(cString,At_Prg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,nTamanho,,.T.)
wnrel   := SetPrint(cString,At_Prg,nil,@titulo,cDesc1,cDesc2,cDesc3,.F. ,   ,.T.,nTamanho,,.T.)

IF nLastKey == 27
	MT297MF12(.t.) // Habilita F12
	Return
EndIF

SetDefault(aReturn,cString)

IF nLastKey == 27
	MT297MF12(.t.) // Habilita F12
	Return
EndIF
nTipo := IF(aReturn[4]==1,15,18)

If GetMv("MV_VEICULO") == "S"

	SDF->(DbSetOrder(1))
	SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
	VEI->(DbSetOrder(1))
	VEI->(DbSeek( xFilial("VEI") + Traz_Marca(SDF->DF_PRODUTO) + SFJ->FJ_SOLICIT ))

	TITULO += " - "+VEI->VEI_PEDFAB
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| M297MImpRT(Cabec1,Cabec2,Titulo,nLin) },Titulo)

RestArea(cAliasAnt)

MT297MF12(.t.) // Habilita F12

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MGert³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao de Solicitacao/Pedido de Compras                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297MGert()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Mata297                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MGert(nViaTrans,cCodTrans,nPagto48h,cPedFab,cTipPed)
Local cAliasAnt:=GetArea()
Local cCont    := repl("0",TamSx3("C7_ITEM")[1])
Local aCab     :={}
Local aItem    :={}
Local cScAnt
Local cNumero
Local aArea    := {}
Local cObsVE6  := ""

if GetNewPar("MV_PEDANO","N")=="S"
	cPedFab := cPedFab + "/" + Right(Alltrim(str(Year(DDATABASE),4)),2)
endif

IF ! Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297GER")
	Return
EndIF

IF M->FJ_TIPGER=="1"
	cNumero  :=CriaVar("C1_NUM",.T.)
	IF !(SC1->(dbSeek(xFilial("SC1")+cNumero)))
		cScAnt := NextNumero("SC1",1,"C1_NUM",.F.,cNumero)
		IF  cScAnt # cNumero
			cNumero := cScAnt
		EndIF
	EndIF

	//	aCab := {{"C1_NUM"		,cNumero   ,Nil},;
	//	{"C1_EMISSAO"	,dDataBase ,Nil}}

	aCab := {{"C1_NUM"    ,cNumero   ,Nil},;
	{"C1_SOLICIT",cusername ,Nil},;
	{"C1_EMISSAO",dDataBase ,Nil},;
	{"C1_FILENT" , M->FJ_FILENT ,Nil}}


	SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
	While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
		//      If (SDF->DF_QTDINF+SDF->DF_QTDSUG) > 0
		//	    	SB1->(DbSetOrder(1))
		//   		SB1->(DbSeek(xFilial("SB1")+SDF->DF_PRODUTO))
		//  		AADD(aItem,{{"C1_ITEM"    ,StrZero(nCont,2) ,Nil },;
		//                    {"C1_PRODUTO" ,SDF->DF_PRODUTO  ,Nil },;
		//                    {"C1_UM" ,SB1->B1_UM ,Nil },;
		//                    {"C1_QUANT"   ,IF(SDF->DF_QTDINF > 0,SDF->DF_QTDINF,SDF->DF_QTDSUG),Nil },;
		//                    {"C1_FORNECE" ,SB1->B1_PROC,Nil }})
		//   		nCont++
		//      Endif
		If SDF->DF_QTDINF > 0
			cCont := Soma1( cCont , TamSx3("C7_ITEM")[1] )
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SDF->DF_PRODUTO))
			AADD(aItem,{{"C1_ITEM"    , cCont ,Nil },;
			{"C1_PRODUTO" ,SDF->DF_PRODUTO  ,Nil },;
			{"C1_UM" ,SB1->B1_UM ,Nil },;
			{"C1_QUANT"   ,SDF->DF_QTDINF,Nil },;
			{"C1_FORNECE" ,SB1->B1_PROC,Nil },;
			{"C1_LOJA"    ,SB1->B1_LOJPROC,Nil }})
		Endif
		SDF->(DbSkip())
	EndDo
	lMsErroAuto := .f.
	MSExecAuto({|x,y| MATA110(x,y)},aCab,aItem)
	IF ! lMSErroAuto
		IF ( __lSx8 )
			ConfirmSX8()
		EndIF
		RecLock("SFJ",.F.)
		SFJ->FJ_SOLICIT:=cNumero
		SFJ->FJ_TIPGER :=M->FJ_TIPGER
		SFJ->(MsUnlock())
		SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
			RecLock("SDF",.F.)
			SDF->DF_FLAG    := "F"
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
	Else
		Help(" ",1,"MTA297GER1")
		RollBackSx8()
		DisarmTransaction()
		Break
	EndIF
ElseIF M->FJ_TIPGER=="2"
	If Empty(M->FJ_FORNECE) .or. Empty(M->FJ_LOJA) .or. Empty(M->FJ_COND)
		Help(" ",1,"MTA297GER2")
		Return
	EndIF
	
	aArea := sGetArea(aArea,"VE6") //Salva o posicionamento da tabela VE6 para alterar o indice para 9
	DbSelectArea("VE6")
	DbSetOrder(9)

	cNumero  :=CriaVar("C7_NUM",.T.)
	SA2->(dbSeek(xFilial("SA2")+M->FJ_FORNECE+M->FJ_LOJA))
	aCab:={ {"C7_NUM"     ,cNumero        ,Nil},; // Numero do Pedido
			{"C7_EMISSAO" ,dDataBase      ,Nil},; // Data de Emissao
			{"C7_FORNECE" ,M->FJ_FORNECE  ,Nil},; // Fornecedor
			{"C7_LOJA"    ,M->FJ_LOJA     ,Nil},; // Loja do Fornecedor
			{"C7_COND"    ,M->FJ_COND     ,Nil},; // Condicao de pagamento
			{"C7_CONTATO" ,"            " ,Nil},; // Contato
			{"C7_FILENT"  ,M->FJ_FILENT   ,Nil} } // Filial Entrega

	SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
	cCodMar:=Traz_Marca(SDF->DF_PRODUTO)

	While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SDF->DF_PRODUTO))
		If SDF->DF_QTDINF > 0
			
			cObsVE6 := ""
			If VE6->(DBSeek(xFilial("VE6")+"0"+SFJ->FJ_CODIGO+SB1->B1_GRUPO+SB1->B1_CODITE))
				cObsVE6 := VE6->VE6_OBSPED
			EndIf

			cCont := Soma1( cCont , TamSx3("C7_ITEM")[1] )
			aadd(aItem,{{"C7_ITEM"   , cCont                           ,Nil},; //Numero do Item
						{"C7_PRODUTO", SDF->DF_PRODUTO                 ,Nil},; //Codigo do Produto
						{"C7_UM"     , SB1->B1_UM                      ,Nil},; //Unidade de Medida
						{"C7_QUANT"  , SDF->DF_QTDINF                  ,Nil},; //Quantidade
						{"C7_PRECO"  , (SDF->DF_VLRTOT/SDF->DF_QTDINF) ,Nil},; //Preco
						{"C7_DATPRF" , dDataBase                       ,Nil},; //Data De Entrega
						{"C7_FLUXO"  , "S"                             ,Nil},; //Fluxo de Caixa (S/N)
						{"C7_LOCAL"  , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") ,Nil},; //Localizacao
						{"C7_OBS"    , cObsVE6                         ,Nil}}) // Observação do Pedido VE6

			if SFJ->(FieldPos("FJ_TIPPED")) <> 0 .and. SC7->(FieldPos("C7_TIPPED")) <> 0
				aAdd(aItem[Len(aItem)],{"C7_TIPPED"  , M->FJ_TIPPED,Nil})
			endif

			//                       {"C7_CODITE" ,SB1->B1_CODITE         ,Nil},;
			//	                      {"C7_CODGRP",SB1->B1_GRUPO          ,Nil}})
		EndIf
		SDF->(DbSkip())
	EndDo
	
	DbSelectArea("VE6")
	sRestArea(aArea) // Retorna o posicionamento na tabela VE6 para antes da alteração de indice

	lMsErroAuto := .f.
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,3)
	IF ! lMSErroAuto
		IF ( __lSx8 )
			ConfirmSX8()
		EndIF
		RecLock("SFJ",.F.)
		SFJ->FJ_SOLICIT:=cNumero
		SFJ->FJ_FORNECE:=M->FJ_FORNECE
		SFJ->FJ_LOJA   :=M->FJ_LOJA
		SFJ->FJ_TIPGER :=M->FJ_TIPGER
		SFJ->FJ_FILENT :=M->FJ_FILENT
		SFJ->FJ_COND   :=M->FJ_COND
		If SFJ->(FieldPos("FJ_DATDIS")) # 0
			SFJ->FJ_DATDIS := M->FJ_DATDIS
		EndIf
		SFJ->(MsUnlock())
		SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
			RecLock("SDF",.F.)
			SDF->DF_FLAG := "F"
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
		//Gravar Pedido da MIL aqui
		If GetMV("MV_VEICULO") == "S"

			SC7->(DbSetOrder(1))
			SC7->(DbSeek( xFilial("SC7") + cNumero ))
			cAprocacao := SC7->C7_CONAPRO

			VE4->(dbseek(xFilial("VE4")+cCodMar))
			If !Empty(VE4->VE4_ULTPED)
				RecLock("VE4",.f.)
				VE4->VE4_ULTPED := val(cPedFab)
				MsUnLock()
			EndIf
			If !("VEI"$cFopened)
				ChkFile("VEI",.F.)
			EndIf
			cNumOSv := ""
			cChaInt := ""
			VE6->(DbSeek(xFilial("VE6")+SFJ->FJ_CODIGO))
			VEJ->(DbSetOrder(1))
			VEJ->(DbSeek(xFilial("VEJ")+VE6->VE6_CODMAR+VE6->VE6_FORPED))
			If VEJ->VEJ_PROGRA == "2" // Unidade Parada
				cNumOSv := VE6->VE6_NUMOSV
				cChaInt := VE6->VE6_CHAINT
			EndIf
			if !lJohnDeere
				RecLock("VEI",.T.)
				VEI->VEI_FILIAL :=xFilial("VEI")
				VEI->VEI_CODMAR :=cCodMar
				VEI->VEI_NUM    :=cNumero
				VEI->VEI_NUMOSV :=cNumOSv
				VEI->VEI_CHAINT :=cChaInt

				If !Empty(VE4->VE4_ULTPED)
					if GetNewPar("MV_PEDANO","N")=="S"
						VEI->VEI_PEDFAB :=if(VE4->VE4_PEDINI>0,strzero(val(cPedFab),10)+Right(cPedFab,3),space(13-len(alltrim(cPedFab)))+alltrim(cPedFab))
					else
						VEI->VEI_PEDFAB :=if(VE4->VE4_PEDINI>0,StrZero(val(cPedFab),13),Alltrim(cPedfab)+space(13-len(alltrim(cPedFab)))) //+alltrim(cPedFab))
					endif
				Else
					VEI->VEI_PEDFAB := cPedFab
				Endif

				VEI->VEI_TIPPED :=cTipPed
				VEI->VEI_VIATRA :=Str(nViaTrans,1)
				VEI->VEI_TRANSP :=cCodTrans
				VEI->VEI_PGT48H :=Str(nPagto48h,1)
				VEI->VEI_DATSC7 :=dDataBase
				VEI->VEI_HORSC7 :=Val(Substr(Time(),1,2)+Substr(Time(),4,2))
				// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
				// obs nos pedidos emergencia  para atender layout RAC
				If VEJ->VEJ_PROGRA $ "2/3" // Emergencia ou programado
					VEI->VEI_OBSPED := VE6->VE6_OBSPED
				EndIf
				// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
				If SFJ->(FieldPos("FJ_DATDIS")) # 0
					VEI->VEI_DATDIS := SFJ->FJ_DATDIS
				EndIf
				VEI->(MsUnlock())
			endif
		EndIF
	Else
		Help(" ",1,"MTA297GER1")
		RollBackSx8()
		DisarmTransaction()
		Break
	EndIF
EndIF
RestArea(cAliasAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MCant³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cancelamento de Solicitacao/Pedido de Compras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297MCant()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Mata297                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MCant()
Local aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_FORMUL","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE",;
"FJ_GRUPOAT","FJ_CLASSIF","FJ_GRUDESC","FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND","FJ_TIPPED","FJ_ORIPED"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

Local aAltEnChoice := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet , cSolicit:=""
Local aCab      :={}
Local aItem     :={}
Local nI		:= 0
PRIVATE nOpca   := 5
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12","DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
PRIVATE nUsado := 0

MT297MF12(.f.) // Desabilita F12

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297CAN")
Else
	RegToMemory("SFJ",.F.)
	MontaHead()
	MontaCols()
	lRet:=Modelo3(cCadastro,"SFJ","SDF",aCpoEnChoice,,"MTA297MOKt()",5,4,,,,aAltEnchoice,"",aAltGetDados)
	lMshelpAuto := .t.
	Begin Transaction
	IF lRet .and. M->FJ_TIPGER=="1" //Cancela Solicitacao de Compra
		SC1->(DbSetOrder(1))
		If SC1->(DbSeek(xFilial("SC1")+SFJ->FJ_SOLICIT))
			AADD(aCab ,{"C1_NUM"	,SFJ->FJ_SOLICIT ,Nil})
			AADD(aItem,{{"C1_NUM"	,SFJ->FJ_SOLICIT ,Nil}})
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| MATA110(x,y,z)},aCab,aItem,5)
		EndIf
	ElseIF lRet .and. M->FJ_TIPGER=="2" //Cancela Pedido de Compra
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7")+SFJ->FJ_SOLICIT))
			AADD(aCab ,{"C7_NUM"	,SFJ->FJ_SOLICIT ,Nil})
			AADD(aItem,{{"C7_NUM"	,SFJ->FJ_SOLICIT ,Nil}})
			lMsErroAuto := .f.
			lRet := MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,5)
		EndIf
	EndIF
	IF lRet .and. !lMSErroAuto
		If FM_SQL('select count(*) from ' + RetSqlName('SFJ') + " WHERE FJ_FILIAL ='"+xFilial('SFJ')+"' AND D_E_L_E_T_ = ' ' AND FJ_CODIGO = '"+SFJ->FJ_CODIGO+"' ") > 0
			cSolicit := SFJ->FJ_SOLICIT

			RecLock("SFJ",.F.)
			SFJ->FJ_SOLICIT:=""
			SFJ->FJ_FORNECE:=M->FJ_FORNECE
			SFJ->FJ_LOJA   :=M->FJ_LOJA
			SFJ->FJ_FILENT :=""
			SFJ->FJ_TIPGER :=""
			SFJ->FJ_COND   :=""
			MsUnlock()
			SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
			While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())

				//Gravar Pedido da MIL aqui
				If GetMV("MV_VEICULO") == "S" .and. !lJohnDeere
					If !("VEI"$cFopened)
						ChkFile("VEI",.F.)
					EndIf
					DbSelectArea("VEI")
					DbSetOrder(1)
					If DbSeek(xFilial("VEI")+Traz_Marca(SDF->DF_PRODUTO)+cSolicit)
						RecLock("VEI",.F.,.T.)
						dbdelete()
						MsUnlock()
						WriteSx2("VEI")
					EndIf
				EndIF

				DbSelectArea("SDF")
				RecLock("SDF",.F.)
				SDF->DF_FLAG    := "A"
				SDF->(MsUnlock())
				SDF->(DbSkip())
			EndDo
		EndIf
	Else
		If lRet
			Help(" ",1,"MTA297CAN1")
			DisarmTransaction()
			Break
		EndIf
	EndIF
	End Transaction
	IF lMsErroAuto
		MostraErro()
	EndIF
	lMsErroAuto := .f.
	lMsHelpAuto := .f.
EndIF

MT297MF12(.t.) // Habilita F12

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M297MImpRT³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao de Sugestao de Compras                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³M297MImpRT(Cabec1,Cabec2,Titulo,nLin)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M297MImpRT(Cabec1,Cabec2,Titulo,nLin)
Local cText
Local nCont

Local nValor:=0
Local aGrupoDesc := {}
dbSelectArea(cString)
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(RecCount())
WCABEC0 := 4
WCABEC1 :=STR0016+SFJ->FJ_CODIGO+STR0017+DtoC(SFJ->FJ_DATREF)+STR0018+Str(SFJ->FJ_DIASSUG,2) //"Numero : "###"     Referencia : "###"     Sugestao p/ "
WCABEC1 :=WCABEC1+STR0021 //"     Tipo de Preco : "
WCABEC1 :=WCABEC1+IIF(SFJ->FJ_TIPPRC="1",STR0022,IIF(SFJ->FJ_TIPPRC="2",STR0023,STR0024)) //"Custo Medio"###"Reposicao"###"Preco de Venda"
WCABEC1 :=WCABEC1+STR0025+IIF(SFJ->FJ_CUSUNIT="1",STR0026,IIF(SFJ->FJ_CUSUNIT="2",STR0027,IIF(SFJ->FJ_CUSUNIT="3",STR0028,STR0064))) //"     Custo Unitario : "###"Alto"###"Medio"###"Baixo"## Todos
WCABEC1 :=WCABEC1+STR0029+IF(SFJ->FJ_IMPORT="1",STR0030,STR0031)+STR0032+SFJ->FJ_CLASSIF+If(!Empty(SFJ->FJ_SOLICIT),If(SFJ->FJ_TIPGER == "1",STR0072,STR0073),"")+SFJ->FJ_SOLICIT   //"     Importado : "###"Sim"###"Nao"###"     ClassIFicacao : " //"  N. Solicitacao: "###"  N. Pedido: "
WCABEC2 :=Replicate("-",IIF(nTamanho=="P",80,IIF(nTamanho=="G",220,132)))
WCABEC3 :=Space(80)+STR0033+STR0034+STR0035+STR0036+STR0037+STR0038+STR0039 //"Ultima                      "###"Media   "###"Media    "###"Media       "###"A      "###"Qtd. "###"------------------------------- Demanda -------------------------------"
WCABEC4 :=STR0040+STR0041+STR0042+STR0043+STR0044+STR0045+STR0046+STR0047+STR0048+STR0049+STR0050+STR0051+STR0052 //"Gir/Fin "###"Codigo               "###"Descricao                   "###"G.D Sugestao  "###"Pedido   "###"Compra       "###"Preco Total "###"12 Meses "###"3 Meses "###"p/ Calc. "###"Disp. "###"Receb. "###"Emb. "
//         <<A/A>>     000000000000000000000   XXXXXXXXXXXXXXXXXXXXXXXXXX   999999999999     9999999     99/99/99      999,999,999.99    99999999    99999999   99999999
For nCont:=1 to 12
	nMes := Val(SFJ->FJ_MES) + nCont
	If nMes > 12
		nMes := nMes - 12
		nAno := Val(SFJ->FJ_ANO)
	Else
		nAno := Val(SFJ->FJ_ANO) - 1
	EndIf
	WCABEC4+= strzero(nMes,2)+"/"+substr(strzero(nAno,4),3,4)+" "
	//   WCABEC4:=WCABEC4+StrZero(Month(SToD("15/"+SFJ->FJ_MES+"/"+substr(SFJ->FJ_ANO,3,2),"dd/mm/yy")-365+(nCont*30)),2)+"/"
	//   WCABEC4:=WCABEC4+SubStr(StrZero(Year(SToD("15/"+SFJ->FJ_MES+"/"+SFJ->FJ_ANO,"dd/mm/yy")-365+(nCont*30)),4),7,2)+Space(1)
Next
SBL->(DbSetOrder(1))
DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO)

While SDF->DF_FILIAL==xFilial("SDF") .and. SDF->DF_CODIGO == SFJ->FJ_CODIGO .and. !EOF()
	//LOCALIZA O SBL
	SBL->(DbSeek(xFilial("SBL")+SDF->DF_PRODUTO+SFJ->FJ_ANO+SFJ->FJ_MES))
	//LOCALIZA O PRODUTO
	SB1->(DbSeek(xFilial("SB1")+SDF->DF_PRODUTO))

	&& Totaliza grupo de desconto
	SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
	If Len(aGrupoDesc) == 0 .Or. ((nCont := Ascan(aGrupoDesc,{|x| x[1]+x[2] == SBM->BM_CODMAR+SB1->B1_GRUDES }) ) == 0)

		VE5->(DbSeek(xFilial("VE5")+SBM->BM_CODMAR+SB1->B1_GRUDES))

		Aadd(aGrupoDesc, { SBM->BM_CODMAR, SB1->B1_GRUDES, VE5->VE5_DESGRU, 0 } )
		nCont := Len(aGrupoDesc)

	EndIf

	If SDF->DF_QTDINF > 0
		aGrupoDesc[nCont,4] += SDF->DF_VLRTOT
	EndIf

	cText:=SBL->BL_ABCVEND+"/"+SBL->BL_ABCCUST+" "   // ABC Giro / Finaceiro
	cTExt:=cText+SB1->B1_GRUPO+" "+left(SB1->B1_CODITE,24)+" "+left(SB1->B1_DESC,20)+" "+left(SB1->B1_FABRIC,8)
	cTExt:=cText+Transform(SDF->DF_QTDSUG,"999999")+" >"+Transform(SDF->DF_QTDINF,"999999")+"< "

	cTExt:=cText+DToC(SB1->B1_UCOM)+Space(2)
	If SDF->DF_QTDINF > 0
		cTExt:=cText+Transform(SDF->DF_VLRTOT,"@E 9999,999,999.99")
	Else
		cTExt:=cText+Transform(0,"@E 9999,999,999.99")
	EndIf
	cTExt:=cText+Transform(SDF->DF_M12,"999999999")
	cTExt:=cText+Transform(SDF->DF_M03,"99999999")+Transform(SDF->DF_QTDSUGM,"999999999")
	cTExt:=cText+Transform(SDF->DF_QTDEST,"999999")+Transform(SDF->DF_QTDPC,"9999999")+Transform(SDF->DF_QE,"99999")
	//Demanda dos ultimos 12 Meses
	cTExt:=cText+IF(SDF->DF_D12 >0,Transform(SDF->DF_D12,"999999"),"     -")+IF(SDF->DF_D11 >0,Transform(SDF->DF_D11,"999999"),"     -")
	cTExt:=cText+IF(SDF->DF_D10 >0,Transform(SDF->DF_D10,"999999"),"     -")+IF(SDF->DF_D09 >0,Transform(SDF->DF_D09,"999999"),"     -")
	cTExt:=cText+IF(SDF->DF_D08 >0,Transform(SDF->DF_D08,"999999"),"     -")+IF(SDF->DF_D07 >0,Transform(SDF->DF_D07,"999999"),"     -")
	cTExt:=cText+IF(SDF->DF_D06 >0,Transform(SDF->DF_D06,"999999"),"     -")+IF(SDF->DF_D05 >0,Transform(SDF->DF_D05,"999999"),"     -")
	cTExt:=cText+IF(SDF->DF_D04 >0,Transform(SDF->DF_D04,"999999"),"     -")+IF(SDF->DF_D03 >0,Transform(SDF->DF_D03,"999999"),"     -")
	cTExt:=cText+IF(SDF->DF_D02 >0,Transform(SDF->DF_D02,"999999"),"     -")+IF(SDF->DF_D01 >0,Transform(SDF->DF_D01,"999999"),"     -")
	Impr(cText,"C")

	If SDF->DF_QTDINF > 0
		nValor += SDF->DF_VLRTOT
	EndIf

	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo
//Totais
Impr(Space(87)+"-----------------","C")
Impr(Space(89)+Transform(nValor,"@E 9999,999,999.99"),"C")

&& Imprime total Grupo de Desconto
Impr(Repl("-",05)+STR0098+Repl("-",32),"C")
Impr(STR0099,"C")
nValor := 0
For nCont:=1 to Len(aGrupoDesc)
	cText:= aGrupoDesc[nCont,1]+" "
	cText+= aGrupoDesc[nCont,2]+" "
	cText+= aGrupoDesc[nCont,3]+" "
	cText+= Transform(aGrupoDesc[nCont,4],"@E 9999,999,999.99")
	Impr(cText,"C")
	nValor += aGrupoDesc[nCont,4]
Next
Impr(Space(37)+"-----------------","C")
Impr(Space(39)+Transform(nValor,"@E 9999,999,999.99"),"C")

Impr("","F")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIF

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA297MLit³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Muda de Linha                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA297MLit()
Local lRet := .T.
Local lDeleted := .F.
IF ValType(aCols[n,Len(aCols[n])]) == "L"
	lDeleted := aCols[n,Len(aCols[n])]      // Verifica se esta Deletado
EndIF

IF ! lDeleted
	if !Empty(aCols[n,ProcH('DF_PRODUTO')]) .AND. FM_SQL('SELECT COUNT(*) FROM ' + oSqlHlp:NoLock('SB1') + " WHERE B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = '"+aCols[n,ProcH('DF_PRODUTO')]+"' AND D_E_L_E_T_ = ' '") > 0
		if aCols[n,ProcH('DF_QE')] > 0
			IF Mod(aCols[n,ProcH('DF_QTDINF')],If(aCols[n,ProcH('DF_QE')] > 0,aCols[n,ProcH('DF_QE')],1)  ) > 0
				IF M->FJ_TIPGER != "3"
					Help(" ",1,"MTA297LIN")
					lRet := .f.
				endif
			EndIF
		Endif

		If lRet
			dbSelectArea('SB1')
			lRet := FG_OBRIGAT()
		EndIf
	Else
		alert(STR0173 /*'Produto inválido'*/)
		lRet := .F.
	EndIf
EndIF
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA297MOKt³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tudo Ok                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA297MOKt()
Local lRet := .T.
Local ni
Local lDeleted := .F.
Local lContinua := .f.
Local nUltP := 0
Local cPerg := ""
Local nVldTot := 0
Local nCont:=0
Local cCodMar := ""

Local oFilHlp := DMS_FilialHelper():New()

Local lVS1_TRFRES := ( VS1->(FieldPos("VS1_TRFRES")) > 0 )

Private cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Private lFaseConfer := (At(cFaseConfer,GetMv("MV_FASEORC")) <> 0) // Fase de Conferencia
IF ValType(aCols[n,Len(aCols[n])]) == "L"
	lDeleted := aCols[n,Len(aCols[n])]      // Verifica se esta Deletado
EndIF
IF !lDeleted
	For ni = 1 To Len(aCols)
		IF Mod(aCols[ni,ProcH('DF_QTDINF')],If(aCols[ni,ProcH('DF_QE')] > 0,aCols[ni,ProcH('DF_QE')],1)  ) > 0
			IF M->FJ_TIPGER != "3"
				oGetDados:oBrowse:nat := n := ni
				oGetDados:oBrowse:SetFocus()
				Help(" ",1,"MTA297LIN")
				lRet := .f.
			endif
		EndIF
		IF !lRet
			Exit
		EndIF
	Next ni
Endif
Private cPreMar := "", cPrePed := "", cAprocacao := ""
IF nOpca == 4 //Alterar
	if Empty(M->FJ_TIPGER)
		MsgInfo(STR0100)
		Return(.f.)
	Endif
	if Empty(M->FJ_COND)
		MsgInfo(STR0101)
		Return(.f.)
	Endif
Endif
nTotCont := 0
For nCont:=1 to Len(aCols)
	nTotCont += aCols[nCont,FG_POSVAR("DF_QTDINF")]
Next
IF nOpca == 4 //Alterar
	If nTotCont <= 0
		MsgAlert(STR0102 ,STR0103)
		Return .F.
	EndIf
Endif
dbSelectArea("SFJ")
dbSetOrder(1)
if dbSeek(xFilial("SFJ")+M->FJ_CODIGO)
	if SFJ->(FieldPos("FJ_VALTOT")) <> 0
		DBSelectArea("SDF")
		DBSetOrder(1)
		DBSeek(xFilial("SDF")+M->FJ_CODIGO)
		nSumTot := 0
		while !eof() .and. xFilial("SDF")+M->FJ_CODIGO == SDF->DF_FILIAL + SDF->DF_CODIGO
			nSumTot += SDF->DF_VLRTOT
			DBSkip()
		enddo
		RecLock("SFJ",.f.)
		SFJ->FJ_VALTOT := nSumTot
		MsUnlock()
	endif
	RecLock("SFJ",.f.)
	SFJ->FJ_FORNECE := M->FJ_FORNECE
	SFJ->FJ_LOJA    := M->FJ_LOJA
	SFJ->FJ_FORMUL  := M->FJ_FORMUL
	MsUnlock()
Endif
IF nOpca == 4 //Alterar
	Begin Transaction
	IF M->FJ_TIPGER == "3"
		if !lRet
			DisarmTransaction()
			return .f.
		endif
		If MsgYesNo(STR0162,STR0062) //"Confirma a Geração do Orçamento de Transferência?"
			aFilis := {}
			VE4->(DBSetOrder(1))
			DBSelectArea("SX6")
			DBSetOrder(1)
			DBGoTop()
			while !eof()
				if Alltrim(SX6->X6_VAR) == "MV_MIL0005"
					aAdd(aFilis,Alltrim(SX6->X6_FIL))
				endif
				DBSkip()
			enddo

			aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Destino (MV_PAR05)
			cCGCDest := aSM0[18] // SM0->M0_CGC
			dbSelectArea("SA1")
			dbSetOrder(3)
			if !dbSeek(xFilial("SA1")+cCGCDest)
				MsgStop(STR0167 + Alltrim(cCGCDest) + STR0168)
				DisarmTransaction()
				return .f.
			endif
			cCodFilOT := xFilial("SD2")
			DBSelectArea("SA2")
			DBSetOrder(1)
			DBSeek(xFilial("SA2") + M->FJ_FORNECE + M->FJ_LOJA)
			nRecNoM0 := SM0->(RecNo())
			SM0->(DBGoTop())
			while !SM0->(eof())
				if Alltrim(SM0->M0_CGC) == SA2->A2_CGC
					if ascan(aFilis, Alltrim(SM0->M0_CODFIL)) > 0
						cCodFilOT := SM0->M0_CODFIL
						exit
					endif
				endif
				SM0->(DBSkip())
			enddo
			SM0->(DBGoTo(nRecNoM0))
			cFilAntOld := cFilAnt
			cFilAnt := cCodFilOT
			
			Pergunte("MT297MF12",.f.) // Pegar o STATUS que devera ser criado o Orcamento

			SA1->(DbGoTo( oFilHlp:GetCliente(M->FJ_FILIAL) ))

			dbSelectArea("VS1")
			RecLock("VS1",.t.)
			VS1->VS1_FILIAL := cCodFilOT
			VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
			VS1->VS1_TIPORC := "3" // Transferencia
			VS1->VS1_DATORC := dDatabase
			VS1->VS1_CLIFAT := SA1->A1_COD
			VS1->VS1_LOJA   := SA1->A1_LOJA
			VS1->VS1_NCLIFT := SA1->A1_NOME
			If MV_PAR01 == 2 // 2-SIM (cria Orcamento com a possibilidade de alteracao?)
				VS1->VS1_STATUS := "0" // Deixar o Status do Orcamento como 0=Aberto/Digitado
			Else // MV_PAR01 == 1-NAO (padrao)
				If lFaseConfer
					VS1->VS1_STATUS := cFaseConfer // Deixar o Status do Orcamento como Aguardando conferencia
				Else
					VS1->VS1_STATUS := "F" // Deixar o Status do Orcamento como Pronto para Transferir
				Endif
			EndIf
			VS1->VS1_FILDES := M->FJ_FILIAL
			VS1->VS1_ARMDES := "01"
			If lVS1_TRFRES
				VS1->VS1_TRFRES := CriaVar("VS1_TRFRES")
			EndIf
			ConfirmSX8()
			MsUnlock()
			If VS1->VS1_STATUS == cFaseConfer // Foi para Fase de Conferencia
				If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
					OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , VS1->VS1_NUMORC ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
				EndIf
			EndIf

			If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
				OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001+" - "+STR0187 ) // Grava Data/Hora na Mudança de Status do Orçamento / Sugestão de Compras / Transferência de Peças
			EndIf

			Pergunte(cPergMil,.f.)

			nSeq := 1
			For nCont := 1 to Len(aCols)
				if aCols[nCont,FG_POSVAR("DF_QTDINF")] > 0 .and. !aCols[nCont,Len(aCols[nCont])]
					dbSelectArea("SB1")
					dbSetOrder(1)
					DbSeek(xFilial("SB1") +  aCols[nCont,FG_POSVAR("DF_PRODUTO")])

					dbSelectArea("SB2")
					dbSetOrder(1)
					DbSeek(xFilial("SB2") +  aCols[nCont,FG_POSVAR("DF_PRODUTO")] + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )

					dbSelectArea("VS3")
					RecLock("VS3",.t.)
					VS3->VS3_FILIAL := cCodFilOT
					VS3->VS3_NUMORC := VS1->VS1_NUMORC
					VS3->VS3_SEQUEN := strzero(nSeq,3)
					VS3->VS3_GRUITE := SB1->B1_GRUPO
					VS3->VS3_CODITE := SB1->B1_CODITE
					VS3->VS3_QTDINI := aCols[nCont,FG_POSVAR("DF_QTDINF")]
					VS3->VS3_QTDITE := aCols[nCont,FG_POSVAR("DF_QTDINF")]
					VS3->VS3_VALPEC := aCols[nCont,FG_POSVAR("DF_VLRTOT")] / aCols[nCont,FG_POSVAR("DF_QTDINF")]
					VS3->VS3_FORMUL := M->FJ_FORMUL

					cTipOpeS := PADR(GetNewPar("MV_MIL0028",""), TamSX3("FM_TIPO")[1])
					cTipOpeE := PADR(GetNewPar("MV_MIL0029",""), TamSX3("FM_TIPO")[1])

					if !Empty(cTipOpeS)
						cTESSai := MaTesInt(2,cTipOpeS,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
						VS3->VS3_CODTES := cTESSai
						VS3->VS3_TESSAI := cTESSai
					endif
					if !Empty(cTipOpeE)
						cTESEnt := MaTesInt(1,cTipOpeE,SA2->A2_COD,SA2->A2_LOJA,"C",SB1->B1_COD)
						VS3->VS3_TESENT := cTESEnt
					endif

					VS3->VS3_ARMORI := SB2->B2_LOCAL
					If ExistTrigger('VS3_QTDINI')
						RunTrigger(2,ni,nil,,'VS3_QTDINI')
					EndIf
					MsUnlock()
					nSeq += 1
				Endif
			Next
			cFilAnt := cFilAntOld
			DBSelectArea("SFJ")
			reclock("SFJ",.f.)
			if SFJ->(FieldPos("FJ_NUMORC")) <> 0
				SFJ->FJ_NUMORC := VS1->VS1_NUMORC
			endif
			SFJ->FJ_SOLICIT := Right(VS1->VS1_NUMORC,6)
			msunlock()
			If lVS1_TRFRES .and. VS1->VS1_TRFRES == "1" // Reservar Itens da Transferencia Automaticamente
				If !MATA297M7_Reservar_Itens()
					DisarmTransaction()
					Return .F.
				EndIf
			EndIf
			MsgInfo(STR0163+Chr(13)+Chr(10)+STR0164+VS1->VS1_FILIAL+Chr(13)+Chr(10)+STR0165+VS1->VS1_NUMORC,STR0166) //"Orçamento de Transferência gerado com sucesso!"
		Else
			DisarmTransaction()
			Return .F.
		EndIf
	endif
	IF M->FJ_TIPGER == "2"
		If Empty(M->FJ_FORNECE) .or. Empty(M->FJ_LOJA) .or. Empty(M->FJ_FILENT) .or. Empty(M->FJ_COND)
			lMshelpAuto := .f.
			Help(" ",1,"MTA297PED")
			DisarmTransaction()
			Return .F.
		EndIf

		&& Valida se o valor minimo do fornecedor esta sendo respeitado.
		For nVldTot := 1 to Len(aValorPed)
			If ( !Empty(aValorPed[nVldTot,5]) .and. aValorPed[nVldTot,4] < aValorPed[nVldTot,5] )
				MsgAlert(STR0104 ;
				+CHR(13) + STR0105 + Space(04) + aValorPed[nVldTot,1] +" "+ aValorPed[nVldTot,2] +" "+ aValorPed[nVldTot,3] ;
				+CHR(13) + STR0106 + Transform(aValorPed[nVldTot,4],"@E 999,999,999.99") ;
				+CHR(13) + STR0107 + Transform(aValorPed[nVldTot,5],"@E 999,999,999.99") ,STR0103)
				DisarmTransaction()
				Return .F.
			EndIf
		Next

		lContinua:=MsgYesNo(STR0071,STR0062) //"Confirma a Geracao do Pedido de Compra"
		If lContinua .and. GetMV("MV_VEICULO") == "S"
			DbSelectArea("VE4")
			DbSetOrder(1)
			DbSeek( xFilial("VE4") )
			While !Eof() .and. VE4->VE4_FILIAL == xFilial("VE4")
				If M->FJ_FORNECE+M->FJ_LOJA == VE4->VE4_CODFOR+VE4->VE4_LOJFOR
					cCodMar := VE4->VE4_PREFAB
					Exit
				EndIf
				DbSelectArea("VE4")
				DbSkip()
			EndDo
			If !Empty(VE4->VE4_ULTPED)
				nUltP := VE4->VE4_ULTPED + 1
				nRest := VE4->VE4_PEDFIN - VE4->VE4_ULTPED
				If SX6->(DbSeek( xFilial("SX6") + "MV_MAQGPEC" ))
					If nRest <= 20 .and. nRest >= 1
						cMsg := STR0108+Transform(nRest,"@R 999999")+STR0109
						MsgAlert(cMsg,STR0103)
						cSendMsg := ""
						If AT(",",GetMv("MV_MAQGPEC")) == 0
							cSendMsg := "prj_client " + GetMv("MV_MAQGPEC") + " " + '"' + cMsg + '"'
						Else
							cSendMsg := "prj_client " + subs(GetMv("MV_MAQGPEC"),1,at(",",GetMv("MV_MAQGPEC"))-1) + " " + '"' + cMsg + '"'
						EndIf
						WinExec(cSendMsg)
					ElseIf nRest <= 0
						cMsg := STR0110
						MsgAlert(cMsg,STR0103)
						cSendMsg := ""
						If AT(",",GetMv("MV_MAQGPEC")) == 0
							cSendMsg := "prj_client " + GetMv("MV_MAQGPEC") + " " + '"' + cMsg + '"'
						Else
							cSendMsg := "prj_client " + subs(GetMv("MV_MAQGPEC"),1,at(",",GetMv("MV_MAQGPEC"))-1) + " " + '"' + cMsg + '"'
						EndIf
						WinExec(cSendMsg)
						DisarmTransaction()
						Return(.f.)
					EndIf
				EndIf
			EndIf
			M->VE6_CODMAR := cCodMar
			if !lJohnDeere
				cPerg := "MT297A          "
				DbSelectArea("SX1")
				DbSetOrder(1)
				cPerg := left(cPerg,len(X1_GRUPO))
				DbSeek(cPerg+"04")
				RecLock("SX1",.f.)
				If !Empty(nUltP)
					X1_CNT01 := strzero(nUltP,6)
				Else
					X1_CNT01 := SOMA1(Alltrim(X1_CNT01),Len(Alltrim(X1_CNT01)))
				EndIf
				MsUnlock()
				DbSeek(cPerg+"05")
				RecLock("SX1",.f.)
				X1_CNT01 := SFJ->FJ_FORPED
				MsUnlock()
				If !Pergunte(cPerg,.T.)
					DisarmTransaction()
					Return .F.
				EndIF
				//			cCodMar:=Traz_Marca(M->DF_PRODUTO)
				DbSelectArea("VEI")
				DbSetOrder(2)
				If DbSeek( xFilial("VEI") + cCodMar + MV_PAR04 )
					MsgStop(STR0111+MV_PAR04+STR0112,STR0103)
					Return(.f.)
				EndIf
			endif
		EndIF
	ElseIF M->FJ_TIPGER == "1"
		lContinua:=MsgYesNo(STR0070,STR0062) //"Confirma a Geracao da Solicitacao de Compras"
	EndIf
	lMshelpAuto := .t.

	For ni:=1 to Len(aCols)
		lDeleted := .f.
		IF ValType(aCols[ni,Len(aCols[ni])]) == "L"
			lDeleted := aCols[ni,Len(aCols[ni])]      // Verfiica se esta Deletado
		EndIF

		DbSelectArea("SDF")
		DbSetOrder(1)

		SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO+aCols[ni,ProcH('DF_PRODUTO')]))

		IF !lDeleted

			SDF->(RecLock("SDF",!SDF->(Found())))

			FG_GRAVAR("SDF",aCols,aHeader,ni)

			SDF->DF_FILIAL := xFilial("SDF")
			SDF->DF_CODIGO := SFJ->FJ_CODIGO

			SDF->(MsUnlock())

		Else

			If Found()
				SDF->(RecLock("SDF",.F.))
				SDF->(DbDelete())
				SDF->(MsUnlock())
			EndIF

		EndIF

	Next
	IF M->FJ_TIPPRC # nTipPrc
		SFJ->(RecLock("SFJ",.F.))
		SFJ->FJ_TIPPRC := M->FJ_TIPPRC
		SFJ->(MsUnlock())
	EndIF
	If lContinua
		MT297MGert(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05)
	EndIF
	End Transaction
	IF lMsErroAuto
		MostraErro()
		lRet := .F.
	EndIF
	lMsErroAuto := .f.
	lMsHelpAuto := .f.
EndIF
Return lRet

// Funcoes Estaticas
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SaldoEst ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³SaldoEst                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SaldoEst(cCod)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SaldoEst(cCod)
Local cAlias :=GetArea()
Local nSaldo :=0
Local nPend  :=0
Local nVezes :=0
Local nCustoM:=0
Local cAliasSB2 := "SQLSB2"

cQuery := "SELECT SB2.B2_QATU,SB2.B2_SALPEDI,SB2.B2_CM1 "
cQuery += "FROM "
cQuery += RetSqlName( "SB2" ) + " SB2 "
cQuery += "WHERE "
cQuery += "SB2.B2_FILIAL='"+ xFilial("SB2")+ "' AND SB2.B2_COD = '"+cCod+"' AND '"+Trim(GetMV("MV_VEICULO"))+"' <> 'S' AND SB2.B2_LOCAL <= '50' AND "
cQuery += "SB2.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB2, .T., .T. )

Do While !( cAliasSB2 )->( Eof() )
	nVezes++
	nSaldo  += ( cAliasSB2 )->B2_QATU
	nPend   += ( cAliasSB2 )->B2_SALPEDI
	nCustoM += ( cAliasSB2 )->B2_CM1
	( cAliasSB2 )->(DbSkip())
EndDo
(cAliasSB2)->(dbCloseArea())
RestArea(cAlias)
IF nVezes > 0
	nCustoM := (nCustoM/nVezes)
EndIF
Return {nSaldo,nPend,nCustoM}
//Monta Heads
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaHead³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Head                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontaHead()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaHead()
local npos:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SDF")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof() .And. (X3_ARQUIVO == "SDF")
	nPos := Ascan(aCpoGetDados,X3_CAMPO)
	IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. Empty(nPos)
		nUsado:=nUsado+1
		AADD(aHeader,{ Trim(X3Titulo()),;
		X3_CAMPO,;
		X3_PICTURE,;
		X3_TAMANHO,;
		X3_DECIMAL,;
		X3_VALID,;
		X3_USADO,;
		X3_TIPO,;
		X3_ARQUIVO,;
		X3_CONTEXT,;
		X3_RELACAO,;
		X3_RESERV  } )

	EndIF
	dbSkip()
Enddo
nUsado:=nUsado+1
AADD(aHeader,{ STR0174            , "B1_DESC",X3Picture("B1_DESC"),50, 0 , "" , "" , "C" , "SB1" , "V" } ) // //"Descrição do produto"
nUsado:=nUsado+1
AADD(aHeader,{ STR0175            , "B2_QATU",X3Picture("B1_QATU"),14, 2 , "" , "" , "N" , "SB2" , "V" } ) // //"Saldo Atual"
nUsado:=nUsado+1
AADD(aHeader,{ RetTitle("B1_PESO"),"B1_PESO",X3Picture("B1_PESO") ,11, 4 , "" , "" , "N" , "SB1" , "V" } ) // //Peso "

Return
//Monta Cols
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaCols³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Cols                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontaCols()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaCols()
Local _ni      := 0
Local cDesc    := ""
Local nPeso    := 0
Local nRecNo   := 0

nPesoTot := 0

aCols       := {}
DbSelectArea("SDF")
DbSetOrder(1)
DbSeek( xFilial("SDF")+SFJ->FJ_CODIGO )
While !Eof() .And. DF_CODIGO==SFJ->FJ_CODIGO .and. xFilial("SDF")==SDF->DF_FILIAL

	cDesc  := FM_SQL(" SELECT B1_DESC FROM " +RetSqlName('SB1')+ " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = '"+SDF->DF_PRODUTO+"' AND D_E_L_E_T_ = ' ' ")
	nPeso  := FM_SQL(" SELECT B1_PESO FROM " +RetSqlName('SB1')+ " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = '"+SDF->DF_PRODUTO+"' AND D_E_L_E_T_ = ' ' ")
	nRecNo := FM_SQL(" SELECT R_E_C_N_O_ RECSB2 FROM " +RetSqlName('SB2')+ " WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND B2_COD = '"+SDF->DF_PRODUTO+"' AND B2_LOCAL = '"+FM_PRODSBZ(SDF->DF_PRODUTO,"SB1->B1_LOCPAD")+"' AND D_E_L_E_T_ = ' ' ")

	SB2->(dbGoTo(nRecNo))
	nSaldo := SaldoSB2()

	AADD(aCols,Array(nUsado+1))

	For _ni:=1 to nUsado
		If ( aHeader[_ni][10] != "V")
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Else
			if aHeader[_ni,2] == "B1_DESC"
				aCols[Len(aCols),_ni] := cDesc
			Elseif aHeader[_ni,2] == "B1_PESO"
				aCols[Len(aCols),_ni] := nPeso
				nPesoTot += (nPeso*SDF->DF_QTDINF)
			Elseif aHeader[_ni,2] == "B2_QATU"
				aCols[Len(aCols),_ni] := nSaldo
			Else
				aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2],.t.)
			Endif
		EndIf
	Next

	aCols[Len(aCols),nUsado+1]:=.F.


	dbSkip()
EndDo

// PONTO DE ENTRADA PARA ALTERACAO DO VETOR aCols
If ExistBlock("MT297MAC")
	ExecBlock("MT297MAC",.f.,.f.)
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Modelo3	  ³ Autor ³ Wilson		        ³ Data ³ 17/03/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice e GetDados									  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lRet:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk, 	  ³±±
±±³			 ³cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice  ³±±
±±³			 ³  ,nFreeze,aAlter)                                          ³±±
±±³			 ³lRet=Retorno .T. Confirma / .F. Abandona			  		  ³±±
±±³			 ³cTitulo=Titulo da Janela 									  ³±±
±±³			 ³cAlias1=Alias da Enchoice									  ³±±
±±³			 ³cAlias2=Alias da GetDados									  ³±±
±±³			 ³aMyEncho=Array com campos da Enchoice						  ³±±
±±³			 ³cLinOk=LinOk 											 	  ³±±
±±³			 ³cTudOk=TudOk 											 	  ³±±
±±³			 ³nOpcE=nOpc da Enchoice								 	  ³±±
±±³			 ³nOpcG=nOpc da GetDados								 	  ³±±
±±³			 ³cFieldOk=validacao para todos os campos da GetDados 		  ³±±
±±³			 ³lVirtual=Permite visualizar campos virtuais na enchoice	  ³±±
±±³			 ³nLinhas=Numero Maximo de linhas na getdados			  	  ³±±
±±³			 ³aAltEnchoice=Array com campos da Enchoice Alteraveis		  ³±±
±±³			 ³nFreeze=Congelamento das colunas.                           ³±±
±±³			 ³aAlter =Campos do GetDados a serem alterados.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³MTA297												 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³         nAtualIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Valdir F. Sil³11/05/00³XXXXXX³Colocar campos alteraveis no GetDados    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aAlter)
Local lRet, nOpca := 0,nReg:=(cAlias1)->(Recno())
Local aCpoAlt:={} , ni:=0
Local i := 0 , nR := 0

Private Altera:=.t.,Inclui:=.t.,bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
Private oDesc
Private cDesc := " "
Private M
Private naColsDados := Len(aCols)
//Private aNewBot := {{"EDIT","FS_ExpSug()","Exporta Sugestao para Planilha"}}
Private aNewBot := {}
Private aMesAno:={"","","","","","","","","","","",""}
//variaveis controle de janela
Private aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Private aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

For ni:=1 to Len(aAlter)
	If !( aAlter[ni] $ "DF_CODGRP/DF_CODITE" )
		Aadd( aCpoAlt , aAlter[ni] )
	EndIf
Next

If Month(dDataBase)==1
	cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
Else
	cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
EndIf

nOpcE := IF(nOpcE==Nil,3,nOpcE)
nOpcG := IF(nOpcG==Nil,3,nOpcG)
lVirtual := IIF(lVirtual==Nil,.F.,lVirtual)
nLinhas:=IIF(nLinhas==Nil,3000,nLinhas)

AADD(aNewBot, {"ANALITICO",{|| IIf(Pergunte("OF20MV"),(OFIOC150(MV_PAR01,MV_PAR02),Pergunte(cPergMil,.f.)),Pergunte(cPergMil,.f.)) },( STR0149 )} ) //"Movimento da Peca"
If GetMv("MV_VEICULO") == "S"
	AADD(aNewBot, {"PENDENTE",{|| OFIOC190() },( STR0150 )} ) //"Pedido"
Endif
AADD(aNewBot, {"EDIT",{|| FS_ExpSug() },( STR0151)} ) //"Exporta Sugestao para Planilha"


// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 83 , .T., .F. } )
AAdd( aObjects, { 1, 180, .T. , .T. } )
AAdd( aObjects, { 1,  25, .T. , .F. } )
AAdd( aObjects, { 1,  20, .T. , .F. } )
AAdd( aObjects, { 1,  70, .T. , .F. } )

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg297 TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

if ! lDebug
	oTimer := TTimer():New(150, {|| MATA297M1_BUSCADEMANDA("") }, oDlg297 )
	oTimer:Activate()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice 01							                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFJ")
RegToMemory("SFJ")
Zero()
oEnc01:= MsMGet():New("SFJ" ,nReg ,nOpcE,,,,aMyEncho[1],{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},aAltEnchoice,3,,,,oDLG297,,,lVirtual,"")


oEnc01:oBox:bGotFocus   := {|| AL_EntraEnc(1,"SFJ")}
oEnc01:oBox:bLostFocus  := {|| AL_SaiEnc(1)}

//  "DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

If len(aCols) > 0 .and. !Empty(aCols[1,ProcH('DF_PRODUTO')])
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xfilial("SB1")+aCols[1,ProcH('DF_PRODUTO')])
Endif

// For i = 1 to 12
// 	m := month(dDatabase) - i
// 	m := if(m<1, m + 12, m)
// 	aMesAno[i] :=aMeses[m]+"/"+ if(m<month(dDatabase),str(year(dDatabase),4),str(year(dDatabase)-1,4))
// Next

oUtil := DMS_Util():New()
dData := dDatabase
for i := 1 to 12
	aMesAno[i] := aMeses[month(dData)] + "/" + right(strzero(year(dData),4),4)
	dData := oUtil:RemoveMeses(dData, 1)
next

@ aPosObj[3,1]+005, 01*nQtdDis - 22 SAY aMesAno[01] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 02*nQtdDis - 22 SAY aMesAno[02] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 03*nQtdDis - 22 SAY aMesAno[03] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 04*nQtdDis - 22 SAY aMesAno[04] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 05*nQtdDis - 22 SAY aMesAno[05] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 06*nQtdDis - 22 SAY aMesAno[06] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 07*nQtdDis - 22 SAY aMesAno[07] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 08*nQtdDis - 22 SAY aMesAno[08] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 09*nQtdDis - 22 SAY aMesAno[09] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 10*nQtdDis - 22 SAY aMesAno[10] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 11*nQtdDis - 22 SAY aMesAno[11] OF oDlg297 PIXEL
@ aPosObj[3,1]+005, 12*nQtdDis - 22 SAY aMesAno[12] OF oDlg297 PIXEL

@ aPosObj[3,1],aPosObj[3,2]    TO aPosObj[3,3],aPosObj[3,4]-70 LABEL "" OF oDlg297 PIXEL  // Caixa - Descricao Item / Meses Demanda

// LinhaIni,ColunaIni TO LinhaFin,ColunaFial
@ aPosObj[3,1],aPosObj[3,4]-65 TO aPosObj[3,3],aPosObj[3,4] LABEL STR0184 OF oDlg297 PIXEL  // Caixa - Peso Total da Sugestão
@ aPosObj[3,1]+010, aPosObj[3,4]-50 SAY oPesoTot VAR Transform(nPesoTot,"@E 99,999,999,999.99") OF oDlg297 PIXEL // Peso Total

@ aPosObj[4,1]+004,aPosObj[4,2]+002 SAY OBJ05 VAR STR0121+SB1->B1_FABRIC+STR0122 + SBL->BL_CODFORM + " = " + cDescForm OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[4,1]+005,aPosObj[4,4]-052  BUTTON oKIT PROMPT OemToAnsi(STR0123) OF oDlg297 SIZE 40,10 PIXEL ACTION (OFIOC040(SB1->B1_GRUPO,SB1->B1_CODITE)) WHEN lKIT
@ aPosObj[4,1],aPosObj[4,2] TO aPosObj[4,3],aPosObj[4,4]-70 LABEL "" OF oDlg297 PIXEL  // Caixa - Marca / Formula

cFornComp1 := cFornComp2 := space(50)
nQtdNotas := 0
DbSelectArea( "SD1" )
DbSetOrder(7)
DbSeek( xFilial("SD1") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") + dtos(dDataBase+1) , .t. )
If !Bof()
	Skip(-1)
EndIf
While !Bof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. SB1->B1_COD == SD1->D1_COD
	DbSelectArea( "SF4" )
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + SD1->D1_TES )
	If SF4->F4_ESTOQUE == "S" .and. SF4->F4_DUPLIC == "S"
		If lF4_OPEMOV
			If SF4->F4_OPEMOV # "01"
				DbSelectArea( "SD1" )
				DbSkip(-1)
				Loop
			EndIf
		EndIf
		DbSelectArea( "SA2" )
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA )
		nQtdNotas++
		Do Case
			Case nQtdNotas = 1
				cFornComp1 := Transform(SD1->D1_DTDIGIT,"@D") + " R$" + Transform((((SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA)-SD1->D1_VALDESC)/SD1->D1_QUANT),"@E 999,999.99") + " " + left(SA2->A2_NOME,17)
			Case nQtdNotas = 2
				cFornComp2 := Transform(SD1->D1_DTDIGIT,"@D") + " R$" + Transform((((SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA)-SD1->D1_VALDESC)/SD1->D1_QUANT),"@E 999,999.99") + " " + left(SA2->A2_NOME,17)
		EndCase
		If nQtdNotas >= 2
			Exit
		EndIf
	EndIf
	DbSelectArea( "SD1" )
	DbSkip(-1)
EndDo

@ aPosObj[5,1]+010,aPosObj[5,2]+003 SAY OBJ23 VAR (cFornComp1) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+017,aPosObj[5,2]+003 SAY OBJ24 VAR (cFornComp2) OF oDlg297 PIXEL COLOR CLR_BLUE

@ aPosObj[5,1],aPosObj[5,2] TO aPosObj[5,3]-30,aPosObj[5,4]-400 LABEL STR0124 OF oDlg297 PIXEL  // Caixa - Compra

@ aPosObj[5,1]+050,aPosObj[5,2]+001 SAY OBJ25 VAR STR0125 OF oDlg297 PIXEL COLOR CLR_RED
@ aPosObj[5,1]+059,aPosObj[5,2]+001 SAY OBJ26 VAR  STR0127 OF oDlg297 PIXEL COLOR CLR_RED
@ aPosObj[5,3]-31,aPosObj[5,2] TO aPosObj[5,3],aPosObj[5,4]-400 LABEL "" OF oDlg297 PIXEL  // Caixa - Atencao

////////////////////////////////////////////////////////////////////////////////////////
///      Andre Luis Almeida      ///   16/04/2004   ///      Itens Relacionados      ///
////////////////////////////////////////////////////////////////////////////////////////
DbSelectArea("SB1")
nOrderSB1 := indexord()
nRecNoSB1 := RecNo()
DbSelectArea("SB2")
nOrderSB2 := indexord()
nRecNoSB2 := RecNo()
DbSelectArea("SBM")
nOrderSBM := indexord()
nRecNoSBM := RecNo()
// luis
DbSelectArea("SBL")
nOrderSBL := indexord()
nRecNoSBL := RecNo()

cSeekSB1  := ""
cRelacGrp := SB1->B1_GRUPO
cRelacIte := SB1->B1_CODITE
aIteRelac := {}
nRelacTot := 0
cRelac1 := cRelac2 := cRelac3 := cRelac4 := ""
cRelABC1 := cRelABC2 := cRelABC3 := cRelABC4 := ""
nRelac1 := nRelac2 := nRelac3 := nRelac4 := 0

DbSelectArea("SBM")
DbSetOrder(1)
DbSeek(xFilial("SBM") + SB1->B1_GRUPO )
aIteRelac := {}
For nR := 1 to (len(alltrim(SBM->BM_GRUREL))/5)
	cSeekSB1 := left(substr(SBM->BM_GRUREL,((nR*5)-4),4)+space(4),4) + left(cRelacIte,SBM->BM_LENREL)
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek(xFilial("SB1") + cSeekSB1 )
	While !Eof() .and. SB1->B1_FILIAL == xFilial("SB1") .and. cSeekSB1 == SB1->B1_GRUPO+left(SB1->B1_CODITE,SBM->BM_LENREL)
		If SB1->B1_GRUPO+SB1->B1_CODITE # cRelacGrp+cRelacIte
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2") + SB1->B1_COD + "01" , .t. )
			While !Eof() .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_COD == SB1->B1_COD .and. SB2->B2_LOCAL <= "49"
				nPosRel := 0
				nPosRel := aScan(aIteRelac,{|x| x[1] == SB1->B1_GRUPO+" "+SB1->B1_CODITE })
				If nPosRel == 0
					// luis: curva abc no item relacionado (1)
					DBSelectArea("SBL")
					DBSetOrder(1)
					IF Month(dDataBase)==1
						cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
					Else
						cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
					EndIf
					if DBSeek(xFilial("SBL")+SB1->B1_COD+cAnoMes)
						aAdd(aIteRelac,{ SB1->B1_GRUPO+" "+SB1->B1_CODITE , SB2->B2_QATU , SBL->BL_ABCVEND+SBL->BL_ABCCUST })
					else
						aAdd(aIteRelac,{ SB1->B1_GRUPO+" "+SB1->B1_CODITE , SB2->B2_QATU , "" })
					endif
				Else
					aIteRelac[nPosRel,2] += SB2->B2_QATU
				EndIf
				nRelacTot += SB2->B2_QATU
				DbSelectArea("SB2")
				DbSkip()
			EndDo
		EndIf
		DbSelectArea("SB1")
		DbSkip()
	EndDo
Next
If nRelacTot > 0
	aSort(aIteRelac,1,,{|x,y| x[2] > y[2] })
	For nR := 1 to 4
		cRelR := str(nR,1)
		If len(aIteRelac) >= nR
			cRelac&cRelR := " - "+ aIteRelac[nR,1]
			nRelac&cRelR := aIteRelac[nR,2]
			cRelABC&cRelR := aIteRelac[nR,3]
		Else
			cRelac&cRelR := ""
			cRelABC&cRelR := ""
			nRelac&cRelR := 0
		EndIf
	Next
	If !Empty(Alltrim(cRelac1))
		cTotal := STR0128+Transform(len(aIteRelac),"@E 9999")+STR0129
	Else
		cTotal := space(50)
	EndIf

	@ aPosObj[5,1]+006,aPosObj[5,4]-398 SAY OBJ27 VAR cTotal OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 200, 179 SAY OBJ28 VAR If(!Empty(Alltrim(cTotal)),Transform(nRelacTot,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

	@ 208, 119 SAY OBJ29 VAR left(cRelac1+space(50),50) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 208, 174 SAY OBJ30 VAR left(cRelABC1+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 208, 179 SAY OBJ31 VAR If(!Empty(Alltrim(cRelac1)),Transform(nRelac1,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

	@ 215, 119 SAY OBJ32 VAR left(cRelac2+space(50),50) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 215, 174 SAY OBJ33 VAR left(cRelABC2+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 215, 179 SAY OBJ34 VAR If(!Empty(Alltrim(cRelac2)),Transform(nRelac2,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

	@ 222, 119 SAY OBJ35 VAR left(cRelac3+space(50),50) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 222, 174 SAY OBJ36 VAR left(cRelABC3+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 222, 179 SAY OBJ37 VAR If(!Empty(Alltrim(cRelac3)),Transform(nRelac3,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

	@ 229, 119 SAY OBJ38 VAR left(cRelac4+space(50),50) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 229, 174 SAY OBJ39 VAR left(cRelABC4+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ 229, 179 SAY OBJ40 VAR If(!Empty(Alltrim(cRelac4)),Transform(nRelac4,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

Else

	cTotal  := cRelac1 := cRelac2 := cRelac3 := cRelac4 := space(50)
	cRelABC1 := cRelABC2 := cRelABC3 := cRelABC4 := space(2)
	nRelac1 := nRelac2 := nRelac3 := nRelac4 := 0

	@ aPosObj[5,1]+008,aPosObj[5,4]-398 SAY OBJ27 VAR cTotal OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+008,aPosObj[5,4]-338 SAY OBJ28 VAR If(!Empty(Alltrim(cTotal)),Transform(nRelacTot,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

	@ aPosObj[5,1]+017,aPosObj[5,4]-398 SAY OBJ29 VAR left(cRelac1+space(50),50) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+017,aPosObj[5,4]-348 SAY OBJ30 VAR left(cRelABC1+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+017,aPosObj[5,4]-338 SAY OBJ31 VAR If(!Empty(Alltrim(cRelac1)),Transform(nRelac1,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

	@ aPosObj[5,1]+026,aPosObj[5,4]-398 SAY OBJ32 VAR left(cRelac2+space(50),50) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+026,aPosObj[5,4]-348 SAY OBJ33 VAR left(cRelABC2+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+026,aPosObj[5,4]-338 SAY OBJ34 VAR If(!Empty(Alltrim(cRelac2)),Transform(nRelac2,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

	@ aPosObj[5,1]+035,aPosObj[5,4]-398 SAY OBJ35 VAR left(cRelac3+space(50),50) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+035,aPosObj[5,4]-348 SAY OBJ36 VAR left(cRelABC3+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+035,aPosObj[5,4]-338 SAY OBJ37 VAR If(!Empty(Alltrim(cRelac3)),Transform(nRelac3,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

	@ aPosObj[5,1]+045,aPosObj[5,4]-398 SAY OBJ38 VAR left(cRelac4+space(50),50) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+045,aPosObj[5,4]-348 SAY OBJ39 VAR left(cRelABC4+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
	@ aPosObj[5,1]+045,aPosObj[5,4]-338 SAY OBJ40 VAR If(!Empty(Alltrim(cRelac4)),Transform(nRelac4,"@E 99,999"),space(30)) OF oDlg297 PIXEL COLOR CLR_BLUE

EndIf
@ aPosObj[5,1],aPosObj[5,4]-401 TO aPosObj[5,3],aPosObj[5,4]-300 LABEL STR0130 OF oDlg297 PIXEL  // Caixa - Itens Relacionados
// luis -----
DbSelectArea("SBL")
DbSetOrder(nOrderSBL)
DbGoTo(nRecNoSBL)
// ----------
DbSelectArea("SBM")
DbSetOrder(nOrderSBM)
DbGoTo(nRecNoSBM)
DbSelectArea("SB2")
DbSetOrder(nOrderSB2)
DbGoTo(nRecNoSB2)
DbSelectArea("SB1")
DbSetOrder(nOrderSB1)
DbGoTo(nRecNoSB1)
////////////////////////////////////////////////////////////////////////////////////////
/// Luis Delorme - Itens Substituidos
////////////////////////////////////////////////////////////////////////////////////////
DBSelectArea("VE9")
nContAnt := 0
nContPos := 0
lPecFound := .t.
aVecTot := {}
aVecAnt := {}
aVecPos := {}
cItemAnt := cRelacIte
cGrupoIte := cRelacGrp
cItemPos := cRelacIte
while (lPecFound)
	lPecFound := .f.
	DbSetOrder(3)
	// pecas que substituiram a peca selecionada
	if DBSeek(xFilial("VE9")+cItemPos) .and. ((nContPos + nContAnt) < 4)
		lPecFound := .t.
		cItemPos := VE9->VE9_ITENOV
		aAdd(aVecPos,cItemPos)
		nContPos++
	endif
	//  pecas que foram substituidas pela selecionada
	DbSetOrder(4)
	if DBSeek(xFilial("VE9")+cItemAnt) .and. ((nContPos + nContAnt) < 4)
		lPecFound := .t.
		cItemAnt := VE9->VE9_ITEANT
		aAdd(aVecAnt,cItemAnt)
		nContAnt++
	endif
enddo
for i := 0 to (nContAnt -1)
	aAdd(aVecTot,aVecAnt[nContAnt-i])
next
aAdd(aVecTot,cRelacIte)
vItePrinc = Len(aVecTot)
for i := 1 to nContPos
	aAdd(aVecTot,aVecPos[i])
next
If len(aVecTot) == 1
	vItePrinc := 0
	aVecTot := {}
	aAdd(aVecTot," ")
EndIf
for i := len(aVecTot) to 4
	aAdd(aVecTot," ")
next
// pega o ABC do item
aVecABCIt = {}
aVecABCSal= {}
for i := 1 to 5
	DBSelectArea("SBL")
	DBSetOrder(1)
	IF Month(dDataBase)==1
		cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
	Else
		cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
	EndIf
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+cGrupoIte+aVecTot[i])
	DBSelectArea("SB2")
	DBSetOrder(1)
	if DBSeek(xFilial("SB2")+SB1->B1_COD+"01")
		aAdd(aVecABCSal,SB2->B2_QATU)
	else
		aAdd(aVecABCSal,0)
	endif
	DBSelectArea("SBL")
	if DBSeek(xFilial("SBL")+SB1->B1_COD+cAnoMes)
		aAdd(aVecABCIt, SBL->BL_ABCVEND+SBL->BL_ABCCUST )
	else
		aAdd(aVecABCIt, "  " )
	endif
next

@ aPosObj[5,1]+008,aPosObj[5,4]-298 SAY OBJ41 VAR if(aVecTot[1]!=" ",if(vItePrinc==1,">","-"),"")+left(aVecTot[1]+space(15),15) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+008,aPosObj[5,4]-250 SAY OBJ42 VAR left(aVecABCIt[1]+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+008,aPosObj[5,4]-260 SAY OBJ43 VAR If(aVecTot[1] != " ",Transform(aVecABCSal[1],"@E 9999"),space(4)) OF oDlg297 PIXEL COLOR CLR_BLUE

@ aPosObj[5,1]+017,aPosObj[5,4]-298 SAY OBJ44 VAR if(aVecTot[2]!=" ",if(vItePrinc==2,">","-"),"")+left(aVecTot[2]+space(15),15) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+017,aPosObj[5,4]-250 SAY OBJ45 VAR left(aVecABCIt[2]+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+017,aPosObj[5,4]-260 SAY OBJ46 VAR If(aVecTot[2] != " ",Transform(aVecABCSal[2],"@E 9999"),space(4)) OF oDlg297 PIXEL COLOR CLR_BLUE

@ aPosObj[5,1]+026,aPosObj[5,4]-298 SAY OBJ47 VAR if(aVecTot[3]!=" ",if(vItePrinc==3,">","-"),"")+left(aVecTot[3]+space(15),15) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+026,aPosObj[5,4]-250 SAY OBJ48 VAR left(aVecABCIt[3]+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+026,aPosObj[5,4]-260 SAY OBJ49 VAR If(aVecTot[3] != " ",Transform(aVecABCSal[3],"@E 9999"),space(4)) OF oDlg297 PIXEL COLOR CLR_BLUE

@ aPosObj[5,1]+035,aPosObj[5,4]-298 SAY OBJ50 VAR if(aVecTot[4]!=" ",if(vItePrinc==4,">","-"),"")+left(aVecTot[4]+space(15),15) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+035,aPosObj[5,4]-250 SAY OBJ51 VAR left(aVecABCIt[4]+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+035,aPosObj[5,4]-260 SAY OBJ52 VAR If(aVecTot[4] != " ",Transform(aVecABCSal[4],"@E 9999"),space(4)) OF oDlg297 PIXEL COLOR CLR_BLUE

@ aPosObj[5,1]+044,aPosObj[5,4]-298 SAY OBJ53 VAR if(aVecTot[5]!=" ",if(vItePrinc==5,">","-"),"")+left(aVecTot[5]+space(15),15) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+044,aPosObj[5,4]-250 SAY OBJ54 VAR left(aVecABCIt[5]+space(2),2) OF oDlg297 PIXEL COLOR CLR_BLUE
@ aPosObj[5,1]+044,aPosObj[5,4]-260 SAY OBJ55 VAR If(aVecTot[5] != " ",Transform(aVecABCSal[5],"@E 9999"),space(4)) OF oDlg297 PIXEL COLOR CLR_BLUE

@ aPosObj[5,1],aPosObj[5,4]-301 TO aPosObj[5,3],aPosObj[5,4]-200 LABEL STR0131 OF oDlg297 PIXEL  // Caixa - Itens Relacionados

////////////////////////////////////////////////////////////////////////////////////////
/// Fabio        - Valor total do pedido por fonecedor
////////////////////////////////////////////////////////////////////////////////////////

MT297MVLDt(.f.) // Totaliza Itens e chama a funcao FS_TOTFORNEC() no final

@ aPosObj[5,1],aPosObj[5,4]-201 TO aPosObj[5,3],aPosObj[5,4] LABEL STR0132 OF oDlg297 PIXEL

@ aPosObj[5,1]+007,aPosObj[5,4]-198 LISTBOX oLblValor FIELDS HEADER  OemToAnsi(STR0133),OemToAnsi(STR0134),OemToAnsi(STR0135) COLSIZES 40,60,60 SIZE 196,60 OF oDlg297 PIXEL
oLblValor:SetArray(aValorPed)
oLblValor:bLine := { || { left(aValorPed[oLblValor:nAt,3],10),;
Transform(aValorPed[oLblValor:nAt,4],"@E 999,999,999.99"),;
Transform(aValorPed[oLblValor:nAt,5],"@E 999,999,999.99")}}

oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",IF(nOpcE==4,.t.,.f.),aAlter,nFreeze,,nLinhas,cFieldOk)

oGetDados:oBrowse:bDrawSelect := {|| FS_VLTPROD1() }
oGetDados:oBrowse:bEditCol    := {|| FS_TRATAQTD(), FS_VLTPROD1() }
oGetDados:oBrowse:bChange     := {|| oGetDados:aAlter := oGetDados:oBrowse:aAlter := If( n <= naColsDados , aCpoAlt , aAlter ) , MTA297ATt(), FS_VLTPROD1() }
oGetDados:oBrowse:bDelete     := {|| ( ( aCols[n,Len(aCols[n])] := !aCols[n,Len(aCols[n])] ), FS_TOTFORNEC() ) }

FS_VERKIT()

ACTIVATE MSDIALOG oDlg297 CENTER ON INIT EnchoiceBar(oDlg297, {|| nOpca:=1,MT297RECL(),If(oGetDados:TudoOk().And. If(type("cTudoOk") == "U",oDlg297:End(),cTudoOk), oDlg297:End() , .f. ) } , {|| nOpca := 2,MT297RECL(),oDlg297:End() },,aNewBot)


lRet:=(nOpca==1)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Impr		³ Autor ³           		        | Data ³ 16.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de Linhas de Impressao e Cabecalho			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ 															  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IMPR(Detalhe,Fimfolha,Pos_cabec)
LOCAL Colunas, aDriver := LEDriver()
LOCAL X_IMPR := 0
LOCAL XTMP	 := 0
Colunas := IIF(nTamanho=="P",80,IIF(nTamanho=="G",220,132))

IF FIMFOLHA = "F"
	@ 63 ,000		 PSAY REPLICATE("*",COLUNAS)
	@ 64 ,000		 PSAY "       "
	RETURN Nil
EndIF
IF FIMFOLHA = "P" .OR. LI >= 60
	@ LI,00 PSAY REPLICATE("*",COLUNAS)
	LI := 00
	IF FIMFOLHA = "P"
		RETURN Nil
	EndIF
EndIF
IF LI=00
	IF aReturn[4] == 1  // Comprimido
		@ 0,0 PSAY &(IF(nTamanho=="P",aDriver[1],IF(nTamanho=="G",aDriver[5],aDriver[3])))
	Else					  // Normal
		@ 0,0 PSAY &(IF(nTamanho=="P",aDriver[2],IF(nTamanho=="G",aDriver[6],aDriver[4])))
	EndIF
	@ 00,000 PSAY REPLICATE("*",COLUNAS)
	@ 01,000 PSAY "*" + SM0->m0_Nome
	COL_AUX := IF(COLUNAS = 220,210,COLUNAS)
	WCOL	  := INT((COL_AUX - (LEN(TRIM(TITULO))))/2)
	WPAGINA := SUBSTR(STR(CONTFL+100000,6),2,5)
	IF TYPE("POS_CABEC")= "U"
		@ 01,COLUNAS-20 PSAY STR0053 + WPAGINA + "*" //"Folha:        "
	Else
		@ 01,COLUNAS-26 PSAY "*"
	EndIF
	@ 02,000 PSAY "*" + CHR(83) + CHR(46) + CHR(73) + CHR(46) + CHR(71) + CHR(46) + CHR(65) + CHR(46) + " / "  + AT_PRG
	@ 02,WCOL		 PSAY TRIM(TITULO)
	IF TYPE("POS_CABEC")= "U"
		@ 02,COLUNAS-20 PSAY STR0054 //"DT.Ref.:"
		@ 02,COLUNAS-11 PSAY PADL(dDataBase,10)
		@ 02,COLUNAS-01 PSAY "*"
	Else
		@ 02,COLUNAS-26 PSAY "*"
	EndIF
	@ 03,000 PSAY STR0055 + TIME() //"*Hora...: "
	IF TYPE("POS_CABEC")= "U"
		@ 03,COLUNAS-20 PSAY STR0056 //"Emissao:"
		@ 03,COLUNAS-11 PSAY PADL(DATE(),10)
		@ 03,COLUNAS-01 PSAY "*"
	Else
		@ 03,COLUNAS-26 PSAY "*"
	EndIF
	@ 04,000 PSAY REPLICATE("*",IIF(TYPE("POS_CABEC")="U",COLUNAS,COLUNAS-25))
	IF TYPE("POS_CABEC") # "U"
		@ 05,00 PSAY "*"
		@ 05,COLUNAS-26 PSAY "*"
		LI_WCABEC := 6
	Else
		LI_WCABEC := 5
	EndIF
	IF WCABEC0 == 0
		IF TYPE("POS_CABEC") # "U"
			@ 06,00 PSAY STR0057 + WPAGINA //"*Folha:       "
			@ 06,COLUNAS-26 PSAY "*"
			@ 07,00 PSAY STR0058 //"*DT.Ref.:  "
			@ 07,14 PSAY dDataBase
			@ 07,COLUNAS-26 PSAY "*"
			@ 08,00 PSAY STR0059 //"*Emissao:"
			@ 08,14 PSAY DATE()
			@ 08,COLUNAS-26 PSAY "*"
			@ 09,00 PSAY "*"
			@ 09,COLUNAS-26 PSAY "*"
			LI_WCABEC := 10
		EndIF
		@ LI_WCABEC,000 PSAY REPLICATE("*",COLUNAS)
	EndIF
	IF WCABEC0 # 0
		FOR X_IMPR = 1 TO WCABEC0
			IF TYPE("POS_CABEC") # "U"
				IF X_IMPR = 1
					@ LI_WCABEC,00 PSAY STR0057 + WPAGINA //"*Folha:       "
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				ElseIF X_IMPR = 2
					@ LI_WCABEC,00 PSAY STR0058 //"*DT.Ref.:  "
					@ LI_WCABEC,14 PSAY dDataBase
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				ElseIF X_IMPR = 3
					@ LI_WCABEC,00 PSAY STR0059 //"*Emissao:"
					@ LI_WCABEC,14 PSAY DATE()
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				EndIF
			EndIF
			AUX_IMPR := "WCABEC" + ALLTRIM(STR(X_IMPR))
			IF X_IMPR <= 3
				@ LI_WCABEC,IIF(TYPE("POS_CABEC")="U",000,025) PSAY &AUX_IMPR
			Else
				@ LI_WCABEC,000 PSAY &AUX_IMPR
			EndIF
			LI_WCABEC++
		NEXT
		IF TYPE("POS_CABEC") # "U"
			IF X_IMPR <=3
				FOR XTMP = X_IMPR-1 TO 3
					IF XTMP = 2
						@ LI_WCABEC,00 PSAY STR0058 //"*DT.Ref.:  "
						@ LI_WCABEC,14 PSAY dDataBAse
						@ LI_WCABEC,COLUNAS-26 PSAY "*"
					Else
						@ LI_WCABEC,00 PSAY STR0059 //"*Emissao:"
						@ LI_WCABEC,14 PSAY DATE()
						@ LI_WCABEC,COLUNAS-26 PSAY "*"
					EndIF
					LI_WCABEC = LI_WCABEC + 1
				NEXT
			EndIF
		EndIF
		@ LI_WCABEC,000 PSAY REPLICATE("*",COLUNAS)
	EndIF
	LI 	 := LI_WCABEC+1
	CONTFL := CONTFL+1

	__LogPages()

EndIF
@ LI,00 PSAY DETALHE
LI++
RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LEDriver	³ Autor ³ Tecnologi          	  |Data  ³ 16.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controlar o Tipo de Impressora e Impressao    		    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³LEDriver(Void)										            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Acionada pela Funcao Impr									  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LEDriver()
Local aSettings := {}
Local cStr, cLine, i

IF !File(__DRIVER)
	aSettings := {"CHR(15)","CHR(18)","CHR(15)","CHR(18)","CHR(15)","CHR(15)"}
Else
	cStr := MemoRead(__DRIVER)
	For i:= 2 to 7
		cLine := AllTrim(MemoLine(cStr,254,i))
		AADD(aSettings,SubStr(cLine,7))
	Next
EndIF
Return aSettings

/*
Static Function AL_InicioEnc()
dbSelectArea("SFJ")
Return .f.
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AL_EntraEnc³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice									                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Mata297()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AL_EntraEnc(nE,cAlias)
dbSelectArea(cAlias)
Return
//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Al_Saienc ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Fecha enchoice					                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Al_Saienc(nE)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Traz_Marca³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Traz a marca						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Traz_Marca(cProduto)
Local cMarca := ""
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cProduto))
SBM->(dbSetOrder(1))
SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
cMarca := SBM->BM_CODMAR
Return cMarca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³l297FilEnt³ Autor ³ Valdir F. Silva      ³ Data ³25.08.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verif. existencia da Filial para Entrega do Pedido em SM0. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 297FilEnt(ExpC1)                                       	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Codigo da Filial de Entrega                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata297  		                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
STATIC Function A297FilEnt(cFilialEnt)
Local aArea		:= GetArea()
Local lRet 		:= .T.
Local aAreaSM0  := SM0->(GetArea())
If M->FJ_TIPGER == "2"
If !Empty(cFilialEnt).And.Empty(xFilial("SFJ"))
Help(" ",1,"FILENTC")
lRet := .T.
ElseIF Empty(cFilialEnt).And.!Empty(xFilial("SFJ"))
Help(" ",1,"FILENTE")
lRet := .F.
Else
dbSelectArea("SM0")
dbSetOrder(1)
If !dbSeek(SUBS(cNumEmp,1,2)+cFilialEnt)	// Procura pelo Numero da Empresa e Filial para Entrega.
Help(" ",1,"C7_FILENT")
lRet := .F.
EndIf
EndIf
EndIf
RestArea(aAreaSM0)
RestArea(aArea)
Return lRet
*/


//Atualiza a acols
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA297ATt ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Traz a marca						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTA297ATt()

Local aSE := {0,0,0}

Local i   := 0, nR := 0

vB2Estoq := 0
vB2Dispo := 0
vDFEstoq := 0
vDFDispo := 0

FG_MEMVAR()

DbSelectArea("SB1")
DbSetOrder(1)
MsSeek(xfilial("SB1")+aCols[n,ProcH('DF_PRODUTO')])

SDF->(DbSetOrder(1))
if SDF->(DbSeek( xFilial("SDF")+SFJ->FJ_CODIGO+aCols[n,ProcH('DF_PRODUTO')]))
	vDFEstoq := SDF->DF_QTDEST
	vDFDispo := SDF->DF_QTDPC
endif

aSE := SaldoEst(aCols[n,ProcH('DF_PRODUTO')])

vB2Estoq := aSE[1] // SB2->B2_QATU
vB2Dispo := aSE[2] // SB2->B2_SALPEDI

cqtEstoq := Alltrim(Transform(vDFEstoq, "@E 99,999")) + " / " + Alltrim(Transform(vB2Estoq, "@E 99,999"))
cqtDispo := Alltrim(Transform(vDFDispo, "@E 99,999")) + " / " + AllTrim(Transform(vB2Dispo, "@E 99,999"))

SBL->(DbSetOrder(1))  //Filial+Ano+Mes
SBL->(MsSeek(xFilial("SBL")+SB1->B1_COD+cAnoMes))

Do Case
	Case SBL->BL_CODFORM == [PES]
		cDescForm := "D[m-1]"
	Case SBL->BL_CODFORM == [PME]
		cDescForm := "( D[m-1] + D[m-2] + D[m-3] ) / 3"
	Case SBL->BL_CODFORM == [PTE]
		cDescForm := "D[m-1] + ( D[m-1] - D[m-2] )"
	Case SBL->BL_CODFORM == [PSA]
		cDescForm := "D[m-12] * ( (D[m-1] + D[m-2] + D[m-3]) / (D[m-13] + D[m-14] + D[m-15]) )"
EndCase

cFornComp1 := cFornComp2 := space(50)
nQtdNotas := 0
DbSelectArea( "SD1" )
DbSetOrder(7)
DbSeek( xFilial("SD1") + aCols[n,ProcH('DF_PRODUTO')] + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") + dtos(dDataBase+1) , .t. )
If !Bof()
	Skip(-1)
EndIf
While !Bof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. aCols[n,ProcH('DF_PRODUTO')] == SD1->D1_COD
	DbSelectArea( "SF4" )
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + SD1->D1_TES )
	If SF4->F4_ESTOQUE == "S" .and. SF4->F4_DUPLIC == "S"
		If lF4_OPEMOV
			If SF4->F4_OPEMOV # "01"
				DbSelectArea( "SD1" )
				DbSkip(-1)
				Loop
			EndIf
		EndIf
		DbSelectArea( "SA2" )
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA )
		nQtdNotas++
		Do Case
			Case nQtdNotas = 1
				cFornComp1 := Transform(SD1->D1_DTDIGIT,"@D") + " R$" + Transform((((SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA)-SD1->D1_VALDESC)/SD1->D1_QUANT),"@E 999,999.99") + " " + left(SA2->A2_NOME,17)
			Case nQtdNotas = 2
				cFornComp2 := Transform(SD1->D1_DTDIGIT,"@D") + " R$" + Transform((((SD1->D1_TOTAL+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA)-SD1->D1_VALDESC)/SD1->D1_QUANT),"@E 999,999.99") + " " + left(SA2->A2_NOME,17)
		EndCase
		If nQtdNotas >= 2
			Exit
		EndIf
	EndIf

	cPecaAtu := SB1->B1_COD

	DbSelectArea( "SD1" )
	DbSkip(-1)
EndDo
FS_VERKIT()
////////////////////////////////////////////////////////////////////////////////////////
///      Andre Luis Almeida      ///   16/04/2004   ///      Itens Relacionados      ///
////////////////////////////////////////////////////////////////////////////////////////
DbSelectArea("SB1")
nOrderSB1 := indexord()
nRecNoSB1 := RecNo()
DbSelectArea("SB2")
nOrderSB2 := indexord()
nRecNoSB2 := RecNo()
DbSelectArea("SBM")
nOrderSBM := indexord()
nRecNoSBM := RecNo()
DbSelectArea("SBL")
nOrderSBL := indexord()
nRecNoSBL := RecNo()

cSeekSB1  := ""
cRelacGrp := SB1->B1_GRUPO
cRelacIte := SB1->B1_CODITE
aIteRelac := {}
nRelacTot := 0
cRelac1 := cRelac2 := cRelac3 := cRelac4 := ""
cRelABC1 := cRelABC2 := cRelABC3 := cRelABC4 := ""
nRelac1 := nRelac2 := nRelac3 := nRelac4 := 0
DbSelectArea("SBM")
DbSetOrder(1)
DbSeek(xFilial("SBM") + SB1->B1_GRUPO )
aIteRelac := {}
For nR := 1 to (len(alltrim(SBM->BM_GRUREL))/5)
	cSeekSB1 := left(substr(SBM->BM_GRUREL,((nR*5)-4),4)+space(4),4) + left(cRelacIte,SBM->BM_LENREL)
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek(xFilial("SB1") + cSeekSB1 )
	While !Eof() .and. SB1->B1_FILIAL == xFilial("SB1") .and. cSeekSB1 == SB1->B1_GRUPO+left(SB1->B1_CODITE,SBM->BM_LENREL)
		If SB1->B1_GRUPO+SB1->B1_CODITE # cRelacGrp+cRelacIte
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2") + SB1->B1_COD + "01" , .t. )
			While !Eof() .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_COD == SB1->B1_COD .and. SB2->B2_LOCAL <= "49"
				nPosRel := 0
				nPosRel := aScan(aIteRelac,{|x| x[1] == SB1->B1_GRUPO+" "+SB1->B1_CODITE })
				If nPosRel == 0
					// luis: ABC no item relacionado (2)
					DBSelectArea("SBL")
					DBSetOrder(1)
					IF Month(dDataBase)==1
						cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
					Else
						cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
					EndIf
					if DBSeek(xFilial("SBL")+SB1->B1_COD+cAnoMes)
						aAdd(aIteRelac,{ SB1->B1_GRUPO+" "+SB1->B1_CODITE , SB2->B2_QATU , SBL->BL_ABCVEND+SBL->BL_ABCCUST })
					else
						aAdd(aIteRelac,{ SB1->B1_GRUPO+" "+SB1->B1_CODITE , SB2->B2_QATU , "" })
					endif
				Else
					aIteRelac[nPosRel,2] += SB2->B2_QATU
				EndIf
				nRelacTot += SB2->B2_QATU
				DbSelectArea("SB2")
				DbSkip()
			EndDo
		EndIf
		DbSelectArea("SB1")
		DbSkip()
	EndDo
Next
If nRelacTot > 0
	cTotal := STR0128+Transform(len(aIteRelac),"@E 9999")+STR0129
	aSort(aIteRelac,1,,{|x,y| x[2] > y[2] })
	For nR := 1 to 4
		cRelR := str(nR,1)
		If len(aIteRelac) >= nR
			cRelac&cRelR := " - "+ aIteRelac[nR,1]
			nRelac&cRelR := aIteRelac[nR,2]
			cRelABC&cRelR := aIteRelac[nR,3]
		Else
			cRelac&cRelR := ""
			cRelABC&cRelR := ""
			nRelac&cRelR := 0
		EndIf
	Next
Else
	aIteRelac := {}
	cTotal := cRelac1 := cRelac2 := cRelac3 := cRelac4 := space(50)
	cRelABC1 := cRelABC2 := cRelABC3 := cRelABC4 := space(2)
EndIf
DbSelectArea("SBL")
DbSetOrder(nOrderSBL)
DbGoTo(nRecNoSBL)
DbSelectArea("SBM")
DbSetOrder(nOrderSBM)
DbGoTo(nRecNoSBM)
DbSelectArea("SB2")
DbSetOrder(nOrderSB2)
DbGoTo(nRecNoSB2)
DbSelectArea("SB1")
DbSetOrder(nOrderSB1)
DbGoTo(nRecNoSB1)

////////////////////////////////////////////////////////////////////////////////////////
/// Luis Delorme - Itens Substituidos
////////////////////////////////////////////////////////////////////////////////////////
DBSelectArea("VE9")
nContAnt := 0
nContPos := 0
lPecFound := .t.
aVecTot := {}
aVecAnt := {}
aVecPos := {}
cItemAnt := cRelacIte
cGrupoIte := cRelacGrp
cItemPos := cRelacIte
while (lPecFound)
	lPecFound := .f.
	DbSetOrder(3)
	// pecas que substituiram a peca selecionada
	if DBSeek(xFilial("VE9")+cItemPos) .and. ((nContPos + nContAnt) < 4)
		lPecFound := .t.
		cItemPos := VE9->VE9_ITENOV
		aAdd(aVecPos,cItemPos)
		nContPos++
	endif
	//  pecas que foram substituidas pela selecionada
	DbSetOrder(4)
	if DBSeek(xFilial("VE9")+cItemAnt) .and. ((nContPos + nContAnt) < 4)
		lPecFound := .t.
		cItemAnt := VE9->VE9_ITEANT
		aAdd(aVecAnt,cItemAnt)
		nContAnt ++
	endif
enddo
for i := 0 to (nContAnt -1)
	aAdd(aVecTot,aVecAnt[nContAnt-i])
next
aAdd(aVecTot,cRelacIte)
vItePrinc := Len(aVecTot)
for i := 1 to nContPos
	aAdd(aVecTot,aVecPos[i])
next
If len(aVecTot) == 1
	vItePrinc := 0
	aVecTot := {}
	aAdd(aVecTot," ")
EndIf
for i := len(aVecTot) to 4
	aAdd(aVecTot," ")
next
// pega o ABC do item
aVecABCSal := {}
aVecABCIt := {}
for i := 1 to 5
	DBSelectArea("SBL")
	DBSetOrder(1)
	IF Month(dDataBase)==1
		cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
	Else
		cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
	EndIf
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+cGrupoIte+aVecTot[i])
	DBSelectArea("SB2")
	DBSetOrder(1)
	if DBSeek(xFilial("SB2")+SB1->B1_COD+"01")
		aAdd(aVecABCSal,SB2->B2_QATU)
	else
		aAdd(aVecABCSal,0)
	endif
	DBSelectArea("SBL")
	if DBSeek(xFilial("SBL")+SB1->B1_COD+cAnoMes)
		aAdd(aVecABCIt, SBL->BL_ABCVEND+SBL->BL_ABCCUST)
	else
		aAdd(aVecABCIt, "  " )
	endif
next
//
DbSelectArea("SBL")
DbSetOrder(nOrderSBL)
DbGoTo(nRecNoSBL)
DbSelectArea("SBM")
DbSetOrder(nOrderSBM)
DbGoTo(nRecNoSBM)
DbSelectArea("SB2")
DbSetOrder(nOrderSB2)
DbGoTo(nRecNoSB2)
DbSelectArea("SB1")
DbSetOrder(nOrderSB1)
DbGoTo(nRecNoSB1)

Obj23:refresh()
Obj24:refresh()
Obj25:refresh()
Obj26:refresh()
Obj27:refresh()
Obj28:refresh()
Obj29:refresh()
Obj30:refresh()
Obj31:refresh()
Obj32:refresh()
Obj33:refresh()
Obj34:refresh()
Obj35:refresh()
Obj36:refresh()
Obj37:refresh()
Obj38:refresh()
Obj39:refresh()
Obj40:refresh()
Obj41:refresh()
Obj42:refresh()
Obj43:refresh()
Obj44:refresh()
Obj45:refresh()
Obj46:refresh()
Obj47:refresh()
Obj48:refresh()
Obj49:refresh()
Obj50:refresh()
Obj51:refresh()
Obj52:refresh()
Obj53:refresh()
Obj54:refresh()
Obj55:refresh()
//
oEnc01:EnchRefreshAll()
//
Return


//Valida e atualiza os totais
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MT297MVLDt³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao							                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297MVLDt(lT)
Local lRet := .T.
Local aSE  := {}
Local ni
Default lT := .t.
For ni:=1 to Len(aCols)
	aSE := SaldoEst(aCols[ni,ProcH('DF_PRODUTO')])
	If aSE[2] < 0
		aSE[2] := 0
	EndIf

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aCols[ni,ProcH('DF_PRODUTO')]))

	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5")+aCols[ni,ProcH('DF_PRODUTO')]))

	SBZ->(DbSetOrder(1))
	SBZ->(DbSeek(xFilial("SBZ")+aCols[ni,ProcH('DF_PRODUTO')]))

	nQtdInf:=aCols[ni,ProcH('DF_QTDINF')]
	If Empty(nQtdInf)
		nQtdInf:=1
	EndIf
	IF M->FJ_TIPGER != "3"
		if SFJ->(FieldPos("FJ_FORMUL")) == 0
			M->FJ_FORMUL := ""
		Endif
		if !Empty(M->FJ_FORMUL)
			aCols[ni,ProcH('DF_VLRTOT')] := nQtdInf * Fg_Formula(M->FJ_FORMUL)
		Else
			IF M->FJ_TIPPRC == "1"
				aCols[ni,ProcH('DF_VLRTOT')] := (nQtdInf*RetFldProd(SB1->B1_COD,"B1_CUSTD"))
			ElseIF M->FJ_TIPPRC == "2"
				aCols[ni,ProcH('DF_VLRTOT')] := (nQtdInf*RetFldProd(SB1->B1_COD,"B1_UPRC"))
			ElseIF M->FJ_TIPPRC == "3" .or. M->FJ_TIPPRC == "4"
				aCols[ni,ProcH('DF_VLRTOT')] := (nQtdInf*SB1->B1_PRV1)
			EndIf
		Endif
	Endif
	If aCols[ni,ProcH('DF_VLRTOT')] < 0.01
		aCols[ni,ProcH('DF_VLRTOT')] := 0.01
	Endif

	aCols[ni,ProcH('DF_QE')] := If(SB1->B1_QE>99999,99999,SB1->B1_QE)
	if aCols[ni,ProcH('DF_QE')] == 0
		aCols[ni,ProcH('DF_QE')] := 1
	endif

Next
If lT
	If !Empty(aCols[n,ProcH('DF_CODITE')])
		For ni:=1 to Len(aCols) - 1
			If aCols[n,ProcH('DF_CODITE')] == aCols[ni,ProcH('DF_CODITE')] .AND. ;
				aCols[n,ProcH('DF_CODGRP')] == aCols[ni,ProcH('DF_CODGRP')]
				Help("  ",1,"EXISTCHAV")
				oGetDados:oBrowse:Refresh()
				return .F.
			EndIf
		Next
	EndIf
	oGetDados:oBrowse:Refresh()
EndIf
FS_TOTFORNEC() // Total valor por fornecedor
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcH     ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ProcH								                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcH(cCampo)
Return aScan(aHeader,{|x|Trim(x[2])== cCampo })

Function FS_TRATAQTD()
Local ni := 0
DbSelectArea("SB1")
nOrderSB1 := indexord()
nRecNoSB1 := RecNo()
DbSelectArea("SB2")
nOrderSB2 := indexord()
nRecNoSB2 := RecNo()
DbSelectArea("SBM")
nOrderSBM := indexord()
nRecNoSBM := RecNo()
DbSelectArea("SBL")
nOrderSBL := indexord()
nRecNoSBL := RecNo()

// Trata recalculo dos itens

If ProcH('DF_CODITE') > 0 .AND. ( oGetDados:oBrowse:nColPos == (ProcH('DF_CODGRP') + 1)  .Or. oGetDados:oBrowse:nColPos == (ProcH('DF_CODITE') + 1) )

	If !Empty(aCols[n,ProcH('DF_CODITE')])
		For ni:=1 to Len(aCols) - 1
			If aCols[n,ProcH('DF_CODITE')] == aCols[ni,ProcH('DF_CODITE')] .AND. ;
				aCols[n,ProcH('DF_CODGRP')] == aCols[ni,ProcH('DF_CODGRP')]
				Help("  ",1,"EXISTCHAV")
				oGetDados:oBrowse:Refresh()
				return .F.
			EndIf
		Next
	EndIf
	//	MT297MVLDt()
EndIf
if oGetDados:oBrowse:nColPos == (ProcH('DF_CODITE'))
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aCols[n,ProcH('DF_PRODUTO')]))
	If SB1->B1_FLAGSUG # "1"
		MsgAlert(STR0138,STR0103) //"Item nao pode ser incluido na Susgestao de Compras! Verifique o campo B1_FLAGSUG."
		n := ( oGetDados:oBrowse:nAt )
		aCols[n,ProcH('DF_CODGRP')] := space(len(SB1->B1_GRUPO))
		aCols[n,ProcH('DF_CODITE')] := space(len(SB1->B1_CODITE))
		aCols[n,ProcH('DF_PRODUTO')] := space(len(SB1->B1_COD))
		oGetDados:oBrowse:nColPos  := ProcH('DF_CODGRP')
		Eval( oGetDados:oBrowse:bDrawSelect )
		oGetDados:oBrowse:Refresh()
		return .F.
	EndIf
	If SB1->B1_CLASSVE # "1"
		MsgAlert(STR0139,STR0103) //"Item nao pode ser incluido na Susgestao de Compras! Verifique o campo B1_CLASSVE."
		n := ( oGetDados:oBrowse:nAt )
		aCols[n,ProcH('DF_CODGRP')] := space(len(SB1->B1_GRUPO))
		aCols[n,ProcH('DF_CODITE')] := space(len(SB1->B1_CODITE))
		aCols[n,ProcH('DF_PRODUTO')] := space(len(SB1->B1_COD))
		oGetDados:oBrowse:nColPos  := ProcH('DF_CODGRP')
		Eval( oGetDados:oBrowse:bDrawSelect )
		oGetDados:oBrowse:Refresh()
		return .F.
	EndIf
	If aCols[n,ProcH('DF_VLRTOT')] < 0.01
		aCols[n,ProcH('DF_VLRTOT')] := 0.01
	Endif
	MTA297ATt()
endif

&& Trata linha/coluna da quantidade
If oGetDados:oBrowse:nColPos == (ProcH('DF_QTDINF')) // .and. oGetDados:LinhaOk() // Andre Luis Almeida 23/03/06 - Incluir Item

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aCols[n,ProcH('DF_PRODUTO')]))

	nQtdInf:=aCols[n,ProcH('DF_QTDINF')]
	If Empty(nQtdInf)
		nQtdInf:=0
	EndIf
	if SFJ->(FieldPos("FJ_FORMUL")) == 0
		M->FJ_FORMUL := ""
	Endif
	if !Empty(M->FJ_FORMUL)
		aCols[n,ProcH('DF_VLRTOT')] := nQtdInf*Fg_Formula(M->FJ_FORMUL)
	ElseIF M->FJ_TIPPRC == "1"
		aCols[n,ProcH('DF_VLRTOT')] := (nQtdInf*RetFldProd(SB1->B1_COD,"B1_CUSTD"))
	ElseIF M->FJ_TIPPRC == "2"
		aCols[n,ProcH('DF_VLRTOT')] := (nQtdInf*RetFldProd(SB1->B1_COD,"B1_UPRC"))
	Else
		aCols[n,ProcH('DF_VLRTOT')] := (nQtdInf*SB1->B1_PRV1)
	EndIf

	If nQtdInf # 0
		If aCols[n,ProcH('DF_VLRTOT')] < 0.01
			aCols[n,ProcH('DF_VLRTOT')] := 0.01
		EndIf
	Else
		aCols[n,Len(aCols[n])] := .t. // Deleta Item na Sugestao
	EndIf
	/*
	If oGetDados:oBrowse:nAt + 1 <= Len(aCols)

	n := ( oGetDados:oBrowse:nAt += 1 )
	oGetDados:oBrowse:nColPos  := ProcH('DF_QTDINF')
	Eval( oGetDados:oBrowse:bDrawSelect )
	oGetDados:oBrowse:Refresh()

	EndIf
	*/
	oGetDados:oBrowse:Refresh()

EndIf

FS_TOTFORNEC() // Total valor por fornecedor

DbSelectArea("SBL")
DbSetOrder(nOrderSBL)
DbGoTo(nRecNoSBL)
DbSelectArea("SBM")
DbSetOrder(nOrderSBM)
DbGoTo(nRecNoSBM)
DbSelectArea("SB2")
DbSetOrder(nOrderSB2)
DbGoTo(nRecNoSB2)
DbSelectArea("SB1")
DbSetOrder(nOrderSB1)
DbGoTo(nRecNoSB1)


Obj23:refresh()
Obj24:refresh()
Obj25:refresh()
Obj26:refresh()
Obj27:refresh()
Obj28:refresh()
Obj29:refresh()
Obj30:refresh()
Obj31:refresh()
Obj32:refresh()
Obj33:refresh()
Obj34:refresh()
Obj35:refresh()
Obj36:refresh()
Obj37:refresh()
Obj38:refresh()
Obj39:refresh()
Obj40:refresh()
Obj41:refresh()
Obj42:refresh()
Obj43:refresh()
Obj44:refresh()
Obj45:refresh()
Obj46:refresh()
Obj47:refresh()
Obj48:refresh()
Obj49:refresh()
Obj50:refresh()
Obj51:refresh()
Obj52:refresh()
Obj53:refresh()
Obj54:refresh()
Obj55:refresh()
oEnc01:EnchRefreshAll()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_GRP_TSUGEST()³ Autor ³ Andre Luis Almeida ³ Data³13/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Atual. o MV_PAR07 da PERG. com Grp Originais e/ou Nao Orig. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRP_TSUGEST()
Local cGrupos := ""
Local cFilter := ""
If MV_PAR06 == 1 // Original
	cFilter := "1"
ElseIf MV_PAR06 == 2	// Nao Original
	cFilter := "0"
Else // Ambos: Original e Nao Original
	cFilter := "1/0"
EndIf
DBSelectArea("SBM")
DbSetOrder(1)
DbSeek( xFilial("SBM") )
While !Eof() .and. SBM->BM_FILIAL == xFilial("SBM")
	If SBM->BM_PROORI $ cFilter .and. Alltrim(SBM->BM_TIPGRU) == "1"
		cGrupos += SBM->BM_GRUPO + "/"
	EndIf
	DBSelectArea("SBM")
	DbSkip()
EndDo
MV_PAR07 := left(cGrupos+space(99),99)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_ExpSug		 ³ Autor ³ Wilson	    	  ³ Data³13/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Exporta sugestao											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ExpSug()

Private cDesc1     := ""
Private cDesc2     := ""
Private cDesc3     := ""
Private nLin := 1
Private aPag := 1
Private cCabec1    := ""
Private cCabec2    := ""
Private aReturn   := { OemToAnsi(STR0014), 1,OemToAnsi(STR0015), 1, 2, 1, "",1 }
Private cTamanho   := "M"           // P/M/G
Private Limite     := 132         // 80/132/220
Private cTitulo    := ""
Private cNomProg
Private cNomeRel
Private nLastKey   := 0
Private nCaracter  := 18
Private oReport
Private cStr := ""
           
oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ReportDef		 ³ Autor ³ Thiago   	    	   ³ Data³ 24/05/17³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Imprime TXT												 				 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 	                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()  

oReport := TReport():New("SUGPLAN",STR0001,,{|oReport| MTA297IMP(oReport)}) // Sugestao de compra

oSection1 := TRSection():New(oReport,STR0176,{"SB1"})
TRCell():New(oSection1,"B1_GRUPO","SB1",STR0177,,10)
TRCell():New(oSection1,"B1_CODITE","SB1",STR0178,,30)
TRCell():New(oSection1,"B1_DESC","SB1",STR0179,,30)
TRCell():New(oSection1,"",,STR0180,"@!",15,, {|| cQtInf } )
TRCell():New(oSection1,"B1_UCOM","SB1",STR0181,,15)
TRCell():New(oSection1,"",,STR0182,"@!",20,, {|| cVlrTot } )
               
Return oReport


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³MTA297IMP           Autor ³ Thiago	    	    ³ Data³24/05/17³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Imprime Relatorio.          											 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTA297IMP()
Local ni := 0
Local oSection1 := oReport:Section(1)

oSection1:Init()

DbSelectArea("SB1")
nOrderSBL := indexord()
nRecNoSBL := RecNo()

nTotPrt := 0
for ni = 1 to len(aCols)
	lDeleted := .f.
	IF ValType(aCols[ni,Len(aCols[ni])]) == "L"
		lDeleted := aCols[ni,Len(aCols[ni])]      // Verifica se esta Deletado
	EndIF
	IF !lDeleted
		DbSelectArea("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+aCols[ni,ProcH('DF_PRODUTO')])
		cQtInf  := Transform(aCols[ni,ProcH('DF_QTDINF')],"@E 999999.99")
		cVlrTot := Transform(aCols[ni,ProcH('DF_VLRTOT')], "@E 99999999.99")
		oSection1:PrintLine()
	EndIF
next
oSection1:Finish()

DbSelectArea("SB1")
DBSetOrder(nOrderSBL)
DBGoto(nRecNoSBL)


Return

nloop := 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TOTFORNºAutor  ³Fabio               º Data ³  03/23/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Totaliza valor do fornecedor                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TOTFORNEC()

Local nTotForn := 0, nPos:=0

aValorPed := {}

Aadd(aValorPed, { "Total","","Total", 0, 0 } )

nPesoTot := 0

For nTotForn := 1 to Len(aCols)

	If !aCols[nTotForn,Len(aCols[nTotForn])]

		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1") + aCols[nTotForn,FG_POSVAR("DF_PRODUTO")] )

			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2") + SB1->B1_PROC + SB1->B1_LOJPROC )

			If ( Len(aValorPed) == 1 .Or. ( nPos:=Ascan(aValorPed,{|x| x[1]+x[2]==SB1->B1_PROC+SB1->B1_LOJPROC }) ) == 0 )
				Aadd(aValorPed, { SB1->B1_PROC , SB1->B1_LOJPROC , SA2->A2_NOME , 0, 0 } )
				nPos := Len(aValorPed)
			EndIf

			aValorPed[1,4]    += aCols[nTotForn,FG_POSVAR("DF_VLRTOT")]
			aValorPed[nPos,4] += aCols[nTotForn,FG_POSVAR("DF_VLRTOT")]

			If FieldPos("A2_VLRMINP") # 0
				aValorPed[nPos,5] := SA2->A2_VLRMINP
			EndIf

		EndIf
		nPesoTot += ( aCols[nTotForn,FG_POSVAR("B1_PESO")] * aCols[nTotForn,FG_POSVAR("DF_QTDINF")] )

	EndIf 

Next

If Type("oLblValor") # "U"
	oLblValor:SetArray(aValorPed)
	oLblValor:bLine := { || { aValorPed[oLblValor:nAt,1] ,;
	Transform(aValorPed[oLblValor:nAt,4],"@E 999,999,999.99"),;
	Transform(aValorPed[oLblValor:nAt,5],"@E 999,999,999.99")}}
	oLblValor:SetFocus()
	oLblValor:Refresh()
	oGetDados:oBrowse:SetFocus()
	oGetDados:oBrowse:Refresh()
EndIf

oPesoTot:refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VERKIT		 ³ Autor ³ Wilson	    	  ³ Data³13/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Verifica KIT												 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERKIT()
lKIT := .f.
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xfilial("SB1")+aCols[oGetDados:oBrowse:nAt,ProcH('DF_PRODUTO')])
DbSelectArea("VEH")
DbSetOrder(1)
If DbSeek(xFilial("VEH")+SB1->B1_GRUPO+SB1->B1_CODITE)
	lKIT := .t.
Else
	DbSelectArea("VE8")
	DbSetOrder(2)
	If DbSeek(xFilial("VE8")+SB1->B1_GRUPO+SB1->B1_CODITE)
		lKIT := .t.
	EndIf
EndIf
oKIT:SetFocus()
oKIT:Refresh()
oGetDados:oBrowse:SetFocus()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³MenuDef		 ³ Autor ³ Wilson	    	  ³ Data³13/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³Menu														 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {{STR0002  ,"AxPesqui", 0 , 1},; //"Pesquisar"
{STR0003  ,"MT297MVist", 0 , 2},; //"Visualizar"
{STR0067  ,"MT297MInct", 0 , 3},; //"Incluir"
{STR0068  ,"MT297MAltt", 0 , 4, 2},; //"Efetivar"
{STR0069  ,"MT297MCant", 0 , 5},; //"Cancelar Efet."
{STR0007  ,"MT297MImpt", 0 , 5},; //"Imprimir"
{STR0008  ,"MT297MExct", 0 , 5},;  //"Excluir"
{STR0076  ,"MATA297LEG", 0 , 6}} //Legenda
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_M297QT		 ³ Autor ³ Wilson	    	  ³ Data³13/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Calculo dos valores										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_M297QT()

FG_MEMVAR()

nQtdInf := M->DF_QTDINF
If Empty(nQtdInf)
	nQtdInf:=0
EndIf
aCols[n,ProcH('DF_QTDINF')] := nQtdInf

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+aCols[n,ProcH('DF_PRODUTO')]))

if SFJ->(FieldPos("FJ_FORMUL")) == 0
	M->FJ_FORMUL := ""
Endif
if !Empty(M->FJ_FORMUL)
	aCols[n,ProcH('DF_VLRTOT')] := nQtdInf*Fg_Formula(M->FJ_FORMUL)
Else
	IF M->FJ_TIPPRC == "1"
		aCols[n,ProcH('DF_VLRTOT')] := (nQtdInf*RetFldProd(SB1->B1_COD,"B1_CUSTD"))
	ElseIF M->FJ_TIPPRC == "2"
		aCols[n,ProcH('DF_VLRTOT')] := (nQtdInf*RetFldProd(SB1->B1_COD,"B1_UPRC"))
	Else
		aCols[n,ProcH('DF_VLRTOT')] := (nQtdInf*SB1->B1_PRV1)
	EndIf
Endif
If nQtdInf # 0
	If aCols[n,ProcH('DF_VLRTOT')] < 0.01
		aCols[n,ProcH('DF_VLRTOT')] := 0.01
	EndIf
Else
	aCols[n,Len(aCols[n])] := .t. // Deleta Item na Sugestao
EndIf

oGetDados:oBrowse:Refresh()

FS_TOTFORNEC() // Totaliza Fornecedor qdo atualiza qtde. 22/02/08 - Andre Luis Almeida

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA297MFilºAutor  ³Fabio               º Data ³  03/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida campos                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA297MFil()
Local nP  := 0

SetKey(VK_F4, Nil) // pra não abrir varias janelas

FG_MEMVAR()

If ( ReadVar() == "M->DF_CODGRP" .Or. ReadVar() == "M->DF_CODITE" )

	&& Verifica se o item foi substituido
	DbSelectArea("VE9")
	DbSetOrder(3)
	DbSeek(xFilial("VE9") + M->DF_CODITE )

	Do While !EOF() .and. VE9->VE9_FILIAL + VE9->VE9_ITEANT == xFilial("VE9") + M->DF_CODITE

		If VE9->VE9_DATSUB <= dDataBase

			If MsgYesNo(STR0152+M->DF_CODGRP+" "+M->DF_CODITE+STR0153+M->DF_CODGRP+" "+VE9->VE9_ITENOV+STR0154,STR0103)
				SB1->(DbSetOrder(7))
				SB1->(DbSeek(xFilial("SB1") + M->DF_CODGRP + VE9->VE9_ITENOV ))
				aCols[n,FG_POSVAR("DF_PRODUTO")] := SB1->B1_COD
				M->DF_CODITE                      := SB1->B1_CODITE
			Else
				aCols[n,FG_POSVAR("DF_PRODUTO")] := Space(Len(aCols[n,FG_POSVAR("DF_PRODUTO")]))
				//				MsgStop("O item "+M->DF_CODGRP+" "+M->DF_CODITE+" "+SB1->B1_DESC+" foi substituido!","Atencao")
				Return(.f.)
			EndIf

		EndIf

		DbSelectArea("VE9")
		DbSkip()

	Enddo

	&& Verifica se a peca esta ativa
	DbSelectArea("SB1")
	//	DbSetOrder(7)
	//	DbSeek( xFilial("SB1") + M->DF_CODGRP + M->DF_CODITE )
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + aCols[n,FG_POSVAR("DF_PRODUTO")] )

	If SB1->B1_ATIVO == "N"
		aCols[n,FG_POSVAR("DF_PRODUTO")] := Space(Len(aCols[n,FG_POSVAR("DF_PRODUTO")]))
		MsgStop("O item "+M->DF_CODGRP+" "+M->DF_CODITE+" "+SB1->B1_DESC+" nao esta ativo!",STR0103)
		Return(.f.)
	EndIf

ElseIf ReadVar() == "M->DF_QTDINF"

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + aCols[n,FG_POSVAR("DF_PRODUTO")] )
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
	DbSelectArea("SB5")
	DbSetOrder(1)
	DbSeek(xFilial("SB5")+SB1->B1_COD)
	//
	if M->FJ_TIPGER == "3"
		aCols[n,FG_POSVAR("DF_VLRTOT")] := M->DF_QTDINF * aCols[n,FG_POSVAR("DF_VLRTOT")] / aCols[n,FG_POSVAR("DF_QTDINF")]
	else
		if SFJ->(FieldPos("FJ_FORMUL")) == 0
			M->FJ_FORMUL := ""
		Endif
		if !Empty(M->FJ_FORMUL)
			aCols[n,ProcH('DF_VLRTOT')] := M->DF_QTDINF*Fg_Formula(M->FJ_FORMUL)
		Else
			if M->FJ_TIPPRC == "1"
				aCols[n,FG_POSVAR("DF_VLRTOT")] := RetFldProd(SB1->B1_COD,"B1_CUSTD") * M->DF_QTDINF
			Elseif M->FJ_TIPPRC == "2"
				aCols[n,FG_POSVAR("DF_VLRTOT")] := RetFldProd(SB1->B1_COD,"B1_UPRC") * M->DF_QTDINF
			Else
				aCols[n,FG_POSVAR("DF_VLRTOT")] := SB1->B1_PRV1 * M->DF_QTDINF
			Endif

		Endif
	endif
	//
	aCols[n,FG_POSVAR("DF_QE")] := SB1->B1_QE
	aCols[n,FG_POSVAR("DF_QTDINF")] := M->DF_QTDINF
	//
EndIf

If ReadVar() == "M->DF_PRODUTO"
	if !Empty(M->DF_PRODUTO)
		aCols[n,FG_POSVAR("DF_PRODUTO")] := M->DF_PRODUTO
		SB1->(DbSetOrder(1))
		SB1->(DbSeek( xFilial("SB1") + aCols[n,FG_POSVAR("DF_PRODUTO")] ))
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2") + M->DF_PRODUTO + FM_PRODSBZ(M->DF_PRODUTO,"SB1->B1_LOCPAD") ))
		nSaldo := SaldoSB2()
		if FG_POSVAR("DF_CODGRP") > 0
			aCols[n,FG_POSVAR("DF_CODGRP")] := SB1->B1_GRUPO
		end
		if FG_POSVAR("DF_CODITE") > 0
			aCols[n,FG_POSVAR("DF_CODITE")] := SB1->B1_CODITE
		end
		aCols[n,FG_POSVAR("B1_DESC","aHeader")] := SB1->B1_DESC
		aCols[n,FG_POSVAR("B2_QATU","aHeader")] := nSaldo
		aCols[n,FG_POSVAR("B1_PESO","aHeader")] := SB1->B1_PESO
		MTA297ATt()
		dbSelectArea("SDF")
	EndIf
EndIf


// Levanta Peso Total da Sugestão
If ( ReadVar() == "M->DF_PRODUTO" .Or. ReadVar() == "M->DF_QTDINF" )
	nPesoTot := 0
	For nP := 1 to Len(aCols)
		nPesoTot += ( aCols[nP,FG_POSVAR("B1_PESO")] * aCols[nP,FG_POSVAR("DF_QTDINF")] )
	Next
	oPesoTot:refresh()
Endif
//


SetKey(VK_F4, {|| MATA297M_001ConsultaPecas() })
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VLAUTOGIRO	 ³ Autor ³ Wilson	    	  ³ Data³13/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Verifica Tipos de pedidos									 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLAUTOGIRO(lMostraMsg)

Default lMostraMsg := .f.

If !FG_SEEK("VEJ","VE4->VE4_PREFAB+MV_PAR05",1,.F.)
	If lMostraMsg
		MsgStop(STR0155,STR0103)  //"Tipo de pedido nao cadastrado ou fornecedor invalido!"
	EndIf
	Return(.f.)
EndIf

If (GetNewPar("MV_AUTGIRO","N") == "S".AND.VEJ->VEJ_TIPPED=="01" .Or. GetNewPar("MV_AUTGIRO","N") == "N".AND.VEJ->VEJ_TIPPED#"01")
	If lMostraMsg
		If VEJ->VEJ_TIPPED=="01"
			MsgStop(STR0156+VEJ->VEJ_TIPPED+STR0157,STR0103)
		Else
			MsgStop(STR0156+VEJ->VEJ_TIPPED+STR0158,STR0103)
		EndIf
	EndIf
	Return(.f.)
EndIf

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aConsumoSC³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumula no Array aConsumo a demanda dos produtos			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ aConsumoSC							 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Static Function aConsumoSC(cCodi)
//	Local aConsumo  := {}
//	Local oPeca
//	Local nIdx := 1
//	Local nIdx2 := 1
//	Local aDadosDem := {}
//	Local oUtil := DMS_Util():New()
//	Local dData
//	dbSelectArea('SB1')
//	DBSetOrder(1)
//	DbSeek( xFilial('SB1') + cCodi )
//	MATA297M1_BUSCADEMANDA(cCodi)
//
//	cAnoMes := DTOS(dDatabase)
//	cAno    := substr(cAnoMes,1,4)
//	cMes    := substr(cAnoMes,5,2)
//	nMeses  := 12
//
//	if ! SB1->(EOF())
//		oPeca := DMS_Peca():New(SB1->B1_GRUPO, SB1->B1_CODITE)
//		
//		dData := STOD(cAno+cMes+"10") // dia 10 só de amostragem
//
//		for nIdx := 1 to nMeses
//			cAno      := StrZero(Year(dData),4)
//			cMes      := StrZero(Month(dData),2)
//			aDadosDem := oPeca:GetDemanda(.F., cAno, cMes, 1)
//			
//			for nIdx2 := 1 to LEN(aDadosDem)
//				aDados := aDadosDem[nIdx2]
//				Aadd(aConsumo, aDados[5])
//			next
//			dData := oUtil:RemoveMeses(dData, 1) // remove um mes pra fazer demanda do prox
//		next
//
//	EndIf
//
//	// completando 12 meses
//	if LEN(aDadosDem) < 12
//		for nIdx := LEN(aDadosDem) to 12
//			aAdd(aConsumo, 0)
//		next
//	endif
//
//Return aConsumo

//////////////////////////////////////////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ValidPerg		 ³ Autor ³ Wilson	    	  ³ Data³13/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Perguntes													 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg(cSX1PergMil)
Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cSX1PergMil := left(cSX1PergMil+space(15),len(SX1->X1_GRUPO))

//CASO HAJA MUDANDCA NAS POSICOES DA PERGUNTE, DEVE-SE ALTERAR A ROTINA OFIOA560 (FUNÇÃO OFIOA560FL)

Aadd(aRegs,{cSX1PergMil,"01",STR0159  ,"","","mv_ch1","N",3 ,0,0,"G","(mv_par01 > 0)","mv_par01","","","","60","","","","","","","","","","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"02",STR0160  ,"","","mv_ch2","N",1 ,0,4,"C","","mv_par02","Alto","Alto","High","","mv_par02","Medio","Promedio","Average","","mv_par02","Baixo","Bajo","Low","","mv_par02","Todos","Todos","All","","","","","","","","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"03",STR0161  ,"","","mv_ch3","N",1 ,0,2,"C","","mv_par03","UltPrc / CustMd","","","","mv_par03","Reposicao","Precio de Venta","Sales Price","","mv_par03","Preco de Venda","Reposicion","Replacement","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"04",STR0136  ,"","","mv_ch4","C",18,0,0,"G","","mv_par04","","","","AA/AB/AC/BA/BB/BC/","","","","","","","","","","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"05",STR0137  ,"","","mv_ch5","N",1 ,0,2,"C","","mv_par05","Sim","Si","Yes","","mv_par05","Nao","No","No","","","","","","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"06",STR0140  ,"","","mv_ch6","N",1 ,0,1,"C","FS_GRP_TSUGEST()","mv_par06","Original","Original","Original","","","Nao Original","Nao Original","Nao Original","","","Ambos","Ambos","Ambos","","","","","","","","","","","","","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"07",STR0141  ,"","","mv_ch7","C",99,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SBM","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"08",STR0060  ,"","","mv_ch8","C",30,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"09",STR0061  ,"","","mv_ch9","C",30,0,0,"G","","mv_par09","","","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","SB1","S","","","","" } )
Aadd(aRegs,{cSX1PergMil,"10",STR0063  ,"","","MV_CHA","C",99,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
Aadd(aRegs,{cSX1PergMil,"11",STR0004  ,"","","MV_CHB","N",2 ,0,0,"G","","mv_par11","","","","12","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
Aadd(aRegs,{cSX1PergMil,"12",STR0006  ,"","","MV_CHC","N",2 ,0,0,"G","If(MV_PAR12 <= MV_PAR11,.T.,.F.)","mv_par12","","","","6","","","","","","","","","","","","","","","","","","","","","","","","","","" } )
If lMLF // trabalha com Marca / Linha / Familia
	Aadd(aRegs,{cSX1PergMil,"13",STR0169  ,"","","MV_CHD","C", 6 ,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","VQS","","","","","" } )
	Aadd(aRegs,{cSX1PergMil,"14",STR0170  ,"","","MV_CHE","C", 6 ,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","0A","","","","","" } )
	Aadd(aRegs,{cSX1PergMil,"15",STR0171  ,"","","MV_CHF","C", 6 ,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","0B","","","","","" } )
Endif
Aadd(aRegs,{cSX1PergMil,"16",STR0172  ,"","","MV_CHG","C", 6 ,0,0,"G","OFP8600016_VerificacaoFormula(mv_par16)","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","VEG","","","","","" } )

For i:=1 to Len(aRegs)
	If !dbSeek(cSX1PergMil+aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
/////////////////////////
// FNC - 24622 RAFAEL  //
// ALTERAR TAM. CODIGO //
/////////////////////////
dbSelectArea("SX1")
dbSetOrder(1)
IF DbSeek(cSX1PergMil+"08") .and. SX1->X1_TAMANHO == 15
	RecLock("SX1",.f.)
	SX1->X1_TAMANHO := 30
	MsUnlock()
Endif
dbSelectArea("SX1")
dbSetOrder(1)
IF DbSeek(cSX1PergMil+"09") .and. SX1->X1_TAMANHO == 15
	RecLock("SX1",.f.)
	SX1->X1_TAMANHO := 30
	MsUnlock()
Endif
DbSelectArea("SBL")
/////////////////////////
dbSelectArea(_sAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³MATA297LEG		 ³ Autor ³ Wilson	    	  ³ Data³13/12/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Legenda													 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA297LEG()
Local aLegenda := 	{{'BR_VERDE'		,STR0074},; //Em Aberto
{'BR_VERMELHO'		,STR0075}} //Efetivada

MT297MF12(.f.) // Desabilita F12

BrwLegenda(cCadastro,STR0076 ,aLegenda) //Legenda

MT297MF12(.t.) // Habilita F12

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³MT297RECL		 ³ Autor ³ Luis Delorme       ³ Data³13/06/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Recalcula valor toral do SFJ                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297RECL()
if SFJ->(FieldPos("FJ_VALTOT")) <> 0
	DBSelectArea("SDF")
	DBSetOrder(1)
	DBSeek(xFilial("SDF")+M->FJ_CODIGO)
	nSumTot := 0
	while !eof() .and. xFilial("SDF")+M->FJ_CODIGO == SDF->DF_FILIAL + SDF->DF_CODIGO
		nSumTot += SDF->DF_VLRTOT
		DBSkip()
	enddo
	RecLock("SFJ",.f.)
	SFJ->FJ_VALTOT := nSumTot
	MsUnlock()
endif
return

//Valida e atualiza os totais
Function MT297FML(cPar297)
Local lRet := .T.
Local aSE  := {}
Local nX
Local OFP8600016 := ExistFunc("OFP8600016_VerificacaoFormula")

Default cPar297 := ""

If !cPar297 == "TRIGGER"

	If !Empty(M->FJ_FORMUL)
		If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->FJ_FORMUL)
			Return .f.
		EndIf
	EndIf

Endif

For nX:=1 to Len(aCols)
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+aCols[nX,ProcH('DF_PRODUTO')]))
	SB5->(DbSetOrder(1))
	SB5->(MsSeek(xFilial("SB5")+aCols[nX,ProcH('DF_PRODUTO')]))
	aSE := SaldoEst(aCols[nX,ProcH('DF_PRODUTO')])
	if SFJ->(FieldPos("FJ_FORMUL")) == 0
		M->FJ_FORMUL := ""
	Endif
	if !Empty(M->FJ_FORMUL)
		aCols[nX,ProcH('DF_VLRTOT')] := aCols[nX,ProcH('DF_QTDINF')]*Fg_Formula(M->FJ_FORMUL)
	Else
		IF M->FJ_TIPPRC == "1"
			aCols[nX,ProcH('DF_VLRTOT')] := aCols[nX,ProcH('DF_QTDINF')]*RetFldProd(SB1->B1_COD,"B1_CUSTD")
		ElseIF M->FJ_TIPPRC == "2"
			aCols[nX,ProcH('DF_VLRTOT')] := aCols[nX,ProcH('DF_QTDINF')]*RetFldProd(SB1->B1_COD,"B1_UPRC")
		Else
			aCols[nX,ProcH('DF_VLRTOT')] := aCols[nX,ProcH('DF_QTDINF')]*SB1->B1_PRV1
		EndIF
	Endif
Next

oGetDados:oBrowse:Refresh()

If cPar297 == "TRIGGER"
	Return M->FJ_TIPPRC
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ updDemanda     ³ Autor ³ Vinicius Gati      ³ Data³25/01/16³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Calcula a valor da demanda 12 meses e mostra               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M 		                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function updDemanda(cCodB1)
	if VALTYPE(oDlg297) != "U"
		//aConsumo := aConsumoSC( cCodB1 )

		cDemMes1  := aConsumo[01]
		cDemMes2  := aConsumo[02]
		cDemMes3  := aConsumo[03]
		cDemMes4  := aConsumo[04]
		cDemMes5  := aConsumo[05]
		cDemMes6  := aConsumo[06]
		cDemMes7  := aConsumo[07]
		cDemMes8  := aConsumo[08]
		cDemMes9  := aConsumo[09]
		cDemMes10 := aConsumo[10]
		cDemMes11 := aConsumo[11]
		cDemMes12 := aConsumo[12]




		OBJ10:Refresh()
		OBJ11:Refresh()
		OBJ12:Refresh()
		OBJ13:Refresh()
		OBJ14:Refresh()
		OBJ15:Refresh()
		OBJ16:Refresh()
		OBJ17:Refresh()
		OBJ18:Refresh()
		OBJ19:Refresh()
		OBJ20:Refresh()
		OBJ21:Refresh()
	endif
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ ConsulaPecas ³ Autor ³ Vinicius Gati      ³ Data³ 16/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Chama OFIOC520 para peça selecionada no getdados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA297M_001ConsultaPecas()
	if type("M->DF_PRODUTO") == "C" .AND. ! Empty(M->DF_PRODUTO)
		DBSelectArea("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+M->DF_PRODUTO)
		cCodPecInt := M->DF_PRODUTO
		SetKey(VK_F4, Nil) // pra não abrir varias janelas
		OFIOC520(.T.)
		SetKey(VK_F4, {|| MATA297M_001ConsultaPecas() })
	end
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_VLTPROD1  ³ Autor ³ Vinicius Gati      ³ Data³ 18/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Esta funcao foi criada para voltar o valor correto da peca ³±±
±±³           caso a integração estrague o mesmo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function FS_VLTPROD1()
	if M->DF_PRODUTO == "BM_GRUPO"
		M->DF_PRODUTO := cCodPecInt
		aCols[oGetDados:oBrowse:nat,FG_POSVAR("DF_PRODUTO")] := ccodPecInt
	end
	cPecaAtu := SB1->B1_COD
return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ MT297MF12    ³ Autor ³ Andre Luis Almeida ³ Data³ 07/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Parametros F12 - Habilita / Desabilita                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MT297MF12(lHabilita)
If lHabilita
	SetKey(VK_F12,{ || Pergunte( "MT297MF12" , .T. ,,,,.f.)})
Else
	SetKey(VK_F12,Nil)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ MTA297MSX1   ³ Autor ³ Andre Luis Almeida ³ Data³ 10/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Criacao do SX1 - F12                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ MATA297M                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTA297MSX1()
Local aRegs := {}
AADD(aRegs,{STR0183, "", "", "mv_ch1", "N", 1 , 0, 1, "C", '' , "mv_par01", STR0031, STR0031 , STR0031 , "" , "" , STR0030 , STR0030 , STR0030 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {},{},{}}) // Cria Orç. c/possib. de alterar / Nao / Sim
Pergunte("MT297MF12",.f.,,,,.f.)    
Return()

/*/{Protheus.doc} MATA297M1_BUSCADEMANDA
	Buscara a demanda internamente, com sorte não causa lentidao na tela
	
	@type function
	@author Vinicius Gati
	@since 23/08/2017
/*/
Static Function MATA297M1_BUSCADEMANDA()
	if cPecaDem != cPecaAtu
		if FM_SQL(" SELECT COUNT(*) from " + cTableName + " where T01_COD = '"+cPecaAtu+"' ") == 0
			if aScan(aFilaDem, {|cPec| cPec == cPecaAtu}) == 0 // evita mandar gerar demanda sem necessidade
				StartJob("MATA297M4_BuscaDemandaPorThread", GetEnvServer(), .F., { cEmpAnt, xFilial('VS1'), cPecaAtu, cTableName })
				AADD(aFilaDem, cPecaAtu)
			endif
		else
			MATA297M3_UIDemanda(cPecaAtu) // atualiza tela com demanda da peça atual
		endif
	endif
Return .T.

/*/{Protheus.doc} MATA297M4_BuscaDemandaPorThread
	Vai buscar a demanda que é lento e gravar na tabela temporaria via thread
	
	@type function
	@author Vinicius Gati
	@since 23/08/2017
/*/
Function MATA297M4_BuscaDemandaPorThread(aParams)
	Prepare Environment Empresa aParams[1] Filial aParams[2] Modulo "PEC"
	MATA297M5_GeraDemTblTemp(aParams[3], aParams[4])
Return .T.

/*/{Protheus.doc} MATA297M5_GeraDemTblTemp
	Gera a demanda caso necessário na tabela de demanda temporaria
	
	@type function
	@author Vinicius Gati
	@since 24/08/2017
/*/
Function MATA297M5_GeraDemTblTemp(cB1Cod, cTbl)
	local nIdx := 1
	local oPeca
	local cIns := ""

	DbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial('SB1')+ cB1Cod)
	oPeca  := DMS_Peca():New(SB1->B1_GRUPO, SB1->B1_CODITE)

	aDadosDem := oPeca:GetDemanda(.F., '', '', 1)
	for nIdx := 1 to LEN(aDadosDem)
		cIns := " INSERT INTO " + cTbl + " (T01_COD, T01_ANO, T01_MES, T01_QTD, R_E_C_N_O_) "
		cIns += " VALUES ('"+SB1->B1_COD+"','"+aDadosDem[nIdx, 3]+"','"+aDadosDem[nIdx, 4]+"',"+ALLTRIM(STR(aDadosDem[nIdx, 5]))+","
		cIns += " (SELECT COALESCE(MAX(R_E_C_N_O_),0) + 1 FROM "+cTbl+") )"
		tcsqlexec(cIns)
	next
Return .T.

/*/{Protheus.doc} MATA297M2_CRIATAB
	CRia tabela temporario
	
	@type function
	@author Vinicius Gati
	@since 23/08/2017
/*/
Static Function MATA297M2_CRIATAB()
	local cTableName := "T01_"+xFilial('VS3')+DTOS(date())
	
	aFields := {;
		{"T01_COD", "C", 15, 0},;
		{"T01_ANO", "C",  4, 0},;
		{"T01_MES", "C",  2, 0},;
		{"T01_QTD", "N", 20, 0} ;
	}
	MATA297M6_DropTempTables()

	oObjTempTable := OFDMSTempTable():New()
	oObjTempTable:cAlias := cTableName        // Compatibilidade da versao 12
	oObjTempTable:cNomeArquivos := cTableName // compatibilidade da versao 11
	oObjTempTable:aVetCampos := aFields
	oObjTempTable:cMetodo := "MSCREATE"
	oObjTempTable:CreateTable()
	cTableName := oObjTempTable:GetRealName()
Return cTableName

/*/{Protheus.doc} MATA297M3_UIDemanda
	Jogara a demanda na tela de fato
	
	@type function
	@author Vinicius Gati
	@since 23/08/2017
/*/
Static Function MATA297M3_UIDemanda(cB1Cod)
	local cQuery  := " "
	local nIdx    := 1
	local cAnoMes := DTOS(dDatabase)
	local cAno    := substr(cAnoMes,1,4)
	local cMes    := substr(cAnoMes,5,2)
	local nMeses  := 12
	local dData   := date()

	cPecaDem := cB1Cod

	cQuery += " SELECT T01_QTD FROM ("
	for nIdx := 1 to nMeses
		cAno   := StrZero(Year(dData),4)
		cMes   := StrZero(Month(dData),2)
		cQuery += " SELECT COALESCE(SUM(T01_QTD), 0) T01_QTD FROM " + cTableName + " WHERE T01_ANO = '"+cAno+"' AND T01_MES = '"+cMes+"' AND T01_COD = '"+cB1Cod+"' "
		if nIdx < 12
			cQuery += " UNION ALL "
		endif
		dData := oUtil:RemoveMeses(dData, 1) // remove um mes pra fazer demanda do prox
	next
	cQuery += " ) TBL "
	aDem       := oSqlHlp:GetSelectArray(cQuery)
	cPecaDem   := cB1Cod
	cDemMes1   := aDem[1]
	cDemMes2   := aDem[2]
	cDemMes3   := aDem[3]
	cDemMes4   := aDem[4]
	cDemMes5   := aDem[5]
	cDemMes6   := aDem[6]
	cDemMes7   := aDem[7]
	cDemMes8   := aDem[8]
	cDemMes9   := aDem[9]
	cDemMes10  := aDem[10]
	cDemMes11  := aDem[11]
	cDemMes12  := aDem[12]
	cDemPec    := "Peça: " + cB1Cod
	if VALTYPE(Obj10) != "U"
		Obj10:refresh()
		Obj11:refresh()
		Obj12:refresh()
		Obj13:refresh()
		Obj14:refresh()
		Obj15:refresh()
		Obj15:refresh()
		Obj16:refresh()
		Obj17:refresh()
		Obj18:refresh()
		Obj19:refresh()
		Obj20:refresh()
		Obj21:refresh()
		OBJ22:refresh()
	else
		@ aPosObj[3,1]+015, 01*nQtdDis - 17 SAY OBJ10 VAR cDemMes1  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 02*nQtdDis - 17 SAY OBJ11 VAR cDemMes2  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 03*nQtdDis - 17 SAY OBJ12 VAR cDemMes3  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 04*nQtdDis - 17 SAY OBJ13 VAR cDemMes4  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 05*nQtdDis - 17 SAY OBJ14 VAR cDemMes5  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 06*nQtdDis - 17 SAY OBJ15 VAR cDemMes6  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 07*nQtdDis - 17 SAY OBJ16 VAR cDemMes7  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 08*nQtdDis - 17 SAY OBJ17 VAR cDemMes8  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 09*nQtdDis - 17 SAY OBJ18 VAR cDemMes9  OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 10*nQtdDis - 17 SAY OBJ19 VAR cDemMes10 OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 11*nQtdDis - 17 SAY OBJ20 VAR cDemMes11 OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 12*nQtdDis - 17 SAY OBJ21 VAR cDemMes12 OF oDlg297 PIXEL COLOR CLR_HBLUE
		@ aPosObj[3,1]+015, 13*nQtdDis - 17 SAY OBJ22 VAR cDemPec   OF oDlg297 PIXEL COLOR CLR_HBLUE
	endif
Return .T.

/*/{Protheus.doc} MATA297M6_DropTempTables
	Deleta tabelas temporarias anteriores
	
	@type function
	@author Vinicius Gati
	@since 28/08/2017
/*/
Static Function MATA297M6_DropTempTables()
	local nIdx := 1
	local cTbl := ''
	for nIdx := 1 to 15
		cTbl := "T01_"+xFilial('VS3')+DTOS(date()-nIdx)
		if MsFile(cTbl)
			MsErase(cTbl)
		endif
	next
Return .F.

/*/{Protheus.doc} MATA297M7_Reservar_Itens
	Reserva Itens do Orçamento de Transferencia 
	
	@type function
	@author Andre Luis Almeida
	@since 26/09/2019
/*/
Static Function MATA297M7_Reservar_Itens()
Local lRet     := .t.
Local oEstoq   := DMS_Estoque():New()
Local cArmDest := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE"))) // Armazem Reserva
Local cQuery   := ""
Local cQAlVS3  := "SQLVS3"
Local cDocSDB  := ""
cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 , "
cQuery += "       VS3.R_E_C_N_O_ AS RECVS3 , "
cQuery += "       VS3.VS3_ARMORI           , "
cQuery += "       VS3.VS3_QTDINI           , "
cQuery += "       VS3.VS3_NUMLOT           , "
cQuery += "       VS3.VS3_LOTECT             "
cQuery += "  FROM "+RetSQLName("VS3")+" VS3"
cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
cQuery += "       ON  SB1.B1_FILIAL='"+xFilial("SB1")+"'"
cQuery += "       AND SB1.B1_GRUPO=VS3.VS3_GRUITE"
cQuery += "       AND SB1.B1_CODITE=VS3.VS3_CODITE"
cQuery += "       AND SB1.D_E_L_E_T_=' '"
cQuery += " WHERE VS3.VS3_FILIAL = '"+xFilial("VS3")+"'"
cQuery += "   AND VS3.VS3_NUMORC = '"+VS1->VS1_NUMORC+"'"
cQuery += "   AND VS3.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS3 , .F., .T. )
While !( cQAlVS3 )->( Eof() )
	SB1->(DbGoTo(( cQAlVS3 )->( RECSB1 )))
	cDocSDB := oEstoq:TransfereLote(	SB1->B1_COD                 ,;
										( cQAlVS3 )->( VS3_ARMORI ) ,; 
										cArmDest                    ,;
										( cQAlVS3 )->( VS3_QTDINI ) ,;
										( cQAlVS3 )->( VS3_NUMLOT ) ,; 
										( cQAlVS3 )->( VS3_LOTECT ) )
	If Empty(cDocSDB) .or. cDocSDB == "ERRO"
		Help(NIL, NIL, "MATA297M7_Reservar_Itens", NIL, STR0185, 1, 0, NIL, NIL, NIL, NIL, NIL,;
														{STR0186+" "+SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" "+Alltrim(SB1->B1_DESC)})
		lRet := .f. // Erro
		Exit
	Else
		DbSelectArea("VS3")
		DbGoTo(( cQAlVS3 )->( RECVS3 ))
		RecLock("VS3",.f.)
			VS3->VS3_DOCSDB := cDocSDB // Codigo do SD3 - Movimentacao
			VS3->VS3_QTDRES := VS3->VS3_QTDINI
			VS3->VS3_RESERV := "1" // Reservado
		MsUnLock()
		OX001VE6(VS1->VS1_NUMORC,.t.) // Gravar VE6
	EndIf
	( cQAlVS3 )->( DbSkip() )
EndDo
( cQAlVS3 )->( DbCloseArea() )
dbSelectArea("VS1")
If lRet
	RecLock("VS1",.f.)
	VS1->VS1_RESERV := "1" // Reservado
	VS1->(MsUnLock())
EndIf
Return lRet