#INCLUDE "Eicpn400.ch"
#INCLUDE "AVERAGE.CH"

STATIC CONSULTA:="1"
STATIC ESTORNO:="2"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EICPN400 ³ Autor ³ Luiz Claudio Barbosa  ³ Data ³ 18.08.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Zera o saldo de nacionalização de PO, quando houver nacio- ³±±
±±³          ³ nalização parcial.                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICPN400()
Local cOldArea  := Alias()
Private cProg   := "PN"  // Usada na PO_Filter Identifica como PO de Nacionalização
Private cFiltro // AST - 05/01/09 - Usada na PO_Filter     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variavel indicando se o cliente usa ForeCast            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lForeCast := (AllTrim(EasyGParam("MV_FORECAS"))$cSim), lFilDa:=EasyGParam("MV_FIL_DA")

SX3->(DBSETORDER(2))
PRIVATE lExiste_Midia:=EasyGParam("MV_SOFTWAR") $ cSim
SX3->(DBSETORDER(1))

PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro:= STR0004   // "Pedido de Nacionalização"
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))

PO_Filter(.T.)
mBrowse( 6, 1,22,75,"SW2")
PO_Filter(.F.)

DBSELECTAREA(cOldArea)

Return .T.                  


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 26/01/07 - 14:42
*/
Static Function MenuDef()
Local aRotAdic := {}  
Local aRotina  := { { STR0001,"AxPesqui"  , 0 , 1},; // "Pesquisar"
                    { STR0002,"PN400Visua", 0 , 2},; // "Visualizar"
  				    { STR0003,"PN400ZERA" , 0 , 2}}  // "Zera Saldo"
  				    
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IPN400MNU")
	aRotAdic := ExecBlock("IPN400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina  				    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PN400Visua³ Autor ³ Luiz Claudio Barbosa  ³ Data ³ 18.08.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Zera o saldo de nacionalização de PO.                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void PN400Visua(ExpC1,ExpN2,ExpN3)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN2 = Numero do registro                                 ³±±
±±³          ³ ExpN3 = Define a apção                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICPN400                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PN400Visua(cAlias,nReg,nOpc)
Local lVisua := .T.
nOpca := PN400Manut(cAlias,nReg,nOpc,lVisua)
Return(Nil)

Function PN400ZERA(cAlias, nReg, nOpc)
Local lVisua := .F.
nOpca := PN400Manut(cAlias,nReg,nOpc,lVisua)
Return(Nil)

Function PN400Manut(cAlias,nReg,nOpc,lVisua)
LOCAL nOpca := 0, i
LOCAL oDlg, oGet , oEnch
LOCAL cAlias1:="SW3", FileWork
LOCAL _LIT_R_CC := IF(EMPTY(ALLTRIM(EasyGParam("MV_LITRCC"))),(AVSX3("W0__CC",5)), ALLTRIM(EasyGParam("MV_LITRCC")))
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL _PictSI   := ALLTRIM(X3PICTURE("W0__NUM"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0],aHeader[0]
PRIVATE MConta:=MTotal:=0, TPO_NUM:=SW2->W2_PO_NUM           
PRIVATE cMarca := GetMark(), lInverte := .F.

If ! EICPN400PROG()
   Return .F.
EndIf

If !lVisua
   If PN400SLDMANUT(.F.)
      Help(" ", 1, "AVG0000101")
      Return(.F.)
   EndIf
EndIf

dbSelectArea(cAlias)
IF EasyRecCount() == 0
   Return (.T.)
EndIf

SW3->(DBSETORDER(7))
IF !SW3->(DBSEEK(xFilial()+SW2->W2_PO_NUM))
   Help(" ",1,"E_NAOHAITE")
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PN400GeraWork(@FileWork,CONSULTA)
   Return
Endif

IF MTotal = 0
   Help(" ",1,"E_NAOHAITE")
ENDIF

TB_Campos:={}
bQtde_Emb:={||IF(Work->WKFLUXO=="7",TRAN(Work->WKQTDE_EMB,_PictPrUn),;
                                    STR0005 )} //'   Anuencia    '

bTotal:={||TRAN(Work->WKQTDE*Work->WKPRECO,_PictPrUn)}

AADD(Tb_Campos,{{||PN400PESQ('CC')},,_LIT_R_CC })
AADD(Tb_Campos,{"WKSI_NUM",,STR0006,_PictSI})                          // "No.SI"
AADD(Tb_Campos,{"WKPOSICAO",,STR0007})                                 // "Posição"
AADD(Tb_Campos,{"WKCOD_I" ,,STR0008,_PictItem})                        // "Item"
AADD(Tb_Campos,{"WKPART_N",,STR0009})                                  // "Part Number"
AADD(Tb_Campos,{{||IF(Work->WKFLUXO=='7',STR0010,STR0011)},,STR0012})  // "Nao"###"Sim"###"Anuencia"
AADD(Tb_Campos,{"WKDESCR" ,,STR0013})                                  // "Descricao em Inglês"
AADD(Tb_Campos,{{||PN400PESQ('FB')},,STR0014})                         // "Fabricante"
AADD(Tb_Campos,{{||BUSCA_UM(Work->WKCOD_I+Work->WKFABR+Work->WKFORN,WORK->WKCC+WORK->WKSI_NUM)},,STR0015}) //"Uni" //OS:0142/02 SO.:0022/02 FCD

IF lExiste_Midia .AND. !EMPTY(SW2->W2_VLMIDIA)
   AADD(Tb_Campos,{"WK_QTMIDIA",,AVSX3("B1_QTMIDIA",5),AVSX3("B1_QTMIDIA",6)})
   AADD(Tb_Campos,{"WK_VLTOTMI",,STR0016,AVSX3("W2_VLMIDIA",6)})       // "Vlr. Total Midia"
ENDIF

AADD(Tb_Campos,{"WKQTDE"  ,,STR0017,_PictQtde})                       // "Quantidade"
AADD(Tb_Campos,{bQtde_Emb ,,STR0018})                                  // "Qtde Embarcada"
AADD(Tb_Campos,{"WKSALDO_Q",,STR0019,AVSX3("W3_SALDO_Q",6)})            // "Saldo Qtde"
AADD(Tb_Campos,{"WKPRECO"  ,,STR0020,_PictPrUn})                       // "Preço Unit"
AADD(Tb_Campos,{bTotal,,STR0021})                                      // "Valor Total"
AADD(Tb_Campos,{"WKDT_EMB" ,,STR0022})                                 // "Embarque"
AADD(Tb_Campos,{"WKDT_ENTR",,STR0023})                                 // "Entrega"

If lForeCast
   AADD(Tb_Campos,{{||IF(WK_FORECAS=="S",STR0024,STR0025)},,STR0026})  // "Sim"###"Nao"###"Forecast"
Endif

AADD(Tb_Campos,{{||SX5->(dbSeek(xFilial()+"Y2"+Work->WK_REG_TRI)),AllTrim(X5DESCRI())},,AVSX3("W3_REG_TRI")[5]})
AADD(Tb_Campos,{"WK_REG_MIN",,OemToAnsi(STR0027)})                     // "Registro no Ministério / Orgão Público"
AADD(Tb_Campos,{"WK_TEC"   ,,AVSX3("W3_TEC"   )[5]})
AADD(Tb_Campos,{"WK_EX_NCM",,AVSX3("W3_EX_NCM")[5]})
AADD(Tb_Campos,{"WK_EX_NBM",,AVSX3("W3_EX_NBM")[5]})

FOR i := 1 TO SW2->(FCount())
   SW2->( M->&(FIELDNAME(i)) := FieldGet(i) )
NEXT

While .T.
   oMainWnd:ReadClientCoords()

   DEFINE MSDIALOG oDlg TITLE STR0028+AllTrim(Transf(M->W2_HAWB_DA,AVSX3("W2_HAWB_DA",6))); //"Pedido de Nacionalização - DA: "
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
    	    OF oMainWnd PIXEL  

   oEnCh:=MsMGet():New(cAlias,nReg,nOpc,,,,,{15,1,FINAL_ENCHOICE,COLUNA_FINAL},,3)

   dbSelectArea("Work")
   dbGoTop()

   //GFP 19/10/2010
   TB_Campos := AddCpoUser(TB_Campos,"SW3","2")
   
   oGet:=MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{FINAL_ENCHOICE+1,1,FINAL_SELECT,COLUNA_FINAL})
   
   oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||nopca:=2,oDlg:End()})) //LRL 12/04/04 - Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   Exit
