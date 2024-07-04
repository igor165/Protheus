#INCLUDE "protheus.ch"     
#INCLUDE "apta080.ch"      

Static cIdiom := FWRetIdiom()

/*/
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Programa  �APTA080   � Autor � TANIA BRONZERI             � Data �  29/03/2004 ���
���������������������������������������������������������������������������������͹��
���Descricao � Cadastro de Tipos                                                  ���
���          �                                                                    ���
���������������������������������������������������������������������������������͹��
���Uso       � Cadastro de Tipos de Processos (Acoes), Audiencias, Fases,         ���
���          � Ocorrencias, Pleitos, Recursos, Pericias, Resultados de            ���
���          � Pericias, Despesas, Prognosticos, Eventos para Intimacao           ���
���          � / Convocacao / Notificacao e Sentenca                              ���
���������������������������������������������������������������������������������Ķ��
���        ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                      ���
���������������������������������������������������������������������������������Ķ��
���Programador � Data     � BOPS �  Motivo da Alteracao                           ���
���������������������������������������������������������������������������������Ķ��
���Cecilia Car.�12/08/2014�TQEQCC�Incluido o fonte da 11 para a 12 e efetuada a   ���
���            �          �      �limpeza.                                        ���
���Matheus M.  �08/12/2015�TTZVJD�Ajuste na fun��o RE5GdDelOk que valida a exclu -���
���			   �          �		 �s�o de um TIPO REM com Tip. Propri = Microsiga. ���
���Matheus M.  �21/12/2015�TTVHG0�Ajuste na fun��o Re5ChkUso que valida a exclu - ���
���			   �          �		 �s�o de um TIPO REM v�nculado a um processo. 	  ���
��������������������������������������������������������������������������������ͼͱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
/*/

Function APTA080( cAlias , nReg , nOpc , lExecAuto , lMaximized )

Local aArea 	:= GetArea()
Local aAreaREK	:= REK->( GetArea() )
Local aAreaRE5	:= RE5->( GetArea() )
Local lExistOpc	:= ( ValType( nOpc ) == "N" )
Local lTabGen	:= .F.
Local aBrowse 	:= {}
Local bBlock
Local nPos

LOCAL cFiltraRH		  						//Variavel para filtro
LOCAL aIndCateg	:= {}						//Variavel Para Filtro
Local cFiltro

Private cCadastro	:= OemToAnsi(STR0001)	//"Cadastro de Tipos" 

cAlias	:= "REK"
DbSelectArea(cAlias)
lTabGen	:=	IIF(Len(REK->REK_TABELA)=4,.T.,.F.)

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	�Redefine o Alias                                              �
	����������������������������������������������������������������/*/

	/*/
	��������������������������������������������������������������Ŀ
	�Nao Executa se o REK estiver Vazio                            �
	����������������������������������������������������������������/*/
	IF !ChkVazio( cAlias )
		Break
	EndIF

	Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

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
			APTA080Mnt( cAlias , nReg , nOpc , .T. ,, lMaximized )
		
		EndIF

	Else
		
		//������������������������������������������������������������������������Ŀ
		//� Inicializa o filtro utilizando a funcao FilBrowse por nModulo          �
		//��������������������������������������������������������������������������
		cFiltraRh 	:= CHKRH("APTA080","REK","1") 
		cFiltro		:= Iif(Empty(cFiltraRh),"(","("+cFiltraRh + ' .And. ')
		cFiltro		+= 'REK->REK_MODULO == nModulo) '  
		cFiltro		+= '.OR. (REK->REK_MODULO == 0 .And. ( (nModulo == 64) .OR. (nModulo == 07)))'
		
		bFiltraBrw 	:= {|| FilBrowse("REK",@aIndCateg,@cFiltro) }
		dbSelectArea("REK")
		dbSetOrder(2)
		
		Eval(bFiltraBrw)

		IF cIdiom == "es"    
			aAdd(aBrowse,{"Categoria " ,"REK_TABELA" })
			aAdd(aBrowse,{"Nm.Cat.Span." ,"REK_DSCSPA"})
		ELSEIF cIdiom == "en" 
			aAdd(aBrowse,{"Category   "  ,"REK_TABELA" })
			aAdd(aBrowse,{"Nm.Cat.Engl.","REK_DSCENG"})
		ELSE                                          
			aAdd(aBrowse,{"Categoria    " ,"REK_TABELA" })
			aAdd(aBrowse,{"Nome Categ. "  ,"REK_DESCR "})
		ENDIF

		/*/
		������������������������������������������������������������������������Ŀ
		� Chama a Funcao de Montagem do Browse                                   �
		��������������������������������������������������������������������������/*/

		IF lTabGen
			mBrowse( 6, 1, 22, 75, cAlias, aBrowse, Nil, Nil, Nil, Nil, Apta80Cor() )
		Else
			mBrowse( 6, 1, 22, 75, cAlias, aBrowse )
		EndIF

	EndIF
	EndFilBrw("REK",aIndCateg)
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
RestArea( aAreaRE5 )
RestArea( aAreaREK )
RestArea( aArea	   )

/*/
��������������������������������������������������������������Ŀ
�Restaura o Cursor do Mouse                				   	   �
����������������������������������������������������������������/*/
CursorArrow()
	
Return( NIL )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Aptx080Del�Autor  �Microsiga           � Data �  11/04/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Aptx080Del ()

dbSelectArea("RE5")
dbSetOrder(1)
                      
If (ChkDelRegs("RE5"))
	RecLock("RE5",.F.)
	DBDelete()
	MSUnlock()
Endif

Return Nil


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �Ap080F3Re5� Autor �Tania Bronzeri         � Data �13/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Tipos (Manutencao)	 	 	 	 				�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA080()	                                                �
�������������������������������������������������������������������������/*/
Function Ap080F3Re5(cCategoria)

