#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'DBTREE.CH'
#INCLUDE 'PCPC101.CH'
//-----------------------------------------------------------------
/*/{Protheus.doc} PCPC101
Consulta da Ficha técnica.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-----------------------------------------------------------------
Function PCPC101()
	Local aButtons   := {}

	Private oBitMemo := LoadBitmap(GetResources(),'bmpvisual16')
	Private oBitImag := LoadBitmap(GetResources(),'image_lupa')
	Private oBitNada := LoadBitmap(nil,'4')
	Private oTree
	Private oGroup

	Private lAlrChg := .F.

	Private aAux		:= {}
	Private cBrowse   := ""
	Private cBrowseAux := ""

	Private aTamanhos	:= FWGetDialogSize(oMainwnd)
	Private oDlg1		:= NIL
	Private oTemplate, oVersao, oTempDes, oData
	Private cTemplate, cVersao, cTempDes, dData
	Private aColumns

	Private oPnlTop
	Private oBrowseSB1, oBrowseSH1, oBrowseSxS, oBrowseCZL, oBrowseCxC
	Private oPanelSB1,  oPanelSH1,  oPanelSxS,  oPanelCZL,  oPanelCxC
	Private oBrowseDow
	Private oFiltrar
	Private cPergSX1

	Private oFontN

	//Array Auxiliar
	//Descrição da Coluna - Tamanho da Coluna - Conteúdo da Coluna
	Private aColumnsGI := { ;
		{STR0014, 40,{|| {"", aAtributos[nX][3]} },"LEFT","" }, ; //"Atributo"
		{STR0015, 100, {|| {"", aAtributos[nX][1]} },"LEFT","" }, ; //"Descrição"
		{STR0016, 60, {|| { "MV_TIPO", aAtributos[nX][2] } },"LEFT","" }, ; //"Tipo"
		{STR0017, 200, {|| {"MV_CONTEUDO", cConteudo} },"LEFT","" }, ; //"Conteúdo"
		{'', 10, {|| { "LEGENDA", aAtributos[nX][2] } },"LEFT","" } }
	oBitNada:CNAME := "" //Apenas para nao aparecer nada TWBrowse

	Default lAutoMacao := .F.

	DEFINE Font oFontN Name "Arial" Size 07,16

	IF !lAutoMacao
		oDlg1 := MSDialog():New( aTamanhos[1],aTamanhos[2],aTamanhos[3],aTamanhos[4],STR0024,,,.F.,,,,,,.T.,,,.T. ) //"Consulta Ficha Técnica"
		oPnlPai := TPanel():New(01,01,,oDlg1,,,,,,,,.T.,.T.)
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		//Inicia o Layer   1
		//Cria o layer pelo metodo construtor
		oLayer := FWLayer():New()

		//Inicia o 1o Layer
		oLayer:Init(oPnlPai,.T.)

		//Cria as colunas do Layer
		oLayer:addCollumn("ColunaTree",22,.F.)
		oLayer:addCollumn("ColunaDado",78,.F.)

		//Adiciona Janelas as colunas
		oLayer:addWindow("ColunaTree",'C1_Win01',STR0044,97,.T.,.F.,{|| },,{|| }) //"Templates"
		oLayer:addWindow("ColunaDado",'C1_Win01',STR0045,48.5,.T.,.F.,{|| },,{|| }) //"Ficha Técnica"
		oLayer:addWindow("ColunaDado",'C1_Win02',STR0042,48.5,.T.,.T.,{|| },,{|| }) //"Atributos"

		//Atribui a janela da Tree
		oPnlTree := oLayer:getWinPanel("ColunaTree",'C1_Win01')
		oLayer:setColSplit("ColunaTree",CONTROL_ALIGN_RIGHT,,{|| })
		//Atribui a janela dos dados superiores
		oPnlAux1 := oLayer:getWinPanel("ColunaDado",'C1_Win01')

			oPnlFiltro := TPanel():New(01,01,,oPnlAux1,,,,,,10,aTamanhos[3]*0.02,.F.,.T.)
			oPnlFiltro:Align := CONTROL_ALIGN_TOP

				oPnlTop := TPanel():New(0,0,,oPnlAux1,,,,,,10,aTamanhos[3]*0.23,.F.,.T.)
				oPnlTop:Align := CONTROL_ALIGN_ALLCLIENT

					oPanelSB1 := TPanel():New(01,01,,oPnlTop,,,,,,,,.F.,.T.)
					oPanelSB1:Align := CONTROL_ALIGN_ALLCLIENT
					oPanelSH1 := TPanel():New(01,01,,oPnlTop,,,,,,,,.F.,.T.)
					oPanelSH1:Align := CONTROL_ALIGN_ALLCLIENT
					oPanelSxS := TPanel():New(01,01,,oPnlTop,,,,,,,,.F.,.T.)
					oPanelSxS:Align := CONTROL_ALIGN_ALLCLIENT
					oPanelCZL := TPanel():New(01,01,,oPnlTop,,,,,,,,.F.,.T.)
					oPanelCZL:Align := CONTROL_ALIGN_ALLCLIENT
					oPanelCxC := TPanel():New(01,01,,oPnlTop,,,,,,,,.F.,.T.)
					oPanelCxC:Align := CONTROL_ALIGN_ALLCLIENT

		//Atribui a janela dos dados inferiores
		oPnlAux2 := oLayer:getWinPanel("ColunaDado",'C1_Win02')

		oPnlBottom := TPanel():New(01,01,,oPnlAux2,,,,,,10,aTamanhos[3]*0.2,.F.,.T.)//Tamanho da janela //TODO
		oPnlBottom:Align := CONTROL_ALIGN_ALLCLIENT

		oPnlCenter := TPanel():New(01,01,,oPnlAux2,,,,,,10,aTamanhos[3]*0.05,.F.,.F.)//Tamanho da janela //TODO
		oPnlCenter:Align := CONTROL_ALIGN_TOP

		CriaBotoes()
		ChangeBox()

		InfTemplat()

		CriaTree()
		If !Empty(cBrowse) .AND. ValType(oTree) = "O"
			Eval(oTree:bChange)
		EndIf

		aAdd(aButtons,{'FILTRO',{|| consProdt()},STR0056}) //'Produtos relacionados'
		aAdd(aButtons,{'FILTRO',{|| openCadFT()},"Cadastro"}) //

		ACTIVATE MSDIALOG oDlg1 On Init EnchoiceBar(oDlg1,{|| oDlg1:End()},{|| oDlg1:End()},,aButtons) CENTERED
	ENDIF
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeBox
Função disparada na troca do ListBox

@param lParamSX1 Indica se devera executar o filtro (botao Filtrar) ou nao.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ChangeBox(lParamSX1)

	//Array Auxiliar
	//Descrição da Coluna - Tamanho da Coluna - Conteúdo da Coluna
	Local lTab
	Default lParamSX1 := .f.
	Default lAutoMacao := .F.
	aColumns := {}

	IF !lAutoMacao
		If ValType(oTree) = "O"
			oTree:Reset()
		EndIf

		oFiltrar:lVisible := .t.
	ENDIF

	Do Case
		Case cBrowse == ""
			cPergSX1 := ""
			oFiltrar:lVisible := .f.
		Case cBrowse == STR0001 //"Produto"
			cPergSX1 := "PCPC101A"
			aColumns := { ;
							{STR0029, 100,{|| (cAliasQry)->B1_COD},"LEFT","" },; //"Código do produto"
							{STR0030, 100,{|| (cAliasQry)->B1_DESC},"LEFT","" },; //"Descrição do produto"
							{STR0031, 100,{|| (cAliasQry)->B1_TIPO},"LEFT","" },; //"Tipo produto"
							{STR0032, 100,{|| (cAliasQry)->B1_GRUPO},"LEFT","" },; //"Grupo produto"
							{STR0033, 100,{|| (cAliasQry)->B1_UM},"LEFT","" }} //"Unidade de medida"
			lTab := "SB1"
			GridTop("S",lTab,aColumns,@oBrowseSB1,lParamSX1)
			GridAtrib(@oBrowseSB1)
		Case cBrowse == STR0002 //"Recurso"
			cPergSX1 := "PCPC101B"
			aColumns := { ;
							{STR0034, 100,{|| (cAliasQry)->H1_CODIGO},"LEFT","" },; //"Código do recurso"
							{STR0035, 100,{|| (cAliasQry)->H1_DESCRI},"LEFT","" },; //"Descrição do recurso"
							{STR0036, 100,{|| (cAliasQry)->H1_CCUSTO},"LEFT","" },; //"Centro de custo"
							{STR0037, 100,{|| (cAliasQry)->H1_CTRAB},"LEFT","" }} //"Centro de trabalho"
			lTab := "SH1"
			GridTop("S",lTab,aColumns,@oBrowseSH1,lParamSX1)
			GridAtrib(@oBrowseSH1)
		Case cBrowse == STR0003 //"Produto x Recurso"
			cPergSX1 := "PCPC101C"
			aColumns := { ;
							{STR0029, 100,{|| (cAliasQry)->B1_COD},"LEFT","" },; //"Código do produto"
							{STR0030, 100,{|| (cAliasQry)->B1_DESC},"LEFT","" },; //"Descrição do produto"
							{STR0031, 100,{|| (cAliasQry)->B1_TIPO},"LEFT","" },; //"Tipo produto"
							{STR0032, 100,{|| (cAliasQry)->B1_GRUPO},"LEFT","" },; //"Grupo produto"
							{STR0033, 100,{|| (cAliasQry)->B1_UM},"LEFT","" },; //"Unidade de medida"
							{STR0034, 100,{|| (cAliasQry)->H1_CODIGO},"LEFT","" },; //"Código do recurso"
							{STR0035, 100,{|| (cAliasQry)->H1_DESCRI},"LEFT","" },; //"Descrição do recurso"
							{STR0036, 100,{|| (cAliasQry)->H1_CCUSTO},"LEFT","" },; //"Centro de custo"
							{STR0037, 100,{|| (cAliasQry)->H1_CTRAB},"LEFT","" }} //"Centro de trabalho"
			lTab := "SB1xSH1"
			GridTop("S",lTab,aColumns,@oBrowseSxS,lParamSX1)
			GridAtrib(@oBrowseSxS)
		Case cBrowse == STR0025 //"Família Técnica"
			cPergSX1 := "PCPC101D"
			aColumns := { ;
							{STR0038, 100,{|| (cAliasQry)->CZL_CDFATD},"LEFT","" },; //"Código da família técnica"
							{STR0039, 100,{|| (cAliasQry)->CZL_DSFATD},"LEFT","" }} //"Descrição da família técnica"
			lTab := "CZL"
			GridTop("S",lTab,aColumns,@oBrowseCZL,lParamSX1)
			GridAtrib(@oBrowseCZL)
		Case cBrowse == STR0026 //"Família Técnica x Recurso"
			cPergSX1 := "PCPC101E"
			aColumns := { ;
							{STR0038, 100,{|| (cAliasQry)->CZG_CDFATD},"LEFT","" },; //"Código da família técnica"
							{STR0039, 100,{|| (cAliasQry)->CZL_DSFATD},"LEFT","" },; //"Descrição da família técnica"
							{STR0034, 100,{|| (cAliasQry)->H1_CODIGO},"LEFT","" },; //"Código do recurso"
							{STR0035, 100,{|| (cAliasQry)->H1_DESCRI},"LEFT","" },; //"Descrição do recurso"
							{STR0036, 100,{|| (cAliasQry)->H1_CCUSTO},"LEFT","" },; //"Centro de custo"
							{STR0037, 100,{|| (cAliasQry)->H1_CTRAB},"LEFT","" }} //"Centro de trabalho"
			lTab := "CxC"
			GridTop("S",lTab,aColumns,@oBrowseCxC,lParamSX1)
			GridAtrib(@oBrowseCxC)
	EndCase

	IF !lAutoMacao
		If !Empty(cBrowse) .AND. ValType(oTree) = "O"
			Eval(oTree:bChange)
		EndIf
	ENDIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GridAtrib
Cria o Grid de Atributos (grid inferior)

@param oBrowseTop Referencia do Browse pai/superior

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GridAtrib(oBrowseTop)

	GridTop("I","CZG",aColumnsGI,@oBrowseTop,.f.)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} InfTemplat
Cria a parte da tela que ficam as informacoes do template selecionado na Tree

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function InfTemplat()
//TODO
@ 003,08 SAY STR0022 SIZE 30, 30 Font oFontN OF oPnlCenter PIXEL //"Template"
@ 001,40 MSGET oTemplate VAR cTemplate Font oFontN WHEN .F. SIZE 40,10 OF oPnlCenter PIXEL

@ 018,08 SAY "Descrição do " +  STR0022 SIZE 70, 30 Font oFontN OF oPnlCenter PIXEL //"Descrição do Template"
@ 016,80 MSGET oTempDes VAR cTempDes Font oFontN WHEN .F. SIZE 120,10 OF oPnlCenter PIXEL

@ 003,93 SAY STR0023 SIZE 30, 30 Font oFontN OF oPnlCenter PIXEL //"Versão"
@ 001,119 MSGET oVersao VAR cVersao Font oFontN WHEN .F. SIZE 40,10 OF oPnlCenter PIXEL

@ 003,172 SAY STR0040 SIZE 45, 30 Font oFontN OF oPnlCenter PIXEL //"Data da Ficha"
@ 001,218 MSGET oData VAR dData Font oFontN Picture '99/99/9999' WHEN .F. SIZE 40,10 OF oPnlCenter PIXEL
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} GridTop
Cria o Grid superior

@param cType Indica se ira criar o grid superior ou inferior.
@param cTabela Indica a tabela que sera exibida no grid superior.
@param aColumns Relacao das colunas que serao criadas na grid.
@param oBrowseTop Referencia do Browse pai/superior.
@param lParamSX1 Indica se devera executar o filtro (botao Filtrar) ou nao.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GridTop(cType,cTabela,aColumns,oBrowseTop,lParamSX1)

	Local cQuery := ""
	Local nI
	Local nJ := 0

	Local aHeader := {}
	Local aLength := {}
	Local aCols
	Default lAutoMacao := .F.

	For nI := 1 to Len(aColumns)
		aAdd(aHeader,aColumns[nI][1])
		aAdd(aLength,aColumns[nI][2])
	Next

	aColunas := Array(Len(aColumns))

	If cTabela == "CZG"
		nJ := 0
	Else
		cAliasQry := GetNextAlias()
		Do Case
			//PRODUTOS
			Case cTabela == "SB1"
				cQuery += "SELECT "
				cQuery += "  DISTINCT SB1.B1_COD, "
				cQuery += "           SB1.B1_DESC, "
				cQuery += "           SB1.B1_TIPO, "
				cQuery += "           SB1.B1_GRUPO, "
				cQuery += "           SB1.B1_UM "
				cQuery += "FROM " + RetSQLName( 'SB1' ) + " SB1 "
				cQuery += "  INNER JOIN " + RetSQLName( 'CZG' ) + " CZG ON CZG.CZG_CDAC = SB1.B1_COD "
				cQuery += "    AND CZG.CZG_CDRC   = ' ' "
				cQuery += "    AND CZG.CZG_CDFATD = ' ' "
				cQuery += "    AND CZG.D_E_L_E_T_ = ' ' "
				cQuery += "    AND CZG.CZG_FILIAL = '"+xFilial("CZG")+"'"
				cQuery += "WHERE SB1.D_E_L_E_T_ = ' ' "
				cQuery += "  AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
				If lParamSX1
					cQuery += " AND SB1.B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
					cQuery += " AND SB1.B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
					cQuery += " AND SB1.B1_TIPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
				EndIf
				cQuery += "ORDER BY SB1.B1_DESC "

			//RECURSOS
			Case cTabela == "SH1"
				cQuery += "SELECT "
				cQuery += "  DISTINCT SH1.H1_CODIGO, "
				cQuery += "           SH1.H1_DESCRI, "
				cQuery += "           SH1.H1_CCUSTO, "
				cQuery += "           SH1.H1_CTRAB "
				cQuery += "FROM " + RetSQLName( 'SH1' ) + " SH1 "
				cQuery += "  INNER JOIN " + RetSQLName( 'CZG' ) + " CZG ON CZG.CZG_CDRC = SH1.H1_CODIGO "
				cQuery += "    AND CZG.CZG_CDAC   = ' ' "
				cQuery += "    AND CZG.CZG_CDFATD = ' ' "
				cQuery += "    AND CZG.D_E_L_E_T_ = ' ' "
				cQuery += "    AND CZG.CZG_FILIAL = '"+xFilial("CZG")+"'"
				cQuery += "WHERE SH1.D_E_L_E_T_ = ' ' "
				cQuery += "  AND SH1.H1_FILIAL = '"+xFilial("SH1")+"'"
				If lParamSX1
					cQuery += " AND SH1.H1_CODIGO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
				EndIf
				cQuery += "ORDER BY SH1.H1_DESCRI "

			//PRODUTOS X RECURSOS
			Case cTabela == "SB1xSH1"
				cQuery += "SELECT DISTINCT(SB1.B1_COD+SH1.H1_CODIGO), "
				cQuery += "  SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_GRUPO, SB1.B1_UM, SH1.H1_CODIGO, SH1.H1_DESCRI, SH1.H1_CCUSTO, SH1.H1_CTRAB "
				cQuery += "FROM " + RetSQLName( 'CZG' ) + " CZG "
				cQuery += "  INNER JOIN " + RetSQLName( 'SB1' ) + " SB1 ON CZG.CZG_CDAC = SB1.B1_COD "
				cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += "    AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
				If lParamSX1
					cQuery += " AND   SB1.B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
					cQuery += " AND   SB1.B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
					cQuery += " AND   SB1.B1_TIPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'"
				EndIf
				cQuery += "  INNER JOIN " + RetSQLName( 'SH1' ) + " SH1 ON CZG.CZG_CDRC = SH1.H1_CODIGO "
				cQuery += "    AND SH1.D_E_L_E_T_ = ' ' "
				cQuery += "    AND SH1.H1_FILIAL = '"+xFilial("SH1")+"'"
				If lParamSX1
					cQuery += " AND SH1.H1_CODIGO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
				EndIf
				cQuery += "WHERE CZG.D_E_L_E_T_ = ' ' "
				cQuery += "  AND CZG.CZG_FILIAL = '"+xFilial("CZG")+"'"

			//FAMILIA TECNICA
			Case cTabela == "CZL"
				cQuery += "SELECT "
				cQuery += "  DISTINCT CZL.CZL_CDFATD, "
				cQuery += "           CZL.CZL_DSFATD "
				cQuery += "FROM " + RetSQLName( 'CZL' ) + " CZL "
				cQuery += "  INNER JOIN " + RetSQLName( 'CZG' ) + " CZG ON CZG.CZG_CDFATD = CZL.CZL_CDFATD "
				cQuery += "    AND CZG.CZG_CDAC   = ' ' "
				cQuery += "    AND CZG.CZG_CDRC   = ' ' "
				cQuery += "    AND CZG.D_E_L_E_T_ = ' ' "
				cQuery += "    AND CZG.CZG_FILIAL = '"+xFilial("CZG")+"'"
				cQuery += "WHERE CZL.D_E_L_E_T_ = ' ' "
				cQuery += "  AND CZL.CZL_FILIAL = '"+xFilial("CZL")+"'"
				If lParamSX1
					cQuery += " AND CZL.CZL_CDFATD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
				EndIf
				cQuery += "ORDER BY CZL.CZL_DSFATD "

			//FAMILIA TECNICA x RECURSOS
			Case cTabela == "CxC"
				cQuery += "SELECT DISTINCT(CZG.CZG_CDFATD+SH1.H1_CODIGO), "
				cQuery += "  CZG.CZG_CDFATD, CZL.CZL_DSFATD, SH1.H1_CODIGO, SH1.H1_DESCRI, SH1.H1_CCUSTO, SH1.H1_CTRAB "
				cQuery += "FROM " + RetSQLName( 'CZG' ) + " CZG "
				cQuery += "  INNER JOIN " + RetSQLName( 'CZL' ) + " CZL ON CZG.CZG_CDFATD = CZL.CZL_CDFATD "
				cQuery += "    AND CZL.D_E_L_E_T_ = ' ' "
				cQuery += "    AND CZL.CZL_FILIAL = '"+xFilial("CZL")+"'"
				cQuery += "  INNER JOIN " + RetSQLName( 'SH1' ) + " SH1 ON CZG.CZG_CDRC = SH1.H1_CODIGO "
				cQuery += "    AND SH1.D_E_L_E_T_ = ' ' "
				cQuery += "    AND SH1.H1_FILIAL = '"+xFilial("SH1")+"'"
				If lParamSX1
					cQuery += " AND SH1.H1_CODIGO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
				EndIf
				cQuery += "WHERE CZG.D_E_L_E_T_ = ' ' "
				cQuery += "  AND CZG.CZG_FILIAL = '"+xFilial("CZG")+"'"
				If lParamSX1
					cQuery += " AND CZG.CZG_CDFATD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
				EndIf

		EndCase
		cQuery := ChangeQuery(cQuery)
		If cTabela <> "CZG"
			dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			(cAliasQry)->(dbGotop())
			While !(cAliasQry)->(Eof())
				nJ++
				(cAliasQry)->(dbSkip())
			End

			If nJ != 0
				aCols = Array( nJ )

				nJ := 1
				(cAliasQry)->(dbGotop())
				While !(cAliasQry)->(Eof())
					aCols[nJ] = {}
					For nI := 1 to Len(aColumns)
						aAdd(aCols[nJ], Eval(aColumns[nI][3]))
					Next
					nJ++
					(cAliasQry)->(dbSkip())
				End
				cBrowseAux := cBrowse
			Else
				MsgStop(STR0041) //"Não existem dados para serem exibidos!"
				cBrowseAux := ''
			EndIf
		Else
			//FICHAS TECNICAS
			If cTabela == "CZG"
				nJ := 0
			EndIf
		EndIf
	EndIf

	If nJ == 0
		aCols := Array(1)

		For nI := 1 to Len(aColumns)
			aColunas[nI] := ''
		Next
		aCols[1] := aColunas
	EndIf

	If cType <> "I" //Nao pode limpar o array quando for construir o grid debaixo
		(cAliasQry)->(dbCloseArea())
		aAux := {}
	Else
		aCols[1][5] := .f.
		aAdd(aAux,{aHeader,aLength,aCols})
	EndIf
	aAdd(aAux,{aHeader,aLength,aCols})

	If cType == 'S'
		If cTabela == 'SB1'
			IF !lAutoMacao
				CriaArray(cType,aAux,cTabela,@oBrowseSB1,@oPanelSB1)
			ENDIF
		ElseIf cTabela == 'SH1'
			CriaArray(cType,aAux,cTabela,@oBrowseSH1,@oPanelSH1)
		ElseIf cTabela == "SB1xSH1"
			CriaArray(cType,aAux,cTabela,@oBrowseSxS,@oPanelSxS)
		ElseIf cTabela == "CZL"
			CriaArray(cType,aAux,cTabela,@oBrowseCZL,@oPanelCZL)
		ElseIf cTabela == "CxC"
			CriaArray(cType,aAux,cTabela,@oBrowseCxC,@oPanelCxC)
		EndIf
	Else
		IF !lAutoMacao
			CriaArray(cType,aAux,cTabela,@oBrowseSB1,@oPanelCxC)
		ENDIF
	EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} CriaArray
Cria o objeto/grid (inferior ou superior)

@param cType Indica se ira criar o grid superior ou inferior.
@param aAux Relacao das colunas que serao criadas na grid.
@param cTabela Indica a tabela que sera exibida no grid superior.
@param _oBrowse Referencia do Browse pai/superior.
@param _oPanel Referencia do Panel no qual sera criado o grid.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaArray(cType,aAux,cTabela,_oBrowse,_oPanel)
	Local nX, aGridBaixo := {}

	If cType == "S"

   	If ValType(_oBrowse) <> "O"
			_oBrowse := TCBrowse():New(0,0,260,156,,aAux[1][1],aAux[1][2],_oPanel,,,,,{||},,,,,,,.F.,,.F.,,.F.,,, )
			_oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			_oBrowse:bGotFocus  := {|| LoadTree()}
			_oBrowse:bChange    := {|| LoadTree()}
		Else
			_oBrowse:aARRAY    := {}
			_oBrowse:aCOLUMNS  := {}
			_oBrowse:aCOLSIZES := {}
		EndIf
		For nX := 1 to Len(aColumns)
			_oBrowse:AddColumn(TCColumn():New(aColumns[nX][1],&("{|| If(Len(_oBrowse:aArray) >= _oBrowse:nAt,_oBrowse:aArray[_oBrowse:nAt,"+cValToChar(nX)+"],'') }"),;
														 aColumns[nX][5],,,aColumns[nX][4],aColumns[nX][2],.F.,.F.,,,,.F.))
		Next nX
		_oBrowse:SetArray(aAux[1][3])
		_oBrowse:bLine := { || aAux[1][3][_oBrowse:nAT] }
		_oBrowse:Refresh()

		HideRefre(@_oPanel)

	ElseIf cType == "I"
		IF ValType(oBrowseDow) <> "O"
			//aGridBaixo := aAux[2][3]
			oBrowseDow := TWBrowse():New(0,0,0,0,,aAux[2][1],aAux[2][2],oPnlBottom,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
			oBrowseDow:bldblclick := {|| MemImgAfas() }
			oBrowseDow:Align := CONTROL_ALIGN_ALLCLIENT
		Else
			oBrowseDow:aARRAY    := {}
			oBrowseDow:aCOLUMNS  := {}
			oBrowseDow:aCOLSIZES := {}
		EndIf
		For nX := 1 to Len(aColumnsGI)
			If nX == Len(aColumnsGI)
				oBrowseDow:AddColumn(TCColumn():New(" ",{|| If( oBrowseDow:aArray[oBrowseDow:nAt,3] == STR0012 .OR.;
																						 oBrowseDow:aArray[oBrowseDow:nAt,3] == STR0046, oBitMemo,;
																						 If( oBrowseDow:aArray[oBrowseDow:nAt,3] == STR0009, oBitImag , oBitNada ) )},;
   											         nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
			Else
				oBrowseDow:AddColumn(TCColumn():New(aColumnsGI[nX][1],&("{|| If(Len(oBrowseDow:aArray) >= oBrowseDow:nAt,oBrowseDow:aArray[oBrowseDow:nAt,"+cValToChar(nX)+"],'') }"),;
															 aColumnsGI[nX][5],,,aColumnsGI[nX][4],aColumnsGI[nX][2],.F.,.F.,,,,.F.))
			Endif
		Next nX
		oBrowseDow:SetArray(aAux[2][3])
		oBrowseDow:bLine := { || aAux[2][3][oBrowseDow:nAT] }
		oBrowseDow:Refresh()
	EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MemImgAfas
Cria a tela que ira exibir o campo memo, imagem ou afastamento.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MemImgAfas()

	Local oDlgAux,oMemo, cMemo
	Local cTipoAtrib
	Local cDescricao
	Local nAltura, nLargura
	Local nAfastInf, nAfastSup

	If Empty(SubStr(oBrowseDow:AARRAY[oBrowseDow:nAT][3],1,1))
		Return .t.
	EndIf
	cTipoAtrib := oBrowseDow:AARRAY[oBrowseDow:nAT][3]
	If cTipoAtrib == STR0046 //Tolerância
		cTipoAtrib := 'T'
	ElseIf cTipoAtrib == STR0012 //Memo
		cTipoAtrib := 'M'
	ElseIf cTipoAtrib == STR0009 //Imagem
		cTipoAtrib := 'I'
	EndIf
	cDescricao := IF(cTipoAtrib=='M',STR0027,'')

	If cTipoAtrib == 'M' .OR. cTipoAtrib == 'I' .OR. cTipoAtrib == 'T'
		If cTipoAtrib = 'M'
			nAltura  := 450
			nLargura := 770
		ElseIf cTipoAtrib = 'T'
			nAltura  := 450
			nLargura := 580
		ElseIf cTipoAtrib = 'I'
			nAltura  := 600
			nLargura := 650
		EndIf

		Define MsDialog oDlgAux Title cDescricao From 300,120 TO nAltura,nLargura Of oMainWnd Pixel COLOR CLR_BLACK //"Observação"
			@ 20,08 Say cDescricao Of oDlgAux Font oFontN Pixel //"Observação"

			If cTipoAtrib == 'M'
				cMemo := oBrowseDow:AARRAY[oBrowseDow:nAT][4]
				@ 20,48 GET oMemo Var cMemo MEMO Font oFontN SIZE 270,40 MEMO of oDlgAux READONLY PIXEL
			ElseIf cTipoAtrib == 'I'
				oScroll := TScrollBox():Create(oDlgAux,01,01,oDlgAux:nWidth-20,oDlgAux:nHeight-20,.T.,.T.,.T.)
				oScroll:Align := CONTROL_ALIGN_ALLCLIENT
				@ 01,01 REPOSITORY oBitPro SIZE 70,70 OF oScroll PIXEL NOBORDER WHEN .F.
				oBitPro:Align := CONTROL_ALIGN_ALLCLIENT
				ShowBitMap(oBitPro,oBrowseDow:AARRAY[oBrowseDow:nAT][4],"SEMFOTO")
				oBitPro:lStretch     := .T.
				oBitPro:lAutosize    := .T.
				oBitPro:Refresh()
			ElseIf cTipoAtrib == 'T'
				aAfast := {}
				cTemplate	:= SubStr(oTree:GetPrompt(),1,At('-',oTree:GetPrompt())-1)
				cTempDes	:= POSICIONE( "CZD", 1, xFilial("CZD")+ cTemplate, "CZD_NMMD" )
				cVersao	:= oTree:GetCargo()

				If oPanelSB1:lVisible
					cProduto := oBrowseSB1:AARRAY[oBrowseSB1:nAt][1]
					aAfast := ValorAfast(cProduto,'','',cTemplate,cVersao)
				ElseIf oPanelSH1:lVisible
					cRecurso := oBrowseSH1:AARRAY[oBrowseSH1:nAt][1]
					aAfast := ValorAfast('',cRecurso,'',cTemplate,cVersao)
				ElseIf oPanelSxS:lVisible
					cProduto := oBrowseSxS:AARRAY[oBrowseSxS:nAt][1]
					cRecurso := oBrowseSxS:AARRAY[oBrowseSxS:nAt][6]
					aAfast := ValorAfast(cProduto,cRecurso,'',cTemplate,cVersao)
				ElseIf oPanelCZL:lVisible
					cFamilia := oBrowseCZL:AARRAY[oBrowseCZL:nAt][1]
					aAfast := ValorAfast('','',cFamilia,cTemplate,cVersao)
				ElseIf oPanelCxC:lVisible
					cFamilia := oBrowseCxC:AARRAY[oBrowseCxC:nAt][1]
					cRecurso := oBrowseCxC:AARRAY[oBrowseCxC:nAt][3]
					aAfast := ValorAfast('',cRecurso,cFamilia,cTemplate,cVersao)
				EndIf

				@ 010,010 SAY STR0047 SIZE 60, 7 OF oDlgAux PIXEL //"Afastamento Inferior"
				@ 010,130 MSGET aAfast[1][1] SIZE 60,11 Picture '@E 99,999,999.9999' OF oDlgAux PIXEL WHEN .F. HASBUTTON
				@ 030,010 SAY STR0049 SIZE 60, 7 OF oDlgAux PIXEL //"Valor Base"
				@ 030,130 MSGET oBrowseDow:AARRAY[oBrowseDow:nAT][4] SIZE 60,11 Picture '@E 99,999,999.9999' OF oDlgAux PIXEL WHEN .F. HASBUTTON
				@ 050,010 SAY STR0048 SIZE 60, 7 OF oDlgAux PIXEL //"Afastamento Superior"
				@ 050,130 MSGET aAfast[1][2] SIZE 60,11 Picture '@E 99,999,999.9999' OF oDlgAux PIXEL WHEN .F. HASBUTTON

			EndIf
			@ 022,070 Button "&OK" Size 30,10
		Activate MsDialog oDlgAux Centered
	EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTree
Cria a Tree.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaTree()

	oTree := DbTree():New( 0, 0, (aTamanhos[3]/2), ((aTamanhos[4]/2)*0.2), oPnlTree , , , .T. )

	oTree:Align    := CONTROL_ALIGN_ALLCLIENT
	oTree:bChange := {|| ChangeTree()}

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} CriaBotoes
Cria os botoes.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaBotoes(oPanel)

	Local aPesquisa := {"",STR0001,STR0002,STR0003,STR0025,STR0026} //"Produto"##"Recurso"##"Produto x Recurso"##"Família Técnica"##"Família Técnica x Recurso"

	@ 2,08 Say OemtoAnsi(STR0028) of oPnlFiltro Font oFontN Pixel //"Pesquisar por:"
	@ 1,60 Combobox cBrowse Items aPesquisa Font oFontN Size 100,7 OF oPnlFiltro Pixel On Change (ChangeBox())

	oFiltrar := TBtnBmp2():New( 2,350,60,22,'brw_filtro',,,,{|| FiltroSX1()},oPnlFiltro,STR0043,,.T. ) //"Filtrar"
	cCss := "QPushButton{ border-radius: 3px;border: 1px solid #000000; font-size: 13px; background-color: #F0F0F0;  }"
	oFiltrar:SetCss(cCSS)
	oFiltrar:lVisible := .f.

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} FiltroSX1
Filtro do SX1, referente ao grid superior.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FiltroSX1()

	Local aOldArea := GetArea()

	If cBrowse <> ""
		If Pergunte(cPergSX1,.T.)
			ChangeBox(.t.)
		EndIf
	EndIf

	RestArea(aOldArea)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTree
Carrega/Recarrega a Tree no evento OnChange da mesma.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadTree()

	Local cQuery := ""
	Local nI
	Default lAutoMacao := .F.

	If lAlrChg .AND. Len(aAux) > 0

		IF !lAutoMacao
			oTree:BeginUpdate()
			oTree:Reset()

			oTree:AddTree(STR0022+Space(10),.T.,'FOLDER13','FOLDER13',,,"node-template") //"Template"
		ENDIF

			cAliasQry := GetNextAlias()
			cQuery += "SELECT DISTINCT "
			cQuery += "  CZG.CZG_VRFH VERSAO, "
			cQuery += "  CZG.CZG_CDMD TEMPLAT "
			cQuery += "FROM " + RetSQLName( 'CZG' ) + " CZG "
			cQuery += "WHERE CZG.D_E_L_E_T_ = ' ' "
			IF !lAutoMacao
				If oPanelSB1:lVisible
					cQuery += "  AND CZG.CZG_CDAC = '" + oBrowseSB1:AARRAY[oBrowseSB1:nAt][1] + "' "
					cQuery += "  AND CZG.CZG_CDRC   = ' ' "
					cQuery += "  AND CZG.CZG_CDFATD = ' ' "
				ElseIf oPanelSH1:lVisible
					cQuery += "  AND CZG.CZG_CDRC = '" + oBrowseSH1:AARRAY[oBrowseSH1:nAt][1] + "' "
					cQuery += "  AND CZG.CZG_CDAC   = ' ' "
					cQuery += "  AND CZG.CZG_CDFATD = ' ' "
				ElseIf oPanelSxS:lVisible
					cQuery += "  AND CZG.CZG_CDAC = '" + oBrowseSxS:AARRAY[oBrowseSxS:nAt][1] + "' "
					cQuery += "  AND CZG.CZG_CDRC = '" + oBrowseSxS:AARRAY[oBrowseSxS:nAt][6] + "' "
				ElseIf oPanelCZL:lVisible
					cQuery += "  AND CZG.CZG_CDFATD = '" + oBrowseCZL:AARRAY[oBrowseCZL:nAt][1] + "' "
					cQuery += "  AND CZG.CZG_CDAC   = ' ' "
					cQuery += "  AND CZG.CZG_CDRC   = ' ' "
				ElseIf oPanelCxC:lVisible
					cQuery += "  AND CZG.CZG_CDFATD = '" + oBrowseCxC:AARRAY[oBrowseCxC:nAt][1] + "' "
					cQuery += "  AND CZG.CZG_CDRC =   '" + oBrowseCxC:AARRAY[oBrowseCxC:nAt][3] + "' "
				EndIf
			ENDIF
			cQuery += "  AND CZG.CZG_FILIAL = '"+xFilial("CZG")+"'"
			cQuery += "  ORDER BY CZG.CZG_CDMD "
			dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )

			(cAliasQry)->(dbGotop())
			While !(cAliasQry)->(Eof())
				IF !lAutoMacao	
					oTree:AddTreeItem((AllTrim((cAliasQry)->TEMPLAT) + ' - ' + AllTrim((cAliasQry)->VERSAO)),'PMSDOC',,(cAliasQry)->VERSAO)
				ENDIF
				(cAliasQry)->(dbSkip())
			End
			(cAliasQry)->(dbCloseArea())

		IF !lAutoMacao	
			oTree:EndTree()

			oTree:EndUpdate()

			oTree:PTRefresh()

			LimpaGets()
		ENDIF

		aAux[2][3] := {{}}

		For nI := 1 to Len(aColumnsGI)
			aAdd(aAux[2][3][1],'')
		Next

		IF !lAutoMacao
			oBrowseDow:SetArray(aAux[2][3])
			oBrowseDow:bLine := { || aAux[2][3][oBrowseDow:nAT] }
			oBrowseDow:Refresh()
		ENDIF
	EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeTree
Carrega/Recarrega a Tree de acordo com selecao no Grid superior.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ChangeTree()

	Local nI := 0
	Local nJ := 0
	Local nX := 0
	Local Temp := {}
	Local cQuery := ""
	Local cConteudo := ""
	Local aAtributos := {}

	If ValType(oBrowseDow) <> "O"
		Return Nil
	EndIf

	If !lAlrChg .Or. oTree:GetCargo() = "node-template"
		lAlrChg := .T.

		LimpaGets()

		aAux[2][3] := {{}}

		For nI := 1 to Len(aColumnsGI)
			aAdd(aAux[2][3][1],'')
		Next

		oBrowseDow:SetArray(aAux[2][3])
		oBrowseDow:bLine := { || aAux[2][3][oBrowseDow:nAT] }
		oBrowseDow:Refresh()

	Else

		cTemplate	:= SubStr(oTree:GetPrompt(),1,At('-',oTree:GetPrompt())-1)
		cTempDes	:= POSICIONE( "CZD", 1, xFilial("CZD")+ cTemplate, "CZD_NMMD" )
		cVersao	:= oTree:GetCargo()

		If oPanelSB1:lVisible
			cProduto := oBrowseSB1:AARRAY[oBrowseSB1:nAt][1]
			aAtributos := PCPC101TVA(cProduto,'','',cTemplate,cVersao)
		ElseIf oPanelSH1:lVisible
			cRecurso := oBrowseSH1:AARRAY[oBrowseSH1:nAt][1]
			aAtributos := PCPC101TVA('',cRecurso,'',cTemplate,cVersao)
		ElseIf oPanelSxS:lVisible
			cProduto := oBrowseSxS:AARRAY[oBrowseSxS:nAt][1]
			cRecurso := oBrowseSxS:AARRAY[oBrowseSxS:nAt][6]
			aAtributos := PCPC101TVA(cProduto,cRecurso,'',cTemplate,cVersao)
		ElseIf oPanelCZL:lVisible
			cFamilia := oBrowseCZL:AARRAY[oBrowseCZL:nAt][1]
			aAtributos := PCPC101TVA('','',cFamilia,cTemplate,cVersao)
		ElseIf oPanelCxC:lVisible
			cFamilia := oBrowseCxC:AARRAY[oBrowseCxC:nAt][1]
			cRecurso := oBrowseCxC:AARRAY[oBrowseCxC:nAt][3]
			aAtributos := PCPC101TVA('',cRecurso,cFamilia,cTemplate,cVersao)
		EndIf

		aCols = Array( Len(aAtributos) )

		nJ := 1

		For nX := 1 to Len(aAtributos)
			aCols[nJ] = {}
			For nI := 1 to Len(aColumnsGI)

				Temp := Eval(aColumnsGI[nI][3])
				If Temp[1] == "MV_TIPO"
					Do Case
						Case Temp[2] == "F"
							Temp[2] := STR0004
						Case Temp[2] == "C"
							Temp[2] := STR0005
						Case Temp[2] == "N"
							Temp[2] := STR0006
						Case Temp[2] == "D"
							Temp[2] := STR0007
						Case Temp[2] == "L"
							Temp[2] := STR0008
						Case Temp[2] == "I"
							Temp[2] := STR0009
						Case Temp[2] == "A"
							Temp[2] := STR0010
						Case Temp[2] == "R"
							Temp[2] := STR0011
						Case Temp[2] == "M"
							Temp[2] := STR0012
						Case Temp[2] == "T"
							Temp[2] := STR0013
						Case Temp[2] == "O"
							Temp[2] := STR0046 //"Tolerância"
					EndCase
					cConteudo := aAtributos[nX][5]
					aAdd(aCols[nJ],Temp[2])
					aAdd(aCols[nJ],cConteudo)
				ElseIf Temp[1] == "LEGENDA"
					If Temp[2] == 'M' .OR. Temp[2] == 'O'
						aAdd(aCols[nJ],oBitMemo)
					ElseIf Temp[2] == 'I'
						aAdd(aCols[nJ],oBitImag)
					Else
						aAdd(aCols[nJ],oBitNada)
					EndIf
				ElseIf Temp[1] != "MV_CONTEUDO"
					aAdd(aCols[nJ],Temp[2])
				EndIf
			Next
			nJ++

			dData := DTOC(STOD(aAtributos[nX][4]))
			oData:CtrlRefresh()

		Next nX

		oTemplate:CtrlRefresh()
		oTempDes:CtrlRefresh()

		cVersao := oTree:GetCargo()
		oVersao:CtrlRefresh()

		aAux[2][3] := {}
		aAux[2][3] := aClone(aCols)

		oBrowseDow:SetArray(aAux[2][3])
		oBrowseDow:bLine := { || aAux[2][3][oBrowseDow:nAT] }
		oBrowseDow:Refresh()

	EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} HideRefre
Esconde todos os Panels da tela e exibe apenas o selecionado.

@param _oPanel Referencia do Panel no qual sera criado o grid.
admin
@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function HideRefre(_oPanel)

oPanelSB1:Hide()
oPanelSB1:Refresh()
oPanelSH1:Hide()
oPanelSH1:Refresh()
oPanelSxS:Hide()
oPanelSxS:Refresh()
oPanelCZL:Hide()
oPanelCZL:Refresh()
oPanelCxC:Hide()
oPanelCxC:Refresh()

_oPanel:Show()
_oPanel:Refresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaGets
Limpa todos os componentes Gets da tela.

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LimpaGets()

	cTemplate := ""
	oTemplate:CtrlRefresh()
	
	cTempDes := ""
	oTempDes:CtrlRefresh()

	cVersao := ""
	cBrowseAux := ""
	
	oVersao:CtrlRefresh()

	dData := "  /  /  "
	oData:CtrlRefresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ValorAfast
Retorna Afastamento Inferior/Superior

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValorAfast(cProduto,cRecurso,cFamilia,cTemplate,cVersao)
Local aRetorno := {}
Default lAutoMacao := .F.

	cAliasQry := GetNextAlias()
	cQuery := "SELECT CZG.CZG_AFINF, CZG.CZG_AFSUP "
	cQuery += "FROM " + RetSQLName( 'CZG' ) + " CZG "
	cQuery += " WHERE CZG.D_E_L_E_T_ = ' '"
	If !Empty(cProduto) .AND. !Empty(cRecurso)
		cQuery += "  AND CZG.CZG_CDAC = '" + cProduto + "' "
		cQuery += "  AND CZG.CZG_CDRC = '" + cRecurso + "' "
	ElseIf !Empty(cFamilia) .AND. !Empty(cRecurso)
		cQuery += "  AND CZG.CZG_CDFATD = '" + cFamilia + "' "
		cQuery += "  AND CZG.CZG_CDRC = '" + cRecurso + "' "
	ElseIf !Empty(cProduto)
		cQuery += "  AND CZG.CZG_CDAC   = '" + cProduto + "' "
		cQuery += "  AND CZG.CZG_CDRC   = ' ' "
		cQuery += "  AND CZG.CZG_CDFATD = ' ' "
	ElseIf !Empty(cRecurso)
		cQuery += "  AND CZG.CZG_CDRC   = '" + cRecurso + "' "
		cQuery += "  AND CZG.CZG_CDAC   = ' ' "
		cQuery += "  AND CZG.CZG_CDFATD = ' ' "
	ElseIf !Empty(cFamilia)
		cQuery += "  AND CZG.CZG_CDFATD = '" + cFamilia + "' "
		cQuery += "  AND CZG.CZG_CDAC   = ' ' "
		cQuery += "  AND CZG.CZG_CDRC   = ' ' "
	EndIf
	cQuery += "  AND CZG.CZG_FILIAL = '"+xFilial("CZG")+"'"
	cQuery += "  AND CZG.CZG_CDMD   = '" + cTemplate + "' "
	IF !lAutoMacao
		cQuery += "  AND CZG.CZG_CDAB   = '" + oBrowseDow:AARRAY[oBrowseDow:nAT][1] + "' "
	ENDIF
	If !Empty(cVersao)
		cQuery += "  AND CZG.CZG_VRFH   = '" + cVersao + "' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )
	(cAliasQry)->(dbGotop())
	If !(cAliasQry)->(Eof())
		AADD(aRetorno,{(cAliasQry)->CZG_AFINF,(cAliasQry)->CZG_AFSUP})
	Else
		AADD(aRetorno,{0,0})
	End

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPC101TVA
Carrega

@author Marcos Wagner Junior
@since 24/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPC101TVA(cProduto,cRecurso,cFamilia,cTemplate,cVersao)
Local aRetorno := {}
Local nRecno	:= 0
Local aArea   := {}
	cAliasQry := GetNextAlias()
	cQuery := "SELECT "
	cQuery += "  CZB.CZB_DSAB CZG_DSAB, CZB.CZB_TPAB CZG_TPAB, CZG.CZG_CDAB, CZG.CZG_CDMD, "
	cQuery += "  CZG.CZG_VLFG, CZG.CZG_VLCHAR,CZG.CZG_VLNR,CZG.CZG_VLDT,CZG.CZG_VLLST,CZG.CZG_BITMAP, "
	cQuery += "  CZG.CZG_VLFX,CZG.CZG_VLFO,CZG.CZG_VLTB,CZG.CZG_DTFH, CZG.CZG_VRFH, "
	//cQuery += "  ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),CZG_VLMEMO)),'') AS CZG_VLMEMO "
	cQuery += "  CZG.R_E_C_N_O_ "
	cQuery += "FROM " + RetSQLName( 'CZG' ) + " CZG "
	cQuery += "  INNER JOIN " + RetSQLName( 'CZB' ) + " CZB ON CZB.CZB_CDAB = CZG.CZG_CDAB "
	cQuery += "    AND CZB.CZB_FILIAL = '"+xFilial("CZB")+"'"
	cQuery += "    AND CZB.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CZG.D_E_L_E_T_ = ' '"
	If !Empty(cProduto) .AND. !Empty(cRecurso)
		cQuery += "  AND CZG.CZG_CDAC = '" + cProduto + "' "
		cQuery += "  AND CZG.CZG_CDRC = '" + cRecurso + "' "
	ElseIf !Empty(cFamilia) .AND. !Empty(cRecurso)
		cQuery += "  AND CZG.CZG_CDFATD = '" + cFamilia + "' "
		cQuery += "  AND CZG.CZG_CDRC = '" + cRecurso + "' "
	ElseIf !Empty(cProduto)
		cQuery += "  AND CZG.CZG_CDAC   = '" + cProduto + "' "
		cQuery += "  AND CZG.CZG_CDRC   = ' ' "
		cQuery += "  AND CZG.CZG_CDFATD = ' ' "
	ElseIf !Empty(cRecurso)
		cQuery += "  AND CZG.CZG_CDRC   = '" + cRecurso + "' "
		cQuery += "  AND CZG.CZG_CDAC   = ' ' "
		cQuery += "  AND CZG.CZG_CDFATD = ' ' "
	ElseIf !Empty(cFamilia)
		cQuery += "  AND CZG.CZG_CDFATD = '" + cFamilia + "' "
		cQuery += "  AND CZG.CZG_CDAC   = ' ' "
		cQuery += "  AND CZG.CZG_CDRC   = ' ' "
	EndIf
	cQuery += "  AND CZG.CZG_FILIAL = '"+xFilial("CZG")+"'"
	cQuery += "  AND CZG.CZG_CDMD   = '" + cTemplate + "' "
	If !Empty(cVersao)
		cQuery += "  AND CZG.CZG_VRFH   = '" + cVersao + "' "
	EndIf
	cQuery += " ORDER BY CZG.CZG_SQAB, CZG.CZG_CDAB"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )
	(cAliasQry)->(dbGotop())
	While !(cAliasQry)->(Eof())
		Do Case
			Case (cAliasQry)->CZG_TPAB == "F"
				cConteudo := (cAliasQry)->CZG_VLFG
				If AllTrim(cConteudo) == "1"
					cConteudo := STR0050
				Else
					cConteudo := STR0051
				EndIf
			Case (cAliasQry)->CZG_TPAB == "C"
				cConteudo := (cAliasQry)->CZG_VLCHAR
			Case (cAliasQry)->CZG_TPAB == "N"
				cConteudo := Str((cAliasQry)->CZG_VLNR)
			Case (cAliasQry)->CZG_TPAB == "D"
				cConteudo := DTOC(STOD((cAliasQry)->CZG_VLDT))
			Case (cAliasQry)->CZG_TPAB == "L"
				cConteudo := (cAliasQry)->CZG_VLLST
			Case (cAliasQry)->CZG_TPAB == "I"
				cConteudo := (cAliasQry)->CZG_BITMAP
			Case (cAliasQry)->CZG_TPAB == "A"
				cConteudo := Str((cAliasQry)->CZG_VLFX)
			Case (cAliasQry)->CZG_TPAB == "R"
				cConteudo := Str((cAliasQry)->CZG_VLNR)
			Case (cAliasQry)->CZG_TPAB == "M"
				aArea := GetArea()
				nRecno := (cAliasQry)->R_E_C_N_O_
				dbSelectArea("CZG")
				CZG->(dbSetOrder(1))
				CZG->(dbGoTo(nRecno))
				//cConteudo := (cAliasQry)->CZG_VLMEMO
				cConteudo := CZG->CZG_VLMEMO
				RestArea(aArea)
			Case (cAliasQry)->CZG_TPAB == "T"
				cConteudo := (cAliasQry)->CZG_VLTB
			Case (cAliasQry)->CZG_TPAB == "O"
				cConteudo := (cAliasQry)->CZG_VLNR
		EndCase
		AADD(aRetorno,{(cAliasQry)->CZG_DSAB,;
								(cAliasQry)->CZG_TPAB,;
								(cAliasQry)->CZG_CDAB,;
								(cAliasQry)->CZG_DTFH,;
								cConteudo,;
								(cAliasQry)->CZG_VRFH})
		(cAliasQry)->(dbSkip())
	End

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} consProdt
Consulta os produtos relacionados à ficha técnica consultada.

@author Lucas Konrad França
@since 05/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function consProdt()
	Local cFTec     := ""
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local aArea     := GetArea()
	Local aDados    := {}
	Local aCampos   := {}
	Local aSizes    := {}
	Local oPanel, oDlgPrd, oBrwPrd
	Default lAutoMacao := .F.

	If AllTrim(cBrowse) == AllTrim(STR0025) .Or. AllTrim(cBrowse) == AllTrim(STR0026)
		IF !lAutoMacao
			If AllTrim(cBrowse) == AllTrim(STR0025)
				cFTec := oBrowseCZL:AARRAY[oBrowseCZL:nAt][1]
			Else
				cFTec := oBrowseCxC:AARRAY[oBrowseCxC:nAt][1]
			EndIf

			If Empty(cFTec)
				MsgStop(STR0055) //"Nenhuma família técnica selecionada."
				Return .F.
			EndIf
		ENDIF

		cQuery := " SELECT SB5.B5_COD, "
		cQuery +=        " SB1.B1_DESC "
		cQuery +=   " FROM " + RetSqlName("SB1") + " SB1, "
		cQuery +=              RetSqlName("SB5") + " SB5 "
		cQuery +=  " WHERE SB5.B5_FILIAL  = '" + xFilial("SB5") + "' "
		cQuery +=    " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQuery +=    " AND SB5.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SB5.B5_COD     = SB1.B1_COD "
		cQuery +=    " AND SB5.B5_CDFATD  = '" + cFTec + "' "
		cQuery +=  " ORDER BY 1 "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .T. )

		While (cAliasQry)->(!Eof())
			aAdd(aDados,{(cAliasQry)->(B5_COD), (cAliasQry)->(B1_DESC)})
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
		
		IF !lAutoMacao
			If Len(aDados) >= 1
				DEFINE MSDIALOG oDlgPrd TITLE STR0054 + AllTrim(cFTec) FROM 0,0 TO 350,800 PIXEL //"Produtos relacionados a família técnica XX"

				oPanel := tPanel():Create(oDlgPrd,01,01,,,,,,,401,156)
				//Cria o array dos campos para o browse
				aCampos := {STR0001,STR0015} //"Produto", "Descrição"
				aSizes  := {140, 200}

				// Cria Browse
				oBrwPrd := TCBrowse():New( 0 , 0, 400, 155,,;
											aCampos,aSizes,;
											oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
				// Seta vetor para a browse
				oBrwPrd:SetArray(aDados)
				oBrwPrd:bLine := {||{ aDados[oBrwPrd:nAT,1],;
										aDados[oBrwPrd:nAt,2]}}
				oPanel:Refresh()
				oPanel:Show()

				DEFINE SBUTTON FROM 160,373 TYPE 1 ACTION (oDlgPrd:End()) ENABLE OF oDlgPrd
				ACTIVATE DIALOG oDlgPrd CENTERED
			Else
				MsgStop(STR0053) //"Não existem produtos relacionados a esta Família técnica."
			EndIf
		ENDIF
	Else
		MsgStop(STR0052) //"Opção disponível apenas para os tipos de ficha técnica 'Família Técnica' e 'Família Técnica X Recurso'."
	EndIf
	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} openCadFT
Abre a tela de cadastro de Ficha técnica, já posicionado no registro que
está sendo consultado.

@author Lucas Konrad França
@since 26/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function openCadFT()
	Local cProduto := ""
	Local cRecurso := ""
	Local cFamilia := ""

	Private cFiltro := ""
	Default lAutoMacao := .F.

	IF !lAutoMacao
		If ValType(oBrowseDow) == "U" .Or. oBrowseDow:nAT < 1 .Or. Len(oBrowseDow:AARRAY) < 1 .Or. Empty(oBrowseDow:AARRAY[oBrowseDow:nAT][1])
			Help( ,, 'Help',, STR0057, 1, 0 ) //"Pesquise previamente uma ficha técnica."
			Return .F.
		EndIf
	ENDIF
	
	//CONOUT('CBROWSE:' + cBrowse)
	//CONOUT(STR0001)
	//CONOUT(STR0002)
	//CONOUT(STR0003)

	If AllTrim(cBrowse) == AllTrim(STR0001) .Or. ;
	   AllTrim(cBrowse) == AllTrim(STR0002) .Or. ;
	   AllTrim(cBrowse) == AllTrim(STR0003)
	   
	   	IF !lAutoMacao
			If AllTrim(cBrowse) == AllTrim(STR0001)
				cProduto := oBrowseSB1:AARRAY[oBrowseSB1:nAt][1]
				cRecurso := CriaVar("CZG_CDRC",.F.)
			Else
				If AllTrim(cBrowse) == AllTrim(STR0002)
					cProduto := CriaVar("CZG_CDAC",.F.)
					cRecurso := oBrowseSH1:AARRAY[oBrowseSH1:nAt][1]
				Else
					cProduto := oBrowseSxS:AARRAY[oBrowseSxS:nAt][1]
					cRecurso := oBrowseSxS:AARRAY[oBrowseSxS:nAt][6]
				EndIf
			EndIf
		ENDIF
		
		//CONOUT('cProduto:' + cProduto)
		//CONOUT('cRecurso:' + cRecurso)
		//CONOUT('cTemplate:' + cTemplate)
		//CONOUT('cVersao:' + cVersao)
		
		CZG->(dbSetOrder(1))
		CZG->(dbSeek(xFilial("CZG")+Padr(cProduto,TAMSX3("CZG_CDAC")[1])+;
                                  Padr(cRecurso,TAMSX3("CZG_CDRC")[1])+;
                                  Padr(cTemplate,TAMSX3("CZG_CDMD")[1])+;
                                  Padr(cVersao,TAMSX3("CZG_VRFH")[1])))
		cFiltro := " CZG_CDAC = '" + CZG->CZG_CDAC + "' .And. "
		cFiltro += " CZG_CDRC = '" + CZG->CZG_CDRC + "' .And. "
		cFiltro += " CZG_CDMD = '" + CZG->CZG_CDMD + "' .And. "
		cFiltro += " CZG_VRFH = '" + CZG->CZG_VRFH + "' "
	Else
		If AllTrim(cBrowse) == AllTrim(STR0025)
			cFamilia := oBrowseCZL:AARRAY[oBrowseCZL:nAt][1]
			cRecurso := CriaVar("CZG_CDRC",.F.)
		Else
			cFamilia := oBrowseCxC:AARRAY[oBrowseCxC:nAt][1]
			cRecurso := oBrowseCxC:AARRAY[oBrowseCxC:nAt][3]
		EndIf
		
		CZG->(dbSetOrder(4))
		CZG->(dbSeek(xFilial("CZG")+Padr(cFamilia,TAMSX3("CZG_CDFATD")[1])+Padr(cRecurso,TAMSX3("CZG_CDRC")[1])))
		
		While CZG->(!Eof()) .And. CZG->(CZG_FILIAL+CZG_CDFATD+CZG_CDRC) == xFilial("CZG")+Padr(cFamilia,TAMSX3("CZG_CDFATD")[1])+Padr(cRecurso,TAMSX3("CZG_CDRC")[1])
		
			If AllTrim(CZG->(CZG_VRFH)) == AllTrim(cVersao) .And. ;
			   AllTrim(CZG->(CZG_CDMD)) == AllTrim(cTemplate) .And. ;			   
				CZG->(CZG_DTFH) == Iif(ValType(dData)=="C",CtoD(dData),dData)
				
				Exit
			EndIf
			
			CZG->(dbSkip())
		End
		
		cFiltro := " CZG_CDAC   = '" + CZG->CZG_CDAC   + "' .And. "
		cFiltro += " CZG_CDRC   = '" + CZG->CZG_CDRC   + "' .And. "
		cFiltro += " CZG_CDMD   = '" + CZG->CZG_CDMD   + "' .And. "
		cFiltro += " CZG_VRFH   = '" + CZG->CZG_VRFH   + "' .And. "
		cFiltro += " CZG_CDFATD = '" + CZG->CZG_CDFATD + "' .And. "
		cFiltro += " CZG_DTFH   = '" + DtoS(CZG->CZG_DTFH) + "' "
	EndIf
	
	IF !lAutoMacao
		PCPA104()
	ENDIF
Return Nil
