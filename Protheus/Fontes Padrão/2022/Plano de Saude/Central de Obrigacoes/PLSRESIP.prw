#include "protheus.ch"

#define M_VLR "@E 999,999,999.99"
#define M_DATE "@D"
#define M_NUM "@E 99999"

/*/{Protheus.doc} PLSRESIP
Relatório para listar as guias de determinada competência do SIP extraidas do PLS.

@owner TOTVS

@author Gabriel H. Klok
@since 24/08/2020
@version 1.0
/*/
function PLSRESIP(lAuto)
    local aArea := getarea()
    local oReport 
    local cPerg := "PLSRESIP"
    local cAlias := getnextalias()

    default lAuto := .f.

    if pergunte(cPerg, !lAuto)
        oReport := reportdef(lAuto, cPerg, @cAlias)
        oReport:printdialog()
        freeobj(oReport)
        cAlias := nil
    endif
    
    restarea(aArea)
return iif(lAuto, .t., nil)


/*/{Protheus.doc} reportdef
Função monta a estrutura do relatório no formato treport.

@author Gabriel H. Klok
@since 24/08/2020
@version 1.0

@return oReport, object, Objeto instanciado da classe 'TReport'.
/*/
static function reportdef(lAuto, cPerg, cAlias)
    local oReport
    local oGuias
    local lPixel := .t.

    local cName := "PLSRESIP"
    local cTitle := "Guias PLS extraidas SIP"
    local cDesc := "Relatório mostra as guias presentes no trimestre selecionado do SIP, extraidas do PLS."
    local bParam := {|| pergunte(cPerg, .t.) }
    local bImpres := {|oReport| printreport(oReport, lAuto, @cAlias)}

    oReport := treport():new(cName, cTitle, bParam, bImpres, cDesc)
    oReport:nfontbody := 8
    oReport:nlineheight := 40
    oReport:setlandscape()
    oReport:hidefooter()

    oGuias := trsection():new(oReport, "Guias PLS", cAlias)
    oGuias:nPercentage := 100
    oGuias:setautosize(.t.)
    trcell():new(oGuias, "RECSIP", cAlias, "RECSIP", "@!",, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "NUMLOT", cAlias, "Numero Lote", "@!", 12, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "MATRIC", cAlias, "Matricula", "@!", 20, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "CDGUIA", cAlias, "Guia", "@!", 26, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "TPGUIA", cAlias, "Tipo", "@!", 17, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "CODRDA", cAlias, "Código RDA", "@!", 12, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "CODPAD", cAlias, "Tabela", "@!",, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "CODPRO", cAlias, "Procedimento", "@!", 14, lPixel,,,,,, 0)
    trcell():new(oGuias, "QTDPRO", cAlias, "Quantidade", M_NUM, 12, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "SEQUEN", cAlias, "Sequência", "@!", 10, lPixel,, "CENTER",, "CENTER",, 0)
    trcell():new(oGuias, "VLRPAG", cAlias, "Valor Pago", M_VLR, 12, lPixel,, "RIGHT",, "RIGHT",, 0)
    trcell():new(oGuias, "DATPRO", cAlias, "Data Procedimento", M_DATE,, lPixel, {|| dtoc(stod((cAlias)->DATPRO)) }, "CENTER",, "CENTER",, 0)
      
return oReport


/*/{Protheus.doc} printreport
Função realiza a impressão do relatório.

@author Gabriel H. Klok
@since 24/08/2020
@version 1.0

@param oReport, object, Objecto da classe 'TReport'.
/*/
static function printreport(oReport, lAuto, cAlias)
    local oGuias := oReport:section(1)

    executeSQL(lAuto, @cAlias)

    if (cAlias)->(eof())
        iif(lAuto, conout("PLSRESIP Auto - Nenhum dado para ser exibido!"),msgalert("Nenhum dado para ser exibido!", "TOTVS"))
    else 
        oGuias:print()
    endif 

    (cAlias)->(dbclosearea())
return 


