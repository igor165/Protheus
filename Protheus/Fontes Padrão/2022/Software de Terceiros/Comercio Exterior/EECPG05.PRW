#include "protheus.ch"
#include "msgraphi.ch"  
#include "eecpg05.ch"
#Include "TOPCONN.CH"

#Define ABERTO       1
#Define ENCAMINHADO  2
#Define EMBARCADO    3

********************************************************************************************************
Function EECPG05()
********************************************************************************************************

 Local aRetPanel := {}      ,;
       TypeGraph := GRP_PIE ,;
       cTitleG   := STR0001 ,;//"Processos"
       bClickG   := {|| }   ,;
       aEixoX    := {}      ,;
       aEixoY    := {}      ,;
       cTitleT   := STR0002 ,;//"Pedidos" 
       bClickT   := {|| }   ,;
       aTabela   := {}      ,;
       aProcesso := {}      ,;
       aPeriodo  := {}

 Private dDtIni    := CToD("  /  /  ")  ,;
         dDtFim    := CToD("  /  /  ")

   // TypeGraph : Tipo do Gráfico ( GRP_LINE, GRP_PIE, GRP_BAR )
   // cTitleG   : Título do Gráfico 
   // bClickG   : Bloco de código a ser executado no clique do gráfico 
   // aEixoX    : Array contendo os atributos a serem exibidos
   // aEixoY    : Array contendo os valores dos atributos
   // cTitleT   : Título da Tabela
   // bClickT   : Bloco de Código a ser executado no clique da Tabela 
   // aTabela   : Array multidimensional contendo os arrays por filtro, no formato { "filtro", aCabec, aValores } , onde :  
   //             aCabec    : Array contendo o cabeçalho.
   //             aValores  : Array contendo os valores da lista. 
   
   Pergunte("EECPGOL5",.F.)
   aEixoX := { STR0003, STR0004, STR0005 }//"Abertos", "Encaminhados", "Embarcados"
   EECPG05Per( @dDtIni, @dDtFim )
   EECPG05Pro( aEixoX, @aEixoY, @aTabela )

   aRetPanel := { TypeGraph ,{ cTitleG, bClickG, aEixoX, aEixoY } , { cTitleT , bClickT, aTabela } }

Return aRetPanel


********************************************************************************************************
Static Function EECPG05Per( dDtIni, dDtFim )
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
Static Function EECPG05Pro( aEixoX, aEixoY, aTabela )
********************************************************************************************************

 Local bWhile    := {|| }  ,;
       bCond     := {|| }  ,;
       aCabec    := {}     ,;
       aPedidos  := {}     ,;
       cAliasEE7 := ""     ,;
       cFilEE8   := ""     ,;
       cFilEEC   := ""     ,;
       cFilEE9   := ""     ,;
       cChaveEE8 := ""     ,;
       cChaveEE9 := ""     ,;
       nStatus   := 0      ,;
       nInd      := 1

 Private cFilEE7 := xFilial("EE7")

   aCabec   := { AvSX3("EE7_PEDIDO",5), AvSX3("EE7_DTPROC",5) }
   aEixoY   := { 0, 0, 0 }
   aPedidos := { {}, {}, {} }
   
   cFilEE8 := xFilial("EE8")
   cFilEEC := xFilial("EEC")
   cFilEE9 := xFilial("EE9")
   EE8->( DBSetOrder(1) )
   EEC->( DBSetOrder(1) )
   EE9->( DBSetOrder(1) )

   #IFDEF TOP
      EECPG05Qry()
      bWhile    := { || .T. }
      bCond     := { || .T. }
      cAliasEE7 := "TRB"
      TRB->( DBGoTop() )
   #ELSE
      bWhile    := { || EE7->EE7_FILIAL == cFilEE7 }
      bCond     := { || EE7->( EE7_DTPROC >= dDtIni  .And.  EE7_DTPROC <= dDtFim ) }
      cAliasEE7 := "EE7"
      EE7->( DBSetOrder(1) )
      EE7->( DBSeek(cFilEE7) )
   #ENDIF

   Do While (cAliasEE7)->( !EoF()  )  .And.  Eval(bWhile)
      If !Eval(bCond)
         (cAliasEE7)->( DBSkip() )
         Loop
      EndIf
      cChaveEE8 := cFilEE8+(cAliasEE7)->EE7_PEDIDO
      EE8->( DBSeek(cChaveEE8) )
      nStatus := ABERTO  //"1"
      Do While EE8->( !EoF()  .And.  EE8_FILIAL+EE8_PEDIDO == cChaveEE8 )
         If EE8->( EE8_SLDATU != EE8_SLDINI  .Or.  !Empty(EE8_RV) )
            nStatus := EMBARCADO  //"3"
            cChaveEE9 := cFilEE9+EE8->( EE8_PEDIDO+EE8_SEQUEN )
            If EE8->EE8_SLDATU == 0  .And.  EE9->( DBSeek(cChaveEE9) )
               Do While EE9->( !EoF()  .And.  EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN == cChaveEE9 )
                  EEC->( DBSeek(cFilEEC+EE9->EE9_PREEMB) )
                  If EEC->( Empty(EEC_DTEMBA) )
                     nStatus := ENCAMINHADO  //"2"
                     Exit
                  EndIf
                  EE9->( DBSkip() )
               EndDo
               If nStatus == ENCAMINHADO  //"2"
                  Exit
               EndIf
            Else
               nStatus := ENCAMINHADO  //"2"
            EndIf
         EndIf
         EE8->( DBSkip() )
      EndDo      
      aEixoY[nStatus] += 1
      AAdd( aPedidos[nStatus], { (cAliasEE7)->EE7_PEDIDO, (cAliasEE7)->EE7_DTPROC } ) //AOM - 02/09/10 
      (cAliasEE7)->( DBSkip() )
   EndDo
   (cAliasEE7)->( DBCloseArea() )

   For nInd := 1  to  Len(aEixoX)
      AAdd( aTabela, { aEixoX[nInd], aCabec, IIF( !Empty(aPedidos[nInd]), aPedidos[nInd], { { "", "  /  /  " } } ) } )
   Next nInd

Return


********************************************************************************************************
Static Function EECPG05Qry()
********************************************************************************************************

 Local cQuery := ""  ,;
       cFrom  := ""  ,;
       cWhere := ""

   cQuery := " SELECT EE7.EE7_PEDIDO, EE7.EE7_DTPROC "

   cFrom := "FROM "+RetSqlName("EE7")+" EE7 "

   cWhere := "WHERE EE7.EE7_FILIAL='"+cFilEE7+"' "+IIF(TcSrvType()<>"AS/400","AND EE7.D_E_L_E_T_ <> '*' ","")
   cWhere += "AND EE7.EE7_DTPROC >= '"+DToS(dDtIni)+"' "
   cWhere += "AND EE7.EE7_DTPROC <= '"+DToS(dDtFim)+"' "

   cQuery += cFrom+cWhere+" ORDER BY EE7_PEDIDO "
   cQuery := ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","EE7_DTPROC","D")
   DBSelectArea("TRB")

Return
