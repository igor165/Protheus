#INCLUDE "ATFA003.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE OPER_BLOQUEAR	10
#DEFINE OPER_REVISAR	11

Static __cCalcDep
Static __nOper 		:= 0 // Operacao da rotina

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?ATFA003  ?Autor 矼auricio Pequim Jr.    ?Data ?09/12/11 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Cadastro de Al鏰das de aprova玢o por opera玢o              潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?SIGAATF                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?Nenhum                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Function ATFA003()
Local oBrowse
Private cCadastro := STR0001 //"Al鏰das de aprova玢o por opera玢o"
__nOper := 0

ChkFile("FNH")
ChkFile("FNK")
ChkFile("FNL")
ChkFile("SN0")

dbSelectArea('FNK')
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FNK' )
oBrowse:SetDescription( STR0001 )  //"Al鏰das de aprova玢o por opera玢o"
oBrowse:AddLegend( "FNK_STATUS == '1'", "GREEN"		, STR0002  ) //"Habilitado"
oBrowse:AddLegend( "FNK_STATUS == '2'", "RED"  		, STR0003) //"Desabilitado"

oBrowse:Activate()

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北砅rograma  矼enuDef   ?Autor ?Mauricio Pequim Jr.  ?Data ?0/09/11  潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escri噮o ?Utilizacao de menu Funcional                               潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砇etorno   矨rray com opcoes da rotina.                                 潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros砅arametros do array a Rotina:                               潮?
北?         ?. Nome a aparecer no cabecalho                             潮?
北?         ?. Nome da Rotina associada                                 潮?
北?         ?. Reservado                                                潮?
北?         ?. Tipo de Transa噭o a ser efetuada:                        潮?
北?         ?	1 - Pesquisa e Posiciona em um Banco de Dados         潮?
北?         ?   2 - Simplesmente Mostra os Campos                       潮?
北?         ?   3 - Inclui registros no Bancos de Dados                 潮?
北?         ?   4 - Altera o registro corrente                          潮?
北?         ?   5 - Remove o registro corrente do Banco de Dados        潮?
北?         ?. Nivel de acesso                                          潮?
北?         ?. Habilita Menu Funcional                                  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?  DATA   ?Programador   矼anutencao efetuada                         潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?         ?              ?                                           潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0014  	ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0015 	ACTION 'VIEWDEF.ATFA003'  		OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0016   	ACTION 'VIEWDEF.ATFA003' 		OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0017  	ACTION 'AFA003REV'    	  		OPERATION 2 ACCESS 0 //'Revisar'
ADD OPTION aRotina TITLE STR0018	ACTION 'AFA003BLQ' 		  		OPERATION 20 ACCESS 0 //'Bloqueio/Desbloq'
ADD OPTION aRotina TITLE STR0020	ACTION 'AFA003ATU' 		  		OPERATION 30 ACCESS 0 //"Atualiza Aprv."

Return aRotina



//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砇otinas de configura玢o do MVC?
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?MODELDEF ?Autor 矼auricio Pequim Jr.    ?Data ?09/12/11 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Fun玢o que define o modelo do cadastro Al鏰das de aprova玢o潮?
北?         ?por opera玢o para o MVC                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?ATFA003                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?Nenhum                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function Modeldef()

Local oStruFNK 	:= AF003Struct('FNK')
Local oStruFNL 	:= AF003Struct('FNL')
Local oModel		:= Nil
Local aRelacFNL	:= {}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'ATFA003', /*bPreValidacao*/, /*bPreValidacao*/ , /*bPosGrava*/ , /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul醨io de edi玢o por campo
oModel:AddFields( 'FNKMASTER', /*cOwner*/, oStruFNK )

// Remove campos da estrutura para nao aparecer na grid
oStruFNL:RemoveField( 'FNL_FILIAL' )
oStruFNL:RemoveField( 'FNL_ROTINA' )
oStruFNL:RemoveField( 'FNL_REVIS' )

