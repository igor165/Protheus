#INCLUDE "Eictr280.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"
#COMMAND E_RESET_AREA => SW6->(DBSETORDER(1)) ; SY9->(DBSETORDER(1))   ;
                       ; SW2->(DBSETORDER(1)) ;
                       ; TRB->(E_EraseArq(FileWork)) ; DBSELECTAREA(nOldArea)

#DEFINE   Transportes  "1"
#DEFINE   Processo     "2"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR280 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 30.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Avalia‡Æo de Transportes                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR280()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                
// EOS - OS 576/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR280
// um parametro como .T. identificando que é schedulado 
******************
Function EICTR280S
******************
EICTR280(.T.)
RETURN NIL


***********************
Function EICTR280(lSXD)
***********************
EICTR280R3(lSXD,.T.)
Return .T.
                   

******************************
Function EICTR280R3(lSXD,p_R4)
******************************
Local   lEICPTR02 := EasyEntryPoint("EICPTR02")
PRIVATE P_Qual    := Transportes
PRIVATE cCadastro := STR0001 //"Avaliação de Transportes"
Private cCpoAval1 := "W6_DT_DESE"
Private cCpoAval2 := "W6_DT_ENTR"
Private aCampos   := {}
Private lEmail    := !lSXD = NIL  // EOS - OS 576/02
Private lR4       := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()
Private cNome  
Private l280DiasUt := .F. //FDR - 04/06/12

If lEICPTR02
   ExecBlock("EICPTR02", .F., .F., "TRANSPORTES")
Endif

aCampos := {"W6_LOCAL"  , "Y9_DESCR" , "W7_PO_NUM" , "W7_FORN" ,;
            "A2_NREDUZ" , "W6_HAWB"  , "W6_DI_NUM" , "W6_LOTE" ,;
             cCpoAval1  , cCpoAval2 }
EICAddLoja(aCampos, "W7_FORLOJ", Nil, "W7_FORN") 
If EasyEntryPoint("EICTR280")
   ExecBlock("EICTR280",.F.,.F.,"ACAMPOS") //chiba
EndIf


Return TR280Main("EIC010")
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR285 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 30.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Dura‡Æo dos Processos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR285()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// EOS - OS 576/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR280
// um parametro como .T. identificando que é schedulado 
******************
Function EICTR285S
******************
EICTR285(.T.)
RETURN NIL


***********************
Function EICTR285(lSXD)
***********************
EICTR285R3(lSXD,.T.)
Return .T.


******************************
Function EICTR285R3(lSXD,p_R4)
******************************
Local   lEICPTR02 := EasyEntryPoint("EICPTR02")
PRIVATE P_Qual    := Processo
PRIVATE cCadastro := STR0002 //"Duração dos Processos"
Private cCpoAval1 := "W0__DT"
Private cCpoAval2 := "W6_DT_ENTR"
Private aCampos   := {}                             
Private lEmail    := !lSXD = NIL  // EOS - OS 576/02
Private lR4       := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()
Private cNome
Private nPrazo
Private l285DiasUt := .F.
//If lR4
   //oReport := ReportDef()
//EndIf

If lEICPTR02
   ExecBlock("EICPTR02", .F., .F., "PROCESSO")
Endif

aCampos := {"W7_PO_NUM" , "W7_FORN"  , "A2_NREDUZ" , "W6_HAWB"   ,;
            "W6_DI_NUM" , "W6_LOTE"  , cCpoAval1   , cCpoAval2 }

EICAddLoja(aCampos, "W7_FORLOJ", Nil, "W7_FORN") 
If EasyEntryPoint("EICTR280")
   ExecBlock("EICTR280",.F.,.F.,"ACAMPOS5") //chiba
EndIf

Return TR280Main("EIC285")

*---------------------------------------------------------------------------
Function TR280Main(cPergunte)
*---------------------------------------------------------------------------
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
LOCAL FileWork, nOldArea:=SELECT(), TForn:=SW7->W7_FORN,TFornLoj:=EICRetLoja("SW7","W7_FORLOJ"), lValidForn:=.F.
LOCAL cSaveMenuh, nCnt, cTitulo, oDlg, oPanel ,oMark,bMsg,cForn//,nOpca chiba
LOCAL  nPos, lInverte:=.F., cMarca:=GetMark()
LOCAl TDt_I, TDt_F  

Private nPrazoMed := 0
PRIVATE aDados  :={"TRB",;    //chiba
                  STR0003,; //"Este relatorio ir  exibir uma estat¡stica sobre"
                   "",;
                  "",;
                  "G",;
                  132,;
                  "",;
                  "",;
                  STR0004,; //"Avaliacao de "
                  { "Zebrado", 1,"Importa‡Æo", 1, 2, 1, "",1 },;
                  "EICTR280",;
                  { {|| .T. } , {|| TR_RelMed(110,nPrazoMed) }  }  }

PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
Private aHeader[0], nUsado:=0, aReturn := aDados[10]

// aRotina declarada apenas para compatibilizar com GetDadDB

