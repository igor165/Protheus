#INCLUDE "ATFA490.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE OPER_BLOQUEAR	10
#DEFINE OPER_REVISAR		11
#DEFINE OPER_ATUALIZAR	12
#DEFINE OPER_CONTABIL	13
#DEFINE OPER_EST_CTBL	14
#DEFINE OPER_COPIAR		15
#DEFINE OPER_IMPORTAR   	16
#DEFINE OPER_REALIZAR	17
#DEFINE OPER_EFETREAL	18
#DEFINE OPER_EST_EFET  	19

Static __nOper 			:= 0 // Operacao da rotina
Static __cProcPrinc  	:= "ATFA490"
Static __lConfirmar     	:= .T.
Static __lBTNConfirma   	:= .F.
Static aDadosFNX			:= {}	//Array da consulta F3 do grid da FNX
Static aStatus	 		:= {}	//Descricao de Status possiveis para um controle de provisão
Static aCargaFNX			:= {}	//Array da carga inicial do grid da FNX
Static _nRecFNW			:= 0
Static _oATFA4901

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ATFA490  ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de controle de provisão do Ativo Fixo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFA490()
Local oBrowse

// Incluido por causa da rotina MSDOCUMENT, o MVC não precisa de nenhuma variável private
Private cCadastro := STR0012		//'Controle de Provisão'
Private aRotina	:= MenuDef()

__nOper := 0

If FWHASMVC()

	ChkFile("FNU")
	ChkFile("FNV")
	ChkFile("FNX")
	ChkFile("FNW")
		
	dbSelectArea('FNU')
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'FNU' )
	oBrowse:SetDescription( STR0012 )	//'Controle de Provisão'
	oBrowse:AddLegend( "FNU_MSBLQL == '1'", "RED"	  	, STR0002	) //"Bloqueado"
	oBrowse:AddLegend( "FNU_STATUS == '0'", "WHITE"		, STR0003	) //"Gerado"
	oBrowse:AddLegend( "FNU_STATUS == '1'", "YELLOW"	, STR0004	) //"Atualizado"
	oBrowse:AddLegend( "FNU_STATUS == '2'", "GREEN" 	, STR0005	) //"Efetivado"
	oBrowse:AddLegend( "FNU_STATUS == '3'", "GRAY"	 	, STR0102	) //"Revisado"
	oBrowse:AddLegend( "FNU_STATUS == 'A'", "BLUE"  	, STR0006	) //"Realização Pendente"
		
	SetKey( VK_F12, { || Pergunte("ATFA490A",.T.) } )
		
	oBrowse:Activate()
Else
	Help(" ",1,"AF490MVC",,STR0008,1,0) //"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³04/10/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados 	      ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0067  		ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0		//'Pesquisar'		
ADD OPTION aRotina TITLE STR0068 		ACTION 'VIEWDEF.ATFA490'  		OPERATION 2 ACCESS 0 	//'Visualizar'		
ADD OPTION aRotina TITLE STR0069		ACTION 'VIEWDEF.ATFA490' 		OPERATION 3 ACCESS 0 	//'Incluir'			
ADD OPTION aRotina TITLE STR0070		ACTION 'VIEWDEF.ATFA490' 		OPERATION 4 ACCESS 0 	//'Alterar'			
ADD OPTION aRotina TITLE STR0071		ACTION 'VIEWDEF.ATFA490' 		OPERATION 5 ACCESS 0 	//'Excluir'			
ADD OPTION aRotina TITLE STR0072		ACTION 'AFA490CPY' 	 			OPERATION 2 ACCESS 0 	//'Copiar'			
ADD OPTION aRotina TITLE STR0073  		ACTION 'AFA490ATU'    	  		OPERATION 2 ACCESS 0 	//'Atualizar'		
ADD OPTION aRotina TITLE STR0076		ACTION 'AFA490ICTB'    	  		OPERATION 2 ACCESS 0 	//'Contabilizar'         
ADD OPTION aRotina TITLE STR0093		ACTION 'AFA490ECTB'    	  		OPERATION 2 ACCESS 0 	//'Estorno Contabil'
ADD OPTION aRotina TITLE STR0074		ACTION 'AFA490REV'    	  		OPERATION 2 ACCESS 0 	//'Revisar'         
ADD OPTION aRotina TITLE STR0009		ACTION 'AFA490REA'    	  		OPERATION 4 ACCESS 0 	//"Realizar"		
ADD OPTION aRotina TITLE STR0010		ACTION 'AF490EFRE'    	  		OPERATION 2 ACCESS 0 	//"Efetivar Rlz"	 
ADD OPTION aRotina TITLE STR0094		ACTION 'AF490ESEF'    	  		OPERATION 2 ACCESS 0 	//'Estorno Efet.Rlz.'
ADD OPTION aRotina TITLE STR0075		ACTION 'AFA490BLQ' 		  		OPERATION 20 ACCESS 0 	//'Bloqueio/Desbloq'	
ADD OPTION aRotina TITLE STR0011   	ACTION 'MSDOCUMENT'   	 		OPERATION 4 ACCESS 0 	//"Conhecimento"		

Return aRotina



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotinas de configuração do MVC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MODELDEF ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que define o modelo do cadastro de controle de      ³±±
±±³          ³ provisão para o MVC                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA490                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modeldef()

Local oStruFNU 	:= AF490Struct('FNU')
Local oStruFNV 	:= AF490Struct('FNV')
Local oStruFNX 	:= AF490Struct('FNX')
Local oModel		:= Nil
Local aRelacFNV	:= {}
Local aRelacFNX	:= {}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'ATFA490', /*bPreValidacao*/, { |oModel| AF490POSVL(oModel) },  { |oModel| AF490GRVMD( oModel ) }, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FNUMASTER', /*cOwner*/, oStruFNU )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'FNVDETAIL'	, 'FNUMASTER'	, oStruFNV, /*bLinePre*/, { |oModelGrid,cAction| FNVLINPOS(oModelGrid) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'FNXDETAIL'	, 'FNUMASTER'	, oStruFNX, { |oModelGrid,  nLine, cAction,cField| FNXLINPRE(oModelGrid,cAction) }, { |oModelGrid,cAction| FNXLINPOS(oModelGrid) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Não permite inserir linhas na grid
If __nOper == OPER_BLOQUEAR .Or. __nOper == OPER_REALIZAR .or. __nOper == OPER_EFETREAL  .or. __nOper == OPER_COPIAR
	oModel:GetModel( 'FNVDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FNVDETAIL' ):SetNoDeleteLine( .T. )
EndIf

//Caso nao seja a acao de realizar, nao sera possivel manipular dados na grid FNX
If __nOper != OPER_REALIZAR
	oModel:GetModel( 'FNXDETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FNXDETAIL' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'FNXDETAIL' ):SetNoUpdateLine( .T. )
Endif

//Relacionamento da tabela Item da Provisao
aAdd(aRelacFNV,{ 'FNV_FILIAL'	, 'xFilial( "FNV" )'	})
aAdd(aRelacFNV,{ 'FNV_COD'		, 'FNU_COD'		 		})
aAdd(aRelacFNV,{ 'FNV_REV'		, 'FNU_REV' 			})

//Relacionamento da tabela do Controle de Provisão com Itens de Execucao
aAdd(aRelacFNX,{ 'FNX_FILIAL'	, 'xFilial( "FNX" )'})
aAdd(aRelacFNX,{ 'FNX_COD'		, 'FNU_COD' 		})
aAdd(aRelacFNX,{ 'FNX_REV'		, 'FNU_REV' 		})


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'FNVDETAIL', aRelacFNV , FNV->( IndexKey( 1 ) )  )
If __nOper != OPER_COPIAR
	oModel:SetRelation( 'FNXDETAIL', aRelacFNX , FNX->( IndexKey( 1 ) )  )
Endif

