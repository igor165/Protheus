#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#DEFINE PDTE_VALID     "1" // Pendente Validação
#DEFINE VALIDO         "2" // Valido
#DEFINE INVALIDO       "3" // Inválido
#DEFINE ENV_ANS        "4" // Enviado ANS
#DEFINE CRIT_ANS       "5" // Criticado ANS
#DEFINE ACAT_ANS       "6" // Acatado ANS
#DEFINE CANCELADO      "7" // Cancelado

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCARQSIB

Manutencao de Produtos no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSARQSIB(cTipo, lAuto)

	Local oBrowse	:= Nil
	Local cFiltro := 	" B3R_FILIAL = xFilial( 'B3R' ) .AND. " +;
		" B3R_CODOPE = B3D->B3D_CODOPE .AND. " +;
		" B3R_CDOBRI = B3D->B3D_CDOBRI .AND. " +;
		" B3R_ANO = B3D->B3D_ANO .AND. " +;
		" B3R_CDCOMP = B3D->B3D_CODIGO "
	Default lAuto := .F.

	If cTipo == "2" //Sib

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('B3R')
		oBrowse:SetDescription("Arquivos SIB") //Produtos
		oBrowse:SetMenuDef( 'PLSMVCARQSIB' )
		oBrowse:SetProfileID( 'SBX1' )
		oBrowse:ForceQuitButton()
		oBrowse:DisableDetails()
		oBrowse:SetWalkthru(.F.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetFilterDefault(cFiltro)
		If !lAuto
			oBrowse:Activate()

		EndIf

		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Histórico Arq SBX", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

	Else
		Alert("Operação não disponível para este tipo de obrigação.")
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.PLSMVCARQSIB'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 		Action 'PLEXARQSIB'	          OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Download' 	Action 'DOWNLSBX'	            OPERATION 5 ACCESS 0

Return aRotina
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para o conjunto B3R e B3X

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruB3R 		:= FWFormStruct( 1, 'B3R' )
	Local oStruB3X 		:= FWFormStruct( 1, 'B3X' )
	Local oStruB3F 		:= FWFormStruct( 1, 'B3F' )
	Local oModel 		:= Nil

	oModel := MPFormModel():New( 'PLSMVCARQSIB' )

	oModel:AddFields( 'B3RMASTER', /*cOwner*/ , oStruB3R )
	oModel:AddGrid( 'B3XDETAIL', 'B3RMASTER', oStruB3X )
	oModel:AddGrid( 'B3FDETAIL', 'B3RMASTER', oStruB3F )

	oModel:SetRelation( 'B3XDETAIL',  { 	{ 'B3X_FILIAL', 'xFilial( "B3X" )' },;
		{ 'B3X_ARQUIV' , 'B3R_ARQUIV' };
		}, B3X->( IndexKey( 4 ) ) )
	If B3F->(FieldPos("B3F_TABKEY")) > 0
		oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
			{ 'B3F_ORICRI' , '"B3R"' },;
			{ 'B3F_TABKEY' , 'B3R_ARQUIV' };
			}, B3F->( IndexKey( 1 ) ) )
	Else
		oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
			{ 'B3F_ORICRI' , '"B3R"' },;
			{ 'B3F_CHVORI' , 'B3R->(Recno())' };
			}, B3F->( IndexKey( 1 ) ) )
	EndIf

	oModel:SetDescription( 'Arquivos' )
	oModel:GetModel( 'B3RMASTER' ):SetDescription( "Arquivos" )
	oModel:GetModel( 'B3XDETAIL' ):SetDescription( "Movimentações" )
	oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Críticas Proces" )

	oModel:GetModel( 'B3RMASTER' ):SetOnlyView(.T.)
	oModel:GetModel( 'B3XDETAIL' ):SetOnlyView(.T.)
	oModel:GetModel( 'B3FDETAIL' ):SetOnlyView(.T.)

	oModel:SetPrimaryKey({})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para o conjunto B3R e B3X

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel( 'PLSMVCARQSIB' )
	Local oStruB3R 			:= FWFormStruct( 2, 'B3R' )
	Local oStruB3X 			:= FWFormStruct( 2, 'B3X' )
	Local oStruB3F 			:= FWFormStruct( 2, 'B3F' )
	Local oView 			:= FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'VIEW_B3R', oStruB3R, 'B3RMASTER' )
	oView:AddGrid( 'VIEW_B3X', oStruB3X, 'B3XDETAIL' )
	oView:AddGrid( 'VIEW_B3F', oStruB3F, 'B3FDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

	oView:CreateFolder( 'PASTA_INFERIOR' ,'INFERIOR' )
	oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_MOVI'    , "Movimentações" )
	oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_CRIT'    , "Críticas Proces" )

	oView:CreateVerticalBox( 'BOX_MOVI', 100,,, 'PASTA_INFERIOR', 'ABA_MOVI' )
	oView:CreateVerticalBox( 'BOX_CRIT', 100,,, 'PASTA_INFERIOR', 'ABA_CRIT' )

	oView:SetOwnerView( 'VIEW_B3R', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B3X', 'BOX_MOVI' )
	oView:SetOwnerView( 'VIEW_B3F', 'BOX_CRIT' )

	oView:EnableTitleView( 'VIEW_B3R', "Arquivos" )
	oView:EnableTitleView( 'VIEW_B3X', "Movimentações" )
	oView:EnableTitleView( 'VIEW_B3F', "Crit. Proces" )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLEXARQSIB

Realiza a exclusão de um arquivo, desmarca as movimentações e exclui as críticas

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLEXARQSIB(cAlias, cOpe, cAccess,lAuto)

	Local lYesOrNo := .F.
	Default lAuto := .F.

	if !lAuto
		lYesOrNo := ApMsgNoYes ("Este processo não pode ser desfeito, deseja realmente excluir este arquivo?" ,"Central de Obrigações")
	EndIF

	If lYesOrNo .OR. lAuto
		If PodeExcluir(B3R->B3R_ARQUIV)
			BEGIN TRANSACTION

				B3X->(DbSetOrder(4)) //B3X_FILIAL+B3X_ARQUIV+B3X_OPERA

				While B3X->(MsSeek(xFilial("B3X")+AllTrim(B3R->B3R_ARQUIV)))

					B3X->(Reclock("B3X",.F.))
					B3X->B3X_STATUS := VALIDO
					B3X->B3X_ARQUIV := ""
					B3X->(MsUnlock())

					B3X->(DbSkip())
				EndDo

				//Limpo as críticas
				If CnLmpCriBen(B3R->(Recno()),"B3R")
					grvUsrCanc("B3R", "B3R_USRCAN", "B3R_DTHCAN")
					Reclock("B3R",.F.)
					B3R->(DbDelete())
					MsUnlock()
				Else
					DisarmTransaction()
				EndIf
			END TRANSACTION
		Else
			Alert("Este arquivo não pode ser excluido pois já foi importado o arquivo retorno.")
		Endif

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvUsrCanc

@author vinicius.nicolau
@since 30/09/2020
/*/
//--------------------------------------------------------------------------------------------------
Function grvUsrCanc(cAlias, cCampoUsr, cCampoData)
	If (cAlias)->(FieldPos(cCampoUsr)) > 0 .AND. (cAlias)->(FieldPos(cCampoData)) > 0
		Reclock(cAlias,.F.)
		(cAlias)->&(cCampoUsr) := strZero( val(RetCodUsr()),6)
		(cAlias)->&(cCampoData) := DToS(Date()) + " " + Time()
		MsUnlock()
	EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PodeExcluir


@param cArq		Nome do arquivo a ser excluido
@return lRet	Indica se pode excluir o arquivo

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PodeExcluir(cArq)
	Local lRet := .T.

	cSql := "SELECT count(1) TOTAL"
	cSql += " FROM " + RetSqlName("B3X") + " "
	cSql += " WHERE "
	cSql += " B3X_FILIAL = '" + xFilial("B3X") + "' "
	cSql += " AND B3X_ARQUIV = '"+ cArq +"'"
	cSql += " AND B3X_STATUS IN ('"+CRIT_ANS+"','"+ACAT_ANS+"')

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBARQ",.F.,.T.)

	lRet := TRBARQ->TOTAL == 0

	TRBARQ->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DOWNLSBX

@author p.drivas
@since 15/09/2020
/*/
//--------------------------------------------------------------------------------------------------
Function DOWNLSBX()
	local cPath := SelArq()
	local lCopiouSBX := CpyS2T( "\SIB\" + B3R->B3R_ARQUIV, cPath )
	local lCopiouCSV := CpyS2T( "\SIB\" + Left(AllTrim(B3R->B3R_ARQUIV),Len(AllTrim(B3R->B3R_ARQUIV))-4) + ".csv", cPath )
	local cMsg := ''
	If lCopiouSBX
		cMsg += 'Arquivo SBX copiado com sucesso.' + CRLF
	EndIf
	If lCopiouCSV
		cMsg += 'Arquivo CSV copiado com sucesso.' + CRLF
	EndIf
	MsgInfo(cMsg,'Aviso')
return nil

Static Function SelArq()
	local _cExtens   := "Diretório"//"Arquivo Texto ( *.TXT ) |*.TXT|"
	_cRet := cGetFile( _cExtens, "Selecione o Diretório",,, .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
	_cRet := ALLTRIM( _cRet )
Return( _cRet )