PRIVATE aRotina := { { STR0005, "AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                     { STR0006, "C210Impor" , 0 , 2} ,; //"Atual"
                     { STR0007, "C210Impor" , 0 , 3} }  //"Todos"


PRIVATE aRCampos:={} //chiba
                     
PRIVATE nOpca:=0 //chiba

bCampo  := {|nCPO| Field(nCPO) }

SW2->(DBSETORDER(2))
SW6->(DBSETORDER(4))
SY9->(DBSETORDER(2))

aCamposTRB:= CriaEstru(aCampos,@aHeader)
AADD(aCamposTRB,{"XX_FLAGWIN","C",2,0})
AADD(aCamposTRB,{"WKPRAZO_R","N",5,0})
AADD(aCamposTRB,{"WKPRAZO_P","N",5,0})
AADD(aCamposTRB,{"WKPRAZO_D","N",5,0})

AADD(aHeader,{STR0008,"WKPRAZO_R","@E 99,999",5,0," ","   ","N",," "}) //"Prazo Realizado"
AADD(aHeader,{STR0009,"WKPRAZO_P","@E 99,999",5,0," ","   ","N",," "}) //"Prazo Previsto"
AADD(aHeader,{STR0010,"WKPRAZO_D","@E 99,999",5,0," ","   ","N",," "}) //"Atraso/Antecipado"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho e indice                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

FileWork := E_CriaTrab(,aCamposTRB,"TRB") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   IF !lEmail // EOS - OS 576/02 - Quando schedulado, desvia apresentacoes na tela
      Help(" ",1,"E_NAOHAREA")
   ENDIF
   E_RESET_AREA
   RETURN .F.
ENDIF

IF P_Qual=Transportes
   IndRegua("TRB",FileWork+TEOrdBagExt(),"W6_LOCAL+W7_PO_NUM")
   aDados[03]+=STR0011 //"os prazos de transporte."
   aDados[09]+=STR0012 //"Tranportes."
   aDados[11]:="EICTR280"
   IF lEmail // EOS - OS 576/02
      cPergunte := "EIC280"
   ENDIF
ELSE
   IndRegua("TRB",FileWork+TEOrdBagExt(),"W7_PO_NUM")
   aDados[03]+=STR0013 //"a prazo de conclusao dos processos."
   aDados[09]:=STR0002 //"Dura‡ao dos Processos"
   aDados[11]:="EICTR285"
ENDIF

aSize(aCampos,0)                                    // p/ criacao correta de
AEval(aCamposTRB,{|campo| AAdd(aCampos,campo[1]) }) // aRCampos
E_CriaCampos(aRCampos,.T.,1)

WHILE .T.
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Variaveis utilizadas para parametros                         ³
  //³ mv_par01  // Data inicial                                    ³
  //³ mv_par02  // Data final                                      ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  // EOS - OS 576/02 Se for schedulado, chama o pergunte como .F. somente para
  // inicializar as variaveis mv_par?? e atraves do setprint carrega as variaveis
  IF !Pergunte(cPergunte,IF(lEmail,.F.,.T.)) 
     E_RESET_AREA
     RETURN .F.
  ENDIF
  IF lEmail  // EOS - OS 576/02
     aDados[11] := SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
  ENDIF
  IF P_Qual=Transportes
     TDt_I:=mv_par01
     TDt_F:=mv_par02
     //FDR - 04/06/12
     If !Type("mv_par03") <> "N"  //ASK 29/02/2008
        If mv_par03 == 1
           l280DiasUt := .T.
        EndIF
     EndIf
     cTitulo:=STR0014+DTOC(mv_par01)+STR0015+DTOC(mv_par02) //" De "###" … "
     // aRCampos[11,3]:="D" ; aRCampos[12,3]:="D" ; aRCampos[13,3]:="D" - AST - 19/11/08
                                                                                        
     // AST - 19/11/08
     nPos := aScan(aRCampos,{ |campo|  "WKPRAZO_R" $ campo[1] }) 
     If ( nPos > 0, aRCampos[nPos,3] := "D" , )                  
     nPos := aScan(aRCampos,{ |campo|  "WKPRAZO_P" $ campo[1] }) 
     If ( nPos > 0, aRCampos[nPos,3] := "D" , )                  
     nPos := aScan(aRCampos,{ |campo|  "WKPRAZO_D" $ campo[1] }) 
     If ( nPos > 0, aRCampos[nPos,3] := "D" , )                  
     
  ELSE
     SW2->(DBSETORDER(1))
     TForn   :=mv_par01
     TFornLoj:=mv_par02
     TDt_I   :=mv_par03
     TDt_F   :=mv_par04 
     If !Type("mv_par05") <> "N"  //ASK 29/02/2008
        If mv_par05 == 1
           l285DiasUt := .T.
        EndIF
     EndIf
     cForn:=IF(!EMPTY(TForn) .And. IIF(EICLoja(),!EMPTY(TFornLoj),.T.),TForn+" "+BuscaFabr_Forn(TForn+TFornLoj),STR0016) //"Todos os Fornecedores"
     cTitulo:=cForn+" - De "+DTOC(mv_par03)+" … "+DTOC(mv_par04)
     
     //aRCampos[3,3]:="E" 
     //aRCampos[9,3]:="D" 
     //aRCampos[10,3]:="D"
     //aRCampos[11,3]:="D"    
     
     //deixar de uma forma dinamica igor chiba 
      
     nPos := aScan(aRCampos,{ |campo|  "A2_NREDUZ" $ campo[1] }) 
     If ( nPos > 0, aRCampos[nPos,3] := "E" , )                  
     nPos := aScan(aRCampos,{ |campo|  "WKPRAZO_R" $ campo[1] }) 
     If ( nPos > 0, aRCampos[nPos,3] := "D" , )                  
     nPos := aScan(aRCampos,{ |campo|  "WKPRAZO_P" $ campo[1] }) 
     If ( nPos > 0, aRCampos[nPos,3] := "D" , )                  
     nPos := aScan(aRCampos,{ |campo|  "WKPRAZO_D" $ campo[1] }) 
     If ( nPos > 0, aRCampos[nPos,3] := "D" , )                  
     
  ENDIF
  
  If cCpoAval2 == "W6_DT_ENTR"
      SW6->(DBSETORDER(4))
     SW6->(DBSEEK(xFilial("SW6")+DTOS(TDt_I),.T.))
  Else
     SW6->(dbSetOrder(1))
     SW6->(dbSeek(xFilial("SW6")))
  EndIf
  
  IF SW6->(EOF())
     IF !lEmail // EOS - OS 576/02 - Quando schedulado, desvia apresentacoes na tela
        Help(" ",1,"EICSEMREG")
     ENDIF
     LOOP
  ENDIF

  TRB->(avzap())
  
  IF lEmail // EOS - OS 576/02 - Quando schedulado, desvia apresentacoes na tela
     IF P_Qual=Transportes
        TR280Grava(@nPrazoMed,, TDt_I, TDt_F)
     ELSE
        TR285Grava(@nPrazoMed,,TForn,TDt_I,TDt_F,TFornLoj)
     ENDIF       
     IF TRB->(Easyreccount("TRB")) > 0   
        E_Report(aDados,aRCampos,.T.,.F.)
     ENDIF
     E_RESET_AREA
     EXIT
     
  ELSE
     bMsg:={|msg|MsProcTxt(msg)}
     IF P_Qual=Transportes
        bProcessa:={|lEnd| TR280Sint(bMsg,TDt_I,TDt_F) }
        Processa({|lEnd| ProcRegua(SW6->(Easyreccount("SW6"))),;
                         TR280Grava(@nPrazoMed,, TDt_I, TDt_F), .T. },;
                         STR0017) //"Pesquisando informa‡äes..."
     ELSE
        bProcessa:={|lEnd| TR285Sint(bMsg,TDt_I,TDt_F) }
        Processa({|lEnd| ProcRegua(SW6->(Easyreccount("SW6"))),;
                         TR285Grava(@nPrazoMed,,TForn,TDt_I,TDt_F,TFornLoj), .T. },;
                         STR0017) //"Pesquisando informa‡äes..."
     ENDIF   
 
     IF TRB->(Easyreccount("TRB")) > 0
        oMainWnd:ReadClientCoors()
         
        lPadrao:=.T.                 
        If EasyEntryPoint("EICTR280")
           ExecBlock("EICTR280",.F.,.F.,"LPADRAO") //chiba
        EndIf                                 
        
        IF lPadrao //chiba
        
           DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+cTitulo;
                  FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
                  OF oMainWnd PIXEL  
              @ 00,00 MsPanel oPanel Prompt "" Size 60,28 of oDlg //LRL 27/04/04
              @ 08,(oDlg:nClientWidth-4)/2-70 BUTTON STR0018 SIZE 35,12 FONT oDlg:oFont ; //"Lead Time"
                                          ACTION (Processa(bProcessa)) OF oPanel PIXEL

              DEFINE SBUTTON FROM 08,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos)) ) ENABLE OF oPanel
              E_CriaCampos(aCamposTRB,,1)

              npos:=ASCAN(aCamposTRB,{|aTab|aTab[1]=="XX_FLAGWIN"})
              IF nPos <> 0
                 ADEL(aCamposTRB,nPos)
                 ASIZE(aCamposTRB,LEN(aCamposTRB)-1)
              ENDIF
 
              oMark:=MsSelect():New("TRB",,,aCamposTRB,@lInverte,@cMarca,{35,5,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
              
              oPanel:Align:=CONTROL_ALIGN_TOP //BCO 15/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT     
              oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT//BCO 15/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

           ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                                           {||nOpca:=0,oDlg:End()})) //LRL 27/04/04//Alinhamento MDI */ //BCO 15/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
        ELSE
           If EasyEntryPoint("EICTR280")
              ExecBlock("EICTR280",.F.,.F.,"TELA_01") //chiba
           EndIf  
        ENDIF
        
        If nOpca = 0
           E_RESET_AREA
           Return .F.
        Endif
     ENDIF
     IF TRB->(Easyreccount("TRB")) == 0
        Help(" ",1,"EICSEMREG")
     ENDIF
  ENDIF
