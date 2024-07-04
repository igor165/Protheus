#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA871A.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA871A 
Cadastro de grupos de layouts

@author Varejo
@since 20/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA871A()
Local oBrowse


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MG6' )
oBrowse:SetDescription(STR0002) //"Cadastro de Grupo de Layout"
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

ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw"  		       OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.LOJA871A"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.LOJA871A"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.LOJA871A"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.LOJA871A"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

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
Local oStructMG6 := FWFormStruct(1,"MG6",{|cCampo| (AllTrim(cCampo) $ "MG6_CODIGO|MG6_DESCRI|")}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(1,"MG6",{|cCampo| !(AllTrim(cCampo) $ "MG6_CODIGO|MG6_DESCRI|")})// Informe que os campos do cabecalho nao devem aparecer nos itens
Local oModel := Nil  // objeto modelo

oStructIt:AddTrigger( "MG6_LAYOUT", "MG6_DSCLAY", {|| .T.},;
							 {|oModel| Padr(Posicione("MFG",1,XFILIAL("MFG")+oModel:GetValue("MG6_LAYOUT"),"MFG_DESCRI"),TamSx3("MFG_DESCRI")[1]) } )

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA871A",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
//colocar validacao da linha depois de digitar colocar aspas ""
oModel:AddFields("MG6MASTER", Nil/*cOwner*/, oStructMG6 ,/*Pre-Validacao*/,{||.T.},/*Carga*/)

oModel:SetPrimaryKey( { "MG6_FILIAL","MG6_CODIGO","MG6_LAYOUT" } )

oModel:AddGrid  ('MG6GRID' , 'MG6MASTER',     oStructIt, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
                       
oModel:SetRelation( "MG6GRID", { { "MG6_FILIAL", "xFilial('MG6')" }, { "MG6_CODIGO", "MG6_CODIGO" } }, MG6->( IndexKey( 1 ) ) )

oModel:GetModel( 'MG6GRID' ):SetUniqueLine( { 'MG6_LAYOUT' } )
                                                                 
oModel:GetModel("MG6MASTER"):SetDescription(STR0003) //"Grupo de Layout"

oModel:GetModel("MG6GRID"  ):SetDescription(STR0004) //"Grupo de Layout - Item"

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
Local oView      := Nil   // view do modelo
Local oModel     := FWLoadModel("LOJA871A")
Local oStructMG6 := FWFormStruct(2,"MG6",{|cCampo| (AllTrim(cCampo) $ "MG6_CODIGO|MG6_DESCRI")}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(2,"MG6",{|cCampo| !(AllTrim(cCampo) $ "MG6_CODIGO|MG6_DESCRI")})// Informe que os campos do cabecalho nao devem aparecer nos itens

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWMG6" , oStructMG6, "MG6MASTER" )
oView:AddGrid (  "VIEWGMG6", oStructIt,  "MG6GRID" )

oView:AddIncrementField( 'VIEWGMG6', 'MG6_ITEM' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMG6' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEWGMG6', 'INFERIOR' )
                               
oView:EnableTitleView( 'VIEWMG6' )
oView:EnableTitleView( 'VIEWGMG6')
                                                       	
Return oView
