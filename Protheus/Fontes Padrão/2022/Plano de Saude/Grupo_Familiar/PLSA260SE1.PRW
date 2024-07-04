#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260SE1
Browse de Historico Financeiro da Familia
@author DEV TOTVS
@since 09/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260SE1(lAutomato)
// Declaração de Variáveis
Local oBrowse
Default lAutomato := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260SE1' )
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu de histórico da familia
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
Definicao do modelo de dados do histórico da familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
// Declaração de Variáveis
Local oModel	
Local oStruBA1 		:= FWFormStruct(1,'BA1')
Local oStruSE1 		:= FWFormStruct(1,'SE1')	

Local aCamposBA1	:= {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'} // Campos a serem adicionado na estrutura
Local nNx
// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260SE1')
// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
Next

// Adiciona as estruturas no modelo
oModel:addFields('MasterBA1' ,NIL,oStruBA1) 
oModel:AddGrid('SE1DETAIL','MasterBA1',oStruSE1)

// Permissão de grid sem dados
oModel:GetModel('SE1DETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'SE1DETAIL', { { 'E1_FILIAL' , 'xFilial( "SE1" )'},;
								{ 'E1_CODINT'	, 'BA1_CODINT'       },;
								{ 'E1_CODEMP'	, 'BA1_CODEMP'       },;
								{ 'E1_MATRIC'	, 'BA1_MATRIC'       } },;									
								SE1->( IndexKey( 7 ) ) ) 						
	
oModel:SetDescription( FunDesc() )	// Descrição do Modelo de dados

// Descrição de cada modelo usado
oModel:GetModel('MasterBA1'):SetDescription('Familia' )
oModel:GetModel('SE1DETAIL'):SetDescription('Histórico Financeiro' )	

// Não permite alteração ou inclusão no modelo
oModel:GetModel('MasterBA1'):SetOnlyQuery(.T.)
oModel:GetModel('MasterBA1'):SetOnlyView(.T.)
oModel:GetModel('SE1DETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('SE1DETAIL'):SetOnlyView(.T.)

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
Local oStruSE1 := FWFormStruct(2,'SE1')	
Local oModel   := FWLoadModel( 'PLSA260SE1') // Carrega o modelo
Local oView
Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx	

oView := FWFormView():New() // Cria o Objeto View

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCampos)
	oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
Next

oView:SetModel( oModel )

oStruSE1:RemoveField('E1_CODINT')
oStruSE1:RemoveField('E1_CODEMP')
oStruSE1:RemoveField('E1_MATRIC')

oView:AddField( 'VIEW_BA1' , oStruBA1, 'MasterBA1' )
oView:AddGrid(  'VIEW_SE1' , oStruSE1, 'SE1DETAIL' )

oStruBA1:SetNoFolder() // Retirando as pastas de uma estrutura

oView:AddUserButton("Composição","", {||GetComposicao()} ,,,,.T./*lShowBar*/ )

oView:CreateHorizontalBox( 'SUPERIOR', 20) 
oView:CreateHorizontalBox( 'MEIO'	 , 80) 

oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
oView:SetOwnerView('VIEW_SE1', 'MEIO')	
	
oView:EnableTitleView('VIEW_BA1','Familia')
oView:EnableTitleView('VIEW_SE1','Histórico Financeiro')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GetComposicao
Carrega a composição do titulo posicionado
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function GetComposicao(lAutomato)

Local oModel        := FWModelActive()
Local cPrefix       := oModel:GetModel('SE1DETAIL'):GetValue('E1_PREFIXO')
Local cNumTit       := oModel:GetModel('SE1DETAIL'):GetValue('E1_NUM')
Local cParcela      := oModel:GetModel('SE1DETAIL'):GetValue('E1_PARCELA')
Local cTipTit       := oModel:GetModel('SE1DETAIL'):GetValue('E1_TIPO')
Local cNumCob       := oModel:GetModel('SE1DETAIL'):GetValue('E1_PLNUCOB')
Local aSaveLines    := FWSaveRows()
Default lAutomato	:= .f.

If(!lAutomato,PLSCOMPFIN(cPrefix,cNumTit,cParcela,cTipTit,cNumCob,.F.,.F.),)

FWRestRows( aSaveLines )

Return