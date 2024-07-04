#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FISR220.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}FISR220
Relatório de conferência das notas fiscais consideradas na composição do coeficiente
de aropriaçãoapropriação do CIAP, por meio da configuração dos CFOPs e CSTs.

@author Erick G Dias
@since 14/03/2019
@version P12.1.23

/*/
//-------------------------------------------------------------------
Function FISR220()

Local oReport
Local cMsg      := ""
Local ccAlias   := getNextAlias()
Local ccAlias2  := getNextAlias()

If AliasIndic("F1F") .AND. AliasIndic("F1G")
    If Pergunte("FISR220",.T.)        
        cMsg    := ChkPerg()
        If Empty(cMsg)        
            oReport := ReportDef(ccAlias, ccAlias2,  "FISR220")
            oReport:PrintDialog()
        
            If Select(ccAlias) > 0
                dbSelectArea(ccAlias)
                (ccAlias)->(DbCloseArea())
            EndIf
            If Select(ccAlias2) > 0
                dbSelectArea(ccAlias2)
                (ccAlias2)->(DbCloseArea())
            EndIf            

        Else
            MsgAlert(cMsg)
        EndIF

    EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}ReportDef

Função que montará a estrutura do relatório

@author Erick G Dias
@since 14/03/2019
@version P12.1.23

/*/
//-------------------------------------------------------------------
Static Function ReportDef(ccAlias, ccAlias2, cPerg )

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local cTitle    := STR0001//"Conferência de notas fiscais consideradas para compor coeficiente de apropriação do CIAP"
Local oBreak1   := Nil
Local nBorder    := 1 //superior
Local nBorder4   := 4 //direita
Local cMtdCoef  := Alltrim(GetNewPar ("MV_MTDCOEF",""))
Local cDivCoef	:= GetNewPar ("MV_DIVCOEF","1")
Default ccAlias   := getNextAlias()
Default ccAlias2   := getNextAlias()

oReport	:= TReport():New('FISR220', cTitle ,cPerg,{|oReport|ReportPrint(oReport,ccAlias,ccAlias2, MV_PAR01)},'')
oReport:SetLandScape()
oReport:HideParamPage()
oReport:SetLineHeight(40)

oSection1 := TRSection():New( oReport, STR0002, {"F1F"} ) //"Operando do Coeficiente CIAP"
oSection1:SetPageBreak(.T.)
oSection1:SetBorder(2)

//Seção 1 - Operando
TRCell():New(oSection1,"F1F_FILIAL", "F1F", STR0003) //"Filial"
TRCell():New(oSection1,"F1F_OPERAN", "F1F", STR0004) //"Operando CIAP"
TRCell():New(oSection1,"F1G_VLORIG", "F1F", STR0005) //"Valor Origem"
TRCell():New(oSection1,"",  "", "","@!",170) 

// Seção 2 - Documentos Fiscais
oSection2 := TRSection():New(oSection1 , "Notas Fiscais", {"SFT"})//"Tributos por Documentos Fiscais"
TRCell():New(oSection2,"FT_NFISCAL", "SFT", STR0006)//"Número NF"
TRCell():New(oSection2,"FT_SERIE",	 "SFT", STR0007) //"Série NF"
TRCell():New(oSection2,"FT_CFOP",    "SFT", STR0008)//"CFOP"
TRCell():New(oSection2,"FT_CLIEFOR", "SFT", STR0009)//"Cod. Participante"
TRCell():New(oSection2,"FT_LOJA",	 "SFT", STR0010)//"Loja Participante"
TRCell():New(oSection2,"FT_EMISSAO", "SFT", STR0011) //"Data"
TRCell():New(oSection2,"FT_ITEM",	 "SFT", STR0012)//"Item NF"
TRCell():New(oSection2,"FT_CLASFIS", "SFT", STR0013)//"CST ICMS"
TRCell():New(oSection2,"FT_VALCONT", "SFT", STR0014)//"Valor Contábil"
TRCell():New(oSection2,"FT_TOTAL"  , "SFT", STR0015)//"Valor Mercadoria"
TRCell():New(oSection2,"FT_BASEICM", "SFT", STR0016)//"Base ICMS"
TRCell():New(oSection2,"FT_ISENICM", "SFT", STR0017)//"Isento"
TRCell():New(oSection2,"FT_OUTRICM", "SFT", STR0018)//"Outros"
TRCell():New(oSection2,"VALORIGEM",    "" , STR0019,"@E 99,999,999,999.99",14,,{||MTA906VOPE((ccAlias)->F1G_VLORIG, (ccAlias)->FT_VALCONT, (ccAlias)->FT_TOTAL, (ccAlias)->FT_ISENICM , (ccAlias)->FT_OUTRICM , (ccAlias)->FT_BASEICM)}) //"Valor de Origem"