ENDDO
RETURN 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR280Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 30/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR280Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICSIGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------
STATIC FUNCTION TR280Grava(nPrazoMed,bMsg, TDt_I, TDt_F)
*----------------------------------------------------------------------------
PRIVATE nPrazoTot:=0 //chiba

nPrazoMed:=0

WHILE !SW6->(EOF()) .And. If(cCpoAval2 == "W6_DT_ENTR",;
                             TR280DataAval(cCpoAval2) >= TDt_I .AND.;
                             TR280DataAval(cCpoAval2) <= TDt_F, .T.) .AND.;
   SW6->W6_FILIAL == xFilial("SW6")
   IF !lEmail // EOS - OS 576/02 - Quando schedulado, desvia apresentacoes na tela
      IncProc()
   ENDIF
   
   SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))

   If(bMsg # NIL, Eval(bMsg,STR0019+SW6->W6_HAWB+; //"Conhecimento "
                            " - Ötem "+TRAN(SW7->W7_COD_I,_PictItem)),)

   //SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL))
   If(!Empty(SW6->W6_LOCAL),SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL)),SY9->(DBSEEK(xFilial("SY9")+SW6->W6_DEST)) )//JVR - 30/04/2009 - tratamento do seek
   SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")))
   If TR280DataAval(cCpoAval2) < TDt_I .Or. TR280DataAval(cCpoAval2) > TDt_F
      SW6->(dbSkip())
      Loop
   EndIf
   
   lGrava:=.T.
   If EasyEntryPoint("EICTR280")
      ExecBlock("EICTR280",.F.,.F.,"LGRAVA") //
   EndIf    
   
   IF lGrava
      TRB->(DBAPPEND())
      TRB->W6_LOCAL  :=If(!Empty(SW6->W6_LOCAL),SW6->W6_LOCAL,SW6->W6_DEST)//JVR - 30/04/2009
      TRB->Y9_DESCR  :=SY9->Y9_DESCR
      TRB->W7_PO_NUM :=SW7->W7_PO_NUM
      TRB->W7_FORN   :=SW7->W7_FORN
      TRB->A2_NREDUZ :=SA2->A2_NREDUZ
      TRB->W6_HAWB   :=SW6->W6_HAWB
      TRB->W6_DI_NUM :=SW6->W6_DI_NUM
      TRB->W6_LOTE   :=SW6->W6_LOTE
      TRB->&cCpoAval1:=TR280DataAval(cCpoAval1)
      TRB->&cCpoAval2:=TR280DataAval(cCpoAval2)
      //FDR - 04/06/12
      IF(TR280DataAval(cCpoAval1)==TR280DataAval(cCpoAval2))
         TRB->WKPRAZO_R := 0
      ElseIf l280DiasUt
         TRB->WKPRAZO_R := Dias_Uteis(TR280DataAval(cCpoAval1),TR280DataAval(cCpoAval2))
      Else
         TRB->WKPRAZO_R := Dias_Corridos(TR280DataAval(cCpoAval1),TR280DataAval(cCpoAval2))
      EndIf
         
      TRB->WKPRAZO_P :=SY9->Y9_LT_TRA
      TRB->WKPRAZO_D :=TRB->WKPRAZO_R - TRB->WKPRAZO_P
      nPrazoTot+=TRB->WKPRAZO_R 
   ELSE 
      If EasyEntryPoint("EICTR280")
         ExecBlock("EICTR280",.F.,.F.,"TRBGRV") //chiba
      EndIf    
   ENDIF
   SW6->(DBSKIP())
