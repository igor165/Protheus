#Include "PROTHEUS.CH"
#Include "CTBR514P.CH"

#DEFINE ANOANT     1
#DEFINE PRIQUAD    2
#DEFINE SEGQUAD    3
#DEFINE TERQUAD    4

#DEFINE C_CONTA	   1
#DEFINE C_DESC	   1
#DEFINE C_SALDOATU 2
#DEFINE C_ITHASH   2
#DEFINE C_TIPCONTA 3

#DEFINE POS_GC     1 
#DEFINE POS_RCL    2 

//-------------------------------------------------------------------
/*{Protheus.doc} CTBR514P
Relatorio LRF - Demonstrativo das Garantias Concedidas e Contragarantias 
Recebidas

@author Totvs
   
@version P12
@since   13/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CTBR514P()

Local oReport       := Nil
Local cPerg         := "CTR514P"
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
//³ MV_PAR06    Limite para RCL:           						        ³
//³ MV_PAR07    Limite Alerta:						                    ³
//³ MV_PAR08    Divide Por:         			    					³
//³ MV_PAR09    Seleciona Filiais:     			    					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX1->(dbSetOrder(1))

If GetRpoRelease() < "12.1.023"
    Help(,, "Help",, OemToAnsi(STR0001), 1, 0) //"Relatorio Demonstrativo das Garantias Concedidas e Contragarantias Recebidas disponível a partir da versao 12.1.23"
    lContinua := .F.
ElseIf !SX1->(dbSeek(Padr(cPerg, Len(SX1->X1_GRUPO), " ")))
    Help(,, "Help",, OemToAnsi(STR0002), 1, 0) //"Para utilizaçao do relatorio Demonstrativo das Garantias Concedidas e Contragarantias Recebidas é necessário aplicar o pacote acumulado da controladoria."
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
@since   13/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg, aSelFil, aSetOfBook)

Local oReport   := Nil
Local oSecCab   := Nil
Local oSaldos   := Nil
Local oBorder   := Nil
Local cNomeProg := "CTBR514P"
Local cDescri   := OemToAnsi(STR0003) //"Este programa ira imprimir o Relatorio Demonstrativo das Garantias Concedidas e Contragarantias Recebidas."	
Local cTitulo 	:= STR0004 //"Demonstrativo das Garantias Concedidas e Contragarantias Recebidas"

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
TRCell():New(oSaldos, "DESC_CONTA",, STR0005                            , PesqPict("CTS", "CTS_DESCCG"), TamSx3("CTS_DESCCG")[1]+10, /*lPixel*/, /*CodeBlock*/, "LEFT" , .T., "LEFT",, 5) //"Garantias Concedidas e Contragarantias Recebidas"    
TRCell():New(oSaldos, "VAL_ANT"   ,, STR0006 + CHR(13)+CHR(10) + STR0007, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Saldo do" #"Exercício Anterior"
TRCell():New(oSaldos, "VAL_PRI"   ,, STR0008 + CHR(13)+CHR(10) + STR0009, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Saldo até o" #"1. Quadrimestre"
TRCell():New(oSaldos, "VAL_SEG"   ,, STR0008 + CHR(13)+CHR(10) + STR0010, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Saldo até o" #"2. Quadrimestre"
TRCell():New(oSaldos, "VAL_TERC"  ,, STR0008 + CHR(13)+CHR(10) + STR0011, PesqPict("CT2", "CT2_VALOR") , TamSx3("CT2_VALOR")[1]    , /*lPixel*/, /*CodeBlock*/, "RIGHT", .T., "RIGHT")    //"Saldo até o" #"3. Quadrimestre"
oSaldos:SetLinesBefore(0)

Return oReport

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Definicao do objeto do relatorio personalizavel e das secoes que serao 
utilizadas 

@author Totvs
   
@version P12
@since   13/10/2020
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
Local aLimites   := {{0,0,0,0}, {0,0,0,0}}
Local aSetOfBook := CTBSetOf(MV_PAR02)
Local lRet       := .T.
Local lLimites   := .T.
Local lTotal     := .T.
Local lZerados   := MV_PAR05 == 1

Private lComNivel	:= .T. //Variável utilizada no CTBXSAL para retornar o campo NIVEL

If Empty(aSetOfBook[5])
	MsgAlert(STR0012)  //"Os demonstrativos das garantias concedidas e contragarantias recebidas obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
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
            cDescPer := STR0013 + cAnoRef //"Primeiro Quadrimestre de "
        ElseIf nI == 3 //Segundo Quadrimestre do Ano Referencia
            dDataIni := StoD(cAnoRef + "0501") 
            dDataFim := LastDay(StoD(cAnoRef + "0801"))
            cDescPer := STR0014 + cAnoRef //"Segundo Quadrimestre de "
        ElseIf nI == 4 //Terceiro Quadrimestre do Ano Referencia
            dDataIni := StoD(cAnoRef + "0901") 
            dDataFim := LastDay(StoD(cAnoRef + "1201"))
            cDescPer := STR0015 + cAnoRef //"Terceiro Quadrimestre de "
        EndIf

        //Monta Arquivo Temporario para Impressao
        MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
                    CTGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp, dDataIni, dDataFim, "", "", "",;
                              Repl("Z", Len(CT1->CT1_CONTA)), "", Repl("Z", Len(CTT->CTT_CUSTO)), "",; 
                              Repl("Z", Len(CTD->CTD_ITEM)), "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda,; 
                              cTpSld, aSetOfBook, Space(2), Space(20), Repl("Z", 20), Space(30),,,,,,,;
                              nDivide,,,,,,,,,,,,,,,,,,,,,,,,,, cMoeda, .T., aSelFil)}, STR0016 + cDescPer, cTitulo) //"Carregando valores de "

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
        oReport:OnPageBreak({|| C514ImpCab(oReport, oSecCab, aCtbMoeda, nDivide)})

        For nI := 1 To Len(aSaldos[ANOANT])
            //Imprime Saldos
            If lZerados .Or.; 
                (aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU] > 0 .Or.; 
                    aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU] > 0 .Or.; 
                    aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU] > 0 .Or.;
                    aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU] > 0)

                //Habilita campos de saldos para impressao
                oSaldos:Cell("VAL_ANT"):Show()
                oSaldos:Cell("VAL_PRI"):Show()
                oSaldos:Cell("VAL_SEG"):Show()
                oSaldos:Cell("VAL_TERC"):Show()

                //Imprime totalizador e limites 
                If lTotal .And. SubStr(aSaldos[ANOANT][nI][C_CONTA], 1, 1) == "2" 
                    C514ImpTot(oReport, oSaldos, aLimites, .T.) //Imprime Totalizador Garantias Concedidas
                    lTotal := .F.	//Flag para impressao de totalizador apenas 1 vez
                ElseIf lLimites .And. SubStr(aSaldos[ANOANT][nI][C_CONTA], 1, 1) == "3" 
                    C514ImpTot(oReport, oSaldos, aLimites, .F.) //Imprime % e Limites de Alerta
                    lLimites := .F.	//Flag para impressao de limites apenas 1 vez
                EndIf

                //Desabilita campos saldos para impressao qd sintetica Garantias Concedidas
                //ou sintetica ContraGarantias Recebidas, esses valores estao nos Totalizadores
                If aSaldos[ANOANT][nI][2][C_TIPCONTA] == "1" .And.; 
                    (AllTrim(aSaldos[ANOANT][nI][C_CONTA]) == "1" .Or. AllTrim(aSaldos[ANOANT][nI][C_CONTA]) == "3")

                     oSaldos:Cell("VAL_ANT"):Hide()
                     oSaldos:Cell("VAL_PRI"):Hide()
                     oSaldos:Cell("VAL_SEG"):Hide()
                     oSaldos:Cell("VAL_TERC"):Hide()   
                EndIf

                oSaldos:Cell("DESC_CONTA"):SetBlock({|| aSaldos[ANOANT][nI][C_ITHASH][C_DESC]}) 
                oSaldos:Cell("VAL_ANT"):SetBlock({|| aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU]})
                oSaldos:Cell("VAL_PRI"):SetBlock({|| aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU]})
                oSaldos:Cell("VAL_SEG"):SetBlock({|| aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU]})	
                oSaldos:Cell("VAL_TERC"):SetBlock({|| aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU]})
                oSaldos:PrintLine()

                /* Posicoes Array aLimites
                    [1] - Total Garantias Concedidas
                    [2] - Receita Corrente Liquida */

                If aSaldos[ANOANT][nI][2][C_TIPCONTA] == "2"
                    If SubStr(aSaldos[ANOANT][nI][C_CONTA], 1, 1) == "1" //Total Garantias Concedidas
                        aLimites[POS_GC][ANOANT]  += aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_GC][PRIQUAD] += aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_GC][SEGQUAD] += aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_GC][TERQUAD] += aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU]
                    ElseIf SubStr(aSaldos[ANOANT][nI][C_CONTA], 1, 1) == "2" //Receita Corrente Liquida
                        aLimites[POS_RCL][ANOANT]  += aSaldos[ANOANT][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_RCL][PRIQUAD] += aSaldos[PRIQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_RCL][SEGQUAD] += aSaldos[SEGQUAD][nI][C_ITHASH][C_SALDOATU]
                        aLimites[POS_RCL][TERQUAD] += aSaldos[TERQUAD][nI][C_ITHASH][C_SALDOATU]
                    EndIf
                EndIf
            EndIf
        Next nI

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
/*/{Protheus.doc} C514ImpCab

Imprime o cabecalho do relatório

@author TOTVS
@since 13/10/2020
@version 12.1.31
@return Nil
/*/
//---------------------------------------------------------------------------------------

