#INCLUDE "PROTHEUS.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "CNTXFIX.CH"

/*/{Protheus.doc} GCTAjMtBon
//Ajusta os campos de multas/bonificações das medições
@author juan.felipe
@since 23/09/2020
@version 12
@return Nil
/*/
Function GCTAjMtBon()
	Local oProcess As Object
	Local nOpc As Numeric
    Local cMsg As Character

    If !FwIsInCallStack('GCT029Ajus')
        nOpc := Aviso(STR0016 /*Atenção*/, STR0017, {STR0013/*Processar*/, STR0014/*Imprimir*/,STR0015/*Cancelar*/}, 2) //-- STR0017 - Essa rotina tem como objetivo efetuar ajustes nas tabelas CND (Cabeçalho Medição de Contratos), CXN (Planilha Med. de Contratos) e CNE (Itens da Medição de Contratos ), compatibilizando os campos de Multa/Bonificação (CND_VLMPED, CND_VLBPED, CXN_VLMPED, CXN_VLBPED, CNE_VLMPED e CNE_VLBPED).
        cMsg := IIf(nOpc == 2, STR0018/*Impressão*/, STR0019/*Atualização*/)

        If nOpc <> 3
            oProcess := MsNewProcess():New({|| AjustMtBon(@oProcess, nOpc) }, cMsg + STR0020) //-- Impressão/Atualização de Multas/Bonficações das Medições","Lendo Itens (CNE)
            oProcess:Activate()
        Endif
    Else
        AjustMtBon(Nil, 1)
    EndIf
Return

/*/{Protheus.doc} GCTAjMtBon
//Ajusta os campos de multas/bonificações das medições
@author juan.felipe
@since 23/09/2020
@version 12
@param oProcess, MsNewProcess, objeto que exibe tela de carregamento
@param nOpc, Numeric, opção selecionada, 1 - Processa atualização, 2 - Imprime relatório
@return Nil
/*/
Static Function AjustMtBon(oProcess, nOpc)
    Local aAreas         := {}
	Local lRet 	         := .T.
    Local cAliasItem     := ""
    LocaL lCposCND       := CND->(FieldPos("CND_VLMPED")) > 0 .And. CND->(FieldPos("CND_VLBPED")) > 0
    Local lCposCXN       := CXN->(FieldPos("CXN_VLMPED")) > 0 .And. CXN->(FieldPos("CXN_VLBPED")) > 0
    Local lCposCNE       := CNE->(FieldPos("CNE_VLMPED")) > 0 .And. CNE->(FieldPos("CNE_VLBPED")) > 0
    Local lCposMBPed     := lCposCND .And. lCposCXN .And. lCposCNE
    Private _nTotAtu     := 0
    Private _nQtdPlan    := 0
    Private _nQtdItem    := 0
    Private _cAliasPlan  := ""
	Default oProcess     := Nil 
	Default nOpc         := 1

    If lCposMBPed
	    aAreas	     := {CND->(GetArea()), CXN->(GetArea()), CNE->(GetArea()), GetArea()}
        cAliasItem   := GetNextAlias()
	    _cAliasPlan := GetNextAlias()

        If oProcess <> Nil
            oProcess:SetRegua1(2)
        EndIf

        BeginSQL Alias cAliasItem //-- Multas/Bonificações do Item (CNE)
            SELECT
                CNR.CNR_FILIAL,
                CNR.CNR_NUMMED,
                CNR.CNR_CONTRA,
                CNR.CNR_CODPLA,
                CNR.CNR_ITEM,
                CNE.R_E_C_N_O_ AS CNE_RECNO,
                SUM(CNR.CNR_VALOR) AS TOTMULTA,
                                    0 AS TOTBONI
            FROM %Table:CNR% CNR
            INNER JOIN %Table:CNE% CNE ON
                CNE.CNE_FILIAL = CNR.CNR_FILIAL
                AND CNE.CNE_CONTRA = CNR.CNR_CONTRA 
                AND CNE.CNE_NUMMED = CNR.CNR_NUMMED
                AND CNE.CNE_NUMERO = CNR.CNR_CODPLA
                AND CNE.CNE_ITEM = CNR.CNR_ITEM
                AND CNE.CNE_VLMPED = 0
                AND CNE.CNE_VLBPED = 0
                AND (CNE.CNE_MULTA > 0 OR CNE.CNE_BONIF > 0)
                AND CNE.%NotDel%
            WHERE 
                CNR.CNR_FLGPED = %Exp:'1'%
                AND CNR.CNR_TIPO = %Exp:'1'%
                AND CNR.CNR_VALOR > 0
                AND CNR.CNR_ITEM <> %Exp:' '%
                AND CNR.%NotDel%
            GROUP BY 
                CNR_FILIAL,
                CNR_NUMMED,
                CNR_CONTRA,
                CNR_CODPLA,
                CNR_ITEM,
                CNE.R_E_C_N_O_
            UNION
            SELECT
                CNR.CNR_FILIAL,
                CNR.CNR_NUMMED,
                CNR.CNR_CONTRA,
                CNR.CNR_CODPLA,
                CNR.CNR_ITEM,
                CNE.R_E_C_N_O_ AS CNE_RECNO,
                            0 AS TOTMULTA,
                SUM(CNR.CNR_VALOR) AS TOTBONI
            FROM %Table:CNR% CNR
            INNER JOIN %Table:CNE% CNE ON
                CNE.CNE_FILIAL = CNR.CNR_FILIAL
                AND CNE.CNE_CONTRA = CNR.CNR_CONTRA 
                AND CNE.CNE_NUMMED = CNR.CNR_NUMMED
                AND CNE.CNE_NUMERO = CNR.CNR_CODPLA
                AND CNE.CNE_ITEM = CNR.CNR_ITEM
                AND CNE.CNE_VLMPED = 0
                AND CNE.CNE_VLBPED = 0
                AND (CNE.CNE_MULTA > 0 OR CNE.CNE_BONIF > 0)
                AND CNE.%NotDel%
            WHERE 
                CNR.CNR_FLGPED = %Exp:'1'%
                AND CNR.CNR_TIPO = %Exp:'2'%
                AND CNR.CNR_VALOR > 0
                AND CNR.CNR_ITEM <> %Exp:' '%
                AND CNR.%NotDel%
            GROUP BY 
                CNR_FILIAL,
                CNR_NUMMED,
                CNR_CONTRA,
                CNR_CODPLA,
                CNR_ITEM,
                CNE.R_E_C_N_O_
        EndSql

        If oProcess <> Nil
            Count To _nQtdItem //-- Conta quantidade de registros retornados pela query
            _nTotAtu := _nQtdItem
            (cAliasItem)->(dbGoTop())

            oProcess:IncRegua1(STR0021) //-- Lendo Planilhas
        EndIf

        BeginSQL Alias _cAliasPlan //-- Multas/Bonificações da Planilha (CXN)
            SELECT
                CXN.CXN_FILIAL,
                CXN.CXN_NUMMED,
                CXN.CXN_NUMPLA,
                CXN.CXN_CONTRA,
                CXN.CXN_REVISA,
                CXN.R_E_C_N_O_ CXN_RECNO,
                SUM(CNR.CNR_VALOR) AS TOTMULTA,
                                0 AS TOTBONI
            FROM %Table:CNR% CNR
            INNER JOIN %Table:CXN% CXN ON
                CXN.CXN_FILIAL = CNR.CNR_FILIAL
                AND CXN.CXN_CONTRA = CNR.CNR_CONTRA
                AND CXN.CXN_NUMMED = CNR.CNR_NUMMED
                AND CXN.CXN_NUMPLA = CNR.CNR_CODPLA
                AND CXN.CXN_VLMPED = 0
                AND CXN.CXN_VLBPED = 0
                AND (CXN.CXN_VLMULT > 0 OR CXN.CXN_VLBONI > 0)
                AND CXN.%NotDel%
            WHERE 
                CNR.CNR_FLGPED = %Exp:'1'%
                AND CNR.CNR_TIPO = %Exp:'1'%
                AND CNR.CNR_VALOR > 0
                AND CNR.%NotDel%
            GROUP BY 
                CXN_FILIAL,
                CXN_NUMMED,
                CXN_NUMPLA,
                CXN_CONTRA,
                CXN_REVISA,
                CXN.R_E_C_N_O_
            UNION
            SELECT
                CXN.CXN_FILIAL,
                CXN.CXN_NUMMED,
                CXN.CXN_NUMPLA,
                CXN.CXN_CONTRA,
                CXN.CXN_REVISA,
                CXN.R_E_C_N_O_ CXN_RECNO,
                                0 AS TOTMULTA,
                SUM(CNR_VALOR) AS TOTBONI
            FROM %Table:CNR% CNR
            INNER JOIN %Table:CXN% CXN ON
                CXN.CXN_FILIAL = CNR_FILIAL
                AND CXN.CXN_CONTRA = CNR.CNR_CONTRA
                AND CXN.CXN_NUMMED = CNR.CNR_NUMMED
                AND CXN.CXN_NUMPLA = CNR.CNR_CODPLA
                AND CXN.CXN_VLMPED = 0
                AND CXN.CXN_VLBPED = 0
                AND (CXN.CXN_VLMULT > 0 OR CXN.CXN_VLBONI > 0)
                AND CXN.%NotDel%
            WHERE 
                CNR.CNR_FLGPED = %Exp:'1'%
                AND CNR.CNR_TIPO = %Exp:'2'%
                AND CNR.CNR_VALOR > 0
                AND CNR.%NotDel%
            GROUP BY 
                CXN_FILIAL,
                CXN_NUMMED,
                CXN_NUMPLA,
                CXN_CONTRA,
                CXN_REVISA,
                CXN.R_E_C_N_O_
        EndSql


        If oProcess <> Nil
            Count To _nQtdPlan //-- Conta quantidade de registros retornados pela query
            _nTotAtu += _nQtdPlan
            (_cAliasPlan)->(dbGoTop())

            oProcess:IncRegua1(STR0022 + AllTrim(str(_nTotAtu))+ STR0023) //-- Serão processados x registros
            oProcess:SetRegua2(_nTotAtu)

            If _nTotAtu == 0
                Alert(STR0024) //-- Nenhum registro encontrado para processamento
                lRet := .F. 
            EndIf
        EndIf

        If lRet
            If nOpc == 1 //-- Processa atualização
                AtuMultBon(oProcess, cAliasItem, _cAliasPlan)
            ElseIf nOpc == 2 
                ImpRelMult() //-- Imprime relatório
            EndIf
        EndIf

        (cAliasItem)->(DbCloseArea())
        (_cAliasPlan)->(DbCloseArea())
        aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
    EndIf
