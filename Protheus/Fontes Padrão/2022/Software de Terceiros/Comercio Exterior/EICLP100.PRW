#include "Eiclp100.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"

/*
Funcao      : EICLP100
Objetivos   : Ajustar o relatório para a versão 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 08/08/2006
Obs         :
Revisão     :
*/

*******************
Function EICLP100
*******************
lRet := EICLP100R3(.T.)
RETURN lRet

*------------------------*
FUNCTION EICLP100R3(p_R4)
*------------------------*
LOCAL nOpc, oDlg, bBtnOk, bBtnCancel, oRadio, cNrProc, TB_Campos := {}, nReg:=1
LOCAL aWK_DBF:= { {"WKHAWB"   ,"C",AVSX3("W6_HAWB",3),0},;
                  {"WKDT_HAWB","D",                8 ,0},;
                  {"WKIMPORT" ,"C",                20,0},;
                  {"WKDT_EMB" ,"D",                8 ,0},;
                  {"WKDT_CHEG","D",                8 ,0},;
                  {"WKDT_DESE","D",                8 ,0},;
                  {"WKDI_NUM" ,"C",AVSX3("W6_DI_NUM",3),0},;
                  {"WKVIA_TRA","C",                10 ,0},;
                  {"WKORIGEM" ,"C",                3 ,0},;
                  {"WKDEST"   ,"C",                3 ,0},;
                  {"WKAGENTE" ,"C",                20,0} }
                  
LOCAL oPanel                   

//GFP 19/10/2010
aWK_DBF := AddWkCpoUser(aWK_DBF,"SW6")
FileWork := E_CriaTrab(,aWK_DBF,"Work") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help("", 1, "AVG0000451")//"NÆo h   rea dispon¡vel para abertura do Cadastro de Work"###"Atenção"
   Return .F.
ENDIF

PRIVATE aHeader[0]                                                               
PRIVATE cPGI_Num := SPACE(LEN(SW5->W5_PGI_NUM))
PRIVATE cCEmbarq := SPACE(LEN(SW6->W6_HOUSE))
PRIVATE cDocNF   := SPACE(LEN(SF1->F1_DOC)+LEN(SF1->F1_SERIE))
PRIVATE cInvoice := SPACE(LEN(SW8->W8_INVOICE)) 
PRIVATE cCCarga  := SPACE(LEN(SW6->W6_IDEMANI)) 
PRIVATE oGetNPLI, oGetCEmb, oGetNF, oGetInv, oGetCarg, nOpRad := 0
PRIVATE nCol01 := 01
PRIVATE nCol02 := 19
PRIVATE nCol03 := 29
PRIVATE nCol04 := 50
PRIVATE nCol05 := 60
PRIVATE nCol06 := 70
PRIVATE nCol07 := 80
PRIVATE nCol08 := 91
PRIVATE nCol09 := 110
PRIVATE lTem_LI := .F.
PRIVATE cNrNF                  

//JPA - 08/08/2006 - Relatório Personalizavel - Release 4
Private oReport
Private lR4   := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()
                   
AADD(TB_Campos,{"WKHAWB"   ,"", STR0020}) 
AADD(TB_Campos,{"WKDT_HAWB","", STR0021})
AADD(TB_Campos,{"WKIMPORT" ,"", STR0022})
AADD(TB_Campos,{"WKDT_EMB" ,"", STR0023})
AADD(TB_Campos,{"WKDT_CHEG","", STR0024})
AADD(TB_Campos,{"WKDT_DESE","", STR0025})
AADD(TB_Campos,{"WKDI_NUM" ,"", STR0026})
AADD(TB_Campos,{"WKVIA_TRA","", STR0027})
AADD(TB_Campos,{"WKORIGEM" ,"", STR0028})
AADD(TB_Campos,{"WKDEST"   ,"", STR0029})
AADD(TB_Campos,{"WKAGENTE" ,"", STR0031})


