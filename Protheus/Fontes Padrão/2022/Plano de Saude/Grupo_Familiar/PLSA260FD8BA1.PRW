#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD8BA1
Tela com campos para o preenchimento do Folder Dados Pessoais BA1
@author Totver
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260FD8BA1(lAutomato)
Local oBrowse

Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD8BA1' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD8BA1 
@author  Totver
@version P12
@since   05/08/2019
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260FD8BA1 
@author  Totver
@version P12
@since   05/08/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA1 := FWFormStruct( 1, 'BA1'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA1','Pessoais') })

	BA3->(DbSetORder(1))
	BA3->(MsSeek(xFilial("BA3") + BA1->BA1_CODINT + BA1->BA1_CODEMP + BA1->BA1_MATRIC  + BA1->BA1_CONEMP + BA1->BA1_VERCON + BA1->BA1_SUBCON + BA1->BA1_VERSUB))
	
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD8BA1')	
    
	oModel:addFields('MasterBA1' , ,oStruBA1) 								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'MasterBA1' ):SetDescription( 'Dados Pessoais do Beneficiario' )
	oModel:SetPrimaryKey({})

	oStruBA1:setProperty('BA1_CODDEP',MODEL_FIELD_VALID, { ||.T.})
	oStruBA1:setProperty('BA1_DATCAS',MODEL_FIELD_VALID, { ||.T.})
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P2
@since   05/08/2019.
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  
Local oStruBA1 := FWFormStruct( 2, 'BA1'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA1','Pessoais') })
Local oModel   := FWLoadModel( 'PLSA260FD8BA1' )
Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA1' ,  oStruBA1,  'MasterBA1' )

    oStruBA1:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:EnableTitleView('VIEW_BA1','Dados Pessoais do Beneficiario')
	
Return oView

