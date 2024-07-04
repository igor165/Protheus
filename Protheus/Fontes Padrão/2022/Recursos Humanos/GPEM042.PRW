#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM042.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o      ³ GPEM042  ³ Autor   ³ Erika Kanamori                  ³ Data ³ 10/08/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³ Calculo de Rescisao para o Modelo II                        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe     ³ GPEM042()                                                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Generico                                                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ FNC            ³  Motivo da Alteracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V.³07/11/11³00000020276/2011³ Criação da função de retorno do período ativo ³±±
±±³             ³        ³                ³ e correção de error log na aplicação da resc. ³±±
±±³Christiane V.³30/11/11³00000020276/2011³ Correção de Error Log no cálculo da rescisão. ³±±
±±³Marcelo F.   ³12/03/11³ARG11.6_RH      ³ Atualizacao do processo de rescisao do modelo ³±±
±±³             ³        ³REQ005          ³ II para localizacao Argentina.                ³±±
±±³Marcelo F.   ³02/04/11³ARG11.6_RH      ³ Ajustes Rescisao Argentina Modelo 2.		  ³±±    
±±³Raquel Hager ³23/05/12³00000012611/2012³ Correcao do SetRelation, nomenclatura de campo³±±
±±³             ³        ³			TF2192³ e gravacao dos dados na tabela SRC.           ³±±   
±±³Raquel Hager ³01/06/12³00000014111/2012³ Remocao da visualizacao das opcoes do MenuDef ³±± 
±±³             ³        ³          TFCDCW³ para evitar conflitos com instrucao SetMenudef³±± 
±±³Raquel Hager ³27/06/12³00000016367/2012³ Correcao na funcao Gp042FerVenc para correta  ³±± 
±±³             ³        ³          TFGC16³ selecao do roteiro de rescisao.               ³±±
±±³Raquel Hager ³28/06/12³00000016367/2012³ Correcao na funcao Gp042FerVenc para correta  ³±± 
±±³             ³        ³          TFGC16³ selecao do rot. de rescisao e dias vencidos.  ³±± 
±±³Glaucia M.   ³13/07/12³00000017919/2012³ Funcao fCommiM042 readequada para apos exclu- ³±± 
±±³             ³        ³          TFJESM³ sao de calculo, volte ao browse inicial.      ³±± 
±±³Glaucia M.   ³13/08/12³00000020623/2012³ O browse inicial inferior, sua ativacao só    ³±± 
±±³             ³        ³      	TFMX68³ apos o AddRelation, para que o relaciomento   ³±±  
±±³             ³        ³      	      ³ funcione adequadamente.                       ³±±  
±±³Glaucia M.   ³12/08/12³00000020623/2012³ Desabiltar botoes de acaoes relacionadas para ³±± 
±±³             ³        ³      	TFMX68³ Apagar e botoes de calculo para Visualizar.   ³±±  
±±³Glaucia M.   ³27/09/12³00000023714/2012³ Atualizar o browse inicial após aplicação da  ³±± 
±±³             ³        ³      	TFTZY9³ rescisão. Inserção e retirada variável Legenda³±± 
±±³Leandro D.   ³19/12/12³                ³ Ajuste pois MVC mudou.                        ³±± 
±±³Glaucia M.   ³05/02/13³00000001501/2013³ Preparar campos RG_DFERVEN e RG_DFERPRO, para ³±± 
±±³             ³        ³      	TGMQ59³ funcionar para todos paises. Retirada da fun- ³±±
±±³             ³        ³      	      ³ cao Gp042FerProp. Ajuste de dicionario.       ³±± 
±±³Will C.      ³08/09/14³TQMQKE          ³ Declaracao da variável Normal e Descanso como ³±± 
±±³             ³        ³      	      ³ Private para que não ocorra ErrorLog ao carre-³±±
±±³             ³        ³      	      ³ gar a estrutura desses campos via MVC         ³±± 
±±³jonathan Glez³18/09/15³PCREQ-2095      ³Funcion fVPerRes()                             ³±±
±±³             ³        ³      	       ³->Se comenta variables default  lViaRot        ³±±
±±³             ³        ³      	       ³->se cambia la inicializacion de la variable   ³±±
±±³             ³        ³      	       ³cPagSRG se le agrega un POSICIONE.             ³±±
±±³             ³        ³      	       ³->se agrega getArea()                          ³±±
±±³GSantacruz   ³09/11/2015³PCREQ-5930    ³Merge 12.1.8                                   ³±±
±±³M.Camargo    ³15/05/16³TVDMLQ         ³ Localización Rep .Dominicana Mod 2. Al aplicar ³±± 
±±³             ³        ³               ³ finiquito genera registro en RCP. Al deshacer  ³±±
±±³             ³        ³               ³ finiquito se elimina el registro generado en   ³±±
±±³             ³        ³               ³ RCP.Se habilita uso DE MV_SITRES para Rep Dom. ³±±
±±³M. Camargo   ³10/11/16³TSSERMI01-58   ³Modificación por Localizacion para Chile Mod 2  ³±±
±±³M.Camargo    ³25/10/16³MRH-1134       ³ Se modifica fgenpropchi para cuando el empleado³±± 
±±³             ³        ³               ³ sea finiquitado en su aniversario.             ³±±
±±³M.Camargo    ³16/11/16³TSSERMI01-56   ³ Se declara var CComp para mexico y se habilita ³±±
±±³             ³        ³               ³ var cModel para México. Se quita redefinición  ³±±
±±³             ³        ³               ³ var cPAGSRG                                    ³±±
±±³Isabel N.    ³15/09/17³DRHPAG-4561    ³Inicializa variáveis p/ Modfol Modelo 2.        ³±±
±±³Raul Ortiz   ³16/11/16³TSSERMI01-224  ³Se inhabilita la inclusión desde la filial a la ³±±
±±³             ³        ³               ³que no corresponde el Empleado                  ³±±
±±³Oscar G.     ³20/06/19³DMINA-6900     ³Se bifurca la validación de la variable lRescDis³±±
±±³             ³        ³               ³para paises diferente de Brasil. (COL)          ³±±
±±³M.Camargo    ³19/09/19³DMINA-7192     ³Se habilita uso DE MV_SITRES para MEX|COL.Al a- ³±± 
±±³             ³        ³               ³plica finiquito genera registro en RCP.         ³±±
±±³             ³        ³               ³Al deshacer finiquito ya no se actualiza situa- ³±±
±±³             ³        ³               ³ ción del empleado ni se elimna reg en RCP      ³±±
±±³M.Camargo    ³11/11/19³DMINA-7670     ³Se Modifica fgenRCP para grabar campos de SRG a ³±± 
±±³             ³        ³               ³RCP para País México                            ³±±
±±³M.Camargo    ³27/11/19³DMINA-7850     ³Se Modifica fgenRCP para que no genere registro ³±± 
±±³             ³        ³               ³si encuentra una baja previa para País México   ³±±
±±³José Gonzalez³03/09/20³DMINA-9890     ³Se agrega función LeeSRG:() para obtener y      ³±± 
±±³             ³        ³               ³ validar el campo RG_EFETIVA                    ³±±
±±³Oscar G.     ³27/05/21³DMINA-12218    ³Al realizar Inclusion,  se valida si el empleado³±±
±±³             ³        ³               ³ya ha sido dado de baja (RA_SITHFOLH = D). (MEX)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*TODA VEZ QUE ESTA ROTINA FOR ALTERADA, OBRIGATORIAMENTE TESTAR RECISAO COLETIVA - GPEM043*/
/*Regra Argentina esta disponivel no chamado TGMQ59*/

Function GPEM042() 

Local aArea         := GetArea()
Local aCoors  		:= FWGetDialogSize( oMainWnd )
Local oPanelUp, oFWLayer, oPanelDown,  oRelacSRG
Local cMsgDic		:= ""


//Private oBrowseUp
Local oDlgPrinc
Private oBrowseUp, oBrowseDwn
Private lAtualiza   := .F.
Private cAtualSit   := GetMvRH( "MV_SITRES", .F., "2" )
Private Normal      := 0.00
Private Descanso    := 0.00 

Private nOpcFinC		:= 1 //Modificar Situacion del Empleado (nOpcFinC = 1) 
Private nTipFinC		:= 0 //Finiquito -  Aplicar  (nTipFinC = 1) Deshacer (nTipFinC = 2)

//Variaveis de controle - QTD Minima para calculo com GRID (MV_MINGRID)
Private nRecRCHAux	:= 0
Private nTotCalFunc	:= 0
Private nTotCalReg	:= 1
Private lRutAuto := isBlind() //variable utilizada para rutina automática
If cPaisLoc $ "DOM|MEX"
	Private cCompl := ""
EndIf
Private cModel := "SRGMASTER"
If cPaisLoc $ "DOM|CHI|COL|MEX|PER|PAR"
	If cPaisLoc $ "DOM|CHI"
		cAtualSit   := GetMvRH( "MV_SITRES", .F., "1" )
	Else
		cAtualSit   := GetMvRH( "MV_SITRES", .F., "2" )
	EndIF
	cModel := "GPEM040_MSRG"
Else
	cAtualSit   := GetMvRH( "MV_SITRES", .F., "2" )
EndIf
Private cModFol 	:= GetMvRh( "MV_MODFOL", .F., "1" )

private aSRG:={}

If cAtualSit == "2"
	lAtualiza := .T.
Endif	

If cModFol == "2" .And. !(cPaisLoc $ "BRA")
	lRescDis := .F.
EndIf

Define MsDialog oDlgPrinc Title OemToAnsi(STR0001) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel  //"Calculo de Rescisao"

//
// Cria o conteiner onde serão colocados os browses
//
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )

//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 60, .F. )                       // Cria uma "linha" com 60% da tela
oFWLayer:AddCollumn( 'ALLUP', 100, .T., 'UP' )          // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALLUP', 'UP' )       // Pego o objeto desse pedaço do container

