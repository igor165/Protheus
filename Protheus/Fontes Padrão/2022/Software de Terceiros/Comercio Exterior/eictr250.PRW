#INCLUDE "Eictr250.ch"
//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "avprint.ch"


#DEFINE TIMES_NEW_ROMAN_24_UNDERLINE oFont1 
#DEFINE TIMES_NEW_ROMAN_14           oFont2

#DEFINE   Atracacao    "1"        
#DEFINE   Pagamento    "2"
#DEFINE   Desembaraco  "3"

#DEFINE   _Agentes      STR0001 //"Agentes"
#DEFINE   _Despachantes STR0002 //"Despachantes"
#DEFINE   ATUAL  2
#DEFINE   TODOS  3

#DEFINE   Transportes  "1"
#DEFINE   Processo     "2"

#DEFINE ARRAY_OPCOES   {STR0003,; //"Aguardando Embarque"
                        STR0004} //"Aguardando EmissÃo do Shipping"

#COMMAND E_RESET_AREA => SW6->(DBSETORDER(1)) ; SY9->(DBSETORDER(1)) ;
                       ; TRB->(E_EraseArq(cNomArq)) ;
                       ; DBSELECTAREA(nOldArea)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR250 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 18.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Follow-Up de Aguardando Embarque                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR250()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*---------------*
//Alterado Heder M Oliveira 26/11/99 10:45
function EICTR250
*---------------*
LOCAL nPrazoMed:=0, nOldArea:=SELECT(), oDlg, oGet,i
LOCAL oDlg_Opc, lOk_Opc, cOpcao// , oPanel // DRL 07/07/10
Local lConsSW6 := EasyGParam("MV_EIC0022",,.F.)   // GFP - 07/01/2013 - Considera SW6
Private cDias := "" //NCF 11/05/09
PRIVATE lSeal:=EasyEntryPoint("IC193TR1")
PRIVATE lExisteRD:=EasyEntryPoint("EICPFUP1_AP5")
Private oPanel, aCposTRB := {} //DRL 07/07/10 - Para controle do Panel e colocar mais campos no TRB
Private lDlgFilCusto := .F. //DRL 23/06/10 - Caso o Dialog do Filtro Seja Customizado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCampos:={"W5_PO_NUM","W5_COD_I","B1_DESC","W5_SALDO_Q","W2_COMPRA","Y1_NOME",;
                  "W5_FORN","A2_NREDUZ","WP_VENCTO","W5_DT_EMB"}, nOpca:=0
IF(lSeal,ExecBlock("IC193TR1",.F.,.F.,"1"),) //AWR 01/10/1999 

aCposTRB := { {"WKFILIAL","C", 2,0},{"W4_PRAZO","N", 5,0},{"W5_OBS","C",45,0},{"XX_FLAGWIN","C",2,0},{"W4_ORDEM","C", 5,0}}  //DRL 07/07/10 #### THTS - 07/11/2017 - Adicionado o campo W4_ORDEM
EICAddLoja(aCampos,"W5_FORLOJ", Nil, "W5_FORN") 
If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250CAMPOS"),)  // EOB - 19/01/10

PRIVATE cCadastro := STR0003, nIdioma:=1 //"Aguardando Embarque"
Private aHeader[0], cTitulo, cImportador
PRIVATE cMarca := GetMark(), lInverte := .F., TB_Campos:={}
Private aTB_CAmpos:={},aDBF:={},aMarcados:={},aFilSW5:={}			//CDS 11/01/06s

cNomArq := E_CriaTrab(,aCposTRB)

AADD(aHeader,{STR0005,"W4_PRAZO"    ,E_TrocaVP(nIdioma,"@E 99,999"),05,0," ","   ","N",," "}) 	//"Prazo"
AADD(aHeader,{STR0006,"W5_OBS"      ,"@!"       ,30,0," ","   ","C",," "}) 						//"Status"
AADD(aHeader,{""     ,"XX_FLAGWIN"  ,,2,0," ","   ","C",," "})

IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W4_ORDEM+W5_PO_NUM") //THTS - 07/11/2017 - Substituido no indice o STR(99999-W4_PRAZO,5,0) pelo W4_ORDEM, pois dava erro com temp no banco
If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250INDICE"),)  // DRL 07/07/10 - Para Criar Indices Customizados

AADD(aCampos,"W4_PRAZO")
AADD(aCampos,"W5_OBS")

aFilSW5:=AvgSelectFil(.T.,"SW5")    //CDS 11/01/05
IF aFilSW5[1] == "WND_CLOSE"    	
   TRB->(E_EraseArq(cNomArq))
   DBSELECTAREA(nOldArea)
   RETURN 
ENDIF

