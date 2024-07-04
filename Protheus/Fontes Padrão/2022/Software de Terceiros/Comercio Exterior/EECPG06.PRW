#include "protheus.ch"
#include "msgraphi.ch"
#include "eecpg06.ch"
#Include "TOPCONN.CH"

#Define EMBARQUE "E"
#Define RECEBER  "R"
#Define PAGAR    "P"
#Define IND_RECEBER  1
#Define IND_PAGAR    2

********************************************************************************************************
Function EECPG06()
********************************************************************************************************

 Local aRetPanel    := {}                               ,;
       TypeGraph    := GRP_BAR                          ,;
       bClickG      := {||  }                           ,;
       aEixoX       := {}                               ,;
       aIndicadores := {}                               ,;
       aValores     := {}                               ,;
       aPeriodo     := {}                               ,;
       nInd         := {}

 Private dDtIni := CToD("  /  /  ")  ,;
         dDtFim := CToD("  /  /  ")
       
   // TypeGraph    : Tipo do Gráfico ( GRP_LINE, GRP_PIE, GRP_BAR )
   // bClickG      : Bloco de Código a ser executado no clique do gráfico 
   // aEixoX       : Array contendo os atributos a serem exibidos 
   // aIndicadores : Array contendo os nomes dos indicadores 
   // aValores     : Array multidimensional contendo os valores dos indicadores
   
 //AOM - 02/09/10
 Pergunte("EECPGOL6",.F.)
 Private cMoeDolar := EasyGParam("MV_EECUSS",,"US$")
 Private nTxDolar  := BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.)

   EECPG06ExX(@aEixoX,@aPeriodo)

   dDtIni := aPeriodo[1][1]
   dDtFim := aPeriodo[Len(aPeriodo)][2]

   EECPG06Vlr( aPeriodo, @aValores ) 
   
   //AOM - 02/09/10 - Adiciona os indicadores de acordo com a estrutura dos parametros.
   For nInd := 1  to  Len(aEixoX)
      AAdd( aIndicadores, {} )
      AAdd( aIndicadores[nInd],aEixoX[nInd][1])//"Receber"
      AAdd( aIndicadores[nInd],aEixoX[nInd][2])//"Pagar"
   Next nInd

   aRetPanel := { TypeGraph, bClickG, aEixoX, aIndicadores, aValores  }

Return aRetPanel


********************************************************************************************************
Static Function EECPG06ExX(aEixoX,aPeriodo)
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
       nInd      := 1

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
      AAdd( aEixoX, {})//AOM - 02/09/10
      AAdd( aEixoX[nInd], STR0001 + " - " + Left(aData[1],3)+"/"+Right(aData[3],2) + " - " + AllTrim(cMoeDolar) ) // "Receber"
      AAdd( aEixoX[nInd], STR0002 + " - " + Left(aData[1],3)+"/"+Right(aData[3],2) + " - " + AllTrim(cMoeDolar) ) // "Pagar"
      nInd++
      If nMesIni == 12
         nMesIni := 1
         nAnoIni += 1
      Else
         nMesIni += 1
      EndIf
   EndDo

Return


********************************************************************************************************
Static Function EECPG06Vlr( aPeriodo, aValores )
********************************************************************************************************

 Local nValor    := 0      ,;
       bWhile    := {|| }  ,;
       bCond     := {|| }  ,;
       cAliasEEQ := ""     ,;
       aValAux   := {}     ,;
       nPos      := 0      ,;
       nInd      := 1      ,;
       nInd2     := 1

 Private cFilEEQ := xFilial("EEQ")

   #IFDEF TOP
      cAliasEEQ := "TRB"
      bWhile    := { || .T. }
      bCond     := { || .T. }
      EECPG06Qry()
      TRB->( DBGoTop() )
   #ELSE
      cAliasEEQ := "EEQ"
      bWhile    := { || EEQ->( EEQ_FILIAL+EEQ_FASE == cFilEEQ+EMBARQUE ) }  //"E"
      bCond     := { || EEQ->( EEQ_VCT >= dDtIni  .And.  EEQ_VCT <= dDtFim  .And.  EEQ_TIPO $ "PR" ) }
      EEQ->( DBSetOrder(6) )
      EEQ->( DBSeek(cFilEEQ+EMBARQUE) )  //"E"
   #ENDIF

   For nInd := 1  to  Len(aPeriodo)
      AAdd( aValores, {} )
      AAdd( aValores[nInd], 0 )
      AAdd( aValores[nInd], 0 )
   Next nInd

   Do While (cAliasEEQ)->( !EoF() )  .And.  Eval(bWhile)
      If !Eval(bCond)
         (cAliasEEQ)->( DBSkip() )
         Loop
      EndIf
      If (cAliasEEQ)->EEQ_MOEDA == cMoeDolar
         nValor := Round((cAliasEEQ)->EEQ_VL,2)
      Else
         nValor := Round(( (cAliasEEQ)->EEQ_VL * BuscaTaxa((cAliasEEQ)->EEQ_MOEDA,dDataBase,,.F.,.T.) ) / nTxDolar,2)
      EndIf
      
      //DFS - 16/09/2010 - Implementado para que o sistema não fique com várias casas decimais      
      nValor := ROUND((nValor)/1000,2) // Valores em milhares de US$
      
      // Verifica em que Periodo se encontra o embarque - AOM - 02/09/10
      nPos := AScan( aPeriodo, { |x| (cAliasEEQ)->EEQ_VCT >= x[1]  .And.  (cAliasEEQ)->EEQ_VCT <= x[2] } )
      If (cAliasEEQ)->EEQ_TIPO == RECEBER  //"R"
         aValores[nPos][IND_RECEBER] += nValor
      ElseIf (cAliasEEQ)->EEQ_TIPO == PAGAR  //"P"
         aValores[nPos][IND_PAGAR] += nValor
      EndIf

      (cAliasEEQ)->( DBSkip() )
   EndDo
   (cAliasEEQ)->( DBCloseArea() )
   
Return


********************************************************************************************************
Static Function EECPG06Qry()
********************************************************************************************************

 Local cQuery := ""  ,;
       cFrom  := ""  ,;
       cWhere := ""

   cQuery := " SELECT EEQ.EEQ_MOEDA, EEQ.EEQ_VL, EEQ.EEQ_VCT, EEQ.EEQ_TIPO "

   cFrom := "FROM "+RetSqlName("EEQ")+" EEQ "

   cWhere := "WHERE EEQ.EEQ_FILIAL='"+cFilEEQ+"' "+IIF(TcSrvType()<>"AS/400","AND EEQ.D_E_L_E_T_ <> '*' ","")
   cWhere += "AND EEQ.EEQ_FASE = '"+EMBARQUE+"' "
   cWhere += "AND EEQ.EEQ_TIPO IN ('"+RECEBER+"','"+PAGAR+"') "
   cWhere += "AND EEQ.EEQ_VCT >= '"+DToS(dDtIni)+"' "
   cWhere += "AND EEQ.EEQ_VCT <= '"+DToS(dDtFim)+"' "

   cQuery += cFrom+cWhere+" ORDER BY EEQ_VCT "
   cQuery := ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","EEQ_VCT","D")
   DBSelectArea("TRB")

Return
