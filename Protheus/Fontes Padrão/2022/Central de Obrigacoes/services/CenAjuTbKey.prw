#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'

#DEFINE ARQ_LOG     "ajuste_tabkey.log"
#DEFINE ARQ_MOV_CSV "tabkey_movimentos.csv"
#DEFINE ARQ_CRI_CSV "tabkey_criticas.csv"

/*/{Protheus.doc}
    @type  Function
    @author lima.everton
    @since 09/12/2019
/*/
Main Function SvcTabKey()
Local cEmp := cEmpAnt
Local cFil := cFilAnt
StartJob("CenAjuTabKey", GetEnvServer(), .F., cEmp, cFil)
return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

Function CenAjuTabKey(cEmp, cFil, lJob)
    Default lJob := .T.
    If lJob
        rpcSetType(3)
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf
    BEGIN TRANSACTION
        PlsLogFil(CENDTHRL("I") + "[CenAjuTabKey] Inicio do ajuste de preenchimento do tabkey. ",ARQ_LOG)
        upTbKeyB3K()
        upTbKeyB3X()
        upTbKeyB3R()
        upTbKeyB3W()
        upTbKeyB3L()
        PlsLogFil(CENDTHRL("I") + "[CenAjuTabKey] Fim do ajuste de preenchimento do tabkey.",ARQ_LOG)
    END TRANSACTION
    MsgInfo("Processamento concluído!")
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} upTbKeyB3K()
    Popula a coluna TABKEY com as chaves da B3K CodCCo e Matricula
    @author lima.everton
    @since 10/02/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function upTbKeyB3K()

    Local nQtd := 0
    Local nProc:= 0

    B3F->(DbSetOrder(1)) //B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI

    PlsLogFil(CENDTHRL("I") + "[upTbKeyB3K] Inicio para popular tabkey. ",ARQ_LOG)
    PlsLogFil("recno_b3k;recno_b3f;valo_antigo;valor_novo",ARQ_CRI_CSV)

    If B3F->(FieldPos("B3F_TABKEY")) > 0 .AND. !ReadyRun()
        nQtd := carCriticas(.T.)
        If nQtd > 0
            carCriticas(.F.)
            Do While !TRBB3K->(Eof())
                B3F->(DbGoto(TRBB3K->RECB3F))
                nVlrAntigo := B3F->B3F_CHVORI
                If B3F->(MsSeek(xFilial("B3F")+TRBB3K->(B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI)+PADR(TRBB3K->RECB3K,tamSX3("B3F_CHVORI")[1])+TRBB3K->(B3F_CODCRI+B3F_TIPO+B3F_IDEORI)))
                    B3F->(DbGoto(TRBB3K->RECB3F))
                    RecLock('B3F',.F.)
                    B3F->B3F_TABKEY := TRBB3K->B3K_CODCCO+TRBB3K->B3K_MATRIC
                    B3F->(MsUnlock())
                    PlsLogFil(Alltrim(Str(TRBB3K->RECB3K))+";"+Alltrim(Str(TRBB3K->RECB3F))+";"+Alltrim(Str(nVlrAntigo))+";"+TRBB3K->B3K_CODCCO+TRBB3K->B3K_MATRIC,ARQ_CRI_CSV)
                EndIf
                nProc++
                TRBB3K->(DbSkip())
            EndDo
        Else
            PlsLogFil(CENDTHRL("W") + "[upTbKeyB3K] Não encontrou dados para processar. ",ARQ_LOG)
        EndIf
        TRBB3K->(DbCloseArea())
        PlsLogFil(CENDTHRL("I") + "[upTbKeyB3K] Fim dos ajustes e preenchimento dos tabkeys. ",ARQ_LOG)
    else
        PlsLogFil(CENDTHRL("I") + "[upTbKeyB3K] Sistema ainda não contém a coluna B3F_TABKEY. ",ARQ_LOG)
    EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} upTbKeyB3X()
    Popula a coluna TABKEY com as chaves da B3X CodCCo e Matricula
    @author lima.everton
    @since 10/02/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function upTbKeyB3X()

    Local nQtd := 0

    B3F->(DbSetOrder(1)) //B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI

    PlsLogFil(CENDTHRL("I") + "[upTbKeyB3X] Inicio para popular tabkey. ",ARQ_LOG)
    PlsLogFil("recno_b3x;recno_b3f;valo_antigo;valor_novo",ARQ_CRI_CSV)

    nQtd := carMovtoSIB(.T.)
    If nQtd > 0 .And. B3F->(FieldPos("B3F_TABKEY")) > 0 .AND. !ReadyRun("B3X")
        carMovtoSIB(.F.)
        Do While !TBRB3X->(Eof())
            B3F->(DbGoto(TBRB3X->RECB3F))
            nVlrAntigo := B3F->B3F_CHVORI
            If B3F->(MsSeek(xFilial("B3F")+TBRB3X->(B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI)+PADR(TBRB3X->RECB3X,tamSX3("B3F_CHVORI")[1])+TBRB3X->(B3F_CODCRI+B3F_TIPO+B3F_IDEORI)))
                B3F->(DbGoto(TBRB3X->RECB3F))
                RecLock('B3F',.F.)
                B3F->B3F_TABKEY := TBRB3X->(B3X_CAMPO+B3X_OPERA+B3X_ARQUIV+B3X_DATA+B3X_HORA+B3X_IDEORI+B3X_DESORI+B3X_CODCCO)
                B3F->(MsUnlock())
                PlsLogFil(Alltrim(Str(TBRB3X->RECB3X))+";"+Alltrim(Str(TBRB3X->RECB3F))+";"+Alltrim(Str(nVlrAntigo))+";"+TBRB3X->B3X_CODCCO+TBRB3X->B3X_IDEORI,ARQ_CRI_CSV)
            EndIf
            TBRB3X->(DbSkip())
        EndDo
    Else
        PlsLogFil(CENDTHRL("W") + "[upTbKeyB3X] Não encontrou dados para processar. ",ARQ_LOG)
    EndIf
    TBRB3X->(DbCloseArea())
    PlsLogFil(CENDTHRL("I") + "[upTbKeyB3X] Fim dos ajustes e preenchimento dos tabkeys. ",ARQ_LOG)

