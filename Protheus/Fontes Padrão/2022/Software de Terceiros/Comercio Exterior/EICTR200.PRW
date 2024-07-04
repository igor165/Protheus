#INCLUDE "Eictr200.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"

#DEFINE SAIU_DECEX    "1"
#COMMAND E_RESET_AREA => SYI->(DBSETORDER(4)) ; SW4->(DBSETORDER(1)) ;
                       ; DBSELECTAREA(nOldArea) ; IF(Select("TRB")>0,TRB->(E_EraseArq(cNomArq)),)
                       
#DEFINE Aprovacao_LI  "1"
#DEFINE Validade_LI   "2"
#DEFINE FollowUp_Neg  "3"                       
#DEFINE Confec_LI     "4"                       

#DEFINE Ag_Transferencia 1
#DEFINE Ag_Registro      2
#DEFINE Ag_Anuencia      3



#DEFINE CAMPOS     IF(nTipo=Aprovacao_LI, TB1_Campos, TB2_Campos)
#DEFINE TITULO     IF(nTipo=Aprovacao_LI, UPPER(ALLTRIM(SUBSTR(aTipo[nopcao],4))), STR0001) //"VALIDADE DE LI's"

#DEFINE EXP2       

#define PRAZO STR0002 //"Prazo"
#define ITEM  STR0003 //"Item"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR200 ³ Autor ³ MicroSiga/Average     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Follow-Up em Negociacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR200()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// EOS - OS 569/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR200
// um parametro como .T. identificando que é schedulado  
*---------------------------*
Function EICTR200S()
*---------------------------*
DBSELECTAREA("SW1")
DBSELECTAREA("SW0")
DBSELECTAREA("SY1")
DBSELECTAREA("SB1")
DBSELECTAREA("SA5")
EICTR200(.T.)
RETURN .T.

*---------------------------*
Function EICTR200(lSXD)
*---------------------------*

EICTR200R3(lSXD,.T.)

RETURN .T.

*---------------------------*
Function EICTR200R3(lSXD,P_R4)
*---------------------------*
LOCAL cAlias:="SY1"
PRIVATE aRotina := { { STR0004, "AxPesqui"   , 0 , 1} ,; //"Pesquisar"
                     { STR0005, "TR200Compr" , 0 , 2} ,; //"Atual"
                     { STR0006, "TR200Compr" , 0 , 2} } //"Todos"

PRIVATE cCadastro := OemtoAnsi(STR0007) //"Follow-Up em Negocia‡ao - Compradores"
PRIVATE cMarca := GetMark(), lInverte := .F., nPrzMed:=0
PRIVATE lEMail:=!lSXD = Nil // EOS OS 569/02
PRIVATE lR4 := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()                  
Private cNome1,cNome2
//IF lR4
   //AAF - 20/06/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   //oReport := ReportDef(FollowUp_Neg)    //FollowUp_Neg
//ENDIF



IF lEMail // EOS OS 569/02 - Desvia apresentacoes em tela se schedulado
   TR200Compr(cAlias,SY1->(RECNO()),1)
ELSE
   mBrowse( 6, 1,22,75,cAlias)
ENDIF
Return .T.


*--------------------------------------------*
FUNCTION TR200Compr(cAlias,nReg,nOpcx)
*--------------------------------------------*
LOCAL _LIT_R_CC := If(Empty(ALLTRIM(EasyGParam("MV_LITRCC"))),AVSX3("W0__CC",5),ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL cCadastro := OemtoAnsi(STR0008) //"Follow-Up em Negocia‡ao"
LOCAL nSavRec  := RecNo(),nComprador:='', cIndice2, oGet,;
      cTitulo, cLeadTime:=PadL(EasyGParam("MV_LT_COMP"),4,"0")
PRIVATE oDlg, oPanel //DRL 16/07/10 - Para manipulacao via Ponto de Entrada
PRIVATE  aCamposTRB:={} //igor chiba 31/08/2010
PRIVATE aDados :={"TRB",;
                STR0009,; //"Este relatorio ir  emitir a rela‡„o de S.I.s em fase  "
                STR0010,; //"de negocia‡ao."
                "",;
                "G",;
                132,;
                "Lead Time: "+cLeadTime,;
                "",;
                STR0011,; //"Follow-up: Em Negociacao "
                { STR0012, 1,STR0013, 1, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
                "EICTR200",;
                { {||IF(!lEmail,!EMPTY(ALLTRIM(TRB->XX_FLAGWIN)),.T.)},;
                  {|| TR_RelMed(116,nPrzMed)} } }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cArqRdmake:="EICTRNEC"
Private aCampos:={ "W0__CC","W0__NUM","W0__DT","W1_COD_I","W1_SALDO_Q", "B1_DESC",;
                   "W1_DTENTR_","W0_COMPRA","Y1_NOME", "W1_POSICAO","W1_PRAZO"}   // JBS - 22/09/2003  -> //,"W1_PRAZO"}

Private _PictSI   := ALLTRIM(X3Picture("W0__NUM"))
Private _PictItem := ALLTRIM(X3Picture("B1_COD"))
Private aHeader[0], aReturn := aDados[10]
Private aRCampos:={ ;
                  {"W0__CC"                               , _LIT_R_CC  , "C"}  ,;
                  {"TRAN(W0__NUM,'"+_PictSI+"')"          , STR0014    , "D"}  ,; //"No. S.I."
                  {"W0__DT"                               , STR0015    , "C"}  ,; //"Dt S.I."
                  {"W1_POSICAO"                           , STR0016    , "C"}  ,; //"Posicao"
                  {"TRAN(W1_COD_I,'"+_PictItem+"')"       , STR0017    , "E"}  ,; //"Codigo do Item"
                  {"TRAN(W1_SALDO_Q,'@E 999,999,999.999')", STR0018    , "D"}  ,; //"Quantidade"
                  {"B1_DESC"                              , STR0019    , "E"}  ,; //"Descricao em Portugues"
                  {"W1_DTENTR_"                           , STR0020    , "C"}  ,; //"Prev Entrega"
                  {"TRAN(W1_PRAZO,'99999')"               , STR0021    , "D"}  ,; //"Prazo Decorrido"
                  {"W0_COMPRA"                            , STR0022    , "D"}   } //"Comp"    
                  

IF EasyEntryPoint(cArqRdmake)
   nExecute:="1"
   lTopConn:=.F.
   #ifdef TOP
      lTopConn:=.T.
   #endif
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

If  nOpcx = 2
    nComprador:=SY1->Y1_COD
    cTitulo:=STR0023+ALLTRIM(SY1->Y1_NOME)+"  " //"  Comprador: "
Else
    cTitulo:=""
Endif

If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR200CAMPOS"),)  //DRL 15/07/10

aCamposTRB:= CriaEstru(aCampos,@aHeader)
AAdd(aCamposTRB,{"W1_FLAG"   ,"C",2,0})
AAdd(aCamposTRB,{"XX_FLAGWIN","C",2,0})
AAdd(aCamposTRB,{"W3_INDEX"  ,"C",4,0})

If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR200CPOTRB"),)  //igor chiba 31/08/10

AAdd(aCamposTRB,{"DBDELETE"  ,"L",1,0})
cNomArq := E_CriaTrab(,aCamposTRB,"TRB") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("TRB",cNomArq+TEOrdBagExt(),"DTOS(W0__DT)+W0__CC+W0__NUM+W1_COD_I")

cIndice2:=E_Create({},.F.)//APENAS GERA UM NOME PARA O INDICE 2
IndRegua("TRB",cIndice2+TEOrdBagExt(),"W1_COD_I")

SET INDEX TO (cNomArq+TEOrdBagExt()),(cIndice2+TEOrdBagExt())
// EOS OS 569/02 Se schedulado, inicializa variaveis atraves do pergunte, e atraves do
// setprint carrega as variaveis mv_par?? e a ordem do relatorio (aReturn[8])
IF lEMail  
   IF Pergunte("EIC200",.F.)
      aDados[11] := SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
      nComprador := MV_PAR01
      
      TR200Grava(nComprador)
      TR200Print(aDados,aRCampos,.T.)
   ENDIF
ELSE
   Processa( {|| TR200Grava(nComprador),.T.},;
                 STR0025,STR0026) //"Pesquisa de S.I.s"###"Selecionando registros - aguarde..."

   dbSelectArea("TRB")
   dbGoTop()
   E_CriaCampos(aCamposTRB)

   oMainWnd:ReadClientCoords()

   DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+OemToAnsi(cTitulo) ;
   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
   OF oMainWnd PIXEL  
   @ 00,00 MsPanel oPanel Prompt "" Size 60,28 of oDlg  //LRL 26/04/04 - Painel para alinhamento MDI.
   @ 10,06 SAY   OemToAnsi(STR0027) SIZE 60,08 of oPanel PIXEL //"Lead Time"
   @ 08,48  MSGET cLeadTime WHEN .F. SIZE 32,08 CENTERED of oPanel PIXEL
   @ 10,80  SAY  OemToAnsi(STR0028) SIZE 60,08 of oPanel PIXEL //"Prazo M‚dio"
   @ 08,128  MSGET nPrzMed WHEN .F. SIZE 32,08 CENTERED of oPanel PIXEL
   
   If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR200ANTES_GET"),) //DRL 16/07/10 - Para colocar mais gets na tela
                                                                      
   oMark:= MsSelect():New("TRB","XX_FLAGWIN",,aCamposTRB,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
   oMark:bAval:={||TRB->XX_FLAGWIN:=IF(EMPTY(TRB->XX_FLAGWIN),cMarca,"   " ) }

   DEFINE SBUTTON FROM 08,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (TR200Print(aDados,aRCampos,.T.),oMark:oBrowse:Refresh()) ENABLE OF oPanel

   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT              
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})) //LRL 26/04/04 - //Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ENDIF
TRB->(E_EraseArq(cNomArq,cIndice2))
dbSelectArea(cAlias)
dbGoTo(nSavRec)
Return NIL

*-----------------------------------*
FUNCTION TR200Grava(nQual)
*-----------------------------------*
LOCAL nPrazoTot:=0, nCont:=0, cFilSW1:=xFilial("SW1") 
LOCAL bWhile:={||cFilSW1 == SW1->W1_FILIAL .AND. SW1->W1_SEQ = 0 .AND. SW1->W1_SALDO_Q > 0 }

PRIVATE cCompr:=nQual

bFor:={||SW0->(DBSEEK(xFilial()+SW1->W1_CC+SW1->W1_SI_NUM)),;
             ( EMPTY(cCompr) .OR. RTRIM(cCompr) == RTRIM(SW0->W0_COMPRA) ) }

IF EasyEntryPoint(cArqRdmake)//AWR 07/04/99
   nExecute:="3"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF !LEMAIL // EOS OS 569/02 - Se schedulado, desvia apresentacoes em tela
   ProcRegua( SW1->(Easyreccount("SW1")) )
ENDIF

SA5->(DBSETORDER(3))//Para o Rdmake


SW1->(DBSETORDER(4))
SW1->(DBSEEK(xFilial()+STR(0,2,0)+STR(0.001,13,3),.T.))
SW1->(DBEVAL({|| IF(!LEMAIL,IncProc(STR0029+ALLTRIM(SW1->W1_COD_I)),),; //"Processando Item: "
                 SB1->(DBSEEK(xFilial()+SW1->W1_COD_I)),;
                 SY1->(DBSEEK(xFilial()+SW0->W0_COMPRA)),;
                 nPrazoTot+=TR200Atualiza() },;
                 bFor,bWhile))

