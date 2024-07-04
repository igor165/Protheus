#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE  TOTVS "TOTVS"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das opções do menu

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef(lAuto)

	Local aRotina  := {}
	Local aProcess := {}
	Local lLiberado:= .F.
	Default lAuto  := .f.

	aProcess := FWECMPsqProcess("CENPROCSIB")
	lLiberado := Len(aProcess) > 0 .AND. aProcess[1]

	ADD OPTION aRotina Title 'Visualizar' 				 Action 'PLCOExiCad(.F.,oBrowUp,.T.,.T.)'				OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Visualiza Cadastro' 		 Action 'PLCOExiCad(.F.,oBrowUp,.T.,.f.)'			OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Comparar ANS x Central'    Action 'PLCOComCad(.F.)'		            OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Enviar Alt. ANS' 		     Action 'CnCritPMrk(oBrowUp)'		        OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Enviar Crítica(s) p/Fluig' Action 'CenFluig(oBrowUp)'	                OPERATION 2 ACCESS 0

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnMBRWCrit

Tela que exibe as criticas com mark browse

@author vinicius.nicolau
@since 31/03/2020

/*/
//--------------------------------------------------------------------------------------------------
Function CnMBRWCrit(cFiltro, lAuto,lPrinc)

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer
	Local oPnlCriUp

	Private oBrowUp
	Private oDlgPrinc

	Default cFiltro   := ""
	Default lAuto     := .F.
	Default lPrinc    := .F.

	If(!lAuto)
		Define MsDialog oDlgPrinc Title 'Criticas' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlgPrinc, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COLLUP', 100, .T., 'LINE' )
		oFWLayer:AddCollumn( 'COLLDOWN', 100, .T., 'LINE' )

		oPnlCriUp := oFWLayer:GetColPanel( 'COLLUP', 'LINE' )
		oPnlBenDown := oFWLayer:GetColPanel( 'COLLDOWN', 'LINE' )
	EndIf

	oBrowUp := FWMarkBrowse():New()
	oBrowUp:SetOwner( oPnlCriUp )

	oBrowUp:SetAlias('B3F')
	oBrowUp:SetMenuDef('CENMRKCRIT')
	oBrowUp:SetAllMark({ || MarcaBrw(oBrowUp,"B3F") })

	If lPrinc
		oBrowUp:SetDescription('Criticas')

	Else
		oBrowUp:SetDescription('Criticas ANS x Central (Selecionado)')

	Endif

	oBrowUp:SetProfileID('CENMRKCRIT')
	oBrowUp:ForceQuitButton()
	oBrowUp:DisableDetails()
	oBrowUp:SetWalkthru(.F.)
	oBrowUp:SetAmbiente(.F.)
	oBrowUp:SetFieldMark( 'B3F_OK' )

	If !Empty(cFiltro)
		oBrowUp:SetFilterDefault(cFiltro)
	EndIf

	If !lAuto
		oBrowUp:Activate()
		Activate MsDialog oDlgPrinc Center
	EndIf

Return oBrowUp

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnCritPMrk

Valida as opcoes selecionadas na tela do Mark Browse

@author vinicius.nicolau
@since 31/03/2020

/*/
//--------------------------------------------------------------------------------------------------
Function CnCritPMrk(oMark,lQry)
	Local cAlias   := getNextAlias()
	Local aArea    := B3F->(GetArea())
	Local aRec     := {}
	Default lQry   := .F.

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetSqlName("B3F") + " B3F "
	cSql += " WHERE B3F_FILIAL = '" + xfilial("B3F") + "' "
	cSql += " AND B3F_OK = '" + oMark:cMark + "' "
	cSql += " AND B3F.D_E_L_E_T_ = ' '  "

	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	If (cAlias)->(eof())
		iF !lQry
			Alert("Selecione uma crítica para ser enviada à ANS.")
		EndIf
	else
		While (cAlias)->(!eof())
			B3F->(DbGoTo((cAlias)->RECNO))
			MV_PAR01 := dDataBase
			If !lQry
				PLSALTANS(.F., .T.)
			else
				AADD(aRec,{(cAlias)->RECNO})
			Endif
			(cAlias)->(dbskip())
		EndDo
		If !lQry
			MsgInfo("Movimentação criada no compromisso vigente.")
		Endif
	EndIf

	(cAlias)->(dbclosearea())
	RestArea(aArea)

Return aRec

Static Function MarcaBrw(oMark,cAliasTmp)
	Default oMark := Nil
	Default cAliasTmp := ""

	MsgRun("Marcando / Desmarcando registros do browse",TOTVS,{ || PrcMarcaBrw(oMark,cAliasTmp) })

Return

Static Function PrcMarcaBrw(oMark,cAliasTmp)
	Default oMark := Nil
	Default cAliasTmp := ""

	If !Empty(cAliasTmp) .And. oMark <> Nil
		(cAliasTmp)->(dbGoTop())
		While !(cAliasTmp)->(Eof())

			oMark:MarkRec()
			(cAliasTmp)->(dbSkip())
		EndDo
		oMark:oBrowse:Refresh(.T.)
	EndIf

Return .T.