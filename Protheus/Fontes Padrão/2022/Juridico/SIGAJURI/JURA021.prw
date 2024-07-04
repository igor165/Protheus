#INCLUDE "JURA021.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//----------------------------------------------------------------------
/*/{Protheus.doc} JURA021
Tipos de Follow-up

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0
/*/
//----------------------------------------------------------------------
Function JURA021()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQS" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQS" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL
//----------------------------------------------------------------------
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
@since 05/05/09
@version 1.0
/*/
//------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA021", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA021", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA021", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA021", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA021", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0012, "JA021CFG"	 	 , 0, 3, 0, NIL } ) //"Config. Inicial"

Return aRotina
//------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipos de Follow-up

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0
/*/
//------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := FwLoadModel( "JURA021" )
Local oStructNQS
Local oStructNVD

//------------------------------------------------------------------------
//Montagem da interface via dicionario de dados
//------------------------------------------------------------------------
oStructNQS := FWFormStruct( 2, "NQS" )
oStructNVD := FWFormStruct( 2, "NVD" )

oStructNVD:RemoveField( "NVD_CTIPOF" )

//------------------------------------------------------------------------
//Montagem do View normal se Container
//------------------------------------------------------------------------
JurSetAgrp( 'NQS',, oStructNQS )

oView := FWFormView():New()

oView:SetModel( oModel )
oView:SetDescription( STR0007 ) // "Tipos de Follow-up"

oView:AddField( "JURA021_TIPOFU", oStructNQS , "NQSMASTER" )
oView:AddGrid(  "JURA021_DETAIL", oStructNVD , "NVDDETAIL" )

oView:CreateHorizontalBox( "FORMTIPOFU", 50 )
oView:CreateHorizontalBox( "FORMDETAIL", 50 )

oView:SetOwnerView( "NQSMASTER", "FORMTIPOFU" )
oView:SetOwnerView( "NVDDETAIL", "FORMDETAIL" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView
	
//------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipos de Follow-up

@author Clovis E. Teixeira dos Santos
@since 05/05/09
@version 1.0

@obs NQSMASTER - Cabecalho Tipos de Follow-up / NRTDETAIL - Itens Tipos de Follow-up
/*/
//------------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := NIL
Local oStructNQS
Local oStructNVD

//-------------------------------------------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-------------------------------------------------------------------------
oStructNQS := FWFormStruct(1,"NQS")
oStructNVD := FWFormStruct(1,"NVD")

oStructNVD:RemoveField( "NVD_CTIPOF" )

//-------------------------------------------------------------------------
//Monta o modelo do formulário
//-------------------------------------------------------------------------
oModel:= MpFormModel():New( "JURA021", /*Pre-Validacao*/, {|oModel| JURA021TOK(oModel)}/*Pos-Validacao*/,{|oX|JA021Commit(oX)}/*Commit*/ )
oModel:SetDescription( STR0007 ) // "Modelo de Dados da Tipos de Follow-up"

oModel:AddFields( "NQSMASTER", /*cOwner*/, oStructNQS, /*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:AddGrid( "NVDDETAIL", "NQSMASTER" /*cOwner*/, oStructNVD, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )

oModel:GetModel( "NQSMASTER" ):SetDescription( STR0008 ) // "Cabecalho Tipos de Follow-up"
oModel:GetModel( "NVDDETAIL" ):SetDescription( STR0009 ) // "Itens Tipos de Follow-up"

oModel:SetRelation( "NVDDETAIL", { { "NVD_FILIAL", "XFILIAL('NVD')" }, { "NVD_CTIPOF", "NQS_COD" } }, NVD->( IndexKey( 1 ) ) )
                                                 
oModel:GetModel( 'NVDDETAIL' ):SetDelAllLine( .T. )    

oModel:SetOptional( 'NVDDETAIL' , .T. )