//Deixa o prrenchimento das tabelas opcional
oModel:GetModel( 'FNVDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'FNXDETAIL' ):SetOptional( .T. )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'FNVDETAIL' ):SetUniqueLine( { 'FNV_ITEM','FNV_DTFIN' } )
oModel:GetModel( 'FNXDETAIL' ):SetUniqueLine( { 'FNX_CBASE','FNX_ITEM','FNX_TIPO','FNX_TPSALD' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0012 )  //'Controle de Provisão'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FNUMASTER' ):SetDescription( STR0012 ) //'Controle de Provisão'
oModel:GetModel( 'FNVDETAIL' ):SetDescription( STR0013 ) //'Itens do Controle de Provisão'
oModel:GetModel( 'FNXDETAIL' ):SetDescription( STR0014 )  //'Ativos de Execução'

oModel:AddCalc( 'FNUCALC1', 'FNUMASTER', 'FNVDETAIL', 'FNV_VLRBRT', 'FNU__TOTBRT', 'SUM',,,STR0015 ) //'Total Bruto'
oModel:AddCalc( 'FNUCALC1', 'FNUMASTER', 'FNVDETAIL', 'FNV_VLRPRE', 'FNU__TOTPRE', 'SUM',,,STR0016 ) //'Total Presente'

oModel:GetModel( 'FNVDETAIL' ):SetUniqueLine( { 'FNV_DTFIN' } )

oModel:SetVldActivate( {|oModel| AF490VLMod(oModel) } )

Return oModel

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Viewdef  ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função que define a interface do cadastro de controle de   ³±±
±±³          ³ provisão para o MVC                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA490                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Viewdef()
// Cria a estrutura a ser usada na View
Local oStruFNU := FWFormStruct( 2, 'FNU' )
Local oStruFNV := FWFormStruct( 2, 'FNV' )
Local oStruFNX := FWFormStruct( 2, 'FNX' )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'ATFA490' )
Local oView		:= Nil

// Remove campos da estrutura para nao aparecer na grid

oStruFNU:RemoveField( 'FNU_STATUS' )
oStruFNU:RemoveField( 'FNU_VLRBRT' )
oStruFNU:RemoveField( 'FNU_VLRPRE' )

oStruFNV:RemoveField( 'FNV_FILIAL')
oStruFNV:RemoveField( 'FNV_COD' )
oStruFNV:RemoveField( 'FNV_REV' )

oStruFNX:RemoveField( 'FNX_FILIAL' )
oStruFNX:RemoveField( 'FNX_COD' )
oStruFNX:RemoveField( 'FNX_REV' )

// Cria o objeto de View
oView := FWFormView():New()

// Cria o objeto de Estrutura
oCalc1 := FWCalcStruct( oModel:GetModel('FNUCALC1') )
//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddField( 'VIEW_CALC', oCalc1, 'FNUCALC1' )


// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FNU', oStruFNU, 'FNUMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FNV', oStruFNV, 'FNVDETAIL' )
oView:AddGrid(  'VIEW_FNX', oStruFNX, 'FNXDETAIL' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_FNV', 'FNV_ITEM' 	)
oView:AddIncrementField( 'VIEW_FNX', 'FNX_LINHA' 	)

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 37 )
oView:CreateHorizontalBox( 'INFERIOR' , 48 )
oView:CreateHorizontalBox( 'TOTALIZA' , 15 )

// Cria Folder na view
oView:CreateFolder( 'PASTA_SUPERIOR' ,'SUPERIOR' )
oView:CreateFolder( 'PASTA_INFERIOR','INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'PASTA_SUPERIOR'    , 'ABA_PROVISAO'  , STR0017 ) //'Provisão'
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_ITENS'     , STR0018 ) //'Itens de Provisão'
oView:AddSheet( 'PASTA_INFERIOR'    , 'ABA_REALIZAR'  , STR0014 ) //'Ativos de Execução'


// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PROVISAO'   , 100,,, 'PASTA_SUPERIOR', 'ABA_PROVISAO' )
oView:CreateHorizontalBox( 'ITENS' 		,100,,, 'PASTA_INFERIOR', 'ABA_ITENS' )
oView:CreateHorizontalBox( 'ATF_RLZ'    ,100,,, 'PASTA_INFERIOR', 'ABA_REALIZAR' )

// Criar "box" vertical para receber algum elemento da view
oView:CreateVerticalBox( 'TOTAL'		  , 100,'TOTALIZA')

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FNU', 'PROVISAO'   )
oView:SetOwnerView( 'VIEW_CALC', 'TOTAL' )
oView:SetOwnerView( 'VIEW_FNV', 'ITENS'     )
oView:SetOwnerView( 'VIEW_FNX', 'ATF_RLZ'   )


// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_CALC',  STR0142 ) //"Totais"

//Setar o folder 
oView:SetAfterViewActivate({|oView| F490SelFolder(oView)})

If  __lBTNConfirma 
	oView:AddUserButton( STR0141, 'OK', {|oView| A490CancVs(oView) } )	//"Cancelar"
EndIf

Return oView


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A490ConfVsºAutor  ³Mauricio Pequim Jr. º Data ³  27/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Botão de confirmar para operações de revisao,encerramento  º±±
±±º          ³ e atualizar                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A490ConfVs()
Local cMensagem := ""
Local lRet		:= .F.

If __nOper == OPER_REVISAR
	cMensagem := STR0020 //"Deseja gravar a operação, bloqueando a revisão anterior ? "
ElseIf __nOper == OPER_ATUALIZAR
	cMensagem := STR0021 //"Deseja atualizar o controle de provisão, gerando as informações de planilha da provisão ? "
ElseIf __nOper == OPER_EFETREAL
	cMensagem := STR0022 //"Deseja efetivar a baixa de provisão realizada para esse controle de provisão?"
ElseIf __nOper == OPER_CONTABIL
	cMensagem := STR0095 //"Deseja executar a contabilização dos movimentos do controle de provisão ? "
ElseIf __nOper == OPER_EST_CTBL
	cMensagem := STR0096 //"Deseja executar o estorno da contabilização dos movimentos do controle de provisão ? "
ElseIf __nOper == OPER_EST_EFET
	cMensagem := STR0097 //"Deseja executar o estorno das efetivações de realização do controle de provisão ? "
EndIf

If MsgNoYes(cMensagem)
	__lConfirmar := .T.
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490POSVLºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pós validação do modelo de dados                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490POSVL(oModel)
Local lRet 			:= .T.
Local nOperation 	:= oModel:GetOperation()
Local aSaveLines 	:= FWSaveRows()
Local oView	 		:= FWViewActive()

If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT
	If lRet
		lRet := AF490VDTI(oModel)
	EndIf
	
	If lRet
		aCargaFNX := {}
		lRet := A490VldTLin(oModel)
	EndIf
	
	If lRet
		A490AjtLin(@oModel)
	EndIf
	
ElseIf nOperation == MODEL_OPERATION_DELETE
	If oView != Nil
		lRet := MsgNoYes(STR0023) //"Deseja excluir o controle de provisão?"
		Help( , ,"AF490EXC",, STR0116, 1, 0 )//"Operação Cancelada"	
	EndIf
EndIf

FWRestRows(aSaveLines)

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490VDTI  ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 08/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se a data inicial da provisao é menor que a data do ³±±
±±³          ³ período final de cada item da provisao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF490VDTI(oModel)
Local oModelFNV	:= Nil
Local dDataIni		:= Nil
Local dDataFim	  	:= Ctod( '' )
Local aSaveLines  := {}
Local lRet         := .T.
Local nX           := 0
Local dDataProj   := Ctod( '' )
Local dDataAvp    := Ctod( '' )

Default oModel := FWModelActive()

oModelFNV		:= oModel:GetModel("FNVDETAIL")
dDataIni		:= oModel:GetValue("FNUMASTER","FNU_DTINI")
aSaveLines		:= FWSaveRows()


If !Empty(dDataIni) .and. dDataIni != FirstDay(dDataIni)
	Help( , ,"AF490VDTINI",, STR0077, 1, 0 )	//"Data de reconhecimento da provisão deve ser igual ao primeiro dia do mês"
	lRet := .F.
Endif

dDataProj := oModel:GetValue("FNUMASTER","FNU_INIPRJ")

If lRet .And. !Empty(dDataProj) .and. (dDataProj != FirstDay(dDataProj))
	Help("  ",1,"AF490FNVDT2",,STR0133,1,0)	//"A data de início de projeto deve ser igual ao último dia do periodo."
	lRet := .F.
EndIf

If lRet .and. !Empty(dDataIni) .and. !Empty(dDataProj) .and. dDataIni < dDataProj
	Help( , ,"AF490VDTPROJ",, STR0132, 1, 0 ) //"Data de Inicio de Projeto deve ser menor ou igual a data de reconhecimento"
	lRet := .F.
EndIf

dDataAvp := oModel:GetValue("FNUMASTER","FNU_DTAVP")

If lRet .and. !Empty(dDataIni) .and. !Empty(dDataAvp) .and. dDataIni < dDataAvp
	Help( , ,"AF490VDTAVP",, STR0134, 1, 0 ) //"Data de Referencia AVP deve ser menor ou igual a data de reconhecimento"
	lRet := .F.
EndIf

For nX := 1 to oModelFNV:Length()
	oModelFNV:GoLine(nX)
	
	If !oModelFNV:IsDeleted()
	
		dDataFim := oModelFNV:GetValue("FNV_DTFIN")
		
		If lRet .And. !Empty(dDataFim) .and. (dDataFim != LastDay(dDataFim))
			Help("  ",1,"AF490FNVDT",,STR0078,1,0)	//"A data final da previsao de realizacao deve ser igual ao último dia do periodo."
			lRet := .F.
			Exit
		EndIf
		
		If lRet .and. !Empty(dDataIni) .and. !Empty(dDataFim) .and. dDataIni >= dDataFim
			Help( , ,"AF490VDTFIM",, STR0024, 1, 0 ) //"Data final do item deve ser maior que a data de reconhecimento do controle de provisão"
			lRet := .F.
			Exit
		EndIf
		
	EndIf
Next nX


FWRestRows(aSaveLines)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A490VldTLinºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza todas as pos-validações de linha do modelo na      º±±
±±º          ³  pós validação da rotina                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A490VldTLin(oModel)
Local lRet		        := .T.
Local oModelFNX		:= oModel:GetModel("FNXDETAIL")
Local oModelFNV		:= oModel:GetModel("FNVDETAIL")
Local aSaveLines 	    := FWSaveRows()
Local nX			    := 0

If lRet .and. __nOper == OPER_REALIZAR
	For nX := 1 To oModelFNX:Length()
		oModelFNX:GoLine( nX )
		If !oModelFNX:IsDeleted()
			lRet := FNXLINPOS(oModelFNX)
		EndIf
		If !lRet
			Exit
		EndIf
	Next nX
ElseIf lRet .and. __nOper == 0
	For nX := 1 To oModelFNV:Length()
		oModelFNV:GoLine( nX )
		If !oModelFNV:IsDeleted()
			lRet := FNVLINPOS(oModelFNV)
		EndIf
		If !lRet
			Exit
		EndIf
	Next nX
Endif

FWRestRows(aSaveLines)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A490AjtLinºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o ajuste na numeração das linhas , caso alguma      º±±
±±º          ³linha seja excluída  		                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A490AjtLin(oModel)
Local oModelFNV		:= oModel:GetModel("FNVDETAIL")
Local oModelFNX		:= oModel:GetModel("FNXDETAIL")
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local cContFNV		:= ""
Local cContFNX		:= ""

cContFNV := StrZero(0,TamSx3('FNV_ITEM')[1] )
For nX := 1 To oModelFNV:Length()
	oModelFNV:GoLine( nX )
	If !oModelFNV:IsDeleted()
		cContFNV := Soma1(cContFNV)
		oModelFNV:LoadValue( 'FNV_ITEM' , cContFNV )
	EndIf
Next nX
	
If __nOper == OPER_REALIZAR
	cContFNX := StrZero(0,TamSx3('FNX_LINHA')[1] )
	For nX := 1 To oModelFNX:Length()
		oModelFNX:GoLine( nX )
		If !oModelFNX:IsDeleted()
			cContFNX := Soma1(cContFNX)
			oModelFNX:LoadValue( 'FNX_LINHA' , cContFNX )
		EndIf
	Next nX
Endif

FWRestRows(aSaveLines)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490GRVMDºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a gravação do modelo de dados                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490GRVMD( oModel )

Local cCod	 := oModel:GetValue("FNUMASTER","FNU_COD")
Local cRev	 := oModel:GetValue("FNUMASTER","FNU_REV")
Local nVlrBrt := oModel:GetValue("FNUCALC1","FNU__TOTBRT")
Local nVlrPre := oModel:GetValue("FNUCALC1","FNU__TOTPRE")
Local nOperation := oModel:GetOperation()
Local lRealizacao:= .F.

//Realiza a gravação do Modelo
FWFormCommit( oModel )

If (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT)
	AF490GrvVl(cCod,cRev,nVlrBrt,nVlrPre)
ElseIf nOperation == MODEL_OPERATION_DELETE
	AF490DelFnw(cCod,cRev)	
Endif

If __nOper == OPER_REVISAR .Or. (__nOper == 0 .And. (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT) )
	//Altera o Status para Gerado
	AF490FLAG(cCod,cRev,"0")
ElseIf  __nOper == OPER_COPIAR
	//Altera o Status para Gerado
	FNV->(dbSetOrder(1)) //FNX_FILIAL+FNX_COD+FNX_REV+DTOS(FNX_DTMOV)
	FNV->(MsSeek(xFilial("FNV") +  cCod + cRev ))
	While FNV->(!EOF()) .And. FNV->(FNV_FILIAL+FNV_COD+FNV_REV) == xFilial("FNV") +  cCod + cRev
		Reclock("FNV",.F.)
		FNV->FNV_RLZEFT := '2'    	
		FNV->(MsUnLock())
		FNV->(dbSkip())
	EndDo

	AF490FLAG(cCod,cRev,"0")
ElseIf __nOper == OPER_REALIZAR
	//Altera o Status para Gerado
	FNX->(dbSetOrder(1)) //FNX_FILIAL+FNX_COD+FNX_REV+DTOS(FNX_DTMOV)
	FNX->(dbSeek(xFilial("FNX") +  cCod + cRev ))
	While FNX->(!EOF()) .And. FNX->(FNX_FILIAL+FNX_COD+FNX_REV) == xFilial("FNX") +  cCod + cRev
		If Empty(FNX->FNX_DTCONT) .and. !lRealizacao
			lRealizacao := .T.
			Exit
		EndIf
		FNX->(dbSkip())
	EndDo
	If lRealizacao
		cFlag := "A"
	Else	
		aRegs := AF490Dados(3,cCod,cRev)
		If Len(aRegs) > 0
			cFlag := "2"
		Else			
			cFlag := "1"
		Endif
	EndIf
	AF490FLAG(cCod,cRev,cFlag)
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490VLModºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a validação do modelo de dados do MVC              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490VLMod(oModel)

Local nOperation := oModel:GetOperation()
Local lRet := .T.

If lRet .And. (nOperation == MODEL_OPERATION_UPDATE )
	If FNU->FNU_MSBLQL == "1" .and. __nOper != OPER_BLOQUEAR
		Help("  ",1,"AF490BLQB",,STR0101 ,1,0)   //"O controle de provisão encontra-se bloqueado. Portanto não será possível realizar a ação desejada."
		lRet := .F.
	ElseIf FNU->FNU_STATUS == "3" .AND. __nOper == 0
		Help(" ",1,"AF490STALTPR",,STR0119 ,1,0) //"O status deste controle de provisao não permite a realização deste processo."
		lRet := .F.
	ElseIf FNU->FNU_STATUS == "A" .AND. __nOper == 0
		Help(" ",1,"AF490STALTPR",,STR0119 + CRLF + STR0126 ,1,0) //"O status deste controle de provisao não permite a realização deste processo."###"Efetive a realização e após utilize a opção de bloqueio ou revisão"
		lRet := .F.
	ElseIf !(FNU->FNU_STATUS $ "0*1") .AND. __nOper == 0
		Help(" ",1,"AF490STAALT",,STR0025 ,1,0) //"Este controle de provisão já está ativo. Para alterar o controle de provisão, por favor utilizar a opção de revisão"
		lRet := .F.
	Endif
EndIf

If lRet .And. (nOperation == MODEL_OPERATION_DELETE )
	If FNU->FNU_MSBLQL == "1" .and. __nOper != OPER_BLOQUEAR
		Help("  ",1,"AF490BLQC",,STR0101 ,1,0)   //"O controle de provisão encontra-se bloqueado. Portanto não será possível realizar a ação desejada."
		lRet := .F.
	ElseIf FNU->FNU_STATUS == "A"
		Help(" ",1,"AF490STDELPR",,STR0119 + CRLF + STR0126 ,1,0) //"O status deste controle de provisao não permite a realização deste processo."###"Efetive a realização e após utilize a opção de bloqueio ou revisão"
		lRet := .F.
	ElseIf FNU->FNU_STATUS != "0"
		Help(" ",1,"AF490STADEL",,STR0026 ,1,0) //"Este controle de provisão já está ativo. Por favor, utilize a opção de bloqueio ou revisão"
		lRet := .F.
	ElseIf FNU->FNU_REV > "0001"
		Help(" ",1,"AF490STADELREV",,STR0117 ,1,0) //"Este controle de provisão tem revisão anterior e não poderá ser excluido"
		lRet := .F.
	Endif	
EndIf

If lRet .and. __nOper > 0 .and. __nOper != OPER_BLOQUEAR .and. FNU->FNU_MSBLQL == "1"  //REGISTRO BLOQUEADO
	Help("  ",1,"AF490BLQD",,STR0101 ,1,0)   //"O controle de provisão encontra-se bloqueado. Portanto não será possível realizar a ação desejada."
	lRet := .F.
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490StructºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a estrutura do modelo com o tratamento das         º±±
±±º          ³ operações                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490Struct(cAlias)
Local oStruct 	:= FWFormStruct( 1, cAlias, /*bAvalCampo*/, /*lViewUsado*/ )
Local aFields	:= {}
Local nX		:= 0
Local cPrefix	:= PrefixoCpo(cAlias)
Local cCampoBlq := cPrefix+'_MSBLQL'

If __nOper == OPER_BLOQUEAR
	// Bloqueia todos os campos menos do bloqueio
	oStruct:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
	If  (cAlias)->(FieldPos(cCampoBlq)) > 0
		oStruct:SetProperty(cCampoBlq , MODEL_FIELD_WHEN , {|| .T. } )
	EndIf
ElseIf __nOper == OPER_REVISAR
	If cAlias == "FNU"
		oStruct:SetProperty("FNU_COD" , MODEL_FIELD_WHEN , {|| .F. } )
		oStruct:SetProperty("FNU_REV"  , MODEL_FIELD_WHEN , {|| .F. } )
	EndIf
ElseIf __nOper == OPER_REALIZAR  

	oStruct:SetProperty('*' , MODEL_FIELD_WHEN , {|| .F. } )

	If cAlias == "FNX"	
		oStruct:SetProperty('FNX_DTMOV'  , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty('FNX_CBASE'  , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty('FNX_ITEM'   , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty('FNX_TIPO'   , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty('FNX_TPSALD' , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty('FNX_VALOR'  , MODEL_FIELD_WHEN , {|| .T. } )
	Endif
ElseIf __nOper == OPER_COPIAR
	// Bloqueia todos os campos menos do bloqueio
	oStruct:SetProperty( '*' , MODEL_FIELD_WHEN , {|| .F. } )
	If cAlias == "FNU"
		oStruct:SetProperty("FNU_COD"   , MODEL_FIELD_WHEN , {|| .T. } )
		oStruct:SetProperty("FNU_DESCR" , MODEL_FIELD_WHEN , {|| .T. } )
	Endif					
EndIf


//Criação de Gatilho
// [01] Id do campo de origem
// [02] Id do campo de destino
// [03] Bloco de codigo de validação da execução do gatilho
// [04] Bloco de codigo de execução do gatilho

If cAlias == "FNU"

	oStruct:AddTrigger( "FNU_DTAVP"  	, "FNU_DTAVP"	  	, {|| .T. }  , {|| AF490CBAVP() }  )
	oStruct:AddTrigger( "FNU_DTINI"  	, "FNU_DTAVP"	  	, {|| .T. }  ,  {|| AF490TData("FNU_DTAVP") }  ) 

	oStruct:AddTrigger( "FNU_DTINI"  	, "FNU_INIPRJ"	  	, {|| .T. }  ,  {|| AF490TData("FNU_INIPRJ") }  ) //IIF(Empty(M->FNU_INIPRJ),M->FNU_DTINI,M->FNU_INIPRJ)

	oStruct:AddTrigger( "FNU_INDAVP"  	, "FNU_INDAVP"  	, {|| .T. }  , {|| AF490CBAVP() }  )
	oStruct:AddTrigger( "FNU_TPCALC"  	, "FNU_TPCALC"  	, {|| .T. }  , {|| AF490GTTP() }  )
	

ElseIf cAlias == "FNV"
	oStruct:AddTrigger( "FNV_DTFIN"  	, "FNV_VLRPRE"	  	, {|| .T. }  , {|| AF490ATVP() }  )
	oStruct:AddTrigger( "FNV_VLRBRT"  	, "FNV_VLRPRE"   	, {|| .T. }  , {|| AF490ATVP()  }  )

ElseIf cAlias == "FNX"
	oStruct:AddTrigger( "FNX_CBASE"    , "FNX_CBASE"		, {|| .T. }  , {|| AF490GSldE("FNX_CBASE"	)  }  )
	oStruct:AddTrigger( "FNX_ITEM"     , "FNX_ITEM"		, {|| .T. }  , {|| AF490GSldE("FNX_ITEM"	)  }  )
EndIf

Return oStruct


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490ATVP ºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza os valores do AVP planejado dos itens             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490ATVP()

Local oModel   		:= FWModelActive()
Local oModelFNU		:= oModel:GetModel("FNUMASTER")
Local oModelFNV		:= oModel:GetModel("FNVDETAIL")
Local nOperation 	    := oModel:GetOperation()
Local cCodInd         := ""
Local nValItem		    := oModelFNV:GetValue('FNV_VLRBRT')
Local nValVP		    := 0
Local nValAVP		    := 0
Local dDataIni		    := Ctod("//")
Local dPrevista		:= Ctod("//")  
Local nDecimais		:= TamSx3("FNV_VLRPRE")[2]


If (nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT) .and. nValItem > 0
	//Carrega tabela FNV
	If !oModelFNV:IsDeleted()
		cCodInd	:= oModelFNU:GetValue('FNU_INDAVP')
		nTaxaAvp	:= oModelFNU:GetValue('FNU_TAXAVP')
		dDataIni	:= oModelFNU:GetValue('FNU_DTAVP')
		dPrevista	:= oModelFNV:GetValue('FNV_DTFIN')
			
		IF !Empty(dPrevista)
		nValAVP := 0
		AFCalcAVP("C",nTaxaAvp,cCodInd,nValItem,,dDataIni,@nValVP,@nValAVP,dPrevista,.T.)
		nValVp := Round(NoRound(nValVP,nDecimais + 1),nDecimais)
		Else
			Help("  ",1,"AF490ATVP1",,STR0130,1,0)   //"Data final do periodo não preenchida. Esta data é necessária para o calculo do valor presente da provisão."
		Endif
		
	EndIf
EndIf

Return nValVP


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490GTTP ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 08/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho para atualização dos campos de taxa linear ou indice³±±
±±³          ³ quando alterado o conteudo do campo tipo de calculo         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF490GTTP()

Local oModel	:= FWModelActive()
Local cTipo		:= oModel:GetValue("FNUMASTER","FNU_TPCALC")
Local aArea		:= GetArea()
Local nOperation := oModel:GetOperation()

If (nOperation == MODEL_OPERATION_UPDATE  .AND. __nOper == 0) .or. __nOper == OPER_REVISAR

	If cTipo == "1"  //Taxa Linear
		oModel:LoadValue("FNUMASTER","FNU_INDICE", "")			
	Else			//Valor Fixo
		oModel:LoadValue("FNUMASTER","FNU_TAXALN", 0 )	
	Endif

EndIf

RestArea(aArea)


Return cTipo

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490TData ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 29/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho para atualização de datas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF490TData(cCampo)

Local oModel	    := FWModelActive()
Local dDataIni		:= oModel:GetValue("FNUMASTER","FNU_DTINI")
Local dDataGat    := oModel:GetValue("FNUMASTER",cCampo) 

If __nOper == 0 .or. __nOper == OPER_REVISAR
    dDataGat := IIF(Empty(dDataGat),dDataIni,dDataGat)
EndIf

Return dDataGat

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490CBAVP ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho para atualizacao do campo FNU_TAXAVP				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490CBAVP()

Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelFNU	:= oModel:GetModel("FNUMASTER")
Local oModelFNV	:= oModel:GetModel("FNVDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nX			:= 0
Local cIndAvp		:= oModelFNU:GetValue("FNU_INDAVP")
Local dDtIni		:= CTOD("")
Local nAVP			:= 0
Local oView		:= FWViewActive()

dDtIni		:= oModelFNU:GetValue("FNU_DTAVP")
	
//Atualizo indice para calculo do AVP
//Pego Indice - Ultimo valor
nTaxa	 := AtfRetInd(cIndAvp,dDtIni )

//Atualiza a taxa em tela
lRet := oModelFNU:LoadValue( "FNU_TAXAVP" , nTaxa )

//Atualiza calculos de AVP previstos apos mudanca da taxa
If lRet .AND. nTaxa > 0.00 
	For nX := 1 To oModelFNV:Length()
		oModelFNV:GoLine( nX )
		nAVP := AF490ATVP()
		oModelFNV:SetValue( "FNV_VLRPRE" , nAVP )
	Next
Endif

FWRestRows(aSaveLines)

If oView != Nil .AND. nAvp > 0.00
	oView:Refresh()
EndIf

Return 



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490GSldE ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 09/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho para atualização dos campos da grid do FNX		  ³±±
±±³          ³ com base nas informações do SN3  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490GSldE(cCampo)

Local oModel	:= FWModelActive()
Local oModelFNX	:= oModel:GetModel("FNXDETAIL")
Local cRet       := oModelFNX:GetValue(cCampo)
Local cBase		:= oModelFNX:GetValue("FNX_CBASE")
Local cItem		:= oModelFNX:GetValue("FNX_ITEM")
Local cTipo		:= oModelFNX:GetValue("FNX_TIPO")
Local cTpSld     := oModel:GetValue("FNUMASTER","FNU_TPSALD")
Local aArea 	:= GetArea()


cTipo := IIF(Empty(cTipo),"10",cTipo)

SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
If SN3->(MsSeek( xFilial("SN3") + cBase + cItem + cTipo + "0" + cTpSld ))
	lRet := oModelFNX:SetValue( 'FNX_TIPO' , cTipo )
	lRet := oModelFNX:SetValue( 'FNX_TPSALD' , cTpSld )
	lRet := oModelFNX:SetValue( 'FNX_VALOR' , SN3->N3_VORIG1 )
	oModelFNX:LOADVALUE( 'FNX_FILATF' , xFilial("SN3") )
EndIf


RestArea(aArea)

Return cRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA490CPY ºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a cópia do controle de provisão                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490CPY(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cCodPrv       := FNU->FNU_COD
Local cRev          := FNU->FNU_REV
Local lRet          := .T.


If FNU->FNU_MSBLQL == "1"  //REGISTRO BLOQUEADO
	Help("  ",1,"AF490CPYBLQ",,STR0101 ,1,0)   //"O controle de provisão encontra-se bloqueado. Portanto não será possível realizar a ação desejada."
	lRet := .F.
Endif

If lRet .and. FNU->(MsSeek(xFilial("FNU") + cCodPrv + cRev))
	__nOper      := OPER_COPIAR
	cTitulo      := STR0072 //'Copiar'
	cPrograma    := 'ATFA490'
	nOperation   := MODEL_OPERATION_INSERT
	
	oModel       := FWLoadModel( cPrograma )
	oModel:SetOperation( nOperation ) // Inclusão
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	oModel:SetValue("FNUMASTER","FNU_COD","")  
	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	oModel:DeActivate()
	__nOper      := 0
	
EndIf

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA490BLQ ºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza o bloqueio/Desbloqueio do controle de provisao     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490BLQ(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local lRet          := .T.

If !(FNU->FNU_STATUS $ '0/1/2' )
	Help(" ",1,"AF490BLOQ",,STR0029,1,0)  //"Não é possivel bloquear/desbloquear controle de provisão com esse status"
	lRet := .F.
EndIf


If lRet
	__nOper      := OPER_BLOQUEAR
	cTitulo      := STR0125 //'Bloqueio/Desbloqueio'
	cPrograma    := 'ATFA490'
	nOperation   := MODEL_OPERATION_UPDATE
	bOk          := {|| lRet := MsgNoYes(STR0030) } // //"Deseja Realizar o bloqueio/desbloqueio do controle de provisão ? "
	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	__nOper      := 0
EndIf

RestArea(aArea)
Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA490REA ºAutor  ³Mauricio Pequim Jr  º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza amarração Controle de Provisao x Bens Execução     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490REA(cAlias,nReg,nOpc)
Local aArea         := GetArea()
Local lConfirma     := .F.
Local lCancela      := .F.
Local cTitulo       := ""
Local cPrograma     := ""
Local nOperation    := 0
Local cCodPrv       := FNU->FNU_COD
Local cRev          := FNU->FNU_REV
Local lRet          := .T.
Local cStatus		:= ""

If !(FNU->FNU_STATUS $ "1/2/A")
	Help("  ",1,"AFR490RLZ",,STR0043 ,1,0)  //"Apenas controles de provisão ativos poderão receber informações de realização."
	lRet := .F.
Endif

If lRet
	__nOper      := OPER_REALIZAR
	cTitulo      := STR0009 //"Realizar"
	cPrograma    := 'ATFA490'
	nOperation   := MODEL_OPERATION_UPDATE
	bOk          := {|| .T. } 
	nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
	__nOper      := 0
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FNXLINPRE ºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pré validação de linha da grid FNXDetail                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FNXLINPRE(oModelFNX, cAction)
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local nVlrFNX	:= oModel:GetValue("FNXDETAIL","FNX_VALOR")
Local dDtRlz	:= oModel:GetValue("FNXDETAIL","FNX_DTCONT")

Local aSaveLines:= FWSaveRows()

//Registro com realizacao efetivada
If nVlrFNX > 0 .and. !Empty(dDtRlz)
	Help("  ",1,"AFR490EX1",,STR0044 ,1,0)  //"Este registro ja teve sua realização efetivada e não pode sofrer manutenções"
	lRet := .F.
Endif

FWRestRows(aSaveLines)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FNXLINPOS ºAutor  ³Mauricio Pequim Jr  º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pós validação de linha da entidade FNXDETAIL - Bens de     º±±
±±º          ³ execucao                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FNXLINPOS(oModelFNX)

Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local lLinAtiva	:= !oModelFNX:IsDeleted()
Local aSaveLines	:= FWSaveRows()
Local dDtMov		:= oModelFNX:GetValue("FNX_DTMOV")
Local cDtMov		:= Dtos(dDtMov)
Local cBase		:= oModelFNX:GetValue("FNX_CBASE")
Local cItem		:= oModelFNX:GetValue("FNX_ITEM")
Local cTipo		:= oModelFNX:GetValue("FNX_TIPO")
Local cTpSld		:= oModelFNX:GetValue("FNX_TPSALD")
Local dTpSldPrv	:= oModel:GetValue("FNUMASTER","FNU_TPSALD")
Local l490Rlz		:= ISINCALLSTACK('AFA490REA')


//Verifica campos nao preenchidos na FNX
If lRet .And. lLinAtiva .and. !Empty(cDtMov+cBase+cItem+cTipo+cTpSld) .and. ;
		(Empty(cDtMov) .or. Empty(cBase) .or. Empty(cItem) .or. Empty(cTipo) .or. Empty(cTpSld))
	Help("  ",1,"AF490POS1",,STR0045 ,1,0)  //"Verifique o preenchimento dos dados do bem a ser relacionado ao controle de provisão para realização"
	lRet := .F.
EndIf

//Verifica campos nao preenchidos na FNX
If lRet .And. lLinAtiva .and. !Empty(cTpSld) .and. (cTpSld != dTpSldPrv)
	Help("  ",1,"AF490POS2",,STR0046 ,1,0)  //"Verifique o tipo de saldo do informado. O tipo de saldo deve ser o mesmo do cadastro de provisão."
	lRet := .F.
EndIf

//Caso a linha nao tenha dados do bem de execucao, 
//deleto a mesma para nao gravar registro em branco na FNX
If lRet .And. lLinAtiva .and. Empty(cBase+cItem+cTipo+cTpSld) .and. l490Rlz
	lRet := oModelFNX:DeleteLine(.T.)	
Endif

FWRestRows(aSaveLines)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FNVLINPOS ºAutor  ³Alvaro Camillo Neto º Data ³  12/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pós validação de linha da entidade FNVDETAIL - Planejamento     º±±
±±º          ³ de previsão                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FNVLINPOS(oModelFNV)

Local lRet		    := .T.
Local oModel	    := FWModelActive()
Local lLinAtiva	:= !oModelFNV:IsDeleted()
Local aSaveLines  := FWSaveRows()
Local nMax         := Val("9" +  Replicate( "0", 10 ) ) // numeto maximo para previnir estouro de valores
Local nVlrBrt := oModel:GetValue("FNUCALC1","FNU__TOTBRT")
Local nVlrPre := oModel:GetValue("FNUCALC1","FNU__TOTPRE")


//Verifica valor presente da linha
If lRet .And. lLinAtiva .And. oModelFNV:GetValue("FNV_VLRPRE") <= 0 
	Help("  ",1,"AF490POSV1",,STR0136 ,1,0)//"Valor presente inválido. Por favor verificar taxa,valor bruto ou datas para o calculo do valor."
	lRet := .F.
EndIf

If lRet .And. lLinAtiva .And. ( nVlrPre > nMax .Or. nVlrBrt > nMax )
	Help("  ",1,"AF490POSV3",,STR0135,1,0)//"Valor inválido. Por favor verificar o cadastro do Controle de Provisão" 
	lRet := .F.
EndIf


FWRestRows(aSaveLines)

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490VLBEX ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Função para validar campo em função do método de depreciação³±± 
±±³          ³ definido.											  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490VLBEX()
Local oModel   	:= FWModelActive()
Local oModelFNX	:= oModel:GetModel("FNXDETAIL")
Local lRet 		:= .T.
Local cBase		:= oModelFNX:GetValue("FNX_CBASE")
Local cItem		:= oModelFNX:GetValue("FNX_ITEM")
Local cTipo		:= oModelFNX:GetValue("FNX_TIPO")
Local cTpSld	:= oModelFNX:GetValue("FNX_TPSALD")
Local cTipSld	:= oModel:GetValue("FNUMASTER","FNU_TPSALD")

If !Empty(cBase) .and. !Empty(cItem) .and. !Empty(cTipo) .and. !Empty(cTpSld) .and. !Empty(cTipSld)
	
	SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
	If !(SN3->(MsSeek( xFilial("SN3") + cBase + cItem + cTipo + "0" + cTpSld )))
		Help( " ", 1, "AF490VLBEX1",, STR0048, 1, 0 )  //"Imobilizado não localizado"
		lRet := .F.
	ElseIF cTpSld != cTipSld
		Help( " ", 1, "AF490VLBEX2",, STR0049, 1, 0 )   //"Imobilizado deve possuir mesmo Tipo de Ativo e Tipo de Saldo do Item de Etapa"
		lRet := .F.
	Endif
Endif

Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490VLDTS ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Função para validar campo do tipo de saldo da provisão      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490VLDTS()

Local oModel   	:= FWModelActive()
Local oModelFNU	:= oModel:GetModel("FNUMASTER")
Local lRet 		:= .T.
Local cProvis	:= oModelFNU:GetValue("FNU_COD")
Local cRev		:= oModelFNU:GetValue("FNU_REV")
Local cTpSld	:= oModelFNU:GetValue("FNU_TPSALD")

//Valida tipo de saldo (SX5 - Tabela SL
If !VldTpSald( cTpSld,,, .T. )

	lRet := .F.

ElseIf !Empty(cProvis) .and. !Empty(cRev) .and. !Empty(cTpSld)

	FNX->(dbSetOrder(1)) //FNX_FILIAL+FNX_COD+FNX_REV
	If (FNX->(MsSeek( xFilial("FNX") + cProvis + cRev ))) .and. FNX->FNX_TPSALD != cTpSld
		Help( " ", 1, "AF490VLDTS",, STR0050, 1, 0 )  //"Tipo de saldo incompatível com os Imobilizados de execução relacionados ao controle de provisão"
		lRet := .F.
	Endif
Endif

Return lRet



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FNXSxbFil  ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Filtro de Consulta Padrao SN303							  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FNXSxbFilt()

Local oModel   	:= FWModelActive()
Local cProvis 	:= oModel:GetValue("FNUMASTER","FNU_COD")
Local cTpSld 	:= oModel:GetValue("FNUMASTER","FNU_TPSALD")
Local cTipo		:= "10"
Local cAliasQry	:= "SN3490"
Local cCadastro  := STR0051 //"Imobilizados de Execução"
Local aCampos    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aHeadSXB 		:= {} 
Local aColsSXB      := {}       
Local nOpcGet		:= 0									 			   	// GD_INSERT+GD_UPDATE+GD_DELETE					// Opção da MsNewGetDados
Local cLinhaOk     	:= "AllwaysTrue"  										// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"									   	// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			               			  		  		// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              								   	// Campos estaticos na GetDados.
Local aAlter      	:= {}                   		                   		// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"					 	  		        // Funcao executada na validacao do campo
Local cSuperDel     := "AllwaysTrue"          			  			 		// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        := "AllwaysTrue"    					 				// Funcao executada para validar a exclusao de uma linha do aCols
Local lRet 			:= .T.
Local nOpcA			:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para a MsAdvSize e MsObjSize³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lEnchBar   := .F. // Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao    := .F. // Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY	     := 400 // Altura mínima da janela
Local aSize	  	 := MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 	 := {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	 := {}
Local aPosObj	 := {}
Local aRecNo	 := {}
Local oDlg		 := Nil
Local oPanelGet	 := Nil
Local nX         := 0
Local bOK		 := {|| (AF490VldF3(aColsSXB,oGetSN3:nAt),oDlg:End())}
Local bCancel    := {|| oDlg:End() }
Local bVisual    := {|| AF490VBem(aColsSXB,oGetSN3:nAt)}
Local aSvKeys	 := GetKeys()

Private oGetSN3 	:= Nil

aDadosFNX	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definição das posições dos objetos na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do acols da get de modificadores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aCampos,"N3_CBASE")
aAdd(aCampos,"N3_ITEM")
aAdd(aCampos,"N3_TIPO")
aAdd(aCampos,"N3_TPSALDO")
aAdd(aCampos,"N3_VORIG1")
aAdd(aCampos,"N3_HISTOR")

SN3->(DbSetOrder(11))

cQuery := "SELECT N3_FILIAL,N3_CBASE, N3_ITEM, N3_TIPO, N3_TPSALDO, N3_HISTOR,N3_VORIG1, N1_PROVIS "
cQuery += "FROM " + RetSQLTab('SN3')
cQuery += "JOIN " + RetSQLTab('SN1')
cQuery += "  ON  SN3.N3_FILIAL  = SN1.N1_FILIAL AND "
cQuery += "      SN3.N3_CBASE   = SN1.N1_CBASE AND "
cQuery += "      SN3.N3_ITEM	= SN1.N1_ITEM "
cQuery += " WHERE "
cQuery +=   "N1_FILIAL  = '" +xFilial("SN1")+ "' AND "
cQuery +=   "N3_FILIAL  = '" +xFilial("SN3")+ "' AND "
cQuery += 	"N1_PROVIS  = '" +cProvis	    + "' AND "
cQuery += 	"N3_TIPO    = '" + cTipo	    + "' AND "
cQuery += 	"N3_TPSALDO = '" + cTpSld	    + "' AND "
cQuery += 	"N3_BAIXA	= '0' AND "                                   
cQuery +=   "SN1.D_E_L_E_T_ = ' ' AND "
cQuery +=   "SN3.D_E_L_E_T_ = ' ' AND "
cQuery += 	" NOT EXISTS ("
cQuery +=         "SELECT FNX_CBASE "
cQuery +=         "FROM "+RetSqlName("FNX")+" "
cQuery +=         "WHERE FNX_FILIAL = '"+xFilial("FNX")+"' AND "
cQuery +=				"FNX_CBASE = N3_CBASE AND "
cQuery +=				"FNX_ITEM  = N3_ITEM AND "
cQuery +=				"FNX_TIPO = N3_TIPO AND "
cQuery +=				"FNX_TPSALD = N3_TPSALDO AND "
cQuery +=				"D_E_L_E_T_ = ' ' )"

cQuery += "ORDER BY N3_FILIAL,N3_CBASE, N3_ITEM, N3_TIPO, N3_TPSALDO"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
dbSelectArea(cAliasQry)
DbGotop()

aHeadSXB := AF490CvHeader(aCampos) 
aColsSXB := AF490CvAcols(aHeadSXB, cAliasQry )

(cAliasQry)->(dbCloseArea())

oDlg := MSDIALOG():New(0,0,500,730,cCadastro,,,,,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura de Panels³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanelGet 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.T.,.T. )
oPanelGet:Align 	:= CONTROL_ALIGN_ALLCLIENT

oGetSN3	:= 	MsNewGetDados():New(0,0,100,100,nOpcGet,;
			cLinhaOk ,cTudoOk,cIniCpos,/*aAlter*/,nFreeze,999,cFieldOk,cSuperDel,cDelOk,oPanelGet,aHeadSXB,aColsSXB)
oGetSN3:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oButtonBar := FWButtonBar():new()
oButtonBar:Init(oDlg,015,015,CONTROL_ALIGN_BOTTOM,.T.,.F.)

oButtonBar:addBtnText( STR0052	, STR0052+" <Alt-X>" , bCancel,,,CONTROL_ALIGN_RIGHT, .T.) //"Fechar"###"Fechar"
SetKEY(K_ALT_X,{||Eval(bCancel)})

oButtonBar:addBtnText( STR0019	, STR0019+" <Alt-O>" , bOk,,,CONTROL_ALIGN_RIGHT) //"Confirmar"###"Confirmar"
SetKEY(K_ALT_O,{||Eval(bOk)})

oButtonBar:addBtnText( STR0053	, STR0053+" <Alt-V>" , bVisual,,,CONTROL_ALIGN_RIGHT) //"Visualizar"###"Visualizar"
SetKEY(K_ALT_V,{||Eval(bVisual)})

oDlg:lCentered	:= .T.
oDlg:Activate()

SetKEY(K_ALT_O, NIL)
SetKEY(K_ALT_X, NIL)
SetKEY(K_ALT_V, NIL)

RestKeys( aSvKeys , .T. )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490CvHeaderºAutor ³Mauricio Pequim Jr. º Data ³ 04/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria o Aheader da getdados                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490CvHeader(aCampos)
Local aArea	  		:= GetArea()
Local aAreaSX3	  	:= SX3->(GetArea())
Local aHeader 		:= {}
Local nX			:= 0

SX3->(dbSetOrder(2)) // X3_CAMPO

For nX := 1 to Len(aCampos)
	SX3->(msSeek(aCampos[nX])) 
				
	Aadd( aHeader, { Rtrim( SX3->(X3Titulo())), ;
						SX3->X3_CAMPO,; 
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID, 	;
						SX3->X3_USADO,	;
						SX3->X3_TIPO, 	;
						".T.",;
						SX3->X3_CONTEXT, ;
						SX3->X3_CBOX } )
Next nX

RestArea(aAreaSX3)
RestArea(aArea)
Return(aHeader)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490CvAcolsºAutor ³Mauricio Pequim Jr. º Data ³  04/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o aCols da getdados de conversão                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490CvAcols( aHeadSXB ,cAliasQry)
Local nX		:= 0 
Local nCols		:= 0
Local aArea		:= GetArea()
Local aColsSXB	:= {}

DbSelectArea(cAliasQry)
(cAliasQry)->(dbGotop())
While !Eof()
    
	aAdd(aColsSXB,Array(Len(aHeadSXB)+1))
	nCols ++
	For nX := 1 To Len(aHeadSXB)
		aColsSXB[nCols][nX] := (cAliasQry)->( FieldGet( FieldPos( aHeadSXB[nX][2]  ) ) )
	Next nX
	aColsSXB[nCols][Len(aHeadSXB)+1] := .F.
    (cAliasQry)->(dbSkip())

Enddo

RestArea( aArea )

Return aColsSXB


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FNXSxbRFlt  ºAutor ³Mauricio Pequim Jr. º Data ³ 04/10/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de retorno da consulta SN303                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FNXSxbRFlt(nCpo)

Local uRet		:= ""
Local oModel	:= FWModelActive()
Local oModelFNX	:= oModel:GetModel("FNXDETAIL")
Local cBase		:= oModelFNX:GetValue("FNX_CBASE")
Local cItem		:= oModelFNX:GetValue("FNX_ITEM")
Local cTipo		:= oModelFNX:GetValue("FNX_TIPO")
Local cTpSld		:= oModelFNX:GetValue("FNX_TPSALD")
Local nValor		:= oModelFNX:GetValue("FNX_VALOR")
Local cFilATF		:= oModelFNX:GetValue("FNX_FILATF")

If Len(aDadosFNX) > 0
	uRet := aDadosFNX[nCpo]
Else
	DO CASE
		CASE nCpo == 1
			uRet := cFilATF 	
		CASE nCpo == 2	
			uRet := cBase 		
		CASE nCpo == 3
			uRet := cItem 		
		CASE nCpo == 4
			uRet := cTipo 
		CASE nCpo == 5
			uRet := cTpSld 
		CASE nCpo == 6
			uRet := nValor
		OTHERWISE
			uRet := ""
	END CASE
Endif

Return uRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490VldF3  ºAutor ³Mauricio Pequim Jr. º Data ³ 04/10/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de retorno da consulta SN303                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490VldF3(aColsSXB,nPos)

aDadosFNX := {}

If Len(aColsSXB) > 0
	aDadosFNX := aClone(aColsSXB[nPos])
Endif

Return .T.      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490STAT   ºAutor ³Mauricio Pequim Jr. º Data ³ 31/07/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Combo box dos campos de Status do controle de provisao     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490STAT(cCodStatus)

Local cStatus := ""

DEFAULT cCodStatus := ""

cStatus := "0="+STR0003 +";" //"Gerado"
cStatus += "1="+STR0054 +";" //"Ativo"
cStatus += "2="+STR0005 +";" //"Efetivado"
cStatus += "3="+STR0102 +";" //"Revisado"
cStatus += "A="+STR0006      //"Realização Pendente"

//Utilizado apenas para o retorno da descricao do Status
If !Empty(cCodStatus)

	If Len(aStatus) == 0	
		aStatus := STRTOKARR(cStatus,";")
	Endif

	If (nPos := Ascan(aStatus,{|aCod| Substr(aCod,1,1) == Alltrim(cCodStatus)}) ) > 0
		cStatus := STR0055 + Substr(aStatus[nPos],3) //"Status Atual: "
	Endif
Endif

Return cStatus


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490VBem   ºAutor ³Mauricio Pequim Jr. º Data ³ 04/10/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualizacao do bem (tela de consulta F3)                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490VBem(aColsSXB,nPos)

Local aAreaSN1	:= SN1->(GetArea())
Local aArea		:= GetArea()		

If !Empty(aColsSXB[nPos][1]) .and. !Empty(aColsSXB[nPos][2])
	dbSelectArea("SN1") 
	SN1->(dbSetOrder(1))
	If SN1->(MsSeek(xFilial("SN1")+aColsSXB[nPos][1]+aColsSXB[nPos][2]))
    	FWExecView("","ATFA012",/*Por padrão a operação é Veiw*/, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)
	Endif
Endif

RestArea(aAreaSN1)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490EFRE ºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a geração das fichas do ativo fixo vinculadas      º±±
±±º          ³ ao controle de provisão                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490EFRE(cAlias,nReg,nOpc)
Local aArea		:= GetArea()
Local aAreaFNV	:= FNV->(GetArea())
Local lConfirma	:= .F.
Local lCancela	:= .F.
Local cTitulo		:= ""
Local cPrograma	:= ""
Local nOperation	:= MODEL_OPERATION_VIEW
Local cCodPrv		:= FNU->FNU_COD
Local cRev			:= FNU->FNU_REV
Local lRet			:= .T.
Local dDtFinal	:= LastDay(dDatabase)
Local dDtInic		:= FNU->FNU_DTINI
Local dDataRlz	:= CTOD("//")
Local aPeriodos	:= {}
Local dLastPer	:= CTOD("//")
Local aButtons	:= {}
Local bCancel		:= {|| A490ConfVs() }


If !(FNU->FNU_STATUS $ '1/2/A' )
	Help("  ",1,"AF490EFR1",,STR0056 ,1,0)   //"O status deste controle de provisao não permite a realização deste processo."
	lRet := .F.
EndIf

If lRet .and. FNU->FNU_STATUS $ '1/2'
	FNV->(dbSetOrder(2)) //FNV_FILIAL+FNV_COD+FNV_REV+DTOS(FNV_DTFIN)
	If !(FNV->(MsSeek(xFilial("FNV")+cCodPrv+cRev)))
		Help("  ",1,"AF490EFR2",,STR0079  + CRLF + STR0080 ,1,0)   //"Não foi encontrada provisão para realização neste período."###"Verifique o cadastro de controle de provisão."
		lRet := .F.
	Endif
EndIf

If lRet .and. dDatabase != dDtFinal
	Help("  ",1,"AF490EFR3",,STR0081+CRLF+STR0082,1,0)	//"A efetivação de realização deve ocorrer no último dia do mês corrente."###"Altere a database do sistema para o último dia do mês do qual deseja efetivar as realizações da provisão"
	lRet := .F.
Endif

If lRet 
	nOcor := AtFVldRlzd(cCodPrv, cRev, dDatabase,@dDataRlz)
	
	//Efetivacao ja realizada para o mes	
	If nOcor == 2 
		Help("  ",1,"AF490EFR5",,STR0083+CRLF+STR0084,1,0)	//"As efetivações de realização para esse período já ocorreram."###"Para novas realizações neste periodo, efetue o estorno das realizações através da opção -> Est.Efet.Rlz."
		lRet := .F.
	Endif	
	
Endif

If lRet .and. AF490TemCtb(cCodPrV,cRev,dDtInic,dDtFinal)
	lRet := .F.
Endif	

If lRet
	cTitulo			:= STR0123 //"Efetivar Realização"
	cPrograma 			:= 'ATFA490'
	__lConfirmar		:= .F.
	__nOper     		:= OPER_EFETREAL
	__lBTNConfirma	:= .T.
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0141},{.T.,STR0140},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar"##"Confirmar"
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons, bCancel )
	
	If __lConfirmar
		MsgRun( STR0057 ,, {||	lRet := AF490Reali(cCodPrv,cRev) } ) // //"Efetivando as realizações do controle de provisao...."
	EndIf
EndIf

__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490ESEF ºAutor  ³Alvaro Camillo Neto º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza o estorno das movimentações de realização do periodo±±
±±º          ³ do controle de provisão                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490ESEF(cAlias,nReg,nOpc)
Local aArea          := GetArea()
Local aAreaFNV       := FNV->(GetArea())
Local lConfirma      := .F.
Local lCancela       := .F.
Local cTitulo        := ""
Local cPrograma      := ""
Local nOperation     := MODEL_OPERATION_VIEW
Local cCodPrv        := FNU->FNU_COD
Local cRev           := FNU->FNU_REV
Local lRet           := .T.
Local cPeriodo       := Substr(Dtos(dDatabase),1,6)
Local dDtFinal       := LastDay(dDatabase)
Local dDataRlz       := CTOD("//")
Local aButtons		:= {}
Local bCancel			:= {|| A490ConfVs() }

If !(FNU->FNU_STATUS $ '1/2/A' )
	Help("  ",1,"AF490SEFR1",,STR0119 ,1,0)   //"O status deste controle de provisao não permite a realização deste processo."
	lRet := .F.
EndIf

If lRet .and. dDatabase != dDtFinal
	Help("  ",1,"AF490EFR3",,STR0104+CRLF+STR0105,1,0)	//"O estorno da realização deve ocorrer no último dia do mês corrente."###"Altere a database do sistema para o último dia do mês do qual deseja estornar as realizações da provisão"
	lRet := .F.
Endif

If lRet
	lRet := AtFVlEsEf(cCodPrv, cRev, dDatabase)
Endif

If lRet .And. Pergunte("ATFA490A",.T.)
	cTitulo         := STR0124 //"Estornar Efetivação de Realização"
	cPrograma       := 'ATFA490'
	__lConfirmar    := .F.
	__nOper         := OPER_EST_EFET
	__lBTNConfirma  := .T.
	aButtons 		  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0141},{.T.,STR0140},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar"##"Confirmar"
	
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons, bCancel )

	If __lConfirmar
		MsgRun( STR0103 ,, {||	lRet := AF490EstRz(cCodPrv,cRev,dDataBase) } ) //"Estornando as realizações do controle de provisao...." 
	EndIf
EndIf

__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet   




/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtFPerRlzd   ³ Autor ³Mauricio Pequim Jr.³ Data ³ 19/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a realizacao do periodo ja foi efetivada       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPrv   = Codigo da Provisao                             ³±±
±±³          ³ cRev      = Revisao da Provisao                            ³±±
±±³          ³ dData     = Database da efetivacao de realizacao			  ³±±
±±³          ³ dDataRlz  = Data da previsao de realizacao (recursiva)     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtFVldRlzd(cCodPrv, cRev, dData,dDtRlzd)

Local nOcor		:= 0
Local cQuery	:= ""
Local cData		:= ""
Local cAliasQry := "TRB490RLZ"

DEFAULT cCodPrv := ""
DEFAULT cRev	:= ""
DEFAULT dData	:= CTOD("//")
DEFAULT dDtRlzd := CTOD("//")

cData	:= DTOS(dData)

//Query na FNX para obter movimentos de realização no periodo
cQuery := "SELECT FNV_DTFIN, FNV_RLZEFT "
cQuery += " FROM " + RetSQLTab('FNV')
cQuery += " WHERE "
cQuery += 		"FNV_COD    = '" + cCodPrv	+ "' AND "
cQuery += 		"FNV_REV    = '" + cRev     + "' AND "
cQuery += 		"FNV_DTFIN  <= '" + cData   + "' AND "
cQuery += 		RetSqlCond("FNV")

cQuery += "ORDER BY FNV_FILIAL,FNV_COD,FNV_REV,FNV_DTFIN"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
TcSetField(cAliasQry,"FNV_DTFIN","D")	

dbSelectArea(cAliasQry)
DbGotop()

While (cAliasQry)->(!EOF())
	//Realizacao anterior pendente
	If (cAliasQry)->(FNV_DTFIN) < dData .and. (cAliasQry)->(FNV_RLZEFT) == '2'
		nOcor := 1	
		dDtRlzd := (cAliasQry)->(FNV_DTFIN)

	//Realizacao ja efetuada para o periodo
	ElseIf (cAliasQry)->(FNV_DTFIN) == dData .and. (cAliasQry)->(FNV_RLZEFT) == '1'
		nOcor := 2    
	Endif

	If nOcor > 0
		Exit
	Else
		(cAliasQry)->(dbskip())	
	Endif
EndDo

(cAliasQry)->(dbCloseArea())

Return nOcor




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490GerRzºAutor  ³Mauricio Pequim Jr  º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que realiza a gravação das fichas do ativo do        º±±
±±º          ³processo                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490GerRZ(cCodPrv,cRev,dData,cPeriodo,lAtualiza)

Local aArea		:= GetArea()
Local aAreaFNU	:= FNU->(GetArea())
Local aAreaFNV	:= FNV->(GetArea())
Local aAreaFNX	:= FNX->(GetArea())
Local aRecnosFNX	:= {}
Local aTamFNX		:= TAMSX3("FNX_VALOR")
Local aPeriodos	:= {}
Local cOcor		:= ""
Local cAliasQry	:= "FNX490"
Local cDataIni	:= CTOD("//")
Local cDataFin	:= CTOD("//")
Local dLastPer	:= CTOD("//")
Local lRet			:= .T.
Local lCurto		:= .F.
Local nX			:= 0
Local nTotPrv		:= 0
Local nTotRlz		:= 0 
Local nComplRev	:= 0
Local nRecFNV		:= 0

DEFAULT cCodPrv 	:= ""
DEFAULT cRev		:= ""
DEFAULT dData		:= CTOD("//")
DEFAULT cPeriodo	:= Substr(Dtos(dDatabase),1,6)
DEFAULT lAtualiza	:= .F.

cDataIni	:= DTOS(FirstDay(dData))
cDataFin	:= DTOS(LastDay(dData))

//Acho a ultima data dos periodos da provisao
A490Periodos(cCodPrv,cRev,aPeriodos,.T.) 
dLastPer := aPeriodos[Len(aPeriodos)]

//Verifico se o movimento eh de curto ou longo prazo
lCurto := AF490Curto(dData,dLastPer)[1]

If !Empty(cCodPrv) .and. !Empty(cRev) .and. !Empty(dData) .and. !Empty(cPeriodo)

	//Posiciono o cadastro da provisão
	FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV
	FNU->(MsSeek( xFilial("FNU") + cCodPrv + cRev )) 

	//Encontro o valor da provisao planejada
	FNV->(dbSetOrder(2)) //FNV_FILIAL+FNV_COD+FNV_REV+DTOS(FNV_DTFIN)
	If FNV->(MsSeek( xFilial("FNV") + cCodPrv + cRev + cDataFin )) 
		nTotPrv	:= FNV->FNV_VLRBRT
		nRecFNV := FNV->(Recno())
	Endif
	
	//Query na FNX para obter movimentos de realização no periodo
	cQuery := "SELECT R_E_C_N_O_ FNXRECNO, FNX_FILIAL, FNX_COD, FNX_REV, "
	cQuery += "FNX_LINHA, FNX_CBASE, FNX_ITEM, FNX_TIPO, FNX_TPSALD, FNX_VALOR, FNX_DTMOV "
	cQuery += " FROM " + RetSQLTab('FNX')
	cQuery += " WHERE "
	cQuery += 		"FNX_COD    = '" + cCodPrv	+"' AND "
	cQuery += 		"FNX_REV    = '" + cRev     +"' AND "
	cQuery += 		"FNX_DTMOV  BETWEEN  '" + cDataIni + "'AND '" + cDataFin + "' AND "
	cQuery +=		"FNX_DTCONT = ' ' AND "
	cQuery += 		RetSqlCond("FNX")
	
	cQuery += "ORDER BY FNX_FILIAL,FNX_COD,FNX_REV,FNX_DTMOV"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	TcSetField(cAliasQry,"FNX_VALOR","N",aTamFNX[1],aTamFNX[2])
	TcSetField(cAliasQry,"FNX_DTMOV","D")	
		
	dbSelectArea(cAliasQry)
	
	
	//array com recnos para atualizacao do flag de realizacao
	nTotRlz := 0
	While (cAliasQry)->(!EOF())
		aadd( aRecnosFNX, (cAliasQry)->(FNXRECNO) )
		nTotRlz += (cAliasQry)->(FNX_VALOR)
		(cAliasQry)->(dbSkip())	
	EndDo

	(cAliasQry)->(dbCloseArea())

	//Caso nao encontre nenhum momento de realizacao, finaliza o processo
	If nTotRlz == 0 .and. nTotPrv == 0 .and. !lAtualiza
		lRet := .F.
	Endif
	
	If lRet
		Begin Transaction
			// Exclui os movimentos da operação de realização ( ocorrencia 03/04/05 )
			AF490DelFnw(cCodPrv,cRev,FirstDay(dData),LastDay(dData),{'03','04','05'})

			//Grava movimento de reaalizacao - soma das realizacoes do periodo
			If lRet .and. nTotRlz > 0
				lRet := AtfGrvFNW("03",cCodPrv,cRev,nTotRlz,dData,lCurto)
			Endif
					
			If lRet
				//Encontro a diferenca entre o previsto e o realizado
				nComplRev := nTotPrv - nTotRlz
				
				//Se houve diferenca entre a previsao e a realizacao
				//Grava movimento de Complemento (04) ou Reversao (05)
				If nComplRev != 0
        			cOcor := If(nComplRev < 0,"04","05")
					lRet := AtfGrvFNW(cOcor,cCodPrv,cRev,ABS(nComplRev),dData,lCurto)
				Endif        	
        	Endif
		
			If lRet .and. !lAtualiza
				//Efetivo os movimentos de realizacao							
				For nX := 1 to Len(aRecnosFNX)
					DbSelectArea("FNX")
					dbSetOrder(3)
					FNX->(dbGoto(aRecnosFNX[nX]))
					RecLock("FNX")
					FNX->FNX_DTCONT  := dDatabase
					MsUnlock( )
				Next

				//Seto o flag de realizado para o item da provisão
				If nRecFNV > 0
        			FNV->(dbGoTo(nRecFnv))
					RecLock("FNV")
					FNV->FNV_RLZEFT := "1"
					MsUnlock( )
				Endif									

				//Volto o projeto ao status de ativo	
				If FNU->FNU_STATUS == 'A' 
					//Verifico se foi incluido algum registro de realização 
					//Verifico se existe algum registro contabilizado para o controle de provisao
					//Se nao existir, volto o status para Atualizado
					//Se existir, volto para o status Efetivado

					aRegs := AF490Dados(3,cCodPrv,cRev)
					If Len(aRegs) > 0
						cFlag := "2"
					Else			
						cFlag := "1"
					Endif
				
					AF490FLAG(cCodPrv,cRev,cFlag)
				Endif				
			Endif
		
		End Transaction

	EndIf
Endif

RestArea(aAreaFNX)
RestArea(aAreaFNV)
RestArea(aAreaFNU)
RestArea(aArea)

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490FLAG ºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera os campos flags do cadastro de provisao             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490FLAG(cCodPrv,cRev,cFlag)

Local aArea		:= GetArea()
Local aAreaFNU	:= FNU->(GetArea())

FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV
If FNU->(MsSeek( xFilial("FNU") + cCodPrv + cRev ))
	RecLock("FNU",.F.)
	FNU->FNU_STATUS := cFlag
	MsUnLock()
EndIf

RestArea(aAreaFNU)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490GrvVl ºAutor  ³Mauricio Pequim Jr. º Data ³ 04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera os campos de valores do cadastro de provisao (FNU)  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490GrvVl(cCodPrv,cRev,nVlrBrt,nVlrPre)

Local aArea		:= GetArea()
Local aAreaFNU	:= FNU->(GetArea())

FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV
If FNU->(MsSeek( xFilial("FNU") + cCodPrv + cRev ))
	RecLock("FNU",.F.)
	FNU->FNU_VLRBRT := nVlrBrt
	FNU->FNU_VLRPRE := nVlrPre	
	MsUnLock()
EndIf

RestArea(aAreaFNU)
RestArea(aArea)

Return



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFA490ATU  ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a geracao dos dados da planilha de provisao do     ³±±
±±³          ³ controle de provisao e ativa o mesmo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490ATU(cAlias,nReg,nOpc,lA490Auto,cChave)
Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo			:= ""
Local cPrograma		:= ""
Local nOperation		:= MODEL_OPERATION_VIEW
Local cCodPrv			:= ""
Local cRev				:= ""
Local lRet				:= .T.
Local aButtons		:= {}
Local bCancel			:= {|| A490ConfVs() }

Default lA490Auto := .F.  //Controla se é via execauto

If lA490Auto
	DbSelectArea("FNU")
	DbSeek(cChave)
Endif

cCodPrv			:= FNU->FNU_COD
cRev			:= FNU->FNU_REV

If lRet .And. FNU->FNU_STATUS != '0'
	Help(" ",1,"AF490ATU",,STR0065 ,1,0)   //"Não é possivel atualizar controle de provisão com esse status"
	lRet := .F.
EndIf
If lRet .and. FNU->FNU_MSBLQL == "1"  //REGISTRO BLOQUEADO
	Help("  ",1,"AF490BLQA",,STR0101 ,1,0)   //"O controle de provisão encontra-se bloqueado. Portanto não será possível realizar a ação desejada."
	lRet := .F.
Endif
If lRet .AND. !lA490Auto
	cTitulo 	:= STR0073 //"Atualizar"
	cPrograma 	:= 'ATFA490'
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0141},{.T.,STR0140},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar"##"Confirmar"
	__lConfirmar:= .F.
	__nOper     := OPER_ATUALIZAR
	__lBTNConfirma  := .T.
		
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
	
	If __lConfirmar
		MsgRun( STR0066 ,, {||	lRet := AF490GerAT(cCodPrv,cRev) } ) // //"Processando atualização do Controle de Provisão..."
	EndIf
EndIf

If lA490Auto
	AF490GerAT(cCodPrv,cRev)
Endif
	
__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490GerATºAutor  ³Mauricio Pequim Jr. º Data ³  09/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que realiza a gravação da atualizacao do controle de º±±
±±º          ³provisao                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function AF490GerAT(cCodPrV,cRev)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaFNU	:= FNU->(GetArea())
Local nIndice	:= 0 
Local nValorDst := 0
Local nValorPrv	:= 0
Local aPeriodos	:= {}
Local aMovtos	:= {}
Local lCurto	:= .F.
Local dLastPer  := Ctod("//")  
Local dAtualPer := Ctod("//")  
Local dCurto    := Ctod("//")  
Local nX		:= 0
Local cPeriodo	:= Substr(Dtos(dDatabase),1,6)
Local dIniProj := cTod("//")
Local lProvAcm := .F.
Local dIniAVP := Ctod("//")  

FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV
FNU->(MsSeek(xFilial("FNU")+cCodPrv+cRev))

//Acho numero de periodos da provisao
A490Periodos(cCodPrv,cRev,aPeriodos) 

//Acho data final dos periodos de provisao
dLastPer := aPeriodos[Len(aPeriodos)]

//Acho data de inicio do curto prazo
dCurto := AF490Curto(dAtualPer,dLastPer)[2]

dIniProj := FNU->FNU_INIPRJ

dIniAVP := FNU->FNU_DTAVP


dIniProv := FNU->FNU_DTINI

//Criacao do TRB auxiliar do calculo de AVP
IF Len(aPeriodos) > 0
	cArqTrb := AF490TRB()
Endif 


Begin Transaction

	//Excluo os movimentos gerados anteriormente
	AF490DelFnw(cCodPrV,cRev)
   
    //Grava o movimento acumulado
	If dIniProj < dIniProv
		
		lProvAcm := .T.
		
		dIniProj := LastDay(dIniProj) + 1
		
		dAtualPer := LastDay(dIniProv - 1)
		
		//Obtenho o indice da curva de demanda
		Atf490Ind(@nIndice,,FNU->FNU_INDICE,dIniProj,dLastPer, dAtualPer , .T.)
	
		//Calculo do periodo - Distribuicao
		nValorDst := AtfCalFNW("01",FNU->FNU_VLRPRE,nIndice)
	
		//Verifico se o movimento eh de curto ou longo prazo
		lCurto := AF490Curto(dIniProj,dLastPer)[1]
	
		//Grava movimento Distribuicao
		lRet := AtfGrvFNW("01",cCodPrv,cRev,nValorDst,dAtualPer,lCurto)
		
		If lRet
			//Calculo do periodo - Provisao
			nValorPrv := AtfCalFNW("02",,,dIniAVP,dAtualPer,nValorDst)
			//Grava movimento - Provisao
			lRet := AtfGrvFNW("02",cCodPrv,cRev,nValorPrv,dAtualPer,lCurto)
		Endif
		
	EndIf

	
	For nX := 1 to Len(aPeriodos)
	
		dAtualPer := aPeriodos[nX]
	
		cPeriodo  := Substr(Dtos(dAtualPer),1,6)
		
		//Obtenho o indice da curva de demanda
		Atf490Ind(@nIndice,,FNU->FNU_INDICE,dIniProj,dLastPer,dAtualPer)   
	
		//Calculo do periodo - Distribuicao
		nValorDst := AtfCalFNW("01",FNU->FNU_VLRPRE,nIndice)
		
		//Verifico se o movimento eh de curto ou longo prazo
		lCurto := AF490Curto(dAtualPer,dLastPer)[1]
		
		//Grava movimento Distribuicao 
		lRet := AtfGrvFNW("01",cCodPrv,cRev,nValorDst,dAtualPer,lCurto)
		
		If lRet
			//Calculo do periodo - Provisao
			nValorPrv := AtfCalFNW("02",,,dIniAVP,dAtualPer,nValorDst)
			//Grava movimento - Provisao
			lRet := AtfGrvFNW("02",cCodPrv,cRev,nValorPrv,dAtualPer,lCurto)
		Endif
	
		If lRet
			//Gera o realizado para a atualizacao
			lRet := AF490GerRz(cCodPrv,cRev,dAtualPer,cPeriodo,.T.)  
		Endif
	
		If !lRet
			Exit
	 	Endif
	
	Next
	
	//Movimentos de AVP
	If lRet
		//Carrego no TRB dos movimentos gerados acima e calculo AVP
		//01 - Distribuicao
		//02 - Provisao
		//03 - Realizacao
		//04 - Complemento
		//05 - Reversao
		lRet := Af490AVP(cArqTrb,cCodPrV,cRev,lProvAcm)
		If lRet
			//Gravacao dos movimentos de provisao de AVP
			dbSelectArea(cArqTrb)
			(cArqTrb)->(dbGoTop())
			While (cArqTrb)->(!Eof()) 
			
				dAtualPer := (cArqTrb)->DTPERIODO
	
				//Verifico se o movimento eh de curto ou longo prazo
				lCurto := AF490Curto(dAtualPer,dLastPer)[1]
	
				//Grava movimento - Avp
				lRet := AtfGrvFNW("06",cCodPrv,cRev,(cArqTrb)->AVPPERIODO,dAtualPer,lCurto)
	
				If !lRet
					DisarmTransaction()
					Exit
				Else 
					(cArqTrb)->(dbSkip()) 
			 	Endif
		
			EndDo
		
			If lRet
				AtfDifAvp(cCodPrv,cRev)
				//Torno o controle de provisao ativo
				AF490FLAG(cCodPrV,cRev,"1")
			Endif
		EndIf
	
	Endif

	//Movimentos de transferencia para curto prazo
	If lRet

		//aMovtos[1] = Codigo do movimento
		//				11 - Trf. Tot Distribuicao [soma movto tipo 01]
		//				12 - Trf. Tot Provisao     [soma movto tipo 02]
		//				13 - Trf. Tot Realizacao   [soma movto tipo 03]
		//				14 - Trf. Tot Complemento  [soma movto tipo 04]
		//				11 - Trf. Tot Reversao     [soma movto tipo 05]
		//				11 - Trf. Tot AVP          [soma movto tipo 06]
		//aMovtos[2] = Valor de cada movimento (Soma de cada movimento do inicio da provisao ate a data de curto prazo)
		aMovtos := AF490TrfCP(cCodPrv,cRev,dCurto)
		
		For nX := 1 to Len(aMovtos)
			//Grava movimento - Avp
			lRet := AtfGrvFNW(aMovtos[nX,1],cCodPrv,cRev,aMovtos[nX,2],dCurto,.T.)

			If !lRet
				Exit
			Endif
		Next

	Endif
	
	If !lRet
		DisarmTransaction()
	Endif
	
End Transaction

IF Select(cArqTrb) > 0
	dbSelectArea(cArqTrb)
	dbCloseArea()
ENDIF

//Deleta tabela temporaria no banco de dados
If _oATFA4901 <> Nil
	_oATFA4901:Delete()
	_oATFA4901 := Nil
Endif

RestArea(aAreaFNU)
RestArea(aArea)

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ F490SelFolder³ Autor ³Mauricio Pequim Jr.³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona o folder conforme a necessidade da rotina  o     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//-------------------------------------------------------------------
/* SelectFolder
Seleciona e exibe um FOLDER. Pode ser usado tanto para Folders do View,
quanto para folders criadas pelo metodo CreateFolder().

param cID ID da Folder ou do View
param xFolder Número da Folder ou Título dela
param nType Tipo de Folder [ 1 - VIEW ; 2 - FOLDER ]
*/
Static Function F490SelFolder(oView)

If __nOper == OPER_REALIZAR .or. __nOper == OPER_EFETREAL .or. __nOper == OPER_EST_EFET
	oView:SelectFolder('PASTA_INFERIOR',2,2)
Else
	oView:SelectFolder('PASTA_INFERIOR',1,2)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ Atf490Ind 	ºAutor  ³Jandir Deodato   º Data ³  10/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula a taxa de depreciacao por índice Tipo 2(Calculado) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Atf490Ind(nTxDepr,cFili,cCodInd,dIniDepre,dFinDepre,dDataPer,lAcumulada)

Local aAreaFNI		:= FNI->(GetArea())
Local aArea		:= GetArea()
Local cTipo	  	:= ""
Local cDataIni		:= ""
Local cDataFin		:= ""
Local cDataPer    := ""
Local nTaxa		:= 0
Local nAcumulado 	:= 0
Local nCurva 		:= 0
Local lRet			:= .T.

Default nTxDepr 	:= 0
Default cFili		:=  xFilial("FNI")
Default cCodInd		:= ""
Default dIniDepre	:= Ctod("//")
Default dFinDepre	:= Ctod("//")
Default dDataPer	:= dDatabase
Default lAcumulada := .F.

//Caso os dados nao sejam informados, nao efetuo calculos
If Empty(cCodInd) .or. Empty(dIniDepre) .or. Empty(dFinDepre)
	lRet := .F.
Endif

//Pesquisa o cadastro do índice
If lRet .and. FNI->(MsSeek( cFili + cCodInd ))

	cTipo := AllTrim(FNI->FNI_PERIOD)

	//Verifica se o índice nao está desbloqueado
	If FNI->FNI_MSBLQL == "2"

		cDataIni := DtoS(FirstDay(dIniDepre))
		cDataFin := Dtos(LastDay(dFinDepre))
		cDataPer := Dtos(dDataPer)
		
		If lAcumulada
			//Funcao para Calcular o acumulado da curva de demanda
			nAcumulado:= AF490Acumula(cDataIni,cDataFin,cCodInd,cFili)
			
			//Funcao para Calcular o acumulado do inicio da curva até a data atual
			nAcmProj:= AF490Acumula(cDataIni,cDataPer,cCodInd,cFili)
	
			IF nAcumulado > 0 .and. nAcmProj > 0
				nTaxa:=(nAcmProj/nAcumulado)
			Endif		
		Else
			//Funcao para Calcular o acumulado da curva de demanda
			nAcumulado:= AF490Acumula(cDataIni,cDataFin,cCodInd,cFili)
		
			//para indices tipo 2 - calculado a taxa de depreciacao e calculada dividindo-se
			// a curva cadastrada para o mes de depreciacao pelo acumulado da curva
			nCurva:=AtfCalCurv(cFili,cCodInd,dDataPer)
		
			IF nAcumulado > 0 .and. nCurva > 0
				nTaxa:=(nCurva/nAcumulado)
			Endif
		EndIf
	Endif

	//Atualiza a taxa de depreciação
	nTxDepr := nTaxa

EndIf


RestArea(aAreaFNI)
RestArea(aARea)	

Return nTxDepr


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ AF490Acumula ºAutor  ³Jandir Deodato  º Data ³  10/10/12     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula o acumulado da  curva de demanda                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490Acumula(cDataIni,cFimDepre,cCodigo,cFili)

Local nAcumul 	:= 0
Local aArea		:= GetArea()
Local aAreaFNT	:= FNT->(GetArea())
Local cQuery	:= ""
Local cAliasCalc:= ""

Default cFili := Xfilial('FNI')

cQuery := "SELECT SUM(FNT_CURVA) ACUMULADO FROM" + RetSQLName('FNT') 
cQuery += " WHERE "
cQuery += "   FNT_FILIAL = '" + cFili + "' AND "
cQuery += "   FNT_DATA BETWEEN  '" + cDataIni + "'AND  '" + cFimDepre + "'  AND "
cQuery += "   FNT_CODIND ='" + cCodigo + "' AND "
cQuery += "   FNT_MSBLQL ='2' AND 
cQuery += "   FNT_STATUS ='1' AND  
cQuery += "   D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

cAliasCalc := GetNextAlias()

If Select(cAliasCalc)>0
	(cAliasCalc)->(dbCloseArea())
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasCalc, .T., .T.)
If (cAliasCalc)->ACUMULADO > 0
	nAcumul:= (cAliasCalc)->ACUMULADO
Endif	
(cAliasCalc)->(dbCloseArea())

RestArea(aAreaFNT)
RestArea(aArea)
Return nAcumul


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ AtfCalCurv ºAutor  ³Jandir Deodato      º Data ³ 10/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca a Curva do mes da baixa						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfCalCurv(cFili,cCodigo,dDataPer)

Local aArea		 := GetArea()
Local aAreaFNT	 := FNT->(GetArea())
Local nCurva	 := 0
Local dDataDepre := CTOD("//")

Default cFili	:= xFilial("FNI")
Default cCodigo := ""
Default dDataPer := FirstDay(dDatabase)

dDataDepre	:= Firstday(dDataPer)

dbSelectArea('FNT')
FNT->(dbSetOrder(3))//FNT_FILIAL+FNT_CODIND+DTOS(FNT_DATA)+FNT_REVIS

If FNT->(DbSeek(cFili+cCodigo+Dtos(dDataDepre)))	
	While FNT->(!EoF()) .And. (FNT->FNT_FILIAL == cFili) .And. (FNT->FNT_CODIND == cCodigo) .And. (FNT->FNT_DATA == dDataDepre)
		If (FNT->FNT_MSBLQL == "2") .And. (FNT->FNT_STATUS = "1")
			nCurva:=FNT->FNT_CURVA
			Exit
		Endif
		FNT->(dbSkip())	
	Enddo
Endif

RestArea(aAreaFNT)
RestArea(aArea)

Return nCurva

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ F490SelFolder³ Autor ³Mauricio Pequim Jr.³ Data ³ 16/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna as datas do periodo do controle de provisao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPrv = Codigo da Provisao                               ³±±
±±³          ³ cRev    = Revisao da Provisao                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A490Periodos(cCodPrv,cRev,aPeriodos,lRealizacao) 

Local lRet				:= .T.
Local nPeriodos		:= 0
Local nMonthIni		:= 0
Local nMonthFin		:= 0
Local nMonthYear		:= 0
Local cQuery			:= ""
Local cTab   			:= "TRBATFA490"
Local nX				:= 0   
Local dDataFin		:= CTOD("//")
Local dDataIni		:= CTOD("//")

Default cCodPrv 		:= ""
Default cRev 			:= ""
Default lRealizacao	:= .F.

If Empty(cCodPrv) .or. Empty(cRev)
	lRet := .F.
Endif

If lRet
	
	FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV
	FNU->(MsSeek(xFilial("FNU")+cCodPrv+cRev))
	
	dDataIni := FNU->FNU_DTINI
	
	//Encontro a data final do controle de provisao
	If Select(cTab) > 0
		(cTab)->(dbCloseArea())
	EndIf
	cQuery := " SELECT MAX(FNV_DTFIN) FNV_DTFIN FROM " + RetSQLTab("FNV")+ " WHERE "
	cQuery += " FNV_COD = '" + cCodPrv +"' AND"
	cQuery += " FNV_REV = '" + cRev    +"' AND"
	cQuery += RetSQLCond("FNV")
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab )
	TCSetField(cTab, "FNV_DTFIN" ,"D", 8, 0 )
	
	If (cTab)->(!EOF())
		dDataFin := (cTab)->FNV_DTFIN
	EndIf
	(cTab)->(dbCloseArea())
	
	If lRealizacao // Considera realizações para definições do período
		FNX->(dbSetOrder(1)) //FNX_FILIAL+FNX_COD+FNX_REV+DTOS(FNX_DTMOV)
		
		If FNX->(MsSeek(xFilial("FNX")+cCodPrv+cRev))
			dDataIniFNX := FirstDay(FNX->FNX_DTMOV)
			dDataIni := IIF( dDataIniFNX < dDataIni , dDataIniFNX , dDataIni )
		EndIf
		
		//Encontro a data final do controle de provisao
		If Select(cTab) > 0
			(cTab)->(dbCloseArea())
		EndIf
		cQuery := " SELECT MAX(FNX_DTMOV) FNX_DTMOV FROM " + RetSQLTab("FNX")+ " WHERE "
		cQuery += " FNX_COD = '" + cCodPrv +"' AND"
		cQuery += " FNX_REV = '" + cRev    +"' AND"
		cQuery += RetSQLCond("FNX")
		
		cQuery := ChangeQuery(cQuery)
		
		DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTab )
		TCSetField(cTab, "FNX_DTMOV" ,"D", 8, 0 )
		
		If (cTab)->(!EOF())
			dDataFinFNX := LastDay((cTab)->FNX_DTMOV)
			dDataFin := IIF( dDataFinFNX > dDataFin , dDataFinFNX , dDataFin )
		EndIf
		
		(cTab)->(dbCloseArea())
	EndIf
	
	
	//Encontro o numero de periodos do controle de provisao
	nMonthIni  := Month(dDataIni)						//Mes data inicial
	nMonthFin  := Month(dDataFin)+1					  		//Mes data final + 1
	nMonthYear := (Year(dDataFin) - Year(dDataIni)) * 12	//diferença entre o ano inicial e o final
	//(para cada ano, somo 12 meses)
	nPeriodos  := (nMonthFin - nMonthIni) + nMonthYear
	
	//Retorno array com as datas
	For nX := 1 to nPeriodos
		
		//Primeira data eh a data inicial da provisao
		If nX == 1
			AADD(aPeriodos, LastDay(dDataIni))
			dDataAnt := dDataIni
			//Ultima data eh a data final da provisao
		ElseIf nX == nPeriodos
			AADD(aPeriodos, LastDay(dDataFin))
		Else
			//Acho a data do proximo mes
			dDataAtu := dDataAnt + 28
			If ( Month(dDataAtu) == Month(dDataAnt) )
				dDataAtu += 28
			EndIf
			//Acho a data inicial do mes
			dDataAtu := LastDay(dDataAtu)
			//Guardo a data no array de periodos
			AADD(aPeriodos, dDataAtu)
			dDataAnt := dDataAtu
		Endif
	Next
Endif

Return aPeriodos



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtfCalFNW    ³ Autor ³Mauricio Pequim Jr.³ Data ³ 16/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o valor calculado de acordo com a ocorrencia       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOcorr  = Codigo da ocorrencia a ser processada            ³±±
±±³          ³ nValPre = Valor presente total do controle de provisao     ³±±
±±³          ³ nIndice = Indice da curva a ser aplicado                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfCalFNW(cOcor,nValPre,nIndice,dDataIni,dDataFin,nValDist)

Local nValor	:= 0
Local nTaxa		:= 0	
Local nDias		:= 0
Local nIndDia	:= 0
Local nDiasAvp	:= 0
Local cPeriodo	:= ""

Default cOcor		:= ""
Default nValPre		:= 0
Default nIndice		:= 0
Default dDataIni	:= 0
Default dDataFin	:= 0
Default nValDist	:= 0 

DO CASE
	//Distribuicao
	CASE cOcor == "01"
		nValor := nValPre * nIndice

	//Provisao	
	CASE cOcor == "02"

		cPeriodo := GetAdvFVal("FIT","FIT_PERIOD", xFilial("FIT") + FNU->FNU_INDAVP)
		nTaxa	 := FNU->FNU_TAXAVP

		DO CASE
			CASE cPeriodo = "1"	//Diario
				nDias := 1
			CASE cPeriodo = "2"	//Mensal
				nDias := 30
			CASE cPeriodo = "3"	//Trimestra
				nDias := 90
			CASE cPeriodo = "4"	//Semestral
				nDias := 180
			CASE cPeriodo = "5"	//Anual
				nDias := 360
			OTHERWISE
				nDias := 0
		ENDCASE

		//Converto a Taxa informada para taxa diaria
		nIndDia := (1+(nTaxa/100))**(1/nDias) //Taxa equivalente
		
		//Calculo o numero de dias para AVP
		nDiasAvp := AtfDiasAvp(dDataIni,dDataFin,.T.)
		
		//Valor Provisao
		nValor	:= nValDist * (nIndDia**nDiasAVP)				

ENDCASE


Return nValor		


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtfCalFNW    ³ Autor ³Mauricio Pequim Jr.³ Data ³ 16/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o valor calculado de acordo com a ocorrencia       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOcorr    = Codigo da ocorrencia a ser processada          ³±±
±±³          ³ cCodPrv   = Codigo da Provisao                             ³±±
±±³          ³ cRev      = Revisao da Provisao                            ³±±
±±³          ³ nValorFNW = Valor do movimento						      ³±±
±±³          ³ nIndice   = Indice da curva a ser aplicado                 ³±±
±±³          ³ dPeriodo  = Ultimo dia do periodo de referencia            ³±±
±±³          ³ lCurtoPrz = Indica se eh movimento de curto ou longo prazo ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfGrvFNW(cOcor,cCodPrv,cRev,nValorFNW,dPeriodo,lCurtoPrz)

Local aArea		:= GetArea()
Local lRet			:= .T.
Local cIdProc		:= ""
Local nMax         := Val("9" +  Replicate( "0", 10 ) ) // numeto maximo para previnir estouro de valores

Default cOcor		:= ""
Default cCodPrv	:= ""
Default cRev		:= ""
Default nValorFNW	:= 0
Default dPeriodo	:= 0
Default lCurtoPrz	:= .F.

If Empty(cOcor) .or. Empty(cCodPrv) .or. Empty(cRev) .or. Empty(dPeriodo)
	lRet := .F.
Endif

If lRet .And. nValorFNW > nMax
	lRet := .F.
	Help("  ",1,"AF490POSV4",,STR0135 ,1,0)//"Valor inválido. Por favor verificar os itens do Controle de Provisão"
EndIf


If lRet .and. !Empty(nValorFNW) 

	cPeriod := Substr(Dtos(dPeriodo),1,6)

	cIdProc := GetSxeNum('FNW','FNW_IDMOV','FNW_IDMOV'+cEmpAnt,3)

	RecLock("FNW",.T.)

	FNW->FNW_FILIAL := xFilial("FNW")
	FNW->FNW_COD	:= cCodPrv
	FNW->FNW_REV	:= cRev
	FNW->FNW_PERIOD := cPeriod
	FNW->FNW_DTMOV  := LastDay(dPeriodo)
	FNW->FNW_OCOR   := cOcor		
	FNW->FNW_VALOR  := nValorFNW
	FNW->FNW_IDMOV  := cIdProc       	
	FNW->FNW_PRAZO  := If (lCurtoPrz, "2","1")
	FNW->FNW_DTEFET := dDatabase

	FNW->(MsUnlock())

	//Confirmo o ID do processo nas tabelas de controle
	ConfirmSX8()
	
Endif

If cOcor == '06'
	_nRecFNW := FNW->(Recno()) 
Endif

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o	 ³ AF490TRB ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 22/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o³ Cria o arquivo TRB para calculo do AVP de atualizacao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ AF490TRB()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ ATFA490 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490TRB()

Local cNomeArq := ""

aCampos	:=	{{ "PERIODO   ", "C", 06, 0 }, ;
 	  		 { "DTPERIODO ", "D", 08, 0 }, ;
 	  		 { "VLDISTRIB ", "N", 16, 2 }, ;
			 { "VLPRESPLAN", "N", 16, 2 }, ;
			 { "SLDDESCONT", "N", 16, 2 }, ;
			 { "QTDEDIAS  ", "N", 16, 2 }, ;
			 { "INDCORAVP ", "N", 14, 8 }, ;
			 { "SLDATUALIZ", "N", 16, 2 }, ;
	 		 { "SLDINICIAL", "N", 16, 2 }, ;
	 		 { "PRVPERIODO", "N", 16, 2 }, ;
			 { "RLZPERIODO", "N", 16, 2 }, ;
			 { "CPLPERIODO", "N", 16, 2 }, ;
			 { "REVPERIODO", "N", 16, 2 }, ;
			 { "MOVACM"    , "C", 1, 0 }, ;
			 { "AVPPERIODO", "N", 16, 2 } }

If (Select("TRBAVP")<>0)
	dbSelectArea ("TRBAVP")
	dbCloseArea()
Endif

If _oATFA4901 <> Nil
	_oATFA4901:Delete()
	_oATFA4901 := Nil
Endif

_oATFA4901 := FWTemporaryTable():New( "TRBAVP" )  
_oATFA4901:SetFields(aCampos) 
_oATFA4901:AddIndex("1", {"PERIODO"})

//------------------
//Criação da tabela temporaria
//------------------
_oATFA4901:Create()  

Return "TRBAVP"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ Af490apv   ³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 22/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Insere dados no TRB para calculo do AVP de atualizacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ AF490TRB()												   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ cArqutrb - Nome do TRB   								   ³±±
±±³           ³ cCod     - Codigo do controle de provisao				   ³±±
±±³           ³ cCod     - Revisao do controle de provisao				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af490Avp(cArqTrb,cCod,cRev,lProvAcm)

Local lRet 		:= .T.
Local cQuery 		:= "" 
Local cAliasQry	:= "AF490KRGA1"
Local aTamFNV		:= TAMSX3("FNV_VLRPRE")   
Local aArea		:= GetArea()
Local aAreaFNU		:= FNU->(GetArea())
Local aAreaFNW		:= FNW->(GetArea())  
Local nDias		:= 0
Local nSldDesc		:= 0
Local nIndCorAvp	:= 0
Local nSldAtu		:= 0
Local nValAvp		:= 0
Local nTotVlDis	:= 0
Local nSldIni		:= 0
Local lPrimeiro	:= .T.

Default lProvAcm := .F.

If Select("TRBAVP") > 0

	//--------------------------------------------------------------------
	//Query na FNW para obter movimentos do controle de provisao
	//
	cQuery := "SELECT FNW_COD, FNW_REV, FNW_PERIOD, FNW_OCOR, FNW_VALOR, FNW_DTMOV "
	cQuery += " FROM " + RetSQLTab('FNW')
	cQuery += " WHERE "
	cQuery += 		"FNW_COD    = '" + cCod	+ "' AND "
	cQuery += 		"FNW_REV    = '" + cRev + "' AND "
	cQuery += 		RetSqlCond("FNW")
	cQuery += "ORDER BY FNW_FILIAL,FNW_COD,FNW_REV,FNW_PERIOD,FNW_OCOR"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	TcSetField(cAliasQry,"FNW_DTMOV","D")	
	TcSetField(cAliasQry,"FNW_VALOR","N",aTamFNV[1],aTamFNV[2])	

	dbSelectArea(cAliasQry)
	
	While (cAliasQry)->(!EOF())

		lRec := !((cArqTrb)->(MsSeek((cAliasQry)->FNW_PERIOD)))
		
		Reclock(cArqTrb,lRec)
		(cArqTrb)->PERIODO   := (cAliasQry)->FNW_PERIOD
		(cArqTrb)->DTPERIODO := (cAliasQry)->FNW_DTMOV
		
		// Marca o primeiro registro pois esse é de saldo acumulado e tem tratamento diferenciado
		If lProvAcm .And. lPrimeiro
			(cArqTrb)->MOVACM := '1'
			lPrimeiro := .F.
		EndIf
		
		DO CASE
			CASE (cAliasQry)->FNW_OCOR == '01'
				(cArqTrb)->VLDISTRIB := (cAliasQry)->FNW_VALOR
			
			CASE (cAliasQry)->FNW_OCOR == '02'
				(cArqTrb)->PRVPERIODO := (cAliasQry)->FNW_VALOR

			CASE (cAliasQry)->FNW_OCOR == '03'
				(cArqTrb)->RLZPERIODO := (cAliasQry)->FNW_VALOR

			CASE (cAliasQry)->FNW_OCOR == '04'
				(cArqTrb)->CPLPERIODO := (cAliasQry)->FNW_VALOR

			CASE (cAliasQry)->FNW_OCOR == '05'
				(cArqTrb)->REVPERIODO := (cAliasQry)->FNW_VALOR

		END CASE

		(cArqTrb)->(MsUnlock())

		(cAliasQry)->(dbSkip())

	Enddo

	(cAliasQry)->(dbCloseArea())
	

	//--------------------------------------------------------------------
	//Query na FNV para obter valor presente planejado
	//
	cQuery := "SELECT FNV_DTFIN, FNV_VLRPRE "
	cQuery += " FROM " + RetSQLTab('FNV')
	cQuery += " WHERE "
	cQuery += 		"FNV_COD    = '" + cCod	+ "' AND "
	cQuery += 		"FNV_REV    = '" + cRev + "' AND "
	cQuery += 		"FNV_VLRPRE > 0 AND "
	cQuery += 		RetSqlCond("FNV")
	
	cQuery += "ORDER BY FNV_FILIAL,FNV_COD,FNV_REV,FNV_DTFIN"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	TcSetField(cAliasQry,"FNV_DTFIN","D")	
	TcSetField(cAliasQry,"FNV_VLRPRE","N",aTamFNV[1],aTamFNV[2])

	dbSelectArea(cAliasQry)
	DbGotop()
	
	While (cAliasQry)->(!EOF())

		cPeriodo := Substr(Dtos((cAliasQry)->FNV_DTFIN),1,6)

		If (cArqTrb)->(MsSeek(cPeriodo))
					
			//Gravo valor presente planejado do periodo
			Reclock(cArqTrb,.F.)
			(cArqTrb)->VLPRESPLAN 	:= (cAliasQry)->FNV_VLRPRE
	
			(cArqTrb)->(MsUnlock())			

			(cAliasQry)->(dbskip())	
		Endif
	EndDo
	
	(cAliasQry)->(dbCloseArea())       



	//--------------------------------------------------------------------
	//Campos calculados do TRB	
	//
	dbSelectArea(cArqTRB)
	DbGotop()

	While (cArqTRB)->(!EOF())

		nIndCorAvp := Af490IndAvp(cCod,cRev,(cArqTrb)->DTPERIODO,@nDias)
		
		If nIndCorAvp > 9999
			Help("  ",1,"AF490POSV5",,STR0135,1,0)//"Valor inválido. Por favor verificar o cadastro do Controle de Provisão" 
			lRet := .F.
			Exit
		EndIf
		
		//Saldo Descontado
		nSldDesc := ((cArqTrb)->VLDISTRIB + nTotVlDis) - (cArqTrb)->VLPRESPLAN
		
		//Saldo Atualizado
		nSldAtu	:= nSldDesc * nIndCorAvp
		//Retirada tratamento para numeros negativo pois existem situações que o AVP fica negativo 
		//nSldAtu    := If(nSldAtu > 0, nSldAtu, 0) :TODO:
		 
		If (cArqTrb)->MOVACM != '1'
			//Avp do Periodo
			nValAvp := nSldAtu - ( nSldIni + (cArqTrb)->PRVPERIODO - (cArqTrb)->RLZPERIODO + (cArqTrb)->CPLPERIODO - (cArqTrb)->REVPERIODO )
			//Retirada tratamento para numeros negativo pois existem situações que o AVP fica negativo 
			//nValAvp := If(nValAvp < 0.99, 0, nValAvp)  :TODO:
		EndIf
		
		Reclock(cArqTrb,.F.)
		(cArqTrb)->SLDDESCONT 	:= nSldDesc		
		(cArqTrb)->QTDEDIAS 	    := nDias
		(cArqTrb)->INDCORAVP	    := Round(nIndCorAvp,6)
		(cArqTrb)->SLDATUALIZ	:= Round(nSldAtu,2)
		(cArqTrb)->SLDINICIAL	:= Round(nSldIni,2)	
		(cArqTrb)->AVPPERIODO	:= Round(NoRound(nValAvp,3),3)			
		(cArqTrb)->(MsUnlock())
				
 		//Somo o valor distribuido no periodo
		nTotVlDis += (cArqTrb)->VLDISTRIB - (cArqTrb)->VLPRESPLAN
 		//Guardo o valor do saldo atualizado
		nSldIni := (cArqTrb)->SLDATUALIZ

		(cArqTRB)->(dbskip())	

	EndDo
Else
	lRet := .F.
Endif	

RestArea(aAreaFNW)
RestArea(aAreaFNU)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ Af490IndAvp³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 22/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Obtém o indice de correcao do AVP                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Af490IndAvp()											   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ cCod     - Codigo do controle de provisao				   ³±±
±±³           ³ cRev     - Revisao do controle de provisao				   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Af490IndAvp(cCod,cRev,dDataFin,nDias)

Local cIndAvp	:= ""
Local cPeriodo	:= ""
Local nDiasInd	:= 0 
Local nIndAvp	:= 0
Local nDiasPer := 0

DEFAULT cCod	 := ""
DEFAULT cRev 	 := ""



If !Empty(cCod) .and. !Empty(cRev)

	FNU->(dbSetOrder(1))
	FNU->(MsSeek(xFilial("FNU")+cCod+cRev))
	
	cIndAvp := FNU->FNU_INDAVP
	nTaxAvp := FNU->FNU_TAXAVP
	nDiasPer := AtfDiasAvp(FNU->FNU_DTAVP,dDataFin,.T.)
	
	cPeriodo := GetAdvFVal("FIT","FIT_PERIOD", xFilial("FIT") + cIndAvp)
	
	DO CASE
		CASE cPeriodo = "1"	//Diario
			nDiasInd := 1
		CASE cPeriodo = "2"	//Mensal
			nDiasInd := 30
		CASE cPeriodo = "3"	//Trimestra
			nDiasInd := 90
		CASE cPeriodo = "4"	//Semestral
			nDiasInd := 180
		CASE cPeriodo = "5"	//Anual
			nDiasInd := 360
		OTHERWISE
			nDiasInd := 0
	ENDCASE
	
	//Converto a Taxa informada para taxa diaria
	nIndDia := (1+(nTaxAvp/100))**(1/nDiasInd) //Taxa equivalente
	
	//Valor Presente
	nIndAVP	:= (nIndDia**nDiasPer)
	nDias 		:= nDiasPer
Endif 

Return nIndAVP		


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ AF490DelFnw³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 22/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Exclui movimentos do controle de provisao quando houver    ³±±
±±³           ³ nova atualizacao do controle de provisao				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ AF490DelFnw(cCodPrV,cRev)								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ cCod     - Codigo do controle de provisao				   ³±±
±±³           ³ cRev     - Revisao do controle de provisao				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AF490DelFnw(cCodPrV,cRev,dDataIni,dDataFim,aOcorr)
Local aArea	 := GetArea()
Local cQuery := ""
Local cAliasQry := "AF490DEL"
Local nX         := 0
Local cOcorr     := ""
Local lRet	 := .T.

Default dDataIni := cTod("")
Default dDataFim := cTod("")
Default aOcorr   := {}

cQuery := "SELECT R_E_C_N_O_ FNWRECNO "
cQuery += " FROM " + RetSQLTab('FNW')
cQuery += " WHERE "
cQuery += 		" FNW_COD    = '" + cCodPrv	+"' "
cQuery += 		" AND FNW_REV = '" + cRev +"' "

If !Empty(dDataIni)
	cQuery += 		" AND FNW_DTMOV >= '" + DTOS(dDataIni) +"' "
EndIf 

If !Empty(dDataFim)
	cQuery += 		" AND FNW_DTMOV <= '" + DTOS(dDataFim) +"' "
EndIf 

If !Empty(aOcorr)
	For nX := 1 to Len(aOcorr)
		cOcorr += aOcorr[nX] + IIf(nX < Len(aOcorr),  "/" ,"")
	Next nX
	
	cQuery += 		" AND FNW_OCOR IN " + FormatIn(cOcorr,"/") +" "
EndIf
cQuery += " AND FNW_LA = '' "
cQuery += " AND " + RetSqlCond("FNW")

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
dbSelectArea(cAliasQry)


//Utilizado para verificacao da efetivacao de realizacao.
//Nos demais casos sempre sera .T.
If __nOper == OPER_EFETREAL
	lRet := .F.
Endif

While (cAliasQry)->(!EOF())

	//Registros serao deletados
	lRet := .T.

	FNW->(DbGoto( (cAliasQry)->(FNWRECNO) ))

	RecLock("FNW",.F.)
	FNW->(dbDelete())
	FNW->(MsUnlock())
	
	(cAliasQry)->(dbSkip())	
EndDo

(cAliasQry)->(dbCloseArea())

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ AF490Curto ³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 24/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Verifica se a data de referencia eh de curto prazo         ³±±
±±³           ³ Calcula a data de inicio do periodo de curto prazo		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ AF490Curto(dDtRef,dDtFinPrv)							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ dDtRef - Data a qual quer se verificar se eh de curto prazo³±±
±±³           ³ dDtFinPrv - Data final da provisao         				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Array[1] = variavel logica indicando se eh curto prazo     ³±±
±±³           ³ Array[2] = Data de inicio do periodo de curto prazo		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490Curto(dDtRef,dDtFinPrv)

Local nDiasCurto := SuperGetMv("MV_ATFPROV",.F.,365)
Local dDtCurto := CTOD("//")

DEFAULT dDtRef 	  := CTOD("//")
DEFAULT dDtFinPrv := CTOD("//")

//Calculo da data de curto prazo
dDtCurto := dDtFinPrv - ( nDiasCurto + 1) // Ano Bisexto

lCurto := If(dDtRef >= dDtCurto, .T., .F.)
	
//Retorno o inicio do periodo do curto prazo
dDtCurto := FirstDay(dDtCurto)
                                                         
Return {lCurto,dDtCurto}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ AF490TrfCP ³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 24/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Calcula o valor dos movimentos de transferencia para curto ³±±
±±³           ³ prazo.                                  				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ AF490TrfCP(cCodPrV,cRev,dCurto)							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ cCodPrv  - Codigo do controle de provisao				   ³±±
±±³           ³ cRev     - Revisao do controle de provisao				   ³±±
±±³           ³ cCurto   - Data de inicio do periodo de curto prazo		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490TrfCP(cCodPrv,cRev,dCurto)

Local cQuery := ""
Local aTotais := {}
Local cAliasQry	:= "AF490TRF"
Local aTamFNW	:= TamSx3("FNW_VALOR")

DEFAULT cCodPrv := ""
DEFAULT cRev := ""
DEFAULT dCurto := CTOD("//")

If !Empty(cCodPrv) .and. !Empty(cRev) .and. !Empty(dCurto)

	cQuery := "SELECT FNW_VALOR, FNW_DTMOV, FNW_OCOR "
	cQuery += " FROM " + RetSQLTab('FNW')
	cQuery += " WHERE "
	cQuery += 		"FNW_COD    = '" + cCodPrv		+ "' AND "
	cQuery += 		"FNW_REV    = '" + cRev     	+ "' AND "  
	cQuery +=		"FNW_DTMOV	< '" + Dtos(dCurto)	+ "' AND "  	
	cQuery += 		RetSqlCond("FNW")
	cQuery += "ORDER BY FNW_FILIAL,FNW_COD,FNW_REV,FNW_PERIOD,FNW_OCOR"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	TcSetField(cAliasQry,"FNW_DTMOV","D")	
	TcSetField(cAliasQry,"FNW_VALOR","N",aTamFNW[1],aTamFNW[2])	

	dbSelectArea(cAliasQry)
	DbGotop()
	
	While (cAliasQry)->(!EOF())

		cOcor := Alltrim(STR(Val((cAliasQry)->FNW_OCOR )+10))
		nPos := aScan(aTotais,{|x| AllTrim(x[1]) == cOcor })

		If nPos == 0
			Aadd(aTotais,{cOcor , 0})
			nPos := Len(aTotais)
		Endif

		aTotais[nPos][2] += (cAliasQry)->FNW_VALOR
			
		(cAliasQry)->(dbSkip())

	Enddo

	(cAliasQry)->(dbCloseArea())

Endif

Return (aTotais)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFA490CTB  ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 24/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a contabilizacao dos movimentos gerados pela rotina³±±
±±³          ³ de atualizacao.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490ICTB()
	AFA490CTB(1) // Inclusão
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFA490ECTB ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 24/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Estorna a contabilizacao dos movimentos gerados pela rotina³±±
±±³          ³ de atualizacao.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490ECTB(cAlias,nReg,nOpc)

AFA490CTB(2) // Estorno

Return 
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AFA490CTB  ³ Autor ³Mauricio Pequim Jr.  ³ Data ³ 24/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a contabilizacao dos movimentos gerados pela rotina³±±
±±³          ³ de atualizacao.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAATF                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFA490CTB(nOpc)
Local aArea			:= GetArea()
Local cPerg			:= "ATFA490"
Local cOcorSel			:= ""
Local lMostra   		:= .F.
Local lAglutina 		:= .F.
Local dDataIni  		:= CTOD("")
Local dDataFim  		:= CTOD("")
Local cProvIni  		:= ""
Local cProvFim  		:= ""
Local lRet				:= .T.
Local lSelecao			:= .F.

Default nOpc			:= 1

If lRet
	// Carrega fun‡„o Pergunte
	If Pergunte( cPerg , .T. )
		If mv_par05 == 1 .And. !IsBlind()
			cOcorSel := AFSelTpPrv(@lSelecao)
			If Empty( cOcorSel )
				If lSelecao
					Help(" ",1,"AF490GETOC",,STR0131,1,0) //"Favor selecionar ao menos uma Ocorência"
				Endif
				Return
			EndIf
		Endif		
		lMostra   := MV_PAR01 == 1
		lAglutina := MV_PAR02 == 1
		dDataIni  := MV_PAR03
		dDataFim  := MV_PAR04
		cProvIni  := MV_PAR06
		cProvFim  := MV_PAR07

		MsgRun( STR0091 ,, {|| AF490CtbMv(nOpc,,,lMostra,lAglutina,dDataIni,dDataFim,cProvIni,cProvFim,cOcorSel) } ) // "Contabilizando movimentos do Controle de Provisão..."
	EndIf

EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ AF490CtbMv ³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 24/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Contabiliza os movimentos do controle de provisao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ AF490CtbMv(nProc,cCodPrV,cRev)							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ nProv   - numero do processo a ser realizado			   ³±±
±±³           ³ cCodPrv - Codigo do controle de provisao				   ³±±
±±³           ³ cRev    - Revisao do controle de provisao				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490CtbMv(nOpc,cCodPrv,cRev,lMostra,lAglutina,dDataIni,dDataFim,cProvIni,cProvFim,cOcorSel)

Local lRet := .F.
Local aArea := GetArea()
Local cQuery := ""
Local cAliasQry := "AF490CTB" 
Local nX := 0

Local nHdlPrv  := 0
Local lEnd     := .T.
Local nTotal   := 0
Local nRegs := 0
Local nCont := 0
Default cCodPrv := ""
Default cRev	  := ""
Default cOcorSel:= ""

If !Empty(cCodPrv)
	AF490Contab(nOpc,cCodPrv,cRev,lMostra,lAglutina,dDataIni,dDataFim,,,,cOcorSel)
Else
	// 1 vez faz a contagem dos registros, na segunda realiza a operação
	For nX := 1 to 2
		cQuery := ""
		cQuery += " SELECT  " + CRLF
		If nX == 1
			cQuery += "  COUNT(*) CONT    " + CRLF
		Else
			cQuery += "     FNU_COD,   " + CRLF
			cQuery += "     FNU_REV   " + CRLF
		EndIf
		
		cQuery += " FROM " + RetSQLName("FNU") + CRLF
		cQuery += " WHERE  " + CRLF
		cQuery += "     FNU_FILIAL = '"+xFilial("FNU")+"' AND  " + CRLF
		cQuery += "     FNU_COD    >= '"+cProvIni+"' AND  " + CRLF
		cQuery += "     FNU_COD    <= '"+cProvFim+"' AND  " + CRLF
		cQuery += "     FNU_STATUS IN ('1','2') AND" + CRLF
		cQuery += "     FNU_MSBLQL != '1' AND  " + CRLF
		cQuery += "     D_E_L_E_T_ = ''  " + CRLF
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		dbSelectArea(cAliasQry)
		If nX == 1
			nRegs := (cAliasQry)->CONT
		Else
			While (cAliasQry)->(!EOF())
				nCont++
				lEnd := nCont == nRegs
				AF490Contab(nOpc,(cAliasQry)->FNU_COD,(cAliasQry)->FNU_REV,lMostra,lAglutina,dDataIni,dDataFim,@nHdlPrv,lEnd,@nTotal,cOcorSel)
				(cAliasQry)->(dbSkip())
			Enddo
		EndIf
		(cAliasQry)->(dbCloseArea())
	Next nX
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ AF490Contab ³ Autor ³ Mauricio Pequim Jr ³ Data ³ 24/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Contabiliza os movimentos do controle de provisao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490Contab(nProc,cCodPrv,cRev,lMostra,lAglutina,dDataIni,dDataFim,nHdlPrv,lEnd,nTotal,cOcorSel)

Local cPadrao := ""
Local aRegs := {}
Local aArea := GetArea()
Local aAreaFNW := FNW->(GetArea())
Local cFlagCtb  := ""
Local cFlagProv  := ""

Default cCodPrv := "" 
Default cRev	  := ""  
Default nHdlPrv := 0
Default lEnd    := .T.
Default nTotal := 0
Default cOcorSel:= ""

If nProc == 1	//Movimentos de Provisao
	cPadrao := "881"
	cFlagCtb  := "1"
	cFlagProv := "2"
	
	//Encontro os registros a processar
	aRegs := AF490Dados(nProc,cCodPrv,cRev,dDataIni,dDataFim,,cOcorSel)


ElseIf nProc == 2		//Estorno dos movimentos de Provisao
	cPadrao := "882"
	cFlagCtb  := " "
	cFlagProv := "1"
	//Encontro os registros a processar
	aRegs := AF490Dados(nProc,cCodPrv,cRev,dDataIni,dDataFim,,cOcorSel)
	
ElseIf nProc == 3		//Revisao de controle de provisao
	cPadrao := "883"
	cFlagCtb  := "2"
	cFlagProv := "0"
	aRegs := AF490Dados(nProc,cCodPrv,cRev,,,.F.)
Endif

//Efetivo a contabilização
AF490CtbPrv(aRegs,cPadrao,cFlagCtb,lMostra,lAglutina,@nHdlPrv,lEnd,@nTotal)


//Verifico se sobrou algum registro contabilizad para o controle de provisao
//Se nao existir, volto o status para Atualizado
If nProc == 2
	aRegs := AF490Dados(3,cCodPrv,cRev)
	If Len(aRegs) == 0
		//Altera o Status para Atualizado
		AF490FLAG(cCodPrv,cRev,cFlagProv)
	Endif
Else
	//Altera o Status para Efetivado
	aRegs := AF490Dados(3,cCodPrv,cRev)
	If Len(aRegs) > 0
		AF490FLAG(cCodPrv,cRev,cFlagProv)
	EndIf
EndIf



RestArea(aAreaFNW)
RestArea(aArea)

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ AF490Dados ³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 24/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Seleciona registros de movimento do controle de provisao   ³±±
±±³           ³ a serem contabilizados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ AF490Dados(nProc,cCodPrV,cRev)							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ nProc   - numero do processo a ser realizado			   ³±±
±±³           ³ cCod    - Codigo do controle de provisao				   ³±±
±±³           ³ cRev    - Revisao do controle de provisao				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490Dados(nProc,cCod,cRev,dPerIni,dPerFin,lFiltraPer,cOcorSel)

Local cQuery  := ""
Local aRecnos := {}
Local cAliasQry := "AF490DATA" 
Local aArea		:= GetArea()

Default dPerIni   := Nil
Default dPerFin   := Nil
Default lFiltraPer:= .T.
Default cOcorSel := ""

//----------------------------------------------------------------------------
//Query na FNW para obter movimentos do controle de provisao a contabilizar
//
If nProc == 1 
	cQuery := "SELECT R_E_C_N_O_ RECNOFNW "
	cQuery += " FROM " + RetSQLTab('FNW')
	cQuery +=  "WHERE "
	cQuery += 		" FNW_COD    = '" + cCod	+ "' "
	cQuery += 		" AND FNW_REV    = '" + cRev + "' "
	If lFiltraPer
		cQuery += 		" AND FNW_DTMOV  BETWEEN  '" + Dtos(dPerIni) + "'AND '" + Dtos(dPerFin) + "' "
	EndIf
	cQuery += 		" AND FNW_LA = ' ' AND "		
	cQuery += 		RetSqlCond("FNW")
	If !Empty(cOcorSel)
		cQuery += 		" AND FNW_OCOR IN " + FormatIn(cOcorSel,"/") + " "
	EndIf
	cQuery += " ORDER BY FNW_FILIAL,FNW_COD,FNW_REV,FNW_PERIOD,FNW_OCOR "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	While (cAliasQry)->(!EOF())
		aadd(aRecnos,(cAliasQry)->RECNOFNW)
		(cAliasQry)->(dbSkip())
	Enddo
	
	(cAliasQry)->(dbCloseArea())

Endif	

//----------------------------------------------------------------------------
//Query na FNW para obter movimentos do controle de provisao ja contabilizados
//
If nProc == 2 
	cQuery := "SELECT R_E_C_N_O_ RECNOFNW "
	cQuery += " FROM " + RetSQLTab('FNW')
	cQuery += " WHERE "
	cQuery += 		"FNW_COD    = '" + cCod	+ "' AND "
	cQuery += 		"FNW_REV    = '" + cRev + "' AND "
	cQuery += 		"FNW_DTMOV  BETWEEN  '" + Dtos(dPerIni) + "'AND '" + Dtos(dPerFin) + "' AND "
	cQuery += 		"FNW_LA = '1' AND "	
	cQuery += 		RetSqlCond("FNW")
	If !Empty(cOcorSel)
		cQuery += 		" AND FNW_OCOR IN " + FormatIn(cOcorSel,"/") + " "
	EndIf	
	cQuery += "ORDER BY FNW_FILIAL,FNW_COD,FNW_REV,FNW_PERIOD,FNW_OCOR"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)

	While (cAliasQry)->(!EOF())
		aadd(aRecnos,(cAliasQry)->RECNOFNW)
		(cAliasQry)->(dbSkip())
	Enddo
	
	(cAliasQry)->(dbCloseArea())

Endif	

//----------------------------------------------------------------------------
//Query na FNW para obter movimentos do controle de provisao ja contabilizados
//Utilizado na revisao
If nProc == 3
	cQuery := "SELECT R_E_C_N_O_ RECNOFNW "
	cQuery += " FROM " + RetSQLTab('FNW')
	cQuery += " WHERE "
	cQuery += 		"FNW_COD    = '" + cCod	+ "' AND "
	cQuery += 		"FNW_REV    = '" + cRev + "' AND "
	cQuery += 		"FNW_LA = '1' AND "		
	cQuery += 		RetSqlCond("FNW")
	cQuery += "ORDER BY FNW_FILIAL,FNW_COD,FNW_REV,FNW_PERIOD,FNW_OCOR"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)

	While (cAliasQry)->(!EOF())
		aadd(aRecnos,(cAliasQry)->RECNOFNW)
		(cAliasQry)->(dbSkip())
	Enddo
	
	(cAliasQry)->(dbCloseArea())

