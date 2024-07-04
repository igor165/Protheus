#Include "PCOR071.CH"
#Include "PROTHEUS.CH"

#DEFINE CAT_COD     1
#DEFINE CAT_DESCRI  2
#DEFINE CAT_VALOR   3

#DEFINE TOT_SUBTOTAL  1
#DEFINE TOT_SUPERAVIT 2
#DEFINE TOT_TOTAL     3

#DEFINE TOT_DESCRI  1
#DEFINE TOT_VALOR   2

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR071
Relatorio Demonstraçao da Receita e Despesa segundo as Categorias 
Econômicas

@author Totvs
   
@version P12
@since   08/05/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR071()

Local oReport
Local cPerg    := "PCOR071"
Local cFindSX1 := Padr("PCOR071", Len(SX1->X1_GRUPO), " ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01    Período De:           									³
//³ mv_par02    Período Até:                							³
//³ mv_par03    Aglutinador de Visoes:          						³
//³ mv_par04    Moeda:    							                    ³
//³ mv_par05    Divide por:    						                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstraçao da Receita e Despesa segundo as Categorias Econômicas disponível a partir da versao 12.1.23"
ElseIf !SX1->(dbSeek(cFindSX1))
    Help(,, "Help",, OemToAnsi(STR0002), 1, 0) //"Para utilizaçao do relatório Demonstraçao da Receita e Despesa segundo as Categorias Econômicas é necessário aplicar o pacote acumulado da controladoria."
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
@since   08/05/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oCorrente, oCapital, oBorder
Local cNomeProg := "PCOR071"
Local cTitulo   := Capital(STR0003) //"Demonstraçao da Receita e Despesa segundo as Categorias Econômicas"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatório Demonstraçao da Receita e Despesa segundo as Categorias Econômicas."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
    {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)                                    		
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como retrato
oReport:DisableOrientation() //Desabilita opcao para mudar orientacao de impressao
oReport:SetTotalInLine(.F.)
oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0005, {}, /*aOrdem*/) //"Exercício Financeiro"
TRCell():New(oCabec, "EXERCICIO",, "",, 40, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder //Remove a borda do cabecalho

//Colunas referentes as Receitas Correntes
oCorrente := TRSection():New(oReport, STR0006, {"cArqTmp"},, .F., .F.) //"Correntes"
TRCell():New(oCorrente, "REC_CORRENTES",, "" /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TamSx3("A1H_CHVCNT")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT",, 5) 
TRCell():New(oCorrente, "REC_VAL_CORR" ,, "" /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",, 10) 

//Colunas referentes as Despesas Correntes
TRCell():New(oCorrente, "DESC_CORRENTES",, "" /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TamSx3("A1H_CHVCNT")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 5)
TRCell():New(oCorrente, "DESC_VAL_CORR" ,, "" /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",, 5) 

//Criacao da Secao Valores Capitais
oCapital := TRSection():New(oReport, STR0007, {"cArqTmp"},, .F., .F.) //"Capitais"

//Colunas referentes as Receitas Capitais
TRCell():New(oCapital, "REC_CAPITAL",, "" /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TamSx3("A1H_CHVCNT")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 5) 
TRCell():New(oCapital, "REC_VAL_CAP",, "" /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",, 10) 

//Colunas referentes as Despesas Capitais
TRCell():New(oCapital, "DESC_CAPITAL",, "" /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TamSx3("A1H_CHVCNT")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 5) 
TRCell():New(oCapital, "DESC_VAL_CAP",, "" /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT",, 10) 

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao 
utilizadas

@author Totvs
   
@version P12
@since   08/05/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec     := oReport:Section(1)
Local oCorrente  := oReport:Section(2)
Local oCapital   := oReport:Section(3) 
Local dDataIni   := MV_PAR01
Local dDataFim   := MV_PAR02
Local cArqTmp    := GetNextAlias()
Local cCodAgl    := MV_PAR03
Local cMoeda     := MV_PAR04 
Local cChvRecCor := ""
Local cChvRecCap := ""
Local cChvDesCor := ""
Local cChvDesCap := ""
Local cCondCta   := ""
Local cTitulo    := STR0008 //"Demonstraçao da Receita e Despesa"
Local aMoedas    := CtbMoeda(cMoeda) 
Local nI         := 0
Local nX         := 0
Local nPos       := 0
Local nDif       := 0
Local nIniCpoCE  := 0
Local nDigCpoCE  := 0
Local nIniCpoDE  := 0
Local nDigCpoDE  := 0
Local nIniCatRe  := 0
Local nDigCatRe  := 0
Local nIniCatDe  := 0
Local nDigCatDe  := 0
Local nDivide    := 1
//Local aFiltros   := {}
Local aRecCorr   := {}
Local aRecCap    := {}
Local aDesCorr   := {}
Local aDesCap    := {}
Local aA1HReCor  := {}
Local aA1HReCap  := {}
Local aA1HDeCor  := {}
Local aA1HDeCap  := {}
Local aTotRecCor := {}
Local aTotRecCap := {}
Local aTotDesCor := {}
Local aTotDesCap := {}

/*
//Monta filtros
aAdd(aFiltros, "")                              //Conta Orcamentaria De
aAdd(aFiltros, Repl("Z", Len(AKD->AKD_CO)))     //Conta Orcamentaria Ate
aAdd(aFiltros, "")                              //Classe Orcamentaria De
aAdd(aFiltros, Repl("Z", Len(AKD->AKD_CLASSE))) //Classe Orcamentaria Ate
aAdd(aFiltros, "")                              //Tipo de Saldo
aAdd(aFiltros, "")                              //Centro de Custo De
aAdd(aFiltros, Repl("Z", Len(AKD->AKD_CC)))     //Centro de Custo Ate
aAdd(aFiltros, "")                              //Item De
aAdd(aFiltros, Repl("Z", Len(AKD->AKD_ITCTB)))  //Item Ate
aAdd(aFiltros, "")                              //Classe de Valor De
aAdd(aFiltros, Repl("Z", Len(AKD->AKD_CLVLR)))  //Classe de Valor Ate
*/

//Divide por
If MV_PAR05 == 2        //Divide por cem
	nDivide := 100
ElseIf MV_PAR05 == 3    //Divide por mil
	nDivide := 1000
ElseIf MV_PAR05 == 4	//Divide por milhao
	nDivide := 1000000
EndIf

//Monta Arquivo Temporario para Impressao
MsgMeter({|oMeter, oText, oDlg, lEnd| ;
			PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
					  cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                      nil,nil,nDivide)},;
			          STR0009, cTitulo) //"Criando Arquivo Temporario..."

A1G->(dbSetOrder(1)) //A1G_FILIAL+A1G_CODTAB
A1H->(dbSetOrder(1)) //A1H_FILIAL+A1H_CODTAB+A1H_ITETAB+A1H_RADCHV+A1H_ITECHV

If (cArqTmp)->(!Eof())
    //Categoria Econômica de Receitas
    If A1G->(dbSeek(xFilial("A1G")+"CE")) 
        nIniCpoCE := A1G->A1G_INICPO
        nDigCpoCE := A1G->A1G_DIGCPO
        
        If A1H->(dbSeek(xFilial("A1H")+A1G->A1G_CODTAB)) 
            While A1H->(!EOF()) .And. A1H->A1H_FILIAL == xFilial("A1H") .And. A1H->A1H_CODTAB == "CE"
                If A1H->A1H_ITETAB == "0001"
                    cChvRecCor := AllTrim(A1H->A1H_ITECHV)
                    
                    //Cabecalho Receitas Correntes
                    aAdd(aRecCorr, {"", AllTrim(A1H->A1H_CHVCNT), 0}) 
                ElseIf A1H->A1H_ITETAB == "0002"
                    cChvRecCap := AllTrim(A1H->A1H_ITECHV)

                    //Cabecalho Receitas Capitais
                    aAdd(aRecCap, {"", AllTrim(A1H->A1H_CHVCNT), 0}) 
                EndIf
            
                A1H->(dbSkip()) 
            EndDo
        EndIf

        If A1G->(dbSeek(xFilial("A1G")+"O1")) //Receitas Correntes
            nIniCatRe := A1G->A1G_INICPO
            nDigCatRe := A1G->A1G_DIGCPO

            //Armazena itens de configuracao
            If A1H->(dbSeek(xFilial("A1H")+A1G->A1G_CODTAB))  
                While A1H->(!EOF()) .And. A1H->A1H_FILIAL == xFilial("A1H") .And. A1H->A1H_CODTAB == "O1"
                    aAdd(aA1HReCor, {AllTrim(A1H->A1H_ITECHV), AllTrim(A1H->A1H_CHVCNT)})
                    A1H->(dbSkip())
                EndDo
            EndIf
        EndIf 

        If A1G->(dbSeek(xFilial("A1G")+"O2")) //Receitas Capitais
            //Armazena itens de configuracao
            If A1H->(dbSeek(xFilial("A1H")+A1G->A1G_CODTAB))  
                While A1H->(!EOF()) .And. A1H->A1H_FILIAL == xFilial("A1H") .And. A1H->A1H_CODTAB == "O2"
                    aAdd(aA1HReCap, {AllTrim(A1H->A1H_ITECHV), AllTrim(A1H->A1H_CHVCNT)})
                    A1H->(dbSkip())
                EndDo
            EndIf
        EndIf 
    EndIf

    //Categoria Econômica de Despesas
    If A1G->(dbSeek(xFilial("A1G")+"DE")) 
        nIniCpoDE := A1G->A1G_INICPO
        nDigCpoDE := A1G->A1G_DIGCPO
        
        If A1H->(dbSeek(xFilial("A1H")+A1G->A1G_CODTAB)) //Categoria Econômica de Despesas
            While A1H->(!EOF()) .And. A1H->A1H_CODTAB == "DE"
                If A1H->A1H_ITETAB == "0001"
                    cChvDesCor := AllTrim(A1H->A1H_ITECHV)

                    //Cabecalho Despesas Correntes
                    aAdd(aDesCorr, {"", AllTrim(A1H->A1H_CHVCNT), 0}) 
                ElseIf A1H->A1H_ITETAB == "0002"
                    cChvDesCap := AllTrim(A1H->A1H_ITECHV)

                    //Cabecalho Despesas Capitais
                    aAdd(aDesCap, {"", AllTrim(A1H->A1H_CHVCNT), 0})
                EndIf
            
                A1H->(dbSkip())
            EndDo
        EndIf

        If A1G->(dbSeek(xFilial("A1G")+"GD")) 
            nIniCatDe := A1G->A1G_INICPO
            nDigCatDe := A1G->A1G_DIGCPO

            //Armazena itens de configuracao
            If A1H->(dbSeek(xFilial("A1H")+A1G->A1G_CODTAB))  
                While A1H->(!EOF()) .And. A1H->A1H_FILIAL == xFilial("A1H") .And. A1H->A1H_CODTAB == "GD"
                    If AllTrim(A1H->A1H_ITECHV) $ "0|1|2|3"
                        aAdd(aA1HDeCor, {AllTrim(A1H->A1H_ITECHV), AllTrim(A1H->A1H_CHVCNT)}) //Despesas Correntes
                    ElseIf AllTrim(A1H->A1H_ITECHV) $ "4|5|6|8"
                        aAdd(aA1HDeCap, {AllTrim(A1H->A1H_ITECHV), AllTrim(A1H->A1H_CHVCNT)}) //Despesas Capitais
                    EndIf

                    A1H->(dbSkip())
                EndDo
            EndIf
        EndIf 
    EndIf

    //Inicializa arrays com Totais de cada categoria
    aAdd(aTotRecCor, {STR0010, 0}) //"SUB-TOTAL"
    aAdd(aTotRecCor, {STR0011, 0}) //"SUPERAVIT ORCAMENTARIO"
    aAdd(aTotRecCor, {STR0013, 0}) //"TOTAL"

    aAdd(aTotRecCap, {STR0010, 0}) //"SUB-TOTAL"
    aAdd(aTotRecCap, {STR0012, 0}) //"SUPERAVIT ORCAMENTARIO CORRENTE"
    aAdd(aTotRecCap, {STR0013, 0}) //"TOTAL"

    aTotDesCor := aClone(aTotRecCor)
    aTotDesCap := aClone(aTotRecCor)

    //Alimenta os arrays com valores
    While (cArqTmp)->(!Eof())
        If oReport:Cancel()
            Exit
        EndIf

        //Flag Tipo da Conta: 1 = Receita; 2 = Despesa
        cCondCta := Posicione("AK5", 1, xFilial("AK5") + (cArqTmp)->AKD_CO, "AK5_DEBCRE")  

        //Adiciona valores conforme categoria     
        Do Case
            Case cCondCta == "1" .And. SubStr((cArqTmp)->AKD_CO, nIniCpoCE, nDigCpoCE) == cChvRecCor //Receitas Correntes
                If (nPos := aScan(aRecCorr, {|x| x[CAT_COD] == SubStr((cArqTmp)->AKD_CO, nIniCatRe, nDigCatRe)})) > 0
                    aRecCorr[nPos][CAT_VALOR] += (cArqTmp)->AKD_VALOR1               
                ElseIf (nPos := aScan(aA1HReCor, {|x| x[CAT_COD] == SubStr((cArqTmp)->AKD_CO, nIniCatRe, nDigCatRe)})) > 0
                    aAdd(aRecCorr, {aA1HReCor[nPos][CAT_COD], aA1HReCor[nPos][CAT_DESCRI], (cArqTmp)->AKD_VALOR1})
                EndIf

                aTotRecCor[TOT_SUBTOTAL][TOT_VALOR] += (cArqTmp)->AKD_VALOR1 //Armazena sub-total 
            Case cCondCta == "1" .And. SubStr((cArqTmp)->AKD_CO, nIniCpoCE, nDigCpoCE) == cChvRecCap //Receitas Capitais
                If (nPos := aScan(aRecCap, {|x| x[CAT_COD] == SubStr((cArqTmp)->AKD_CO, nIniCatRe, nDigCatRe)})) > 0
                    aRecCap[nPos][CAT_VALOR] += (cArqTmp)->AKD_VALOR1               
                ElseIf (nPos := aScan(aA1HReCap, {|x| x[CAT_COD] == SubStr((cArqTmp)->AKD_CO, nIniCatRe, nDigCatRe)})) > 0
                    aAdd(aRecCap, {aA1HReCap[nPos][CAT_COD], aA1HReCap[nPos][CAT_DESCRI], (cArqTmp)->AKD_VALOR1})
                EndIf

                aTotRecCap[TOT_SUBTOTAL][TOT_VALOR] += (cArqTmp)->AKD_VALOR1 //Armazena sub-total
            Case cCondCta == "2" .And. SubStr((cArqTmp)->AKD_CO, nIniCpoDE, nDigCpoDE) == cChvDesCor //Despesas Correntes
                If (nPos := aScan(aDesCorr, {|x| x[CAT_COD] == SubStr((cArqTmp)->AKD_CO, nIniCatDe, nDigCatDe)})) > 0
                    aDesCorr[nPos][CAT_VALOR] += (cArqTmp)->AKD_VALOR1               
                ElseIf (nPos := aScan(aA1HDeCor, {|x| x[CAT_COD] == SubStr((cArqTmp)->AKD_CO, nIniCatDe, nDigCatDe)})) > 0
                    aAdd(aDesCorr, {aA1HDeCor[nPos][CAT_COD], aA1HDeCor[nPos][CAT_DESCRI], (cArqTmp)->AKD_VALOR1})
                EndIf

                aTotDesCor[TOT_SUBTOTAL][TOT_VALOR] += (cArqTmp)->AKD_VALOR1 //Armazena sub-total
            Case cCondCta == "2" .And. SubStr((cArqTmp)->AKD_CO, nIniCpoDE, nDigCpoDE) == cChvDesCap //Despesas Capitais
                If (nPos := aScan(aDesCap, {|x| x[CAT_COD] == SubStr((cArqTmp)->AKD_CO, nIniCatDe, nDigCatDe)})) > 0
                    aDesCap[nPos][CAT_VALOR] += (cArqTmp)->AKD_VALOR1               
                ElseIf (nPos := aScan(aA1HDeCap, {|x| x[CAT_COD] == SubStr((cArqTmp)->AKD_CO, nIniCatDe, nDigCatDe)})) > 0
                    aAdd(aDesCap, {aA1HDeCap[nPos][CAT_COD], aA1HDeCap[nPos][CAT_DESCRI], (cArqTmp)->AKD_VALOR1})
                EndIf

                aTotDesCap[TOT_SUBTOTAL][TOT_VALOR] += (cArqTmp)->AKD_VALOR1 //Armazena sub-total
        EndCase

        (cArqTmp)->(dbSkip())
    EndDo

    //** Iguala tamanho dos arrays correntes e capitais para que seja possível comparacao no relatorio

    //Array com Valores Correntes
    If Len(aRecCorr) > Len(aDesCorr)
        nDif := Len(aRecCorr) - Len(aDesCorr)

        For nI := 1 To nDif
            aAdd(aDesCorr, {"", "", 0})
        Next nI
    ElseIf Len(aDesCorr) > Len(aRecCorr)
        nDif := Len(aDesCorr) - Len(aRecCorr)

        For nI := 1 To nDif
            aAdd(aRecCorr, {"", "", 0})
        Next nI
    EndIf

    //Arrays com Valores Capitais
    If Len(aRecCap) > Len(aDesCap)
        nDif := Len(aRecCap) - Len(aDesCap)

        For nI := 1 To nDif
            aAdd(aDesCap, {"", "", 0})
        Next nI
    ElseIf Len(aDesCap) > Len(aRecCap)
        nDif := Len(aDesCap) - Len(aRecCap)

        For nI := 1 To nDif
            aAdd(aRecCap, {"", "", 0})
        Next nI
    EndIf

    //Calcula e armazena Superávit das Categorias
    aTotDesCor[TOT_SUPERAVIT][TOT_VALOR] := aTotRecCor[TOT_SUBTOTAL][TOT_VALOR] - aTotDesCor[TOT_SUBTOTAL][TOT_VALOR]
    aTotRecCap[TOT_SUPERAVIT][TOT_VALOR] := aTotDesCor[TOT_SUPERAVIT][TOT_VALOR]
    aTotDesCap[TOT_SUPERAVIT][TOT_VALOR] := (aTotRecCap[TOT_SUBTOTAL][TOT_VALOR] + aTotRecCap[TOT_SUPERAVIT][TOT_VALOR]) - aTotDesCap[TOT_SUBTOTAL][TOT_VALOR]

    //Calcula Armazena Total das Categorias
    aTotRecCor[TOT_TOTAL][TOT_VALOR] := aTotRecCor[TOT_SUBTOTAL][TOT_VALOR] + aTotRecCor[TOT_SUPERAVIT][TOT_VALOR]
    aTotRecCap[TOT_TOTAL][TOT_VALOR] := aTotRecCap[TOT_SUBTOTAL][TOT_VALOR] + aTotRecCap[TOT_SUPERAVIT][TOT_VALOR]
    aTotDesCor[TOT_TOTAL][TOT_VALOR] := aTotDesCor[TOT_SUBTOTAL][TOT_VALOR] + aTotDesCor[TOT_SUPERAVIT][TOT_VALOR]
    aTotDesCap[TOT_TOTAL][TOT_VALOR] := aTotDesCap[TOT_SUBTOTAL][TOT_VALOR] + aTotDesCap[TOT_SUPERAVIT][TOT_VALOR]

    //Inicio da impressao
    If Len(aRecCorr) > 0 .Or. Len(aRecCap) > 0
        //Imprime cabecalho
        oCabec:Init()
        oCabec:Cell("EXERCICIO"):SetBlock({|| STR0014 + SubStr(DToS(MV_PAR01), 1, 4) + STR0015 + AllTrim(aMoedas[3]) + STR0016}) //"Exercício Financeiro de: " #" (em: " ## ")"
        oCabec:PrintLine()
        oCabec:Finish()

        //Pula linha
        oReport:SkipLine()   
    EndIf

    //Imprime valores correntes
    For nI := 1 To Len(aRecCorr) 
        oReport:IncMeter() //Regua

        If nI == 1
            //Inicializa valores correntes
            oCorrente:Init()

            oCorrente:Cell("REC_CORRENTES"):SetTitle(aRecCorr[nI][CAT_DESCRI])
            oCorrente:Cell("DESC_CORRENTES"):SetTitle(aDesCorr[nI][CAT_DESCRI])
        Else
            //Receitas correntes
            If !Empty(aRecCorr[nI][2])
                oCorrente:Cell("REC_CORRENTES"):SetBlock({|| aRecCorr[nI][CAT_DESCRI]})
                oCorrente:Cell("REC_VAL_CORR"):SetBlock({|| aRecCorr[nI][CAT_VALOR]})
            Else
                oCorrente:Cell("REC_CORRENTES"):Hide()
                oCorrente:Cell("REC_VAL_CORR"):Hide()
            EndIf

            //Despesas correntes
            If !Empty(aDesCorr[nI][2])
                oCorrente:Cell("DESC_CORRENTES"):SetBlock({|| aDesCorr[nI][CAT_DESCRI]})
                oCorrente:Cell("DESC_VAL_CORR"):SetBlock({|| aDesCorr[nI][CAT_VALOR]})
            Else
                oCorrente:Cell("DESC_CORRENTES"):Hide()
                oCorrente:Cell("DESC_VAL_CORR"):Hide()
            EndIf
        EndIf
        
        oCorrente:PrintLine()

        //Habilita exibicao de campos
        oCorrente:Cell("REC_CORRENTES"):Show()
        oCorrente:Cell("REC_VAL_CORR"):Show()
        oCorrente:Cell("DESC_CORRENTES"):Show()
        oCorrente:Cell("DESC_VAL_CORR"):Show()

        //Último registro imprime totais
        If nI == Len(aRecCorr)
            oReport:SkipLine() //pula linha

            For nX := 1 To Len(aTotRecCor)
                If nX <> 2
                    oCorrente:Cell("REC_CORRENTES"):SetBlock({|| aTotRecCor[nX][TOT_DESCRI]})
                    oCorrente:Cell("REC_VAL_CORR"):SetBlock({|| aTotRecCor[nX][TOT_VALOR]})
                Else
                    oCorrente:Cell("REC_CORRENTES"):SetBlock({|| ""})
                    oCorrente:Cell("REC_VAL_CORR"):Hide()
                EndIf

                oCorrente:Cell("DESC_CORRENTES"):SetBlock({|| aTotDesCor[nX][TOT_DESCRI]})
                oCorrente:Cell("DESC_VAL_CORR"):SetBlock({|| aTotDesCor[nX][TOT_VALOR]})

                oCorrente:PrintLine()

                oCorrente:Cell("REC_VAL_CORR"):Show() //Habilita exibicao de campo
            Next nX

            //Finaliza objeto e pula linha
            oCorrente:Finish()
            oReport:SkipLine()
        EndIf
    Next nI

    //Imprime valores capitais
    For nI := 1 To Len(aRecCap) 
        oReport:IncMeter() //Regua

        If nI == 1
            //Inicializa valores capitais
            oCapital:Init()

            oCapital:Cell("REC_CAPITAL"):SetTitle(aRecCap[nI][CAT_DESCRI])
            oCapital:Cell("DESC_CAPITAL"):SetTitle(aDesCap[nI][CAT_DESCRI])
        Else
            //Receitas capitais
            If !Empty(aRecCap[nI][2])
                oCapital:Cell("REC_CAPITAL"):SetBlock({|| aRecCap[nI][CAT_DESCRI]})
                oCapital:Cell("REC_VAL_CAP"):SetBlock({|| aRecCap[nI][CAT_VALOR]})
            Else
                oCapital:Cell("REC_CAPITAL"):Hide()
                oCapital:Cell("REC_VAL_CAP"):Hide()
            EndIf

            //Despesas capitais
            If !Empty(aDesCap[nI][2])
                oCapital:Cell("DESC_CAPITAL"):SetBlock({|| aDesCap[nI][CAT_DESCRI]})
                oCapital:Cell("DESC_VAL_CAP"):SetBlock({|| aDesCap[nI][CAT_VALOR]})
            Else
                oCapital:Cell("DESC_CAPITAL"):Hide()
                oCapital:Cell("DESC_VAL_CAP"):Hide()
            EndIf
        EndIf

    oCapital:PrintLine()

    //Habilita campos
        oCapital:Cell("REC_CAPITAL"):Show()
        oCapital:Cell("REC_VAL_CAP"):Show()
        oCapital:Cell("DESC_CAPITAL"):Show()
        oCapital:Cell("DESC_VAL_CAP"):Show()

        //Último registro imprime totais
        If nI == Len(aRecCap)
            oReport:SkipLine() //pula linha

            For nX := 1 To Len(aTotRecCap)
                oCapital:Cell("REC_CAPITAL"):SetBlock({|| aTotRecCap[nX][TOT_DESCRI]})
                oCapital:Cell("REC_VAL_CAP"):SetBlock({|| aTotRecCap[nX][TOT_VALOR]})

                oCapital:Cell("DESC_CAPITAL"):SetBlock({|| aTotDesCap[nX][TOT_DESCRI]})
                oCapital:Cell("DESC_VAL_CAP"):SetBlock({|| aTotDesCap[nX][TOT_VALOR]})

                oCapital:PrintLine()
            Next nX

            //Finaliza objeto
            oCapital:Finish()
        EndIf
    Next nI 
EndIf  

//Fecha arquivo temporario
If Select("cArqTmp") > 0
    (cArqTmp)->(dbCloseArea()) 
EndIf

Return .T.