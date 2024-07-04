#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BFO
Funcao para abrir a tela de cadastro de Classe de Carência
@author Totver
@since 19/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260BFO(lAutomato)
Local oBrowse
Default lAutomato :=.F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BFO' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BFO 
@author  Totver
@version P12
@since   19/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BFO 
@author  Totver
@version P12
@since   19/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA1 		:= FWFormStruct(1,'BA1')
	Local oStruBFO 		:= FWFormStruct(1,'BFO')
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBFO	:= {"BFO_CODINT","BFO_CODEMP","BFO_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
    
    //Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BFO')

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBFO)
		oStruBFO := CriaCampMVC(1,oStruBFO,aCamposBFO[nNx]) 
	Next
    
	oModel:addFields('BA1MASTER' , ,oStruBA1) 
   	oModel:AddGrid(  'BFODETAIL' , 'BA1MASTER', oStruBFO )
	
	oModel:GetModel( "BFODETAIL" ):SetOptional( .T. )

	oModel:SetRelation( 'BFODETAIL', { { 'BFO_FILIAL' 	, 'xFilial( "BFO" )' },;
									{'BFO_CODINT'	, 'BA1_CODINT'},;
                                    {'BFO_CODEMP'	, 'BA1_CODEMP'},;
                                    {'BFO_MATRIC'	, 'BA1_MATRIC'},;
									{'BFO_TIPREG'	, 'BA1_TIPREG'} },;									
									BFO->( IndexKey(  ) ) ) 
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( 'BA1MASTER' ):SetDescription( 'Beneficiário' )
    oModel:GetModel( 'BFODETAIL' ):SetDescription( 'Classe de Carência' )	

	oModel:GetModel( 'BA1MASTER' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'BA1MASTER' ):SetOnlyView(.T.)	
    
    oStruBFO:setProperty('BFO_TIPREG', MODEL_FIELD_INIT, { || BA1->BA1_TIPREG} )
    oStruBFO:setProperty('BFO_CLACAR', MODEL_FIELD_VALID,{ || BDL->(ExistCpo("BDL",PLSINTPAD()+oModel:GetValue("BFODETAIL","BFO_CLACAR"),1)) } )
    
	oModel:SetPrimaryKey( { "BFO_FILIAL", "BFO_CODINT", "BFO_CODEMP", "BFO_MATRIC","BFO_TIPREG", "BFO_CLACAR" } )    
		
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P2
@since   19/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  
	Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR' } )
	Local oStruBFO := FWFormStruct(2,'BFO')	
    Local oModel   := FWLoadModel( 'PLSA260BFO' )
	Local oView
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx

	oView := FWFormView():New()

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next

	oView:SetModel( oModel )
	
    oView:AddField( 'VIEW_BA1' ,  oStruBA1,  'BA1MASTER' )
    oView:AddGrid(  'VIEW_BFO' ,  oStruBFO,  'BFODETAIL' )
   
    oStruBA1:SetNoFolder()
   	oStruBFO:SetNoFolder()

	oView:CreateHorizontalBox( 'SUPERIOR', 25 )
	oView:CreateHorizontalBox( 'INFERIOR', 75 )	
	
	oView:SetOwnerView( 'VIEW_BA1', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BFO', 'INFERIOR' )
	
	oView:EnableTitleView('VIEW_BA1','Beneficiário')
	oView:EnableTitleView('VIEW_BFO','Classe de Carência')		

Return oView