#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA500.ch"


/*/{Protheus.doc} AGRA500F
//View de dados básicos.
@author carlos.augusto
@since 24/11/2017
@version undefined
@type function
/*/
Function AGRA500F()

Return .T.


Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( 'AGRA500' )
	Local oStruNJJ := FWFormStruct( 2, "NJJ", {|cCampo| AllTRim(cCampo) $ "NJJ_CODROM|NJJ_TIPO|NJJ_TOETAP|NJJ_DESTPO" } )
	Local oStruNJK 	:= FWFormStruct( 2, "NJK" )
	
	oView := FwFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'AGRA500F', oStruNJJ, 'AGRA500_NJJ' )
	oView:AddGrid( "V500_NJK", oStruNJK, "AGRA500_NJK",, /*Get Focus*/)
	
	oStruNJK:RemoveField( "NJK_CODROM" )
	oStruNJK:RemoveField( "NJK_RESINF"  )
	oStruNJK:RemoveField( "NJK_CLASSP" )
	
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	oView:SetOwnerView( 'AGRA500F', 'TOTAL' )



Return oView