WHILE .T.

   lOk_Opc:=.F.
   DEFINE MSDIALOG oDlg_Opc TITLE STR0003 From 11,0 To 24,50 OF oMainWnd //"Aguardando Embarque"
      
      oPanel:= TPanel():New(0, 0, "", oDlg_Opc,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 1.7,0.8  SAY STR0007 OF oPanel //"Follow-up"
      @ 1.4,6.0  COMBOBOX cOpcao ITEMS ARRAY_OPCOES SIZE 100,25 OF oPanel

   ACTIVATE MSDIALOG oDlg_Opc ON INIT ;
            EnchoiceBar(oDlg_Opc,{||lOk_Opc:=.T.,oDlg_Opc:End()},;
                                 {||lOk_Opc:=.F.,oDlg_Opc:End()}) CENTERED
   IF !lOk_Opc
      EXIT
   ENDIF                                                                             
   
   lBrowseFil:=.F.   
   //CDS 11/01/06
   SX2->(DBSetOrder(1))
   SX2->(DBSeek("SYT"))   
   If !FWModeAccess("SYO",3) =="E"
      lBrowseFil:=.T.
      ccpo:="YT_COD_IMP"

      bCampo:={||IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",STR0063,WorkFil->(FIELDGET(FIELDPOS(ccpo))))}
                 
      aTB_Campos:={{bCampo,"",AVSX3(ccpo,5) } }
            
      aDBF:= { {ccpo,AVSX3(ccpo,2),AVSX3(ccpo,3),AVSX3(ccpo,4)} }
      bMarca:={||IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",SPACE(AVSX3(ccpo,3)),WorkFil->(FIELDGET(FIELDPOS(ccpo)))),TR250GET(@cImportador,@cTitulo)}

      aRetMarcados:={ccpo}
         
      aMarcados:=AvgMBrowseFil("","",aFilSW5,aTb_Campos,"",aDBF,bMarca,aRetMarcados, , {|| markAll()})        
	     
      IF EMPTY(aMarcados)   // Nao marcou nenhum ou cancelou ??
         EXIT
      ENDIF 
	elseif !lDlgFilCusto .And. ! E_GetImp(@cImportador,@cTitulo)
      LOOP
   ENDIF
   
   lLoop := .F. //DRL 07/07/10 - Caso o Dlg Customizado retorna falso
   If EasyEntryPoint("EICTR250") //DRL 07/07/10
      ExecBlock("EICTR250",.F.,.F.,"TR250DIALOG_CUSTO") //DRL 07/07/10 - Caso Seja um Dialog Customizado
   EndIf
   
   If lLoop //DRL 07/07/10
      LOOP
   ENDIF
   
   IF(!lBrowseFil,aMarcados:=ACLONE(aFilSW5),)  
   
   nPrazoMed:=0

   TRB->(avzap())
   SW5->(DBSETORDER(6))

   lAguardaEmissaoShip:= !(cOpcao==ARRAY_OPCOES[1])   // RS - 18/01/06
   cCadastro := cOpcao               

   cSvFilAnt:=cFilant   
   For i:=1 to len(aMarcados)         
      aTemp:=aMarcados[i]
      cFilSel:=IF(lBrowseFil,aTemp[1],aTemp)
      If !Empty(aFilSW5[i])  //ASK
         cFilAnt:=cFilSel
      EndIf       
      IF(lBrowseFil,cImportador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1]),)                                           
   
      SW5->(DBSEEK(xFilial("SW5")+STR(0,2,0)+STR(0.001,13,3),.T.))
          
      ProcRegua(SW5->(Easyreccount("SW5")))

      While ! SW5->(Eof()).and.SW5->W5_FILIAL==xFilial("SW5")
         If SW5->W5_SEQ==0 .and. SW5->W5_SALDO_Q>0       // GFP - 07/01/2013
            nPrazoMed+=TR250Grava(cImportador,lAguardaEmissaoShip)  
            IncProc()
         EndIf
         SW5->(DBSkip())
      End
      
      If(lConsSW6, TR250GrvSW6(),)  // GFP - 07/01/2013
      	          
   Next                                       
   cFilAnt:=cSvFilAnt
   
   SW5->(DBSETORDER(1))

   IF TRB->(Easyreccount("TRB")) > 0
      nPrazoMed:=INT((nPrazoMed/TRB->(Easyreccount("TRB")) * 100)/100)
   ELSE
      Help("", 1, "AVG0000604")//"Não há registros para visualização !"###"Informação"
      nPrazoMed:=0
      LOOP
   ENDIF

   If ValType(nPrazoMed) = "N"
      nPrazoMed:=Padl(nPrazoMed,4,"0")
   Endif

   TB_Campos:={}
   E_CriaCampos(TB_Campos)

   cRel:=STR0010 //"1 - Carta"
   lEmbarque:= .T.
   SYT->(DBSEEK(xFilial("SYT")+cImportador))
   
   aSize(TB_Campos,len(TB_Campos)+1)
   aIns(TB_Campos,2)

   Tb_Campos[2]:={ {||TRB->WKFILIAL+'-'+AvgFilName({TRB->WKFILIAL})[1]},"",AVSX3("W2_FILIAL",5) }
  
   DO WHILE .T.
   
      dbSelectArea("TRB")
      dbGoTop()
      nOpca:=0

      oMainWnd:ReadClientCoors()

      DEFINE MSDIALOG oDlg TITLE cCadastro+IF(!lBrowseFil," - "+cTitulo+IF(!EMPTY(cImportador)," - "+SYT->YT_NOME_RE,""),"") ;
         From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL                 

         oGet:=MsSelect():New("TRB","XX_FLAGWIN",,TB_Campos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
         //oGet:oBrowse:lCanAllMark:=.t.
         //oGet:oBrowse:lHasmark:=.t.
         @00,00 MsPanel oPanel Prompt "" Size 60,25 of oDlg  //LRL 28/04/04 - Painel p/ alinhamento MDI
         @ .8 ,0.8  SAY   OEMTOANSI(STR0011) of oPanel//"Prazo M‚dio"
         @ .8 ,  6  MSGET nPrazoMed WHEN .F. SIZE 21,8 of oPanel centered
         @ .8 ,15.5 SAY   OemToAnsi(STR0012) SIZE 25,8 of oPanel //"ImpressÆo"
         @ .4 ,020  COMBOBOX oCbx VAR cRel ITEMS {STR0010,STR0013} SIZE 40,50 OF oPanel  //"1 - Carta"###"2 - Itens"

         If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250CABEC_TELA"),) //DRL 07/07/10
         
         //DEFINE SBUTTON FROM 08,(oDlg:nClientWidth-4)/2-70 TYPE 6 ACTION (TR250Marca(),oGet:oBrowse:Refresh()) ENABLE OF oPanel
         @8,(oDlg:nClientWidth-4)/2-70 BUTTON STR0063 SIZE 34,11 ACTION (TR250Marca(),oGet:oBrowse:Refresh())  OF oPanel PIXEL //"&Todos"
         DEFINE SBUTTON FROM 08,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (nOpca:=2,oDlg:End()) ENABLE OF oPanel
      
	     oPanel:Align:=CONTROL_ALIGN_TOP   //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT        
         oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	     oGet:oBrowse:Refresh()  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()})) //LRL 28/04/04//Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      IF nOpca == 2
         IF(cRel="1",TR250Carta(),TR250Item())
         LOOP
      ENDIF

      EXIT

   ENDDO

   IF nOpca == 0
      EXIT
   ENDIF

END

TRB->(E_EraseArq(cNomArq))
DBSELECTAREA(nOldArea)

Return

*-------------------------------------*
FUNCTION TR250GET(cImportador,cTitulo)
*-------------------------------------*
LOCAL cSvFilAnt
IF !EMPTY(WorkFil->WKMARCA)
   WorkFil->YT_COD_IMP:=SPACE(LEN(WorkFil->YT_COD_IMP))
   WorkFil->WKMARCA:=SPACE(02)
   RETURN .T.
ENDIF

cSvFilAnt:=cFilAnt
cFilAnt:=WorkFil->WKFILIAL

IF E_GetImp(@cImportador,@cTitulo)
   WorkFil->WKMARCA:=cMarca
   WorkFil->YT_COD_IMP:=IF(EMPTY(cImportador),"*Todos",cImportador)   
ENDIF   
cFilAnt:=cSvFilAnt
RETURN .T.

Static Function markAll()

cNewMarca := ''

IF WorkFil->WKMARCA == cMarca
   cNewMarca:=SPACE(02)
ELSE
   cNewMarca:=cMarca
   cImportador := ""
   cTitulo := "Geral"
ENDIF

WorkFil->(DBGOTOP())

WHILE ! WorkFil->(EOF())
   WorkFil->WKMARCA :=cNewMarca
   IF WorkFil->WKMARCA == cMarca
      IF EMPTY(cImportador)
        WorkFil->YT_COD_IMP := "*Todos"
      EndIf
   ELSE
      WorkFil->YT_COD_IMP := ""
   ENDIF
   WorkFil->(DBSKIP())
ENDDO

WorkFil->(DbGoTop())

oMark:oBrowse:Refresh()
oMark:oBrowse:Reset()
SysRefresh()

RETURN NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR250Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 18.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR250Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICTR250                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION TR250Grava(cImportador,lAguardaEmissaoShip)

LOCAL dIni, cObs, cDesc, nPrazo:=0

DBSELECTAREA("SW5")

SW4->(DBSEEK(xFilial("SW4")+SW5->W5_PGI_NUM))

