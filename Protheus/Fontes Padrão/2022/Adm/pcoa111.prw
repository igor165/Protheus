#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA111.CH'

#DEFINE OPER_INCLUIR	3
#DEFINE OPER_ALTERAR	4

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA111
Cadastro de Grupos de Usuários do ambiente Planejamento e Controle
Orçamentário.

@author marylly.araujo
@since 10/07/2013
@version MP11
/*/
//-------------------------------------------------------------------
Function PCOA111()

Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ALB')
oBrowse:SetDescription(STR0001) // "Cadastro de Grupos de Usuários"
oBrowse:AddLegend( "ALB_STATUS=='1'", "GREEN" , STR0002 )	//"Ativo"
oBrowse:AddLegend( "ALB_STATUS=='2'", "RED"   , STR0003 )	//"Inativo"

oBrowse:DisableDetails()
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA111
Menu da browse do Cadastro de Grupos de Usuários do ambiente Planejamento e Controle
Orçamentário.

@author marylly.araujo
@since 10/07/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title STR0005	Action 'PesqBrw'			OPERATION 1 ACCESS 0 //Pesquisar
ADD OPTION aRotina Title STR0006	Action 'VIEWDEF.PCOA111'	OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title STR0007	Action 'VIEWDEF.PCOA111'	OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina Title STR0008	Action 'VIEWDEF.PCOA111'	OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina Title STR0009	Action 'VIEWDEF.PCOA111'	OPERATION 5 ACCESS 0 //Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA111
Função do composição do modelo de dados do cadastro de grupos de usuários
do ambiente Planejamento e Controle Orçamentário.

@author marylly.araujo
@since 10/07/2013
@version MP11
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel		:= Nil
Local oStruALB		:= FWFormStruct( 1, "ALB",	/*bAvalCampo*/, /*lViewUsado*/ )
Local oStruALC		:= FWFormStruct( 1, "ALC", 	/*bAvalCampo*/, /*lViewUsado*/ )
Local aRelacALC		:= {}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('PCOA111M', /*bPreValidacao*/, { |oModel| AC111VlMd( oModel) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul?rio de edi??o por campo
oModel:AddFields( 'ALBMASTER', /* cOwner */, oStruALB)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ALCDETAIL'		, 'ALBMASTER'	, oStruALC, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Validações no Modelo de Dados
oModel:SetVldActivate( {|oModel| AC111VlMd(oModel) } )

//Relacionamento da tabela Etapa com Projeto
aAdd(aRelacALC,{ 'ALC_FILIAL'	, 'xFilial( "ALC" )'	})
aAdd(aRelacALC,{ 'ALC_GRUPO'		, 'ALB_CODIGO' 		})

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ALCDETAIL', aRelacALC , ALC->( IndexKey( 1 ) )  )

/*
	Criação de Gatilho
	[01] Id do campo de origem
	[02] Id do campo de destino
	[03] Bloco de codigo de validação da execução do gatilho
	[04] Bloco de codigo de execução do gatilho
*/
oStruALC:AddTrigger( "ALC_USUARI", "ALC_USUARI"	, {|| .T. }  , {|| PC111GTL("ALC_USUARI","ALC_USRNOM") }  )

/*
 * Definindo a consistência do Grid de existir somente uma vez um usuário do
 * sistema no grupo de usuários
 */
oModel:GetModel( 'ALCDETAIL' ):SetUniqueLine( { 'ALC_USUARI' } )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:SetDescription(STR0010) // "Modelo de Dados do Cadastro de Grupos de Usuários"
oModel:GetModel( 'ALBMASTER' ):SetDescription( STR0011 ) // "Modelo de Dados do Cabeçalho do Grupo de Usuários"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA111
Montagem da camada de interface do cadastro de grupos de usuários
do ambiente Planejamento e Controle Orçamentário

@author marylly.araujo
@since 10/07/2013
@version MP11
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel		:= FWLoadModel( 'PCOA111' )
Local oStruALB		:= FWFormStruct( 2, 'ALB')
Local oStruALC		:= FWFormStruct( 2, 'ALC')
Local oView		:= Nil
Local nOperation 	:= oModel:GetOperation()


//tratamento para Dados Protegidos quando o usuario nao tiver acesso a dados pessoais n?o ativar F3.
If FindFunction("CTPROTDADO") .AND. !CTPROTDADO()
	oStruALC:SetProperty( 'ALC_USUARI', MVC_VIEW_LOOKUP, "" )
Endif

oView := FWFormView():New()
oView:SetModel(oModel)

// Remoção de campos para não serem exibidos dos Grid Usuários
oStruALC:RemoveField( 'ALC_FILIAL' )
oStruALC:RemoveField( 'ALC_GRUPO' )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField(	"VIEW_ALB",	oStruALB,	"ALBMASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(	"VIEW_ALC", 	oStruALC,	"ALCDETAIL")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( "ENCHOICE" , 40 )
oView:CreateHorizontalBox( "GETDADOS" , 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( "VIEW_ALB", "ENCHOICE"  )
oView:SetOwnerView( "VIEW_ALC", "GETDADOS"  )

/*
 * Quando o modo de edição for para inclusão ou alteração, o botão para importação de usuário deve ser exibido.
 */
oView:AddUserButton( STR0012, 'FORM', {|oView| P111ImpGrp() },/*cToolTip*/,/*nShortCut*/,{MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} ) //"Importar"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA111
Função da validação de informações contidas no modelo de dados do
Cadastro de Grupos de Usuários do ambiente Planejamento e Controle
Orçamentário.

@author marylly.araujo
@since 10/07/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function AC111VlMd(oModel)
Local lRet	:= .T.

/*Local cStatus := FNI->FNI_STATUS
Local cBloq   := FNI->FNI_MSBLQL 
Local cRev    := FNI->FNI_REVIS 
Local nOper   := oModel:GetOperation()


If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_DELETE  
	If FNI->(!EOF())
		If Alltrim(cStatus) != "1" .Or. nOper == MODEL_OPERATION_UPDATE .And. Alltrim(cBloq) == "1"
			Help( ,, 'AF005STAT',, STR0023, 1, 0 )//"O Status desse índice não permite manutenção"
			lRet := .F.
		EndIf
		
		If lRet .And. nOper == MODEL_OPERATION_DELETE .And. cRev > "0001"
			Help( ,, 'AF005STAT3',, STR0024, 1, 0 ) //"O indice possui revisão anterior e não poderá ser excluido"
			lRet := .F.
		EndIf
	EndIf
EndIf
*/

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA111
Função para implementar gatilhos em campos com campo de descrição virtual.

@author marylly.araujo
@since 10/07/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function PC111GTL(cCampoOri,cCampoAtu)

Local oModel		:= FWModelActive()
Local oModelALC	:= oModel:GetModel("ALCDETAIL")
Local cResult		:= ""
Local cDescr		:= ""

If cCampoOri == "ALC_USUARI"
	cResult:= oModel:GetValue("ALCDETAIL","ALC_USUARI")
	cDescr := UsrRetName(cResult)

	oModelALC:LoadValue( cCampoAtu , cDescr )
Endif
	
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} PC111GNUsr
Função inicializador padrão do campo do nome do usuário do cadastro
de grupos de usuários do ambiente Planejamento e Controle Orçamentário.

@author	marylly.araujo
@since		12/07/2013
@version	MP11
/*/
//-------------------------------------------------------------------

Function PC111GNUsr()

Local cNome := ""

If !INCLUI
	cNome := UsrRetName(ALC->ALC_USUARI)
Endif
	
Return cNome


//-------------------------------------------------------------------
/*/{Protheus.doc} P111GrpUsr
Função que monta a tela de seleção de grupos de usuários o para filtro genéricos nas rotinas do ambiente Protheus

@param		lTodas			Sinaliza se todos os grupos de usuários estão selecionados na tela.
@return	aSelGrup		Array com os grupos de usuários selecionados.
@author	marylly.araujo
@since		12/07/2013
@version	MP11
/*/
//-------------------------------------------------------------------
Function P111GrpUsr(lTodas)                                  

Local cTitulo		:= ""
Local MvPar		:= ""
Local MvParDef		:= ""
Local aArea		:= GetArea() 			
Local nReg			:= 0
Local nSit			:= 1
Local aSit			:= {}
Local aSelGrup		:= {}	
Local lDefTop		:= IfDefTopCTB()// verificar se pode executar query (TOPCONN)
Local nTamGrup		:= 0
Local aGrupos 		:= AllGroups()
Local nCount		:= 0
Local nQtdGrps		:= Len(aGrupos)

Default lTodas := .F. // Sinaliza se todos os métodos de depreciação estão selecionados na tela

If lDefTop
	If !IsBlind()
		aSit		:= {}               
		MvParDef	:= ""
		cTitulo	:= STR0013 // "Selecione um grupo de usuários."
		
		For nCount := 1 To nQtdGrps
			cDesc := AllTrim(aGrupos[nCount][1][2])
			Aadd(aSit, cDesc )
		 	MvParDef += aGrupos[nCount][1][1]
		 	
		 	If nTamGrup == 0
		 		nTamGrup := Len(aGrupos[nCount][1][1])
		 	EndIf
		Next nCount		
		
		IF AdmOpcoes(@MvPar,cTitulo,aSit,MvParDef,,,.F.,nTamGrup,nQtdGrps,.T.) // Função que abre a tela com os checkbox para seleção das opções 
			For nReg := 1 To len(mvpar) Step nTamGrup  // Acumula as opções dos métodos de depreciação
				If SubSTR(mvpar, nReg, nTamGrup) <> Replicate("*",nTamGrup)
			 		AADD(aSelGrup, SubSTR(mvpar, nReg, nTamGrup) ) 
				Endif	
				nSit++
			Next nReg
			
			If Empty(aSelGrup) 
	 	  		Help(" ",1,"ATFGERGRP",,STR0014,1,0) //"Por favor, selecionar pelo menos um grupo de usuários."
			EndIf
			lTodas := Len(aSelGrup) == Len(aSit)
		EndIf
	Else
		aSelGrup := {"1"}
	EndIf	
Else
	Help("  ",1,"ATFTPDPTOP",,STR0015,1,0) // "Função de seleção de grupos de usuários do sistema só pode ser utilizada em ambientes TopConnect."                                                                                                                                                                                                                                                                                                                                                                                                                    
EndIf
	
RestArea(aArea)  

Return(aSelGrup)

//-------------------------------------------------------------------
/*/{Protheus.doc} P111ImpGrp
Função importação de usuários do sistema Protheus para o cadastro de
grupos de usuários do ambiente Planejamento e Controle Orçamentário.

@author marylly.araujo
@since 12/07/2013
@version MP11
/*/
//-------------------------------------------------------------------

Function P111ImpGrp()
Local lRet			:= .T.
Local aSelGrup		:= P111GrpUsr() // Tela de Seleção de grupos de usuários de sistema para importação de usuários
Local nGrupo		:= ''	
Local nQtdGrupos	:= Len(aSelGrup)
Local aUserGrp		:= {}
Local nUserGrp		:= 0
Local nQtdUsers	:= 0
Local aArrAux		:= {}
Local oModel		:= FWModelActive()
Local oModelALC	:= oModel:GetModel("ALCDETAIL")
Local lDeleted		:= .F.
Local cCodGrp		:= ''
Local cCodUsr		:= ''
Local nQtdGrp		:= 0
Local nGrp			:= 0

/*
 * Busca de usuários pelos grupos selecionados para importação
 */
For nGrupo := 1 To nQtdGrupos
	cCodGrp	:= AllTrim(aSelGrup[nGrupo])
	aArrAux	:= FWSFGrpUsers(cCodGrp)
	aAdd(aUserGrp,aArrAux)
Next nGrupo

// Quantidade de Usuários encontrados nos grupos de usuários informados
nQtdGrp := Len(aUserGrp)

/*
 * Inclusão de usuários encontrados no sistema para o grid de usuários do grupo de usuários do PCO
 */
For nGrp := 1 To nQtdGrp
	nQtdUsers := Len(aUserGrp[nGrp])
	For nUserGrp := 1 To nQtdUsers
		cCodUsr := AllTrim(aUserGrp[nGrp][nUserGrp])
		/*
		 * Verificação se o usuário já existe preenchido no Grid, se estiver, não será incluído no modelo de dados do Grid
		 */
		If !oModelALC:Seekline({{"ALC_USUARI",cCodUsr}},lDeleted)
			oModelALC:AddLine()
			oModelALC:LoadValue('ALC_USUARI',cCodUsr)
			oModelALC:LoadValue('ALC_USRNOM',UsrRetName(cCodUsr))
		EndIf
	Next nUserGrp
Next nUserGrp

/*
 * Posiciona na primeira linha do Grid de Usuários do Grupo
 */
oModelALC:GoLine(1)

Return lRet