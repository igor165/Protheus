#INCLUDE "EFFPV400.ch"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"

#define VISUALIZAR 2
#define INCLUIR    3
#define ALTERAR    4
#define ESTORNAR   5

#define MOEDA_REAIS "R$ "
#define ACC         "01"
#define ACE         "02"
#define PRE_PAGTO   "03"
#define EV_PRINC    "100"
#define EV_PRINC2   "101"
#define EV_EMBARQUE "600"
#define EV_PJ       "520"
#define EV_TJ       "650"
#define EV_VC_PJ    "550"
#define EV_LIQ_PRC  "630"
#define EV_LIQ_JUR  "640"
#define EV_VC_PRC   "500"
#define EV_VC_PRC1  "501"
#define EV_DESCON   "801"
#define EV_ESTORNO  "999"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2

/*
Programa        : EFFPV400.PRW
Objetivo        : Manutenção da Pre-Vinculação
Autor           : Lucas Rolim Rosa Lopes
Data/Hora       : 
*/

/*
REVISÃO
Objetivo   : Acrescentar validações para novos campos do Financiamento (Tipo do Modulo / Sequencia do Contrato)
Autor      : PLB - Pedro Baroni
Data       : 10/03/06
*/

*-----------------*
Function EFFPV400()
*-----------------*
PRIVATE cCadastro := STR0094  //"Pré-Vinculação"
Private aRotina:=MenuDef()
Private lMultiFil
Private lIntExp := EasyGParam("MV_EEC_EFF",,.F.) //Verifica se existe a integração com o Módulo SIGAEEC
Private lParFin := EEQ->(FieldPos("EEQ_PARFIN")) > 0
Private lExistForn := EEQ->(FieldPos("EEQ_FORN")) > 0 .and. EEQ->(FieldPos("EEQ_FOLOJA")) > 0
Private lTemPraca  := EF1->(FieldPos("EF1_PRACA")) > 0  .ANd. EF1->(FieldPos("EF1_BAN_FI")) > 0
Private lTemFilOri := EF3->(FieldPos("EF3_FILORI")) > 0
Private lTop := .F.
Private aBotao:= {{"BUDGET"  ,{|| BtnContrat()}, STR0088,STR0046}}  //"Saldo do Contrato"  "Contrato"
SX3->(DbSetOrder(2))
lMultiFil  := VerSenha(115) .and. Posicione("SX2",1,"EF6","X2_MODO") == "C" .and. Posicione("SX2",1,"EEQ","X2_MODO") == "E"  .AND. EF6->(FieldPos("EF6_FILORI")) > 0
Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI"))
SX3->(DbSetOrder(1))

//** GFC - Pré-Pagamento/Securitização
Private lPrePag   := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                     EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                     EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                     EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                     EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                     EF1->(FieldPos("EF1_PREPAG")) > 0 .and.;
                     EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
                     EF1->(FieldPos("EF1_ROF")) > 0    .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
                     EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
                     EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
                     EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
                     EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0

//** AAF - 21/02/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0

Private lEF2_INVOIC := EF2->(FieldPos("EF2_INVOIC")) > 0 .and. EF2->(FieldPos("EF2_PARC")) > 0 .and.;
                       EF2->(FieldPos("EF2_FILORI")) > 0

Private lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0
//**

//** PLB 09/03/06 

// Verifica se existe Cadastro de Tipo de Financiamento
Private lCadFin := ChkFile("EF7")  .And.  ChkFile("EF8")

Private lEEQ_TP_CON := EEQ->(FieldPos("EEQ_TP_CON")) > 0 //** GFC - 01/12/05

//Variaveis privadas das filiais 
Private cFilEF1:=xFilial("EF1"), cFilEF6:=xFilial("EF6"), cFilEF3:=xFilial("EF3")
Private cFilEF2:=xFilial("EF2")
Private cFilEC6:=xFilial("EC6"), cFilEEC:=xFilial("EEC"), cFilEEQ:=xFilial("EEQ")
Private cFilEE9:=xFilial("EE9"), cFilSX5:=xFilial("SX5"), cFilECF:=xFilial("ECF")
Private cFilSA6:=xFilial("SA6"), cFilEF4:=xFilial("EF4")
Private cFilEF7:="" // PLB 10/03/06
//          

//** PLB 10/03/06
If lCadFin
   cFilEF7 := xFilial("EF7")
EndIf

If !Empty(EasyGParam("MV_AVG0024",,"")) .and. cFilAnt $ EasyGParam("MV_AVG0024",,"")
   MsgStop(STR0089)  //"Financiamento desabilitado para filiais off-shore."
   Return .F.
EndIf

//
Private cFiltro := "3"
Private cFiliais
Private aFiliais 
Private dVencIni   
Private dVencFim 
Private cInvoice  
Private cProcesso 
Private nValIni , nValFim 	
Private cCliente  ,cCondPagto
Private cLojaCli := ""
Private nDias 
Private xAux //Variavel Auxiliar para Rdmakes 
Private xAux2 //Variavel Auxiliar para Rdmakes 
Private PV400Inclui := .T.
                                                                                 
DbSelectArea("EF6")
DbSetOrder(1)
MBrowse(10,05,22,78,"EF6",,"EF6_DT_LIB",,".T.") 
Return .T.


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 31/01/07 - 12:13
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := {}

AADD(aRotina,{ STR0001 ,"AxPesqui"  ,0,1})  //"Pesquisar"
AADD(aRotina,{ STR0002 ,"PV400Manut",0,2})  //"Visualizar"
AADD(aRotina,{ STR0003 ,"PV400Manut",0,3})  //"Incluir"
AADD(aRotina,{ STR0004 ,"PV400Manut",0,4})  //"Alterar"
AADD(aRotina,{ STR0005 ,"PV400Eftiv",0,5})  //"Efetiva"
AADD(aRotina,{ STR0006 ,"PV400Estor",0,6})  //"Estorna"
AADD(aRotina,{ STR0007 ,"BtnContrat",0,7})  //"Sld. Contr."
AADD(aRotina,{ STR0095 ,"PV400Legenda",0,2})  //"Legenda"
//AADD(aRotina,{ STR0008 ,"PV400Filtro",0,8}) //"Filtra"  // GFP - 11/12/2015 - Nopado, pois as condições serão incluídas no botão padrão de filtro do MBrowse.

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("FPV400MNU")
	aRotAdic := ExecBlock("FPV400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
                         
*-----------------------------------*
Function PV400Manut(cAlias,nReg,nOpc)
*-----------------------------------*
Local lOk := .F.   
Local i ,ni                     

//Variaveis privadas par MsGetDados
Private oGet
Private aHeader := {}                 
Private aAlter  := {}                                              
Private aCols := {}
//        
//** PLB 13/03/06 - Utilizado para Seek quando alterar Contrato
Private aKeyEF6 := {}
Private aOldKey := {}
Private nOption := nOpc
//**
//
Private aContra := {}
Private aInvoice:= {}
Private aDel    := {} 
Private cDel
Private cError1 := STR0009 + CHR(10)+CHR(13) //"A(s) invoice(s)/parcela(s) não tem saldo para vinculação , favor verificar ! :"
Private cError2 := STR0010 + CHR(10)+CHR(13) //"O(s) contrato(s)  não tem saldo para vinculação , favor verificar ! :"
Private cError3 := STR0011 + CHR(10)+CHR(13) //"As parcelas do processo estão diferentes das parcelas da pre-vinculação, favor verificar ! :"
Private lError1 := lError2 :=  lError3 := .F.
If nOpc == 3 .and. !PV400Inclui
  PV400Inclui := .T.
  Return .T.
EndIf  
SetFil()
#IFDEF TOP
   lTop := .T.                
#ENDIF
If lMulTiFil
   Aadd(aHeader,{AVSX3("EF6_FILORI",5),"EF6_FILORI",AVSX3("EF6_FILORI",6), AVSX3("EF6_FILORI",3),AVSX3("EF6_FILORI",4),"",nil, AVSX3("EF6_FILORI",2),nil,nil }) 
EndIf 
Aadd(aHeader,{AVSX3("EF6_PREEMB",5),"EF6_PREEMB",AVSX3("EF6_PREEMB",6), AVSX3("EF6_PREEMB",3),AVSX3("EF6_PREEMB",4),"",nil, AVSX3("EF6_PREEMB",2),nil,nil }) 
Aadd(aHeader,{AVSX3("EF6_NRINVO",5),"EF6_NRINVO",AVSX3("EF6_NRINVO",6), AVSX3("EF6_NRINVO",3),AVSX3("EF6_NRINVO",4),"",nil, AVSX3("EF6_NRINVO",2),nil,nil }) 
Aadd(aHeader,{AVSX3("EF6_PARC"  ,5),"EF6_PARC"  ,AVSX3("EF6_PARC"  ,6), AVSX3("EF6_PARC"  ,3),AVSX3("EF6_PARC"  ,4),"",nil, AVSX3("EF6_PARC"  ,2),nil,nil })
Aadd(aHeader,{AVSX3("EF6_VL_INV",5),"EF6_VL_INV",AVSX3("EF6_VL_INV",6), AVSX3("EF6_VL_INV",3),AVSX3("EF6_VL_INV",4),"",nil, AVSX3("EF6_VL_INV",2),nil,nil })
Aadd(aHeader,{AVSX3("EEC_MOEDA" ,5),"EEC_MOEDA" ,AVSX3("EEC_MOEDA" ,6), AVSX3("EEC_MOEDA" ,3),AVSX3("EEC_MOEDA" ,4),"",nil, AVSX3("EEC_MOEDA" ,2),nil,nil })
Aadd(aHeader,{AVSX3("EEC_DTEMBA",5),"EEC_DTEMBA",AVSX3("EEC_DTEMBA",6), AVSX3("EEC_DTEMBA",3),AVSX3("EEC_DTEMBA",4),"",nil, AVSX3("EEC_DTEMBA",2),nil,nil })
Aadd(aHeader,{AVSX3("EF6_CLIENT",5),"EF6_CLIENT",AVSX3("EF6_CLIENT",6), AVSX3("EF6_CLIENT",3),AVSX3("EF6_CLIENT",4),"",nil, AVSX3("EF6_CLIENT",2),nil,nil }) 
Aadd(aHeader,{AVSX3("EF6_CLLOJA",5),"EF6_CLLOJA"  ,AVSX3("EF6_CLLOJA",6), AVSX3("EF6_CLLOJA",3),AVSX3("EF6_CLLOJA",4),"",nil, AVSX3("EF6_CLLOJA",2),nil,nil })
Aadd(aHeader,{AVSX3("EF6_CONTRA",5),"EF6_CONTRA",AVSX3("EF6_CONTRA",6), AVSX3("EF6_CONTRA",3),AVSX3("EF6_CONTRA",4),"PV400FieldOK ('M->EF6_CONTRA')",nil, AVSX3("EF6_CONTRA",2),nil,nil })
//Aadd(aHeader,{AVSX3("EF6_MOEDA" ,5),"EF6_MOEDA" ,AVSX3("EF6_MOEDA" ,6), AVSX3("EF6_MOEDA" ,3),AVSX3("EF6_MOEDA" ,4),"",nil, AVSX3("EF6_MOEDA" ,2),nil,nil })
Aadd(aHeader,{AVSX3("EF6_BANCO" ,5),"EF6_BANCO",AVSX3("EF6_BANCO" ,6), AVSX3("EF6_BANCO" ,3),AVSX3("EF6_BANCO" ,4),"PV400FieldOK ('M->EF6_BANCO')",nil, AVSX3("EF6_BANCO" ,2),nil,nil })
Aadd(aHeader,{AVSX3("EF6_PRACA" ,5),"EF6_PRACA" ,AVSX3("EF6_PRACA" ,6), AVSX3("EF6_PRACA" ,3),AVSX3("EF6_PRACA" ,4),"PV400FieldOK ('M->EF6_PRACA')",nil, AVSX3("EF6_PRACA" ,2),nil,nil })
If lEFFTpMod
   Aadd(aHeader,{AVSX3("EF6_SEQCNT",5),"EF6_SEQCNT",AVSX3("EF6_SEQCNT",6), AVSX3("EF6_SEQCNT",3),AVSX3("EF6_SEQCNT",4),"PV400FieldOK ('M->EF6_SEQCNT')",nil, AVSX3("EF6_SEQCNT",2),nil,nil })
   Aadd(aHeader,{"Vinculado ao"       ,"EF6_TP_VIN",AVSX3("EF6_TP_VIN",6), AVSX3("EF6_TP_VIN",3),AVSX3("EF6_TP_VIN",4),"",nil, AVSX3("EF6_TP_VIN",2),nil,nil })
EndIf
//Aadd(aHeader,{AVSX3("EF6_DTVINC",5),"EF6_DTVINC",AVSX3("EF6_DTVINC",6), AVSX3("EF6_DTVINC",3),AVSX3("EF6_DTVINC",4),"",nil, AVSX3("EF6_DTVINC",2),nil,nil }) 
Aadd(aHeader,{"Sld. Vinc. Inv."    ,"EF6_VL" ,AVSX3("EF6_VL_VIN",6), AVSX3("EF6_VL_VIN",3),AVSX3("EF6_VL_VIN",4),"",nil, AVSX3("EF6_VL_VIN",2),nil,nil })
Aadd(aHeader,{AVSX3("EF6_VL_VIN",5),"EF6_VL_VIN",AVSX3("EF6_VL_VIN",6), AVSX3("EF6_VL_VIN",3),AVSX3("EF6_VL_VIN",4),"PV400FieldOK ('M->EF6_VL_VIN')",nil, AVSX3("EF6_VL_VIN",2),nil,nil }) 
Aadd(aHeader,{AVSX3("EF6_TP_FIN",5),"EF6_TP_FIN",AVSX3("EF6_TP_FIN",6), AVSX3("EF6_TP_FIN",3),AVSX3("EF6_TP_FIN",4),"PV400FieldOK ('M->EF6_TP_FIN')",nil, AVSX3("EF6_TP_FIN",2),nil,nil })
Aadd(aHeader,{AVSX3("EF6_VM_FIN",5),"EF6_VM_FIN",AVSX3("EF6_VM_FIN",6), AVSX3("EF6_VM_FIN",3),AVSX3("EF6_VM_FIN",4),"",nil, AVSX3("EF6_VM_FIN",2),nil,nil })
Aadd(aHeader,{AVSX3("EF6_OBS"   ,5),"EF6_OBS"   ,AVSX3("EF6_OBS"   ,6), AVSX3("EF6_OBS"   ,3),AVSX3("EF6_OBS"   ,4),"",nil, AVSX3("EF6_OBS"   ,2),nil,nil })
If nOpc <> 2
  Aadd(aAlter ,"EF6_OBS"   )
  Aadd(aAlter ,"EF6_VL_VIN")  
  Aadd(aAlter ,"EF6_CONTRA")
  If lEFFTpMod
     Aadd(aAlter ,"EF6_SEQCNT")
  EndIf
  Aadd(aAlter ,"EF6_BANCO" )
  Aadd(aAlter ,"EF6_PRACA" )
//  Aadd(aAlter ,"EF6_TP_FIN")
Else
  Aadd(aHeader,{AVSX3("EF6_DT_LIB",5),"EF6_DT_LIB" ,AVSX3("EF6_DT_LIB",6), AVSX3("EF6_DT_LIB",3),AVSX3("EF6_DT_LIB",4),"",nil, AVSX3("EF6_DT_LIB",2),nil,nil }) 
EndIF
EF6->(DBClearFilter())
If EasyEntryPoint("EFFPV400")                       
   ExecBlock("EFFPV400",.F.,.F.,"ANTES_GERADADOS")
EndIf
oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o programa todo
If nOpc != 6                               
   If nOpc = 3
      If  PV400FltInv()
         cDel := "PV400Del()"
         If Len(aCols) = 0
            MsgInfo(STR0012) //"Não existem invoices para pre-vinculção"
            Return .F.
         EndIf
      Else
         Return .F.
      EndIf  
   Else
      //PV400Altera(nOpc)
      cSeek     := ""
      cWhile    := ""
      FillGetDados(nOpc,"EF6",1,cSeek,{||&cWhile},{||.T.},,,,,{ || PV400Altera(nOpc) },,,,,,,)
      If Len(aCols) = 0
         MsgInfo(STR0013) //"A pre-vinculação ja foi efetivada e não pode ser alterada"
         Return .F.
      EndIf
      cDel := "PV400Del(.T.)"
   EndIf
   If lError1
      MsgInfo(cError1)
      If nOpc!=VISUALIZAR
         Return .F.
      EndIf
   EndIf
   If lError2
      MsgInfo(cError2)
      If nOpc!=VISUALIZAR
         Return .F.
      EndIf
   EndIf 
   If lError3
      MsgInfo(cError3)
      If nOpc!=VISUALIZAR
         Return .F.
      EndIf
   EndIf
   DEFINE MSDIALOG oDlg TITLE STR0014 FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd  PIXEL //"Pre-Vinculação"
      DbSelectArea("EF6")
      oGet := MsGetDados():New(30,000,FINAL_SELECT,COLUNA_FINAL, 3,"PV400LinOK()","AlwaysTrue()","AlwaysTrue()" ,.F.,aAlter,.T.,,1500,"AlwaysTrue()",nil,nil,cDel )
      oGet:oBROWSE:BADD  := {|| .F. } 
      oGet:oBrowse:bWhen := {|| DbSelectArea("EF6")}
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(PV400Valid(),(lOk:=.T.,oDlg:End()),)},{||oDlg:End()},,aBotao) CENTERED
   If lOk
      EF6->(DbSetOrder(2))
      For i := 1 to Len(aCols)
         If !Empty(GdFieldGet("EF6_CONTRA",i) ) .And. ; //.And. !Empty(GdFieldGet("EF6_BANCO",i) ) .And. !Empty(GdFieldGet("EF6_PRACA",i) )
         GdFieldGet("EF6_VL_VIN",i) > 0 .And.  aCols[i][Len(aHeader)+2] == .F.
//            EF6->(dbSetOrder(2))
            If nOpc==3 .Or. nOpc==4
//               If(lMultiFil,aCols[i][10] == EF6->EF6_CONTRA .AND. aCols[i][11] == EF6->EF6_BANCO .AND. aCols[i][12] == EF6->EF6_PRACA,;
//               aCols[i][9] == EF6->EF6_CONTRA .AND. aCols[i][10] == EF6->EF6_BANCO .AND. aCols[i][11] == EF6->EF6_PRACA))
               //** PLB 13/03/06
               If nOpc==4
                  EF6->(DBSeek(cFilEF6+aKeyEF6[i]))
                  Do While !EF6->( EOF() ) .And. aKeyEF6[i] == EF6->EF6_PREEMB+EF6->EF6_NRINVO+EF6->EF6_PARC .And. ;
                           aOldKey[i] != EF6->EF6_CONTRA+EF6->EF6_BANCO+EF6->EF6_PRACA+IIF(lEFFTpMod,EF6->EF6_SEQCNT,"")+Str(EF6->EF6_VL_VIN)
                     EF6->( DBSkip() )
                  EndDo
               EndIf            
               //**
               EF6->(RecLock("EF6",If (nOpc=3,.T.,.F.)))
               For ni := 1 to Len(aHeader)
                  EF6->&(aHeader[ni][2]) := aCols[i][ni]
               Next
               EF6->EF6_MOEDA  := GdFieldGet("EEC_MOEDA" ,i) 
               EF6->EF6_DTEMBA := GdFieldGet("EEC_DTEMBA" ,i)
               EF6->EF6_FILORI := aCols[i][Len(aHeader)+1]
               EF6->EF6_FILIAL := cFilEF6
               EF6->(MsUnlock())                    
            EndIf
         EndIf    
      Next
      EF6->(DbGoTop())
      For i:= 1 to Len(aDel)
         If EF6->(DbSeek(cFIlEF6+aDEl[i][1]+aDel[i][2]+aDel[i][3])) .AND. ;
         aDel[i][4] == EF6->EF6_CONTRA .AND. aDel[i][5] == EF6->EF6_BANCO .AND. aDel[i][6] == EF6->EF6_PRACA .And. IIF(lEFFTpMod,aDel[i][7] == EF6->EF6_SEQCNT,.T.)
            RecLock("EF6", .f.)
            EF6->( DBDelete() )
            EF6->( MSUnlock() )
         EndIf   
      Next
   EndIf 
EndIf
Filtra()                       
If nOpc == 3 .and. lOk
   PV400Inclui := .F.
EndIf
Return .F.     

*-----------------------------------*
Function PV400FltInv(lEfetiva)
*-----------------------------------*                                              
Local lRet := .f.
Local oCmbFil
Local aPos
Local nFil
Local i, oComboTpCo, aTpCon:={STR0065,STR0066} //"1-Cambio de Exportacao" # "3-Recebimento tipo 3"
Private cTpCon := "1"   // GFC - 26/01/06
Private cQuery
Private oDlg                                     
Default lEfetiva := .F.
cFiliais := "'"
aFiliais := If (lMultiFil,AvgSelectFil(.T.),{cFIlEEQ})
If aFiliais[1]=="WND_CLOSE"
   Return .F.