Return

/*/{Protheus.doc} upTbKeyB3W()
    Popula a coluna TABKEY com as chaves da B3X CodCCo e Matricula
    @author lima.everton
    @since 10/02/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function upTbKeyB3W()

    Local nQtd := 0

    B3F->(DbSetOrder(1)) //B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI

    PlsLogFil(CENDTHRL("I") + "[upTbKeyB3W] Inicio para popular tabkey. ",ARQ_LOG)
    PlsLogFil("recno_b3w;recno_b3f;valo_antigo;valor_novo",ARQ_CRI_CSV)

    nQtd := carEspSIB(.T.)
    If nQtd > 0 .And. B3F->(FieldPos("B3F_TABKEY")) > 0
        carEspSIB(.F.)
        Do While !TBRB3W->(Eof())
            B3F->(DbGoto(TBRB3W->RECB3F))
            nVlrAntigo := B3F->B3F_CHVORI
            If B3F->(MsSeek(xFilial("B3F")+TBRB3W->(B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI)+PADR(TBRB3W->RECB3W,tamSX3("B3F_CHVORI")[1])+TBRB3W->(B3F_CODCRI+B3F_TIPO+B3F_IDEORI)))
                B3F->(DbGoto(TBRB3W->RECB3F))
                RecLock('B3F',.F.)
                B3F->B3F_TABKEY := TBRB3W->B3W_CODCCO+TBRB3W->B3W_MATRIC
                B3F->(MsUnlock())
                PlsLogFil(Alltrim(Str(TBRB3W->RECB3W))+";"+Alltrim(Str(TBRB3W->RECB3F))+";"+Alltrim(Str(nVlrAntigo))+";"+TBRB3W->B3W_CODCCO+TBRB3W->B3W_MATRIC,ARQ_CRI_CSV)
            EndIf
            TBRB3W->(DbSkip())
        EndDo

    Else
        PlsLogFil(CENDTHRL("W") + "[upTbKeyB3W] Não encontrou dados para processar. ",ARQ_LOG)
    EndIf
    TBRB3W->(DbCloseArea())
    PlsLogFil(CENDTHRL("I") + "[upTbKeyB3W] Fim dos ajustes e preenchimento dos tabkeys. ",ARQ_LOG)

Return

/*/{Protheus.doc} upTbKeyB3R()
    Popula a coluna TABKEY com as chaves da B3R Nome do arquivo
    @author lima.everton
    @since 18/02/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function upTbKeyB3R()

    Local nQtd := 0

    B3F->(DbSetOrder(1)) //B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI

    PlsLogFil(CENDTHRL("I") + "[upTbKeyB3R] Inicio para popular tabkey. ",ARQ_LOG)
    PlsLogFil("recno_b3r;recno_b3f;valo_antigo;valor_novo",ARQ_CRI_CSV)

    nQtd := carArqSIB(.T.)
    If nQtd > 0 .And. B3F->(FieldPos("B3F_TABKEY")) > 0
        carArqSIB(.F.)
        Do While !TBRB3R->(Eof())
            B3F->(DbGoto(TBRB3R->RECB3F))
            nVlrAntigo := B3F->B3F_CHVORI
            If B3F->(MsSeek(xFilial("B3F")+TBRB3R->(B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI)+PADR(TBRB3R->RECB3R,tamSX3("B3F_CHVORI")[1])+TBRB3R->(B3F_CODCRI+B3F_TIPO+B3F_IDEORI)))
                B3F->(DbGoto(TBRB3R->RECB3F))
                RecLock('B3F',.F.)
                B3F->B3F_TABKEY := TBRB3R->B3R_ARQUIV
                B3F->(MsUnlock())
                PlsLogFil(Alltrim(Str(TBRB3R->RECB3R))+";"+Alltrim(Str(TBRB3R->RECB3F))+";"+Alltrim(Str(nVlrAntigo))+";"+TBRB3R->B3R_ARQUIV,ARQ_CRI_CSV)
            EndIf
            TBRB3R->(DbSkip())
        EndDo
    Else
        PlsLogFil(CENDTHRL("W") + "[upTbKeyB3R] Não encontrou dados para processar. ",ARQ_LOG)
    EndIf
    TBRB3R->(DbCloseArea())
    PlsLogFil(CENDTHRL("I") + "[upTbKeyB3R] Fim dos ajustes e preenchimento dos tabkeys. ",ARQ_LOG)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} upTbKeyB3L()
    Popula a coluna TABKEY com as chaves da B3L
    @author lima.everton
    @since 10/02/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function upTbKeyB3L()

    Local nQtd := 0
    Local nProc:= 0

    B3F->(DbSetOrder(1)) //B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI

    PlsLogFil(CENDTHRL("I") + "[upTbKeyB3L] Inicio para popular tabkey. ",ARQ_LOG)
    PlsLogFil("recno_b3l;recno_b3f;valo_antigo;valor_novo",ARQ_CRI_CSV)

    If B3F->(FieldPos("B3F_TABKEY")) > 0 .AND. !ReadyRun("B3L")
        nQtd := carCritiSIP(.T.)
        If nQtd > 0
            carCritiSIP(.F.)
            Do While !TRBB3L->(Eof())
                B3F->(DbGoto(TRBB3L->RECB3F))
                nVlrAntigo := B3F->B3F_CHVORI
                If B3F->(MsSeek(xFilial("B3F")+TRBB3L->(B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI)+PADR(TRBB3L->RECB3L,tamSX3("B3F_CHVORI")[1])+TRBB3L->(B3F_CODCRI+B3F_TIPO+B3F_IDEORI)))
                    B3F->(DbGoto(TRBB3L->RECB3F))
                    RecLock('B3F',.F.)
                    B3F->B3F_TABKEY := TRBB3L->(B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+B3L_DATEVE+B3L_EVDEIN)
                    B3F->(MsUnlock())
                    PlsLogFil(Alltrim(Str(TRBB3L->RECB3L))+";"+Alltrim(Str(TRBB3L->RECB3F))+";"+Alltrim(Str(nVlrAntigo))+";"+TRBB3L->B3L_EVEDES+TRBB3L->B3L_CODEVE,ARQ_CRI_CSV)
                EndIf
                nProc++
                TRBB3L->(DbSkip())
            EndDo
        Else
            PlsLogFil(CENDTHRL("W") + "[upTbKeyB3L] Não encontrou dados para processar. ",ARQ_LOG)
        EndIf
        TRBB3L->(DbCloseArea())
        PlsLogFil(CENDTHRL("I") + "[upTbKeyB3L] Fim dos ajustes e preenchimento dos tabkeys. ",ARQ_LOG)
    else
        PlsLogFil(CENDTHRL("I") + "[upTbKeyB3L] Sistema ainda não contém a coluna B3F_TABKEY. ",ARQ_LOG)
    EndIf
