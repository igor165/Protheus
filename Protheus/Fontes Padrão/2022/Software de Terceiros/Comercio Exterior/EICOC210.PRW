//#include "FiveWin.ch"
#include "AVERAGE.CH"
#include "EICOC210.CH"
#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICOC210 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 15/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Consulta de Ocorrencias                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
*----------------------*
Function EICOC210S
*----------------------*   
EICOC210(.T.)
RETURN NIL

Function EICOC210(lSXD)

EICOC210R3(lSXD,.T.)

RETURN .t.

*----------------------*
Function EICOC210R3(lSXD,p_R4)
*----------------------*
PRIVATE aRotina := { { STR0001 ,"AxPesqui"  , 0 , 1},; //"Pesquisar"
                     { STR0002 ,"OC210Hist", 0 , 2},; //"Historico"
                     { STR0003 ,"OC210IMPR" , 0 , 3} } //"Impressao"

PRIVATE lEMail:=!lSXD = Nil
PRIVATE cCadastro := OemtoAnsi(STR0004) //"Status Report"
PRIVATE cTitulo   := OemtoAnsi(STR0005) //"Ocorrencias"
PRIVATE bSeek :={||SWO->(DBSEEK(xFilial()+SW2->W2_PO_NUM)) }
PRIVATE bWhile:={||xFilial("SWO") = SWO->WO_Filial  .AND. ;
                   SWO->WO_PO_NUM = SW2->W2_PO_NUM }, bFor:={||.T.}

PRIVATE aCampos:=ARRAY(SWO->(FCOUNT()))  
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                          
IF lEmail
   OC210IMPR("SW2",SW2->(RECNO()),1)
ELSE
   mBrowse( 6, 1,22,75,"SW2")
