#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA220.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Cadastro de Entidades 

@sample		CRMA220( uRotAuto, nOpcAuto )

@param		uRotAuto - Array com os valores 
			nOpcAuto - Numero de identificacao da operacao
			
@return		ExpL - Verdadeiro / Falso  

@author		Thiago Tavares
@since		24/02/2014
@version	12.0
/*/
//-------------------------------------------------------------------
Function CRMA220( uRotAuto, nOpcAuto )

Local oBrowse := Nil

Private lMsErroAuto := .F.

If uRotAuto == Nil .AND. nOpcAuto == Nil

	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias( "AO2" ) 
	oBrowse:SetDescription( STR0005 )								// "Controle de Entidades"
	oBrowse:SetAttach( .T. ) 				  						//Habilita as visões do Browse
	oBrowse:SetTotalDefault( "AO2_FILIAL", "COUNT", STR0008) 		// "Total de Registros"
	oBrowse:Activate()
	
Else
	FWMVCRotAuto( ModelDef(), "AO2", nOpcAuto, { { "AO2MASTER", uRotAuto } }, /*lSeek*/, .T. )
  	If lMsErroAuto  
  		MostraErro() 
  	Endif 
EndIf

Return !( lMsErroAuto )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do modelo de Dados

@sample		ModelDef()

@param		Nenhum
			
@return		ExpO - Objeto do modelo de dados  

@author		Thiago Tavares
@since		24/02/2014
@version	12.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	 := Nil
Local oStructAO2 := FWFormStruct( 1, "AO2", /*bAvalCampo*/, /*lViewUsado*/ )

oModel := MPFormModel():New( "CRMA220", /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)
oModel:AddFields( "AO2MASTER", /*cOwner*/, oStructAO2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey( { "AO2_FILIAL", "AO2_ENTID" } )
oModel:SetDescription( STR0005 )		// "Controle de Entidades"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da interface

@sample		ViewDef()

@param		Nenhum
			
@return		ExpO - Objeto do modelo da interface  

@author		Thiago Tavares
@since		24/02/2014
@version	12.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= Nil
Local oModel 		:= FwLoadModel( "CRMA220" )
Local oStructAO2	:= FWFormStruct( 2, "AO2" )

oStructAO2:AddGroup( "GRUPO01", STR0006, "", 2 )		// "Entidade"
oStructAO2:SetProperty( "*" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )

oStructAO2:AddGroup( "GRUPO02", STR0007,  "", 2 )	// "Rotinas"
oStructAO2:SetProperty( "AO2_ESPEC",  MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAO2:SetProperty( "AO2_ATIV",   MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAO2:SetProperty( "AO2_CONEX",  MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAO2:SetProperty( "AO2_ANOTAC", MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAO2:SetProperty( "AO2_MEMAIL", MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAO2:SetProperty( "AO2_CEMAIL", MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStructAO2:SetProperty( "AO2_WAVIEW", MVC_VIEW_GROUP_NUMBER, "GRUPO02" )   
oStructAO2:SetProperty( "AO2_AGRREG", MVC_VIEW_GROUP_NUMBER, "GRUPO02" )

oView := FWFormView():New()
oView:SetContinuousForm()

oView:SetModel( oModel )
oView:AddField( "VIEW_AO2" , oStructAO2, "AO2MASTER" ) 
oView:CreateHorizontalBox( "BOXFORM1", 100 )
oView:SetOwnerView( "VIEW_AO2", "BOXFORM1" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição das rotinas do menu

@sample		MenuDef()

@param		Nenhum
			
@return		ExpA - Array de rotinas   

@author		Thiago Tavares
@since		24/02/2014
@version	12.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.CRMA220" OPERATION 3 ACCESS 0		// "Incluir" 
ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CRMA220" OPERATION 4 ACCESS 0		// "Alterar" 
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CRMA220" OPERATION 5 ACCESS 0		// "Excluir" 
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CRMA220" OPERATION 2 ACCESS 0		// "Visualizar" 

Return( aRotina ) 