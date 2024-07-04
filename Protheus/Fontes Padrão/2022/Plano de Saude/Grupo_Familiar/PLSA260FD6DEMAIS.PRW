#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD6DEMAIS
Tela com campos para o preenchimento dos dados do Folder Comercial da BA3
@author Totver
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260FD6DEMAIS(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA3' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD6DEMAIS' )
	iF(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD6DEMAIS 
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
Definicao do modelo MVC PLSA260FD6DEMAIS 
@author  Totver
@version P12
@since   05/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Cadastro') })
	
	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)	))
   

    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD6DEMAIS')	
    
	oModel:addFields('MasterBA3' , ,oStruBA3) 								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'MasterBA3' ):SetDescription( 'Demais dados Cadastrais da Familia' )
	oModel:SetPrimaryKey({})
	oStruBA3:setProperty( 'BA3_AGMTFU', MODEL_FIELD_VALID, { || VldMatrFun(oModel)} )
		
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
Local oStruBA3 := FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Cadastro') })
Local oModel   := FWLoadModel( 'PLSA260FD6DEMAIS' )
Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA3' ,  oStruBA3,  'MasterBA3' )

    oStruBA3:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')
	oView:EnableTitleView('VIEW_BA3','Demais dados Cadastrais da Familia')
	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} VldMatrFun
Valida o Funcionario
@author  Totver
@version P2
@since   05/08/19
/*/
//-------------------------------------------------------------------
Static Function VldMatrFun(oModel)
Local lRet := .F.

If SRA->RA_MAT == oModel:GetValue('MasterBA3','BA3_AGMTFU')
	lRet := .T.
Endif

Return lRet