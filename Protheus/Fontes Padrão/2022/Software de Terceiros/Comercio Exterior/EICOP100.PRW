#INCLUDE "Eicop100.ch"
#include "Average.ch"
#INCLUDE "APWIZARD.ch"
#INCLUDE "FWBROWSE.CH"
//#include "FiveWin.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICOP100 ³ Autor ³ AVERAGE-CRISTIANO     ³ Data ³ 10/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Manutencao de C.F.O.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION EICOP100
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL i:=1, nOldArea:=SELECT()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()
PRIVATE cDelFunc 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0006) //"Cadastro C.F.O."
PRIVATE cTitulo   := OemtoAnsi(STR0007) //"Manuten‡Æo de C.F.O."

PRIVATE aCampos := {}, aHeader[0]

PRIVATE bSeek :={||SWZ->(DBSEEK(xFilial()+SWX->WX_COD)) }
PRIVATE bWhile:={||xFilial("SWZ") = SWZ->WZ_FILIAL  .AND. ;
                   SWZ->WZ_CFO = SWX->WX_COD }, bFor:={||.T.}
Private cSeek //bSWXWhile := {|| xFilial("SWZ") + SWX->WX_COD }                   
Private aTela, aGets

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis com nome dos campos de Bancos de Dados        ³
//³ para serem usadas na funcao de inclusao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SWX")
FOR i := 1 TO SWX->(FCount())
    M->&(SWX->(FIELDNAME(i))) := SWX->(FieldGet(i))
NEXT

DbSelectArea("SWZ")
FOR i := 1 TO SWZ->(FCount())
    M->&(SWZ->(FIELDNAME(i))) := SWZ->(FieldGet(i))
NEXT

SWX->(E_InitVar())
aCampos:=ARRAY( SWX->(FCOUNT()) )

//PRIVATE aPos:= { 15,  1, 70, 315 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SWX")

DBSELECTAREA(nOldArea)
Return .T. 

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 22/01/07 - 11:21
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina := {  { STR0001   ,"AxPesqui"   , 0 , 1},; //"Pesquisar"
                    { STR0002   ,"OP100Visual", 0 , 2},; //"Visual"
                    { STR0003   ,"OP100Inclui", 0 , 3},; //"Inclui"
                    { STR0004   ,"OP100Altera", 0 , 4, },; //20 },; //"Altera"  // GFP - 07/11/2014 - Retirado trava de permissão de usuario
                    { STR0005   ,"OP100Deleta", 0 , 5, } } //21 } } //"Exclui"  // GFP - 07/11/2014 - Retirado trava de permissão de usuario
   
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("IOP100MNU")
	  aRotAdic := ExecBlock("IOP100MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OP100Visua³ Autor ³ AVERAGE-CRISTIANO    ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para visualizacao de C.F.O.                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void OP100Visual(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OP100Visual(cAlias,nReg,nOpc)

LOCAL oDlg, oGet, nMeio ,oEnch 

LOCAL cAlias1:="SWZ"

LOCAL cTit:= OemtoAnsi(STR0007)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nOpca:=0, cNomArq
PRIVATE aHeader[0]
PRIVATE bSWXWhile := {|| xFilial("SWZ") + SWX->WX_COD }

PRIVATE aPos:= { 15,  1, 70, 315 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

dbSelectArea(cAlias1)
dbSetOrder(1)

If !(cAlias1)->(dbSeek(xFilial()+SWX->WX_COD))
   Help(" ",1,"EICSEMIT")
   Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE bBrock:={||IF(EasyEntryPoint("EICPTA01"),ExecBlock("EICPTA01",.F.,.F.,{3,NIL}),.T.)}
                    
IF EasyEntryPoint("EICPTA01")
   EXECBLOCK("EICPTA01",.F.,.F.,{7,NIL},)
ENDIF

cSeek := xFilial("SWZ")+SWX->WX_COD
bRecSemX3 := {|| M->WZ_RECNO := SWZ->(Recno()), .T.}
bCond := {||.T.}
bAction1 := {|| SWZ->( WZ_FILIAL+WZ_CFO ) == xFilial("SWZ")+SWX->WX_COD }
bAction2 := {||.F.}
FillGetDB(nOpc, "SWZ", "TRB",,1, cSeek,  bSWXWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,/*ExcHeader(aYesHeader, "SWZ")*/,,,/*aCpoVirtual*/,{|a, b|  AddSemSx3(@b) },,bRecSemX3)
cNomArq := AvTrabName("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"WZ_OPERACA")

M->WZ_CFO := SWZ->WZ_CFO

IF(EasyEntryPoint("EICOP100"), EXECBLOCK("EICOP100",.F.,.F.,7),)

If IsVazio("TRB")
   Help(" ",1,"EA200SEMIT")
   TRB->(E_EraseArq(cNomArq,,,,.F.))
   Return .T.
Endif

While .T.

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTit ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

   nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
   aPos[3]:=nMeio-1 
   aPos[4]:=(oDlg:nClientWidth-2)/2 
   oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , , aPos, , 3 )//LRL 20/04/04

   dbSelectArea("TRB")
   TRB->(dbSetOrder(0))
   dbGoTop()
   TRB->(oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2,nOpc,"OP100LinOk","E_TudOk","",.F., , ,.T., ,"TRB"))
   oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
   
   oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT      
   oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()},{||oDlg:End()})) // Alinhamento MDI. // LRL 20/04/04    //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                              
   Exit
