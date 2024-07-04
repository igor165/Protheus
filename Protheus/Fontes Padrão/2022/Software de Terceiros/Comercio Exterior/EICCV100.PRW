#INCLUDE "Eiccv100.ch"
//#include "FiveWin.ch"
#include "Average.ch"
#include "tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICCV100 ³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 10/07/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao do Cadastro de Vias                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Alterado por Heder M Oliveira - 6/14/1999
Function EICCV100
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL i:=1
Private aTELA[0][0],aGETS[0]
PRIVATE aRotina := MenuDef()
PRIVATE cDelFunc,cArqn,lCampo := " ",bRecno:={||TRB->YR_RECNO:=SYR->(RECNO())} // cArqn ,bRECNO e lCampo é do rdmake da Gradiente - icpadca1
PRIVATE laHeader :=.T.,cNomArq,aHeaderSYR:={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemtoAnsi(STR0006) //"Vias de Transporte"
PRIVATE cTitulo   := OemtoAnsi(STR0007) //"Tarifas de Frete"

PRIVATE aCampos :={}, nTip:=0, lMoeda:=.T., lAlteracao:=.F.
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))

PRIVATE bSeek :={||SYR->(DBSEEK(xFilial("SYR")+SYQ->YQ_VIA)) }
Private cSeek, bSYQWhile := {|| xFilial("SYR") + SYQ->YQ_VIA }
PRIVATE bWhile:={||xFilial("SYR") = SYR->YR_FILIAL  .AND. ;
                   SYR->YR_VIA = SYQ->YQ_VIA }, bFor:={|| EMPTY(SYR->YR_PAIS_DE)}

PRIVATE bRegBranco:={|| EMPTY(TRB->YR_ORIGEM).OR.EMPTY(TRB->YR_DESTINO).OR.;
                        EMPTY(TRB->YR_MOEDA).OR.EMPTY(TRB->YR_VALOR1).OR.EMPTY(TRB->YR_TRANS_T).OR.;
                        EMPTY(TRB->YR_PAIS_OR).OR.EMPTY(TRB->YR_CID_ORI).OR.EMPTY(TRB->YR_KILO1) }

PRIVATE aSemSX3:={ {"YR_CONTEIN","C",7,0},;
                   {"YR_FRETE_K","C",7,0},;
                   {"YR_RECNO"  ,"N",06,0},; //CES 12/06
                   {"YR_VL_MIN" ,"N",12,2},;
                   {"YR_KILO1"  ,"N",12,3},;
                   {"YR_VALOR1" ,"N",12,2},;
                   {"YR_KILO2"  ,"N",12,3},;
                   {"YR_VALOR2" ,"N",12,2},;
                   {"YR_KILO3"  ,"N",12,3},;
                   {"YR_VALOR3" ,"N",12,2},;
                   {"YR_KILO4"  ,"N",12,3},;
                   {"YR_VALOR4" ,"N",12,2},;
                   {"YR_KILO5"  ,"N",12,3},;
                   {"YR_VALOR5" ,"N",12,2},;
                   {"YR_KILO6"  ,"N",12,3},;
                   {"YR_VALOR6" ,"N",12,2},;
                   {"YR_20"     ,"N",12,2},;
                   {"YR_40"     ,"N",12,2},;
                   {"YR_40_HC"  ,"N",12,2},;                   
                   {"YR_OUTROS" ,"N",12,2}}

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"ESTRU_TRB"),)
IF ( nMODULO=29 ) //EXPORTACAO
	AADD(aSEMSX3,{"YR_TIPTRAN","C",1,0})
ENDIF
//aCampos:={"YR_ORIGEM","YR_DESTINO","YR_MOEDA","YR_TRANS_T","YR_PAIS_OR","YR_CID_ORI"}
IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"CRIA_CAMPOS"),) // JBS - 27/11/2003

IF EasyEntryPoint("ICPADCA1")
  ExecBlock("ICPADCA1",.F.,.F.,"VARIAVEIS")
ENDIF

SX3->(DBSETORDER(2))
FOR I := 1 TO LEN(aSemSX3)
   IF SX3->(DBSEEK(aSemSX3[I][1]))
      aSemSX3[I][2]:=SX3->X3_TIPO
      aSemSX3[I][3]:=SX3->X3_TAMANHO
      aSemSX3[I][4]:=SX3->X3_DECIMAL
   ENDIF
NEXT
SX3->(DBSETORDER(1))

SYR->(DBSETORDER(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis com nome dos campos de Bancos de Dados        ³
//³ para serem usadas na funcao de inclusao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SYQ")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT
DbSelectArea("SYR")
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

SYQ->(E_InitVar())

PRIVATE aPos:= { 15,  1, 70, 315 }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SYQ")

Return .T.    

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 17/01/07 - 13:53
*/
Static Function MenuDef()
Local aRotAdic              
Local aRotina :=   { { STR0001   ,"AxPesqui"   , 0 , 1},; //"Pesquisar"
                     { STR0002   ,"CV100Visual", 0 , 2},; //"Visualizar"
                     { STR0003   ,"CV100Inclui", 0 , 3},; //"Incluir"
                     { STR0004   ,"CV100Altera", 0 , 4, 20 },; //"Alterar"
                     { STR0005   ,"CV100Deleta", 0 , 5, 21 } } //"Excluir"

//P.E. existente antes da utilização do MenuDef.
IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"AROTINA"),) 

