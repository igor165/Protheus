//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICPS150.CH"

#COMMAND E_RESET_AREA => SW6->(DBSETORDER(1)) ; SY9->(DBSETORDER(1)) ;
                       ; Work->(E_EraseArq(WorkFile)) ;
                       ; DBSELECTAREA(nOldArea)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICCPS150³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 22.10.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Planilha de Seguro                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICPS150()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICPS150

LOCAL aDados :={STR0001,; //"Work"
                STR0002,; //"Este relatório irá exibir dados relativos a "
                STR0003,; //"Planilha de Seguro"
                "",;
                "G",;
                220,;
                "",;
                "",;
                STR0004,; //"Planilha de Seguro"
                { "Zebrado", 1,"Importação", 1, 2, 1, "",1 },;
                STR0005,; //"EICPS150"
                { {|| .T. } , {|| .T. }  }  }

LOCAL WorkFile, nOldArea:=SELECT()
Local aCamposTRB:={}
LOCAL cSaveMenuh, nCnt, cTitulo, oDlg, oGet, nOpcA:=0, TipoGuia
PRIVATE T_DBF:= {} // OS 0632/01
PRIVATE TB_Campos:={}// OS 0632/01
PRIVATE lRetVal := .T. // OS 0632/01
PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE cCadastro := OemtoAnsi(STR0006), TCod_I, dDt_I, dDt_F //"Planilha de Seguro"
PRIVATE cVia := "  ",dDT_I := dDT_F := AVCTOD(''), cApolice := SPACE(10)
PRIVATE cObs1:= cObs2:= cObs3:= cObs4:= cObs5:= cObs6:= SPACE(70)  
PRIVATE MTot_Fob:= MTot_Frt := 0.00

//PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
//        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

Private aHeader[0],nUsado:=0,lRetPar09:= .F.
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

PRIVATE R_Dados:={cCadastro,132,.T.,NIL}, R_Campos:={},;
        R_Funcoes:={ {|| PS150Qb("D")},{|| PS150Qb("F")} }

PRIVATE cPictTaxa:=ALLTRIM(X3Picture("W6_TX_US_D")),;
        cPictPeso:=ALLTRIM(X3Picture("B1_PESO"))
aDados[12]:=R_Funcoes                          

