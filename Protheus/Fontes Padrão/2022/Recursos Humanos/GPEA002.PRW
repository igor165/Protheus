#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA002.CH"

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    	� GPEA002    � Autor � Mauricio Takakura     	      � Data � 27/09/11 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o 	� Historico de Alteracoes dos Planos Ativos                    			���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEA002()                                                    			���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      	� Generico ( DOS e Windows )                                   			���
���������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               			���
���������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC			�  Motivo da Alteracao                      ���
���������������������������������������������������������������������������������������Ĵ��
���Cecilia Car. �15/05/2014�TPPCSB          �Incluido o fonte da 11 para a 12 e efetuada���
���             �          �                � a limpeza.                                ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Function GPEA002()
	Local oMBrowse
	Local cFiltraRh

	oMBrowse := FWMBrowse():New()
	
	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Historico de Alteracoes Planos Ativos"

	GpLegMVC(@oMBrowse)	// Adicionar a Legenda no Browse
	
	oMBrowse:ForceQuitButton()								//"Incluir botao de sair" 
	
	/*
	������������������������������������������������������������������������Ŀ
	� Inicializa o filtro utilizando a funcao FilBrowse                      �
	��������������������������������������������������������������������������*/
	cFiltraRh := CHKRH("GPEA002","SRA","1")
	oMBrowse:SetFilterDefault( cFiltraRh )
	                           
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
	
Return

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Mauricio Takakura� Data �27/09/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Criacao do Menu do Browse.                                  �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA002                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar' 
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA002" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.GPEA002" 		OPERATION 4 ACCESS 0				//'Manutencao'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA002" 		OPERATION 5 ACCESS 0				//'Excluir'
								
Return aRotina
	
/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � ModelDef 		�Autor�  Mauricio Takakura� Data �27/09/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Modelagem da gravacao.                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA002                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ModelDef()

	Local oModel
	Local oStructSRA
	Local oStructRHN	// Historico de Alteracoes de Planos Ativos
	
	// Criacao do Objeto de Modelagem de dados //	
	oModel     := MPFormModel():New("GPEA002",,, /*{ |oModel| Gp001Commit(oModel) }*/ )
	oModel:SetDescription( OemToAnsi(STR0001) ) //"Historico de Alteracoes Planos Ativos"
    
	// Cabecalho de dados - SRA (Funcionario)//
	oStructSRA := FWFormStruct(1, "SRA",  { |cCampo| Gpa002SRAStru(cCampo) })
	oModel:AddFields("GPEA002_MSRA", NIL, oStructSRA)
	oModel:GetModel( "GPEA002_MSRA" ):SetDescription( OemToAnsi(STR0001) ) //"Historico de Alteracoes Planos Ativos"
	oModel:GetModel('GPEA002_MSRA'):SetOnlyQuery(.T.)
	oModel:GetModel('GPEA002_MSRA'):SetOnlyView(.T.)

	// Estrutura de campos do Model - RHN - Historico de Alteracoes dos Planos Ativos //
	oStructRHN := FWFormStruct(1, "RHN")
	oStructRHN:SetProperty( "RHN_CODIGO", MODEL_FIELD_WHEN, { |oModel| Gpea002_When(oModel, 1) } )
	oStructRHN:SetProperty( "RHN_NOME", MODEL_FIELD_WHEN, { |oModel| Gpea002_When(oModel, 2) } )
	oStructRHN:SetProperty( "RHN_PDDAGR", MODEL_FIELD_WHEN, { |oModel| Gpea002_When(oModel, 3) } )
	
	oModel:AddGrid("GPEA002_MRHN", "GPEA002_MSRA", oStructRHN,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVal*/, { |x,y| LoadInforRHN(x, y)} ) //x=Grid, y=Copia
	
	oModel:GetModel( "GPEA002_MRHN" ):SetDescription( OemToAnsi(STR0001) ) //"Historico de Alteracoes Planos Ativos"

	oModel:SetRelation( "GPEA002_MRHN", { { "RHN_FILIAL", 'xFilial( "SRA" )' }, { "RHN_MAT", 'SRA->RA_MAT' }}, RHN->( IndexKey( 1 ) ) )
	
