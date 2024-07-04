#Include "TOTVS.ch"
#Include "OFIXDEF.ch"
#Include "OFIA204.ch"

/*/
{Protheus.doc} OFIA204
Rotina que realiza a geração e envio do DEF (DFS D-In) Gerencial Referencial da AGCO no formato JSON para consumo da API.
@type   Function
@author Otávio Favarelli
@since  16/11/2019
@param  nil
@return nil
/*/
Function OFIA204()

    Local oTProcess
    Local bProcess := { |oSelf| OA2040017_GeraDFSGerencialJSON(oSelf) }
    Local lPainelAux := .f.
    Local lViewExecute := .f.
    Local lOneMeter := .f.
    Local cPerg := "OFIA204" // Pergunte

	//
	// Validacao de Licencas DMS
	//
	If !OFValLicenca():ValidaLicencaDMS()
		Return
	EndIf

    oTProcess := tNewProcess():New(;
                                    STR0001,;				// 01 - Nome da função que está chamando o objeto.	// OFIA204
                                    STR0002,;				// 02 - Título da árvore de opções.	// Geração e Envio DEF Gerencial Referencial AGCO
                                    bProcess,;				// 03 - Bloco de execução que será executado ao confirmar a tela.
                                    STR0003,;				// 04 - Descrição da rotina.	// Esta rotina realiza a geração e a transmissão do DEF Gerencial Referencial da AGCO.
                                    cPerg,;					// 05 - Nome do Pergunte (SX1) a ser utilizado na rotina.
                                    /* aInfoCustom */ ,;	// 06 - Informações adicionais carregada na árvore de opções.
                                    lPainelAux,;			// 07 - Se .T. cria uma novo painel auxiliar ao executar a rotina.
                                    /* nSizePanelAux */ ,;	// 08 - Tamanho do painel auxiliar, utilizado quando lPainelAux = .T.
                                    /* cDescriAux */ ,;		// 09 - Descrição a ser exibida no painel auxiliar.
                                    lViewExecute,;			// 10 - Se .T. exibe o painel de execução. Se .f., apenas executa a função sem exibir a régua de processamento.
                                    lOneMeter;				// 11 - Se .T. cria apenas uma regua de processamento.
                                    )

Return