DO WHILE .T.    
   nOpc     := 0
   cPGI_Num := SPACE(LEN(SW5->W5_PGI_NUM))
   cCEmbarq := SPACE(LEN(SW6->W6_HOUSE))
   cDocNF   := SPACE(LEN(SF1->F1_DOC)+LEN(SF1->F1_SERIE))
   cInvoice := SPACE(LEN(SW8->W8_INVOICE)) 
   cCCarga  := SPACE(LEN(SW6->W6_IDEMANI)) 
  
   oMainWnd:ReadClientCoords()        
    
   DEFINE MSDIALOG oDlg TITLE STR0001 FROM 12,05 TO 29,80 OF GetWndDefault()
   
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.) //MCF - 22/07/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
          
      bBtnOk     := {|| nOpc:= 1, oDlg:End() }
      bBtnCancel := {|| nOpc:= 0, oDlg:End() }
      
      @ 19, 30 TO 80, 105 LABEL STR0002 OF oPanel PIXEL 
 
      @ 24, 35 RADIO oRadio VAR nOpRad ITEMS STR0003, STR0004,  ;
                     STR0005, STR0006 3D SIZE 65,13 ;
                     PIXEL OF oPanel ON CHANGE (SelTipDoc(nOpRad)) 
                                   
      @ 24, 142 SAY STR0003 OF oPanel PIXEL                                               
      @ 24, 200 MSGET oGetNPLI VAR cPGI_Num SIZE 60,08 OF oPanel PIXEL WHEN {||nOpRad==1 }
      
      @ 38, 142 SAY STR0004 OF oPanel PIXEL
      @ 38, 200 MSGET oGetCEmb VAR cCEmbarq SIZE 60,08 OF oPanel PIXEL WHEN {||nOpRad==2 }

      @ 52, 142 SAY STR0005 OF oPanel PIXEL
      @ 52, 200 MSGET oGetNF VAR cDocNF SIZE 60,08 OF oPanel PIXEL WHEN {||nOpRad==3 }

      @ 66, 142 SAY STR0006 OF oPanel PIXEL
      @ 66, 200 MSGET oGetInv  VAR cInvoice SIZE 60,08 OF oPanel PIXEL WHEN {||nOpRad==4 }

   ACTIVATE MSDIALOG oDlg ON INIT  EnchoiceBar(oDlg,bBtnOK,bBtnCancel) CENTERED
   
   IF nOpc == 0
      EXIT
   ELSE   
      IF nOpRad == 0
         MSGINFO(STR0007)
         LOOP
      ENDIF
      IF nOpRad == 1 
         IF EMPTY(cPGI_Num)
            MSGINFO(STR0009 + STR0008)
            LOOP
         ENDIF

         IF !SW5->(dbSeek(xFilial("SW5")+cPGI_Num))
            MSGINFO(STR0010)
            LOOP
         ENDIF

      ELSEIF nOpRad == 2
         IF EMPTY(cCEmbarq)
            MSGINFO(STR0011 + STR0008)
            LOOP
         ENDIF
  
         SW6->(dbSetOrder(10))
         IF !SW6->(dbSeek(xFilial("SW6")+cCEmbarq))
            MSGINFO(STR0012)
            LOOP
         ENDIF
         
         cNrProc := SW6->W6_HAWB
         
      ELSEIF nOpRad == 3
         IF EMPTY(cDocNF)
            MSGINFO(STR0013 + STR0008)
            LOOP
         ENDIF
  
         SF1->(dbSetOrder(01))
         IF !SF1->(dbSeek(xFilial("SF1")+AllTrim(cDocNF),.T.))
            MSGINFO(STR0014)
            LOOP
         ENDIF
                  
         cNrNF := SF1->F1_DOC
      
      ELSEIF nOpRad == 4      
         IF EMPTY(cInvoice)
            MSGINFO(STR0015 + STR0008)
            LOOP
         ENDIF
         
         SW9->(dbSetOrder(01))
         IF !SW9->(dbSeek(xFilial("SW9")+cInvoice))
            MSGINFO(STR0016)
            LOOP
         ENDIF
         
         cNrProc := SW9->W9_HAWB

      ENDIF     
              
      Processa({||LP100Ler(cNrProc)}, STR0001,; //"Localizacao de Processo"
                                      STR0017 ) //"Em processamento - aguarde..."

      SW6->(dbSetOrder(1))

      If !lTem_LI
         MsgInfo("Nao foi encontrado processo para esta pesquisa.","Atencao")
         Loop
      Endif
      
      Work->(dbGoTop())
            
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE STR0001 FROM ;
             oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;     
             OF oMainWnd PIXEL  
         @00,00 MSPanel oPanel Size 20,45 of oDlg
            
         DEFINE SBUTTON FROM 18,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (Processa(If(lR4, {||(oReport := ReportDef(),oReport:PrintDialog())}, {||PrintProc()}),STR0018))ENABLE OF oPanel
         
         //GFP 19/10/2010
         TB_Campos := AddCpoUser(TB_Campos,"SW6","2")
                  	
         oMark:= MsSelect():New("Work",,,TB_Campos,.F.,"",{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
		 
		 oPanel:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT   
         oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()})) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
  
   ENDIF
