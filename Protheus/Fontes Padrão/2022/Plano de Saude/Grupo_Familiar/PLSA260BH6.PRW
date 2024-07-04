#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BH6
Funcao para abrir a tela de cadastro de Gratuidade da Familia
@author DEV TOTVS
@since 28/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260BH6(lAutomato)

	Local oBrowse
	Default lAutomato := .F.
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BH6' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BH6 
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
Definicao do modelo MVC PLSA260BH6 
@author  DEV TOTVS
@version P12
@since   28/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()			

	Local oModel
	Local oStruBA1 		:= FWFormStruct(1,'BA1')
	Local oStruBH6 		:= FWFormStruct(1,'BH6')
	Local oEvent   		:= PL260BH6EVDEF():New()
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBH6	:= {"BH6_CODINT","BH6_CODEMP","BH6_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
   
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BH6')

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBH6)
		oStruBH6 := CriaCampMVC(1,oStruBH6,aCamposBH6[nNx]) 
	Next
    
	oModel:addFields('MasterBA1' , ,oStruBA1) 
   	oModel:AddGrid(  'BH6DETAIL' , 'MasterBA1', oStruBH6 )
		
	oModel:GetModel( "BH6DETAIL" ):SetOptional( .T. )

	oModel:SetRelation( 'BH6DETAIL', { { 'BH6_FILIAL' 	, 'xFilial( "BH6" )' },;
									{ 'BH6_CODINT', 'BA1_CODINT' },;
									{ 'BH6_CODEMP', 'BA1_CODEMP' },;
									{ 'BH6_MATRIC', 'BA1_MATRIC' },;
									{ 'BH6_TIPREG', 'BA1_TIPREG'}},;									
									BH6->( IndexKey(  ) ) ) 
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( 'MasterBA1' ):SetDescription( 'Beneficiário' )
    oModel:GetModel( 'BH6DETAIL' ):SetDescription( 'Gratuidade do Beneficiário' )	

	oModel:GetModel( 'MasterBA1' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'MasterBA1' ):SetOnlyView(.T.)	
	
    oStruBH6:setProperty( 'BH6_USUARI', MODEL_FIELD_INIT, { || BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)} )	
	oStruBH6:setProperty( 'BH6_CODINT', MODEL_FIELD_INIT, { || BA1->BA1_CODINT} )
	oStruBH6:setProperty( 'BH6_CODEMP', MODEL_FIELD_INIT, { || BA1->BA1_CODEMP} )
	oStruBH6:setProperty( 'BH6_MATRIC', MODEL_FIELD_INIT, { || BA1->BA1_MATRIC} )
	oStruBH6:setProperty( 'BH6_TIPREG', MODEL_FIELD_INIT, { || BA1->BA1_TIPREG} )
	oStruBH6:setProperty( 'BH6_USUOPE', MODEL_FIELD_INIT, { || PlRetOpe()} )
	
	oModel:SetPrimaryKey( { "BH6_FILIAL", "BH6_CODINT", "BH6_CODEMP", "BH6_MATRIC","BH6_CODGRA" } )

	//Instala o evento padrão do programa.
	oModel:InstallEvent("PL260BH6EVDEF",/*cOwner*/,oEvent)
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P12
@since   28/08/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  

	Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR|' } )
	Local oStruBH6 := FWFormStruct(2,'BH6')	
    Local oModel   := FWLoadModel( 'PLSA260BH6' )
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
    oView:AddGrid(  'VIEW_BH6' ,  oStruBH6,  'BH6DETAIL' )

    //Retira o campo código da tela 
    oStruBH6:RemoveField('BH6_CODINT')
    oStruBH6:RemoveField('BH6_CODEMP')
    oStruBH6:RemoveField('BH6_MATRIC')
    oStruBH6:RemoveField('BH6_USUARI')    
    oStruBH6:RemoveField('BH6_USUOPE') 
	oStruBH6:RemoveField('BH6_NOMRES')
	oStruBH6:RemoveField('BH6_TIPREG')
    //--------------------------------
    oStruBA1:SetNoFolder()
   	oStruBH6:SetNoFolder()

	oView:CreateHorizontalBox( 'SUPERIOR', 15 )
	oView:CreateHorizontalBox( 'INFERIOR', 85 )
	
	oView:EnableTitleView('VIEW_BH6','Gratuidade do Beneficiário')
	
	oView:SetOwnerView( 'VIEW_BA1', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BH6', 'INFERIOR' )
	
	oView:EnableTitleView('VIEW_BA1','Beneficiário')
	oView:EnableTitleView('VIEW_BH6','Gratuidade do Beneficiário')		

Return oView