#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM031.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      ³ GPEM031  ³ Autor   ³ Erika Kanamori                  ³ Data ³ 07/07/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Calculo de Ferias para o Modelo II                        			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ GPEM031()                                                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Generico                                                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ FNC            ³  Motivo da Alteracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V.³07/11/11³00000020276/2011³ Criação da função de validação dos dias de    ³±±
±±³             ³        ³                ³ férias da Costa Rica.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Faria³18/11/12³REQ0008 ARG11.6 ³ Atualizacao no processo de programacao para   ³±±
±±³             ³        ³                ³ ferias da Argentina.                          ³±±
±±³Christiane V.³24/01/12³00000011857/2011³ Correções de MVC quando o ambiente é CTREE    ³±±
±±³Marcelo F.   |08/02/12³ARG11.6-RH 	  ³ Requisito 001 - Liquid. Mensual 	          ³±±
±±³Christiane V.³10/02/12³00000016466/2011³ Correções para apresentação dos recibos de    ³±±
±±³             ³        ³          TDHGV9³ férias de todas as filiais                    ³±±
±±³Marcelo Faria³23/02/12³REQ0002 ARG11.6 ³ Atualizacao no processo de calculo de ferias  ³±±
±±³             ³        ³                ³ para Argentina (Modelo 2).                    ³±±
±±³Marcelo F.   ³02/04/11³ARG11.6_RH      ³ Ajustes Rescisao Argentina Modelo 2.		  ³±±
±±³Glaucia M.   ³10/05/12³00000011005/2012³ Ao realizar o calculo, será disponibilizada   ³±±
±±³             ³        ³      	TEXINO³ a opcao de habilitar log de calculo.		  ³±±
±±³Raquel Hager ³01/06/12³00000014110/2012³ Remocao da visualizacao das opcoes do MenuDef ³±±
±±³             ³        ³      	TFCDCS³ para evitar conflitos com instrucao SetMenudef³±±
±±³Glaucia M.   ³13/08/12³00000020623/2012³ O browse inicial inferior, sua ativacao só    ³±±
±±³             ³        ³      	TFMX68³ apos o AddRelation, para que o relaciomento   ³±±
±±³             ³        ³      	      ³ funcione adequadamente.                       ³±±
±±³Glaucia M.   ³10/09/12³00000022331/2012³Alteração para permissao de alteração do       ³±±
±±³             ³        ³		    TFQWKR³campo RF_DIASANT, mesmo que já tenha algum     ³±±
±±³             ³        ³		          ³dia de férias já pago.                         ³±±
±±³Glaucia M.   ³14/12/12³00000031958/2012³Melhorias: 1-p/ filtrar itens SRC, c/ processo,³±±
±±³             ³        ³		    TGHPRX³roteiro, periodo e semana pertinentes ao cabe- ³±±
±±³             ³        ³		          ³calho de férias. 2-Verificacao de dias de      ³±±
±±³             ³        ³		          ³Antecipcao de ferias, somente qdo nao ha ferias³±±
±±³             ³        ³		          ³vencidas. 3-Emissao de alerta bloqueio de inclu³±±
±±³             ³        ³		          ³sao de ferias, intercaladas com outra ferias.  ³±±
±±³Leandro Dr.  ³19/12/12³                ³Inclusao de opcao para impressa do Recibo de   ³±±
±±³             ³        ³		    TFLIGV³Ferias.                                        ³±±
±±³Glaucia M.   ³04/02/13³00000000689/2013³Insercao Ausencia - Alteracao campo R8_STATUS e³±±
±±³             ³        ³		    TGJMGL³R8_SITUAC. O campo RA_SITFOLH será atualizado  ³±±
±±³             ³        ³		          ³oMrkBrwDwn:Refresh(), não funciona, e fomos a  ³±±
±±³             ³        ³		          ³usar oMrkBrwDwn:Refresh(.T.).				  ³±±
±±³             ³        ³		          ³Ao executar o calculo de férias RA_SITFOLH='F'.³±±
±±³             ³        ³		          ³Ao excluir calculo de férias RA_SITFOLH=' '.   ³±±
±±³             ³        ³		          ³Apenas permitir inclusao de férias, se o perio-³±±
±±³             ³        ³		          ³do VAC utilizado, possui correspondente em LIQ.³±±
±±³Glaucia M.   ³14/02/13³00000003551/2013³Modificacao na chamado do calculo de ferias, p/³±±
±±³             ³        ³		    TGPCYH³nao gerar incosistencia na tabela SRC.         ³±±
±±³             ³        ³                ³                                               ³±±
±±³Jonathan glez³30/14/15³      PCREQ-4256³Se elimina la funcion AjustaHLP() con motivo de³±±
±±³             ³        ³                ³adecuacion a nuevas estructuras en SXs de      ³±±
±±³             ³        ³                ³Version 12                                     ³±±
±±³M. Camargo   ³18/12/15³PDR_SER_MI0002  ³Ajustes Loc. Chile                             ³±±
±±³             ³        ³Req.  PCREQ-7944³adecuacion a nuevas estructuras en SXs de      ³±±
±±³             ³        ³                ³Version 12                                     ³±±
±±³M. Camargo   ³05/04/16³PCDEF2015_2016  ³Asociación de fuente a defecto                 ³±±
±±³             ³        ³-3951           ³                                               ³±±
±±³MCamargo     ³08/09/16³               ³Merge v12.1.13                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*	1.É de suma importância ao alterar esta rotina, verificar se o calculo de ferias coletivas, está
	com o mesmo comportamento.
	2.Verificar se ausencias está adequada
	3.Se calculo de dias de direito esta compatível com o SRF
	4.Calcular e fechar VAC (verique lancamentos na SRC/SRD - como roteiro-periodo-pago)
	5.Calcular e fechar LIQ
	6.Tente inserir novos registros manualmente nas rotinas GPEA240 e GPEA050, nenhuma alteração aqui poderá influencias nestes cadastros
*/
Function GPEM031()
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oPanelUp, oFWLayer, oPanelDown, oRelacRHI

Private oDlgPrinc
Private oMrkBrwDwn ,oBrowseUp

Define MsDialog oDlgPrinc Title OemToAnsi(STR0001) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel  //"Cálculo de Férias"

dbSelectArea("RHJ")
//
// Cria o conteiner onde serão colocados os browses
//
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )

//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 50, .F. )                        // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALLUP', 100, .T., 'UP' )           // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALLUP', 'UP' )        // Pego o objeto desse pedaço do container

//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 50, .F. )                     // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALLDWN' ,  100, .T., 'DOWN' )     // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelDown 	:= oFWLayer:GetColPanel( 'ALLDWN', 'DOWN' ) // Pego o objeto desse pedaço do container


//
// FWmBrowse Superior Funcionarios
//
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )                    // Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( STR0002 )				  //"Funcionarios"
oBrowseUp:SetAlias( 'SRA' )
oBrowseUp:SetMenuDef( 'GPEM032' )                 // Define de onde virao os botoes deste browse
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )

oBrowseUp:AddLegend( "RA_SITFOLH==' '" 		, "GREEN"   , STR0043 ) 	//"Situacao Normal"
oBrowseUp:AddLegend( "RA_RESCRAI$'30/31'"   , "PINK"    , STR0044 )    //"Transferido"
oBrowseUp:AddLegend( "RA_SITFOLH=='D'"      , "RED"     , STR0045 )    //"Demitido"
oBrowseUp:AddLegend( "RA_SITFOLH=='A'"      , "YELLOW"  , STR0046 ) 	//"Afastado"
oBrowseUp:AddLegend( "RA_SITFOLH=='F'"      , "BLUE"    , STR0047 ) 	//"Ferias"
oBrowseUp:Activate()

//
// FWmBrowse Inferior Cabecalhos de ferias
oMrkBrwDwn:= FWMarkBrowse():New()
oMrkBrwDwn:SetAlias('RHI')
oMrkBrwDwn:SetOwner( oPanelDown )
oMrkBrwDwn:SetSemaphore(.T.)
oMrkBrwDwn:SetDescription( STR0003 )		//"Cabeçalhos de ferias"
oMrkBrwDwn:SetFieldMark( 'RHI_MARK' )
oMrkBrwDwn:SetAllMark( { || oMrkBrwDwn:AllMark() } )
oMrkBrwDwn:SetMenuDef( 'GPEM031' )
oMrkBrwDwn:ForceQuitButton()
oMrkBrwDwn:SetValid({||ValidMark()})
oMrkBrwDwn:AddLegend( "RHI_STATUS $ '1*2'"  , "BLUE", OemToAnsi(STR0004)  ) //"Ferias em aberto"
oMrkBrwDwn:AddLegend( "RHI_STATUS $ '3*4*5'", "RED" , OemToAnsi(STR0005)  ) //"Ferias fechadas"