End

TRB->(E_EraseArq(cNomArq,,,,.F.))

dbSelectArea(cAlias)
Return( nOpca )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OP100Inclu ³ Autor ³ AVERAGE-CRISTIANO     ³ Data ³ 10.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para inclusao de C.F.O.                            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void OP100Inclui(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                    ³±±
±±³          ³ ExpN1 = Numero do registro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OP100Inclui(cAlias,nReg,nOpc)

LOCAL nOpca := 0,lGravaOk := .T.,i,nMeio
LOCAL cAlias1:="SWZ"//, aSemSX3:={ {"WZ_RECNO","N",05,0} }
LOCAL oDlg, oGet , oEnch
LOCAL bOK //JWJ - Botão OK - 04.05.09

LOCAL cTit:= OemtoAnsi(STR0007)
Local oPanel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE PAlteracao:=.F., aHeader[0], cNomArq
PRIVATE bSWXWhile := {|| xFilial("SWZ") + SWX->WX_COD }
PRIVATE aButtons := {}  // GFP - 19/05/2015
PRIVATE aPos:= { 15,  1, 70, 315 }

If Type("aRotina")<>"A" //LGS-26/11/2014
	aRotina := MenuDef()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
//aSemSX3:={ {"WZ_RECNO","N",05,0} }
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
NEXT i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho e indice                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF EasyEntryPoint("EICPTA01")
   EXECBLOCK("EICPTA01",.F.,.F.,{5,NIL},)
ENDIF

IF(EasyEntryPoint("EICOP100"), EXECBLOCK("EICOP100",.F.,.F.,5),)
cSeek := xFilial("SWZ")+SWX->WX_COD
bRecSemX3 := {|| If(nOpc == 3, M->WZ_RECNO := 0, M->WZ_RECNO := SWZ->(Recno())), .T.}
FillGetDB(nOpc, "SWZ", "TRB1",,1, cSeek,  bSWXWhile,,/*aNoFields*/,/*aYesFields*/,,,,/*ExcHeader(aYesHeader, "SWZ")*/,,,/*aCpoVirtual*/,{|a, b|  AddSemSx3(@b) },,bRecSemX3)

cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
//cNomArq := AvTrabName("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"WZ_OPERACA")
TERestBackup("TRB1")
TRB1->(dbCloseArea())

TRB->(avzap())

M->WX_COD:=SPACE(LEN(SWX->WX_COD))
M->WX_DESC:=SPACE(LEN(SWX->WX_DESC))
M->WX_CFOFILH:=SPACE(LEN(SWX->WX_CFOFILH))
M->WX_DSCCFOF:=SPACE(LEN(SWX->WX_DSCCFOF)) 

bOK := {|| IF(Obrigatorio(aGets,aTela), ;
			    ( nOpca:=1, If(oGet:TudoOk(), oDlg:End(),nOpca := 0) ), ;
			    ( nOpca := 0 ) ) }  //JWJ 04.05.09

aAdd(aButtons,{"NOTE",{|| OP100Wizard(oGet)  },"Wizard"})   // GFP - 19/05/2015
WHILE .T.
   
   nOpca := 0

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTit ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

   oPanel:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, aPos[4], aPos[3])
   oPanel:Align := CONTROL_ALIGN_ALLCLIENT
   
   nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
   aPos[3]:=nMeio-1 
   aPos[4]:=(oDlg:nClientWidth-2)/2 
   
   oEnCh:=MsMGet():New(cAlias, nReg, nOpc,,,,, aPos,,,,,,oPanel) //LRL 20/04/04 
   lTab := .T.
   dbSelectArea("TRB")
   TRB->(dbSetOrder(0))
   TRB->(oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2,nOpc,"OP100LinOk","E_TudOk","",.T.,,,.T.,,"TRB" ,,,,oPanel))
   oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
   
   oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT       
   oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
          
   oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bOK , {||nOpca:=2,oDlg:cCaption:="",oDlg:End()},,aButtons)) // LRL 20/04/04// Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                                 

   IF nOpcA == 2
      EXIT
   ENDIF

   If nOpcA == 1
      If !Obrigatorio(aGets,aTela)
         Loop
      Endif

      Begin Transaction
         lGravaOk := OP100Grava(cAlias,cAlias1)
         If !lGravaOk
            Help(" ",1,"A110NAORE")
         Else
            //Processa Gatilhos
            EvalTrigger()
            If __lSX8
               ConfirmSX8()
            Endif
         EndIf
      End Transaction
   ElseIf __lSX8
      RollBackSX8()
   Endif

   Exit
ENDDO

TRB->(E_EraseArq(cNomArq,,,,.F.))
dbSelectArea(cAlias)
Return( nOpcA )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OP100Alter³ Autor ³ AVERAGE-CRISTIANO     ³ Data ³ 13.07.98³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para alteracao de C.F.O.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void OP100Altera(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OP100Altera(cAlias,nReg,nOpc)

LOCAL bCampo,nOpca := 0,lGravaOk:=.T.
LOCAL cAlias1:="SWZ"
LOCAL oDlg, oGet, i ,oEnch
LOCAL bOK  //JWJ 04.05.09
Local oPanel

LOCAL cTit:= OemtoAnsi(STR0007)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nCampos // acb - 12/03/2010

PRIVATE PAlteracao:=.T., cNomArq   
PRIVATE aPos:= { 15,  1, 70, 315 }
PRIVATE aButtons := {}  // GFP - 19/05/2015
aTela := {}
aGets := {}

If ! Reclock("SWX",.F.) // VI 03/11/03
   Return .F.
EndIf

nRecno:=SWX->(RECNO())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aHeader[0]
PRIVATE bSWXWhile := {|| xFilial("SWZ") + SWX->WX_COD }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}