Endif	

//----------------------------------------------------------------------------
//Query na FNX para obter realizacoes pendentes
//Utilizado no estorno de efetivacao de revisao para alterar o status da provisao
If nProc == 4
	cQuery := "SELECT R_E_C_N_O_ RECNOFNX "
	cQuery += " FROM " + RetSQLTab('FNX')
	cQuery += " WHERE "
	cQuery += 		"FNX_COD    = '" + cCod	+ "' AND "
	cQuery += 		"FNX_REV    = '" + cRev + "' AND "
	cQuery += 		"FNX_DTCONT = ' ' AND "		
	cQuery += 		RetSqlCond("FNX")
	cQuery += "ORDER BY FNX_FILIAL,FNX_COD,FNX_REV,FNX_DTMOV"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	While (cAliasQry)->(!EOF())
		aadd(aRecnos,(cAliasQry)->RECNOFNX)
		(cAliasQry)->(dbSkip())
	Enddo
	
	(cAliasQry)->(dbCloseArea())

Endif	

RestArea(aArea)

Return aRecnos



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF490CtbPrv ³ Autor ³ Mauricio Pequim Jr ³ Data ³ 24.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processo de contabilizacao off-line dos movimentos do      ³±±
±±³          ³ controle de provisao                 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA490													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490CtbPrv(aRecCTB,cPadrao,cFlag,lMostra,lAglutina,nHdlPrv,lEnd,nTotal)

