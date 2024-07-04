#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "PONA390.CH"
   
   
   

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё PONA390  Ё Autor Ё Leandro Drumond       Ё Data Ё 12/12/07 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Manutencao de Jornadas									  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё PONA390()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁGlaucia M.  Ё07/07/11Ё015529ЁReadequacao das telas para diversas		  Ё╠╠
╠╠Ё			   Ё        ЁSDTCW0Ёresolucoes.								  Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function PONA390( Alias , nReg , nOpc , lExecAuto , nOpcNewGd )

Local aArea 	:= GetArea()
Local aAreaRF3	:= RF3->( GetArea() )
Local lExistOpc	:= ( ValType( nOpc ) == "N" )

Local bBlock
Local nPos

If FindRel()

	cMsgAlert := OemToAnsi(STR0031) + CRLF		//"Foi aplicado o Path de RescisЦo e nao foi executado o"
	cMsgAlert += OemToAnsi(STR0032) + CRLF		//"programa de Atualizacao de Bases (RHUPDGPE)!"
	cMsgAlert += OemToAnsi(STR0033)				//"Consulte o Administrador do Sistema." 
	
	MsgAlert( cMsgAlert, OemToAnsi(STR0034) ) 	// "Atencao"
	
	Return (Nil)

EndIf


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
	cAlias	:= "RF3"

    Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

	Private cCadastro   := OemToAnsi( STR0001 ) //"Cadastro de Jornadas"

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
		
			PONA390Mnt( cAlias , nReg , nOpc , .T. , nOpcNewGd )
		
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
RestArea( aAreaRF3 )
RestArea( aArea	   )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura o Cursor do Mouse                				   	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( NIL )