Local cReadVar	:= Upper( AllTrim( ReadVar() ) )
Local cRet		:= ""        
Local lTabGen	:= IIF(Len(ALLTRIM(REK->REK_TABELA))=4,.T.,.F.)
Local cTipo		:= IIF(lTabGen,"S","")

cTipo			+= Substr(cReadVar,4,3)

Default cCategoria := cTipo
                                                                                                                                                                                                                                         
cRet := "@#RE5->RE5_TABELA='"+cCategoria+"'@#"

//Garanto o Posicionamento na Tabela REK
REK->( MsSeek( xFilial( "REK" ) + cCategoria , .F. ) )

Return (cRet)


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APTA080Mnt� Autor �Tania Bronzeri         � Data �13/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Tipos (Manutencao)	 	 	 	 				�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �APTA080Mnt( cAlias , nReg , nOpc , lDlgPadSiga )			�
�����������������������������������������������������������������������Ĵ
�Parametros�cAlias 		= Alias do arquivo                              �
�          �nReg   		= Numero do registro                            �
�          �nOpc   		= Numero da opcao selecionada                   �
�          �lDlgPadSiga = Numero da opcao selecionada                   �
�����������������������������������������������������������������������Ĵ
�Uso       �APTA080()	                                                �
�������������������������������������������������������������������������/*/
Function APTA080Mnt( cAlias , nReg , nOpc , lDlgPadSiga , lTela , lMax )

Local aArea			:= GetArea()
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aREKHeader	:= {}
Local aREKCols		:= {}
Local aSvREKCols	:= {}
Local aREKFields	:= {}
Local aREKAltera	:= {}
Local aREKNaoAlt	:= {}
Local aREKVirtEn	:= {}
Local aREKNotFields	:= {}
Local aREKVisuEn	:= {}
Local aRE5GdAltera  := {}
Local aRE5GdNaoAlt	:= {}
Local aRE5Recnos	:= {}
Local aRE5Keys		:= {}
Local aRE5NotFields	:= {}
Local aRE5VirtGd	:= {}
Local aRE5VisuGd	:= {}
Local aRE5Header	:= {}
Local aRE5Cols		:= {}
Local aSvRE5Cols	:= {}
Local aRE5Query		:= {}
Local aRE5MemoGd	:= {}
Local aLog			:= {}
Local aLogTitle		:= {}
Local aLogGer		:= {}
Local aLogGerTitle	:= {}
Local aButtons		:= {}
Local aFreeLocks	:= {}
Local bRE5GdDelOk	:= { || NIL }
Local bRE5TreeDelOk	:= { || .T. }
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local bDialogInit	:= { || NIL }
Local bGdRE5Seek	:= { || NIL }
Local bGetREK		:= { || NIL } 
Local bGetRE5		:= { || NIL }
Local cREKKeySeek	:= ""
Local cFilREK		:= ""
Local cTabREK		:= ""
Local cMsgYesNo		:= ""
Local cTitLog		:= ""
Local lLocks		:= .F.
Local lExecLock		:= .F.
Local lExcGeraLog	:= .F.
Local nOpcAlt		:= 0
Local nREKUsado		:= 0
Local nRE5Usado		:= 0
Local nLoop			:= 0
Local nLoops		:= 0
Local nOpcNewGd		:= 0
Local nRE5ItemOrd	:= 0
Local nRE5PosItem	:= 0
Local nRE5MaxLocks	:= 10
Local oDlg			:= NIL
Local oEnREK		:= NIL
Local lTabGen		:= IIF(Len(REK->REK_TABELA)=4,.T.,.F.)
Local lGravaOk		:= .T.

Private aGets
Private aTela
Private aREKKeys	:= {}
Private oGdRE5		:= NIL
Private lRecad		:= .F.

nRE5ItemOrd	:=	RetOrdem( "RE5" , "RE5_FILIAL+RE5_TABELA+RE5_PROPRI+RE5_CODIGO" )
nOpc			:=	IIF (nOpc==4,5,nOpc)
bRE5GdDelOk	:= { |lDelOk| CursorWait() , lDelOk := RE5GdDelOk( "RE5" , NIL , nOpc , cTabREK ) , CursorArrow() , lDelOk }
lExecLock		:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
nOpcNewGd		:= 	IIF	( ( ( nOpc == 2 ) .or. ( nOpc == 4 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE	)

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
		aREKNotFields	:= { "REK_TABELA" , "REK_DESCR" , "REK_DSCSPA" , "REK_DSCENG"}
		bGetREK			:= { |lExclu|	IF( lExecLock , lExclu := .T. , NIL ),;
											aREKCols := REK->(;
																GdMontaCols(	@aREKHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																				@nREKUsado		,;	//02 -> Numero de Campos em Uso
																				@aREKVirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																				@aREKVisuEn		,;	//04 -> [@]Array com os Campos Visuais
																				"REK"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																				aREKNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																				NIL				,;	//07 -> [@]Array unidimensional contendo os Recnos
																				"REK"		   	,;	//08 -> Alias do Arquivo Pai
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
																				@aREKKeys		,;	//26 -> [@]Array que contera as chaves conforme Recnos
																				NIL				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
																				@lExclu			 ;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		    );
															  ),;
											IF( lExecLock , lExclu , .T. );
		  					} 
		/*/
		��������������������������������������������������������������Ŀ
		�Lock do Registro do REK									   �
		����������������������������������������������������������������/*/
		IF !( lLocks := WhileNoLock( "RDU_REK" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetREK ) )
			Break
		EndIF
		CursorWait()
		aSvREKCols		:= aClone( aREKCols )
		cFilREK			:= REK->REK_FILIAL
		cTabREK			:= REK->REK_TABELA
		cREKKeySeek		:= ( cFilREK + cTabREK )

		/*/
		������������������������������������������������������������������������Ŀ
		�Os Modelos de Categorias ficaram assim definidos:                       �
		�Modelo 1: Tabela segue vazia no instalador, e o cliente inclui todos os �
		�          Tipos, e pode dar manutencao em todos como desejar.           �
		�Modelo 2: Tabela segue com Tipos pre-cadastrados, mas o cliente pode in-�
		�          cluir novos Tipos, e dar manutencao somente nos que criar, nao�
		�          podendo alterar os Tipos padroes da Microsiga.                �
		�Modelo 3: Tabela segue com Tipos exclusivos da Microsiga, sendo que o   |
		|          cliente nao pode dar nenhuma manutencao. Nao sera possivel a  |
		|          inclusao de novos registros.                                  |
		��������������������������������������������������������������������������/*/

		IF REK->REK_MODELO == "3"
			nOpc	:=	2
			Aviso( STR0010, STR0020, { "OK" } ) //"Atencao!"###"Nao e permitida a manutencao de Tipos nesta Categoria."
			lExecLock	:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
			nOpcNewGd	:= 	IIF	( ( ( nOpc == 2 ) .or. ( nOpc == 4 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE	)
		EndIF
		
		/*/
		��������������������������������������������������������������Ŀ
		� Cria as Variaveis de Memoria e Carrega os Dados Conforme o ar�
		� quivo														   �
		����������������������������������������������������������������/*/

		For nLoop := 1 To nREKUsado
			IF cIdiom == "es"    
				If ! (aREKHeader[ nLoop , 02 ] $ "REK_DSCENG,REK_DESCR")
					aAdd( aREKFields , aREKHeader[ nLoop , 02 ] )
					SetMemVar( aREKHeader[ nLoop , 02 ] , aREKCols[ 01 , nLoop ] , .T. )
				Endif	
			ELSEIF cIdiom == "en" 
				If ! (aREKHeader[ nLoop , 02 ] $ "REK_DSCSPA,REK_DESCR")
					aAdd( aREKFields , aREKHeader[ nLoop , 02 ] )
					SetMemVar( aREKHeader[ nLoop , 02 ] , aREKCols[ 01 , nLoop ] , .T. )
				Endif	
			ELSE                                          
				If ! (aREKHeader[ nLoop , 02 ] $ "REK_DSCSPA,REK_DSCENG")
					aAdd( aREKFields , aREKHeader[ nLoop , 02 ] )
					SetMemVar( aREKHeader[ nLoop , 02 ] , aREKCols[ 01 , nLoop ] , .T. )
				Endif	
			ENDIF
		Next nLoop

		/*/
		��������������������������������������������������������������Ŀ
		� Monta os Dados para a GetDados							   �
		����������������������������������������������������������������/*/
		aAdd( aRE5NotFields , "RE5_FILIAL"  )
		aAdd( aRE5NotFields , "RE5_TABELA"	)
		aRE5Query		:= Array( 05 )
		aRE5Query[01]	:= "RE5_FILIAL='"+cFilREK+"'"
		aRE5Query[02]	:= " AND "
		aRE5Query[03]	:= "RE5_TABELA='"+cTabREK+"'"
		aRE5Query[04]	:= " AND "
		aRE5Query[05]	:= "D_E_L_E_T_=' ' "
		/*/
		��������������������������������������������������������������Ŀ
		� Quando For Inclusao Posiciona o RE5 No Final do Arquivo	   �
		����������������������������������������������������������������/*/
		IF ( nOpc == 3  ) //Inclusao
			/*/
			��������������������������������������������������������������Ŀ
			� Garante que na Inclusao o Ponteiro do RE5 estara em Eof()    � 
			����������������������������������������������������������������/*/
			PutFileInEof( "RE5" )
		EndIF
		RE5->( dbSetOrder( nRE5ItemOrd ) )
		bGetRE5	:= { |lLock,lExclu| IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aRE5Keys := NIL ),;
							 		aRE5Cols := RE5->(;
														GdMontaCols(	@aRE5Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																		@nRE5Usado		,;	//02 -> Numero de Campos em Uso
																		@aRE5VirtGd		,;	//03 -> [@]Array com os Campos Virtuais
																		@aRE5VisuGd		,;	//04 -> [@]Array com os Campos Visuais
																		"RE5"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																		aRE5NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																		@aRE5Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																		"REK"		   	,;	//08 -> Alias do Arquivo Pai
																		cREKKeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
																		NIL				,;	//10 -> Bloco para condicao de Loop While
																		NIL				,;	//11 -> Bloco para Skip no Loop While
																		.T.				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																		NIL				,;	//13 -> Se cria variaveis Publicas
																		NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
																		NIL				,;	//15 -> Lado para o inicializador padrao
																		NIL				,;	//16 -> Opcional, Carregar Todos os Campos
																		NIL				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
																		aRE5Query		,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
																		.F.				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																		.F.				,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																		.F.				,;	//21 -> Carregar Coluna Fantasma
																		NIL				,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																		NIL				,;	//23 -> Verifica se Deve verificar se o campo eh usado
																		NIL				,;	//24 -> Verifica se Deve verificar o nivel do usuario
																		NIL				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																		@aRE5Keys  		,;	//26 -> [@]Array que contera as chaves conforme Recnos
																		@lLock			,;	//27 -> [@]Se devera efetuar o Lock dos Registros
																		@lExclu			,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		nRE5MaxLocks	 ;	//29 -> Numero maximo de Locks a ser efetuado
																    );
													  ),;
									IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  		    }
		/*/
		��������������������������������������������������������������Ŀ
		�Lock do Registro do RE5									   �
		����������������������������������������������������������������/*/
		IF !( lLocks := WhileNoLock( "RE5" , NIL , NIL , 1 , 1 , .T. , nRE5MaxLocks , 5 , bGetRE5 ) )
			Break
		EndIF
		CursorWait()
		aSvRE5Cols	:= aClone( aRE5Cols )

		/*/
		��������������������������������������������������������������Ŀ
		� Carrega os Campos Editaveis para a GetDados				   �
		����������������������������������������������������������������/*/
		For nLoop := 1	To nRE5Usado
			SetMemVar( aRE5Header[ nLoop , 02 ] , GetValType( aRE5Header[ nLoop , 08 ] , aRE5Header[ nLoop , 04 ] ) , .T. )
			IF (;
					(;
						( aScan( aRE5VirtGd		, aRE5Header[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aRE5VisuGd		, aRE5Header[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aRE5NotFields	, aRE5Header[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aRE5GdNaoAlt	, aRE5Header[ nLoop , 02 ] ) == 0 )		;
			   		) .or. ;
			   		( aScan( aRE5MemoGd	, { |x| aRE5Header[ nLoop , 02 ] == x[1] } ) > 0 )	;
			  	)
				aAdd( aRE5GdAltera , aRE5Header[ nLoop , 02 ] )
			EndIF			   
		Next nLoop

		/*/
		��������������������������������������������������������������Ŀ
		� Monta as Dimensoes dos Objetos         					   �
		����������������������������������������������������������������/*/
		DEFAULT lDlgPadSiga	:= .F.
		aAdvSize		:= MsAdvSize( NIL , lDlgPadSiga )
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 040 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
		/*/
		��������������������������������������������������������������Ŀ
		� Define o Botao de Pesquisa na GetDados					   �
		����������������������������������������������������������������/*/
		bGdRE5Seek := { ||	GdRE5Seek( oGdRE5 ),;
							SetKey( VK_F4 , bGdRE5Seek );
				   }
		aAdd(;
				aButtons	,;
								{;
									"pesquisa" 							,;
		   							bGdRE5Seek							,;
		       	   					OemToAnsi( STR0001 + "...<F4>"  )	,;	//"Pesquisar"
		       	   					OemToAnsi( STR0015 )			 ;	//"Pesq.Tipo"
		           				};
		     )
	    
		/*/
		��������������������������������������������������������������Ŀ
		� Define o Bloco para a Tecla <CTRL-O> 						   �
		����������������������������������������������������������������/*/
		bSet15		:= { || IF(; 
									( ( nOpc == 3 ) .Or. ( nOpc == 5 )  )		 .and.;	//Atualizacao
									IF(;
										!fCompArray( aSvRE5Cols , oGdRE5:aCols ),;
										oGdRE5:TudoOk(),;			//Valida as Informacoes da GetDados
										.T.;
									  ),;		
									(;
										nOpcAlt := 1 ,;
										RestKeys( aSvKeys , .T. ),;
										oDlg:End();
								 	),;
								 	IF(; 
								 		( ( nOpc == 3 ) .Or. (nOpc == 5 ) ) ,;		//Atualizacao
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
*/
		bDialogInit := { ||;
								EnchoiceBar( oDlg , bSet15 , bSet24 , NIL  ),;
						}
	/*/
	��������������������������������������������������������������Ŀ
	� Restaura o Ponteiro do Cursor do Mouse                  	   �
	����������������������������������������������������������������/*/
	CursorArrow()

	/*/
	����������������������������������Ŀ
	� Monta o Dialogo Principal 	   �
	������������������������������������/*/
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0007 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL

		/*/
		��������������������������������������������������������������Ŀ
		� Monta o Objeto Enchoice para o REK                      	   �
		����������������������������������������������������������������/*/
		oEnREK	:= MsmGet():New(	cAlias		,;
									nReg		,;
									2			,;
									NIL			,;
									NIL			,;
									NIL			,;
									aREKFields	,;
									aObjSize[1] ,;
									aREKAltera	,;
									NIL			,;
									NIL			,;
									NIL			,;
									oDlg		,;
									NIL			,;
									.T.			 ;
								)
		/*/
		��������������������������������������������������������������Ŀ
		� Monta o Objeto GetDados para o RE5						   �
		����������������������������������������������������������������/*/
		oGdRE5	:= MsNewGetDados():New(	aObjSize[2,1]								,;
										aObjSize[2,2]								,;
										aObjSize[2,3]								,;
										aObjSize[2,4]								,;
										nOpcNewGd									,;
										"RE5GdLinOk"								,;
										"RE5GdTudOk"								,;
										""											,;
										aRE5GdAltera								,;
										0											,;
										999999										,;
										NIL											,;
										NIL											,;
										bRE5GdDelOk									,;
										oDlg										,;
										aRE5Header									,;
										aRE5Cols		 							 ;
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
	�clui as Informacoes do REK e RE5							   �
	����������������������������������������������������������������/*/
	IF( nOpcAlt == 1 )
		/*/
		��������������������������������������������������������������Ŀ
		� Apenas se nao For Visualizacao              				   �
		����������������������������������������������������������������/*/
 		IF ( nOpc != 2 )
			/*/
			��������������������������������������������������������������Ŀ
			� Gravando/Incluido ou Excluindo Informacoes do SRY/RE5        �
			����������������������������������������������������������������/*/
			aRE5Cols := oGdRE5:aCols //Redireciona o Ponteiro do aRE5Cols
			IF nOpc == 5
				CursorWait() 
				lGravaOk := RE5DelAll(cTabRek,lTabGen)
				CursorArrow()
			EndIF
			IF lGravaOk
				MsAguarde(;
							{ ||;
									APTA080Grava(	nOpc		,;	//Opcao de Acordo com aRotina
								 					nReg		,;	//Numero do Registro do Arquivo Pai ( REK )
								 					aRE5Header	,;	//Campos do Arquivo Filho ( RE5 )
								 					aRE5Cols	,;	//Itens Atual do Arquivo Filho ( RE5 )
								 					aSvRE5Cols	,;	//Itens Anterior do Arquivo Filho ( RE5 )
								 					aRE5VirtGd	,;	//Campos Virtuais do Arquivo Filho ( RE5 )
								 					aRE5Recnos	,;	//Recnos do Arquivo Filho ( RE5 )
								 					aRE5MemoGd	 ;	//Campos Memo na GetDados ( RE5 )
								  				);
							};
						)
			EndIF
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

aAdd( aFreeLocks , { "RDU_REK"	, NIL			, aREKKeys } )
aAdd( aFreeLocks , { "RE5" 		, aRE5Recnos	, aRE5Keys } )
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

//======================================================================================================

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �RE5GdLinOk	�Autor�Tania Bronzeri         � Data �13/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �RE5GdLinOk( oBrowse )									    �
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA080()	                                                �
�������������������������������������������������������������������������/*/
Function RE5GdLinOk( oBrowse )

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
	PutFileInEof( "RE5" )
	
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
			aCposKey := { "RE5_CODIGO" }
			IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
				Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica Se o Campos Estao Devidamente Preenchidos		   �
			����������������������������������������������������������������/*/
			aCposKey := { "RE5_CODIGO" , "RE5_DESCR" }
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
�Fun��o    �RE5GdTudOk	�Autor�Tania Bronzeri         � Data �13/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �RE5GdTudOk( oBrowse )									   	�
�����������������������������������������������������������������������Ĵ
�Parametros� 															�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA080()	                                                �
�������������������������������������������������������������������������/*/
Function RE5GdTudOk( oBrowse )

Local lTudoOk 	:= .T. 
Local cCateg	:=	""  
Local cTipo		:=	""
Local lTabGen	:= IIF(Len(REK->REK_TABELA)=4,.T.,.F.)

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
			
			//Verificacao de uso dos tipos no Processo para delecao
			IF ( GdDeleted() )	
				cCateg	:=	IIF(lTabGen,right(aREKKeys[1],4),right(aREKKeys[1],3))
				cTipo	:=	oBrowse:oMother:aCols[n][1]	
				lTudoOk	:=	Re5ChkUso(cCateg,cTipo,lTabGen)
			EndIF
			
			IF !(lTudoOk)
				oBrowse:Refresh()
				Break
			EndIF
			
			IF !( lTudoOk := RE5GdLinOk( oBrowse ) )
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
�Fun��o    �RE5GdDelOk  �Autor�Tania Bronzeri         � Data �13/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Validar a Delecao na GetDados                               �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>								    �
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>								    �
�����������������������������������������������������������������������Ĵ
�Uso       �APTA080()	                                                �
�������������������������������������������������������������������������/*/
Static Function RE5GdDelOk( cAlias , nREKno , nOpc , cCodigo )
         
Local lDelOk 		:= .T.
Local lStatusDel	:= .F.  
Local lDele			:= .T.
Local nRE5ItemOrd	:= 0
Local cPropri		:=	""
Local lSigaDelOk	:=	.F.

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

	cPropri	:=	GdFieldGet("RE5_PROPRI",oGdRE5:nAt,,oGdRE5:aHeader,oGdRE5:aCols)
	lDele	:=	IIF ( (cPropri == "U") , .T. , .F. )  
	IF !lDele .And. !lSigaDelOk
		Aviso( STR0010, STR0019, { "OK" } ) //"Atencao!"###"Nao e permitida a exclusao de Tipos do proprietario Microsiga."
		lSigaDelOk	:= .T.
	EndIF

	lStatusDel	:= IIF ( lDele, !( GdDeleted() ), GdDeleted() ) //Se for Tipo do Usu�rio, Inverte o Estado
	
	IF ( lStatusDel )	//Deletar
    	IF !( nOpc == 3  )	//Quando nao for Atualizacao
			nRE5ItemOrd	:= RetOrdem( "RE5" , "RE5_FILIAL+RE5_TABELA+RE5_CODIGO" )
    		RE5->( dbSetOrder( nRE5ItemOrd ) )
    		IF !( lDelOk := ApdChkDel( cAlias , n , nOpc , ( cCodigo + GdFieldGet( "RE5_CODIGO" ) ) , .F. , NIL , NIL , NIL , NIL , .T. ) )
				CursorArrow()
				//"A chave a ser excluida est� sendo utilizada."
				//"At� que as refer�ncias a ela sejam eliminadas a mesma n�o pode ser excluida."
				MsgInfo( OemToAnsi( STR0008 + CRLF + STR0009 ) , cCadastro )
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

If cPropri == "S" .OR. ( lFirstDelOk .AND. Empty(cPropri) )
	lDelOk := .F.
Else
	lDelOk	:=	lDele	
EndIF

Return( lDelOk )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �APTA080Grava �Autor�Tania Bronzeri        � Data �13/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA080()	                                                �
�������������������������������������������������������������������������/*/    
Static Function APTA080Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( REK )
							 	aRE5Header	,;	//Campos do Arquivo Filho ( RE5 )
							 	aRE5Cols	,;	//Itens Atual do Arquivo Filho ( RE5 )
							 	aSvRE5Cols	,;	//Itens Anterior do Arquivo Filho ( RE5 )
							 	aRE5VirtGd	,;	//Campos Virtuais do Arquivo Filho ( RE5 )
							 	aRE5REKnos	,;	//REKnos do Arquivo Filho ( RE5 )
							 	aRE5MemoGd	 ;	//Campos Memo na GetDados ( RE5 )
							  )