Local nX		:= 0
Local cArquivo	:= ''
Local cLoteAtf := ""
Local lPadrao   := VerPadrao(cPadrao)
Local aArea		:= GetArea()

PRIVATE LanceiCtb := .F.

Default aRecCTB := {}
Default cPadrao := ""
Default cFlag	  := ""
Default lMostra := .F.
Default lAglutina := .F.
Default nHdlPrv := 0
Default lEnd    := .T.
Default nTotal := 0

FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV

If Len(aRecCTB) > 0 .and. lPadrao
	
	dbSelectArea("FNW")
	cLoteAtf    := LoteCont("ATF")
	BEGIN TRANSACTION
		
		For nX := 1 to Len(aRecCTB)
			
			FNW->(dbGoto(aRecCTB[nX]))
			FNU->(MsSeek( xFilial("FNU") + FNW->(FNW_COD+FNW_REV) ))
			
			If lPadrao
				
				//Verifico Handle de contabilizacao
				If ValType(nHdlPrv) != "N" .Or. nHdlPrv <= 0
					nHdlPrv := HeadProva(cLoteAtf,"ATFA490",Substr(cUsername,1,6),@cArquivo)
				EndIf
				
				If nHdlPrv > 0
					//Verifico o uso de Flag contabil automatico
					nTotal +=	DetProva(nHdlPrv,cPadrao,"ATFA490",cLoteAtf)
					
					If LanceiCtb // Vem do DetProva
						RecLock("FNW")
						FNW->FNW_LA  := cFlag
						MsUnlock( )
					EndIf
				Endif
			Endif
		Next

	END TRANSACTION
	