EndIf
dVencIni   := dVencFim  := CtoD(Space(8))   
cInvoice   := cProcesso := Space(20)		
nValIni    := nValFim   := 0				
cCliente   := Space(15) 			 		
cCondPagto := Space(5)		    	     	
cLojaCli   := Space (2)	    	     	
nDias      := 0  
Private aEmbarcado    := {STR0015,STR0016}                        //"1-Embarcado"###"2-Não Embarcado"
Private cEmbarcado  := "1"
aEval(aFiliais,{|x,y| cFiliais += x + iIF(y == Len(aFiliais),"'","','")})
If oMainWnd:nRight > 804 
   aPos:={oMainWnd:nTop+125,oMainWnd:nLeft+55,If(SetMdiChild(),oMainWnd:nBottom-100,oMainWnd:nBottom-290),oMainWnd:nRight - 500 }      
Else
   aPos:={oMainWnd:nTop+125,oMainWnd:nLeft+55,If(SetMdiChild(),oMainWnd:nBottom-10,oMainWnd:nBottom-100),oMainWnd:nRight-270}
EndIf
DEFINE MSDIALOG oDlg TITLE  STR0017  FROM  aPos[1] , aPos[2] TO aPos[3]/*/1.7*/ , aPos[4]/*/2*/ OF oMainWnd PIXEL  //"Filtro das invoices"

   @002,002 SAY   STR0018                of oDlg     //"Vencimento Inicial"
   @002,008 MSGET dVencIni                                           SIZE 60,8
   @002,016 Say   STR0019               of oDlg     //"Final"
   @002,018 MSGET dVencFim                                           SIZE 60,8
   @003,002 Say   STR0020                of oDlg      //"Invoice"
   @003,008 MSGET cInvoice   Pict AVSX3("EEC_NRINVO",6)              SIZE 60,8 
   @004,002 Say   STR0021                of oDlg     //"Processo"
   @004,008 MSGET cProcesso  Pict AVSX3("EEC_PREEMB",6)  F3 "EEC"  Valid AvgExistCpo("EEC",cProcesso) SIZE 60,8 
   @005,002 Say   STR0022                of oDlg      //"Valor Entre"
   @005,008 MSGET nValIni    Pict AVSX3("EEQ_VL",6)                  SIZE 60,8    
   @005,016 Say   STR0023                of oDlg     //"e"
   @005,018 MSGET nValFim    Pict AVSX3("EEQ_VL",6)                  SIZE 60,8
   @006,002 Say   STR0024                of oDlg      //"Cliente"
   @006,008 MSGET cCliente   Pict AVSX3("EEC_CLIENT",6)   F3 "SA1"   SIZE 60,8 
   @006,016 Say   STR0092                of oDlg      //"Loja Cliente"
   @006,018 MSGET cLojaCli   Pict AVSX3("EEC_CLLOJA",6)   WHEN .F.   SIZE 5,8  //ASK 18/12/2007 - Incluído o campo Loja Cliente
   @007,002 Say   STR0025                of oDlg      //"Condição de Pagto"
   @007,008 MSGET cCondPagto Pict AVSX3("EEC_CONDPA",6)   F3 "SY6"   SIZE 60,8
   @007,016 Say   STR0026                of oDlg    //  //"Dias"
   @007,018 MSGET nDias      Pict AVSX3("EEC_DIASPA",6)              SIZE 60,8
   If !lEfetiva
      @008,002 SAY   STR0027                of oDlg     //"Embarcado"
      @008,008 COMBOBOX cEmbarcado ITEMS aEmbarcado  SIZE 60,08 
      
      @008,016 SAY   AVSX3("EEQ_TP_CON",5)  of oDlg    // "Tipo Contra."
      @008,020 ComboBox oComboTpCo Var cTpCon Items aTpCon SIZE 80,08 When Left(cEmbarcado,1) == "1"
   EndIf
   Define sButton from 150,160 Type 1 Action(  lRet:=.t., oDlg:End() ) Enable of oDlg Pixel  //TRP-20/02/08-Ajuste na posição dos botões de OK e Cancel.
   Define sButton from 150,195 Type 2 Action(  lRet:=.f., oDlg:End() ) Enable of oDlg Pixel
   If EasyEntryPoint("EFFPV400")
      ExecBlock("EFFPV400",.F.,.F.,"FILTRA_INV")
   EndIf
ACTIVATE MSDIALOG oDlg CENTERED

// ------------------------------------------------------------- //
If lRet  .And. !lEfetiva
   cFiliais := StrTran(cFiliais,",'"+Alltrim(EasyGParam("MV_AVG0024",,""))+"'")
   If Right(Alltrim(cFiliais),1) == ","
      cFil := Left(cFiliais,len(cFiliais)-1)
   EndIf
   If Left(cEmbarcado,1) == "1"
      PV400Invoices()
   Else    
      PV400SemInv()
   EndIf
Endif

Return lRet

