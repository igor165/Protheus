#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'

Static lF1B_PREDBC  := F1B->(FieldPos("F1B_PREDBC")) > 0
Static lF1B_PERRED  := F1B->(FieldPos("F1B_PERRED")) > 0

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} file
Gerenciador de Processamento
@author    author
@version   version
@since     date
/*/
//------------------------------------------------------------------------------------------
Function FISR153A()

Local oReport
Local ccAlias   := getNextAlias()
Local cPer      := ""

dbSelectArea("F1A")
F1A->(dbSetOrder(1))

If Pergunte("FSR153A",.T.)

    cPer      := year2str( FSA200DataApur ( mv_par01 ) ) + month2str( FSA200DataApur ( mv_par01 ) )

    F1A->( DbSetOrder ( 1 ) )
    If F1A->( MsSeek(xFilial("F1A") +  cPer  ) )
	    cIdApur	:= F1A->F1A_ID
        oReport := xPrintRel(ccAlias, "FISR153A", F1A->F1A_ID)
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
Local oBreak2
Local cTitle    := "Relatório Analítico de Apuração do Simples Nacional"
Local nBorder    := 1 //superior
Local nBorder4   := 4 //direita
Local nBorder3   := 3 //esquerda

oReport	:= TReport():New('FISR153A', cTitle ,cPerg,{|oReport|ReportPrint(oReport,ccAlias, cIdApur)},'')
oReport:SetLandScape()
oReport:HideParamPage()

oReport:SetLineHeight(40)

oSection1 := TRSection():New( oReport, "SubAtividade", {"F17"} )
oSection1:SetPageBreak(.T.)
oSection1:SetHeaderPage(.T.)

TRCell():New(oSection1,"F1B_FILIAL",	"F1B", "Filial"  )
TRCell():New(oSection1,"F17_SUBATV",	"F17", "SubAtividade"  )
TRCell():New(oSection1,"F17_DESCR",		"F17", ""    )

oSection1:Cell("F1B_FILIAL"):lBold := .T.
oSection1:Cell("F17_SUBATV"):lBold := .T.
oSection1:Cell("F17_DESCR"):lBold := .T.
oSection1:Cell("F17_DESCR"):SetLineBreak(.T.)

// Seção 2 - CAbeçalho do tipo da receita  - Excedeu, não excedeu etc..
oSection2 := TRSection():New(oSection1 , "Parcelas das Receitas", {"F1B"})
TRCell():New(oSection2,"F1B_TPPARC",	"F19", "Tipo da Parcela")
TRCell():New(oSection2,"F1B_VLPARC",	"F19", "Base de Cálculo (A)")

oSection2:Cell("F1B_TPPARC"):lBold := .T.
oSection2:Cell("F1B_VLPARC"):lBold := .T.
oSection2:SetBorder(2)

// Seção 3 - Valores da subatividade
oSection3 := TRSection():New(oSection2 , "Memória de Cálculo", {"F1B"})

TRCell():New(oSection3,"F1B_TRIB"       ,	"F1B"   , "Tributo"                         )
TRCell():New(oSection3,"F1B_RECENQ"     ,	"F1B"   , "Receita Enquadramento (B) "      ) 
TRCell():New(oSection3,"F1B_ANEXO"      ,	"F1B"   , "Anexo"                           )
TRCell():New(oSection3,"F1B_FAIXA"      ,	"F1B"   , "Faixa"                           )
TRCell():New(oSection3,"F1B_ALQNOM"     ,	"F1B"   , "% Alq. Nominal (C)"              )
TRCell():New(oSection3,"F1B_VALDED"     ,	"F1B"   , "Val. Dedução (D)"                )
TRCell():New(oSection3,"F1B_EFET"       ,	"F1B"   , "% Alq. Efetiva (E=((B*C)-D)/B) " )
TRCell():New(oSection3,"F1B_PARTTB"     ,	"F1B"   , "% Partilha (F)"                  )
TRCell():New(oSection3,"F1B_EFETTB"     ,	"F1B"   , "% Alq. Efetiva Tributo (G=E*F)"  )
TRCell():New(oSection3,"PERRED"         ,	"F1B"   , "% Red. Base Cálculo (I)"  )
TRCell():New(oSection3,"F1B_VALOR"      ,	"F1B"   , "Val. Tributo (H=A*G)"            )

//Insere linha superior no cabeçalho
oSection3:Cell("F1B_TRIB"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_RECENQ"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_ANEXO"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_FAIXA"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_ALQNOM"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_VALDED"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_EFET"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_PARTTB"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_EFETTB"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("PERRED"):SetBorder(nBorder,1,000000,.T.)
oSection3:Cell("F1B_VALOR"):SetBorder(nBorder,1,000000,.T.)

//Insere linha na direita no cabeçalho
oSection3:Cell("F1B_TRIB"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_RECENQ"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_ANEXO"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_FAIXA"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_ALQNOM"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_VALDED"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_EFET"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_PARTTB"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_EFETTB"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("PERRED"):SetBorder(nBorder4,1,000000,.T.)
oSection3:Cell("F1B_VALOR"):SetBorder(nBorder4,1,000000,.T.)

//Insere linha na direita nas linhas
oSection3:Cell("F1B_TRIB"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_RECENQ"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_ANEXO"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_FAIXA"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_ALQNOM"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_VALDED"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_EFET"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_PARTTB"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_EFETTB"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("PERRED"):SetBorder(nBorder4,1,000000,.F.)
oSection3:Cell("F1B_VALOR"):SetBorder(nBorder4,1,000000,.F.)

oSection3:Cell("F1B_TRIB"):SetBorder(nBorder3,1,000000,.F.)
oSection3:Cell("F1B_TRIB"):SetBorder(nBorder3,1,000000,.T.)

oSection3:SetAutoSize(.T.)
oSection3:Cell("F1B_ANEXO"):nAlign := 2
oSection3:Cell("F1B_FAIXA"):nAlign := 2
oSection3:Cell("F1B_TRIB"):nAlign := 2

oSection3:Cell("F1B_ANEXO"):nHeaderAlign := 2
oSection3:Cell("F1B_FAIXA"):nHeaderAlign := 2
oSection3:Cell("F1B_TRIB"):nHeaderAlign := 2
 
oBreak1 := TRBreak():New(oSection1,{|| F1B_FILIAL + F17_SUBATV  },"Total dos Tributos",.T.,'SubAtividade',.T.) 
oBreak2 := TRBreak():New(oSection2,{|| F1B_FILIAL + F1B_TPPARC  },'Valor Tributo',.F.,'Parcela da Receita',.F.)

Return oReport

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Montar query e abrir em tabela temporária
@author    author
@version   version
@since     date
/*/
//------------------------------------------------------------------------------------------
static function ReportPrint(oReport, ccAlias,  cIdApur)
    local oSection1b := oReport:Section(1)
    local oSection2b := ''
    Local oSection3b := ''    
    Local cFiltro   := ''
    Local cSelect   := ''
    Local cCaseCmp  := ''
    Local cPeriodo := DtoS(cToD("01/" + SubStr(MV_PAR01, 1, 2) + "/" + SubStr(MV_PAR01, 3, 4)))

    oSection2b := oReport:Section(1):Section(1)
    oSection3b := oReport:Section(1):Section(1):Section(1)

    cFiltro = "%"
    cFiltro += "F1B.F1B_IDAPUR		= " + ValToSQL(  cIdApur  ) + " AND "
    cFiltro += "F1B.D_E_L_E_T_ = ' ' ORDER BY F1B.F1B_FILIAL, F1B.F1B_SUBATV, F1B.F1B_TPPARC, F1B.F1B_TRIB  "
    cFiltro += "%"

    cSelect := "%"
    cSelect += "F1B.F1B_FILIAL,F1B.F1B_TRIB,F1B.F1B_RECENQ,F1B.F1B_ANEXO,F1B.F1B_FAIXA, F1B.F1B_ALQNOM, F1B.F1B_VALDED, F1B.F1B_EFET, " 
    cSelect += "F1B.F1B_PARTTB, F1B.F1B_EFETTB, F1B.F1B_SUBATV, " 

    If lF1B_PREDBC .Or. lF1B_PERRED
        cSelect += "(CASE 
    
        If lF1B_PREDBC
            cSelect += " WHEN F1B.F1B_PREDBC > 0 THEN F1B.F1B_PREDBC
            cCaseCmp += " F1B.F1B_PREDBC = 0"
        EndIf
        
        If lF1B_PERRED
            cSelect += " WHEN F1B.F1B_PERRED > 0 THEN F1B.F1B_PERRED
            If !Empty(AllTrim(cCaseCmp))
                cCaseCmp += " AND "
            EndIf
            cCaseCmp += " F1B.F1B_PERRED = 0 "
        EndIf
        
        If !Empty(AllTrim(cCaseCmp))
            cSelect += " WHEN "+cCaseCmp+" THEN 0
        EndIf

        cSelect += " END) PERRED,
    EndIf

    cSelect += " F1B.F1B_VALOR, F1B.F1B_TPPARC,F1B.F1B_VLPARC, F17.F17_SUBATV, F17_DESCR"
    cSelect += "%"

    oSection1b:BeginQuery()
    BeginSql Alias ccAlias    

        SELECT
            %Exp:cSelect%
        FROM
            %TABLE:F1B% F1B
			JOIN %Table:F17% F17 ON( F17.F17_FILIAL = %xFilial:F17% AND F17.F17_SUBATV = F1B.F1B_SUBATV AND F17.%NotDel%)
        WHERE
            %Exp:cFiltro%
    EndSql
    oSection1b:EndQuery()

    oSection2b:SetParentQuery()

    oSection2b:SetParentFilter({|cParam| (ccAlias)->F1B_FILIAL + (ccAlias)->F1B_SUBATV == cParam}, {|| (ccAlias)->F1B_FILIAL + (ccAlias)->F17_SUBATV})

    oSection3b:SetParentQuery()

    oSection3b:SetParentFilter({|cParam| (ccAlias)->F1B_SUBATV + (ccAlias)->F1B_TPPARC   == cParam}, {||  (ccAlias)->F1B_SUBATV +  (ccAlias)->F1B_TPPARC })

    oReport:SetMeter((ccAlias)->(RecCount()))
	oSection1b:Print()

Return