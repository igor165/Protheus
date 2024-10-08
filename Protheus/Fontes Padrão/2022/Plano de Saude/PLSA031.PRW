#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'TBICONN.CH'  
#include "PLSMGER.CH" 
#include "PLSA031.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA031   �Autor  �Microsiga           � Data �  04/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Historico de autorizacoes forcadas						  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA031()
Local oBrowse

If ! CheckB67()
   Return
Endif       

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BDS')
oBrowse:SetDescription(STR0001) //"Consultar Historico de Autorizacoes Forcadas"
//oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |MenuDef   �Autor  �Microsiga           � Data �  04/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �  														  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.PLSA031' OPERATION 2 ACCESS 0 //'Visualizar'

Return aRotina
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ModelDef  �Autor  �Microsiga           � Data �  04/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Cria a estrutura a ser usada no Modelo de Dados		  	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()
Local oStruBDS := FWFormStruct( 1, 'BDS', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruB67 := FWFormStruct( 1, 'B67', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('PLSA031MD', /*bPreValidacao*/, nil/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('COMP011MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'BDSMASTER', /*cOwner*/, oStruBDS, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'B67DETAIL', 'BDSMASTER', oStruB67, ,, /*bPreVal*/,/*bPreVal*/, {|oModel,y| GridLoad(oModel,y)}/*BLoad*/ )

oModel:SetPrimaryKey({"BDS_FILIAL","BDS_OPEMOV","BDS_ANOAUT","BDS_MESAUT","BDS_NUMAUT","BDS_ORIGEM"})

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B67DETAIL', { 	{ 'B67_FILIAL', 'xFilial( "B67" )' },; 
									{ 'B67_OPEMOV', 'BDS_OPEMOV' },; 
									{ 'B67_ANOAUT', 'BDS_ANOAUT' },; 
									{ 'B67_MESAUT', 'BDS_MESAUT' },; 
									{ 'B67_NUMAUT', 'BDS_NUMAUT' },; 
									{ 'B67_ORIGEM', 'BDS_ORIGEM' },; 
									{ 'B67_CODPAD', 'BDS_CODPAD' },; 
									{ 'B67_CODPRO', 'BDS_CODPRO' } }, "B67_FILIAL+B67_OPEMOV+B67_ANOAUT+B67_MESAUT+B67_NUMAUT+B67_ORIGEM+B67_CODPAD+B67_CODPRO" )

// Indica que � opcional ter dados informados na Grid
oModel:GetModel( 'B67DETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //"Consultar Historico de Autorizacoes Forcadas"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BDSMASTER' ):SetDescription( STR0001 ) //"Consultar Historico de Autorizacoes Forcadas"
oModel:GetModel( 'B67DETAIL' ):SetDescription( STR0004 ) //"Criticas For�adas"

// Liga a valida��o da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } ) 

Return oModel
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ViewDef   �Autor  �Microsiga           � Data �  04/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria um objeto de Modelo de Dados baseado no ModelDef      ���
���          � do fonte informado		  	                              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
Local oStruBDS := FWFormStruct( 2, 'BDS' )
Local oStruB67 := FWFormStruct( 2, 'B67' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA031' )

//Local oStruBDS := FWFormStruct( 2, 'BDS', { |cCampo| COMP11STRU(cCampo) } )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BDS', oStruBDS, 'BDSMASTER' )  

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B67', oStruB67, 'B67DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 65 )
oView:CreateHorizontalBox( 'INFERIOR', 35 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_BDS', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_B67', 'INFERIOR' )

Return oView
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GridLoad  �Autor  �Microsiga           � Data �  04/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Faz a carga dos dados Ordenando as Criticas.  		      ���
���          � 							  	                              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GridLoad(oModel,y)
Local aRetorno := {}
Local aDefault := FormLoadGrid(oModel,y)
Local aDados   := aClone(aDefault) 

If Len(aDados) > 0
	aDados := aClone(ASort(aDados,,, { |x,y| x[1] < y[1] }))
Endif

Return aDados
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CheckB67  �Autor  �Microsiga           � Data �  04/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Checa se o compatibilizador foi executado.	  		      ���
���          � 							  	                              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CheckB67()
Local lExite :=	.F.

SIX->(dbSetOrder(1))
If SIX->(dbSeek("B67"))
   lExite :=	.T.
Else
   Aviso( STR0005, STR0006, {STR0007} ) //"Tabela B67 n�o foi encontrada"###"Execute o compatibilizador da FNC 00000028736/2010, Chamado SDBNOO."###"Ok"
EndIf
	
Return lExite





Function CheckHis(cNumgui)

Local aAreaB53 := B53->(GetArea())
Local aAreaSX5 := SX5->(GetArea())
Local cRetorno := ""

default cNumgui = ""

B53->( DbSetOrder(1) )  
IF (B53->(MsSeek(xFilial("B53") + cNumgui)) )
	cRetorno := BCT->(POSICIONE("BCT",1,XFILIAL("BCT")+BDS->(BDS_OPEMOV+BDS_CODMOT),"BCT_DESCRI"))
else
	cRetorno :=	SX5->(POSICIONE("SX5",1,XFILIAL("SX5")+"BU"+BDS->BDS_CODMOT,"X5_DESCRI"))
EndiF

RestArea(aAreaB53)
RestArea(aAreaSX5)

Return(cRetorno)