//
// Relacionamento entre os Paineis
//
oRelacRHI:= FWBrwRelation():New()
oRelacRHI:AddRelation( oBrowseUp  , oMrkBrwDwn , { { 'RHI_FILIAL', 'xFilial( "RHI" )' }, { 'RHI_MAT' , 'RA_MAT'  } } )
oRelacRHI:Activate()

oMrkBrwDwn:Activate()

Activate MsDialog oDlgPrinc Center

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Erika Kanamori        ³ Data ³ 05/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MenuDef()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title OemToAnsi(STR0006) Action 'PesqBrw'         OPERATION 1  ACCESS 0 DISABLE MENU  //"Pesquisar"
	ADD OPTION aRotina Title OemToAnsi(STR0007) Action 'VIEWDEF.GPEM031' OPERATION 2  ACCESS 0 DISABLE MENU  //"Visualizar"
	ADD OPTION aRotina Title OemToAnsi(STR0008) Action 'VIEWDEF.GPEM031' OPERATION 3  ACCESS 0 DISABLE MENU  //"Incluir"
	ADD OPTION aRotina Title OemToAnsi(STR0009) Action 'VIEWDEF.GPEM031' OPERATION 4  ACCESS 0 DISABLE MENU  //"Alterar"
	ADD OPTION aRotina Title OemToAnsi(STR0010) Action 'VIEWDEF.GPEM031' OPERATION 5  ACCESS 0 DISABLE MENU  //"Excluir tudo"
	ADD OPTION aRotina Title OemToAnsi(STR0011) Action 'CalculaM31()' 	 OPERATION 6  ACCESS 0 DISABLE MENU  //"Calcular"
	ADD OPTION aRotina Title OemToAnsi(STR0039) Action 'ElimCalcM31()'   OPERATION 7  ACCESS 0 DISABLE MENU  //"Excluir Calculo"
	ADD OPTION aRotina Title OemToAnsi(STR0050) Action 'GPER940()'   	 OPERATION 8  ACCESS 0 DISABLE MENU  //"Recibo de Férias"

Return aRotina



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Erika Kanamori        ³ Data ³ 07/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ViewDef()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function ViewDef()
Local oStruRHI := FWFormStruct( 2, 'RHI' )
Local oStruRHJ := FWFormStruct( 2, 'RHJ' )
Local oStruSRC := FWFormStruct( 2, 'SRC' )
Local oModel   := FWLoadModel( 'GPEM031' )
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )

//nao apresenta os seguites campos no RHI
oStruRHI:RemoveField( 'RHI_MARK' )

//nao apresenta os seguites campos no RHJ
oStruRHJ:RemoveField( 'RHJ_FILIAL' )
oStruRHJ:RemoveField( 'RHJ_MAT' )
oStruRHJ:RemoveField( 'RHJ_DTINI' )
oStruRHJ:RemoveField( 'RHJ_STATUS' )

//nao apresenta os seguites campos no SRC
oStruSRC:RemoveField( 'RC_FILIAL' )
oStruSRC:RemoveField( 'RC_MAT' )
oStruSRC:RemoveField( 'RC_NOME' )

oView:AddField( 'VIEW_RHI', oStruRHI, 'RHIMASTER' )
oView:AddGrid(  'VIEW_RHJ', oStruRHJ, 'RHJDETAIL' )
oView:AddGrid(  'VIEW_SRC', oStruSRC, 'SRCDETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'MEIO', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 30 )

//SRC eh soh para consulta, não permite alterações
oView:SetOnlyView('VIEW_SRC')

oView:SetOwnerView( 'VIEW_RHI', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_RHJ', 'MEIO' )
oView:SetOwnerView( 'VIEW_SRC', 'INFERIOR' )

oView:EnableTitleView('VIEW_RHI')
oView:EnableTitleView('VIEW_RHJ')
oView:EnableTitleView('VIEW_SRC')

Return oView



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Erika Kanamori        ³ Data ³ 08/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de Dados da Rotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ModelDef()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static Function ModelDef()
Local oStruRHI  := FWFormStruct( 1, 'RHI', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruRHJ  := FWFormStruct( 1, 'RHJ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruSRC  := FWFormStruct( 1, 'SRC', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel
Local bCommiM031:= { | oModel | CommiM031( oModel )}
Local bVldActiv	:= { | oModel | VldActvM31( oModel )}
Local bTudoOK	:= { | oModel | fTudoOkM031( oModel )}

oModel := MPFormModel():New( 'GPEM031', /*bPreValid*/, bTudoOK, bCommiM031, /*bCancel*/ )
oModel:SetDescription( OemToAnsi(STR0001) ) //'Calculo de Ferias'

//seta inicializador padrao para o campo de descricao do SRC
oStruSRC:SetProperty( 'RC_DESCPD' , MODEL_FIELD_INIT, FWBuildFeature( /*STRUCT_FEATURE_INIPAD*/ 3 , "FillDescPd()" ))

//incluindo fields e grid no oModel
oModel:AddFields( 'RHIMASTER', /*cOwner*/, oStruRHI )
oModel:AddGrid( 'RHJDETAIL', 'RHIMASTER', oStruRHJ, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'SRCDETAIL', 'RHIMASTER', oStruSRC, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

//Definindo relacionamento entre RHI e RHJ
oModel:SetRelation( 'RHJDETAIL', { { 'RHJ_FILIAL', 'xFilial( "RHJ" )' }, { 'RHJ_MAT', 'RHI_MAT' }, {'RHJ_DTINI', 'RHI_DTINI'} }, RHJ->(IndexKey(1)) )
oModel:SetRelation( 'SRCDETAIL', { { 'RC_FILIAL', 'xFilial( "SRC" )' } , { 'RC_MAT', 'RHI_MAT' }, {'RC_PROCES', 'RHI_PROCES'},{'RC_ROTEIR', 'RHI_ROTEIR'},{'RC_PERIODO', 'RHI_PERIOD'},{'RC_SEMANA', 'RHI_NUMPAG'}, {'RC_DTREF', 'RHI_DTINI'} } , SRC->(IndexKey(1)) )

oModel:SetVldActivate(bVldActiv)

//Regras do model RHIMASTER
//oModel:GetModel( 'RHIMASTER' ):SetUniqueLine( { 'RHI_FILIAL','RHI_MAT', 'RHI_DTINI'} )

//Regras do Model RHJDETAIL
//oModel:GetModel( 'RHJDETAIL' ):SetUniqueLine( { 'RHJ_FILIAL','RHJ_MAT', 'RHJ_DTINI', 'RHJ_DTBASE' } )
oModel:GetModel( 'RHJDETAIL' ):SetNoInsertLine( .T. )
oModel:GetModel( 'RHJDETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'RHJDETAIL' ):SetOptional( .T. )

//Regras do Model SRCDETAIL
oModel:GetModel( 'SRCDETAIL' ):SetNoInsertLine( .T. )	//nao permite insercao de linhas
oModel:GetModel( 'SRCDETAIL' ):SetNoDeleteLine( .T. ) 	//nao permite delecao de linhas
oModel:GetModel( 'SRCDETAIL' ):SetOptional( .T. )  	//pode nao ter linhas

//Definindo descricoes
oModel:GetModel( 'RHIMASTER' ):SetDescription( OemToAnsi(STR0012)  ) //'Cabeçalho de férias'
oModel:GetModel( 'RHJDETAIL' ):SetDescription( OemToAnsi(STR0013)  ) //'Ítens de férias'
oModel:GetModel( 'SRCDETAIL' ):SetDescription( OemToAnsi(STR0014)  ) //'Ítens de calculo'

Return oModel



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fValidDur   ³ Autor ³ Erika Kanamori        ³ Data ³ 11/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de Dados da Rotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fValidDur()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fValidDur()
Local lRet:= .T.
Local oModel    := FWModelActive()
Local nOperation:= oModel:GetOperation()
Local oModelRHJ := oModel:GetModel( 'RHJDETAIL' )
Local nLinAux	:= 1
Local nLinha	:= 0
Local nDiasAntec:= 0
Local nDiasProg := 0
Local nDiasPagos:= 0
Local nDiasVenc :=0
//verifica se tem dias antecipados de ferias (deve estar previamente cadastrado atraves de Controle de Dias Direito)
//neste ponto, já devem estar criados os registros de RHJ
nLinha:= oModelRHJ:Length()
If nLinha <> 0
	For nLinAux:= 1 to nLinha
		If !(oModelRHJ:IsDeleted(nLinAux))
			nDiasAntec+= oModelRHJ:GetValue('RHJ_DIASAN', nLinAux)
			nDiasPagos+= oModelRHJ:GetValue('RHJ_DFERAN', nLinAux)
			nDiasVenc += oModelRHJ:GetValue('RHJ_DFERVA', nLinAux)
		 Endif
	End
	nLinha:= nLinha+1
Endif

If nOperation != MODEL_OPERATION_UPDATE
	//Busca lanctos nao pagos no SR8 para o periodo
	dbSelectArea("SR8")
	SR8->(DbSetOrder( RetOrdem( "SR8", "R8_FILIAL+R8_MAT+R8_PER" ) ))
	If SR8->(dbSeek(xFilial("SR8")+M->RHI_MAT+M->RHI_PERIOD))
		While SR8->(R8_FILIAL+R8_MAT+R8_PER) == xFilial("SR8")+M->RHI_MAT+M->RHI_PERIOD
			If SR8->R8_DPAGOS == 0 .And. SR8->R8_SDPAGAR > 0 .And. PdIsAbsence( SR8->R8_PD, .F. )
			   nDiasProg += SR8->R8_SDPAGAR
			Endif
			SR8->(dbSkip())
		End
	Endif
Endif

//a variavel de memoria M->RHI_DFERVE ja calculou os dias pagos no periodo
If (cPaisLoc=="PAR" .And. M->RHI_DFERIA > ((nDiasVenc + M->RHI_DFERPR + nDiasAntec) - nDiasPagos));
	.OR. ( cPaisLoc <> "PAR" .And. M->RHI_DFERIA > ((M->RHI_DFERVE + nDiasAntec) - nDiasProg))
		Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0016), 1, 0 )//"Help" ## "os dias de férias informados não podem ser superiores aos dias que o funcionario tem direito"
		lRet:= .F.
EndIf	


If (cPaisLoc == "ARG") .AND. (nDiasVenc = 0)
	If (nDiasPagos > 0) .And. (M->RHI_DFERIA > (nDiasAntec - nDiasPagos)  )
		Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0016), 1, 0 )//"Help" ## "os dias de férias informados não podem ser superiores aos dias que o funcionario tem direito"
		lRet:= .F.
	EndIf

EndIf



Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fTudoOk     ³ Autor ³ Erika Kanamori        ³ Data ³ 27/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao do formulario.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fTudoOkM031()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fTudoOkM031()
Local nAux			:= 1
Local lRecalcula	:= .F.
Local lRet			:= .T.
Local aCampos		:= {}
Local oModel    	:= FWModelActive()
Local nOperation	:= oModel:GetOperation()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Nao deixa incluir ferias se existirem outras ferias no mesmo periodo ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nOperation <> MODEL_OPERATION_DELETE
	If Empty(M->RHI_PROCES) .or. Empty(M->RHI_ROTEIR) .or. Empty(M->RHI_PERIOD)
		Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0021), 1, 0 )//"Help" ## "Os campos Processo, Roteiro ou Periodo não estao preenchidos."
		lRet:= .F.
	Else
		dbSelectArea("RHI")
		dbSetOrder(RetOrder("RHI", "RHI_FILIAL+RHI_MAT+DTOS(RHI_DTINI)"))
		RHI->(dbSeek(xFilial("RHI") + SRA->RA_MAT ))
		While RHI->( !Eof() ) .And. RHI->(RHI_FILIAL+RHI_MAT) == (xFilial("RHI") + SRA->RA_MAT)
			If (RHI->RHI_DTINI <> M->RHI_DTINI) //se nao for o registro que esta posicionado
				If !( (RHI->RHI_DTFIM < M->RHI_DTINI) .Or. ( RHI->RHI_DTINI > M->RHI_DTFIM ) )
					Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0017), 1, 0 )//"Help" ## 'Jah existem ferias informadas para este periodo'
					lRet:= .F.
					Exit
				Endif
			Endif
			RHI->( dbSkip() )
		End
	Endif
