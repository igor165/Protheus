#INCLUDE "MDTR997.ch"
#INCLUDE "protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR997
Impress�o do relat�rio de Exposi��o Radioativa.

@type Function
@author Elynton Fellipe Bazzo
@since 16/04/2013
@sample MDTR997()

@return  Nil, Sempre Nulo
/*/
//---------------------------------------------------------------------
Function MDTR997()

	Private cString := "SRA"
	Private wnrel   := STR0011 // "MDTR997" - Nome do relat�rio
	Private limite  := 220     // Limite do Relat�rio

	Private cDesc1  := STR0019 // "O objetivo deste relat�rio � exibir detalhadamente as doses apuradas  "
	Private cDesc2  := STR0020 // "de radia��o, mediante recibo."
	Private cDesc3  := ""
	Private aPerg   := {}

	Private nomeprog := STR0011 // Define o nome do programa.
	Private Tamanho  := "G"     // Define o Tamanho do relat�rio.
	//Define as propriedades do relatorio
	Private aReturn  := { STR0009, 1, STR0010, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
	Private titulo   := STR0001 //"Resultado das doses de exposi��o Radioativa"
	Private ntipo    := 0       //Define o tipo de acordo com as propriedades
	Private nLastKey := 0       //Variavel de controle dos botoes do SetPrint
	Private cPerg    := "MDT997"
	Private cabec1   := STR0008 // Data Medi��o / Ponto / Tipo do Local / Dose Taxa Equiv. uSv/h / Dist�ncia
	Private cabec2   := ""      //Cabecalhos

	/*-----------------------------------
	//PADR�O						    |
	|  Matr�cula ?						|
	|  A partir de ?					|
	|  Termo Responsabilidade ?			|
	-----------------------------------*/

	If FindFunction( 'MDTChkTJ7' )

		If MDTChkTJ7() // Verifica o tamanho do campo TJ7_CODIGO
			Pergunte( cPerg, .F. )

			//Envia controle para a funcao SETPRINT
			wnrel:=SetPrint( cString, wnrel, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., {}, , Tamanho )

			If nLastKey = 27
				Set Filter To
				Return .F.
			Endif

			SetDefault( aReturn, cString )
			Processa( { |lEnd| R997Imp( @lEnd, wnRel, titulo, tamanho ) }, STR0012 ) //"Processando Registros..."
		EndIf
	Else
		MsgStop( STR0024 ) //"Seu ambiente encontra-se desatualizado ou com inconsist�ncias no campo C�digo (TJ7_CODIGO) da tabela de Servi�os (TJ7). Favor atualizar o ambiente."
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} R997Imp
Fun��o que realiza a impress�o do relat�rio de Exposi��o Radioativa.

@author Elynton Fellipe Bazzo
@since 17/04/2013
@sample R997Imp( .T. )
@param lEnd, L�gico, Controle de Encerramento do Relat�rio

