#include "protheus.ch"
#include "msgraphi.ch"  
#include "eecpg01.ch"

********************************************************************************************************
Function EECPG01()
********************************************************************************************************

 Local aRetPanel    := {}                    ,;
       TypeGraph    := GRP_BAR               ,;
       bClickG      := {||  }                ,;
       aEixoX       := {}                    ,;
       aIndicadores := {}                    ,;  //"Valor Exportado (em mil US$)"STR0001
       aValores     := {}                    ,;
       aPeriodo     := {}
 Local nInd
   // TypeGraph    : Tipo do Gráfico ( GRP_LINE, GRP_PIE, GRP_BAR )
   // bClickG      : Bloco de Código a ser executado no clique do gráfico 
   // aEixoX       : Array contendo os atributos a serem exibidos 
   // aIndicadores : Array contendo os nomes dos indicadores 
   // aValores     : Array multidimensional contendo os valores dos indicadores

   Private cMoeDolar := EasyGParam("MV_EECUSS",,"US$")
   Private nTxDolar  := BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.)
   
   //AOM - 01/09/10
   Pergunte("EECPGOL1",.F.)
   EECPG01ExX(@aEixoX,@aPeriodo)
   //AOM - 01/09/10 - Adicionando os meses indicadores de acordo com o parametro informado
   For nInd := 1  to  Len(aEixoX)
         AAdd( aIndicadores,{})
         AAdd( aIndicadores[nInd], aEixoX[nInd] )
         AAdd( aValores, {} )
   Next nInd
   aValores  := EECPG01Vlr(aPeriodo,@aValores)
   aRetPanel := { TypeGraph, bClickG, aEixoX, aIndicadores, aValores  }

Return aRetPanel


********************************************************************************************************
Static Function EECPG01ExX(aEixoX,aPeriodo)
********************************************************************************************************

 Local nMesIni := 0                 ,;
       nAnoIni := 0                 ,;
       nMesFim := 0                 ,;
       nAnoFim := 0                 ,;
       dDtIni  := CToD("  /  /  ")  ,;
       dDtFim  := CToD("  /  /  ")  ,;
       aData     := {}              ,;
       cDataBase := ""              ,;
       cIdioma   := ""              ,;
       nCont     := 1

   if FwRetIdiom() == "es"
      cIdioma := "ESP.  -ESPANHOL          "
   else
      if FwRetIdiom() == "en"
         cIdioma := "INGLES-INGLES"
      else
         cIdioma := IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES         "
      endif
   endif

   If Empty(mv_par01)  .Or.  Empty(mv_par02)
      cDataBase := DToS(dDataBase)
      nMesFim := Val(SubStr(cDataBase,5,2))
      nAnoFim := Val(SubStr(cDataBase,3,2))
      If nMesFim < 6
         nMesIni := nMesFim + 7
         nAnoIni := nAnoFim - 1
      Else
         nMesIni := nMesFim - 5
         nAnoIni := nAnoFim
      EndIf
   Else
      nMesIni := Val(Left( mv_par01,2))
      nAnoIni := Val(Right(mv_par01,2))
      nMesFim := Val(Left( mv_par02,2))
      nAnoFim := Val(Right(mv_par02,2))
   EndIf

   Do While IIF( nAnoIni < nAnoFim , nAnoIni < nAnoFim , nAnoIni == nAnoFim  .And.  nMesIni <= nMesFim )
      dDtIni := CToD("01/"+StrZero(nMesIni,2)+"/"+StrZero(nAnoIni,2))
      If nMesIni == 12
         dDtFim := CToD("31/12"+"/"+StrZero(nAnoIni,2))
      Else
         dDtFim := CToD("01/"+StrZero(nMesIni+1,2)+"/"+StrZero(nAnoIni,2))-1
      EndIf

      AAdd( aPeriodo , {dDtIni,dDtFim} )
      aData := DataExtenso(dDtIni,cIdioma)
      //AOM - 01/09/10
      AAdd(aEixoX,{})                                                       //DFS - Adicionado o campo moeda no painel de gestão.
      AAdd( aEixoX[nCont], Left(aData[1],3)+"/"+Right(aData[3],2) + " - " + AllTrim(cMoeDolar) )
      If nMesIni == 12
         nMesIni := 1
         nAnoIni += 1
      Else
         nMesIni += 1
      EndIf
      nCont++
   EndDo

Return


********************************************************************************************************
Static Function EECPG01Vlr(aPeriodo,aValores)
********************************************************************************************************

 Local nValor    := 0             ,;
       nInd      := 1             ,; 
       nPos      := 0             ,;  
       cFilEEC := xFilial("EEC")

   ChkFile("EEC")

   //AOM - 01/09/10
   For nInd := 1  to  Len(aPeriodo)
      AAdd( aValores[nInd], 0 )
   Next nInd
   
   EEC->( DBSetOrder(12) )
   EEC->( DBSeek(cFilEEC+DToS(aPeriodo[1][1]),.T.) )  // SoftSeek utilizando primeira data

   Do While EEC->( !EoF()  .And.  EEC_FILIAL == cFilEEC  .And.  EEC_DTEMBA <= aPeriodo[Len(aPeriodo)][2] )
      If EEC->EEC_MOEDA == cMoeDolar
         nValor := EEC->EEC_TOTPED
      Else
         nValor := ( EEC->EEC_TOTPED * BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.) ) / nTxDolar
      EndIf
      nValor /= 1000  // Valores em milhares de US$
      // Verifica em que Periodo se encontra o embarque
      nPos := AScan( aPeriodo, { |x| EEC->EEC_DTEMBA >= x[1]  .And.  EEC->EEC_DTEMBA <= x[2] } )
      If nPos > 0
         aValores[nPos][1] += nValor
      EndIf
      EEC->( DBSkip() )
   EndDo
   For nInd := 1  to  Len(aValores)
      aValores[nInd][1] := Round( aValores[nInd][1], 2 )
   Next nInd

Return aValores
