//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICTR320.CH"

#COMMAND E_RESET_AREA => SW6->(DBSETORDER(1)) ; SY9->(DBSETORDER(1)) ;
                       ; SA5->(DBSETORDER(1)) ; DBSELECTAREA(nOldArea)
/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR320 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 27.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ S.I.s fora do Lead Time                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR320()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// EOS - OS 578/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR320
// um parametro como .T. identificando que é schedulado 
******************
Function EICTR320S
******************
EICTR320(.T.)
RETURN NIL

Function EICTR320(lSXD)

EICTR320R3(lSXD,.T.)
***********************
Function EICTR320R3(lSXD,p_R4)
***********************
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),AVSX3("W0__CC",5),ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))
LOCAL WorkFile, nOldArea := SELECT(), cTitulo, oDlg, oGet, oPanel, nOpcA := 0, bMsg, aRCampos := aCordTela := {}

LOCAL T_DBF:={ { "WKCC"      , "C" ,  AVSX3("W1_CC",3) , 0 } ,;
               { "WKCOD_I"   , "C" , AVSX3("W1_COD_I",3) , 0 } ,;
               { "WKDESC"    , "C" , 36 , 0 } ,;
               { "WKNUM_SI"  , "C" ,  AVSX3("W1_SI_NUM",3) , 0 } ,;
               { "WKDT_ENT_P", "D" ,  8 , 0 } ,;
               { "WKDT_ENT_E", "D" ,  8 , 0 } ,;
               { "WKDT_SI"   , "D" ,  8 , 0 } ,;
               { "WKPRAZ_S"  , "N" ,  5 , 0 } ,;
               { "WKPRAZ_P"  , "N" ,  5 , 0 } ,;
               { "WKPRAZ_R"  , "N" ,  5 , 0 } ,;
               { "OR_FILIAL" , "C" ,  2 , 0 } ,;
               { "WKFORN"    , "C" ,  AVSX3("A2_COD",3)+AVSX3("A2_NREDUZ",3) , 0 } }

LOCAL TB_Campos:={ ;
      {"WKCC"       ,"", _LIT_R_CC                    } ,;
      {"WKNUM_SI"   ,"", OemToAnsi(STR0001)  ,_PictSI } ,; //"N§ S.I."
      {"WKDT_SI"    ,"", STR0002                      } ,; //"Dt. S.I."
      {"WKCOD_I"    ,"", STR0003,_PictItem            } ,; //"Item"
      {"WKDESC"     ,"", OemToAnsi(STR0004)           } ,; //"Descri‡ao"
      {"WKFORN"     ,"", STR0005                      } ,; //"Fornecedor"
      {"WKDT_ENT_P" ,"", OemToAnsi(STR0006)           } ,; //"Previsao Entrega"
      {"WKDT_ENT_E" ,"", STR0007                      } ,; //"Entrega"
      {"WKPRAZ_S"   ,"", STR0008                      } ,; //"Prazo Solicitado"
      {"WKPRAZ_P"   ,"", STR0009                      } ,; //"Prazo Previsto"
      {"WKPRAZ_R"   ,"", STR0010                      } }  //"Prazo Realizado"

LOCAL aDados :={STR0011,; //"Work"
                STR0012,; //"Este relatorio ir  exibir um estat¡stica sobre"
                STR0013,; //"as S.I.s atendidas acima do prazo solicitado."
                "",;
                "G",;
                132,;
                "",;
                "",;
                STR0014,; //"S.I.s fora de Lead Time"
                { "Zebrado", 1,"Importa‡Æo", 1, 2, 1, "",1 },;
                STR0015,; //"EICTR320"
                { {|| .T. } , {|| .T. }  }  }

PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE cCadastro := OemtoAnsi(STR0016), TCod_I, TDt_I, TDt_F //"S.I.s fora do Lead Time"
Private aHeader[0], nUsado:=0, aReturn := aDados[10]
Private lEmail := !lSXD = NIL  // EOS - OS 578/02
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()                                                                  
Private lDiasUteis := .F. //TRP-23/08/07
Private nPrazo
Private cCpoAval1 := "W0__DT"  //TRP-23/08/07
Private cCpoAval2 := "W1_DTENTR_"
Private cCpoAval3 := "W6_DT_ENTR"

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKCC+WKNUM_SI+WKCOD_I")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Data inicial                               ³
//³ mv_par02      // Data final                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// EOS - OS 578/02 Se for schedulado, chama o pergunte como .F. somente para
// inicializar as variaveis mv_par?? e atraves do setprint carrega as variaveis
IF !Pergunte("EIC010",IIF(lEmail,.F.,.T.)) 
   Work->(E_EraseArq(WorkFile))
   RETURN .F.
ENDIF

IF lEmail  // EOS - OS 578/02
   aDados[11] := SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
ENDIF

TDt_I:=mv_par01
TDt_F:=mv_par02

//TRP-23/08/07
If !Type("mv_par03") <> "N"  //ASK 11/03/2008
   If mv_par03 == 1
      lDiasUteis := .T.
   EndIf
EndIF


SA5->(DBSETORDER(3))
SW6->(DBSETORDER(4))
SY9->(DBSETORDER(2))

SW6->(DBSEEK(xFilial()+DTOS(TDt_I),.T.))
IF SW6->(EOF()) .OR. SW6->W6_DT_ENTR > TDt_F
   IF !lEmail  // EOS - OS 578/02 Quando schedulado, desvia apresentacoes na tela
      Help(" ",1,"EICSEMREG")
   ENDIF
   Work->(E_EraseArq(WorkFile))
   E_RESET_AREA
   Return .T.
ENDIF

cTitulo:="De "+DTOC(mv_par01)+" at‚ "+DTOC(mv_par02)

aRCampos:=E_CriaRCampos(TB_Campos)
aRCampos[07,3]:="C" ; aRCampos[09,3]:=aRCampos[10,3]:=aRCampos[11,3]:="D"

IF lEmail // EOS - OS 578/02 Quando schedulado, desvia apresentacoes na tela
   SW6->(TR320Apur(bMsg))
   IF Work->(Easyreccount("Work")) > 0      
      E_Report(aDados,aRCampos,.T.,.F.)   
   ENDIF
ELSE
   Processa({|| ProcRegua(SW6->(Easyreccount("SW6"))),SW6->(TR320Apur(bMsg))},;
                          STR0017) //"Pesquisando Entregas..."
                  
   IF Work->(Easyreccount("Work")) > 0
      Work->(DBGOTOP())

      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitulo;
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
             OF oMainWnd PIXEL  
         @ 00,00 MsPanel oPanel Prompt "" SIze 60,20 of oDlg       //LRL 28/04/04
         DEFINE SBUTTON FROM 03,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (If(lR4,(oReport := ReportDef(),oReport:PrintDialog()), E_Report(aDados,aRCampos))) ENABLE OF oPanel

//         oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
		aCordTela := AVG_TELA()//ASR 13/10/06 - Retorna o tamanho do objeto - correção de reflesh de tela por não mostrar todos os itens na MsSelect()
		oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{aCordTela[1,1],aCordTela[1,2],aCordTela[1,3],aCordTela[1,4]})
		
		oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT              
        oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})) //LRL 28/04/04 //Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      IF Work->(Easyreccount("Work")) == 0
         Help(" ",1,"EICSEMREG")
      ENDIF
   ELSE
      MSGINFO("Não há SI's fora de Lead Time") //JWJ 12/01/07
   ENDIF
ENDIF
Work->(E_EraseArq(WorkFile))
E_RESET_AREA
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR320Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 27/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR320Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICSIGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------
STATIC FUNCTION TR320Apur(bMsg)
*----------------------------------------------------------------------------
LOCAL bWhile := {|| SW7->W7_HAWB == SW6->W6_HAWB .AND. SW7->W7_FILIAL == xFilial("SW7")}

WHILE !SW6->(EOF()) .AND. SW6->W6_DT_ENTR <= TDt_F
   IF !lEmail  // EOS - OS 578/02 Quando schedulado, desvia apresentacoes na tela
      IncProc()
   ENDIF

   SW7->(DBSEEK(xFILIAL()+SW6->W6_HAWB))
   While !SW7->(Eof()) .And. SW7->W7_HAWB == SW6->W6_HAWB .AND. SW7->W7_FILIAL == xFilial("SW7")
      SW7->(TR320Grv(bMsg))
      SW7->(DBSKIP())
   Enddo
   SW6->(DBSKIP())
