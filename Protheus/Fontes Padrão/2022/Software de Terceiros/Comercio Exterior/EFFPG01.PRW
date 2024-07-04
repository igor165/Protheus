#include "protheus.ch"
#include "msgraphi.ch"     
#include "effpg01.ch"

#Define EV_EMBARQUE "600"
#Define EV_ESTORNO  "999"
#Define EXP "E"
#Define IMP "I"

********************************************************************************************************
Function EFFPG01()
********************************************************************************************************

 Local aRetPanel    := {}                          ,;
       TypeGraph    := GRP_BAR                     ,;
       bClickG      := {||  }                      ,;
       aEixoX       := { STR0001 , STR0002 }       ,; //"Exportação","Importação"
       aIndicadores := { STR0003 , STR0004 }      ,; //"Total","Financiado"
       aValores     := EFFPG01Val()

   // TypeGraph    : Tipo do Gráfico ( GRP_LINE, GRP_PIE, GRP_BAR )
   // bClickG      : Bloco de Código a ser executado no clique do gráfico 
   // aEixoX       : Array contendo os atributos a serem exibidos 
   // aIndicadores : Array contendo os nomes dos indicadores 
   // aValores     : Array multidimensional contendo os valores dos indicadores

   aRetPanel := { TypeGraph, bClickG, aEixoX, aIndicadores, aValores }

Return aRetPanel


********************************************************************************************************
Static Function EFFPG01Val()
********************************************************************************************************

 Local aValores  := {}               ,;
       nTotalEXP := 0                ,;
       nFinanEXP := 0                ,;
       nTotalIMP := 0                ,;
       nFinanIMP := 0

 Private cMoeDolar := ""  ,;
         nTxDolar  := 0
         
   DBSelectArea("EF1")
   cMoeDolar := EasyGParam("MV_SIMB2",,"US$")
   nTxDolar  := BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.)

   nTotalEXP := EFFPG01Exp()
   nTotalIMP := EFFPG01Imp()
   nFinanEXP := EFFPG01Fin(EXP)
   nFinanIMP := EFFPG01Fin(IMP) 

   aValores := { {nTotalEXP, nTotalIMP} , {nFinanEXP, nFinanIMP} }

Return aValores


********************************************************************************************************
Static Function EFFPG01Exp()
********************************************************************************************************

 Local nValor  := 0               ,;
       cFilEEC := xFilial("EEC")
 
   ChkFile("EEC")

   // Soma Valor Total de Exportações Embarcadas
   EEC->( DBSetOrder(12) )
   If EEC->( AvSeekLast(cFilEEC+Space(AVSX3("EEC_DTEMBA",3))) )
      EEC->( DBSkip() )
   Else
      EEC->( DBSeek(cFilEEC) )
   EndIf
   Do While EEC->( !EoF()  .And.  EEC_FILIAL == cFilEEC )
      If EEC->EEC_MOEDA == cMoeDolar
         nValor += EEC->EEC_TOTPED
      Else
         nValor += ( EEC->EEC_TOTPED * BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.) ) / nTxDolar
      EndIf
      EEC->( DBSkip() )
   EndDo

   nValor := Round( nValor/1000, 2 )

Return nValor


********************************************************************************************************
Static Function EFFPG01Imp()
********************************************************************************************************

 Local nValor  := 0               ,;
       cFilSW6 := xFilial("SW6")  ,;
       cFilSW9 := xFilial("SW9")  ,;
       cChave  := ""
 
   ChkFile("SW6")
   ChkFile("SW9")

   // Soma Valor Total de Importações com D.I. registrada
   SW6->( DBSetOrder(11) )
   If SW6->( AvSeekLast(cFilSW6+Space(AVSX3("W6_DI_NUM",3))) )
      SW6->( DBSkip() )
   Else
      SW6->( DBSeek(cFilSW6) )
   EndIf
   SW9->( DBSetOrder(3) )
   Do While SW6->( !EoF()  .And.  W6_FILIAL == cFilSW6 )
      cChave := cFilSW9+SW6->W6_HAWB
      SW9->( DBSeek(cChave) )
      Do While SW9->( !EoF()  .And.  W9_FILIAL+W9_HAWB == cChave )
         If SW9->W9_MOE_FOB == cMoeDolar
            nValor += SW9->W9_FOB_TOT
         Else
            nValor += SW9->( W9_FOB_TOT * W9_TX_FOB ) / nTxDolar
         EndIf
         SW9->( DBSkip() )
      EndDo
      SW6->( DBSkip() )
   EndDo

   nValor := Round( nValor/1000, 2 )

Return nValor


********************************************************************************************************
Static Function EFFPG01Fin(cTpModu)
********************************************************************************************************

 Local nValor  := 0               ,;
       cFilEF3 := xFilial("EF3")  ,;
       cChave  := cFilEF3+cTpModu+EV_EMBARQUE  //"600"

   ChkFile("EF3")

   EF3->( DBSetOrder(2) )
   EF3->( DBSeek(cChave) )
   Do While EF3->( !EoF()  .And.  EF3_FILIAL+EF3_TPMODU+EF3_CODEVE == cChave )
      If EF3->EF3_MOE_IN == cMoeDolar
         nValor += EF3->EF3_VL_INV
      Else
         nValor += ( EF3->EF3_VL_INV * BuscaTaxa(EF3->EF3_MOE_IN,dDataBase,,.F.,.T.) ) / nTxDolar
      EndIf
      EF3->( DBSkip() )
   EndDo

   cChave  := cFilEF3+cTpModu+EV_ESTORNO  //"999"
   EF3->( DBSeek(cChave) )
   Do While EF3->( !EoF()  .And.  EF3_FILIAL+EF3_TPMODU+EF3_CODEVE == cChave )
      If EF3->EF3_EV_EST == EV_EMBARQUE  //"600"
         If EF3->EF3_MOE_IN == cMoeDolar
            nValor -= EF3->EF3_VL_INV
         Else
            nValor -= ( EF3->EF3_VL_INV * BuscaTaxa(EF3->EF3_MOE_IN,dDataBase,,.F.,.T.) ) / nTxDolar
         EndIf
      EndIf
      EF3->( DBSkip() )
   EndDo

   If nValor < 0
      nValor := 0
   EndIf

   nValor := Round( nValor/1000, 2 )

Return nValor