//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("ICV100MNU")
	aRotAdic := ExecBlock("ICV100MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CV100Visua³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para visualizacao de tarifas de frete             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void CV100Visual(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CV100Visual(cAlias,nReg,nOpc)

LOCAL nOpca := 0,;
      cSavMenuh,;
      bCampo

LOCAL oDlg, oGet, oEnch

LOCAL cAlias1:="SYR"// , cNomArq

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nUsado:=0,lTab := .F.
PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP
PRIVATE CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

aTela := {}
aGets := {}

bCampo   := { |nCPO| Field(nCPO) }

nTip:=nOpc

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
PRIVATE aHeader[0],Continua, nNumLin:=0

dbSelectArea(cAlias1)
dbSetOrder(1)
dbSeek(xFilial(cAlias1)+SYQ->YQ_VIA)

If (cAlias1)->(EOF())
   Help(" ",1,"EICSEMTARI")
   Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aNoHeader:=   { "YR_VALOR_K" ,;
                "YR_PAIS_DE" ,;
                "YR_CID_DES" ,;
                "YR_INLAND"  ,;
                "YR_FRVALOR" ,;
                "YR_VL_MIN"  ,;
                "YR_KILO1"   ,;
                "YR_VALOR1"  ,;
                "YR_KILO2"   ,;
                "YR_VALOR2"  ,;
                "YR_KILO3"   ,;
                "YR_VALOR3"  ,;
                "YR_KILO4"   ,;
                "YR_VALOR4"  ,;
                "YR_KILO5"   ,;
                "YR_VALOR5"  ,;
                "YR_KILO6"   ,;
                "YR_VALOR6"  ,;
                "YR_20"      ,;
                "YR_20_M3"   ,;
                "YR_40"      ,;
                "YR_40_M3"   ,;
                "YR_40_HC"   ,;
                "YR_40HC_M3" ,;
                "YR_CNTR_FR" ,;
                "YR_CNFR_M3" ,;
                "YR_CNTR_PE" ,;
                "YR_CNPE_M3" ,;
                "YR_CNTR_OP" ,;
                "YR_CNOP_M3" ,;
                "YR_OUTROS"  ,;
                "YR_OUT_M3"  } 

aCpoVirtual:= { "YR_CONTEIN" ,;
                "YR_FRETE_K" }
cSeek := xFilial("SYR")+SYQ->YQ_VIA
bCond := {|| EMPTY(SYR->YR_PAIS_DE) .Or. (cPaisLoc == "BRA" .And. SYR->YR_PAIS_DE == "105")}
bAction1 := {|| SYR->( YR_FILIAL+YR_VIA ) == xFilial("SYR")+SYQ->YQ_VIA  }
bAction2 := {||.F.}

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"NOHERADERV"),)

FillGetDB(nOpc, "SYR", "TRB",,1, cSeek, bSYQWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,/*ExcHeader(aYesHeader, "SYR")*/aNoHeader,,,aCpoVirtual,)
cNomArq := AvTrabName("TRB")
dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"YR_ORIGEM+YR_DESTINO")

If IsVazio("TRB")
   Help(" ",1,"EA200SEMIT")
   TRB->(E_EraseArq(cNomArq,,,,.F.))//THTS - 01/08/2018 - Adicionado o forcabanco falso, pois a FillGetDB sempre cria o temporaruio local
   Return .T.
Endif

While .T.

   //DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 28,80 OF oMainWnd
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTitulo;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL

   oEnCh:=MsMGet():New( cAlias, nReg, nOpc, , , , , aPos, , 3 ) //LRL 22/04/04

   lTab   := .T.
   dbSelectArea("TRB")
   TRB->(dbGoTop())
   //aHeader:=ACLONE(aHeaderSYR)
   TRB->(oGet:=MsGetDB():New(75,1,143,315,nOpc,"CV100LinOk","E_TudOk","",.T., , ,.F., ,"TRB"))
   oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
   oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT   //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()}, ,AvBarCV()),; //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Refresh()) //LRL 22/04/04 - Alinhamento MDI.
   Exit

End

CV100_DEL_TRB()

dbSelectArea(cAlias)
Return( nOpca )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CV100Inclu³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para inclusao de Orcamentos.            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void CV100Inclui(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CV100Inclui(cAlias,nReg,nOpc)
LOCAL nOpca := 0,cSavMenuh,lGravaOk := .T.,i
LOCAL cAlias1:="SYR" //, cNomArq
LOCAL oDlg, oGet , oEnch, oPanel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nUsado:=0,lTab := .F.,nNumLin:=0
PRIVATE bArqF3, bCpoF3, lInclui:=.T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aHeader[0],Continua
PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
        
aTela    := {}
aGets    := {}
bCampo   := { |nCPO| Field(nCPO) }

nTip:=nOpc

FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
NEXT i
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho e indice                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aNoHeader:=   { "YR_VALOR_K" ,;
                "YR_PAIS_DE" ,;
                "YR_CID_DES" ,;
                "YR_INLAND"  ,;
                "YR_FRVALOR" ,;
                "YR_VL_MIN"  ,;
                "YR_KILO1"   ,;
                "YR_VALOR1"  ,;
                "YR_KILO2"   ,;
                "YR_VALOR2"  ,;
                "YR_KILO3"   ,;
                "YR_VALOR3"  ,;
                "YR_KILO4"   ,;
                "YR_VALOR4"  ,;
                "YR_KILO5"   ,;
                "YR_VALOR5"  ,;
                "YR_KILO6"   ,;
                "YR_VALOR6"  ,;
                "YR_20"      ,;
                "YR_20_M3"   ,;
                "YR_40"      ,;
                "YR_40_M3"   ,;
                "YR_40_HC"   ,;
                "YR_40HC_M3" ,;
                "YR_CNTR_FR" ,;
                "YR_CNFR_M3" ,;
                "YR_CNTR_PE" ,;
                "YR_CNPE_M3" ,;
                "YR_CNTR_OP" ,;
                "YR_CNOP_M3" ,;
                "YR_OUTROS"  ,;
                "YR_OUT_M3"  }   

aCpoVirtual:= { "YR_CONTEIN" ,;
                "YR_FRETE_K" }
cSeek := xFilial("SYR")+SYQ->YQ_VIA

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"NOHERADERI"),)

FillGetDB(nOpc, "SYR", "TRB1",,1, cSeek, bSYQWhile,,/*aNoFields*/,/*aYesFields*/,,,,/*ExcHeader(aYesHeader, "SYR")*/aNoHeader,,,aCpoVirtual,)
//cNomArq := AvTrabName("TRB")
cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
dbSelectArea("TRB")
// EJA - 23/07/2019 - AvZap removido por causa do Oracle Database.
// TRB->(avzap())
IndRegua("TRB",cNomArq+TEOrdBagExt(),"YR_ORIGEM+YR_DESTINO")

TRB1->(dbCloseArea())

// Alterado por Heder M Oliveira - 6/14/1999
IF ( nModulo=29 ) //Exportacao
	AHEADER[ASCAN(aHEADER,{|x| x[1]=STR0011})][1]:=STR0012 //"Pais Origem"###"Pais Destino"
	AHEADER[ASCAN(aHEADER,{|x| x[1]=STR0013})][1]:=STR0014 //"Cidade Orig."###"Cidade Dest."
ENDIF

nOpca := 0
Continua := .F.

TRB->(DBSetOrder(0))   // ACSJ - 07/04/2004 -> Na Versão 8.11 a Work não pode estar indexado para o MSGetDB
 					   //                      Funcionar corretamente.

//DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 28,80 OF oMainWnd
oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE cTitulo;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL    

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, aPos[4], aPos[3])
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT 
   
   oEnCh:=MsMGet():New(cAlias, nReg, nOpc,,,,, aPos,, 3,,,, oPanel) //LRL 22/04/04

   lTab := .T.
   dbSelectArea("TRB")


   TRB->(oGet:=MsGetDB():New(75,1,145,315,nOpc,"CV100LinOk","E_TudOk","",.T., , ,.F., ,"TRB",,,, oPanel))
   oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}

   oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,If(oGet:TudoOk() .And. Obrigatorio(aGets,aTela),oDlg:End(),nOpca := 0)},{||oDlg:End()}),;
