#INCLUDE "JURA218.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA218
Cadastro de grupos de usu�rios

@author Wellington Coelho
@since 11/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA218()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0006 )//"Cadastro de grupos de usu�rios
	oBrowse:SetAlias( "NZX" )
	JurSetBSize( oBrowse )

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author Wellington Coelho
@since 11/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA218", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA218", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA218", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA218", 0, 5, 0, NIL } ) // "Excluir"
	aAdd( aRotina, { STR0026, "JA218GLOTE"	   , 0, 3, 0, NIL } ) // "Grupos em Lote"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Cadastro de grupos de usu�rios

@author Wellington Coelho
@since 11/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel  := FWLoadModel( "JURA218" )
	Local oStructNZX := FWFormStruct( 2, "NZX" )
	Local oStructNZY := FWFormStruct( 2, "NZY" )

	oStructNZY:RemoveField( "NZY_CGRUP" )

	JurSetAgrp( 'NZX',, oStructNZX )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0006 )//"Cadastro de grupos de usu�rios"

	oView:AddField( "JURA218_VIEW", oStructNZX , "NZXMASTER" )
	oView:AddGrid( "JURA218_DETAIL", oStructNZY , "NZYDETAIL" )

	oView:CreateHorizontalBox( "FORMGRUPOS", 30 )
	oView:CreateHorizontalBox( "FORMUSUARIOS", 70 )

	oView:SetOwnerView( "NZXMASTER", "FORMGRUPOS" )
	oView:SetOwnerView( "NZYDETAIL", "FORMUSUARIOS" )

	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Cadastro de grupos de usu�rios

@author Wellington Coelho
@since 11/05/16
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructNZX := FWFormStruct( 1, "NZX" )
	Local oStructNZY := FWFormStruct( 1, "NZY" )

//-----------------------------------------
//Monta o modelo do formul�rio
//-----------------------------------------
	oStructNZY:RemoveField( "NZY_CGRUP" )

	oModel:= MPFormModel():New( "JURA218", /*Pre-Validacao*/, /*{|oX| JURA218TOK(oX)}*/, {|oModel| J218Commit(oModel)}, /*Cancel*/)
	oModel:SetDescription( STR0007 )//"Modelo de Dados cadastro de grupos de usu�rios"

	oModel:AddFields( "NZXMASTER", NIL /*cOwner*/, oStructNZX, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "NZXMASTER" ):SetDescription( STR0007 )//"Modelo de Dados cadastro de grupos de usu�rios"

	oModel:AddGrid( "NZYDETAIL", "NZXMASTER" /*cOwner*/, oStructNZY, /*bLinePre*/, {|oX,y| J218LineOk(oX,y)},/*bPre*/, /*bPost*/ )
	oModel:GetModel( "NZYDETAIL" ):SetDescription( STR0008 )//"Participantes"

	oModel:GetModel( "NZYDETAIL" ):SetUniqueLine( { "NZY_CUSER" } )

	oModel:SetRelation( "NZYDETAIL", { { "NZY_FILIAL", "XFILIAL('NZX')" }, { "NZY_CGRUP", "NZX_COD" } }, NZY->( IndexKey( 1 ) ) )

	oModel:SetOptional( "NZYDETAIL" , .F. )

	JurSetRules( oModel, 'NZXMASTER',, 'NZX' )
	JurSetRules( oModel, 'NZYDETAIL',, 'NZY' )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} J218LineOk()
Valida se o usu�rio j� est� vinculado com a pesquisa, por algum grupo ou diretamente

@author Wellington Coelho
@since 19/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J218LineOk(oModel, nLine)
Local aArea      := GetArea()
Local cPesq      := GetNextAlias()
Local cGrupo     := FWFLDGET('NZX_COD')
Local cQuery     := ""
Local cNomePesq  := ""
Local lRet       := .T.
Local lWSTLegal  := .F.
Local lNVKNvCmp  := .F.

	//Verifica se o campo NVK_CASJUR existe no dicion�rio
	If Select("NVK") > 0
		lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	lWSTLegal := lNVKNvCmp .And. JModRst()

	If oModel:IsFieldUpdated('NZY_CUSER')
		//Monta query que valida se o usu�rio j� est� vinculado com alguma pesquisa, por algum grupo ou diretamente
		cQuery := SqlVldUser( oModel:GetValue('NZY_CUSER'), cGrupo )

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cPesq, .T., .F.)

		While (cPesq)->(!Eof())
			lRet := .F.

			If !lWSTLegal
				cNomePesq := (cPesq)->NVK_CPESQ + "-" + ALLTRIM(JurGetDados('NVG', 1, xFilial('NVK') + (cPesq)->NVK_CPESQ, 'NVG_DESC'))
				JurMsgErro( STR0009 + cNomePesq) //"O usu�rio n�o pode ser adicionado ao grupo. Pois o mesmo j� tem vinculo com a pesquisa "
			EndIf

			Exit
		EndDo

		(cPesq)->( dbCloseArea() )
	EndIf

	RestArea( aArea )

	If lRet
		lRet := J218VldUsr(oModel:GetValue('NZY_CUSER'))//Valida se o usu�rio tem tipo de acesso diferente do grupo.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J218VldTpA()
Valida campo NZX_TIPOA

@Return lRet

