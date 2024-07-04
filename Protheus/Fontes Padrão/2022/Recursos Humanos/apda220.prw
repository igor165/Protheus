#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'APDA220.CH'

/*�������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Programa     � APDA220  � Autor � Equipe IP-RH          � Data � 23/07/12  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o    � Cadastro Competencias                                       ���
�����������������������������������������������������������������������������Ĵ��
���Uso          � SigaApd - Arquitetura Organizacional                        ���
�����������������������������������������������������������������������������Ĵ��
���Programador  � Data   � BOPS      �  Motivo da Alteracao                   ���  
�����������������������������������������������������������������������������Ĵ�� 
���Cecilia Car. �03/07/14�TPZWBQ     �Incluido o fonte da 11 para a 12 e efetu��� 
���             �        �           �ada a limpeza.                          ���
���Isabel N.    �02/08/17�DRHPONTP-  �Ajuste nos par�metros de filial passados���
���             �        �1214       �nos relacionamentos RDMxRD2 e RD2xRBJ.  ��� 
������������������������������������������������������������������������������ٱ� 
���������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Function APDA220()
	
Local aCoors  := FWGetDialogSize( oMainWnd )
Local oFWLayer, oPanelUp

Private oDlgPrinc
Private oBrowseUp
Private oBrowseLeft
Private oBrowseRight
Private oRelacRDMRD2
Private oRelacRD2RBJ
                        
Private cCadastro   := OemToAnsi( STR0001 )	//"Compet�ncias"

Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

/*/
�������������������������������������������������������������Ŀ
�Cria o container onde ser�o colocados os browses        	  �
���������������������������������������������������������������/*/
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )

//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 40, .F. )                       // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )            // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )         // Pego o objeto desse peda�o do container

//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 60, .F. )                     // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'LEFT' ,  50, .T., 'DOWN' )
oFWLayer:AddCollumn( 'RIGHT',  50, .T., 'DOWN' )

oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )  // Pego o objeto do peda�o esquerdo
oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )  // Pego o objeto do peda�o direito

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
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  IP Rh Inovacao   � Data �23/07/2012�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �APDA220                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Apda220Rel  � Autor �IP-RH Inovacao       � Data � 23/07/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chama a rotina de Relacionamento Competencias X Habilidades ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Apda200Rel( cAlias , nReg )	         					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cAlias = Alias do arquivo                                   ���
���          �nReg   = Numero do registro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �APDA220                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Apda220Rel(cAlias,nReg) 
Private cCadastro   := OemToAnsi( STR0011 ) //"Relacionamento Competencia x Habilidade"

CSAa160Mnt(cAlias,nReg,3)

Return