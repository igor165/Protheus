#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
#Include "OFIOC525.CH"

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

Function OFIOC525(lNoMBrowse)

Local cBkpFilial := cFilAnt
Local aArea := sGetArea(,"SB1")

Local bBlock

Default lNoMBrowse := .f.

Private cCadastro := STR0001
Private aRotina := MenuDef()

//AADD(aRegs,{STR0004,STR0004,STR0004,'MV_CH1','N', 4,0,,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
//AADD(aRegs,{STR0005,STR0005,STR0005,'MV_CH2','C',50,0,,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})

dbSelectArea("SB1")
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	SetKey(VK_F12,{ || Pergunte( "OFIOC525" , .T. ,,,,.f.)})
	mBrowse( 6, 1,22,75,"SB1")
	SetKey( VK_F12, Nil )
EndIf
//

sRestArea(aArea)
cFilAnt := cBkpFilial

Return


Function OC525Visual(cAlias,nReg,nOpc)

Local aCpoRegistro := {}
Local cPictQtd := PesqPict("SC7","C7_QUANT")

Private oSizePrinc
Private oSizeFiltro

Private oDlg525
Private obC525EncFiltro
Private obC525Pedidos

Private a525FldFiltro

Static oC525Peca := MIL_PecaDao():New()
oC525Peca:SetGrupo(SB1->B1_GRUPO)
oC525Peca:SetCodigo(SB1->B1_CODITE)

// Calcula Coordenadas dos objetos
OC525CalcSize()

DEFINE MSDIALOG oDlg525 TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

aCampos := { ;
		{ "B1_GRUPO"   , "" , .t. },;
		{ "B1_CODITE"  , "" , .t. },;
		{ "B1_DESC"    , "" , .t. },;
		{ "C525PARFIL" , "" , .f. },;
		{ "C525DTINI"  , "" , .f. },;
		{ "C525DTFIM"  , "" , .f. },;
		{ "C525TPPEDN" , "" , .f. }}

aCpoRegistro := {}
OC520AddField(aCampos, @a525FldFiltro, "OC525Field" )
aEval(a525FldFiltro,{ |x| &("M->" + x[2]) := OC525AtVal(x) , AADD( aCpoRegistro , x[2] ) })

obC525EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
	oSizeFiltro:GetObjectArea("FILTRO"), ;
	aClone(aCpoRegistro), 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg525 , .t. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
	aClone(a525FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)
	
TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 2, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 2 ,;
	"Atualizar", oDlg525 , { || OC525Atu() }, 040, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

