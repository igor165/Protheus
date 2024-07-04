#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BF3
Browse de Doenças Pre-Existentes
@author DEV TOTVS
@since  10/12/2019
@version P12.
/*/
//-------------------------------------------------------------------

Function PLSA260BF3(lAutomato)

// Declaração de Variáveis
Local oBrowse
Default lAutomato := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260BF3' )
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu de Doenças Pre-Existentes
@author  DEV TOTVS
@since   10/12/2019
@version P12
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

// Declaração de Variáveis
Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados de Doenças Pre-Existentes
@author  DEV TOTVS
@since   10/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

// Declaração de Variáveis
Local oModel	
Local oStruBA1 		:= FWFormStruct(1,'BA1')
Local oStruBF3 		:= FWFormStruct(1,'BF3')
Local oStruBYY 		:= FWFormStruct(1,'BYY')	

Local aCamposBA1	:= {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'} // Campos a serem adicionado na estrutura
Local nNx

// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260BF3')

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
Next

//FwStruTrigger: ( cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic )
aAux := FwStruTrigger(;
        'BF3_CODDOE'     ,; 
        'BF3_DESDOE'     ,; 
        'Substr(BA9->BA9_DOENCA,1,TAMSX3("BF3_DESDOE")[1])',;
        .F.              ,; 
        'BA9'            ,; 
        1                ,; 
        ''               ,;
        '')

oStruBF3:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

// Adiciona as estruturas no modelo
oModel:addFields('BA1MASTER' ,NIL,oStruBA1) 
oModel:AddGrid('BF3DETAIL','BA1MASTER',oStruBF3)
oModel:AddGrid('BYYDETAIL','BF3DETAIL',oStruBYY)

// Permissão de grid sem dados
oModel:GetModel('BF3DETAIL'):SetOptional(.T.)
oModel:GetModel('BYYDETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'BF3DETAIL', {  { 'BF3_FILIAL'  , 'xFilial( "BF3" )'},;
				    { 'BF3_CODINT'	, 'BA1_CODINT' } ,;
                                    { 'BF3_CODEMP'	, 'BA1_CODEMP' } ,;
                                    { 'BF3_MATRIC'	, 'BA1_MATRIC' } ,;
                                    { 'BF3_TIPREG'	, 'BA1_TIPREG' }},;										
								BF3->( IndexKey( ) ) ) 

oModel:SetRelation( 'BYYDETAIL', {  { 'BYY_FILIAL'  , 'xFilial( "BYY" )'},;
				    { 'BYY_CODINT'	, 'BF3_CODINT' } ,;
                                    { 'BYY_CODEMP'	, 'BF3_CODEMP' } ,;
                                    { 'BYY_MATRIC'	, 'BF3_MATRIC' } ,;
                                    { 'BYY_TIPREG'	, 'BF3_TIPREG' } ,;	
                                    { 'BYY_CODDOE'	, 'BF3_CODDOE' }},;										
								BYY->( IndexKey( ) ) )  					
	
oModel:SetDescription( FunDesc() )	// Descrição do Modelo de dados

// Descrição de cada modelo usado
oModel:GetModel('BA1MASTER'):SetDescription('Familia' )
oModel:GetModel('BF3DETAIL'):SetDescription('Doenças Pré-Existentes' )	
oModel:GetModel('BYYDETAIL'):SetDescription('Carências' )	

// Não permite alteração ou inclusão no modelo
oModel:GetModel('BA1MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('BA1MASTER'):SetOnlyView(.T.)

// Alteração no dicionario da tabela BF3                                                                                                                                                        
oStruBF3:setProperty( 'BF3_CODDOE', MODEL_FIELD_VALID, { || BA9->(ExistCpo('BA9',oModel:GetValue('BF3DETAIL','BF3_CODDOE'),1))} )
oStruBF3:setProperty( 'BF3_TIPREG', MODEL_FIELD_INIT,  { || BA1->BA1_TIPREG })


// Campos não usados 
//------------------------------------------------------------------------------
//oStruBF3:setProperty( 'BF3_CODPAD', MODEL_FIELD_VALID, { || BR4->(ExistCpo('BR4',oModel:GetValue('BF3DETAIL','BF3_CODPAD'),1))} )
//oStruBF3:setProperty( 'BF3_CODPSA', MODEL_FIELD_VALID, { || BR8->(ExistCpo('BR8',oModel:GetValue('BF3DETAIL','BF3_CODPAD')+oModel:GetValue('BF3DETAIL','BF3_CODPSA'),1))} )
//------------------------------------------------------------------------------
oStruBF3:setProperty( 'BF3_VALAGR', MODEL_FIELD_WHEN,  { || oModel:GetValue('BF3DETAIL','BF3_PAGAGR') == "1" })
oStruBF3:setProperty( 'BF3_PERAGR', MODEL_FIELD_WHEN,  { || oModel:GetValue('BF3DETAIL','BF3_PAGAGR') == "1" })
oStruBF3:setProperty( 'BF3_UNAGR' , MODEL_FIELD_WHEN,  { || oModel:GetValue('BF3DETAIL','BF3_PAGAGR') <> "1" })
oStruBF3:setProperty( 'BF3_DESDOE', MODEL_FIELD_INIT,  { || If(Inclui,"",Posicione("BA9",1,xFilial("BA9")+BF3->BF3_CODDOE,"BA9_ABREVI")) } )

// Alteração no dicionario da tabela BYY    
oStruBYY:setProperty( 'BYY_TIPREG', MODEL_FIELD_INIT,  { || BA1->BA1_TIPREG })   
oStruBYY:setProperty( 'BYY_CODINT', MODEL_FIELD_INIT,  { || BA1->BA1_CODINT })   
oStruBYY:setProperty( 'BYY_CODEMP', MODEL_FIELD_INIT,  { || BA1->BA1_CODEMP })   
oStruBYY:setProperty( 'BYY_MATRIC', MODEL_FIELD_INIT,  { || BA1->BA1_MATRIC })   
oStruBYY:setProperty( 'BYY_CODDOE', MODEL_FIELD_INIT,  { || oModel:GetValue('BF3DETAIL','BF3_CODDOE') })                                                                                                                                             
oStruBYY:setProperty( 'BYY_CODPRO', MODEL_FIELD_VALID, { || BR8->(ExistCpo('BR8',oModel:GetValue('BYYDETAIL','BYY_CODPAD')+oModel:GetValue('BYYDETAIL','BYY_CODPRO'),1))} )
oStruBYY:setProperty( 'BYY_DESPRO', MODEL_FIELD_VALID , { || .T.} )
oStruBYY:setProperty( 'BYY_DESPRO', MODEL_FIELD_INIT,  { || If(Inclui,"",BR8->(Posicione("BR8",1,xFilial("BR8")+BYY->(BYY_CODPAD+BYY_CODPRO),"BR8_DESCRI"))) } )

oModel:SetPrimaryKey( { 'BF3_FILIAL', 'BF3_CODINT', 'BF3_CODEMP', 'BF3_MATRIC' , 'BF3_CODDOE' } )



Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View de Doenças Pre-Existentes
@author  DEV TOTVS
@since   10/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 

// Declaração de Variáveis
Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR' } )
Local oStruBF3 := FWFormStruct(2,'BF3')	
Local oStruBYY := FWFormStruct(2,'BYY')	
Local oModel   := FWLoadModel( 'PLSA260BF3') // Carrega o modelo
Local oView
Local aCamposBA1  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx	

oView := FWFormView():New() // Cria o Objeto View

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(2,oStruBA1,aCamposBA1[nNx],StrZero(nNx,2))
Next

oView:SetModel( oModel )

// Removo os campos para não ser exibido no AddGrid
oStruBF3:RemoveField('BF3_TIPREG')
oStruBYY:RemoveField('BYY_TIPREG')
oStruBYY:RemoveField('BYY_CODDOE')

oView:AddField( 'VIEW_BA1' , oStruBA1, 'BA1MASTER' )
oView:AddGrid(  'VIEW_BF3' , oStruBF3, 'BF3DETAIL' )
oView:AddGrid(  'VIEW_BYY' , oStruBYY, 'BYYDETAIL' )

oStruBA1:SetNoFolder() // Retirando as pastas de uma estrutura

oView:CreateHorizontalBox( 'SUPERIOR', 20) 
oView:CreateHorizontalBox( 'MEIO'	 , 45) 
oView:CreateHorizontalBox( 'INFERIOR', 35) 

oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
oView:SetOwnerView('VIEW_BF3', 'MEIO')	
oView:SetOwnerView('VIEW_BYY', 'INFERIOR')	
	
oView:EnableTitleView('VIEW_BA1','Beneficiário')
oView:EnableTitleView('VIEW_BF3','Doenças Pré-Existentes')
oView:EnableTitleView('VIEW_BYY','Carências')

Return oView       