*-----------------------------*
Static Function PV400Invoices()
*-----------------------------*
Local cCond:="" 
Local aCondDel:={"AND EEC.D_E_L_E_T_ <> '*' ","AND EEQ.D_E_L_E_T_ <> '*' "}
Local nValVinc
Local i
If lTop
   
   If Left(cTpCon,1) == "1"
      If !lMultiFil 
         cCond+="EEC.EEC_FILIAL='"+xFilial("EEC")+"' "+If(TcSrvType()<>"AS/400",aCondDel[1],"")
      Else
         cCond+="EEC.EEC_FILIAL IN ("+cFiliais+") "+If(TcSrvType()<>"AS/400",aCondDel[1],"")
      EndIf
      cCond+="AND EEC.EEC_STATUS <> '*' "
      cCond+="AND EEQ.EEQ_PREEMB = EEC.EEC_PREEMB "
      If !lMultiFil 
         cCond+="AND EEQ.EEQ_FILIAL='"+xFilial("EEQ")+"' "+If(TcSrvType()<>"AS/400",aCondDel[2],"")
      Else                                                                                         
         cCond+="AND EEQ.EEQ_FILIAL IN ("+cFiliais+") "+If(TcSrvType()<>"AS/400",aCondDel[2],"")
      EndIf
      cCond+="AND ( EEQ.EEQ_NRINVO <> '' OR EEQ.EEQ_NRINVO <> ' '    ) "
      cCond+="AND ( EEQ.EEQ_PGT = '' OR EEQ.EEQ_PGT = ' '            ) "   
      cCond+="AND ((EEQ.EEQ_FI_TOT <> 'N' AND EEQ.EEQ_FI_TOT <> 'S') "
      cCond+="OR (EEQ.EEQ_FI_TOT = 'N' AND EEQ.EEQ_VL_PAR-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ > 0)) "
      cCond+="AND EEQ.EEQ_EVENT = '101' "
     
      If .not. Empty( dVencIni ) 
         cCond+="AND EEQ.EEQ_VCT >= '" + DtoS( dVencIni ) + "' " 
      Endif
      If .not. Empty( dVencFim )
         cCond+="AND EEQ.EEQ_VCT <= '" + DtoS( dVencFim ) + "' "      
      Endif
      If .not. Empty( cInvoice )   
         cCond+="AND  EEC.EEC_NRINVO = '" + Alltrim( cInvoice ) + "' "
      Endif 
      If .not. Empty( cProcesso ) 
         cCond+="AND EEC.EEC_PREEMB = '" + Alltrim( cProcesso ) + "' "
      Endif 
      If .not. Empty( nValIni ) 
         cCond+="AND EEQ.EEQ_VL-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ >= " + Str( nValIni, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
      Endif                    
      If .not. Empty( nValFim )  
         cCond+="AND EEQ.EEQ_VL-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ <= " + Str( nValFim, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
      Endif
      If lEEQ_TP_CON
         cCond+="AND EEQ.EEQ_TP_CON = '1' "
      EndIf
      If .not. Empty( cCliente ) 
         cCond+="AND EEC.EEC_CLIENT = '" + Alltrim( cCliente ) + "' " 
      Endif          
      If .not. Empty( cLojaCli )  //ASK 18/12/2007 - Incluído o campo Loja Cliente
         cCond+="AND EEC.EEC_CLLOJA = '" + Alltrim( cLojaCli ) + "' " 
      Endif          
      If .not. Empty( cCondPagto )
         cCond+="AND EEC.EEC_CONDPA = '" + Alltrim(cCondPagto) + "' AND EEC.EEC_DIASPA = " + Str(nDias, AVSX3("EEC_DIASPA",3), AVSX3("EEC_DIASPA",4) ) + " " 
      Endif    
      cQuery:= " SELECT DISTINCT " +;
               " EEQ.EEQ_NRINVO NRINVO ,EEC.EEC_PREEMB PREEMB, EEQ.EEQ_FI_TOT FI_TOT, "+;
               " EEC.EEC_DTEMBA DTEMBA ,EEC.EEC_MOEDA  MOEDA , "+;
               " EEQ.EEQ_VL-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ VALOR  , EEQ.EEQ_VL_PAR-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ SALDO ,EEQ.EEQ_PARC PARC  , "  
      cQuery+= " EEQ.EEQ_FILIAL FILORI "  
      If lExistForn   
         cQuery+=  " ,EEQ.EEQ_FORN FORN , EEQ.EEQ_FOLOJA LOJA"  
      EndIf
      cQuery+= " FROM "+RetSqlName("EEC")+" EEC, "+RetSqlName("EEQ")+" EEQ WHERE "+cCond+;
               " ORDER BY FILORI, PREEMB,NRINVO"
   
   ElseIf Left(cTpCon,1) == "3"
      aCondDel:={"AND EEQ.D_E_L_E_T_ <> '*' "}
      
      If !lMultiFil 
         cCond+="EEQ.EEQ_FILIAL='"+xFilial("EEQ")+"' "+If(TcSrvType()<>"AS/400",aCondDel[1],"")
      Else                                                                                         
         cCond+="EEQ.EEQ_FILIAL IN ("+cFiliais+") "+If(TcSrvType()<>"AS/400",aCondDel[1],"")
      EndIf
      cCond+="AND ( EEQ.EEQ_NRINVO <> '' OR EEQ.EEQ_NRINVO <> ' '    ) "
      cCond+="AND ( EEQ.EEQ_PGT = '' OR EEQ.EEQ_PGT = ' '            ) "   
      cCond+="AND ((EEQ.EEQ_FI_TOT <> 'N' AND EEQ.EEQ_FI_TOT <> 'S') "
      cCond+="OR (EEQ.EEQ_FI_TOT = 'N' AND EEQ.EEQ_VL_PAR-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ > 0)) "
      cCond+="AND EEQ.EEQ_EVENT = '101' "
     
      If .not. Empty( dVencIni ) 
         cCond+="AND EEQ.EEQ_VCT >= '" + DtoS( dVencIni ) + "' " 
      Endif                      
      If .not. Empty( dVencFim )
         cCond+="AND EEQ.EEQ_VCT <= '" + DtoS( dVencFim ) + "' "      
      Endif
      If .not. Empty( cInvoice )   
         cCond+="AND  EEQ.EEQ_NRINVO = '" + Alltrim( cInvoice ) + "' "
      Endif 
      If .not. Empty( cProcesso ) 
         cCond+="AND EEQ.EEQ_PREEMB = '" + Alltrim( cProcesso ) + "' "
      Endif 
      If .not. Empty( nValIni ) 
         cCond+="AND EEQ.EEQ_VL-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ >= " + Str( nValIni, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
      Endif                    
      If .not. Empty( nValFim )  
         cCond+="AND EEQ.EEQ_VL-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ <= " + Str( nValFim, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
      Endif
      If lEEQ_TP_CON
         cCond+="AND EEQ.EEQ_TP_CON = '3' "
      EndIf
      If .not. Empty( cCliente ) 
         cCond+="AND EEQ.EEQ_IMPORT = '" + Alltrim( cCliente ) + "' " 
      Endif          
       If .not. Empty( cLojaCli )  //ASK 18/12/2007 - Incluído o campo Loja Cliente
         cCond+="AND EEQ.EEQ_IMLOJA = '" + Alltrim( cLojaCli ) + "' " 
      Endif          
      cQuery:= " SELECT DISTINCT " +;
               " EEQ.EEQ_NRINVO NRINVO ,EEQ.EEQ_PREEMB PREEMB, EEQ.EEQ_FI_TOT FI_TOT, "+;
               " EEQ.EEQ_SOL DTEMBA ,EEQ.EEQ_MOEDA  MOEDA , "+;
               " EEQ.EEQ_VL-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ VALOR  , EEQ.EEQ_VL_PAR-EEQ.EEQ_CGRAFI-EEQ.EEQ_ADEDUZ SALDO ,EEQ.EEQ_PARC PARC  , "  
      cQuery+= " EEQ.EEQ_FILIAL FILORI "  
      If lExistForn   
         cQuery+=  " ,EEQ.EEQ_FORN FORN , EEQ.EEQ_FOLOJA LOJA"  
      EndIf
      cQuery+= " FROM "+RetSqlName("EEQ")+" EEQ WHERE "+cCond+;
               " ORDER BY FILORI, PREEMB,NRINVO"
   EndIf
   
   If EasyEntryPoint("EFFPV400")                       
      ExecBlock("EFFPV400",.F.,.F.,"QRY_FILTRA_INV")
   EndIf
   cQuery:=ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","DTEMBA","D")
   dbSelectArea("TRB")
   TRB->(dbGoTop())
   Do While !TRB->(EOF())
     nValVinc :=  ( If(TRB->FI_TOT <> "N" , TRB->VALOR , TRB->SALDO ) -  SaldoEF6(,TRB->PREEMB+TRB->NRINVO+TRB->PARC,.F.) )
     If nValVinc >  0                                    
       Aadd(aCols,Array(Len(aHeader)+2))
       aCols[Len(aCols)][Len(aHeader)+1] := TRB->FILORI 
       //aAdd(aInvoice,{TRB->PREEMB,TRB->NRINVO,TRB->PARC,0})
       GDFieldPut("EF6_PREEMB",TRB->PREEMB,Len(aCols)) 
       GDFieldPut("EF6_NRINVO",TRB->NRINVO,Len(aCols)) 
       GDFieldPut("EEC_DTEMBA",TRB->DTEMBA,Len(aCols))       
       GDFieldPut("EEC_MOEDA" ,TRB->MOEDA,Len(aCols))          
       GdFieldPut("EF6_VL_INV" , TRB->VALOR ,Len(aCols))                
       GdFieldPut("EF6_VL" , nValVinc ,Len(aCols))             
       GdFieldPut("EF6_PARC" ,TRB->PARC  ,Len(aCols))             
       GdFieldPut("EF6_OBS"   ,CriaVar("EF6_OBS"),Len(aCols))              
       If lExistForn
          GdFieldPut("EF6_CLIENT",TRB->FORN  ,Len(aCols))              
          GdFieldPut("EF6_CLLOJA"  ,TRB->LOJA  ,Len(aCols))             
       EndIf   
       GdFieldPut("EF6_CONTRA",CriaVar("EF6_CONTRA"),Len(aCols))             
       GdFieldPut("EF6_BANCO",CriaVar("EF6_BANCO" ),Len(aCols))             
       GdFieldPut("EF6_PRACA" ,CriaVar("EF6_PRACA" ),Len(aCols))             
       If lEFFTpMod
          GdFieldPut("EF6_SEQCNT",CriaVar("EF6_SEQCNT"),Len(aCols))             
          GdFieldPut("EF6_TP_VIN" ,"1",Len(aCols))              
       EndIf
//       GdFieldPut("EF6_TP_FIN",CriaVar("EF6_TP_FIN"),Len(aCols))              
//       GdFieldPut("EF6_VM_FIN",Posicione("SX5",1,xFilial("SX5")+"CG"+"01","X5_DESCRI"),Len(aCols))
//       GdFieldPut("EF6_VL_VIN",CriaVar("EF6_VL_VIN"),Len(aCols))
       GdFieldPut("EF6_VL_VIN" , nValVinc ,Len(aCols))                                
       GdFieldPut("EF6_DT_LIB" ,CriaVar("EF6_DT_LIB"),Len(aCols))                    
       aCols[Len(aCols)][Len(aHeader) +2] := .F.
       If lMulTiFil
          GdFieldPut("EF6_FILORI" ,AvgFilName({TRB->FILORI })[1],Len(aCols))                   
       EndIf
       If EasyEntryPoint("EFFPV400")                       
          ExecBlock("EFFPV400",.F.,.F.,"GRV_ACOLS_INV")
       EndIf
     EndIf  
     TRB->(dbSkip())                                                    
   EndDo
   TRB->( DbCloseArea() )
Else
   cCond := ""
   If .not. Empty( dVencIni ) 
      cCond+="EEQ->EEQ_VCT >= dVencIni "
   Endif                      
   If .not. Empty( dVencFim )
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEQ->EEQ_VCT <= dVencFim " 
   Endif
   If .not. Empty( cInvoice )   
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_NRINVO = '" + Alltrim( cInvoice ) + "' "
   Endif 
   If .not. Empty( cProcesso ) 
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_PREEMB = '" + Alltrim( cProcesso ) + "' "
   Endif 
   If .not. Empty( nValIni ) 
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "(EEQ->EEQ_VL-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ) >= nValIni "
   End
   If .not. Empty( nValFim )                
      cCond+=iif(.not. Empty(cCond), ".AND.","") + "(EEQ->EEQ_VL-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ)  <= nValFim "
   Endif
   If .not. Empty( cCliente ) 
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_CLIENT = '" + Alltrim( cCliente ) + "' "
   Endif          
   If .not. Empty( cLojaCli ) //ASK 18/12/2007 - Incluído o campo Loja Cliente
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_CLLOJA  = '" + Alltrim( cLojaCli ) + "' "
   Endif        
   If .not. Empty( cCondPagto )
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_CONDPA = '" + Alltrim(cCondPagto) + "' .AND. EEC->EEC_DIASPA = nDias" 
   Endif  
   If Empty (cCond)
      cCond := ".t."
   Endif
   EEQ->(DbSetOrder(1))
   EEC->(DbSetOrder(1))
   For i:=1 to Len(aFiliais)
      EEC->(DbSeek(aFiliais[i]))
      Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL == aFiliais[i]  
         If EEC->EEC_STATUS <> '*'
            If EEQ->(dbSeek(aFiliais[i]+EEC->EEC_PREEMB)) 
               Do While !EEQ->(EOF()) .and. EEQ->EEQ_PREEMB == EEC->EEC_PREEMB
                  If !Empty(EEQ->EEQ_NRINVO) .and. EEQ->EEQ_EVENT == '101' .and. ;
                    (!EEQ->EEQ_FI_TOT $("N/S") .or. (EEQ->EEQ_FI_TOT == "N" .and. (EEQ->EEQ_VL_PAR-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ) > 0)) .and. !EEQ->EEQ_TIPO $ "AP" .And.; 
                     Empty(EEQ->EEQ_PGT) .AND. &cCond
                      nValVinc :=  ( If(EEQ->EEQ_FI_TOT <> "N" , EEQ->EEQ_VL-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ , EEQ->EEQ_VL_PAR-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ )  -  SaldoEF6(,EEQ->EEQ_PREEMB+EEQ->EEQ_NRINVO+EEQ->EEQ_PARC,.F.) )
                      If nValVinc >  0                                    
                         Aadd(aCols,Array(Len(aHeader)+2))
                         aCols[Len(aCols)][Len(aHeader)+1] := EEQ->EEQ_FILIAL
                         //aAdd(aInvoice,{EEQ->EEQ_PREEMB,EEQ->EEQ_NRINVO,EEQ->EEQ_PARC,0})
                         GDFieldPut("EF6_PREEMB",EEC->EEC_PREEMB,Len(aCols)) 
                         GDFieldPut("EF6_NRINVO",EEQ->EEQ_NRINVO,Len(aCols)) 
                         GDFieldPut("EEC_DTEMBA",EEC->EEC_DTEMBA,Len(aCols))       
                         GDFieldPut("EEC_MOEDA" ,EEC->EEC_MOEDA ,Len(aCols))          
                         GdFieldPut("EF6_VL_INV",EEQ->EEQ_VL    ,Len(aCols))                
                         GdFieldPut("EF6_VL" , nValVinc ,Len(aCols))             
                         GdFieldPut("EF6_PARC" ,EEQ->EEQ_PARC   ,Len(aCols))             
                         GdFieldPut("EF6_OBS"   ,CriaVar("EF6_OBS"),Len(aCols))              
                         If lExistForn
                            GdFieldPut("EF6_CLIENT",EEQ->EEQ_FORN      ,Len(aCols))              
                            GdFieldPut("EF6_CLLOJA",EEQ->EEQ_FOLOJA    ,Len(aCols))             
                         EndIf
                         GdFieldPut("EF6_CONTRA",CriaVar("EF6_CONTRA"),Len(aCols))             
                         GdFieldPut("EF6_BANCO",CriaVar("EF6_BANCO" ),Len(aCols))
                         GdFieldPut("EF6_PRACA" ,CriaVar("EF6_PRACA" ),Len(aCols))
                         If lEFFTpMod
                            GdFieldPut("EF6_SEQCNT",CriaVar("EF6_SEQCNT"),Len(aCols))             
                         EndIf
//                         GdFieldPut("EF6_TP_FIN",CriaVar("EF6_TP_FIN"),Len(aCols))
//                         GdFieldPut("EF6_VM_FIN",Posicione("SX5",1,xFilial("SX5")+"CG"+"01","X5_DESCRI"),Len(aCols))
//                         GdFieldPut("EF6_VL_VIN",CriaVar("EF6_VL_VIN"),Len(aCols))
                         GdFieldPut("EF6_VL_VIN" , nValVinc ,Len(aCols))
                         GdFieldPut("EF6_DT_LIB" ,CriaVar("EF6_DT_LIB"),Len(aCols))
                         aCols[Len(aCols)][Len(aHeader) +2] := .F.
                         If lMulTiFil
                            GdFieldPut("EF6_FILORI" ,AvgFilName({EEQ->EEQ_FILIAL})[1],Len(aCols))
                         EndIf
                      EndIf
                  EndIf
                  EEQ->(dbSkip())
               EndDo
            EndIf
         Endif
         EEC->(DbSkip())
      Enddo
   Next   
Endif
Return .T.

*------------------------------*
Function PV400LinOK()
*------------------------------*
Local lRet := .T.
Local nSaldoVin := 0
Local i
If Len(aCols) > 0
   If  ( !EmpTy(GdFieldGet("EF6_CONTRA",N)) .And. (  EmpTy(GdFieldGet("EF6_BANCO" ,N)) .Or. EmpTy(GdFieldGet("EF6_PRACA",N)) .Or. IIF(lEFFTpMod, Empty(GDFieldGet("EF6_SEQCNT",N)),.F.) ) ) .Or. ;
       (  EmpTy(GdFieldGet("EF6_CONTRA",N)) .And. ( !EmpTy(GdFieldGet("EF6_BANCO" ,N)) .Or. IIF(lEFFTpMod,!Empty(GDFieldGet("EF6_SEQCNT",N)),.F.) .Or. !EmpTy(GdFieldGet("EF6_PRACA",N)) ) )  //PLB - 09/03/06
       MsGInfo(STR0046+", "+IIF(lEFFTpMod,STR0067+", ","")+STR0047+" e "+STR0048+" devem ser preenchidos")  // Contrato ## Sequencia ## Banco ## Praça 
       lRet := .F.
   EndIf     
   If lRet .And. !Empty( GDFieldGet("EF6_CONTRA",n) ) .And. !EF1->( DBSeek( cFilEF1+IIF(lEFFTpMod,"E","")+GdFieldGet("EF6_CONTRA" ,n)+If(lTemPraca,GdFieldGet("EF6_BANCO" ,n)+GdFieldGet("EF6_PRACA" ,n),"")+IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT" ,n),"") ) )
      MsgStop( STR0079+STR0046+" "+AllTrim(GDFieldGet("EF6_CONTRA",n))+IIF(lTemPraca,", "+STR0047+" "+AllTrim(GDFieldGet("EF6_BANCO",n))+", "+STR0048+" "+AllTrim(GDFieldGet("EF6_PRACA",n)),"")+IIF(lEFFTpMod," e "+STR0067+" "+AllTrim(GDFieldGet("EF6_SEQCNT",n)),"")+"." )  // Não existe  Contrato ## Banco ## Praça ## Sequencia 
      lRet := .F.
   Else 
      GDFieldPut("EF6_TP_FIN", Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+GDFieldGet("EF6_CONTRA",n)+IIF(lTemPraca,GDFieldGet("EF6_BANCO",n)+GDFieldGet("EF6_PRACA",n),"")+IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),"EF1_TP_FIN"),n )
      GDFieldPut("EF6_VM_FIN",IIF(lCadFin,Posicione("EF7",1,cFilEF7+GDFieldGet("EF6_TP_FIN",n),"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+GDFieldGet("EF6_TP_FIN",n),"X5_DESCRI")),n)
      PV400Contr(GdFieldGet("EF6_CONTRA" ,n),GdFieldGet("EF6_BANCO" ,n),GDFieldGet("EF6_PRACA",n),IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),GdFieldGet("EEC_MOEDA",n),,aCols[n][Len(aHeader)+1],IIF(lEFFTpMod,GDFieldGet("EF6_TP_VIN",n),"") )
   EndIf
   If lRet .And. ( !EmpTy( GdFieldGet("EF6_CONTRA",N)  ) .OR. !EmpTy( GdFieldGet("EF6_BANCO",N) ) )
      EF1->(DbSeek(cFilEF1+IIF(lEFFTpMod,"E","")+GdFieldGet("EF6_CONTRA" ,n)+If(lTemPraca,GdFieldGet("EF6_BANCO" ,n)+GdFieldGet("EF6_PRACA" ,n),"")+IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT" ,n),"")))
      For i:= 1 To len(aCols)
         If i!=n .And. GdFieldGet("EF6_CONTRA" ,i) == GdFieldGet("EF6_CONTRA" ,n) .And. GdFieldGet("EF6_BANCO" ,i) == GdFieldGet("EF6_BANCO" ,n) .And. GdFieldGet("EF6_PRACA" ,i) == GdFieldGet("EF6_PRACA" ,n) .And. IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT" ,i) == GdFieldGet("EF6_SEQCNT" ,n) .And. GdFieldGet("EF6_TP_VIN" ,i) == GdFieldGet("EF6_TP_VIN" ,n),.T.)
            nSaldoVin += Round(GdFieldGet("EF6_VL_VIN" ,i) *BuscaTaxa(GdFieldGet("EEC_MOEDA",n),dDataBase,.T.,.F.,.T.) / BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.),2)
         EndIf
      Next
      nPos := aScan(aContra,{|x| x[1] == GdFieldGet("EF6_CONTRA" ,n) .AND. x[2] == GdFieldGet("EF6_BANCO" ,n) .And. x[3] == GdFieldGet("EF6_PRACA" ,n)  .And. IIF(lEFFTpMod,x[5] == GdFieldGet("EF6_SEQCNT" ,n),.T.) } )
      nSaldoVin  := Round(( aContra[nPos][IIF(lEFFTpMod .And. GDFieldGet("EF6_TP_VIN",n)=="2",6,4)]  - nSaldoVin );
                   * BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.) /  BuscaTaxa(GdFieldGet("EEC_MOEDA",n),dDataBase,.T.,.F.,.T.) ,2)
      If nSaldoVin < GdFieldGet("EF6_VL_VIN" ,n)
         MsgInfo(STR0032 +GdFieldGet("EEC_MOEDA",n)+" "+AllTrim(Transform(nSaldoVin,AVSX3("EF6_VL_VIN",6)))) //"O saldo para vinculação a este contrato e de "
         lRet := .F.
      EndIf
    EndIf
EndIf
Return lRet

*------------------------------*
Function PV400FieldOK(cVar)
*------------------------------*
Local cOldAlias  := alias() , i 
Local lQuebra := .T.
Local nDif    := 0
Local lSaldo  := .F.
Local nSaldoCnt := 0
Local nSaldoInv := 0
Local nSAldoAnt := 0                   
Local cBanco := CriaVar("EF6_BANCO" )
Local cPraca := CriaVar("EF6_PRACA" )
Local lRet  := .t., nColAux:=0
Local nFil ,nSaldo         
Local cxFil:= cFilAnt
Local nValTot := 0
Default cVar := ReadVar()
cFilAnt := aCols[n][Len(aHeader)+1]
SetFil()
Do Case
//  Case !Empty(&(cVar)) .And. cVar == "M->EF6_TP_FIN" 
//    GdFieldPut("EF6_VM_FIN",IIF(lCadFin,Posicione("EF7",1,cFilEF7+&(cVar),"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+&(cVar),"X5_DESCRI")),n)

  Case cVar == "M->EF6_CONTRA"
//     If lTemPraca
//          cBanco:= EF1->EF1_BAN_FI
//          cPraca:= EF1->EF1_PRACA
//     EndIf
     If ( !( !Empty(&(cVar)) .AND. AvgExistCpo("EF1",IIF(lEFFTpMod,"E","")+&(cVar)) ) )  //.Or. !VldContra(&(cVar),cBanco,cPraca,"",aCols[n][Len(aHeader)+1],GdFieldGet("EF6_PREEMB" ,n),GdFieldGet("EF6_NRINVO" ,n),GdFieldGet("EF6_PARC" ,n),.T.)
        &(cVar) := CriaVAr("EF6_CONTRA")
//        GDFieldPut("EF6_CONTRA" ,CriaVAr("EF6_CONTRA"),n)             
        If lTemPraca
           GDFieldPut("EF6_BANCO" ,CriaVar("EF6_BANCO"),n)
           GDFieldPut("EF6_PRACA" ,CriaVar("EF6_PRACA"),n)
        EndIf
        If lEFFTpMod
           GDFieldPut("EF6_SEQCNT" ,CriaVar("EF6_SEQCNT"),n)
           GDFieldPut("EF6_TP_VIN" ,"1",n)
        EndIf
        GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)             
        GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)             
        lRet := .F.  
//     Else
//        If lTemPraca
//          GdFieldPut("EF6_BANCO",cBanco,n)
//          GdFieldPut("EF6_PRACA",cPraca,n)
//        EndIf
//        PV400Contr  (&(cVar),cBanco,cPraca,IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),GdFieldGet("EEC_MOEDA",n),,cxFil)
     EndIf
     If !lRet
        lRet := .T.
     ElseIf EF1->(DBSeek(cFilEF1+IIF(lEFFTpMod,"E","")+&(cVar)+If(lTemPraca,GDFieldGet("EF6_BANCO",n)+GdFieldGet("EF6_PRACA" ,n),"")+IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT" ,n),"")))
        //** PLB 23/03/06 - Não permite pré-vincular mais de uma parte de uma parcela para o mesmo contrato
        nPos := aScan(aCols,{|x| x[GDFieldPos("EF6_CONTRA")] == &(cVar) .And. IIF(lTemPraca,x[GDFieldPos("EF6_BANCO")] == GdFieldGet("EF6_BANCO" ,n) .And. x[GDFieldPos("EF6_PRACA")] == GdFieldGet("EF6_PRACA" ,n),.T.) .And. IIF(lEFFTpMod,x[GDFieldPos("EF6_SEQCNT")] == GdFieldGet("EF6_SEQCNT" ,n),.T.) .And. x[GDFieldPos("EF6_PARC")] == GdFieldGet("EF6_PARC" ,n) } )
        If nPos > 0 .And. nPos != n
           &(cVar) := CriaVar("EF6_CONTRA")
           If lTemPraca
              GdFieldPut("EF6_BANCO",CriaVar("EF6_BANCO"),n)
              GdFieldPut("EF6_PRACA",CriaVar("EF6_PRACA"),n)
           EndIf
           GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)
           GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)
           If lEFFTpMod
              GDFieldPut("EF6_SEQCNT" ,CriaVar("EF6_SEQCNT"),n)
              GDFieldPut("EF6_TP_VIN" ,"1",n)
           EndIf
           MsgStop(STR0068+STR0069+STR0046+IIF(lTemPraca,", "+STR0047+", "+STR0048,"")+IIF(lEFFTpMod," e "+STR0067,"")+".")   // Esta parcela da Invoice já está pré-vinculada para este Contrato ## Banco ## Praça ## Sequencia 
           lRet := .F.
        Else
        //**
           //** PLB 29/03/06 - Se for Financiamento Parcelado verifica se vincula para Principal ou Juros
           If lEFFTpMod
              If Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+&(cVar)+IIF(lTemPraca,GDFieldGet("EF6_BANCO",n)+GDFieldGet("EF6_PRACA",n),"")+IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),"EF1_CAMTRA") == "1"
                 PV400PrePg()
              Else
                 GDFieldPut( "EF6_TP_VIN" , "1" , n )
              EndIf
           EndIf
           //**
           PV400Contr(&(cVar),If(lTemPraca,GDFieldGet("EF6_BANCO",n),""),IIF(lTemPraca,GdFieldGet("EF6_PRACA" ,n),""),IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),GdFieldGet("EEC_MOEDA",n),,cxFil,IIF(lEFFTpMod,GDFieldGet("EF6_TP_VIN",n),""))
           GDFieldPut("EF6_TP_FIN", Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+&(cVar)+IIF(lTemPraca,GDFieldGet("EF6_BANCO",n)+GDFieldGet("EF6_PRACA",n),"")+IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),"EF1_TP_FIN"),n )
           GDFieldPut("EF6_VM_FIN",IIF(lCadFin,Posicione("EF7",1,cFilEF7+GDFieldGet("EF6_TP_FIN",n),"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+GDFieldGet("EF6_TP_FIN",n),"X5_DESCRI")),n)
        EndIf
     EndIf

  Case cVar == "M->EF6_BANCO"
     If !Empty(&(cVar))
        lRet:=AvgExistCpo("SA6",&(cVAr))
//        If lRet  .AND. !VldContra(GdFieldGet("EF6_CONTRA" ,n),&(cVar),GdFieldGet("EF6_PRACA" ,n),IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),aCols[n][Len(aHeader)+1],GdFieldGet("EF6_PREEMB" ,n),GdFieldGet("EF6_NRINVO" ,n),GdFieldGet("EF6_PARC" ,n),.T.)
//           lRet := .F.
//        EndIf      
        If /*lRet .AND.*/ !Empty( GdFieldGet("EF6_CONTRA" ,n) ) .And. !Empty( GdFieldGet("EF6_PRACA" ,n) ) .AND. IIF(lEFFTpMod,!Empty(GDFieldGet("EF6_SEQCNT",n)),.T.) .And. EF1->(DbSeek(cFilEF1+IIF(lEFFTpMod,"E","")+GDFieldGet("EF6_CONTRA",n)+If(lTemPraca,&(cVar)+GdFieldGet("EF6_PRACA" ,n),"")+IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT" ,n),"")))
           //** PLB 23/03/06 - Não permite pré-vincular mais de uma parte de uma parcela para o mesmo contrato
           nPos := aScan(aCols,{|x| x[GDFieldPos("EF6_CONTRA")] == GdFieldGet("EF6_CONTRA",n) .And. x[GDFieldPos("EF6_BANCO")] == &(cVar) .And. x[GDFieldPos("EF6_PRACA")] == GdFieldGet("EF6_PRACA" ,n) .And. IIF(lEFFTpMod,x[GDFieldPos("EF6_SEQCNT")] == GdFieldGet("EF6_SEQCNT" ,n),.T.) .And. x[GDFieldPos("EF6_PARC")] == GdFieldGet("EF6_PARC" ,n) } )
           If nPos > 0 .And. nPos != n
              &(cVar) := CriaVar("EF6_BANCO")
              GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)
              GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)
              If lEFFTpMod
                 GDFieldPut("EF6_TP_VIN" ,"1",n)
              EndIf
              MsgStop(STR0068+STR0069+STR0046+", "+STR0047+", "+STR0048+IIF(lEFFTpMod," e "+STR0067,"")+".")   // Esta parcela da Invoice já está pré-vinculada para este Contrato ## Banco ## Praça ## Sequencia
              lRet := .F.
           Else
           //**
              //** PLB 29/03/06 - Se for Financiamento Parcelado verifica se vincula para Principal ou Juros
              If lEFFTpMod
                 If Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+GdFieldGet("EF6_CONTRA" ,n)+&(cVar)+GDFieldGet("EF6_PRACA",n)+IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),"EF1_CAMTRA") == "1"
                    PV400PrePg()
                 Else
                    GDFieldPut( "EF6_TP_VIN" , "1" , n )
                 EndIf
              EndIf
              //**
              GDFieldPut("EF6_TP_FIN", Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+GDFieldGet("EF6_CONTRA",n)+IIF(lTemPraca,&(cVar)+GDFieldGet("EF6_PRACA",n),"")+IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),"EF1_TP_FIN"),n )
              GDFieldPut("EF6_VM_FIN",IIF(lCadFin,Posicione("EF7",1,cFilEF7+GDFieldGet("EF6_TP_FIN",n),"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+GDFieldGet("EF6_TP_FIN",n),"X5_DESCRI")),n)
              PV400Contr  (GdFieldGet("EF6_CONTRA" ,n),&(cVar),GdFieldGet("EF6_PRACA" ,n),IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),GdFieldGet("EEC_MOEDA",n),,cxFil,IIF(lEFFTpMod,GDFieldGet("EF6_TP_VIN",n),""))
           EndIf
        Else
           GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)             
           GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)             
           If lEFFTpMod
              GDFieldPut("EF6_TP_VIN" ,"1",n)
           EndIf
        EndIf
     Else
        GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)             
        GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)             
        If lEFFTpMod
           GDFieldPut("EF6_TP_VIN" ,"1",n)
        EndIf
     EndIf

  Case cVar == "M->EF6_PRACA"
     If !Empty(&(cVar))
        lRet:=AvgExistCpo("EF5",&(cVAr))