//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 40, .F. )                     	// Cria uma "linha" com 40% da tela
oFWLayer:AddCollumn( 'ALLDWN' ,  100, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelDown 	:= oFWLayer:GetColPanel( 'ALLDWN', 'DOWN' )    // Pego o objeto desse pedaço do container


//
// FWmBrowse Superior: Funcionarios
//
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )                  // Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( OemToAnsi(STR0002) )	//"Funcionarios"
oBrowseUp:SetAlias( 'SRA' )
oBrowseUp:SetMenuDef( 'GPEM043' )              // Define de onde virao os botoes deste browse
oBrowseUp:DisableDetails()
oBrowseUp:SetProfileID( '1' )
oBrowseUp:SetCacheView (.F.) 
oBrowseUp:ExecuteFilter(.T.)

oBrowseUp:AddLegend( "RA_SITFOLH==' '" 		, "GREEN" 	, STR0053 ) 	//"Situacao Normal"
oBrowseUp:AddLegend( "RA_RESCRAI$'30/31'" 	, "PINK" 	, STR0054 ) 	//"Transferido"
oBrowseUp:AddLegend( "RA_SITFOLH=='D'" 		, "RED" 	, STR0055 ) 	//"Demitido"
oBrowseUp:AddLegend( "RA_SITFOLH=='A'" 		, "YELLOW" 	, STR0056 ) 	//"Afastado"
oBrowseUp:AddLegend( "RA_SITFOLH=='F'" 		, "BLUE" 	, STR0057 ) 	//"Ferias"
oBrowseUp:Activate()

//
// FWmBrowse Inferior: Cabecalhos de rescisao    

oBrowseDwn:= FWMBrowse():New()
oBrowseDwn:SetOwner( oPanelDown )
oBrowseDwn:SetDescription( OemToAnsi(STR0003) )	//"Cabeçalho de rescisão"
oBrowseDwn:SetMenuDef( 'GPEM042' )                       
oBrowseDwn:DisableDetails()
oBrowseDwn:SetAlias( 'SRG' )
oBrowseDwn:SetProfileID( '2' )
oBrowseDwn:ForceQuitButton()					//sempre que existem dois menudefs na tela, deve-se indicar em qual browse vai ficar o botao 'Sair'
oBrowseDwn:SetCacheView (.F.)
oBrowseDwn:ExecuteFilter(.T.)
//
// Relacionamento entre os Paineis
//
oRelacSRG:= FWBrwRelation():New()
If cPaisLoc <> "BRA"
	oRelacSRG:AddRelation( oBrowseUp  , oBrowseDwn , {{ 'RG_FILIAL' , 'RA_FILIAL'  },{ 'RG_MAT' , 'RA_MAT'  } } )
Else
	oRelacSRG:AddRelation( oBrowseUp  , oBrowseDwn , { { 'RG_FILIAL', 'xFilial( "SRG" )' }, { 'RG_MAT' , 'RA_MAT'  } } )
EndIf

oRelacSRG:Activate()

oBrowseDwn:Activate()

oBrowseUp:Refresh()
oBrowseDwn:Refresh()

Activate MsDialog oDlgPrinc Center

RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Erika Kanamori        ³ Data ³ 10/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function MenuDef()
                                                                               	
	Local aRotina := {}  

	ADD OPTION aRotina Title OemToAnsi(STR0004) Action 'PesqBrw'         OPERATION 1  ACCESS 0 DISABLE MENU //"Pesquisar"
	ADD OPTION aRotina Title OemToAnsi(STR0005) Action 'VIEWDEF.GPEM042' OPERATION 2  ACCESS 0 DISABLE MENU //"Visualizar"
	ADD OPTION aRotina Title OemToAnsi(STR0006) Action 'VIEWDEF.GPEM042' OPERATION 3  ACCESS 0 DISABLE MENU //"Incluir"
	ADD OPTION aRotina Title OemToAnsi(STR0007) Action 'VIEWDEF.GPEM042' OPERATION 4  ACCESS 0 DISABLE MENU //"Alterar"
	ADD OPTION aRotina Title OemToAnsi(STR0008) Action 'VIEWDEF.GPEM042' OPERATION 5  ACCESS 0 DISABLE MENU	//"Excluir"
	

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Erika Kanamori        ³ Data ³ 10/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ViewDef()                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function ViewDef()

Local oStruSRG := FWFormStruct( 2, 'SRG' )
Local oStruSRC := FWFormStruct( 2, 'SRC' ) 
Local oModel   := FWLoadModel( 'GPEM042' )
Local oView              
Local bLogM042	:= {|| TelaLog() } 
Local bAplicacao:= {|| fAplicaRes(1) }
Local bUndoAplic:= {|| fAplicaRes(2) }
Local bCalcM42	:= {|| CalResM2(), fRefresh() } 
Local bLancFixos:= {|| AbreCadastro(1)} 
Local bIncidenci:= {|| AbreCadastro(2) } 
Local bAusencias:= {|| AbreCadastro(3) } 
Local bValFuturo:= {|| AbreCadastro(4) } 
Local bTmpExtra	:= {|| AbreCadastro(5) }

oView := FWFormView():New()
oView:SetModel( oModel )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                             
³Nao apresenta os seguintes campos do SRC                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/	
oStruSRC:RemoveField( 'RC_FILIAL' )
oStruSRC:RemoveField( 'RC_MAT' )
oStruSRC:RemoveField( 'RC_NOME' ) 
oStruSRC:RemoveField( 'RC_QTDSEM' )
oStruSRC:RemoveField( 'RC_HORINFO' )
oStruSRC:RemoveField( 'RC_VALINFO' )
oStruSRC:RemoveField( 'RC_VALORBA' )
oStruSRC:RemoveField( 'RC_PROCES' )
oStruSRC:RemoveField( 'RC_PERIODO' )
oStruSRC:RemoveField( 'RC_ROTEIR' )
oStruSRC:RemoveField( 'RC_SEMANA' )  

If cPaisLoc == "BRA"
	oStruSRG:SetProperty('RG_PERIODO', MVC_VIEW_ORDEM,'20')
	oStruSRG:SetProperty('RG_ROTEIR', MVC_VIEW_ORDEM,'19')
	oStruSRG:SetProperty('RG_SEMANA', MVC_VIEW_ORDEM,'21')
EndIf
                                                    
oView:AddField( 'VIEW_SRG', oStruSRG, cModel )

oView:AddGrid(  'VIEW_SRC', oStruSRC, 'SRCDETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

oView:SetOnlyView('VIEW_SRC') //nao permite alteracoes no SRC

oView:SetOwnerView( 'VIEW_SRG', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_SRC', 'INFERIOR' )

oView:EnableTitleView('VIEW_SRG')
oView:EnableTitleView('VIEW_SRC') 

oView:addUserButton(OemToAnsi(STR0009),"MAGIC_BMP", bCalcM42,   OemToAnsi(STR0009),, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) 	//"Calcular Rescisão"
oView:addUserButton(OemToAnsi(STR0010),"MAGIC_BMP", bLogM042,   OemToAnsi(STR0010),, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE})	//"Log de cálculo"
oView:addUserButton(OemToAnsi(STR0011),"MAGIC_BMP", bAplicacao, OemToAnsi(STR0011),, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} )	//"Aplicar rescisão"
oView:addUserButton(OemToAnsi(STR0012),"MAGIC_BMP", bUndoAplic, OemToAnsi(STR0012),, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} )	//"Desfazer aplicação de rescisão"

oView:addUserButton(OemToAnsi(STR0045),"MAGIC_BMP", bLancFixos, OemToAnsi(STR0045),,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW } )	//"Lançamentos Fixos"
oView:addUserButton(OemToAnsi(STR0046),"MAGIC_BMP", bIncidenci, OemToAnsi(STR0046),,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW } )	//"Incidências por funcionário"
oView:addUserButton(OemToAnsi(STR0047),"MAGIC_BMP", bAusencias, OemToAnsi(STR0047),,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW } )	//"Ausências"
oView:addUserButton(OemToAnsi(STR0048),"MAGIC_BMP", bValFuturo, OemToAnsi(STR0048),,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW } )	//"Valores Futuros"
If cPaisLoc != "CHI"
	oView:addUserButton(OemToAnsi(STR0049),"MAGIC_BMP", bTmpExtra , OemToAnsi(STR0049),,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_VIEW } )	//"Tempo Extra"
EndIf

oView:CanActivate({|oView|fVldView(oView)})  
oView:SetVldActivate({|oView|fVldView(oView)})

Return oView



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Erika Kanamori        ³ Data ³ 10/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de Dados da Rotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ModelDef()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/    

