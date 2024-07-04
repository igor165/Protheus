#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} ngIntegra
Fonte com as integrações realizadas por parte da NG.

@author Gabriel Sokacheski
@since 16/05/2022

@param aParam, contém os parâmetros que serão utilizados na função
/*/
//---------------------------------------------------------------------
Function NgIntegra( aParam )

    //Salva a área
    Local aArea := GetArea()

    //Variável de controle (não excluir pois é utilizada no retorno da NgIntegra no GPEA010)
    Local lRet := .T.

    //Variáveis de chamadas
    Local lGpea010 := FWIsInCallStack( 'Gpea010' ) //Cadastro de funcionário
    Local lRspm001 := FWIsInCallStack( 'Rspm001' ) //Admissão de candidato
    Local lGpem040 := FWIsInCallStack( 'Gpem040' ) //Rescisão de funcionário

    //Caso for chamado pelo módulo do GPE e houver integração
    If ( cModulo == 'GPE' .Or. cModulo == 'RSP' ) .And. SuperGetMv( 'MV_MDTGPE', Nil, 'N' ) == 'S'

        Do Case
            Case lGpea010 .Or. lRspm001 // Cadastro de funcionário
                fCadFun( aParam )
            Case lGpem040 // Rescisão de funcionário
                fRescFun( aParam )
        EndCase

    EndIf

    //Retorna a área
    RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fCadFun
Faz as chamadas das funções do processo de cadastro de funcionário

@author Luis Fellipy Bett
@since  07/06/2022

@param aParam, contém os parâmetros que serão utilizados na função
    1° Posição: Operação que está sendo realizada (inclusão ou alteração)
    2° Posição: Indica se é admissão preliminar
/*/
//---------------------------------------------------------------------
Static Function fCadFun( aParam )

    //Salva a área
    Local aArea := GetArea()

    //Variáveis de parâmetros
    Local lMDTAdic := SuperGetMv( "MV_MDTADIC", , .F. )

    //Variáveis de chamadas
    Local lGPEA180 := FWIsInCallStack( "GPEA180" )

    //Variáveis de busca das informações
    Local nOpc    := aParam[ 1 ]
    Local lAdmPre := aParam[ 2 ]
    Local cVerGPE := ""

    //---------------------------------------------------------
    // Verifica o fluxo a ser seguido de acordo com a operação
    //---------------------------------------------------------
    If nOpc == 3 //Inclusão

        //Inclui a ficha médica do funcionário
        If FindFunction( "MdtAltTrf" )

            MdtAltTrf( xFilial( "SRA" ), SRA->RA_MAT )

        EndIf

    ElseIf nOpc == 4 //Alteração

        //Altera a ficha médica do funcionário (se necessário)        
        If FindFunction( "MdtAltFicha" )

            MdtAltFicha( xFilial( "SRA" ), SRA->RA_MAT )

        EndIf

        //Caso os campos estejam na memória
        If IsMemVar( "RA_SITFOLH" ) .And. IsMemVar( "RA_DEMISSA" )

            //Caso o funcionário foi demitido
            If ( M->RA_SITFOLH == "D" ) .Or. ( !Empty( M->RA_DEMISSA ) )

                If FindFunction( "MdtDelExames" )

                    //Deleta os exames do funcionário
                    MdtDelExames( SRA->RA_MAT, xFilial( "SRA" ), M->RA_DEMISSA )

                EndIf

                If FindFunction( "MdtDelCandCipa" )

                    //Deleta a candidatura da CIPA
                    MdtDelCandCipa( SRA->RA_MAT )

                EndIf

            EndIf

        EndIf

    EndIf

    //Verifica se é o SIGAMDT que ajustará a insalubridade/periculosidade
    If lMDTAdic

        //Verifica se a função existe no RPO
        If FindFunction( "MDT180AGL" ) .And. SRJ->( ColumnPos( "RJ_CUMADIC" ) ) > 0 .And. Posicione( "SRJ", 1, xFilial( "SRJ" ) + SRA->RA_CODFUNC, "RJ_CUMADIC" ) == "2"

            MDT180AGL( SRA->RA_MAT, "", SRA->RA_FILIAL, nOpc )

        ElseIf FindFunction( "MDT180INT" )

            MDT180INT( SRA->RA_MAT, "", .F., nOpc, SRA->RA_FILIAL )//Preenchimento dos campos de Insalubridade e periculosidade da SRA

        EndIf

    EndIf

    //Integração do S-2240 com o SIGATAF/Middleware
    If FindFunction( "MDTIntEsoc" )

        //Busca a versão de envio do SIGAGPE
        fVersEsoc( "S2200", .F., , , @cVerGPE )

        //Caso não for admissão preliminar, o leiaute for maior ou igual ao S-1.0 e não for chamada pelo GPEA180
        If !( lAdmPre .And. cVerGPE < "9.0.00" ) .And. !lGPEA180

            //Integra o evento com o TAF/Mid
            MDTIntEsoc( "S-2240", nOpc, , { { SRA->RA_MAT } }, .T. )

        EndIf

    EndIf

    //Retorna a área
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fRescFun
Faz as chamadas das funções do processo de rescisão de funcionário

@author Luis Fellipy Bett
@since  07/06/2022

@param aParam, contém os parâmetros que serão utilizados na função
    1° Posição: Matrícula do funcionário
    2° Posição: Data de demissão/rescisão
/*/
//---------------------------------------------------------------------
Static Function fRescFun( aParam )

    //Salva a área
    Local aArea := GetArea()

    //Variáveis de busca das informações
    Local cMatFun := aParam[ 1 ]
    Local dDtResc := aParam[ 2 ]

    //Finaliza o programa de saúde e as tarefas do funcionário
    fTermFunc( cMatFun, dDtResc )

    //Deleta os exames do funcionário
    MdtDelExames( cMatFun, xFilial( "SRA" ), dDtResc )

    //Deleta a candidatura da CIPA do funcionário
    MdtDelCandCipa( cMatFun )

    //Retorna a área
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fTermFunc
Termina o programa de saúde e a tarefa do funcionário de acordo com a
data de rescisão.

@author Gabriel Sokacheski
@since  16/05/2022

@param cMatFun, Caracter, Matrícula do funcionário
@param dDtResc, Data, Data de rescisão de contrato do funcionário
/*/
//---------------------------------------------------------------------
Static Function fTermFunc( cMatFun, dDtResc )

    Local aFun := {}
    Local aArea := GetArea()

    Local lGera2240 := SuperGetMV( 'MV_MDTENRE', Nil, .T. )

    //Posiciona na ficha médica do funcionário para buscar pelo programa de saúde
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

    //Posiciona nas tarefas do funcionário
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

    //Retorna a área
    RestArea( aArea )

Return