//        If lRet .And. !VldContra(GdFieldGet("EF6_CONTRA" ,n),GdFieldGet("EF6_BANCO" ,n),&(cVar),IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),aCols[n][Len(aHeader)+1],GdFieldGet("EF6_PREEMB" ,n),GdFieldGet("EF6_NRINVO" ,n),GdFieldGet("EF6_PARC" ,n),.T.)
//           lRet := .F.
//        EndIf      
        If /*lRet .AND.*/ !Empty( GdFieldGet("EF6_CONTRA" ,n) ) .And. !Empty( GdFieldGet("EF6_BANCO" ,n) ) .AND. IIF(lEFFTpMod,!Empty(GDFieldGet("EF6_SEQCNT",n)),.T.) .And. EF1->(DbSeek(cFilEF1+IIF(lEFFTpMod,"E","")+GdFieldGet("EF6_CONTRA" ,n)+If(lTemPraca,GdFieldGet("EF6_BANCO" ,n)+&(cVar),"")+IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT" ,n),"")))
           //** PLB 23/03/06 - Não permite pré-vincular mais de uma parte de uma parcela para o mesmo contrato
           nPos := aScan(aCols,{|x| x[GDFieldPos("EF6_CONTRA")] == GdFieldGet("EF6_CONTRA",n) .And. x[GDFieldPos("EF6_BANCO")] == GdFieldGet("EF6_BANCO",n) .And. x[GDFieldPos("EF6_PRACA")] == &(cVar) .And. IIF(lEFFTpMod,x[GDFieldPos("EF6_SEQCNT")] == GdFieldGet("EF6_SEQCNT" ,n),.T.) .And. x[GDFieldPos("EF6_PARC")] == GdFieldGet("EF6_PARC" ,n) } )
           If nPos > 0  .And.  nPos != n
              &(cVar) := CriaVar("EF6_PRACA")
              GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)
              GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)
              If lEFFTpMod
                 GDFieldPut("EF6_TP_VIN" ,"1",n)
              EndIf
              MsgStop(STR0068+STR0069+STR0046+", "+STR0047+", "+STR0048+IIF(lEFFTpMod," e "+STR0067,"")+".")   // Esta parcela da Invoice já está pré-vinculada para este Contrato ## Banco ## Praça ## Sequencia 
              lRet := .F.
           Else
           //**
              //** PLB 29/03/06 - Se for Pre-pagamento verifica se vinculacao e para o Principal ou Juros
              If lEFFTpMod
                 If Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+GdFieldGet("EF6_CONTRA" ,n)+GDFieldGet("EF6_BANCO",n)+&(cVar)+IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),"EF1_CAMTRA") == "1"
                    PV400PrePg()
                 Else
                    GDFieldPut( "EF6_TP_VIN" , "1" , n )
                 EndIf
              EndIf
              //**
              GDFieldPut("EF6_TP_FIN", Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+GDFieldGet("EF6_CONTRA",n)+IIF(lTemPraca,GDFieldGet("EF6_BANCO",n)+&(cVar),"")+IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),"EF1_TP_FIN"),n )
              GDFieldPut("EF6_VM_FIN",IIF(lCadFin,Posicione("EF7",1,cFilEF7+GDFieldGet("EF6_TP_FIN",n),"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+GDFieldGet("EF6_TP_FIN",n),"X5_DESCRI")),n)
              PV400Contr(GdFieldGet("EF6_CONTRA" ,n),GdFieldGet("EF6_BANCO" ,n),&(cVar),IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",n),""),GdFieldGet("EEC_MOEDA",n),,cxFil,IIF(lEFFTpMod,GDFieldGet("EF6_TP_VIN",n),""))
           EndIf
        Else
           GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)             
           GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)             
           If lEFFTpMod   
              GDFieldPut("EF6_TP_VIN" ,"1",n)
           EndIf
        EndIf
     Else
        GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)             
        GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)             
        If lEFFTpMod
           GDFieldPut("EF6_TP_VIN" ,"1",n)
        EndIf
     EndIf

  //** PLB 13/03/06
  Case cVar == "M->EF6_SEQCNT"
     If !Empty(&(cVar))
        If lRet .And. !Empty( GDFieldGet("EF6_CONTRA",n) ) .And. !EF1->( DBSeek( cFilEF1+"E"+GdFieldGet("EF6_CONTRA" ,n)+If(lTemPraca,GdFieldGet("EF6_BANCO" ,n)+GdFieldGet("EF6_PRACA" ,n),"")+&(cVar) ) )
           MsgStop( STR0079+STR0046+" "+AllTrim(GDFieldGet("EF6_CONTRA",n))+IIF(lTemPraca,", "+STR0047+" "+AllTrim(GDFieldGet("EF6_BANCO",n))+", "+STR0048+" "+AllTrim(GDFieldGet("EF6_PRACA",n)),"")+" e "+STR0067+" "+AllTrim(&(cVar))+"." )  // Não existe ## Contrato ## Banco ## Praça ## Sequencia 
           lRet := .F.
        EndIf
        If lRet .And. !VldContra(GdFieldGet("EF6_CONTRA" ,n),GdFieldGet("EF6_BANCO" ,n),GdFieldGet("EF6_PRACA" ,n),&(cVar),aCols[n][Len(aHeader)+1],GdFieldGet("EF6_PREEMB" ,n),GdFieldGet("EF6_NRINVO" ,n),GdFieldGet("EF6_PARC" ,n),.T.)
           lRet := .F.
        EndIf      
        If lRet .AND. !Empty( GdFieldGet("EF6_CONTRA" ,n) ) .And. !Empty( GdFieldGet("EF6_BANCO" ,n) ) .AND. !Empty( GdFieldGet("EF6_PRACA" ,n) ) .And. EF1->(DbSeek(cFilEF1+"E"+GdFieldGet("EF6_CONTRA" ,n)+IIF(lTemPraca,GdFieldGet("EF6_BANCO" ,n)+GdFieldGet("EF6_PRACA" ,n),"")+&(cVar)))
           If Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+GdFieldGet("EF6_CONTRA" ,n)+IIF(lTemPraca,GDFieldGet("EF6_BANCO",n)+GDFieldGet("EF6_PRACA",n),"")+&(cVar),"EF1_CAMTRA") == "1"
              PV400PrePg()
           Else
              GDFieldPut( "EF6_TP_VIN" , "1" , n )
           EndIf
           GDFieldPut("EF6_TP_FIN", Posicione("EF1",1,cFilEF1+"E"+GDFieldGet("EF6_CONTRA",n)+IIF(lTemPraca,GDFieldGet("EF6_BANCO",n)+GDFieldGet("EF6_PRACA",n),"")+&(cVar),"EF1_TP_FIN"),n )
           GDFieldPut("EF6_VM_FIN",IIF(lCadFin,Posicione("EF7",1,cFilEF7+GDFieldGet("EF6_TP_FIN",n),"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+GDFieldGet("EF6_TP_FIN",n),"X5_DESCRI")),n)
           PV400Contr(GdFieldGet("EF6_CONTRA" ,n),GdFieldGet("EF6_BANCO" ,n),GdFieldGet("EF6_PRACA" ,n),&(cVar),GdFieldGet("EEC_MOEDA",n),,cxFil,IIF(lEFFTpMod,GDFieldGet("EF6_TP_VIN",n),""))
        Else
           GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)             
           GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)             
           GDFieldPut("EF6_TP_VIN" ,"1",n)
        EndIf         
     Else
        GDFieldPut("EF6_TP_FIN" ,CriaVar("EF6_TP_FIN"),n)             
        GDFieldPut("EF6_VM_FIN" ,CriaVar("EF6_VM_FIN"),n)             
        GDFieldPut("EF6_TP_VIN" ,"1",n)
     EndIf
  //**

  Case cVar   == "M->EF6_VL_VIN"
    If Empty( GdFieldGet("EF6_CONTRA" ,n) ) .OR. Empty( GdFieldGet("EF6_BANCO" ,n) ) .OR. Empty( GdFieldGet("EF6_PRACA" ,n) ) .Or. IIF(lEFFTpMod,Empty( GDFieldGet("EF6_SEQCNT" ,n) ),.F.)
       MsgInfo(STR0029+IIF(lEFFTpMod," e sequencia","")) //"É necessario informar o numero do contrato , banco e praça"
       lRet := .F. 
//    ElseIf &(cVar) = 0 .And. &(cVar) != GdFieldGet("EF6_VL_VIN" ,n)
    ElseIf &(cVar) <=0  // PLB 31/03/06
       MSgInfo(STR0062) //"O Valor da Pré-Vinculação deve ser maior que zero."
       lRet := .F.
    Else 
       EF1->(DbSeek(cFilEF1+IIF(lEFFTpMod,"E","")+GdFieldGet("EF6_CONTRA" ,n)+If(lTemPraca,GdFieldGet("EF6_BANCO" ,n)+GdFieldGet("EF6_PRACA" ,n),"")+IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT" ,n),"")))
       For i:= 1 To len(aCols)
          If i!=n .And. GdFieldGet("EF6_CONTRA" ,i) == GdFieldGet("EF6_CONTRA" ,n) .And. GdFieldGet("EF6_BANCO" ,i) == GdFieldGet("EF6_BANCO" ,n) .And. GdFieldGet("EF6_PRACA" ,i) == GdFieldGet("EF6_PRACA" ,n) .And. IIF(lEFFTpMod,(GdFieldGet("EF6_SEQCNT" ,i) == GdFieldGet("EF6_SEQCNT" ,n) .And. GdFieldGet("EF6_TP_VIN" ,i) == GdFieldGet("EF6_TP_VIN" ,n)),.T.)
             nSaldoCnt += Round(GdFieldGet("EF6_VL_VIN" ,i) *BuscaTaxa(GdFieldGet("EEC_MOEDA",n),dDataBase,.T.,.F.,.T.) / BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.),2)
          EndIf
          If i!=n .And. GdFieldGet("EF6_NRINVO" ,n) == GdFieldGet("EF6_NRINVO" ,i) .And. GdFieldGet("EF6_PARC" ,n) == GdFieldGet("EF6_PARC" ,i) 
             If (!Empty( GdFieldGet("EF6_CONTRA" ,i) ) .OR. !Empty( GdFieldGet("EF6_BANCO" ,i) ) )
                nSaldoInv += GdFieldGet("EF6_VL_VIN" ,i)
             ElseIf nOption == INCLUIR
                lQuebra := .F.
                nQuebra := i
             EndIf
          EndIf
       Next
       nPos := aScan(aContra,{|x| x[1] == GdFieldGet("EF6_CONTRA" ,n) .AND. x[2] == GdFieldGet("EF6_BANCO" ,n) .And. x[3] == GdFieldGet("EF6_PRACA" ,n) .And. IIF(lEFFTpMod,x[5] == GdFieldGet("EF6_SEQCNT" ,n),.T.) } )
       nSaldoCnt  := Round(( aContra[nPos][IIF(lEFFTpMod .And. GDFieldGet("EF6_TP_VIN",n)=="2",6,4)]  - nSaldoCnt );
                     * BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.) /  BuscaTaxa(GdFieldGet("EEC_MOEDA",n),dDataBase,.T.,.F.,.T.) ,2)
       nSaldoInv := GdFieldGet("EF6_VL" ,n) - nSaldoInv     
       If &(cVar) > nSaldoInv 
          MsgInfo(STR0031 + Transform(nSaldoInv,AVSX3("EF6_VL_VIN",6))) //"O saldo de vinculação para essa invoice é de "
          lRet := .F.
       EndIf       
       If nSaldoCnt  < &(cVar)
          MsgInfo(STR0032 + GdFieldGet("EEC_MOEDA",n)+" "+AllTrim(Transform(nSaldoCnt,AVSX3("EF6_VL_VIN",6)))) //"O saldo para vinculação a este contrato e de "
          lRet := .F.
       EndIf
       If lRet .And. nOption == INCLUIR
          If &(cVar) <= nSaldoInv 
             If !lQuebra 
                nDif:=ABS( &(cVar) - GdFieldGet("EF6_VL_VIN" ,n) )
                GDFieldPut("EF6_VL_VIN", GdFieldGet("EF6_VL_VIN" ,nQuebra)+If( &(cVar) > GdFieldGet("EF6_VL_VIN" ,n),-nDif,nDif ),nQuebra)
                GDFieldPut("EF6_VL_VIN",&(cVar),n)
                If GdFieldGet("EF6_VL_VIN",nQuebra) <= 0
                   aDel(aCols,nQuebra)
                   aSize(aCols,LEN(aCols)-1)
                EndIf
             ElseIf &(cVar) <> nSaldoInv
                GDFieldPut("EF6_VL_VIN",&(cVar),n)  
                Aadd(aCols,Array(Len(aHeader)+2))
                AIns(aCols ,n) 
                aCols[n] := Array( Len(aHeader) + 2 )    
                aCols[n][Len(aHeader)+1] := aCols[n+1][Len(aHeader)+1]
                GDFieldPut("EF6_PREEMB",GdFieldGet("EF6_PREEMB" ,n+1),n) 
                GDFieldPut("EF6_NRINVO",GdFieldGet("EF6_NRINVO" ,n+1),n) 
                GDFieldPut("EEC_DTEMBA",GdFieldGet("EEC_DTEMBA" ,n+1),n)       
                GDFieldPut("EF6_MOEDA" ,CriaVar("EF6_MOEDA"),n)
                GDFieldPut("EEC_MOEDA" ,GdFieldGet("EEC_MOEDA" ,n+1),n)
                GdFieldPut("EF6_VL"    ,GdFieldGet("EF6_VL"    ,n+1),n)
                GdFieldPut("EF6_VL_INV",GdFieldGet("EF6_VL_INV",n+1),n)
                GdFieldPut("EF6_PARC"  ,GdFieldGet("EF6_PARC"  ,n+1),n)
                GdFieldPut("EF6_OBS"   ,CriaVar("EF6_OBS"),n)
                GdFieldPut("EF6_CLIENT",GdFieldGet("EF6_CLIENT",n+1),n)              
                GdFieldPut("EF6_CLLOJA",GdFieldGet("EF6_CLLOJA",n+1),n)             
                GdFieldPut("EF6_CONTRA",CriaVar("EF6_CONTRA"),n) 
                GdFieldPut("EF6_BANCO",CriaVar("EF6_BANCO" ),n)             
                GdFieldPut("EF6_PRACA" ,CriaVar("EF6_PRACA" ),n)             
                If lEFFTpMod
                   GdFieldPut("EF6_SEQCNT",CriaVar("EF6_SEQCNT"),n) 
                   GDFieldPut("EF6_TP_VIN" ,"1",n)
                EndIf
//                GdFieldPut("EF6_TP_FIN",CriaVar("EF6_TP_FIN"),n) 
//                GdFieldPut("EF6_VM_FIN",Posicione("SX5",1,xFilial("SX5")+"CG"+"01","X5_DESCRI"),n)                                
                GdFieldPut("EF6_VL_VIN",nSaldoInv-&(cVar),n)                   
                GdFieldPut("EF6_DT_LIB",CriaVar("EF6_DT_LIB"),n)    
                aCols[n][Len(aHeader)+2] := .F.
                If lMulTiFil
                   GdFieldPut("EF6_FILORI" ,AvgFilName({aCols[n][Len(aHeader)+1]})[1],N)                   
                EndIf     
                If EasyEntryPoint("EFFPV400")                       
                   ExecBlock("EFFPV400",.F.,.F.,"QUEBRA_ACOLS")
                EndIf
                n++
             EndIf
          EndIf
       EndIf
    EndIf
EndCase  
cFilAnt := cxFil 
SetFil()
DbSelectArea(cOldAlias)  
Return lRet               
*------------------------------------*
Static Function SaldoEF6(cFil,cChave,lContInv ,cMoeInv,cTipoVin)
*------------------------------------*
Local nOldRec := EF6->(RecNo())
Local nOldORd := EF6->(IndexOrd())
Local nSaldo := 0            
Local bWhile 
Local cxFil  := cFilAnt
Default cFil := cFilAnt 
Default lContInv := .T. // Por Contrato e na moeda do Contrato
cFilAnt:= cFil
SetFil()                                      
nSaldo := 0
If lContInv
   bWhile := {|| EF6->EF6_FILIAL == cFilEF6 .AND. EF6->EF6_CONTRA+IIF(lTemPraca,EF6->EF6_BANCO+EF6->EF6_PRACA,"")+IIF(lEFFTpMod,EF6->EF6_SEQCNT,"") = cChave }  // PLB 10/03/06
//   If lTemPraca
//      bWhile := {|| EF6->EF6_FILIAL == cFilEF6 .AND. EF6->EF6_CONTRA+EF6->EF6_BANCO+EF6->EF6_PRACA = cChave }  
//   Else
//      bWhile := {|| EF6->EF6_FILIAL == cFilEF6 .AND. EF6->EF6_CONTRA = cChave }
//   EndIf   
   EF6->(DbSetOrder(1))
Else
   bWhile := {|| EF6->EF6_FILIAL == cFilEF6 .AND. EF6->EF6_PREEMB+EF6->EF6_NRINVO+EF6->EF6_PARC = cChave}
   EF6->(DbSetOrder(2))
EndIf
EF6->( DbSeek(cFIlEF6+cChave) )
While EF6->(!EOF()) .And. Eval(bWhile)
   If Empty(EF6->EF6_DT_LIB) //Não Efetivado
     If lContInv 
        If !lEFFTpMod .OR. EF6->EF6_TP_VIN==cTipoVin
           nSaldo += (EF6->EF6_VL_VIN * BuscaTaxa(EF6->EF6_MOEDA,dDataBase,.T.,.F.,.T.) ) / BuscaTaxa(Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+cChave,"EF1_MOEDA"),dDataBase,.T.,.F.,.T.)
        EndIf
     Else //Moeda da Invoice      
        nSaldo += EF6->EF6_VL_VIN
     EndIf
   EndIf  
   EF6->(DbSkip())
EndDo                           
cFilAnt:= cxFil
SetFil()
EF6->(DbSetOrder(nOldOrd))
EF6->(DbGoTo(nOldRec))
Return nSaldo  

*---------------------------*
FUNCTION PV400DelLn()                      
*---------------------------*
Local aAux := {}    
Local i
       
aCols[n, ( Len(aHeader) + 2 ) ] := .t.

For i := 1 to Len(aCols)
   If aCols[ i, ( Len(aHeader) + 2 ) ] == .f. 
      Aadd(aAux,aCols[i])
   Endif
Next

aCols := aAux     
n:=1
Return .T.


*--------------------------------*
Function PV400Altera(nOpc)
*--------------------------------*       
Local nValVinc
Local nSldCntPr ,;
      nSldCntJr ,;
      aError1 := aError2 := {}

Local cNrInvo  := EF6->EF6_NRINVO
Local cPreemb  := EF6->EF6_PREEMB      
Local lTemInv  
Local aOrd    := {}    ,;
      nRecEF6 := 0
      
aOrd := SaveOrd({"EF1","EF6","EEQ"})
nRecEF6 := EF6->( RecNo() )