Return( oModel )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � ViewDef  		�Autor�  Mauricio Takakura� Data �27/09/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Regras de Interface com o Usuario                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA002                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function ViewDef()
	Local oView 
	Local oModel
	Local oStructSRA
	Local oStructRHN

	// Vincular o View ao Model //
	oModel := FWLoadModel("GPEA002")

	// Criacao da Interface //
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Criacao do Cabecalho - SRA (Funcionario) //
	oStructSRA := FWFormStruct(2, "SRA", { |cCampo| Gpa002SRAStru(cCampo) })
	oStructSRA:SetNoFolder()
	oView:AddField("GPEA002_VSRA", oStructSRA, "GPEA002_MSRA" )
	
	// Criacao do Cabecalho - RHN (Historico Alteracoes dos Planos Ativos) //
	oStructRHN 	:= FWFormStruct(2, "RHN")
	oStructRHN:RemoveField( "RHN_MAT" )

	oView:AddGrid("GPEA002_VRHN", oStructRHN, "GPEA002_MRHN" )

	// Desenho da Tela //
	oView:CreateHorizontalBox("SRA_HEAD", 12)
	oView:CreateHorizontalBox("RHN_HIST", 88)
	
	oView:SetOwnerView( "GPEA002_VSRA", "SRA_HEAD" )
	oView:SetOwnerView( "GPEA002_VRHN", "RHN_HIST" )
		
Return oView

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � Gpa002SRAStru	�Autor�  Mauricio Takakura� Data �27/09/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Selecionar os campos para a estrutura do SRA                �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA002                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function Gpa002SRAStru( cCampo )
	Local lRet := .F.
	
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME*RA_ADMISSA' 
		lRet := .T.
	EndIf
	
Return lRet

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � LoadInforRHN	�Autor�  Mauricio Takakura� Data �11/10/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Realizar a leitura dos dados da tabela de Historico         �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA002                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function LoadInforRHN(oGrid, lCopia)
	Local aRet			:= {}
	
	Local cFunc			:= FunName()
	
	Local nOperation 	:= oGrid:GetOperation()
    
	If !(cFunc == "GPEA001") .Or. (cFunc == "GPEA001" .and. nOperation <> 3 )
		aRet := FormLoadGrid( oGrid, lCopia )
	EndIf

Return( aRet )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � Gpea002_When	�Autor�  Mauricio Takakura� Data �27/09/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Habilitar pelo When Campos para edicao                      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA002                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Static Function Gpea002_When(oModel, nCampo)
	Local cOrigem	:= ""
	
	Local lRet 		:= .T.
	
	cOrigem			:= oModel:GetValue( "RHN_ORIGEM" )
	
	If nCampo <> 3 .and. cOrigem == "1"
		lRet := .F. 
	ElseIf nCampo == 2 .and. cOrigem <> "3"
		lRet := .F. 
	ElseIf nCampo == 3 .and. cOrigem <> "1"
		lRet := .F. 
	ElseIf Empty(cOrigem)
		lRet := .F. 
	EndIf
	
Return( lRet )


/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � GPA002_ORIG	�Autor�  Mauricio Takakura� Data �23/10/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validacao da Origem da Informacao                           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA003                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function GPA002_ORIG()
	Local aArea		:= GetArea()
	
	Local lRet		:= .T.
	
	Local oModel 		:= FWModelActive()
	Local oStruct		:= oModel:GetModel( "GPEA002_MRHN" )

	oStruct:LoadValue("RHN_CODIGO", Space(GetSx3Cache("RHN_CODIGO", "X3_TAMANHO"))  )

	RestArea( aArea )
	
Return( lRet )