SW1->(DBSETORDER(1))

IF TRB->(Easyreccount("TRB")) > 0
   nPrzMed:=INT((nPrazoTot/TRB->(Easyreccount("TRB")) * 100)/100)
ENDIF       
IF VALTYPE(nPrzMed) = "N"
   nPrzMed := STR(nPrzMed,4)
ENDIF
SA5->(DBSETORDER(1))
RETURN NIL

*---------------------------------------------------------------------------
FUNCTION TR200Atualiza()
*---------------------------------------------------------------------------

lLoop := .F. //DRL 15/07/10
If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR200VALID_APPEND"),)  //DRL 15/07/10 - Validacao Customizada
If lLoop
   Return 0
EndIf

TRB->(DBAPPEND())
REPLACE TRB->W1_COD_I   WITH SW1->W1_COD_I,;
        TRB->W0__CC     WITH SW1->W1_CC,;
        TRB->W0__NUM    WITH SW1->W1_SI_NUM,;
        TRB->W0__DT     WITH SW0->W0__DT,;
        TRB->W1_SALDO_Q WITH SW1->W1_SALDO_Q,;
        TRB->W1_POSICAO WITH SW1->W1_POSICAO,;//AWR 12/02/99
        TRB->B1_DESC    WITH SB1->B1_DESC,;
        TRB->W1_DTENTR_ WITH SW1->W1_DTENTR_,;
        TRB->W0_COMPRA  WITH SW0->W0_COMPRA,;
        TRB->Y1_NOME    WITH SY1->Y1_NOME //,;


IF EasyEntryPoint(cArqRdmake)//AWR 11/01/99
   nExecute:="2"
   ExecBlock(cArqRdmake,.F.,.F.)
ELSE
   TRB->W1_PRAZO:=Dias_Uteis(SW0->W0__DT)
ENDIF
 
TRB->W1_FLAG:=IF(TRB->W1_PRAZO>EasyGParam("MV_LT_COMP"),'','   ') //protheus

If !Empty(TRB->W1_FLAG)
   REPLACE TRB->XX_FLAGWIN WITH cMarca
Endif

If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR200APPEND"),)  //DRL 15/07/10
TRB->W3_INDEX := STR(9999-TRB->W1_PRAZO,4,0)
RETURN TRB->W1_PRAZO

*------------------------------------------*
FUNCTION TR200Print(aDados,aRCampos,lMarca)
*------------------------------------------*
LOCAL nOpcao:=1, oRad, oDlg, nCont:=0, nTotal:=0, SvItem:=TRB->W1_COD_I
LOCAL bActionItem:={||TRB->(DBSETORDER(nOpcao)) ,;
                      TRB->(DBGOTOP())          ,;
                      {|| TR_TOTQTD(45,@nTotal,TRB->W1_SALDO_Q,@SvItem,@nCont)} ,;
                      {|| ++Linha,TR_TOTQTD(45,@nTotal,TRB->W1_SALDO_Q,@SvItem,@nCont),TR_RelMed(116,nPrzMed) } }

LOCAL bActionData:={||TRB->(DBSETORDER(nOpcao)) ,;
                      TRB->(DBGOTOP())          ,;
                      {|| TR_RelMed(116,nPrzMed)} }
                      
//EOS 0569/02 Se schedulado, seta ordem escolhida e dispara a impressao                       
IF lEMail
   nOpcao := aReturn[8]
   IF(aReturn[8]=1, EVAL(bActionData), EVAL(bActionItem))
   E_Report(aDados,aRCampos,.T.,.F.)
   
ELSE
   DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0030) From 18,04 To 24,44 OF oMainWnd //"Impressao"

      @ 6,6 RADIO oRad VAR nOpcao ITEMS STR0031,STR0032 3D SIZE 80,11 PIXEL //" Data / U.R. / S.I"###" Item"

      DEFINE SBUTTON FROM 08,110 TYPE 1 ACTION (IF(nOpcao==1,EVAL(bActionData),EVAL(bActionItem)),;
                                                   If(!lR4,E_Report(aDados,aRCampos,lMarca),(oReport := ReportDef(FollowUp_Neg),oReport:PrintDialog())),oDlg:End()) ENABLE OF oDlg
      DEFINE SBUTTON FROM 25,110 TYPE 2 ACTION (nOpcao:=0,oDlg:End()) ENABLE OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED
ENDIF
RETURN NIL

*-------------------------------------------------*
FUNCTION TR_TOTQTD(nCol,nTotal,Qtde,SvItem,nCont)
*-------------------------------------------------*
IF SvItem <> TRB->W1_COD_I
   IF nCont > 1
      @Linha+2,nCol  PSAY STR0033+TRAN(nTotal,'@E 999,999,999.999') //"Total Qtde.:   "
      Linha+=3
   ELSE
      Linha++
   ENDIF
   SvItem:=TRB->W1_COD_I
   nTotal:=Qtde
   nCont:=1
ELSE
   nTotal+=Qtde
   ++nCont
ENDIF
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR210 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 16.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Follow-Up Aguardando Proforma                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR210()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// EOS - OS 569/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR210
// um parametro como .T. identificando que é schedulado  
******************
FUNCTION EICTR210S
******************
EICTR210(.T.)
RETURN NIL    

***********************
Function EICTR210(lSXD)
**********************

EICTR210R3(lSXD, .T.)                   
                   
Return .T.

***********************
Function EICTR210R3(lSXD, p_R4)
***********************
LOCAL   nOldArea:=SELECT()
                     
PRIVATE lEMail:=!lSXD = Nil  // EOS - OS 569/02                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0034), nOpca:=1 //"Confeccao de P.L.I's"

PRIVATE lR4 := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()                  
Private cNome1
//IF lR4
   //AAF - 20/06/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   //oReport := ReportDef(Confec_LI)    //Confec_LI
//ENDIF

TR210Impor(1,3,.T.)
DBSelectArea(nOldArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR210Impor³ Autor ³ MicroSiga/Average     ³ Data ³ 16.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de consulta Aguardando Proforma                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR210Impor(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION TR210Impor(nReg,nOpcx, p_R4)
LOCAL nSavRec  := RecNo(), nPrazoMed:=0,  nPos,;
      cIndice2, cTitulo, cLeadTime:=STR(EasyGParam("MV_LT_PROF"),2,0)

LOCAL aDados :={"TRB",;
                STR0035,; //"Este relatorio ir  exibir a rela‡Æo de Purchase Orders"
                STR0036,; //"Confeccao PLIs."
                "",;
                "G",;
                132,;
                "",;
                "",;
                STR0037,; //"Confeccao LIs"
                { STR0012, 1,STR0013, 1, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
                "EICTR210",;
                { {|| .T. } , {|| TR_RelMed(110,nPrazoMed) }  }  }

PRIVATE oDlg, oGet, oPanel1, cImportador:=SPACE(LEN(SW2->W2_IMPORT))
PRIVATE cMarca := GetMark(), lInverte := .F., aHeader[0], aReturn := aDados[10]   

PRIVATE aCamposTRB:={}, aRCampos:={}    //igor chiba 31/08/2010

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCampos:={ "W3_PO_NUM","W2_PO_DT","W3_CC","W3_SI_NUM","W3_POSICAO",;
                   "W3_COD_I","B1_DESC","W3_QTDE","W3_DT_ENTR","W2_DT_PRO", "W1_PRAZO",;
                   "W2_COMPRA", "Y1_NOME"}, oMark //"W1_PRAZO"     
                       
If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR210CAMPOS"),)  // EOB - 19/01/10
                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria WorkFile para GetDadDB()                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCamposTRB:= CriaEstru(aCampos,@aHeader)
aHeader[10,1]:=STR0088 //"Confeccionar Até"

AAdd(aCamposTRB,{"XX_FLAGWIN","C",2,0})
AAdd(aCamposTRB,{"W1_PRAZO"  ,"N",6,0})
AAdd(aCamposTRB,{"W3_INDEX"  ,"C",4,0})

If(EasyEntryPoint("EICTR210"),Execblock("EICTR210",.F.,.F.,"TR210CPOTRB"),)  // igor chiba 31/08/2010

cNomArq := E_CriaTrab(,aCamposTRB,"TRB") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

cNomArq := cNomArq+TEOrdBagExt()

cIndice2:= LEFT(cNomArq,7)+"A"+TEOrdBagExt()
INDEX ON TRB->W3_INDEX+TRB->W3_PO_NUM TO (cNomArq)
INDEX ON TRB->W3_COD_I TO (cIndice2)
SET INDEX TO (cNomArq),(cIndice2)
E_CriaCampos(aRCampos,.T.,1)
nPos := ASCAN(aRCampos, {|x| "Y1_NOME" $ x[1]})
IF nPos > 0  // elimina o nome do comprador
   ADEL(aRCampos, nPos)
   aSize(aRCampos,Len(aRCampos)-1) 
ENDIF

If(EasyEntryPoint("EICTR210"),Execblock("EICTR210",.F.,.F.,"TR210RCAMPOS"),)  // igor chiba 31/08/2010


WHILE .T.
   // EOS OS 569/02 Se schedulado, inicializa variaveis atraves do pergunte, e atraves do
   // setprint carrega as variaveis mv_par?? e a ordem do relatorio (aReturn[8])
   IF !Pergunte("EIC210",IF(lEmail,.F.,.T.)) 
      EXIT
   ENDIF 
   cImportador := MV_PAR01

   nOpca:=0
   
   IF lEmail
      aDados[11]  := SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
      
      TRB->(DbSetOrder(aRETURN[8]))
      TRB->(DBGOTOP())
      
      cImportador := MV_PAR01
      
      nPrazoMed:=TR210Grava(cImportador)
       
      E_Report(aDados,aRCampos,.T.,.F.)
      
   ELSE
      Processa({||nPrazoMed:=TR210Grava(cImportador),.T.},STR0038) //"Pesquisa de P.O.s"
       
      dbSelectArea("TRB")
      dbGoTop()
      E_CriaCampos(aCamposTRB,,1)

      oMainWnd:ReadClientCoords()

      DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+OemToAnsi(cTitulo);
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
             OF oMainWnd PIXEL  

         TEscolha:=1
         @ 00,00 MsPanel oPanel1 Prompt "" Size 60,28 of oDlg //LRL 26/04/04 - Painel para alinhamento MDI.
         @ 10,06  SAY   OemToAnsi(STR0027) SIZE 60,08 PIXEL OF oPanel1 //"Lead Time"
         @ 08,40  MSGET cLeadTime WHEN .F. SIZE 32,08 PIXEL OF oPanel1
         @ 10,80  SAY   OemToAnsi(STR0028) SIZE 60,08 PIXEL OF oPanel1 //"Prazo M‚dio"
         @ 08,120 MSGET nPrazoMed WHEN .F. SIZE 32,08 PIXEL OF oPanel1

         npos:=ASCAN(aCamposTRB,{|aTab|aTab[1]=="XX_FLAGWIN"})
         IF nPos <> 0
            ADEL(aCamposTRB,nPos)
            ASIZE(aCamposTRB,LEN(aCamposTRB)-1)
         ENDIF

         oMark:=MsSelect():New("TRB",,"XX_FLAGWIN",aCamposTRB,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})

         @ 08,(oDlg:nClientWidth-4)/2-85 SAY STR0039 SIZE 20,08 OF oPanel1 PIXEL //"Ordem"
         @ 08,(oDlg:nClientWidth-4)/2-62 COMBOBOX TEscolha ITEMS {PRAZO,ITEM};
              SIZE 30,20 ON CHANGE Tr210_Pesq() PIXEL OF oPanel1

         DEFINE SBUTTON FROM 08,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (If(!lR4,E_Report(aDados,aRCampos),(oReport := ReportDef(Confec_LI),oReport:PrintDialog()))) ENABLE OF oPanel1
      
	  oPanel1:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||nOpca:=0,oDlg:End()})) //LRL 26/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ENDIF

   IF nOpca==0
      EXIT
   ENDIF
