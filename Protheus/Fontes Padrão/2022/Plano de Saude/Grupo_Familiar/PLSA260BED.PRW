#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BED
Browse do Historico Cobrança Carteirinha - Familia
@author DEV TOTVS
@since 09/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BED(lAutomato)
// Declaração de Variáveis
Local oBrowse
Default lAutomato := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260BED' )
iF(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu de Historico Cobrança Carteirinha - Familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
// Declaração de Variáveis
Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados do Historico Cobrança Carteirinha - Familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
// Declaração de Variáveis
Local oModel	
Local oStruBA1 		:= FWFormStruct(1,'BA1')
Local oStruBED 		:= FWFormStruct(1,'BED')	

Local aCamposBA1	:= {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'} // Campos a serem adicionado na estrutura
Local nNx
// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260BED')

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
Next

// Adiciona as estruturas no modelo
oModel:addFields('MasterBA1' ,NIL,oStruBA1) 
oModel:AddGrid('BEDDETAIL','MasterBA1',oStruBED)

// Permissão de grid sem dados
oModel:GetModel('BEDDETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'BEDDETAIL', { { 'BED_FILIAL' , 'xFilial( "BED" )'},;
								{ 'BED_CODINT'	, 'BA1_CODINT'       },;
								{ 'BED_CODEMP'	, 'BA1_CODEMP'       },;
								{ 'BED_MATRIC'	, 'BA1_MATRIC'       } },;									
								BED->( IndexKey( ) ) ) 						
	
oModel:SetDescription( FunDesc() )	// Descrição do Modelo de dados

// Descrição de cada modelo usado
oModel:GetModel('MasterBA1'):SetDescription('Familia' )
oModel:GetModel('BEDDETAIL'):SetDescription('Histórico Cobrança Carteirinha' )	

// Não permite alteração ou inclusão no modelo
oModel:GetModel('MasterBA1'):SetOnlyQuery(.T.)
oModel:GetModel('MasterBA1'):SetOnlyView(.T.)
oModel:GetModel('BEDDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('BEDDETAIL'):SetOnlyView(.T.)

oModel:SetPrimaryKey( { "BA1_FILIAL", "BA1_CODINT", "BA1_CODEMP", "BA1_MATRIC" } )

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View do histórico da familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
// Declaração de Variáveis
Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' } )
Local oStruBED:= FWFormStruct(2,'BED')	
Local oModel   := FWLoadModel( 'PLSA260BED') // Carrega o modelo
Local oView
Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx	

oView := FWFormView():New() // Cria o Objeto View

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCampos)
	oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
Next

oView:SetModel( oModel )

oStruBED:RemoveField('BED_CODINT')
oStruBED:RemoveField('BED_CODEMP')
oStruBED:RemoveField('BED_MATRIC')

oView:AddField( 'VIEW_BA1' , oStruBA1, 'MasterBA1' )
oView:AddGrid(  'VIEW_BED' , oStruBED, 'BEDDETAIL' )

oStruBA1:SetNoFolder() // Retirando as pastas de uma estrutura

oView:CreateHorizontalBox( 'SUPERIOR', 20) 
oView:CreateHorizontalBox( 'MEIO'	 , 80) 

oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
oView:SetOwnerView('VIEW_BED', 'MEIO')	
	
oView:EnableTitleView('VIEW_BA1','Familia')
oView:EnableTitleView('VIEW_BED','Histórico Cobrança Carteirinha')

Return oView