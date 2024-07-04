#Include "Protheus.ch"
#Include "OFIA205.ch"

/*/
{Protheus.doc} OFIA205
Rotina que realiza o cadastro do DEF (DFS D-In) Contabil utilizando De/Para de contas AGCO e contas concessionario.
Este De/Para e fornecido pela AGCO.
@type   Function
@author Otavio Favarelli
@since  05/12/2019
@param  nil
@return nil
/*/
Function OFIA205()

    Local oTProcess
    //
    Local bProcess
    //
    Local lPainelAux
    Local lViewExecute
    Local lOneMeter
    //
    Local cPerg
    Local cQuery

	//
	// Validacao de Licencas DMS
	//
	If !OFValLicenca():ValidaLicencaDMS()
		Return
	EndIf

    cQuery := "SELECT "
    cQuery += 	" COUNT(VX5_CHAVE) "
    cQuery += "FROM "
    cQuery +=   RetSQLName("VX5") + " VX5 "
    cQuery += "WHERE "
    cQuery +=   " VX5.D_E_L_E_T_ = ' ' "
    cQuery +=   " AND VX5.VX5_CHAVE = '080' "

    If FM_SQL(cQuery) > 0
        bProcess        := { |oSelf| OA2050017_ProcessaCadDePara(oSelf) }
        lPainelAux      := .t.
        lViewExecute    := .t.
        lOneMeter       := .f.
        cPerg           := "OFIA205" // Pergunte

        oTProcess := tNewProcess():New(;
        STR0001,;				// 01 - Nome da funcao que esta chamando o objeto.	// OFIA205
        STR0002,;				// 02 - Titulo da arvore de opcões.	// Cadastro DEF Contabil De/Para de contas AGCO / Concessionario.
        bProcess,;				// 03 - Bloco de execucao que sera executado ao confirmar a tela.
        STR0003,;				// 04 - Descricao da rotina.	// Esta rotina realiza o cadastro do DEF (DFS D-In) Contabil utilizando De/Para de contas AGCO e contas concessionario.
        cPerg,;					// 05 - Nome do Pergunte (SX1) a ser utilizado na rotina.
        /* aInfoCustom */ ,;	// 06 - Informacões adicionais carregada na arvore de opcões.
        lPainelAux,;			// 07 - Se .T. cria uma novo painel auxiliar ao executar a rotina.
        /* nSizePanelAux */ ,;	// 08 - Tamanho do painel auxiliar, utilizado quando lPainelAux = .T.
        /* cDescriAux */ ,;		// 09 - Descricao a ser exibida no painel auxiliar.
        lViewExecute,;			// 10 - Se .T. exibe o painel de execucao. Se .f., apenas executa a funcao sem exibir a regua de processamento.
        lOneMeter;				// 11 - Se .T. cria apenas uma regua de processamento.
        )
    Else
        Help(NIL, NIL, STR0004, NIL, STR0005, /* Chave Inexistente | A chave 080 - Plano Contabil DFS AGCO nao foi encontrada na tabela VX5. Impossivel continuar! */;
        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006})	// Acesse a rotina Tab. Gener Conces. (OFIOA560) atualizada para criar esta chave.
    EndIf

Return