ENDDO

TRB->(E_EraseArq(cNomArq,cIndice2))

Return NIL

*--------------------*
Function Tr210_Pesq()
*--------------------*
Local nRec := TRB->(RecNo())

If TEscolha == PRAZO
   TRB->(DbSetOrder(1))
Else
   TRB->(DbSetOrder(2))
Endif

TRB->(DBGOTOP())
TRB->(dbGoTo(nRec))

oMark:oBrowse:Refresh()

Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR210Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 10/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR210Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICTR210                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION TR210Grava(nQual)
LOCAL nPrazoMed:=0, nPrazoTot:=0, nLeadTime:=EasyGParam("MV_LT_PROF")
LOCAL bFor  :={||SW2->(DBSEEK(xFilial()+SW3->W3_PO_NUM)),;
                 EMPTY(nQual) .OR. nQual = SW2->W2_IMPORT }
LOCAL bWhile:={||cFilSW3 == SW3->W3_FILIAL .AND. SW3->W3_SEQ = 0 .AND. SW3->W3_SALDO_Q > 0 }

cFilSW3:=xFILIAL("SW3")

IF !lEMAIL  // EOS OS 569/02 Se schedulado, desvia apresentacoes em tela
   ProcRegua( SW3->(Easyreccount("SW3")) )
ENDIF
SW3->(DBSETORDER(6))
SW3->(DBSEEK(xFilial()+STR(0,2,0)+STR(0.001,13,3),.T.))
SW3->(DBEVAL({||IF(!lEmail,IncProc(STR0029+ALLTRIM(SW3->W3_COD_I)),),; //"Processando Item: "
                SB1->(DBSEEK(xFilial()+SW3->W3_COD_I)),;
                SY1->(DBSEEK(xFilial()+SW2->W2_COMPRA)),;
                nPrazoTot+=TR210Atualiza(nLeadTime)},;
                bFor,bWhile))

SW3->(DBSETORDER(1))

IF TRB->(Easyreccount("TRB")) > 0
   nPrazoMed:=INT((nPrazoTot/TRB->(Easyreccount("TRB")) * 100)/100)
ENDIF       
nPrazoMed:=Str(nPrazoMed,4)
RETURN nPrazoMed

*---------------------------------------------------------------------------
FUNCTION TR210Atualiza(nLeadTime)
*---------------------------------------------------------------------------
LOCAL dDataPrazo:= (SW3->W3_DT_EMB-EasyGParam("MV_LT_LICE"))

TRB->(DBAPPEND())
REPLACE TRB->W3_COD_I   WITH SW3->W3_COD_I,;
        TRB->W3_CC      WITH SW3->W3_CC,;
        TRB->W3_SI_NUM  WITH SW3->W3_SI_NUM,;
        TRB->W3_PO_NUM  WITH SW3->W3_PO_NUM,;
        TRB->W2_PO_DT   WITH IF(! EMPTY(SW2->W2_DT_ALTER),;
                                        SW2->W2_DT_ALTER,SW2->W2_PO_DT),;
        TRB->W3_POSICAO WITH SW3->W3_POSICAO,;//AWR 18/02/99
        TRB->W3_COD_I   WITH SW3->W3_COD_I,;
        TRB->B1_DESC    WITH SB1->B1_DESC,;
        TRB->W3_QTDE    WITH SW3->W3_SALDO_Q,;
        TRB->W3_DT_ENTR WITH SW3->W3_DT_ENTR,;
        TRB->W2_COMPRA  WITH SW2->W2_COMPRA,;
        TRB->Y1_NOME    WITH SY1->Y1_NOME,;
        TRB->W2_DT_PRO  WITH dDataPrazo,;
        TRB->W1_PRAZO   WITH Dias_Uteis(IF(TRB->W2_DT_PRO < TRB->W2_PO_DT, TRB->W2_PO_DT, TRB->W2_DT_PRO)) ,;
        TRB->XX_FLAGWIN WITH IF(TRB->W1_PRAZO>nLeadTime,cMarca,'  ')

