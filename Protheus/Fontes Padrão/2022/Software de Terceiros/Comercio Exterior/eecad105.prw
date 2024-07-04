#Include "EEC.CH"
#Include "EECAD105.CH"

/*
Programa        : 
Objetivo        : 
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 
Obs. 
*/

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Function EECAD105
Local cNomFile := CriaWork()
Local oReport  := ReportDef()

   oReport:PrintDialog()

TRB->(E_EraseArq(cNomFile))
Return Nil

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function CalcVal(dDataIni, dDataFim, oReport)
Local bSubMes := {|dData| SToD(StrZero(If(Month(dData) == 1, Year(dData)-1, Year(dData)), 4) + StrZero(If(Month(dData) == 1, 12, Month(dData) - 1), 2) + StrZero(Day(dData), 2)  ) }
Local aProcsAno := {}, aValores := {}, aMoedas
Local nSaldoLiq := 0
Local nInc1 := 0, nInc2 := 0
Private nMoeda  := 1, nRecno  := 1,;
        nTotEmb := 2, nContMv := 2,;
        nTotLiq := 3, nDtCred := 3,;
        nPerce  := 4, nParcs  := 4, nDtLiq := 4,;
        nVal    := 5, nDisp   := 5,;
        nBco    := 6, nEmbs   := 6,;
        nAge    := 7,;
        nCnt    := 8

   If Empty(dDataIni)
      dDataIni := dDataBase
   EndIf
   If Empty(dDataFim) .Or. dDataFim < dDataIni
      dDataFim := dDataIni
   EndIf
   
   oReport:SetMeter(24)
   For nInc1 := 1 To 24
      If Year(dDataFim) >= Year(dDataIni) .And. Month(dDataFim) > Month(dDataIni)
         --nInc1
      EndIf

      aAdd(aProcsAno, Ad103TotEmbs(dDataFim))
      aAdd(aValores, GetValRec(aProcsAno[Len(aProcsAno)]))

      dDataFim := Eval(bSubMes, dDataFim)
      oReport:IncMeter()
   Next
   
   aMoedas := GetMoedas(aValores)

   For nInc1 := 1 To Len(aMoedas)
      nSldDoisAnos  := GetSldDoisAnos(aValores, aMoedas[nInc1])
      nTotLiqAnoAnt := GetTotLiqAnoAnt(aValores, aMoedas[nInc1])

      For nInc2 := 0 To Len(aValores) - 24

         TRB->(DbAppend())
         TRB->TRB_MOEDA := aMoedas[nInc1]
         TRB->TRB_MES   := GetMesAtu(nInc2, dDataIni)

         nSaldoLiq := nTotLiqAnoAnt - nSldDoisAnos
         If nSaldoLiq < 0
            nSaldoLiq := 0
         EndIf
         
         nValToInt := Round(0.7 * GetValEmb12Ant(aValores, aMoedas[nInc1], Len(aValores) - 12 - nInc2), AvSx3("EYR_VALOR", AV_DECIMAL))
         
         If nValToInt < nSaldoLiq
            TRB->TRB_SALDO := 0
         Else
            TRB->TRB_SALDO := nValToInt - nSaldoLiq
         EndIf

         If nInc2 + 1 < Len(aValores) - 23
            nSldDoisAnos  -= GetSldMes(aValores[Len(aValores) - nInc2], aMoedas[nInc1])
            nTotLiqAnoAnt -= GetTotLiqMes(aValores[Len(aValores) - 12 - nInc2], aMoedas[nInc1])

            nSldDoisAnos  += GetSldMes(aValores[Len(aValores) - 12 - nInc2], aMoedas[nInc1])
            nTotLiqAnoAnt += GetTotLiqMes(aValores[Len(aValores) - 24 - nInc2], aMoedas[nInc1])
         EndIf
      Next
   Next

Return 

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetMesAtu(nPosAtu, dData)
Local bSomaMes := {|dData| SToD(StrZero(If(Month(dData) == 12, Year(dData)+1, Year(dData)), 4) + StrZero(If(Month(dData) == 12, 01, Month(dData) + 1), 2) + StrZero(Day(dData), 2)  ) }
Local cAnoMes
Local nInc

   If nPosAtu > 0
      For nInc := 1 To nPosAtu
         dData := Eval(bSomaMes, dData)
      Next
   EndIf
   
   cAnoMes := Left(DToS(dData), 6)

Return cAnoMes

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetValEmb12Ant(aValores, cMoeda, nInc)
Local nPos
Local nTotal := 0

   If (nPos := aScan(aValores[nInc], {|x| x[nMoeda] == cMoeda })) > 0
      nTotal := aValores[nInc][nPos][2]
   EndIf

Return nTotal

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetSldDoisAnos(aValores, cMoeda)
Local nSaldo := 0
Local nInc

   For nInc := Len(aValores) To Len(aValores) - 12 Step -1
      nSaldo += GetSldMes(aValores[nInc], cMoeda)
   Next