JurSetRules( oModel, 'NQSMASTER',, 'NQS' )
JurSetRules( oModel, 'NVDDETAIL',, 'NVD' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA021Commit
Commit de dados de Tipo de Follow-up

@author Jorge Luis Branco Martins Junior
@since 17/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA021Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQSMASTER","NQS_COD")
Local nOpc := oModel:GetOperation()

FWFormCommit(oModel)
  
If nOpc == 3 .AND. !IsInCallStack("JA021CFG")
	lRet := JurSetRest('NQS',cCod)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA021TOK
Verifica o preenchimento dos campos

@param 	oModel  	Model a ser verificado
@Return lTudoOk	    Valor lógico de retorno

@author Wellignton Coelho
@since 30/09/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA021TOK( oModel )
Local lTudoOk		:= .T.

If oModel:GetModel('NQSMASTER'):HasField("NQS_TAPROV") //valida se o campo tipo de aprovação existe
	If oModel:GetValue("NQSMASTER","NQS_TAPROV") $ '12345' .AND. Empty(oModel:GetValue("NQSMASTER","NQS_DESPAD"))
		JurMsgErro(STR0010)//"Quando é selecionado algum tipo de aprovação Fluig, é necessário preencher a descrição do tipo de Follow-up"
		lTudoOk := .F.
	EndIF
	
	If !Empty (oModel:GetValue("NQSMASTER","NQS_TAPROV")) .And. (( oModel:GetOperation()==3 ) .Or. ( oModel:GetOperation()==4 .And. oModel:IsFieldUpdated("NQSMASTER","NQS_TAPROV") )) //3=Inclusão; 4=Alteração
		lTudoOk := J021TpApr( oModel:GetValue("NQSMASTER","NQS_TAPROV") ) //Valida se existe o tipo de Fw Tp de Aprov como Encerrado
	Endif
Endif

Return lTudoOk


//-------------------------------------------------------------------
/*/{Protheus.doc} J021TpApr(cTipoFw)
Valida se existe cadastrado na NQS um tipo de Follow-UP com o mesmo tipo de aprovação no fluig, se existe não permite cadastrar
Uso geral.

@param	cTipoFw

@return	 lRetorno - Informando se existe ou nao cadastrado o tipo de follow-up com tipo Aprov ao passado por cTipoFw

@author Reginaldo N Soares
@since 17/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J021TpApr(cTAprov)
Local cQuery		:= ""
Local cAliasNQS	:= GetNextAlias()
Local aArea		:= GetArea()
Local lRetorno		:= .T.
Local cValor		:= ""

cQuery := " SELECT NQS_COD, NQS_TAPROV "+ CRLF
cQuery +=     " FROM "+RetSqlName("NQS")+" NQS "+ CRLF
cQuery +=   " WHERE NQS.D_E_L_E_T_ = ' ' " + CRLF 
cQuery +=     " AND NQS.NQS_TAPROV   = '" + cTAprov   + "' "
cQuery +=     " AND NQS.NQS_FILIAL = '" + xFilial("NQS") + "' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNQS,.T.,.T.)

(cAliasNQS)->( dbGoTop() )

	 
IF !(cAliasNQS)->( EOF() )
	cValor := JTrataCbox( "NQS_TAPROV", AllTrim(AllToChar(cTAprov)) ) //Retorna o valor do campo
	JurMsgErro( I18N(STR0011, {cValor})) //"Já existe Follow-Up cadastrado com o tipo de Aprovação igial a #1"
	lRetorno := .F.
Endif

(cAliasNQS)->( dbcloseArea() )

RestArea(aArea)
	
Return lRetorno	

//-------------------------------------------------------------------
/*/{Protheus.doc} JA021CFG()
Rotina que faz a chamada do processamento da carga inicial

@author Reginaldo Natal Soares
@since 03/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA021CFG()

Local aArea		:= GetArea()
Local lRet			:= .F.
Local lGrv			:= .T.
Local oModel		:= ModelDef()
Local nI			:= 0
Local aPlvdes		:= {}

If IsInCallStack("JurLoadAsJ") .Or. ApMsgYesNo( STR0013 ) //"Serão incluídos novos Tipos de Follow-up padrão. Deseja continuar?"

	aAdd( aPlvdes, {STR0016, "1", "2", "2"} ) //"Acompanhamento"
	aAdd( aPlvdes, {STR0017, "2", "1", "2"} ) //"Audiência"
	aAdd( aPlvdes, {STR0018, "3", "1", "2"} ) //"Julgamento"
	aAdd( aPlvdes, {STR0019, "4", "2", "1"} ) //"Prazo"
	aAdd( aPlvdes, {STR0020, "1", "2", "2"} ) //"Providências"
	aAdd( aPlvdes, {STR0021, "5", "1", "2"} ) //"Reunião"

	For nI:=1 To Len(aPlvdes)

		lRet := JA021PLVDE(aPlvdes[nI][1])
		lGrv	    := .T.

		If !lRet

			oModel:SetOperation( 3 )
			oModel:Activate()

			If !oModel:SetValue("NQSMASTER",'NQS_DESC'   ,aPlvdes[nI][1]) .Or. ;
			   !oModel:SetValue("NQSMASTER",'NQS_TIPO'   ,aPlvdes[nI][2]) .Or. ;
			   !oModel:SetValue("NQSMASTER",'NQS_HORAM'  ,aPlvdes[nI][3]) .Or. ;
			   !oModel:SetValue("NQSMASTER",'NQS_SUGERE' ,aPlvdes[nI][4])
				lGrv := .F.
				JurMsgErro( I18N(STR0014, {""}) ) //Erro na carga da configuração inicial
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
/*/{Protheus.doc} JA021PLVDE
Retorna .T./.F. se contiver a descrição indicada no parâmetro

@Param cDesc  Descrição

@Return lRet	 	.T./.F. Se a configuração existe ou não.

@author Reginaldo Natal Soares
@since 03/08/16
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA021PLVDE(cDesc)
Local aArea    := GetArea()
Local aAreaNQS := NQS->( GetArea() )
Local cQuery   := ""
Local lRet     := .F.
Local cAlias

	cDesc := LOWER(PADR(JurLmpCpo(cDesc) + '', TamSx3('NQS_DESC')[1]))

	cQuery := " SELECT NQS_COD COD"
	cQuery +=     " FROM "+RetSqlName("NQS")+" NQS"
	cQuery +=   " WHERE NQS_FILIAL = '" + xFilial( "NQS" ) + "'"
	cQuery +=     " AND " + JurFormat("NQS_DESC", .T./*lAcentua*/,.T./*lPontua*/) + " = '" +cDesc+ "'"
	cQuery +=     " AND NQS.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	
	cAlias := GetNextAlias()
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	(cAlias)->( dbGoTop() )
	
	If !(cAlias)->( EOF() )
		lRet := .T.
	Endif

	(cAlias)->( dbcloseArea() )

RestArea(aAreaNQS)
RestArea(aArea)
	
Return lRet