ENDDO
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION TR320Grv(bMsg)
*----------------------------------------------------------------------------
LOCAL MPraz_S:=MPraz_R:=MPraz_P:=0,MCompara
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),AVSX3("W0__CC",5),ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))

IF !PosO1_It_Solic(W7_CC,W7_SI_NUM,W7_COD_I,W7_REG,0)
   DBSELECTAREA("SW7")
   IF !lEmail  // EOS - OS 578/02 Quando schedulado, desvia apresentacoes na tela 
      Help("", 1, "AVG0003005",,TRAN(W7_COD_I,_PictItem) + STR0019+_LIT_R_CC+'/S.I. '+W7_CC+"/"+W7_SI_NUM+" ID/IS",1,6)
      //'ITEM '###' NÇO CADASTRADO P/ O '+ _LIT_R_CC+'/S.I. '+W7_CC+"/"+W7_SI_NUM+" ID/IS",STR0020)//"Informação"
   ENDIF
   RETURN .T.
ENDIF

DBSELECTAREA("SW7")

SW0->(DBSEEK(xFILIAL()+SW7->W7_CC+SW7->W7_SI_NUM))
SW2->(DBSEEK(xFILIAL()+SW7->W7_PO_NUM))
SYR->(DBSEEK(xFILIAL()+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))
SY9->(DBSEEK(xFILIAL()+SW6->W6_LOCAL))
SA5->(DBSEEK(xFILIAL()+SW7->W7_COD_I+SW7->W7_FABR+SW7->W7_FORN))

//TRP-23/08/07- Verifica se cálculo de prazos será realizado baseado em dias úteis ou corridos de acordo com pergunte.
If lDiasUteis
   MPraz_S:= Dias_Uteis(TR320DataAval(cCpoAval1),TR320DataAval(cCpoAval2))
   MPraz_R:= Dias_Uteis(TR320DataAval(cCpoAval1),TR320DataAval(cCpoAval3))
Else
   MPraz_S:= Dias_Corridos(TR320DataAval(cCpoAval1),TR320DataAval(cCpoAval2)) 
   MPraz_R:= Dias_Corridos(TR320DataAval(cCpoAval1),TR320DataAval(cCpoAval3))
EndIf

IF (EasyGParam("MV_LT_PROF")+EasyGParam("MV_LT_LICE")) > SA5->A5_LEAD_T
   MCompara := EasyGParam("MV_LT_PROF")+EasyGParam("MV_LT_LICE")
ELSE
   MCompara := SA5->A5_LEAD_T
ENDIF

nPrazo:= EasyGParam("MV_LT_COMP") + MCompara + SYR->YR_TRANS_T + ;
         SY9->Y9_LT_TRA + SY9->Y9_LT_DES

MPraz_P:= If (lDiasUteis,nPrazo, Prazo_Prev(nPrazo,TR320DataAval(cCpoAval1),TR320DataAval(cCpoAval1)))  //TRP-23/08/07

IF MPraz_S >= MPraz_P
   RETURN .T.
ENDIF

SB1->(DBSEEK(xFILIAL()+SW1->W1_COD_I))
Work->(DBAPPEND())
Work->WKCC       := SW1->W1_CC
Work->WKNUM_SI   := SW1->W1_SI_NUM
Work->WKDT_SI    := SW0->W0__DT
Work->WKCOD_I    := SW1->W1_COD_I
Work->WKDESC     := MSMM(SB1->B1_DESC_P,36,1)
Work->WKDT_ENT_P := SW1->W1_DTENTR_
Work->WKDT_ENT_E := SW6->W6_DT_ENTR
Work->WKPRAZ_R   := E_VerPrazo(MPraz_R)
Work->WKPRAZ_P   := E_VerPrazo(MPraz_P)
Work->WKPRAZ_S   := E_VerPrazo(MPraz_S)
Work->WKFORN     := SW7->W7_FORN+" "+(SA2->(DBSEEK(xFilial()+SW7->W7_FORN)),;
                                      SA2->A2_NREDUZ)
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION TR320DataAval(cCpoAval)
*----------------------------------------------------------------------------
Local cAlias
cAlias := If(Substr(cCpoAval,3,1)=="_", "S"+Substr(cCpoAval,1,2), Substr(cCpoAval,1,3))+"->"
cCpoAval:= cAlias+cCpoAval
Return(&cCpoAval)

