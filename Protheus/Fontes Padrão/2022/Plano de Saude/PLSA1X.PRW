#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSA1X.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA107
Rotina de cadastro de Tabela de Reembolso Patronal.

@author Geraldo Felix Junior.
@since 01/01/11
@version P11
/*/
Function PLSA1X()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B1I' )
oBrowse:SetDescription( STR0002) //"Tabela de Reembolso Patronal"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author Geraldo Felix Junior.
@since 01/01/11
@version P11
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  	Action 'PesqBrw'		OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.PLSA1X'	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'  	Action 'VIEWDEF.PLSA1X' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'  	Action 'VIEWDEF.PLSA1X' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'  	Action 'VIEWDEF.PLSA1X' OPERATION 5 ACCESS 0 
ADD OPTION aRotina Title 'Faixas'  		Action 'PLSA2X' OPERATION 1 ACCESS 0 
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o model

@author Geraldo Felix Junior
@since 01/01/11
@version P11
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruB1I := FWFormStruct( 1, 'B1I', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA1XMD',/*bPreValidacao*/,{|| PlsMdl1X(oModel)},/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'B1IMASTER', /*cOwner*/, oStruB1I )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0002 ) // //"Tabela de Reembolso Patronal"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B1IMASTER' ):SetDescription( STR0002) // //"Tabela de Reembolso Patronal"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author Geraldo Felix Junior.
@since 01/01/11
@version P11
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruB1I := FWFormStruct( 2, 'B1I' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA1X' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B1I', oStruB1I, 'B1IMASTER' )

// Cria container para a view.
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B1I', 'SUPERIOR' )

// Forcar o fechamento da tela ao salvar o model
oView:SetCloseOnOk({|| .T.})

Return oView    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldMdl ºAutor  ³Microsiga           º Data ³  10/25/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsMdl1X(oModel)                       
Local aArea := GetArea()
Local nOperation := oModel:GetOperation()
LOCAL lRet		:= .T.		
	                                     
If nOperation == MODEL_OPERATION_DELETE
    
	// Verifica se existem faixas associadas.
	B1J->( dbSetorder(01) )
	If B1J->( dbSeek(xFilial("B1J") + B1I->B1I_CODOPE + B1I->B1I_CODIGO) )
		Help( ,, 'HELP',,STR0005, 1, 0) // //"Impossivel excluir a tabela porque existem Faixas de Valores relacionadas a ela."
		lRet := .F.
	Endif 		

Endif

RestArea( aArea )

Return lRet