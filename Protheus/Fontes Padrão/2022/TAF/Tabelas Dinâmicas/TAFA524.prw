#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA524.CH"


/*/{Protheus.doc} TAFA522
	Tabela autocontida criada para evento do e-Social S-5011
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@type function
/*/
Function TAFA524()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription( STR0001 ) //"Indicativos da Aquisição"
oBrw:SetAlias( "V28" )
oBrw:SetMenuDef( "TAFA524" )
V28->( DBSetOrder( 1 ) )
oBrw:Activate()

Return 


/*/{Protheus.doc} MenuDef
	Definição do menu da rotina
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function MenuDef()
Return xFunMnuTAF( "TAFA524",,,, .T. )


/*/{Protheus.doc} ModelDef
	Modelo da rotina 
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ModelDef()

Local oStruV28 := FwFormStruct( 1, "V28" )
Local oModel   := MpFormModel():New( "TAFA524" )

oModel:AddFields( "MODEL_V28", /*cOwner*/, oStruV28 )
oModel:GetModel ( "MODEL_V28" ):SetPrimaryKey( { "V28_FILIAL", "V28_ID" } )

Return( oModel )


/*/{Protheus.doc} ViewDef
	View da rotina
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA524" )
Local oStruV28 := FwFormStruct( 2, "V28" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V28", oStruV28, "MODEL_V28" )
oView:EnableTitleView( "VIEW_V28", STR0001 ) //"Indicativos da Aquisição"
oView:CreateHorizontalBox( "FIELDSV28", 100 )
oView:SetOwnerView( "VIEW_V28", "FIELDSV28" )

Return( oView )


/*/{Protheus.doc} FAtuCont
	Função que carrega os dados da autocontida de acordo com a versão do cliente
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@param nVerEmp, numeric, descricao
	@param nVerAtu, numeric, descricao
	@type function
/*/
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1025.02

If nVerEmp < nVerAtu
	aAdd( aHeader, "V28_FILIAL" )
	aAdd( aHeader, "V28_ID" )
	aAdd( aHeader, "V28_CODIGO" )
	aAdd( aHeader, "V28_DESCRI" )
	aAdd( aHeader, "V28_VALIDA" )

	aAdd( aBody, { "", "000001", "1", "Aquisição da produção de produtor rural pessoa física ou segurado especial em geral"																, "" } )
	aAdd( aBody, { "", "000002", "2", "Aquisição da produção de produtor rural pessoa física ou segurado especial em geral por Entidade do PAA"											, "" } )
	aAdd( aBody, { "", "000003", "3", "Aquisição da produção de produtor rural pessoa jurídica por Entidade do PAA"																		, "" } )
	aAdd( aBody, { "", "000004", "4", "Aquisição da produção de produtor rural pessoa física ou segurado especial em geral - Produção Isenta (Lei 13.606/2018)"							, "" } )
	aAdd( aBody, { "", "000005", "5", "Aquisição da produção de produtor rural pessoa física ou segurado especial em geral por Entidade do PAA - Produção Isenta (Lei 13.606/2018)"		, "" } )
	aAdd( aBody, { "", "000006", "6", "Aquisição da produção de produtor rural pessoa jurídica por Entidade do PAA - Produção Isenta (Lei 13.606/2018)"									, "" } )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
