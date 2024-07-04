#INCLUDE "JURA087.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA087
Despesa Juridica

@author Raphael Zei Cartaxo Silva
@since 14/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA087()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NSR" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NSR" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Raphael Zei Cartaxo Silva
@since 14/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA087", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA087", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA087", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA087", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA087", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0010, "JA087CFG"	 	 , 0, 3, 0, NIL } ) //"Config. Inicial"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Despesa Juridica

@author Raphael Zei Cartaxo Silva
@since 14/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA087" )
Local oStruct := FWFormStruct( 2, "NSR" )

JurSetAgrp( 'NSR',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA087_VIEW", oStruct, "NSRMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA087_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Despesa Juridica"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Despesa Juridica

@author Raphael Zei Cartaxo Silva
@since 14/05/09
@version 1.0

@obs NSRMASTER - Dados do Despesa Juridica

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NSR" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA087", /*Pre-Validacao*/, /*Pos-Validacao*/,{|oX|JA087Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NSRMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Despesa Juridica"
oModel:GetModel( "NSRMASTER" ):SetDescription( STR0009 ) // "Dados de Despesa Juridica"

JurSetRules( oModel, 'NSRMASTER',, 'NSR' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA087Commit
Commit de dados de Tipo de Despesa

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA087Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NSRMASTER","NSR_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3 .AND. !IsInCallStack("JA087CFG")
		lRet := JurSetRest('NSR',cCod)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA087CFG()
Rotina que faz a chamada do processamento da carga inicial

@author Reginaldo Natal Soares
@since 03/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA087CFG()

Local aArea		:= GetArea()
Local lRet			:= .F.
Local lGrv			:= .T.
Local oModel		:= ModelDef()
Local nI			:= 0
Local aPlvdes		:= {}

If IsInCallStack("JurLoadAsJ") .Or. ApMsgYesNo( STR0011 ) //"Serão incluídos novos Tipos de Despesa. Deseja continuar?"

	aAdd( aPlvdes, {STR0014, "2"} ) //"Custas Judiciais"

	For nI:=1 To Len(aPlvdes)

		lRet := JA087PLVDE(aPlvdes[nI][1])
		lGrv	    := .T.

		If !lRet

			oModel:SetOperation( 3 )
			oModel:Activate()

			If !oModel:SetValue("NSRMASTER",'NSR_DESC'    ,aPlvdes[nI][1]) .Or. ;
			   !oModel:SetValue("NSRMASTER",'NSR_INTCTB'  ,aPlvdes[nI][2])
				lGrv := .F.
				JurMsgErro( I18N(STR0012, {""}) ) //Erro na carga da configuração inicial
				Exit
			EndIf

			If	lGrv
				If ( lRet := oModel:VldData() )
					oModel:CommitData()
				Else
					aErro := oModel:GetErrorMessage()
					JurMsgErro(aErro[6])
				EndIf
			EndIf

		  oModel:DeActivate()
		EndIf
	Next nI
Endif

RestArea(aArea)

Return Nil
 
//-------------------------------------------------------------------
/*/{Protheus.doc} JA087PLVDE
Retorna .T./.F. se contiver a descrição indicada no parâmetro

@Param cDesc  Descrição

@Return lRet	 	.T./.F. Se a configuração existe ou não.

@author Reginaldo Natal Soares
@since 03/08/16
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA087PLVDE(cDesc)
Local aArea    := GetArea()
Local aAreaNSR := NSR->( GetArea() )
Local cQuery   := ""
Local lRet     := .F.
Local cAlias

	cDesc := LOWER(PADR(JurLmpCpo(cDesc) + '', TamSx3('NSR_DESC')[1]))

	cQuery := " SELECT NSR_COD COD"
	cQuery +=     " FROM "+RetSqlName("NSR")+" NSR"
	cQuery +=   " WHERE NSR_FILIAL = '" + xFilial( "NSR" ) + "'"
	cQuery +=     " AND " + JurFormat("NSR_DESC", .T./*lAcentua*/,.T./*lPontua*/) + " = '" +cDesc+ "'"
	cQuery +=     " AND NSR.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	
	cAlias := GetNextAlias()
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	(cAlias)->( dbGoTop() )
	
	If !(cAlias)->( EOF() )
		lRet := .T.
	Endif

	(cAlias)->( dbcloseArea() )

RestArea(aAreaNSR)
RestArea(aArea)
	
Return lRet
