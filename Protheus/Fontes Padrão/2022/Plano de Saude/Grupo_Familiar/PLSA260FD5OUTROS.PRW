#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD5OUTROS
Tela com campos para o preenchimento do Folder Outros BA3
@author Totver
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260FD5OUTROS(lAutomato)
Local oBrowse
Default lAutomato := .F. 
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA3' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD5OUTROS' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD5OUTROS 
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
Definicao do modelo MVC PLSA260FD5OUTROS 
@author  Totver
@version P12
@since   05/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','OUTROS') })
	
	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)	))
   

    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD5OUTROS')	
    
	oModel:addFields('MasterBA3' , ,oStruBA3) 								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'MasterBA3' ):SetDescription( 'Outras Informações' )
	oModel:SetPrimaryKey({})  

	oStruBA3:setProperty('BA3_CODRAS', MODEL_FIELD_VALID, { || ExistCpo("BA3",oModel:GetValue('MasterBA3','BA3_CODRAS'), 11)  } )
		
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
Local oStruBA3 := FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','OUTROS') })
Local oModel   := FWLoadModel( 'PLSA260FD5OUTROS' )
Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA3' ,  oStruBA3,  'MasterBA3' )

    oStruBA3:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')
	oView:EnableTitleView('VIEW_BA3','Outras Informações')
	
Return oView