//Insere linha superior no cabeçalho
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_ITEM"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_CLASFIS"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_VALCONT"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_TOTAL"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_BASEICM"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_ISENICM"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_OUTRICM"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("VALORIGEM"):SetBorder(nBorder,1,000000,.T.)

//Insere linha na direita no cabeçalho
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_ITEM"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_CLASFIS"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_VALCONT"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_TOTAL"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_BASEICM"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_ISENICM"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_OUTRICM"):SetBorder(nBorder4,1,000000,.T.)

//Insere linha na direita nas linhas
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_ITEM"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_CLASFIS"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_VALCONT"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_TOTAL"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_BASEICM"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_ISENICM"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_OUTRICM"):SetBorder(nBorder4,1,000000,.F.)

//Alinhamento centralizado
oSection2:Cell("FT_NFISCAL"):nAlign := 2
oSection2:Cell("FT_SERIE"):nAlign := 2
oSection2:Cell("FT_CFOP"):nAlign := 2
oSection2:Cell("FT_CLIEFOR"):nAlign := 2
oSection2:Cell("FT_EMISSAO"):nAlign := 2
oSection2:Cell("FT_LOJA"):nAlign := 2
oSection2:Cell("FT_ITEM"):nAlign := 2
oSection2:Cell("FT_CLASFIS"):nAlign := 2
oSection2:SetAutoSize(.T.)

oBreak1 := TRBreak():New(oSection1,{|| (ccAlias)->(F1F_OPERAN) + (ccAlias)->(F1G_VLORIG)   },STR0019 ,.F.,STR0019 ,.T.) //'Total da Regra por Operação NF' //'Total da Regra por Operação NF '
TRFunction():New(oSection2:Cell("VALORIGEM") ,  ,"SUM", oBreak1,STR0019 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.T./*lEndPage*/) //"Valor "
oSection2:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection2:SetHeaderSection(.T.)

oSection3 := TRSection():New( oReport, STR0021, {"F1F"} ) //"Operando do Coeficiente CIAP (Devoluções)"
oSection3:SetPageBreak(.T.)
oSection3:SetBorder(2)

//Seção 1 - Operando
TRCell():New(oSection3,"F1F_FILIAL", "F1F", STR0003) //"Filial"
TRCell():New(oSection3,"F1F_OPERAN", "F1F", STR0004) //"Operando CIAP"
TRCell():New(oSection3,"F1G_VLORIG", "F1F", STR0005) //"Valor Origem"
TRCell():New(oSection3,"",  "", "","@!",170) 

