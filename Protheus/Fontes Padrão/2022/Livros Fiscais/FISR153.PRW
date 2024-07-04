#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} file
Gerenciador de Processamento
@author    author
@version   version
@since     date
/*/
//------------------------------------------------------------------------------------------
Function FISR153()

Local oReport
Local ccAlias   := getNextAlias()
Local cPer      := ""

dbSelectArea("F1A")
F1A->(dbSetOrder(1))

If Pergunte("FSR153",.T.)

    cPer      := year2str( FSA200DataApur ( mv_par01 ) ) + month2str( FSA200DataApur ( mv_par01 ) )

    F1A->( DbSetOrder ( 1 ) )
    If F1A->( MsSeek(xFilial("F1A") +  cPer  ) )
	    cIdApur	:= F1A->F1A_ID
        oReport := xPrintRel(ccAlias,  "FISR153", F1A->F1A_ID)
        oReport:PrintDialog()
    Else
        Alert("Não existe apuração para o período informado!")
    EndIF

EndIF

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} xPrintRel
Imprimir Relatório
@author    author
@version   version
@since     date
/*/
//------------------------------------------------------------------------------------------
Static Function xPrintRel(ccAlias, cPerg, cIdApur)

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oBreak1
Local cTitle    := "Relatório Sintético de Apuração do Simples Nacional"
Local oTot1 := NIL
Local oTot2 := NIL
Local oTot3 := NIL
Local oTot4 := NIL
Local oTot5 := NIL
Local oTot6 := NIL
Local oTot7 := NIL
Local oTot8 := NIL
Local oTot9 := NIL
Local oTot10:= NIL
Local nBorder1 := 1
Local nBorder4 := 4

oReport	:= TReport():New('FISR153', cTitle ,cPerg,{|oReport|ReportPrint(oReport,ccAlias, cIdApur)},'')
oReport:SetLandScape()
oReport:HideParamPage()

oReport:SetLineHeight(40)

oSection1 := TRSection():New( oReport, "Atividades", {"F12"} )
oSection1:SetPageBreak(.T.)
oSection1:SetHeaderPage(.T.)
oSection1:SetAutoSize(.T.)

TRCell():New(oSection1,"F12_CODATV", "F12", "Atividade")
TRCell():New(oSection1,"F12_DESCR",	"F12", "")

oSection1:Cell("F12_CODATV"):lBold := .T.
oSection1:Cell("F12_DESCR"):lBold := .T.
oSection1:Cell("F12_DESCR"):SetLineBreak(.T.)

// Seção 2 - Descrição da subatividade
oSection2 := TRSection():New(oSection1 , "Subatividades", {"F19", "F17"})
TRCell():New(oSection2,"F19_SUBATV",	"F19", "Subatividade")
TRCell():New(oSection2,"F17_DESCR",	    "F17", "Descrição")

oSection2:Cell("F19_SUBATV"):lBold := .T.
oSection2:Cell("F17_DESCR"):lBold := .T.
//oSection2:Cell("F17_DESCR"):SetLineBreak(.T.)

// Seção 3 - Valores da subatividade
oSection3 := TRSection():New(oSection2 , "Valores da Sub Atividade", {"F19"})


TRCell():New(oSection3,"F19_FILIAL",	"F19", "Filial")
TRCell():New(oSection3,"F19_TOTREC",	"F19", "Receita")
TRCell():New(oSection3,"F19_IRPJ",		"F19", "IRPJ")
TRCell():New(oSection3,"F19_CSLL",		"F19", "CSLL")
TRCell():New(oSection3,"F19_COFINS",	"F19", "COFINS")
TRCell():New(oSection3,"F19_PIS",		"F19", "PIS")
TRCell():New(oSection3,"F19_CPP",		"F19", "CPP")
TRCell():New(oSection3,"F19_IPI",		"F19", "IPI")
TRCell():New(oSection3,"F19_ICMS",		"F19", "ICMS")
TRCell():New(oSection3,"F19_ISS",		"F19", "ISS")
TRCell():New(oSection3,"F19_TOTAL",		"F19", "Total dos Tributos")

oSection3:SetAutoSize(.T.)