ENDDO                     

Work->(E_EraseArq(FileWork))

RETURN .T.                            

*------------------------------*
FUNCTION SelTipDoc()
*------------------------------*
IF nOpRad==1
  oGetNPLI:ENABLE()
  oGetNPLI:SetFocus()
  
  cCEmbarq := SPACE(LEN(SW6->W6_HOUSE))
  cDocNF   := SPACE(LEN(SF1->F1_DOC)+LEN(SF1->F1_SERIE)) 
  cInvoice := SPACE(LEN(SW8->W8_INVOICE)) 
 
  oGetCEmb:Refresh()
  oGetCEmb:DISABLE()
  oGetNf:Refresh()
  oGetNF:DISABLE()
  oGetInv:Refresh()  
  oGetInv:DISABLE()
  
ELSEIF nOpRad==2  
  oGetCEmb:ENABLE()
  oGetCEmb:SetFocus()

  cPGI_Num := SPACE(LEN(SW5->W5_PGI_NUM))
  cDocNF   := SPACE(LEN(SF1->F1_DOC)+LEN(SF1->F1_SERIE))
  cInvoice := SPACE(LEN(SW8->W8_INVOICE)) 
  
  oGetNPLI:Refresh()
  oGetNPLI:DISABLE()
  oGetNF:Refresh()
  oGetNF:DISABLE()
  oGetInv:Refresh()  
  oGetInv:DISABLE()

  
ELSEIF nOpRad==3  
  oGetNF:ENABLE()
  oGetNF:SetFocus()
  
  cPGI_Num := SPACE(LEN(SW5->W5_PGI_NUM))
  cCEmbarq := SPACE(LEN(SW6->W6_HOUSE))
  cInvoice := SPACE(LEN(SW8->W8_INVOICE)) 
                   
  oGetNPLI:Refresh()
  oGetNPLI:DISABLE()
  oGetCEmb:Refresh()
  oGetCEmb:DISABLE()
  oGetInv:Refresh()
  oGetInv:DISABLE()
 
ELSEIF nOpRad==4  
  oGetInv:ENABLE()
  oGetInv:SetFocus()
  
  cPGI_Num := SPACE(LEN(SW5->W5_PGI_NUM))
  cCEmbarq := SPACE(LEN(SW6->W6_HOUSE))
  cDocNF   := SPACE(LEN(SF1->F1_DOC)+LEN(SF1->F1_SERIE))
                   
  oGetNPLI:Refresh()
  oGetNPLI:DISABLE()
  oGetCEmb:Refresh()
  oGetCEmb:DISABLE()
  oGetNF:Refresh()
  oGetNF:DISABLE()  

ENDIF 
lRefresh:=.T.
RETURN .T.


*------------------------------*
FUNCTION PrintProc(cNrProc)
*------------------------------*
LOCAL wnrel    := "EICLP100"
LOCAL cDesc1   := "Impressao do relatorio - " + STR0001
LOCAL cDesc2   := " "
LOCAL cDesc3   := " "
LOCAL cString  := "Work"

PRIVATE tamanho :="M"
PRIVATE limite  :=132
PRIVATE Titulo  :=STR0001
PRIVATE aReturn := { "Zebrado", 1,"Importação", 2, 2, 1, "",0 }
PRIVATE nomeprog:="EICLP100",nLastKey := 0,nBegin:=0,aLinha:={ }
PRIVATE aDriver :=ReadDriver()
PRIVATE cPerg   :=NIL

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)
If nLastKey == 27
   Return
