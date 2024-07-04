#include 'protheus.ch'
#include 'eicap153.ch'

/*/{Protheus.doc} EICAP153
    Relatório de Variação de parcelas

    @type  Function
    @author Bruno Akyo Kubagawa
    @since 01/09/2022
    @version 1.0
    @param nenhum
    @return nenhum
/*/
function EICAP153()
    local aArea      := {}
    local oFwSX1Util := nil
    local aPergunte  := {}

    private cTitF3   := ""

    if EasyGParam("MV_EASYFIN",,"N") == "S"

        oFwSX1Util := FwSX1Util():New()
        oFwSX1Util:AddGroup("EICAP153")
        oFwSX1Util:SearchGroup()
        aPergunte := oFwSX1Util:GetGroup("EICAP153")
        if len(aPergunte) > 0 .and. len(aPergunte[2]) > 0 .and. pergunte("EICAP153",.T.)
            PrcRelat()
        endif
        FwFreeArray(aPergunte)
        FwFreeObj(oFwSX1Util)
        aPergunte := nil

    else
        EasyHelp(STR0001, STR0002, STR0003) // "Relatório indisponível para este cenário de negócio." ### "Atenção" ### "Relatório disponível para ambientes integrados com o módulo Financeiro (SIGAFIN)."
    endif

    restArea(aArea)

return nil