@author Wellington Coelho
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J218VldTpA()
	Local lRet      := .F.
	Local oModel    := FWModelActive()
	Local oModelNZX := oModel:GetModel("NZXMASTER")

	If oModel <> Nil
		If !Empty(oModelNZX:GetValue("NZX_TIPOA"))
			If oModelNZX:GetValue("NZX_TIPOA") $ "1234"
				DbSelectArea("NVK")
				NVK->(DBSetOrder(5))
				NVK->(dbGoTop())
				If NVK->( dbSeek( XFILIAL('NVK') + oModelNZX:GetValue("NZX_COD")) )
					JurMsgErro(STR0010)//"O tipo de acesso n�o pode ser alterado. Pois o grupo j� tem vinculo com pesquisa(s)"
					lRet := .F.
				Else
					lRet := .T.
				EndIf
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J218VldUsr(oModel)
Valida��o para n�o permitir que o usu�rio seja cadastrado com tipos de acesso diferentes
sendo em grupos ou pesquisas.

@param cUsuario   - C�digo do usu�rio para valida��o
@param cGrupo     - C�digo do grupo para valida��o
@param lMensagem  - Apresenta mensagem de erro, sim ou n�o?
@param lWSTLegal  - A valida��o � para o totvs legal?
@param cTpAcesso  - C�digo do tipo de acesso do grupo
@param cMsgTLegal - Mensagem que ser� apresentada no totvs legal.

@author Wellington Coelho
@since 19/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J218VldUsr(cUsuario, cGrupo, lMensagem, lWSTLegal, cTpAcesso, cMsgTLegal)
Local aAreaGru   := GetArea()
Local cAliasGrup := GetNextAlias()
Local oModel     := FWModelActive()
Local lRet       := .T.
Local cQuery     := ""
Local cTipoA     := ""
Local aAuxUser   := {}
Local nI         := 0

Default lMensagem  := .T.
Default lWSTLegal  := .F.
Default cTpAcesso  := ''
Default cMsgTLegal := ""

	If lWSTLegal
		cQuery := " SELECT A.NVK_TIPOA, B.NZY_CUSER CUSER, B.NZY_CGRUP CGRUP "
	Else
		cQuery := " SELECT A.NVK_TIPOA "
	EndIf

	cQuery += "  FROM " + RetSqlName("NVK") + " A "
	cQuery += "   JOIN " + RetSqlName("NZY") + " B "
	cQuery += "   ON NZY_CGRUP = A.NVK_CGRUP "

	If Empty(cUsuario)
		cQuery += "   AND NZY_CGRUP = '" + cGrupo + "' "
	Else
		If lWSTLegal
			cQuery += "   AND NZY_CUSER IN (" + cUsuario + ") "
		Else
			cQuery += "   AND NZY_CUSER = '" + cUsuario + "' "
		EndIf
	EndIf

	cQuery += "   AND A.D_E_L_E_T_ = ' ' "
	cQuery += "   AND B.D_E_L_E_T_ = ' ' "
	cQuery += "   AND A.NVK_FILIAL = '" + xFilial("NVK") + "' "
	cQuery += "   AND B.NZY_FILIAL = '" + xFilial("NZY") + "' "

	cQuery += " UNION "

	If lWSTLegal
		cQuery += " SELECT NVK.NVK_TIPOA, NVK.NVK_CUSER CUSER, NVK.NVK_CGRUP CGRUP "
	Else
		cQuery += " SELECT NVK.NVK_TIPOA "
	EndIf

	cQuery += "  FROM " + RetSqlName("NVK") + " NVK "
	cQuery += "   WHERE "

	If Empty(cUsuario)
		cQuery += " NVK.NVK_CGRUP = '" + cGrupo + "' "
	Else
		If lWSTLegal
			cQuery += " NVK.NVK_CUSER IN (" + cUsuario + ") "
		Else
			cQuery += " NVK.NVK_CUSER = '" + cUsuario + "' "
		EndIf
	EndIf
	
	cQuery += "   AND NVK.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "

	//Se for altera��o de pesquisa tira o proprio registro que esta sendo alterado
	If !lWSTLegal .And. oModel:GetId() == "JURA163" .And. oModel:GetOperation() == 4
		cQuery += "   AND NVK.R_E_C_N_O_ <> '" + cValToChar( NVK->(Recno()) ) + "'"
	EndIf

	cQuery += " UNION "

	If lWSTLegal
		cQuery += " SELECT NZX.NZX_TIPOA, NZY.NZY_CUSER CUSER, NZY.NZY_CGRUP CGRUP "
	Else
		cQuery += " SELECT NZX.NZX_TIPOA "
	EndIf

	cQuery += "  FROM " + RetSqlName("NZX")+ " NZX "
	cQuery += "   JOIN " + RetSqlName("NZY") + " NZY "
	cQuery += "   ON NZY.NZY_CGRUP = NZX.NZX_COD "

	If Empty(cUsuario)
		cQuery += "   AND NZY.NZY_CGRUP = '" + cGrupo + "' "
	Else
		If lWSTLegal
			cQuery += " AND NZY.NZY_CUSER IN (" + cUsuario + ") "
		Else
			cQuery += " AND NZY.NZY_CUSER = '" + cUsuario + "' "
		EndIf
	EndIf

	cQuery += "   AND NZY.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NZX.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NZX.NZX_FILIAL = '" + xFilial("NZX") + "' "
	cQuery += "   AND NZY.NZY_FILIAL = '" + xFilial("NZY") + "' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasGrup, .T., .F.)

	If !lWSTLegal .And. oModel:GetId() == 'JURA218'
		cTipoA := FWFLDGET('NZX_TIPOA')
	EndIf

	If !lWSTLegal .And. (cAliasGrup)->(!Eof())
		If !Empty(cTipoA)
			If (cAliasGrup)->NVK_TIPOA <> cTipoA//FWFLDGET('NZX_TIPOA')
				If lMensagem
					JurMsgErro(I18N(STR0011,{Alltrim(FWFLDGET('NZY_DUSER')),JTrataCbox( "NVK_TIPOA", (cAliasGrup)->NVK_TIPOA )}))
				EndIf
				//'O usu�rio: "#1" est� configurado com o tipo de acesso: "#2" em outro grupo ou pesquisa'
				lRet := .F.
			EndIf
		Else
			If (cAliasGrup)->NVK_TIPOA <> FWFLDGET('NVK_TIPOA')
				If lMensagem
					JurMsgErro(I18N(STR0011,{Alltrim(FWFLDGET('NVK_DUSER')),JTrataCbox( "NVK_TIPOA", (cAliasGrup)->NVK_TIPOA )}))
				EndIf
				//'O usu�rio: "#1" est� configurado com o tipo de acesso: "#2" em outro grupo ou pesquisa'
				lRet := .F.
			EndIf
		EndIf
	Else
		While (cAliasGrup)->(!Eof())
			If (cAliasGrup)->NVK_TIPOA <> cTpAcesso .And. !Empty( (cAliasGrup)->CUSER ) .And. (cAliasGrup)->CGRUP <> cGrupo
				lRet      := .F.
				Aadd(aAuxUser, {JurEncUTF8(UsrRetName((cAliasGrup)->CUSER)) + ' (' + JTrataCbox( "NVK_TIPOA", (cAliasGrup)->NVK_TIPOA ) + ')'})
			EndIf

			(cAliasGrup)->( dbSkip() )
		end
	EndIf

	If lWSTLegal .And. !lRet
		For nI := 1 to Len(aAuxUser)
			If nI > 1
				cMsgTLegal += ', ' + aAuxUser[nI][1]
			Else
				cMsgTLegal := aAuxUser[nI][1]
			EndIf
		Next
	EndIf

	(cAliasGrup)->( dbCloseArea() )
	RestArea(aAreaGru)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA218GLOTE()
