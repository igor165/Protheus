#Include	"Protheus.Ch"
#Include	"FWMVCDef.Ch"  
#Include	"topconn.Ch"
#Include 	"ApWizard.Ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSITBTQ
@author Totvs
@since 25/04/2016
@version P11
/*/
Function PLSITBTQ()

Local	oBrowse := Nil

Private	cCadastro	:= "Atalho Item Terminologia"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Instancia a Classe de Browse.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse := FWMBrowse():New()

// Definicao do MenuDef a ser utilizado.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse:SetMenuDef("PLSITBTQ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao da tabela do Browse.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse:SetAlias("BTQ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Filtros.													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltroAux := " BTQ->BTQ_CODTAB == '"+BTP->BTP_CODTAB+"'"

oBrowse:SetFilterDefault(cFiltroAux)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do titulo do Browse.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse:SetDescription("Atalho Itens Terminologia")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita a exibicao dos Detalhes.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse:DisableDetails()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativacao da Classe de Browse.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define as opcoes do aRotina.

@author Totvs
@since 25/04/2016
@version P11
/*/
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.PLSITBTQ' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina Title 'Incluir' 		Action 'VIEWDEF.PLSITBTQ' OPERATION 3 ACCESS 0 
	ADD OPTION aRotina Title 'Alterar' 		Action 'VIEWDEF.PLSITBTQ' OPERATION 4 ACCESS 0 
	ADD OPTION aRotina Title 'Excluir' 		Action 'VIEWDEF.PLSITBTQ' OPERATION 5 ACCESS 0 
Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o Modelo de Interface.

@author Totvs
@since 25/04/2016
@version P11
/*/
Static Function ModelDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a estrutura a ser usada no Modelo de Dados.						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oStruBTQ 	:= FWFormStruct( 1, "BTQ", /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel	:= Nil

oStruBTQ:SetProperty( 'BTQ_CODTAB', MODEL_FIELD_INIT, { || BTP->BTP_CODTAB } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o objeto do Modelo de Dados.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel := MPFormModel():New("PLSITBTQ", /*bPreValidacao*/, { | oMdl | PLIBTQVAL( oMdl ) }, /*bCommit*/, /*bCancel*/ )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a descricao do Modelo de Dados.								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:SetDescription( "Modelo de Dados BTQ" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona ao modelo uma estrutura de formulário de edição por campo.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddFields( "BTQTESTE", /*cOwner*/, oStruBTQ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a descricao do Componente do Modelo de Dados.					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:GetModel( "BTQTESTE" ):SetDescription( "Itens Terminologia" )

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o Modelo de Interface.

@author Totvs 
@since 25/04/2016
@version P11
/*/
Static Function ViewDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a estrutura a ser usada na View. 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oStruBTQ 	:= FWFormStruct( 2, "BTQ" )
Local oView		:= Nil

oStruBTQ:SetProperty( 'BTQ_CODTAB' , MVC_VIEW_CANCHANGE, .F. )
//oStruBTQ:SetProperty( 'BTQ_CDTERM' , MVC_VIEW_MODAL, .T. )    
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o objeto de View.				 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView := FWFormView():New()

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado.
oModel   	:= FWLoadModel( "PLSITBTQ" )	

//Define qual o Modelo de dados será utilizado.							 
oView:SetModel( oModel )  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona no nosso View um controle do tipo FormFields(antiga enchoice).	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:AddField( "VIEW_TESTE", oStruBTQ, "BTQTESTE" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criar um "box" horizontal para receber algum elemento da view.			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:CreateHorizontalBox( 'BOX0101' 	, 100 , , , , )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Relaciona o ID da View com o "box" para exibicao.						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oView:SetOwnerView( "VIEW_TESTE", "BOX0101" )    

Return(oView)  

//-------------------------------------------------------------------
Static Function PLIBTQVAL()
Local oModel     := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aArea      := GetArea()
Local aAreaBTQ   := BTQ->( GetArea() ) 
Local lOk        := .T.

If nOperation == 3 // Inclusao
	BTQ->( dbSetOrder( 1 ) ) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
	cBTQChave := xFilial( 'BTQ' ) + BTP->BTP_CODTAB + FwFldGet( 'BTQ_CDTERM' )  
	cCodTerm := FwFldGet( 'BTQ_CDTERM' )                                                                                                                     
	If BTQ->( dbSeek(cBTQChave) )   
		While BTQ->(!EOF()) .And. BTQ->(BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM)== cBTQChave
			If BTQ->BTQ_CDTERM  == cCodTerm
				Help( ,, 'Help',, 'Registro já existe. Informação Duplicada', 1, 0 )
				lOk := .F. 
			Endif
			BTQ->(dbSkip())
		Enddo
	EndIf
Endif

RestArea( aAreaBTQ )
RestArea( aArea )

Return lOk



//-------------------------------------------------------------------
/*/{Protheus.doc} 
Define o Modelo de Interface.
Valida se o campo poderá ser editado na alteração
@author Totvs 
@since 25/04/2016
@version P11
/*/

Function PLBTQCMP(cCampo)
Local lRet:=.T.

Default cCampo:=""
	
If IsInCallStack("PLSITBTQ").and. ALTERA
	lRet := .F.
Endif

Return lRet


