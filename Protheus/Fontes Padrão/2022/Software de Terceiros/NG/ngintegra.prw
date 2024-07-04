#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} ngIntegra
Fonte com as integra��es realizadas por parte da NG.

@author Gabriel Sokacheski
@since 16/05/2022

@param aParam, cont�m os par�metros que ser�o utilizados na fun��o
/*/
//---------------------------------------------------------------------
Function NgIntegra( aParam )

    //Salva a �rea
    Local aArea := GetArea()

    //Vari�vel de controle (n�o excluir pois � utilizada no retorno da NgIntegra no GPEA010)
    Local lRet := .T.

    //Vari�veis de chamadas
    Local lGpea010 := FWIsInCallStack( 'Gpea010' ) //Cadastro de funcion�rio
    Local lRspm001 := FWIsInCallStack( 'Rspm001' ) //Admiss�o de candidato
    Local lGpem040 := FWIsInCallStack( 'Gpem040' ) //Rescis�o de funcion�rio

    //Caso for chamado pelo m�dulo do GPE e houver integra��o
    If ( cModulo == 'GPE' .Or. cModulo == 'RSP' ) .And. SuperGetMv( 'MV_MDTGPE', Nil, 'N' ) == 'S'

        Do Case
            Case lGpea010 .Or. lRspm001 // Cadastro de funcion�rio
                fCadFun( aParam )
            Case lGpem040 // Rescis�o de funcion�rio
                fRescFun( aParam )
        EndCase

    EndIf

    //Retorna a �rea
    RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCadFun
Faz as chamadas das fun��es do processo de cadastro de funcion�rio

@author Luis Fellipy Bett
@since  07/06/2022

@param aParam, cont�m os par�metros que ser�o utilizados na fun��o
    1� Posi��o: Opera��o que est� sendo realizada (inclus�o ou altera��o)
    2� Posi��o: Indica se � admiss�o preliminar
/*/
//---------------------------------------------------------------------
Static Function fCadFun( aParam )

    //Salva a �rea
    Local aArea := GetArea()

    //Vari�veis de par�metros
    Local lMDTAdic := SuperGetMv( "MV_MDTADIC", , .F. )

    //Vari�veis de chamadas
    Local lGPEA180 := FWIsInCallStack( "GPEA180" )

    //Vari�veis de busca das informa��es
    Local nOpc    := aParam[ 1 ]
    Local lAdmPre := aParam[ 2 ]
    Local cVerGPE := ""

    //---------------------------------------------------------
    // Verifica o fluxo a ser seguido de acordo com a opera��o
    //---------------------------------------------------------
    If nOpc == 3 //Inclus�o

        //Inclui a ficha m�dica do funcion�rio
        If FindFunction( "MdtAltTrf" )

            MdtAltTrf( xFilial( "SRA" ), SRA->RA_MAT )

        EndIf

    ElseIf nOpc == 4 //Altera��o

        //Altera a ficha m�dica do funcion�rio (se necess�rio)        
        If FindFunction( "MdtAltFicha" )

            MdtAltFicha( xFilial( "SRA" ), SRA->RA_MAT )

        EndIf

        //Caso os campos estejam na mem�ria
        If IsMemVar( "RA_SITFOLH" ) .And. IsMemVar( "RA_DEMISSA" )

            //Caso o funcion�rio foi demitido
            If ( M->RA_SITFOLH == "D" ) .Or. ( !Empty( M->RA_DEMISSA ) )

                If FindFunction( "MdtDelExames" )

                    //Deleta os exames do funcion�rio
                    MdtDelExames( SRA->RA_MAT, xFilial( "SRA" ), M->RA_DEMISSA )

                EndIf

                If FindFunction( "MdtDelCandCipa" )

                    //Deleta a candidatura da CIPA
                    MdtDelCandCipa( SRA->RA_MAT )

                EndIf

            EndIf

        EndIf

    EndIf

    //Verifica se � o SIGAMDT que ajustar� a insalubridade/periculosidade
    If lMDTAdic

        //Verifica se a fun��o existe no RPO
        If FindFunction( "MDT180AGL" ) .And. SRJ->( ColumnPos( "RJ_CUMADIC" ) ) > 0 .And. Posicione( "SRJ", 1, xFilial( "SRJ" ) + SRA->RA_CODFUNC, "RJ_CUMADIC" ) == "2"

            MDT180AGL( SRA->RA_MAT, "", SRA->RA_FILIAL, nOpc )

        ElseIf FindFunction( "MDT180INT" )

            MDT180INT( SRA->RA_MAT, "", .F., nOpc, SRA->RA_FILIAL )//Preenchimento dos campos de Insalubridade e periculosidade da SRA

        EndIf

    EndIf

    //Integra��o do S-2240 com o SIGATAF/Middleware
    If FindFunction( "MDTIntEsoc" )

        //Busca a vers�o de envio do SIGAGPE
        fVersEsoc( "S2200", .F., , , @cVerGPE )

        //Caso n�o for admiss�o preliminar, o leiaute for maior ou igual ao S-1.0 e n�o for chamada pelo GPEA180
        If !( lAdmPre .And. cVerGPE < "9.0.00" ) .And. !lGPEA180

            //Integra o evento com o TAF/Mid
            MDTIntEsoc( "S-2240", nOpc, , { { SRA->RA_MAT } }, .T. )

        EndIf

    EndIf

    //Retorna a �rea
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fRescFun
Faz as chamadas das fun��es do processo de rescis�o de funcion�rio

