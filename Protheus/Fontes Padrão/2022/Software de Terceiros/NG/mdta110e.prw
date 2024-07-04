#Include "mdta110.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA110E
ASOS Funcionario Selecionado

@author  Denis Hyroshi de Souza
@since   11/11/2004

@return  Lógico, Verdadeiro quando a fonção for executada normalmente
/*/
//-------------------------------------------------------------------
Function MDTA110E()

	Local aNGBEGINPRM := NGBEGINPRM( , "MDTA200" )

	If !IsInCallStack( "MDTA110" ) .And. !IsBlind()
		ShowHelpDlg( STR0035, ;          //"ATENÇÃO"
					{ STR0046 }, 1, ;    //"Execução não permitida."
					{ STR0047, "" }, 1 ) //"Rotina somente pode ser executada pelo menu de Ocorrências Ficha (MDTA110)."
		Return .F.
	EndIf

	If FindFunction( "MDTRESTRI" ) .And. !MDTRESTRI( "MDTA200" )
		Return .F.
	EndIf

	//Verifica se o funcionario esta demitido
	If !SitFunFicha( TM0->TM0_NUMFIC, .F., .T., .T. )
		NGRETURNPRM( aNGBEGINPRM )
		Return
	Endif

	Private bFiltraBrw := { || Nil } // Variavel para Filtro
	Private aTrocaF3   := {}
	Private aNGFIELD   := {}
	Private LEDTEMIS   := .T. //Abertura do campo para atender ao eSocial (ASO's de terceiros)
	Private LEDTCANC   := .F.
	Private LEEXAME    := .F.
	Private LECODUSU   := .T.
	Private LEDTPROG   := .T.
	Private cMARCA     := GetMark()

	If lSigaMdtPS
		dbSelectArea( "SA1" )
		dbSetOrder( 1 )
		dbSeek( xFilial( "SA1" ) + TM0->TM0_CLIENT + TM0->TM0_LOJA )
		Private cCliMdtPs := SA1->A1_COD + SA1->A1_LOJA
	Endif

	lInverte := .F.
	lQuery := .T.

	Private aRotina := MenuDef()

	Private LENUMFIC  := .F.
	Private cCadastro := OemtoAnsi( STR0024 ) //"Atestado Saúde Ocupacional - ASO"
	Private sNOMFIC	  := TM0->TM0_NOMFIC
	Private sNUMFIC	  := TM0->TM0_NUMFIC

	SetFunName( "MDTA110E" )
	dbselectarea( "TM0" )
	dbsetorder( 1 )
	dbSelectArea( "TMY" )
	dbSetOrder( 1 )

	dbSelectArea( "TMY" )
	Set Filter to TMY->TMY_FILIAL == xFilial( "TMY" ) .And. TMY->TMY_NUMFIC == sNUMFIC
	mBrowse( 6, 1, 22, 75, "TMY" )

	dbSelectArea( "TMY" )
	dbSetOrder( 1 )
	Set Filter to

	NGRETURNPRM( aNGBEGINPRM )
	SetFunName( "MDTA110" )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional
@type static function
@author Rafael Diogo Richter
@since 11/01/2007
@return array, opções do menu com o seguinte layout:
				Parametros do array a Rotina:
				1. Nome a aparecer no cabecalho
				2. Nome da Rotina associada
				3. Reservado
				4. Tipo de Transação a ser efetuada:
					1 - Pesquisa e Posiciona em um Banco de Dados
					2 - Simplesmente Mostra os Campos
					3 - Inclui registros no Bancos de Dados
					4 - Altera o registro corrente
					5 - Remove o registro corrente do Banco de Dados
				5. Nivel de acesso
				6. Habilita Menu Funcional

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local lSigaMdtPS := SuperGetMv( "MV_MDTPS", .F., "N" ) == "S"
	Local cSTRIN9	 := SubStr( STR0022, 1 , 1 ) + "&" + SubStr( STR0022, 2 ) //"Imprimir"###"Imprimir"
	Local aRotina	 := { { STR0004, "AxPesqui" , 0, 1    },; // "Pesquisar"
						  { STR0005, "NGCAD01"  , 0, 2    },; // "Visualizar"
					      { STR0011, "NG200INC" , 0, 3    },; // "Incluir"
					      { STR0012, "NG200INC" , 0, 4    },; // "Alterar"
					      { STR0013, "NG200INC" , 0, 5, 3 },; // "Excluir"
					      { cSTRIN9, "MDT110ASO", 0, 6    } } // "Imprimir"
	
	If !lSigaMdtPs .And. SuperGetMv( "MV_NG2AUDI", .F., "2" ) == "1"
		aAdd( aRotina, { STR0031, "MDTA991( 'TMY' )", 0, 3 } ) //"Hist. Exc."
	EndIf

Return aRotina