IF (!EMPTY(cImportador) .AND. SW4->W4_IMPORT # cImportador )    .OR. ;
   ( SW4->W4_FLUXO = "5" )
   RETURN nPrazo
ENDIF

IF lAguardaEmissaoShip .And. ! Empty(SW5->W5_DT_SHIP)
   Return nPrazo
Endif
   
lLoop := .F. //DRL 07/07/10
If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250VALID_GRAVA"),)  //DRL 07/07/10

If lLoop //DRL 07/07/10
   Return nPrazo
EndIf
DIni:= SW5->W5_DT_EMB

If SW5->W5_DT_EMB >= dDataBase    // GFP - 19/10/2012
   cObs := "AG. EMBARQUE"+;
           IF(EMPTY( SW5->W5_DT_SHIP ),STR0014,"") //" S/ SHIPPING INSTRUCTIONS" 
Else
   cObs := "NAO EMBARCADO"+;
           IF(EMPTY( SW5->W5_DT_SHIP ),STR0014,"") //" S/ SHIPPING INSTRUCTIONS" 
EndIf
 
IF SW5->W5_DT_EMB < dDataBase
   cObs := STR0015+; //"NAO EMBARCADO - "
           IF(EMPTY(SW5->W5_DT_SHIP),STR0016,; //"SEM SHIPPING INSTRUCTIONS"
                                     STR0017) //"COM SHIPPING INSTRUCTIONS"
ENDIF

IF ! EMPTY( SW5->W5_DOCTO_FU )
   cObs:= STR0018 + DTOC(SW5->W5_DT_EMB) //"EMBARQUE CONFIRMADO P/ "
ENDIF

IF ! EMPTY(SW5->W5_HAWB)
   SW6->( DBSEEK(xFilial("SW6")+SW5->W5_HAWB) )
   IF SW6->( EMPTY(W6_CHEG) )
      IF SW6->W6_DT_EMB >= dDataBase
         DIni:= SW6->W6_DT_EMB
         cObs:=STR0019+DTOC(SW6->W6_DT_EMB) //"EMBARQUE CONFIRMADO PARA "
      ENDIF
   ENDIF
ENDIF            

SB1->( DBSetOrder(1) )   // PLB 26/09/06

IF ! SB1->( DBSEEK(xFilial("SB1")+SW5->W5_COD_I) )
   cDesc:=STR0020 //"ITEM NAO CADASTRADO NO ARQUIVO SB1 (W5)"
ELSE
   cDesc := SB1->B1_DESC //MSMM(SB1->B1_DESC_P,36,1)       // GFP - 01/03/2013
ENDIF                 

DIni := SW5->W5_DT_EMB //SW6->W6_DT_EMB // GFP - 22/10/2012
          
//DFS - 02/09/10 - Inclusão de tratamento para deixar zerado o campo Prazo caso a data de embarque não esteja preenchida. 
If !EMPTY(SW5->W5_DT_EMB)  //SW6->W6_DT_EMB)  // GFP - 22/10/2012
   IF DIni < dDataBase                                 //NCF - 11/05/09
      IF cDias = "Úteis"
         nPrazo:=Dias_Uteis(DIni,dDataBase)
      ELSE
         nPrazo:=Dias_Corridos(DIni,dDataBase)
      ENDIF 
   ENDIF
Else 
   nPrazo := 0
Endif    

SW2->(DBSEEK(xFilial("SW2")+SW5->W5_PO_NUM))
SY1->(DBSEEK(xFilial("SY1")+SW2->W2_COMPRA))
SA2->(DBSEEK(xFilial("SA2")+SW5->W5_FORN+EICRetLoja("SW5","W5_FORLOJ")))

TRB->(DBAPPEND())
TRB->XX_FLAGWIN := cMarca

TRB->WKFILIAL   := SW5->W5_FILIAL
TRB->W5_PO_NUM  := SW5->W5_PO_NUM
TRB->W5_COD_I   := SW5->W5_COD_I
TRB->B1_DESC    := cDesc
TRB->W5_SALDO_Q := SW5->W5_SALDO_Q
TRB->W2_COMPRA  := SW2->W2_COMPRA
TRB->Y1_NOME    := SY1->Y1_NOME
TRB->W5_FORN    := SW5->W5_FORN

IF EICLOJA()
   TRB->W5_FORLOJ := SW5->W5_FORLOJ
ENDIF

TRB->A2_NREDUZ  := SA2->A2_NREDUZ
TRB->W5_DT_EMB  := SW5->W5_DT_EMB
TRB->W4_PRAZO   := nPrazo
TRB->W4_ORDEM   := STR(99999-TRB->W4_PRAZO,5,0) //THTS - 07/11/2017 - Campo para ser utilizado no IndRegua. Determina a ordem dos registros
TRB->W5_OBS     := cObs

IF(lSeal,ExecBlock("IC193TR1",.F.,.F.,"2"),) //AWR 01/10/1999

IF SW5->W5_FLUXO="1"
   IF SWP->(DBSEEK(xFilial("SWP")+SW5->W5_PGI_NUM+SW5->W5_SEQ_LI) )
      TRB->WP_VENCTO  := SWP->WP_VENCTO
   ENDIF
ENDIF

// A chamada a seguir e para intervencoes na gravacao
IF(lExisteRD,ExecBlock("EICPFUP1_AP5",.F.,.F.,"1"),) //JS 19/08/2000

If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250GRAVA"),)  // EOB - 19/01/10

RETURN TRB->W4_PRAZO

*--------------------*
FUNCTION TR250Carta()
*--------------------*
LOCAL aTermos:= {}, nIdioma, bImp
LOCAL lMarcados := .F., nVolta, oDlgIdioma

TRB->(dbGoTop())
TRB->(dbEval({|| lMarcados := .T.}, {||IsMark("XX_FLAGWIN",cMarca,lInverte)}, {|| !lMarcados}))

IF ! lMarcados
   Help("", 1, "AVG0000606")//"Não há registros selecionados para a impresssão !"###"Atenção"
   Return (NIL)
ENDIF

DEFINE MSDIALOG oDlgIdioma  FROM 9,10 TO 17,42  TITLE STR0023 //"Seleção"

   @  8,10 TO 48,80  LABEL STR0024  OF oDlgIdioma  PIXEL //"Selecione o Idioma"

   nVolta:=0

   @ 18,13 RADIO oRadio1 VAR nIdioma ITEMS STR0025,STR0026 3D SIZE 45,13 PIXEL ;  //75,9 //"Inglês"###"Português"
                                                                OF oDlgIdioma

   DEFINE SBUTTON FROM 10,90 TYPE 1 ACTION (nVolta:=1,oDlgIdioma:End()) ENABLE OF oDlgIdioma PIXEL
   DEFINE SBUTTON FROM 37,90 TYPE 2 ACTION (oDlgIdioma:End()) ENABLE OF oDlgIdioma PIXEL

ACTIVATE MSDIALOG oDlgIdioma CENTERED

IF nVolta#1
   Return
ENDIF

aadd(aTermos, {"URGENT",""})
aadd(aTermos, {STR0027,""}) //"         PLEASE INFORM US THE SHIPPING SCHEDULE FOR THE ABOVE MENTIONED"
aadd(aTermos, {"",""})
aadd(aTermos, {"         ORDER.",""})
aadd(aTermos, {"",""})
aadd(aTermos, {STR0028,""}) //"         IF THIS ORDER WAS ALREADY DISPATCHED, PLEASE SEND US  URGENTLY"
aadd(aTermos, {"",""})
aadd(aTermos, {STR0029,""}) //"         COPY OF SHIPPING DOCUMENTS BY FAX."
aadd(aTermos, {"",""})
aadd(aTermos, {STR0030,""}) //"         WE ARE LOOKING FORWARD TO HEAR FROM YOU."
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {STR0031,""}) //"         THANKS AND BEST REGARDS."
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"         "+EasyGParam("MV_DEPTO_I"),""})