/*/
�������������������������������������������������������������Ŀ
� Variaveis de Inicializacao Obrigatoria					  �
���������������������������������������������������������������/*/
Local aMestre	:= GdPutIStrMestre( 01 )
Local aItens	:= {}
Local cOpcao	:= ""
cOpcao	:=	IIF( nOpc == 4 , "DELETE", IIF( nOpc == 3 .Or. nOpc == 5 , "PUT" , NIL ) )

/*/
��������������������������������������������������������������Ŀ
� Altera o Estado do Cursor  								   �
����������������������������������������������������������������/*/
CursorWait()

	/*/
	��������������������������������������������������������������Ŀ
	� Carrega os Itens Apenas se Houver Alteracoes ou na Exclusao  �
	����������������������������������������������������������������/*/
	IF ( ( nOpc == 4 .Or. nOpc == 5 ) .or. !( fCompArray( aRE5Cols , aSvRE5Cols ) ) )

		aItens := GdPutIStrItens( 01 )
		
		aItens[ 01 , 01 ] := "RE5"
		aItens[ 01 , 02 ] := {;
								{ "FILIAL" , xFilial( "RE5" , xFilial( "REK" ) ) },;
								{ "TABELA" , GetMemVar( "REK_TABELA" ) };
							 }
		aItens[ 01 , 03 ] := aClone( aRE5Header )
		aItens[ 01 , 04 ] := aClone( aRE5Cols   )
		aItens[ 01 , 05 ] := aClone( aRE5VirtGd )
		aItens[ 01 , 06 ] := aClone( aRE5REKnos )
		aItens[ 01 , 07 ] := aClone( aRE5MemoGd )
		aItens[ 01 , 08 ] := NIL

	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ou�
	� se foi Selecionada a Exclusao								   �
	����������������������������������������������������������������/*/
	aMestre[ 01 , 01 ]	:= "REK"
	aMestre[ 01 , 02 ]	:= nReg
	aMestre[ 01 , 03 ]	:= .F.
	aMestre[ 01 , 04 ]	:= NIL
	aMestre[ 01 , 05 ]	:= NIL
	aMestre[ 01 , 06 ]	:= {}
	aMestre[ 01 , 07 ]	:= aClone( aItens )
	
	/*/
	��������������������������������������������������������������������Ŀ
	� Grava as Informacoes / 4� Parametro : Se executar� o Sort no aCols �                       				   �
	����������������������������������������������������������������������/*/
	GdPutInfoData( aMestre , cOpcao , , .F. )

/*/
��������������������������������������������������������������Ŀ
� Restaura o Estado do Cursor								   �
����������������������������������������������������������������/*/
CursorArrow()

Return( NIL )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GdRE5Seek	 �Autor�Tania Bronzeri        � Data �13/05/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Efetuar Pesquisa na GetDados                               	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �APTA080                                                		�
�������������������������������������������������������������������������/*/
Static Function GdRE5Seek( oGdRE5 )

