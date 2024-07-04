#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "PONA410.CH"
    



/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё PONA410  Ё Autor Ё Igor Franzoi          Ё Data Ё 30/10/07 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Manutencao Tipos de Dia									  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PONA410()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁLeandroDR   Ё11/12/07ЁMelhorЁAlteraГЦo completa do fonte baseado no    Ё╠╠
╠╠Ё			   |	    |      |pona400				                      Ё╠╠
╠╠ЁLeandroDR   Ё18/09/08Ё154195ЁIncluido AJUSTASX3 para corrigir VALID do Ё╠╠
╠╠Ё			   |	    |      |campo RF5_CODREF                          Ё╠╠
╠╠ЁGlaucia M.  Ё07/07/11Ё015529ЁReadequacao das telas para diversas		  Ё╠╠
╠╠Ё			   Ё        ЁSDTCW0Ёresolucoes.								  Ё╠╠
╠╠ЁCМcero AlvesЁ04/03/15Ё	   ЁRetirada da funГЦo 	AjustaSx3			  Ё╠╠
╠╠Ё			   Ё        Ё	   Ё								 		  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/




Function PONA410( Alias , nReg , nOpc , lExecAuto , nOpcNewGd )

Local aArea 	:= GetArea()
Local aAreaRF9	:= RF9->( GetArea() )
Local aAreaRF5	:= RF5->( GetArea() )
Local lExistOpc	:= ( ValType( nOpc ) == "N" )

Local bBlock
Local nPos

Begin Sequence

	
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁSo Executa se o Modo de Acesso dos Arquivos do Modulo PON estiЁ
	Ёverem OK													   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !( ValidArqPon())
	   Break
	Endif

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁRedefine o Alias                                              Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	cAlias	:= "RF9"

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
		
			PONA410Mnt( cAlias , nReg , nOpc , .T. , nOpcNewGd )
		
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
RestArea( aAreaRF5 )
RestArea( aAreaRF9 )
RestArea( aArea	   )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura o Cursor do Mouse                				   	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( NIL )

