#include "protheus.ch"
#include "msgraphi.ch"           
#include "Eicpg03.ch"

#Define ABERTO       1
#Define ENCAMINHADO  2
#Define ENCERRADO    3

********************************************************************************************************
Function EICPG03()
********************************************************************************************************

 Local aRetPanel := {}       ,;
       TypeGraph := GRP_PIE  ,;
       cTitleG   := STR0001  ,; //"Quantidade de P.O."
       bClickG   := {||  }   ,;
       aEixoX    := {}       ,;
       aEixoY    := {}       ,;
       cTitleT   := STR0002  ,; //"Purchase Orders"    
       bClickT   := {||  }   ,;
       aTabela   := {}       ,;
       aProcesso := {}       ,;
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


   aEixoX := { STR0003, STR0004, STR0005 } //"Abertos", "Encaminhados", "Encerrados"
   EICPG03Per( @dDtIni, @dDtFim )
   EICPG03Pro( aEixoX, @aEixoY, @aTabela )

   aRetPanel := { TypeGraph ,{ cTitleG, bClickG, aEixoX, aEixoY } , { cTitleT , bClickT, aTabela } }

Return aRetPanel


********************************************************************************************************
Static Function EICPG03Per( dDtIni, dDtFim )
********************************************************************************************************

 Local nMesFim   := 0   ,;
       nAnoFim   := 0   ,;
       cDataBase := ""

   Pergunte("EICPGOL3", .F.)
   
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
Static Function EICPG03Pro( aEixoX, aEixoY, aTabela )
********************************************************************************************************

 Local aCabec       := {}   ,;
       aPedidos     := {}   ,;
       aItens       := {}   ,;
       cFilSW2      := ""   ,;
       cFilSW3      := ""   ,;
       cFilSW6      := ""   ,;
       cFilSW7      := ""   ,;
       cChaveSW3    := ""   ,;
       cChaveSW7    := ""   ,;
       nStatus      := 0    ,;
       nSaldo       := 0    ,;
       nInd         := 1    ,;
       nPos         := 0    ,;
       lEncaminhado := .F.

   aCabec   := { AvSX3("W2_PO_NUM",5), AvSX3("W2_PO_DT",5) }
   aEixoY   := { 0, 0, 0 }
   aPedidos := { {}, {}, {} }
   
   ChkFile("SW2")
   ChkFile("SW3")
   ChkFile("SW6")
   ChkFile("SW7")

   cFilSW2 := xFilial("SW2")
   cFilSW3 := xFilial("SW3")
   cFilSW6 := xFilial("SW6")
   cFilSW7 := xFilial("SW7")
   SW2->( DBSetOrder(4) )
   SW3->( DBSetOrder(1) )
   SW6->( DBSetOrder(1) )
   SW7->( DBSetOrder(2) )

   SW2->( DBSeek(cFilSW2+DToS(dDtIni),.T.) )  // SoftSeek utilizando a menor data

   Do While SW2->( !EoF()  .And.  W2_FILIAL == cFilSW2  .And.  W2_PO_DT <= dDtFim )
      cChaveSW3 := cFilSW3+SW2->W2_PO_NUM 
      SW3->( DBSeek(cChaveSW3) )
      lEncaminhado := .F.
      aItens  := {}
      nStatus := ABERTO  // 1
      nSaldo  := 0
      Do While SW3->( !EoF()  .And.  W3_FILIAL+W3_PO_NUM == cChaveSW3 )
         If SW3->W3_SEQ == 0
            AAdd( aItens, { SW3->W3_POSICAO, SW3->W3_QTDE } )
            cChaveSW7 := cFilSW7+SW3->W3_PO_NUM
            SW7->( DBSeek(cChaveSW7) )
            Do While SW7->( !EoF()  .And.  W7_FILIAL+W7_PO_NUM == cChaveSW7 )
               SW6->( DBSeek(cFilSW6+SW7->W7_HAWB) )
               If !Empty(SW6->W6_DT_ENTR)
                  If (nPos := AScan( aItens, { |x| x[1]==SW7->W7_POSICAO .And. SW3->W3_POSICAO==SW7->W7_POSICAO  } )) > 0  // TLM 27/11/2007
                     aItens[nPos][2] -= SW7->W7_QTDE 
                  EndIf   
               Else
                  nStatus := ENCAMINHADO  // 2
                  Exit
               EndIf
               lEncaminhado := .T.  //TLM 27/11/2007  
               SW7->( DBSkip() )
            EndDo
         //Else  
            //lEncaminhado := .T.
         EndIf
         If nStatus == ENCAMINHADO  // 2
            Exit
         EndIf
         SW3->( DBSkip() )
      EndDo      
      If lEncaminhado
         For nInd := 1  to  Len(aItens)
            nSaldo += aItens[nInd][2]
            If nSaldo > 0
               Exit
            EndIf
         Next nInd
         If nSaldo == 0
            nStatus := ENCERRADO  // 3
         Else
            nStatus := ENCAMINHADO  // 2
         EndIf
      EndIf
      aEixoY[nStatus] += 1
      AAdd( aPedidos[nStatus], { SW2->W2_PO_NUM, SW2->W2_PO_DT } )
      SW2->( DBSkip() )
   EndDo

   For nInd := 1  to  Len(aEixoX)
      AAdd( aTabela, { aEixoX[nInd], aCabec, IIF( !Empty(aPedidos[nInd]), aPedidos[nInd], { { "", "  /  /  " } } ) } )
   Next nInd

Return
