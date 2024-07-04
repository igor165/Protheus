// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 27     ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº

#Include "PROTHEUS.CH"
#Include "OFIOC520.CH"

#DEFINE MVC_STRUCT_ID        01 // Id do Field
#DEFINE MVC_STRUCT_ORDEM     02 // Ordem
#DEFINE MVC_STRUCT_TITULO    03 // Titulo do campo
#DEFINE MVC_STRUCT_DESCRICAO 04 // Descricao do campo
#DEFINE MVC_STRUCT_TIPO      05 // Tipo do campo
#DEFINE MVC_STRUCT_TAM       06 // Tamanho do campo
#DEFINE MVC_STRUCT_DEC       07 // Decimal do campo
#DEFINE MVC_STRUCT_CBOX      08 // Array	Lista de valores permitido do campo	{}
#DEFINE MVC_STRUCT_OBRIGAT   09 // Indica se o campo tem preenchimento obrigatÛrio
#DEFINE MVC_STRUCT_VIRTUAL   10 // Indica se o campo È virtual
#DEFINE MVC_STRUCT_PICTURE   11 // Picture
#DEFINE MVC_STRUCT_F3        12 // Consulta F3
#DEFINE MVC_STRUCT_ALTER     13 // Indica se o campo È alteravel
#DEFINE MVC_STRUCT_PASTA     14 // Pasta do campo
#DEFINE MVC_STRUCT_AGRP      15 // Agrupamento do campo
#DEFINE MVC_STRUCT_NEWLINE   16 // Pula linha depois do campo

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Rubens Takahashi
    @since  25/07/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006392_1"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFIOC520   | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta Analitica de Itens                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIOC520(lNoMBrowse)

Local cBkpFilial   := cFilAnt
Local aBkpArea     := sGetArea(,"SB1")
Local bBlock
Private cCadastro  := STR0001
Private aRotina    := MenuDef()
Default lNoMBrowse := .f.
//
If type("nOpc") == "U"
	nOpc := 2
EndIf
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar o modulo de ( 14 - Oficina ) ou ( 41 - Auto Pecas ) //
///////////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIXA018","OFIXA012","OFIXA011","OFIOC520","OFIXA120","OFIXC001","MATA297M","OFINJD10"})
	Return
