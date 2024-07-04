#include "Protheus.ch"
#include "TCFA021.CH"
#Include 'FWMVCDEF.CH'
/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    � TCFA021  � Autor � Emerson Campos                    � Data � 19/04/2012 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Categoria de artefatos                                       ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   � TCFA021()                                                                ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL NA VERSAO MVC              ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Cecilia Car.�24/07/2014�TQEA22          �Incluido o fonte da 11 para a 12 e efetuada ���
���            �          �                �a limpeza.                                  ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/
FUNCTION TCFA021    
	Local cFiltraRh
	Local oBrwRHY    

    oBrwRHY := FWmBrowse():New()		
	oBrwRHY:SetAlias( 'RHY' )
	oBrwRHY:SetDescription(STR0001)	//"Categoria de Artefatos"

	//Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh	:= CHKRH(FunName(),"RHY","1")
	//Filtro padrao do Browse conforme tabela RHY (Categoria de Artefatos)
	oBrwRHY:SetFilterDefault(cFiltraRh)

	oBrwRHY:Activate()
Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef    � Autor � Emerson Campos        � Data � 19/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Menu Funcional                                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � TCFA021                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002  Action 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.TCFA021'  OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.TCFA021'  OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.TCFA021' 	OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title STR0006  Action 'VIEWDEF.TCFA021'  OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ModelDef   � Autor � Emerson Campos        � Data � 19/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados e Regras de Preenchimento para o Cadastro de ���
���          � Categoria de artefatos                                       ���
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
	Local oStruRHY := FWFormStruct( 1, 'RHY', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oMdlRHY
	
	// Blocos de codigo do modelo
    Local bPosValid 	:= { |oMdl| Tc021PosVal( oMdl )}
    Local bCommit		:= { |oMdl| Tc021Grav( oMdl )}
	// Bloco de codigo doa Fields
	Local bTOkVld		:= { |oGrid| Tc021TOk( oGrid, oMdlRHY)}
	
	// Cria o objeto do Modelo de Dados
	oMdlRHY := MPFormModel():New('MDTCFA021', /*bPreValid*/, bPosValid, bCommit, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oMdlRHY:AddFields( 'MODELTCFA021', /*cOwner*/, oStruRHY, /*bLOkVld*/, bTOkVld, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oMdlRHY:SetDescription(STR0001)	//"Categoria de artefatos"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRHY:GetModel( 'MODELTCFA021' ):SetDescription(STR0001)	//"Categoria de artefatos"
		
Return oMdlRHY
	
	
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ViewDef    � Autor � Emerson Campos        � Data � 19/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizador de dados do Cadastro de Categoria de artefatos  ���
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
	Local oMdlRHY   := FWLoadModel( 'TCFA021' )
	// Cria a estrutura a ser usada na View
	Local oStruRHY := FWFormStruct( 2, 'RHY' )
	Local oView
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlRHY )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_TCFA021', oStruRHY, 'MODELTCFA021' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_TCFA021', 'FORMFIELD' )

Return oView

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Tc021PosVal� Autor � Emerson Campos        � Data � 19/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Pos-validacao do Cadastro de Categoria de artefatos          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tc021PosVal( oMdlRHY )                                       ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRHY = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Tc021PosVal( oMdlRHY )
	Local lRetorno      := .T.
	Local nOperation
	
	// Seta qual � a operacao corrente
	nOperation := oMdlRHY:GetOperation()	
	
Return lRetorno

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Tc021Grav  � Autor � Emerson Campos        � Data � 19/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao responsavel pelo commit do Cad.de Categ. de artefatos ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tc021Grav( oMdlRHY )                                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oMdlRHY = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Tc021Grav( oMdlRHY )
	Local lRetorno       := .T.	
	Local nOperation
	Local aSaveLines
	
	// Seta qual � a operacao corrente
	nOperation := oMdlRHY:GetOperation()
	// Salva as posicoes das FWFormGrids do Model
	aSaveLines := FWSaveRows()
	// Fornece o objeto da classe FWFormModel ativo no momento, para ser utilizado nas regras de validacao. 
	FWModelActive( oMdlRHY )    
    /* Realiza os tratamentos necessarios para gravacao dos formularios de edicao. A Gravacao e 
    realizada em niveis onde o primeiro elemento do modelo e posteriormente seus filhos sao gravados.*/
	FWFormCommit( oMdlRHY )
    // Restaura as posicoes das FWFormGrids do Model 
	FWRestRows( aSaveLines )
Return lRetorno                                             
 
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Tc021TOk   � Autor � Emerson Campos        � Data � 19/04/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Tudo Ok do Cadastro de Cargos                                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tc021TOk( oGrid, oMdlRHY )                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oGrid   = Objeto da Grid                                     ���
���          � oMdlRHY = Objeto do modelo                                   ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRetorno = .T. ou .F.                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function Tc021TOk( oGrid, oMdlRHY )
	Local lRetorno       := .T.
	Local nOperation
	
	// Seta qual � a operacao corrente   
	nOperation := oMdlRHY:GetOperation()	
	
Return lRetorno