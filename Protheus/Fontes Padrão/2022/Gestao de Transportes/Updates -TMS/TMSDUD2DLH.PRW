#INCLUDE 'PROTHEUS.CH'

#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} TMSDUD2DLH
    (Popula a tabela DLH - Histórico do MDF-e com os dados da tabela DUD - Movimento da Viagem sincronizando os dados para busca do manifesto de carga)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function TMSDUD2DLH()
        //| Rotina de Migração roda somente se existir a tabela
        If TableInDic("DLH") == .T.
            TmsLogMsg("INFO","================================================================================================")
            TmsLogMsg("INFO", "Inicio - Migração de Dados para o Histórico do MDF-e...") 
            TmsLogMsg("INFO", " " + DtoC(Date()) + " " + Time()) 

            ProcDUD2DLH()

            TmsLogMsg("INFO", "### Termino : " + DTOC(Date()) + " " + Time()) 
            TmsLogMsg("INFO","================================================================================================")
        ELSE
            TmsLogMsg("INFO","================================================================================================")
            TmsLogMsg("INFO", DTOC(Date()) + " " + Time() )
            TmsLogMsg("INFO", "### Migrador do Histórico do MDF-e não será executado, pois não foi localizado a tabela DLH."   )
            TmsLogMsg("INFO", "### Atualize o Dicionário de dados.")
            TmsLogMsg("INFO","================================================================================================")
        EndIf

Return .T.

