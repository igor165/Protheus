#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"


/*/{Protheus.doc} ViewDef
//Função de criação da view padrão da rotina de novo romaneio
@author bruna.rocio
@since 22/11/2017
@version undefined
@type function
/*/
Static Function ViewDef()
	Local oView    := Nil
	Local oModel   := FwLoadModel('AGRA500')
	Local oStrNJJ  := FwFormStruct( 2, "NJJ", {|cCampo| (Alltrim(cCampo) $ 'NJJ_CODROM|NJJ_CODTRA|NJJ_PLACA|NJJ_CGC|NJJ_NOMTRA|NJJ_NOMMOT|NJJ_TPFRET')} )
							
	oStrNJJ:SetProperty('NJJ_TPFRET', MVC_VIEW_COMBOBOX, { "C=CIF", "F=FOB" })	
	oStrNJJ:SetProperty('NJJ_CGC'   , MVC_VIEW_ORDEM , '08')
	oStrNJJ:SetProperty('NJJ_PLACA' , MVC_VIEW_ORDEM , '10')
	oStrNJJ:SetProperty('NJJ_CGC'   , MVC_VIEW_PICT  , '@R 999.999.999-99999')				
	oStrNJJ:SetProperty('NJJ_CGC'   , MVC_VIEW_LOOKUP , 'DA4NJJ')
	oStrNJJ:SetProperty('NJJ_PLACA' , MVC_VIEW_LOOKUP , 'DA3')							
																  
	oView := FwFormView():New()
	oView:SetModel( oModel )															  
	 
	oView:AddField( 'VIEW_NJJ_TRANSP', oStrNJJ , 'AGRA500_NJJ' )
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	oView:SetOwnerView( 'VIEW_NJJ_TRANSP' ,'TOTAL' )
Return oView