Static Function ModelDef()
Local oStruSRG  	:= FWFormStruct( 1, 'SRG', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruSRC  	:= FWFormStruct( 1, 'SRC', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oModel    	                                      
Local bVldAct_Model	:= { | oModel | fVldAcTm42(oModel, oStruSRG) }              
Local bCommiM042	:= { | oModel | fCommiM042(oModel) }                         
Local bTudoOK		:= { | oModel | bTudoOKM42(oModel) }
Local bCancel		:= { | oModel | oBrowseUp:Refresh(),oBrowseDwn:Refresh(),.T. }

Private cModel := IIf(cPaisLoc $ "DOM|CHI|COL|MEX|PER|PAR", "GPEM040_MSRG", "SRGMASTER")

oModel := MPFormModel():New( 'GPEM042', /*bPreValid*/, bTudoOK, bCommiM042, bCancel )
oModel:SetDescription( 'Rescisao' ) 

//seta inicializador padrao para o campo de descricao do SRC      
oStruSRC:SetProperty( 'RC_DESCPD' , MODEL_FIELD_INIT, FWBuildFeature( /*STRUCT_FEATURE_INIPAD*/ 3 , "FillDescPd()" ))

//incluindo fields e grid no oModel
oModel:AddFields( cModel, /*cOwner*/, oStruSRG )
oModel:AddGrid( 'SRCDETAIL', cModel, oStruSRC, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
       

//Definindo relacionamento entre SRG e SRC
oModel:SetRelation( 'SRCDETAIL', { { 'RC_FILIAL', 'xFilial( "SRC" )' } , { 'RC_MAT', 'RG_MAT' },  {'RC_DTREF', 'RG_DTPAGO'}	} , SRC->(IndexKey(1)) )
										  
oModel:SetVldActivate( bVldAct_Model )
 
//Regras do model RHIMASTER
//oModel:GetModel( 'RHIMASTER' ):SetUniqueLine( { 'RHI_FILIAL','RHI_MAT', 'RHI_DTINI'} )
If cPaisLoc == 'CHI'
	oModel:SetPrimaryKey( {} )
EndIf
//Regras do Model SRCDETAIL
oModel:GetModel( 'SRCDETAIL' ):SetNoInsertLine( .T. )	//nao permite insercao de linhas
oModel:GetModel( 'SRCDETAIL' ):SetNoDeleteLine( .T. ) 	//nao permite delecao de linhas
oModel:GetModel( 'SRCDETAIL' ):SetOptional( .T. )  	//pode nao ter linhas        

//Definindo descricoes
oModel:GetModel( cModel ):SetDescription( OemToAnsi(STR0013)  )	//"Cabeçalho de rescisão"

oModel:GetModel( 'SRCDETAIL' ):SetDescription( OemToAnsi(STR0014)  )   //"Ítens de cálculo"

Return oModel   
  
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AbreCadastro³ Autor ³Erika Kanamori		  ³ Data ³ 14/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz chamada de telas de cadastro e tratamento para calculo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³nOpcaoTela: opcao a ser chamada                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function AbreCadastro(nOpcaoTela)
Local aArea		:= GetArea()
Private lResM2	:= .T. 	//flag que indica se deve ou nao mostrar o browse inicial
Private lM2Modif:= .F. //variavel para saber se houve alteracoes no cadastro

Do Case
	Case nOpcaoTela== 1 //"Lançamentos Fixos"
		GpeA550()
	Case nOpcaoTela== 2 //"Incidências por funcionário"
		 GPEA580()
	Case nOpcaoTela== 3 //"Ausências"  
		GpeA240()
	Case nOpcaoTela== 4 //"Valores Futuros"
		GPEA110()
	Case nOpcaoTela== 5 //"Tempo Extra"     
		Gpea640()
EndCase 
	
If lM2Modif
	If( MsgNoYes(	OemToAnsi( STR0050 + CRLF + CRLF + STR0051),;//"Estas modificações só terão efeito se a rescisão for recalculada."##"Deseja recalcular agora?"
		OemToAnsi(STR0027) )) // "Atencao"
		CalResM2() //Nao eh necessario validar, pois a funcao de calculo realiza a validacao do model (se houver alteracoes)
		fRefresh()
	Endif
Endif

RestArea(aArea)   
Return
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVldAct_M042³ Autor ³ Mauricio T. Takakura  ³ Data ³ 11/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se deve ativar ou nao a tela                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fVldAcTm42(oModel, oStruSRG)                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fVldAcTm42(oModel, oStruSRG)   
Local aArea     := GetArea()   
Local nOperation:= oModel:GetOperation()
Local cCodFer	:= "" 
Local lRet 		:= .F.

If Empty(oModel)
	Return(.F.)
EndIf
	
cCodFer:= fGetCodFol("0072") // Codigo de Ferias 
SRF->(DbSetOrder(2))
SRF->( MsSeek( SRA->( RA_FILIAL + RA_MAT + cCodFer  ) ) )

While !SRF->(EOF()) .and. SRA->( RA_FILIAL + RA_MAT ) + cCodFer == SRF->( RF_FILIAL + RF_MAT + RF_PD )
    IF SRF->RF_STATUS $ " 1"
       lRet := .T.
	   Exit
	EndIf
	SRF->( DbSkip()	)
EndDo

SRF->(DbSetOrder(1))
If !lRet
   	Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0015), 1, 0 ) //"Help" ## "Funcionário não tem período de férias no cadastro de Programacao de Férias."
EndIf
If cPaisLoc <> "BRA" 
	lRet:= .T.
EndIf    
If cPaisLoc <> "BRA" .and. (nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE)
	If xFilial("SRG") <> SRA->RA_FILIAL
		oModel:SetErrorMessage('GPEM042', '' , 'GPEM042' , '' , OemToAnsi(STR0077), OemToAnsi(STR0078), OemToAnsi(STR0079))
		lRet:= .F.
	EndIf
EndIf

/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Nao deixa incluir rescisao se houver outra em aberto. 	          ³
	³ Se jah houver rescisao fechada, lanca como rescisao complementar.   ³
	³ (Se for complemetar fora do mes, sera modificada no TudoOK)  	      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If lRet              
	If nOperation == MODEL_OPERATION_INSERT
		dbSelectArea("SRG")
		leeSRG(SRA->RA_MAT)
		If !Empty(ASRG)              
			If ASRG[1] $ "1*2" 
				Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0017 + CRLF + CRLF + STR0018), 1, 0 ) //"Nao é possivel incluir nova rescisao" ## "pois existe rescisao em aberto para este funcionario" 
				lRet:= .F.
		  	Else
		  		oStruSRG:SetProperty( 'RG_RESCOMP' , MODEL_FIELD_INIT, FWBuildFeature( /*STRUCT_FEATURE_INIPAD*/ 3 , "2" )) 
		  	Endif
		Endif
	Endif 
Endif
    

If lRet
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Avisa ao usuario, porem permite continuar no calculo         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If nOperation == 3 .and. SRA->RA_SITFOLH == "A"
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0019), 1, 0 ) //Funcionário está com situação de afastado no cadastro.
	EndIf
	
	If nOperation == 3 .and. SRA->RA_SITFOLH == "F"
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0020), 1, 0 )//Funcionário está com situação de férias no cadastro.
	EndIf
	
	If nOperation = 1 .And. SRA->RA_SITFOLH == "D" .And. MesAno(SRA->RA_DEMISSA) < MesAno( dDataBase )
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0021), 1, 0 ) //Rescisão foi calculada em Data Anterior a Data Base.
	EndIf

Endif

If lRet .And. cPaisLoc $ "MEX" .And. SRA->RA_SITFOLH == "D"
	oStruSRG:SetProperty( 'RG_DATADEM',	MODEL_FIELD_WHEN, { || .F. } )
	oStruSRG:SetProperty( 'RG_DATADEM',	MODEL_FIELD_INIT, { || SRA->RA_DEMISSA })
EndIf

RestArea(aArea)
Return( lRet )   
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³bTudoOKM42  ³ Autor ³ Erika Kanamori        ³ Data ³ 12/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacoes acionadas ao clicar no botao confirma.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³bTudoOKM42()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function bTudoOKM42(oModel)
Local aArea         := GetArea()
Local lRet			:= .T. 
Local lRecalcula	:= .F.
Local lContinua		:= .T.
Local nAux			:= 1   
Local nAux2         := 0
Local nOperation	:= oModel:GetOperation() 
Local oModelSRG    	:= oModel:GetModel(cModel)
Local aCampos		:= {}
Local cProcesso		:= "" 
Local cRoteiro		:= ""
Local cPeriodo		:= ""
Local cNumPago		:= ""
Local cMesAnt		:= ""
Local cMesAtu		:= ""
Local cAnoAnt		:= ""
Local cAnoAtu		:= "" 
Local lAlteracao	:= .F.
Local cLlave 		:= ""
Local cLlave1 		:= ""
Local cLlave2		:= ""
Local cLlave3 		:= ""
Local cLlave4		:= ""
Local cLlave5 		:= ""
Local cAliasQRY:=CriaTrab(Nil,.F.)
Local cQuery :=""
Local aSRG1:={}

FWModelActive( oModel ) 

lVldCalculo:= Iif(Type("lVldCalculo") == "U", .F., lVldCalculo)

 /*	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Nao deixa alterar informacoes caso a rescisao esteja aplicada. 					  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	*/
If (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE) .And. !(RG_EFETIVA $ "1*2")
	Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0044), 1, 0 ) //"Esta rescisao ja foi aplicada. Portanto, não pode ser modificada."
	lRet:= .F.
Endif	
	
/*	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Reclassifica o tipo de rescisao (caso for rescisao complementar ou complementar fora do mes). ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	*/
If lRet .And. (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT)
	//Necessario igualar os campos de roteiro, pois o setRelation e feito atraves
	//de RG_APLROT em virtude do processo de aplicacao e reversao de aplicacao 
	oModelSRG:LoadValue('RG_APLROT', oModelSRG:GetValue('RG_ROTEIR'))
                              
	dbSelectArea("SRG")
	SRG->(DbSetOrder( RetOrdem( "SRG", "RG_FILIAL+RG_MAT+DTOS(RG_DTPAGO)" ) ))
	If SRG->(dbSeek(xFilial("SRG")+SRA->RA_MAT)) .And. SRG->RG_DTPAGO <> M->RG_DTPAGO
		While SRG->(RG_FILIAL+RG_MAT) == xFilial("SRG") + SRA->RA_MAT .And. lContinua
			If SRG->RG_RESCOMP == "1"
				cProcesso	:= SRG->RG_PROCES  
				cRoteiro	:= SRG->RG_ROTEIR
				cPeriodo	:= SRG->RG_PERIODO
				cNumPago	:= SRG->RG_SEMANA
				lContinua:= .F.
			Endif
			SRG->(dbSkip())
		End 
		
		//procura o mes do periodo da rescisao
		cAnoAnt:= Posicione("RCH", 4, xFilial("RCH")+cProcesso+cRoteiro+cPeriodo+cNumPago, "RCH_ANO")
		cMesAnt:= Posicione("RCH", 4, xFilial("RCH")+cProcesso+cRoteiro+cPeriodo+cNumPago, "RCH_MES")
		cAnoAnt+= cMesAnt
		//procura o mes do periodo da nova rescisao. Se for no mesmo mes, mantem status 'rescisao complementar', caso contrario muda para 'rescisao compl. fora do mes'
		cAnoAtu:= Posicione("RCH", 4, xFilial("RCH")+M->RG_PROCES+M->RG_ROTEIR+M->RG_PERIODO+M->RG_SEMANA, "RCH_ANO")
		cMesAtu:= Posicione("RCH", 4, xFilial("RCH")+M->RG_PROCES+M->RG_ROTEIR+M->RG_PERIODO+M->RG_SEMANA, "RCH_MES")
		cAnoAtu+= cMesAtu
		
		If cAnoAnt < cAnoAtu
	   		M->RG_RESCOMP:= "3"		
		Elseif cAnoAnt > cAnoAtu  
			Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0022), 1, 0 ) //"O periodo selecionado eh anterior ao periodo em que foi calculada a rescisao"
			lRet:= .F.
   		Endif	
			
	Endif

