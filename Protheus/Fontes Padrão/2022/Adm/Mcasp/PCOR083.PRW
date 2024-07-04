#Include "PCOR083.CH"
#Include "PROTHEUS.CH"

#DEFINE CODTAB      1
#DEFINE DESTAB      2
#DEFINE CPOMOV      3
#DEFINE POSINI      4
#DEFINE QTDDIG      5
#DEFINE ITETAB      6
#DEFINE ITECHV      1
#DEFINE ITEDES      2

#DEFINE CODDES      1
#DEFINE VLRDOTINI   2
#DEFINE VLRDOTATU   3
#DEFINE VLREMPNOBIM 4
#DEFINE VLREMPATBIM 5
#DEFINE VLRLIQNOBIM 6
#DEFINE VLRLIQATBIM 7
#DEFINE TIPOENT     8

#DEFINE ITEHASH     2
#DEFINE TAMDESCRI   55

Static __nPosDes   := 1
Static __nFunOpc   := 0
Static __aTabFC    := {}
Static __aTabSB    := {}
Static __aDespesas := {}
Static __aTotDesp  := {}

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR083
Relatorio Demonstrativo da Execucao das Despesas por Funcao/SubFuncao					

@author Totvs
   
@version P12
@since   20/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR083()

Local oReport := Nil
Local cPerg   := Padr("PCOR083", Len(SX1->X1_GRUPO))

//=================================================================================================================================================
//mv_par01    Exercício:   
//mv_par02    Bimestre: 
//mv_par03    Aglut. Visao Dot. Inicial:
//mv_par04    Aglut. Visao Dot. Atual.:
//mv_par05    Aglut. Visao Desp. Empen.:
//mv_par06    Aglut. Visao Desp. Liquid.:
//mv_par07    Moeda:
//mv_par08    Divide Por:    						                    
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
	
//CLEAR VAR STATIC
__nPosDes   := 1
__nFunOpc   := 0
__aTabFC    := {}
__aTabSB    := {}
__aDespesas := {}
__aTotDesp  := {}

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   18/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec1, oCabec2, oDespesas, oBorder
Local cNomeProg := "PCOR083"
Local cTitulo   := Capital(STR0003)  //"Relatório Demonstrativo da Execucao das Despesas por Funcao/SubFuncao"
Local cDescri 	:= OemToAnsi(STR0004)  //"Este programa irá imprimir o Relatório Demonstrativo da Execucao das Despesas por Funcao/SubFuncao."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:SetTotalInLine(.F.)
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como retrato
oReport:DisableOrientation() //Desabilita opcao para mudar orientacao de impressao                                  

//Configuracoes de impressao
oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho 1
oCabec1 := TRSection():New(oReport, "CABEC_1", {}, /*aOrdem*/) 
TRCell():New(oCabec1, "CABEC_1",, "",, 170, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) 
oCabec1:oHBrdBottom := oBorder //Remove a borda do cabecalho 1
oCabec1:setLinesBefore(0)

//Criacao da Secao Cabecalho 2
oCabec2 := TRSection():New(oReport, "CABEC_2", {}, /*aOrdem*/) 
TRCell():New(oCabec2, "CABEC_2",, "",, 170, /*lPixel*/, /*CodeBlock*/, "CENTER",, "CENTER",,,,,, .T.) 
oCabec2:oHBrdBottom := oBorder //Remove a borda do cabecalho 1
oCabec2:setLinesBefore(0)

//Criacao da Secao Despesas por Unidade Orçamentária
oDespesas := TRSection():New(oReport, "DESPESAS", {"cArqTmp"},, .F., .F.)