Return


//Carrega Criticas
Static Function carCriticas(lTotal)

    Local cSql := ""
    Local nQtd := 0

    Default lTotal := .F.

    If Select('TRBB3K') > 0
        TRBB3K->(dbCloseArea())
    EndIf

    cSql := " SELECT  "
    If lTotal
        cSql += " 	count(1) TOTAL "
    Else
        cSql += " 	B3K.R_E_C_N_O_ RECB3K, B3F.R_E_C_N_O_ RECB3F "
        cSql += " 	,B3F_CODOPE,B3F_CDOBRI,B3F_ANO,B3F_CDCOMP "
        cSql += " 	,B3F_ORICRI,B3F_CODCRI,B3F_TIPO,B3F_IDEORI "
        cSql += " 	,B3K_CODCCO,B3K_MATRIC "
    EndIf
    cSql += " FROM " + RetSqlName("B3F") + " B3F , "
    cSql += " " + RetSqlName("B3K") + " B3K "
    cSql += " WHERE "
    cSql += "	B3F_FILIAL = '" + xFilial('B3F') + "' "
    cSql += "	AND B3F_FILIAL = B3K_FILIAL "
    cSql += "	AND B3F_CODOPE = B3K_CODOPE "
    cSql += "	AND B3F_ORICRI = 'B3K' "
    cSql += "	AND B3F_IDEORI = B3K_MATRIC "
    cSql += "	AND B3F_CODCRI <> '' "
    cSql += "	AND B3F_CHVORI = B3K.R_E_C_N_O_ "
    cSql += "	AND B3F.D_E_L_E_T_ = ' ' "
    cSql += "	AND B3K.D_E_L_E_T_ = ' ' "
    cSql += "	AND B3K.R_E_C_N_O_ > 0 "
    cSql += "	AND B3F.R_E_C_N_O_ > 0 "
    cSql := ChangeQuery(cSql)

    PlsLogFil(CENDTHRL("I") + "[carCriticas] Query de críticas: " + cSql,ARQ_LOG)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB3K",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carCriticas] Fim da query.",ARQ_LOG)

    If lTotal .AND. !TRBB3K->(Eof())
        nQtd := TRBB3K->TOTAL
    EndIf