// Adiciona ao modelo uma estrutura de formul醨io de edi玢o por grid
oModel:AddGrid( 'FNLDETAIL'		, 'FNKMASTER'	, oStruFNL, /*bLinePre*/ , { |oModelGrid| FNLLINPOS(oModelGrid) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// N鉶 permite inserir linhas na grid
If __nOper == OPER_BLOQUEAR
	oModel:GetModel( 'FNLDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FNLDETAIL' ):SetNoDeleteLine( .T. )
EndIf

//Relacionamento da tabela Etapa com Projeto
aAdd(aRelacFNL,{ 'FNL_FILIAL'	, 'xFilial( "FNL" )'	})
aAdd(aRelacFNL,{ 'FNL_ROTINA'	, 'FNK_ROTINA' 		})
aAdd(aRelacFNL,{ 'FNL_REVIS'	, 'FNK_REVIS' 			})

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FNLDETAIL', aRelacFNL , FNL->( IndexKey( 1 ) )  )

//Deixa o prenchimento das tabelas opcional
//oModel:GetModel( 'FNLDETAIL' ):SetOptional( .T. )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'FNLDETAIL' ):SetUniqueLine( { 'FNL_OPER' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0006) //'Al鏰das de aprova玢o por opera玢o'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FNKMASTER' ):SetDescription( STR0006 ) // //'Al鏰das de aprova玢o por opera玢o'
oModel:GetModel( 'FNLDETAIL' ):SetDescription( STR0007) //'Itens da al鏰da de aprova玢o por opera玢o'

oStruFNK:SetProperty("FNK_ROTINA",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, SX3Valid("FNK_ROTINA")+' .And. AF003ROT()' ))

Return oModel

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?Viewdef  ?Autor 矼auricio Pequim Jr.    ?Data ?09/12/11 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Fun玢o que define a interface do cadastro Al鏰das de       潮?
北?         ?aprova玢o por opera玢o para o MVC                          潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?ATFA003                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?Nenhum                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Static Function Viewdef()
// Cria a estrutura a ser usada na View
Local oStruFNK := FWFormStruct( 2, 'FNK' )
Local oStruFNL := FWFormStruct( 2, 'FNL' )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'ATFA003' )
Local oView		:= Nil