Endif

//Fecha contabilizacao para o processo de apuracao de AVP
//Quando esta rotina for chamada de outro processo, a contabilizacao sera fechada
//apenas na rotina de chamada.
If lEnd .And. nHdlPrv > 0 .And. nTotal > 0
	RodaProva(nHdlPrv, nTotal)
	cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,lMostra,lAglutina)
Endif	

RestArea(aArea)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA490REV ºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a revisão do controle de provisao                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490REV(cAlias,nReg,nOpc)
Local aArea		:= GetArea()
Local lConfirma	:= .F.
Local lCancela	:= .F.
Local cTitulo		:= ""
Local cPrograma	:= ""
Local nOperation	:= 0
Local cCodPrv		:= FNU->FNU_COD
Local cRev			:= FNU->FNU_REV
Local lRet			:= .T.
Local aButtons	:= {}
Local bCancel		:= {|| A490ConfVs() }

If FNU->FNU_MSBLQL == "1"  //Registro Bloqueado
	Help(" ",1,"AF490REVB",,STR0108+CRLF+STR0109,1,0)//"Não é possivel revisar controle de provisão que estajam bloqueadas."##"Desbloqueie o controle de provisão, se possível, antes de revisá-la." 
	lRet := .F.
ElseIf FNU->FNU_STATUS == '3' //Registro revisado
	Help(" ",1,"AF490REVR",,STR0110+CRLF+STR0111,1,0)//"Não é possivel revisar controle de provisão que possuam revisão posterior"##"Apenas revisões ativas são passíveis de revisão." 
	lRet := .F.
