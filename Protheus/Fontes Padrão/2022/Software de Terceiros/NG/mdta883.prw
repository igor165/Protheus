#INCLUDE "PROTHEUS.CH"
#INCLUDE "MDTA883.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA883
Rotina que realiza a verifica��o di�ria da altera��o das informa��es do
recibo da CAT, recibo da CAT origem e data do recebimento da CAT por
parte do governo. Essas informa��es devem ser atualizadas periodicamente
para que essas informa��es sejam impressas corretamente no relat�rio
da CAT eSocial (MDTR832). A rotina pode ser executada tanto via schedule
(job) ou manualmente atrav�s do bot�o "Outras A��es/Sincronizar Infos. CAT"
contido na rotina de cadastro de acidentes (MDTA640)

@return .T., Boolean, Sempre verdadeiro

@sample MDTA883()

@author Luis Fellipy Bett
@since  28/02/2022
/*/
//---------------------------------------------------------------------
Function MDTA883()

	//Armazena as vari�veis
	Local leSocial := IIf( FindFunction( "MDTVldEsoc" ), MDTVldEsoc(), .F. )
    Local aNGBEGINPRM

    //Vari�veis private utilizadas no processo
    Private lMiddleware := IIf( cPaisLoc == 'BRA' .And. Findfunction( "fVerMW" ), fVerMW(), .F. )
    Private lJob := IsBlind()

    //Caso a integra��o com o eSocial estiver habilitada
    If leSocial

        //Caso os campos novos do recibo existirem na tabela TNC
        If FindFunction( "MDT640Rcb" ) .And. MDT640Rcb( 1 )

            //---------------------------------------------------
            // Caso n�o for execu��o via job inicia as vari�veis
            //---------------------------------------------------
            If !lJob
                aNGBEGINPRM := NGBEGINPRM()
            EndIf

            //-------------------------------------------------------
            // Chama a fun��o de processamento das informa��s da CAT
            //-------------------------------------------------------
            fProcCAT()

            If lJob
                FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA883', '', '01', STR0002, 0, 0, {} ) //"Execu��o do schedule finalizada com sucesso!"
            Else
                Help( ' ', 1, STR0001, , STR0003, 2, 0 ) //"Processamento finalizado com sucesso!"
            EndIf

            //----------------------------------------------------
            // Caso n�o for execu��o via job retorna as vari�veis
            //----------------------------------------------------
            If !lJob
                NGRETURNPRM( aNGBEGINPRM )
            EndIf

        Else

            If lJob
                FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA883', '', '01', STR0004, 0, 0, {} ) //"O sistema n�o possui os campos TNC_RECIBO, TNC_RECORI e TNC_DTRECB no dicion�rio ou est� com o pacote de fontes desatualizado"
            Else
                Help( ' ', 1, STR0001, , STR0004, 2, 0, , , , , , { STR0005 } ) //"O sistema n�o possui os campos TNC_RECIBO, TNC_RECORI e TNC_DTRECB no dicion�rio ou est� com o pacote de fontes desatualizado" ## "Favor atualizar o sistema para poder utilizar a rotina de atualiza��o autom�tica dos campos do acidente"
            EndIf

        EndIf

    Else

        If lJob
            FWLogMsg( 'WARN', , 'BusinessObject', 'MDTA883', '', '01', STR0006, 0, 0, {} ) //"A integra��o com o eSocial n�o est� habilitada" ##
        Else
            Help( ' ', 1, "Aten��o", , STR0006, 2, 0, , , , , , { STR0007 } ) //"A integra��o com o eSocial n�o est� habilitada" ## "Favor ativar o par�metro MV_NG2ESOC para poder utilizar a rotina de atualiza��o autom�tica dos campos do acidente"
        EndIf

    EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fProcCAT
Fun��o que processa a busca as informa��es do recibo da CAT, recibo da
CAT origem e data do recebimento da CAT do SIGATAF/Middleware. Caso o
envio for via job cria as pastas e o arquivo .txt com as CAT's atualizadas
dentro da pasta system

@return Nil, Nulo

@sample fProcCAT()

@author Luis Fellipy Bett
@since  28/02/2022
/*/
//---------------------------------------------------------------------
Function fProcCAT()

    //Vari�veis de composi��o do arquivo .txt
	Local cBarras := IIf( IsSrvUnix(), "/", "\" )
    Local cDirPai := cBarras + 'esocial_mdt'
    Local cDirFil := cBarras + 'esocial_mdt' + cBarras + 'upd_cpos_cat'
    Local cMsgAux := ""
    Local cMsg    := ""

	//Se for execu��o via schedule
    If lJob

		//Verifica se a pasta pai existe na system
		If !File( cDirPai )
			MakeDir( cDirPai )
		EndIf

        //Verifica se a pasta filha existe na system
		If !File( cDirFil )
			MakeDir( cDirFil )
		EndIf

        //Define o nome do arquivo que ser� criado
		cArqPesq := cDirFil + cBarras + "mdta883_" + DToS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"

		//Cria arquivo no diret�rio
        nHandle := FCREATE( cArqPesq, 0 )

        //Caso o arquivo tenha sido criado corretamente
		If FERROR() == 0

            //Define cabe�alho da mensagem
            cMsg += "----------------------     MDTA883 | " + DToC( Date() ) + " " + Time() + "     ----------------------" + CRLF + CRLF

            //Chama a fun��o de atualiza��o dos campos
            fUpdCpsCAT( @cMsgAux )

            //Adiciona a mensagem retornada com as CAT's atualizadas
            cMsg += cMsgAux

            //Caso alguma CAT tiver sido atualizada
            If !Empty( cMsgAux )

                cMsg += CRLF + "----------------------     " + STR0008 + "    ----------------------" //"CAT's atualizadas com sucesso!"

            Else

                cMsg += CRLF + "------------------------    " + STR0009 + "    ------------------------" //"Nenhuma CAT foi atualizada!"

            EndIf

			FWrite( nHandle, cMsg )

			FCLOSE( nHandle )

		EndIf

	Else //Se for execu��o via rotina

        fUpdCpsCAT( @cMsg )

        //Caso alguma CAT tenha sido atualizada
        If !Empty( cMsg )

            NGMSGMEMO( STR0010, cMsg ) //"CAT's atualizadas"

        Else

            Help( ' ', 1, STR0001, , STR0009, 2, 0 ) //"Nenhuma CAT foi atualizada!"

        EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fUpdCpsCAT
Fun��o que gerencia as chamadas das fun��es de busca dos acidentes do
sistema, de busca das informa��es do recibo, recibo origem e data do 
recebimento da CAT por parte do governo e de atualiza��o dos campos
na tabela TNC

@sample fUpdCpsCAT( "" )

@param  cMsg, Caracter, Vari�vel que retorna por refer�ncia as CAT's
que foram atualizadas na tabela TNC

@return Nil, Nulo

@author Luis Fellipy Bett
@since  07/03/2022
/*/
//-------------------------------------------------------------------
Static Function fUpdCpsCAT( cMsg )

    //Salva a �rea
    Local aArea := GetArea()

    //Vari�veis de busca das informa��es
	Local aAcids := {}

    //--------------------------------------------------
    // Busca os acidentes a terem os campos atualizados
    //--------------------------------------------------
    If lJob
        aAcids := fGetCATs()
    Else
        Processa( { || aAcids := fGetCATs() }, STR0011 ) //"Aguarde, buscando acidentes..."
    EndIf

    //--------------------------------------------------------------------------------
    // Busca as informa��es do SIGATAF/Middleware para atualizar nos registros da TNC
    //--------------------------------------------------------------------------------
    If lJob
        fGetInfRET( @aAcids )
    Else
        Processa( { || fGetInfRET( @aAcids ) }, STR0012 + IIf( lMiddleware, STR0013, STR0014 ) + "..." ) //"Aguarde, buscando as informa��es do " ## "Middleware" ## "SIGATAF"
    EndIf

    //--------------------------------------------------------------------------------------------
    // Atualiza as informa��es da CAT na tabela TNC de acordo com o retorno do SIGATAF/Middleware
    //--------------------------------------------------------------------------------------------
    If lJob
        fUpdCpsTNC( aAcids, @cMsg )
    Else
        Processa( { || fUpdCpsTNC( aAcids, @cMsg ) }, STR0015 ) //"Aguarde, atualizando informa��es na tabela TNC..."
    EndIf

    //Retorna a �rea
    RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetCATs
Busca os acidentes ativos cadastrados na tabela TNC

@sample fGetCATs()

@return aAcids, Array, Array contendo os acidentes a serem atualizados

@author Luis Fellipy Bett
@since  07/03/2022
/*/
//-------------------------------------------------------------------
Static Function fGetCATs()

	//Salva a �rea
    Local aArea := GetArea()

    //Vari�veis de tabelas tempor�rias
    Local cAliasTNC := GetNextAlias()

    //Vari�veis de busca das informa��es
    Local aAcids := {}

    BeginSQL Alias cAliasTNC

        SELECT
            TNC.TNC_ACIDEN, TNC.TNC_DTACID, TNC.TNC_HRACID, TNC.TNC_TIPCAT, TM0.TM0_MAT
        FROM
            %Table:TNC% TNC
        INNER JOIN %Table:TM0% TM0 ON
            TM0.TM0_FILIAL = %xFilial:TM0% AND
            TM0.TM0_NUMFIC = TNC.TNC_NUMFIC AND
            TM0.TM0_MAT != '' AND
            TM0.%NotDel%
        WHERE
            TNC.TNC_FILIAL = %xFilial:TNC% AND
            TNC.%NotDel%

    EndSQL

    //Posiciona na tabela
    dbSelectArea( cAliasTNC )
    ( cAliasTNC )->( dbGoTop() )

    //Caso for execu��o manual, seta a r�gua de processamento
    If !lJob
        ProcRegua( RecCount() )
    EndIf

    //Percorre os acidentes adicionando no array
    While ( cAliasTNC )->( !Eof() )

        //Caso for execu��o manual, incrementa a r�gua de processamento
        If !lJob
            IncProc()
        EndIf

        //Adiciona as informa��es do acidente no array
        aAdd( aAcids, { { ( cAliasTNC )->TNC_ACIDEN }, { ( cAliasTNC )->TM0_MAT }, { ( cAliasTNC )->TNC_DTACID, StrTran( ( cAliasTNC )->TNC_HRACID, ":", "" ), ( cAliasTNC )->TNC_TIPCAT }, {} } )

        //Pula para o pr�ximo registro
        ( cAliasTNC )->( dbSkip() )

    End

    //Fecha a tabela tempor�ria
    ( cAliasTNC )->( dbCloseArea() )

    //Retorna a �rea
    RestArea( aArea )

Return aAcids

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetInfRET
Busca as informa��es de recibo, recibo da CAT origem (se houver) e data
do recebimento da CAT do SIGATAF/Middleware

@sample fGetInfRET( { { "000231" } } )

@param  aAcids, Array, Array contendo os acidentes a terem as informa��es atualizadas

@return Nil, Nulo

@author Luis Fellipy Bett
@since  07/03/2022
/*/
//-------------------------------------------------------------------
Static Function fGetInfRET( aAcids )

	//Salva a �rea
    Local aArea := GetArea()
    
    //Vari�veis de busca das informa��es
    Local cIDFunc  := ""
    Local cRecibo  := ""
    Local cDtRecb  := ""
    Local cTipoCAT := ""
    Local dDtAcid  := SToD( "" )
    Local cHrAcid  := ""
    Local nCont    := 0
    Local aArrTAF  := {}
    Local aEvento  := {}
    Local nEvento  := 0

    //Vari�veis private utilizadas dentro da fun��o MDTCATOrig
    Private cNumMat := ""
    Private cNrRecCatOrig := ""

    //Caso o envio for via Middleware
    If lMiddleware

        //Seta a r�gua de processamento
        If !lJob
            ProcRegua( Len( aAcids ) )
        EndIf

        //Percorre os acidentes buscando as informa��es
        For nCont := 1 To Len( aAcids )

            //Incrementa a r�gua de processamento
            If !lJob
                IncProc()
            EndIf

            //Adiciona a matr�cula do funcion�rio na vari�vel
            cNumMat := aAcids[ nCont, 2, 1 ]

            //Busca os Xml's do evento S-2210 para o funcion�rio
            aEvento := MDTLstXml( "S2210", aAcids[ nCont, 2, 1 ] )

            //Verifica entre os Xml's encontrados qual se refere a CAT
            For nEvento := 1 To Len( aEvento )

                //Adiciona as informa��es do acidente nas vari�veis
                dDtAcid  := MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:dtAcid", "D" )
                cHrAcid  := MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:hrAcid", "C" )
                cTipoCAT := MDTXmlVal( "S2210", aEvento[ nEvento, 1 ], "/ns:eSocial/ns:evtCAT/ns:cat/ns:tpCat", "C" )

                //Caso o xml conter as informa��es iguais ao do acidente
                If ( dDtAcid == SToD( aAcids[ nCont, 3, 1 ] ) ) .And. ;
                ( cHrAcid == aAcids[ nCont, 3, 2 ] ) .And. ;
                ( cTipoCAT == aAcids[ nCont, 3, 3 ] )

                    //Salva as informa��es da CAT
                    cRecibo := AllTrim( aEvento[ nEvento, 2 ] )
                    cDtRecb := aEvento[ nEvento, 2 ]
                    MDTCATOrig( cTipoCAT, dDtAcid, cHrAcid ) //Fun��o para buscar o recibo da CAT origem

                    //Sai do la�o pois encontrou as informa��es da CAT
                    Exit

                EndIf

            Next nEvento

            //Caso tenha sido encontrada alguma das informa��es
            If !Empty( cRecibo ) .Or. !Empty( cNrRecCatOrig ) .Or. !Empty( cDtRecb )

                //Adiciona as informa��es do SIGATAF/Middleware no array
                aAdd( aAcids[ nCont, 4 ], { cRecibo, cNrRecCatOrig, cDtRecb } )

            EndIf

            //Zera as vari�veis para buscar as informa��es da pr�xima CAT do la�o
            cNrRecCatOrig := ""
            cRecibo := ""
            cDtRecb := ""

        Next nCont

    Else //Caso o envio for via SIGATAF

        //Caso a fun��o de busca do TAF exista no RPO
        If FindFunction( "ConsultaCAT" )

            //Percorre os acidentes a serem atualizados para montar o array a ser passado na fun��o ConsultaCAT do SIGATAF
            For nCont := 1 To Len( aAcids )

                //Guarda a matr�cula do funcion�rio na vari�vel private
                cNumMat := aAcids[ nCont, 2, 1 ]

                //Busca o TAFKEY da CAT, se houver
                cTAFKey := MDTGetTKEY( aAcids[ nCont, 3, 1 ] + aAcids[ nCont, 3, 2 ] + aAcids[ nCont, 3, 3 ] )

                //Busca o ID do funcion�rio no TAF
                cIDFunc := MDTGetIdFun( cNumMat )

                aAdd( aArrTAF, { xFilial( "CM0" ), cTAFKey, cIDFunc, aAcids[ nCont, 3, 1 ], aAcids[ nCont, 3, 2 ], aAcids[ nCont, 3, 3 ] } )

            Next nCont

            //Busca as informa��es da CAT do SIGATAF
            aInfTAF := ConsultaCAT( aArrTAF )

            //Adiciona as informa��es ao array de retorno
            For nCont := 1 To Len( aAcids )

                //Pega as informa��es do array retornado do SIGATAF
                cRecibo := aInfTAF[ nCont, 7 ]
                cNrRecCatOrig := aInfTAF[ nCont, 8 ]
                cDtRecb := aInfTAF[ nCont, 9 ]

                //Caso tenha sido encontrada alguma das informa��es
                If !Empty( cRecibo ) .Or. !Empty( cNrRecCatOrig ) .Or. !Empty( cDtRecb )

                    //Adiciona as informa��es do SIGATAF/Middleware no array
                    aAdd( aAcids[ nCont, 4 ], { cRecibo, cNrRecCatOrig, cDtRecb } )

                EndIf

                //Zera as vari�veis para buscar as informa��es da pr�xima CAT do la�o
                cNrRecCatOrig := ""
                cRecibo := ""
                cDtRecb := ""

            Next nCont
        
        Else

            //Seta a r�gua de processamento
            If !lJob
                ProcRegua( Len( aAcids ) )
            EndIf

            //Percorre os acidentes buscando as informa��es
            For nCont := 1 To Len( aAcids )

                //Incrementa a r�gua de processamento
                If !lJob
                    IncProc()
                EndIf

                //Adiciona a matr�cula do funcion�rio na vari�vel
                cNumMat := aAcids[ nCont, 2, 1 ]

                //Busca o ID do funcion�rio no TAF
                cIDFunc := MDTGetIdFun( aAcids[ nCont, 2, 1 ] )

                //Busca o registro do acidente no TAF
                dbSelectArea( "CM0" )
                dbSetOrder( 4 )
                If dbSeek( xFilial( "CM0" ) + cIDFunc + aAcids[ nCont, 3, 1 ] + aAcids[ nCont, 3, 2 ] + aAcids[ nCont, 3, 3 ] )

                    //Busca o acidente mais atual para pegar as informa��es
                    While CM0->( !Eof() ) .And. ;
                        CM0->CM0_FILIAL == xFilial( "CM0" ) .And. ;
                        CM0->CM0_TRABAL == cIdFunc .And. ;
                        DToS( CM0->CM0_DTACID ) == aAcids[ nCont, 3, 1 ] .And. ;
                        StrTran( CM0->CM0_HRACID, ":", "" ) == aAcids[ nCont, 3, 2 ] .And. ;
                        CM0->CM0_TPCAT == aAcids[ nCont, 3, 3 ]

                        //Adiciona as informa��es do acidente nas vari�veis
                        dDtAcid  := CM0->CM0_DTACID
                        cHrAcid  := StrTran( CM0->CM0_HRACID, ":", "" )
                        cTipoCAT := CM0->CM0_TPCAT

                        //Salva as informa��es da CAT
                        cRecibo := AllTrim( CM0->CM0_PROTUL )
                        cDtRecb := DToS( CM0->CM0_DTRECP )
                        MDTCATOrig( cTipoCAT, dDtAcid, cHrAcid ) //Fun��o para buscar o recibo da CAT origem
                        
                        //Pula o registro
                        CM0->( dbSkip() )

                    End

                EndIf

                //Caso tenha sido encontrada alguma das informa��es
                If !Empty( cRecibo ) .Or. !Empty( cNrRecCatOrig ) .Or. !Empty( cDtRecb )

                    //Adiciona as informa��es do SIGATAF/Middleware no array
                    aAdd( aAcids[ nCont, 4 ], { cRecibo, cNrRecCatOrig, cDtRecb } )

                EndIf

                //Zera as vari�veis para buscar as informa��es da pr�xima CAT do la�o
                cNrRecCatOrig := ""
                cRecibo := ""
                cDtRecb := ""

            Next nCont

        EndIf

    EndIf

    //Retorna a �rea
    RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fUpdCpsTNC
Atualiza as os campos da tabela TNC com o retorno das informa��es do
recibo, recibo da CAT origem (se houver) e data do recebimento da CAT
do SIGATAF/Middleware

@sample fUpdCpsTNC( { { "000217" } }, "" )

@param  aAcids, Array, Array contendo as informa��es do acidente
@param  cMsg, Caracter, Vari�vel que retorna por refer�ncia as CAT's
que foram atualizadas na tabela TNC

@return Nil, Nulo

@author Luis Fellipy Bett
@since  07/03/2022
/*/
//-------------------------------------------------------------------
Static Function fUpdCpsTNC( aAcids, cMsg )

    //Salva a �rea
    Local aArea := GetArea()

    //Vari�veis de busca das informa��es
    Local nCont := 0

    //Seta a r�gua de processamento
    If !lJob
        ProcRegua( Len( aAcids ) )
    EndIf

    //Percorre os acidentes para atualizar as informa��es na TNC
    For nCont := 1 To Len( aAcids )

        //Incrementa a r�gua de processamento
        If !lJob
            IncProc()
        EndIf

        dbSelectArea( "TNC" )
        dbSetOrder( 1 )
        If dbSeek( xFilial( "TNC" ) + aAcids[ nCont, 1, 1 ] ) .And. Len( aAcids[ nCont, 4 ] ) > 0

            RecLock( "TNC", .F. )

                TNC->TNC_RECIBO := aAcids[ nCont, 4, 1, 1 ]
                TNC->TNC_RECORI := aAcids[ nCont, 4, 1, 2 ]
                TNC->TNC_DTRECB := SToD( aAcids[ nCont, 4, 1, 3 ] )
 
            TNC->( MsUnlock() )

            //Adiciona na vari�vel para informar ao usu�rio
            cMsg += STR0016 + ": " + AllTrim( aAcids[ nCont, 1, 1 ] ) + CRLF //"Acidente"
            cMsg += "- " + STR0017 + ": " + AllTrim( aAcids[ nCont, 4, 1, 1 ] ) + CRLF //"Recibo"
            cMsg += "- " + STR0018 + ": " + AllTrim( aAcids[ nCont, 4, 1, 2 ] ) + CRLF //"Recibo CAT Origem"
            cMsg += "- " + STR0019 + ": " + DToC( SToD( aAcids[ nCont, 4, 1, 3 ] ) ) + CRLF + CRLF //"Data do Recebimento"

        EndIf

    Next nCont

    //Retorna a �rea
    RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execu��o de Par�metros na Defini��o do Schedule

@return aParam, Array, Conteudo com as defini��es de par�metros para WF

@sample SchedDef()

@author Luis Fellipy bett
@since  07/03/2022
/*/
//---------------------------------------------------------------------
Static Function SchedDef()
Return { "P", "PARAMDEF", "", {}, "Param" }
