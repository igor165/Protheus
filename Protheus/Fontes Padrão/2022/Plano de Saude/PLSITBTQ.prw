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

//��������������������������������������������������������������������������Ŀ
//� Instancia a Classe de Browse.											 �
//����������������������������������������������������������������������������
oBrowse := FWMBrowse():New()

// Definicao do MenuDef a ser utilizado.          �
//����������������������������������������������������������������������������
oBrowse:SetMenuDef("PLSITBTQ")

//��������������������������������������������������������������������������Ŀ
//� Definicao da tabela do Browse.											 �
//����������������������������������������������������������������������������
oBrowse:SetAlias("BTQ")

//��������������������������������������������������������������������������Ŀ
//� Definicao de Filtros.													 �
//����������������������������������������������������������������������������
cFiltroAux := " BTQ->BTQ_CODTAB == '"+BTP->BTP_CODTAB+"'"

oBrowse:SetFilterDefault(cFiltroAux)

//��������������������������������������������������������������������������Ŀ
//� Definicao do titulo do Browse.											 �
//����������������������������������������������������������������������������
oBrowse:SetDescription("Atalho Itens Terminologia")

//��������������������������������������������������������������������������Ŀ
//� Desabilita a exibicao dos Detalhes.										 �
//����������������������������������������������������������������������������
oBrowse:DisableDetails()

//��������������������������������������������������������������������������Ŀ
//� Ativacao da Classe de Browse.											 �
//����������������������������������������������������������������������������
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

//��������������������������������������������������������������������������Ŀ
//� Cria a estrutura a ser usada no Modelo de Dados.						 �
//����������������������������������������������������������������������������
Local oStruBTQ 	:= FWFormStruct( 1, "BTQ", /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel	:= Nil

oStruBTQ:SetProperty( 'BTQ_CODTAB', MODEL_FIELD_INIT, { || BTP->BTP_CODTAB } )

//��������������������������������������������������������������������������Ŀ
//� Cria o objeto do Modelo de Dados.										 �
//����������������������������������������������������������������������������
oModel := MPFormModel():New("PLSITBTQ", /*bPreValidacao*/, { | oMdl | PLIBTQVAL( oMdl ) }, /*bCommit*/, /*bCancel*/ )

//��������������������������������������������������������������������������Ŀ
//� Adiciona a descricao do Modelo de Dados.								 �
//����������������������������������������������������������������������������
oModel:SetDescription( "Modelo de Dados BTQ" )

//��������������������������������������������������������������������������Ŀ
//� Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo.		 �
//����������������������������������������������������������������������������
oModel:AddFields( "BTQTESTE", /*cOwner*/, oStruBTQ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//��������������������������������������������������������������������������Ŀ
//� Adiciona a descricao do Componente do Modelo de Dados.					 �
//����������������������������������������������������������������������������
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

//��������������������������������������������������������������������������Ŀ
//�Cria a estrutura a ser usada na View. 									 �
//����������������������������������������������������������������������������
Local oStruBTQ 	:= FWFormStruct( 2, "BTQ" )
Local oView		:= Nil

oStruBTQ:SetProperty( 'BTQ_CODTAB' , MVC_VIEW_CANCHANGE, .F. )
//oStruBTQ:SetProperty( 'BTQ_CDTERM' , MVC_VIEW_MODAL, .T. )    
	
//��������������������������������������������������������������������������Ŀ
//�Cria o objeto de View.				 									 �
//����������������������������������������������������������������������������
oView := FWFormView():New()

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado.
oModel   	:= FWLoadModel( "PLSITBTQ" )	

//Define qual o Modelo de dados ser� utilizado.							 
oView:SetModel( oModel )  

//��������������������������������������������������������������������������Ŀ
//�Adiciona no nosso View um controle do tipo FormFields(antiga enchoice).	 �
//����������������������������������������������������������������������������
oView:AddField( "VIEW_TESTE", oStruBTQ, "BTQTESTE" )

//��������������������������������������������������������������������������Ŀ
//�Criar um "box" horizontal para receber algum elemento da view.			 �
//����������������������������������������������������������������������������
oView:CreateHorizontalBox( 'BOX0101' 	, 100 , , , , )

//��������������������������������������������������������������������������Ŀ
//�Relaciona o ID da View com o "box" para exibicao.						 �
//����������������������������������������������������������������������������
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
				Help( ,, 'Help',, 'Registro j� existe. Informa��o Duplicada', 1, 0 )
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
Valida se o campo poder� ser editado na altera��o
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