bCampo  := {|nCPO| Field(nCPO) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F10 para acessar os parametros                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
SetKey( VK_F12,{ || Pergunte("EICPSE",.T.) } )
*/     
IF EasyEntryPoint("EICPS150")
   If !ExecBlock("EICPS150",.F.,.F.,"PARAM01")
      Return 
   Endif
ENDIF   

If !lRetPar09
   nOpca := 0
   DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0044) From 15,03 To 35,96 OF oMainWnd 

   @0.2,0.3 TO 10.5,40

   @01  ,001 SAY OemToAnsi(STR0040) //"Via de Transporte "     
   @02.0,001 SAY OemToAnsi(STR0041)//"Data Inicial Desembaraco"
   @03.0,001 SAY OemToAnsi(STR0042)//"Data Final Desembaraco"  
   @04.0,001 SAY OemToAnsi(STR0025)//"Apolice "                
   @05.0,001 SAY OemToAnsi(STR0043)//"Observacoes "            

   @01.0,010 MSGET cVia     PICTURE '@!' SIZE 030,03  F3 'SYQ' Valid(ExistCpo("SYQ",cVia)) 
   @02.0,010 MSGET dDT_I    PICTURE '@D' SIZE 040,03 Valid(!Empty(dDt_I))
   @03.0,010 MSGET dDT_F    PICTURE '@D' SIZE 040,03  Valid (PS150VAL())
   @04.0,010 MSGET cApolice PICTURE '@!' SIZE 050,03
   @05.0,010 MSGET cObs1    PICTURE '@!' SIZE 220,03
   @06.0,010 MSGET cObs2    PICTURE '@!' SIZE 220,03
   @07.0,010 MSGET cObs3    PICTURE '@!' SIZE 220,03
   @08.0,010 MSGET cObs4    PICTURE '@!' SIZE 220,03
   @09.0,010 MSGET cObs5    PICTURE '@!' SIZE 220,03
   @10.0,010 MSGET cObs6    PICTURE '@!' SIZE 220,03

   DEFINE SBUTTON FROM 005,330 TYPE 1 ACTION(nopca:=1,oDlg:End()) ENABLE OF oDlg PIXEL
   DEFINE SBUTTON FROM 020,330 TYPE 2 ACTION(nopca:=0,oDlg:End()) ENABLE OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg CENTERED //ON INIT Enc hoiceBar(oDlg,;
   If nOpca == 0
      Return
   Endif   
ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01    Data inicial                                     ³
//³ mv_par02    Data final                                       ³
//³ mv_par03    Ap¢lice                                          ³
//³ mv_par04    Observacoes                                      ³
//³ mv_par05                                                     ³
//³ mv_par06                                                     ³
//³ mv_par07                                                     ³
//³ mv_par08                                                     ³
//³ mv_par09                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     T_DBF:= { { "WKVIA"      , "C" , 02 , 0 } ,;
               { "WKVIADESC"  , "C" , 10 , 0 } ,;
               { "WKPO_NUM"   , "C" , AVSX3("W7_PO_NUM",AV_TAMANHO) , 0 } ,;
               { "WKTRANSP"   , "C" , 25 , 0 } ,;
               { "WK_HAWB"    , "C" , AVSX3("W7_HAWB",AV_TAMANHO) , 0 },;   // OS 0632/01
               { "WK_MAWB"    , "C" , 18 , 0 },;   // OS 0632/01               
               { "WKDT_HAWB"  , "D" , 08 , 0 } ,;   //OS0632
               { "WKDT_EMB"   , "D" , 08 , 0 } ,;
               { "WKDT_CHEG"  , "D" , 08 , 0 } ,;
               { "WKPAIS"     , "C" , 12 , 0 } ,;
               { "WKLOCAL"    , "C" , 03 , 0 } ,;
               { "WKVL_FOB"   , "N" , 15 , 2 } ,;
               { "WKVL_FRT"   , "N" , 15 , 2 } ,;
               { "WKTAXA"     , "N" , 15 , 8 } ,;
               { "WKCOD_I"    , "C" , AVSX3("W7_COD_I",3) , 0 } ,;
               { "WKDESCR"    , "C" , 23 , 0 } ,;
               { "WKPESOL"    , "N" , 18 , 8 } ,;
               { "WKGI_NUM"   , "C" , AVSX3("W7_PGI_NUM",AV_TAMANHO) , 0 } ,;
               { "WKDI_NUM"   , AVSX3("W6_DI_NUM",2),AVSX3("W6_DI_NUM",3) , 0 } ,;
               { "WKDT_DES"   , "D" , 08 , 0 } }
     IF EasyEntryPoint("EICPS150")
        ExecBlock("EICPS150",.F.,.F.,"ESTRUTURA")
     ENDIF
               
     AADD(T_DBF,{ "WKNAO"      , "C" , 03 , 0 } )

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKVIADESC+DTOS(WKDT_DES)")

//AADD(TB_Campos,{"WKVIADESC" ,"",STR0007}) //"Via"
AADD(TB_Campos,{"WKPO_NUM"  ,"", OemToAnsi(STR0008),_PictPo }) //"N§ P.O."
//AADD(TB_Campos,{"WKTRANSP"  ,"", STR0009                 }) //"Transporte"
AADD(TB_Campos,{"WK_HAWB"  ,"", OemToAnsi(STR0035)           }) //"Processo"   // OS 0632/01
AADD(TB_Campos,{"WKDT_HAWB"  ,"", OemToAnsi(STR0038)           }) //"Data"   // OS 0632/01
AADD(TB_Campos,{"WK_MAWB"  ,"", OemToAnsi(STR0039)       }) //"MAWB"   // OS 0632/01
//AADD(TB_Campos,{"WKDT_EMB"  ,"", OemToAnsi(STR0010)           }) //"Sa¡da"
AADD(TB_Campos,{"WKDT_CHEG" ,"", STR0011                    }) //"Chegada"
AADD(TB_Campos,{"WKPAIS"    ,"", OemToAnsi(STR0010)     }) //"SAIDA"
AADD(TB_Campos,{{||SY9->(DBSEEK(xFilial()+Work->WKLOCAL)),LEFT(SY9->Y9_DESCR,15)},"",STR0013})//"Destino"
AADD(TB_Campos,{"WKVL_FOB"  ,"", STR0014,"@E 9999,999,999.99"}) //"Valor FOB US$"
AADD(TB_Campos,{"WKVL_FRT"  ,"", STR0015,"@E 999,999,999.99"}) //"Valor Frete US$"
AADD(TB_Campos,{"WKTAXA"    ,"", STR0016,cPictTaxa           }) //"Fiscal"
AADD(TB_Campos,{"WKDESCR"   ,"", OemToAnsi(STR0017)            }) //"Item"
AADD(TB_Campos,{"WKPESOL"   ,"", STR0018,cPictPeso             }) //"Peso"
//AADD(TB_Campos,{"WKGI_NUM"  ,"", STR0019                       }) //"Guia"
AADD(TB_Campos,{"WKDI_NUM"  ,"", STR0020,E_Tran("W6_DI_NUM",,.T.)}) //"D.I."
//AADD(TB_Campos,{"WKDT_DES"  ,"", STR0021                    }) //"Desemb."
IF EasyEntryPoint("EICPS150")   // OS 0632/01
   ExecBlock("EICPS150",.F.,.F.,"BROWSE")
