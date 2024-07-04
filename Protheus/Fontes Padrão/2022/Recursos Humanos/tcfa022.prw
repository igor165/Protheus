#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'TCFA022.CH'
/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    � TCFA022  � Autor � Emerson Campos                    � Data � 08/05/2012 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Configuracao para o arquivo do cad. de artefatos  (RHZ)      ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � TCFA022()                                                                ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Cecilia Car.�24/07/2014�TQEA22          �Incluido o fonte da 11 para a 12 e efetuada ���
���            �          �                �a limpeza.                                  ���
���Renan Borges�25/04/2016�TUZCRD          �Ajuste para cadastrar configura��es de ambi-���
���            �          �                �ente corretamente para ser poss�vel a trans-���
���            �          �                �fer�ncia de um artefato para o servidor, per���
���            �          �                �mitindo sua visualiza��o no Portal.         ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/
Function TCFA022()
	Local oBrwRHZ

    oBrwRHZ := FWmBrowse():New()		
	oBrwRHZ:SetAlias( 'RHZ' )
	oBrwRHZ:SetDescription(STR0001)	//"Configuracao para o Cadastro de Artefatos"		

	oBrwRHZ:Activate()
Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef    � Autor � Emerson Campos        � Data �08/05/2012���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Menu Funcional                                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {}
 
	ADD OPTION aRotina Title STR0002  	Action 'PesqBrw'         	OPERATION 1 ACCESS 0	//"Pesquisar"
	ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.TCFA022' 	OPERATION 2 ACCESS 0	//"Visualizar"   
	ADD OPTION aRotina Title STR0004  	Action 'VIEWDEF.TCFA022' 	OPERATION 3 ACCESS 0	//"Incluir"
	ADD OPTION aRotina Title STR0005  	Action 'VIEWDEF.TCFA022' 	OPERATION 4 ACCESS 0	//"Alterar" 
	ADD OPTION aRotina Title STR0006  	Action 'VIEWDEF.TCFA022' 	OPERATION 5 ACCESS 0 	//"Excluir" 

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef   � Autor � Emerson Campos        � Data �08/05/2012���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados e Regras de Preenchimento para o Configuracao���
���          � para o arquivo do cad. de artefatos (RHZ)                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRHZ := FWFormStruct( 1, 'RHZ', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oMdlRHZ
		
	// Bloco de codigo da Fields
	Local bTOkVld		:= { |oGrid| RHZTOk( oGrid, oMdlRHZ)}
		
	// Cria o objeto do Modelo de Dados
	oMdlRHZ := MPFormModel():New('TCFA022', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oMdlRHZ:AddFields( 'MODELRHZInf', /*cOwner*/, oStruRHZ, /*bLOkVld*/, bTOkVld, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oMdlRHZ:SetDescription(STR0001)	//"Configuracao para o Cadastro de Artefatos"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRHZ:GetModel( 'MODELRHZInf' ):SetDescription(STR0001)	//"Configuracao para o Cadastro de Artefatos"
		
Return oMdlRHZ

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ViewDef    � Autor � Emerson Campos        � Data �08/05/2012���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados e Regras de Preenchimento para o Configuracao���
���          � para o arquivo do cad. de artefatos (RHZ)                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oMdlRHZ   := FWLoadModel( 'TCFA022' )
	// Cria a estrutura a ser usada na View
	Local oStruRHZ := FWFormStruct( 2, 'RHZ' )
	Local oView
		
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlRHZ )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_RHZInf', oStruRHZ, 'MODELRHZInf' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RHZInf', 'FORMFIELD' )

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � RHZTOk     � Autor � Emerson Campos        � Data �08/05/2012���
���������������������������������������������������������������������������Ĵ��
���Descri��o � MValidacao da Fields                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � RHZTOk()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function RHZTOk( oGrid, oMdlRHZ )
	Local lRet      := .T.
Return lRet