Return nQtd


//Carrega Criticas
Static Function carCritiSIP(lTotal)

    Local cSql := ""
    Local nQtd := 0

    Default lTotal := .F.

    If Select('TRBB3L') > 0
        TRBB3L->(dbCloseArea())
    EndIf

    cSql := " SELECT  "
    If lTotal
        cSql += " 	count(1) TOTAL "
    Else
        cSql += " 	B3L.R_E_C_N_O_ RECB3L, B3F.R_E_C_N_O_ RECB3F "
        cSql += " 	,B3F_CODOPE,B3F_CDOBRI,B3F_ANO,B3F_CDCOMP "
        cSql += " 	,B3F_ORICRI,B3F_CODCRI,B3F_TIPO,B3F_IDEORI "
        cSql += " 	,B3L_MATRIC,B3L_EVEDES,B3L_CDTPTB,B3L_CODEVE,B3L_CLAAMB,B3L_CLAINT,B3L_FORCON,B3L_SEGMEN,B3L_DATEVE,B3L_EVDEIN "

    EndIf
    cSql += " FROM " + RetSqlName("B3F") + " B3F , "
    cSql += " " + RetSqlName("B3L") + " B3L "
    cSql += " WHERE "
    cSql += "	B3F_FILIAL = '" + xFilial('B3F') + "' "
    cSql += "	AND B3F_FILIAL = B3L_FILIAL "
    cSql += "	AND B3F_CODOPE = B3L_CODOPE "
    cSql += "	AND B3F_ORICRI = 'B3L' "
    cSql += "	AND B3F_IDEORI = B3L_EVEDES "
    cSql += "	AND B3F_CODCRI <> '' "
    cSql += "	AND B3F_CHVORI = B3L.R_E_C_N_O_ "
    cSql += "	AND B3F.D_E_L_E_T_ = ' ' "
    cSql += "	AND B3L.D_E_L_E_T_ = ' ' "
    cSql += "	AND B3L.R_E_C_N_O_ > 0 "
    cSql += "	AND B3F.R_E_C_N_O_ > 0 "
    cSql := ChangeQuery(cSql)

    PlsLogFil(CENDTHRL("I") + "[carCritiSIP] Query de críticas: " + cSql,ARQ_LOG)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB3L",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carCritiSIP] Fim da query.",ARQ_LOG)

    If lTotal .AND. !TRBB3L->(Eof())
        nQtd := TRBB3L->TOTAL
    EndIf