Local aSvKeys 		:= GetKeys()
Local cProcName3	:= Upper( AllTrim( ProcName( 3 ) ) )
Local cProcName5	:= Upper( AllTrim( ProcName( 5 ) ) )

Begin Sequence

	IF !( "APTA080MNT" $ ( cProcName3 + cProcName5 ) )
		Break
	EndIF

	GdSeek( oGdRE5 , OemToAnsi( STR0001 ) )	//"Pesquisar"
	
End Sequence

RestKeys( aSvKeys , .T. )

Return( NIL )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Apt080TpInc � Autor � TANIA BRONZERI    � Data � 16/09/2004 ���
�������������������������������������������������������������������������͹��
���Descricao � Inclusao de Tipos Atraves do F3                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SXB => F3 Inclusao                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function Apt080TpInc( cALIAS , nREG  )

nReg	:=	REK->( Recno() )

APTA080MNT("REK",nReg,3,.T.,,.F.)

Return 

      
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Funcao    �RE5CODX3VALID � Autor � TANIA BRONZERI    � Data � 05/10/2004 ���
���������������������������������������������������������������������������͹��
���Descricao � Validacao campo RE5_CODIGO                                   ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � SX3 - X3_Valid                                               ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function RE5CODX3VALID()
Local cVar		:= &( ReadVar() )
Local lCpoOk	:= .T.
Local nx		:= 0
Local nPosCod	
lRecad			:= .F.



