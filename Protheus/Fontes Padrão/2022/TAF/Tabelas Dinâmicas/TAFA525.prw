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

oBrw:SetDescription( STR0001 ) //"Indicativos de Comercializa��o"
oBrw:SetAlias( "V29" )
oBrw:SetMenuDef( "TAFA525" )
V29->( DBSetOrder( 1 ) )
oBrw:Activate()

Return 


/*/{Protheus.doc} MenuDef
	Defini��o do menu da rotina
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
oView:EnableTitleView( "VIEW_V29", STR0001 ) //"Indicativos de Comercializa��o"
oView:CreateHorizontalBox( "FIELDSV29", 100 )
oView:SetOwnerView( "VIEW_V29", "FIELDSV29" )

Return( oView )


/*/{Protheus.doc} FAtuCont
	Fun��o que carrega os dados da autocontida de acordo com a vers�o do cliente
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

	aAdd( aBody, { "", "000001", "2", "Comercializa��o da Produ��o efetuada diretamente no varejo a consumidor final ou a outro produtor rural pessoa f�sica por Produtor Rural Pessoa F�sica, inclusive por Segurado Especial ou por Pessoa F�sica n�o produtor rural"		, "" } )
	aAdd( aBody, { "", "000002", "3", "Comercializa��o da Produ��o por Prod. Rural PF/Seg. Especial - Vendas a PJ (exceto Entidade inscrita no Programa de Aquisi��o de Alimentos - PAA) ou a Intermedi�rio PF"																, "" } )
	aAdd( aBody, { "", "000003", "7", "Comercializa��o da Produ��o Isenta de acordo com a Lei n� 13.606/2018"																																								, "" } )
	aAdd( aBody, { "", "000004", "8", "Comercializa��o da Produ��o da Pessoa F�sica/Segurado Especial para Entidade inscrita no Programa de Aquisi��o de Alimentos - PAA"																									, "" } )
	aAdd( aBody, { "", "000005", "9", "Comercializa��o da Produ��o no Mercado Externo"																																														, "" } )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
