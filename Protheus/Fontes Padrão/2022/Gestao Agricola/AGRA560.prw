#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "AGRW560.CH"


/*/{Protheus.doc} AGRA560
//Fonte provisório para chamar Integracao da Situacao do Local de Producao	
@author carlos.augusto/brunosilva
@since 24/05/2018
@version undefined
@type function
/*/
Function AGRA560()
	Local oMBrowse		:= Nil
	DbSelectArea("N9F")
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("N9F")
	oMBrowse:SetMenuDef("AGRA560")
	oMBrowse:SetDescription(STR0004) //Integração da Situação do Local de Produção	
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( Nil )


Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { "Integrar Teste"	, 'AGRA560INT()', 0, 3, 0, NIL } )
Return aRotina


Static Function ModelDef()
	Local oStruN9F 	:= FWFormStruct( 1,"N9F")
	Local oModel 	:= MPFormModel():New("AGRA560")
	
	oModel:SetDescription(STR0005) //"Situacao do Local de Producao"
	oModel:AddFields( 'N9FAGRA560', /*cOwner*/, oStruN9F )
	oModel:SetPrimaryKey( { "N9F_FILIAL", "N9F_CODIGO" } )
	oModel:GetModel( 'N9FAGRA560' ):SetDescription( STR0005 ) //"Situacao do Local de Producao"
	

Return ( oModel )

Static Function ViewDef()

	Local oStruN9F	:= FWFormStruct( 2, "N9F" )
	Local oModel   	:= FWLoadModel( "AGRA560" )
	Local oView    	:= FWFormView():New()
		
	oView:SetModel( oModel )
	oView:AddField( "AGRA560_N9F", oStruN9F, "N9FAGRA560" )

	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 100, "TELANOVA" )
	oView:SetOwnerView( "AGRA560_N9F", "SUPERIOR" )
	oView:EnableTitleView( "AGRA560_N9F" )
	
	oView:SetCloseOnOk( {||.t.} )

Return (oView) 

	
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet := {}

	If FindFunction("AGRW560")
		aRet:= AGRW560( cXml, nTypeTrans, cTypeMessage )
	EndIf
Return aRet

Function AGRA560INT()
	Local aRet := {}

	Processa({|| aRet := FWIntegDef( "AGRA560", EAI_MESSAGE_BUSINESS, TRANS_SEND, "", "AGRA560")}, "Enviando dados para o Protheus" )

Return .T.