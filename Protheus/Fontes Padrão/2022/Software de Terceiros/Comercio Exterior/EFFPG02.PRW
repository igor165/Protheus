#include "protheus.ch"
#include "msgraphi.ch"  
#include "effpg02.ch

#Define EV_ENCERR "180"
#Define EV_TRANSF "190"
#Define IMP       "I"

********************************************************************************************************
Function EFFPG02()
********************************************************************************************************

 Local aRetPanel := {}                       ,;
       TypeGraph := GRP_PIE                  ,;
       cTitleG   := STR0001                  ,;//"Valores dos Contratos"
       bClickG   := {|| }                    ,;
       cTitleT   := STR0002                  ,;//"Contratos" 
       bClickT   := {||  }
       
 Private aEixoX    := {}  ,;
         aEixoXCod := {}  ,;
         aEixoY    := {}  ,;
         aTabela   := {}

 Private cMoeDolar := EasyGParam("MV_SIMB2",,"US$")

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

   EFFPG02ExX()  // Monta aEixoX e aEixoXCod
   EFFPG02Tab()  // Monta aTabela, aEixoY e corrige aEixoX
   
   aRetPanel := { TypeGraph ,{cTitleG, bClickG, aEixoX, aEixoY } , { cTitleT , bClickT, aTabela } }

Return aRetPanel


********************************************************************************************************
Static Function EFFPG02ExX()
********************************************************************************************************

 Local cFilEF7 := xFilial("EF7")

   EF7->( DBSetOrder(1) )
   EF7->( DBSeek(cFilEF7) )
   Do While EF7->( !EoF()  .And.  EF7_FILIAL == cFilEF7 )
      AAdd(aEixoX   ,EF7->EF7_DESCRI)
      AAdd(aEixoXCod,EF7->EF7_FINANC)
      EF7->( DBSkip() )
   EndDo

Return


********************************************************************************************************
Static Function EFFPG02Tab()
********************************************************************************************************

 Local cFilEF1   := xFilial("EF1")             ,;
       cFilEF3   := xFilial("EF3")             ,;
       ni        := 1                          ,;
       cChaveEF1 := ""                         ,;
       cChaveEF3 := ""                         ,;
       cFiltro   := ""                         ,;
       nVlContra := 0                          ,;
       nVlTipo   := 0                          ,;
       aValores  := {}                         ,;
       lHaDados  := .F.                        ,;
       aEixoXAux := {}                         ,;
       aCabec    := { AvSX3("EF1_CONTRA",5)    ,;
                      AvSX3("EF1_VL_MOE",5)    ,;
                      AvSX3("EF1_BAN_FI",5) }
 Local dDtIni, dDtFim

   If Empty(mv_par02)
      dDtFim := dDatabase
   Else
      dDtFim := CToD("30/"+mv_par02)
   EndIf
   If Empty(mv_par01)
      dDtIni := dDtFim - 180//6 Meses antes
   Else
      dDtIni := CToD("01/"+mv_par01)
   EndIf
  
   EF1->( DBSetOrder(2) )
   EF3->( DBSetOrder(1) )

   For ni := 1  to  Len(aEixoXCod)

      aValores  := {}
      nVlTipo   := 0
      cFiltro   := aEixoX[ni]
      cChaveEF1 := cFilEF1+aEixoXCod[ni]
      lHaDados  := .F.

      EF1->( DBSeek(cChaveEF1) )

      Do While EF1->( !EoF()  .And.  EF1_FILIAL+EF1_TP_FIN == cChaveEF1 )

         cChaveEF3 := cFilEF3+EF1->( EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT )

         If !Empty(EF1->EF1_DT_ENC)
            EF1->( DBSkip() )
            Loop
         ElseIf EF1->EF1_DT_CON > dDtFim
            EF1->( DBSkip() )
            Loop
         ElseIf EF1->EF1_DT_VEN < dDtIni
            EF1->( DBSkip() )
            Loop
         ElseIf EF3->( DBSeek(cChaveEF3+EV_ENCERR) )  // "180"
            EF1->( DBSkip() )
            Loop
         ElseIf EF3->( DBSeek(cChaveEF3+EV_TRANSF) )  // "190"
            EF1->( DBSkip() )
            Loop
         ElseIf EF1->( EF1_TPMODU == IMP  .And.  ( Empty(EF1_DT_JUR)  .Or.  EF1_DT_JUR > dDtFim ) )  // "I"
            EF1->( DBSkip() )
            Loop
         EndIf

         If EF1->EF1_MOEDA == cMoeDolar
            nVlContra := EF1->EF1_VL_MOE
         Else
            nVlContra := ( EF1->EF1_VL_MOE * BuscaTaxa(EF1->EF1_MOEDA,dDataBase,,.F.,.T.) ) / nTxDolar
         EndIf

         AAdd( aValores, { EF1->EF1_CONTRA, nVlContra, EF1->EF1_BAN_FI } )

         nVlTipo += nVlContra
         
         lHaDados := .T.

         EF1->( DBSkip() )
      EndDo

      If lHaDados
         AAdd( aEixoXAux , aEixoX[ni] )
         AAdd( aEixoY , nVlTipo )
         AAdd( aTabela, { cFiltro, aCabec, aValores } )
      EndIf

   Next ni
   
   aEixoX := AClone( aEixoXAux )
   
Return