aTermos[1,2] :="URGENTE"
aTermos[2,2] :=STR0032 //"         FAVOR INFORMAR-NOS SOBRE A DATA DE EMBARQUE OU ENVIAR-NOS OS"
aTermos[4,2] :=STR0033 //"         DOCUMENTOS DE EMBARQUE REFERENTES A OCI ACIMA MENCIONADA."
aTermos[7,2] :=STR0034 //"         EM CASO DE DÚVIDAS OU PROBLEMAS, FAVOR CONTATAR-NOS."
aTermos[14,2]:=STR0035 //"         ATENCIOSAMENTE,"
aTermos[20,2]:="         "+EasyGParam("MV_DEPTO_P")

SW2->(DBSETORDER(1))
SY1->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SYT->(DBSETORDER(1))

TRB->(DBGOTOP())

AVPRINT oPrn NAME cCadastro+IF(!EMPTY(cImportador),STR0036+SUBSTR(cTitulo,8),"/"+alltrim(cTitulo)) //"/Imp."

   DEFINE FONT oFont1  NAME "Times New Roman"    SIZE 0,24  BOLD UNDERLINE  OF oPrn
   DEFINE FONT oFont2  NAME "Times New Roman"    SIZE 0,14                  OF oPrn

   lNovaPag:=.f.

   AVPAGE

     aPOAux:={}
     Linha := 0
     bImp  := {||TR250ImpCarta(aTermos,nIdioma)}
     TRB->(DBGOTOP())
     Processa({||ProcRegua(TRB->(Easyreccount("TRB"))),TRB->(DBEVAL(bImp))},"Impressao")

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()

RETURN NIL

*----------------------------------------------------------------------------*
Function TR250ImpCarta(aTermos,nIdioma) //AWR 10/05/1999
*----------------------------------------------------------------------------*
LOCAL I

IncProc(STR0037+ALLTRIM(TRB->W5_PO_NUM)) //'Imprimindo P.O.: '

IF ! IsMark("XX_FLAGWIN",cMarca,lInverte) .OR. ASCAN(aPOAux,TRB->W5_PO_NUM) # 0
   Return .F.
ENDIF

AADD(aPOAux,TRB->W5_PO_NUM)

IF lNovaPag
   AVNEWPAGE
ENDIF

lNovaPag:=.T.

SW2->(DBSEEK(xFilial("SW2")+TRB->W5_PO_NUM))
SY1->(DBSEEK(xFilial("SY1")+TRB->W2_COMPRA))
SA2->(DBSEEK(xFilial("SA2")+TRB->W5_FORN+EICRetLoja("TRB","W5_FORLOJ")))
SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))

PrintCab(oPrn,TRB->W5_PO_NUM,1,@Linha,nidioma)

oPrn:Say( Linha+=180 , 1240 , aTermos[1,nidioma] , TIMES_NEW_ROMAN_24_UNDERLINE,,,,2 )

Linha+=150

oPrn:oFont := TIMES_NEW_ROMAN_14

aTermos[18,nidioma]:="         "+SY1->Y1_NOME

FOR I=2 TO LEN(aTermos)
    oPrn:Say( Linha+=50, 100, aTermos[i,nidioma])
NEXT

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR255 ³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 18.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Follow-Up de Documentos                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR255()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*------------------
Function EICTR255
*------------------

LOCAL nPrazoMed:=0, nOldArea:=SELECT(), oGet , i

Private aCampos:={"W6_HAWB","W2_PO_NUM","W2_COMPRA","Y1_NOME",;
                  "W7_FORN","A2_NOME","W2_TIPO_EM","YQ_DESCR"}, nOpca:=0
PRIVATE cCadastro := OemtoAnsi(STR0038), nIdioma //"Follow Up Documentos"
PRIVATE cMarca := GetMark(), lInverte := .F., TB_Campos:={}
Private aHeader[0], cTitulo, cImportador
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
Private cDias := ""
EICAddLoja(aCampos,"W7_FORLOJ", Nil, "W7_FORN")
Private oPanel, aCposTRB := {} //DRL 07/07/10
Private lDlgFilCusto := .F. //DRL 23/06/10 - Caso o Dialog do Filtro Seja Customizado
AADD(TB_Campos,{"XX_FLAGWIN",,""})
AADD(Tb_Campos,{{||TRB->WKFILIAL+'-'+AvgFilName({TRB->WKFILIAL})[1]},"",AVSX3("W2_FILIAL",5)})
AADD(TB_Campos,{{||TRB->W6_HAWB}     ,"",AVSX3("W6_HAWB",5)}) //"P.O."
AADD(TB_Campos,{{||TRB->W2_PO_NUM}   ,"",STR0039,_PictPO}) //"P.O."
AADD(TB_Campos,{{||TRB->Y1_NOME}     ,"",STR0040,""}) //"Comprador"
AADD(TB_Campos,{{||TRB->A2_NOME}     ,"",STR0041,""}) //"Fornecedor"
AADD(TB_Campos,{{||TRB->W6_DT_EMB}    ,"",STR0066,""}) //"Dt. Emb"
AADD(TB_Campos,{{||TRB->W6_PRAZO}    ,"",STR0005,""}) //"Prazo"
AADD(TB_Campos,{{||TRB->W2_TIPO_EM}  ,"",STR0064,""}) //"Via"
AADD(TB_Campos,{{||TRB->YQ_DESCR}  ,"",STR0065+STR0064,""}) //"Via"
aCposTRB := { {"WKFILIAL","C", 2,0},{"W6_PRAZO","N", 5,0},{"XX_FLAGWIN","C",2,0}, {"W6_DT_EMB", "D",8,0}} //DRL 07/07/10
If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255CAMPOS"),)  // EOB - 19/01/10

cNomArq := E_CriaTrab(,aCposTRB) //DRL 07/07/10
                                                 
AADD(aHeader,{STR0005 ,"W6_PRAZO",E_TrocaVP(nIdioma,"@E 99,999"),05,0," ","   ","N",," "}) //"Prazo"

IndRegua("TRB",cNomArq+TEOrdBagExt(),"WKFILIAL+W2_PO_NUM")

