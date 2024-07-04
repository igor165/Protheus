#INCLUDE "Eictc210.ch"
#include "AVERAGE.CH"
//#include "FiveWin.ch"
#DEFINE CONTEINER  "5"
#DEFINE PESO       "4"
#DEFINE QUANTIDADE "3"
#DEFINE PERCENTUAL "2"
#DEFINE VALOR      "1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTC210 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 10/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao da Tabela de Pre-Calculo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTC210
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL i:=1, nOldArea:=SELECT("SX3")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Incluir registros no Bancos de Dados                   ³
//³    4 - Alterar o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina := MenuDef()
//PRIVATE cDelFunc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0006) //"Tabela de Pre-Calculo"
PRIVATE cTitulo   := OemtoAnsi(STR0007) //"Manutencao Pre-Calculo"

PRIVATE aCampos:={}

Private aCamposWI := {}
PRIVATE bSeek :={||SWI->(DBSETORDER(2)),;
                   SWI->(DBSEEK(xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB)) }
PRIVATE bWhile:={||xFilial("SWI") = SWI->WI_FILIAL  .AND. ;
                   SWI->WI_VIA+SWI->WI_TAB == SWF->WF_VIA+SWF->WF_TAB} ,;
                   bFor:={||.T.}
//mfr                   
Private cSeek, bSWFWhile := {|| xFilial("SWI") + SWI->WI_VIA+SWI->WI_TAB }
PRIVATE lNaoAltera := .T.

Private aCamposWF := {} //LGS-28/07/2016
Private lMoedaWF  := If(EasyGParam("MV_EASYFPO",,"N") == "S" .Or. EasyGParam("MV_EASYFDI",,"N") == "S" ,.T.,.F.) //LGS-28/07/2016

SYE->(DBSETORDER(2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis com nome dos campos de Bancos de Dados        ³
//³ para serem usadas na funcao de inclusao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SWF")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
    If FIELDNAME(i) <> "WF_FILIAL" //LGS-28/07/2016
       aaDD(aCamposWF,FIELDNAME(i))
    EndIf
NEXT

If !lMoedaWF .And. SWF->(FieldPos("WF_IDMOEDA")) > 0 //LGS-28/07/2016
   If(nPos := AScan(aCamposWF,{ |x| x == "WF_IDMOEDA" })) > 0
      ADel(aCamposWF,nPos)
      ASize(aCamposWF,Len(aCamposWF)-1)
   EndIf
EndIf

DBSELECTAREA("SWI")
DBGOBOTTOM()
DBSKIP()
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT
SWI->(E_InitVar())

//CCH - 23/10/08 - Substituição do campo YB_DESCR para WI_IDVL para uso de ComboBox na tabela de pré-cálculo
//aCamposWI:={"WI_DESP","YB_DESCR","A1_NREDUZ","WI_MOEDA","WI_PERCAPL","WI_DESPBAS","WI_VALOR","WI_QTDDIAS","WI_VAL_MAX","WI_VAL_MIN"}
aCamposWI:={"WI_DESP","YB_DESCR","WI_IDVL","WI_MOEDA","WI_PERCAPL","WI_DESPBAS","WI_VALOR","WI_QTDDIAS","WI_VAL_MAX","WI_VAL_MIN"}

FOR I := 1 TO 6
   AADD(aCamposWI,"WI_KILO" +STR(I,1))
   AADD(aCamposWI,"WI_VALOR"+STR(I,1))
NEXT

//AADD(aCamposWI,"WI_IDVL")//Esse campo fica por ultimo porque sera deletado do aHeader 23/10/2008 - CCH - Não será deletado do aHeader

PRIVATE aPos:= { 15,  1, 50, 315 }

PRIVATE nLin:= 53

//ER - 24/04/2007
If EasyEntryPoint("EICTC210")
   ExecBlock("EICTC210",.F.,.F.,"ANTES_MBROWSE")
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SWF")

DBSELECTAREA(nOldArea)
SWI->(dbSetOrder(1))
Return .T.                  


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 26/01/07 - 15:58
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0001   ,"AxPesqui"   , 0 , 1},; //"Pesquisar"
                    { STR0002   ,"TC210Visual", 0 , 2},; //"Visualizar"
                    { STR0003   ,"TC210Inclui", 0 , 3},; //"Incluir"
                    { STR0004   ,"TC210Altera", 0 , 4, 20 },; //"Alterar"
                    { STR0005   ,"TC210Deleta", 0 , 5, 21 } } //"Excluir"
                   
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("ITC210MNU")
	aRotAdic := ExecBlock("ITC210MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TC210Visua³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para visualizacao de Detalhes do Pre-Calculo      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void TC210Visual(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TC210Visual(cAlias,nReg,nOpc)

LOCAL nOpca:=0,oDlg, oGet, cAlias1:="SWI", cNomArq
LOCAL oEnch,i
PRIVATE aTELA[0][0],aGETS[0]

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

PRIVATE aHeader[0]

dbSelectArea(cAlias1)
dbSetOrder(2)
(cAlias1)->( dbSeek(xFilial(cAlias1)+SWF->WF_VIA+SWF->WF_TAB) )
If EOF()
   Help(" ",1,"EICSEMIT")
   Return .T.
Endif

IF SELECT("TRB") <> 0
   TRB->(dbCloseArea())
   E_EraseArq(cNomArq,cNomArq)
ENDIF                
  
aYesHeader := CriaStruct()


aYesHeader := AddCpoUser(aYesHeader,"SWI","3")

cSeek := xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB
bRecSemX3 := {|| M->A1_NREDUZ:=TC210Tipo(SWI->WI_DESP,"SWI"), M->YB_DESCR:=SYB->YB_DESCR, M->RECNO := SWI->(Recno()), .T.}
bCond := {||.T.}
bAction1 := {|| SWI->( WI_FILIAL+WI_VIA+WI_TAB ) == xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB }
bAction2 := {||.F.}
FillGetDB(nOpc, "SWI", "TRB",,2, cSeek, bSWFWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,ExcHeader(aYesHeader, "SWI"),,,/*aCpoVirtual*/,{|a, b| AddHeader(@a), AddSemSx3(@b) }, , bRecSemX3)
cNomArq := AvTrabName("TRB")
dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"WI_DESP")

If IsVazio("TRB")
   Help(" ",1,"EA200SEMIT")
   TRB->(E_EraseArq(cNomArq))
   Return .T.
Endif


dbSelectArea(cAlias)
FOR i := 1 TO FCount()
    M->&(FIELDNAME(I)) := FieldGet(i)
NEXT i

nOpca := 0

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE cTitulo ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
aPos[3] := nMeio-1 
aPos[4] := (oDlg:nClientWidth-4)/2 

oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , aCamposWF, aPos,,, 3 ) //LRL 12/04/04 //LGS-28/07/2016
TRB->(DBSetOrder(0))   // ACSJ - Para o funcionamento correto da função MSGetDb na versão V811 não pode haver 
                       // Indice ativo no arquivo relacionado a função - 22/06/04 -------------------------//
   oGet:=MsGetDB():New(nMeio,;//01
                           1,;//02
    (oDlg:nClientHeight-6)/2,;//03
     (oDlg:nClientWidth-4)/2,;//04
                        nOpc,;//05
                "TC210LinOk",;//06
                   "E_TudOk",;//07
                          "",;//08
                         .T.,;//09
                  aYesHeader,;//10
                         NIL,;//11
                         .T.,;//12
                         NIL,;//13
                       "TRB",;//14
                         NIL,;//15
                         NIL,;//16
                         .F.,;//17 - Conforme o conversado com Juan Jose Pereira (MicroSiga) o 17o parametro //     deve ser .F. quando o arquivo de trablho é criado não-vazio.
                         NIL,;//18
                         NIL,;//19
                         NIL,;//20
     "TC210ValDBASE(TRB->WI_DESP,1)")//21
oGet:oBrowse:bWhen:={||oGet:oBrowse:Refresh(),dbSelectArea("TRB"),.T.}

oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,If(TC210TudOK().and.oGet:TudoOk(),oDlg:End(),nOpca := 0)},;
                                                {||nOpcA:=0,oDlg:End()})) //LRL 12/04/04 - Alinhamento MDI.    //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                                          




TRB->(dbCloseArea())
E_EraseArq(cNomArq)

dbSelectArea(cAlias)
Return( nOpca )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TC210Inclu³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para inclusao de Pre-Calculo            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void TC210Inclui(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*Caio César Henrique - 24/10/2008 
   Os comentários da função TC210Visual se aplicam para todas as outras funções do fonte (INCLUI, DELETA, ALTERA).   
   Mudança do campo YB_DESCR para WI_IDVL pois será utilizado ComboBox para seleção do Tipo de Despesa na Tabela de Pré-Cálculo
*/
Function TC210Inclui(cAlias,nReg,nOpc)
LOCAL nOpca := 0,I ,lGravaOk := .T.,cAlias1:="SWI",cNomArq
LOCAL aSemSx3:={ {"RECNO"  ,"N",7,0} }, oDlg,aAltera:={}
PRIVATE aTela[0][0],aGets[0],aHeader[0], oGet, oEnch
Private aButtons := {}
IncluiDespesa() // TDF

/*FOR i := 1 TO LEN(aCamposWI)
   M->&(aCamposWI[i]) := CRIAVAR(aCamposWI[i])
   IF !(aCamposWI[i] $ "YB_DESCR,A1_NREDUZ")
      AADD(aAltera,aCamposWI[i])
   ENDIF   
NEXT i*/

M->WF_TAB:=SPACE(04)
M->WF_VIA:=SPACE(02)
M->WF_DESC:=SPACE(40)
If lMoedaWF .And. SWF->(FieldPos("WF_IDMOEDA")) > 0 //LGS-28/07/2016
   M->WF_IDMOEDA := '1'
EndIf
IF(EasyEntryPoint("EICTC210"),ExecBlock("EICTC210",.F.,.F.,"TRATA_VAR"),)
   
aYesHeader:= CriaStruct() 

aYesHeader := AddCpoUser(aYesHeader,"SWI","3")

cSeek := xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB
bRecSemX3 := {|| M->A1_NREDUZ:=TC210Tipo(SWI->WI_DESP,"SWI"), M->YB_DESCR:=SYB->YB_DESCR, M->RECNO := SWI->(Recno()), .T.}
bCond := {||.T.}
bAction1 := {|| SWI->( WI_FILIAL+WI_VIA+WI_TAB ) == xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB }
bAction2 := {||.F.}
FillGetDB(nOpc, "SWI", "TRB1",,2, cSeek, bSWFWhile,,/*aNoFields*/,/*aYesFields*/,,,,ExcHeader(aYesHeader, "SWI"),,,/*aCpoVirtual*/,{|a, b| AddHeader(@a), AddSemSx3(@b) }, , bRecSemX3)

cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
//cNomArq := AvTrabName("TRB")
dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"WI_DESP")
TERestBackup("TRB1")
TRB1->(dbCloseArea())
nOpca := 0

IF ! TC210Desp(aYesHeader)
   Help(" ",1,"TC210SDESP")
   TRB->(E_EraseArq(cNomArq,cNomArq))
   dbSelectArea(cAlias)
   RETURN NIL
ENDIF

dbSelectArea("TRB")
TC210Del()

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE cTitulo ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
aPos[3] := nMeio-1 
aPos[4] := (oDlg:nClientWidth-4)/2 
oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , aCamposWF, aPos,,, 3 )//LRL 12/04/04 //LGS-28/07/2016
TRB->(DBSetOrder(0))   // ACSJ - Para o funcionamento correto da função MSGetDb na versão V811 não pode haver 
                       // Indice ativo no arquivo relacionado a função - 22/06/04 -------------------------//
TRB->(oGet:=MsGetDB():New(nMeio,;//01
                              1,;//02
       (oDlg:nClientHeight-6)/2,;//03
        (oDlg:nClientWidth-4)/2,;//04
                           nOpc,;//05
                   "TC210LinOk",;//06
                   "TC210TudOk",;//07
                             "",;//08
                            .T.,;//09
                     aYesHeader,;//10
                            NIL,;//11
                            .T.,;//12
                            NIL,;//13
                          "TRB",;//14
                            NIL,;//15
                            NIL,;//16
                            .F.,;//17 - Conforme o conversado com Juan Jose Pereira (MicroSiga) o 17o parametro //     deve ser .F. quando o arquivo de trablho é criado não-vazio.
                            NIL,;//18
                            NIL,;//19
                            NIL,;//20
     "TC210ValDBASE(TRB->WI_DESP,1)"))//21            

oGet:oBrowse:bWhen:={||oGet:oBrowse:Refresh(),dbSelectArea("TRB"),.T.}

oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Refresh()      //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,If(UnicoRegSWF().AND.TC210TudOk().and.Obrigatorio(aGets,aTela),oDlg:End(),nOpca := 0)},; //FSY - 10/09/2013 - Incluido a função UnicoRegSWF para empedir registro duplicado.
                                                {||nOpcA:=0,oDlg:End()},,aButtons)) //LRL 12/04/04 - Alinhamento MDI.      //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                                
If nOpcA == 1
   Begin Transaction
         lGravaOk := TC210Grava(cAlias,cAlias1)
         /*If !lGravaOk
            Help(" ",1,"TC210NAORE")
         Else
            EvalTrigger()
            If __lSX8
               ConfirmSX8()
            Endif
         EndIf */
   End Transaction
ElseIf __lSX8
    RollBackSX8()
Endif
TRB->(dbCloseArea())
E_EraseArq(cNomArq,cNomArq)
dbSelectArea(cAlias)
Return( nOpcA )

*----------------------------------------------------------------------------*
Function TC210Del()
*----------------------------------------------------------------------------*
TRB->(DBGOTOP())
WHILE ! TRB->(EOF())
  IF EMPTY(ALLTRIM(TRB->WI_DESP))
     TRB->(DBDELETE())
     TRB->(__DBPACK())
  ENDIF
  TRB->(DBSKIP())
END
TRB->(DBGOTOP())
RETURN NIL
*----------------------------------------------------------------------------*
Function TC210Desp()
*----------------------------------------------------------------------------*

