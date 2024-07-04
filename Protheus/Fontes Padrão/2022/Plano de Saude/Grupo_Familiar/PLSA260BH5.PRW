#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BH5
Funcao para abrir a tela de cadastro de Gratuidade da Familia
@author DEV TOTVS
@since 28/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260BH5(lAutomato)

	Local oBrowse
	Default lAutomato := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BH5' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BH5 
@author  DEV TOTVS
@version P12
@since   28/08/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BH5 
@author  DEV TOTVS
@version P12
@since   28/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	

	Local oModel
	Local oStruBA1 		:= FWFormStruct(1,'BA1')
	Local oStruBH5 		:= FWFormStruct(1,'BH5')
	Local oEvent   		:= PL260BH5EVDEF():New()
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BH5')

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next
    
	oModel:addFields('MasterBA1' , ,oStruBA1) 
   	oModel:AddGrid(  'BH5DETAIL' , 'MasterBA1', oStruBH5 )
	
	oModel:GetModel( "BH5DETAIL" ):SetOptional( .T. )
	
    oStruBH5:RemoveField('BH5_NOMRES')

	oModel:SetRelation( 'BH5DETAIL', { { 'BH5_FILIAL' 	, 'xFilial( "BH5" )' },;
									{ 'BH5_CODINT'	, 'BA1_CODINT' },;
									{ 'BH5_CODEMP'	, 'BA1_CODEMP' },;
									{ 'BH5_MATRIC'	, 'BA1_MATRIC'} },;									
									BH5->( IndexKey(  ) ) ) 
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( 'MasterBA1' ):SetDescription( 'Familia' )
    oModel:GetModel( 'BH5DETAIL' ):SetDescription( 'Gratuidade da Familia' )	

	oModel:GetModel( 'MasterBA1' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'MasterBA1' ):SetOnlyView(.T.)	
	
	oStruBA1:setProperty( 'BA1_MATRIC', MODEL_FIELD_INIT, { || BA1->BA1_MATRIC} )
	oStruBH5:setProperty( 'BH5_CODINT', MODEL_FIELD_INIT, { || BA1->(BA1_CODINT)} )
	oStruBH5:setProperty( 'BH5_CODEMP', MODEL_FIELD_INIT, { || BA1->(BA1_CODEMP)} )
    oStruBH5:setProperty( 'BH5_USUARI', MODEL_FIELD_INIT, { || BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)} )
    
	oModel:SetPrimaryKey( { "BH5_FILIAL", "BH5_CODINT", "BH5_CODEMP", "BH5_MATRIC","BH5_CODGRA" } )

 
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P2
@since   28/08/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  

	Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' } )
	Local oStruBH5 := FWFormStruct(2,'BH5')	
    Local oModel   := FWLoadModel( 'PLSA260BH5' )
	Local oView
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx

	oView := FWFormView():New()

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next

	oView:SetModel( oModel )
	
    oView:AddField( 'VIEW_BA1' ,  oStruBA1,  'MasterBA1' )
    oView:AddGrid(  'VIEW_BH5' ,  oStruBH5,  'BH5DETAIL' )

    //Retira o campo código da tela 
    oStruBH5:RemoveField('BH5_CODINT')
    oStruBH5:RemoveField('BH5_CODEMP')
    oStruBH5:RemoveField('BH5_MATRIC')
    oStruBH5:RemoveField('BH5_USUARI')
    oStruBH5:RemoveField('BH5_NOMRES')
    oStruBH5:RemoveField('BH5_USUOPE')    
    
    oStruBA1:SetNoFolder()
   	oStruBH5:SetNoFolder()

	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )
	
	oView:EnableTitleView('VIEW_BH5','Gratuidade da Familia')
	
	oView:SetOwnerView( 'VIEW_BA1', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BH5', 'INFERIOR' )
	
	oView:EnableTitleView('VIEW_BA1','Familia')
	oView:EnableTitleView('VIEW_BH5','Gratuidade da Familia')		

Return oView