Return lRet

/*/{Protheus.doc} ImpRel
// Executa a tela de impressão do relatório
@author juan.felipe
@since 23/09/2020
@version 12
@return Nil
*/
static Function ImpRelMult()
	Local oReport As Object

	oReport := RepDefMult()
	oReport:PrintDialog()
Return

/*/{Protheus.doc} RepDefMult
// Define o objeto TReport para impressão das medições
@author juan.felipe
@since 23/09/2020
@version 12
@return Nil
*/
Static Function RepDefMult()
	Local oReport As Object
	Local oSection As Object

	oReport:= TReport():New("CNTXFIX",STR0025 /*Fix para Multas/Bonficações das Medições*/,, {|oReport| RepPrMult(oReport)},OemToAnsi(STR0026 /*Este relatório imprime uma relação dos ajustes que são efetuados nas tabelas CND (Cabeçalho Medição de Contratos) CXN (Planilha Med. de Contratos) CNE (Itens da Medição de Contratos).*/))
	oSection := TRSection():New(oReport,,{"CXN"})
	oSection:SetHeaderPage()

	TRCell():New(oSection,"CXN_FILIAL", "CXN")
	TRCell():New(oSection,"CXN_NUMMED", "CXN")
	TRCell():New(oSection,"CXN_CONTRA", "CXN")
	TRCell():New(oSection,"CXN_REVISA", "CXN")
Return(oReport)

/*/{Protheus.doc} ImpRel
// Realiza impressão das medições que serão modificadas
@author juan.felipe
@since 23/09/2020
@version 12
@param oReport, TReport, objeto utilizado para impressão das linhas
@return Nil
*/
Static Function RepPrMult(oReport)
	Local oSection  := oReport:Section(1)
    Local cChave    := ""
	Local nMedRec   := 0

	oReport:SetMeter(_nQtdPlan)
	oSection:Init()

	While !(_cAliasPlan)->(Eof())

        If cChave != (_cAliasPlan)->CXN_FILIAL + (_cAliasPlan)->CXN_NUMMED .And. nMedRec != (_cAliasPlan)->CXN_RECNO //-- Tratamento para listar apenas uma vez cada planilha
            oSection:Cell("CXN_FILIAL"):SetValue((_cAliasPlan)->CXN_FILIAL)
            oSection:Cell("CXN_NUMMED"):SetValue((_cAliasPlan)->CXN_NUMMED)
            oSection:Cell("CXN_CONTRA"):SetValue((_cAliasPlan)->CXN_CONTRA)
            oSection:Cell("CXN_REVISA"):SetValue((_cAliasPlan)->CXN_REVISA)

            oSection:PrintLine()
            cChave := (_cAliasPlan)->CXN_FILIAL + (_cAliasPlan)->CXN_NUMMED
            nMedRec := (_cAliasPlan)->CXN_RECNO
        EndIf
        
        oReport:IncMeter()
		(_cAliasPlan)->(dbSkip())
	EndDo

	oSection:Finish()
Return NIL