//TRP - 09/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),AVSX3("W0__CC",5),ALLTRIM(EasyGParam("MV_LITRCC")))

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW0","SW1","SW6","SW7"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICTR320",STR0014,"EIC010",{|oReport| ReportPrint(oReport)},STR0012+ " " +STR0013)

//ER - 20/10/2006 - Inicia o relatório como paisagem. 
oReport:oPage:lLandScape := .T. 
oReport:oPage:lPortRait := .F. 

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"S.I.s",aTabelas,aOrdem)


//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WKCC"        ,"Work"  ,_LIT_R_CC            ,/*Picture*/                       ,AVSX3("W1_CC",3)                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKNUM_SI"    ,"Work"  ,OemToAnsi(STR0001)   ,ALLTRIM(X3PICTURE("W0__NUM"))     ,AVSX3("W1_SI_NUM",3)                      ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDT_SI"     ,"Work"  ,STR0002              ,/*Picture*/                       ,8                                         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKCOD_I"     ,"Work"  ,STR0003              ,ALLTRIM(X3PICTURE("B1_COD"))      ,AVSX3("W1_COD_I",3)                       ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDESC"      ,"Work"  ,OemToAnsi(STR0004)   ,/*Picture*/                       ,36                                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKFORN"      ,"Work"  ,STR0005              ,/*Picture*/                       , AVSX3("A2_COD",3)+AVSX3("A2_NREDUZ",3)   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDT_ENT_P"  ,"Work"  ,OemToAnsi(STR0006)   ,/*Picture*/                       ,8                                         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDT_ENT_E"  ,"Work"  ,STR0007              ,/*Picture*/                       ,8                                         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKPRAZ_S"    ,"Work"  ,STR0008              ,/*Picture*/                       ,5                                         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKPRAZ_P"    ,"Work"  ,STR0009              ,/*Picture*/                       ,5                                         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKPRAZ_R"    ,"Work"  ,STR0010              ,/*Picture*/                       ,5                                         ,/*lPixel*/,/*{|| code-block de impressao }*/)

oReport:Section("S.I.s"):Cell("WKCC"      ):SetColSpace(2)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKNUM_SI"  ):SetColSpace(2)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKDT_SI"   ):SetColSpace(2)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKCOD_I"   ):SetColSpace(2)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKDESC"    ):SetColSpace(2)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKFORN"    ):SetColSpace(2)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKDT_ENT_P"):SetColSpace(3)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKDT_ENT_E"):SetColSpace(3)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKPRAZ_S"  ):SetColSpace(3)//ASR - 10/11/2006
oReport:Section("S.I.s"):Cell("WKPRAZ_P"  ):SetColSpace(3)//ASR - 10/11/2006

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

***********************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

TRPosition():New(oReport:Section("S.I.s"),"SW0",1,{|| xFilial("SW0") + SW7->W7_CC+SW7->W7_SI_NUM})

TRPosition():New(oReport:Section("S.I.s"),"SW6",4,{|| xFilial("SW6") + DTOS(W6_DT_ENTR)})

TRPosition():New(oReport:Section("S.I.s"),"SW7",1,{|| xFilial("SW7") + SW6->W6_HAWB})

//oSection:Print()
oReport:SetMeter (Work->(EasyRecCount("Work")))
Work->( dbGoTop() )


//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("S.I.s"):Init()


//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("S.I.s"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("S.I.s"):Finish()
Work->( dbGoTop() )//ASR 13/06/2006 - CORRIGE O PROBLEMA DE POSICIONAMENTO DA WORK DA MSSELECT()  
Return .T.

