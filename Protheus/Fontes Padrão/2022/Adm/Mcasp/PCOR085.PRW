#Include "PCOR085.CH"
#Include "PROTHEUS.CH"

#DEFINE CODTAB 1
#DEFINE DESTAB 2
#DEFINE CPOMOV 3
#DEFINE POSINI 4
#DEFINE QTDDIG 5
#DEFINE ITETAB 6
#DEFINE ITECHV 1
#DEFINE ITEDES 2

#DEFINE TAMDESCRI 60
#DEFINE ITEHASH   2

#DEFINE COD_ENT  1
#DEFINE DESC_ENT 2
#DEFINE VLR_PREV 3
#DEFINE VLR_DOT  3
#DEFINE VLR_REAL 4
#DEFINE VLR_EMP  4
#DEFINE VLR_LIQ  5
#DEFINE VLR_PAG  6

Static __nItemEnt  := 0
Static __aReceitas := {}
Static __aDespesas := {}

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR085
Relatorio Demonstrativo da Receita com Alienacao de Ativos e Aplicacao 
de Recursos

@author Totvs
   
@version P12
@since   09/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR085()

Local oReport  := Nil
Local cPerg    := Padr("PCOR085", Len(SX1->X1_GRUPO))

//=================================================================================================================================================
// MV_PAR01    Exercício:   
// MV_PAR02    Bimestre: 
// MV_PAR03    Aglut. Previsao Atualizada:
// MV_PAR04    Aglut. Receitas Realizadas:
// MV_PAR05    Aglut. Dotacao Atualizada:
// MV_PAR06    Aglut. Despesas Empenhadas:
// MV_PAR07    Aglut. Despesas Liquidadas:
// MV_PAR08    Aglut. Despesas Pagas:
// MV_PAR09    Moeda:
// MV_PAR10    Divide Por:         					                    
//=================================================================================================================================================
SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstrativo da Receita com Alienacao de Ativos e Aplicacao de Recursos disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilizacao do Relatorio Demonstrativo da Receita com Alienacao de Ativos e Aplicacao de Recursos é necessário aplicar o pacote acumulado da controladoria."      
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__nItemEnt  := 0
__aReceitas := {}
__aDespesas := {}

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   09/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oReceitas, oDespesas, oBorder
Local cNomeProg := "PCOR085"
Local cTitulo   := Capital(STR0003) //"Relatorio Demonstrativo da Receita com Alienacao de Ativos e Aplicacao de Recursos"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatorio Demonstrativo da Receita com Alienacao de Ativos e Aplicacao de Recursos."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 6 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, "EXERCICIO", {}, /*aOrdem*/)
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho

//Criacao da Secao Receitas
oReceitas := TRSection():New(oReport, "RECEITAS", {"cArqTmp"},, .F., .F.)

