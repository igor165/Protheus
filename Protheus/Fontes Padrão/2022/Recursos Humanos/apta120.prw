#INCLUDE "PROTHEUS.CH"
#INCLUDE "APTA120.CH"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммммммммкммммммямммммммммммммм╩╠╠
╠╠╨Programa  ЁAPTA120   ╨Autor  ЁTania Bronzeri      ╨ Data Ё  10/05/2004         ╨╠╠
╠╠╨          Ё          ╨       ЁMarinaldo de Jesus  ╨      Ё                     ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммммммммммм╧╠╠
╠╠╨Desc.     ЁCadastro de Registros de Classe                                     ╨╠╠
╠╠╨          Ё                                                                    ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁRegistros de Classe associados ao cadastro de Pessoas               ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠ЁProgramador Ё Data     Ё BOPS         Ё  Motivo da Alteracao                   Ё╠╠
╠╠цддддддддддддеддддддддддеддддддедддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car.Ё04/08/2014ЁTQEQ39        ЁIncluido o fonte da 11 para a 12 e efe- Ё╠╠
╠╠Ё            Ё          Ё              Ёtuda a limpeza.                         Ё╠╠
╠╠ЁFlavio Corr.Ё04/08/2014ЁTQLHZP        ЁAjuste tamanho Enchoice				  Ё╠╠
╠╠ЁWillian U.  Ё15/08/2017ЁDRHPONTP-1304 ЁAjuste na funГЦo Apta120Grava() para    Ё╠╠
╠╠Ё            Ё          Ё              Ёverificar o compartilhamento das tabelasЁ╠╠
╠╠Ё            Ё          Ё              ЁREU e RD0.                              Ё╠╠  
╠╠хммммммммммммоммммммммммоммммммомммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
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
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁRedefine o Alias                                              Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	cAlias	:= "RD0"

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁNao Executa se o RD0 estiver Vazio                            Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !ChkVazio( cAlias )
		Break
	EndIF

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
	
    Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

	Private cCadastro   := OemToAnsi( STR0007 ) //"Registros de Classe"

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
			Apta120Mnt( cAlias , nReg , nOpc , .T. ,lMaximized , cSigla )
		
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
RestArea( aAreaReu )
RestArea( aAreaRd0 )
RestArea( aArea	   )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRestaura o Cursor do Mouse                				   	   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()
	