/*/
{Protheus.doc} OA2050017_ProcessaCadDePara
Realiza o processamento geral do cadastro de DEF contabil De/Para
@type   Static Function
@author Otavio Favarelli
@since  05/12/2019
@param  oTProcess   ,Objeto ,Objeto tNewProcess
@return nil
/*/
Static Function OA2050017_ProcessaCadDePara(oTProcess)

    Local cQuery
    Local cAliasA
    Local cAliasB
    Local cAliasC
    Local cAuxData
	Local c205Par01 := MV_PAR01
    //
    Local nCntForB, nCntForC, nCntForD, nCntForE, nCntForF
    Local nPos
    //
    Local lCriaCabec
	//
	Local aUni
    Local aFil

    Private aFilComp
    Private aPlnCtbDePara
    Private aCenCusDePara
    Private cGrEmpDEF
    Private cEmpDEF

    DbSelectArea("VD7")

    If Empty(c205Par01)
        Help(NIL, NIL, STR0007, NIL, STR0008 , /* Pergunta Em Branco | A Pergunta Código DEF esta em branco. Impossivel continuar. */;
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009})	// Preencha a pergunta Código DEF para realizar o cadastro corretamente.
        Return
    EndIf

	If Empty(MV_PAR04)
        Help(NIL, NIL, STR0007, NIL, STR0027 , /* Pergunta Em Branco | A Pergunta Filial Matriz esta em branco. Impossivel continuar. */;
            1, 0, NIL, NIL, NIL, NIL, NIL, {STR0028})	// Preencha a pergunta Filial Matriz para realizar o cadastro corretamente.
        Return
    EndIf

    lCriaCabec := .t.

    cQuery := "SELECT "
    cQuery +=   " COUNT(*) "
    cQuery += "FROM "
    cQuery +=   RetSQLName("VD7") + " VD7 "
    cQuery += "WHERE "
    cQuery +=   " VD7.D_E_L_E_T_ =  ' ' "
    cQuery +=   " AND VD7.VD7_FILIAL = '" + xFilial("VD7") + "' "
    cQuery +=   " AND VD7.VD7_CODDEF = '" + Alltrim(MV_PAR01) + "' " // Código DEF?
	
	// DEF ja cadastrado
	If FM_SQL(cQuery) > 0
		
		If !MsgYesNo(STR0010 + MV_PAR01 + STR0011)	// O DEF | já esta cadastrado no sistema. Deseja continuar a importacao utilizando este DEF? Os itens existentes para este DEF serão apagados.
    		Return
    	Else
			
			lCriaCabec := .f.
			
			cQuery := "SELECT "
    		cQuery +=   " COUNT(*) "
    		cQuery += "FROM "
    		cQuery +=   RetSQLName("VDB") + " VDB "
    		cQuery += "WHERE "
    		cQuery +=   " VDB.D_E_L_E_T_ =  ' ' "
    		cQuery +=   " AND VDB.VDB_CODDEF = '" + Alltrim(MV_PAR01) + "' " // Código DEF?

			If FM_SQL(cQuery) > 0
				Help(NIL, NIL, STR0012, NIL, STR0013,/* Itens do DEF com históricos gerados | O Código DEF informado já possui valores históricos gerados no sistema. Impossível continuar. */;
            	1, 0, NIL, NIL, NIL, NIL, NIL, {STR0014})	// Utilize um novo Código DEF ou utilize um código DEF sem valores históricos gerados.
        		
				Return 
			EndIf
			
    	EndIf

	EndIf

	If !OA2050037_LeituraCSVPlanoContas(MV_PAR02)
		Return
    EndIf
    
    If !OA2050047_LeituraCSVCentroCusto(MV_PAR03)
		Return
    EndIf

	cAuxData := Dtoc(dDataBase)

    ConOut(Chr(13) + Chr(10))
    ConOut("--------------------------------------------------------------")
    ConOut(" #######  ######## ####    ###     #######    #####   ########")
    ConOut("##     ## ##        ##    ## ##   ##     ##  ##   ##  ##      ")
    ConOut("##     ## ##        ##   ##   ##         ## ##     ## ##      ")
    ConOut("##     ## ######    ##  ##     ##  #######  ##     ## ####### ")
    ConOut("##     ## ##        ##  ######### ##        ##     ##       ##")
    ConOut("##     ## ##        ##  ##     ## ##         ##   ##  ##    ##")
    ConOut(" #######  ##       #### ##     ## #########   #####    ###### ")
    ConOut("--------------------------------------------------------------")
    ConOut(Chr(13) + Chr(10))
    ConOut(STR0015 + cAuxData + STR0016 +Time())	// INICIO DO PROCESSAMENTO: | -

	// Inicio da Transacao
    Begin Transaction
    //

    aFilComp 	:= {}
	cGrEmpDEF	:= FWArrFilAtu(,MV_PAR04)[1]	// Grupo de Empresas - SM0_GRPEMP
	cEmpDEF		:= FWArrFilAtu(,MV_PAR04)[3]	// Empresa - SM0_EMPRESA

	// Levantamento de todas as filiais da empresa na qual a filial matriz faz parte (MV_PAR04)
	aUni := FWAllUnitBusiness(cEmpDEF,cGrEmpDEF)
	If Len(aUni) == 0
		aAdd(aUni, "")
	Endif
	For nCntForB := 1 to Len(aUni)  
		aFil := FWAllFilial(cEmpDEF,aUni[nCntForB],cGrEmpDEF)
		For nCntForC := 1 to Len(aFil)
			AAdd(aFilComp,cEmpDEF+aUni[nCntForB]+aFil[nCntForC])
		Next
	Next

	If !lCriaCabec // Caso seja utilizado um DEF ja cadastrado, vamos precisar verificar as tabelas adjacentes e deleta-las
		FWMsgRun(, { || OA2050057_DeletaDEF(MV_PAR01) }, STR0031, STR0032 + MV_PAR01 ) // Aguarde | Removendo Registros Cadastrais Existentes do DEF
    Else // Vamos criar um novo DEF
        OA2050027_CriaCabecalhoDEF(MV_PAR01)
    EndIf

	oTProcess:SetRegua1(3) // Patrimonial e Resultado

    // Vamos levantar as filiais ativas a serem consideradas na gravacao dos itens do DEF (VDA)
    cAliasB := GetNextAlias()
    cQuery := "SELECT "
    cQuery += 	" VD8.VD8_CODEMP "
    cQuery +=   " , VD8.VD8_CODFIL "
    cQuery +=   " , VD8.VD8_CODDEF "
    cQuery += "FROM "
    cQuery +=	RetSQLName("VD8") + " VD8 "
    cQuery += "WHERE "
    cQuery +=   " VD8.D_E_L_E_T_ = ' ' "
    cQuery +=   " AND VD8.VD8_FILIAL = '" + xFilial("VD8") + "' "
    cQuery +=   " AND VD8.VD8_CODDEF = '" + MV_PAR01 + "' "
    cQuery +=   " AND VD8.VD8_ATIVO = '1' "
    cQuery += "ORDER BY "
    cQuery += 	" 2, 3 "
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasB, .f., .t.)
    
    //Vamos realizar o levantamento das contas contabeis patrimonais da AGCO que dispensam centros de custos diversos
    cQuery := "SELECT "
    cQuery +=	" COUNT( LTRIM( RTRIM( VX5.VX5_CODIGO ) ) ) "
    cQuery += "FROM "
    cQuery +=	RetSQLName("VX5") + " VX5 "
    cQuery += "WHERE "
    cQuery +=   " D_E_L_E_T_ = ' ' "
    cQuery +=   " AND VX5_CHAVE = '080' "   // 080 = Plano Contabil DFS AGCO
    cQuery +=   " AND VX5.VX5_CODIGO BETWEEN '1000' AND '2999' "   // Contas Patrimoniais - Ativo e Passivo
    oTProcess:SetRegua2(FM_SQL(cQuery))
    
    cAliasC := GetNextAlias()
    cQuery := "SELECT "
    cQuery +=   " LTRIM( RTRIM( VX5.VX5_CODIGO ) ) PLANOAGCO "
    cQuery +=   " , LTRIM( RTRIM( VX5.VX5_DESCRI ) ) DESCRIPLANO "
    cQuery += "FROM "
    cQuery +=	RetSQLName("VX5") + " VX5 "
    cQuery += "WHERE "
    cQuery +=	" D_E_L_E_T_ = ' ' "
    cQuery +=   " AND VX5_CHAVE = '080' "   // 080 = Plano Contabil DFS AGCO
    cQuery +=   " AND VX5.VX5_CODIGO BETWEEN '1000' AND '2999' "   // Contas Patrimoniais - Ativo e Passivo
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasC, .f., .t.)

    // Criacao dos itens do DEF Patrimoniais
	oTProcess:IncRegua1(STR0017)  // Criando DFS Patrimonial
    While !(cAliasC)->(EoF())
        oTProcess:IncRegua2(STR0017 + AllTrim( (cAliasC)->PLANOAGCO ) + "1401")  // Criando DFS Patrimonial
		// Departamento 1401 = Administrativo (fixo para patrimonial)
        
        DBSelectArea("VD9")
        RecLock("VD9",.t.)
            VD9->VD9_FILIAL  := xFilial("VD9")
            VD9->VD9_CODCON  := GetSXENum("VD9","VD9_CODCON")
            VD9->VD9_CODDEF  := MV_PAR01
            VD9->VD9_CONCTA  := AllTrim( (cAliasC)->PLANOAGCO ) + "1401"
            VD9->VD9_DESCRI  := AllTrim( (cAliasC)->PLANOAGCO ) + "1401 - " + AllTrim( (cAliasC)->DESCRIPLANO ) + " / Administrativo"
            VD9->VD9_CPODEF  := AllTrim( (cAliasC)->PLANOAGCO ) + "1401"
            VD9->VD9_TIPO    := "3" // 3=CCTERP
            VD9->VD9_ATIVO   := "1" // 1=Sim
        MsUnlock()
        ConfirmSX8()
        
        (cAliasB)->(DbGoTop())
        DbSelectArea("VDA")
        While !(cAliasB)->(EoF())
            RecLock("VDA",.t.)
                VDA->VDA_FILIAL  := xFilial("VDA")
                VDA->VDA_CODEMP  := (cAliasB)->VD8_CODEMP
                VDA->VDA_CODFIL  := (cAliasB)->VD8_CODFIL
                VDA->VDA_CODDEF  := (cAliasB)->VD8_CODDEF
                VDA->VDA_CODCON  := VD9->VD9_CODCON
                VDA->VDA_ATIVO   := "1"  // 1=Sim
            MsUnlock()
            (cAliasB)->(dbSkip())
        End
        
        nPos := AScan( aPlnCtbDePara, {|x|x[1] == AllTrim( (cAliasC)->PLANOAGCO ) } )
        If nPos > 0
            DbSelectArea("VDE")
            For nCntForD := 2 to Len(aPlnCtbDePara[nPos]) // Comeca com 2 pois a primeira posicao do vetor e a conta contabil da AGCO
                RecLock("VDE",.t.)
                    VDE->VDE_FILIAL  := xFilial("VDE")
                    VDE->VDE_CODDEF  := MV_PAR01
                    VDE->VDE_CODCON  := VD9->VD9_CODCON
                    VDE->VDE_CCTERP  := aPlnCtbDePara[nPos,nCntForD]
                    VDE->VDE_OPER    := "1"  // 1=Soma
                    VDE->VDE_TIPSAL  := "1"  // 1=Saldo Atual
                MsUnlock()
            Next
        EndIf
        (cAliasC)->(dbSkip())
    End
    (cAliasC)->(DbCloseArea())

    // Vamos realizar o cruzamento das contas contabeis de resultado da AGCO com os centros de custo AGCO para montarmos o cadastro
    cQuery := "SELECT "
    cQuery +=	" COUNT( LTRIM( RTRIM( VX5A.VX5_CODIGO ) ) + LTRIM( RTRIM( VX5B.VX5_CODIGO ) ) ) "
    cQuery += "FROM "
    cQuery +=	" ( "
    cQuery +=   	"SELECT "
    cQuery +=       	" VX5_FILIAL"
    cQuery +=       	" , VX5_CODIGO "
    cQuery +=   	"FROM "
    cQuery +=       	RetSQLName("VX5") + " VX5 "
    cQuery +=   	"WHERE "
    cQuery +=       	" D_E_L_E_T_ = ' ' "
    cQuery +=       	" AND VX5_CHAVE = '080' "   // 080 = Plano Contabil DFS AGCO
    cQuery +=       	" AND VX5_CODIGO >= '3000' "   // Contas de Resultado
    cQuery +=   " ) VX5A "
    cQuery += "JOIN "
    cQuery +=   " ( "
    cQuery +=		"SELECT "
    cQuery +=       	" VX5_FILIAL"
    cQuery +=       	" , VX5_CODIGO "
    cQuery +=   	"FROM "
    cQuery +=       	RetSQLName("VX5") + " VX5 "
    cQuery +=   	"WHERE "
    cQuery +=       	" D_E_L_E_T_ = ' ' "
    cQuery +=       	" AND VX5_CHAVE = '079' "   // 079 = Departamentos Referencial DFS AGCO
    cQuery +=   " ) VX5B "
    cQuery += " ON "
    cQuery += " VX5A.VX5_FILIAL = VX5B.VX5_FILIAL "
    oTProcess:SetRegua2(FM_SQL(cQuery))
    
    cAliasA := GetNextAlias()
    cQuery := "SELECT "
    cQuery +=   " LTRIM( RTRIM( VX5A.VX5_CODIGO ) ) PLANOAGCO "
    cQuery +=   " , LTRIM( RTRIM( VX5A.VX5_DESCRI ) ) DESCRIPLANO "
    cQuery +=   " , LTRIM( RTRIM( VX5B.VX5_CODIGO ) ) DEPTOAGCO "
    cQuery +=   " , LTRIM( RTRIM( VX5B.VX5_DESCRI ) ) DESCRIDEPTO "
    cQuery += "FROM "
    cQuery +=   " ( "
    cQuery +=   	"SELECT "
    cQuery +=       	" VX5_FILIAL"
    cQuery +=       	" , VX5_CODIGO "
    cQuery +=       	" , VX5_DESCRI "
    cQuery +=   	"FROM "
    cQuery +=       	RetSQLName("VX5") + " VX5 "
    cQuery +=   	"WHERE "
    cQuery +=       	" D_E_L_E_T_ = ' ' "
    cQuery +=       	" AND VX5_CHAVE = '080' "   // 080 = Plano Contabil DFS AGCO
    cQuery +=       	" AND VX5_CODIGO >= '3000' "   // Contas de Resultado
    cQuery +=   " ) VX5A "
    cQuery += "JOIN "
    cQuery +=   " ( "
    cQuery +=   	"SELECT "
    cQuery +=       	" VX5_FILIAL"
    cQuery +=       	" , VX5_CODIGO "
    cQuery +=       	" , VX5_DESCRI "
    cQuery +=   	"FROM "
    cQuery +=       	RetSQLName("VX5") + " VX5 "
    cQuery +=   	"WHERE "
    cQuery +=       	" D_E_L_E_T_ = ' ' "
    cQuery +=       	" AND VX5_CHAVE = '079' "   // 079 = Departamentos Referencial DFS AGCO
    cQuery +=   " ) VX5B "
    cQuery += " ON "
    cQuery += " VX5A.VX5_FILIAL = VX5B.VX5_FILIAL "
    cQuery += "ORDER BY "
    cQuery +=   " 1, 2 "
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasA, .f., .t.)
    
    // Criacao dos itens do DEF de Resultado
	oTProcess:IncRegua1(STR0018)	// Criando DFS de Resultado
    While !(cAliasA)->(EoF())
        oTProcess:IncRegua2(STR0018 + AllTrim( (cAliasA)->PLANOAGCO ) + AllTrim( (cAliasA)->DEPTOAGCO ) )	// Criando DFS de Resultado
        
        DBSelectArea("VD9")
        RecLock("VD9",.t.)
            VD9->VD9_FILIAL  := xFilial("VD9")
            VD9->VD9_CODCON  := GetSXENum("VD9","VD9_CODCON")
            VD9->VD9_CODDEF  := MV_PAR01
            VD9->VD9_CONCTA  := AllTrim( (cAliasA)->PLANOAGCO ) + AllTrim( (cAliasA)->DEPTOAGCO )
            VD9->VD9_DESCRI  := AllTrim( (cAliasA)->PLANOAGCO ) + AllTrim( (cAliasA)->DEPTOAGCO ) + " - " + AllTrim( (cAliasA)->DESCRIPLANO ) + " / " + AllTrim( (cAliasA)->DESCRIDEPTO )
            VD9->VD9_CPODEF  := AllTrim( (cAliasA)->PLANOAGCO ) + AllTrim( (cAliasA)->DEPTOAGCO )
            VD9->VD9_TIPO    := "3" // 3=CCTERP
            VD9->VD9_ATIVO   := "1" // 1=Sim
        MsUnlock()
        ConfirmSX8()
        
        (cAliasB)->(DbGoTop())
        DbSelectArea("VDA")
        While !(cAliasB)->(EoF())
            RecLock("VDA",.t.)
                VDA->VDA_FILIAL  := xFilial("VDA")
                VDA->VDA_CODEMP  := (cAliasB)->VD8_CODEMP
                VDA->VDA_CODFIL  := (cAliasB)->VD8_CODFIL
                VDA->VDA_CODDEF  := (cAliasB)->VD8_CODDEF
                VDA->VDA_CODCON  := VD9->VD9_CODCON
                VDA->VDA_ATIVO   := "1"  // 1=Sim
            MsUnlock()
            (cAliasB)->(dbSkip())
        End
        
        nPos := AScan( aPlnCtbDePara, {|x|x[1] == AllTrim( (cAliasA)->PLANOAGCO ) } )
        If nPos > 0
            DbSelectArea("VDE")
            For nCntForD := 2 to Len(aPlnCtbDePara[nPos]) // Comeca com 2 pois a primeira posicao do vetor e a conta contabil da AGCO
                RecLock("VDE",.t.)
                    VDE->VDE_FILIAL  := xFilial("VDE")
                    VDE->VDE_CODDEF  := MV_PAR01
                    VDE->VDE_CODCON  := VD9->VD9_CODCON
                    VDE->VDE_CCTERP  := aPlnCtbDePara[nPos,nCntForD]
                    VDE->VDE_OPER    := "1"  // 1=Soma
                    VDE->VDE_TIPSAL  := "1"  // 1=Saldo Atual
                MsUnlock()
            Next
        EndIf
        
        If nPos > 0 // Existe conta contabil relacionada no De/Para
            For nCntForE := 1 to Len(aCenCusDePara)
                If AllTrim(aCenCusDePara[nCntForE,1]) == AllTrim( (cAliasA)->DEPTOAGCO ) // Considera apenas centros de custo da AGCO para fazer o De/Para
                    For nCntForF := 2 to Len(aCenCusDePara[nCntForE]) // Comeca com 2 pois a primeira posicao do vetor e o departamento da AGCO
                        RecLock("VD9",.f.)
                            Do Case
                                Case Len(AllTrim(VD9->VD9_CCUSTS)) <= 240
                                    VD9->VD9_CCUSTS := AllTrim(VD9->VD9_CCUSTS) + AllTrim(aCenCusDePara[nCntForE,nCntForF]) + ","
                                Case Len(AllTrim(VD9_CCUSTA)) <= 240
                                    VD9->VD9_CCUSTA := AllTrim(VD9->VD9_CCUSTA) + AllTrim(aCenCusDePara[nCntForE,nCntForF]) + ","
                                Case Len(AllTrim(VD9_CCUSTB)) <= 240
                                    VD9->VD9_CCUSTB := AllTrim(VD9->VD9_CCUSTB) + AllTrim(aCenCusDePara[nCntForE,nCntForF]) + ","
                                Case Len(AllTrim(VD9_CCUSTC)) <= 240
                                    VD9->VD9_CCUSTC := AllTrim(VD9->VD9_CCUSTC) + AllTrim(aCenCusDePara[nCntForE,nCntForF]) + ","
                                Otherwise
                                    Help(NIL, NIL, STR0019, NIL, STR0020 + VD9->VD9_CPODEF + ".",/* Tamanho do campo insuficiente | Não há quantidade de caracteres suficientes para importar todos os centros de custo do Campo DEF */;
                                    1, 0, NIL, NIL, NIL, NIL, NIL, {STR0021})	// Entre em contato com o Administrador do Protheus.
                            EndCase
                        MsUnlock()
                    Next
                EndIf
            Next
			// Se nao existe o De/Para de um Departamento da AGCO para o Centro de Custo do Concessionario, vamos gravar zerado para evitar valores duplicados
			If Empty(VD9->VD9_CCUSTS)
				RecLock("VD9",.f.)
                	VD9->VD9_TIPO := "6" // 6=Zerado
            	MsUnlock()
			EndIf
        Else
            RecLock("VD9",.f.)
                VD9->VD9_TIPO := "6" // 6=Zerado
            MsUnlock()
        EndIf

        (cAliasA)->(dbSkip())
    End
    (cAliasA)->(DbCloseArea())
    (cAliasB)->(DbCloseArea())

	oTProcess:IncRegua1(STR0033)	// Importacao Finalizada!

    // Fim da Transacao
    //
    End Transaction
    //

    ConOut(Chr(13) + Chr(10))
    ConOut("--------------------------------------------------------------")
    ConOut(" #######  ######## ####    ###     #######    #####   ########")
    ConOut("##     ## ##        ##    ## ##   ##     ##  ##   ##  ##      ")
    ConOut("##     ## ##        ##   ##   ##         ## ##     ## ##      ")
    ConOut("##     ## ######    ##  ##     ##  #######  ##     ## ####### ")
    ConOut("##     ## ##        ##  ######### ##        ##     ##       ##")
    ConOut("##     ## ##        ##  ##     ## ##         ##   ##  ##    ##")
    ConOut(" #######  ##       #### ##     ## #########   #####    ###### ")
    ConOut("--------------------------------------------------------------")
    ConOut(Chr(13) + Chr(10))
    ConOut(STR0022 + cAuxData +" - "+Time())	// FIM DO PROCESSAMENTO:

	MsgInfo(STR0029,STR0030)	// Importacao e Cadastro do DEF finalizados com sucesso! | Sucesso

