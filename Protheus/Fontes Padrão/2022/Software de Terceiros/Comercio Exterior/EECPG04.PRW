#include "protheus.ch"
#include "msgraphi.ch"     
#include "eecpg04.ch"

#Define EMBARQUE "Q"

********************************************************************************************************
Function EECPG04()
********************************************************************************************************

 Local aRetPanel    := {}                        ,;
       TypeGraph    := GRP_BAR                   ,;
       bClickG      := {||  }                    ,;
       aEixoX       := {}                        ,;
       aIndicadores := {}                        ,;//"Vias de Transporte"
       aValores     := {}                        ,;
       nInd         := 1
       
 Private dDtIni := CToD("  /  /  ")  ,;
         dDtFim := CToD("  /  /  ")

   // TypeGraph    : Tipo do Gráfico ( GRP_LINE, GRP_PIE, GRP_BAR )
   // bClickG      : Bloco de Código a ser executado no clique do gráfico 
   // aEixoX       : Array contendo os atributos a serem exibidos 
   // aIndicadores : Array contendo os nomes dos indicadores 
   // aValores     : Array multidimensional contendo os valores dos indicadores

   DBSelectArea("EEC")
   Private cMoeDolar := EasyGParam("MV_EECUSS",,"US$")
   Private nTxDolar  := BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.)
   
   //AOM - 01/09/10
   Pergunte("EECPGOL4",.F.)
   EECPG04Per(@dDtIni,@dDtFim)
   EECPG04Vlr(@aEixoX,@aValores)
   //AOM - 01/09/10 - Adicionar os indicadores de acordo com a Via de Transporte
   For nInd := 1  to  Len(aEixoX)
      AAdd( aIndicadores,{})
      AAdd( aIndicadores[nInd], aEixoX[nInd] )
   Next nInd
   aRetPanel := { TypeGraph ,bClickG, aEixoX, aIndicadores, aValores }

Return aRetPanel


********************************************************************************************************
Static Function EECPG04Per(dDtIni,dDtFim)
********************************************************************************************************

 Local nMesFim  := 0  ,;
       nAnoFim  := 0   ,;
       cDataBase := ""

   If Empty(mv_par01)  .Or.  Empty(mv_par02)
      cDataBase := DToS(dDataBase)
      nMesFim := Val(SubStr(cDataBase,5,2))
      nAnoFim := Val(SubStr(cDataBase,3,2))
      If nMesFim < 6
         dDtIni := CToD("01/"+StrZero(nMesFim+7,2)+"/"+StrZero(nAnoFim-1,2))
      Else
         dDtIni := CToD("01/"+StrZero(nMesFim-5,2)+"/"+StrZero(nAnoFim,2))
      EndIf
   Else
      nMesFim := Val(Left( mv_par02,2))
      nAnoFim := Val(Right(mv_par02,2))
      dDtIni := CToD("01/"+Left(mv_par01,2)+"/"+Right(mv_par01,2))
   EndIf

   If nMesFim == 12
      dDtFim := CToD("31/12"+"/"+StrZero(nAnoFim,2))
   Else
      dDtFim := CToD("01/"+StrZero(nMesFim+1,2)+"/"+StrZero(nAnoFim,2))-1
   EndIf
                                             


Return


********************************************************************************************************
Static Function EECPG04Vlr(aEixoX,aValores)
********************************************************************************************************

 Local aVias     := {}              ,;
       nValor    := 0               ,;
       nInd      := 1               ,;
       nPos      := 0               ,;
       cFilEET   := xFilial("EET")  ,;   
       cFilEEC   := xFilial("EEC")  ,;
       cFilSYQ   := xFilial("SYQ")  ,;
       cChaveEET := ""

   ChkFile("EEC")
   ChkFile("EET")
   ChkFile("SYQ")

   EEC->( DBSetOrder(12) )
   EEC->( DBSeek(cFilEEC+DToS(dDtIni),.T.) )  // SoftSeek utilizando a menor Data

   EET->( DBSetOrder(1) )
   SYQ->( DBSetOrder(1) )
   
   Do While EEC->( !EoF()  .And.  EEC_FILIAL == cFilEEC  .And.  EEC_DTEMBA <= dDtFim )

      nPos := AScan( aVias, { |x| x[1] == EEC->EEC_VIA } )
      nValor := 0

      cChaveEET := cFilEET+AvKey(EEC->EEC_PREEMB,"EET_PEDIDO")+EMBARQUE  //"Q"

      If EET->( DBSeek(cChaveEET) )

         Do While EET->( !EoF()  .And.  EET_FILIAL+EET_PEDIDO+EET_OCORRE == cChaveEET )
            nValor += EET->EET_VALORR / nTxDolar
            EET->( DBSkip() )
         EndDo

         If nPos > 0
            aVias[nPos][3] += nValor
         Else
            SYQ->( DBSeek(cFilSYQ+EEC->EEC_VIA) )
            AAdd( aVias, { EEC->EEC_VIA, SYQ->YQ_DESCR, nValor, 1 } )
         EndIf

      Else

         If nPos > 0
            aVias[nPos][4] += 1
         Else
            SYQ->( DBSeek(cFilSYQ+EEC->EEC_VIA) )
            AAdd( aVias, { EEC->EEC_VIA, SYQ->YQ_DESCR, nValor, 1 } )
         EndIf

      EndIf

      EEC->( DBSkip() )
   EndDo
   
   If Len(aVias) > 0
      ASort( aVias, , , { |a,b| a[1] < b[1] } )
      For nInd := 1  to  Len(aVias)
         //AOM - 02/09/10
         AAdd( aEixoX,{})
         AAdd( aEixoX[nInd], aVias[nInd][2] )
         If Len(aValores) > 0
            AAdd( aValores, {})
            AAdd( aValores[nInd], Round( aVias[nInd][3] / aVias[nInd][4], 2 ) )
         Else
            aValores := { { Round( aVias[nInd][3] / aVias[nInd][4], 2 ) } }
         EndIf
      Next nInd
   Else
      aEixoX   := { STR0002 }//"Não há Despesas de Processos."
      aValores := { { 0 } }
   EndIf

Return
