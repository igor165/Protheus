#Include "PCOR070.CH"
#Include "PROTHEUS.CH"

#DEFINE COD_CONTA  1
#DEFINE DES_CONTA  2

//Receitas
#DEFINE PRE_INI    3
#DEFINE REC_SUPL   4
#DEFINE PRE_ATU    5
#DEFINE REC_REANOM 6
#DEFINE REC_REATM  7
#DEFINE REC_PERCRE 8
#DEFINE REC_ANALIT 9

//Despesas
#DEFINE DOT_INI    3
#DEFINE DESP_CRED  4
#DEFINE DESP_SUPL  5
#DEFINE DOT_ATU    6
#DEFINE DES_EMP    7
#DEFINE DES_LIQ    8
#DEFINE DES_PGNOM  9
#DEFINE DES_PGATM  10
#DEFINE DES_PERCRE 11
#DEFINE DES_ANALIT 12

#DEFINE TAM_DESC 30
//amarrar novamente falha ferramenta
//-------------------------------------------------------------------
/*{Protheus.doc} PCOR070
Relatorio de Balanco Orcamentario

@author Totvs
   
@version P12
@since   13/02/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR070()

Local oReport
Local cFindSX1 := Padr("PCOR070", Len(SX1->X1_GRUPO), " ")
Local dDtRefOld := dDataBase
Local lContinua := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01    Exercício:           									³
//³ mv_par02    Conta Orçamentária Despesas De:							³
//³ mv_par03    Conta Orçamentária Despesas Até:						³
//³ mv_par04    Conta Orçamentária Receitas De:							³
//³ mv_par05    Conta Orçamentária Receitas Até:						³
//³ mv_par06    Config. Dot. Inicial:   								³
//³ mv_par07    Config. Dot. Atualizada:               				    ³
//³ mv_par08    Config. Desp. Empenhadas:  								³
//³ mv_par09 	Config. Desp. Liquidadas:                           	³
//³ mv_par10 	Config. Desp Pagas:                                 	³
//³ mv_par11 	Config. Total Despesas:                                	³
//³ mv_par12    Config. Previsao Inicial Rec:							³
//³ mv_par13    Config. Previsao Atualizada Rec:						³
//³ mv_par14    Config. Receitas Realizadas:    						³
//³ mv_par15    Codigo do Cubo:                    						³
//³ mv_par16    Moeda:                    						        ³
//³ mv_par17    Divide por:        				    					³
//³ mv_par18    Leiaute do Relatorio:			    					³
//³ mv_par19    Config. Creditos Adicionais:        					³
//³ mv_par20    Tipo Calc. Cred. Adicionais:        					³
//³ mv_par21    Data Final                           					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0024), 1, 0) //"Relatório Balanço Orçamentário disponível a partir da versao 12.1.23"
ElseIf !SX1->(dbSeek(cFindSX1))
    Help(,, "Help",, OemToAnsi(STR0025), 1, 0) //"Para utilizaçao do relatório Balanço Orçamentário é necessário aplicar o pacote acumulado da controladoria."
ElseIf !SX1->(dbSeek(cFindSX1+"21"))          //verifica se foi aplicado pacote que tem a pergunta 21 - Data Final - solicitacao do CRC pois nao pode retroceder database
    Help(,, "Help",, OemToAnsi(STR0025), 1, 0) //"Para utilizaçao do relatório Balanço Orçamentário é necessário aplicar o pacote acumulado da controladoria."
Else 
    //Perguntas do Relatório
    Pergunte("PCOR070", .T.)   

    If ! Empty(MV_PAR21)
        If Year(MV_PAR21) != Val(MV_PAR01) //ANO DATA BASE DO SISTEMA DEVE SER IGUAL AO ANO EXERCICIO          
            Help(,, "Help",, OemToAnsi(STR0056), 1, 0) //"Relatório Balanço Orçamentário somente disponível para o Ano Exercicio informado."
            lContinua := .F.
        Else
            dDataBase := MV_PAR21  //ASSUME DATA BASE DO SISTEMA A DATA FINAL DO PERIODO PASSADO NO PARAMETRO 21
        EndIf
    EndIf

    If lContinua
        oReport := ReportDef()

        If ValType(oReport) == "O"  
          
            oReport:PrintDialog()
        EndIf
    EndIf

    oReport := Nil

EndIf

dDataBase := dDtRefOld  //volta dDataBase gravado no inicio da rotina

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que serao 
utilizadas 
Imprime o relatorio do Balanco Orcamentario

@author Totvs
   
@version P12
@since   13/02/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef()

Local oReport, oCabRec, oCabDesp, oReceitas, oDespesas, oQuadro1, oNotExplic
Local cDescri 	:= OemToAnsi(STR0001) //"Este programa ira imprimir o Relatorio de Balanço Orçamentário."	
Local cTitulo 	:= OemToAnsi(STR0002) //"Balanço Orçamentário"
Local cCompTit  := ""
Local cPerg	    := "PCOR070"
Local cNomeProg := "PCOR070"
Local nDivide   := 1
Local cPerioDe  := "01" + "/" + "01" + "/" + MV_PAR01 //Período De - primeiro dia e primeiro mes do ano de exercício
Local cPerioAte := StrZero(Day(dDataBase), 2) + "/" + StrZero(Month(dDataBase), 2) + "/" + MV_PAR01 //Período Ate - data base do sistema + ano de exercício
Local nLeiaute  := MV_PAR18
Local aArea	    := GetArea()  

//Divide por
If mv_par17 == 2     //Divide por cem
	nDivide := 100
ElseIf mv_par17 == 3 //Divide por mil
	nDivide := 1000
ElseIf mv_par17 == 4 //Divide por milhao
	nDivide := 1000000
EndIf

If nDivide > 1
    cCompTit  := "(" + OemToAnsi(STR0019) + CValToChar(nDivide) + ")" //"DIV."
EndIf

oReport := TReport():New(cNomeProg, cTitulo + cCompTit, cPerg, {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport, nDivide), .T., oReport:CancelPrint())}, cDescri)
oReport:SetTotalInLine(.F.)
oReport:ParamReadOnly(.T.)
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como retrato
oReport:DisableOrientation() //Desabilita opcao para mudar orientacao de impressao

oCabRec := TRSection():New(oReport, STR0003, {}, /*aOrdem*/) //"Receitas Orcamentarias"
TRCell():New(oCabRec, "REC_ORC"   , "", STR0026          ,, 60, /*lPixel*/, /*CodeBlock*/, "LEFT",, "LEFT",,,,,, .T.) //"R E C E I T A S   O R C A M E N T A R I A S"
TRCell():New(oCabRec, "REC_PERDE" , "", STR0028+cPerioDe ,, 30, /*lPixel*/, /*CodeBlock*/, "LEFT",, "LEFT",,,,,, .T.) //"Período de: "
TRCell():New(oCabRec, "REC_PERATE", "", STR0029+cPerioAte,, 30, /*lPixel*/, /*CodeBlock*/, "LEFT",, "LEFT",,,,,, .T.) //"Período até: "
oCabRec:Cell("REC_ORC"):SetBorder("BOTTOM",,, .T.)
oCabRec:setLinesBefore(0)

oReceitas := TRSection():New(oReport, STR0003,, /*aOrdem*/) //"Receitas Orcamentarias"
TRCell():New(oReceitas, "CONTA"     , "", STR0004 + CHR(13)+CHR(10) + STR0030 , PesqPict("AK5", "AK5_CODIGO"), TamSx3("AK5_CODIGO")[1], /*lPixel*/, /*CodeBlock*/, "LEFT" ,.T., "LEFT" ,, 2) //"Conta" #"Orcamentaria"
TRCell():New(oReceitas, "DESCRICAO" , "", STR0005                             , PesqPict("AK5", "AK5_DESCRI"), TAM_DESC                     , /*lPixel*/, /*CodeBlock*/, "LEFT" ,.T., "LEFT" ,, 2) //"Descricao"

