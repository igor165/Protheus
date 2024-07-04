#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FISA808.CH'
#include "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   �  FISA808 � Autor � alfredo.medrano     � Data �  10/05/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Equivalencia COF entrada/salida  COLOMBIA                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FISA808()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mantenimiento a mnem�nicos                                 ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao              ���
�������������������������������������������������������������������������Ĵ��
���Alf. Medrano  �06/07/16�TVOJAM     �se quita dbcloseArea func FISA808V ���
���              �        �           �se agrega Msg confirma borrado en  ���
���              �        �           �FISA808P                           ���
���              �        �           �asigna titulo"C�digo Fiscal Salida"���
���              �        �           �al ViewDef                         ���
���Alf. Medrano  �26/07/16�           � valida COF Entrada cuando se copia���
���              �        �           �un registro en func FISA808P       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function FISA808()
Local 	 oBrowse
Private oArial10

oArial10 := tFont():New("Arial",,-10,,.t.) // fuente del Texto	
//�������������������������������������������Ŀ
//�Browse Automatico contiene				:   �
//�B�squeda de Registro                       �
//�Filtro configurable                        �
//�Configuraci�n de columnas y apariencia     �
//�Impresi�n                                  �
//���������������������������������������������
oBrowse:= FWMBrowse():New()
dbselectArea("CWF")
dbselectArea("CWE")
oBrowse:SetAlias('CWE') // Codigo Fiscal Entrada
oBrowse:SetDescription(OemToAnsi(STR0001)) // "Equivalencia COF entrada/salida"
oBrowse:Activate()

Return NIL
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MenuDef  � Autor � Alfredo Medrano       � Data �10/05/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � define las operaciones que ser�n realizadas por la         ���
���          � aplicaci�n: incluir, alterar, excluir etc.                 ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � FWMVCMenu                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FISA808                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title OemToAnsi(STR0002)	Action 'VIEWDEF.FISA808' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title OemToAnsi(STR0003)	Action 'VIEWDEF.FISA808' OPERATION 3 ACCESS 0 //"Incluir"   
ADD OPTION aRotina Title OemToAnsi(STR0004) 	Action 'VIEWDEF.FISA808' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0005) 	Action 'VIEWDEF.FISA808' OPERATION 5 ACCESS 0 //"Excluir" 
ADD OPTION aRotina Title OemToAnsi(STR0006) 	Action 'VIEWDEF.FISA808' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina Title OemToAnsi(STR0007)	Action 'VIEWDEF.FISA808' OPERATION 9 ACCESS 0 //"Copiar" 
Return aRotina
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ModelDef � Autor � Alfredo Medrano       � Data �10/05/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Contiene la construcci�n y la definici�n del Modelo        ���
���          � (Model) contiene las reglas del negocio                    ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FISA808                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCWE := FWFormStruct( 1, 'CWE', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruCWF := FWFormStruct( 1, 'CWF', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel
// Cria o objeto do Modelo de Dados
oModel:= MPFormModel():New('FISA808', /*bPre*/, { | oMdl | FISA808P( oMdl ) }, /*bCommit*/, /*bCancel*/ )
// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:addfields( 'CWEMASTER', /*cOwner*/, oStruCWE, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'CWFDETAIL', 'CWEMASTER', oStruCWF, /*bLinePRE*/,/*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CWFDETAIL', { { 'CWF_FILIAL', 'xFilial( "CWF" )' }, { 'CWF_COFIEN', 'CWE_COFIEN' } }, CWF->( IndexKey( 1 ) ) )
oModel:SetPrimaryKey( {} ) 
// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CWFDETAIL' ):SetUniqueLine( { 'CWF_COFIEN', 'CWF_COFISA' } )
// Adiciona a descricao do Modelo de Dadosadmin	
oModel:SetDescription( OemToAnsi(STR0008) + " " + OemToAnsi(STR0001) )// "Equivalencia COF entrada/salida"
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CWEMASTER' ):SetDescription( OemToAnsi(STR0009) ) // "C�digo Fiscal Entrada"

//oStruCWE:SetProperty( 'CWE_COFIEN' , MODEL_FIELD_WHEN,{ ||FISA808C() })
//oStruCWE:SetProperty( 'CWE_COFIEN' , MODEL_FIELD_VALID,{ ||FISA808C() })

Return oModel
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ViewDef  � Autor � Alfredo Medrano       � Data �10/05/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Contiene la construcci�n y la definici�n de la View        ���
���          � construcci�n de la interfaz                                ���  
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FISA808                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static function ViewDef()
Local oStruCWE := FWFormStruct( 2, 'CWE' )
Local oStruCWF := FWFormStruct( 2, 'CWF' )
Local oModel   := FWLoadModel( 'FISA808' )
Local oView
oStruCWF:RemoveField("CWF_COFIEN")
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CWE', oStruCWE, 'CWEMASTER' )
//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_CWF', oStruCWF, 'CWFDETAIL' )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CWE', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_CWF', 'INFERIOR' )
// Define campos que terao Auto Incremento	
//oView:AddIncrementField( 'VIEW_CWF', 'CWF_XXX' )
// Criar novo botao na barra de botoes
//oView:AddUserButton( 'Inclui', 'CLIPS', { |oView| Funcion() } )
// Liga a identificacao do componente
oView:EnableTitleView('VIEW_CWF',OemToAnsi(STR0010)) //"C�digo Fiscal Salida"
// Liga a Edi��o de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_CWF', "ENABLEDGRIDDETAIL", { 50 } )

//oStruCWE:SetProperty( 'CWE_COFIEN' ,MVC_VIEW_CANCHANGE, FISA808D() )
Return oView

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FISA808V  � Autor � Alfredo Medrano       � Data �19/05/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida que no este repetido el Cod Fis. de salida          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FISA808V()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CWF_COFISA                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FISA808V()
	Local aArea 		:= getArea()
	Local oModel    	:= FWModelActive()
	Local cCodFS:=''
	Local cCodFE:=''
	Local lRet:= .T.
	
	cCodFS	:= oModel:GetValue("CWFDETAIL","CWF_COFISA")
	cCodFE	:= oModel:GetValue("CWEMASTER","CWE_COFIEN")
	
	dbselectArea('CWF')
	CWF->(dbSetOrder(1)) 
	IF CWF->(DBSeek(XFILIAL("CWF")+cCodFE+cCodFS))	
		MSGALERT(OemToAnsi(STR0011), "") //Ya existe Registro con este codigo Fiscal" 
		lRet= .F.
	EndIf
	RestArea(aArea)
Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FISA808P  � Autor � Alfredo Medrano       � Data �02/06/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Control de eventos en Post Validaci�n                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FISA808P(ExpO1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lBorrar                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 := Modelo de datos                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FISA808P(oModel)
	Local aArea		:= getArea()
	Local lVal		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cCodFE := ""

	If nOperation ==	MODEL_OPERATION_DELETE  
	 	lVal := MsgNoYes(OemToAnsi(STR0012) ) // "Eliminar el Registro?"
	EndIf
	
	If nOperation ==	3	
		cCodFE	:= oModel:GetValue("CWEMASTER","CWE_COFIEN")
		dbselectArea('CWE')
		CWE->(dbSetOrder(1)) 
		IF CWE->(DBSeek(XFILIAL("CWE")+cCodFE))	
			MSGALERT(OemToAnsi(STR0011) + OemToAnsi(STR0013) , "") //Ya existe Registro con este codigo Fiscal" "de Entrada" 
			lVal= .F.
		EndIf	
	EndIf
	
	RestArea(aArea)                         
Return lVal