LOCAL bBlock1,bBlock2,bBlock3,bBlock4,I //ACB - 24/02/2010  
LOCAL nInd/*, cDesp,*/, lRet:=.T.//ACB - 24/02/2010  
PRIVATE aDesp:={"MV_D_FOB","MV_D_FRETE","MV_D_SEGUR","MV_D_CIF","MV_D_II","MV_D_IPI","MV_D_ICMS","MV_D_PIS","MV_D_COFIN"}, cDesp//, lRet:=.T.//ACB - 24/02/2010  

If cModulo == "EEC" //Exportação
   aDesp := {"MV_D_FOB","MV_D_FRETE","MV_D_SEGUR"}
EndIf

IF !cPaisLoc="BRA"  // Somente para Versao Espanhol
   aDesp:={"MV_D_FOB","MV_D_FRETE","MV_D_SEGUR","MV_D_CIF"}
ENDIF
TRB->(avzap())

FOR nInd:=1 TO LEN(aDesp)

    cDesp:=EasyGParam(aDesp[nInd],,"")
    
	IF EMPTY(cDesp)
		If aDesp[nInd] == "MV_D_FOB" //ER - 17/10/2006 - A Despesa FOB, é obrigatória.
		   cDesp := "101"
		Else
		  LOOP
		EndIf
	ENDIF
    IF !SYB->(DBSEEK(xFilial("SYB")+cDesp))//(TRB->A1_NREDUZ:=TC210Tipo(cDesp)) == "*"
       MSGINFO("Despesa: "+cDesp+" nao encontrada no cadastro de despesas.")
       LOOP
//     lRet:=.F.
//     EXIT
    ENDIF
    TRB->(DBAPPEND())
    TRB->WI_DESP   :=cDesp
    TRB->YB_DESCR  :=SYB->YB_DESCR
    TRB->WI_MOEDA  :=SYB->YB_MOEDA
    TRB->WI_PERCAPL:=SYB->YB_PERCAPL
    TRB->WI_DESPBAS:=SYB->YB_DESPBAS
    TRB->WI_VALOR  :=SYB->YB_VALOR
    TRB->WI_QTDDIAS:=SYB->YB_QTDEDIA
    TRB->WI_VAL_MAX:=SYB->YB_VAL_MAX
    TRB->WI_VAL_MIN:=SYB->YB_VAL_MIN
    TRB->WI_IDVL   :=TC210Tipo(cDesp,"SYB")
    //TRB->A1_NREDUZ :=TC210Tipo(cDesp,"SYB")
    If SWI->(FieldPos("WI_CON20")) # 0 .AND. SWI->(FieldPos("WI_CON40")) # 0 .AND. SWI->(FieldPos("WI_CON40H")) # 0 .AND. SWI->(FieldPos("WI_CONOUT")) # 0
       TRB->WI_CON20  :=SYB->YB_CON20
       TRB->WI_CON40  :=SYB->YB_CON40
       TRB->WI_CON40H :=SYB->YB_CON40H
       TRB->WI_CONOUT :=SYB->YB_CONOUT
    EndIf
    IF SYB->YB_IDVL == "4"
       FOR I := 1 TO 6
           bBlock1:=FIELDWBLOCK("YB_KILO" +STR(I,1),SELECT("SYB"))
           bBlock2:=FIELDWBLOCK("YB_VALOR"+STR(I,1),SELECT("SYB"))
           bBlock3:=FIELDWBLOCK("WI_KILO" +STR(I,1),SELECT("TRB"))
           bBlock4:=FIELDWBLOCK("WI_VALOR"+STR(I,1),SELECT("TRB"))
           IF VALTYPE(bBlock1) = "B" .AND. VALTYPE(bBlock2) = "B" .AND.;
              VALTYPE(bBlock3) = "B" .AND. VALTYPE(bBlock4) = "B"
              EVAL(bBlock3,EVAL(bBlock1))
              EVAL(bBlock4,EVAL(bBlock2))
           ENDIF
       NEXT
    ENDIF                                                                               
NEXT                                                                                    

IF(EasyEntryPoint("EICTC210"),ExecBlock("EICTC210",.F.,.F.,"CAR_DESP"),) //ACB - 24/02/2010    

RETURN lRet

*----------------------------------------------------------------------------*
Function TC210Tipo(cDesp,cAlias)
*----------------------------------------------------------------------------*
//CCH - 23/10/08 - Retornos alterados para serem usados no ComboBox do campo WI_IDVL
Local cRetorno :=" " ,cTipo := "1"
IF ! SYB->(DBSEEK(xFilial("SYB")+cDesp))
   RETURN "*"
ENDIF
cAlias := IF(cAlias==nil,"SYB",cAlias)
cTipo := (cAlias)->&(SUBSTR(cALIAS,2,3)+"_IDVL")
DO CASE
  CASE cTipo == "1"
    //cRetorno := "Valor"
    cRetorno := "1" 
  CASE cTipo == "2"
    //cRetorno := "Percentual"
    cRetorno := "2" 
  CASE cTipo == "3"
    //cRetorno := "Quantidade"
    cRetorno := "3" 
  CASE cTipo == "4"
    //cRetorno := "Peso"
    cRetorno := "4"
  // SVG - 25/05/09 -
  OTHERWISE
     cRetorno := cTipo
ENDCASE  
RETURN cRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TC210Alter³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para alteracao de Pre-Calculo           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void TC210Altera(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TC210Altera(cAlias,nReg,nOpc)
LOCAL nRecnoWF:=SWF->(RECNO())
LOCAL nOpca := 0, lGravaOk := .T., i,aAltera:={}

/*LOCAL bGrava:={|nRec|TRB->RECNO:=nRec,TRB->A1_NREDUZ:=TC210Tipo(SWI->WI_DESP),;
                     TRB->YB_DESCR:=SYB->YB_DESCR,TRB->WI_IDVL:=SYB->YB_IDVL }*/

LOCAL bGrava:={|nRec|TRB->RECNO:=nRec,TRB->WI_IDVL:=TC210Tipo(SWI->WI_DESP,"SWI"),;
                     TRB->YB_DESCR:=SYB->YB_DESCR,TRB->WI_IDVL:=SWI->WI_IDVL}

LOCAL cAlias1:="SWI",cNomArq, oDlg //,oEnch FSY - 10/09/2013 - oEnch nopado
LOCAL aSemSx3:={ {"RECNO","N",7,0} }

PRIVATE aTela[0][0],aGets[0], oGet, aHeader[0],oEnch //FSY - 10/09/2013 - variavel oEnch como private.

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

aYesHeader:= CriaStruct()

aYesHeader := AddCpoUser(aYesHeader,"SWI","3")

cSeek := xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB
bRecSemX3 := {|| M->A1_NREDUZ:=TC210Tipo(SWI->WI_DESP,"SWI"), M->YB_DESCR:=SYB->YB_DESCR, M->RECNO := SWI->(Recno()), .T.}
bCond := {||.T.}
bAction1 := {|| SWI->( WI_FILIAL+WI_VIA+WI_TAB ) == xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB }
bAction2 := {||.F.}
FillGetDB(nOpc, "SWI", "TRB1",,2, cSeek, bSWFWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,ExcHeader(aYesHeader, "SWI"),,,/*aCpoVirtual*/,{|a, b| AddHeader(@a), AddSemSx3(@b) }, , bRecSemX3)

cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
//cNomArq := AvTrabName("TRB")
dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"WI_DESP")

