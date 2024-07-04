#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD4ANS
Tela com campos para o preenchimento do Folder ANS BA3
@author Totver
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260FD4ANS(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA3' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD4ANS' )
	iF(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD4ANS 
@author  Totver
@version P12
@since   05/08/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260FD4ANS 
@author  Totver
@version P12
@since   05/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','ANS') })
	

	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)	))
   
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD4ANS')	
    
	oModel:addFields('MasterBA3' , ,oStruBA3) 								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'MasterBA3' ):SetDescription( 'Dados da ANS' )
	oModel:SetPrimaryKey({})  
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P2
@since   05/08/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  
Local oStruBA3 := FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','ANS') })
Local oModel   := FWLoadModel( 'PLSA260FD4ANS' )
Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA3' ,  oStruBA3,  'MasterBA3' )

    oStruBA3:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')	
	oView:EnableTitleView('VIEW_BA3','Dados da ANS')
	
Return oView