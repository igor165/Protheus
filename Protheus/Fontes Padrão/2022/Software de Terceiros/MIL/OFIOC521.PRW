#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
//#Include "OFIOC521.CH"

#DEFINE STR0001 "Detalhes de Estoque"
#DEFINE STR0002 "Pesquisar"
#DEFINE STR0003 "Visualizar"

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
#DEFINE MVC_STRUCT_NEWLINE   16 // Pula linha depois do campo

Function OFIOC521(lNoMBrowse,xAutoCab)

Local cBkpFilial   := cFilAnt
Local aBkpArea     := sGetArea(,"SB1")

Default lNoMBrowse := .f.
Default xAutoCab   := {}

Private cCadastro  := STR0001
Private aAutoCab   := xAutoCab
Private aRotina    := MenuDef()

dbSelectArea("SB1")
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	mBrowse( 6, 1,22,75,"SB1")
EndIf
//

SetKey( VK_F12, Nil )
sRestArea(aBkpArea)
cFilAnt := cBkpFilial

Return

Function OC521Visual(cAlias,nReg,nOpc)


Local cPerg := PADR("OFC521",len(SX1->X1_GRUPO))

Local cPictQtd := PesqPict("SB2","B2_QATU")

Private oSizePrinc
Private oSizeFiltro

Private oDlg521
Private obC521EncFiltro
Private obC521EncDetalhe
Private obC521Estq

Private a521FldFiltro  := {}
Private a521FldDetalhe  := {}

//AADD(aRegs,{"Arm.Disponiveis","Arm.Disponiveis","Arm.Disponiveis",'MV_CH1','C',30,0,,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
//AADD(aRegs,{"Arm.Oficina","Arm.Oficina","Arm.Oficina",'MV_CH2','C',30,0,,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
Pergunte(cPerg,.F.,,,,.f.)

DbSelectArea("SB1")
SB1->(dbGoTo(nReg))

Static oC521Peca := MIL_PecaDao():New()
oC521Peca:SetGrupo(SB1->B1_GRUPO)
oC521Peca:SetCodigo(SB1->B1_CODITE)

// Calcula Coordenadas dos objetos
OC521CalcSize()

DEFINE MSDIALOG oDlg521 TITLE STR0001 OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

aCampos := { ;
	{ "B1_GRUPO"    , "" , .t. },;
	{ "B1_CODITE"   , "" , .t. },;
	{ "B1_DESC"     , "" , .t. },;
	{ "C521ESTQT"   , "" , .f. },;
	{ "C521CDTINI"  , "" , .f. },;
	{ "C521CDTFIM"  , "" , .f. },;
	{ "C521VDTINI"  , "" , .f. },;
	{ "C521VDTFIM"  , "" , .f. },;
	{ "C521ARMDIS"  , "" , .f. },;
	{ "C521ARMOFI"  , "" , .f. }}

aCpoRegistro := {}
OC520AddField(aCampos, @a521FldFiltro, "OC521Field" )
aEval(a521FldFiltro,{ |x| &("M->" + x[2]) := OC521AtVal(x) , AADD( aCpoRegistro , x[2] ) })

obC521EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
	oSizeFiltro:GetObjectArea("FILTRO"), ;
	aClone(aCpoRegistro), 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg521 , .t. /*lF3*/, .t. /* lMemoria */ , .f. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
	aClone(a521FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)

TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 2, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") + 2 ,;
	"Atualizar", oDlg521 , { || OC521Atu() }, 040, 010,,,.F.,.T.,.F.,,.F.,,,.F. )

// ------------------- //
// CRIA BOX - ESTOQUE  //
// ------------------- //
obC521Estq := TWBrowse():New( ;
	oSizePrinc:GetDimension("ESTOQUE","LININI"),;
	oSizePrinc:GetDimension("ESTOQUE","COLINI"),;
	oSizePrinc:GetDimension("ESTOQUE","XSIZE"), ;
	oSizePrinc:GetDimension("ESTOQUE","YSIZE") ,,,,oDlg521,,,,{ || OC521CHANGE(obC521Estq:nAT,cPictQtd) },,,,,,,,.F.,,.T.,,.F.,,,)
	