ElseIf !(FNU->FNU_STATUS $ '1/2') //Registro ativo ou efetivado
	Help(" ",1,"AF490REVA",,STR0027,1,0)  //"Não é possivel revisar controle de provisão com esse status"
	lRet := .F.
EndIf

If lRet
	lRet := Pergunte("ATFA490A",.T.)
EndIf

If lRet
	cTitulo         := STR0074   //'Revisar'
	cPrograma 		:= 'ATFA490'
	nOperation 		:= MODEL_OPERATION_VIEW		 	// Visualizar
	__lConfirmar 	:= .F.
	__lBTNConfirma  := .T.
	__nOper 		:= OPER_REVISAR
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0141},{.T.,STR0140},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar"##"Confirmar"
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, /*bOk*/ , /*nPercReducao*/, aButtons, bCancel )
	
	If __lConfirmar
		MsgRun( STR0028 ,, {||	lRet := AF490REVGR(cCodPrv,cRev) } )  //"Processando revisão do Controle de Provisão..."
	EndIf
EndIf

__nOper := 0
__lConfirmar    := .F.
__lBTNConfirma  := .F.

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490REVGRºAutor  ³Mauricio Pequim Jr. º Data ³  10/27/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a revisao do controle de provisao					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490REVGR(cCodPrV,cRev)