// ------------------------------------- //
// Criacao do Listbox das NF's de Compra //
// ------------------------------------- //
obC525Pedidos := TWBrowse():New( ;
	oSizePrinc:GetDimension("PEDIDOS","LININI"),;
	oSizePrinc:GetDimension("PEDIDOS","COLINI"),;
	oSizePrinc:GetDimension("PEDIDOS","XSIZE"), ;
	oSizePrinc:GetDimension("PEDIDOS","YSIZE") ,,,,oDlg525,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//
obC525Pedidos:AddColumn( TCColumn():New( STR0012 , { || obC525Pedidos:aArray[obC525Pedidos:nAT,1] } ,,,,"LEFT"   ,040,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0013 , { || obC525Pedidos:aArray[obC525Pedidos:nAT,2] } ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0014 , { || obC525Pedidos:aArray[obC525Pedidos:nAT,3] } ,,,,"LEFT"   ,050,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0015 , { || obC525Pedidos:aArray[obC525Pedidos:nAT,4] } ,,,,"LEFT"   ,040,.F.,.F.,,,,.F.,) ) // 
//
obC525Pedidos:AddColumn( TCColumn():New( STR0016 , { || Transform(obC525Pedidos:aArray[obC525Pedidos:nAT,5], cPictQtd) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0017 , { || Transform(obC525Pedidos:aArray[obC525Pedidos:nAT,6], cPictQtd) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0018 , { || Transform(obC525Pedidos:aArray[obC525Pedidos:nAT,7], cPictQtd) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0019 , { || Transform(obC525Pedidos:aArray[obC525Pedidos:nAT,8], cPictQtd) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
//
obC525Pedidos:AddColumn( TCColumn():New( STR0020 , { || Transform(obC525Pedidos:aArray[obC525Pedidos:nAT,9], PesqPict("SC7","C7_PRECO")) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0021 , { || Transform(obC525Pedidos:aArray[obC525Pedidos:nAT,10], PesqPict("SC7","C7_TOTAL")) } ,,,,"RIGHT"  ,050,.F.,.F.,,,,.F.,) ) // 
//
obC525Pedidos:AddColumn( TCColumn():New( STR0022 , { || obC525Pedidos:aArray[obC525Pedidos:nAT,11] } ,,,,"LEFT"   ,035,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0023 , { || obC525Pedidos:aArray[obC525Pedidos:nAT,12] } ,,,,"LEFT"   ,020,.F.,.F.,,,,.F.,) ) // 
obC525Pedidos:AddColumn( TCColumn():New( STR0024 , { || obC525Pedidos:aArray[obC525Pedidos:nAT,13] } ,,,,"LEFT"   ,120,.F.,.F.,,,,.F.,) ) // 
//
obC525Pedidos:nAt := 1
obC525Pedidos:bLDblClick := { || OC525Pedido( obC525Pedidos:aArray[obC525Pedidos:nAT,14] ) }
obC525Pedidos:SetArray({})

// Atualiza Controles ...
OC525Atu()
//

ACTIVATE MSDIALOG oDlg525 ON INIT EnchoiceBar(oDlg525,{||oDlg525:End()},{||oDlg525:End()})

Return


Function OC525Field(cField)

Local aRetorno := Array(16)

aRetorno[MVC_STRUCT_ID       ] := cField
aRetorno[MVC_STRUCT_DEC      ] := 0
aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
aRetorno[MVC_STRUCT_ALTER    ] := .F.

Do Case
Case cField == "C525PARFIL"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0007 // Filial
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0007 // Filial
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
	aRetorno[MVC_STRUCT_CBOX     ] := OC520RetFil()
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C525DTINI"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0008 // Dt.Inicial
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0009 // Data Inicial
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C525DTFIM"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0010 // Dt.Final
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0011 // Data Final
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C525TPPEDN"
	aRetorno[MVC_STRUCT_TITULO   ] := STR0006 // Tp.Ped.Desc.
	aRetorno[MVC_STRUCT_DESCRICAO] := STR0005 // Tp.Ped.Desconsiderar
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 50
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

EndCase

Return aRetorno


Static Function OC525AtVal(aAuxField)

Local xValue

Do Case
Case aAuxField[2] == "C525PARFIL"
	xValue := FWArrFilAtu()[SM0_CODFIL]
Case aAuxField[2] == "C525DTINI"
	Pergunte( "OFIOC525",.F.,,,,.f.)
	xValue := dDataBase - MV_PAR01
Case aAuxField[2] == "C525DTFIM"
	xValue := dDataBase
Case aAuxField[2] == "C525TPPEDN"
	Pergunte( "OFIOC525",.F.,,,,.f.)
	xValue := MV_PAR02
Case Left(aAuxField[2],3) == "B1_"
	xValue := &("SB1->" + AllTrim(aAuxField[2]))	
EndCase

If xValue <> NIL
	&("M->"+aAuxField[2]) := xValue
EndIf

Return xValue

Static Function OC525Atu()
Local cSQL
Local cAuxAlias  := "TOC525"
Local aPedidos   := {}
Local cAux       := ""
Local lC7_PEDFAB := SC7->(FieldPos("C7_PEDFAB")) > 0
Local lC7_TIPPED := SC7->(FieldPos("C7_TIPPED")) > 0
Local oSqlHlp := DMS_SqlHelper():New()

If Empty(M->C525PARFIL)
	MsgAlert("Favor selecionar uma Filial!","Atenção")
	Return()
EndIf

// Ajusta a cFilAnt ...
cFilAnt := M->C525PARFIL

cSQL := "SELECT SC7.C7_EMISSAO , SC7.C7_NUM , "
cSQL += "SC7.C7_QUANT , SC7.C7_QUJE , SC7.C7_RESIDUO , SC7.C7_PRECO , SC7.C7_TOTAL , "
cSQL += "SC7.C7_FORNECE , SC7.C7_LOJA , SA2.A2_NOME , SC7.R_E_C_N_O_ RECSC7 "

If lC7_TIPPED
	cSQL += " , SC7.C7_TIPPED "
Endif

If lC7_PEDFAB
	cSQL += " , SC7.C7_PEDFAB "
EndIf

cSQL +=  " FROM " + oSqlHlp:NoLock("SC7") + " "
cSQL +=  " LEFT JOIN " + oSqlHlp:NoLock("SA2") + " ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD=SC7.C7_FORNECE AND SA2.A2_LOJA=SC7.C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cSQL += " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'"
cSQL +=   " AND SC7.C7_PRODUTO = '" + SB1->B1_COD + "'"
cSQL +=   " AND SC7.C7_EMISSAO BETWEEN '" + DtoS(M->C525DTINI) + "' AND '" + DtoS(M->C525DTFIM) + "'"
If lC7_TIPPED .And. !Empty(M->C525TPPEDN)
	cAux := Alltrim(M->C525TPPEDN)
	If len(cAux) > 1 .and. right(cAux,1) == "/"
		cAux := left(cAux,len(cAux)-1)
	EndIf
	cSQL += " AND SC7.C7_TIPPED NOT IN " + FormatIN(cAux,"/")
EndIf
cSQL +=   " AND SC7.D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	AADD(aPedidos, { StoD( (cAuxAlias)->C7_EMISSAO),;
							(cAuxAlias)->C7_NUM,;
							If(lC7_PEDFAB,(cAuxAlias)->C7_PEDFAB,""),;
							If(lC7_TIPPED,(cAuxAlias)->C7_TIPPED,""),;
							(cAuxAlias)->C7_QUANT,;
							(cAuxAlias)->C7_QUJE,;
							IIf((cAuxAlias)->C7_RESIDUO<>'S',(cAuxAlias)->C7_QUANT-(cAuxAlias)->C7_QUJE,0),;
							IIf((cAuxAlias)->C7_RESIDUO=='S',(cAuxAlias)->C7_QUANT-(cAuxAlias)->C7_QUJE,0),;
							(cAuxAlias)->C7_PRECO,;
							(cAuxAlias)->C7_TOTAL,;
							(cAuxAlias)->C7_FORNECE,;
							(cAuxAlias)->C7_LOJA,;
							(cAuxAlias)->A2_NOME,;
							(cAuxAlias)->RECSC7 })
	(cAuxAlias)->(dbSkip())
End
(cAuxAlias)->(dbCloseArea())

If Len(aPedidos) <= 0
	AADD(aPedidos, { ctod("") , "" , "" , "" , 0 , 0 , 0 , 0 , 0 , 0 , "" , "" , "" , 0 })
EndIf

dbSelectArea("SC7")

obC525Pedidos:nAt := 1
obC525Pedidos:SetArray(aPedidos)
obC525Pedidos:Refresh()

Return

Static Function OC525Pedido( nRecSC7 )

Local aBKPRotina := aClone(aRotina)
Local aArea      := GetArea()
Private l120Auto := .F. //-- Variavel utilizada pelo MATA120
Private nTipoPed := 1   //-- Variavel utilizada pelo MATA120
dbSelectArea("SC7")
If nRecSC7 > 0
	dbGoTo(nRecSC7)
	INCLUI := .F.
	ALTERA := .F.
	aRotina := {}
	AAdd( aRotina, { '' , '' , 0, 1 } )
	AAdd( aRotina, { '' , '' , 0, 2 } )
	AAdd( aRotina, { '' , '' , 0, 3 } )
	AAdd( aRotina, { '' , '' , 0, 4 } )
	AAdd( aRotina, { '' , '' , 0, 5 } )
	A120Pedido( 'SC7', SC7->( Recno() ), 2 ) // Visualizacao do Pedido de Compra
Else
	MsgInfo("Pedido não encontrado.")
EndIf
aRotina := aClone(aBKPRotina)

RestArea(aArea)

Return


Static Function OC525CalcSize()

oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
oSizePrinc:AddObject("SUP" , 100 , 90 , .T. , .F. )
oSizePrinc:AddObject("PEDIDOS" , 100 , 100 , .T. , .T. )
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
	{ STR0003 , "OC525Visual"  , 0 , 2} } // Visualizar
Return aRotina