Endif

If lRet .And. !lVldCalculo 
/*	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Se eh inclusao, soh permite a confirmacao se a rescisao foi calculada.              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	*/	
	If nOperation == MODEL_OPERATION_INSERT  
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0023 + CRLF + CRLF + STR0024), 1, 0 ) //"Para incluir uma rescisao ela deve ser calculada."##"Calcule a rescisao."
		lRet:= .F.
	Elseif nOperation == MODEL_OPERATION_UPDATE
	/*	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   		³ Se eh alteracao, verifica se os dados foram alterados e se houve recalculo da rescisao ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	*/ 
		If Len(oModelSRG:aDataModel) > 0
			For nAux2 := 1 To Len(oModelSRG:aDataModel[1])
				If oModel:IsFieldUpdated(cModel, oModelSRG:aDataModel[1][nAux2][1])
					lAlteracao:= .T.
					Exit
				Endif
			Next
		Endif
		
		If lAlteracao 
			If!( MsgNoYes(	OemToAnsi( STR0025 + CRLF + CRLF + STR0026),;//"Houve alteracao de campos no formulario e nao houve recalculo da rescisao."##"Deseja gravar mesmo assim?"
				 OemToAnsi(STR0027) )) // "Atencao"
				lRet:= .F.
			Endif
		Endif
	Endif
          
Endif


If  nOperation == MODEL_OPERATION_INSERT
	
	cLlave  := oModel:GetValue( cModel, 'RG_FILIAL')
	cLlave1 := oModel:GetValue( cModel, 'RG_MAT')
	cLlave2 := oModel:GetValue( cModel, 'RG_PERIODO')
	cLlave3 := oModel:GetValue( cModel, 'RG_ROTEIR')
	cLlave4 := oModel:GetValue( cModel, 'RG_SEMANA')
	cLlave5 := dtos(oModel:GetValue( cModel, 'RG_DTGERAR'))
		
	aSRG1:={}
		
	cQuery := "SELECT RG_MAT FROM " + RetSqlName("SRG")
	cQuery += " WHERE RG_FILIAL = '"+cLlave+"'
	cQuery += " AND RG_MAT = '" + cLlave1+ "'
	cQuery += " AND RG_PERIODO = '" + cLlave2+ "'
	cQuery += " AND RG_ROTEIR = '" + cLlave3+ "'
	cQuery += " AND RG_SEMANA = '" + cLlave4+ "'
	cQuery += " AND RG_DTGERAR = '" + cLlave5+ "'
	cQuery += "  AND D_E_L_E_T_ <> '*'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY)
		
	WHILE  !(cAliasQRY)->(EOF())
		AADD(aSRG1,(cAliasQRY)->RG_MAT)
		(cAliasQRY)->(dbskip()) 
	Enddo
	(cAliasQRY)->( dbCloseArea())	
		
	If !Empty(aSRG1) 
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0017 + CRLF +STR0067), 1, 0 ) //
		lRet:= .F.
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fRefresh    ³ Autor ³ Erika Kanamori        ³ Data ³ 11/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Dah refresh no model.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fRefresh()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fRefresh()
Local aArea         := GetArea()
Local oModel      	:= FWModelActive()
Local nOperation	:= oModel:GetOperation()
Local oView 		:= FWViewActive()


FWModelActive(oModel)
oModel:Deactivate()                 
If nOperation == MODEL_OPERATION_INSERT  //ao gravar, a operacao muda para modo 'UPDATE', para que nao haja conflito na hora da gravacao (duplicated line)
	oModel:SetOperation(4)   
Endif
oModel:Activate()

If ValType(oView) != "U"
	oView:Refresh()                           
Endif

RestArea(aArea)
Return
 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalResM2    ³ Autor ³ Erika Kanamori        ³ Data ³ 10/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava as informacoes do model (para que seja possivel acessa- ³±±
±±³          ³las nas formulas), e executa o calculo de rescisao de acordo  ³±±
±±³          ³com os campos de roteiro, processo, periodo e data de pagto.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CalResM2()                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function CalResM2()

Local aArea         := GetArea()
Local cMat			:= SRA->RA_MAT   
Local oModel      	:= FWModelActive()
Local oModelSRG		:= oModel:GetModel(cModel)
Local lAutomato     := isblind()

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
Private nStatus		:= If( SRA->RA_SITFOLH = 'D', 2, 1)
Private dDataIni	:= Ctod("//")
Private dDataFim	:= Ctod("//")

Private dDataKey	:= CtoD("//") //data que vai servir de relacionamento entre SRG e SRC (data pagamento, RG_DTPAGO)

Private lVldCalculo	:= .T.	    

Private lAtualiza   := .F.
Private cAtualSit   := GetMvRH( "MV_SITRES", .F., "2" ) 


If cAtualSit == "2" .and. !(cPaisLoc $ "COL|MEX|DOM|PER|PAR") 
	lAtualiza := .T.
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
	Return(.F.)
Endif  


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o calculo pode ser executado (a rescisao nao pode estar aplicada  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAutomato
	If !(M->RG_EFETIVA $ "1*2")
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0052), 1, 0 ) //"Help"##"A rescisao nao pode ser calculada pois ja foi aplicada."
		Return(.F.)
	Endif
Else
	If !(oModelSRG:GetValue("RG_EFETIVA") $ "1*2")
		conout(STR0052) //"A rescisao nao pode ser calculada pois ja foi aplicada."
		Return(.F.)
	Endif
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava as informacoes na tabela SRG para possibilitar sua   ³
//³leitura atraves das formulas.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lAutomato
	If( MsgNoYes(	OemToAnsi( STR0028 + CRLF + CRLF + STR0029), OemToAnsi(STR0027) ))//"Ao calcular a rescisao, os dados informados serao gravados." ## "Deseja calcular?" ## "Atencao"
		lRet := oModel:VldData()
		If lRet 
			FwFormCommit(oModel) 
			fRefresh()  
		Else
			Return(.F.)
		Endif
	Else
		Return(.F.)
	EndIf
Else
	lRet := oModel:VldData()
	If lRet 
		FwFormCommit(oModel) 
		fRefresh()  
	Else
		Return(.F.)
	Endif
EndIf

cProces		:= SRA->RA_PROCES
cRoteiro 	:= SRG->RG_ROTEIR
cPeriodo	:= SRG->RG_PERIODO
cNumPag		:= SRG->RG_SEMANA
dDataKey	:= SRG->RG_DTPAGO

If Empty(cProces) .Or. Empty(cRoteiro) .Or. Empty(cPeriodo) .Or. fGetTipoRot(cRoteiro) <> "4"
	Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0030), 1, 0 ) //"Help"##"Roteiro de Cálculo diferente de Rescisão!"
Else

If !lAutomato
	If( MsgNoYes(	OemToAnsi( STR0062), OemToAnsi(STR0027) )) 	//"Habilitar TRACE?"##"Atenção"
		lHabTrace:= .T.
	Endif
Else
	lHabTrace:= .T.
EndIf

	cProcDesc	:= Posicione("RCJ", 1, xFilial("RCJ")+ cProces, "RCJ_DESCRI")
	cRotDesc	:= Posicione("SRY", 1, xFilial("SRY")+ cRoteiro, "RY_DESC")
	
	//gera filtro para calcular somente o funcionario posicionado
	fGeraFilter( aFilter, cMat," "," "," "," ")
	If !lAutomato
		Proc2BarGauge({|lEnd| VldPeriodo(), VldCalculo(), Gpem022Processa()})
	Else
		If VldPeriodo()
			If VldCalculo()
				Gpem022Processa()
			EndIf
		EndIf
	EndIf
	If cAtualSit == "2"
		RetSituacao( ,,lAtualiza,M->RG_DATADEM,,,,,,,nOpcFinC,nTipFinC)
	Endif	
	
	DbSelectArea("SRY") //necessário posicionar para evitar o error log na impressão.
Endif  

RestArea(aArea)

Return(.T.)
                                           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCommiM042  ³ Autor ³ Erika Kanamori        ³ Data ³ 11/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que comita as informacoes, SEM abrir outra inclusao au-³±±
±±³          ³tomaticamente.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fCommiM042(oModel)                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/ 
Static Function fCommiM042(oModel)
Local aArea      	:= GetArea()	 
Local nOperation	:= oModel:GetOperation()  
Local aSaveLines

	// Salva as posicoes das FWFormGrids do Model
	aSaveLines := FWSaveRows()
	// Fornece o objeto da classe FWFormModel ativo no momento, para ser utilizado nas regras de validacao. 
	FWModelActive( oModel )    
    /* Realiza os tratamentos necessarios para gravacao dos formularios de edicao. A Gravacao e 
    realizada em niveis onde o primeiro elemento do modelo e posteriormente seus filhos sao gravados.*/
	FWFormCommit( oModel )
    // Restaura as posicoes das FWFormGrids do Model 
	FWRestRows( aSaveLines ) 

If cAtualSit == "2" .And. nOperation == MODEL_OPERATION_DELETE
	fRetSitRes()
Endif

fRefresh()

RestArea(aArea) 

Return .T.                                                               
  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fAplicaRes  ³ Autor ³ Erika Kanamori        ³ Data ³ 18/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao de aplicacao e reversao de aplicacao de   ³±±
