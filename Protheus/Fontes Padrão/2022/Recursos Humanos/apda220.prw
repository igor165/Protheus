#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'APDA220.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa     ³ APDA220  ³ Autor ³ Equipe IP-RH          ³ Data ³ 23/07/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Cadastro Competencias                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ SigaApd - Arquitetura Organizacional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS      ³  Motivo da Alteracao                   ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Cecilia Car. ³03/07/14³TPZWBQ     ³Incluido o fonte da 11 para a 12 e efetu³±± 
±±³             ³        ³           ³ada a limpeza.                          ³±±
±±³Isabel N.    ³02/08/17³DRHPONTP-  ³Ajuste nos parâmetros de filial passados³±±
±±³             ³        ³1214       ³nos relacionamentos RDMxRD2 e RD2xRBJ.  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function APDA220()
	
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oFWLayer, oPanelUp

Private oDlgPrinc
Private oBrowseUp
Private oBrowseLeft
Private oBrowseRight
Private oRelacRDMRD2
Private oRelacRD2RBJ
                        
Private cCadastro   := OemToAnsi( STR0001 )	//"Competˆncias"

Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Cria o container onde serão colocados os browses        	  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )

//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 40, .F. )                       // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )            // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )         // Pego o objeto desse pedaço do container

//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 60, .F. )                     // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'LEFT' ,  50, .T., 'DOWN' )
oFWLayer:AddCollumn( 'RIGHT',  50, .T., 'DOWN' )

oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )  // Pego o objeto do pedaço esquerdo
oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )  // Pego o objeto do pedaço direito

//
// FWmBrowse Superior Grupo de Competencias
//
oBrowseUp:= FWmBrowse():New()
oBrowseUp:SetOwner( oPanelUp )                          // Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( STR0001 )
oBrowseUp:SetAlias( 'RDM' )
oBrowseUp:SetProfileID( '1' )
oBrowseUp:DisableDetails()
oBrowseUP:SetMenuDef( 'APDA220' )                       // Referencia uma funcao que nao tem menu para que nao exiba nenhum botao
oBrowseUp:DisableReport()
oBrowseUp:DisableConfig()
oBrowseUp:DisableSaveConfig()
oBrowseUp:ForceQuitButton()
oBrowseUp:Activate()
//
// Lado Esquerdo Competencias
//
oBrowseLeft:= FWMBrowse():New()
oBrowseLeft:SetOwner( oPanelLeft )
oBrowseLeft:SetDescription( STR0002 ) // 'itens de Competencias'
oBrowseLeft:SetMenuDef( '' )         // Referencia uma funcao que nao tem menu para que nao exiba nenhum botao
oBrowseLeft:DisableDetails()
oBrowseLeft:SetAlias( 'RD2' )
oBrowseLeft:SetProfileID( '2' )
oBrowseLeft:DisableReport()
oBrowseLeft:DisableConfig()
oBrowseLeft:DisableSaveConfig()
oBrowseLeft:Activate()
//
// Lado Direito Habilidades
//
oBrowseRight:= FWMBrowse():New()
oBrowseRight:SetOwner( oPanelRight )
oBrowseRight:SetDescription( STR0003 ) // 'Habilidades'
oBrowseRight:SetMenuDef( '' )                      // Referencia uma funcao que nao tem menu para que nao exiba nenhum botao
oBrowseRight:DisableDetails()
oBrowseRight:SetAlias( 'RBJ' )
oBrowseRight:SetProfileID( '3' )
oBrowseRight:DisableReport()
oBrowseRight:DisableConfig()
oBrowseRight:DisableSaveConfig()
oBrowseRight:Activate()

//
// Relacionamento entre os Paineis
//
oRelacRDMRD2:= FWBrwRelation():New()
oRelacRDMRD2:AddRelation( oBrowseUp  , oBrowseLeft , { { 'RD2_FILIAL', 'RDM_FILIAL' }, { 'RD2_CODIGO' , 'RDM_CODIGO'  } } )
oRelacRDMRD2:Activate()

oRelacRD2RBJ:= FWBrwRelation():New()
oRelacRD2RBJ:AddRelation( oBrowseLeft, oBrowseRight, { { 'RBJ_FILIAL', 'RD2_FILIAL' }, { 'RBJ_CODCOM' , 'RD2_CODIGO' }, {  'RBJ_ITECOM' , 'RD2_ITEM' } } )
oRelacRD2RBJ:Activate()

ACTIVATE MSDIALOG oDlgPrinc Center

Return    

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  IP Rh Inovacao   ³ Data ³23/07/2012³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³APDA220                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

Local aRotina := {}

// Local aRotina := {;
//					{ STR0004 	, "AxPesqui"	, 0 , 01,,.F. } ,; //"Pesquisar"
//					{ STR0005 	, "Apda050Mnt" , 0 , 02 } ,; //"Visualizar"
//					{ STR0006 	, "Apda050Mnt" , 0 , 03 } ,; //"Incluir"
//					{ STR0007  	, "Apda050Mnt" , 0 , 04 } ,; //"Alterar"
//					{ STR0008 	, "Apda050Mnt" , 0 , 05 } ,; //"Excluir"
//					{ STR0009 	, "Apda050Mnt" , 0 , 04 } ,; //"Montar Estrutura"
//					{ STR0010 	, "Apda220Rel" , 0 , 04 }  ; //"Relacionar"
//					}

ADD OPTION aRotina Title STR0004 	Action 'AxPesqui' 	OPERATION 1 ACCESS 0
ADD OPTION aRotina Title STR0005 	Action 'Apda050Mnt' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0006	Action 'Apda050Mnt' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title STR0007	Action 'Apda050Mnt' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0008	Action 'Apda050Mnt' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title STR0009	Action 'Apda050Mnt' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0010	Action 'Apda220Rel' OPERATION 4 ACCESS 0

Return aRotina

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Apda220Rel  ³ Autor ³IP-RH Inovacao       ³ Data ³ 23/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama a rotina de Relacionamento Competencias X Habilidades ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Apda200Rel( cAlias , nReg )	         					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias = Alias do arquivo                                   ³±±
±±³          ³nReg   = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³APDA220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Apda220Rel(cAlias,nReg) 
Private cCadastro   := OemToAnsi( STR0011 ) //"Relacionamento Competencia x Habilidade"

CSAa160Mnt(cAlias,nReg,3)

Return