/*/{Protheus.doc} AtuMultBon
// Processa atualização dos campos de multa/bonificação
@author juan.felipe
@since 23/09/2020
@version 12
@param oProcess, MsNewProcess, objeto que exibe tela de carregamento
@cAliasItem, Character, Alias dos itens da medição
@cAliasPlan, Character, Alias da planilha da medição
@return Nil
*/
Static function AtuMultBon(oProcess, cAliasItem, cAliasPlan)
	Local cAliasCab  := GetNextAlias()
    Local nCont      := 1
    Default oProcess := Nil

    If oProcess <> Nil
        oProcess:SetRegua1(3)
        oProcess:SetRegua2(_nQtdItem)
        oProcess:IncRegua1(STR0027) //-- Processando Itens
    EndIf

    Begin Transaction //-- Atualiza CNE_VLMPED e CNE_VLBPED
        While !(cAliasItem)->(Eof())
            CNE->(dbGoTo((cAliasItem)->CNE_RECNO))
            RecLock("CNE",.F.)
            If (cAliasItem)->TOTMULTA > 0
                CNE->CNE_VLMPED := (cAliasItem)->TOTMULTA
            ElseIf (cAliasItem)->TOTBONI > 0
                CNE->CNE_VLBPED := (cAliasItem)->TOTBONI
            EndIf
            CNE->(MsUnLock())
            (cAliasItem)->(DbSkip())

            If oProcess <> Nil
			    oProcess:IncRegua2(STR0028 + AllTrim(str(nCont)) + STR0029 + AllTrim(str(_nTotAtu))) //-- Processando registro X de XX
		    EndIf
            nCont ++
        EndDo
    End Transaction

    If oProcess <> Nil
        oProcess:SetRegua2(_nQtdPlan)
        oProcess:IncRegua1(STR0030) //-- Processando Planilhas
    EndIf

    Begin Transaction //-- Atualiza CXN_VLMPED e CXN_VLBPED
        While !(cAliasPlan)->(Eof())
            CXN->(dbGoTo((cAliasPlan)->CXN_RECNO))
            RecLock("CXN",.F.)
            If (cAliasPlan)->TOTMULTA > 0
                CXN->CXN_VLMPED := (cAliasPlan)->TOTMULTA
            ElseIf (cAliasPlan)->TOTBONI > 0
                CXN->CXN_VLBPED := (cAliasPlan)->TOTBONI
            EndIf
            CXN->(MsUnLock())
            (cAliasPlan)->(DbSkip())

            If oProcess <> Nil
			    oProcess:IncRegua2(STR0028 + AllTrim(str(nCont)) + STR0029 + AllTrim(str(_nTotAtu))) //-- Processando registro X de XX
		    EndIf
            nCont ++
        EndDo
    End Transaction
    
    If oProcess <> Nil
        oProcess:IncRegua1(STR0031) //-- Processando Medições
    EndIf

    BeginSQL Alias cAliasCab //-- Multas/Bonificações Cabeçalho da Medição (CND)
        SELECT
            CXN.CXN_FILIAL,
            CXN.CXN_CONTRA,
            CXN.CXN_NUMMED,
            SUM(CXN.CXN_VLMPED) TOTMULTA,
            SUM(CXN.CXN_VLBPED) TOTBONI,
            CND.R_E_C_N_O_ CND_RECNO
        FROM %Table:CXN% CXN
        INNER JOIN %Table:CND% CND ON
            CND.CND_FILIAL = CXN.CXN_FILIAL
            AND CND.CND_CONTRA = CXN.CXN_CONTRA
            AND CND.CND_NUMMED = CXN.CXN_NUMMED
            AND CND.%NotDel%
        WHERE
            (CXN.CXN_VLMPED > 0 OR CXN.CXN_VLBPED > 0)
            AND (CXN.CXN_VLMULT > 0 OR CXN.CXN_VLBONI > 0)
            AND CXN.%NotDel%
        GROUP BY 
            CXN_FILIAL,
            CXN_CONTRA,
            CXN_NUMMED,
            CXN_VLMPED,
            CXN_VLBPED,
            CND.R_E_C_N_O_
    EndSql
    
    If oProcess <> Nil
        Count To nQtdMed //-- Conta quantidade de registros retornados pela query
        _nTotAtu += nQtdMed
        (cAliasCab)->(dbGoTop())

        oProcess:SetRegua2(nQtdMed)
    EndIf


    Begin Transaction //-- Atualiza CND_VLMPED e CND_VLBPED
        While !(cAliasCab)->(Eof())
            CND->(dbGoTo((cAliasCab)->CND_RECNO))
            RecLock("CND",.F.)
            CND->CND_VLMPED := (cAliasCab)->TOTMULTA
            CND->CND_VLBPED := (cAliasCab)->TOTBONI
            CND->(MsUnLock())
            (cAliasCab)->(DbSkip())

            If oProcess <> Nil
			    oProcess:IncRegua2(STR0028 + AllTrim(str(nCont)) + STR0029 + AllTrim(str(_nTotAtu))) //-- Processando registro X de XX
		    EndIf
            nCont ++
        EndDo
    End Transaction

	If oProcess <> Nil
		MsgInfo(STR0032) //-- Término do Ajuste.
	EndIf 
Return NIL

/*/{Protheus.doc} GCTAjstCNU
    Processa a correção da tabela Vendedores x Contratos(CNU)
@author philipe.pompeu
@since 24/02/2021
@return Nil, nulo
*/
Function GCTAjstCNU()
	Local oProcess As Object
	Local nOpc As Numeric
    Local cMsg As Character

    If !FwIsInCallStack('GCT029Ajus')
        nOpc := Aviso(STR0016 /*Atenção*/, STR0033, {STR0013/*Processar*/, STR0014/*Imprimir*/,STR0015/*Cancelar*/}, 2) 
        
        cMsg := IIf(nOpc == 2, STR0018/*Impressão*/, STR0019/*Atualização*/)

        If nOpc <> 3
            oProcess := MsNewProcess():New({|| FixCNU(@oProcess, nOpc) }, cMsg + STR0034) //-- Impressão/Atualização
            oProcess:Activate()
        Endif
    ElseIf CNURevisa() //Somente executa caso o campo CNU_REVISA exista e esteja no X2_UNICO da tabela
        FixCNU(Nil, 1)
    EndIf
Return Nil

/*/{Protheus.doc} FixCNU
    Processa a escolha do usuário realizada na função <GCTAjstCNU>
@author philipe.pompeu
@since 24/02/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return lRet, lógico, verdadeiro caso possa ser processado
*/
Static Function FixCNU(oProcess, nOpc)
    Local aAreas         := {}
	Local lRet 	         := .T.
	Default oProcess     := Nil 
	Default nOpc         := 1

    If (CNU->(ColumnPos('CNU_REVISA') > 0) .And. X3Uso(GetSx3Cache('CNU_REVISA', 'X3_USADO')))	   
        aAreas	:= {CN9->(GetArea()), CNU->(GetArea()), GetArea()}       

        If oProcess <> Nil
            oProcess:SetRegua1(1)            
            oProcess:IncRegua1(IIF(nOpc == 1, STR0036, STR0018))
        EndIf

        If (nOpc == 1) //-- Processa atualização            
            ProcFixCNU(oProcess)//Processa ajuste CNU
        ElseIf (nOpc == 2 .AND. oProcess <> Nil)
            CNUReport(oProcess)
        EndIf
        
        aEval(aAreas, {|x| RestArea(x) })
        FwFreeArray(aAreas)    
    ElseIf(oProcess <> Nil)
        Alert(STR0035)//"Campo Revisão(CNU_REVISA) inexistente ou marcado como Não Usado.
        lRet := .F.
    EndIf
Return lRet

/*/{Protheus.doc} CNUReport
    Definição do objeto TReport
@author philipe.pompeu
@since 24/02/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function CNUReport(oProcess)
	Local oReport As Object
	Local oSection As Object

	oReport:= TReport():New("CNUFIX",STR0037,, {|oReport| PrintCNU(oReport)},STR0038)
	oSection := TRSection():New(oReport,,{"CNU", "CN9"})
	oSection:SetHeaderPage()

	TRCell():New(oSection,"CN9_FILCTR"  , "CN9")
	TRCell():New(oSection,"CNU_CONTRA"  , "CNU")
	TRCell():New(oSection,"CN9_REVISA"  , "CN9")
	TRCell():New(oSection,"CNU_CODVD"   , "CNU")

    oReport:PrintDialog()//-- Imprime relatório
Return Nil


/*/{Protheus.doc} PrintCNU
    Realiza a impressão dos registros que serão processados da CNU