TERestBackup("TRB1")
TRB1->(dbCloseArea())

If IsVazio("TRB")
   Help(" ",1,"EA200SEMIT")
   TRB->(E_EraseArq(cNomArq))
   Return .T.
Endif

dbSelectArea(cAlias)
FOR i := 1 TO FCount()
    M->&(FIELDNAME(I)) := FieldGet(i)
NEXT i

nOpca := 0

oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE cTitulo ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
aPos[3] := nMeio-1 
aPos[4] := (oDlg:nClientWidth-4)/2 

oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , aCamposWF, aPos,,, 3 ) //LRL 12/04/04 //LGS-28/07/2016
TRB->(DBSetOrder(0))   // ACSJ - Para o funcionamento correto da função MSGetDb na versão V811 não pode haver 
                       // Indice ativo no arquivo relacionado a função - 22/06/04 -------------------------//
   oGet:=MsGetDB():New(nMeio,;//01
                           1,;//02
    (oDlg:nClientHeight-6)/2,;//03
     (oDlg:nClientWidth-4)/2,;//04
                        nOpc,;//05
                "TC210LinOk",;//06
                   "E_TudOk",;//07
                          "",;//08
                         .T.,;//09
                  aYesHeader,;//10
                         NIL,;//11
                         .T.,;//12
                         NIL,;//13
                       "TRB",;//14
                         NIL,;//15
                         NIL,;//16
                         .F.,;//17 - Conforme o conversado com Juan Jose Pereira (MicroSiga) o 17o parametro //     deve ser .F. quando o arquivo de trablho é criado não-vazio.
                         NIL,;//18
                         NIL,;//19
                         NIL,;//20
     "TC210ValDBASE(TRB->WI_DESP,1)")//21
oGet:oBrowse:bWhen:={||oGet:oBrowse:Refresh(),dbSelectArea("TRB"),.T.}

oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=1,If(TC210TudOK().and.oGet:TudoOk(),oDlg:End(),nOpca := 0)},;
                                                {||nOpcA:=0,oDlg:End()})) //LRL 12/04/04 - Alinhamento MDI.        //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT                                      
If nOpcA == 1
   Begin Transaction
         SWF->(DBGOTO(nRecnoWF))
            lGravaOk := TC210Grava(cAlias,cAlias1)
            If !lGravaOk
                     Help(" ",1,"A110NAOREG")
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
TRB->(dbCloseArea())
E_EraseArq(cNomArq)
dbSelectArea(cAlias)
Return( nOpcA )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TC210Delet³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de exclusao de Orcamentos                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void TC210Deleta(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TC210Deleta(cAlias,nReg,nOpc)
LOCAL nOpca := 0

/*LOCAL bGrava:={|nRec|TRB->RECNO:=nRec,TRB->A1_NREDUZ:=TC210Tipo(SWI->WI_DESP,"SWI"),;
                     TRB->YB_DESCR:=SYB->YB_DESCR,TRB->WI_IDVL:=SWI->WI_IDVL }*/
                     
LOCAL bGrava:={|nRec|TRB->RECNO:=nRec,TRB->WI_IDVL:=TC210Tipo(SWI->WI_DESP,"SWI"),;
                     TRB->YB_DESCR:=SYB->YB_DESCR,TRB->WI_IDVL:=SWI->WI_IDVL}

LOCAL oDlg, aSemSx3:={{"RECNO"  ,"N",7,0}}, oEnch

LOCAL cAlias1:="SWI",cNomArq

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0], oGet

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
dbSelectArea(cAlias1)
dbSetOrder(2)
(cAlias1)->( dbSeek(xFilial(cAlias1)+SWF->WF_VIA+SWF->WF_TAB) )
If EOF()
   Help(" ",1,"EICSEMIT")
   Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                
aYesHeader:=  CriaStruct()

aYesHeader := AddCpoUser(aYesHeader,"SWI","3")

cSeek := xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB
bRecSemX3 := {|| M->A1_NREDUZ:=TC210Tipo(SWI->WI_DESP,"SWI"), M->YB_DESCR:=SYB->YB_DESCR, M->RECNO := SWI->(Recno()), .T.}
bCond := {||.T.}
bAction1 := {|| SWI->( WI_FILIAL+WI_VIA+WI_TAB ) == xFilial("SWI")+SWF->WF_VIA+SWF->WF_TAB }
bAction2 := {||.F.}
FillGetDB(nOpc, "SWI", "TRB",,2, cSeek, bSWFWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,ExcHeader(aYesHeader, "SWI"),,,/*aCpoVirtual*/,{|a, b| AddHeader(@a), AddSemSx3(@b) }, , bRecSemX3)
cNomArq := AvTrabName("TRB")
dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"WI_DESP")

DBGOTOP()

If IsVazio("TRB")
   Help(" ",1,"EA200SEMIT")
   TRB->(E_EraseArq(cNomArq))
   Return .T.
Endif

While .T.
   dbSelectArea("TRB")
   dbGoTop()

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTitulo ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
        	     OF oMainWnd PIXEL                          

   nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
	 aPos[3] := nMeio-1 
   aPos[4] := (oDlg:nClientWidth-4)/2 
   oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , aCamposWF, aPos, , 3 ) //LRL 12/04/04 //LGS-28/07/2016

   oGet:=MsGetDB():New(nMeio,;//01
                           1,;//02
    (oDlg:nClientHeight-6)/2,;//03
     (oDlg:nClientWidth-4)/2,;//04
                        nOpc,;//05
                "TC210LinOk",;//06
                   "E_TudOk",;//07
                          "",;//08
                         .T.,;//09
                         NIL,;//10
                         NIL,;//11
                         .T.,;//12
                         NIL,;//13
                       "TRB",;//14
                         NIL,;//15
                         NIL,;//16
                         .F.,;//17 - Conforme o conversado com Juan Jose Pereira (MicroSiga) o 17o parametro //     deve ser .F. quando o arquivo de trablho é criado não-vazio.
                         NIL,;//18
                         NIL,;//19
                         NIL,;//20
     "TC210ValDBASE(TRB->WI_DESP,1)")//21
   oGet:oBrowse:bWhen:={||oGet:oBrowse:Refresh(),dbSelectArea("TRB"),.T.}
   
   
  oEnCh:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
  oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
  oGet:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
    

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcA:=2,IF(TC210TudOK() .and. VldDelTab(),oDlg:End(),(nOpcA:=1,oDlg:End()))},;
                                                   {||nOpcA:=1,oDlg:End()})) //LRL 12/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF nOpcA == 1
      Exit
   ELSEIF nOpcA == 2

    Begin Transaction
          dbselectarea("TRB")
          dbGotop()
          nCnt := 0
          While !TRB->(Eof())
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Apagar Itens da Cotacao                             ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             SWI->(DBGOTO(TRB->RECNO))
             RecLock("SWI",.F.)
             SWI->(dbDelete())
             SWI->(MSUNLOCK())
