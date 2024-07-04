#Include "Protheus.ch"

/*/{Protheus.doc} CADDEFAM
Cadastro do DEF Áster Máquinas
Função que realiza o cadastro do DEF para a Áster Máquinas com base nas informações
do DEF atual customizado da mesma.

@type User Function
@author Otávio Favarelli
@since 06/10/2019
@version 1.0

/*/

User Function CADDEFAM()

    STATIC cDescRot := "Esta rotina realiza o cadastro do DEF para a Áster Máquinas com base nas informações do DEF atual customizado da mesma."

    Local oTProcess
    Local bProcess := { |oSelf| CADDEFAMPROC(oSelf) }
    Local lPainelAux := .t.
    Local lViewExecute := .t.
    Local lOneMeter := .f.
    Local cPerg := "CADDEFAM"                       // Pergunte

    If ChkFile("ZMK")
        oTProcess := tNewProcess():New(;
        "CADDEFAM",;                                    // 01 - Nome da função que está chamando o objeto.
        "Cadastro DEF Áster Máquinas",;                 // 02 - Título da árvore de opções.
        bProcess,;                                      // 03 - Bloco de execução que será executado ao confirmar a tela.
        cDescRot,;                                      // 04 - Descrição da rotina.
        cPerg,;                                         // 05 - Nome do Pergunte (SX1) a ser utilizado na rotina.
        /* aInfoCustom */ ,;                            // 06 - Informações adicionais carregada na árvore de opções.
        lPainelAux,;                                    // 07 - Se .T. cria uma novo painel auxiliar ao executar a rotina.
        /* nSizePanelAux */ ,;                          // 08 - Tamanho do painel auxiliar, utilizado quando lPainelAux = .T.
        /* cDescriAux */ ,;                             // 09 - Descrição a ser exibida no painel auxiliar.
        lViewExecute,;                                  // 10 - Se .T. exibe o painel de execução. Se .f., apenas executa a função sem exibir a régua de processamento.
        lOneMeter;                                      // 11 - Se .T. cria apenas uma regua de processamento.
        )
    Else
        MsgInfo( "Tabela ZMK não encontrada. Impossível continuar!", "Atenção!" )
    EndIf

Return