WHILE .T.

   aFilSW5:=AvgSelectFil(.T.,"SW5")    //CDS 11/01/05
   IF aFilSW5[1] == "WND_CLOSE"    	
      EXIT    
   ENDIF
   
   nPrazoMed:=0
   lBrowseFil:=.F.   

   SX2->(DBSetOrder(1))
   SX2->(DBSeek("SYT"))   
   If !SX2->(Eof()).and.FWModeAccess("SYO",3) =="E"
      lBrowseFil:=.T.
      ccpo:="YT_COD_IMP"

      bCampo:={||IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",STR0063,WorkFil->(FIELDGET(FIELDPOS(ccpo))))}
                 
      aTB_Campos:={{bCampo,"",AVSX3(ccpo,5) } }
            
      aDBF:= { {ccpo,AVSX3(ccpo,2),AVSX3(ccpo,3),AVSX3(ccpo,4)} }
      bMarca:={||IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",SPACE(AVSX3(ccpo,3)),WorkFil->(FIELDGET(FIELDPOS(ccpo)))),TR250GET(@cImportador,@cTitulo)}

      aRetMarcados:={ccpo}
         
      aMarcados:=AvgMBrowseFil("","",aFilSW5,aTb_Campos,"",aDBF,bMarca,aRetMarcados)
	     
      IF EMPTY(aMarcados)   // Nao marcou nenhum ou cancelou ??
         EXIT
      ENDIF 
      
	elseif !lDlgFilCusto .And. ! E_GetImp(@cImportador,@cTitulo,@cDias,.T.)
      EXIT
   ENDIF
   
   lLoop := .F. //DRL 07/07/10 - Caso o Dlg Customizado retorna falso
   If EasyEntryPoint("EICTR255") //DRL 07/07/10
      ExecBlock("EICTR255",.F.,.F.,"TR255DIALOG_CUSTO") //DRL 07/07/10 - Caso Seja um Dialog Customizado
   EndIf
   
   If lLoop //DRL 07/07/10
      LOOP
   ENDIF
   
   IF(!lBrowseFil,aMarcados:=ACLONE(aFilSW5),)       
   
   TRB->(avzap())
   cSvFilAnt:=cFilant   
   For i:=1 to len(aMarcados)         
      aTemp:=aMarcados[i]
      cFilSel:=IF(lBrowseFil,aTemp[1],aTemp)
      If !Empty(aFilSW5[i])  //ASK
         cFilAnt:=cFilSel
      EndIf
      IF(lBrowseFil,cImportador:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1]),)  
         
      Processa({|| TR250TRB(@nPrazoMed) } )
   NEXT
   cFilAnt:=cSvFilAnt
      
   IF TRB->(Easyreccount("TRB")) > 0
      nPrazoMed:=INT((nPrazoMed/TRB->(Easyreccount("TRB")) * 100)/100)
   ELSE
      Help("", 1, "AVG0000604")//"Não há registros para visualização !"###"Informação"
      nPrazoMed:=0
      LOOP
   ENDIF

   AADD(aCampos,"W6_PRAZO")

   If ValType(nPrazoMed) = "N"
      nPrazoMed:=Padl(nPrazoMed,4,"0")
   Endif

   cRel:=STR0010 //"1 - Carta"
   lEmbarque:= .F.
   SYT->(DBSEEK(xFilial("SYT")+cImportador))

   DO WHILE .T.
   
      dbSelectArea("TRB")
      dbGoTop()
      nOpca:=0
      
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE cCadastro+IF(lBrowseFil,""," - "+OemToAnsi(cTitulo)+;
             IF(!EMPTY(cImportador)," - "+SYT->YT_NOME_RE,""))  ;
         From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

         oGet:=MsSelect():New("TRB","XX_FLAGWIN",,TB_Campos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
         oGet:oBrowse:lCanAllMark:=.t.
         oGet:oBrowse:lHasmark:=.t.
         @00,00 MsPanel oPanel Prompt "" Size 60,25 of oDlg  //LRL 26/04/04 - Painel p/ alinhamento MDI
         @ .8 ,0.8  SAY   OemToAnsi(STR0011) of oPanel //"Prazo M‚dio"
         @ .8 ,  6  MSGET nPrazoMed WHEN .F. SIZE 21,8 of oPanel  centered
         @ .8 ,15.5 SAY   OemToAnsi(STR0012) SIZE 25,8 of oPanel //"ImpressÆo"
         @ .8 ,020  COMBOBOX oCbx VAR cRel ITEMS {"1 - Carta","2 - Itens"} SIZE 40,50 OF oPanel

         DEFINE SBUTTON FROM 08,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (nOpca:=2,oDlg:End()) ENABLE OF oPanel //DRL 07/07/10
         If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255CABEC_TELA"),) //DRL 07/07/10
		 
		 oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT           
         oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()})) //LRL 26/04/04  //ALinhamento MDI

      IF nOpca == 2
         IF(cRel="1",TR255Carta(),TR250Item())
         LOOP
      ENDIF

      EXIT

   ENDDO

   IF nOpca == 0
      EXIT
   ENDIF

ENDDO

TRB->(E_EraseArq(cNomArq))
DBSELECTAREA(nOldArea)

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR255Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 18.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR255Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICTR255                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION TR255Grava(cImportador)

LOCAL dIni, nPrazo:=0

SW7->( DBSEEK(xFilial("SW7")+SW6->W6_HAWB) )
IF SW7->(EOF())
   RETURN nPrazo
ENDIF

SW2->( DBSEEK(xFilial("SW2")+SW7->W7_PO_NUM) )
IF SW2->(EOF())
   RETURN nPrazo
ENDIF