ENDIF   
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OC210Impr ³ Autor ³Robson Luiz            ³ Data ³ 15.05.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para Impressao das Ocorrencias                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void OC210Impr(ExpC1,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC210Impr(cAlias,nReg,nOpc)

LOCAL oDlg, oGet, cNomArq

// incluir variaveis para o relatorio padrao

LOCAL aDados :={"TRB",;
                STR0006,; //"Este relatorio ir  exibir as Ocorrencias para"
                STR0007 +TRAN(SW2->W2_PO_NUM,AVSX3("W2_PO_NUM",6)) ,; //"o pedido "
                "",;
                "P",;
                 80,;
                STR0008+TRAN(SW2->W2_PO_NUM,AVSX3("W2_PO_NUM",6)),; //"Pedido Nr.: "
                "",;
                STR0009,; //"Status Report"
                { "Zebrado", 1,"Importa‡Æo", 2, 2, 1, " ",1 },;
                STR0010,; //"EICOC210"
                { {|| .T. } , {|| .T. }  }  }

LOCAL aRCampos:={},cPictPO:=AVSX3("W2_PO_NUM",6)

PRIVATE aHeader[0], R_Dados:={}, R_Campos:={}, R_Funcoes:={{||.T.},{||.T.}}
PRIVATE aReturn:=aDados[10]


R_Dados:={STR0011, 80, .F., STR0012+TRAN(SW2->W2_PO_NUM,cPictPO)} //"Status Report"###"Pedido Nr. "

ASIZE(aRCampos,0)
aRCampos:={ {"WO_DT"  ,STR0013 ,"C"},; //"Data"
            {"WO_DESC",STR0014 ,"C"} } //"Descricao"


dbSelectArea(cAlias)
IF EasyRecCount() == 0
   Return (.T.)
EndIf

cNomArq:=E_CriaTrab("SWO")



IF lEmail .AND. Pergunte("EIC211",.F.)
   aDados[11]:= SetPrint(aDados[1],aDados[11],"",@aDados[9],aDados[2],aDados[3],aDados[4],.F.,"",.T.,aDados[5])
   //mv_par01:= P.O.   
   SW2->(DBSEEK(xFilial("SW2")+mv_par01))
ENDIF

If lR4
   //TRP - 31/07/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   oReport := ReportDef()
Endif


IndRegua("TRB",cNomArq+TEOrdBagExt(),"DTOS(WO_DT)")
If ! E_GravaTRB("SWO",bSeek,bFor,bWhile)
   IF !lEmail   
      Help(" ",1,"REGNOIS")	//ASR 11/11/2005 - Help(" ",1,"EICSEMITEM")
   ENDIF   
   TRB->(E_EraseArq(cNomArq))
   Return .T.
Endif      

If(lR4 .AND. !lEmail, oReport:PrintDialog() ,E_Report(aDados,aRCampos,,!lEmail))
TRB->(E_EraseArq(cNomArq))
dbSelectArea(cAlias)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OC210Hist³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para visualizacao dos Itens da SI                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void OC210Hist(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OC210Hist(cAlias,nReg,nOpc)

LOCAL nOpca := 0, oDlg, oGet, oEnch ,cNomArq, i
Local bRecno := {|x| TRB->TRB_RECNO := x }
PRIVATE aTELA[0][0],aGETS[0], aHeader[0], aDeletados := {}

dbSelectArea(cAlias)
IF EasyRecCount() == 0
   Return (.T.)
EndIf

cNomArq:=E_CriaTrab("SWO",{{"TRB_INCLUI","C",1,0}, {"TRB_RECNO", "N", 10, 0}})
IndRegua("TRB",cNomArq+TEOrdBagExt(),"DTOS(WO_DT)")
cNomArq2:=E_Create(,.F.)
IndRegua("TRB",cNomArq2+TEOrdBagExt(),"TRB_INCLUI")
SET INDEX TO (cNomArq+TEOrdBagExt()),(cNomArq2+TEOrdBagExt())

If ! E_GravaTRB("SWO",bSeek,bFor,bWhile,,bRecno)
   Help(" ",1,"REGNOIS")	//ASR 11/11/2005 - Help(" ",1,"EICSEMITEM")
   TRB->(E_EraseArq(cNomArq))
   Return .T.
Endif

//SW2->(E_InitVar()) foi trocado por causa do inicializador padrao AWR 29/04/1999
DBSELECTAREA("SW2")
FOR i := 1 TO SW2->(FCount())
   SW2->( M->&(FIELDNAME(i)) := FieldGet(i) )
NEXT

aButton:={{"EDIT",{||OC210Manut("I")},STR0016},;//AWR 21/08/00 //"Inclui"
          {"EXCLUIR" ,{||OC210Manut("E") } , STR0020 } } //TRP 09/08/07 //"Exclui"
TB_Campos:=ArrayBrowse("SWO","TRB")
nTotal:=0
dbSelectArea("TRB")
dbGoTop()

While .T.
   oMainWnd:ReadClientCoords()

   DEFINE MSDIALOG oDlg TITLE cTitulo  ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
    	    OF oMainWnd PIXEL  

      oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , , {15,1,FINAL_ENCHOICE,COLUNA_FINAL}, , 3 ) //LRL 28/04/04

//    TRB->(oGet:=MsGetDB():New(FINAL_ENCHOICE+1,1,FINAL_SELECT,COLUNA_FINAL,nOpc,"E_LinOk","E_TudOk","",.F.,, ,.T., ,"TRB"))
      
      //GFP 19/10/2010
      TB_Campos := AddCpoUser(TB_Campos,"SWO","2")
      
      oGet:=MsSelect():New("TRB",,,TB_Campos,.F.,"X",{FINAL_ENCHOICE+1,1,FINAL_SELECT,COLUNA_FINAL})
      oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
	  
	  oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT       
      oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||nopca:=0,oDlg:End()},,aButton))//Alinhamento MDI. //LRL 28/04/04 //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF nOpca = 1 
      Processa({||OC210GravaTRB()},"Gravando Ocorrencias")
      TRB->(DBSETORDER(1))
   ENDIF

   Exit

End

TRB->(E_EraseArq(cNomArq,cNomArq2))

dbSelectArea(cAlias)