Return nQtd

//Carrega Movimentos
Static Function carMovtoSIB(lTotal)
    Local cSql := ""
    Local nQtd := 0

    Default lTotal := .F.

    If Select('TBRB3X') > 0
        TBRB3X->(dbCloseArea())
    EndIf

    cSql := " SELECT  "
    If lTotal
        cSql += " 	count(1) TOTAL "
    Else
        cSql += " 	B3X.R_E_C_N_O_ RECB3X, B3F.R_E_C_N_O_ RECB3F "
        cSql += " 	,B3F_CODOPE,B3F_CDOBRI,B3F_ANO,B3F_CDCOMP "
        cSql += " 	,B3F_ORICRI,B3F_CODCRI,B3F_TIPO,B3F_IDEORI "
        cSql += " 	,B3X_CAMPO,B3X_OPERA,B3X_ARQUIV,B3X_DATA "
        cSql += " 	,B3X_HORA,B3X_IDEORI,B3X_DESORI,B3X_CODCCO "
    EndIf
    cSql += " FROM " + RetSqlName("B3F") + " B3F , "
    cSql += " " + RetSqlName("B3X") + " B3X "
    cSql += " WHERE 1=1 "
    cSql += "	AND B3F_FILIAL = '" + xFilial('B3F') + "' "
    cSql += "	AND B3X_FILIAL = B3F_FILIAL "
    cSql += "	AND B3X_CODOPE = B3F_CODOPE  "
    cSql += "	AND B3F_ORICRI = 'B3X'  "
    cSql += "	AND B3F_IDEORI = B3X_IDEORI  "
    cSql += "	AND B3F_CHVORI = B3X.R_E_C_N_O_  "
    cSql += "	AND B3F.D_E_L_E_T_ = ' '  "
    cSql += "	AND B3X.D_E_L_E_T_ = ' '  "
    cSql += "	AND B3F.R_E_C_N_O_ > 0  "
    cSql += "	AND B3X.R_E_C_N_O_ > 0  "
    cSql := ChangeQuery(cSql)

    PlsLogFil(CENDTHRL("I") + "[carMovtoSIB] Query de movimentações: " + cSql,ARQ_LOG)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TBRB3X",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carMovtoSIB] Fim da query.",ARQ_LOG)

    If lTotal .AND. !TBRB3X->(Eof())
        nQtd := TBRB3X->TOTAL
    EndIf

