#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo do Log de Integração do GTP com o 
sistema RJ
@type Function
@author Fernando Radu Muscalu
@since 13/07/2021
@version 1.0
@return oModel: Objeto,. Retorna o Objeto instanciado da classe FwFormModel
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel
    Local oStruct   := FWFormStruct(1,"GYS")
   
    oModel := MPFormModel():New("GTPRJMODA")

    oModel:AddFields("GYSMASTER",,oStruct)

    oModel:SetDescription("Log de falhas da Integração REST - Modelo Fields")
    oModel:SetPrimaryKey({})
Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view do Log de Integração do GTP com o 
sistema RJ
@type Function
@author Fernando Radu Muscalu
@since 13/07/2021
@version 1.0
@return oView: Objeto. Retorna instância do objeto da classe FWFormView
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
    
    Local oView    	:= FwFormView():New()       // Recebe o objeto da View
    Local oModel   	:= FwLoadModel( "GTPRJMODA" )	// Objeto do Model 	
    Local oStruct	:= FWFormStruct( 2, 'GYS' )	
    	
   //-- Seta o Model para o modelo view
    oView:SetModel(oModel)
    
    //-------------------------------------------+
    // ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
    //-------------------------------------------+
    oView:AddField('VIEW_GYSMASTER', oStruct,  'GYSMASTER')
    
    //-------------------------------------------+
    // DEFINE EM % A DIVISAO DA TELA, HORIZONTAL |
    //-------------------------------------------+
    oView:CreateHorizontalBox('HEADER', 100)
        
    //-------------------------------------------+
    // DEFINE UM BOX PARA CADA COMPONENTE DO MVC |
    //-------------------------------------------+
    oView:SetOwnerView( 'VIEW_GYSMASTER',   'HEADER')
    
    // Liga a identificacao do componente
    oView:EnableTitleView ('VIEW_GYSMASTER'	,"Log de Integração RJ - Cabeçalho" )
    
Return(oView)
