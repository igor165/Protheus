#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA660.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA660
Rotina para Sequência de Avaliação do Território. 

@author     Ronaldo Robes
@since      15/05/2015
@version    12.1.5
/*/
//------------------------------------------------------------------------------
Function CRMA660()
	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("A03")
	oBrowse:SetDescription( STR0001 ) //"Sequência de Avaliação do Território"
	oBrowse:DisableDetails()
	oBrowse:Activate()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opções disponíveis no menu da sequência de avaliação do território.

@return aRotina Rotinas que serão exibidas no menu. 

@author     Ronaldo Robes
@since      15/05/2015
@version    12.1.5
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := FWMVCMenu("CRMA660")
Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o modelo de dados da sequência de avaliação do território.

@return oModel Modelo de dados da sequência de avaliação do território.

@author     Ronaldo Robes
@since      15/05/2015
@version    12.1.5
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel		:= MPFormModel():New("CRMA660")
	Local oA03Struct	:= FWFormStruct( 1, "A03" )
	Local oA04Struct	:= FWFormStruct( 1, "A04" )

    //-------------------------------------------------------------------
	// Define a estrutura do modelo de dados. 
	//-------------------------------------------------------------------
	oModel:AddFields("A03MASTER",/*cOwner*/, oA03Struct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid( "A04DETAIL", "A03MASTER", oA04Struct, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )	
	oModel:SetRelation("A04DETAIL", { { "A04_FILIAL", "xFilial('A03')" }, {"A04_CODSEQ", "A03_CODSEQ"}}, A04->( IndexKey( 1 ) ) )

    //-------------------------------------------------------------------
	// Define a chave primária do modelo. 
	//-------------------------------------------------------------------	
	oModel:SetPrimaryeKey( { "A03_FILIAL", "A03_CODSEQ" } )
	
    //-------------------------------------------------------------------
	// Define o critério de linha única para o grid. 
	//-------------------------------------------------------------------	
	oModel:GetModel("A04DETAIL"):SetUniqueLine( { "A04_CODAGR" } )	
	
	//-------------------------------------------------------------------
	// Define a descrição dos modelos de dados. 
	//-------------------------------------------------------------------	
	oModel:SetDescription( STR0001 )
	oModel:GetModel("A03MASTER"):SetDescription( STR0002 ) //"Sequenciador de Avaliação"
	oModel:GetModel("A04DETAIL"):SetDescription( STR0003 ) //"Agrupadores"
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada de visualização da sequência de avaliação do território.

@return oView Camada de visualização da sequência de avaliação do território. 

@author     Ronaldo Robes
@since      15/05/2015
@version    12.1.5
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView			:= FWFormView():New()
	Local oModel 		:= FWLoadModel( "CRMA660" )
	Local oA03Struct	:= FWFormStruct( 2, "A03")
	Local oA04Struct	:= FWFormStruct( 2, "A04")

	//-------------------------------------------------------------------
	// Define o modelo utilizado pela camada de visualização. 
	//-------------------------------------------------------------------	
	oView:SetModel(oModel)  

	//-------------------------------------------------------------------
	// Remove campos da camada de visualização.  
	//-------------------------------------------------------------------
	oA04Struct:RemoveField( "A04_CODSEQ" )

	//-------------------------------------------------------------------
	// Define a estrutura da camada de visualização. 
	//------------------------------------------------------------------
	oView:AddField( "VIEW_A03", oA03Struct	, "A03MASTER" )
	oView:AddGrid( "VIEW_A04",	oA04Struct	, "A04DETAIL" )
	
	oView:CreateHorizontalBox("TOP"		,30)
	oView:CreateHorizontalBox("BOTTOM"	,70)
	
	oView:SetOwnerView( "VIEW_A03",	"TOP" )
	oView:SetOwnerView( "VIEW_A04", "BOTTOM" )
	
	oView:EnableTitleView("VIEW_A03", STR0002 ) //"Sequenciador de Avaliação"
	oView:EnableTitleView("VIEW_A04", STR0003 ) //"Agrupadores"

	//-------------------------------------------------------------------
	// Define campos autoincremento.  
	//-------------------------------------------------------------------
	oView:AddIncrementField( "VIEW_A04", "A04_ORDEM" )
Return oView