±±³          ³rescisao.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³nTipoApl: 1 para aplicacao; 2 para reversao de aplicacao.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/ 
Function fAplicaRes(nTipoApl)
Local oModel        := FWModelActive() 
Local oModelSRG    	:= oModel:GetModel(cModel)
Local nOperation	:= oModel:GetOperation() 
Local cRoteiro		:= ""
Local cPeriodo		:= ""
Local cNumPago		:= ""
Local lRet			:= .T.  
Local nAux2			:= 0
Local dDtFech  		:= CTOD("//")

nTipFinC := nTipoApl
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Soh faz aplicacao se tiver rescisao calculada e sem        ³
//³alteracoes a confirmar 								      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF nOperation == MODEL_OPERATION_INSERT
	lRet:= .F. 
Else
   	IF nOperation != MODEL_OPERATION_VIEW
		If Len(oModelSRG:aDataModel) > 0
			For nAux2 := 1 To Len(oModelSRG:aDataModel[1])
				If oModel:IsFieldUpdated(cModel, oModelSRG:aDataModel[1][nAux2][1])
					lRet:= .F. 
					Exit
				Endif
			Next
		Endif
	Else	
		lRet:= .F. 
	EndIf
EndIf

If lRet
	If nTipoApl == 1
		cRoteiro:= M->RG_ROTEIR 
		cPeriodo:= M->RG_PERIODO                   
		cNumPago:= M->RG_SEMANA
	Else
		cRoteiro:= M->RG_APLROT 
		cPeriodo:= M->RG_APLPER
		cNumPago:= M->RG_APLNPG
		If Empty(cRoteiro) .Or. Empty(cPeriodo)
			Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0032) , 1, 0 )//"Help"##"Nao eh possivel reverter a aplicaçao de rescisao pois a aplicação ainda não foi executada."
			Return(.F.)
		Endif

		//Verifica se o periodo do roteiro de aplicacao esta fechado
		dDtFech := Posicione("RCH", 4, xFilial("RCH")+SRA->RA_PROCES+cRoteiro+cPeriodo+cNumPago, "RCH_DTFECH")
		If !Empty(dDtFech)
			Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0061) , 1, 0 )//"Help"##"Nao eh possivel reverter a aplicaçao de rescisao pois o periodo ja esta fechado."
			Return(.F.)
		Endif
	Endif
	
	If !Gpm042Apl( nTipoApl, cRoteiro, cPeriodo , cNumPago )
		lRet:= .F.
	Endif
Else
	IF nOperation == MODEL_OPERATION_VIEW 
   		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0060) , 1, 0 )//"Help"##"Execute esse processo em modo de alteracao."
	Else
		If nTipoApl == 1 
	   		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0033) , 1, 0 )//"Help"##"Eh necessario confirmar as informacoes do formulario antes de realizar a operação de aplicação de rescisão."
	   	Else
			Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0034) , 1, 0 )//"Help"##'Eh necessario confirmar as informacoes do formulario antes de realizar a operação de reversão de aplicação de rescisão.'
		EndIf 
	EndIf	
Endif

Return(lRet)

  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gpm042Apl   ³ Autor ³ Erika Kanamori        ³ Data ³ 19/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de aplicacao e reversao de aplicacao de rescisao.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³nTipo		: 1- Aplicacao, 2- Reversao de aplicacao            ³±±
±±³          ³cRoteir	: Roteiro de calculo                                ³±±
±±³          ³cPer 		: Periodo de calculo                                ³±±
±±³          ³cNPgto	: Numero de pagamento                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/ 
Static Function Gpm042Apl( nTipo, cRoteir, cPer, cNPgto)
					 	
Local aPerAtual	  := {}

Local bSet15	  := { || lRet := .T., oDlg:End() }
Local bSet24	  := { || lRet := .F., oDlg:End() }
Local bDialogInit := {}

Local cTitle
Local cTipoRot 	  := fGetTipoRot( cRoteir )
Local cRotDesc
Local cSvRoteir   := cRoteir
Local cSvPer	  := cPer
Local cSvNPgto	  := cNPgto

Local lRet 		  := .t.

Local nLin
Local nNextRecno  := 0
Local nRecno 	  := 0
Local nOrder 	  := 0

Local oDlg
Local oPanel

//Local lGpm042ReA
//Local lGpm042Apl
Local lRetGpm042 	:= .F.
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
		
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}	
Local aObj1Coords 	:= {}
	
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}	
Local aObj2Coords 	:= {}

Local oModel      	:= FWModelActive()
Local oModelSRG		:= oModel:GetModel(cModel)

Local aSituacao 	:= {} 
Local cFil			:= SRA->RA_FILIAL
Local cMat			:= SRA->RA_MAT
Local cAtualSit     := SuperGetMV( "MV_SITRES", .F., "2" )
Local lRutAuto		:= IsBlind()

DEFAULT nTipo 	  := 0
DEFAULT cRoteir	  := ""
DEFAULT cPer 	  := ""
DEFAULT cNPgto	  := ""  

/*
lGpm042ReA := ExistBlock( "GPM042RA" )  //colocar depois os pontos de entrada
lGpm042Apl:= ExistBlock( "GPM042AR" )
*/  

//If ( nTipo == 2 )

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Ponto de Entrada para nao verificacao da Situacao da Folha   ³
	³ em caso de Reversao da Aplicacao de Rescisao				   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
  /*	If ( lGpm042ReA )
		lRetGpm042 := ExecBlock("GPM042RA")
		If !( ValType(lRetGpm042Apl) == "L" )
			lRetGpm042Apl := .F.
		EndIf
	EndIf

EndIf
*/

If (nTipo == 1 .and. cTipoRot <> "4") .Or. (nTipo == 2 .and. cTipoRot <> "A")
	Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0035) , 1, 0 )//"Help"##Tipo de Roteiro Diferente do Solicitado!
	Return( .F. )
Else

	If nTipo == 1
		cRoteir := fGetCalcRot('A')	// Aplicacao de Finiquito
	ElseIf nTipo == 2
		//If (AllTrim(SRA->RA_SITFOLH) == "D") .or. lRetGpm042Apl
			cRoteir := fGetCalcRot('4')	// Reversao de Aplicacao de Rescisao 
		/*Else
			MsgInfo("A reversao só pode ser feita para funcionários demitidos", "Aviso" )
			Return( .F. )
		EndIf*/
	EndIf  
	
	lRet := fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRoteir ) // Busca o periodo aberto para trabalho
	If lRet 
		cPer		:= aPerAtual[1,1]
		cNPgto 		:= aPerAtual[1,2]
	Else
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0036) , 1, 0 )//"Help"##"Periodo nao cadastrado para o Roteiro selecionado!"
		Return( lRet )	
	EndIf
	If nTipo == 1 .and. cTipoRot == "4"
		cTitle := OemToAnsi(STR0037) // "Aplicacao de Rescisao"
	Else
		cTitle := OemToAnsi(STR0038) // "Reversao da Aplicacao de Rescisao"
	EndIf
EndIf                                         

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define o Bloco para a Inicializacao do Dialog            	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If !lRutAuto
	bDialogInit		:= { ||;
								CursorWait()													,;
								EnchoiceBar( oDlg , bSet15 , bSet24, NIL  )						,;
								CursorArrow()												 	 ;
					}
					
	aAdvSize        := MsAdvSize( ,.T.,370)

	aInfoAdvSize    := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 040 , 000 , .T. , .T. } )        
	aAdd( aObjCoords , { 060 , 000 , .T. , .T. } )
	aObjSize    := MsObjSize( aInfoAdvSize , aObjCoords, .T., .T. )

	aAdv1Size    := aClone(aObjSize[1])

	aInfo1AdvSize    := { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
	aAdd( aObj1Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj1Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
	aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords )

	aAdv2Size    := aClone(aObjSize[2])

	aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
	aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
	aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords )

	DEFINE MSDIALOG oDlg TITLE cTitle FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() STYLE DS_MODALFRAME PIXEL
		oDlg:lEscClose := .F. // Nao permite sair ao se pressionar a tecla ESC.

		If ExistCpo("SRY", cRoteir)
			cRotDesc := Posicione("SRY",1,xFilial("SRY")+cRoteir, "RY_DESC")
		EndIf

		
		@ aObj1Size[1,1]	, aObj1Size[1,2] 		SAY   OemToAnsi(STR0039) SIZE 033,007 OF oDlg PIXEL	//"Periodo: "
		@ aObj1Size[1,1]	, aObj1Size[1,2]+55 	MSGET cPer SIZE 040,007	OF oDlg PIXEL WHEN .F.

		@ aObj1Size[2,1]	, aObj1Size[2,2] 		SAY   OemToAnsi(STR0040) SIZE 038,007 OF oDlg PIXEL	//"Nro Pagto: "
		@ aObj1Size[2,1]	, aObj1Size[2,2]+55 	MSGET cNPgto SIZE 040,007	OF oDlg PIXEL WHEN .F.
		
		@ aObj1Size[3,1]	, aObj1Size[3,2] 		SAY OemToAnsi(STR0041) SIZE 033,007 OF oDlg PIXEL	//"Roteiro: "
		@ aObj2Size[3,1]	, aObj2Size[3,2] 		SAY OemToAnsi(STR0042) SIZE 033,007 OF oDlg PIXEL	//"Descricao: "
		@ aObj1Size[3,1]	, aObj1Size[3,2]+55 	MSGET cRoteir  SIZE 040,007	OF oDlg PIXEL WHEN .F. PICTURE PesqPict("SRY","RY_CALCULO")
		@ aObj2Size[3,1]	, aObj2Size[3,2]+55 	MSGET cRotDesc SIZE 110,007	OF oDlg PIXEL WHEN .F.

		IF cPaisLoc $ "DOM|MEX|COL|PER|PAR"
			If nTipo == 1 // aplicar Finiquito
				If cAtualSit == '1'
					cHelpPar := OemToAnsi(STR0068) //"El parámetro MV_SITRES = 1 indica que el estado del trabajador cambiará a inactivo al Aplicar el Finiquito"
				ElseIf cAtualSit == '2'
					cHelpPar := OemToAnsi(STR0074) // "El parámetro MV_SITRES = 2 indica que el estado del trabajador no sera cambiado al Aplicar el Finiquito"
				EndIf
				
				@ aObj1Size[3,1] + 50, aObj1Size[3,2] 	SAY   cHelpPar  SIZE 300,300 OF oDlg PIXEL
			EndIf
				
		EndIf
	ACTIVATE DIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED
EndIf

If lRet
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Alterando o periodo do Calculo de Finiquitos para Aplicacao de Finiquitos ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/ 
	
	DbSelectArea( "SRC" )
    nOrder := RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA")
    DbSetOrder( nOrder )
    DbSeek(SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cSvRoteir+cSvPer+cSvNPgto, .F.)

	Begin Transaction 
	    
	    /*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Altera informacoes no formulario             				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   		If nTipo == 1
			oModelSRG:LoadValue('RG_APLROT' , cRoteir 	)  
			oModelSRG:LoadValue('RG_APLPER' , cPer    	)
			oModelSRG:LoadValue('RG_APLNPG' , cNPgto  	)
			oModelSRG:LoadValue('RG_EFETIVA', "3"		)
		Else                                             
			oModelSRG:LoadValue('RG_ROTEIR' , cRoteir 	)		   
			oModelSRG:LoadValue('RG_PERIODO', cPer    	)
			oModelSRG:LoadValue('RG_SEMANA' , cNPgto  	)
			oModelSRG:LoadValue('RG_EFETIVA', "2"		)
			oModelSRG:ClearField('RG_APLPER')
			oModelSRG:ClearField('RG_APLNPG') 
			oModelSRG:ClearField('RG_APLROT' )
		Endif
		
		If cAtualSit == "1"
			If nTipo == 1
				RetSituacao(cFil ,cMat , .T.,M->RG_DATADEM,,,,,,,nOpcFinC,nTipFinC)
	        Else
		        fRetSitRes(cFil,cMat)
    		Endif
		Endif	

		FwFormCommit(oModel) //nao precisa fazer validacoes novamente pois o formulario jah foi validado antes da aplicacao de rescisao
		fRefresh()

		DbSelectArea("SRG") //voltar para a tabela SRG
	End Transaction  
	
	While SRC->( !Eof() ) .and. SRC->( RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA) == SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cSvRoteir+cSvPer+cSvNPgto

   		/*/
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Obtem o Proximo Registro                    				   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !GetNextRecno( "SRC", @nNextRecno , @nRecno , nOrder )
			Exit
		EndIF

		RecLock( "SRC", .F.)
		SRC->RC_PERIODO := cPer
		SRC->RC_ROTEIR	:= cRoteir
		SRC->RC_SEMANA 	:= cNPgto
		MsUnlock()

		IF !GotoNextRecno( "SRC" , nNextRecno , nOrder )
			Exit
		EndIF
    EndDo 
	If cPaisLoc $ "DOM|MEX|COL"
		lRet := gp042RCP(nTipo,nOpcFinC)
	EndIf                      		
	If lRet
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0043) , 1, 0 )//"Help"##"Processo Concluido com Sucesso!"   
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP042RetPer ºAutor  ³Christiane Vieira º Data ³  02/11/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o Periodo em aberto                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                          	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp042RetPer()
Local oModel	:= FWModelActive()
Local oModelSRG	:= oModel:GetModel(cModel)
Local cPer			:= ""
Local cPago			:= ""

If fVPerRes(@cPer,@cPago, .T.)   
	oModelSRG:LoadValue('RG_PERIODO', cPer) 
	oModelSRG:LoadValue('RG_SEMANA', cPago) 
Endif
	
Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEM042   ºAutor  ³Microsiga           º Data ³  01/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a Situacao do funcionario                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fRetSitRes(cFil,cMat,nOpcFinC)

Local aSituacao := {}
Default cFil 	:= SRA->RA_FILIAL
Default cMat 	:= SRA->RA_MAT
Default nOpcFinC := "1"
   	aSituacao := RetSituacao( cFil , cMat , .F. , NIL , .T.)
	If !( aSituacao[1] == "D" )
			SRA->( RecLock( "SRA" , .F. , .T. ) )
			If !(cPaisLoc $ "MEX|COL|DOM|PAR")
				SRA->RA_DEMISSA  := Ctod("//")
			EndIf
			SRA->RA_RESCRAI  := "  "
			SRA->( MsUnLock() )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Retorna a Atual Situacao do Funcionario                       ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !(cPaisLoc $ "MEX|COL|DOM|PAR")
				RetSituacao(cFil , cMat , .T. , NIL , .T. )
			Else			
				RetSituacao(cFil , cMat , .F. , NIL , .T. )
			EndIf
	EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP042FerVencºAutor  ³Marcelo Faria     º Data ³  31/01/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega Ferias vencidas do funcionario                     º±±
±±º          ³ Usado apenas para inicializar o campo RG_DFERVENC          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                           	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp042FerVenc()
Local cCodFer 	  := "" 
Local cPer	  	  := Ctod("//")
Local lRetPer 	  := .F.
Local nRetFerVenc := 0    
Local aPerAtual	  := {}
Local cRotRes     := fGetCalcRot("4")  

If lRetPer  := fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRotRes ) //Busca Data Base periodo aberto RESCISAO
	Per := aPerAtual[1,6] 
EndIf

cCodFer:= fGetCodFol("0072") // Codigo de Ferias 
If !(empty(cCodFer)) .and. lRetPer

	SRF->(DbSetOrder(2))
	SRF->( MsSeek( SRA->( RA_FILIAL + RA_MAT + cCodFer  ) ) )
	While !SRF->(EOF()) .and. SRA->( RA_FILIAL + RA_MAT ) + cCodFer == SRF->( RF_FILIAL + RF_MAT + RF_PD )
	    IF SRF->RF_DATABAS != cPer  .and. SRF->RF_STATUS == "1" 
	    	// ((dias vencidos + dias antecipados) - dias pagos) 
			nRetFerVenc := nRetFerVenc + ((SRF->RF_DFERVAT + SRF->RF_DIASANT) - SRF->RF_DFERANT)
        EndIf
		SRF->( DbSkip()	)
	EndDo

	SRF->(DbSetOrder(1))
EndIf
   

Return(nRetFerVenc)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP042VerTipoºAutor  ³Marcelo Faria     º Data ³  01/02/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o tipo de rescisao para o funcionario             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MVC nao esta suportando bem a utilizacao de gatinhos no dicº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp042VerTipo()
Local lRet 	    := .F.
Local cDescTipo := ""

cDescTipo := fDescRCC("S012", M->RG_TIPORES,1,2,3,25)
if !Empty(cDescTipo)
	M->RG_DESCTPR := cDescTipo
    lRet := .T.
EndIf 
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP042RotVld ºAutor  ³Marcelo Faria     º Data ³  09/02/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica compatibilidade do roteiro com o processo         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³cRot	    : Roteiro para verificar                          º±±
±±º          ³cTipoRot	: Tipo do Roteiro para comparar                   º±±
±±º          ³lMsg		: Se mostra ou nao MSG de retorno                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                           	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp042RotVld(cRot,cTipoRot,lMsg)
Local lRetRot    := .T.

Default cRot     := ""
Default cTipoRot := ""
Default lMsg     := .T.

if !(Empty(cRot)) .and. !(Empty(cTipoRot)) 

	DbSelectArea("SRY")
	SRY->(DbSetOrder(1))
	If !SRY->(DbSeek(xFilial("SRY") + cRot))
		If lMsg
			MsgAlert(OemToAnsi(STR0058)) // "Roteiro Inválido!"
		EndIf	
		lRetRot := .F.
	Else
		If SRY->RY_TIPO != cTipoRot
			If lMsg
				MsgAlert(OemToAnsi(STR0059)) // "Roteiro incompativel com o processo!"
			EndIf	
			lRetRot := .F.
		EndIF
	EndIf

EndIf
	
Return(lRetRot) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVldView     ³ Autor ³ EquipeRH		       ³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida view, antes apresentar a mesma.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fVldView(oView)                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/  

Static Function fVldView(oViewVal)   
Local lRet	:= .T.
Local nOperation	:= oViewVal:GetModel():GetOperation()
/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Nao deixa incluir rescisao se houver outra em aberto. 	          ³
	³ Se jah houver rescisao fechada, lanca como rescisao complementar.   ³
	³ (Se for complemetar fora do mes, sera modificada no TudoOK)  	      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If lRet              
	If nOperation == MODEL_OPERATION_INSERT
		dbSelectArea("SRG")
		leeSRG(SRA->RA_MAT)
		If !Empty(ASRG[1])    
			If ASRG[1] $ "1*2"
				Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0017 + CRLF + CRLF + STR0018), 1, 0 ) //"Nao é possivel incluir nova rescisao" ## "pois existe rescisao em aberto para este funcionario" 
				lRet:= .F.
		  	Else
		  		oViewVal:SetProperty( 'RG_RESCOMP' , MODEL_FIELD_INIT, FWBuildFeature( /*STRUCT_FEATURE_INIPAD*/ 3 , "2" )) 
		  	Endif
		Endif
	Endif 
Endif    


	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Avisa ao usuario, porem permite continuar no calculo         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	
	If nOperation == 3 .and. SRA->RA_SITFOLH == "A"
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0019), 1, 0 ) //Funcionário está com situação de afastado no cadastro.
	EndIf
	
	If nOperation == MODEL_OPERATION_INSERT .and. SRA->RA_SITFOLH == "F"
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0020), 1, 0 )//Funcionário está com situação de férias no cadastro.
	EndIf
	
	If nOperation = 1 .And. SRA->RA_SITFOLH == "D" .And. MesAno(SRA->RA_DEMISSA) < MesAno( dDataBase )
		Help( ,, OemToAnsi(STR0016),, OemToAnsi(STR0021), 1, 0 ) //Rescisão foi calculada em Data Anterior a Data Base.
	EndIf


Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVPerRes     ³ Autor ³ EquipeRH		       ³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida data de demissao Versus Periodo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³RG_PERIODO                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/  
Function fVPerRes(cPer,cPago,lViaRot)   
	local aArea 		:= getArea()
