#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'MATA638.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA638
Relacionamento Operações x Componentes

@author Samantha Preima
@since 25/02/2015
@version P11

/*/
//-------------------------------------------------------------------
Function MATA638()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SGF')
oBrowse:SetDescription( STR0001 ) // "Operação X Componente"
oBrowse:Activate()
	
Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar' 
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MATA637' OPERATION 2 ACCESS 0    // 'Visualizar'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MATA637' OPERATION 3 ACCESS 0    // 'Incluir'    
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA637' OPERATION 4 ACCESS 0    // 'Alterar'   
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.MATA637' OPERATION 5 ACCESS 0    // 'Excluir'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructM := FWFormStruct( 1, 'SGF' )
Local oModel

oModel := MPFormModel():New('MATA638', /*bPreValidacao*/, { | oMdl | MATA638POS ( oMdl ) }, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( 'SGFMASTER', /*cOwner*/, oStructM )

oModel:SetPrimaryKey({ "SGF_FILIAL", "SGF_PRODUTO", "SGF_COMP" })

oModel:SetDescription( STR0007 ) //'Relacionamento Operações x Componentes'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
Local oStructM := FWFormStruct( 2, 'SGF' )
Local oModel   := FWLoadModel( 'MATA638' )
Local oView

oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_SGF' , oStructM, 'SGFMASTER' )

oView:CreateHorizontalBox( 'SGF', 100 ) 

Return oView
//-------------------------------------------------------------------
Function MATA638PAI(cProduto, cRoteiro)
Local lRet := .T.

// Verificar se produto existe
dbSelectArea('SB1')
SB1->(dbSetOrder(1))
if !SB1->(dbSeek(xFilial('SB1')+cProduto))
	Help( ,, 'HELP', 'MATA638PROD', , 1, 0) // 'Não existe produto com a chave informada'
	lRet := .F.
Endif

// Verificar se produto + roteiro existe
dbSelectArea('SG2')
SG2->(dbSetOrder(1))
if !SG2->(dbSeek(xFilial('SG2')+cProduto+cRoteiro))
	Help( ,, 'HELP', 'MATA638ROTPRO', , 1, 0) // 'Não existe roteiro para o produto informado'
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
Function MATA638FIL(cProduto, cRoteiro, cOperac, cCompon, cTRT)
Local lRet   := .T. 
Local lExist := .F.
Local lPE    := .T.

// Verificar se produto + roteiro + operação existe
dbSelectArea('SG2')
SG2->(dbSetOrder(1))
if !SG2->(dbSeek(xFilial('SG2')+cProduto+cRoteiro+cOperac))
	Help( ,, 'HELP', 'MATA638OPER', , 1, 0) // 'Não existe operação para o roteiro e produto informado'
	lRet := .F.
Endif

If lRet
	// Verificar se componente existe
	dbSelectArea('SB1')
	SB1->(dbSetOrder(1))
	if !SB1->(dbSeek(xFilial('SB1')+cCompon))
		Help( ,, 'HELP', 'MATA638COMP', , 1, 0) // 'Não existe componente com a chave informada'
		lRet := .F.
	Endif
EndIf
 

/* Vivian - TRZIRQ - Permitir incluir componentes alternativos dos filhos do produto pai */

If lRet

	lExist := .F.
	DbSelectArea("SG1")
	SG1->(DbSetOrder(1))
	SG1->(dbSeek(xFilial("SG1")+cProduto)) 
	While SG1->(!Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cProduto
		If SG1->G1_COMP == cCompon .And. SG1->G1_TRT == cTRT
			lExist := .T.
			Exit 
		Else
			DbSelectArea("SGI")
			SGI->(DbSetOrder(1))
			IF SGI->(dbSeek(xFilial("SGI")+SG1->G1_COMP))
				While SGI->(!Eof()) .And. SGI->GI_FILIAL+SGI->GI_PRODORI == xFilial("SGI")+SG1->G1_COMP
					If SGI->GI_PRODALT == cCompon
						lExist := .T.
						Exit
					ElseIf !SGI->GI_PRODALT == cCompon
						lExist := .F. 
					EndIf 
					SGI->(dbSkip())   
				End
			Endif
		EndIf

		If lExist == .T.
			lRet:= .T.
			Exit
		EndIf	

		dbSelectArea("SG1")
		SG1->(dbSkip())
	End

    // Este ponto de entrada não deve ser divulgado para os clientes
	// Criado apenas para atender Schaefer Yachts
	// Permitir colocar qualquer coisa na relação, mesmo sem estar na estrutura
	If ExistBlock('A638CPSQ')
		aParam := {cProduto, cRoteiro, cOperac, cCompon, cTRT}
	
		lPE := Execblock('A638CPSQ',.F.,.F.,aParam)
		If ValType(lPE) == "L"
			lExist := lPE
		EndIf
	Endif

	If lExist == .F. 
		lRet := .F.
		Help( ,, 'HELP', 'MATA638COMPSQ', , 1, 0) // 'Não existe o componente na sequencia informada'
	EndIf
EndIf

If lRet
	If !IsInCallStack('MATA637POS')
		// Verificar se componente está sendo usado em outra operação
		dbSelectArea('SGF')
		SGF->(dbSetOrder(2))
		if SGF->(dbSeek(xFilial('SGF')+cProduto+cRoteiro+cCompon+cTRT))
			Help( ,, 'HELP', 'MATA638OUTOPE', , 1, 0) // 'Componente já está sendo usado em outra operaçao'
			lRet := .F.
		Endif
	Endif
EndIf

Return lRet

//-------------------------------------------------------------------
Static Function MATA638POS(oModel)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local oModelSGF := oModel:GetModel('SGFMASTER')
Local cProduto  := oModelSGF:GetValue('GF_PRODUTO')
Local cRoteiro  := oModelSGF:GetValue('GF_ROTEIRO')
Local cOperac   := oModelSGF:GetValue('GF_OPERAC')
Local cCompon   := oModelSGF:GetValue('GF_COMP')
Local cTRT      := oModelSGF:GetValue('GF_TRT')

if nOpc == 3
	lRet := MATA638PAI(cProduto, cRoteiro)
	
	lRet := MATA638FIL(cProduto, cRoteiro, cOperac, cCompon, cTRT)
ElseIf nOpc == 5
	// Validar as ordens de produção existentes
Endif

Return lRet