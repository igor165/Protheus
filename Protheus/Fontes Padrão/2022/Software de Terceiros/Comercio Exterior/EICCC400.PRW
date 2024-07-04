//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICCC400.ch" 
#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICCC400 ³ Autor ³ LUIZ CLAUDIO BARBOSA  ³ Data ³ 09.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Apresentação de Cambio                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICCC400()

LOCAL i:=1, nOldArea:=SELECT()

PRIVATE aRotina := { { STR0001   ,"AxPesqui" , 0 , 1},;     // "Pesquisar"
                     { STR0002   ,"CC400MANUT", 0 , 2, 0}}  // "Apresenta"

PRIVATE cCadastro := STR0003 // "Apresentação das taxas cotadas nas corretoras"
PRIVATE cMarca    := GetMark(), lInverte := .F., cFiltroSWB

SX3->(DBSETORDER(2))
PRIVATE lCposAdto:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
SX3->(DBSETORDER(1))
// lCposAdto->Se existir os cpos referente a pagto antecipado, trata Seek
// com um campo a mais  WA_PO_DI/WB_PO_DI que, nas parcelas de cambio de DI tera como 
// conteudo a letra "D".

PRIVATE aPos:= { 15,  1, 70, 315 }

SW6->(DBSETORDER(1))
DBSELECTAREA("SWB")

If ! Pergunte("EICCC2", .T.)     
   Return .T.
EndIf

cFiltroSWB := "WB_FILIAL = '"+xFilial("SWB")+"'"

/*NOPADO - THTS - 17/10/2019 - DTRADE-2683
If lCposAdto
   cFiltroSWB+=" .And. WB_PO_DI='D' "
EndIf
*/
If MV_PAR01 = 1  // Aberto
   cFiltroSWB += " .And. EMPTY(WB_DT_CONT)" // = '+Alltrim(MV_PAR01)+"'"
ElseIf MV_PAR01 = 2  // Fechado
   cFiltroSWB += " .And. ! EMPTY(WB_DT_CONT)" // = '+Alltrim(MV_PAR01)+"'"
EndIf

SET FILTER TO &cFiltroSWB

mBrowse( 6, 1,22,75,"SWB")

SET FILTER TO

DBSELECTAREA(nOldArea)

SX3->(DBSETORDER(1))

Return .T.

*------------------------------------*
Function CC400Manut(cAlias,nReg,nOpc) 
*------------------------------------*
Local aSemSX3   := { {"RECNO", "N", 7, 0},{"EID_INVOIC", "C", 15 ,0 }}
Local cAliasOld := Alias()
Local aCpos     := {}
Local aFobTot   := {}
Local _nX , i 
PRIVATE aDeletados := {}
PRIVATE cPictTaxa  := X3Picture("EID_TAXA")
PRIVATE cPictValor := AVSX3("EID_VLCORR",6)
Private nOpcA      := 0, lTRBInclui:=.T.
Private cProcesso  := Space(Len(SWB->WB_HAWB))

aCpos:= { {{|| TRB->EID_BANCO+if(SA6->(dbSeek(xFilial()+TRB->EID_BANCO+TRB->EID_AGENC+TRB->EID_NUMCON))," - "+SA6->A6_NOME,Space(Len(SA6->A6_NOME)))},,AVSX3("EID_BANCO",5)},; //"Banco"
          {"EID_AGENC"  ,,AVSX3("EID_AGENC"  ,5) },; //"AGENCIA"
          {"EID_NUMCON" ,,AVSX3("EID_NUMCON" ,5) },; //"NRO.CONTA"
          {"EID_TAXA"   ,,AVSX3("EID_TAXA"   ,5), cPictTaxa  },; //"TAXA"
          {"EID_DESP"   ,,AVSX3("EID_DESP"   ,5), cPictValor },; //"Despesa banco"
          {{|| TRB->EID_CORRET+If(SYW->(dbSeek(xFilial("SYW")+TRB->EID_CORRET))," - "+SYW->YW_NOME, Space(Len(SYW->YW_NOME)))},,AVSX3("EID_CORRET"   ,5)},;
          {"EID_VLCORR" ,,AVSX3("EID_VLCORR" ,5), cPictValor } } //"Valor de corretagem R$"

PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE aCampos:= Array(EID->(fCount()))
PRIVATE aHeader:= {}
PRIVATE nEfetiva := nNaoEfet := nTotDesp := 0
PRIVATE oPanel
cHawbPadrao   := SWB->WB_HAWB
cInvPadrao    := SWB->WB_INVOICE
cFornPadrao   := SWB->WB_FORN
dVencPadrao   := SWB->WB_DT_VEN             
nRecSWBPadrao := SWB->(RECNO())
IF EICLOJA()
   cLojaPadrao   := SWB->WB_LOJA 
ENDIF
SW6->(DBSETORDER(1))
SW6->(DBSEEK(xFilial("SW6")+SWB->WB_HAWB))

cNomeTemp := E_CriaTrab("EID",aSemSX3)  // Criacao do arquivo de Trabalho
IndRegua("TRB",cNomeTemp+TEOrdBagExt(),"EID_HAWB+EID_BANCO+EID_AGENC+EID_NUMCON+EID_CORRET")
dbSelectArea("EID")
EID->(dbSetOrder(2))
dbSeek(xFilial("EID")+SWB->WB_HAWB+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")+DTOS(SWB->WB_DT_VEN))

While !(EID->(Eof())) .And. EID->EID_HAWB == SWB->WB_HAWB .AND. SWB->WB_INVOICE == EID->EID_INVOIC .AND.;
      SWB->WB_FORN == EID->EID_FORN .and. (!EICLOJA() .OR. SWB->WB_LOJA == EID->EID_FORLOJ) .And. SWB->WB_DT_VEN == EID->EID_DT_VEN

   RecLock("TRB", .T.)
   For _nX := 1 To EID->(fCount())
       
      _xConteudo := EID->(FieldGet(_nX))
      _nPos      := TRB->(FieldPos(EID->(Field(_nX))))
      If _nPos > 0
         TRB->(FieldPut(_nPos, _xConteudo))
      EndIf

   Next
   TRB->RECNO := EID->(Recno())

   EID->(dbSkip())
EndDo
EID->(dbSetOrder(1))
oMainWnd:ReadClientCoords()

While .T.
   nOpcao := 0

   DEFINE MSDIALOG oDlg TITLE STR0004 ;  // "Taxas cotadas nas corretoras"	
   From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL   
   
   @00,00 MsPanel oPanel Prompt "" Size 60,60 of oDlg  //LRL 13/04/04 - Painel para alinamento MDI.
   M->WB_FORN    := SWB->WB_FORN
   IF EICLOJA()
      M->WB_LOJA := SWB->WB_LOJA
   ENDIF
   M->WB_INVOICE := SWB->WB_INVOICE
   M->WB_HAWB    := SWB->WB_HAWB
   M->WB_DT_CONT := SWB->WB_DT_CONT
   M->WB_CA_NUM  := SWB->WB_CA_NUM
   M->cCORRETO   := SWB->WB_CORRETO + If(SYW->(dbSeek(xFilial("SYW")+SWB->WB_CORRETO))," - "+SYW->YW_NOME, "")
   M->cBANCO     := SWB->WB_BANCO + If(SA6->(dbSeek(xFilial("SA6")+SWB->WB_BANCO  ))," - "+ SA6->A6_NOME, "")
   M->WB_CORRETO := SWB->WB_CORRETO
   M->WB_BANCO   := SWB->WB_BANCO  
   M->WB_DT      := SWB->WB_DT
   M->WB_MOEDA   := SWB->WB_MOEDA
   M->WB_FOBMOE  := SWB->WB_FOBMOE
   M->WB_DT_VEN  := SWB->WB_DT_VEN
   M->WB_CA_TX   := SWB->WB_CA_TX                                                
   M->WB_AGENCIA := SWB->WB_AGENCIA 
   M->WB_VL_CORR := SWB->WB_VL_CORR      
   If Empty(SWB->WB_DT_CONT)
     SYE->(DBSETORDER(2))
     M->nPTAX   := If(SYE->(DBSEEK(xFilial("SYE")+M->WB_MOEDA+DTOS(dDataBase))),SYE->YE_VLCON_C,0)
     SYE->(DBSETORDER(1))
   Else
 	 SYE->(DBSETORDER(2))
 	 M->nPTAX   := If(SYE->(DBSEEK(xFilial("SYE")+M->WB_MOEDA+DTOS(SWB->WB_DT_CONT))), SYE->YE_VLCON_C,0)
 	 SYE->(DBSETORDER(1))
   EndIf
   @ 05,010 Say STR0005       			             of oPanel PIXEL // "Processo:"
   @ 03,050 MSGET M->WB_HAWB   SIZE 80,08 WHEN .F.   of oPanel PIXEL
   @ 18,010 Say STR0006                              of oPanel PIXEL //"Fatura:    "
   @ 16,050 MSGET M->WB_INVOICE  SIZE 80,08 WHEN .F. of oPanel PIXEL
   @ 31,010 Say STR0007                              of oPanel PIXEL //"Dt.Fecham: "
   @ 29,050 MSGET M->WB_DT_CONT  SIZE 80,08 WHEN .F. of oPanel PIXEL
   If Empty(SWB->WB_DT_CONT)
     @ 44,010 Say STR0008                           of oPanel PIXEL //"Tx.PTax:  "
   Else                                                   
   	 @ 44,010 Say STR0009                           of oPanel PIXEL //"Tx.PTaxFech:"
   EndIf
   @ 42,050 MSGET M->nPTAX   PICTURE X3Picture("WB_CA_TX")   SIZE 80,08 WHEN .F.  of oPanel PIXEL

   @ 05,140 Say STR0010                              of oPanel PIXEL //"Nº Contrat:"
   @ 03,170 MSGET M->WB_CA_NUM   SIZE 80,08 WHEN .F. of oPanel PIXEL
   @ 18,140 Say STR0011                              of oPanel PIXEL //"Corretora: "
   @ 16,170 MSGET M->cCORRETO    SIZE 80,08 WHEN .F. of oPanel PIXEL
   @ 31,140 Say STR0012                              of oPanel PIXEL //"Banco:     "
   @ 29,170 MSGET M->cBANCO      SIZE 80,08 WHEN .F. of oPanel PIXEL
// @ 54,130 Say "Dt.Débito: "                        PIXEL
// @ 54,160 MSGET WB_DT_VEN      SIZE 80,08 WHEN .F. PIXEL
   @ 44,140 Say STR0013                              of oPanel PIXEL //"Tx.(Moeda):    "
   @ 42,170 MSGET M->WB_CA_TX   PICTURE X3Picture("WB_CA_TX")   SIZE 80,08 WHEN .F. of oPanel PIXEL


   @ 05,260 Say STR0014                              of oPanel PIXEL //"Moeda:     "
   @ 03,290 MSGET M->WB_MOEDA   SIZE 80,08 WHEN .F.  of oPanel PIXEL
   @ 18,260 Say STR0015                              of oPanel PIXEL //"Total:     "
   @ 16,290 MSGET M->WB_FOBMOE  PICTURE X3Picture("WB_FOBMOE")  SIZE 80,08 WHEN .F. of oPanel PIXEL
   @ 31,260 Say STR0016                              of oPanel PIXEL //"Vencto:    "
   @ 29,290 MSGET M->WB_DT_VEN   SIZE 80,08 WHEN .F. of oPanel PIXEL
//   @ 54,250 Say "Tx.US$:    "                        PIXEL
//   @ 54,280 MSGET M->WB_CA_TX   PICTURE X3Picture("WB_CA_TX")   SIZE 80,08 WHEN .F. PIXEL
   @ 44,260 Say STR0036                              of oPanel PIXEL //"Fornecedor    "
   @ 42,290 MSGET M->WB_FORN    SIZE 80,08 WHEN .F.  of oPanel PIXEL
   
   //by GFP - 29/09/2010 :: 11:53 - Inclusão da função para carregar campos criados pelo usuario.
   aCpos := AddCpoUser(aCpos,"EID","5","TRB")
   
   TRB->(dbGoTop())
   oMark:= MSSELECT():New("TRB",,,aCpos,@lInverte,@cMarca,{70,4,FINAL_SELECT,COLUNA_FINAL})
   
   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlg ON INIT ; 
   (CC400BarItem(oDlg,{||nOpcao := 1,oDlg:End()},{||nOpcao := 0,oDlg:End()} )) //LRL 13/04/04 - Alinhamento MDI. //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If nOpcao == 2       // *** Em processamento
     Loop
   ElseIf nOpcao == 1   // *** Clicou em Ok.
      *----------------------------------------------------------*
      * INICIO DA TRANSACAO                                      *
      *----------------------------------------------------------*

      Begin Transaction            
        SWB->(DBGOTO(nRecSWBPadrao))
        SWB->(RecLock("SWB", .F.))
        SWB->WB_CORRETO := M->WB_CORRETO
        SWB->WB_BANCO   := M->WB_BANCO   
        SWB->WB_AGENCIA := M->WB_AGENCIA 
        SWB->WB_CA_TX   := M->WB_CA_TX   
        SWB->WB_VL_CORR := M->WB_VL_CORR
        SWB->(MSUNLOCK())

         For i:=1 To Len(aDeletados)
             EID->(dbGoTo(aDeletados[i]))
             EID->(RecLock("EID",.F.))
             EID->(dbDelete())
             EID->(MSUnlock())
         Next i
         TRB->(dbGoTop())
         While TRB->(!Eof())
            IF TRB->RECNO == 0
               EID->(RecLock("EID",.T.)) // Append com lock
            ELSE
               EID->(dbGoTo(TRB->RECNO))
               EID->(RecLock("EID",.F.))
            ENDIF
            // Grava campos no EID ...
            For _nX := 1 To EID->(fCount())
               If TRB->(FieldPos(EID->(Field(_nX)))) > 0
                  _xConteudo := TRB->(FieldGet(TRB->(FieldPos(EID->(Field(_nX))))))
                  EID->(FieldPut(_nX, _xConteudo))
               EndIf
            Next
            EID->EID_FILIAL := xFilial("EID")
            EID->EID_DT_VEN := dVencPadrao
            EID->EID_INVOIC := cInvPadrao
            EID->EID_FORN   := cFornPadrao
            IF EICLOJA()
               EID->EID_FORLOJ := cLojaPadrao
            ENDIF
            TRB->(dbSkip())
         EndDo

         EvalTrigger()

      End Transaction

      *----------------------------------------------------------*
      * FIM DA TRANSACAO                                         *
      *----------------------------------------------------------*
   EndIf
   Exit
EndDo

TRB->(E_EraseArq(cNomeTemp))

dbSelectArea(cAliasOld)

Return(Nil)

*-------------------------------------------*
Static Function CC400BarItem(oDlg,bOk,bCancel)
*-------------------------------------------*
LOCAL oBar, bSet15, bSet24, lOk 
Local aButtons := {}
LOCAL bIncluir  := {|| CC400Enchoice(1), oMark:oBrowse:Refresh()}
LOCAL bAlterar  := {|| CC400Enchoice(2), oMark:oBrowse:Refresh()}
LOCAL bExcluir  := {|| CC400Enchoice(3), oMark:oBrowse:Refresh()}
LOCAL bAtualiza := {|| CC400Enchoice(4), oMark:oBrowse:Refresh(), oDlg:Refresh()}
LOCAL bCopia    := {|| CC400CopiaTx()  , oMark:oBrowse:Refresh()}

AAdd(aButtons, {"EDIT", bIncluir , STR0020, STR0020}) //MCF - 21/07/2015
AAdd(aButtons, {"EDIT", bAlterar , STR0021, STR0021})
AAdd(aButtons, {"EDIT", bExcluir , STR0022, STR0022})
AAdd(aButtons, {"EDIT", bAtualiza, STR0023, STR0023})
AAdd(aButtons, {"EDIT", bCopia   , STR0024, STR0024})

RETURN EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

*---------------------------------*
Static Function CC400Enchoice(nOpc)
*---------------------------------*
Local cTitulo:= STR0027 //"Taxas cotadas nas corretoras - "
Local cPerg, cTitMsg , nXi, _nX 
// variaveis p/ EnChoice
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE bCampo, nCampos := 0
PRIVATE lX3_WHEN := IF(nOpc==3 .Or. nOpc==4, .F., .T.)
PRIVATE oEnCh1
lTRBInclui:=.F.
If nOpc == 1
   aRotina[2,4]:=3
   cTitulo     += STR0020 //"Inclusão"
   lTRBInclui:=.T.
ElseIf nOpc == 2
   aRotina[2,4]:=4
   cTitulo     += STR0021 //"Alteração"
ElseIf nOpc == 3
   aRotina[2,4]:=4
   cTitulo     += STR0022 //"Exclusão"
   cPerg       := STR0028 //"Confirma a Exclusão ? "
   cTitMsg     := STR0029 //"Exclusão de Despesas" 
ElseIf nOpc == 4
   aRotina[2,4]:=4
   cTitulo     := STR0030 //"Taxas cotadas nas corretoras/bancos"
   cPerg       := STR0031 //"Efetiva no cambio ? "
   cTitMsg     := STR0032 //"Efetivação de taxa/corretora"
EndIf

bCampo := {|x| EID->(Field(x)) }

dbSelectArea("TRB")

If Bof() .And. Eof() .And. nOpc <> 1
   Help(" ",1,"REGNOIS")
   Return(.F.)
EndIf

While .T.
   nOpcA:=1
   FOR nXi := 1 TO EID->(FCount())
      _nPos      := TRB->(FieldPos(EID->(Field(nXi))))
      If _nPos > 0
         M->&(EVAL(bCampo,nXi)) := If(nOpc == 1, CRIAVAR(EID->(FIELDNAME(nXi))),TRB->(FieldGet(_nPos)))
         nCampos++
      EndIf
   NEXT i
   M->EID_FILIAL := xFilial("EID")
   M->EID_FORLOJ := cLojaPadrao //MCF - 21/07/2015
   If nOpc <> 1
     M->EID_FORN   := cFornPadrao
     IF EICLOJA()
        M->EID_FORLOJ := cLojaPadrao
     ENDIF
   Endif
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG Odlg1 TITLE cTitulo ;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL  
      
	  oEnch1:=MsMGet():New("EID", , 2, , , , ,{15,1,FINAL_SELECT,COLUNA_FINAL}, IF(nOpc==3 .Or. nOpc==4,{},), 3) //LRL 13/04/04 - Na V811 deve ser usado MsMGET
      oDlg1:lMaximized:=.T. //LRL 13/04/04 - Maximiliza Janela MDI
	  oEnCh1:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  
   ACTIVATE MSDIALOG Odlg1 ON INIT ;
        (EnchoiceBar(Odlg1,;
                  {|| If(nOpc >= 3,If(MsgYesNo(cPerg,cTitMsg),;
                  (nOpca := 2,Odlg1:End()),), (If(EIDVAL("TUDO"),(nOpca := 2,Odlg1:End()),)))},;
                  {|| nOpca:=1,Odlg1:End()})) //LRL 13/04/04 Alinhamento MDI      //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT    

   IF nOpcA == 2
      If nOpc == 3
			
            If TRB->RECNO != 0
               aAdd(aDeletados,TRB->RECNO)
            Endif
            dbSelectArea("TRB")
            dbDelete()
            dbskip(-1)
            IF Bof()
               dbSkip()
               If Eof()
                  Pack  // Corrige problema do browse qdo nao existe reg. valido.
               Endif
            Endif
      ElseIf nOpc == 4
         SWB->(RecLock("SWB", .F.))
         SWB->WB_CORRETO := TRB->EID_CORRET
         SWB->WB_BANCO   := TRB->EID_BANCO
         SWB->WB_CONTA   := TRB->EID_NUMCON //ASK 10/10/2007 Gravação da conta no SWB
         SWB->WB_AGENCIA := TRB->EID_AGENC
         SWB->WB_CA_TX   := TRB->EID_TAXA
         SWB->WB_VL_CORR := TRB->EID_VLCORR
         

         M->cCORRETO     := TRB->EID_CORRET+" "+If(SYW->(dbSeek(xFilial("SYW")+SWB->WB_CORRETO)), SYW->YW_NOME, "")
         M->cBANCO       := TRB->EID_BANCO +" "+If(SA6->(dbSeek(xFilial("SA6")+SWB->WB_BANCO  )), SA6->A6_NOME, "")
         M->WB_CORRETO   := TRB->EID_CORRET
         M->WB_BANCO     := TRB->EID_BANCO
         M->WB_AGENCIA   := TRB->EID_AGENC
         M->WB_CA_TX     := TRB->EID_TAXA
         M->WB_VL_CORR   := TRB->EID_VLCORR

         TRB->(dbGoTop())
         While TRB->(!Eof())
            IF TRB->RECNO == 0
               EID->(RecLock("EID",.T.)) // Append com lock
               TRB->RECNO := EID->(Recno())
            ELSE
               EID->(dbGoTo(TRB->RECNO))
               EID->(RecLock("EID",.F.))
            ENDIF
            // Grava campos no EID ...
            For _nX := 1 To EID->(fCount())
               If TRB->(FieldPos(EID->(Field(_nX)))) > 0
                  _xConteudo := TRB->(FieldGet(TRB->(FieldPos(EID->(Field(_nX))))))
                  EID->(FieldPut(_nX, _xConteudo))
               EndIf
            Next
            EID->EID_FILIAL := xFilial("EID")
            EID->EID_DT_VEN := dVencPadrao
            EID->EID_INVOIC := cInvPadrao
            EID->EID_FORN   := cFornPadrao
            IF EICLOJA()
               EID->EID_FORLOJ := cLojaPadrao
            ENDIF
            TRB->(dbSkip())
         EndDo

         TRB->(DBGOTOP())

         SWB->(MsUnLock())
      Else
         If nOpc == 1
            RecLock("TRB", .T.)
         EndIf

         For _nX := 1 To EID->(fCount()) //Len(aHeader)
            IF TRB->(FieldPos(EID->(FieldName(_nX))))  > 0 .Or. AllTrim(EID->(FieldName(_nX))) == "EID_FILIAL" //AOM - 17/12/10
               _xConteudo := "M->"+EID->(FieldName(_nX))
               _xConteudo := &_xConteudo
               _nPos      := TRB->(FieldPos(EID->(Field(_nX))))
               If _nPos > 0
                  TRB->(FieldPut(_nPos, _xConteudo))
               EndIf 
            EndIf
         Next
         
         If nOpc == 1
            Loop
         EndIf						
      EndIf      

   Endif

   Exit
End
aRotina[2,4]:=2

Return(Nil)                 

*----------------------------*
Static Function CC400CopiaTx() 
*----------------------------*
Local nRecWB := SWB->(RECNO()), cAliasCop:=Alias(), _nX
Private cCorretora := Space(Len(SWB->WB_CORRETO))
Private cInvoice   := Space(Len(SWB->WB_INVOICE))
Private cForn      := Space(Len(SWB->WB_FORN))
Private dVencimento:= CTOD("")

IF EICLOJA()
   cLoja:= Space(Len(SWB->WB_LOJA)) 
ENDIF

DbSelectArea("SWB")
SET FILTER TO 
DbSelectArea(cAliasCop)

/* ISS - 18/03/10 - Alteração do tamanho da tela para que a mesma não corte o botão "Confirmar"
DEFINE MSDIALOG oDlg3 TITLE STR0033 ; //"Copia taxas de processo"
   FROM 5,5 TO 200,380 OF oMainWnd PIXEL */  
DEFINE MSDIALOG oDlg3 TITLE STR0033 ; //"Copia taxas de processo"
   FROM 5,5 TO 300,390 OF oMainWnd PIXEL
   
   oPanel:= TPanel():New(0, 0, "", oDlg3,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT  

   @ 20,010 Say STR0005                                                  OF oPanel PIXEL //"Processo:"
   @ 20,040 MSGET cProcesso  F3 "SWB"/*"SW6"*/ VALID EIDVal("PROCESSO") SIZE 80,08 OF oPanel PIXEL
   @ 35,010 Say STR0034                                                    OF oPanel PIXEL //"Invoice:"
   @ 35,040 MSGET cInvoice                When .F.             SIZE 80,08  OF oPanel PIXEL
   @ 50,010 Say STR0036                                                    OF oPanel PIXEL //"Forncecedor:"
   @ 50,040 MSGET cForn                   When .F.             SIZE 80,08  OF oPanel PIXEL   
   
   IF EICLOJA()
       @ 65,010 Say "Loja"                                                 OF oPanel PIXEL 
       @ 65,040 MSGET cLoja               When .F.             SIZE 80,08  OF oPanel PIXEL   
   ENDIF
   
   @ 80,010 Say STR0035                                                    OF oPanel PIXEL //"Vencimento:"
   @ 80,040 MSGET dVencimento             When .F.             SIZE 80,08  OF oPanel PIXEL
   @ 95,010 Say STR0011                                                    OF oPanel PIXEL //"Corretora:"
   @ 95,040 MSGET cCorretora F3 "SYW" VALID Empty(cCorretora) .Or. ExistCpo("SYW")  SIZE 80,08 OF oPanel PIXEL

   ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3,{||If(EIDVAL("PROCESSO"),(nOpca := 2,oDlg3:End()),)}, {|| nOpca:=1,oDlg3:End()}) CENTERED

EID->(dbSetOrder(2))
IF nOpcA == 2 .And. EID->(dbSeek(xFilial("EID")+cProcesso+cInvoice+cForn+IF(EICLOJA(),cLoja,"")+DTOS(dVencimento)))

   While !(EID->(Eof())) .And. EID->EID_HAWB == cProcesso .AND. EID->EID_INVOIC == cInvoice .AND.; 
         EID->EID_DT_VEN = dVencimento .AND. EID->EID_FORN == cForn .AND. (!EICLOJA() .OR. EID->EID_FORLOJ == cLoja)
    
      If Empty(cCorretora) .Or. cCorretora == EID->EID_CORRET
         IF TRB->(DBSEEK(cHawbPadrao+EID->EID_BANCO+EID->EID_AGENC+EID->EID_NUMCON+EID->EID_CORRET))
            RecLock("TRB", .F.)
         Else
            RecLock("TRB", .T.)         
            TRB->RECNO    := 0            
         EndIf   
         For _nX := 1 To EID->(fCount())
            _xConteudo := EID->(FieldGet(_nX))
            _nPos      := TRB->(FieldPos(EID->(Field(_nX))))
            If _nPos > 0
               TRB->(FieldPut(_nPos, _xConteudo))
            EndIf
         Next
         TRB->EID_HAWB := cHawbPadrao
         TRB->EID_FORN := cFornPadrao
         IF EICLOJA()
            TRB->EID_FORLOJ := cLojaPadrao
         ENDIF
      EndIf
      EID->(dbSkip())
   EndDo
   
   M->WB_CORRETO := SWB->WB_CORRETO
   M->WB_BANCO   := SWB->WB_BANCO   
   M->WB_AGENCIA := SWB->WB_AGENCIA 
   M->WB_CA_TX   := SWB->WB_CA_TX   
   M->WB_VL_CORR := SWB->WB_VL_CORR 
   M->cCORRETO   := SWB->WB_CORRETO+" "+If(SYW->(dbSeek(xFilial("SYW")+SWB->WB_CORRETO)), SYW->YW_NOME, "")
   M->cBANCO     := SWB->WB_BANCO  +" "+If(SA6->(dbSeek(xFilial("SA6")+SWB->WB_BANCO  )), SA6->A6_NOME, "")

EndIf

SWB->(DBGOTO(nRecWB))
EID->(dbSetOrder(1))
TRB->(dbGotop())
DbSelectArea("SWB")
SET FILTER TO &cFiltroSWB
DbSelectArea(cAliasCop)
Return Nil

*--------- Retorna o valor da corretagem em R$ --------*
Function CalcCorret(cCorretora, nParcCambio, nTaxa)
*------------------------------------------------------*
Local nValor      := nParcCambio
Local nCorretagem := 0, nCalc := 0

SYW->(dbSeek(xFilial("SYW")+cCorretora))
If SYW->YW_VLR_MIN > 0 .And. nValor > 0 //.And. nValor <= SYW->YW_VLR_MIN
   nCalc       := If(nValor-SYW->YW_VLR_MIN >= 0, SYW->YW_VLR_MIN, nValor )
   nCorretagem += (nCalc * SYW->YW_PERCENT / 100)
   nValor      -= nCalc
EndIf
If SYW->YW_VLR_02 > 0 .And. nValor > 0 //SYW->YW_VLR_MIN .And. nValor <= SYW->YW_VLR_02
   nCalc       := If(nValor-SYW->YW_VLR_02 >= 0, SYW->YW_VLR_02, nValor )
   nCorretagem += (nCalc * SYW->YW_PERC_02 / 100)
   nValor      -= nCalc
EndIf
If SYW->YW_VLR_03 > 0 .And. nValor > 0 //SYW->YW_VLR_02 .And. nValor <= SYW->YW_VLR_03
   nCalc       := If(nValor-SYW->YW_VLR_03 >= 0, SYW->YW_VLR_03, nValor )
   nCorretagem += (nCalc * SYW->YW_PERC_03 / 100)
   nValor      -= nCalc
EndIf
If SYW->YW_VLR_04 > 0 .And. nValor > 0 //SYW->YW_VLR_03 .And. nValor <= SYW->YW_VLR_04
   nCalc       := If(nValor-SYW->YW_VLR_04 >= 0, SYW->YW_VLR_04, nValor )
   nCorretagem += (nCalc * SYW->YW_PERC_04 / 100)
   nValor      -= nCalc
EndIf
If SYW->YW_VLR_05 > 0 .And. nValor > 0 //.And. nParcCambio > SYW->YW_VLR_05
   nCorretagem += (nValor * SYW->YW_PERC_05 / 100)
   nValor      -= nValor
EndIf
nCorretagem := nCorretagem * nTaxa
Return(nCorretagem)

*--------------------*
Function EIDVal(cPar) 
*--------------------*
LOCAL lRet:=.T., nRecTRB:=TRB->(RECNO())

If cPar == "TUDO" .AND. !Obrigatorio(aGets,aTela)
   lRet:=.F.
EndIf          

If lRet .AND. cPar == "PROCESSO" 
   If cProcesso # SWB->WB_HAWB                  
      SWB->(DBSETORDER(1))
      If ! SWB->(DBSEEK(xFilial("SWB")+cProcesso))
         Help("", 1, "AVG0000457")//MSGSTOP("Cambio não cadastrado.")
         lRet:=.F.
      EndIf
   EndIf
   cInvoice    := SWB->WB_INVOICE
   dVencimento := SWB->WB_DT_VEN   
   cFor        := SWB->WB_FORN
   IF EICLOJA()
      cLoj     := SWB->WB_LOJA
   ENDIF
   If M->WB_MOEDA <> SWB->WB_MOEDA
     Help("", 1, "AVG0000669") // As moedas das parcelas sao diferentes .
      lRet := .F.
   Endif
   
EndIf
SA1->(DBSETORDER(1))
If lRet .AND. cPar == "BANCO" .AND. ! EMPTY(M->EID_BANCO)
   If M->EID_BANCO # SA6->A6_COD .AND. ! SA6->(Dbseek(xFilial("SA6")+M->EID_BANCO))
      Help("", 1, "AVG0000458")//MsgStop("Banco sem cadastro.")
      lRet:=.F.
   EndIf      
EndIf
        
If lRet .AND. cPar == "AGENCIA" .AND. ! EMPTY(M->EID_AGENC)
   If ! EMPTY(M->EID_BANCO) .AND. M->EID_BANCO+M->EID_AGENC#SA6->A6_COD+SA6->A6_AGENCIA .AND. ;
      ! SA6->(Dbseek(xFilial("SA6")+M->EID_BANCO+M->EID_AGENC))
      Help("", 1, "AVG0000459")//MsgStop("Banco/Agencia sem cadastro.")
      lRet:=.F.
   EndIf
EndIf
        
If lRet .AND. cPar == "CONTA" .AND. ! EMPTY(M->EID_NUMCON)
   If M->EID_BANCO+M->EID_AGENC+M->EID_NUMCON # SA6->(A6_COD+A6_AGENCIA+A6_NUMCON) .AND. ;
      ! SA6->(Dbseek(xFilial("SA6")+M->EID_BANCO+M->EID_AGENC+M->EID_NUMCON))
      Help("", 1, "AVG0000460")//MsgStop("Banco/Agencia/Conta sem cadastro.")
      lRet:=.F.        
   EndIf      
EndIf

If lRet .AND. cPar == "TUDO"
   If M->EID_BANCO+M->EID_AGENC+M->EID_NUMCON # SA6->(A6_COD+A6_AGENCIA+A6_NUMCON) .AND. ;
      ! SA6->(Dbseek(xFilial("SA6")+M->EID_BANCO+M->EID_AGENC+M->EID_NUMCON))
      Help("", 1, "AVG0000460")//MsgStop("Banco/Agencia/Conta sem cadastro.")
      lRet:=.F.        
   EndIf      
EndIf

If lRet .AND. cPar # "PROCESSO" .AND. ! EMPTY(ALLTRIM(M->EID_HAWB+M->EID_BANCO+M->EID_AGENC+M->EID_NUMCON+M->EID_CORRET))
   If TRB->(DBSEEK(cHawbPadrao+M->EID_BANCO+M->EID_AGENC+M->EID_NUMCON+M->EID_CORRET))
      Do While cHawbPadrao+M->EID_BANCO+M->EID_AGENC+M->EID_NUMCON+M->EID_CORRET = ;
               TRB->EID_HAWB+TRB->EID_BANCO+TRB->EID_AGENC+TRB->EID_NUMCON+TRB->EID_CORRET 
         If lTRBInclui .OR. TRB->(RECNO()) # nRecTRB
            Help("", 1, "AVG0000461")//MSGSTOP("Corretor e Banco já cadastrados para este câmbio.")
            lRet:=.F.
         EndIf
         TRB->(DBSKIP())
      EndDo
   EndIf
EndIf              
TRB->(DBGOTO(nRecTRB))
Return(lRet)        