/*/{Protheus.doc} PrcRelat
    Realiza o processamento/layout da impressão do relatorio

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 01/09/2022
    @version 1.0
    @param nenhum
    @return nenhum
/*/
static function PrcRelat()
    local oReport    := nil
    local cAliasQry  := getNextAlias()
    local aTables    := {"SE2", "SE5"}
    local aOrdem     := {}
    local oSecao1    := nil

    private cTipoReg   := ""
    private cParcela   := ""
    private cMoeda     := ""
    private dDtEmissao := ctod("")
    private nValor     := 0
    private nTaxaEmi   := 0
    private nVlrTot    := 0
    private dDtEmiDI   := ctod("")
    private nTaxaDI    := 0
    private nVlrDI     := 0
    private nVarCambDI := 0
    private dDtEmiLiq  := ctod("")
    private nTaxaLiq   := 0
    private nVlrLiq    := 0
    private nVarCambLq := 0
    private dDateRef   := ctod("")
    private nTaxaData  := 0
    private nVlrData   := 0
    private nVarCambDt := 0
    private cObs       := ""

    oReport := TReport():New("EICAP153", STR0004, "EICAP153", {|oReport| ReportPrint(oReport, cAliasQry)}, STR0005 ) // "Relatório de variação de parcelas" ### "Este programa tem como objetivo imprimir relatório de acordo com os parametros informados pelo usuário."
    oReport:oPage:lLandScape := .T.
    oReport:oPage:lPortRait := .F.

    oSecao1 := TRSection():New(oReport,"Variação de parcelas",aTables,aOrdem)

    TRCell():New( oSecao1 , "HAWB"       , cAliasQry , STR0007 , GetSX3Cache("WB_HAWB"   , "X3_PICTURE") , GetSX3Cache("WB_HAWB"   , "X3_TAMANHO") )                      // "Processo"
    TRCell():New( oSecao1 , "cTipoReg"   , cAliasQry , STR0008 , ""                                      , 15                                      , , {|| cTipoReg } )   // "Tipo"
    TRCell():New( oSecao1 , "INVOICE"    , cAliasQry , STR0009 , GetSX3Cache("WB_INVOICE", "X3_PICTURE") , GetSX3Cache("WB_INVOICE", "X3_TAMANHO") )                      // "Invoice"
    TRCell():New( oSecao1 , "FORN"       , cAliasQry , STR0010 , GetSX3Cache("WB_FORN"   , "X3_PICTURE") , GetSX3Cache("WB_FORN"   , "X3_TAMANHO") )                      // "Fornecedor"
    TRCell():New( oSecao1 , "LOJA"       , cAliasQry , STR0011 , GetSX3Cache("WB_LOJA"   , "X3_PICTURE") , GetSX3Cache("WB_LOJA"   , "X3_TAMANHO") )                      // "Loja"
    TRCell():New( oSecao1 , "A2_NREDUZ"  , cAliasQry , STR0012 , GetSX3Cache("A2_NREDUZ" , "X3_PICTURE") , GetSX3Cache("A2_NREDUZ" , "X3_TAMANHO") )                      // "Nome"
    TRCell():New( oSecao1 , "dDtEmissao" , ""        , STR0013 , GetSX3Cache("E2_EMISSAO", "X3_PICTURE") , GetSX3Cache("E2_EMISSAO", "X3_TAMANHO") , , {|| dDtEmissao } ) // "Emissão"
    TRCell():New( oSecao1 , "DT_VEN"     , cAliasQry , STR0014 , GetSX3Cache("WB_DT_VEN" , "X3_PICTURE") , GetSX3Cache("WB_DT_VEN" , "X3_TAMANHO") )                      // "Vencimento"
    TRCell():New( oSecao1 , "NUMDUP"     , cAliasQry , STR0015 , GetSX3Cache("WB_NUMDUP" , "X3_PICTURE") , GetSX3Cache("WB_NUMDUP" , "X3_TAMANHO") )                      // "Número do título"
    TRCell():New( oSecao1 , "cParcela"   , ""        , STR0016 , GetSX3Cache("WB_PARCELA", "X3_PICTURE") , GetSX3Cache("WB_PARCELA", "X3_TAMANHO") , , {|| cParcela } )   // "Parcela do título"
    TRCell():New( oSecao1 , "cMoeda"     , ""        , STR0035 , GetSX3Cache("WB_MOEDA"  , "X3_PICTURE") , GetSX3Cache("WB_MOEDA"  , "X3_TAMANHO") , , {|| cMoeda } )     // "Moeda"
    TRCell():New( oSecao1 , "nValor"     , ""        , STR0017 , GetSX3Cache("WB_FOBMOE" , "X3_PICTURE") , GetSX3Cache("WB_FOBMOE" , "X3_TAMANHO") , , {|| nValor } )     // "Valor na Moeda"
    TRCell():New( oSecao1 , "nTaxaEmi"   , ""        , STR0018 , GetSX3Cache("E2_TXMOEDA", "X3_PICTURE") , GetSX3Cache("E2_TXMOEDA", "X3_TAMANHO") , , {|| nTaxaEmi } )   // "Taxa na data de emissão"
    TRCell():New( oSecao1 , "nVlrTot"    , ""        , STR0019 , GetSX3Cache("WB_FOBMOE" , "X3_PICTURE") , GetSX3Cache("WB_FOBMOE" , "X3_TAMANHO") , , {|| nVlrTot } )    // "Valor R$ na data da emissão"

    TRCell():New( oSecao1 , "dDtEmiDI"   , ""        , STR0020 , GetSX3Cache("W6_DTREG_D", "X3_PICTURE") , GetSX3Cache("W6_DTREG_D", "X3_TAMANHO") , , {|| dDtEmiDI })    // "Data da DI"
    TRCell():New( oSecao1 , "nTaxaDI"    , ""        , STR0021 , GetSX3Cache("W9_TX_FOB" , "X3_PICTURE") , GetSX3Cache("W9_TX_FOB" , "X3_TAMANHO") , , {|| nTaxaDI } )    // "Taxa na data da DI"
    TRCell():New( oSecao1 , "nVlrDI"     , ""        , STR0022 , GetSX3Cache("WB_FOBMOE" , "X3_PICTURE") , GetSX3Cache("WB_FOBMOE" , "X3_TAMANHO") , , {|| nVlrDI } )     // "Valor R$ na data da DI"
    TRCell():New( oSecao1 , "nVarCambDI" , ""        , STR0023 , GetSX3Cache("WB_FOBMOE" , "X3_PICTURE") , GetSX3Cache("WB_FOBMOE" , "X3_TAMANHO") , , {|| nVarCambDI } ) // "Variação cambial data da DI"

    TRCell():New( oSecao1 , "dDtEmiLiq"  , ""        , STR0034 , GetSX3Cache("W6_DTREG_D", "X3_PICTURE") , GetSX3Cache("W6_DTREG_D", "X3_TAMANHO") , , {|| dDtEmiLiq } )  // "Data da liquidação"
    TRCell():New( oSecao1 , "nTaxaLiq"   , ""        , STR0024 , GetSX3Cache("WB_CA_TX"  , "X3_PICTURE") , GetSX3Cache("WB_CA_TX"  , "X3_TAMANHO") , , {|| nTaxaLiq} )    // "Taxa de liquidação"
    TRCell():New( oSecao1 , "nVlrLiq"    , ""        , STR0025 , GetSX3Cache("WB_FOBMOE" , "X3_PICTURE") , GetSX3Cache("WB_FOBMOE" , "X3_TAMANHO") , , {|| nVlrLiq } )    // "Valor R$ na data da liquidação"
    TRCell():New( oSecao1 , "nVarCambLq" , ""        , STR0026 , GetSX3Cache("WB_FOBMOE" , "X3_PICTURE") , GetSX3Cache("WB_FOBMOE" , "X3_TAMANHO") , , {|| nVarCambLq } ) // "Variação cambial data da liquidação"

    TRCell():New( oSecao1 , "dDateRef"   , ""        , STR0027 , GetSX3Cache("W6_DTREG_D", "X3_PICTURE") , GetSX3Cache("W6_DTREG_D", "X3_TAMANHO") , , {|| dDateRef } )   // "Data de Referência"
    TRCell():New( oSecao1 , "nTaxaData"  , ""        , STR0028 , GetSX3Cache("W9_TX_FOB" , "X3_PICTURE") , GetSX3Cache("W9_TX_FOB" , "X3_TAMANHO") , , {|| nTaxaData } )  // "Taxa na data de referência"
    TRCell():New( oSecao1 , "nVlrData"   , ""        , STR0029 , GetSX3Cache("WB_FOBMOE" , "X3_PICTURE") , GetSX3Cache("WB_FOBMOE" , "X3_TAMANHO") , , {|| nVlrData } )   // "Valor R$ na data de referência"
    TRCell():New( oSecao1 , "nVarCambDt" , ""        , STR0030 , GetSX3Cache("WB_FOBMOE" , "X3_PICTURE") , GetSX3Cache("WB_FOBMOE" , "X3_TAMANHO") , , {|| nVarCambDt } ) // "Variação cambial na data de referência"

    TRCell():New( oSecao1 , "cObs"       , ""        , STR0031 , ""                                      , 100                                     , , {|| cObs } )       // "Observação"

    oReport:PrintDialog()

    if select(cAliasQry) > 0
        (cAliasQry)->(dbCloseArea())
    endif