EF1->( DbSetOrder(1) )
EF6->( DbSetOrder(2) )
EEQ->( DbSetOrder(1) )
EF6->( DbSeek(cFilEF6+cPreemb+cNrInvo) )
Do While !EF6->(EOF()) .AND.  cFilEF6+cPreemb+cNrInvo == EF6->EF6_FILIAL+EF6->EF6_PREEMB+EF6->EF6_NRINVO 
   If Empty(EF6->EF6_DT_LIB) .OR. nOpc == 2
      If EEQ->(DbSeek(EF6->EF6_FILORI+EF6->EF6_PREEMB+EF6->EF6_PARC))
            nValVinc :=  ( If (EEQ->EEQ_FI_TOT <> "N" , EEQ->EEQ_VL-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ , EEQ->EEQ_VL_PAR-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ ) /*- SaldoEF6(,EF6->EF6_PREEMB+EF6->EF6_NRINVO+EF6->EF6_PARC,.F.)*/ )
            lTemInv := .T.
            If EF6->EF6_VL_INV  != If (EEQ->EEQ_FI_TOT <> "N" , EEQ->EEQ_VL-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ , EEQ->EEQ_VL_PAR-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ )
               lError3 := .T.
            EndIf
      Else
            nValVinc :=  ( EF6->EF6_VL_INV /*-  SaldoEF6(,EF6->EF6_PREEMB+EF6->EF6_NRINVO+EF6->EF6_PARC,.F.)*/ )
            lTemInv := .F.
      EndIf

      EF1->( DbSeek( cFilEF1+IIF(lEFFTpMod,"E","")+EF6->EF6_CONTRA+If(lTemPraca,EF6->EF6_BANCO+EF6->EF6_PRACA,"")+IIF(lEFFTpMod,EF6->EF6_SEQCNT,"") ) )
      
      //** AAF 06/05/2006 - Utilizar o Saldo do EF3 para Parcelas de Pagamento.
      If lEFFTpMod .And. EF1->EF1_CAMTRA == "1"
         nSldPM := PV400SldPar("PRINCIPAL")
         nSldJM := PV400SldPar("JUROS")
      Else
         nSldPM := EF1->EF1_SLD_PM
         nSldJM := EF1->EF1_SLD_JM
      EndIf
      //**
      
      nSldCntPr :=  ( nSldPM - SaldoEF6(cFilEF6,EF6->EF6_CONTRA+If(lTemPraca,EF6->EF6_BANCO+EF6->EF6_PRACA,"")+IIF(lEFFTpMod,EF6->EF6_SEQCNT,""),.T.,EF1->EF1_MOEDA,IIF(lEFFTpMod,"1",) ) )
      //** PLB 31/03/06
      If lEFFTpMod .And. EF1->EF1_CAMTRA == "1"  // "Parcela de Pagamento? Sim"
         nSldCntJr :=  ( nSldJM - SaldoEF6(cFilEF6,EF6->EF6_CONTRA+If(lTemPraca,EF6->EF6_BANCO+EF6->EF6_PRACA,"")+EF6->EF6_SEQCNT,.T.,EF1->EF1_MOEDA,"2" ) )
      EndIf
      //**
      Aadd(aCols,Array(Len(aHeader)+2))
      aCols[Len(aCols)][Len(aHeader)+1] := EF6->EF6_FILORI
      //aAdd(aInvoice,{EF6->EF6_PREEMB,If (lTemInv,EEQ->EEQ_NRINVO,EF6->EF6_NRINVO),EF6->EF6_PARC,nValVinc})
      PV400Contr(EF6->EF6_CONTRA,EF6->EF6_BANCO,EF6->EF6_PRACA,IIF(lEFFTpMod,EF6->EF6_SEQCNT,""),,,,IIF(lEFFTpMod,EF6->EF6_TP_VIN,"") )
      PV400Contr(EF6->EF6_CONTRA,EF6->EF6_BANCO,EF6->EF6_PRACA,IIF(lEFFTpMod,EF6->EF6_SEQCNT,""),EF6->EF6_MOEDA,EF6->EF6_VL_VIN,,IIF(lEFFTpMod,EF6->EF6_TP_VIN,""))
      GDFieldPut("EF6_PREEMB",EF6->EF6_PREEMB,Len(aCols)) 
      GDFieldPut("EF6_NRINVO",If (lTemInv,EEQ->EEQ_NRINVO,EF6->EF6_NRINVO),Len(aCols)) 
      GDFieldPut("EEC_DTEMBA",EF6->EF6_DTEMBA,Len(aCols))       
      GDFieldPut("EEC_MOEDA" ,EF6->EF6_MOEDA ,Len(aCols))          
      GdFieldPut("EF6_VL_INV",EF6->EF6_VL_INV,Len(aCols))                
      GdFieldPut("EF6_VL"    ,nValVinc       ,Len(aCols))             
      GdFieldPut("EF6_PARC"  ,EF6->EF6_PARC  ,Len(aCols))             
      GdFieldPut("EF6_OBS"   ,EF6->EF6_OBS   ,Len(aCols))              
      GdFieldPut("EF6_CLIENT",EF6->EF6_CLIENT,Len(aCols))              
      GdFieldPut("EF6_CLLOJA",EF6->EF6_CLLOJA,Len(aCols))             
      GdFieldPut("EF6_CONTRA",EF6->EF6_CONTRA,Len(aCols))             
      If lEFFTpMod
         GdFieldPut("EF6_SEQCNT",EF6->EF6_SEQCNT,Len(aCols))             
         GdFieldPut("EF6_TP_VIN",EF6->EF6_TP_VIN,Len(aCols))              
      EndIf
      GdFieldPut("EF6_BANCO" ,EF6->EF6_BANCO ,Len(aCols))             
      GdFieldPut("EF6_PRACA" ,EF6->EF6_PRACA ,Len(aCols))             
      GdFieldPut("EF6_TP_FIN",EF6->EF6_TP_FIN,Len(aCols))              
      GdFieldPut("EF6_VM_FIN",IIF(lCadFin,Posicione("EF7",1,cFilEF7+EF6->EF6_TP_FIN,"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+EF6->EF6_TP_FIN,"X5_DESCRI")),Len(aCols))
      GdFieldPut("EF6_VL_VIN",EF6->EF6_VL_VIN,Len(aCols))                   
      GdFieldPut("EF6_DT_LIB",EF6->EF6_DT_LIB,Len(aCols))                       
      //** PLB 27/02/07 - Walk-Thru
      GdFieldPut("EF6_ALI_WT","EF6",Len(aCols))                       
      GdFieldPut("EF6_REC_WT",EF6->( RecNo() ),Len(aCols))                       
      //**
      If EF6->(FieldPos("EF6_DTDOC")) > 0      
         GdFieldPut("EF6_DTDOC",EF6->EF6_DTDOC,Len(aCols))//FSY - 16/04/2013                    
      End If
      aCols[Len(aCols)][Len(aHeader) +2] := .F.
      If lMulTiFil
         GdFieldPut("EF6_FILORI" ,AvgFilName({EF6->EF6_FILORI})[1],Len(aCols))                   
      EndIf
      //** PLB 13/03/06 - Utilizado para comparação quando houver alteração de contrato
      AAdd(aKeyEF6,If(lMultiFil,aCols[Len(aCols),2]+aCols[Len(aCols),3]+aCols[Len(aCols),4],aCols[Len(aCols),1]+aCols[Len(aCols),2]+aCols[Len(aCols),3]))
      AAdd(aOldKey,GDFieldGet("EF6_CONTRA",Len(aCols))+GDFieldGet("EF6_BANCO",Len(aCols))+GDFieldGet("EF6_PRACA",Len(aCols))+IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",Len(aCols)),"")+Str(GDFieldGet("EF6_VL_VIN",Len(aCols))))
      //**
      If EEQ->EEQ_VL <= 0   .OR. nValVinc < 0 .OR.  EEQ->EEQ_VL < EF6->EF6_VL_VIN
         If aScan(aError1,{|x| x[1] == EF6->EF6_NRINVO .And. x[2] == EF6->EF6_PARC} ) = 0
            aAdd(aError1, {EF6->EF6_NRINVO , EF6->EF6_PARC} )
            cError1+= EF6->EF6_NRINVO+ " / " +EF6->EF6_PARC + CHR(10)+CHR(13)
            lError1 := .T.
         EndIf
      EndIf
      If  nSldPM <= 0 .OR. nSldCntPr  < 0 .OR. nSldPM <  (EF6->EF6_VL_VIN * BuscaTaxa(EF6->EF6_MOEDA,dDataBase,.T.,.F.,.T.) / BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.)   ) .And. ;
          IIF( lEFFTpMod .And. EF1->EF1_CAMTRA=="1" , nSldJM <= 0 .OR. nSldCntJr  < 0 .OR. nSldJM <  (EF6->EF6_VL_VIN * BuscaTaxa(EF6->EF6_MOEDA,dDataBase,.T.,.F.,.T.) / BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.)   ) , .T. ) // PLB 31/03/06 - Verifica se há saldo para juros
         If aScan(aError2,{|x| x[1] == EF6->EF6_CONTRA .And. x[2] == EF6->EF6_BANCO .And. x[3] == EF6->EF6_PRACA} ) = 0
            aAdd(aError2, {EF6->EF6_CONTRA , EF6->EF6_BANCO , EF6->EF6_PRACA} )
            cError2+= Alltrim(EF6->EF6_CONTRA) + STR0034 + Alltrim(EF6->EF6_BANCO) + If(!Empty(EF6->EF6_PRACA),STR0035 + Alltrim(EF6->EF6_PRACA),"") +CHR(10)+CHR(13)
            cError2+= STR0082+Alltrim(Transform(nSldPM,AVSX3("EF6_VL_VIN",6))) + CHR(10)+CHR(13) //"Saldo Principal "
            If lEFFTpMod .And. EF1->EF1_CAMTRA=="1"  // PLB 31/03/06
               cError2+= STR0083+Alltrim(Transform(nSldJM,AVSX3("EF6_VL_VIN",6)))+CHR(10)+CHR(13) //"Saldo Juros     "
            EndIf
            lError2 := .T.
         EndIf
      EndIf
      If EasyEntryPoint("EFFPV400")                       
        ExecBlock("EFFPV400",.F.,.F.,"GRV_ACOLS_EF6")
      EndIf
   EndIf   
   EF6->(dbSkip())                                                    
EndDo
RestOrd(aOrd)
EF6->( DBGoTo(nRecEF6) )
Return .T.


*---------------------------*
FUNCTION PV400Del(lDel)                      
*---------------------------*
Local lRet:= .T.
Default lDel := .F.
If Len(aCols) > 0 
   If MsgNoYes(STR0030)    //"Deseja deletar essa linha"
      If lDel
         aAdd(aDel,{GdFieldGet("EF6_PREEMB" ,n),GdFieldGet("EF6_NRINVO" ,n),GdFieldGet("EF6_PARC" ,n),GdFieldGet("EF6_CONTRA" ,n),GdFieldGet("EF6_BANCO" ,n),GdFieldGet("EF6_PRACA" ,n),IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT" ,n),"")})
      EndIf                   
      PV400DelLn()
   Else
      lRet := .F.
   EndIf
Else
   MsgInfo(STR0064) //"Não existe registro para exclusão."
   lRet := .F.
EndIf
oGet:ForceRefresh()
Return lRet

*----------------------------*
Static Function PV400Contr(cContra,cBanco,cPraca,cSeqCnt,cMoeda,nVal,cxFil,cTpVinc)
*----------------------------*
Local nSaldoEF1Pr := 0 ,;
      nSaldoEF1Jr := 0 ,;
      nSaldoEF6   := 0 

If cTpVinc == NIL  .Or.  Empty(cTpVinc)
   cTpVinc := "1"  // Principal
EndIf

If ValType(nVal) == "U"
   //** PLB 31/03/06
   If cTpVinc == "2"  // Juros
      nSaldoEF1Jr := If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("JUROS")    ,EF1->EF1_SLD_JM)
   Else
      nSaldoEF1Pr := If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("PRINCIPAL"),EF1->EF1_SLD_PM)
   EndIf
   //**
   nSaldoEF6 := SaldoEF6(cxFil,cContra+IF(lTemPraca,cBanco+cPraca,"")+IIF(lEFFTpMod,cSeqCnt,""),,cMoeda,cTpVinc)
   nPos := aScan(aContra,{|x| x[1] == cContra .AND. x[2] == cBanco .And. x[3] == cPraca  .And. IIF(lEFFTpMod,x[5] == cSeqCnt,.T.) } )
   If nPos = 0
      aAdd(aContra,{cContra,cBanco,cPraca, IIF(cTpVinc $ " 1" , nSaldoEF1Pr-nSaldoEF6, 0), cSeqCnt , IIF(lEFFTpMod .And. cTpVinc=="2", nSaldoEF1Jr - nSaldoEF6, 0) })
   Else
      If aContra[nPos][4] == 0
         aContra[nPos][4] += IIF(cTpVinc $ " 1" , nSaldoEF1Pr-nSaldoEF6, 0)
      EndIf
      If aContra[nPos][6] == 0
         aContra[nPos][6] += IIF(lEFFTpMod .And. cTpVinc=="2", nSaldoEF1Jr - nSaldoEF6, 0)
      EndIf
   EndIf
Else                                                  
   nPos := aScan(aContra,{|x| x[1] == cContra .AND. x[2] == cBanco .And. x[3] == cPraca  .And. IIF(lEFFTpMod,x[5] == cSeqCnt,.T.) } )
   aContra[nPos][IIF(cTpVinc=="2",6,4)]+= nVal * BuscaTaxa(cMoeda,dDataBase,.T.,.F.,.T.)/BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.)
EndIf
Return .T.

*----------------------------*
Static Function PV400Inv (cPreemb,cNrInvo,cParc,nVal)
*----------------------------*
Local nPos
nPos := aScan(aInvoice,{|x| x[1] == cPreemb .And. if(!Empty(cNrInvo),x[2] == cNrInvo,.T.) .AND. x[3] == cParc  } )
aInvoice[nPos][4]+= nVal 
Return .T.
*---------------------------------*
Static Function SetFil()
*----------------------------------*
cFilEF1:=xFilial("EF1")
cFilEF6:=xFilial("EF6")
cFilEF2:=xFilial("EF2")
cFilEC6:=xFilial("EC6")
cFilEEC:=xFilial("EEC")
cFilEEQ:=xFilial("EEQ")
cFilEE9:=xFilial("EE9")
cFilSX5:=xFilial("SX5")
cFilECF:=xFilial("ECF")
cFilSA6:=xFilial("SA6")
cFilEF4:=xFilial("EF4")
IIF(lCadFin,cFilEF7:=xFilial("EF7"),) // PLB 10/03/06
Return .T.

*-----------------------------------*
Function PV400Eftiv(cAlias,nReg,nOpc)
*-----------------------------------*
Local lOk := .F.                                               
Local oGet
Local nRecEEQ := 0
Private lInvert
Private cMarca := GetMark()
Private aHeader:={}
Private aCampos :={} 
Private aCpos :={}
Private aContra := {}
Private aInvoice:= {}
Private FileWork1
Private cTX_520
Private cTipo := ""
Private cTX_100 
Private lACCACE := .T. //EasyGParam("MV_ACC_ACE",,.T.)
Private cMod := "E"
Private lEF2_INVOIC := EF2->(FieldPos("EF2_INVOIC")) > 0 .and. EF2->(FieldPos("EF2_PARC")) > 0 .and.;
                       EF2->(FieldPos("EF2_FILORI")) > 0
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0

Private lIsContab := .F.  // PLB 18/06/07 - Identifica se o Contrato foi Contabilizado - Usada no EFFEX400

SetFil()
AADD(aCpos, {"MARCA",,""})   
If lMultiFil
   AADD(aCpos,{ {|| AvgFilName({EFETIVA->EF6_FILORI})[1]              }, "" , Avsx3("EF6_FILORI",5) }) 
EndIf
AADD(aCpos,{ {|| EFETIVA->EF6_PREEMB                                   }, "" , Avsx3("EF6_PREEMB",5) }) 
AADD(aCpos,{ {|| EFETIVA->EF6_NRINVO                                   }, "" , Avsx3("EF6_NRINVO",5) }) 
AADD(aCpos,{ {|| EFETIVA->EF6_PARC                                     }, "" , Avsx3("EF6_PARC"  ,5) }) 
AADD(aCpos,{ {|| Transform( EFETIVA->EF6_VL_INV,Avsx3("EF6_VL_INV",6)) }, "" , Avsx3("EF6_VL_INV",5) })  
AADD(aCpos,{ {|| EFETIVA->EF6_MOEDA                                    }, "" , Avsx3("EF6_MOEDA" ,5) }) 
AADD(aCpos,{ {|| EFETIVA->EF6_DTEMBA                                   }, "" , Avsx3("EF6_DTEMBA",5) })
AADD(aCpos,{ {|| EFETIVA->EF6_CLIENT                                   }, "" , Avsx3("EF6_CLIENT",5) }) 
AADD(aCpos,{ {|| EFETIVA->EF6_CLLOJA                                   }, "" , Avsx3("EF6_CLLOJA",5) })  
AADD(aCpos,{ {|| EFETIVA->EF6_CONTRA                                   }, "" , Avsx3("EF6_CONTRA",5) }) 
If lEFFTpMod
   AADD(aCpos,{ {|| EFETIVA->EF6_SEQCNT                                }, "" , Avsx3("EF6_SEQCNT",5) }) 
   AADD(aCpos,{ {|| BSCXBOX("EF6_TP_VIN",EFETIVA->EF6_TP_VIN)            }, "" , Avsx3("EF6_TP_VIN",5) }) // PLB 29/03/06
EndIf
AADD(aCpos,{ {|| EFETIVA->EF6_BANCO                                    }, "" , Avsx3("EF6_BANCO" ,5) }) 
AADD(aCpos,{ {|| EFETIVA->EF6_PRACA                                    }, "" , Avsx3("EF6_PRACA" ,5) }) 
AADD(aCpos,{ {|| EFETIVA->EF6_DTVINC                                   }, "" , Avsx3("EF6_DTVINC",5) })  
AADD(aCpos,{ {|| Transform(EFETIVA->EF6_VL_VIN,Avsx3("EF6_VL_INV",6))  }, "" , Avsx3("EF6_VL_VIN",5) }) 
If EF6->(FieldPos("EF6_DTDOC")) > 0 //FSY 19/06/2013
   AADD(aCpos,{ {|| EFETIVA->EF6_DTDOC                                    }, "" , Avsx3("EF6_DTDOC" ,5) })
EndIf
AADD(aCpos,{ {|| IIF(lCadFin,Posicione("EF7",1,cFilEF7+EFETIVA->EF6_TP_FIN,"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+EFETIVA->EF6_TP_FIN,"X5_DESCRI")) }, "" , Avsx3("EF6_TP_FIN",5) }) // PLB 10/03/06
AADD(aCpos,{ {|| EFETIVA->EF6_OBS                                      }, "" , Avsx3("EF6_OBS"   ,5) })
CriaWork() 
GravaWork()
If !(EFETIVA->(EOF()) .and. EFETIVA->(BOF()))
   DEFINE MSDIALOG oDlg TITLE STR0090 FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd  PIXEL  //"Efetivação"
      DbSelectArea("EF6")
      oGet := MsSelect():New("EFETIVA","MARCA",,aCpos,@lInvert,@cMarca,{30,000,FINAL_SELECT,COLUNA_FINAL})
      oGet:oBrowse:bWhen:={|| DbSelectArea("EFETIVA")} 
      oGet:bAval:={|| PV400Marca ()}
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lOk := .T. , oDlg:End()},{||oDlg:End()},,aBotao) CENTERED
   If lOk
     //** PLB 23/03/06
     EFETIVA->( DBSetOrder(2)  )
     EFETIVA->( DBSeek(cMarca) )
     //**
     //EFETIVA->( DBGOTOP())
     EF6->(DbSetOrder(2))
//     Do While EFETIVA->(!EOF())
     Do While EFETIVA->(!EOF()) .And. EFETIVA->MARCA == cMarca  // PLB 23/03/06
//       If EFETIVA->MARCA == cMarca
          EF1->(DbSeek(cFilEF1+IIF(lEFFTpMod,"E","")+EFETIVA->EF6_CONTRA+If(lTemPraca,EFETIVA->EF6_BANCO+EFETIVA->EF6_PRACA,"")+IIF(lEFFTpMod,EFETIVA->EF6_SEQCNT,"")))
          EC6->(DbSeek( cFilEC6+"FIEX"+EF1->EF1_TP_FIN+'520' ))
          cTX_520 := EC6->EC6_TXCV
          cTX_100 := EC6->EC6_TXCV
          EX400GrvEventos(EFETIVA->EF6_CONTRA,EFETIVA->EF6_NRINVO,EFETIVA->EF6_PREEMB,EFETIVA->EF6_VL_VIN,dDataBase,;
          EFETIVA->EF6_MOEDA,EFETIVA->EF6_PARC,EF1->EF1_MOEDA,"EF1","EF3","CAMB",,EFETIVA->EF6_TX_VIN,;
          EFETIVA->EF6_DTVINC,If(lTEmFilORi,EFETIVA->EF6_FILORI,Nil),If(lTemPraca,EFETIVA->EF6_BANCO,),;
          IIF(lTemPraca,EFETIVA->EF6_PRACA,),IIF(lEFFTpMod,EFETIVA->EF6_TP_VIN,),IIF(lEFFTpMod,"E",),IIF(lEFFTpMod,EFETIVA->EF6_SEQCNT,),,,,,,EFETIVA->EF6_DTDOC)//FSY - 16/04/2013
          If !EF6->(DbSeek(cFilEF6+EFETIVA->EF6_PREEMB+EFETIVA->EF6_NRINVO+EFETIVA->EF6_PARC))
             EF6->(DbSeek(cFilEF6+EFETIVA->EF6_PREEMB+AVKEY("","EF6_NRINVO")+EFETIVA->EF6_PARC))
          EndIf
          Do While  EF6->EF6_CONTRA!=EFETIVA->EF6_CONTRA .Or. IIF(lTemPraca,EF6->EF6_BANCO!=EFETIVA->EF6_BANCO .Or. EF6->EF6_PRACA!=EFETIVA->EF6_PRACA,.F.) ;
                    .Or. IIF(lEFFTpMod,EF6->EF6_SEQCNT!=EFETIVA->EF6_SEQCNT,.F.) .Or. EF6->EF6_VL_VIN != EFETIVA->EF6_VL_VIN  .Or.  !Empty(EF6->EF6_DT_LIB) // PLB 23/03/06
             EF6->( DBSkip() )
          EndDo
          EF6->(RecLock("EF6",.F.))
          EF6->EF6_NRINVO := EFETIVA->EF6_NRINVO
          EF6->EF6_DTEMBA := EFETIVA->EF6_DTEMBA
          EF6->EF6_TX_VIN := EFETIVA->EF6_TX_VIN
          EF6->EF6_DTVINC := EFETIVA->EF6_DTVINC
          EF6->EF6_DT_LIB := dDataBAse
          EF6->EF6_HR_LIB := Time()
          EF6->EF6_USUARI := UPPER(ALLTRIM(cUserName))
          EF6->EF6_DTDOC := EFETIVA->EF6_DTDOC//FSY - 16/04/2013
          EF6->(MsUnlock())

          //** PLB 22/03/06 - Atualiza EEQ e Quebra Parcelas da Invoice na Efetivacao
          EEQ->( DBSetOrder(1) )
          If EEQ->( DBSeek(IIF(lMultiFil,EF6->EF6_FILORI,cFilEF6)+EF6->EF6_PREEMB+EF6->EF6_PARC) ) 
 
             nRecEEQ := EEQ->( RecNo() )
 
             If EF6->EF6_VL_VIN < EEQ->EEQ_VL-IIF(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0)
                EX401QuebraEEQ(EEQ->EEQ_VL-IIF(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0),EF6->EF6_VL_VIN,IIF(lMultiFil,EF6->EF6_FILORI,""),EEQ->EEQ_PREEMB,EEQ->EEQ_NRINVO,EEQ->EEQ_PARC,EEQ->( RecNo() ),"PREVIN" )
                EF6->(RecLock("EF6",.F.))
                EF6->EF6_VL_INV := EF6->EF6_VL_VIN  // Como a parcela da Invoice é quebrada, o valor dela assume o valor pré-vinculado efetivado
                EF6->(MsUnlock())
             EndIf
             
             EF3->( DBSetOrder(1) )
             EF3->( DBSeek(cFilEF6+IIF(lEFFTpMod,"E","")+EF6->EF6_CONTRA+IIF(lTemPraca,EF6->EF6_BANCO+EF6->EF6_PRACA,"")+IIF(lEFFTpMod,EF6->EF6_SEQCNT,"")+"600"+EF6->EF6_PARC) )
             Do While EF3->EF3_INVOIC != EF6->EF6_NRINVO
                EF3->( DBSkip() )
             EndDo
             EEQ->( DBGoTo(nRecEEQ) )
             EEQ->(RecLock("EEQ",.F.))
             EEQ->EEQ_FI_TOT := "S"
             EEQ->EEQ_VL_PAR := 0
             EEQ->EEQ_BANC   := EF3->EF3_BAN_FI
             EEQ->EEQ_AGEN   := EF3->EF3_AGENFI
             EEQ->EEQ_NCON   := EF3->EF3_NCONFI
             EEQ->EEQ_NOMEBC := Posicione("SA6",1,xFilial("SA6")+EF3->EF3_BAN_FI+EF3->EF3_AGENFI+EF3->EF3_NCONFI,"A6_NOME")
             EEQ->EEQ_NROP   := EF3->EF3_CONTRA
             If lParFin .and. Empty(EEQ->EEQ_PARFIN)
                EEQ->EEQ_PARFIN := EEQ->EEQ_PARC
             EndIf
             EEQ->( MSUnlock() )


          EndIf
          //**

//       EndIf
     EFETIVA->(DbSkip())
     EndDo
     EF6->(DbSetOrder(1))
   EndIf
Else
   MsgInfo(STR0063) //"Não existe registro para efetivacäo."
EndIf
If Select("EFETIVA") <> 0
   EFETIVA->(dbCloseArea())
   FErase(FileWork1)
EndIf   
Filtra()
Return .T.
*-------------------------*
Static Function CriaWork() 
*-------------------------*
PRivate aEfetiva := {}
DbSelectArea("EF6")                                                     
Aadd( aEfetiva,{"EF6_CONTRA", AVSX3("EF6_CONTRA",2), AVSX3("EF6_CONTRA",3), AVSX3("EF6_CONTRA",4)} )  
Aadd( aEfetiva,{"EF6_BANCO" , AVSX3("EF6_BANCO" ,2), AVSX3("EF6_BANCO" ,3), AVSX3("EF6_BANCO" ,4)} )  
Aadd( aEfetiva,{"EF6_PRACA" , AVSX3("EF6_PRACA" ,2), AVSX3("EF6_PRACA" ,3), AVSX3("EF6_PRACA" ,4)} )  
If lEFFTpMod
   Aadd( aEfetiva,{"EF6_SEQCNT", AVSX3("EF6_SEQCNT",2), AVSX3("EF6_SEQCNT",3), AVSX3("EF6_SEQCNT",4)} )  
   Aadd( aEfetiva,{"EF6_TP_VIN", AVSX3("EF6_TP_VIN",2), AVSX3("EF6_TP_VIN",3), AVSX3("EF6_TP_VIN",4)} )  // PLB 29/03/06
EndIf
Aadd( aEfetiva,{"EF6_FILORI", AVSX3("EF6_FILORI",2), AVSX3("EF6_FILORI",3), AVSX3("EF6_FILORI",4)} ) 
Aadd( aEfetiva,{"EF6_PREEMB", AVSX3("EF6_PREEMB",2), AVSX3("EF6_PREEMB",3), AVSX3("EF6_PREEMB",4)} )
Aadd( aEfetiva,{"EF6_NRINVO", AVSX3("EF6_NRINVO",2), AVSX3("EF6_NRINVO",3), AVSX3("EF6_NRINVO",4)} )
Aadd( aEfetiva,{"EF6_PARC"  , AVSX3("EF6_PARC"  ,2), AVSX3("EF6_PARC"  ,3), AVSX3("EF6_PARC"  ,4)} )
Aadd( aEfetiva,{"EF6_VL_INV", AVSX3("EF6_VL_INV",2), AVSX3("EF6_VL_INV",3), AVSX3("EF6_VL_INV",4)} )
Aadd( aEfetiva,{"EF6_MOEDA" , AVSX3("EF6_MOEDA" ,2), AVSX3("EF6_MOEDA" ,3), AVSX3("EF6_MOEDA" ,4)} )
Aadd( aEfetiva,{"EF6_DTEMBA", AVSX3("EF6_DTEMBA",2), AVSX3("EF6_DTEMBA",3), AVSX3("EF6_DTEMBA",4)} )
Aadd( aEfetiva,{"EF6_CLIENT", AVSX3("EF6_CLIENT",2), AVSX3("EF6_CLIENT",3), AVSX3("EF6_CLIENT",4)} )
Aadd( aEfetiva,{"EF6_CLLOJA", AVSX3("EF6_CLLOJA",2), AVSX3("EF6_CLLOJA",3), AVSX3("EF6_CLLOJA",4)} )                                                         
Aadd( aEfetiva,{"EF6_DTVINC", AVSX3("EF6_DTVINC",2), AVSX3("EF6_DTVINC",3), AVSX3("EF6_DTVINC",4)} )  
If EF6->(FieldPos("EF6_DTDOC")) > 0 //FSY 19/06/2013
   Aadd( aEfetiva,{"EF6_DTDOC"   , AVSX3("EF6_DTDOC"   ,2), AVSX3("EF6_DTDOC"   ,3), AVSX3("EF6_DTDOC"   ,4)} )//FSY - 15/04/2013
EndIf
Aadd( aEfetiva,{"EF6_TX_VIN", AVSX3("EF6_TX_VIN",2), AVSX3("EF6_TX_VIN",3), AVSX3("EF6_TX_VIN",4)} )  
Aadd( aEfetiva,{"EF6_VL_VIN", AVSX3("EF6_VL_VIN",2), AVSX3("EF6_VL_VIN",3), AVSX3("EF6_VL_VIN",4)} )  
Aadd( aEfetiva,{"EF6_TP_FIN", AVSX3("EF6_TP_FIN",2), AVSX3("EF6_TP_FIN",3), AVSX3("EF6_TP_FIN",4)} )  
Aadd( aEfetiva,{"EF6_OBS"   , AVSX3("EF6_OBS"   ,2), AVSX3("EF6_OBS"   ,3), AVSX3("EF6_OBS"   ,4)} )  
Aadd( aEfetiva,{ "MARCA"   , "C",2,0} )    

//TRP - 02/02/07 - Campos do WalkThru
AADD(aEfetiva,{"TRB_ALI_WT","C",03,0})
AADD(aEfetiva,{"TRB_REC_WT","N",10,0})


If EasyEntryPoint("EFFPV400")                       
   ExecBlock("EFFPV400",.F.,.F.,"ANTES_CRIAWORK")
EndIf
FileWork1 := E_CriaTrab(,aEfetiva,"EFETIVA") 
FileWork2 := E_Create(,.F.)
//IndRegua("WORKPROC",FileWork1+OrdBagExt(),"W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO")                                                               

//** PLB 23/03/06
IndRegua("EFETIVA",FileWork1+TEOrdBagExt(),"EF6_FILORI+EF6_PREEMB+EF6_NRINVO+EF6_PARC+EF6_CONTRA+EF6_BANCO+EF6_PRACA"+IIF(lEFFTpMod,"+EF6_SEQCNT","") , , ,"Processando Arquivo Temporário...")
IndRegua("EFETIVA",FileWork2+TEOrdBagExt(),"MARCA" , , ,STR0091)  //"Processando Arquivo Temporário..."
Set Index To ( FileWork1+TEOrdBagExt()) , (FileWork2+TEOrdBagExt() )
//**

Return .T. 

*-------------------------*
Static Function GravaWork()
*-------------------------*
Local cFiliais := ""                             
Private cGrava:= ""       
EF6->(DBSetFilter( {|| Empty(EF6->EF6_DT_LIB) }, "Empty(EF6->EF6_DT_LIB)"))
EF6->(DbGoTop())
PV400FltInv(.T.)
aEval(aFiliais,{|x,y| cFiliais += x +"/"})
cGrava+="EF6->EF6_FILORI $ cFiliais "
cGrava+=" .And. !Empty(EEC->EEC_DTEMBA) "
If .not. Empty( dVencIni ) 
    cGrava+=" .and. EEQ->EEQ_VCT >= dVencIni "
Endif                      
If .not. Empty( dVencFim )
     cGrava+=iif(.not. Empty(cGrava), ".AND. ","") + "EEQ->EEQ_VCT <= dVencFim " 
Endif
If .not. Empty( cInvoice )   
   cGrava+=iif(.not. Empty(cGrava), ".AND. ","") + "EEC->EEC_NRINVO = '" + Alltrim( cInvoice ) + "' "
Endif 
If .not. Empty( cProcesso ) 
   cGrava+=iif(.not. Empty(cGrava), ".AND. ","") + "EEC->EEC_PREEMB = '" + Alltrim( cProcesso ) + "' "
Endif 
If .not. Empty( nValIni ) 
    cGrava+=iif(.not. Empty(cGrava), ".AND. ","") + "EEQ->EEQ_VL >= nValIni "
End
If .not. Empty( nValFim )                
   cGrava+=iif(.not. Empty(cGrava), ".AND.","") + "EEQ->EEQ_VL <= nValFim "
Endif
If .not. Empty( cCliente ) 
   cGrava+=iif(.not. Empty(cGrava), ".AND. ","") + "EEC->EEC_CLIENT = '" + Alltrim( cCliente ) + "' "
Endif          
If .not. Empty( cLojaCli ) //ASK 18/12/2007 - Incluído o campo Loja Cliente
   cGrava+=iif(.not. Empty(cGrava), ".AND. ","") + "EEC->EEC_CLLOJA = '" + Alltrim( cLojaCli ) + "' "
Endif          
If .not. Empty( cCondPagto )
   cGrava+=iif(.not. Empty(cGrava), ".AND. ","") + "EEC->EEC_CONDPA = '" + Alltrim(cCondPagto) + "' .AND. EEC->EEC_DIASPA = nDias" 
Endif  
If EasyEntryPoint("EFFPV400")                       
   ExecBlock("EFFPV400",.F.,.F.,"FILTRA_EFETIVA")
EndIf

If Empty (cGrava)
   cGrava := ".t."
Endif
 
Do While EF6->(!EOF())                                            
   EEC->(DbSeek(EF6->EF6_FILORI+EF6->EF6_PREEMB))   
   EEQ->(DbSeek(EF6->EF6_FILORI+EF6->EF6_PREEMB+EF6->EF6_PARC))   
   IF &(cGrava)
      
      RecLock("EFETIVA",.T.)
      EFETIVA->EF6_FILORI := EF6->EF6_FILORI
      EFETIVA->EF6_PREEMB := EF6->EF6_PREEMB
      EFETIVA->EF6_VL_INV := EF6->EF6_VL_INV
      EFETIVA->EF6_PARC   := EF6->EF6_PARC
      EFETIVA->EF6_MOEDA  := EF6->EF6_MOEDA
      EFETIVA->EF6_DTEMBA := EEC->EEC_DTEMBA
      EFETIVA->EF6_CLIENT := EF6->EF6_CLIENT
      EFETIVA->EF6_CLLOJA := EF6->EF6_CLLOJA
      EFETIVA->EF6_CONTRA := EF6->EF6_CONTRA
      If lEFFTpMod    // PLB 29/03/06
         EFETIVA->EF6_SEQCNT := EF6->EF6_SEQCNT
         EFETIVA->EF6_TP_VIN := EF6->EF6_TP_VIN
      EndIf
      EFETIVA->EF6_BANCO  := EF6->EF6_BANCO
      EFETIVA->EF6_PRACA  := EF6->EF6_PRACA
      EFETIVA->EF6_DTVINC := EF6->EF6_DTVINC
      EFETIVA->EF6_TX_VIN := EF6->EF6_TX_VIN   
      EFETIVA->EF6_VL_VIN := EF6->EF6_VL_VIN
      EFETIVA->EF6_TP_FIN := EF6->EF6_TP_FIN
      EFETIVA->EF6_OBS    := EF6_OBS
      If !Empty(EEQ->EEQ_NRINVO)
         EFETIVA->EF6_NRINVO := EEQ->EEQ_NRINVO
      Else
         EFETIVA->EF6_NRINVO := EF6->EF6_NRINVO   
      EndIf            
      If EasyEntryPoint("EFFPV400")                       
         ExecBlock("EFFPV400",.F.,.F.,"GRV_WORK_EFETIVA")
      EndIf
      EFETIVA->TRB_ALI_WT := "EF6"
      EFETIVA->TRB_REC_WT := EF6->(Recno())
      EFETIVA->(MsUnlock()) 

   EndIf   
   EF6->(DbSkip())
EndDo        
EFETIVA->( DBSetOrder(1) )  // PLB 23/03/06
EFETIVA->(DbGoTop())
EF6->(DBClearFilter())
Return .T.
*----------------------------------*
Function Pv400Marca()
*----------------------------------*
Local nPos
Local oDlg             
Local dDtInv := dDtCtr := CTOD("  /  /  ")
Local nRecEFETIV := 0   // PLB 23/03/06
Local cChvEFETIV := ""  // PLB 23/03/06
Local lRet := .F.       // PLB 23/03/06
Private nTx   := BuscaTaxa(EFETIVA->EF6_MOEDA,dDataBase,,.F.,.T.,,"1")
Private dData := dDataBase
Private lMArca
Private dEntrega := dDataBase  // FSY 11/04/2013
EF3->(DbSetOrder(6))
EEQ->( DbSetOrder(1) )
lMarca:=.T.
//** PLB 23/03/06
nRecEFETIV := EFETIVA->( RecNo() )
cChvEFETIV := EFETIVA->EF6_FILORI+EFETIVA->EF6_PREEMB+EFETIVA->EF6_NRINVO+EFETIVA->EF6_PARC
cCmpEFETIV := "EFETIVA->EF6_FILORI+EFETIVA->EF6_PREEMB+EFETIVA->EF6_NRINVO+EFETIVA->EF6_PARC"
//**
If EFETIVA->MARCA == "  " .OR. EFETIVA->MARCA == ""

   //** PLB 23/03/06 - Não permite efetivar mais de uma vinculacao para a mesma parcela da invoice, pois ao efetivar
   //                  uma vinculacao com valor parcial a invoice sera quebrada
   EFETIVA->( DBSeek(cChvEFETIV) )
   Do While  !EFETIVA->( EOF() )  .And.  cChvEFETIV == &(cCmpEFETIV)  .And.  (EFETIVA->MARCA == "  " .Or. EFETIVA->MARCA == "")
      EFETIVA->( DBSkip() )
   EndDo
   If cChvEFETIV == &(cCmpEFETIV)
      MsgInfo(STR0068+STR0070)  // "Esta Parcela da Invoice ja esta marcada para Efetivacao para outro Contrato. Refaca a Pre-Vinculacao com a nova parcela que sera gerada apos a Efetivacao."
      lMarca := .F.
   EndIf
   EFETIVA->( DBGoTo(nRecEFETIV) )
   //**

   If lMarca .And. EF1->(DbSeek(cFilEF1+IIF(lEFFTpMod,"E","")+EFETIVA->EF6_CONTRA+If(lTemPraca,EFETIVA->EF6_BANCO+EFETIVA->EF6_PRACA,"")+IIF(lEFFTpMod,EFETIVA->EF6_SEQCNT,"")))  .AND. Empty(EF1->EF1_DT_ENC)
      nPos := aScan(aContra,{|x| x[1] == EFETIVA->EF6_CONTRA .AND. x[2] == EFETIVA->EF6_BANCO .And. x[3] == EFETIVA->EF6_PRACA .And. IIF(lEFFTpMod,x[5] == EFETIVA->EF6_SEQCNT, .T.)  } )
      If nPos = 0
         aAdd(aContra,{EFETIVA->EF6_CONTRA,EFETIVA->EF6_BANCO,EFETIVA->EF6_PRACA, If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("PRINCIPAL"),EF1->EF1_SLD_PM) ,IIF(lEFFTpMod,EFETIVA->EF6_SEQCNT,"") , IIF(lEFFTpMod .And. EFETIVA->EF6_TP_VIN=="2" , If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("JUROS"),EF1->EF1_SLD_JM) , 0 )}) // PLB 31/03/06
      ElseIf lEFFTpMod
         If aContra[nPos][4] == 0
            aContra[nPos][4] += IIF(EFETIVA->EF6_TP_VIN == "1" , If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("PRINCIPAL"),EF1->EF1_SLD_PM), 0)
         EndIf
         If aContra[nPos][6] == 0
            aContra[nPos][6] += IIF(EFETIVA->EF6_TP_VIN =="2", If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("JUROS"),EF1->EF1_SLD_JM), 0)
         EndIf
      EndIf
      nPos := aScan(aContra,{|x| x[1] == EFETIVA->EF6_CONTRA .AND. x[2] == EFETIVA->EF6_BANCO .And. x[3] == EFETIVA->EF6_PRACA .And. IIF(lEFFTpMod,x[5] == EFETIVA->EF6_SEQCNT,.T.)  } )
      If aContra[nPos][IIF(lEFFTpMod .And. EFETIVA->EF6_TP_VIN=="2",6,4)] <  (EFETIVA->EF6_VL_VIN * BuscaTaxa(EF6->EF6_MOEDA,dDataBase,.T.,.F.,.T.) / BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.)   )
         MsGInfo(STR0033 +Alltrim(EFETIVA->EF6_CONTRA) + STR0034 + Alltrim(EFETIVA->EF6_BANCO) + STR0035 + AllTrim(EFETIVA->EF6_PRACA) + STR0036 +; //"O contrato "###" banco "###" praça "###" não possui saldo para vinculação"
         CHR(10)+CHR(13)+IIF(lEFFTpMod .And. EFETIVA->EF6_TP_VIN=="2",STR0083,STR0049)+EF1->EF1_MOEDA+": "+Alltrim(Transform(aContra[nPos][IIF(lEFFTpMod .And. EFETIVA->EF6_TP_VIN=="2",6,4)],AVSX3("EF6_VL_VIN",6))))  //"Saldos do Contrato "