Altera��o de grupos em lote


@author Jorge Luis Branco Martins Junior
@since 10/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA218GLOTE()
Local lRet      := .T.
Local aListBox1 := {}
Local aListBox2 := {}
Local oGrupList := Nil
Local oDlg      := Nil
Local oModel := FWLoadModel("JURA218")

// Essa atribui��o foi feita nesse momento devido ao consumo de mem�ria, pois dessa forma � chamada uma �nica vez.
// Com isso estamos assumindo que no momento da execu��o dessa rotina n�o estar� sendo inclu�do um novo usu�rio.
	Local aUsers := AllUsers() // Retorna todos os usu�rios cadastrados no sistema

	If 1 > 0

		DEFINE MSDIALOG oDlg TITLE STR0012 FROM C(0),C(0) TO C(370),C(620) PIXEL //"Altera��es em lote - Tipos de Assuntos Jur�dicos X Campos"

		// Cria Componentes Padroes do Sistema
		@ C(006),C(010) Say    STR0013   Size C(115),C(007) COLOR CLR_BLACK PIXEL OF oDlg //"Grupos"
		@ C(030),C(010) Say    STR0014   Size C(115),C(007) COLOR CLR_BLACK PIXEL OF oDlg //"Usu�rios disponiveis"
		@ C(030),C(157) Say    STR0015   Size C(106),C(008) COLOR CLR_BLACK PIXEL OF oDlg //"Usu�rios configurados"
		@ C(037),C(114) Button STR0016   Size C(040),C(010) PIXEL OF oDlg Action oGrupList:AllToSel () //"Add. Todos >>"
		@ C(052),C(114) Button STR0017   Size C(040),C(010) PIXEL OF oDlg Action oGrupList:OneToSel () //"Adicionar >>"
		@ C(067),C(114) Button STR0018   Size C(040),C(010) PIXEL OF oDlg Action oGrupList:OneToDisp () //"<< Remove"
		@ C(169),C(220) Button STR0019   Size C(039),C(010) PIXEL OF oDlg Action JA218Grava(oModel, oGrupList) //"Salvar"
		@ C(169),C(266) Button STR0020   Size C(039),C(010) PIXEL OF oDlg Action JA218Sair(@oDlg ,oModel) //"Sair"

		oGrupList := JurLstBoxD():New()
		//Habilita pesquisa por nome dos usu�rios dispon�veis
		oGrupList:SetEnabSch(.T.)
		//Indica a posi��o do array de usu�rios em que deseja fazer a pesquisa.
		// 1 = C�digo do usu�rio
		// 2 = Nome do usu�rio
		oGrupList:SetNSearch(2)

		oGrupList:befAdd := {|oObj1,oObj2,aOrigem,aDestino, lRem| JA218VldUser(oObj1,oObj2,aOrigem,aDestino,lRem,oModel)}

		oGrupList:SetPosCmbTabela( {015,010,133,007} )
		oGrupList:SetCmbTabela(JA218Grupos())	 // Grupos
		oGrupList:SetSelectTab( { |x|JA218Lista(x,@oModel, aUsers) } )  // Usu�rios Disponiveis
		oGrupList:SetRefresh( { |x|JA218UsCfg(x,@oModel) } ) // Usu�rios Configurados

		oGrupList:SetRemove( { |x|JA218Remove(x,@oModel) } ) // Usu�rios removidos dos configurados que voltar�o para os dispon�veis

		//Habilita as op��es de configura��o
		oGrupList:SetEnabConfig(.F.)

		//Coordenadas do get e button da pesquisa
		oGrupList:SetPosGetSearch( {195,010,133,007} )
		oGrupList:SetPosBtnSearch( {193,150,045,012} )

		//Coordenadas do get e button de renomeio
		//oGrupList:SetPosGetRename( {195,200,133,007} )
		//oGrupList:SetPosBtnRename( {193,340,050,012} )

		//Array de usu�rios dispon�veis e coordenadas
		oGrupList:SetCmpDisp(aListBox1)
		oGrupList:SetPosCmpDisp( {047,010,133,140} )

		//Array de usu�rios selecionados e coordenadas
		oGrupList:SetCmpSel(aListBox2)
		oGrupList:SetPosCmpSel( {047,200,133,140} )
		oGrupList:SetDlgWin( oDlg )
		oGrupList:Activate()

		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA218Grupos