Endif

SetDefault(aReturn,cString)
If nLastKey == 27
   Set Filter to
   Return
Endif

RptStatus({|lEnd| RelLocProc(@lEnd,wnRel,cString,tamanho,limite)},Titulo)
Return


*--------------------------------------------------------------------*
FUNCTION RelLocProc(lEnd,wnRel,cString,tamanho,limite)
*--------------------------------------------------------------------*
LOCAL OldRecno := Work->(RECNO())
M_Pag  :=1
limite := 130;li:= 80
MLin := 99
MPag := 00

Work->(DBGOTOP())
SetRegua(Work->(LASTREC()))
DO WHILE !Work->(EOF())
   IF MLin > 55
      LocProcCab()
      MLin ++
   ENDIF        
   @ Mlin,nCol01 PSAY Work->WKHAWB     
   @ Mlin,nCol02 PSAY Work->WKDT_HAWB
   @ Mlin,nCol03 PSAY Work->WKIMPORT 
   @ Mlin,nCol04 PSAY Work->WKDT_EMB
   @ Mlin,nCol05 PSAY Work->WKDT_CHEG     
   @ MLin,nCol06 PSAY Work->WKDT_DESE
   @ MLin,nCol07 PSAY LEFT(Work->WKDI_NUM,10)
   @ Mlin,nCol08 PSAY Work->WKVIA_TRA + " " + Work->WKORIGEM + "/" + Work->WKDEST
   @ Mlin,nCol09 PSAY Work->WKAGENTE 
   Work->(dbSkip())
   mLin+=2
ENDDO                      
mLin+=1

Set Device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
   Set Printer TO 
   Commit
   OurSpool(wnrel)
Endif
MS_FLUSH()
Work->(DBGOTO(OldRecno))
RETURN .T.

*---------------------*
FUNCTION LocProcCab()
*---------------------*
MPag := MPag + 1
cabec1:= ""

MLIN := Cabec(titulo,cabec1,"",nomeprog,tamanho,EasyGParam("MV_COMP"))

MLin += 1
@ MLin,nCol01 PSAY STR0020
@ MLin,nCol02 PSAY STR0021
@ MLin,nCol03 PSAY STR0022
@ MLin,nCol04 PSAY STR0023
@ MLin,nCol05 PSAY STR0024
@ MLin,nCol06 PSAY STR0025
@ MLin,nCol07 PSAY STR0026
@ MLin,nCol08 PSAY STR0030
@ MLin,nCol09 PSAY STR0031

MLin += 1
@ MLin,nCol01 PSAY Replicate("-",17) //"-----------------"
@ MLin,nCol02 PSAY Replicate("-",08) //"--------"
@ MLin,nCol03 PSAY Replicate("-",20) //"--------------------"
@ MLin,nCol04 PSAY Replicate("-",08) //"--------"
@ MLin,nCol05 PSAY Replicate("-",08) //"--------"
@ MLin,nCol06 PSAY Replicate("-",08) //"--------"
@ MLin,nCol07 PSAY Replicate("-",10) //"----------"
@ MLin,nCol08 PSAY Replicate("-",18) //"------------------"
@ Mlin,nCol09 PSAY Replicate("-",20) //"--------------------"
RETURN NIL


// ACL 09/06/03 - Para buscar todos os Processos q tenham a PLI
*------------------------------*
FUNCTION LP100Ler(cNrProc)
*------------------------------*
Local aHawb := {}

ProcRegua(SW6->(LASTREC()))

DBSELECTAREA("Work")
AvZap()

IF nOpRad == 1 
   cNrProc := ""
   aHawb := {}
   lTem_LI := .F.
   While !SW5->(Eof()) .and. cPGI_Num = SW5->W5_PGI_NUM
      If Ascan(aHawb,{|x| x[1] == SW5->W5_HAWB}) = 0
         cNrProc := SW5->W5_HAWB
         IncProc(STR0019+ALLTRIM(cNrProc))
         Aadd(aHawb,{SW5->W5_HAWB,SW5->W5_PGI_NUM})
         IncProc(STR0019+ALLTRIM(cNrProc)) //"Pesquisando Processo: "
         IF SW6->(DBSEEK(xFilial()+SW5->W5_HAWB))
            lTem_LI := .T.
            LP100GrvWk(cNrProc)
         ENDIF
      Endif
      SW5->(Dbskip())
   End
   SW5->(dbSetOrder(01))