Local lRet			:= .F.
Local cProcesso		:= M->RG_PROCES
Local cPerSRG			:= M->RG_PERIODO
Local cPagSRG			:= M->RG_SEMANA
Local cRot			:= M->RG_ROTEIR
Local dDemissao		:= M->RG_DATADEM
Local cMes			:= StrZero(MONTH(dDemissao),2)
Local cAno			:= StrZero(YEAR(dDemissao),4)
Local aPerAberto		:= {}
Local nAux			:= 0

Default cPer		:= ""
Default cPago		:= ""   

If !Empty(cProcesso) .And. !Empty(cRot) .And. !Empty(dDemissao) 
	fRetPerComp(cMes			,;		// Obrigatorio - Mes para localizar as informacoes
				cAno			,;		// Obrigatorio - Ano para localizar as informacoes
				nil				,;		 // Opcional - Filial a Pesquisar
				cProcesso		,;		// Opcional - Filtro por Processo
				cRot			,;		// Opcional - Filtro por Roteiro
				@aPerAberto	,,)		// Por Referencia - Array com os periodos Abertos

	If (len(aPerAberto) >=1)
		For nAux:= 1 to len(aPerAberto)
			If dDemissao>= aPerAberto[nAux,5]  .And.  dDemissao <= aPerAberto1[nAux,6]
				If !lViaRot
					If (aPerAberto[nAux,1]==cPerSRG) .And. (aPerAberto[nAux,2]==cPagSRG)       
						lRet	:= .T.
						Exit
   					EndIf
   				Else
					cPer	:= aPerAberto[nAux,1]
					cPago	:= aPerAberto[nAux,2]
					lRet	:= .T.
					Exit
				EndIf
			Endif
		Next nAux
	EndIf
EndIf		
	
If !lViaRot .And. !lRet 
	alert(OemtoAnsi(STR0063)+CRLF+OemtoAnsi(STR0064)) //"Nao existe Periodo cadastrado  sem data de fechamento, com situacao normal, e com procedimento do tipo Rescisao"  ### "Será necessário o cadastro de um período com estas caracterísiticas."  
EndIf

	restArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³gp042RCP    ºAutor  ³Mayra Camargo     º Data ³  15/05/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera Registros en Trayectoria Laboral para Rep Dominicanaº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nPar02:= Tipo de Finiquito 1. apl Finiquito 2. Deshacer Finº±±
±±º          ³ nPar02:= Si deshacer fin, si rev sit elimina Tray Lab      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function gp042RCP(nOp,nRevSit)
	Local lRet := .T.
	If nOp == 1
		lRet := fGenRCP()
	EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGenRCP     ºAutor  ³Mayra Camargo     º Data ³  15/05/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Genera Mov de baja en trayectoria Laboral al aplciar fin.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fGenRCP()

	Local cTipoMov
	Local lRet  	:= .T.
	Local lBjIMSS 	:= .F.					// Permitir incluir um rescisao junto com uma alteracao salarial
	Local nPos 		:= nPosA := nPosB := 0
	Local nPosDtMov 	
	Local nPosTipo  	
	Local nPosRPat  	
	Local nPosSal  	
	Local nPosDtImss
	Local nPosPer
	Local nPosPag
	Local nPosTpBa
	Local nPosCodFunc
	Local nPosCargo
	Local nPosTpCCSS
	Local nPosCic
	Local nPosTjrNda
	Local nPosTpFin
	Local dDtDemis		:= Ctod("//") 
	Local cKey			:= ''				// variavel com os valores das chaves. (variavel para getdados da tabela RCP)
	Local aRCPVirtGd	:= {}				// vetor com os campos virtuais. (variavel para getdados da tabela RCP)
	Local aRCPVisualGD	:= {} 				// vetor com os campos visuais. (variavel para getdados da tabela RCP)
	Local aRCPNotFields	:= {}				// vetor com os campos que nao seria visualizados. (variavel para getdados da tabela RCP)
	Local aArea			:= GetArea()
	Local nNewPos		:= 0
	Local nTamOri 
	Local cTipoReg
	Local dLastDt		:= CToD("  /  /  ")  
	Local cPdSrf		:= ""   
	Local nPosTpAlt 	:= 0
	Local lTLFuncSal    := .T.              // COS - Variável que determina que foi realizada uma troca de função + salário
	Local nPosAFP		:=  0
	Local nPosCC := 0
	Local cFilSRA     := xFilial( "SRA", SRA->RA_FILIAL )
	
	Private aRCPColsRec	:= {}				// vetor que contem os Recnos da tabela. (variavel para getdados da tabela RCP)
	Private nRCPUsado	:= 0.00 			// variavel que retorna a quantidade de campos da tabela. (variavel para getdados da tabela RCP)
	Private _aPerSel := {}
	Private aHeaderRCP := {}
	fGetPerAtual(@_aPerSel,xFilial("RCH"),SRA->RA_PROCES,fGetRotOrdinar())//fGetPerSel(SRA->RA_PROCES
	//Default nOp := 1 // 1. Generar baja en RCP 2. Eliminar Baja
	
	
	cKey	 := ( cFilSRA + SRA->RA_MAT )
	aHeaderRCP := {}						// foi necessario zerar a variavel pois o Gdmontacols nao gerencia o campo Ghost
	aRCPCols := RCP->( GdMontaCols(	@aHeaderRCP		,; 	//01 -> Array com os Campos do Cabecalho da GetDados
							  		@nRCPUsado		,;	//02 -> Numero de Campos em Uso
							  		@aRCPVirtGd		,;	//03 -> [@]Array com os Campos Virtuais
							  		@aRCPVisualGd	,;	//04 -> [@]Array com os Campos Visuais
	                          	"RCP"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
							  		aRCPNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
							  		@aRCPColsRec	,;	//07 -> [@]Array unidimensional contendo os Recnos
							  		"SRA"			,;	//08 -> Alias do Arquivo Pai
							  		cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
					 			  	NIL				,;	//10 -> Bloco para condicao de Loop While
		  			 				NIL				,;	//11 -> Bloco para Skip no Loop While
		  			 				.T.				,;	//12 -> Se Havera o Elemento de Delecao no aCols
		  			 				NIL				,;	//13 -> Se cria variaveis Publicas
		  			 				NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
		  			 				NIL				,;	//15 -> Lado para o inicializador padrao
		  			 				NIL				,;	//16 -> Opcional, Carregar Todos os Campos
		  			 				NIL				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
					 				NIL				,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
					 				NIL				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
					 				NIL				,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
					 				.T.				,;	//21 -> Carregar Coluna Fantasma
									NIL				,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									NIL				,;	//23 -> Verifica se Deve Checar se o campo eh usado
									NIL				,;	//24 -> Verifica se Deve Checar o nivel do usuario
									NIL				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
									NIL				,;	//26 -> [@]Array que contera as chaves conforme recnos
									NIL				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
									NIL				,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							       NIL				,;	//29 -> Numero maximo de Locks a ser efetuado
									.T.				 ;	//30 -> Utiliza Numeracao na GhostCol				 				
							  	);
									)					//funcao em PONXFUN.PRX
	
	aRCPColsAnt := aClone( aRCPCols ) 
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Reorganiza o array para o tratamento de datas duplicadas     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fReorgCols(@aRCPCols)
	
	nPosDtMov 	:= GdFieldPos( "RCP_DTMOV"	, aHeaderRCP )	
	nPosTipo  	:= GdFieldPos( "RCP_TPMOV"	, aHeaderRCP )	
	nPosRPat  	:= GdFieldPos( "RCP_CODRPA" , aHeaderRCP )	
	nPosSal  	:= GdFieldPos( "RCP_SALMES" , aHeaderRCP )	
	nPosDtImss	:= GdFieldPos( "RCP_DTIMSS" , aHeaderRCP )	                 
	nPosPer		:= GdFieldPos( "RCP_PERMOV" , aHeaderRCP )	                 
	nPosPag		:= GdFieldPos( "RCP_NPGMOV" , aHeaderRCP )	                 
	nPosTpBa	:= GdFieldPos( "RCP_CBIMSS" , aHeaderRCP )	                 
	nPosTpFin	:= GdFieldPos( "RCP_TIPFIN" , aHeaderRCP )
	If cPaisLoc <> "MEX"
		nPosDtImss	:= nPosDtMov
	EndIf
	nPosTpAlt	:= GdFieldPos( "RCP_TIPALT" , aHeaderRCP ) 

	IF cPaisLoc == "COL"
		nPosCodFunc 	:= GdFieldPos( "RCP_CODFUN", aHeaderRCP )
		nPosCargo		:= GdFieldPos( "RCP_CARGO"	, aHeaderRCP )
		nPosTpCCSS		:= GdFieldPos( "RCP_KEYLOC"	, aHeaderRCP )
		nPosTpFin		:= GdFieldPos( "RCP_CBIMSS" , aHeaderRCP )
		nPosTpAlt		:= GdFieldPos( "RCP_TIPALT" , aHeaderRCP )
		nPosAFP  		:= GdFieldPos( "RCP_NITAFP" , aHeaderRCP )
		nPosCic			:= GdFieldPos( "RCP_CIC"	, aHeaderRCP )
		nPosNITarl		:= GdFieldPos( "RCP_NITARL"	, aHeaderRCP )
	EndIF
	aModTraj	:= {}
	nTamOri  := Len(aRCPCols)
	
	If M-> RG_DATADEM == SRA->RA_DEMISSA
		nPos := aScan( aRCPCols , { |x| x[nPosTipo] == "02"  .And. x[nPosDtMov] == SRA->RA_DEMISSA  } )
		If nPos == 0 
			//Adiciona em Acols o tipo de movimento 02 , Para Colombia tipo RET
			GpMontac(GetMemVar( "RG_DATADEM" ),"02",,,@nNewPos)
			aRCPCols[nNewPos,nPosPer]	:= 	Gp010RetCont("RCH_PER",GetMemVar( "RG_DATADEM" ),SRA->RA_PROCES, @lRet)
			aRCPCols[nNewPos,nPosPag]	:= 	Gp010RetCont("RCH_NUMPAG",GetMemVar( "RG_DATADEM" ),SRA->RA_PROCES, @lRet)
			IF cPaisLoc $ "MEX|DOM"					
				aRCPCols[nNewPos,nPosTpFin]	:= SRA->RA_TIPOFIN
			ElseIf cPaisLoc == "COL"
				aRCPCols[nNewPos,nPosTpFin] := GetMemVar( "RA_TIPFIN" )
			EndIf
			aRCPCols[nNewPos,nPosTpAlt]	:= ""
			aRCPCols[nNewPos,nPosSal]	:= SRA->RA_SALARIO						
			aRCPCols[nNewPos,GdFieldPos( "RCP_MAT"		, aHeaderRCP )] := SRA->RA_MAT
			aRCPCols[nNewPos,GdFieldPos( "RCP_CC"		, aHeaderRCP )] := SRA->RA_CC
			aRCPCols[nNewPos,GdFieldPos( "RCP_DEPTO"	, aHeaderRCP )] := SRA->RA_DEPTO
			aRCPCols[nNewPos,GdFieldPos( "RCP_CODFUN"	, aHeaderRCP )] := SRA->RA_CODFUNC
			If cPaisLoc == "MEX"
				aRCPCols[nNewPos,GdFieldPos( "RCP_CODRPA", aHeaderRCP )]:= SRA->RA_CODRPAT
				aRCPCols[nNewPos,GdFieldPos( "RCP_SALDII", aHeaderRCP )]:= SRA->RA_SALINT
				aRCPCols[nNewPos,GdFieldPos( "RCP_SALIVC", aHeaderRCP )]:= SRA->RA_SALIVC
				aRCPCols[nNewPos,GdFieldPos( "RCP_TEIMSS", aHeaderRCP )]:= SRA->RA_TEIMSS
				aRCPCols[nNewPos,GdFieldPos( "RCP_TSIMSS", aHeaderRCP )]:= SRA->RA_TSIMSS
				aRCPCols[nNewPos,GdFieldPos( "RCP_CBIMSS", aHeaderRCP )]:= SRA->RA_TIPOAFA
				aRCPCols[nNewPos,GdFieldPos( "RCP_SALINS", aHeaderRCP )]:= SRA->RA_SALINS	
				aRCPCols[nNewPos,GdFieldPos( "RCP_TJRNDA", aHeaderRCP )]:= SRA->RA_TJRNDA	
				aRCPCols[nNewPos,nPosDtImss]:= SRG->RG_DATADEM					
			EndIf		
			If !GpValTraj(@aRCPCols, nNewPos, .F., cFilSRA)
				lRet := .F.
			Endif
			
			If lRet 
				GravaRCP()
			EndIf
		Endif
	EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDelGenRCP  ºAutor  ³Mayra Camargo     º Data ³  15/05/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Elimina Mov de baja en trayectoria Laboral al deshacer apl º±±