ENDIF

AADD(TB_Campos,{"WKNAO"     ,"", STR0022                         }) //"VD"

WHILE .T.         
/*
  IF ! Pergunte("EICPSE",.T.)
     EXIT
  ENDIF

  TDt_I   :=mv_par01
  TDt_F   :=mv_par02
  TApolice:=mv_par03
  TObs1   :=mv_par04
  TObs2   :=mv_par05
  TObs3   :=mv_par06
  TObs4   :=mv_par07
  TObs5   :=mv_par08
  TObs6   :=mv_par09
*/
  cTitulo:=STR0023+DTOC(dDt_I)+STR0024+DTOC(dDt_F) + STR0025 + ALLTRIM(cApolice) //"De "###" ate "###" Apolice.: "
  R_Dados[4]:=cTitulo          
  SYQ->(DBSEEK(xFilial("SYQ")+cVia))
  aDados[7]:= OemToAnsi(STR0007)+" "+ cVia +" - "+ SYQ->YQ_DESCR+ "  Periodo : "+DTOC(dDt_I)+ " a " +DTOC(dDT_F)  

     SW6->(DBSETORDER(2))
     SY9->(DBSETORDER(2))
     SW6->(DBSEEK(xFilial()+DTOS(dDt_I),.T.))
     Work->(avzap())
     Processa({|lEnd| PS150Grava(dDt_F)},;
               OemtoAnsi(STR0026))//"Pesquisando informa‡äes..."
     Work->(DBGOTOP())
     IF Work->(Easyreccount("Work")) > 0

        oMainWnd:ReadClientCoors()
        DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+OemToAnsi(cTitulo) ;
               FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
            	      OF oMainWnd PIXEL                          

        IF EasyEntryPoint("EICPS150")   // OS 0632/01
           ExecBlock("EICPS150",.F.,.F.,"TELA")   
        ENDIF                                 

        DEFINE SBUTTON FROM 18,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (E_Report(aDados,aCamposTRB)) ENABLE OF oDlg
        aCamposTRB:=E_CriaRCampos(TB_Campos)
        aCamposTRB[7,1]:="IF(SY9->(DBSEEK(xFilial()+Work->WKLOCAL)),LEFT(SY9->Y9_DESCR,15),SPACE(15))"
        oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
        ACTIVATE MSDIALOG oDlg ON INIT (Work->(DBGOTOP()),EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()}))
     ENDIF

//   Set Key VK_F12 To

  IF Work->(Easyreccount("Work")) = 0
     Help(" ",1,"EICSEMREG")
     exit
  ENDIF

  IF nOpca == 0
     EXIT
  ENDIF

END
E_RESET_AREA
Return
*----------------------------------------------------------------------------
FUNCTION PS150Val()
*----------------------------------------------------------------------------
If Empty(dDt_I)
   Help("", 1, "AVG0000471")//"Data Inicial deve ser informada"###"Atenção"
   RETURN .F.
ENDIF
If Empty(dDt_F)
   Help("", 1, "AVG0000472")//"Data Final deve ser informada"###"Atenção"
   RETURN .F.
ENDIF
IF dDt_I > dDt_F
   Help("", 1, "AVG0000473")//"Data Inicial maior que Data Final"###"Atenção"
   RETURN .F.