//Colunas referentes as Receitas
TRCell():New(oReceitas, "DESCRICAO",, STR0005                  /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TAMDESCRI               /*Tamanho*/, /*lPixel*/, {|| Desc_Clas("R")}   /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 3) //"Receitas"
TRCell():New(oReceitas, "PREATU"   ,, STR0006 + CRLF + STR0007 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] + 5/*Tamanho*/, /*lPixel*/, {|| Val_Enti("R", 1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Previsao" #"Atualizada"
TRCell():New(oReceitas, "RECREA"   ,, STR0005 + CRLF + STR0008 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] + 5/*Tamanho*/, /*lPixel*/, {|| Val_Enti("R", 2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Receitas" #"Realizadas"
TRCell():New(oReceitas, "SALDO_REA",, STR0009 + CRLF + STR0010 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] + 5/*Tamanho*/, /*lPixel*/, {|| Val_Enti("R", 3)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Saldo" #"a Realizar"
oReceitas:SetLinesBefore(0)

//Criacao da Secao Despesas
oDespesas := TRSection():New(oReport, "DESPESAS", {"cArqTmp"},, .F., .F.)

//Colunas referentes as Despesas
TRCell():New(oDespesas, "DESCRICAO",, STR0011                  /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TAMDESCRI               /*Tamanho*/, /*lPixel*/, {|| Desc_Clas("D")}   /*CodeBlock*/, "LEFT" , .T., "LEFT" ,, 3) //"Despesas"
TRCell():New(oDespesas, "DOTATU"   ,, STR0012 + CRLF + STR0007 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] + 5 /*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Dotacao"  #"Atualizada"
TRCell():New(oDespesas, "DESEMP"   ,, STR0011 + CRLF + STR0014 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] + 5/*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Receitas" #"Realizadas"
TRCell():New(oDespesas, "DESLIQ"   ,, STR0011 + CRLF + STR0015 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] + 5/*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 3)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Despesas" #"Liquidadas"
TRCell():New(oDespesas, "DESPAG"   ,, STR0011 + CRLF + STR0016 /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] + 5/*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 4)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Despesas" #"Pagas"
TRCell():New(oDespesas, "SALDO"    ,, STR0009                  /*Titulo*/, "@E 999,999,999,999,999.99"  , TamSx3("AKD_VALOR1")[1] + 5/*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 5)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     //"Saldo"
oReceitas:SetLinesBefore(0)

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   09/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec    := oReport:Section("EXERCICIO")
Local oReceitas := oReport:Section("RECEITAS") 
Local oDespesas := oReport:Section("DESPESAS")
Local cExerc    := MV_PAR01
Local cBimestre := MV_PAR02
Local cMoeda    := MV_PAR09
Local cTitulo   := STR0017 //"Demonstrativo da Receita com Alienacao de Ativos e Aplicacao de Recursos"
Local nDivide   := 1
Local nI        := 0
Local dDataIni  := CToD("  /  /    ")
Local dDataFim  := CToD("  /  /    ")
Local aTabCat   := CargaTab("CE"/*cTabela*/, "CE"/*cRadical*/) //Funcao
Local aTabOri   := CargaTab("O2"/*cTabela*/, "C" /*cRadical*/) //Origem Capital
Local aTabEsp   := CargaTab("E1"/*cTabela*/, "E1"/*cRadical*/) //Especie
Local aTabDes   := CargaTab("DR"/*cTabela*/, "DR"/*cRadical*/) //Desdobramento
Local aTabDE    := CargaTab("DE"/*cTabela*/, "DE"/*cRadical*/) //Categoria Economica da Despesa
Local aTabGD    := CargaTab("GD"/*cTabela*/, "GD"/*cRadical*/) //Grupo da Despesa
Local aMoedas   := CtbMoeda(cMoeda)

//Divide por
If MV_PAR10 == 2     //Divide por cem
	nDivide := 100
ElseIf MV_PAR10 == 3 //Divide por mil
	nDivide := 1000
ElseIf MV_PAR10 == 4 //Divide por milhao
	nDivide := 1000000
EndIf

//Armazena Data Final
If cBimestre == "1"
    dDataIni := SToD(cExerc + "0101")
    dDataFim := LastDay(SToD(cExerc + "0201"))
ElseIf cBimestre == "2"
    dDataIni := SToD(cExerc + "0301")
    dDataFim := LastDay(SToD(cExerc + "0401"))
ElseIf cBimestre == "3"
    dDataIni := SToD(cExerc + "0501")
    dDataFim := LastDay(SToD(cExerc + "0601"))
ElseIf cBimestre == "4"
    dDataIni := SToD(cExerc + "0701")
    dDataFim := LastDay(SToD(cExerc + "0801"))
ElseIf cBimestre == "5"
    dDataIni := SToD(cExerc + "0901")
    dDataFim := LastDay(SToD(cExerc + "1001"))
ElseIf cBimestre == "6"
    dDataIni := SToD(cExerc + "1101")
    dDataFim := LastDay(SToD(cExerc + "1201"))
EndIf

//Armazena Receitas
Pco085Rec(cExerc, cBimestre, cMoeda, cTitulo, nDivide, dDataIni,; 
            dDataFim, aMoedas, aTabCat, aTabOri, aTabEsp, aTabDes)

//Armazena Despesas
Pco085Des(cExerc, cBimestre, cMoeda, cTitulo, nDivide, dDataIni,; 
            dDataFim, aMoedas, aTabDE, aTabGD)


If Len(__aReceitas) > 0  .And. Len(__aDespesas) > 0
    oReport:OnPageBreak({|| ImpCabec(oReport, oCabec, aMoedas)})

    //Imprime Receitas
    oReceitas:Init()
    
    For nI := 1 To Len(__aReceitas) 
        If oReport:Cancel()
            Exit
        EndIf
        
        __nItemEnt := nI
        oReceitas:PrintLine()
    Next nI
    
    oReport:ThinLine()
    oReport:SkipLine()
    oReceitas:Finish()

    //Imprime Despesas
    oDespesas:Init()

     For nI := 1 To Len(__aDespesas) 
        If oReport:Cancel()
            Exit
        EndIf

        __nItemEnt := nI
        oDespesas:PrintLine()
     Next nI

     oDespesas:Finish()
EndIf

//Limpa array e objetos
aSize(__aReceitas, 0)
aSize(__aDespesas, 0)
aSize(aTabCat    , 0)
aSize(aTabOri    , 0)
aSize(aTabEsp    , 0)
aSize(aTabDes    , 0)
aSize(aMoedas    , 0)

__aReceitas := Nil
__aDespesas := Nil
aTabCat     := Nil
aTabOri     := Nil
aTabEsp     := Nil
aTabDes     := Nil
aMoedas     := Nil

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Pco085Rec
Imprime as Receitas do Demonstrativo

@author Totvs
   
@version P12
@since   09/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco085Rec(cExerc, cBimestre, cMoeda, cTitulo, nDivide, dDataIni,; 
                            dDataFim, aMoedas, aTabCat, aTabOri, aTabEsp, aTabDes)

Local cArqTmp   := ""
Local cCodAgl   := ""
Local cNomReal  := ""
Local cCateg    := ""
Local cOrigem   := ""
Local cEspeci   := ""
Local cDesdob   := ""
Local cChvEnti  := ""
Local cCpoValor := "AKD_VALOR" + CValToChar(Val(cMoeda))
Local nPos      := 0
Local nI        := 0
Local aLinAux   := {}
Local oHashRec  := HMNew()

/* Estrutura Receitas :

1 – Categoria Econômica: (1 dígito) – Portaria 387/2019
2 – Origem: (1 dígito) – Portaria 387/2019
3 – Espécie: (1 dígito) – Portaria 387/2019
4 – Desdobramento para identificação de peculiaridades da receita: (4 dígitos) – Portaria 387/2019
5 – Tipo: (1 dígito) – Portaria 387/2019
6 - Fonte de Recurso (2 - digitos)- Específico(Adicionado após)
7 - Código de Aplicação (4 - digitos) - Específico(Adicionado após)           
*/

For nI := 1 To 2
    cArqTmp  := GetNextAlias()
    
    //Armazena Codigo Aglutinadora de Visoes
    If nI == 1
        cCodAgl := MV_PAR03 //Previsao Atualizada
    Else
        cCodAgl := MV_PAR04 //Receitas Realizadas
    EndIf 
    
    //Monta Arquivo Temporario para Impressao
    MsgMeter({|oMeter, oText, oDlg, lEnd|;
                cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, cMoeda, .T., cCodAgl,;
                                        dDataIni, dDataFim, Nil, Nil, nDivide)}, STR0018, cTitulo) //"Criando Arquivo Temporario..."

    //Todo o arquivo 
    While (cArqTmp)->(!Eof())
        //Alimenta Entidades de Receitas
        cCateg   := SubStr((cArqTmp)->AKD_CO, aTabCat[POSINI], aTabCat[QTDDIG])
        cOrigem  := SubStr((cArqTmp)->AKD_CO, aTabOri[POSINI], aTabOri[QTDDIG])     
        cEspeci  := SubStr((cArqTmp)->AKD_CO, aTabEsp[POSINI], aTabEsp[QTDDIG]) 
        cDesdob  := cCateg + cOrigem + cEspeci + SubStr((cArqTmp)->AKD_CO, aTabDes[POSINI], aTabDes[QTDDIG]) + "0"

        //Alimenta valores Previsao Atualizada e Receitas Realizadas
        If nI == 1
            nVlrPrev := (cArqTmp)->&(cCpoValor)
            nVlrReal := 0
        Else
            nVlrReal := (cArqTmp)->&(cCpoValor)
            nVlrPrev := 0
        EndIf
            
        //Adiciona Receitas por Origem
        cChvEnti := cCateg + cOrigem

        If oHashRec:Get(cChvEnti, @aLinAux)
            aLinAux[VLR_PREV] += nVlrPrev
            aLinAux[VLR_REAL] += nVlrReal
            HMSet(oHashRec, cChvEnti, aLinAux)
        Else
            If (nPos := aScan(aTabOri[ITETAB], {|x| AllTrim(x[1]) == AllTrim(cOrigem)})) > 0
                HMSet(oHashRec, cChvEnti, {cOrigem,; 
                                            aTabOri[ITETAB][nPos][ITEDES],;
                                            nVlrPrev,; 
                                            nVlrReal})
            EndIf
        EndIf
            
        //Adiciona Receitas por Desdobramento - Nivel 2
        cChvEnti := cDesdob
        
        If oHashRec:Get(cChvEnti, @aLinAux)
            aLinAux[VLR_PREV] += nVlrPrev
            aLinAux[VLR_REAL] += nVlrReal
            HMSet(oHashRec, cChvEnti, aLinAux)
        Else
            If (nPos := aScan(aTabDes[ITETAB], {|x| AllTrim(x[1]) == AllTrim(cDesdob)})) > 0
                HMSet(oHashRec, cChvEnti, {cDesdob,; 
                                            aTabDes[ITETAB][nPos][ITEDES],;
                                            nVlrPrev,; 
                                            nVlrReal})
            EndIf
        EndIf

        (cArqTmp)->(dbSkip())
    EndDo

    //Fecha arquivo temporario
    If Select("cArqTmp") > 0
        (cArqTmp)->(dbCloseArea()) 
    EndIf
Next nI

//Armazena movimentos
HMList(oHashRec, __aReceitas)
HMClean(oHashRec)
aSort(__aReceitas,,, {|x, y| x[1] < y[1]})

//Limpa objeto
FreeObj(oHashRec)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Pco085Rec
Imprime as Receitas do Demonstrativo

@author Totvs
   
@version P12
@since   09/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco085Des(cExerc, cBimestre, cMoeda, cTitulo, nDivide, dDataIni,; 
                            dDataFim, aMoedas, aTabDE, aTabGD)

Local cArqTmp   := ""
Local cCodAgl   := ""
Local cNomReal  := ""
Local cCateg    := ""
Local cGrupo    := ""
Local cChvEnti  := ""
Local cCpoValor := "AKD_VALOR" + CValToChar(Val(cMoeda))
Local nI        := 0
Local nVlrDot   := 0
Local nVlrEmp   := 0
Local nVlrLiq   := 0
Local nVlrPag   := 0
Local aLinAux   := {}
Local oHashDes  := HMNew()

/* Estrutura Despesas :
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
Tabela DE-DE - Categ. Economica da Despesa
Tabela GD-GD - Grupo da Despesas
*/

For nI := 1 To 4
    cArqTmp  := GetNextAlias()
    
    //Armazena Codigo Aglutinadora de Visoes
    If nI == 1
        cCodAgl := MV_PAR05 //Dotacao Atualizada
    ElseIf nI == 2
        cCodAgl := MV_PAR06 //Despesas Empenhadas
    ElseIf nI == 3
        cCodAgl := MV_PAR07 //Despesas Liquidadas
    ElseIf nI == 4
        cCodAgl := MV_PAR08 //Despesas Pagas
    EndIf 
    
    //Monta Arquivo Temporario para Impressao
    MsgMeter({|oMeter, oText, oDlg, lEnd|;
                cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, cMoeda, .T., cCodAgl,;
                                        dDataIni, dDataFim, Nil, Nil, nDivide)}, STR0018, cTitulo) //"Criando Arquivo Temporario..."

    //Todo o arquivo 
    While (cArqTmp)->(!Eof())
        //Alimenta Entidades de Despesas
        cCateg := SubStr((cArqTmp)->AKD_CO, aTabDE[POSINI], aTabDE[QTDDIG])
        cGrupo := SubStr((cArqTmp)->AKD_CO, aTabGD[POSINI], aTabGD[QTDDIG])

        //Alimenta valores Dotacao Atualizada, Despesas Empenhadas, Despesas Liquidadas e Depesas Pagas
        If nI == 1
            nVlrDot := (cArqTmp)->&(cCpoValor)
            nVlrEmp := 0
            nVlrLiq := 0
            nVlrPag := 0
        ElseIf nI == 2
            nVlrDot := 0
            nVlrEmp := (cArqTmp)->&(cCpoValor)
            nVlrLiq := 0
            nVlrPag := 0
        ElseIf nI == 3
            nVlrDot := 0
            nVlrEmp := 0
            nVlrLiq := (cArqTmp)->&(cCpoValor)
            nVlrPag := 0
        ElseIf nI == 4
            nVlrDot := 0
            nVlrEmp := 0
            nVlrLiq := 0
            nVlrPag := (cArqTmp)->&(cCpoValor)
        EndIf

        //Adiciona Despesas por Categoria Economica
        cChvEnti := cCateg

        If oHashDes:Get(cChvEnti, @aLinAux)
            aLinAux[VLR_DOT] += nVlrDot
            aLinAux[VLR_EMP] += nVlrEmp
            aLinAux[VLR_LIQ] += nVlrLiq
            aLinAux[VLR_PAG] += nVlrPag
            HMSet(oHashDes, cChvEnti, aLinAux)
        Else
            If (nPos := aScan(aTabDE[ITETAB], {|x| AllTrim(x[1]) == AllTrim(cCateg)})) > 0
                HMSet(oHashDes, cChvEnti, {cCateg,; 
                                            aTabDE[ITETAB][nPos][ITEDES],;
                                            nVlrDot,; 
                                            nVlrEmp,;
                                            nVlrLiq,;
                                            nVlrPag})
            EndIf
        EndIf  

        //Adiciona Despesas por Grupo de Despesa
        cChvEnti := cCateg + cGrupo

        If oHashDes:Get(cChvEnti, @aLinAux)
            aLinAux[VLR_DOT] += nVlrDot
            aLinAux[VLR_EMP] += nVlrEmp
            aLinAux[VLR_LIQ] += nVlrLiq
            aLinAux[VLR_PAG] += nVlrPag
            HMSet(oHashDes, cChvEnti, aLinAux)
        Else
            If (nPos := aScan(aTabGD[ITETAB], {|x| AllTrim(x[1]) == AllTrim(cGrupo)})) > 0
                HMSet(oHashDes, cChvEnti, {cGrupo,; 
                                            aTabGD[ITETAB][nPos][ITEDES],;
                                            nVlrDot,; 
                                            nVlrEmp,;
                                            nVlrLiq,;
                                            nVlrPag})
            EndIf
        EndIf

        (cArqTmp)->(dbSkip())
    EndDo

    //Fecha arquivo temporario
    If Select("cArqTmp") > 0
        (cArqTmp)->(dbCloseArea()) 
    EndIf
Next nI

//Armazena movimentos
HMList(oHashDes, __aDespesas)
HMClean(oHashDes)
aSort(__aDespesas,,, {|x, y| x[1] < y[1]})

//Limpa objeto
FreeObj(oHashDes)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Desc_Clas()
Descricao do Classificador Receita\Despesa

cTipo:
    R = Receitas
    D = Despesas

@author Totvs
   
@version P12
@since   09/11/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Desc_Clas(cTipo)

Local cDesc := ""

If Upper(cTipo) == "R" //Receitas
    cDesc := __aReceitas[__nItemEnt][ITEHASH][DESC_ENT]
ElseIf Upper(cTipo) == "D" //Despesas
    cDesc := __aDespesas[__nItemEnt][ITEHASH][DESC_ENT]  
EndIf

Return cDesc

//-------------------------------------------------------------------
/*{Protheus.doc} Val_Enti(cTipo, nEnti)

Valores das Entidades (Receitas e Despesas)

cTipo:
    R = Receitas
    D = Despesas

nEnti: 
    Receitas
    1 - Previsao Atualizada
    2 - Receitas Realizadas
    3 - Saldo a Realizar

    Despesas
    1 - Dotacao Atualizada
    2 - Despesas Empenhadas
    3 - Despesas Liquidadas
    4 - Despesas Pagas
    5 - Saldo

@author Totvs
   
@version P12
@since   09/11/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Val_Enti(cTipo, nEnti)

Local nValor := 0  

If Upper(cTipo) == "R" //Receitas
    If nEnti == 1
        nValor := __aReceitas[__nItemEnt][ITEHASH][VLR_PREV]
    ElseIf nEnti == 2
        nValor := __aReceitas[__nItemEnt][ITEHASH][VLR_REAL]
    ElseIf nEnti == 3
        nValor := __aReceitas[__nItemEnt][ITEHASH][VLR_PREV] - __aReceitas[__nItemEnt][ITEHASH][VLR_REAL]
    EndIf
ElseIf Upper(cTipo) == "D" //Despesas
    If nEnti == 1
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_DOT]
    ElseIf nEnti == 2
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_EMP]
    ElseIf nEnti == 3
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_LIQ]
    ElseIf nEnti == 4
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_PAG]
    ElseIf nEnti == 5
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_DOT] - __aDespesas[__nItemEnt][ITEHASH][VLR_EMP]
    EndIf
EndIf

Return nValor  

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   09/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ImpCabec(oReport, oCabec, aMoedas, dDataFim)

Local cUnidMoed := ""
Local cExerc    := MV_PAR01
Local cBimestre := MV_PAR02

If MV_PAR10 == 2
    cUnidMoed := STR0019  //Centena de 
ElseIf MV_PAR10 == 3
    cUnidMoed := STR0020 //Milhares de 
ElseIf MV_PAR10 == 4
    cUnidMoed := STR0021  //Milhoes de
EndIf

//Imprime cabecalho
If ValType(aMoedas) == "A"
    oCabec:Init()
    oCabec:Cell("EXERCICIO"):SetBlock({|| STR0022 + AllTrim(cExerc) + "            ("+ STR0023 + cUnidMoed + " : " + AllTrim(aMoedas[3]) +  ")"}) //"Exercicio : " #"em " 
    oCabec:PrintLine()
    oCabec:Cell("EXERCICIO"):SetBlock({|| STR0024 + STR0025}) //"Periodicidade : " "Bimestral"
    oCabec:PrintLine()
    oCabec:Cell("EXERCICIO"):SetBlock({|| STR0026 + AllTrim(cBimestre) + " " + STR0027}) //"Periodo :" "Bimestre"
    oCabec:PrintLine()
    oCabec:Finish()

    //Pula linha
    oReport:SkipLine()
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
@since   09/11/2020
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

If !Empty(cTabela) .And. !Empty(cRadical)
    aArea    := GetArea()
    aAreaA1G := A1G->(GetArea())
    aAreaA1H := A1H->(GetArea())
    cTabela  := PadR(cTabela, Len(A1G->A1G_CODTAB))
    cRadical := PadR(cRadical, Len(A1H->A1H_RADCHV))

    A1G->(dbSetOrder(1)) //A1G_FILIAL+A1G_CODTAB
    A1H->(dbSetOrder(2)) //A1H_FILIAL+A1H_CODTAB+A1H_RADCHV+A1H_ITECHV

    If A1G->(dbSeek(xFilial("A1G") + cTabela)) 
        aTab := Array(6)  //6 ELEMENTOS
        aTab[CODTAB] := A1G->A1G_CODTAB
        aTab[DESTAB] := A1G->A1G_DESTAB
        aTab[CPOMOV] := A1G->A1G_CAMPO     
        aTab[POSINI] := A1G->A1G_INICPO
        aTab[QTDDIG] := A1G->A1G_DIGCPO
        aTab[ITETAB] := {}  

        If A1H->(dbSeek(xFilial("A1H")+cTabela)) 
            While A1H->(!EOF() .And. A1H->A1H_FILIAL == xFilial("A1H") .And. A1H->A1H_CODTAB == cTabela .And. A1H->A1H_RADCHV == cRadical)     
                aAdd(aTab[ITETAB], Array(2)) //2 ELEMENTOS NO SUB ARRAY ITECHV DESCHV
            
                aTab[ITETAB][Len(aTab[ITETAB])][ITECHV] := A1H->A1H_ITECHV
                aTab[ITETAB][Len(aTab[ITETAB])][ITEDES] := A1H->A1H_CHVCNT

                A1H->(dbSkip()) 
            EndDo
        EndIf
    EndIf

    RestArea(aAreaA1H)
    RestArea(aAreaA1G)
    RestArea(aArea) 
EndIf

Return(aTab)