Return( nOpca )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OC210Del  ³ Autor ³ AVERAGE-RS            ³ Data ³ 02/06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de OCorrencias                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OC210Del(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OC210                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OC210Del(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod 
LOCAL oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]

While .T.
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Envia para processamento dos Gets          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        nOpcA:=0

   RecLock(cAlias,.F.,.t.)
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE cCadastro+OemToAnsi(STR0015) ; //" - ExclusÆo"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
    	    OF oMainWnd PIXEL  

      //EnChoice( cAlias, nReg, nOpc, , , , , {15,1,FINAL_ENCHOICE,COLUNA_FINAL}, , 3 )
      nOpcA:=EnChoice( cAlias, nReg, nOpc)
      nOpca:= 1
   ACTIVATE MSDIALOG oDlg ON INIT ;
           EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},.T.)

   dbSelectArea(cAlias)

        IF nOpcA == 2

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Antes de deletar eu vou verificar se existe P.O.             ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                Begin Transaction

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Apos passar por todas as verificacoes , deleta o registro    ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                dbDelete()


                End Transaction
        Else
                MsUnLock()
        EndIf
        Exit
End

dbSelectArea(cAlias)
*---------------------------------------*
FUNCTION OC210Manut(cOpcao)
*---------------------------------------*
LOCAL oDlg, oPanel ,nOpca := 0, cTitle
LOCAL nRec_TRB, bOk , i
LOCAL aPos2 := {15,1,140,315}
LOCAL aCpoUser := {}

PRIVATE aTela[0][0],aGets[0]
    
Begin Sequence    
   dbSelectArea("TRB")
   nRec_Trb := TRB->(Recno())

   If cOpcao == "I"
      TRB->(dbGoBottom())
      TRB->(dbSkip())
   ElseIf cOpcao == "E" .And. SWO->(FieldPos("SWO->WO_MANUAL")) > 0 //ASK 27/09/2007 - Testa se existe o campo
      If TRB->WO_MANUAL <> "S" .Or. !(AvKey(SubStr(cUsuario,7,15), "WO_USUARIO") $ TRB->WO_USUARIO ) //TRP-14/08/07- Tratamento para exclusão apenas de ocorrências incluídas manualmente e pelo mesmo usuário.
         MsgInfo("Ocorrência não pode ser excluída pois não foi incluída manualmente, ou foi incluída por outro usuário!")
      EndIf
      Break
   Endif

   FOR i := 1 TO TRB->(FCount())
    M->&(TRB->(FIELDNAME(i))) := TRB->(FIELDGET(i))
   NEXT i
   
   //TRP-14/08/07
   If cOpcao == "I" .And. SWO->(FieldPos("SWO->WO_MANUAL")) > 0
      M->WO_MANUAL := "S"
   EndIf

   If cOpcao == "I"
      cTitle := STR0017 //"InclusÆo de Ocorrencias"
   Elseif cOpcao == "E"
      cTitle := STR0019 //"Exclusao de Ocorrencias"
   Endif

   aCpos:={"WO_DT","WO_DESC"}

   DO WHILE .T.
      nOpca := 0
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitle) ;
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-060,oMainWnd:nRight - 010 ;
     	        OF oMainWnd PIXEL                          

       aPos2[3]:=(oDlg:nClientHeight-2)/2
       aPos2[4]:=(oDlg:nClientWidth -2)/2
       oEnCh:=MsMGet():New( "SWO", nRec_TRB, IF(cOpcao=="I",3,2), , , ,aCpos, aPos2,,3,,,,,,.T.)//LRL 28/04/04
       oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
       bOk := {||IF(OC210ValidTRB(),(nOpca:=1,oDlg:End()), ) }
       oDlg:lMaximized:=.T.  //LRL 28/04/04 Maximized
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,{||nOpca:=0,oDlg:End()}))   //LRL 28/04/04    //Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

       //TRP-14/08/07 -Exclusão de ocorrências
       IF nOpca == 1
          If cOpcao == "E"
             IF TRB->(Eof() .Or. Bof())
                Help("", 1, "AVG0003035")//"Não existe registro selecionado para a exclusão !"###"Atenção"
                Break
             Endif
             If TRB->TRB_RECNO != 0
                aAdd(aDeletados, TRB->TRB_RECNO)
             Endif   
             TRB->(dbDelete())
          Else
             TRB->(DBAPPEND())
             AVREPLACE("M","TRB")
             TRB->TRB_INCLUI:="I" 
