#include "protheus.ch"
#include "msgraphi.ch"  
#include "eecpg03.ch"

#Define AGENTE   "3"
#Define EMBARQUE "Q"

********************************************************************************************************
Function EECPG03()
********************************************************************************************************

 Local aRetPanel := {}       ,;
       TypeGraph := GRP_PIE  ,;
       cTitleG   := STR0001  ,;  //"Comissões por Período (em mil US$)"
       bClickG   := {||  }   ,;
       aEixoX    := {}       ,;
       aEixoY    := {}       ,;
       cTitleT   := STR0002  ,;  //"Embarques"
       bClickT   := {||  }   ,;
       aTabela   := {}       ,;
       aPeriodo  := {}

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
    
   //AOM - 01/09/10 
   Pergunte("EECPGOL3",.F.) 
   EECPG03ExX(@aEixoX,@aPeriodo)
   EECPG03Pro(aEixoX,aPeriodo,@aEixoY,@aTabela)

   aRetPanel := { TypeGraph ,{cTitleG, bClickG, aEixoX, aEixoY } , { cTitleT , bClickT, aTabela } }

Return aRetPanel


********************************************************************************************************
Static Function EECPG03ExX(aEixoX,aPeriodo)
********************************************************************************************************

 Local nMesIni   := 0                 ,;
       nAnoIni   := 0                 ,;
       nMesFim   := 0                 ,;
       nAnoFim   := 0                 ,;
       dDtIni    := CToD("  /  /  ")  ,;
       dDtFim    := CToD("  /  /  ")  ,;
       aData     := {}                ,;
       cDataBase := ""                ,;
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
Static Function EECPG03Pro(aEixoX,aPeriodo,aEixoY,aTabela)
********************************************************************************************************

 Local bWhile    := {|| }  ,;
       cFiltro   := ""     ,;
       aCabec    := {}     ,;
       aValores  := {}     ,;
       aComissao := {}     ,;
       cFilEEB   := ""     ,;
       cFilEEC   := ""     ,;
       cPicture  := ""     ,;
       nValor    := 0      ,;
       nPos      := 0      ,;
       nInd      := 1

   cPicture  := "@E 999,999,999.99"
   aCabec    := { AvSX3("EEC_PREEMB",5), AvSX3("EEB_TOTCOM",5)+STR0003 }  //" (em US$)"

   ChkFile("EEC")
   ChkFile("EEB")
   
   For nInd := 1  to  Len(aPeriodo)
      AAdd( aComissao, { Right(DToS(aPeriodo[nInd][1]),5), 0, { } } )
   Next nInd

   cFilEEB := xFilial("EEB")
   cFilEEC := xFilial("EEC")
   EEB->( DBSetOrder(1) )
   EEC->( DBSetOrder(12) )
   EEC->( DBSeek(cFilEEC+DToS(aPeriodo[1][1]),.T.) )  // SoftSeek com a menor data do Periodo
   
   Do While EEC->( !EoF()  .And.  EEC_FILIAL == cFilEEC  .And.  EEC_DTEMBA <= aPeriodo[Len(aPeriodo)][2] )
      nPos := AScan( aPeriodo, { |x| EEC->( EEC_DTEMBA >= x[1]  .And.  EEC_DTEMBA <= x[2] ) } )
      If nPos == 0
         EEC->( DBSkip() )
         Loop
      EndIf
      cChaveEEB := cFilEEB+EEC->EEC_PREEMB+EMBARQUE
      EEB->( DBSeek(cChaveEEB) )
      nValor := 0
      Do While EEB->( !EoF()  .And.  EEB_FILIAL+EEB_PEDIDO+EEB_OCORRE == cChaveEEB )
         If EEB->( Left(EEB_TIPOAG,1) != AGENTE )
            EEB->( DBSkip() )
            Loop
         EndIf
         If EEC->EEC_MOEDA == cMoeDolar
            nValor += EEB->EEB_TOTCOM
         Else
            nValor += ( EEB->EEB_TOTCOM * BuscaTaxa(EEC->EEC_MOEDA,dDataBase,,.F.,.T.) ) / nTxDolar
         EndIf
         EEB->( DBSkip() )
      EndDo
      If nValor > 0
         aComissao[nPos][2] += nValor/1000  // Valores em milhares
         AAdd( aComissao[nPos][3], { EEC->EEC_PREEMB, Transform( nValor, cPicture) } )
      EndIf
      EEC->( DBSkip() )
   EndDo

   For nInd := 1  to  Len(aComissao)
      aComissao[nInd][2] := Round( aComissao[nInd][2], 2 )
      If Empty(aComissao[nInd][3])
         AAdd(aComissao[nInd][3],{ "", "0,00" })
      EndIf
      AAdd( aEixoY, aComissao[nInd][2] )
      AAdd( aTabela, { aEixoX[nInd], aCabec, aComissao[nInd][3] } )
   Next nInd

Return