Else
	If SRA->RA_SITFOLH $ 'F'
		dbSelectArea( "SRA" )
		RecLock("SRA",.F.,.T.)
		SRA->RA_SITFOLH := " "
		MsUnlock()
		oBrowseUp:Refresh()
		oMrkBrwDwn:Refresh(.T.)
	EndIf
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Se houve alteracao de campos importantes, aciona novamente o calculo ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If lRet
	If nOperation == MODEL_OPERATION_UPDATE .And. M->RHI_STATUS == "2"
		aAdd(aCampos, 'RHI_DTINI' )
	    aAdd(aCampos, 'RHI_DFERIA')
	    aAdd(aCampos, 'RHI_PROCES')
	    aAdd(aCampos, 'RHI_ROTEIR')
	    aAdd(aCampos, 'RHI_PERIOD')
	    aAdd(aCampos, 'RHI_NUMPAG')

	  	While (nAux <= len(aCampos))
			If oModel:IsFieldUpdated( 'RHIMASTER', aCampos[nAux])
				lRecalcula:= .T.
				Exit
			Endif
			nAux:= nAux + 1
		End


		If lRecalcula
			If( MsgNoYes(	OemToAnsi( STR0019 + CRLF + CRLF + STR0020 ),; //"Ao confirmar estas alteracoes, as ferias calculadas anteriormente serao deletadas." ## "Confirma modificacao?"
							 OemToAnsi(STR0018) )) //"Atencao"
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Grava informacoes para que sejam acessadas corretamente durante o calculo ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				If !Empty(M->RHI_PROCES) .And. !Empty(M->RHI_ROTEIR) .And. !Empty(M->RHI_PERIOD)
					FwFormCommit(oModel)
					CalFerM2(.T.)
				Else
					Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0021), 1, 0 )//"Help" ## "Os campos Processo, Roteiro ou Periodo não estao preenchidos."
					lRet:= .F.
				Endif
			Else
				lRet:= .F.
			Endif

		Endif
	Endif
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fDataferM2  ³ Autor ³ Erika Kanamori        ³ Data ³ 11/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula data final das ferias.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³dDtIniFer	: Data de Inicio das ferias                         ³±±
±±³          ³nDuracao	: Duracao das ferias                                ³±±
±±³          ³cCpoDtFim	: Campo a ser preenchido (data final)               ³±±
±±³          ³cCpoDtAvi	: Campo de data de Aviso                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fDataferM2( dDtIniFer, ;
					 nDuracao,  ;
					 cCpoDtFim,	;
					 cCpoDtAvi )



Local oModel    	:= IIf ((Type("lColetiva") == "U" ) .Or. !lColetiva,FWModelActive(),)
Local nOperation	:= IIf ((Type("lColetiva") == "U" ) .Or. !lColetiva,oModel:GetOperation(),)
Local oModelRHI		:= IIf ((Type("lColetiva") == "U" ) .Or. !lColetiva,oModel:GetModel( 'RHIMASTER' ),)
Local dDataIni		:= Ctod("//")
Local DtAvisoF, DtRecibo
Local dDtRetAf 		:= CTOD("//")
Local nDMes12  		:= nDMes01 := 0
Local nDLicQ1  		:= nDLicQ2 := 0
Local lHabiles		:=	.T.
Local nRCMOrder 	:= 0
Local cTipoDia 		:= "2"
Local dDatafim 		:= ctod("//")
Local cCampo	  	:= ReadVar()
Local nDiasAux		:= 0
Local cDia2501    	:= Getmv( "MV_DIA2501" )
Local cVrbDescVac	:= If(!Empty(fGetCodFol("0786")), fGetCodFol("0786"), fGetCodFol("072"))
Local lTemAfast		:= .F.       //Variavel para verificar se já existe afastamento no mesmo periodo aquisitivo

DEFAULT cCpoDtFim:= ""
DEFAULT cCpoDtAvi:= ""

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica se nao tem Afastamento no Inicio das Ferias                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !Empty(dDtIniFer) .And. !Empty(nDuracao)

	If Type("lColetiva") == "U" .Or. !lColetiva
		If nOperation == MODEL_OPERATION_INSERT

			lTemAfast := fChkAfas(SRA->RA_FILIAL,SRA->RA_MAT,dDtIniFer,,@dDtRetAf, , , ,)
		Endif

		If (lTemAfast) .AND. (dDtRetAf >= dDtIniFer)
			nOp:= Aviso( OemToAnsi(STR0022), OemToAnsi(STR0023) + Dtoc(dDtRetAf),; //"Aviso"##"Na Data Informada Existe Afastamento com Termino em"
								{STR0024,STR0025}) // "confirma" ## "redigita"
			If nOp = 2
				Return( .F. )
			Endif
		Endif
	Endif

	//Verifica se as ferias tem inicio em algum dia feriado
	cTipoDia := gp240RetCont( "RCM", RetOrder( "RCM", "RCM_FILIAL+RCM_PD" ), xFilial("RCM") + fGetCodFol("0072"), "RCM_TIPODI")
	dDataIni  := dDtIniFer
	If cTipoDia == "2"
	   dDataFim  := (dDataIni + Round(nDuracao,0)) - 1//dDataIni + Round(nDuracao, 0)                                                                                                   w
	Else
		GpeCalend(,,,,, dDataIni, @dDataFim, nDuracao, "F", cCampo, .F.)
	Endif

	dDataFim  := If( dDataFim < dDataIni, dDataIni, dDataFim)
	DtAvisoF := fVerData(dDtIniFer - GetNewPar("MV_AVISFER", nDiasAux))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Deve Considerar dias 24/12, 25/12, 31/12 e 01/01 ³
	//| como licenca remunerada.                                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fChkLicRem( dDataIni, dDataFim, @nDMes12, @nDMes01, cDia2501)
	If nDMes12 + nDMes01 > 0
		dDataFim += nDMes12 + nDMes01
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houver dias de ferias = 0.5, lancar 0.5 em Lic. Remunerda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	fChkFQueb( dDataIni, dDataFim, @nDLicQ1, @nDLicQ2, , nDuracao)    //retirar nDLicQ1 e nDLicQ2 para modelo 2 depois

	If !Empty(cCpoDtFim)
		&(cCpoDtFim)  := dDataFim
		If ValType(oModelRHI) == "O" .And.  "RHI_DTFIM" $ cCpoDtFim
			cCpoDtFim := Replace(cCpoDtFim,"M->","") 
			oModelRHI:LoadValue(cCpoDtFim , dDataFim )
		EndIf
	Endif
	If !Empty(cCpoDtAvi)
		&(cCpoDtAvi) := DtAvisoF
		If ValType(oModelRHI) == "O" .And.  "RHI_DTAVIS" $ cCpoDtAvi .ANd. oModelRHI:HasField("RHIMASTER","RHI_DTAVIS")
			cCpoDtAvi := Replace(cCpoDtAvi,"M->","") 
			oModelRHI:LoadValue(cCpoDtAvi , dDataFim )
		EndIf
	Endif