IF Empty( StrTran( cVar , "0" , "" )) 
	Aviso( STR0010, STR0011, { "OK" } ) //"Atencao!"###"Zero nao e um valor valido para Codigo do Tipo. Favor informar codigo valido."
	lCpoOk	:=	.F.
EndIF

If !ISINCALLSTACK("APTA100")
	nPosCod	:= GdFieldPos("RE5_CODIGO"	,oGdRE5:aHeader)
	If lCpoOk
		For nx:=1 To Len(oGdRE5:aCols)
			If 	(!Empty(cVar) .And. cVar == oGdRE5:aCols[nx][nPosCod]) .And. n # nx
				If 	!oGdRE5:aCols[nx][Len(oGdRE5:aCols[nx])]
	 				Aviso( STR0010, STR0012, { "OK" } ) //"Atencao!"###"Tipo ja existe na tabela."
	 				lCpoOk	:=	.F.
					Exit
				Else
					lRecad	:= .T.
				EndIf
			EndIf	
		Next nx		
	EndIf
Endif
	

Return( lCpoOk )
                                   
      
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Funcao    �RE5DescrWhen  � Autor � TANIA BRONZERI    � Data � 05/10/2004 ���
���������������������������������������������������������������������������͹��
���Descricao � Validacao campo RE5_CODIGO                                   ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � SX3 - X3_Valid                                               ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function RE5DescrWhen()
Local lRet		:=	.T.
Local cTabela	:=	""        
Local cCodigo	:=	""
Local lNovaDes	:=	.F.    