ENDIF
IF EasyEntryPoint("EICPS150")   // OS 0632/01

   ExecBlock("EICPS150",.F.,.F.,"VALID")   
   If !lRetVal
      Return .F.
   Endif
ENDIF                                 
SW6->(DBSETORDER(2))
SW6->(DBSEEK(xFilial()+DTOS(dDt_I),.T.))
If SW6->(EOF()) .OR. SW6->W6_DT_DESE > dDt_F
   Help("", 1, "AVG0000474")//"Não existem registros para este período"###"Informação"
   RETURN .F.
Endif

RETURN .T.
*----------------------------------------------------------------------------
FUNCTION PS150Grava(dDt_F)
*----------------------------------------------------------------------------
lRetVal := .T. //OS 0632/01
IF EasyEntryPoint("EICPS150")   // OS 0632/01
   ExecBlock("EICPS150",.F.,.F.,"GRAVA")

   If !lRetVal
      TRB->(DBCLOSEAREA())
      Return .t.
   Else
      Return .f.        
   Endif              
ENDIF

ProcRegua(SW6->(Easyreccount("SW6")))
SW6->(DBEVAL({||PS150Grv()},,{|| SW6->W6_DT_DESE <= dDt_F.AND.SW6->W6_VIA_TRA==cVia }))
Return .T.

*----------------------------------------------------------------------------
FUNCTION PS150Grv()
*----------------------------------------------------------------------------
LOCAL MPeso_L:=0


LOCAL cFilSW7 := xFilial("SW7"), nTot0 , nTot1
LOCAL cMoedaDolar:=BuscaDolar()//EasyGParam("MV_SIMB2",,"US$")

IncProc(STR0035+ SW6->W6_HAWB) //"Conhecimento "
SW7->(DBSEEK(cFilSW7+SW6->W6_HAWB))

WHILE ! SW7->(EOF()) .AND. SW6->W6_HAWB == SW7->W7_HAWB .AND. cFilSW7==SW7->W7_FILIAL

/* IncProc(STR0036+SW6->W6_HAWB+; //"Conhecimento "
             STR0037+TRAN(SW7->W7_COD_I,_PictItem)) //" Item "
*/
   IF SW7->W7_SEQ # 0
      SW7->(DBSKIP())  ; LOOP
   ENDIF

   SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM) )
   SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN))
   SW4->(DBSEEK(xFilial("SW4")+SW7->W7_PGI_NUM ))

   SB1->(DBSEEK(xFilial("SB1")+SW7->W7_COD_I))
   nPeso_UN :=W5PESO()// SB1->B1_PESO FCD 04/07/01
  IF(EasyEntryPoint("EICPS150"),ExecBlock("EICPS150",.F.,.F.,"PESO" ),)

   MPeso_L+= nPeso_UN * SW7->W7_QTDE

   SW7->(DBSKIP())
ENDDO        
aTotal:=aDespFob:= {}
nTotalSeg := 0
nDespFob  := 0
aTotal    := ConvInvMoeda(SW6->W6_HAWB, cMoedaDolar, SW6->W6_DT )
aDespFob  := ConvDespFobMoeda( SW6->W6_HAWB, cMoedaDolar,SW6->W6_DT ,"TUDO")
If VALTYPE(aTotal)== "A"
   if Len(aTotal)>0
      For nTot0 := 1 to Len(aTotal)
         nTotalSeg += aTotal[nTot0][2]
      Next
   EndiF  
Else 
   nTotalSeg +=aTotal
Endif
if Len(aDespFob)>0
   For nTot1 := 1 to Len(aDespFob)
      nDespFob += aDespFob[nTot1][2]
   Next
EndiF

