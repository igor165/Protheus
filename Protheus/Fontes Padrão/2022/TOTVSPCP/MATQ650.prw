#include "protheus.ch"
#include "quicksearch.ch"
#include "matq650.ch"

   QSSTRUCT MATA650 DESCRIPTION STR0001 /*Ordem de produção*/ MODULE 10
   
   QSMETHOD INIT QSSTRUCT MATA650
   
   QSTABLE "SC2" JOIN "SB1" ON "C2_PRODUTO = B1_COD"
   QSTABLE "SC2" LEFT JOIN "SC5" ON "C2_PEDIDO = C5_NUM"
   QSTABLE "SC5" LEFT JOIN "SA1" ON "C5_CLIENTE = A1_COD"
   
   // campos do SX3 e indices do SIX
   QSPARENTFIELD "C2_PRODUTO" INDEX ORDER 2
   QSPARENTFIELD "B1_DESC"    INDEX ORDER 3 LABEL STR0002 /*Descrição*/
   QSPARENTFIELD "A1_COD"     INDEX ORDER 1 LABEL STR0003 /*Cliente*/  
   QSPARENTFIELD "A1_NOME"    INDEX ORDER 2
   QSPARENTFIELD "A1_CGC"     INDEX ORDER 3
   
   // campos do SX3
   QSFIELD "C2_NUM"    LABEL STR0004 /*Número da OP*/,;
           "C2_ITEM",;
           "C2_SEQUEN" LABEL STR0005 /*Sequência*/,;
           "C2_PRODUTO",;
           "B1_DESC"   LABEL STR0002 /*Descrição*/,;
           "C2_STATUS" LABEL STR0007 /*Situação*/,;
           "C2_TPOP",;
           "C2_QUANT",;
           "C2_DATPRI",;
           "C2_DATPRF",;
           "C2_PEDIDO",;
           "C5_CLIENTE",;
           "A1_NOME"
   QSFIELD "Saldo" EXPRESSION "C2_QUANT-C2_QUJE" LABEL STR0006 /*Saldo*/ FIELDS "C2_QUANT","C2_QUJE"  TYPE "N" SIZE 15 DECIMAL 2 
   
   // acoes do menudef, MVC ou qualquer rotina
   QSACTION MENUDEF "MATA650" OPERATION 2 LABEL STR0030 /*Ordens de produção*/
   
   // acoes do menudef, MVC ou qualquer rotina
   /*
   
      C2_TPOP = P - Prevista
                F - Firme
      
      C2_STATUS = U - Suspensa
                  S - Sacramentada
                  N - Normal 
   
   */
   QSFILTER STR0008 /*Todos*/;
      WHERE "1=1"
   QSFILTER STR0009 /*Prevista e Suspensa*/;
      WHERE "C2_TPOP = 'P' AND C2_STATUS = 'U'"
   QSFILTER STR0010 /*Prevista e Sacramentada*/;
      WHERE "C2_TPOP = 'P' AND C2_STATUS = 'S'"
   QSFILTER STR0011 /*Prevista e Normal*/;
      WHERE "C2_TPOP = 'P' AND C2_STATUS = 'N'"
   QSFILTER STR0012 /*Prevista e Suspensa - Sacramentada*/;
      WHERE "C2_TPOP = 'P' AND C2_STATUS IN ('U','S')"
   QSFILTER STR0013 /*Prevista e Suspensa - Normal*/;
      WHERE "C2_TPOP = 'P' AND C2_STATUS IN ('U','N')"
   QSFILTER STR0014 /*Prevista e Normal - Sacramentada*/;
      WHERE "C2_TPOP = 'P' AND C2_STATUS IN ('N','S')"
   QSFILTER STR0015 /*Prevista e Suspensa - Sacramentada - Normal*/;
      WHERE "C2_TPOP = 'P' AND C2_STATUS IN ('U','S','N')"
   QSFILTER STR0016 /*Firme e Suspensa*/;
      WHERE "C2_TPOP = 'F' AND C2_STATUS = 'U'"
   QSFILTER STR0017 /*Firme e Sacramentada*/;
      WHERE "C2_TPOP = 'F' AND C2_STATUS = 'S'"
   QSFILTER STR0018 /*Firme e Normal*/;
      WHERE "C2_TPOP = 'F' AND C2_STATUS = 'N'"
   QSFILTER STR0019 /*Firme e Suspensa - Sacramentada*/;
      WHERE "C2_TPOP = 'F' AND C2_STATUS IN ('U','S')"
   QSFILTER STR0020 /*Firme e Suspensa - Normal*/;
      WHERE "C2_TPOP = 'F' AND C2_STATUS IN ('U','N')"
   QSFILTER STR0021 /*Firme e Normal - Sacramentada*/;
      WHERE "C2_TPOP = 'F' AND C2_STATUS IN ('N','S')"
   QSFILTER STR0022 /*Firme e Suspensa - Sacramentada - Normal*/;
      WHERE "C2_TPOP = 'F' AND C2_STATUS IN ('U','S','N')"
   QSFILTER STR0023 /*Prevista - Firme e Suspensa*/;
      WHERE "C2_TPOP IN ('P','F') AND C2_STATUS = 'U'"
   QSFILTER STR0024 /*Prevista - Firme e Sacramentada*/;
      WHERE "C2_TPOP IN ('P','F') AND C2_STATUS = 'S'"
   QSFILTER STR0025 /*Prevista - Firme e Normal*/;
      WHERE "C2_TPOP IN ('P','F') AND C2_STATUS = 'N'"
   QSFILTER STR0026 /*Prevista - Firme e Suspensa - Sacramentada*/;
      WHERE "C2_TPOP IN ('P','F') AND C2_STATUS IN ('U','S')"
   QSFILTER STR0027 /*Prevista - Firme e Suspensa - Normal*/;
      WHERE "C2_TPOP IN ('P','F') AND C2_STATUS IN ('U','N')"
   QSFILTER STR0028 /*Prevista - Firme e Normal - Sacramentada*/;
      WHERE "C2_TPOP IN ('P','F') AND C2_STATUS IN ('N','S')"
   QSFILTER STR0029 /*Prevista - Firme e Suspensa - Sacramentada - Normal*/;
      WHERE "C2_TPOP IN ('P','F') AND C2_STATUS IN ('U','S','N')"
Return