dbSelectArea(cAlias)
FOR i := 1 TO FCount()
        M->&(Field(i)) := FieldGet(i)
        nCampos++
NEXT i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    
IF EasyEntryPoint("EICPTA01")
   EXECBLOCK("EICPTA01",.F.,.F.,{6,NIL},)
ENDIF

cSeek := xFilial("SWZ")+SWX->WX_COD
bRecSemX3 := {|| M->WZ_RECNO := SWZ->(Recno()), .T.}
bCond := {||.T.}
bAction1 := {|| SWZ->( WZ_FILIAL+WZ_CFO ) == xFilial("SWZ")+SWX->WX_COD }
bAction2 := {||.F.}
FillGetDB(nOpc, "SWZ", "TRB1",,1, cSeek,  bSWXWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,/*ExcHeader(aYesHeader, "SWZ")*/,,,/*aCpoVirtual*/,{|a, b|  AddSemSx3(@b) },,bRecSemX3)

cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
//cNomArq := AvTrabName("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"WZ_OPERACA")
TERestBackup("TRB1")
TRB1->(dbCloseArea())

M->WX_COD:=SWX->WX_COD

IF(EasyEntryPoint("EICOP100"), EXECBLOCK("EICOP100",.F.,.F.,6),)

IF TRB->(Easyreccount("TRB")) == 0 
   Help(" ",1,"EA200SEMIT")
   TRB->(E_EraseArq(cNomArq,,,,.F.))
   dbSelectArea(cAlias)
   Return .T.
ENDIF

bOK := {|| IF(Obrigatorio(aGets,aTela), ;
			    ( nOpca:=1, If(oGet:TudoOk(), oDlg:End(),nOpca := 0) ), ;
			    ( Help( "", 1, "OP100JACAD" ) ) ) }  //JWJ 04.05.09
			    
aAdd(aButtons,{"NOTE",{|| OP100Wizard(oGet)  },"Wizard"})   // GFP - 19/05/2015

   nOpca := 0

   lTab := .T.
   oMainWnd:ReadClientCoors()
      
   DEFINE MSDIALOG oDlg TITLE cTit ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, aPos[4], aPos[3])
      oPanel:Align := CONTROL_ALIGN_ALLCLIENT
      
      nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
      aPos[3]:=nMeio-1 
      aPos[4]:=(oDlg:nClientWidth-2)/2 
      oEnCh:= MsMGet():New(cAlias, nReg, nOpc,,,,, aPos,, 3,,,, oPanel)//LRL 20/04/04

      dbSelectArea("TRB")
      TRB->(dbSetOrder(0))
      dbGoTop()
      SWX->(DBGOTO(nRecno))

      TRB->(oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2,nOpc,"OP100LinOk","E_TudOk","",.T.,,,.T.,,"TRB",,,, oPanel))
      oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
   
      oEnch:oBox:Align:=CONTROL_ALIGN_TOP        //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bOK ,{||oDlg:End()},,aButtons)) // LRL 20/04/04// Alinhamento MDI.  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                                

   If nOpcA == 1
      lGravaOk := OP100Grava(cAlias,cAlias1)
   Endif