Return nQtd

//Carrega Espelho
Static Function carEspSIB(lTotal)
    Local cSql := ""
    Local nQtd := 0

    Default lTotal := .F.

    If Select('TBRB3W') > 0
        TBRB3W->(dbCloseArea())
    EndIf

    cSql := " SELECT  "
    If lTotal
        cSql += " 	count(1) TOTAL "
    Else
        cSql += " 	B3W.R_E_C_N_O_ RECB3W, B3F.R_E_C_N_O_ RECB3F "
        cSql += " 	,B3F_CODOPE,B3F_CDOBRI,B3F_ANO,B3F_CDCOMP "
        cSql += " 	,B3F_ORICRI,B3F_CODCRI,B3F_TIPO,B3F_IDEORI "
        cSql += " 	,B3W_CODCCO, B3W_MATRIC "
    EndIf
    cSql += " FROM " + RetSqlName("B3F") + " B3F , "
    cSql += " " + RetSqlName("B3W") + " B3W "
    cSql += " WHERE 1=1 "
    cSql += "	AND B3F_FILIAL = '" + xFilial('B3F') + "' "
    cSql += "	AND B3W_FILIAL = B3F_FILIAL "
    cSql += "	AND B3W_CODOPE = B3F_CODOPE  "
    cSql += "	AND B3F_ORICRI = 'B3W'  "
    cSql += "	AND B3F_IDEORI = B3W_MATRIC  "
    cSql += "	AND B3F_CHVORI = B3W.R_E_C_N_O_  "
    cSql += "	AND B3F.D_E_L_E_T_ = ' '  "
    cSql += "	AND B3W.D_E_L_E_T_ = ' '  "
    cSql += "	AND B3F.R_E_C_N_O_ > 0  "
    cSql += "	AND B3W.R_E_C_N_O_ > 0  "
    cSql := ChangeQuery(cSql)

    PlsLogFil(CENDTHRL("I") + "[carEspSIB] Query de movimentações: " + cSql,ARQ_LOG)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TBRB3W",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carEspSIB] Fim da query.",ARQ_LOG)

    If lTotal .AND. !TBRB3W->(Eof())
        nQtd := TBRB3W->TOTAL
    EndIf

Return nQtd


