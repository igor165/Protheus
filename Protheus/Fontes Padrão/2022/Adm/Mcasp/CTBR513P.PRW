#Include "PROTHEUS.CH"
#Include "CTBR513P.CH"

#DEFINE ANOANT     1
#DEFINE PRIQUAD    2
#DEFINE SEGQUAD    3
#DEFINE TERQUAD    4

#DEFINE C_CONTA	   1
#DEFINE C_DESC	   1
#DEFINE C_SALDOATU 2
#DEFINE C_ITHASH   2
#DEFINE C_TIPCONTA 3

#DEFINE POS_DC     1 
#DEFINE POS_DCL    2
#DEFINE POS_RCL    3 

//-------------------------------------------------------------------
/*{Protheus.doc} CTBR513P
Relatorio LRF - Demonstrativo da Dívida Consolidada Liquida - DCL
Proprio da Previdencia

@author Totvs
   
@version P12
@since   05/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CTBR513P()

Local oReport       := Nil
Local cPerg         := "CTR513P"
Local aSetOfBook    := {}
Local aCtbMoeda		:= {}
Local aSelFil		:= {}
Local lContinua     := .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_PAR01    Ano de Referencia:        								³
//³ MV_PAR02    Cod Config Livros:       				                ³
//³ MV_PAR03    Moeda:                  								³
//³ MV_PAR04    Tipo de Saldo:     				    					³
//³ MV_PAR05    Saldos Zerados:     			    					³
//³ MV_PAR06    Limite para DCL:           						        ³
//³ MV_PAR07    Limite Alerta:						                    ³
//³ MV_PAR08    Divide Por:         			    					³
//³ MV_PAR09    Seleciona Filiais:     			    					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0001), 1, 0) //"Relatorio Demonstrativo da Divida Consolidada Liquida disponível a partir da versao 12.1.23"
    lContinua := .F.
ElseIf !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi(STR0002), 1, 0) //"Para utilizaçao do relatorio Demonstrativo da Divida Consolidada Liquida é necessário aplicar o pacote acumulado da controladoria."
    lContinua := .F.
Else 
    //Perguntas do Relatório
    lContinua := Pergunte(cPerg, .T.) 
EndIf   

//Faz a validacao das filiais
If lContinua .And. MV_PAR09 == 1 .And. Len(aSelFil) <= 0 
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
@since   05/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg, aSelFil, aSetOfBook)

Local oReport   := Nil
Local oSecCab   := Nil
Local oSaldos   := Nil
Local oBorder   := Nil
Local cNomeProg := "CTBR513P"
Local cDescri   := OemToAnsi(STR0003) //"Este programa ira imprimir o Relatorio Demonstrativo da Divida Consolidada Liquida."	
Local cTitulo 	:= STR0004 //"Demonstrativo da Divida Consolidada Liquida"

oReport := TReport():New(cNomeProg, cTitulo, cPerg, {|oReport| Pergunte(cPerg, .F.), IIf(ReportPrint(oReport, cTitulo, aSelFil), .T., oReport:CancelPrint())}, cDescri)
oReport:SetTotalInLine(.T.)
oReport:ParamReadOnly(.T.)

//Configuracoes de impressao
oReport:nFontBody   := 9 //Define o tamanho da fonte
oReport:nLineHeight	:= 45 //Define a altura da linha.
oReport:CFONTBODY   := "Arial Narrow"

oBorder := TRBorder():New(oReport, 5,, 0)

oSecCab := TRSection():New(oReport, "SECCAB", {}, /*aOrdem*/)
TRCell():New(oSecCab, "DESC_DEM",, "" /*Titulo*/, /*Picture*/, 100 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "CENTER" /*cAlign*/, /*lLineBreak*/,,,, .T.,,, .T.)
oSecCab:oHBrdBottom := oBorder //Remove a borda do cabecalho

