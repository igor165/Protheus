#include "protheus.ch"
#Include "PanelOnLine.ch"
#Include "EECPGONL.ch"

// [nType]    : Tipo do Painel de Gest�o OnLine
//              1 - Exibi��o de valores ( 1 dimens�o )
//              2 - Exibi��o de valores ( n dimens�es )
//              3 - Indicador ( 1 Valor )
//              4 - Indicador ( 2 Valores )
//              5 - Browse
// [cProcessa]: Fun��o que executa o processamento. Receber� os    // [nSegundos] : Tempo sugerido para refresh 
//              do painel. Caso seja colocado 0, n�o haver� refresh inicial.
// [aToolBar] : Array contendo as fun��es dispon�veis na barra de ferramentas. Cada posi��o do array ser� 
//              um outro array contendo : {nome do �cone, texto, bloco de a��o a ser executada}
// [nPadr�o]  : Apenas usado para o Tipo 2 de painel, informando qual o tipo de padr�o que ser� mostrado (1,2,3).
// [cID]      : Identificador ( para controle interno ) do Painel. Usar inicialmente n�meros seq�enciais e 
//              nunca dever� repetir o mesmo identificador dentro de uma mesma fun��o XXXPGOnL. 
// NOTIMER    : Desabilita o Timer ( O usu�rio n�o conseguir� definir um timer).

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

   //************************************* Painel de Gest�o 01 **************************************//

   cTitulo    := STR0001  //"Exporta��es por Per�odo"
   cDescr     := STR0002 //"Valores das Exporta��es distribu�dos por Per�odo (Em Milhares)"
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


   //************************************* Painel de Gest�o 02 **************************************//

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


   //************************************* Painel de Gest�o 03 **************************************//

   cTitulo    := STR0005  //"Comiss�es"
   cDescr     := STR0006  //"Comiss�es de Agentes"
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
               

   //************************************* Painel de Gest�o 04 **************************************//

   cTitulo    := STR0007  //"Custo dos Processos"
   cDescr     := STR0008  //"Custo M�dio dos Processos por Via de Transporte (em US$)"
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


   //************************************* Painel de Gest�o 05 **************************************//

   cTitulo    := STR0009  //"Processos"
   cDescr     := STR0010 //"Status dos Processos de Exporta��o"
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


   //************************************* Painel de Gest�o 06 **************************************//

   cTitulo    := STR0011  //"C�mbio de Exporta��o"
   cDescr     := STR0012  //"Valores do C�mbio de Exporta��o por Per�odo (Em Milhares)"
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