IF (!EMPTY(cImportador) .AND. SW2->W2_IMPORT # cImportador )
   RETURN nPrazo
ENDIF

TRB->( DBSEEK(SW7->W7_PO_NUM) )
IF ! TRB->(EOF())
   RETURN nPrazo
ENDIF

lLoop := .F. //DRL 07/07/10
If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255VALID_GRAVA"),)  //DRL 07/07/10
If lLoop //DRL 07/07/10
   Return nPrazo
EndIf                 

DIni := SW5->W5_DT_EMB //SW6->W6_DT_EMB // GFP - 22/10/2012

//DFS - 02/09/10 - Inclusão de tratamento para deixar zerado o campo Prazo caso a data de embarque não esteja preenchida. 
If !EMPTY(SW5->W5_DT_EMB)  //SW6->W6_DT_EMB)  // GFP - 22/10/2012
   IF DIni < dDataBase     //NCF - 11/05/09
      IF cDias = "Úteis"
         nPrazo:=Dias_Uteis(DIni,dDataBase)
      ELSE
         nPrazo:=Dias_Corridos(DIni,dDataBase)
      ENDIF  
   EndIf
Else
   nPrazo := 0 
EndIf

SY1->(DBSEEK(xFilial("SY1")+SW2->W2_COMPRA))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")))
SYQ->(dbSetOrder(1))
SYQ->(dbSeek(xFilial("SYQ")+SW2->W2_TIPO_EM))

TRB->(DBAPPEND())
TRB->XX_FLAGWIN := cMarca
TRB->WKFILIAL   := SW6->W6_FILIAL
TRB->W6_HAWB    := SW6->W6_HAWB
TRB->W2_PO_NUM  := SW2->W2_PO_NUM
TRB->W2_COMPRA  := SW2->W2_COMPRA
TRB->Y1_NOME    := SY1->Y1_NOME
TRB->W7_FORN    := SW7->W7_FORN

IF EICLOJA()
   TRB->W7_FORLOJ := SW7->W7_FORLOJ
ENDIF

TRB->A2_NOME    := SA2->A2_NOME
TRB->W6_DT_EMB  := SW6->W6_DT_EMB
TRB->W6_PRAZO   := nPrazo
TRB->W2_TIPO_EM := SW2->W2_TIPO_EM 
TRB->YQ_DESCR   := SYQ->YQ_DESCR
If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255GRAVA"),)  // EOB - 19/01/10

RETURN TRB->W6_PRAZO

*--------------------*
FUNCTION TR255Carta()
*--------------------*
LOCAL aTermos:= {}, nIdioma, bImp
LOCAL lMarcados := .F., nVolta, oDlgIdioma

TRB->(dbGoTop())
TRB->(dbEval({|| lMarcados := .T.}, {||IsMark("XX_FLAGWIN",cMarca,lInverte)}, {|| !lMarcados}))

IF ! lMarcados
   Help("", 1, "AVG0000606")//"Não há registros selecionados para a impresssão !"###"Atenção"
   Return (NIL)
ENDIF

DEFINE MSDIALOG oDlgIdioma  FROM 9,10 TO 17,42  TITLE STR0023 //"Seleção"

   @  8,10 TO 48,80  LABEL STR0024  OF oDlgIdioma  PIXEL //"Selecione o Idioma"

   nVolta:=0

   @ 18,13 RADIO oRadio1 VAR nIdioma ITEMS STR0025,STR0026 3D SIZE 45,13 PIXEL ;  //75,9 //"Inglês"###"Português"
                                                                OF oDlgIdioma

   DEFINE SBUTTON FROM 10,90 TYPE 1 ACTION (nVolta:=1,oDlgIdioma:End()) ENABLE OF oDlgIdioma PIXEL
   DEFINE SBUTTON FROM 37,90 TYPE 2 ACTION (oDlgIdioma:End()) ENABLE OF oDlgIdioma PIXEL

ACTIVATE MSDIALOG oDlgIdioma CENTERED

IF nVolta#1
   Return
ENDIF

aadd(aTermos, {"URGENT",""})
aadd(aTermos, {STR0042,""}) //"         Dear Mr. / Mrs."
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {STR0043,""}) //"         We are still waiting for the original set of documents, which would allow us to clear the material"
aadd(aTermos, {STR0044,""}) //"         covered by the above mentioned order."
aadd(aTermos, {"",""})
aadd(aTermos, {STR0045,""}) //"         Please let us know the courier details, as soon as just possible."
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {STR0046,""}) //"         Thank you"
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {"",""})
aadd(aTermos, {STR0047,""}) //"         Import Dept."

aTermos[1,2] :="URGENTE"
aTermos[2,2] :=STR0048 //"         Prezado(a) Sr(a)."
aTermos[5,2] :=STR0049 //"         Pedimos a gentileza  de  nos  informar  a respeito   da  situacao   de  encaminhamento dos "
aTermos[6,2] :=STR0050 //"         documentos originais  do  processo  acima  mencionado, não recebemos os mesmos."
aTermos[8,2] :=STR0051 //"         Aguardamos dados do courier, assim que possível."
aTermos[12,2]:=STR0035 //"         Atenciosamente,"
aTermos[18,2]:=STR0052 //"         Departamento de Importação"

SW2->(DBSETORDER(1))
SY1->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SYT->(DBSETORDER(1))

TRB->(DBGOTOP())

AVPRINT oPrn NAME STR0053+IF(!EMPTY(cImportador),STR0036+SUBSTR(cTitulo,8),"/"+alltrim(cTitulo)) //"Follo-up de Documentos"###"/Imp."

   DEFINE FONT oFont1  NAME "Times New Roman"    SIZE 0,24  BOLD UNDERLINE  OF oPrn
   DEFINE FONT oFont2  NAME "Times New Roman"    SIZE 0,14                  OF oPrn

   lNovaPag:=.f.

   AVPAGE

     Linha := 0
     bImp  := {||TR255ImpCarta(aTermos,nIdioma)}
     TRB->(DBGOTOP())
     Processa({||ProcRegua(TRB->(Easyreccount("TRB"))),TRB->(DBEVAL(bImp))},STR0054) //"Impressao"

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()


RETURN NIL

*----------------------------------------------------------------------------*
Function TR255ImpCarta(aTermos,nIdioma) //AWR 10/05/1999
*----------------------------------------------------------------------------*
LOCAL I
IncProc(STR0037+ALLTRIM(TRB->W2_PO_NUM)) //'Imprimindo P.O.: '

IF ! IsMark("XX_FLAGWIN",cMarca,lInverte)
   Return .F.
ENDIF

IF lNovaPag
   AVNEWPAGE
ENDIF

lNovaPag:=.T.

SW2->(DBSEEK(xFilial("SW2")+TRB->W2_PO_NUM))
SY1->(DBSEEK(xFilial("SY1")+TRB->W2_COMPRA))
SA2->(DBSEEK(xFilial("SA2")+TRB->W7_FORN+EICRetLoja("TRB","W7_FORLOJ")))
SYT->(DBSEEK(xFilial("SYT")+SW2->W2_IMPORT))

PrintCab(oPrn,TRB->W2_PO_NUM,1,@Linha)
oPrn:Say( Linha+=180 , 1240 , aTermos[1,nidioma] , TIMES_NEW_ROMAN_24_UNDERLINE,,,,2 )
Linha+=150

oPrn:oFont := TIMES_NEW_ROMAN_14

aTermos[16,nidioma]:="         "+SY1->Y1_NOME

FOR I=2 TO LEN(aTermos)
   oPrn:Say( Linha+=50, 100, aTermos[i,nidioma])
NEXT

Return .T.

*----------------------*
Function TR250Item() //AWR 10/05/1999
*----------------------*
#DEFINE COURIER_07 oFont1
#DEFINE COURIER_10 oFont3

LOCAL lMarcados := .F., nCont, bImp, bfor
                              
TRB->(dbGoTop())
TRB->(dbEval({||lMarcados:=.T.}, {||IsMark("XX_FLAGWIN",cMarca,lInverte)}, {|| !lMarcados}))
TRB->(dbGoTop())

IF ! lMarcados
   Help("", 1, "AVG0000606")//"Não há registros selecionados para a impresssão !"###"Atenção"
   Return (NIL)
ENDIF

//mjb160300 PRINT oPrn NAME ""
//mjb160300     IF lEmbarque
//mjb160300        oPrn:SetLandScape()
//mjb160300     ELSE
//mjb160300        oPrn:SetPortrait()
//mjb160300     ENDIF
//mjb160300 ENDPRINT

AVPRINT oPrn NAME cCadastro+IF(!EMPTY(cImportador),"/Imp."+SUBSTR(cTitulo,8),"/"+alltrim(cTitulo))

IF lEmbarque           //mjb160300
   oPrn:SetLandScape() //mjb160300
ELSE                   //mjb160300
   oPrn:SetPortrait()  //mjb160300
