#INCLUDE "PROTHEUS.CH"
#INCLUDE "MDTA882.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA882
Job que realiza a verifica��o di�ria de poss�veis novos per�odos de tarefas
dos funcion�rios para envio ao TAF (eSocial).

@return

@sample MDTA882()

@author Luis Fellipy Bett
@since 27/03/18
/*/
//---------------------------------------------------------------------
Function MDTA882()

	//Armazena as vari�veis
	Local aNGBEGINPRM

	If FindFunction( "MDTIntEsoc" )
		If IsBlind() //Se via schedule

			If !fProcTar( .T. ) //Processa gera��o
				FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA882', '', '01', STR0001, 0, 0, {} ) //"Erro na execu��o do Schedule, favor verificar!"
			Else
				FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA882', '', '01', STR0002, 0, 0, {} ) //"Execu��o do Schedule realizada com sucesso!"
			EndIf

		Else //Se via rotina

			aNGBEGINPRM := NGBEGINPRM()

			If fProcTar() //Processa a valida��o e envio do evento S-2240 ao Governo
				Help( ' ', 1, STR0003, , STR0004, 2, 0 ) //"Aten��o"##"Processamento realizado com sucesso!"
			EndIf

			NGRETURNPRM( aNGBEGINPRM )
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcTar
Fun��o que envia os dados da tarefa do funcion�rio ao TAF (eSocial).

@return lRet

@sample fProcTar()

@author Luis Fellipy Bett
@since 27/03/18
/*/
//---------------------------------------------------------------------
Function fProcTar( lSchedule )

	Local lRet		:= .T.
	Local lErro		:= .F.
	Local cMsg		:= ""
	Local cDirFile  := '\esocial_mdt'

	Default lSchedule := .F.

	If !lSchedule //Se for execu��o via rotina

		lRet := fRisS2240()

	Else //Se for execu��o via Schedule

		If !File( cDirFile )
			MakeDir( cDirFile )
		EndIf

		cArqPesq := cDirFile + "\mdt_evts2240_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"

		cMsg += "----------------------     MDTA882 | " + DToC( Date() ) + " " + Time() + "     ----------------------"

		If lRet := fRisS2240( @cMsg )
			cMsg += CRLF + "----------   " + STR0003 + " " + STR0005 + "   ----------" //"Aten��o!"##"Envio ao SIGATAF/Middleware realizado com sucesso!"
		Else
			cMsg += CRLF + "--------------   " + STR0003 + " " + STR0006 + "   --------------" //"Aten��o!"##"Envio ao SIGATAF/Middleware n�o realizado!"
		EndIf

		nHandle := FCREATE( cArqPesq, 0 ) //Cria arquivo no diret�rio

		//----------------------------------------------------------------------------------
		// Verifica se o arquivo pode ser criado, caso contrario um alerta sera exibido
		//----------------------------------------------------------------------------------
		If FERROR() <> 0
			lErro := .T.
		Endif

		If !lErro
			FWrite( nHandle, cMsg )

			FCLOSE( nHandle )
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fRisS2240
Fun��o para validar o envio do evento S-2240 ao TAF, na p�s valida��o
do cadastro valida os dados e ap�s a grava��o envia ao TAF

@sample fRisS2240()

@param lValid, L�gico, indica se far� a valida��o dos dados ou o envio

@author  Luis Fellipy Bett
@since   08/08/2019
/*/
//-------------------------------------------------------------------
Static Function fRisS2240( cMsg )

	Local lRet     := .T.
	Local nCont    := 0
	Local aFuncTot := {}
	Local aFuncs   := {}

	Default cMsg := ""

	//Pega todos os funcion�rios ativos
	aFuncTot := MDTGetFunc()

	For nCont := 1 To Len( aFuncTot )

		//Tarefas por Funcion�rio
		dbSelectArea( "TN6" )
		dbSetOrder( 2 ) //TN6_FILIAL+TN6_MAT
		dbSeek( xFilial( "TN6" ) + aFuncTot[ nCont, 1 ] )
		While xFilial( "TN6" ) == TN6->TN6_FILIAL .And. TN6->TN6_MAT == aFuncTot[ nCont, 1 ]
			If TN6->TN6_DTINIC = dDataBase .Or. TN6->TN6_DTTERM = dDataBase
				aAdd( aFuncs, { aFuncTot[ nCont, 1 ], , , TN6->TN6_CODTAR, TN6->TN6_DTINIC, TN6->TN6_DTTERM } )
				Exit
			EndIf
			TN6->( dbSkip() )
		End

	Next nCont

	If Len( aFuncs ) > 0
		lRet := MDTIntEsoc( "S-2240", 4, , aFuncs, .T., , , @cMsg ) //Valida e envia informa��es ao Governo
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execu��o de Par�metros na Defini��o do Schedule

@return aParam, Array, Conteudo com as defini��es de par�metros para WF

@sample SchedDef()

@author Alexandre Santos
@since 04/07/2018
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return { "P", "PARAMDEF", "", {}, "Param" }