oGet:oBrowse:Refresh()) //LRL 22/04/04 -Alinhamento MDI. //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

If nOpcA == 1
   Begin Transaction
      lGravaOk := CV100Grava(cAlias,cAlias1,nReg)
      If !lGravaOk
         //Help(" ",1,"A110NAOREG") //comentado por wfs
         EasyHelp(STR0038, STR0020) //"Não foi possível concluir a gravação. Não existem origens e/ou destinos válidos para gravação. Verifique os dados informados e o preenchimento de campos obrigatórios", "Atenção"
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

CV100_DEL_TRB()
dbSelectArea(cAlias)
Return( nOpcA )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CV100Alter³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa exclusivo para alteracao de Or‡amentos.           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void CV100Altera(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CV100Altera(cAlias,nReg,nOpc)
LOCAL bCampo,nOpca := 0,cSavMenuh,lGravaOk:=.T.,lLiber := .F., xAlias
LOCAL cAlias1:="SYR"//, cNomArq
LOCAL oDlg, oGet,i, oEnch
Local oPanel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nUsado:=0,lTab := .F.,nNumLin:=0, lInclui:=.F.

aTela := {}
aGets := {}
lAlteracao:=.T.

bCampo := { |nCPO| Field(nCPO) }

nTip:=nOpc

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
PRIVATE aHeader[0],Continua
PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999,nCampos:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
FOR i := 1 TO FCount()
    M->&(EVAL(bCampo,i)) := FieldGet(i)
    nCampos++
NEXT i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aNoHeader:=   { "YR_VALOR_K" ,;
                "YR_PAIS_DE" ,;
                "YR_CID_DES" ,;
                "YR_INLAND"  ,;
                "YR_FRVALOR" ,;
                "YR_VL_MIN"  ,;
                "YR_KILO1"   ,;
                "YR_VALOR1"  ,;
                "YR_KILO2"   ,;
                "YR_VALOR2"  ,;
                "YR_KILO3"   ,;
                "YR_VALOR3"  ,;
                "YR_KILO4"   ,;
                "YR_VALOR4"  ,;
                "YR_KILO5"   ,;
                "YR_VALOR5"  ,;
                "YR_KILO6"   ,;
                "YR_VALOR6"  ,;
                "YR_20"      ,;
                "YR_20_M3"   ,;
                "YR_40"      ,;
                "YR_40_M3"   ,;
                "YR_40_HC"   ,;
                "YR_40HC_M3" ,;
                "YR_CNTR_FR" ,;
                "YR_CNFR_M3" ,;
                "YR_CNTR_PE" ,;
                "YR_CNPE_M3" ,;
                "YR_CNTR_OP" ,;
                "YR_CNOP_M3" ,;
                "YR_OUTROS"  ,;
                "YR_OUT_M3"  }  


aCpoVirtual:= { "YR_CONTEIN" ,;
                "YR_FRETE_K" }
cSeek := xFilial("SYR")+SYQ->YQ_VIA                
//bCond := {||.T.}
//bCond := {|| EMPTY(SYR->YR_PAIS_DE)} //wfs 31/05
bCond := {|| EMPTY(SYR->YR_PAIS_DE) .Or. (cPaisLoc == "BRA" .And. SYR->YR_PAIS_DE == "105")}
bAction1 := {|| SYR->( YR_FILIAL+YR_VIA ) == xFilial("SYR")+SYQ->YQ_VIA  }
bAction2 := {||.F.}

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"NOHERADERA"),)

FillGetDB(nOpc, "SYR", "TRB1",,1, cSeek, bSYQWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,/*ExcHeader(aYesHeader, "SYR")*/aNoHeader,,,aCpoVirtual,)

cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
//cNomArq := AvTrabName("TRB")
dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"YR_ORIGEM+YR_DESTINO")
TERestBackup("TRB1")
TRB1->(dbCloseArea())

//If ! E_GravaTRB(cAlias1,bSeek,bFor,bWhile,aSemSx3,bRecno)
If IsVazio("TRB")
   IF SYR->(DBSEEK(xFilial("SYR")+SYQ->YQ_VIA))
	   IF EMPTY((cAlias1)->YR_PAIS_DE)   // Jonato em 30/09/05 para não dar erro, quando a via for cadastrada na exportação
	      Help(" ",1,"EA200SEMIT")
	      TRB->(E_EraseArq(cNomArq,,,,.F.))//THTS - 01/08/2018 - Adicionado o forcabanco falso, pois a FillGetDB sempre cria o temporaruio local
	      dbSelectArea(cAlias)
	      Return .T.
	   Else
          TRB->(DBAppend())	      
	   ENDIF
   ELSE
      //MFR 08/03/2017 TE-4889 WCC-506663 MTRADE-697
      TRB->(DBAppend())
      // Help(" ",1,"EA200SEMIT")
      // TRB->(E_EraseArq(cNomArq))
      // dbSelectArea(cAlias)
      // Return .T.
   ENDIF
Endif
TRB->(DBGOTOP())
DO WHILE ! TRB->(EOF())
   TRB->YR_CONTEIN:='<Click>'
   TRB->YR_FRETE_K:='<Click>'
   TRB->(DBSKIP())
ENDDO
IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"ATU_TRB"),)
TRB->(DBGOTOP())

// Alterado por Heder M Oliveira - 6/14/1999
IF ( nModulo=29 ) //Exportacao
	AHEADER[ASCAN(aHEADER,{|x| x[1]=STR0011})][1]:=STR0012 //"Pais Origem"###"Pais Destino"
	AHEADER[ASCAN(aHEADER,{|x| x[1]=STR0013})][1]:=STR0014 //"Cidade Orig."###"Cidade Dest."
ENDIF

nOpca := 0
Continua := .F.
lTab := .T.

TRB->(DBSetOrder(0))   // ACSJ - 07/04/2004 -> Na Versão 8.11 a Work não pode estar indexado para o MSGetDB
 					   //                      Funcionar corretamente.

//DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 28,80 OF oMainWnd
oMainWnd:ReadClientCoors()
DEFINE MSDIALOG oDlg TITLE cTitulo;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL    

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, aPos[4], aPos[3])
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   
   oEnCh:=MsMget():New( cAlias, nReg, nOpc,,,,, aPos,, 3,,,, oPanel) //LRL 22/04/04 

   dbSelectArea("TRB")
   TRB->(dbGoTop())

   TRB->(oGet:=MsGetDB():New(75,1,143,315,nOpc,"CV100LinOk","CVDELITEM","",.T., , ,.F., ,"TRB",,,, oPanel))
   oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}

   oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk() .And. Obrigatorio(aGets,aTela),oDlg:End(),nOpca := 0)},{||oDlg:End()}),;
  oGet:oBrowse:Refresh()) //LRL 22/04/04 -Alinhamento MDI. //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

If nOpcA == 1
   Begin Transaction
      lGravaOk := CV100Grava(cAlias,cAlias1,nReg)
      If !lGravaOk
         //Help(" ",1,"A110NAOREG") //comentado por wfs
         EasyHelp(STR0038, STR0020) //"Não foi possível concluir a gravação. Não existem origens e/ou destinos válidos para gravação. Verifique os dados informados e o preenchimento de campos obrigatórios", "Atenção"
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

CV100_DEL_TRB()
dbSelectArea(cAlias)
lAlteracao:=.F.
Return( nOpca )
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CV100Delet³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de exclusao de Orcamentos                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void CV100Deleta(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CV100Deleta(cAlias,nReg,nOpc)

LOCAL nOpca := 0, cSavMenuh, nCnt := 0, bCampo, cAlias1:="SYR" //, cNomArq
LOCAL oDlg, oGet, cFilSW2 ,oEnch, oPanel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nUsado:=0,lTab := .F.
PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP
PRIVATE CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999
        
aTela    := {}
aGets    := {}
bCampo   := { |nCPO| Field(nCPO) }

nTip:=nOpc

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
PRIVATE aHeader[0],Continua, nNumLin:=0

If !ValExcVIA(SYQ->YQ_VIA,.F.)
   Return .F.
EndIf

cFilSW2:=xFilial('SW2')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aNoHeader:=   { "YR_VALOR_K" ,;
                "YR_PAIS_DE" ,;
                "YR_CID_DES" ,;
                "YR_INLAND"  ,;
                "YR_FRVALOR" ,;
                "YR_VL_MIN"  ,;
                "YR_KILO1"   ,;
                "YR_VALOR1"  ,;
                "YR_KILO2"   ,;
                "YR_VALOR2"  ,;
                "YR_KILO3"   ,;
                "YR_VALOR3"  ,;
                "YR_KILO4"   ,;
                "YR_VALOR4"  ,;
                "YR_KILO5"   ,;
                "YR_VALOR5"  ,;
                "YR_KILO6"   ,;
                "YR_VALOR6"  ,;
                "YR_20"      ,;
                "YR_20_M3"   ,;
                "YR_40"      ,;
                "YR_40_M3"   ,;
                "YR_40_HC"   ,;
                "YR_40HC_M3" ,;
                "YR_CNTR_FR" ,;
                "YR_CNFR_M3" ,;
                "YR_CNTR_PE" ,;
                "YR_CNPE_M3" ,;
                "YR_CNTR_OP" ,;
                "YR_CNOP_M3" ,;
                "YR_OUTROS"  ,;
                "YR_OUT_M3"  }

aCpoVirtual:= { "YR_CONTEIN" ,;
                "YR_FRETE_K" }
cSeek := xFilial("SYR")+SYQ->YQ_VIA                
//bCond := {||.T.}                                                        
//bCond := {|| EMPTY(SYR->YR_PAIS_DE)} //wfs 31/05
bCond := {|| EMPTY(SYR->YR_PAIS_DE) .Or. (cPaisLoc == "BRA" .And. SYR->YR_PAIS_DE == "105")}
bAction1 := {|| SYR->( YR_FILIAL+YR_VIA ) == xFilial("SYR")+SYQ->YQ_VIA  }
bAction2 := {||.F.}

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"NOHERADERE"),)

FillGetDB(nOpc, "SYR", "TRB1",,1, cSeek, bSYQWhile,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,,,,/*ExcHeader(aYesHeader, "SYR")*/aNoHeader,,,aCpoVirtual,)
cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"YR_ORIGEM+YR_DESTINO")
TERestBackup("TRB1")
TRB1->(dbCloseArea())

If IsVazio("TRB")
   Help(" ",1,"EA200SEMIT")
   TRB->(E_EraseArq(cNomArq,,,,.F.))//THTS - 01/08/2018 - Adicionado o forcabanco falso, pois a FillGetDB sempre cria o temporaruio local
   Return .T.
Endif

While .T.

   nOpca := 1
   //DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 28,80 OF oMainWnd
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cTitulo;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10;
      OF oMainWnd PIXEL
      
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, aPos[4], aPos[3])
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      oEnCh:=MsMGet():New( cAlias, nReg, nOpc,,,,, aPos,, 3,,,, oPanel)//LRL 22/04/04

      lTab   := .T.

      dbSelectArea("TRB")
      dbGoTop()
      TRB->(oGet:=MsGetDB():New(75,1,143,315,nOpc,"CV100LinOk","E_TudOk","",.T., , ,.F., ,"TRB",,,, oPanel))
      oGet:oBrowse:bwhen:={||(dbSelectArea("TRB"),.t.)}
      oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {||nOpcA:=2,oDlg:End()},;
                                                     {||nOpcA:=1,oDlg:End()},,AvBarCV()),;//LRL 22/04/04
                                                     oGet:oBrowse:Refresh()) //Alinhamento MDI.
   IF nOpcA == 1
      Exit
   ELSEIF nOpcA == 2

      Begin Transaction
         dbSelectArea( cAlias1 )
         ( cAlias1 )->(dbSeek(xFilial(cAlias1)+SYQ->YQ_VIA))
         nCnt := 0

         While ( cAlias1 )->(!Eof()) .And. xFilial(cAlias1)=SYR->YR_FILIAL .AND. SYQ->YQ_VIA=SYR->YR_VIA
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Apagar Tarifas de Frete                             ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            RecLock(cAlias1,.F.)
            dbDelete()
            MSUNLOCK()
            nCnt++
            ( cAlias1 )->(dbSkip())
         End

         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Apaga o cabecalho: Vias de Transporte               ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         dbSelectArea("SYQ")
         RecLock("SYQ",.F.)
         dbDelete()
         MSUNLOCK()

         IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"CV100DELETA"),)
         dbSelectArea( cAlias1 )
      End Transaction
      Exit
   Endif
End

CV100_DEL_TRB()
dbSelectArea(cAlias)
Return( nOpca )
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CV100Grava³ Autor ³ PADRAO GETDADDB       ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as nformacoes nos arquivos SZ1 e SW2.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ EICCV100                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CV100Grava(cAlias,cAlias1,nReg)
LOCAL nX, nMaxArray, bCampo, lTemReg:=.f. //,nCntDel:=0