// Remove campos da estrutura para nao aparecer na grid
oStruFNL:RemoveField( 'FNL_FILIAL' )
oStruFNL:RemoveField( 'FNL_ROTINA' )
oStruFNL:RemoveField( 'FNL_REVIS' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser?utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FNK', oStruFNK, 'FNKMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FNL', oStruFNL, 'FNLDETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 20 )
oView:CreateHorizontalBox( 'INFERIOR' , 80 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FNK', 'SUPERIOR'     	)
oView:SetOwnerView( 'VIEW_FNL', 'INFERIOR' 	)

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_FNK' )
oView:EnableTitleView( 'VIEW_FNL' )

Return oView


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯退屯屯屯脱屯屯屯屯屯屯屯屯屯屯送屯屯脱屯屯屯屯屯屯槐?
北篜rograma  矨F003Struct篈utor  矼auricio Pequim Jr. ?Data ? 26/10/11  罕?
北掏屯屯屯屯拓屯屯屯屯屯褪屯屯屯拖屯屯屯屯屯屯屯屯屯屯释屯屯拖屯屯屯屯屯屯贡?
北篋esc.     ?Retorna a estrutura do modelo com o tratamento das			 罕?
北?         ?operacoes                                                  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function AF003Struct(cAlias)
Local oStruct 	:= FWFormStruct( 1, cAlias, /*bAvalCampo*/, /*lViewUsado*/ )
Local aFields	:= {}
Local nX			:= 0
Local cPrefix	:= PrefixoCpo(cAlias)
Local cCampoBlq:= cPrefix+'_STATUS'

If __nOper == OPER_BLOQUEAR
	// Bloqueia todos os campos menos do bloqueio
	oStruct:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
	oStruct:SetProperty(cCampoBlq , MODEL_FIELD_WHEN , {|| .T. } )
ElseIf __nOper == OPER_REVISAR
	If cAlias == "FNK"
		oStruct:SetProperty("FNK_ROTINA" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FNK_STATUS" , MODEL_FIELD_WHEN , {|| .F. } )
	EndIf
EndIf
*/

//Cria玢o de Gatilho
// [01] Id do campo de origem
// [02] Id do campo de destino
// [03] Bloco de codigo de valida玢o da execu玢o do gatilho
// [04] Bloco de codigo de execu玢o do gatilho
If cAlias == "FNK"
	oStruct:AddTrigger( "FNK_ROTINA" , "FNK_ROTINA"	, {|| .T. }  , {|| AF003GTL("FNK_ROTINA","FNK_DESCRT") }  )
	oStruct:AddTrigger( "FNK_STATUS" , "FNK_STATUS"	, {|| .T. }  , {|| AF003GTL("FNK_STATUS","FNL_STATUS") }  )
ElseIf cAlias == "FNL"
	oStruct:AddTrigger( "FNL_OPER"	, "FNL_OPER"	, {|| .T. }  , {|| AF003GTL("FNL_OPER","FNL_DESCOP") }  )
	oStruct:AddTrigger( 'FNL_CODAPR' , 'FNL_CODAPR' , {|| .T. }  , {|| AF003GTL("FNL_CODAPR","FNL_NOMAPR") }  )
EndIf

Return oStruct



//
//revisao de alcada
//


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨FA003REV 篈utor  矼auricio Pequim Jr. ?Data ? 24/10/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Realiza a revis鉶 do projeto de imobilizado                罕?
北?         ?                                                           罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AFA003REV(cAlias,nReg,nOpc)

Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cRotina       := FNK->FNK_ROTINA
Local cRev          := FNK->FNK_REVIS
Local lRet          := .T.


If lRet .And. FNK->FNK_STATUS == '2'
	Help(" ",1,"AF003BLOQ",,STR0008 ,1,0) //"N鉶 ?possivel revisar al鏰da de aprova玢o com esse status"
	lRet := .F.
EndIf

If lRet .and. FNL->(MsSeek(xFilial("FNL") + cRotina + cRev))

	nRecno		 := FNK->(RECNO())
	__nOper      := OPER_REVISAR
	cTitulo      := STR0006 //'Al鏰das de Aprova玢o por Opera玢o'
	cPrograma    := 'ATFA003'
	nOperation   := MODEL_OPERATION_INSERT

	oModel       := FWLoadModel( cPrograma )
	oModel:SetOperation( nOperation ) // Inclus鉶
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	oModel:DeActivate()
	__nOper      := 0

	If nRet == 0 //Confirmou
		AF003Flag(nRecno)
	Endif

EndIf

RestArea(aArea)
Return


//
//revisao de alcada
//


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨FA003BLQ 篈utor  矼auricio Pequim Jr. ?Data ? 24/10/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Realiza o Bloqueio da Alcada de aprovacao                  罕?
北?         ?                                                           罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AFA003BLQ(cAlias,nReg,nOpc)

Local aArea			:= GetArea()
Local lConfirma	:= .F.
Local lCancela		:= .F.
Local cTitulo		:= ""
Local cPrograma	:= ""
Local nOperation	:= 0
Local cRotina		:= FNK->FNK_ROTINA
Local cRev			:= FNK->FNK_REVIS
Local cStatus		:= FNK->FNK_STATUS
Local cNewRev		:= Soma1(cRev)
Local lRet			:= .T.
Local nRecFNK		:= FNK->(RECNO())

If FNK->(MsSeek(xFilial("FNK") + cRotina + cNewRev))
	Help(" ",1,"AF003REVS",,STR0009+CRLF+STR0010 ,1,0) //"Existe revis鉶 posterior para esta al鏰da de aprova玢o"###"N鉶 ?possivel bloquear/desbloquear al鏰da de aprova玢o neste caso"
	lRet := .F.
Else
	FNK->(dbGoto(nRecFNK))
EndIf

If lRet .and. FNL->(MsSeek(xFilial("FNL") + cRotina + cRev))

	__nOper      := OPER_BLOQUEAR
	cTitulo      := STR0011 //'Al鏰das de Aprova玢o por Opera玢o - Bloqueio/Desbloqueio'
	cPrograma    := 'ATFA003'
	nOperation   := MODEL_OPERATION_UPDATE

	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,{ |oModel| AF003VLBLQ(oModel) } , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )

	__nOper      := 0

EndIf

RestArea(aArea)

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨F003FLAG 篈utor  矼auricio Pequim Jr. ?Data ? 10/26/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Altera os campos flags do projeto                            罕?
北?         ?                                                           罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                        罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function AF003FLAG(nRecno,lBloq)
Local aArea		:= GetArea()

DEFAULT nRecno := 0
DEFAULT lBloq	:= .F.

FNK->(dbSetOrder(1)) //FNK_FILIAL+FNK_ROTINA+FNK_REVIS
FNL->(dbSetOrder(1)) //FNL_FILIAL+FNL_ROTINA+FNL_REVIS+FNL_OPER+FNL_CODAPR

FNK->(DBGOTO(nRecno))

If FNL->( MsSeek( xFilial("FNL") + FNK->(FNK_ROTINA+FNK_REVIS) ) )

	BEGIN TRANSACTION

	//Desabilita o cabecalho (FNK)
	//Se lBloq = .F. - chamada da revisao de alcada
	//Se lBloq = .T. - Chamada da bloqueio de alcada
	RecLock("FNK",.F.)
	If !lBloq
		FNK->FNK_STATUS := '2'
	Endif
	MsUnLock()

	//Desabilita os detalhes (FNL)
	dbselectArea('FNL')
	cKey := xFilial("FNL") + FNL->(FNL_ROTINA+FNL_REVIS)

	While FNL->(!Eof()) .and. cKey == FNL->(FNL->FNL_FILIAL+FNL_ROTINA+FNL_REVIS)
		RecLock("FNL",.F.)
		FNL->FNL_STATUS := FNK->FNK_STATUS
		MsUnLock()
		FNL->(DBSKIP())
	Enddo

	END TRANSACTION

EndIf

RestArea(aArea)

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨F003INREV篈utor  矼auricio Pequim Jr. ?Data ? 24/10/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     砇etorna a revis鉶 do projeto conforme opera玢o              罕?
北?         ?                                                           罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AF003INREV()
Local cRevisao 	:= STRZERO(1,TamSx3("FNK_REVIS")[1] )
Local aArea			:= GetArea()
Local aAreaFNK		:= FNK->(GetArea())
Local cRotina		:= ""

FNK->(dbSetOrder(1)) //FNK_FILIAL+FNK_ROTINA+FNK_REVIS

If __nOper == OPER_REVISAR
	cRotina		:= FNK->FNK_ROTINA
	If FNK->(MsSeek(xFilial("FNK") + cRotina ))
		While FNK->(!EOF()) .And.  FNK->(FNK_FILIAL+FNK_ROTINA) == xFilial("FNK") + cRotina
			cRevisao := FNK->FNK_REVIS
			FNK->(dbSkip())
		EndDo
		cRevisao := Soma1(cRevisao)
	EndIf
EndIf

RestArea(aAreaFNK)
RestArea(aArea)
Return cRevisao

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨F003INROT篈utor  矼auricio Pequim Jr  ?Data ? 13/12/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     砇etorna o c骴igo da rotina caso seja uma operacao de revisao罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AF003INROT()

Local cRotina		:= ""

If __nOper == OPER_REVISAR
	cRotina		:= FNK->FNK_ROTINA
EndIf

Return cRotina


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨F003INIC 篈utor  矼auricio Pequim Jr  ?Data ? 13/12/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Inicializador padrao p/ os campos FNK_DESCROT e FNL_DESCOP 罕?
北?         ?                                                           罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AF003INIC(cCampo)

Local oModel   	:= FWModelActive()
Local oModelFNL	:= oModel:GetModel("FNLDETAIL")
Local cRet := ""

DEFAULT cCampo := '0'

If !INCLUI .or. (__nOper == OPER_REVISAR .And. oModelFNL:nLine==0)

	If cCampo == '1' //FNK_DESCROT
		cRet := Posicione("SN0",1,xFilial("SN0")+"20"+FNK->FNK_ROTINA ,'SUBSTR(N0_DESC01,1,20)')
	ElseIf cCampo == '2' //FNL_DESCOP
		cRet := Posicione("SN0",1,xFilial("SN0")+"21"+FNL->FNL_OPER,"SUBSTR(N0_DESC01,1,20)")
	Endif

Endif

Return cRet


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?AF003GTL ?Autor 矼auricio Pequim Jr     ?Data ?30/09/11 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?Gatilho para atualizacao dos campos          				  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?SIGAATF                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?Nenhum                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Function AF003GTL(cCampoOri,cCampoAtu)

Local oModel   := FWModelActive()
Local oModelFNK:= oModel:GetModel("FNKMASTER")
Local oModelFNL:= oModel:GetModel("FNLDETAIL")
Local cResult	:= ""
Local cDescr	:= ""

SN0->(dbSetOrder(1))

If cCampoOri == "FNK_ROTINA"
	cResult:= oModel:GetValue("FNKMASTER","FNK_ROTINA")

	If SN0->(MsSeek(xFilial('SN0')+'20'+cResult))
		cDescr := SUBSTR(SN0->N0_DESC01,1,20)
	Endif
	oModelFNK:LoadValue( cCampoAtu , cDescr )

ElseIf cCampoOri == "FNL_OPER"
	cResult:= oModel:GetValue("FNLDETAIL","FNL_OPER")
	If SN0->(MsSeek(xFilial('SN0')+'21'+cResult))
		cDescr := SUBSTR(SN0->N0_DESC01,1,20)
	Endif
	oModelFNL:LoadValue( cCampoAtu , cDescr )

ElseIf cCampoOri == "FNL_CODAPR"
	cResult:= oModel:GetValue("FNLDETAIL","FNL_CODAPR")
	cDescr := UsrRetName(cResult)

	oModelFNL:LoadValue( cCampoAtu , cDescr )
ElseIf cCampoOri == "FNK_STATUS"
	cResult:= oModel:GetValue("FNKMASTER","FNK_STATUS")
	AF003STAT(oModel,cResult)
Endif

Return cResult


/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘?
北矲un噮o    ?AF003GNAP?Autor 矼auricio Pequim Jr     ?Data ?30/09/11 潮?
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢?
北矰escricao ?inicializador padrao do campo FNL_NOMAPR         			  潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北?Uso      ?SIGAATF                                                    潮?
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢?
北砅arametros?Nenhum                                                     潮?
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
/*/
Function AF003GNAP()

Local oModel   	:= FWModelActive()
Local oModelFNL	:= oModel:GetModel("FNLDETAIL")
Local cDescr	:= ""

If !INCLUI .or. (__nOper == OPER_REVISAR .And. oModelFNL:nLine==0)
	cDescr := UsrRetName(FNL->FNL_CODAPR)
Endif

Return cDescr



/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨003Stat  篈utor 矨lvaro Camillo Neto ?Data ? 05/12/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Realiza todas as pos-valida珲es de linha do modelo na      罕?
北?         ? p髎 valida玢o da rotina                                   罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Static Function AF003Stat(oModel,cStatus)
Local lRet			:= .T.
Local oModelFNL	:= oModel:GetModel("FNLDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX				:= 0

// N鉶 permite inserir linhas na grid
If __nOper == OPER_BLOQUEAR

	For nX := 1 To oModelFNL:Length()
		oModelFNL:GoLine( nX )
		oModelFNL:LoadValue( "FNL_STATUS" , cStatus )
	Next nX

Endif

FWRestRows(aSaveLines)

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨F003VLBLQ篈utor  矼auricio Pequim Jr  ?Data ? 13/12/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Realiza todas as pre-valida珲es de linha do grid permitindo罕?
北?         ? ou nao a edicao da linha                                  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AF003VLBLQ(oModel)

Local oModelFNL	:= oModel:GetModel("FNLDETAIL")
Local cFlagFNK		:= ""
Local cFlagFNL		:= ""
Local cOper			:= ""
Local lRet			:= .T.
Local aSaveLines  := FWSaveRows()
Local nX		  		:= 0

cFlagFNK := oModel:GetValue("FNKMASTER","FNK_STATUS")

If cFlagFNK == '2' //Desabilitado

	For nX := 1 To oModelFNL:Length()
		oModelFNL:GoLine( nX )
		If !oModelFNL:IsDeleted()
			cFlagFNL := oModel:GetValue("FNLDETAIL","FNL_STATUS")
			If cFlagFNK != cFlagFNL
				cOper := oModel:GetValue("FNLDETAIL","FNL_OPER")
				Help(" ",1,"AF003STATUS",,STR0012+CRLF+STR0013+ cOper ,1,0) //"Status da rotina e da opera玢o est鉶 divergentes."###"Verifique status da operacao "
				lRet := .F.
			Endif
   	Endif

		If !lRet
			Exit
		EndIf
	Next

EndIf

FWRestRows(aSaveLines)

Return lRet


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨F003BLQV 篈utor  矼auricio Pequim Jr  ?Data ? 13/12/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Realiza todas as pre-valida珲es de linha do grid permitindo罕?
北?         ? ou nao a edicao da linha                                  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AF003BLQV()

Local oModel   	:= FWModelActive()
Local cPeriodo		:= ""
Local lRet			:= .F.

cPeriodo := oModel:GetValue("FNLDETAIL","FNL_PERIOD")

IF cPeriodo != '0'
	lRet := .T.
Endif

Return lRet



/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矨FA003ATU 篈utor  矼auricio Pequim Jr. ?Data ? 24/10/11   罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ?Realiza a atualizacao dos aprovadores nas tarefas de       罕?
北?         ?aprovacao                                                  罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ?AP                                                         罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function AFA003ATU(cAlias,nReg,nOpc)

Local aArea         := GetArea()
Local cRotina       := FNK->FNK_ROTINA
Local cRev          := FNK->FNK_REVIS
Local lRet          := .T.
Local cAliasQry 	:= GetNextAlias()

If lRet .And. FNK->FNK_STATUS == '2'
	Help(" ",1,"AF003ATU1",,STR0023 ,1,0) //"Este controle de al鏰da est?bloqueado. Utilize uma revisao ativa para realizar a atualiza玢o de aprovadores."
	lRet := .F.
EndIf

FNL->(dbSetOrder(1))
If lRet .and. FNL->(MsSeek(xFilial("FNL") + cRotina + cRev))

	nRecno		 := FNK->(RECNO())

	lAtualiza := MSGYESNO(STR0021,STR0022) //"Deseja realmente atualizar as tarefas de aprova玢o deste processo com os aprovadores atuais?"###"Aten玢o"


	If lAtualiza //Confirmou

		cQuery := "SELECT FNL_CODAPR, FNM.R_E_C_N_O_ RECNOFNM FROM " + RetSQLTab('FNM')
		cQuery +=  " INNER JOIN "+ RetSQLTab('FNL')+" ON "
		cQuery +=    " FNM_ROTINA = FNL_ROTINA AND "
		cQuery +=    " FNM_OPER = FNL_OPER "
		cQuery +=  " WHERE "
		cQuery += 	 " FNM_STATUS = '1' AND "
		cQuery += 	 " FNM_CODAPR <> FNL_CODAPR AND "
		cQuery +=    " FNL_STATUS <> '2' AND "
		cQuery += RetSqlCond("FNL") + " AND "
		cQuery += RetSqlCond("FNM")

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		dbSelectArea(cAliasQry)

		DbGotop()
		If !EOF() .AND. !BOF()

			BEGIN TRANSACTION

			While !(cAliasQry)->(Eof())

				FNM->(DBGOTO((cAliasQry)->RECNOFNM))

				RecLock("FNM")
				FNM->FNM_CODAPR := (cAliasQry)->FNL_CODAPR
				FNM->(MsUnlock())

				(cAliasQry)->(dbskip())
	        Enddo

			END TRANSACTION

		Endif
		(cAliasQry)->(DbCloseArea())

	Endif

EndIf

RestArea(aArea)

Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯屯屯送屯屯淹屯屯屯屯屯屯屯屯屯屯屯屯送屯脱屯屯屯屯槐?
北篜rograma  矨f003ROT      篈utor矹ose Domingos Caldana Jr 篋ata?6/10/12罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯释屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯释屯拖屯屯屯屯贡?
北篋escri嘺o 砎erifica se j?existe conteudo na Grid                      罕?
北棠哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪贡?
北篟etorno   砙L] - .T. Se nao existir conteudo na Grid                   罕?
北棠哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪贡?
北篜arametros?                                                           罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
Function Af003ROT()

Local oModel   		:= FWModelActive()
Local oModelFNL		:= oModel:GetModel("FNLDETAIL")
Local nx
Local lRet 			:= .T.

For nX := 1 To oModelFNL:Length()
	oModelFNL:GoLine( nX )
	If !Empty(oModel:GetValue("FNLDETAIL","FNL_OPER")) .And. !oModelFNL:IsDeleted()
		lRet := .F.
		Help(" ",1,"AF003ROT",,STR0024 ,1,0) //"N鉶 ?possivel alterar a rotina, pois j?existe opera玢o informada."
		Exit
	EndIf
Next nX

Return lRet


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯屯屯送屯屯淹屯屯屯屯屯屯屯屯屯屯屯屯送屯脱屯屯屯屯槐?
北篜rograma  砈X3Valid      篈utor矹ose Domingos Caldana Jr 篋ata?6/10/12罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯释屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯释屯拖屯屯屯屯贡?
北篋escri嘺o 砇ecupera validacao de Campo do dicion醨io de dados (SX3)    罕?
北棠哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪贡?
北篟etorno   砙C] - Express鉶 de Valida玢o do campo                       罕?
北棠哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪贡?
北篜arametros砙C] - Codigo do Campo                                       罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/

Static Function SX3Valid(cCampo)

Local aArea 	:= GetArea()
Local aAreaSX3
Local cValid	:= ""

If ValType(cCampo) == "C"

	aAreaSX3 	:= SX3->(GetArea())

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(cCampo))
		cValid := IIf(!Empty(SX3->X3_VALID),Alltrim(SX3->X3_VALID),"")
		cValid += IIf(!Empty(SX3->X3_VALID).And.!Empty(SX3->X3_VLDUSER)," .And. ","")
		cValid += IIf(!Empty(SX3->X3_VLDUSER),Alltrim(SX3->X3_VLDUSER),"")
	EndIf

	RestArea(aAreaSX3)

EndIf

If Empty(cValid)
	cValid := ".T."
Endif

RestArea(aArea)

Return cValid


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯屯屯送屯屯淹屯屯屯屯屯屯屯屯屯屯屯屯送屯脱屯屯屯屯槐?
北篜rograma  矲NLLINPOS     篈utor矹ose Domingos Caldana Jr 篋ata?6/10/12罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯释屯屯贤屯屯屯屯屯屯屯屯屯屯屯屯释屯拖屯屯屯屯贡?
北篋escri嘺o 砎alida se Chave ja foi cadastrada                           罕?
北棠哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪贡?
北篟etorno   砙L] - .T. Se Rotina+Operacao nao existir                    罕?
北棠哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪贡?
北篜arametros砙O] - Modelos da Grid - Tabela FNL                          罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/

Static Function FNLLINPOS(oModelFNL)
Local lRet 			:= .T.
Local oModel   		:= FWModelActive()
Local cRotina		:= oModel:GetValue("FNKMASTER","FNK_ROTINA")
Local cOper			:= oModelFNL:GetValue("FNL_OPER")

If !oModelFNL:IsDeleted()
	lRet :=  ExistCpo("FNH",cRotina+cOper)
EndIf

Return lRet


//Master