IF ( IsMemVar( "REK_TABELA" ) )
	cTabela		:=	M->REK_TABELA
Else
	cTabela		:=	REK->REK_TABELA
EndIF
	
If !ISINCALLSTACK("APTA100") .AND. !lRecad
	cCodigo		:=	GdFieldGet("RE5_CODIGO",oGdRE5:nAt,,oGdRE5:aHeader,oGdRE5:aCols)
	RE5->(DBSetOrder(1))
	lNovaDes	:=	RE5->(DBSeek( xFilial("RE5") + REK->REK_TABELA + cCodigo ) )
EndIf
	
IF lNovaDes 
	lNovaDes	:= IIF ( RE5->RE5_PROPRI=="S",.T.,.F. )
EndIF

lRet	:=	IIF ( lNovaDes , .F. , .T. )

Return lRet
                                   
      
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Funcao    �RE5CodigoWhen � Autor � TANIA BRONZERI    � Data � 05/10/2004 ���
���������������������������������������������������������������������������͹��
���Descricao � Validacao campo RE5_CODIGO                                   ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � SX3 - X3_Valid                                               ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function RE5CodigoWhen()

Local lRet		:=	.T.
Local cTabela	:=	""        
Local cCodigo	:=	""
Local lNovoCod	:=	.F.


IF ( IsMemVar( "REK_TABELA" ) )
	cTabela	:=	M->REK_TABELA
