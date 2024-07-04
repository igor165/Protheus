#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA500.ch"


/*/{Protheus.doc} AGRA500A
//View de dados básicos.
@author carlos.augusto
@since 24/11/2017
@version undefined
@type function
/*/
Function AGRA500A()

Return .T.

Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( 'AGRA500' )
	Local oStruNJJ := FWFormStruct( 2, "NJJ", {|cCampo| AllTRim(cCampo) $ "NJJ_CODROM|NJJ_TIPO|NJJ_TOETAP|NJJ_DESTPO|NJJ_CODSAF|NJJ_CODPRO|NJJ_UM1PRO|NJJ_LOCAL|NJJ_CODENT|NJJ_LOJENT|NJJ_FAZ|NJJ_TALHAO|NJJ_CODVAR" } )
		
	oView := FwFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'AGRA500A', oStruNJJ, 'AGRA500_NJJ' )
	
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	oView:SetOwnerView( 'AGRA500A', 'TOTAL' )

	oStruNJJ:AddFolder('FOLDER1', STR0022 ,'',2) //"Dados Básicos"

	oStruNJJ:SetProperty( 'NJJ_CODROM' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_TIPO'   , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_TOETAP' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DESTPO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_CODSAF' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_CODPRO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_UM1PRO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_LOCAL'  , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_CODENT' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_LOJENT' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_FAZ'    , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_TALHAO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_CODVAR' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')

	oStruNJJ:SetProperty( 'NJJ_CODENT' , MVC_VIEW_LOOKUP, 'NJ0' ) 

Return oView