If nLeiaute == 1 //Modelo 1 do Relatorio
    TRCell():New(oReceitas, "NOTAEXP"   , "", STR0044                            , "@!"                         , 6                      , /*lPixel*/, /*CodeBlock*/, "LEFT" ,.T., "LEFT" ,, 2)    //"NE"
    TRCell():New(oReceitas, "PREV_INI"  , "", STR0006 + CHR(13)+CHR(10) + STR0031, PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Previsao" #"Inicial"
    TRCell():New(oReceitas, "PREV_ATU"  , "", STR0006 + CHR(13)+CHR(10) + STR0007, PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Previsao" #"Atualizada"
    TRCell():New(oReceitas, "REC_REATEM", "", STR0008 + CHR(13)+CHR(10) + STR0032, PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Receitas" #"Realizadas"
    TRCell():New(oReceitas, "SALDO"     , "", STR0009                            , PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Saldo"
Else //Modelo 2 do Relatorio
    TRCell():New(oReceitas, "PREV_INI"  , "", STR0006 + CHR(13)+CHR(10) + STR0031, PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,  , .T.) //"Previsao" #"Inicial"
    TRCell():New(oReceitas, "REC_SUPL"  , "", STR0033                            , PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.)      //"Suplementacao"
    TRCell():New(oReceitas, "PREV_ATU"  , "", STR0006 + CHR(13)+CHR(10) + STR0007, PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.)      //"Previsao" #"Atualizada"
    TRCell():New(oReceitas, "REC_REANOM", "", STR0034 + CHR(13)+CHR(10) + STR0035, PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.)      //"Rec. Realizadas" #"no mes"
    TRCell():New(oReceitas, "REC_REATEM", "", STR0034 + CHR(13)+CHR(10) + STR0036, PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.)      //"Rec. Realizadas" #"ate o mes"
    TRCell():New(oReceitas, "REC_PERCRE", "", STR0037                            , "@E 999.999"                 , 7                      , /*lPixel*/, /*CodeBlock*/, "LEFT" ,, "LEFT" ,,, .T.)      //"%"
    TRCell():New(oReceitas, "SALDO"     , "", STR0009                            , PesqPict("AKT", "AKT_MVCRD1"), TamSx3("AKT_MVCRD1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.)      //"Saldo"
EndIf

oCabDesp := TRSection():New(oReport, STR0011, {}, /*aOrdem*/) //"Despesas Orcamentarias"
TRCell():New(oCabDesp, "DESP_ORC"   , "", STR0027          , /*Picture*/, 60, /*lPixel*/, /*CodeBlock*/, "LEFT",, "LEFT",,,,,, .T.) //"D E S P E S A S   O R C A M E N T A R I A S"
TRCell():New(oCabDesp, "DESP_PERDE" , "", STR0028+cPerioDe , /*Picture*/, 30, /*lPixel*/, /*CodeBlock*/, "LEFT",, "LEFT",,,,,, .T.) //"Período de: "
TRCell():New(oCabDesp, "DESP_PERATE", "", STR0029+cPerioAte, /*Picture*/, 30, /*lPixel*/, /*CodeBlock*/, "LEFT",, "LEFT",,,,,, .T.) //"Período até: "
oCabDesp:Cell("DESP_ORC"):SetBorder("BOTTOM",,, .T.)

oDespesas := TRSection():New(oReport, STR0011, {}, /*aOrdem*/) //"Despesas Orcamentarias"
TRCell():New(oDespesas, "CONTA"    , "", STR0004 + CHR(13)+CHR(10) + STR0030, PesqPict("AK5", "AK5_CODIGO"), TamSx3("AK5_CODIGO")[1], /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 2) //"Conta" ##"Orçamentaria"
TRCell():New(oDespesas, "DESCRICAO", "", STR0005                            , PesqPict("AK5", "AK5_DESCRI"), TAM_DESC                     , /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 2) //"Descricao"

If nLeiaute == 1 //Modelo 1 do Relatorio
    TRCell():New(oDespesas, "NOTAEXP"   , "", STR0044                            , "@!"                         , 6                      , /*lPixel*/, /*CodeBlock*/, "LEFT" ,.T., "LEFT" ,, 2)    //"NE"
    TRCell():New(oDespesas, "DOT_INI"   , "", STR0012 + CHR(13)+CHR(10) + STR0031, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Dotacao" #"Inicial"
    TRCell():New(oDespesas, "CRED_ADI"  , "", STR0048                            , PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Creditos Adicionais"
    TRCell():New(oDespesas, "DOT_ATU"   , "", STR0012 + CHR(13)+CHR(10) + STR0007, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Dotacao" #"Atualizada"
    TRCell():New(oDespesas, "DESP_EMP"  , "", STR0013 + CHR(13)+CHR(10) + STR0014, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Despesas" #"Empenhadas"
    TRCell():New(oDespesas, "DESP_LIQUI", "", STR0013 + CHR(13)+CHR(10) + STR0015, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Despesas" #"Liquidadas"
    TRCell():New(oDespesas, "DESP_PGATM", "", STR0013 + CHR(13)+CHR(10) + STR0016, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",   , "RIGHT",,, .T.) //"Despesas" #"Pagas"
Else //Modelo 2 do Relatorio
    TRCell():New(oDespesas, "DOT_INI"    , "", STR0012 + CHR(13)+CHR(10) + STR0031, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.) //"Dotacao" #"Inicial"
    TRCell():New(oDespesas, "DESP_SUPL"  , "", STR0033 + CHR(13)+CHR(10) + STR0038, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.) //"Suplementacao" #"Anulacao"
    TRCell():New(oDespesas, "DOT_ATU"    , "", STR0012 + CHR(13)+CHR(10) + STR0007, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.) //"Dotacao" #"Atualizada"
    TRCell():New(oDespesas, "DESP_EMP"   , "", STR0013 + CHR(13)+CHR(10) + STR0014, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.) //"Despesas" #"Empenhadas"
    TRCell():New(oDespesas, "DESP_LIQUI" , "", STR0013 + CHR(13)+CHR(10) + STR0015, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.) //"Despesas" #"Liquidadas"
    TRCell():New(oDespesas, "DESP_PGNOM" , "", STR0039 + CHR(13)+CHR(10) + STR0035, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.) //"Desp. Pagas" #""no mes""
    TRCell():New(oDespesas, "DESP_PGATM" , "", STR0039 + CHR(13)+CHR(10) + STR0036, PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.) //"Desp. Pagas" #"ate o mes"
    TRCell():New(oDespesas, "DESP_PERCRE", "", STR0037                            , "@E 999.999"                 , 7                      , /*lPixel*/, /*CodeBlock*/, "LEFT" ,, "LEFT" ,,, .T.) //"%"
    TRCell():New(oDespesas, "SALDO"      , "", STR0009                            , PesqPict("AKT", "AKT_MVDEB1"), TamSx3("AKT_MVDEB1")[1], /*lPixel*/, /*CodeBlock*/, "RIGHT",, "RIGHT",,, .T.) //"Saldo"
EndIf

If nLeiaute == 1 //Modelo 1 do Relatorio
    //Criacao da Secao Quadro I - TITULO DO RELATORIO
    oQuadro1 := TRSection():New(oReport, STR0049, {}, /*aOrdem*/,,,, .F. /*<lTotalInLine>*/,,,,,, .T. /*<lLineStyle>*/,,,, 0 /*<nLinesBefore>*/, 1/*<nCols>*/) //"Quadro I"
    TRCell():New(oQuadro1, "TITREL1",, "",, 140, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
    TRCell():New(oQuadro1, "TITREL2",, "",, 140, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)  

    //Criacao da Secao Nota Explicativa
    oNotExplic := TRSection():New(oReport, STR0050, {}, /*aOrdem*/ ,,,, .F./*<lTotalInLine>*/,,,,,, .T./*<lLineStyle>*/,,,, 0 /*<nLinesBefore>*/, 1/*<nCols>*/) //"Nota Explicativa"
    TRCell():New(oNotExplic, "CODNOT",, STR0051,,  10, /*lPixel*/, /*CodeBlock*/,      ,   ,        ,,,,,, .T.) //"Código NE"
    TRCell():New(oNotExplic, "DATNOT",, STR0052,,  10, /*lPixel*/, /*CodeBlock*/,      ,   ,        ,,,,,,)     //"Data NE"
    TRCell():New(oNotExplic, "OBSNOT",, STR0053,, 140, /*lPixel*/, /*CodeBlock*/,"LEFT",.T.,"CENTER",,,,,,)     //"Observ.NE"
EndIf

RestArea(aArea)

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao utilizadas 
Imprime o relatorio Balanço Orçamentário

@author Totvs
   
@version P12
@since   14/02/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport, nDivide)

Local nLeiaute := MV_PAR18

If nLeiaute == 1 //Imprime Receitas e Despesas - Leiaute 1
    Pco70Mod1(oReport, nDivide)
ElseIf nLeiaute == 2 //Imprime Receitas e Despesas - Leiaute 2
    Pco70Mod2(oReport, nDivide)
EndIf

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Pco70Mod1
Imprime o relaótio Balanco Orcamentario - Leiaute 1

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco70Mod1(oReport, nDivide)

Local oCabRec    := oReport:Section(1)
Local oReceitas	 := oReport:Section(2)
Local oCabDesp   := oReport:Section(3)
Local oDespesas	 := oReport:Section(4)
Local oQuadro1	 := oReport:Section(5)
Local oNotExplic := oReport:Section(6)
Local cDescAux   := ""
Local cNotaExp   := ""
Local cDtAKTDe   := MV_PAR01 + "01" + "01" //Exercicio De
Local cDtAKTAte  := MV_PAR01 + StrZero(Month(dDataBase), 2) + StrZero(Day(dDataBase), 2) //Exercicio Ate
Local nI         := 0
Local nSaldo     := 0
Local nPreIni    := 0
Local nDotIni    := 0
Local nPreIniTot := 0 //Previsao Inicial Total
Local nDotIniTot := 0 //Dotacao Inicial Total
Local nDeficit   := 0
Local nSuperAv   := 0
Local nTotRecAnt := 0
Local nTotDesAnt := 0
Local nSaldoAnt  := 0
Local nTotRec    := 0
Local nTotDesp   := 0
Local aReceitas  := {}
Local aDespesas  := {}
Local aRecAnt    := {}
Local aDespAnt   := {}
Local aNotaExp   := {}
Local nCredAdi   := MV_PAR20 //Tipo de Calculo para Creditos Adicionais

//Busca de saldos
Pco70GerMov(cDtAKTDe, cDtAKTAte, aReceitas, aDespesas, @nTotRec, @nTotDesp, nDivide)

//Busca de saldos do periodo anterior
cDtAKTDe  := CValToChar(Val(MV_PAR01) - 1) + "01" + "01" //Exercicio De
cDtAKTAte := CValToChar(Val(MV_PAR01) - 1) + "12" + "31" //Exercicio Ate

Pco70GerMov(cDtAKTDe, cDtAKTAte, aRecAnt, aDespAnt, @nTotRecAnt, @nTotDesAnt, nDivide)

//Retorna valores das datas originais
cDtAKTDe  := MV_PAR01 + "01" + "01" //Exercicio De
cDtAKTAte := MV_PAR01 + StrZero(Month(dDataBase), 2) + StrZero(Day(dDataBase), 2) //Exercicio Ate

If Len(aReceitas) > 0
    //Armazena Deficit e Total das receitas como ultimos registros
    For nI := 1 To 3
        If nI == 1
            cDescAux := STR0045 //"SUBTOTAL"
        ElseIf nI == 2
            cDescAux := STR0042 //"DEFICIT"
        Else
            cDescAux := STR0018 //"TOTAL"
        EndIf

        aAdd(aReceitas, { "",;     //1-Conta 
                        cDescAux,; //2-Descricao #SUBTOTAL ##DEFICIT ###TOTAL                         
                        0,;        //3-Previsao Inicial
                        0,;        //4-Suplementacao                       
                        0,;        //5-Previsao Atualizada
                        0,;        //6-Receitas Realizadas no mes            
                        0,;        //7-Receitas Realizadas ate o mes
                        0,;        //8-Percentual Realizado
                        "" })      //9-Analitico/Sintetico  
    Next nI
    
    //Imprime Cabecalho
    oCabRec:Init()
    oCabRec:Printline()   
    oCabRec:Finish() 

    oReceitas:Init()    
EndIf

For nI := 1 To Len(aReceitas)        
    If oReport:Cancel()
        Exit
    EndIf
        
    oReport:IncMeter() //Regua
    If nI == 1 .And. aReceitas[nI][REC_ANALIT] == '0'
        aReceitas[nI][REC_REATM] := nTotRec
    EndIf
    

    nPreIni := IIF(aReceitas[nI][PRE_ATU] > 0, aReceitas[nI][PRE_ATU], aReceitas[nI][PRE_INI]) //Previsao inicial        
    nSaldo  := nPreIni - aReceitas[nI][REC_REATM] //Calculo do Saldo

    //Tratamento quando nao é Antepenultimo registro
    If nI < (Len(aReceitas) - 2) 
        aReceitas[nI][REC_PERCRE] := aReceitas[nI][REC_REATM] / nPreIni * 100 //Percentual Realizado 

        If aReceitas[nI][REC_ANALIT] == "1" //Soma Total receitas analiticas
            aReceitas[Len(aReceitas)-2][PRE_INI] += aReceitas[nI][PRE_INI] //SubTotal Previsao inicial
            
            If aReceitas[nI][PRE_ATU] > 0                
                aReceitas[Len(aReceitas)-2][REC_SUPL] += aReceitas[nI][PRE_ATU] - aReceitas[nI][PRE_INI] //SubTotal Suplementacao
            EndIf

            aReceitas[Len(aReceitas)-2][PRE_ATU]    += aReceitas[nI][PRE_ATU]     //SubTotal Previsao atualizada
            aReceitas[Len(aReceitas)-2][REC_REANOM] += aReceitas[nI][REC_REANOM]  //SubTotal Receitas realizadas no mes
            aReceitas[Len(aReceitas)-2][REC_REATM]  += aReceitas[nI][REC_REATM]   //SubTotal Receitas realizadas                  
        EndIf                
    ElseIf nI == (Len(aReceitas) - 2) //Antepenultimo registro, armazena SubTotal
        nPreIniTot := IIF(aReceitas[nI][PRE_ATU] > 0, aReceitas[nI][PRE_ATU], aReceitas[nI][PRE_INI]) //Previsao inicial Total
        aReceitas[nI][REC_PERCRE] := aReceitas[nI][REC_REATM] / nPreIniTot * 100  //Total Percentual Receitas realizadas  
    ElseIf nI == (Len(aReceitas) - 1) //Penultimo registro, armazena Deficit
        aReceitas[nI][REC_REATM] := nTotDesp - nTotRec
    ElseIf nI == Len(aReceitas) //Ultimo registro, armazena Total Receitas
        nDeficit := nTotDesp - nTotRec
        aReceitas[nI][REC_REATM] := aReceitas[Len(aReceitas) - 2][REC_REATM] - IIF(nDeficit > 0, nDeficit, 0)  
    EndIf

    oReceitas:Cell("CONTA"):SetBlock({|| aReceitas[nI][COD_CONTA]})
    oReceitas:Cell("DESCRICAO"):SetBlock({|| OemToAnsi(aReceitas[nI][DES_CONTA])})
    
    //Nota Explicativa
    If !Empty(aReceitas[nI][COD_CONTA])
        cNotaExp := Pco70NExp(aReceitas[nI][COD_CONTA], aNotaExp)      
    Else
        cNotaExp := "" 
    EndIf

    oReceitas:Cell("NOTAEXP"):SetBlock({|| OemToAnsi(cNotaExp)})
    oReceitas:Cell("PREV_INI"):SetBlock({|| aReceitas[nI][PRE_INI]})
    oReceitas:Cell("PREV_ATU"):SetBlock({|| aReceitas[nI][PRE_ATU]})
    oReceitas:Cell("REC_REATEM"):SetBlock({|| aReceitas[nI][REC_REATM]})
    oReceitas:Cell("SALDO"):SetBlock({|| nSaldo})

    If nI == (Len(aReceitas) - 2) //Antepenultima linha, imprime sublinhado
        oReceitas:Cell("NOTAEXP"):Hide()
        oReport:ThinLine()
    ElseIf nI == (Len(aReceitas) - 1) //Penultima linha, inibe informacoes zeradas de deficit
        oReceitas:Cell("PREV_INI"):Hide()
        oReceitas:Cell("PREV_ATU"):Hide()
        oReceitas:Cell("SALDO"):Hide()
        
        If aReceitas[nI][REC_REATM] <= 0 //Se nao tem valor de defit, inibe o campo
            oReceitas:Cell("REC_REATEM"):Hide()
        EndIf
        
        oReport:ThinLine()
    ElseIf nI == Len(aReceitas) //Ultima linha
        oReport:ThinLine()
        oReceitas:Cell("REC_REATEM"):Show()
    EndIf

    //Imprime
    oReceitas:Printline()              
Next nI

If Len(aReceitas) > 0
    //Impressao de Saldos Anteriores
    If nTotRecAnt > 0 .Or. nTotDesAnt > 0
        If nTotRecAnt > nTotDesAnt //Superavit Financeiro nos Saldos Anteriores
            cDescAux  := STR0046 //"Saldos de Exercícios Anteriores - Superávit Financeiro"
            nSaldoAnt := nTotRecAnt - nTotDesAnt
        ElseIf nTotDesAnt > nTotRecAnt //Deficit Financeiro nos Saldos Anteriores
            cDescAux  := STR0047 //"Saldos de Exercícios Anteriores - Déficit Financeiro"
            nSaldoAnt := nTotDesAnt - nTotRecAnt
        EndIf

        aAdd(aReceitas, { "",;        //1-Conta 
                          cDescAux,;  //2-Descricao                         
                          0,;         //3-Previsao Inicial
                          0,;         //4-Suplementacao                       
                          nSaldoAnt,; //5-Previsao Atualizada
                          0,;         //6-Receitas Realizadas no mes            
                          0,;         //7-Receitas Realizadas ate o mes
                          0,;         //8-Percentual Realizado
                          "" })       //9-Analitico/Sintetico 
        
        oReport:ThinLine()
        
        oReceitas:Cell("REC_REATEM"):Hide()
        oReceitas:Cell("PREV_ATU"):Show()

        oReceitas:Cell("DESCRICAO"):SetBlock({|| OemToAnsi(aReceitas[Len(aReceitas)][DES_CONTA])})
        oReceitas:Cell("PREV_ATU"):SetBlock({|| aReceitas[Len(aReceitas)][PRE_ATU]})
    
        //Imprime
        oReceitas:Printline()  
    EndIf

    oReceitas:Finish() 

    //Finaliza Folha de Impressao
    oReport:EndPage()
EndIf

// *** Imprime Despesas ***  

If Len(aDespesas) > 0        
    //Armazena Superavit e Total das despesas
    For nI := 1 To 3
        If nI == 1
            cDescAux := STR0045 //"SUBTOTAL"
        ElseIf nI == 2
            cDescAux := STR0043 //"SUPERAVIT"
        Else
            cDescAux := STR0018 //"TOTAL"
        EndIf

        aAdd(aDespesas, { "",;     //1-Conta
                        cDescAux,; //2-Descricao #SUBTOTAL ##SUPERAVIT ###TOTAL                  
                        0,;        //3-Dotacao Inicial
                        0,;        //4-Creditos Adicionais
                        0,;        //5-Suplementacao/Anulacao                      
                        0,;        //6-Dotacao Atualizada                
                        0,;        //7-Despesas Empenhadas                
                        0,;        //8-Despesas Liquidadas
                        0,;        //9-Despesas Pagas no mes
                        0,;        //10-Despesas Pagas ate o mes
                        0,;        //11-Percentual Realizado
                        "" })      //12-Analitico/Sintetico
    Next nI

    oCabDesp:Init()
    oCabDesp:Printline()   
    oCabDesp:Finish() 

    oDespesas:Init()    
EndIf

For nI := 1 To Len(aDespesas)        
    If oReport:Cancel()
        Exit
    EndIf
        
    oReport:IncMeter() //Regua
    
    nDotIni := IIF(aDespesas[nI][DOT_ATU] > 0, aDespesas[nI][DOT_ATU], aDespesas[nI][DOT_INI]) //Dotacao inicial        
    
    //Tratamento quando nao é Antepenultimo registro
    If nI < (Len(aDespesas) - 2)
        aDespesas[nI][DES_PERCRE] := aDespesas[nI][DES_PGATM] / nDotIni * 100 //Percentual Realizado

        //Creditos Adicionais de forma automatica
        If nCredAdi == 2
            If aDespesas[nI][DOT_ATU] > 0 //Dotacao Atualizada maior que Dotacao Inicial
                aDespesas[nI][DESP_CRED] := aDespesas[nI][DOT_ATU] - aDespesas[nI][DOT_INI]
            EndIf
        EndIf   

        If aDespesas[nI][DES_ANALIT] == "1" //Soma SubTotal despesas analiticas
            aDespesas[Len(aDespesas)-2][DOT_INI] += aDespesas[nI][DOT_INI] //SubTotal Dotacao inicial
            aDespesas[Len(aDespesas)][DOT_INI]   += aDespesas[nI][DOT_INI] //Total Dotacao inicial   
            
            If aDespesas[nI][DOT_ATU] > 0                
                aDespesas[Len(aDespesas)-2][DESP_SUPL] += aDespesas[nI][DOT_ATU] - aDespesas[nI][DOT_INI] //SubTotal Suplementacao
                aDespesas[Len(aDespesas)][DESP_SUPL]   += aDespesas[nI][DOT_ATU] - aDespesas[nI][DOT_INI] //Total Suplementacao
            EndIf

            aDespesas[Len(aDespesas)-2][DESP_CRED] += aDespesas[nI][DESP_CRED]                            //SubTotal Creditos Adicionais
            aDespesas[Len(aDespesas)][DESP_CRED]   += aDespesas[nI][DESP_CRED]                            //Total Creditos Adicionais
            aDespesas[Len(aDespesas)-2][DOT_ATU]   += aDespesas[nI][DOT_ATU]                              //SubTotal Dotacao atualizada
            aDespesas[Len(aDespesas)][DOT_ATU]     += aDespesas[nI][DOT_ATU]                              //Total Dotacao atualizada              
            aDespesas[Len(aDespesas)-2][DES_EMP]   += aDespesas[nI][DES_EMP]                              //SubTotal Despesas empenhadas
            aDespesas[Len(aDespesas)][DES_EMP]     += aDespesas[nI][DES_EMP]                              //Total Despesas empenhadas
            aDespesas[Len(aDespesas)-2][DES_LIQ]   += aDespesas[nI][DES_LIQ]                              //SubTotal Despesas liquidadas
            aDespesas[Len(aDespesas)][DES_LIQ]     += aDespesas[nI][DES_LIQ]                              //Total Despesas liquidadas                
            aDespesas[Len(aDespesas)-2][DES_PGNOM] += aDespesas[nI][DES_PGNOM]                            //SubTotal Despesas pagas no mes
            aDespesas[Len(aDespesas)][DES_PGNOM]   += aDespesas[nI][DES_PGNOM]                            //Total Despesas pagas no mes
            aDespesas[Len(aDespesas)-2][DES_PGATM] += aDespesas[nI][DES_PGATM]                            //SubTotal Despesas pagas ate o mes
            aDespesas[Len(aDespesas)][DES_PGATM]   += aDespesas[nI][DES_PGATM]                            //Total Despesas pagas ate o mes
        EndIf                                 
    ElseIf nI == (Len(aDespesas) - 2) //Antepenultimo registro, armazena SubTotal
        nDotIniTot := IIF(aDespesas[nI][DOT_ATU] > 0, aDespesas[nI][DOT_ATU], aDespesas[nI][DOT_INI]) //Dotacao inicial Total
        aDespesas[nI][DES_PERCRE] := aDespesas[nI][DES_PGATM] / nDotIniTot * 100  //Total Percentual Despesas realizadas 
    ElseIf nI == (Len(aDespesas) - 1) //Penultimo registro, armazena Superavit        
        aDespesas[nI][DES_LIQ] := nTotRec - nTotDesp
    ElseIf nI == Len(aDespesas) //Ultimo registro, armazena Total Despesas
        nSuperAv := nTotRec - nTotDesp
        aDespesas[nI][DES_LIQ] := aDespesas[nI][DES_LIQ] + IIF(nSuperAv > 0, nSuperAv, 0)   
    EndIf

    oDespesas:Cell("CONTA"):SetBlock({|| aDespesas[nI][COD_CONTA]})
    oDespesas:Cell("DESCRICAO"):SetBlock({|| OemToAnsi(aDespesas[nI][DES_CONTA])})
    
    //Nota Explicativa
    If !Empty(aDespesas[nI][COD_CONTA])
        cNotaExp := Pco70NExp(aDespesas[nI][COD_CONTA], aNotaExp)      
    Else
        cNotaExp := "" 
    EndIf
    
    oDespesas:Cell("NOTAEXP"):SetBlock({|| OemToAnsi(cNotaExp)})
    oDespesas:Cell("DOT_INI"):SetBlock({|| aDespesas[nI][DOT_INI]})
    oDespesas:Cell("CRED_ADI"):SetBlock({|| aDespesas[nI][DESP_CRED]})
    oDespesas:Cell("DOT_ATU"):SetBlock({|| aDespesas[nI][DOT_ATU]})
    oDespesas:Cell("DESP_EMP"):SetBlock({|| aDespesas[nI][DES_EMP]})
    oDespesas:Cell("DESP_LIQUI"):SetBlock({|| aDespesas[nI][DES_LIQ]})
    oDespesas:Cell("DESP_PGATM"):SetBlock({|| aDespesas[nI][DES_PGATM]}) 

    If nI == (Len(aDespesas) - 2) //Antepenultima linha, imprime sublinhado
        oDespesas:Cell("NOTAEXP"):Hide()
        oReport:ThinLine()
    ElseIf nI == (Len(aDespesas) - 1) //Penultima linha, inibe informacoes zeradas de superavit
        oDespesas:Cell("DOT_INI"):Hide()
        oDespesas:Cell("CRED_ADI"):Hide()
        oDespesas:Cell("DOT_ATU"):Hide()
        oDespesas:Cell("DESP_EMP"):Hide()
        oDespesas:Cell("DESP_PGATM"):Hide()
        
        If aDespesas[nI][DES_LIQ] <= 0 //Se nao tem valor de superavit, inibe o campo
            oDespesas:Cell("DESP_LIQUI"):Hide()
        EndIf
        
        oReport:ThinLine()
    ElseIf nI == Len(aDespesas) //Ultima linha
        oReport:ThinLine()

        oDespesas:Cell("DOT_INI"):Show()
        oDespesas:Cell("CRED_ADI"):Show()
        oDespesas:Cell("DOT_ATU"):Show()
        oDespesas:Cell("DESP_EMP"):Show()
        oDespesas:Cell("DESP_PGATM"):Show()
        oDespesas:Cell("DESP_LIQUI"):Show()
    EndIf

    //Imprime   
    oDespesas:Printline()              
Next nI

If Len(aDespesas) > 0
    oDespesas:Finish() 
EndIf

//Impressao de Notas Explicativas
If Len(aNotaExp) > 0
    oReport:EndPage() //Finaliza Folha de Impressao
    
    oQuadro1:Init()
    oQuadro1:Cell("TITREL1"):SetBlock({|| STR0002}) //Balanco Orcamentario
    oQuadro1:Cell("TITREL2"):SetBlock({|| STR0054 + DToC(SToD(cDtAKTAte))}) //"Em: "
    oQuadro1:PrintLine()
	oQuadro1:Finish()
	
    oReport:ThinLine()
	oReport:PrintText(STR0055) //"** NOTAS EXPLICATIVAS **"
	oReport:ThinLine()

    oNotExplic:Init()

	For nI := 1 To Len(aNotaExp)
		A20->(dbGoto(aNotaExp[nI]))

        oNotExplic:Cell("CODNOT"):SetBlock({|| A20->A20_CODIGO})
        oNotExplic:Cell("DATNOT"):SetBlock({|| DToC(A20->A20_DATA)})
        oNotExplic:Cell("OBSNOT"):SetBlock({|| A20->A20_DESC})
		oNotExplic:PrintLine()
	Next nI

	oNotExplic:Finish()
EndIf

//Limpa arrays
aSize(aReceitas, 0)
aSize(aDespesas, 0)
aSize(aRecAnt  , 0)
aSize(aDespAnt , 0)
aSize(aNotaExp , 0)

aReceitas := Nil
aDespesas := Nil
aRecAnt   := Nil
aDespAnt  := Nil
aNotaExp  := Nil

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} Pco70Mod2
Imprime o relaótio Balanco Orcamentario - Leiaute 2

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco70Mod2(oReport, nDivide)

Local oCabRec    := oReport:Section(1)
Local oReceitas	 := oReport:Section(2)
Local oCabDesp   := oReport:Section(3)
Local oDespesas	 := oReport:Section(4)
Local cDtAKTDe   := MV_PAR01 + "01" + "01" //Exercicio De
Local cDtAKTAte  := MV_PAR01 + StrZero(Month(dDataBase), 2) + StrZero(Day(dDataBase), 2) //Exercicio Ate
Local nI         := 0
Local nSaldo     := 0
Local nPreIni    := 0
Local nDotIni    := 0
Local nPreIniTot := 0 //Previsao Inicial Total
Local nDotIniTot := 0 //Dotacao Inicial Total
Local nTotRec    := 0
Local nTotDesp   := 0
Local aReceitas  := {}
Local aDespesas  := {}

//Busca de saldos
Pco70GerMov(cDtAKTDe, cDtAKTAte, aReceitas, aDespesas, @nTotRec, @nTotDesp, nDivide)

If Len(aReceitas) > 0
    //Armazena Deficit e Total das receitas como ultimos registros
    For nI := 1 To 2
        aAdd(aReceitas, { "",;                           //1-Conta 
                        IIF(nI == 1, STR0042, STR0018),; //2-Descricao #DEFICIT ##TOTAL                         
                        0,;                              //3-Previsao Inicial
                        0,;                              //4-Suplementacao                       
                        0,;                              //5-Previsao Atualizada
                        0,;                              //6-Receitas Realizadas no mes            
                        0,;                              //7-Receitas Realizadas ate o mes
                        0,;                              //8-Percentual Realizado
                        "" })                            //9-Analitico/Sintetico  
    Next nI
    
    //Imprime Cabecalho
    oCabRec:Init()
    oCabRec:Printline()   
    oCabRec:Finish() 

    oReceitas:Init()    
EndIf

For nI := 1 To Len(aReceitas)        
    If oReport:Cancel()
        Exit
    EndIf
        
    oReport:IncMeter() //Regua

    nPreIni := IIF(aReceitas[nI][PRE_ATU] > 0, aReceitas[nI][PRE_ATU], aReceitas[nI][PRE_INI]) //Previsao inicial        
    nSaldo  := nPreIni - aReceitas[nI][REC_REATM] //Calculo do Saldo

    //Tratamento quando nao é ultimo registro
    If nI <> Len(aReceitas) 
        aReceitas[nI][REC_PERCRE] := aReceitas[nI][REC_REATM] / nPreIni * 100 //Percentual Realizado 

        If aReceitas[nI][REC_ANALIT] == "1" //Soma Total receitas analiticas
            aReceitas[Len(aReceitas)][PRE_INI] += aReceitas[nI][PRE_INI] //Total Previsao inicial
            
            If aReceitas[nI][PRE_ATU] > 0                
                aReceitas[Len(aReceitas)][REC_SUPL] += aReceitas[nI][PRE_ATU] - aReceitas[nI][PRE_INI] //Suplementacao
            EndIf

            aReceitas[Len(aReceitas)][PRE_ATU]    += aReceitas[nI][PRE_ATU]     //Total Previsao atualizada
            aReceitas[Len(aReceitas)][REC_REANOM] += aReceitas[nI][REC_REANOM]  //Total Receitas realizadas no mes
            aReceitas[Len(aReceitas)][REC_REATM]  += aReceitas[nI][REC_REATM]   //Total Receitas realizadas                    
        EndIf

        If nI == (Len(aReceitas) - 1) //Se for penultimo registro, armazena deficit
            aReceitas[nI][REC_REATM] := nTotDesp - nTotRec
        EndIf                    
    Else //Ultimo registro armazena Total Receitas
        nPreIniTot := IIF(aReceitas[nI][PRE_ATU] > 0, aReceitas[nI][PRE_ATU], aReceitas[nI][PRE_INI]) //Previsao inicial Total
        aReceitas[nI][REC_PERCRE] := aReceitas[nI][REC_REATM] / nPreIniTot * 100  //Total Percentual Receitas realizadas  
    EndIf

    oReceitas:Cell("CONTA"):SetBlock({|| aReceitas[nI][COD_CONTA]})
    oReceitas:Cell("DESCRICAO"):SetBlock({|| OemToAnsi(aReceitas[nI][DES_CONTA])})
    oReceitas:Cell("PREV_INI"):SetBlock({|| aReceitas[nI][PRE_INI]})
    oReceitas:Cell("PREV_ATU"):SetBlock({|| aReceitas[nI][PRE_ATU]})
    oReceitas:Cell("REC_REATEM"):SetBlock({|| aReceitas[nI][REC_REATM]})
    oReceitas:Cell("SALDO"):SetBlock({|| nSaldo})

    //Suplementacao
    If aReceitas[nI][PRE_ATU] > 0
        oReceitas:Cell("REC_SUPL"):SetBlock({|| aReceitas[nI][PRE_ATU] - aReceitas[nI][PRE_INI]})
    Else
        oReceitas:Cell("REC_SUPL"):SetBlock({|| 0})
    EndIf

    oReceitas:Cell("REC_REANOM"):SetBlock({|| aReceitas[nI][REC_REANOM]}) //Receitas Pagas no mes
    oReceitas:Cell("REC_PERCRE"):SetBlock({|| aReceitas[nI][REC_PERCRE]}) //Percentual Receitas realizadas

    If nI == (Len(aReceitas) - 1) //Penultima linha, inibe informacoes zeradas de deficit
        oReceitas:Cell("PREV_INI"):Hide()
        oReceitas:Cell("PREV_ATU"):Hide()
        oReceitas:Cell("SALDO"):Hide()
        
        If aReceitas[nI][REC_REATM] <= 0 //Se nao tem valor de defit, inibe o campo
            oReceitas:Cell("REC_REATEM"):Hide()
        EndIf
        
        oReceitas:Cell("REC_SUPL"):Hide()
        oReceitas:Cell("REC_REANOM"):Hide()
        oReceitas:Cell("REC_PERCRE"):Hide()
    ElseIf nI == Len(aReceitas) //Ultima linha, pula linha para impressao Total e exibe campos
        oReport:SkipLine()

        oReceitas:Cell("PREV_INI"):Show()
        oReceitas:Cell("PREV_ATU"):Show()
        oReceitas:Cell("REC_REATEM"):Show()
        oReceitas:Cell("SALDO"):Show()
        oReceitas:Cell("REC_SUPL"):Show()
        oReceitas:Cell("REC_REANOM"):Show()
        oReceitas:Cell("REC_PERCRE"):Show()
    EndIf

    //Imprime
    oReceitas:Printline()              
Next nI

If Len(aReceitas) > 0
    oReceitas:Finish() 

    //Pula linha
    oReport:EndPage()
EndIf

// *** Imprime Despesas ***  

If Len(aDespesas) > 0        
    //Armazena Superavit e Total das despesas
    For nI := 1 To 2
        aAdd(aDespesas, { "",;                           //1-Conta
                        IIF(nI == 1, STR0043, STR0018),; //2-Descricao #SUPERAVIT ##TOTAL                  
                        0,;                              //3-Dotacao Inicial
                        0,;                              //4-Creditos Adicionais
                        0,;                              //5-Suplementacao/Anulacao                      
                        0,;                              //6-Dotacao Atualizada                
                        0,;                              //7-Despesas Empenhadas                
                        0,;                              //8-Despesas Liquidadas
                        0,;                              //9-Despesas Pagas no mes
                        0,;                              //10-Despesas Pagas ate o mes
                        0,;                              //11-Percentual Realizado
                        "" })                            //12-Analitico/Sintetico
    Next nI

    oCabDesp:Init()
    oCabDesp:Printline()   
    oCabDesp:Finish() 

    oDespesas:Init()    
EndIf

For nI := 1 To Len(aDespesas)        
    If oReport:Cancel()
        Exit
    EndIf
        
    oReport:IncMeter() //Regua

    nDotIni := IIF(aDespesas[nI][DOT_ATU] > 0, aDespesas[nI][DOT_ATU], aDespesas[nI][DOT_INI]) //Dotacao inicial        
    nSaldo  := nDotIni - (aDespesas[nI][DES_LIQ] + aDespesas[nI][DES_PGATM]) //Saldo
    
    //Tratamento quando nao é ultimo registro
    If nI <> Len(aDespesas)
        aDespesas[nI][DES_PERCRE] := aDespesas[nI][DES_PGATM] / nDotIni * 100 //Percentual Realizado   

        If aDespesas[nI][DES_ANALIT] == "1" //Soma Total despesas analiticas
            aDespesas[Len(aDespesas)][DOT_INI] += aDespesas[nI][DOT_INI] //Total Dotacao inicial  
            
            If aDespesas[nI][DOT_ATU] > 0                
                aDespesas[Len(aDespesas)][DESP_SUPL] += aDespesas[nI][DOT_ATU] - aDespesas[nI][DOT_INI] //Suplementacao
            EndIf

            aDespesas[Len(aDespesas)][DOT_ATU]    += aDespesas[nI][DOT_ATU]     //Total Dotacao atualizada              
            aDespesas[Len(aDespesas)][DES_EMP]    += aDespesas[nI][DES_EMP]     //Total Despesas empenhadas
            aDespesas[Len(aDespesas)][DES_LIQ]    += aDespesas[nI][DES_LIQ]     //Total Despesas liquidadas                
            aDespesas[Len(aDespesas)][DES_PGNOM]  += aDespesas[nI][DES_PGNOM]   //Total Despesas pagas no mes
            aDespesas[Len(aDespesas)][DES_PGATM]  += aDespesas[nI][DES_PGATM]   //Total Despesas pagas ate o mes
        EndIf

        If nI == (Len(aDespesas) - 1) //Penultimo registro trata superavit
            aDespesas[nI][DES_LIQ] := nTotRec - nTotDesp  
        EndIf                                  
    Else //Ultimo registro armazena Total Despesas
        nDotIniTot := IIF(aDespesas[nI][DOT_ATU] > 0, aDespesas[nI][DOT_ATU], aDespesas[nI][DOT_INI]) //Dotacao inicial Total
        aDespesas[nI][DES_PERCRE] := aDespesas[nI][DES_PGATM] / nDotIniTot * 100  //Total Percentual Despesas realizadas  
    EndIf

    oDespesas:Cell("CONTA"):SetBlock({|| aDespesas[nI][COD_CONTA]})
    oDespesas:Cell("DESCRICAO"):SetBlock({|| OemToAnsi(aDespesas[nI][DES_CONTA])})
    oDespesas:Cell("DOT_INI"):SetBlock({|| aDespesas[nI][DOT_INI]})
    oDespesas:Cell("DOT_ATU"):SetBlock({|| aDespesas[nI][DOT_ATU]})
    oDespesas:Cell("DESP_EMP"):SetBlock({|| aDespesas[nI][DES_EMP]})
    oDespesas:Cell("DESP_LIQUI"):SetBlock({|| aDespesas[nI][DES_LIQ]})
    oDespesas:Cell("DESP_PGATM"):SetBlock({|| aDespesas[nI][DES_PGATM]}) 
    oDespesas:Cell("SALDO"):SetBlock({|| nSaldo})

    //Suplementacao
    If aDespesas[nI][DOT_ATU] > 0
        oDespesas:Cell("DESP_SUPL"):SetBlock({|| aDespesas[nI][DOT_ATU] - aDespesas[nI][DOT_INI]})
    Else
        oDespesas:Cell("DESP_SUPL"):SetBlock({|| 0})
    EndIf

    oDespesas:Cell("DESP_PGNOM"):SetBlock({|| aDespesas[nI][DES_PGNOM]}) //Despesas Pagas no mes
    oDespesas:Cell("DESP_PERCRE"):SetBlock({|| aDespesas[nI][DES_PERCRE]}) //Percentual Despesas realizadas
    
    If nI == (Len(aDespesas) - 1) //Penultima linha, inibe informacoes zeradas de superavit
        oDespesas:Cell("DOT_INI"):Hide()
        oDespesas:Cell("DOT_ATU"):Hide()
        oDespesas:Cell("DESP_EMP"):Hide()
        oDespesas:Cell("DESP_PGATM"):Hide()
        oDespesas:Cell("SALDO"):Hide()
        
        If aDespesas[nI][DES_LIQ] <= 0 //Se nao tem valor de superavit, inibe o campo
            oDespesas:Cell("DESP_LIQUI"):Hide()
        EndIf
        
        oDespesas:Cell("DESP_SUPL"):Hide()
        oDespesas:Cell("DESP_PGNOM"):Hide()
        oDespesas:Cell("DESP_PERCRE"):Hide()
    ElseIf nI == Len(aDespesas) //Ultima linha, pula linha para impressao Total e exibe campos
        oReport:SkipLine()

        oDespesas:Cell("DOT_INI"):Show()
        oDespesas:Cell("DOT_ATU"):Show()
        oDespesas:Cell("DESP_EMP"):Show()
        oDespesas:Cell("DESP_LIQUI"):Show()
        oDespesas:Cell("DESP_PGATM"):Show()
        oDespesas:Cell("SALDO"):Show()
        oDespesas:Cell("DESP_SUPL"):Show()
        oDespesas:Cell("DESP_PGNOM"):Show()
        oDespesas:Cell("DESP_PERCRE"):Show()
    EndIf

    //Imprime   
    oDespesas:Printline()              
Next nI

If Len(aDespesas) > 0
    oDespesas:Finish() 
EndIf

//Limpa arrays
aSize(aReceitas, 0)
aSize(aDespesas, 0)

aReceitas := Nil
aDespesas := Nil

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} Pco70GerMov
Executa query para busca de movimentacoes na AKT para Balanco Orcamentario

@author Totvs
   
@version P12
@since   27/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco70GerMov(cDtAKTDe, cDtAKTAte, aReceitas, aDespesas, nTotRec, nTotDesp, nDivide)

Local cTpSaldo    := "%"
Local cTpSldDesp  := ""
Local cTpSldRec   := ""
Local cTotDesp    := ""
Local cMoeda      := CValToChar(Val(MV_PAR16))
Local cMVCRD      := "%"+"AKT_MVCRD"+cMoeda+"%" //Valores credito
Local cMVDEB      := "%"+"AKT_MVDEB"+cMoeda+"%" //Valores debito
Local cCodCube    := MV_PAR15 //Codigo Cubo
Local cMesAtu     := StrZero(Month(dDataBase), 2)
Local cArqTmp	  := GetNextAlias()
Local nSaldoAKT   := 0
Local nLeiaute    := MV_PAR18
Local nCredAdi    := MV_PAR20 //Tipo de Calculo para Creditos Adicionais
Local aSaldos     := {}
Local lContinua   := .T.

//Armazena Tipos de Saldo
lContinua := Pco70TpSld(aSaldos, @cTpSaldo, @cTpSldDesp, @cTpSldRec, cCodCube)

If lContinua
    //Composicao de campos com parametrizacao
    cTpSaldo += "%"

    //Consulta da movimentacoes
    BeginSQL Alias cArqTmp
        SELECT AKT_FILIAL, AKT_NIV01 CONTA, SUM(AKT_SLD001) SALDO, AKT_TPSALD TIPO_SALDO, AKT_ANALIT, AKT_DATA, AK5_DESCRI DESCRICAO    
            FROM (SELECT AKT_FILIAL, AKT_NIV01 AKT_NIV01, SUM(%Exp:cMVCRD%-%Exp:cMVDEB%) AKT_SLD001, AKT_TPSALD, AKT_ANALIT, AKT_DATA  
                FROM %Table:AKT% AKT 
                    WHERE  AKT.AKT_FILIAL = %Exp:xFilial('AKT')% AND
                    AKT.AKT_CONFIG = %Exp:cCodCube%  AND 
                    AKT.AKT_TPSALD IN (%Exp:cTpSaldo%) AND 
                    AKT.AKT_NIV01 IN (SELECT AK5_CODIGO N_I_V_01 FROM %Table:AK5% AK5 WHERE AK5_FILIAL = %Exp:xFilial('AK5')% AND
                                        (AK5_CODIGO >= %Exp:MV_PAR02% AND AK5_CODIGO <= %Exp:MV_PAR03% OR
                                         AK5_CODIGO >= %Exp:MV_PAR04% AND AK5_CODIGO <= %Exp:MV_PAR05%) AND %NotDel%) AND 
                    AKT.AKT_DATA >= %Exp:cDtAKTDe% AND
                    AKT.AKT_DATA <= %Exp:cDtAKTAte% AND                
                    %NotDel%
            GROUP BY AKT_FILIAL, AKT_NIV01, AKT_TPSALD, AKT_ANALIT, AKT_DATA) TMPSALDO  
        INNER JOIN %Table:AK5% AK5 ON AK5_FILIAL = %Exp:xFilial('AK5')% AND AK5_CODIGO = AKT_NIV01 
        WHERE AK5.%NotDel%
        GROUP BY AKT_FILIAL, AKT_NIV01, AKT_TPSALD, AKT_ANALIT, AKT_DATA, AK5_DESCRI
        ORDER BY AKT_NIV01, AKT_TPSALD, AKT_DATA    
    EndSQL

    //Tipos de Saldo para Total Despesas
    nPosSld := aScan(aSaldos, {|x| AllTrim(x[1]) == Alltrim(MV_PAR11)})

    If nPosSld > 0
        cTotDesp := aSaldos[nPosSld][2]    
    EndIf

    //Verifica contas orcamentarias
    While (cArqTmp)->(!Eof()) 
        nSaldoAKT := (cArqTmp)->SALDO / nDivide //Tratamento divide para os saldos da AKT
        nPosSld   := aScan(aSaldos, {|x| AllTrim((cArqTmp)->TIPO_SALDO) $ x[2]})

        If (cArqTmp)->TIPO_SALDO $ (cTpSldRec) .And.; 
            (cArqTmp)->CONTA >= MV_PAR04 .And. (cArqTmp)->CONTA <= MV_PAR05 //Receitas
            
            If aScan(aReceitas, {|x| AllTrim(x[COD_CONTA]) == AllTrim((cArqTmp)->CONTA)}) == 0                       
                //Inicializa conta
                aAdd(aReceitas, { AllTrim((cArqTmp)->CONTA),;     //1-Conta 
                                  AllTrim((cArqTmp)->DESCRICAO),; //2-Descricao                       
                                  0 ,;                            //3-Previsao Inicial
                                  0 ,;                            //4-Suplementacao   
                                  0 ,;                            //5-Previsao Atualizada
                                  0 ,;                            //6-Receitas Realizadas no mes  
                                  0 ,;                            //7-Receitas Realizadas ate o mes
                                  0 ,;                            //8-Percentual Realizado
                                  (cArqTmp)->AKT_ANALIT })        //9-Analitico\Sintetico       
            EndIf
            If Len(aReceitas) > 0 .And. nPosSld > 0 .And. nSaldoAKT > 0
                //Armazena valores nas contas
                Do Case
                    Case AllTrim(aSaldos[nPosSld][1]) == MV_PAR12 //Previsao inicial
                        aReceitas[Len(aReceitas)][PRE_INI] += nSaldoAKT                
                    Case AllTrim(aSaldos[nPosSld][1]) == MV_PAR13 //Previsao atualizada
                        aReceitas[Len(aReceitas)][PRE_ATU] += nSaldoAKT               
                    Case AllTrim(aSaldos[nPosSld][1]) == MV_PAR14 //Receitas realizadas
                        If SubStr((cArqTmp)->AKT_DATA, 5, 2) == cMesAtu //Receitas realizadas no mes
                            aReceitas[Len(aReceitas)][REC_REANOM] += nSaldoAKT
                        EndIf 
                        
                        aReceitas[Len(aReceitas)][REC_REATM] += nSaldoAKT //Receitas realizadas até o mes
                        
                        If (cArqTmp)->AKT_ANALIT == "1"
                            nTotRec += nSaldoAKT //Alimenta Totalizador Receitas Realizadas
                        EndIf                                                            
                EndCase  
            EndIf                          
        ElseIf (cArqTmp)->TIPO_SALDO $ (cTpSldDesp) .And.; 
                (cArqTmp)->CONTA >= MV_PAR02 .And. (cArqTmp)->CONTA <= MV_PAR03 //Despesas

            If aScan(aDespesas, {|x| AllTrim(x[COD_CONTA]) == AllTrim((cArqTmp)->CONTA)}) == 0                        
                //Inicializa nova conta
                aAdd(aDespesas, { (cArqTmp)->CONTA,;            //1-Conta
                                AllTrim((cArqTmp)->DESCRICAO),; //2-Descricao                          
                                0 ,;                            //3-Dotacao Inicial
                                0 ,;                            //4-Creditos Adicionais
                                0 ,;                            //5-Suplementacao/Anulacao 
                                0 ,;                            //6-Dotacao Atualizada
                                0 ,;                            //7-Despesas Empenhadas
                                0 ,;                            //8-Despesas Liquidadas                            
                                0 ,;                            //9-Despesas Pagas no mes
                                0 ,;                            //10-Despesas Pagas ate o mes
                                0 ,;                            //11-Percentual Realizado
                                (cArqTmp)->AKT_ANALIT })        //12-Analitico/Sintetico
            EndIf
            If Len(aDespesas) > 0 .And. nPosSld > 0 .And. nSaldoAKT > 0                           
                //Armazena valores nas contas    
                Do Case
                    Case AllTrim(aSaldos[nPosSld][1]) == AllTrim(MV_PAR06) //Dotacao inicial
                        aDespesas[Len(aDespesas)][DOT_INI] += nSaldoAKT                 
                    Case AllTrim(aSaldos[nPosSld][1]) == AllTrim(MV_PAR07) //Dotacao atualizada
                        aDespesas[Len(aDespesas)][DOT_ATU] += nSaldoAKT                                  
                    Case AllTrim(aSaldos[nPosSld][1]) == AllTrim(MV_PAR08) //Despesas empenhadas
                        aDespesas[Len(aDespesas)][DES_EMP] += nSaldoAKT                                
                    Case AllTrim(aSaldos[nPosSld][1]) == AllTrim(MV_PAR09) //Despesas liquidadas
                        aDespesas[Len(aDespesas)][DES_LIQ] += nSaldoAKT
                        
                        If (cArqTmp)->AKT_ANALIT == "1"
                            nTotDesp += nSaldoAKT //Alimenta Totalizador Despesas liquidadas 
                        EndIf                               
                    Case AllTrim(aSaldos[nPosSld][1]) == AllTrim(MV_PAR10) //Despesas pagas
                        If SubStr((cArqTmp)->AKT_DATA, 5, 2) == cMesAtu //Despesas realizadas no mes
                            aDespesas[Len(aDespesas)][DES_PGNOM] += nSaldoAKT
                        EndIf 
                        
                        aDespesas[Len(aDespesas)][DES_PGATM] += nSaldoAKT //Despesas realizadas ate o mes
                    Case nLeiaute == 1 .And. nCredAdi == 1 .And. AllTrim(aSaldos[nPosSld][1]) == AllTrim(MV_PAR19) //Creditos Adicionais de Forma Manual                       
                        aDespesas[Len(aDespesas)][DESP_CRED] += nSaldoAKT                                                                                   
                EndCase 
            EndIf             
        EndIf

        (cArqTmp)->(dbSkip())
    EndDo
EndIf

//Fecha arquivo temporario
If Select("cArqTmp") > 0
    (cArqTmp)->(dbCloseArea()) 
EndIf

//Limpa arrays
aSize(aSaldos, 0)
aSaldos := Nil

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} Pco70TpSld
Busca Tipos de Saldos para cada Configuracao do Cubo Gerencial

@author Totvs
   
@version P12
@since   03/03/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco70TpSld(aSaldos, cTpSaldo, cTpSldDesp, cTpSldRec, cCodCube)

Local cCondSld   := ""
Local cFiltro    := ""
Local nI         := 0
Local nLeiaute   := MV_PAR18
Local cConfigDes := ""
Local cConfigRec := ""
Local aConfigTot := {}
Local nCredAdi   := MV_PAR20 //Tipo de Calculo para Creditos Adicionais
Local lRet       := .T.

//Alimenta array com as configuracoes das perguntas
cConfigDes := MV_PAR06 + "|" + MV_PAR07 + "|" + MV_PAR08 + "|" + MV_PAR09 + "|" + MV_PAR10 + IIF(nLeiaute == 1 .And. nCredAdi == 1, "|" + MV_PAR19, "")
cConfigRec := MV_PAR12 + "|" + MV_PAR13 + "|" + MV_PAR14

//Armazena Configuracoes utilizadas
aAdd(aConfigTot, MV_PAR06)
aAdd(aConfigTot, MV_PAR07)
aAdd(aConfigTot, MV_PAR08)
aAdd(aConfigTot, MV_PAR09)
aAdd(aConfigTot, MV_PAR10)
aAdd(aConfigTot, MV_PAR12)
aAdd(aConfigTot, MV_PAR13)
aAdd(aConfigTot, MV_PAR14)

If nLeiaute == 1 .And. nCredAdi == 1 //Creditos Adicionais de Forma Manual
    aAdd(aConfigTot, MV_PAR19)
EndIf

//Busca Tipos de Saldos relacionados as configuraçoes passadas nas perguntas
AL4->(dbSetOrder(1)) //AL4_FILIAL+AL4_CODIGO+AL4_CONFIG+AL4_NIVEL

For nI := 1 To Len(aConfigTot)
    aAdd(aSaldos, {aConfigTot[nI], ""}) //Adiciona tipo de Saldo no array de Saldos

    If AL4->(dbSeek(xFilial("AL4") + PadR(aConfigTot[nI], TamSx3("AL4_CODIGO")[1])))                        
        If AllTrim(AL4->AL4_CONFIG) == AllTrim(MV_PAR15) //Valida cubo gerencial        
            //Range Saldos
            cCondSld := "AL2_TPSALD >= '" + AllTrim(AL4->AL4_EXPRIN) + "'"
            cCondSld += " AND AL2_TPSALD <= '" + Alltrim(AL4->AL4_EXPRFI) + "'"                                                                       

            //Aplica filtros
            cFiltro := ""

            If !Empty(AL4->AL4_FILTER)
                cFiltro := PcoParseFil(AL4->AL4_FILTER, "AL2")                                       
            EndIf

            //Busca saldos
            Pco70FindSl(aSaldos, cCondSld, cFiltro, @cTpSaldo)
                            
            If aConfigTot[nI] $ cConfigDes //Armazena saldos despesas            
                cTpSldDesp += aSaldos[Len(aSaldos)][2] + "|"    
            ElseIf aConfigTot[nI] $ cConfigRec //Armazena saldos receitas            
                cTpSldRec += aSaldos[Len(aSaldos)][2] + "|"
            EndIf
        Else
            lRet := .F.
            Help(,, "Help",, OemToAnsi(STR0022) + AllTrim(aConfigTot[nI]) + OemToAnsi(STR0023), 1, 0) //#"Configuracao: " ##" nao pertence ao cubo gerencial selecionado."
            Exit
        EndIf                     
    Else
        lRet := .F.
        Help(,, "Help",, OemToAnsi(STR0022) + AllTrim(aConfigTot[nI]) + OemToAnsi(STR0040), 1, 0) //#"Configuracao: " ##" nao pertence ao cubo gerencial selecionado."
        Exit
    EndIf
Next nI

//Valida se encontrou Tipos de Saldos para consulta
If lRet .And. Len(cTpSaldo) <= 1
    lRet := .F.
    Help(,, "Help",, OemToAnsi(STR0041), 1, 0) //"Nao foram encontrados tipos de saldos para esta consulta, verificar as perguntas do relatorio e o cadastro de configuracoes de cubos gerenciais."
EndIf

//Remove separador do final da string
If lRet
    cTpSldDesp := SubStr(cTpSldDesp, 1, Len(cTpSldDesp)-1) 
    cTpSldRec  := SubStr(cTpSldRec , 1, Len(cTpSldRec)-1) 
    cTpSaldo   := SubStr(cTpSaldo, 1, Len(cTpSaldo)-1)
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Pco70FindSl
Query para localizar Tipos de Saldos

@author Totvs
   
@version P12
@since   03/03/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco70FindSl(aSaldos, cCondSld, cFiltro, cTpSaldo)

Local cQuery    := ""
Local cAliasQry := GetNextAlias()

//Query busca tipo de saldos
cQuery := " SELECT AL2_TPSALD "
cQuery += " FROM " + RetSQLName("AL2")
cQuery += "  WHERE AL2_FILIAL = '" + xFilial("AL2") + "'"
cQuery += "  AND " + cCondSld

//Adiciona expressao de filtro convertida para SQL
If !Empty(cFiltro)
    cQuery += "  AND (" + cFiltro + ")"	
EndIf

cQuery += "  AND D_E_L_E_T_ = ''"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .T., .F.)

(cAliasQry)->(dbGoTop())

//Armazena Tipos de Saldos
While (cAliasQry)->(!EOF())    
    aSaldos[Len(aSaldos)][2] += (cAliasQry)-> AL2_TPSALD + "|" 
    
    If !(cAliasQry)-> AL2_TPSALD $ cTpSaldo
        cTpSaldo += "'" + (cAliasQry)-> AL2_TPSALD + "',"
    Endif
    
    (cAliasQry)->(dbSkip())
EndDo
 
//Remove separador do final da string
aSaldos[Len(aSaldos)][2] := SubStr(aSaldos[Len(aSaldos)][2], 1, Len(aSaldos[Len(aSaldos)][2])-1)

//Fecha alias
(cAliasQry)->(dbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} CodeNota()
Retorna o codigo da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco70NExp(cCodConta, aNotaExp)

Local cCodeNota := ""
Local cDtAKTDe  := MV_PAR01 + "01" + "01" //Data De
Local cDtAKTAte := MV_PAR01 + "12" + "31" //Data Ate

//Tratamento tamanho da conta
cCodConta := Padr(cCodConta, TamSx3("A20_CONTA")[1])

//Busca pela codigo da conta gerencial por query
//Indice 2 -> A20_FILIAL+A20_CONTA+DTOS(A20_DATA)
A20->(dbSetOrder(2))

//Primeiro busca na data
If A20->(dbSeek(xFilial("A20") + cCodConta + cDtAKTAte))
    cCodeNota := A20->A20_CODIGO

    If !Empty(cCodeNota) .And. aScan(aNotaExp, {|x| x == A20->(Recno())}) == 0
        aAdd(aNotaExp, A20->(Recno()))
    EndIf
ElseIf A20->(dbSeek(xFilial("A20") + cCodConta))
	//Laco para percorrer todas as notas explicativas para conta orcamentaria
	While A20->(!Eof() .And. A20_FILIAL + A20_CONTA == xFilial("A20") + cCodConta)
		If A20->A20_DATA >= SToD(cDtAKTDe) .And. A20->A20_DATA <= SToD(cDtAKTAte)
			cCodeNota := A20->A20_CODIGO
			
            If !Empty(cCodeNota) .And. aScan(aNotaExp, {|x| x == A20->(Recno())}) == 0
                aAdd(aNotaExp, A20->(Recno()))
            EndIf
            
            Exit
		EndIf

		A20->(dbSkip())
	EndDo
EndIf

Return cCodeNota