//Colunas referentes as Despesas por Unidade Orçamentária
TRCell():New(oDespesas, "FUNC_SUBF"   ,, STR0005                                                 /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TAMDESCRI               /*Tamanho*/, /*lPixel*/, {|| Des_Desp()}  /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 3) //"Funcao/SubFuncao"
TRCell():New(oDespesas, "DOTINI"      ,, STR0006+CHR(13)+CHR(10)+STR0007                         /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Desp(1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Dotacao" #"Inicial"
TRCell():New(oDespesas, "DOTATU"      ,, STR0006+CHR(13)+CHR(10)+STR0030                         /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Desp(2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Dotacao" #"Atualizada"
TRCell():New(oDespesas, "DESPEMP_NOB" ,, STR0008+CHR(13)+CHR(10)+STR0010+CHR(13)+CHR(10)+STR0009 /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Desp(3)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Despesas" #"Empenhadas" ##"no Bimestre"
TRCell():New(oDespesas, "DESPEMP_ATEB",, STR0008+CHR(13)+CHR(10)+STR0010+CHR(13)+CHR(10)+STR0011 /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Desp(4)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Despesas" #"Empenhadas" ##"ate o Bimestre"
TRCell():New(oDespesas, "SALDO_EMP"   ,, STR0012                                                 /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Desp(5)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Saldo"
TRCell():New(oDespesas, "DESPLIQ_NOB" ,, STR0008+CHR(13)+CHR(10)+STR0013+CHR(13)+CHR(10)+STR0009 /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Desp(6)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Despesas" #"Liquidadas" ##"no Bimestre"
TRCell():New(oDespesas, "DESPLIQ_ATEB",, STR0008+CHR(13)+CHR(10)+STR0013+CHR(13)+CHR(10)+STR0011 /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Desp(7)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Despesas" #"Liquidadas" ##"ate o Bimestre"
TRCell():New(oDespesas, "SALDO_LIQ"   ,, STR0012                                                 /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Desp(8)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Saldo"
oDespesas:SetLinesBefore(0)

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

Local oCabec1    := oReport:Section("CABEC_1")
Local oCabec2    := oReport:Section("CABEC_2")
Local oDespesas  := oReport:Section("DESPESAS")
Local oHashDes   := HMNew()   
Local cCodAgl    := ""
Local cNomReal   := ""
Local dDataFim   := ""
Local cArqTmp    := ""
Local cEntidd    := ""
Local cCpoValor  := ""
Local cExerc     := MV_PAR01
Local cBimestre  := MV_PAR02
Local cMoeda     := MV_PAR07 
Local dDataIni   := SToD(cExerc + "0101")
Local cTitulo    := STR0014 //"Demonstrativo da Execucao das Despesas por Funcao/SubFuncao"
Local aMoedas    := CtbMoeda(cMoeda) 
Local nI         := 0
Local nX         := 0
Local nVlDotIni  := 0
Local nVlDotAtu  := 0
Local nVlEmpNBi  := 0
Local nVlEmpABi  := 0
Local nVlLiqNBi  := 0
Local nVlLiqABi  := 0
Local nDivide    := 1
Local aLinAux    := {}

/*
1 – Órgão: Unidade Orçamentária + Unidade Executora (6 dígitos) – Campos distintos - Específico      Substr(AKD_CO, 1,6)
2 – Função: (2 dígitos) – Portaria 42/1999                                                           Substr(AKD_CO, 7,2)   
3 – Sub Função: (3 dígitos) – Portaria 42/1999                                                       Substr(AKD_CO, 9,3)
4 – Programas: (4 dígitos) - Específico                                                              Substr(AKD_CO,12,4)
5 – Ação (4 dígitos) - Específico                                                                    Substr(AKD_CO,16,4)
6 – Categoria Econômica ( 1 dígito) – Lei 4.320/64                                                   Substr(AKD_CO,17,1)
7 – Grupo da Despesa ( 1 dígito) – Lei 4.320/64                                                      Substr(AKD_CO,18,1)
8 – Modalidade de Aplicação (2 dígitos) – Lei 4.320/64                                               Substr(AKD_CO,19,2) 
9 – Elemento da despesa (2 dígitos) – Lei 4.320/64                                                   Substr(AKD_CO,21,2)
10 – Sub Elemento da Despesa - Específico                                                            Substr(AKD_CO,23,x)//nao definido
11 – Fonte de Recurso (2 - digitos) - Específico                                                     Substr(AKD_CO, y,z)//nao definido
12 – Código de Aplicação (4 - digitos) - Específico                                                  Substr(AKD_CO, s,t)//nao definido

Neste Relatorio vamos utilizar: 

Funcao + SubFuncao -> Substr(AKD_CO, 7, 5)
Tabela FC-FC - Funcao
Tabela SB-SB - SubFuncao
*/

//Armazena Data Final
If cBimestre == "1"
    dDataFim := LastDay(SToD(cExerc + "0201"))
ElseIf cBimestre == "2"
    dDataFim := LastDay(SToD(cExerc + "0401"))
ElseIf cBimestre == "3"
    dDataFim := LastDay(SToD(cExerc + "0601"))
ElseIf cBimestre == "4"
    dDataFim := LastDay(SToD(cExerc + "0801"))
ElseIf cBimestre == "5"
    dDataFim := LastDay(SToD(cExerc + "1001"))
ElseIf cBimestre == "6"
    dDataFim := LastDay(SToD(cExerc + "1201"))
EndIf

//Divide por
If MV_PAR08 == 2     //Divide por cem
	nDivide := 100
ElseIf MV_PAR08 == 3 //Divide por mil
	nDivide := 1000
ElseIf MV_PAR08 == 4 //Divide por milhao
	nDivide := 1000000
EndIf

__aTabFC := CargaTab( "FC"/*cTabela*/, "FC"/*cRadical*/)  //Funcao
__aTabSB := CargaTab( "SB"/*cTabela*/, "SB"/*cRadical*/)  //SubFuncao

cCpoValor  := "AKD_VALOR" + CValToChar(Val(cMoeda))
__aTotDesp := {"", 0, 0, 0, 0, 0, 0}

For nI := 1 To 4
    cArqTmp := GetNextAlias()
    
    //Armazena Codigo Aglutinadora de Visoes
    If nI == 1
        cCodAgl := MV_PAR03
    ElseIf nI == 2
        cCodAgl := MV_PAR04
    ElseIf nI == 3
        cCodAgl := MV_PAR05
    Else
        cCodAgl := MV_PAR06
    EndIf 

    //Monta Arquivo Temporario para Impressao
    MsgMeter({|oMeter, oText, oDlg, lEnd| ;
                cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, cMoeda, .T., cCodAgl, dDataIni, dDataFim,;
                                        Nil, Nil, nDivide)}, STR0015, cTitulo) //"Criando Arquivo Temporario..."
                
    //Verifica todo o arquivo 
    While (cArqTmp)->(!Eof())
        If oReport:Cancel()
            Exit
        EndIf
        
        //Inicializa valores
        nVlDotIni := 0 //Dotacao Inicial
        nVlDotAtu := 0 //Dotacao Atualizada
        nVlEmpNBi := 0 //Despesas Empenhadas no Bimestre
        nVlEmpABi := 0 //Despesas Empenhadas ate o Bimestre
        nVlLiqNBi := 0 //Despesas Liquidadas no Bimestre
        nVlLiqABi := 0 //Despesas Liquidadas ate o Bimestre

        //Alimenta valores das visoes
        If nI == 1
            nVlDotIni := &("(cArqTmp)->" + cCpoValor)
            __aTotDesp[VLRDOTINI] += &("(cArqTmp)->" + cCpoValor)
        ElseIf nI == 2
            nVlDotAtu := &("(cArqTmp)->" + cCpoValor)
            __aTotDesp[VLRDOTATU] += &("(cArqTmp)->" + cCpoValor)
        ElseIf nI == 3
            If CTB083IsBim(cBimestre, (cArqTmp)->AKD_DATA) //Verifica se é no Bimestre
                nVlEmpNBi := &("(cArqTmp)->" + cCpoValor)
                __aTotDesp[VLREMPNOBIM] += &("(cArqTmp)->" + cCpoValor)
            EndIf
            
            nVlEmpABi := &("(cArqTmp)->" + cCpoValor)
            __aTotDesp[VLREMPATBIM] += &("(cArqTmp)->" + cCpoValor)
        ElseIf nI == 4
            If CTB083IsBim(cBimestre, (cArqTmp)->AKD_DATA) //Verifica se é no Bimestre
                nVlLiqNBi := &("(cArqTmp)->" + cCpoValor)
                __aTotDesp[VLRLIQNOBIM] += &("(cArqTmp)->" + cCpoValor)
            EndIf
            
            nVlLiqABi := &("(cArqTmp)->"+cCpoValor)
            __aTotDesp[VLRLIQATBIM] += &("(cArqTmp)->" + cCpoValor)
        EndIf

        //Alimentas valores de Funcao e SubFuncao
        For nX := 1 To 2
            If nX == 1 //Funcao
                cEntidd := SubStr((cArqTmp)->AKD_CO, __aTabFC[POSINI], __aTabFC[QTDDIG])
            Else //SubFuncao
                cEntidd := SubStr((cArqTmp)->AKD_CO, __aTabSB[POSINI], __aTabSB[QTDDIG])
            EndIf 

            If oHashDes:Get(cEntidd, @aLinAux)
                aLinAux[VLRDOTINI]   += nVlDotIni
                aLinAux[VLRDOTATU]   += nVlDotAtu
                aLinAux[VLREMPNOBIM] += nVlEmpNBi
                aLinAux[VLREMPATBIM] += nVlEmpABi
                aLinAux[VLRLIQNOBIM] += nVlLiqNBi
                aLinAux[VLRLIQATBIM] += nVlLiqABi
                HMSet(oHashDes, cEntidd, aLinAux)
            Else
                HMSet(oHashDes, cEntidd, {cEntidd,; 
                                            nVlDotIni,; 
                                            nVlDotAtu,;
                                            nVlEmpNBi,;
                                            nVlEmpABi,;
                                            nVlLiqNBi,; 
                                            nVlLiqABi,;
                                            nX})
            EndIf
        Next nX          
        
        (cArqTmp)->(dbSkip())  
    EndDo
    
    //Fecha arquivo temporario
    If Select("cArqTmp") > 0
        (cArqTmp)->(dbCloseArea()) 
    EndIf
Next nI

//Alimenta array de Despesas
HMList(oHashDes, @__aDespesas)
HMClean(oHashDes)
aSort(__aDespesas,,, {|x, y| x[1] < y[1]})

If Len(__aDespesas) > 0
    oReport:OnPageBreak({|| ImpCabec(oReport, oCabec1, oCabec2, aMoedas, nDivide)})

    //Inicializa componentes de impressao
    oDespesas:Init()

    //Imprime Total das Despesas no inicio
    __nFunOpc := 1
    oDespesas:PrintLine()
    
    //Imprime despesas
    __nFunOpc := 2

    For nX := 1 To Len(__aDespesas)
        __nPosDes := nX
        oDespesas:PrintLine()
    Next nX

    //Imprime Total Geral
    __nFunOpc := 3
    oReport:SkipLine()
    oDespesas:PrintLine()

    //Finaliza componentes de impressao
    oDespesas:Finish()
EndIf

//Limpa array e objetos
FreeObj(oHashDes)

aSize(__aDespesas, 0)
aSize(__aTotDesp , 0)
aSize(__aTabFC   , 0)
aSize(__aTabSB   , 0)
aSize(aLinAux    , 0)
aSize(aMoedas    , 0)

__aDespesas := Nil
__aTotDesp  := Nil
__aTabFC    := Nil
__aTabSB    := Nil
aLinAux     := Nil
aMoedas     := Nil

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Des_Desp()
Descricao de Classificacao da Despesas - Funcao e SubFuncao

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Des_Desp()

Local cRet    := ""
Local nPos    := 0
Local aTabAux := {}

If __nFunOpc == 1 //Total das Despesas
    cRet := STR0028 //"DESPESAS"
ElseIf __nFunOpc == 2 //Despesas
    If __aDespesas[__nPosDes][ITEHASH][TIPOENT] == 1 //Funcao
        aTabAux := aClone(__aTabFC)   
    ElseIf __aDespesas[__nPosDes][ITEHASH][TIPOENT] == 2 //SubFuncao
        aTabAux := aClone(__aTabSB)
    EndIf

    If (nPos := aScan(aTabAux[ITETAB], {|x| AllTrim(x[ITECHV]) == AllTrim(__aDespesas[__nPosDes][ITEHASH][CODDES])})) > 0
        cRet := AllTrim(aTabAux[ITETAB][nPos][ITEDES])
    EndIf
ElseIf __nFunOpc == 3 //Total Geral
    cRet := STR0029 //"TOTAL"
EndIf

//Limpa array
aSize(aTabAux, 0)
aTabAux := Nil
        
Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} Val_Desp()
Colunas Valores das Despesas

@author Totvs
   
@version P12
@since   21/10/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Val_Desp(nOpcVal)

Local nRet    := 0
Local nDotIni := 0

If __nFunOpc == 2 //Despesas
    nDotIni := IIF(__aDespesas[__nPosDes][ITEHASH][VLRDOTATU] > 0, __aDespesas[__nPosDes][ITEHASH][VLRDOTATU], __aDespesas[__nPosDes][ITEHASH][VLRDOTINI])

    Do Case
        Case nOpcVal == 1 //Dotacao Inicial
            nRet := __aDespesas[__nPosDes][ITEHASH][VLRDOTINI]
        Case nOpcVal == 2 //Dotacao Atualizada
            nRet := __aDespesas[__nPosDes][ITEHASH][VLRDOTATU]
        Case nOpcVal == 3 //Despesas Empenhadas no Bimestre
            nRet := __aDespesas[__nPosDes][ITEHASH][VLREMPNOBIM]
        Case nOpcVal == 4 //Despesas Empenhadas ate o Bimestre
            nRet := __aDespesas[__nPosDes][ITEHASH][VLREMPATBIM]
        Case nOpcVal == 5 //Saldo Despesas Empenhadas
            nRet := nDotIni - __aDespesas[__nPosDes][ITEHASH][VLREMPATBIM]
        Case nOpcVal == 6 //Despesas Liquidadas no Bimestre
            nRet := __aDespesas[__nPosDes][ITEHASH][VLRLIQNOBIM]
        Case nOpcVal == 7 //Despesas Liquidadas ate o Bimestre
            nRet := __aDespesas[__nPosDes][ITEHASH][VLRLIQATBIM]
        Case nOpcVal == 8 //Saldo Despesas Liquidadas
            nRet := nDotIni - __aDespesas[__nPosDes][ITEHASH][VLRLIQATBIM]
    EndCase
Else //Total das Despesas ou Total Geral
    nDotIni := IIF(__aTotDesp[VLRDOTATU] > 0, __aTotDesp[VLRDOTATU], __aTotDesp[VLRDOTINI])

    Do Case
        Case nOpcVal == 1 //Dotacao Inicial
            nRet := __aTotDesp[VLRDOTINI]
        Case nOpcVal == 2 //Dotacao Atualizada
            nRet := __aTotDesp[VLRDOTATU]
        Case nOpcVal == 3 //Despesas Empenhadas no Bimestre
            nRet := __aTotDesp[VLREMPNOBIM]
        Case nOpcVal == 4 //Despesas Empenhadas ate o Bimestre
            nRet := __aTotDesp[VLREMPATBIM]
        Case nOpcVal == 5 //Saldo Despesas Empenhadas
            nRet := nDotIni - __aTotDesp[VLREMPATBIM]
        Case nOpcVal == 6 //Despesas Liquidadas no Bimestre
            nRet := __aTotDesp[VLRLIQNOBIM]
        Case nOpcVal == 7 //Despesas Liquidadas ate o Bimestre
            nRet := __aTotDesp[VLRLIQATBIM]
        Case nOpcVal == 8 //Saldo Despesas Liquidadas
            nRet := nDotIni - __aTotDesp[VLRLIQATBIM]
    EndCase
EndIf

Return nRet  

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   21/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ImpCabec(oReport, oCabec1, oCabec2, aMoedas, nDivPor)

Local cUnidMoed := ""

//Imprime cabecalho
If ValType(aMoedas) == "A"
    If nDivPor == 2
        cUnidMoed := STR0016 //"Centena de "
    ElseIf nDivPor == 3
        cUnidMoed := STR0017 //"Milhares de "
    ElseIf nDivPor == 4
        cUnidMoed := STR0018 //"Milhoes de "
    EndIf

    //Inicializa componentes de impressao
    oCabec1:Init()
    oCabec2:Init()

    oCabec1:Cell("CABEC_1"):SetBlock({|| STR0014}) //"Demonstrativo da Execucao das Despesas por Funcao/SubFuncao"
    oCabec1:PrintLine()
    oCabec2:Cell("CABEC_2"):SetBlock({|| STR0019 + MV_PAR01 + "            (" + STR0020 + AllTrim(cUnidMoed) + ": " + AllTrim(aMoedas[3]) +  ")"})  //"Exercício: " #"Valores expressos em " 
    oCabec2:PrintLine()
    oReport:ThinLine()
    oReport:SkipLine()

    //Finaliza componentes de impressao
    oCabec1:Finish()
    oCabec2:Finish()
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} CargaTab
Carrega tabela / radical informado e retorna um array aTab

Estrutura aTab: 
Elemento 1 - Codigo da Tabela                        [CODTAB]
Elemento 2 - Descricao da Tabela                     [DESTAB]
Elemento 3 - Campo Tab.Movimentos                    [CPOMOV]
Elemento 4 - Pos.Inicial no Campo                    [POSINI]
Elemento 5 - Quantidade de digitos                   [QTDDIG]
Elemento 6 - SubArray com seguinte Estrutura         [ITETAB]
              [6][n][1] - Chave                         [ITECHV]
              [6][n][2] - Descricao                     [ITEDES]

@author Totvs
   
@version P12
@since   21/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function CargaTab(cTabela, cRadical)

Local aTab     := {}
Local aArea    := {}
Local aAreaA1G := {}
Local aAreaA1H := {}

Default cTabela  := ""
Default cRadical := ""

/*
Local aTab := {}
Estrutura aTab: 
Elemento 1 - Codigo da Tabela                        [CODTAB]
Elemento 2 - Descricao da Tabela                     [DESTAB]
Elemento 3 - Campo Tab.Movimentos                    [CPOMOV]
Elemento 4 - Pos.Inicial no Campo                    [POSINI]
Elemento 5 - Quantidade de digitos                   [QTDDIG]
Elemento 6 - SubArray com seguinte Estrutura         [ITETAB]
              [6][1] - Chave                         [ITECHV]
              [6][2] - Descricao                     [ITEDES]
*/

If !Empty(cTabela) .And. !Empty(cRadical)
    aArea   := GetArea()
    aAreaA1G := A1G->(GetArea())
    aAreaA1H := A1H->(GetArea())
    cTabela := PadR( cTabela, Len(A1G->A1G_CODTAB) )
    cRadical := PadR( cRadical, Len(A1H->A1H_RADCHV) )

    A1G->(dbSetOrder(1)) //A1G_FILIAL+A1G_CODTAB
    A1H->(dbSetOrder(2)) //A1H_FILIAL+A1H_CODTAB+A1H_RADCHV+A1H_ITECHV

    If A1G->( dbSeek( xFilial("A1G")+cTabela ) ) 
        aTab := Array(6)  //6 ELEMENTOS
        aTab[CODTAB] := A1G->A1G_CODTAB
        aTab[DESTAB] := A1G->A1G_DESTAB
        aTab[CPOMOV] := A1G->A1G_CAMPO     
        aTab[POSINI] := A1G->A1G_INICPO
        aTab[QTDDIG] := A1G->A1G_DIGCPO
        aTab[ITETAB] := {}  

        If A1H->(dbSeek(xFilial("A1H")+cTabela)) 
            While A1H->( !EOF() .And. A1H_FILIAL == xFilial("A1H") .And. A1H_CODTAB == cTabela .And. A1H_RADCHV == cRadical )
                aAdd( aTab[ITETAB], Array(2) ) //2 ELEMENTOS NO SUB ARRAY ITECHV DESCHV
            
                aTab[ITETAB][Len(aTab[ITETAB])][ITECHV] := A1H->A1H_ITECHV
                aTab[ITETAB][Len(aTab[ITETAB])][ITEDES] := A1H->A1H_CHVCNT

                A1H->( dbSkip() ) 
            EndDo
        EndIf
    EndIf

    RestArea(aAreaA1H)
    RestArea(aAreaA1G)
    RestArea(aArea)
EndIf

Return(aTab)

//-------------------------------------------------------------------
/*{Protheus.doc} CTB083Bim
Alimenta opcoes da pergunta Bimestre (MV_PAR02) do relatorio

@author Totvs
   
@version P12
@since   21/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CTB083Bim()

Local cTitulo    := STR0021 //"Bimestres"
Local cMvParDef  := "123456"
Local cMvPar     := "" //Retorno da funcao f_Opcoes
Local cMvRet     := AllTrim(ReadVar()) //Pergunta sendo tratada
Local cValBkp    := &(ReadVar()) //Backup do valor inicial da pergunta
Local lRet       := .T.
Local aBimestres := {STR0022,; //"Primeiro Bimestre"
                     STR0023,; //"Segundo Bimestre"
                     STR0024,; //"Terceiro Bimestre" 
                     STR0025,; //"Quarto Bimestre"
                     STR0026,; //"Quinto Bimestre"
                     STR0027}  //"Sexto Bimestre" 

//Chama funcao com opcoes da pergunta
If f_Opcoes(@cMvPar, cTitulo, aBimestres, cMvParDef, 12, 49, .F.) 
    &(cMvRet) := AllTrim(StrTran(cMvPar, "*", ""))
ElseIf !Empty(cValBkp) .And. cValBkp $ cMvParDef
    &(cMvRet) := cValBkp
Else
    lRet := .F.
EndIf                                     

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} CTB083IsBim
Verifica se Mes da data pertence ao Bimestre escolhido na pergunta-SX1

@author Totvs
   
@version P12
@since   21/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function CTB083IsBim(cBimestre, dDataAtu)

Local cMeses := ""
Local lRet   := .F.

//Armazena meses do bimestre selecionado na Pergunta-SX1
Do Case
    Case cBimestre == "1"
        cMeses := "Janeiro|Fevereiro"
    Case cBimestre == "2"
        cMeses := "Marco|Abril"
    Case cBimestre == "3"
        cMeses := "Maio|Junho"
    Case cBimestre == "4"
        cMeses := "Julho|Agosto"
    Case cBimestre == "5"
        cMeses := "Setembro|Outubro"
    Case cBimestre == "6"
        cMeses := "Novembro|Dezembro"
EndCase

//Verifica se mes passado na data pertence ao Bimestre escolhido na Pergunta-SX1
lRet := Upper(MesExtenso(Month(dDataAtu))) $ Upper(cMeses)

Return lRet