Gera o array de grupos
Uso Geral.

@return aRet    Array de grupos

@author Jorge Luis Branco Martins Junior
@since 07/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA218Grupos()
	Local aRet      := {}
	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT NZX_COD,NZX_DESC
		FROM %table:NZX% NZX
		WHERE NZX.NZX_FILIAL = %xFilial:NZX%
		AND NZX.D_E_L_E_T_ = ' '
	EndSql

	aAdd(aRet,{'','','',''})

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbgoTop())

	While !(cAliasQry)->( EOF())

		aAdd(aRet,{ (cAliasQry)->NZX_COD+"=",AllTrim((cAliasQry)->NZX_DESC), "NZX" ,"NZX" })
		(cAliasQry)->( dbSkip() )

	EndDo

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA218Lista( oGrupList, oModel, aUsers )
Atualiza o array de usu�rios dispon�veis para altera��o em lote
Uso Geral.

@param oGrupList    Objeto da lista
@return aLista	    Lista de usu�rios

@author Jorge Luis Branco Martins Junior
@since 07/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA218Lista( oGrupList, oModel, aUsers )
Local aLista   := {}
Local aConfig  := {}
Local cGrupo   := oGrupList:GetTabela()
Local aArea    := GetArea()
Local nI       := 0
Local nJ       := 0
Local nPos     := 0

	aSize(oGrupList:aCmpSel,0)

	oGrupList:RefreshUsers()

	aConfig  := oGrupList:GetCmpSel()

	For nI := 1 to Len(aUsers)
		//Filtra os usuarios que podem aparecer nos grupos em lote como disponiveis
		If FiltraUser(aUsers[nI][1][1], cGrupo)
			aAdd(aLista, {aUsers[nI][1][1]+"-", aUsers[nI][1][2], 0})
		EndIf
	Next nI

	If !Empty( aConfig )
		For nJ := 1 To Len (aConfig)
			nPos := aScan( aLista, { |x| x[1] == aConfig[nJ][1] .And. x[2] == aConfig[nJ][2] } )
			If nPos <> 0
				aDel(aLista, nPos)
				aSize(aLista, LEN(aLista)-1)
			EndIf
		Next
	EndIf

	RestArea(aArea)

Return aLista

//-------------------------------------------------------------------
/*/{Protheus.doc} JA218UsCfg( oGrupList, oModel )
Gera o array de usu�rios de uma configura��o j� existente.

Uso Geral.

@param  oGrupList   Objeto de lista
@return aUsers      Array de Campos

@author Jorge Luis Branco Martins Junior
@since 07/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA218UsCfg( oGrupList, oModel )
	Local aArea    := GetArea()
	Local aUsers   := {}
	Local nQtdLine := 0
	Local oModelNZY
	Local nI := 0

	Default cOrig := ""

	If !Empty( oGrupList:GetTabela() )

		If oModel:lModify
			If ApMsgYesNo(STR0021)//"Deseja salvar altera��es atuais?"
				JA218Grava(oModel, oGrupList)
			EndIf
		EndIf

		oModel:DeActivate()

		DbSelectArea("NZX")
		NZX->(DBSetOrder(1))
		NZX->( dbSeek( XFILIAL("NZX") + oGrupList:GetTabela() ) )
		oModel:SetOperation( 4 )

		oModel:Activate()

		oModelNZY := oModel:GetModel('NZYDETAIL')
		nQtdLine  := oModelNZY:GetQtdLine()

		//Atualiza lista de usu�rios configurados
		For nI := 1 To nQtdLine

			If !oModelNZY:IsDeleted(nI)
				aAdd(aUsers,{oModelNZY:GetValue("NZY_CUSER", nI)+"-",JurUsrName(oModelNZY:GetValue("NZY_CUSER", nI)),nI})
			EndIf

		Next nI

	EndIf

	RestArea(aArea)

Return aUsers
//-------------------------------------------------------------------
/*/{Protheus.doc} JA218Remove( oGrupList, oModel )
Gera o array de usu�rios a remover do grupo e inserir na lista de
usu�rios dispon�veis
Uso Geral.

@param  oGrupList   Objeto de lista
@return aRemover    Array de tabelas

@author Jorge Luis Branco Martins Junior
@since 07/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA218Remove( oGrupList, oModel )
	Local aArea      := GetArea()
	Local aRemover   := {}
	Local aCampos    := oGrupList:GetCmpSel()
	Local nPos       := oGrupList:oCmpSel:nAt
	Local nI
	Local nCampo     := nPos
	Local aRemove    := {}

	If !Empty( aCampos )

		For nI:=1 to Len(aCampos)

			If nPos == 0
				nCampo := nI
			EndIf

			aAdd(aRemove,aCampos[nCampo])
			aAdd(aRemover,aCampos[nCampo])

			If nPos != 0
				nI := Len(aCampos) + 1
			Endif

		Next

	EndIf

	oGrupList:SetaRemove(aRemove)

	oModelNZY := oModel:GetModel('NZYDETAIL')
	nQtdLine  := oModelNZY:GetQtdLine()

	//Atualiza lista de usu�rios configurados
	For nI := 1 To Len(aRemove)
		nLinha := aRemove[nI][3]
		If nQtdLine >= nLinha
			oModelNZY:GoLine(nLinha)
			If !oModelNZY:IsDeleted(nLinha)
				oModelNZY:DeleteLine()
			EndIf
		EndIf

	Next nI

	RestArea(aArea)

Return aRemover

