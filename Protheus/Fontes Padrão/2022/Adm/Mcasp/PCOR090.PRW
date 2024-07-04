#Include "PCOR090.CH"
#Include "PROTHEUS.CH"

#DEFINE SINTE1 1
#DEFINE SINTE2 2
#DEFINE SINTE3 3
#DEFINE SINTE4 4
#DEFINE ANALIT 5

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

#DEFINE IND_CTA    1
#DEFINE DESC_CTA   2
#DEFINE VLR_PREINI 3
#DEFINE VLR_PREATU 4
#DEFINE VLR_REAL   5

#DEFINE VLR_DOTINI  3
#DEFINE VLR_DOTATU  4
#DEFINE VLR_EMP     5
#DEFINE VLR_LIQ     6

#DEFINE VLR_ANT 3
#DEFINE VLR_ATU 4

Static __nItemEnt   := 0
Static __aReceitas  := {}
Static __aDespesas  := {}
Static __aPlanoPrev := {}

//-------------------------------------------------------------------
/*{Protheus.doc} PCOR090
Relatorio Demonstrativo de Receitas e Despesas Previdenciarias

@author Totvs
   
@version P12
@since   02/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function PCOR090()

Local oReport := Nil
Local cPerg   := Padr("PCOR090", Len(SX1->X1_GRUPO))

//=================================================================================================================================================
// MV_PAR01    Exercício:   
// MV_PAR02    Bimestre: 
// MV_PAR03    Aglut. Previsao Inicial:
// MV_PAR04    Aglut. Previsao Atualizada:
// MV_PAR05    Aglut. Receitas Realizadas:
// MV_PAR06    Aglut. Dotacao Inicial:
// MV_PAR07    Aglut. Dotacao Atualizada:
// MV_PAR08    Aglut. Despesas Empenhadas:
// MV_PAR09    Aglut. Despesas Liquidadas:
// MV_PAR10    Cod. Config. Livros:
// MV_PAR11    Tipo de Saldo:
// MV_PAR12    Saldos Zerados:
// MV_PAR13    Moeda:
// MV_PAR14    Divide Por:         					                    
//=================================================================================================================================================

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.025"
    Help(,, "VER_RELEASE",, OemToAnsi(STR0001), 1, 0) //"Relatório Demonstrativo de Receitas e Despesas Previdenciarias disponí­vel a partir da versao 12.1.31"
ElseIf !SX1->(dbSeek(cPerg))
    Help(,, "NO_PERG",, OemToAnsi(STR0002), 1, 0) //"Para utilizacao do Relatorio Demonstrativo de Receitas e Despesas Previdenciarias é necessário aplicar o pacote acumulado da controladoria."      
Else                 
    oReport := ReportDef(cPerg)

    If ValType(oReport) == "O"    
        oReport:PrintDialog()
    EndIf

    oReport := Nil    
EndIf
	
//CLEAR VAR STATIC
__nItemEnt   := 0
__aReceitas  := {}
__aDespesas  := {}
__aPlanoPrev := {}

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   02/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)

Local oReport, oCabec, oReceitas, oDespesas, oPlanoPrev, oBorder
Local cNomeProg := "PCOR090"
Local cTitulo   := Capital(STR0003)   //"Relatorio Demonstrativo das Receitas e Despesas Previdenciarias"
Local cDescri 	:= OemToAnsi(STR0004) //"Este programa irá imprimir o Relatorio Demonstrativo das Receitas e Despesas Previdenciarias."

//Criacao do componente de impressao
oReport := TReport():New(cNomeProg, cTitulo, cPerg,; 
                                  {|oReport| Pergunte(cPerg, .F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, cDescri)

oReport:nFontBody := 7 //Define o tamanho da fonte

oBorder := TRBorder():New(oReport, 5,, 0)

//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, "EXERCICIO", {}, /*aOrdem*/)
TRCell():New(oCabec, "EXERCICIO",, "",, 80, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho

//Criacao da Secao Receitas
oReceitas := TRSection():New(oReport, "RECEITAS", {"cArqTmp"},, .F., .F.)

//Colunas das Receitas
TRCell():New(oReceitas, "DESCRICAO",, STR0005                    /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TAMDESCRI               /*Tamanho*/, /*lPixel*/, {|| Desc_Clas("R")}   /*CodeBlock*/, "LEFT" , .T., "LEFT",, 3) //"Receitas Previdenciarias do RPPS"
TRCell():New(oReceitas, "PREINI"   ,, STR0006 + CRLF + STR0007   /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("R", 1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Previsao" #"Inicial"
TRCell():New(oReceitas, "PREATU"   ,, STR0006 + CRLF + STR0008   /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("R", 2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Previsao" #"Atualizada"
TRCell():New(oReceitas, "RECREA"   ,, STR0009 + CRLF + STR0010   /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("R", 3)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Receitas" #"Realizadas"
oReceitas:SetLinesBefore(0)

//Criacao da Secao Despesas
oDespesas := TRSection():New(oReport, "DESPESAS", {"cArqTmp"},, .F., .F.)

//Colunas das Despesas
TRCell():New(oDespesas, "DESCRICAO",, STR0012                                   /*Titulo*/, PesqPict("A1H", "A1H_CHVCNT"), TAMDESCRI               /*Tamanho*/, /*lPixel*/, {|| Desc_Clas("D")}   /*CodeBlock*/, "LEFT" , .T., "LEFT",, 3) //"Despesas Previdenciarias do RPPS"
TRCell():New(oDespesas, "DOTINI"   ,, STR0011 + CRLF + STR0007                  /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Dotacao"  #"Inicial"
TRCell():New(oDespesas, "DOTATU"   ,, STR0011 + CRLF + STR0008                  /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Dotacao"  #"Atualizada"
TRCell():New(oDespesas, "DESEMP"   ,, STR0013 + CRLF + STR0014 + CRLF + STR0016 /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 3)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Despesas" #"Empenhadas" ##"Ate o Bimestre"
TRCell():New(oDespesas, "DESLIQ"   ,, STR0013 + CRLF + STR0015 + CRLF + STR0016 /*Titulo*/, PesqPict("AKD", "AKD_VALOR1"), TamSx3("AKD_VALOR1")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("D", 4)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Despesas" #"Liquidadas" ##"Ate o Bimestre"
oDespesas:SetLinesBefore(0)

//Criacao da Secao Plano Previdenciario
oPlanoPrev := TRSection():New(oReport, "PLANOPREV", {"cArqTmp"},, .F., .F.)

//Colunas do Plano Previdenciario
TRCell():New(oPlanoPrev, "DESCRICAO",, STR0017 /*Titulo*/, PesqPict("CTS", "CTS_DESCCG"), TAMDESCRI              /*Tamanho*/, /*lPixel*/, {|| Desc_Clas("P")}   /*CodeBlock*/, "LEFT" , .T., "LEFT",, 3) //"Bens e Direitos do RPPS - Plano Previdenciario"
TRCell():New(oPlanoPrev, "VAL_ANT"  ,, ""      /*Titulo*/, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("P", 1)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     
TRCell():New(oPlanoPrev, "VAL_ATU"  ,, ""      /*Titulo*/, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1] /*Tamanho*/, /*lPixel*/, {|| Val_Enti("P", 2)} /*CodeBlock*/, "RIGHT", .T., "RIGHT")     
oPlanoPrev:SetLinesBefore(0)

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao  
utilizadas

@author Totvs
   
@version P12
@since   03/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport) 

Local oCabec     := oReport:Section("EXERCICIO")
Local oReceitas  := oReport:Section("RECEITAS") 
Local oDespesas  := oReport:Section("DESPESAS")
Local oPlanoPrev := oReport:Section("PLANOPREV")
Local cExerc     := MV_PAR01
Local cBimestre  := MV_PAR02
Local cTpSld     := MV_PAR11
Local cMoeda     := MV_PAR13
Local cTitulo    := STR0018 //"Demonstrativo das Receitas e Despesas Previdenciarias"
Local nDivide    := 1
Local nI         := 0
Local dDataIni   := CToD("  /  /    ")
Local dDataFim   := CToD("  /  /    ")
Local dDtFimBim  := CToD("  /  /    ")
Local aSetOfBook := CTBSetOf(MV_PAR10)
Local aTabRec    := P090CarRec() //Contas Receitas
Local aTabFC     := CargaTab("FC"/*cTabela*/, "FC" /*cRadical*/) //Funcao
Local aTabDE     := CargaTab("DE"/*cTabela*/, "DE" /*cRadical*/) //Categoria Economica da Despesa
Local aTabED     := CargaTab("ED"/*cTabela*/, "ED" /*cRadical*/) //Elemento da Despesa
Local aTabSE     := CargaTab("SE"/*cTabela*/, "SE" /*cRadical*/) //Desdobramento
Local aMoedas    := {}
Local lZerados   := MV_PAR12 == 1
Local lPrint     := .T.

//Divide por
If MV_PAR14 == 2     //Divide por cem
	nDivide := 100
ElseIf MV_PAR14 == 3 //Divide por mil
	nDivide := 1000
ElseIf MV_PAR14 == 4 //Divide por milhao
	nDivide := 1000000
EndIf

aMoedas := CtbMoeda(cMoeda, nDivide)

//Armazena Datas
dDataIni := FirstDay(SToD(cExerc + "0101")) //Data Inicial
dDataFim := LastDay(SToD(cExerc + "1201"))  //Data Final

//Data Final do Bimestre
If cBimestre == "1"
    dDtFimBim := LastDay(SToD(cExerc + "0201"))
ElseIf cBimestre == "2"
    dDtFimBim := LastDay(SToD(cExerc + "0401"))
ElseIf cBimestre == "3"
    dDtFimBim := LastDay(SToD(cExerc + "0601"))
ElseIf cBimestre == "4"
    dDtFimBim := LastDay(SToD(cExerc + "0801"))
ElseIf cBimestre == "5"
    dDtFimBim := LastDay(SToD(cExerc + "1001"))
ElseIf cBimestre == "6"
    dDtFimBim := LastDay(SToD(cExerc + "1201"))
EndIf

//Armazena Receitas
lPrint :=  Pco090Rec(cExerc, cBimestre, cMoeda, cTitulo, nDivide, dDataIni,; 
                        dDataFim, dDtFimBim, aMoedas, aTabRec)

//Armazena Despesas
lPrint := Pco090Des(cExerc, cBimestre, cMoeda, cTitulo, nDivide, dDataIni, dDataFim,; 
                        dDtFimBim, aMoedas, aTabFC, aTabDE, aTabED, aTabSE)

//Armazena Plano Previdenciario
lPrint := Pco090Plan(cExerc, cMoeda, cTitulo, nDivide, aMoedas, cTpSld,;
                        aSetOfBook, lZerados)

If lPrint
    oReport:OnPageBreak({|| ImpCabec(oReport, oCabec, aMoedas)})

    //Imprime Receitas
    If Len(__aReceitas) > 0
        oReceitas:Init()
        
        For nI := 1 To Len(__aReceitas) 
            If oReport:Cancel()
                Exit
            EndIf
            
            __nItemEnt := nI
            
            If nI == Len(__aReceitas) //Totalizador de Receitas
                oReport:SkipLine()
            EndIf
            
            oReceitas:PrintLine()
        Next nI
    
        oReport:ThinLine()
        oReport:SkipLine()
        oReceitas:Finish()
    EndIf

    //Imprime Despesas
    If Len(__aDespesas) > 0
        oDespesas:Init()

        For nI := 1 To Len(__aDespesas) 
            If oReport:Cancel()
                Exit
            EndIf

            __nItemEnt := nI

            If nI == Len(__aDespesas) //Resultado Previdenciario
                oReport:ThinLine()
                oReport:SkipLine()
                oDespesas:PrintLine()
                oReport:ThinLine()
                oReport:SkipLine()
            Else
                If nI == Len(__aDespesas) - 1 //Totalizador de Despesas
                    oReport:SkipLine()
                EndIf
                
                oDespesas:PrintLine()
            EndIf
        Next nI

        oDespesas:Finish()
    EndIf

    //Imprime Plano Previdenciario
    If Len(__aPlanoPrev) > 0
        oPlanoPrev:Init()

        For nI := 1 To Len(__aPlanoPrev)
            If nI == 1
                oPlanoPrev:Cell("VAL_ANT"):SetTitle(CValToChar(Val(cExerc) - 1))
                oPlanoPrev:Cell("VAL_ATU"):SetTitle(cExerc)
            EndIf

            If oReport:Cancel()
                Exit
            EndIf

            __nItemEnt := nI

            oPlanoPrev:PrintLine()
        Next nI

        oPlanoPrev:Finish()
    EndIf
EndIf

//Limpa array e objetos
aSize(__aReceitas , 0)
aSize(__aDespesas , 0)
aSize(__aPlanoPrev, 0)
aSize(aMoedas     , 0)

__aReceitas  := Nil
__aDespesas  := Nil
__aPlanoPrev := Nil
aMoedas      := Nil

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Pco090Rec
Imprime as Receitas do Demonstrativo

@author Totvs
   
@version P12
@since   03/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco090Rec(cExerc, cBimestre, cMoeda, cTitulo, nDivide, dDataIni,; 
                            dDataFim, dDtFimBim, aMoedas, aTabRec)

Local cArqTmp   := ""
Local cCodAgl   := ""
Local cNomReal  := ""
Local cContaN1  := ""
Local cContaN2  := ""
Local cContaN3  := ""
Local cContaN4  := ""
Local cCpoValor := "AKD_VALOR" + CValToChar(Val(cMoeda))
Local nPos      := 0
Local nI        := 0
Local nVlrIni   := 0
Local nVlrAtu   := 0
Local nVlrReal  := 0
Local nIndCta   := 0
Local aTotRec   := {0, "", 0, 0, 0}
Local aLinAux   := {}
Local aTabCE    := CargaTab("CE"/*cTabela*/, "CE" /*cRadical*/) //Categoria Economica
Local aTabO1    := CargaTab("O1"/*cTabela*/, "R" /*cRadical*/)  //Origem
Local aTabED    := CargaTab("E1"/*cTabela*/, "E1" /*cRadical*/) //Especie
Local aTabDR    := CargaTab("DR"/*cTabela*/, "DR" /*cRadical*/) //Desdobramento
Local aTabTP    := CargaTab("TP"/*cTabela*/, "TP" /*cRadical*/) //Tipo
Local nTamRec   := aTabCE[QTDDIG] + aTabO1[QTDDIG] + aTabED[QTDDIG] + aTabDR[QTDDIG] + aTabTP[QTDDIG]
Local oHashRec  := HMNew()

For nI := 1 To 3
    cArqTmp  := GetNextAlias()
    
    //Armazena Codigo Aglutinadora das Visoes de Receita
    If nI == 1
        cCodAgl := MV_PAR03 //Previsao Inicial
    ElseIf nI == 2
        cCodAgl := MV_PAR04 //Previsao Atualizada
    Else
        cCodAgl := MV_PAR05 //Receitas Realizadas
    EndIf 
    
    //Monta Arquivo Temporario para Impressao
    MsgMeter({|oMeter, oText, oDlg, lEnd|;
                cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, cMoeda, .T., cCodAgl,;
                                        dDataIni, dDataFim, Nil, Nil, nDivide)}, STR0019, cTitulo) //"Criando Arquivo Temporario..."

    //Todo o arquivo 
    While (cArqTmp)->(!Eof())
        //Alimenta Entidades de Receitas
        If (nPos := aScan(aTabRec, {|x| AllTrim(x[ANALIT]) == SubStr((cArqTmp)->AKD_CO, 1, nTamRec)})) > 0
            cContaN1 := aTabRec[nPos][SINTE1]
            cContaN2 := aTabRec[nPos][SINTE2]
            cContaN3 := aTabRec[nPos][SINTE3]
            cContaN4 := aTabRec[nPos][SINTE4]
            
            //Valores: Previsao Inicial, Atualizada e Receitas Realizadas
            If nI == 1 
                nVlrIni  := (cArqTmp)->&(cCpoValor)
                nVlrAtu  := 0
                nVlrReal := 0
            ElseIf nI == 2
                nVlrIni  := 0
                nVlrAtu  := (cArqTmp)->&(cCpoValor)
                nVlrReal := 0
            Else
                nVlrIni  := 0
                nVlrAtu  := 0
                nVlrReal := 0
                
                //Armazena Receitas Realizadas somente até o Bimestre selecionado
                If (cArqTmp)->AKD_DATA <= dDtFimBim
                    nVlrReal := (cArqTmp)->&(cCpoValor)
                EndIf
            EndIf
            
            //Primeiro nivel Sintetica
            If !Empty(cContaN1)
                cChvEnti := cContaN1
                If oHashRec:Get(cChvEnti, @aLinAux)
                    aLinAux[VLR_PREINI] += nVlrIni
                    aLinAux[VLR_PREATU] += nVlrAtu
                    aLinAux[VLR_REAL]   += nVlrReal
                    HMSet(oHashRec, cChvEnti, aLinAux)
                Else
                    nIndCta++
                    HMSet(oHashRec, cChvEnti, {nIndCta,;
                                               cContaN1,; 
                                               nVlrIni,;
                                               nVlrAtu,; 
                                               nVlrReal})
                EndIf
            EndIf
        
            //Segundo nivel Sintetica
            If !Empty(cContaN2)
                cChvEnti := cContaN2
                If oHashRec:Get(cChvEnti, @aLinAux)
                    aLinAux[VLR_PREINI] += nVlrIni
                    aLinAux[VLR_PREATU] += nVlrAtu
                    aLinAux[VLR_REAL]   += nVlrReal
                    HMSet(oHashRec, cChvEnti, aLinAux)
                Else
                    nIndCta++
                    HMSet(oHashRec, cChvEnti, {nIndCta,;
                                               Replicate(".", 2) + cContaN2,; 
                                               nVlrIni,;
                                               nVlrAtu,; 
                                               nVlrReal})
                EndIf
            EndIf

            //Terceiro nivel Sintetica
            If !Empty(cContaN3)
                cChvEnti := cContaN2 + cContaN3
                If oHashRec:Get(cChvEnti, @aLinAux)
                    aLinAux[VLR_PREINI] += nVlrIni
                    aLinAux[VLR_PREATU] += nVlrAtu
                    aLinAux[VLR_REAL]   += nVlrReal
                    HMSet(oHashRec, cChvEnti, aLinAux)
                Else
                    nIndCta++
                    HMSet(oHashRec, cChvEnti, {nIndCta,;
                                               Replicate(".", 4) + cContaN3,; 
                                               nVlrIni,;
                                               nVlrAtu,; 
                                               nVlrReal})
                EndIf
            EndIf

            //Quarto nivel Sintetica
            If !Empty(cContaN4)
                cChvEnti := cContaN2 + cContaN3 + cContaN4
                If oHashRec:Get(cChvEnti, @aLinAux)
                    aLinAux[VLR_PREINI] += nVlrIni
                    aLinAux[VLR_PREATU] += nVlrAtu
                    aLinAux[VLR_REAL]   += nVlrReal
                    HMSet(oHashRec, cChvEnti, aLinAux)
                Else
                    nIndCta++
                    HMSet(oHashRec, cChvEnti, {nIndCta,;
                                               Replicate(".", 6) + cContaN4,; 
                                               nVlrIni,;
                                               nVlrAtu,; 
                                               nVlrReal})
                EndIf
            EndIf
            
            //Alimenta Totalizador de Receitas
            aTotRec[VLR_PREINI] += nVlrIni
            aTotRec[VLR_PREATU] += nVlrAtu
            aTotRec[VLR_REAL]   += nVlrReal
        EndIf

        (cArqTmp)->(dbSkip())
    EndDo

    //Fecha arquivo temporario
    If Select("cArqTmp") > 0
        (cArqTmp)->(dbCloseArea()) 
    EndIf
Next nI

//Adiciona Totalizador de Receitas no Array
If nIndCta > 0
    nIndCta++
    HMSet(oHashRec, nIndCta, {nIndCta,;
                              STR0020,; //"TOTAL DAS RECEITAS PREVIDENCIARIAS - RPPS"
                              aTotRec[VLR_PREINI],;
                              aTotRec[VLR_PREATU],; 
                              aTotRec[VLR_REAL]})
EndIf

//Armazena movimentos
HMList(oHashRec, __aReceitas)
HMClean(oHashRec)
aSort(__aReceitas,,, {|x, y| x[2][1] < y[2][1]})

//Limpa objeto
FreeObj(oHashRec)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Pco090Des
Imprime as Receitas do Demonstrativo

@author Totvs
   
@version P12
@since   04/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco090Des(cExerc, cBimestre, cMoeda, cTitulo, nDivide, dDataIni, dDataFim,; 
                            dDtFimBim, aMoedas, aTabFC, aTabDE, aTabED, aTabSE)

Local cArqTmp   := ""
Local cCodAgl   := ""
Local cNomReal  := ""
Local cFunc     := ""
Local cCateg    := ""
Local cElemen   := ""
Local cSubElem  := ""
Local cChvEnti  := ""
Local cCpoValor := "AKD_VALOR" + CValToChar(Val(cMoeda))
Local nI        := 0
Local nVlDotIni := 0
Local nVlDotAtu := 0
Local nVlrEmp   := 0
Local nVlrLiq   := 0
Local nIndCta   := 0
Local aLinAux   := {}
Local aTotDes   := {0, "", 0, 0, 0, 0}
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
Funcao -> Substr(AKD_CO, 7, 2)
Cat.Economica -> Substr(AKD_CO, 17, 1)
Elemento da Despesa/Sub Elemento da Despesa -> Substr(AKD_CO, 21, 6)

Tabela FC-FC - Funcao
Tabela DE-DE - Categ. Economica da Despesa
Tabela ED-ED - Elemento da Despesa
Tabela SE-SE - Sub-Elemento da Despesa
*/

For nI := 1 To 4
    cArqTmp  := GetNextAlias()
    
    //Armazena Codigo Aglutinadora de Visoes
    If nI == 1
        cCodAgl := MV_PAR06 //Dotacao Inicial
    ElseIf  nI == 2
        cCodAgl := MV_PAR07 //Dotacao Atualizada
    ElseIf nI == 3
        cCodAgl := MV_PAR08 //Despesas Empenhadas
    ElseIf nI == 4
        cCodAgl := MV_PAR09 //Despesas Liquidadas
    EndIf 
    
    //Monta Arquivo Temporario para Impressao
    MsgMeter({|oMeter, oText, oDlg, lEnd|;
                cNomReal := PCGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, cMoeda, .T., cCodAgl,;
                                        dDataIni, dDataFim, Nil, Nil, nDivide)}, STR0019, cTitulo) //"Criando Arquivo Temporario..."

    //Todo o arquivo 
    While (cArqTmp)->(!Eof())
        //Alimenta Entidades de Despesas
        cFunc    := SubStr((cArqTmp)->AKD_CO, aTabFC[POSINI], aTabFC[QTDDIG])
        cCateg   := SubStr((cArqTmp)->AKD_CO, aTabDE[POSINI], aTabDE[QTDDIG])
        cElemen  := SubStr((cArqTmp)->AKD_CO, aTabED[POSINI], aTabED[QTDDIG])
        cSubElem := SubStr((cArqTmp)->AKD_CO, aTabSE[POSINI], aTabSE[QTDDIG])

        //Alimenta valores Dotacao Inicial, Dotacao Atualizada, Despesas Empenhadas e Despesas Liquidadas
        If nI == 1
            nVlDotIni := (cArqTmp)->&(cCpoValor)
            nVlDotAtu := 0
            nVlrEmp   := 0
            nVlrLiq   := 0
        ElseIf nI == 2
            nVlDotIni := 0
            nVlDotAtu := (cArqTmp)->&(cCpoValor)
            nVlrEmp   := 0
            nVlrLiq   := 0
        ElseIf nI == 3
            nVlDotIni := 0
            nVlDotAtu := 0
            nVlrEmp   := 0
            nVlrLiq   := 0

            //Armazena Despesas Empenhadas somente até o Bimestre selecionado
            If (cArqTmp)->AKD_DATA <= dDtFimBim
                nVlrEmp := (cArqTmp)->&(cCpoValor)
            EndIf
        ElseIf nI == 4
            nVlDotIni := 0
            nVlDotAtu := 0
            nVlrEmp   := 0
            nVlrLiq   := 0

            //Armazena Despesas Liquidadas somente até o Bimestre selecionado
            If (cArqTmp)->AKD_DATA <= dDtFimBim
                nVlrLiq := (cArqTmp)->&(cCpoValor)
            EndIf
        EndIf

        //Adiciona Despesas por Funcao
        cChvEnti := cFunc

        If oHashDes:Get(cChvEnti, @aLinAux)
            aLinAux[VLR_DOTINI] += nVlDotIni
            aLinAux[VLR_DOTATU] += nVlDotAtu
            aLinAux[VLR_EMP]    += nVlrEmp
            aLinAux[VLR_LIQ]    += nVlrLiq
            HMSet(oHashDes, cChvEnti, aLinAux)
        Else
            If (nPos := aScan(aTabFC[ITETAB], {|x| AllTrim(x[1]) == AllTrim(cFunc)})) > 0
                nIndCta++
                HMSet(oHashDes, cChvEnti, {nIndCta,; 
                                           aTabFC[ITETAB][nPos][ITEDES],;
                                           nVlDotIni,; 
                                           nVlDotAtu,;
                                           nVlrEmp,;
                                           nVlrLiq})
            EndIf
        EndIf
        
        //Adiciona Despesas por Categoria Economica
        cChvEnti := cFunc + cCateg

        If oHashDes:Get(cChvEnti, @aLinAux)
            aLinAux[VLR_DOTINI] += nVlDotIni
            aLinAux[VLR_DOTATU] += nVlDotAtu
            aLinAux[VLR_EMP]    += nVlrEmp
            aLinAux[VLR_LIQ]    += nVlrLiq
            HMSet(oHashDes, cChvEnti, aLinAux)
        Else
            If (nPos := aScan(aTabDE[ITETAB], {|x| AllTrim(x[1]) == AllTrim(cCateg)})) > 0
                nIndCta++
                HMSet(oHashDes, cChvEnti, {nIndCta,; 
                                           Replicate(".", 2) + aTabDE[ITETAB][nPos][ITEDES],;
                                           nVlDotIni,; 
                                           nVlDotAtu,;
                                           nVlrEmp,;
                                           nVlrLiq})
            EndIf
        EndIf  

        //Adiciona Despesas por Elemento da Despesa
        cChvEnti := cFunc + cCateg + cElemen

        If oHashDes:Get(cChvEnti, @aLinAux)
            aLinAux[VLR_DOTINI] += nVlDotIni
            aLinAux[VLR_DOTATU] += nVlDotAtu
            aLinAux[VLR_EMP]    += nVlrEmp
            aLinAux[VLR_LIQ]    += nVlrLiq
            HMSet(oHashDes, cChvEnti, aLinAux)
        Else
            If (nPos := aScan(aTabED[ITETAB], {|x| AllTrim(x[1]) == AllTrim(cElemen)})) > 0
                nIndCta++
                HMSet(oHashDes, cChvEnti, {nIndCta,; 
                                           Replicate(".", 4) + aTabED[ITETAB][nPos][ITEDES],;
                                           nVlDotIni,; 
                                           nVlDotAtu,;
                                           nVlrEmp,;
                                           nVlrLiq})
            EndIf
        EndIf

        //Adiciona Despesas por Sub-Elemento da Despesa
        cChvEnti := cFunc + cCateg + cElemen + cSubElem

        If oHashDes:Get(cChvEnti, @aLinAux)
            aLinAux[VLR_DOTINI] += nVlDotIni
            aLinAux[VLR_DOTATU] += nVlDotAtu
            aLinAux[VLR_EMP]    += nVlrEmp
            aLinAux[VLR_LIQ]    += nVlrLiq
            HMSet(oHashDes, cChvEnti, aLinAux)
        Else
            If (nPos := aScan(aTabSE[ITETAB], {|x| AllTrim(x[1]) == AllTrim(cSubElem)})) > 0
                nIndCta++
                HMSet(oHashDes, cChvEnti, {nIndCta,; 
                                           Replicate(".", 6) + aTabSE[ITETAB][nPos][ITEDES],;
                                           nVlDotIni,; 
                                           nVlDotAtu,;
                                           nVlrEmp,;
                                           nVlrLiq})
            EndIf
        EndIf

        //Alimenta Totalizador de Despesas
        aTotDes[VLR_DOTINI] += nVlDotIni
        aTotDes[VLR_DOTATU] += nVlDotAtu
        aTotDes[VLR_EMP]    += nVlrEmp
        aTotDes[VLR_LIQ]    += nVlrLiq

        (cArqTmp)->(dbSkip())
    EndDo

    //Fecha arquivo temporario
    If Select("cArqTmp") > 0
        (cArqTmp)->(dbCloseArea()) 
    EndIf
Next nI

If nIndCta > 0
    //Adiciona Totalizador de Despesas no Array
    nIndCta++
    HMSet(oHashDes, nIndCta, {nIndCta,;
                              STR0021,; //"TOTAL DAS DESPESAS PREVIDENCIARIAS - RPPS"
                              aTotDes[VLR_DOTINI],;
                              aTotDes[VLR_DOTATU],; 
                              aTotDes[VLR_EMP],;
                              aTotDes[VLR_LIQ]})

    //Adiciona Resultado Previdenciario no Array
    nIndCta++
    If Len(__aReceitas) > 0
        HMSet(oHashDes, nIndCta, {nIndCta,;
                                  STR0022,; //"RESULTADO PREVIDENCIARIO"
                                  __aReceitas[Len(__aReceitas)][ITEHASH][VLR_PREINI] - aTotDes[VLR_DOTINI],;
                                  __aReceitas[Len(__aReceitas)][ITEHASH][VLR_PREATU] - aTotDes[VLR_DOTATU],; 
                                  __aReceitas[Len(__aReceitas)][ITEHASH][VLR_REAL]   - aTotDes[VLR_EMP],;
                                  __aReceitas[Len(__aReceitas)][ITEHASH][VLR_REAL]   - aTotDes[VLR_LIQ]})
    Else
        HMSet(oHashDes, nIndCta, {nIndCta,;
                                  STR0022,; //"RESULTADO PREVIDENCIARIO"
                                  0,;
                                  0,; 
                                  0,;
                                  0})
    EndIf
EndIf

//Armazena movimentos
HMList(oHashDes, __aDespesas)
HMClean(oHashDes)
aSort(__aDespesas,,, {|x, y| x[2][1] < y[2][1]})

//Limpa objeto
FreeObj(oHashDes)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} Pco090Plan
Imprime o Plano Previdenciario do Demonstrativo

@author Totvs
   
@version P12
@since   07/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function Pco090Plan(cExerc, cMoeda, cTitulo, nDivide, aMoedas, cTpSld,;
                            aSetOfBook, lZerados)

Local oHashPrev  := tHashMap():New()
Local cArqTmp	 := ""
Local cDescPer   := ""
Local nI         := 0
Local nSaldoAnt  := 0
Local nSaldoAtu  := 0
Local dDataIni   := StoD("")
Local dDataFim   := StoD("")
Local aLinAux    := {}
Local lRet       := .T.

Private lComNivel := .T. //Variável utilizada no CTBXSAL para retornar o campo NIVEL

If Empty(aSetOfBook[5])
	MsgAlert(STR0023)  //"Os Demonstrativos das Receitas e Despesas Previdenciarias obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	lRet := .F.
Else
    aSetOfBook[9] := nDivide

    For nI := 1 To 2
        cArqTmp := ""

        If nI == 1 //Ano anterior
            dDataIni := FirstDay(StoD(CValToChar(Val(cExerc) - 1) + "0101")) 
            dDataFim := LastDay(StoD(CValToChar(Val(cExerc) - 1) + "1201"))
            cDescPer := CValToChar(Val(cExerc) - 1)
        ElseIf nI == 2 //Ano Atual
            dDataIni := FirstDay(StoD(cExerc + "0101")) 
            dDataFim := LastDay(StoD(cExerc + "1201"))
            cDescPer := cExerc
        EndIf

        //Monta Arquivo Temporario para Impressao
        MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
                    CTGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, dDataIni, dDataFim, "", "", "",;
                              Repl("Z", Len(CT1->CT1_CONTA)), "", Repl("Z", Len(CTT->CTT_CUSTO)), "",; 
                              Repl("Z", Len(CTD->CTD_ITEM)), "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda,; 
                              cTpSld, aSetOfBook, Space(2), Space(20), Repl("Z", 20), Space(30),,,,,,,;
                              nDivide,,,,,,,,,,,,,,,,,,,,,,,,,, cMoeda, .T.)}, STR0024 + cDescPer, cTitulo) //"Carregando valores de "

        dbSelectArea("cArqTmp")
        dbGoTop()

        While !Eof()
            //Saldo: Ano Anterior e Ano Atual
            If nI == 1 
                nSaldoAnt  := Abs(SALDOATU) - Abs(MOVPERANT)
                nSaldoAtu  := 0
            ElseIf nI == 2
                nSaldoAnt  := 0
                nSaldoAtu  := Abs(SALDOATU) - Abs(MOVPERANT)
            EndIf
            
            If TIPOCONTA == "1" .And.; 
                (lZerados .Or. nSaldoAnt > 0 .Or. nSaldoAtu > 0)

                If oHashPrev:Get(CONTA, @aLinAux)
                    aLinAux[VLR_ANT] += nSaldoAnt
                    aLinAux[VLR_ATU] += nSaldoAtu
                    HMSet(oHashPrev, CONTA, aLinAux)
                Else            
                    HMSet(oHashPrev, CONTA, {CONTA,;     //[1] Conta
                                             DESCCTA,;	 //[2] Descricao da Conta
                                             nSaldoAnt,; //[3] Saldo Anterior
                                             nSaldoAtu}) //[4] Saldo Atual
                EndIf
            EndIf

		    dbSkip()
	    EndDo

        dbSelectArea("cArqTmp")
        Set Filter To
        dbCloseArea()

        If Select("cArqTmp") == 0
            FErase(cArqTmp + GetDBExtension())
            FErase(cArqTmp + OrdBagExt())
        EndIf	 
    Next nI

    HMList(oHashPrev, @__aPlanoPrev)
    HMClean(oHashPrev) //Limpa os dados do HashMap
    aSort(__aPlanoPrev,,, {|x,y| x[1] < y[1]}) 

    //Limpa objeto
    FreeObj(oHashPrev)
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Desc_Clas()
Descricao da Conta Sintetica para Receita e Despesa

cTipo:
    R = Receitas
    D = Despesas
    P = Plano Previdenciario

@author Totvs
   
@version P12
@since   04/12/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Desc_Clas(cTipo)

Local cDesc := ""

If Upper(cTipo) == "R" //Receitas
    cDesc := __aReceitas[__nItemEnt][ITEHASH][DESC_CTA]
ElseIf Upper(cTipo) == "D" //Despesas
    cDesc := __aDespesas[__nItemEnt][ITEHASH][DESC_CTA] 
ElseIf Upper(cTipo) == "P" //Plano Previdenciario
    cDesc := __aPlanoPrev[__nItemEnt][ITEHASH][DESC_CTA]
EndIf

Return cDesc

//-------------------------------------------------------------------
/*{Protheus.doc} Val_Enti(cTipo, nEnti)

Valores das Entidades (Receitas e Despesas)

cTipo:
    R = Receitas
    D = Despesas
    P = Plano Previdenciario

nEnti: 
    Receitas
    1 - Previsao Inicial
    2 - Previsao Atualizada
    3 - Receitas Realizadas Ate o Bimestre

    Despesas
    1 - Dotacao Inicial
    2 - Dotacao Atualizada
    3 - Despesas Empenhadas
    4 - Despesas Liquidadas

    Plano Previdenciario
    1 - Ano Anterior
    2 - Ano Atual

@author Totvs
   
@version P12
@since   04/12/2020
@return  Nil
@obs	 
*/
//----------------------------------------------------------------

Static Function Val_Enti(cTipo, nEnti)

Local nValor := 0  

If Upper(cTipo) == "R" //Receitas
    If nEnti == 1
        nValor := __aReceitas[__nItemEnt][ITEHASH][VLR_PREINI]
    ElseIf nEnti == 2
        nValor := __aReceitas[__nItemEnt][ITEHASH][VLR_PREATU]
    ElseIf nEnti == 3
        nValor := __aReceitas[__nItemEnt][ITEHASH][VLR_REAL]
    EndIf
ElseIf Upper(cTipo) == "D" //Despesas
    If nEnti == 1
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_DOTINI]
    ElseIf nEnti == 2
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_DOTATU]
    ElseIf nEnti == 3
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_EMP]
    ElseIf nEnti == 4
        nValor := __aDespesas[__nItemEnt][ITEHASH][VLR_LIQ]
    EndIf