//      ElseIf EF3->(DbSeek(cFilEF3+IIF(lEFFTpMod,"E","")+EFETIVA->EF6_CONTRA+If(lTemPraca,EFETIVA->EF6_BANCO+EFETIVA->EF6_PRACA,"")+IIF(lEFFTpMod,EFETIVA->EF6_SEQCNT,"")+EFETIVA->EF6_NRINVO+EFETIVA->EF6_PARC))
//         MsGInfo(STR0033 +Alltrim(EFETIVA->EF6_CONTRA) + STR0034 + Alltrim(EFETIVA->EF6_BANCO) + STR0035 + AllTrim(EFETIVA->EF6_PRACA) + STR0037)  //"O contrato "###" banco "###" praça "###" já  vinculado a essa invoice"
         lMarca := .F.
      Else
         lMarca := .T.   
         dDtCtr := EF1->EF1_DT_VIN
      EndIf
   ElseIf lMarca
        MsgInfo(STR0033+Alltrim(EF1->EF1_CONTRA)+STR0038+Dtoc(EF1->EF1_DT_ENC))  //"O Contrato "###" já foi Encerrado em: "
        lMarca := .F.
   EndIf  
   If lMarca 
      If EEQ->( DbSeek( EFETIVA->EF6_FILORI+EFETIVA->EF6_PREEMB+EFETIVA->EF6_PARC))
         nPos := aScan(aInvoice,{|x| x[1] == EFETIVA->EF6_PREEMB .AND. x[2] == EEQ->EEQ_NRINVO .AND. x[3] == EFETIVA->EF6_PARC  } )
         If nPos = 0 
            aAdd(aInvoice,{ EFETIVA->EF6_PREEMB ,EEQ->EEQ_NRINVO,EFETIVA->EF6_PARC, If (EEQ->EEQ_FI_TOT <> "N" , EEQ->EEQ_VL-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ , EEQ->EEQ_VL_PAR-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ ) })
         EndIf 
         nPos := aScan(aInvoice,{|x| x[1] == EFETIVA->EF6_PREEMB .AND. x[2] == EEQ->EEQ_NRINVO .AND. x[3] == EFETIVA->EF6_PARC  } )
         //** PLB 22/03/06 - Verifica se a Parcela da Invoice já foi vinculada
         If !Empty(EEQ->EEQ_FI_TOT)
            MsgInfo(STR0068+STR0071)  // "Esta Parcela da Invoice já foi vinculada. Estorne esta Pré-Vinculação."
            lMarca := .F.
         //**
         ElseIf (aInvoice[nPos][4]- EFETIVA->EF6_VL_VIN) < 0
            MsGInfo(STR0039 +Alltrim(EFETIVA->EF6_NRINVO) + STR0040 + Alltrim(EFETIVA->EF6_PARC) + STR0036)  //"A Invoice "###" parcela "###" não possui saldo para vinculação"
            lMArca:= .F.
         ElseIf (If(EEQ->EEQ_FI_TOT='N', EEQ->EEQ_VL_PAR-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ, EEQ->EEQ_VL-EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ) - EFETIVA->EF6_VL_VIN) < 0
            MsgInfo (STR0041 + Alltrim(EFETIVA->EF6_PREEMB) + STR0042) //"As  parcelas   do processo "###" diferentes das parcelas da pre-vinculção , favor verificar "
            lMarca := .F.
         Else 
            lMarca := .T.
            dDtInv := EEQ->EEQ_VCT
         EndIf
      Else
         MsgInfo (STR0041 + Alltrim(EFETIVA->EF6_PREEMB) + STR0042) //"As  parcelas   do processo "###" diferentes das parcelas da pre-vinculção , favor verificar "
         lMarca := .F.
      EndIf
   EndIf
   If !Empty(dDtInv) .And. !Empty(dDtCtr) .And. dDtInv > dDtCtr
      MsGInfo(STR0043) //"Data limite para a vinculção do contrato maior que a data de vencimento da fatura"
   EndIF                                                  
   If EasyEntryPoint("EFFPV400")                       
      ExecBlock("EFFPV400",.F.,.F.,"ANTES_MARCA")
   EndIf
   If lMArca
      If(!Empty(EEQ->EEQ_DTCE),dData:=EEQ->EEQ_DTCE,)//FSY 19/06/2013 - Se a data credito estever preenchido, inicializar com a mesma data no campo data vinculação.
      nTx   := BuscaTaxa(EFETIVA->EF6_MOEDA,dDataBase,,.F.,.T.,,"1")//FSY 19/06/2013
      
      DEFINE MSDIALOG oDlg TITLE "" FROM 200,200 TO 320,800  OF oMainWnd PIXEL//FSY 19/06/2013 Ajustado o tamanho para comportar o novo campo DTDOC
         @ 40,008  SAY STR0045 Of oDlg Pixel  //"Dt. de Vinc."
         @ 40,040  MsGet dData Size 60,6 Picture AVSX3("EF6_DTVINC",6)  VALID DtValidVinc(dData) Of oDlg pixel//FSY - 09/04/2013
         @ 40,110  SAY STR0044  Of oDlg Pixel  //"Tx. de Vinc."
         @ 40,140  MsGet nTx  Size 60,6 Picture AVSX3("EF6_TX_VIN",6)  Of oDlg pixel
         @ 40,210  SAY STR0093  Of oDlg Pixel  //"Dt.Ent.Doc."
         @ 40,240  MsGet dEntrega  Size 60,6 /*Picture AVSX3("EF6_DT_ENT",6)*/ Of oDlg pixel
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,{|| If (ValidMarca(nTx,dData),oDlg:End(),.f.)},{|| lMarca := .F. ,oDlg:End() }) CENTERED
      If lMarca
         PV400Contr(EFETIVA->EF6_CONTRA,EFETIVA->EF6_BANCO,EFETIVA->EF6_PRACA,IIF(lEFFTpMod,EFETIVA->EF6_SEQCNT,""),EFETIVA->EF6_MOEDA,-EFETIVA->EF6_VL_VIN,,IIF(lEFFTpMod,EFETIVA->EF6_TP_VIN,""))
         PV400Inv  (EFETIVA->EF6_PREEMB,EFETIVA->EF6_NRINVO,EFETIVA->EF6_PARC,-EFETIVA->EF6_VL_VIN)
         EFETIVA->MARCA := cMarca
         EFETIVA->EF6_TX_VIN := nTx
         EFETIVA->EF6_DTVINC := dData
         EFETIVA->EF6_DTDOC  := dEntrega//FSY - 15/04/2013               
      EndIf  
   EndIf
