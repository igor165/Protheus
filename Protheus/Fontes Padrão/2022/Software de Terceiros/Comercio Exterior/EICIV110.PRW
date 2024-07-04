//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICIV110.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICIV110 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 16/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Consulta de Invoices                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICIV110

PRIVATE aRotina := MenuDef()


PRIVATE cCadastro := OemtoAnsi(STR0004) //"Invoices"
PRIVATE cTitItem  := OemtoAnsi(STR0005) //"Itens da Invoice"
PRIVATE cCambio   := OemtoAnsi(STR0006) //"Cƒmbio"
PRIVATE aFixo     :={}
PRIVATE aCampos:={}

PRIVATE lRdmake:=EasyEntryPoint("EICIV110")
PRIVATE lCposAdto:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado

PRIVATE bSeek2 :={||SWB->(DBSEEK(xFILIAL()+SW9->W9_HAWB)) }
PRIVATE bSeek1 :={||SW8->(DBSEEK(xFILIAL()+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN)) }                         

PRIVATE bWhile1:={||SW8->W8_FILIAL  == xFILIAL("SW8")  .AND. ;
                    SW8->W8_HAWB    == SW9->W9_HAWB    .AND. ;
                    SW8->W8_INVOICE == SW9->W9_INVOICE .AND. ;
                    SW8->W8_FORN    == SW9->W9_FORN }, bFor:=NIL
PRIVATE bWhile2:={||SWB->WB_FILIAL  == xFILIAL("SWB")  .AND. ;
                    SWB->WB_HAWB    == SW9->W9_HAWB }

IF(EasyEntryPoint("EICIV110"),ExecBlock("EICIV110",.F.,.F.,"MBROWSE"),)

IF lCposAdto
   bSeek2  := {||SWB->(DBSEEK(xFILIAL()+SW9->W9_HAWB+"D")) }
   bWhile2 := {|| SWB->WB_FILIAL  == xFILIAL("SWB")  .AND. ;
                  SWB->WB_HAWB    == SW9->W9_HAWB    .AND. ;
                  SWB->WB_PO_DI   == "D" } 
ENDIF   

mBrowse( 6, 1,22,75,"SW9",aFixo)

Return .T.
/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 06/02/07 - 11:02
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := {{STR0001, "AxPesqui"  , 0, 1},;//"Pesquisar"
                   {STR0002, "IV110Visua", 0, 2}} //"Visual"

If cPaisLoc == "BRA"
   aAdd(aRotina, {STR0003, "IV110Cambi", 0, 2})//"Cambio"
EndIf

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IIV110MNU")
	aRotAdic := ExecBlock("IIV110MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IV110Visua³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para visualizacao dos Itens da Invoice            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void IV110Visua(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IV110Visua(cAlias,nReg,nOpc)

PRIVATE aCamposWK:={"W8_COD_I","W8_QTDE","W8_PRECO","W8_PO_NUM","W8_PGI_NUM","W8_SEQ_LI",;
                    "W8_CC"}   

If EasyEntryPoint("EICPIV01")                                                 //MJB-SAP-1100
   ExecBlock("EICPIV01",.F.,.F.)                                          //MJB-SAP-1100
Endif                                                                     //MJB-SAP-1100

Return IV110Detalhe(cAlias,nReg,nOpc,"SW8",bSeek1,bWhile1,cTitItem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³IV110Cambi³ Autor ³ AVERAGE/MJBARROS      ³ Data ³ 26.09.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para Cambio                                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void IV110Cambi(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IV110Cambi(cAlias,nReg,nOpc)
PRIVATE aCamposWK :={"WB_DT_VEN","WB_CA_NUM","WB_FOBMOE","WB_CA_DT","WB_NUM",;
                     "WB_DT","WB_BANCO","WB_AGENCIA","WB_LC_NUM","WB_CA_TX",;
                     "WB_TIPO","WB_HAWB"}

IF lRdmake
   ExecBlock("EICIV110",.F.,.F.,"CAMPOS_BROWSE")
ENDIF                          
                     
                     
Return IV110Detalhe(cAlias,nReg,nOpc,"SWB",bSeek2,bWhile2,cCambio)

*----------------------------------------------------------------------------
Function IV110Detalhe(cAlias,nReg,nOpc,cAlias1,bSeek,bWhile,cTitulo)
*----------------------------------------------------------------------------

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-2)/2
#define FINAL_SELECT   (oDlg:nClientHeight-2)/2

LOCAL nOpca := 0, oDlg, cNomArq
PRIVATE aTELA[0][0], aGETS[0], aHeader[0],nEscoha:=nOpc
PRIVATE oEnch1 //LRL 06/04/04
dbSelectArea(cAlias)
IF EasyRecCount() == 0
   Return (.T.)
EndIf



ASIZE(aCampos,0)
aCampos:=ACLONE(aCamposWK)
aCamposTRB:=CriaEstru(aCamposWK,@aHeader)
AAdd(aCamposTRB,{"XX_FLAGWIN","C",2,0})
AADD(aCamposTRB,{"TRB_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(aCamposTRB,{"TRB_REC_WT","N",10,0})
AADD(aCamposTRB,{"DBDELETE","L",1,0})

//by GFP - 18/10/2010 - 15:33
aCamposTRB := AddWkCpoUser(aCamposTRB,"SWB")

cNomArq := E_CriaTrab(,aCamposTRB,"TRB") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

DBSELECTAREA("SWA")
DBSELECTAREA("SWB")
DBSELECTAREA("SW9")
DBSELECTAREA("SW8")

If ! E_GravaTRB(cAlias1,bSeek,bFor,bWhile)
   MsgInfo(STR0007) //"Não existe câmbio para esta invoice"
   TRB->(E_EraseArq(cNomArq))
   Return .T.
Endif

TRB->TRB_ALI_WT:= "SW8"
TRB->TRB_REC_WT:=  SW8->(Recno())

E_CriaCampos(aCamposTRB)



IF lRdmake
   ExecBlock("EICIV110",.F.,.F.,"ITENS_BROWSE")
ENDIF                       


While .T.

   dbSelectArea("TRB")
   dbGoTop()

   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE cTitulo ;
          From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL

      oEnCh1:=MsMget():New( cAlias,nReg,nOpc,,,,,{15,1,FINAL_ENCHOICE,COLUNA_FINAL},,3 )
      
      //by GFP - 18/10/2010 - 15:25
      aCamposTRB := AddCpoUser(aCamposTRB,"SWB","2")

      oMark:= MsSelect():New("TRB",,,aCamposTRB,.F.,"XX",{MEIO_DIALOG,1,FINAL_SELECT,COLUNA_FINAL})
      
	  oEnch1:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  
   ACTIVATE MSDIALOG oDlg ON INIT(EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})) //LRL 06/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   Exit
    
End

TRB->(E_EraseArq(cNomArq))
dbSelectArea(cAlias)
Return( nOpca )