//-------------------------------------------------------------------
/*/{Protheus.doc} JA218AddOne(oGrupList,oObj2,aOrigem,aDestino,lRem,oModel)
Gera o array de campos a remover da exporta��o e inserir na lista de
campos dispon�veis
Uso Geral.

@param  oGrupList   Objeto de lista
@return aRemover    Array de tabelas

@author Jorge Luis Branco Martins Junior
@since 08/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA218VldUser(oGrupList,oObj2,aOrigem,aDestino,lRem,oModel)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local cUser     := ""
	Local cNameUser := ""
	Local cDados    := ""
	Local oModelNZY

	Default cOrig := ""
	Default lRem  := .F.

	If valtype(oGrupList) == "O" .And. !lRem

		oModelNZY := oModel:GetModel('NZYDETAIL')

		oModelNZY:AddLine()

		cUser := oGrupList:aItems[oGrupList:nAT]

		If (oModelNZY:SetValue("NZY_CUSER", SUBSTRING(cUser,1,at("-",cUser)-1) ))
			If oModelNZY:VldData()
				aOrigem[oGrupList:nAT][3] := oModelNZY:nLine // Adiciona a posi��o da linha nova do modelo no array de usu�rios.
			Else
				oModelNZY:DeleteLine()
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf

	ElseIf !Empty(aOrigem) .And. !lRem

		oModelNZY := oModel:GetModel('NZYDETAIL')

		oModelNZY:AddLine()

		If valtype(oGrupList) == "O"
			cDados := oGrupList:aitems[oGrupList:nAt]
			cUser := SUBSTRING(cDados,1,at("-",cUser)-1)
			cNameUser := SUBSTRING(cDados,at("-",cDados)+1,Len(cDados))
		ElseIf valtype(oGrupList) == "A"
			cUser := oGrupList[1]
			cNameUser := oGrupList[2]
		EndIf

		If (oModelNZY:SetValue("NZY_CUSER", SUBSTRING(cUser,1,at("-",cUser)-1) ))
			If oModelNZY:VldData()
				aOrigem[aScan(aOrigem, { |aX| ALLTRIM(aX[1]) == cUser})][3] := oModelNZY:nLine // Adiciona a posi��o da linha nova do modelo no array de usu�rios.
			Else
				oModelNZY:DeleteLine()
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA218Grava(oModel, oGrupList)
Salva a lista de usu�rios selecionados para um grupo

Uso Geral.

@param oModel     Modelo de dados
@param oGrupList	Objeto da lista de grupos

@author Jorge Luis Branco Martins Junior
@since 08/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA218Grava(oModel, oGrupList)
	Local aArea := GetArea()
	Local aErro := {}

	If oModel:lModify

		If oModel:VldData()
			oModel:CommitData()
			MsgInfo(STR0024)//"Configura��o efetuada com sucesso"
		Else
			aErro := oModel:GetErrorMessage()
			JurMsgErro(aErro[6])
		EndIf

		oModel:DeActivate()

		DbSelectArea("NZX")
		NZX->(DBSetOrder(1))
		NZX->( dbSeek( XFILIAL("NZX") + oGrupList:GetTabela() ) )
		oModel:SetOperation( 4 )

		oGrupList:RefreshUsers()

		oModel:Activate()

	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA218Sair(oDlg,oModel)
Fecha a tela de altere��o em lote.
Caso tenha alguma altera��o pergunta se deseja salvar antes de fechar
Uso Geral.

@param oDlg     Tela de altera��o em lote
@param oModel   Modelo de dados

@author Jorge Luis Branco Martins Junior
@since 09/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA218Sair(oDlg,oModel)
	Local aArea := GetArea()
	Local aErro := {}

	If oModel:lModify .And. ApMsgYesNo(STR0021)//"Deseja salvar altera��es atuais?"

		If oModel:VldData()
			oModel:CommitData()
			MsgInfo(STR0024)//"Configura��o efetuada com sucesso"
		Else
			aErro := oModel:GetErrorMessage()
			JurMsgErro(aErro[6])
		EndIf

		oModel:DeActivate()

	EndIf

	oDlg:End()

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J218RetGru
Retornar os grupos do usuario
Uso Geral.

@param	cUser	- Codigo o usuario
@return aGrupos - Array de grupos
@author Rafael Tenorio da Costa
@since  08/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J218RetGru( cUser )
Local aArea   := GetArea()
Local cTabela := GetNextAlias()
Local aGrupos := {}
Local cQuery  := ""

Default cUser := __CUSERID

	cQuery := " SELECT NZY_CGRUP"
	cQuery +=   " FROM " + RetSqlName("NZY")
	cQuery +=  " WHERE NZY_FILIAL = '" + xFilial("NZY") + "'"
	cQuery +=    " AND NZY_CUSER = '" + cUser + "'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .T., .T.)

	While !(cTabela)->( Eof() )
		Aadd(aGrupos, (cTabela)->NZY_CGRUP)
		(cTabela)->( DbSkip() )
	EndDo

	(cTabela)->( DbCloseArea() )

	RestArea(aArea)

Return aGrupos

//-------------------------------------------------------------------
/*/{Protheus.doc} SqlVldUser
Monta query que valida se o usu�rio j� est� vinculado com alguma pesquisa,
por algum grupo ou diretamente

@param cUser      - C�digo do usu�rio para ser validado
@param cGrupo     - C�digo do grupo para ser validado