ENDDO
dbSelectArea("TRB")
dbGoTop()
If Easyreccount("TRB") > 0
   // Deixar o arredondamento igual ao do Release 3
   cPrazoMed:=Trans((nPrazoTot/Easyreccount("TRB") * 100)/100,'9999')
   nPrazoMed:=Val(cPrazoMed)
Endif
Return .T.

*----------------------------------------------------------------------------
FUNCTION TR280Sint(bMsg,TDt_I,TDt_F)
*----------------------------------------------------------------------------
LOCAL OldTela, OldRecno:=RECNO(), OldArea:=SELECT(), nRec:=0
LOCAL WorkFile,oDlg,Tit280A:=STR0020, oPanel, oMark //" Lead Time por Porto "
LOCAL T_DBF:={ {"WKPORTO"    ,"C", 24, 0 } ,;
               {"WKREALIZ"   ,"N",  6, 0 } ,;
               {"WKPREVIS"   ,"N",  6, 0 } ,;
               {"WKREGISTRO" ,"N",  6, 0 } }

LOCAL TB_Campos:={ {"WKPORTO"    ,"", STR0021      } ,; //"Porto"
                   {"WKPREVIS"   ,"", STR0022   } ,; //"Previsto"
                   {"WKREALIZ"   ,"", STR0023  } ,; //"Realizado"
                   {"WKREGISTRO" ,"", STR0010} } //"Atraso/Antecipado"

PRIVATE cMarca := GetMark(), lInverte := .F.

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKPORTO")

