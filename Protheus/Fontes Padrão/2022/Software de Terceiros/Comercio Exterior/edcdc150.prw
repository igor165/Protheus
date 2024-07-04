#INCLUDE "EDCDC150.CH"
#INCLUDE "AVERAGE.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2

/*
Programa        : EDCDC150.PRW
Objetivo        : Manutenção das descrições de DI/RE
Autor           : Gustavo Carreiro
Data/Hora       : 
Obs.            : 
*/


*-----------------------------------------------------------------------------------------------*
Function EDCDC150a()
*-----------------------------------------------------------------------------------------------*
Local oDlg, nOp:=0, aBotao:={}
Private cMarca := GetMark(), lInverte := .F., cPedido:=Space(Len(SW6->W6_HAWB))
Private oMark, cFilSW8:=xFilial("SW8"), aSelCpos:={}, cFilSB1:=xFilial("SB1")
Private oPanel //LRL 25/05/04
oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o programa todo

DC150Works("IMP")

Aadd(aBotao,{"EDIT",{|| Processa({|| DC150ImpDesc()},STR0001) },STR0001,STR0009}) // //"Altera Descrição"###"Altera Descrição" -  "Descricäo"

DEFINE MSDIALOG oDlg TITLE STR0002 FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO ; //"Manutenção de Descrições"
oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
   @00,00 MsPanel oPanel Prompt "" Size 60,20 of oDlg   //LRL 25/05/04
   @0.5,02 SAY   STR0003   of oPanel //"Processo"
   @0.5,08 MSGET cPedido  PICT AVSX3("ED0_PD",6) F3 "HAW" VALID MsAguarde({|| DC150GrvWorks("IMP")}, STR0004)  SIZE 60,8 OF oPanel //"Carregando Itens"

   nLinha := (oDlg:nClientHeight-6)/2
   oMark:= MsSelect():New("WorkIMP",,,aSelCpos,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL})
   oMark:bAval:={|| DC150ImpDesc()}
   
   
   oPanel:Align:=CONTROL_ALIGN_TOP            //LRL 25/05/04 //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   
   

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()},,aBotao))//Alinhamento MDI //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
WorkIMP->(dbCloseArea())

Return .T.

*-----------------------------------------------------------------------------------------------*
Function EDCDC150b()
*-----------------------------------------------------------------------------------------------*
Local nOp:=0, aBotao:={}
Private cFilSB1 := xFilial("SB1")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1"
Private cMarca := GetMark(), lInverte := .F., cPedido:=Space(Len(EEC->EEC_PREEMB))
Private oMark, aSelCpos:={}
Private oPanelb //LRL 25/05/04
If AmIin(50)
   If Select("SB1EXP") = 0
      lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
   Else
      lAbriuExp := .T.
   Endif
   If lAbriuExp
      Help(" ",1,"AVG0005294") //Essa opção não pode ser executada nesse módulo!###Utilizar essa Opção no Módulo da Exportação
      Return .F.
   Endif
Endif   

oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o programa todo

DC150Works("EXP")

Aadd(aBotao,{"EDIT",{|| Processa({|| DC150ExpDesc()},STR0001) },STR0001,STR0009}) // //"Altera Descrição"###"Altera Descrição" - "Descricäo"

DEFINE MSDIALOG oDlg TITLE STR0002 FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO ; //"Manutenção de Descrições"
oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
   @00,00 MsPanel oPanelb Prompt "" Size 60,20 of oDlg   //LRL 25/05/04
   @0.5,02 SAY   STR0005   of oPanelB //"Embarque"
   @0.5,08 MSGET cPedido  PICT AVSX3("ED0_PD",6) F3 "EEC" VALID MsAguarde({|| DC150GrvWorks("EXP")}, STR0004) SIZE 60,8 of oPanelb//"Carregando Itens"

   nLinha := (oDlg:nClientHeight-6)/2
   oMark:= MsSelect():New("WorkEXP",,,aSelCpos,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL})
   oMark:bAval:={|| DC150ExpDesc()}
   
   oPanelB:Align:=CONTROL_ALIGN_TOP            //LRL 25/05/04 //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()},,aBotao))//Alinhamento MDI //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