/*/{Protheus.doc} CADDEFAMPROC
    (long_description)
    @type  Static Function
    @author Otávio Favarelli
    @since 06/10/2019
    @version version
    @param param_name, param_type, param_descr
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function CADDEFAMPROC( oTProcess)

    Local cQuery
    Local cAliasA       := GetNextAlias()
    Local cAliasB       := GetNextAlias()
    Local cAliasC       := GetNextAlias()
    Local cAliasD       := GetNextAlias()
    Local cAliasE       := GetNextAlias()
    Local cAliasF       := GetNextAlias()
    Local cAliasG       := GetNextAlias()
    Local cAliasH       := GetNextAlias()
    Local cAliasI       := GetNextAlias()
    Local cCustoVetVD9
    Local cCampo
    Local cAuxData := Dtoc(dDataBase)
    Local cCODCONSkip
    Local ni, nu, nv, nx, nw, ny, nz
    Local nTamCPODEF    := TamSX3("VD9_CPODEF")[1]
    Local aFilVD8
    Local aVD9
    Local aCCTVDE
    Local lGravou := .f.
    Local nCntFor1, nCntFor2, nCntFor3, nCntFor4
    Local aFilComp := {}

    DbSelectArea("VD7")

    If Empty(MV_PAR01)
        Help(NIL, NIL, "Pergunta Em Branco", NIL, "A Pergunta Código DEF está em branco. Impossível continuar.",;
            1, 0, NIL, NIL, NIL, NIL, NIL, {"Preencha a pergunta Código DEF para realizar o cadastro corretamente."})
        Return
    EndIf

    If !ExistChav("VD7", MV_PAR01)
        Help(NIL, NIL, "DEF Já Cadastrado", NIL, "O Cadastro do DEF " + MV_PAR01 + " já existe neste ambiente. Impossível continuar.",;
            1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe outro código DEF ou apague este código DEF do seu ambiente."}) 
        Return
    EndIf

    ConOut(Chr(13) + Chr(10))
    ConOut("----------------------------------------------------------------------------")
    ConOut(" ######     ###    ########  ########  ######## ########    ###    ##     ##")
    ConOut("##    ##   ## ##   ##     ## ##     ## ##       ##         ## ##   ###   ###")
    ConOut("##        ##   ##  ##     ## ##     ## ##       ##        ##   ##  #### ####")
    ConOut("##       ##     ## ##     ## ##     ## ######   ######   ##     ## ## ### ##")
    ConOut("##       ######### ##     ## ##     ## ##       ##       ######### ##     ##")
    ConOut("##    ## ##     ## ##     ## ##     ## ##       ##       ##     ## ##     ##")
    ConOut(" ######  ##     ## ########  ########  ######## ##       ##     ## ##     ##")
    ConOut("----------------------------------------------------------------------------")
    ConOut(Chr(13) + Chr(10))
    ConOut("INICIO DO PROCESSAMENTO:  "+ cAuxData +" - "+Time())

    // Início da Transação
        Begin Transaction
    //

    aEmp := FWAllCompany(SM0->M0_CODIGO)
    if Len(aEmp) == 0
    	aAdd(aEmp, "")
    endif
    for nCntFor2 := 1 to Len(aEmp)
    	aUni := FWAllUnitBusiness(aEmp[nCntFor2],SM0->M0_CODIGO)
    	if Len(aUni) == 0
    		aAdd(aUni, "")
    	endif
    	for nCntFor3 := 1 to Len(aUni)  
    		aFil := FWAllFilial(aEmp[nCntFor2],aUni[nCntFor3],SM0->M0_CODIGO)
    		for nCntFor4 := 1 to Len(aFil)
    			cNomeFil := FWFilialName(SM0->M0_CODIGO,aEmp[nCntFor2]+aUni[nCntFor3]+aFil[nCntFor4],2)    
    			if !Empty(cNomeFil)
    				if Ascan(aFilComp,{ |x| x[1] + x[2] + x[3] + x[4] == SM0->M0_CODIGO,aEmp[nCntFor2]+aUni[nCntFor3]+aFil[nCntFor4]}) == 0
    					aAdd(aFilComp,{SM0->M0_CODIGO,aEmp[nCntFor2],aUni[nCntFor3],aFil[nCntFor4],cNomeFil })
    				endif
    			endif
    		next
    	next
    next

    aFilVD8 := RetFilVD8()

    DbSelectArea("VD7")
    RecLock("VD7",.t.)
    VD7_FILIAL  := xFilial("VD7")
    VD7_CODDEF  := MV_PAR01
    VD7_DESDEF  := "DEF Importação"
    VD7_FREQUE  := "1"          // 1=Mensal
    VD7_ATIVO   := "1"          // 1=Sim
    VD7_CALCCT  := "2"          // 2=Estruturado
    VD7_CCESTR  := "A##AAAAAA"  
    VD7_CALICT  := "0"          // 0=Não 
    MsUnlock()

    DbSelectArea("VD8")

    For nz := 1 to Len(aFilComp)
        RecLock("VD8",.t.)
        VD8_FILIAL  := xFilial("VD8")
            If aFilComp[nz,4] == '00'
                VD8_ATIVO := "1"
            Else
                VD8_ATIVO := IIf( AScan(aFilVD8,aFilComp[nz,4]) == 0, "0", "1" )  // 1=Sim
            EndIf
        VD8_CODEMP  := aFilComp[nz,1]
        VD8_CODFIL  := aFilComp[nz,4]
        VD8_CODDEF  := VD7->VD7_CODDEF
        VD8_CC      := aFilComp[nz,4]
        MsUnlock()
    Next

    cQuery := "SELECT COUNT(DISTINCT ZMK_DFA) "
    cQuery += "FROM "
    cQuery +=   RetSQLName("ZMK") + " ZMK "
    cQuery += "WHERE "
    cQuery +=   "D_E_L_E_T_ = ' ' AND ZMK_VALIDA <> '20150430' AND ZMK_ATIVO = 'S' "
    //cQuery +=   "AND ZMK_DFA = '344' "
    //cQuery +=   "AND ZMK_DFA BETWEEN '101' AND '102' "
    oTProcess:SetRegua1(FM_SQL(cQuery))

    // A-Obter todos os ZMK_DFA disponiveis para cadastro.
    cQuery := "SELECT DISTINCT "
    cQuery +=   " ZMK_DFA "
    cQuery += "FROM "
    cQuery +=   RetSQLName("ZMK") + " ZMK "
    cQuery += "WHERE "
    cQuery +=   "D_E_L_E_T_ = ' ' AND ZMK_VALIDA <> '20150430' AND ZMK_ATIVO = 'S' "
    //cQuery +=   "AND ZMK_DFA = '344' "
    //cQuery +=   "AND ZMK_DFA BETWEEN '101' AND '102' "
    cQuery += "ORDER BY ZMK_DFA"
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasA, .f., .t.)

    While !(cAliasA)->(EoF())
        // B-Levantar todas as ZMK_CONTA para cada ZMK_DFA.
        oTProcess:IncRegua1("Criando DEF para o DFA " + (cAliasA)->ZMK_DFA)

        cQuery := "SELECT COUNT(DISTINCT ZMK_CONTA) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("ZMK") + " ZMK "
        cQuery += "WHERE "
        cQuery +=   "D_E_L_E_T_ = ' ' AND ZMK_VALIDA <> '20150430' AND ZMK_ATIVO = 'S' "
        cQuery +=   "AND ZMK_DFA = '" + (cAliasA)->ZMK_DFA + "' "
        oTProcess:SetRegua2(FM_SQL(cQuery))    

        cQuery := "SELECT DISTINCT "
        cQuery +=   " ZMK_CONTA "
        cQuery += "FROM "
        cQuery +=   RetSQLName("ZMK") + " ZMK "
        cQuery += "WHERE "
        cQuery +=   "D_E_L_E_T_ = ' ' AND ZMK_VALIDA <> '20150430' AND ZMK_ATIVO = 'S' "
        cQuery +=   "AND ZMK_DFA = '" + (cAliasA)->ZMK_DFA + "' "
        cQuery += "ORDER BY ZMK_CONTA"
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasB, .f., .t.)
        oTProcess:IncRegua2("Criando Itens do DEF a Conta Contábil " + (cAliasB)->ZMK_CONTA)

        While !(cAliasB)->(EoF())
            //C-Levantar todos os ZMK_CCUSTO para cada ZMK_CONTA levantada.
            cQuery := "SELECT DISTINCT "
            cQuery +=   " ZMK_CCUSTO "
            cQuery += "FROM "
            cQuery +=   RetSQLName("ZMK") + " ZMK "
            cQuery += "WHERE "
            cQuery +=   " D_E_L_E_T_ = ' ' "
            cQuery +=   " AND ZMK_VALIDA <> '20150430' AND ZMK_ATIVO = 'S' "
            cQuery +=   " AND ZMK_DFA = '" + (cAliasA)->ZMK_DFA + "' "
            cQuery +=   " AND ZMK_CONTA = '" + (cAliasB)->ZMK_CONTA + "' "
            cQuery += "ORDER BY ZMK_CCUSTO "
            DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasC, .f., .t.)
            aVD9 := {}

            While !(cAliasC)->(EoF())
                lProcCC := .t.
                If !Empty((cAliasC)->ZMK_CCUSTO)
                    lProcCC := RetProcCC((cAliasC)->ZMK_CCUSTO)
                EndIf

                If lProcCC
                    cContaTemp  := AllTrim((cAliasB)->ZMK_CONTA)
                    cDFATemp    := AllTrim((cAliasA)->ZMK_DFA)
                    cFilTemp    := IIf(Substr((cAliasC)->ZMK_CCUSTO,2,2) == '00', '99', Substr((cAliasC)->ZMK_CCUSTO,2,2)) // Tratar filial: de 00 (Áster) para 99 (DFA)
                    cDeptoTemp  := RetDptDFA(Substr((cAliasC)->ZMK_CCUSTO,4,2))

                    nPos := AScan(aVD9,{|x|x[3] == cFilTemp .and. x[4] == cDeptoTemp}) // Separa os centros de custo desta conta contábil por filial e departamento 
                    If nPos == 0
                        AAdd(aVD9, {cContaTemp,;                // 01
                                    cDFATemp,;                  // 02
                                    cFilTemp,;                  // 03
                                    cDeptoTemp,;                // 04
                                    {(cAliasC)->ZMK_CCUSTO}})   // 05
                    Else
                        AAdd(aVD9[nPos,5], (cAliasC)->ZMK_CCUSTO )
                    EndIf
                EndIf

                (cAliasC)->(dbSkip())
            End
            (cAliasC)->(DbCloseArea())

            // Aqui já temos levantados todos os centros de custo para aquela conta contábil
            For ni := 1 to Len(aVD9)
                DbSelectArea("VD9")
                DbSetOrder(2)       // VD9_FILIAL+VD9_CODDEF+VD9_CPODEF
                If DbSeek(xFilial("VD9") + VD7->VD7_CODDEF + aVD9[ni,2]+aVD9[ni,4] + Space(nTamCPODEF-(Len(aVD9[ni,2]+aVD9[ni,4])))) // Já existe pelo menos um deste DFA + Departamento
                    cQuery := "SELECT "
                    cQuery +=   "VD9_CODCON "
                    cQuery += "FROM "
                    cQuery +=   RetSQLName("VD9") + " VD9 "
                    cQuery += "JOIN "
                    cQuery +=   RetSQLName("VDE") + " VDE ON "
                    cQuery +=   "VD9_CODCON = VDE_CODCON "
                    cQuery += "WHERE "
                    cQuery +=   "VD9.D_E_L_E_T_ = ' ' AND VD9.D_E_L_E_T_ = ' ' "
                    cQuery +=   " AND VD9_CODDEF = '" + VD7->VD7_CODDEF + "' " 
                    cQuery +=   " AND VD9_CPODEF = '" + aVD9[ni,2] + aVD9[ni,4] + "' "
                    cQuery +=   " AND VDE_CCTERP = '" + aVD9[ni,1] + "' "
                    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasD, .f., .t.)

                //    If !Empty((cAliasD)->VD9_CODCON) // Há VD9 para esta conta contábil?
                        cCustoVetVD9 := ""
                        cQuery := "SELECT "
                        cQuery +=   "VD9_CODCON, LTRIM(RTRIM((VD9_CCUSTS + VD9_CCUSTA + VD9_CCUSTB + VD9_CCUSTC))) AS CUSTOVD9 "
                        cQuery += "FROM "
                        cQuery +=   RetSQLName("VD9") + " VD9 "
                        cQuery += "WHERE "
                        cQuery +=   "D_E_L_E_T_ = ' ' AND VD9_CODDEF = '" + VD7->VD7_CODDEF + "' "
                        cQuery +=   " AND VD9_CPODEF = '" + aVD9[ni,2] + aVD9[ni,4] + "' "
                        If !Empty((cAliasD)->VD9_CODCON)
                            cQuery +=   " AND VD9_CODCON = '" + (cAliasD)->VD9_CODCON + "' "
                        EndIf
                        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasE, .f., .t.)

                        For nw := 1 to Len(aVD9[ni,5])
                            If !Empty(aVD9[ni,5,nw])
                                cCustoVetVD9 += AllTrim(cCustoVetVD9) + AllTrim(aVD9[ni,5,nw]) + ","
                            EndIf
                        Next

                        If AllTrim((cAliasE)->CUSTOVD9) == "2##" .and. Empty(cCustoVetVD9) // Todos os centros de custo
                            //Utiliza o mesmo VD9, acrescentando a conta contábil na VDE
                            RecLock("VDE",.t.)
                            VDE_FILIAL  := xFilial("VDE")
                            VDE_CODDEF  := VD7->VD7_CODDEF
                            VDE_CODCON  := (cAliasE)->VD9_CODCON
                            VDE_CCTERP  := (cAliasB)->ZMK_CONTA
                            VDE_OPER    := "1"  // 1=Soma
                            VDE_TIPSAL  := "1"  // 1=Saldo Atual
                            MsUnlock()
                            lGravou := .t.
                        EndIf
                        If !lGravou
                            If cCustoVetVD9 == AllTrim((cAliasE)->CUSTOVD9) // São os mesmos centros de custo?
                                //Utiliza o mesmo VD9, acrescentando a conta contábil na VDE
                                RecLock("VDE",.t.)
                                VDE_FILIAL  := xFilial("VDE")
                                VDE_CODDEF  := VD7->VD7_CODDEF
                                VDE_CODCON  := (cAliasE)->VD9_CODCON
                                VDE_CCTERP  := (cAliasB)->ZMK_CONTA
                                VDE_OPER    := "1"  // 1=Soma
                                VDE_TIPSAL  := "1"  // 1=Saldo Atual
                                MsUnlock()
                                lGravou := .t.                        
                            EndIf                    
                        EndIf
                        If !lGravou
                            DbSelectArea("VDE")
                            DbSetOrder(1)
                            If DbSeek(xFilial("VDE")+VD7->VD7_CODDEF+(cAliasD)->VD9_CODCON+(cAliasB)->ZMK_CONTA) // Se trata da mesma conta contábil
                                DbSelectArea("VD9")
                                DbSetOrder(1)       // VD9_FILIAL+VD9_CODDEF+VD9_CODCON
                                DbSeek(xFilial("VD9") + VD7->VD7_CODDEF + (cAliasD)->VD9_CODCON)
                                RecLock("VD9",.f.)
                                For nw := 1 to Len(aVD9[ni,5])
                                    Do Case
                                        Case Len(AllTrim(VD9_CCUSTS)) <= 240
                                            VD9_CCUSTS := AllTrim(VD9_CCUSTS) + AllTrim(aVD9[ni,5,nw]) + ","
                                            lGravou := .t.
                                        Case Len(AllTrim(VD9_CCUSTA)) <= 240
                                            VD9_CCUSTA := AllTrim(VD9_CCUSTA) + AllTrim(aVD9[ni,5,nw]) + ","
                                            lGravou := .t.
                                        Case Len(AllTrim(VD9_CCUSTB)) <= 240
                                            VD9_CCUSTB := AllTrim(VD9_CCUSTB) + AllTrim(aVD9[ni,5,nw]) + ","
                                            lGravou := .t.
                                        Case Len(AllTrim(VD9_CCUSTC)) <= 240
                                            VD9_CCUSTC := AllTrim(VD9_CCUSTC) + AllTrim(aVD9[ni,5,nw]) + ","
                                            lGravou := .t.
                                        Otherwise
                                            Conout("NÃO COUBE O CENTRO DE CUSTO NA VD9!!!")
                                    EndCase
                                Next
                                MsUnlock()
                            EndIf                    
                        EndIf
                        (cAliasE)->(DbCloseArea())
                  //  EndIf 
                    (cAliasD)->(DbCloseArea())
                EndIf
                If !lGravou // Não são os mesmos centros de custo, não encontrou DFA + Departamento na VD9, não é a mesma conta contábil e não tem VD9 para esta conta
                    RecLock("VD9",.t.)
                    VD9_FILIAL  := xFilial("VD9")
                    VD9_CODCON  := GetSXENum("VD9","VD9_CODCON")
                    VD9_CODDEF  := VD7->VD7_CODDEF
                    VD9_CONCTA  := aVD9[ni,2] + aVD9[ni,4]
                    VD9_DESCRI  := "Cadastro do DFA " + aVD9[ni,2] + aVD9[ni,4]
                    VD9_CPODEF  := aVD9[ni,2] + aVD9[ni,4]
                    VD9_TIPO    := "3" // 3=CCTERP
                    VD9_ATIVO   := "1" // 1=Sim
                
                    If Len(aVD9[ni,5]) >= 28
                        cCampo := ""
                        For nx := 1 to Len(aVD9[ni,5])
                            Do Case
                                Case Len(cCampo) >= 243
                                    VD9_CCUSTA := AllTrim(VD9_CCUSTA) + AllTrim(aVD9[ni,5,nx]) + ","
                                Case Len(cCampo) >= 486
                                    VD9_CCUSTB := AllTrim(VD9_CCUSTB) + AllTrim(aVD9[ni,5,nx]) + ","
                                Case Len(cCampo) >= 729
                                    VD9_CCUSTC := AllTrim(VD9_CCUSTC) + AllTrim(aVD9[ni,5,nx]) + ","
                                Otherwise
                                    VD9_CCUSTS := AllTrim(VD9_CCUSTS) + AllTrim(aVD9[ni,5,nx]) + ","
                            EndCase
                            cCampo += aVD9[ni,5,nx] + ","
                        Next
                    Else
                        For nx := 1 to Len(aVD9[ni,5])
                            If Empty(aVD9[ni,5,nx])
                                VD9_CCUSTS := "2##" // Considera todos os centros de custo para todas as filiais
                            Else
                                VD9_CCUSTS := AllTrim(VD9_CCUSTS) + AllTrim(aVD9[ni,5,nx]) + ","
                            EndIf
                        Next
                    EndIf
                    MsUnlock()
                    ConfirmSX8()
                            
                    DBSelectArea("VDA")
                            
                    DBSelectArea("VD8")
    		        DBSetOrder(1)
    		        VD8->(DBGoTop())
    		        While VD8->(!eof()) .and. xFilial("VD8")+VD7->VD7_CODDEF == VD8->VD8_FILIAL + VD8->VD8_CODDEF
                        If VD8->VD8_ATIVO == "1"
                            RecLock("VDA",.t.)
                            VDA_FILIAL  := xFilial("VDA")
                            VDA_CODEMP  := VD8->VD8_CODEMP
                            VDA_CODFIL  := VD8->VD8_CODFIL
                            VDA_CODDEF  := VD7->VD7_CODDEF
                            VDA_CODCON  := VD9->VD9_CODCON
                            VDA_ATIVO   := "1"  // 1=Sim
                            MsUnlock()
    		        	Endif
                    VD8->(dbSkip())
    		        End

                    DbSelectArea("VDE")
                    RecLock("VDE",.t.)
                    VDE_FILIAL  := xFilial("VDE")
                    VDE_CODDEF  := VD7->VD7_CODDEF
                    VDE_CODCON  := VD9->VD9_CODCON
                    VDE_CCTERP  := (cAliasB)->ZMK_CONTA
                    VDE_OPER    := "1"  // 1=Soma
                    VDE_TIPSAL  := "1"  // 1=Saldo Atual
                    MsUnlock()
                EndIf
                lGravou := .f.
            Next

            (cAliasB)->(dbSkip())
        End
        (cAliasB)->(DbCloseArea())

        (cAliasA)->(dbSkip())
    End
    (cAliasA)->(DbCloseArea())

    // Fim da Transação
    End Transaction
    //

    // Início da otimização do cadastro para agrupar DFAs com contas contábeis diferentes porém com o mesmos centros de custo

    // Início da Transação
    //
    Begin Transaction
    //

    //Aqui vamos contar a quantidade de registros que são iguais, sendo assim elegíveis para serem agrupados
    cQuery := "SELECT "
    cQuery +=   " VD9_CPODEF "
    cQuery +=   " ,COUNT(VD9_CODCON) AS QUANTIDADE "
    cQuery +=   " ,(VD9_CCUSTS+VD9_CCUSTA+VD9_CCUSTB+VD9_CCUSTC) AS CUSTOS "
    cQuery += "FROM "
    cQuery +=   RetSQLName("VD9") + " VD9 "
    cQuery += "WHERE "
    cQuery +=   "D_E_L_E_T_ = ' ' "
    cQuery += "GROUP BY "
    cQuery +=   "VD9_CCUSTS+VD9_CCUSTA+VD9_CCUSTB+VD9_CCUSTC "
    cQuery +=   ", VD9_CPODEF "
    cQuery += "HAVING "
    cQuery +=   " COUNT(VD9_CODCON) > 1 "
    cQuery += "ORDER BY VD9_CPODEF, QUANTIDADE DESC "
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasF, .f., .t.)

    oTProcess:SetRegua1((cAliasF)->QUANTIDADE)
    oTProcess:SetRegua2(0)

    // Vamos percorrer um a um e realizar o agrupamento
    While !(cAliasF)->(EoF())
        oTProcess:IncRegua1("Otimizando o Cadastro do DEF para o DFA " + (cAliasF)->VD9_CPODEF)
        aCCTVDE := {}
        cQuery := "SELECT "
        cQuery +=   " COUNT(VD9_CODCON) "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VD9") + " VD9 "
        cQuery += "WHERE "
        cQuery +=   "D_E_L_E_T_ = ' ' "
        cQuery +=   " AND VD9_CPODEF = '" + (cAliasF)->VD9_CPODEF + "' "

        If FM_SQL(cQuery) != (cAliasF)->QUANTIDADE // Um ou mais VD9_CPODEF iguais possuem centro de custos diferentes e não podem ser agrupados. Vamos precisar separa-los!
        
            cCODCONSkip := ""
            cQuery := "SELECT "
            cQuery +=   " (VD9_CCUSTS+VD9_CCUSTA+VD9_CCUSTB+VD9_CCUSTC) AS CUSTOS "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VD9") + " VD9 "
            cQuery += "WHERE "
            cQuery +=   "D_E_L_E_T_ = ' ' "
            cQuery +=   " AND VD9_CPODEF = '" + (cAliasF)->VD9_CPODEF + "' "
            cQuery += "GROUP BY "
            cQuery +=   " VD9_CCUSTS+VD9_CCUSTA+VD9_CCUSTB+VD9_CCUSTC "
            cQuery += "HAVING "
            cQuery +=   " COUNT(VD9_CODCON) = 1 "
            DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasI, .f., .t.)

            If !Empty((cAliasI)->CUSTOS) // Os registros avulso precisam ser desconsiderados

                While !(cAliasI)->(EoF())
                    cQuery := "SELECT "
                    cQuery +=   " VD9_CODCON "
                    cQuery += "FROM "
                    cQuery +=   RetSQLName("VD9") + " VD9 "
                    cQuery += "WHERE "
                    cQuery +=   "D_E_L_E_T_ = ' ' "
                    cQuery +=   " AND VD9_CPODEF = '" + (cAliasF)->VD9_CPODEF + "' "
                    cQuery +=   " AND VD9_CCUSTS+VD9_CCUSTA+VD9_CCUSTB+VD9_CCUSTC = '" + (cAliasI)->CUSTOS + "' "
                    If Empty(cCODCONSkip)
                        cCODCONSkip := "'" + FM_SQL(cQuery) + "'"
                    Else
                        cCODCONSkip += ",'" + FM_SQL(cQuery) + "'"
                    EndIf 

                    (cAliasI)->(dbSkip())
                End
            EndIf
            (cAliasI)->(DbCloseArea())
        EndIf    
        // Vamos separar todos os VD9_CODCON
        cQuery := "SELECT "
        cQuery +=   " VD9_CODCON "
        cQuery += "FROM "
        cQuery +=   RetSQLName("VD9") + " VD9 "
        cQuery += "WHERE "
        cQuery +=   "D_E_L_E_T_ = ' ' "
        cQuery +=   " AND VD9_CPODEF = '" + (cAliasF)->VD9_CPODEF + "' "
        cQuery +=   " AND VD9_CCUSTS+VD9_CCUSTA+VD9_CCUSTB+VD9_CCUSTC = '" + (cAliasF)->CUSTOS + "' "
        If !Empty(cCODCONSkip)
            cQuery +=   " AND VD9_CODCON NOT IN (" + cCODCONSkip + ") "
        EndIf
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasG, .f., .t.)

        While !(cAliasG)->(EoF())
            // Vamos separar todos os VDE_CCTERP deste VD9_CODCON
            cQuery := "SELECT "
            cQuery +=   " VDE_CCTERP "
            cQuery += "FROM "
            cQuery +=   RetSQLName("VDE") + " VDE "
            cQuery += "JOIN "
            cQuery +=   RetSQLName("VD9") + " VD9 "
            cQuery += "ON "
            cQuery +=   " VDE_CODCON = VD9_CODCON "
            cQuery += "WHERE "
            cQuery +=   "VD9.D_E_L_E_T_ = ' ' AND VDE.D_E_L_E_T_ = ' ' "
            cQuery +=   " AND VDE_CODCON = '" + (cAliasG)->VD9_CODCON + "' "
            DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasH, .f., .t.)

            While !(cAliasH)->(EoF())
                nPos := AScan(aCCTVDE,{|x|x[1] == (cAliasG)->VD9_CODCON}) 
                If nPos == 0
                    AAdd(aCCTVDE, { (cAliasG)->VD9_CODCON,;
                                    {(cAliasH)->VDE_CCTERP}})
                Else
                    AAdd(aCCTVDE[nPos,2], (cAliasH)->VDE_CCTERP )
                EndIf

                (cAliasH)->(dbSkip())
            End
            (cAliasH)->(DbCloseArea())

            (cAliasG)->(dbSkip())
        End

        (cAliasG)->(DbCloseArea())    

        cCODCONUnico := aCCTVDE[1,1]

        For ny := 2 to Len(aCCTVDE) // Adiciona todas as contas contábeis em um único VD9_CODCON
            For nv := 1 to Len(aCCTVDE[ny,2])
                RecLock("VDE",.t.)
                VDE_FILIAL  := xFilial("VDE")
                VDE_CODDEF  := VD7->VD7_CODDEF
                VDE_CODCON  := cCODCONUnico
                VDE_CCTERP  := aCCTVDE[ny,2,nv]
                VDE_OPER    := "1"  // 1=Soma
                VDE_TIPSAL  := "1"  // 1=Saldo Atual
                MsUnlock()
            Next        
        Next

        // Vamos excluir / deletar os registros a mais
        For nu := 2 to Len(aCCTVDE)
            DbSelectArea("VD9")
            DbSetOrder(1)       // VD9_FILIAL+VD9_CODDEF+VD9_CODCON
            DbSeek(xFilial("VD9") + VD7->VD7_CODDEF + aCCTVDE[nu,1])
            
            DbSelectArea("VDE")
            DbSetOrder(1)       // VDE_FILIAL+VDE_CODDEF+VDE_CODCON+VDE_CCTERP+VDE_CCUSTO
            DbSeek(xFilial("VDE") + VD7->VD7_CODDEF + aCCTVDE[nu,1])
            While VDE->VDE_CODCON == aCCTVDE[nu,1]
                RecLock("VDE",.f.)
                DbDelete()
                MsUnlock()
                VDE->(dbSkip())
            End

            DbSelectArea("VDA")
            DbSetOrder(1)       // VDA_FILIAL+VDA_CODDEF+VDA_CODCON+VDA_CODEMP+VDA_CODFIL
            DbSeek(xFilial("VDA") + VD7->VD7_CODDEF + aCCTVDE[nu,1])
            While VDA->VDA_CODCON == aCCTVDE[nu,1]
                RecLock("VDA",.f.)
                DbDelete()
                MsUnlock()
                VDA->(dbSkip())
            End
            
            RecLock("VD9",.f.)
            DbDelete()
            MsUnlock()
        Next
        (cAliasF)->(dbSkip())

    End

    (cAliasF)->(DbCloseArea())

    // Fim da Transação
    //
    End Transaction
    //

    ConOut(Chr(13) + Chr(10))
    ConOut("----------------------------------------------------------------------------")
    ConOut(" ######     ###    ########  ########  ######## ########    ###    ##     ##")
    ConOut("##    ##   ## ##   ##     ## ##     ## ##       ##         ## ##   ###   ###")
    ConOut("##        ##   ##  ##     ## ##     ## ##       ##        ##   ##  #### ####")
    ConOut("##       ##     ## ##     ## ##     ## ######   ######   ##     ## ## ### ##")
    ConOut("##       ######### ##     ## ##     ## ##       ##       ######### ##     ##")
    ConOut("##    ## ##     ## ##     ## ##     ## ##       ##       ##     ## ##     ##")
    ConOut(" ######  ##     ## ########  ########  ######## ##       ##     ## ##     ##")
    ConOut("----------------------------------------------------------------------------")
    ConOut(Chr(13) + Chr(10))

    ConOut("FIM DO PROCESSAMENTO:  "+ cAuxData +" - "+Time())

Return

Static Function RetDptDFA(cCustoAster)

    Local cQuery
    Local cAliasDpt := GetNextAlias()
    Local cDeptoDFA := ""

    Default cCustoAster := ""

    If !Empty(cCustoAster)
        cQuery := "SELECT "
        cQuery +=   " Departamentos_DFA "
        cQuery += "FROM "
        cQuery +=   " DEPARTAMENTO "
        cQuery += "WHERE "
        cQuery +=   "Cadastro_Departamentos = '" + cCustoAster + "' "
        DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasDpt, .f., .t.)

        If !(cAliasDpt)->(EoF())
            cDeptoDFA := cValToChar((cAliasDpt)->Departamentos_DFA)
        Else
            Conout("Departamento " + cCustoAster + " não encontrado!")
        EndIf
        
        (cAliasDpt)->(DbCloseArea())
    Else
        cDeptoDFA := "00"
    EndIf

Return cDeptoDFA

Static Function RetFilVD8()

    Local cQuery
    Local cAliasFil := GetNextAlias()
    Local aFilAster := {}

    cQuery := "SELECT "
    cQuery +=   " Codigo_DFA "
    cQuery += "FROM "
    cQuery +=   " LOCAL_DEPARTAMENTO "
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasFil, .f., .t.)

    While !(cAliasFil)->(EoF())
        AAdd(aFilAster,AllTrim((cAliasFil)->Codigo_DFA))
        (cAliasFil)->(dbSkip())
    End

    (cAliasFil)->(DbCloseArea())

Return aFilAster

Static Function RetProcCC(cCCusto)

    Local cQuery
    Local lProcessaCC := .f.
            
    Default cCCusto := ""
            
    If !Empty(cCCusto)
        cQuery := "SELECT "
        cQuery +=   " CTT_CLASSE "
        cQuery += "FROM "
        cQuery +=   RetSQLName("CTT") + " CTT "
        cQuery += "WHERE "
        cQuery +=   " D_E_L_E_T_ = ' ' "
        cQuery +=   " AND CTT_CUSTO = '" + cCCusto + "' "
        lProcessaCC := ( FM_SQL(cQuery) == '2' )
    EndIf

Return lProcessaCC