If cCpoAval2 == "W6_DT_ENTR"
   SW6->(DBSETORDER(4))
   SW6->(DBSEEK(xFilial("SW6")+DTOS(TDt_I),.T.))  // by RS 2202
Else
   SW6->(dbSetOrder(1))
   SW6->(dbSeek(xFilial("SW6")))
EndIf

ProcRegua(SW6->(Easyreccount("SW6")))
   
bFor   := {||TR280DataAval(cCpoAval2)>=TDT_I .AND.;
             TR280DataAval(cCpoAval2)<=TDT_F }

bWhile := {||If(cCpoAval2 == "W6_DT_ENTR", TR280DataAval(cCpoAval2)>=TDT_I .AND.;
                                           TR280DataAval(cCpoAval2)<=TDT_F, .T.) .AND.;
             SW6->W6_FILIAL == xFilial("SW6")}

SW6->(DBEVAL({|| IncProc(), TR280Pro() }, bFor, bWhile ))

IF Work->(Easyreccount("Work")) == 0
   Help(" ",1,"EICSEMREG")
   Work->(E_EraseArq(WorkFile))
   DbSelectArea(OldArea)
   DBGOTO(OldRecno)
   Return .F.
ENDIF

DBGOTOP()
DBEVAL({||Work->WKPREVIS  :=ROUND(Work->WKPREVIS/Work->WKREGISTRO,0),;
          Work->WKREALIZ  :=ROUND(Work->WKREALIZ/Work->WKREGISTRO,0),;
          Work->WKREGISTRO:=Work->WKREALIZ-Work->WKPREVIS })

DBGOTOP()

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE Tit280A ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
       OF oMainWnd PIXEL  
   @00,00 MsPanel oPanel Prompt "" Size 60,28 of oDlg    //LRL 27/04/04 
   DEFINE SBUTTON FROM 06,(oDlg:nClientWidth-4)/2-30 TYPE 1 ACTION (oDlg:End()) ENABLE OF oPanel

   oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{26,5,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
   oDlg:lMaximized:=.T.  //LRL 27/04/04 - Maximiliza Janela
   
   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT      
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
ACTIVATE MSDIALOG oDlg ON INIT (Work->(dbGotop())) //LRL 27/04/04 //Alinhamento MDi //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

Work->(E_EraseArq(WorkFile))
DbSelectArea(OldArea)
DBGOTO(OldRecno)
Return .T.

*----------------------------------------------------------------------------
FUNCTION TR280Pro()
*----------------------------------------------------------------------------
SY9->(DBSETORDER(2))
//SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL))
If(!Empty(SW6->W6_LOCAL),SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL)),SY9->(DBSEEK(xFilial("SY9")+SW6->W6_DEST)) )//JVR - 30/04/2009 - tratamento do seek

If !Empty(SW6->W6_LOCAL)//JVR - 30/04/2009 - Tratamento de busca por destino se local estiver vazio.
   IF !Work->(DBSEEK(SW6->W6_LOCAL))
      Work->(DBAPPEND())
      Work->WKPORTO := SW6->W6_LOCAL+" "+SY9->Y9_DESCR
   EndIf
Else
   IF !Work->(DBSEEK(SW6->W6_DEST))
      Work->(DBAPPEND())
      Work->WKPORTO := SW6->W6_DEST+" "+SY9->Y9_DESCR
   EndIf   
End   
Work->WKREALIZ  += Dias_Uteis(TR280DataAval(cCpoAval1),TR280DataAval(cCpoAval2))
Work->WKPREVIS  += SY9->Y9_LT_TRA
Work->WKREGISTRO+= 1
RETURN .T.

*------------------------------------*
FUNCTION TR280Total(MTotRea,MTotA_T)
*------------------------------------*
LOCAL _PictItem := ALLTRIM(X3Picture("B1_COD"))
Linha++
@ Linha,T_Len[3,2] SAY REPL("-",T_Len[3,1])
@ Linha,T_Len[4,2] SAY REPL("-",T_Len[4,1])
Linha++
@ Linha,T_Len[3,2]+03 SAY TRAN(MTotRea,'999999')
@ Linha,T_Len[4,2]+11 SAY TRAN(MTotA_T,'999999')
RETURN .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR285Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 30/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR285Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICSIGA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------------------------------------------------------------
STATIC FUNCTION TR285Grava(nPrazoMed,bMsg,TForn,TDt_I,TDt_F,TFornLoj)
*----------------------------------------------------------------------------
PRIVATE nPrazoTot:=0//chiba                         
PRIVATE bFilter  :={||.T.} //chiba