@author Luis Fellipy Bett
@since  07/06/2022

@param aParam, cont�m os par�metros que ser�o utilizados na fun��o
    1� Posi��o: Matr�cula do funcion�rio
    2� Posi��o: Data de demiss�o/rescis�o
/*/
//---------------------------------------------------------------------
Static Function fRescFun( aParam )

    //Salva a �rea
    Local aArea := GetArea()

    //Vari�veis de busca das informa��es
    Local cMatFun := aParam[ 1 ]
    Local dDtResc := aParam[ 2 ]

    //Finaliza o programa de sa�de e as tarefas do funcion�rio
    fTermFunc( cMatFun, dDtResc )

    //Deleta os exames do funcion�rio
    MdtDelExames( cMatFun, xFilial( "SRA" ), dDtResc )

    //Deleta a candidatura da CIPA do funcion�rio
    MdtDelCandCipa( cMatFun )

    //Retorna a �rea
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fTermFunc
Termina o programa de sa�de e a tarefa do funcion�rio de acordo com a
data de rescis�o.

@author Gabriel Sokacheski
@since  16/05/2022

@param cMatFun, Caracter, Matr�cula do funcion�rio
@param dDtResc, Data, Data de rescis�o de contrato do funcion�rio
/*/
//---------------------------------------------------------------------
Static Function fTermFunc( cMatFun, dDtResc )

    Local aFun := {}
    Local aArea := GetArea()

    Local lGera2240 := SuperGetMV( 'MV_MDTENRE', Nil, .T. )

    //Posiciona na ficha m�dica do funcion�rio para buscar pelo programa de sa�de
    dbSelectArea( 'TM0' )
	dbSetOrder( 3 )
	If dbSeek( xFilial( 'TM0' ) + cMatFun )

		dbSelectArea( 'TMN' )
		dbSetOrder( 2 )

		If dbSeek( xFilial( 'TMN' ) + TM0->TM0_NUMFIC )

			While TMN->( !Eof() ) .And. TMN->TMN_NUMFIC == TM0->TM0_NUMFIC

				If Empty( TMN->TMN_DTTERM )

					RecLock( 'TMN', .F. )
						TMN->TMN_DTTERM := dDtResc
					TMN->( MsUnlock() )

				EndIf

				TMN->( dbSkip() )

			End

		EndIf

	EndIf

    //Posiciona nas tarefas do funcion�rio
    dbSelectArea( 'TN6' )
    dbSetOrder( 2 )
    If dbSeek( xFilial( 'TN6' ) + cMatFun )

        While TN6->( !Eof() ) .And. TN6->TN6_MAT == cMatFun

            If Empty( TN6->TN6_DTTERM )

                RecLock( 'TN6', .F. )
                    TN6->TN6_DTTERM := dDtResc
                TN6->( MsUnlock() )

                MdtEsoFimT()

            EndIf

            aAdd( aFun, { TN6->TN6_MAT, Nil, Nil, TN6->TN6_CODTAR, TN6->TN6_DTINIC, dDtResc } )

            TN6->( dbSkip() )

        End

        If lGera2240
            MdtIntEsoc( 'S-2240', 4, Nil, aFun, .T. )
        EndIf

    EndIf

    //Retorna a �rea
    RestArea( aArea )

Return
