//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRMig01
Relatório com os status de processamento do Migrador
@author  Victor A. Barbosa
@since   30/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAFRMig01()

Local aParamBox := {}
Local aRetParam := {}

aAdd( aParamBox, { 5, "Pendente"            , .T., 80, '.T.', .T.} )
aAdd( aParamBox, { 5, "Processado Com erros", .T., 80, '.T.', .T.} )
aAdd( aParamBox, { 5, "Processado Sem erros", .T., 80, '.T.', .T.} )

If ParamBox(aParamBox, "Parâmetros", @aRetParam)
    FWMsgRun(, {|oSay| RMigr01Proc(oSay, aRetParam) }, "Aguarde", "Gerando Relatório...")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RMigr01Proc
Encapsula as funções de processamento
@author  Victor A. Barbosa
@since   30/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function RMigr01Proc(oSay, aRetParam)

Local cAliasTot := ""
Local cAliasDet := ""
Local cInParam  := ""

oSay:cCaption := "Filtrando Registros"
ProcessMessages()

If aRetParam[1]
    cInParam += " '1', '2', '3' "
EndIf

If aRetParam[2]
    If Empty(cInParam)
        cInParam += " '6' "
    Else
        cInParam += " ,'6' "
    EndIf
EndIf

If aRetParam[3]
    If Empty(cInParam)
        cInParam += " '5' "
    Else
        cInParam += " ,'5' "
    EndIf
EndIf

cInParam := "%(" + cInParam + ")%"

cAliasTot   := RMigr01Tot(cInParam)
cAliasDet   := RMigr01Det(cInParam)

RMigr01Print(cAliasTot, cAliasDet, oSay)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RMigr01Tot
Disponibiliza o arquivo de trabalho "sintético"
@author  Victor A. Barbosa
@since   30/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function RMigr01Tot(cInParam)

Local aArea     := GetArea()
Local cAliasTot := "rsMigrTOT"

If Select(cAliasTot) > 0
    (cAliasTot)->( dbCloseArea() )
EndIf

BeginSQL Alias cAliasTot
    SELECT V2A_STATUS, COUNT(V2A_STATUS) AS TOTAL, V2A_EVENTO FROM %table:V2A% V2A
    WHERE   V2A_STATUS IN %exp:cInParam%
    AND     V2A.%notdel% 
    GROUP BY V2A_STATUS, V2A_EVENTO 
    ORDER BY V2A_EVENTO
EndSQL

RestArea(aArea)

Return(cAliasTot)