/*/
{Protheus.doc} OA2040017_GeraDFSGerencialJSON
Rotina que realiza a geração do DEF AGCO (DFS) Gerencial Referencial no formato JSON.
@type   Static Function
@author Otávio Favarelli
@since  16/11/2019
@param  oTProcess,  Objeto, Objeto tNewProcess para controle e interação do processamento.
@return nil
/*/
Static Function OA2040017_GeraDFSGerencialJSON(oTProcess)

    Local cAliasA   := GetNextAlias()
    Local cAliasB   := GetNextAlias()
    Local cAliasC   := GetNextAlias()
    Local cAliasD   := GetNextAlias()
    Local cAliasE   := GetNextAlias()
    Local cAliasF   := GetNextAlias()
    Local cAliasG   := GetNextAlias()
    Local cAliasH   := GetNextAlias()
    Local cAliasI   := GetNextAlias()
    Local cAliasJ   := GetNextAlias()
    Local cAliasK   := GetNextAlias()
    Local cAliasL   := GetNextAlias()
    Local cAliasM   := GetNextAlias()
    Local cAliasN   := GetNextAlias()
    Local cAliasO   := GetNextAlias()
    Local cAliasP   := GetNextAlias()
    Local cAliasQ   := GetNextAlias()
    Local cAliasR   := GetNextAlias()
    Local cAliasS   := GetNextAlias()
    Local cQuery    := ""
    Local cAuxData  := Dtoc(dDataBase)
    Local cJsonFinal
    Local cMV_PAR01 // Filial Matriz?
    Local dMV_PAR02 // Data?
    Local cMV_PAR03 // Gera para qual filial?
    Local cMV_PAR04 // Diretório gravação Arq JSON?
    Local cEndPoint
    Local cTimeIni
    Local cArqCNPJ  
    Local cArqMesAno
    Local cArqTStamp
    Local cModelVFG
    //
    Local nPos
    Local nCntA
    Local nCntB
    Local nCntC
    Local nCntD
    Local nCntE
    Local nCntF
    Local nCntG
    Local nCntH
    Local nQuantTec
    Local nQuantMaq
    Local nHrsDisp
    Local nHrsFat
    Local nDiasAbOS
    Local nValPec
    Local nValSer
    Local nTotGerOS
    Local nMedTotOS
    Local nDiasAbAt
    Local nValAtend
    Local nTotGerAt
    Local nMedTotAt
    //
    Local jChavePrimaria    := {}
    //
    Local aDFS              := {}
    Local aValPecOS
    Local aValSerOS
    Local aOSAber
    Local aAtenAber
    //
    Local lGrvJSON
    Local lVAIComp
    //
    Local dDataIni
    
    cEndPoint := GetMV("MV_MIL0142")
    If Empty(cEndPoint)
        Help(NIL, NIL, STR0004, NIL, STR0005, /* Parâmetro Em Branco | O Parâmetro MV_MIL0142 está em branco. Impossível continuar. */;
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006})	// Preencha o parâmetro MV_MIL0142 para utilizar esta rotina.
        Return
    EndIf

    // Vamos salvar as perguntes pois abaixo iremos utilizar a pergunte do OFIA202 (F12 no browse da rotina)
    cMV_PAR01 := MV_PAR01
    dMV_PAR02 := MV_PAR02
    cMV_PAR03 := MV_PAR03
    cMV_PAR04 := MV_PAR04

    Pergunte("OFIA202",.f.) // 
    If Empty(MV_PAR01)
        Help(NIL, NIL, STR0004, NIL, STR0007, /* Parâmetro Em Branco | O Parâmetro Status Outros Negócios da rotina de cadastro de DFS Gerencial de Máquinas (OFIA202) está em branco. Impossível continuar. */;
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0008})	// Preencha o parâmetro Status Outros Negócios para prosseguir com a utilização desta rotina.
        Return
    EndIf

    ConOut(Chr(13) + Chr(10))
    ConOut("---------------------------------------------------------------")
    ConOut(" #######  ######## ####    ###     #######    #####   ##       ")
    ConOut("##     ## ##        ##    ## ##   ##     ##  ##   ##  ##    ## ")
    ConOut("##     ## ##        ##   ##   ##         ## ##     ## ##    ## ")
    ConOut("##     ## ######    ##  ##     ##  #######  ##     ## ##    ## ")
    ConOut("##     ## ##        ##  ######### ##        ##     ## #########")
    ConOut("##     ## ##        ##  ##     ## ##         ##   ##        ## ")
    ConOut(" #######  ##       #### ##     ## #########   #####         ## ")
    ConOut("---------------------------------------------------------------")
    ConOut(Chr(13) + Chr(10))
    ConOut( STR0009 + cAuxData + " - " + Time() )	// INICIO DA GERACAO DO AGCO DFS GERENCIAL REFERENCIAL JSON - OFIA204:
    cTimeIni := Time()
    
    //
    // Primeiro Processamento
    // Processamento de Registros de Colaboradores (VVF_TIPREG = 1)
    //
    
    // Verificacao das filiais informadas para os colaboradores e laço tratando cada filial encontrada
    cQuery := " SELECT "
	cQuery +=   " COUNT(DISTINCT VFG.VFG_FILTEC) " // Filial do Tecnico
	cQuery += " FROM "
	cQuery +=   RetSQLName("VFG") + " VFG "
	cQuery += " WHERE "
	cQuery +=   " VFG.D_E_L_E_T_ = ' ' "
    cQuery +=   " AND VFG.VFG_FILIAL =  '" + xFilial("VFG") + "' "
    If !Empty(cMV_PAR03) // Gera para qual filial?
        cQuery +=   " AND ( VFG.VFG_FILTEC = '" + Alltrim(cMV_PAR03) + "' OR VFG.VFG_FILTEC = ' ' ) "
    EndIf 
    oTProcess:SetRegua1(FM_SQL(cQuery))
    
    cQuery := " SELECT "
	cQuery +=   " DISTINCT VFG.VFG_FILTEC " // Filial do Tecnico
	cQuery += " FROM "
	cQuery +=   RetSQLName("VFG") + " VFG "
	cQuery += " WHERE "
	cQuery +=   " VFG.D_E_L_E_T_ = ' ' "
    cQuery +=   " AND VFG.VFG_FILIAL =  '" + xFilial("VFG") + "' "
    If !Empty(cMV_PAR03) // Gera para qual filial?
        cQuery +=   " AND ( VFG.VFG_FILTEC = '" + Alltrim(cMV_PAR03) + "' OR VFG.VFG_FILTEC = ' ' ) "
    EndIf 
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasA, .f., .t.)

    While !(cAliasA)->(EoF())
        // Não podemos utilizar filial em branco
        // Mas precisamos listar os registros VFG_FILTEC em branco para considerar os registros preenchidos no VFG_CC
        If !Empty( (cAliasA)->VFG_FILTEC ) 
            oTProcess:IncRegua1(STR0010 + (cAliasA)->VFG_FILTEC )	// Gerando JSON de Colaboradores para a Filial

            // Separacao das classificacoes de colaboradores cadastrados (VFF_CODCAB + VFF_CODGRF + VFF_CODDRF)
            cQuery := "SELECT DISTINCT"
            cQuery +=   " COUNT(VFF.VFF_CODCAB) "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VFF") + " VFF "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VFG") + " VFG "
            cQuery += "ON "
            cQuery +=   " VFF.VFF_CODCAB = VFG.VFG_CODCAB "
            cQuery += "WHERE "
            cQuery +=   " VFF.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VFG.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VFF.VFF_FILIAL =  '" + xFilial("VFF") + "' "
            cQuery +=   " AND VFF.VFF_TIPREG = '1' "    // 1=Colaborador
            cQuery +=   " AND ( VFG.VFG_FILTEC = '" + (cAliasA)->VFG_FILTEC + "' OR VFG.VFG_FILTEC = ' ' ) "
            oTProcess:SetRegua2(FM_SQL(cQuery))

            cQuery := "SELECT DISTINCT"
            cQuery +=   " VFF.VFF_CODCAB "
            cQuery +=   " ,VFF.VFF_DESCAB "
            cQuery +=   " ,VFF.VFF_CODGRF "
            cQuery +=   " ,VFF.VFF_CODDRF "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VFF") + " VFF "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VFG") + " VFG "
            cQuery += "ON "
            cQuery +=   " VFF.VFF_CODCAB = VFG.VFG_CODCAB "
            cQuery += "WHERE "
            cQuery +=   " VFF.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VFG.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VFF.VFF_FILIAL =  '" + xFilial("VFF") + "' "
            cQuery +=   " AND VFF.VFF_TIPREG = '1' "    // 1=Colaborador
            cQuery +=   " AND ( VFG.VFG_FILTEC = '" + (cAliasA)->VFG_FILTEC + "' OR VFG.VFG_FILTEC = ' ' ) "
            cQuery += "ORDER BY VFF.VFF_CODCAB, VFF.VFF_CODGRF, VFF.VFF_CODDRF"
            DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasB, .f., .t.)

            // Laco das classificacoes para geracao do JSON
            While !(cAliasB)->(EoF())
                oTProcess:IncRegua2(STR0011 + (cAliasB)->VFF_CODCAB + " - " + (cAliasB)->VFF_DESCAB )	// Gerando JSON para o registro

                nQuantTec := 0

                // Vamos levantar os técnicos lançados manualmente
                cQuery := "SELECT DISTINCT "
                cQuery +=   " COUNT(VFG.VFG_CODTEC) "
                cQuery += "FROM "
                cQuery +=   RetSQLName("VFG") + " VFG "
                cQuery += "WHERE "
                cQuery +=   " VFG.D_E_L_E_T_ =  ' ' "
                cQuery +=   " AND VFG.VFG_FILIAL =  '" + xFilial("VFG") + "' "
                cQuery +=   " AND VFG.VFG_FILTEC = '" + (cAliasA)->VFG_FILTEC + "' "
                cQuery +=   " AND VFG.VFG_CODCAB = '" + (cAliasB)->VFF_CODCAB + "' "
                cQuery +=   " AND VFG.VFG_CODTEC <> ' ' "
                nQuantTec := FM_SQL(cQuery)

                // Vamos levantar os técnicos agrupados pelo centro de custo
                cQuery := "SELECT DISTINCT"
                cQuery +=   " VFG.VFG_CC "
                cQuery += "FROM "
                cQuery +=   RetSQLName("VFG") + " VFG "
                cQuery += "WHERE "
                cQuery +=   " VFG.D_E_L_E_T_ =  ' ' "
                cQuery +=   " AND VFG.VFG_FILIAL =  '" + xFilial("VFG") + "' "
                cQuery +=   " AND VFG.VFG_CODCAB = '" + (cAliasB)->VFF_CODCAB + "' "
                cQuery +=   " AND VFG.VFG_CC <> ' ' "
                cQuery += "ORDER BY VFG.VFG_CC"
                DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasC, .f., .t.)

                While !(cAliasC)->(EoF())
                    cQuery := "SELECT "
                    cQuery +=   " COUNT(VAI.VAI_CODTEC) "
                    cQuery += "FROM "
                    cQuery +=   RetSQLName("VAI") + " VAI "
                    cQuery += "WHERE "
                    cQuery +=   " VAI.D_E_L_E_T_ =  ' ' "
                    cQuery +=   " AND VAI.VAI_FILPRO =  '" + (cAliasA)->VFG_FILTEC + "' "
                    cQuery +=   " AND VAI.VAI_CC = '" + (cAliasC)->VFG_CC + "' "
                    nQuantTec += FM_SQL(cQuery)
                    (cAliasC)->(dbSkip())
                End
                (cAliasC)->(DbCloseArea())

                Aadd(aDFS,JsonObject():new())
                jChavePrimaria := JsonObject():new()
                nPos := Len(aDFS)
                jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
                jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
                jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,(cAliasA)->VFG_FILTEC)[18], "@R 99.999.999/9999-99" )
                jChavePrimaria['codeDFSPlan'        ] := (cAliasB)->VFF_CODGRF
                jChavePrimaria['sectionCode'        ] := (cAliasB)->VFF_CODDRF
                aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
                aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
                aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantTec )

                (cAliasB)->(dbSkip())
            End
            (cAliasB)->(DbCloseArea())
        EndIf
        (cAliasA)->(dbSkip())
    End
        
    (cAliasA)->(DbCloseArea())

    //
    // Segundo Processamento
    // Processamento de Registros de Tipos de Máquinas (VV1_STATUS)
    //
    
    // Laço de vendas de maquinas para todas as filiais por tipo
    If Empty(cMV_PAR03) // Gera para qual filial?
        nQuantMaq := 0

        cQuery := " SELECT "
	    cQuery +=   " COUNT(DISTINCT VV0.VV0_FILIAL) " 
	    cQuery += " FROM "
	    cQuery +=   RetSQLName("VV0") + " VV0 "
	    cQuery += " WHERE "
	    cQuery +=   " VV0.D_E_L_E_T_ = ' ' "
        cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
        cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
        cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
        oTProcess:SetRegua1(FM_SQL(cQuery))

        cQuery := " SELECT "
	    cQuery +=   " DISTINCT VV0.VV0_FILIAL " 
	    cQuery += " FROM "
	    cQuery +=   RetSQLName("VV0") + " VV0 "
	    cQuery += " WHERE "
	    cQuery +=   " VV0.D_E_L_E_T_ = ' ' "
        cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
        cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
        cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasD, .f., .t.)

        While !(cAliasD)->(EoF())
            oTProcess:IncRegua1(STR0012 + (cAliasD)->VV0_FILIAL )	// Gerando JSON de Venda por Tipos de Máquinas para a Filial

            // Quantidades Vendidas de Máquinas Novas no período
            cQuery := "SELECT "
            cQuery +=   " COUNT(VVA.VVA_CHAINT) "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VVA") + " VVA "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VV0") + " VV0 "
            cQuery += "ON "
            cQuery +=   " VV0.VV0_FILIAL = VVA.VVA_FILIAL "
            cQuery +=   " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VV1") + " VV1 "
            cQuery += "ON "
            cQuery +=   " VVA.VVA_CHAINT = VV1.VV1_CHAINT "
            cQuery += "WHERE "
            cQuery +=   " VVA.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV0.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV1.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
            cQuery +=   " AND VV0.VV0_TIPFAT = '0' "    // 0=Normal Novo
            cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
            cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
            cQuery +=   " AND VV1.VV1_STATUS <> '" + MV_PAR01 + "' "    // Diferente de Outros Negócios
            cQuery +=   " AND VV0.VV0_FILIAL = '" + (cAliasD)->VV0_FILIAL + "' "
            nQuantMaq := FM_SQL(cQuery)

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,(cAliasD)->VV0_FILIAL)[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9211" // Novos
            jChavePrimaria['sectionCode'        ] := "1101" // Máquinas Novas
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantMaq )

            // Quantidades Vendidas de Máquinas Usadas no período
            cQuery := "SELECT "
            cQuery +=   " COUNT(VVA.VVA_CHAINT) "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VVA") + " VVA "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VV0") + " VV0 "
            cQuery += "ON "
            cQuery +=   " VV0.VV0_FILIAL = VVA.VVA_FILIAL "
            cQuery +=   " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VV1") + " VV1 "
            cQuery += "ON "
            cQuery +=   " VVA.VVA_CHAINT = VV1.VV1_CHAINT "
            cQuery += "WHERE "
            cQuery +=   " VVA.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV0.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV1.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
            cQuery +=   " AND VV0.VV0_TIPFAT = '1' "    // 0=Normal Usado
            cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
            cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
            cQuery +=   " AND VV1.VV1_STATUS <> '" + MV_PAR01 + "' "    // Diferente de Outros Negócios
            cQuery +=   " AND VV0.VV0_FILIAL = '" + (cAliasD)->VV0_FILIAL + "' "
            nQuantMaq := FM_SQL(cQuery)

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,(cAliasD)->VV0_FILIAL)[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9212" // Usados
            jChavePrimaria['sectionCode'        ] := "1102" // Máquinas Usadas
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantMaq )

            // Quantidades Vendidas de Outros Negócios no período
            cQuery := "SELECT "
            cQuery +=   " COUNT(VVA.VVA_CHAINT) "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VVA") + " VVA "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VV0") + " VV0 "
            cQuery += "ON "
            cQuery +=   " VV0.VV0_FILIAL = VVA.VVA_FILIAL "
            cQuery +=   " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VV1") + " VV1 "
            cQuery += "ON "
            cQuery +=   " VVA.VVA_CHAINT = VV1.VV1_CHAINT "
            cQuery += "WHERE "
            cQuery +=   " VVA.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV0.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV1.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
            cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
            cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
            cQuery +=   " AND VV1.VV1_STATUS = '" + MV_PAR01 + "' "    // Outros Negócios
            cQuery +=   " AND VV0.VV0_FILIAL = '" + (cAliasD)->VV0_FILIAL + "' "
            nQuantMaq := FM_SQL(cQuery)

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,(cAliasD)->VV0_FILIAL)[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9213" // Outros Negócios
            jChavePrimaria['sectionCode'        ] := "1501" // Outros Negócios
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantMaq )

            (cAliasD)->(dbSkip())

        End

    Else
        oTProcess:IncRegua1(STR0012 + cMV_PAR03 )	// Gerando JSON de Venda por Tipos de Máquinas para a Filial
        
        nQuantMaq := 0

        // Quantidades Vendidas de Máquinas Novas no período
        cQuery := "SELECT "
        cQuery +=   " COUNT(VVA.VVA_CHAINT) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VVA") + " VVA "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV0") + " VV0 "
        cQuery += "ON "
        cQuery +=   " VV0.VV0_FILIAL = VVA.VVA_FILIAL "
        cQuery +=   " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV1") + " VV1 "
        cQuery += "ON "
        cQuery +=   " VVA.VVA_CHAINT = VV1.VV1_CHAINT "
        cQuery += "WHERE "
        cQuery +=   " VVA.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV0.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV1.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
        cQuery +=   " AND VV0.VV0_TIPFAT = '0' "    // 0=Normal Novo
        cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
        cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
        cQuery +=   " AND VV1.VV1_STATUS <> '" + MV_PAR01 + "' "    // Diferente de Outros Negócios
        cQuery +=   " AND VV0.VV0_FILIAL = '" + cMV_PAR03 + "' "    // Gera para qual filial?
        nQuantMaq := FM_SQL(cQuery)

        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,cMV_PAR03)[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9211" // Novos
        jChavePrimaria['sectionCode'        ] := "1101" // Máquinas Novas
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantMaq )

        // Quantidades Vendidas de Máquinas Usadas no período
        cQuery := "SELECT "
        cQuery +=   " COUNT(VVA.VVA_CHAINT) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VVA") + " VVA "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV0") + " VV0 "
        cQuery += "ON "
        cQuery +=   " VV0.VV0_FILIAL = VVA.VVA_FILIAL "
        cQuery +=   " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV1") + " VV1 "
        cQuery += "ON "
        cQuery +=   " VVA.VVA_CHAINT = VV1.VV1_CHAINT "
        cQuery += "WHERE "
        cQuery +=   " VVA.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV0.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV1.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
        cQuery +=   " AND VV0.VV0_TIPFAT = '1' "    // 0=Normal Usado
        cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
        cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
        cQuery +=   " AND VV1.VV1_STATUS <> '" + MV_PAR01 + "' "    // Diferente de Outros Negócios
        cQuery +=   " AND VV0.VV0_FILIAL = '" + cMV_PAR03 + "' "    // Gera para qual filial?
        nQuantMaq := FM_SQL(cQuery)

        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,cMV_PAR03)[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9212" // Usados
        jChavePrimaria['sectionCode'        ] := "1102" // Máquinas Usadas
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantMaq )

        // Quantidades Vendidas de Outros Negócios no período
        cQuery := "SELECT "
        cQuery +=   " COUNT(VVA.VVA_CHAINT) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VVA") + " VVA "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV0") + " VV0 "
        cQuery += "ON "
        cQuery +=   " VV0.VV0_FILIAL = VVA.VVA_FILIAL "
        cQuery +=   " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV1") + " VV1 "
        cQuery += "ON "
        cQuery +=   " VVA.VVA_CHAINT = VV1.VV1_CHAINT "
        cQuery += "WHERE "
        cQuery +=   " VVA.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV0.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV1.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
        cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
        cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
        cQuery +=   " AND VV1.VV1_STATUS = '" + MV_PAR01 + "' "    // Outros Negócios
        cQuery +=   " AND VV0.VV0_FILIAL = '" + cMV_PAR03 + "' "    // Gera para qual filial?
        nQuantMaq := FM_SQL(cQuery)

        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,cMV_PAR03)[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9213" // Outros Negócios
        jChavePrimaria['sectionCode'        ] := "1501" // Outros Negócios
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantMaq )
    EndIf

    //
    // Terceiro Processamento
    // Processamento de Registros de Especificacao e Potencia/Classe (VFF_TIPREG = 2)
    // Considera-se Especificacao e Potencia/Classe atraves do campo VFF_CODGRF
    //

    // Inicio do processo de listagem de vendas de maquinas para todas as filiais por especificacao e potencia/classe
        
    // Separacao das classificacoes de maquinas cadastradas (VFF_TIPREG = 2) 
    cQuery := "SELECT DISTINCT"
    cQuery +=   " COUNT(VFF.VFF_CODCAB) "
    cQuery += "FROM "
    cQuery +=   RetSQLName("VFF") + " VFF "
    cQuery += "WHERE "
    cQuery +=   " VFF.D_E_L_E_T_ =  ' ' "
    cQuery +=   " AND VFF.VFF_FILIAL =  '" + xFilial("VFF") + "' "
    cQuery +=   " AND VFF.VFF_TIPREG = '2' "    // 2=Maquina
    oTProcess:SetRegua1(FM_SQL(cQuery))

    cQuery := "SELECT DISTINCT"
    cQuery +=   " VFF.VFF_CODCAB "
    cQuery +=   " ,VFF.VFF_DESCAB "
    cQuery +=   " ,VFF.VFF_CODGRF "
    cQuery += "FROM "
    cQuery +=   RetSQLName("VFF") + " VFF "
    cQuery += "WHERE "
    cQuery +=   " VFF.D_E_L_E_T_ =  ' ' "
    cQuery +=   " AND VFF.VFF_FILIAL =  '" + xFilial("VFF") + "' "
    cQuery +=   " AND VFF.VFF_TIPREG = '2' "    // 2=Maquina
    cQuery += "ORDER BY VFF.VFF_CODCAB "
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasE, .f., .t.)
    
    // Laco das classificacoes para geracao do JSON
    While !(cAliasE)->(EoF())
        oTProcess:IncRegua1(STR0013 + (cAliasE)->VFF_CODCAB + " - " + (cAliasE)->VFF_DESCAB )	// Gerando JSON de Venda por Especificação de Máquinas para o registro
        
        // Listar todos os VFG do VFF posicionado
        cQuery := "SELECT "
        cQuery +=   " VFG.VFG_FILIAL "
        cQuery +=   " , VFG.VFG_CODSEQ "
        cQuery +=   " , VFG.VFG_CODMAR "
        cQuery +=   " , VFG.VFG_GRUMOD "
        cQuery +=   " , VFG.VFG_MODVEI "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VFG") + " VFG "
        cQuery += "WHERE "
        cQuery +=   " VFG.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VFG.VFG_CODCAB =  '" + (cAliasE)->VFF_CODCAB + "' "
        cQuery +=   " AND VFG.VFG_TIPREG = '2' "    // 2=Maquina
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasF, .f., .t.)

        If Empty(cMV_PAR03) // Gera para qual filial?
            (cAliasD)->(DbGoTop())
            While !(cAliasD)->(EoF())
                nQuantMaq := 0
                (cAliasF)->(DbGoTop())
                While !(cAliasF)->(EoF())
                    cModelVFG := OA2040027_NivelCadastroMaquinaVFG(,(cAliasF)->VFG_CODSEQ,(cAliasF)->VFG_CODMAR,(cAliasF)->VFG_GRUMOD,(cAliasF)->VFG_MODVEI)
                    // Quantidade de Máquinas Vendidas no Período
                    cQuery := "SELECT "
                    cQuery +=   " COUNT(VVA.VVA_CHAINT) "
                    cQuery += "FROM "
                    cQuery +=   RetSQLName("VVA") + " VVA "
                    cQuery += "INNER JOIN "
                    cQuery +=   RetSQLName("VV0") + " VV0 "
                    cQuery += "ON "
                    cQuery +=   " VV0.VV0_FILIAL = VVA.VVA_FILIAL "
                    cQuery +=   " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
                    cQuery += "INNER JOIN "
                    cQuery +=   RetSQLName("VV1") + " VV1 "
                    cQuery += "ON "
                    cQuery +=   " VVA.VVA_CHAINT = VV1.VV1_CHAINT "
                    cQuery += "WHERE "
                    cQuery +=   " VVA.D_E_L_E_T_ =  ' ' "
                    cQuery +=   " AND VV0.D_E_L_E_T_ =  ' ' "
                    cQuery +=   " AND VV1.D_E_L_E_T_ =  ' ' "
                    cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
                    cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
                    cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
                    cQuery +=   " AND VV0.VV0_FILIAL = '" + (cAliasD)->VV0_FILIAL + "' "
                    cQuery +=   " AND VV1.VV1_MODVEI IN (" + cModelVFG + ") "
                    nQuantMaq += FM_SQL(cQuery)
                    (cAliasF)->(dbSkip())
                End
                Aadd(aDFS,JsonObject():new())
                jChavePrimaria := JsonObject():new()
                nPos := Len(aDFS)
                jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
                jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
                jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,(cAliasD)->VV0_FILIAL)[18], "@R 99.999.999/9999-99" )
                jChavePrimaria['codeDFSPlan'        ] := (cAliasE)->VFF_CODGRF // Novos
                jChavePrimaria['sectionCode'        ] := "1101" // Máquinas Novas
                aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
                aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
                aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantMaq )
    
                (cAliasD)->(dbSkip())
            End
            (cAliasD)->(DbCloseArea())            
        Else
            nQuantMaq := 0
            (cAliasF)->(DbGoTop())
            While !(cAliasF)->(EoF())
                cModelVFG := OA2040027_NivelCadastroMaquinaVFG(,(cAliasF)->VFG_CODSEQ,(cAliasF)->VFG_CODMAR,(cAliasF)->VFG_GRUMOD,(cAliasF)->VFG_MODVEI)
                // Quantidade de Máquinas Vendidas no Período
                cQuery := "SELECT "
                cQuery +=   " COUNT(VVA.VVA_CHAINT) "
                cQuery += "FROM "
                cQuery +=   RetSQLName("VVA") + " VVA "
                cQuery += "INNER JOIN "
                cQuery +=   RetSQLName("VV0") + " VV0 "
                cQuery += "ON "
                cQuery +=   " VV0.VV0_FILIAL = VVA.VVA_FILIAL "
                cQuery +=   " AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA "
                cQuery += "INNER JOIN "
                cQuery +=   RetSQLName("VV1") + " VV1 "
                cQuery += "ON "
                cQuery +=   " VVA.VVA_CHAINT = VV1.VV1_CHAINT "
                cQuery += "WHERE "
                cQuery +=   " VVA.D_E_L_E_T_ =  ' ' "
                cQuery +=   " AND VV0.D_E_L_E_T_ =  ' ' "
                cQuery +=   " AND VV1.D_E_L_E_T_ =  ' ' "
                cQuery +=   " AND VV0.VV0_OPEMOV = '0' "    // 0=Venda
                cQuery +=   " AND VV0.VV0_SITNFI = '1' "    // 1=Válida
                cQuery +=   " AND VV0.VV0_DATMOV BETWEEN '" + cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + "01' AND '" + DToS(dMV_PAR02) +"' "
                cQuery +=   " AND VV0.VV0_FILIAL = '" + cMV_PAR03 + "' "
                cQuery +=   " AND VV1.VV1_MODVEI IN (" + cModelVFG + ") "
                nQuantMaq += FM_SQL(cQuery)
                (cAliasF)->(dbSkip())
            End

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,cMV_PAR03)[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := (cAliasE)->VFF_CODGRF // Novos
            jChavePrimaria['sectionCode'        ] := "1101" // Máquinas Novas
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nQuantMaq )

        EndIf
        (cAliasF)->(DbCloseArea())
        (cAliasE)->(dbSkip())
    End    
    (cAliasE)->(DbCloseArea())

    //
    // Quarto Processamento e Quinto Processamento
    // Horas Disponiveis e Horas Faturadas
    //
    
    lVAIComp    := .f.
    nHrsDisp    := 0
    nHrsFat     := 0
    dDataIni    := SToD(cValToChar(Year(dMV_PAR02)) + StrZero( Month( dMV_PAR02 ), 2, 0) + '01')

	cQuery := " SELECT "
	cQuery +=   " COUNT(DISTINCT VAI.VAI_FILIAL) "
	cQuery += " FROM "
	cQuery +=   RetSQLName("VAI") + " VAI "
	cQuery += " WHERE "
	cQuery +=   " VAI.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND VAI.VAI_FUNPRO = '1' " // Produtivo 1=Sim
	cQuery +=   " AND ( VAI.VAI_DATDEM = ' ' OR '" + DToS(dMV_PAR02) + "' < VAI.VAI_DATDEM ) " // Data de demissão em branco ou admitido dentro do periodo
	If FM_SQL(cQuery) <= 1
		lVAIComp := .t.
	EndIf
    
    If Empty(cMV_PAR03) // Gera para qual filial?
        cQuery := " SELECT "
        If lVAIComp // VAI Compartilhada = Vamos trabalhar com VAI_FILPRO
            cQuery +=   " DISTINCT VAI.VAI_FILPRO "
        Else // VAI Exclusiva = Vamos trabalhar com VAI_FILIAL
            cQuery +=   " DISTINCT VAI.VAI_FILIAL "
        EndIf
	    cQuery += " FROM "
	    cQuery +=   RetSQLName("VAI") + " VAI "
	    cQuery += " WHERE "
	    cQuery +=   " VAI.D_E_L_E_T_ = ' ' "
        cQuery +=   " AND VAI.VAI_FUNPRO = '1' " // Produtivo 1=Sim
        cQuery +=   " AND ( VAI.VAI_DATDEM = ' ' OR '" + DToS(dMV_PAR02) + "' < VAI.VAI_DATDEM ) " // Data de demissão em branco ou admitido dentro do periodo
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasG, .f., .t.)
        
        While !(cAliasG)->(EoF()) // Laco para listar os tecnicos por filial para todas as filiais
            cQuery := "SELECT "
            cQuery +=   " VAI.VAI_CODTEC "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VAI") + " VAI "
            cQuery += "WHERE "
            cQuery +=   " VAI.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VAI.VAI_FUNPRO = '1' " // Produtivo 1=Sim
            cQuery +=   " AND ( VAI.VAI_DATDEM = ' ' OR '" + DToS(dMV_PAR02) + "' < VAI.VAI_DATDEM ) " // Data de demissão em branco ou admitido dentro do periodo
            If lVAIComp // VAI Compartilhada = Vamos trabalhar com VAI_FILPRO
                cQuery +=   " AND VAI.VAI_FILPRO = '" + (cAliasG)->VAI_FILPRO + "' "
            Else // VAI Exclusiva = Vamos trabalhar com VAI_FILIAL
                cQuery +=   " AND VAI.VAI_FILIAL = '" + (cAliasG)->VAI_FILIAL + "' "
            EndIf
            DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasH, .f., .t.)
            
            While !(cAliasH)->(EoF())
                nHrsDisp    += FG_CALTEM((cAliasH)->VAI_CODTEC,dDataIni,"0",dMV_PAR02) // 0 = Horas Disponiveis
                nHrsFat     += FG_CALTEM((cAliasH)->VAI_CODTEC,dDataIni,"5",dMV_PAR02) // 5 = Horas Vendidas
                (cAliasH)->(dbSkip())
            End

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,(cAliasG)->VAI_FILPRO)[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9511" // Horas Disponiveis
            jChavePrimaria['sectionCode'        ] := "1301" // Servicos
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nHrsDisp )

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,(cAliasG)->VAI_FILPRO)[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9512" // Horas Faturadas
            jChavePrimaria['sectionCode'        ] := "1301" // Servicos
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nHrsFat )
            
            nHrsDisp := 0
            nHrsFat := 0
            (cAliasH)->(DbCloseArea())
            (cAliasG)->(dbSkip())
        End
        (cAliasG)->(DbCloseArea())

    Else
        cQuery := "SELECT "
        cQuery +=   " VAI.VAI_CODTEC "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VAI") + " VAI "
        cQuery += "WHERE "
        cQuery +=   " VAI.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VAI.VAI_FUNPRO = '1' " // Produtivo 1=Sim
        cQuery +=   " AND ( VAI.VAI_DATDEM = ' ' OR '" + DToS(dMV_PAR02) + "' < VAI.VAI_DATDEM ) " // Data de demissão em branco ou admitido dentro do periodo
        If lVAIComp // VAI Compartilhada = Vamos trabalhar com VAI_FILPRO
            cQuery +=   " AND VAI.VAI_FILPRO = '" + cMV_PAR03 + "' "
        Else // VAI Exclusiva = Vamos trabalhar com VAI_FILIAL
            cQuery +=   " AND VAI.VAI_FILIAL = '" + cMV_PAR03 + "' "
        EndIf
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasI, .f., .t.)
        
        While !(cAliasI)->(EoF())
            nHrsDisp    += FG_CALTEM((cAliasI)->VAI_CODTEC,dDataIni,"0",dMV_PAR02) // 0 = Horas Disponiveis
            nHrsFat     += FG_CALTEM((cAliasI)->VAI_CODTEC,dDataIni,"5",dMV_PAR02) // 5 = Horas Vendidas
            (cAliasI)->(dbSkip())
        End
        
        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,cMV_PAR03)[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9511" // Horas Disponiveis
        jChavePrimaria['sectionCode'        ] := "1301" // Servicos
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nHrsDisp )

        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(,cMV_PAR03)[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9512" // Horas Faturadas
        jChavePrimaria['sectionCode'        ] := "1301" // Servicos
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nHrsFat )
        
        (cAliasI)->(DbCloseArea())

    EndIf

    //
    // Sexto Processamento e Setimo Processamento
    // Valor O.S. em Aberto e Media Ponderada do Tempo de O.S. em Aberto (Nao faturada ou cancelada)
    //

    nDiasAbOS   := 0
    nValPec     := 0
    nValSer     := 0
    nTotGerOS   := 0
    nMedTotOS   := 0
    aValPecOS   := {}
    aValSerOS   := {}
    aOSAber     := {}

    If Empty(cMV_PAR03) // Gera para qual filial?

        // Vamos listar todas as filiais
        cQuery := "SELECT "
        cQuery +=   " COUNT(DISTINCT VO1.VO1_FILIAL) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VO1") + " VO1 "
        cQuery += "WHERE "
        cQuery +=   " VO1.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VO1.VO1_STATUS NOT IN ('F','C') " // Nao esta Fechada e Cancelada
        oTProcess:SetRegua1(FM_SQL(cQuery))

        cQuery := "SELECT "
        cQuery +=   " DISTINCT VO1.VO1_FILIAL "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VO1") + " VO1 "
        cQuery += "WHERE "
        cQuery +=   " VO1.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VO1.VO1_STATUS NOT IN ('F','C') " // Nao esta Fechada e Cancelada
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasJ, .f., .t.)

        While !(cAliasJ)->(EoF())
            oTProcess:IncRegua1(STR0014 + (cAliasJ)->VO1_FILIAL )	// Gerando JSON de Tempo e Valor de O.S. em Aberto para a Filial

            // Vamos listar todas as OSs filial por filial
            cQuery := "SELECT "
            cQuery +=   " VO1.VO1_NUMOSV "
            cQuery +=   " , VO1.VO1_DATABE "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VO1") + " VO1 "
            cQuery += "WHERE "
            cQuery +=   " VO1.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VO1.VO1_STATUS NOT IN ('F','C') " // Nao esta Fechada e Cancelada
            cQuery +=   " AND VO1.VO1_FILIAL = '" + (cAliasJ)->VO1_FILIAL + "' "
            DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasK, .f., .t.)

            While !(cAliasK)->(EoF())
                nDiasAbOS := Val( DToS( dMV_PAR02 ) ) - Val( (cAliasK)->VO1_DATABE )

                // Vamos levantar os valores de pecas por tipo de tempo
                cQuery := "SELECT "
                cQuery +=   " VO3.VO3_TIPTEM "
                cQuery +=   " , VO3.VO3_LIBVOO "
		        cQuery += "FROM "
		        cQuery +=   RetSQLName("VO3") + " VO3 "
		        cQuery += "INNER JOIN "
		        cQuery +=   RetSQLName("VO2") + " VO2 "
		        cQuery += "ON "
		        cQuery +=   " VO2.VO2_FILIAL = VO3.VO3_FILIAL "
		        cQuery +=   " AND VO2.VO2_NUMOSV = VO3.VO3_NUMOSV "
		        cQuery += "LEFT JOIN "
		        cQuery +=   RetSQLName("VEC") + " VEC "
		        cQuery += "ON "
		        cQuery +=   " VEC.VEC_FILIAL = VO3.VO3_FILIAL "
		        cQuery +=   " AND VEC.VEC_NUMOSV = VO3.VO3_NUMOSV "
		        cQuery +=   " AND VEC.VEC_TIPTEM = VO3.VO3_TIPTEM "
		        cQuery +=   " AND VEC.VEC_GRUITE = VO3.VO3_GRUITE "
		        cQuery +=   " AND VEC.VEC_CODITE = VO3.VO3_CODITE "
		        cQuery += "WHERE "
		        cQuery +=   " VO3.D_E_L_E_T_ = ' ' "
		        cQuery +=   " AND VO2.D_E_L_E_T_ = ' ' "
		        cQuery +=   " AND VEC.D_E_L_E_T_ = ' ' "
		        cQuery +=   " AND VO3.VO3_FILIAL = '" + (cAliasJ)->VO1_FILIAL + "' "
		        cQuery +=   " AND VO3.VO3_NUMOSV = '" + (cAliasK)->VO1_NUMOSV + "' "
		        cQuery +=   " AND VO3.VO3_DATCAN = '" + Space(8) + "' " // Ignora itens cancelados
		        cQuery +=   " AND VO3.VO3_DATFEC = '" + Space(8) + "' " // Ignora itens fechados
		        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasL, .f., .t.)
                
                While !(cAliasL)->(EoF())
                    aValPecOS := FMX_CALPEC(   (cAliasK)->VO1_NUMOSV,  ;
				                            (cAliasL)->VO3_TIPTEM,  ;
				                            ,                       ;
				                            ,                       ;
				                            .T.,                    ;
				                            .T.,                    ;
				                            .F.,                    ;
				                            .T.,                    ;
				                            .T.,                    ;
				                            .T.,                    ;
				                            .T.,                    ;
				                            (cAliasL)->VO3_LIBVOO)    // Matriz TOTAL de Pecas/Requisicoes da OS
                    
                    // Vamos somar os valores das peças
                    For nCntB := 1 to Len(aValPecOS)
                        If Empty(aValPecOS[nCntB,PECA_DATFEC]) // Em Aberto
							nValPec += aValPecOS[nCntB, PECA_VALBRU] - aValPecOS[nCntB, PECA_VALDES]
                        EndIf
                    Next
                    (cAliasL)->(dbSkip())                     
                End
                (cAliasL)->(DbCloseArea())

                // Vamos levantar os valores de servicos por tipo de tempo
                cQuery := "SELECT "
                cQuery +=   " VO4.VO4_TIPTEM "
		        cQuery += "FROM "
		        cQuery +=   RetSQLName("VO4") + " VO4 "
		        cQuery += "WHERE "
		        cQuery +=   " VO4.D_E_L_E_T_ =  ' ' "
		        cQuery +=   " AND VO4.VO4_FILIAL = '" + (cAliasJ)->VO1_FILIAL + "' "
		        cQuery +=   " AND VO4.VO4_NUMOSV = '" + (cAliasK)->VO1_NUMOSV + "' "
		        cQuery +=   " AND VO4.VO4_DATCAN = '" + Space(8) + "' " // Ignora itens cancelados
		        cQuery +=   " AND VO4.VO4_DATFEC = '" + Space(8) + "' " // Ignora itens fechados
		        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasM, .f., .t.)

                While !(cAliasM)->(EoF())
                    aValSerOS := FMX_CALSER((cAliasK)->VO1_NUMOSV,    ;
				                            (cAliasM)->VO4_TIPTEM,    ;
				                            ,                           ;
				                            ,                           ;
				                            .F.,                        ;
				                            .T.,                        ;
				                            .T.,                        ;
				                            .T.,                        ;
				                            .T.,                        ;
				                            .F.)

			        If Len(aValSerOS) == 0
			        	(cAliasM)->(dbSkip())
			        Else
                        For nCntC := 1 to Len(aValSerOS)
                            If Empty(aValSerOS[nCntC, SRVC_DATFEC]) // Em Aberto
                                nValSer += aValSerOS[nCntC, SRVC_VALLIQ] 
                            EndIF
                        Next
                    EndIf
                    (cAliasM)->(dbSkip())
                End
                (cAliasM)->(DbCloseArea())

                nValTotOS := nValPec + nValSer
                AAdd(aOSAber,{      nValPec,    ;   // 01 = Valor das Pecas em Aberto
                                    nValSer,    ;   // 02 = Valor dos Servicos em Aberto
                                    nValTotOS,  ;   // 03 = Soma das Pecas e Servicos em Aberto
                                    0,          ;   // 04 = Representatividade em Percentual
                                    nDiasAbOS,  ;   // 05 = Dias Em Aberto da OS
                                    0})             // 06 = Prazo OS Media Ponderada da OS
                
                nTotGerOS += nValTotOS

                nValPec := 0
                nValSer := 0

                (cAliasK)->(dbSkip())
            End
            (cAliasK)->(DbCloseArea())

            For nCntD := 1 to Len(aOSAber)
                aOSAber[nCntD,4] := (aOSAber[nCntD,3] / nTotGerOS) * 100 // Representatividade em Percentual
                aOSAber[nCntD,6] := aOSAber[nCntD,4] * aOSAber[nCntD,5] // Prazo OS Media Ponderada da OS = Representatividade * Quantidade de Dias em Aberto
                nMedTotOS += aOSAber[nCntD,6]
            Next

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, (cAliasJ)->VO1_FILIAL )[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9513" // Tempo de OS
            jChavePrimaria['sectionCode'        ] := "1301" // Servicos
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nMedTotOS )

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, (cAliasJ)->VO1_FILIAL )[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9514" // Valor de OS Em Aberto 
            jChavePrimaria['sectionCode'        ] := "1301" // Servicos
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nTotGerOS )

            nMedTotOS := 0
            nTotGerOS := 0

            (cAliasJ)->(dbSkip())
        End
        (cAliasJ)->(DbCloseArea())

    Else
        // Vamos levantar todas as OS da filial escolhida
        cQuery := "SELECT "
        cQuery +=   " COUNT (VO1.VO1_NUMOSV) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VO1") + " VO1 "
        cQuery += "WHERE "
        cQuery +=   " VO1.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VO1.VO1_STATUS NOT IN ('F','C') " // Nao esta Fechada e Cancelada
        cQuery +=   " AND VO1.VO1_FILIAL = '" + cMV_PAR03 + "' "
        oTProcess:SetRegua1(FM_SQL(cQuery))

        cQuery := "SELECT "
        cQuery +=   " VO1.VO1_NUMOSV "
        cQuery +=   " , VO1.VO1_DATABE "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VO1") + " VO1 "
        cQuery += "WHERE "
        cQuery +=   " VO1.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VO1.VO1_STATUS NOT IN ('F','C') " // Nao esta Fechada e Cancelada
        cQuery +=   " AND VO1.VO1_FILIAL = '" + cMV_PAR03 + "' "
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasM, .f., .t.)

        While !(cAliasM)->(EoF())
            oTProcess:IncRegua1(STR0015 + cMV_PAR03 )	// Gerando JSON de Tempo de O.S. em Aberto para a Filial
            
            nDiasAbOS := Val( DToS( dMV_PAR02 ) ) - Val( (cAliasM)->VO1_DATABE )

            // Vamos levantar os valores de pecas por tipo de tempo
            cQuery := "SELECT "
            cQuery +=   " VO3.VO3_TIPTEM "
            cQuery +=   " , VO3.VO3_LIBVOO "
		    cQuery += "FROM "
		    cQuery +=   RetSQLName("VO3") + " VO3 "
		    cQuery += "INNER JOIN "
		    cQuery +=   RetSQLName("VO2") + " VO2 "
		    cQuery += "ON "
		    cQuery +=   " VO2.VO2_FILIAL = VO3.VO3_FILIAL "
		    cQuery +=   " AND VO2.VO2_NUMOSV = VO3.VO3_NUMOSV "
		    cQuery += "LEFT JOIN "
		    cQuery +=   RetSQLName("VEC") + " VEC "
		    cQuery += "ON "
		    cQuery +=   " VEC.VEC_FILIAL = VO3.VO3_FILIAL "
		    cQuery +=   " AND VEC.VEC_NUMOSV = VO3.VO3_NUMOSV "
		    cQuery +=   " AND VEC.VEC_TIPTEM = VO3.VO3_TIPTEM "
		    cQuery +=   " AND VEC.VEC_GRUITE = VO3.VO3_GRUITE "
		    cQuery +=   " AND VEC.VEC_CODITE = VO3.VO3_CODITE "
		    cQuery += "WHERE "
		    cQuery +=   " VO3.D_E_L_E_T_ = ' ' "
		    cQuery +=   " AND VO2.D_E_L_E_T_ = ' ' "
		    cQuery +=   " AND VEC.D_E_L_E_T_ = ' ' "
		    cQuery +=   " AND VO3.VO3_FILIAL = '" + cMV_PAR03 + "' "
		    cQuery +=   " AND VO3.VO3_NUMOSV = '" + (cAliasM)->VO1_NUMOSV + "' "
		    cQuery +=   " AND VO3.VO3_DATCAN = '" + Space(8) + "' " // Ignora itens cancelados
		    cQuery +=   " AND VO3.VO3_DATFEC = '" + Space(8) + "' " // Ignora itens fechados
		    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasN, .f., .t.)
            
            While !(cAliasN)->(EoF())
                aValPecOS := FMX_CALPEC(    (cAliasM)->VO1_NUMOSV,  ;
			                                (cAliasN)->VO3_TIPTEM,  ;
			                                ,                       ;
			                                ,                       ;
			                                .T.,                    ;
			                                .T.,                    ;
			                                .F.,                    ;
			                                .T.,                    ;
				                            .T.,                    ;
				                            .T.,                    ;
				                            .T.,                    ;
				                            (cAliasN)->VO3_LIBVOO)    // Matriz TOTAL de Pecas/Requisicoes da OS
                    
                // Vamos somar os valores das peças
                For nCntD := 1 to Len(aValPecOS)
                    If Empty(aValPecOS[nCntD,PECA_DATFEC]) // Em Aberto
						nValPec += aValPecOS[nCntD, PECA_VALBRU] - aValPecOS[nCntD, PECA_VALDES]
                    EndIf
                Next
                (cAliasN)->(dbSkip())                     
            End
            (cAliasN)->(DbCloseArea())

            // Vamos levantar os valores de servicos por tipo de tempo
            cQuery := "SELECT "
            cQuery +=   " VO4.VO4_TIPTEM "
		    cQuery += "FROM "
		    cQuery +=   RetSQLName("VO4") + " VO4 "
		    cQuery += "WHERE "
		    cQuery +=   " VO4.D_E_L_E_T_ =  ' ' "
		    cQuery +=   " AND VO4.VO4_FILIAL = '" + cMV_PAR03 + "' "
		    cQuery +=   " AND VO4.VO4_NUMOSV = '" + (cAliasM)->VO1_NUMOSV + "' "
		    cQuery +=   " AND VO4.VO4_DATCAN = '" + Space(8) + "' " // Ignora itens cancelados
		    cQuery +=   " AND VO4.VO4_DATFEC = '" + Space(8) + "' " // Ignora itens fechados
		    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasO, .f., .t.)
            
            While !(cAliasO)->(EoF())
                aValSerOS := FMX_CALSER((cAliasM)->VO1_NUMOSV,    ;
			                            (cAliasO)->VO4_TIPTEM,    ;
			                            ,                           ;
			                            ,                           ;
			                            .F.,                        ;
			                            .T.,                        ;
			                            .T.,                        ;
			                            .T.,                        ;
			                            .T.,                        ;
			                            .F.)
			    If Len(aValSerOS) == 0
			    	(cAliasO)->(dbSkip())
			    Else
                    For nCntE := 1 to Len(aValSerOS)
                        If Empty(aValSerOS[nCntE, SRVC_DATFEC]) // Em Aberto
                            nValSer += aValSerOS[nCntE, SRVC_VALLIQ] 
                        EndIF
                    Next
                EndIf
                (cAliasO)->(dbSkip())
            End
            (cAliasO)->(DbCloseArea())

            nValTotOS := nValPec + nValSer
            AAdd(aOSAber,{      nValPec,    ;   // 01 = Valor das Pecas em Aberto
                                nValSer,    ;   // 02 = Valor dos Servicos em Aberto
                                nValTotOS,  ;   // 03 = Soma das Pecas e Servicos em Aberto
                                0,          ;   // 04 = Representatividade em Percentual
                                nDiasAbOS,  ;   // 05 = Dias Em Aberto da OS
                                0})             // 06 = Prazo OS Media Ponderada da OS
            
            nTotGerOS += nValTotOS

            nValPec := 0
            nValSer := 0

            (cAliasM)->(dbSkip())
        End
        (cAliasM)->(DbCloseArea())
        
        For nCntF := 1 to Len(aOSAber)
            aOSAber[nCntF,4] := (aOSAber[nCntF,3] / nTotGerOS) * 100 // Representatividade em Percentual
            aOSAber[nCntF,6] := aOSAber[nCntF,4] * aOSAber[nCntF,5] // Prazo OS Media Ponderada da OS = Representatividade * Quantidade de Dias em Aberto
            nMedTotOS += aOSAber[nCntF,6]
        Next

        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, cMV_PAR03 )[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9513" // Tempo de OS
        jChavePrimaria['sectionCode'        ] := "1301" // Servicos
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nMedTotOS )
        
        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, cMV_PAR03 )[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9514" // Valor de OS Em Aberto 
        jChavePrimaria['sectionCode'        ] := "1301" // Servicos
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nTotGerOS )
        
    EndIf

    //
    // Oitavo Processamento e Nono Processamento
    // Tempo de Pedido de Venda de Maquinas e Valor Pedidos Abertos de Venda de Maquinas (Atendimentos)
    //

    nDiasAbAt := 0
    nValAtend := 0
    nTotGerAt := 0
    nMedTotAt := 0
    aAtenAber := {}

    If Empty(cMV_PAR03) // Gera para qual filial?
        
        // Vamos listar todas as filiais
        cQuery := "SELECT "
        cQuery +=   " COUNT(DISTINCT VV0.VV0_FILIAL) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VV0") + " VV0 "
        cQuery += "JOIN "
        cQuery +=   RetSQLName("VV9") + " VV9 "
        cQuery += "ON "
        cQuery +=   " VV0.VV0_FILIAL = VV9.VV9_FILIAL "
        cQuery +=   " AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
        cQuery += "WHERE "
        cQuery +=   " VV0.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV9.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV9.VV9_STATUS NOT IN ('F','C') " // Nao esta Finalizado e Cancelado
        cQuery +=   " AND VV0.VV0_OPEMOV IN ('0','1','8') " // 0=Venda; 1=Simulacao; 8=Venda Futura
        cQuery +=   " AND VV0.VV0_TIPFAT IN ('0','1') "// 0=Normal Novo; 1=Normal Usado
        oTProcess:SetRegua1(FM_SQL(cQuery))

        cQuery := "SELECT "
        cQuery +=   " DISTINCT VV0.VV0_FILIAL "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VV0") + " VV0 "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV9") + " VV9 "
        cQuery += "ON "
        cQuery +=   " VV0.VV0_FILIAL = VV9.VV9_FILIAL "
        cQuery +=   " AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
        cQuery += "WHERE "
        cQuery +=   " VV0.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV9.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV9.VV9_STATUS NOT IN ('F','C') " // Nao esta Finalizado e Cancelado
        cQuery +=   " AND VV0.VV0_OPEMOV IN ('0','1','8') " // 0=Venda; 1=Simulacao; 8=Venda Futura
        cQuery +=   " AND VV0.VV0_TIPFAT IN ('0','1') "// 0=Normal Novo; 1=Normal Usado
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasP, .f., .t.)

        While !(cAliasP)->(EoF())
            oTProcess:IncRegua1(STR0016 + (cAliasP)->VV0_FILIAL )	// Gerando JSON de Tempo e Valor de Pedido em Aberto para a Filial

            // Vamos listar todos os atendimentos filial por filial
            cQuery := "SELECT "
            cQuery +=   " VV0.VV0_NUMTRA "
            cQuery +=   " , VV0.VV0_DATMOV "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VV0") + " VV0 "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("VV9") + " VV9 "
            cQuery += "ON "
            cQuery +=   " VV0.VV0_FILIAL = VV9.VV9_FILIAL "
            cQuery +=   " AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
            cQuery += "WHERE "
            cQuery +=   " VV0.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV9.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VV9.VV9_STATUS NOT IN ('F','C') " // Nao esta Finalizado e Cancelado
            cQuery +=   " AND VV0.VV0_OPEMOV IN ('0','1','8') " // 0=Venda; 1=Simulacao; 8=Venda Futura
            cQuery +=   " AND VV0.VV0_TIPFAT IN ('0','1') "// 0=Normal Novo; 1=Normal Usado
            cQuery +=   " AND VV0.VV0_FILIAL = '" + (cAliasP)->VV0_FILIAL + "' "
            DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasQ, .f., .t.)

            While !(cAliasQ)->(EoF())
                nDiasAbAt := Val( DToS( dMV_PAR02 ) ) - Val( (cAliasQ)->VV0_DATMOV )

                // Vamos levantar o valor de cada atendimento
                cQuery := "SELECT "
                cQuery +=   " VV0.VV0_VALTOT "
		        cQuery += "FROM "
		        cQuery +=   RetSQLName("VV0") + " VV0 "
		        cQuery += "WHERE "
		        cQuery +=   " VV0.D_E_L_E_T_ = ' ' "
		        cQuery +=   " AND VV0.VV0_FILIAL = '" + (cAliasP)->VV0_FILIAL + "' "
		        cQuery +=   " AND VV0.VV0_NUMTRA = '" + (cAliasQ)->VV0_NUMTRA + "' "
		        nValAtend := FM_SQL(cQuery)

                AAdd(aAtenAber, {   nValAtend,  ;   // 01 = Valor dos Atendimentos em Aberto
                                    0,          ;   // 02 = Representatividade em Percentual
                                    nDiasAbAt,  ;   // 03 = Dias Em Aberto do Atendimento
                                    0})             // 04 = Prazo Atendimento Media Ponderada
                
                nTotGerAt += nValAtend

                (cAliasQ)->(dbSkip())
            End
            (cAliasQ)->(DbCloseArea())

            For nCntG := 1 to Len(aAtenAber)
                aAtenAber[nCntG,2] := (aAtenAber[nCntG,1] / nTotGerAt) * 100 // Representatividade em Percentual
                aAtenAber[nCntG,4] := aAtenAber[nCntG,2] * aAtenAber[nCntG,3] // Prazo OS Media Ponderada da OS = Representatividade * Quantidade de Dias em Aberto
                nMedTotAt += aAtenAber[nCntG,4]
            Next

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, (cAliasP)->VV0_FILIAL )[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9611" // Tempo de Pedido
            jChavePrimaria['sectionCode'        ] := "1401" // Administrativo
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nMedTotAt )

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, (cAliasP)->VV0_FILIAL )[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9612" // Valor Pedidos Abertos
            jChavePrimaria['sectionCode'        ] := "1401" // Administrativo
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( nTotGerAt )

            nMedTotAt := 0
            nTotGerAt := 0

            (cAliasP)->(dbSkip())
        End
        (cAliasP)->(DbCloseArea())

    Else
        // Vamos levantar todos os atendimentos da filial escolhida
        cQuery := "SELECT "
        cQuery +=   " COUNT (VV0.VV0_NUMTRA) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VV0") + " VV0 "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV9") + " VV9 "
        cQuery += "ON "
        cQuery +=   " VV0.VV0_FILIAL = VV9.VV9_FILIAL "
        cQuery +=   " AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
        cQuery += "WHERE "
        cQuery +=   " VV0.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV9.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV9.VV9_STATUS NOT IN ('F','C') " // Nao esta Finalizado e Cancelado
        cQuery +=   " AND VV0.VV0_OPEMOV IN ('0','1','8') " // 0=Venda; 1=Simulacao; 8=Venda Futura
        cQuery +=   " AND VV0.VV0_TIPFAT IN ('0','1') "// 0=Normal Novo; 1=Normal Usado
        cQuery +=   " AND VV0.VV0_FILIAL = '" + cMV_PAR03 + "' "
        oTProcess:SetRegua1(FM_SQL(cQuery))

        cQuery := "SELECT "
        cQuery +=   " VV0.VV0_NUMTRA "
        cQuery +=   " , VV0.VV0_DATMOV "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VV0") + " VV0 "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("VV9") + " VV9 "
        cQuery += "ON "
        cQuery +=   " VV0.VV0_FILIAL = VV9.VV9_FILIAL "
        cQuery +=   " AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
        cQuery += "WHERE "
        cQuery +=   " VV0.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV9.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND VV9.VV9_STATUS NOT IN ('F','C') " // Nao esta Finalizado e Cancelado
        cQuery +=   " AND VV0.VV0_OPEMOV IN ('0','1','8') " // 0=Venda; 1=Simulacao; 8=Venda Futura
        cQuery +=   " AND VV0.VV0_TIPFAT IN ('0','1') "// 0=Normal Novo; 1=Normal Usado
        cQuery +=   " AND VV0.VV0_FILIAL = '" + cMV_PAR03 + "' "
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasR, .f., .t.)

        While !(cAliasR)->(EoF())
            oTProcess:IncRegua1(STR0016 + cMV_PAR03 )	// Gerando JSON de Tempo e Valor de Pedido em Aberto para a Filial
            
            nDiasAbAt := Val( DToS( dMV_PAR02 ) ) - Val( (cAliasR)->VV0_DATMOV )

            // Vamos levantar o valor de cada atendimento
            cQuery := "SELECT "
            cQuery +=   " VV0.VV0_VALTOT "
		    cQuery += "FROM "
		    cQuery +=   RetSQLName("VV0") + " VV0 "
		    cQuery += "WHERE "
		    cQuery +=   " VV0.D_E_L_E_T_ = ' ' "
		    cQuery +=   " AND VV0.VV0_FILIAL = '" + cMV_PAR03 + "' "
		    cQuery +=   " AND VV0.VV0_NUMTRA = '" + (cAliasR)->VV0_NUMTRA + "' "
		    nValAtend := FM_SQL(cQuery)
            
            AAdd(aAtenAber, {   nValAtend,  ;   // 01 = Valor dos Atendimentos em Aberto
                                0,          ;   // 02 = Representatividade em Percentual
                                nDiasAbAt,  ;   // 03 = Dias Em Aberto do Atendimento
                                0})             // 04 = Prazo Atendimento Media Ponderada
            
            nTotGerAt += nValAtend
            
            (cAliasR)->(dbSkip())
        End

        (cAliasR)->(DbCloseArea())

        For nCntH := 1 to Len(aAtenAber)
            aAtenAber[nCntH,2] := (aAtenAber[nCntH,1] / nTotGerAt) * 100 // Representatividade em Percentual
            aAtenAber[nCntH,4] := aAtenAber[nCntH,2] * aAtenAber[nCntH,3] // Prazo OS Media Ponderada da OS = Representatividade * Quantidade de Dias em Aberto
            nMedTotAt += aAtenAber[nCntH,4]
        Next

        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, cMV_PAR03 )[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9611" // Tempo de Pedido
        jChavePrimaria['sectionCode'        ] := "1401" // Administrativo
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nMedTotAt )
        
        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, cMV_PAR03 )[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9612" // Valor Pedidos Abertos
        jChavePrimaria['sectionCode'        ] := "1401" // Administrativo
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( nTotGerAt )

    EndIf

    //
    // Decimo Processamento
    // Valor Peças Zero Vendas
    //

    // Observacao: aqui so estou trabalhando com SF4 compartilhada (TODO --> SF4 Exclusiva)

    If Empty(cMV_PAR03) // Gera para qual filial?

        // Vamos listar todas as filiais
        cQuery := "SELECT "
        cQuery +=   " COUNT(DISTINCT SD2.D2_FILIAL) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("SD2") + " SD2 "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("SF4") + " SF4 "
        cQuery += "ON "
        cQuery +=   " SF4.F4_CODIGO = SD2.D2_TES "
        cQuery += "WHERE "
        cQuery +=   " SD2.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND SF4.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND SF4.F4_OPEMOV = '05' "
        cQuery += "HAVING "
        cQuery +=   " MAX(SD2.D2_EMISSAO) < '" + DToS( YearSub(dMV_PAR02, 3) ) + "' " // Pecas com zero vendas nos ultimos 3 anos (36 meses)
        oTProcess:SetRegua1(FM_SQL(cQuery))

        cQuery := "SELECT "
        cQuery +=   " DISTINCT SD2.D2_FILIAL "
        cQuery += "FROM "
        cQuery +=   RetSQLName("SD2") + " SD2 "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("SF4") + " SF4 "
        cQuery += "ON "
        cQuery +=   " SF4.F4_CODIGO = SD2.D2_TES "
        cQuery += "WHERE "
        cQuery +=   " SD2.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND SF4.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND SF4.F4_OPEMOV = '05' "
        cQuery += "GROUP BY "
        cQuery +=   " SD2.D2_FILIAL "
        cQuery += "HAVING "
        cQuery +=   " MAX(SD2.D2_EMISSAO) < '" + DToS( YearSub(dMV_PAR02, 3) ) + "' " // Pecas com zero vendas nos ultimos 3 anos (36 meses)
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasS, .f., .t.)

        While !(cAliasS)->(EoF())
            oTProcess:IncRegua1(STR0017 + (cAliasS)->D2_FILIAL )	// Gerando JSON de Valor de Peças Zero Vendas para a Filial

            cQuery := "SELECT "
            cQuery +=   " SUM (SB2.B2_CM1) "
            cQuery += "FROM "
            cQuery +=   RetSQLName("SB2") + " SB2 "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("SD2") + " SD2 "
            cQuery += "ON "
            cQuery +=   " SB2.B2_COD = SD2.D2_COD "
            cQuery +=   " AND SB2.B2_FILIAL = SD2.D2_FILIAL "
            cQuery += "INNER JOIN "
            cQuery +=   RetSQLName("SF4") + " SF4 "
            cQuery += "ON "
            cQuery +=   " SF4.F4_CODIGO = SD2.D2_TES "
            cQuery += "WHERE "
            cQuery +=   " SB2.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND SD2.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND SF4.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND SF4.F4_OPEMOV = '05' "
            cQuery +=   " AND SD2.D2_FILIAL = '" + (cAliasS)->D2_FILIAL + "' "
            cQuery += "HAVING "
            cQuery +=   " MAX(SD2.D2_EMISSAO) < '" + DToS( YearSub(dMV_PAR02, 3) ) + "' " // Pecas com zero vendas nos ultimos 3 anos (36 meses)

            Aadd(aDFS,JsonObject():new())
            jChavePrimaria := JsonObject():new()
            nPos := Len(aDFS)
            jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
            jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
            jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, (cAliasS)->D2_FILIAL )[18], "@R 99.999.999/9999-99" )
            jChavePrimaria['codeDFSPlan'        ] := "9613" // Valor Pecas Zero Vendas
            jChavePrimaria['sectionCode'        ] := "1201" // Pecas
            aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
            aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
            aDFS[nPos]['balanceValue'           ] := cValToChar( FM_SQL(cQuery) )

            (cAliasS)->(dbSkip())
        End
        (cAliasS)->(DbCloseArea())

    Else

        cQuery := "SELECT "
        cQuery +=   " SUM (SB2.B2_CM1) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("SB2") + " SB2 "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("SD2") + " SD2 "
        cQuery += "ON "
        cQuery +=   " SB2.B2_COD = SD2.D2_COD "
        cQuery +=   " AND SB2.B2_FILIAL = SD2.D2_FILIAL "
        cQuery += "INNER JOIN "
        cQuery +=   RetSQLName("SF4") + " SF4 "
        cQuery += "ON "
        cQuery +=   " SF4.F4_CODIGO = SD2.D2_TES "
        cQuery += "WHERE "
        cQuery +=   " SB2.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND SD2.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND SF4.D_E_L_E_T_ =  ' ' "
        cQuery +=   " AND SF4.F4_OPEMOV = '05' "
        cQuery +=   " AND SD2.D2_FILIAL = '" + cMV_PAR03 + "' "
        cQuery += "HAVING "
        cQuery +=   " MAX(SD2.D2_EMISSAO) < '" + DToS( YearSub(dMV_PAR02, 3) ) + "' " // Pecas com zero vendas nos ultimos 3 anos (36 meses)
        
        Aadd(aDFS,JsonObject():new())
        jChavePrimaria := JsonObject():new()
        nPos := Len(aDFS)
        jChavePrimaria['periodMonth'        ] := cValToChar( Month(dMV_PAR02) )
        jChavePrimaria['periodYear'         ] := cValToChar( Year(dMV_PAR02) )
        jChavePrimaria['dealerBranchCode'   ] := Transform( FWArrFilAtu(, cMV_PAR03 )[18], "@R 99.999.999/9999-99" )
        jChavePrimaria['codeDFSPlan'        ] := "9613" // Valor Pecas Zero Vendas
        jChavePrimaria['sectionCode'        ] := "1201" // Pecas
        aDFS[nPos]['dfsPk'                  ] := jChavePrimaria
        aDFS[nPos]['dealerHeadOfficeCode'   ] := Transform( FWArrFilAtu(,cMV_PAR01)[18], "@R 99.999.999/9999-99" )
        aDFS[nPos]['balanceValue'           ] := cValToChar( FM_SQL(cQuery) )

    EndIf

    cJsonFinal := "["
    
    For nCntA := 1 to Len(aDFS)
        cJsonFinal += aDFS[nCntA]:toJson() + ","
    Next
    
    cJsonFinal := Stuff(cJsonFinal,Len(cJsonFinal),2,"]")
    
    FreeObj(jChavePrimaria)

    lGrvJSON := .t.
    // Gravacao do arquivo JSON no diretorio
    If !Empty(cMV_PAR04)
        cArqCNPJ    := FWArrFilAtu(,cMV_PAR01)[18]
        cArqMesAno  := cValToChar( Month(dMV_PAR02) ) + cValToChar( Year(dMV_PAR02) )
        cArqTStamp  := StrTran(FWTimeStamp(3,Date()),":","-")
        
        lGrvJSON := OA200JSON( RTrim(cMV_PAR04), RTrim(cMV_PAR04) + "dfsgerencial_" + cArqCNPJ + "_" + cArqMesAno + "_" + cArqTStamp + ".json" , cJsonFinal , "OFIA204" )
    EndIf
    
    // Comentado apenas para nao transmitir neste momento
    /*

    If lGrvJSON

        // Chamada de função para transmissão do JSON via API
        Processa( {|| OA200API(cEndPoint,cJsonFinal,"OFIA204") }, "Aguarde" + "...", "Realizando Transmissão via API" + "...",.t.)

    EndIf

    */

    ConOut(Chr(13) + Chr(10))
    ConOut("---------------------------------------------------------------")
    ConOut(" #######  ######## ####    ###     #######    #####   ##       ")
    ConOut("##     ## ##        ##    ## ##   ##     ##  ##   ##  ##    ## ")
    ConOut("##     ## ##        ##   ##   ##         ## ##     ## ##    ## ")
    ConOut("##     ## ######    ##  ##     ##  #######  ##     ## ##    ## ")
    ConOut("##     ## ##        ##  ######### ##        ##     ## #########")
    ConOut("##     ## ##        ##  ##     ## ##         ##   ##        ## ")
    ConOut(" #######  ##       #### ##     ## #########   #####         ## ")
    ConOut("---------------------------------------------------------------")
    ConOut(Chr(13) + Chr(10))
    ConOut( STR0018 + cAuxData + " - " + Time() )	// FIM DA GERACAO DO AGCO DFS GERENCIAL REFERENCIAL JSON - OFIA204:
    ConOut( STR0019 + ElapTime( cTimeIni, Time() ) )	// TEMPO DECORRIDO:

