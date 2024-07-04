#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA500.ch"


/*/{Protheus.doc} AGRA500D
//View de dados fiscais.
@author silvana.torres
@since 29/11/2017
@version undefined

@type function
/*/
Function AGRA500D()

Return .T.

Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( 'AGRA500' )
	Local oStruNJJ 	:= FWFormStruct( 2, "NJJ", {|cCampo| AllTRim(cCampo) $ "NJJ_CODROM|NJJ_DOCNUM|NJJ_DOCSER|NJJ_DOCESP|NJJ_EST|NJJ_DOCEMI|NJJ_VLRUNI|NJJ_VLRTOT|NJJ_QTDFIS" } )
	Local lWhen		:= .T.			
		
	oView := FwFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'AGRA500D', oStruNJJ, 'AGRA500_NJJ' )
	
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	oView:SetOwnerView( 'AGRA500D', 'TOTAL' )

	oStruNJJ:AddFolder('FOLDER1', STR0032 ,'',2) //"Dados Fiscais"

	oStruNJJ:SetProperty('NJJ_CODROM' 	, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	
	oStruNJJ:SetProperty('NJJ_DOCNUM' 	, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty('NJJ_DOCSER' 	, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty('NJJ_DOCESP' 	, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty('NJJ_EST' 		, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty('NJJ_DOCEMI'  	, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty('NJJ_VLRUNI' 	, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty('NJJ_VLRTOT' 	, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty('NJJ_QTDFIS' 	, MVC_VIEW_FOLDER_NUMBER, 'FOLDER1') 
	
	oStruNJJ:SetProperty("NJJ_DOCNUM"   , MVC_VIEW_ORDEM		, '19')
	oStruNJJ:SetProperty("NJJ_DOCSER"   , MVC_VIEW_ORDEM		, '20')
	oStruNJJ:SetProperty("NJJ_DOCESP"   , MVC_VIEW_ORDEM		, '21')
	oStruNJJ:SetProperty("NJJ_EST"  	, MVC_VIEW_ORDEM		, '22')
	oStruNJJ:SetProperty("NJJ_DOCEMI"  	, MVC_VIEW_ORDEM		, '23')
	oStruNJJ:SetProperty('NJJ_QTDFIS' 	, MVC_VIEW_ORDEM		, '27')

Return oView