WHILE !SW6->(EOF()) .And. If(cCpoAval2 == "W6_DT_ENTR",;
                             TR280DataAval(cCpoAval2) >= TDt_I .AND.;
                             TR280DataAval(cCpoAval2) <= TDt_F, .T.) .AND.;
       SW6->W6_FILIAL == xFilial("SW6")
 
   IF !lEmail // EOS - OS 576/02 - Quando schedulado, desvia apresentacoes na tela
      IncProc()
   ENDIF

   SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))

   If(bMsg # NIL,Eval(bMsg,STR0019+SW6->W6_HAWB+STR0024+; //"Conhecimento "###" - Ötem "
                           TRAN(SW7->W7_COD_I,_PictItem)),)

   IF EICLOJA()
      IF (!Empty(TForn) .AND. IIF(EICLoja(),!Empty(TFornLoj),.T.)) .AND. (TForn+TFornLoj <> SW7->W7_FORN+SW7->W7_FORLOJ)
         SW6->(DBSKIP()) ; LOOP
      ENDIF
   ELSE
      IF !Empty(TForn) .AND. TForn <> SW7->W7_FORN
         SW6->(DBSKIP()) ; LOOP
      ENDIF
   ENDIF
   If TR280DataAval(cCpoAval2) < TDt_I  .Or. TR280DataAval(cCpoAval2) > TDt_F
      SW6->(dbSkip())
      Loop
   EndIf
   
   lGrava:=.T.
   If EasyEntryPoint("EICTR280")
       ExecBlock("EICTR280",.F.,.F.,"LGRAVAS") //
   EndIf    
  
   IF !EVAL(bFilter)//CHIBA
      SW6->(dbSkip())
      Loop
   EndIf
  
   SW0->(DBSEEK(xFilial("SW0")+SW7->W7_CC+SW7->W7_SI_NUM))
  
   //DFS - Nopado para que não apresente mensagem ao selecionar o filtro na Duração do Processo
   
      /*
   IF SW0->( EOF() )
      IF !lEmail // EOS - OS 576/02 - Quando schedulado, desvia apresentacoes na tela
         Help("", 1, "AVG0003001",,(AVSX3("W0__CC",5)+"/S.I. "+SW7->W7_CC+" / "+SW7->W7_SI_NUM,1,1))
      ENDIF
      EXIT
   ENDIF 
    */ 
   
 SW2->(DBSETORDER(1))
   //SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL))
   If(!Empty(SW6->W6_LOCAL),SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL)),SY9->(DBSEEK(xFilial("SY9")+SW6->W6_DEST)) )//JVR - 30/04/2009 - tratamento do seek
   SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")))
   SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
   SYR->(DBSEEK(xFilial("SYR")+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))

 
   IF lGRAVA
      TRB->(DBAPPEND())
      TRB->W7_PO_NUM :=SW7->W7_PO_NUM
      TRB->W7_FORN   :=SW7->W7_FORN
      TRB->A2_NREDUZ :=SA2->A2_NREDUZ
      TRB->W6_HAWB   :=SW6->W6_HAWB
      TRB->W6_DI_NUM :=SW6->W6_DI_NUM
      TRB->W6_LOTE   :=SW6->W6_LOTE
      TRB->&cCpoAval1:=TR280DataAval(cCpoAval1)
      TRB->&cCpoAval2:=TR280DataAval(cCpoAval2)
   IF EICLoja()
      TRB->W7_FORLOJ:=SW7->W7_FORLOJ
   EndIf
      IF TR280DataAval(cCpoAval1)==TR280DataAval(cCpoAval2)
         TRB->WKPRAZO_R := 0
      ElseIf l285DiasUt
         TRB->WKPRAZO_R := Dias_Uteis(TR280DataAval(cCpoAval1),TR280DataAval(cCpoAval2))
      Else
         TRB->WKPRAZO_R := Dias_Corridos(TR280DataAval(cCpoAval1),TR280DataAval(cCpoAval2)) //TRP-07/08/07
      EndIf

      nPrazo:= EasyGParam("MV_LT_COMP") + EasyGParam("MV_LT_PROF") + ;
               EasyGParam("MV_LT_LICE") + SYR->YR_TRANS_T    + ;
               SY9->Y9_LT_TRA      + SY9->Y9_LT_DES
   
      TRB->WKPRAZO_P := IF (l285DiasUt, nPrazo, Prazo_Prev(nPrazo,TR280DataAval(cCpoAval1),TR280DataAval(cCpoAval1))) //TRP-07/08/07
      TRB->WKPRAZO_D :=TRB->WKPRAZO_R - TRB->WKPRAZO_P

      nPrazoTot+=TRB->WKPRAZO_R
   ELSE
      If EasyEntryPoint("EICTR280")
         ExecBlock("EICTR280",.F.,.F.,"TRBGRVS") //chiba
      EndIf
   ENDIF

   SW6->(DBSKIP())
ENDDO
dbSelectArea("TRB")
dbGoTop()
If Easyreccount("TRB") > 0
   // Deixar o arredondamento igual ao do Release 3
   cPrazoMed:=Trans((nPrazoTot/Easyreccount("TRB") * 100)/100,'9999')
   nPrazoMed:=Val(cPrazoMed)
Endif
Return .T.

*----------------------------------------------------------------------------
FUNCTION TR285Sint(bMsg,TDt_I,TDt_F)
*----------------------------------------------------------------------------
LOCAL OldTela, OldRecno:=RECNO(), OldArea:=SELECT(), nRec:=0
LOCAL WorkFile,oDlg,oPanel,Tit285A:=STR0027 //" Lead Time por Frete "