Enddo

If !lVisua .And. nOpca == 1
   PN400SLDMANUT(.T.)
EndIf

Work->(E_EraseArq(FileWork))
DBSELECTAREA("SW2")

Return( nOpca )


*----------------------------------------------------------------------------
Function PN400GeraWork(FileWork,cOpcao)  
*----------------------------------------------------------------------------
// aDBF_Stru eh private por causa dos rdmakes
PRIVATE aDBF_Stru:= { {"WKCOD_I","C",  AVSX3("W3_COD_I",3),0}, {"WKDESCR","C",26,0}    ,;
                      {"WKFABR","C",   AVSX3("A2_COD",3),0}  , {"WKNOME_FAB","C",15,0} ,;
                      {"WKFORN","C",   AVSX3("A2_COD",3),0}  , {"WKNOME_FOR","C",15,0} ,;
                      {"WKREG","N",    AVSX3("W3_REG",3),0}  , {"WKFLUXO","C",1,0}     ,;
                      {"WKQTDE","N",   AVSX3("W3_QTDE",3),   AVSX3("W3_QTDE",4)},; 
                      {"WKPRECO","N",  AVSX3("W3_PRECO",3),  AVSX3("W3_PRECO",4)},;
                      {"WKSALDO_Q","N",AVSX3("W3_SALDO_Q",3),AVSX3("W3_SALDO_Q",4)},;
                      {"WKCC","C",AVSX3("Y3_COD",3),0},;
                      {"WKPOSICAO","C",LEN(SW3->W3_POSICAO),0} , {"WKFLAGWIN","C",2,0}   ,;
                      {"WKSI_NUM","C" ,AVSX3("W0__NUM",3),0}   , {"WKPO_NUM","C",15,0}   ,;
                      {"WKDT_EMB","D",8,0}   , {"WKDT_ENTR","D",8,0}   ,;
                      {"WKDTENTR_S","D",8,0} , {"WKSEQ","N",2,0}       ,;
                      {"WKRECNO","N",7,0}    , {"WKFLAG","L",1,0}      ,;
                      {"WKQTDE_EMB","N",AVSX3("W3_QTDE",3),AVSX3("W3_QTDE",4)},;
                      {"WKPART_N","C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0}   ,;
                      {"WKCCNOME","C",20,0}  , {"WK_REG_MIN","C",10,0} ,;
                      {"WK_ALTEROU","L",01,0}, {"WK_REG_TRI","C",01,0} ,;
                      {"WK_TEC"  ,"C",10,0}  , {"WK_EX_NCM", "C",LEN(SW3->W3_EX_NCM),0} ,;
                      {"WK_EX_NBM","C",LEN(SW3->W3_EX_NBM),0}}

EICAddWkLoja(aDBF_Stru, "W3_FABLOJ", "WKFABR")
EICAddWkLoja(aDBF_Stru, "W3_FORLOJ", "WKFORN")

IF lExiste_Midia
   AADD(aDBF_Stru,{"WK_QTMIDIA",AVSX3("B1_QTMIDIA",2),AVSX3("B1_QTMIDIA",3),AVSX3("B1_QTMIDIA",4)})
   AADD(aDBF_Stru,{"WK_VLTOTMI",AVSX3("W2_VLMIDIA",2),AVSX3("W2_VLMIDIA",3),AVSX3("W2_VLMIDIA",4)})
ENDIF

If lForeCast
   AADD(aDBF_Stru,{"WK_FORECAS","C",1,0})
Endif

//GFP 19/10/2010
aDBF_Stru := AddWkCpoUser(aDBF_Stru,"SW3")

SW5->(DbSetOrder(3))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho e indice                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FileWork := E_CriaTrab(,aDBF_Stru,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Work->(E_EraseArq(FileWork))
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
IndRegua("Work",FileWork+TEOrdBagExt(), "WKCC+WKSI_NUM+WKCOD_I+WKFABR+WKFORN+STR(WKREG,"+Alltrim(Str(AVSX3("W3_REG",3)))+",0)")

MsAguarde({||SW3->(PN400Work({|msg|MsProcTxt(msg)},cOpcao))},;
                                        STR0029) //"Pesquisa de Itens"

Return .T.


*----------------------------------------------------------------------------
Function PN400Work(bMsg,cOpcao)  
*----------------------------------------------------------------------------
LOCAL cKey_SA5 := " ", cKey_SB1 := " "
LOCAL cKey_SY3 := " ", cKey_SYG := " "

SA5->(DbSetOrder(3))
SW3->(dbSetOrder(7)) // FILIAL+PO+SEQ

WHILE .NOT. SW3->(EOF()) .AND. SW3->W3_PO_NUM = SW2->W2_PO_NUM .AND. SW3->W3_FILIAL == xFilial("SW3")
   Eval(bMsg,STR0030+ALLTRIM(W3_COD_I)) // "Processando Item "
   MConta:= MConta + 01

   IF SW3->W3_SEQ <> 0
      EXIT
   ENDIF

   IF cOpcao = ESTORNO .And. SW3->W3_FLUXO # "7" .AND. SW3->W3_SALDO_Q == 0
      DBSKIP() ; LOOP
   ENDIF

   IF SW3->W3_FLUXO == "7"
      nQtd_Gi:=nSld_Gi:=nQtdEmb:=0
      Po420_IgPos("3")
      nSeq_SLi:= SW5->W5_PGI_NUM
      
      IF cOpcao = ESTORNO .And. nSld_Gi == 0
         DBSKIP() ; LOOP
      ENDIF
   ENDIF

   DBSELECTAREA("Work")
   DBAPPEND()

   If cKey_SB1 != SW3->W3_COD_I
      cKey_SB1 := SW3->W3_COD_I
      SB1->(DBSEEK(xFilial()+SW3->W3_COD_I))
   Endif
   If cKey_SA5 != SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN
      cKey_SA5 := SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN
      SA5->(DBSEEK(xFilial()+SW3->W3_COD_I+SW3->W3_FABR+SW3->W3_FORN))
   Endif
   If cKey_SY3 != SW3->W3_CC
      cKey_SY3 := SW3->W3_CC
      SY3->(DbSeek(xFilial()+SW3->W3_CC))
   Endif
   If cKey_SYG != SW3->W3_FABR+SW3->W3_COD_I
      cKey_SYG := SW3->W3_FABR+SW3->W3_COD_I
      SYG->(DBSEEK(xFilial()+SW2->W2_IMPORT+SW3->W3_FABR+SW3->W3_COD_I))
   Endif
   
   REPLACE WKCOD_I    WITH  SW3->W3_COD_I            ,;
           WKFABR     WITH  SW3->W3_FABR             ,;
           WKFORN     WITH  SW3->W3_FORN             ,;
           WKREG      WITH  SW3->W3_REG              ,;
           WKSEQ      WITH  SW3->W3_SEQ              ,;
           WKQTDE     WITH  SW3->W3_QTDE             ,;
           WKPRECO    WITH  SW3->W3_PRECO            ,;
           WKSALDO_Q  WITH  SW3->W3_SALDO_Q          ,;
           WKCC       WITH  SW3->W3_CC               ,;
           WKPOSICAO  WITH  SW3->W3_POSICAO          ,;
           WKSI_NUM   WITH  SW3->W3_SI_NUM           ,;
           WKDT_EMB   WITH  SW3->W3_DT_EMB           ,;
           WKDT_ENTR  WITH  SW3->W3_DT_ENTR          ,;
           WKRECNO    WITH  SW3->(RECNO())           ,;
           WKFLUXO    WITH  SW3->W3_FLUXO            ,;
           WKCCNOME   WITH  SY3->Y3_DESC             ,;
           WK_REG_MIN WITH  SYG->YG_REG_MIN
           // WKPART_N   WITH  ALLTRIM(SA5->A5_CODPRF)  ,;
           
   If SW3->(FieldPos("W3_PART_N")) # 0 .And. !Empty(SW3->W3_PART_N) //ASK  05/10/2007
      Work->WKPART_N := SW3->W3_PART_N
   Else 
      Work->WKPART_N := ALLTRIM(SA5->A5_CODPRF)
   EndIf      

   IF lExiste_Midia           .AND.;
      !EMPTY(SW2->W2_VLMIDIA) .AND.;
      SB1->B1_MIDIA $ cSim
      Work->WK_QTMIDIA := SB1->B1_QTMIDIA
      Work->WK_VLTOTMI := SB1->B1_QTMIDIA * SW2->W2_VLMIDIA
   ENDIF
   
   Work->WK_TEC    := Busca_NCM("SW3","NCM") //SW3->W3_TEC
   Work->WK_EX_NCM := Busca_NCM("SW3","EX_NCM")//SW3->W3_EX_NCM
   Work->WK_EX_NBM := Busca_NCM("SW3","EX_NBM")//SW3->W3_EX_NBM

   Work->WK_ALTEROU := .F. // Qdo True indica que o registro foi alterado.
              
   If lForeCast
      Work->WK_FORECAS := SW3->W3_FORECAS
   Endif

   Work->WK_REG_TRI := SW3->W3_REG_TRI             
               
   IF SW3->W3_FLUXO == "7"
      //Work->WKQTDE_EMB:= IF(cOpcao = ESTORNO,SW3->W3_QTDE,nQtd_Gi) - nSld_Gi
      Work->WKQTDE_EMB:= IF(cOpcao = ESTORNO,SW3->W3_QTDE - nSld_Gi,nQtdEmb)
      Work->WKSALDO_Q := nSld_Gi
   ENDIF

   E_ItFabFor(.T.,,"PO")

   MTotal+=( SW3->W3_QTDE * SW3->W3_PRECO )

   DBSELECTAREA("SW3")
   DBSKIP()
ENDDO

Return .T.

*-------------------*
Function PN400PESQ(nOp)
*-------------------*
DBSELECTAREA("Work")
DO CASE
   CASE nOp == 'CC'
        RETURN WKCC+' '+WKCCNOME
   CASE nOp == 'FB'
        RETURN WKFABR + '-' + WKNOME_FAB
   CASE nOP == 'FO'
        RETURN WKFORN + '-' + WKNOME_FOR
ENDCASE

Function PN400SLDMANUT(lAlter)
Local lRet := .T.,   lZerou := .F.
Local cProduto, cPosicao, nSaldo
Local cProdSiga, cPedSiga, cEmissao, cForn, cLoja  // SVG - 26/07/2010 -
Local lCompras := EasyGParam("MV_EASY",,"S") $ cSim     // SVG - 26/07/2010 -
Local cPoNum := SW2->W2_PO_NUM                     // SVG - 26/07/2010 -
Local aRecSC7 := {} //MCF - 12/05/2016 - Parâmetro novo utilizado na função MA235PC
PRIVATE lMT235G1 := EasyEntryPoint("MT235G1")          // SVG - 26/07/2010 - Variavél declarada para uso da rotina MA235PC, não utilizada no Easy.
SW3->(dbSetOrder(8))
SW5->(dbSetOrder(8))

SW3->(dbSeek(xFilial("SW3")+cPoNum))

While !(SW3->(Eof())) .And. SW3->W3_FILIAL+SW3->W3_PO_NUM == ;
							xFilial("SW3")+cPoNum
	cPosicao := SW3->W3_POSICAO
	cProduto := SW3->W3_COD_I
	nSaldo   := 0

	While !(SW3->(Eof())) .And. xFilial("SW3")+cPoNum  == ;
								SW3->W3_FILIAL+SW3->W3_PO_NUM .And.;
								cPosicao == SW3->W3_POSICAO
		If SW3->W3_SEQ == 0
		   //*** SVG - 26/07/2010 -  
           If lCompras .And. lAlter  //Se integrado com SIGACOM chama a rotina da microsiga para Eliminar Resíduo.
              SW2->(dbSeek(xFilial("SW2")+SW3->W3_PO_DA))
              cProdSiga := SW3->W3_COD_I
              cPedSiga  := SW2->W2_PO_SIGA  
              cEmissao  := SW2->W2_PO_DT               
              cForn     := SW2->W2_FORN
              cLoja     := Posicione("SA2",1,xFilial("SA2") + cForn,"A2_LOJA") 
                       
              MA235PC(100,1,cEmissao,cEmissao,cPedSiga,cPedSiga,cProdSiga,cProdSiga,cForn,cForn,,,,,.F.,aRecSC7) //Elimina Residuo no SIGACOM
		   EndIf
		   //*** SVG - 26/07/2010 -  		
				
			nSaldo := nSaldo + SW3->W3_SALDO_Q
			If lAlter
				RecLock("SW3", .F.)
				SW3->W3_SALDO_Q := 0
				SW3->(MsUnLock())
			EndIf
			SW3->(dbSkip())
			Loop
		EndIf
						
		SW5->(dbSeek(xFilial("SW5")+SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO))
		While !(SW5->(Eof())) .And. xFilial("SW5")+SW3->W3_PGI_NUM+SW3->W3_PO_NUM+SW3->W3_POSICAO ==;
			                        SW5->W5_FILIAL+SW5->W5_PGI_NUM+SW5->W5_PO_NUM+SW5->W5_POSICAO
		   If SW5->W5_SEQ == 0
			  If SW5->W5_SALDO_Q > 0
			     If lAlter
					If SW5->W5_FLUXO == "1"
					   cDesc := "ZERADO O SALDO DE "+AllTrim(TransForm(SW5->W5_SALDO_Q, AVSX3("W5_SALDO_Q", 6)))+"DO ITEM "+cProduto
					   Grava_Ocor(SW5->W5_PO_NUM, dDataBase, cDesc, "LI")
					Else
					   nSaldo := nSaldo + SW5->W5_SALDO_Q
					EndIf
					RecLock("SW5", .F.)
					SW5->W5_SALDO_Q := 0
					SW5->(MsUnLock())
				 EndIf
				 lZerou := .T.
			  EndIf
		   EndIf
		   SW5->(dbSkip())
		EndDo
   		SW3->(dbSkip())
	EndDo
			
	If nSaldo > 0
		If lAlter
			nSaldo := nSaldo + SW3->W3_SALDO_Q
			cDesc  := "ZERADO O SALDO DE "+AllTrim(TransForm(nSaldo, AVSX3("W3_SALDO_Q", 6)))+;
				      "DO ITEM "+cProduto
			Grava_Ocor(SW3->W3_PO_NUM, dDataBase, cDesc, "PN")
		EndIf
		lZerou := .T.
	EndIf
EndDo

SW3->(dbSetOrder(1))
SW5->(dbSetOrder(1))
lRet := !lZerou
If lRet
	Help(" ", 1, "AVG0000102")
EndIf
Return(lRet)

Static Function EICPN400PROG()
LOCAL lCerto:=.T.
If EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000107") 
   lCerto:=.F.
EndIf
Return lCerto