@author Rafael Tenorio da Costa
@since  14/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SqlVldUser(cUser, cGrupo)

	Local cQuery := ""

	cQuery := "SELECT NVK_CPESQ FROM (SELECT D.NVK_CPESQ "
	cQuery += " FROM " + RetSqlName("NVK") + " D "
	cQuery += "  WHERE D.NVK_CUSER = '" + cUser + "' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += "   AND D.NVK_FILIAL = '" + xFilial("NVK") + "' "

	cQuery += " UNION "

	cQuery += " SELECT A.NVK_CPESQ "
	cQuery += " FROM " + RetSqlName("NVK") + " A "
	cQuery += " JOIN " + RetSqlName("NZY") + " B "
	cQuery += " ON NZY_CGRUP = A.NVK_CGRUP "
	cQuery += " AND NZY_CUSER = '" + cUser + "' "
	cQuery += " AND NZY_CGRUP <> '" + cGrupo + "'"
	cQuery += " AND A.D_E_L_E_T_ = ' ' "
	cQuery += " AND B.D_E_L_E_T_ = ' ' "
	cQuery += " AND A.NVK_FILIAL = '" + xFilial("NVK") + "' "
	cQuery += " AND B.NZY_FILIAL = '" + xFilial("NZY") + "') A "

	cQuery += " INTERSECT "

	cQuery += " SELECT C.NVK_CPESQ "
	cQuery += " FROM " + RetSqlName("NVK") + " C "
	cQuery += "  WHERE C.NVK_CGRUP = '" + cGrupo + "' "
	cQuery += "   AND C.D_E_L_E_T_ = ' ' "
	cQuery += "   AND C.NVK_FILIAL = '" + xFilial("NVK") + "'"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} FiltraUser
Filtra os usuarios que podem aparecer nos grupos em lote como disponiveis

@author Rafael Tenorio da Costa
@since  14/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FiltraUser(cUser, cGrupo)

	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local cTabela 	:= GetNextAlias()
	Local cQuery	:= ""

	//Monta query que valida se o usu�rio j� est� vinculado com alguma pesquisa, por algum grupo ou diretamente
	cQuery := SqlVldUser(cUser, cGrupo)

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., 'TOPCONN', TcGenQry( , , cQuery), cTabela, .T., .F.)

	If !(cTabela)->( Eof() )
		lRetorno := .F.
	EndIf
	(cTabela)->( DbCloseArea() )

	//Valida��o para n�o permitir que o usu�rio seja cadastrado com tipos de acesso diferentes sendo em grupos ou pesquisas.
	If lRetorno
		lRetorno := J218VldUsr(cUser, cGrupo, .F.)
	EndIf

	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J218Commit
Realiza o commit do modelo

@author  Rafael Tenorio da Costa
@since   21/03/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J218Commit(oModel)
	Local lRet       := .T.
	Local nCont      := 0
	Local nI         := 0
	Local cEndEmail  := ""
	Local cErro      := ""
	Local cColIdRem  := ""
	Local aAddMsg    := {}
	Local aUsuarios  := {}
	Local aGuardaUsu := {}
	Local oModelNZY  := oModel:GetModel('NZYDETAIL')
	Local cGrupo     := oModel:GetValue("NZXMASTER", "NZX_COD")
	Local cRestUsu   := oModel:GetValue("NZXMASTER", "NZX_TIPOA")
	Local nOpc       := oModel:GetOperation()
	Local lFluig     := ( SuperGetMV('MV_JDOCUME',,"2") == "3" )

	//Carrega todos os usuarios antes do commit
	If lFluig
		For nCont := 1 To oModelNZY:GetQtdLine()

			oModelNZY:GoLine(nCont)

			If oModelNZY:IsFieldUpdated("NZY_CUSER")
				Aadd(aUsuarios, {oModelNZY:GetValue("NZY_CUSER", nCont)})

			ElseIf oModelNZY:IsDeleted()
				If cRestUsu == "3"
					cErro     := ""
					cEndEmail := AllTrim( UsrRetMail(oModelNZY:GetValue("NZY_CUSER")) )

					If !Empty(cEndEmail)
						Processa( {|| AtuPstCorr(cGrupo, oModelNZY:GetValue("NZY_CUSER", nCont), cEndEmail, @cErro, @cColIdRem)}, STR0030, , .F.) // "Atualizando usu�rios no Fluig"

						Aadd(aGuardaUsu, { cEndEmail, cColIdRem , cErro })
					Else
						cEndEmail := UsrRetName( oModelNZY:GetValue("NZY_CUSER") )

						Aadd(aGuardaUsu, { cEndEmail, cEndEmail , I18n(STR0027, { cEndEmail }) }) //"Usu�rio(s) #1 n�o est� ativo no Fluig!"
					EndIf
				ElseIf cRestUsu == "2"
					AtuPstClie(cGrupo, oModelNZY:GetValue("NZY_CUSER", nCont))
				EndIf
			EndIf
		Next nCont

		If cRestUsu == "3" .And. Len(aGuardaUsu) > 0 .And. aScan( aGuardaUsu, {|x| !Empty(x[3])} ) > 0
			For nI := 1 to Len(aGuardaUsu)
				If !Empty(aGuardaUsu[nI][3])
					Aadd(aAddMsg, { aGuardaUsu[nI][1], aGuardaUsu[nI][2] , aGuardaUsu[nI][3] })
				EndIf
			Next
		EndIf
	EndIf

	lRet := FWFormCommit( oModel )

	If lRet
		//Atualiza dados de usuarios no fluig
		If lFluig .And. Len(aUsuarios) > 0
			AtuFluig(aUsuarios, cGrupo, cRestUsu, nOpc, aAddMsg)
		Else
			If Len(aAddMsg) > 0
				cEndEmail := ""
				cErro     := ""

				For nI := 1 to Len(aAddMsg)
					If !Empty(aAddMsg[nI][3])
						If STR0028 $ aAddMsg[nI][3]
							cErro := STR0028 //"Objeto XML nao criado, verificar a estrutura do XML"
						Else
							cEndEmail += aAddMsg[nI][1] + ", "
						EndIf
					EndIf
				Next

				If !Empty(cEndEmail)
					cEndEmail := Substr(cEndEmail,1,Rat(',', cEndEmail)-1)

					cErro := CRLF + I18n(STR0027, {cEndEmail}) //"Usu�rio(s) #1 n�o est� ativo no Fluig!"
				EndIf

				If !Empty(cErro)
					JurMsgErro( I18n(STR0029, {cErro}) ) //"Erro nas permiss�es no Fluig: #1"
				EndIf
			EndIf
		EndIf
	Else
		JurShowErro( oModel:GetModel():GetErrormessage() )
	EndIf

	oModel:Activate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuFluig(aUsuarios, cGrupo, cRestUsu, nOpc, aAddMsg)