WorkEXP->(dbCloseArea())
EE9->(dbSetOrder(1))

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function DC150Works(cModulo)
*----------------------------------------------------------------------------------------------*
Local aSemSX3DI:={}, aSemSX3RE:={}, FWorkDI, FWorkRE

If cModulo == "IMP"
   AADD(aSemSX3DI,{"ITEM","C",AVSX3("ED2_ITEM",3),0})
   AADD(aSemSX3DI,{"NCM","C",AVSX3("ED2_NCM",3),0})
   AADD(aSemSX3DI,{"QTD","N",AVSX3("ED2_QTD",3),AVSX3("ED2_QTD",4)})
   AADD(aSemSX3DI,{"VALOR","N",AVSX3("ED2_VALEMB",3),AVSX3("ED2_VALEMB",4)})
   AADD(aSemSX3DI,{"DI_NUM","C",AVSX3("ED2_DI_NUM",3),0})
   AADD(aSemSX3DI,{"ADICAO","C",AVSX3("ED2_ADICAO",3),0})
   AADD(aSemSX3DI,{"INVOICE","C",AVSX3("ED2_INVOIC",3),0})
   AADD(aSemSX3DI,{"REC","N",10,0})
   //TRP - 03/02/07 - Campos do WalkThru
   AADD(aSemSX3DI,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3DI,{"TRB_REC_WT","N",10,0})
  
   FWorkDI := E_CriaTrab(, aSemSX3DI, "WorkIMP")
   IndRegua("WorkIMP",FWorkDI+TEOrdBagExt(),"ITEM+NCM")
   SET INDEX TO (FWorkDI+TEOrdBagExt())
   
   aSelCpos:= {  {"ITEM"   ,,AVSX3("ED2_ITEM",5)},;
                 {"NCM"    ,,AVSX3("ED2_NCM",5),AVSX3("ED2_NCM",6)},;
                 {"QTD"    ,,AVSX3("ED2_QTD",5),AVSX3("ED2_QTD",6)},;
                 {"VALOR"  ,,AVSX3("ED2_VALEMB",5),AVSX3("ED2_VALEMB",6)},;
                 {"DI_NUM" ,,AVSX3("W6_DI_NUM",5),AVSX3("W6_DI_NUM",6)},;
                 {"ADICAO" ,,AVSX3("W8_ADICAO",5),AVSX3("W8_ADICAO",6)},;
                 {"INVOICE",,AVSX3("W9_INVOICE",5),AVSX3("W9_INVOICE",6)} }
   
   SW8->(dbSetOrder(1))
   SW6->(dbSetOrder(1))
   SB1->(dbSetOrder(1))
   
Else
   AADD(aSemSX3RE,{"PROD","C",AVSX3("ED1_PROD",3),0})
   AADD(aSemSX3RE,{"NCM","C",AVSX3("ED1_NCM",3),0})
   AADD(aSemSX3RE,{"QTD","N",AVSX3("EE9_SLDINI",3),AVSX3("EE9_SLDINI",4)})
   AADD(aSemSX3RE,{"VALOR","N",AVSX3("ED1_VL_MOE",3),AVSX3("ED1_VL_MOE",4)})
   AADD(aSemSX3RE,{"RE","C",AVSX3("ED1_RE",3),0})
   AADD(aSemSX3RE,{"PREEMB","C",AVSX3("ED1_PREEMB",3),0})
   AADD(aSemSX3RE,{"PEDIDO","C",AVSX3("ED1_PEDIDO",3),0})
   AADD(aSemSX3RE,{"SEQUEN","C",AVSX3("ED1_SEQUEN",3),0})
   AADD(aSemSX3RE,{"REC","N",10,0})
   //TRP - 03/02/07 - Campos do WalkThru
   AADD(aSemSX3RE,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3RE,{"TRB_REC_WT","N",10,0})

   FWorkRE := E_CriaTrab(, aSemSX3RE, "WorkEXP")
   IndRegua("WorkEXP",FWorkRE+TEOrdBagExt(),"PROD+NCM")
   SET INDEX TO (FWorkRE+TEOrdBagExt())
   
   aSelCpos:= {  {"PROD"  ,,AVSX3("ED1_PROD",5)},;
                 {"NCM"   ,,AVSX3("ED1_NCM",5),AVSX3("ED1_NCM",6)},;
                 {"QTD"   ,,AVSX3("ED1_QTD",5),AVSX3("ED1_QTD",6)},;
                 {"VALOR" ,,AVSX3("ED1_VAL_EM",5),AVSX3("ED1_VAL_EM",6)},;
                 {"RE"    ,,AVSX3("ED1_RE",5),AVSX3("ED1_RE",6)},;
                 {"PREEMB",,AVSX3("ED1_PREEMB",5),AVSX3("ED1_PREEMB",6)},;
                 {"PEDIDO",,AVSX3("ED1_PEDIDO",5),AVSX3("ED1_PEDIDO",6)},;
                 {"SEQUEN",,AVSX3("ED1_SEQUEN",5),AVSX3("ED1_SEQUEN",6)} }

   EE9->(dbSetOrder(2))