Return

/*/
{Protheus.doc} OA2050027_CriaCabecalhoDEF
Realiza a criacao do cabecalho do DEF.
@type   Static Function
@author Otavio Favarelli
@since  06/12/2019
@param  cCodDEF ,Caractere  ,Código do DEF a ser criado.
@return nil
/*/
Static Function OA2050027_CriaCabecalhoDEF(cCodDEF)

    Local nCntForA

    DbSelectArea("VD7")
    RecLock("VD7",.t.)
        VD7->VD7_FILIAL  := xFilial("VD7")
        VD7->VD7_CODDEF  := cCodDEF
        VD7->VD7_DESDEF  := "DEF Importacao AGCO"
        VD7->VD7_FREQUE  := "1"          // 1=Mensal
        VD7->VD7_ATIVO   := "1"          // 1=Sim
    MsUnlock()

    DbSelectArea("VD8")
    For nCntForA := 1 to Len(aFilComp)
        RecLock("VD8",.t.)
            VD8->VD8_FILIAL  := xFilial("VD8")
            VD8->VD8_ATIVO   := "1"  // 1=Sim
            VD8->VD8_CODEMP  := cGrEmpDEF	// Deve ser gravado o Grupo de Empresa
            VD8->VD8_CODFIL  := aFilComp[nCntForA]
            VD8->VD8_CODDEF  := cCodDEF
        MsUnlock()
    Next