LOCAL T_DBF:={ {"WKOR_DE_VI" ,"C", 40, 0 } ,;
               {"WKREALIZ"   ,"N",  6, 0 } ,;
               {"WKPREVIS"   ,"N",  6, 0 } ,;
               {"WKREGISTRO" ,"N",  6, 0 } }

LOCAL TB_Campos:={ {"WKOR_DE_VI" ,"", STR0028},; //"Origem/Destino/Via/Local"
                   {"WKPREVIS"   ,"", STR0022   } ,; //"Previsto"
                   {"WKREALIZ"   ,"", STR0023  } ,; //"Realizado"
                   {"WKREGISTRO" ,"", STR0010} } //"Atraso/Antecipado"

PRIVATE cMarca := GetMark(), lInverte := .F.

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKOR_DE_VI")

If cCpoAval2 == "W6_DT_ENTR"
   SW6->(DBSETORDER(4))
   SW6->(DBSEEK(xFilial("SW6")+DTOS(TDt_I),.T.))  // by RS 2202
Else
   SW6->(dbSetOrder(1))
   SW6->(dbSeek(xFilial("SW6")))
EndIf

ProcRegua(SW6->(Easyreccount("SW6")))
bFor   := {||TR280DataAval(cCpoAval2)>=TDT_I .AND. TR280DataAval(cCpoAval2)<=TDT_F }

bWhile := {||If(cCpoAval2 == "W6_DT_ENTR", TR280DataAval(cCpoAval2)>=TDT_I .AND.;
                                           TR280DataAval(cCpoAval2)<=TDT_F, .T.) .AND.;
             SW6->W6_FILIAL == xFilial("SW6")}

SW6->(DBEVAL({|| IncProc(), TR285Pro() }, bFor, bWhile ))
         
IF Work->(Easyreccount("Work")) = 0
   Help(" ",1,"EICSEMREG")
   Work->(E_EraseArq(WorkFile))
   DbSelectArea(OldArea)
   DBGOTO(OldRecno)
   Return .F.
ENDIF

DBGOTOP()
DBEVAL({||Work->WKPREVIS  :=ROUND(Work->WKPREVIS/Work->WKREGISTRO,0),;
          Work->WKREALIZ  :=ROUND(Work->WKREALIZ/Work->WKREGISTRO,0),;
          Work->WKREGISTRO:=Work->WKREALIZ-Work->WKPREVIS })

DBGOTOP()

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE Tit285A ; 
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
       OF oMainWnd PIXEL  
   @00,00 MsPanel oPanel Prompt "" Size 60,28 of oDlg //LRL 27/04/04
   oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{26,5,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})

   DEFINE SBUTTON FROM 06,(oDlg:nClientWidth-4)/2-30 TYPE 1 ACTION (oDlg:End()) ENABLE OF oPanel
   oDlg:lMaximized:=.T. //LRL 27/04/04 - Maximiliza Janela
   
   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT    
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
ACTIVATE MSDIALOG oDlg ON INIT (Work->(dbGotop())) //LRL 27/04/04 // Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

Work->(E_EraseArq(WorkFile))
DbSelectArea(OldArea)
DBGOTO(OldRecno)
Return .T.

*----------------------------------------------------------------------------
FUNCTION TR285Pro()
*----------------------------------------------------------------------------
LOCAL cChave
SW2->(DBSETORDER(1))
//SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL))
If(!Empty(SW6->W6_LOCAL),SY9->(DBSEEK(xFilial("SY9")+SW6->W6_LOCAL)),SY9->(DBSEEK(xFilial("SY9")+SW6->W6_DEST)) )//JVR - 30/04/2009 - tratamento do seek
SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
SW2->(DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM))
SYR->(DBSEEK(xFilial("SYR")+SW2->W2_TIPO_EM+SW2->W2_ORIGEM+SW2->W2_DEST))
SYQ->(DBSEEK(xFilial("SYQ")+SW2->W2_TIPO_EMB))

cChave:=SW2->W2_ORIGEM+"/"+SW2->W2_DEST+"/"+SW2->W2_TIPO_EM+'-'+LEFT(SYQ->YQ_DESCR,15)+"/"+SY9->Y9_DESCR

IF ! Work->(DBSEEK(cChave))
   Work->(DBAPPEND())
   Work->WKOR_DE_VI:=ALLTRIM(cChave)
ENDIF

If l285DiasUt
   Work->WKREALIZ  += Dias_Uteis(TR280DataAval(cCpoAval1),TR280DataAval(cCpoAval2))
Else
   Work->WKREALIZ  += Dias_Corridos(TR280DataAval(cCpoAval1),TR280DataAval(cCpoAval2)) //TRP-07/08/07
EndIf
Work->WKPREVIS  += EasyGParam("MV_LT_COMP") + EasyGParam("MV_LT_PROF") + ;
                   EasyGParam("MV_LT_LICE") + SYR->YR_TRANS_T    + ;
                   SY9->Y9_LT_TRA      + SY9->Y9_LT_DES

Work->WKREGISTRO+= 1
RETURN .T.