/*           TRB->WO_DT     :=M->WO_DT
             TRB->WO_DESC   :=M->WO_DESC
             TRB->WO_USUARIO:=SUBSTR(cUsuario,7,15)
             If SWO->(FieldPos("SWO->WO_MANUAL")) > 0
                TRB->WO_MANUAL :=M->WO_MANUAL
             EndIf        */
             TRB->WO_USUARIO:=SUBSTR(cUsuario,7,15)
             nTotal++                              
             M->WO_DESC:=SPACE(LEN(TRB->WO_DESC))
            
             // FDR - 04/05/11 - Limpar o campo de usuário na nova inclusão
             AddCpoUser(aCpoUser,"SWO","2")
             For i := 1 To Len(aCpoUser)
                 M->&(aCpoUser[i][1]) := CriaVar(aCpoUser[i][1])
             Next

             LOOP
          EndIf
          
       ENDIF

       EXIT

   ENDdo

End Sequence

RETURN .T.
*---------------------------------------*
FUNCTION OC210ValidTRB()
*---------------------------------------*
IF !NaoVazio(M->WO_DT)
   RETURN .F.
ENDIF
IF !NaoVazio(M->WO_DESC)
   RETURN .F.
ENDIF
RETURN .T.
*---------------------------------------*
FUNCTION OC210GravaTRB()
*---------------------------------------*
Local nInc
ProcRegua(nTotal)
TRB->(DBSETORDER(2))
TRB->(DBSEEK("I"))

DO WHILE TRB->TRB_INCLUI = "I" .AND. !TRB->(EOF())

   IncProc(STR0018+dtoc(TRB->WO_DT)) //"Gravando Data: "
   SWO->(RECLOCK("SWO",.T.))
   //FDR - 04/05/11 - Tratamento para gravação da ocorrência
   AvReplace("TRB","SWO")
   SWO->WO_FILIAL :=xFilial("SWO")
   SWO->WO_PO_NUM :=SW2->W2_PO_NUM
   /* FDR - 04/05/2011
   SWO->WO_DT     :=TRB->WO_DT
   SWO->WO_DESC   :=TRB->WO_DESC
   SWO->WO_USUARIO:=TRB->WO_USUARIO
   If SWO->(FieldPos("SWO->WO_MANUAL")) > 0
      SWO->WO_MANUAL :=TRB->WO_MANUAL
   EndIf   */

   SWO->(MSUNLOCK())
   TRB->(DBSKIP())

ENDDO
//TRP-14/08/07
For nInc := 1 To Len(aDeletados)
   SWO->(DbGoTo(aDeletados[nInc]))
   SWO->(RecLock("SWO", .F.))
   SWO->(DbDelete())
   SWO->(MsUnlock())
Next

TRB->(DBSETORDER(1))

RETURN .T. 

//TRP - 31/07/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SWO"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICOC210",STR0009,"EIC211",{|oReport| ReportPrint(oReport)},STR0006+ " " + STR0007 +TRAN(SW2->W2_PO_NUM,AVSX3("W2_PO_NUM",6)))
               
//oReport:Say(oReport:oPage:nPageHeight-175,50, STR0008+TRAN(SW2->W2_PO_NUM,AVSX3("W2_PO_NUM",6)))

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Status",aTabelas,aOrdem)
 
//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Pedido",{"SW2"},aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WO_DT"       ,"TRB"   ,STR0013      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WO_DESC"     ,"TRB"   ,STR0014      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)

//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,"W2_PO_NUM"   ,"SW2"   ,STR0012      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
oReport:Section("Pedido"):Cell("W2_PO_NUM"):SetCellBreak()
oReport:bOnPageBreak :={||oReport:Section("Pedido"):PrintLine()}  

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Status"),"SWO",1,{|| xFilial("SWO") + SW2->W2_PO_NUM})

//oSection:Print()
oReport:SetMeter (TRB->(EasyRecCount()))
TRB->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Status"):Init()

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Pedido"):Init()

//Laço principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Status"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Status"):Finish()
//Fim da impressão da seção 2
oReport:Section("Pedido"):Finish()
Return .T. 