@author philipe.pompeu
@since 24/02/2021
@param oReport, TReport, objeto para impressão do relatório
@return Nil
*/
Static Function PrintCNU(oReport)
    Local oSection  := oReport:Section(1)    	
    Local cQuery    := ""
    Local nCount    := 0
	
    If QueryCNU(@cQuery, oSection, @nCount)
        oReport:SetMeter(nCount)
        oSection:SetParentQuery()
        oSection:Print()
	    oSection:Finish()
    Else
        Alert(STR0024) //-- Nenhum registro encontrado para processamento
    EndIf
Return Nil

/*/{Protheus.doc} QueryCNU
    Processa a correção da tabela de vendedores <CNU>
@author philipe.pompeu
@since 24/02/2021
@param cUmAlias, caractere, carrega o alias com os registros a serem processados
@param oSection, objeto, TSection
@param nCount, numerico, carrega o numero total de registros
@return lResult, lógico, verdadeiro caso existam registros à serem processados/impressos
*/
Static Function QueryCNU(cUmAlias, oSection, nCount)
    Local cRevVazia := Space(Len(CN9->CN9_REVISA))
    Local lResult   := .F.
    Default cUmAlias:= ""
    Default oSection:= Nil
    Default nCount  := 0

    cUmAlias:= GetNextAlias()
   
    If ValType(oSection) == "O"
        oSection:BeginQuery()
    EndIf

    BeginSQL Alias cUmAlias
        SELECT CN9_FILCTR,CN9_REVISA,CNU.* 
        FROM %Table:CNU% CNU
        INNER JOIN %Table:CN9% CN9 ON(CN9_FILIAL = CNU.CNU_FILIAL AND CN9_NUMERO = CNU.CNU_CONTRA AND CN9.%NotDel%)
        LEFT JOIN %Table:CNU% CNU2 ON
        (        
                CNU2.CNU_FILIAL = CNU.CNU_FILIAL
            AND CNU2.CNU_CONTRA = CNU.CNU_CONTRA
            AND CNU2.CNU_REVISA = CN9.CN9_REVISA
            AND CNU2.CNU_CODVD  = CNU.CNU_CODVD
            AND CNU2.%NotDel%
        )
        WHERE
        CN9_REVISA <> %Exp:cRevVazia%
        AND CNU.CNU_REVISA = %Exp:cRevVazia%        
        AND CNU.%NotDel%
        AND ISNULL(CNU2.CNU_REVISA, '0') = '0'
        ORDER BY CN9_FILCTR, CNU.CNU_CONTRA, CN9_REVISA
    EndSql

    If ValType(oSection) == "O"
        oSection:EndQuery()
    EndIf
    
    lResult := (cUmAlias)->(!Eof())    
    
    If !lResult
        (cUmAlias)->(DbCloseArea())
    Else
        nCount := 0
        (cUmAlias)->(dbEval({|| nCount++}))
        (cUmAlias)->(DbGoTop())
    EndIf

Return lResult

/*/{Protheus.doc} ProcFixCNU
    Processa a correção da tabela de vendedores <CNU>
@author philipe.pompeu
@since 24/02/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function ProcFixCNU(oProcess)
    Local lHasView  := .F.    
    Local cQuery    := ""
    Local aStruct   := {}
    Local nI        := 0
    Local nTam      := 0
    Local nPosCNU   := 0
    Local nPosQuery := 0
    Local nFldQuery := 0
    Local nFldCNU   := 0
    Local nCount    := 0
    lHasView := (oProcess <> Nil)

    If QueryCNU(@cQuery,Nil, @nCount)
        If lHasView
            oProcess:SetRegua2(nCount)
        EndIf

        aStruct   := CNU->(DbStruct())
        nTam      := Len(aStruct)
        for nI := 1 to nTam           
            aAdd(aStruct[nI], CNU->( FieldPos(aStruct[nI, 1]) ) )

            If (aStruct[nI, 1] == 'CNU_REVISA')
                aAdd(aStruct[nI], (cQuery)->( FieldPos('CN9_REVISA') ) )//Nesse caso preencherá com o campo da CN9
            Else
                aAdd(aStruct[nI], (cQuery)->( FieldPos(aStruct[nI, 1]) ) )                
            EndIf
        next nI        
        nPosQuery   := Len(aStruct[1])
        nPosCNU     := (nPosQuery-1)

        While (cQuery)->(!EOF())
            If lHasView
                oProcess:IncRegua2(STR0011 + (cQuery)->(CNU_CONTRA + "/" + CNU_REVISA))                
            EndIf

            RecLock("CNU" , .T.)
            For nI := 1 to nTam

                nFldCNU     := aStruct[nI,nPosCNU]
                nFldQuery   := aStruct[nI,nPosQuery]
                If (nFldQuery > 0 .And. nFldCNU > 0)                    
                    CNU->(FieldPut(nFldCNU, (cQuery)->(FieldGet(nFldQuery))))
                EndIf               
            Next nI
            CNU->(MsUnlock())

            (cQuery)->(DbSkip())
        EndDo
        (cQuery)->(DbCloseArea())
    ElseIf(lHasView)
        Alert(STR0024) //-- Nenhum registro encontrado para processamento
    EndIf    
Return Nil


/*/{Protheus.doc} GCTAjstCND
    Processa a correção da tabela Cabeçalho Medição de Contratos(CND)
@author jose.souza2
@since 24/02/2021
@return Nil, nulo
*/
Function GCTAjstCND()
	Local oProcess As Object
	Local nOpc As Numeric
    Local cMsg As Character

   
    nOpc := Aviso(STR0016 /*Atenção*/, STR0039, {STR0013/*Processar*/, STR0014/*Imprimir*/,STR0015/*Cancelar*/}, 2) 
        
    cMsg := IIf(nOpc == 2, STR0018/*Impressão*/, STR0019/*Atualização*/)

    If nOpc <> 3
        oProcess := MsNewProcess():New({|| FixCND(@oProcess, nOpc) }, cMsg + STR0040) //-- Impressão/Atualização
        oProcess:Activate()
    Endif

Return Nil

/*/{Protheus.doc} FixCND
    Processa a escolha do usuário realizada na função <GCTAjstCND>
@author jose.souza2
@since 07/10/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return lRet, lógico, verdadeiro caso possa ser processado
*/
Static Function FixCND(oProcess, nOpc)
	Local lRet 	         := .T.
	Default oProcess     := Nil 
	Default nOpc         := 1

    
    oProcess:SetRegua1(1)            
    oProcess:IncRegua1(IIF(nOpc == 1, STR0042, STR0018))
  

    If (nOpc == 1) //-- Processa atualização            
        ProcFixCND(oProcess)//Processa ajuste CND
    ElseIf (nOpc == 2)
        CNDReport(oProcess)
    EndIf

Return lRet


/*/{Protheus.doc} CNDReport
    Definição do objeto TReport
@author jose.souza2
@since 07/10/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function CNDReport(oProcess)
	Local oReport As Object
	Local oSection As Object

	oReport:= TReport():New("CNDFIX",STR0043,, {|oReport| PrintCND(oReport)},STR0044)
	oSection := TRSection():New(oReport,,{"CND"})
	oSection:SetHeaderPage()

	TRCell():New(oSection,"CND_FILIAL"  , "CND")
	TRCell():New(oSection,"CND_CONTRA"  , "CND")
	TRCell():New(oSection,"CND_NUMMED"  , "CND")
	TRCell():New(oSection,"CND_FILCTR"  , "CND")

    oReport:PrintDialog()//-- Imprime relatório
Return Nil


/*/{Protheus.doc} PrintCND
    Realiza a impressão dos registros que serão processados da CND