oSaldos := TRSection():New(oReport, "SALDOS",, /*aOrdem*/)
TRCell():New(oSaldos, "DESC_CONTA",, STR0005, PesqPict("CTS", "CTS_DESCCG"), TamSx3("CTS_DESCCG")[1]+10, /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT",, 5) //"Divida Consolidada"    
TRCell():New(oSaldos, "VAL_ANT"   ,, STR0006, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Saldo do Exercício Anterior"
TRCell():New(oSaldos, "VAL_PRI"   ,, STR0007, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Até o 1. Quadrimestre"
TRCell():New(oSaldos, "VAL_SEG"   ,, STR0008, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Até o 2. Quadrimestre"
TRCell():New(oSaldos, "VAL_TERC"  ,, STR0009, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Até o 3. Quadrimestre"
oSaldos:SetLinesBefore(0)

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao 
utilizadas 

@author Totvs
   
@version P12
@since   06/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport, cTitulo, aSelFil)

Local oSecCab    := oReport:Section("SECCAB")
Local oSaldos    := oReport:Section("SALDOS")
Local oHashLin   := tHashMap():New()
Local cArqTmp	 := ""
Local cDescPer   := ""
Local cAnoRef    := MV_PAR01
Local cMoeda     := MV_PAR03
Local cTpSld     := MV_PAR04
Local nI         := 0
Local nSaldoAtu  := 0
Local nDivide    := 1 
Local dDataIni   := StoD("")
Local dDataFim   := StoD("")
Local aLinhas    := {}
Local aLinAux    := {}
Local aCtbMoeda	 := {}
Local aSaldos    := {}
Local aLimites   := {{0,0,0,0}, {0,0,0,0}, {0,0,0,0}}
Local aSetOfBook := CTBSetOf(MV_PAR02)
Local lRet       := .T.
Local lLimites   := .F.
Local lZerados   := MV_PAR05 == 1

Private lComNivel	:= .T. //Variável utilizada no CTBXSAL para retornar o campo NIVEL

If Empty(aSetOfBook[5])
	MsgAlert(STR0010)  //"Os demonstrativos da dívida consolidada liquida obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	lRet := .F.
Else
    //Divide por
    If MV_PAR08 == 2     //Divide por cem
        nDivide := 100
    ElseIf MV_PAR08 == 3 //Divide por mil
        nDivide := 1000
    ElseIf MV_PAR08 == 4 //Divide por milhao
        nDivide := 1000000
    EndIf

    aSetOfBook[9] := nDivide
    aCtbMoeda := CtbMoeda(cMoeda, nDivide)
   
    For nI := 1 To 4
        cArqTmp := ""
	    
        If nI == 1 //Ano anterior
            dDataIni := StoD(CValToChar(Val(cAnoRef) - 1) + "0101") 
            dDataFim := LastDay(StoD(CValToChar(Val(cAnoRef) - 1) + "1201"))
            cDescPer := CValToChar(Val(cAnoRef) - 1) 
        ElseIf nI == 2 //Primeiro Quadrimestre do Ano Referencia
            dDataIni := StoD(cAnoRef + "0101") 
            dDataFim := LastDay(StoD(cAnoRef + "0401"))
            cDescPer := STR0011 + cAnoRef //"Primeiro Quadrimestre de "
        ElseIf nI == 3 //Segundo Quadrimestre do Ano Referencia
            dDataIni := StoD(cAnoRef + "0501") 
            dDataFim := LastDay(StoD(cAnoRef + "0801"))
            cDescPer := STR0012 + cAnoRef //"Segundo Quadrimestre de "
        ElseIf nI == 4 //Terceiro Quadrimestre do Ano Referencia
            dDataIni := StoD(cAnoRef + "0901") 
            dDataFim := LastDay(StoD(cAnoRef + "1201"))
            cDescPer := STR0013 + cAnoRef //"Terceiro Quadrimestre de "
        EndIf

        //Monta Arquivo Temporario para Impressao
        MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
                    CTGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, dDataIni, dDataFim, "", "", "",;
                              Repl("Z", Len(CT1->CT1_CONTA)), "", Repl("Z", Len(CTT->CTT_CUSTO)), "",; 
                              Repl("Z", Len(CTD->CTD_ITEM)), "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda,; 
                              cTpSld, aSetOfBook, Space(2), Space(20), Repl("Z", 20), Space(30),,,,,,,;
                              nDivide,,,,,,,,,,,,,,,,,,,,,,,,,, cMoeda, .T., aSelFil)}, STR0014 + cDescPer, cTitulo) //"Carregando valores de "

        dbSelectArea("cArqTmp")
        dbGoTop()
         
        While !Eof()
            If !oHashLin:Get(CONTA, @aLinAux)            
                nSaldoAtu := Abs(SALDOATU) - Abs(MOVPERANT) 
                HMSet(oHashLin, CONTA, { DESCCTA,;	  //[1] Descricao da Conta
                                         nSaldoAtu,;  //[2] Saldo da Conta
                                         TIPOCONTA }) //[3] Tipo da Conta
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
    Next nI

    If Len(aSaldos) > 0
        oSecCab:Init()
        oSaldos:Init()
        oReport:OnPageBreak({|| C513ImpCab(oReport, oSecCab, aCtbMoeda, nDivide)})

        For nI := 1 To Len(aSaldos[ANOANT])
            //Imprime Saldos
            If lZerados .Or.; 
                (aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU] > 0 .Or.; 
                    aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU] > 0 .Or.; 
                    aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU] > 0 .Or.;
                    aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU] > 0)

                oSaldos:Cell("DESC_CONTA"):SetBlock({|| aSaldos[ANOANT][nI][C_ITHASH][C_DESC]}) 
                oSaldos:Cell("VAL_ANT"):SetBlock({|| aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU]})
                oSaldos:Cell("VAL_PRI"):SetBlock({|| aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU]})
                oSaldos:Cell("VAL_SEG"):SetBlock({|| aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU]})	
                oSaldos:Cell("VAL_TERC"):SetBlock({|| aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU]})
                oSaldos:PrintLine()

                /* Posicoes Array aLimites
                    [1] - Divida Consolidada
                    [2] - Divida Consolidada Liquida
                    [3] - Receita Corrente Liquida */

                If aSaldos[ANOANT][nI][2][C_TIPCONTA] == "2"
                    If SubStr(aSaldos[ANOANT][nI][C_CONTA], 1, 1) == "1" //Divida Consolidada
                        aLimites[POS_DC][ANOANT]  += aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_DC][PRIQUAD] += aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_DC][SEGQUAD] += aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_DC][TERQUAD] += aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU]
                    ElseIf SubStr(aSaldos[ANOANT][nI][C_CONTA], 1, 1) == "3" //Divida Consolidada Liquida
                        aLimites[POS_DCL][ANOANT]  += aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_DCL][PRIQUAD] += aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_DCL][SEGQUAD] += aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_DCL][TERQUAD] += aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU]
                    ElseIf SubStr(aSaldos[ANOANT][nI][C_CONTA], 1, 1) == "4" //Receita Corrente Liquida
                        aLimites[POS_RCL][ANOANT]  += aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_RCL][PRIQUAD] += aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_RCL][SEGQUAD] += aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_RCL][TERQUAD] += aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU]
                    EndIf
                EndIf

                lLimites := .T.	
            EndIf
        Next nI

        //Imprime % e Limites de Alerta
        If lLimites 
            C513ImpLim(oSaldos, aLimites)  
        EndIf

        oSecCab:Finish()
        oSaldos:Finish()
    EndIf
