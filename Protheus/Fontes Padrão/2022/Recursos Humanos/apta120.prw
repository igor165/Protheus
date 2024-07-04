#INCLUDE "PROTHEUS.CH"
#INCLUDE "APTA120.CH"

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Programa  �APTA120   �Autor  �Tania Bronzeri      � Data �  10/05/2004         ���
���          �          �       �Marinaldo de Jesus  �      �                     ���
���������������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Registros de Classe                                     ���
���          �                                                                    ���
���������������������������������������������������������������������������������͹��
���Uso       �Registros de Classe associados ao cadastro de Pessoas               ���
���������������������������������������������������������������������������������ͼ��
���Programador � Data     � BOPS         �  Motivo da Alteracao                   ���
���������������������������������������������������������������������������������Ĵ��
���Cecilia Car.�04/08/2014�TQEQ39        �Incluido o fonte da 11 para a 12 e efe- ���
���            �          �              �tuda a limpeza.                         ���
���Flavio Corr.�04/08/2014�TQLHZP        �Ajuste tamanho Enchoice				  ���
���Willian U.  �15/08/2017�DRHPONTP-1304 �Ajuste na fun��o Apta120Grava() para    ���
���            �          �              �verificar o compartilhamento das tabelas���
���            �          �              �REU e RD0.                              ���  
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Function APTA120( cAlias , nReg , nOpc , lExecAuto , lMaximized , cSigla )
Local aArea 	:= GetArea()
Local aAreaRd0	:= RD0->( GetArea() )
Local aAreaReu	:= REU->( GetArea() )
Local lExistOpc	:= ( ValType( nOpc ) == "N" )

Local bBlock
Local nPos                                                         
Private aMemos	:= { { "REU_C_ESP" , "REU_ESPEC" , "RE6" } }	//Variavel para tratamento dos memos

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	�Redefine o Alias                                              �
	����������������������������������������������������������������/*/
	cAlias	:= "RD0"

	/*/
	��������������������������������������������������������������Ŀ
	�Nao Executa se o RD0 estiver Vazio                            �
	����������������������������������������������������������������/*/
	IF !ChkVazio( cAlias )
		Break
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Define Array contendo as Rotinas a executar do programa      �
	� ----------- Elementos contidos por dimensao ------------     �
	� 1. Nome a aparecer no cabecalho                              �
	� 2. Nome da Rotina associada                                  �
	� 3. Usado pela rotina                                         �
	� 4. Tipo de Transa��o a ser efetuada                          �
	�    1 - Pesquisa e Posiciona em um Banco de Dados             �
	�    2 - Simplesmente Mostra os Campos                         �
	�    3 - Inclui registros no Bancos de Dados                   �
	�    4 - Altera o registro corrente                            �
	�    5 - Remove o registro corrente do Banco de Dados          �
	�    6 - Copiar                                                �
	����������������������������������������������������������������/*/
	
    Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

	Private cCadastro   := OemToAnsi( STR0007 ) //"Registros de Classe"

	IF ( lExistOpc )

		/*/
		��������������������������������������������������������������Ŀ
		�Garante o Posicinamento do Recno                              �
		����������������������������������������������������������������/*/
		DEFAULT nReg	:= ( cAlias )->( Recno() )
		IF !Empty( nReg )
			( cAlias )->( MsGoto( nReg ) )
		EndIF

		DEFAULT lExecAuto := .F.
		IF ( lExecAuto )

			nPos := aScan( aRotina , { |x| x[4] == nOpc } )
			IF ( nPos == 0 )
				Break
			EndIF
			bBlock := &( "{ |a,b,c,d| " + aRotina[ nPos , 2 ] + "(a,b,c,d) }" )
			Eval( bBlock , cAlias , nReg , nPos )
		
		Else
		
			DEFAULT lMaximized := .F.
			Apta120Mnt( cAlias , nReg , nOpc , .T. ,lMaximized , cSigla )
		
		EndIF

	Else
		
		/*/
		������������������������������������������������������������������������Ŀ
		� Chama a Funcao de Montagem do Browse                                   �
		��������������������������������������������������������������������������/*/
		mBrowse( 6 , 1 , 22 , 75 , cAlias )

	EndIF
	
End Sequence

/*/
��������������������������������������������������������������Ŀ
�Coloca o Ponteiro do Mouse em Estado de Espera			   	   �
����������������������������������������������������������������/*/
CursorWait()
		
/*/
������������������������������������������������������������������������Ŀ
� Restaura os Dados de Entrada 											 �
��������������������������������������������������������������������������/*/
RestArea( aAreaReu )
RestArea( aAreaRd0 )
RestArea( aArea	   )