*------------------------------------*
FUNCTION TR285Total(MTotRea,MTotA_T)
*------------------------------------*
Linha++
@ Linha,T_Len[3,2] SAY REPL("-",T_Len[3,1])
@ Linha,T_Len[4,2] SAY REPL("-",T_Len[4,1])
Linha++
@ Linha,T_Len[3,2]+03 SAY TRAN(MTotRea,'999999')
@ Linha,T_Len[4,2]+11 SAY TRAN(MTotA_T,'999999')
RETURN .T.

*----------------------------------------------------------------------------
FUNCTION TR285ValForn()
*----------------------------------------------------------------------------
If !ExistCpo("SA2",mv_par01)
   Return .F.
Else
   If Empty(mv_par02)
      SA2->(DbSeek(xFilial()+mv_par01))
      mv_par02 := If(SA2->(FieldPos("A2_LOJA")) > 0,SA2->A2_LOJA,"")   // GFP - 25/04/2012 - Gatilha Loja
   EndIf
EndIf

SW2->(dbSetOrder(2))
If (!Empty(mv_par01)) .And. ! SW2->(DBSEEK(xFilial("SW2")+mv_par01))
   Help("", 1, "AVG0003002")//MsgInfo(STR0029,STR0026) //"NÆo h  P.O.s p/ este Fornecedor"###"Informação"
   Return .F.
Endif
Return .T.

*----------------------------------------------------------------------------
FUNCTION TR280DataAval(cCpoAval)
*----------------------------------------------------------------------------
Local cAlias
cAlias := If(Substr(cCpoAval,3,1)=="_", "S"+Substr(cCpoAval,1,2), Substr(cCpoAval,1,3))+"->"
cCpoAval:= cAlias+cCpoAval
Return(&cCpoAval)
                          

//JPA - 20/07/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW6","SW7","SA2"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Cria o objeto principal de controle do relatório.                                                     
If P_Qual=Transportes 
   AADD(aTabelas, "SY9")
   cNome:= "Avaliações por pedidos"
   //Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
   oReport := TReport():New( "EICTR280", STR0001, "EIC280", {|oReport| ReportPrint(oReport)}, STR0003 + " " + STR0011)

   //ER - 20/10/2006 - Inicia o relatório como paisagem. 
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F. 
   
Else
   cNome:= "Pedidos"
   oReport := TReport():New("EICTR285", STR0002, "EIC285", {|oReport| ReportPrint(oReport)}, STR0003 + " " + STR0013)   
   
   //ER - 20/10/2006 - Inicia o relatório como paisagem. 
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F. 

EndIf
//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
If P_Qual=Transportes
   TRCell():New(oSecao1, "W6_LOCAL" , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
   TRCell():New(oSecao1, "Y9_DESCR" , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
EndIf

TRCell():New(oSecao1, "W7_PO_NUM", "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W7_FORN"  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/) 
If EICLoja()
   TRCell():New(oSecao1, "W7_FORLOJ"  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/) 
EndIf
TRCell():New(oSecao1, "A2_NREDUZ", "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W6_HAWB"  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W6_DI_NUM", "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W6_LOTE"  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, cCpoAval1  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, cCpoAval2  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPRAZO_R", "TRB", STR0008      , "@E 99,999"   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPRAZO_P", "TRB", STR0009      , "@E 99,999"   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKPRAZO_D", "TRB", STR0010      , "@E 99,999"   , /*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/)


oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Prazo Médio em Dias")

oTotal:= TRFunction():New(oSecao1:Cell("WKPRAZO_R"),NIL,"SUM",/*oBreak*/,"","@E 99,999",{|| TRB->WKPRAZO_R/TRB->(EasyRecCount("TRB")) },.T.,.F.)
oTotal:SetTotalInLine(.F.)

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport


************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section(cNome)
Local nTotProc := TRB->(EasyRecCount("TRB")) //Acb - 05/10/2010 - Incluida variavel para que possa ser emitido o total de processo do relatório

If P_Qual=Transportes
   //Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
   TRPosition():New(oReport:Section(cNome),"SY9",3,{|| xFilial("SY9") + If(!Empty(SW6->W6_LOCAL),SW6->W6_LOCAL,SW6->W6_DEST)})//JVR - 30/04/2009
EndIf                                                                                        

TRPosition():New(oReport:Section(cNome),"SW7",1,{|| xFilial("SW7") + TRB->W7_PO_NUM})
TRPosition():New(oReport:Section(cNome),"SA2",1,{|| xFilial("SA2") + SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")})
TRPosition():New(oReport:Section(cNome),"SW6",1,{|| xFilial("SW6") + TRB->W6_HAWB})

oReport:SetMeter(TRB->(EasyRecCount("TRB")))
TRB->(dbGoTop())

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section(cNome):Init()

//Laço principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   oReport:Section(cNome):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo
//Fim da impressão da seção 1
oReport:Section(cNome):Finish()                                
oReport:PrintText('Tot.Processos:  '+ALLTRIM(STR(nTotProc)))
TRB->(DBGOTOP())


return .T.        