EndIf

oReport:EndPage()

//Libera o objeto de HashMap
FreeObj(oHashLin)
oHashLin := Nil

aSize(aLinAux,   0)
aSize(aSaldos,   0)
aSize(aLinhas,   0)
aSize(aCtbMoeda, 0)
aSize(aLimites,  0)
    
aLinAux   := Nil
aSaldos   := Nil
aLinhas   := Nil
aCtbMoeda := Nil
aLimites  := Nil
    
Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} C513ImpCab

Imprime o cabecalho do relatório

@author TOTVS
@since 06/10/2020
@version 12.1.31
@return Nil
/*/
//---------------------------------------------------------------------------------------

Static Function C513ImpCab(oReport, oSecCab, aCtbMoeda, nDivide)

Local cDescDiv := ""
Local cAnoRef  := MV_PAR01

cDescDiv := IIf(nDivide > 1, " (" + STR0015 + cValToChar(nDivide) + ")", "") //"DIV. "

If ValType(aCtbMoeda) == "A"    
    oSecCab:Cell("DESC_DEM"):SetBlock({|| STR0004 + cDescDiv}) //"Demonstrativo da Divida Consolidada Liquida"
    oSecCab:PrintLine()
    oSecCab:Cell("DESC_DEM"):SetBlock({|| STR0016 + cAnoRef + " (" + STR0017 + AllTrim(aCtbMoeda[2]) + " )"})  //"EXERCICIO: " #"EM: "
    oSecCab:PrintLine()
    oReport:ThinLine()
    oReport:SkipLine()
EndIf

Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} C513ImpLim

Imprime as linhas responsaveis pelos Limites de Alerta

@author TOTVS
@since 06/10/2020
@version 12.1.31
@return Nil
/*/
//---------------------------------------------------------------------------------------

