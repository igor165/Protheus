#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA870G.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870G
Cadastro de erros da administradora financeira ( seguradora ).

@author Varejo
@since 22/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA870G()
Local oBrowse


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MFO' )
oBrowse:SetDescription( STR0001 ) //"Cadastro de Erros"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"              OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOJA870G"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA870G"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA870G"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA870G"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMFO := FWFormStruct(1,"MFO") // Informe os campos que eu quero no cabecalho
Local oModel := Nil

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA870G",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

oModel:AddFields("MFOMASTER", Nil/*cOwner*/, oStructMFO ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

oModel:SetPrimaryKey( { "MFO_FILIAL","MFO_CODIGO" } )
                                                                        
oModel:GetModel("MFOMASTER"):SetDescription(STR0001)


Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel("LOJA870G")
Local oStructMFO := FWFormStruct(2,"MFO") // Informe os campos que eu quero no cabecalho
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
            
oView:AddField( "VIEWMFO" , oStructMFO, "MFOMASTER" )
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMFO' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWMFO' )
                                                       	
Return oView