LOCAL xVar, BVar:={||.t.},ny
bCampo := {|nCPO| Field(nCPO) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de itens                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
TRB->(dbGoBottom())

TRB->(dbGoTop())
While TRB->(!EoF())
   If ! FieldGet(FCount()) .AND. ! EVAL(bRegBranco)
      lTemReg:=.t.
      EXIT
   Endif
   TRB->(dbSkip())
End

If ! lTemReg
   Return .F.
Endif  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SYQ ( Vias de Tranporte )                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea(cAlias)
If ! inclui
   (cAlias)->(DBGOTO(nReg))
EndIf
E_Grava(cAlias,inclui)

SYQ->(FKCOMMIT())	//Johann 24/08/2005 - P/ compatibilizar com a Integridade Referencial

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SYR (Tarifas de Frete)                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
TRB->(DBGOTOP())
SY9->(DBSetOrder(2))
WHILE ! TRB->(EOF())

    IF TRB->YR_FLAG.OR.EVAL(bRegBranco)
		If !Empty(TRB->YR_REC_WT)
		   SYR->(dbGoTo(TRB->YR_REC_WT))
		   
		   RecLock("SYR",.F.)
		   SYR->(DBDELETE())
		   SYR->(MSUNLOCK())
		EndIf
	
       TRB->(DBSKIP())
       LOOP
    ENDIF
	
	If !Empty(TRB->YR_REC_WT)
	   SYR->(dbGoTo(TRB->YR_REC_WT))
	   RecLock("SYR",.F.)
	Else
       RecLock(cAlias1,.T.)  // bloqueia e incluir registro vazio
	EndIf

    For ny := 1 to Len(aHeader)
       xVar:=Trim(aHeader[ny][2])
       bVar:=FIELDWBLOCK(xVar,SELECT(cAlias1))
       If aHeader[ny][10] # "V" .And. SYR->(FieldPos(aHeader[ny][2])) > 0
          EVAL(bVar,EVAL(FIELDWBLOCK(xVar,SELECT("TRB"))))
       Endif
    Next ny

    For ny := 4 to Len(aSemSx3)  //CES 12/06 POR CAUSA DO CAMPO RECNO
        xVar:=Trim(aSemSx3[ny][1])
        bVar:=FIELDWBLOCK(xVar,SELECT(cAlias1))
        EVAL(bVar,EVAL(FIELDWBLOCK(xVar,SELECT("TRB"))))
    Next ny

    SYR->YR_VIA:=SYQ->YQ_VIA
    SYR->YR_FILIAL:=xFilial("SYR")
    
    SY9->(DBSeek(xFilial() + TRB->YR_DESTINO))
    SYR->YR_PAIS_DE:= SY9->Y9_PAIS //wfs - preenchimento do país conforme cadastro de portos e aeroportos
    
    SYR->(MSUNLOCK())

    TRB->(DBSKIP())

End

SYQ->(MSUNLOCK())
IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"CV100GRAVA"),)

Return( .T. )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CV100LinOk³ Autor ³ PADRAO PARA GETDADDB  ³ Data ³ 12.07.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas do Orcamento. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpN1 = CV100LinOk                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor devolvido pela fun‡„o                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function CV100LinOk(o)
Local lRet := .T., nRec
lCampo:= " "
// Fazer as consistencias especiais

IF TRB->YR_FLAG
   RETURN lRet
ENDIF

IF EVAL(bRegBranco)
   //HELP(" ",1,"OBRIGAT") //wfs - melhoria na mensagem de validação
   EasyHelp(STR0039, STR0040) //"Um ou mais campos obrigatórios não foram preenchidos. Preencha os campos cujos títulos possuem o símbolo '*' (asterisco) e confirme os dados de origem, destino, moeda, Transit Time e valores de frete por kg.", "Obrigatórios")
   RETURN .F.
ENDIF
IF EasyEntryPoint("ICPADCA1")            
    IF !ExecBlock("ICPADCA1",.F.,.F.,"VALID")  
      RETURN .F.
    ELSE
      RETURN .T.
  ENDIF 
ENDIF

IF TRB->YR_ORIGEM = TRB->YR_DESTINO
   HELP(" ",1,"EA200ORIDE")
   RETURN .F.
ENDIF

IF TRB->(Easyreccount("TRB")) > 1

   nRec:=TRB->(RECNO())
   TRB->(DBSetOrder(1))   // ACSJ - 07/04/2004 -> O Arquivo Work não pode esta indexado para a MSGetDB funcionar
                          //                      Corretamente. Setando indice para a busca.
   
   IF TRB->(DBSEEK(TRB->YR_ORIGEM+TRB->YR_DESTINO)) .AND. TRB->(RecNo()) # nRec .AND. !TRB->YR_FLAG
      HELP(" ",1,"EA200EXIST")
      TRB->(DBGOTO(nRec))
      TRB->(DBSetOrder(0))
      RETURN .F.
   ENDIF               
   
   TRB->(DBGOTO(nRec))
   TRB->(DBSetOrder(0))   // ACSJ - 07/04/2004 -> O Arquivo Work não pode esta indexado para a MSGetDB funcionar
                          //                      Corretamente. Setando indice para a busca.
   
ENDIF

//SY9->(DBSETORDER(2))  
//IF !ExistCpo("SY9",M->YR_DESTINO)
//   SY9->(DBSETORDER(1))
//   RETURN .F.
//ENDIF
//SY9->(DBSETORDER(1)) 

//M->YR_DESTINO:="   "

Return( lRet )


/*³Revisão: wfs mai/2017 - validar o país da inclusão do cadastro via módulo
            SIGAEIC, consistindo o país de origem diferente de Brasil e país de destino igual à Brasil.*/
*---------------------------------*
Function CV100ValidSYR(lOrigem)
*---------------------------------*
Local cMsg:= "", nOldOrd:= 0

lCampo := IF(lOrigem==NIL,"A",IF(lOrigem==.T.,"O","D"))

lAchou := .F.
IF lOrigem
   lAchou := TRB->YR_DESTINO == M->YR_ORIGEM
ELSEIF lOrigem == .F.         // Para O  rdmake abaixo , lOrigem == NIL
   lAchou := M->YR_DESTINO == TRB->YR_ORIGEM
ENDIF

IF lAchou
   HELP(" ",1,"EA200ORIDE")
   RETURN .F.
ENDIF