@return L�gico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Static Function R997Imp( lEnd )

	Local lImp			:= .F. //Variavel para controle de impressao.
	Local cRodaTxt		:= ""
	Local nCntImpr		:= 0
	Local nLinha  		:= 40
	Local nTam    		:= 0
	Local cFunc		:= ""
	Local dDataAtu 	:= CTOD( "  /  /    " )
	Local lPrimeiro
	Local LinhaCorrente
	Local nLinhasMemo

	Private li := 80, m_pag := 1

	//Verifica se deve imprimir ou n�o
  	nTipo  := IIF( aReturn[4] == 1, 15, 18 )

	// Impress�o dos dados do funcion�rio.
	dbSelectArea( "SRA" )
	dbSetOrder( 01 )
	If dbSeek( xFilial( "SRA" ) + PadR( MV_PAR01, TAMSX3( "RA_MAT" )[1] ) )
		ProcRegua( Recno() )
		IncProc()
		lImp := .T. // Variavel para controle de impressao.
		NGSomali( 58 )
		cIdade := Alltrim( Str( Int( ( dDataBase - SRA->RA_NASC ) / 365 ), 10 ) )
		@ Li, 000 Psay STR0013 // "Funcion�rio:"
		@ Li, 013 Psay SRA->RA_MAT
		@ Li, 020 Psay STR0014 // " - "
		@ Li, 023 Psay SRA->RA_NOME
		@ Li, 065 Psay STR0015 // "C. Custo:"
		@ Li, 075 Psay SRA->RA_CC
		@ Li, 130 Psay STR0016 // "Fun��o:"
		@ Li, 138 Psay SRJ->RJ_DESC
		@ Li, 195 Psay STR0017 // "Idade:"
		@ Li, 202 Psay cIdade
		@ Li, 205 Psay STR0018 // "Anos"
		NGSomali( 58 )
		NGSomali( 58 )
		NGSomali( 58 )
	EndIf

		dbSelectArea( "TJ7" )
		dbSetOrder( 03 ) // TJ7_FILIAL+TJ7_TIPREG+TJ7_CODIGO+DTOS(TJ7_DATA)
		dbSeek( xFilial( "TJ7" ) + "2" + PadR( MV_PAR01, 6 ) )
		While !EoF() .And. TJ7->( TJ7_FILIAL + TJ7_TIPREG ) + Alltrim( TJ7->TJ7_CODIGO ) == xFilial( "TJ7" ) + "2" + PadR( MV_PAR01, 6 )
			If DTOS( TJ7->TJ7_DATA ) < DTOS( MV_PAR02 )
				NGDBSELSKIP( "TJ7" )
				Loop
			EndIf

			dDataAtu := TJ7->TJ7_DATA
			@ Li, 000 Psay TJ7->TJ7_DATA
			DbSelectArea( "TJ7" )
			While !EoF() .And. TJ7->( TJ7_FILIAL + TJ7_TIPREG ) + Alltrim( TJ7->TJ7_CODIGO ) + DTOS( TJ7->TJ7_DATA ) == xFilial( "TJ7" ) + "2" + PadR( MV_PAR01, 6 ) + DTOS( dDataAtu )
				ProcRegua( Recno() )
				IncProc()
				lImp := .T. // Variavel para controle de impressao.
				@ Li, 045 Psay TJ7->TJ7_PONTO
				@ Li, 085 Psay TJ7->TJ7_TIPO
				@ Li, 140 Psay TJ7->TJ7_DOSE
				@ Li, 190 Psay TJ7->TJ7_DISTAN
	  			NGSomali( 58 )
	  			NGDBSELSKIP( "TJ7" )
			End While
			NGSomali( 58 )
		End While

	NGSomali( 58 )
	NGSomali( 58 )
 	@ Li, 000 Psay Replicate( "_", 220 ) // Replica uma linha que separa os dados do Funcion�rio e dados da dosimetria com a decalra��o e ass.

	lPrimeiro := .T.
	// Impress�o do termos de responsabilidade.
	dbSelectArea( "TMZ" )
	dbSetOrder( 01 )
	If dbSeek( xFilial( "TMZ" ) + MV_PAR03 )
		ProcRegua( Recno() )
		IncProc()
		lImp := .T.  // Variavel para controle de impressao.
		NGSomali( 58 ) //PulaLinha
		NGSomali( 58 )
		NGSomali( 58 )
		@ Li, 000 Psay STR0022 // "Declara��o:"
		nLinhasMemo := MLCOUNT( TMZ->TMZ_DESCRI, 200 )
		For LinhaCorrente := 1 to nLinhasMemo
			If lPrimeiro
				If !Empty( ( MemoLine( TMZ->TMZ_DESCRI, 200, LinhaCorrente ) ) )
					@ Li, 012 Psay ( MemoLine( TMZ->TMZ_DESCRI, 200, LinhaCorrente ) )
					lPrimeiro := .F.
				Else
					Exit
				Endif
			Else
				@ Li, 012 Psay ( MemoLine( TMZ->TMZ_DESCRI, 200, LinhaCorrente ) )
			EndIf
			NGSomali( 58 )
		Next
		NGSomali( 58 )
		NGSomali( 58 )
		@ Li, 000 Psay STR0023 // "Ass.:"
		NGSomali( 58 )
		NGSomali( 58 )
		@ Li, 005 Psay Replicate( "_", nLinha ) // Replicada uma linha horizontol.
		NGSomali( 58 )
		cFunc := ALLTRIM( SRA->RA_NOME )
		nTam  := nLinha - Len( cFunc )
	   	@ Li, 005 Psay Padr( Padl( cFunc, nLinha - ( nTam / 2 ) ), nLinha )
	EndIf

	If lImp
		RODA( nCntImpr, cRodaTxt, Tamanho )
		Set Device To Screen
		If aReturn[5] == 1
		   Set Printer To
		   dbCommitAll()
		   OurSpool( WnRel )
		EndIf
		MS_FLUSH()
	Else
		MsgInfo( STR0021 ) //"N�o existem dados para montar o relat�rio."
	Endif

	// Devolve a condicao original do arquivo principal
	RetIndex( "SRA" )
	Set Filter To

Return .T.