obC521Estq:AddColumn( TCColumn():New( "Filial"         , { || obC521Estq:aArray[obC521Estq:nAT,1] + " - " + obC521Estq:aArray[obC521Estq:nAT,9] } ,,,,"LEFT"   ,(oSizePrinc:GetDimension("ESTOQUE","XSIZE")*0.20),.F.,.F.,,,,.F.,) ) // 
obC521Estq:AddColumn( TCColumn():New( "Disponível"     , { || Transform(obC521Estq:aArray[obC521Estq:nAT,2],cPictQtd) } ,,,,"RIGHT"  ,(oSizePrinc:GetDimension("ESTOQUE","XSIZE")*0.11),.F.,.F.,,,,.F.,) ) // 
obC521Estq:AddColumn( TCColumn():New( "Oficina"        , { || Transform(obC521Estq:aArray[obC521Estq:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizePrinc:GetDimension("ESTOQUE","XSIZE")*0.11),.F.,.F.,,,,.F.,) ) // 
obC521Estq:AddColumn( TCColumn():New( "Outros"         , { || Transform(obC521Estq:aArray[obC521Estq:nAT,4],cPictQtd) } ,,,,"RIGHT"  ,(oSizePrinc:GetDimension("ESTOQUE","XSIZE")*0.11),.F.,.F.,,,,.F.,) ) // 
obC521Estq:AddColumn( TCColumn():New( "Ped. Pendentes" , { || Transform(obC521Estq:aArray[obC521Estq:nAT,5],cPictQtd) } ,,,,"RIGHT"  ,(oSizePrinc:GetDimension("ESTOQUE","XSIZE")*0.11),.F.,.F.,,,,.F.,) ) // 
obC521Estq:AddColumn( TCColumn():New( "Excesso"        , { || Transform(obC521Estq:aArray[obC521Estq:nAT,6],cPictQtd) } ,,,,"RIGHT"  ,(oSizePrinc:GetDimension("ESTOQUE","XSIZE")*0.11),.F.,.F.,,,,.F.,) ) // 
obC521Estq:AddColumn( TCColumn():New( "Qtd.Endereçar"  , { || Transform(obC521Estq:aArray[obC521Estq:nAT,7],cPictQtd) } ,,,,"RIGHT"  ,(oSizePrinc:GetDimension("ESTOQUE","XSIZE")*0.11),.F.,.F.,,,,.F.,) ) // 
obC521Estq:AddColumn( TCColumn():New( "Total"          , { || Transform(obC521Estq:aArray[obC521Estq:nAT,8],cPictQtd) } ,,,,"RIGHT"  ,(oSizePrinc:GetDimension("ESTOQUE","XSIZE")*0.11),.F.,.F.,,,,.F.,) ) // 
obC521Estq:nAt := 1
obC521Estq:SetArray({})

// ----------------------- //
// CRIA Enchoice - Detalhe // 
// ----------------------- //
aCampos := { ;
	{ "C521GIRTOT"	 , "" , .f. },;
	{ "C521ULTPED"	 , "" , .f. },;
	{ "C521ULTPDE"	 , "" , .f. },;
	{ "C521ULTSAI"	 , "" , .f. },;
	{ "C521PEDCOM"   , "" , .f. } }

aCpoRegistro := {}
OC520AddField(aCampos, @a521FldDetalhe, "OC521Field" )
aEval(a521FldDetalhe,{ |x| &("M->" + x[2]) := OC521AtVal(x) , AADD( aCpoRegistro , x[2] ) })

obC521EncDetalhe := MsmGet():New(,,2 /* Visualizar */,;
	/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
	oSizePrinc:GetObjectArea("DETALHE"), ;
	aClone(aCpoRegistro), 3 /*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg521 , .f. /*lF3*/, .t. /* lMemoria */ , .f. /*lColumn*/,;
	/*caTela*/, .t. /*lNoFolder*/, .f. /*lProperty*/,;
	aClone(a521FldDetalhe), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)

// Atualiza Controles ...
OC521Atu()
//

ACTIVATE MSDIALOG oDlg521 ON INIT EnchoiceBar(oDlg521,{||oDlg521:End()},{||oDlg521:End()})

DbSelectArea("SX1")
DbSetOrder(1)
If DbSeek(cPerg+"01") 
	Reclock("SX1",.F.)
	SX1->X1_CNT01 := c521ArmDis
	MsUnlock()
EndIf
If DbSeek(cPerg+"02") 
	Reclock("SX1",.F.)
	SX1->X1_CNT01 := c521ArmOfi
	MsUnlock()
EndIf

Return

Static Function OC521Atu()

Local cBkpFilial  := cFilAnt
Local nCont       := 0
Local lVerExcesso := .f.
Local aAuxEstoque := {}
Local aEstoque    := {}
Local cSQL        := ""
Local nQtd        := 0
Local cArm        := ""
Local nQtdCpa     := 0
Local nQtdVda     := 0   
Local oSqlHlp := DMS_SqlHelper():New()

oC521Peca:SetGrupo(SB1->B1_GRUPO)
oC521Peca:SetCodigo(SB1->B1_CODITE)

// Calcula o saldo do estoque ...
aAuxEstoque := oC521Peca:EstqSaldo(,.t.,.t.)

aEstoque := {}
For nCont := 1 to Len(aAuxEstoque)
	lVerExcesso := .f.
	If (nPos := aScan(aEstoque,{ |x| x[1] == aAuxEstoque[nCont,1] })) == 0
		AADD( aEstoque , { aAuxEstoque[nCont,1] , 0 , 0 , 0 , 0 , 0 , 0 , 0 , aAuxEstoque[nCont,5] } )
		nPos := Len(aEstoque)
		cFilAnt := aAuxEstoque[nCont,1]
		cSQL := "SELECT SUM(SC7.C7_QUANT-SC7.C7_QUJE) "
		cSQL +=  " FROM " + oSqlHlp:NoLock("SC7") + " "
		cSQL += " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "'"
		cSQL +=   " AND SC7.C7_PRODUTO = '" + SB1->B1_COD + "'"
		cSQL +=   " AND SC7.C7_RESIDUO<>'S'"
		cSQL +=   " AND SC7.C7_QUANT>SC7.C7_QUJE"
		cSQL +=   " AND SC7.D_E_L_E_T_ = ' '"
		nQtd := FM_SQL(cSQL)
		aEstoque[nPos,5] := nQtd // Pedido
		aEstoque[nPos,8] := nQtd // Total
		lVerExcesso := .t.
	EndIf
	//
	cArm := aAuxEstoque[nCont,2] // Armazem
	nQtd := aAuxEstoque[nCont,3] // Normal
	SB2->(dbSetOrder(1))
	SB2->(dbSeek( aAuxEstoque[nCont,1] + SB1->B1_COD + cArm ))
	If c521EstQT == "1" // Terceiro
		nQtd := ( SB2->B2_QTNP + SB2->B2_QNPT )
	ElseIf c521EstQT == "2" // Normal + Terceiro
		nQtd := ( aAuxEstoque[nCont,3] + ( SB2->B2_QTNP + SB2->B2_QNPT ) )
	EndIf
	//	
	If cArm $ c521ArmDis // Disponivel
		aEstoque[nPos,2] += nQtd
	ElseIf cArm $ c521ArmOfi // Oficina
		aEstoque[nPos,3] += nQtd
	Else // Outros
		aEstoque[nPos,4] += nQtd
	EndIf	
	aEstoque[nPos,7] += SB2->B2_QACLASS // Qtd.Enderecar
	aEstoque[nPos,8] += ( SB2->B2_QACLASS + nQtd ) // Total
	//
	If lVerExcesso
		//
		cSQL := "SELECT SUM(D1.D1_QUANT)"
		cSQL +=  " FROM " + oSqlHlp:NoLock("SD1"," D1") + " "
		cSQL +=  " JOIN " + oSqlHlp:NoLock("SF4"," F4") + " ON F4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4.F4_CODIGO  = D1.D1_TES AND F4.D_E_L_E_T_ = ' ' "
		cSQL +=         " AND F4.F4_OPEMOV = '01'" // Somente TES de compra 
		cSQL += " WHERE D1.D1_FILIAL  = '" + xFilial("SD1") + "'"
		cSQL +=   " AND D1.D1_COD     = '" + SB1->B1_COD + "'"
		cSQL +=   " AND D1.D1_DTDIGIT BETWEEN '" + DtoS(M->C521CDTINI) + "' AND '" + DtoS(M->C521CDTFIM) + "'"
		cSQL +=   " AND D1.D_E_L_E_T_ = ' '"
		nQtdCpa := FM_SQL(cSQL) // Qtde Comprada
		//
		If nQtdCpa > 0
			cSQL := "SELECT SUM(D2.D2_QUANT)"
			cSQL +=  " FROM " + oSqlHlp:NoLock("SD2"," D2") + " "
			cSQL +=  " JOIN " + oSqlHlp:NoLock("SF4"," F4") + " ON F4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4.F4_CODIGO  = D2.D2_TES AND F4.D_E_L_E_T_ = ' ' "
			cSQL +=         " AND F4.F4_OPEMOV = '05'" // Somente TES de VENDA
			cSQL += " WHERE D2.D2_FILIAL  = '" + xFilial("SD2") + "'"
			cSQL +=   " AND D2.D2_COD     = '" + SB1->B1_COD + "'"
			cSQL +=   " AND D2.D2_EMISSAO BETWEEN '" + DtoS(M->C521VDTINI) + "' AND '" + DtoS(M->C521VDTFIM) + "'"
			cSQL +=   " AND D2.D_E_L_E_T_ = ' '"
			nQtdVda := FM_SQL(cSQL)
			If aEstoque[nPos,8] > nQtdVda // Estoque Atual > Qtde Vendida
				aEstoque[nPos,6] := ( aEstoque[nPos,8] - nQtdVda )  // EXCESSO: Estoque Atual - Qtde Vendida
			EndIf
		EndIf
		//
		lVerExcesso := .f.
		//
	EndIf
	//
Next nCont
If len(aEstoque) <= 0
	AADD( aEstoque , { "" , 0 , 0 , 0 , 0 , 0 , 0 , 0 , "" } )
EndIf

obC521Estq:nAt := 1
obC521Estq:SetArray(aEstoque)
obC521Estq:Refresh()
cFilAnt := cBkpFilial

Return

Static Function OC521AtVal(aAuxField)

Local xValue
Local nPos := aScan(aAutoCab,{ |x| x[1] == aAuxField[2] })

If nPos <> 0
	xValue := aAutoCab[nPos,2]
Else
	Do Case
	Case aAuxField[2] == "C521ESTQT"
		xValue := "0"
	Case aAuxField[2] == "C521CDTINI"
		xValue := dDataBase - 180
	Case aAuxField[2] == "C521CDTFIM"
		xValue := dDataBase
	Case aAuxField[2] == "C521VDTINI"
		xValue := dDataBase - 365
	Case aAuxField[2] == "C521VDTFIM"
		xValue := dDataBase
	Case aAuxField[2] == "C521ARMDIS"
		xValue := PADR(MV_PAR01,30)
	Case aAuxField[2] == "C521ARMOFI"
		xValue := PADR(MV_PAR02,30)
	Case Left(aAuxField[2],3) == "B1_"
		xValue := &("SB1->" + AllTrim(aAuxField[2]))	
	EndCase
EndIf

If xValue <> NIL
	&("M->"+aAuxField[2]) := xValue
EndIf

Return xValue

Function OC521Field(cField)

Local aRetorno := Array(16)

aRetorno[MVC_STRUCT_ID       ] := AllTrim(cField)
aRetorno[MVC_STRUCT_DEC      ] := 0
aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
aRetorno[MVC_STRUCT_ALTER    ] := .F.

Do Case

Case cField == "C521ESTQT"
	aRetorno[MVC_STRUCT_TITULO   ] := "Tipo Estoque"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Tipo Estoque"
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 1
	aRetorno[MVC_STRUCT_CBOX     ] := "0=Normal;1=Terceiro;2=Nomal+Terceiro"
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C521ARMDIS"
	aRetorno[MVC_STRUCT_TITULO   ] := "Armazens Disponiveis"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Armazens Disponiveis"
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 30
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C521ARMOFI"
	aRetorno[MVC_STRUCT_TITULO   ] := "Armazens Oficina"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Armazens Oficina"
	aRetorno[MVC_STRUCT_TIPO     ] := "C"
	aRetorno[MVC_STRUCT_TAM      ] := 30
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C521CDTINI"
	aRetorno[MVC_STRUCT_TITULO   ] := "Dt.Inicial Compras"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Dt.Inicial Compras"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C521CDTFIM"
	aRetorno[MVC_STRUCT_TITULO   ] := "Dt.Final Compras"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Dt. Final de Compras"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C521VDTINI"
	aRetorno[MVC_STRUCT_TITULO   ] := "Dt.Inicial Vendas"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Dt.Inicial Vendas"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C521VDTFIM"
	aRetorno[MVC_STRUCT_TITULO   ] := "Dt.Final Vendas"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Dt.Final Vendas"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 08
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .T.

Case cField == "C521GIRTOT"
	aRetorno[MVC_STRUCT_TITULO   ] := "Giro Total"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Giro Total"
	aRetorno[MVC_STRUCT_TIPO     ] := "N"
	aRetorno[MVC_STRUCT_TAM      ] := 15

Case cField == "C521ULTPED"
	aRetorno[MVC_STRUCT_TITULO   ] := "Ult.Pedido"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Ult.Pedido"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 8

Case cField == "C521ULTPDE"
	aRetorno[MVC_STRUCT_TITULO   ] := "Ult.Pedido Efetuado"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Ult.Pedido Efetuado"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 8

Case cField == "C521ULTSAI"
	aRetorno[MVC_STRUCT_TITULO   ] := "Ult.Saída"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Ult.Saída"
	aRetorno[MVC_STRUCT_TIPO     ] := "D"
	aRetorno[MVC_STRUCT_TAM      ] := 8

Case cField == "C521PEDCOM"
	aRetorno[MVC_STRUCT_TITULO   ] := "Estoque Comprometido"
	aRetorno[MVC_STRUCT_DESCRICAO] := "Estoque Comprometido"
	aRetorno[MVC_STRUCT_TIPO     ] := "N"
	aRetorno[MVC_STRUCT_TAM      ] := 15

EndCase

Return aRetorno



Static Function OC521CalcSize()

oSizePrinc := FwDefSize():New(.t.)
oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
oSizePrinc:AddObject("SUP"     , 100 , 100 , .T. , .F. )
oSizePrinc:AddObject("ESTOQUE" , 100 , 100 , .T. , .T. )
oSizePrinc:AddObject("DETALHE" , 100 , 050 , .T. , .F. )
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


Function OC521CHANGE(nLinha,cPictQtd)
Local cBkpFilial := cFilAnt
Local cSQLI      := ""
Local cSQLCntI   := ""     
Local oSqlHlp := DMS_SqlHelper():New()
Local cSQLQtdI   := ""
Local cAnoAntI   := strzero(year(dDataBase)-101,4)
Local cAnoAtuI   := strzero(year(dDataBase)-100,4)
Local cSQLV      := ""
Local cSQLCntV   := ""
Local cSQLQtdV   := ""
Local cAnoAntV   := strzero(year(dDataBase)-1,4)
Local cAnoAtuV   := strzero(year(dDataBase),4)
Local cMesSQL    := strzero(month(dDataBase),2)
Local lVB8       := .f.
Local lVQG       := .f.
Local lVQH       := .f.
If TCCANOPEN(oSqlHlp:NoLock("VB8"))
	If VB8->(!Eof())
		lVB8 := .t.
	EndIf
EndIf
If TCCANOPEN(oSqlHlp:NoLock("VQG"))
	If VQG->(!Eof())
		lVQG := .t.
	EndIf
EndIf
If TCCANOPEN(oSqlHlp:NoLock("VQH"))
	If VQH->(!Eof())
		lVQH := .t.
	EndIf
EndIf
c521GirTot := ""
c521UltPed := ""
c521UltPdE := ""
c521UltSai := ""
c521PedCom := ""
If !Empty(obC521Estq:aArray[nLinha,1])
	//
	cFilAnt := obC521Estq:aArray[nLinha,1]
	//
	If lVB8
		cSQLCntI := "SELECT COUNT(*) "
		cSQLQtdI := "SELECT SUM( VB8_TOTFAB ) "
		cSQLI := "FROM "+oSqlHlp:NoLock("VB8")+" WHERE "
		cSQLI += "VB8_FILIAL='"+xFilial("VB8")+"' AND "
		cSQLI += "("
		cSQLI += "( VB8_ANO='"+cAnoAntI+"' AND VB8_MES>'"+cMesSQL+"' )"
		cSQLI += " OR "
		cSQLI += "( VB8_ANO='"+cAnoAtuI+"' AND VB8_MES<='"+cMesSQL+"' )"
		cSQLI += ") "
		cSQLI += "AND VB8.D_E_L_E_T_=' '"
		cSQLCntV := "SELECT COUNT(*) "
		If lVQG
			cSQLQtdV := "SELECT SUM( VQG_VDABAL + VQG_VDAOFI + VQG_VDAINT ) "
			cSQLV := "FROM "+oSqlHlp:NoLock("VQG")+" WHERE "
			cSQLV += "VQG_FILIAL='"+xFilial("VQG")+"' AND "
			cSQLV += "("
			cSQLV += "( VQG_ANO='"+cAnoAntV+"' AND VQG_MES>'"+cMesSQL+"' )"
			cSQLV += " OR "
			cSQLV += "( VQG_ANO='"+cAnoAtuV+"' AND VQG_MES<='"+cMesSQL+"' )"
			cSQLV += ") "
			cSQLV += "AND VQG.D_E_L_E_T_=' '"
		Else
			cSQLQtdV := "SELECT SUM( BL_DEMANDA ) "
			cSQLV := "FROM "+oSqlHlp:NoLock("SBL")+" WHERE "
			cSQLV += "BL_FILIAL='"+xFilial("SBL")+"' AND BL_PRODUTO='"+SB1->B1_COD+"' AND "
			cSQLV += "("
			cSQLV += "( BL_ANO='"+cAnoAntV+"' AND BL_MES>'"+cMesSQL+"' )"
			cSQLV += " OR "
			cSQLV += "( BL_ANO='"+cAnoAtuV+"' AND BL_MES<='"+cMesSQL+"' )"
			cSQLV += ") "
			cSQLV += "AND SBL.D_E_L_E_T_=' '"
		EndIf
		c521GirTot := Transform( ( FM_SQL(cSQLQtdI+cSQLI) / FM_SQL(cSQLCntI+cSQLI) ) / ( FM_SQL(cSQLQtdV+cSQLV) / FM_SQL(cSQLCntV+cSQLV) ) ,"@E 99999.99")  // ( Inventario / Venda )
	EndIf
	//
	cSQL := "SELECT MAX(C7_EMISSAO) FROM "+oSqlHlp:NoLock("SC7")+" WHERE "
	cSQL += "C7_FILIAL='"+xFilial("SC7")+"' AND C7_PRODUTO='"+SB1->B1_COD+"' AND "
	cSQL += "C7_RESIDUO<>'S' AND SC7.D_E_L_E_T_=' '"
	c521UltPed := Transform(stod(FM_SQL(cSQL)),"@D")
	//	
	cSQL := "SELECT MAX(C7_EMISSAO) FROM "+oSqlHlp:NoLock("SC7")+" WHERE "
	cSQL += "C7_FILIAL='"+xFilial("SC7")+"' AND C7_PRODUTO='"+SB1->B1_COD+"' AND "
	cSQL += "C7_RESIDUO<>'S' AND C7_QUJE>0 AND SC7.D_E_L_E_T_=' '"
	c521UltPdE := Transform(stod(FM_SQL(cSQL)),"@D")
    //
	cSQL := "SELECT MAX(D2_EMISSAO) FROM "+oSqlHlp:NoLock("SD2")+" WHERE "
	cSQL += "D2_FILIAL='"+xFilial("SD2")+"' AND D2_COD='"+SB1->B1_COD+"' AND SD2.D_E_L_E_T_=' '"
	c521UltSai := Transform(stod(FM_SQL(cSQL)),"@D")
	//
	If lVQH
		cSQL := "SELECT SUM(VQH_QUANT) FROM "+oSqlHlp:NoLock("VQH")+" WHERE "
		cSQL += "VQH_FILIAL='"+xFilial("VQH")+"' AND VQH_PRODUT='"+SB1->B1_COD+"' AND VQH.D_E_L_E_T_=' '"
		c521PedCom := Transform(FM_SQL(cSQL),cPictQtd)
	EndIf
	//
EndIf
obC521EncDetalhe:Refresh()
cFilAnt := cBkpFilial
Return()

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
	{ STR0003 , "OC521Visual"  , 0 , 2} } // Visualizar
Return aRotina