Else
	cTabela	:=	REK->REK_TABELA
EndIF
	
If !ISINCALLSTACK("APTA100")
	cCodigo		:=	GdFieldGet("RE5_CODIGO",oGdRE5:nAt,,oGdRE5:aHeader,oGdRE5:aCols)  
Endif
	
RE5->(DbSetOrder(1))
lNovoCod	:=	RE5->(DBSeek( xFilial("RE5") + REK->REK_TABELA+" "+  cCodigo ) )
lRet	:=	IIF ( lNovoCod , .F. , .T. )                                     


Return lRet
                                   
      
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Funcao    �Re5ChkUso		� Autor � TANIA BRONZERI    � Data � 06/05/2005 ���
���������������������������������������������������������������������������͹��
���Descricao � Validacao Codigo para delecao                                ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � 					                                            ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function Re5ChkUso(cCateg,cTipo,lTabGen)
       
Local lEmUso	:=	.F. 
Local cTabela	:=	""     
Local cExpress	:=	""

cTipo			:= AllTrim(cTipo)

IF left(Upper(AllTrim(cCateg)),1)#"U"
	Begin Sequence                   
		IF AllTrim(cCateg) == "RE0"   
			cTabela := "RE0"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(7)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF
			cTabela	:= "REL"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(11)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "REA"
			cTabela	:= "REA"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(4)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "REH" 
			cTabela	:= "REH"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(2)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "REL" 
			cTabela	:= "REL"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(5)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "REM"  
			cTabela := "REM"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(2)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "REO" 
			cTabela	:= "REO"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(3)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "RES" 
			cTabela	:=	"RES"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(2)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "RSP" 
			cTabela	:=	"REL"
			cCateg		:= AllTrim(cCateg) 
			dbSelectArea(cTabela)
			dbSetOrder(12)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "RST"
			cTabela	:= "REH"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(3) 
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "RC1"
			cTabela	:= "RC1"
			cCateg		:= AllTrim(cCateg)
			dbSelectArea(cTabela)
			dbSetOrder(4)
			cExpress	:= cTabela+"->(DBSEEK(xFilial('"+cCateg+"')+'"+cTipo+"'))"
			lEmUso	:=	&(cExpress)    
			IF lEmUso
				Break
			EndIF                                                           
		ElseIF AllTrim(cCateg) == "REF"
			lEmUso	:= REFDelConsist(cTipo)	
			Break
		EndIF
	End Sequence