ENDIF                  //mjb160300

   DEFINE FONT oFont1  NAME "Courier New" SIZE 0,07 OF  oPrn
   DEFINE FONT oFont3  NAME "Courier New" SIZE 0,10 OF  oPrn

   AVPAGE

      oPrn:oFont:=COURIER_07 
      
      FilAtu:="*"
      TRB->(DBGOTOP())
      
      nPag    := 0000
      nLin    := 9999
      nLimPage:= 2150
      nColFim := 3060
      nColIni := 0001
      nPula   := 0045
      nTam    := 30 //FDR - 05/04/13 //45-LEN(SW5->W5_COD_I)

	  IF lEmbarque

         nTamF:=6-LEN(TRB->W5_FORN)
         nCol1:=nColIni ; nCol2:=250 ; nCol3:=1000
         nCol4:=1350    ; nCol5:=1885; nCol6:=2080 
         nCol7:=2360    ; nCol8:=nColFim   
         IF(lSeal,ExecBlock("IC193TR1",.F.,.F.,"3"),) //AWR 01/10/1999
         
         If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250DEFCOLS"),)  // EOB - 19/01/10

      ELSE

         nLimPage:= 3000
         nColFim := 2300
         nCol1:=nColIni ; nCol2:=350 ; nCol3:=1220
         nCol5:=1600
         nCol4:=nColFim   

         If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255DEFCOLS"),)  // EOB - 19/01/10

      ENDIF

      nCont:=TRB->(Easyreccount("TRB"))
      bImp :={||TR250Detalhe()}
      bfor :={||IsMark("XX_FLAGWIN",cMarca,lInverte)}
      Processa({||ProcRegua(nCont), TRB->(DBEVAL(bImp,bfor)) },STR0054) //"Impressao"

      If lEmbarque //DRL 07/07/10
         If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250ANTESIMPRIME"),)  // DRL - 07/07/10
      Else
         If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255ANTESIMPRIME"),)  // DRL - 07/07/10
      EndIf
   AVENDPAGE

AVENDPRINT

// Libera da memoria o handle das fontes
oFont1:End()
oFont3:End()

RETURN .T.

*----------------*
FUNCTION TR250Cab //AWR 10/05/1999
*----------------*
LOCAL cTitulo2:=cTitulo+IF(!EMPTY(cImportador)," - "+SYT->YT_NOME_RE,"")

IF nPag # 0
   AVNEWPAGE
ENDIF

nLin:= 100
nPag:= nPag + 1

oPrn:Box(nLin,nColIni,nLin+1,nColFim)
nLin:=nLin+25

oPrn:Say(nLin,nColIni  ,SM0->M0_NOME,COURIER_10)
oPrn:Say(nLin,nColFim/2,cCadastro,COURIER_10,,,,2)
oPrn:Say(nLin,nColFim  ,STR0055+STR(nPag,8),COURIER_10,,,,1) //"Pagina..: "
nLin:=nLin+50

oPrn:Say(nLin,nColIni  ,"SIGAEIC",COURIER_10)

oPrn:Say(nLin,nColFim/2,cTitulo2,COURIER_10,,,,2)
oPrn:Say(nLin,nColFim  ,STR0056+DTOC(dDataBase),COURIER_10,,,,1) //"Emissao.: "
nLin:=nLin+50

oPrn:Box(nLin,nColIni,nLin+1,nColFim)
nLin:=nLin+40

oPrn:oFont:=COURIER_07 

IF lEmbarque

   oPrn:Say(nLin,nCol1,STR0057) //"Pedido"
   oPrn:Say(nLin,nCol2,STR0058) //"Produto"
   oPrn:Say(nLin,nCol3,STR0040) //"Comprador"
   oPrn:Say(nLin,nCol4,STR0041) //"Fornecedor"
   oPrn:Say(nLin,nCol5,STR0059) //"Vecto LI"
   oPrn:Say(nLin,nCol6,STR0060) //"Embarque"
   oPrn:Say(nLin,nCol7,STR0005,,,,,1) //"Prazo"
   oPrn:Say(nLin,nCol8,STR0006+SPACE(40-6),,,,,1) //"Status"
   IF(lSeal,ExecBlock("IC193TR1",.F.,.F.,"4"),) //AWR 01/10/1999

   If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250IMPCAB"),)  // EOB - 19/01/10


ELSE

   oPrn:Say(nLin,nCol1,STR0057) //"Pedido"
   oPrn:Say(nLin,nCol2,STR0040) //"Comprador"
   oPrn:Say(nLin,nCol3,STR0041) //"Fornecedor"
   oPrn:Say(nLin,nCol5,STR0064) //"Via"
   oPrn:Say(nLin,nCol4,STR0005,,,,,1) //"Prazo"

   If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255IMPCAB"),)  // EOB - 19/01/10

ENDIF

nLin:=nLin+30

IF lEmbarque

   oPrn:Say(nLin,nCol1,REPL("-",15))
   oPrn:Say(nLin,nCol2,REPL("-",LEN(TRB->W5_COD_I)+nTam+1))
   oPrn:Say(nLin,nCol3,REPL("-",19))
   oPrn:Say(nLin,nCol4,REPL("-",LEN(TRB->W5_FORN)+16-nTamF))
   oPrn:Say(nLin,nCol5,REPL("-",08))
   oPrn:Say(nLin,nCol6,REPL("-",08))
   oPrn:Say(nLin,nCol7,REPL("-",LEN(TRANS(TRB->W4_PRAZO,"@E 99,999"))),,,,,1)
   oPrn:Say(nLin,nCol8,REPL("-",40),,,,,1)
   
   IF(lSeal,ExecBlock("IC193TR1",.F.,.F.,"5"),) //AWR 01/10/1999

   If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250CABLIN"),)  // EOB - 19/01/10

ELSE

   oPrn:Say(nLin,nCol1,REPL("-",15))
   oPrn:Say(nLin,nCol2,REPL("-",4+40))
   oPrn:Say(nLin,nCol3,REPL("-",LEN(TRB->W7_FORN)+25))
   oPrn:Say(nLin,nCol5,REPL("-",10))
   oPrn:Say(nLin,nCol4,REPL("-",06),,,,,1)

   If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255CABLIN"),)  // EOB - 19/01/10

ENDIF

nLin:=nLin+nPula

RETURN .T.

*----------------------*
FUNCTION TR250Detalhe //AWR 10/05/1999
*----------------------*
IF nLin > (nLimPage)
   TR250Cab()
ENDIF

IF FilAtu == "*" .OR. (FilAtu <>TRB->WKFILIAL)
   oPrn:Say(nLin,nCol1,AVSX3("W2_FILIAL",5)+".: "+TRB->WKFILIAL+'-'+AvgFilName({TRB->WKFILIAL})[1]) 
   nLin:=nLin+nPula
   FilAtu:=TRB->WKFILIAL
ENDIF     


oPrn:oFont:=COURIER_07 