Endif

Return( .T. )




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValidMark   ³ Autor ³ Erika Kanamori        ³ Data ³ 12/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Nao deixa selecionar ferias fechadas na markbrowse.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ValidMark()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function ValidMark()
Local lRet := .T.
Local RHIArea:= RHI->(GetArea())
Local cMarca := oMrkBrwDwn:Mark()

RHI->( dbGoTop() )
While !RHI->( Eof() )
	If oMrkBrwDwn:IsMark(cMarca)
		If RHI_STATUS $ "3*4*5"
			Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0026), 1, 0 )//"Help" ## "As férias referentes a este registro já estão fechadas"
			RecLock("RHI", .F.)
			RHI_MARK:= ""
			MsUnlock()

			lRet:= .F.
		Endif
	EndIf
	RHI->( dbSkip() )
End

RestArea(RHIArea)

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalculaM31()³ Autor ³ Erika Kanamori        ³ Data ³ 13/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta tela de calculo de ferias                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CalculaM31()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function CalculaM31()
Local lRet:= .T.
Local aArea			:= GetArea()

//Variaveis para montagem da Dialog
Local oDlg
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}

Local aButtons		:= {}

Local bSet15
Local bSet24
Local bDialogInit
Local oChkHabTrace
Private lHabTrace	:= .F.

If SRA->RA_SITFOLH $ 'F'
	Alert(OemtoAnsi(STR0055))	//'O Funcionário está com situação de férias no cadastro. Assim não será possível calcular as férias.'
Else
	//monta tela
	aAdd(aButtons, {'RELATORIO', {|| TelaLog()}, OemToAnsi(STR0027), OemToAnsi(STR0028) }) //"Consulta Logs de Calculo"##"Logs"

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Bloco para a Inicializacao do Dialog            	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bDialogInit		:= { ||;
								CursorWait()													,;
								EnchoiceBar( oDlg , bSet15 , bSet24, NIL , aButtons )			,;
								CursorArrow()												 	 ;
					   }

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aAdvSize		:= MsAdvSize( , .T., 310 )
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	//Divisao em colunas Linha 1-Cabecalho Dados Funcionario
	aAdv1Size		:= aClone(aObjSize[1])
	aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//1-Matricula
	aAdd( aObj1Coords , { 000 , 235 , .T. , .F. } )			//2-Nome
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//3-Admissao
	aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )



	Define MsDialog oDlg Title OemToAnsi(STR0029) From aAdvSize[7],000 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Dados do folder - Gerais 											       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       		//
		@aObjSize[2,1], aObj1Size[2,2] SAY  OemToAnsi(STR0030) SIZE 250, 020 OF oDlg PIXEL //Deseja calcular ferias para os registros selecionados?
		@aObjSize[3,1], aObj1Size[2,2] CHECKBOX oChkHabTrace VAR lHabTrace PROMPT OemToAnsi(STR0049) SIZE 100,08 OF oDlg PIXEL //"Habilitar TRACE"

		bSet15		:= { || CalFerM2(),oBrowseUp:Refresh(),oMrkBrwDwn:Refresh(.T.)}
		bSet24		:= { || oBrowseUp:Refresh(),oMrkBrwDwn:Refresh(.T.),oDlg:End() }

	ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED

EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ElimCalcM31()³ Autor ³ Marcelo Faria        ³ Data ³ 25/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta tela exclusao somente de calculo de ferias              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ElimCalcM31()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function ElimCalcM31()
Local lRet:= .T.
Local aArea			:= GetArea()

//Variaveis para montagem da Dialog
Local oDlg
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aRetcoords    := {}
Local aButtons		:= {}

Local bSet15
Local bSet24
Local bDialogInit

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define o Bloco para a Inicializacao do Dialog            	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bDialogInit		:= { ||;
								CursorWait()									   ,;
								EnchoiceBar( oDlg , bSet15 , bSet24, NIL , Nil )  ,;
								CursorArrow()					    			 	 ;
					   }

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aAdvSize		:= MsAdvSize( , .T., 310 )
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	Define MsDialog oDlg Title OemToAnsi(STR0039) From aAdvSize[7],000 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Dados do folder - Gerais 											       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
       		//

		@aObjSize[2,1], aObjSize[2,2] SAY  OemToAnsi(STR0040) SIZE 250, 020 OF oDlg PIXEL //Deseja excluir o calculo para a programação selecionada?
		@aObjSize[3,1], aObjSize[2,2] SAY  SRA->RA_NOME +'        * Ref: ' +DTOC(RHI->RHI_DTINI) SIZE 250, 020 OF oDlg PIXEL //Deseja excluir o calculo para a programação selecionada?

		bSet15		:= { || ExcluiSRC() }
		bSet24		:= { || oDlg:End() }

	ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ExcluiSRC() ³ Autor ³ Marcelo Faria         ³ Data ³ 13/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta tela exclusao somente de calculo de ferias              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExcluiSRC()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function ExcluiSRC()
Local lRet:= .T.

If RHI_STATUS $ "3*4*5"
	Aviso( STR0018, OemToAnsi(STR0026), {'ok'} )//"Atenção"##"As férias referentes a este registro já estão fechadas"
	lRet:= .F.
Endif
If RHI_STATUS == "1"
	Aviso( STR0018, OemToAnsi(STR0041), {'ok'} )//"Atenção"##"Não existe calculo para essa programação!"
	lRet:= .F.
Endif

If lRet
	dbSelectArea("SRC")
	DbSetOrder( 6 )

	IF SRC->( dbSeek( xFilial( "SRC" ) + RHI->RHI_MAT + RHI->RHI_PROCES + RHI->RHI_ROTEIR ) )
		While SRC->( !Eof() ) .And. SRC->RC_FILIAL +SRC->RC_MAT +SRC->RC_PROCES +SRC->RC_ROTEIR == ;
									xFilial("SRC") +RHI->RHI_MAT +RHI->RHI_PROCES +RHI->RHI_ROTEIR
			If DTOS(SRC->RC_DTREF) == DTOS(RHI->RHI_DTINI)
				RecLock("SRC",.F.,.T.)
				SRC->( dbDelete() )
				SRC->( MsUnLock() )
			EndIf

			SRC->( dbSkip() )
		End While
	EndIf

	dbSelectArea("RHI")
	RecLock("RHI", .F.)
	RHI->RHI_STATUS := "1"
	RHI->(MsUnlock())

	If SRA->RA_SITFOLH $ 'F'
		dbSelectArea( "SRA" )
		RecLock("SRA",.F.,.T.)
		SRA->RA_SITFOLH := " "
		MsUnlock()

	EndIf


	Aviso( STR0018, OemToAnsi(STR0042), {'ok'} )//"Atenção"##"Calculo eliminado com sucesso!
	oBrowseUp:Refresh()
	oMrkBrwDwn:Refresh(.T.)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalFerM2()  ³ Autor ³ Erika Kanamori        ³ Data ³ 13/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa o calculo de ferias individuais.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lRecalculo: se eh recalculo (se houve modificacao no formul.) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function CalFerM2(lRecalculo)
Local RHIArea	:= RHI->(GetArea())
Local aArea		:= GetArea()
Local oModel    := FWModelActive()
Local cMarca 	:= oMrkBrwDwn:Mark()
Local cMat	 	:= SRA->RA_MAT
Local lCalcula	:= .F.
Local lHouveCalc:= .F. //flag para saber se calculou alguma vez