If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR210GRAVA"),)  // EOB - 19/01/10
TRB->W3_INDEX := STR(9999-TRB->W1_PRAZO,4,0)
RETURN TRB->W1_PRAZO


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR215 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 16.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Follow-Up Aguardando PGI                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR215()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßß ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR215
LOCAL   cAlias:="SY1"
PRIVATE aRotina := {  { STR0004           , "AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                      { STR0005           , "TR215Impor", 0 , 2} ,; //"Atual"
                      { STR0006           , "TR215Impor", 0 , 3} } //"Todos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0040) //"Aguardando P.G.I."

TR215Impor(cAlias,1,3)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR215Impor³ Autor ³ MicroSiga/Average     ³ Data ³ 16.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de consulta Aguardando PGI                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR215Impor(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION TR215Impor(cAlias,nReg,nOpcx)
LOCAL nSavRec  := (cAlias)->(RecNo()), nPrazoMed:=0,;
      cIndice2, cTitulo, cLeadTime:=STR(EasyGParam("MV_LT_LICE"),2,0)

LOCAL oDlg, oGet, cImportador:=SPACE(LEN(SW2->W2_IMPORT))

LOCAl aCamposTRB:={}

LOCAL aDados :={"TRB",;
                STR0041,; //"Este relatorio ir  emitir a rela‡Æo de Purchase Orders"
                STR0040,; //"aguardando P.G.I."
                "",;
                "G",;
                132,;
                "",;
                "",;
                STR0042,; //"P.O.s Aguardando Proforma"
                { STR0012, 1,STR0013, 2, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
                "EICTR215",;
                { {|| .T. } , {|| TR_RelMed(110,nPrazoMed) }  }  }

LOCAL aRCampos:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCampos:={ "W3_FLAG","W3_PO_NUM","W2_PO_DT","W3_CC","W3_SI_NUM",;
                   "W3_COD_I","B1_DESC","W3_QTDE","W3_DT_ENTR","W2_DT_PRO",;
                   "W1_PRAZO" ,"W2_COMPRA", "Y1_NOME" }

Private aHeader[0]

IF ! E_GetImp(@cImportador,@cTitulo)
   RETURN .F.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria WorkFile para GetDadDB()                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := E_CriaTrab()
cIndice2:= LEFT(cNomArq,7)+"A"

IndRegua("TRB",cNomArq+TEOrdBagExt(),"W3_INDEX+W3_PO_NUM")
IndRegua("TRB",cIndice2+TEOrdBagExt(),"TRB->W3_COD_I")

SET INDEX TO (cNomArq+TEOrdBagExt()),(cIndice2+TEOrdBagExt())

aHeader[11,1]:=STR0043 //"Prazo"
E_CriaCampos(aRCampos,.T.,2)
aRCampos[3,3]:=aRCampos[7,3]:="D"
aRCampos[5,3]:=aRCampos[6,3]:="E"

aSize(aRCampos,Len(aRCampos)-1) // elimina o nome do comprador

Processa({|lEnd| ProcRegua(SW3->(Easyreccount("SW3"))),;
            nPrazoMed:=TR215Grava(cImportador),.T.},;
            STR0038,STR0026) //"Pesquisa de P.O.s"###"Selecionando registros - aguarde..."

E_SayLeadT(cCadastro+" - "+OemToAnsi(cTitulo),cLeadTime,nPrazoMed,aDados,aRCampos)
TRB->(E_EraseArq(cNomArq,cIndice2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbGoTo(nSavRec)

Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR215Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 10/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR215Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICTR215                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION TR215Grava(nQual)

LOCAL nPrazoMed:=0, nPrazoTot:=0, cAlias:=ALIAS()
LOCAL nLeadTime:=EasyGParam("MV_LT_LICE")

SW3->(DBSETORDER(6))
SW3->(DBSEEK(xFilial()+STR(0,2,0)+STR(0.001,13,3),.T.))
SW3->(DBEVAL({|| IncProc(),;
                 SB1->(DBSEEK(xFilial()+SW3->W3_COD_I)),;
                 SY1->(DBSEEK(xFilial()+SW2->W2_COMPRA)),;
                 nPrazoTot+=(cAlias)->(TR215Atualiza(nLeadTime)) },;
             {|| SW2->(DBSEEK(xFilial()+SW3->W3_PO_NUM)),;
                 (!EMPTY(SW2->W2_DT_PRO) .AND. ( EMPTY(nQual) .OR. ;
                                                 nQual = SW2->W2_IMPORT )) },;
             {||xFilial() == SW3->W3_FILIAL .AND. SW3->W3_SEQ = 0 .AND. SW3->W3_SALDO_Q > 0 }))

SW3->(DBSETORDER(1))

IF (cAlias)->(Easyreccount(cAlias)) > 0
   nPrazoMed:=INT((nPrazoTot/(cAlias)->(Easyreccount(cAlias)) * 100)/100)
ENDIF

RETURN nPrazoMed
*----------------------------------------------------------------------------
FUNCTION TR215Atualiza(nLeadTime)
*----------------------------------------------------------------------------
LOCAL dIncAlt:=IF(! EMPTY(SW2->W2_DT_ALTER),SW2->W2_DT_ALTER,SW2->W2_PO_DT)


TRB->(DBAPPEND())

REPLACE TRB->W3_COD_I   WITH SW3->W3_COD_I,;
        TRB->W3_CC      WITH SW3->W3_CC,;
        TRB->W3_SI_NUM  WITH SW3->W3_SI_NUM,;
        TRB->W3_PO_NUM  WITH SW3->W3_PO_NUM,;
        TRB->W2_PO_DT   WITH dIncAlt,;
        TRB->W3_COD_I   WITH SW3->W3_COD_I,;
        TRB->B1_DESC    WITH SB1->B1_DESC,;
        TRB->W3_QTDE    WITH SW3->W3_QTDE,;
        TRB->W3_DT_ENTR WITH SW3->W3_DT_ENTR,;
        TRB->W2_DT_PRO  WITH SW2->W2_DT_PRO,;
        TRB->W2_COMPRA  WITH SW2->W2_COMPRA,;
        TRB->Y1_NOME    WITH SY1->Y1_NOME,;
        TRB->W1_PRAZO   WITH Dias_Uteis(IF(TRB->W2_DT_PRO<dIncAlt,dIncAlt,TRB->W2_DT_PRO)),;
        TRB->W3_FLAG    WITH IF(TRB->W1_PRAZO>nLeadTime,'','   ')
        
TRB->W3_INDEX := STR(9999-TRB->W1_PRAZO,4,0)

RETURN TRB->W1_PRAZO

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR220 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 17.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Follow-Up de Processos no DECEX                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR220()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR220
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0044) //"Processos no DECEX"

E_SelDecex("2",1)

Return .T.

Function EICTR221
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0045) //"Prazos do DECEX"

E_SelDecex(SAIU_DECEX,1)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_SelDECEX³ Autor ³ MicroSiga/Average     ³ Data ³ 17.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de consulta Aguardando Proforma                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_SelDecex(nQual,nOpcao)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nQual = "1" Avaliacao de Prazos, "2" Follow-up de Processos³±±
±±³          ³ nOpcao= 1 DECEX, 2 Suframa                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION E_SelDecex(cQual,nOpcao)

LOCAL nOldArea:=SELECT(), nPrazoMed:=0, cIndice2
LOCAL oDlg, oGet, dVazia:=AVCTOD(""), cTitulo, cLeadTime
LOCAl aCamposTRB:={}
LOCAL aDados :={}, aRCampos:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCampos:={"W4_ID_GI","W4_PGI_NUM","W5_FORN","A2_NREDUZ","W4_DTEDCEX"}

IF EICLoja()
   AADD(aCampos,{"W5_FORLOJ"})
EndIf

// aRotina declarada apenas para compatibilizar com GetDadDB
PRIVATE aRotina := {  { STR0004           , "AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                      { STR0005           , "C210Impor" , 0 , 2} ,; //"Atual"
                      { STR0006           , "C210Impor" , 0 , 3} } //"Todos"

Private aHeader[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ funcao EasyGParam necessita de arquivo aberto                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLeadTime:=STR(EasyGParam("MV_LT_LICE")-3,2,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F10 para acessar os parametros                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F12,{ || pergunte("EIC010",.T.) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Data inicial                               ³
//³ mv_par02      // Data final                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF !Pergunte("EIC010",.T.)
   E_RESET_AREA
   RETURN .F.
ENDIF

SW4->(DBSETORDER(4))
SYI->(DBSETORDER(4))

IF cQual = SAIU_DECEX
   IF nOpcao = 1
      SW4->(DBSEEK(xFilial()+DTOS(mv_par01),.T.))
      IF SW4->(EOF()) .OR. SW4->W4_DTSDCEX > mv_par02
         SYI->(DBSEEK(xFilial()+DTOS(mv_par01),.T.))
         IF SYI->(EOF()) .OR. SYI->YI_DTSDCEX > mv_par02
            Help(" ",1,"EICSEMREG")
            E_RESET_AREA
            Return .T.
         ENDIF
      ENDIF
   ELSE
      SW4->(DBSEEK(xFilial()+DTOS(dVazia)+DTOS(mv_par01),.T.))
      IF SW4->(EOF()) .OR. SW4->W4_DTEDCEX > mv_par02
         SYI->(DBSEEK(xFilial()+DTOS(dVazia)+DTOS(mv_par01),.T.))
         IF SYI->(EOF()) .OR. SYI->YI_DTEDCEX > mv_par02
            Help(" ",1,"EICSEMREG")
            E_RESET_AREA
            Return .T.
         ENDIF
      ENDIF
   ENDIF
ELSE
   IF nOpcao = 1
      SW4->(DBSEEK(xFilial()+DTOS(dVazia)+DTOS(mv_par01),.T.))
      IF SW4->(EOF()) .OR. SW4->W4_DTEDCEX > mv_par02 .OR. ;
       ! EMPTY(SW4->W4_DTSDCEX)
         SYI->(DBSEEK(xFilial()+DTOS(dVazia)+DTOS(mv_par01),.T.))
         IF SYI->(EOF()) .OR. SYI->YI_DTEDCEX > mv_par02 .OR. ;
            ! SYI->(EMPTY(YI_DTSDCEX))
            Help(" ",1,"EICSEMREG")
            E_RESET_AREA
            Return .T.
         ENDIF
      ENDIF
   ELSE
      SW4->(DBSEEK(xFilial()+DTOS(dVazia)+DTOS(dVazia)+DTOS(mv_par01),.T.))
      IF SW4->(EOF()) .OR. SW4->W4_DT_SUFR > mv_par02 .OR. ;
       ! EMPTY(SW4->W4_DTEDCEX)
         SYI->(DBSEEK(xFilial()+DTOS(dVazia)+DTOS(dVazia)+DTOS(mv_par01),.T.))
         IF SYI->(EOF()) .OR. SYI->YI_DT_SUFR > mv_par02 .OR. ;
            ! SYI->(EMPTY(YI_DTEDCEX))
            Help(" ",1,"EICSEMREG")
            E_RESET_AREA
            Return .T.
         ENDIF
      ENDIF
   ENDIF
ENDIF

IF DTOS(mv_par01) == "19000101" .AND. DTOS(mv_par02) == "29991231"
   cTitulo:="Geral"
ELSE
   cTitulo:="De "+DTOC(mv_par01)+" ate "+DTOC(mv_par02)
ENDIF

IF cQual # SAIU_DECEX
   AADD(aCampos,"W4_PRAZO")
   AADD(aCampos,"W5_PO_NUM")

   aDados :={"TRB",;
             STR0046,; //"Este relatorio ir  exibir a rela‡Æo de processos no"
             STR0047,; //"DECEX."
             "",;
             "P",;
              80,;
             "",;
             "",;
             STR0048,; //"Processos no DECEX."
             { STR0012, 1,STR0013, 2, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
             "EICTR220",;
             { {|| .T. } , {|| TR_RelMed(110,nPrazoMed) }  }  }

ELSE
   AADD(aCampos,"W4_DTSDCEX")
   AADD(aCampos,"W4_PRAZO")
   AADD(aCampos,"W5_PO_NUM")
   AADD(aCampos,"W4_GI_NUM")

   aDados :={"TRB",;
             STR0049,; //"Este relatorio ir  exibir os prazos no DECEX"
             "",;
             "",;
             "P",;
              80,;
             "",;
             "",;
             STR0050,; //"Avaliacao de Prazos do DECEX."
             { STR0012, 1,STR0013, 2, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
             "EICTR221",;
             { {|| .T. } , {|| TR_RelMed(110,nPrazoMed) }  }  }
ENDIF

AADD(aCAMPOS,"W4_DESLIN1")

AADD(aCAMPOS,"W4_RECNO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria WorkFile para GetDadDB()                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := E_CriaTrab()

E_CriaCampos(aRCampos,.T.)

DBSELECTAREA("TRB")
IndRegua("trb",cNomArq+TEOrdBagExt(),"W4_PGI_NUM")

Processa({|lEnd| ProcRegua(SW4->(Easyreccount("SW4"))),;
                 nPrazoMed:=SW4->(TR220Grava(cQual,"GI",nOpcao)),.T.},;
                 STR0051,STR0026) //"Pesquisa de Guias"###"Selecionando registros - aguarde..."

SYI->(DBSEEK(xFilial()+IF(cQual=SAIU_DECEX,IF(nOpcao=1,DTOS(mv_par01),DTOS(dVazia)+DTOS(mv_par01)),IF(nOpcao=1,DTOS(dVazia)+DTOS(mv_par01),DTOS(dVazia)+DTOS(dVazia)+DTOS(mv_par01)) ),.T.))

Processa({|lEnd| ProcRegua(SYI->(Easyreccount("SYI"))),;
                 nPrazoMed+=SYI->(TR220Grava(cQual,"AD",nOpcao)),.T.},;
                 STR0052,STR0026) //"Pesquisa de Aditivos"###"Selecionando registros - aguarde..."
IF TRB->(Easyreccount("TRB")) > 0
   nPrazoMed:=INT((nPrazoMed/TRB->(Easyreccount("TRB")) * 100)/100)
ELSE
   nPrazoMed:=0
ENDIF

E_SayLeadT(cCadastro+" - "+OemToAnsi(cTitulo),cLeadTime,nPrazoMed,aDados,aRCampos)

E_RESET_AREA

Set Key VK_F12 To

Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR220Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 17/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR220Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICTR220                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION TR220Grava(cQual,cFile,nOpcao)

LOCAL dEntDecex, dSaiDecex, cPGI_NUM, cGI_NUM, dSuframa
LOCAL bEntDecex, bSaiDecex, bPGI_NUM, bGI_NUM, bSuframa
LOCAL cPGI_Chave, cPO_NUM, cForn,cForLoj:="", nPrazoTot:=0
LOCAL cPrefixo:=IF(cFile="GI","W4_","YI_")

bSuframa :=FIELDBLOCK(cPrefixo+"DT_SUFR")
bEntDecex:=FIELDBLOCK(cPrefixo+"DTEDCEX")
bSaiDecex:=FIELDBLOCK(cPrefixo+"DTSDCEX")
bPGI_NUM :=FIELDBLOCK(cPrefixo+IF(cFile="GI","PGI_NUM","PAGI_NU"))
bGI_NUM  :=FIELDBLOCK(cPrefixo+IF(cFile="GI","GI_NUM","AGI_NUM"))
bFilial  :=FIELDBLOCK(cPrefixo+"FILIAL")

WHILE ! EOF() .AND. EVAL(bFilial) == xFilial()

      IncProc()

      IF cFile = "GI" .AND. SW4->W4_FLUXO = "4"
         DBSKIP() ; LOOP
      ENDIF

      dSuframa :=EVAL(bSuframa)
      dEntDecex:=EVAL(bEntDecex)
      dSaiDecex:=EVAL(bSaiDecex)
      cPGI_NUM :=EVAL(bPGI_NUM)
      cGI_NUM  :=EVAL(bGI_NUM)

      cPGI_Chave :=IF(cFile="GI",cPGI_NUM," ")

      IF cQual = SAIU_DECEX
         IF nOpcao = 1
            IF dSaiDecex > mv_par02
               RETURN nPrazoTot
            ENDIF
            nPrazo:=Dias_Uteis(dEntDecex,dSaiDecex)
         ELSE
            IF dEntDecex > mv_par02
               RETURN nPrazoTot
            ENDIF
            nPrazo:=Dias_Uteis(dSuframa,dEntDecex)
            IF cFile = "AD"
               SW4->(DBSETORDER(2))
               IF ! SW4->(DBSEEK(xFilial()+SYI->YI_GI_NUM))
                  SW4->(DBSETORDER(4))
                  DBSKIP() ; LOOP
               ENDIF
               SW4->(DBSETORDER(4))
            ENDIF
            IF SW4->W4_SUFRAMA <> "S"
               DBSKIP() ; LOOP
            ENDIF
         ENDIF
      ELSE
         IF nOpcao = 1
            IF dEntDecex > mv_par02 .OR. ! EMPTY(dSaiDecex)
               RETURN nPrazoTot
            ENDIF
            nPrazo:=Dias_Uteis(dEntDecex,dDataBase)
         ELSE
            IF dSuframa > mv_par02 .OR. ! EMPTY(dEntDecex)
               RETURN nPrazoTot
            ENDIF
            nPrazo:=Dias_Uteis(dSuframa,dDataBase)
            IF cFile = "AD"
               SW4->(DBSETORDER(2))
               IF ! SW4->(DBSEEK(xFilial()+SYI->YI_GI_NUM))
                  SW4->(DBSETORDER(4))
                  DBSKIP() ; LOOP
               ENDIF
               cPGI_Chave:=SW4->W4_PGI_NUM
               SW4->(DBSETORDER(4))
            ENDIF
            IF SW4->W4_SUFRAMA <> "S"
               DBSKIP() ; LOOP
            ENDIF
         ENDIF
      ENDIF

      IF cFile = "AD" .AND. EMPTY(cPGI_Chave)
         SW4->(DBSETORDER(2))
         SW4->(DBSEEK(xFilial()+SYI->YI_GI_NUM))
         SW4->(DBSETORDER(4))
         cPGI_Chave:=SW4->W4_PGI_NUM
      ENDIF

      IF SW5->(DBSEEK(xFilial()+cPGI_Chave))
         cPO_Num:=SW5->W5_PO_NUM ; cForn := SW5->W5_FORN ; cForLoj := SW5->W5_FORLOJ
      ELSE
         SWE->(DBSEEK(xFilial()+cPGI_Chave))
         cPO_Num:=SWE->WE_PO_NUM ; cForn := SWE->WE_FORN ; cForLoj := SWE->WE_FORLOJ
      ENDIF

      SA2->(DBSEEK(xFilial()+cForn+cForLoj))

      TRB->(DBAPPEND())
      TRB->W4_ID_GI   := "P"+IF(cFile="GI","GI ","AGI")
      TRB->W4_PGI_NUM := cPGI_NUM
      TRB->W4_DTEDCEX := IF(nOpcao=1,dEntDecex,dSuframa)
      TRB->W4_PRAZO   := nPrazo
      TRB->W5_PO_NUM  := cPO_Num
      TRB->W4_DESLIN1 := VerTexo()
*     TRB->W4_RECNO   := SW4->( RECNO() )
      TRB->W5_FORN    := cForn
      TRB->A2_NREDUZ  := SA2->A2_NREDUZ
      IF cQual = SAIU_DECEX
         TRB->W4_DTSDCEX := IF(nOpcao=1,dSaiDecex,dEntDecex)
         TRB->W4_GI_NUM  := cGI_NUM
      ENDIF
      If EICLoja()
         TRB->W5_FORLOJ := cForLoj
      EndIf
      nPrazoTot+=TRB->W4_PRAZO
      DBSKIP()
ENDDO
RETURN nPrazoTot

*---------------------------*
FUNCTION VerTexo()
*---------------------------*
LOCAL Texto:=MSMM(SW4->W4_DESC_GE,48,1)

IF MLCOUNT(SW4->W4_DESC_GE) > 1
   Texto:= LEFT(Texto,37)+STR0053 //"...Continua"
ENDIF
RETURN Texto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICTR225 ³ Autor ³ AVERAGE/MJB/RSD       ³ Data ³ 11.03.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validade das L.I.s                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR225()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              
// EOS - OS 569/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR227
// um 2º parametro como .T. identificando que é schedulado 
Function EICTR225S
EICTR227("2", .T., .F. )
RETURN 

Function EICTR225R3
PRIVATE cCadastro := OemtoAnsi(STR0054) //"Validade das L.I.s"
Return EICTR227("2",,.F.)
Function EICTR225
PRIVATE cCadastro := OemtoAnsi(STR0054) //"Validade das L.I.s"
Return EICTR227("2",,.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICTR226 ³ Autor ³ AVERAGE/MJB/RSD       ³ Data ³ 11.03.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ L.I.s em Aprovacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR226()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                 
// EOS - OS 569/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR227
// um 2º parametro como .T. identificando que é schedulado  
******************
Function EICTR226S
******************
EICTR227("1", ,.T. )
RETURN NIL

******************
Function EICTR226SR3
******************
EICTR227("1", .T. )
RETURN NIL

*****************
Function EICTR226
*****************
PRIVATE cCadastro := OemtoAnsi(STR0055) //"L.I.s em Aprova‡ao"
Return EICTR227("1",,.T.)
                  
*****************
Function EICTR226R3
*****************
PRIVATE cCadastro := OemtoAnsi(STR0055) //"L.I.s em Aprova‡ao"
Return EICTR227("1")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICTR227 ³ Autor ³ AVERAGE/MJB/RSD       ³ Data ³ 11.03.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validade das L.I.s                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR227()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Us o      ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR227(nTipo, lSXD, p_R4)
#COMMAND E_RESET_AREA => SW4->(DBSETORDER(1))  ;
                       ; IF(SELECT("TRB")<>0,TRB->(E_EraseArq(cNomArq)),) ;
                       ; IF(SELECT("TRB")<>0,TRB->(E_EraseArq(cNomArq+TEOrdBagExt())),) ;
                       ; DBSELECTAREA(nOldArea)

LOCAL nOldArea:=SELECT() 

// incluir variaveis para o relatorio padrao
LOCAL aDados :={"TRB",;
                "",;
                "",;
                "",;
                "M",;
                132,;
                "",;
                "",;
                STR0056,; //"LI's em Aprovacao"
                { STR0012, 1,STR0013, 1, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
                "EICTR225",;
                { {|| .T. } , {|| .T. }  }  }


LOCAL TB_Funcoes := { {"-4" , STR0057 , "F5" , STR0057} } //"Relatorio"###"Relatorio"
LOCAL Ind, nLinha, nPrazoMed, nMTotal, nParam:=2

PRIVATE TB2_Campos:={ "WP_VENCTO" , "WP_REGIST" , "WP_SUBST"  , "WP_NR_MAQ" ,;//igor chiba 31/08/2010
                      "WP_MICRO"  , "WP_PGI_NUM", "WP_SEQ_LI" , "WP_PROT"   ,;
                      "WP_TRANSM" }
                                                 

PRIVATE TB1_Campos:={}//igor chiba 31/08/2010

PRIVATE aSemSX3 :={ { "WKPRAZO","C",5,0 } }//igor chiba 31/08/2010
PRIVATE aRCampos:={} //igor chiba 31/08/2010

Private cNome1
PRIVATE 	R_Dados:={}, R_Campos:={}, R_Funcoes:={{||.T.},{||.T.}}, ;
        aTipo := {STR0058,       ; //"Aguardando Transferencia de LI"
                  STR0059,       ; //"Aguardando Registro           "
                  STR0060 }, oDlgOpc //"Aguardando Anuencia           "

// aRotina declarada apenas para compatibilizar com GetDadDB
PRIVATE aRotina := {  { STR0004, "AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                      { STR0005, "C210Impor" , 0 , 2} ,; //"Atual"
                      { STR0006, "C210Impor" , 0 , 3} } //"Todos"

PRIVATE cMarca := GetMark(), lInverte := .F.
Private aHeader[0], aCampos:={}, nOpcao:=1, Valor[0], nOpcA:=0, aReturn := aDados[10]

PRIVATE lEMail:=!lSXD = Nil  // EOS - OS 569/02
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
              


ASIZE(aCampos,0)     

WHILE .T.
   nLinha := 5 ; nPrazoMed := '0' ; nMTotal:= 0
   ASIZE(aRCampos,0)
   ASIZE(aHeader,0)
   aDados[7]:="" 
   // EOS OS 569/02 Se schedulado, inicializa variaveis atraves do pergunte, e atraves do
   // setprint carrega as variaveis mv_par??   
   IF nTipo = Validade_LI 
      IF !Pergunte("EIC010",IIF(lEmail,.F.,.T.))  
         E_RESET_AREA
         RETURN .F.
      ENDIF
      dInicial:=mv_par01
      dFinal  :=mv_par02
      cTitulo :=STR0061+DTOC(dInicial)+STR0062+DTOC(dFinal) //"De "###" ate "

      aCampos:=aClone(TB2_Campos)
      cNomArq:=E_CriaTrab()
      IndRegua("TRB",cNomArq+TEOrdBagExt(),"DTOS(WP_VENCTO)")
      
      IF lEmail
         aDados[11] := SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
         dInicial:=mv_par01
         dFinal  :=mv_par02
      ENDIF
   ELSE        // 1.
      IF !Pergunte("EIC226",IIF(lEmail,.F.,.T.))
         EXIT
      ENDIF
      nOpcao := mv_par01

      ASIZE(TB1_Campos,0)
      AADD(TB1_Campos, "WP_NR_MAQ")
      AADD(TB1_Campos, "WP_MICRO")
      AADD(TB1_Campos, "WP_PGI_NUM")
      AADD(TB1_Campos, "WP_SEQ_LI")
      cTitulo  :=aTipo[nOpcao]
      aDados[7]:=aTipo[nOpcao]
      DO CASE
         CASE nOpcao == Ag_Registro
              AADD( TB1_Campos, "WP_PROT")
              AADD( TB1_Campos, "WP_TRANSM")
         CASE nOpcao == Ag_Anuencia
              AADD( TB1_Campos, "WP_REGIST")
      ENDCASE
      If(EasyEntryPoint("EICTR227"),Execblock("EICTR227",.F.,.F.,"TR227CPOTRB"),)  //igor chiba 31/08/10

      aCampos:=ACLONE(TB1_Campos)
      cNomArq:=E_CriaTrab(,aSemSX3)
      AADD(aHeader,{STR0088,"WKPRAZO","@!",5,0," ","   ","C",," "}) //"Confeccionar Até"
      IF lEmail
         aDados[11] := SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
         nOpcao := mv_par01
      ENDIF
   ENDIF 
   
   //IF lR4
       //AAF - 20/06/2006 - Relatório Personalizavel - Release 4
       //ReportDef cria os objetos.
       //oReport := ReportDef(nTipo)
   //ENDIF   

   ASIZE(R_Dados,0)
   R_Dados:={TITULO, 80, .F., NIL}
   IF nTipo = Validade_LI
      IF DTOS(dInicial) == "19000101" .AND. DTOS(dFinal) == "29991231"
         R_Dados[4]:=STR0063 //"Geral"
      ELSE
         R_Dados[4]:=STR0061+DTOC(dInicial)+STR0062+DTOC(dFinal) //"De "###" ate "
      ENDIF
   ENDIF

   ASIZE(R_Campos,0)
   TR225R_Campos(CAMPOS)     

   TRB->(avzap())
   IF lEmail  // EOS - OS 569/02 
      TR225GravaWork(@nMTotal,nTipo,nOpcao)   
   ELSE
      Processa({|lEnd| TR225GravaWork(@nMTotal,nTipo,nOpcao) } )
   ENDIF

   IF nTipo = Aprovacao_LI
      IF TRB->(Easyreccount("TRB")) # 0
         nPrazoMed := ALLTRIM(STR( nMTotal / TRB->(Easyreccount("TRB")) ,5,0))
      ENDIF
   ENDIF

   IF TRB->(Easyreccount("TRB")) > 0
      E_CriaCampos(aRCampos,.T.)
     
      If(EasyEntryPoint("EICTR227"),Execblock("EICTR227",.F.,.F.,"TR227RCAMPOS"),)  //igor chiba 31/08/10

      IF !lEmail // EOS - OS 569/02 Se schedulado, desvia das apresentacoes em tela 
         E_SayLeadT(cCadastro+" - "+OemToAnsi(cTitulo),,nPrazoMed,aDados,aRCampos,NIL,NIL,NIL, If(lR4,{||(oReport := ReportDef(nTipo),oReport:PrintDialog())} ,NIL))
      ELSE
         E_Report(aDados,aRCampos,.T.,.F.)
      ENDIF		         
      IF nOpca == 0
         E_RESET_AREA
         EXIT
      ENDIF
   ELSE
      IF !lEmail // EOS - OS 569/02 Se schedulado, desvia das apresentacoes em tela 
         MsgInfo(STR0064,STR0065) //"Não existem registros"###"Informação"
      ENDIF
   ENDIF
   E_RESET_AREA
ENDDO
RETURN

*--------------------------------------------*
FUNCTION TR225GravaWork(nMTotal,nTipo,nOpcao)
*--------------------------------------------*
LOCAL bWhile := {|| SWP->WP_FILIAL==xFilial("SWP") .AND.;
                   IF(nTipo=Validade_LI,(SWP->WP_VENCTO<=dFinal),.T.) }                   
                   
IF !lEmail  // EOS - OS 569/02 Se schedulado, desvia das apresentacoes em tela 
   ProcRegua(SWP->(Easyreccount("SWP")))
ENDIF

IF nTipo = Validade_LI
   SWP->(DBSETORDER(2))
   SWP->(DBSEEK(xFilial()+DTOS(dInicial),.T.))
ELSE
   SWP->(DBSEEK(xFilial("SWP")))
ENDIF

//EOS - OS 569/02 Se schedulado, desvia das apresentacoes em tela 
 
DO WHILE SWP->(!EOF()) .AND. Eval(bWhile)

   IF(!lEmail,IncProc(STR0066),)

   IF nTipo # Validade_LI
      IF nOpcao=1 .AND. (!EMPTY(SWP->WP_REGIST) .OR. !EMPTY(SWP->WP_ENV_ORI))         
         SWP->(DBSKIP());LOOP
      ELSEIF nOpcao=2 .AND. !EMPTY(SWP->WP_REGIST)
         SWP->(DBSKIP())
         LOOP
      ELSEIF nOpcao=3 
      
         IF EMPTY(SWP->WP_ENV_ORI)
             SWP->(DBSKIP())
             LOOP
         ENDIF
             
         IF !EMPTY(SWP->WP_REGIST)
            SWP->(DBSKIP())
            LOOP
         ENDIF   
      ENDIF
      
   ENDIF
      
   nMtotal+=TR225CalculaPrazo(nOpcao)
   
   TRB->(DBAPPEND())
   TR225WKGrava(nTipo,nOpcao)
   
   If(EasyEntryPoint("EICTR225"),Execblock("EICTR225",.F.,.F.,"TR225GRAVA"),)  //igor chiba 31/08/10
   
   SWP->(DBSKIP())
ENDDO

RETURN .T.

*----------------------------------*
FUNCTION TR225WKGrava(nTipo,nOpcao)
*----------------------------------*
DO CASE
   CASE nTipo = Validade_LI
        TRB->WP_VENCTO := SWP->WP_VENCTO
        TRB->WP_REGIST := SWP->WP_REGIST
        TRB->WP_SUBST  := SWP->WP_SUBST
        TRB->WP_NR_MAQ := SWP->WP_NR_MAQ
        TRB->WP_MICRO  := SWP->WP_MICRO
        TRB->WP_PGI_NUM:= SWP->WP_PGI_NUM
        TRB->WP_SEQ_LI := SWP->WP_SEQ_LI
        TRB->WP_PROT   := SWP->WP_PROT
        TRB->WP_TRANSM := SWP->WP_TRANSM
   CASE nTipo = Aprovacao_LI
        TRB->WP_NR_MAQ :=SWP->WP_NR_MAQ
        TRB->WP_MICRO  :=SWP->WP_MICRO
        TRB->WP_PGI_NUM:=SWP->WP_PGI_NUM
        TRB->WP_SEQ_LI :=SWP->WP_SEQ_LI

        IF nOpcao == Ag_Registro
           TRB->WP_PROT  :=SWP->WP_PROT
           TRB->WP_TRANSM:=SWP->WP_TRANSM
        ENDIF

        IF nOpcao == Ag_Anuencia
           TRB->WP_REGIST:=SWP->WP_REGIST
        ENDIF
ENDCASE                
If !nTipo = Validade_LI
   TRB->WKPRAZO := TR225Prazo(nOpcao)
Endif



RETURN NIL

*----------------------------------------------------------------------------
FUNCTION TR225CalculaPrazo(pTp)
*----------------------------------------------------------------------------
IF pTp = 1
   IF SW4->(DBSEEK(xFilial()+SWP->WP_PGI_NUM))
      IF ! EMPTY(SW4->W4_PGI_DT)
         RETURN E_VerPrazo( Dias_Uteis( SW4->W4_PGI_DT,dDataBase ))
      ENDIF
   ENDIF
ELSE
   IF !EMPTY(SWP->WP_TRANSM)
      RETURN E_VerPrazo( Dias_Uteis( SWP->WP_TRANSM,dDataBase ))
   ENDIF
ENDIF
RETURN 0

*----------------------------------------------------------------------------
FUNCTION TR225Prazo(pTp)
*----------------------------------------------------------------------------
LOCAL rData:=0
IF pTp = Ag_Transferencia
   IF SW4->(DBSEEK(xFilial()+TRB->WP_PGI_NUM))
      IF ! EMPTY(SW4->W4_PGI_DT)
         rData := E_VerPrazo(Dias_Uteis(SW4->W4_PGI_DT,dDataBase))
      ENDIF
   ENDIF
ELSE
   IF !EMPTY(SWP->WP_TRANSM)
      rData := E_VerPrazo(Dias_Uteis(SWP->WP_TRANSM,dDataBase))
   ENDIF
ENDIF
RETURN STR(rData,5,0)

*----------------------------------------------------------------------------
FUNCTION TR225R_Campos(pCampo)
*----------------------------------------------------------------------------
Local Ind
FOR ind=1 TO LEN(pCampo)
    AADD(R_Campos,{pCampo[ind],pCampo[ind],"C"})
NEXT
RETURN NIL

*----------------------------------------------------------------------------
FUNCTION TR225VerifPGI( )
*----------------------------------------------------------------------------
RETURN 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR230 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 17.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Follow-Up de Processos a serem enviados DECEX     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR230()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR230
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#COMMAND E_RESET_AREA => SW4->(DBSETORDER(1)) ; DBSELECTAREA(nOldArea) ;
                       ; TRB->(E_EraseArq(cNomArq))

PRIVATE cCadastro := OemtoAnsi(STR0067) //"Processos p/ envio ao DECEX"

E_SemDecex(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³E_SemDecex³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 17.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de consulta processos a serem enviados ao DECEX   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ E_SemDecex(nOpcao)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcao= 1 DECEX, 2 Suframa                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION E_SemDecex(nOpcao)

LOCAL nPrazoMed:=0, cIndice2, cTitulo, cLeadTime

LOCAL nOldArea:=SELECT(), oDlg, oGet, cImportador:=SPACE(LEN(SW2->W2_IMPORT))

LOCAl aCamposTRB:={}
                                                                 
LOCAL aDados :={"TRB",;
                STR0068,; //"Este relatorio ir  emitir a rela‡Æo de processos a "
                STR0069,; //"serem enviados ao DECEX."
                "",;
                "P",;
                 80,;
                "",;
                "",;
                STR0070,; //"Aguardando envio ao DECEX."
                { STR0012, 1,STR0013, 2, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
                "EICTR230",;
                { {|| .T. } , {|| TR_RelMed(110,nPrazoMed) }  }  }

LOCAL aRCampos:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCampos:={"W4_FLAG","W4_ID_GI","W4_PGI_NUM","W4_PGI_DT","W5_PO_NUM",;
                  "W5_FORN","A2_NREDUZ","W4_PRAZO"} 
                  
If EICLoja()
   AADD(aCampos,{"W5_FORLOJ"})
EndIf

// aRotina declarada apenas para compatibilizar com GetDadDB

PRIVATE aRotina := { { STR0004       , "AxPesqui"  , 0 , 1} ,; //"Pesquisar"
                     { STR0005       , "C210Impor" , 0 , 2} ,; //"Atual"
                     { STR0006       , "C210Impor" , 0 , 3} } //"Todos"

Private aHeader[0]


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ funcao EasyGParam necessita de arquivo aberto                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLeadTime:=STR(EasyGParam("MV_LT_LICE")-3,2,0)

IF ! E_GetImp(@cImportador,@cTitulo)
   RETURN .F.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria WorkFile para GetDadDB()                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := E_CriaTrab()
INDEX ON W4_PGI_NUM TO (cNomArq)

SW4->(DBSEEK(xFilial()))

Processa({|lEnd| ProcRegua(SW4->(Easyreccount("SW4"))),;
                 nPrazoMed:=SW4->(TR230Grava("GI",nOpcao,cImportador)),.T.},;
                 STR0051,STR0026) //"Pesquisa de Guias"###"Selecionando registros - aguarde..."

SYI->(DBSEEK(xFilial()))

Processa({|lEnd| ProcRegua(SYI->(Easyreccount("SYI"))),;
                 nPrazoMed+=SYI->(TR230Grava("AD",nOpcao,cImportador)),.T.},;
                 STR0052,STR0026) //"Pesquisa de Aditivos"###"Selecionando registros - aguarde..."
IF TRB->(Easyreccount("TRB")) > 0
   nPrazoMed:=INT((nPrazoMed/TRB->(Easyreccount("TRB")) * 100)/100)
ELSE
   nPrazoMed:=0
ENDIF

E_CriaCampos(aRCampos,.T.,2)

E_SayLeadT(cCadastro+" - "+OemToAnsi(cTitulo),cLeadTime,nPrazoMed,aDados,aRCampos)

E_RESET_AREA
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR230Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 17/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR230Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICTR230                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION TR230Grava(cFile,nOpcao,cImportador)

LOCAL cPrefixo:=IF(cFile="GI","W4_","YI_"), nPrazoTot:=0
LOCAL bEntrada, bPGI_Num, bEmitida, bdPGI
LOCAL dEntrada, cPGI_NUM, cEmitida, dPGI, cPO_Num, cForn, cForLoj:= ""

bEntrada :=FIELDBLOCK(cPrefixo+IF(nOpcao=1,"DTEDCEX","DT_SUFR"))
bPGI_Num :=FIELDBLOCK(cPrefixo+IF(cFile="GI","PGI_NUM","PAGI_NU"))
bEmitida :=FIELDBLOCK(cPrefixo+"EMITIDA")
bdPGI    :=FIELDBLOCK(cPrefixo+IF(cFile="GI","PGI_DT","PAGI_DT"))
bFilial  :=FIELDBLOCK(cPrefixo+"FILIAL")

WHILE ! EOF() .AND. EVAL(bFilial) == xFilial()

         IncProc()

      IF ! EMPTY(cImportador)
         IF SW4->W4_IMPORT # cImportador
            DBSKIP() ; LOOP
         ENDIF
      ENDIF

      IF cFile = "AD"
         SW4->(DBSETORDER(2))
         IF ! SW4->(DBSEEK(xFilial()+SYI->YI_GI_NUM))
            SW4->(DBSETORDER(1))
            DBSKIP() ; LOOP
         ENDIF
         SW4->(DBSETORDER(1))
      ENDIF

      IF nOpcao = 1 .AND. SW4->W4_SUFRAMA = "S"
         DBSKIP() ; LOOP
      ELSEIF nOpcao = 2 .AND. SW4->W4_SUFRAMA <> "S"
         DBSKIP() ; LOOP
      ENDIF

      dEntrada:=EVAL(bEntrada)
      cEmitida:=EVAL(bEmitida)
      dPGI    :=EVAL(bdPGI)
      cPGI_NUM:=EVAL(bPGI_Num)

      IF EMPTY(dEntrada) .AND. cEmitida = "S"
         IF SW5->(DBSEEK(xFilial()+SW4->W4_PGI_NUM))
            cPO_Num:=SW5->W5_PO_NUM ; cForn := SW5->W5_FORN ; cForLoj := SW5->W5_FORLOJ
         ELSE
            SWE->(DBSEEK(xFilial()+SW4->W4_PGI_NUM))
            cPO_Num:=SWE->WE_PO_NUM ; cForn := SWE->WE_FORN ; cForLoj := SWE->WE_FORLOJ
         ENDIF

         SA2->(DBSEEK(xFilial()+cForn+cForLoj))

         TRB->(DBAPPEND())
         TRB->W4_ID_GI   := "P"+IF(cFile="GI","GI ","AGI")
         TRB->W4_PGI_NUM := cPGI_NUM
         TRB->W4_PGI_DT  := dPGI
         TRB->W4_PRAZO   := Dias_Uteis(dPGI,dDataBase)
         TRB->W5_PO_NUM  := cPO_Num
         TRB->W5_FORN    := cForn
         TRB->A2_NREDUZ  := SA2->A2_NREDUZ
         TRB->W4_FLAG    := IF(TRB->W4_PRAZO>2,'','   ')
         nPrazoTot+=TRB->W4_PRAZO
         If EICLoja()
            TRB->W5_FORLOJ:= cForLoj
         EndIf
      ENDIF
      DBSKIP()
ENDDO
RETURN nPrazoTot

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICC240  ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 26.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validade das G.I.s                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICC240()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Us o      ³ SIGAEIC                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracao ³ Cristiano A. Ferreira 24/11/1999 13:30 - Protheus          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICC240
#COMMAND E_RESET_AREA => SYI->(DBSETORDER(1)) ; SW4->(DBSETORDER(1)) ;
                       ; DBSELECTAREA(nOldArea)
      
LOCAL nOldArea:=SELECT(), WorkFile, WorkIndi

LOCAL T_DBF:= { {"WKPGI_NUM" , "C", AVSX3("W7_PGI_NUM",AV_TAMANHO),0} ,;
                {"WKPO_NUM"  , "C", AVSX3("W7_PO_NUM",AV_TAMANHO),0} ,;
                {"WKGI_NUM"  , "C", 13,0} ,;
                {"WKGI_DT"   , "D",  8,0} ,;
                {"WKPRORR"   , "C",  1,0} ,;
                {"WKAPGI_NUM", "C", AVSX3("W7_PGI_NUM",AV_TAMANHO),0} ,;
                {"WKAGI_NUM" , "C", 13,0} ,;
                {"WKAGI_DT"  , "D",  8,0} ,;
                {"WKVALI_ATU", "D",  8,0} ,;
                {"WKNBM"     , "C", 40,0} ,;
                {"OR_FILIAL" , "C",  2,0} ,;
                {"WKFORN"    , "C", 22,0} }

Local _PictPGI := ALLTRIM(X3Picture("W4_PGI_NUM")) 
Local _PictGI := ALLTRIM(X3Picture("W4_GI_NUM"))
Local _PictPAGI := ALLTRIM(X3Picture("W4_PGI_NUM"))
Local cPictPo := ALLTRIM(X3Picture("W2_PO_NUM"))

LOCAL TB_Campos:=;
      { {"WKVALI_ATU","", STR0071                } ,; //"Validade"
        {"WKGI_NUM"  ,"", OemToAnsi(STR0072)    ,_PictGI    } ,; //"N§ G.I."
        {"WKGI_DT"   ,"", STR0073            } ,; //"Data da G.I."
        {"WKPGI_NUM" ,"", OemToAnsi(STR0074)  ,_PictPGI   } ,; //"N§ P.G.I."
        {"WKPO_NUM"  ,"", OemToAnsi(STR0075)    ,cPictPo    } ,; //"N§ P.O."
        {"WKFORN"    ,"", STR0076              } ,; //"Fornecedor"
        {"WKPRORR"   ,"", STR0077                } ,; //"Prorrog."
        {"WKAGI_NUM" ,"", OemToAnsi(STR0078),_PictGI    } ,; //"N§ do A.G.I."
        {"WKAGI_DT"  ,"", STR0079             } ,; //"Data A.G.I."
        {"WKAPGI_NUM","", OemToAnsi(STR0080),_PictPAGI} } //"N§ do P.A.G.I."

LOCAL cTitulo, oDlg, oGet, nOpcA:=0

PRIVATE cMarca := GetMark(), lInverte := .F.
Private _PictPo := cPictPo

PRIVATE cCadastro := OemtoAnsi(STR0081) //"Validade das Guias de Importa‡Æo"

Private aHeader[0]

SetKey( VK_F12,{ || pergunte("EIC010",.T.) } )

// Variaveis utilizadas para parametros                         ³
// mv_par01       // Data inicial                               ³
// mv_par02      // Data final                                  ³

IF ! Pergunte("EIC010",.T.)
   RETURN .F.
ENDIF

SYI->(DBSETORDER(5))
SW4->(DBSETORDER(3))

SYI->(DBSEEK(xFilial()+DTOS(mv_par01),.T.))
SW4->(DBSEEK(xFilial()+DTOS(mv_par01),.T.))

IF SW4->(EOF()) .OR. SW4->W4_DT_VEN > mv_par02
   IF SYI->(EOF()) .OR. SYI->YI_AGI_VEN > mv_par02
      Help(" ",1,"EICSEMREG")
      E_RESET_AREA
      Return .T.
   ENDIF
ENDIF

cTitulo:=STR0061+DTOC(mv_par01)+STR0082+DTOC(mv_par02) //"De "###" at‚ "

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKGI_NUM")

WorkIndi:=LEFT(WorkFile,7)+"A"
IndRegua("Work",WorkIndi+TEOrdBagExt(),"DTOS(WKVALI_ATU)+WKGI_NUM")


SET INDEX TO (WorkFile),(WorkIndi)

   MsAguarde({|lEnd| C240Grava({|msg| MsProcTxt(OemToAnsi(msg))}) },;
              STR0083) //"Pesquisando informa‡äes..."

   oMainWnd:ReadClientCoords()

   DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+OemToAnsi(cTitulo);
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
      OF oMainWnd PIXEL  

   DEFINE SBUTTON FROM 18,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (Help(" ",1,"EICEMDESEN")) ENABLE OF oDlg

   oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
   Set Key VK_F12 To

If nOpcA==2
// RELATORIO
Endif
Work->(E_EraseArq(WorkFile,WorkIndi))
E_RESET_AREA
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C240Grava ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 17/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C240Grava()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICC240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION C240Grava(bMsg)

LOCAL PForn
LOCAL PLoja := ""

DBSELECTAREA("SW4")

WHILE ! EOF() .AND. W4_DT_VEN <= mv_par02 .AND. xFilial("SW4") == W4_FILIAL


   Eval(bMsg,STR0084+W4_PGI_NUM) //"Processando P.G.I. N§ "

   IF W4_FLUXO = '7' .OR. W4_FLUXO = "4"
      DBSKIP() ; LOOP
   ENDIF

   IF SW5->(TR240Saldo(@PForn,bMsg,@PLoja))
      Work->(DBAPPEND())
      Work->WKPGI_NUM := W4_PGI_NUM
      Work->WKGI_NUM  := W4_GI_NUM
      Work->WKGI_DT   := W4_DT
      Work->WKPRORR   := W4_PRORR
      Work->WKVALI_ATU:= W4_DT_VEN
      Work->WKFORN    := PForn+" "+(SA2->(DBSEEK(xFilial()+PForn+PLoja)),SA2->A2_NREDUZ)
      Work->WKPO_NUM  := (SW5->(DBSEEK(xFilial()+Work->WKPGI_NUM)),SW5->W5_PO_NUM)
   ENDIF
   DBSKIP()
ENDDO

SW4->(DBSETORDER(2))

DBSELECTAREA("SYI")

WHILE ! EOF() .AND. YI_AGI_VEN <= mv_par02  .AND. xFilial("SYI") == YI_FILIAL

   Eval(bMsg,STR0085+SW4->W4_PGI_NUM) //"Processando P.A.G.I. N§ "

   IF ! SW4->(DBSEEK(xFILIAL()+SYI->YI_GI_NUM))
      MsgInfo(STR0086 + YI_GI_NUM,STR0065) //"ARQUIVO GI DESBALANCEADO GI-> "###"Informação"
      DBSKIP() ; LOOP
   ENDIF

   IF SW5->(TR240Saldo(@PForn,bMsg,@PLoja))
      IF ! Work->(DBSEEK(SYI->YI_GI_NUM))
         Work->(DBAPPEND())
         Work->WKPGI_NUM:= SW4->W4_PGI_NUM
         Work->WKGI_NUM := SW4->W4_GI_NUM
         Work->WKGI_DT  := SW4->W4_DT
         Work->WKPRORR  := SW4->W4_PRORR
         Work->WKFORN   := PForn+" "+(SA2->(DBSEEK(xFilial()+PForn+PLoja)),SA2->A2_NREDUZ)
         Work->WKPO_NUM := (SW5->(DBSEEK(xFilial()+Work->WKPGI_NUM)),SW5->W5_PO_NUM)
      ENDIF

      Work->WKAPGI_NUM:= YI_PAGI_NUM
      Work->WKAGI_NUM := YI_AGI_NUM
      Work->WKAGI_DT  := YI_AGI_DT
      Work->WKVALI_ATU:= YI_AGI_VEN
   ENDIF
   DBSKIP()
ENDDO

DBSELECTAREA("Work")
DBSETORDER(2)
DBGOTOP()
Return .T.
*----------------------------------------------------------------------------
STATIC FUNCTION  TR240Saldo(PForn,bMsg,PLoja)
*----------------------------------------------------------------------------
SW5->(DBSEEK(xFILIAL()+SW4->W4_PGI_NUM))
WHILE ! EOF() .AND. W5_PGI_NUM = SW4->W4_PGI_NUM .AND.;
                    SW5->W5_FILIAL == xFilial("SW5")

   Eval(bMsg,STR0084+SW4->W4_PGI_NUM+" Item "+W5_COD_I) //"Processando P.G.I. N§ "

   IF W5_SEQ = 0 .AND. W5_SALDO_Q > 0
      PForn := W5_FORN 
      If EICLoja()
         PLoja := W5_FORLOJ
      EndIF
      RETURN .T.
   ENDIF
   DBSKIP()
ENDDO
IF SW4->W4_FLUXO = '2'
   SWE->(DBSEEK(xFILIAL()+SW4->W4_PGI_NUM))
   WHILE ! SWE->(EOF()) .AND. SWE->WE_PGI_NUM = SW4->W4_PGI_NUM .AND.;
                    SWE->WE_FILIAL == xFilial("SWE")

       Eval(bMsg,STR0084+W4_PGI_NUM+STR0087+SWE->WE_COD_I) //"Processando P.G.I. N§ "###" Item "

       IF SWE->WE_SEQ = 0 .AND. SWE->WE_SALDO_Q > 0
          PForn := SWE->WE_FORN
       If EICLoja()
         PLoja := SWE->WE_FORLOJ
       EndIF
          RETURN .T.
       ENDIF
       SWE->(DBSKIP())
   ENDDO
ENDIF     

RETURN .F.

***************************
Static Function ReportDef(nTipo)
***************************

   IF nTipo = FollowUp_Neg
      cNome1:= "Itens"
      cNome2:= "Lead Time"
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWO", "SW1", "SY1"}
   
      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem := {}

      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICTR200",STR0008,"EIC200",{|oReport| ReportPrint(oReport, nTipo)},STR0056+" "+STR0009)
      
      //ER - 20/10/2006 - Inicia o relatório como paisagem. 
      oReport:oPage:lLandScape := .T. 
      oReport:oPage:lPortRait := .F. 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome1,aTabelas,aOrdem)                  

 
      //Define o objeto com a seção do relatório
      oSecao2 := TRSection():New(oReport,cNome2,{},aOrdem)


      //Definição das colunas de impressão da seção 2
//      TRCell():New(oSecao2,"LEADTIME",{},"LeadTime: ","@!"  ,10 ,/*lPixel*/,{||STR(EasyGParam("MV_LT_PROF"),2,0)})
      TRCell():New(oSecao2,"LEAD",,"LeadTime: ","@E 99,999",10,/*lPixel*/,{||EasyGParam("MV_LT_COMP")})
      oReport:Section(cNome2):Cell("LEAD"):SetCellBreak()
      oReport:bOnPageBreak :={||oReport:Section(cNome2):PrintLine()}       
      
   
      //Definição das colunas de impressão da seção 1   
      TRCell():New(oSecao1,"W0__CC"       ,"TRB"  ,/*_LIT_R_CC*/   ,/*_PictSI*/            ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"W0__NUM"      ,"TRB"  ,STR0014   ,/*Picture*/                  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W0__DT"       ,"TRB"  ,STR0015   ,/*Picture*/                  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"W1_POSICAO"   ,"TRB"  ,STR0016   ,/*Picture*/                  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W1_COD_I"     ,"TRB"  ,STR0017   ,/*_PictItem*/                ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W1_SALDO_Q"   ,"TRB"  ,STR0018   ,"@E 999,999,999.999"         ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"B1_DESC"      ,"TRB"  ,STR0019   ,/*Picture*/                  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W1_DTENTR_"   ,"TRB"  ,STR0020   ,/*Picture*/                  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W1_PRAZO"     ,"TRB"  ,STR0021   ,"@E 99999"                   ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W0_COMPRA"    ,"TRB"  ,STR0022   ,/*Picture*/                  ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
     
     
      oSecao1:SetTotalInLine(.F.)
      oSecao1:SetTotalText("Prazo Médio")
      
      AEVAL(oSecao1:aCell, {|X| X:SetColSpace(3)})  //JWJ 22/01/07: Acerto no espaçamento das colunas
                                                                                                                                                 
      oTotal:= TRFunction():New(oSecao1:Cell("W1_PRAZO"),NIL,"AVERAGE",/*oBreak*/,"","@E 99,999",{|| TRB->W1_PRAZO },.T.,.F.)      
      oTotal:SetTotalInLine(.F.)
      
      If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR200REPORT"),)  //DRL 15/07/10
 
    
                  
   ENDIF
   
   IF nTipo = Confec_LI
      cNome1:= "Pedidos"
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SW3","SB1","SY1","SW2"}
   
      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem := {}

      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICTR200",STR0037,"EIC200",{|oReport| ReportPrint(oReport, nTipo)},STR0054)
      
      //ER - 20/10/2006 - Inicia o relatório como paisagem. 
      oReport:oPage:lLandScape := .T. 
      oReport:oPage:lPortRait := .F. 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome1,aTabelas,aOrdem)                  
   
      //Definição das colunas de impressão da seção 1   
      TRCell():New(oSecao1,"W3_PO_NUM"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"W2_PO_DT"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W3_CC"      ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"W3_SI_NUM"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W3_POSICAO" ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W3_COD_I"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"B1_DESC"    ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W3_QTDE"    ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W3_DT_ENTR" ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"W2_DT_PRO"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"W2_COMPRA"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)
//      TRCell():New(oSecao1,"Y1_NOME"    ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)   

      oSecao1:SetTotalInLine(.F.)
      oSecao1:SetTotalText("Prazo Médio")

      oTotal:= TRFunction():New(oSecao1:Cell("W3_QTDE"),NIL,"SUM",/*oBreak*/,"","@E 99,999",{|| TRB->W1_PRAZO/TRB->(EasyRecCount("TRB")) },.T.,.F.)      
      oTotal:SetTotalInLine(.F.)

      If(EasyEntryPoint("EICTR210"),Execblock("EICTR210",.F.,.F.,"TR210REPORT"),)  //igor chiba 31/08/2010
                  
   ENDIF   
   
   IF nTipo = Aprovacao_LI
      cNome1:="PLI.s"
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWP"}
   
      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem := {}

      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      
      IF nOpcao == 1 //Ag_Transferencia
         oReport := TReport():New("EICTR200",STR0056+" - "+STR0058,"EIC200",{|oReport| ReportPrint(oReport, nTipo)},STR0056+" "+STR0009)
      ENDIF
      
      IF nOpcao == 2 //Ag_Registro
         oReport := TReport():New("EICTR200",STR0056+" - "+STR0059,"EIC200",{|oReport| ReportPrint(oReport, nTipo)},STR0056+" "+STR0009)
      ENDIF

      IF nOpcao == 3 //Ag_Anuencia
         oReport := TReport():New("EICTR200",STR0056+" - "+STR0060,"EIC200",{|oReport| ReportPrint(oReport, nTipo)},STR0056+" "+STR0009)
      ENDIF
      
      //ER - 20/10/2006 - Inicia o relatório como paisagem. 
      oReport:oPage:lLandScape := .T. 
      oReport:oPage:lPortRait := .F.    

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome1,aTabelas,aOrdem)
   
      //Definição das colunas de impressão da seção 1   
      TRCell():New(oSecao1,"WP_NR_MAQ"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"WP_MICRO"    ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"WP_PGI_NUM"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"WP_SEQ_LI"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
              
      IF nOpcao == Ag_Registro
         TRCell():New(oSecao1,"WP_PROT"     ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
         TRCell():New(oSecao1,"WP_TRANSM"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)           
      ENDIF

      IF nOpcao == Ag_Anuencia
         TRCell():New(oSecao1,"WP_REGIST"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      ENDIF
   
      If(EasyEntryPoint("EICTR226"),Execblock("EICTR226",.F.,.F.,"TR226REPORT"),)  //igor chiba 31/08/2010
    
   
   ENDIF
   
   //JAP - 13/09/06 - Conversão do relatório de Validade de LI´s 
   IF nTipo = Validade_LI 
      cNome1:= "PLI.s"
      //Alias que podem ser utilizadas para adicionar campos personalizados no relatório
      aTabelas := {"SWP"}
   
      //Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
      aOrdem := {}

      //Cria o objeto principal de controle do relatório.
      //Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
      oReport := TReport():New("EICTR225",STR0056,"EIC200",{|oReport| ReportPrint(oReport, nTipo)},STR0037+" "+STR0035)
                          
      //ER - 20/10/2006 - Inicia o relatório como paisagem. 
      oReport:oPage:lLandScape := .T. 
      oReport:oPage:lPortRait := .F. 

      //Define o objeto com a seção do relatório
      oSecao1 := TRSection():New(oReport,cNome1,aTabelas,aOrdem)                  
   
      //Definição das colunas de impressão da seção 1   
      TRCell():New(oSecao1,"WP_VENCTO"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"WP_REGIST"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"WP_SUBST"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)   
      TRCell():New(oSecao1,"WP_NR_MAQ"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)
      TRCell():New(oSecao1,"WP_MICRO"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)                          
      TRCell():New(oSecao1,"WP_PGI_NUM" ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"WP_SEQ_LI"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"WP_PROT"    ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)          
      TRCell():New(oSecao1,"WP_TRANSM"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/     ,/*Tamanho*/      ,/*lPixel*/,/*{|| code-block de impressao }*/)             
          
      oSecao1:Cell("WP_VENCTO" ):SetColSpace(4)
      oSecao1:Cell("WP_REGIST" ):SetColSpace(4)
      oSecao1:Cell("WP_SUBST"  ):SetColSpace(4)
      oSecao1:Cell("WP_NR_MAQ" ):SetColSpace(4)
      oSecao1:Cell("WP_MICRO"  ):SetColSpace(4)
      oSecao1:Cell("WP_PGI_NUM"):SetColSpace(4)
      oSecao1:Cell("WP_SEQ_LI" ):SetColSpace(4)
      oSecao1:Cell("WP_PROT"   ):SetColSpace(4)
      oSecao1:Cell("WP_TRANSM" ):SetColSpace(4)
   
   ENDIF      

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport


************************************
Static Function ReportPrint(oReport, nTipo)
************************************
//Local oSection := oReport:Section("Seção 1")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
//TRPosition():New(oReport:Section("Seção 1"),"SW5",3,{|| xFilial("SW5") + Work->WKPO_NUM})

//TRPosition():New(oReport:Section("Seção 1"),"SA5",3,{|| xFilial("SA5") + SW5->W5_COD_I+SW5->W5_FABR+SW5->W5_FORN})

//TRPosition():New(oReport:Section("Seção 1"),"SB1",1,{|| xFilial("SB1") + Work->WKCOD_I})
//TRPosition():New(oReport:Section("Seção 1"),"SWP",2,{|| xFilial("SWP")})
//oSection:Print() 

//03/01/11 - DFS - Inclusão de tratamento para posicionar e trazer corretamente os fornecedores dos itens
If TRB->(FieldPos("W1_COD_I")) > 0 // 03/05/11 - TDF - Verifica se o campo existe na TRB
   TRPosition():New(oReport:Section(cNome1),"SW1",3,{|| xFilial("SW1") + TRB->W1_COD_I})
   oReport:SetMeter(TRB->(EasyRecCount("TRB")))
EndIf 

If TRB->(FieldPos("W3_COD_I")) > 0 // 03/05/11 - TDF - Verifica se o campo existe na TRB
   //03/05/11 - TDF - Posiciona a TRB
   TRPosition():New(oReport:Section(cNome1),"SW3",3,{|| xFilial("SW3") + TRB->W3_COD_I})
   oReport:SetMeter(TRB->(EasyRecCount("TRB")))
EndIf

TRB->( dbGoTop() )


//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section(cNome1):Init()

IF nTipo = FollowUp_Neg
   //Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
   //o cabeçalho dela.
   oReport:Section(cNome2):Init()
ENDIF


//Para desabilitar a impressão da página de parâmetros do pergunte
//oReport:oParamPage:Disable()

//Laço principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()     
   //ACB - 01/02/2011 - Tratamento para que o filtro do processo selecionados funcione
   If nTipo = FollowUp_Neg
      If EMPTY(ALLTRIM(TRB->XX_FLAGWIN))
         TRB->(DbSKip()) ; LOOP
      ENDIF
   ENDIF

   oReport:Section(cNome1):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section(cNome1):Finish() 


IF nTipo = FollowUp_Neg
   //Fim da impressão da seção 2
   oReport:Section(cNome2):Finish()
   
If(EasyEntryPoint("EICTR200"),Execblock("EICTR200",.F.,.F.,"TR200APOS_REPORT"),)  //DRL 15/07/10   
   
ENDIF

Return .T.

