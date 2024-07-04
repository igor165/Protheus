#Include "PROTHEUS.CH"
#Include "PCOR084.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR084
Relatorio Resumo por unidade Gestora

@author Totvs
   
@version P12
@since   03/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR084()

Local oReport := Nil
Local cPerg   := Padr("PCOR084", Len(SX1->X1_GRUPO))

//=================================================================================================================================================
//mv_par01    Código do PPA ? 
//mv_par02    Ano ? 
//mv_par03    Unidade Gestora De ?
//mv_par04    Unidade Gestora Até ?
//mv_par05    Programa De ?
//mv_par06    Programa Até ? 						                    
//=================================================================================================================================================
SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstrativo da Execucao das Despesas por Funcao/SubFuncao disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilizacao do Relatorio Demonstrativo da Execucao das Despesas por Funcao/SubFuncao é necessário aplicar o pacote acumulado da controladoria."
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   03/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oBorder
Local cNomeProg := "PCOR084"
Local cTitulo   := Capital(STR0003)  //"Resumo por unidade Gestora"
Local cDescri 	:= OemToAnsi(STR0004)  //"Este programa irá imprimir o Relatório Relatorio Resumo por unidade Gestora."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:SetTotalInLine(.F.)
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como retrato
oReport:DisableOrientation() //Desabilita opcao para mudar orientacao de impressao                                  

//Configuracoes de impressao
oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

oGestora := TRSection():New(oReport, "GESTORA", {}, /*aOrdem*/, /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , .T./*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ )
TRCell():New(oGestora, "GESTORA",, STR0005 ,,  100, /*lPixel*/, {|| (ALIAS())->(AKU_UNGEST) +" "+Posicione("ALD",1,xFilial("ALD")+(ALIAS())->(AKU_UNGEST),"ALD_DESCRI") }/*CodeBlock*/,,,,,,,,, .T.)  //"Unidade Gestora"

oPrograma := TRSection():New(oReport, "PROGR", {"cArqTmp"},/*aOrdem*/, .F., .F.)
TRCell():New(oPrograma, "PROGRAMA"  ,, STR0006              /*Titulo*/,                              , TamSx3("AL0_CODIGO")[1] /*Tamanho*/, /*lPixel*/, {|| (ALIAS())->(AKU_PROGR)}  /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 3) //"Cód. Prog."
TRCell():New(oPrograma, "NOME"      ,, STR0007              /*Titulo*/,                              , TamSx3("AL0_DESCRI")[1] /*Tamanho*/, /*lPixel*/, {|| Posicione("AL0",1,xFilial("AL0")+(ALIAS())->(AKU_PROGR),"AL0_DESCRI")} /*CodeBlock*/, "LEFT", .T., "LEFT")     //"Nome Programa"
TRCell():New(oPrograma, "RECPROP"   ,, STR0008              /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| (ALIAS())->PROP} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Recurso Proprio"
TRCell():New(oPrograma, "RECVINC"   ,, STR0009              /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| (ALIAS())->VINCU} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Recurso Vinculado"
TRCell():New(oPrograma, "TOTAL"     ,, STR0010              /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| (ALIAS())->TOTAL} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Total"

oGestora:SetLinesBefore(5)
oPrograma:SetLineBreak()
oPrograma:SetLinesBefore(1)

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   20/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oGestora    := oReport:Section("GESTORA")
Local oPrograma  := oReport:Section("PROGR")
Local cQry       := ""
Local cAlsAK4    := Getnextalias()
Local cUniGest  := ""

cQry := "SELECT AKU_UNGEST, AKU_PROGR, SUM(PROP) PROP, SUM(VINCU) VINCU, SUM(TOTAL) TOTAL FROM ( " +CRLF

