#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA870D.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870D
Cadastro de lote para gerar arquivos texto ( txt ).

@author Varejo
@since 29/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA870D()
Local oBrowse


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MFH' )
oBrowse:SetDescription( STR0001 ) //"Cadastro de Lote"
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

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"  	           OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOJA870D"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA870D"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA870D"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA870D"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

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
Local oStructMFH := FWFormStruct(1,"MFH") // Informe os campos que eu quero no cabecalho
Local oModel := Nil

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA870D",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

oModel:AddFields("MFHMASTER", Nil/*cOwner*/, oStructMFH ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

oModel:SetPrimaryKey( { "MFH_FILIAL","MFH_LOTE" } )
                                                                        
oModel:GetModel("MFHMASTER"):SetDescription(STR0001)


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
Local oModel       := FWLoadModel("LOJA870D")
Local oStructMFH := FWFormStruct(2,"MFH") // Informe os campos que eu quero no cabecalho
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
            
oView:AddField( "VIEWMFH" , oStructMFH, "MFHMASTER" )
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMFH' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWMFH' )
                                                       	
Return oView