#include "protheus.ch"
#Include "PanelOnLine.ch"
#Include "EECPGONL.ch"

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
Function EECPgOnL(oPGOnLine)
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
   cDescr     := STR0002 //"Valores das Exportações distribuídos por Período (Em Milhares)"
   nType      := 2
   cPergunte  := "EECPGOL1"
   cProcessa  := "EECPG01"
   nSegundos  := 900
   aToolBar   := {}
   nPadrao    := 3
   cID        := "01"

   PANELONLINE oPGOnline ADDPANEL      ;
               TITLE      cTitulo      ;
               DESCR      cDescr       ;
               TYPE       nType        ;
               PARAMETERS cPergunte    ;
               ONLOAD     cProcessa    ;
               REFRESH    nSegundos    ;
               TOOLBAR    aToolBar     ;
               DEFAULT    nPadrao      ;
               NAME       cID


   //************************************* Painel de Gestão 02 **************************************//

   cTitulo    := STR0003  //"Adiantamentos"
   cDescr     := STR0004  //"Adiantamentos Pendentes"
   nType      := 2
   cPergunte  := ""
   cProcessa  := "EECPG02"
   nSegundos  := 900
   aToolBar   := {}
   nPadrao    := 2
   cID        := "02"

   PANELONLINE oPGOnline ADDPANEL     ;
               TITLE       cTitulo    ;
               DESCR       cDescr     ;
               TYPE        nType      ;
               PARAMETERS  cPergunte  ;
               ONLOAD      cProcessa  ;
               REFRESH     nSegundos  ;
               TOOLBAR     aToolBar   ;
               DEFAULT     nPadrao    ;
               NAME        cID


   //************************************* Painel de Gestão 03 **************************************//

   cTitulo    := STR0005  //"Comissões"
   cDescr     := STR0006  //"Comissões de Agentes"
   nType      := 2
   cPergunte  := "EECPGOL3"
   cProcessa  := "EECPG03"
   nSegundos  := 900
   aToolBar   := {}
   nPadrao    := 2
   cID        := "03"

   PANELONLINE oPGOnline   ADDPANEL   ;
               TITLE       cTitulo    ;
               DESCR       cDescr     ;
               TYPE        nType      ;
               PARAMETERS  cPergunte  ;
               ONLOAD      cProcessa  ;
               REFRESH     nSegundos  ;
               TOOLBAR     aToolBar   ;
               DEFAULT     nPadrao    ;
               NAME        cID
               

   //************************************* Painel de Gestão 04 **************************************//

   cTitulo    := STR0007  //"Custo dos Processos"
   cDescr     := STR0008  //"Custo Médio dos Processos por Via de Transporte (em US$)"
   nType      := 2
   cPergunte  := "EECPGOL4"
   cProcessa  := "EECPG04"
   nSegundos  := 900
   aToolBar   := {}
   nPadrao    := 3
   cID        := "04"

   PANELONLINE oPGOnline ADDPANEL    ;
               TITLE      cTitulo    ;
               DESCR      cDescr     ;
               TYPE       nType      ;
               PARAMETERS cPergunte  ;
               ONLOAD     cProcessa  ;
               REFRESH    nSegundos  ;
               TOOLBAR    aToolBar   ;
               DEFAULT    nPadrao    ;
               NAME       cID


   //************************************* Painel de Gestão 05 **************************************//

   cTitulo    := STR0009  //"Processos"
   cDescr     := STR0010 //"Status dos Processos de Exportação"
   nType      := 2
   cPergunte  := "EECPGOL5"
   cProcessa  := "EECPG05"
   nSegundos  := 900
   aToolBar   := {}
   nPadrao    := 2
   cID        := "05"

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


   //************************************* Painel de Gestão 06 **************************************//

   cTitulo    := STR0011  //"Câmbio de Exportação"
   cDescr     := STR0012  //"Valores do Câmbio de Exportação por Período (Em Milhares)"
   nType      := 2
   cPergunte  := "EECPGOL6"
   cProcessa  := "EECPG06"
   nSegundos  := 0
   aToolBar   := {}
   nPadrao    := 3
   cID        := "06"

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


********************************************************************************************************
Function EECPGOnLVal(cCampo)
********************************************************************************************************

 Local lRet  := .T.  ,;
       nMes  := 0    ,;
       cMes1 := ""   ,;
       cAno1 := ""   ,;
       cMes2 := ""   ,;
       cAno2 := ""   ,;
       ni    := 1
 
   cCampo := Upper(cCampo)

   Begin Sequence

      Do Case

         Case cCampo $ "DTINICIAL___DTFINAL"
            If cCampo == "DTINICIAL"
               For ni := 1  to  Len(mv_par01)
                  If SubStr(mv_par01,ni,1) $ " -"
                     lRet := .F.
                     Break
                  EndIf
               Next ni
               nMes := Val(Left(mv_par01,2))
               If nMes < 1  .Or.  nMes > 12
                  lRet := .F.
                  Break
               EndIf
            EndIf
         
            If cCampo == "DTFINAL"
               For ni := 1  to  Len(mv_par02)
                  If SubStr(mv_par02,ni,1) $ " -"
                     lRet := .F.
                     Break
                  EndIf
               Next ni
               nMes := Val(Left(mv_par02,2))
               If nMes < 1  .Or.  nMes > 12
                  lRet := .F.
                  Break
               EndIf
            EndIf

            cMes1 := Left(mv_par01,2)
            cAno1 := Right(mv_par01,2)
            cMes2 := Left(mv_par02,2)
            cAno2 := Right(mv_par02,2)
            
            If !Empty(mv_par01)  .And.  !Empty(mv_par02)
               If cAno1 > cAno2
                  lRet := .F.
                  Break
               ElseIf cAno1 == cAno2
                  If cMes1 > cMes2
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

      EndCase
      
   End Sequence

Return lRet
