#INCLUDE "PROTHEUS.CH"
#INCLUDE "APTA060.CH"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁAPTA060   ╨Autor  ЁTania Bronzeri      ╨ Data Ё  11/05/2004 ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁCadastro de Varas                                           ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁSIGAAPT                                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁAnalista    Ё Data   Ё BOPS Ё Alteracao                                Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car.Ё04/08/14ЁTQEQ39ЁIncluido o fonte da 11 para a 12 e efetudaЁ╠╠  
╠╠Ё            Ё        Ё      Ёa limpeza.                                Ё╠╠
╠╠ЁOswaldo L  .Ё28/11/17ЁDRHPONTЁEvitar excluir Varas ja vinculadas no    Ё╠╠
╠╠Ё           .Ё        ЁP-2220 Ёsistema. Acerto uso TudoOk               Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function APTA060( cAlias , nReg , nOpc , lExecAuto , lMaximized )
Local aArea 	:= GetArea()
Local aAreaREC	:= REC->( GetArea() )
Local aAreaRE1	:= RE1->( GetArea() )
Local lExistOpc	:= ( ValType( nOpc ) == "N" )

Local bBlock
Local nPos

Begin Sequence

	cAlias	:= "REC"

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁNao Executa se o REC estiver Vazio                            Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !ChkVazio( cAlias )
		Break
	EndIF

	
	Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

	
	Private cCadastro   := OemToAnsi( STR0001 ) //"Varas"

	IF ( lExistOpc )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁGarante o Posicinamento do Recno                              Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
			APTA060Mnt( cAlias , nReg , nOpc , .T. ,, lMaximized )
		
		EndIF

	Else
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Chama a Funcao de Montagem do Browse                                   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		mBrowse( 6 , 1 , 22 , 75 , cAlias )

	EndIF
	
End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁColoca o Ponteiro do Mouse em Estado de Espera			   	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()
		
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura os Dados de Entrada 											 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RestArea( aAreaRE1 )
RestArea( aAreaREC )
RestArea( aArea	   )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura o Cursor do Mouse                				   	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()
	