// Seção 2 - Documentos Fiscais
oSection4 := TRSection():New(oSection3 , "Notas Fiscais", {"SFT"})//"Tributos por Documentos Fiscais"
TRCell():New(oSection4,"FT_NFISCAL", "SFT", STR0006)//"Número NF"
TRCell():New(oSection4,"FT_SERIE",	 "SFT", STR0007) //"Série NF"
TRCell():New(oSection4,"FT_CFOP",    "SFT", STR0008)//"CFOP"
TRCell():New(oSection4,"FT_CLIEFOR", "SFT", STR0009)//"Cod. Participante"
TRCell():New(oSection4,"FT_LOJA",	 "SFT", STR0010)//"Loja Participante"
TRCell():New(oSection4,"FT_EMISSAO", "SFT", STR0011) //"Data"
TRCell():New(oSection4,"FT_ITEM",	 "SFT", STR0012)//"Item NF"
TRCell():New(oSection4,"FT_CLASFIS", "SFT", STR0013)    //"CST ICMS"
TRCell():New(oSection4,"FT_VALCONT", "SFT", STR0014)//"Valor Contábil"
TRCell():New(oSection4,"FT_TOTAL"  , "SFT", STR0015)//"Valor Mercadoria"
TRCell():New(oSection4,"FT_BASEICM", "SFT", STR0016)//"Base ICMS"
TRCell():New(oSection4,"FT_ISENICM", "SFT", STR0017)//"Isento"
TRCell():New(oSection4,"FT_OUTRICM", "SFT", STR0018)//"Outros"
TRCell():New(oSection4,"VALORIGEM",    "" , STR0019,"@E 99,999,999,999.99",14,,{||MTA906VOPE((ccAlias2)->F1G_VLORIG, (ccAlias2)->FT_VALCONT, (ccAlias2)->FT_TOTAL, (ccAlias2)->FT_ISENICM , (ccAlias2)->FT_OUTRICM , (ccAlias2)->FT_BASEICM)}) //"Valor de Origem"

