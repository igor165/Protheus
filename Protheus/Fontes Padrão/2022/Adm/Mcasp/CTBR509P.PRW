#Include "PROTHEUS.CH"
#Include "CTBR509P.CH"

#DEFINE ANOATU      1
#DEFINE ANOANT      2
#DEFINE ANOSEGANT   3

#DEFINE C_CONTA		1
#DEFINE C_DESC		1
#DEFINE C_SALDOATU  2
#DEFINE C_TIPCONTA  3

//-------------------------------------------------------------------
/*{Protheus.doc} CTBR509P
Relatorio LDO - Avaliacao da Situacao Financeira e Atuarial do Regime
Proprio da Previdencia

@author Totvs
   
@version P12
@since   05/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CTBR509P()

Local oReport       := Nil
Local cPerg         := "CTR509P"
Local aSetOfBook    := {}
Local aCtbMoeda		:= {}
Local aSelFil		:= {}
Local lContinua     := .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_PAR01    Ano de Referencia:        								³
//³ MV_PAR02    Cod Config Livros:       				                ³
//³ MV_PAR03    Moeda:                    						        ³
//³ MV_PAR04    Tipo de Saldo:						                    ³
//³ MV_PAR05    Saldos Zerados:            								³
//³ MV_PAR06    Divide por:        				    					³
//³ MV_PAR07    Seleciona Filiais:  			    					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0001), 1, 0) //"Relatório Avaliacao da Situacao Financeira e Atuarial do Regime Proprio da Previdencia disponível a partir da versao 12.1.23"
    lContinua := .F.
ElseIf !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi(STR0002), 1, 0) //"Para utilizaçao do relatório Avaliacao da Situacao Financeira e Atuarial do Regime Proprio da Previdencia é necessário aplicar o pacote acumulado da controladoria."
    lContinua := .F.
Else 
    //Perguntas do Relatório
    lContinua := Pergunte(cPerg, .T.) 
EndIf   

//Faz a validacao das filiais
If lContinua .And. MV_PAR07 == 1 .And. Len(aSelFil) <= 0 
	aSelFil := AdmGetFil()
	
	If Len(aSelFil) <= 0
		lContinua := .F.
	EndIf                     
EndIf

If lContinua
    //Seta o livro
	aSetOfBook := CTBSetOf(MV_PAR02)

	//Seta a moeda
	aCtbMoeda := CtbMoeda(MV_PAR03, aSetOfBook[9])

	If Empty(aCtbMoeda[1])
		Help(" ", 1, "NOMOEDA")
		lContinua := .F.
	EndIf	
    
    If lContinua  
        oReport := ReportDef(cPerg, aSelFil, aSetOfBook)

        If ValType(oReport) == "O"    
            oReport:PrintDialog()
        EndIf

        oReport := Nil
    EndIf    
EndIf
	
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que serao 
utilizadas 

@author Totvs
   
@version P12
@since   05/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg, aSelFil, aSetOfBook)

Local oReport   := Nil
Local oSecCab1  := Nil
Local oSecCab2  := Nil
Local oSaldos   := Nil
Local oTotais   := Nil
Local oBorder   := Nil
Local cNomeProg := "CTBR509P"
Local cDescri   := OemToAnsi(STR0003) //"Este programa ira imprimir o Relatorio Avaliacao da Situacao Financeira e Atuarial do Regime Proprio da Previdencia."	
Local cTitulo 	:= STR0019 //"Avaliacao da Situacao Financeira e Atuarial do Regime Proprio da Previdencia"

oReport := TReport():New(cNomeProg, cTitulo, cPerg, {|oReport| Pergunte(cPerg, .F.), IIf(ReportPrint(oReport, cTitulo, aSelFil), .T., oReport:CancelPrint())}, cDescri)
oReport:SetTotalInLine(.T.)
oReport:ParamReadOnly(.T.)
oReport:SetPortrait(.T.)
oReport:DisableOrientation() //Desabilita opcao para mudar orientacao de impressao

//Configuracoes de impressao
oReport:nFontBody   := 9 //Define o tamanho da fonte
oReport:nLineHeight	:= 45 //Define a altura da linha.
oReport:CFONTBODY   := "Arial Narrow"

oBorder := TRBorder():New(oReport, 5,, 0)

oSecCab1 := TRSection():New(oReport, "SECCAB1")
TRCell():New(oSecCab1, "DESC_PREV",, "" /*Titulo*/, /*Picture*/, 100 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "CENTER" /*cAlign*/, /*lLineBreak*/,,,, .T.,,, .T.)
oSecCab1:oHBrdBottom := oBorder //Remove a borda do cabecalho