Static Function C513ImpLim(oSaldos, aLimites)

Local nI        := 0
Local nLimDCL   := MV_PAR06 //Limite para DCL         						        
Local nLimAlert := MV_PAR07 //Limite para Alerta						                   

For nI := 1 To 4
    If nI == 1
        oSaldos:Cell("DESC_CONTA"):SetBlock({|| STR0018}) //"% DA DC SOBRE A RCL"
        oSaldos:Cell("VAL_ANT"):SetBlock({||  (aLimites[POS_DC][ANOANT]  / aLimites[POS_RCL][ANOANT])  * 100})
        oSaldos:Cell("VAL_PRI"):SetBlock({||  (aLimites[POS_DC][PRIQUAD] / aLimites[POS_RCL][PRIQUAD]) * 100})
        oSaldos:Cell("VAL_SEG"):SetBlock({||  (aLimites[POS_DC][SEGQUAD] / aLimites[POS_RCL][SEGQUAD]) * 100})	
        oSaldos:Cell("VAL_TERC"):SetBlock({|| (aLimites[POS_DC][TERQUAD] / aLimites[POS_RCL][TERQUAD]) * 100})
    ElseIf nI == 2
        oSaldos:Cell("DESC_CONTA"):SetBlock({|| STR0019}) //"% DA DCL SOBRE A RCL"
        oSaldos:Cell("VAL_ANT"):SetBlock({||  (aLimites[POS_DCL][ANOANT]  / aLimites[POS_RCL][ANOANT])  * 100})
        oSaldos:Cell("VAL_PRI"):SetBlock({||  (aLimites[POS_DCL][PRIQUAD] / aLimites[POS_RCL][PRIQUAD]) * 100})
        oSaldos:Cell("VAL_SEG"):SetBlock({||  (aLimites[POS_DCL][SEGQUAD] / aLimites[POS_RCL][SEGQUAD]) * 100})	
        oSaldos:Cell("VAL_TERC"):SetBlock({|| (aLimites[POS_DCL][TERQUAD] / aLimites[POS_RCL][TERQUAD]) * 100})
    ElseIf nI == 3
        oSaldos:Cell("DESC_CONTA"):SetBlock({|| STR0020}) //"LIMITE DEFINIDO POR RESOLUCAO DO SENADO FEDERAL"
        oSaldos:Cell("VAL_ANT"):SetBlock({||  aLimites[POS_RCL][ANOANT]  * nLimDCL})
        oSaldos:Cell("VAL_PRI"):SetBlock({||  aLimites[POS_RCL][PRIQUAD] * nLimDCL})
        oSaldos:Cell("VAL_SEG"):SetBlock({||  aLimites[POS_RCL][SEGQUAD] * nLimDCL})	
        oSaldos:Cell("VAL_TERC"):SetBlock({|| aLimites[POS_RCL][TERQUAD] * nLimDCL})
    Else
        oSaldos:Cell("DESC_CONTA"):SetBlock({|| STR0021}) //"LIMITE DE ALERTA"
        oSaldos:Cell("VAL_ANT"):SetBlock({||  ((aLimites[POS_RCL][ANOANT]  * nLimDCL) * nLimAlert) / 100})
        oSaldos:Cell("VAL_PRI"):SetBlock({||  ((aLimites[POS_RCL][PRIQUAD] * nLimDCL) * nLimAlert) / 100})
        oSaldos:Cell("VAL_SEG"):SetBlock({||  ((aLimites[POS_RCL][SEGQUAD] * nLimDCL) * nLimAlert) / 100})	
        oSaldos:Cell("VAL_TERC"):SetBlock({|| ((aLimites[POS_RCL][TERQUAD] * nLimDCL) * nLimAlert) / 100})
    EndIf
    
    oSaldos:PrintLine()
Next nI

Return Nil