//Insere linha superior no cabeçalho
oSection4:Cell("FT_NFISCAL"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_SERIE"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_CFOP"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_CLIEFOR"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_LOJA"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_EMISSAO"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_ITEM"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_CFOP"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_CLASFIS"):SetBorder(nBorder,1,000000,.T.)    
oSection4:Cell("FT_VALCONT"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_TOTAL"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_BASEICM"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_ISENICM"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("FT_OUTRICM"):SetBorder(nBorder,1,000000,.T.)
oSection4:Cell("VALORIGEM"):SetBorder(nBorder,1,000000,.T.)

//Insere linha na direita no cabeçalho
oSection4:Cell("FT_NFISCAL"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_SERIE"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_CLIEFOR"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_LOJA"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_EMISSAO"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_ITEM"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_CLASFIS"):SetBorder(nBorder4,1,000000,.T.)    
oSection4:Cell("FT_VALCONT"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_TOTAL"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_BASEICM"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_ISENICM"):SetBorder(nBorder4,1,000000,.T.)
oSection4:Cell("FT_OUTRICM"):SetBorder(nBorder4,1,000000,.T.)    

//Insere linha na direita nas linhas
oSection4:Cell("FT_NFISCAL"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_SERIE"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_CLIEFOR"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_LOJA"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_EMISSAO"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_ITEM"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_CLASFIS"):SetBorder(nBorder4,1,000000,.F.)    
oSection4:Cell("FT_VALCONT"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_TOTAL"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_BASEICM"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_ISENICM"):SetBorder(nBorder4,1,000000,.F.)
oSection4:Cell("FT_OUTRICM"):SetBorder(nBorder4,1,000000,.F.)    

//Alinhamento centralizado
oSection4:Cell("FT_NFISCAL"):nAlign := 2
oSection4:Cell("FT_SERIE"):nAlign := 2
oSection4:Cell("FT_CFOP"):nAlign := 2
oSection4:Cell("FT_CLIEFOR"):nAlign := 2
oSection4:Cell("FT_EMISSAO"):nAlign := 2
oSection4:Cell("FT_LOJA"):nAlign := 2
oSection4:Cell("FT_ITEM"):nAlign := 2
oSection4:Cell("FT_CLASFIS"):nAlign := 2
oSection4:SetAutoSize(.T.)

oBreak1 := TRBreak():New(oSection3,{|| (ccAlias2)->(F1F_OPERAN) + (ccAlias2)->(F1G_VLORIG)   },"Valor de Origem (Devolução)",.F.,"Valor de Origem (Devolução)",.T.) //'Total da Regra por Operação NF' //'Total da Regra por Operação NF '
TRFunction():New(oSection4:Cell("VALORIGEM") ,  ,"SUM", oBreak1,"Valor de Origem (Devolução)" ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.T./*lEndPage*/) //"Valor "
oSection4:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection4:SetHeaderSection(.T.)

//---------------------
//Seção de Totalizador
//---------------------
oSection5 := TRSection():New( oReport, "Resumo dos Totais" )
oSection5:SetPageBreak(.T.)
oSection5:SetBorder(2)

TRCell():New(oSection5,"A", "", "(A)Tributado","@E 99,999,999,999.99",17)
TRCell():New(oSection5,"B", "", "(B)Dev. Trib.","@E 99,999,999,999.99",17)
TRCell():New(oSection5,"C", "", "(C)Não Trib.","@E 99,999,999,999.99",14)
TRCell():New(oSection5,"D", "", "(D)Dev. Não Trib.","@E 99,999,999,999.99",17)
TRCell():New(oSection5,"E", "", "(E)Exp.","@E 99,999,999,999.99",17)
TRCell():New(oSection5,"F", "", "(F)Dev. Exp.","@E 99,999,999,999.99",17)
TRCell():New(oSection5,"G", "", "(G)Equip.","@E 99,999,999,999.99",17)
TRCell():New(oSection5,"H", "", "(H)Dev. Equip.","@E 99,999,999,999.99",17)
If cDivCoef == "1" .Or. Empty(cDivCoef)
    TRCell():New(oSection5,"I", "", "(I)Tot. Trib=((A-B)+(E-F)+(G-H))","@E 99,999,999,999.99",17)
    TRCell():New(oSection5,"J", "", "(J)Tot. Não Trib.=(C-D)","@E 99,999,999,999.99",17)
    TRCell():New(oSection5,"L", "", "(L)Tot. Saídas=(I+J)","@E 99,999,999,999.99",17)
ElseIf cDivCoef == "2"
    TRCell():New(oSection5,"I", "", "(I)Tot. Trib=((A-B)+(E-F)+(G-H))","@E 99,999,999,999.99",17)
    TRCell():New(oSection5,"J", "", "(J)Tot. Não Trib.=(C-D)","@E 99,999,999,999.99",17)
    TRCell():New(oSection5,"L", "", "(L)Tot. Saídas","@E 99,999,999,999.99",17)
ElseIf cDivCoef == "3"
    TRCell():New(oSection5,"I", "", "(I)Tot. Trib=(A-B)","@E 99,999,999,999.99",17)
    TRCell():New(oSection5,"J", "", "(J)Tot. Não Trib.=(C-D)","@E 99,999,999,999.99",17)
    TRCell():New(oSection5,"L", "", "(L)Tot. Saídas","@E 99,999,999,999.99",17)
EndIf

//Insere linha superior no cabeçalho
oSection5:Cell("A"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("B"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("C"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("D"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("E"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("F"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("G"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("H"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("I"):SetBorder(nBorder,1,000000,.T.)    
oSection5:Cell("H"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("J"):SetBorder(nBorder,1,000000,.T.)
oSection5:Cell("L"):SetBorder(nBorder,1,000000,.T.)

//Insere linha na direita no cabeçalho
oSection5:Cell("A"):SetBorder(nBorder4,1,000000,.T.)
oSection5:Cell("B"):SetBorder(nBorder4,1,000000,.T.)
oSection5:Cell("C"):SetBorder(nBorder4,1,000000,.T.)
oSection5:Cell("D"):SetBorder(nBorder4,1,000000,.T.)
oSection5:Cell("E"):SetBorder(nBorder4,1,000000,.T.)
oSection5:Cell("F"):SetBorder(nBorder4,1,000000,.T.)
oSection5:Cell("G"):SetBorder(nBorder4,1,000000,.T.)
oSection5:Cell("H"):SetBorder(nBorder4,1,000000,.T.)
oSection5:Cell("I"):SetBorder(nBorder4,1,000000,.T.)    
oSection5:Cell("J"):SetBorder(nBorder4,1,000000,.T.)    

//Insere linha na esquerda nas linhas
oSection5:Cell("A"):SetBorder(nBorder4,1,000000,.F.)
oSection5:Cell("B"):SetBorder(nBorder4,1,000000,.F.)
oSection5:Cell("C"):SetBorder(nBorder4,1,000000,.F.)
oSection5:Cell("D"):SetBorder(nBorder4,1,000000,.F.)
oSection5:Cell("E"):SetBorder(nBorder4,1,000000,.F.)
oSection5:Cell("F"):SetBorder(nBorder4,1,000000,.F.)
oSection5:Cell("G"):SetBorder(nBorder4,1,000000,.F.)
oSection5:Cell("H"):SetBorder(nBorder4,1,000000,.F.)
oSection5:Cell("I"):SetBorder(nBorder4,1,000000,.F.)    
oSection5:Cell("J"):SetBorder(nBorder4,1,000000,.F.)    

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc}ReportPrint

Função que fará a query para obter as informações

@author Erick G Dias
@since 14/03/2019
@version P12.1.23

/*/
//-------------------------------------------------------------------
static function ReportPrint(oReport, ccAlias,ccAlias2, dDataProc)
local oSection1b := oReport:Section(1)
local oSection2b := ''
local oSection3b := oReport:Section(2)
local oSection4b := ''
local oSection5b := oReport:Section(3)
Local cFiltro    := ''
Local cMtdCoef  := Alltrim(GetNewPar ("MV_MTDCOEF",""))
Local dDtIni    := FirstDay(dDataProc)
Local dDtFin    := LastDay(dDataProc)

Local nTotalSai     := 0
Local nTotTrib      := 0
Local nTotNaoTrib   := 0
Local aResumo   :={0,0,0,0,0,0,0,0,0,0}
Local cDivCoef	:= GetNewPar ("MV_DIVCOEF","1")

//-------------------------------------------------------------------
oSection2b := oReport:Section(1):Section(1)

cFiltro = "%"
cFiltro  += "F1F.F1F_FILIAL = " + ValToSQL( xFilial("F1F") ) + " AND "
cFiltro  +=	" F1F.F1F_OPERAN IN ('01','03','05','07','09') AND "
cFiltro  += " F1F.D_E_L_E_T_ = ' ' "
cFiltro += "  ORDER BY F1F_OPERAN, FT_EMISSAO, FT_CFOP, FT_CLASFIS"
cFiltro += "%"

oSection1b:BeginQuery()
BeginSql Alias ccAlias    

    SELECT
        F1F.F1F_FILIAL, F1F.F1F_OPERAN, F1G.F1G_VLORIG,
        SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_EMISSAO, SFT.FT_ITEM, SFT.FT_CFOP, SFT.FT_VALCONT,  SFT.FT_CLASFIS,
        SFT.FT_VALCONT, SFT.FT_TOTAL, SFT.FT_ISENICM, SFT.FT_OUTRICM, SFT.FT_BASEICM
    FROM
        %TABLE:F1F% F1F
        JOIN %Table:F1G% F1G ON( F1G.F1G_FILIAL  = %xFilial:F1G%  AND F1G.F1G_IDCAB = F1F.F1F_ID AND F1G.%NotDel%)        
        JOIN %Table:SFT% SFT ON( SFT.FT_FILIAL  =  %xFilial:SFT%  AND SFT.FT_ENTRADA >= %Exp:DToS(dDtIni)%  AND  SFT.FT_ENTRADA <= %Exp:DToS(dDtFin)% AND SFT.FT_DTCANC = ' ' AND SFT.FT_CFOP = F1G.F1G_CFOP AND SUBSTRING(SFT.FT_CLASFIS,2,2) = F1G.F1G_CST AND SFT.%NotDel%)        

    WHERE
        %Exp:cFiltro%
EndSql
oReport:SetTitle(STR0022)//"Notas Fiscais Que compoem Coeficiente CIAP"
oSection1b:EndQuery()

oSection2b:SetParentQuery()

oSection2b:SetParentFilter({|cParam| (ccAlias)->F1F_OPERAN + (ccAlias)->F1G_VLORIG  == cParam}, {|| (ccAlias)->F1F_OPERAN + (ccAlias)->F1G_VLORIG })

oReport:SetMeter((ccAlias)->(RecCount()))
oSection1b:SetTitle(STR0022)//"Notas Fiscais Que compoem Coeficiente CIAP"
oSection1b:Print()

//Função para calcular o resumo dos sub totais
CalcRes(ccAlias, @aResumo)

//-------------------------------------------------------------------

//-------------------------------------------------------------------
If cMtdCoef == "1"
    //Esta seção somente será impressa se o método de composição do coeficiente considerar devoluções automáticas.
    oSection4b := oReport:Section(2):Section(1)

    cFiltro = "%"
    cFiltro  += "F1F.F1F_FILIAL = " + ValToSQL( xFilial("F1F") ) + " AND "
    If cMtdCoef == "1"
        //Operandos de saída
        //Para este método os operandos de devoluções não serão considerados.
        cFiltro  +=	" F1F.F1F_OPERAN IN ('01','03','05','07','09') AND "
    EndIF
    cFiltro  += " F1F.D_E_L_E_T_ = ' ' "
    cFiltro += "  ORDER BY F1F_OPERAN, SFTDEV.FT_EMISSAO, SFTDEV.FT_CFOP, SFTDEV.FT_CLASFIS"
    cFiltro += "%"

    oSection3b:BeginQuery()
    BeginSql Alias ccAlias2    

        SELECT
            CASE WHEN F1F.F1F_OPERAN = '01' then '02'
                 WHEN F1F.F1F_OPERAN = '03' then '04'
                 WHEN F1F.F1F_OPERAN = '05' then '06'
                 WHEN F1F.F1F_OPERAN = '07' then '08'
                 WHEN F1F.F1F_OPERAN = '09' then '10'
            END F1F_OPERAN,
            F1F.F1F_FILIAL,  F1G.F1G_VLORIG,
            SFTDEV.FT_NFISCAL, SFTDEV.FT_SERIE, SFTDEV.FT_CLIEFOR, SFTDEV.FT_LOJA, SFTDEV.FT_EMISSAO, SFTDEV.FT_ITEM, SFTDEV.FT_CFOP, SFTDEV.FT_VALCONT,  SFTDEV.FT_CLASFIS,
            SFTDEV.FT_VALCONT, SFTDEV.FT_TOTAL, SFTDEV.FT_ISENICM, SFTDEV.FT_OUTRICM, SFTDEV.FT_BASEICM
        FROM
            %TABLE:F1F% F1F
            JOIN %Table:F1G% F1G ON( F1G.F1G_FILIAL  = %xFilial:F1G%  AND F1G.F1G_IDCAB = F1F.F1F_ID AND F1G.%NotDel%)
            JOIN %Table:SFT% SFTDEV ON( SFTDEV.FT_FILIAL =  %xFilial:SFT% AND SFTDEV.FT_ENTRADA >= %Exp:DToS(dDtIni)%  AND SFTDEV.FT_ENTRADA <= %Exp:DToS(dDtFin)% AND SFTDEV.FT_DTCANC = ' ' AND SFTDEV.FT_TIPOMOV='E' AND SFTDEV.FT_TIPO='D' AND SFTDEV.%NotDel%)
            JOIN %Table:SFT% SFT ON( SFT.FT_FILIAL  =  %xFilial:SFT%  AND SFT.FT_DTCANC = ' ' AND SFT.FT_CFOP = F1G.F1G_CFOP AND SUBSTRING(SFT.FT_CLASFIS,2,2) = F1G.F1G_CST AND SFT.FT_NFISCAL  = SFTDEV.FT_NFORI  AND SFT.FT_SERIE = SFTDEV.FT_SERORI  AND SFT.FT_ITEM = SFTDEV.FT_ITEMORI AND SFT.FT_CLIEFOR = SFTDEV.FT_CLIEFOR AND SFT.FT_LOJA = SFTDEV.FT_LOJA AND SFT.%NotDel%)            

        WHERE
            %Exp:cFiltro%
    EndSql

    oReport:SetTitle("Devoluções que compoem o Coeficiente CIAP")//"Devoluções que compoem o Coeficiente CIAP"
    oSection3b:EndQuery()

    oSection4b:SetParentQuery()

    oSection4b:SetParentFilter({|cParam| (ccAlias2)->F1F_OPERAN + (ccAlias2)->F1G_VLORIG  == cParam}, {|| (ccAlias2)->F1F_OPERAN + (ccAlias2)->F1G_VLORIG })

    oReport:SetMeter((ccAlias2)->(RecCount()))
    oSection3b:SetTitle("Devoluções que compoem o Coeficiente CIAP")//"Devoluções que compoem o Coeficiente CIAP"
    oSection3b:Print()
    
    //Função para calcular o resumo dos sub totais
    CalcRes(ccAlias2, @aResumo)

ElseIF cMtdCoef == "2"
    //Apresentará as devoluções configuradas 
    
   //Esta seção somente será impressa se o método de composição do coeficiente considerar devoluções automáticas.
    oSection4b := oReport:Section(2):Section(1)

    cFiltro = "%"
    cFiltro  += "F1F.F1F_FILIAL = " + ValToSQL( xFilial("F1F") ) + " AND "
    cFiltro  +=	" F1F.F1F_OPERAN IN ('02','04','06','08','10') AND "
    cFiltro  += " F1F.D_E_L_E_T_ = ' ' "
    cFiltro += "  ORDER BY F1F_OPERAN, FT_EMISSAO, FT_CFOP, FT_CLASFIS"
    cFiltro += "%"


    oSection3b:BeginQuery()
    BeginSql Alias ccAlias2    

    SELECT
        F1F.F1F_FILIAL, F1F.F1F_OPERAN, F1G.F1G_VLORIG,
        SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_EMISSAO, SFT.FT_ITEM, SFT.FT_CFOP, SFT.FT_VALCONT,  SFT.FT_CLASFIS,
        SFT.FT_VALCONT, SFT.FT_TOTAL, SFT.FT_ISENICM, SFT.FT_OUTRICM, SFT.FT_BASEICM
    FROM
        %TABLE:F1F% F1F
        JOIN %Table:F1G% F1G ON( F1G.F1G_FILIAL  = %xFilial:F1G%  AND F1G.F1G_IDCAB = F1F.F1F_ID AND F1G.%NotDel%)        
        JOIN %Table:SFT% SFT ON( SFT.FT_FILIAL  =  %xFilial:SFT%  AND SFT.FT_ENTRADA >= %Exp:DToS(dDtIni)%  AND  SFT.FT_ENTRADA <= %Exp:DToS(dDtFin)% AND SFT.FT_DTCANC = ' ' AND SFT.FT_TIPOMOV='E' AND SFT.FT_TIPO='D' AND SFT.FT_CFOP = F1G.F1G_CFOP AND SUBSTRING(SFT.FT_CLASFIS,2,2) = F1G.F1G_CST AND SFT.%NotDel%)                

    WHERE
        %Exp:cFiltro%
    EndSql

    oReport:SetTitle("Devoluções que compoem o Coeficiente CIAP")//"Devoluções que compoem o Coeficiente CIAP"
    oSection3b:EndQuery()

    oSection4b:SetParentQuery()

    oSection4b:SetParentFilter({|cParam| (ccAlias2)->F1F_OPERAN + (ccAlias2)->F1G_VLORIG  == cParam}, {|| (ccAlias2)->F1F_OPERAN + (ccAlias2)->F1G_VLORIG })

    oReport:SetMeter((ccAlias2)->(RecCount()))
    oSection3b:SetTitle("Devoluções que compoem o Coeficiente CIAP")//"Devoluções que compoem o Coeficiente CIAP"
    oSection3b:Print()
    
    //Função para calcular o resumo dos sub totais
    CalcRes(ccAlias2, @aResumo)    

EndIF

//Seção do resumo será impressa manualmente
oSection5b:Init()
oReport:SetTitle("Resumo dos Totais")

nTotNaoTrib   := Max(aResumo[3] - aResumo[4], 0)
If cDivCoef == "1" .Or. Empty(cDivCoef)
    nTotTrib      := Max((aResumo[1] + aResumo[5] + aResumo[7]) - (aResumo[2] + aResumo[6] + aResumo[8]), 0)
    nTotalSai   := nTotTrib + nTotNaoTrib 
ElseIf cDivCoef == "2"
    nTotTrib      := Max((aResumo[1] + aResumo[5] + aResumo[7]) - (aResumo[2] + aResumo[6] + aResumo[8]), 0)
    nTotalSai   := (aResumo[9] - aResumo[10])
ElseIf cDivCoef == "3"
    nTotTrib      := Max((aResumo[1]) - (aResumo[2]), 0)
    nTotalSai   := (aResumo[9] - aResumo[10])
EndIf

oSection5b:Cell("A"):SetValue(aResumo[1])//VAlor Tributado
oSection5b:Cell("B"):SetValue(aResumo[2])//Devoluções de vendas tributadas
oSection5b:Cell("C"):SetValue(aResumo[3])//Saídas Não tributadas
oSection5b:Cell("D"):SetValue(aResumo[4])//Devoluções de vendas Não Tributadas
oSection5b:Cell("E"):SetValue(aResumo[5])//Exportações
oSection5b:Cell("F"):SetValue(aResumo[6])//Devoluções das Exportações
oSection5b:Cell("G"):SetValue(aResumo[7])//Exportações Equiparadas
oSection5b:Cell("H"):SetValue(aResumo[8])//Devoluções das exportações equiparadas
oSection5b:Cell("I"):SetValue(nTotTrib ) //Total tributado
oSection5b:Cell("J"):SetValue(nTotNaoTrib)//Total não tributado.
oSection5b:Cell("L"):SetValue(nTotalSai)//Total Saídas

oSection5b:PrintLine()
oSection5b:Finish()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}ChkPerg

Função que fará as devidas validações dos parãmetros iniciais

@author Erick G Dias
@since 14/03/2019
@version P12.1.23

/*/
//-------------------------------------------------------------------
Static Function ChkPerg()

Local cRet  := ""

Do Case
    Case Empty(MV_PAR01)
        cRet    := STR0024//"Obrigatório informar a data"
EndCase

Return cRet


Static Function CalcRes(cAlsNF, aResumo)
Local nValor    := 0

(cAlsNF)->(DbGoTop ())
Do While !(cAlsNF)->(Eof())
    
    nValor  := MTA906VOPE((cAlsNF)->F1G_VLORIG, (cAlsNF)->FT_VALCONT, (cAlsNF)->FT_TOTAL, (cAlsNF)->FT_ISENICM , (cAlsNF)->FT_OUTRICM , (cAlsNF)->FT_BASEICM)

    If (cAlsNF)->F1F_OPERAN == "01"    
        aResumo[1]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "02"
        aResumo[2]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "03"
        aResumo[3]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "04"
        aResumo[4]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "05"
        aResumo[5]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "06"
        aResumo[6]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "07"
        aResumo[7]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "08"                        
        aResumo[8]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "09"                        
        aResumo[9]  += nValor
    ElseIf (cAlsNF)->F1F_OPERAN == "10"                        
        aResumo[10]  += nValor
    Endif

    (cAlsNF)->(DbSkip ())
EndDo

Return