ELSEIF nOpRad == 2
   While !SW6->(Eof()) .and. SW6->W6_HOUSE = cCEmbarq
      cNrProc := SW6->W6_HAWB
      IncProc(STR0019+ALLTRIM(cNrProc))
      lTem_LI := .T.
//      cNrProc
      LP100GrvWk(cNrProc)
      SW6->(Dbskip())
   End

ELSEIF nOpRad == 3
   While !SF1->(Eof()) .and. SF1->F1_DOC = cNrNF
      cNrProc := SF1->F1_HAWB
      SW6->(Dbseek(xFilial("SW6")+cNrProc))
      IncProc(STR0019+ALLTRIM(cNrProc))
      lTem_LI := .T.
//      cNrProc
      LP100GrvWk(cNrProc)
      If !Empty(Subs(cDocNF,7,3))
         Exit
      Endif
      SF1->(Dbskip())
   End
ELSE
   IncProc(STR0019+ALLTRIM(cNrProc)) //"Pesquisando Processo: "
   SW6->(DBSEEK(xFilial()+cNrProc))
   lTem_LI := .T.
   LP100GrvWk(cNrProc)
Endif

RETURN lTem_LI


*--------------------------*
FUNCTION LP100GrvWk(cNrProc)
*--------------------------*
Work->(DBAPPEND())                                    
Work->WKHAWB    := cNrProc
Work->WKDT_HAWB := SW6->W6_DT_HAWB
Work->WKIMPORT  := IIF( SYT->(dbSeek(xFilial()+SW6->W6_IMPORT)), LEFT(SYT->YT_NOME,20), SW6->W6_IMPORT ) 
Work->WKDT_EMB  := SW6->W6_DT_EMB
Work->WKDT_CHEG := SW6->W6_CHEG
Work->WKDT_DESE := SW6->W6_DT_DESE
Work->WKDI_NUM  := SW6->W6_DI_NUM
Work->WKVIA_TRA := IIF( SYQ->(dbSeek(xFilial()+SW6->W6_VIA_TRA)), LEFT(SYQ->YQ_COD_DI,10), SW6->W6_VIA_TRA )
Work->WKORIGEM  := SW6->W6_ORIGEM
Work->WKDEST    := SW6->W6_DEST
Work->WKAGENTE  := IIF( SY4->(dbSeek(xFilial()+SW6->W6_AGENTE)), LEFT(SY4->Y4_NOME,20), SW6->W6_AGENTE )
RETURN NIL


//JPA - 08/08/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW6"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICLP100", STR0001, "", {|oReport| ReportPrint(oReport)}, "Impressao do relatorio - " + STR0001)

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Processos",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1, "WKHAWB"   , "Work", STR0020   , /*Picture*/   , AVSX3("W6_HAWB",3)  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_HAWB", "Work", STR0021   , /*Picture*/   , 10                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKIMPORT" , "Work", STR0022   , /*Picture*/   , 20                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_EMB" , "Work", STR0023   , /*Picture*/   , 10                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_CHEG", "Work", STR0024   , /*Picture*/   , 10                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDT_DESE", "Work", STR0025   , /*Picture*/   , 10                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDI_NUM" , "Work", STR0026   , /*Picture*/   , AVSX3("W6_DI_NUM",3), /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKVIA_TRA", "Work", STR0027   , /*Picture*/   , 10                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKORIGEM" , "Work", STR0028   , /*Picture*/   , 03                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKDEST"   , "Work", STR0029   , /*Picture*/   , 03                  , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "WKAGENTE" , "Work", STR0031   , /*Picture*/   , 20                  , /*lPixel*/, /*{|| code-block de impressao }*/)

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport


************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Processos")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Processos"),"SW6",1,{|| xFilial()+SW6->W6_HAWB})

oReport:SetMeter(Work->(EasyRecCount()))
Work->(dbGoTop())

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Processos"):Init()

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Processos"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Processos"):Finish()                                

return .T.