//             nCnt++
             TRB->(dbSkip())
          End

          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³ Apaga o cabecalho: Pre-Calculo                      ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          dbSelectArea("SWF")
          RecLock("SWF",.F.)
          dbDelete()
          MSUNLOCK()

    End Transaction
    Exit
  Endif
End
TRB->(dbCloseArea())
E_EraseArq(cNomArq,cNomArq)
dbSelectArea(cAlias)
Return( nOpca )

static function VldDelTab()
   local lRet      := .F.
   local aTabelas  := {}

   aAdd( aTabelas, { "SW2" , {} })
   aAdd( aTabelas, { "SW6" , {} })
   aAdd( aTabelas, { "EE7" , {} })
   aAdd( aTabelas, { "EXL" , {} })
   lRet := EasyVldSX9( "SWF" , aTabelas )

return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TC210TudOk³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 20.10.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas da S.I.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = TC210TudOk                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function TC210TudOK(o)
LOCAL nRecno:=TRB->(RECNO())
Local cCodFOB := EasyGParam("MV_D_FOB",,"101") //ER - 17/10/2006
Private lRet:=.T.  // GFP - 16/08/2012

//Caso o parametro esteja em branco, carrega como padrão o código "101"
If Empty(cCodFOB)
   cCodFOB := "101"
EndIf

TRB->(DBGOTOP())
WHILE ! TRB->(EOF())
  IF TRB->WI_FLAG
     //IF TRB->WI_DESP == EasyGParam("MV_D_FOB") 
     IF TRB->WI_DESP == cCodFOB //ER - 17/10/2006
        MsgInfo(STR0022) //LRL 22/01/04 Help(" ",1,"TC210NDEL")
        lRet:=.F.
        EXIT
     ENDIF
     TRB->(DBSKIP()) ; LOOP
  ENDIF
  IF EMPTY(ALLTRIM(TRB->WI_DESP))
     TRB->(DBDELETE())
     TRB->(DBSKIP()) ; LOOP     
  ENDIF
  IF EMPTY(TRB->WI_MOEDA)
     HELP("",1,"AVG0000556") //"Moeda Não Preenchida"
     lRet:=.F.
     EXIT
  ENDIF
  //DbSkip()    // mjb1297
  TRB->( DBSkip() )  // PLB 27/03/07
END

If(EasyEntryPoint("EICTC210"),Execblock("EICTC210",.F.,.F.,"FINAL_TUDOK"),)  // GFP - 16/08/2012

TRB->(DBGOTO(nRecno))
RETURN lRet




/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TC210Grava³ Autor ³ PADRAO GETDADDB       ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as nformacoes nos arquivos SZ1 e SW2.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICTC210                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TC210Grava(cAlias,cAlias1)
LOCAL nX, nMaxArray, bCampo, nCntDel:=0

LOCAL xVar, BVar:={||.t.}
//bCampo := {|nCPO| Field(nCPO) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de itens                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SWF ( Tabela de Pre-Calculo  )                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

E_Grava(cAlias,inclui)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SWI (Itens do Pre-Calculo)                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
TRB->(DBGOTOP())

WHILE ! TRB->(EOF())

    IF TRB->WI_FLAG
       IF TRB->RECNO == 0
          TRB->(DBSKIP())
          LOOP
       ENDIF
       SWI->(DBGOTO(TRB->RECNO))
       RecLock(cAlias1,.F.)
       SWI->(DBDELETE())
       SWI->(MSUNLOCK())

       TRB->(DBSKIP())
       LOOP
    ENDIF

    IF Inclui
       RecLock(cAlias1,.T.)
    ELSE
       IF TRB->RECNO <> 0              // Alteracao
          SWI->(DBGOTO(TRB->RECNO))
          RecLock(cAlias1,.F.)
       ELSE
          RecLock(cAlias1,.T.)
       ENDIF
    ENDIF

    AVReplace("TRB","SWI")

    SWI->WI_FILIAL  := xFilial("SWI")
    SWI->WI_TAB     := M->WF_TAB
    SWI->WI_VIA     := M->WF_VIA
    SWI->WI_DESC    := M->WF_DESC

/*  SWI->WI_MOEDA   := TRB->WI_MOEDA
    SWI->WI_DESP    := TRB->WI_DESP
    SWI->WI_PERCAPL := TRB->WI_PERCAPL
    SWI->WI_DESPBAS := TRB->WI_DESPBAS
    SWI->WI_VALOR   := TRB->WI_VALOR
    SWI->WI_QTDDIAS := TRB->WI_QTDDIAS
    SWI->WI_VAL_MAX := TRB->WI_VAL_MAX
    SWI->WI_VAL_MIN := TRB->WI_VAL_MIN
    SWI->WI_IDVL    := TRB->WI_IDVL*/

    SWI->(MsUnlock())
    TRB->(DBSKIP())
End
Return( .T. )

*-----------------------------------*
Function TC210DespBase(cDesp,lLinOk)
*-----------------------------------*
IF TRB->WI_DESP == EasyGParam("MV_D_FOB") .AND. lLinOk == NIL   // Despesa 101
   MsgInfo(STR0023) //LRL 22/01/04 Help(" ",1,"TC210NALT")
   RETURN .F.
ENDIF
IF !TC210ValDBASE(M->WI_DESPBAS,2) //LRS - 14/05/2018
   RETURN .F.
EndIF
RETURN EA110DespBase(cDesp)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TC210LinOk³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas do Orcamento. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = TC210LinOk                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function TC210LinOk(o)
Local lRet := .T., i, Ind 
Local nRec
Local nOldOrd

/*LOCAL aCamposWI:={ {"WI_DESP"    ,"WI_DESP"    } ,;
                   {"WI_MOEDA"   ,"WI_MOEDA"   } ,;
                   {"WI_PERCAPL" ,"WI_PERCAPL" } ,;
                   {"WI_DESPBAS" ,"WI_DESPBAS" } ,;
                   {"WI_VALOR"   ,"WI_VALOR"   } ,;
                   {"WI_VAL_MAX" ,"WI_VAL_MAX" } ,;
                   {"WI_VAL_MIN" ,"WI_VAL_MIN" } }
//                  {"WI_QTD"     ,"WI_QTD"     } ,; AWR 7/8/98*/

// Fazer as consistencias especiais

IF TRB->WI_FLAG
   RETURN lRet
ENDIF

DBSelectArea("TRB")  // PLB 27/03/07
FOR i := 1 TO FCOUNT()
   M->&(FIELDNAME(I)) := FIELDGET(i)
NEXT i

FOR Ind :=1 TO SWI->(FCOUNT())//LEN(aCamposWI)
    IF TRB->WI_DESP == "101" //CCH - 23/10/08 - Impede apenas a alteração da despesa 101 FOB
       EXIT
    ENDIF

    Private lUserValid := NIL
    
    IF EasyEntryPoint("EICTC210")//FSY - 18/09/2013 - ponto de entrada para customizar a validação do campo.
       ExecBlock("EICTC210",.F.,.F.,"VAL_CUSTOMIZA")
    ENDIF
    
    IF ValType(lUserValid) == "U" .AND. !TC210VAL(FIELDNAME(Ind)) .OR. ValType(lUserValid) == "L" .AND. !lUserValid//FSY - 18/09/2013 - ajustes para o ponto de entrada.
       lRet:=.F.
       EXIT
    ENDIF