//Carrega Arquivos B3R
Static Function carArqSIB(lTotal)
    Local cSql := ""
    Local nQtd := 0

    Default lTotal := .F.

    If Select('TBRB3R') > 0
        TBRB3R->(dbCloseArea())
    EndIf

    cSql := " SELECT  "
    If lTotal
        cSql += " 	count(1) TOTAL "
    Else
        cSql += " 	B3R.R_E_C_N_O_ RECB3R, B3F.R_E_C_N_O_ RECB3F "
        cSql += " 	,B3F_CODOPE,B3F_CDOBRI,B3F_ANO,B3F_CDCOMP "
        cSql += " 	,B3F_ORICRI,B3F_CODCRI,B3F_TIPO,B3F_IDEORI "
        cSql += " 	,B3R_ARQUIV "
    EndIf
    cSql += " FROM " + RetSqlName("B3F") + " B3F , "
    cSql += " " + RetSqlName("B3R") + " B3R "
    cSql += " WHERE 1=1 "
    cSql += "	AND B3F_FILIAL = '" + xFilial('B3F') + "' "
    cSql += "	AND B3R_FILIAL = B3F_FILIAL "
    cSql += "	AND B3R_CODOPE = B3F_CODOPE  "
    cSql += "	AND B3F_ORICRI = 'B3R'  "
    cSql += "	AND B3F_CHVORI = B3R.R_E_C_N_O_  "
    cSql += "	AND B3F.D_E_L_E_T_ = ' '  "
    cSql += "	AND B3R.D_E_L_E_T_ = ' '  "
    cSql += "	AND B3F.R_E_C_N_O_ > 0  "
    cSql += "	AND B3R.R_E_C_N_O_ > 0  "
    cSql := ChangeQuery(cSql)

    PlsLogFil(CENDTHRL("I") + "[carArqSIB] Query de movimentações: " + cSql,ARQ_LOG)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TBRB3R",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[carArqSIB] Fim da query.",ARQ_LOG)

    If lTotal .AND. !TBRB3R->(Eof())
        nQtd := TBRB3R->TOTAL
    EndIf

Return nQtd

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReadyRun
Checa se já rodou o cadastros de chaves no SIB, para não rodar sempre.
@author lima.everton
@since 15/02/2021
/*/
//--------------------------------------------------------------------------------------------------

Function ReadyRun(cOriCri)

    Local lRet := .F.
    Local cSql := ""
    Local cDB	  := TCGetDB()
    Local cDBText := "ORACLE POSTGRES"
    Default cOriCri := ""

    If Select('TRBCHECK') > 0
        TRBCHECK->(dbCloseArea())
    EndIf

    cSql += " SELECT "
    If !(cDB $ cDBText)
        cSql += " TOP 1 "
    EndIf
    cSql += " B3F_ORICRI, "
    cSql += " B3F_TABKEY "
    cSql += "  FROM " + RetSqlName("B3F")
    cSql += " WHERE B3F_TABKEY <> ' ' "

    If !Empty(cOriCri)
        cSql += " AND B3F_ORICRI = '" +cOriCri+ "' "
    EndIf

    If (cDB $ "ORACLE")
        cSql += "	AND ROWNUM = 1 "
    EndIf
    If (cDB $ "POSTGRES")
        cSql += "	LIMIT 1 "
    EndIf

    cSql := ChangeQuery(cSql)

    PlsLogFil(CENDTHRL("I") + "[AlreadyRun] Query que checa se ja rodou o preenchimento do TabKey: " + cSql,ARQ_LOG)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCHECK",.F.,.T.)
    PlsLogFil(CENDTHRL("I") + "[AlreadyRun] Fim da query.",ARQ_LOG)

    If !TRBCHECK->(Eof())
        lRet := !Empty(TRBCHECK->B3F_TABKEY)
        If lRet .AND. TRBCHECK->B3F_ORICRI == 'B3X' .AND. Len(RTrim(TRBCHECK->B3F_TABKEY)) <= 62
            lRet := .F.
        EndIf
        If lRet
            PlsLogFil(CENDTHRL("I") + "[AlreadyRun] Importação ja efetuada. ",ARQ_LOG)
        EndIf
    EndIf
    TRBCHECK->(DbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENDTHRL

Funcao criada para retornar date e hora para log

@author timoteo.bega
@since
/*/
//--------------------------------------------------------------------------------------------------
Static Function CENDTHRL(cTp)
    Local cMsg := "[" + DTOS(Date()) + " " + Time() + "]"
    Default cTp	:= "I"
    If cTp == "E"
        cMsg += "[ERRO]"
    ElseIf cTp == "W"
        cMsg += "[WARN]"
    Else
        cMsg += "[INFO]"
    EndIf
Return cMsg


