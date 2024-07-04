#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONA400.CH"
   

/*/
зддддддддддбддддддддддбдддддбдддддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁPONA400   ЁAutorЁIgor Franzoi             Ё Data Ё30/10/07  Ё
цддддддддддеддддддддддадддддадддддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁManutencao de Horarios         								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё
цддддддддддддбддддддддддбдддддддддддбддддддддддддддддддддддддддддддддддд╢
ЁProgramador ЁData      ЁBOPS 	    ЁMotivo da Alteracao                Ё
цддддддддддддеддддддддддедддддддддддеддддддддддддддддддддддддддддддддддд╢
Ё            Ё          Ё           Ё                                   Ё
ЁIgor Franzoi| 30/10/07 Ё           Ё Criacao							Ё  
ЁMauricio MR | 06/12/07 ЁMelhoria   Ё Reformulacao					    Ё
ЁLeandro DR  | 12/12/07 ЁMelhoria   Ё Ajuste da enchoice 			    Ё
ЁGlaucia M.  Ё 07/07/11 Ё015529     ЁReadequacao das telas p/ diversas  Ё
Ё		     Ё          ЁSDTCW0     Ёresolucoes.					    Ё
юддддддддддддаддддддддддадддддддддддаддддддддддддддддддддддддддддддддддды/*/

Function PONA400( cAlias , nReg , nOpc , lExecAuto , nOpcNewGd )

Local aArea 	:= GetArea()
Local aAreaRF8	:= RF8->( GetArea() )
Local aAreaRF4	:= RF4->( GetArea() )
Local lExistOpc	:= ( ValType( nOpc ) == "N" )

Local bBlock
Local nPos

Begin Sequence

	
	
	// SС Executa se o Modo de Acesso dos Arquivos do Modulo PON estiverem OK
	IF !( ValidArqPon())
	   Break
	Endif

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁRedefine o Alias                                              Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	cAlias	:= "RF8"

    Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

	Private cCadastro   := OemToAnsi( STR0001 ) //"Cadastro de HorАrios"

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
			bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPos , 2 ] + "(a,b,c,d,e) }" )
			Eval( bBlock , cAlias , nReg , nPos )
		
		Else
		
			PONA400Mnt( cAlias , nReg , nOpc , .T. , nOpcNewGd )
		
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
RestArea( aAreaRF4 )
RestArea( aAreaRF8 )
RestArea( aArea	   )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura o Cursor do Mouse                				   	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( NIL )

