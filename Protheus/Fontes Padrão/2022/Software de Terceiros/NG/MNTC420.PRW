#INCLUDE "Protheus.ch"
#INCLUDE "FWBrowse.ch"
#INCLUDE "MNTC420.ch"
#INCLUDE "RWMake.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC420
Consulta dos Equipamentos com Menor Disponibilidade.

@author	Elynton Fellipe Bazzo
@since		29/05/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Function MNTC420()

	//------------------------------
	// Armazena as vari�veis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM( )

	// Vari�veis do Dialog
	Private oDlgRank
	Private oPnlRank
	Private aSize := MsAdvSize( .F. ) // .T. - Tem EnchoiceBar

	// Vari�veis PRIVATE
	MNT420VR()

	// F4: Pergunta
	SETKEY( VK_F4, {|| fAskSX1() })

	//--------------------
	// Monta o Dialog
	//--------------------
	DEFINE MSDIALOG oDlgRank TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

		// N�o permite fechar a janela atrav�s da tecla <ESC>
		oDlgRank:lEscClose := .F.

		// Pain�l principal do Dialog
		oPnlRank := TPanel():New(01, 01, , oDlgRank, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlRank:Align := CONTROL_ALIGN_ALLCLIENT

		// Monta o Layout
		oLayerRank := FWLayer():New()
		oLayerRank:Init(oPnlRank, .F.)
		fLayout()

	ACTIVATE MSDIALOG oDlgRank ON INIT ( fAskSX1() ) CENTERED

	//------------------------------
	// Devolve as vari�veis armazenadas
	//------------------------------
	NGRETURNPRM( aNGBEGINPRM )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420VR
Declara as vari�veis Private utilizadas no Pain�l de Indicadores.
* Lembrando que essas vari�veis ficam declaradas somente para a fun��o
que � Pai imediata desta.

@author	Elynton Fellipe Bazzo
@since		29/05/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function MNT420VR()


	//------------------------------
	// Declara Vari�veis PRIVATE
	//------------------------------

	// Vari�vel do Cadastro
	_SetOwnerPrvt( "cCadastro",OemToAnsi( STR0001 )) //"Consulta de Equipamentos com Menor Disponibilidade"

	// Vari�vel da Pergunta
	_SetOwnerPrvt( "cPerg","MNT420" )
	_SetOwnerPrvt( "nQtdEquips",20 )

	// Vari�veis dos Objetos do Layout
	_SetOwnerPrvt( "oLayerRank", Nil ) // FWLayer
	_SetOwnerPrvt( "oPnlLista" , Nil ) // Pain�l da 'Lista' (Janela)
	_SetOwnerPrvt( "oPnlBrowse", Nil ) // Pain�l do objeto do Browse
	_SetOwnerPrvt( "oPnlGrafi" , Nil ) // Pain�l do 'Gr�fico' (Janela)
	_SetOwnerPrvt( "oPnlChart" , Nil ) // Pain�l do objeto do Gr�fico

	// Vari�veis do Browse
	_SetOwnerPrvt( "oRankBrw", Nil )
	_SetOwnerPrvt( "nBrwNUMERO", 1 ) // Posi��o da coluna 'N�mero'
	_SetOwnerPrvt( "nBrwEQUIPA", 2 ) // Posi��o da coluna 'Equipamento'
	_SetOwnerPrvt( "nBrwLOCALI", 3 ) // Posi��o da coluna 'Localiza��o'
	_SetOwnerPrvt( "nBrwDISPON", 4 ) // Posi��o da coluna 'Disponibilidade'
	_SetOwnerPrvt( "nBrwDESCLO", 5 ) // Posi��o da coluna 'Descri��o da Localiza��o'
	_SetOwnerPrvt( "nBrwEXTERN", 6 ) // Posi��o da coluna 'Externo'

	// Vari�vel do Gr�fico
	_SetOwnerPrvt( "oRankGrf", Nil)

	// Vari�vel que indica a M�dia Geral de disponibilidade
	_SetOwnerPrvt( "oMedGeral", Nil )
	_SetOwnerPrvt( "nMedGeral", 0.0 )

	// Vari�vel que indica a Meta de disponibilidade
	_SetOwnerPrvt( "nTotNMeta", 0.0 )
	_SetOwnerPrvt( "oTotNMeta", Nil )
	_SetOwnerPrvt( "nTotPorce", 0.0 )
	_SetOwnerPrvt( "oTotPorce", Nil )
	_SetOwnerPrvt( "\", 0.0 ) // Total de Equipamentos abaixo da meta

	//------------------------------
	// Define conte�dos
	//------------------------------

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLayout
Monta o layout da tela.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fLayout()

	// Linhas
	oLayerRank:AddLine( "Linha_Consulta",100,.F./*lFixed*/ )

	// Colunas
	oLayerRank:AddCollumn( "Coluna_Consulta",100,.F./*lFixed*/,"Linha_Consulta" )

	// Janela da Lista - "Lista dos Equipamentos com Menor Disponibilidade no Per�odo"
	oLayerRank:AddWindow( "Coluna_Consulta", "Janela_Lista", STR0002, 50,;
						.T./*lEnable*/, .F./*lFixed*/, {|| fProcessa(.F.) }/*bAction*/, "Linha_Consulta", /*bGotFocus*/)

	// Janela do Gr�fico - "Gr�fico dos Equipamentos com Menor Disponibilidade no Per�odo"
	oLayerRank:AddWindow( "Coluna_Consulta", "Janela_Grafico",STR0003, 45,;
						.T./*lEnable*/, .F./*lFixed*/, {|| fProcessa(.F.) }/*bAction*//*bAction*/, "Linha_Consulta", /*bGotFocus*/)

	// Objetos
	oPnlLista := oLayerRank:GetWinPanel( "Coluna_Consulta","Janela_Lista"  ,"Linha_Consulta" )
	oPnlGrafi := oLayerRank:GetWinPanel( "Coluna_Consulta","Janela_Grafico","Linha_Consulta" )

	//--- Monta a Consulta
	fMontaCons()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaCons
Monta a Consulta.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fMontaCons()

	// Vari�veis auxiliares
	Local oPnlBrw
	Local oPnlGrf

	//----------
	// Monta
	//----------
	// Pain�l do Browse
	oPnlBrw := TPanel():New(01, 01, , oPnlLista, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlBrw:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlBrw:CoorsUpdate()

	// Monta o Browse
	fMontaBrw( oPnlBrw )

	// Pain�l do Gr�fico
	oPnlGrf := TPanel():New(01, 01, , oPnlGrafi, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlGrf:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlGrf:CoorsUpdate()

	// Monta Gr�fico
	fMontaGrf( oPnlGrf )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaBrw
Monta o Browse.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@param		oObjPai - Indica o Objeto Pai * Obrigat�rio
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fMontaBrw( oObjPai )

	// Vari�veis auxiliares
	Local oPnlPai
	Local oPnlMed

	Local aHeader := {}, nHeader := 0
	Local aColunas := {}, oColuna
	Local cArrTitulo := ""
	Local cArrTipo   := ""
	Local nArrTamanh := 0
	Local nArrDecima := 0
	Local cArrPictur := ""
	Local aBrowse    := {}

	Local oFntPDBold := TFont():New( , , , , .T.)
	
	//--- Cabe�alho do Browse
	aAdd(aHeader, { STR0004, "N", 3, 0, "@E 999"}) // Coluna 1 - "N�mero"
	aAdd(aHeader, { STR0005, "C", TAMSX3("T9_CODBEM")[1], 0, PesqPict("ST9", "T9_CODBEM", )}) // Coluna 2 - "Equipamento"
	aAdd(aHeader, { STR0006, "C", TAMSX3("TC_CODBEM")[1], 0, PesqPict("STC", "TC_CODBEM", )}) // Coluna 3 - "Localiza��o"
	aAdd(aHeader, { STR0007, "N", 10, 0, "@E 999.99"}) // Coluna 4 - "Disponibilidade (%)"
	aAdd(aHeader, { STR0008, "C", TAMSX3("T9_NOME")[1], 0, PesqPict("ST9", "T9_NOME", )}) // Coluna 5 - "Descri��o da Localiza��o"
	aAdd(aHeader, { STR0009, "C", 01, 0, "@!"}) // Coluna 6 - "Externo"

	//----------
	// Monta
	//----------
	// Pain�l pai dos objetos
	oPnlPai := TPanel():New(01, 01, , oObjPai, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlPai:CoorsUpdate()

	// Pain�l do Browse
	oPnlBrowse := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// Browse
	oRankBrw := FWBrowse():New()
	oRankBrw:SetOwner(oPnlBrowse)
	oRankBrw:SetDataArray()

	oRankBrw:SetLocate()
	oRankBrw:SetDelete(.F., {|| .F.})
	oRankBrw:DisableReport()
	oRankBrw:DisableConfig()

	aColunas := {}
	aBrowse  := { Array(Len(aHeader)) }
	For nHeader := 1 To Len(aHeader)
		cArrTitulo := aHeader[nHeader][1]
		cArrTipo   := aHeader[nHeader][2]
		nArrTamanh := aHeader[nHeader][3]
		nArrDecima := aHeader[nHeader][4]
		cArrPictur := aHeader[nHeader][5]

		oColuna := FWBrwColumn():New()
		oColuna:SetAlign( If(cArrTipo == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT) )

		cSetData := "{|oFWBrowse| fBrwSetData(oFWBrowse, " + cValToChar( nHeader ) + " ) }"
		oColuna:SetData( &(cSetData) )

		oColuna:SetEdit( .F. )
		oColuna:SetSize( nArrTamanh + nArrDecima )
		oColuna:SetTitle( cArrTitulo )
		oColuna:SetType( cArrTipo )
		oColuna:SetPicture( cArrPictur )
		oColuna:SetHeaderClick({||  }) // Desabilita o clique no cabe�alho

		aAdd(aColunas, oColuna)

		aBrowse[1][nHeader] := If(cArrTipo == "N", 0, If(cArrTipo == "D", CTOD(""), " "))
	Next nHeader
	oRankBrw:SetColumns(aColunas)
	oRankBrw:Activate()
	oRankBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oRankBrw:SetArray(aBrowse)
	oRankBrw:Refresh()

	// Pain�l da M�dia
	oPnlMed := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 15, .F., .F.)
	oPnlMed:Align := CONTROL_ALIGN_BOTTOM

	// M�dia Geral
	@ 002,010 SAY OemToAnsi( STR0010 ) FONT oFntPDBold OF oPnlMed PIXEL //"M�dia Geral:"
	oMedGeral := TSay():New(002, 050, {|| nMedGeral }, oPnlMed, , , , , ,.T., CLR_BLACK, CLR_WHITE, 150, 010)

	// Total Equipamentos com Menor Disponibilidade
	@ 002,100 SAY OemToAnsi( STR0011 + "     %: " ) FONT oFntPDBold OF oPnlMed PIXEL //"Total de Equipamentos com disponibilidade menor que "
	oTotPorce := TSay():New(002, 254, {|| nTotPorce }, oPnlMed, , , , , ,.T., CLR_BLACK, CLR_WHITE, 150, 010)
	oTotNMeta := TSay():New(002, 275, {|| nTotNMeta }, oPnlMed, , , , , ,.T., CLR_BLACK, CLR_WHITE, 150, 010)

	//"Par�metros"
	oButPart := TButton():New(002, 565, STR0042,oPnlMed,{|| Processa({|| fAskSX1() })}, 50, 12,,,,.T.)

	//"Sair"
	oButEnd  := TButton():New(002, 505, STR0043,oPnlMed,{|| Processa({|| oDlgRank:End() })}, 50, 12,,,,.T.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrwSetData
Seta a data do registro do browse.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@param		oFWBrowse - Indica o objeto do FWBrowse * Obrigat�rio
@param		nHeader - Indica a posi��o do cabe�alho * Obrigat�rio
@return	uSetData
/*/
//---------------------------------------------------------------------
Static Function fBrwSetData( oFWBrowse,nHeader )

	// Vari�veis auxiliares
	Local nAT      := oFWBrowse:AT()
	Local aBrowse  := oFWBrowse:Data():GetArray()
	Local uSetData := Nil

	// Data
	If nAT <= Len(aBrowse)
		uSetData := aBrowse[nAT][nHeader]
	EndIf

Return uSetData

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontaGrf
Monta o Gr�fico.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@param		oObjPai - Indica o Objeto Pai * Obrigat�rio
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fMontaGrf( oObjPai )

	// Vari�veis auxiliares
	Local oPnlPai

	//----------
	// Monta
	//----------
	// Pain�l pai dos objetos
	oPnlPai := TPanel():New(01, 01, , oObjPai, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlPai:CoorsUpdate()

	// Pain�l do Gr�fico
	oPnlChart := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlChart:Align := CONTROL_ALIGN_ALLCLIENT

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAskSX1
Realiza a Pergunta ('Pergunte()').

@author	Elynton Fellipe Bazzo
@since	01/06/2015
@return	.T.
/*/
//---------------------------------------------------------------------
Static Function fAskSX1()

	If Pergunte( cPerg,.T. )
		MsgRun( STR0034,STR0035, {|| fProcessa() }) //"Processando Consulta..." - "Por favor, aguarde..."
	Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420DT
Valida��o da Pergunta: De/At� Data.

@author	Elynton Fellipe Bazzo
@since		29/05/2015
@param		nDeAte - Indica qual � a valida��o: * Obrigat�rio
				1 - Pergunta 'De'
	   			2 - Pergunta 'At�'

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNT420DT( nDeAte )

	// Vari�vel do Retorno
	Local lRetorno := .T.

	//----------
	// Valida
	//----------
	If nDeAte == 1 // 'De'

		If Empty( MV_PAR01 )
			Help( Nil,Nil,STR0032,Nil,STR0036,1,0 ) //"Aten��o" - "A Data Inicial deve ser preenchida."
			lRetorno := .F.
		ElseIf !Empty( MV_PAR02 ) .And. MV_PAR01 > MV_PAR02
			Help( Nil,Nil,STR0032,Nil,STR0037,1,0 ) //"Aten��o" - "A Data Inicial deve ser menor ou igual � Data Final"
			lRetorno := .F.
		EndIf

	ElseIf nDeAte == 2 // 'At�'

		If Empty( MV_PAR02 )
			Help( Nil,Nil,STR0032,Nil,STR0038,1,0 ) //"Aten��o" - "A Data Final deve ser preenchida."
			lRetorno := .F.
		ElseIf MV_PAR02 < MV_PAR01
			Help( Nil,Nil,STR0032,Nil,STR0039,1,0 ) //"Aten��o" - "A Data Final deve ser maior ou igual � Data Inicial"
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420CC
Valida��o da Pergunta: De/At� Centro de Custo.

@author	Elynton Fellipe Bazzo
@since		29/05/2015
@param 		nDeAte - Indica qual � a valida��o: * Obrigat�rio
	   				1 - Pergunta 'De'
	   				2 - Pergunta 'At�'

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNT420CC( nDeAte )

	// Vari�vel do Retorno
	Local lRetorno := .T.

	//----------
	// Valida
	//----------
	If nDeAte == 1 // 'De'

		If !Empty( MV_PAR03 ) .And. !ExistCpo( "CTT", MV_PAR03, 1 )
			lRetorno := .F.
		EndIf

	ElseIf nDeAte == 2 // 'At�'

		If !AteCodigo( "CTT",MV_PAR03,MV_PAR04,TAMSX3( "CTT_CUSTO" )[1] )
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420FA
Valida��o da Pergunta: De/At� Fam�lia.

@author	Elynton Fellipe Bazzo
@since		29/05/2015

@param nDeAte - Indica qual � a valida��o: * Obrigat�rio
	   			1 - Pergunta 'De'
	   			2 - Pergunta 'At�'

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNT420FA( nDeAte )

	// Vari�vel do Retorno
	Local lRetorno := .T.

	//----------
	// Valida
	//----------
	If nDeAte == 1 // 'De'

		If !Empty( MV_PAR05 ) .And. !ExistCpo( "ST6", MV_PAR05, 1 )
			lRetorno := .F.
		EndIf

	ElseIf nDeAte == 2 // 'At�'

		If !AteCodigo( "ST6", MV_PAR05, MV_PAR06, TAMSX3( "T6_CODFAMI" )[1] )
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT420CT
Valida��o da Pergunta: De/At� centro de trabalho.

@author Vitor Bonet
@since 06/09/2018

@param nDeAte - Indica qual � a valida��o: * Obrigat�rio
	   			1 - Pergunta 'De'
	   			2 - Pergunta 'At�'

@return lRetorno
/*/
//---------------------------------------------------------------------
Function MNT420CT( nDeAte )

	// Vari�vel do Retorno
	Local lRetorno := .T.

	//----------
	// Valida
	//----------
	If nDeAte == 1 // 'De'

		If !Empty( MV_PAR05 ) .And. !ExistCpo( "SHB", MV_PAR05, 1 )
			lRetorno := .F.
		EndIf

	ElseIf nDeAte == 2 // 'At�'

		If !AteCodigo( "SHB",MV_PAR05,MV_PAR06 )
			lRetorno := .F.
		EndIf

	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcessa
Processamento da Consulta.

@author	Elynton Fellipe Bazzo
@since		01/06/2015
@param		lProcessa - Indica se deve processar a nova consulta ou apenas
atualizar os objetos * Opcional
	   			.T. - Gera nova consulta
	   			.F. - Apenas atualiza os objetos
				Default: .T.
@return .T.
/*/
//---------------------------------------------------------------------
Static Function fProcessa( lProcessa )

	// Vari�veis de atualiza��o
	Local aFWBrowse := {}, aProcessa := {}, nLen := 0, nX := 0
	Local oFWChart
	Local nSerie
	Local nMTBF := 0
	Local nMTTR := 0

	// Vari�veis da Query
	Local cQryAlias := ""
	Local cQryExec  := ""

	// Vari�veis dos Par�metros SX1
	Local dMV_DeData := If(!Empty( MV_PAR01 ), MV_PAR01, Nil)
	Local dMV_AtData := If(!Empty( MV_PAR02 ), MV_PAR02, Nil)
	Local cMV_DeCCus := If(!Empty( MV_PAR03 ), MV_PAR03, Space(TAMSX3( "CTT_CUSTO" )[1]))
	Local cMV_AtCCus := If(!Empty( MV_PAR04 ), MV_PAR04, Replicate("Z",TAMSX3( "CTT_CUSTO" )[1]))
	Local cMV_ConCal := If(!Empty( MV_PAR07 ), cValToChar( MV_PAR07 ), Nil)
	Local cMV_DeCTra
	Local cMV_AtCTra
	Local cMV_DeFamB
	Local cMV_AtFamB

	// Vari�veis auxiliares
	Local cBemAtu := ""
	Local cBemPai := "", cEmBranco := "-"

	// Verifica a vers�o do Release utilizado.
	Local lRPORel17 := GetRPORelease() <= '12.1.017'

	// Vari�veis para Classe NGKPI
	Local oNGKPI
	Local aParams := {}

	// Defaults
	Default lProcessa := .T.

	If !lRPORel17 // Caso seja uma release maior que 12.1.17
		oNGKPI     := NGKPI():New()
		cMV_DeCTra := If(!Empty( MV_PAR05 ), MV_PAR05, Space(TAMSX3( "HB_COD" )[1]))
		cMV_AtCTra := If(!Empty( MV_PAR06 ), MV_PAR06, Replicate("Z",TAMSX3( "HB_COD" )[1]))
	Else
		cMV_DeFamB := If(!Empty( MV_PAR05 ), MV_PAR05, Space(TAMSX3( "T6_CODFAMI" )[1]))
		cMV_AtFamB := If(!Empty( MV_PAR06 ), MV_PAR06, Replicate("Z",TAMSX3( "T6_CODFAMI" )[1]))
	EndIf

	//----------
	// Processa
	//----------

	If lProcessa
		nMedGeral := 0 // M�dia Geral
		nTotNMeta := 0 // Total abaixo da meta

		// Alias da Query
		cQryAlias := GetNextAlias()

		// SELECT
		cQryExec := "SELECT ST9.T9_CODBEM, ST9.T9_NOME, "
		cQryExec += "	( SELECT COUNT(STJTERC.TJ_TERCEIR) FROM " + RetSQLName( "STJ" ) + " STJTERC "
		cQryExec += "   WHERE STJTERC.TJ_FILIAL = " + ValToSQL( xFilial( "STJ",xFilial( "ST9" ))) + " "
		cQryExec += "	AND STJTERC.TJ_CODBEM = ST9.T9_CODBEM "
		If !Empty( dMV_DeData ) // De Data
			cQryExec += "	AND STJTERC.TJ_DTPRINI >= " + ValToSQL( dMV_DeData ) + " "
		EndIf
		If !Empty( dMV_AtData ) // At� Data
			cQryExec += "	AND STJTERC.TJ_DTPRINI <= " + ValToSQL( dMV_AtData ) + " "
		EndIf
		cQryExec += "	AND STJTERC.TJ_TERCEIR = '2' "
		cQryExec += "	AND STJTERC.D_E_L_E_T_ <> '*' ) AS TERCEIRO "
		// FROM 'ST9'
		cQryExec += "FROM "
		cQryExec += " " + RetSQLName( "ST9" ) + " ST9 "
		// LEFT JOIN 'STJ'
		cQryExec += "LEFT JOIN "
		cQryExec += " " + RetSQLName( "STJ" ) + " STJ ON ( "
		cQryExec += " STJ.TJ_FILIAL = " + ValToSQL( xFilial( "STJ",xFilial( "ST9" ))) + " "
		cQryExec += " AND STJ.TJ_CODBEM = ST9.T9_CODBEM "
		If !Empty(dMV_DeData) // De Data
			cQryExec += " AND STJ.TJ_DTPRINI >= " + ValToSQL( dMV_DeData ) + " "
		EndIf
		If !Empty(dMV_AtData) // At� Data
			cQryExec += " AND STJ.TJ_DTPRINI <= " + ValToSQL( dMV_AtData ) + " "
		EndIf
		cQryExec += " AND STJ.TJ_SITUACA = 'L' AND STJ.TJ_TERMINO = 'S' "
		cQryExec += " AND STJ.D_E_L_E_T_ <> '*' ) "
		// WHERE
		cQryExec += "WHERE ST9.T9_FILIAL = " + ValToSQL( xFilial( "ST9" )) + " "
		If !Empty(cMV_DeCCus) // De Centro de Custo
			cQryExec += " AND ST9.T9_CCUSTO >= " + ValToSQL( cMV_DeCCus ) + " "
		EndIf
		If !Empty(cMV_AtCCus) // At� Centro de Custo
			cQryExec += " AND ST9.T9_CCUSTO <= " + ValToSQL( cMV_AtCCus ) + " "
		EndIf
		If !lRPORel17 // Caso seja uma release maior que 12.1.17
			If !Empty(cMV_DeCTra) // De Centro de Trabalho
				cQryExec += " AND ST9.T9_CENTRAB >= " + ValToSQL( cMV_DeCTra ) + " "
			EndIf
			If !Empty(cMV_AtCTra) // At� Centro de Trabalho
				cQryExec += " AND ST9.T9_CENTRAB <= " + ValToSQL( cMV_AtCTra ) + " "
			EndIf
		Else
			If !Empty(cMV_DeFamB) // De Fam�lia
				cQryExec += " AND ST9.T9_CODFAMI >= " + ValToSQL( cMV_DeFamB ) + " "
			EndIf
			If !Empty(cMV_AtFamB) // At� Fam�lia
				cQryExec += " AND ST9.T9_CODFAMI <= " + ValToSQL( cMV_AtFamB ) + " "
			EndIf
		EndIf
		cQryExec += " AND ST9.D_E_L_E_T_ <> '*' "
		// GROUP BY
		cQryExec += "GROUP BY "
		cQryExec += " ST9.T9_CODBEM, ST9.T9_NOME "
		// ORDER BY
		cQryExec += "ORDER BY "
		cQryExec += " ST9.T9_CODBEM "

		// Verifica a sintaxe da query de acordo com o Banco de Dados
		cQryExec := ChangeQuery( cQryExec )
		// Executa a Query no Banco
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .T., .T.)

		dbSelectArea( cQryAlias )
		dbGoTop()
		While !Eof() //Percorre o la�o de repeti��o

			lProcessa := .T.

			dbSelectArea( "STJ" )
			dbSetOrder( 12 ) //TJ_FILIAL+TJ_TIPOOS+TJ_CODBEM+TJ_TERMINO+DTOS(TJ_DTMRFIM)
			If dbSeek( xFilial( "STJ" ) + "B" + (cQryAlias)->T9_CODBEM + "S" )
				If STJ->TJ_TERMINO <> 'S' //Ordem de Servi�o Terminada
					lProcessa := .F.
				Else
					If dMV_DeData > STJ->TJ_DTPRINI .Or. dMV_AtData < STJ->TJ_DTPRINI //Se estiver fora do per�odo conf. par�metros informados
						lProcessa := .F.
					EndIf
				EndIf
			ElseIf !dbSeek( xFilial( "STJ" ) + "B" + (cQryAlias)->T9_CODBEM + "S" )
				lProcessa := .F.
			EndIf

			If lProcessa
				aAdd( aProcessa,Array( Len( oRankBrw:aColumns )))
				nLen := Len( aProcessa )

				cBemAtu := (cQryAlias)->T9_CODBEM //C�digo do Bem
				aProcessa[nLen][nBrwNUMERO] := 0 //N�mero da posi��o do Bem
				aProcessa[nLen][nBrwEQUIPA] := cBemAtu //C�digo do Bem

				//Localiza��o do pai imediato na estrutura de bens (TC_LOCALIZ);
				aProcessa[nLen][nBrwLOCALI] := AllTrim( Posicione( "STC",3, xFilial( "STC" ) + cBemAtu, "TC_LOCALIZ" ))

				If Empty( aProcessa[nLen][nBrwLOCALI] ) //Se n�o existir Localiza��o;
					aProcessa[nLen][nBrwLOCALI] := cEmBranco //"-"
				EndIf

				If lRPORel17 // Caso seja 12.1.17 ou menor.

					//----------
					// MTBF
					//----------
					nMTBF := 0
					nMTBF := f420MTBF( dMV_DeData,dMV_AtData,cBemAtu,cBemAtu,cMV_DeCCus,cMV_AtCCus,cMV_DeFamB,cMV_AtFamB,cMV_ConCal )

					//----------
					// MTTR
					//----------
					nMTTR := 0
					nMTTR := f420MTTR( dMV_DeData,dMV_AtData,cBemAtu,cBemAtu,cMV_DeCCus,cMV_AtCCus,cMV_DeFamB,cMV_AtFamB,cMV_ConCal )

					//----------------
					// DISPONIBILIDADE
					//-----------------
					aProcessa[nLen,nBrwDISPON] := ( ( nMTBF / ( SomaHoras( nMTBF , nMTTR )  ) ) * 100 )

				Else
					// Utiliza��o da Classe de indicadores NGKPI
					aParams := {{"DE_DATA"   , dMV_DeData},;
								{"ATE_DATA"  , dMV_AtData},;
								{"DE_BEM"    , cBemAtu   },;
								{"ATE_BEM"   , cBemAtu   },;
								{"DE_CCUSTO" , cMV_DeCCus},;
								{"ATE_CCUSTO", cMV_AtCCus},;
								{"DE_CENTRA" , cMV_DeCTra},;
								{"ATE_CENTRA", cMV_AtCTra}}

					// C�lculo do Indicador de disponibilidade
					oNGKPI:setIndParams(aParams) // Carrega os valores para a classe

					aProcessa[nLen,nBrwDISPON] :=  oNGKPI:getKPI("DISP")  // Executa o c�lculo do indicador

					// Exibe Error da Classe se Houver.
					If aProcessa[nLen][nBrwDISPON] == Nil
						oNGKPI:showHelp()
						aProcessa[nLen][nBrwDISPON] := 0
					EndIf

					// Elimina o objeto da mem�ria.
					oNGKPI:Free()

				EndIf

				cBemPai := aProcessa[nLen][nBrwLOCALI] // Pai da Estrutura = Pai Imediato
				If Empty( cBemPai ) .Or. AllTrim( cBemPai ) == cEmBranco
					cBemPai := NGBEMPAI( cBemAtu ) // Pai da Estrutura = Pai da Estrutura
					If Empty( cBemPai )
						cBemPai := cBemAtu // Pai da Estrutura = O Pr�prio Bem
					EndIf
				EndIf

				aProcessa[nLen][nBrwDESCLO] := AllTrim( Posicione( "TPS", 1, xFilial( "TPS" ) + cBemPai, "TPS_NOME" )) //Descri��o Localiza��o
				aProcessa[nLen][nBrwEXTERN] := IIF( (cQryAlias)->TERCEIRO > 0,"X"," " ) //Terceiro

				// J� quantifica a M�dia Geral e tamb�m a Meta
				nMedGeral += aProcessa[nLen][nBrwDISPON]
				If aProcessa[nLen][nBrwDISPON] < MV_PAR09
					nTotNMeta++
				EndIf
			EndIf

			dbSelectArea( cQryAlias )
			dbSkip()
		End While

		// Finaliza o c�lculo da M�dia Geral
		nMedGeral := Round(( nMedGeral / Len( aProcessa )),2 )

		// Ordena por ordem de Menor -> Maior disponibilidade
		aSort(aProcessa, , , {|x,y| Transform(x[nBrwDISPON],"@E 999.99")+x[nBrwEQUIPA] < Transform(y[nBrwDISPON],"@E 999.99")+y[nBrwEQUIPA] })

		If MV_PAR08 == 1
			nQtdEquips := 20 // Quantidade de 20 Equipamentos
		ElseIf MV_PAR08 == 2
			nQtdEquips := 40 // Quantidade de 40 Equipamentos
		ElseIf MV_PAR08 == 3
			nQtdEquips := 60 // Quantidade de 60 Equipamentos
		ElseIf MV_PAR08 == 4
			nQtdEquips := 80 // Quantidade de 80 Equipamentos
		ElseIf MV_PAR08 == 5
			nQtdEquips := 100 // Quantidade de 100 Equipamentos
		EndIf

		// Repassa para o Array do Browse
		For nX := 1 To Len( aProcessa )
			If nX > nQtdEquips
				Exit
			EndIf
			aProcessa[nX][nBrwNUMERO] := nX
			aAdd(aFWBrowse, aClone( aProcessa[nX] ))
		Next nX

		// Seta o Array do Browse
		oRankBrw:SetArray( aFWBrowse )
	EndIf

	// Atualiza a M�dia Geral
	oMedGeral:SetText( cValToChar( nMedGeral ) + "%" )

	// Atualiza a porcentagem de equipamentos com menor disponibilidade
	oTotPorce:SetText( cValToChar( MV_PAR09 ))

	// Atualiza a quantidade de equipamentos, conforme porcentagem informada.
	oTotNMeta:SetText( cValToChar( nTotNMeta ))

	// Atualiza o Browse
	oRankBrw:GoTop()
	oRankBrw:Refresh()
	aFWBrowse := aClone( oRankBrw:Data():GetArray() )

	// Libera os filhos do pain�l do gr�fico e Atualiza o Gr�fico
	oPnlChart:FreeChildren()
	oPnlChart:CoorsUpdate()

	// Monta o Gr�fico
	oFWChart := FWChartFactory():New()
	oRankGrf := oFWChart:GetInstance( BARCHART )
	oRankGrf:Init( oPnlChart,.T.,.T. )
	oRankGrf:SetTitle( STR0040,CONTROL_ALIGN_CENTER ) // "Equipamentos - Rela��o com menor disponibilidade"
	oRankGrf:SetLegend( CONTROL_ALIGN_RIGHT )
	oRankGrf:SetMask( "*@* %" )
	oRankGrf:SetPicture( "@E 999.99" )
	For nSerie := 1 To Len( aFWBrowse )
		oRankGrf:AddSerie( aFWBrowse[nSerie][nBrwEQUIPA],aFWBrowse[nSerie][nBrwDISPON] )
	Next nSerie
	oRankGrf:SetMinY( 0 ) // Valor M�nimo do Eixo Y
	oRankGrf:SetMaxY( 90 ) // Valor M�ximo do Eixo Y (a classe sempre coloca um +10 neste 90, fechando ent�o, 100)
	oRankGrf:Build()

	If Len( aProcessa ) <= 0 // Se n�o possuem registros para gerar a consulta
		Alert( STR0041 ) // Exibe a mensagem: "N�o possuem dados cadastrados para exibir a consulta."
		fAskSX1() // Executa a fun��o que realiza novamente a pergunta ao usu�rio.
	EndIf

Return .T.

//---------------------------------------------------------------------|
/*/{Protheus.doc} f420MTBF
Fun��o que calcula a quantidade de horas - MTBF.

@author	Elynton Fellipe Bazzo
@since		08/06/2015
@return	nHrsParada  - Quantidade de horas
/*/
//---------------------------------------------------------------------|

Static Function f420MTBF( De_Data,Ate_Data,De_Bem,Ate_Bem,De_Ccusto,Ate_Ccusto,De_Fami,Ate_Fami,Con_Calend )

	Local aArea := GetArea()
	Local aVetBem	:= {}
	Local cCalend, lAglut := .F.
	Local nHrsParada := 0, nF := 0, nCo := 0
	Local De_BemL    := IIF( De_Bem = Nil,Space(NGSEEKDIC( "SX3","TJ_CODBEM",2,"X3_TAMANHO" )),De_Bem )
	Local De_CcustoL := IIF( De_Ccusto = Nil,Space(NGSEEKDIC( "SX3","TJ_CCUSTO",2,"X3_TAMANHO" )),De_Ccusto )
	Local dDtPRFim, cHrPRFim

	//1 - Sim   2- N�o
	Default Con_Calend := '2'
	Con_Calend :=If( ValType( Con_Calend ) == "N",cValToChar( Con_Calend ),Con_Calend )

	// De/At� Fam�lia
	Default De_Fami  := Space( TAMSX3( "T9_CODFAMI" )[1] )
	Default Ate_Fami := Replicate( "Z",TAMSX3( "T9_CODFAMI" )[1] )

	cAlia1 := "        "

	If ValType( De_Data ) != "D" .Or. ValType( Ate_Data ) != "D"
		Return 0
	Endif

	//--------------------
	// Query: STJ
	//--------------------
	cQuery := "SELECT TJ_CODBEM,TJ_ORDEM,TJ_PLANO,TJ_DTPRINI,TJ_HOPRINI,TJ_DTPRFIM,TJ_HOPRFIM "
	cQuery += "FROM "+RetSqlName( "STJ" )+" WHERE "
	cQuery += "TJ_FILIAL='"+xFilial( "STJ" )+"' AND TJ_CODBEM >= '"+De_BemL+"' AND "
	If ValType(Ate_Bem) == "C"
		cQuery += "TJ_CODBEM <= '"+Ate_Bem+"' AND "
	Endif
	cQuery += "TJ_CCUSTO >= '"+De_CcustoL+"' AND "
	If ValType(Ate_Ccusto) == "C"
		cQuery += "TJ_CCUSTO <= '"+Ate_Ccusto+"' AND "
	Endif
	cQuery += "TJ_DTPRINI||TJ_HOPRINI <> ' ' AND "
	cQuery += "TJ_SERVICO <> 'MELINV' AND TJ_SERVICO <> 'SERVIC' AND "
	cQuery += "TJ_TIPOOS = 'B'  AND TJ_SITUACA = 'L' AND "
	If ValType(De_Data) == "D"
		cQuery += "TJ_DTPRINI >= '"+Dtos(De_Data)+"' AND "
	Endif
	If ValType(Ate_Data) == "D"
		cQuery += "TJ_DTPRINI <= '"+Dtos(Ate_Data)+"' AND "
	Endif
	cQuery += "D_E_L_E_T_<> '*' "
	cQuery += "ORDER BY TJ_CODBEM,TJ_DTPRINI,TJ_HOPRINI,TJ_DTPRFIM,TJ_HOPRFIM"
	cQuery := ChangeQuery(cQuery)
	cAlia1 := getNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlia1,.T.,.T.)

	dbSelectArea( cAlia1 )
	dbGotop()
	While !(cAlia1)->(Eof())
		dbSelectArea( "ST9" )
		dbSetOrder( 01 )
		dbSeek( xFilial( "ST9" ) + (cAlia1)->TJ_CODBEM )
		If ST9->T9_CODFAMI >= De_Fami .And. ST9->T9_CODFAMI <= Ate_Fami
			dDtPRFim := STOD( (cAlia1)->TJ_DTPRFIM )
			cHrPRFim := (cAlia1)->TJ_HOPRFIM

			// Se a data de PARADA Real Fim estiver em branco, ent�o considera como a data final ('At�') da consulta
			If Empty(dDtPRFim)
				dDtPRFim := Ate_Data
				cHrPRFim := "23:59"
			EndIf

			// Apenas considera caso o Bem n�o tenha sido baixado
			If Empty(ST9->T9_DTBAIXA) .Or. dDtPRFim < ST9->T9_DTBAIXA
				nPos := Ascan(aVetBem,{|x| x[1] == (cAlia1)->TJ_CODBEM})

				Aadd( aVetBem,{ (cAlia1)->TJ_CODBEM,If(nPos == 0,1,aVetBem[nPos][2] + 1),Stod((cAlia1)->TJ_DTPRINI),(cAlia1)->TJ_HOPRINI,;
									dDtPRFim,cHrPRFim,ST9->T9_DTBAIXA })
				If nPos > 0
					aVetBem[nPos][2] := aVetBem[nPos][2] + 1
				EndIf
			EndIf
		EndIf
		(cAlia1)->(Dbskip())
	End While

	dbSelectArea( cAlia1 )
	dbCloseArea()

	//Coloca OS's em fila e aglutina aquelas com intervalo que se interceptam.
	If Len(aVetBem) > 1

		aSort( aVetBem,,, { |x,y| dtos(x[3])+x[4] < dtos(y[3])+y[4] } )

		nF := 1
		For nCo := 1 To ( Len( aVetBem )-1 )

			If aVetBem[nF] == Nil
				nF++
				Loop
			EndIf

		   dDtI := aVetBem[nF][3]
		   cHrI := aVetBem[nF][4]
		   dDtF := aVetBem[nF][5]
		   cHrF := aVetBem[nF][6]

		   dDtIp := aVetBem[nF+1][3]
		   cHrIp := aVetBem[nF+1][4]
		   dDtFp := aVetBem[nF+1][5]
		   cHrFp := aVetBem[nF+1][6]

			If DtoS(dDtIp)+cHrIp >= DtoS(dDtI)+cHrI .And. DtoS(dDtIp)+cHrIp <= DtoS(dDtF)+cHrF

				If DtoS(dDtFp)+cHrFp >= DtoS(dDtF)+cHrF
					aVetBem[nF][5] := dDtFp
					aVetBem[nF][6] := cHrFp
				EndIf

				lAglut := .T.
				aDel(aVetBem,nF+1)

			Else
				nF++
			EndIf
		Next

		If lAglut
			aVetBem := fCopyMat( aVetBem,nF )
		EndIf

	EndIf
	If Len( aVetBem ) = 1

		dDtI := STJ->TJ_DTPRINI
		cHrI := STJ->TJ_HOPRINI
		dDtF := STJ->TJ_DTPRFIM
		cHrF := STJ->TJ_HOPRFIM

		If Con_Calend == '2' //Sem Calend�rio
			nHrsParada += NGCONVERHORA( HtoM( NGCALCHCAR( De_Data,'00:00',dDtI,cHrI )) / 60, "D", "S" ) //calcula tempo corrido
			nHrsParada += NGCONVERHORA( HtoM( NGCALCHCAR( dDtF,cHrF,dDtF,'24:00')) / 60, "D", "S" )
		Else
			cCalend := NGSEEK( "ST9",aVetBem[1][1],1,"T9_CALENDA" ) //calcula tempo baseado em calendario
			nHrsParada += NGCONVERHORA( MNT360CALE( dDtI,'00:00',dDtI,cHrI,cCalend ), "D", "S" )
			nHrsParada += NGCONVERHORA( MNT360CALE( dDtF,cHrF,dDtF,'24:00',cCalend ), "D", "S" )
		EndIf

	Else

		lPrimeiro := .T.
		For nF := 1 To ( Len( aVetBem )-1 )

			cCalend := NGSEEK( "ST9",aVetBem[nF][1],1,"T9_CALENDA" )

			dDtI := aVetBem[nF][3]
			cHrI := aVetBem[nF][4]
			dDtF := aVetBem[nF][5]
			cHrF := aVetBem[nF][6]

			dDtIp := aVetBem[nF+1][3]
			cHrIp := aVetBem[nF+1][4]
			dDtFp := aVetBem[nF+1][5]
			cHrFp := aVetBem[nF+1][6]

			If Con_Calend == '2' //sem calendario
				If lPrimeiro
					nHrsParada += HTON( NGCALCHCAR( De_Data,'00:00',dDtI,cHrI ))
				EndIf
				If !lPrimeiro .Or. nF == ( Len( aVetBem )-1 )
					nHrsParada += HTON( NGCALCHCAR( dDtF,cHrF,dDtIp,cHrIp ))
				EndIf
				If nF == ( Len( aVetBem )-1 )
					nHrsParada += HTON( NGCALCHCAR( dDtFp,cHrFp,dDtFp,'24:00' ))
				ElseIf Len(aVetBem) > nF
					nHrsParada += HTON( NGCALCHCAR( dDtF,cHrFp,dDtFp,"00:00" ))
				EndIf
			Else
				If lPrimeiro
					nHrsParada += MNT360CALE( De_Data,'00:00',dDtI,cHrI,cCalend )
				EndIf
				If !lPrimeiro .Or. nF == ( Len( aVetBem )-1 )
					nHrsParada += MNT360CALE( dDtF,cHrF,dDtIp,cHrIp,cCalend )
				EndIf
				If nF == ( Len( aVetBem )-1 )
					nHrsParada += MNT360CALE( dDtFp,cHrFp,dDtFp,'24:00',cCalend )
				ElseIf Len( aVetBem ) > nF
					nHrsParada += MNT360CALE( dDtF,cHrF,dDtFp,cHrIp,cCalend )
				EndIf
			EndIf

			If lPrimeiro
				lPrimeiro := .F.
			EndIf

		Next nF
	Endif

	RestArea( aArea )

Return nHrsParada

//---------------------------------------------------------------------|
/*/{Protheus.doc} f420MTTR
Fun��o que calcula a quantidade de horas - MTTR.

@author	Elynton Fellipe Bazzo
@since		08/06/2015
@return	nTotRep  - Quantidade de horas
/*/
//---------------------------------------------------------------------|
Static Function f420MTTR( De_Data,Ate_Data,De_Bem,Ate_Bem,De_Ccusto,Ate_Ccusto,De_Fami,Ate_Fami,Con_Calend )

	Local aArea := GetArea()
	Local aVetBem := {}
	Local De_BemL    := IIF(De_Bem = Nil,Space(NGSEEKDIC( "SX3","TJ_CODBEM",2,"X3_TAMANHO" )),De_Bem)
	Local De_CcustoL := IIF(De_Ccusto = Nil,Space(NGSEEKDIC( "SX3","TJ_CCUSTO",2,"X3_TAMANHO" )),De_Ccusto)
	Local nF,nCo, cAliasQry, lAglut := .F.
	Local dDtI, cHrI, dDtF, cHrF
	Local dDtIp, cHrIp, dDtFp, cHrFp
	Local dDtPRFim, cHrPRFim

	//1 - Sim   2- N�o
	Default Con_Calend := '2'
	Con_Calend :=If(ValType(Con_Calend)=="N",cValToChar(Con_Calend),Con_Calend)

	// De/At� Fam�lia
	Default De_Fami  := Space(TAMSX3("T9_CODFAMI")[1])
	Default Ate_Fami := Replicate("Z",TAMSX3("T9_CODFAMI")[1])

	cAliasQry := GetNextAlias()
	cQuery := " SELECT TJ_CODBEM,TJ_ORDEM,TJ_DTPRINI,TJ_HOPRINI,TJ_DTPRFIM,TJ_HOPRFIM "
	cQuery += " FROM "+RetSqlName( "STJ" )+" STJ "
	cQuery += " WHERE TJ_FILIAL = '"+xFilial( "STJ" )+"' AND "
	cQuery += " TJ_DTPRINI||TJ_HOPRINI <> ' ' AND "
	cQuery += " TJ_SERVICO <> 'MELINV' AND TJ_SERVICO <> 'SERVIC' AND "
	cQuery += " TJ_SITUACA = 'L' AND TJ_TIPOOS = 'B' AND "

	If ValType( De_BemL ) == "C" .And. ValType( Ate_Bem ) == "C"
		cQuery += " TJ_CODBEM >= '"+De_BemL+"' AND TJ_CODBEM <= '"+Ate_Bem+"' AND "
	Endif

	If ValType( De_CcustoL ) == "C" .and. ValType(Ate_Ccusto) == "C"
		cQuery += " TJ_CCUSTO >= '"+De_CcustoL+"' AND TJ_CCUSTO <= '"+Ate_Ccusto+"' AND "
	Endif
	If ValType( De_Data ) == "D" .and. ValType( Ate_Data ) == "D"
		cQuery += " TJ_DTPRINI >= '"+Dtos( De_Data )+"' AND TJ_DTPRINI <= '"+Dtos( Ate_Data )+"' AND "
	Endif
	cQuery += " D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While !(cAliasQry)->(Eof())
		dbSelectArea( "ST9" )
		dbSetOrder( 01 )
		dbSeek( xFilial( "ST9" ) + (cAliasQry)->TJ_CODBEM )
		If ST9->T9_CODFAMI >= De_Fami .And. ST9->T9_CODFAMI <= Ate_Fami

			dDtPRFim := STOD( (cAliasQry)->TJ_DTPRFIM ) //Data Parada Real In�cio
			cHrPRFim := (cAliasQry)->TJ_HOPRFIM //Hora Parada Real In�cio

			// Se a data de PARADA Real Fim estiver em branco, ent�o considera como a data final ('At�') da consulta
			If Empty( dDtPRFim )
				dDtPRFim := Ate_Data
				cHrPRFim := "23:59"
			EndIf

			// Apenas considera caso o Bem n�o tenha sido baixado
			If Empty( ST9->T9_DTBAIXA ) .Or. dDtPRFim < ST9->T9_DTBAIXA
				Aadd( aVetBem,{ (cAliasQry)->TJ_CODBEM,(cAliasQry)->TJ_ORDEM,Stod((cAliasQry)->TJ_DTPRINI),(cAliasQry)->TJ_HOPRINI,dDtPRFim,cHrPRFim })
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	If Len( aVetBem ) > 1

		aSort( aVetBem,,, { |x,y| dtos(x[3])+x[4] < dtos(y[3])+x[4] } )

		nF := 1
		For nCo := 1 To ( Len( aVetBem )-1 )

			If aVetBem[nF] == Nil
				nF++
				Loop
			EndIf

			dDtI := aVetBem[nF][3]
			cHrI := aVetBem[nF][4]
			dDtF := aVetBem[nF][5]
			cHrF := aVetBem[nF][6]

			dDtIp := aVetBem[nF+1][3]
			cHrIp := aVetBem[nF+1][4]
			dDtFp := aVetBem[nF+1][5]
			cHrFp := aVetBem[nF+1][6]

			If DtoS(dDtIp)+cHrIp >= DtoS(dDtI)+cHrI .And. DtoS(dDtIp)+cHrIp <= DtoS(dDtF)+cHrF

				If DtoS(dDtFp)+cHrFp >= DtoS(dDtF)+cHrF
					aVetBem[nF][5] := dDtFp
					aVetBem[nF][6] := cHrFp
				EndIf

				lAglut := .T.
				aDel( aVetBem,nF+1 )

			Else
				nF++
			EndIf

		Next

		If lAglut
			aVetBem := fCopyMat( aVetBem,nF )
		EndIf

	EndIf

	nF := 0
	For nCo := 1 to Len( aVetBem )

		dDtI := aVetBem[nCo][3]
		cHrI := aVetBem[nCo][4]
		dDtF := aVetBem[nCo][5]
		cHrF := aVetBem[nCo][6]

		If Con_Calend == '2'
	     	nF += NGCONVERHORA( HtoM(NGCALCHCAR( dDtI,cHrI,dDtF,cHrF )) / 60, "D", "S" ) //calcula tempo corrido
		Else
		   	cCalend := NGSEEK( "ST9",aVetBem[nCo][1],1,"T9_CALENDA" ) //calcula tempo baseado em calendario
		   	nF += NGCONVERHORA( MNT360CALE( dDtI,cHrI,dDtF,cHrF,cCalend ), "D", "S" )
	   	EndIf

	Next

	RestArea( aArea )

Return nF

//---------------------------------------------------------------------|
/*/{Protheus.doc} fCopyMat
Fun��o que realiza a c�pia de uma matriz.

@author	Elynton Fellipe Bazzo
@since		09/06/2015
@return	aAux
/*/
//---------------------------------------------------------------------|
Static Function fCopyMat( aMat,nFim )

	Local aAux
	Local nX, nY

	aAux := Array( nFim,6 )

	For nX := 1 To nFim
		For nY:=1 To 6
		    aAux[nX][nY] := aMat[nX][nY]
		Next
	Next

Return aAux