//-------------------------------------------------------------------
/*/{Protheus.doc} RMigr01Det
Disponibiliza o arquivo de trabalho "analítico"
@author  Victor A. Barbosa
@since   30/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function RMigr01Det(cInParam)

Local aArea     := GetArea()
Local cAliasDet := "rsMigrDET"

If Select(cAliasDet) > 0
    (cAliasDet)->( dbCloseArea() )
EndIf

BeginSQL Alias cAliasDet
    SELECT V2A_FILDES, V2A_EVENTO, V2A_CHVGOV, V2A_STATUS, V2A_RECIBO, V2A_CNPJ, V2A_RECEXC, V2A.R_E_C_N_O_ AS V2ARECNO FROM %table:V2A% V2A
    WHERE V2A_STATUS IN %exp:cInParam%
    AND V2A.%notdel%
    ORDER BY V2A_EVENTO
EndSQL

RestArea(aArea)

Return(cAliasDet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RMigr01Print
Efetua a impressão do relatório
@author  Victor A. Barbosa
@since   30/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function RMigr01Print(cAliasTot, cAliasDet, oSay)

Local oExcel 	:= FWMSExcel():New()
Local oExcelApp	:= Nil
Local cAbaTot	:= "Totais"
Local cAbaDet   := "Detalhes"
Local cTabela	:= "Registros"
Local cArquivo	:= "migrador_" + DTOS(Date()) + "_" + StrTran(Time(), ":", "") + ".xls"
Local cPath		:= cGetFile( "Diretório" + "|*.*", "Procurar", 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )
Local cDefPath	:= GetSrvProfString( "StartPath", "\system\" )
Local nQtdRegs  := 0
Local nQtdExec  := 0
Local cErro		:= "" 

oExcel:AddWorkSheet(cAbaTot)
oExcel:AddTable(cAbaTot, cTabela)

oExcel:AddColumn(cAbaTot, cTabela, "Evento"		                , 1, 1, .F.)
oExcel:AddColumn(cAbaTot, cTabela, "Status"		                , 1, 1, .F.)
oExcel:AddColumn(cAbaTot, cTabela, "Quantidade de Registros"	, 1, 1, .F.)

oExcel:AddWorkSheet(cAbaDet)
oExcel:AddTable(cAbaDet, cTabela)

oExcel:AddColumn(cAbaDet, cTabela, "Filial"		            , 1, 1, .F.)
oExcel:AddColumn(cAbaDet, cTabela, "Evento"		            , 1, 1, .F.)
oExcel:AddColumn(cAbaDet, cTabela, "XML Id"		            , 1, 1, .F.)
oExcel:AddColumn(cAbaDet, cTabela, "Status"		            , 1, 1, .F.)
oExcel:AddColumn(cAbaDet, cTabela, "Recibo"		            , 1, 1, .F.)
oExcel:AddColumn(cAbaDet, cTabela, "CNPJ"		            , 1, 1, .F.)
oExcel:AddColumn(cAbaDet, cTabela, "Recibo Exclusão"        , 1, 1, .F.)
oExcel:AddColumn(cAbaDet, cTabela, "Erro"                   , 1, 1, .F.)

(cAliasDet)->( dbEval( {||nQtdRegs++} ) )
(cAliasTot)->( dbGoTop() )
While (cAliasTot)->( !Eof() )

    nQtdExec++
    SetIncPerc( oSay, "1", nQtdRegs, nQtdExec )

    oExcel:AddRow(cAbaTot,;
				  cTabela,;
                  { (cAliasTot)->V2A_EVENTO,;
                    GetStatus( (cAliasTot)->V2A_STATUS ),;
                    (cAliasTot)->TOTAL})

    (cAliasTot)->( dbSkip() )

EndDo

nQtdRegs := 0
nQtdExec := 0
(cAliasDet)->( dbEval( {||nQtdRegs++} ) )

(cAliasDet)->( dbGoTop() )
While (cAliasDet)->( !Eof() )

    nQtdExec++
    SetIncPerc( oSay, "2", nQtdRegs, nQtdExec )

    V2A->( dbGoTo( (cAliasDet)->V2ARECNO ) )
    
    cErro := STRTRAN(AllTrim(V2A->V2A_ERRO),"<","'")
    cErro := STRTRAN(cErro,">","'")

    oExcel:AddRow(cAbaDet,;
				  cTabela,;
                  { (cAliasDet)->V2A_FILDES,;
                    (cAliasDet)->V2A_EVENTO,;
                    (cAliasDet)->V2A_CHVGOV,;
                    GetStatus( (cAliasDet)->V2A_STATUS ),;
                    (cAliasDet)->V2A_RECIBO,;
                    (cAliasDet)->V2A_CNPJ,;
                    (cAliasDet)->V2A_RECEXC,;
                    cErro })

    (cAliasDet)->( dbSkip() )

EndDo

If !Empty(oExcel:aWorkSheet)

    oExcel:Activate()
    oExcel:GetXMLFile(cArquivo)
 
    CpyS2T(cDefPath+cArquivo, cPath)

    FErase(cDefPath+cArquivo)

    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre a planilha
    oExcelApp:SetVisible(.T.)

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Retorna a descrição do status
@author  Victor A. Barbosa
@since   31/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function GetStatus(cStatus)

Local cDescrStatus := ""

Do Case
    Case cStatus == "1"
        cDescrStatus := "1 - Pendente (Somente XML)"
    Case cStatus == "2"
        cDescrStatus := "2 - Pendente (Somente Recibo)"
    Case cStatus == "3"
        cDescrStatus := "3 - Pendente (Completo)"
    Case cStatus == "4"
        cDescrStatus := "4 - XML Integrado (Sem Recibo)"
    Case cStatus == "5"
        cDescrStatus := "5 - XML + Recibo Integrado (Com Recibo)"
    Case cStatus == "6"
        cDescrStatus := "6 - Erro na Integração"
EndCase

Return(cDescrStatus)

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIncPerc
@type			function
@description	Incrementa o progresso realizado.
@author			Felipe C. Seolin
@since			04/09/2018
@version		1.0
@param			oMsgRun		-	Objeto do FWMsgRun
@param			cEtapa		-	Etapa em curso de execução
@param			nQtdTotal	-	Quantidade total de registros a processar
@param			nQtdProc	-	Quantidade de registros processados
/*/
//---------------------------------------------------------------------
Function SetIncPerc( oMsgRun, cEtapa, nQtdTotal, nQtdProc )

Local cMessage	:=	""
Local cPercent	:=	cValToChar( Int( ( nQtdProc / nQtdTotal ) * 100 ) )

If cEtapa == "1"
    cMessage := I18N( "#1 #2 #3 - Progresso: #4%", { "Gerando", "dados", "Sintéticos", cPercent } )
ElseIf cEtapa == "2"
    cMessage := I18N( "#1 #2 #3 - Progresso: #4%", { "Gerando", "dados", "Analíticos", cPercent } )
ElseIf cEtapa == "3"
    cMessage := I18N( "#1 #2 #3 - Progresso: #4%", { "Processando", "XMLs", "Totalizadores", cPercent } )
EndIf

oMsgRun:cCaption := cMessage
ProcessMessages()

Return()