#INCLUDE "MDTR998.ch"
#INCLUDE "protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR998
Impress�o do relat�rio de Exposi��o Radioativa Anual.

@type Function
@author Elynton Fellipe Bazzo
@since 19/04/2013
@sample MDTR998()

@return  Nil, Sempre Nulo
/*/
//---------------------------------------------------------------------
Function MDTR998()

	Local aMeses   := { "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" }
   	Local nMes     := 0
	Local nAno     := 0
	Local dDataAtu := CTOD( "  /  /    " )
	Local nI       := 0

	Private cString   := "SRA"
	Private wnrel     := STR0004 // "MDTR998" - Nome do relat�rio
	Private limite    := 220 // Limite do Relat�rio

	Private cDesc1    := STR0002 // "O Objetivo deste relat�rio � exibir detalhadamente as doses de radia��o, "
	Private cDesc2    := STR0003 // "visualiza��o m�s a m�s dos 12 meses."
	Private cDesc3    := ""
	Private aPerg     := {}
	Private aPosicoes := {}

	Private nomeprog := STR0004 // Define o nome do programa.
	Private Tamanho  := "G"     // Define o Tamanho do relat�rio.
	//Define as propriedades do relatorio
	Private aReturn  := { STR0009, 1, STR0010, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
	Private titulo   := STR0001 //"Resultado das doses de exposi��o Radioativa Anual"
	Private ntipo    := 0       //Define o tipo de acordo com as propriedades
	Private nLastKey := 0       //Variavel de controle dos botoes do SetPrint
	Private cPerg    := "MDT998"
	Private cabec1   := STR0005 // "Ponto              Tipo do Local                                 Dist�ncia      "
	Private cabec2   := ""      //Cabecalhos

	/*------------------------------
	//PADR�O				    	|
	|  Matr�cula ?					|
	|  A partir de ?				|
	|  Termo Responsabilidade ?		|
	---------------------------------*/

	If FindFunction( 'MDTChkTJ7' )

		If  MDTChkTJ7() // Verifica o tamanho do campo TJ7_CODIGO

			Pergunte( cPerg, .F. )

			//Envia controle para a funcao SETPRINT
			wnrel:=SetPrint( cString, wnrel, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., {}, , Tamanho )

			// Gera cabe�alho
			nMes     	:= Month( MV_PAR02 )
			nAno     	:= Year( MV_PAR02 )
			dDataAtu	:= MV_PAR02
			nCol 	 	:= 80 // posiciona a dose da dosimetria em rela��o ao m�s informado.

			If nMes >= 1
				For nI := 1 To 12
					cabec1 += aMeses[nMes] + "/" + cValToChar( nAno ) + Space( 4 )
					aAdd( aPosicoes, { Month( dDataAtu ), nCol } )
					dDataAtu	:= NGSomaMes( dDataAtu, 1 )
					nAno     	:= Year( dDataAtu )
					nMes     	:= Month( dDataAtu )
					nCol     	+= 12
				Next nI
			Endif

			If nLastKey = 27
				Set Filter To
				Return .F.
			Endif

			SetDefault( aReturn, cString )
			Processa({ |lEnd| R998Imp( @lEnd, wnRel, titulo, tamanho )}, STR0012 ) //"Processando Registros..."
		EndIf
	Else
		MsgStop( STR0023 ) //"Seu ambiente encontra-se desatualizado ou com inconsist�ncias no campo C�digo (TJ7_CODIGO) da tabela de Servi�os (TJ7). Favor atualizar o ambiente."
	EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} R998Imp
Fun��o que realiza a impress�o do relat�rio de Exposi��o Radioativa.

@type Static Function
@author Elynton Fellipe Bazzo
@since 19/04/2013
@sample R998Imp( .T. )
@param lEnd, L�gico, Controle de Encerramento do Relat�rio

