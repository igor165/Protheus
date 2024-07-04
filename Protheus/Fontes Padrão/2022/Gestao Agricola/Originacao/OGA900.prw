#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "OGA900.CH"


/*/{Protheus.doc} OGA900
Cadastro de Documentos do PEPRO.
@author thiago.rover
@since 04/06/2018
@version undefined

@type function
/*/
Function OGA900()
	Local oMBrowse		:= Nil

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("N9S")
	oMBrowse:SetMenuDef("OGA900")
	oMBrowse:SetDescription(STR0001) //Cadastro de Documentos PEPRO
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( Nil )


/*/{Protheus.doc} OGA900
Cadastro de Documentos do PEPRO
@author thiago.rover
@since 04/06/2018
@version undefined

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002	, 'VIEWDEF.OGA900', 0, 2, 0, NIL } )//STR0002 Visualisar
	aAdd( aRotina, { STR0003    , 'VIEWDEF.OGA900', 0, 3, 0, NIL } )//STR0003 Incluir
	aAdd( aRotina, { STR0004	, 'VIEWDEF.OGA900', 0, 4, 0, NIL } )//STR0004 Alterar
	aAdd( aRotina, { STR0005	, 'VIEWDEF.OGA900', 0, 5, 0, NIL } )//STR0005 Excluir 
	aAdd( aRotina, { STR0006	, 'VIEWDEF.OGA900', 0, 8, 0, NIL } )//STR0006 Imprimir

Return aRotina


/*/{Protheus.doc} OGA900
Cadastro de Documentos do PEPRO
@author thiago.rover
@since 04/06/2018
@version undefined

@type function
/*/
Static Function ModelDef()
	Local oStruN70 	:= FWFormStruct( 1,"N9S")
	Local oModel 	:= MPFormModel():New("OGA900")
	
	oModel:SetDescription(STR0001) //Cadastro de Documento PEPRO
	oModel:AddFields( 'N9SOGA900', /*cOwner*/, oStruN70 ) 
	oModel:SetPrimaryKey( { "N9S_FILIAL", "N9S_CODIGO", "N9S_DESCRI" } )
	oModel:GetModel( 'N9SOGA900' ):SetDescription( STR0001 )  //Cadastro de Documentos PEPRO
	
Return ( oModel )


/*/{Protheus.doc} OGA900
Cadastro de Documentos do PEPRO
@author thiago.rover
@since 04/06/2018
@version undefined

@type function
/*/ 
Static Function ViewDef()
	Local oStruN70	:= FWFormStruct( 2, "N9S" )
	Local oModel   	:= FWLoadModel( "OGA900" )
	Local oView    	:= FWFormView():New()
		
	oView:SetModel( oModel )
	oView:AddField( "OGA900_N9S", oStruN70, "N9SOGA900" )

	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 100, "TELANOVA" )
	oView:SetOwnerView( "OGA900_N9S", "SUPERIOR" )
	oView:EnableTitleView( "OGA900_N9S" )

	oView:SetCloseOnOk( {||.T.} )

Return (oView) 