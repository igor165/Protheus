#include "protheus.ch"
#include "msgraphi.ch"
#include "eicpg05.ch"

#Include "TOPCONN.CH"

#Define DESEMBARACO "D"
#Define IND_PAGAR   1
#Define IND_PAGO    2

********************************************************************************************************
Function EICPG05()
********************************************************************************************************

 Local aRetPanel    := {}                      ,;
       TypeGraph    := GRP_HBAR                 ,;
       bClickG      := {||   }                 ,;
       aEixoX       := {}                      ,;
       aIndicadores := {STR0001, STR0002}      ,; //"A Pagar", "Pago"
       aValores     := {}                      ,;
       aPeriodo     := {}                      ,;
       nInd         := {}

 Private dDtIni := CToD("  /  /  ")  ,;
         dDtFim := CToD("  /  /  ")
       
   //[1] TypeGraph    : Tipo do Gráfico ( GRP_LINE, GRP_PIE, GRP_BAR )
   //[2] bClickG      : Bloco de Código a ser executado no clique do gráfico 
   //[3] aEixoX       : Array contendo os atributos a serem exibidos; eixo X {"C"}
   //[4] aIndicadores : Array contendo os nomes dos indicadores ; legenda {"C"}
   //[5] aValores     : Array multidimensional contendo os valores dos indicadores; eixo Y {{N}}
   //[6] Titulo
   //[7] Sub Titulo

 Private cMoeDolar := EasyGParam("MV_EECUSS",,"US$")

   EICPG05ExX(@aEixoX,@aPeriodo)

   dDtIni := aPeriodo[1][1]
   dDtFim := aPeriodo[Len(aPeriodo)][2]

   For nInd := 1  to  Len(aIndicadores)
      AAdd( aValores, {} )
   Next nInd

   EICPG05Vlr( aPeriodo, @aValores )

   aRetPanel := { TypeGraph, bClickG, aEixoX, aIndicadores, aValores }

Return aRetPanel


********************************************************************************************************
Static Function EICPG05ExX(aEixoX,aPeriodo)
********************************************************************************************************

 Local nMesIni := 0                 ,;
       nAnoIni := 0                 ,;
       nMesFim := 0                 ,;
       nAnoFim := 0                 ,;
       dDtIni  := CToD("  /  /  ")  ,;
       dDtFim  := CToD("  /  /  ")  ,;
       aData     := {}              ,;
       cDataBase := ""              ,;
       cIdioma   := ""

   if FwRetIdiom() == "es"
      cIdioma := "ESP.  -ESPANHOL          "
   else
      if FwRetIdiom() == "en"
         cIdioma := "INGLES-INGLES"
      else
         cIdioma := IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES         "
      endif
   endif

   Pergunte("EICPGOL5", .F.)

   If ValType(mv_par01) <> "C" .Or. ValType(mv_par02) <> "C" .Or. Empty(mv_par01)  .Or.  Empty(mv_par02)
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
Static Function EICPG05Vlr( aPeriodo, aValores )
********************************************************************************************************

 Local nValor    := 0      ,;
       bWhile    := {|| }  ,;
       bCond     := {|| }  ,;
       cAliasSWB := ""     ,;
       aValAux   := {}     ,;
       nPos      := 0      ,;
       nInd      := 1      ,;
       nInd2     := 1

 Private cFilSWB := xFilial("SWB")

   #IFDEF TOP
      cAliasSWB := "TRB"
      bWhile    := { || .T. }
      bCond     := { || .T. }
      EICPG05Qry()
      TRB->( DBGoTop() )
   #ELSE
      cAliasSWB := "SWB"
      bWhile    := { || SWB->( WB_FILIAL == cFilSWB ) }
      bCond     := { || SWB->( WB_PO_DI == DESEMBARACO  .And.  WB_DT_VEN >= dDtIni  .And.  WB_DT_VEN <= dDtFim ) }
      SWB->( DBSetOrder(1) )
      SWB->( DBSeek(cFilSWB) )
   #ENDIF

   For nInd := 1  to  Len(aValores)
      For nInd2 := 1  to  Len(aPeriodo)
         AAdd( aValores[nInd], 0 )
      Next nInd2
   Next nInd

   Do While (cAliasSWB)->( !EoF() )  .And.  Eval(bWhile)
      If !Eval(bCond)
         (cAliasSWB)->( DBSkip() )
         Loop
      EndIf
      If (cAliasSWB)->WB_MOEDA == cMoeDolar
         nValor := (cAliasSWB)->WB_FOBMOE
      Else
         nValor := ( (cAliasSWB)->WB_FOBMOE * BuscaTaxa((cAliasSWB)->WB_MOEDA,(cAliasSWB)->WB_DT_VEN,,.F.,.T.) ) / BuscaTaxa(cMoeDolar,(cAliasSWB)->WB_DT_VEN,,.F.,.T.)
      EndIf

      nValor /= 1000  //TRP- 21/05/09 - Valor em milhares de Dólares
      // Verifica em que Periodo se encontra o embarque
      nPos := AScan( aPeriodo, { |x| (cAliasSWB)->WB_DT_VEN >= x[1]  .And.  (cAliasSWB)->WB_DT_VEN <= x[2] } )
      If Empty((cAliasSWB)->WB_CA_DT)
         aValores[IND_PAGAR][nPos] += nValor
      Else
         aValores[IND_PAGO][nPos] += nValor
      EndIf

      (cAliasSWB)->( DBSkip() )
   EndDo
   //TRP - 21/05/09 - Eliminar os decimais, uma vez que os valores do gráfico serão apresentados em mil US$.
   For nInd := 1  to  Len(aValores[IND_PAGAR])
      aValores[IND_PAGAR][nInd] := Round( aValores[IND_PAGAR][nInd], 0 )
   Next nInd
   
   For nInd := 1  to  Len(aValores[IND_PAGO])
      aValores[IND_PAGO][nInd] := Round( aValores[IND_PAGO][nInd], 0 )
   Next nInd  
   (cAliasSWB)->( DBCloseArea() )
   
Return


********************************************************************************************************
Static Function EICPG05Qry()
********************************************************************************************************

 Local cQuery := ""  ,;
       cFrom  := ""  ,;
       cWhere := ""

   cQuery := " SELECT SWB.WB_MOEDA, SWB.WB_FOBMOE, SWB.WB_DT_VEN, SWB.WB_CA_DT "

   cFrom := "FROM "+RetSqlName("SWB")+" SWB "

   cWhere := "WHERE SWB.WB_FILIAL='"+cFilSWB+"' "+IIF(TcSrvType()<>"AS/400","AND SWB.D_E_L_E_T_ <> '*' ","")
   cWhere += "AND SWB.WB_DT_VEN >= '"+DToS(dDtIni)+"' "
   cWhere += "AND SWB.WB_DT_VEN <= '"+DToS(dDtFim)+"' "
   cWhere += "AND SWB.WB_PO_DI = '"+DESEMBARACO+"' "

   cQuery += cFrom+cWhere+" ORDER BY WB_DT_VEN "
   cQuery := ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","WB_DT_VEN","D")
   DBSelectArea("TRB")

Return
