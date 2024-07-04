#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"
#Include "OGAA750.ch"

/** {Protheus.doc} OGAA750
Rotina para cadastro de  tipos de remessas 

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	13/12/2017
@Uso: 		SIGAAGR - Originação de Grãos
@Autor:     Felipe Rafael Mendes
*/
Function OGAA750()
	Local oMBrowse	:= Nil
	  
	If !TableInDic('N96')
		Help( , , STR0008, , STR0012, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
		Return(Nil)
	EndIf 

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N96" )
	oMBrowse:SetDescription( STR0001 ) //"Tipos de Remessas"
	oMBrowse:Activate()
Return( )

/** {Protheus.doc} MenuDef

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@since: 	13/12/2017
@Uso: 		SIGAAGR - Originação de Grãos
@Autor:     Felipe Rafael Mendes
*/
Static Function MenuDef()
	Local aRotina	:= {}

	aAdd( aRotina, { STR0002	, "PesqBrw"			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003	, "ViewDef.OGAA750"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004	, "ViewDef.OGAA750"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005	, "ViewDef.OGAA750"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006	, "ViewDef.OGAA750"	, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007	, "ViewDef.OGAA750"	, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0008	, "ViewDef.OGAA750"	, 0, 9, 0, Nil } ) //"Copiar"	
Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function ModelDef()
	Local oStruN96	:= FWFormStruct( 1, "N96" )
	Local oStruN97	:= FWFormStruct( 1, "N97" )	
	Local oModel


	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New( "OGAA750", /*bPre*/ , /*bPos*/ , /*bCOmmit*/ , /*bCancel*/  )

	oModel:SetDescription( STR0001 ) //"Tipos de Remessas"
	oModel:AddFields( "N96UNICO", Nil, oStruN96 )
  //MPFORMMODEL():AddGrid(< cId >, < cOwner >, < oModelStruct >, < bLinePre >, < bLinePost >, < bPre >, < bLinePost >, < bLoad >)-> NIL
	oModel:AddGrid( "N97UNICO", "N96UNICO", oStruN97           ,             , { |oGrid,nline| ValidaGrid( oGrid,nline ) } ,         ,  ,  )
	oModel:GetModel( "N97UNICO" ):SetDescription( STR0010 ) //"Modalidade de Pagamento Exportação"
	oModel:GetModel( "N97UNICO" ):SetUniqueLine( { "N97_FILIAL", "N97_CODREM", "N97_MODPAG" } )
	oModel:GetModel( "N97UNICO" ):SetOptional( .t. )
	oModel:SetRelation( "N97UNICO", { { "N97_FILIAL", "xFilial( 'N97' )" }, { "N97_CODREM", "N96_CODREM" } }, N97->( IndexKey( 1 ) ) )

	oModel:GetModel( "N97UNICO" ):SetUseOldGrid( .f. ) //correção ponto de entrada - cadastro de fornecedores.	

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	13/12/2017
@Uso: 		OGAA750 - tipos de remessas 
*/
Static Function ViewDef()
	Local oStruN96	:= FWFormStruct( 2, "N96" )
	Local oStruN97	:= FWFormStruct( 2, "N97" )
	Local oModel	:= FWLoadModel( "OGAA750" )
	Local oView		:= FWFormView():New()

	oStruN97:RemoveField( "N97_CODREM" )
	
	oView:SetModel( oModel )	
	oView:AddField( "VIEW_N96", oStruN96, "N96UNICO" )
	oView:AddGrid( "VIEW_N97", oStruN97, "N97UNICO" )
	
	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 15, "TELANOVA" )
	oView:CreateHorizontalBox( "INFERIOR" , 85, "TELANOVA" )

	oView:SetOwnerView( "VIEW_N96", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_N97", "INFERIOR" )

	oView:EnableTitleView( "VIEW_N96" )
	oView:EnableTitleView( "VIEW_N97" )


	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} ValidaGrid
Função que valida o grid de dados 

@param:     oGrid - Gride do modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Felipe Rafael Mendes
@since:     13/12/2017
@Uso:       OGAA750
*/
Static Function ValidaGrid( oGrid, nline )
	//posiciona na linha que haverá a validação
    oGrid:GoLine( nline )
    If AGRIFDBSEEK("N97",oGrid:GetValue( "N97_MODPAG" ),2)
    	Help(,, STR0011,, STR0009 + POSICIONE('N97',2,XFILIAL('N97')+oGrid:GetValue( "N97_MODPAG" ),'N97_CODREM')  , 1, 0, ) //"AJUDA" , "A modalidade informada já está cadastrada no Tipo de Remessa: " 
    	Return .F.
    Endif
	
Return( .T. )