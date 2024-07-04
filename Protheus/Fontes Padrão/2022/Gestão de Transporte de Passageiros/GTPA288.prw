#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA288()


@sample GTPR283A()

@author Renan Ribeiro Brando
@since 21/08/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA288()
Local cParam  := "%%"
Local nParam  := 0 
Local oModel 
Local oModelGQY 
Local oGridGQW 
Local cAliasGQW := GetNextAlias()
Local cClient := ""
Local cStore := ""
Local lRet := .T.
Local lHeader := .F.

// caso o usuário não cancele a ação
IF (Pergunte("GTPA288", .T., "Geração de Lotes em Massa"))
    cParam := "%"
    cParam += IIF(EMPTY(MV_PAR01), "", " AND GQW.GQW_CODCLI >= '" + cValToChar(MV_PAR01) + "' ") // Cliente de?
    cParam += IIF(EMPTY(MV_PAR03), "", " AND GQW.GQW_CODCLI <= '" + cValToChar(MV_PAR03) + "' ") // Cliente até? 
    cParam += IIF(EMPTY(MV_PAR02), "", " AND GQW.GQW_CODLOJ >= '" + cValToChar(MV_PAR02) + "' ") // Loja de?
    cParam += IIF(EMPTY(MV_PAR04), "", " AND GQW.GQW_CODLOJ <= '" + cValToChar(MV_PAR04) + "' ") // Loja até?
    cParam += IIF(EMPTY(MV_PAR05), "", " AND GQW.GQW_DATEMI >= '" + DTOS(MV_PAR05) + "' ") // Data de?
    cParam += IIF(EMPTY(MV_PAR06), "", " AND GQW.GQW_DATEMI <= '" + DTOS(MV_PAR06) + "' ")// Data até?
    cParam += "%"
    nParam := MV_PAR07 // Gera Pedido?

    
    IF !(EMPTY(cParam))
        // Consulta que traz todas requisições que podem ser adicionadas em um lote
        BeginSQL Alias cAliasGQW
            SELECT  GQW.GQW_CODIGO,
                    GQW.GQW_CODCLI,
                    GQW.GQW_CODLOJ,
                    GQW.GQW_TOTAL,
                    GQW.GQW_STATUS,
                    GQW.GQW_CONFER,
                    GQW.GQW_CODLOT
            FROM    %TABLE:GQW% GQW 
            WHERE   GQW.GQW_FILIAL = %xFilial:GQW%
                    AND GQW.%NotDel% 
                    AND GQW.GQW_CONFER =  '1' // Requisições conferidas 
                    AND GQW.GQW_STATUS != '1' // Não baixadas 
                    AND GQW.GQW_CODLOT =  ''  // Sem vínculos a nenhum lote  
                    %Exp:cParam% 
            ORDER BY GQW.GQW_CODCLI,
                    GQW.GQW_CODLOJ 
        EndSQL
        
        cClient := (cAliasGQW)->GQW_CODCLI 
        cStore  := (cAliasGQW)->GQW_CODLOJ

        WHILE ((cAliasGQW)->(!Eof()))
            IF (!lHeader) 
                oModel := FWLoadModel("GTPA284")
                oModelGQY := oModel:GetModel("FIELDGQY")
                oGridGQW := oModel:GetModel("GRIDGQW")
                oModel:SetOperation(MODEL_OPERATION_INSERT)
                oModel:Activate()      
                oModelGQY:SetValue("GQY_CODIGO", GetSXEnum("GQY"))
                oModelGQY:SetValue("GQY_DESCRI", "LOT" + AllTrim((cAliasGQW)->GQW_CODIGO) + "/")
                oModelGQY:SetValue("GQY_CODCLI", (cAliasGQW)->GQW_CODCLI)
                oModelGQY:SetValue("GQY_CODLOJ", (cAliasGQW)->GQW_CODLOJ)
                oModelGQY:SetValue("GQY_DTFECH", dDatabase) 
                lHeader := .T.
            ENDIF 
                
                IF ( !Empty(oGridGQW:GetValue("GQW_CODIGO")) .OR. oGridGQW:IsDeleted() )
                    oGridGQW:AddLine()
                ENDIF

                oGridGQW:SetValue("GQW_CODIGO", (cAliasGQW)->GQW_CODIGO)

            (cAliasGQW)->(DbSkip())

            IF (cAliasGQW)->(eof()) .OR. (cClient != (cAliasGQW)->GQW_CODCLI .OR. cStore != (cAliasGQW)->GQW_CODLOJ)
                oModelGQY:SetValue("GQY_DESCRI", AllTrim(oModelGQY:GetValue("GQY_DESCRI")) + AllTrim((cAliasGQW)->GQW_CODIGO))
                // Commit do model    
                IF (lRet := oModel:VldData())
                    lRet := oModel:CommitData()
                    IF (lRet .AND. nParam == 1)
                        lRet := GA284IntFat(/*lEstorno*/,.F.)
                    ENDIF
                ELSE
                    oModel:GetModel():SetErrorMessage(oModel:GetModel():GetId(),,oModel:GetModel():GetId(),,"Existem inconsistências nas requsições do lote " + oModelGQY:GetValue("GQY_DESCRI"), "Verifique o range de requisições contido no lote.", "Erro ao Gerar o Lote")
                    GA284SetLog("MVC")
                ENDIF

                IF (!lRet)
                    GA289SetLog()
                    GA284ResetLog() //reinicia o log para o processamento do próximo lote
                ENDIF    

                cClient := (cAliasGQW)->GQW_CODCLI 
                cStore  := (cAliasGQW)->GQW_CODLOJ 
                lHeader := .F.
                oModel:Deactivate()  
                oModel:Destroy()
            ENDIF
        END

        (cAliasGQW)->(DbCloseArea())

        
    ELSE
        MSGSTOP("Preencha todos os campos do filtro.", "Erro")
        GTPA288()
    ENDIF

ENDIF

IF (!lRet .AND. LEN(GA289GetLog()) > 0)
    GA289LogArchive()
    FwAlertInfo("O processamento, finalizou, mas ocorreram problemas." + Alltrim(GA289GetPath()), "Para maiores informações, consulte os arquivos de log gerados através do diretório") //"O processamento, finalizou, mas ocorreram problemas." //"Para maiores informações, consulte os arquivos de log gerados através do diretório "
ELSE		
	FwAlertInfo("Processamento finalizado com sucesso!","Finalizado")
ENDIF	

Return lRet