Return

/*/
{Protheus.doc} OA2050037_LeituraCSVPlanoContas
Realiza a criacao da matriz com as contas contabeis do concessionario por conta contabil da AGCO.
@type   Static Function
@author Otavio Favarelli
@since  08/12/2019
@param  cArqPlanoCtb    ,Caractere ,Arquivo .csv que contem o De/Para do Plano de Contas.
@return lRet            ,Booleano  ,Indica se foi possivel realizar a leitura do arquivo csv informado.
/*/
Static Function OA2050037_LeituraCSVPlanoContas(cArqPlanoCtb)

    Local oCSVFile
    //
    Local lRet
    //
    Local cLine
    Local cCodeDFSPlan
    Local cPlanoCtbConcess
    //
    Local nPos

    oCSVFile := FWFileReader():New(cArqPlanoCtb)

    If oCSVFile:Open()
        lRet := .t.
        
        // Variavel Private
        aPlnCtbDePara := {}

        While oCSVFile:hasLine()
            cLine := DecodeUTF8(oCSVFile:getLine())
            If !Empty(cLine)
                cCodeDFSPlan        := Substr( cLine,1                  ,At(",",cLine)-1 )
                cPlanoCtbConcess    := Substr( cLine,At(",",cLine)+1    ,Len(cLine)      )

           //     FAZER CHECAGEM DE LINHAS DUPLICADAS, LISTAR AS LINHAS DUPLICADAS PARA O USUARIO AVERIGUAR E ABORTAR

                nPos := AScan(aPlnCtbDePara,{|x|x[1] == cCodeDFSPlan})
                
                // Se nao existir este plano de contas AGCO na matriz, inclui uma nova posicao na matriz e adiciona a conta contabil da concessionaria
                If nPos == 0
                    AAdd(aPlnCtbDePara,{cCodeDFSPlan})
                    AAdd(aPlnCtbDePara[Len(aPlnCtbDePara)],cPlanoCtbConcess)
                Else
                    AAdd(aPlnCtbDePara[nPos],cPlanoCtbConcess)
                EndIf
            EndIf 
        End
        oCSVFile:Close()
    Else
        Help(NIL, NIL, STR0023, NIL, STR0024, /* Importação não realizada | O arquivo .csv informado para o pergunte De/Para Plano Contábil não foi encontrado ou nao pôde ser aberto. Impossível continuar! */;
        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0025}) // Verifique se o diretório e o nome do arquivo estão corretos, se o arquivo esta presente no diretório informado e se o arquivo pode ser aberto.
        lRet := .f.
    EndIf

