#include "protheus.ch"
#Include "PanelOnLine.ch"
#Include "ECOPGONL.ch"

// [nType]    : Tipo do Painel de Gestão OnLine
//              1 - Exibição de valores ( 1 dimensão )
//              2 - Exibição de valores ( n dimensões )
//              3 - Indicador ( 1 Valor )
//              4 - Indicador ( 2 Valores )
//              5 - Browse
// [cProcessa]: Função que executa o processamento. Receberá os    // [nSegundos] : Tempo sugerido para refresh 
//              do painel. Caso seja colocado 0, não haverá refresh inicial.
// [aToolBar] : Array contendo as funções disponíveis na barra de ferramentas. Cada posição do array será 
//              um outro array contendo : {nome do ícone, texto, bloco de ação a ser executada}
// [nPadrão]  : Apenas usado para o Tipo 2 de painel, informando qual o tipo de padrão que será mostrado (1,2,3).
// [cID]      : Identificador ( para controle interno ) do Painel. Usar inicialmente números seqüenciais e 
//              nunca deverá repetir o mesmo identificador dentro de uma mesma função XXXPGOnL. 
// NOTIMER    : Desabilita o Timer ( O usuário não conseguirá definir um timer).

********************************************************************************************************
Function ECOPgOnL(oPGOnLine)
********************************************************************************************************

 Local cTitulo    := ""   ,;
       cDescr     := ""   ,;
       nType      := 0    ,;
       cPergunte  := ""   ,;
       cProcessa  := ""   ,;
       nSegundos  := 0    ,;
       aToolBar   := {}   ,;
       nPadrao    := 0    ,;
       cID        := ""


   //************************************* Painel de Gestão 01 **************************************//

   cTitulo    := STR0001  //"Exportações por Período"
   cDescr     := STR0002  //"Valores das Exportações distribuídos por Período"
   nType      := 2
   cPergunte  := "EECPGOL1"
   cProcessa  := "EECPG01"
   nSegundos  := 900
   aToolBar   := {}
   nPadrao    := 3
   cID        := "01"

   PANELONLINE oPGOnline  ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID


   //************************************* Painel de Gestão 02 **************************************//

   cTitulo    := STR0003  //"Processos"
   cDescr     := STR0004  //"Status dos Processos de Exportação"
   nType      := 2
   cPergunte  := "EECPGOL5"
   cProcessa  := "EECPG05"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 2
   cID        := "02"

   PANELONLINE oPGOnline ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID

   //************************************* Painel de Gestão 03 **************************************//

   cTitulo    := STR0005  //"Câmbio de Exportação"
   cDescr     := STR0006  //"Valores do Câmbio de Exportação por Período"
   nType      := 2
   cPergunte  := "EECPGOL6"
   cProcessa  := "EECPG06"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 3
   cID        := "03"

   PANELONLINE oPGOnline ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID

   //************************************* Painel de Gestão 04 **************************************//

   cTitulo    := STR0007  //"Câmbio de Importação"
   cDescr     := STR0008  //"Valores do Câmbio de Importação por Período"
   nType      := 2
   cPergunte  := "EICPGOL5"
   cProcessa  := "EICPG05"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 3
   cID        := "04"

   PANELONLINE oPGOnline ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID

   //************************************* Painel de Gestão 05 **************************************//

   cTitulo    := STR0009  //"Resumo do Financiamento"
   nType      := 1
   cPergunte  := "EFFPGOL3"
   cProcessa  := "EFFPG03"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 0
   cID        := "05"

   cDescr     := STR0010  //"Informações resumidas sobre os contratos de Financiamento"


   PANELONLINE oPGOnline ADDPANEL      ;
               TITLE       cTitulo      ;
               DESCR       cDescr       ;
               TYPE        nType        ;
               PARAMETERS  cPergunte    ;
               ONLOAD      cProcessa    ;
               REFRESH     nSegundos    ;
               TOOLBAR     aToolBar     ;
               DEFAULT     nPadrao      ;
               NAME        cID

Return