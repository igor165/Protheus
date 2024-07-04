#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
#Include "OFIOC523.CH"

#DEFINE MVC_STRUCT_ID        01 // Id do Field
#DEFINE MVC_STRUCT_ORDEM     02 // Ordem
#DEFINE MVC_STRUCT_TITULO    03 // Titulo do campo
#DEFINE MVC_STRUCT_DESCRICAO 04 // Descricao do campo
#DEFINE MVC_STRUCT_TIPO      05 // Tipo do campo
#DEFINE MVC_STRUCT_TAM       06 // Tamanho do campo
#DEFINE MVC_STRUCT_DEC       07 // Decimal do campo
#DEFINE MVC_STRUCT_CBOX      08 // Array	Lista de valores permitido do campo	{}		
#DEFINE MVC_STRUCT_OBRIGAT   09 // Indica se o campo tem preenchimento obrigatório
#DEFINE MVC_STRUCT_VIRTUAL   10 // Indica se o campo é virtual
#DEFINE MVC_STRUCT_PICTURE   11 // Picture
#DEFINE MVC_STRUCT_F3        12 // Consulta F3
#DEFINE MVC_STRUCT_ALTER     13 // Indica se o campo é alteravel
#DEFINE MVC_STRUCT_PASTA     14 // Pasta do campo
#DEFINE MVC_STRUCT_AGRP      15 // Agrupamento do campo

Function OFIOC523(lNoMBrowse)

Local cBkpFilial := cFilAnt
Local aArea := sGetArea(,"SB1")
Local bBlock

Default lNoMBrowse := .f.

Private cCadastro := STR0001
Private aRotina := MenuDef()

//AADD(aRegs,{STR0004,STR0004,STR0004,'MV_CH1','N',3,0,,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})

dbSelectArea("SB1")
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	SetKey(VK_F12,{ || Pergunte( "OFIOC523" , .T. ,,,,.f.)})
	mBrowse( 6, 1,22,75,"SB1")
	SetKey( VK_F12, Nil )
EndIf
//

sRestArea(aArea)
cFilAnt := cBkpFilial

//MsgInfo("OFIOC523 - " + cFilAnt)

Return


Function OC523Visual(cAlias,nReg,nOpc)

Local aCpoRegistro := {}

Local cPictQtd := PesqPict("SD1","D1_QUANT")
Local cPictVlr := PesqPict("SD1","D1_VUNIT")
Local cPictTot := PesqPict("SD1","D1_TOTAL")

Private oSizePrinc
Private oSizeFiltro

Private oDlg523
Private obC523EncFiltro
Private obC523Vendas

Private a523FldFiltro

Static oC523Peca := MIL_PecaDao():New()
oC523Peca:SetGrupo(SB1->B1_GRUPO)
oC523Peca:SetCodigo(SB1->B1_CODITE)

// Calcula Coordenadas dos objetos
OC523CalcSize()

DEFINE MSDIALOG oDlg523 TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

aCampos := { ;
		{ "B1_GRUPO"  , "" , .t. },;
		{ "B1_CODITE" , "" , .t. },;
		{ "B1_DESC"   , "" , .t. },;
		{ "C523PARFIL", "" , .f. },;
		{ "C523DTINI" , "" , .f. },;
		{ "C523DTFIM" , "" , .f. },;
		{ "C523CLIENT", "" , .f. },;
		{ "C523LOJA"  , "" , .f. }}

aCpoRegistro := {}
OC520AddField(aCampos, @a523FldFiltro, "OC523Field" )
aEval(a523FldFiltro,{ |x| &("M->" + x[2]) := OC523AtVal(x) , AADD( aCpoRegistro , x[2] ) })

obC523EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
	oSizeFiltro:GetObjectArea("FILTRO"), ;
	aClone(aCpoRegistro), 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg523 , .t. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
	aClone(a523FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)
	
TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 2, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 2 ,;
	STR0005, oDlg523 , { || OC523Atu() }, 040, 010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Atualizar