NEXT
//ENDIF

//TRP-17/12/07
If lRet
   nRec := TRB->(RecNo())
   nOldOrd:=TRB->(IndexOrd())        
   lRet := Valida_Desp(TRB->WI_DESP)
   TRB->(dbSetOrder(nOldOrd))
   TRB->(dbGoTo(nRec))
EndIf
oGet:oBrowse:Refresh()
Return( lRet )

*---------------------------------*
Function TC210Val(cCampo)
*---------------------------------*
LOCAL nRecno, lExiste, lProcessa, uDado, i

IF cCampo==NIL
   uDado:=&(READVAR())
   cCampo:=Subs(READVAR(),4)
ELSE
   uDado:=TRB->(FIELDGET(FIELDPOS(cCampo)))
ENDIF

DO CASE
   CASE cCampo == "WI_DESP"
        RETURN TC210GET(uDado,.T.)

   CASE cCampo == "WI_IDVL"
        RETURN TC210Valid(cCampo,.T.)     

   CASE cCampo == "WI_MOEDA"
        M->WI_MOEDA:=uDado
        RETURN TC210Valid(cCampo,.T.) .AND. TC210ValMoeda(uDado,.T.,cCampo)

   CASE cCampo == "WI_PERCAPL"
        M->WI_PERCAPL:=uDado
        RETURN TC210Valid(cCampo,.T.)

   CASE cCampo == "WI_DESPBAS"
        RETURN EA110DespBase(uDado)

   CASE cCampo == "WI_VALOR" .AND. M->WI_IDVL # "4"
        M->WI_VALOR:=uDado
        RETURN TC210Valid(cCampo,.T.)

   CASE cCampo == "WI_VAL_MAX"
        M->WI_VAL_MAX:=uDado
        RETURN TC210Valid(cCampo,.T.)

   CASE cCampo == "WI_VAL_MIN"
        M->WI_VAL_MIN:=uDado
        RETURN TC210Valid(cCampo,.T.)

ENDCASE

If M->WI_IDVL == "4"// \\\\////AWR 23/10/1999

   FOR I := 1 TO 6
       bBlock1:=MEMVARBLOCK( "WI_KILO" +STR(I,1) )
       bBlock2:=MEMVARBLOCK( "WI_VALOR"+STR(I,1) )
       IF VALTYPE(bBlock1) = "B" .AND. VALTYPE(bBlock2) = "B"
          IF !Empty( EVAL(bBlock1) ) .OR. !Empty( EVAL(bBlock1) )
             EXIT
          ENDIF
       ENDIF
   NEXT

   IF I == 7
      HELP("",1,"AVG0000559") //"NÆo h  Pesos e Valores p/ Kg informados"
      oGet:oBrowse:Refresh()
      //oGet:oBrowse:Reset()
      Return .F.
   ENDIF

   FOR I := 1 TO 6
       bBlock1:=MEMVARBLOCK( "WI_KILO" +STR(I,1) )
       bBlock2:=MEMVARBLOCK( "WI_VALOR"+STR(I,1) )
       IF VALTYPE(bBlock1) = "B" .AND. VALTYPE(bBlock2) = "B"
          IF (!Empty( EVAL(bBlock1) ) .AND.  Empty( EVAL(bBlock2) )) .OR.;
             ( Empty( EVAL(bBlock1) ) .AND. !Empty( EVAL(bBlock2) ))
             HELP("",1,"AVG0000561",,STR(I,1),1,36)////"Nao esta correta a faixa de peso "###" 
                oGet:oBrowse:Refresh()
                //oGet:oBrowse:Reset()
             Return .F.
             EXIT
          ENDIF
       ENDIF
   NEXT

   FOR I := 2 TO 6
       bBlock1:=MEMVARBLOCK( "WI_KILO" +STR(I-1,1) )
       bBlock2:=MEMVARBLOCK( "WI_KILO" +STR(I  ,1) )
       IF VALTYPE(bBlock1) = "B" .AND. VALTYPE(bBlock2) = "B"
          IF !EMPTY( EVAL(bBlock2) )
             IF IF(I=6,EVAL(bBlock2) < EVAL(bBlock1),EVAL(bBlock2) <= EVAL(bBlock1))
                HELP("",1,"AVG0000562",,STR(I,1)+STR0015+STR(I-1,1),1,06)//"Kilo "###" menor ou igual que o Kilo "###"
                oGet:oBrowse:Refresh()
                //oGet:oBrowse:Reset()
                Return .F.
             ENDIF
          ENDIF
       ENDIF
    NEXT

Endif

RETURN .T.

//FSY - 10/09/2013 - Removido a antiga condição(Via transp. obrigatorio), pois foi adicionado o calculo com % frete fixo no pre-calculo.
//Valide foi ajustada para que as ações sejam feita no momento correto possibilitando que edite o campo "Via transp."
*---------------------*
Function TC210ValVia()//Usado pelo campo WF_VIA na rotina de tabela pre-calculo EIC
*---------------------*
Local lRet  := .T.
Local aOrd  := SaveOrd({"SWF","SYQ"})//Necessario para que o seek funcione corretamente.
SWF->(DBSETORDER(2))
SYQ->(DBSETORDER(1))

Begin sequence

IF !SYQ->(DbSeek(xFilial("SYQ")+M->WF_VIA)) 
   If !Empty(M->WF_VIA)
      HELP("",1,"AVG0000565") //"Via de Transporte não cadastrada"
      lRet:= .F. 
      Break
   End If
End If    

If oGet:nOpc == 4 .And. ! ( AvKey(M->WF_TAB,"WF_TAB") == SWF->WF_TAB .AND. AvKey(M->WF_VIA,"WF_VIA") == SWF->WF_VIA) 
      
   lRet := MsgYesno(STR0024, STR0025)//"Deseja realmente alterar o campo de 'via trans.'? O(s) registro(s) que utilizam está tabela de Pre-Calculo perderão a referência para o calculo.", "Aviso"
   If !lRet
      M->WF_VIA := SWF->WF_VIA 
   End If
     
End If

If oGet:nOpc == 4 .And.( AvKey(M->WF_TAB,"WF_TAB") == SWF->WF_TAB .AND. AvKey(M->WF_VIA,"WF_VIA") == SWF->WF_VIA)//Permitir que volte ao valor antigo antes de gravar.
   Break
End If 

IF SWF->(DBSEEK(xFilial("SWF")+M->WF_VIA+M->WF_TAB)) 
   Help(" ",1,"JAGRAVADO") //"Já existe registro com esta infomação"
   lRet:= .F.
End If
            
End sequence

RestOrd(aOrd, .T.)
oEnch:Refresh()

RETURN lRet
////FSY - 10/09/2013

*--------------------------------------------------------------*
Function TC210GET(Campo,lLinOk)
*--------------------------------------------------------------*
LOCAL bBlock1,bBlock2,bBlock3,bBlock4
LOCAL nRec:=TRB->(RECNO()), i