oSecCab2 := TRSection():New(oReport, "SECCAB2")
TRCell():New(oSecCab2, "CABEC",, "" /*Titulo*/, /*Picture*/, 50 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*cAlign*/, /*lLineBreak*/,,,, .T.,,, .T.)
TRCell():New(oSecCab2, "ANO_ATU"   ,, "",, TamSx3("CT2_VALOR")[1], /*lPixel*/, /*CodeBlock*/,,,,,, .T.,,, .T.)     
TRCell():New(oSecCab2, "ANO_ANT"   ,, "",, TamSx3("CT2_VALOR")[1], /*lPixel*/, /*CodeBlock*/,,,,,, .T.,,, .T.) 
TRCell():New(oSecCab2, "ANO_SEGANT",, "",, TamSx3("CT2_VALOR")[1], /*lPixel*/, /*CodeBlock*/,,,,,, .T.,,, .T.) 
oSecCab2:SetLinesBefore(0)

oSaldos := TRSection():New(oReport, "SALDOS",, /*aOrdem*/)
TRCell():New(oSaldos, "CONTA"     ,, "",, TamSx3("CTS_DESCCG")[1]+30, /*lPixel*/, /*CodeBlock*/,,,,, 3)     
TRCell():New(oSaldos, "VAL_ATU"   ,, "",, TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/,,,,,, .T.)     
TRCell():New(oSaldos, "VAL_ANT"   ,, "",, TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/,,,,,, .T.) 
TRCell():New(oSaldos, "VAL_SEGANT",, "",, TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/,,,,,, .T.) 
oSaldos:SetLinesBefore(0)

oTotais := TRSection():New(oReport, "TOTAIS",, /*aOrdem*/)
TRCell():New(oTotais, "DESCRI"    ,, "",, TamSx3("CTS_DESCCG")[1]+30, /*lPixel*/, /*CodeBlock*/,,,,, 3,,,, .T.)     
TRCell():New(oTotais, "TOT_ATU"   ,, "",, TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/,,,,,, .T.,,, .T.)     
TRCell():New(oTotais, "TOT_ANT"   ,, "",, TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/,,,,,, .T.,,, .T.) 
TRCell():New(oTotais, "TOT_SEGANT",, "",, TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/,,,,,, .T.,,, .T.) 

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao 
utilizadas 

@author Totvs
   
@version P12
@since   06/08/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport, cTitulo, aSelFil)

Local oSecCab1    := oReport:Section("SECCAB1")
Local oSecCab2    := oReport:Section("SECCAB2")
Local oSaldos     := oReport:Section("SALDOS")
Local oTotais     := oReport:Section("TOTAIS")
Local oHashLin    := tHashMap():New()
Local cArqTmp	  := ""
Local cIdent      := ""
Local cAnoRef     := MV_PAR01
Local cMoeda      := MV_PAR03
Local cTpSld      := MV_PAR04
Local nI          := 0
Local nDivide     := 1 
Local dDataIni    := StoD("")
Local dDataFim    := StoD("")
Local aLinhas     := {}
Local aLinAux     := {}
Local aCtbMoeda	  := {}
Local aSaldos     := {}
Local aTotRec     := {0, 0, 0}
Local aTotDes     := {0, 0, 0}
Local aTotApor    := {0, 0, 0}
Local aResult     := {0, 0, 0}
Local aSetOfBook  := CTBSetOf(MV_PAR02)
Local lRet        := .T.
Local lCabRec     := .T.
Local lCabDes     := .T.
Local lCabApor    := .T.
Local lTotApor    := .T.
Local lReserva    := .T.
Local lZerados    := MV_PAR05 == 1

Private lComNivel	:= .T. //Variável utilizada no CTBXSAL para retornar o campo NIVEL