Return

/*/
{Protheus.doc} OA2040027_NivelCadastroMaquinaVFG
Funcao que indica o nivel do cadastro realizado para a VFG informada. Este nivel indica se deve ser considerado marca, grupo de modelo ou modelo.
@type   Static Function
@author Otávio Favarelli
@since  15/06/2020
@param  cVFGFILIAL, Caractere, Filial do registro da VFG.
@param  cVFGCODSEQ, Caractere, Codigo Sequencial do registro da VFG.
@param  cVFGCODMAR, Caractere, Codigo da Marca do registro da VFG. Quando desejar retornar a marca, informe-a como referencia.
@param  cVFGGRUMOD, Caractere, Codigo do Grupo de Modelo do registro da VFG.
@param  cVFGMODVEI, Caractere, Codigo do Modelo do registro da VFG.
@return cRetMod,    Caractere, Codigo dos modelos a serem considerados de acordo com os parametros informados.    
/*/
Static Function OA2040027_NivelCadastroMaquinaVFG(cVFGFILIAL,cVFGCODSEQ,cVFGCODMAR,cVFGGRUMOD,cVFGMODVEI)

    Local cRetMod
    Local cAli2040      := GetNextAlias()
    Local cAli2041      := GetNextAlias()
    //
    Default cVFGFILIAL  := ""
    Default cVFGCODSEQ  := ""
    Default cVFGCODMAR  := ""
    Default cVFGGRUMOD  := ""
    Default cVFGMODVEI  := ""

    If Empty(cVFGCODSEQ)
        Help(NIL, NIL, STR0020, NIL, STR0021, /* Sequencial Em Branco | Um registro da tabela VFG está com o campo VFG_CODSEQ em branco. Impossível continuar. */;
        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0022})	// Verifique a integridade dos dados inseridos na tabela VFG, bem como a forma de inserção dos mesmos, e corrija-os.
        Return
    Else
        If Empty(cVFGCODMAR) .and. Empty(cVFGGRUMOD) .and. Empty(cVFGMODVEI) // Temos apenas a informacao do sequencial
            cQuery := "SELECT "
            cQuery +=   " VFG.VFG_FILIAL "
            cQuery +=   " , VFG.VFG_CODMAR "
            cQuery +=   " , VFG.VFG_GRUMOD "
            cQuery +=   " , VFG.VFG_MODVEI "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VFG") + " VFG "
            cQuery += "WHERE "
            cQuery +=   " VFG.D_E_L_E_T_ =  ' ' "
            cQuery +=   " AND VFG.VFG_CODSEQ =  '" + cVFGCODSEQ + "' "
            cQuery +=   " AND VFG.VFG_TIPREG = '2' "    // 2=Maquina
            DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAli2040, .f., .t.)

            While !(cAli2040)->(EoF())
                cVFGFILIAL  := (cAli2040)->VFG_FILIAL
                cVFGCODMAR  := (cAli2040)->VFG_CODMAR
                cVFGGRUMOD  := (cAli2040)->VFG_GRUMOD
                cVFGMODVEI  := (cAli2040)->VFG_MODVEI

                (cAli2040)->(dbSkip())                
            End       
            (cAli2040)->(DbCloseArea())
        EndIf

        Do Case
		    Case !Empty(cVFGMODVEI) // Marca + Modelo Especifico
                cRetMod := "'" + AllTrim(cVFGMODVEI) + "'"
            Otherwise
                cQuery := "SELECT "
                cQuery +=   " VV2.VV2_MODVEI "
                cQuery += "FROM "
                cQuery +=   RetSQLName("VV2") + " VV2 "
                cQuery += "WHERE "
                cQuery +=   " VV2.D_E_L_E_T_ =  ' ' "
                cQuery +=   " AND VV2.VV2_CODMAR =  '" + cVFGCODMAR + "' " //  Todos os modelos desta Marca
                If !Empty(cVFGGRUMOD) // Todos os modelos deste Grupo de Modelo
                    cQuery +=   " AND VV2.VV2_GRUMOD =  '" + cVFGGRUMOD + "' "
                EndIf
                DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAli2041, .f., .t.)

                While !(cAli2041)->(EoF())
                    cRetMod := "'" + (cAli2041)->VV2_MODVEI + "',"
                    (cAli2041)->(dbSkip())   
                End       
                (cAli2041)->(DbCloseArea())

                cRetMod := Stuff(cRetMod,Len(cRetMod),2," ")     
		EndCase
    EndIf

Return cRetMod