Return( NIL )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁAPTA060VisЁ Autor ЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Varas ( Visualizar )		             		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function APTA060Vis( cAlias , nReg  )
Return( APTA060( cAlias , nReg , 2 ,, .F. ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁAPTA060IncЁ Autor ЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Varas ( Incluir )	 	 	 					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function APTA060Inc( cAlias , nReg , nOpcz , lMax , cNil , lTela )
                   
Local lDeOnde	:= 	IsInCallStack("Apt060VaraInc")
Local nOpz		:= 0

IF ( (!INCLUI) .AND. (lDeOnde) )  
	nOpz	:=	4
else
	nOpz	:=	3
EndIf

Return( APTA060( cAlias , nReg , nOpz , , .F. ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁAPTA060AltЁ Autor ЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Varas ( Alterar )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function APTA060Alt( cAlias , nReg  )
Return( APTA060( cAlias , nReg , 3 ,, .T. ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁAPTA060DelЁ Autor ЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Varas ( Excluir )	 	 	 					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function APTA060Del( cAlias , nReg  )
Return( APTA060( cAlias , nReg , 5 ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRE1Visual Ё Autor ЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Itens de varas ( Visualizar )	 	 	 		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RE1Visual( cAlias , nReg  )

aRotSetOpc( cAlias , @nReg , 2 )

Return( AxVisual( cAlias, nReg , 2 ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁAPTA060MntЁ Autor ЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Varas (Manutencao)	 	 	 	 				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁAPTA060Mnt( cAlias , nReg , nOpc , lDlgPadSiga )			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁcAlias 		= Alias do arquivo                              Ё
Ё          ЁnReg   		= Numero do registro                            Ё
Ё          ЁnOpcx  		= Sequencia aRotina selecionada                 Ё
Ё          ЁlDlgPadSiga = Numero da opcao selecionada                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA060()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function APTA060Mnt( cAlias , nReg , nOpcx , lDlgPadSiga )

Local aArea			:= GetArea()
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aRECHeader	:= {}
Local aRECCols		:= {}
Local aSvRECCols	:= {}
Local aRECFields	:= {}
Local aRECAltera	:= {}
Local aRECNaoAlt	:= {}
Local aRECVirtEn	:= {}
Local aRECNotFields	:= {}
Local aRECKeys		:= {}
Local aRECVisuEn	:= {}
Local aRE1GdAltera  := {}
Local aRE1GdNaoAlt	:= {}
Local aRE1Recnos	:= {}
Local aRE1Keys		:= {}
Local aRE1NotFields	:= {}
Local aRE1VirtGd	:= {}
Local aRE1VisuGd	:= {}
Local aRE1Header	:= {}
Local aRE1Cols		:= {}
Local aSvRE1Cols	:= {}
Local aRE1Query		:= {}
Local aRE1MemoGd	:= {}
Local aLog			:= {}
Local aLogTitle		:= {}
Local aLogGer		:= {}
Local aLogGerTitle	:= {}
Local aButtons		:= {}
Local aFreeLocks	:= {}
Local aRe6Recnos	:= {}
Local aRe6Keys		:= {}
Local bRE1GdDelOk	:= { |lDelOk| CursorWait() , lDelOk := RE1GdDelOk( "RE1" , NIL , nOpcx , cCodREC ) , CursorArrow() , lDelOk }
Local bRE1TreeDelOk	:= { || .T. }
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local bDialogInit	:= { || NIL }
Local bGdRE1Seek	:= { || NIL }
Local bGetREC		:= { || NIL } 
Local bGetRE1		:= { || NIL }
Local cRECKeySeek	:= ""
Local cFilREC		:= ""
Local cCodREC		:= ""
Local cMsgYesNo		:= ""
Local cTitLog		:= ""
Local lLocks		:= .F.
Local lExecLock		:= .F.
Local lExcGeraLog	:= .F.
Local nOpcAlt		:= 0
Local nRECUsado		:= 0
Local nRE1Usado		:= 0
Local nLoop			:= 0
Local nLoops		:= 0
Local nRE1ItemOrd	:= RetOrdem( "RE1" , "RE1_FILIAL+RE1_COMAR+RE1_VARA" )
Local nRE1PosItem	:= 0
Local nRE1MaxLocks	:= 10
Local oDlg			:= NIL
Local oEnREC		:= NIL
Local oGdRE1		:= NIL
Local lDeOnde		:= IsInCallStack("Apt060VaraInc")//este
Local nOpcNewGd		:= 0

Private aGets
Private aTela

Private nGetSX8Len	:= GetSX8Len()

IF lDeOnde
	nOpcNewGd		:= IF( ( ( nOpcx == 2 ) .or. ( nOpcx == 5 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE	) //pelo que verifiquei nunca ocorre esta clausula, pois Apt060VaraInc nunca И usado
	lExecLock		:= ( ( nOpcx <> 2 ) .and. ( nOpcx <> 3 ) )
Else
	nOpcNewGd		:= IF( ( ( nOpcx == 2 ) .or. ( nOpcx == 4 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE	)
	lExecLock		:= ( ( nOpcx <> 2 ) .and. ( nOpcx <> 4 ) )
EndIF

Begin Sequence

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Coloca o ponteiro do Cursor do Mouse em Estado de Espera     Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorWait()

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁCheca a Opcao Selecionada									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aRotSetOpc( cAlias , NIL , 2 )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta os Dados para a Enchoice							   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aRECNotFields	:= { "REC_CODIGO" , "REC_NOME" }
		bGetREC			:= { |lExclu|	IF( lExecLock , lExclu := .T. , NIL ),;
											aRECCols := REC->(;
																GdMontaCols(	@aRECHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																				@nRECUsado		,;	//02 -> Numero de Campos em Uso
																				@aRECVirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																				@aRECVisuEn		,;	//04 -> [@]Array com os Campos Visuais
																				"REC"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																				aRECNotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																				NIL				,;	//07 -> [@]Array unidimensional contendo os Recnos
																				"REC"		   	,;	//08 -> Alias do Arquivo Pai
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
																				@aRECKeys		,;	//26 -> [@]Array que contera as chaves conforme recnos
																				NIL				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
																				@lExclu			 ;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		    );
															  ),;
											IF( lExecLock , lExclu , .T. );
		  					} 
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do REC									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "RDU_REC" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetREC ) )
			Break
		EndIF
		CursorWait()
		aSvRECCols		:= aClone( aRECCols )
		cFilREC			:= REC->REC_FILIAL
		cCodREC			:= REC->REC_CODIGO
		cRECKeySeek		:= ( cFilREC + cCodREC )
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
		Ё quivo														   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1 To nRECUsado
			aAdd( aRECFields , aRECHeader[ nLoop , 02 ] )
			SetMemVar( aRECHeader[ nLoop , 02 ] , aRECCols[ 01 , nLoop ] , .T. )
		Next nLoop

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta os Dados para a GetDados							   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aRE1NotFields , "RE1_FILIAL"  )
		aAdd( aRE1NotFields , "RE1_COMAR"	)
		if cPaisLoc != "BRA"
			aAdd( aRE1NotFields , "RE1_IDVARA"	)
			aAdd( aRE1NotFields , "RE1_CODMUN"	)
			aAdd( aRE1NotFields , "RE1_MUNIC"	)
		EndIf
		aRE1Query		:= Array( 05 )
		aRE1Query[01]	:= "RE1_FILIAL='"+cFilREC+"'"
		aRE1Query[02]	:= " AND "
		aRE1Query[03]	:= "RE1_COMAR='"+cCodREC+"'"
		aRE1Query[04]	:= " AND "
		aRE1Query[05]	:= "D_E_L_E_T_=' ' "
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Quando For Inclusao Posiciona o RE1 No Final do Arquivo	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpcx == 3  ) //Inclusao
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Garante que na Inclusao o Ponteiro do RE1 estara em Eof()    Ё 
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			PutFileInEof( "RE1" )
		EndIF
		RE1->( dbSetOrder( nRE1ItemOrd ) )
		bGetRE1	:= { |lLock,lExclu| IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aRE1Keys := NIL ),;
							 		aRE1Cols := RE1->(;
														GdMontaCols(	@aRE1Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																		@nRE1Usado		,;	//02 -> Numero de Campos em Uso
																		@aRE1VirtGd		,;	//03 -> [@]Array com os Campos Virtuais
																		@aRE1VisuGd		,;	//04 -> [@]Array com os Campos Visuais
																		"RE1"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																		aRE1NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																		@aRE1Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																		"REC"		   	,;	//08 -> Alias do Arquivo Pai
																		cRECKeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
																		NIL				,;	//10 -> Bloco para condicao de Loop While
																		NIL				,;	//11 -> Bloco para Skip no Loop While
																		NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																		NIL				,;	//13 -> Se cria variaveis Publicas
																		NIL				,;	//14 -> Se Sera considerado o Inicializador Padrao
																		NIL				,;	//15 -> Lado para o inicializador padrao
																		NIL				,;	//16 -> Opcional, Carregar Todos os Campos
																		NIL				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
																		aRE1Query		,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
																		.F.				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																		.F.				,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																		.F.				,;	//21 -> Carregar Coluna Fantasma
																		NIL				,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																		NIL				,;	//23 -> Verifica se Deve verificar se o campo eh usado
																		NIL				,;	//24 -> Verifica se Deve verificar o nivel do usuario
																		NIL				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																		@aRE1Keys  		,;	//26 -> [@]Array que contera as chaves conforme recnos
																		@lLock			,;	//27 -> [@]Se devera efetuar o Lock dos Registros
																		@lExclu			,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		nRE1MaxLocks	 ;	//29 -> Numero maximo de Locks a ser efetuado
																    );
													  ),;
									IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  		    }
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do RE1									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "RE1" , NIL , NIL , 1 , 1 , .T. , nRE1MaxLocks , 5 , bGetRE1 ) )
			Break
		EndIF
		CursorWait()
		aSvRE1Cols	:= aClone( aRE1Cols )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega os Campos Editaveis para a GetDados				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1	To nRE1Usado
			SetMemVar( aRE1Header[ nLoop , 02 ] , GetValType( aRE1Header[ nLoop , 08 ] , aRE1Header[ nLoop , 04 ] ) , .T. )
			IF (;
					(;
						( aScan( aRE1VirtGd		, aRE1Header[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aRE1VisuGd		, aRE1Header[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aRE1NotFields	, aRE1Header[ nLoop , 02 ] ) == 0 ) .and.	;
			   			( aScan( aRE1GdNaoAlt	, aRE1Header[ nLoop , 02 ] ) == 0 )		;
			   		) .or. ;
			   		( aScan( aRE1MemoGd	, { |x| aRE1Header[ nLoop , 02 ] == x[1] } ) > 0 )	;
			  	)
				aAdd( aRE1GdAltera , aRE1Header[ nLoop , 02 ] )
			EndIF			   
		Next nLoop

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta as Dimensoes dos Objetos         					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdvSize		:= MsAdvSize( )
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Botao de Pesquisa na GetDados					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bGdRE1Seek := { ||	GdRE1Seek( oGdRE1 )}
		

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para a Tecla <CTRL-O> 						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bSet15		:= { || IF(; 
									( ( nOpcx == 3 ) 	)	.and.	;	//	.or. ( nOpc == 4 ) )		 .and.;	//Inclusao ou Alteracao
									IF(;
										!fCompArray( aSvRE1Cols , oGdRE1:aCols ),;
										oGdRE1:TudoOk(),;									//Valida as Informacoes da GetDados
										.T.;
									  ),;		
									(;
										nOpcAlt := 1 ,;
										RestKeys( aSvKeys , .T. ),;
										oDlg:End();
								 	),;
								 	IF(; 
								 		( ( nOpcx == 3 )	)	,	;	//	 .or. ( nOpc == 4 ) ) ,;				//Inclusao ou Visualizacao
								 			(;
								 				nOpcAlt :=	1	,	;	//	 0 ,;
								 				.F.;
								 			 ),;	
										(;
											nOpcAlt := IF( nOpcx == 2 , 0 , 1 ) ,;			//Visualizacao ou Exclusao
											RestKeys( aSvKeys , .T. ),;
											IF( nOpcx == 4,    Iif( !PermtExcl(aRE1Header,oGdRE1:aCols), (nOpcAlt := 0, RestKeys( aSvKeys , .T. )),  oDlg:End()  )       , oDlg:End() )   ;
								 		);
								 	  );
							   );
						 }
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para a Teclas <CTRL-X>     	   			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bSet24		:= { || ( nOpcAlt := 0 , RestKeys( aSvKeys , .T. ) , oDlg:End() ) }
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para o Init do Dialog						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		SetKey( VK_F4 , bGdRE1Seek )
        AADD( aButtons, {NIL, bGdRE1Seek, OemToAnsi(STR0013)+ "<F4>",OemToAnsi(STR0013)+ "<F4>",{|| .T.}} )	//"Pesq.Vara"


		bDialogInit := { ||	EnchoiceBar( oDlg , bSet15 , bSet24 , NIL, aButtons  )}


	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Restaura o Ponteiro do Cursor do Mouse                  	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorArrow()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta o Dialogo Principal para a Manutencao das vARAS	   	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0001 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto Enchoice para o REC                      	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		oEnREC	:= MsmGet():New(	cAlias		,;
									nReg		,;
									2			,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRECFields	,;
									aObjSize[1] ,;
									aRECAltera	,;
									NIL			,;
									NIL			,;
									NIL			,;
									oDlg		,;
									NIL			,;
									.T.			 ;
								)
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto GetDados para o RE1						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		oGdRE1	:= MsNewGetDados():New(	aObjSize[2,1]								,;
										aObjSize[2,2]								,;
										aObjSize[2,3]								,;
										aObjSize[2,4]								,;
										nOpcNewGd									,;
										"RE1GdLinOk"								,;
										"RE1GdTudOk"								,;
										""											,;
										aRE1GdAltera								,;
										0											,;
										999999										,;
										NIL											,;
										NIL											,;
										bRE1GdDelOk									,;
										oDlg										,;
										aRE1Header									,;
										aRE1Cols		 							 ;
									  )


	ACTIVATE MSDIALOG oDlg ON INIT Eval( bDialogInit ) CENTERED


	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁQuando Confirmada a Opcao e Nao for Visualizacao Grava ou   ExЁ
	Ёclui as Informacoes do REC e RE1							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF( nOpcAlt == 1 )
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Apenas se nao For Visualizacao              				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 		IF ( nOpcx != 2 )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Gravando/Incluido ou Excluindo Informacoes do SRY/RE1        Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			aRE1Cols := oGdRE1:aCols //Redireciona o Ponteiro do aRE1Cols
			MsAguarde(;
						{ ||;
								APTA060Grava(	nOpcx		,;	//Opcao de Acordo com aRotina
							 					nReg		,;	//Numero do Registro do Arquivo Pai ( REC )
							 					aRE1Header	,;	//Campos do Arquivo Filho ( RE1 )
							 					aRE1Cols	,;	//Itens Atual do Arquivo Filho ( RE1 )
							 					aSvRE1Cols	,;	//Itens Anterior do Arquivo Filho ( RD2 )
							 					aRE1VirtGd	,;	//Campos Virtuais do Arquivo Filho ( RE1 )
							 					aRE1Recnos	,;	//Recnos do Arquivo Filho ( RE1 )
							 					aRE1MemoGd	 ;	//Campos Memo na GetDados ( RE1 )
							  				);
						};
					)
		EndIF
	ElseIF ( nOpcx == 3 )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё RollBack da Numeracao Automatica            				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		While ( GetSX8Len() > nGetSX8Len )
			RollBackSX8()
		End While
	EndIF

End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁLibera os Locks             								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
aAdd( aFreeLocks , { "RDU_REC"	, NIL			, aRECKeys } )
aAdd( aFreeLocks , { "RE1" 		, aRE1Recnos	, aRE1Keys } )
ApdFreeLocks( aFreeLocks )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura os Dados de Entrada								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RestArea( aArea )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura as Teclas de Atalho                				   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RestKeys( aSvKeys , .T. )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Ponteiro do Cursor do Mouse                  	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( nOpcAlt )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRE1GdLinOk	ЁAutorЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRE1GdLinOk( oBrowse )									    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA060()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RE1GdLinOk( oBrowse )

Local aCposKey	:= {}
Local lLinOk	:= .T.

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Evitar que os Inicializadores padroes sejam carregados indeviЁ
	Ё damente													   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	PutFileInEof( "RE1" )
	
	Begin Sequence
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Se a Linha da GetDados Nao Estiver Deletada				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( GdDeleted() )
		
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Verifica Itens Duplicados na GetDados						   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			aCposKey := { "RE1_VARA" }
			IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
				Break
			EndIF

			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Verifica Se o Campos Estao Devidamente Preenchidos		   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			aCposKey := { "RE1_VARA" , "RE1_DESCR" }
			IF !( lLinOk := GdNoEmpty( aCposKey ) )
		    	Break
			EndIF
	
		EndIF
		
	End Sequence
	
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁSe Houver Alguma Inconsistencia na GetDados, Seta-lhe o Foco  Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !( lLinOk )
		oBrowse:SetFocus()
	EndIF

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( lLinOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRE1GdTudOk	ЁAutorЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRE1GdTudOk( oBrowse )									   	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA060()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RE1GdTudOk( oBrowse )

Local lTudoOk := .T.

Local nLoop
Local nLoops

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	Begin Sequence
	
	    /*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Percorre Todas as Linhas para verificar se Esta Tudo OK      Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		nLoops	:= Len( aCols )
		For nLoop := 1 To nLoops
			n := nLoop
			IF !( lTudoOk := RE1GdLinOk( oBrowse ) )
				oBrowse:Refresh()
				Break
			EndIF
		Next n
	
	End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( lTudoOk  )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRE1GdDelOk  ЁAutorЁTania Bronzeri         Ё Data Ё11/05/2004Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidar a Delecao na GetDados                               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA060()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function RE1GdDelOk( cAlias , nRecno , nOpc , cCodigo )
         
Local lDelOk 		:= .T.
Local lStatusDel	:= .F.
Local nRE1ItemOrd	:= 0

Static lFirstDelOk
Static lLstDelOk

DEFAULT lFirstDelOk	:= .T.
DEFAULT lLstDelOk	:= .T.

Begin Sequence
	
	//Quando for Visualizacao ou Exclusao Abandona
	IF (;
			( nOpc == 2 ) .or. ;	//Visualizacao
			( nOpc == 4 );			//Exclusao ...veja pelo menudef deste fonte que a ordem das opГУes sao diferentes do padrao  4 И o excluir
		)
	
		Break
	EndIF

	//Apenas se for a primeira vez
	IF !( lFirstDelOk )
		lFirstDelOk	:= .T.
		lDelOk 		:= lLstDelOk
		lLstDelOk	:= .T.
		
		lStatusDel	:= !( GdDeleted() ) //Inverte o Estado
		
		IF ( lStatusDel )
	    	If ( nOpc == 3  )
				nRE1ItemOrd	:= RetOrdem( "RE1" , "RE1_FILIAL+RE1_COMAR+RE1_VARA" )
	    		RE1->( dbSetOrder( nRE1ItemOrd ) )
	    		IF !( lDelOk := ApdChkDel( cAlias , nRecno , nOpc , ( cCodigo + GdFieldGet( "RE1_VARA" ) ) , .F. , NIL , NIL , NIL , NIL , .T. ) )
					
					CursorArrow()
					//"A chave a ser excluida est═ sendo utilizada."
					//"At┌ que as refer┬ncias a ela sejam eliminadas a mesma n└o pode ser excluida."
					MsgInfo( OemToAnsi( STR0007 + CRLF + STR0008 ) , cCadastro )
	    			
	    			Break
	    		EndIF
	    	EndIF
    	EndIf
		
		Break
	EndIF
	
	lStatusDel	:= !( GdDeleted() ) //Inverte o Estado
	
	IF ( lStatusDel )	//Deletar
    	If ( nOpc == 3  )
			nRE1ItemOrd	:= RetOrdem( "RE1" , "RE1_FILIAL+RE1_COMAR+RE1_VARA" )
    		RE1->( dbSetOrder( nRE1ItemOrd ) )
    		IF !( lDelOk := ApdChkDel( cAlias , nRecno , nOpc , ( cCodigo + GdFieldGet( "RE1_VARA" ) ) , .F. , NIL , NIL , NIL , NIL , .T. ) )
				CursorArrow()
				//"A chave a ser excluida est═ sendo utilizada."
				//"At┌ que as refer┬ncias a ela sejam eliminadas a mesma n└o pode ser excluida."
				MsgInfo( OemToAnsi( STR0007 + CRLF + STR0008 ) , cCadastro )
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
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁAPTA060Grava ЁAutorЁTania Bronzeri        Ё Data Ё11/05/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA060()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function APTA060Grava(	nOpcy		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( REC )
							 	aRE1Header	,;	//Campos do Arquivo Filho ( RE1 )
							 	aRE1Cols	,;	//Itens Atual do Arquivo Filho ( RE1 )
							 	aSvRE1Cols	,;	//Itens Anterior do Arquivo Filho ( RD2 )
							 	aRE1VirtGd	,;	//Campos Virtuais do Arquivo Filho ( RE1 )
							 	aRE1Recnos	,;	//Recnos do Arquivo Filho ( RE1 )
							 	aRE1MemoGd	 ;	//Campos Memo na GetDados ( RE1 )
							  )

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis de Inicializacao Obrigatoria					  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aMestre	:= GdPutIStrMestre( 01 )
Local aItens	:= {}
//Local cOpcao	:= IF( ( nOpcy == 5 ) , "DELETE" , IF( ( ( nOpcy == 3 ) .or. ( nOpcy == 4 ) ) , "PUT" , NIL ) )
Local cOpcao	:= IF( ( nOpcy == 4) , "DELETE" , IF( ( ( nOpcy == 3 ) ) , "PUT" , NIL ) )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carrega os Itens Apenas se Houveram Alteracoes ou na ExclusaoЁ
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
//	IF ( ( nOpc == 5 ) .or. !( fCompArray( aRE1Cols , aSvRE1Cols ) ) )
	IF ( ( nOpcy == 4 ) .or. !( fCompArray( aRE1Cols , aSvRE1Cols ) ) )

		aItens := GdPutIStrItens( 01 )
		
		aItens[ 01 , 01 ] := "RE1"
		aItens[ 01 , 02 ] := {;
								{ "FILIAL" , xFilial( "RE1" , xFilial( "REC" ) ) },;
								{ "COMAR" , GetMemVar( "REC_CODIGO" ) };
							 }
		aItens[ 01 , 03 ] := aClone( aRE1Header )
		aItens[ 01 , 04 ] := aClone( aRE1Cols   )
		aItens[ 01 , 05 ] := aClone( aRE1VirtGd )
		aItens[ 01 , 06 ] := aClone( aRE1Recnos )
		aItens[ 01 , 07 ] := aClone( aRE1MemoGd )
		aItens[ 01 , 08 ] := NIL
//		aItens[ 01 , 10 ] := "RE6"

	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
	Ё se foi Selecionada a Exclusao								   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	aMestre[ 01 , 01 ]	:= "REC"
	aMestre[ 01 , 02 ]	:= nReg
	aMestre[ 01 , 03 ]	:= .F.
	aMestre[ 01 , 04 ]	:= NIL
	aMestre[ 01 , 05 ]	:= NIL
	aMestre[ 01 , 06 ]	:= {}
	aMestre[ 01 , 07 ]	:= aClone( aItens )
	
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Grava as Informacoes  / 4╨ Parametro : Se executarА o Sort no aCols Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	GdPutInfoData( aMestre , cOpcao , , .F. )

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Confirmando a Numeracao Automatica          				   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( nOpcy == 3 )
		While ( GetSX8Len() > nGetSX8Len )
			ConfirmSX8()
		End While
	EndIF

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( NIL )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁGdRE1Seek	 ЁAutorЁTania Bronzeri        Ё Data Ё11/05/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁEfetuar Pesquisa na GetDados                               	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA060                                                		Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function GdRE1Seek( oGdRE1 )

Local aSvKeys 		:= GetKeys()
Local cProcName3	:= Upper( AllTrim( ProcName( 3 ) ) )
Local cProcName5	:= Upper( AllTrim( ProcName( 5 ) ) )

Begin Sequence

	IF !( "APTA060MNT" $ ( cProcName3 + cProcName5 ) )
		Break
	EndIF

	GdSeek( oGdRE1 , OemToAnsi( STR0001 ) )	//"Pesquisar"
	
End Sequence

RestKeys( aSvKeys , .T. )

Return( NIL )

/*
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддддбддддбдддддддддд©
ЁFun┤┘o    ЁRe1SxbFilterЁAutorЁTania Bronzeri           ЁDataЁ19/05/2004Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддддаддддадддддддддд╢
ЁDescri┤┘o ЁFiltro de Consulta Padrao para o RE1						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁConsulta Padrao (SXB)				                  	   	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Function Re1SxbFilter()
         
Local cReadVar	:= Upper( AllTrim( ReadVar() ) )
Local cRet		:= ""

//RE1 = Cadastro de Varas
IF ( "RE0_COMAR" $ cReadVar )
	IF ( IsInGetDados( { "RE0_COMAR" } ) )
		cRet := "@#RE1->RE1_COMAR=='"+GdFieldGet("RE0_COMAR")+"'@#"
	EndIF
ElseIF ( "RE0_VARA" $ cReadVar )
	cRet := "@#RE1->RE1_COMAR=='" + GdFieldGet("RE0_COMAR") + "'@#"
Else
//...codigo semelhante ao acima...
EndIF
                                                          
Return( cRet )     

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммямммммммммммммммммммкммммммямммммммммммм╩╠╠
╠╠╨Funcao    ЁApt060VaraInc ╨ Autor Ё TANIA BRONZERI    ╨ Data Ё 16/09/2004 ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммомммммммммммммммммммйммммммомммммммммммм╧╠╠
╠╠╨Descricao Ё Inclusao de varas Atraves do F3                              ╨╠╠
╠╠╨          Ё                                                              ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SXB => F3 Inclusao                                           ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function Apt060VaraInc( cALIAS , nREG )
                            
Local cComar	:=	M->RE0_COMAR
Local lHaVaras	:=	.F.
Default nReg	:=	REC->( Recno() )

IF !Empty(cComar)
	lHaVaras	:= RE1->(DBSeek(xFilial("RE1")+cComar)) 
	IF !(lHaVaras) .And. IsInCallStack("Apt060VaraInc")
		lHaVaras :=	REC->(DBSeek(xFilial("REC")+cComar ) )
		nReg	:=	IF( lHaVaras , REC->( Recno() ) , nReg )
		APTA060Inc("REC",nReg,3,.T.,,.F.)  
	EndIF
Else
	Aviso(STR0011, STR0012, { "OK" } ) // "Atencao!"###"Nao foi informada uma Comarca Valida. Informe a Comarca antes da Inclusao da Vara."
EndIF


Return Nil

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Luiz Gustavo     Ё Data Ё19/12/2006Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁAPTA060                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   

Static Function MenuDef()

 Local aRotina := {;
								{ STR0002 , "AxPesqui"	 , 0 , 01,,.F. } ,; //"Pesquisar"
								{ STR0003 , "APTA060MNT" , 0 , 02 } ,; //"Visualizar"
								{ STR0005 , "APTA060MNT" , 0 , 04 } ,; //"Atualizar"
								{ STR0006 , "APTA060MNT" , 0 , 05 }  ; //"Excluir"
							}
Return aRotina


/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё PermtExcl		ЁAutorЁ  Oswaldo L        Ё Data Ё19/12/2017Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁEfetua consitЙncias para permitir excluir ou nao           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁAPTA060                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   

Static Function PermtExcl( aRE1Header,aRE1Cols)
Local lRet := .T.
Local nLoop
Local nLoops
Local nOpcAtual 
Local nIndRecno
Local nRE1ItemOrd
Local aArea := GetArea()

nLoops	:= Len( aRE1Cols )

nIndRecno   := aScan( aRE1Header , { |x| x[2] == "RE1_REC_WT" } )
	
If	nIndRecno > 0 
	
	For nLoop := 1 To nLoops
		n := nLoop
		
		 	
		nRE1ItemOrd	:= RetOrdem( "RE1" , "RE1_FILIAL+RE1_COMAR+RE1_VARA" )
						
		RE1->( dbSetOrder( nRE1ItemOrd ) )
		nOpcAtual := 4//nesta tela especifica 4 <=> excluir
		
		IF !(  ApdChkDel( "RE1" , aRE1Cols[n][nIndRecno] , nOpcAtual , ( GetMemVar( "REC_CODIGO" ) +  GdFieldGet( "RE1_VARA" , n , .F. , aRE1Header , aRE1Cols )   ) , .F. , NIL , NIL , NIL , NIL , .T. ) )
							//"A chave a ser excluida est═ sendo utilizada."
							//"At┌ que as refer┬ncias a ela sejam eliminadas a mesma n└o pode ser excluida."
				MsgInfo( GdFieldGet( "RE1_VARA" , n , .F. , aRE1Header , aRE1Cols )  + ": " + OemToAnsi( STR0007 + CRLF + STR0008 ) , cCadastro )
				lRet := .F.
				return lRet
		EndIF
		
	Next n
	
EndIf
restArea(aArea)					  
return lRet



