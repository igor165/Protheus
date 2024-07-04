#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSA260.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD2COME
Tela com campos para o preenchimento dos dados do Folder Comercial da BA3
@author Totver
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260FD2COME(lAutomato)
Local oBrowse
Default lAutomato	:= .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA3' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD2COME' )
	iF(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD2COME 
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
Definicao do modelo MVC PLSA260FD2COME 
@author  Totver
@version P12
@since   05/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Comercial') })
	
	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)	))
   
	
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD2COME')	
    
	oModel:addFields('MasterBA3' , ,oStruBA3) 								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'MasterBA3' ):SetDescription( 'Dados Comerciais da Familia' )
	oModel:SetPrimaryKey({})

	oStruBA3:setProperty( 'BA3_EQUIPE', MODEL_FIELD_VALID, { || PLS260EQPMVC("BA3",oModel) } )
	oStruBA3:setProperty( 'BA3_CODVEN', MODEL_FIELD_VALID, { || PLS260EQPMVC("BA3",oModel) } )
	oStruBA3:setProperty( 'BA3_CODVE2', MODEL_FIELD_VALID, { || PLS260EQPMVC("BA3",oModel) } )

	
		
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
Local oStruBA3 := FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Comercial') })
Local oModel   := FWLoadModel( 'PLSA260FD2COME' )
Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA3' ,  oStruBA3,  'MasterBA3' )

    oStruBA3:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')
	oView:EnableTitleView('VIEW_BA3','Dados Comerciais da Familia')
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS260EQPMVC
Validacao da equipe de venda na familia
@author  Totver
@version P2
@since   30/08/19
/*/
//-------------------------------------------------------------------
Function PLS260EQPMVC(cAlias,oModel)
LOCAL lRet    := .T.
Local cEquipe := oModel:GetValue('MasterBA3','BA3_EQUIPE')
Local cCodVen := oModel:GetValue('MasterBA3','BA3_CODVEN')
Local cCodVe2 := oModel:GetValue('MasterBA3','BA3_CODVE2')

If !Empty(cEquipe)
	BXL->( dbSetorder(01) )
	If BXL->( MsSeek(xFilial("BXL")+cEquipe) )
			BXM->( dbSetorder(01) )
			If !Empty(cCodVen)
				If !BXM->( MsSeek(xFilial("BXM")+BXL->BXL_SEQ+cCodVen) )
					Help("",1,"PLS260EQP2")
					lRet := .F.
				EndIf
			ElseIf !Empty(cCodVe2)
				If !BXM->( MsSeek(xFilial("BXM")+BXL->BXL_SEQ+cCodVe2) )
					Help("",1,"PLS260EQP3")
					lRet := .F.
				EndIf
			Endif
	Else
		Help("",1,"REGNOIS")
		lRet := .F.
	Endif
Endif

Return(lRet)