//Insere linha superior no cabeçalho
oSection3:Cell("F19_FILIAL"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_TOTREC"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_IRPJ"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_CSLL"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_COFINS"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_PIS"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_CPP"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_IPI"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_ICMS"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_ISS"):SetBorder(nBorder1,1,000000,.T.)
oSection3:Cell("F19_TOTAL"):SetBorder(nBorder1,1,000000,.T.)


oBreak1 := TRBreak():New(oSection1,{|| oSection1:Cell('F12_CODATV') },'Totais da Atividade',.F.,'Atividade',.T.)

oTot1  := TRFunction():New(oSection3:Cell("F19_TOTREC") ,"TOT1"  ,"SUM", /*oBreak*/oBreak1,"Receita "           ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot2  := TRFunction():New(oSection3:Cell("F19_ICMS")   ,"TOT2"  ,"SUM", /*oBreak*/oBreak1,"ICMS "              ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot3  := TRFunction():New(oSection3:Cell("F19_ISS")    ,"TOT3"  ,"SUM", /*oBreak*/oBreak1,"ISS "               ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot4  := TRFunction():New(oSection3:Cell("F19_IPI")    ,"TOT4"  ,"SUM", /*oBreak*/oBreak1,"IPI "               ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot5  := TRFunction():New(oSection3:Cell("F19_PIS")    ,"TOT5"  ,"SUM", /*oBreak*/oBreak1,"PIS "               ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot6  := TRFunction():New(oSection3:Cell("F19_COFINS") ,"TOT6"  ,"SUM", /*oBreak*/oBreak1,"COFINS "            ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot7  := TRFunction():New(oSection3:Cell("F19_CSLL")   ,"TOT7"  ,"SUM", /*oBreak*/oBreak1,"CSLL "              ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot8  := TRFunction():New(oSection3:Cell("F19_CPP")    ,"TOT8"  ,"SUM", /*oBreak*/oBreak1,"CPP "               ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot9  := TRFunction():New(oSection3:Cell("F19_IRPJ")   ,"TOT9"  ,"SUM", /*oBreak*/oBreak1,"IRPJ "              ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTot10 := TRFunction():New(oSection3:Cell("F19_TOTAL")  ,"TOT10" ,"SUM", /*oBreak*/oBreak1,"Tributos "          ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

Return oReport


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Montar query e abrir em tabela temporária
@author    author
@version   version
@since     date
/*/
//------------------------------------------------------------------------------------------
static function ReportPrint(oReport, ccAlias, cIdApur)
    local oSection1b := oReport:Section(1)
    local oSection2b := ''
    Local oSection3b := ''
    Local cFiltro   := ''
    Local cPeriodo := DtoS(cToD("01/" + SubStr(MV_PAR01, 1, 2) + "/" + SubStr(MV_PAR01, 3, 4)))

    oSection2b := oReport:Section(1):Section(1)

    oSection3b := oReport:Section(1):Section(1):Section(1)

    cFiltro = "%"
    cFiltro += "F19.F19_IDAPUR		= " + ValToSQL(  cIdApur  ) + " AND "
    cFiltro += "F19.D_E_L_E_T_		= ' ' ORDER BY F12.F12_CODATV, F19.F19_SUBATV  "
    cFiltro += "%"

    oSection1b:BeginQuery()

    BeginSql Alias ccAlias

        COLUMN F19_PER AS DATE

        SELECT
            F12.*, F17.*, F19.*
        FROM
            %TABLE:F19% F19
			JOIN %Table:F12% F12 ON( F12.F12_FILIAL = %xFilial:F12% AND F12.F12_CODATV = F19.F19_CODATV AND F12.%NotDel%)
            JOIN %Table:F17% F17 ON( F17.F17_FILIAL = %xFilial:F17% AND F17.F17_SUBATV = F19.F19_SUBATV AND F17.%NotDel%)
        WHERE
            %Exp:cFiltro%
    EndSql

    oSection1b:EndQuery()

    oSection2b:SetParentQuery()

    oSection2b:SetParentFilter({|cParam| (ccAlias)->F19_CODATV == cParam}, {|| (ccAlias)->F12_CODATV})

    oSection3b:SetParentQuery()

    oSection3b:SetParentFilter({|cParam| (ccAlias)->F19_SUBATV == cParam}, {|| (ccAlias)->F19_SUBATV})

    oReport:SetMeter((ccAlias)->(RecCount()))

	oSection1b:Print()

return