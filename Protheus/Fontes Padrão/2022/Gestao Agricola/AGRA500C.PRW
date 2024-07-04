#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA500.ch"


/*/{Protheus.doc} AGRA500C
//View de dados pesagem.
@author carlos.augusto
@since 24/11/2017
@version undefined
@type function
/*/
Function AGRA500C()

Return .T.

Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( 'AGRA500' )
	Local oStruNJJ := FWFormStruct( 2, "NJJ", {|cCampo| AllTRim(cCampo) $ "NJJ_CODROM|NJJ_PESO1|NJJ_MODPS1|NJJ_DATPS1|NJJ_HORPS1|NJJ_PESO2|NJJ_MODPS2|NJJ_DATPS2|NJJ_HORPS2|NJJ_PSSUBT|NJJ_PSDESC|NJJ_PSLIQU|NJJ_DIFFIS" } )
		
	oView := FwFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'AGRA500C', oStruNJJ, 'AGRA500_NJJ' )
	
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	oView:SetOwnerView( 'AGRA500C', 'TOTAL' )

	oStruNJJ:AddFolder('FOLDER1', STR0028 ,'',2) //"Dados de Pesagem do Romaneio" 

	oStruNJJ:SetProperty( 'NJJ_CODROM' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_PESO1'  , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_MODPS1' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DATPS1' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_HORPS1' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_PESO2'  , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_MODPS2' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DATPS2' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_HORPS2' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_PSSUBT' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_PSDESC' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_PSLIQU' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DIFFIS' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')

	oStruNJJ:SetProperty("NJJ_PSDESC" , MVC_VIEW_CANCHANGE ,.T.)
	oStruNJJ:SetProperty("NJJ_PSSUBT" , MVC_VIEW_CANCHANGE ,.F.)

	//-----------------
	//Adiciona botão
	//-----------------
	oView:AddUserButton( STR0007 , '', {|oView| AGRA500P(oView)} ) //"Pesagem" 

Return oView