IF TRB->WI_DESP == EasyGParam("MV_D_FOB") .AND. lLinOk == NIL   // Despesa 101
   MsgInfo(STR0023) //LRL 22/01/04 Help(" ",1,"TC210NALT")
   RETURN .F.
ENDIF

IF ! SYB->(DbSeek(xFilial("SYB")+Campo))
   HELP("",1,"AVG0000569",,Campo+STR0020,1,11) //"Despesa "###" nao cadastrada"
   RETURN .F.
ENDIF

IF TRB->(Easyreccount("TRB")) > 1 
   // ACSJ - Para o funcionamento correto da função MSGetDb na versão V811 não pode haver indice ativo no arquivo 
   // relacionado a função - Por este motivo o indice é ativado antes do seek e desativado logo apos - 22/06/04 /
   TRB->(DBSetOrder(1))
   lSeek := TRB->(DBSEEK(Campo))
   TRB->(DBSetOrder(0))
   // ACSJ - 22/06/04  -------------------------------------------------------------------------------------- //
   IF  lSeek .AND. nRec <> TRB->(RECNO())
      TRB->(DBGOTO(nRec))
      Help(" ",1,"JAGRAVADO")
      RETURN .F.
   ENDIF
   TRB->(DBGOTO(nRec))
ENDIF

