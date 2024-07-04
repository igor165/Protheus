#include "protheus.ch"
#include "msgraphi.ch"  
#include "Eicpg06.ch"

#Include "TOPCONN.CH"

#Define ADIANTAMENTO "A"

********************************************************************************************************
Function EICPG06()
********************************************************************************************************

 Local aRetPanel := {}                       ,;
       TypeGraph := GRP_PIE                  ,;
       cTitleG   := STR0001                  ,; //"Pgtos. Antecipados por Fornecedor"
       bClickG   := {||  }                   ,;
       aEixoX    := {}                       ,;
       aEixoY    := {}                       ,;
       cTitleT   := STR0002                  ,;  //"Pagamentos Antecipados" 
       bClickT   := {||  }                   ,;
       aTabela   := {}

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

  Private cMoeDolar := ""  ,;
          nTxDolar  := 0

   cMoeDolar := EasyGParam("MV_EECUSS",,"US$")
   nTxDolar  := BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.)

   EICPG06Pro(@aEixoX,@aEixoY,@aTabela)

   aRetPanel := { TypeGraph ,{cTitleG, bClickG, aEixoX, aEixoY } , { cTitleT , bClickT, aTabela } }

Return aRetPanel


********************************************************************************************************
Static Function EICPG06Pro(aEixoX,aEixoY,aTabela)
********************************************************************************************************

 Local cAliasSWA := ""     ,;
       bWhile    := {|| }  ,;
       bCond     := {|| }  ,;
       cFiltro   := ""     ,;
       aCabec    := {}     ,;
       aValores  := {}     ,;
       aFornec   := {}     ,;
       cFilSWB   := ""     ,;
       cFilSA2   := ""     ,;
       cPicture  := ""     ,;
       nValor    := 0      ,;
       nPos      := 0      ,;
       nInd      := 1

 Private cFilSWA := xFilial("SWA")

   cPicture  := "@E 999,999,999.99"
   aCabec    := { AvSX3("WA_HAWB",5), AvSX3("WA_SLDANT",5) }

   #IFDEF TOP
      EICPG06Qry()
      bWhile := { || .T. }
      bCond  := { || .T. }
      cAliasSWA := "TRB"
      TRB->( DBGoTop() )
   #ELSE
      bWhile := { || SWA->( WA_FILIAL == cFilSWA  .And.  WA_PO_DI == ADIANTAMENTO ) }
      bCond  := { || SWA->( WA_SLDANT > 0 ) }
      cAliasSWA := "SWA"
      SWA->( DBSetOrder(2) )
      SWA->( DBSeek(cFilSWA+ADIANTAMENTO) )
   #ENDIF
   
   cFilSWB := xFilial("SWB")
   cFilSA2 := xFilial("SA2")
   SWB->( DBSetOrder(1) )
   SA2->( DBSetOrder(1) )

   Do While (cAliasSWA)->( !EoF() )  .And.  Eval(bWhile)
      If !Eval(bCond)
         (cAliasSWA)->( DBSkip() )
         Loop
      EndIf
      If SWB->( DBSeek(cFilSWB+(cAliasSWA)->WA_HAWB+(cAliasSWA)->WA_PO_DI) )
         If SWB->WB_MOEDA == cMoeDolar
            nValor := (cAliasSWA)->WA_SLDANT
         Else
            nValor := ( (cAliasSWA)->WA_SLDANT * BuscaTaxa(SWB->WB_MOEDA,dDataBase,,.F.,.T.) ) / nTxDolar
         EndIf
         nPos := AScan( aFornec, { |x| x[1] == SWB->WB_FORN } )
         If nPos == 0
            SA2->( DBSeek(cFilSA2+SWB->WB_FORN) )
            AAdd( aFornec, { SWB->WB_FORN, SA2->A2_NREDUZ, nValor, { { (cAliasSWA)->WA_HAWB, Transform(nValor, cPicture) } } } )
         Else
            aFornec[nPos][3] += nValor
            AAdd( aFornec[nPos][4], { (cAliasSWA)->WA_HAWB, Transform( nValor, cPicture) } )
         EndIf
      EndIf
      (cAliasSWA)->( DBSkip() )
   EndDo
   (cAliasSWA)->( DBCloseArea() )

   If Len(aFornec) > 0
      ASort( aFornec, , , { |a,b| a[1]<b[1] } )
      For nInd := 1  to  Len(aFornec)
         AAdd( aEixoX, aFornec[nInd][2] )
         AAdd( aEixoY, aFornec[nInd][3] )
         AAdd( aTabela, { aFornec[nInd][2], aCabec, aFornec[nInd][4] } )
      Next nInd
   Else
      aEixoX  := { STR0003 }//"Não há Saldo de Pgtos. Antecipados"
      aEixoY  := { 0 }
      aTabela := { { "", aCabec, { { "", "0,00" } } } }
   EndIf

Return


********************************************************************************************************
Static Function EICPG06Qry()
********************************************************************************************************

 Local cQuery  := ""              ,;
       cFrom   := ""              ,;
       cWhere  := ""

   cQuery := " SELECT SWA.WA_HAWB, SWA.WA_PO_DI, SWA.WA_SLDANT "

   cFrom := "FROM "+RetSqlName("SWA")+" SWA "

   cWhere := "WHERE SWA.WA_FILIAL='"+cFilSWA+"' "+IIF(TcSrvType()<>"AS/400","AND SWA.D_E_L_E_T_ <> '*' ","")
   cWhere += "AND SWA.WA_PO_DI  = '"+ADIANTAMENTO+"' "
   cWhere += "AND SWA.WA_SLDANT > 0 "

   cQuery += cFrom+cWhere+" ORDER BY WA_HAWB "
   cQuery := ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW
   DBSelectArea("TRB")

Return