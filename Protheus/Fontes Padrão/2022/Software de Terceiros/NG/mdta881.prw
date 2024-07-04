#INCLUDE "MDTA881.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA881
Carga Inicial dos registros do evento S-2240 (Riscos)

@return Nil, sempre nulo

@sample MDTA881()

@author	Luis Fellipy Bett
@since	07/08/2017
/*/
//---------------------------------------------------------------------
Function MDTA881()

	//Armazena as vari�veis
	Local aNGBEGINPRM := NGBEGINPRM()
	Local aSay		:= {}
	Local aButton	:= {}
	Local nOpc		:= 0
	Local leSocial	:= IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )
	Local lFirst	:= SuperGetMv( "MV_NG2BLEV", .F., "2" ) == "1"

	If leSocial
		If lFirst .And. FindFunction( "MDTIntEsoc" )
			aAdd( aSay, STR0001 ) //"Esta rotina realiza a carga inicial dos Riscos, referente ao evento S-2240 do"
			aAdd( aSay, STR0002 ) //"eSocial, a serem integrados com o Governo atrav�s do SIGATAF ou Middleware"
			aAdd( aSay, STR0003 ) //"Importante: Deve ser executado uma �nica vez por empresa"

			aAdd( aButton, { 1, .T., { | | nOpc := 1, FechaBatch() } } )
			aAdd( aButton, { 2, .T., { | | FechaBatch() } } )

			FormBatch( STR0004, aSay, aButton ) //"CARGA INICIAL DO EVENTO S-2240 DO ESOCIAL"

			If nOpc == 1
				Begin Transaction

				If !fRisS2240()
					DisarmTransaction()
					RollBackSX8()
				Else
					Help( ' ', 1, STR0005, , STR0006, 2, 0 ) //"Aten��o"##"Carga inicial realizada com sucesso!"
					PUTMV( "MV_NG2BLEV", "2" ) //Seta valor para que n�o seja poss�vel abrir a rotina mais de 1 vez
				EndIf

				End Transaction
			EndIf
		Else
			Help( ' ', 1, STR0005, , STR0007, 2, 0 ) //"Aten��o"##"Essa a��o j� foi realizada ou o dicion�rio n�o est� devidamente atualizado, favor verificar!"
		EndIf
	Else
		Help( ' ', 1, STR0005, , STR0008, 2, 0, , , , , , { STR0009 } ) //"Aten��o"##"O par�metro de integra��o com o eSocial (MV_NG2ESOC) est� desabilitado"##"Para realizar a carga inicial habilite o par�metro"
	EndIf

	// Devolve as vari�veis armazenadas
	NGRETURNPRM( aNGBEGINPRM )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fRisS2240
Realiza a valida��o e envio das informa��es do evento S-2240 ao Governo

@sample fRisS2240()

@return lRet, Boolean, .T. caso n�o existam inconsist�ncias no envio

@author Luis Fellipy Bett
@since	17/03/2021
/*/
//---------------------------------------------------------------------
Static Function fRisS2240()

	//Salva a �rea
	Local aArea := GetArea()

	//Vari�veis para busca das informa��es
	Local aFuncs := {}
	Local lRet := .T.

	//Vari�veis private utilizadas no processo
	Private lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )
	Private lGPEA180 := .F. //Define a vari�vel de chamada da rotina de transfer�ncias como .F.

	//Pega todos os funcion�rios ativos
	aFuncs := MDTGetFunc()

	//Valida se os funcion�rios est�o afastados por motivo diferente de f�rias e licen�a maternidade
	fVldAfas( @aFuncs )

	//Valida se o evento S-2240 j� existe no SIGATAF
	fEveExis( @aFuncs )

	If Len( aFuncs ) > 0
		lRet := MDTIntEsoc( "S-2240", 3, , aFuncs, .T. ) //Envia informa��es ao Governo
	EndIf

	//Retorna a �rea
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAfas
Valida se os funcion�rios a serem carregados na carga inicial est�o afastados
por motivo diferente de f�rias ou licen�a maternidade

@return	 Nil, Nulo

@sample	 fVldAfas( { { "100016" } } )

@param	 aFunVld, Array, Array contendo os funcion�rios a serem validados