If Empty(aSetOfBook[5])
	MsgAlert(STR0008)  //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	lRet := .F.
Else
    //Divide por
    If MV_PAR06 == 2        //Divide por cem
        nDivide := 100
    ElseIf MV_PAR06 == 3    //Divide por mil
        nDivide := 1000
    ElseIf MV_PAR06 == 4	//Divide por milhao
        nDivide := 1000000
    EndIf

    aSetOfBook[9] := nDivide
    aCtbMoeda := CtbMoeda(cMoeda, nDivide)
   
    For nI := 1 To 3
        cArqTmp  := ""
	    
        If nI < 3 //Ano atual e anterior
            dDataIni := StoD(cAnoRef + "0101") 
        Else //Ultimo Bimestre do segundo ano anterior
            dDataIni := StoD(cAnoRef + "1101") 
        EndIf

        dDataFim := StoD(cAnoRef + "1231") 

        //Monta Arquivo Temporario para Impressao
        MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
                    CTGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, dDataIni, dDataFim, "", "", "",;
                              Repl("Z", Len(CT1->CT1_CONTA)), "", Repl("Z", Len(CTT->CTT_CUSTO)), "",; 
                              Repl("Z", Len(CTD->CTD_ITEM)), "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda,; 
                              cTpSld, aSetOfBook, Space(2), Space(20), Repl("Z", 20), Space(30),,,,,,,;
                              nDivide,,,,,,,,,,,,,,,,,,,,,,,,,, cMoeda,, aSelFil)}, STR0009 + cAnoRef, cTitulo) //"Carregando valores de "

        dbSelectArea("cArqTmp")
        dbGoTop()
         
        While !Eof()
            If !oHashLin:Get(CONTA, @aLinAux)            
                HMSet(oHashLin, CONTA, { DESCCTA,;	  //[1]
                                         SALDOATU,;   //[2]
                                         TIPOCONTA }) //[3]
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

        HMList(oHashLin, @aLinhas)

	    aSort(aLinhas,,, {|x,y| x[1] < y[1]})
        aAdd(aSaldos, aClone(aLinhas))

        HMClean(oHashLin) //Limpa os dados do HashMap      

        cAnoRef := CValToChar(Val(cAnoRef)-1)
    Next nI

    If Len(aSaldos) > 0
        oSecCab1:Init()
        oSecCab2:Init()
        oSaldos:Init()
        oTotais:Init()

        For nI := 1 To Len(aSaldos[ANOATU])
            //Cabecalhos e Totalizadores
            Do Case
                Case SubStr(aSaldos[ANOATU][nI][C_CONTA], 1, 1) $ "1|2" .And. lCabRec //Receitas
                    C509ImpCab(oReport, oSecCab1, oSecCab2, aCtbMoeda, STR0010, nDivide) //"RECEITAS  PREVIDENCIARIAS"
                    lCabRec := .F. //Flag para imprimir cabecalho Receitas apenas 1 vez
                Case SubStr(aSaldos[ANOATU][nI][C_CONTA], 1, 1) $ "3|4" .And. lCabDes //Despesas
                    C509ImpTot(oReport, oTotais, STR0014, aTotRec) //"TOTAL DAS RECEITAS PREVIDENCIARIAS (I)"	
                    C509ImpCab(oReport, oSecCab1, oSecCab2, aCtbMoeda, STR0011, nDivide, .T.) //"DESPESAS  PREVIDENCIARIAS"
                    lCabDes := .F. //Flag para imprimir cabecalho Despesas apenas 1 vez
                Case SubStr(aSaldos[ANOATU][nI][C_CONTA], 1, 1) $ "5|6" .And. lCabApor //Aportes
                    C509ImpTot(oReport, oTotais, STR0015, aTotDes, .T.) //"TOTAL DAS DESPESAS PREVIDENCIARIAS (II)"
                    C509ImpTot(oReport, oTotais, STR0016, aResult) //"RESULTADO PREVIDENCIARIO (I - II)"
                    C509ImpCab(oReport, oSecCab1, oSecCab2, aCtbMoeda, STR0012, nDivide, .T.) //"APORTES DE REC. PARA O REGIME PROPRIO DE PREV. DOS SERVIDORES"
                    lCabApor := .F. //Flag para imprimir cabecalho Aporte apenas 1 vez
                Case SubStr(aSaldos[ANOATU][nI][C_CONTA], 1, 1) == "7" .And. lTotApor
                    C509ImpTot(oReport, oTotais, STR0017, aTotApor, .T.) //"TOTAL DOS APORTES DO RPS"
                    lTotApor := .F. //Flag para imprimir Totalizador Aporte apenas 1 vez    
            EndCase

            //Imprime Saldos
            If lZerados .Or.; 
                (aSaldos[ANOATU][nI][2][C_SALDOATU] > 0 .Or.; 
                    aSaldos[ANOANT][nI][2][C_SALDOATU] > 0 .Or.; 
                    aSaldos[ANOSEGANT][nI][2][C_SALDOATU] > 0)

                If SubStr(aSaldos[ANOATU][nI][C_CONTA], 1, 1) == "8" .And. lReserva
                    oReport:ThinLine()
                    oReport:SkipLine()
                    lReserva := .F.
                EndIf
                
                cIdent := IIF(aSaldos[ANOATU][nI][2][C_TIPCONTA] == "2", Space(3), "")

                oSaldos:Cell("CONTA"):SetBlock({|| cIdent + aSaldos[ANOATU][nI][2][C_DESC]}) 
                oSaldos:Cell("VAL_ATU"):SetBlock({|| Transform(aSaldos[ANOATU][nI][2][C_SALDOATU], PesqPict("CT2", "CT2_VALOR"))})
                oSaldos:Cell("VAL_ANT"):SetBlock({|| Transform(aSaldos[ANOANT][nI][2][C_SALDOATU], PesqPict("CT2", "CT2_VALOR"))})
                oSaldos:Cell("VAL_SEGANT"):SetBlock({|| Transform(aSaldos[ANOSEGANT][nI][2][C_SALDOATU], PesqPict("CT2", "CT2_VALOR"))})	
                oSaldos:PrintLine()	

                //Armazena Totalizadores
                If aSaldos[ANOATU][nI][2][C_TIPCONTA] == "2"
                    If  SubStr(aSaldos[ANOATU][nI][C_CONTA], 1, 1) $ "1|2" //Total Receitas
                        aTotRec[ANOATU] += aSaldos[ANOATU][nI][2][C_SALDOATU]
                        aTotRec[ANOANT] += aSaldos[ANOANT][nI][2][C_SALDOATU]
                        aTotRec[ANOSEGANT] += aSaldos[ANOSEGANT][nI][2][C_SALDOATU]
                        
                        //Resultado Previdenciario
                        aResult[ANOATU] += aSaldos[ANOATU][nI][2][C_SALDOATU]
                        aResult[ANOANT] += aSaldos[ANOANT][nI][2][C_SALDOATU]
                        aResult[ANOSEGANT] += aSaldos[ANOSEGANT][nI][2][C_SALDOATU]
                    ElseIf SubStr(aSaldos[ANOATU][nI][C_CONTA], 1, 1) $ "3|4" //Total Despesas
                        aTotDes[ANOATU] += aSaldos[ANOATU][nI][2][C_SALDOATU]
                        aTotDes[ANOANT] += aSaldos[ANOANT][nI][2][C_SALDOATU]
                        aTotDes[ANOSEGANT] += aSaldos[ANOSEGANT][nI][2][C_SALDOATU]

                        //Resultado Previdenciario
                        aResult[ANOATU] -= aSaldos[ANOATU][nI][2][C_SALDOATU]
                        aResult[ANOANT] -= aSaldos[ANOANT][nI][2][C_SALDOATU]
                        aResult[ANOSEGANT] -= aSaldos[ANOSEGANT][nI][2][C_SALDOATU]
                    ElseIf SubStr(aSaldos[ANOATU][nI][C_CONTA], 1, 1) $ "5|6" //Total Aportes
                        aTotApor[ANOATU] += aSaldos[ANOATU][nI][2][C_SALDOATU]
                        aTotApor[ANOANT] += aSaldos[ANOANT][nI][2][C_SALDOATU]
                        aTotApor[ANOSEGANT] += aSaldos[ANOSEGANT][nI][2][C_SALDOATU]
                    EndIf
                EndIf
            
                If nI == Len(aSaldos[ANOATU])
                    oReport:ThinLine()
                EndIf
            EndIf
        Next nI

        oSecCab1:Finish()
        oSecCab2:Finish()
        oSaldos:Finish()
        oTotais:Finish()
    EndIf
