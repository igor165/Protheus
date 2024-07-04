#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'        
#INCLUDE "PARMTYPE.CH"
#INCLUDE "HSPAHM62.CH"
//-------------------------------------------------------------------
Function HSPAHM62()
Local oBrowse

If !Hs_ExisDic({{"T","GTK"}},.T.)
	Return
EndIf 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('GTK')
oBrowse:SetDescription(STR0001) //'Cadastro de Críticas - Especialidades / Procedimentos'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  	ACTION 'PesqBrw'          OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.HSPAHM62' OPERATION 2 ACCESS 0 // 'Visualizar'
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.HSPAHM62' OPERATION 3 ACCESS 0 // 'Incluir'
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.HSPAHM62' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.HSPAHM62' OPERATION 5 ACCESS 0 // 'Excluir'
ADD OPTION aRotina TITLE STR0007   	ACTION 'VIEWDEF.HSPAHM62' OPERATION 8 ACCESS 0 // 'Imprimir'
ADD OPTION aRotina TITLE STR0008    ACTION 'VIEWDEF.HSPAHM62' OPERATION 9 ACCESS 0 // 'Copiar'
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruGTI := FWFormStruct( 1, 'GTK', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('HSPM62MODEL', /*bPreValidacao*/, { | oMdl | FS_vldCrit( oMdl )} ,/*bCancel*/ , /*bCancel*/ )
//oModel := MPFormModel():New('HSPM62MODEL', /*bPreValidacao*/, { | oMdl | FS_vldCrit( oMdl ) } ,/*bCancel*/ , /*bCancel*/ )
//oModel := MPFormModel():New('COMP011MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'GTKMASTER', /*cOwner*/, oStruGTI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0012 ) //'Modelo de Dados Críticas de Procedimentos'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'GTKMASTER' ):SetDescription( STR0009 ) // 'Críticas'

// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'HSPAHM62' )
// Cria a estrutura a ser usada na View
Local oStruGTI := FWFormStruct( 2, 'GTK' )
//Local oStruZA0 := FWFormStruct( 2, 'ZA0', { |cCampo| COMP11STRU(cCampo) } )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_GTK', oStruGTI, 'GTKMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_GTK', 'TELA' )

Return oView   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_vldCrit³ Autor ³ MICROSIGA             ³ Data ³05/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao que valida os campos da critica que nao sao obrigat.³±±
±±³          ³ conforme a selecao do campo Controle (GTK_CTRL)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/          
Static Function FS_vldCrit(oModel)
Local nOperation := oModel:GetOperation()
Local lRet       := .T.
Local nDias      := oModel:GetValue("GTKMASTER","GTK_DIAS")
Local nQtdMax    := oModel:GetValue("GTKMASTER","GTK_QTDMAX")
Local cCtrl      := oModel:GetValue("GTKMASTER","GTK_CTRL")
Local nReg       := 0


If nOperation == 3 .or. nOperation == 4 //Inclusao ou Alteracao
	//Verifica se os campos foram preenchidos conforme a seleção no combo
	if cCtrl $ "1/2"
		if nQtdMax <= 0
			Help( ,, 'Help',, STR0010, 1, 0 ) //'Informe a quantidade máxima permitida!'
			lRet := .F.
		endif
	else
		if nDias <= 0
			Help( ,, 'Help',, STR0011, 1, 0 ) // 'Informe a quantidade de dias para o intervalo!'
			lRet := .F.
		endif
	endif

	//Zera o campo necessario conforme selecao no combo (GTK_CTRL)
	if cCtrl $ "1/2" .and. lRet
		oModel:SetValue( 'GTKMASTER', 'GTK_DIAS', 0 )  // FwFldGet( 'ZA0_QTDMUS' ,, oModelZA0 )
	else
		oModel:SetValue( 'GTKMASTER', 'GTK_QTDMAX', 0 )  // FwFldGet( 'ZA0_QTDMUS' ,, oModelZA0 )
	endif
elseif nOperation == 5 //Exclusao
	//Especialidade
	if (nReg := HS_CountTb("GTM", " GTM_CODCRI = '" + GTK->GTK_CODIGO + "'"))> 0
		//HS_MsgInf("Esta crítica está associada a uma Especialidade (GFR)", "Integridade", "Cadastro de Crítica")//"Esta crítica está associada a uma Especialidade (GFR)" ###  "Integridade" ### "Cadastro de Crítica"
		Help( ,, 'Help',, STR0013 + cValToChar(nReg) + " " + STR0014 + " (GFR/GTM). " + STR0015, 1, 0 ) //"Esta crítica está associada à n especialidade(s) (GFR). Não pode ser excluída!"
		lRet := .F.
	elseif (nReg := HS_CountTb("GTL", " GTL_CODCRI = '" + GTK->GTK_CODIGO + "'"))> 0 // Procedimento
		Help( ,, 'Help',, STR0013 + cValToChar(nReg) + " " + STR0016 + " (GA7/GTL). " + STR0015, 1, 0 ) //"Esta crítica está associada à n procedimento(s) (GFR). Não pode ser excluída!"
		lRet := .F.
	elseif (nReg := HS_CountTb("GTN", " GTN_CODCRI = '" + GTK->GTK_CODIGO + "'"))> 0//Paciente
		Help( ,, 'Help',, STR0013 + cValToChar(nReg) + " " + STR0017 + " (GBH/GTN). " + STR0015, 1, 0 ) //"Esta crítica está associada à n procedimento(s) (GFR). Não pode ser excluída!"
		lRet := .F.
	endif	
endif


Return lRet