@author jose.souza2
@since 07/10/2021
@param oReport, TReport, objeto para impressão do relatório
@return Nil
*/
Static Function PrintCND(oReport)
    Local oSection  := oReport:Section(1)    	
    Local cQuery    := ""
    Local nCount    := 0
	
    If QueryCND(@cQuery, oSection, @nCount)
        oReport:SetMeter(nCount)
        oSection:SetParentQuery()
        oSection:Print()
	    oSection:Finish()
    Else
        Alert(STR0024) //-- Nenhum registro encontrado para processamento
    EndIf
Return Nil

/*/{Protheus.doc} QueryCND
    Processa o ajuste referente a tabela do Cabeçalho Medição de Contratos(CND)
@author jose.souza2
@since 07/10/2021
@param oReport, TReport, objeto para impressão do relatório
@return Nil
*/
Static Function QueryCND(cUmAlias, oSection, nCount)
    Local lResult   := .F.
    Default cUmAlias:= ""
    Default oSection:= Nil
    Default nCount  := 0

    cUmAlias:= GetNextAlias()
   
    If ValType(oSection) == "O"
        oSection:BeginQuery()
    EndIf

    BeginSQL Alias cUmAlias

        SELECT A.CND_FILIAL, A.CND_CONTRA, A.CND_NUMMED FROM %Table:CND% A WHERE A.CND_FILIAL = %xFilial:CND% AND
		A.CND_REVGER <> A.CND_REVISA AND A.%NotDel% AND
		(SELECT COUNT(CND_NUMMED) FROM %Table:CND% B  WHERE B.CND_FILIAL = A.CND_FILIAL AND B.CND_NUMMED = A.CND_NUMMED AND B.%NotDel%) = 1
		ORDER BY A.CND_FILIAL,A.CND_NUMMED

    EndSql

    If ValType(oSection) == "O"
        oSection:EndQuery()
    EndIf
    
    lResult := (cUmAlias)->(!Eof())    
    
    If !lResult
        (cUmAlias)->(DbCloseArea())
    Else
        nCount := 0
        (cUmAlias)->(dbEval({|| nCount++}))
        (cUmAlias)->(DbGoTop())
    EndIf

Return lResult

/*/{Protheus.doc} ProcFixCND
    Processa a correção da tabela Cabeçalho Medição de Contratos <CND>
@author jose.souza2
@since 07/10/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function ProcFixCND(oProcess)   
    Local cQuery    := ""
    Local nCount    := 0
    Local cChave    := ""
    Local aAreas	:= {CND->(GetArea()), GetArea()}

    If QueryCND(@cQuery,Nil, @nCount)
        oProcess:SetRegua2(nCount)

        CND->(dbSetOrder(4))

        While (cQuery)->(!EOF())
            oProcess:IncRegua2(STR0011 + (cQuery)->(CND_CONTRA + "/" + CND_NUMMED))                
            cChave:= (cQuery)->(CND_FILIAL+CND_NUMMED)
            If CND->(dbSeek(cChave))
                Reclock("CND", .F.)
                CND->CND_REVGER:= CND->CND_REVISA
                CND->(MsUnlock())
            EndIf
             (cQuery)->(dbSkip())
        EndDo
        (cQuery)->(dbCloseArea())
    Else
        Alert(STR0024) //-- Nenhum registro encontrado para processamento
    EndIf  

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})

Return Nil

/*/{Protheus.doc} AjstCNL
//TODO Ajusta registros tabela CNL 
@author fabiano.dantas
@since 24/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AjstCNL()

    Local oProcess
    Local nOpc := 0


    nOpc := Aviso(STR0016 /*Atenção*/, STR0001, {STR0013/*Processar*/,STR0014/*Imprimir*/,STR0015/*'Cancelar*/}, 2)
    If nOpc <> 3
		oProcess := MsNewProcess():New({|lEnd| CNLAJUSTA(@oProcess, @lEnd, nOpc) },STR0002,STR0003,.T.)
		oProcess:Activate()
	Endif

Return

/*/{Protheus.doc} CNLAJUSTA
//TODO Ajusta registros tabela CNL 
@author fabiano.dantas
@since 24/12/2019
@version 1.0
@return lRet

@type function
/*/     

Function CNLAJUSTA(oProcess, lEnd, nOpc)
	Local lRet 	      := .T.
	Private nTotal	  := 0
	
	Default oProcess := Nil 
	Default nOpc := 1


	lRet := .F.
	cAliasCNL := GetNextAlias()

	If oProcess <> Nil
		oProcess:SetRegua1(2)
		oProcess:IncRegua1(STR0003) // Lendo Tipo de Planilha 
	Endif

	BeginSQL Alias cAliasCNL

	SELECT	CNL.CNL_FILIAL AS FILIAL, CNL.CNL_CODIGO AS CODIGO, CNL.CNL_DESCRI AS DESCRICAO

	FROM %Table:CNL% CNL

	WHERE CNL_FILIAL = %xFilial:CNL%
	AND CNL.%NotDel%
	AND (CNL_TPSFIX = '0' OR CNL_TPSFIX = '')
	AND CNL_CTRFIX = '3'


	EndSql

	If oProcess <> Nil
		Count To nTotal
		oProcess:IncRegua1(STR0004+ alltrim(str(nTotal))+STR0005) //Serão processados x registros
		oProcess:SetRegua2(nTotal)
		DbSelectArea(cAliasCNL)
		(cAliasCNL)->(DbGoTop())

		If nTotal == 0
			Alert(STR0009) //Nenhum registro encontrado para processamento
			lRet := .F. 
	 		Return lRet
		EndIf
	EndIf

	If nOpc = 2 
		Imprel()
	Else
		ProcUPD(oProcess)
	EndIf	

	(cAliasCNL)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} ImpRel
// Realiza impressão dos registros que serão modificados
@author fabiano.dantas
@since 24/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
*/
static Function ImpRel()
	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