/*/
зддддддддддбддддддддддддддбддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁInPONA390Exec ЁAutor ЁMauricio MR          Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддддаддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁExecutar Funcoes Dentro de PONA390                           Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁInPONA390Exec( cExecIn , aFormParam )						 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁuRet                                                 	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function InPONA390Exec( cExecIn , aFormParam )
         
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
ЁFun┤┘o    ЁPONA390VisЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios( Visualizar )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA390Vis( cAlias , nReg , nOpcNewGd )
Return( PONA390( cAlias , nReg , 2 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA390IncЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios ( Incluir )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA390Inc( cAlias , nReg , nOpcNewGd )
Return( PONA390( cAlias , nReg , 3 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA390AltЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios( Alterar )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA390Alt( cAlias , nReg , nOpcNewGd  )
Return( PONA390( cAlias , nReg , 4 , NIL , nOpcNewGd ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA390DelЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios ( Excluir )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA390Del( cAlias , nReg  )
Return( PONA390( cAlias , nReg , 5 , NIL , 0 ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF32Visual ЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Itens de Horarios ( Visualizar )				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF32Visual( cAlias , nReg  )

SetMemoFields( cAlias , GetMemoDb( cAlias ) )
aRotSetOpc( cAlias , @nReg , 2 )

Return( AxVisual( cAlias, nReg , 2 ) )


/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA390MntЁAutor  ЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Horarios (Manutencao)							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA390()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function PONA390Mnt( cAlias , nReg , nOpc , lDlgPadSiga , nOpcNewGd )

Local aArea			:= GetArea(Alias())
Local aSvKeys		:= GetKeys()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}  
Local aDomingo		:= {}
Local aRF31Header	:= {}
Local aRF31Fields	:= {}
Local aRF31Altera	:= {}
Local aRF31NaoAlt	:= {}
Local aRF31NotFields	:= {}
Local aRF32Altera   := {}
Local aRF32NaoAlt	:= {}
Local aRF32NotFields	:= {}
Local aRF32Header	:= {}
Local aRF32Fields	:= {}
Local aLog			:= {}
Local aLogTitle		:= {}
Local aLogGer		:= {}
Local aLogGerTitle	:= {}
Local aRF3Header	:= {}
Local aRF3Cols		:= {}
Local aRF3Recnos	:= {}
Local aRF3Keys		:= {}
Local aRF3NotFields	:= {}
Local aRF3VirtEn	:= {}
Local aRF3VisuEn	:= {}
Local aSvRF3Cols	:= {}
Local aRF3Query		:= {}
Local aRF
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }
Local bChange		:= { || NIL }
Local cRF3KeySeek	:= ""
Local cFilRF3		:= ""
Local cJornRF3		:= ""
Local cMsgYesNo		:= ""
Local cTitLog		:= ""
Local cDia			:= ""
Local lLocks		:= .F.
Local lExecLock		:= ( ( nOpc <> 2 ) .and. ( nOpc <> 3 ) )
Local lExcGeraLog	:= .F.
Local nOpcAlt		:= 0
Local nRF3Usado		:= 0
Local nLoop			:= 0
Local nLoops		:= 0
Local nRF3ItemOrd	:= RetOrdem( "RF3" , "RF3_FILIAL+RF3_JORN" )
Local nCol	    	:= 0
Local nField    	:= 0
Local oDlg			:= NIL
Local oEn1RF3		:= NIL
Local oEn2RF3		:= NIL
Local oGroup		:= NIL

Private aGets
Private aTela
Private aHeader 	:= {}
Private aCols		:= {}
Private bGetRF3

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
		
		cFilRF3			:= RF3->RF3_FILIAL
		cJornRF3		:= RF3->RF3_JORN		

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta os Dados para a GetDados							   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		#IFDEF TOP
			aRF3Query		:= Array( 05 )
			aRF3Query[01]	:= "RF3_FILIAL='"+cFilRF3+"'"
			aRF3Query[02]	:= " AND "
			aRF3Query[03]	:= "RF3_JORN='"+cJornRF3+"'"
			aRF3Query[04]	:= " AND "
			aRF3Query[05]	:= "D_E_L_E_T_=' ' "
		#ENDIF

		aAdd( aRF3NotFields, "RF3_FILIAL" )
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Quando For Inclusao Posiciona o RF3 No Final do Arquivo	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 3  ) //Inclusao
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Garante que na Inclusao o Ponteiro do RF3 estara em Eof()    Ё 
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			PutFileInEof( "RF3" )
		EndIF 
		
		RF3->( dbSetOrder( nRF3ItemOrd ) )
		bGetRF3			:= { |lLock,lExclu|	IF( lExecLock , ( lLock := .T. , lExclu	:= .T. ) , aRF3Keys := NIL ),;
											aRF3Cols := RF3->(;
																GdBuildCols(	@aRF3Header		,;	//01 -> Array com os Campos do Cabecalho da GetDados
																				@nRF3Usado		,;	//02 -> Numero de Campos em Uso
																				@aRF3VirtEn		,;	//03 -> [@]Array com os Campos Virtuais
																				@aRF3VisuEn		,;	//04 -> [@]Array com os Campos Visuais
																				NIL				,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
																				aRF3NotFields	,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
																				@aRF3Recnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
																				"RF3"		   	,;	//08 -> Alias do Arquivo Pai
																				NIL				,;	//09 -> Chave para o Posicionamento no Alias Filho
																				NIL				,;	//10 -> Bloco para condicao de Loop While
																				NIL				,;	//11 -> Bloco para Skip no Loop While
																				NIL				,;	//12 -> Se Havera o Elemento de Delecao no aCols 
																				NIL				,;	//13 -> Se Sera considerado o Inicializador Padrao
																				NIL				,;	//14 -> Opcional, Carregar Todos os Campos
																				NIL				,;	//15 -> Opcional, Nao Carregar os Campos Virtuais
																				aRF3Query		,;	//16 -> Opcional, Utilizacao de Query para Selecao de Dados
																				NIL				,;	//17 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
																				NIL				,;	//18 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
																				NIL				,;	//19 -> Carregar Coluna Fantasma
																				NIL				,;	//20 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
																				NIL				,;	//21 -> Verifica se Deve verificar se o campo eh usado
																				NIL				,;	//22 -> Verifica se Deve verificar o nivel do usuario
																				NIL				,;	//23 -> Verifica se Deve Carregar o Elemento Vazio no aCols
																				@aRF3Keys		,;	//24 -> [@]Array que contera as chaves conforme recnos
																				@lLock			,;	//25 -> [@]Se devera efetuar o Lock dos Registros
																				@lExclu			 ;	//26 -> [@]Se devera obter a Exclusividade nas chaves dos registros
																		    );
															  ),;
											IF( lExecLock , ( lLock .and. lExclu ) , .T. );
		  					} 
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do RF3									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "RF3" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRF3 ) )
			Break
		EndIF

		aSvRF3Cols		:= aClone( aRF3Cols )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
		Ё quivo														   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
  		For nLoop := 1 To nRF3Usado
			SetMemVar( aRF3Header[ nLoop , 02 ] , aRF3Cols[ 01 , nLoop ] , .T. )
		Next nLoop 

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta os Dados para a Enchoice Cabec						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aRF31NotFields , "RF3_JORN") 
		aAdd( aRF31NotFields , "RF3_DESC")
		aAdd( aRF31NotFields , "RF3_FLAG")
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
		Ё quivo														   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aRF31Header := {} 
		aRF32Header := {}
	

		For nLoop := 1 To nRF3Usado
			If !Empty(nPos := aScan(aRF31NotFields, {|x|  aRF3Header[ nLoop , 02 ] == x } ) )
				aAdd( aRF31Header, aRF3Header[nLoop] )
			Else
				aAdd( aRF32NotFields , aRF3Header[nLoop,2])
				aAdd( aRF32Header, aRF3Header[nLoop] )
			EndIF
		Next nLoop
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁDefine os Campos Editaveis na Enchoice Apenas na Inclusao( 3 )Ё
		Ёou Alteracao(4)											   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )

			IF ( nOpc == 4 )
				aAdd( aRF31NaoAlt , "RF3_JORN" )
				aAdd( aRF31NaoAlt , "RF3_FLAG" )				
			EndIF

		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carregando campos Alteraveis e Editavies Ench Cabec		   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		MkArrEdFlds( nOpc , aRF31Header , aRF3VisuEn , aRF3VirtEn , @aRF31NaoAlt , @aRF31Altera , @aRF31Fields )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carregando campos Alteraveis e Editavies	Ench 2			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		MkArrEdFlds( nOpc , aRF32Header , aRF3VisuEn , aRF3VirtEn , @aRF32NaoAlt , @aRF32Altera , @aRF32Fields )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁVerifica se Pode Efetuar a Delecao dos Registros			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 5 )   
			IF ! ( ChkDelRegs(	"RF3"											,;	//01 -> Alias do Arquivo Principal
			 					nReg											,;  //02 -> Registro do Arquivo Principal
			 					nOpc 											,;  //03 -> Opcao para a AxDeleta
			 					cFilRF3											,;	//04 -> Filial do Arquivo principal para Delecao
			 					cJornRF3 									 	,;  //05 -> Chave do Arquivo Principal para Delecao
			 					NIL												,;  //06 -> Array contendo informacoes dos arquivos a serem pesquisados
			 					NIL 											,;  //07 -> Mensagem para MsgYesNo
			 					NIL							 					,;  //08 -> Titulo do Log de Delecao
								NIL 											,;  //09 -> Mensagem para o corpo do Log
								.F.												,;	//10 -> Se executa AxDeleta
								.T.												,;	//11 -> Se deve Mostrar o Log					 					
		 						@aLog											,;	//12 -> Array com o Log de Exclusao
								@aLogTitle	 									 ;	//13 -> Array com o Titulo do Log
		 				);
			    )
			    Break
			EndIF
		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta as Dimensoes dos Objetos         					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 080 , .T. , .F. } )
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
									PONA390TEncOk( nOpc , oEn1RF3, aRF3Header );		//Valida Todos os Campos da Enchoice
									.and.;									
									PONA390TEncOk( nOpc , oEn2RF3, aRF3Header ),;		//Valida as Informacoes da GetDados
									(;
										nOpcAlt		:= 1 ,;
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
		Ё Monta o Objeto Enchoice para o RF3                      	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		oEn1RF3	:= MsmGet():New(	cAlias		,;
									nReg		,;
									nOpc		,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRF31Fields	,;
									aObjSize[1] ,;
									aRF31Altera	,;
									NIL			,;
									NIL			,;
									NIL			,;
									oDlg		,;
									NIL			,;
									.F.			,;
									NIL			,;
									.F.			, ;
									NIL,;
									.F.;
								)
		oEn2RF3	:= MsmGet():New(	cAlias		,;
									nReg		,;
									nOpc		,;
									NIL			,;
									NIL			,;
									NIL			,;
									aRF32Fields	,;
									aObjSize[2] ,;
									aRF32Altera ,;
									NIL			,;
									NIL			,;
									NIL			,;
									oDlg		,;
									NIL			,;
									.F.			,;
									NIL			,;									
									.F.		   ,NIL,.F.	;
								)									  
		
	ACTIVATE MSDIALOG oDlg ON INIT 	EnchoiceBar( oDlg , bSet15 , bSet24  ) CENTERED


	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁQuando Confirmada a Opcao e Nao for Visualizacao Grava ou   ExЁ
	Ёclui as Informacoes do RF3 e RF3							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF( nOpcAlt == 1 )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Apenas se nao For Visualizacao              				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 		IF ( nOpc != 2 )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Gravando/Incluido ou Excluindo Informacoes do SRY/RF3        Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			MsAguarde(;
						{ ||;
								PONA390Grava(	nOpc		,;	//Opcao de Acordo com aRotina
											 	nReg		,;	//Numero do Registro do Arquivo Pai ( RF3 )
											 	aRF3Header	,;	//Campos do Arquivo Pai ( RF3 )
											 	aRF3Cols	,;	//Conteudo Atual dos Campos do Arquivo Pai ( RF3 )
											 	aSvRF3Cols  ,;	//Conteudo Anterior dos Campos do Arquivo Pai ( RF3 )
											 	aRF3VirtEn	 ;	//Campos Virtuais do Arquivo Pai ( RF3 )
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
FreeLocks( "RF3" , aRF3Recnos , .T. , aRF3Keys )

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
ЁFun┤┘o    ЁPONA390TEncOkЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁTudoOk para a Enchoice                                      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁPONA390TEncOk( nOpc , oEnRF31 )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA390()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function PONA390TEncOk( nOpc , oEnRF3, aCpos )

Local lTudoOk  := .T.
Local cMsgInfo := "" 
                
IF ( ( nOpc == 3 ) .or. ( nOpc == 4 ) )
	lTudoOk := EnchoTudOk( oEnRF3 )
	
	//Verifica se Existe Saida de Intervalo sem Entrada correspondente
	IF ( ( ( M->RF3_HRINT1 <> 0 ) .or. ( M->RF3_INTER1 == "S" ) ) .and. ( M->RF3_HRTRA2 == 0 ) )

		lTudoOk		:= .F.
		cMsgInfo	:= STR0026  //"Tabela n└o pode terminar com uma saida de intervalo"
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo	+= STR0027	//"O intervalo: "
		cMsgInfo	+= " 1 "
		cMsgInfo	+= STR0028  //"Nao possui a entrada correspondente"
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo	+= STR0029  //"Altere o conteudo do campo: "
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_INTER1" , aCpos ) , 01 ]
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo    += STR0030	//"ou informe Hor═rio nos campos: "
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_ENTRA2" , aCpos ), 01 ]
		cMsginfo	+= " / " 
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_SAIDA2" , aCpos ), 01 ]

		MsgInfo( cMsgInfo )
		
	EndIF
	
	//Verifica se Existe Saida de Intervalo sem Entrada correspondente
	IF ( ( ( M->RF3_HRINT2 <> 0 ) .or. ( M->RF3_INTER2 == "S" ) ) .and. ( M->RF3_HRTRA3 == 0 ) )

		lTudoOk		:= .F.
		cMsgInfo	:= STR0026  //"Tabela n└o pode terminar com uma saida de intervalo"
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo	+= STR0027	//"O intervalo: "
		cMsgInfo	+= " 1 "
		cMsgInfo	+= STR0028  //"Nao possui a entrada correspondente"
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo	+= STR0029  //"Altere o conteudo do campo: "
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_INTER2" , aCpos ), 01 ]
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo    += STR0030	//"ou informe Hor═rio nos campos: "
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_ENTRA3" , aCpos ), 01 ]
		cMsginfo	+= " / " 
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_SAIDA3" , aCpos ), 01 ]

		MsgInfo( cMsgInfo )
		
	EndIF
	
	//Verifica se Existe Saida de Intervalo sem Entrada correspondente
	IF ( ( ( M->RF3_HRINT3 <> 0 ) .or. ( M->RF3_INTER3 == "S" ) ) .and. ( M->RF3_HRTRA4 == 0 ) )

		lTudoOk		:= .F.
		cMsgInfo	:= STR0026  //"Tabela n└o pode terminar com uma saida de intervalo"
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo	+= STR0027	//"O intervalo: "
		cMsgInfo	+= " 1 "
		cMsgInfo	+= STR0028  //"Nao possui a entrada correspondente"
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo	+= STR0029  //"Altere o conteudo do campo: "
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_INTER3" , aCpos ), 01 ]
		cMsgInfo	+= CRLF
		cMsgInfo	+= CRLF
		cMsgInfo    += STR0030	//"ou informe Hor═rio nos campos: "
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_ENTRA4" , aCpos ), 01 ]
		cMsginfo	+= " / " 
		cMsgInfo	+= aCpos[ GdFieldPos( "RF3_SAIDA4" , aCpos ), 01 ]

		MsgInfo( cMsgInfo )
		
	EndIF	

EndIF

Return( lTudoOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF3GdLinOk	ЁAutorЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRF3GdLinOk( oBrowse )									    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA390()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF3GdLinOk( oBrowse )

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
			aCposKey := GetArrUniqe( "RF3" )
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
	PutFileInEof( "RF3" )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( lLinOk )

/*/
зддддддддддбддддддддддддбдддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁRF3GdTudOk	ЁAutorЁMauricio MR            Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRF3GdTudOk( oBrowse )									   	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA390()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF3GdTudOk( oBrowse )

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
			IF !( lTudoOk := RF3GdLinOk( oBrowse ) )
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
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁPONA390Grava ЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA390()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function PONA390Grava(	nOpc		,;	//Opcao de Acordo com aRotina
							 	nReg		,;	//Numero do Registro do Arquivo Pai ( RF3 )
							 	aRF3Header	,;	//Campos do Arquivo Pai ( RF3 )
							 	aRF3Cols	,;	//Conteudo Atual dos Campos do Arquivo Pai ( RF3 )
							 	aSvRF3Cols  ,;	//Conteudo Anterior dos Campos do Arquivo Pai ( RF3 )
							 	aRF3VirtEn	 ;	//Campos Virtuais do Arquivo Pai ( RF3 )
							  )

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis de Inicializacao Obrigatoria					  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aMestre	:= GdPutIStrMestre( 01 )
Local cOpcao	:= IF( ( nOpc == 5 ) , "DELETE" , IF( ( ( nOpc == 3 ) .or. ( nOpc == 4 ) ) , "PUT" , NIL ) )
Local lRF3Modif	:= .F.

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis que serao inicializadas no Corpo da Funcao		  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local nLoop
Local nLoops

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Atualiza aRF3Cols para Verificar se Houveram Alteracoes	   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	nLoops := Len( aRF3Header )
	For nLoop := 1 To nLoops
		aRF3Cols[ 01 , nLoop ] := GetMemVar( aRF3Header[ nLoop , 02 ] )
	Next nLoop

	IF ( cOpcao <> "DELETE" )
	 
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
		Ё se foi Selecionada a Exclusao								   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		lRF3Modif := !( ArrayCompare( aRF3Cols , aSvRF3Cols ) )

	Else
		lRF3Modif := .T.
	EndIF

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Se Houveram Alteracoes, ou Exclusao efetua a Gravacao        Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( lRF3Modif )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
		Ё se foi Selecionada a Exclusao								   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aMestre[ 01 , 01 ]	:= "RF3"
		aMestre[ 01 , 02 ]	:= nReg
		aMestre[ 01 , 03 ]	:= lRF3Modif
		aMestre[ 01 , 04 ]	:= aClone( aRF3Header )
		aMestre[ 01 , 05 ]	:= aClone( aRF3VirtEn )
		aMestre[ 01 , 06 ]	:= {} 
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Nao e necessario passar o array itens pois a gravacao da 	   Ё
		Ё tabela mestre e a gravacao do proprio filho				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/		
	    //aMestre[ 01 , 07 ]	:= aClone( aItens )
		
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
ЁFun┤┘o    ЁRF3CodigoVldЁAutorЁMauricio MR           Ё Data Ё06/12/2007Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁFuncao para Validar o Conteudo do Campo RF3_CODIGO         Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁX3_VALID para o campo RF3_CODREF                         	Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RF3CodigoVld()