Return lRet

/*/
{Protheus.doc} OA2050047_LeituraCSVCentroCusto
Realiza a criacao da matriz com os centros de custo do concessionario por departamento da AGCO.
@type   Static Function
@author Otavio Favarelli
@since  08/12/2019
@param  cArqCentroCusto ,Caractere ,Arquivo .csv que contem o De/Para do Centro de Custos.
@return lRet            ,Booleano  ,Indica se foi possivel realizar a leitura do arquivo csv informado.
/*/
Static Function OA2050047_LeituraCSVCentroCusto(cArqCentroCusto)

    Local oCSVFile
    //
    Local lRet
    //
    Local cLine
    Local cSectionCode
    Local cCentroCusto
    //
    Local nPos

    oCSVFile := FWFileReader():New(cArqCentroCusto)

    If oCSVFile:Open()
        lRet := .t.
        
        // Variavel Private
        aCenCusDePara := {}

        While oCSVFile:hasLine()
            cLine := DecodeUTF8(oCSVFile:getLine())
            If !Empty(cLine)
                cSectionCode := Substr( cLine,1                  ,At(",",cLine)-1 )
                cCentroCusto := Substr( cLine,At(",",cLine)+1    ,Len(cLine)      )

           //     FAZER CHECAGEM DE LINHAS DUPLICADAS, LISTAR AS LINHAS DUPLICADAS PARA O USUARIO AVERIGUAR E ABORTAR

                nPos := AScan(aCenCusDePara,{|x|x[1] == cSectionCode})
                
                // Se nao existir este departamento AGCO na matriz, inclui uma nova posicao na matriz e adiciona o centro de custo da concessionaria
                If nPos == 0
                    AAdd(aCenCusDePara,{cSectionCode})
                    AAdd(aCenCusDePara[Len(aCenCusDePara)],cCentroCusto)
                Else
                    AAdd(aCenCusDePara[nPos],cCentroCusto)
                EndIf
            EndIf
        End
        oCSVFile:Close()
    Else
        Help(NIL, NIL, STR0023, NIL, STR0026,/* Importação não realizada | O arquivo .csv informado para o pergunte De/Para Centro de Custo não foi encontrado ou nao pôde ser aberto. Impossível continuar! */;
        1, 0, NIL, NIL, NIL, NIL, NIL, {STR0025})	// Verifique se o diretório e o nome do arquivo estão corretos, se o arquivo esta presente no diretório informado e se o arquivo pode ser aberto.
        lRet := .f.
    EndIf


