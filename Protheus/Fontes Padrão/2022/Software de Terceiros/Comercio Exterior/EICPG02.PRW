#include "protheus.ch"
#include "msgraphi.ch"    
#include "eicpg02.ch"

#Define SEM_EMBARQUE  1
#Define EMBARCADO     2
#Define DESEMBARACADO 3

********************************************************************************************************
Function EICPG02()
********************************************************************************************************

 Local aRetPanel := {}                    ,;
       TypeGraph := GRP_PIE               ,;
       cTitleG   := STR0001               ,; //"Processos"    
       bClickG   := {||   }               ,;
       aEixoX    := {}                    ,;
       aEixoY    := {}                    ,;
       cTitleT   := STR0001               ,; //"Processos"
       bClickT   := {||   }               ,;
       aTabela   := {}                    ,;
       aProcesso := {}                    ,;
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

   aEixoX := {STR0002, STR0003, STR0004} //"Não Embarcados", "Embarcados", "Desembaraçados"
   EICPG02Per( @dDtIni, @dDtFim )
   EICPG02Pro( aEixoX, @aEixoY, @aTabela )

   aRetPanel := { TypeGraph ,{ cTitleG, bClickG, aEixoX, aEixoY } , { cTitleT , bClickT, aTabela } }

Return aRetPanel


********************************************************************************************************
Static Function EICPG02Per( dDtIni, dDtFim )
********************************************************************************************************

 Local nMesFim   := 0  ,;
       nAnoFim   := 0  ,;
       cDataBase := ""

   Pergunte("EICPGOL2", .F.)
   
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
Static Function EICPG02Pro( aEixoX, aEixoY, aTabela )
********************************************************************************************************

 Local aCabec     := {}  ,;
       aProcessos := {}  ,;
       cFilSW6    := ""  ,;
       nStatus    := 0   ,;
       nInd       := 1

   aCabec     := { AvSX3("W6_HAWB",5), AvSX3("W6_DT_EMB",5), AvSX3("W6_DT_DESE",5) }
   aEixoY     := { 0, 0, 0 }
   aProcessos := { {}, {}, {} }
   
   ChkFile("SW6")

   cFilSW6 := xFilial("SW6")
   SW6->( DBSetOrder(2) )
   SW6->( DBSeek(cFilSW6) )

   Do While SW6->( !EoF()  .And.  W6_FILIAL == cFilSW6  .And.  Empty(W6_DT_DESE) )
      If SW6->W6_TIPOFEC != "DI"  .And.  SW6->W6_TIPOFEC != "DIN"
         SW6->( DBSkip() )
         Loop
      EndIf
      If Empty(SW6->W6_DT_EMB)
         nStatus := SEM_EMBARQUE  // "1"
      Else
         nStatus := EMBARCADO  // "2"
      EndIf
      aEixoY[nStatus] += 1
      AAdd( aProcessos[nStatus], { SW6->W6_HAWB, SW6->W6_DT_EMB, SW6->W6_DT_DESE } )
      SW6->( DBSkip() )
   EndDo
   SW6->( DBSeek(cFilSW6+DToS(dDtIni),.T.) )  // SoftSeek utilizando primeira data
   Do While SW6->( !EoF()  .And.  W6_FILIAL == cFilSW6  .And.  W6_DT_DESE <= dDtFim )
      If SW6->W6_TIPOFEC != "DI"  .And.  SW6->W6_TIPOFEC != "DIN"
         SW6->( DBSkip() )
         Loop
      EndIf
      nStatus := DESEMBARACADO  //"3"
      aEixoY[nStatus] += 1
      AAdd( aProcessos[nStatus], { SW6->W6_HAWB, SW6->W6_DT_EMB, SW6->W6_DT_DESE } )
      SW6->( DBSkip() )
   EndDo

   For nInd := 1  to  Len(aEixoX)
      AAdd( aTabela, { aEixoX[nInd], aCabec, IIF( !Empty(aProcessos[nInd]), aProcessos[nInd], { { "", "  /  /  ", "  /  /  " } } ) } )
   Next nInd

Return
