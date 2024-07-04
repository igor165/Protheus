#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCOMMAND.CH"
#INCLUDE "VDFA080.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} VDFA080()
Cadastro de Workflow de Aprovacoes
@author Marcelo Faria
@since 19/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function VDFA080()
Local oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("RIB")
	oMBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional
@author Marcelo Faria
@since 19/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE OemToAnsi(STR0001) ACTION "PESQBRW"         OPERATION 1 ACCESS 0 DISABLE MENU //Pesquisar
	ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION "VIEWDEF.VDFA080" OPERATION 2 ACCESS 0             //"Visualizar" 
	ADD OPTION aRotina TITLE OemToAnsi(STR0003) ACTION "VIEWDEF.VDFA080" OPERATION 3 ACCESS 0             //"Incluir"    
	ADD OPTION aRotina TITLE OemToAnsi(STR0004) ACTION "VIEWDEF.VDFA080" OPERATION 4 ACCESS 0             //"Alterar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0005) ACTION "VIEWDEF.VDFA080" OPERATION 5 ACCESS 0             //"Excluir"
	ADD OPTION aRotina TITLE OemToAnsi(STR0006) ACTION "VIEWDEF.VDFA080" OPERATION 8 ACCESS 0             //"Imprimir" 	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do modelo da regra de negocios
@author Marcelo Faria
@since 19/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel
Local bPosValid := { |oModel| VDFA080_PosVal( oModel ) } 
Local bLinePre  := {|oModel, nLine, cAction, cField| VDFA080_LPRE(oModel, nLine, cAction, cField)}
Local bLinePost := {|oModel, nLine, cAction, cField| VDFA080_LinePOS(oModel, nLine, cAction)}
Local oStruRIB
Local oStruRIC
	
	oStruRIB  := FWFormStruct( 1, 'RIB', /*bAvalCampo*/, /*lViewUsado*/ )
	oStruRIC  := FWFormStruct( 1, 'RIC', /*bAvalCampo*/, /*lViewUsado*/ )

	oStruRIC:SetProperty( "RIC_DEPTO", MODEL_FIELD_WHEN, { |oModel| VDFA080_When(oModel, 1) } )
	oStruRIC:SetProperty( "RIC_RESP",  MODEL_FIELD_WHEN, { |oModel| VDFA080_When(oModel, 2) } )
	oStruRIC:SetProperty( "RIC_CODIGO",MODEL_FIELD_OBRIGAT,.F.)

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'MDVDFA080', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'RIBMASTER', /*cOwner*/, oStruRIB, /*bLOkVld*/, /*bTOkVld*/, /*bCarga*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'RICDETAIL', 'RIBMASTER', oStruRIC, bLinePre, bLinePost, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'RICDETAIL', { { 'RIC_FILIAL', 'xFilial( "RIC" )' }, { 'RIC_CODIGO', 'RIB_CODIGO' } }, RIC->( IndexKey( 1 ) ) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'RICDETAIL' ):SetUniqueLine( { 'RIC_ETAPA' } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
@author Marcelo Faria
@since 19/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruRIB := FWFormStruct( 2, 'RIB' )
Local oStruRIC := FWFormStruct( 2, 'RIC' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'VDFA080' )
Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	oStruRIC:RemoveField( 'RIC_CODIGO' )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_RIB', oStruRIB, 'RIBMASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_RIC', oStruRIC, 'RICDETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 15 )
	oView:CreateHorizontalBox( 'INFERIOR', 85 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RIB', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_RIC', 'INFERIOR' )

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_RIC', 'RIC_ETAPA' )

	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_RIB','Workflow de Aprovacao')
	oView:EnableTitleView('VIEW_RIC','Etapas do Workflow')

	// Liga a Edição de Campos na FormGrid
	oView:SetViewProperty( 'VIEW_RIC', "DISABLEDGRIDDETAIL", { 60 } )

Return oView

//-------------------------------------------------------------------
Static Function VDFA080_PosVal( oModel )
Local nOperation := oModel:GetOperation()
Local lRet      := .T. 
Local oModelRIB := oModel:GetModel( 'RIBDETAIL' )

    If nOperation == MODEL_OPERATION_UPDATE
        FwFldPut('RIB_DATA', dDataBase, , oModelRIB)
    EndIf  
Return (lRet)          

//-------------------------------------------------------------------
Static Function VDFA080_When(oModel, nCampo)
Local cOrigem   := ""
Local lRet      := .T.
    
    cOrigem         := alltrim(oModel:GetValue( "RIC_DEST" ))

    If cOrigem != "1"
        lRet := .F.
    EndIf
 
Return( lRet )

//-------------------------------------------------------------------
Static Function VDFA080_LPRE( oModelGrid, nLinha, cAcao, cCampo )
Local lRet      := .T.
Local oModelRIC := oModelGrid:GetModel( 'RICDETAIL' )

    If cCampo == "RIC_DEST"
        If FwFldGet('RIC_DEST') == '2' .or. FwFldGet('RIC_DEST') == '3'
           FwFldPut('RIC_DEPTO', '', nlinha, oModelRIC,.F.,.T.)
           FwFldPut('RIC_DDEPTO', '', nlinha, oModelRIC,.F.,.T.)
           FwFldPut('RIC_RESP', '', nlinha, oModelRIC,.F.,.T.)
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
Static Function VDFA080_LinePOS( oModelGrid, nLinha, cAcao )
Local lRet      := .T.
Local oModelRIC := oModelGrid:GetModel( 'RICDETAIL' )
Local cRICDest  := FwFldGet('RIC_DEST',,oModelRIC)
Local cRICDepto := FwFldGet('RIC_DEPTO',,oModelRIC)
    
    If cAcao <> 'DELETE' 
        If cRICDest == "1" .and. empty(cRICDepto)
           Help( ,, OemToAnsi(STR0007), , OemToAnsi(STR0008), 1, 0 ) //"Ajuda" - "Lotacao nao informada para o destino!"
           lRet := .F.
        EndIf      
    EndIF

Return lRet