Return nSaldo

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetSldMes(aValMes, cMoeda)
Local nPos
Local nSaldo := 0

   If (nPos := aScan(aValMes, {|x| x[nMoeda] == cMoeda })) > 0
      nSaldo := aValMes[nPos][2] - aValMes[nPos][4]
   EndIf

Return nSaldo

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetTotLiqAnoAnt(aValores, cMoeda)
Local nTotal := 0
Local nInc

   For nInc := Len(aValores) - 13 To 24 Step -1
      nTotal += GetTotLiqMes(aValores[nInc], cMoeda)
   Next

Return nTotal

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetTotLiqMes(aValMes, cMoeda)
Local nPos
Local nTotal := 0

   If (nPos := aScan(aValMes, {|x| x[nMoeda] == cMoeda })) > 0
      nTotal := aValMes[nPos][4]
   EndIf

Return nTotal

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/12/07
Revisao     : 
Obs.        :
*/
Static Function GetMoedas(aValores)
Local aMoedas := {}
Local nInc1, nInc2

   For nInc1 := 1 To Len(aValores)
      For nInc2 := 1 To Len(aValores[nInc1])
         If aScan(aMoedas, aValores[nInc1][nInc2][nMoeda]) == 0
            aAdd(aMoedas, aValores[nInc1][nInc2][nMoeda])
         EndIf
      Next
   Next

Return aMoedas

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 
*/
Static Function GetValRec(aProcs)
Local nValor := 0, nValorTot := 0
Local nInc1, nInc2, nInc3
Local aMoedas := {}

   For nInc1 := 1 To Len(aProcs)
      If (nPos := aScan(aMoedas, {|x| x[1] == aProcs[nInc1][nMoeda] })) == 0
         //                                  VALTOT, VALREC, VALLIQ
         aAdd(aMoedas, {aProcs[nInc1][nMoeda], 0, 0, 0})
         nPos := Len(aMoedas)
      EndIf      
      For nInc2 := 1 To Len(aProcs[nInc1][nEmbs])
         aMoedas[nPos][2] += aProcs[nInc1][nEmbs][nInc2][nTotEmb]
         For nInc3 := 1 To Len(aProcs[nInc1][nEmbs][nInc2][nParcs])
            aParcela := aProcs[nInc1][nEmbs][nInc2][nParcs][nInc3]
            If !Empty(aParcela[nDtCred])
               aMoedas[nPos][3] += aParcela[nVal]
            EndIf
            If !Empty(aParcela[nDtLiq])
               aMoedas[nPos][4] += aParcela[nVal]
            EndIf
         Next
      Next
   Next

Return aMoedas

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 
*/
Static Function ReportDef()
Local oReport, oSecao
Local oMoeda, oAnoMes

   //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
   aTabelas := {}

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
   aOrdem   := {}

   //Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New("EECAD105", STR0001, "EECAD5"  , {|oReport| ReportPrint(oReport)}, "")//"Follow-up de Recursos no Exterior"

   //Define a seção do relatório
   oSecao := TRSection():New(oReport, "MAIN", aTabelas, aOrdem)

   //Definição das colunas de impressão da seção
   oMoeda  := TRCell():New(oSecao, "TRB_MOEDA" , "TRB", "Moeda"               , /*Picture*/     , /*Size*/, /*lPixel*/, /*bBlock*/)
   oAnoMes := TRCell():New(oSecao, "TRB_MES"   , "TRB", "Ano/Mes"             , AvSx3("EYR_ANOMES", AV_PICTURE)     , /*Size*/, /*lPixel*/, /*bBlock*/)
   TRCell():New(oSecao, "TRB_SALDO" , "TRB", "Saldo a Internar"    , AvSx3("EYR_VALOR", AV_PICTURE)     , /*Size*/, /*lPixel*/, /*bBlock*/)
   
   TRBreak():New (oSecao, oAnoMes)
   
   //Força a exibição dos perguntes
   Pergunte("EECAD5")
   
   //Não imprime os perguntes
   oReport:lParamPage := .F.

Return oReport

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 
*/
Static Function ReportPrint(oReport)
Local oSection := oReport:Section("MAIN")

   CalcVal(MV_PAR01, MV_PAR02, oReport)
   
   TRB->(DbGoTop())
   oSection:Init()
   While TRB->(!Eof()) .And. !oReport:Cancel()
      oSection:PrintLine() //Impressão da linha
      TRB->(DbSkip())
   EndDo
   oSection:Finish()

Return .T.

/*
Funcao     : 
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 
*/
Static Function CriaWork()
Local cNomFile
Local aSemSx3 := {}
Private aHeader, aCampos

   aSemSx3 := {}
   aAdd(aSemSx3, {"TRB_MOEDA" , "C", AvSx3("EEC_MOEDA", AV_TAMANHO), 0})
   aAdd(aSemSx3, {"TRB_MES"   , "C", 6, 0})
   aAdd(aSemSx3, {"TRB_SALDO" , "N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   
   cNomFile := E_CriaTrab(, aSemSx3, "TRB")
   
Return cNomFile