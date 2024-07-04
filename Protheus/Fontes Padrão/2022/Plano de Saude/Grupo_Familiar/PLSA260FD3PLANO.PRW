#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD3PLANO
Tela com campos para o preenchimento do Folder Plano BA3
@author Totver
@since 05/08/19
@version P12.
/*/
//-------------------------------------------------------------------
Function PLSA260FD3PLANO(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA3' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD3PLANO' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD3PLANO 
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
Definicao do modelo MVC PLSA260FD3PLANO 
@author  Totver
@version P12
@since   05/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Plano') })
	

	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)	))
   

    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD3PLANO')	
    
	oModel:addFields('MasterBA3' , ,oStruBA3) 								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'MasterBA3' ):SetDescription( 'Dados do Plano da Familia' )
	oModel:SetPrimaryKey({})

    oStruBA3:SetProperty( 'BA3_DESPLA' , MODEL_FIELD_INIT, { || Posicione("BI3",1,xFilial("BI3")+BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO,"BI3_DESCRI") })

	oStruBA3:setProperty('BA3_CODPLA',MODEL_FIELD_VALID, { || PLSABA3MVC(oModel) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_VERSAO',MODEL_FIELD_VALID, { || EXISTCPO("BIL", RetFilPla(oModel),1) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_FORPAG',MODEL_FIELD_VALID, { || PLS260COFZ(.T.,oModel) .And. PLSA260GCMvc(oModel)})
	oStruBA3:setProperty('BA3_FORCTX',MODEL_FIELD_VALID, { || .T.})
		
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
Local oStruBA3 := FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Plano') })
Local oModel   := FWLoadModel( 'PLSA260FD3PLANO' )
Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA3' ,  oStruBA3,  'MasterBA3' )

    oStruBA3:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')
	oView:EnableTitleView('VIEW_BA3','Dados do Plano da Familia')
	
Return oView