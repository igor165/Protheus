#INCLUDE "JURA006.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA006
Prognostico

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA006()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQ7" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQ7" )
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
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA006", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA006", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA006", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA006", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA006", 0, 8, 0, NIL } ) //"Imprimir"
aAdd( aRotina, { STR0010, "JA006CFG"	 	 , 0, 3, 0, NIL } ) //"Config. Inicial"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Prognostico

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA006" )
Local oStruct := FWFormStruct( 2, "NQ7" )

JurSetAgrp( 'NQ7',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA006_VIEW", oStruct, "NQ7MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA006_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Prognostico"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Prognostico

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0

@obs NQ7MASTER - Dados do Prognostico

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQ7 := FWFormStruct( 1, "NQ7" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA006", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA006Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NQ7MASTER", NIL, oStructNQ7, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Prognostico"
oModel:GetModel( "NQ7MASTER" ):SetDescription( STR0009 ) //"Dados de Prognostico"

JurSetRules( oModel, 'NQ7MASTER',, 'NQ7' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA006Commit
Commit de dados de Prognóstico

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA006Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQ7MASTER","NQ7_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3 .AND. !IsInCallStack("JA006CFG")
		lRet := JurSetRest('NQ7',cCod) 
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA006CFG()
Rotina que faz a chamada do processamento da carga inicial

@author Reginaldo Natal Soares
@since 01/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA006CFG()

Local aArea		:= GetArea()
Local lRet			:= .F.
Local lGrv			:= .T.
Local oModel		:= ModelDef()
Local nI			:= 0
Local aPlvdes		:= {}

If IsInCallStack("JurLoadAsJ") .Or. ApMsgYesNo( STR0011 ) //"Serão incluídos novos Prognóticos padrão. Deseja continuar?"

	aAdd( aPlvdes, {STR0014, 75, "1"} ) //"Provável"
	aAdd( aPlvdes, {STR0015, 50, "2"} ) //"Possível"
	aAdd( aPlvdes, {STR0016, 25, "3"} ) //"Remoto"

	For nI:=1 To Len(aPlvdes)

		lRet := JA006PLVDE(aPlvdes[nI][1])
		lGrv	    := .T.

		If !lRet

			oModel:SetOperation( 3 )
			oModel:Activate()

			If !oModel:SetValue("NQ7MASTER",'NQ7_DESC'  ,aPlvdes[nI][1]) .Or. ;
			   !oModel:SetValue("NQ7MASTER",'NQ7_PORCEN',aPlvdes[nI][2]) .Or. ;
			   !oModel:SetValue("NQ7MASTER",'NQ7_TIPO'  ,aPlvdes[nI][3])
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
/*/{Protheus.doc} JA006PLVDE
Retorna .T./.F. se contiver a descrição indicada no parâmetro

@Param cDesc  Descrição

@Return lRet	 	.T./.F. Se a configuração existe ou não.

@author Reginaldo Natal Soares
@since 01/08/16
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA006PLVDE(cDesc)
Local aArea    := GetArea()
Local aAreaNQ7 := NQ7->( GetArea() )
Local cQuery   := ""
Local lRet     := .F.
Local cAlias

	cDesc := LOWER(PADR(JurLmpCpo(cDesc) + '', TamSx3('NQ7_DESC')[1]))

	cQuery := " SELECT NQ7_COD COD"
	cQuery +=     " FROM "+RetSqlName("NQ7")+" NQ7"
	cQuery +=   " WHERE NQ7_FILIAL = '" + xFilial( "NQ7" ) + "'"
	cQuery +=     " AND " + JurFormat("NQ7_DESC", .T./*lAcentua*/,.T./*lPontua*/) + " = '" +cDesc+ "'"
	cQuery +=     " AND NQ7.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	
	cAlias := GetNextAlias()
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	(cAlias)->( dbGoTop() )
	
	If !(cAlias)->( EOF() )
		lRet := .T.
	Endif

	(cAlias)->( dbcloseArea() )

RestArea(aAreaNQ7)
RestArea(aArea)
	
Return lRet