//Relação de registros que serão modificados 
@author fabiano.dantas
@since 24/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ReportDef()

	Local oReport
	Local oSection

	oReport:= TReport():New(STR0010,STR0006,, {|oReport| ReportPrint(oReport)},STR0007)


	oSection := TRSection():New(oReport,OemToAnsi("CNL1"),{"CNL"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

	oSection:SetHeaderPage()

	TRCell():New(oSection,"CNL_FILIAL", "CNL")
	TRCell():New(oSection,"CNL_CODIGO", "CNL")
	TRCell():New(oSection,"CNL_DESCRI", "CNL")

Return(oReport)


/*/{Protheus.doc} ReportPrint
//Relação de registros que serão modificados 
@author fabiano.dantas
@since 24/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
/*/
Static Function ReportPrint(oReport)

	Local oSection  := oReport:Section(1)

	
	oReport:SetMeter(CNL->(LastRec()))
	oSection:Init()

	While  !(cAliasCNL)->(Eof())

		oSection:Cell("CNL_FILIAL"):SetValue((cAliasCNL)->FILIAL)
		oSection:Cell("CNL_CODIGO"):SetValue((cAliasCNL)->CODIGO)
		oSection:Cell("CNL_DESCRI"):SetValue((cAliasCNL)->DESCRICAO)

		oSection:PrintLine()
		oReport:IncMeter()
		(cAliasCNL)->(dbSkip())

	EndDo

	oSection:Finish()

Return NIL


/*/{Protheus.doc} ProcUPD
//Atualização dos registros
@author fabiano.dantas
@since 24/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oProcess, object, descricao
@type function
/*/
Static function ProcUPD(oProcess)
	Local nStatus := 0
	
	While !(cAliasCNL)->(Eof())

		cUpDate := " UPDATE "+RetSqlName("CNL")
		cUpDate += " 	SET CNL_TPSFIX = '1'"
		cUpDate += " 	WHERE CNL_FILIAL = '"+xFilial("CNL")+"' "
		cUpDate += " 	  AND CNL_CODIGO = '"+(cAliasCNL)->CODIGO+"' "
		cUpDate += " 	  AND D_E_L_E_T_ = ' ' "

		nStatus := TcSqlExec(cUpDate)
		If nStatus < 0
			conout("TCSQLError() " + TCSQLError())
  		EndIf

		If oProcess <> Nil
			oProcess:IncRegua2(STR0011 + alltrim(str(nTotal)) ) // Processando registro
		EndIf

		(cAliasCNL)->(dbSkip())
		

	EndDo

	If oProcess <> Nil
		MsgInfo(STR0012) // Término do ajuste - CNL
	EndIf 
	
Return NIL

/*/{Protheus.doc} GCPAjstCNB
    Processa a correção da tabela CNB
@author philipe.pompeu
@since 19/11/2021
@return Nil, nulo
*/
Function GCPAjstCNB()
	Local oProcess As Object
	Local nOpc As Numeric
    Local cMsg As Character

    nOpc := Aviso(STR0016 /*Atenção*/, STR0045, {STR0013/*Processar*/, STR0014/*Imprimir*/,STR0015/*Cancelar*/}, 2) 
    
    cMsg := IIf(nOpc == 2, STR0018/*Impressão*/, STR0019/*Atualização*/)

    If nOpc <> 3
        oProcess := MsNewProcess():New({|| ExecCNBFix(@oProcess, nOpc) }, cMsg) //-- Impressão/Atualização
        oProcess:Activate()
    Endif
    
Return Nil

/*/{Protheus.doc} ExecCNBFix
    Processa a escolha do usuário realizada na função <GCPAjstCNB>
@author philipe.pompeu
@since 19/11/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return lRet, lógico, verdadeiro caso possa ser processado
*/
Static Function ExecCNBFix(oProcess, nOpc)
    Local aArea         := GetArea()
	Local lRet 	         := .T.
	Default oProcess     := Nil 
	Default nOpc         := 1

    oProcess:SetRegua1(1)            
    oProcess:IncRegua1(IIF(nOpc == 1, STR0046, STR0018))        

    If (nOpc == 1) //-- Processa atualização            
        UpdCNBLote(oProcess)//Processa ajuste
    ElseIf (nOpc == 2)
        CNBLoteRpt(oProcess)
    EndIf
    
    RestArea(aArea)
    FwFreeArray(aArea)
Return lRet

/*/{Protheus.doc} CNBLoteRpt
    Definição do objeto TReport
@author philipe.pompeu
@since 19/11/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function CNBLoteRpt(oProcess, oRptToExec)
	Local oReport As Object
	Local oSection As Object
    Local oMainSect As Object
    Local cQuery    := ""
    Local nCount    := 0

    If (ValType(oRptToExec) == "O")
        oMainSect  := oRptToExec:Section(1)
        If QryCNBLote(@cQuery, oMainSect, @nCount)
            oRptToExec:SetMeter(nCount)
            oMainSect:SetParentQuery()
            oMainSect:Print()
            oMainSect:Finish()
        Else
            Alert(STR0024) //-- Nenhum registro encontrado para processamento
        EndIf
    Else
        oReport:= TReport():New("CNBLote",STR0047,, {|oReport| CNBLoteRpt(Nil, oReport)},STR0048)
        oSection := TRSection():New(oReport,,{"CNB", "CN9", "CX6"})
        oSection:SetHeaderPage()

        TRCell():New(oSection,"CN9_NUMERO"  , "CN9")
        TRCell():New(oSection,"CN9_REVISA"  , "CN9")
        TRCell():New(oSection,"CN9_CODED"   , "CN9")
        TRCell():New(oSection,"CN9_NUMATA"  , "CN9")
        TRCell():New(oSection,"CN9_NUMPR"   , "CN9")
        TRCell():New(oSection,"CX6_LOTE"    , "CX6")
        TRCell():New(oSection,"CNB_NUMERO"  , "CNB")
        TRCell():New(oSection,"CNB_ITEM"    , "CNB")
        TRCell():New(oSection,"CNB_PRODUT"  , "CNB")
        TRCell():New(oSection,"CNB_GCPIT"   , "CNB")

        oReport:PrintDialog()//-- Imprime relatório
    EndIf

Return Nil

/*/{Protheus.doc} QryCNBLote
    Realiza a consulta a base de dados dos registros que serão atualizados
@author philipe.pompeu
@since 19/11/2021
@param cUmAlias, caractere, carrega o alias com os registros a serem processados
@param oSection, objeto, TSection
@param nCount, numerico, carrega o numero total de registros
@return lResult, lógico, verdadeiro caso existam registros à serem processados/impressos
*/
Static Function QryCNBLote(cUmAlias, oSection, nCount)
    Local cItemVazio := Space(Len(CNB->CNB_GCPIT))
    Local cLoteVazio := Space(Len(CNB->CNB_GCPLT))
    Local lResult   := .F.
    Default cUmAlias:= ""
    Default oSection:= Nil
    Default nCount  := 0

    cUmAlias:= GetNextAlias()
   
    If ValType(oSection) == "O"
        oSection:BeginQuery()
    EndIf

    BeginSQL Alias cUmAlias

        SELECT CN9_FILCTR, CN9_NUMERO, CN9_REVISA, CN9_CODED, CN9_NUMATA, CN9_NUMPR, CX6_LOTE, CNB_NUMERO, CNB_ITEM, CNB_PRODUT, CNB.R_E_C_N_O_ AS RECID
        FROM %Table:CNB% CNB
        INNER JOIN %Table:CNA% CNA ON(CNB_FILIAL = CNA_FILIAL AND CNB_CONTRA = CNA_CONTRA AND CNB_REVISA = CNA_REVISA AND CNB_NUMERO = CNA_NUMERO AND CNA.%NotDel%)
        INNER JOIN %Table:CN9% CN9 ON(CNA_FILIAL = CN9_FILIAL AND CNA_CONTRA = CN9_NUMERO AND CNA_REVISA =  CN9_REVISA AND CN9.%NotDel%)
        INNER JOIN %Table:CX6% CX6 ON(CX6_FILIAL = %xFilial:CX6% AND CX6_NUMATA = CN9_NUMATA AND CX6.%NotDel%)
        WHERE 
        CNB_FILIAL = %xFilial:CNB%
        AND CNB_GCPIT <> %Exp:cItemVazio% 
        AND CNB_GCPLT = %Exp:cLoteVazio%
        AND CNB.%NotDel%
        
        ORDER BY CN9_NUMERO, CN9_REVISA, CNB_NUMERO, CNB_ITEM
    EndSql

    If ValType(oSection) == "O"
        oSection:EndQuery()
    EndIf
    
    lResult := (cUmAlias)->(!Eof())    
    
    If !lResult
        (cUmAlias)->(DbCloseArea())
    Else
        nCount := 0
        (cUmAlias)->(dbEval({|| nCount++}))
        (cUmAlias)->(DbGoTop())
    EndIf
Return lResult

/*/{Protheus.doc} UpdCNBLote
    Processa a correção da tabela de itens da planilha(CNB)
@author philipe.pompeu
@since 24/02/2021
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function UpdCNBLote(oProcess)    
    Local cQuery    := ""
    Local nCount    := 0    

    If QryCNBLote(@cQuery,Nil, @nCount)        
        oProcess:SetRegua2(nCount)
        
        While (cQuery)->(!EOF())
            oProcess:IncRegua2(STR0011 + (cQuery)->(CN9_NUMERO + "/" + CX6_LOTE))

            CNB->(DbGoTo((cQuery)->RECID))

            RecLock("CNB" , .F.)

            CNB->CNB_GCPLT := (cQuery)->CX6_LOTE
            
            CNB->(MsUnlock())

            (cQuery)->(DbSkip())
        EndDo
        (cQuery)->(DbCloseArea())
    Else
        Alert(STR0024) //-- Nenhum registro encontrado para processamento
    EndIf    
Return Nil

/*/{Protheus.doc} GCPAjstSC7
    Processa a correção da tabela SC7 referente aos campos filial do edital, código do Edital e número do processo
@since 22/03/2022
@return Nil, nulo
*/
Function GCPAjstSC7()
	Local oProcess As Object
	Local nOpc As Numeric
    Local cMsg As Character
   
    nOpc := Aviso(STR0016 /*Atenção*/, STR0049, {STR0013/*Processar*/, STR0014/*Imprimir*/,STR0015/*Cancelar*/}, 2) 
        
    cMsg := IIf(nOpc == 2, STR0018/*Impressão*/, STR0019/*Atualização*/)

    If nOpc <> 3
        oProcess := MsNewProcess():New({|| FixSC7(@oProcess, nOpc) }, cMsg + STR0050) //-- Impressão/Atualização
        oProcess:Activate()
    Endif

Return Nil

/*/{Protheus.doc} FixSC7
    Processa a escolha do usuário realizada na função <GCPAjstSC7>
@author jose.souza2
@since 22/03/2022
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return lRet, lógico, verdadeiro caso possa ser processado
*/
Static Function FixSC7(oProcess, nOpc)
	Local lRet 	         := .T.
	Default oProcess     := Nil 
	Default nOpc         := 1

    oProcess:SetRegua1(1)            
    oProcess:IncRegua1(IIF(nOpc == 1, STR0051, STR0018))
  
    If (nOpc == 1) //-- Processa atualização            
        ProcFixSC7(oProcess)//Processa ajuste SC7
    ElseIf (nOpc == 2)
        SC7Report(oProcess)
    EndIf

Return lRet

/*/{Protheus.doc} SC7Report
    Definição do objeto TReport
@author jose.souza2
@since 22/03/2022
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function SC7Report(oProcess)
	Local oReport As Object
	Local oSection As Object

	oReport:= TReport():New("FIXSC7",STR0052,, {|oReport| PrintSC7(oReport)},STR0053)
	oSection := TRSection():New(oReport,,{"SC7"})
	oSection:SetHeaderPage()

	TRCell():New(oSection,"C7_NUM"      ,   "SC7")
	TRCell():New(oSection,"CN9_NUMERO"  ,   "CN9")
    TRCell():New(oSection,"CN9_CODED"   ,   "CN9")
    TRCell():New(oSection,"CN9_NUMPR"   ,   "CN9")
    TRCell():New(oSection,"CN9_FILEDT"  ,   "CN9")

    oReport:PrintDialog()//-- Imprime relatório
Return Nil

/*/{Protheus.doc} PrintSC7
    Realiza a impressão dos registros que serão processados da SC7
@author jose.souza2
@since 22/13/2022
@param oReport, TReport, objeto para impressão do relatório
@return Nil
*/
Static Function PrintSC7(oReport)
    Local oSection  := oReport:Section(1)    	
    Local cQuery    := ""
    Local nCount    := 0
	
    If QuerySC7(@cQuery, oSection, @nCount)
        oReport:SetMeter(nCount)
        oSection:SetParentQuery()
        oSection:Print()
	    oSection:Finish()
    Else
        Alert(STR0024) //-- Nenhum registro encontrado para processamento
    EndIf
Return Nil

/*/{Protheus.doc} QuerySC7
    Processa o ajuste referente a tabela de Pedido de Compra (SC7)
@author jose.souza2
@since 22/03/2022
@param oReport, TReport, objeto para impressão do relatório
@return Nil
*/
Static Function QuerySC7(cUmAlias, oSection, nCount)
    Local lResult       := .F.
    Local cECN9Vazio    := Space(Len(CN9->CN9_CODED))
    Local cNCN9Vazio    := Space(Len(CN9->CN9_NUMPR))
    Local cFCN9Vazio    := Space(Len(CN9->CN9_FILEDT))
    Local cEdC7Vazio    := Space(Len(SC7->C7_CODED))
    Local cNpC7Vazio    := Space(Len(SC7->C7_NUMPR))
    Local cFiC7Vazio    := Space(Len(SC7->C7_FILEDT))
    Default cUmAlias    := ""
    Default oSection    := Nil
    Default nCount      := 0

    cUmAlias:= GetNextAlias()
   
    If ValType(oSection) == "O"
        oSection:BeginQuery()
    EndIf

    BeginSQL Alias cUmAlias

        SELECT CN9_CODED, CN9_NUMPR, CN9_FILEDT, CN9_NUMERO, C7_NUM,C7_CONTRA, SC7.R_E_C_N_O_ AS RECID
        FROM %Table:SC7% SC7
        INNER JOIN %Table:CND% CND ON(C7_MEDICAO = CND_NUMMED AND C7_CONTREV = CND_REVISA AND C7_CONTRA = CND_CONTRA AND CND.%NotDel%)
        INNER JOIN %Table:CN9% CN9 ON(CN9_FILCTR = CND_FILCTR AND CN9_REVISA = CND_REVISA AND CN9_NUMERO = CND_CONTRA AND CN9.%NotDel%)
        WHERE
        C7_FILIAL = %xFilial:SC7%
        AND SC7.%NotDel%
        AND CN9_CODED <> %Exp:cECN9Vazio%
        AND CN9_NUMPR <> %Exp:cNCN9Vazio%
        AND CN9_FILEDT <> %Exp:cFCN9Vazio%
        AND (C7_CODED = %Exp:cEdC7Vazio%
        OR C7_NUMPR = %Exp:cNpC7Vazio%
        OR C7_FILEDT = %Exp:cFiC7Vazio%)

    EndSql
    If ValType(oSection) == "O"
        oSection:EndQuery()
    EndIf
    
    lResult := (cUmAlias)->(!Eof())    
    
    If !lResult
        (cUmAlias)->(DbCloseArea())
    Else
        nCount := 0
        (cUmAlias)->(dbEval({|| nCount++}))
        (cUmAlias)->(DbGoTop())
    EndIf

Return lResult

/*/{Protheus.doc} ProcFixSC7
    Processa o ajuste da tabela de Pedido de Compra (SC7) 
@author jose.souza2
@since 22/03/2022
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function ProcFixSC7(oProcess)
    Local cQuery    := ""
    Local nCount    := 0

     If QuerySC7(@cQuery,Nil, @nCount)
        oProcess:SetRegua2(nCount)

        While (cQuery)->(!EOF())
            oProcess:IncRegua2(STR0011 + (cQuery)->(C7_NUM + "\" + C7_CONTRA))
            SC7->(dbGoTo((cQuery)->RECID))
            RecLock("SC7", .F.)
            SC7->C7_CODED := (cQuery)->CN9_CODED
            SC7->C7_NUMPR := (cQuery)->CN9_NUMPR
            SC7->C7_FILEDT:= (cQuery)->CN9_FILEDT

            SC7->(MsUnlock())
            
            (cQuery)->(dbSkip())

        EndDo
        (cQuery)->(dbCloseArea())
     Else
        Alert(STR0024) //-- Nenhum registro encontrado para processamento 

     EndIf

Return Nil

/*/{Protheus.doc} GCTAjstCXJ
    Processa o ajuste da tabela Amarração Pedido x Med x Plan x Part (CXJ) 
@author jose.souza2
@since 08/07/2022
@return Nil
*/
Function GCTAjstCXJ()
	Local oProcess As Object
	Local nOpc As Numeric
    Local cMsg As Character
    nOpc := Aviso(STR0016 /*Atenção*/, STR0054, {STR0013/*Processar*/, STR0014/*Imprimir*/,STR0015/*Cancelar*/}, 2) 
        
    cMsg := IIf(nOpc == 2, STR0018/*Impressão*/, STR0019/*Atualização*/)

    If nOpc <> 3
        oProcess := MsNewProcess():New({|| FixCXJ(@oProcess, nOpc) }, cMsg + STR0055) //-- Impressão/Atualização
        oProcess:Activate()
    Endif

Return Nil

/*/{Protheus.doc} FixCXJ
    Processa a escolha do usuário realizada na função <GCTAjstCXJ>
@author jose.souza2
@since 08/07/2022
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@param nOpc, Opção selecionada.
@return lRet, lógico, verdadeiro caso possa ser processado
*/
Static Function FixCXJ(oProcess, nOpc)
	Local lRet 	         := .T.
	Default oProcess     := Nil 
	Default nOpc         := 1

    oProcess:SetRegua1(1)            
    oProcess:IncRegua1(IIF(nOpc == 1, STR0051, STR0018))
  
    If (nOpc == 1) //-- Processa atualização            
        ProcFixCXJ(oProcess)//Processa ajuste CXJ
    ElseIf (nOpc == 2)
        CXJReport(oProcess)
    EndIf

Return lRet

/*/{Protheus.doc} CXJReport
    Definição do objeto TReport
@author jose.souza2
@since 08/07/2022
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function CXJReport(oProcess)
	Local oReport As Object
	Local oSection As Object

	oReport:= TReport():New("FIXCXJ",STR0056,, {|oReport| PrintCXJ(oReport)},STR0057)
	oSection := TRSection():New(oReport,,{"CXJ"})
	oSection:SetHeaderPage()

	TRCell():New(oSection,"CXJ_CONTRA"  ,   "CXJ")
	TRCell():New(oSection,"CXJ_NUMPED"  ,   "CXJ")
    TRCell():New(oSection,"CXJ_NUMPLA"  ,   "CXJ")
    TRCell():New(oSection,"CXJ_NUMMED"  ,   "CXJ")
   
    oReport:PrintDialog()//-- Imprime relatório
Return Nil

/*/{Protheus.doc} PrintCXJ
    Realiza a impressão dos registros que serão processados da CXJ
@author jose.souza2
@since 08/07/2022
@param oReport, TReport, objeto para impressão do relatório
@return Nil
*/
Static Function PrintCXJ(oReport)
    Local oSection  := oReport:Section(1)    	
    Local cQuery    := ""
    Local nCount    := 0
	
    If QueryCXJ(@cQuery, oSection, @nCount)
        oReport:SetMeter(nCount)
        oSection:SetParentQuery()
        oSection:Print()
	    oSection:Finish()
    Else
        Alert(STR0024) //-- Nenhum registro encontrado para processamento
    EndIf
Return Nil

/*/{Protheus.doc} QueryCXJ
    Processa o ajuste referente a tabela CXJ
@author jose.souza2
@since 11/07/2022
@param cUmAlias, caractere, carrega o alias com os registros a serem processados
@param oSection, objeto, TSection
@param nCount, numerico, carrega o numero total de registros
@return lResult, lógico, verdadeiro caso existam registros à serem processados/impressos
*/
Static Function QueryCXJ(cUmAlias, oSection, nCount)
    Local lResult       := .F.
    Local nNumTitCXJ    := Space(Len(CXJ->CXJ_NUMTIT))
    Default cUmAlias    := ""
    Default oSection    := Nil
    Default nCount      := 0

    cUmAlias:= GetNextAlias()
   
    If ValType(oSection) == "O"
        oSection:BeginQuery()
    EndIf

    BeginSQL Alias cUmAlias
        SELECT CXJ_NUMPED, CXJ_CONTRA,CXJ_NUMPLA,CXJ_NUMMED,C7_NUM, CXJ.R_E_C_N_O_ AS RECID 
        FROM %Table:CXJ% CXJ
        INNER JOIN  %Table:SC7% SC7 ON( C7_FILIAL = %xFilial:SC7% AND CXJ_CONTRA = C7_CONTRA  AND CXJ_NUMMED = C7_MEDICAO AND CXJ_NUMPLA = C7_PLANILH  AND SC7.%NotDel%)
        WHERE 
        CXJ_FILIAL = %xFilial:CXJ%
        AND CXJ.%NotDel%
        AND CXJ_NUMTIT = %Exp:nNumTitCXJ%
        AND CXJ_NUMPED <> C7_NUM

    EndSql
    If ValType(oSection) == "O"
        oSection:EndQuery()
    EndIf
    
    lResult := (cUmAlias)->(!Eof())    
    
    If !lResult
        (cUmAlias)->(DbCloseArea())
    Else
        nCount := 0
        (cUmAlias)->(dbEval({|| nCount++}))
        (cUmAlias)->(DbGoTop())
    EndIf

Return lResult

/*/{Protheus.doc} ProcFixCXJ
    Processa o ajuste da tabela CXJ referente ao campo número do pedido 
@author jose.souza2
@since 11/07/2022
@param oProcess, MsNewProcess, objeto utilizado para exibir carregamento
@return Nil
*/
Static Function ProcFixCXJ(oProcess)
    Local cQuery    := ""
    Local nCount    := 0

     If QueryCXJ(@cQuery,Nil, @nCount)
        oProcess:SetRegua2(nCount)

        While (cQuery)->(!EOF())
            oProcess:IncRegua2(STR0011 + (cQuery)->(CXJ_NUMPED + "\" + CXJ_CONTRA))
            CXJ->(dbGoTo((cQuery)->RECID))
            RecLock("CXJ", .F.)
            CXJ->CXJ_NUMPED := (cQuery)->C7_NUM

            CXJ->(MsUnlock())
            
            (cQuery)->(dbSkip())

        EndDo
        (cQuery)->(dbCloseArea())
     Else
        Alert(STR0024) //-- Nenhum registro encontrado para processamento 

     EndIf

Return Nil