@return  L�gico, Sempre verdadeiro
/*/
//---------------------------------------------------------------------
Static Function R998Imp( lEnd )

	Local lImp		:= .F. //Variavel para controle de impressao.
	Local cRodaTxt 	:= ""
	Local nCntImpr 	:= 0
	Local nLinha   	:= 40
	Local nTam     	:= 0
	Local cFunc		:= ""
	Local lPrimeiro
	Local LinhaCorrente
	Local nLinhasMemo

	Private li := 80, m_pag := 1

	//Verifica se deve imprimir ou n�o
	nTipo  := IIF( aReturn[4] == 1, 15, 18 )

	// Impress�o dos dados do funcion�rio.
	dbSelectArea( "SRA" )
	dbSetOrder( 01 )
	If dbSeek( xFilial( "SRA" ) + MV_PAR01 )
		ProcRegua( Recno() )
		IncProc()
		lImp := .T.
		NGSomali( 58 )
		cIdade := Alltrim( Str( Int(( dDataBase - SRA->RA_NASC ) / 365 ), 10 ) )
		@ Li, 000 Psay STR0013 // "Funcion�rio:"
		@ Li, 013 Psay SRA->RA_MAT
		@ Li, 020 Psay STR0014 // " - "
		@ Li, 023 Psay SRA->RA_NOME
		@ Li, 080 Psay STR0015 // "C. Custo:"
		@ Li, 090 Psay SRA->RA_MAT
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
	dbSetOrder( 02 ) // TJ7_FILIAL+TJ7_CODIGO
	dbSeek( xFilial( "TJ7" ) + Padr( MV_PAR01, 6 ) )
	While !Eof() .And. Alltrim( TJ7->TJ7_CODIGO ) == Padr( MV_PAR01, 6 )
		If TJ7->TJ7_TIPREG == "2"
			If TJ7->TJ7_DATA < MV_PAR02 .Or. TJ7->TJ7_DATA > ( NGSomaMes( MV_PAR02,12 ) )
	 			DbSelectArea( "TJ7" )
	 	   		DbSkip()
	 			Loop
			ElseIf TJ7->TJ7_DATA >= MV_PAR02 // verifica a data a partir da qual as medi��es ser�o consideradas para o relat�rio.
				ProcRegua(Recno())
				IncProc()
				lImp := .T.
				NGSomali(58)
				@ Li,000 Psay TJ7->TJ7_PONTO
				@ Li,019 Psay TJ7->TJ7_TIPO
				@ Li,065 Psay TJ7->TJ7_DISTAN
				nPos := aScan( aPosicoes,{|x| x[1] == Month(TJ7->TJ7_DATA)} )
				@ Li,aPosicoes[nPos][2] Psay TJ7->TJ7_DOSE
	  			NGSomali(58)
	  		EndIf
	  	EndIf
   		dbSelectArea( "TJ7" )
   		dbSkip()
   	End

	NGSomali( 58 )
	NGSomali( 58 )
 	@ Li, 000 Psay Replicate( STR0022, 220 ) // Replica uma linha que sepra os dados do Funcion�rio e dados da dosimetria com a declara��o e ass.

	// Impress�o do termos de responsabilidade.
	dbSelectArea( "TMZ" )
	dbSetOrder( 01 )
	If dbSeek( xFilial( "TMZ" ) + MV_PAR03 )
		ProcRegua( Recno() )
		IncProc()
		lImp := .T.
		NGSomali( 58 )
		NGSomali( 58 )
		NGSomali( 58 )
		@ Li, 000 Psay STR0019 // "Declara��o:"
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
		@ Li, 000 Psay STR0020 // "Ass.:"
		NGSomali( 58 )
		NGSomali( 58 )
		@ Li, 005 Psay Replicate( STR0022, nLinha ) // Replica uma linha horizontal, separando as informa��es.
		NGSomali( 58 )
		cFunc := ALLTRIM( SRA->RA_NOME )
		nTam := nLinha - Len( cFunc )
	   	@ Li, 005 Psay Padr( Padl( cFunc, nLinha - ( nTam / 2 ) ), nLinha )
	EndIf

	If lImp
		RODA( nCntImpr, cRodaTxt, Tamanho ) // Roda - Impress�o de rodap� no relat�rio
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

	//Devolve a condicao original do arquivo principal
	RetIndex( "SRA" )
	Set Filter To

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} R998XBTJ7
Fun��o que busca os funcion�rios (SRA) que possuem registros dentro da rotina
de Medi��o de Dosimentria (TJ7). Tamb�m utilizada na sa�da das perguntas de Matr�cula
dos relat�rios MDTR997 e MDTR998.

@type Function
@author Roberta S. Borchardt
@since 20/07/2020
@param, caracter, indica a matr�cula que � informada na pergunta dos SX1 MDT997 e MDT998.

@return  lRet, verdadeiro se encontrar o Funcion�rio
/*/
//---------------------------------------------------------------------
Function R998XBTJ7(cMAT)

	Local lRet	:= .F.
	Local aArea

	Default cMat := " "

	//Se a chamada for na sa�da do campo das perguntas
	If !Empty( cMAT )
		dbSelectArea( "TJ7" )
		dbSetOrder( 3 )// TJ7_FILIAL+TJ7_TIPREG+TJ7_CODIGO+DTOS(TJ7_DATA)
		If 	dbSeek( xFilial( "TJ7" ) + '2' + cMAT )
			lRet:= .T.
		Else
			MsgStop( STR0024, STR0025 )//"Este c�digo de funcion�rio n�o existe na Medi��o de Dos�metro."###"ATEN��O"
			lRet:= .F.
		EndIf
	//Se a chamada for via F3
	Else
		aArea := GetArea()
		dbSelectArea( "TJ7" )
		dbSetOrder( 2 )// TJ7_FILIAL+TJ7_CODIGO
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
			lRet := .T.
		End
		RestArea( aArea )
	EndIf

Return lRet