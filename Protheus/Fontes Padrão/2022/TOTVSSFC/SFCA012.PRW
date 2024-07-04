#INCLUDE "SFCA012.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA012
Tela de cadastro de Equipe x Operador

@author Tiago Gauziski
@since 16/08/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA012()
Local oBrowse

SFCValInt() // Verifica integração ligada

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'CYH' )
oBrowse:SetDescription( STR0001 ) // 'Equipe X Operador'  
oBrowse:AddFilter( STR0002, "CYH_TPRC=='3'", .T., .T.)   //'Tipo do Recurso'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0003 Action 'PesqBrw'         OPERATION 1 ACCESS 0  // 'Pesquisar'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.SFCA012' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.SFCA012' OPERATION 4 ACCESS 0  // 'Alterar'
//ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.SFCA012' OPERATION 5 ACCESS 0  // 'Excluir'
ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.SFCA012' OPERATION 8 ACCESS 0  // 'Imprimir'
ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.SFCA012' OPERATION 9 ACCESS 0  // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructCYH := FWFormStruct( 1, 'CYH', /*bAvalCampo*/, .T./*lViewUsado*/ )
Local oStructCZ1 := FWFormStruct( 1, 'CZ1', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA012', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CYHMASTER', /*cOwner*/, oStructCYH )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'CZ1DETAIL', 'CYHMASTER', oStructCZ1, /*bLinePre*/, { |oMdlG| SFCA012CZ1( oMdlG ) } /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CZ1DETAIL', { { 'CZ1_FILIAL', 'xFilial( "CZ1" )' }, { 'CZ1_IDRCGR', 'CYH_IDRC' } }, CZ1->(IndexKey(1)) )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'CZ1DETAIL' ):SetUniqueLine( { 'CZ1_CDOE' } )
oModel:GetModel( 'CYHMASTER' ):SetOnlyView()

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'CZ1DETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0009 ) //'Modelo de Equipe x Operador'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CYHMASTER' ):SetDescription( STR0010 ) //'Dados da Equipe'
oModel:GetModel( 'CZ1DETAIL' ):SetDescription( STR0011  ) //'Dados dos Operadores da Equipe'

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStructCYH := FWFormStruct( 2, 'CYH' )
Local oStructCZ1 := FWFormStruct( 2, 'CZ1' )
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'SFCA012' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Para nao reabrir a tela, após salvar registro
oView:SetCloseOnOk({||.T.})  

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYH', oStructCYH, 'CYHMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CZ1', oStructCZ1, 'CZ1DETAIL' )   

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )                      
                                             
// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'INFERIOR' )                                             
                                                 
// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', STR0012 ) //'Operadores'

oView:CreateHorizontalBox( "INFERIOROOPERADORES"  , 100,,,"PASTAS","ABA01" )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYH', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CZ1', 'INFERIOROOPERADORES' )       

//Remove o campo repetido em tela
oStructCZ1:RemoveField("CZ1_IDRCGR")
oStructCZ1:RemoveField("CZ1_IDRCOE") 
oStructCZ1:RemoveField("CZ1_DSGR")
oStructCZ1:RemoveField("CZ1_CDGR") 

Return oView
              
//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA012CZ1
Rotina de validação do grid da tabela CZ1 (Equipe x Operador)

@param   oModelGrid        Model do grid da tabela

@author Tiago Gauziski
@since 02/09/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SFCA012CZ1 (oModelGrid)   
Local lRet     := .T.       
Local nI       := 0                    
Local nLineCZ1 := oModelGrid:GetLine()

If Empty(FwFldGet('CZ1_CDOE')) 
	SFCMsgErro(STR0013, "SFCA012") //"O campo Operador é obrigatório"
	lRet = .F.
ElseIf(FwFldGet('CZ1_DTBGVD') > FwFldGet('CZ1_DTEDVD'))
	SFCMsgErro(STR0014, "SFCA012") //"Data Final precisa ser maior que a Data Inicial."
	lRet = .F.	 
Else
	For nI := 1 To oModelGrid:GetQtdLine() 
		If(nI == nLineCZ1 .Or. oModelGrid:IsDeleted(nI))
  			Loop
   		EndIf
   		If( FwFldGet('CZ1_CDOE', nI) == FwFldGet('CZ1_CDOE') )
   			If(SFCXValDate(FwFldGet('CZ1_DTBGVD', nI), FwFldGet('CZ1_DTEDVD', nI), FwFldGet('CZ1_DTBGVD')) == .T. .Or.;
			   SFCXValDate(FwFldGet('CZ1_DTBGVD', nI), FwFldGet('CZ1_DTEDVD', nI), FwFldGet('CZ1_DTEDVD')) == .T. .Or.;
   			   SFCXValDate(FwFldGet('CZ1_DTBGVD'), FwFldGet('CZ1_DTEDVD'), FwFldGet('CZ1_DTBGVD', nI)) == .T. .Or.;
			   SFCXValDate(FwFldGet('CZ1_DTBGVD'), FwFldGet('CZ1_DTEDVD'), FwFldGet('CZ1_DTEDVD', nI)) == .T.) 
			   
				SFCMsgErro(STR0015, "SFCA012") //"Periodo informado está sobrepondo um periodo já existente."
	   			lRet := .F.	   
			EndIf		
   		EndIf 
   		
	Next
EndIf 

Return lRet    