TRB->(E_EraseArq(cNomArq,,,,.F.))
SWX->(MSUNLOCK())  // VI 03/11/03
dbSelectArea(cAlias)
Return( nOpca )
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OP100Delet³ Autor ³ AVERAGE-CRISTIANO     ³ Data ³13.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de exclusao de C.F.O.                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void OP100Deleta(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OP100Deleta(cAlias,nReg,nOpc)

LOCAL nOpca := 1, cAlias1:="SWZ"
LOCAL oDlg, oGet , oEnch
Local oPanel
LOCAL cTit:= OemtoAnsi(STR0007)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aHeader[0], cNomArq
PRIVATE bSWXWhile := {|| xFilial("SWZ") + SWX->WX_COD }

PRIVATE aPos:= { 15,  1, 70, 315 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aTela := {}
aGets := {} 

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE bBrock:={||IF(EasyEntryPoint("EICPTA01"),ExecBlock("EICPTA01",.F.,.F.,{3,NIL}),.T.)}
                    
IF EasyEntryPoint("EICPTA01")
   EXECBLOCK("EICPTA01",.F.,.F.,{8,NIL},)
ENDIF

cSeek := xFilial("SWZ")+SWX->WX_COD
bRecSemX3 := {|| M->WZ_RECNO := SWZ->(Recno()), .T.}
bCond := {||.T.}
bAction1 := {|| SWZ->( WZ_FILIAL+WZ_CFO ) == xFilial("SWZ")+SWX->WX_COD }
bAction2 := {||.F.}
FillGetDB(nOpc, "SWZ", "TRB",,1, cSeek,  bSWXWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,/*ExcHeader(aYesHeader, "SWZ")*/,,,/*aCpoVirtual*/,{|a, b|  AddSemSx3(@b) },,bRecSemX3)
cNomArq := AvTrabName("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"WZ_OPERACA")
M->WX_COD:=SWX->WX_COD

IF(EasyEntryPoint("EICOP100"), EXECBLOCK("EICOP100",.F.,.F.,8),)

If IsVazio("TRB")
   Help(" ",1,"EA200SEMIT")
   TRB->(E_EraseArq(cNomArq,,,,.F.))
   Return .T.
Endif

While .T.

   nOpca := 1
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTit ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, aPos[4], aPos[3])
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      nMeio:=INT(((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4)
      aPos[3]:=nMeio-1 
      aPos[4]:=(oDlg:nClientWidth-2)/2 
      oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , , aPos,, 3,,,, oPanel)//LRL 20/04/04

      dbSelectArea("TRB")
      TRB->(dbSetOrder(0))
      dbGoTop()
      TRB->(oGet:=MsGetDB():New(nMeio,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2,nOpc,"OP100LinOk","E_TudOk","",.F., , ,.T., ,"TRB",,,, oPanel))
      oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
   
      oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT        
      oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=2,oDlg:End()},;
                                                   {||nOpcA:=1,oDlg:End()})) // LRL 20/04/04 // Alinhamento MDI.  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                                
    IF nOpcA == 1
       Exit
    ELSEIF nOpcA == 2

        IF MSGYESNO(OemtoAnsi(STR0008),STR0009) # .T. //'Confirma a exclusÆo ? '###'Excluir'
           EXIT
        ENDIF

        Begin Transaction
        dbSelectArea( cAlias1 )
        ( cAlias1 )->(dbSeek(xFilial("SWZ")+SWX->WX_COD))
        nCnt := 0
        While !(cAlias1)->(Eof()) .And. xFilial("SWZ") = SWZ->WZ_FILIAL  .AND. ;
                                        SWZ->WZ_CFO = SWX->WX_COD 
            RecLock(cAlias1,.F.)
            dbDelete()
            MSUNLOCK()
            nCnt++
            (cAlias1)->(dbSkip())
        End

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Apaga o cabecalho: APE                              ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        dbSelectArea("SWX")
        RecLock("SWX",.F.)
        dbDelete()
        MSUNLOCK()

        dbSelectArea( cAlias1 )

        End Transaction
        Exit
        Endif
End

TRB->(E_EraseArq(cNomArq,,,,.F.))

dbSelectArea(cAlias)
Return( nOpca )

*----------------------*
Function OP100ValRed()
*----------------------*
LOCAL cCampo:=Subs(READVAR(),4)
LOCAL lMen:=.F.
LOCAL nTpCalcIcms := If(SWZ->(FieldPos("WZ_TP_CALC"))>0,.T.,.F.)

IF cCampo = "WZ_RED_ICM"
   lMen:=!EMPTY(M->WZ_RED_ICM) .AND. !EMPTY(TRB->WZ_RED_CTE)
ELSEIF cCampo = "WZ_RED_CTE"
   lMen:=!EMPTY(M->WZ_RED_CTE) .AND. !EMPTY(TRB->WZ_RED_ICM)
ENDIF

IF lMen .And. !nTpCalcIcms
   MSGINFO("Percentual de reducao de base e percentual de carga tributaria equivalente "+;
           "preenchidos, o percentual de reducao de base  sera utilizado no Sistema.")
ENDIF

RETURN .T.

*----------------------*
Function OP100LinOk(o)
*----------------------*
LOCAL nInd
Local lRet := .T.

PRIVATE aCampos:={{"WZ_CFO"    ,"CFO"     },;
                 {"WZ_OPERACA","OPERACAO" },;
                 {"WZ_DESC"   ,"DESC."    },;
                 {"WZ_AL_ICMS","AL_ICMS" },;
                 {"WZ_RED_ICM","RED_ICM" },;
                 {"WZ_MSG_IPI","MSG_IPI" },;
                 {"WZ_MSG_ICM","MSG_ICM" },;
                 {"WZ_CST"    ,"CST"     },;
                 {"WZ_COD_IPI","COD_IPI" },;
                 {"WZ_COD_ICM","COD_ICM" },;
                 {"WZ_TRI_ICM","TRI_ICM" },;
                  {"WZ_TRI_IPI","TRI_IPI" }}
                 
IF SWZ->(FIELDPOS("WZ_REC_PIS")) > 0       // JBS - 29/04/2004
   AADD(aCampos, {"WZ_REC_PIS","REC_PIS" })
ENDIF                 
                 
IF SWZ->(FIELDPOS("WZ_ICMS_PC")) > 0       // JBS - 03/05/2004
   AADD(aCampos, {"WZ_ICMS_PC","ICMS_PC" })
ENDIF                 

If SWZ->( FieldPos("WZ_ICMS_CP") > 0  .And.  FieldPos("WZ_ICMS_PD") > 0 )   // PLB 14/05/07 - Porcentagem a ser paga no Desembaraço
   AAdd( aCampos, { "WZ_ICMS_PD", "ICMS_PD" } )
EndIf

IF EasyEntryPoint("EICPTA01")
  EXECBLOCK("EICPTA01",.F.,.F.,{2,NIL},)
ENDIF

IF(EasyEntryPoint("EICOP100"), EXECBLOCK("EICOP100",.F.,.F.,2),)