/*/
��������������������������������������������������������������Ŀ
�Restaura o Cursor do Mouse                				   	   �
����������������������������������������������������������������/*/
CursorArrow()
	
Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apta120Vis� Autor �Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Registros de Classe ( Visualizar )				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico 	                                                �
�������������������������������������������������������������������������/*/
Function Apta120Vis( cAlias , nReg  )
Return( APTA120( cAlias , nReg , 2 ,, .F. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apta120Inc� Autor �Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Registros de Classe ( Incluir )					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico 	                                                �
�������������������������������������������������������������������������/*/
Function Apta120Inc( cAlias , nReg  )  

nReg	:=	RD0->( Recno() )

Return( APTA120( cAlias , nReg , 3 ,, .F. ) )

/*/
��������������������������������������������������������������������������Ŀ
�Fun��o    �Apta120IncAdv� Autor �Tania Bronzeri         � Data �10/09/2004�
��������������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Registros de Classe Advogado ( Incluir )   		   �
��������������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          				               �
��������������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>                                      �
��������������������������������������������������������������������������Ĵ
�Uso       �Cadastramento dos Advogados do Processo                        �
����������������������������������������������������������������������������/*/
Function Apta120AdvInc ( cAlias , nReg  )
Local cPessoa 	:= ""
Local cSigla	:= ""
Local nRegis	:=	0
                              
cPessoa := GdFieldGet("RE4_CODADV")           
cSigla	:= FDESC("RE8","ADV","RE8_SIGLA")

