#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA7032.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA7032
Cadastro de Tipo de Eventos - Integração com NeoGrid

@author Varejo
@since 09/08/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA7032()
Local oBrowse						// Objeto do cadastro de Eventos (MVC)


oBrowse := FWmBrowse():New()	
oBrowse:SetAlias( 'MFQ' )
oBrowse:SetDescription( STR0001 ) 	//"Cadastro de Erros"
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
Local aRotina        := {}				// Array para o menu principal

ADD OPTION aRotina TITLE STR0004 ACTION "PesqBrw"              OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA7032"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA7032"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.LOJA7032"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.LOJA7032"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

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
Local oStructMFQ := FWFormStruct(1,"MFQ") 	// Informe os campos que eu quero no cabecalho
Local oModel := Nil							// Modelo de Dados

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA7032",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("MFQMASTER", Nil/*cOwner*/, oStructMFQ ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:SetPrimaryKey( { "MFQ_FILIAL","MFQ_CODIGO" } )
oModel:SetDescription(STR0002) //"Modelo de dados"
oModel:GetModel("MFQMASTER"):SetDescription(STR0003)


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
Local oView        := Nil							// Definição da View
Local oModel       := FWLoadModel("LOJA7032")		// Modelo de dados
Local oStructMFQ := FWFormStruct(2,"MFQ") 			// Informe os campos que eu quero no cabecalho
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
            
oView:AddField( "VIEWMFQ" , oStructMFQ, "MFQMASTER" )
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMFQ' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWMFQ' )
                                                       	
Return oView