// Fazer as consistencias especiais

IF TRB->WZ_FLAG
   RETURN lRet
ENDIF
FOR nInd:=1 TO LEN(aCampos)
    IF ! OP100Crit(aCampos[nInd,2],aCampos[nInd,1])
       lRet:=.F.
       EXIT
    ENDIF
NEXT

Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OP100Crit ³ Autor ³ AVERAGE-CRISTIANO    ³ Data ³ 13.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz as Valida‡oes necessarias aos campos da GETDADDB       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICOP100                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION OP100Crit(MFlag,cCampo)

*LOCAL SaveRec, SaveAPE:=' ', ValorFob, _MRecord, _Soma:= 0, _Tamanho, _Encontrou:= .F., uDado
LOCAL uDado

IF cCampo==NIL
   uDado:=&(READVAR())
   cCampo:=Subs(READVAR(),4)
ELSE
   uDado:=&cCampo
ENDIF

DO CASE
   CASE MFlag = 'OPERACA'
       IF ! OP100Valid("WZ_OPERACA","TRB")
          RETURN .F.
       ENDIF

   CASE MFlag = "AL_ICMS"
//       IF EMPTY(TRB->WZ_AL_ICMS)
//          Help("",1,"OP100NOICM")
//          RETURN .F.
//       ENDIF
      
   CASE MFlag = "RED_ICM"
//       IF EMPTY(TRB->WZ_RED_ICM)
//          Help("",1,"OP100NORED")
//          RETURN .F.
//      ENDIF
     
   Case MFlag == "ICMS_PD"
      If TRB->( WZ_ICMS_CP + WZ_ICMS_PD ) > TRB->WZ_AL_ICMS
         MsgInfo(STR0013)  //"A soma dos percentuais de Crédito Presumido e de ICMS a ser pago no Desembaraço não podem ultrapassar a Alíquota do ICMS."
         Return .F.
      EndIf
      
ENDCASE

RETURN .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OP100Grava³ Autor ³ AVERAGE-CRISTIANO     ³ Data ³ 13.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as informacoes nos arquivos SWX e SWZ.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICOP100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OP100Grava(cAlias,cAlias1)
LOCAL nX, nMaxArray, bCampo, nCntDel:=0, ny
LOCAL _DelIncAlt:= SPACE(01) , _MindDi

LOCAL xVar, BVar:={||.t.}
bCampo := {|nCPO| Field(nCPO) }


dbSelectArea("TRB")
TRB->(DBGOTOP())

lInc_Det:=.f.

WHILE ! TRB->(EOF())

    IF !EMPTY(TRB->WZ_RECNO)

       SWZ->(DBGOTO(TRB->WZ_RECNO))
       SWZ->(RecLock(cAlias1,.F.))

       IF TRB->WZ_FLAG
          SWZ->(DBDELETE())
          SWZ->(MSUNLOCK())
          TRB->(DBSKIP())
          LOOP
       ENDIF

       lInc_Det:=.t.

    ELSE

       IF TRB->WZ_FLAG
          TRB->(DBSKIP())
          LOOP
       ENDIF
       RecLock(cAlias1,.T.) // bloqueia e incluir registro vazio

    ENDIF

    For ny := 1 to Len(aHeader)
        xVar:=Trim(aHeader[ny][2])
        bVar:=FIELDWBLOCK(xVar,SELECT(cAlias1))
        If aHeader[ny][10] # "V" .AND. SWZ->(FieldPos(aHeader[ny][2])) > 0
           EVAL(bVar,EVAL(FIELDWBLOCK(xVar,SELECT("TRB"))))
        Endif
    Next ny


    IF EMPTY(TRB->WZ_RECNO)
       SWZ->WZ_FILIAL := xFilial("SWZ")
       SWZ->WZ_CFO    := M->WX_COD
    ENDIF

    lInc_Det:=.t.

    SWZ->(MSUNLOCK())
    TRB->(DBSKIP())
END

dbSelectArea(cAlias)
IF PAlteracao
   DBGOTO(nRecno)
ENDIF
IF lInc_Det
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Grava arquivo SWZ ( OP )                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   E_Grava(cAlias,!PAlteracao)
ELSE
   IF SWX->(DBSEEK(xFilial()+M->WX_COD))
      SWX->(RECLOCK("SWX",.f.))
      SWX->(DBDELETE())
   ENDIF
ENDIF
    

(cAlias)->(MsUnlock())

RETURN .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OP100GrTRB³ Autor ³ AVERAGE-CRISTIANO    ³ Data ³ 13.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as informacoes no arquivo TRB                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICOP100                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*STATIC FUNCTION OP100GrTRB(cLAlias,bSeek,bFor,bWhile)
PRIVATE cAlias:=cLAlias
(cAlias)->(EVAL(bSeek))
WHILE EVAL(bWhile)

  IF ! EVAL(bFor)
     (cAlias)->(DBSKIP())
     LOOP
  ENDIF

  TRB->(DBAPPEND())
  AVREPLACE(cAlias,"TRB")
  TRB->WZ_RECNO    :=(cAlias)->(RECNO())
  IF EasyEntryPoint("EICPTA01")
    EXECBLOCK("EICPTA01",.F.,.F.,{1,cAlias},)
  ENDIF
  IF(EasyEntryPoint("EICOP100"), EXECBLOCK("EICOP100",.F.,.F.,1),)
  (cAlias)->(DBSKIP())