return nil

/*/{Protheus.doc} ReportPrint
    Realiza a impressão das informações do relatorio

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 01/09/2022
    @version 1.0
    @param oReport, object, objeto da classe tReport
    @return nenhum
/*/
static function ReportPrint(oReport, cAliasQry)
    local aAreaSE2   := {}
    local aAreaSE5   := {}
    local cOrder     := ""
    local cTipo      := ""
    local aTaxaRef   := {}
    local aTipoReg   := FWGetSX5( "Y6" )
    local nPosReg    := 0
    local cMoedaUSS  := alltrim(BuscaDolar())
    local nTotal     := 0
    local nRecno     := 0
    local cWhere     := ""
    local cCond      := ""

    pergunte("EICAP153",.F.)

    cWhere += "% SWB_D.WB_FILIAL = '" + xFilial("SWB") + "' "
    cCond := if( !empty(MV_PAR02) , " SWB_D.WB_HAWB BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " , if( !empty(MV_PAR01), " SWB_D.WB_HAWB = '" + MV_PAR01 + "' ", ""))
    if !empty(cCond)
        cWhere += " AND " + cCond
    endif
    cCond := if( !empty(MV_PAR04) , " SE2.E2_EMISSAO BETWEEN '" + dtos(MV_PAR03) + "' AND '" + dtos(MV_PAR04) + "' " , if( !empty(MV_PAR03), " SWB_D.E2_EMISSAO = '" + dtos(MV_PAR03) + "' ", ""))
    if !empty(cCond)
        cWhere += " AND " + cCond
    endif
    cCond := if( !empty(MV_PAR07) , " SWB_D.WB_FORN BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' " , if( !empty(MV_PAR05), " SWB_D.WB_FORN = '" + MV_PAR05 + "' ", ""))
    if !empty(cCond)
        cWhere += " AND " + cCond
    endif
    cCond := if( !empty(MV_PAR08) , " SWB_D.WB_LOJA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' " , if( !empty(MV_PAR06), " SWB_D.WB_LOJA = '" + MV_PAR06 + "' ", ""))
    if !empty(cCond)
        cWhere += " AND " + cCond
    endif
    cCond := if( !empty(MV_PAR10) , " SWB_D.WB_NUMDUP BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " , if( !empty(MV_PAR09), " SWB_D.WB_NUMDUP = '" + MV_PAR09 + "' ", ""))
    if !empty(cCond)
        cWhere += " AND " + cCond
    endif
    cWhere += "%"

    dbSelectArea("SE2")
    aAreaSE2 := SE2->(getArea())
    SE2->(dbSetOrder(6)) // E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO

    dbSelectArea("SE5")
    aAreaSE5 := SE5->(getArea())
    SE5->(dbSetOrder(7)) // E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA + E5_SEQ

    /*
    MV_PAR01 -> Processo de:
    MV_PAR02 -> Processo até:
    MV_PAR03 -> Emissão de:
    MV_PAR04 -> Emissão até:
    MV_PAR05 -> Fornecedor de:
    MV_PAR06 -> Loja de:
    MV_PAR07 -> Fornecedor até:
    MV_PAR08 -> Loja até:
    MV_PAR09 -> Titulo Financeiro de:
    MV_PAR10 -> Titulo Financeiro até:
    MV_PAR11 -> Ordem:
    MV_PAR12 -> Data de Referencia:
    */

    if MV_PAR11 == 3 // Título + data de emissão
        cOrder := "% SWB_D.WB_NUMDUP, SE2.E2_PARCELA, SE2.E2_EMISSAO %"
    elseif MV_PAR11 == 2 // Fornecedor + data de emissão
        cOrder := "% SWB_D.WB_FORN, SWB_D.WB_LOJA, SE2.E2_EMISSAO %"
    else // Processo + data de emissão
        cOrder := "% SWB_D.WB_HAWB, SE2.E2_EMISSAO %"
    endif

    BeginSQL Alias cAliasQry
        SELECT SWB_D.WB_HAWB HAWB, SWB_D.WB_INVOICE INVOICE, SWB_D.WB_PO_DI PO_DI, SWB_D.WB_TIPOREG TIPOREG, SWB_D.WB_EVENT EVENTO, SWB_D.WB_FORN FORN, SWB_D.WB_LOJA LOJA, SWB_D.WB_NUMDUP NUMDUP, SWB_D.WB_DT_VEN DT_VEN, 
            SWB_D.WB_CA_DT CA_DT, SWB_D.WB_CA_TX CA_TX, SWB_D.WB_FOBMOE FOBMOE, SWB_D.WB_PGTANT PGTANT, SWB_D.WB_MOEDA MOEDA, SWB_D.WB_SEQBX SEQBX, SWB_D.WB_PREFIXO PREFIXO, SWB_D.WB_PARCELA PARCELA, SWB_D.WB_TIPOTIT TIPOTIT,
            SWB_ANTEC.WB_HAWB HAWB_ANT, SWB_ANTEC.WB_INVOICE INVOICE_ANT, SWB_ANTEC.WB_PO_DI PO_DI_ANT, SWB_ANTEC.WB_TIPOREG TIPOREG_ANT, SWB_ANTEC.WB_EVENT EVENTO_ANT, SWB_ANTEC.WB_FORN FORN_ANT, SWB_ANTEC.WB_LOJA LOJA_ANT, SWB_ANTEC.WB_NUMDUP NUMDUP_ANT, SWB_ANTEC.WB_DT_VEN DT_VEN_ANT,
            SWB_ANTEC.WB_CA_DT CA_DT_ANT,SWB_ANTEC.WB_CA_TX CA_TX_ANT, SWB_ANTEC.WB_FOBMOE FOBMOE_ANT, SWB_ANTEC.WB_PGTANT PGTANT_ANT, SWB_ANTEC.WB_MOEDA MOEDA_ANT, SWB_ANTEC.WB_SEQBX SEQBX_ANT, SWB_ANTEC.WB_PREFIXO PREFIXO_ANT, SWB_ANTEC.WB_PARCELA PARCELA_ANT, SWB_ANTEC.WB_TIPOTIT TIPOTIT_ANT,
            SE2.E2_EMISSAO, SE2.E2_TXMOEDA, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_LOJA, SE2.R_E_C_N_O_ SE2_REC,
            SA2.A2_NREDUZ,
            SW6.W6_DTREG_D, W6_TX_US_D
        FROM %Table:SWB% SWB_D
            INNER JOIN %Table:SE2% SE2 ON SE2.D_E_L_E_T_ = ' '
                AND SE2.E2_FILIAL = %xFilial:SE2%
                AND SE2.E2_PREFIXO = SWB_D.WB_PREFIXO
                AND SE2.E2_NUM = SWB_D.WB_NUMDUP
                AND SE2.E2_PARCELA = SWB_D.WB_PARCELA
                AND SE2.E2_TIPO = SWB_D.WB_TIPOTIT
                AND SE2.E2_FORNECE = SWB_D.WB_FORN
                AND SE2.E2_LOJA = SWB_D.WB_LOJA
            LEFT JOIN %Table:SW6% SW6 ON SW6.D_E_L_E_T_ = ' '
                AND SW6.W6_FILIAL = %xFilial:SW6%
                AND SW6.W6_HAWB = SWB_D.WB_HAWB
            LEFT JOIN %Table:SA2% SA2 ON SA2.D_E_L_E_T_ = ' '
                AND SA2.A2_FILIAL = %xFilial:SA2%
                AND SA2.A2_COD = SWB_D.WB_FORN
                AND SA2.A2_LOJA = SWB_D.WB_LOJA
            LEFT JOIN %Table:SWB% SWB_COMP ON SWB_COMP.D_E_L_E_T_ = ' ' 
                AND SWB_COMP.WB_FILIAL = %xFilial:SWB%
                AND SWB_COMP.WB_HAWB = SWB_D.WB_HAWB
                AND SWB_COMP.WB_NUMDUP = ' ' 
                AND SWB_COMP.WB_CHAVE = CONCAT( SWB_D.WB_HAWB , SWB_D.WB_PO_DI , SWB_D.WB_INVOICE , SWB_D.WB_FORN , SWB_D.WB_LOJA , SWB_D.WB_LINHA )
            LEFT JOIN %Table:SWB% SWB_ANTEC ON SWB_ANTEC.D_E_L_E_T_ = ' ' 
                AND SWB_ANTEC.WB_FILIAL = %xFilial:SWB%
                AND SWB_ANTEC.WB_HAWB = SWB_COMP.WB_NUMPO
                AND SWB_ANTEC.WB_TIPOREG = 'P'
        WHERE SWB_D.D_E_L_E_T_ = ' '
            AND %Exp:cWhere%
        ORDER BY %Exp:cOrder%
    EndSQL

    TcSetField(cAliasQry,'E2_EMISSAO','D')
    TcSetField(cAliasQry,'W6_DTREG_D','D')
    TcSetField(cAliasQry,'DT_VEN','D')
    TcSetField(cAliasQry,'DT_VEN_ANT','D')
    TcSetField(cAliasQry,'CA_DT','D')
    TcSetField(cAliasQry,'CA_DT_ANT','D')

    dDateRef := MV_PAR12

    (cAliasQry)->(dbGoTop())
    if (cAliasQry)->(!eof())

        oReport:Section("Variação de parcelas"):Init()
        while (cAliasQry)->(!eof()) .and. !oReport:Cancel()

            SE2->(dbGoTo( (cAliasQry)->SE2_REC ))
            SE5->(dbSeek( xFilial("SE5") + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA + if( empty((cAliasQry)->SEQBX), "", (cAliasQry)->SEQBX) ))

            if nRecno == 0 .or. !( nRecno == SE2->(recno()))
                nRecno := SE2->(recno())
                nTotal := (cAliasQry)->FOBMOE + (cAliasQry)->PGTANT
            endif

            cTipoReg   := ""
            cParcela   := (cAliasQry)->PARCELA
            nValor     := 0 // Valor na Moeda
            nVlrTot    := 0 // Valor R$ na data da emissão
            dDtEmiDI   := ctod("") // Data da DI
            nTaxaDI    := 0 // Taxa na data da DI
            nVlrDI     := 0 // Valor R$ na data da DI
            nVarCambDI := 0 // Variação cambial data da DI
            dDtEmiLiq  := ctod("") // "Data da liquidação"
            nTaxaLiq   := 0 // Taxa de liquidação
            nVlrLiq    := 0 // Valor R$ na data da liquidação
            nVarCambLq := 0 // Variação cambial data da liquidação
            nTaxaData  := 0 // Taxa na data de referência
            nVlrData   := 0 // Valor R$ na data de referência
            nVarCambDt := 0 // Variação cambial na data de referência
            cObs       := "" // Observação

            cTipo := (cAliasQry)->PO_DI
            cMoeda := (cAliasQry)->MOEDA

            nPosReg := aScan( aTipoReg, { |X| alltrim(X[2]) == "Y6" .and. alltrim(X[3]) == (cAliasQry)->TIPOREG} )
            if nPosReg > 0
                cTipoReg := alltrim(aTipoReg[nPosReg][4])
            endif

            // "Emissão"
            dDtEmissao := (cAliasQry)->E2_EMISSAO

            // Taxa na data de emissão
            nTaxaEmi := (cAliasQry)->E2_TXMOEDA

            // Data da liquidação
            dDtEmiLiq := (cAliasQry)->CA_DT

            // Taxa de liquidação
            nTaxaLiq := (cAliasQry)->CA_TX

            // Tipo de Cambio
            // D - Desembaraço
            // A - Adiantamento PO
            // F - Adiantamento Fornecedor
            // C - Credito

            if cTipo == "D"

                dDtEmiDI := (cAliasQry)->W6_DTREG_D

                // Taxa na data da Declaração (a taxa da capa do processo é sempre em US$ e deve ser convertida para a taxa da moeda do câmbio)
                if !empty(dDtEmiDI)
                    nTaxaDI := if( !( alltrim(cMoeda) == cMoedaUSS ) , BuscaTaxa(cMoeda, dDtEmiDI, .T. ,.F.) , (cAliasQry)->W6_TX_US_D )
                endif

                if (cAliasQry)->FOBMOE > 0

                    nValor := (cAliasQry)->FOBMOE

                    PrintLine(oReport, cAliasQry, nValor, aTaxaRef, cMoeda)

                endif

                if (cAliasQry)->PGTANT > 0

                    if (cAliasQry)->PGTANT_ANT <= (cAliasQry)->PGTANT
                        nValor := (cAliasQry)->PGTANT_ANT
                        nTotal -= nValor
                    else
                        nValor := nTotal
                    endif

                    // Data da liquidação
                    dDtEmiLiq := (cAliasQry)->CA_DT_ANT

                    // Taxa de liquidação
                    nTaxaLiq   := (cAliasQry)->CA_TX_ANT

                    cObs := STR0032 + ": " + alltrim( (cAliasQry)->NUMDUP_ANT ) // "Compensado com o título"

                    PrintLine(oReport, cAliasQry, nValor, aTaxaRef, cMoeda)

                endif

            endif

            if cTipo == "A" .or. cTipo == "F" .or. cTipo == "C"

                // Valor na Moeda
                nValor := (cAliasQry)->PGTANT

                PrintLine(oReport, cAliasQry, nValor, aTaxaRef, cMoeda)

            endif

            (cAliasQry)->(dbSkip())
        end
        oReport:Section("Variação de parcelas"):Finish()

    endif

    restArea(aAreaSE2)
    restArea(aAreaSE5)