// ------------------------------------- //
// Criacao do Listbox das NF's de Compra //
// ------------------------------------- //
obC523Vendas := TWBrowse():New( ;
	oSizePrinc:GetDimension("VENDAS","LININI"),;
	oSizePrinc:GetDimension("VENDAS","COLINI"),;
	oSizePrinc:GetDimension("VENDAS","XSIZE"), ;
	oSizePrinc:GetDimension("VENDAS","YSIZE") ,,,,oDlg523,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
obC523Vendas:AddColumn( TCColumn():New( STR0006, { || obC523Vendas:aArray[obC523Vendas:nAT,1] } ,,,,"LEFT"   ,040,.F.,.F.,,,,.F.,) ) // Data
obC523Vendas:AddColumn( TCColumn():New( STR0007, { || obC523Vendas:aArray[obC523Vendas:nAT,2] } ,,,,"LEFT"   ,020,.F.,.F.,,,,.F.,) ) // Filial
obC523Vendas:AddColumn( TCColumn():New( STR0008, { || obC523Vendas:aArray[obC523Vendas:nAT,3] } ,,,,"LEFT"   ,030,.F.,.F.,,,,.F.,) ) // Série
obC523Vendas:AddColumn( TCColumn():New( STR0009, { || obC523Vendas:aArray[obC523Vendas:nAT,4] } ,,,,"LEFT"   ,080,.F.,.F.,,,,.F.,) ) // Documento
obC523Vendas:AddColumn( TCColumn():New( STR0010, { || obC523Vendas:aArray[obC523Vendas:nAT,5] } ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // Cliente
obC523Vendas:AddColumn( TCColumn():New( STR0011, { || obC523Vendas:aArray[obC523Vendas:nAT,6] } ,,,,"LEFT"   ,020,.F.,.F.,,,,.F.,) ) // Loja
obC523Vendas:AddColumn( TCColumn():New( STR0012, { || obC523Vendas:aArray[obC523Vendas:nAT,7] } ,,,,"LEFT"   ,080,.F.,.F.,,,,.F.,) ) // Nome
obC523Vendas:AddColumn( TCColumn():New( STR0013, { || Transform(obC523Vendas:aArray[obC523Vendas:nAT,8] , cPictQtd ) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // Quant.
obC523Vendas:AddColumn( TCColumn():New( STR0014, { || Transform(obC523Vendas:aArray[obC523Vendas:nAT,9] , cPictVlr ) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // Vl. Unitário
obC523Vendas:AddColumn( TCColumn():New( STR0015, { || Transform(obC523Vendas:aArray[obC523Vendas:nAT,10], cPictTot ) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // Total
obC523Vendas:nAt := 1
obC523Vendas:bLDblClick := { || OC523NFSai( ;
										obC523Vendas:aArray[obC523Vendas:nAT,4],;
										obC523Vendas:aArray[obC523Vendas:nAT,3],;
										obC523Vendas:aArray[obC523Vendas:nAT,5],;
										obC523Vendas:aArray[obC523Vendas:nAT,6] ) }
obC523Vendas:SetArray({})

// Atualiza Controles ...
OC523Atu()
//

ACTIVATE MSDIALOG oDlg523 ON INIT EnchoiceBar(oDlg523,{||oDlg523:End()},{||oDlg523:End()})

Return


Function OC523Field(cField)

Local aRetorno := Array(16)

aRetorno[MVC_STRUCT_ID       ] := cField
aRetorno[MVC_STRUCT_DEC      ] := 0
aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
aRetorno[MVC_STRUCT_ALTER    ] := .F.

Do Case
Case cField == "C523PARFIL"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0007 // Filial
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0007 // Filial
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
	aRetorno[MVC_STRUCT_CBOX     ] := OC520RetFil(.t.)
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C523DTINI"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0016 // Dt.Inicial
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0017 // Data Inicial
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C523DTFIM"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0018 // Dt.Final
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0019 // Data Final
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C523CLIENT"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0010 //"Cliente" 
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0010 //"Cliente" 
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := TamSX3("D2_CLIENTE")[1]
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.
	aRetorno[MVC_STRUCT_F3	     ] := "SA1"

Case cField == "C523LOJA"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0011 //"Loja" 
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0011 //"Loja" 
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := TamSX3("D2_LOJA")[1]
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

EndCase

Return aRetorno


Static Function OC523AtVal(aAuxField)

Local xValue

Do Case
Case aAuxField[2] == "C523PARFIL"
	xValue := FWArrFilAtu()[SM0_CODFIL]
Case aAuxField[2] == "C523DTINI"
	Pergunte( "OFIOC523",.F.,,,,.f.)
	xValue := oC523Peca:GetUltVenda() - MV_PAR01
Case aAuxField[2] == "C523DTFIM"
	xValue := oC523Peca:GetUltVenda()
Case Left(aAuxField[2],3) == "B1_"
	xValue := &("SB1->" + AllTrim(aAuxField[2]))
Case aAuxField[2] == "C523CLIENT"
	xValue := Space(TamSX3("D2_CLIENTE")[1]) 
Case aAuxField[2] == "C523LOJA"
	xValue := Space(TamSX3("D2_LOJA")[1])			
EndCase

If xValue <> NIL
	&("M->"+aAuxField[2]) := xValue
EndIf

Return xValue

Static Function OC523Atu()
Local cBkpFilial := cFilAnt
Local cSQL
Local cAuxAlias := "TOC523"
Local aVendas := {}               
Local oSqlHlp := DMS_SqlHelper():New()
Local nCont   := 0
Local aFilAtu := FWArrFilAtu()
Local aSM0    := {}
Local nTotQtd := 0
Local nTotVlr := 0

// Ajusta a cFilAnt
If Empty(M->C523PARFIL)
	// Filial vazia
	MsgAlert(STR0020, STR0021) // Favor selecionar uma Filial! / Atenção

	Return
ElseIf M->C523PARFIL <> STR0022 // TODAS
	// Filtrar por uma filial
	//aSM0 := M->C523PARFIL
	AADD(aSM0, M->C523PARFIL)
Else
	// Todas as filiais
	aSM0 := FWAllFilial(aFilAtu[3], aFilAtu[4], aFilAtu[1], .f.)
EndIf

// Total
AADD(aVendas, { STR0023 , "" , "" , "" , "" , "" , "" , 0 , 0 , 0 })

For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]

	cSQL := "SELECT D2.D2_EMISSAO, D2.D2_FILIAL, D2.D2_SERIE, D2.D2_DOC, D2.D2_CLIENTE, D2.D2_LOJA, A1.A1_NOME, D2.D2_QUANT, D2.D2_PRCVEN, D2.D2_TOTAL "
	cSQL +=  " FROM " + oSqlHlp:NoLock("SD2"," D2") + " "
	cSQL +=  " JOIN " + oSqlHlp:NoLock("SF4"," F4") + " ON F4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4.F4_CODIGO  = D2.D2_TES AND F4.D_E_L_E_T_ = ' ' "
	cSQL +=         " AND F4.F4_OPEMOV = '05'" // Somente TES de VENDA
	cSQL +=  " JOIN " + oSqlHlp:NoLock("SA1"," A1") + " ON A1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1.A1_COD = D2.D2_CLIENTE AND A1.A1_LOJA = D2.D2_LOJA AND A1.D_E_L_E_T_ = ' '"
	cSQL += " WHERE D2.D2_FILIAL  = '" + xFilial("SD2") + "'"
	cSQL +=   " AND D2.D2_COD     = '" + SB1->B1_COD + "'"
	cSQL +=   " AND D2.D2_EMISSAO BETWEEN '" + DtoS(M->C523DTINI) + "' AND '" + DtoS(M->C523DTFIM) + "'"

	If !Empty(M->C523CLIENT) 
		cSQL +=	" AND D2.D2_CLIENTE = '" +M->C523CLIENT + "'" 
	EndIf

	If !Empty(M->C523LOJA)
		cSQL +=	" AND D2.D2_LOJA = '"+M->C523LOJA+"'"
	EndIf

	cSQL +=   " AND D2.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY D2_NUMSEQ"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )

	While !(cAuxAlias)->(Eof())
		AADD(aVendas, { StoD( (cAuxAlias)->D2_EMISSAO), ;
								(cAuxAlias)->D2_FILIAL, ;
								(cAuxAlias)->D2_SERIE,  ;
								(cAuxAlias)->D2_DOC,    ;
								(cAuxAlias)->D2_CLIENTE,;
								(cAuxAlias)->D2_LOJA,   ;
								(cAuxAlias)->A1_NOME,   ;
								(cAuxAlias)->D2_QUANT,  ;
								(cAuxAlias)->D2_PRCVEN, ;
								(cAuxAlias)->D2_TOTAL })

		// Totais
		nTotQtd += (cAuxAlias)->D2_QUANT
		nTotVlr += (cAuxAlias)->D2_TOTAL

		(cAuxAlias)->(dbSkip())
	EndDo

	(cAuxAlias)->(dbCloseArea())
Next

// Totais
aVendas[1,8]  := nTotQtd
aVendas[1,10] := nTotVlr

dbSelectArea("SD2")

obC523Vendas:nAt := 1
obC523Vendas:SetArray(aVendas)
obC523Vendas:Refresh()

cFilAnt := cBkpFilial
Return

Static Function OC523NFSai( cDoc, cSerie, cCliente, cLoja )

Local aArea := GetArea()

dbSelectArea("SF2")
SF2->(dbSetOrder(1))
If !Empty(cDoc) .and. SF2->(dbSeek( xFilial("SF2") + cDoc + cSerie + cCliente + cLoja ))
	Mc090Visual("SF2",SF2->(RecNo()),1)
Else
	MsgInfo(STR0024) // Nota fiscal de saída não encontrada.
EndIf

RestArea(aArea)

Return


Static Function OC523CalcSize()

oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
oSizePrinc:AddObject("SUP" , 100 , 080 , .T. , .F. )
oSizePrinc:AddObject("VENDAS" , 100 , 100 , .T. , .T. )
oSizePrinc:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizePrinc:Process()	// Calcula Coordenadas

oSizeFiltro := FWDefSize():New(.f.)
oSizeFiltro:aWorkArea := oSizePrinc:GetNextCallArea("SUP")
oSizeFiltro:aMargins := { 2 , 2 , 2 , 2 }
oSizeFiltro:AddObject("FILTRO"      ,100,100,.t.,.t.)
oSizeFiltro:AddObject("BTN_ATUALIZA",045,100,.f.,.t.)
oSizeFiltro:lLateral := .t.	// Calcula em colunas
oSizeFiltro:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
oSizeFiltro:Process()

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | MenuDef    | Autor | Takahashi             | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Definicao de Menu                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function MenuDef()

Local aRotina:= {;
	{ STR0002 , "PesqBrw"   , 0 , 1},; // Pesquisar
	{ STR0003 , "OC523Visual"  , 0 , 2} } // Visualizar
Return aRotina