Chama rotina que atualiza acessos dos usuarios no Fluig.

@param aUsuarios - Usu�rios que seram alterados
@param cGrupo    - C�digo do Grupo que ser� concedido a permiss�o.
@param cRestUsu  - C�d. de restri��o que o grupo pertence.
				   1 = Matriz, 2 = Cliente ou  3 = Correspondente.
@param nOpc      - Opera��o que est� sendo realizada.
@param aAddMsg   - Lista das mensagens obtidas na exclus�o de usu�rios
do grupo para que seja apresentada em uma �nica
				   chamada.

@since   21/03/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuFluig(aUsuarios, cGrupo, cRestUsu, nOpc, aAddMsg)
Local aArea      := GetArea()
Local nCont      := 0
Local cQuery     := ""
Local cCodAssJur := ""
Local aRetorno   := {}
Local lMostraMsg := .T.
Local lWSTLegal  := .F.
Local lNVKNvCmp  := .F.

	//Verifica se o campo NVK_CASJUR existe no dicion�rio
	If Select("NVK") > 0
		lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	lWSTLegal := lNVKNvCmp .And. JModRst()

	Default aAddMsg    := {}

	Do Case
	Case cRestUsu == "1"
		cRestUsu := "MATRIZ"
	Case cRestUsu == "2"
		cRestUsu := "CLIENTES"
	Case cRestUsu == "3"
		cRestUsu   := "CORRESPONDENTES"
		lMostraMsg := .F.
	End Case

	//Busca as pesquisas relacionadas ao grupo
	If lWSTLegal
		cQuery := " SELECT NVK_CPESQ, NVK_CASJUR"
		cQuery += " FROM " + RetSqlName("NVK")
		cQuery += " WHERE NVK_FILIAL = '" + xFilial("NVK") + "'"
		cQuery +=   " AND NVK_CGRUP = '" + cGrupo + "'"
		cQuery +=   " AND D_E_L_E_T_ = ' ' "

		aRetorno := JurSQL(cQuery, {"NVK_CPESQ", "NVK_CASJUR"})
	Else
		cQuery := " SELECT NVK_CPESQ"
		cQuery += " FROM " + RetSqlName("NVK")
		cQuery += " WHERE NVK_FILIAL = '" + xFilial("NVK") + "'"
		cQuery +=   " AND NVK_CGRUP = '" + cGrupo + "'"
		cQuery +=   " AND D_E_L_E_T_ = ' ' "

		aRetorno := JurSQL(cQuery, "NVK_CPESQ")
	EndIf

	For nCont:=1 To Len(aRetorno)
		cCodAssJur := Iif( Len(aRetorno[nCont]) > 1, aRetorno[nCont][2], '')
		Processa( {|| J163PFluig(aUsuarios, aRetorno[nCont][1], cRestUsu, nOpc, lMostraMsg, aAddMsg, cCodAssJur)}, I18n(STR0025, {aRetorno[nCont][1]}), , .F.) // "Atualizando usu�rios no Fluig - Pesquisa: #1"
	Next nCont

	aSize(aRetorno, 0)
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuPstCorr(cCodGrup, cUsuRem, cEndEmail, cErro, cColIdRem)
Atualiza��o da Permiss�o de Pasta de Config para Correspondente

@param cCodGrup  - C�digo do Grupo.
@param cUsuRem   - C�digo do usu�rio que foi removido.
@param cEndEmail - Email do usu�rio que foi removido.
@param cErro     - Mensagem de erro para envio a fun��o J218Commit().
@param cColIdRem - C�digo obtido no fluig do usu�rio que foi removido.