±±º          ³ de finiquito                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fDelRCP()
	Local lRet := .T.
	Local aArea:= GetArea()
	dbSelectArea("RCP")
	RCP->(dbSetOrder(2)) // RCP_FILIAL+RCP_MAT+RCP_TPMOV
	
	If RCP->(dbSeek(XFILIAL("RCP") + SRG->RG_MAT + "02"))
		RecLock("RCP",.f.)
			RCP->(dbDelete())
		RCP->(MsUnlock())		
		lRet := .T.
	EndIf
	RestArea(aArea)
	
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Gp042VacProgºAutor  ³Alfredo Medrano   º Data ³  05/11/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula las Vacaciones Progresivas que tuviera el empleado º±±
±±º          ³ en sus días derecho para el campo RG_DFERPRG               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                           	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp042VacProg(lVacNorm)
Local cCodFer 	  := "" 
Local cPer	  	  := Ctod("//")
Local lRetPer 	  := .F.
Local nRetVacPro := 0    
Local aPerAtual	  := {}
Local cRotRes     := fGetCalcRot("4") 
DEFAULT lVacNorm := .F.

If lRetPer  := fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRotRes ) //Busca Data Base periodo aberto RESCISAO
	Per := aPerAtual[1,6] 
EndIf

cCodFer:= IIF(lVacNorm,fGetCodFol("0072"),fGetCodFol("1383")) // Codigo de vacaciones progresivas 
If !(empty(cCodFer)) .and. lRetPer
	nRetVacPro := GpeDiasDere(1,M->RG_DATADEM,cCodFer,.f.)
EndIf
   

Return(nRetVacPro)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Gp042VaPc   ºAutor  ³Alfredo Medrano   º Data ³  05/06/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula las Vacaciones Proporcionales del  empleado        º±±
±±º          ³  para el campo RG_DFERPRO                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ RG_DFERPRO                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gp042VaPc()
Local cCodFer 	  	:= "" 
Local cPer	  	  	:= Ctod("//")
Local lRetPer 	  	:= .F.
Local nRetProp 		:= 0 
Local nDiaTrans		:= 0    
Local aPerAtual	  	:= {}
Local cRotRes     	:= fGetCalcRot("4") 

If lRetPer  := fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRotRes ) //Busca Data Base periodo aberto RESCISAO
	cPer := aPerAtual[1,6] 
EndIf

cCodFer:= fGetCodFol("0072") // Codigo de vacaciones proporcionales
If !(empty(cCodFer)) .and. lRetPer

	SRF->(DbSetOrder(2))
	SRF->( MsSeek( SRA->( RA_FILIAL + RA_MAT + cCodFer  ) ) )
	While !SRF->(EOF()) .and. SRA->( RA_FILIAL + RA_MAT ) + cCodFer == SRF->( RF_FILIAL + RF_MAT + RF_PD )
	    IF SRF->RF_DATABAS != cPer  .and. SRF->RF_STATUS == "1" .AND. ( M->RG_DATADEM >= SRF->RF_DATABAS .AND. M->RG_DATADEM <= SRF->RF_DATAFIM ) 
	    	//Calcula Días Proporcionales
	    	//nDiaTrans	:= M->RG_DATADEM - SRF->RF_DATABAS + 1ADM
	    	nRetProp	:= FGENPROPCHI(M->RG_DATADEM)//((nDiaTrans * SRF->RF_DIASDIR ) / 365) - SRF->RF_DFERANT
	    	If /*nDiaTrans < 30 .OR.*/ nRetProp < 0
	    		 nRetProp := 0	
	    	EndIf
	   
        EndIf
		SRF->( DbSkip()	)
	EndDo
	
	
	SRF->(DbSetOrder(1))
EndIf
Return(nRetProp)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGenPropChi ºAutor  ³Mayra Camargo     º Data ³  15/12/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula las Vacaciones Proporcionales del  empleado        º±±
±±º          ³ en base a la fecha informada en parámetro dDataDem         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ dPara01:= Fecha de demisión                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ RG_DFERPRO                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function fGenPropChi(dDataDem)

	Local nDiasTrans 	:= 0
	Local nMesesTrans	:= 0
	Local nPropMes 		:= 0
	Local nPropDias 	:= 0

	
	If MONTH(dDataDem)> MONTH(SRF->RF_DATABAS) .OR. (MONTH(dDataDem)= MONTH(SRF->RF_DATABAS) .AND. DAY(dDataDem)>= DAY(SRF->RF_DATABAS)) //RCH->RCH_DTFIM >=SRF->RF_DATABAS 
		nMesesTrans := Iif(DAY(dDataDem)>= DAY(SRF->RF_DATABAS),;
							MONTH(dDataDem)- MONTH(SRF->RF_DATABAS),;
							MONTH(dDataDem)- MONTH(SRF->RF_DATABAS)-1)		
	Else												
		nMesesTrans := Iif(DAY(dDataDem)>= DAY(SRF->RF_DATABAS),;
							12-(MONTH(SRF->RF_DATABAS)- MONTH(dDataDem)),;
							12-(MONTH(SRF->RF_DATABAS)- MONTH(dDataDem)+1))	
	EndIf
	
	nDiasTrans := Iif(DAY(dDataDem)>= DAY(SRF->RF_DATABAS),;
						DAY(dDataDem)- DAY(SRF->RF_DATABAS),;
						last_day(dDataDem)-(DAY(SRF->RF_DATABAS)- DAY(dDataDem)))
							
	nPropMes  := nMesesTrans * (SRF->RF_DIASDIR/12)
	nPropDias := nDiasTrans  *((SRF->RF_DIASDIR/12)/ 30)	
									
	nDProp := nPropMes + nPropDias 
	If (nMesesTrans == 11 .and. 	nDiasTrans== 30) 	
		nDProp := 0
	EndIF						 
Return nDProp



Static Function leeSRG(cMat)

	Local cAliasQRY:=CriaTrab(Nil,.F.)
	Local cQuery :=""
	
	aSRG:={}
	
	cQuery := "SELECT RG_EFETIVA FROM " + RetSqlName("SRG")
	cQuery += " WHERE RG_MAT = '" + cMat+ "'
	cQuery += " AND  RG_FILIAL = '" + xFilial("SRG") + "'"
	cQuery += "  AND D_E_L_E_T_ <> '*'
	cQuery += " ORDER BY RG_DATADEM DESC"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY)
	
	WHILE  !(cAliasQRY)->(EOF())
		AADD(aSRG,(cAliasQRY)->RG_EFETIVA)
		(cAliasQRY)->(dbskip()) 
	Enddo
	(cAliasQRY)->( dbCloseArea())

Return (aSRG)
