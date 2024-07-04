#Include "rwmake.ch"
#Include "AVERAGE.CH"
#INCLUDE "Eicgi430.ch"

#define GI_NORMAL     (MOpcao = 1)
#define GI_APROVADA   (MOpcao = 2)
#define GI_PORTARIA78 (MOpcao = 3)
#define GI_PORTARIA15 (MOpcao = 4)
#define GI_ENTREPOST  (MOpcao = 5)
#define GI_NACIONALIZ (MOpcao = 6)
#define ITENS_LI      5
#DEFINE PLI (MOpcao= 1)



*-----------------------*
Function EICGI430()
*-----------------------*
Local oDlgNcm,cArqW6:="SW6",nOpcao:=0
Local bOk:={||nOpcao:=1,OdlgNcm:End()},bCancel:={||OdlgNcm:End()}
LOCAL aStruc:={{"WKPLI","C",10,0}}
LOCAL FileWork

FileWork := E_CriaTrab(,aStruc,"WorkNCM") //THTS - 03/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("WorkNCM",FileWork+TEOrdBagExt(),"WKPLI")

Private cProc:=SW6->W6_HAWB,lHunter  := EasyEntryPoint("IC010PO1")
Private lIntDraw := EasyGParam("MV_EIC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
Private cIndice4 := "WKTEC+WKFABR+WKSHNA_NTX+WKALADI+WK_EX_NBM+WK_EX_NCM"+If(lIntDraw, "+WKAC" , "" )
PRIVATE lLote:=EasyGParam("MV_LOTEEIC") $ cSim
PRIVATE cWorkArq,cNomSuf,cOutSuf // Variaveis de rdmake para Suframa
PRIVATE nTamQ    := AVSX3("W5_QTDE",3)
PRIVATE nDecQ    := AVSX3("W5_QTDE",4)
PRIVATE nTamP    := AVSX3("W5_PRECO",3)
PRIVATE nDecP    := AVSX3("W5_PRECO",4)
PRIVATE nTamT    := AVSX3("W6_FOB_TOT",3)
PRIVATE nDecT    := AVSX3("W6_FOB_TOT",4)
Private lTem_DSI := EasyGParam("MV_TEM_DSI",,.F.)//Verifica se tem manutenção de LSI // ACSJ - 28/04/2004
PRIVATE cRotinaOPC := "LI"   // Quando tiver LSI, virar com "LSI"                                                                                // Alteração feita para resolver 
                                                                                // QNC 001690/2004-00 de 28/04/2004
                                                                                // Conforme orientação do Sr. Jonato
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictQtde := ALLTRIM(X3Picture("W3_QTDE")) // ACSJ - 28/04/2004
                                                                                                // Alteração feita para resolver 
                                                                                                // QNC 001690/2004-00 de 28/04/2004
                                                                                                // Probelma causado apos acerto da variavel lTem_DSI
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM")), _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2) // ACSJ - 28/04/2004
                                                                                                       // Alteração feita para resolver 
If lIntDraw //TRP-11/10/07                                                                                                      // QNC 001690/2004-00 de 28/04/2004
   Private lMUserEDC := FindFunction("EDCMultiUser")
   If lMUserEDC
      Private oMUserEDC := EDCMultiUser():Novo()                                                                                                       // Probelma causado apos acerto da variavel lTem_DSI
   Endif
Endif
Do While .T.
   nOpcao:=0
   Define MsDialog oDlgNcm Title STR0001 From 8,5 To 22,55 OF oMainWnd  // STR0001 Embarque
   
   oPanel:= TPanel():New(0, 0, "", oDlgNcm,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT  

   @20.0,10 Say STR0001           of oPanel Pixel    //STR0001 " Embarque" "No do Processo:..."
   @20.0,50 MSGet cProc F3 cArqW6 of oPanel Pixel Picture '@!' Valid GiValid(cProc) Size 60,10

	Activate MsDialog oDlgNcm On Init EnchoiceBar(oDlgNcm,bOk,bCancel) CENTERED

	If nOpcao==1
       Processa({||Grava()},STR0002) // STR0002 Processando item
	   If WorkNcm->(EasyRecCount())#0
          GITela()
	   Else
          Help("",1,"AVG0001032") // EMBARQUE NAO POSSUI P.L.I.
          Loop   
	   EndIf    
	Else
	   Exit   
	EndIf
	Exit
EndDo	
WorkNcm->(E_EraseArq(FileWork))   
Return .T.
*----------------------------*
Static Function GiValid(cProc)
*----------------------------*
Local nOrdSW6:=SW6->(IndexOrd())

If Empty(cProc)
   Help("",1,"AVG0001033")// Embarque não preenchido
   Return .F. 
EndIf   
SW6->(DbSetOrder(1))
If SW6->(!DbSeek(xFilial("SW6")+cProc))
   Help("",1,"AVG0001034") // Embarque não cadastrado
   SW6->(DbSetOrder(nOrdSW6))
   Return .F. 
EndIf 

Return .T.

*----------------------------*
Static Function Grava()  
*----------------------------*
Local nOrderW5:=SW5->(IndexOrd())
SW5->(DbSetOrder(2))
ProcRegua(SW5->(LASTREC()))
SW5->(DbSeek(xFilial("SW5")+cProc))
Do While SW5->(!Eof()).And. SW5->W5_HAWB==cProc
   IncProc("Lendo P.L.I. :"+SW5->W5_PGI_NUM)
   If WorkNcm->(!DbSeek(SW5->W5_PGI_NUM)).And. Substr(SW5->W5_PGI_NUM,1,1)#"*"
      RecLock("WorkNcm",.T.)
      WorkNcm->WKPLI:=SW5->W5_PGI_NUM
      WorkNcm->(MsUnLock())
   EndIf   
   SW5->(DbSkip())
EndDo   
SW5->(DbSetOrder(nOrderW5))
Return .T. 

*---------------------*
Static Function GITela()   
*---------------------*
Local aCampos:={},OdlgTela,nOpcao:=0
Local bCancel:={||nOpcao:=0,OdlgTela:End()}
Local bAltera:={||nOpcao:=1,OdlgTela:End()}
LOCAL nOrdSWP := SWP->(INDEXORD()), i
LOCAL oPanelTela

PRIVATE cMarca := GetMark(), lInverte := .F.,nRec  
PRIVATE FileWork, WorkNTX2, WorkNTX3, WorkNTX4
PRIVATE WorkNtx5  // ACSJ - 28/04/2004
                  // Alteração feita para resolver 
                  // QNC 001690/2004-00 de 28/04/2004
                  // Probelma causado apos acerto da variavel lTem_DSI
Private cFilED0, cFilED4, cFilED2, cFilED3,cFilSY6:=xFilial("SY6"), lMostraAC:=.T.  //LRL 04/05/04 Necessario no EICGI400
PRIVATE Inclui :=.F.,lRefresh:=.T.
PRIVATE cPictFob := ALLTRIM(X3Picture("W6_FOB_TOT"))
PRIVATE cPictInl := ALLTRIM(X3Picture("W6_INLAND"))
PRIVATE cPictFri := ALLTRIM(X3Picture("W6_FRETEIN"))
PRIVATE cPictPac := ALLTRIM(X3Picture("W6_PACKING"))
PRIVATE cPictDes := ALLTRIM(X3Picture("W6_DESCONT"))
PRIVATE cPictNBM := ALLTRIM(X3Picture("B1_POSIPI"))
PRIVATE cPictPeso:= ALLTRIM(X3Picture("B1_PESO"))
PRIVATE MTotal, MTotal2, MTotPeso
If lIntDraw   //LRL 04/05/04 - Necessario no EICGI400
   cFilED4 := xFilial("ED4")
   cFilED0 := xFilial("ED0")
   cFilED2 := xFilial("ED2")
   cFilED3 := xFilial("ED3")
EndIf
MTotal:=0
MTotal2:=0
MTotPeso:=0

DbSelectArea("SW4")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT
PRIVATE aRotina := { {,, 0 , 1},;
                     {,, 0 , 2},;
                     {,, 0 , 3},;
                     {,, 0 , 4, 20 },;
                     {,, 0 , 6, 21 } }
             
TB_Campos:={{"WKPLI","","PLI"}}                

Do While .T.                   
   DBSELECTAREA("WorkNCM") 
   nOpcao:=0
   WorkNcm->(DbGoTop())    

   DEFINE MSDIALOG oDlgTela TITLE STR0003 FROM 4,3 TO 20,55 OF oMainWnd //STR0003	"Manuteção de PLI" 

   oMark:= MsSelect():New("WorkNCM","",,TB_Campos,@lInverte,@cMarca,{20,6,100,160})
   oMark:bAval:={||Eval(bAltera),oMark:oBrowse:Refresh()}                         
   
   @00,00 MsPanel oPanelTela Prompt "" Size 50,30 of oDlgTela 
   
   @ 10,5  BUTTON STR0004 Size 40,10 ACTION EVAL(bAltera) OF oPAnelTela Pixel // STR0004 "Alterar"
   
   DEFINE SBUTTON FROM 25,5 TYPE 2 ACTION EVAL(bCancel) ENABLE OF oPanelTela PIXEL
   oPanelTela:Align:=CONTROL_ALIGN_RIGHT
   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlgTela CENTERED //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If nOpcao==1                   
      SWP->(DBSETORDER(1))
      If SWP->(DbSeek(xFilial("SWP")+WorkNcm->WKPLI)) 
         nRec:=SWP->(Recno())                                           
         M->WP_PGI_NUM := SWP->WP_PGI_NUM
         M->WP_SEQ_LI  := SWP->WP_SEQ_LI
         oMainWnd:ReadClientCoors()                          
         EICGI400(.T.)  //TRP-15/10/07
         //GI400Altera("SWP",nRec,4)
      EndIf            
   Else
      Exit
   EndIf   
EndDo                             
SWP->(DBSETORDER(nordSWP))
DBSELECTAREA("SX3")
Return .T.
