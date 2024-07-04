#include "protheus.ch"
#include "msgraphi.ch" 
#include "eecpg02.ch"
#Include "TOPCONN.CH"

#Define ADIANTAMENTO "A"
#Define EV_ADIANT    "605"
#Define CLIENTE      "C"

********************************************************************************************************
Function EECPG02()
********************************************************************************************************

 Local aRetPanel := {}                         ,;
       TypeGraph := GRP_PIE                    ,;
       cTitleG   := STR0001+STR0004            ,;//"Adiantamentos por Importador"+" (em mil US$)"
       bClickG   := {||  }                     ,;
       aEixoX    := {}                         ,;
       aEixoY    := {}                         ,;
       cTitleT   := STR0002                    ,;//"Adiantamentos" 
       bClickT   := {||  }                     ,;
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
            nTxDolar  := 0   ,;
            lTop      := .F.

   cMoeDolar := EasyGParam("MV_EECUSS",,"US$")
   nTxDolar  := BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.)
   
   Pergunte("EECPGOL2",.F.)
   #IFDEF TOP
      lTop := .T.                
   #ENDIF

   EECPG02Pro(@aEixoX,@aEixoY,@aTabela)

   aRetPanel := { TypeGraph ,{cTitleG, bClickG, aEixoX, aEixoY } , { cTitleT , bClickT, aTabela } }


Return aRetPanel


********************************************************************************************************
Static Function EECPG02Pro(aEixoX,aEixoY,aTabela)
********************************************************************************************************

 Local cAliasEEQ := ""     ,;
       bWhile    := {|| }  ,;
       bCond     := {|| }  ,;
       cFiltro   := ""     ,;
       aCabec    := {}     ,;
       aValores  := {}     ,;
       aImport   := {}     ,;
       nTamIKey  := 0      ,;
       cImpKey   := ""     ,;
       cFilSA1   := ""     ,;
       cPicture  := ""     ,;
       nValor    := 0      ,;
       nPos      := 0      ,;
       nInd      := 1

 Private cFilEEQ := xFilial("EEQ")

   cPicture  := "@E 999,999,999.99"
   aCabec    := { AvSX3("EEQ_NRINVO",5), AvSX3("EEQ_SALDO",5)+STR0004 }  //" (em mil US$)"

   ChkFile("SA1")
   ChkFile("EEQ")

   cFilSA1  := xFilial("SA1")
   nTamIKey := AvSX3("A1_COD" ,3)+AvSX3("A1_LOJA",3)
   SA1->( DBSetOrder(1) )
   
   If lTop
      EECPG02Qry()
      bWhile := { || .T. }
      bCond  := { || .T. }
      cAliasEEQ := "TRB"
      TRB->( DBGoTop() )
   Else
      bWhile := { || EEQ->( EEQ_FILIAL == cFilEEQ  .And.  EEQ_FASE == CLIENTE ) }
      bCond  := { || EEQ->( EEQ_EVENT == EV_ADIANT  .And.  EEQ_TIPO == ADIANTAMENTO  .And.  EEQ_SALDO > 0 ) }
      cAliasEEQ := "EEQ"
      EEQ->( DBSetOrder(6) )
      EEQ->( DBSeek(cFilEEQ+ADIANTAMENTO) )
   EndIf
   
   Do While (cAliasEEQ)->( !EoF() )  .And.  Eval(bWhile)
      If !Eval(bCond)
         (cAliasEEQ)->( DBSkip() )
         Loop
      EndIf
      If (cAliasEEQ)->EEQ_MOEDA == cMoeDolar
         nValor := (cAliasEEQ)->EEQ_SALDO
      Else
         nValor := ( (cAliasEEQ)->EEQ_SALDO * BuscaTaxa((cAliasEEQ)->EEQ_MOEDA,dDataBase,,.F.,.T.) ) / nTxDolar
      EndIf
      nValor /= 1000  // Valores em milhares de dólares
      cImpKey := Left( (cAliasEEQ)->EEQ_PREEMB, nTamIKey )
      nPos := AScan( aImport, { |x| x[1] == cImpKey } )
      If nPos == 0
         SA1->( DBSeek(cFilSA1+cImpKey) )
         AAdd( aImport, { cImpKey, SA1->A1_NREDUZ, nValor, { { (cAliasEEQ)->EEQ_NRINVO, Transform( nValor, cPicture) } } } )
      Else
         aImport[nPos][3] += nValor
         AAdd( aImport[nPos][4], { (cAliasEEQ)->EEQ_NRINVO, Transform( nValor, cPicture) } )
      EndIf                
      (cAliasEEQ)->( DBSkip() )
   EndDo
   (cAliasEEQ)->( DBCloseArea() )

   If Len(aImport) > 0
      ASort( aImport, , , { |a,b| a[1]<b[1] } )
      For nInd := 1  to  Len(aImport)
         AAdd( aEixoX, aImport[nInd][2] )
         AAdd( aEixoY, Round(aImport[nInd][3],2) )
         AAdd( aTabela, { aImport[nInd][2], aCabec, aImport[nInd][4] } )
      Next nInd
   Else
      aEixoX  := { STR0003 }//"Não há Saldo de Adiantamentos"
      aEixoY  := { 0 }
      aTabela := { { "", aCabec, { { "", "0,00" } } } }
   EndIf

Return


********************************************************************************************************
Static Function EECPG02Qry()
********************************************************************************************************

 Local cQuery  := ""              ,;
       cFrom   := ""              ,;
       cWhere  := ""

   cQuery := " SELECT EEQ.EEQ_PREEMB, EEQ.EEQ_NRINVO, EEQ.EEQ_MOEDA, EEQ.EEQ_SALDO "

   cFrom := "FROM "+RetSqlName("EEQ")+" EEQ "

   cWhere := "WHERE EEQ.EEQ_FILIAL='"+cFilEEQ+"' "+IIF(TcSrvType()<>"AS/400","AND EEQ.D_E_L_E_T_ <> '*' ","")
   cWhere += "AND EEQ.EEQ_EVENT = '"+EV_ADIANT+"' "
   cWhere += "AND EEQ.EEQ_FASE  = '"+CLIENTE+"' "
   cWhere += "AND EEQ.EEQ_TIPO  = '"+ADIANTAMENTO+"' "
   cWhere += "AND EEQ.EEQ_SALDO > 0 "

   cQuery += cFrom+cWhere+" ORDER BY EEQ_PREEMB "
   cQuery := ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW
   DBSelectArea("TRB")

Return
