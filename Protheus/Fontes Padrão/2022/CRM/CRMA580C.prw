#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA580C.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580C

Chamda para prote��o da fun��o

@return		Nil

@author		Jonatas Martins
@version	12
@since		29/09/2015
/*/
//------------------------------------------------------------------------------
Function CRMA580C()
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados do N�veis do Agrupador no formato de field.

@return		oModel, objeto, Modelo de Dados

@author		Valdiney V GOMES
@version	12
@since		31/08/2015
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oAOMStruct	:= FWFormStruct( 1, "AOM" )

    //-------------------------------------------------------------------
	// Define a estrutura do modelo de dados. 
	//-------------------------------------------------------------------
	oModel	:= MPFormModel():New( "CRMA580C" )
	oModel:AddFields("AOMMASTER",, oAOMStruct )
	oModel:GetModel("AOMMASTER"):SetOnlyQuery(.T.)

	//-------------------------------------------------------------------
	// Define a descri��o do modelo de dados. 
	//-------------------------------------------------------------------	
	oModel:SetDescription(STR0001) //"N�veis do Agrupador"
	oModel:GetModel("AOMMASTER"):SetDescription( STR0002 ) //"N�vel" 
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta interface do N�veis do Agrupador no formato de field.

@return		oView, objeto, Interface do Agrupador de Registros

@author		Valdiney V GOMES
@version	12
@since		31/08/2015
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local bAOMShow		:= { |cField| AllTrim(cField) $ "AOM_FILIAL|AOM_CODNIV|AOM_DESCRI|AOM_MSBLQL|" }
	Local oModel		:= FWLoadModel("CRMA580C")
	Local oView			:= FWFormView():New() 
	Local oAOMStruct	:= FWFormStruct( 2, "AOM", bAOMShow)

	//-------------------------------------------------------------------
	// Define o modelo utilizado pela camada de visualiza��o. 
	//-------------------------------------------------------------------	
	oView:SetModel(oModel)

	//-------------------------------------------------------------------
	// Define a estrutura da camada de visualiza��o. 
	//-------------------------------------------------------------------
	oView:AddField( "VIEW_AOM", oAOMStruct, "AOMMASTER" )
	oView:CreateHorizontalBox( "TOP", 100 )
	oView:SetOwnerView( "VIEW_AOM",	"TOP" )
	oView:EnableTitleView("VIEW_AOM" ) 
	oView:ShowInsertMsg(.F.)   
	oView:ShowUpdateMsg(.F.) 

Return oView  