/*/{Protheus.doc} executeSQL
Função realiza a busca das guias no PLS.

@author Gabriel H. Klok
@since 24/08/2020
@version 1.0
/*/
static function executeSQL(lAuto, cAlias)
    local cCodOpe := ""
    local cAno := ""
    local cTri := ""
    local cTpGuiDe := "  "
    local cTpGuiAte := "ZZ"
	Local cDB	    := TCGetDB()

    cCodOpe := iif(lAuto, "", MV_PAR01)
    cAno := iif(lAuto, "", MV_PAR02)
    cTri := iif(lAuto, "", "0" + alltrim(str(MV_PAR03)))

    if ! empty(MV_PAR04)
        cTpGuiDe := iif(lAuto, "  ", MV_PAR04)    
        cTpGuiAte := iif(lAuto, "ZZ", MV_PAR04)
    endif

    If cDB == 'MSSQL'
        beginsql alias cAlias
            SELECT BD7.BD7_RECSIP RECSIP, 
                BD7_NUMLOT NUMLOT,
                BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG + BD6_DIGITO MATRIC,
                BD7T.BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV CDGUIA,
                CASE BD7T.BD7_TIPGUI
                    WHEN '01' THEN 'Consulta'
                    WHEN '02' THEN 'SADT/Odonto'
                    WHEN '04' THEN 'Reembolso'
                    WHEN '05' THEN 'Resumo Internação'
                    WHEN '06' THEN 'Honorários'
                    ELSE '--'
                END TPGUIA,
                BD7_CODRDA CODRDA, 
                BD7_CODPAD CODPAD, 
                BD7_CODPRO CODPRO,
                BD6_QTDPRO QTDPRO,
                BD7_SEQUEN SEQUEN, 
                SUM(BD7_VLRPAG) VLRPAG, 
                BD7_DATPRO DATPRO            
            FROM (
                SELECT BD7_CODOPE, BD7_TIPGUI, BD7_RECSIP, BD7I.R_E_C_N_O_ FROM %table:BD7% BD7I WHERE BD7I.%notdel%
            ) BD7T
                INNER JOIN %table:BD7% BD7
                    ON BD7.R_E_C_N_O_ = BD7T.R_E_C_N_O_
                INNER JOIN %table:BD6% BD6
                    ON BD6_FILIAL = BD7.BD7_FILIAL 
                    AND BD6_CODOPE = BD7.BD7_CODOPE
                    AND BD6_CODLDP = BD7.BD7_CODLDP 
                    AND BD6_CODPEG = BD7.BD7_CODPEG
                    AND BD6_NUMERO = BD7.BD7_NUMERO 
                    AND BD6_ORIMOV = BD7.BD7_ORIMOV
                    AND BD6_SEQUEN = BD7.BD7_SEQUEN
                    AND BD6.%notdel% 
            WHERE BD7T.BD7_CODOPE = %exp:cCodOpe%
                AND BD7T.BD7_RECSIP = %exp:cAno + cTri%
                AND BD7T.BD7_TIPGUI BETWEEN %exp:cTpGuiDe% AND %exp:cTpGuiAte%
            GROUP BY BD7.BD7_RECSIP, 
                BD7_NUMLOT,
                BD7_OPEUSR + BD7_CODEMP + BD7_MATRIC + BD7_TIPREG + BD6_DIGITO,
                BD7T.BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV,
                CASE BD7T.BD7_TIPGUI
                    WHEN '01' THEN 'Consulta'
                    WHEN '02' THEN 'SADT/Odonto'
                    WHEN '04' THEN 'Reembolso'
                    WHEN '05' THEN 'Resumo Internação'
                    WHEN '06' THEN 'Honorários'
                    ELSE '--'
                END,
                BD7_CODRDA, 
                BD7_CODPAD, 
                BD7_CODPRO,
                BD6_QTDPRO,
                BD7_SEQUEN, 
                BD7_DATPRO
            ORDER BY 1,4,2,10
        endsql 
    else    

        beginsql alias cAlias
            SELECT BD7.BD7_RECSIP RECSIP, 
                BD7_NUMLOT NUMLOT,
                BD7_OPEUSR || BD7_CODEMP || BD7_MATRIC || BD7_TIPREG || BD6_DIGITO MATRIC,
                BD7T.BD7_CODOPE || BD7_CODLDP || BD7_CODPEG || BD7_NUMERO || BD7_ORIMOV CDGUIA,
                CASE BD7T.BD7_TIPGUI
                    WHEN '01' THEN 'Consulta'
                    WHEN '02' THEN 'SADT/Odonto'
                    WHEN '04' THEN 'Reembolso'
                    WHEN '05' THEN 'Resumo Internação'
                    WHEN '06' THEN 'Honorários'
                    ELSE '--'
                END TPGUIA,
                BD7_CODRDA CODRDA, 
                BD7_CODPAD CODPAD, 
                BD7_CODPRO CODPRO,
                BD6_QTDPRO QTDPRO,
                BD7_SEQUEN SEQUEN, 
                SUM(BD7_VLRPAG) VLRPAG, 
                BD7_DATPRO DATPRO            
            FROM (
                SELECT BD7_CODOPE, BD7_TIPGUI, BD7_RECSIP, BD7I.R_E_C_N_O_ FROM %table:BD7% BD7I WHERE BD7I.%notdel%
            ) BD7T
                INNER JOIN %table:BD7% BD7
                    ON BD7.R_E_C_N_O_ = BD7T.R_E_C_N_O_
                INNER JOIN %table:BD6% BD6
                    ON BD6_FILIAL = BD7.BD7_FILIAL 
                    AND BD6_CODOPE = BD7.BD7_CODOPE
                    AND BD6_CODLDP = BD7.BD7_CODLDP 
                    AND BD6_CODPEG = BD7.BD7_CODPEG
                    AND BD6_NUMERO = BD7.BD7_NUMERO 
                    AND BD6_ORIMOV = BD7.BD7_ORIMOV
                    AND BD6_SEQUEN = BD7.BD7_SEQUEN
                    AND BD6.%notdel% 
            WHERE BD7T.BD7_CODOPE = %exp:cCodOpe%
                AND BD7T.BD7_RECSIP = %exp:cAno + cTri%
                AND BD7T.BD7_TIPGUI BETWEEN %exp:cTpGuiDe% AND %exp:cTpGuiAte%
            GROUP BY BD7.BD7_RECSIP, 
                BD7_NUMLOT,
                BD7_OPEUSR || BD7_CODEMP || BD7_MATRIC || BD7_TIPREG || BD6_DIGITO,
                BD7T.BD7_CODOPE || BD7_CODLDP || BD7_CODPEG || BD7_NUMERO || BD7_ORIMOV,
                BD7T.BD7_TIPGUI,

                BD7_CODRDA, 
                BD7_CODPAD, 
                BD7_CODPRO,
                BD6_QTDPRO,
                BD7_SEQUEN, 
                BD7_DATPRO
            ORDER BY 1,4,2,10
        endsql 
    endif

return cAlias