IF!lOrigem .AND. !EMPTY(M->YR_DESTINO)
   SY9->(DBSETORDER(2))
   IF !ExistCpo("SY9",M->YR_DESTINO)
      SY9->(DBSETORDER(1))
      RETURN .F.
   ENDIF

   //wfs mai/2017 - validar o preenchimento do país; quando importação, o destino deve ser Brasil.
   If cPaisLoc == "BRA"         
      SY9->(DBSeek(xFilial() + M->YR_DESTINO))
      If Empty(SY9->Y9_PAIS)
         cMsg += STR0041 //"O país não foi informado. Verifique o cadastro do destino, na tabela de Portos/ Aeroportos, antes de prosseguir."
      ElseIf SY9->Y9_PAIS <> '105'
         cMsg += STR0042 //"O país de destino deve ser o Brasil. Verifique o destino informado para esta via de transporte."
      EndIf
   EndIf
   SY9->(DBSETORDER(1))
ENDIF

IF EasyEntryPoint("ICPADCA1")            
    IF !ExecBlock("ICPADCA1",.F.,.F.,"VALID")  
      RETURN .F.
    ELSE
      RETURN .T.
  ENDIF 
ENDIF

IF TRB->(Easyreccount("TRB")) > 1

   nRec:=TRB->(RECNO())
   TRB->(DBSetOrder(1))	// ACSJ - 07/04/2004 -> Alterações para ajustar a MSGetDB a versão 8.11 
   						//                      a Work não pode estar indexada.

   IF lOrigem
      lAchou := TRB->(DBSEEK(M->YR_ORIGEM+TRB->YR_DESTINO)) .AND. TRB->(RECNO()) # nRec .AND. !TRB->YR_FLAG
   ELSE
      lAchou := TRB->(DBSEEK(TRB->YR_ORIGEM+M->YR_DESTINO)) .AND. TRB->(RECNO()) # nRec .AND. !TRB->YR_FLAG
   ENDIF
   
   TRB->(DBSetOrder(0)) // ACSJ - 07/04/2004 -> O Arquivo não pode estar indexado para a MSGetDB funcionar 
                        //                      corretamente  

   IF lAchou
      HELP(" ",1,"EA200EXIST")
      TRB->(DBGOTO(nRec))
      RETURN .F.
   ENDIF

   TRB->(DBGOTO(nRec))

   //wfs mai/2017 - validar o preenchimento do país. Quando importação, a origem não pode ser o Brasil.
   If lOrigem .And. !Empty(M->YR_ORIGEM)
      If cPaisLoc == "BRA"
         
         nOldOrd:= SY9->(IndexOrd())
         
         SY9->(DBSetOrder(2)) //Y9_FILIAL+Y9_SIGLA
         SY9->(DBSeek(xFilial() + M->YR_ORIGEM))
         If Empty(SY9->Y9_PAIS)
            cMsg += STR0043 //"O país não foi informado. Verifique o cadastro da origem, na tabela de Portos/ Aeroportos, antes de prosseguir."
         // ElseIf SY9->Y9_PAIS == '105'
         //    cMsg += STR0044 //"O país de origem não pode ser Brasil. Verifique a origem informada para esta via de transporte."
         EndIf

         SY9->(DBSetOrder(nOldOrd))
      EndIf
   EndIf
ENDIF

If !Empty(cMsg)
   EasyHelp(cMsg, STR0020) //;Atenção
   Return .F.
EndIf

Return .T.

*--------------------------------*
FUNCTION CVManSYR(nTipo,cCampo)
*--------------------------------*
LOCAL oDlg1, cOldAlias:=Alias(), cNewTit:='', nReg1:=TRB->(RECNO())
LOCAL nLinIni, nLinFim, nColIni, nColFim, aPosi,i, oEnch1
PRIVATE nUsado:=0, aSYR:={}, cQual := cCampo , nTipoQual := nTipo , lPadrao := .T. , lSair := .F.

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"CVMANSYR"),)

IF lSair
   RETURN .T.
ENDIF   

IF EMPTY(cQual)
   cQual:='FRE'
ENDIF
        
aTela := {}
aGets := {}

IF cQual='FRE' .OR. ( STR(nTipo,1)$'2,5' .AND. lPadrao)
   AADD(aSYR,"YR_MOEDA")
   AADD(aSYR,"YR_VL_MIN")
   FOR i := 1 TO 6
       nMacro := Str( i,1 )
       M->(YR_KILO&nMacro)  := TRB->(YR_KILO&nMacro)
       M->(YR_VALOR&nMacro) := TRB->(YR_VALOR&nMacro)
       AADD(aSYR,"YR_KILO"+nMacro)
       AADD(aSYR,"YR_VALOR"+nMacro)
   NEXT i
	IF ( nMODULO=29 )  //EXPORTACAO
		AADD(aSYR,"YR_TIPTRAN")
	ENDIF

   M->YR_VL_MIN := TRB->YR_VL_MIN
   M->YR_MOEDA  := TRB->YR_MOEDA
   IF EMPTY(M->YR_MOEDA)
      lMoeda:=.T.
   ELSE
      lMoeda:=.F.
   ENDIF

   cNewTit:=STR0017 //"Fretes por Kg"
ENDIF

IF cQual='CON' .OR. ( STR(nTipo,1)$'2,5' .AND. lPadrao)
   AADD(aSYR,"YR_20")
   AADD(aSYR,"YR_40")
   AADD(aSYR,"YR_40_HC")
   AADD(aSYR,"YR_OUTROS")

   M->YR_20     := TRB->YR_20
   M->YR_40     := TRB->YR_40
   M->YR_40_HC  := TRB->YR_40_HC
   M->YR_OUTROS := TRB->YR_OUTROS
   cNewTit:=STR0009 //"Containers"
ENDIF

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"DEFINE_VAR"),)

IF STR(nTipo,1)$'2,5'
   cNewTit:=STR0018 //"Containers / Frete por Kg"
ENDIF

dbSelectArea("TRB")

WHILE .T.
    nOpc1 := 0

    DEFINE MSDIALOG oDlg1 TITLE cNewTit FROM 9,0 TO 28,80 OF oMainWnd

    IF(nTipo=3,lInclusao:=.T.,lInclusao:=.F.)

    oEnCh1:=MsMGet():New( "SYR", nReg1, 4, , , ,aSYR, {15,1,140,315},IF(STR(nTipo,1)$'2,5',{},NIL) , 3 ) //LRl 22/04/04
//    EnChoice( "SYR", nReg1, 4, , , ,aSYR, {15,1,140,315},IF(STR(nTipo,1)$'2,5',{},) , 3 )
    oEnch1:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

    ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1,{||nOpc1:=1,IF((Obrigatorio(aGets,aTela).and.CVValidFrete()),oDlg1:End(),nOpc1:=0)},{||oDlg1:End()})) //LRL 22/04/04 -Alinhamento MDI //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

