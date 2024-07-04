#include 'totvs.ch'
#define ARQUIVO_LOG	"sip_limpa_criticados.log"
#define DESPESA 1
#define CRITICA 2
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENCLSCRIT

Rotina para limpar as despesas criticadas do SIP na central

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
FUNCTION CENCLSCRIT()
    Local aSay     := {}
    Local aButton  := {}
    Local nOpc     := 0
    Local Titulo   := 'SIP - Limpeza de Criticados'
    Local cDesc1   := 'Esta rotina irá limpar as despesas criticadas com suas respectivas críticas'
    Local cDesc2   := 'As guias geradoras das despeas também serão desmarcadas.'
    Local lOk      := .T.

    aAdd( aSay, cDesc1 )
    aAdd( aSay, cDesc2 )

    aAdd( aButton, { 1, .T., { || nOpc := 2,  FechaBatch() } } )
    aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

    FormBatch( Titulo, aSay, aButton )

    If nOpc == 2

        if lHabMetric .and. lLibSupFw .and. lVrsAppSw
            FWMetrics():addMetrics("Limpa Desp. Criticadas - SIP", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
        endif
        Processa( { || lOk := ExecutaLimpeza() },"SIP - Limpeza de itens criticados","Processando...",.T.)

    EndIf

Return lOk

Static Function ExecutaLimpeza()
    Local cRegANS   := B3D->B3D_CODOPE
    Local cTipObr   := "1"//SIP
    Local cAtivo    := "1"//Ativo
    Local cCodObri  := B3D->B3D_CDOBRI
    Local cAnoComp  := B3D->B3D_ANO
    Local cCodComp  := B3D->B3D_CODIGO
    Local lRet := .F.

    PlsLogFil(CENDTHRL("I") + " Limpa criticas compromisso: " + cAnoComp + " " + cCodComp + " - inicio",ARQUIVO_LOG)

    lRet := LimpaCriticados(cRegAns,cCodObri,cAnoComp,cCodComp)

    PlsLogFil(CENDTHRL("I") + " Limpa criticas compromisso: " + cAnoComp + " " + cCodComp + " - termino",ARQUIVO_LOG)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENRETOBRI

Retorna o codigo da obrigacao - B3A_CODIGO

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
FUNCTION CENRETOBRI(cRegAns,cTipObr,cAtivo)
    Local cCodObri  := ""
    Local cSql      := ""
    Local cNomeArea := GetNextAlias()
    Default cRegAns := ""
    Default cTipObr := ""
    Default cAtivo  := "1"

    If !Empty(cRegAns) .AND. !Empty(cTipObr)
        cSql := "SELECT B3A_CODIGO "
        cSql += " FROM " + RetSqlName("B3A") + " "
        cSql += " WHERE "
        cSql += " B3A_FILIAL = '" + xFilial("B3A") + "' "
        cSql += " AND B3A_CODOPE = '" + cRegAns + "' "
        cSql += " AND B3A_TIPO = '" + cTipObr + "' "
        cSql += " AND B3A_ATIVO = '" + cAtivo + "' "
        cSql += " AND D_E_L_E_T_ = ' '"
        If CENCRIAALI(cSql,cNomeArea)
            cCodObri := (cNomeArea)->B3A_CODIGO
        EndIf
    EndIf
    (cNomeArea)->(dbCloseArea())

Return cCodObri

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LimpaCriticados

Execucao da limpeza de despesas e respectivas criticas referentes ao SIP da central

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function LimpaCriticados(cRegAns,cCodObri,cAnoComp,cCodComp)
    Local cSql      := ""
    Local cNomeArea := GetNextAlias()
    Local nRegua    := 5
    Local nInd      := 1
    Local nExec     := 0
    Local lRet      := .T.

    PlsLogFil(CENDTHRL("I") + " Limpa criticados - inicio",ARQUIVO_LOG)
    ProcRegua(nRegua)
    IncProc("Limpeza de despesas criticadas")

    BEGIN TRANSACTION
        cSql := RetornaQuery("1",cRegAns,cCodObri,cAnoComp,cCodComp)
        cMsg := "Desmarcando despesas do PLS criticadas"
        AtualizaRegua(cMsg,@nInd,nRegua)
        lRet := execStat(cSql, cMsg)
        If lRet
            cSql := RetornaQuery("2",cRegAns,cCodObri,cAnoComp,cCodComp)
            cMsg := "Limpando registros totalizadores "
            AtualizaRegua(cMsg,@nInd,nRegua)
            lRet := execStat(cSql, cMsg)
            If lRet
                cSql := RetornaQuery("3",cRegAns,cCodObri,cAnoComp,cCodComp)
                cMsg := "Limpando despesas criticadas"
                lRet := execStat(cSql, cMsg)
                If lRet
                    cSql := RetornaQuery("4",cRegAns,cCodObri,cAnoComp,cCodComp)
                    cMsg := "Deletando da central despesas excluidas no PLS"
                    lRet := DB3LSemBD7(cRegAns,cCodObri,cAnoComp,cCodComp)
                    If lRet
                        cSql := RetornaQuery("5",cRegAns,cCodObri,cAnoComp,cCodComp)
                        cMsg := "Limpando criticas de despesas"
                        lRet := execStat(cSql, cMsg)
                        If lRet
                            B3F->(dbSetOrder(3))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_STATUS+B3F_TIPO
                            If !B3F->(msSeek(xFilial('B3F')+B3D->(B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO) ) )
                                Reclock("B3D",.F.)
                                B3D->B3D_STATUS := '1' //Pdte Envio
                                B3D->(MsUnlock())
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf

    END TRANSACTION
    If lRet
        cMsg := "Limpeza de criticados concluída."
        MsgInfo(cMsg)
    Else
        cMsg := "Erro ao limpar criticados, verifique o log da operação."
        MsgAlert(cMsg)
    EndIf

    PlsLogFil(CENDTHRL("I") + " Limpa criticados - termino",ARQUIVO_LOG)

Return lRet

Static Function execStat(cSql, cMsg)
    Local nExec := 0
    Local lRet  := .T.
    Default cMsg := ""
    PlsLogFil(CENDTHRL("I") + " " + cMsg ,ARQUIVO_LOG)
    PlsLogFil(CENDTHRL("I") + " " + cSql ,ARQUIVO_LOG)
    nExec := TCSQLEXEC(cSql)
    If nExec < 0
        PlsLogFil(CENDTHRL("E") + cMsg + TCSQLError(),ARQUIVO_LOG)
    Else
        Comita(cSql)
    EndIf
    lRet := nExec >= 0
    If !lRet
        disarmTransaction()
    EndIf

Return lRet

Static Function DB3LSemBD7(cRegAns,cCodObri,cAnoComp,cCodComp)
    Local cSql        := ""
    Local lTabExist   := .F.
    Local lRet        := .F.
    Local cDb         := Upper(TcGetDb())
    Local lOracle     :=Upper(TcGetDb()) $ "ORACLE"
    Local cConcat     := IIf(SubStr(Alltrim(Upper(TCGetDb())),1,5) == "MSSQL","+","||")
    Local cTable      := IIf(lOracle .Or. cDb == "POSTGRES","B3LCOMBD7","#B3LCOMBD7")

    lTabExist := MsFile(cTable)

    If lTabExist
        DropB3LCOMBD7()
    EndIf

    If lOracle .Or. cDb == "POSTGRES"
        cSql := "CREATE TABLE " + cTable + " AS "
        cSql += " SELECT *
    Else
        cSql := " SELECT *
        cSql += " INTO #B3LCOMBD7 "
    EndIf
    cSql += " FROM ( "
    cSql += "     SELECT EVEDES "
    cSql += "     FROM ( "
    cSql += "         SELECT DISTINCT B3L_EVEDES AS EVEDES "
    cSql += "             ,'B3L' AS ONDE "
    cSql += "             ,1 AS QTD "
    cSql += "         FROM " + RetSqlName("B3L") + " B3L "
    cSql += "         WHERE B3L_FILIAL = '"+ xFilial("B3L") +"' "
    cSql += "           AND B3L_CODOPE = '" + cRegANS + "' "
    cSql += "           AND B3L_CODOBR = '" + cCodObri + "' "
    cSql += "           AND B3L_ANOCMP = '" + cAnoComp + "' "
    cSql += "           AND B3L_CDCOMP = '" + cCodComp + "' "
    cSql += "           AND B3L_EVEDES <> B3L_MATRIC "
    cSql += "         UNION ALL "
    cSql += " SELECT DISTINCT BD7_CODOPE "+cConcat+"BD7_CODLDP"+cConcat+"BD7_CODPEG"+cConcat+"BD7_NUMERO"+cConcat+"BD7_ORIMOV AS EVEDES "
    cSql += "             ,'BD7' AS ONDE "
    cSql += "             ,1 AS QTD "
    cSql += "         FROM " + RetSqlName("BD7") + " BD7 "
    cSql += "         WHERE BD7_FILIAL ='"+ xFilial("BD7") +"' "
    cSql += "             AND BD7.D_E_L_E_T_ = ' ' "
    If lOracle
        cSql += "         )  "
    Else
        cSql += "         ) AS TABELASJUNTAS "
    EndIf
    cSql += "     GROUP BY EVEDES "
    cSql += "     HAVING COUNT(QTD) >= 2 "

    If lOracle
        cSql += "     )  "
    Else
        cSql += "     ) AS EVENTOSNASDUASTAB "
    EndIf

    If execStat(cSql, "PREENCHENDO TABELA TEMPORARIA")
        //Executa o delete
        cSql := " DELETE  " + RetSqlName("B3L") + " "

        If cDb == "POSTGRES"
            cSql := " DELETE FROM " + RetSqlName("B3L") + " "
        EndIf

        cSql += " WHERE "
        cSql += "   B3L_FILIAL='"+ xFilial("B3L") +"' "
        cSql += "   AND B3L_CODOPE = '" + cRegANS + "' "
        cSql += "   AND B3L_CODOBR = '" + cCodObri + "' "
        cSql += "   AND B3L_ANOCMP = '" + cAnoComp + "' "
        cSql += "   AND B3L_CDCOMP = '" + cCodComp + "' "
        cSql += "   AND B3L_EVEDES <> B3L_MATRIC "
        cSql += " 	AND B3L_EVEDES NOT IN (SELECT EVEDES FROM " + cTable + ") "

        cSql += "   AND D_E_L_E_T_ = ' ' "
        lRet := execStat(cSql,"DELETANDO REGISTROS CRITICADOS")
    EndIf
    //Exclui a tabela
    lRet := DropB3LCOMBD7()

Return lRet

Static Function DropB3LCOMBD7()
    Local cSql   := ""
    Local lRet   := .T.
    Local lOracle:=Upper(TcGetDb()) $ "ORACLE/POSTGRES"
    Local cTable := IIf(lOracle,"B3LCOMBD7","#B3LCOMBD7")

    cSql := " DROP TABLE " + cTable+ " "


    lRet := execStat(cSql,"APAGANDO TABELA TEMPORARIA")

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaQuery

Retorna a query que será executada

@author timoteo.bega
@since 19/12/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaQuery(cTipo,cRegAns,cCodObri,cAnoComp,cCodComp,cChaveGuia)
    Local cSql          := ""
    //Local cSubStr       := IIf(SubStr(Alltrim(Upper(TCGetDb())),1,5) == "MSSQL","SUBSTRING","SUBSTR")
    Local cDb           := Alltrim(Upper(TCGetDb()))
    Local cConcat       := IIf(SubStr((cDb),1,5) == "MSSQL","+","||")
    Default cTipo       := "1"//1-Totalizadores, 2-Itens - B3L_EVEDES , 3-Itens, 4-ChaveGuia
    Default cRegAns     := ""
    Default cCodObri    := ""
    Default cAnoComp    := ""
    Default cCodComp    := ""
    Default cChaveGuia   := ""

    If cTipo == "1" //Desmarca despesas do PLS criticadas

        cSql := "UPDATE "+ RetSqlName("BD7") + " SET BD7_RECSIP = '' "
        cSql += " WHERE "
        cSql += " BD7_FILIAL = '" + xFilial("BD7") + "' "
        cSql += " AND BD7_CODOPE"+cConcat+"BD7_CODLDP"+cConcat+"BD7_CODPEG"+cConcat+"BD7_NUMERO"+cConcat+"BD7_ORIMOV IN "
        cSql += "   ( SELECT B3L_EVEDES FROM " + RetSqlName("B3L") + " "
        cSql += "       WHERE B3L_FILIAL = '  ' "
        cSql += "       AND B3L_CODOPE = '" + cRegANS + "' "
        cSql += "       AND B3L_CODOBR = '" + cCodObri + "' "
        cSql += "       AND B3L_ANOCMP = '" + cAnoComp + "' "
        cSql += "       AND B3L_CDCOMP = '" + cCodComp + "' "
        cSql += "       AND B3L_EVEDES <> B3L_MATRIC "
        cSql += "       AND B3L_STATUS = '3' "
        cSql += "       AND D_E_L_E_T_ = ' ' "
        cSql += "     ) "
        cSql += " AND BD7_RECSIP <> '' "
        cSql += " AND D_E_L_E_T_ = ' ' "
    ElseIf cTipo == "2" //Deleta totalizadores de despesa criticados
        cSql := " DELETE " + RetSqlName("B3L") + " "

        If cDb $ "POSTGRES"
            cSql := " DELETE FROM " + RetSqlName("B3L") + " "
        EndIf

        cSql += " WHERE "
        cSql += "   B3L_FILIAL='"+ xFilial("B3L") +"' "
        cSql += "   AND B3L_CODOPE = '" + cRegANS + "' "
        cSql += "   AND B3L_CODOBR = '" + cCodObri + "' "
        cSql += "   AND B3L_ANOCMP = '" + cAnoComp + "' "
        cSql += "   AND B3L_CDCOMP = '" + cCodComp + "' "
        cSql += "   AND B3L_EVEDES = B3L_MATRIC "
        cSql += "   AND B3L_STATUS = '3' "
        If !Empty(cChaveGuia)
            cSql += " AND B3L_EVEDES='" + cChaveGuia + "' "
        EndIf
        cSql += "   AND D_E_L_E_T_ = ' ' "

    ElseIf cTipo == "3"//Deleta na central despesas criticadas
        cSql := " DELETE " + RetSqlName("B3L") + " "

        If cDb $ "POSTGRES"
            cSql := " DELETE FROM " + RetSqlName("B3L") + " "
        EndIf

        cSql += " WHERE "
        cSql += "   B3L_FILIAL='"+ xFilial("B3L") +"' "
        cSql += "   AND B3L_CODOPE = '" + cRegANS + "' "
        cSql += "   AND B3L_CODOBR = '" + cCodObri + "' "
        cSql += "   AND B3L_ANOCMP = '" + cAnoComp + "' "
        cSql += "   AND B3L_CDCOMP = '" + cCodComp + "' "
        cSql += "   AND B3L_EVEDES <> B3L_MATRIC "
        cSql += "   AND B3L_STATUS = '3' "
        cSql += "   AND D_E_L_E_T_ = ' ' "

    ElseIf cTipo == "4" //Deleta da central as despesas que foram marcadas no PLS para exclusão

        cSql := " DELETE " + RetSqlName("B3L") + "  "

        If cDb $ "POSTGRES"
            cSql := " DELETE FROM " + RetSqlName("B3L") + " "
        EndIf

        cSql += " WHERE "
        cSql += "   B3L_FILIAL='"+ xFilial("B3L") +"' "
        cSql += "   AND B3L_CODOPE = '" + cRegANS + "' "
        cSql += "   AND B3L_CODOBR = '" + cCodObri + "' "
        cSql += "   AND B3L_ANOCMP = '" + cAnoComp + "' "
        cSql += "   AND B3L_CDCOMP = '" + cCodComp + "' "
        cSql += "   AND B3L_EVEDES <> B3L_MATRIC "
        cSql += "   AND B3L_EVEDES IN ( "
        cSql += "               SELECT  BD7_CODOPE"+cConcat+"BD7_CODLDP"+cConcat+"BD7_CODPEG"+cConcat+"BD7_NUMERO"+cConcat+"BD7_ORIMOV "
        cSql += "                   FROM " + RetSqlName("BD7") + " "
        cSql += "                   WHERE 1=1 "
        cSql += "                       AND BD7_FILIAL ='"+ xFilial("BD7") +"' "
        cSql += "                       AND BD7_RECSIP = '" + cAnoComp+SubStr(cCodComp,2,2) + "'  "
        cSql += "                       AND D_E_L_E_T_ = ' ' ) "
        cSql += "   AND D_E_L_E_T_ = ' ' "

    ElseIf cTipo == "5" //Deleta as críticas que estão na B3F e não estão na B3L
        cSql := " DELETE " + RetSqlName("B3F") + " "

        If cDb $ "POSTGRES"
            cSql := " DELETE FROM " + RetSqlName("B3F") + " "
        EndIf

        cSql += " WHERE "
        cSql += "   B3F_FILIAL='"+ xFilial("B3L") +"' "
        cSql += "   AND B3F_CODOPE = '" + cRegANS + "' "
        cSql += "   AND B3F_CDOBRI = '" + cCodObri + "' "
        cSql += "   AND B3F_ANO = '" + cAnoComp + "' "
        cSql += "   AND B3F_CDCOMP = '" + cCodComp + "' "
        cSql += "   AND B3F_ORICRI = 'B3L' "
        cSql += "   AND B3F_CHVORI NOT IN( SELECT R_E_C_N_O_ FROM " + RetSqlName("B3L") + ") "

    EndIf

Return cSql

Static Function Comita(cSql)
    Local nCommit   := 0
    Default cSql    := ""

    If SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
        nCommit := TCSQLEXEC("COMMIT")
        If nCommit < 0
            PlsLogFil(CENDTHRL("E") + " Instrucao: " + cSql + " Erro: " + TCSQLError(),ARQUIVO_LOG)
        EndIf
    EndIf
Return

Static Function AtualizaRegua(cMsg,nInd,nRegua)
    Default cMsg    := ""
    Default nInd    := 0
    Default nRegua  := 0

    IncProc(AllTrim(Str(nInd)) +"/"+ AllTrim(Str(nRegua)) + " " + cMsg)
    nInd++

Return