//If (Empty(TRB->A1_NREDUZ) .OR. M->WI_DESP # TRB->WI_DESP) .AND. lLinOk == NIL
If (Empty(M->WI_IDVL) .OR. M->WI_DESP # TRB->WI_DESP) .AND. lLinOk == NIL
   //TRB->A1_NREDUZ:=TC210Tipo(M->WI_DESP)
   TRB->YB_DESCR  :=SYB->YB_DESCR
   TRB->WI_MOEDA  :=SYB->YB_MOEDA
   TRB->WI_PERCAPL:=SYB->YB_PERCAPL
   TRB->WI_DESPBAS:=SYB->YB_DESPBAS
   TRB->WI_VALOR  :=SYB->YB_VALOR
   TRB->WI_QTDDIAS:=SYB->YB_QTDEDIA
   TRB->WI_VAL_MAX:=SYB->YB_VAL_MAX
   TRB->WI_VAL_MIN:=SYB->YB_VAL_MIN
   TRB->WI_IDVL   :=TC210Tipo(M->WI_DESP,"SYB")
   //TRB->WI_IDVL   :=SYB->YB_IDVL
    If SWI->(FieldPos("WI_CON20")) # 0 .AND. SWI->(FieldPos("WI_CON40")) # 0 .AND. SWI->(FieldPos("WI_CON40H")) # 0 .AND. SWI->(FieldPos("WI_CONOUT")) # 0
       TRB->WI_CON20  :=SYB->YB_CON20
       TRB->WI_CON40  :=SYB->YB_CON40
       TRB->WI_CON40H :=SYB->YB_CON40H
       TRB->WI_CONOUT :=SYB->YB_CONOUT
    EndIf
   IF TRB->WI_IDVL = "4"
       FOR I := 1 TO 6
           bBlock1:=FIELDWBLOCK("YB_KILO" +STR(I,1),SELECT("SYB"))
           bBlock2:=FIELDWBLOCK("YB_VALOR"+STR(I,1),SELECT("SYB"))
           bBlock3:=FIELDWBLOCK("WI_KILO" +STR(I,1),SELECT("TRB"))
           bBlock4:=FIELDWBLOCK("WI_VALOR"+STR(I,1),SELECT("TRB"))
		         IF VALTYPE(bBlock1) = "B" .AND. VALTYPE(bBlock2) = "B" .AND.;
              VALTYPE(bBlock3) = "B" .AND. VALTYPE(bBlock4) = "B"
              EVAL(bBlock3,EVAL(bBlock1))
              EVAL(bBlock4,EVAL(bBlock2))
           ENDIF
       NEXT
    ENDIF

Endif


oGet:oBrowse:Refresh()
//oGet:oBrowse:Reset()

RETURN .T.
//TRP- 16/02/07 - Adiciona os campos de usuário no arquivo temporário
Static Function AddSemSx3(aSemSx3)
Local bCpo  := {|cCpo| aAdd(aSemSx3, {cCpo, AvSx3(cCpo, AV_TIPO), AvSx3(cCpo, AV_TAMANHO), AvSx3(cCpo, AV_DECIMAL)}) }
Local aCpos := {"YB_DESCR", "A1_NREDUZ"}

    AEval(aCpos, {|a| Eval(bCpo, a) })
    AAdd(aSemSx3, {"RECNO"  ,"N", 7, 0})
    
Return .T.

//TRP- 16/02/07 - Adiciona campos de usuário no Header
Static Function AddHeader(aHeader)
Local ni  := 1
Local aCpos := { {"YB_DESCR","WI_DESP"} }

   SX3->(dBsetorder(2))
   For ni := 1 to Len(aCpos)
      SX3->( DbSeek(aCpos[ni][1]) )
      nPos := 1 + AScan( aHeader, {|x| AllTrim(x[2]) == AllTrim(aCpos[ni][2])} )
      AAdd( aHeader, Nil )
      AIns( aHeader, nPos )
      aHeader[nPos] := {Rtrim( SX3->(X3Titulo())),Rtrim( SX3->X3_CAMPO ),SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,"TRB",SX3->X3_CONTEXT}
   Next ni  

Return .T.

//TRP-17/12/07- Valida linha de cada despesa para que não haja recursividade.
*--------------------------------------------------------------*
Static Function Valida_Desp(cDespesa,cCampo,aControle)
*--------------------------------------------------------------*
Local lRet:= .T. 
Local x
Local aDespBase:={}
DEFAULT aControle := {}

TRB->(DBSetOrder(1))
TRB->(DBSEEK(cDespesa))

DEFAULT cCampo:=TRB->WI_DESPBAS
                                                    
If !Empty(SUBS(cCampo,1,3))
   Aadd(aDespBase,SUBS(cCampo,1,3))
Endif

If !Empty(SUBS(cCampo,4,6))
   Aadd(aDespBase,SUBS(cCampo,4,6))
Endif   
   
If !Empty(SUBS(cCampo,7,9))
   Aadd(aDespBase,SUBS(cCampo,7,9))
Endif

Aadd(aControle,cDespesa)

For x:=1 to Len(aDespBase) 

   If Ascan(aControle,aDespBase[x]) > 0
      MsgStop("Não é possível calcular a despesa pois há uma referência circular na montagem das despesas base!")
      lRet:= .F.
      Exit
   Endif   
   If !Valida_Desp(aDespBase[x],,aControle)
      lRet:= .F.
      Exit
   Endif

Next

If (nPos:=Ascan(aControle,cDespesa)) > 0
   aDel(aControle,nPos)
   aSize(aControle,Len(aControle)-1)
Endif

Return lRet   

/*
Função          : CriaStruct()
Objetivo        : Criação do array com os campos que irao compor as colunas apresentadas na rotina "Tabela Pre-calculo"
Parâmetros      : Nenhum
Retorno         : Array com os campos que serão apresentados nas rotinas do aRotinas do MBrownser ("Tabela Pre-calculo").
Autor           : Ivo Santana Santos
Data/Hora       : 23/02/10
Obs.            : Criação desta rotina devido ao chamado : 080814, para o melhor funcionamento do ponto de entrada EICTC210 com o
                  parâmetro "MONTA_CAMPOS".
*/

*==============================================================*
Static Function CriaStruct()
*==============================================================*

Private aStruct                                     

//19.mai.2009 - 710059 - Tratamento para não aparecer QtdDias no EEC - HFD
   If nModulo == 29 //Módulo EEC

      aStruct:= { "WI_DESP" ,;
                  "WI_MOEDA" ,; 
                  "WI_PERCAPL" ,;  
                  "WI_IDVL" ,; 
                  "WI_DESPBAS" ,;
                  "WI_VALOR" ,;
                  "WI_QTDDIAS",; 
                  "WI_VAL_MAX",;
                  "WI_VAL_MIN",;
                  "WI_KILO1",;
                  "WI_VALOR1",;
                  "WI_KILO2",;
                  "WI_VALOR2",;
                  "WI_KILO3",;
                  "WI_VALOR3",;
                  "WI_KILO4",;
                  "WI_VALOR4",;
                  "WI_KILO5",;
                  "WI_VALOR5",;
                  "WI_KILO6",;
                  "WI_VALOR6"}
   Else    

      aStruct:= { "WI_DESP" ,;
                  "WI_MOEDA" ,; 
                  "WI_PERCAPL" ,;  
                  "WI_IDVL" ,;  
                  "WI_DESPBAS" ,;
                  "WI_VALOR" ,;
                  "WI_QTDDIAS",; 
                  "WI_VAL_MAX",;
                  "WI_VAL_MIN",;
                  "WI_KILO1",;
                  "WI_VALOR1",;
                  "WI_KILO2",;
                  "WI_VALOR2",;
                  "WI_KILO3",;
                  "WI_VALOR3",;
                  "WI_KILO4",;
                  "WI_VALOR4",;
                  "WI_KILO5",;
                  "WI_VALOR5",;
                  "WI_KILO6",;
                  "WI_VALOR6"}

   EndIf

   If SWI->(FieldPos("WI_CON20")) # 0 .AND. SWI->(FieldPos("WI_CON40")) # 0 .AND. SWI->(FieldPos("WI_CON40H")) # 0 .AND. SWI->(FieldPos("WI_CONOUT")) # 0
      aadd(aStruct,"WI_CON20")
      aadd(aStruct,"WI_CON40")
      aadd(aStruct,"WI_CON40H")
      aadd(aStruct,"WI_CONOUT")
   EndIf

   If EasyEntryPoint("EICTC210")
      ExecBlock("EICTC210",.F.,.F.,"MONTA_CAMPOS")
   EndIf 
   
Return aStruct            

/*
Função          : IncluiDespesa()
Objetivo        : Criar as despesas 204 e 205
Parâmetros      : Nenhum
Retorno         : Nenhum
Autor           : Tamires Daglio Ferreira
Data/Hora       : 28/03/10
*/           
*==============================================================*
Function IncluiDespesa()
*==============================================================*
Local cAlias  := "SYB"
Local aOrd    := SaveOrd(cAlias)
Local cPis    := EasyGParam("MV_D_PIS")
Local cConfins:=EasyGParam("MV_D_COFIN")

SYB->(DbsetOrder(1))

If !SYB->(DBSEEK(xFilial(cAlias)+cPis))
   SYB->(RecLock(cAlias,.T.))
   SYB->YB_FILIAL:= xFilial("SYB") //MCF - 08/06/2015
   SYB->YB_DESP:= "204"
   SYB->YB_DESCR:= "PIS"
   SYB->YB_IDVL:= "2" // PERCENTUAL
   SYB->YB_PERCAPL:= 1.65
   SYB->YB_DESPBAS:= "104201203"
   SYB->YB_MOEDA:= "R$"
   SYB->(MsUnlock())
EndIf

If !SYB->(DBSEEK(xFilial(cAlias)+cConfins))
   SYB->(RecLock(cAlias,.T.))
   SYB->YB_FILIAL:= xFilial("SYB") //MCF - 08/06/2015
   SYB->YB_DESP:= "205"
   SYB->YB_DESCR:="COFINS"
   SYB->YB_IDVL:= "2" // PERCENTUAL
   SYB->YB_PERCAPL:= 7.6
   SYB->YB_DESPBAS:= "104201203"
   SYB->YB_MOEDA:= "R$"
   SYB->(MsUnlock())
EndIf

RestOrd(aOrd, .T.)

Return .T.       

/*
Programa   : UnicoRegSWF
Objetivo   : Empedir que incluia registro duplicado na rotina de tabela de pre calculo.
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 10/09/2013
*/
Static Function UnicoRegSWF()
Local aOrd  := SaveOrd({"SWF"})
Local lRet  := .T.
SWF->(DBSETORDER(2))
IF oGet:nOpc == 3 .AND. SWF->(DBSEEK(xFilial("SWF")+M->WF_VIA+M->WF_TAB)) //Somente na inclusão.
   Help(" ",1,"JAGRAVADO") //"Já existe registro com esta infomação"
   lRet := .F.
End If
RestOrd(aOrd, .T.)

Return lRet

/*
Programa   : TC210ValDBASE
Objetivo   : Validação extra para a despesa e despesa base
Autor      : Lucas Raminelli
Data/Hora  : 10/05/2018
*/
Function TC210ValDBASE(cCampo,nInEx)
LOCAL I, nRecno:=TRB->(RECNO()), aDesp:={}, lRet:=.T.


IF nInEx == 1
    TRB->(DBGoTop())
    While  TRB->(!Eof())
        IF SUBS(TRB->WI_DESPBAS,1,3) == cCampo .OR. SUBS(TRB->WI_DESPBAS,4,3) == cCampo;
        .OR. SUBS(TRB->WI_DESPBAS,7,9) == cCampo
           lRet:=.F.
           Exit
        EndIF
        TRB->(DBSkip())
    EndDO
Else

    AADD(aDesp,SUBS(cCampo,1,3))
    AADD(aDesp,SUBS(cCampo,4,3))
    AADD(aDesp,SUBS(cCampo,7,9))

    TRB->(DBSetOrder(1))

    FOR I:=1 TO LEN(aDesp)
        IF !EMPTY(aDesp[I])
        IF !TRB->(DBSEEK(+aDesp[I]))
            lRet:=.F.
            Exit
        ENDIF
        ENDIF
    NEXT

EndIF

If ! lRet
   IF nInEx == 1
      EasyHelp(STR0026 + cCampo +STR0027,STR0025)
      //"Não é possivel excluir a despesa " cCampo " pois a mesma se encontra em uma desepesa base"
   Else
      EasyHelp(STR0028 +aDesp[I]+ STR0029,STR0025)
     //"Não é possivel Incluir a despesa base " aDesp[I] " pois a mesma não se encontra nas despesas do Pré-Calculo"
   EndIF
Endif

TRB->(DBGOTO(nRecno))

Return lRet

*--------------------------------------------------------------*
*	          		 FIM DO PROGRAMA EICTC210.PRW			   *
*--------------------------------------------------------------*