EndIF

IF lEmUso
	Aviso( STR0010, STR0016+cTipo+STR0017, { "OK" } )	// "Atencao!"###"Tipo "###" em uso, nao pode ser excluido."
EndIF                                                           

Return !(lEmUso)


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao    �REFDelConsist� Autor � TANIA BRONZERI    � Data � 11/05/2005 ���
��������������������������������������������������������������������������͹��
���Descricao � Checa Relacionamentos de Fases para Delecao de Registro     ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � Exclus�o de fases                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function REFDelConsist(cTipo)              

Local 	lEmUso	:=	.F.

Begin Sequence

	//Fase do Processo
	DbSelectArea("RE0")
	DbSetOrder(6)
	lEmUso	:=	&("RE0->(DBSEEK(xFilial('RE0')+'"+cTipo+"'))")
	IF lEmUso
		Break
	EndIF                                                           
	
	//Fase da Audiencia
	DbSelectArea("REA")
	DbSetOrder(5)
	lEmUso	:=	&("REA->(DBSEEK(xFilial('REA')+'"+cTipo+"'))")
	IF lEmUso
		Break
	EndIF                                                           
	
	//Fase da Ocorrencia
	DbSelectArea("REO")
	DbSetOrder(4)
	lEmUso	:=	&("REO->(DBSEEK(xFilial('REO')+'"+cTipo+"'))")
	IF lEmUso
		Break
	EndIF                                                           
	
	//Fase da Sentenca
	DbSelectArea("RES")
	DbSetOrder(3)
	lEmUso	:=	&("RES->(DBSEEK(xFilial('RES')+'"+cTipo+"'))")
	IF lEmUso
		Break
	EndIF                                                           

	//Fase do Recurso
	DbSelectArea("REM")
	DbSetOrder(3)
	lEmUso	:=	&("REM->(DBSEEK(xFilial('REM')+'"+cTipo+"'))")
	IF lEmUso
		Break
	EndIF                                                           

End Sequence

Return lEmUso


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao    �RE5DelAll    � Autor � TANIA BRONZERI    � Data � 07/10/2005 ���
��������������������������������������������������������������������������͹��
���Descricao � Seta itens da Get Dados para Delecao                        ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � Exclus�o de Tipos da Categoria                              ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������/*/
Function RE5DelAll(cCateg,lTabGen)

Local cTipo			:=	""
Local lDelAll		:=	.F.
Local nDeleta		:=	Len(oGdRe5:aHeader)+1
Local ni			:=	0 
Local nPosCod 		:= GdFieldPos("RE5_PROPRI",oGdRe5:aHeader) 
Local lSigaDelOk 	:= .F.
                                         
For ni	:= 1 to Len(oGdRe5:aCols)
	cTipo		:= 	oGdRe5:aCols[ni][1]
	lDelAll		:=	Re5ChkUso(cCateg,cTipo,lTabGen)  
	IF (nPosCod<>0 .And. oGdRe5:aCols[ni][nPosCod]=="S") 
		IF !lSigaDelOk
			Aviso( STR0010, STR0019, { "OK" } )		// "Atencao!"###"Nao e permitida a exclusao de Tipos do proprietario Microsiga."
		EndIF
		lDelAll :=	.F.
		lSigaDelOk	:= .T.
	EndIF
	IF (lDelAll) 
		oGdRe5:aCols[ni][nDeleta]:=.T.
	EndIF
Next ni
	
Return lDelAll

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  Apta080Leg    �Autor  �Tania Bronzeri   � Data �25/10/2005���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda de Browse do cadastro de Tipos.   	              ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Apta080Leg()

BrwLegenda	(cCadastro,STR0021, {	{"BR_AZUL"	 , OemToAnsi(STR0022)},; 	//"Legenda###"Categoria da Microsiga"
									{"BR_VERDE"	 , OemToAnsi(STR0023)} ; 	//"Categoria do Usuario"
								  	} ;
			) 
Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Apta80Cor� Autor � Tania Bronzeri        � Data �26/10/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao p/ definir cores p/ Situacao dos Tipos.             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aCores                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�															  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function Apta80Cor()

Local aCores	:=	{	                                    	 	 ;
					{ "Left(REK->REK_TABELA,1)<>'U'" 	,"BR_AZUL"		}   ,;
					{ "Left(REK->REK_TABELA,1)=='U'"	,"BR_VERDE"		}	 ;
				   }

Return(aCores)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � APTA080250 � Autor � TANIA BRONZERI    � Data � 27/10/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Chamada do APTA250, Definicao e Manutencao das Categorias. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � APTA080 - Defin.Categorias                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Apta080250()

Local nOpc250	:= 0 

APTA250(nOPc250,bFiltraBrw,.T.)

Return 
      


/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �19/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �APTA080                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina :=	{;
						{ STR0002 , "AxPesqui"	 	, 0 , 01,,.F.} ,; //"Pesquisar"
						{ STR0003 , "APTA080Mnt" 	, 0 , 02 } ,; //"Visualizar"
						{ STR0004 , "APTA080Mnt" 	, 0 , 04 } ,; //"Atualizar"
						{ STR0006 , "APTA080Mnt"	, 0 , 05 } ,; //"Excluir"
						{ STR0005 , "APTA080250"  	, 0 , 04 } ,; //"Defin.Categ."
						{ STR0021 , "APTA080Leg" 	, 0 , 02,,.F.} ;  //"Legenda"
					}

Return aRotina