//--PROPRIO
cQry += "SELECT AKU_UNGEST, AKU_PROGR, SUM(AKU_TOTPPA) PROP, 0 VINCU, SUM(AKU_TOTPPA) TOTAL  FROM " +RetSqlName("AKU") +" AKU" +CRLF
cQry += "RIGHT JOIN " +RetSqlName("ALE") +" ALE" +CRLF
cQry += "ON ALE_FILIAL = AKU_FILIAL " +CRLF
cQry += "AND ALE_CODACA = AKU_ACAO " +CRLF
cQry += "AND ALE_TPRCRS = 1 " +CRLF
cQry += "AND ALE.D_E_L_E_T_ = '' " +CRLF
cQry += "WHERE AKU_FILIAL   =  '" + FwxFilial("AKU") + "'" +CRLF
cQry += "AND AKU_CODIGO     =  '" + MV_PAR01 + "'" +CRLF
cQry += "AND AKU_VERSAO		=  '" + MV_PAR02 + "' " +CRLF
cQry += "AND AKU_ANO        =   " + CVALTOCHAR(MV_PAR03) +CRLF
cQry += "AND AKU_UNGEST     >= '" + MV_PAR04 + "'" +CRLF
cQry += "AND AKU_UNGEST     <= '" + MV_PAR05 + "'" +CRLF
cQry += "AND AKU_PROGR      >= '" + MV_PAR06 + "'" +CRLF
cQry += "AND AKU_PROGR      <= '" + MV_PAR07 + "'" +CRLF
cQry += "AND AKU.D_E_L_E_T_ = '' " +CRLF
cQry += "GROUP BY AKU_UNGEST, AKU_PROGR " +CRLF

cQry += "UNION ALL " +CRLF

//--VINCULADO
cQry += "SELECT AKU_UNGEST, AKU_PROGR, 0 PROP, SUM(AKU_TOTPPA) VINCU, SUM(AKU_TOTPPA) TOTAL FROM " +RetSqlName("AKU") +" AKU" +CRLF
cQry += "RIGHT JOIN " +RetSqlName("ALE") +" ALE" +CRLF
cQry += "ON ALE_FILIAL = AKU_FILIAL" +CRLF
cQry += "AND ALE_CODACA = AKU_ACAO" +CRLF
cQry += "AND ALE_TPRCRS = 2" +CRLF
cQry += "AND ALE.D_E_L_E_T_ = ''" +CRLF
cQry += "WHERE AKU_FILIAL   =  '" + FwxFilial("AKU") + "'" +CRLF
cQry += "AND AKU_CODIGO     =  '" + MV_PAR01 + "'" +CRLF
cQry += "AND AKU_VERSAO		=  '" + MV_PAR02 + "' " +CRLF
cQry += "AND AKU_ANO        =   " + CVALTOCHAR(MV_PAR03) +CRLF
cQry += "AND AKU_UNGEST     >= '" + MV_PAR04 + "'" +CRLF
cQry += "AND AKU_UNGEST     <= '" + MV_PAR05 + "'" +CRLF
cQry += "AND AKU_PROGR      >= '" + MV_PAR06 + "'" +CRLF
cQry += "AND AKU_PROGR      <= '" + MV_PAR07 + "'" +CRLF
cQry += "AND AKU.D_E_L_E_T_ = '' " +CRLF
cQry += "GROUP BY AKU_UNGEST, AKU_PROGR) TAB " +CRLF
cQry += "GROUP BY AKU_UNGEST, AKU_PROGR " +CRLF
cQry += "ORDER BY AKU_UNGEST, AKU_PROGR " +CRLF

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlsAK4,.T.,.F.)

oGestora:Init()
oPrograma:Init()
While ((cAlsAK4)->(!EOF()))

    If (cAlsAK4)-> AKU_UNGEST == cUniGest
        oPrograma:PrintLine()
    Else
        oPrograma:Finish()
        oGestora:PrintLine()
        oPrograma:Init()
        oPrograma:PrintLine()
    EndIf

    cUniGest := (cAlsAK4)-> AKU_UNGEST
    (cAlsAK4)->(dbSkip())
   
End
oGestora:Finish()
oPrograma:Finish()

Return .T.