/*/{Protheus.doc} ProcDUD2DLH
    (Processa a migracao dos dados da DUD para a DLH)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ProcDUD2DLH()
 Local cProcName := "DUD2DLH_SP_"+cEmpAnt
 Local lExec     := .T.
 Local nSQLRet   := 0
 Local aResult   := {}
 Local lResult   := .F.

        If !TCSPExist( cProcName )
            lExec := CriaProc()
        EndIf
        If lExec

            //aResult  := TCSPExec(xProcedures(cProcName),nSQLRet)
            nSQLRet := TcSqlExec("EXEC "+ cProcName)
            If nSQLRet < 0 .And. Len(TcSqlError()) > 0
                Help(1," ","TMSDUD2DLH-01",,"Erro encontrado ao executar a procedure SP_DUD2DLH " + ": " + TcSqlError())
                lResult := .F.
            Else
                //| Drop a procedure
                TcSqlExec("DROP PROCEDURE " + cProcName)
                lResult := .T.
            EndIf
        EndIf

Return lResult

//+---------------------------------------------------------------------------
//| Cria procedure para popular a tabela DLH com as informações da DUD
//+---------------------------------------------------------------------------
Static Function CriaProc()
Local cQry    := ""
Local nSQLRes := 0
Local lResult := .T.

        //+-------------------------------------------------------------------
        //| Monta a procedure para popular a tabela DLH - Historico do MDF-e
        //| com as informacoes contidas na tabela DUD - Movimentos da Viagem
        //+-------------------------------------------------------------------
        cQry := getPQuery()
        //| Instala a procedure...
        nSQLRes := TcSQLExec(cQry)
        If nSQLRes <> 0
            If !IsBlind()
                Help(1," ","SP-DUD2DLH-03",,"Erro encontrado ao instalar a procedure SP_DUD2DLH " + ": " + TcSqlError(),4,8)
            Else
                TmsLogMsg("Error"," ### " + "Erro encontrado ao instalar a procedure SP_DUD2DLH " + ": " + TcSqlError())
            EndIf
            lResult := .F.
        EndIf

Return lResult

//+---------------------------------------------------------------------------
//| Monta PL/SQL - procedure que será instalada para popular a tabela DLH 
//| com as informações da DUD.
//+---------------------------------------------------------------------------
Static Function getPQuery()
 Local cResult     := ""
 Local nMaxInserts := 8*1024 //--4096 inserts por ciclo
 Local cProcName   := "DUD2DLH_SP_"+cEmpAnt
 Local lDUDCmpEmp  := ( FWModeAccess('DUD',1) == "C" ) //| Indica o nível a ser avaliado (1=Empresa, 2=Unidade de Negócio e 3=Filial)   
 Local lDUDCmpUni  := ( FWModeAccess('DUD',2) == "C" )
 Local lDUDCmpFil  := ( FWModeAccess('DUD',3) == "C" )
 Local lDLHCmpEmp  := ( FWModeAccess('DLH',1) == "C" )
 Local lDLHCmpUni  := ( FWModeAccess('DLH',2) == "C" )
 Local lDLHCmpFil  := ( FWModeAccess('DLH',3) == "C" )

    cResult := "CREATE PROCEDURE " + cprocName + " AS " + CRLF
    cResult += "  DECLARE @IDLHREC         INTEGER " + CRLF
    cResult += "  DECLARE @IMAXENTRIES     INTEGER " + CRLF
    cResult += "  DECLARE @ITOTAL_DUD_REC  INTEGER " + CRLF
    cResult += "  DECLARE @IEXISTDLH       INTEGER " + CRLF
    cResult += "  DECLARE @IPROCESSED      INTEGER " + CRLF
    cResult += "  DECLARE @ITOTAL_INSERTS  INTEGER " + CRLF
    cResult += "BEGIN " //--BEGIN 1
    cResult += "    SET @IMAXENTRIES = " + AllTrim(Str(nMaxInserts)) + " " + CRLF
    cResult += "    SET @IPROCESSED  = 0 " + CRLF
	 
    cResult += "    SET @ITOTAL_DUD_REC = (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("DUD") + ") " + CRLF
    cResult += "    SET @IEXISTDLH  = (SELECT COUNT(1) FROM " + RetSqlName("DLHT") + " WHERE D_E_L_E_T_ = ' ' AND DLH_FILIAL = '"  + IIF(lDLHCmpFil,xFilial("DLH"),' ') + "' ) " + CRLF

    cResult += "    WHILE (@IPROCESSED < @ITOTAL_DUD_REC) " + CRLF
    cResult += "    BEGIN " + CRLF //-- BEGIN WHILE
    cResult += "        SET @IDLHREC     = ( SELECT COALESCE(MAX(R_E_C_N_O_),0) FROM " + RetSqlName("DLH") + ") " + CRLF
    cResult += "        BEGIN TRANSACTION recdlh "  + CRLF //--BEGIN TRANSACTION
    cResult += "        INSERT INTO DLHT10(DLH_FILIAL,DLH_FILORI,DLH_VIAGEM,DLH_FILMAN,DLH_MANIFE,DLH_SERMAN,DLH_FILDOC,DLH_DOC,DLH_SERIE,R_E_C_N_O_) " + CRLF
    cResult += "        SELECT " + CRLF
    
    //| Se DUD e DLH são exclusívas considera a filial da DLH igual ao do DUD
    If !lDLHCmpFil .And. !lDUDCmpFil
        cResult += "        DUD.DUD_FILIAL, " + CRLF
    //| Se somente o DLH for Exclusiva
    ElseIf !lDLHCmpFil
        cResult += "    DUD.DUD_FILMAN, " + CRLF //| Considera o DUD_FILMAN já que a DLH só existe mediante o manifesto.
    //| DUD e DLH compartilhados
    Else
        cResult += " '" + Space(GetSx3Cache("DLH_FILIAL","X3_TAMANHO")) + "', " + CRLF 
    EndIf

    cResult += "        DUD.DUD_FILORI, " + CRLF
    cResult += "        DUD.DUD_VIAGEM, " + CRLF
    cResult += "        DUD.DUD_FILMAN, " + CRLF
    cResult += "        DUD.DUD_MANIFE, " + CRLF
    cResult += "        DUD.DUD_SERMAN, " + CRLF
    cResult += "        DUD.DUD_FILDOC, " + CRLF
    cResult += "        DUD.DUD_DOC, " + CRLF
    cResult += "        DUD.DUD_SERIE, " + CRLF
    cResult += "        (@IDLHREC + (ROW_NUMBER() over (order by (select NULL)))) AS RECNUM " + CRLF
    cResult += "        FROM " + CRLF
    cResult += "        " + RetSqlName("DUD") + " DUD WHERE " + CRLF
    cResult += "        DUD.D_E_L_E_T_ = ' '
    cResult += "        AND DUD.DUD_FILIAL = '" + IIF(lDUDCmpFil,xFilial("DUD"),' ') + "' " + CRLF
    cResult += "        AND DUD.DUD_FILDOC > ' ' " + CRLF
    cResult += "        AND DUD.DUD_DOC    > ' ' " + CRLF
    cResult += "        AND DUD.DUD_SERIE  > ' ' " + CRLF
    cResult += "        AND DUD.DUD_FILORI > ' ' " + CRLF
    cResult += "        AND DUD.DUD_VIAGEM > ' ' " + CRLF
    cResult += "        AND DUD.DUD_FILMAN > ' ' " + CRLF
    cResult += "        AND DUD.DUD_MANIFE > ' ' " + CRLF
    cResult += "        AND DUD.R_E_C_N_O_ > @IPROCESSED AND DUD.R_E_C_N_O_ <= @IPROCESSED + @IMAXENTRIES " + CRLF
    cResult += "        AND (@IEXISTDLH = 0 OR NOT EXISTS(SELECT 1 FROM " + RetSqlName("DLH") + " DLH WHERE DLH.D_E_L_E_T_ = ' ' " + CRLF
    cResult += "            AND DLH.DLH_FILIAL = '" + IIF(lDLHCmpFil,xFilial("DLH"),' ') + "' " + CRLF
    cResult += "            AND DLH.DLH_FILORI = DUD.DUD_FILORI " + CRLF
    cResult += "            AND DLH.DLH_VIAGEM = DUD.DUD_VIAGEM " + CRLF
    cResult += "            AND DLH.DLH_FILDOC = DUD.DUD_FILDOC " + CRLF
    cResult += "            AND DLH.DLH_DOC = DUD.DUD_DOC " + CRLF
    cResult += "            AND DLH.DLH_SERIE = DUD.DUD_SERIE " + CRLF
    cResult += "            AND DLH.DLH_FILMAN = DUD.DUD_FILMAN " + CRLF
    cResult += "            AND DLH.DLH_MANIFE = DUD.DUD_MANIFE)) " + CRLF
			
    cResult += "        COMMIT TRANSACTION recdlh " + CRLF
    //cResult += "        @ITOTAL_INSERTS = @ITOTAL_INSERTS + SQL%ROWCOUNT " + CRLF
    cResult += "        SET @IPROCESSED = @IPROCESSED + @IMAXENTRIES " + CRLF
    cResult += "    END	 " + CRLF //-- BEGIN WHILE

    cResult += "END " //-- TERMINO BEGIN 1
        
Return cResult