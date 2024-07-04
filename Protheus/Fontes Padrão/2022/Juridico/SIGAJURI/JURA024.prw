#INCLUDE "JURA024.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA024
Tipo de Garantia

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA024()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQW" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NQW" )
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

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA024", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA024", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA024", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA024", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA024", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0011, "JA024CFG"	 	 , 0, 3, 0, NIL } ) //"Config. Inicial"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Garantia

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA024" )
Local oStruct := FWFormStruct( 2, "NQW" )

JurSetAgrp( 'NQW',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA024_VIEW", oStruct, "NQWMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA024_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Tipo de Garantia"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Garantia

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0

@obs NQWMASTER - Dados do Tipo de Garantia

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NQW" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA024", /*Pre-Validacao*/, {|oX| JURA024TOK(oX)}/*Pos-Validacao*/, {|oX|JA024Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NQWMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo de Garantia"
oModel:GetModel( "NQWMASTER" ):SetDescription( STR0009 ) // "Dados de Tipo de Garantia"

JurSetRules( oModel, 'NQWMASTER',, 'NQW' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA024Commit
Commit de dados de Tipo de garantia

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA024Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQWMASTER","NQW_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3 .AND. !IsInCallStack("JA024CFG")
		lRet := JurSetRest('NQW',cCod)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA024TOK
Valida dados de Tipo de garantia

@param 	oModel  	 Modelo a ser verificado	
@Return lRet	 	   .T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 23/04/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA024TOK(oModel)
Local lRet		:= .T.
Local cGrupo	:= oModel:GetValue("NQWMASTER","NQW_GRPAPR")
Local cTipo		:= oModel:GetValue("NQWMASTER","NQW_TIPO")

	If cTipo == '2' .And. !Empty(Alltrim(cGrupo))
		lRet := .F.
		JurMsgErro(STR0010)//Não é permitido ter grupo de aprovação para Alvará
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J024WHENGP
When do campo de grupo de aprovacao. Só será habilitado caso a 
integracao Juri x Contabil x Financeiro estiver ativa e o campo 
de tipo de despesa estiver com o tipo GARANTIA

@param 	oModel  	 Modelo a ser verificado	
@Return lRet	 	   .T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 23/04/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J024WHENGP()
Local lRet	:= .F.
	If ((SuperGetMV('MV_JINTVAL',, '2') == '1') .And. (SuperGetMV('MV_JALCADA',, '2') == '1') .And. M->NQW_TIPO == "1" .And. M->NQW_INTCOM == "1")
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA024CFG()
Rotina que faz a chamada do processamento da carga inicial

@author Reginaldo Natal Soares
@since 03/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA024CFG()

Local aArea		:= GetArea()
Local lRet			:= .F.
Local lGrv			:= .T.
Local oModel		:= ModelDef()
Local nI			:= 0
Local aPlvdes		:= {}

If IsInCallStack("JurLoadAsJ") .Or. ApMsgYesNo( STR0012 ) //"Serão incluídos novos Tipos de Garantia. Deseja continuar?"

	aAdd( aPlvdes, {STR0015, "1", "2"} ) //"Arrolamento de Bens"
	aAdd( aPlvdes, {STR0016, "1", "1"} ) //"Carta de Fiança"
	aAdd( aPlvdes, {STR0017, "1", "2"} ) //"Caução"
	aAdd( aPlvdes, {STR0018, "1", "2"} ) //"Depósito Judicial"
	aAdd( aPlvdes, {STR0019, "2", "2"} ) //"Levantamento"
	aAdd( aPlvdes, {STR0020, "1", "2"} ) //"Penhora"

	For nI:=1 To Len(aPlvdes)

		lRet := JA024PLVDE(aPlvdes[nI][1])
		lGrv	    := .T.

		If !lRet

			oModel:SetOperation( 3 )
			oModel:Activate()

			If !oModel:SetValue("NQWMASTER",'NQW_DESC'  ,aPlvdes[nI][1]) .Or. ;
			   !oModel:SetValue("NQWMASTER",'NQW_TIPO'  ,aPlvdes[nI][2]) .Or. ;
			   !oModel:SetValue("NQWMASTER",'NQW_PRAZO' ,aPlvdes[nI][3])
				lGrv := .F.
				JurMsgErro( I18N(STR0013, {""}) ) //Erro na carga da configuração inicial
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
/*/{Protheus.doc} JA024PLVDE
Retorna .T./.F. se contiver a descrição indicada no parâmetro

@Param cDesc  Descrição

@Return lRet	 	.T./.F. Se a configuração existe ou não.

@author Reginaldo Natal Soares
@since 03/08/16
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA024PLVDE(cDesc)
Local aArea    := GetArea()
Local aAreaNQW := NQW->( GetArea() )
Local cQuery   := ""
Local lRet     := .F.
Local cAlias

	cDesc := LOWER(PADR(JurLmpCpo(cDesc) + '', TamSx3('NQW_DESC')[1]))

	cQuery := " SELECT NQW_COD COD"
	cQuery +=     " FROM "+RetSqlName("NQW")+" NQW"
	cQuery +=   " WHERE NQW_FILIAL = '" + xFilial( "NQW" ) + "'"
	cQuery +=     " AND " + JurFormat("NQW_DESC", .T./*lAcentua*/,.T./*lPontua*/) + " = '" +cDesc+ "'"
	cQuery +=     " AND NQW.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	
	cAlias := GetNextAlias()
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	(cAlias)->( dbGoTop() )
	
	If !(cAlias)->( EOF() )
		lRet := .T.
	Endif

	(cAlias)->( dbcloseArea() )

RestArea(aAreaNQW)
RestArea(aArea)
	
Return lRet