Local lRF3CodigoOk := .T.

Begin Sequence

	IF !( lRF3CodigoOk := NaoVazio() )
		Break
	EndIF

	IF !( lRF3CodigoOk := ExistCpo( "RF3" ) )
    	Break
    EndIF

End Sequence

Return( lRF3CodigoOk )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁRF3VLIMITEЁ Autor Ё Igor Franzoi			Ё Data Ё10.10.2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Chama a funcao q consiste a hora digitada.				  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё Rf3VLimite(nHor)											  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ nHor = Hora no formato 99.99	 						      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё Generico 												  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
*/
Function Rf3VLimite(cCampo)

Local nCampo := &("M->RF3_"+cCampo)

lRet := VldHora( nCampo )

Return ( lRet )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁMauricio MR        Ё Data Ё06/12/2007Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA390                                                     Ё
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
								{ STR0002 , "AxPesqui"	 		, 0 , 01,,.F.} ,; 	//"Pesquisar"
								{ STR0003 , "PONA390Mnt" 		, 0 , 02 } 	,; 		//"Visualizar"
								{ STR0004 , "PONA390Mnt" 		, 0 , 03 } 	,; 		//"Incluir"
								{ STR0005 , "PONA390Mnt" 		, 0 , 04 } 	,; 		//"Alterar"
								{ STR0006 , "PONA390Mnt" 		, 0 , 05 } 	; 		//"Excluir"
							}
Return aRotina

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o	 ЁFindRel	Ё Autor Ё Reginaldo G. Ribeiro	Ё Data Ё13.10.2009Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё funГЦo que verifica se existe relacionamento entre tabelas Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё FindRel()   												  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё PONA390													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
*/	

Static Function FindRel()

Local lRet	:= .F.
	
dbSelectArea("SX9")
dbSetOrder(2)
	
If SX9->(!dbSeek("RF4"+"RF3"))
	lRet := .T.
EndIf
		
Return lRet