Endif

Return .T.

*------------------------------------------------------------------------------------------------*
Static Function DC150GrvWorks(cModulo)
*------------------------------------------------------------------------------------------------*
Local cFilSW6:=xFilial("SW6"), cFilEE9:=xFilial("EE9")

If cModulo == "IMP"
   If !ExistCpo("SW6",cPedido)
      Return .F.
   EndIf
   WorkIMP->(avzap())
   SW6->(dbSeek(cFilSW6+cPedido))
   SW8->(dbSeek(cFilSW8+cPedido))
   Do While !SW8->(EOF()) .and. SW8->W8_HAWB == cPedido
      WorkIMP->(RecLock("WorkIMP",.T.))
      WorkIMP->ITEM   := SW8->W8_COD_I
      WorkIMP->NCM    := SW8->W8_TEC
      WorkIMP->QTD    := SW8->W8_QTDE
      WorkIMP->VALOR  := SW8->W8_QTDE * SW8->W8_PRECO
      WorkIMP->DI_NUM := SW6->W6_DI_NUM
      WorkIMP->ADICAO := SW8->W8_ADICAO
      WorkIMP->INVOICE:= SW8->W8_INVOICE
      WorkIMP->REC    := SW8->(RecNo())
      WorkIMP->TRB_ALI_WT:= "SW8"
      WorkIMP->TRB_REC_WT:= SW8->(Recno())
      WorkIMP->(msUnlock())
      SW8->(dbSkip())
   EndDo
   WorkImp->(dbGoTop())
   oMark:oBrowse:Refresh()
Else
   If !ExistCpo("EEC",cPedido)
      Return .F.
   EndIf
   WorkEXP->(avzap())
   EE9->(dbSeek(cFilEE9+cPedido))
   Do While !EE9->(EOF()) .and. EE9->EE9_PREEMB == cPedido
      WorkEXP->(RecLock("WorkEXP",.T.))
      WorkEXP->PROD   := EE9->EE9_COD_I
      WorkEXP->NCM    := EE9->EE9_POSIPI
      WorkEXP->QTD    := EE9->EE9_SLDINI
      WorkEXP->VALOR  := EE9->EE9_PRCINC
      WorkEXP->RE     := EE9->EE9_RE
      WorkEXP->PREEMB := EE9->EE9_PREEMB
      WorkEXP->PEDIDO := EE9->EE9_PEDIDO
      WorkEXP->REC    := EE9->(RecNo())
      WorkEXP->TRB_ALI_WT:= "EE9"
      WorkEXP->TRB_REC_WT:= EE9->(Recno())
      WorkEXP->(msUnlock())
      EE9->(dbSkip())
   EndDo
   WorkExp->(dbGoTop())
   oMark:oBrowse:Refresh()
EndIf

Return .T.

*------------------------------------------------------------------------------------------------*
Static Function DC150ImpDesc()
*------------------------------------------------------------------------------------------------*
Local mDesc:="", oDlgDescr, oMemo, lGrava:=.F.
DEFINE FONT oFont NAME "Courier New" SIZE 0,15