Else                          
  EFETIVA->MARCA := "  "
  PV400Contr(EFETIVA->EF6_CONTRA,EFETIVA->EF6_BANCO,EFETIVA->EF6_PRACA,IIF(lEFFTpMod,EFETIVA->EF6_SEQCNT,""),EFETIVA->EF6_MOEDA,EFETIVA->EF6_VL_VIN,,IIF(lEFFTpMod,EFETIVA->EF6_TP_VIN,""))
  PV400Inv  (EFETIVA->EF6_PREEMB,EFETIVA->EF6_NRINVO,EFETIVA->EF6_PARC,EFETIVA->EF6_VL_VIN)
     
EndIf

Return lMarca                               

*------------------------*
Static Function ValidMarca(nTx,dData)          
*------------------------*
Local lRet := .T.
If nTx != 0
   If !Positivo(nTx) .OR. Empty(dData)
      lRet:=.F.
   EndIF  
Else    
   lRet:=.F.
EndIf
Return lRet

*----------------------*
FuncTion BtnContrat()
*----------------------*   
Local Odlg
Local cContrato  := CriaVar("EF6_CONTRA")                               
Local cSequencia := ""  //** PLB 09/03/06
Local cBanco     := CriaVar("EF6_BANCO")                               
Local cPraca     := CriaVar("EF6_PRACA")                               
Local lOk:= .F.
      //** PLB 31/03/06
Local nSldRealPr ,;
      nSldRealJr ,;
      nSldPrevPr ,;
      nSldPrevJr 
      //**      
Local cMens         
Local aPos       := { 08, 32, 98, 116, 152, 170 }
Local nPos       := 680
Local i            

//** PLB 09/03/06
If lEFFTpMod
   cSequencia := CriaVar("EF6_SEQCNT")
   nPos       := 800
   aAdd( aPos, 206 )
   aAdd( aPos, 236 )
EndIf
//**

EF6->(DBClearFilter())
DEFINE MSDIALOG oDlg TITLE "" FROM 200,200 TO 320,nPos  OF oMainWnd PIXEL
   @ 40,aPos[1] SAY   STR0046 Of oDlg Pixel  //"Contrato"
   @ 40,aPos[2] MsGet cContrato  F3 AVSX3("EF6_CONTRA",8) Size 60,6  Picture AVSX3("EF6_CONTRA",6) Valid IIF(AvgExistCpo("EF1",IIF(lEFFTpMod,"E","")+cContrato),IIF(lEFFTpMod,,Eval({|| cBanco := EF1->EF1_BAN_FI , cPraca := EF1->EF1_PRACA})),.F.) Of oDlg pixel   
   @ 40,aPos[3] SAY  STR0047 Of oDlg Pixel  //"Banco"
   @ 40,aPos[4] MsGet cBanco  F3 AVSX3("EF6_BANCO",8) Size 30,6 Picture AVSX3("EF6_BANCO",6) Valid AvgExistCpo("SA6",cBanco)  Of oDlg pixel
   @ 40,aPos[5] SAY  STR0048 Of oDlg Pixel  //"Praca"
   @ 40,aPos[6] MsGet cPraca  F3 AVSX3("EF6_PRACA",8) Size 30,6 Picture AVSX3("EF6_PRACA",6) Valid AvgExistCpo("EF5",cPraca)  Of oDlg pixel
   //** PLB 09/03/2006
   If lEFFTpMod
      @ 40,aPos[7] SAY   STR0067 Of oDlg Pixel  //"Seqüência"
      @ 40,aPos[8] MsGet cSequencia  Size 30,6  Picture AVSX3("EF6_SEQCNT",6) Of oDlg pixel   
   EndIf
   //**      
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,{|| If(AvgExistCpo("EF1",IIF(lEFFTpMod,"E","")+cContrato+IF(lTemPRaca,cBanco+cPraca,"")+IIF((lEFFTpMod .And. !Empty(cSequencia)),cSequencia,"")),Eval({|| lOk:= .T. , oDlg:End()}),.F.)},{|| oDlg:End() }) CENTERED
If lOk
   EF1->( DbSeek( cFilEF1+IIF(lEFFTpMod,"E","")+cContrato+If(lTemPraca,cBanco+cPraca,"")+IIF((lEFFTpMod .And. !Empty(cSequencia)),cSequencia,"") ) )
   nSldRealPr := If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("PRINCIPAL"),EF1->EF1_SLD_PM)
   nSldPrevPr := SaldoEF6(cFilEF6,cContrato+If(lTemPraca,cBanco+cPraca,"")+IIF(lEFFTpMod,cSequencia,""),,,"1")
   cMens      := STR0049 + Alltrim(cContrato) + IIF(lEFFTpMod,", "+STR0067+" " + AllTrim(cSequencia),"") +","+STR0034 + Alltrim(cBanco) +","+ STR0035 + Alltrim(cPraca) +" "+; //"Saldos do contrato "###" banco "###" praça " ##" sequencia" ##
                 STR0050+EF1->EF1_MOEDA+": "+Alltrim(Transform(nSldRealPr,AVSX3("EF6_VL_VIN",6)))+; //"em "
                 CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
                 STR0080+CHR(13)+CHR(10)+;  // "PRINCIPAL"
                 AllTrim(STR0051) + PadL(AllTrim(Transform(EF1->EF1_LIQPRM+EF1->EF1_SL2_PM,AVSX3("EF6_VL_VIN",6))),34," ") +CHR(13)+CHR(10)+ ; //"Saldo de Invoices já vinculadas    "
                 AllTrim(STR0052) + PadL(AllTrim(Transform(nSldPrevPr,AVSX3("EF6_VL_VIN",6))),29," ") +CHR(13)+CHR(10)+; //"Saldo de Invoices pré-vinculadas "
                 AllTrim(STR0053) + PadL(AllTrim(Transform(nSldRealPr-nSldPrevPr,AVSX3("EF6_VL_VIN",6))),62," ") //"Saldo Total                                   "
   //** PLB 31/03/06
   If lEFFTpMod .And. EF1->EF1_CAMTRA == "1" // "1-Sim"
      nSldRealJr := If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("JUROS"),EF1->EF1_SLD_JM)
      nSldPrevJr := SaldoEF6(cFilEF6,cContrato+If(lTemPraca,cBanco+cPraca,"")+IIF(lEFFTpMod,cSequencia,""),,,"2" )
      cMens      += CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
                    STR0081+CHR(13)+CHR(10)+;  // "JUROS"
                    AllTrim(STR0051) + PadL(AllTrim(Transform(EF1->EF1_LIQJRM+EF1->EF1_SL2_JM,AVSX3("EF6_VL_VIN",6))),34," ") +CHR(13)+CHR(10)+ ; //"Saldo de Invoices já vinculadas    "
                    AllTrim(STR0052) + PadL(AllTrim(Transform(nSldPrevJr,AVSX3("EF6_VL_VIN",6))),29," ") +CHR(13)+CHR(10)+; //"Saldo de Invoices pré-vinculadas "
                    AllTrim(STR0053) + PadL(AllTrim(Transform(nSldRealJr-nSldPrevJr,AVSX3("EF6_VL_VIN",6))),62," ") //"Saldo Total                                   "
   EndIf
   //**
   MsGInfo(cMens)
EndIF
Filtra()
Return .T.                     


*-----------------------------*
Static Function PV400SemInv()
*-----------------------------*
Local cCond:="",i,nFil
Local aCondDel:={"AND EEC.D_E_L_E_T_ <> '*' "}
Local nValVinc
Local aParc := {}    
cQuery := ""
Private cMoeda
If lTop
   If !lMultiFil 
     cCond+="EEC.EEC_FILIAL='"+xFilial("EEC")+"' AND "+If(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_ <> '*' ","EEC.@DELETED@ <> '*' ")
   Else
     cCond+="EEC.EEC_FILIAL IN ("+cFiliais+") AND "+If(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_ <> '*' ","EEC.@DELETED@ <> '*' ")
   EndIf
   cCond+="AND EEC.EEC_STATUS <> '*' " 
   cCond+=" AND ( EEC.EEC_DTEMBA = '' OR EEC.EEC_DTEMBA = '"+Space(08)+"')"
   If .not. Empty( cProcesso ) 
      cCond+="AND EEC.EEC_PREEMB = '" + Alltrim( cProcesso ) + "' "
   Endif 
   If .not. Empty( cCliente ) 
      cCond+="AND EEC.EEC_CLIENT = '" + Alltrim( cCliente ) + "' " 
   Endif          
   If .not. Empty( cLojaCli ) //ASK 18/12/2007 - Incluído o campo Loja Cliente
      cCond+="AND EEC.EEC_CLLOJA = '" + Alltrim( cLojaCli ) + "' " 
   Endif                   
   If .not. Empty( cCondPagto )
      cCond+="AND EEC.EEC_CONDPA = '" + Alltrim(cCondPagto) + "' AND EEC.EEC_DIASPA = " + Str(nDias, AVSX3("EEC_DIASPA",3), AVSX3("EEC_DIASPA",4) ) + " " 
   Endif    
   cQuery:= " SELECT DISTINCT " +;
            " EEC.EEC_PREEMB , EEC.EEC_DTEMBA ,EEC.EEC_MOEDA, EEC.EEC_TOTPED , EEC.EEC_CONDPA , EEC.EEC_DIASPA ,EEC.EEC_FOLOJA ,EEC.EEC_FORN "  
   cQuery+= " , EEC.EEC_FILIAL FILORI "  
   cQuery+= " FROM "+RetSqlName("EEC")+" EEC WHERE "+cCond+;
            " ORDER BY FILORI, EEC_PREEMB"
   If EasyEntryPoint("EFFPV400")                       
      ExecBlock("EFFPV400",.F.,.F.,"QRY_FILTRA_PRV")
   EndIf
   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","EEC_DTEMBA","D")
   dbSelectArea("TRB")
   TRB->(dbGoTop())
   Do While !TRB->(EOF())                                               
     cMoeda:= TRB->EEC_MOEDA
     aParc:=AF200GPCD(TRB->EEC_TOTPED,;
                       TRB->(EEC_CONDPA+Str(EEC_DIASPA, 3)),;
                       dDataBAse,;
                       "101",;
                       TRB->EEC_FORN,;
                       TRB->EEC_FOLOJA,;
                       "" )
     For i:= 1 To Len(aParc)
       nValVinc :=  ( aParc[I][1] -  SaldoEF6(,TRB->EEC_PREEMB+Space(Avsx3("EF6_NRINVO",3))+STRZERO(i,2),.F.) )
       If nValVinc >  0                                    
          Aadd(aCols,Array(Len(aHeader)+2))
          aCols[Len(aCols)][Len(aHeader)+1] := TRB->FILORI 
          //aAdd(aInvoice,{TRB->EEC_PREEMB,,STRZERO(i,2),0})
          GDFieldPut("EF6_PREEMB",TRB->EEC_PREEMB,Len(aCols)) 
          GDFieldPut("EF6_NRINVO","",Len(aCols)) 
          GDFieldPut("EEC_DTEMBA",,Len(aCols))       
          GDFieldPut("EEC_MOEDA" ,TRB->EEC_MOEDA,Len(aCols))          
          GdFieldPut("EF6_VL_INV" , aParc[I][1] ,Len(aCols))                
          GdFieldPut("EF6_VL" , nValVinc ,Len(aCols))             
          GdFieldPut("EF6_PARC" ,STRZERO(i,2),Len(aCols))             
          GdFieldPut("EF6_OBS"   ,CriaVar("EF6_OBS"),Len(aCols))              
          If lExistForn
             GdFieldPut("EF6_CLIENT",TRB->EEC_FORN  ,Len(aCols))              
             GdFieldPut("EF6_CLLOJA"  ,TRB->EEC_FOLOJA  ,Len(aCols))             
          EndIf   
          GdFieldPut("EF6_CONTRA",CriaVar("EF6_CONTRA"),Len(aCols))             
          GdFieldPut("EF6_BANCO",CriaVar("EF6_BANCO" ),Len(aCols))             
          GdFieldPut("EF6_PRACA" ,CriaVar("EF6_PRACA" ),Len(aCols))             
          If lEFFTpMod
             GDFieldPut("EF6_SEQCNT",CriaVar("EF6_SEQCNT"),Len(aCols))
             GDFieldPut("EF6_TP_VIN" ,"1",Len(aCols))
          EndIf
//          GdFieldPut("EF6_TP_FIN",CriaVar("EF6_TP_FIN"),Len(aCols))              
//          GdFieldPut("EF6_VM_FIN",Posicione("SX5",1,xFilial("SX5")+"CG"+"01","X5_DESCRI"),Len(aCols))	                   
//        GdFieldPut("EF6_VL_VIN",CriaVar("EF6_VL_VIN"),Len(aCols))
          GdFieldPut("EF6_VL_VIN" , nValVinc ,Len(aCols))                               
          GdFieldPut("EF6_DT_LIB" ,CriaVar("EF6_DT_LIB"),Len(aCols))                    
          aCols[Len(aCols)][Len(aHeader) +2] := .F.
          If lMulTiFil
             GdFieldPut("EF6_FILORI" ,AvgFilName({TRB->FILORI })[1],Len(aCols))                   
          EndIf
          If EasyEntryPoint("EFFPV400")                       
             ExecBlock("EFFPV400",.F.,.F.,"GRV_ACOLS_PROC")
          EndIf
       EndIF   
     Next                  
     TRB->(dbSkip())                                                    
   EndDo                                                              
TRB->(DbCLoseArea()) 
Else
   cCond := ""
   If .not. Empty( cProcesso ) 
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_PREEMB = '" + Alltrim( cProcesso ) + "' "
   Endif 
   If .not. Empty( cCliente ) 
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_CLIENT = '" + Alltrim( cCliente ) + "' "
   Endif          
   If .not. Empty( cLojaCli ) //ASK 18/12/2007 - Incluído o campo Loja Cliente
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_CLLOJA = '" + Alltrim( cLojaCli ) + "' "
   Endif     
   If .not. Empty( cCondPagto )
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_CONDPA = '" + Alltrim(cCondPagto) + "' .AND. EEC->EEC_DIASPA = nDias" 
   Endif  
   If Empty (cCond)
      cCond := ".t."
   Endif
   EEQ->(DbSetOrder(1))
   EEC->(DbSetOrder(1))
   For nFil:=1 to Len(aFiliais)
      EEC->(DbSeek(aFiliais[nFil]))
      Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL == aFiliais[nFil]  
         If EEC->EEC_STATUS <> '*'  .AND. Empty(EEC->EEC_DTEMBA) .AND. &(cCond)
            cMoeda:= EEC->EEC_MOEDA
            aParc:=AF200GPCD(EEC->EEC_TOTPED,;
                           EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)),;
                           dDataBAse,;
                           "101",;
                           EEC->EEC_FORN,;
                           EEC->EEC_FOLOJA,;
                           "" )
            For i:= 1 To Len(aParc)
               nValVinc :=  ( aParc[I][1] -  SaldoEF6(,EEC->EEC_PREEMB+Space(Avsx3("EF6_NRINVO",3))+STRZERO(i,2),.F.) )
               If nValVinc >  0                                    
                  Aadd(aCols,Array(Len(aHeader)+2))
                  aCols[Len(aCols)][Len(aHeader)+1] := EEC->EEC_FILIAL
                  //aAdd(aInvoice,{EEC->EEC_PREEMB,,STRZERO(i,2),0})
                  GDFieldPut("EF6_PREEMB",EEC->EEC_PREEMB,Len(aCols)) 
                  GDFieldPut("EF6_NRINVO","",Len(aCols)) 
                  GDFieldPut("EEC_DTEMBA",,Len(aCols))       
                  GDFieldPut("EEC_MOEDA" ,EEC->EEC_MOEDA,Len(aCols))          
                  GdFieldPut("EF6_VL_INV" , aParc[I][1] ,Len(aCols))                
                  GdFieldPut("EF6_VL" , nValVinc ,Len(aCols))             
                  GdFieldPut("EF6_PARC" ,STRZERO(i,2),Len(aCols))             
                  GdFieldPut("EF6_OBS"   ,CriaVar("EF6_OBS"),Len(aCols))              
                  If lExistForn
                     GdFieldPut("EF6_CLIENT",EEC->EEC_FORN  ,Len(aCols))              
                     GdFieldPut("EF6_CLLOJA"  ,EEC->EEC_FOLOJA  ,Len(aCols))             
                  EndIf   
                  GdFieldPut("EF6_CONTRA",CriaVar("EF6_CONTRA"),Len(aCols))             
                  GdFieldPut("EF6_BANCO",CriaVar("EF6_BANCO" ),Len(aCols))             
                  GdFieldPut("EF6_PRACA" ,CriaVar("EF6_PRACA" ),Len(aCols))             
                  If lEFFTpMod
                     GDFieldPut("EF6_SEQCNT",CriaVar("EF6_SEQCNT"),Len(aCols))
                     GDFieldPut("EF6_TP_VIN" ,"1",Len(aCols))
                  EndIf
//                  GdFieldPut("EF6_TP_FIN",CriaVar("EF6_TP_FIN"),Len(aCols))              
//                  GdFieldPut("EF6_VM_FIN",Posicione("SX5",1,xFilial("SX5")+"CG"+"01","X5_DESCRI"),Len(aCols))
//                  GdFieldPut("EF6_VL_VIN",CriaVar("EF6_VL_VIN"),Len(aCols))
                  GdFieldPut("EF6_VL_VIN" , nValVinc ,Len(aCols))                               
                  GdFieldPut("EF6_DT_LIB" ,CriaVar("EF6_DT_LIB"),Len(aCols))                    
                  aCols[Len(aCols)][Len(aHeader) +2] := .F.
                  If lMulTiFil
                     GdFieldPut("EF6_FILORI" ,AvgFilName({EEC->FILIAL })[1],Len(aCols))                   
                  EndIf
//;                  If EasyEntryPoint("EFFPV400")                       
//                     ExecBlock("EFFPV400",.F.,.F.,"GRV_ACOLS_PROC")
//                  EndIf
               Endif
            Next   
         EndIf
         EEC->(DbSkip())
      Enddo
   Next nFil 