END
RETURN .T.*/

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OP100Valid³ Autor ³ AVERAGE-CRISTIANO    ³ Data ³ 13.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencias de SWZ                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICOP100                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OP100Valid(MFlag,cAlias)
LOCAL Recno    := SWZ->(RECNO())
LOCAL RecnoTRB := TRB->(RECNO())
LOCAL uDado
IF cAlias == NIL
   uDado:=M->WZ_OPERACA
ELSE
   uDado:=(cAlias)->WZ_OPERACA
ENDIF
DO CASE
   CASE MFlag = 'WZ_OPERACA'

        IF EMPTY( uDado )
           Help( "",1,"OP100SEMOP" )
           RETURN .F.
        ENDIF
		//Valida se ja existe a operacao na TRB, para nao inserir item duplicado
        TRB->(DBSETORDER(1))
        TRB->(DBGOTOP())
        IF TRB->(DBSEEK(uDado))
           WHILE TRB->( !EOF() .AND. WZ_OPERACA = uDado )

              IF TRB->(RECNO()) = RecnoTRB
                 TRB->(DBSKIP())
                 LOOP
              ENDIF
              Help( "", 1, "OP100JACAD" )
              TRB->(DBSETORDER(0))
              TRB->(DBGOTOP())
              TRB->(DBGOTO(RecnoTRB))
              RETURN .F.
           ENDDO
        ENDIF

        TRB->(DBSETORDER(0))
        TRB->(DBGOTOP())
        TRB->(DBGOTO(RecnoTRB))

		//Valida se ja existe a operacao em algum outro cadastro de CFO.
		SWZ->(DBSETORDER(2))
        SWZ->(DBGOTOP())
        IF SWZ->(DBSEEK(xFilial()+uDado))
           WHILE SWZ->( !EOF() .AND. WZ_OPERACA = uDado ) .AND.;
                 xFilial("SWZ") = SWZ->WZ_FILIAL

              IF SWZ->(RECNO()) = TRB->WZ_RECNO
                 SWZ->(DBSKIP())
                 LOOP
              ENDIF
              Help( "", 1, "OP100JACAD" )
              SWZ->(DBSETORDER(1))
              SWZ->(DBGOTOP())
              SWZ->(DBGOTO(Recno))
              RETURN .F.
           ENDDO
        ENDIF

        SWZ->(DBSETORDER(1))
        SWZ->(DBGOTOP())
        SWZ->(DBGOTO(Recno))

   CASE MFlag = "WZ_AL_ICMS"
       IF EMPTY(M->WZ_AL_ICMS)
          Help("",1,"OP100NOICM")
          RETURN .F.
       ENDIF
      
   CASE MFlag = "WZ_RED_ICM"
       IF EMPTY(M->WZ_RED_ICM)
          Help("",1,"OP100NORED")
          RETURN .F.
       ENDIF

   CASE MFlag = "WZ_REC_PIS"  // JBS - 04/05/2004
       IF EMPTY(M->WZ_REC_PIS) .OR. !M->WZ_REC_PIS $ "SN"
          MSGINFO(STR0010,STR0011)
          RETURN .F.
       ENDIF
       
   Case MFlag = "WZ_ICMSDIF"  // PLB - 14/05/07
       If M->WZ_ICMSDIF > 100
          MsgInfo(STR0012,STR0011) // "O percentual deve ser no máximo 100."  "Atencao"
          Return .F.
       EndIf
       
       If M->WZ_ICMSDIF > 0 .And. SWZ->(FieldPos("WZ_TPPICMS")) # 0 .And. ( /*(!EMPTY(M->WZ_TPPICMS).And. M->WZ_TPPICMS # "3") .Or.*/ ( !EMPTY(TRB->WZ_TPPICMS).And. TRB->WZ_TPPICMS # "3") )  //NCF - 20/05/2011 - Validação do ICMS de Pauta         
          MsgStop(STR0015+CHR(13)+CHR(10)+STR0016+CHR(13)+CHR(10)+STR0017,"Aviso")
          Return  .F.                     
       EndIf

   Case MFlag = "WZ_ICMS_CP"  // PLB - 14/05/07
       If M->WZ_ICMS_CP > 100
          MsgInfo(STR0012,STR0011) // "O percentual deve ser no máximo 100."  "Atencao"
          Return .F.
       ElseIf M->WZ_ICMS_CP > TRB->WZ_AL_ICMS
          MsgInfo(STR0014,STR0011) // "O percentual não pode ultrapassar a Alíquota do ICMS."  "Atencao"
          Return .F.
       EndIf
       
       If M->WZ_ICMS_CP > 0 .And. SWZ->(FieldPos("WZ_TPPICMS")) # 0 .And. ( /*(!EMPTY(M->WZ_TPPICMS).And. M->WZ_TPPICMS # "3") .Or.*/ ( !EMPTY(TRB->WZ_TPPICMS).And. TRB->WZ_TPPICMS # "3") )  //NCF - 20/05/2011 - Validação do ICMS de Pauta    
          MsgStop(STR0015+CHR(13)+CHR(10)+STR0016+CHR(13)+CHR(10)+STR0017,"Aviso")
          Return  .F.                     
       EndIf

   Case MFlag = "WZ_ICMS_PD"  // PLB - 14/05/07
       If M->WZ_ICMS_PD > 100
          MsgInfo(STR0012,STR0011) // "O percentual deve ser no máximo 100."  "Atencao"
          Return .F.
       ElseIf M->WZ_ICMS_PD > TRB->WZ_AL_ICMS
          MsgInfo(STR0014,STR0011) // "O percentual não pode ultrapassar a Alíquota do ICMS."  "Atencao"
          Return .F.
       EndIf 
       
       If M->WZ_ICMS_PD > 0 .And. SWZ->(FieldPos("WZ_TPPICMS")) # 0 .And. ( /*(!EMPTY(M->WZ_TPPICMS).And. M->WZ_TPPICMS # "3") .Or.*/ ( !EMPTY(TRB->WZ_TPPICMS).And. TRB->WZ_TPPICMS # "3") )  //NCF - 20/05/2011 - Validação do ICMS de Pauta        
          MsgStop(STR0015+CHR(13)+CHR(10)+STR0016+CHR(13)+CHR(10)+STR0017,"Aviso")
          Return  .F.                     
       EndIf
       
   Case MFlag == "WZ_PCREPRE"
        
       If M->WZ_PCREPRE > 0 .And. SWZ->(FieldPos("WZ_TPPICMS")) # 0 .And. ( /*(!EMPTY(M->WZ_TPPICMS).And. M->WZ_TPPICMS # "3") .Or.*/ ( !EMPTY(TRB->WZ_TPPICMS).And. TRB->WZ_TPPICMS # "3") )  //NCF - 20/05/2011 - Validação do ICMS de Pauta        
          MsgStop(STR0015+CHR(13)+CHR(10)+STR0016+CHR(13)+CHR(10)+STR0017,"Aviso")
          Return  .F.                     
       EndIf
            
   Case MFlag == "WZ_ICMSUSP" 
   
       If M->WZ_ICMSUSP == "1" .And. SWZ->(FieldPos("WZ_TPPICMS")) # 0 .And. ( /*(!EMPTY(M->WZ_TPPICMS).And. M->WZ_TPPICMS # "3") .Or.*/ ( !EMPTY(TRB->WZ_TPPICMS).And. TRB->WZ_TPPICMS # "3") )  //NCF - 20/05/2011 - Validação do ICMS de Pauta         
          MsgStop(STR0015+CHR(13)+CHR(10)+STR0016+CHR(13)+CHR(10)+STR0017,"Aviso")
          Return  .F.                     
       EndIf

   Case MFlag == "WZ_TPPICMS"                                                                                //NCF - 20/05/2011 - Validação do ICMS de Pauta 
      
      IF(( SWZ->(FieldPos("WZ_ICMSDIF")) # 0 .And. (/*M->WZ_ICMSDIF > 0 .Or.*/ TRB->WZ_ICMSDIF > 0) ) .Or. ; 
         ( SWZ->(FieldPos("WZ_PCREPRE")) # 0 .And. (/*M->WZ_PCREPRE > 0 .Or.*/ TRB->WZ_PCREPRE > 0) ) .Or. ;
         ( SWZ->(FieldPos("WZ_ICMS_CP")) # 0 .And. (/*M->WZ_ICMS_CP > 0 .Or.*/ TRB->WZ_ICMS_CP > 0) ) .Or. ;
         ( SWZ->(FieldPos("WZ_ICMS_PD")) # 0 .And. (/*M->WZ_ICMS_PD > 0 .Or.*/ TRB->WZ_ICMS_PD > 0) ) .Or. ;
         ( SWZ->(FieldPos("WZ_ICMSUSP")) # 0 .And. (/*M->WZ_ICMSUSP == "1" .Or.*/ TRB->WZ_ICMSUSP == "1") ) ) .And. ;          
         ( SWZ->(FieldPos("WZ_TPPICMS")) # 0 .And. ( (!EMPTY(M->WZ_TPPICMS).And. M->WZ_TPPICMS # "3") .Or.;
         ( !EMPTY(TRB->WZ_TPPICMS).And. TRB->WZ_TPPICMS # "3") ) ) 
      
         MsgStop(STR0018+CHR(13)+CHR(10)+STR0019+CHR(13)+CHR(10)+STR0020+CHR(13)+CHR(10)+STR0021,"Aviso")
         Return  .F.        
      ENDIF
   
   Case MFlag == "WZ_TP_CALC"                                                                                //	LGS - 05/09/2014 - Validação do Tipo Calculo do ICMS
		If M->WZ_TP_CALC == "1"
		   If Empty(M->WZ_RED_CTE)
		      MsgInfo(STR0022,"")
		      Return .F.
		   EndIf
		ElseIf M->WZ_TP_CALC == "2"
		   If Empty(M->WZ_RED_ICM)
		      MsgInfo(STR0023,"")
		      Return .F.
		   EndIf
        ElseIf M->WZ_TP_CALC == "3"
		   If ( Empty(M->WZ_RED_CTE) .Or. Empty(M->WZ_RED_ICM) )
		      MsgInfo(STR0024,"")
		      Return .F.
		   EndIf
		EndIf
        
   Case MFlag == "WZ_ALFECP"
       If M->WZ_ALFECP > TRB->WZ_AL_ICMS
          MsgInfo(STR0014,STR0011) // "O percentual não pode ultrapassar a Alíquota do ICMS."  "Atencao"
          Return .F.
       EndIf

ENDCASE

lRet:=.T.

IF(EasyEntryPoint("EICOP100"),EXECBLOCK("EICOP100",.F.,.F.,4),)

If !(lRet := If(EasyEntryPoint("EICPTA01"),EXECBLOCK("EICPTA01",.F.,.F.,{4,TRB->(recno())},),.T.))
    RETURN .F.
Endif    
RETURN lRet

//TRP- 16/02/07 - Adiciona os campos de usuário no arquivo temporário
Static Function AddSemSx3(aSemSx3)
//Local bCpo  := {|cCpo| aAdd(aSemSx3, {cCpo, AvSx3(cCpo, AV_TIPO), AvSx3(cCpo, AV_TAMANHO), AvSx3(cCpo, AV_DECIMAL)}) }

   AAdd(aSemSx3, {"WZ_RECNO"  ,"N", 05, 0})
    
Return .T.


/*
Funcao     : OP100Wizard()
Parametros : Objeto de tela
Retorno    : NIL
Objetivos  : Wizard para calculo de Diferimento
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 19/05/2015 :: 08:11
*/
*-------------------------------*
Static Function OP100Wizard(o)
*-------------------------------*
Local aOrd := SaveOrd({"TRB"})
Local oWizard, oPanel
Local oAlICMS, oICMSDif, oAlRec
Private nAlRec := If(!Empty(M->WZ_ICMSDIF),M->WZ_AL_ICMS - M->WZ_ICMSDIF,0)
Private cAtuLogWiz := ""
Private aGets


DEFINE WIZARD oWizard	TITLE		STR0025;  //"Assistente de Aplicação de Diferimento"
							HEADER		STR0026;  //"Início"
							MESSAGE	STR0027;  //"Easy Import Control - Cadastro de C.F.O."
							TEXT		STR0028;  //"Este wizard tem como objetivo auxiliar na aplicação de diferimento do registro."
							PANEL		NEXT {|| .T. };
							FINISH		{|| .F.}


		CREATE PANEL oWizard HEADER 	STR0029	PANEL;  //"Aplicação de Diferimento"
								MESSAGE	STR0027;  //"Easy Import Control - Cadastro de C.F.O."
								BACK		{|| .F. };
								NEXT		{|| .T. };
								FINISH		{|| .T. };
								EXEC		{|| .T. }
			
			oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]

			
			@ 10, 10 Say  STR0030	Size oPanel:nClientHeight, oPanel:nClientWidth Pixel Of oPanel  //"Alíquota ICMS %:"
			@ 30, 10 Say  STR0031	Size oPanel:nClientHeight, oPanel:nClientWidth Pixel Of oPanel  //"Aliquota Diferida %:"
			@ 50, 10 Say 	STR0032	Size oPanel:nClientHeight, oPanel:nClientWidth Pixel Of oPanel  //"Aliquota a Recolher %:"

			@ 10, 68 MSGET oAlICMS	VAR M->WZ_AL_ICMS 	Picture AvSX3("WZ_AL_ICMS",AV_PICTURE) Size 65,8 VALID (Positivo()) RIGHT Pixel Of oPanel
			@ 30, 68 MSGET oICMSDif	VAR M->WZ_ICMSDIF	 	Picture AvSX3("WZ_ICMSDIF",AV_PICTURE) Size 65,8 VALID (Positivo() .AND. CalculaDif(1,@nAlRec)) RIGHT Pixel Of oPanel
			@ 50, 68 MSGET oAlRec	VAR nAlRec		 		Picture AvSX3("WZ_ICMSDIF",AV_PICTURE) Size 65,8 VALID (Positivo() .AND. CalculaDif(2,@nAlRec)) RIGHT Pixel Of oPanel


ACTIVATE WIZARD oWizard CENTERED VALID {|| CalculaDif(3,nAlRec) }

TRB->WZ_AL_ICMS := M->WZ_AL_ICMS
TRB->WZ_ICMSDIF := (M->WZ_ICMSDIF / TRB->WZ_AL_ICMS)*100  // GFP - 28/05/2015

o:oBrowse:Refresh()
RestOrd(aOrd,.T.)
Return NIL

/*
Funcao     : CalculaDif()
Parametros : Valores
Retorno    : .T./.F.
Objetivos  : Calculo de diferimento
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 19/05/2015 :: 10:00
*/
*----------------------------------------------------*
Static Function CalculaDif(nTipo,nAlRec)
*----------------------------------------------------*
Local lRet := .T.

If nTipo == 1 // Calculo de Aliquota a Recolher
   nAlRec := M->WZ_AL_ICMS - M->WZ_ICMSDIF
ElseIf nTipo == 2  // Calculo de Diferimento
   M->WZ_ICMSDIF := M->WZ_AL_ICMS - nAlRec
Else  // Validação de Calculos
   If M->WZ_AL_ICMS <> (M->WZ_ICMSDIF+nAlRec)
      MsgInfo(STR0033,STR0011)  //"O valor da aliquota de ICMS informado deve ser o mesmo da somatória dos valores de diferimento e aliquota a recolher informados." ## "Atenção"
      lRet := .F.
   EndIf
EndIf
Return lRet
*----------------------------------------------------------------------------*
*     FIM DO PROGRAMA EICOP100
*----------------------------------------------------------------------------*