IF lEmbarque

   IncProc(STR0061+TRB->W5_COD_I) //'Imprimindo Item: '

   oPrn:Say(nLin,nCol1,TRB->W5_PO_NUM)
   oPrn:Say(nLin,nCol2,TRB->W5_COD_I +" "+LEFT(TRB->B1_DESC,nTam))
   oPrn:Say(nLin,nCol3,TRB->W2_COMPRA+" "+LEFT(TRB->Y1_NOME,15))
   oPrn:Say(nLin,nCol4,TRB->W5_FORN+" "+IF(EICLOJA(),TRB->W5_FORLOJ+" ","")+LEFT(TRB->A2_NREDUZ,15-nTamF))
   oPrn:Say(nLin,nCol5,DTOC(TRB->WP_VENCTO))
   oPrn:Say(nLin,nCol6,DTOC(TRB->W5_DT_EMB))
   oPrn:Say(nLin,nCol7,TRANS(TRB->W4_PRAZO,"@E 99,999"),,,,,1)
   oPrn:Say(nLin,nCol8,LEFT(TRB->W5_OBS,40),,,,,1)  
   
   IF(lSeal,ExecBlock("IC193TR1",.F.,.F.,"6"),) //AWR 01/10/1999
   
   If(EasyEntryPoint("EICTR250"),Execblock("EICTR250",.F.,.F.,"TR250IMPDET"),)  // EOB - 19/01/10


ELSE

   IncProc(STR0037+TRB->W2_PO_NUM) //'Imprimindo P.O.: '

   oPrn:Say(nLin,nCol1,TRB->W2_PO_NUM)
   oPrn:Say(nLin,nCol2,TRB->W2_COMPRA+" "+TRB->Y1_NOME)
   oPrn:Say(nLin,nCol3,TRB->W7_FORN+" "+IF(EICLOJA(),TRB->W7_FORLOJ+" ","")+LEFT(TRB->A2_NOME,40))
   oPrn:Say(nLin,nCol4,TRANS(TRB->W6_PRAZO,"@E 99,999"),,,,,1)
   oPrn:Say(nLin,nCol5,TRB->W2_TIPO_EM+" "+TRB->YQ_DESCR)
   If(EasyEntryPoint("EICTR255"),Execblock("EICTR255",.F.,.F.,"TR255IMPDET"),)  // EOB - 19/01/10

ENDIF

nLin:=nLin+nPula


RETURN .T.  

*-----------------------------*
FUNCTION TR250TRB(nPrazoMed)
*-----------------------------*
LOCAL cNomeProc:=Avsx3("W6_HAWB",5)+": "
SW2->(DBSETORDER(1))
SW6->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW6->( dbSeek(xFilial("SW6")) )

ProcRegua(SW6->(Easyreccount("SW6")))

//TRB->(avzap())
//nPrazoMed:=0

DO WHILE SW6->(!EOF()) .AND. SW6->W6_FILIAL==xFilial("SW6")

   IncProc(cNomeProc+SW6->W6_HAWB)
   // SVG - 17/03/09 - 
   IF ALLTRIM(SW6->W6_TIPOFEC) == "DA" .AND. SW2->(DBSEEK(xFilial("SW2")+LEFT("DA"+SW6->W6_DI_NUM,LEN(SW2->W2_PO_NUM))))
      SW6->(DBSKIP())
      LOOP
   EndIf	                         // SVG - 17/03/09 - 
   IF !EMPTY(SW6->W6_DTRECDO) .Or. !EMPTY(SW6->W6_DT_ENCE) .Or. !EMPTY(SW6->W6_DT_DESE) .Or. !EMPTY(SW6->W6_DT_ENTR) 
      SW6->(DBSKIP())
      LOOP
   ENDIF   
   nPrazoMed+=TR255Grava(cImportador)
   SW6->(DBSKIP())
   
ENDDO
   
//TRP - 09/11/2011 - Função Marca/Desmarca Todos
*---------------------------------------------------------------------------
FUNCTION TR250Marca()
*---------------------------------------------------------------------------
LOCAL nOp, Ind ,  nMarca, nRecno ,;
b_Grava:={||IF(nMarca,(TRB->XX_FLAGWIN:=cMarca),;
                      (TRB->XX_FLAGWIN:=SPACE(2)  ))} 


nMarca:=IF(IsMark("XX_FLAGWIN"),.F.,.T.)
nRecno:=TRB->(RECNO())
TRB->(DBGOTOP())
DBEVAL(b_Grava)
TRB->(DBGOTO(nRecno))

RETURN .T.

/*
Funcao      : TR250GrvSW6
Parametros  : -
Retorno     : -
Objetivos   : Considera registros SW6 que não possuem data de embarque
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 07/01/2013 :: 11:12
*/
*--------------------------------------------------------------------------*
FUNCTION TR250GrvSW6()
*--------------------------------------------------------------------------*
LOCAL dIni, cObs, cDesc, nPrazo:=0
Local aOrd := SaveOrd({"SW5","SW6","SW7"})

SW6->(DbGoTop())

Do While SW6->(!Eof()) .AND. SW6->W6_FILIAL == xFilial("SW6")
   If Empty(SW6->W6_DT_EMB)
      SW7->(DbSetOrder(1))
      SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
      Do While SW7->(!Eof()) .AND. SW7->W7_FILIAL == xFilial("SW7") .AND. SW7->W7_HAWB == SW6->W6_HAWB
         SW5->(DbSetOrder(3))
         SW5->(DbSeek(xFilial("SW5")+SW6->W6_PO_NUM))

         dIni := SW5->W5_DT_EMB   
         cObs := STR0067  //"AG. CONFIRMAÇÃO DE EMBARQUE"
      
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+SW7->W7_COD_I))//FDR - 03/04/13
         cDesc := SB1->B1_DESC //MSMM(SB1->B1_DESC_P,36,1)       // GFP - 01/03/2013
      
         If !EMPTY(DIni)
            IF dIni < dDataBase
               IF cDias = "Úteis"
                  nPrazo:=Dias_Uteis(dIni,dDataBase)
               ELSE
                  nPrazo:=Dias_Corridos(dIni,dDataBase)
               ENDIF 
            ENDIF
         Else 
            nPrazo := 0
         Endif    

         SW2->(DBSEEK(xFilial("SW2")+SW6->W6_PO_NUM))
         SY1->(DBSEEK(xFilial("SY1")+SW2->W2_COMPRA))
         SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")))  //SW3->W3_FORN+EICRetLoja("SW3","W3_FORLOJ")))     // GFP - 22/02/2013

         TRB->(DBAPPEND())
         TRB->XX_FLAGWIN := cMarca

         TRB->WKFILIAL   := SW7->W7_FILIAL
         TRB->W5_PO_NUM  := SW6->W6_PO_NUM
         TRB->W5_COD_I   := SW7->W7_COD_I
         TRB->B1_DESC    := cDesc
         TRB->W5_SALDO_Q := SW7->W7_SALDO_Q
         TRB->W2_COMPRA  := SW2->W2_COMPRA
         TRB->Y1_NOME    := SY1->Y1_NOME
         TRB->W5_FORN    := SW7->W7_FORN

         IF EICLOJA()
            TRB->W5_FORLOJ := SW7->W7_FORLOJ
         ENDIF

         TRB->A2_NREDUZ  := SA2->A2_NREDUZ
         TRB->W5_DT_EMB  := SW5->W5_DT_EMB
         TRB->W4_PRAZO   := nPrazo
         TRB->W5_OBS     := cObs
      
         SW7->(DbSkip())
      End Do

   EndIf
   SW6->(DbSkip())
End Do

RestOrd(aOrd,.T.)
Return