Private cProces		:= Space( TamSX3( "RCJ_CODIGO" )[1] )
Private cRoteiro 	:= Space( TamSX3( "RY_CALCULO" )[1] )
Private cPeriodo	:= Space( TamSX3( "RCH_PER" )[1] )
Private cNumPag		:= Space( TamSX3( "RCH_NUMPAG" )[1] )
Private cProcDesc	:= Space( TamSX3( "RCJ_DESCRI" )[1] )
Private cRotDesc 	:= Space( TamSX3( "RY_DESC" )[1] )
Private lHabGrab	:= .F.
Private lHabTrace	:= .F.
Private aFilter		:= {}
Private __aFormulas	:= {}
Private oPeriodo	 := RHPERIODO():New()
Private lGrid	:= .F.

Private nStatus		:= 1
Private dDataIni	:= Ctod("//")
Private dDataFim	:= Ctod("//")

Private dDataKey	:= CtoD("//") //data que vai servir de relacionamento entre RHI, RHJ e SRC (data inicial de férias, RHI_DTINI

Private aNCalcula	:= {}

DEFAULT lRecalculo:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Funcionario Esta Demitido                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If SRA->RA_SITFOLH $ "DE"
		Help(" ","1","GPEM30AFAS")
		Return( NIL )
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Funcionario Esta Afastado                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SRA->RA_SITFOLH $ "AF"
		Help(" ",1,"A090AFASTA")
		If (SRA->RA_SITFOLH $ "F")
			Return( NIL )
		EndIf
	Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao verifica se existe alguma restrição de acesso para o³
//³usuário que impeça a execução da rotina.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !(fValidFun({"SQB","SRJ","RCO",;
				"CTT","RGC","RCE","SR6","SR3",;
				"SR7","SRC","RGB","SRV","SRK",;
				"RCP","RG7"}))
	RestArea(aArea)
	Return
Endif


If lRecalculo
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega informacoes utilizadas no calculo				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cProces		:= SRA->RA_PROCES
	cRoteiro 	:= M->RHI_ROTEIR
	cPeriodo	:= M->RHI_PERIOD
	cNumPag		:= M->RHI_NUMPAG
	dDataKey	:= M->RHI_DTINI

	If VldPerVAC() .And. VldCalculo()

		cProcDesc	:= Posicione("RCJ", 1, xFilial("RCJ")+ cProces, "RCJ_DESCRI")
		cRotDesc	:= Posicione("SRY", 1, xFilial("SRY")+ cRoteiro, "RY_DESC")

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera filtro para calcular somente o funcionario posicionado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		fGeraFilter( aFilter, cMat," "," "," "," ")
		Proc2BarGauge({|lEnd| Gpem022Processa()})
	Endif

Else
	dbSelectArea("RHI")
	dbSetOrder(RetOrder("RHI", "RHI_FILIAL+RHI_MAT+DTOS(RHI_DTINI)"))
	RHI->(dbSeek(xFilial("RHI") + cMat))
	While RHI->( !Eof() ) .And. RHI->(RHI_FILIAL+RHI_MAT) == (xFilial("RHI") + cMat)
		If oMrkBrwDwn:IsMark(cMarca)

			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega informacoes utilizadas no calculo				  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cProces		:= SRA->RA_PROCES
			cRoteiro 	:= RHI->RHI_ROTEIR
			cPeriodo	:= RHI->RHI_PERIOD
			cNumPag		:= RHI->RHI_NUMPAG
			dDataKey	:= RHI->RHI_DTINI

			If Empty(cProces) .Or. Empty(cRoteiro) .Or. Empty(cPeriodo)
				//VERIFICAR COMO FAZER LOG
				AddMsgLog(OemtoAnsi(STR0054) + SRA->RA_MAT)		//"Nao foi possivel calcular o funcionario"
				lCalcula	:= .F.
			Else
				cProcDesc	:= Posicione("RCJ", 1, xFilial("RCJ")+ cProces, "RCJ_DESCRI")
				cRotDesc	:= Posicione("SRY", 1, xFilial("SRY")+ cRoteiro, "RY_DESC")
				lCalcula	:= .T.
			Endif


			If lCalcula
				If VldPerVAC() .And. VldCalculo()
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera filtro para calcular somente o funcionario posicionado³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					nRecno	:= ( "RHI")->(Recno())
					fGeraFilter( aFilter, cMat," "," "," "," ")
					Proc2BarGauge({|lEnd| Gpem022Processa()})
					lHouveCalc:= .T.
					dbSelectArea("RHI")
					("RHI")->( dbGoto( nRecno ) )
				Endif
			Endif
		EndIf
		RHI->( dbSkip() )
	End



	If !lHouveCalc
		Aviso( OemToAnsi(STR0022), OemToAnsi(STR0048), {'ok'} )//"Nao foi realizado calculo. Verifique se algum registro foi selecionado!"  ##"OK"
	Else
		//RetSituacao( SRA->RA_FILIAL , SRA->RA_MAT , .T. )//, NIL , .T. )
		//Independentemente da data das férias, assim que executar o calculo,
		//o status sera alterado para 'F'
		dbSelectArea("SRA")
		RecLock("SRA",.F.,.T.)
			SRA->RA_SITFOLH := "F"
		SRA->( MsUnLock() )
		oBrowseUp:Refresh()
		oMrkBrwDwn:Refresh(.T.)
	Endif

	RestArea(RHIArea)

Endif

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FillDescPd  ³ Autor ³ Erika Kanamori        ³ Data ³ 14/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche descricao de verba no campo RC_DESCPD.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FillDescPd()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function FillDescPd()
Local cDescPD	:= ""
Local oModel    := FWModelActive()
Local nOperation:= oModel:GetOperation()

If nOperation <> MODEL_OPERATION_INSERT
	cDescPd := fDesc('SRV',SRC->RC_PD,'RV_DESC',,xFilial("SRV", SRC->RC_FILIAL))
EndIf

Return cDescPd




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriaPerAqu  ³ Autor ³ Erika Kanamori        ³ Data ³ 08/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche itens de calculo (RHJ) de acordo com RHI_DTINI.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CriaPerAqu()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function CriaPerAqu()
Local oModel    := FWModelActive()
Local nOperation:= oModel:GetOperation()
Local oModelRHJ := oModel:GetModel( 'RHJDETAIL' )
Local oModelRHI	:= oModel:GetModel( 'RHIMASTER' )
Local nLinAux	:= 1
Local nLinha	:= 0
Local nAux		:= 0
Local nDFerVen	:= 0 //Dias de ferias vencidas
Local nDFerAVe	:= 0 //Dias de ferias a vencer
Local nDFerPag	:= 0
Local aPerFerias:= {}
Local aDiasFer	:= {}
Local lRet		:= .T.

If Empty(M->RHI_PROCES) .or. Empty(M->RHI_ROTEIR) .or. Empty(M->RHI_PERIOD)
	Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0021), 1, 0 )//"Help" ## "Os campos Processo, Roteiro ou Periodo não estao preenchidos."
	M->RHI_DTINI := ""
	return .F.
Endif

If RHI_DTINI <= RHI_ADMISSA     //Data Inicio Férias não poderá ser menor que data de admissao
	Return .F.