Return lRet

/*/
{Protheus.doc} OA2050057_DeletaDEF
Realiza a delecao do cabecalho e itens do DEF.
@type   Static Function
@author Otavio Favarelli
@since  17/09/2021
@param  cCodDEF ,Caractere  ,Código do DEF a ser deletado.
@return nil
/*/
Static Function OA2050057_DeletaDEF(cCodDEF)

    Local cQuery
    Local cAliasD
    Local cAliasE
    Local cAliasF

	cAliasD := GetNextAlias()
	cQuery := "SELECT "
    cQuery +=   " VD9.VD9_FILIAL "
    cQuery +=   " , VD9.VD9_CODCON "
    cQuery +=   " , VD9.R_E_C_N_O_ "
    cQuery += "FROM "
    cQuery +=	RetSQLName("VD9") + " VD9 "
    cQuery += "WHERE "
    cQuery +=   " VD9.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND VD9.VD9_FILIAL = '" + xFilial("VD9") + "' "
    cQuery +=   " AND VD9.VD9_CODDEF = '" + MV_PAR01 + "' "
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasD, .f., .t.)

	// Delecao dos itens do DEF e tabelas adjacentes
    While !(cAliasD)->(EoF())
		
		// Tabela VDA - Filiais do Item do DEF
		cAliasE := GetNextAlias()
		cQuery := "SELECT "
    	cQuery +=   " VDA.R_E_C_N_O_ "
    	cQuery += "FROM "
    	cQuery +=	RetSQLName("VDA") + " VDA "
    	cQuery += "WHERE "
    	cQuery +=   " VDA.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND VDA.VDA_FILIAL = '" + (cAliasD)->VD9_FILIAL + "' "
    	cQuery +=   " AND VDA.VDA_CODCON = '" + (cAliasD)->VD9_CODCON + "' "
    	DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasE, .f., .t.)

		While !(cAliasE)->(EoF())
			VDA->( DbGoTo( (cAliasE)->R_E_C_N_O_ ) )
			RecLock("VDA",.f.,.t.)
			DbDelete()
			MsUnLock()
			
			(cAliasE)->(dbSkip())
		End

		(cAliasE)->(DbCloseArea())

		// Tabela VDE - Contas Contabeis do Item do DEF
		cAliasF := GetNextAlias()
		cQuery := "SELECT "
    	cQuery +=   " VDE.R_E_C_N_O_ "
    	cQuery += "FROM "
    	cQuery +=	RetSQLName("VDE") + " VDE "
    	cQuery += "WHERE "
    	cQuery +=   " VDE.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND VDE.VDE_FILIAL = '" + (cAliasD)->VD9_FILIAL + "' "
    	cQuery +=   " AND VDE.VDE_CODCON = '" + (cAliasD)->VD9_CODCON + "' "
    	DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasF, .f., .t.)

		While !(cAliasF)->(EoF())
			VDE->( DbGoTo( (cAliasF)->R_E_C_N_O_ ) )
			RecLock("VDE",.f.,.t.)
			DbDelete()
			MsUnLock()
			
			(cAliasF)->(dbSkip())
		End

		(cAliasF)->(DbCloseArea())

		VD9->( DbGoTo( (cAliasD)->R_E_C_N_O_ ) )
		RecLock("VD9",.f.,.t.)
		DbDelete()
		MsUnLock()

		(cAliasD)->(dbSkip())

    End

    (cAliasD)->(DbCloseArea())

Return