EndIf           
Return .T.   
*------------------------------*
Static Function VldContra(cContra,cBanco,cPraca,cSeqCnt,cFilORi,cProcesso,cInvoice,cParcela,lGDados)
*------------------------------*                               
Local lRet := .T.     
Local lShowMsg := .F.
Local i
Default lGDados := .F.
EF3->(DbSetOrder(6))
Begin Sequence
   If lGDados
      For i:=1 To Len(aCols)
          If i!=n .AND. cProcesso == GdFieldGet("EF6_PREEMB" ,i) .ANd. cInvoice == GdFieldGet("EF6_NRINVO" ,i)  .And. cParcela == GdFieldGet("EF6_PARC" ,i) .And. ;
             GdFieldGet("EF6_CONTRA" ,i) = cContra  .AND.;
             IIF(lTemPraca,cBanco == GdFieldGet("EF6_BANCO" ,i) .AND. GdFieldGet("EF6_PRACA" ,i) == cPraca,.T. ) .And. ;
             IIF(lEFFTpMod,cSeqCnt == GDFieldGet("EF6_SEQCNT",i),.T.)
                lRet := .F.
                Exit
          EndIf
      Next
   EndIf   
   If lRet  .And.  EF6->(DbSeek(cFilEF6+cContra+cBanco+cPraca+IIF(lEFFTpMod,cSeqCnt,""))) .AnD. cInvoice == EF6->EF6_NRINVO .AND. cParcela == EF6->EF6_PARC
      lRet := .F.
   EndIf      
   If lRet  .And.  EF3->(DbSeek(cFilEF3+IIF(lEFFTpMod,"E","")+cContra+If(lTemPraca,cBanco+cPraca,"")+IIF(lEFFTpMod,cSeqCnt,"")+cInvoice+cParcela)) 
      lRet := .F.
   EndIf   
   If !lRet
      MsgInfo("Contrato " + Alltrim(cContra) + STR0054 + "-" + Alltrim(cInvoice) + " / " + Alltrim(cParcela)) //" ja cadastrado para a invoice / parcela "
      Break
   EndIf
   If EF1->(DbSeek(cFilEF1+IIF(lEFFTpMod,"E","")+cContra+If(lTemPraca,cBanco+cPraca,"")+IIF(lEFFTpMod,cSeqCnt,"")))  .AND. !Empty(EF1->EF1_DT_ENC)
      MsgInfo(STR0033+Alltrim(cContra)+STR0038+Dtoc(EF1->EF1_DT_ENC))  //"O Contrato "###" já foi Encerrado em: "
      lRet := .F.
      Break
   EndIf
   //** PLB 31/07/06
   If lGDados
      For i:=1 To Len(aCols)
          If i!=n  ;
             .And.  cProcesso == GdFieldGet("EF6_PREEMB" ,i)  ;
             .And.  cInvoice  == GdFieldGet("EF6_NRINVO" ,i)  ;
             .And.  cParcela  == GdFieldGet("EF6_PARC"   ,i)  ;
             .And.  !Empty(GdFieldGet("EF6_CONTRA" ,i))       ;
             .And.  IIF(lTemPraca, !Empty(GdFieldGet("EF6_BANCO" ,i))        ;
                            .And.  !Empty(GdFieldGet("EF6_PRACA" ,i)) ,.T. ) ;
             .And.  IIF(lEFFTpMod,   !Empty(GDFieldGet("EF6_SEQCNT",i)) ,.T.)
             MsgInfo(STR0073+cInvoice+" / "+cParcela+;  // "A Invoice / Parcela '"
                     STR0074+AllTrim(GDFieldGet("EF6_CONTRA",i))+; // "' já está Pré-vinculada para o Contrato '"
                     IIF(lTemPraca,"', "+STR0047+" '"+AllTrim(GDFieldGet("EF6_BANCO",i))+"', "+STR0048+" '"+AllTrim(GDFieldGet("EF6_PRACA",i)),"")+;  // Banco ## Praca
                     IIF(lEFFTpMod,"' e "+STR0067+" '"+AllTrim(GDFieldGet("EF6_SEQCNT",i)),"")+"'.")  // Sequencia
             lShowMsg := .T.
             Exit
          EndIf
      Next
   EndIf   
   EF6->( DBSetOrder(2) )
   If !lShowMsg  .And.  EF6->( DBSeek(cFilEF6+cProcesso+cInvoice+cParcela) )
      MsgInfo(STR0073+cInvoice+" / "+cParcela+;  // "A Invoice / Parcela '"
               STR0074+EF6->EF6_CONTRA+; // "' já está Pré-vinculada para o Contrato '"
               IIF(lTemPraca,"', "+STR0047+" '"+EF6->EF6_BANCO+"', "+STR0048+" '"+EF6->EF6_PRACA,"")+;  // Banco ## Praca
               IIF(lEFFTpMod,"' e "+STR0067+" '"+EF6->EF6_SEQCNT,"")+"'.")  // Sequencia
      lShowMsg := .T.
      EF6->( DBSetOrder(1) )
   EndIf      
   //**
   If Posicione("EEQ",1,cFilOri+cProcesso+cParcela,"EEQ_VCT") > Posicione("EF1",1,cFilEF1+IIF(lEFFTpMod,"E","")+cContra+If(lTemPraca,cBanco+cPraca,"")+IIF(lEFFTpMod,cSeqCnt,""),"EF1_DT_VIN") 
      MsGInfo(STR0043) //"Data limite para a vinculação do contrato maior que a data de vencimento da fatura"
   EndIf
   //If lRet
   //   MsgInfo(".")
   //EndIf
End Sequence

Return lRet

*--------------------------------*
Function PV400Estor(cAlias,nReg,nOpc)
*--------------------------------*

EF6->(DBClearFilter())

//** PLB 22/03/06
EF3->(DbSetOrder(6))
If EF3->(DbSeek(cFilEF3+IIF(lEFFTpMod,"E","")+EF6->EF6_CONTRA+If(lTemPraca,EF6->EF6_BANCO+EF6->EF6_PRACA,"")+IIF(lEFFTpMod,EF6->EF6_SEQCNT,"")+EF6->EF6_NRINVO+EF6->EF6_PARC))
   Do While EF3->EF3_CODEVE != "600"
      EF3->( DBSkip() )
   EndDo
   If EF3->EF3_VL_INV != EF6->EF6_VL_VIN
      If MsgNoYes(STR0056) //"Deseja estornar esta previnculação ? "
         RecLock("EF6",.F.)
         EF6->( DBDelete() )
         EF6->( MSUnlock() )
      EndIf
   ElseIf !Empty(EF6->EF6_DT_LIB)
      MsGInfo(STR0055) //"Invoice ja possui vinculção, estorne a vinculação pela manutenção de cambio ou financiamento"
   ElseIf Empty(EF6->EF6_DT_LIB)
      If MsgYesNo(STR0068+STR0072)  // "Esta parcela da Invoice já foi vinculada pela Manutenção de Câmbio ou Financiamento. Deseja marcar esta pré-vinculação como efetivada?"
         RecLock("EF6",.F.)
         EF6->EF6_VL_INV := EF6->EF6_VL_VIN
         EF6->EF6_DT_LIB := dDataBAse
         EF6->EF6_HR_LIB := Time()
         EF6->EF6_USUARI := UPPER(ALLTRIM(cUserName))
         EF6->(MsUnlock())
      ElseIf MsgNoYes(STR0056) //"Deseja estornar esta previnculação ? "
         RecLock("EF6",.F.)
         EF6->( DBDelete() )
         EF6->( MSUnlock() )
      EndIf
   EndIf
ElseIf MsgNoYes(STR0056) //"Deseja estornar esta previnculação ? "
   RecLock("EF6", .F.)
   EF6->( DBDelete() )
   EF6->( MSUnlock() )
EndIf
EF6->(DBClearFilter())
Filtra()
Return .T.

*--------------------------------*
Function PV400Filtro()
*--------------------------------*
Local oDlg                
Local aFiltro := {STR0057,STR0058,STR0059} //"1-Pre-vinculados"###"2-Efetivados"###"3-Ambos"
Local lOk := .T.
   DEFINE MSDIALOG oDlg TITLE STR0060 FROM 200,200 TO 320,500  OF oMainWnd PIXEL //"Filtros"
      @ 40,08  SAY STR0061  Of oDlg Pixel  //"Filtro"
      @ 40,40 COMBOBOX cFiltro ITEMS aFiltro  SIZE 60,08 of oDlg Pixel
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,{|| oDlg:End()},{|| lOk:= .F. , oDlg:End() }) CENTERED
If lOk
   Filtra()
EndIF
Return .T.

*--------------------------------*
Static Function Filtra()
*--------------------------------*
Do Case
   Case Left(cFiltro,1)=="1"
       EF6->(DBSetFilter( {|| Empty(EF6->EF6_DT_LIB) }, "Empty(EF6->EF6_DT_LIB)"))  
   Case Left(cFiltro,1)=="2"
       EF6->(DBSetFilter( {|| !Empty(EF6->EF6_DT_LIB) }, "!Empty(EF6->EF6_DT_LIB)"))         
   Case Left(cFiltro,1)=="3"
       EF6->(DBClearFilter())
EndCase
Return .T.

*---------------------------------------------------------------------------------------------------*
Static Function PV400Valid()
*---------------------------------------------------------------------------------------------------*
Local lRet := .T., i:=0, aCont:={}, nPos

EF6->( DBSetOrder(2) )  // PLB 23/03/06
For i := 1 to Len(aCols)
    If !Empty(GdFieldGet("EF6_CONTRA",i) )// .And. GdFieldGet("EF6_VL_VIN",i) > 0
      If (nPos:=aScan(aCont,{|x| x[1]==GdFieldGet("EF6_CONTRA",i) .and. If(lTemPraca,x[2]==GdFieldGet("EF6_BANCO",i) .and.;
      x[3]==GdFieldGet("EF6_PRACA",i),.T.) .And. IIF(lEFFTpMod,x[5]==GdFieldGet("EF6_SEQCNT",i) .And. x[6]==GdFieldGet("EF6_TP_VIN",i),.T.) .And. x[7]==GdFieldGet("EEC_MOEDA",i) }) ) = 0
         aAdd(aCont,{GdFieldGet("EF6_CONTRA",i),If(lTemPraca,GdFieldGet("EF6_BANCO",i),),If(lTemPraca,GdFieldGet("EF6_PRACA",i),),GdFieldGet("EF6_VL_VIN",i),IIF(lEFFTpMod,GdFieldGet("EF6_SEQCNT",i),""),IIF(lEFFTpMod,GdFieldGet("EF6_TP_VIN",i),""),GdFieldGet("EEC_MOEDA",i) } )
      Else
         aCont[nPos,4] += GdFieldGet("EF6_VL_VIN",i)
      EndIf
      //** PLB 23/03/06
      If EF6->( DBSeek(cFilEF6+GdFieldGet("EF6_PREEMB",i)+GdFieldGet("EF6_NRINVO",i)+GdFieldGet("EF6_PARC",i)) )
         Do While !EF6->( EOF() ) .And. GdFieldGet("EF6_PREEMB",i)==EF6->EF6_PREEMB .And. GdFieldGet("EF6_NRINVO",i)==EF6->EF6_NRINVO .And. ;
         GdFieldGet("EF6_PARC",i)==EF6->EF6_PARC .And. ( GDFieldGet("EF6_CONTRA",i)!=EF6->EF6_CONTRA .Or. IIF(lTemPraca,GDFieldGet("EF6_BANCO",i)!=EF6->EF6_BANCO .Or. ;
         GDFieldGet("EF6_PRACA",i)!=EF6->EF6_PRACA,.F.) .Or. IIF(lEFFTpMod,GDFieldGet("EF6_SEQCNT",i)!=EF6->EF6_SEQCNT,.F.) .Or. aCols[i][Len(aHeader)+1]!=EF6->EF6_FILORI .Or. !Empty(EF6->EF6_DT_LIB) )
            EF6->( DBSkip() )
         EndDo
         If nOption == INCLUIR  .And.  !EF6->( EOF() ) .And. GdFieldGet("EF6_PREEMB",i)==EF6->EF6_PREEMB .And. GdFieldGet("EF6_NRINVO",i)==EF6->EF6_NRINVO .And. ;
            GdFieldGet("EF6_PARC",i)==EF6->EF6_PARC   

            MsgInfo(STR0073+AllTrim(GdFieldGet("EF6_NRINVO",i))+" / "+AllTrim(GdFieldGet("EF6_PARC",i))+;  // "A Invoice / Parcela '"
                    STR0074+AllTrim(GDFieldGet("EF6_CONTRA",i))+; // "' já está Pré-vinculada para o Contrato '"
                    IIF(lTemPraca,"', "+STR0047+" '"+AllTrim(GDFieldGet("EF6_BANCO",i))+"', "+STR0048+" '"+AllTrim(GDFieldGet("EF6_PRACA",i)),"")+;  // Banco ## Praca
                    IIF(lEFFTpMod,"' e "+STR0067+" '"+AllTrim(GDFieldGet("EF6_SEQCNT",i)),"")+"'."+CHR(10)+CHR(13)+;  // Sequencia
                    STR0075+CHR(10)+CHR(13)+;  // "Se desejar aumentar o valor da Pré-Vinculação siga as etapas:"
                    STR0076+CHR(10)+CHR(13)+;  // " 1º Limpe ou altere esta Pré-Vinculação,"
                    STR0077+CHR(10)+CHR(13)+;  // " 2º Clique em 'OK' para confirmar as demais Pré-Vinculações,"
                    STR0078)                   // " 3º Localize esta Pré-Vinculação na tela inicial, clique em alterar e coloque o valor desejado."
            lRet := .F.
            Exit
         EndIf
      EndIf
      //**
   EndIf
Next i

For i:=1 to Len(aCont)
   If EF1->(DbSeek(cFilEF1+IIF(lEFFTpMod,"E","")+aCont[i,1]+If(lTemPraca,aCont[i,2]+aCont[i,3],"")+IIF(lEFFTpMod,aCont[i,5],"")))
      If aCont[i,4] > IIF(lEFFTpMod .And. aCont[i,6]=="2",If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("JUROS",.T.,aCont[i][7],dDataBase),EF1->EF1_SLD_JM * BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.) / BuscaTaxa(aCont[i][7],dDataBase,.T.,.F.,.T.)),If(lEFFTpMod .AND. EF1->EF1_CAMTRA == "1",PV400SldPar("PRINCIPAL",.T.,aCont[i][7],dDataBase),EF1->EF1_SLD_PM * BuscaTaxa(EF1->EF1_MOEDA,dDataBase,.T.,.F.,.T.) / BuscaTaxa(aCont[i][7],dDataBase,.T.,.F.,.T.)))
         MsgInfo(STR0033+Alltrim(aCont[i,1])+If(lTemPraca,STR0034+Alltrim(aCont[i,2])+STR0035+Alltrim(aCont[i,3])+IIF(lEFFTpMod,"sequencia "+AllTrim(aCont[i,5]),"")+STR0036,)) //"O contrato " # " Banco " # " Praça " # " näo possui saldo para vinculacäo"
         lRet := .F.
         Exit
      EndIf 
   Else
      MsgStop( STR0079+STR0046+" "+AllTrim(aCont[i,1])+IIF(lTemPraca,", "+STR0047+" "+AllTrim(aCont[i,2])+", "+STR0048+" "+AllTrim(aCont[i,3]),"")+IIF(lEFFTpMod," e "+STR0067+" "+AllTrim(aCont[i,5]),"") )  // Não existe  ## Contrato ## Banco ## Praca ## Sequencia
      lRet := .F.
      Exit
   EndIf
Next i

Return lRet


*---------------------------------------------------------------------------------------------------*
Static Function PV400PrePg()     // PLB 29/03/06 - Opcao de Vinculacao a Principal ou Juros
*---------------------------------------------------------------------------------------------------*

 Local oCombo, cSelecao := "", aValores := {""}

   aValores := { STR0084 , STR0085 } // "1-Principal" ## "2-Juros"

   DEFINE MSDIALOG oDlg2 TITLE STR0086 FROM oMainWnd:nTop+150, oMainWnd:nLeft+50 TO oMainWnd:nTop +250, oMainWnd:nLeft + 400 OF oMainWnd PIXEL   // "Pre-Vinculacao a Contrato do Tipo Pre-Pagamento"

   @ 12,25  Say STR0087 Of oDlg2 pixel  // "Pre-Vincular a:"
   @ 12,68  Combobox oCombo var cSelecao items aValores size 80,08 of oDlg2 pixel
   @ 32,70 BUTTON "OK" SIZE 34,11 Of oDlg2 pixel ACTION oDlg2:END()

   ACTIVATE MSDIALOG oDlg2 centered

   GDFieldPut( "EF6_TP_VIN" , Left(cSelecao,1) , n )

Return .T.

//AAF 06/05/2006 - Função para retorno do Saldo de Contrato com Parcelas de Pagamento.
***********************************************
Function PV400SldPar(cTipo,lConv,cMoeda,dData)
***********************************************
Local cFilEF3 := xFilial("EF3")
Local nSld    := 0

IIF(lConv  == NIL, lConv  := .F.             , )
IIF(cMoeda == NIL, cMoeda := ""              , )
IIF(dData  == NIL, dData  := CToD("  /  /  "), )

EF3->( dbSetOrder(1) )
   
If cTipo == "PRINCIPAL"
      
   EF3->( DBSeek(cFilEF3+IIF(lEFFTpMod,"E","")+EF1->EF1_CONTRA+IIF(lTemPraca,EF1->EF1_BAN_FI+EF1->EF1_PRACA,"")+IIF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"700") )
   Do While EF3->( !EoF() .AND. EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IIF(lEFFTpMod,"E","")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,"")+"700") )
      nSld      += EF3->EF3_SLDVIN
      
      EF3->( DBSkip() )
   EndDo
   
ElseIf cTipo == "JUROS"
   EF2->(dbSetOrder(2))
   
   EF3->( dbSeek(cFilEF3+IIF(lEFFTpMod,"E","")+EF1->EF1_CONTRA+IIF(lTemPraca,EF1->EF1_BAN_FI+EF1->EF1_PRACA,"")+IIF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
   
   Do While EF3->( !EoF() .AND. EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,"")+Left(EF3_CODEVE,2) == cFilEF3+IIF(lEFFTpMod,"E","")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+If(lEFFTpMod,EF1_SEQCNT,"")+"71") )
      
      EF2->( dbSeek(xFilial("EF2")+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+If(lEF2_INVOIC,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC)),"")+;
                                   EF1->EF1_TP_FIN+If(lEF2_TIPJUR,Right(EF3->EF3_CODEVE,1),"")+DtoS(EF3->EF3_DT_EVE),.T.))
      
      If EF2->(Eof()) .or. If(lEFFTpMod,EF2->EF2_TPMODU,"")+EF2->EF2_CONTRA <> If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA .or.;
      EF2->EF2_TP_FIN <> EF1->EF1_TP_FIN .or. iif(lTemChave,EF2->EF2_BAN_FI+EF2->EF2_PRACA+If(lEFFTpMod,EF2->EF2_SEQCNT,"")<>EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),.F.) .or.;
      If(lEF2_TIPJUR,EF2->EF2_TIPJUR<>Right(EF3->EF3_CODEVE,1),.F.)
         EF2->(dbSkip(-1))
      EndIf
      
      If EF2->EF2_DT_INI > EF3->EF3_DT_EVE
         EF2->(dbSkip(-1))
         
         If EF2->(BOF()) .or.;
         If(lEFFTpMod,EF2->EF2_TPMODU,"")+EF2->EF2_CONTRA <> If(cAliasEF1=="M",If(lEFFTpMod,M->EF2_TPMODU,"")+M->EF1_CONTRA,If(lEFFTpMod,EF2->EF2_TPMODU,"")+EF1->EF1_CONTRA) .or.;
         EF2->EF2_TP_FIN <> If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN) .or. iif(lTemChave,EF2->EF2_BAN_FI+EF2->EF2_PRACA+If(lEFFTpMod,EF2->EF2_SEQCNT,"")<>EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),.F.) .or.;
         If(lEF2_TIPJUR,EF2->EF2_TIPJUR<>Right(EF3->EF3_CODEVE,1),.F.)
            EF3->(dbSkip())
            Loop
         ElseIf (EF2->EF2_DT_INI > EF3->EF3_DT_EVE .or. EF2->EF2_DT_FIM < EF3->EF3_DT_EVE) .or.;
         EF2->EF2_USEINV == "2"
            EF3->(dbSkip())
            Loop
         Else
            nSld      += EF3->EF3_SLDVIN
         EndIf
      ElseIf EF2->EF2_DT_INI > EF3->EF3_DT_EVE .or. EF2->EF2_DT_FIM < EF3->EF3_DT_EVE .or.;
      EF2->EF2_USEINV == "2"
         EF3->(dbSkip())
         Loop
      Else
         nSld      += EF3->EF3_SLDVIN
      EndIf
      
      EF3->( DBSkip() )
   EndDo
   
EndIf

//** PLB 21/07/06
If lConv
   nSld := nSld * BuscaTaxa(EF1->EF1_MOEDA,dData,.T.,.F.,.T.) / BuscaTaxa(cMoeda,dData,.T.,.F.,.T.)
EndIf
//**

Return nSld
*---------------------------------------------------------------------------------------------------*
Static Function DtValidVinc(dData)// FSY - Função para validar o campo da data de vinculação ao marcar caixa mark na rotina "Efetivo". 10/04/2013
*---------------------------------------------------------------------------------------------------*
Local lRet := .T.
//dData,nTX variaveis private
If(Empty(dData))
   nTX:=0
Else
   nTX:=BuscaTaxa(EFETIVA->EF6_MOEDA,dData,,.F.,.T.,,"1")
End If

If !Empty(EEQ->EEQ_DTCE) .And. dData>EEQ->EEQ_DTCE
   MsgInfo("Data de Vinculação não pode ser maior que a Data de credito exterior ("+ DtoC(EEQ->EEQ_DTCE) +").")
   lRet := .F.
End If

Return lRet
*-------------------------*
Function PV400Legenda()
*-------------------------*
Local aColors := {}
aAdd(aColors,{"BR_VERDE"   , "Pré-Vinculação não efetivada" })
aAdd(aColors,{"BR_VERMELHO", "Pré-Vinculação efetivada" })
Return BrwLegenda(STR0095, STR0095, aColors)  // "Legenda"  ## "Legenda"