dbSelectArea("RD0")
dbSeek(xFilial("RD0")+cPessoa)
nRegis	:=	RD0->(Recno())
Return( APTA120( cAlias , nRegis , 3 ,, .F. , cSigla ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apta120Alt� Autor �Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Visoes ( Alterar )								�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico 	                                                �
�������������������������������������������������������������������������/*/
Function Apta120Alt( cAlias , nReg  )
Return( APTA120( cAlias , nReg , 4 ,, .T. ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apta120Del� Autor �Marinaldo de Jesus     � Data �27/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Registros de Classe ( Excluir )					�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico 	                                                �
�������������������������������������������������������������������������/*/
Function Apta120Del( cAlias , nReg  )
Return( APTA120( cAlias , nReg , 5 ) )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �ReuVisual � Autor �Marinaldo de Jesus     � Data �12/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Itens de Registros de Classe ( Visualizar )		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico 	                                                �
�������������������������������������������������������������������������/*/
Function ReuVisual( cAlias , nReg  )

SetMemoFields( cAlias , GetMemoDb( cAlias ) )
aRotSetOpc( cAlias , @nReg , 2 )

Return( AxVisual( cAlias, nReg , 2 ) )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apta120Mnt� Autor �Marinaldo de Jesus     � Data �18/06/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Registros de Classe (Manutencao)				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Apta120Mnt(cAlias,nReg,nOpc,lDlgPadSiga,cSigla) 			�
�����������������������������������������������������������������������Ĵ
�Parametros�cAlias 		= Alias do arquivo                              �
�          �nReg   		= Numero do registro                            �
�          �nOpc   		= Numero da opcao selecionada                   �
�          �lDlgPadSiga = Numero da opcao selecionada                   �
�          �lMaximized	= Informa se a tela devera ser maximizada       �
�          �cSigla		= Sigla do Registro de Classe                   �
�����������������������������������������������������������������������Ĵ
�Uso       �APTA120()	                                                �
�������������������������������������������������������������������������
�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.   			�
�����������������������������������������������������������������������ĳ
�Programador � Data   � FNC  �  Motivo da Alteracao                     �
�����������������������������������������������������������������������Ĵ
� Gustavo M. |22/09/11�24561/� Alteracao do Parametro lCposUser para   	� 
�      	 	 � 		  �2011  � carregar os Campos de Usuario		    �
�������������������������������������������������������������������������/*/
Function Apta120Mnt( cAlias , nReg , nOpc , lDlgPadSiga , lMaximized , cSigla )

Local aArea			:= GetArea()
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aRd0Header	:= {}
Local aRd0Cols		:= {}
Local aSvRd0Cols	:= {}
Local aRd0Fields	:= {}
Local aRd0Altera	:= {}
Local aRd0NaoAlt	:= {}
Local aRd0VirtEn	:= {}
Local aRd0NotFields	:= {}
Local aRd0Keys		:= {}
Local aRd0VisuEn	:= {}
Local aReuGdAltera  := {}
Local aReuGdNaoAlt	:= {}
Local aReuRecnos	:= {}
Local aReuKeys		:= {}
Local aReuNotFields	:= {}
Local aReuVirtGd	:= {}
Local aReuVisuGd	:= {}
Local aReuHeader	:= {}
Local aReuCols		:= {}
Local aSvReuCols	:= {}
Local aReuQuery		:= {}
Local aReuMemoGd	:= {}
Local aLog			:= {}
Local aLogTitle		:= {}
Local aLogGer		:= {}
Local aLogGerTitle	:= {}
Local aButtons		:= {}
Local aFreeLocks	:= {}
Local aRe6Recnos	:= {}
Local aRe6Keys		:= {}
Local bReuGdDelOk	:= { |lDelOk| CursorWait() , lDelOk := ReuGdDelOk( "REU" , NIL , nOpc , cCodRD0 ) , CursorArrow() , lDelOk }
Local bReuTreeDelOk	:= { || .T. }
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local bDialogInit	:= { || NIL }
Local bGdReuSeek	:= { || NIL }
Local bGetRd0		:= { || NIL } 
Local bGetReu		:= { || NIL }
Local cRD0KeySeek	:= ""
Local cFilRD0		:= ""
Local cCodRD0		:= ""
Local cMsgYesNo		:= ""
Local cTitLog		:= ""
Local lLocks		:= .F.
Local lExecLock		:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
Local lExcGeraLog	:= .F.
Local nOpcAlt		:= 0
Local nRd0Usado		:= 0
Local nReuUsado		:= 0
Local nLoop			:= 0
Local nLoops		:= 0
Local nOpcNewGd		:= IF( ( ( nOpc == 2 ) .or. ( nOpc == 4 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE	)
Local nReuItemOrd	:= RetOrdem( "REU" , "REU_FILIAL+REU_CODPES+REU_SIGLA" )
Local nReuPosItem	:= 0
Local nReuMaxLocks	:= 10
Local oDlg			:= NIL
Local oEnRd0		:= NIL
Local oGdReu		:= NIL

Private aGets
Private aTela
                                                                    
DEFAULT lMaximized := .F.
Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	� Coloca o ponteiro do Cursor do Mouse em Estado de Espera     �
	����������������������������������������������������������������/*/
	CursorWait()

		/*/
		��������������������������������������������������������������Ŀ
		�Checa a Opcao Selecionada									   �
		����������������������������������������������������������������/*/
		aRotSetOpc( cAlias , NIL , 2 )

		/*/
		��������������������������������������������������������������Ŀ
		� Monta os Dados para a Enchoice							   �
		����������������������������������������������������������������/*/
		aRd0NotFields	:= { "RD0_CODIGO" , "RD0_NOME" , "RD0_IDENT" , "RD0_IDESCR"}
		bGetRd0			:= { |lExclu|	IF( lExecLock , lExclu := .T. , NIL ),;
											aRd0Cols := RD0->(;
																GdMontaCols(	@aRd0Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																				@nRd0Usado		,;	//02 -> Numero de Campos em Uso
																				@aRd0VirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																				@aRd0VisuEn		,;	//04 -> [@]Array com os Campos Visuais
																				"RD0"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																				aRd0NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																				NIL				,;	//07 -> [@]Array unidimensional contendo os Recnos
																				"RD0"		   	,;	//08 -> Alias do Arquivo Pai
																				NIL				,;	//09 -> Chave para o Posicionamento no Alias Filho
																				NIL				,;	//10 -> Bloco para condicao de Loop While
																				NIL				,;	//11 -> Bloco para Skip no Loop While
																				NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																				NIL				,;	//13 -> Se cria variaveis Publicas
																				NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
																				NIL				,;	//15 -> Lado para o inicializador padrao
																				NIL				,;	//16 -> Opcional, Carregar Todos os Campos
																				NIL				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
																				NIL				,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
																				NIL				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																				NIL				,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																				NIL				,;	//21 -> Carregar Coluna Fantasma
																				.T.				,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																				NIL				,;	//23 -> Verifica se Deve verificar se o campo eh usado
																				NIL				,;	//24 -> Verifica se Deve verificar o nivel do usuario
																				NIL				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																				@aRd0Keys		,;	//26 -> [@]Array que contera as chaves conforme recnos
																				NIL				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
																				@lExclu			,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros 
																				NIL				,;  //29 -> Numero maximo de Locks a ser efetuado
																				NIL				,;  //30 -> Utiliza Numeracao na GhostCol
																				.T.				;   //31 -> Carrega os Campos de Usuario
																		    );
															  ),;
											IF( lExecLock , lExclu , .T. );
		  					} 
		/*/
		��������������������������������������������������������������Ŀ
		�Lock do Registro do RD0									   �
		����������������������������������������������������������������/*/
		IF !( lLocks := WhileNoLock( "RDU_RD0" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRd0 ) )
			Break
		EndIF
		CursorWait()
		aSvRd0Cols		:= aClone( aRd0Cols )
		cFilRD0			:= RD0->RD0_FILIAL
		cCodRD0			:= RD0->RD0_CODIGO
		cRD0KeySeek		:= ( cFilRD0 + cCodRD0 )
	
		/*/
		��������������������������������������������������������������Ŀ
		� Cria as Variaveis de Memoria e Carrega os Dados Conforme o ar�
		� quivo														   �
		����������������������������������������������������������������/*/
		For nLoop := 1 To nRd0Usado
			aAdd( aRd0Fields , aRd0Header[ nLoop , 02 ] )
			SetMemVar( aRd0Header[ nLoop , 02 ] , aRd0Cols[ 01 , nLoop ] , .T. )
		Next nLoop

		/*/
		��������������������������������������������������������������Ŀ
		� Monta os Dados para a GetDados							   �
		����������������������������������������������������������������/*/
		aAdd( aReuNotFields , "REU_FILIAL"  )
		aAdd( aReuNotFields , "REU_CODPES"	)
		aReuQuery		:= Array( 05 )
		aReuQuery[01]	:= "REU_FILIAL='"+cFilRD0+"'"
		aReuQuery[02]	:= " AND "
		aReuQuery[03]	:= "REU_CODPES='"+cCodRD0+"'"
		aReuQuery[04]	:= " AND "
		aReuQuery[05]	:= "D_E_L_E_T_=' ' "
		/*/
		��������������������������������������������������������������Ŀ
		� Quando For Inclusao Posiciona o REU No Final do Arquivo	   �
		����������������������������������������������������������������/*/
		IF ( nOpc == 3  ) //Inclusao
			/*/
			��������������������������������������������������������������Ŀ
			� Garante que na Inclusao o Ponteiro do REU estara em Eof()    � 
			����������������������������������������������������������������/*/
			PutFileInEof( "REU" )
		EndIF
		REU->( dbSetOrder( nReuItemOrd ) )
		bGetReu	:= { |lLock,lExclu| IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aReuKeys := NIL ),;
							 		aReuCols := REU->(;
														GdMontaCols(	@aReuHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																		@nReuUsado		,;	//02 -> Numero de Campos em Uso
																		@aReuVirtGd		,;	//03 -> [@]Array com os Campos Virtuais
																		@aReuVisuGd		,;	//04 -> [@]Array com os Campos Visuais
																		"REU"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																		aReuNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																		@aReuRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																		"RD0"		   	,;	//08 -> Alias do Arquivo Pai
																		cRD0KeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
																		NIL				,;	//10 -> Bloco para condicao de Loop While
																		NIL				,;	//11 -> Bloco para Skip no Loop While
																		NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																		NIL				,;	//13 -> Se cria variaveis Publicas
																		NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
																		NIL				,;	//15 -> Lado para o inicializador padrao
																		NIL				,;	//16 -> Opcional, Carregar Todos os Campos
																		NIL				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
																		aReuQuery		,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
																		.F.				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																		.F.				,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																		.F.				,;	//21 -> Carregar Coluna Fantasma
																		NIL				,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																		NIL				,;	//23 -> Verifica se Deve verificar se o campo eh usado
																		NIL				,;	//24 -> Verifica se Deve verificar o nivel do usuario
																		NIL				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																		@aReuKeys  		,;	//26 -> [@]Array que contera as chaves conforme recnos
																		@lLock			,;	//27 -> [@]Se devera efetuar o Lock dos Registros
																		@lExclu			,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		nReuMaxLocks	 ;	//29 -> Numero maximo de Locks a ser efetuado
																    );
													  ),;
									IF( lExecLock , ( lLock .and. lExclu ) , .T. ) ; 
					}
		/*/
		��������������������������������������������������������������Ŀ
		�Lock do Registro do REU									   �
		����������������������������������������������������������������/*/
		IF !( lLocks := WhileNoLock( "REU" , NIL , NIL , 1 , 1 , .T. , nReuMaxLocks , 5 , bGetReu ) )
			Break
		EndIF
		CursorWait()
		aSvReuCols	:= aClone( aReuCols )
  
		/*/
		��������������������������������������������������������������Ŀ
		� Define os Campos Memos                     				   �
		����������������������������������������������������������������/*/
		aAdd( aReuMemoGd , { "REU_ESPEC" , "REU_C_ESP"   } )

		/*/
		��������������������������������������������������������������Ŀ
		� Carrega os Campos Editaveis para a GetDados				   �
		����������������������������������������������������������������/*/
		For nLoop := 1	To nReuUsado
			SetMemVar( aReuHeader[ nLoop , 02 ] , GetValType( aReuHeader[ nLoop , 08 ] , aReuHeader[ nLoop , 04 ] ) , .T. )
			IF (;
					(;
						( aScan( aReuVirtGd		, aReuHeader[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aReuVisuGd		, aReuHeader[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aReuNotFields	, aReuHeader[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aReuGdNaoAlt	, aReuHeader[ nLoop , 02 ] ) == 0 )		;
			   		) .or. ;
			   		( aScan( aReuMemoGd	, { |x| aReuHeader[ nLoop , 02 ] == x[1] } ) > 0 )	;
			  	)
				aAdd( aReuGdAltera , aReuHeader[ nLoop , 02 ] )
			EndIF			   
		Next nLoop

		/*/
		��������������������������������������������������������������Ŀ
		�Carrega os Recnos e as Chaves correspondentes dos campos Memos�
		����������������������������������������������������������������/*/
		IF ( nOpc <> 2 )
			IF !( lLocks := AptMemRec( "REU" , aReuRecnos , aReuMemoGd , @aRe6Recnos , @aRe6Keys , .T. ) )
				Break
			EndIF
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Monta as Dimensoes dos Objetos         					   �
		����������������������������������������������������������������/*/
		DEFAULT lDlgPadSiga	:= .F.
		aAdvSize		:= MsAdvSize( NIL , lDlgPadSiga )
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
		aAdd( aObjCoords , { 000 , 050 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
		/*/
		��������������������������������������������������������������Ŀ
		� Define o Botao de Pesquisa na GetDados					   �
		����������������������������������������������������������������/*/
		bGdReuSeek := { ||	GdReuSeek( oGdReu ),;
							SetKey( VK_F4 , bGdReuSeek );
				   }
		aAdd(;
				aButtons	,;
								{;
									"pesquisa" 							,;
		   							bGdReuSeek							,;
		       	   					OemToAnsi( STR0001 + "...<F4>"  )	,;	//"Pesquisar"
		       	   					OemToAnsi( STR0001 )				 ;	//"Pesquisar"
		           				};
		     )
	
		/*/
		��������������������������������������������������������������Ŀ
		� Define o Bloco para a Tecla <CTRL-O> 						   �
		����������������������������������������������������������������/*/
		bSet15		:= { || IF(; 
									( ( nOpc == 3 ) )		 .and.;	//Atualizacao
									IF(;
										!fCompArray( aSvReuCols , oGdReu:aCols ),;
										oGdReu:TudoOk(),;									//Valida as Informacoes da GetDados
										.T.;
									  ),;		
									(;
										nOpcAlt := 1 ,;
										RestKeys( aSvKeys , .T. ),;
										oDlg:End();
								 	),;
								 	IF(; 
								 		( ( nOpc == 3 ) ) ,;			//Atualizacao
								 			(;
								 				nOpcAlt := 0 ,;
								 				.F.;
								 			 ),;	
										(;
											nOpcAlt := IF( nOpc == 2 , 0 , 1 ) ,;			//Visualizacao ou Exclusao
											RestKeys( aSvKeys , .T. ),;
											oDlg:End();
								 		);
								 	  );
							   );
						 }
		/*/
		��������������������������������������������������������������Ŀ
		� Define o Bloco para a Teclas <CTRL-X>     	   			   �
		����������������������������������������������������������������/*/
		bSet24		:= { || ( nOpcAlt := 0 , RestKeys( aSvKeys , .T. ) , oDlg:End() ) }
	
		/*/
		��������������������������������������������������������������Ŀ
		� Define o Bloco para o Init do Dialog						   �
		����������������������������������������������������������������/*/
		bDialogInit := { ||;
								EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ),;
								SetKey( VK_F4 , bGdReuSeek  ),;
						}

	/*/
	��������������������������������������������������������������Ŀ
	� Restaura o Ponteiro do Cursor do Mouse                  	   �
	����������������������������������������������������������������/*/
	CursorArrow()

	/*/
	��������������������������������������������������������������Ŀ
	� Monta o Dialogo Principal para a Manutencao das Formulas	   �
	����������������������������������������������������������������/*/
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0007 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL

		/*/
		��������������������������������������������������������������Ŀ
		� Monta o Objeto Enchoice para o RD0                      	   �
		����������������������������������������������������������������/*/
		oEnRd0	:= MsmGet():New(	cAlias		,;
									nReg		,;
									2			,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRd0Fields	,;
									aObjSize[1] ,;
									aRd0Altera	,;
									NIL			,;
									NIL			,;
									NIL			,;
									oDlg		,;
									NIL			,;
									.T.			 ;
								)
		/*/
		��������������������������������������������������������������Ŀ
		� Monta o Objeto GetDados para o REU						   �
		����������������������������������������������������������������/*/
		oGdReu	:= MsNewGetDados():New(	aObjSize[2,1]								,;
										aObjSize[2,2]								,;
										aObjSize[2,3]								,;
										aObjSize[2,4]								,;
										nOpcNewGd									,;
										"ReuGdLinOk"								,;
										"ReuGdTudOk"								,;
										""											,;
										aReuGdAltera								,;
										0											,;
										999999										,;
										NIL											,;
										NIL											,;
										bReuGdDelOk									,;
										oDlg										,;
										aReuHeader									,;
										aReuCols		 							 ;
									  )

	ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED


	/*/
	��������������������������������������������������������������Ŀ
	� Coloca o Ponteiro do Mouse em Estado de Espera			   �
	����������������������������������������������������������������/*/
	CursorWait()

	/*/
	��������������������������������������������������������������Ŀ
	�Quando Confirmada a Opcao e Nao for Visualizacao Grava ou   Ex�
	�clui as Informacoes do RD0 e REU							   �
	����������������������������������������������������������������/*/
	IF( nOpcAlt == 1 )
		/*/
		��������������������������������������������������������������Ŀ
		� Apenas se nao For Visualizacao              				   �
		����������������������������������������������������������������/*/
 		IF ( nOpc != 2 )
			/*/
			����������������������������������������������������������Ŀ
			� Gravando/Incluido ou Excluindo Informacoes do REU        �
			������������������������������������������������������������/*/
			aReuCols := oGdReu:aCols //Redireciona o Ponteiro do aReuCols
			MsAguarde(;
						{ ||;
								Apta120Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 					nReg		,;	//Numero do Registro do Arquivo Pai ( RD0 )
							 					aReuHeader	,;	//Campos do Arquivo Filho ( REU )
							 					aReuCols	,;	//Itens Atual do Arquivo Filho ( REU )
							 					aSvReuCols	,;	//Itens Anterior do Arquivo Filho ( REU )
							 					aReuVirtGd	,;	//Campos Virtuais do Arquivo Filho ( REU )
							 					aReuRecnos	,;	//Recnos do Arquivo Filho ( REU )
							 					aReuMemoGd	 ;	//Campos Memo na GetDados ( REU )
							  				);
						};
					)
		EndIF
	EndIF

End Sequence

/*/
��������������������������������������������������������������Ŀ
� Coloca o Ponteiro do Mouse em Estado de Espera			   �
����������������������������������������������������������������/*/
CursorWait()

/*/
��������������������������������������������������������������Ŀ
�Libera os Locks             								   �
����������������������������������������������������������������/*/
aAdd( aFreeLocks , { "RDU_RD0"	, NIL			, aRd0Keys } )
aAdd( aFreeLocks , { "REU" 		, aReuRecnos	, aReuKeys } )
ApdFreeLocks( aFreeLocks )

/*/
��������������������������������������������������������������Ŀ
�Restaura os Dados de Entrada								   �
����������������������������������������������������������������/*/
RestArea( aArea )

/*/
��������������������������������������������������������������Ŀ
� Restaura as Teclas de Atalho                				   �
����������������������������������������������������������������/*/
RestKeys( aSvKeys , .T. )

/*/
��������������������������������������������������������������Ŀ
� Restaura o Ponteiro do Cursor do Mouse                  	   �
����������������������������������������������������������������/*/
CursorArrow()

Return( nOpcAlt )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �ReuGdLinOk	�Autor�Marinaldo de Jesus     � Data �18/06/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �ReuGdLinOk( oBrowse )									    �
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA120()	                                                �
�������������������������������������������������������������������������/*/
Function ReuGdLinOk( oBrowse )

Local aCposKey	:= {}
Local lLinOk	:= .T.

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
CursorWait()

	/*/
	��������������������������������������������������������������Ŀ
	� Evitar que os Inicializadores padroes sejam carregados indevi�
	� damente													   �
	����������������������������������������������������������������/*/
	PutFileInEof( "REU" )
	
	Begin Sequence
	
		/*/
		��������������������������������������������������������������Ŀ
		� Se a Linha da GetDados Nao Estiver Deletada				   �
		����������������������������������������������������������������/*/
		IF !( GdDeleted() )
		
			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Itens Duplicados na GetDados						   �
			����������������������������������������������������������������/*/
			aCposKey := { "REU_SIGLA" }
			IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
				Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se o Campos Estao Devidamente Preenchidos		   �
			����������������������������������������������������������������/*/
			aCposKey := { "REU_SIGLA" , "REU_NUMREG" }
			IF !( lLinOk := GdNoEmpty( aCposKey ) )
		    	Break
			EndIF
	
		EndIF
		
	End Sequence
	
	/*/
	��������������������������������������������������������������Ŀ
	�Se Houver Alguma Inconsistencia na GetDados, Seta-lhe o Foco  �
	����������������������������������������������������������������/*/
	IF !( lLinOk )
		oBrowse:SetFocus()
	EndIF

/*/
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
CursorArrow()

Return( lLinOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �ReuGdTudOk	�Autor�Marinaldo de Jesus     � Data �18/06/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �ReuGdTudOk( oBrowse )									   	�
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA120()	                                                �
�������������������������������������������������������������������������/*/
Function ReuGdTudOk( oBrowse )

Local lTudoOk := .T.

Local nLoop
Local nLoops

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
CursorWait()

	Begin Sequence
	
	    /*/
		��������������������������������������������������������������Ŀ
		� Percorre Todas as Linhas para verificar se Esta Tudo OK      �
		����������������������������������������������������������������/*/
		nLoops	:= Len( aCols )
		For nLoop := 1 To nLoops
			n := nLoop
			IF !( lTudoOk := ReuGdLinOk( oBrowse ) )
				oBrowse:Refresh()
				Break
			EndIF
		Next n
	
	End Sequence

/*/
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
CursorArrow()

Return( lTudoOk  )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �ReuGdDelOk  �Autor�Marinaldo de Jesus     � Data �18/07/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar a Delecao na GetDados                               �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>								    �
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>								    �
�����������������������������������������������������������������������Ĵ
�Uso       �APTA120()	                                                �
�������������������������������������������������������������������������/*/
Static Function ReuGdDelOk( cAlias , nRecno , nOpc , cCodigo )
         
Local lDelOk 		:= .T.
Local lStatusDel	:= .F.
Local nReuItemOrd	:= 0

Static lFirstDelOk
Static lLstDelOk

DEFAULT lFirstDelOk	:= .T.
DEFAULT lLstDelOk	:= .T.

Begin Sequence

	//Quando for Visualizacao ou Exclusao Abandona
	IF (;
			( nOpc == 2 ) .or. ;	//Visualizacao
			( nOpc == 4 );			//Exclusao
		)
		Break
	EndIF

	//Apenas se for a primeira vez
	IF !( lFirstDelOk )
		lFirstDelOk	:= .T.
		lDelOk 		:= lLstDelOk
		lLstDelOk	:= .T.
		Break
	EndIF

	lStatusDel	:= !( GdDeleted() ) //Inverte o Estado
	
	IF ( lStatusDel )	//Deletar
    	IF !( nOpc == 3  )	//Quando nao for Atualizacao
			nReuItemOrd	:= RetOrdem( "REU" , "REU_FILIAL+REU_CODPES+REU_SIGLA" )
    		REU->( dbSetOrder( nReuItemOrd ) )
    		IF !( lDelOk := ApdChkDel( cAlias , nRecno , nOpc , ( cCodigo + GdFieldGet( "REU_SIGLA" ) ) , .F. , NIL , NIL , NIL , NIL , .T. ) )
				CursorArrow()
				//"A chave a ser excluida est� sendo utilizada."
				//"At� que as refer�ncias a ela sejam eliminadas a mesma n�o pode ser excluida."
				MsgInfo( OemToAnsi( STR0023 + CRLF + STR0024 ) , cCadastro )
    			lLstDelOk := lDelOk
    			//Ja Passou pela funcao
				lFirstDelOk := .F.
    			Break
    		EndIF
    	EndIF
	Else				//Restaurar
   		lLstDelOk := lDelOk
   		//Ja Passou pela funcao
		lFirstDelOk := .F.
   		Break
	EndIF

	//Ja Passou pela funcao
	lFirstDelOk := .F.


End Sequence
	
Return( lDelOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apta120Grava �Autor�Marinaldo de Jesus    � Data �21/07/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA120()	                                                �
�������������������������������������������������������������������������/*/
Static Function Apta120Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( RD0 )
							 	aReuHeader	,;	//Campos do Arquivo Filho ( REU )
							 	aReuCols	,;	//Itens Atual do Arquivo Filho ( REU )
							 	aSvReuCols	,;	//Itens Anterior do Arquivo Filho ( REU )
							 	aReuVirtGd	,;	//Campos Virtuais do Arquivo Filho ( REU )
							 	aReuRecnos	,;	//Recnos do Arquivo Filho ( REU )
							 	aReuMemoGd	 ;	//Campos Memo na GetDados ( REU )
							  )

/*/
�������������������������������������������������������������Ŀ
� Variaveis de Inicializacao Obrigatoria					  �
���������������������������������������������������������������/*/
Local aMestre	:= GdPutIStrMestre( 01 )
Local aItens	:= {}
Local cOpcao	:= IF( ( nOpc == 4 ) , "DELETE" , IF( ( ( nOpc == 3 )  ) , "PUT" , NIL ) )

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
CursorWait()

	/*/
	��������������������������������������������������������������Ŀ
	� Carrega os Itens Apenas se Houveram Alteracoes ou na Exclusao�
	����������������������������������������������������������������/*/
	IF ( ( nOpc == 4 ) .or. !( fCompArray( aReuCols , aSvReuCols ) ) )

	//Verifica o modo de acesso das tabelas REU e RD0
	cREU := FWModeAccess( "REU", 1) + FWModeAccess( "REU", 2) + FWModeAccess( "REU", 3)
	cRD0 := FWModeAccess( "RD0", 1) + FWModeAccess( "RD0", 2) + FWModeAccess( "RD0", 3)
	
	If cREU > cRD0
		//"O Modo de Acesso do relacionamento para a tabela de Registro de Classe deve possuir um compartilhamento igual ou maior � tabela de Pessoas/Participantes"
		//"Altere o modo de acesso atraves do Configurador. Arquivos REU e RD0."
		MsgInfo( oEmToAnsi( STR0027 ) + CRLF + CRLF + oEmToAnsi( STR0028 ) )
		Return (.F.)
	EndIf

		aItens := GdPutIStrItens( 01 )
		
		aItens[ 01 , 01 ] := "REU"
		aItens[ 01 , 02 ] := {;
								{ "FILIAL" , xFilial( "REU" , xFilial( "RD0" ) ) },;
								{ "CODPES" , GetMemVar( "RD0_CODIGO" ) };
							 }
		aItens[ 01 , 03 ] := aClone( aReuHeader )
		aItens[ 01 , 04 ] := aClone( aReuCols   )
		aItens[ 01 , 05 ] := aClone( aReuVirtGd )
		aItens[ 01 , 06 ] := aClone( aReuRecnos )
		aItens[ 01 , 07 ] := aClone( aReuMemoGd )
		aItens[ 01 , 08 ] := NIL
		aItens[ 01 , 10 ] := "RE6"

	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ou�
	� se foi Selecionada a Exclusao								   �
	����������������������������������������������������������������/*/
	aMestre[ 01 , 01 ]	:= "RD0"
	aMestre[ 01 , 02 ]	:= nReg
	aMestre[ 01 , 03 ]	:= .F.
	aMestre[ 01 , 04 ]	:= NIL
	aMestre[ 01 , 05 ]	:= NIL
	aMestre[ 01 , 06 ]	:= {}
	aMestre[ 01 , 07 ]	:= aClone( aItens )
	
	/*/
	��������������������������������������������������������������Ŀ
	� Grava as Informacoes                        				   �
	����������������������������������������������������������������/*/
	GdPutInfoData( aMestre , cOpcao )

/*/
������������������������������������������





��������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
CursorArrow()

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GdReuSeek	 �Autor�Marinaldo de Jesus    � Data �08/01/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Efetuar Pesquisa na GetDados                               	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA120                                                		�
�������������������������������������������������������������������������/*/
Static Function GdReuSeek( oGdReu )

Local aSvKeys 		:= GetKeys()
Local cProcName3	:= Upper( AllTrim( ProcName( 3 ) ) )
Local cProcName5	:= Upper( AllTrim( ProcName( 5 ) ) )

Begin Sequence

	IF !( "APTA120MNT" $ ( cProcName3 + cProcName5 ) )
		Break
	EndIF

	GdSeek( oGdReu , OemToAnsi( STR0001 ) )	//"Pesquisar"
	
End Sequence

RestKeys( aSvKeys , .T. )

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �AptMemRec	 �Autor�Marinaldo de Jesus    � Data �10/04/2003�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem os Recnos e as Chaves do RE6 conforme Alias           �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �SIGAAPT  	                                                �
�������������������������������������������������������������������������/*/
Function AptMemRec( cAlias , aRecnos , aMemoEn , aRe6Recnos , aRe6Keys , lObtemKeys )

DEFAULT lObtemKeys := .F.

ApdMsMmObtemRec( cAlias , aRecnos , aMemoEn , @aRe6Recnos , @aRe6Keys , lObtemKeys )

Return( WhileNoLock( "RE6" , aRe6Recnos , aRe6Keys , 1 , 1 , .T. , NIL , 5 ) )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �19/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �APTA120                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina :={;
								{ STR0001 , "AxPesqui"	 , 0 , 01 } ,; //"Pesquisar"
								{ STR0002 , "Apta120Mnt" , 0 , 02 } ,; //"Visualizar"
								{ STR0004 , "Apta120Mnt" , 0 , 04 } ,; //"Atualizar"
								{ STR0005 , "Apta120Mnt" , 0 , 05 }  ; //"Excluir"
							}
Return aRotina