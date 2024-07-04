#include "protheus.ch"
#include "msgraphi.ch"  
#include "Eicpg01.ch"

********************************************************************************************************
Function EICPG01()
********************************************************************************************************

 Local aRetPanel    := {}                    ,;
       TypeGraph    := GRP_HBAR               ,;
       bClickG      := { ||  }               ,;
       aEixoX       := {}                    ,;
       aIndicadores := {STR0001}             ,; //"Valor Importado"
       aValores     := {}                    ,;
       aPeriodo     := {}

   // TypeGraph    : Tipo do Gráfico ( GRP_LINE, GRP_PIE, GRP_BAR )
   // bClickG      : Bloco de Código a ser executado no clique do gráfico 
   // aEixoX       : Array contendo os atributos a serem exibidos 
   // aIndicadores : Array contendo os nomes dos indicadores 
   // aValores     : Array multidimensional contendo os valores dos indicadores

   Private cMoeDolar := EasyGParam("MV_EECUSS",,"US$")
   Private nTxDolar  := BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.)

   EICPG01ExX(@aEixoX,@aPeriodo)
   aValores  := EICPG01Vlr(aPeriodo)
   aRetPanel := { TypeGraph, bClickG, aEixoX, aIndicadores, aValores }

Return aRetPanel


********************************************************************************************************
Static Function EICPG01ExX(aEixoX,aPeriodo)
********************************************************************************************************

 Local nMesIni := 0                 ,;
       nAnoIni := 0                 ,;
       nMesFim := 0                 ,;
       nAnoFim := 0                 ,;
       dDtIni  := CToD("  /  /  ")  ,;
       dDtFim  := CToD("  /  /  ")  ,;
       aData   := {}                ,;
       cIdioma   := ""

   Pergunte("EICPGOL1", .F.)
   
   if FwRetIdiom() == "es"
      cIdioma := "ESP.  -ESPANHOL          "
   else
      if FwRetIdiom() == "en"
         cIdioma := "INGLES-INGLES"
      else
         cIdioma := IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES         "
      endif
   endif

   If ValType(mv_par01) <> "C" .Or. ValType(mv_par02) <> "C" .Or. Empty(mv_par01) .Or. Empty(mv_par02)
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
      nMesIni := Val(Left(mv_par01,2))
      nAnoIni := Val(Right(mv_par01,2))
      nMesFim := Val(Left(mv_par02,2))
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
      AAdd( aEixoX, Left(aData[1],3)+"/"+Right(aData[3],2) )
      If nMesIni == 12
         nMesIni := 1
         nAnoIni += 1
      Else
         nMesIni += 1
      EndIf
   EndDo

Return


********************************************************************************************************
Static Function EICPG01Vlr(aPeriodo)
********************************************************************************************************

 Local aValores  := {}              ,;
       nValor    := 0               ,;
       nInd      := 1               ,;
       nPos      := 0               ,;
       cFilSW6   := xFilial("SW6")  ,;
       cFilSW9   := xFilial("SW9")

   ChkFile("SW6")
   ChkFile("SW9")

   AAdd( aValores, {} )
   For nInd := 1  to  Len(aPeriodo)
      AAdd( aValores[1], 0 )
   Next nInd
   
   SW6->( DBSetOrder(2) )
   SW6->( DBSeek(cFilSW6+DToS(aPeriodo[1][1]),.T.) )  // SoftSeek utilizando primeira data
   SW9->( DBSetOrder(3) )

   Do While SW6->( !EoF()  .And.  W6_FILIAL == cFilSW6  .And.  W6_DT_DESE <= aPeriodo[Len(aPeriodo)][2] )
      If SW6->W6_TIPOFEC != "DI"  .And.  SW6->W6_TIPOFEC != "DIN"
         SW6->( DBSkip() )
         Loop
      EndIf
      nValor := 0
      cChaveSW9 := cFilSW9+SW6->W6_HAWB
      SW9->( DBSeek(cChaveSW9) )
      Do While SW9->( !EoF()  .And.  W9_FILIAL+W9_HAWB == cChaveSW9 )
         If SW9->W9_MOE_FOB == cMoeDolar
            nValor += SW9->W9_FOB_TOT
         Else
            nValor += ( SW9->W9_FOB_TOT * BuscaTaxa(SW9->W9_MOE_FOB,dDataBase,,.F.,.T.) ) / nTxDolar
         EndIf
         SW9->( DBSkip() )
      EndDo
      nValor /= 1000  // Valor em milhares de Dólares
      // Verifica em que Periodo se encontra o embarque
      nPos := AScan( aPeriodo, { |x| SW6->W6_DT_DESE >= x[1]  .And.  SW6->W6_DT_DESE <= x[2] } )
      If nPos > 0
         aValores[1][nPos] += nValor
      EndIf
      SW6->( DBSkip() )
   EndDo
   //TRP- 21/05/09 - Eliminar os decimais, uma vez que os valores do gráfico serão apresentados em mil US$.
   For nInd := 1  to  Len(aValores[1])
      aValores[1][nInd] := Round( aValores[1][nInd], 0 )
   Next nInd


Return aValores