SW8->(dbGoTo(WorkIMP->REC))
If SW8->(BOF()) .and. SW8->(EOF())
   Return .T.
EndIf

mDesc := MSMM(SW8->W8_DESC_DI,AVSX3('W8_DESC_VM',3))
If Empty(Alltrim(mDesc))
   SB1->(dbSeek(cFilSB1+SW8->W8_COD_I))
   mDesc := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
   mDesc += STR0006+Alltrim(MSMM(SB1->B1_DESC_I,AvSx3("B1_VM_I",3)))+")" //" (Nome Comercial - "
   mDesc := StrTran( mDesc, CRLF , " " )
   Do While At("  ",mDesc) > 0
      mDesc := StrTran( mDesc, "  " , " " )
   EndDo
Else
   mDesc := StrTran( mDesc, CRLF , " " )
   Do While At("  ",mDesc) > 0
      mDesc := StrTran( mDesc, "  " , " " )
   EndDo
EndIf

DEFINE MSDIALOG oDLGDescr TITLE STR0007 From 15,00 To 32,54 OF oMainWnd  // //"Alteracao de Descricao"

   oDLGDescr:SetFont(oFont)
   @17,2 GET mDesc MEMO HSCROLL SIZE 203,100 OF oDLGDescr PIXEL

ACTIVATE MSDIALOG oDLGDescr ON INIT EnchoiceBar(oDlgDescr,{|| lGrava:=.T.,oDlgDescr:End()},{|| lGrava:=.F.,oDlgDescr:End()}) CENTERED 

If lGrava .and. MsgYesNo(STR0008) //"Confirma alteração na descrição do item?"
   SW8->(RecLock("SW8",.F.))
   MSMM(SW8->W8_DESC_DI,AVSX3("W8_DESC_VM",3),,mDesc,1,,,"SW8","W8_DESC_DI")
   SW8->(msUnlock())
EndIf

Return .T.

*------------------------------------------------------------------------------------------------*
Static Function DC150ExpDesc()
*------------------------------------------------------------------------------------------------*
Local mDesc:="", oDlgDescr, oMemo, lGrava:=.F.
DEFINE FONT oFont NAME "Courier New" SIZE 0,15

EE9->(dbGoTo(WorkEXP->REC))
If EE9->(BOF()) .and. EE9->(EOF())
   Return .T.
EndIf

mDesc := MSMM(EE9->EE9_DESCRE,AVSX3('EE9_VM_DRE',3))
If Empty(Alltrim(mDesc))
   EE2->(DbSeek(xFilial("EE2")+"3*"+AVKey(IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES","EE2_IDIOMA")+AVKey(EE9->EE9_COD_I,"EE2_COD")))
   mDesc := Alltrim(MSMM_DR(EE2->EE2_TEXTO,AvSx3("EE2_VM_TEX",3)))
EndIf
mDesc := StrTran( mDesc, CRLF , " " )
Do While At("  ",mDesc) > 0
   mDesc := StrTran( mDesc, "  " , " " )
EndDo

DEFINE MSDIALOG oDLGDescr TITLE STR0007 From 15,00 To 32,54 OF oMainWnd  // //"Alteracao de Descricao"

   oDLGDescr:SetFont(oFont)
   @32,2 GET mDesc MEMO HSCROLL SIZE 203,85 OF oDLGDescr PIXEL

ACTIVATE MSDIALOG oDLGDescr ON INIT EnchoiceBar(oDlgDescr,{|| lGrava:=.T.,oDlgDescr:End()},{|| lGrava:=.F.,oDlgDescr:End()}) CENTERED 

If lGrava .and. MsgYesNo(STR0008) //"Confirma alteração na descrição do item?"
   EE9->(RecLock("EE9",.F.))
   MSMM(EE9->EE9_DESCRE,AVSX3("EE9_VM_DRE",3),,mDesc,1,,,"EE9","EE9_DESCRE")
   EE9->(msUnlock())
EndIf

Return .T.
