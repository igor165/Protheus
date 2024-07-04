#include "protheus.ch"
#include "msgraphi.ch"   
#include "Eicpg04.ch"

#Include "TOPCONN.CH"

#Define CUSTO  "4"

********************************************************************************************************
Function EICPG04()
********************************************************************************************************

 Local aRetPanel    := {}                     ,;
       TypeGraph    := GRP_BAR                ,;
       bClickG      := {|| }                  ,;
       aEixoX       := {}                     ,;
       aIndicadores := {} //{STR0001} Lengenda,; //"Vias de Transporte" nopado por WFS 13/05/09
       aValores     := {} //Eixo Y
       
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

   EICPG04Per(@dDtIni,@dDtFim)
   EICPG04Vlr(@aEixoX,@aValores, @aIndicadores)
     
   aRetPanel := {TypeGraph, bClickG, aEixoX, aIndicadores, aValores}

Return aRetPanel


********************************************************************************************************
Static Function EICPG04Per(dDtIni,dDtFim)
********************************************************************************************************

 Local nMesFim  := 0  ,;
       nAnoFim  := 0   ,;
       cDataBase := ""

   Pergunte("EICPGOL4", .F.)

   If ValType(mv_par01) <> "C" .Or. ValType(mv_par02) <> "C" .Or. Empty(mv_par01)  .Or.  Empty(mv_par02)
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
Static Function EICPG04Vlr(aEixoX,aValores, aLegenda)
********************************************************************************************************

 Local aVias     := {}              ,;
       bWhile    := {|| }           ,;
       bCond     := {|| }           ,;
       nValor    := 0               ,;
       nInd      := 1               ,;
       nPos      := 0               ,;
       cAliasSW6 := ""              ,;
       cFilSWN   := xFilial("SWN")  ,;
       cFilSYQ   := xFilial("SYQ")  ,;
       cChaveSWN := ""

 Private cFilSW6   := xFilial("SW6")        ,;
         nTamDINum := AvSX3("W6_DI_NUM",3)

   #IFDEF TOP
      cAliasSW6 := "TRB"
      bWhile    := { || .T. }
      bCond     := { || .T. }
      EICPG04Qry()
      TRB->( DBGoTop() )
   #ELSE
      cAliasSW6 := "SW6"
      bWhile    := { || SW6->( W6_FILIAL == cFilW6 ) }
      bCond     := { || SW6->( W6_DTREG_D >= dDtIni  .And.  W6_DTREG_D <= dDtFim  .And.  W6_TIPOFEC $ "DI___DIN" ) }
      SW6->( DBSetOrder(11) )
      If SW6->( AvLastSeek(cFilSW6+Space(nTamDINum)) )
         SW6->( DBSkip() )
      Else
         SW6->( DBGoTop() )
      EndIf
   #ENDIF

   SWN->( DBSetOrder(3) )
   SYQ->( DBSetOrder(1) )
      
   Do While (cAliasSW6)->( !EoF() )  .And.  Eval(bWhile)

      If !Eval(bCond)
         (cAliasSW6)->( DBSkip() )
         Loop
      EndIf
         
      cChaveSWN := cFilSWN+(cAliasSW6)->W6_HAWB
      If SWN->( DBSeek(cChaveSWN) )
         nValor := 0
         Do While SWN->( !EoF()  .And.  WN_FILIAL+WN_HAWB == cChaveSWN )
            If SWN->WN_TIPO_NF != CUSTO  // "4"
               nValor += SWN->WN_VALOR
               nValor += SWN->WN_VALIPI
               nValor += SWN->WN_VLRPIS
               nValor += SWN->WN_VLRCOF
               nValor += SWN->WN_VALICM
            EndIf
            SWN->( DBSkip() )
         EndDo

         nTxDolar := BuscaTaxa(cMoeDolar,(cAliasSW6)->W6_DTREG_D,,.F.,.T.)
         
         nValor /= nTxDolar

         nPos := AScan( aVias, { |x| x[1] == (cAliasSW6)->W6_VIA_TRA } )
         If nPos > 0
            aVias[nPos][3] += nValor
            aVias[nPos][4] += 1
         Else
            SYQ->( DBSeek(cFilSYQ+(cAliasSW6)->W6_VIA_TRA) )
            AAdd( aVias, { (cAliasSW6)->W6_VIA_TRA, SYQ->YQ_DESCR, nValor, 1 } )
         EndIf
      EndIf      

      (cAliasSW6)->( DBSkip() )
   EndDo
   (cAliasSW6)->( DBCloseArea() )

   If Len(aVias) > 0
      ASort( aVias, , , { |a,b| a[1] < b[1] } )
      For nInd := 1  to  Len(aVias)
         AAdd( aEixoX, "" ) //Eixo X
         AAdd(aValores, {Round( aVias[nInd][3] / aVias[nInd][4], 2 )}) //Eixo Y
         AAdd(aLegenda, aVias[nInd][2]) //Legenda
      Next
   Else
      AAdd(aLegenda,  STR0002)//"Não há Despesas de Processos." 
      AAdd(aValores, {0})
   EndIf

Return


********************************************************************************************************
Static Function EICPG04Qry()
********************************************************************************************************

 Local cQuery  := ""  ,;
       cFrom   := ""  ,;
       cWhere  := ""

   cQuery := " SELECT SW6.W6_HAWB, SW6.W6_DTREG_D, SW6.W6_VIA_TRA "

   cFrom := "FROM "+RetSqlName("SW6")+" SW6 "

   cWhere := "WHERE SW6.W6_FILIAL='"+cFilSW6+"' "+IIF(TcSrvType()<>"AS/400","AND SW6.D_E_L_E_T_ <> '*' ","")
   cWhere += "AND SW6.W6_DI_NUM <> '' AND SW6.W6_DI_NUM <> '"+Space(nTamDINum)+"' "
   cWhere += "AND SW6.W6_DTREG_D >= '"+DToS(dDtIni)+"' "
   cWhere += "AND SW6.W6_DTREG_D <= '"+DToS(dDtFim)+"' "
   cWhere += "AND SW6.W6_TIPOFEC IN ('DI','DIN') "

   cQuery += cFrom+cWhere+" ORDER BY W6_VIA_TRA "
   cQuery := ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","W6_DTREG_D","D")
   DBSelectArea("TRB")

Return