ElseIf Upper(cTipo) == "P" //Plano Previdenciario
    If nEnti == 1
        nValor := __aPlanoPrev[__nItemEnt][ITEHASH][VLR_ANT]
    ElseIf nEnti == 2
        nValor := __aPlanoPrev[__nItemEnt][ITEHASH][VLR_ATU]
    EndIf
EndIf

Return nValor  

//-------------------------------------------------------------------
/*{Protheus.doc} ImpCabec
Cabecalho do relatorio - imprimir em todas as paginas

@author Totvs
   
@version P12
@since   04/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ImpCabec(oReport, oCabec, aMoedas, dDataFim)

Local cUnidMoed := ""
Local cExerc    := MV_PAR01
Local cBimestre := MV_PAR02

If MV_PAR14 == 2
    cUnidMoed := STR0025 //"Centena de" 
ElseIf MV_PAR14 == 3
    cUnidMoed := STR0026 //"Milhares de" 
ElseIf MV_PAR14 == 4
    cUnidMoed := STR0027 //"Milhoes de"
EndIf

//Imprime cabecalho
If ValType(aMoedas) == "A"
    oCabec:Init()
    oCabec:Cell("EXERCICIO"):SetBlock({|| STR0028 + AllTrim(cExerc) + "            ("+ STR0029 + cUnidMoed + " : " + AllTrim(aMoedas[3]) +  ")"}) //"Exercicio : " #"em " 
    oCabec:PrintLine()
    oCabec:Cell("EXERCICIO"):SetBlock({|| STR0030 + STR0031}) //"Periodicidade : " #"Bimestral"
    oCabec:PrintLine()
    oCabec:Cell("EXERCICIO"):SetBlock({|| STR0032 + AllTrim(cBimestre) + " " + STR0033}) //"Periodo :" #"Bimestre"
    oCabec:PrintLine()
    oCabec:Finish()

    //Pula linha
    oReport:SkipLine()
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} P090CarRec
Carrega contas de Receitas Previdenciarias, sao contas fixas

@author Totvs
   
@version P12
@since   03/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function P090CarRec()

Local aContaRec := {}

//Adiciona Contas - 1 Sintética, 2 - Sintetica, 3 - Sintetica, 4 - Sintetica e 5 - Analitica
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "ATIVO"      , "12180110"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "ATIVO"      , "12180140"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "ATIVO"      , "12180210"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "ATIVO"      , "12180240"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "INATIVO"    , "12180120"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "INATIVO"    , "12180150"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "INATIVO"    , "12180220"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "INATIVO"    , "12180250"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "PENSIONISTA", "12180130"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "PENSIONISTA", "12180160"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "PENSIONISTA", "12180230"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "CIVIL"                                         , "PENSIONISTA", "12180260"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "MILITAR"                                       , "ATIVO"      , "12180510"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "MILITAR"                                       , "ATIVO"      , "12180610"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "MILITAR"                                       , "INATIVO"    , "12180520"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "MILITAR"                                       , "INATIVO"    , "12180620"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "MILITAR"                                       , "PENSIONISTA", "12180530"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES"          , "MILITAR"                                       , "PENSIONISTA", "12180630"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "ATIVO"      , "12180310"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "ATIVO"      , "12180340"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "ATIVO"      , "12180410"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "ATIVO"      , "12180440"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "INATIVO"    , "12180320"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "INATIVO"    , "12180350"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "INATIVO"    , "12180420"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "INATIVO"    , "12180450"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "PENSIONISTA", "12180330"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "PENSIONISTA", "12180360"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "PENSIONISTA", "12180430"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "CIVIL"                                         , "PENSIONISTA", "12180460"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "MILITAR"                                       , "ATIVO"      , "12180710"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "MILITAR"                                       , "ATIVO"      , "12180810"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "MILITAR"                                       , "INATIVO"    , "12180720"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "MILITAR"                                       , "INATIVO"    , "12180820"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "MILITAR"                                       , "PENSIONISTA", "12180730"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA DE CONTRIBUICOES PATRONAIS", "MILITAR"                                       , "PENSIONISTA", "12180830"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA PATRIMONIAL"               , "RECEITAS IMOBILIARIAS"                         , ""           , "13100000"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "RECEITA PATRIMONIAL"               , "RECEITAS DE VALORES MOBILIARIOS"               , ""           , "13200000"})
aAdd(aContaRec, {"RECEITAS CORRENTES" , "OUTRAS RECEITAS CORRENTES"         , "COMPENSACAO PREVIDENCIARIA DO RGPS PARA O RPPS", ""           , "19900300"})
aAdd(aContaRec, {"RECEITAS DE CAPITAL", "AMORTIZACAO DE EMPRESTIMOS"        , ""                                              , ""           , "23000610"})
aAdd(aContaRec, {"RECEITAS DE CAPITAL", "OUTRAS RECEITAS DE CAPITAL"        , ""                                              , ""           , "29980100"})

Return(aContaRec)

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