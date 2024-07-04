#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
//#Include "OFIOC522.CH"

#DEFINE STR0001 "Movimento de Compras"
#DEFINE STR0002 "Pesquisar"
#DEFINE STR0003 "Visualizar"
#DEFINE STR0004 "Dias"

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


Function OFIOC522(lNoMBrowse,xParam)

Local cBkpFilial := cFilAnt
Local aBkpArea := sGetArea(,"SB1")
//Local aRegs := {}
Local bBlock

Default lNoMBrowse := .f.
Default xParam := {}

Private cCadastro := STR0001
Private aRotina := MenuDef()
Private aAutoParam

//AADD(aRegs,{STR0004,STR0004,STR0004,'MV_CH1','N',3,0,,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})

dbSelectArea("SB1")
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		aAutoParam := xParam
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	SetKey(VK_F12,{ || Pergunte( "OFIOC522" , .T. ,,,,.f.)})
	mBrowse( 6, 1,22,75,"SB1")
	SetKey( VK_F12, Nil )	
EndIf
//

SetKey( VK_F12, Nil )
sRestArea(aBkpArea)
cFilAnt := cBkpFilial

//MsgInfo("OFIOC523 - " + cFilAnt)

Return


Function OC522Visual(cAlias,nReg,nOpc)

Local aCpoRegistro := {}

Local cPictQtd := PesqPict("SD1","D1_QUANT")
Local cPictVlr := PesqPict("SD1","D1_VUNIT")
Local cPictTot := PesqPict("SD1","D1_TOTAL")

Private oSizePrinc
Private oSizeFiltro

Private oDlg522
Private obC522EncFiltro
Private obC522Compras

Private a522FldFiltro

Static oC522Peca := MIL_PecaDao():New()
oC522Peca:SetGrupo(SB1->B1_GRUPO)
oC522Peca:SetCodigo(SB1->B1_CODITE)


// Calcula Coordenadas dos objetos
OC522CalcSize()

DEFINE MSDIALOG oDlg522 TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

aCampos := { ;
		{ "B1_GRUPO"   , "" , .t. },;
		{ "B1_CODITE"  , "" , .t. },;
		{ "B1_DESC"    , "" , .t. },;
		{ "C522PARFIL" , "" , .f. },;
		{ "C522DTINI"  , "" , .f. },;
		{ "C522DTFIM"  , "" , .f. } }

aCpoRegistro := {}
OC520AddField(aCampos, @a522FldFiltro, "OC522Field" )
aEval(a522FldFiltro,{ |x| &("M->" + x[2]) := OC522AtVal(x) , AADD( aCpoRegistro , x[2] ) })

obC522EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
	oSizeFiltro:GetObjectArea("FILTRO"), ;
	aClone(aCpoRegistro), 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg522 , .t. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
	aClone(a522FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)
	
TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 2, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 2 ,;
	"Atualizar", oDlg522 , { || OC522Atu() }, 040, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