Local aArea			:= GetArea()
Local lRet			:= .T.

Pergunte("ATFA490A",.F.)
	
Begin Transaction
	
	//Altera o Status da Revisão anterior para Bloqueado por Revisão
If lRet
	lRet := AF490CriaRev(cCodPrV,cRev)
	cRevNov := AF490GetRev(cCodPrV,.f.)
	AF490DTREV(cCodPrV,cRevNov,dDataBase)
EndIf

// Realiza o lançamento de revisao dos movimentos na contabilidade
If lRet
	AF490CtbMv(3,cCodPrv,cRev,MV_PAR01 == 1,MV_PAR02 == 1)
EndIf
	
	//Altera o Status da Revisão anterior para Revisado
If lRet
	AF490FLAG(cCodPrv,cRev,"3")
	AF490FLAG(cCodPrV,cRevNov,"0")
EndIf
	
If !lRet
	DisarmTransaction()
EndIf
	
End Transaction
	
RestArea(aArea)


Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490CriaRevºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a nova revisao do cadastro de provisao                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490CriaRev(cCodPrv,cRev)
Local lRet 	:= .T.
Local aArea := GetArea()
Local oModel:= Nil
Local aErro	:= {}

DEFAULT cCodPrv := ""
DEFAULT cRev := ""

__nOper := OPER_REVISAR

dbSelectArea("FNU")
FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV
If FNU->(MsSeek(xFilial("FNU") + cCodPrv + cRev))
	oModel := FWLoadModel( 'ATFA490' )
	oModel:SetOperation( 3 ) // Inclusão
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
	If ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		oModel:CommitData()
	Else
		aErro   := oModel:GetErrorMessage()	
	Endif
	// Desativamos o Model
	oModel:DeActivate()
EndIf


__nOper := 0

RestArea(aArea)
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490DTREVºAutor  ³Mauricio Pequim Jr. º Data ³  08/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a data de revisão do controle de provisao            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490DTREV(cCodPrV,cRev,dData)

Local aArea		:= GetArea()
Local aAreaFNU	:= FNU->(GetArea())

Default dData  := dDataBase

FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV
FNV->(dbSetOrder(1)) //FNV_FILIAL+FNV_COD+FNV_REV+FNV_ITEM
FNX->(dbSetOrder(3)) //FNX_FILIAL+FNX_COD+FNX_REV+FNX_LINHA+FNX_CBASE+FNX_ITEM+FNX_TIPO+FNX_TPSALD

If FNU->(MsSeek( xFilial("FNU") + cCodPrV + cRev ))
	RecLock("FNU",.F.)
	FNU->FNU_DTREV := dData
	MsUnLock()
EndIf
	
// Limpa a data de efetivação da realização
If FNX->(MsSeek(xFilial("FNX") + cCodPrV + cRev ))
	While FNX->(!EOF()) .And. FNX->(FNX_FILIAL+FNX_COD+FNX_REV) == xFilial("FNX") + cCodPrV + cRev
		RecLock("FNX",.F.)
			FNX->FNX_DTCONT := CTOD("")
		MsUnLock()
		FNX->(dbSkip())
	EndDo
EndIf

// Limpa a data de efetivação da realização
If FNV->(MsSeek(xFilial("FNV") + cCodPrV + cRev ))
	While FNV->(!EOF()) .And. FNV->(FNV_FILIAL+FNV_COD+FNV_REV) == xFilial("FNV") + cCodPrV + cRev 
		RecLock("FNV",.F.)
			FNV->FNV_RLZEFT := '2'
		MsUnLock()
		FNV->(dbSkip())
	EndDo
EndIf
	
RestArea(aAreaFNU)
RestArea(aArea)
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490GetRev ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 06/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a ultima revisão da regra de margem gerencial       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA490                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF490GetRev(cCodPrv,lProx)

Local aArea    := GetArea()
Local aAreaFNU := FNU->(GetArea())
Local cQuery   := ""
Local cAliasQry := "AF490REV"
Local cRevisao := ""

Default lProx := .T.

cQuery := " SELECT MAX(FNU_REV) CREV FROM " + RetSQLTab("FNU")+ " WHERE "
cQuery += " FNU_COD  = '" + cCodPrv          +"' AND "
cQuery += RetSQLCond("FNU")
cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )

If (cAliasQry)->(!EOF())
	If lProx
		cRevisao := Soma1( (cAliasQry)->CREV , Len(FNU->FNU_REV) )
	Else
		cRevisao := (cAliasQry)->CREV
	EndIf
EndIf

(cAliasQry)->(dbCloseArea())

RestArea(aAreaFNU)
RestArea(aArea)

Return cRevisao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490INCODºAutor  ³Mauricio Pequim Jr. º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o código do controle de provisao caso seja uma      º±±
±±º          ³operacao de revisão                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490INCOD()
Local cCodPrv		:= ""

If __nOper == OPER_REVISAR
	cCodPrv		:= FNU->FNU_COD
EndIf