SW7->(DBSKIP(-1))               
SYA->(DBSeek(xFilial("SYA")+SA2->A2_PAIS))
Work->(DBAPPEND())
Work->WKVIA     := SW6->W6_VIA_TRA
Work->WKVIADESC := IF(SYQ->(DBSEEK(xFilial("SYQ")+SW6->W6_VIA_TRA)),SYQ->YQ_DESCR,' ')
Work->WKPO_NUM  := SW7->W7_PO_NUM
Work->WKTRANSP  := SW6->W6_IDENTVEI
Work->WK_HAWB   := SW6->W6_HAWB //OS 632/01
Work->WK_MAWB   := SW6->W6_MAWB //OS 632/01
Work->WKDT_EMB  := SW6->W6_DT_EMB
Work->WKDT_CHEG := SW6->W6_CHEG
Work->WKPAIS    := SYA->YA_DESCR
Work->WKLOCAL   := SW6->W6_LOCAL
//Work->WKVL_FOB  := ConvInvMoeda(SW6->W6_HAWB, "US$", SW6->W6_DT )+ConvDespFobMoeda( SW6->W6_HAWB, "US$",SW6->W6_DT ,"TUDO")
Work->WKVL_FOB  := nTotalSeg +nDespFob
Work->WKVL_FRT  := ValorFrete(SW6->W6_HAWB,cMoedaDolar,SW6->W6_DT,3)
Work->WKTAXA    := SW6->W6_TX_US_D
Work->WKCOD_I   := SW7->W7_COD_I
//Work->WKGI_NUM  := IF(SW4->W4_PORTASN=="S","PORTARIA 15     ",TRAN(SW4->W4_GI_NUM,_PictGI))
Work->WKDI_NUM  := SW6->W6_DI_NUM
Work->WKDT_DES  := SW6->W6_DT_DESE
Work->WKNAO     := "NAO"
Work->WKPESOL   := MPeso_L
Work->WKDT_HAWB := SW6->W6_DT_HAWB //OS 0632/01
IF SB1->(DBSEEK(xFilial("SB1")+SW7->W7_COD_I))
   Work->WKDESCR := MSMM( SB1->B1_DESC_P,23,1 )
ENDIF                                          
IF EasyEntryPoint("EICPS150")   // OS 0632/01
   ExecBlock("EICPS150",.F.,.F.,"GRAVA_WORK")
ENDIF

RETURN .T.
*-----------------------------------*
FUNCTION PS150Qb(PLocal)
*-----------------------------------*
LOCAL  MCod:=Work->WKVIA
STATIC SavVia, _Primeiro

_Primeiro:=IF(_Primeiro=NIL,.T.,.F.)
IF MCod # SavVia
   SavVia:= MCod
   IF ! _Primeiro .AND. PLocal # "F"
      @ Linha,T_Len[08,2]     PSAY REPL("-",T_Len[08,1])
      @ Linha,T_Len[09,2]     PSAY REPL("-",T_Len[09,1])
      Linha++
      @ Linha,T_Len[07,2]+5   PSAY "TOTAL"
      @ Linha,T_Len[08,2] PSAY TRAN(MTot_FOB,'@E 999,999,999.99')
      @ Linha,T_Len[09,2] PSAY TRAN(MTot_FRT,'@E 999,999,999.99')
      Linha+=2
      MTot_Fob:= MTot_Frt := 0.00
      MTot_Fob+= Work->WKVL_FOB 
      MTot_Frt+= Work->WKVL_FRT
   ELSE
      MTot_Fob+= Work->WKVL_FOB 
      MTot_Frt+= Work->WKVL_FRT
   ENDIF
ELSE
   MTot_Fob+= Work->WKVL_FOB 
   MTot_Frt+= Work->WKVL_FRT
ENDIF
IF PLocal = "F"
   Linha++
   @ Linha,T_Len[08,2]     PSAY REPL("-",T_Len[08,1])
   @ Linha,T_Len[09,2]     PSAY REPL("-",T_Len[09,1])
   Linha++
   @ Linha,T_Len[07,2]+5   PSAY "TOTAL"
   @ Linha,T_Len[08,2] PSAY TRAN(MTot_FOB,'@E 999,999,999.99')
   @ Linha,T_Len[09,2] PSAY TRAN(MTot_FRT,'@E 999,999,999.99')
   Linha+=2
   @ Linha,T_Len[01,2] PSAY cObs1
   Linha++
   @ Linha,T_Len[01,2] PSAY cObs2
   Linha++
   @ Linha,T_Len[01,2] PSAY cObs3
   Linha++
   @ Linha,T_Len[01,2] PSAY cObs4
   Linha++
   @ Linha,T_Len[01,2] PSAY cObs5
   Linha++
   @ Linha,T_Len[01,2] PSAY cObs6
   SavVia := NIL ; _Primeiro := NIL
ENDIF
RETURN .T.