@author  Luis Fellipy Bett
@since   03/02/2022
/*/
//-------------------------------------------------------------------
Static Function fVldAfas( aFunVld )

	//Salva a �rea
	Local aArea := GetArea()
	
	//Vari�veis para busca das informa��es
	Local dDtEsoc := SuperGetMv( "MV_NG2DTES", .F., SToD( "20211013" ) )
	Local dDtAdmi := SToD( "" )
	Local dDtEnv  := SToD( "" )
	Local aArrExc := {}
	Local nPosReg := 0
	Local nCont	  := 0

	//Valida todos os funcion�rios verificando os afastamentos
	For nCont := 1 To Len( aFunVld )

		//Busca a data de admiss�o do funcion�rio
		dDtAdmi := Posicione( "SRA", 1, xFilial( "SRA", aFunVld[ nCont, 2 ] ) + aFunVld[ nCont, 1 ], "RA_ADMISSA" )

		//Verifica se considera o in�cio de obrigatoriedade ou a admiss�o do funcion�rio
		If dDtAdmi > dDtEsoc
			dDtEnv := dDtAdmi
		Else
			dDtEnv := dDtEsoc
		EndIf
		
		//Valida todos os afastamentos do funcion�rio verificando se s�o diferente de f�rias ou licen�a maternidade
		dbSelectArea( "SR8" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "SR8", aFunVld[ nCont, 2 ] ) + aFunVld[ nCont, 1 ] )
			While SR8->( !Eof() ) .And. SR8->R8_FILIAL == xFilial( "SR8", aFunVld[ nCont, 2 ] ) .And. SR8->R8_MAT == aFunVld[ nCont, 1 ]
				
				//Verifica se o funcion�rio est� afastado no momento da carga e se o afastamento � diferente de f�rias e licen�a maternidade
				If !( SR8->R8_TIPOAFA $ "001/006/007/008/010/011/012" ) .And. dDtEnv >= SR8->R8_DATAINI .And. ( dDtEnv <= SR8->R8_DATAFIM .Or. Empty( SR8->R8_DATAFIM ) )
					
					//Caso o funcion�rio n�o existir no array
					If aScan( aArrExc, { |x| x == aFunVld[ nCont, 1 ] } ) == 0
						aAdd( aArrExc, aFunVld[ nCont, 1 ] )
					EndIf

				EndIf

				SR8->( dbSkip() )
			End
		EndIf
	
	Next nCont

	//Exclui do array de funcion�rios os que n�o devem ser enviados
	For nCont := 1 To Len( aArrExc )

		nPosReg := aScan( aFunVld, { |x| x[ 1 ] == aArrExc[ nCont ] } )
		aDel( aFunVld, nPosReg ) //Deleta registro do array
		aSize( aFunVld, Len( aFunVld ) - 1 ) //Diminui a posi��o exclu�da do array

	Next nCont

	//Retorna a �rea
	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fEveExis
Valida se o evento S-2240 j� existe para o funcion�rio

@return	 Nil, Nulo

@sample	 fEveExis( { { "100016" } } )

@param	 aFunVld, Array, Array contendo os funcion�rios a serem validados

@author  Luis Fellipy Bett
@since   03/02/2022
/*/
//-------------------------------------------------------------------
Static Function fEveExis( aFunVld )

	//Salva a �rea
	Local aArea := GetArea()

	//Vari�veis para busca das informa��es
	Local aArrExc := {}
	Local nPosReg := 0
	Local nCont	  := 0

	//Percorre os funcion�rios verificando quem j� possui registro do S-2240 no SIGATAF/Middleware
	For nCont := 1 To Len( aFunVld )

		If MDTVld2240( aFunVld[ nCont, 1 ], aFunVld[ nCont, 2 ] )
			aAdd( aArrExc, aFunVld[ nCont, 1 ] ) //Salva a matr�cula do funcion�rio no array
		EndIf

	Next nCont

	//Exclui do array de funcion�rios os que n�o devem ser enviados
	For nCont := 1 To Len( aArrExc )

		nPosReg := aScan( aFunVld, { |x| x[ 1 ] == aArrExc[ nCont ] } )
		aDel( aFunVld, nPosReg ) //Deleta registro do array
		aSize( aFunVld, Len( aFunVld ) - 1 ) //Diminui a posi��o exclu�da do array

	Next nCont

	//Retorna a �rea
	RestArea( aArea )

Return
