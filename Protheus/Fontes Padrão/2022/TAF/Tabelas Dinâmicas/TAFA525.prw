#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA525.CH"


/*/{Protheus.doc} TAFA525
	Tabela autocontida criada para evento do e-Social S-5011
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@type function
/*/
Function TAFA525()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription( STR0001 ) //"Indicativos de Comercialização"
oBrw:SetAlias( "V29" )
oBrw:SetMenuDef( "TAFA525" )
V29->( DBSetOrder( 1 ) )
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
Return xFunMnuTAF( "TAFA525",,,, .T. )


/*/{Protheus.doc} ModelDef
	Modelo da rotina 
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ModelDef()

Local oStruV29 := FwFormStruct( 1, "V29" )
Local oModel   := MpFormModel():New( "TAFA525" )

oModel:AddFields( "MODEL_V29", /*cOwner*/, oStruV29 )
oModel:GetModel ( "MODEL_V29" ):SetPrimaryKey( { "V29_FILIAL", "V29_ID" } )

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

Local oModel   := FwLoadModel( "TAFA525" )
Local oStruV29 := FwFormStruct( 2, "V29" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V29", oStruV29, "MODEL_V29" )
oView:EnableTitleView( "VIEW_V29", STR0001 ) //"Indicativos de Comercialização"
oView:CreateHorizontalBox( "FIELDSV29", 100 )
oView:SetOwnerView( "VIEW_V29", "FIELDSV29" )

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

nVerAtu := 1025.03

If nVerEmp < nVerAtu
	aAdd( aHeader, "V29_FILIAL" )
	aAdd( aHeader, "V29_ID" )
	aAdd( aHeader, "V29_CODIGO" )
	aAdd( aHeader, "V29_DESCRI" )
	aAdd( aHeader, "V29_VALIDA" )

	aAdd( aBody, { "", "000001", "2", "Comercialização da Produção efetuada diretamente no varejo a consumidor final ou a outro produtor rural pessoa física por Produtor Rural Pessoa Física, inclusive por Segurado Especial ou por Pessoa Física não produtor rural"		, "" } )
	aAdd( aBody, { "", "000002", "3", "Comercialização da Produção por Prod. Rural PF/Seg. Especial - Vendas a PJ (exceto Entidade inscrita no Programa de Aquisição de Alimentos - PAA) ou a Intermediário PF"																, "" } )
	aAdd( aBody, { "", "000003", "7", "Comercialização da Produção Isenta de acordo com a Lei n° 13.606/2018"																																								, "" } )
	aAdd( aBody, { "", "000004", "8", "Comercialização da Produção da Pessoa Física/Segurado Especial para Entidade inscrita no Programa de Aquisição de Alimentos - PAA"																									, "" } )
	aAdd( aBody, { "", "000005", "9", "Comercialização da Produção no Mercado Externo"																																														, "" } )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