Return( NIL )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁApta120VisЁ Autor ЁMarinaldo de Jesus     Ё Data Ё27/02/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Registros de Classe ( Visualizar )				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function Apta120Vis( cAlias , nReg  )
Return( APTA120( cAlias , nReg , 2 ,, .F. ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁApta120IncЁ Autor ЁMarinaldo de Jesus     Ё Data Ё27/02/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Registros de Classe ( Incluir )					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function Apta120Inc( cAlias , nReg  )  

nReg	:=	RD0->( Recno() )

Return( APTA120( cAlias , nReg , 3 ,, .F. ) )

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁApta120IncAdvЁ Autor ЁTania Bronzeri         Ё Data Ё10/09/2004Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Registros de Classe Advogado ( Incluir )   		   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          				               Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>                                      Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁCadastramento dos Advogados do Processo                        Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁApta120AltЁ Autor ЁMarinaldo de Jesus     Ё Data Ё27/02/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Visoes ( Alterar )								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function Apta120Alt( cAlias , nReg  )
Return( APTA120( cAlias , nReg , 4 ,, .T. ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁApta120DelЁ Autor ЁMarinaldo de Jesus     Ё Data Ё27/02/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Registros de Classe ( Excluir )					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function Apta120Del( cAlias , nReg  )
Return( APTA120( cAlias , nReg , 5 ) )

/*/
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁReuVisual Ё Autor ЁMarinaldo de Jesus     Ё Data Ё12/04/2004Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Itens de Registros de Classe ( Visualizar )		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>          							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ReuVisual( cAlias , nReg  )

SetMemoFields( cAlias , GetMemoDb( cAlias ) )
aRotSetOpc( cAlias , @nReg , 2 )

Return( AxVisual( cAlias, nReg , 2 ) )

/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁApta120MntЁ Autor ЁMarinaldo de Jesus     Ё Data Ё18/06/2002Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCadastro de Registros de Classe (Manutencao)				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁApta120Mnt(cAlias,nReg,nOpc,lDlgPadSiga,cSigla) 			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁcAlias 		= Alias do arquivo                              Ё
Ё          ЁnReg   		= Numero do registro                            Ё
Ё          ЁnOpc   		= Numero da opcao selecionada                   Ё
Ё          ЁlDlgPadSiga = Numero da opcao selecionada                   Ё
Ё          ЁlMaximized	= Informa se a tela devera ser maximizada       Ё
Ё          ЁcSigla		= Sigla do Registro de Classe                   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA120()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.   			Ё
ЁдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддЁ
ЁProgramador Ё Data   Ё FNC  Ё  Motivo da Alteracao                     Ё
цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢
Ё Gustavo M. |22/09/11Ё24561/Ё Alteracao do Parametro lCposUser para   	Ё 
Ё      	 	 Ё 		  Ё2011  Ё carregar os Campos de Usuario		    Ё
аддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддда/*/
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
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do RD0									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "RDU_RD0" , NIL , NIL , 1 , 1 , .T. , 1 , 5 , bGetRd0 ) )
			Break
		EndIF
		CursorWait()
		aSvRd0Cols		:= aClone( aRd0Cols )
		cFilRD0			:= RD0->RD0_FILIAL
		cCodRD0			:= RD0->RD0_CODIGO
		cRD0KeySeek		:= ( cFilRD0 + cCodRD0 )
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Cria as Variaveis de Memoria e Carrega os Dados Conforme o arЁ
		Ё quivo														   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		For nLoop := 1 To nRd0Usado
			aAdd( aRd0Fields , aRd0Header[ nLoop , 02 ] )
			SetMemVar( aRd0Header[ nLoop , 02 ] , aRd0Cols[ 01 , nLoop ] , .T. )
		Next nLoop

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta os Dados para a GetDados							   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aReuNotFields , "REU_FILIAL"  )
		aAdd( aReuNotFields , "REU_CODPES"	)
		aReuQuery		:= Array( 05 )
		aReuQuery[01]	:= "REU_FILIAL='"+cFilRD0+"'"
		aReuQuery[02]	:= " AND "
		aReuQuery[03]	:= "REU_CODPES='"+cCodRD0+"'"
		aReuQuery[04]	:= " AND "
		aReuQuery[05]	:= "D_E_L_E_T_=' ' "
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Quando For Inclusao Posiciona o REU No Final do Arquivo	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc == 3  ) //Inclusao
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Garante que na Inclusao o Ponteiro do REU estara em Eof()    Ё 
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁLock do Registro do REU									   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF !( lLocks := WhileNoLock( "REU" , NIL , NIL , 1 , 1 , .T. , nReuMaxLocks , 5 , bGetReu ) )
			Break
		EndIF
		CursorWait()
		aSvReuCols	:= aClone( aReuCols )
  
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define os Campos Memos                     				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdd( aReuMemoGd , { "REU_ESPEC" , "REU_C_ESP"   } )

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Carrega os Campos Editaveis para a GetDados				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁCarrega os Recnos e as Chaves correspondentes dos campos MemosЁ
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		IF ( nOpc <> 2 )
			IF !( lLocks := AptMemRec( "REU" , aReuRecnos , aReuMemoGd , @aRe6Recnos , @aRe6Keys , .T. ) )
				Break
			EndIF
		EndIF

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta as Dimensoes dos Objetos         					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		DEFAULT lDlgPadSiga	:= .F.
		aAdvSize		:= MsAdvSize( NIL , lDlgPadSiga )
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
		aAdd( aObjCoords , { 000 , 050 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Botao de Pesquisa na GetDados					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para a Tecla <CTRL-O> 						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para a Teclas <CTRL-X>     	   			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bSet24		:= { || ( nOpcAlt := 0 , RestKeys( aSvKeys , .T. ) , oDlg:End() ) }
	
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define o Bloco para o Init do Dialog						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bDialogInit := { ||;
								EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons ),;
								SetKey( VK_F4 , bGdReuSeek  ),;
						}

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
		Ё Monta o Objeto Enchoice para o RD0                      	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta o Objeto GetDados para o REU						   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁQuando Confirmada a Opcao e Nao for Visualizacao Grava ou   ExЁ
	Ёclui as Informacoes do RD0 e REU							   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF( nOpcAlt == 1 )
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Apenas se nao For Visualizacao              				   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
 		IF ( nOpc != 2 )
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Gravando/Incluido ou Excluindo Informacoes do REU        Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Coloca o Ponteiro do Mouse em Estado de Espera			   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁLibera os Locks             								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
aAdd( aFreeLocks , { "RDU_RD0"	, NIL			, aRd0Keys } )
aAdd( aFreeLocks , { "REU" 		, aReuRecnos	, aReuKeys } )
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
ЁFun┤┘o    ЁReuGdLinOk	ЁAutorЁMarinaldo de Jesus     Ё Data Ё18/06/2002Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁReuGdLinOk( oBrowse )									    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA120()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ReuGdLinOk( oBrowse )

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
	PutFileInEof( "REU" )
	
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
			aCposKey := { "REU_SIGLA" }
			IF !( lLinOk := GdCheckKey( aCposKey , 4 ) )
				Break
			EndIF

			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Verifica Se o Campos Estao Devidamente Preenchidos		   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			aCposKey := { "REU_SIGLA" , "REU_NUMREG" }
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
ЁFun┤┘o    ЁReuGdTudOk	ЁAutorЁMarinaldo de Jesus     Ё Data Ё18/06/2002Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁReuGdTudOk( oBrowse )									   	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ 															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA120()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ReuGdTudOk( oBrowse )

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
			IF !( lTudoOk := ReuGdLinOk( oBrowse ) )
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
ЁFun┤┘o    ЁReuGdDelOk  ЁAutorЁMarinaldo de Jesus     Ё Data Ё18/07/2003Ё
цддддддддддеддддддддддддадддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁValidar a Delecao na GetDados                               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<vide parametros formais>								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA120()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
				//"A chave a ser excluida est═ sendo utilizada."
				//"At┌ que as refer┬ncias a ela sejam eliminadas a mesma n└o pode ser excluida."
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
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁApta120Grava ЁAutorЁMarinaldo de Jesus    Ё Data Ё21/07/2003Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA120()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Variaveis de Inicializacao Obrigatoria					  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Local aMestre	:= GdPutIStrMestre( 01 )
Local aItens	:= {}
Local cOpcao	:= IF( ( nOpc == 4 ) , "DELETE" , IF( ( ( nOpc == 3 )  ) , "PUT" , NIL ) )

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Altera o Estado do Cursor  								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Carrega os Itens Apenas se Houveram Alteracoes ou na ExclusaoЁ
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( ( nOpc == 4 ) .or. !( fCompArray( aReuCols , aSvReuCols ) ) )

	//Verifica o modo de acesso das tabelas REU e RD0
	cREU := FWModeAccess( "REU", 1) + FWModeAccess( "REU", 2) + FWModeAccess( "REU", 3)
	cRD0 := FWModeAccess( "RD0", 1) + FWModeAccess( "RD0", 2) + FWModeAccess( "RD0", 3)
	
	If cREU > cRD0
		//"O Modo de Acesso do relacionamento para a tabela de Registro de Classe deve possuir um compartilhamento igual ou maior Ю tabela de Pessoas/Participantes"
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
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Seta a Gravacao ou Exclusao Apenas se Houveram Alteracoes  ouЁ
	Ё se foi Selecionada a Exclusao								   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	aMestre[ 01 , 01 ]	:= "RD0"
	aMestre[ 01 , 02 ]	:= nReg
	aMestre[ 01 , 03 ]	:= .F.
	aMestre[ 01 , 04 ]	:= NIL
	aMestre[ 01 , 05 ]	:= NIL
	aMestre[ 01 , 06 ]	:= {}
	aMestre[ 01 , 07 ]	:= aClone( aItens )
	
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Grava as Informacoes                        				   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	GdPutInfoData( aMestre , cOpcao )

/*/
зддддддддддддддддддддддддддддддддддддддддд





ддддддддддддддддддддд©
Ё Restaura o Estado do Cursor								   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorArrow()

Return( NIL )

/*/
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁGdReuSeek	 ЁAutorЁMarinaldo de Jesus    Ё Data Ё08/01/2004Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁEfetuar Pesquisa na GetDados                               	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁAPTA120                                                		Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
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
зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁAptMemRec	 ЁAutorЁMarinaldo de Jesus    Ё Data Ё10/04/2003Ё
цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁObtem os Recnos e as Chaves do RE6 conforme Alias           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁSIGAAPT  	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function AptMemRec( cAlias , aRecnos , aMemoEn , aRe6Recnos , aRe6Keys , lObtemKeys )

DEFAULT lObtemKeys := .F.

ApdMsMmObtemRec( cAlias , aRecnos , aMemoEn , @aRe6Recnos , @aRe6Keys , lObtemKeys )

Return( WhileNoLock( "RE6" , aRe6Recnos , aRe6Keys , 1 , 1 , .T. , NIL , 5 ) )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Luiz Gustavo     Ё Data Ё19/12/2006Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁAPTA120                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   

Static Function MenuDef()

 Local aRotina :={;
								{ STR0001 , "AxPesqui"	 , 0 , 01 } ,; //"Pesquisar"
								{ STR0002 , "Apta120Mnt" , 0 , 02 } ,; //"Visualizar"
								{ STR0004 , "Apta120Mnt" , 0 , 04 } ,; //"Atualizar"
								{ STR0005 , "Apta120Mnt" , 0 , 05 }  ; //"Excluir"
							}
Return aRotina