/*  IF nOpc1==1 .AND. !CVValidFrete()
       LOOP
    ENDIF*/

    IF nOpc1 == 1 .AND. ! STR(nTipo,1)$'2,5'
       dbSelectArea("TRB")
       IF cQual='FRE'
          FOR i := 1 TO 6
              nMacro := Str( i,1 )
              TRB->(YR_KILO&nMacro)  := M->(YR_KILO&nMacro)
              TRB->(YR_VALOR&nMacro) := M->(YR_VALOR&nMacro)
          NEXT
          TRB->YR_VL_MIN := M->YR_VL_MIN
          TRB->YR_MOEDA  := M->YR_MOEDA
       ELSE
          TRB->YR_20     := M->YR_20
          TRB->YR_40     := M->YR_40
          TRB->YR_40_HC  := M->YR_40_HC
          TRB->YR_OUTROS := M->YR_OUTROS
          IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"GRAVA_TRB"),)
       ENDIF
    ENDIF

    EXIT
ENDDO

lMoeda:=.T.
dbSelectArea(cOldAlias)
return .F.

*----------------------*
FUNCTION CVValidFrete()
*----------------------*
LOCAL AvALORES:={M->YR_KILO1,M->YR_KILO2,;
               M->YR_KILO3,M->YR_KILO4,;
               M->YR_KILO5,M->YR_KILO6}   ,I

IF !EMPTY(M->YR_KILO2) .AND. M->YR_KILO2 <= M->YR_KILO1
   Help("", 1, "AVG0000233")//MSGSTOP(STR0019,OEMTOANSI(STR0020)) //"Kilo 2 menor ou igual que o Kilo 1 "###"ATEN€ÇO"
   RETURN .F.
ENDIF

IF !EMPTY(M->YR_KILO3) .AND. M->YR_KILO3 <= M->YR_KILO2
   Help("", 1, "AVG0000234")//MSGSTOP(STR0021,OEMTOANSI(STR0020)) //"Kilo 3 menor ou igual que o Kilo 2"###"ATEN€ÇO"
   RETURN .F.
ENDIF

IF !EMPTY(M->YR_KILO4) .AND. M->YR_KILO4 <= M->YR_KILO3
   Help("", 1, "AVG0000246")//MSGSTOP(STR0022,OEMTOANSI(STR0020)) //"Kilo 4 menor ou igual que o Kilo 3"###"ATEN€ÇO"
   RETURN .F.
ENDIF

IF !EMPTY(M->YR_KILO5) .AND. M->YR_KILO5 <= M->YR_KILO4
   Help("", 1, "AVG0000235")//MSGSTOP(STR0023,OEMTOANSI(STR0020)) //"Kilo 5 menor ou igual que o Kilo 4"###"ATEN€ÇO"
   RETURN .F.
ENDIF

FOR I:= 5 to 1 step -1
    nMacro := Str( i,1 )
    IF ! empty( m->yr_kilo&nMacro  )    
       IF !EMPTY(M->YR_KILO6) .AND. M->YR_KILO6 < M->YR_KILO&nMacro
          Help("", 1, "AVG0000237")//MSGSTOP(STR0024,OEMTOANSI(STR0020)) //"Kilo 6 menor que a ultima faixa "###"ATEN€ÇO"
         RETURN .F.
       ENDIF
       EXIT
   ENDIF
NEXT

FOR I:=1 TO 6
    nMacro := Str( i,1 )
    IF (!EMPTY(M->YR_KILO&nMacro) .AND. EMPTY(M->YR_VALOR&nMacro)) .OR.;
       (EMPTY(M->YR_KILO&nMacro) .AND. !EMPTY(M->YR_VALOR&nMacro))
       Help("", 1, "AVG0000238")//MSGSTOP(STR0036,OEMTOANSI(STR0020))// "Kilo ou Valor não Preenchido"
       RETURN .F.
    ENDIF   
NEXT
RETURN .T.

*----------------------------------------------------------------------*
FUNCTION AvBarCV()
*----------------------------------------------------------------------*
LOCAL aButtons:={}

aAdd(aButtons,{"RELATORIO",{|| CVManSYR(nTip) },STR0035})

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"AVBARCV"),)

RETURN aButtons

FUNCTION CVDELITEM()
LOCAL cFilSW2:=xFilial('SW2'), nRecTRB:=TRB->(RECNO()), aDel:={} 
Local lRet := .T.
TRB->(DBGOTOP())
DO WHILE ! TRB->(EOF())
   IF TRB->YR_FLAG
      /*AADD(aDel,{TRB->YR_DESTINO,TRB->YR_ORIGEM,TRB->(RECNO())})*/
      If !ValExcVia(M->YQ_VIA,TRB->YR_ORIGEM,TRB->YR_DESTINO,.F.,"2")      //NCF - 14/12/2015 
         lRet := .F.
         EXIT
      EndIf
   ENDIF
   TRB->(DBSKIP())
ENDDO
TRB->(DBGOTO(nRecTRB))

Return lRet


FUNCTION CV100VERITEM() // VI
//Alterado por Heder M Oliveira 20/04/00
local lRET:=.T.
begin sequence
   If nModulo == 17//EIC
      SYR->(DBSETORDER(1))
      IF lAlteracao .AND. SYR->(DBSEEK(xFilial("SYR")+M->YQ_VIA+TRB->YR_ORIGEM+TRB->YR_DESTINO))
         Help("", 1, "AVG0000240")//MSGINFO(OemToAnsi(STR0035),OemToAnsi(STR0016)) //"NÆo pode ser alterado a Origem e o Destino."###"Informa‡Æo"
         lRET:=.F.
      ENDIF      
   endif
end sequence   
RETURN lRET

*-----------------------------------*
FUNCTION CV100Gera_TRB() // LDR OS 0245/04
*-----------------------------------*

aHeader:={}
cNomArq:=E_CriaTrab(,aSemSx3)
aHeaderSYR:=ACLONE(aHeader)

IndRegua("TRB",cNomArq+TEOrdBagExt(),"YR_ORIGEM+YR_DESTINO")

IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"CRIA_TRB"),)

IF EasyEntryPoint("ICPADCA1")
   ExecBlock("ICPADCA1",.F.,.F.,"INDICE")
ENDIF

RETURN .T.
*-----------------------------------*
FUNCTION CV100_DEL_TRB()  // LDR OS 0245/04
*-----------------------------------*

TRB->(E_EraseArq(cNomArq,cArqn,cNomArq+TEOrdBagExt(),,.F.)) //THTS - 01/08/2018 - O ultimo parametro forca a apagar o arquivo temporario em disco, pois a FillGetDB sempre cria local.

