#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BC3
Browse do Historico Bloqueio da Familia
@author DEV TOTVS
@since  13/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BC3(lAutomato)
// Declaração de Variáveis
Local oBrowse
Default lAutomato :=  .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260BC3' )
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu de Historico Bloqueio da Familia
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
// Declaração de Variáveis
Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados do Historico Bloqueio da Familia
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
// Declaração de Variáveis
Local oModel	
Local oStruBA1 		:= FWFormStruct(1,'BA1')
Local oStruBC3 		:= FWFormStruct(1,'BC3')	
Local aCamposBA1	:= {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'} // Campos a serem adicionado na estrutura
local aCmpRelac		:= { { 'BC3_FILIAL' , 'xFilial( "BC3" )'}, { 'BC3_MATRIC' , 'BA1_CODINT + BA1_CODEMP + BA1_MATRIC' } }
Local nNx
// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260BC3')

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
Next

// Adiciona as estruturas no modelo
oModel:addFields('MasterBA1' ,NIL,oStruBA1) 
oModel:AddGrid('BC3DETAIL','MasterBA1',oStruBC3)

// Permissão de grid sem dados
oModel:GetModel('BC3DETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'BC3DETAIL', aCmpRelac,	BC3->( IndexKey( ) ) )
	
oModel:SetDescription( FunDesc() )	// Descrição do Modelo de dados

// Descrição de cada modelo usado
oModel:GetModel('MasterBA1'):SetDescription('Familia' )
oModel:GetModel('BC3DETAIL'):SetDescription('Histórico Bloqueio da Família' )	

// Não permite alteração ou inclusão no modelo
oModel:GetModel('MasterBA1'):SetOnlyQuery(.T.)
oModel:GetModel('MasterBA1'):SetOnlyView(.T.)
oModel:GetModel('BC3DETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('BC3DETAIL'):SetOnlyView(.T.)

oModel:SetPrimaryKey( { "BA1_FILIAL", "BA1_CODINT", "BA1_CODEMP", "BA1_MATRIC" } )

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View do histórico de Bloqueio da Familia
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
// Declaração de Variáveis
Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC' } )
Local oStruBC3 := FWFormStruct(2,'BC3')	
Local oModel   := FWLoadModel( 'PLSA260BC3') // Carrega o modelo
Local oView
Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx	

oView := FWFormView():New() // Cria o Objeto View

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCampos)
	oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
Next

oView:SetModel( oModel )

oStruBC3:RemoveField('BC3_MATRIC')
oStruBC3:RemoveField('BC3_NOMUSR')

oView:AddField( 'VIEW_BA1' , oStruBA1, 'MasterBA1' )
oView:AddGrid(  'VIEW_BC3' , oStruBC3, 'BC3DETAIL' )

oStruBA1:SetNoFolder() // Retirando as pastas de uma estrutura

oView:CreateHorizontalBox( 'SUPERIOR', 20) 
oView:CreateHorizontalBox( 'MEIO'	 , 80) 

oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
oView:SetOwnerView('VIEW_BC3', 'MEIO')	
	
oView:EnableTitleView('VIEW_BA1','Familia')
oView:EnableTitleView('VIEW_BC3','Histórico Bloqueio da Família')

Return oView
