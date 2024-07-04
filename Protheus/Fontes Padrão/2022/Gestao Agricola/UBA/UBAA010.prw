#INCLUDE "UBAA010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} UBAA010
//--Cadastro de Esteira
@author marcelo.wesan
@since 20/12/2016
/*/   
Function UBAA010()
	Local oMBrowse		:= Nil
	Private _cUserBenf 	:= A655GETUNB()// Busca a unidade de beneficiamento
   
	If !N70->(ColumnPos('N70_CODIGO'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	EndIf
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("N70")
	oMBrowse:SetMenuDef("UBAA010")
	oMBrowse:SetDescription(STR0006)	//Cadastro de Esteiras
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( Nil )


/*/{Protheus.doc} UBAA010
//--Cadastro de Esteira
@author marcelo.wesan
@since 20/12/2016
/*/  
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0001	, 'VIEWDEF.UBAA010', 0, 2, 0, NIL } )//STR0001 Visualisar
	aAdd( aRotina, { STR0002    , 'VIEWDEF.UBAA010', 0, 3, 0, NIL } )//STR0002 Incluir
	aAdd( aRotina, { STR0003	, 'VIEWDEF.UBAA010', 0, 4, 0, NIL } )//STR0003 Alterar
	aAdd( aRotina, { STR0004	, 'VIEWDEF.UBAA010', 0, 5, 0, NIL } )//STR0004 Excluir 
	aAdd( aRotina, { STR0005	, 'VIEWDEF.UBAA010', 0, 8, 0, NIL } )//STR0005 Imprimir

Return aRotina


/*/{Protheus.doc} UBAA010
//--Cadastro de Esteira
@author marcelo.wesan
@since 20/12/2016
/*/  
Static Function ModelDef()
	Local oStruN70 	:= FWFormStruct( 1,"N70")
	Local oModel 	:= MPFormModel():New("UBAA010")
	Default  _cUserBenf 	:= ''

	oModel:SetDescription(STR0006)
	oModel:AddFields( 'N70UBAA010', /*cOwner*/, oStruN70 )
	oModel:SetPrimaryKey( { "N70_FILIAL", "N70_CODIGO" } )//CODEST
	oModel:GetModel( 'N70UBAA010' ):SetDescription( STR0006 )//Cadastro de Esteiras
	
	If !Empty(_cUserBenf)
		oStruN70:SetProperty( "N70_CODUNB" ,MODEL_FIELD_OBRIGAT, .F.)
	EndIf

Return ( oModel )


/*/{Protheus.doc} UBAA010
//--Cadastro de Esteira
@author marcelo.wesan
@since 20/12/2016
/*/  
Static Function ViewDef()
	Local oStruN70	:= FWFormStruct( 2, "N70" )
	Local oModel   	:= FWLoadModel( "UBAA010" )
	Local oView    	:= FWFormView():New()
		
	oView:SetModel( oModel )
	oView:AddField( "UBAA010_N70", oStruN70, "N70UBAA010" )

	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 100, "TELANOVA" )
	oView:SetOwnerView( "UBAA010_N70", "SUPERIOR" )
	oView:EnableTitleView( "UBAA010_N70" )
	
	If !Empty(_cUserBenf)
		oStruN70:RemoveField( "N70_CODUNB" )
	EndIf

	oView:SetCloseOnOk( {||.T.} )

Return (oView) 