return

/*/{Protheus.doc} PrintLine
    Realiza a impressão da linha

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 01/09/2022
    @version 1.0
    @param  oReport, object, objeto da classe tReport
            cAliasQry, caracter, alias da query
    @return nenhum
/*/
static function PrintLine(oReport, cAliasQry, nValor, aTaxaRef, cMoeda)
    local nPosTaxa   := 0

    // Valor R$ na data da emissão
    nVlrTot := nValor * nTaxaEmi

    // Valor R$ na data da DI
    nVlrDI := nValor * nTaxaDI

    // Variação cambial data da DI (data de emissão até a data da declaração)
    nVarCambDI := 0
    if nTaxaDI > 0
        nVarCambDI := nVlrTot - nVlrDI
    endif

    // Valor R$ na data da liquidação
    nVlrLiq := nValor * nTaxaLiq

    // Variação cambial data da liquidação (data da emissão até a data de liquidação)
    nVarCambLq := 0
    if nTaxaLiq > 0
        nVarCambLq := nVlrTot - nVlrLiq
    endif

    if !empty(dDateRef)

        // Taxa na data de referência
        nPosTaxa := aScan( aTaxaRef, { |X| X[1] == cMoeda} )
        if nPosTaxa == 0
            nTaxaData := BuscaTaxa( cMoeda, dDateRef, ,.F.)
            aAdd( aTaxaRef, { cMoeda, nTaxaData } )
        else
            nTaxaData := aTaxaRef[nPosTaxa][2]
        endif

        // Valor R$ na data de referência
        nVlrData := nValor * nTaxaData

        // Variação cambial na data de referência (data da emissão até a data de referência)
        nVarCambDt := 0
        if nTaxaData > 0
            nVarCambDt := nVlrTot - nVlrData
        endif

    endif

    oReport:IncMeter()
    oReport:Section("Variação de parcelas"):PrintLine()