/*/
зддддддддддбддддддддддддддбддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁInPONA400Exec ЁAutor ЁMauricio MR          Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддддаддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁExecutar Funcoes Dentro de PONA400                           Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁInPONA400Exec( cExecIn , aFormParam )						 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁuRet                                                 	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function InPONA400Exec( cExecIn , aFormParam )
         
Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= &( cExecIn )
EndIF

Return( uRet )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA400VisЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios( Visualizar )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA400Vis( cAlias , nReg , nOpcNewGd )
Return( PONA400( cAlias , nReg , 2 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA400IncЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios ( Incluir )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA400Inc( cAlias , nReg , nOpcNewGd )
Return( PONA400( cAlias , nReg , 3 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA400AltЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios( Alterar )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA400Alt( cAlias , nReg , nOpcNewGd  )
Return( PONA400( cAlias , nReg , 4 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA400DelЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios ( Excluir )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA400Del( cAlias , nReg  )
Return( PONA400( cAlias , nReg , 5 , NIL , 0 ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF4Visual ЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Itens de Horarios ( Visualizar )				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF4Visual( cAlias , nReg  )

SetMemoFields( cAlias , GetMemoDb( cAlias ) )
aRotSetOpc( cAlias , @nReg , 2 )

Return( AxVisual( cAlias, nReg , 2 ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA400MntЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios (Manutencao)							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA400()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA400Mnt( cAlias , nReg , nOpc , lDlgPadSiga , nOpcNewGd )

Local aArea			:= GetArea(Alias())
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}  
Local aDomingo		:= {}
Local aRF8Header	:= {}
Local aRF8Cols		:= {}
Local aSvRF8Cols	:= {}
Local aRF8Fields	:= {}
Local aRF8Altera	:= {}
Local aRF8NaoAlt	:= {}
Local aRF8VirtEn	:= {}
Local aRF8NotFields	:= {}
Local aRF8Recnos	:= {}
Local aRF8Keys		:= {}
Local aRF8VisuEn	:= {}
Local aRF4GdAltera  := {}
Local aRF4GdNaoAlt	:= {}
Local aRF4Recnos	:= {}
Local aRF4Keys		:= {}
Local aRF4NotFields	:= {}
Local aRF4VirtGd	:= {}
Local aRF4VisuGd	:= {}
Local aRF4Header	:= {}
Local aRF4Cols		:= {}
Local aSvRF4Cols	:= {}
Local aRF4ColsVazio := {}
Local aRF4Query		:= {}
Local aLog			:= {}
Local aLogTitle		:= {}
Local aLogGer		:= {}
Local aLogGerTitle	:= {}
Local bRF4GdDelOk	:= { |lDelOk| lDelOk := RF4GdDelOk(oGdRF4) , CursorArrow() , lDelOk }
Local bRF4TreeDelOk	:= { || .T. }
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local bDialogInit	:= { || NIL }
Local bRF4Sort		:= { || NIL }
Local bChange		:= { || NIL }
Local cSpaceJor		:= Space(TAMSX3("RF3_DESC")[1])
Local cDescJor		:= cSpaceJor
Local cRF8KeySeek	:= ""
Local cFilRF8		:= ""
Local cHorRF8		:= ""
Local cMsgYesNo		:= ""
Local cTitLog		:= ""
Local lLocks		:= .F.
Local lExecLock		:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
Local lExcGeraLog	:= .F.
Local nOpcAlt		:= 0
Local nRF8Usado		:= 0
Local nRF4Usado		:= 0
Local nLoop			:= 0
Local nLoops		:= 0
Local nField		:= 0
Local nRF4ItemOrd	:= RetOrdem( "RF4" , "RF4_FILIAL+RF4_HOR+RF4_DIA" )
Local nRF4PosItem	:= 0
Local nRF4MaxLocks	:= 10
Local nRF4GhostCol	:= 0
Local oDlg			:= NIL
Local oEnRF8		:= NIL
Local oGdRF4		:= NIL
Local oFont			:= NIL
Local oGroup		:= NIL
Local oPanel		:= NIL

Private aGets
Private aTela
Private bGetRF8
Private bGetRF4

Private nGetSX8Len := GetSX8Len()
Private oDescJor		:= NIL


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
		aRotSetOpc( cAlias , @nReg , nOpc )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta os Dados para a Enchoice							   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aRF8NotFields	:= { "RF8_FILIAL" }
		bGetRF8			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aRF8Keys := NIL ),;
											aRF8Cols := RF8->(;
																GdBuildCols(	@aRF8Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																				@nRF8Usado		,;	//02 -> Numero de Campos em Uso
																				@aRF8VirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																				@aRF8VisuEn		,;	//04 -> [@]Array com os Campos Visuais
																				"RF8"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																				aRF8NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																				@aRF8Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																				"RF8"		   	,;	//08 -> Alias do Arquivo Pai
																				NIL				,;	//09 -> Chave para o Posicionamento no Alias Filho
																				NIL				,;	//10 -> Bloco para condicao de Loop While
																				NIL				,;	//11 -> Bloco para Skip no Loop While
																				NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																				NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																				NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																				NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																				NIL				,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																				NIL				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																				NIL				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																				NIL				,;	//19 -> Carregar Coluna Fantasma
																				NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																				NIL				,;	//21 -> Verifica se Deve verificar se o campo eh usado
																				NIL				,;	//22 -> Verifica se Deve verificar o nivel do usuario
																				NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																				@aRF8Keys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																				@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																				@lExclu			 ;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		    );
															  ),;
											IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  					} 
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do RF8									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "RF8" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRF8 ) )
			Break
		EndIF
		CursorWait()
		aSvRF8Cols		:= aClone( aRF8Cols )
		cFilRF8			:= RF8->RF8_FILIAL
		cHorRF8			:= RF8->RF8_HOR
		cRF8KeySeek		:= ( cFilRF8 + cHorRF8 )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
		Ё quivo														   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1 To nRF8Usado
			SetMemVar( aRF8Header[ nLoop , 02 ] , aRF8Cols[ 01 , nLoop ] , .T. )
		Next nLoop

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁDefine os Campos Editaveis na Enchoice Apenas na Inclusao( 3 )Ё
		Ёou Alteracao(4)											   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )

			IF ( nOpc == 4 )
				aAdd( aRF8NaoAlt , "RF8_HOR"  )
				aAdd( aRF8NaoAlt , "RF8_FLAG" )
			EndIF

		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carregando campos Alteraveis e Editavies					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		MkArrEdFlds( nOpc , aRF8Header , aRF8VisuEn , aRF8VirtEn , @aRF8NaoAlt , @aRF8Altera , @aRF8Fields )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define os Campos que nao serao Carregados					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aRF4NotFields , "RF4_FILIAL"  )
		aAdd( aRF4NotFields , "RF4_HOR"  )
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta os Dados para a GetDados							   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		#IFDEF TOP
			aRF4Query		:= Array( 05 )
			aRF4Query[01]	:= "RF4_FILIAL='"+cFilRF8+"'"
			aRF4Query[02]	:= " AND "
			aRF4Query[03]	:= "RF4_HOR='"+cHorRF8+"'"
			aRF4Query[04]	:= " AND "
			aRF4Query[05]	:= "D_E_L_E_T_=' ' "
		#ENDIF
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Quando For Inclusao Posiciona o RF4 No Final do Arquivo	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 3  ) //Inclusao
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Garante que na Inclusao o Ponteiro do RF4 estara em Eof()    Ё 
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			PutFileInEof( "RF4" )
		EndIF
		RF4->( dbSetOrder( nRF4ItemOrd ) )
		bGetRF4	:= { |lLock,lExclu| IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aRF4Keys := NIL ),;
							 		aRF4Cols := RF4->(;
														GdBuildCols(	@aRF4Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																		@nRF4Usado		,;	//02 -> Numero de Campos em Uso
																		@aRF4VirtGd		,;	//03 -> [@]Array com os Campos Virtuais
																		@aRF4VisuGd		,;	//04 -> [@]Array com os Campos Visuais
																		"RF4"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																		aRF4NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																		@aRF4Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																		"RF8"		   	,;	//08 -> Alias do Arquivo Pai
																		cRF8KeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
																		NIL				,;	//10 -> Bloco para condicao de Loop While
																		NIL				,;	//11 -> Bloco para Skip no Loop While
																		NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																		NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																		NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																		NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																		aRF4Query		,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																		.F.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																		.F.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																		Altera			,;	//19 -> Carregar Coluna Fantasma
																		NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																		NIL				,;	//21 -> Verifica se Deve verificar se o campo eh usado
																		NIL				,;	//22 -> Verifica se Deve verificar o nivel do usuario
																		NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																		@aRF4Keys  		,;	//24 -> [@]Array que contera as chaves conforme recnos
																		@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																		@lExclu			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		nRF4MaxLocks	,;	//27 -> Numero maximo de Locks a ser efetuado
																		Altera			 ;	//28 -> Utiliza Numeracao na GhostCol
																    );
													  ),;
									IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  		    }
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do RF4									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "RF4" , NIL , NIL , 1 , 1 , .T. , nRF4MaxLocks , 5 , bGetRF4 ) )
			Break
		EndIF
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁColoca o Ponteiro do Mouse em Estado de Espera			 	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		CursorWait()

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁMonta Bloco para Sort antes da Gravacao					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( ( nRF4GhostCol := GdFieldPos( "GHOSTCOL" , aRF4Header ) ) > 0 )
			bRF4Sort := { |x,y| ( x[ nRF4GhostCol ] < y[ nRF4GhostCol ] ) }
		EndIF
        
        /*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Quando For Inclusao Posiciona o RF4 No Final do Arquivo	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 3  ) //Inclusao
			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Monta os Dados para a Enchoice							   Ё
			Ё aCols com 7 linhas										   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
 			aRF4ColsVazio:= aClone(aRF4Cols[1])
 			For nLoops := 1 To 7  
		    	IF (nLoops > 1) 
			    	aAdd( aRF4Cols, {})
			    	aRF4Cols[Len(aRF4Cols)] :=aClone(aRF4ColsVazio )
		 	    EndIF
		 	    aRF4Cols[Len(aRF4Cols), GDFIELDPOS("RF4_DIA",aRF4Header) ] := AllTrim( Str( nLoops ) )
			Next			
		EndIF
		                             
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Coloca o Domingo como o ultimo dia da semana a ser visualizado  Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aDomingo	:=	aClone(aRF4Cols[1]) 
		nLoop:=1 
		aEval(aRF4Cols,{|x,y|x:=aClone(aRF4Cols[  Min(y+1,Len(aRF4Cols) )   ])},1,6)
		aRF4Cols[7]	:=	aClone(aDomingo) 
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Salva o Conteudo do RF4aCols para comparacao na saida		   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aSvRF4Cols	:= aClone( aRF4Cols )
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega os Campos Editaveis para a GetDados				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1 To nRF4Usado
			SetMemVar( aRF4Header[ nLoop , 02 ] , GetValType( aRF4Header[ nLoop , 08 ] , aRF4Header[ nLoop , 04 ] ) , .T. )
		Next nLoop
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carregando campos Alteraveis e Editavies					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		MkArrEdFlds( nOpc , aRF4Header , aRF4VisuGd , aRF4VirtGd , @aRF4GdNaoAlt , @aRF4GdAltera )

		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁVerifica se Pode Efetuar a Delecao dos Registros			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 5 )
			IF !( ChkDelRegs(	 "RF8" 											,;	//01 -> Alias do Arquivo Principal
			 					nReg											,;  //02 -> Registro do Arquivo Principal
			 					nOpc 											,;  //03 -> Opcao para a AxDeleta
			 					cFilRF8											,;	//04 -> Filial do Arquivo principal para Delecao
			 					cHorRF8 									 	,;  //05 -> Chave do Arquivo Principal para Delecao
			 					NIL												,;  //06 -> Array contendo informacoes dos arquivos a serem pesquisados
			 					NIL 											,;  //07 -> Mensagem para MsgYesNo
				 				NIL							 					,;  //08 -> Titulo do Log de Delecao
			 					NIL		 										,;  //09 -> Mensagem para o corpo do Log
								.F.												,;	//10 -> Se executa AxDeleta
								.T.												,;	//11 -> Se deve Mostrar o Log					 					
		 						@aLog											,;	//12 -> Array com o Log de Exclusao
								@aLogTitle	 									,;	//13 -> Array com o Titulo do Log
								NIL		   										,;	//14 -> Bloco para Posicionamento no Arquivo
								NIL												,;	//15 -> Bloco para a Condicao While
								NIL												,;	//16 -> Bloco para Skip/Loop no While
								NIL												,;	//17 -> Verifica os Relacionamentos no SX9
								{'RF4'}											,;	//18 -> Alias que nao deverao ser Verificados no SX9
								NIL		 										;	//19 -> Se faz uma checagem soft
			 				);
			 	 )
				Break
			EndIF
		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta as Dimensoes dos Objetos         					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdvSize		:= MsAdvSize( )
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 040 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aAdd( aObjCoords , { 000 , 018, .T. , .F. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para a Tecla <CTRL-O> 						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bSet15		:= { || IF(; 
									(;
											( nOpc == 3 );	//Inclusao
											.or.;
											( nOpc == 4 );	//Alteracao
									 );					
									.and.;	
									PONA400TEncOk( nOpc , oEnRF8 );
									.and.;													//Valida Todos os Campos da Enchoice
								    oGdRF4:TudoOk();
									,;		
									(;
										nOpcAlt		:= 1 ,;
										aRF4Cols	:= oGdRF4:aCols,;						//Redireciona o Ponteiro do aRF4Cols
										RestKeys( aSvKeys , .T. ),;
										oDlg:End();
								 	),;
								 	IF(; 
								 		(;
								 			( nOpc == 3 );	//Inclusao 
								 			.or.;
								 			( nOpc == 4 );	//Alteracao
								 		) ,;				
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
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para a Teclas <CTRL-X>     	   			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bSet24		:= { || ( nOpcAlt := 0 , RestKeys( aSvKeys , .T. ) , oDlg:End() ) }
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para o Init do Dialog						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Restaura o Ponteiro do Cursor do Mouse                  	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorArrow()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta o Dialogo Principal para a Manutencao das Formulas	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0007 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL


	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto Enchoice para o RF8                      	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	
		oEnRF8	:= MsmGet():New(	cAlias		,;
									nReg		,;
									nOpc		,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRF8Fields	,;
									aObjSize[1] ,;
									aRF8Altera	,;
									NIL			,;
									NIL			,;
									NIL			,;
									oDlg		,;
									NIL			,;
									.F.			,;
									NIL			,;
									.F.			 ;
								)
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Valor DEFAULT nOpcNewGd									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		DEFAULT nOpcNewGd := IF( ( ( nOpc == 2 ) .or. ( nOpc == 5 ) ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto GetDados para o RF4						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	  	oGdRF4	:= MsNewGetDados():New(	aObjSize[2,1]												,;
										aObjSize[2,2]												,;
										aObjSize[2,3]												,;
										aObjSize[2,4]												,;
										nOpcNewGd													,;
										"RF4GdLinOk"												,;
										"RF4GdTudOk"												,;
										""															,;
										aRF4GdAltera												,;
										0															,;
										7															,; 
										NIL															,;
										NIL															,;
										bRF4GdDelOk													,;
										oDlg														,;
										aRF4Header													,;
										aRF4Cols													;
									  )
		
	
	oDescJor	:= TSay():New(aObjSize[3,1]+5, aObjSize[3,2]+5 , {||cSpaceJor},oDlg,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
    oGroup:= TGroup():New(aObjSize[3,1], aObjSize[3,2],aObjSize[3,3], aObjSize[3,4],'',oDlg,,,.T.)
    
    oGdRF4:bChange := { || (	oDescJor:cCaption := VerJorRF3(GDFIELDGET("RF4_JORN")),;
								Allwaystrue();
							);
					  }

	ACTIVATE MSDIALOG oDlg ON INIT 	EnchoiceBar( oDlg , bSet15 , bSet24  ) CENTERED


	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁQuando Confirmada a Opcao e Nao for Visualizacao Grava ou   ExЁ
	Ёclui as Informacoes do RF8 e RF4							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF( nOpcAlt == 1 )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Apenas se nao For Visualizacao              				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 		IF ( nOpc != 2 )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Gravando/Incluido ou Excluindo Informacoes do SRY/RF4        Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			MsAguarde(;
						{ ||;
								aSort( aRF4Cols , NIL , NIL , bRF4Sort ),;	//Sorteia as Informacoes do RF4 para Comparacao Antes da Gravacao
								PONA400Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 					nReg		,;	//Numero do Registro do Arquivo Pai ( RF8 )
							 					aRF8Header	,;	//Campos do Arquivo Pai ( RF8 )
							 					aRF8Cols	,;	//Conteudo Atual dos Campos do Arquivo Pai ( RF8 )
							 					aSvRF8Cols  ,;	//Conteudo Anterior dos Campos do Arquivo Pai ( RF8 )
							 					aRF8VirtEn	,;	//Campos Virtuais do Arquivo Pai ( RF8 )
							 					aRF4Header	,;	//Campos do Arquivo Filho ( RF4 )
							 					aRF4Cols	,;	//Itens Atual do Arquivo Filho ( RF4 )
							 					aSvRF4Cols	,;	//Itens Anterior do Arquivo Filho ( RF4 )
							 					aRF4VirtGd	,;	//Campos Virtuais do Arquivo Filho ( RF4 )
							 					aRF4Recnos	 ;	//Recnos do Arquivo Filho ( RF4 )
							  				);
						};
					)
		EndIF
	Else
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
FreeLocks( "RF8" , aRF8Recnos , .T. , aRF8Keys )
FreeLocks( "RF4" , aRF4Recnos , .T. , aRF4Keys )

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
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA400TEncOkЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁTudoOk para a Enchoice                                      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁPONA400TEncOk( nOpc , oEnRF8 )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA400()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function PONA400TEncOk( nOpc , oEnRF8 )

Local lTudoOk := .T.
                
IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )
	lTudoOk := EnchoTudOk( oEnRF8 )
EndIF

Return( lTudoOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF4GdLinOk	ЁAutorЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRF4GdLinOk( oBrowse )									    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA400()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF4GdLinOk( oBrowse )

Local aCposKey	:= {}
Local lLinOk	:= .T.

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

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
			aCposKey := GetArrUniqe( "RF4" )
			IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
				Break
			EndIF

			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Verifica Se o Campos Estao Devidamente Preenchidos		   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			aCposKey := GdObrigat( aHeader )
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
	Ё Evitar que os Inicializadores padroes sejam carregados indeviЁ
	Ё damente													   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	PutFileInEof( "RF4" )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( lLinOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF4GdTudOk	ЁAutorЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRF4GdTudOk( oBrowse )									   	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA400()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF4GdTudOk( oBrowse )

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
			IF !( lTudoOk := RF4GdLinOk( oBrowse ) )
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
ЁFun┤┘o    ЁRF4GdDelOk  ЁAutorЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidar a Delecao na GetDados                               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA400()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function RF4GdDelOk(oGet)
         
Local lDelOk 		:= .F.     

Return( lDelOk )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA400Grava ЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA400()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function PONA400Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( RF8 )
							 	aRF8Header	,;	//Campos do Arquivo Pai ( RF8 )
							 	aRF8Cols	,;	//Conteudo Atual dos Campos do Arquivo Pai ( RF8 )
							 	aSvRF8Cols  ,;	//Conteudo Anterior dos Campos do Arquivo Pai ( RF8 )
							 	aRF8VirtEn	,;	//Campos Virtuais do Arquivo Pai ( RF8 )
							 	aRF4Header	,;	//Campos do Arquivo Filho ( RF4 )
							 	aRF4Cols	,;	//Itens Atual do Arquivo Filho ( RF4 )
							 	aSvRF4Cols	,;	//Itens Anterior do Arquivo Filho ( RF4 )
							 	aRF4VirtGd	,;	//Campos Virtuais do Arquivo Filho ( RF4 )
							 	aRF4Recnos	 ;	//Recnos do Arquivo Filho ( RF4 )
							  )

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis de Inicializacao Obrigatoria					  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aMestre	:= GdPutIStrMestre( 01 )
Local aItens	:= {}
Local cOpcao	:= IF( ( nOpc == 5 ) , "DELETE" , IF( ( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) , "PUT" , NIL ) )
Local lAllModif	:= .F.
Local lRF8Modif	:= .F.
Local lRF4Modif	:= .F.
Local lRF4Delet	:= .F.

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis que serao inicializadas no Corpo da Funcao		  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aRF4ColDel
Local aRF4RecDel
Local nLoop
Local nLoops
Local nItens

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	IF ( cOpcao <> "DELETE" )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Verifica se Houveram Modificacoes no RF4					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( lRF4Modif := !ArrayCompare( aRF4Cols , aSvRF4Cols ) )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Deleto todos os Itens que nao Estao OK					   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			GdSuperDel( aRF4Header , @aRF4Cols , NIL , .T. , GdGetBlock( "RF4" , aRF4Header , .F. ) ) 
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Separa os Itens que foram Deletados     					   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			lRF4Delet := GdSplitDel( aRF4Header , @aRF4Cols , @aRF4Recnos , @aRF4ColDel , @aRF4RecDel  )
		EndIF
	Else
		lRF4Modif := .T.
		lRF8Modif := .T.
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carrega os Itens Apenas se Houveram Alteracoes ou na ExclusaoЁ
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( lRF4Modif )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega as Informacoes deletadas RF4                   	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( lRF4Delet )

			aAdd( aItens , GdPutIStrItens() )
			nItens := Len( aItens )
		
			aItens[ nItens , 01 ] := "RF4"
			aItens[ nItens , 02 ] := NIL
			aItens[ nItens , 03 ] := aClone( aRF4Header )
			aItens[ nItens , 04 ] := aClone( aRF4ColDel )
			aItens[ nItens , 05 ] := aClone( aRF4VirtGd )
			aItens[ nItens , 06 ] := aClone( aRF4RecDel )

		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega as Informacoes do RF4                   			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aItens , GdPutIStrItens() )
		nItens := Len( aItens )
		aItens[ nItens , 01 ] := "RF4"
		aItens[ nItens , 02 ] := {;
									{ "FILIAL" , xFilial( "RF4" , xFilial( "RF8" ) ) },;
									{ "HOR" , GetMemVar( "RF8_HOR" ) };
							 	 }
		aItens[ nItens , 03 ] := aClone( aRF4Header )
		aItens[ nItens , 04 ] := aClone( aRF4Cols   )
		aItens[ nItens , 05 ] := aClone( aRF4VirtGd )
		aItens[ nItens , 06 ] := aClone( aRF4Recnos )
		aItens[ nItens , 07 ] := {}

	EndIF

	IF !( lRF8Modif )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Atualiza aRF8Cols para Verificar se Houveram Alteracoes	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		nLoops := Len( aRF8Header )
		For nLoop := 1 To nLoops
			aRF8Cols[ 01 , nLoop ] := GetMemVar( aRF8Header[ nLoop , 02 ] )
		Next nLoop
		lRF8Modif := !( ArrayCompare( aRF8Cols , aSvRF8Cols ) )
	EndIF	

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
	Ё se foi Selecionada a Exclusao								   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 	lAllModif := ( ( lRF4Modif ) .or. ( lRF8Modif ) )

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Se Houveram Alteracoes, ou Exclusao efetua a Gravacao        Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( lAllModif )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
		Ё se foi Selecionada a Exclusao								   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aMestre[ 01 , 01 ]	:= "RF8"
		aMestre[ 01 , 02 ]	:= nReg
		aMestre[ 01 , 03 ]	:= lRF8Modif
		aMestre[ 01 , 04 ]	:= aClone( aRF8Header )
		aMestre[ 01 , 05 ]	:= aClone( aRF8VirtEn )
		aMestre[ 01 , 06 ]	:= {}
		aMestre[ 01 , 07 ]	:= aClone( aItens )
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Grava as Informacoes                        				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		GdPutInfoData( aMestre , cOpcao , .F. , .F. )
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Confirmando a Numeracao Automatica          				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
ЁFun┤┘o    ЁRF4CodigoVld ЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para Validar o Conteudo do Campo RF4_CODIGO          Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RF4_CODIGO                         	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF4CodigoVld()

Local lRF4CodigoOk := .T.

Begin Sequence

	IF !( lRF4CodigoOk := NaoVazio() )
		Break
	EndIF

	IF !( lRF4CodigoOk := ExistCpo( "RF8" ) )
    	Break
    EndIF

End Sequence

Return( lRF4CodigoOk )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁMauricio MR        Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA400                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   

Static Function MenuDef()
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define Array contendo as Rotinas a executar do programa      Ё
	Ё ----------- Elementos contidos por dimensao ------------     Ё
	Ё 1. Nome a aparecer no cabecalho                              Ё
	Ё 2. Nome da Rotina associada                                  Ё
	Ё 3. Usado pela rotina                                         Ё
	Ё 4. Tipo de Transa┤└o a ser efetuada                          Ё
	Ё    1 - Pesquisa e Posiciona em um Banco de Dados             Ё
	Ё    2 - Simplesmente Mostra os Campos                         Ё
	Ё    3 - Inclui registros no Bancos de Dados                   Ё
	Ё    4 - Altera o registro corrente                            Ё
	Ё    5 - Remove o registro corrente do Banco de Dados          Ё
	Ё    6 - Copiar                                                Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

 Local aRotina :=  {;
								{ STR0002 , "AxPesqui"	 , 0 , 01,,.F.} ,; //"Pesquisar"
								{ STR0003 , "PONA400Mnt" , 0 , 02 } 	,; //"Visualizar"
								{ STR0004 , "PONA400Mnt" , 0 , 03 } 	,; //"Incluir"
								{ STR0005 , "PONA400Mnt" , 0 , 04 } 	,; //"Alterar"
								{ STR0006 , "PONA400Mnt" , 0 , 05 } 	;  //"Excluir"
							}
Return aRotina

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё VerJorRF3		ЁAutorЁLeandro Drumond	  Ё Data Ё17/12/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRetorna a descriГЦo da jornada								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA400                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ё															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   
Static Function VerJorRF3(cJornada)

Local aAreaRF3	:= GetArea(Alias())
Local cKey
Local cRet		:= ""

If !Empty(cJornada)

	cKey		:= xFilial("RCH") + cJornada

	RF3->(dbSetOrder(1))
	
	RF3->(MsSeek(cKey))

	cRet := RF3->RF3_DESC  

	RestArea( aAreaRF3 )
EndIf

Return( cRet )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RF4JORVLD		ЁAutorЁLeandro Drumond	  Ё Data Ё17/12/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁVerifica existЙncia da jornada								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA400                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ё															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   
Function RF4JORVLD()
Local lRet := .F.

If (lRet := EXISTCPO("RF3"))
	oDescJor:cCaption := VerJorRF3(M->RF4_JORN)
EndIf

Return(lRet)