EndIf

oReport:EndPage()

//Libera o objeto de HashMap
FreeObj(oHashLin)
oHashLin := Nil

aSize(aLinAux, 0)
aSize(aSaldos, 0)
aSize(aLinhas, 0)
aSize(aCtbMoeda, 0)
aSize(aTotRec, 0)
aSize(aTotDes, 0)
aSize(aTotApor, 0)
aSize(aResult, 0)
    
aLinAux   := Nil
aSaldos   := Nil
aLinhas   := Nil
aCtbMoeda := Nil
aTotRec   := Nil
aTotDes   := Nil
aTotApor  := Nil
aResult   := Nil
    
Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} C509ImpCab

Imprime o cabecalho do relatório

@author TOTVS
@since 06/08/2020
@version 12.1.31
@return Nil
/*/
//---------------------------------------------------------------------------------------

Static Function C509ImpCab(oReport, oSecCab1, oSecCab2, aCtbMoeda, cDescCab, nDivide, lSection)

Local cDescDiv := ""
Local cAnoRef  := MV_PAR01

Default lSection := .F.

If lSection
    oSecCab1:Cell("DESC_PREV"):SetBlock({|| cDescCab})
    oReport:SkipLine()
    oSecCab1:PrintLine()
    oReport:ThinLine()
Else 
    cDescDiv := IIf(nDivide > 1, " (" + STR0005 + cValToChar(nDivide) + ")", "") //"DIV. "
    
    oSecCab1:Cell("DESC_PREV"):SetBlock({|| STR0004 + cDescDiv}) //"Anexo de Metas Fiscais - Demonstrativo IV - Receitas e Despesas Previdenciárias do RPPS"
    oSecCab1:PrintLine()
    oSecCab1:Cell("DESC_PREV"):SetBlock({|| STR0006 + cAnoRef + " (" + STR0007 + AllTrim(aCtbMoeda[2]) + " )"})  //"ANO ORCAMENTO: " #"EM:
    oSecCab1:PrintLine()
    oReport:SkipLine()
    oReport:ThinLine()

    oSecCab1:Cell("DESC_PREV"):SetBlock({|| cDescCab}) 
    oSecCab1:PrintLine()
EndIf

oSecCab2:Cell("CABEC"):SetBlock({|| STR0018}) //"ANO DE REFERENCIA"
oSecCab2:Cell("ANO_ATU"):SetBlock({|| cAnoRef})
oSecCab2:Cell("ANO_ANT"):SetBlock({|| CValToChar(Val(cAnoRef)-1)})
oSecCab2:Cell("ANO_SEGANT"):SetBlock({|| CValToChar(Val(cAnoRef)-2)})
oSecCab2:PrintLine()

If lSection
    oReport:ThinLine()
EndIf

Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} C509ImpTot

Imprime totalizadores do relatório

@author TOTVS
@since 06/08/2020
@version 12.1.31
@return Nil
/*/
//---------------------------------------------------------------------------------------

Static Function C509ImpTot(oReport, oTotais, cDescri, aTotais, lSection)

Default lSection := .F.

If lSection
    oReport:SkipLine()
    oReport:ThinLine()
EndIf

oTotais:Cell("DESCRI"):SetBlock({|| cDescri}) 
oTotais:Cell("TOT_ATU"):SetBlock({|| Transform(aTotais[ANOATU], PesqPict("CT2", "CT2_VALOR"))})
oTotais:Cell("TOT_ANT"):SetBlock({|| Transform(aTotais[ANOANT], PesqPict("CT2", "CT2_VALOR"))})
oTotais:Cell("TOT_SEGANT"):SetBlock({|| Transform(aTotais[ANOSEGANT], PesqPict("CT2", "CT2_VALOR"))})

oTotais:PrintLine()

oReport:ThinLine()

If lSection
    oReport:SkipLine()
EndIf

Return Nil