/*/
зддддддддддбддддддддддддддбддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁInPONA410Exec ЁAutor ЁMauricio MR          Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддддаддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁExecutar Funcoes Dentro de PONA410                           Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁInPONA410Exec( cExecIn , aFormParam )						 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁuRet                                                 	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function InPONA410Exec( cExecIn , aFormParam )
         
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
ЁFun┤┘o    ЁPONA410VisЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios( Visualizar )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA410Vis( cAlias , nReg , nOpcNewGd )
Return( PONA410( cAlias , nReg , 2 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA410IncЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios ( Incluir )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA410Inc( cAlias , nReg , nOpcNewGd )
Return( PONA410( cAlias , nReg , 3 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA410AltЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios( Alterar )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA410Alt( cAlias , nReg , nOpcNewGd  )
Return( PONA410( cAlias , nReg , 4 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA410DelЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios ( Excluir )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA410Del( cAlias , nReg  )
Return( PONA410( cAlias , nReg , 5 , NIL , 0 ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF5Visual ЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Itens de Horarios ( Visualizar )				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF5Visual( cAlias , nReg  )

SetMemoFields( cAlias , GetMemoDb( cAlias ) )
aRotSetOpc( cAlias , @nReg , 2 )

Return( AxVisual( cAlias, nReg , 2 ) )


/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA410MntЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios (Manutencao)							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA410()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA410Mnt( cAlias , nReg , nOpc , lDlgPadSiga , nOpcNewGd )

Local aArea			:= GetArea(Alias())
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}  
Local aDomingo		:= {}
Local aRF9Header	:= {}
Local aRF9Cols		:= {}
Local aSvRF9Cols	:= {}
Local aRF9Fields	:= {}
Local aRF9Altera	:= {}
Local aRF9NaoAlt	:= {}
Local aRF9VirtEn	:= {}
Local aRF9NotFields	:= {}
Local aRF9Recnos	:= {}
Local aRF9Keys		:= {}
Local aRF9VisuEn	:= {}
Local aRF5GdAltera  := {}
Local aRF5GdNaoAlt	:= {}
Local aRF5Recnos	:= {}
Local aRF5Keys		:= {}
Local aRF5NotFields	:= {}
Local aRF5VirtGd	:= {}
Local aRF5VisuGd	:= {}
Local aRF5Header	:= {}
Local aRF5Cols		:= {}
Local aSvRF5Cols	:= {}
Local aRF5ColsVazio := {}
Local aRF5Query		:= {}
Local aLog			:= {}
Local aLogTitle		:= {}
Local aLogGer		:= {}
Local aLogGerTitle	:= {}
Local bRF5GdDelOk	:= { |lDelOk| lDelOk := RF5GdDelOk() , CursorArrow() , lDelOk }
Local bRF5TreeDelOk	:= { || .T. }
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local bRF5Sort		:= { || NIL }
Local bChange		:= { || NIL }
Local cRF9KeySeek	:= ""
Local cFilRF9		:= ""
Local cTipRF9		:= ""
Local cMsgYesNo		:= ""
Local cTitLog		:= ""
Local cDia			:= ""
Local lLocks		:= .F.
Local lExecLock		:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
Local lExcGeraLog	:= .F.
Local nOpcAlt		:= 0
Local nRF9Usado		:= 0
Local nRF5Usado		:= 0
Local nLoop			:= 0
Local nLoops		:= 0
Local nRF5ItemOrd	:= RetOrdem( "RF5" , "RF5_FILIAL+RF5_DIA+RF5_TIPO" )
Local nRF5PosItem	:= 0
Local nRF5MaxLocks	:= 10
Local nRF5GhostCol	:= 0
Local nCol	    	:= 0
Local nField    	:= 0
Local oDlg			:= NIL
Local oEnRF9		:= NIL
Local oGdRF5		:= NIL
Local oGroup		:= NIL

Private aGets
Private aHeader 	:= {}
Private aCols		:= {}
Private bGetRF9
Private bGetRF5

Private nGetSX8Len := GetSX8Len()

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
		aRF9NotFields	:= { "RF9_FILIAL" }
		bGetRF9			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aRF9Keys := NIL ),;
											aRF9Cols := RF9->(;
																GdBuildCols(	@aRF9Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																				@nRF9Usado		,;	//02 -> Numero de Campos em Uso
																				@aRF9VirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																				@aRF9VisuEn		,;	//04 -> [@]Array com os Campos Visuais
																				"RF9"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																				aRF9NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																				@aRF9Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																				"RF9"		   	,;	//08 -> Alias do Arquivo Pai
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
																				@aRF9Keys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																				@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																				@lExclu			 ;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		    );
															  ),;
											IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  					} 
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do RF9									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "RF9" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRF9 ) )
			Break
		EndIF

		CursorWait()

		aSvRF9Cols		:= aClone( aRF9Cols )
		cFilRF9			:= RF9->RF9_FILIAL
		cTipRF9			:= RF9->RF9_TIPO
		cRF9KeySeek		:= ( cFilRF9 + cTipRF9 )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
		Ё quivo														   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1 To nRF9Usado
			SetMemVar( aRF9Header[ nLoop , 02 ] , aRF9Cols[ 01 , nLoop ] , .T. )
		Next nLoop

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁDefine os Campos Editaveis na Enchoice Apenas na Inclusao( 3 )Ё
		Ёou Alteracao(4)											   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )

			IF ( nOpc == 4 )
				aAdd( aRF9NaoAlt , "RF9_TIPO"  )
				aAdd( aRF9NaoAlt , "RF9_FLAG" )
			EndIF

		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carregando campos Alteraveis e Editavies					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		MkArrEdFlds( nOpc , aRF9Header , aRF9VisuEn , aRF9VirtEn , @aRF9NaoAlt , @aRF9Altera , @aRF9Fields )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define os Campos que nao serao Carregados					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aRF5NotFields , "RF5_FILIAL"  )
		aAdd( aRF5NotFields , "RF5_TIPO"  )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta os Dados para a GetDados							   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		#IFDEF TOP
			aRF5Query		:= Array( 05 )
			aRF5Query[01]	:= "RF5_FILIAL='"+cFilRF9+"'"
			aRF5Query[02]	:= " AND "
			aRF5Query[03]	:= "RF5_TIPO='"+cTipRF9+"'"
			aRF5Query[04]	:= " AND "
			aRF5Query[05]	:= "D_E_L_E_T_=' ' "
		#ENDIF
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Quando For Inclusao Posiciona o RF5 No Final do Arquivo	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 3  ) //Inclusao
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Garante que na Inclusao o Ponteiro do RF5 estara em Eof()    Ё 
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			PutFileInEof( "RF5" )
		EndIF
		RF5->( dbSetOrder( nRF5ItemOrd ) )
		bGetRF5	:= { |lLock,lExclu| IF( lExecLock , ( lLock := .T. , lExclu := .T. ) , aRF5Keys := NIL ),; 
					  		 		aRF5Cols := RF5->(;
														GdBuildCols(	@aRF5Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																		@nRF5Usado		,;	//02 -> Numero de Campos em Uso
																		@aRF5VirtGd		,;	//03 -> [@]Array com os Campos Virtuais
																		@aRF5VisuGd		,;	//04 -> [@]Array com os Campos Visuais
																		"RF5"			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																		aRF5NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																		@aRF5Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																		"RF9"		   	,;	//08 -> Alias do Arquivo Pai
																		cRF9KeySeek		,;	//09 -> Chave para o Posicionamento no Alias Filho
																		NIL				,;	//10 -> Bloco para condicao de Loop While
																		NIL				,;	//11 -> Bloco para Skip no Loop While
																		NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																		NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																		NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																		NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																		aRF5Query		,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																		.F.				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																		.F.				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																		Altera			,;	//19 -> Carregar Coluna Fantasma
																		NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																		NIL				,;	//21 -> Verifica se Deve verificar se o campo eh usado
																		NIL				,;	//22 -> Verifica se Deve verificar o nivel do usuario
																		NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																		@aRF5Keys  		,;	//24 -> [@]Array que contera as chaves conforme recnos
																		@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																		@lExclu			,;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		nRF5MaxLocks	,;	//27 -> Numero maximo de Locks a ser efetuado
																		Altera			 ;	//28 -> Utiliza Numeracao na GhostCol
																    );
													  ),;        
									IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  		    }                                           
		  		    
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do RF5									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "RF5" , NIL , NIL , 1 , 1 , .T. , nRF5MaxLocks , 5 , bGetRF5 ) )
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
		IF ( ( nRF5GhostCol := GdFieldPos( "GHOSTCOL" , aRF5Header ) ) > 0 )
			bRF5Sort := { |x,y| ( x[ nRF5GhostCol ] < y[ nRF5GhostCol ] ) }
		EndIF		  		    
        /*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Quando For Inclusao Posiciona o RF5 No Final do Arquivo	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 3  ) //Inclusao

			/*
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Monta os Dados para a Enchoice							   Ё
			Ё aCols com 7 linhas										   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/  
 			aRF5ColsVazio:= aClone(aRF5Cols[1])
 			aRF5Cols 	 := {} 
 			For nLoops := 1 To 7  
    			aAdd( aRF5Cols, {} )
	    		cDia := AllTrim( Str( nLoops ) ) 
		 		For nField := 1 To len ( aRF5Header )
					IF ( aScan( aRF5NotFields , aRF5Header[ nField , 02 ] ) == 0 )
						If aRF5Header[ nField, 02 ] == "RF5_DIA"
							aAdd( aRF5Cols[nLoops], {} )
							aRF5Cols[ nLoops, nfield ] := cDia
						ElseIF aRF5Header[ nField, 02 ] == "RF5_TPDIA" 
							aAdd( aRF5Cols[nLoops], {} )
			
							If cDia == "1"
								aRF5Cols[ nLoops, nfield ] :=  "D" 						
							ElseIF   cDia == "7"
								aRF5Cols[ nLoops, nfield ] :=  "C" 						
							Else                                                        
								aRF5Cols[ nLoops, nfield ] :=  "S" 												
							Endif  						   
				
						Else
							aAdd( aRF5Cols[nLoops], {} )
							If aRF5Header[ nField, 02] == "RF5_ALI_WT"
								aRF5Cols[ nLoops, nfield ] := "RF5"
							ElseIf aRF5Header[ nField, 02] == "RF5_REC_WT"
								aRF5Cols[ nLoops, nfield ] := ""
							Else
								aRF5Cols[ nLoops, nfield ] := CriaVar( aRF5Header[ nField, 02] )
							EndIf 
						EndIf
					EndIf
				Next
			Next

			For nLoops := 1 To Len(aRF5Cols)
		  		aAdd( aRF5Cols[nLoops], .T. )
		  		GdFieldPut( "GDDELETED" , .F. , nLoops , aRF5Header , @aRF5Cols )
			Next
	    EndIF
		                             
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Coloca o Domingo como o ultimo dia da semana a ser visualizado  Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aDomingo	:=	aClone(aRF5Cols[1]) 
		nLoop:=1
		aEval(aRF5Cols,{|x,y|x:=aClone(aRF5Cols[y+1])},1,6)
		aRF5Cols[7]	:=	aClone(aDomingo) 
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Salva o Conteudo do RF5aCols para comparacao na saida		   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aSvRF5Cols	:= aClone( aRF5Cols )
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega os Campos Editaveis para a GetDados				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1 To nRF5Usado
			SetMemVar( aRF5Header[ nLoop , 02 ] , GetValType( aRF5Header[ nLoop , 08 ] , aRF5Header[ nLoop , 04 ] ) , .T. )
		Next nLoop
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carregando campos Alteraveis e Editavies					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		MkArrEdFlds( nOpc , aRF5Header , aRF5VisuGd , aRF5VirtGd , @aRF5GdNaoAlt , @aRF5GdAltera )

		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁVerifica se Pode Efetuar a Delecao dos Registros			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 5 )		
			IF !( ChkDelRegs(	 "RF9" 											,;	//01 -> Alias do Arquivo Principal
			 					 nReg											,;  //02 -> Registro do Arquivo Principal
				 				 nOpc 											,;  //03 -> Opcao para a AxDeleta
				 				 cFilRF9										,;	//04 -> Filial do Arquivo principal para Delecao
								 cTipRF9 									 	,;  //05 -> Chave do Arquivo Principal para Delecao
				 				 NIL											,;  //06 -> Array contendo informacoes dos arquivos a serem pesquisados
				 				 NIL 											,;  //07 -> Mensagem para MsgYesNo
					 			 NIL							 				,;  //08 -> Titulo do Log de Delecao
				 				 NIL		 									,;  //09 -> Mensagem para o corpo do Log
								 .F.											,;	//10 -> Se executa AxDeleta
								 .T.											,;	//11 -> Se deve Mostrar o Log					 					
			 					 @aLog											,;	//12 -> Array com o Log de Exclusao
								 @aLogTitle	 									,;	//13 -> Array com o Titulo do Log
   								 NIL		   									,;	//14 -> Bloco para Posicionamento no Arquivo
								 NIL											,;	//15 -> Bloco para a Condicao While
								 NIL											,;	//16 -> Bloco para Skip/Loop no While
								 NIL											,;	//17 -> Verifica os Relacionamentos no SX9
								 {'RF5'}										,;	//18 -> Alias que nao deverao ser Verificados no SX9
								 NIL		 									;	//19 -> Se faz uma checagem soft
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
									PONA410TEncOk( nOpc , oEnRF9 );
									.and.;													//Valida Todos os Campos da Enchoice
									IF(;
										!ArrayCompare( aSvRF5Cols , oGdRF5:aCols ),;
										oGdRF5:TudoOk(),;									//Valida as Informacoes da GetDados
										.T.;
									  ),;		
									(;
										nOpcAlt		:= 1 ,;
										aRF5Cols	:= oGdRF5:aCols,;						//Redireciona o Ponteiro do aRF5Cols
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
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0007 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL


		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto Enchoice para o RF9                      	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		
		oEnRF9	:= MsmGet():New(	cAlias		,;
									nReg		,;
									nOpc		,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRF9Fields	,;
									aObjSize[1] ,;
									aRF9Altera	,;
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
		Ё Monta o Objeto GetDados para o RF5						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	  	oGdRF5	:= MsNewGetDados():New(	aObjSize[2,1]											,;
										aObjSize[2,2]												,;
										aObjSize[2,3]												,;
										aObjSize[2,4]												,;
										nOpcNewGd													,;
										"RF5GdLinOk"												,;
										"RF5GdTudOk"												,;
										""															,;
										aRF5GdAltera												,;
										0															,;
										7															,; 
										NIL															,;
										NIL															,;
										bRF5GdDelOk													,;
										oDlg														,;
										aRF5Header													,;
										aRF5Cols													;
									  )
									   
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24  ) CENTERED


	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁQuando Confirmada a Opcao e Nao for Visualizacao Grava ou   ExЁ
	Ёclui as Informacoes do RF9 e RF5							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF( nOpcAlt == 1 )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Apenas se nao For Visualizacao              				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 		IF ( nOpc != 2 )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Gravando/Incluido ou Excluindo Informacoes do SRY/RF5        Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			MsAguarde(;
						{ ||;
								aSort( aRF5Cols , NIL , NIL , bRF5Sort ),;	//Sorteia as Informacoes do RF5 para Comparacao Antes da Gravacao
								PONA410Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 					nReg		,;	//Numero do Registro do Arquivo Pai ( RF9 )
							 					aRF9Header	,;	//Campos do Arquivo Pai ( RF9 )
							 					aRF9Cols	,;	//Conteudo Atual dos Campos do Arquivo Pai ( RF9 )
							 					aSvRF9Cols  ,;	//Conteudo Anterior dos Campos do Arquivo Pai ( RF9 )
							 					aRF9VirtEn	,;	//Campos Virtuais do Arquivo Pai ( RF9 )
							 					aRF5Header	,;	//Campos do Arquivo Filho ( RF5 )
							 					aRF5Cols	,;	//Itens Atual do Arquivo Filho ( RF5 )
							 					aSvRF5Cols	,;	//Itens Anterior do Arquivo Filho ( RF5 )
							 					aRF5VirtGd	,;	//Campos Virtuais do Arquivo Filho ( RF5 )
							 					aRF5Recnos	 ;	//Recnos do Arquivo Filho ( RF5 )
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
FreeLocks( "RF9" , aRF9Recnos , .T. , aRF9Keys )
FreeLocks( "RF5" , aRF5Recnos , .T. , aRF5Keys )

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
ЁFun┤┘o    ЁPONA410TEncOkЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁTudoOk para a Enchoice                                      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁPONA410TEncOk( nOpc , oEnRF9 )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA410()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function PONA410TEncOk( nOpc , oEnRF9 )

Local lTudoOk := .T.
                
IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )
	lTudoOk := EnchoTudOk( oEnRF9 )
EndIF

Return( lTudoOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF5GdLinOk	ЁAutorЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRF5GdLinOk( oBrowse )									    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA410()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF5GdLinOk( oBrowse )

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
			aCposKey := GetArrUniqe( "RF5" )
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
	PutFileInEof( "RF5" )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( lLinOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF5GdTudOk	ЁAutorЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRF5GdTudOk( oBrowse )									   	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA410()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF5GdTudOk( oBrowse )

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
			IF !( lTudoOk := RF5GdLinOk( oBrowse ) )
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
ЁFun┤┘o    ЁRF5GdDelOk  ЁAutorЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidar a Delecao na GetDados                               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA410()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function RF5GdDelOk()
         
Local lDelOk 		:= .F.

Return( lDelOk )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA410Grava ЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA410()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function PONA410Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( RF9 )
							 	aRF9Header	,;	//Campos do Arquivo Pai ( RF9 )
							 	aRF9Cols	,;	//Conteudo Atual dos Campos do Arquivo Pai ( RF9 )
							 	aSvRF9Cols  ,;	//Conteudo Anterior dos Campos do Arquivo Pai ( RF9 )
							 	aRF9VirtEn	,;	//Campos Virtuais do Arquivo Pai ( RF9 )
							 	aRF5Header	,;	//Campos do Arquivo Filho ( RF5 )
							 	aRF5Cols	,;	//Itens Atual do Arquivo Filho ( RF5 )
							 	aSvRF5Cols	,;	//Itens Anterior do Arquivo Filho ( RF5 )
							 	aRF5VirtGd	,;	//Campos Virtuais do Arquivo Filho ( RF5 )
							 	aRF5Recnos	 ;	//Recnos do Arquivo Filho ( RF5 )
							  )

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis de Inicializacao Obrigatoria					  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aMestre	:= GdPutIStrMestre( 01 )
Local aItens	:= {}
Local cOpcao	:= IF( ( nOpc == 5 ) , "DELETE" , IF( ( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) , "PUT" , NIL ) )
Local lAllModif	:= .F.
Local lRF9Modif	:= .F.
Local lRF5Modif	:= .F.
Local lRF5Delet	:= .F.

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis que serao inicializadas no Corpo da Funcao		  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aRF5ColDel
Local aRF5RecDel
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
		Ё Verifica se Houveram Modificacoes no RF5					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( lRF5Modif := !ArrayCompare( aRF5Cols , aSvRF5Cols ) )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Deleto todos os Itens que nao Estao OK					   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			GdSuperDel( aRF5Header , @aRF5Cols , NIL , .T. , GdGetBlock( "RF5" , aRF5Header , .F. ) ) 
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Separa os Itens que foram Deletados     					   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			lRF5Delet := GdSplitDel( aRF5Header , @aRF5Cols , @aRF5Recnos , @aRF5ColDel , @aRF5RecDel  )
		EndIF
	Else
		lRF5Modif := .T.
		lRF9Modif := .T.
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carrega os Itens Apenas se Houveram Alteracoes ou na ExclusaoЁ
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( lRF5Modif )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega as Informacoes deletadas RF5                   	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( lRF5Delet )

			aAdd( aItens , GdPutIStrItens() )
			nItens := Len( aItens )
		
			aItens[ nItens , 01 ] := "RF5"
			aItens[ nItens , 02 ] := NIL
			aItens[ nItens , 03 ] := aClone( aRF5Header )
			aItens[ nItens , 04 ] := aClone( aRF5ColDel )
			aItens[ nItens , 05 ] := aClone( aRF5VirtGd )
			aItens[ nItens , 06 ] := aClone( aRF5RecDel )

		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega as Informacoes do RF5                   			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aItens , GdPutIStrItens() )
		nItens := Len( aItens )
		aItens[ nItens , 01 ] := "RF5"
		aItens[ nItens , 02 ] := {;
									{ "FILIAL" , xFilial( "RF5" , xFilial( "RF9" ) ) },;
									{ "TIPO" , GetMemVar( "RF9_TIPO" ) };
							 	 }
		aItens[ nItens , 03 ] := aClone( aRF5Header )
		aItens[ nItens , 04 ] := aClone( aRF5Cols   )
		aItens[ nItens , 05 ] := aClone( aRF5VirtGd )
		aItens[ nItens , 06 ] := aClone( aRF5Recnos )
		aItens[ nItens , 07 ] := {}

	EndIF

	IF !( lRF9Modif )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Atualiza aRF9Cols para Verificar se Houveram Alteracoes	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		nLoops := Len( aRF9Header )
		For nLoop := 1 To nLoops
			aRF9Cols[ 01 , nLoop ] := GetMemVar( aRF9Header[ nLoop , 02 ] )
		Next nLoop
		lRF9Modif := !( ArrayCompare( aRF9Cols , aSvRF9Cols ) )
	EndIF	

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
	Ё se foi Selecionada a Exclusao								   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 	lAllModif := ( ( lRF5Modif ) .or. ( lRF9Modif ) )

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
		aMestre[ 01 , 01 ]	:= "RF9"
		aMestre[ 01 , 02 ]	:= nReg
		aMestre[ 01 , 03 ]	:= lRF9Modif
		aMestre[ 01 , 04 ]	:= aClone( aRF9Header )
		aMestre[ 01 , 05 ]	:= aClone( aRF9VirtEn )
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
ЁFun┤┘o    ЁRF5CodigoVld ЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para Validar o Conteudo do Campo RF5_CODIGO          Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RF5_CODREF                         	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF5CodigoVld()

Local lRF5CodigoOk := .T.

Begin Sequence

	IF !( lRF5CodigoOk := NaoVazio() )
		Break
	EndIF

	IF !( lRF5CodigoOk := ExistCpo( "RF9" ) )
    	Break
    EndIF

End Sequence

Return( lRF5CodigoOk )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁMauricio MR        Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA410                                                     Ё
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
								{ STR0003 , "PONA410Mnt" , 0 , 02 } 	,; //"Visualizar"
								{ STR0004 , "PONA410Mnt" , 0 , 03 } 	,; //"Incluir"
								{ STR0005 , "PONA410Mnt" , 0 , 04 } 	,; //"Alterar"
								{ STR0006 , "PONA410Mnt" , 0 , 05 } 	;  //"Excluir"
							}
Return aRotina