@since 17/01/2020
/*/
//-------------------------------------------------------------------
Static Function AtuPstCorr(cCodGrup, cUsuRem, cEndEmail, cErro, cColIdRem)
Local cAliasNVK  := Nil
Local cQuery     := ""
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cCodPasta  := ""
Local cUsuario   := AllTrim(SuperGetMV('MV_ECMUSER',,""))
Local cSenha     := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
Local nEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,0))
Local lWSTLegal  := .F.
Local lNVKNvCmp  := .F.

Default cErro     := ""
Default cEndEmail := ""
Default cColIdRem := ""

	//Verifica se o campo NVK_CASJUR existe no dicion�rio
	If Select("NVK") > 0
		lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	lWSTLegal := lNVKNvCmp .And. JModRst()

	ProcRegua(0)
	IncProc()

	//Carrega o Id do usuario no fluig
	cColIdRem := JColId(cUsuario, cSenha, nEmpresa, cEndEmail, @cErro, .F.)

	If Empty(cErro)
		cQrySel := " SELECT NSZ_CCLIEN, NSZ_LCLIEN, NSZ_NUMCAS, NSZ_TIPOAS, NZ7_LINK "

		cQryFrm := " FROM " + RetSqlName("NVK") + " NVK INNER JOIN " + RetSqlName("NUQ") + " NUQ ON (NUQ.NUQ_CCORRE = NVK.NVK_CCORR "
		cQryFrm +=                                                                             " AND NUQ.NUQ_LCORRE = NVK.NVK_CLOJA)"
		cQryFrm +=                                    " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_COD    = NUQ.NUQ_CAJURI "
		cQryFrm +=                                                                             " AND NSZ.NSZ_FILIAL = NUQ.NUQ_FILIAL "
		
		If lWSTLegal
			cQryFrm +=                                                                             " AND NSZ.NSZ_TIPOAS = NVK.NVK_CASJUR)"
		Else
			cQryFrm +=                                                                             " AND NSZ.NSZ_TIPOAS = NVK.NVK_CPESQ)"
		EndIf

		cQryFrm +=                                    " INNER JOIN " + RetSqlName("NZ7") + " NZ7 ON (NSZ.NSZ_CCLIEN = NZ7.NZ7_CCLIEN "
		cQryFrm +=                                                                             " AND NSZ.NSZ_LCLIEN = NZ7.NZ7_LCLIEN "
		cQryFrm +=                                                                             " AND NSZ.NSZ_NUMCAS = NZ7.NZ7_NUMCAS "
		cQryFrm +=                                                                             " AND NZ7.NZ7_FILIAL = '" + xFilial("NZ7") + "' "
		cQryFrm +=                                                                             " AND NZ7.NZ7_STATUS = '2') "

		cQryWhr := " WHERE NVK.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NUQ.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NSZ.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NZ7.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NVK.NVK_CGRUP IN ('" + cCodGrup + "') "

		cAliasNVK := GetNextAlias()
		cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)

		DbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasNVK, .T., .T.)
		While(cAliasNVK)->(!Eof())

			IncProc( cEndEmail )

			cCodPasta := SubStr((cAliasNVK)->NZ7_LINK, 1, At(";", (cAliasNVK)->NZ7_LINK) - 1)

			J163SetPer( cCodPasta, cUsuario, cSenha, nEmpresa, "1", cColIdRem, .F.)
			(cAliasNVK)->( DbSkip())
		EndDo

		(cAliasNVK)->( DbCloseArea() )
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuPstClie(cCodGrup, cUsuRem)
Atualiza��o da Permiss�o de Pasta de Config para Cliente

@param cCodGrup - C�digo do Grupo
@param cUsuRem  - C�digo do usu�rio que foi removido
@since 17/01/2020

/*/
//-------------------------------------------------------------------
Static Function AtuPstClie(cCodGrup, cUsuRem)
	Local cAliasNVK  := Nil
	Local cColIdRem  := ""
	Local cQuery     := ""
	Local cQrySel    := ""
	Local cQryFrm    := ""
	Local cQryWhr    := ""
	Local cErro      := ""
	Local cCodPasta  := ""
	Local cUsuario	 := AllTrim(SuperGetMV('MV_ECMUSER',,""))
	Local cSenha	 := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
	Local nEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,0))

	cEndEmail := AllTrim( UsrRetMail(cUsuRem) )

	//Carrega o Id do usuario no fluig
	cColIdRem	:= JColId(cUsuario, cSenha, nEmpresa, cEndEmail, @cErro)

	If Empty(cErro)
		cQrySel := " SELECT NSZ_CCLIEN, "
		cQrySel +=        " NSZ_LCLIEN, "
		cQrySel +=        " NSZ_NUMCAS, "
		cQrySel +=        " NSZ_TIPOAS, "
		cQrySel +=        " NZ7_LINK, "
		cQrySel +=        " NSZ.R_E_C_N_O_ RECNSZ "
		cQryFrm := " FROM " + RetSqlName("NVK") + " NVK INNER JOIN " + RetSqlName("NWO") + " NWO ON (NWO.NWO_CCONF = NVK.NVK_COD) "
		cQryFrm +=                                    " INNER JOIN " + RetSqlName("NVJ") + " NVJ ON (NVJ.NVJ_CPESQ = NVK.NVK_CPESQ) "
		cQryFrm +=                                    " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_CCLIEN = NWO.NWO_CCLIEN "
		cQryFrm +=                                                                             " AND NSZ.NSZ_LCLIEN = NWO.NWO_CLOJA "
		cQryFrm +=                                                                             " AND NSZ.NSZ_TIPOAS = NVJ.NVJ_CASJUR) "
		cQryFrm +=                                    " INNER JOIN " + RetSqlName("NZ7") + " NZ7 ON (NSZ.NSZ_CCLIEN = NZ7.NZ7_CCLIEN "
		cQryFrm +=                                                                             " AND NSZ.NSZ_LCLIEN = NZ7.NZ7_LCLIEN "
		cQryFrm +=                                                                             " AND NSZ.NSZ_NUMCAS = NZ7.NZ7_NUMCAS "
		cQryFrm +=                                                                             " AND NZ7.NZ7_FILIAL = '" + xFilial("NZ7") + "' "
		cQryFrm +=                                                                             " AND NZ7.NZ7_STATUS = '2') "
		cQryWhr := " WHERE NVK.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NWO.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NVJ.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NSZ.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NZ7.D_E_L_E_T_ = ' ' "
		cQryWhr +=   " AND NVK.NVK_CGRUP IN ('" + cCodGrup + "') "

		cAliasNVK := GetNextAlias()
		cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)

		DbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasNVK, .T., .T.)
		While(cAliasNVK)->(!Eof())
			cCodPasta := SubStr((cAliasNVK)->NZ7_LINK, 1, At(";", (cAliasNVK)->NZ7_LINK) - 1)

			J163SetPer( cCodPasta, cUsuario, cSenha, nEmpresa, "1", cColIdRem, .F.)
			(cAliasNVK)->( DbSkip())
		EndDo

		(cAliasNVK)->( DbCloseArea() )
	EndIf
Return