Endif

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE //.And. RHI->RHI_STATUS $ "1*2")

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se jah contem linhas (caso haja alteracao da data na 	  ³
	//³ inclusao), apaga as linhas jah geradas e gera novamente   ³
	//³ com a data correta.									 	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	nLinha:= oModelRHJ:Length()
	If nLinha <> If(nOperation == 3,1,0)
		For nLinAux:= 1 to nLinha
			If !(oModelRHJ:IsDeleted(nLinAux))
				oModelRHJ:SetLine(nLinAux)
				oModelRHJ:DeleteLine( ,.T.)
		  	Endif
		End
		oModelRHJ:AddLine(.T.)
		nLinha:= nLinha+1
	Endif

	CargaFerias(@aPerFerias, M->RHI_DTINI)

	If !(len(aPerFerias) < 1)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui linhas novas na grid do RHJ 	  					  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		For nAux:= 1 to len(aPerFerias)

			If oModelRHJ:IsInserted(nLinha)
				oModelRHJ:SetLine(nLinha)
				//oModelRHJ:LoadValue('RHJ_FILIAL', SRA->RA_FILIAL )
				//oModelRHJ:LoadValue('RHJ_MAT'   , SRA->RA_MAT )
				oModelRHJ:LoadValue('RHJ_DTINI' , M->RHI_DTINI )

				oModelRHJ:LoadValue('RHJ_DTBASE', aPerFerias[nAux, 1] )
				oModelRHJ:LoadValue('RHJ_DTFIM' , aPerFerias[nAux, 2] )

				oModelRHJ:LoadValue('RHJ_DIASDI', aPerFerias[nAux, 3] ) //dias de direito
				oModelRHJ:LoadValue('RHJ_DFERAA', aPerFerias[nAux, 4] ) //dias proporcionais
				oModelRHJ:LoadValue('RHJ_DFERVA', aPerFerias[nAux, 5] ) //dias vencidos
				oModelRHJ:LoadValue('RHJ_DIASAN', aPerFerias[nAux, 6] ) //dias antecipados
				oModelRHJ:LoadValue('RHJ_DFERAN', aPerFerias[nAux, 7] ) //dias pagos
			Else
				lRet:= .F.
			Endif

			nLinha:= nLinha+1
			oModelRHJ:AddLine(.T.)

		End

	    /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega dias de ferias vencidas e proporcionais e 	   ³
		//³ desconta dias pagos.								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	    Aeval(aPerFerias,{|x| (nDFerVen += x[5], nDFerAVe += x[4], nDFerPag += x[7])})
		If nDFerVen > nDFerPag
			nDFerVen:= nDFerVen - nDFerPag
		Else
			nDFerVen:= 0
			nDFerPag:= nDFerPag - nDFerVen
			nDFerAVe:= Max(nDFerAVe - nDFerPag, 0)
		Endif
	else
		Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0037) +CRLF +OemToAnsi(STR0038), 1, 0 )//"Help" ## "Os campos Processo, Roteiro ou Periodo não estao preenchidos."
		lRet := .F.
	Endif

 	oModelRHI:LoadValue('RHI_DFERVE' , nDFerVen )
	oModelRHI:LoadValue('RHI_DFERPR' , nDFerAVe )


Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na primeira linha do grid.  					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
oModelRHJ:SetLine(1)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CargaFerias ³ Autor ³ Erika Kanamori        ³ Data ³ 28/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega aPerFerias, atualizando dados de acordo com dDataIni  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³aPerFerias : deve ser passado por referencia.                 ³±±
±±³          ³dDataIni	 : data das ferias (data final para atualizar dados.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function CargaFerias( aPerFerias, dDataIni )
Local dDataBase		:= CtoD("//")
Local nAux			:= 0
Local nDiasAdquir	:= 0
Local aDiasFer		:= {}
Local dDataFim		:= CtoD("//")
Local cVerba        := fGetCodFol("0072")

aPerFerias:= {}

dbSelectArea("SRF")
SRF->(DbSetOrder( RetOrdem( "SRF", "RF_FILIAL+RF_MAT+RF_PD+DTOS(RF_DATABAS)" ) ))
SRF->(dbSeek(xFilial("SRF")+SRA->RA_MAT+cVerba))
While SRF->(RF_FILIAL+RF_MAT+RF_PD) == xFilial("SRF")+SRA->RA_MAT+cVerba
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aPerFerias                     					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If SRF->RF_STATUS == "1" .And. SRF->RF_DATABASE <= YearSum(dDataIni,1)
		aAdd(aPerFerias, { 	SRF->RF_DATABASE,;	//1 - data inicial do periodo
							SRF->RF_DATAFIM,;	//2 - data final do periodo
							SRF->RF_DIASDIR,;	//3 - dias de direito
							SRF->RF_DFERAAT,;	//4 - proporcionais
							SRF->RF_DFERVAT,;	//5 - vencidos
							SRF->RF_DIASANT,;	//6 - antecipados
							SRF->RF_DFERANT})	//7 - pagos
	Endif
	dDataBase:= SRF->RF_DATAFIM + 1
	dDataFim := YearSum (SRF->RF_DATAFIM, 1)
	SRF->(dbSkip())
End

dDataBase:= Iif(Empty(dDataBase), SRA->RA_ADMISSA, dDataBase)
dDataFim := Iif(Empty(dDataFim), YearSum(dDataBase -1, 1), dDataFim)

//Verifica se nao foi encontrado lancto no SRF para todo o periodo solicitado
If cPaisLoc == "ARG" .And. dDataBase <= dDataIni
	aPerFerias:= {}
	return
Endif


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria periodos aquisitivos, se necessario				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
While dDataBase <= dDataIni
	aAdd(aPerFerias, {	dDataBase,;
						dDataFim,;
						0,;                	// 3 - dias de direito
						0,; 				// 4 - proporcionais
						0,; 				// 5 - vencidos
						0,; 				// 6 - antecipados
						0				}) 	// 7 - pagos

	dDataBase:= aPerFerias[len(aPerFerias), 2] + 1
	dDataFim := YearSum (aPerFerias[len(aPerFerias), 2], 1)
End


If !(Len(aPerFerias) < 1)
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza dias proporcionais de ferias de acordo com dDataIni ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	For nAux:= 1 to len(aPerFerias)
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o periodo ainda nao esta vencido, calcula dias proporc.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !(aPerFerias[nAux,5] > 0)

			dDataBase:= aPerFerias[nAux, 1]
			dDataFim:= Iif((dDataIni < aPerFerias[nAux, 2]), dDataIni, aPerFerias[nAux, 2])
			If cPaisLoc == "DOM"
				fDiaFerDOM(dDataBase, dDataFim, @aDiasFer)
			ElseIf cPaisLoc == "COS"
				fDiaFerCOS(dDataBase, dDataFim, @aDiasFer)
			ElseIf cPaisLoc == "CHI"
				fDiaFerCHI(dDataBase, dDataFim, @aDiasFer)	
			ElseIf cPaisLoc $ "COL|PER|PAR"
				fDiaFerCOL(dDataBase, dDataFim, @aDiasFer)	
			EndIf
			If !(cPaisLoc $ "ARG|MEX|PER|PAR")    //Argentina nesta rotina não controla dias proporcionais nas férias
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Desconta dias pagos.                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				nDiasAdquir:= aDiasFer[2]
				If aPerFerias[nAux, 7] > 0
					nDiasAdquir:= Min(nDiasAdquir /*- aPerFerias[nAux, 7]*/, 0)
				Endif

				If dDataIni >= aPerFerias[nAux, 1] .And. dDataIni <= aPerFerias[nAux, 2]
					aPerFerias[nAux, 3] := aDiasFer[1]
					aPerFerias[nAux, 4] := nDiasAdquir
				Else
					aPerFerias[nAux, 3] := aDiasFer[1]
					aPerFerias[nAux, 4] := 0
					aPerFerias[nAux, 5] := nDiasAdquir
				EndIf

			EndIf
		EndIf
	End
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fDiaFerDOM  ³ Autor ³ Erika Kanamori        ³ Data ³ 26/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula dias de ferias para Republica Dominicana.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³dDataBase	: Data inicial do periodo aquisitivo                ³±±
±±³          ³dDataFim	: Data final do periodo aquisitivo                  ³±±
±±³          ³aDiasFer	: Array a ser passado por referencia                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fDiaFerDOM(dDataBase, dDataFim, aDiasFer)
Local nAnosTrab:= 0
Local nDiasTot:= 0
Local nPos:= 0

aDiasFer:= { , }

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dias de ferias (dias de direito).                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nAnosTrab:= DateDiffYear( dDataBase, SRA->RA_ADMISSA)
nPos:= fPosTab( "S006", nAnosTrab, ">=", 04, nAnosTrab, "<=", 05 )
If nPos > 0
	aDiasFer[1]:= fTabela("S006", nPos, 06)
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dias de ferias proporcionais.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nDiasTot:=  Min(dDataFim - dDataBase + 1, 365)
nAvosFer:= aDiasFer[1]/365 * nDiasTot

aDiasFer[2]:= nAvosFer

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DistDFerias ³ Autor ³ Erika Kanamori        ³ Data ³ 20/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Distribui automaticamente os dias de ferias (RHI_DFERIAS) nos ³±±
±±³          ³periodos aquisitivos (RHJ) criados previamente.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DistDFerias()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function DistDFerias()
Local oModel      	:= FWModelActive()
Local nOperation 	:= oModel:GetOperation()
Local oModelRHJ 	:= oModel:GetModel( 'RHJDETAIL' )
Local nDFerias		:= M->RHI_DFERIA
Local nLinha		:= 0
Local nLinAux		:= 0
Local nDiasADesc	:= 0
Local dDtBase		:= 0
Local dDtIni
Local dDtFim
Local nDFerVenc		:= 0
Local nDferAVen		:= 0
Local nDFerPago		:= 0
Local nDFerAdia		:= 0
Local lRet			:= .T.
Local cCondicao		:= ""
Local oViewRHJ		:= FWViewActive()
Local aSaveLines	:= FWSaveRows()

If nOperation == MODEL_OPERATION_INSERT .Or. (nOperation == MODEL_OPERATION_UPDATE .And. M->RHI_STATUS $ "1*2")
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem dias de ferias que ainda estao para descontar  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("RHJ")
	RHJ->(DbSetOrder( RetOrdem( "RHJ", "RHJ_FILIAL+RHJ_MAT+DTOS(RHJ_DTBASE)+DTOS(RHJ_DTINI)" ) ))
	nLinha:= oModelRHJ:Length()
	If nLinha <> If(nOperation==3,1,0)
		nLinAux:= 1
		While ((nLinAux < nLinha).And. nOperation == 3) .or.((nLinAux <= nLinha).And. nOperation == 4)
			If !(oModelRHJ:IsDeleted(nLinAux))
				nDiasAPag:= 0
				If !(nDFerias == 0)

					dDtBase:= oModelRHJ:GetValue('RHJ_DTBASE', nLinAux)
					dDtIni:= oModelRHJ:GetValue('RHJ_DTINI', nLinAux)
					cCondicao		:= "RHJ_DTBASE== '" + dtoc(dDtBase) + "' .AND. RHJ_DTINI== '" + dtoc(dDtIni) + "'  .AND. !Empty(RHJ_DIASPG) .AND. RHJ_STATUS $ '0 ' .AND. RHJ_MAT == '" + SRA->RA_MAT + "' "
					nDiasADesc := 0
					dbSelectArea("RHJ")
					("RHJ")->(dbSetOrder(1))
					("RHJ")-> (DBSETFILTER( {||&cCondicao}, cCondicao))
					("RHJ")->(dbGoTop())
					If !(("RHJ")->(EOF()) )
						nDiasADesc := RHJ->RHJ_DIASPG
					EndIf

					dDtBase:= oModelRHJ:GetValue('RHJ_DTBASE', nLinAux)
					nDiasADesc:=0
					RHJ->(dbGoTop())
					If (RHJ->(dbSeek(xFilial("RHJ")+SRA->RA_MAT+ DtoS(dDtBase))))
						While RHJ->(RHJ_FILIAL+RHJ_MAT+DtoS(RHJ_DTBASE)) == xFilial("RHJ")+SRA->RA_MAT+DtoS(dDtBase)
							If RHJ->RHJ_STATUS $ 	"1 " .And. RHJ->RHJ_DTINI <> RHI->RHI_DTINI
								nDiasADesc+= RHJ->RHJ_DIASPG
							Endif
							RHJ->(dbSkip())
						End
					Endif

					/*
					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pega dias de ferias vecidos, a vencer e pagos             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					nDFerVenc:= oModelRHJ:GetValue('RHJ_DFERAA', nLinAux)
					nDferAVen:= oModelRHJ:GetValue('RHJ_DFERVA', nLinAux)
					nDFerPago:= oModelRHJ:GetValue('RHJ_DFERAN', nLinAux)
					nDFerAdia:= oModelRHJ:GetValue('RHJ_DIASAN', nLinAux)

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula quantos dias devem ser descontados do periodo aquisitivo posicionado. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					nDiasAPag:= nDFerVenc + nDferAVen + nDFerAdia - nDFerPago - nDiasADesc

					If nDiasAPag > nDFerias
						nDiasAPag:= nDFerias
					Endif

				Endif

				oModelRHJ:SetLine(nLinAux)
				oModelRHJ:LoadValue('RHJ_DIASPG', nDiasAPag )

				nDFerias:= nDFerias - nDiasAPag

			Endif
			nLinAux:= nLinAux + 1
		End

	Endif
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na primeira linha do grid.  					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

FWRestRows(aSaveLines)
If oViewRHJ != Nil
	oViewRHJ:Refresh()
EndIf

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VldActvM31  ³ Autor ³ Erika Kanamori        ³ Data ³ 21/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se o formulario deve ser aberto ou nao.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³VldActvM31( oModel )                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function VldActvM31(oModel)

Local nOperation 	:= oModel:GetOperation()
Local lRet			:= .T.
Local cVrbDescVac	:= ""

If nOperation == MODEL_OPERATION_UPDATE .And. !(RHI->RHI_STATUS $ "1*2")
	Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0031 + CRLF + STR0032), 1, 0 )//"Help" ## "Estas ferias jah foram calculadas e fechadas." ## "Portanto o registro não pode ser modificado"
	lRet:= .F.
Endif

If nOperation == MODEL_OPERATION_DELETE .And. !(RHI->RHI_STATUS $ "1*2")
	Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0031 + CRLF + STR0033), 1, 0 )//"Help" ## "Estas ferias jah foram calculadas e fechadas." ## "Portanto o registro não pode ser deletado"
	lRet:= .F.
Endif

If SRA->RA_SITFOLH $ 'F' .And. 	nOperation == MODEL_OPERATION_DELETE
		dbSelectArea( "SRA" )
		RecLock("SRA",.F.,.T.)
		SRA->RA_SITFOLH := " "
		MsUnlock()
		oBrowseUp:Refresh()
		oMrkBrwDwn:Refresh(.T.)
Endif


If !(cPaisloc $ "ARG |PAR")
	cVrbDescVac:= fGetCodFol("0786")
	If Empty(cVrbDescVac)
		Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0034), 1, 0 )//"Help" ## "Nao existe verba de desconto de vacaciones (ID 0786)."
		lRet:= .F.
	Else
		dbSelectArea("RCM")
		RCM->(dbSetOrder(RetOrdem( "RCM", "RCM_FILIAL+RCM_PD" ) ))
		If !(dbSeek(xFilial("RCM") + cVrbDescVac))
			Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0035), 1, 0 )//"Help" ## "A verba de desconto de vacaciones (ID 0786) nao esta cadastrada nos tipos de ausencia."
			lRet:= .F.
		Endif
	Endif
Endif
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CommiM031   ³ Autor ³ Erika Kanamori        ³ Data ³ 21/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de commit. Grava informacoes e gera/atualiza ausencia  ³±±
±±³          ³refente as ferias lancadas.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CommiM031( oModel )                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function CommiM031(oModel)
Local lRet			:= .T.

If  oModel:VldData() // verificar se jah foi validado
	lRet := fCriaGozFer()
	If lRet
		FwFormCommit(oModel)
		oModel:DeActivate()
	Else
    	oModel:DeActivate()
 	EndIf
    lRet:=.T.
Else
	Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0036), 1, 0 )//"Help" ## "Erro ao gravar formulario."
 	aErro   := oModel:GetErrorMessage()
  	oModel:DeActivate()
Endif

oBrowseUp:Refresh()
oMrkBrwDwn:Refresh(.T.)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCriaGozFer ³ Autor ³ Erika Kanamori        ³ Data ³ 22/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria/atualiza/delete ausencia referente as ferias lancadas.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fCriaGozFer()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fCriaGozFer()
Local oModel		:= FWModelActive()
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.
Local cSequencia	:= 0
Local cTipoAfa		:= ""
Local cVrbDescVac	:= ""
Local cSituac		:= ""
Local cFilRCH		:= xFilial("RCH")
Local cFilRCM		:= xFilial("RCM")
Local cRot			:= fGetRotOrdinar()   //Obtendo qual roteiro de calculo de Folha de Pagamento
Local cProcesso		:= M->RHI_PROCES
Local cPerRHI		:= M->RHI_PERIOD
Local cPagRHI		:= M->RHI_NUMPAG
Local cRotRHI		:= M->RHI_ROTEIR
Local cMes			:= StrZero(MONTH(M->RHI_DTINI),2)
Local cAno			:= StrZero(YEAR(M->RHI_DTINI),4)


Local cPer			:= ""
Local cPago			:= ""
Local cCondicao		:= "Empty(RCH_DTFECH) .AND. RCH_PER == '" + cPerRHI + "' .AND. RCH_ROTEIRO $ '" + cRotRHI + "' .AND. RCH_PROCES == '" + cProcesso + "' .AND. RCH_NUMPAG == '"+cPagRHI+"' "
Local dPerDtIRCH
Local aPerAberto	:= {}
Local nAux			:= 0

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca verba de gozo de ferias.     					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cVrbDescVac:= If(!Empty(fGetCodFol("0786")), fGetCodFol("0786"), fGetCodFol("072"))


If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT
	If empty(cRot) .Or. cRot == ""
		lRet 	:= .F.
	Else
		//Obtencao Periodo e Pago em LIQ (RY_TIPO=1), equivalente ao periodo usado na rotina de vacaciones
		lRet:=.F.
		dbSelectArea("RCH")
		("RCH")->(dbSetOrder(5))
		("RCH")-> (DBSETFILTER( {||&cCondicao}, cCondicao))
		("RCH")->(dbGoTop())
		dPerDtIRCH:= RCH->RCH_DTINI
		("RCH")->(DbClearFilter())
		("RCH")->(dbCloseArea())

		If !empty(dPerDtIRCH)
			fRetPerComp(cMes			,;		// Obrigatorio - Mes para localizar as informacoes
						cAno			,;		// Obrigatorio - Ano para localizar as informacoes
						nil				,;		 // Opcional - Filial a Pesquisar
						cProcesso		,;		// Opcional - Filtro por Processo
						cRot			,;		// Opcional - Filtro por Roteiro
						@aPerAberto	,,)		// Por Referencia - Array com os periodos Abertos

			If (len(aPerAberto) >=1)
				For nAux:= 1 to len(aPerAberto)
					If dPerDtIRCH>= aPerAberto[nAux,5]  .And.  dPerDtIRCH <= aPerAberto1[nAux,6] //aPerAberto[nAux,5] >= dPerDtIRCH .And.  dPerDtIRCH <= aPerAberto1[nAux,6]
						cPer	:= aPerAberto[nAux,1]
						cPago	:= aPerAberto[nAux,2]
						lRet	:= .T.
						Exit
					Endif
				Next nAux
			EndIf
		EndIf
	EndIf

	If !lRet
		alert(OemtoAnsi(STR0051)+CRLF+OemtoAnsi(STR0052)) //"Nao existe Periodo cadastrado  sem data de fechamento, com situacao normal, e com procedimento do tipo Folha de Pagamento."  ### "Será necessário o cadastro de um período com estas caracterísiticas."
		Return (lRet)
	EndIf

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca o tipo de ausencia da verba de gozo de ferias	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cTipoAfa:= gp240RetCont("RCM", RetOrdem( "RCM", "RCM_FILIAL+RCM_PD" ), cFilRCM + cVrbDescVac, "RCM_TIPO")

	If (empty(cTipoAfa) .or. cTipoAfa=="" )
		Alert(OemtoAnsi(STR0053)+CRLF+OemtoAnsi(STR0054)) //"Não existe tipo de ausências associado com a verba que possua ID de Férias."  ### "Será necessário cadastrar Tipo de Ausencia com estas características."
		lRet:= .F.
		Return(lRet)
	ElseIf cPaisLoc =="ARG"
		cSituac	:= RCM->RCM_SITUAC
	EndIf

EndIf

If lRet .AND. nOperation == MODEL_OPERATION_INSERT

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca o proximo numero sequencial.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SR8")
	SR8->(DbSetOrder( RetOrdem( "SR8", "R8_FILIAL+R8_MAT+R8_SEQ" ) ))
	If SR8->(MsSeek(xFilial("SR8")+M->RHI_MAT))
		While SR8->(R8_FILIAL+R8_MAT) == xFilial("SR8")+M->RHI_MAT
			cSequencia:= SR8->R8_SEQ
			SR8->(dbSkip())
		End
		cSequencia:= StrZero(Val(cSequencia) + 1, 3)
	Else
		cSequencia:= "001"
	Endif


	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o registro referente as ferias lancadas          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RecLock("SR8", .T.)
		SR8->R8_FILIAL	:= xFilial("SR8")
		SR8->R8_MAT		:= M->RHI_MAT
		SR8->R8_SEQ		:= cSequencia
		SR8->R8_DATA	:= Date()
		If cPaisLoc == "PAR"
			SR8->R8_TIPO	:= "3"
		EndIf
		SR8->R8_TIPOAFA	:= cTipoAfa
		SR8->R8_PD		:= cVrbDescVac
		SR8->R8_DATAINI	:= M->RHI_DTINI
		SR8->R8_DURACAO	:= M->RHI_DFERIA
		SR8->R8_DATAFIM	:= M->RHI_DTFIM
		SR8->R8_DIASEMP := 999
		SR8->R8_DPAGAR	:= M->RHI_DFERIA
		SR8->R8_CONTINU	:= "2"
		If cPaisLoc <> "PAR"
			SR8->R8_DNAPLIC	:= 0
		EndIf
		SR8->R8_DPAGOS	:= 0
		SR8->R8_PER		:= cPer
		SR8->R8_NUMPAGO	:= cPago
		SR8->R8_NUMID	:= "SR8" + M->RHI_MAT + cVrbDescVac + Dtos(M->RHI_DTINI)
		SR8->R8_SDPAGAR	:= M->RHI_DFERIA
		SR8->R8_PROCES	:= cProcesso
		If (cPaisLoc == "ARG"  .And. cSituac <> "")
			SR8->R8_SITUAC	:= cSituac
		EndIf

	MsUnlock()
	SR8->(dbCloseArea())

Elseif lRet
	dbSelectArea("SR8")
	SR8->(DbSetOrder( RetOrdem( "SR8", "R8_FILIAL+R8_NUMID" ) ))
	If SR8->(MsSeek(xFilial("SR8")+"SR8"+M->RHI_MAT+cVrbDescVac+DtoS(M->RHI_DTINI)))

		If nOperation == MODEL_OPERATION_UPDATE
			RecLock("SR8",.F.)
				SR8->R8_DATA	:= Date()
				SR8->R8_TIPOAFA	:= cTipoAfa
				SR8->R8_DURACAO	:= M->RHI_DFERIA
				SR8->R8_DATAFIM	:= M->RHI_DTFIM
				SR8->R8_DPAGAR	:= M->RHI_DFERIA
				SR8->R8_PER		:= cPer
				SR8->R8_NUMPAGO	:= cPago
				SR8->R8_SDPAGAR	:= M->RHI_DFERIA
				SR8->R8_PROCES	:= cProcesso
				If (cPaisLoc == "ARG"  .And. cSituac <> "" .And. SR8->R8_SITUAC <> cSituac)  //Garantia que não foi alterando o campo R8_SITUAC via GPEA240
					SR8->R8_SITUAC	:= cSituac
				EndIf

			SR8->( MsUnlock() )
			SR8->(dbCloseArea())

		Elseif nOperation == MODEL_OPERATION_DELETE
			RecLock("SR8",.F.)
				SR8->( dbDelete() )
			SR8->( MsUnlock() )
			SR8->(dbCloseArea())
		Endif
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldPerVACºAutor  ³ Equipe RH          º Data ³  14/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o processo que deseja-se calcular, esta dispo- º±±
±±º          ³ nivel para calculo.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Booleano (.T. Continua com o calculo, .F. Nao continua     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM031                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VldPerVAC()
Local lRet 		:= .T.
Local aPerAtual := {}


If Empty(cProces) .Or. Empty(cRoteiro) .Or. Empty(cPeriodo) //Não inclui cNumPag porque não é obrigatorio
	lRet 		:= .F.
	Return( lRet)
EndIf

lRet := fGetPerAtual( @aPerAtual, xFilial("RCH"), cProces, cRoteiro ) // Busca o periodo aberto para trabalho
If lRet
If ((cPeriodo <> aPerAtual[1,1]) .Or. (cNumPag <> aPerAtual[1,2]))
		Alert(OemToAnsi(STR0057))  //"Calculo não será executado, pois período escolhido não está Selecionado"
		lRet := .F.
	EndIf
EndIf

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fDiaFerCHI  ³ Autor ³ Alfredo Medrano       ³ Data ³ 05/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula dias de ferias para Chile.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³dDataBase	: Data inicial do periodo aquisitivo                ³±±
±±³          ³dDataFim	: Data final do periodo aquisitivo                  ³±±
±±³          ³aDiasFer	: Array a ser passado por referencia                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/  
Function fDiaFerCHI(dDataBase, dDataFim, aDiasFer)
Local nAnosTrab:= 0
Local nDiasTot:= 0
Local nPos:= 0 

aDiasFer:= { , }

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dias de ferias (dias de direito).                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nAnosTrab:= DateDiffYear( dDataBase, SRA->RA_ADMISSA) 
nPos:= fPosTab( "S008", SRA->RA_KEYLOC, "==", 04, nAnosTrab, "<=", 05 )
If nPos > 0
	aDiasFer[1]:= fTabela("S008", nPos, 06)
Else
	aDiasFer[1]:= 0
Endif                                

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dias de ferias proporcionais.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nDiasTot:=  Min(dDataFim - dDataBase + 1, 365)
nAvosFer:= aDiasFer[1]/365 * nDiasTot

aDiasFer[2]:= nAvosFer     

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fDiaFerCOL  ³ Autor ³ Alfredo Medrano       ³ Data ³ 08/01/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula dias de ferias para Colombia y Perú.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³dDataBase	: Data inicial do periodo aquisitivo                ³±±
±±³          ³dDataFim	: Data final do periodo aquisitivo                  ³±±
±±³          ³aDiasFer	: Array a ser passado por referencia                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/  
Function fDiaFerCOL(dDataBase, dDataFim, aDiasFer)
Local nAnosTrab:= 0
Local nDiasTot:= 0
Local nPos:= 0 
Local cTab :="S013"

aDiasFer:= { , }
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dias de ferias (dias de direito).                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nAnosTrab:= DateDiffYear( dDataBase, SRA->RA_ADMISSA) 
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtiene la posición de la tabla alfanumérica S013 si cumple con la siguiente condición ³
//³nAnosTrab >= 05 .And. nAnosTrab <= 06 donde 05 y 06 son las columnas de la tabla S013. ³
//³nAnosTrab = años trabajados                                                            ³
//³05 + 1 = columna Año inferior                                                          ³
//³06 + 1 = Columna Año superior                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nPos:= fPosTab(cTab, nAnosTrab, ">=", 05, nAnosTrab, "<=", 06)

If nPos > 0
	aDiasFer[1]:= fTabela(cTab, nPos, 07)
Else
	aDiasFer[1]:= 0
Endif                                

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dias de ferias proporcionais.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nDiasTot:=  Min(dDataFim - dDataBase + 1, 365)
nAvosFer:= aDiasFer[1]/365 * nDiasTot

aDiasFer[2]:= nAvosFer     

Return()