EndIf
//
DbSelectArea("SB1")
//
If lNoMBrowse
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	mBrowse( 6, 1,22,75,"SB1")
EndIf
//
sRestArea(aBkpArea)
cFilAnt := cBkpFilial
//
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |OC520Visual | Autor | Andre Luis Almeida    | Data | 14/08/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao |Visualizacao                                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC520Visual(cAlias,nReg,nOpc)

	Local aCpoRegistro := {}

	Local cBkpFilial := cFilAnt
	Local aBkpArea := sGetArea(,"SB1")
	Local lSBZ := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )
	Local nI

	Local nSavnOpc := nOpc
	Local lSavIncl := .f.
	Local lSavAlte := .f.
	Local aNewBot  := {}
	Local cPictQtd := PesqPict("SB2","B2_QATU")
	Local cPictVlr := PesqPict("SB1","B1_PRV1")

	Private lChk1 := .f.
	Private lChk2 := .f.
	Private lChk3 := .f.
	Private lChk4 := .f.
	Private lChk5 := .f.
	Private lChk6 := .f.
	
	Private oSizePrinc
	Private oSizeSup
	Private oSizeFiltro
	Private oSizeDet
	Private oSizeDet1
	Private oSizeDet2

	Private oDlg520
	Private obC520EncFiltro
	Private obC520EncDetalhe
	Private obC520Estq
	Private obC520Deman
	Private obC520Btn
	Private obC520CmpVen
	Private obC520TPrc
	Private obC520ItRel
	Private obC520ItSub
	Private obC520Check

	Private a520FldFiltro  := {}
	Private a520FldDetalhe := {}

	Private oAnt    := LoadBitmap( GetResources() , "metas_baixo_16" )
	Private oNov    := LoadBitmap( GetResources() , "metas_cima_16" )
	Private lMLF    := SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia
	Private lMLFSBZ := SBZ->(FieldPos("BZ_MARPEC")) > 0 .and. SBZ->(FieldPos("BZ_CODLIN")) > 0 .and. SBZ->(FieldPos("BZ_CODFAM")) > 0// quando .T. trabalha com Marca / Linha / Familia

	Private oFiltroC525

	Private aCpoCtm := {}
	Private lVAI_ACEDET := VAI->(ColumnPos('VAI_ACEDET')) > 0
	Private lExibePreco := .F.

	dbSelectArea("VAI")
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)

	If Type("INCLUI") != "U"
		lSavIncl := INCLUI
	Endif
	If Type("ALTERA") != "U"
		lSavAlte := ALTERA
	Endif

	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Valida se a empresa tem autorizacao para utilizar o modulo de ( 14 - Oficina ) ou ( 41 - Auto Pecas ) //
	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIXA018","OFIXA012","OFIXA011","OFIOC520","OFIXA120","OFIXC001","MATA297M","OFINJD10"})
		Return()
	EndIf

	If ( ExistBlock("OC520ABT") )
		aNewBot := ExecBlock("OC520ABT",.f.,.f.,{aNewBot})
	EndIf

	SB1->(dbGoTo(nReg))

	Static oC520Peca := DMS_Peca():New()
	oC520Peca:SetGrupo(SB1->B1_GRUPO)
	oC520Peca:SetCodigo(SB1->B1_CODITE)

	Pergunte( "OFIOC525" , .f. ,,,,.f.)
	oFiltroC525 := DMS_DataContainer():New({;
					{'DATA_INICIAL',(dDataBase-MV_PAR01) },; // Data Inicial 
					{'DATA_FINAL'  ,dDataBase            },; // Data Final
					{'TIPO_PEDIDO_DESCONSIDERAR',MV_PAR02}; // Tp.Pedido Desconsiderar
	})

	// Calcula Coordenadas dos objetos
	OC520CalcSize()

	DEFINE MSDIALOG oDlg520 TITLE STR0001 OF oMainWnd PIXEL;
		FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

	// Para cada variavel que comeca com C520 existe uma variavel igual, mas comecando com P520 que deve ser utilizada nos parametros
	//
	// [1] - Nome do campo
	// [2] - Nome do campo que sera considerado (pode ser informado quando È utilizado os dados do dicionario - SX3)
	// [3] - Utilizar SX3 ?
	aCampos := { ;
		{ "B1_COD"      , "C520B1COD" , .t. },;
		{ "B1_DESC"     , "" , .t. },;
		{ "C520PARFIL"  , "" , .f. }}

	aCpoRegistro := {}
	OC520AddField(aCampos, @a520FldFiltro, "OC520Field" )
	nPos := aScan(a520FldFiltro,{ |x| x[2] == "C520B1COD" })
	a520FldFiltro[ nPos , 11 ] := "SB1"
	a520FldFiltro[ nPos , 07 ] := { || OC520Valid() }
	a520FldFiltro[ nPos , 13 ] := .f.
	a520FldFiltro[ nPos , 17 ] := .f.
	aEval(a520FldFiltro,{ |x| ;
		&("M->" + x[2]) := &("M->P" + SubStr(x[2],2)) := OC520AtVal(x) ,;
		AADD( aCpoRegistro , x[2] ) })

	obC520EncFiltro := MsmGet():New(,,2 /* Visualizar */,;
		/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
		oSizeFiltro:GetObjectArea("FILTRO"), ;
		aClone(aCpoRegistro), 3 /*nModelo*/,;
		/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg520 , .t. /*lF3*/, .t. /* lMemoria */ , .t. /*lColumn*/,;
		/*caTela*/, .t. /*lNoFolder*/, .F. /*lProperty*/,;
		aClone(a520FldFiltro), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)

	//obC520EncFiltro:oBox:l3DLook := .f.
	//obC520EncFiltro:oBox:lBorder := .f.

	TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 1, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") ,;
		STR0041, oDlg520 , { || OC520Atu(.t.) }, oSizeFiltro:GetDimension("BTN_ATUALIZA","XSIZE") , 010,,,.F.,.T.,.F.,,.F.,,,.F. ) // Atualizar

	aCampos := {}
	AADD( aCampos , { "B1_GRUPO"    , "" , .t. } )
	AADD( aCampos , { "B1_CODITE"   , "" , .t. } )
	AADD( aCampos , { "B1_DESC"     , "" , .t. } )
	if lSBZ .and. lMLFSBZ
		AADD( aCampos , { "BZ_MARPEC"     , "" , .t. } )
		AADD( aCampos , { "BZ_CODLIN"     , "" , .t. } )
		AADD( aCampos , { "BZ_CODFAM"     , "" , .t. } )
	Elseif lMLF
		AADD( aCampos , { "B5_MARPEC"     , "" , .t. } )
		AADD( aCampos , { "B5_CODLIN"     , "" , .t. } )
		AADD( aCampos , { "B5_CODFAM"     , "" , .t. } )
	Else
		AADD( aCampos , { "BM_CODMAR"     , "" , .t. } )
	EndIf
	AADD( aCampos , { "B1_CODBAR"     , "" , .t. } )
	AADD( aCampos , { "B1_FABRIC"     , "" , .t. } )
	AADD( aCampos , { "C520GRUDES"    , "" , .f. } )
	AADD( aCampos , { "C520ORIGEM"    , "" , .f. } )
	AADD( aCampos , { "B1_UM"         , "" , .t. } )
	AADD( aCampos , { "B1_IPI"        , "" , .t. } )
	AADD( aCampos , { "B1_POSIPI"     , "" , .t. } )
	AADD( aCampos , { "C520GRTRIB"    , "" , .f. } )
	AADD( aCampos , { "B1_QE"         , "" , .t. } )
	AADD( aCampos , { "B1_CRICOD"     , "" , .t. } )
	AADD( aCampos , { "B1_DTREFP1"    , "" , .t. } )
	AADD( aCampos , { "C520MSBLQL"    , "" , .t. } )
	AADD( aCampos , { "B1_CODGEN"     , "" , .t. } )

	If ExistBlock("OC520CPO") // AdiÁ„o de Campos Customizados pelo Cliente	
		aCpoCtm := ExecBlock("OC520CPO",.F.,.F., aCpoCtm)
		For nI := 1 to len(aCpoCtm)
			aadd(aCampos, aCpoCtm[nI])
		Next
	Endif

	aCpoRegistro := {}
	OC520AddField(aCampos, @a520FldDetalhe, "OC520Field" )
	aEval(a520FldDetalhe,{ |x| &("M->" + x[2]) := OC520AtVal(x) , AADD( aCpoRegistro , x[2] ) })

	obC520EncDetalhe := MsmGet():New(,,2 /* Visualizar */,;
		/*aCRA*/,/*cLetras*/,/*cTexto*/,aClone(aCpoRegistro),;
		oSizeSup:GetObjectArea("DETALHE"), ;
		aClone(aCpoRegistro), 3 /*nModelo*/,;
		/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlg520 , .f. /*lF3*/, .t. /* lMemoria */ , .f. /*lColumn*/,;
		/*caTela*/, .t. /*lNoFolder*/, .f. /*lProperty*/,;
		aClone(a520FldDetalhe), /* aFolder */ , .f. /* lCreate */ , .t. /*lNoMDIStretch*/,/*cTela*/)

	// ------------------- //
	// CRIA BOX - ESTOQUE  //
	// ------------------- //
	TButton():New( oSizeDet1:GetDimension("ESTOQUE","LININI"), oSizeDet1:GetDimension("ESTOQUE","COLINI"), STR0042, oDlg520,; // Estoque
		{ || OC520Exec("OFIOC521") },;
		oSizeDet1:GetDimension("ESTOQUE","XSIZE"), 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	obC520Estq := TWBrowse():New( ;
		oSizeDet1:GetDimension("ESTOQUE","LININI")+11,;
		oSizeDet1:GetDimension("ESTOQUE","COLINI"),;
		oSizeDet1:GetDimension("ESTOQUE","XSIZE"), ;
		oSizeDet1:GetDimension("ESTOQUE","YSIZE")-11 ,,,,oDlg520,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	obC520Estq:AddColumn( TCColumn():New( STR0004 , { || obC520Estq:aArray[obC520Estq:nAT,1] + " - " + obC520Estq:aArray[obC520Estq:nAT,4] } ,,,,"LEFT"   ,(oSizeDet1:GetDimension("ESTOQUE","XSIZE")*0.35),.F.,.F.,,,,.F.,) ) // "Estoque"
	obC520Estq:AddColumn( TCColumn():New( STR0005 , { || Transform(obC520Estq:aArray[obC520Estq:nAT,2],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet1:GetDimension("ESTOQUE","XSIZE")*0.30),.F.,.F.,,,,.F.,) ) // "Empresa"
	obC520Estq:AddColumn( TCColumn():New( STR0006 , { || Transform(obC520Estq:aArray[obC520Estq:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet1:GetDimension("ESTOQUE","XSIZE")*0.30),.F.,.F.,,,,.F.,) ) // "Consol."
	obC520Estq:nAt := 1
	obC520Estq:SetArray({})

	// ------------------- //
	// CRIA BOX - DEMANDA  //
	// ------------------- //
	TButton():New( oSizeDet1:GetDimension("DEMANDA","LININI"), oSizeDet1:GetDimension("DEMANDA","COLINI"), STR0043, oDlg520,; // Demandas
		{ || OC520Exec("OFIOC524") },;
		oSizeDet1:GetDimension("DEMANDA","XSIZE"), 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	obC520Deman := TWBrowse():New( ;
		oSizeDet1:GetDimension("DEMANDA","LININI")+11,;
		oSizeDet1:GetDimension("DEMANDA","COLINI"),;
		oSizeDet1:GetDimension("DEMANDA","XSIZE"), ;
		oSizeDet1:GetDimension("DEMANDA","YSIZE")-11 ,,,,oDlg520,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	obC520Deman:AddColumn( TCColumn():New( STR0007     , { || obC520Deman:aArray[obC520Deman:nAT,2] } ,,,,"LEFT"   ,(oSizeDet1:GetDimension("DEMANDA","XSIZE")*0.35),.F.,.F.,,,,.F.,) ) // "MÍs"
	obC520Deman:AddColumn( TCColumn():New( STR0005 , { || Transform(obC520Deman:aArray[obC520Deman:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet1:GetDimension("DEMANDA","XSIZE")*0.30),.F.,.F.,,,,.F.,) ) // "Empresa"
	obC520Deman:AddColumn( TCColumn():New( STR0006 , { || Transform(obC520Deman:aArray[obC520Deman:nAT,4],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet1:GetDimension("DEMANDA","XSIZE")*0.30),.F.,.F.,,,,.F.,) ) // "Consol."
	obC520Deman:nAt := 1
	obC520Deman:SetArray({})
	obC520Deman:Refresh()

	// ------------------- //
	// CRIA BOX COM BOTOES //
	// ------------------- //
	obC520Btn := TScrollBox():New( oDlg520 ,;
		oSizeDet1:GetDimension("BOTOES","LININI"),;
		oSizeDet1:GetDimension("BOTOES","COLINI"),;
		oSizeDet1:GetDimension("BOTOES","LINEND")-oSizeDet1:GetDimension("BOTOES","LININI"),;
		oSizeDet1:GetDimension("BOTOES","COLEND")-oSizeDet1:GetDimension("BOTOES","COLINI"),;
		.t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )
	nLin := 0
	TButton():New( nLin, 02, STR0008 , obC520Btn,{|| OC520Exec("OFIOC150") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. )
	nLin += 13
	TButton():New( nLin, 02, STR0009 , obC520Btn,{|| OC520Exec("M_LCPCJD") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || ExistBlock("M_LCPCJD") } /* bWhen */ ,,.F. )
	nLin += 13
	TButton():New( nLin, 02, STR0010 , obC520Btn,{|| OC520Exec("OFIOC525") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // Pedidos
	nLin += 13
	TButton():New( nLin, 02, STR0011 , obC520Btn,{|| OC520Exec("OFIOC526") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // Reservas
	nLin += 13
	TButton():New( nLin, 02, STR0040 , obC520Btn,{|| OC520Exec("OFIOC528") }, 040, 010,,,.F.,.T.,.F.,,.F.,{ || .t. } /* bWhen */ ,,.F. ) // Transferencias

	// ------------------------------------------- //
	// TIKS                                        //
	// ------------------------------------------- //

	lChk1 := OC520TICK("1")
	lChk2 := OC520TICK("2")
	lChk3 := OC520TICK("3")
	lChk4 := OC520TICK("4")
	lChk5 := OC520TICK("5")
	lChk6 := OC520TICK("6")

	nLin := oSizeDet1:GetDimension("TIKS","LININI")
	nCol := oSizeDet1:GetDimension("TIKS","COLINI")
	@ nLin,nCol TO nLin+oSizeDet1:GetDimension("TIKS","YSIZE"),nCol+oSizeDet1:GetDimension("TIKS","XSIZE") LABEL "" OF oDlg520 PIXEL
	nLin += 5
	nCol += 5
	@ nLin , nCol CHECKBOX oChk1 VAR lChk1 PROMPT STR0012 OF oDlg520 SIZE 80, 10 WHEN .f. PIXEL
	nLin += 10
	@ nLin , nCol CHECKBOX oChk2 VAR lChk2 PROMPT STR0013 OF oDlg520 SIZE 80, 10 WHEN .f. PIXEL
	nLin += 10
	@ nLin , nCol CHECKBOX oChk3 VAR lChk3 PROMPT STR0014 OF oDlg520 SIZE 80, 10 WHEN .f. PIXEL
	nLin += 10
	@ nLin , nCol CHECKBOX oChk4 VAR lChk4 PROMPT STR0015 OF oDlg520 SIZE 80, 10 WHEN .f. PIXEL
	nLin += 10
	@ nLin , nCol CHECKBOX oChk5 VAR lChk5 PROMPT STR0016 OF oDlg520 SIZE 80, 10 WHEN .f. PIXEL
	nLin += 10
	@ nLin , nCol CHECKBOX oChk6 VAR lChk6 PROMPT STR0048 OF oDlg520 SIZE 80, 10 WHEN .f. PIXEL // Obsoleto

	// ------------------------------------------- //
	// CRIA BOX COM INFORMACOES DE COMPRA E VENDA  //
	// ------------------------------------------- //
	obC520CmpVen := TScrollBox():New( oDlg520 ,;
		oSizeDet1:GetDimension("COMPRA_VENDA","LININI")+1,;
		oSizeDet1:GetDimension("COMPRA_VENDA","COLINI")+1,;
		oSizeDet1:GetDimension("COMPRA_VENDA","LINEND")-oSizeDet1:GetDimension("COMPRA_VENDA","LININI")-2,;
		oSizeDet1:GetDimension("COMPRA_VENDA","COLEND")-oSizeDet1:GetDimension("COMPRA_VENDA","COLINI")-2,;
		.t. /* lVertical */ , .f. /* lHorizontal */ , .f. /* lBorder */ )

	@ oSizeDet1:GetDimension("COMPRA_VENDA","LININI"),oSizeDet1:GetDimension("COMPRA_VENDA","COLINI") TO oSizeDet1:GetDimension("COMPRA_VENDA","LINEND"),oSizeDet1:GetDimension("COMPRA_VENDA","COLEND") LABEL "" OF oDlg520 PIXEL

	nLin := 03
	@ nLin+1 , 03 SAY STR0017 OF obC520CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || oC520Peca:GetUltVenda() },obC520CmpVen, 45, 1, "@D",,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"dUltVenda",,,,.T. )
	TButton():New( nLin, 95, STR0018, obC520CmpVen,{ || OC520Exec("OFIOC523") },030, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	nLin += 13
	@ nLin+1 , 03 SAY STR0019 OF obC520CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || SB1->B1_UCOM },obC520CmpVen, 45, 1, "@D",,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"dUltCompra",,,,.T. )
	TButton():New( nLin+07, 95, STR0020, obC520CmpVen,{ || OC520Exec("OFIOC522") },	030, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	nLin += 13
	@ nLin+1 , 03 SAY STR0021 OF obC520CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || oC520Peca:GetUltCompra() },obC520CmpVen, 45, 1, "@D",,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"dUltCompra",,,,.T. )
	nLin += 13
	@ nLin+1 , 03 SAY STR0022 OF obC520CmpVen PIXEL SIZE 100,20
	TGet():New( nLin, 50, { || SB1->(FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")) },obC520CmpVen, 76, 1, "@!",,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"cLocacao",,,, )
	nLin += 13
	@ nLin+1 , 03 SAY STR0015 OF obC520CmpVen PIXEL SIZE 200,20
	TGet():New( nLin, 50, { || oC520Peca:PedCompraPendente(oFiltroC525) },obC520CmpVen, 76, 1, x3Picture("C7_QUANT") ,,,,,.F.,,.T.,,.F.,{||  .f. },.F.,.F.,,.F.,.F. ,,"nQtdPendente",,,,.T. )


	// ---------------------------- //
	// CRIA BOX COM TABELA DE PRECO //
	// ---------------------------- //
	lExibePreco := .F.
	If lVAI_ACEDET
		If VAI->VAI_ACEDET <> "0"
			lExibePreco := .T.
		Endif
	Else
		lExibePreco := .T.
	Endif

	If lExibePreco
		@ oSizeDet2:GetDimension("TAB_PRECO","LININI"),;
		oSizeDet2:GetDimension("TAB_PRECO","COLINI") TO oSizeDet2:GetDimension("TAB_PRECO","LININI") + oSizeDet2:GetDimension("TAB_PRECO","YSIZE"),;
		oSizeDet2:GetDimension("TAB_PRECO","COLINI") + oSizeDet2:GetDimension("TAB_PRECO","XSIZE") - 50 LABEL STR0044 OF oDlg520 PIXEL // PreÁos
		obC520TPrc := TWBrowse():New( ;
			oSizeDet2:GetDimension("TAB_PRECO","LININI")+8,;
			oSizeDet2:GetDimension("TAB_PRECO","COLINI"),;
			oSizeDet2:GetDimension("TAB_PRECO","XSIZE")-50, ;
			oSizeDet2:GetDimension("TAB_PRECO","YSIZE")-8 ,,,,oDlg520,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		obC520TPrc:AddColumn( TCColumn():New( STR0023 , { || obC520TPrc:aArray[obC520TPrc:nAT,1] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("TAB_PRECO","XSIZE")*0.50),.F.,.F.,,,,.F.,) )
		obC520TPrc:AddColumn( TCColumn():New( STR0024     , { || Transform(obC520TPrc:aArray[obC520TPrc:nAT,2],"@E 999,999,999.99") } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("TAB_PRECO","XSIZE")*0.10),.F.,.F.,,,,.F.,) )
		obC520TPrc:nAt := 1
		obC520TPrc:SetArray({})
	Endif

	// ------------------------------- //
	// CRIA BOX COM ITENS RELACIONADOS //
	// ------------------------------- //
	@ oSizeDet2:GetDimension("ITENS_REL","LININI"),;
		oSizeDet2:GetDimension("ITENS_REL", "COLINI") - If(lExibePreco, 50, 317) TO oSizeDet2:GetDimension("ITENS_REL", "LININI") + oSizeDet2:GetDimension("ITENS_REL", "YSIZE"),;
		oSizeDet2:GetDimension("ITENS_REL", "COLINI") + oSizeDet2:GetDimension("ITENS_REL","XSIZE") - If(lExibePreco, 25, 160) LABEL STR0045 OF oDlg520 PIXEL // Itens Relacionados
	obC520ItRel := TWBrowse():New(;
		oSizeDet2:GetDimension("ITENS_REL", "LININI") + 8,;
		oSizeDet2:GetDimension("ITENS_REL", "COLINI") - If(lExibePreco, 50, 317),;
		oSizeDet2:GetDimension("ITENS_REL", "XSIZE") + If(lExibePreco, 25, 156),;
		oSizeDet2:GetDimension("ITENS_REL", "YSIZE") - 8,,,,oDlg520,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	obC520ItRel:AddColumn( TCColumn():New( STR0025 , { || obC520ItRel:aArray[obC520ItRel:nAT,1] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_REL","XSIZE")*0.30),.F.,.F.,,,,.F.,) )
	obC520ItRel:AddColumn( TCColumn():New( STR0026 , { || obC520ItRel:aArray[obC520ItRel:nAT,2] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_REL","XSIZE")*0.30),.F.,.F.,,,,.F.,) )
	obC520ItRel:AddColumn( TCColumn():New( STR0027    , { || Transform(obC520ItRel:aArray[obC520ItRel:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("ITENS_REL","XSIZE")*0.15),.F.,.F.,,,,.F.,) )
	obC520ItRel:AddColumn( TCColumn():New( STR0024    , { || Transform(obC520ItRel:aArray[obC520ItRel:nAT,4],cPictVlr) } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("ITENS_REL","XSIZE")*0.20),.F.,.F.,,,,.F.,) )
	obC520ItRel:nAt := 1
	obC520ItRel:SetArray({})

	// -------------------------------------------- //
	// CRIA BOX COM ITENS SUBSTITUIDOS/SUBSTITUTOS  //
	// -------------------------------------------- //
	@ oSizeDet2:GetDimension("ITENS_SUB", "LININI"),;
		oSizeDet2:GetDimension("ITENS_SUB", "COLINI") - If(lExibePreco, 50, 156) TO oSizeDet2:GetDimension("ITENS_SUB", "LININI") + oSizeDet2:GetDimension("ITENS_SUB", "YSIZE"),;
		oSizeDet2:GetDimension("ITENS_SUB", "COLINI") + oSizeDet2:GetDimension("ITENS_SUB", "XSIZE") - If(lExibePreco, 0, 0) LABEL STR0046 OF oDlg520 PIXEL // Itens Substituidos / Substitutos
	obC520ItSub := TWBrowse():New( ;
		oSizeDet2:GetDimension("ITENS_SUB", "LININI") + 8,;
		oSizeDet2:GetDimension("ITENS_SUB", "COLINI") - If(lExibePreco, 25, 156),;
		oSizeDet2:GetDimension("ITENS_SUB", "XSIZE") + If(lExibePreco, 25, 156),;
		oSizeDet2:GetDimension("ITENS_SUB", "YSIZE") - 8,,,,oDlg520,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	obC520ItSub:AddColumn( TCColumn():New( "" , { || IIf(obC520ItSub:aArray[obC520ItSub:nAT,4]=="A",oAnt,oNov) } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.05),.T.,.F.,,,,.F.,) )
	obC520ItSub:AddColumn( TCColumn():New( STR0025 , { || obC520ItSub:aArray[obC520ItSub:nAT,1] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.35),.F.,.F.,,,,.F.,) )
	obC520ItSub:AddColumn( TCColumn():New( STR0026 , { || obC520ItSub:aArray[obC520ItSub:nAT,2] } ,,,,"LEFT"   ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.30),.F.,.F.,,,,.F.,) )
	obC520ItSub:AddColumn( TCColumn():New( STR0027    , { || Transform(obC520ItSub:aArray[obC520ItSub:nAT,3],cPictQtd) } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.15),.F.,.F.,,,,.F.,) )
	obC520ItSub:AddColumn( TCColumn():New( STR0024    , { || Transform(obC520ItSub:aArray[obC520ItSub:nAT,5],cPictVlr) } ,,,,"RIGHT"  ,(oSizeDet2:GetDimension("ITENS_SUB","XSIZE")*0.20),.F.,.F.,,,,.F.,) )
	obC520ItSub:nAt := 1
	obC520ItSub:SetArray({})

	// Atualiza Controles ...
	OC520Atu(.f.)
	//

	ACTIVATE MSDIALOG oDlg520          ON INIT  (EnchoiceBar(oDlg520,{||oDlg520:End()},{||oDlg520:End() },, aNewBot))

	sRestArea(aBkpArea)
	nOpc    := nSavnOpc

	If Type("INCLUI") != "U"
		INCLUI := lSavIncl
	Endif
	If Type("ALTERA") != "U"
		ALTERA := lSavAlte
	Endif
	cFilAnt := cBkpFilial

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC520Valid | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC520Valid( cReadVar )

	Local lRet := .f.
	Local aArea

	Default cReadVar := ReadVar()

	Do Case
	Case cReadVar == "M->C520B1COD"
		aArea := sGetArea(,"SB1")
		SB1->(dbSetOrder(1))
		If (lRet := SB1->(MsSeek(xFilial("SB1")+M->C520B1COD)))
			M->B1_DESC := SB1->B1_DESC
		EndIf
		sRestArea(aArea)
	End Case

Return lRet

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC520TICK  | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC520TICK(cTp)
	Local lRet := .f.
	Local cSQL := ""
	Local oSqlHlp := DMS_SqlHelper():New()
	Do Case
		Case cTp == "1" // Original
			cSQL := "SELECT BM_PROORI FROM "+oSqlHlp:NoLock("SBM")+" WHERE "
			cSQL += "BM_FILIAL='"+xFilial("SBM")+"' AND BM_GRUPO='"+SB1->B1_GRUPO+"' AND SBM.D_E_L_E_T_=' '"
			If FM_SQL(cSQL) == "1" // Original
				lRet := .t.
			EndIf
		Case cTp == "2" // Desconto
			cSQL := "SELECT VEN_PERDES FROM "+oSqlHlp:NoLock("VEN")+" WHERE "
			cSQL += "VEN_FILIAL='"+xFilial("VEN")+"' AND VEN_GRUITE='"+SB1->B1_GRUPO+"' AND VEN_CODITE='"+SB1->B1_CODITE+"' AND "
			cSQL += "VEN_DATINI<='"+dtos(dDataBase)+"' AND VEN_DATFIN>='"+dtos(dDataBase)+"' AND VEN_PERDES>0 AND VEN.D_E_L_E_T_=' '"
			If FM_SQL(cSQL) > 0 // % Desconto
				lRet := .t.
			EndIf
		Case cTp == "3" // Promocao
			cSQL := "SELECT VEN_VALPRO FROM "+oSqlHlp:NoLock("VEN")+" WHERE "
			cSQL += "VEN_FILIAL='"+xFilial("VEN")+"' AND VEN_GRUITE='"+SB1->B1_GRUPO+"' AND VEN_CODITE='"+SB1->B1_CODITE+"' AND "
			cSQL += "VEN_DATINI<='"+dtos(dDataBase)+"' AND VEN_DATFIN>='"+dtos(dDataBase)+"' AND VEN_VALPRO>0 AND VEN.D_E_L_E_T_=' '"
			If FM_SQL(cSQL) > 0 // Promocao
				lRet := .t.
			EndIf
		Case cTp == "4" // Ped.Pendente
			If oC520Peca:PedCompraPendente(oFiltroC525) > 0 // Existe Pedido Pendente
				lRet := .t.
			EndIf
		Case cTp == "5" // Retornavel
			If ( SB1->(FieldPos("B1_REMANE")) <> 0 )
				If SB1->B1_REMANE == "1"
			    	lRet := .t.
				EndIf
			EndIf
		Case cTp == "6" // Obsoleto
			If ( SBZ->(FieldPos("BZ_OBSOLE")) <> 0 ) // Verificar apenas o SBZ - Otavio falou que n„o sera criado no SB1/SB5 02/08/2022
				cSQL := "SELECT SBZ.BZ_OBSOLE "
				cSQL += "  FROM "+oSqlHlp:NoLock("SBZ")
				cSQL += " WHERE SBZ.BZ_FILIAL='"+xFilial("SBZ")+"'"
				cSQL += "   AND SBZ.BZ_COD='"+SB1->B1_COD+"'"
				cSQL += "   AND SBZ.D_E_L_E_T_=' '"
				If FM_SQL(cSQL) == "1" // Obsoleto
					lRet := .t.
				EndIf
			EndIf
	End Case
Return lRet


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC520Atu   | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC520Atu(lAtuPar)

	Local nCont
	Local aAuxAtu
	Local aEstoque
	Local aDemanda := {}

	Default lAtuPar := .f. // Define se atualiza MsMGet de parametros da Rotina ...

	//
	// Ponto de Entrada ser· executado sempre que a tela principal for atualizada
	//
	If ExistBlock("OC520ATU")
		ExecBlock("OC520ATU",.f.,.f.,{lAtuPar})
	Endif
	//
	
	If lAtuPar
		If Empty(M->C520PARFIL)
			MsgAlert(STR0028,STR0029)
			Return()
		EndIf
		If Empty(M->C520B1COD)
			MsgAlert(STR0030,STR0029)
			Return()
		EndIf
		// Ajusta Filial ... //
		cFilAnt := M->P520PARFIL := M->C520PARFIL
		For nCont := 1 to Len(a520FldFiltro)
			If Left(a520FldFiltro[nCont,2],4) == "C520"
				&("M->P" + SubStr(a520FldFiltro[nCont,2],2)) := &("M->" + a520FldFiltro[nCont,2])
			EndIf
		Next nCont
	EndIf
	//

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + M->P520B1COD))

	// Atualiza MsMGet de Detalhe ...
	For nCont := 1 to Len(a520FldDetalhe)
		OC520AtVal(a520FldDetalhe[nCont])
	Next nCont
	obC520EncDetalhe:Refresh()

	oC520Peca:SetGrupo(SB1->B1_GRUPO)
	oC520Peca:SetCodigo(SB1->B1_CODITE)

	// Atualiza Listbox de Estoque ...
	aAuxAtu := oC520Peca:EstqSaldo(,.t.,.t.)
	aEstoque := {}
	For nCont := 1 to Len(aAuxAtu)
		If (nPos := aScan(aEstoque,{ |x| x[1] == aAuxAtu[nCont,2] })) == 0
			AADD(aEstoque , { aAuxAtu[nCont,2] , 0 , 0 , aAuxAtu[nCont,4] } )
			nPos := Len(aEstoque)
		EndIf
		aEstoque[nPos,2] += IIf( aAuxAtu[nCont,1] == cFilAnt , aAuxAtu[nCont,3] , 0 )
		aEstoque[nPos,3] += aAuxAtu[nCont,3]
	Next nCont
	// coleta descricao correta dos Almoxarifados
	For nCont := 1 to LEN(aEstoque)
		nPos := aScan(aAuxAtu, {|f| f[1] == cFilAnt .AND. f[2] == aEstoque[nCont, 1] })
		if nPos > 0
			if ! EMPTY(aAuxAtu[nPos, 4])
				aEstoque[nCont, 4] := aAuxAtu[nPos, 4] // sobrepondo a descricao com a da filial logada
			end
		end
	Next

	obC520Estq:nAt := 1
	obC520Estq:SetArray(aEstoque)
	obC520Estq:Refresh()
	//

	// Atualiza Precos ...
	If lExibePreco
		aPreco := oC520Peca:TabelaPreco()
		obC520TPrc:nAt := 1
		obC520TPrc:SetArray(aPreco)
		obC520TPrc:Refresh()
	Endif
	//

	lChk1 := OC520TICK("1")
	lChk2 := OC520TICK("2")
	lChk3 := OC520TICK("3")
	lChk4 := OC520TICK("4")
	lChk5 := OC520TICK("5")
	lChk6 := OC520TICK("6")

	oChk1:Refresh()
	oChk2:Refresh()
	oChk3:Refresh()
	oChk4:Refresh()
	oChk5:Refresh()
	oChk6:Refresh()

	// Atualiza Itens Relacionados...
	aItRel := {}
	aAuxItRel := oC520Peca:ItensRelacionados()
	aEval(aAuxItRel,{ |x| AADD(aItRel,{ AllTrim(x[1]+" "+x[2]) , AllTrim(x[3]) , x[4] , x[5] } ) })
	obC520ItRel:nAt := 1
	obC520ItRel:SetArray(aItRel)
	obC520ItRel:Refresh()
	//

	// Atualiza Itens Substituidos...
	aItSub := {}
	aAuxItSub := oC520Peca:ItensSubstituidos()
	aEval(aAuxItSub,{ |x| AADD(aItSub,{ AllTrim(x[1]+" "+x[2]) , AllTrim(x[3]) , x[7] , x[8] , x[9] } ) })
	obC520ItSub:nAt := 1
	obC520ItSub:SetArray(aItSub)
	obC520ItSub:Refresh()

	// Demandas
	For nCont := 1 to 12
		AADD( aDemanda , { strzero(nCont,2) , UPPER(FG_CMONTH(stod("2000"+strzero(nCont,2)+"01"))) , 0 , 0 } )
	Next nCont
	aAuxAtu := oC520Peca:GetDemanda(.t.,Str(Year(dDataBase),4),"")
	For nCont := 1 to Len(aAuxAtu)
		nPos := aScan(aDemanda,{ |x| val(x[1]) == val(aAuxAtu[nCont,4]) })
		if nPos == 0
			loop
		EndIf
		nTotDem := aAuxAtu[nCont,5]-aAuxAtu[nCont,6]
		aDemanda[nPos,3] += IIf( aAuxAtu[nCont,1] == cFilAnt , nTotDem , 0 ) // filial logada
		aDemanda[nPos,4] += nTotDem // todas as empresas
	Next nCont
	obC520Deman:nAt := 1
	obC520Deman:SetArray(aDemanda)
	obC520Deman:Refresh()
	//

	obC520CmpVen:Refresh()

    
Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC520AtVal | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC520AtVal(aAuxField)

	Local xValue
	Local cBx_ORIGEM := ""

	Private oSqlHlp := DMS_SqlHelper():New()

	Do Case
	Case aAuxField[2] == "C520PARFIL"
		xValue := FWArrFilAtu()[SM0_CODFIL]
	Case aAuxField[2] == "C520MSBLQL"
		xValue := IIf( SB1->B1_MSBLQL == "1" , STR0031 , STR0032)
	Case aAuxField[2] == "C520B1COD"
		xValue := SB1->B1_COD

	Case aAuxField[2] == "BM_CODMAR"
		cSQL := "SELECT SBM.BM_CODMAR"
		cSQL +=  " FROM " + oSqlHlp:NoLock("SBM") + " "
		cSQL += " WHERE SBM.BM_FILIAL = '" + xFilial("SBM") + "'"
		cSQL +=   " AND SBM.BM_GRUPO = '" + SB1->B1_GRUPO + "'"
		cSQL +=   " AND SBM.D_E_L_E_T_ = ' '"
		xValue := FM_SQL(cSQL)

	Case aAuxField[2] $ "B5_MARPEC/BZ_MARPEC/B5_CODLIN/BZ_CODLIN/B5_CODFAM/BZ_CODFAM"
		xValue := FM_SQL(OC520ARQPROD(SB1->B1_COD, aAuxField[2]))

	Case aAuxField[2] == "C520GRUDES"
		cSQL := "SELECT VE5.VE5_DESGRU "
		cSQL +=  " FROM " + oSqlHlp:NoLock("SBM") + " "
		cSQL +=  " JOIN " + oSqlHlp:NoLock("VE5") + " "
		cSQL +=    " ON VE5.VE5_FILIAL = '" + xFilial("VE5") + "' AND VE5.VE5_CODMAR = SBM.BM_CODMAR AND VE5.VE5_GRUDST = '"+SB1->B1_GRUDES+"' AND VE5.D_E_L_E_T_ = ' ' "
		cSQL += " WHERE SBM.BM_FILIAL = '" + xFilial("SBM") + "'"
		cSQL +=   " AND SBM.BM_GRUPO = '" + SB1->B1_GRUPO + "'"
		cSQL +=   " AND SBM.D_E_L_E_T_ = ' '"
		xValue := SB1->B1_GRUDES + "-" + FM_SQL(cSQL)

	Case aAuxField[2] == "C520ORIGEM"
		cBx_ORIGEM := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ORIGEM")
		cSQL := "SELECT SX5.X5_DESCRI "
		cSQL +=  " FROM " + oSqlHlp:NoLock("SX5") + " "
		cSQL += " WHERE SX5.X5_FILIAL = '" + xFilial("SX5") + "'"
		cSQL +=   " AND SX5.X5_TABELA = 'S0'"
		cSQL +=   " AND SX5.X5_CHAVE = '" + cBx_ORIGEM + "'"
		cSQL +=   " AND SX5.D_E_L_E_T_ = ' '"
		xValue := cBx_ORIGEM + "-" + FM_SQL(cSQL)

	Case aAuxField[2] == "C520GRTRIB"
		cSQL := "SELECT SX5.X5_DESCRI "
		cSQL +=  " FROM " + oSqlHlp:NoLock("SX5") + " "
		cSQL += " WHERE SX5.X5_FILIAL = '" + xFilial("SX5") + "'"
		cSQL +=   " AND SX5.X5_TABELA = '21'"
		cSQL +=   " AND SX5.X5_CHAVE = '" + SB1->B1_GRTRIB + "'"
		cSQL +=   " AND SX5.D_E_L_E_T_ = ' '"
		xValue := SB1->B1_GRTRIB + "-" + FM_SQL(cSQL)

	Case Left(aAuxField[2],3) == "B1_"
		If GetSX3Cache(aAuxField[2],"X3_CONTEXT") == "V"
			xValue := criavar(AllTrim(aAuxField[2]))
		Else		 
			xValue := &("SB1->" + AllTrim(aAuxField[2]))
		Endif
	EndCase

	If xValue <> NIL
		&("M->"+aAuxField[2]) := xValue
	EndIf

Return xValue

/*/{Protheus.doc} OC520ARQPROD
Monta query dependendo da tabela de complemento de produto
@author Rubens
@since 16/08/2017
@version undefined
@param cCodProd, characters, descricao
@param cCampo, characters, descricao
@type function
/*/
Static Function OC520ARQPROD(cCodProd, cCampo)

	Local cSQL

	Do Case
	Case Left(cCampo,2) == "B5"
		cSQL := "SELECT SB5." + cCampo
		cSQL +=  " FROM " + oSqlHlp:NoLock("SB5") + " "
		cSQL += " WHERE SB5.B5_FILIAL = '" + xFilial("SB5") + "'"
		cSQL +=   " AND SB5.B5_COD = '" + cCodProd + "'"
		cSQL +=   " AND SB5.D_E_L_E_T_ = ' '"
	Case Left(cCampo,2) == "BZ"
		cSQL := "SELECT SBZ." + cCampo
		cSQL +=  " FROM " + oSqlHlp:NoLock("SBZ") + " "
		cSQL += " WHERE SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "'"
		cSQL +=   " AND SBZ.BZ_COD = '" + cCodProd + "'"
		cSQL +=   " AND SBZ.D_E_L_E_T_ = ' '"
	End

Return cSQL

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao  |OC520AddField | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC520AddField(aCampos, aParField, cNomeFunc)

	Local nCont
	Local aAuxField

	aParField := {}
	

	Default cNomeFunc := "OC520Field"

	For nCont := 1 to Len(aCampos)

		If aCampos[nCont,3]
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek(aCampos[nCont,1]))
				AADD( aParField , {;
					X3Titulo(),; // 01 - TÌtulo
					IIf( !Empty(aCampos[nCont,2]) , AllTrim(aCampos[nCont,2]) , AllTrim(SX3->X3_CAMPO) ),; // 02 - Campo
					SX3->X3_TIPO,; // 03 - Tipo
					SX3->X3_TAMANHO,; // 04 - Tamanho
					SX3->X3_DECIMAL,; // 05 - Decimal
					SX3->X3_PICTURE,; // 06 - Picture
					"",; // 07 - Valid
					.f.,; // 08 - Obrigat
					1 ,; // 09 - Nivel
					"",; // 10 - Inicializador Padr„o
					SX3->X3_F3,; // 11 - F3
					"",; // 12 - When
					.t.,; // 13 - Visual
					.f.,; // 14 - Chave
					X3CBox(),; // 15 - Box - OpÁ„o do combo
					,; // 16 - Folder (vazio por causa do par‚metro MV_ENCHOLD)
					.t.,; // 17 - N„o Alter·vel
					"",; // 18 - PictVar
					"N"}) // 19 - Gatilho
			EndIf
		Else
			aAuxField := &(cNomeFunc + "('" + aCampos[nCont,1] + "')" )

			AADD( aParField , {;
				aAuxField[MVC_STRUCT_TITULO],; // 01 - TÌtulo
				AllTrim(aAuxField[MVC_STRUCT_ID]),; // 02 - Campo
				aAuxField[MVC_STRUCT_TIPO],; // 03 - Tipo
				aAuxField[MVC_STRUCT_TAM],; // 04 - Tamanho
				aAuxField[MVC_STRUCT_DEC],; // 05 - Decimal
				aAuxField[MVC_STRUCT_PICTURE],; // 06 - Picture
				"",; // 07 - Valid
				aAuxField[MVC_STRUCT_OBRIGAT],; // 08 - Obrigat
				1,; // 09 - Nivel
				"",; // 10 - Inicializador Padr„o
				aAuxField[MVC_STRUCT_F3],; // 11 - F3
				"",; // 12 - When
				!aAuxField[MVC_STRUCT_ALTER],; // 13 - Visual
				.f.,; // 14 - Chave
				aAuxField[MVC_STRUCT_CBOX],; // 15 - Box - OpÁ„o do combo
				,; // 16 - Folder (vazio por causa do par‚metro MV_ENCHOLD)
				!aAuxField[MVC_STRUCT_ALTER],; // 17 - N„o Alter·vel
				"",; // 18 - PictVar
				"N"}) // 19 - Gatilho
		EndIf
	Next nCont

Return aParField

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC520Field | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC520Field(cField)

	Local aRetorno := Array(16)

	aRetorno[MVC_STRUCT_ID       ] := cField
	aRetorno[MVC_STRUCT_DEC      ] := 0
	aRetorno[MVC_STRUCT_OBRIGAT  ] := .F.
	aRetorno[MVC_STRUCT_VIRTUAL  ] := .T.
	aRetorno[MVC_STRUCT_ALTER    ] := .F.

	Do Case
	Case cField == "C520PARFIL"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0005
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0005
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := FWSizeFilial()
		aRetorno[MVC_STRUCT_CBOX     ] := OC520RetFil()
		aRetorno[MVC_STRUCT_OBRIGAT  ] := .T.
		aRetorno[MVC_STRUCT_ALTER    ] := .T.

	Case cField == "C520MSBLQL"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0033
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0033
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := 9

	Case cField == "C520ORIGEM"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0034
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0034
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := 30

	Case cField == "C520GRTRIB"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0035
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0035
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := 20

	Case cField == "C520GRUDES"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0036
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0036
		aRetorno[MVC_STRUCT_TIPO     ] := "C"
		aRetorno[MVC_STRUCT_TAM      ] := 20

	Case cField == "B1_DTREFP1"
		aRetorno[MVC_STRUCT_TITULO   ] := STR0037
		aRetorno[MVC_STRUCT_DESCRICAO] := STR0037

	EndCase

Return aRetorno

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OC520Exec  | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OC520Exec(cAuxRotina)

	Local aParAutoCab := {}
	Local aArea := GetArea()

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + M->P520B1COD))

	nOpc := 2
	Do Case

		Case cAuxRotina == "OFIOC521"
			AADD( aParAutoCab , { "C521PARFIL" , M->P520PARFIL  } )
			AADD( aParAutoCab , { "C521EMPR2"  , FWFilialName() } )
			OFIOC521(.t.,aParAutoCab)

		Case cAuxRotina == "OFIOC150"
			OFIOC150(SB1->B1_GRUPO,SB1->B1_CODITE)

		Case cAuxRotina == "M_LCPCJD"
			U_M_LCPCJD(SB1->B1_COD)

		Otherwise // OFIOC523/524/524/...
			&(cAuxRotina + "(.t.)")

	EndCase

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + M->P520B1COD))

	// Atualiza os controles novamente para garantir que as outras telas nao alteraram variaveis privates ...
	OC520Atu()
	//

	RestArea(aArea)

	Return

/*
================================================================================
################################################################################
##+----------+-------------+-------+-----------------------+------+----------+##
##|Funcao    |OC520CalcSize| Autor | Andre Luis Almeida    | Data | 14/08/15 |##
##+----------+-------------+-------+-----------------------+------+----------+##
##|Descricao | Formatacao da tela.                                           |##
##+----------+---------------------------------------------------------------+##
##|Uso       | Oficina                                                       |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Static Function OC520CalcSize()

	Local aDialSize := FWGetDialogSize()

	oSizePrinc := FwDefSize():New(.t.)
	oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
	If (aDialSize[3] - 300) > 400
		oSizePrinc:AddObject("SUP" , 100 , 150 , .T. , .F. )
		oSizePrinc:AddObject("BOT" , 100 , 100 , .T. , .T. )
	Else
		oSizePrinc:AddObject("SUP" , 100 , 100 , .T. , .T. )
		oSizePrinc:AddObject("BOT" , 100 , 150 , .T. , .F. )
	EndIf
	//oSizePrinc:lLateral := .t.	// Calcula em colunas
	oSizePrinc:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizePrinc:Process()	// Calcula Coordenadas

	oSizeSup := FWDefSize():New(.f.)
	oSizeSup:aWorkArea := oSizePrinc:GetNextCallArea("SUP")
	oSizeSup:aMargins := { 2 , 2 , 2 , 2 }
	oSizeSup:AddObject("PARTE_FILTRO",100,100,.f.,.t.)
	oSizeSup:AddObject("DETALHE"     ,100,100,.t.,.t.)
	oSizeSup:lLateral := .t.	// Calcula em colunas
	oSizeSup:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeSup:Process()

	oSizeFiltro := FWDefSize():New(.f.)
	oSizeFiltro:aWorkArea := oSizeSup:GetNextCallArea("PARTE_FILTRO")
	oSizeFiltro:aMargins := { 0 , 0 , 0 , 0 }
	oSizeFiltro:AddObject("FILTRO"       ,100,100,.t.,.t.)
	oSizeFiltro:AddObject("BTN_ATUALIZA" ,100,011,.t.,.f.)
	oSizeFiltro:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeFiltro:Process()

	oSizeDet := FWDefSize():New(.f.)
	oSizeDet:aWorkArea := oSizePrinc:GetNextCallArea("BOT")
	oSizeDet:aMargins := { 0 , 0 , 0 , 0 }
	oSizeDet:AddObject("L1_L1",100,100,.t.,.t.)
	oSizeDet:AddObject("L1_L2",100,100,.t.,.t.)
	oSizeDet:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeDet:Process()

	oSizeDet1 := FWDefSize():New(.f.)
	oSizeDet1:aWorkArea := oSizeDet:GetNextCallArea("L1_L1")
	oSizeDet1:aMargins := { 2 , 2 , 2 , 2 }
	oSizeDet1:AddObject("ESTOQUE"       ,010,010,.t.,.t.)
	oSizeDet1:AddObject("DEMANDA"       ,010,010,.t.,.t.)
	oSizeDet1:AddObject("BOTOES"        ,045,010,.f.,.t.)
	oSizeDet1:AddObject("TIKS"     ,055,010,.f.,.t.)
	oSizeDet1:AddObject("COMPRA_VENDA",140,010,.f.,.t.)
	oSizeDet1:lLateral := .t.	// Calcula em colunas
	oSizeDet1:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeDet1:Process()

	oSizeDet2 := FWDefSize():New(.f.)
	oSizeDet2:aWorkArea := oSizeDet:GetNextCallArea("L1_L2")
	oSizeDet2:aMargins := { 2 , 2 , 2 , 2 }
	oSizeDet2:AddObject("TAB_PRECO" ,033,010,.t.,.t.)
	oSizeDet2:AddObject("ITENS_REL" ,033,010,.t.,.t.)
	oSizeDet2:AddObject("ITENS_SUB" ,033,010,.t.,.t.)
	oSizeDet2:lLateral := .t.	// Calcula em colunas
	oSizeDet2:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeDet2:Process()

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |OC520RetFil | Autor | Andre Luis Almeida    | Data | 31/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | funcao padrao                                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OC520RetFil(lEmpresa)
	Local aFilAtu    := FWArrFilAtu()
	Local aAuxFilial := FWAllFilial( aFilAtu[SM0_EMPRESA] , aFilAtu[SM0_UNIDNEG] , aFilAtu[SM0_GRPEMP] , .f. )
	//Local aRetorno := {}
	Local cRetorno := ""

	Default lEmpresa := .f.

	aEval(aAuxFilial, { |x| cRetorno += (x + "=" + AllTrim(FWFilialName(, x)) + ";") })
	//aEval(aAuxFilial,{ |x| AADD(aRetorno, (x + "=" + AllTrim(FWFilialName(,x))) ) })

	If lEmpresa .And. Len(aAuxFilial) >= 2
		cRetorno += STR0047 + ";" // TODAS
	EndIf

	cRetorno := Left(cRetorno, Len(cRetorno) - 1)

	//Return aRetorno
Return cRetorno

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
Local aRecebe
Local aRotina:= {}
If FM_PILHA("OFIXC001") .or. Alltrim(GetNewPar("MV_VERIORC","1")) <> "3"
	aRotina := {;
		{ STR0002 , "PesqBrw"     , 0 , 1},; // Pesquisar
		{ STR0003 , "OC520Visual" , 0 , 2} } // Visualizar
Else
	//aRotina := {;
	//	{ STR0002 , "PesqBrw"     , 0 , 1},; // Pesquisar
	//	{ STR0003 , "OC520Visual" , 0 , 2},; // Visualizar
	//	{ STR0038 , "OFIXC009(1)" , 0 , 1},; // Pesquisa por Aplicacao
	//	{ STR0039 , "OA620"		  , 0 , 2} }   // Visualizar Aplicacao
	aRotina := {;
		{ STR0002 , "PesqBrw"     , 0 , 1},; // Pesquisar
		{ STR0003 , "OC520Visual" , 0 , 2},; // Visualizar
		{ STR0039 , "OA620"		  , 0 , 2} }   // Visualizar Aplicacao
EndIf
If ExistBlock("OC520ART")
	aRecebe := ExecBlock("OC520ART",.f.,.f.,{aRotina} )
	If Valtype(aRecebe) == "A"
		aRotina := aClone(aRecebe)
	Endif
Endif

Return aRotina