return

/*/{Protheus.doc} AP153F3
    Consulta padrão para os titulos da SWB

    @type  Function
    @author Bruno Akyo Kubagawa
    @since 01/09/2022
    @version 1.0
    @param nenhum
    @return lRet, lógico,
/*/
function AP153F3()
    local lRet       := .F.
    local cAliasF3   := ""
    local cAliasQry  := ""
    local aEstr      := {}
    local oSize      := nil
    local oDlg       := nil
    local cTitulo    := STR0033 // "Títulos Financeiros"
    local oSelect    := nil

    cTitF3 := space(len(SWB->WB_NUMDUP))

    cAliasQry := getNextAlias()
    BeginSQL Alias cAliasQry
        SELECT DISTINCT WB_FILIAL, WB_NUMDUP, WB_PO_DI, WB_HAWB, WB_INVOICE, WB_FORN, WB_LOJA, WB_PREFIXO FROM %Table:SWB% SWB
        WHERE SWB.D_E_L_E_T_ = ' ' AND SWB.WB_NUMDUP <> ' ' 
    EndSQL

    aAdd(aEstr,{"WB_FILIAL" , GetSX3Cache("WB_FILIAL" , "X3_TIPO"), GetSX3Cache("WB_FILIAL" , "X3_TAMANHO"), GetSX3Cache("WB_FILIAL" , "X3_DECIMAL")})
    aAdd(aEstr,{"WB_NUMDUP" , GetSX3Cache("WB_NUMDUP" , "X3_TIPO"), GetSX3Cache("WB_NUMDUP" , "X3_TAMANHO"), GetSX3Cache("WB_NUMDUP" , "X3_DECIMAL")})
    aAdd(aEstr,{"WB_PO_DI"  , GetSX3Cache("WB_PO_DI"  , "X3_TIPO"), GetSX3Cache("WB_PO_DI"  , "X3_TAMANHO"), GetSX3Cache("WB_PO_DI"  , "X3_DECIMAL")})
    aAdd(aEstr,{"WB_HAWB"   , GetSX3Cache("WB_HAWB"   , "X3_TIPO"), GetSX3Cache("WB_HAWB"   , "X3_TAMANHO"), GetSX3Cache("WB_HAWB"   , "X3_DECIMAL")})
    aAdd(aEstr,{"WB_INVOICE", GetSX3Cache("WB_INVOICE", "X3_TIPO"), GetSX3Cache("WB_INVOICE", "X3_TAMANHO"), GetSX3Cache("WB_INVOICE", "X3_DECIMAL")})
    aAdd(aEstr,{"WB_FORN"   , GetSX3Cache("WB_FORN"   , "X3_TIPO"), GetSX3Cache("WB_FORN"   , "X3_TAMANHO"), GetSX3Cache("WB_FORN"   , "X3_DECIMAL")})
    aAdd(aEstr,{"WB_LOJA"   , GetSX3Cache("WB_LOJA"   , "X3_TIPO"), GetSX3Cache("WB_LOJA"   , "X3_TAMANHO"), GetSX3Cache("WB_LOJA"   , "X3_DECIMAL")})
    aAdd(aEstr,{"WB_PREFIXO", GetSX3Cache("WB_PREFIXO", "X3_TIPO"), GetSX3Cache("WB_PREFIXO", "X3_TAMANHO"), GetSX3Cache("WB_PREFIXO", "X3_DECIMAL")})

    cAliasF3 := GetNextAlias()

    //Cria tabela temporária no banco de dados 
    oArqTemp := FwTemporaryTable():New(cAliasF3)
    oArqTemp:SetFields(aEstr)
    oArqTemp:AddIndex("1", { "WB_FILIAL", "WB_NUMDUP"} )
    oArqTemp:Create()

    (cAliasF3)->(dbSetOrder(0)) //ordem natural de inserção

    (cAliasQry)->(dbGoTop())
    While !((cAliasQry)->(Eof()))
        RecLock(cAliasF3,.T.)
        (cAliasF3)->WB_FILIAL  := (cAliasQry)->WB_FILIAL
        (cAliasF3)->WB_NUMDUP  := (cAliasQry)->WB_NUMDUP
        (cAliasF3)->WB_PO_DI   := (cAliasQry)->WB_PO_DI
        (cAliasF3)->WB_HAWB    := (cAliasQry)->WB_HAWB
        (cAliasF3)->WB_INVOICE := (cAliasQry)->WB_INVOICE
        (cAliasF3)->WB_FORN    := (cAliasQry)->WB_FORN
        (cAliasF3)->WB_LOJA    := (cAliasQry)->WB_LOJA
        (cAliasF3)->WB_PREFIXO := (cAliasQry)->WB_PREFIXO
        (cAliasF3)->(MsUnLock())
        (cAliasQry)->(DbSkip())
    Enddo

    (cAliasQry)->(dbCloseArea())
    (cAliasF3)->(dbGoTop())

    oSize := FwDefSize():New(.T.)	
    oSize:lLateral := .F.
    oSize:AddObject("MASTER",100,100,.T.,.T.)
    oSize:lProp := .T.
    oSize:Process()
    DEFINE MSDIALOG oDlg TITLE cTitulo From oSize:aWindSize[1]*0.5,oSize:aWindSize[2]*0.5 To oSize:aWindSize[3]*0.5,oSize:aWindSize[4]*0.5 OF oMainWnd PIXEL 

        oSelect := TCBrowse():New(0,0,10,10,,,,oDlg,,,,,,,,,,,,,cAliasF3,.T.,,,,.T.,)
        oSelect:AddColumn( TCColumn():New( RetTitle("WB_FILIAL") , { || (cAliasF3)->WB_FILIAL  } , /*cPicture*/,,,"LEFT", /*nLargura*/,.F., .F.,,/*bValid*/ ) )
        oSelect:AddColumn( TCColumn():New( RetTitle("WB_NUMDUP") , { || (cAliasF3)->WB_NUMDUP  } , /*cPicture*/,,,"LEFT", /*nLargura*/,.F., .F.,,/*bValid*/ ) )
        oSelect:AddColumn( TCColumn():New( RetTitle("WB_PO_DI")  , { || (cAliasF3)->WB_PO_DI   } , /*cPicture*/,,,"LEFT", /*nLargura*/,.F., .F.,,/*bValid*/ ) )
        oSelect:AddColumn( TCColumn():New( RetTitle("WB_HAWB")   , { || (cAliasF3)->WB_HAWB    } , /*cPicture*/,,,"LEFT", /*nLargura*/,.F., .F.,,/*bValid*/ ) )
        oSelect:AddColumn( TCColumn():New( RetTitle("WB_INVOICE"), { || (cAliasF3)->WB_INVOICE } , /*cPicture*/,,,"LEFT", /*nLargura*/,.F., .F.,,/*bValid*/ ) )
        oSelect:AddColumn( TCColumn():New( RetTitle("WB_FORN")   , { || (cAliasF3)->WB_FORN    } , /*cPicture*/,,,"LEFT", /*nLargura*/,.F., .F.,,/*bValid*/ ) )
        oSelect:AddColumn( TCColumn():New( RetTitle("WB_LOJA")   , { || (cAliasF3)->WB_LOJA    } , /*cPicture*/,,,"LEFT", /*nLargura*/,.F., .F.,,/*bValid*/ ) )
        oSelect:AddColumn( TCColumn():New( RetTitle("WB_PREFIXO"), { || (cAliasF3)->WB_PREFIXO } , /*cPicture*/,,,"LEFT", /*nLargura*/,.F., .F.,,/*bValid*/ ) )
        oSelect:Align := CONTROL_ALIGN_ALLCLIENT
        oSelect:bLDblClick := { || cTitF3 := (cAliasF3)->WB_NUMDUP , lRet := .T., oDlg:End() }
        oSelect:Refresh()

    ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| cTitF3 := if( (cAliasF3)->(!eof()), (cAliasF3)->WB_NUMDUP , cTitF3 ), lRet := .T.,oDlg:End()},{|| lRet := .F.,oDlg:End()},,) CENTERED 

    (cAliasF3)->(dbCloseArea())

    oArqTemp:Delete()
    FwFreeObj(oArqTemp)
    oArqTemp := NIL

return lRet

/*/{Protheus.doc} AP153F3
    Retorno da Consulta padrão para os titulos da SWB

    @type  Function
    @author Bruno Akyo Kubagawa
    @since 01/09/2022
    @version 1.0
    @param nenhum
    @return cRet, caracter, numero do titulo selecionado
/*/
function AP153F3Ret()
    local cRet := if( isMemVar("cTitF3"), cTitF3, "")
return cRet