Static Function C514ImpCab(oReport, oSecCab, aCtbMoeda, nDivide)

Local cDescDiv := ""
Local cAnoRef  := MV_PAR01

cDescDiv := IIf(nDivide > 1, " (" + STR0017 + cValToChar(nDivide) + ")", "") //"DIV. "

If ValType(aCtbMoeda) == "A"    
    oSecCab:Cell("DESC_DEM"):SetBlock({|| STR0004 + cDescDiv}) //"Demonstrativo das Garantias Concedidas e Contragarantias Recebidas"
    oSecCab:PrintLine()
    oSecCab:Cell("DESC_DEM"):SetBlock({|| STR0018 + cAnoRef + " (" + STR0019 + AllTrim(aCtbMoeda[2]) + " )"})  //"EXERCICIO: " #"EM: "
    oSecCab:PrintLine()
    oReport:ThinLine()
    oReport:SkipLine()
EndIf

Return Nil

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} C514ImpTot

Imprime as linhas responsaveis pelos Totalizadores e Limites de Alerta

@author TOTVS
@since 13/10/2020
@version 12.1.31
@return Nil
/*/
//---------------------------------------------------------------------------------------

Static Function C514ImpTot(oReport, oSaldos, aLimites, lTotal)

Local nI        := 0
Local nLimRCL   := MV_PAR06 //Limite para RCL         						        
Local nLimAlert := MV_PAR07 //Limite para Alerta						                   

If lTotal //Imprime totalizador
    oSaldos:Cell("DESC_CONTA"):SetBlock({|| STR0020}) //"TOTAL DAS GARANTIAS CONCEDIDAS"
    oSaldos:Cell("VAL_ANT"):SetBlock({||  aLimites[POS_GC][ANOANT]})
    oSaldos:Cell("VAL_PRI"):SetBlock({||  aLimites[POS_GC][PRIQUAD]})
    oSaldos:Cell("VAL_SEG"):SetBlock({||  aLimites[POS_GC][SEGQUAD]})	
    oSaldos:Cell("VAL_TERC"):SetBlock({|| aLimites[POS_GC][TERQUAD]})
    oSaldos:PrintLine()
Else //Imprime limites
    For nI := 1 To 3
        If nI == 1
            oSaldos:Cell("DESC_CONTA"):SetBlock({|| STR0021}) //"% do TOTAL DAS GARANTIAS SOBRE A RCL"
            oSaldos:Cell("VAL_ANT"):SetBlock({||  (aLimites[POS_GC][ANOANT]  / aLimites[POS_RCL][ANOANT])  * 100})
            oSaldos:Cell("VAL_PRI"):SetBlock({||  (aLimites[POS_GC][PRIQUAD] / aLimites[POS_RCL][PRIQUAD]) * 100})
            oSaldos:Cell("VAL_SEG"):SetBlock({||  (aLimites[POS_GC][SEGQUAD] / aLimites[POS_RCL][SEGQUAD]) * 100})	
            oSaldos:Cell("VAL_TERC"):SetBlock({|| (aLimites[POS_GC][TERQUAD] / aLimites[POS_RCL][TERQUAD]) * 100})
        ElseIf nI == 2
            oSaldos:Cell("DESC_CONTA"):SetBlock({|| STR0022}) //"LIMITE DEFINIDO POR RESOLUCAO DO SENADO FEDERAL"
            oSaldos:Cell("VAL_ANT"):SetBlock({||  aLimites[POS_RCL][ANOANT]  * nLimRCL})
            oSaldos:Cell("VAL_PRI"):SetBlock({||  aLimites[POS_RCL][PRIQUAD] * nLimRCL})
            oSaldos:Cell("VAL_SEG"):SetBlock({||  aLimites[POS_RCL][SEGQUAD] * nLimRCL})	
            oSaldos:Cell("VAL_TERC"):SetBlock({|| aLimites[POS_RCL][TERQUAD] * nLimRCL})
        Else
            oSaldos:Cell("DESC_CONTA"):SetBlock({|| STR0023}) //"LIMITE DE ALERTA"
            oSaldos:Cell("VAL_ANT"):SetBlock({||  ((aLimites[POS_RCL][ANOANT]  * nLimRCL) * nLimAlert) / 100})
            oSaldos:Cell("VAL_PRI"):SetBlock({||  ((aLimites[POS_RCL][PRIQUAD] * nLimRCL) * nLimAlert) / 100})
            oSaldos:Cell("VAL_SEG"):SetBlock({||  ((aLimites[POS_RCL][SEGQUAD] * nLimRCL) * nLimAlert) / 100})	
            oSaldos:Cell("VAL_TERC"):SetBlock({|| ((aLimites[POS_RCL][TERQUAD] * nLimRCL) * nLimAlert) / 100})
        EndIf
        
        oSaldos:PrintLine()
    Next nI

    oReport:SkipLine()
EndIf

Return Nil