DBSELECTAREA("SYQ")
IF(EasyEntryPoint("EICCV100"),ExecBlock("EICCV100",.F.,.F.,"DEL_TRB"),)

RETURN .T.

/*
Funcao     : ValExcVIA()
Parametros : cCodVia - Código da via a ser verificada
             lMsgHelp- Exibir Mensagem pelo Help ou por um log que pode ser salvo.
             ctipoVal - "1" - validacao da Via/ "2" - validação Origem/Destino
Retorno    : lRet - Retorna (T) se a via pode ser excluída e (F) caso contrário.
Objetivos  : Validar integridade dos cadastros na exclusão da Via de Transporte
Obs........: A função é chamada na manutenção de via do EIC e EEC
Autor      : Nilson César C. Filho - NCF
Data/Hora  : 14/12/2015 - 13:00
*/
Function ValExcVIA(cCodVia,cOrig,cDest,lMsgHelp,cTipoval)

Local lFound     := .F.
Local lRet       := .T.
Local aAliasECpo := {} 
Local cTit       := 'LOG DE EXCLUSÃO DA VIA DE TRANSPORTE'
Local i          := 1
Local cMsgLog    := ""
Local nOldArea   := Select()
Default lMsgHelp := .F.
Default cTipoVal := "1"

              //|Alias|Campo       |Campo Chave |Descrição 
aAliasECpo := {{"SW2","W2_TIPO_EM","W2_ORIGEM" ,"W2_DEST"   ,"W2_PO_NUM" ,"Processo de Purchase Order(Importação)"},;     //--Verificar em PO's
               {"SW6","W6_VIA_TRA","W6_ORIGEM" ,"W6_DEST"   ,"W6_HAWB"   ,"Processo de Embarque (Importação)"},;          //--Verificar em Embarques(Importação)
               {"EE7","EE7_VIA"   ,"EE7_ORIGEM","EE7_DEST"  ,"EE7_PEDIDO","Processo de Pedido de Exportação"},;           //--Verificar em Pedidos de Exportação            
               {"EEC","EEC_VIA"   ,"EEC_ORIGEM","EEC_DEST"  ,"EEC_PREEMB","Processo de Embarque de Exportação)"}}         //--Verificar em Embarques de Exportação                

If cTipoVal == "1"
   aAdd(aAliasECpo, {"SWF","WF_VIA"    ,            ,            ,"WF_TAB"    ,"Tabela de Pré-cálculo"})                      //--Verificar em Tab.Pre-cálculo
   aAdd(aAliasECpo, {"EXJ","EXJ_VIA"   ,            ,            ,"EXJ_COD"   ,"Cadastro de Cliente\Importador (Exportação)"})//--Verificar em Cliente\Importador                
EndIf
               
Do While i <= Len(aAliasECpo)
   cQuery := "SELECT * FROM "+RetSQLName(aAliasECpo[i][1])+" "+aAliasECpo[i][1]+" WHERE "+Left(aAliasECpo[i][5],At("_",aAliasECpo[i][5]))+"FILIAL = '"+xFilial(aAliasECpo[i][1])+"' AND "+aAliasECpo[i][2]+" = '"+cCodVia+"' "+;
             If( !Empty(cOrig)  , " AND "+aAliasECpo[i][3]+" = '"+cOrig+"' " , "")+;
             If( !Empty(cDest)  , " AND "+aAliasECpo[i][4]+" = '"+cDest+"' " , "")+;             
             " AND " + If( TcSrvType()<>"AS/400","D_E_L_E_T_ = ' '",aAliasECpo[i][1]+".@DELETED@ <> '*'")   
   
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WKOCVIA", .T., .T.)
      
   If !(WKOCVIA->(Eof()) .AND. WKOCVIA->(Bof()))
      lFound  := .T.
      lRet    := .F.
      If cTipoVal == "1"
         cMsgLog := "A via a ser excluída possui vínculo com "+aAliasECpo[i][6]+":"+CHR(13)+CHR(10)
      Else
         cMsgLog := "A origem "+cOrig+" e destino "+cDest+" a ser excluída na via "+cCodVia+" possui vínculo com "+aAliasECpo[i][6]+":"+CHR(13)+CHR(10)
      EndIf
      cMsgLog += "Cod: "+WKOCVIA->&(aAliasECpo[i][5])+CHR(13)+CHR(10)
      cMsgLog += "Por este motivo a mesma não poderá ser excluída!"       
      
      If Select("WKOCVIA") <> 0
         WKOCVIA->(DbCloseArea())
      EndIf 
      
      EXIT
   EndIF
   cQuery := ""
   If Select("WKOCVIA") <> 0
      WKOCVIA->(DbCloseArea())
   EndIf
   i++   
EndDo

If lFound
   If !lMsgHelp
      AVGetSvLog(cTit,cMsgLog)
   Else
      EasyHelp(cMsgLog,cTit)
   EndIF
EndIf

DbSelectArea(nOldArea)
Return lRet

/*
Funcao      : CV100Filtro()
Parametros  : 
Retorno     :
Objetivos   : Filtrar a consulta padrão EY9, de acordo com o módulo e campo que chamou a execução
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 31/05/2017
Revisao     :
Obs.        :
*/
Function CV100Filtro(cCampo)
Local cRet:= ""

Begin Sequence

   Do Case
      Case cCampo == "W2_ORIGEM"
         If IsInCallStack("SI410GERPO")
            cRet:= 'SYR->YR_VIA == mv_par09 .And. !Empty(SYR->YR_PAIS_OR)'
         Else
            cRet:= 'SYR->YR_VIA == M->W2_TIPO_EM .And. !Empty(SYR->YR_PAIS_OR)'
         EndIf
         If cPaisLoc == "BRA"
            cRet:= cRet + ' .And. SYR->YR_PAIS_OR <> "105" .And. (Empty(SYR->YR_PAIS_DE) .Or. SYR->YR_PAIS_DE == "105")'
         EndIf
      
      Case cCampo == "W2_DEST"
          If IsInCallStack("SI410GERPO")
            cRet:= 'SYR->YR_VIA == mv_par09 .AND. SYR->YR_ORIGEM == mv_par10'
         Else
            cRet:= 'SYR->YR_VIA == M->W2_TIPO_EM .AND. SYR->YR_ORIGEM == M->W2_ORIGEM'
         EndIf
         If cPaisLoc == "BRA"   
            cRet:= cRet + ' .And. (Empty(SYR->YR_PAIS_DE) .Or. SYR->YR_PAIS_DE == "105")'
         EndIf

   EndCase

End Sequence
Return cRet
*---------------------------------------------------------------------------*
*   FIM DO PROGRAMA EICCV100.PRW                                            *
*---------------------------------------------------------------------------*
