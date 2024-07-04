#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA304.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA304
Cadastro Concorrent X Produto.

@author Varejo
@since 21/10/2013
@version P11
/*/
//-------------------------------------------------------------------
Function LOJA304()
Local oBrowse// obejto browse que sera exibido na tela


oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MG3' )     
oBrowse:SetDescription( STR0001 ) //"Concorrente X Produto"
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
Local aRotina        := {}     //rotinas do cadastro

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"  	           OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOJA304"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA304"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA304"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA304"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"

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
Local oStructMG3 := FWFormStruct(1,"MG3") // Informe os campos que eu quero no cabecalho
Local oModel := Nil// modelo MVC

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA304",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

oModel:AddFields("MG3MASTER", Nil/*cOwner*/, oStructMG3 ,/*Pre-Validacao*/,/*Pos-Validacao*/{||Lj304Vld(oModel)},/*Carga*/)

oModel:SetPrimaryKey( { "MG3_FILIAL","MG3_CODIGO","MG3_CODCCT","MG3_CODPRD" } )
                                                                        
oModel:GetModel("MG3MASTER"):SetDescription(STR0001)


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
Local oView        := Nil                    //objeto view
Local oModel       := FWLoadModel("LOJA304")// carrega o model
Local oStructMG3 := FWFormStruct(2,"MG3") // Informe os campos que eu quero no cabecalho
//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
            

oView:AddField( "VIEWMG3" , oStructMG3, "MG3MASTER" )
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMG3' , 'SUPERIOR' )
                               
oView:EnableTitleView( 'VIEWMG3' )
                                                       	
Return oView


//-------------------------------------
/*Lj304Vld()
Valida se o Preco ja foi cadastrado para o concorrente X produto

@author Varejo
@since 26/07/2013
@return lRet
 */
//-------------------------------------
Static Function Lj304Vld(oModel)

Local lRet  := .T.                                   //variavel que controla retorno
Local aArea    := GetArea()                          //armazena posicionamento atual da tabela
Local oModel   := oModel:GetModel('MG3MASTER')       // Modelo Cabecalho
Local cProduto := oModel:GetValue('MG3_CODPRD')      // Codigo do produto
Local dDataPrd := DTOS(oModel:GetValue('MG3_EMISSA'))// Data de emissao
Local cCodigo  := oModel:GetValue('MG3_CODIGO')      // Codigo do registro
Local cConncor := oModel:GetValue('MG3_CODCCT')      // Codigo do concorrente
Local nPreco   := oModel:GetValue('MG3_PRECO')       // Preco do produto do cocncorrente

MG3->(DbSetOrder(2))
If MG3->(DbSeek(xFilial("MG3")+cProduto+cConncor+dDataPrd)) 
	While MG3->(!EOF()) .AND. cProduto+cConncor+dDataPrd == MG3->MG3_CODPRD+MG3->MG3_CODCCT+DTOS(MG3->MG3_EMISSA)
		If MG3->MG3_PRECO == nPreco
			MsgInfo(STR0007,STR0008)//"Preço ja cadastrado para esta data!"###"Atenção"
			lRet:=.F.
			Exit
		EndIf
		MG3->(DbSkip())
	EndDo
EndIf

RestArea(aArea)

Return lRet