// ------------------------------------- //
// Criacao do Listbox das NF's de Compra //
// ------------------------------------- //
obC522Compras := TWBrowse():New( ;
	oSizePrinc:GetDimension("COMPRAS","LININI"),;
	oSizePrinc:GetDimension("COMPRAS","COLINI"),;
	oSizePrinc:GetDimension("COMPRAS","XSIZE"), ;
	oSizePrinc:GetDimension("COMPRAS","YSIZE") ,,,,oDlg522,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
obC522Compras:AddColumn( TCColumn():New( "Data"         , { || obC522Compras:aArray[obC522Compras:nAT,1] } ,,,,"LEFT"   ,040,.F.,.F.,,,,.F.,) ) // 
obC522Compras:AddColumn( TCColumn():New( "Série"        , { || obC522Compras:aArray[obC522Compras:nAT,2] } ,,,,"LEFT"   ,030,.F.,.F.,,,,.F.,) ) // 
obC522Compras:AddColumn( TCColumn():New( "Documento"    , { || obC522Compras:aArray[obC522Compras:nAT,3] } ,,,,"LEFT"   ,080,.F.,.F.,,,,.F.,) ) // 
obC522Compras:AddColumn( TCColumn():New( "Fornecedor"   , { || obC522Compras:aArray[obC522Compras:nAT,4] } ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // 
obC522Compras:AddColumn( TCColumn():New( "Loja"         , { || obC522Compras:aArray[obC522Compras:nAT,5] } ,,,,"LEFT"   ,020,.F.,.F.,,,,.F.,) ) // 
obC522Compras:AddColumn( TCColumn():New( "Nome"         , { || obC522Compras:aArray[obC522Compras:nAT,6] } ,,,,"LEFT"   ,080,.F.,.F.,,,,.F.,) ) // 
obC522Compras:AddColumn( TCColumn():New( "Quant."       , { || Transform(obC522Compras:aArray[obC522Compras:nAT,7], cPictQtd ) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
obC522Compras:AddColumn( TCColumn():New( "Vl. Unitário" , { || Transform(obC522Compras:aArray[obC522Compras:nAT,8], cPictVlr ) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
obC522Compras:AddColumn( TCColumn():New( "Total"        , { || Transform(obC522Compras:aArray[obC522Compras:nAT,9], cPictTot ) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
obC522Compras:nAt := 1
obC522Compras:bLDblClick := { || OC522NFEnt( ;
										obC522Compras:aArray[obC522Compras:nAT,3],;
										obC522Compras:aArray[obC522Compras:nAT,2],;
										obC522Compras:aArray[obC522Compras:nAT,4],;
										obC522Compras:aArray[obC522Compras:nAT,5] ) }
obC522Compras:SetArray({})

// Atualiza Controles ...
OC522Atu()
//

ACTIVATE MSDIALOG oDlg522 ON INIT EnchoiceBar(oDlg522,{||oDlg522:End()},{||oDlg522:End()})

Return


Function OC522Field(cField)

Local aRetorno := Array(16)

aRetorno[MVC_STRUCT_ID       ] := cField
aRetorno[MVC_STRUCT_DEC      ] := 0
aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
aRetorno[MVC_STRUCT_ALTER    ] := .F.

Do Case
Case cField == "C522PARFIL"
	aRetorno[MVC_STRUCT_TITULO   ] := "Filial"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Filial"
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
	aRetorno[MVC_STRUCT_CBOX     ] := OC520RetFil()
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C522DTINI"
	aRetorno[MVC_STRUCT_TITULO   ] := "Dt.Inicial"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Data Inicial"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C522DTFIM"
	aRetorno[MVC_STRUCT_TITULO   ] := "Dt.Final"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Data Final"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

EndCase

Return aRetorno


Static Function OC522AtVal(aAuxField)

Local xValue
Local nPos

If (nPos := aScan(aAutoParam,{ |x| x[1] == aAuxField[2] })) <> 0
	xValue := aAutoParam[nPos,2]
Else
	Do Case
	Case aAuxField[2] == "C522PARFIL"
		xValue := FWArrFilAtu()[SM0_CODFIL]
	Case aAuxField[2] == "C522DTINI"
		Pergunte( "OFIOC522",.F.,,,,.f.)	
		xValue := oC522Peca:GetUltCompra() - MV_PAR01
	Case aAuxField[2] == "C522DTFIM"
		xValue := oC522Peca:GetUltCompra()
	Case Left(aAuxField[2],3) == "B1_"
		xValue := &("SB1->" + AllTrim(aAuxField[2]))	
	EndCase
EndIf

If xValue <> NIL
	&("M->"+aAuxField[2]) := xValue
EndIf

Return xValue

Static Function OC522Atu()

Local cSQL
Local cAuxAlias := "TOC522"
Local aCompras := {}
Local oSqlHlp := DMS_SqlHelper():New()

If Empty(M->C522PARFIL)
	MsgAlert("Favor selecionar uma Filial!","Atenção")
	Return()
EndIf

// Ajusta a cFilAnt ...
cFilAnt := M->C522PARFIL

cSQL := "SELECT D1.D1_DTDIGIT, D1.D1_SERIE, D1.D1_DOC, D1.D1_FORNECE, D1.D1_LOJA, A2.A2_NOME, D1.D1_QUANT, D1.D1_VUNIT, D1.D1_TOTAL, D1.R_E_C_N_O_ D1RECNO"
cSQL +=  " FROM " + oSqlHlp:NoLock("SD1"," D1") + " "
cSQL +=  " JOIN " + oSqlHlp:NoLock("SF4"," F4") + " ON F4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4.F4_CODIGO  = D1.D1_TES AND F4.D_E_L_E_T_ = ' ' "
cSQL +=         " AND F4.F4_OPEMOV = '01'" // Somente TES de compra 
cSQL +=  " JOIN " + oSqlHlp:NoLock("SA2"," A2") + " ON A2.A2_FILIAL = '" + xFilial("SA2") + "' AND A2.A2_COD = D1.D1_FORNECE AND A2.A2_LOJA = D1.D1_LOJA AND A2.D_E_L_E_T_ = ' '"
cSQL += " WHERE D1.D1_FILIAL  = '" + xFilial("SD1") + "'"
cSQL +=   " AND D1.D1_COD     = '" + SB1->B1_COD + "'"
cSQL +=   " AND D1.D1_DTDIGIT BETWEEN '" + DtoS(M->C522DTINI) + "' AND '" + DtoS(M->C522DTFIM) + "'"
cSQL +=   " AND D1.D_E_L_E_T_ = ' '"
cSQL += " ORDER BY D1_NUMSEQ"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	AADD(aCompras, { StoD( (cAuxAlias)->D1_DTDIGIT),;
							(cAuxAlias)->D1_SERIE,;
							(cAuxAlias)->D1_DOC,;
							(cAuxAlias)->D1_FORNECE,;
							(cAuxAlias)->D1_LOJA,;
							(cAuxAlias)->A2_NOME,;
							(cAuxAlias)->D1_QUANT,;
							(cAuxAlias)->D1_VUNIT,;
							(cAuxAlias)->D1_TOTAL,;
							(cAuxAlias)->D1RECNO })
	(cAuxAlias)->(dbSkip())
End
(cAuxAlias)->(dbCloseArea())

If len(aCompras) <= 0
	AADD(aCompras, { ctod("") , "" , "" , "" , "" , "" , 0 , 0 , 0 , 0 })
EndIf

DbSelectArea("SD1")

obC522Compras:nAt := 1
obC522Compras:SetArray(aCompras)
obC522Compras:Refresh()

Return

Static Function OC522NFEnt( cDoc, cSerie, cFornece, cLoja )

Local aArea := GetArea()

dbSelectArea("SF1")
SF1->(dbSetOrder(1))
If !Empty(cDoc) .and. SF1->(dbSeek( xFilial("SF1") + cDoc + cSerie + cFornece + cLoja ))
	A103NFiscal("SF1",SF1->(RecNo()),2)  
Else
	MsgInfo("Nota fiscal de entrada não encontrada.")
EndIf

RestArea(aArea)

Return


Static Function OC522CalcSize()

oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
oSizePrinc:AddObject("SUP" , 100 , 080 , .T. , .F. )
oSizePrinc:AddObject("COMPRAS" , 100 , 100 , .T. , .T. )
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
	{ STR0003 , "OC522Visual"  , 0 , 2} } // Visualizar
Return aRotina