Return cCodPrv

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490INREVºAutor  ³Mauricio Pequim Jr. º Data ³  24/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a revisão do projeto conforme operação              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490INREV()
Local cRevisao 		:= STRZERO(1,TamSx3("FNU_REV")[1] )
Local aArea			:= GetArea()
Local aAreaFNU		:= FNU->(GetArea())
Local cCodPrV		:= ""

FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV

If __nOper == OPER_REVISAR
	cCodPrv  := FNU->FNU_COD
	cRevisao := AF490GetRev(cCodPrV)
EndIf

RestArea(aAreaFNU)
RestArea(aArea)
Return cRevisao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490VLATFºAutor  ³Alvaro Camillo Neto º Data ³  24/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao dos campos de codigo base e item                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF490VLATF()
Local lRet     := .T.
Local aArea    := GetArea()
Local oModel   := FWModelActive()
Local cBase    := oModel:GetValue("FNXDETAIL","FNX_CBASE")
Local cItem    := oModel:GetValue("FNXDETAIL","FNX_ITEM")
Local cTpSaldo := oModel:GetValue("FNUMASTER","FNU_TPSALD") 
Local cProv    := oModel:GetValue("FNUMASTER","FNU_COD") 

//N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
If !Empty(cItem)
	lRet := ExistCpo( "SN3", cBase + cItem + '10' + '0' + cTpSaldo , 11 )
EndIf

If lRet
	SN1->(dbSetOrder(1))	//N1_FILIAL+N1_CBASE+N1_ITEM
	SN1->(dbSeek(xFilial("SN1") + cBase + cItem ))
	If Alltrim(SN1->N1_PROVIS) != Alltrim(cProv)
		Help(" ",1,"AF490SN1PROV",,STR0112,1,0)  //"O ativo não está relacionado a provisão"	
	EndIf 
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtFVlEsEf ºAutor  ³Alvaro Camillo Neto º Data ³  24/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação da operação de efetivação, irá verificar se existe 
±±º          ³um movimento posterior ao periodo, bloqueando a operação    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtFVlEsEf(cCodPrv, cRev, dData)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := "TRB490RLZ"
Local cPosterior:= DTOS(LastDay(dData) + 1)
Local aArea     := GetArea()

DEFAULT cCodPrv := ""
DEFAULT cRev	  := ""


//Query na FNX para obter movimentos de realização no periodo posterior
cQuery := " SELECT MAX(FNX_DTCONT) ULTREAL "
cQuery += " FROM " + RetSQLTab('FNX')
cQuery += " WHERE "
cQuery += 		"FNX_COD    = '" + cCodPrv	+ "' AND "
cQuery += 		"FNX_REV    = '" + cRev     + "' AND "
cQuery += 		"FNX_DTCONT >= '" + cPosterior   + "' AND "
cQuery += 		RetSqlCond("FNX")

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
TcSetField(cAliasQry,"ULTREAL","D")	

dbSelectArea(cAliasQry)
(cAliasQry)->(DbGotop())

If (cAliasQry)->(!EOF())
	If !Empty( (cAliasQry)->ULTREAL )
		lRet := .F.
		Help("  ",1,"ATFVLESEF",,STR0106 + DTOC( (cAliasQry)->ULTREAL ) ,1,0) //"Somente é possível estornar a ultima efetivação: "
	EndIf
EndIf 

(cAliasQry)->(dbCloseArea())

If lRet
	//Query na FNW para obter movimentos de realização do periodo
	cQuery := " SELECT COUNT(*) CONTMOV "
	cQuery += " FROM " + RetSQLTab('FNW')
	cQuery += " WHERE "
	cQuery += 		"FNW_COD    = '"  + cCodPrv + "' AND "
	cQuery += 		"FNW_REV    = '"  + cRev    + "' AND "
	cQuery += 		"FNW_DTEFET >= '" + DTOS(FirstDay(dData))   + "' AND "
	cQuery += 		"FNW_DTEFET <= '" + DTOS(LastDay(dData))    + "' AND "
	cQuery += 		"FNW_OCOR   IN ('03','04','05') AND "
	cQuery += 		RetSqlCond("FNW")
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGotop())
	
	If (cAliasQry)->(!EOF())
		If Empty( (cAliasQry)->CONTMOV )
			lRet := .F.
			Help("  ",1,"ATFVLESEF2",,STR0107 ,1,0) //"Não existe movimento de realização no período corrente, por favor verificar."
		EndIf
	EndIf 
	
	(cAliasQry)->(dbCloseArea())
Endif

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490EstRz ºAutor  ³Alvaro Camillo Neto º Data ³  24/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Operação de estorno de efetivacao da realização  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF490EstRz(cCodPrv,cRev,dData)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := "TRB490ERLZ"
Local aArea     := GetArea()
Local aRegs     := {}
Local nX        := 0
Local dDataMov  := CTOD("")
Local aDtMovs	:= {}
Local aCtb		:= {}
Local aPeriodos := {}
Local dDataPer	:= CTOD("")

DEFAULT cCodPrv := ""
DEFAULT cRev	:= ""
DEFAULT dData	:= dDataBase

FNW->(dbSetOrder(1)) // FNW_FILIAL+FNW_COD+FNW_REV+FNW_PERIOD+FNW_OCOR
FNV->(dbSetOrder(2)) // FNV_FILIAL+FNV_COD+FNV_REV+DTOS(FNV_DTFIN)
FNX->(dbSetOrder(4)) // FNX_FILIAL+FNX_COD+FNX_REV+DTOS(FNX_DTCONT)

Pergunte("ATFA490A",.F.)

dData := LastDay(dData)

//Acho a ultima data dos periodos da provisao
A490Periodos(cCodPrv,cRev,aPeriodos) 
dLastPer := aPeriodos[Len(aPeriodos)]

Begin Transaction

	cQuery := " SELECT R_E_C_N_O_ RECFNW, FNW_LA "
	cQuery += " FROM " + RetSQLTab('FNW')
	cQuery += " WHERE "
	cQuery += 		" FNW_COD    = '"  + cCodPrv + "' AND "
	cQuery += 		" FNW_REV    = '"  + cRev    + "' AND "
	cQuery += 		" FNW_DTEFET  >= '" + DTOS(FirstDay(dData))   + "' AND "
	cQuery += 		" FNW_DTEFET  <= '" + DTOS(LastDay(dData))    + "' AND "
	cQuery += 		" FNW_OCOR   IN ('03','04','05') AND "
	cQuery += 		RetSqlCond("FNW")
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)


	//Realiza o lançamento de estorno e a exclusão do registro
	While (cAliasQry)->(!EOF())
		aAdd(aRegs,(cAliasQry)->RECFNW)
		If !Empty( (cAliasQry)->FNW_LA )
			aAdd(aCtb,(cAliasQry)->RECFNW )	
		Endif
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	//Efetivo a contabilização
	cPadrao := "884"
	AF490CtbPrv(aCtb,cPadrao," ",MV_PAR01 == 1,MV_PAR02 == 1)

	//Realiza a Exclusão do Registro
	For nX := 1 to Len(aRegs)
		FNW->(dbGoTo(aRegs[nX]))

		If (nPos :=  aScan(aDtMovs,{|x| x == FNW->FNW_DTMOV }) ) == 0
			AADD(aDtMovs,FNW->FNW_DTMOV) 
		Endif

		RecLock("FNW",.F.)
		FNW->(dbDelete())
		MsUnLock()
	Next nX

	//Atualiza a provisão
	For nX := 1 to Len(aDtMovs)

		dDataPer := LastDay(aDtMovs[nX])
		If FNV->(dbSeek(xFilial("FNV") + cCodPrv + cRev + DTOS(dDataPer)  ))
			RecLock("FNV",.F.)
			FNV->FNV_RLZEFT := "2"
			MsUnLock()

			//Verifico se o movimento eh de curto ou longo prazo
			lCurto := AF490Curto(dDataPer,dLastPer)[1]

			//Gravo o movimento de provisão das realizacoes
			AtfGrvFNW("05",cCodPrv,cRev,FNV->FNV_VLRBRT,dDataPer,lCurto)

		EndIf
	Next

	// Atualiza os registros de realizacao da provisão (FNX)
	cQuery := " SELECT R_E_C_N_O_ RECFNX"
	cQuery += " FROM " + RetSQLTab('FNX')
	cQuery += " WHERE "
	cQuery += 		" FNX_COD    = '"  + cCodPrv + "' AND "
	cQuery += 		" FNX_REV    = '"  + cRev    + "' AND "
	cQuery += 		" FNX_DTCONT = '" + DTOS(dData)   + "' AND "
	cQuery += 		RetSqlCond("FNX")
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	//Realiza o lançamento de estorno e a exclusão do registro
	While (cAliasQry)->(!EOF())
		FNX->( DbGoTo( (cAliasQry)->RECFNX) )
		RecLock("FNX",.F.)
		FNX->FNX_DTCONT := cTod('')
		MsUnLock()
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())


	//Volto o projeto ao status de efetivação pendente pendente 	
	FNU->(dbSetOrder(1))	
	If FNU->(MsSeek(xFilial('FNU')+cCodPrv+cRev))
		//Verifico se sobrou algum registro pendente de realizacao
		//Se existir, volto o status para Pendente Retencao
		aRegs := AF490Dados(4,cCodPrv,cRev)
		If Len(aRegs) > 0
			RecLock("FNU",.F.)
			FNU->FNU_STATUS := 'A'
			MsUnLock()
		Endif
		
	Endif

End Transaction

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA490ICrv ºAutor  ³Alvaro Camillo Neto º Data ³  24/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do indice de curva acao da realização  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490ICrv()
Local lRet := .T.
Local aArea:= GetArea()

FNI->(dbSetOrder(1))//FNI_FILIAL+FNI_CODIND

lRet := ExistCPO("FNI")

If lRet
	If FNI->(MsSeek(xFilial("FNI") + M->FNU_INDICE))
		If lRet .And. Alltrim(FNI->FNI_TIPO) != '2'
			lRet := .F.
			Help("  ",1,"AFA490ICRV",,STR0113 ,1,0) //"Indice de depreciação inválido, por favor escolha um indice do tipo Calculado"		
		EndIf
		
		If lRet .And. Alltrim(FNI->FNI_MSBLQL) == '1'
			lRet := .F.
			Help("  ",1,"AFA490ICRV1",,STR0114 ,1,0) //"Indice de depreciação bloqueado"		
		EndIf
	EndIf 
EndIf 

RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA490ICrv ºAutor  ³Alvaro Camillo Neto º Data ³  24/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do indice de curva acao da realização  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFA490IAVP()
Local lRet := .T.
Local aArea:= GetArea()

FIT->(dbSetOrder(1))

//lRet :=  ExistCPO("FIT")

If lRet
	If FIT->(MsSeek(xFilial("FIT") + M->FNU_INDAVP))	
		If lRet .And. Alltrim(FIT->FIT_BLOQ) == '1'
			lRet := .F.
			Help("  ",1,"AFA490IAVP",,STR0115 ,1,0) //"Indice de AVP bloqueado"		
		EndIf
	Else
		lRet := .F.
		HELP(" " , 1 , "REGNOIS")
	EndIf 
EndIf 

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF490Reali ºAutor  ³Alvaro Camillo Neto º Data ³  24/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validação do indice de curva acao da realização  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AF490Reali(cCodPrv,cRev)

Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaFNU    := FNU->(GetArea())
Local aPeriodos   := {}
Local dAtualPer   := Ctod("//")
Local nX          := 0
Local cPeriodo    := Substr(Dtos(dDatabase),1,6)

FNU->(dbSetOrder(1)) //FNU_FILIAL+FNU_COD+FNU_REV
FNU->(MsSeek(xFilial("FNU")+cCodPrv+cRev))

//Acho numero de periodos da provisao
A490Periodos(cCodPrv,cRev,aPeriodos,.T.)

Begin Transaction
	For nX := 1 to Len(aPeriodos)
		dAtualPer := aPeriodos[nX]
		cAtualPer  := Substr(Dtos(dAtualPer),1,6)
		If cAtualPer <= cPeriodo 
			//Verifico se o periodo esta com realizacao pendente
			If AF490PdRlz(cCodPrv,cRev,dAtualPer)
				//Gera o realizado para a atualizacao
				AF490GerRz(cCodPrv,cRev,dAtualPer,cAtualPer)
			Endif
		Else
			Exit
		Endif
	Next
End Transaction

RestArea(aAreaFNU)
RestArea(aArea)

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF490PdRlz  ³ Autor ³ Mauricio Pequim Jr. ³ Data ³ 07/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se permite a efetivacao de drealizacao do periodo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA490                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AF490PdRlz(cCodPrv,cRev,dAtualPer)

Local lRet := .T.

FNV->(dbSetOrder(2)) // FNV_FILIAL+FNV_COD+FNV_REV+DTOS(FNV_DTFIN)
If FNV->(MsSeek(xFilial("FNV") + cCodPrv + cRev + DTOS(LastDay(dAtualPer))))
	If FNV->FNV_RLZEFT == "1"
		lRet := .F.
	Endif
Endif

Return lRet	




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o    ³ AF490TemCtb³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 22/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Verifica a existencia de contabilizacoes de movimentos do  ³±±
±±³           ³ tipo 03, 04 ou 05 no periodo            				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ AF490DelFnw(cCodPrV,cRev)								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ cCod     - Codigo do controle de provisao				   ³±±
±±³           ³ cRev     - Revisao do controle de provisao				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ ATFA490 												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AF490TemCtb(cCodPrV,cRev,dDataIni,dDataFin)
Local aArea		:= GetArea()
Local aAreaFNV	:= FNV->(GetArea())
Local aAreaFNW	:= FNW->(GetArea())
Local lRet 		:= .F.
Local cQuery 	:= ""
Local cAliasQry := "AF490FNV"
Local cAliasQr1 := "AF490FNW"  
Local cDtIni	:= ""
Local cDtFin	:= "" 


//Query na FNX para obter movimentos de realização no periodo
cQuery := " SELECT MIN(FNX_DTMOV) FNXDTINI, MAX(FNX_DTMOV) FNXDTFIM "
cQuery += " FROM " + RetSQLTab('FNX')
cQuery += " WHERE "
cQuery += 		"FNX_COD    = '" + cCodPrv	+"' AND "
cQuery += 		"FNX_REV    = '" + cRev     +"' AND "
cQuery += 		"FNX_DTMOV  BETWEEN  '" + DTOS(dDataIni) + "'AND '" + DTOS(dDataFin) + "' AND "
cQuery +=		"FNX_DTCONT = ' ' AND "
cQuery += 		RetSqlCond("FNX")

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
TcSetField(cAliasQry,"FNXDTINI","D")	
TcSetField(cAliasQry,"FNXDTFIM","D")	

DbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())

If !(cAliasQry)->(Eof())

 	cDtIni := DTOS(FirstDay((cAliasQry)->FNXDTINI))
 	cDtFin := DTOS(LastDay((cAliasQry)->FNXDTFIM))

	cQuery := " SELECT COUNT(*) CONTMOV "
	cQuery += " FROM " + RetSQLTab('FNW')
	cQuery += " WHERE "
	cQuery += 		" FNW_COD    = '" + cCodPrv	+"' "
	cQuery += 		" AND FNW_REV = '" + cRev +"' "
	cQuery += 		" AND FNW_DTMOV >= '" + cDtIni +"' "
	cQuery += 		" AND FNW_DTMOV <= '" + cDtFin +"' "
	cQuery += 		" AND FNW_OCOR IN ('03','04','05') "
	cQuery +=       " AND FNW_LA = '1' "
	cQuery +=       " AND " + RetSqlCond("FNW")
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQr1,.T.,.T.)
	If (cAliasQr1)->CONTMOV > 0          
		lRet := .T.
	EndiF

Endif
	
If lRet
	Help("  ",1,"AF490EFR6",,STR0127 + CRLF + STR0128 + CRLF+ STR0129 + DTOC(FirstDay((cAliasQry)->FNXDTINI))+" - "+DTOC(LastDay((cAliasQry)->FNXDTFIM)) ,1,0)	//"Existem movimentações referentes a realização do controle de provisão já contabilizadas para o periodo."###"Utilize a rotina 'Estorno Contabil' para possibilitar a efetivação de realização."###"Intervalo: "
Endif

(cAliasQr1)->(dbCloseArea())
(cAliasQry)->(dbCloseArea())

RestArea(aAreaFNW)
RestArea(aAreaFNV)
RestArea(aArea)

Return lRet

Function AtfDifAvp(cCodPrv,cRev)
Local nDiff		:= 0
Local cAliasDif	:= CriaTrab(,.F.)
Local aArea		:= GetArea()
Local cFilFNW 	:= RetSQLName("FNW")
Local nTot02		:= 0
Local nTot05		:= 0
Local nTot06		:= 0
Local cquery		:= ""

cQuery := "SELECT SUM(FNW_VALOR) VALOR, '06' OCORRE FROM "+ cFilFNW + CRLF
cQuery += " WHERE FNW_FILIAL = '"+xFilial('FNW')+"' "+CRLF
cQuery += " AND FNW_OCOR='06' AND FNW_COD='"+cCodPrv+"' AND FNW_REV='"+cRev+"'"+CRLF
cQuery += " AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += "UNION ALL "+CRLF
cQuery += "SELECT SUM(FNW_VALOR) VALOR, '02' OCORRE FROM "+ cFilFNW +CRLF
cQuery += " WHERE FNW_FILIAL = '"+xFilial('FNW')+"' "+CRLF
cQuery += " AND FNW_OCOR='02' AND FNW_COD='"+cCodPrv+"' AND FNW_REV='"+cRev+"'"+CRLF
cQuery += " AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += "UNION ALL "+CRLF
cQuery += "SELECT SUM(FNW_VALOR) VALOR, '05'  OCORRE FROM "+ cFilFNW +CRLF
cQuery += " WHERE FNW_FILIAL = '"+xFilial('FNW')+"' "+CRLF
cQuery += " AND FNW_OCOR='05' AND FNW_COD='"+cCodPrv+"' AND FNW_REV='"+cRev+"'"+CRLF
cQuery += " AND D_E_L_E_T_ = ' ' "+CRLF

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDif,.T.,.T.)

While (cAliasDif)->(!EOF())
	Do Case
		Case (cAliasDif)->(OCORRE) == '02'
			nTot02 := (cAliasDif)->(VALOR)
		Case (cAliasDif)->(OCORRE) == '05'
			nTot05 := (cAliasDif)->(VALOR)
		Case (cAliasDif)->(OCORRE) == '06'
			nTot06 := (cAliasDif)->(VALOR)
	EndCase
	(cAliasDif)->(dbSkip())
EndDo

nDiff := nTot05 - (nTot02+nTot06)

If _nRecFNW > 0
	Reclock('FNW', .F.)
		FNW_VALOR += nDiff 	
	MsUnlock()
Endif


(cAliasDif)->(dbCloseArea())

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A490CancVs
Botão de cancelar para operações

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Static Function A490CancVs(oView)

oView:ButtonCancelAction()

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} AF490BLQW
Validação do X3_WHEN do campo FNU_MSBLQ

@author Mauricio Pequim Jr
@since   06/04/2015

/*/
//-------------------------------------------------------------------
Function AF490BLQW()

//ATENÇÃO
//ESTA FUNÇÃO NÃO DEVE SER RETIRADA DO FONTE
//Compatibilização de releases incrementais.

Return .T.