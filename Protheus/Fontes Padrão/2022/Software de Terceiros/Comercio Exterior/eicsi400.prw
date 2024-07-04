#INCLUDE "Eicsi400.ch"
#include "Average.ch"
#include "AvPrint.ch"
#include "PROTHEUS.ch"
/*#include "FiveWin.ch"
#include "constant.ch"*/

/* AAF 17/09/2014 - Esse return causa erro no menu funcional.
#COMMAND E_RESET_AREA => SW3->(DBSETORDER(1)); SA5->(DBSETORDER(1));
                       ; Work1->(E_EraseArq(cNomArq));
                       ; Work2->(E_EraseArq(cNomArq2));
                       ; DBSELECTAREA("SW0")
*/

#define SEM_KIT "1"
#define COM_KIT "2"

#xTranslate Alert(<uPar1>[,<uPar2>]) => if(isBlind(),Help("",1,"AVG",<uPar2>,<uPar1>,1,0,.F.),ApMsgStop(<uPar1>,<uPar2>))
#xTranslate MsgStop(<uPar1>[,<uPar2>]) => if(isBlind(),Help("",1,"AVG",<uPar2>,<uPar1>,1,0,.F.),ApMsgStop(<uPar1>,<uPar2>))
#xTranslate MsgInfo(<uPar1>[,<uPar2>]) => if(isBlind(),Help("",1,"AVG",<uPar2>,<uPar1>,1,0,.F.),ApMsgInfo(<uPar1>,<uPar2>))

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ EICSI400 ≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 13/07/96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Programa de Manutencao da Solicitacao de Importacao        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
	Last change:  US   23 Nov 99   11:30 am
*/

Function EICSI400(aCabAu,aItemAu,nOpcAu,aELDau,aSYSau)
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Define Variaveis                                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
LOCAL i:=1
LOCAL nOldArea:=SELECT(), aSemSX3:={}
Local aOrd := {}
Local lRet:= .T.
Private oBufferUM:= tHashMap():New() //bufferizaÁ„o da busca pela unidade de medida
Private lIntLogix := AvFlags("EIC_EAI")//EasyGParam("MV_EIC_EAI",,.F.) //Jacomo Lisa - 06/05/2014

Private lIntegra:=if(valtype(EasyGParam("MV_EECFAT"))=="L",EasyGParam("MV_EECFAT"),.F.), cNomArq
Private cNomArqR//Para rdmakes
/* ISS - 19/11/10 - Alterada a os campos da SW0 para SW1, pois na funÁ„o FillGetDb ser· comparado
                    o cSeek (que usa os dados da SW0) com os dados deste code block */
Private cSeek, bSW0While := {|| xFilial("SW1")+ SW1->W1_CC+ SW1->W1_SI_NUM }
Private lGetdb:= .F.

//ExecAuto na SI
Private lSIAuto := ( aCabAu <> NIL ) .And. ( aItemAu <> NIL )
Private nOpcAuto:= nOpcAu
Private aCabAuto:= aCabAu
Private aCabItem:= aItemAu
Private aCabELD := aELDau
Private aCabSYS := aSYSau
Private lAltSYS := .F.
Private lVldSaldo := .T. //RMD - 28/09/16 - Permite desabilitar a validaÁ„o via ponto de entrada.
//Flag para buffer do avsx3()
AvlSX3Buffer(lIntLogix)
//Tratamento especÌfico para manter arquivos de trabalho - Vide EECAE109.
Private __KeepUsrFiles

IF lIntLogix .AND. !lSIAuto
   EICSI410()
   RETURN lRet
ENDIF

IF ! AmIin(17)
   Help("", 1, "AVG0000404")//MsgStop(STR0001,STR0002) //"FunÁ„o n„o autorizada para este mÛdulo !"###"Aviso"
   Return NIL
Endif

If lSiAuto
   If SW0->(FieldPos("W0_SIAUTO")) == 0
      EasyHelp(STR0180,STR0002) //STR0180 "Rotina n„o est· preparada para utilizacao de ExecAuto. Favor contatar o suporte da Trade-Easy" //STR0002 "Aviso"
      Return Nil
   Endif
Endif

PRIVATE aRotina := MenuDef()

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Define o cabecalho da tela de atualizacoes                   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
PRIVATE cCadastro := STR0009 //"SolicitaÁ„o de ImportaÁ„o"
PRIVATE cTitulo   := STR0010, lTemItens:=.F. //"Itens da SI"
PRIVATE cTitNac   := STR0140 // "SolicitaÁ„o de NacionalizaÁ„o - DA:

PRIVATE lComEdit  := GetNewPar("MV_MESI",.T.)    //CDS 23/08/04 Edicao com MsGetDB=.T. por default, .F.=MsSelect

PRIVATE lCopiaSI :=.F.	//CDS 23/08/04  A primeira vez no MsGetDb (Modo Inclusao)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria Variaveis com nome dos campos de Bancos de Dados        ≥
//≥ para serem usadas na funcao de inclusao                      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
PRIVATE aHeader[0],aCampos:=ARRAY(SW3->(FCOUNT()))//E_CriaTrab utiliza

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria variavel indicando se o cliente usa ForeCast            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Private lForeCast := (AllTrim(EasyGParam("MV_FORECAS"))$cSim)
Private nLenReduz := AVSX3("A2_NREDUZ",3) //SO.:0026 OS.:0250/02 FCD
Private nLenForn  := AVSX3("A2_COD",3)//SO.:0026 OS.:0250/02 FCD

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria variaveis para UNISYS; Solicitacao: 0162/99             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Private lUnisys:=EasyEntryPoint("IC159SI0"), aMemos:={}//AWR 15/07/1999

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria variaveis para HUNTER; Solicitacao: 0037/00             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Private lHunter:=EasyEntryPoint("IC010PO1")

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria variaveis da funcao MSSELECT                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*Revis„o : 21/Julho/2009                                                                                                  //
//*Autor   : Caio CÈsar Henrique                                                                                            //
//*Objetivo: Inclus„o do bot„o "Ordena Itens", cuja finalidade ser· organizar os itens por cÛdigo ou por posÌÁ„o (inclus„o).//
//         : Inclus„o do campo W1_POSIT para gravaÁ„o da posiÁ„o do Item                                                    //
//         : ValidaÁıes gerais                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Private oMSSelect,cArqRdmake:="EICSINEC"
Private lInverte := .F., cMarca := GetMark(), lFilDa:=EasyGParam("MV_FIL_DA")
Private _PictPrTot := ALLTRIM(X3Picture("W2_FOB_TOT"))
Private aCamposSI :=;
      {{{||TRB->W1_COD_I}  , "", STR0011,AVSX3("W1_COD_I")[6]},;    //"Codigo do Item"
       {{||TRB->W1_COD_DES}, "", AVSX3("W1_COD_DES",5)},;           //"Descr. do Item"
       {{||TRB->W1_FABR }  , "", STR0012    },;                     //"Fabricante"
       {{||TRB->W1_FORN }  , "", STR0013    },;                     //"Fornecedor"
       {{||SI400BuscaPN(TRB->W1_COD_I,TRB->W1_FORN,TRB->W1_FABR,If(SW1->(FIELDPOS("W1_FORLOJ")) # 0,TRB->W1_FORLOJ,""),If(SW1->(FIELDPOS("W1_FABLOJ")) # 0,TRB->W1_FABLOJ,""))},;
                             "", STR0014   },;                      //"Part Number"
       {{||SI400Tabela("Y1",TRB->W1_CLASS)}, "", STR0015      },;   //"Classificac."
       {{||TRB->W1_QTDE }  , "", STR0016 ,AVSX3("W1_QTDE")[6]   },; //"Quantidade"
       {{||TRB->W1_SALDO_Q}, "", STR0017 ,AVSX3("W1_SALDO_Q")[6]},; //"Saldo Qtde"
       {{||TRB->W1_PRECO}  , "", STR0018,AVSX3("W1_PRECO")[6]  },;  //"PreÁo Unit."
       {{||TRB->W1_DT_EMB} , "", STR0019  },;                       //"Data Embarq."
       {{||TRB->W1_DTENTR_}, "", STR0020  }}                        //"Dt. Entrega"

EICAddLoja(aCamposSI, "W1_FORLOJ", "TRB", STR0013)
EICAddLoja(aCamposSI, "W1_FABLOJ", "TRB", STR0012)

CHKFILE("ELD") //NCF - 01/11/2016 - Carrega para n„o gerar erro na rotina de visualizaÁ„o apÛs receber Ordem por integraÁ„o EAI.

IF SW1->(FIELDPOS("W1_POSIT")) # 0  //CCH - 06/08/09 - Inclus„o da posiÁ„o do item na S.I.
   AADD(aCamposSI,Nil)
   AINS(aCamposSI,1)
   aCamposSI[1] := {{||TRB->W1_POSIT},"",AVSX3("W1_POSIT",5)}
EndIf

Private lCpoCCusto := (EasyGParam("MV_EASY")$cSim) .And. SW1->(FIELDPOS("W1_CTCUSTO")) > 0 // NCF - 22/06/2010 - Flag do campo de Centro de Custo
IF lCpoCCusto
   aAdd(aCamposSI,{{||TRB->W1_CTCUSTO},"",AVSX3("W1_CTCUSTO",5)})
ENDIF

IF cPaisLoc # "BRA"  .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
   AADD(aCamposSI,{ {||TRB->W1_NATUREZ} , "", AVSX3("W1_NATUREZ",5) } )
ENDIF

IF EasyEntryPoint(cArqRdmake)
   PSI     :=""
   nRecSY3 := 1
   nExecute:="1"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

PRIVATE aRdCores := {}//VAI SER INICIALIZADO NO PONTO DE ENTRADA   igorchiba    13/01/2008

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"1")
ENDIF

__KeepUsrFiles:= SaveTempFiles() //Tratamento especÌfico para manter arquivos de trabalho - Vide EECAE109.

IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"1"),)
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"1"),)

IF lForeCast
   AADD(aCamposSI,{{||IF(TRB->W1_FORECAS$cSim,STR0021,STR0022)},"",STR0023}) //"Sim"###"Nao"###"Forecast"
ENDIF

// BAK - CriaÁao do campo W1_CODMAT para apresentar na MsSelect, codigo da Matriz de TributaÁ„o
If SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   aAdd(aCamposSI,{{||TRB->W1_CODMAT},"",AVSX3("W1_CODMAT",5)})
EndIf

aCamposSI:= AddCpoUser(aCamposSI,"SW1","5","TRB")

AADD(aSemSX3,{ "W2_PO_DT" , "D" , 8, 0})
AADD(aSemSX3,{ "W2_MOEDA" , "C" , 3, 0})
AADD(aSemSX3,{ "A2_NREDUZ", "C" ,20, 0})
AADD(aSemSX3,{ "WK_UNI"   , "C" , LEN(SB1->B1_UM), 0})
AADD(aSemSX3,{ "W3_PR_TOT", "N" ,16, 2})
AADD(aSemSX3,{ "W1_QTDE"  , "N" ,AVSX3("W1_QTDE",3),AVSX3("W1_QTDE",4)})

IF lForeCast
   AADD(aSemSX3,{"W1_FORECAS","C",1, 0})
ENDIF

// BAK - CriaÁao do campo W1_CODMAT codigo da Matriz de TributaÁ„o na work
If SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   aAdd(aSemSX3,{"W1_CODMAT",AVSX3("W1_CODMAT",AV_TIPO),AVSX3("W1_CODMAT",AV_TAMANHO),AVSX3("W1_CODMAT",AV_DECIMAL)})
EndIf

AADD(aSemSX3,{"W1_REC_B1","N",10,0})
AADD(aSemSX3,{"W1_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(aSemSX3,{"W1_REC_WT","N",10,0})

If Select("Work1") # 0
   Work1->(DbCloseArea())
EndIf

/* wfs mar/2017 - adequaÁ„o para uso do EECCRIATRAB(), com a passagem do 7∫ par‚metro */
cNomArq:=E_CriaTrab("SW3",aSemSX3,"Work1",,,, SaveTempFiles())

IF !USED()
   Help("", 1, "AVG0000528")//MsgiNFO(OemtoAnsi(STR0024)) //"N∆o foi poss°vel abrir o arquivo tempor†rio"
   DBSELECTAREA("SW0")
   RETURN NIL
ENDIF

/* wfs mar/2017 - adequaÁ„o para uso do EECIndRequa */
E_IndRegua("Work1",cNomArq+TEOrdBagExt(),"W3_COD_I+DTOS(W2_PO_DT)+W3_PO_NUM")

SET INDEX TO (cNomArq+TEOrdBagExt())

cNomArq2:=E_Create(,.F.)

DBSELECTAREA("Work1")

If Select("Work2") # 0
   Work2->(DbCloseArea())
EndIf

TETempBackup("Work2") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   Help("", 1, "AVG0000528")//MsgiNFO(OemtoAnsi(STR0024)) //"N∆o foi poss°vel abrir o arquivo tempor†rio"
   Work1->(E_EraseArq(cNomArq,,, SaveTempFiles())) /* wfs mar/2017 - adequaÁ„o para uso do EECEraseArq(), com a passagem do 4∫ par‚metro */
   DBSELECTAREA("SW0")
   RETURN NIL
ENDIF

IndRegua("Work2",cNomArq2+TEOrdBagExt(),"W3_CC+W3_SI_NUM+W3_COD_I+STR(W3_REG,"+Alltrim(STR(AVSX3("W3_REG",3)))+",0)+STR(W3_SEQ,2,0)")

SET INDEX TO (cNomArq2+TEOrdBagExt())

DbSelectArea("SW0")

PRIVATE aPos := { 15,  1, 75, 315 }

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria variaveis da funcao ENCHOICE                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//PRIVATE lKit := ! Empty(SW0->W0_SIKIT) //JMS 28/06/04 O SW0 NAO ESTA POSICIONADO!!!!
PRIVATE aSW0 := {"W0__CC","W0__CCDESC","W0__NUM","W0__DT","W0__POLE",;
                 "W0__POLEDE", "W0_COMPRA", "W0_COMPRAN", "W0_MOEDA",;
                 "W0_C1_NUM", "W0_SOLIC"}


RestOrd(aOrd,.T.)

EICSI400FIL(.T.)

If !lSIAuto
   //DFS - 18/01/13 - Inclus„o de tratamento para visualizar a SI dentro da rotina de PO.
   If ValType(nOpcAuto) == "N"
      Eval(&("{|| "+aRotina[nOpcAuto][2]+"('SW0',SW0->(RecNo()),"+Str(nOpcAuto)+")}"))
   Else
      mBrowse(6,1,22,75,"SW0",,,,,,aRdCores)
   EndIf
Else
   Default nOpcAuto := 3
   MBrowseAuto(nOpcAuto,aCabAuto,"SW0",,.T.)
Endif

EICSI400FIL(.F.)

If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"DEPOIS_MBROWSE"),)

SW3->(DBSETORDER(1))
SA5->(DBSETORDER(1))
Work1->(E_EraseArq(cNomArq,,, SaveTempFiles())) /* wfs mar/2017 - adequaÁ„o para uso do EECEraseArq(), com a passagem do 4∫ par‚metro */
Work2->(E_EraseArq(cNomArq2))

dbSelectArea("SW0")

//desativa flag de uso do buffer do avsx3
AvlSX3Buffer(.F.)

Return lRet


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 25/01/07 - 13:40
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0003       ,"AxPesqui"   , 0 , 1     },; //"Pesquisar"
                    { STR0004       ,"SI400Visual", 0 , 2     },; //"Visual"
                    { STR0005       ,"SI400Inclui", 0 , 3     },; //"Inclui"
                    { STR0006       ,"SI400Altera", 0 , 4     },; //"Altera"
                    { STR0007       ,"SI400Exclui", 0 , 2     },; //"Exclui"
                    { STR0169       ,"MsDocument" , 0 , 4     },; //STR0169 = "Conhecimento" //"Conhecimento" - TDF - 14/06/10
                    { STR0008       ,"SI400Relat" , 0 , 6     } } //"Relatorio

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"AROTINA")
ENDIF

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("ISI400MNU")
	aRotAdic := ExecBlock("ISI400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SI400Visua≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 12.07.96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Programa para visualizacao dos Itens da SI                 ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe e ≥ Void SI400Visual(ExpC1,ExpN1)                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Alias do arquivo                                   ≥±±
±±≥          ≥ ExpN1 = Numero do registro                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function SI400Visual(cAlias,nReg,nOpc)
LOCAL cAlias1:="SW1"
LOCAL nRecno,nMeio:=0, i
Local oDlg, oEnch1 // FSM - 21/07/2011
Local aCposVis := {} //THTS - 06/10/2017
//Private oDlg FSM - 21/07/2011
PRIVATE cNomArq
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta a entrada de dados do arquivo                          ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
PRIVATE aTELA[0][0],aGETS[0],lInclui := .F., aCpos
aHeader := Array(0)
//JMS 28/06/04
PRIVATE lKit := ! Empty(SW0->W0_SIKIT) .AND. IF(EasyGParam("MV_KIT")$ cSim,.T.,.F.)
PRIVATE aSW0 := {"W0__CC","W0__CCDESC","W0__NUM","W0__DT","W0__POLE",;
                 "W0__POLEDE", "W0_COMPRA", "W0_COMPRAN", "W0_MOEDA",;
                 "W0_C1_NUM", "W0_SOLIC"}

If Type("lSIAuto") == "U"
   lSIAuto:= .F.
EndIf

IF lKit // Manutencao de SI com Kit
   aAdd(aSW0, "W0_SIKIT")
   aAdd(aSW0, "W0_KITSERI")
   aAdd(aSW0, "W0_FORN")
   IF EICLOJA()
      aAdd(aSW0, "W0_FORLOJ")
   ENDIF
   aAdd(aSW0, "W0_FORNDES")
   aAdd(aSW0, "W0_QTDE")
   aAdd(aSW0, "W0_DT_NEC")
   aAdd(aSW0, "W0_DT_EMB")
   aAdd(aSW0, "W0_CLASKIT")
Endif

If SW0->(FIELDPOS("W0_SIAUTO")) # 0
   aAdd(aSW0, "W0_SIAUTO")
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Salva a integridade dos campos de Bancos de Dados            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT i

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Array com os campos do arquivo de Trabalho                   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aCpos := {"W1_COD_I","W1_COD_DES","W1_FABR","W1_FORN","W1_CLASS",;
          "W1_QTDE" ,"W1_SALDO_Q","W1_PRECO",;
          "W1_DT_EMB","W1_DTENTR_"}

EICAddLoja(aCpos, "W1_FORLOJ", Nil, "W1_FORN")
EICAddLoja(aCpos, "W1_FABLOJ", Nil, "W1_FABR")
//NCF - 22/06/2010
If lCpoCCusto
   aAdd(aCpos,"W1_CTCUSTO")
EndIf

IF SW1->(FIELDPOS("W1_POSIT")) # 0
   AADD(aCpos,Nil)
   AINS(aCpos,1)
   aCpos[1] := "W1_POSIT"
ENDIF

// SI400 Campos para a Estrutura                               -    JBS 06/10/2003
nPontoEntrada :=1
IF cPaisLoc # "BRA" .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
    AADD(aCpos,"W1_NATUREZ")
ENDIF

IF EasyEntryPoint(cArqRdmake)
   nExecute:="2"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ALTERA_CAMPOS")
ENDIF

IF lForeCast
   AADD(aCpos,"W1_FORECAS")
ENDIF

// BAK - ApresentaÁao do campo do codigo da matriz de tributaÁao - "W1_CODMAT"
If SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   AADD(aCpos,"W1_CODMAT")
EndIf

IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"2"),)
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"2"),)

//TRP-14/05/07-Inclus„o de campos incluidos pelo configurador e que forem usados, no array da enchoice.
//SX3->(DbSetOrder(1))
//SX3->(dbSeek("SW1"))


   //While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW1"
      //If SX3->X3_PROPRI=="U" .AND. Ascan(aCpos,ALLTRIM(SX3->X3_CAMPO))==0 .AND. X3Uso(SX3->X3_USADO)
         //aAdd(aCpos,AllTrim(SX3->X3_CAMPO))
      //EndIF
      //SX3->(dbSkip())
   //Enddo

//aCpos:= AddCpoUser(aCpos,"SW1","1")  // TRP - 21/03/2013

aCampos := CriaEstru(aCpos,@aHeader)
AADD(aCampos,{"SALDO","N",AVSX3("W1_SALDO_Q",3),AVSX3("W1_SALDO_Q",4)})
AADD(aCampos,{"QTDE","N",AVSX3("W1_QTDE",3),AVSX3("W1_QTDE",4)})
AADD(aCampos,{"RECNO","N",7,0})
AADD(aCampos,{"W1_SEQ","N",1,0})
AADD(aCampos,{"W1_REG","N",AVSX3("W1_REG",3),0})
AADD(aCampos,{"W1_REC_B1","N",10,0})
AADD(aCampos,{"W1_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(aCampos,{"W1_REC_WT","N",10,0})

aCampos := AddWkCpoUser(aCampos,"SW1")

//aCampos[4][3] := 10   //SVG - 18/09/08                           // Para colocar a Descricao no SX5

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria arquivo de trabalho                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ACPOS3")
Endif
//THTS - 06/10/2017 - o aCampos precisou ser clonado para passar para a funcao E_CriaTrab, pois a mesma utiliza um array aCampos com estrutura diferente
aCposVis := aClone(aCampos)
aCampos  := {}

cNomArq := E_CriaTrab(,aCposVis,"TRB") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("TRB",cNomArq+TEOrdBagExt(),"W1_COD_I+STR(W1_REG,"+Alltrim(STR(AVSX3("W1_REG",3)))+",0)")

//** JVR - 27/11/2009
If SW1->(FieldPos("W1_POSIT")) > 0
   cNomArq2 := CriaTrab(,.F.)
   IndRegua("TRB",cNomArq2+TEOrdBagExt(),"W1_POSIT")
   TRB->(dbSetIndex(cNomArq+TEOrdBagExt()),dbSetIndex(cNomArq2+TEOrdBagExt()))
   TRB->(dbSetOrder(1))
EndIf

//**

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Atualiza o arquivo de Trabalho com os dados                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !lSIAuto
   MsAguarde({||lTemItens:=SI400GrTRB(,nOpc)},STR0025+ALLTRIM(SW0->W0__NUM)) //"Lendo Itens da S.I.: "
Else
   lTemItens:=SI400GrTRB(,nOpc)
Endif

If ! lTemItens
   Help(" ",1,"EICSEMITEM")
   TRB->(E_EraseArq(cNomArq))
   DBSELECTAREA("SW0")
   Return .T.
Endif

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ANTES_TELA_VISUAL")
Endif

While .T.
   nOpca:=0
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE IF(!Empty(M->W0_HAWB_DA),cTitNac+AllTrim(Transf(M->W0_HAWB_DA,AVSX3("W6_HAWB",6))),cTitulo+If(lKit,STR0026,STR0027)) ; //" com Kit"###" Normal"
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL
   nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
   oEnch1 := MsMGet():New( cAlias, nReg, nOpc, , , , aSW0 , { 15,  1, nMeio-1 , (oDlg:nClientWidth-4)/2 }, , 3)
   dbSelectArea("TRB")
   dbGoTop()
   lRefresh:=.T.
   oMSSelect:= MsSelect():New("TRB",,,aCamposSI,@lInverte,@cMarca,{nMeio,1,If(SetMdiChild(),(oDlg:nClientHeight+82)/2,(oDlg:nClientHeight-6)/2),(oDlg:nClientWidth-4)/2})//LRL 11/03/04 - para Modulo MDI o Tamanho da janela È diferente

   oMSSelect:oBrowse:bWhen:={||(dbSelectArea("TRB"),.t.)}

   oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMSSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oMSSelect:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   oDlg:lMaximized:=.T. // NCF - 19/09/2019
   //DFS - 04/02/13 - Inclus„o de refresh na tela
   ACTIVATE MSDIALOG oDlg ON INIT;
                     (enchoicebar(oDlg,{||nOpca:=0,oDlg:End()},;
                                       {||nOpca:=0,oDlg:End()},,SI400BarItem(oDlg,,,nOpc)),oMSSelect:oBrowse:Refresh()) //FSM - 21/07/2011 // ACSJ - 12/04/2004 //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF nOpca == 4
      nRecno:=TRB->(RECNO())
      Si400Historico(TRB->W1_COD_I,.F.)
      TRB->(DBGOTO(nRecno))
      aTela := {}
      aGets := {}
      LOOP

   ELSEIF nOpca == 5
      nRecno:=TRB->(RECNO())
      Si400Historico(TRB->W1_COD_I,.T.)
      TRB->(DBGOTO(nRecno))
      aTela := {}
      aGets := {}
      LOOP
   ENDIF
   Exit
End
TRB->(E_EraseArq(cNomArq))
DBSELECTAREA("SW0")

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"FIM_VISUAL")
ENDIF
Return( nOpc )
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SI400Inclu≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 13.07.96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Programa exclusivo para inclusao de S.I.                   ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe e ≥ Void SI400Inclui(ExpC1,ExpN1)                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Alias do arquivo                                   ≥±±
±±≥          ≥ ExpN1 = Numero do registro                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function SI400Inclui(cAlias,nReg,nOpc)
LOCAL aSemSx3:={}, i
LOCAL cAlias1:="SW1"
LOCAL cKit := IIF(EasyGParam("MV_KIT") $ cSim .AND. !lSIAuto,SIcomKit(),SEM_KIT) //LRS - 28/03/2018 - N„o abrir a tela de KIT se for rotina automatica
//Local aButtons
LOCAL bAlterar := {|| cManut := "A", oDlg:End() }
LOCAL bIncluir := {|| cManut := "I", oDlg:End() }
LOCAL bExcluir := {|| cManut := "E", oDlg:End() }
Local lRet:= .T.
LOCAL bCopiar  := {|| cManut := "C", oDlg:End() }
LOCAL bSWitch  := {|| cManut := "S", oDlg:End() }
Local oDlg,oEnch1,oPanel

LOCAL cOldF11:=SetKey(VK_F11)
Local bOk:={||nOpcA:=1,IF(EICSI400SEEK().and.SI400Check(lKit),oDlg:End(),nOpca:=3)}
Local bCancel:= {||nOpca:=3,oDlg:End()}
PRIVATE cNomArq
PRIVATE lKit := (cKit == COM_KIT), nMeio:=0
Private aButtons
lCopiaSI := .F.       //A primeira Vez, inclui registro branco.   //CDS


EICSI400FIL(.F.)  // Para valida se j· existe a SI de nacionalizaÁ„o

IF cKit != COM_KIT .And. cKit != SEM_KIT
   EICSI400FIL(.T.)
   Return (nOpc)
Endif

IF EasyEntryPoint(cArqRdmake)
   nExecute:="6"
   IF !ExecBlock(cArqRdmake,.F.,.F.)
      EICSI400FIL(.T.)
      RETURN (nOpc)
   ENDIF
ENDIF

IF EasyEntryPoint("EICPSI01")
   IF !ExecBlock("EICPSI01",.F.,.F.,"6")
      EICSI400FIL(.T.)
      RETURN(nOpc)
   ENDIF
ENDIF

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta a entrada de dados do arquivo                          ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE lInclui:=.T.
aHeader := Array(0)

Private aSI400Del :=  {}//, aSI400Reg - FSM - 01/08/2011
Private cManut := ""
Private lloop:=.T. //TDF - 22/11/11 - Para ponto de entrada

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria variaveis da funcao ENCHOICE                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
PRIVATE aSW0 := {"W0__CC","W0__CCDESC","W0__NUM","W0__DT","W0__POLE",;
                 "W0__POLEDE", "W0_COMPRA", "W0_COMPRAN", "W0_MOEDA",;
                 "W0_C1_NUM", "W0_SOLIC"}

If Type("lSIAuto") == "U"
   lSIAuto:= .F.
EndIf

IF lKit // Manutencao de SI com Kit
   aAdd(aSW0, "W0_SIKIT")
   aAdd(aSW0, "W0_KITSERI")
   aAdd(aSW0, "W0_FORN")
   IF EICLOJA()
      aAdd(aSW0, "W0_FORLOJ")
   ENDIF
   aAdd(aSW0, "W0_FORNDES")
   aAdd(aSW0, "W0_QTDE")
   aAdd(aSW0, "W0_DT_NEC")
   aAdd(aSW0, "W0_DT_EMB")
   aAdd(aSW0, "W0_CLASKIT")
Endif

If SW0->(FIELDPOS("W0_SIAUTO")) # 0
   aAdd(aSW0, "W0_SIAUTO")
Endif

//aAdd(aSW0, "W0_REFER1")     - Gustavo

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Salva a integridade dos campos de Bancos de Dados            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea(cAlias)
FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
NEXT i
M->W1_CLASS := "1"+Space(5)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Array com os campos do arquivo de Trabalho                   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aCpos := {"W1_COD_I","W1_COD_DES","W1_FABR","W1_FORN","W1_CLASS",;
          "W1_QTDE" ,"W1_SALDO_Q","W1_PRECO",;
          "W1_DT_EMB","W1_DTENTR_"}

EICAddLoja(aCpos, "W1_FORLOJ", Nil, "W1_FORN")
EICAddLoja(aCpos, "W1_FABLOJ", Nil, "W1_FABR")
//NCF - 22/06/2010
If lCpoCCusto
   aAdd(aCpos,"W1_CTCUSTO")
EndIf
If AvFlags("EIC_EAI")
   aAdd(aCpos,"W1_C3_NUM")
   aAdd(aCpos,"W1_CONDPG")
EndIf
IF SW1->(FIELDPOS("W1_POSIT")) # 0
   AADD(aCpos,Nil)
   AINS(aCpos,1)
   aCpos[1] := "W1_POSIT"
ENDIF

aCpos := AddCpoUser(aCpos,"SW1","1")

If lSIAuto
   If SW0->(FIELDPOS("W0_SIAUTO")) # 0
      M->W0_SIAUTO:= "1"
   Endif
Endif

// SI400 Campos para a Estrutura                               -    JBS 06/10/2003
nPontoEntrada :=2
IF cPaisLoc # "BRA" .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
    AADD(aCpos,"W1_NATUREZ")
ENDIF

IF EasyEntryPoint(cArqRdmake)
   nExecute:="2"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ALTERA_CAMPOS")
ENDIF

IF lForeCast
   AADD(aCpos,"W1_FORECAS")
ENDIF

// BAK - ApresentaÁao do campo do codigo da matriz de tributaÁao - "W1_CODMAT"
If SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   AADD(aCpos,"W1_CODMAT")
EndIf

IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"2"),)
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"2"),)
lGetdb:= lComEdit

aYesHeader:=   { "W1_COD_I" ,;
                  "W1_COD_DES",;
                  "W1_FABR" ,;
                  "W1_FORN" ,;
                  "W1_CLASS" ,;
                  "W1_QTDE" ,;
                  "W1_SALDO_Q",;
                  "W1_PRECO",;
                  "W1_DT_EMB",;
                  "W1_DTENTR_"}
If lCpoCCusto                      //NCF - 22/06/2010
   aAdd(aYesHeader,"W1_CTCUSTO")
EndIf
aCpoVirtual :=  {"W1_COD_DES"}

EICAddLoja(aYesHeader, "W1_FABLOJ", Nil, "W1_FABR")
EICAddLoja(aYesHeader, "W1_FORLOJ", Nil, "W1_FORN")

If SW1->(FieldPos("W1_POSIT")) # 0
   Aadd(aYesHeader,Nil)
   AIns(aYesHeader,1)
   aYesHeader[1] := "W1_POSIT"
EndIf

// BAK - ApresentaÁao do campo do codigo da matriz de tributaÁao - "W1_CODMAT"
If SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   aAdd(aYesHeader, "W1_CODMAT")
EndIf

aYesHeader  := AddCpoUser(aYesHeader,"SW1","3")
//DFS - 23/08/11 - Inclus„o de tratamento para que, quando incluir campos de usu·rio do tipo virtual, sistema n„o apresente error.log
aCpoVirtual := AddCpoUser(aCpoVirtual,"SW1","1")

cSeek := Space(100)
bRecSemX3 := {|| M->QTDE:=SW1->W1_QTDE, M->SALDO:= SW1->W1_SALDO_Q ,M->RECNO := SW1->(Recno()), M->W1_REC_B1:=0 , .T.}
FillGetDB(nOpc, "SW1", "TRB1",,1, cSeek, /*bSW0While*/{|| Space(100) },,/*aNoFields*/,/*aYesFields*/;
            ,,,,ExcHeader(aYesHeader, "SW1"),.T. /*lInclui*/,,aCpoVirtual; //ISS - 19/11/10 - Na inclus„o a flag lInclui sempre ser· .T.
            ,{|a, b| AddSemSx3(@b) }, , bRecSemX3)//JVR - 12/02/10 - Inserido o parametro 15 (tratamento de lGetDb)
cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
//cNomArq := AvTrabName("TRB")

// EJA - 23/07/2019 - AvZap removido por causa do Oracle Database.
//AvZap("TRB1")

dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"W1_COD_I+STR(W1_REG,"+Alltrim(Str(AVSX3("W1_REG",3)))+",0)")

// ** JVR - 27/11/2009
If SW1->(FieldPos("W1_POSIT")) > 0
   cNomArq2 := CriaTrab(,.F.)
   IndRegua("TRB",cNomArq2+TEOrdBagExt(),"W1_POSIT")
   TRB->(dbSetIndex(cNomArq+TEOrdBagExt()),dbSetIndex(cNomArq2+TEOrdBagExt()))
   TRB->(dbSetOrder(1))
EndIf
TERestBackup("TRB1")
TRB1->(dbCloseArea())
// **

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ANTES_TELA_INCLUI")
Endif

TRB->(dbGoTop())

WHILE .T.
//TDF - 22/11/11
   aTELA:={}
   aGETS:={}

   aButtons:=SI400BarItem(oDlg,,,nOpc)

   If nOpc <> EXCLUIR
      Aadd(aButtons,{"POSCLI",{||nOpca:=4,oDlg:End()},STR0081})

      IF !lInclui
         Aadd(aButtons,{"RELATORIO",{||nOpca:=5,oDlg:End()},STR0082})
      ENDIF

   EndIf

   IF nOpc # 2
      IF nOpc == 3
         Aadd(aButtons,{"S4WB005N",bCopiar,STR0162})
      ENDIF
      If !lComEdit
         Aadd(aButtons,{"EDIT",bIncluir ,STR0083})
         Aadd(aButtons,{"IC_17",bAlterar ,STR0085})
         Aadd(aButtons,{"EXCLUIR",bExcluir ,STR0084})
      EndIf
      Aadd(aButtons,{"RECALC",bSWitch ,STR0163})
      SETKEY(VK_F11,bSwitch)
   ENDIF

	IF EasyEntryPoint("EICSI400")
	   ExecBlock("EICSI400",.F.,.F.,"ANTES_TELA_INCLUI")
	Endif

   If !lSIAuto

      nOpca  := 3
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE cTitulo+If(lKit,STR0026,STR0027) ; //" com Kit"###" Normal"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	        OF oMainWnd PIXEL

         oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, aPos[4], aPos[3])
         oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

         nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
         oEnch1 := MsMGet():New( cAlias, nReg, nOpc,,,, aSW0, { 15,  1, nMeio-1, (oDlg:nClientWidth-4)/2 },, 3,,,, oPanel)

         dbSelectArea("TRB")

         If lComEdit
            // CDS 23/08/04
            TRB->(DBSetorder(0))
            TRB->(DBGotop())
            //TDF - 22/11/11
            If TRB->(Eof())
               lCopiaSI:= .T.
            Else
               lCopiaSI:= .F.
            Endif
            oMSSelect := MsGetDB():New(100,1,190,317,nOPC,"U_EILinok","U_EILinok",,.T.,aCpos,,.F.,,"TRB",,,lCopiaSI, oPanel,,,"U_SI400ApagaReg")
         ELSE
            oMSSelect:= MsSelect():New("TRB",,,aCamposSI,@lInverte,@cMarca,{nMeio,1,If(SetMdiChild(),(oDlg:nClientHeight+82)/2,(oDlg:nClientHeight-6)/2),(oDlg:nClientWidth-4)/2},,, oPanel)//LRL 11/03/04
            oMSSelect:oBrowse:bWhen:={||(dbSelectArea("TRB"),.t.)}
            oMSSelect:bAval := {|| cManut := "A",oDlg:End() }
         Endif

         cManut := ""

         oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	     oMSSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	     oMSSelect:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oDlg:lMaximized:=.T. // NCF - 19/09/2019
         //DFS - 04/02/13 - Inclus„o de refresh na tela
      ACTIVATE MSDIALOG oDlg ON INIT (ENCHOICEBAR( oDlg, bOk,bCancel,  ,aButtons),oMSSelect:oBrowse:Refresh())  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                                       // ACSJ - 12/04/2004
                     /*(SI400BarItem(oDlg,{||nOpcA:=1,IF(EICSI400SEEK().and.SI400Check(lKit),oDlg:End(),nOpca:=3)},;  // JBS - 27/12/2004, Inclui EICSI400SEEK() na CondiÁ„o.
                                       {||nOpca:=3,oDlg:End()},nOpc), ;*/
      lLoop:=.F.// TDF - 22/11/11
      If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"DEPOIS_TELA_INCLUI"),)
      IF lLoop
         LOOP
      ENDIF

      // Mudar modo de visualizacao
      If cManut="S"
         If Aviso(STR0163,STR0163,{STR0021,STR0022})=1
            LimpaOnSwitch(lComEdit)
            lComEdit := .NOT.(lComEdit)
            SetMV("MV_MESI",lComEdit)
         Endif
         aTela := {}
         aGets := {}
         lCopiaSI:=.F.
         Loop
      Endif

      If !Empty(cManut).and.cManut<>"S"

         If lComEdit
            IF cManut == "C"					//CDS 23/08/04
               SI400SelSI()
               lCopiaSi :=.F.
            Endif
         Else
            IF cManut == "C"
               SI400SelSI()
            Else
               SI400Manut(cManut)
            Endif
         Endif

         aTela := {}
         aGets := {}
         Loop
      Endif

   Else

      lComEdit:= .T.
      Private nBrLin:= 0
      If EnchAuto(cAlias,aCabAuto,{|| Obrigatorio(aGets,aTela) .AND. EICSI400SEEK() },nOpcAuto,aSW0) .And. SIAutoItens(aCabItem) //MsGetDBAuto("TRB",aCabItem,"U_EILinok",{|| U_EILinok() .AND. SI400Check(lKit) },aCabAuto,nOpcAuto)
         nOpcA := 1
      Else
         nOpcA := 3
         lRet:= .F.
         Exit
      Endif

   Endif



    IF nOpcA == 1 .AND. !InTransact()
         BEGIN Transaction
            SI400Grava(cAlias,cAlias1)
            IF __lSX8
               ConfirmSX8()
            ENDIF

            EvalTrigger()
         END Transaction
    ElseIf nOpcA == 1
         SI400Grava(cAlias,cAlias1)
         IF __lSX8
            ConfirmSX8()
         ENDIF

         EvalTrigger()
    ELSEIF nOpcA == 3
         IF __lSX8
            RollBackSX8()
         ENDIF

   ELSEIF nOpcA == 4
      nRecno:=TRB->(RECNO())
      Si400Historico(TRB->W1_COD_I,.F.)
      TRB->(DBGOTO(nRecno))
      aTela := {}
      aGets := {}
      LOOP

 ENDIF

 EXIT
ENDDO

SetKey(VK_F11,cOldF11)           //CDS

IF EasyEntryPoint(cArqRdmake)
   SY3->(DBGOTO(nRecSY3))
   SY3->(MSUNLOCK())
ENDIF
//TRB->(dbCloseArea())
TRB->(E_EraseArq(cNomArq,cNomArqR))
dbSelectArea(cAlias)
MsUnlock()
EICSI400FIL(.T.)
lGetdb:= .F.
Return (nOpc)

If lSIAuto .AND. Type("lPOAuto") <> "U" .AND. lPOAuto
   If lNotPOErroAuto
      lNotPOErroAuto:= lRet
   Endif
Endif

//Return (nOpc)
Return lRet //TRP - 23/05/2011

/*
Funcao      : Si400SelSi
Parametro   : nenhum
Retorno     : nenhum
Objetivos   : Copia dados de uma SI base
Autor       : Elizabete O. Silveira
Data        : 19/04/02
Revisao     : WFS - 01/06/12: opÁ„o pesquisar colocada nas AÁıes Relacionadas (identidade visual).
*/
Static FUNCTION Si400SelSI()
Local oDlg, oBrwCapa, oBtnPesq, bSelOk, bSelCancel, nSelOp, aOrd
Local nSelect := Select() //,aCpoSW0 := ArrayBrowse("SW0")
Local nRecSW0 := SW0->(RecNo())
LOCAL oPanel
Local aCpoSW0 := { {{||BuscaCCusto(SW0->W0__CC)}, "", STR0102 },;
                   {{||SW0->W0__NUM}, "" , STR0050 },;
                   {{||SW0->W0__DT }, "" , STR0051 },;
                   {{||IF(SY2->(dbSeek(xFilial()+SW0->W0__POLE)), SY2->Y2_DESC, "    ")},"", STR0052 },;
                   {{||IF(SY1->(dbSeek(xFilial()+SW0->W0_COMPRA)),SY1->Y1_NOME, "    ")},"", STR0053 } }

Local aButtons:= {}

PRIVATE lCapa := .T., lItens := .T.
Private cSIOldNum := M->W0__NUM

Begin Sequence

   IF ! SW0->(dbSeek(xFilial()))
      HELP(" ",1,"AVG0000622") //MsgStop("N„o existem registros para a visualizaÁ„o !","Aviso")
      Break
   Endif

   nSelOp := 0
   oMainWnd:ReadClientCoors()
   nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 8 )

   AAdd(aButtons,{"",{||AxPesqui("SW0",SW0->(RecNo()),1),oBrwCapa:oBrowse:Refresh()},STR0003})

   DEFINE MSDIALOG oDlg TITLE STR0050 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
          //oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          //OF oMainWnd PIXEL //"SeleÁ„o de Processos"
          

      oBrwCapa  := MsSelect():New("SW0",,,aCpoSW0,,,{nMeio,1,If(SetMdiChild(),(oDlg:nClientHeight+82)/2,(oDlg:nClientHeight-6)/2),(oDlg:nClientWidth-4)/2},;
                                  "xFilial('SW0')","xFilial('SW0')",,,,) //20/06/08 CCH - Par‚metro .T. removido da MSSELECT pois de acordo com a nova sintaxe, foi adicionado o 13∫ par‚metro e o mesmo recebe caractere, n„o booleano

      bSelOk     := {|| IF(!lCapa .And. !lItens, HELP(" ",1,"AVG0000643"),(nSelOp:= 1, oDlg:End())) }
      bSelCancel := {|| oDlg:End() }

      oBrwCapa:bAval := bSelOk

      @00,00 MsPanel oPanel Prompt "" Size 60,30 of oDlg // ACSJ - 12/04/2004

      @ 03, 05 TO 28, 100 LABEL STR0142 OF oPanel PIXEL //"Copiar:"

      @ 11, 10 CHECKBOX lCapa  PROMPT STR0143 SIZE 30,08 OF oPanel PIXEL FONT oDlg:oFont //"&Capa"
      @ 11, 45 CHECKBOX lItens PROMPT STR0144 SIZE 21,08 OF oPanel PIXEL FONT oDlg:oFont //"&Itens"

      oPanel:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oBrwCapa:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oBrwCapa:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oDlg:lMaximized:=.T. // NCF - 19/09/2019
   //DFS - 04/02/13 - Inclus„o de refresh na tela
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bSelOk,bSelCancel,,aButtons),oBrwCapa:oBrowse:Refresh())
      //(Si400Bar(oDlg,{|| IF(!lCapa .And. !lItens, HELP(" ",1,"AVG0000643"),(nSelOp:= 1, oDlg:End())) },;
      //              {|| oDlg:End()})) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   IF nSelOp == 1

      If !IsVazio("TRB")
         If !MsgYesNo(STR0145)  //"Os itens j· lanÁados ser„o apagados. Confirma a cÛpia dos dados?"###"AtenÁ„o"
            Break
         EndIf
         TRB->(AvZap())//AvZap("TRB")
      EndIf

      MsAguarde({|| MsProcTxt(STR0146+Transf(SW0->W0__NUM,AVSX3("W0__NUM",6))),; //"Copiando informaÁıes da SI: "
                    Si400Copia() }, STR0009) //"Solicitacao de Importacao"
      TRB->(dbGoTop())

   ENDIF

End Sequence
SW0->(dbGoto(nRecSW0))
Select(nSelect)
Return NIL


/*
Funcao      : Si400Copia
Parametros  : nenhum
Retorno     : nenhum
Objetivos   : Copia dados de uma SI
Autor       : Elizabete O. Silveira
Data        : 23/04/2002
Revisao     :
*/
Static Function Si400Copia()
Local nCpo, aOrd, cDsc_P_SB1

IF lCapa
   For nCpo:=1 To SW0->(FCount())
       SW0->( M->&(FieldName(nCpo)) := FieldGet(nCpo) )
   Next

   //ER - 18/09/2007 - Caso o N˙mero da SI j· tenha sido preenchida antes da cÛpia, n„o ser· apagado.
   If !Empty(cSIOldNum)
      M->W0__NUM := cSIOldNum
   Else
      M->W0__NUM := SPACE(AVSX3("W0__NUM",3))
   EndIf

   M->W0__CC := SPACE(AVSX3("W0__CC",3))
   M->W0__Dt := CTOD("")
   M->W0_C1_NUM := SPACE(AVSX3("W0_C1_NUM",3))
   M->W0_HAWB_DA := SPACE(AVSX3("W0_HAWB_DA",3))

   // Copia os Campos Virtuais
   aOrd := SaveOrd("SX3",1)
   SX3->(dbSeek("SW0"))
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SW0"
      IF Upper(SX3->X3_CONTEXT) == "V"
         M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
      Endif
      SX3->(dbSkip())
   Enddo
   RestOrd(aOrd)

   IF !lItens
      //MFR 25/11/2019 OSSME-4046
      AvZap("TRB")
      TRB->(DBAPPEND())
      TRB->W1_POSIT := SI400NumPoItem()  
      TRB->W1_CLASS := "1"+Space(5)   
   ENDIF
ENDIF

IF lItens
   SW1->(DBSETORDER(1), DBSEEK(xFilial()+ SW0->W0__CC + SW0->W0__NUM))
   While !SW1->(EOF()) .AND. SW0->W0_FILIAL + SW0->W0__CC + SW0->W0__NUM == ;
                             SW1->W1_FILIAL + SW1->W1_CC + SW1->W1_SI_NUM
      IF SW1->W1_SEQ == 0
         TRB->(DBAPPEND())
         AVReplace("SW1","TRB")
         TRB->W1_SALDO_Q := TRB->W1_QTDE
         TRB->W1_ALI_WT:= "SW1"
         TRB->W1_REC_WT:= 0
      ENDIF
      If TRB->(FIELDPOS("W1_COD_DES")) # 0
         If TRB->W1_REC_B1 == 0
            TRB->W1_REC_B1 := GetRecSB1(TRB->W1_COD_I)
         Else
            SB1->(DbGoto(TRB->W1_REC_B1))
         EndIf
         cDsc_P_SB1 := ""
         If !Empty(TRB->W1_COD_I)
            If SB1->(!Eof())
               cDsc_P_SB1 := MSMM(SB1->B1_DESC_P,30,1)
               If !Empty(cDsc_P_SB1)
                  TRB->W1_COD_DES := cDsc_P_SB1
               Else
                  TRB->W1_COD_DES := SB1->B1_DESC
               EndIf
            EndIf
         EndIf
      EndIf
      SW1->(dbSkip())
   Enddo

   TRB->(dbGotop())

   //DFS - Ponto de entrada para copiar registros da S.I.
   If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"COPIA_SI"),)
Endif
Return NIL

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SI400Alter≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 13.07.96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Programa exclusivo para alteracao de Oráamentos.           ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe e ≥ Void SI400Altera(ExpC1,ExpN1)                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Alias do arquivo                                   ≥±±
±±≥          ≥ ExpN1 = Numero do registro                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ EICSI400                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function SI400Altera(cAlias,nReg,nOpc)
LOCAL cAlias1:="SW1"
LOCAL nRecnoSW0, i
LOCAL nMeio:=0
LOCAL lRet:= .T.
LOCAL cOldF11:=SetKey(VK_F11)
//Local aButtons
LOCAL bAlterar := {|| cManut := "A", oDlg:End() }
LOCAL bIncluir := {|| cManut := "I", oDlg:End() }
LOCAL bExcluir := {|| cManut := "E", oDlg:End() }

LOCAL bCopiar  := {|| cManut := "C", oDlg:End() }
LOCAL bSWitch  := {|| cManut := "S", oDlg:End() }
Local oDlg,oEnch1
PRIVATE lInclui:=.F.
Private lLoop // GFP - 02/07/2012 - Variavel para Ponto de Entrada
Private aButtons

If ( Type("lSIAuto") == "U" .OR. !lSIAuto )
   If SW0->(FieldPos("W0_SIAUTO")) # 0
      If SW0->W0_SIAUTO == "1"
         MsgInfo(STR0181) //STR0181 "Si Autom·tica n„o pode ser alterada!"
         Return(nOpc)
      Endif
   Endif
Endif

//Tratamento para ExecAuto - Na Alteracao, percorrer array de itens e verificar se Inclusao/Alteracao/Exclusao de itens
/*If lSIAuto
   If nOpcAuto == 4  //Alteracao Automatica de SI
      For i:= 1 to Len(aCabItem)
         If EasySeekAuto("TRB", aCabItem[i], 1 )
            If (nPOsDel := aScan(aCabItem[i], {|x| x[1] == "AUTDELETA" .AND. x[2] == "S" })) > 0
               aAdd(aDeletaAuto, aCabItem[i])
            Else
               aAdd(aAlteraAuto,aCabItem[i])
            EndIf
         Else
            aAdd(aIncluiAuto,aCabItem[i])
         Endif
      Next i
   Endif
Endif*/

// *** by CAF 12/08/2000 Entreposto
IF !Empty(SW0->W0_HAWB_DA)
   SW1->(dbSetOrder(1))
   SW1->(dbSeek(xFilial()+SW0->W0__CC+SW0->W0__NUM))

   While SW1->(!Eof() .And. W1_FILIAL == xFilial("SW1")) .And.;
         SW1->(W1_CC+W1_SI_NUM) == SW0->(W0__CC+W0__NUM)
      IF !Empty(SW1->W1_PO_NUM)
         Exit
      Endif

      SW1->(dbSkip())
   Enddo

   Help(" ",1,"AVG0000087",,AllTrim(Transf(SW1->W1_PO_NUM,AVSX3("W1_PO_NUM",6)))+".",3,9)

   Return (nOpc)
Endif

IF EasyEntryPoint(cArqRdmake)
   nExecute:="10"
   IF !ExecBlock(cArqRdmake,.F.,.F.)
      RETURN (nOpc)
   ENDIF
ENDIF

IF EasyEntryPoint("EICPSI01")
   IF !ExecBlock("EICPSI01",.F.,.F.,"10")
      RETURN (nOpc)
   ENDIF
ENDIF

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta a entrada de dados do arquivo                          ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE cNomArq
aHeader := Array(0)

Private aSI400Del := {}//, aSI400Reg -  FSM - 01/08/2011
Private cManut := ""
//JMS 28/06/04
PRIVATE lKit := ! Empty(SW0->W0_SIKIT) .AND. IF(EasyGParam("MV_KIT")$ cSim,.T.,.F.)
PRIVATE aSW0 := {"W0__CC","W0__CCDESC","W0__NUM","W0__DT","W0__POLE",;
                 "W0__POLEDE", "W0_COMPRA", "W0_COMPRAN", "W0_MOEDA",;
                 "W0_C1_NUM", "W0_SOLIC"}

If Type("lSIAuto") == "U"
   lSIAuto:= .F.
EndIf

If Type("lPOAuto") == "U"
   lPOAuto:= .F.
EndIf

IF lKit // Manutencao de SI com Kit
   aAdd(aSW0, "W0_SIKIT")
   aAdd(aSW0, "W0_KITSERI")
   aAdd(aSW0, "W0_FORN")
   IF EICLOJA()
      aAdd(aSW0, "W0_FORLOJ")
   ENDIF
   aAdd(aSW0, "W0_FORNDES")
   aAdd(aSW0, "W0_QTDE")
   aAdd(aSW0, "W0_DT_NEC")
   aAdd(aSW0, "W0_DT_EMB")
   aAdd(aSW0, "W0_CLASKIT")
Endif

If SW0->(FIELDPOS("W0_SIAUTO")) # 0
   aAdd(aSW0, "W0_SIAUTO")
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Salva a integridade dos campos de Bancos de Dados            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0 .Or. Eof()
   Return (.T.)
EndIf

If ! RecLock(cAlias,.F.) // by CAF - 10/13/1998
   Return(.F.)
ENDIF

FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT i
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Array com os campos do arquivo de Trabalho                   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aCpos := {"W1_COD_I","W1_COD_DES","W1_FABR","W1_FORN","W1_CLASS",;
          "W1_QTDE" ,"W1_SALDO_Q","W1_PRECO",;
          "W1_DT_EMB","W1_DTENTR_"}
EICAddLoja(aCpos, "W1_FORLOJ", Nil, "W1_FORN")
EICAddLoja(aCpos, "W1_FABLOJ", Nil, "W1_FABR")
//NCF - 22/06/2010
If lCpoCCusto
   aAdd(aCpos,"W1_CTCUSTO")
EndIf

//JVR - 11/02/10
If SW1->(FieldPos("W1_POSIT")) # 0
   Aadd(aCpos,Nil)
   AIns(aCpos,1)
   aCpos[1] := "W1_POSIT"
EndIf

aCpos := AddCpoUser(aCpos,"SW1","1")

// SI400 Campos para a Estrutura                               -    JBS 06/10/2003
nPontoEntrada :=3
IF cPaisLoc # "BRA" .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
    AADD(aCpos,"W1_NATUREZ")
ENDIF

IF EasyEntryPoint(cArqRdmake)
   nExecute:="2"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ALTERA_CAMPOS")
ENDIF

IF lForeCast
   AADD(aCpos,"W1_FORECAS")
ENDIF

// BAK - ApresentaÁao do campo do codigo da matriz de tributaÁao - "W1_CODMAT"
If SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   AADD(aCpos,"W1_CODMAT")
EndIf

IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"2"),)
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"2"),)
lGetdb:= lComEdit

aYesHeader:=   { "W1_COD_I" ,;
                  "W1_COD_DES",;
                  "W1_FABR" ,;
                  "W1_FORN" ,;
                  "W1_CLASS" ,;
                  "W1_QTDE" ,;
                  "W1_SALDO_Q",;
                  "W1_PRECO",;
                  "W1_DT_EMB",;
                  "W1_DTENTR_"}
//NCF - 22/06/2010
If lCpoCCusto
   aAdd(aYesHeader, "W1_CTCUSTO")
EndIf
EICAddLoja(aYesHeader, "W1_FABLOJ", Nil, "W1_FABR")
EICAddLoja(aYesHeader, "W1_FORLOJ", Nil, "W1_FORN")
aCpoVirtual:= {"W1_COD_DES"}
If SW1->(FieldPos("W1_POSIT")) # 0
   Aadd(aYesHeader,Nil)
   AIns(aYesHeader,1)
   aYesHeader[1] := "W1_POSIT"
EndIf

// BAK - ApresentaÁao do campo do codigo da matriz de tributaÁao - "W1_CODMAT"
If SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   aAdd(aYesHeader, "W1_CODMAT")
EndIf

aYesHeader := AddCpoUser(aYesHeader,"SW1","3")
//DFS - 23/08/11 - Inclus„o de tratamento para que, quando incluir campos de usu·rio do tipo virtual, sistema n„o apresente error.log
aCpoVirtual := AddCpoUser(aCpoVirtual,"SW1","1")

cSeek := xFilial("SW1")+SW0->W0__CC+SW0->W0__NUM
bRecSemX3 := {|| M->QTDE:=SW1->W1_QTDE, M->SALDO:= SW1->W1_SALDO_Q ,M->RECNO := SW1->(Recno()), M->W1_REC_B1:=0 , .T.}
SW1->( DBSetOrder(1) )
bCond := {||.T.}
bAction1 := {|| xFilial("SW1")+SW1->(W1_CC+W1_SI_NUM ) == xFilial("SW1")+SW0->( W0__CC+W0__NUM )  }
bAction2 := {||.F.}
M->W1_ALI_WT := "SW1"
FillGetDB(nOpc, "SW1", "TRB1",,1, cSeek, bSW0While,{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/;
            ,,,,ExcHeader(aYesHeader, "SW1"),if(!lGetDb,.T.,),,aCpoVirtual,;
            {|a, b| AddSemSx3(@b) }, , bRecSemX3)//JVR - 12/02/10 - Inserido o parametro 15 (tratamento de lGetDb)

cNomArq := E_CRIATRAB(,TRB1->(dbStruct()),"TRB")
//cNomArq := AvTrabName("TRB")

dbSelectArea("TRB")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"W1_COD_I+STR(W1_REG,"+Alltrim(STR(AVSX3("W1_REG",3)))+",0)")

//** JVR - 27/11/2009
If SW1->(FieldPos("W1_POSIT")) > 0
   cNomArq2 := CriaTrab(,.F.)
   IndRegua("TRB",cNomArq2+TEOrdBagExt(),"W1_POSIT")
   TRB->(dbSetIndex(cNomArq+TEOrdBagExt()),dbSetIndex(cNomArq2+TEOrdBagExt()))
   TRB->(dbSetOrder(1))
EndIf
TERestBackup("TRB1")
TRB1->(dbCloseArea())
//**

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Atualiza o arquivo de Trabalho com os dados                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !lSIAuto
   MsAguarde({||lTemItens:=SI400GrTRB()},STR0025+ALLTRIM(SW0->W0__NUM)) //"Lendo Itens da S.I.: "
Else
   lTemItens:=SI400GrTRB()
Endif

If ! lTemItens
   Help(" ",1,"EICSEMITEM")
   TRB->(E_EraseArq(cNomArq))
   dbSelectArea(cAlias)
   MSUNLOCK()
   Return .T.
Endif

nRecnoSW0:=SW0->(RECNO())

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ANTES_TELA_ALTERA")
Endif

TRB->(dbGoTop())

WHILE .T.

   aButtons:=SI400BarItem(oDlg,,,nOpc)

   aGets := {}   // GFP - 06/07/2012
   aTela := {}

   If nOpc <> EXCLUIR
      Aadd(aButtons,{"POSCLI",{||nOpca:=4,oDlg:End()},STR0081})

      IF !lInclui
         Aadd(aButtons,{"RELATORIO",{||nOpca:=5,oDlg:End()},STR0082})
      ENDIF

   EndIf

   IF nOpc # 2
      IF nOpc == 3
         Aadd(aButtons,{"S4WB005N",bCopiar,STR0162})
      ENDIF
      If !lComEdit
         Aadd(aButtons,{"EDIT",bIncluir ,STR0083})
         Aadd(aButtons,{"IC_17",bAlterar ,STR0085})
         Aadd(aButtons,{"EXCLUIR",bExcluir ,STR0084})
      EndIf
      Aadd(aButtons,{"RECALC",bSWitch ,STR0163})
      SETKEY(VK_F11,bSwitch)
   ENDIF

	IF EasyEntryPoint("EICSI400")
	   ExecBlock("EICSI400",.F.,.F.,"ANTES_TELA_ALTERA")
	Endif

	TRB->(dbGoTop())

   If !lSIAuto
      nOpcA:= 0
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE IF(!Empty(M->W0_HAWB_DA),cTitNac+AllTrim(Transf(M->W0_HAWB_DA,AVSX3("W6_HAWB",6))),cTitulo+If(lKit,STR0026,STR0027)) ; //" com Kit"###" Normal"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
      	     OF oMainWnd PIXEL
      nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
      oEnch1 := MsMGet():New( cAlias, nReg, nOpc, , , , aSW0, { 15,  1, nMeio-1,(oDlg:nClientWidth-4)/2}, , 3 )
      dbSelectArea("TRB")

      If lComEdit
         //CDS 23/8/04
         TRB->(DBSetorder(1)) //(0) LGS - 11/09/2013
         TRB->(dbSeek(xFilial() + TRB->W1_POSIT)) //LGS - 11/09/2013 - Ordernar os itens na tela pelo campo "PosiÁ„o do Item" para que a tela de alteraÁ„o fique igual a de visualizaÁ„o.
         TRB->(DBGotop())
         If TRB->(Eof())
            TRB->(DBAppend())
         Endif
         oMSSelect := MsGetDB():New(100,1,190,317,nOPC,"U_EILinok","U_EILinok",,.T.,aCpos,,.F.,,"TRB",,,lCopiaSI,,,,"U_SI400ApagaReg")
         TRB->(DBGotop())
         // EOB - 16/02/09 - Inclusa validaÁ„o 'a cl·usula when do campo Codigo do item para que, numa alteraÁ„o, n„o
         // permita alterar o cÛdido do item, somente edita o campo na inclus„o.
         nPos := aScan(aYesHeader, "W1_COD_I")
         oMSSelect:aInfo[nPos,4]:= "SI400WhenItem()"  //"TRB->RECNO == 0" //DRL - 17/06/09
      Else
         oMSSelect:= MsSelect():New("TRB",,,aCamposSI,@lInverte,@cMarca,{nMeio,1,If(SetMdiChild(),(oDlg:nClientHeight+82)/2,(oDlg:nClientHeight-6)/2),(oDlg:nClientWidth-4)/2})//LRL 11/03/04
         oMSSelect:bAval := {||cManut:="A",oDlg:End()}
         TRB->(DBGotop())
      Endif

      cManut := ""

      oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oMSSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oMSSelect:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oDlg:lMaximized:=.T. // NCF - 19/09/2019
      //DFS - 04/02/13 - Inclus„o de refresh na tela
      ACTIVATE MSDIALOG oDlg ON INIT (ENCHOICEBAR( oDlg, {||nOpcA:=1,IF(SI400Check(lKit),oDlg:End(),nOpca:=0)},{||nOpcA:=0,oDlg:End()},  ,aButtons),oMSSelect:oBrowse:Refresh())  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                     /*(SI400BarItem(oDlg,{||nOpcA:=1,IF(SI400Check(lKit),oDlg:End(),nOpca:=0)},;
                                       {||nOpcA:=0,oDlg:End()},nOpc),;
                                       oEnch1:oBox:Align := CONTROL_ALIGN_TOP,;
                                       oMSSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT, oMSSelect:oBrowse:Refresh())  // ACSJ - 12/04/2004*/

      // Mudar modo de visualizacao   CDS 23/08/04
      If cManut="S"
         If Aviso(STR0163,STR0163,{STR0021,STR0022})=1
            LimpaOnSwitch(lComEdit)
            lComEdit := .NOT.(lComEdit)
            SetMV("MV_MESI",lComEdit)
         Endif
         aTela := {}
         aGets := {}
         Loop
      Endif

      If !lComEdit
	     If !Empty(cManut).and.cManut<>"S"
	        SI400Manut(cManut)
	        aTela := {}
	        aGets := {}
	        Loop
         Endif
      Endif

   Else

      If !lPOAuto //LRS - 22/09/2016
         lComEdit:= .T.
      EndIF

      Private nBrLin:= 0

      If !EasySeekAuto("TRB", aCabItem[1], 2 )  // GFP - 08/04/2014 - Caso n„o encontrar item, operaÁ„o deve ser de inclus„o
         nOpcAuto := 3
      EndIf

      If EnchAuto(cAlias,aCabAuto,{|| Obrigatorio(aGets,aTela)} ,nOpcAuto,aSW0) .And. SIAutoItens(aCabItem)
         nOpcA := 1
      Else
         nOpcA := 0  //TRP - 23/05/2011
         lRet:= .F.
         Exit
      Endif

   Endif

   IF nOpcA == 0 .AND. !SI400Sair()

      LOOP

   ELSEIF nOpcA == 1 .AND. !InTransact()

      lLoop:=.F.// GFP - 02/07/2012 - Ponto de Entrada apÛs salvar alteraÁ„o
      If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"DEPOIS_TELA_ALTERA"),)
      IF lLoop
         LOOP
      ENDIF

      Begin Transaction
            SI400Grava(cAlias,cAlias1,nRecnoSW0)
            EvalTrigger()
      End Transaction

   ELSEIF nOpcA == 1
      //RMD - 12/09/13 - Tratamento para quando n„o estiver em transaÁ„o

      lLoop:=.F.// GFP - 02/07/2012 - Ponto de Entrada apÛs salvar alteraÁ„o
      If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"DEPOIS_TELA_ALTERA"),)
      IF lLoop
         LOOP
      ENDIF

      SI400Grava(cAlias,cAlias1,nRecnoSW0)
      EvalTrigger()

   ELSEIF nOpca == 4
      nRecno:=TRB->(RECNO())
      Si400Historico(TRB->W1_COD_I,.F.)
      TRB->(DBGOTO(nRecno))
      aTela := {}
      aGets := {}
      LOOP

   ELSEIF nOpca == 5
      nRecno:=TRB->(RECNO())
      Si400Historico(TRB->W1_COD_I,.T.)
      TRB->(DBGOTO(nRecno))
      aTela := {}
      aGets := {}
      LOOP

   ENDIF

   EXIT
   aTela := {}
   aGets := {}

ENDDO

SetKey(VK_F11,cOldF11)
//TRB->(dbCloseArea())
TRB->(E_EraseArq(cNomArq))
dbSelectArea(cAlias)
MsUnlock()
lGetdb:= .F.
Return( nOpc )

If lSIAuto .AND. lPOAuto
    If lNotPOErroAuto
      lNotPOErroAuto:= lRet
   Endif
Endif

//Return( nOpc )
Return lRet  //TRP - 23/05/2011

/*
Funcao : LINOK
Descric: VALIDAR LINHA NO MSGETDB
Autor  : CDS
Data   : 23/08/04
Param  : lMemoria
Retorna: .T. / .F.
*/
User Function EILinok(lMemoria)
Local  n, lEmpty:=.F., nOrdA5:=SA5->(IndexOrd())
Local cMsg := ""
Private lRet := .T. //LRS - 13/09/2016 Variavel para receber o lRet antes do ponto de entrada

Begin Sequence
// Se o registro est· apagado, nao validar           CDS 23/08/04
 If TRB->W1_FLAG == .T.
   lRet:=.T.
   Return(lRet)
 Endif
 dbSelectArea("TRB")
 For n:=1 to FCount()
   DO CASE
      CASE  FieldName(n) == "W1_COD_I" .AND. Empty(FieldGet(n))
            //"O campo XXXX deve ser informado! " + ENTER
            cMsg += strtran(STR0206,"XXXX",avsx3(fieldname(n),AV_TITULO)) + ENTER 

      CASE  FIeldName(n) == "W1_SALDO_Q" .AND. Empty(FieldGet(n))
            if TRB->W1_QTDE == 0
               // cMsg += "O campo XXXX n„o pode ser igual a zero! " + ENTER
               cMsg += strtran(STR0207,"XXXX",avsx3(fieldname(n),AV_TITULO)) + ENTER
            endif
      CASE  FIeldName(n) == "W1_CLASS" .AND. Empty(FieldGet(n))
            // cMsg += "O campo XXXX deve ser informado! " + ENTER
            cMsg += strtran(STR0208,"XXXX",avsx3(fieldname(n),AV_TITULO)) + ENTER
   ENDCASE
 Next n

 If ! empty(cMsg)
   easyhelp(cMsg,STR0002)
   lRet := .F.
   Break
 Else
   If (!Empty(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ"))  .OR. (!Empty(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ"))

      If !Empty(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ")
         If ! SA2->(DbSeek(xFilial()+AvKey(TRB->W1_FABR,"A2_COD")+EICRetLoja("TRB","W1_FABLOJ")))
            easyhelp(STR0209 + alltrim(TRB->W1_FABR) + STR0210 + EICRetLoja("TRB","W1_FABLOJ") + STR0211 ,STR0002)
            lRet := .F.
            Break
         ElseIf AT(LEFT(SA2->A2_ID_FBFN,1),"13") == 0
                Help("", 1, "AVG0000495")//MsgInfo(OemtOAnsi(STR0028),STR0029) //"C¢digo n∆o se refere a fabricante"###"InformaÁ„o"
                lRet := .F.
                Break
         Endif
      Endif

      If (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_FORN)).AND. lKit
         Help(" ",1,"SI400FOMES")
         lRet:=.F.
         Break
      Endif

      If !Empty(TRB->W1_FORN) .AND.  !EICEmptyLJ("TRB", "W1_FORLOJ")
         If ! SA2->(DbSeek(xFilial()+AvKey(TRB->W1_FORN, "A2_COD")+EICRetLoja("TRB","W1_FORLOJ")))
            easyhelp(STR0212 + alltrim(TRB->W1_FORN) + STR0210 + EICRetLoja("TRB","W1_FORLOJ") + STR0211 ,STR0002)
            lRet := .F.
            Break
         ElseIf AT(LEFT(SA2->A2_ID_FBFN,1),"23") = 0
            If type("lSiAuto") == "L" .AND. !lSiAuto
               MsgInfo(OemToAnsi(STR0204)) //"CÛdigo n„o se refere a fornecedor"
            else
               easyhelp(STR0204,STR0002)
            EndIf
            lRet := .F.
            Break
         Endif
      Endif

      nOrdA5:=SA5->(IndexOrd())

      IF !EMPTY(TRB->W1_FABR) .AND. !EMPTY(TRB->W1_FORN) .And. !EICEmptyLJ("TRB", "W1_FABLOJ") .And. !EICEmptyLJ("TRB", "W1_FORLOJ")
         SA5->(DbSetOrder(3))
         If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+TRB->W1_FABR+TRB->W1_FORN, EICRetLoja("TRB", "W1_FABLOJ"), EICRetLoja("TRB", "W1_FORLOJ"))
            Help("", 1, "AVG0000529")//MsgiNFO(OemtoAnsi(STR0034)) //"Produto n«o cadastrado p/ este Fabricante/Fornecedor"
            lRet := .F.
            Break
         Endif
      ENDIF

      IF !EMPTY(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ") .AND. EMPTY(TRB->W1_FORN) .AND. EICEmptyLJ("TRB", "W1_FORLOJ")
         SA5->(DbSetOrder(3))
         If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+TRB->W1_FABR, EICRetLoja("TRB", "W1_FABLOJ"))
            Help("", 1, "AVG0000530")//MsgiNFO(OemtoAnsi(STR0035)) //"Produto n«o cadastrado para este Fabricante"
            lRet := .F.
            Break
         Endif
      ENDIF

      IF EMPTY(TRB->W1_FABR) .AND. EICEmptyLJ("TRB", "W1_FABLOJ") .AND. !EMPTY(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ")
         SA5->(DbSetOrder(2))
         If !SA5->(DbSeek(xFilial()+TRB->W1_COD_I+TRB->W1_FORN+EICRetLoja("TRB","W1_FORLOJ")))
            If type("lSiAuto") == "L" .AND. !lSiAuto
               MsgiNFO(OemtoAnsi(STR0205)) //"Produto n„o cadastrado para este Fornecedor"
            else
               easyhelp(STR0205,STR0002)
            EndIf
            lRet := .F.
            Break
         Endif
      ENDIF

      SA5->(DbSetOrder(nOrdA5))
   Endif

   If !Empty(TRB->W1_DT_EMB).and.!Empty(TRB->W1_DTENTR_)
      If TRB->W1_DT_EMB>TRB->W1_DTENTR_
           Help(" ",1,"SI400EMBMA")
           lRet:=.F.
           Break
      Endif
   Endif

 Endif

 If (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_CLASS)).AND. lKit
   Help(" ",1,"SI400CLMES")
   lRet:=.F.
   Break
 Endif

 IF (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_DTENTR_)).AND. lKit
   Help(" ",1,"SI400ENMES")
   lRet:=.F.
   Break
 ENDIF

End Sequence

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"EILinok")
Endif


If TRB->W1_REG == 0 //Type("oMSSelect") == "O" .And. oMSSelect:lNewLine  // GFP - 04/08/2015 - A variavel lNewLine sempre estar· falsa nesta passada, pois o sistema esta validando a linha preenchida.
   SI400ApuReg(.T.)  						//CDS 23/08/04
EndIf

Return( lRet )

/************************************************
Funtion: U_SI400FLD
Descric: Valida para que na alteraÁ„o da SI,
         o cÛdigo do item n„o possa ser alterado no MSGETDB.
Autor: Johann (JWJ)
Data:  20/07/2005
*************************************************/
USER FUNCTION SI400FLD()
Local cVar := Upper(ReadVar())
Local lRet := .T.

Do Case
Case cVar == "M->W1_COD_I"
	IF (M->W1_COD_I # TRB->W1_COD_I) .AND.  (TRB->W1_QTDE <> TRB->W1_SALDO_Q)
	   //Alert("Item n„o pode ser alterado pois j· possui processo de importaÁ„o em andamento")
	   Alert(STR0165)
	   Return .F.
	ENDIF
Endcase
RETURN lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SI400Exlui≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 13.07.96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Programa de Estorno de S.I.                                ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe e ≥ Void SI400Exclui(ExpC1,ExpN1)                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpC1 = Alias do arquivo                                   ≥±±
±±≥          ≥ ExpN1 = Numero do registro                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function SI400Exclui(cAlias,nReg,nOpc)
LOCAL nOpca := 0, i
LOCAL cAlias1:="SW1"
LOCAL lNaoExclui := .F.
LOCAL nMeio:=0
Local oDlg
Private oEnch1//,oDlg FSM-21/07/2011
PRIVATE lKit := ! Empty(SW0->W0_SIKIT) .AND. IF(EasyGParam("MV_KIT")$ cSim,.T.,.F.), cNomArq
PRIVATE aSW0 := {"W0__CC","W0__CCDESC","W0__NUM","W0__DT","W0__POLE",;
                 "W0__POLEDE", "W0_COMPRA", "W0_COMPRAN", "W0_MOEDA",;
                 "W0_C1_NUM", "W0_SOLIC"}
PRIVATE lExclui := .f.
            
If Type("lSIAuto") == "U"
   lSIAuto:= .F.
EndIf

IF lKit // Manutencao de SI com Kit
   aAdd(aSW0, "W0_SIKIT")
   aAdd(aSW0, "W0_KITSERI")
   aAdd(aSW0, "W0_FORN")
   IF EICLOJA()
      aAdd(aSW0, "W0_FORLOJ")
   ENDIF
   aAdd(aSW0, "W0_FORNDES")
   aAdd(aSW0, "W0_QTDE")
   aAdd(aSW0, "W0_DT_NEC")
   aAdd(aSW0, "W0_DT_EMB")
   aAdd(aSW0, "W0_CLASKIT")
Endif

If SW0->(FIELDPOS("W0_SIAUTO")) # 0
   aAdd(aSW0, "W0_SIAUTO")
Endif

If !lSIAuto
   If SW0->(FieldPos("W0_SIAUTO")) # 0
      If SW0->W0_SIAUTO == "1"
         If ExistBlock("EICSI400")
            ExecBlock("EICSI400",.F.,.F.,"VALIDA_EXCLUSAO")
         Endif
         if !lExclui
            MsgInfo(STR0182) //STR0182 "Si Autom·tica n„o pode ser excluÌda!"
            Return(nOpc)
         EndIf
      Endif
   Endif
Endif

// *** by CAF 12/08/2000 Entreposto
IF !Empty(SW0->W0_HAWB_DA)
   SW1->(dbSetOrder(1))
   SW1->(dbSeek(xFilial()+SW0->W0__CC+SW0->W0__NUM))

   While SW1->(!Eof() .And. W1_FILIAL == xFilial("SW1")) .And.;
         SW1->(W1_CC+W1_SI_NUM) == SW0->(W0__CC+W0__NUM)
      IF !Empty(SW1->W1_PO_NUM)
         Exit
      Endif

      SW1->(dbSkip())
   Enddo

   Help(" ",1,"AVG0000087",,AllTrim(Transf(SW1->W1_PO_NUM,AVSX3("W1_PO_NUM",6)))+".",3,9)

   Return (nOpc)
Endif
//Qndo For Integrado com o Logix, n„o permitir a exclus„o quando for diferente de Pendente
IF lIntLogix .and. SW1->(dbSeek(xFilial()+SW0->W0__CC+SW0->W0__NUM)) .AND. nOpcAuto == 5
   IF SW1->W1_STATUS <> "A" .AND. SW1->W1_STATUS <> "G"
      EasyHelp(StrTran(STR0198, "####", GetW1Status()), STR0040)//"A aÁ„o de exclus„o n„o pode ser realizada para a SolicitaÁ„o de ImportaÁ„o. O processo encontra-se em fase subsequente. Status atual: ####.","AtenÁ„o")       
      RETURN (nOpc)
   ENDIF
ENDIF
IF EasyEntryPoint(cArqRdmake)
   nExecute:="10"
   IF !ExecBlock(cArqRdmake,.F.,.F.)
      RETURN (nOpc)
   ENDIF
ENDIF

IF EasyEntryPoint("EICPSI01")
   IF !ExecBlock("EICPSI01",.F.,.F.,"10")
      RETURN (nOpc)
   ENDIF
ENDIF

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta a entrada de dados do arquivo                          ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE lInclui:=.F.
aHeader := Array(0)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Salva a integridade dos campos de Bancos de Dados            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0 .Or. Eof()
   Return (.T.)
EndIf

IF ! RecLock(cAlias,.F.)
   Return .f.
ENDIF

FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT i

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Array com os campos do arquivo de Trabalho                   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aCpos := { "W1_COD_I","W1_COD_DES","W1_FABR"   ,"W1_FORN","W1_CLASS",;
           "W1_QTDE" ,"W1_SALDO_Q","W1_PRECO",;
           "W1_DT_EMB","W1_DTENTR_"}
EICAddLoja(aCpos, "W1_FORLOJ", Nil, "W1_FORN")
EICAddLoja(aCpos, "W1_FABLOJ", Nil, "W1_FABR")
//NCF - 22/06/2010
If lCpoCCusto
   aAdd(aCpos,"W1_CTCUSTO")
EndIf

If SW1->(FieldPos("W1_POSIT")) # 0
   AAdd(aCpos,Nil)
   AIns(aCpos,1)
   aCpos[1] := "W1_POSIT"
EndIf

// SI400 Campos para a Estrutura                               -    JBS 06/10/2003
nPontoEntrada :=4
IF cPaisLoc # "BRA" .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
    AADD(aCpos,"W1_NATUREZ")
ENDIF

IF EasyEntryPoint(cArqRdmake)
   nExecute:="2"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ALTERA_CAMPOS")
ENDIF

IF lForeCast
   AADD(aCpos,"W1_FORECAS")
ENDIF

// BAK - ApresentaÁao do campo do codigo da matriz de tributaÁao - "W1_CODMAT"
If SW1->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
   AADD(aCpos,"W1_CODMAT")
EndIf


IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"2"),)
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"2"),)

aCampos := CriaEstru(aCpos,@aHeader)

AADD(aCampos,{"SALDO" ,"N",AVSX3("W1_SALDO_Q",3),AVSX3("W1_SALDO_Q",4)})
AADD(aCampos,{"QTDE"  ,"N",AVSX3("W1_QTDE",3),AVSX3("W1_QTDE",4)})
AADD(aCampos,{"RECNO","N",7,0})
AADD(aCampos,{"W1_REG","N",AVSX3("W1_REG",3),0})
AADD(aCampos,{"W1_REC_B1","N",10,0})
AADD(aCampos,{"W1_ALI_WT","C",03,0}) //TRP - 25/01/07 - Campos do WalkThru
AADD(aCampos,{"W1_REC_WT","N",10,0})

aCampos := AddWkCpoUser(aCampos,"SW1")

//aCampos[4][3] := 10  //SVG - 18/09/08                         // Para colocar a Descricao no SX5
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria arquivo de trabalho                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cNomArq := E_CriaTrab(,aCampos,"TRB") //THTS - 04/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("TRB",cNomArq+TEOrdBagExt(),"W1_COD_I+STR(W1_REG,"+Alltrim(STR(AVSX3("W1_REG",3)))+",0)")

// ** JVR - 27/11/2009
If SW1->(FieldPos("W1_POSIT")) > 0
   cNomArq2 := CriaTrab(,.F.)
   IndRegua("TRB",cNomArq2+TEOrdBagExt(),"W1_POSIT")
   TRB->(dbSetIndex(cNomArq+TEOrdBagExt()),dbSetIndex(cNomArq2+TEOrdBagExt()))
   TRB->(dbSetOrder(1))
EndIf
// **

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Atualiza o arquivo de Trabalho com os dados                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !lSIAuto
   MsAguarde({||lTemItens:=SI400GrTRB()},STR0025+ALLTRIM(SW0->W0__NUM)) //"Lendo Itens da S.I.: "
Else
   lTemItens:=SI400GrTRB()
Endif

If ! lTemItens
   Help(" ",1,"EICSEMITEM")
   TRB->(E_EraseArq(cNomArq))
   dbSelectArea(cAlias)
   MSUNLOCK()
   Return .T.
Endif

dbSelectArea("TRB")
dbGoTop()
While !Eof()
   If W1_QTDE # W1_SALDO_Q
      lNaoExclui := .T.
      EXIT
   Endif
   dbSkip()
End
dbGoTop()

If lNaoExclui .AND. !(Type("lEstornaCapa")=="L" .And. lEstornaCapa)  // GFP - 08/04/2014
   Help(" ",1,"SI_NODEL")
   TRB->(E_EraseArq(cNomArq))
   dbSelectArea(cAlias)
   MSUNLOCK()
   Return.T.
Endif

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"ANTES_TELA_EXCLUI")
Endif

If !lSIAuto

   While .T.
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE IF(!Empty(M->W0_HAWB_DA),cTitNac+AllTrim(Transf(M->W0_HAWB_DA,AVSX3("W6_HAWB",6))),cTitulo+If(lKit,STR0026,STR0027)) ; //" com Kit"###" Normal"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	        OF oMainWnd PIXEL
         nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )
         oEnch1 := MsMGet():New( cAlias, nReg, nOpc, , , , aSW0, { 15,  1, nMeio-1,(oDlg:nClientWidth-4)/2}, , 3 )

         dbSelectArea("TRB")
         dbGoTop()

         oMSSelect:= MsSelect():New("TRB",,,aCamposSI,@lInverte,@cMarca,{nMeio,1,If(SetMdiChild(),(oDlg:nClientHeight+82)/2,(oDlg:nClientHeight-6)/2),(oDlg:nClientWidth-4)/2})//LRL 11/03/04
         oMSSelect:oBrowse:bWhen:={||(dbSelectArea("TRB"),.t.)}


         oEnch1:oBox:Align :=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oMSSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oMSSelect:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oDlg:lMaximized:=.T. // NCF - 19/09/2019
      ACTIVATE MSDIALOG oDlg ON INIT (ENCHOICEBAR( oDlg, {||nOpca:=2,oDlg:End()}, {||oDlg:End()},  ,SI400BarItem(oDlg,,,nOpc)),oMSSelect:oBrowse:Refresh()) //ACSJ - 12/04/2004 //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      Exit
   End

Else
   nOpca:= 2
Endif

If nOpca == 2 .AND. !InTransact()
   SI400Exc(cAlias,cAlias1)
ElseIf nOpca == 2
   Begin Transaction
   SI400Exc(cAlias,cAlias1)
   End Transaction
Endif


IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"DEPOIS_ESTORNO")
ENDIF

TRB->(E_EraseArq(cNomArq,cNomArqR))
dbSelectArea(cAlias)
MSUNLOCK()
Return nOpc

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ SI400LinO≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 13.07.96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Consistencia para mudanca/inclusao de linhas do Orcamento. ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe e ≥ ExpN1 = SI400LinOk                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpN1 = Valor devolvido pela funáÑo                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function SI400LinOk(lMemoria)
Local lRet := .T., n, lEmpty:=.F., nOrdA5:=SA5->(IndexOrd())
Local lRetPto

//Checar se o MsGetDb esta ativo


If lComEdit
  Return(DB_SI400LinOk(lMemoria))
Endif


// Fazer as consistencias especiais
//* TDF - 13/12/2010 Revis„o da utilizaÁ„o de vari·veis de memÛria no lugar da TRB.
If ValType(lMemoria) == "L" .And. lMemoria

   If (!Empty(M->W1_FABR) .AND. !EICEmptyLJ("M", "W1_FABLOJ")) .OR. (!Empty(M->W1_FORN) .AND.  !EICEmptyLJ("M", "W1_FORLOJ") )
      If !Empty(M->W1_FABR) .AND. !EICEmptyLJ("M", "W1_FABLOJ")
         If ! SA2->(DbSeek(xFilial()+AvKey(M->W1_FABR,"A2_COD")+EICRetLoja("M","W1_FABLOJ")))
            HELP(" ",1,"REGNOIS")
            lRet := .F.
         ElseIf AT(LEFT(SA2->A2_ID_FBFN,1),"13") = 0
            Help("", 1, "AVG0000495")//MsgiNFO(OemtoAnsi(STR0028),STR0029) //"C¢digo n∆o se refere a fabricante"###"InformaÁ„o"
            lRet := .F.
         Endif
      Endif

      If (! Empty(M->W0_SIKIT) .AND. EMPTY(M->W1_FORN)) .AND. lKit
         Help(" ",1,"SI400FOMES")
         lRet:=.F.
      Endif

      If !Empty(M->W1_FORN) .AND. !EICEmptyLJ("M", "W1_FORLOJ") //TRP - 17/09/10
         If ! SA2->(DbSeek(xFilial()+AvKey(M->W1_FORN, "A2_COD")+EICRetLoja("M","W1_FORLOJ")))
            HELP(" ",1,"REGNOIS")
            lRet := .F.
         ElseIf AT(LEFT(SA2->A2_ID_FBFN,1),"23") = 0
//          MFR MTRADE-665 WCC-508648 21/03/2017
//          Help("", 1, "AVG0000492")//MsgInfo(OemToAnsi(STR0030),STR0029) //"C¢digo n∆o se refere a fornecedor"###"InformaÁ„o"
//          lRet := .F.
            If type("lSiAuto") == "L" .AND. !lSiAuto
               MsgInfo(OemToAnsi(STR0204)) //"CÛdigo n„o se refere a fornecedor"
            EndIf
            lRet := .T.
         Endif
      Endif

      nOrdA5:=SA5->(IndexOrd())

      If !Empty(M->W1_FABR) .AND. !EICEmptyLJ("M", "W1_FABLOJ") .AND. !Empty(M->W1_FORN) .AND. !EICEmptyLJ("M", "W1_FORLOJ")
         SA5->(DbSetOrder(3))
         //If !SA5->(DbSeek(xFilial()+M->W1_COD_I+M->W1_FABR+M->W1_FORN))
         If !EICSFabFor(xFilial("SA5")+M->W1_COD_I+M->W1_FABR+M->W1_FORN, EICRetLoja("M", "W1_FABLOJ"), EICRetLoja("M", "W1_FORLOJ"))
            Help("", 1, "AVG0000529")//MsgInfo(STR0031,STR0029) //"Produto n„o cadastrado p/ este Fabricante/Fornecedor"###"InformaÁ„o"
            lRet := .F.
         Endif
      ENDIF

      IF !EMPTY(M->W1_FABR) .AND. !EICEmptyLJ("M", "W1_FABLOJ") .AND. EMPTY(M->W1_FORN) .AND. EICEmptyLJ("M", "W1_FORLOJ")
         SA5->(DbSetOrder(3))
         //If !SA5->(DbSeek(xFilial()+M->W1_COD_I+M->W1_FABR))
         If !EICSFabFor(xFilial("SA5")+M->W1_COD_I+M->W1_FABR, EICRetLoja("M", "W1_FABLOJ"))
            Help("", 1, "AVG0000530")//MsgiNFO(OemtoAnsi(STR0032)) //"Produto n∆o cadastrado para este Fabricante"
            lRet := .F.
         Endif
      ENDIF

      IF EMPTY(M->W1_FABR) .AND. EICEmptyLJ("M", "W1_FABLOJ") .AND. !EMPTY(M->W1_FORN) .AND. !EICEmptyLJ("M", "W1_FORLOJ")
         SA5->(DbSetOrder(2))
         If !SA5->(DbSeek(xFilial()+M->W1_COD_I+M->W1_FORN+EICRetLoja("M","W1_FORLOJ")))
//          MFR MTRADE-665 WCC-508648 21/03/2017
//          Help("", 1, "AVG0000531")//MsgiNFO(OemtoAnsi(STR0033)) //"Produto n∆o cadastrado para este Fornecedor"
//          lRet := .F.
            If type("lSiAuto") == "L" .AND. !lSiAuto
               MsgiNFO(OemtoAnsi(STR0205)) //"Produto n„o cadastrado para este Fornecedor"
            EndIf
            lRet := .T.
         Endif
      ENDIF

      SA5->(DbSetOrder(nOrdA5))
   Endif

   IF !EMPTY(M->W1_DTENTR_)
      If M->W1_DT_EMB > M->W1_DTENTR_
         Help(" ",1,"SI400EMBMA")
         Return ( lRet := .F. )
      Endif
   Endif

   IF lRet .AND. M->W1_REG == 0 .AND. !SI400ApuReg(.T.,"M") //MCF - 29/03/2016
      RETURN .F.
   ENDIF

   Return (lRet)
Endif
//* TDF - 13/12/2010 *//

For n:=1 to FCount()
   DO CASE
      CASE  FieldName(n) == "W1_COD_I" .AND. Empty(FieldGet(n))
            lEmpty:=.T.
      CASE  FIeldName(n) == "W1_SALDO_Q" .AND. Empty(FieldGet(n))
            lEmpty:=(TRB->W1_QTDE=0)
      CASE  FIeldName(n) == "W1_CLASS" .AND. Empty(FieldGet(n))
            lEmpty:=.T.
   ENDCASE
Next n

If lEmpty
   HELP(" ",1,"OBRIGAT")
   lRet := .F.
Else
   If (!Empty(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ")) .OR. (!Empty(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ") )

      If !Empty(TRB->W1_FABR) .And. !EICEmptyLJ("TRB", "W1_FABLOJ")
         If ! SA2->(DbSeek(xFilial()+AvKey(TRB->W1_FABR,"A2_COD")+EICRetLoja("TRB","W1_FABLOJ")))
            HELP(" ",1,"REGNOIS")
            lRet := .F.
         ElseIf AT(LEFT(SA2->A2_ID_FBFN,1),"13") = 0
                Help("", 1, "AVG0000495")//MsgInfo(OemtOAnsi(STR0028),STR0029) //"C¢digo n∆o se refere a fabricante"###"InformaÁ„o"
                lRet := .F.
         Endif
      Endif

      If (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_FORN)).AND. lKit
         Help(" ",1,"SI400FOMES")
         lRet:=.F.
      Endif

      If !Empty(TRB->W1_FORN) .AND. !Empty(TRB->W1_FORLOJ)
         If ! SA2->(DbSeek(xFilial()+AvKey(TRB->W1_FORN, "A2_COD")+EICRetLoja("TRB","W1_FORLOJ")))
            HELP(" ",1,"REGNOIS")
            lRet := .F.
         ElseIf AT(LEFT(SA2->A2_ID_FBFN,1),"23") = 0
//          MFR MTRADE-665 WCC-508648 21/03/2017
//          Help("", 1, "AVG0000492")//MsgInfo(OemtoAnsi(STR0030),STR0029) //"C¢digo n∆o se refere a fornecedor"###"InformaÁ„o"
//          lRet := .F.
            If type("lSiAuto") == "L" .AND. !lSiAuto
               MsgInfo(OemToAnsi(STR0204)) //"CÛdigo n„o se refere a fornecedor"
            EndIf
            lRet := .T.
         Endif
      Endif

      nOrdA5:=SA5->(IndexOrd())

      IF !EMPTY(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ") .AND. !EMPTY(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ")
         SA5->(DbSetOrder(3))
         //If !SA5->(DbSeek(xFilial()+TRB->W1_COD_I+TRB->W1_FABR+TRB->W1_FORN))
         If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+TRB->W1_FABR+TRB->W1_FORN, EICRetLoja("TRB", "W1_FABLOJ"), EICRetLoja("TRB", "W1_FORLOJ"))
            Help("", 1, "AVG0000529")//MsgiNFO(OemtoAnsi(STR0034)) //"Produto n«o cadastrado p/ este Fabricante/Fornecedor"
            lRet := .F.
         Endif
      ENDIF

      IF !EMPTY(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ") .AND. EMPTY(TRB->W1_FORN) .AND. EICEmptyLJ("TRB", "W1_FORLOJ")
         SA5->(DbSetOrder(3))
         //If !SA5->(DbSeek(xFilial()+TRB->W1_COD_I+TRB->W1_FABR))
         If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+TRB->W1_FABR, EICRetLoja("TRB", "W1_FABLOJ"))
            Help("", 1, "AVG0000530")//MsgiNFO(OemtoAnsi(STR0035)) //"Produto n«o cadastrado para este Fabricante"
            lRet := .F.
         Endif
      ENDIF

      IF EMPTY(TRB->W1_FABR) .AND. EICEmptyLJ("TRB", "W1_FABLOJ") .AND. !EMPTY(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ")
         SA5->(DbSetOrder(2))
         If !SA5->(DbSeek(xFilial()+TRB->W1_COD_I+TRB->W1_FORN+EICRetLoja("TRB","W1_FORLOJ")))
//          MFR MTRADE-665 WCC-508648 21/03/2017
//          Help("", 1, "AVG0000531")//MsgiNFO(OemtoAnsi(STR0036)) //"Produto n«o cadastrado para este Fornecedor"
//          lRet := .F.
            If type("lSiAuto") == "L" .AND. !lSiAuto
               MsgiNFO(OemtoAnsi(STR0205)) //"Produto n„o cadastrado para este Fornecedor"
            EndIf
            lRet := .T.
         Endif
      ENDIF

      SA5->(DbSetOrder(nOrdA5))
   Endif
Endif

If (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_CLASS)).AND. lKit
   Help(" ",1,"SI400CLMES")
   lRet:=.F.
Endif

IF (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_DTENTR_)).AND. lKit
   Help(" ",1,"SI400ENMES")
   lRet:=.F.
ENDIF

//ER - 07/02/2007
If EasyEntryPoint("EICSI400")
   //13/07/13 - Tratamento para retorno diferente de lÛgico.
   lRetPto := ExecBlock("EICSI400",.F.,.F.,"LINOK")
   If ValType(lRetPto) == "L"
      lRet := lRetPto
   EndIf
EndIf

Return( lRet )


/*
----------------------------------------------------------
--  Criacao:  21/08/04
--  Autor  : CDS
--  Descricao: Consistencia Linhas TRB Items para MsGetDB
----------------------------------------------------------
*/
Function DB_SI400LinOk(lMemoria)
Local lRet := .T., n, lEmpty:=.F., nOrdA5:=SA5->(IndexOrd())
Local lRetPto
Local cChavForn, cChavFabr
// Fazer as consistencias especiais para MsGetDB   --- CDS 23/08/04
For n:=1 to FCount()
   DO CASE
      CASE  FieldName(n) == "W1_COD_I" .AND. Empty(FieldGet(n))
            lEmpty:=.T.
      CASE  FIeldName(n) == "W1_SALDO_Q" .AND. Empty(FieldGet(n))
            lEmpty:=(TRB->W1_QTDE=0)
      CASE  FIeldName(n) == "W1_CLASS" .AND. Empty(FieldGet(n))
            lEmpty:=.T.
   ENDCASE
Next

If lEmpty
   HELP(1," ","OBRIGAT",,STR0185 + Space(50 - Len(STR0185)),3,0) //RRV - 16/10/2012 - "Verifique os itens do processo."
   lRet := .F.
Else
   If (!Empty(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ") ) .OR. (!Empty(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ"))

      If !Empty(TRB->W1_FABR) .And. !( (cChavFabr :=  xFilial("SA2")+AvKey(TRB->W1_FABR,"A2_COD")+EICRetLoja("TRB","W1_FABLOJ")) == SA2->&(IndexKey())  )
         If ! SA2->(DbSeek(cChavFabr))
            HELP(" ",1,"REGNOIS")
            lRet := .F.
         ElseIf AT(LEFT(SA2->A2_ID_FBFN,1),"13") = 0
                Help("", 1, "AVG0000495")//MsgInfo(OemtOAnsi(STR0028),STR0029) //"C¢digo n∆o se refere a fabricante"###"InformaÁ„o"
                lRet := .F.
         Endif
      Endif

      If (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_FORN)).AND. lKit
         Help(" ",1,"SI400FOMES")
         lRet:=.F.
      Endif

      If !Empty(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB","W1_FORLOJ") .And. !( (cChavForn :=  xFilial("SA2")+AvKey(TRB->W1_FORN,"A2_COD")+EICRetLoja("TRB","W1_FORLOJ")) == SA2->&(IndexKey())  )
         If ! SA2->(DbSeek(cChavForn))
            HELP(" ",1,"REGNOIS")
            lRet := .F.
         ElseIf AT(LEFT(SA2->A2_ID_FBFN,1),"23") = 0
//          MFR MTRADE-665 WCC-508648 21/03/2017
//          Help("", 1, "AVG0000492")//MsgInfo(OemToAnsi(STR0030),STR0029) //"C¢digo n∆o se refere a fornecedor"###"InformaÁ„o"
//          lRet := .F.
            if type("lSiAuto") == "L" .AND. !lSiAuto
              MsgInfo(OemToAnsi(STR0204)) //"CÛdigo n„o se refere a fornecedor"
            EndIf
            lRet := .T.
         Endif
      Endif

      nOrdA5:=SA5->(IndexOrd())

      IF !EMPTY(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ") .AND. !EMPTY(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ")
      SA5->(DbSetOrder(3))
         //If !SA5->(DbSeek(xFilial()+TRB->W1_COD_I+TRB->W1_FABR+TRB->W1_FORN))
         If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+TRB->W1_FABR+TRB->W1_FORN, EICRetLoja("TRB", "W1_FABLOJ"), EICRetLoja("TRB", "W1_FORLOJ"))
            Help("", 1, "AVG0000529")//MsgiNFO(OemtoAnsi(STR0034)) //"Produto n«o cadastrado p/ este Fabricante/Fornecedor"
            lRet := .F.
         Endif
      ENDIF

      IF !EMPTY(TRB->W1_FABR) .AND. !EICEmptyLJ("TRB", "W1_FABLOJ") .AND. EMPTY(TRB->W1_FORN) .AND. EICEmptyLJ("TRB", "W1_FORLOJ")
         SA5->(DbSetOrder(3))
         //If !SA5->(DbSeek(xFilial()+TRB->W1_COD_I+TRB->W1_FABR))
         If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+TRB->W1_FABR, EICRetLoja("TRB", "W1_FABLOJ"))
            Help("", 1, "AVG0000530")//MsgiNFO(OemtoAnsi(STR0035)) //"Produto n«o cadastrado para este Fabricante"
            lRet := .F.
         Endif
      ENDIF

      IF EMPTY(TRB->W1_FABR) .AND. EICEmptyLJ("TRB", "W1_FABLOJ") .AND. !EMPTY(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ")
         SA5->(DbSetOrder(2))
         If !SA5->(DbSeek(xFilial()+TRB->W1_COD_I+TRB->W1_FORN+ EICRetLoja("TRB","W1_FORLOJ")))
//          MFR MTRADE-665 WCC-508648 21/03/2017
//          Help("", 1, "AVG0000531")//MsgiNFO(OemtoAnsi(STR0033)) //"Produto n∆o cadastrado para este Fornecedor"
//          lRet := .F.
            if type("lSiAuto") == "L" .AND. !lSiAuto
              MsgiNFO(OemtoAnsi(STR0205)) //"Produto n„o cadastrado para este Fornecedor"
            EndIf
            lRet := .T.
         Endif
      ENDIF

      SA5->(DbSetOrder(nOrdA5))
   Endif
Endif

If (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_CLASS)).AND. lKit
   Help(" ",1,"SI400CLMES")
   lRet:=.F.
Endif

IF (! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_DTENTR_)).AND. lKit
   Help(" ",1,"SI400ENMES")
   lRet:=.F.
ENDIF


If EasyEntryPoint("EICSI400")//TDF - 01/03/10
   //13/07/13 - Tratamento para retorno diferente de lÛgico.
   lRetPto := ExecBlock("EICSI400",.F.,.F.,"DB_LINOK")
   If ValType(lRetPto) == "L"
      lRet := lRetPto
   EndIf
EndIf


Return( lRet )


*-----------------------------------------------------------------------------
FUNCTION SO110Check( NaoGravaSI )
*-----------------------------------------------------------------------------
IF ! NaoGravaSI
   DO CASE
      CASE EMPTY( Work->WKOBS )
           NaoGravaSI := .F.
      CASE LEFT(Work->WKOBS,4) == "Lote"
           NaoGravaSI := .F.
      OTHERWISE
           NaoGravaSI :=.T.
   ENDCASE
ENDIF
RETURN .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SI400Grava≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 13.07.96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Grava as nformacoes nos arquivos SZ1 e SW2.                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ EICSI400                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function SI400Grava(cAlias,cAlias1,nRecnoSW0)

LOCAL nX, nMaxArray, bCampo, nCntDel:=0
LOCAL xVar, BVar:={||.t.}, cPosicao, i, ny
//LOCAL lIntegra := (EasyGParam("MV_EASY")$cSim) //RMD - 28/09/16 - Alterada para private
LOCAL lRet:= .T.
Local nCountIt := 0 //NCF - 30/11/2017
Private lValid:= .T. //TDF - 28/10/11

PRIVATE lMsErroAuto		:= .F. //LGS-24/09/2015 - Variavel utilizada para MsExecAuto.
Private lMsHelpAuto		:= .F. //LGS-24/09/2015 - Variavel utilizada para MsExecAuto.
Private lAutoErrNoFile	:= .T. //LGS-24/09/2015 - Variavel utilizada para MsExecAuto.
Private lIntegra := (EasyGParam("MV_EASY")$cSim) //RMD - 28/09/16 - Alterada para private

If Type("lCpoCcusto") == "U"
   lCpoCCusto := (EasyGParam("MV_EASY")$cSim) .And. SW1->(FIELDPOS("W1_CTCUSTO")) > 0   //NCF - 23/06/2010 - Verifica a flag do campo de Centro de Custo
EndIf

If Type("lIntLogix") == "U"
   lIntLogix:= AvFlags("EIC_EAI")
EndIf

If lComEdit
   Return(DB_SI400Grava(cAlias,cAlias1,nRecnoSW0))
Endif

bCampo := {|nCPO| Field(nCPO) }

IF EasyEntryPoint(cArqRdmake)
   nExecute:="12"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF EasyEntryPoint("EICPSI01")
   ExecBlock("EICPSI01",.F.,.F.,"12")
ENDIF

If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"ANTES_GRAVA_SW0"),)    //TRP - 23/06/10 - Ponto de Entrada antes da gravacao do SW0.
IF lValid
dbSelectArea(cAlias)
If lInclui
   SW0->(RecLock(cAlias,.T.))
   For i := 1 TO FCount()              //GFC 21/12/03 - Integridade Referencial
      If "FILIAL"$Field(i)
         FieldPut(i,xFilial("SW0"))
      Else
         FieldPut(i,M->&(EVAL(bCampo,i)))
      EndIf
   Next i
   SW0->(msUnlock())
   SW0->(RecLock(cAlias,.F.))
Else
   SW0->(dbGoTo(nRecnoSW0))
   SW0->(RecLock(cAlias,.F.)) // Se o usuario incluir
                     // um registro pela Consulta Padrao,
                     // o SW0 e' desalocado.
   For i := 1 TO FCount()              //GFC 21/12/03 - Integridade Referencial
      If "FILIAL"$Field(i)
         FieldPut(i,xFilial("SW0"))
      Else
         FieldPut(i,M->&(EVAL(bCampo,i)))
      EndIf
   Next i
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Grava arquivo SW1                                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea("TRB")
TRB->(DBGOTOP())
aCabec   := {}
aItens   := {}
nCountIt := 0
WHILE ! TRB->(EOF())

   IF TRB->W1_QTDE == 0 .AND. Inclui
      TRB->(DBSKIP())
      LOOP
   ENDIF
   IF EMPTY(TRB->W1_COD_I)
      TRB->(DBSKIP())
      LOOP
   ENDIF
   IF lIntLogix .AND. lAltSYS
      SW1->(DBGOTO(TRB->RECNO))
      SYSAutoItens(aCabSYS)
      TRB->(DBSKIP())
      LOOP
   ENDIF
   IF TRB->RECNO <> 0
      SW1->(DBGOTO(TRB->RECNO))
      SW1->(RecLock(cAlias1,.F.))
   ELSE
      SW1->(RecLock(cAlias1,.T.))
   ENDIF
   SW1->W1_QTSEGUM  := SW1->W1_QTSEGUM  /SW1->W1_QTDE * TRB->W1_QTDE

   For ny := 1 to Len(aHeader)
       xVar:=ALLTrim(aHeader[ny][2])
       If !xVar $ 'W1_CLASS/W1_SALDO_Q/WR_NR_CONC/W1_ALI_WT/W1_REC_WT'  //WR_NR_CONC campo usado no rdmake EICSINEC
          bVar:=FIELDWBLOCK(xVar,SELECT("SW1"))
          If aHeader[ny][10] # "V"
             EVAL(bVar,EVAL(FIELDWBLOCK(xVar,SELECT("TRB"))))
          Endif
       EndIF
   Next ny

   SW1->W1_FILIAL  := xFilial('SW1')
   SW1->W1_CLASS   := TRB->W1_CLASS
   SW1->W1_SALDO_Q := TRB->W1_SALDO_Q  // ABS(SW1->W1_SALDO_Q - TRB->W1_SALDO_Q)
   SW1->W1_CC      := M->W0__CC
   SW1->W1_SI_NUM  := M->W0__NUM
   SW1->W1_REG     := TRB->W1_REG
   If SW1->(FieldPos("W1_POSIT")) # 0
      SW1->W1_POSIT   := TRB->W1_POSIT
   EndIf
   IF lForeCast
      SW1->W1_FORECAS := TRB->W1_FORECAS
   ENDIF
  //   JBS - 06/10/2003
   IF cPaisLoc # "BRA" .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
       SW1->W1_NATUREZ := TRB->W1_NATUREZ
   ENDIF

   //NCF - 22/06/2010
   If lCpoCCusto
      SW1->W1_CTCUSTO := TRB->W1_CTCUSTO
   EndIf

   If lIntegra .And. !Empty(SW0->W0_C1_NUM)//JONATO
      If SC1->(DbSeek(xFilial('SC1')+SW0->W0_C1_NUM+SW1->W1_POSICAO))

         cFil  := xFilial("SC1")
         nCountIt++ //NCF - 30/11/2017
         If nCountIt == 1//aCabec:={}
               Aadd(aCabec,{"C1_EMISSAO", SC1->C1_EMISSAO	, Nil })
               Aadd(aCabec,{"C1_SOLICIT", SC1->C1_SOLICIT	, Nil })
               AADD(aCabec,{"C1_FILIAL" , cFil           	, Nil })
               AADD(aCabec,{"C1_NUM"    , SC1->C1_NUM    	, Nil })
               AADD(aCabec,{"C1_TPOP"   , SC1->C1_TPOP   	, Nil })
               AADD(aCabec,{"C1_UNIDREQ", SC1->C1_UNIDREQ   , Nil })
               AADD(aCabec,{"C1_CODCOMP", SC1->C1_CODCOMP   , Nil })
               //AADD(aCabec,{"C1_NATUREZ", SC1->C1_NATUREZ   , Nil })
               AADD(aCabec,{"C1_FILENT" , SC1->C1_FILENT	, Nil })

         EndIf
         //aItens := {}
         Do While SC1->C1_FILIAL == xFilial('SC1') .AND. SC1->C1_NUM == SW0->W0_C1_NUM .AND. SC1->C1_ITEM == SW1->W1_POSICAO //LRS - 06/11/2017
            aItensTemp := {}
            aadd( aItensTemp , {"C1_FILIAL"	, xFilial("SC1")	, NIL           })
            aadd( aItensTemp , {"LINPOS"     ,"C1_ITEM"		    , SC1->C1_ITEM  }) //MCF - 27/01/2016
            aadd( aItensTemp , {"C1_PRODUTO"	, SC1->C1_PRODUTO	, Nil })
            aadd( aItensTemp , {"C1_UM"		, SC1->C1_UM		, Nil })

            IF GetNewPar("MV_UNIDCOM",2) == 2 .AND. SC1->C1_QTSEGUM <> 0
               aadd( aItensTemp , {"C1_QUANT"	, SW1->W1_QTSEGUM	, Nil })
               aadd( aItensTemp , {"C1_QTSEGUM"	, SW1->W1_QTDE	, Nil })
            Else
               aadd( aItensTemp , {"C1_QUANT"	, SW1->W1_QTDE	, Nil })
               aadd( aItensTemp , {"C1_QTSEGUM"	, SW1->W1_QTSEGUM	, Nil })
            EndIf
            nPos := aScan(aItensTemp,{|x| x[1] == "C1_QUANT"})
            //If aItensTemp[nPos][2] <> SC1->C1_QUANT //LRS - 05/12/2016 - nopado para Preencher o aItens
               aAdd(aItens, aClone(aItensTemp))
            //EndIf

            SC1->(DbSkip())
         EndDo
      Endif
   Endif

   IF lIntLogix
      SW1->W1_NR_CONC := TRB->W1_NR_CONC
      SW1->W1_DT_CANC := TRB->W1_DT_CANC
      SW1->W1_MOTCANC := TRB->W1_MOTCANC
      SW1->W1_C3_NUM  := TRB->W1_C3_NUM
      SW1->W1_CONDPG  := TRB->W1_CONDPG

      SB1->(DbSetOrder(1))
      If !Empty(SW1->W1_COD_I) .And. SB1->(DbSeek(xFilial()+SW1->W1_COD_I))  //SSS - REQ 6.2 INCLUSAO CAMPO W1_UM
         SW1->W1_UM   := SB1->B1_UM
      EndIf

      SW1->W1_STATUS  := SetW1Status()
      ELDAutoItens(aCabELD)
      SYSAutoItens(aCabSYS)
   ENDIF

   If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"GravaSW1"),)
   IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"3"),)
   IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"3"),)

   SW1->(MSUNLOCK())
   TRB->(DBSKIP())

End

If Len(aCabec) > 0 .And. Len(aItens) > 0  //NCF - 30/11/2017
   aHeader:={}
   lMsErroAuto := .F.
   MsExecAuto({|a,b,c| MATA110(a,b,c) },aCabec,aItens,4)
   If lMsErroAuto
      lRet  := .F.
      cErro := STR0200 + ENTER + StrTran(STR0199, "#ITEM#", cValToChar(AllTrim(SC1->C1_PRODUTO))) //Problema
      cErro := StrTran(cErro,   "#SC#"  , cValToChar(AllTrim(SC1->C1_NUM))) + ENTER + ENTER
      aErro := GetAutoGRLog() //Retorna array com o erro do msexecauto.
      cErro += STR0201 + ENTER//Motivo
      For i:=1 To Len(aErro)
         cErro += aErro[i] + ENTER
      Next
      MsgInfo(cErro,STR0040)
   EndIf
EndIf
aCabec   := {}
aItens   := {}
nCountIt := 0
If !lIntLogix  // GFP - 17/08/2016
SC1->(DBSETORDER(1))
For nY :=1  to Len(aSI400Del)
   nCntDel ++
   If aSI400Del[nY] != 0
      SW1->(dbGoTo(aSI400Del[nY]))
      cPosicao:= SW1->W1_POSICAO
      //SW1->(RecLock("SW1",.F.)) MCF - Alterado para caso dÍ erro no MsExecauto n„o exclua a SI.
      IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"4"),)
      If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"GRV_DELET"),)
      //SW1->(dbDelete())
      //SW1->(MSUnlock())

      If lIntegra .And. !Empty(M->W0_C1_NUM)
         If SC1->(DbSeek(xFilial('SC1')+M->W0_C1_NUM+cPosicao))
            /*RecLock("SC1",.F.)
            SC1->C1_COTACAO:='IMPORT'
            SC1->C1_NUM_SI :=''
            SC1->(MsUnlock())*/
            cFil  := xFilial("SC1")
            //aCabec:={}
            nCountIt++
            If nCountIt == 1 //NCF - 30/11/2017
               Aadd(aCabec,{"C1_EMISSAO", SC1->C1_EMISSAO	, Nil })
               Aadd(aCabec,{"C1_SOLICIT", SC1->C1_SOLICIT	, Nil })
               AADD(aCabec,{"C1_FILIAL" , cFil           	, Nil })
               AADD(aCabec,{"C1_NUM"    , SC1->C1_NUM    	, Nil })
               AADD(aCabec,{"C1_TPOP"   , SC1->C1_TPOP   	, Nil })
               AADD(aCabec,{"C1_UNIDREQ", SC1->C1_UNIDREQ   , Nil })
               AADD(aCabec,{"C1_CODCOMP", SC1->C1_CODCOMP   , Nil })
               //AADD(aCabec,{"C1_NATUREZ", SC1->C1_NATUREZ   , Nil })
               AADD(aCabec,{"C1_FILENT" , SC1->C1_FILENT	, Nil })
            EndIf
            //aItens := {}
            Do While SC1->C1_FILIAL == xFilial('SC1') .AND. SC1->C1_NUM == SW0->W0_C1_NUM .AND. SC1->C1_ITEM == SW1->W1_POSICAO //LRS - 06/11/2017
               aItensTemp := {}
               aadd( aItensTemp , {"C1_FILIAL"      , xFilial("SC1")	, NIL         })
               //aadd( aItensTemp , {"LINPOS"         , "C1_ITEM"		    , SC1->C1_ITEM}) //MCF - 26/01/2016
               aadd( aItensTemp , {"C1_ITEM"		, SC1->C1_ITEM      , Nil    })
               aadd( aItensTemp , {"C1_PRODUTO" 	, SC1->C1_PRODUTO	, Nil    })
               //aadd( aItensTemp , {"C1_COTACAO"	, "IMPORT"			, Nil      })
               aadd( aItensTemp , {"C1_NUM_SI"  	, ""              , Nil    })

                aadd( aItensTemp , {"C1_QUANT"  	, SC1->C1_QUANT  , Nil    })
               aAdd(aItens, aClone(aItensTemp))
               SC1->(DbSkip())
            EndDo
         Else
            Help("", 1, "AVG0000532",,M->W0_C1_NUM+STR0038+Right(cPosicao,2),1,24)//MsgStop(STR0037+M->W0_C1_NUM+STR0038+; //"Solicitacao de Compras "###" nao encontrada - item "
            lRet:= .F.
         Endif
      Else
         SW1->(RecLock("SW1",.F.)) //MCF - 26/01/2016
         SW1->(dbDelete())
         SW1->(MSUnlock())
      Endif
   Endif
Next nY

   If Len(aCabec) > 0 .And. Len(aItens) > 0  //NCF - 30/11/2017
      aHeader:={}
      lMsErroAuto := .F.
      MsExecAuto({|a,b,c| MATA110(a,b,c) },aCabec,aItens,4)

      If lMsErroAuto
         lRet  := .F.
         cErro := STR0200 + ENTER + StrTran(STR0199, "#ITEM#", cValToChar(AllTrim(SC1->C1_PRODUTO))) //Problema
         cErro := StrTran(cErro,   "#SC#"  , cValToChar(AllTrim(SC1->C1_NUM))) + ENTER + ENTER
         aErro := GetAutoGRLog() //Retorna array com o erro do msexecauto.
         cErro += STR0201 + ENTER//Motivo
         For i:=1 To Len(aErro)
            cErro += aErro[i] + ENTER
         Next
         MsgInfo(cErro,STR0040)
      Else
         SW1->(RecLock("SW1",.F.)) //MCF - 26/01/2016
         SW1->(dbDelete())
         SW1->(MSUnlock())
      EndIf
   EndIf   

EndIf
//MFR 09/12/2019 OSSME-4082
//If nCntDel == TRB->(Easyreccount("TRB"))
If 0 == TRB->(Easyreccount("TRB"))
   SW0->(DBDELETE())
Else
   dbSelectArea(cAlias)
   //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
   //≥ Grava arquivo SW0                                            ≥
   //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
   /*For i := 1 TO FCount()                    //GFC 21/12/03 - Integridade Referencial
      If "FILIAL"$Field(i)
         FieldPut(i,xFilial("SW0"))
      Else
         FieldPut(i,M->&(EVAL(bCampo,i)))
      EndIf
   Next i */

   IF EasyEntryPoint(cArqRdmake)
      nExecute:="3"
      ExecBlock(cArqRdmake,.F.,.F.)
   ENDIF
   IF EasyEntryPoint("EICPSI01")
      ExecBlock("EICPSI01",.F.,.F.,"3")
   ENDIF

Endif

EndIf
//DFS - Ponto de entrada no momento da gravaÁ„o de inclus„o e alteraÁ„o
If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"GRV_INCALT"),)

dbSelectArea(cAlias)
//Return( .T. )
Return lRet


/*
-----------------------------------------------------------------------------
-- Funcao: DB_SI400Grava
-- Autor : CDS
-- Data  : 23.08.04
-- Descricao:  Grava as nformacoes nos arquivos SW0 e SW1 para MSGetDB.
-----------------------------------------------------------------------------
*/
Function DB_SI400Grava(cAlias,cAlias1,nRecnoSW0)

LOCAL nX, nMaxArray, bCampo, nCntDel:=0
LOCAL xVar, BVar:={||.t.}, cPosicao, i, ny
//LOCAL lIntegra := (EasyGParam("MV_EASY")$cSim) //RMD - 28/09/16 - Alterada para private
Local aChaves
Local lRet := .T. //CRF - 19/07/2011
Local nCountIt          := 0 
PRIVATE lMsErroAuto		:= .F. //LGS-24/09/2015 - Variavel utilizada para MsExecAuto.
Private lMsHelpAuto		:= .F. //LGS-24/09/2015 - Variavel utilizada para MsExecAuto.
Private lAutoErrNoFile	:= .T. //LGS-24/09/2015 - Variavel utilizada para MsExecAuto.
Private lIntegra := (EasyGParam("MV_EASY")$cSim) //RMD - 28/09/16 - Alterada para private

Private lValid:= .T.

If Type("lPOAuto") == "U"
   lPOAuto:= .F.
EndIf

If AvFlags("WORKFLOW")
   aChaves := EasyGroupWF("SOLIC IMPORT")
Endif

bCampo := {|nCPO| Field(nCPO) }

IF EasyEntryPoint(cArqRdmake)
   nExecute:="12"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF EasyEntryPoint("EICPSI01")
   ExecBlock("EICPSI01",.F.,.F.,"12")
ENDIF

If Type("lIntLogix") == "U"
   lIntLogix:= AvFlags("EIC_EAI")
EndIf

If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"ANTES_GRAVA_SW0"),)    //TRP - 23/06/10 - Ponto de Entrada antes da gravacao do SW0.

If lValid
dbSelectArea(cAlias)
If lInclui
   SW0->(RecLock(cAlias,.T.))
   For i := 1 TO FCount()              //GFC 21/12/03 - Integridade Referencial
      If "FILIAL"$Field(i)
         FieldPut(i,xFilial("SW0"))
      Else
         FieldPut(i,M->&(EVAL(bCampo,i)))
      EndIf
   Next i
   SW0->(msUnlock())
   SW0->(RecLock(cAlias,.F.))
Else
   SW0->(dbGoTo(nRecnoSW0))
   SW0->(RecLock(cAlias,.F.)) // Se o usuario incluir
		                      // um registro pela Consulta Padrao,
        		              // o SW0 e' desalocado.
   For i := 1 TO FCount()     //GFC 21/12/03 - Integridade Referencial
      If "FILIAL"$Field(i)
         FieldPut(i,xFilial("SW0"))
      Else
         FieldPut(i,M->&(EVAL(bCampo,i)))
      EndIf
   Next i
Endif

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Grava arquivo SW1                                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea("TRB")
TRB->(DBSetOrder(0))            //CDS
TRB->(DBGOTOP())
aCabec := {}
aItens := {} //LRS - 06/11/2017
nCountIt := 0
WHILE ! TRB->(EOF())

   IF TRB->W1_FLAG == .F.			//Checar Registro Nao Apagado. CDS  23/08/04

      IF TRB->W1_QTDE == 0 .AND. Inclui
         TRB->(DBSKIP())
         LOOP
      ENDIF
      IF EMPTY(TRB->W1_COD_I)
         TRB->(DBSKIP()) ; LOOP
      ENDIF

      IF TRB->RECNO <> 0
         SW1->(DBGOTO(TRB->RECNO))
         SW1->(RecLock(cAlias1,.F.))
         nOpcELD := 4
      ElseIf TRB->W1_FLAG==.F.				//CDS 23/08/04
         SW1->(RecLock(cAlias1,.T.))
         nOpcELD := 3
      EndIf
      SW1->W1_QTSEGUM  := SW1->W1_QTSEGUM  /SW1->W1_QTDE * TRB->W1_QTDE
      For ny := 1 to Len(aHeader)
         xVar:=ALLTrim(aHeader[ny][2])
         If !xVar $ 'W1_CLASS/W1_SALDO_Q/WR_NR_CONC/W1_ALI_WT/W1_REC_WT'  //WR_NR_CONC campo usado no rdmake EICSINEC
            bVar:=FIELDWBLOCK(xVar,SELECT("SW1"))
            If aHeader[ny][10] # "V" // BHF - 31/10/08 - Tratado para campo customizado.
               EVAL(bVar,EVAL(FIELDWBLOCK(xVar,SELECT("TRB"))))
            Endif
         EndIF
      Next ny

      SW1->W1_FILIAL  := xFilial('SW1')
      SW1->W1_CLASS   := TRB->W1_CLASS
      If lSIAuto .AND. lPOAuto .AND. nOpcAuto == 4  // GFP - 06/12/2013
         SW1->W1_QTDE := SW1->W1_QTDE + TRB->W1_SALDO_Q
         SW1->W1_SALDO_Q := SW1->W1_SALDO_Q + TRB->W1_SALDO_Q
      Else
         SW1->W1_SALDO_Q := TRB->W1_SALDO_Q  // ABS(SW1->W1_SALDO_Q - TRB->W1_SALDO_Q)
      EndIf
      SW1->W1_CC      := M->W0__CC
      SW1->W1_SI_NUM  := M->W0__NUM
      SW1->W1_REG     := TRB->W1_REG
      If SW1->(FieldPos("W1_POSIT")) # 0
         SW1->W1_POSIT   := TRB->W1_POSIT
      EndIf
      IF lForeCast
         SW1->W1_FORECAS := TRB->W1_FORECAS
      ENDIF
     //   JBS - 06/10/2003
      IF cPaisLoc # "BRA" .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
         SW1->W1_NATUREZ := TRB->W1_NATUREZ
      ENDIF

      //NCF - 22/06/2010
      If lCpoCCusto
         SW1->W1_CTCUSTO := TRB->W1_CTCUSTO
      EndIf

      If lIntegra .And. !Empty(SW0->W0_C1_NUM)//JONATO
         If SC1->(DbSeek(xFilial('SC1')+SW0->W0_C1_NUM+SW1->W1_POSICAO))
         /*RecLock("SC1",.F.)
         IF GetNewPar("MV_UNIDCOM",2) == 2 .AND. SC1->C1_QTSEGUM <> 0 // JBS - 23/06/2004
            SC1->C1_QUANT  := SW1->W1_QTSEGUM
            SC1->C1_QTSEGUM:= SW1->W1_QTDE
         ELSE
            SC1->C1_QUANT  := SW1->W1_QTDE
            SC1->C1_QTSEGUM:= SW1->W1_QTSEGUM
         ENDIF*/
            cFil  := xFilial("SC1")
            nCountIt++
            If nCountIt == 1//aCabec:={}
               Aadd(aCabec,{"C1_EMISSAO", SC1->C1_EMISSAO, Nil })
               Aadd(aCabec,{"C1_SOLICIT", SC1->C1_SOLICIT, Nil })
               AADD(aCabec,{"C1_FILIAL" , cFil           , Nil })
               AADD(aCabec,{"C1_NUM"    , SC1->C1_NUM    , Nil })
            EndIf

            //aItens := {}                                                                                                            //MFR 04/02/2020 OSSME-4264   
            Do While SC1->C1_FILIAL == xFilial('SC1') .AND. SC1->C1_NUM == SW0->W0_C1_NUM .AND. SC1->C1_ITEM == SW1->W1_POSICAO .AND. SC1->C1_QUANT != TRB->W1_QTDE//LRS - 06/11/2017
               aItensTemp := {} 
            
               //if /*SC1->C1_ITEM == SW1->W1_POSICAO .and.*/ SW1->W1_SALDO_Q == SW1->W1_QTDE //WHRS TE-4896 505176 / MTRADE-508 - Ao excluir um item do PO e depois da SI(quando gerada atravÈs da SC) sistema apresenta msg incorretamente
               aadd( aItensTemp , {"C1_FILIAL"	, xFilial("SC1")	, NIL          })
	           aadd( aItensTemp , {"LINPOS"     ,"C1_ITEM"		   , SC1->C1_ITEM	 })
	           aadd( aItensTemp , {"C1_PRODUTO"	, SC1->C1_PRODUTO	, Nil          })
	           aadd( aItensTemp , {"C1_UM"		, SC1->C1_UM		, Nil          })
	
	           IF GetNewPar("MV_UNIDCOM",2) == 2 .AND. SC1->C1_QTSEGUM <> 0
	              aadd( aItensTemp , {"C1_QUANT"	, SW1->W1_QTSEGUM	, Nil })
	              aadd( aItensTemp , {"C1_QTSEGUM"	, SW1->W1_QTDE	, Nil })
	           Else
	              aadd( aItensTemp , {"C1_QUANT"	, SW1->W1_QTDE	, Nil })
	              aadd( aItensTemp , {"C1_QTSEGUM"	, SW1->W1_QTSEGUM	, Nil })
	           EndIf
	           nPos := aScan(aItensTemp,{|x| x[1] == "C1_QUANT"})
	           //If aItensTemp[nPos][2] <> SC1->C1_QUANT //LRS - 05/12/2016 - nopado para Preencher o aItens
	           aAdd(aItens, aClone(aItensTemp))
	           //EndI
               //endIf
               SC1->(DbSkip())
            EndDo
         Endif
      Endif
      IF lIntLogix
         SW1->W1_C3_NUM  := TRB->W1_C3_NUM
         SW1->W1_STATUS  := SetW1Status()
         SW1->W1_NR_CONC := TRB->W1_NR_CONC
         SW1->W1_DT_CANC := TRB->W1_DT_CANC
         SW1->W1_MOTCANC := TRB->W1_MOTCANC
         SW1->W1_COMPLEM := TRB->W1_COMPLEM//IGOR CHIBA COLOCAR GRAVACAO AKI
         SW1->W1_CONDPG  := TRB->W1_CONDPG

         SB1->(DbSetOrder(1))
         If !Empty(SW1->W1_COD_I) .And. SB1->(DbSeek(xFilial()+SW1->W1_COD_I)) //SSS - REQ 6.2 INCLUSAO CAMPO W1_UM
            SW1->W1_UM   := SB1->B1_UM
         EndIf

         ELDAutoItens(aCabELD)
         SYSAutoItens(aCabSYS)
      ENDIF

      If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"GravaSW1"),)
      IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"3"),)
      IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"3"),)

      // BAK - GravaÁ„o do campo do codigo da matriz de tributacao
      If SW1->(FieldPos("W1_CODMAT")) > 0 .And. TRB->(FieldPos("W1_CODMAT")) > 0 .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
         SW1->W1_CODMAT := TRB->W1_CODMAT
      EndIf
   Else

      IF TRB->RECNO <> 0
         SW1->(DBGOTO(TRB->RECNO))
         SW1->(RECLOCK("SW1",.F.))
	     SW1->(dbDelete())
	     SW1->(MSUNLOCK())
      Endif

   Endif

   TRB->(DBSKIP())

EndDo

if len(aItens) > 0 //LRS - 06/11/2017
    aHeader := {}
    lMsErroAuto := .F.
    MsExecAuto({|a,b,c| MATA110(a,b,c) },aCabec,aItens,4)
    If lMsErroAuto
        lRet  := .F.
        cErro := STR0200 + ENTER + StrTran(STR0199, "#ITEM#", cValToChar(AllTrim(SC1->C1_PRODUTO))) //Problema
        cErro := StrTran(cErro,   "#SC#"  , cValToChar(AllTrim(SC1->C1_NUM))) + ENTER + ENTER
        aErro := GetAutoGRLog() //Retorna array com o erro do msexecauto.
        cErro += STR0201 + ENTER//Motivo
        For i:=1 To Len(aErro)
            cErro += aErro[i] + ENTER
        Next
        MsgInfo(cErro,STR0040)
        RollBackDelTran("")
        Return
    EndIf
endIF
aCabec   := {}
aItens   := {}
nCountIt := 0
If lIntegra
   If(Select("SC1") == 0,ChkFile("SC1"),)
   SC1->(DBSETORDER(1))
   For nY :=1  to Len(aSI400Del)
      nCntDel ++
      If aSI400Del[nY] != 0
         SW1->(dbGoTo(aSI400Del[nY]))
         cPosicao:= SW1->W1_POSICAO
         //SW1->(RecLock("SW1",.F.)) MCF - Alterado para caso dÍ erro no MsExecauto n„o exclua a SI.
         IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"4"),)
         If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"GRV_DELET"),)
         //SW1->(dbDelete())
         //SW1->(MSUnlock())

         If lIntegra .And. !Empty(M->W0_C1_NUM)
            If SC1->(DbSeek(xFilial('SC1')+M->W0_C1_NUM+cPosicao))
               /*RecLock("SC1",.F.)
               SC1->C1_COTACAO:='IMPORT'
               SC1->C1_NUM_SI :=''
               SC1->(MsUnlock())*/
               cFil  := xFilial("SC1")              
               nCountIt++
               If nCountIt == 1 //aCabec:={}
                Aadd(aCabec,{"C1_EMISSAO", SC1->C1_EMISSAO	, Nil })
                Aadd(aCabec,{"C1_SOLICIT", SC1->C1_SOLICIT	, Nil })
                AADD(aCabec,{"C1_FILIAL" , cFil           	, Nil })
                AADD(aCabec,{"C1_NUM"    , SC1->C1_NUM    	, Nil })
                AADD(aCabec,{"C1_TPOP"   , SC1->C1_TPOP   	, Nil })
                AADD(aCabec,{"C1_UNIDREQ", SC1->C1_UNIDREQ  , Nil })
                AADD(aCabec,{"C1_CODCOMP", SC1->C1_CODCOMP  , Nil })
                AADD(aCabec,{"C1_FILENT" , SC1->C1_FILENT	, Nil })
               EndIf
               //aItens := {}
                Do While SC1->C1_FILIAL == xFilial('SC1') .AND. SC1->C1_NUM == SW0->W0_C1_NUM .AND. SC1->C1_ITEM == SW1->W1_POSICAO //LRS - 06/11/2017
                    aItensTemp := {}
                    aadd( aItensTemp , {"C1_FILIAL"	, xFilial("SC1")	, NIL          })
                    aadd( aItensTemp , {"LINPOS"        , "C1_ITEM"         , SC1->C1_ITEM}) //MCF - 26/01/2016
                    //aadd( aItensTemp , {"C1_ITEM"		, SC1->C1_ITEM      , Nil    })
                    aadd( aItensTemp , {"C1_PRODUTO" 	, SC1->C1_PRODUTO	, Nil          })
                    aadd( aItensTemp , {"C1_QUANT"    	, SC1->C1_QUANT     , Nil          })
                    aadd( aItensTemp , {"C1_COTACAO"     , "IMPORT"          , Nil          })
                    aadd( aItensTemp , {"C1_NUM_SI"  	   , ""                , Nil          })
                    aAdd(aItens, aClone(aItensTemp))
                    SC1->(DbSkip())
                EndDo

            Else
               Help("", 1, "AVG0000532",,M->W0_C1_NUM+STR0038+Right(cPosicao,2),1,24)//MsgStop(STR0037+M->W0_C1_NUM+STR0038+; //"Solicitacao de Compras "###" nao encontrada - item "
               lRet:= .F.
            Endif
         Else
            SW1->(RecLock("SW1",.F.)) //MCF - 26/01/2016
            SW1->(dbDelete())
            SW1->(MSUnlock())
         Endif
      Endif
   Next nY
        if len(aItens) > 0 //LRS - 06/11/2017
           aHeader := {}
	        lMsErroAuto := .F.
	        MsExecAuto({|a,b,c| MATA110(a,b,c) },aCabec,aItens,4)
	
	        If lMsErroAuto
	            lRet  := .F.
	            cErro := STR0200 + ENTER + StrTran(STR0199, "#ITEM#", cValToChar(AllTrim(SC1->C1_PRODUTO))) //Problema
	            cErro := StrTran(cErro,   "#SC#"  , cValToChar(AllTrim(SC1->C1_NUM))) + ENTER + ENTER
	            aErro := GetAutoGRLog() //Retorna array com o erro do msexecauto.
	            cErro += STR0201 + ENTER//Motivo
	            For i:=1 To Len(aErro)
	                cErro += aErro[i] + ENTER
	            Next
	            MsgInfo(cErro,STR0040)
	        Else
	            SW1->(RecLock("SW1",.F.)) //MCF - 26/01/2016
	            SW1->(dbDelete())
	            SW1->(MSUnlock())
	        EndIf
        EndIF
EndIf

If nCntDel == TRB->(Easyreccount("TRB"))
   SW0->(DBDELETE())
Else
   dbSelectArea(cAlias)
   //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
   //≥ Grava arquivo SW0                                            ≥
   //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
   /*For i := 1 TO FCount()                    //GFC 21/12/03 - Integridade Referencial
      If "FILIAL"$Field(i)
         FieldPut(i,xFilial("SW0"))
      Else
         FieldPut(i,M->&(EVAL(bCampo,i)))
      EndIf
   Next i */

   IF EasyEntryPoint(cArqRdmake)
      nExecute:="3"
      ExecBlock(cArqRdmake,.F.,.F.)
   ENDIF
   IF EasyEntryPoint("EICPSI01")
      ExecBlock("EICPSI01",.F.,.F.,"3")
   ENDIF

Endif
EndIf

//DFS - Ponto de entrada no momento da gravaÁ„o de inclus„o e alteraÁ„o
If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"GRV_INCALT"),)

// *** GFP - 17/03/2011 :: 15h10 - Tratamento de WorkFlow na SI.
If AvFlags("WORKFLOW")
   EasyGroupWF("SOLIC IMPORT",aChaves)
Endif

/*
If lEasyWorkFlow
   SX2->(DbSetOrder(1))
   If SX2->(DbSeek("EJ7"))
      EJ7->(DbSetOrder(1))
      If EJ7->(DbSeek(xFilial("EJ7")+AvKey("SI","EJ7_COD"))) .AND. EJ7->EJ7_ATIVO == "1" .AND. EJ7->EJ7_OPCENV == "1"
         oWorkFlow := EasyWorkFlow():New("SI", SW0->(W0_FILIAL+W0__CC+W0__NUM))
         oWorkFlow:Send()
      Endif
   Endif
Endif
*/

// *** Fim GFP

dbSelectArea(cAlias)
//Return( .T. )
Return lRet

*-----------------------------------*
FUNCTION SI400VldClass(cVar, lDescri)
*-----------------------------------*
LOCAL lRet

Default lDescri := .F.

If ! lDescri
   lRet := SX5->(dbSeek(xFilial()+'Y1'+AvKey(cVar, "X5_TABELA"))) //MCF - 15/07/2015

   If ! lRet
      Help(" ",1,"NO66SX5")
   Endif
Else
   lRet := !Empty( si400SX5(cVar) )
Endif

If lRet
   M->W1_VMCLASS := SX5->(X5DESCRI())
EndIF

Return lRet

*-----------------------------------------------------
Function SI400SX5(cDescri)
*-----------------------------------------------------
Local cCod := ""

SX5->(dbSeek(xFilial()+"Y1"))
While SX5->X5_FILIAL==xFILIAL("SX5") .AND. SX5->X5_TABELA=='Y1'
   If UPPER(ALLTRIM(X5DESCRI()))=UPPER(ALLTRIM(cDescri))
      cCod := SX5->X5_CHAVE
      Exit
   Endif
   SX5->(dbSkip())
End

If Empty(cCod)
   Help(" ",1,"NO66SX5")
Endif

Return cCod

*----------------------------------------------------------------------------
FUNCTION SI400Valid()
*----------------------------------------------------------------------------
// Ultima Modific:  23/08/04  para MsGetDB
// Autor: CDS
// CHAMADA A PARTIR DO SX3
LOCAL cCampo := Subs(READVAR(),4),lRet:=.T.
LOCAL uData  := &(Readvar())
LOCAL TPRAZO1:= 0,TPRAZO2:=0,TPRAZO2A:=0,TPRAZO2B:=0
LOCAL TLead  := 0,lInc:=.F.

If lComEdit
  Return(DB_SI400Valid())
Endif

IF EasyEntryPoint(cArqRdmake) .AND. cCampo == "W0__CC"
   nExecute:="9"
   lRet:=ExecBlock(cArqRdmake,.F.,.F.)
   RETURN lRet
ENDIF

IF EasyEntryPoint("EICPSI01")
   lRet:=ExecBlock("EICPSI01",.F.,.F.,"9")
   RETURN lRet
ENDIF

IF ! SI400KitValid()
   RETURN .F.
ENDIF

DO CASE
   CASE cCampo == "W1_DTENTR_"

     IF !EMPTY(M->W1_DTENTR_)
        If M->W1_DT_EMB > M->W1_DTENTR_
           Help(" ",1,"SI400EMBMA")
           Return ( lRet := .F. )
        Endif
     Endif

     If !AvFlags("EIC_EAI") .And. uData < M->W0__DT //wfs - n„o validar a data de entrega programada, recebida do ERP, mantendo o histÛrico e consistÍncia com a origem
        HELP(" ",1,"DTENTSI")
        lRet:=.F.
     Else
        If !Empty(M->W1_FABR) .AND. !EICEmptyLJ("M", "W1_FABLOJ") .and. !Empty(M->W1_FORN) .AND. !EICEmptyLJ("M", "W1_FORLOJ")
           SA5->(DBSetOrder(3))
           //SA5->(DBSeek(xFilial()+M->W1_COD_I+M->W1_FABR+M->W1_FORN))
           If EICSFabFor(xFilial("SA5")+M->W1_COD_I+M->W1_FABR+M->W1_FORN, EICRetLoja("M", "W1_FABLOJ"), EICRetLoja("M", "W1_FORLOJ"))
           TLead := SA5->A5_LEAD_T
           Endif
        Endif

        nLtComp  := EasyGParam("MV_LT_COMP")
        nLtDese  := EasyGParam("MV_LT_DESE")
        nLtLice  := EasyGParam("MV_LT_LICE")
        TPrazo1  := uData - M->W0__DT
        TPrazo2A := TLead + nLtComp  + nLtDese
        TPrazo2B := nLtComp + nLtLice + nLtDese
        IF TPrazo2A > TPrazo2B
           TPrazo2 := TPrazo2A
        ELSE
           TPrazo2 := TPrazo2B
        ENDIF
        IF TPrazo1 < TPrazo2 .And. !IsBlind()
           Help("", 1, "AVG0000533")//MSGSTOP(OemtoAnsi(STR0039),OemToAnsi(STR0040)) //"LEAD TIME operacional inviabiliza o atendimento deste(s) item(s)."###"ATENCAO"
        ENDIF
     Endif

   CASE cCampo == "W1_QTDE"
      If !lInclui
         MsgInfo(STR0147) //"Quantidade n‰o pode ser editada na Alteracao."
      Else
         M->W1_SALDO_Q := uData
      EndIf

   CASE cCampo == "W1_SALDO_Q"

      Begin Sequence

	      If !Empty(M->W0_C1_NUM) //MCF - 25/02/2016
	         If lVldSaldo .And. TRB->W1_SALDO_Q == 0 .And. TRB->RECNO <> 0 //RMD - 28/09/16 - Permite desabilitar a validaÁ„o via ponto de entrada.
	            EasyHelp(STR0202,STR0002) //"SolicitaÁ„o de ImportaÁ„o n„o pode ser alterada, pois seu saldo foi completamente consumido em um Purchase Order. Favor inclua um novo item com o saldo desejado."
	            lRet := .F.
	            Break
	         EndIf
	      EndIf

	      If lInclui
	         MsgInfo(STR0148) //"Saldo N‰o pode ser preenchido na Inclus‰o."
	      Else
	       // Jacomo Lisa -01/08/2014- Incluida a ValidaÁ„o quando for integrado com o Logix, N„o permitir alterar o saldo/QTD qndo os Status estiverem C,E e F
	        IF lIntLogix
	           IF M->W1_STATUS # "F"//AWF - 11/08/2014
	              M->W1_QTDE    := uData
	              M->W1_SALDO_Q := uData
	           ENDIF
	           Return .T.
	        ENDIF
	        M->W1_QTDE := M->QTDE
	        If uData # M->SALDO
	           M->W1_SALDO_Q := uData
	           M->W1_QTDE    := IF(inclui,uData,(uDATA - M->SALDO) + M->QTDE )
	        Endif
	        lRefresh:=.t.
	      EndIf
     End Sequence

   CASE cCampo == "W1_FABR"
        If !Empty(uData) .AND. !Empty(EICRetLoja("M", "W1_FABLOJ"))
           SA5->(DBSetOrder(3))
           //if !SA5->(DBSeek(xFilial()+M->W1_COD_I+Alltrim(uData)))
           If !EICSFabFor(xFilial("SA5")+M->W1_COD_I+AvKey(uData,"W1_FABR"), EICRetLoja("M", "W1_FABLOJ"))   //FSM - 29/07/2011
               MsgInfo(STR0149) // LRL 22/01/04 HELP(" ",1,"NOPRODFABR")
              lRet:=.F.
           Endif
        Endif

        //DFS - 16/02/12 - Inclus„o de tratamento de kit para que, ao mudar o fabricante, mude o valor do produto de acordo com o cadastro do mesmo.
        //TDF - 07/05/12 - Tratamento deve ser feito para SI normal e com Kit
        //IF lKit
           IF EICSFabFor(xFilial("SA5")+M->W1_COD_I+Alltrim(uData), EICRetLoja("M", "W1_FABLOJ"))
              IF SA5->A5_MOE_US == M->W0_MOEDA
                 M->W1_PRECO:= SA5->A5_VLCOTUS
              ENDIF
           ENDIF
        //ENDIF

        //FDR - 18/02/2013 - Verifica se o fabricante selecionado encontra-se bloqueado para uso
        DBSELECTAREA("SA2")
        SA2->(DBSETORDER(1))

        IF !Empty(uData) //LRS - 13/02/2015 - Caso o W1_FORLOJ no TRB esteja vazio, n„o vai achar o Fornecedor Bloqueado, forÁando a uma nova pesquisa
	        If lRet .And. SA2->(DBSeek(xFilial("SA2") + AvKey(uData,"A5_FORN") + EICRetLoja("TRB", "W1_FORLOJ")))
	           If SA2->A2_MSBLQL == "1"
	              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
	              lRet := .F.
	              M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	              TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
	           EndIf
	        ElseIF lRet .And. SA2->(DBSEEK(xFilial("SA2")+SA5->A5_FABR+SA5->A5_FALOJA)) .AND. !Empty(EICRetLoja("M", "W1_FABLOJ"))
	          If SA2->A2_MSBLQL == "1"
	              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
	              lRet := .F.
	              M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	              TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
	           EndIf
	        EndIf
        Else
           lRet := .F.
           M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
           TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
        EndIF

   CASE cCampo == "W1_FABLOJ"
        If !Empty(uData)
           SA5->(DBSetOrder(3))
           //if !SA5->(DBSeek(xFilial()+M->W1_COD_I+Alltrim(uData)))
           If !EICSFabFor(xFilial("SA5")+M->(W1_COD_I+W1_FABR), uData)
               MsgInfo(STR0149) // LRL 22/01/04 HELP(" ",1,"NOPRODFABR")
              lRet:=.F.
           Endif
        Endif

   CASE cCampo == "W1_FORN"
        If !Empty(uData) .AND. !Empty(EICRetLoja("M", "W1_FORLOJ"))
           SA5->(DBSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
           If AvFlags("EIC_EAI") //n„o validar o fabricante
              If !SA5->(DBSeek(xFilial()+M->W1_COD_I+AvKey(uData,"W1_FORN")+EICRetLoja("M","W1_FORLOJ")))  //FSM - 29/07/2011
                 MsgInfo(STR0150) //"Item N‰o encontrado no SA5 para este fornecedor." // LRL 22/01/04 HELP(" ",1,"NOPRODFORN")
                 lRet:=.F.
              EndIf
           Else
              If !EICSFabFor(xFilial("SA5")+M->W1_COD_I+M->W1_FABR+AvKey(uData,"W1_FORN"),EICRetLoja("M", "W1_FORLOJ")) // GFP - 13/03/2014
                 MsgInfo(STR0150) //"Item N‰o encontrado no SA5 para este fornecedor." // LRL 22/01/04 HELP(" ",1,"NOPRODFORN")
                 lRet:=.F.
              Endif
           EndIf
        Endif

        //FDR - 20/02/2013 - Verifica se o fornecedor selecionado encontra-se bloqueado para uso
        DBSELECTAREA("SA2")
        SA2->(DBSETORDER(1))

        IF !Empty(uData) //LRS - 13/02/2015 - Caso o W1_FORLOJ no TRB esteja vazio, n„o vai achar o Fornecedor Bloqueado, forÁando a uma nova pesquisa
	        IF !Empty(TRB->W1_FABR) .And. !Empty(TRB->W1_FABLOJ)
	          IF lRet .And. SA2->(DBSEEK(xFilial("SA2")+TRB->W1_FABR+TRB->W1_FABLOJ)) //LRS  Caso o Fornecedor esteja bloqueado, n„o permitir ser preenchido
	              If SA2->A2_MSBLQL == "1"
		              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
		              lRet := .F.
	                  M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	                  TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:="""
	              EndIF
	          EndIF
	        EndIF
	        If lRet .And. SA2->(DBSeek(xFilial("SA2") + AvKey(uData,"A5_FORN") + EICRetLoja("TRB", "W1_FORLOJ")))
	           If SA2->A2_MSBLQL == "1"
	              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
	              lRet := .F.
	              M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	              TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
	           EndIf
	        ElseIF lRet .And. SA2->(DBSEEK(xFilial("SA2")+SA5->A5_FABR+SA5->A5_FALOJA)) .AND. !Empty(EICRetLoja("M", "W1_FORLOJ"))
	          If SA2->A2_MSBLQL == "1"
	              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
	              lRet := .F.
	              M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	              TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
	           EndIf
	        EndIf
        Else
           lRet := .F.
           M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
           TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
        EndIF

   CASE cCampo == "W1_FORLOJ"
        If !Empty(uData)
           SA5->(DBSetOrder(2))
           if !SA5->(DBSeek(xFilial()+M->(W1_COD_I+W1_FORN)+uData))
               MsgInfo(STR0150) // LRL 22/01/04 HELP(" ",1,"NOPRODFORN")
              lRet:=.F.
           Endif
        Endif
   //Case cCampo == "W1_DT_EMB"
      // *** CAF 11 /11/1998 VALIDACAO APENAS NA DATA DE ENTREGA
      // IF !EMPTY(M->W1_DTENTR_)
      //    IF M->W1_DT_EMB > M->W1_DTENTR_
      //       Help(" ",1,"SI400EMBMA")
      //       lRet := .F.
      //    Endif
      //  Endif

   CASE cCampo == "W1_PRECO"
        If !Empty(uData) .And. Empty(M->W0_MOEDA) .And. !AvFlags("EIC_EAI")
           Help(" ",1,"ESINOMOE")
           lRet := .F.
        Endif

ENDCASE

Return( lRet )


*----------------------------------------------------------------------------
FUNCTION DB_SI400Valid()
// Ultima Modific:  23/08/04  para MsGetDB
// Autor: CDS
// CHAMADA A PARTIR DO SX3
*----------------------------------------------------------------------------
LOCAL cCampo := Subs(READVAR(),4),lRet:=.T.
LOCAL uData  := &(Readvar())
LOCAL TPRAZO1:= 0,TPRAZO2:=0,TPRAZO2A:=0,TPRAZO2B:=0
LOCAL TLead  := 0,lInc:=.F.

IF EasyEntryPoint(cArqRdmake) .AND. cCampo == "W0__CC"
   nExecute:="9"
   lRet:=ExecBlock(cArqRdmake,.F.,.F.)
   RETURN lRet
ENDIF

IF EasyEntryPoint("EICPSI01")
   lRet:=ExecBlock("EICPSI01",.F.,.F.,"9")
   RETURN lRet
ENDIF

IF ! SI400KitValid()
   RETURN .F.
ENDIF

DO CASE
   CASE cCampo == "W1_DTENTR_"

     IF !EMPTY(M->W1_DTENTR_)
        If TRB->W1_DT_EMB > M->W1_DTENTR_
           Help(" ",1,"SI400EMBMA")
           Return ( lRet := .F. )
        Endif
     Endif

     If !AvFlags("EIC_EAI") .And. uData < M->W0__DT //wfs - n„o validar a data de entrega programada, recebida do ERP, mantendo o histÛrico e consistÍncia com a origem
        HELP(" ",1,"DTENTSI")
        lRet:=.F.
     Else

        If !Empty(TRB->W1_FABR) .and. !EICEmptyLJ("TRB", "W1_FABLOJ") .and. !Empty(TRB->W1_FORN) .AND. !EICEmptyLJ("TRB", "W1_FORLOJ")
           SA5->(DBSetOrder(3))
           //SA5->(DBSeek(xFilial()+TRB->W1_COD_I+TRB->W1_FABR+TRB->W1_FORN))
           If EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+TRB->W1_FABR+TRB->W1_FORN, EICRetLoja("TRB", "W1_FABLOJ"), EICRetLoja("TRB", "W1_FORLOJ"))
              TLead := SA5->A5_LEAD_T
           Endif
        Endif

        nLtComp  := EasyGParam("MV_LT_COMP")
        nLtDese  := EasyGParam("MV_LT_DESE")
        nLtLice  := EasyGParam("MV_LT_LICE")
        TPrazo1  := uData - M->W0__DT
        TPrazo2A := TLead + nLtComp  + nLtDese
        TPrazo2B := nLtComp + nLtLice + nLtDese
        IF TPrazo2A > TPrazo2B
           TPrazo2 := TPrazo2A
        ELSE
           TPrazo2 := TPrazo2B
        ENDIF
        IF TPrazo1 < TPrazo2 .And. !IsBlind()
           Help("", 1, "AVG0000533")//MSGSTOP(OemtoAnsi(STR0039),OemToAnsi(STR0040)) //"LEAD TIME operacional inviabiliza o atendimento deste(s) item(s)."###"ATENCAO"
        ENDIF
     Endif

   CASE cCampo == "W1_QTDE"//JVR - 11/02/10 - Atualizado tratamento do campo "W1_QTDE".
      If !lInclui
         MsgInfo(STR0147)// LRL 22/01/04 Help(" ",1,"QTDEALTERA")
      Else
         TRB->W1_SALDO_Q := uData
      EndIf

   CASE cCampo == "W1_SALDO_Q" //JVR - 01/10/2009

      Begin Sequence

         If !Empty(M->W0_C1_NUM) //MCF - 25/02/2016
            If lVldSaldo .And. TRB->W1_SALDO_Q == 0 .And. TRB->RECNO <> 0 //RMD - 28/09/16 - Permite desabilitar a validaÁ„o via ponto de entrada.
               EasyHelp(STR0202,STR0002) //"SolicitaÁ„o de ImportaÁ„o n„o pode ser alterada, pois seu saldo foi completamente consumido em um Purchase Order. Favor inclua um novo item com o saldo desejado."
           	 lRet := .F.
           	 Break
            EndIf
         EndIf

         If lInclui // somente pode ser informado na alteracao DA SI
            MsgInfo(STR0148) // LRL 22/01/04Help(" ",1,"SALDOINCL")
         Else
            If Empty(TRB->W1_COD_I)
               MsgInfo(STR0170)//"Informe o cÛdigo do item para poder informar o saldo."
               lRet := .F.
            Else
               If TRB->W1_REC_WT <> 0   //TRB->RECNO <> 0       // GFP - 17/10/2012
                  SW1->(DbGoTo(TRB->W1_REC_WT)) //TRB->RECNO))  // GFP - 17/10/2012
                  If lIntLogix .And. TRB->W1_STATUS <> "F" .And. uData # TRB->SALDO
	                 TRB->W1_QTDE    := uData
                     M->W1_QTDE      := uData
	                 TRB->W1_SALDO_Q := uData
                  ElseIf uData # TRB->SALDO
                     TRB->W1_SALDO_Q := uData
                     TRB->W1_QTDE := IF(inclui,uData,(uDATA - TRB->SALDO) + SW1->W1_QTDE)
                  Else
                     TRB->W1_QTDE := IF(inclui,uData,SW1->W1_QTDE)
                  Endif
               Else
                  If uData # TRB->SALDO
                     If !lIntLogix .Or. TRB->W1_STATUS <> "F"                     
                        TRB->W1_SALDO_Q := uData
                        If lIntLogix
                           TRB->W1_QTDE := uData
                        Else
                           TRB->W1_QTDE := IF(inclui,uData,(uDATA - TRB->SALDO))
                        EndIf
                     EndIf
                  Endif
               EndIf
               lRefresh:=.t.
            EndIf
         EndIf

      End Sequence
   CASE cCampo == "W1_FABR" //mfr 19/03/2019 OSSME-2247
        If !Empty(uData) //.AND. !Empty(EICRetLoja("TRB", "W1_FABLOJ"))
           SA5->(DBSetOrder(3))
           //if !SA5->(DBSeek(xFilial()+TRB->W1_COD_I+Alltrim(uData)))
//           If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+Alltrim(uData), EICRetLoja("TRB", "W1_FABLOJ"))
           If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+AvKey(uData,"A5_FABR"), EICRetLoja("TRB", "W1_FABLOJ")) //Acb - 05/11/2010
//              If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+AllTrim(uData))
              If !EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+AvKey(uData,"A5_FABR")) //Acb - 05/11/2010
                 MsgInfo(STR0149) // LRL 22/01/04 HELP(" ",1,"NOPRODFABR")
                 lRet:=.F.
              ElseIf EICLoja()
                 TRB->W1_FABLOJ := ""
              EndIf  
           ElseIf EICLoja()  .And. !SA2->(DbSeek(xFilial()+uData+TRB->W1_FABLOJ)) 
              TRB->W1_FABLOJ := ""
           Endif
        Endif

        //DFS - 16/02/12 - Inclus„o de tratamento de kit para que, ao mudar o fabricante, mude o valor do produto de acordo com o cadastro do mesmo.
        //TDF - 07/05/12 - Tratamento deve ser feito para SI normal e com Kit
        //IF lKit
           IF Select("TRB") > 0
              IF EICSFabFor(xFilial("SA5")+TRB->W1_COD_I+AvKey(uData,"A5_FABR")+Avkey(TRB->W1_FORN,"W1_FORN"), EICRetLoja("TRB", "W1_FABLOJ"),EICRetLoja("TRB", "W1_FORLOJ")) //LRS - 23/08/2016 - Ajuste na chamada da function EICSFabFor
                 IF SA5->A5_MOE_US == M->W0_MOEDA
                    TRB->W1_PRECO:= SA5->A5_VLCOTUS
                 ENDIF
              ENDIF
           ENDIF
        //ENDIF

        //FDR - 18/02/2013 - Verifica se o fabricante selecionado encontra-se bloqueado para uso
        DBSELECTAREA("SA2")
        SA2->(DBSETORDER(1))

        IF !Empty(uData) //LRS - 13/02/2015 - Caso o W1_FORLOJ no TRB esteja vazio, n„o vai achar o Fornecedor Bloqueado, forÁando a uma nova pesquisa
	        If lRet .And. SA2->(DBSeek(xFilial("SA2") + AvKey(uData,"A5_FORN") + EICRetLoja("TRB", "W1_FORLOJ")))
	           If SA2->A2_MSBLQL == "1"
	              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
	              lRet := .F.
	              M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	              TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
	           EndIf
	        ElseIF lRet .And. SA2->(DBSEEK(xFilial("SA2")+SA5->A5_FABR+SA5->A5_FALOJA))
	          If SA2->A2_MSBLQL == "1"
	              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
	              lRet := .F.
	              M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	              TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
	           EndIf
	        EndIf
        Else
           lRet := .F.
           M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
           TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
        EndIF

   CASE cCampo == "W1_FABLOJ"
        If !Empty(uData) .AND. !Empty(TRB->W1_FABR)
           lRet := ExistCpo("SA2", TRB->W1_FABR+uData)
        Endif

   CASE cCampo == "W1_FORN" //MFR 19/03/2019 OSSME-2247
        If !Empty(uData) //.AND. !Empty(EICRetLoja("TRB","W1_FORLOJ"))
           SA5->(DBSetOrder(2))
//           if !SA5->(DBSeek(xFilial()+TRB->W1_COD_I+Alltrim(uData)+EICRetLoja("TRB","W1_FORLOJ")))
           if !SA5->(DBSeek(xFilial()+TRB->W1_COD_I+AvKey(uData,"A5_FORN")+EICRetLoja("TRB","W1_FORLOJ")))   //acb - 05/11/2010
//              If !SA5->(DBSeek(xFilial()+TRB->W1_COD_I+Alltrim(uData)))
              If !SA5->(DBSeek(xFilial()+TRB->W1_COD_I+AvKey(uData,"A5_FORN"))) //acb - 05/11/2010
                 MsgInfo(STR0150)
                 lRet:=.F.
              ElseIf EICLoja()
                 TRB->W1_FORLOJ := ""
              EndIf

           ElseIf EICLoja() .And. !SA2->(DbSeek(xFilial()+uData+TRB->W1_FORLOJ))
              TRB->W1_FORLOJ := ""
           Endif
        Endif

        //FDR - 20/02/2013 - Verifica se o fornecedor selecionado encontra-se bloqueado para uso
        DBSELECTAREA("SA2")
        SA2->(DBSETORDER(1))

        IF !Empty(uData) //LRS - 13/02/2015 - Caso o W1_FORLOJ no TRB esteja vazio, n„o vai achar o Fornecedor Bloqueado, forÁando a uma nova pesquisa
	        IF !Empty(TRB->W1_FABR) .And. !Empty(TRB->W1_FABLOJ)
	          IF lRet .And. SA2->(DBSEEK(xFilial("SA2")+TRB->W1_FABR+TRB->W1_FABLOJ)) //LRS  Caso o Fornecedor esteja bloqueado, n„o permitir ser preenchido
	              If SA2->A2_MSBLQL == "1"
		              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
		              lRet := .F.
	                  M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	                  TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:="""
	              EndIF
	          EndIF
	        EndIF
	        If lRet .And. SA2->(DBSeek(xFilial("SA2") + AvKey(uData,"A5_FORN") + EICRetLoja("TRB", "W1_FORLOJ")))
	           If SA2->A2_MSBLQL == "1"
	              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
	              lRet := .F.
	              M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	              TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
	           EndIf
	        ElseIF lRet .And. SA2->(DBSEEK(xFilial("SA2")+SA5->A5_FABR+SA5->A5_FALOJA))
	          If SA2->A2_MSBLQL == "1"
	              MsgInfo(STR0187+chr(13)+chr(10)+chr(13)+chr(10)+STR0188)//STR0187:"O fabricante/fornecedor utilizado est· bloqueado para uso." / STR0188:"Selecione outro fabricante/fornecedor ou desbloqueie o mesmo."
	              lRet := .F.
	              M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
	              TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
	           EndIf
	        EndIf
        Else
           lRet := .F.
           M->W1_FORN :="";M->W1_FORLOJ :="";M->W1_FABR :="";M->W1_FABLOJ :=""
           TRB->W1_FORN :="";TRB->W1_FORLOJ:="";TRB->W1_FABR:="";TRB->W1_FABLOJ:=""
        EndIF

   CASE cCampo == "W1_FORLOJ"
       If !Empty(uData) .AND. !Empty(TRB->W1_FORN)
           lRet := ExistCpo("SA2", TRB->W1_FORN+uData)
        Endif
   Case cCampo == "W1_DT_EMB"

      // CDS 23/08/04
       IF !EMPTY(TRB->W1_DTENTR_)
          IF M->W1_DT_EMB > TRB->W1_DTENTR_
             Help(" ",1,"SI400EMBMA")
             lRet := .F.
          Endif
        Endif

   CASE cCampo == "W1_PRECO"
        If !Empty(uData) .And. Empty(M->W0_MOEDA) .And. !AvFlags("EIC_EAI")
           Help(" ",1,"ESINOMOE")
           lRet := .F.
        Endif
ENDCASE

Return( lRet )


*----------------------------------------------------------------------------
FUNCTION SI400GrTRB(aCampos,nOpc)
*----------------------------------------------------------------------------
LOCAL lRet := .F.
LOCAL aOrdAux:= {}
LOCAL cAliasWrk := ""
LOCAL nOldArea
LOCAL aDesc_PSB1 := {}
LOCAL nPosDescPB1:= 0
LOCAL cDesc_PSB1 := cDescAux := ""
If Type("lSIAuto") == "U"
   lSIAuto:= .F.
EndIf

If lGetDb
   dbSelectArea("TRB")
Else
   dbSelectArea("SW1")
EndIf
dbsetorder(1)
SW1->(dbSeek(xFilial("SW1")+SW0->W0__CC+SW0->W0__NUM))

IF EasyEntryPoint(cArqRdmake)
   nExecute:="11"
   cNrConc :=""
   ExecBlock("EICSINEC",.F.,.F.)
ENDIF

IF EasyEntryPoint("EICPSI01")
   ExecBlock("EICPSI01",.F.,.F.,"11")
ENDIF

Work2->(AvZap())//AvZap("Work2")

   nOldArea := Select()
   If Select("WRKSW1") # 0
      WRKSW1->(DbCloseArea())
   EndIf

   BeginSql ALIAS "WRKSW1"
      SELECT SW1.R_E_C_N_O_ W1_RECNO, SB1.R_E_C_N_O_ B1_RECNO,SW1.*
      FROM %table:SW1% SW1
	  LEFT JOIN %table:SB1% SB1
	  ON SW1.W1_COD_I = SB1.B1_COD
      WHERE SW1.%NotDel%
      AND SB1.%NotDel% 
      AND SB1.B1_FILIAL = %xFilial:SB1%
      AND SW1.W1_FILIAL = %xFilial:SW1%
      AND SW1.W1_CC = %exp:SW0->W0__CC%
      AND SW1.W1_SI_NUM = %exp:SW0->W0__NUM%
      ORDER BY SW1.W1_REG, SW1.W1_POSIT
   EndSQL

   cAliasW1 := If( lGetDb, "TRB" , "WRKSW1" )
   DbSelectArea(nOldArea)

(cAliasW1)->(DbGoTop())

While (cAliasW1)->(!Eof()) //.AND.W1_FILIAL==xFilial("SW1").AND.W1_CC==SW0->W0__CC.AND.W1_SI_NUM==SW0->W0__NUM)

	  SW1->(DbGoTo( If( lGetDb , TRB->W1_REC_WT , WRKSW1->W1_RECNO ) ) ) // TDF - 16/04/2012 - Posiciona no registro correto do SW1, pois a ordem difere da TRB.

      If !lSIAuto
         MsProcTxt(STR0041+ALLTRIM(W1_COD_I)) //"Lendo Item: "
      Endif

        If W1_SEQ # 0 
           If nOpc <> 2
              SI400Gera2Work() //AWR 20/05/1999
           EndIf
           If lGetDb
              TRB->(DbDelete())
           EndIf
           (cAliasW1)->(DbSkip()) ; Loop
        Endif
        SI400Gera2Work() //AWR 20/05/1999

        If !lGetDb
           TRB->(DBAPPEND())
           AvReplace("SW1","TRB")
           TRB->RECNO      := SW1->(RECNO())
           TRB->QTDE       := SW1->W1_QTDE
           TRB->SALDO      := SW1->W1_SALDO_Q

           // TDF - 07/05/2012 - Preenche o preÁo de acordo com o fabricante selecionado
           IF nOpc == NIL //FDR - 12/11/2012
              IF EICSFabFor(xFilial("SA5")+SW1->W1_COD_I+AvKey(SW1->W1_FABR,"A5_FABR"), EICRetLoja("SW1", "W1_FABLOJ"))
                 IF SA5->A5_MOE_US == M->W0_MOEDA
                    TRB->W1_PRECO:= SA5->A5_VLCOTUS
                 ENDIF
              ENDIF
           ENDIF
        ENDIF

        // Grava os campos no TRB                           -      JBS 06/10/2003
        IF cPaisLoc # "BRA" .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
           TRB->W1_NATUREZ := SW1->W1_NATUREZ
        ENDIF
        If TRB->W1_REC_B1 == 0
           If lGetDb  
              TRB->W1_REC_B1 := GetRecSB1(TRB->W1_COD_I)
           Else
              TRB->W1_REC_B1 := WRKSW1->B1_RECNO
              If( SB1->B1_COD <> TRB->W1_COD_I , SB1->(DbGoto(TRB->W1_REC_B1)) , )
           EndIf
        Else
           SB1->(DbGoto(TRB->W1_REC_B1))
        EndIf
        If TRB->(FIELDPOS("W1_COD_DES")) # 0
           If ( nPosDescPB1 := aScan(aDesc_PSB1,{|x| x[1] == TRB->W1_COD_I }) ) == 0
              cDesc_PSB1 := If( Empty( cDescAux := MSMM(SB1->B1_DESC_P,AVSX3("W1_COD_DES",AV_TAMANHO),1)) , SB1->B1_DESC , cDescAux   )
              aAdd( aDesc_PSB1, {  TRB->W1_COD_I , cDesc_PSB1} )
           Else
              cDesc_PSB1 :=  aDesc_PSB1[nPosDescPB1][2]
           EndIf          
           TRB->W1_COD_DES := cDesc_PSB1
        EndIf

        //NCF - 22/06/2010
        If lCpoCCusto
           TRB->W1_CTCUSTO := SW1->W1_CTCUSTO
        EndIf

        IF EasyEntryPoint(cArqRdmake)
           nExecute:="4"
           ExecBlock(cArqRdmake,.F.,.F.)
        ENDIF

		IF EasyEntryPoint("EICSI400")
		   ExecBlock("EICSI400",.F.,.F.,"GRAVA_TRB")
		ENDIF

        IF lForeCast
           TRB->W1_FORECAS := SW1->W1_FORECAS
        ENDIF

        // BAK - GravaÁ„o do campo do codigo da matriz de tributacao na work
        If TRB->(FieldPos("W1_CODMAT")) > 0 .And. SW1->(FieldPos("W1_CODMAT")) > 0  .And. AvFlags("SUFRAMA") .And. EasyGParam("MV_TEM_DI", ,.F.)
           TRB->W1_CODMAT := SW1->W1_CODMAT
        EndIf

        IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"5"),)
        IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"4"),)//AWR 09/11/1999


        lRet:=.T.
        
        (cAliasW1)->(dbSkip())

EndDo
//TRB->(__DBPack())//FDR - 25/02/13
dbselectarea("Work2")
Return lRet

*------------------------*
FUNCTION SI400Gera2Work()
*------------------------*

//ISS - 22/09/10 - Incluido a busca de dados para os campos da loja do fornecedor e do fabricante
Local aOldSW2 := SaveOrd("SW2")
Local aOldSW3 := SaveOrd("SW3")
Local cChavCpPO, cChavItPO

Work2->(DBAPPEND())
Work2->W3_PO_NUM   :=  W1_PO_NUM
Work2->W3_QTDE     :=  W1_QTDE
Work2->W3_COD_I    :=  W1_COD_I
Work2->W3_CC       :=  W1_CC
Work2->W3_SI_NUM   :=  W1_SI_NUM
Work2->W3_SEQ      :=  W1_SEQ
Work2->W3_REG      :=  W1_REG
Work2->W1_ALI_WT  :=  "SW1"
Work2->W1_REC_WT  :=  If(lGetDb, TRB->W1_REC_WT, Recno())
IF SW1->W1_SEQ = 0
   Work2->W3_SALDO_Q:= W1_SALDO_Q
ENDIF

If !( (cChavCpPO := xFilial("SW2")+Work2->W3_PO_NUM ) == Left( SW2->&(IndexKey()) , Len(cChavCpPO)) )
   SW2->(DBSETORDER(1))
   SW2->(DBSEEK(cChavCpPO))
EndIf

If !( (cChavItPO := xFilial("SW3")+Work2->W3_PO_NUM+SW1->W1_POSICAO ) == Left( SW3->&(IndexKey()) , Len(cChavItPO)) )
   SW3->(DBSETORDER(8))
   SW3->(DBSEEK(cChavItPO))
EndIf

If !Empty(Work2->W3_PO_NUM)
   Work2->W3_FABR     := SW3->W3_FABR
   Work2->W3_FABLOJ   := SW3->W3_FABLOJ
   Work2->W3_FORN     := SW2->W2_FORN
   Work2->W3_FORLOJ   := SW2->W2_FORLOJ
Else
   Work2->W3_FABR     := W1_FABR
   Work2->W3_FABLOJ   := W1_FABLOJ
   Work2->W3_FORN     := W1_FORN
   Work2->W3_FORLOJ   := W1_FORLOJ
EndIf

RestOrd(aOldSW2,.T.)
RestOrd(aOldSW3,.T.)

RETURN NIL
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SI400Relat≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 13.07.96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Relatorio de SI's                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥EICSI400                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function SI400Relat(cAlias,nReg,nOpc)
LOCAL wnrel
LOCAL cDesc1   := STR0042 //"Emite um relacao para controle das solicitacoes cadastradas ,"
LOCAL cDesc2   := STR0043 //"seus respectivos items e prazos de entrega."
LOCAL cDesc3   := ""
LOCAL cString  := "SW0"
LOCAL aOrd     := {}

PRIVATE nRecno:=SW0->(RECNO())
PRIVATE Tamanho  := "G"
PRIVATE titulo   := STR0044 //"Relacao de Solicitacoes de Importacao"
PRIVATE nomeprog := "EICSI400"
PRIVATE aReturn := { STR0045, 1,STR0046, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE nLastKey := 0 , aInd := {}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica as perguntas selecionadas                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verifica as perguntas selecionadas                           ≥
//≥mv_par01             // a partir do CC                        ≥
//≥mv_par02             // ate o CC                              ≥
//≥mv_par03             // a partir do numero SI                 ≥
//≥mv_par04             // ate o numero SI                       ≥
//≥mv_par05             // a partir do data                      ≥
//≥mv_par06             // ate o data                            ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

IF EasyEntryPoint("EICPSI01") .AND. ExecBlock("EICPSI01",.F.,.F.,"7")

ELSEIF FindFunction("H_RELSI")

   SI400RELSI()

ELSE
   wnrel:=SetPrint(cString,NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.F.)
   If nLastKey == 27
      Set Filter To
      Return
   Endif
   SetDefault(aReturn,cString)
   If nLastKey = 27
      Set Filter To
      Return
   Endif
   RptStatus({|lEnd| SI400Imp(@lEnd,wnRel,cString)},titulo)
ENDIF

dbGoTop()
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ SI400IMP ≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 09.11.95 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Chamada do Relatorio                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ EICSI400                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function SI400Imp(lEnd,WnRel,cString)
LOCAL cabec1,cabec2, cFil, nCC, cSi_Num
LOCAL cRodaTxt := STR0047 //"REGISTRO(S)"
LOCAL nCntImpr := 0,nTipo := 0
PRIVATE cDescr, AsmarcaRel, AscodRel
PRIVATE cPARTNUMBER:="", nTotalPreco:=0
PRIVATE nOrdem   := 1    // RAD 15/06/2006
li := 80
m_pag := 1
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Inicializa os codigos de caracter Comprimido da impressora ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nTipo := 15

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta os Cabecalhos                                          ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
titulo:=STR0048 //"Relatorio de Si's"
cabec1:=""
cabec2:=""
//***    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx xxxxxxxx xxxxxxxxxxxxxxx xxxxxxxx"
//***    0         1         2         3         4         5         6         7         8         9        10        11
//***    012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123

dbSelectArea("SW0")

nCont:=0
SW0->(DBGOTO(nRecno))
SW1->(dbSeek(xFilial()+SW0->W0__CC+SW0->W0__NUM))
SW1->(DBEVAL({||nCont++},,{||W1_FILIAL == xFilial("SW1") .AND. ;
                             W1_CC == SW0->W0__CC   .AND. ;
                             W1_SI_NUM == SW0->W0__NUM}))

SetRegua(nCont)

dbSetOrder(1)
cFil:=xFilial("SW0")
SW0->(DBGOTO(nRecno))


cSi_Num:=SW0->W0__NUM
nCC  :=SW0->W0__CC

nTam :=50
nCol1:=000
nCol2:=nCol1+nTam+20
nCol3:=nCol2+022
nCol4:=nCol3+032
nCol5:=nCol4+032
nCol6:=nCol5+014
nCol7:=nCol6+021
nCol8:=nCol7+012

Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
@ Li,000 PSAY Repli("*",220)
Li++

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Imprime o Cabecalho da SI                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
SY3->(DBSETORDER(1))
SY3->(DBSEEK(xFilial()+SW0->W0__CC))
Li++
@ Li,000   PSAY STR0049+SW0->W0__CC+" - "+SY3->Y3_DESC //"C.Custo....: "
@ Li,090   PSAY STR0050+SW0->W0__NUM //"No. da S.I.: "
@ Li,nCol6 PSAY STR0051+DTOC(SW0->W0__DT) //"Data da SI.: "

SY2->(DBSETORDER(1))
SY2->(DBSEEK(xFilial()+SW0->W0__POLE))
Li++
@ Li,000 PSAY STR0052+SW0->W0__POLE+" - "+SY2->Y2_DESC //"Loc. Entr..: "

SY1->(DBSETORDER(1))
SY1->(DBSEEK(xFilial()+SW0->W0_COMPRA))
@ Li,090 PSAY STR0053+SW0->W0_COMPRA+" - "+SY1->Y1_NOME //"Comprador..: "
@ Li,nCol6 PSAY STR0166+SW0->W0_MOEDA //"Moeda......: "

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"SUB_CAB_REL")
ENDIF

Li+=2
SI400RelSub()

IF EasyEntryPoint("EICSI400")    // RAD 15/06/06 - SUPPLY
   ExecBlock("EICSI400",.F.,.F.,"ANTES_WHILE_RELAT")
ENDIF

dbSelectArea("SW1")
dbSetOrder(nOrdem)
SW1->(dbSeek(xFilial()+SW0->W0__CC+SW0->W0__NUM))
SB1->(DBSETORDER(1))
SA2->(DBSETORDER(1))
SA5->(DBSETORDER(3))

While !Eof() .AND. W1_FILIAL == xFilial("SW1") .AND. ;
      W1_CC==SW0->W0__CC .AND. W1_SI_NUM==SW0->W0__NUM

        If lEnd
           @PROW()+1,001 PSAY STR0054 //"CANCELADO PELO OPERADOR"
           Exit
        Endif

        IncRegua(STR0055+SW1->W1_COD_I) //"Imprimindo Item "

        nCntImpr++

        IF SW1->W1_SEQ != 0  // CAF 28/08/1998  OS.0989/98
           SW1->(dbSkip())
           LOOP
        ENDIF

        If li > 58
           cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
           @ Li,000 PSAY Repli("*",220)
           Li+=3
           SI400RelSub()
        Endif

        SB1->(DBSEEK(xFilial()+SW1->W1_COD_I))

        SI400BuscaPN(SW1->W1_COD_I,SW1->W1_FORN,SW1->W1_FABR,If(SW1->(FIELDPOS("W1_FORLOJ")) # 0,SW1->W1_FORLOJ,""),If(SW1->(FIELDPOS("W1_FABLOJ")) # 0,SW1->W1_FABLOJ,""))

        Li++
        cDescr:=MSMM(SB1->B1_DESC_P)//,avsx3("B1_DESC_P",3))
        cDescr:=MEMOLINE(cDescr,nTam,1)

        IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"7"),)

        cCodItemRel := SW1->W1_COD_I
        cPARTNUMBER := SA5->A5_CODPRF

        IF EasyEntryPoint("EICSI400")
          ExecBlock("EICSI400",.F.,.F.,"RELAT")
        ENDIF

        @ Li,nCol1 PSAY cCodItemRel+" - "+IF(Empty(cDescr),LEFT(SB1->B1_DESC,nTam),cDescr)
        @ Li,nCol2 PSAY cPARTNUMBER                    ; SA2->(DBSEEK(xFilial()+SW1->W1_FORN+EICRetLoja("SW1","W1_FORLOJ")))
        @ Li,nCol3 PSAY SW1->W1_FORN+" - "+Left(SA2->A2_NREDUZ,(nLenReduz-(nLenForn-6))) ; SA2->(DBSEEK(xFilial()+SW1->W1_FABR)) //SO.:0026 OS.:0250/02 FCD
        @ Li,nCol4 PSAY SW1->W1_FABR+" - "+Left(SA2->A2_NREDUZ,(nLenReduz-(nLenForn-6)))//SO.:0026 OS.:0250/02 FCD
        @ Li,nCol5 PSAY SubSTR(TABELA('Y1',SW1->W1_CLASS),1,10)
        @ Li,nCol6 PSAY TRANS(SW1->W1_QTDE,AVSX3("W1_QTDE",6))
        @ Li,nCol7 PSAY DTOC(SW1->W1_DTENTR_)
        @ Li,nCol8-4 PSAY TRANS(SW1->W1_PRECO,AVSX3("W1_PRECO",6))

        IF EasyEntryPoint("EICSI400")
          ExecBlock("EICSI400",.F.,.F.,"DETITEM")
        ENDIF

//      nTotalPreco+=SW1->W1_PRECO // RAD 14-06-2006, O total deve multplicar a quantidade
        nTotalPreco+=SW1->W1_PRECO*SW1->W1_QTDE

                IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"6"),)

        dbSkip()

EndDO

SA5->(DBSETORDER(1))
If ! EMPTY(nTotalPreco)   // Imprimiu ??
   Li++
   @++Li,nCol7 PSAY STR0171 //STR0171 = "TOTAL "
   @Li,nCol8-4 PSAY TRANS(nTotalPreco,AVSX3("W1_PRECO",6))
Endif
//SVG - 26/04/2011 - Retirado o rodapÈ pois sobrepıe o total quando SI com mais de 46 itens
/*If li != 80
   Roda(nCntImpr,cRodaTxt,tamanho)
EndIf
*/
Set Device to Screen

If aReturn[5] = 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

IF EasyEntryPoint("EICSI400")       // RAD 15/06/06 - SUPPLY
   ExecBlock("EICSI400",.F.,.F.,"FINAL_RELAT")
ENDIF

Return

*-------------------------------------------------------*
Function SI400BuscaPN(cItem,cForn,cFabr,cLojFor,cLojFab)
*-------------------------------------------------------*
SA5->(DBSETORDER(3))
//IF !SA5->(DbSeek(xFilial()+cItem+cFabr+cForn))
If !EICSFabFor(xFilial("SA5")+cItem+cFabr+cForn, cLojFab,cLojFor)
   //IF !SA5->(DbSeek(xFilial()+cItem+cFabr))
   If !EICSFabFor(xFilial("SA5")+cItem+cFabr, cLojFab)
       SA5->(DBSETORDER(2))
       SA5->(DbSeek(xFilial()+cItem+cForn+cLojFor))
       SA5->(DBSETORDER(3))
   ENDIF
ENDIF
RETURN SA5->A5_CODPRF

*---------------------------------------*
Function SI400RelSub()
*---------------------------------------*
PRIVATE cCodDesc := STR0056

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"CABEC")
EndIf

   @ Li,nCol1 PSAY cCodDesc //"Codigo do Item  - Descricao"
@ Li,nCol2 PSAY STR0014 //"Part Number"
@ Li,nCol3 PSAY STR0013 //"Fornecedor"
@ Li,nCol4 PSAY STR0012 //"Fabricante"
@ Li,nCol5 PSAY STR0057 //"Classificao"
@ Li,nCol6 PSAY STR0058 //"     Quantidade"
@ Li,nCol7 PSAY STR0059 //"Entrega"
@ Li,nCol8 PSAY STR0167 //"Preco"

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"SUBCAB")
EndIf

Li++
@ Li,nCol1 PSAY REPL("-",nTam+18)
@ Li,nCol2 PSAY REPL("-",LEN(SA5->A5_CODPRF))
@ Li,nCol3 PSAY REPL("-",29)
@ Li,nCol4 PSAY REPL("-",29)
@ Li,nCol5 PSAY REPL("-",11)
@ Li,nCol6 PSAY REPL("-",15)
@ Li,nCol7 PSAY REPL("-",LEN(DTOC(SW1->W1_DTENTR_)))
@ Li,nCol8 PSAY REPL("-",AVSX3("W1_PRECO",3))

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"SUBCABLINHA")
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funá∆o    ≥ SI400Exc ≥ Autor ≥ Gilson Nascimento     ≥ Data ≥ 09.11.95 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriá∆o ≥ Exclui os dados do arquivo                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ EICSI400                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function SI400Exc(cAlias,cAlias1)
Local aSC1:={}, nInd, cPosicao, cC1_NUM:=SW0->W0_C1_NUM, i
Local lIntegra := ( EasyGParam("MV_EASY")$cSim .And. !Empty(cC1_NUM) )
Private lMsHelpAuto	:= .F.
Private lAutoErrNoFile := .T.
// quando possivel colocar regua
dbSelectArea("TRB")
DBGOTOP()

Begin Transaction
   While TRB->(!EOF())
      SW1->(dbGoto(TRB->RECNO))
      SW1->(RecLock(cAlias1,.f.))
      If lIntegra .And. AScan(aSC1, SW1->W1_POSICAO ) == 0	//LGS-02/10/2015 // GFP - 25/08/2015
         AAdd(aSC1, SW1->W1_POSICAO ) 							//LGS-02/10/2015 // GFP - 25/08/2015
      Endif
      IF lIntLogix  // Jacomo Lisa - 01/08/2014 -- Chamada da exclus„o das ELDs
         ELD400Exc()
      ENDIF
      SW1->(dbDelete())
      SW1->(MsUnLock())
      TRB->(dbSkip())
   End

   dbSelectArea(cAlias) // Ja locado, ao entrar na rotina de exclusao.
   If (cAlias)->(RecLock(cAlias,.F.)) //FSM - 21/07/2011
      (cAlias)->(dbDelete())
      (cAlias)->(MsUnLock())
   EndIf

   If lIntegra //MCF - 11/12/2017 - ADICIONADO VERIFICA«√O COM COMPRAS
        SC1->(DBSETORDER(1))  //C1_FILIAL+C1_PRODUTO+C1_NUM+C1_ITEM+C1_FORNECE+C1_LOJA    // GFP - 25/08/2015 //LGS-02/10/2015
        For nInd:=1 To Len(aSC1)                                                          // GFP - 25/08/2015
            cPosicao:= aSC1[nInd]                                                         // GFP - 25/08/2015
            If SC1->(DbSeek(xFilial('SC1')+M->W0_C1_NUM+cPosicao))                      	 // GFP - 25/08/2015 //LGS-02/10/2015
                cFil  := xFilial("SC1")
                If nInd == 1
                    aCabec:={}
                    aItens := {}
                    Aadd(aCabec,{"C1_EMISSAO", SC1->C1_EMISSAO, Nil })
                    Aadd(aCabec,{"C1_SOLICIT", SC1->C1_SOLICIT, Nil })
                    AADD(aCabec,{"C1_FILIAL" , cFil           , Nil })
                    AADD(aCabec,{"C1_NUM"    , SC1->C1_NUM    , Nil })
                Endif

                aItensTemp := {}
                aadd( aItensTemp , {"C1_FILIAL"	, xFilial("SC1")	   , NIL         })
                aadd( aItensTemp , {"LINPOS"    ,"C1_ITEM"		       ,SC1->C1_ITEM }) //MCF - 26/01/2016
                aadd( aItensTemp , {"C1_PRODUTO" 	, SC1->C1_PRODUTO	, Nil         })
                aadd( aItensTemp , {"C1_COTACAO"	, "IMPORT"			, Nil         })
                aadd( aItensTemp , {"C1_NUM_SI"  	, ""           	, Nil         })
                aadd( aItensTemp , {"C1_QUANT"    	, SC1->C1_QUANT     , Nil          })
                aAdd(aItens, aClone(aItensTemp))

            Else
                Help("", 1, "AVG0000532",,cC1_NUM+STR0038+Right(cPosicao,2),1,24)//MsgStop(STR0037+cC1_NUM+STR0038+; //"Solicitacao de Compras "###" nao encontrada - item "
            Endif
        Next

        If type('aCabec') <> 'U' .AND. type('aItens') <> 'U' .AND.  Len(aCabec) # 0 .AND. Len(aItens) # 0 //MFR TE-4967 - 23/02/2017 -- Data erro quando nao passava no for erro aCabec vari·vel n„o existe
            aHeader:={}
            lMsErroAuto := .F.
            MsExecAuto({|a,b,c| MATA110(a,b,c) },aCabec,aItens,4)
            If lMsErroAuto
                lRet  := .F.
                cErro := STR0200 + ENTER + StrTran(STR0199, "#ITEM#", cValToChar(AllTrim(SC1->C1_PRODUTO))) //Problema
                cErro := StrTran(cErro,   "#SC#"  , cValToChar(AllTrim(SC1->C1_NUM))) + ENTER + ENTER
                If Len(aErro := GetAutoGRLog()) <> 0
                    cErro += STR0201 + ENTER//Motivo
                    For i:=1 To Len(aErro)
                        cErro += aErro[i] + ENTER
                    Next
                EndIf
                MsgInfo(cErro,STR0040)
                RollBackDelTran("") //MCF - 26/01/2016
            EndIf
        EndIf
    EndIf
End Transaction

//DFS - Ponto de entrada no momento da gravaÁ„o de exclus„o
If(EasyEntryPoint("EICSI400"),ExecBlock("EICSI400",.F.,.F.,"GRV_EXCLUI"),)

Return

*------------------------*
FUNCTION SI400Check(lKit)
*------------------------*
// Ultima Modif. 23/08/04
// Autor: CDS
LOCAL nRecno:=TRB->(RECNO()), lIncluiu:=.F.

If !Obrigatorio(aGets,aTela) .OR. ! SI400KitValid()
   RETURN .F.
Endif

TRB->(DBGOTOP())

WHILE ! TRB->(EOF())

   IF lComEdit .AND. lKit  // GFP - 06/07/2012

      IF TRB->W1_FLAG==.F.;       //CDS 23/08/04, Registro nao apagado e Nao Vazio completamente
         .and.!EMPTY(TRB->W1_COD_I) //.and.!EMPTY(TRB->W1_FORN).and.!EMPTY(TRB->W1_FABR)

         lIncluiu:=.T.
         IF lKit				//CDS 23/08/04

            IF (EMPTY(TRB->W1_CLASS) .OR. EMPTY(TRB->W1_COD_I) .OR.;
               EMPTY(TRB->W1_QTDE)  .OR. EMPTY(TRB->W1_DTENTR_))
               Help("", 1, "AVG0000534")//MsgInfo(STR0060,STR0061) //"S.I. POSSUI ITEM COM DADOS INCOMPLETOS"###"AtenÁ„o"
               RETURN .F.
            ENDIF

            IF Empty(M->W0_MOEDA) .And. ! Empty(TRB->W1_PRECO) .And. !AvFlags("EIC_EAI")
               Help(" ",1,"ESINOMOE")
               Return .F.
            Endif

            If ! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_CLASS)
               Help(" ",1,"SI400CLMES")
               Return .F.
            Endif

            IF ! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_DTENTR_)
               Help(" ",1,"SI400ENMES")
               Return .F.
            ENDIF

         Else                      //CDS 23/08/04
            // Se nao tem kit, validar linhas dos itens
            If ! SI400LinOk()
               Return .F.
            Endif

            //--- CDS 23/08/04 ---
            IF TRB->W1_REG==0
               SI400ApuReg(.T.)
            Endif

         Endif

      EndIf

   ELSE
        If TRB->W1_FLAG==.F.
            lIncluiu:=.T.

            If ! SI400LinOk() //RRV - 16/10/2012
                Return .F.
            Endif

            SI400ApuReg(.T.)      //NCF - 09/12/2015 - Ajustar o W1_REG da TRB dentro deste loop final de validaÁ„o de todas as linhas

            IF !lKit
                //EXIT             //NCF - 09/12/2015 - Sem kit, continuar validando linha a linha pois pode ocorrer da ˙ltima linha nova conter dados inv·lidos.
                TRB->(DBSKIP())
                Loop
            ENDIF

            IF (EMPTY(TRB->W1_CLASS) .OR. EMPTY(TRB->W1_COD_I) .OR.;
                EMPTY(TRB->W1_QTDE)  .OR. EMPTY(TRB->W1_DTENTR_))
                Help("", 1, "AVG0000534")//MsgInfo(STR0060,STR0061) //"S.I. POSSUI ITEM COM DADOS INCOMPLETOS"###"AtenÁ„o"
                RETURN .F.
            ENDIF

            IF Empty(M->W0_MOEDA) .And. ! Empty(TRB->W1_PRECO) .And. !AvFlags("EIC_EAI")
                Help(" ",1,"ESINOMOE")
                Return .F.
            Endif

            If ! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_CLASS)
                Help(" ",1,"SI400CLMES")
                Return .F.
            Endif

            IF ! Empty(M->W0_SIKIT) .AND. EMPTY(TRB->W1_DTENTR_)
                Help(" ",1,"SI400ENMES")
                Return .F.
            ENDIF
        EndIf
    ENDIF

   TRB->(DBSKIP())
END

TRB->(DBGOTO(nRecno))

IF ! lIncluiu
   Help("", 1, "AVG0000536")//MsgInfo(STR0062,STR0061) //"AtenÁ„o, N„o existem itens para esta S.I."###"AtenÁ„o"
   RETURN .F.
ENDIF

RETURN .T.

*----------------------------------------------------------------------------
FUNCTION SI400Kit(Codigo)
*----------------------------------------------------------------------------
IF !(EasyGParam("MV_KIT",,.F.)$ cSim)
   RETURN .T.
ENDIF
DO CASE
   CASE  Codigo = "W0_SIKIT"

         IF ! Inclui .AND.  EMPTY(M->W0_SIKIT) .AND. M->W0_SIKIT <> SW0->W0_SIKIT //DFS - 10/02/12 Para n„o dar a mensagem se clicar no F3 do campo.
            Help(" ",1,"SI400KTVAZ")
            RETURN .F.
         ENDIF

         IF EMPTY( M->W0_SIKIT )
            RETURN .T.
         ENDIF

         IF ! SB1->(DBSEEK(xFilial()+M->W0_SIKIT))
             MsgInfo(STR0151) // LRL 22/01/04 Help(" ",1,"SI400SEMKI")
            RETURN .F.
         ENDIF
   CASE  Codigo = "W0_KITSERI"
         IF ! Inclui
            MsgInfo(STR0152) // LRL 22/01/04 Help(" ",1,"SI400SEVAZ")
            RETURN .F.
         ENDIF

         IF EMPTY(M->W0_SIKIT) .AND. ! EMPTY(M->W0_KITSERI)
             MsgInfo(STR0153) // LRL 22/01/04 Help(" ",1,"SI400SER")
            RETURN .F.
         ENDIF

         IF EMPTY(M->W0_SIKIT) .AND. EMPTY(M->W0_KITSERI)
            RETURN .T.
         ENDIF

         SYV->(DbSetOrder(1))
         IF ! SYV->(DBSEEK(xFilial()+AvKey(M->W0_SIKIT, "YV_MACHINE")+AvKey(M->W0_KITSERI, "YV_TYP_MOD")))
            Help(" ",1,"SI400ENG")
            RETURN .F.
         ENDIF

         SYX->(DbSetOrder(1))
         IF ! SYX->(DBSEEK(xFilial()+AvKey(M->W0_SIKIT, "YV_MACHINE")+AvKey(M->W0_KITSERI, "YV_TYP_MOD")))
            Help(" ",1,"SI400ITENG")
            RETURN .F.
         ENDIF

   CASE  Codigo = "W0_QTDE"
         IF ! Inclui
            MsgInfo(STR0154) // LRL 22/01/04 Help(" ",1,"SI400QTVAZ")
            RETURN .F.
         ENDIF

         IF EMPTY(M->W0_SIKIT) .AND. ! EMPTY(M->W0_QTDE)
            Help(" ",1,"SI400QT")
            RETURN .F.
         ENDIF

         IF EMPTY(M->W0_SIKIT) .AND. EMPTY(M->W0_QTDE)
            RETURN .T.
         ENDIF

         IF M->W0_QTDE <= 0
            Help(" ",1,"SI400QTKIT")
            RETURN .F.
         ENDIF

   CASE  Codigo = "W0_FORN"
         IF ! Inclui
            MsgInfo(STR0155) // LRL 22/01/04 Help(" ",1,"SI400FOVAZ")
            RETURN .F.
         ENDIF

         IF EMPTY(M->W0_SIKIT) .AND. ! EMPTY(M->W0_FORN)
            Help(" ",1,"SI400FOR")
            RETURN .F.
         ENDIF

         IF EMPTY(M->W0_SIKIT) .AND. EMPTY(M->W0_FORN)
            RETURN .T.
         ENDIF

         IF EMPTY(M->W0_FORN)
            Help(" ",1,"SI400VAZIO")
            RETURN .F.
         ENDIF

         IF ! SA2->(DBSEEK(xFilial()+M->W0_FORN))
            Help(" ",1,"SI400FOKIT")
            RETURN .F.
         ENDIF

         IF LEFT(SA2->A2_ID_FBFN,1) = "1"
            Help(" ",1,"SI400TIPO")
            RETURN .F.
         ENDIF

   CASE  Codigo = "W0_DT_NEC"
         IF EMPTY(M->W0_SIKIT) .AND. ! EMPTY(M->W0_DT_NEC)
            Help(" ",1,"SI400NECE")
            RETURN .F.
         ENDIF

         IF EMPTY(M->W0_SIKIT) .AND. EMPTY(M->W0_DT_NEC)
            RETURN .T.
         ENDIF

         IF EMPTY( M->W0_DT_NEC )
            Help(" ",1,"SI400NEC")
            RETURN .F.
         ENDIF

         IF M->W0_DT_NEC < M->W0__DT
            Help(" ",1,"SI400DTMAI")
            RETURN .F.
         ENDIF

   CASE  Codigo = "W0_DT_EMB"
         IF EMPTY(M->W0_SIKIT) .AND. ! EMPTY(M->W0_DT_EMB)
            Help(" ",1,"SI400DTEMB")
            RETURN .F.
         ENDIF

         IF EMPTY(M->W0_SIKIT) .AND. EMPTY(M->W0_DT_EMB)
            RETURN .T.
         ENDIF

         IF EMPTY( M->W0_DT_EMB )
            Help(" ",1,"SI400EMB")
            RETURN .F.
         ENDIF

         IF M->W0_DT_EMB > M->W0_DT_NEC
            Help(" ",1,"SI400EMBMA")
            RETURN .F.
         ENDIF

   //FDR - 07/07/11 - ValidaÁ„o do campo loja
   CASE Codigo == "W0_FORLOJ"

    If !Empty(M->W0_FORN) .And. !Empty(M->W0_FORLOJ)
       IF ! SA2->(DBSEEK(xFilial()+AvKey(M->W0_FORN,"A2_COD")+AvKey(M->W0_FORLOJ,"A2_COD")))
          //Help(" ",1,"SI400FOKIT")
          MsgInfo(STR0183 + AllTrim(M->W0_FORN) + ".",STR0061) //STR0183 "Loja n„o cadastrada para o fornecedor " //STR0061 "AtenÁ„o"
          RETURN .F.
       ENDIF
    EndIf

ENDCASE
RETURN .T.

*--------------------*
Function SI400Class()
*--------------------*
IF !(EasyGParam("MV_KIT",,.F.)$ cSim)
   RETURN .T.
ENDIF

IF ! Inclui .AND. !EMPTY(M->W0_SIKIT)
   MsgInfo(STR0156) // LRL 22/01/04 Help(" ",1,"SI400CLVAZ")
   RETURN .F.
ENDIF

IF EMPTY(M->W0_SIKIT) .AND. ! EMPTY(M->W0_CLASKIT)
   Help(" ",1,"SI400CLKIT")
   RETURN .F.
ENDIF

IF ! SI400VldClass(M->W0_CLASKIT,.T.)
   RETURN .F.
ENDIF
AvZap("TRB")
Processa({|lEnd|SI400GeraKit(M->W0_SIKIT,M->W0_KITSERI,M->W0_QTDE)},STR0063) //"Gravando os Itens do Kit"
lCopiaSi := .F.			//CDS 23/08/04

RETURN .T.

*-----------------------*
FUNCTION SI400GET(Campo)
*-----------------------*
LOCAL lRet:=.T.

IF !(EasyGParam("MV_KIT",,.F.)$ cSim)
   RETURN .T.
ENDIF

DO CASE
   CASE Campo == "W1_FORN"
        If ! Empty(M->W0_SIKIT) .AND. EMPTY(M->W1_FORN)
           Help(" ",1,"SI400FOMES")
           lRet:=.F.
        Endif
   CASE Campo == "W1_CLASS"
        If ! Empty(M->W0_SIKIT) .AND. EMPTY(M->W1_CLASS)
           Help(" ",1,"SI400CLMES")
           lRet:=.F.
        Endif
   CASE Campo == "W1_DTENTR_"
        IF ! Empty(M->W0_SIKIT) .AND. EMPTY(M->W1_DTENTR_)
           Help(" ",1,"SI400ENMES")
           lRet:=.F.
        ENDIF
ENDCASE
RETURN lRet
*----------------------------------------------------------------------------
FUNCTION SI400GeraKit(TNr_Kit,TNr_Serie,TQtdeKit)
*----------------------------------------------------------------------------
LOCAL Item, TObs:=SPACE(40), QtdeApurada:=0, TipoQtde:=SPACE(13), Qtde
LOCAL cNr_Kit:=TNr_Kit,nReg:=0
LOCAL _PictItem := ALLTRIM(X3PICTURE("B1_COD"))
LOCAL nLenLoj := LEN(SA5->A5_FALOJA)
LOCAL cDesc := ""

ProcRegua(SYX->(Easyreccount("SYX")))

SYX->(DBSETORDER(1))
SYX->(DBSEEK(xFilial("SYX")+AVKEY(cNr_Kit,"YX_MACHINE")+AVKEY(TNr_Serie,"YX_TYP_MOD")))

WHILE ! SYX->(EOF()) .AND. SYX->YX_FILIAL == xFilial("SYX") .AND. ;
                           SYX->YX_MACHINE+SYX->YX_TYP_MOD = AVKEY(cNr_Kit,"YX_MACHINE")+AVKEY(TNr_Serie,"YX_TYP_MOD")
  Item  :=SYX->YX_COD_I
  cDesc :=SYX->YX_DES_ZFM //FDR - 07/07/11
  Qtde  :=SYX->YX_FATOR * TQtdeKit
  nReg  :=SI400ApuReg(.F.)

  IncProc(STR0064+TRAN(Item,_PictItem)) //"Verificando existencia do item "

  IF nReg == 0
     SYX->(DBSKIP())
         LOOP
  ENDIF

  IF ! SB1->(DBSEEK(xFilial()+Item))
     TObs := STR0065 //"ITEM NAO CADASTRADO NO SB1"
  ELSE
     SA5->(DBSETORDER(2))
     IF ! SA5->(DBSEEK(xFilial()+Item+M->W0_FORN+EICRetLoja("M","W0_FORLOJ")))
        Help("", 1, "AVG0000537",,TRAN(Item,_PictItem)+STR0067+M->W0_FORN+STR0068,1,6)//MsgInfo(STR0066+TRAN(Item,_PictItem)+STR0067+M->W0_FORN+STR0068,STR0029) //"Item "###" n„o encontrado p/ o Fornecedor "###" DESPREZANDO"###"InformaÁ„o"
        TObs := STR0069 //"ITEM SEM FORNECEDOR/FABRICANTE"
     ENDIF
     SA5->(DBSETORDER(1))
  ENDIF

  IF EMPTY( TObs )
     QtdeApurada := LoteMinMax(Qtde,SA5->A5_LOTEMIN,;
                                    SA5->A5_LOTEMUL,@TipoQtde)
  ENDIF

  TRB->(DBAPPEND())

  TRB->W1_FLAG       := .F.
  TRB->W1_POSIT   := SI400NumPoItem()
  TRB->W1_COD_I   := Item
  TRB->W1_COD_DES := cDesc //FDR - 07/07/11
  TRB->W1_FABR    := IF(!EMPTY(TObs),Space(nLenForn),SA5->A5_FABR) ////SO.:0026 OS.:0250/02 FCD  -- CDS 23/08/04
  IF EICLOJA()
     TRB->W1_FABLOJ  := IF(!EMPTY(TObs),Space(nLenLoj),SA5->A5_FALOJA)
  ENDIF
  TRB->W1_FORN    := IF(!EMPTY(TObs),Space(nLenForn),M->W0_FORN)//SO.:0026 OS.:0250/02 FCD       -- CDS 23/08/04
  IF EICLOJA()
     TRB->W1_FORLOJ  := IF(!EMPTY(TObs),Space(nLenLoj),M->W0_FORLOJ)
  ENDIF
  TRB->W1_CLASS   := SI400SX5( M->W0_CLASKIT )
  TRB->W1_QTDE    := IF(QtdeApurada<>0,QtdeApurada,Qtde)
  TRB->W1_SALDO_Q := IF(QtdeApurada<>0,QtdeApurada,Qtde)
  TRB->W1_DTENTR_ := M->W0_DT_NEC
  TRB->W1_DT_EMB  := M->W0_DT_EMB
  TRB->QTDE       := IF(QtdeApurada<>0,QtdeApurada,Qtde)
  TRB->SALDO      := IF(QtdeApurada<>0,QtdeApurada,Qtde)
  TRB->W1_REG     := nReg
  TRB->W1_ALI_WT := "SW1"
  TRB->W1_REC_WT := 0
  TRB->W1_REC_B1 := GetRecSB1(TRB->W1_COD_I)
  IF SA5->A5_MOE_US == M->W0_MOEDA
     TRB->W1_PRECO:= SA5->A5_VLCOTUS
  ENDIF
  IF lForeCast

  If lComEdit
     TRB->W1_FORECAS := TRB->W1_FORECAS
  Else
     TRB->W1_FORECAS := M->W1_FORECAS
  Endif
ENDIF

  SYX->(DBSKIP())
END

TRB->(DbGoTop())
If lComEdit
	DbSelectArea("TRB")
	TRB->(DbSetOrder(0))				        //CDS 23/08/04
	BrwRefresh( "TRB", oMSSelect:oBrowse )	//CDS 23/08/04
	TRB->(dbGoTop())
	oMSSelect:oBrowse:GoTop()
	oMSSelect:nCount:=TRB->(EasyRecCount("TRB"))
Else
	BrwRefresh( "TRB", oMSSelect:oBrowse )
	TRB->(dbGoTop())
	oMSSelect:oBrowse:GoTop()
Endif

RETURN NIL

*-------------------------------------------------------------------------*
FUNCTION LoteMinMax( QtdeDigitada, LoteMinimo, LoteMultiplo, TipoQtde )  // Robson 13:31 29 Dec,1994
*-------------------------------------------------------------------------*
LOCAL QtdeApurada := 0

IF QtdeDigitada < LoteMinimo
   QtdeApurada := LoteMinimo
   TipoQtde    := STR0070 //"Lote Minimo"
ELSE
   IF ! EMPTY( LoteMultiplo )
      TipoQtde  := STR0071 //"Lote Multiplo"
      IF QtdeDigitada < LoteMultiplo
         QtdeApurada := LoteMultiplo
      ELSE
         IF MOD(QtdeDigitada,LoteMultiplo) <> 0
            QtdeApurada := (INT(QtdeDigitada/LoteMultiplo)+1) * LoteMultiplo
         ENDIF
      ENDIF
   ENDIF
ENDIF

RETURN QtdeApurada

*-----------------------*
Function SI400KitValid()
*-----------------------*
IF (! EMPTY(M->W0_SIKIT) .AND. EMPTY(M->W0_CLASKIT)).AND. lKit
   Help(" ",1,"SI400KIT")
   RETURN .F.
ENDIF
RETURN .T.

*----------------------------------*
Function SI400ApuReg(lMemoria,cAlias)
*----------------------------------*
LOCAL nRecno:=TRB->(RECNO()), nRet:=.F., nApuReg:=0
LOCAL cCodItemAtual
LOCAL nRegistro:=0
LOCAL aOldTrb
Local cReg
Default cAlias := "TRB"

//CDS 23/08/04
If lComEdit
   cCodItemAtual:=IF(lMemoria,TRB->W1_COD_I,SYX->YX_COD_I)

   If TRB->W1_REG<>0.and.lMemoria
      Return(0)
   Endif
ELSE
   cCodItemAtual:=IF(lMemoria,&(cALias+"->W1_COD_I"),SYX->YX_COD_I) //MCF - 29/03/2016
Endif

aOldTrb:=SaveOrd("TRB")

BEGIN SEQUENCE

   If SW1->(FieldPos("W1_POSIT")) > 0
      TRB->(DbSetOrder(2))
   Else
      TRB->(DbSetOrder(1))
   Endif

   IF !TRB->(DBSEEK(cCodItemAtual))
      nRegistro := 1
      nRet := .T.
      BREAK
   ENDIF
   
   cReg := Replicate("9",AvSX3("W1_REG",AV_TAMANHO))
   IF !TRB->(DBSEEK(cCodItemAtual + cReg,.T.))   //Procura o ultimo
      TRB->(DBSKIP(-1))
   ENDIF

   IF TRB->W1_REG < Val(cReg)         //Soma 1 no ultimo
      nRegistro:=TRB->W1_REG + 1
      nRet := .T.
      BREAK
   ENDIF

   TRB->(DBSEEK(cCodItemAtual))
   //while para procurar 'buraco' nos reg's
   WHILE ! TRB->(EOF()) .AND. TRB->W1_COD_I == cCodItemAtual
   If lComEdit
    //-- MsGetDB --
    If TRB->W1_REG<>0
      nApuReg++

      IF nApuReg == TRB->W1_REG
         TRB->(DBSKIP())
         LOOP
      ENDIF

      nRegistro:=nApuReg

      nRet := .T.
      BREAK
    Else
      TRB->(DBSkip())
    EndIf
   //-- MsSelect --
   ELSE
      nApuReg++

      IF nApuReg == TRB->W1_REG
         TRB->(DBSKIP())
         LOOP
      ENDIF

      nRegistro:=nApuReg

      nRet := .T.
      BREAK
   ENDIF
   ENDDO

   IF nRegistro == 0
      Help("", 1, "AVG0000539",,ALLTRIM(cCodItemAtual)+STR0073,1,8)//MsgInfo(STR0072+ALLTRIM(cCodItemAtual)+STR0073,STR0061) //'O Item: '###' atingiu o m·ximo de "9999" entregas'###"AtenÁ„o"
      nRet := .F.
      BREAK
   ENDIF
END SEQUENCE
TRB->(DBGOTO(nRecno))

IF nRet
   IF lMemoria
     If lComEdit
        TRB->W1_REG:=nRegistro
       Else
        M->W1_REG:=nRegistro
     Endif
   ELSE
      nRet:= nRegistro
   ENDIF
ELSE
   IF !lMemoria
      nRet:= nRegistro
   ENDIF
ENDIF

RestOrd(aOldTrb)
RETURN nRet

*---------------------------------------*
Function SI400Bar(oDlg, lHist)
*---------------------------------------*
Local aButtons := {}

If lHist <> NIL .AND. lHist

      Aadd(aButtons,{"S4WB010N",{||nOpca:=4,oDlg:End()},STR0077})   

EndIf

RETURN aButtons

*-------------------------------------------*
Function SI400BarItem(oDlg,bSelOk,bCancel,nOpc)
*-------------------------------------------*
/* FSM - 21/07/2011
LOCAL bAlterar := {|| cManut := "A", oDlg:End() }
LOCAL bIncluir := {|| cManut := "I", oDlg:End() }
LOCAL bExcluir := {|| cManut := "E", oDlg:End() }

LOCAL bCopiar  := {|| cManut := "C", oDlg:End() }
LOCAL bSWitch  := {|| cManut := "S", oDlg:End() }
*/
PRIVATE oSiBar, bSet15, bSet24, lOk,oOrdena
PRIVATE nOpcSi := nOpc
PRIVATE aBotoes:={}


If SW1->(FieldPos("W1_POSIT")) # 0
   Aadd(aBotoes,{"BMPORD1",{||SI400OrdOpt(oDlg)} ,STR0172}) //STR0172 "Ordena Itens"
  /* DEFINE BUTTON oOrdena RESOURCE "BMPORD1" OF oSiBar ACTION SI400OrdOpt(oDlg); //CCH - 23/07/09 - OrdenaÁ„o de itens por inclus„o ou cÛdigo do item
                 TOOLTIP "Ordena Itens"
                 oOrdena:cTitle:="Ordena Itens"
                 */
EndIf

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"INCLUI_BOTAO")
ENDIF

                   /*
DEFINE BUTTON oBtnOk RESOURCE "OK" OF oSiBar GROUP ;
              ACTION (EVAL(bSelOk)) ;
              TOOLTIP STR0079 //"Ok - <Ctrl-O>"
              oBtnOk:cTitle:= STR0160 //LRL 11/03/04 - "OK"
SETKEY(15,oBtnOK:bAction)

DEFINE BUTTON oBtnCan RESOURCE "CANCEL" OF oSiBar ;
       ACTION (EVAL(bCancel));
       TOOLTIP STR0080 //"Cancelar - <Ctrl-X>"
       oBtnCan:cTitle:= STR0161 //LRL 11/03/04 - "Cancelar"
SETKEY(24,oBtnCan:bAction)
                     */
/*oDlg:bSet15:=oBtnOk :bAction
oDlg:bSet24:=oBtnCan:bAction
oSiBar:bRClicked:={||AllwaysTrue()}
  */
RETURN aBotoes

*----------------------------------------------------------------------------*
Function SI400Historico(cCodigoItem,lConsultaPO)
*----------------------------------------------------------------------------*
   #COMMAND E_RESET_HIST => SETKEY(VK_F11,cOldF11) ; SW3->(DBSETORDER(1))  ;
                        ; DBSELECTAREA("TRB"); RETURN NIL

   LOCAL TB_Campos:={}, oMark, lPassou:=.F. ,cAlias, cTitulo
   LOCAL oPanel
   Local nSizePnl
   Local nRow, nCol
   Local nAlt, nLarg

   LOCAL cOldF11:=SetKey(VK_F11)

   PRIVATE aItens:={} ,  cCodigoProd, cDescri, oDlg2
   PRIVATE cTipo, lHistorico:= .T.
   Private lR4 := FindFunction("TRepInUse") .And. TRepInUse()
   Private oReport, oSecao1
   Private cCodI := cCodigoItem

   IF EMPTY(cCodigoItem)
      Help("", 1, "AVG0000540")//MsgiNFO(OemtoAnsi(STR0086)) //"C¢digo do Item n∆o selecionado"
      RETURN NIL
   ENDIF

   SETKEY(VK_F11,NIL)

   SB1->(DBSEEK(xFilial()+cCodigoItem))

   IF lConsultaPO

      IF !Work2->(DBSEEK(M->W0__CC+M->W0__NUM+cCodigoItem+STR(TRB->W1_REG,AVSX3("W1_REG",3),0)+" 0"))

         Help("", 1, "AVG0000542")//MsgiNFO(OemtoAnsi(STR0087)) //"N∆o h† POs a serem consultados"
         E_RESET_HIST

      ELSE

         Work2->(DBSKIP())

         IF Work2->(EOF()) .OR. M->W0__CC   # Work2->W3_CC    .OR.;
                              M->W0__NUM  # Work2->W3_SI_NUM.OR.;
                              cCodigoItem # Work2->W3_COD_I .OR.;
                              TRB->W1_REG # Work2->W3_REG
            Help("", 1, "AVG0000542")//MsgiNFO(OemtoAnsi(STR0087)) //"N∆o h† POs a serem consultados"
            E_RESET_HIST
         ENDIF

      ENDIF

      cDescri:=MSMM(SB1->B1_DESC_P,30,1)
      cAlias :="Work2"
      cTitulo:=STR0088 //"Pedidos do Item da S.I."
      aLinCol:={38,2,146,322}

      PRIVATE cCodigoFiltro:=M->W0__CC+M->W0__NUM+cCodigoItem+STR(TRB->W1_REG,AVSX3("W1_REG",3),0)
      PRIVATE cPicTotal    :=ALLTRIM(X3Picture("W3_SALDO_Q"))
      PRIVATE cPicQtde     :=ALLTRIM(X3Picture("W3_QTDE"))

      AADD(TB_Campos,{{||IF(Work2->W3_SEQ=0,STR0089,STR0090)} ,,""}) //'Saldo'###'P.O. '
      AADD(TB_Campos,{"W3_PO_NUM"                       ,,STR0091,(AVSX3("W3_PO_NUM")[6])}) //"Pedido"
      AADD(TB_Campos,{"W3_QTDE"                         ,,STR0016 ,cPicQtde}) //"Quantidade"
      AADD(TB_Campos,{"W3_SALDO_Q"                      ,,STR0092,cPicTotal}) //"Sdo. Quant."
      AADD(TB_Campos,{"W3_FABR"                         ,,STR0093}) //"Cod. Fabr."
      AADD(TB_Campos,{{||BuscaFabr_Forn(Work2->W3_FABR,IF(EICLOJA(),Work2->W3_FABLOJ,""))},,STR0012}) //"Fabricante"
      AADD(TB_Campos,{"W3_FORN"                         ,,STR0094}) //"Cod. Forn."
      AADD(TB_Campos,{{||BuscaFabr_Forn(Work2->W3_FORN,IF(EICLOJA(),Work2->W3_FORLOJ,""))},,STR0013}) //"Fornecedor"
      EICAddLoja(TB_Campos, "W3_FORLOJ", cAlias, STR0013)
      EICAddLoja(TB_Campos, "W3_FABLOJ", cAlias, STR0012)

   ELSE

      AvZap("Work1")
      TRB->(DBGOTOP())

      Processa({||ProcRegua(TRB->(Easyreccount("TRB"))),;
               TRB->(DBEVAL({||IncProc(STR0095+TRB->W1_COD_I),; //'Pesquisando Item: '
               IF((P:=ASCAN(aItens,{|It|It[1]=TRB->W1_COD_I}))=0,;
                  AADD(aItens,{TRB->W1_COD_I,TRB->W1_QTDE}),;
                  aItens[P,2]+=TRB->W1_QTDE)} )) } )

      Processa({||SI400PesqHist(cCodigoItem)},STR0096+cCodigoItem) //"Processando Item "

      IF (Work1->(EOF()).AND.Work1->(BOF())) .OR. Work1->(Easyreccount("Work1")) = 0
         Help("", 1, "AVG0000543",,TRANS(cCodigoItem,(AVSX3("W1_COD_I",06))),1,30)//MsgiNFO(OemtoAnsi(STR0097+TRANS(cCodigoItem,(AVSX3("W1_COD_I")[6])))) //"N∆o h† Hist¢rico para o Item "
         E_RESET_HIST
      ENDIF

      cAlias :="Work1"
      cTitulo:=OemToAnsi(STR0098+TRANS(cCodigoItem,(AVSX3("W1_COD_I")[6])))+" - "+MSMM(SB1->B1_DESC_P,40,1) //"Hist¢rico do Item "
      aLinCol:={40,2,146,322}
      cCodigoFiltro:=cCodigoItem
      cTipo        :=STR0099 //'1 - Item Atual'
      cPicQtde    :=ALLTRIM(X3Picture("W3_QTDE"))

   //   PRIVATE cPicTotal    :="@E 9,999,999,999,999.99"
      PRIVATE cPicTotQtde    :=ALLTRIM(X3Picture("W3_QTDE")), cItem

      AADD(TB_Campos,{"W3_FABR"  ,,STR0094}) //"Cod. Forn."
      AADD(TB_Campos,{"A2_NREDUZ",,STR0013}) //"Fornecedor"
      AADD(TB_Campos,{"W3_PO_NUM",,STR0091,(AVSX3("W3_PO_NUM")[6])}) //"Pedido"
      AADD(TB_Campos,{"W2_PO_DT" ,,STR0100}) //"Dt. Pedido"
      AADD(TB_Campos,{"W3_QTDE"  ,,STR0016,cPicQtde}) //"Quantidade"
      AADD(TB_Campos,{{||TRANS(Work1->W2_MOEDA,'!!!')+' '+TRANS((Work1->W3_PR_TOT),_PictPrTot)},,STR0101}) //"Valor Total"
      AADD(TB_Campos,{"W3_CC"    ,,STR0102}) //"Unid. Requ."
      AADD(TB_Campos,{"WK_UNI"   ,,STR0103}) //"Unid. Medida"

      EICAddLoja(TB_Campos, "W3_FABLOJ", cAlias, STR0094)
   ENDIF

   DO WHILE .T.

      nOpca:=0
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0098+cCodigoItem) ; //"Hist¢rico do Item "
            FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
            OF oMainWnd PIXEL

      aLinCol[3]:=if(SetMdiChild(),(oDlg2:nClientHeight+82)/2,(oDlg2:nClientHeight-6)/2) //LRL 11/02/04
      aLinCol[4]:=(oDlg2:nClientWidth -4)/2
      Work1->(DBGOTOP())

      oMark:=MsSelect():New(cAlias,,,TB_Campos,.F.,"OK",aLinCol,"SI400Filtra(cCodigoFiltro)","SI400Filtra(cCodigoFiltro)")

      nAlt := 40

      @00,00 MsPanel oPanel Prompt "" Size nLarg, nAlt of oDlg2 // ACSJ - 12/04/2004

      IF lConsultaPO
         IF EasyEntryPoint("EICSI400")
            ExecBlock("EICSI400",.F.,.F.,"HISTORICO")
         ENDIF
         If lHistorico
            @ 1.5,00.9 SAY OemToAnsi(STR0104) OF oPanel SIZE 050,9 //"C¢digo do Item"
            @ 1.5,17.0 SAY OemToAnsi(STR0105) OF oPanel SIZE 040,9 //"Descriá∆o"
            @ 1.5,06.5 MSGET cCodigoItem OF oPanel WHEN .F.     SIZE 060,9 PICT (AVSX3("W1_COD_I")[6])
            @ 1.5,21.0 MSGET cDescri OF oPanel      WHEN .F.     SIZE 115,9
         EndIf
      ELSE

         nPosY := 1
         nPosX := 1.5

         @ nPosY, nPosX SAY OemToAnsi(STR0077) OF oPanel //"Impress∆o"
         @ nPosY, nPosX + 4.5 COMBOBOX cTipo ITEMS {STR0099,STR0106}; //'1 - Item Atual'###'2 - Todos os Itens'
                              SIZE 75,30 OF oPanel
      ENDIF

      oPanel:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oMark:oBrowse:Refresh() //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      oDlg2:lMaximized:=.T. // NCF - 19/09/2019
      //DFS - 04/02/13 - Inclus„o de refresh na tela
      ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,;
                                                   {||nOpca:=0,oDlg2:End()},;
                                                   {||nOpca:=0,oDlg2:End()},,;
                                                   SI400Bar(oDlg2,!lConsultaPO),;
                                                   oMark:oBrowse:Refresh()) //FSM - 21/07/2011 // ACSJ - 12/04/2004 //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      IF nOpca = 0

         E_RESET_HIST

      ELSEIF nOpca = 4

         IF lConsultaPO ; EXIT ; ENDIF

         IF Left(cTipo,1) == "2" //ASR 17/06/2006 - cTipo = "2"
            IF !lPassou
               AvZap("Work1")
               AEVAL(aItens,{|It|cItem:=It[1],;
                           Processa({||SI400PesqHist(cItem)},;
                           STR0096+cItem)}) //"Processando Item "
            ENDIF
            lPassou:=.T.
            If !lR4
               SIRelHistorico("")
            Else
               ReportDef()
               oReport:PrintDialog()
            EndIf
         ELSE
            If !lR4
               SIRelHistorico(cCodigoItem)
            Else
               ReportDef()
               oReport:PrintDialog()
            EndIf
         ENDIF
         
         LOOP
      ENDIF

      EXIT

   ENDDO

E_RESET_HIST

*---------------------------------------*
Function SI400Filtra(cCodigoItem)
*---------------------------------------*
RETURN cCodigoItem

*---------------------------------------*
Function SI400PesqHist(cCodigoItem)
*---------------------------------------*
LOCAL nCont:=0, bWhile:={||cFil3==W3_FILIAL.AND.cCodigoItem==W3_COD_I}, nDeleta

LOCAL bSeleciona:={||IncProc(STR0107+ALLTRIM(SW3->W3_PO_NUM)),; //'Pesquisando Pedido: '
                     SW2->(DBSEEK(cFil2+SW3->W3_PO_NUM)),;
                     IF(ASCAN(aPOs,{|Po|Po[1]=SW3->W3_PO_NUM})=0,;
                     AADD(aPOs,{SW3->W3_PO_NUM,SW2->W2_PO_DT}),)}

LOCAL bForSel:={||IncProc(STR0107+ALLTRIM(SW3->W3_PO_NUM)),; //'Pesquisando Pedido: '
                  SW3->W3_SEQ=0}

LOCAL bFor:={||IncProc(STR0107+ALLTRIM(SW3->W3_PO_NUM)),; //'Pesquisando Pedido: '
               SW2->(DBSEEK(cFil2+SW3->W3_PO_NUM)),;
               SW3->W3_SEQ=0 .AND.;
               ASCAN(aPOs,{|Po|Po[1]=SW3->W3_PO_NUM})#0}

PRIVATE cFil3:=xFilial("SW3"), cFil2:=xFilial("SW2"), aPOs:={}

SW3->(DBSETORDER(3))
SA5->(DBSETORDER(3))
SB1->(DBSETORDER(1))
SB1->(DBSEEK(xFilial()+cCodigoItem))
SW3->(DBSEEK(cFil3+cCodigoItem))
SW3->(DBEVAL({||nCont++},,bWhile,,,.T.))

ProcRegua(nCont*2)
SW3->(DBSEEK(cFil3+cCodigoItem))
SW3->(DBEVAL(bSeleciona,bForSel,bWhile,,,.T.))

IF LEN(aPOs) > 3
   ASORT(aPOs,,,{|D1,D2| D1[2] > D2[2] })
   ASIZE(aPOs,3)
ENDIF

SW3->(DBSEEK(cFil3+cCodigoItem))
SW3->(DBEVAL({||SI400GrHist(cCodigoItem)},bFor,bWhile,,,.T.))

RETURN .T.

*----------------------------------------------------------------------*
FUNCTION SI400GrHist(cCodigoItem)
*----------------------------------------------------------------------*
//SA5->(DBSEEK(xFilial()+cCodigoItem+SW3->W3_FABR+SW2->W2_FORN))
EICSFabFor(xFilial("SA5")+cCodigoItem+SW3->W3_FABR+SW2->W2_FORN,  EICRetLoja("SW3", "W3_FABLOJ"), EICRetLoja("SW2", "W2_FORLOJ"))

IF Work1->(DBSEEK(cCodigoItem+DTOS(SW2->W2_PO_DT)+SW3->W3_PO_NUM))
   Work1->W3_QTDE  +=SW3->W3_QTDE
   Work1->W3_PR_TOT+=(SW3->W3_PRECO*SW3->W3_QTDE)
ELSE
   Work1->(DBAPPEND())
   Work1->W3_COD_I :=SW3->W3_COD_I
   Work1->W3_FABR  :=SW2->W2_FORN
   If EICLOJA()
      Work1->W3_FABLOJ:=SW3->W3_FABLOJ
   ENDIF
   Work1->A2_NREDUZ:=BuscaFabr_Forn(SW2->W2_FORN,IF(EICLOJA(),SW2->W2_FORLOJ,""))
   Work1->W3_PO_NUM:=SW3->W3_PO_NUM
   Work1->W2_PO_DT :=SW2->W2_PO_DT
   Work1->W3_QTDE  :=SW3->W3_QTDE
   Work1->W1_QTDE  :=aItens[ASCAN(aItens,{|It|It[1]=SW3->W3_COD_I}),2]
   Work1->W3_PR_TOT:=(SW3->W3_PRECO*SW3->W3_QTDE)
   Work1->W2_MOEDA :=SW2->W2_MOEDA
   Work1->W3_CC    :=SW3->W3_CC
   IF EICLOJA()
      Work1->WK_UNI   :=BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR +SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM,SW3->W3_FABLOJ,SW3->W3_FORLOJ)
   ELSE
      Work1->WK_UNI   :=BUSCA_UM(SW3->W3_COD_I+SW3->W3_FABR +SW3->W3_FORN,SW3->W3_CC+SW3->W3_SI_NUM,"","")
   ENDIF
   Work1->W1_ALI_WT:= "SW3"
   Work1->W1_REC_WT:= SW3->(Recno())
ENDIF

RETURN .T.

*---------------------------------------*
Function SIRelHistorico(cCodigoItem)
*---------------------------------------*
LOCAL bWhile:={||EMPTY(cCodigoItem).OR.cCodigoItem==W3_COD_I}

#DEFINE COURIER_07 oFont1
#DEFINE COURIER_08 oFont2
#DEFINE COURIER_10 oFont3
#DEFINE COURIER_12 oFont4

//mjb160300 PRINT oPrn NAME ""
//mjb160300       oPrn:SetPortrait()
//mjb160300 ENDPRINT

AVPRINT oPrn NAME OemToAnsi(STR0108) //"Hist¢rico dos Pedidos"

   DEFINE FONT oFont1  NAME "Courier New" SIZE 0,07 OF  oPrn
   DEFINE FONT oFont2  NAME "Courier New" SIZE 0,08 OF  oPrn
   DEFINE FONT oFont3  NAME "Courier New" SIZE 0,10 OF  oPrn
   DEFINE FONT oFont4  NAME "Courier New" SIZE 0,12 OF  oPrn

   AVPAGE

      oPrn:oFont:=COURIER_08

      Work1->(DBGOTOP())

      MPag    := nCont:= 0
      lPrimPag:= .T.
      MLin    := 9999
      nLimPage:= 3000
      nColFim := 2300
      nColIni := 0001
      cCodItem:= Work1->W3_COD_I

      nCol1:=QC210xCol(001); nCol2:=QC210xCol(27); nCol3:=QC210xCol(41)
      nCol4:=QC210xCol(064); nCol5:=QC210xCol(88); nCol6:=QC210xCol(89)
      nCol7:=QC210xCol(100)

      IF !EMPTY(cCodigoItem)
         Work1->(DBSEEK(cCodigoItem))
         Work1->(DBEVAL({||nCont++},,{||cCodigoItem==W3_COD_I},,,.T.))
         Work1->(DBSEEK(cCodigoItem))
      ELSE
         nCont:=Work1->(Easyreccount("Work1"))
      ENDIF

      Processa({||ProcRegua(nCont),Work1->(DBEVAL({||SI400DetHist()},,bWhile))},STR0109) //"Impressao"

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

RETURN .T.

*--------------------*
FUNCTION SI400CabHist()
*--------------------*
LOCAL cTitulo1:=OemToAnsi(STR0110) //"Hist¢rico dos Pedidos de Itens"
//LOCAL cTitulo2:=OemToAnsi(STR0111+SW0->W0__CC+STR0112+SW0->W0__NUM) //"Item(ns) da Unid. Requ.: "###"  Solicitaá∆o: "
LOCAL cC01:=STR0113 //'         Fornecedor'
LOCAL cC02:=STR0114 //'     Pedido'
LOCAL cC03:=STR0115       //'  Data'
LOCAL cC04:=STR0116 //'Quantidade   '
LOCAL cC05:=STR0117 //'Valor Total      '
LOCAL cC06:=STR0118 //'Unid. Requ.'
LOCAL cC07:=STR0119 //'Unid. Medida'

IF lPrimPag
   lPrimPag:=.F.
ELSE
   AVNEWPAGE
ENDIF

MLin:= 100
MPag++

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=25

oPrn:Say(MLin,nColIni  ,SM0->M0_NOME,COURIER_10)
oPrn:Say(MLin,nColFim/2,cTitulo1,COURIER_10,,,,2)
oPrn:Say(MLin,nColFim  ,STR0120+STR(MPag,8),COURIER_10,,,,1) //"Pagina..: "
MLin+=50

oPrn:Say(MLin,nColIni  ,"SIGAEIC",COURIER_10)
//oPrn:Say(MLin,nColFim/2,cTitulo2,COURIER_10,,,,2)
oPrn:Say(MLin,nColFim  ,STR0121+DTOC(dDataBase),COURIER_10,,,,1) //"Emissao.: "
MLin+=50

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=50

oPrn:oFont:=COURIER_08
oPrn:Say(MLin,nCol1,cC01)
oPrn:Say(MLin,nCol2,cC02)
oPrn:Say(MLin,nCol3,cC03)
oPrn:Say(MLin,nCol4,cC04,,,,,1)
oPrn:Say(MLin,nCol5,cC05,,,,,1)
oPrn:Say(MLin,nCol6,cC06)
oPrn:Say(MLin,nCol7,cC07)
MLin +=20

cC01:=TRANS(Work1->W3_FABR,REPL('!',LEN(Work1->W3_FABR)))+' '+Work1->A2_NREDUZ
cC02:=Work1->W3_PO_NUM
cC03:=DTOC(Work1->W2_PO_DT)
cC04:=TRANS(Work1->W3_QTDE,cPicQtde)
cC05:=TRANS(Work1->W2_MOEDA,'!!!')+' '+TRANS((Work1->W3_PR_TOT),_PictPrTot)

oPrn:Say(MLin,nCol1,REPL("-",LEN(cC01)))
oPrn:Say(MLin,nCol2,REPL("-",LEN(cC02)))
oPrn:Say(MLin,nCol3,REPL("-",LEN(cC03)))
oPrn:Say(MLin,nCol4,REPL("-",LEN(cC04)),,,,,1)
oPrn:Say(MLin,nCol5,REPL("-",LEN(cC05)),,,,,1)
oPrn:Say(MLin,nCol6,REPL("-",LEN(cC06)))
oPrn:Say(MLin,nCol7,REPL("-",LEN(cC07)))
MLin +=60

SI400SubHist()

RETURN .T.

*----------------------*
FUNCTION SI400SubHist()
*----------------------*

PRIVATE cItemHist  := ALLTRIM(Work1->W3_COD_I)
PRIVATE cItemHist2 := STR0122

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"SUBHIST")
ENDIF

SB1->(DBSEEK(xFilial()+Work1->W3_COD_I))
oPrn:Say(MLin,nCol1   ,cItemHist2+cItemHist+" - "+MSMM(SB1->B1_DESC_P,20,1),COURIER_08) //'Item.: '
oPrn:Say(MLin,nCol4   ,TRANS(Work1->W1_QTDE,cPicTotQtde),,,,,1)
oPrn:Say(MLin,nCol4+15,STR0123) //"(Solicitada)"
MLin +=40

RETURN .F.

*----------------------*
FUNCTION SI400DetHist()
*----------------------*
LOCAL lBateu:=.F.
IncProc(STR0124+Work1->W3_COD_I) //'Imprimindo Item: '


IF MLin > nLimPage
   lBateu:=SI400CabHist()
ENDIF

IF cCodItem # Work1->W3_COD_I
   IF !lBateu
      MLin +=20
      oPrn:Box( MLin,nColIni,MLin+1,nColFim)
      MLin +=40
      lBateu:=SI400SubHist()
   ENDIF
   cCodItem:=Work1->W3_COD_I
ENDIF

oPrn:oFont:=COURIER_08
oPrn:Say(MLin,nCol1,TRANS(Work1->W3_FABR,REPL('!',LEN(Work1->W3_FABR)))+' '+Left(Work1->A2_NREDUZ,(nLenReduz-(nLenForn-6))))//SO.:0026 OS.:0250/02 FCD
oPrn:Say(MLin,nCol2,Work1->W3_PO_NUM)
oPrn:Say(MLin,nCol3,DTOC(Work1->W2_PO_DT))
oPrn:Say(MLin,nCol4,TRANS(Work1->W3_QTDE,cPicQtde),,,,,1)
oPrn:Say(MLin,nCol5,TRANS(Work1->W2_MOEDA,'!!!')+' '+TRANS((Work1->W3_PR_TOT),_PictPrTot),,,,,1)
oPrn:Say(MLin,nCol6+50,Work1->W3_CC)
oPrn:Say(MLin,nCol7+75,Work1->WK_UNI)
MLin +=40

RETURN .T.


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥SI400Manut≥ Autor ≥ Cristiano A. Ferreira ≥ Data ≥ 10/9/1998≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Efetua manutencao no arquivo (Inclusao/Alteracao/Exclusao) ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ SI400Manut(<cOpcao>)                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ SI400                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function SI400Manut(cOpcaoAux)
LOCAL oDlg, cAlias:=Alias()
LOCAL nOpca := 0, cTitle, i, nSizeOld
LOCAL nRec_TRB, bOk
LOCAL aPos2 := {15,1,140,315}
Local cOldF11:=SETKEY(VK_F11)
PRIVATE aSW1 := {"W1_COD_I",;
                 "W1_COD_DES","W1_FABR",;
                 "W1_FAB_NOM","W1_FORN",;
                 "W1_FOR_NOM","W1_CLASS",;
                 "W1_VMCLASS","W1_QTDE",;
                 "W1_SALDO_Q","W1_PRECO",;
                 "W1_DT_EMB","W1_DTENTR_"}

Private cOpcao:=cOpcaoAux // para ser utilizado no rdmake

If Type("lSIAuto") == "U"
   lSIAuto:= .F.
EndIf

EICAddLoja(aSW1, "W1_FORLOJ", Nil, "W1_FORN")
EICAddLoja(aSW1, "W1_FABLOJ", Nil, "W1_FABR")
If lCpoCCusto
   aAdd(aSW1,"W1_CTCUSTO")
EndIf

If SW1->(FieldPos("W1_POSIT")) # 0
   AAdd(aSW1,Nil)
   AIns(aSW1,1)
   aSW1[1] := "W1_POSIT"
EndIf

// SI400 Campos para a Enchoice                              -   JBS 06/10/2003
IF cPaisLoc # "BRA" .AND. SW1->(FIELDPOS("W1_NATUREZ")) # 0
    AADD(aSW1,"W1_NATUREZ")
ENDIF

If SW1->(FieldPos("W1_CODMAT")) # 0  // GFP - 05/03/2014
   aAdd(aSW1,"W1_CODMAT")
EndIf

IF EasyEntryPoint(cArqRdmake)
   nExecute:="5"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

IF EasyEntryPoint("EICSI400")
   ExecBlock("EICSI400",.F.,.F.,"CAMPOS_ENCHOICE")
ENDIF

IF lForeCast
   AADD(aSW1,"W1_FORECAS")
ENDIF

IF(lUnisys,ExecBlock("IC159SI0",.F.,.F.,"6"),)
IF(lHunter,ExecBlock("IC010PO1",.F.,.F.,"5"),)


PRIVATE aTela[0][0],aGets[0],nUsado:=0

dbSelectArea("TRB")
nRec_Trb := TRB->(Recno())

If (cOpcao == "E" .Or. cOpcao == "A") .And. Easyreccount("TRB") == 0
   Help("", 1, "AVG0000545")//MsgStop(STR0125, STR0061) //"N„o existem registros para a manutenÁ„o !"###"AtenÁ„o"
   Return .t.
ElseIf (cOpcao == "E" .Or. cOpcao == "A") .And. Eof()
   TRB->(dbGoBottom())
   If TRB->(Eof() .Or. Bof())
      Help("", 1, "AVG0000545")//MsgStop(STR0125, STR0061) //"N„o existem registros para a manutenÁ„o !"###"AtenÁ„o"
      Return .t.
   Endif
Elseif (cOpcao == "E" .Or. cOpcao == "A") .And. Bof()
   TRB->(dbGoTop())
   If TRB->(Eof() .Or. Bof())
      Help("", 1, "AVG0000545")//MsgStop(STR0125, STR0061) //"N„o existem registros para a manutenÁ„o !"###"AtenÁ„o"
      Return .t.
   Endif
Endif

If cOpcao == "I"
   TRB->(dbGoBottom())
   TRB->(dbSkip())
Endif

// FSM - 29/07/2011
FOR i := 1 TO TRB->(FCount())
    cCampo := AllTrim(TRB->(FIELDNAME(i)))
    If cOpcao == "I" .And. SX3->( DBSeek( cCampo ) ) //.And. aSI400Reg != Nil
       M->&(TRB->(FIELDNAME(i))) := CRIAVAR(TRB->(FIELDNAME(i)))
    Else
       M->&(TRB->(FIELDNAME(i))) := TRB->(TRB->(FIELDGET(i)))
    Endif
NEXT i



If SW1->(FieldPos("W1_POSIT")) # 0
   M->W1_POSIT := SI400NumPoItem()
EndIf

If cOpcao == "I"
   cTitle := STR0126 //"Solicitaá∆o de Importaá∆o - Inclus∆o de Itens"
Elseif cOpcao == "A"
   cTitle := STR0127 //"Solicitaá∆o de Importaá∆o - Alteraá∆o de Itens"
Elseif cOpcao == "E"
   cTitle := STR0128 //"Solicitaá∆o de Importaá∆o - Exclus∆o de Itens"
Endif

SETKEY(VK_F11,NIL)

If !lSIAuto

   WHILE .T.
      nOpca := 0
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitle);
           FROM oMainWnd:nTop+160,oMainWnd:nLeft+100 TO oMainWnd:nBottom-180,oMainWnd:nRight - 080 ;
     	     OF oMainWnd PIXEL

    aPos2[3]:=If(SetMdiChild(),(oDlg:nClientHeight+82)/2,(oDlg:nClientHeight-2)/2) //LRL 12/03/04 - O tamnho da janela È <> no MDI
    aPos2[4]:=(oDlg:nClientWidth -2)/2
    oEnch1 := MsMGet():New( "SW1", nRec_TRB, IF(cOpcao=="I",3,4), , , ,aSW1, aPos2, IF(cOpcao == "E",{},) ,3)

    If ! (cOpcao == "E")
       bOk := {||IF(Obrigatorio(aGets,aTela) .AND. SI400LinOk(.t.), (nOpca:=1,oDlg:End()) , ) }
    Else
       bOk := {|| nOpca:=1,oDlg:End() }
    Endif

   oEnch1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
   oDlg:lMaximized:=.T. // NCF - 19/09/2019
   ACTIVATE MSDIALOG oDlg ON INIT ((EnchoiceBar(oDlg,bOk,{||oDlg:End()})))

    IF nOpca == 1
       IF EasyEntryPoint("EICSI400")
          ExecBlock("EICSI400",.F.,.F.,"VALMARCOD")
       Endif
       SI400EFETIVA(cOpcao,nRec_Trb)
       If SW1->(FieldPos("W1_POSIT")) # 0
          M->W1_POSIT := SI400NumPoItem()
       EndIf
       IF cOpcao=="I"
          LOOP
       ENDIF
    ENDIF

    IF nOpca == 0
       TRB->(dbGoTo(nRec_Trb))
       EXIT
    ENDIF

    EXIT
END

dbSelectArea(cAlias)

lRefresh:=.t.

SETKEY(VK_F11,cOldF11)

End
Return .T.


Function SI400EFETIVA(cOpcao,nRec_Trb)
Local i
    IF cOpcao == "I"
       TRB->(DBAPPEND())
       nRec_Trb := TRB->(Recno())
    ELSE
       TRB->(DBGOTO(nRec_Trb))

       IF Work2->(DBSEEK(M->W0__CC+M->W0__NUM+TRB->W1_COD_I+STR(TRB->W1_REG,AVSX3("W1_REG",3),0)+" 0"))
          Work2->W3_FABR    := M->W1_FABR
          IF EICLOJA()
             Work2->W3_FABLOJ  := M->W1_FABLOJ
          ENDIF
          Work2->W3_FORN    := M->W1_FORN
          IF EICLOJA()
             Work2->W3_FORLOJ  := M->W1_FORLOJ
          ENDIF
          Work2->W3_QTDE    := M->W1_QTDE
          Work2->W3_SALDO_Q := M->W1_SALDO_Q
       EndIf


    EndIf

    dbSelectArea("TRB")

    If cOpcao == "A" .Or. cOpcao == "I"
/*
       aSI400Reg := {}

       For i := 1 TO TRB->(FCount())
           aAdd( aSI400Reg, TRB->(M->&(FIELDNAME(i))) )

           TRB->(FieldPut(i,M->&(FIELDNAME(i)) ))

           If AllTrim(TRB->(FieldName(i))) == "RECNO" .Or.;
              AllTrim(TRB->(FieldName(i))) == "W1_REG"
              aSI400Reg[i] := 0
           Endif
           If AllTrim(TRB->(FieldName(i))) == "W1_QTDE"
              aSI400Reg[i] := M->W1_SALDO_Q
           Endif
       Next
*/
       For i := 1 TO TRB->(FCount())
           TRB->(FieldPut(i,M->&(FIELDNAME(i)) ))
       Next
       TRB->W1_ALI_WT:= "SW1"
       TRB->W1_REC_WT:= SW1->(Recno())
       TRB->W1_REC_B1:= GetRecSB1(TRB->W1_COD_I)

       IF EasyEntryPoint("EICSI400")	//ASR 04/11/2005
          ExecBlock("EICSI400",.F.,.F.,"ALTERA_VARMEMO")
       ENDIF

    Elseif cOpcao == "E"

       TRB->(DBGOTO(nRec_Trb))
       IF TRB->W1_QTDE <> TRB->W1_SALDO_Q
          Help("", 1, "AVG0000546")//MSGINFO(STR0129, STR0061) //"Item n„o pode ser excluÌdo, processo de importaÁ„o em andamento"###"AtenÁ„o"
          Return .F.
       ENDIF

       aAdd( aSI400Del, TRB->RECNO )
       TRB->W1_FLAG:=.T.					//CDS 23/08/04
       TRB->(dbDelete())
       TRB->(dbGOTOP())
    ENDIF

    M->W1_COD_I   :=SPACE(LEN(SW1->W1_COD_I))
    M->W1_COD_DES :=SPACE(LEN(M->W1_COD_DES))
    M->W1_REG     :=0
    M->RECNO      :=0
    /* FSM - 01/08/2011 */
    M->W1_FABR    := Space(AVSX3("W1_FABR",3))
    M->W1_FABLOJ  := Space(AVSX3("W1_FABLOJ",3))
    M->W1_FAB_NOM := Space(AVSX3("W1_FAB_NOM",3))
    M->W1_FORN    := Space(AVSX3("W1_FORN",3))
    M->W1_FORLOJ  := Space(AVSX3("W1_FORLOJ",3))
    M->W1_FOR_NOM := Space(AVSX3("W1_FOR_NOM",3))
    M->W1_CLASS   := Space(AVSX3("W1_CLASS",3))
    M->W1_VMCLASS := Space(AVSX3("W1_VMCLASS",3))
    M->W1_QTDE    := 0
    M->W1_SALDO_Q := 0
    M->W1_PRECO   := 0
    M->W1_DT_EMB  := cToD("  /  /  ")
    M->W1_DTENTR_ := cToD("  /  /  ")

Return .T.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥BrwRefresh≥ Autor ≥ Cristiano A. Ferreira ≥ Data ≥10/13/1998≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Redesenha o objeto Browse.                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ BrwRefresh(cAlias,oBrw)                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function BrwRefresh( cAlias, oBrw )
Local nSizeOld

If (cAlias)->(Eof())
   oBrw:GoBottom()
ElseIf (cAlias)->(Bof())
   oBrw:GoTop()
Endif

// Altera o tamanho de uma coluna para redesenhar o Browse

nSizeOld :=  oBrw:aColSizes[1]

oBrw:aColSizes[1] := 1
oBrw:Refresh()

oBrw:aColSizes[1] := nSizeOld
oBrw:Reset()
oBrw:UpStable()
oBrw:Refresh()

Return nil

*--------------------------------------------------
Function SI400Tabela(cTabela,cCodigo)
*--------------------------------------------------
Local cRetorno := ""

IF !Empty(cCodigo)
   cRetorno := Tabela(cTabela,cCodigo)
Endif

Return (cRetorno)

*---------------------------------------------------------------------------*
FUNCTION A5FORNFABR(cTipo)
*---------------------------------------------------------------------------*
// Ultima Modificacao:  23/08/04    Para MsGetDB
// Autor: CDS

LOCAL oDlg, FileWork, Tb_Campos:={}, OldArea:=SELECT(), OldOrd:=SA5->(INDEXORD())
LOCAL cTitulo, cCampo, cCampo2, cTit1, cTit2, lOK:=.F., oMarkSA5
Local bOk := {|| If(MsgYesNo(STR0184,STR0061),(lOK:=.T.,SIPreencheT(),oDlg:End()),Eval(bReturn))} //FSM 07/07/2011 //STR0184 "Deseja preencher o Fabricante e o Fonecedor?" //STR0061 "AtenÁ„o"
Local bCancel := {|| (lOK:=.F.,oDlg:End()) }//FSM 07/07/2011
Private cCadastro
If lComEdit
	bReturn:={||lOK:=.T.,(TRB->W1_FABR:=SA5->A5_FABR, If(EicLoja(), TRB->W1_FABLOJ := SA5->A5_FALOJA,) ),oDlg:End()}//LGS-10/12/2014 //FSM - 07/07/2011
Else
	bReturn:={||lOK:=.T.,(M->W1_FABR:=SA5->A5_FABR, If(EicLoja(), M->W1_FABLOJ := SA5->A5_FALOJA,) ),oDlg:End()}    //LGS-10/12/2014 //FSM - 07/07/2011
Endif

cCampo:=IF(UPPER(cTipo)=="FABR","A5_FABR","A5_FORNECE")
If EICLoja()
   cLoja :=IF(UPPER(cTipo)=="FABR","A5_FALOJA","A5_LOJA")
EndIF
cCampo2:=IF(UPPER(cTipo)=="FABR","A5_FORNECE","A5_FABR")
If EICLoja()
   cLoja2 :=IF(UPPER(cTipo)=="FABR","A5_LOJA","A5_FALOJA")
EndIF
cTit1 :=IF(UPPER(cTipo)=="FABR",STR0012,STR0013) //"Fabricante"###"Fornecedor"
cTit2 :=IF(UPPER(cTipo)=="FABR",STR0013,STR0012) //"Fornecedor"###"Fabricante"

AADD(Tb_Campos,{cCampo ,,STR0130}) //"Codigo"
If EICLoja()
   AADD(Tb_Campos,{cLoja ,,STR0173}) //STR0173 = "Loja"
EndIF
AADD(Tb_Campos,{{||BuscaFabr_Forn(FieldGet(FieldPos(cCampo)), If(EICLoja(), FieldGet(FieldPos(cLoja)),Nil))},,cTit1})     //A5_FABR
AADD(Tb_Campos,{cCampo2,,STR0130}) //"Codigo"
If EICLoja()
   AADD(Tb_Campos,{cLoja2 ,,STR0173}) //STR0173 = "Loja"
EndIF
AADD(Tb_Campos,{{||BuscaFabr_Forn(FieldGet(FieldPos(cCampo2)), If(EICLoja(), FieldGet(FieldPos(cLoja2)),Nil))},,cTit2})
AADD(Tb_Campos,{"A5_PRODUTO",,STR0131}) //"Item"
AADD(Tb_Campos,{"A5_CODPRF",,STR0132}) //"Part-Number"

DBSELECTAREA("SA5")
SA5->(DBSETORDER(3))

If lComEdit
	IF ! SA5->(DBSEEK(xFilial("SA5")+ALLTRIM(TRB->W1_COD_I)))
	   Help("", 1, "AVG0000547")//MsgInfo(STR0133) //"Nao ha Fabricantes e Fornecedores cadastrados para este produto"
	   RETURN .F.
	ENDIF
ELSE
	IF ! SA5->(DBSEEK(xFilial("SA5")+ALLTRIM(M->W1_COD_I)))
	   Help("", 1, "AVG0000547")//MsgInfo(STR0133) //"Nao ha Fabricantes e Fornecedores cadastrados para este produto"
	   RETURN .F.
	ENDIF
ENDIF

cTitulo:=STR0134+IF(UPPER(cTipo)=='FABR',STR0135,STR0136) //"Consulta Padrao de Itens "###'Fabricantes'###'Fornecedores'
cCadastro := cTitulo
IF UPPER(cTipo) == 'FORN'

If lComEdit
   bReturn:={||lOK:=.T.,(TRB->W1_FORN:=SA5->A5_FORNECE, If(EicLoja(), TRB->W1_FORLOJ:= SA5->A5_LOJA,)),oDlg:End()}
ELSE
   bReturn:={||lOK:=.T.,(M->W1_FORN:=SA5->A5_FORNECE, If(EicLoja(), M->W1_FORLOJ:= SA5->A5_LOJA,)),oDlg:End()}
Endif

ENDIF

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 4,3 TO 20,75 OF oMainWnd

   DBSELECTAREA("SA5")
       oMarkSA5:=MsSelect():New("SA5",,,TB_Campos,@lInverte,@cMarca,{20,6,100,160},"A5_DSel","A5_DSel",,,,)//.T.) 20/06/08 - CCH - Par‚metro .T. removido da MSSELECT pois de acordo com a nova sintaxe, foi adicionado o 13∫ par‚metro e o mesmo recebe caractere, n„o booleano
   oMarkSA5:oBrowse:bWhen:={||(dbSelectArea("SA5"),.t.)}
   oMarkSA5:baval:=bOk

//       DEFINE SBUTTON FROM 10,165 TYPE 1 ACTION (Eval(oMarkSA5:baval)) ENABLE OF oDlg PIXEL
//       DEFINE SBUTTON FROM 25,165 TYPE 2 ACTION (lOK:=.F.,oDlg:End()) ENABLE OF oDlg PIXEL

oMarkSA5:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oMarkSA5:oBrowse:Refresh()
//oDlg:lMaximized:=.T. // NCF - 19/09/2019
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bOk, bCancel )) // ACSJ 12/04/2004

SET FILTER TO
SA5->(DBSETORDER(OldOrd))
DBSELECTAREA(OldArea)
lRefresh:=.T.

RETURN lOK

/* FSM - 07/07/2011 - FunÁ„o para preencher os campos Forncedor Fabricante e suas respectivas lojas */
Static Function SIPreencheT()
Local cFonte := If(lComEdit,"TRB","M")
/*Local bReturn := {|| ((cFonte)->W1_FORN:=SA5->A5_FORNECE, If(EicLoja(), (cFonte)->W1_FORLOJ:= SA5->A5_LOJA,),;
                      (cFonte)->W1_FABR:=SA5->A5_FABR   , If(EicLoja(), (cFonte)->W1_FABLOJ:= SA5->A5_LOJA,)) }*/
Local bReturn := {|| ( &( (cFonte) + "->W1_FORN := SA5->A5_FORNECE"), If(EicLoja(), &( (cFonte)+"->W1_FORLOJ:= SA5->A5_LOJA"),),;
                       &( (cFonte) + "->W1_FABR := SA5->A5_FABR")   , If(EicLoja(), &( (cFonte)+"->W1_FABLOJ:= SA5->A5_FALOJA"),))} //LGS-11/12/2014

Eval(bReturn)
Return .T.

******************
Function A5_DSel()
******************
// Ultima Modificacao:  23/08/04    Para MsGetDB
// Autor: CDS

If lComEdit
	Return xFilial("SA5")+TRB->W1_COD_I
Else
	Return xFilial("SA5")+M->W1_COD_I
Endif

*--------------------------------------------*
Function SIcomKit()
*--------------------------------------------*
LOCAL oDlg, cOpcao := "x", nOpcao := SEM_KIT
LOCAL oRadio, lOk := .f.

DEFINE MSDIALOG oDlg FROM 9,10 TO 17,42  TITLE STR0009 //"SolicitaÁ„o de ImportaÁ„o"

@  8,10 TO 48,80  LABEL STR0137  OF oDlg PIXEL //"Tipo de S.I.:"
@ 18,13 RADIO oRadio VAR nOpcao ITEMS STR0138,STR0139 3D SIZE 45,13 PIXEL ;   //"S.I. Normal"###"S.I. com Kit"
                                                                OF oDlg

DEFINE SBUTTON FROM 10,90 TYPE 1 ACTION (lOk:=.t.,oDlg:End()) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 37,90 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL
oDlg:lMaximized:=.T. // NCF - 19/09/2019
ACTIVATE MSDIALOG oDlg CENTERED

IF lOk
   cOpcao := Str(nOpcao,1)
Endif

Return cOpcao
*-------------------------------*
Static Function EICSI400FIL(lFil)
*-------------------------------*
Local cFiltro, cAlias
If lFilDa
   cAlias:=Alias()
   DbSelectArea("SW0")
   If lFil
      cFiltro := "W0_FILIAL='"+xFilial("SW0")+"' .And. W0_HAWB_DA = '"+Space(Len(SW0->W0_HAWB_DA))+"'"
      SET FILTER TO &cFiltro
   Else
      SET FILTER TO
   EndIf
   DbSelectArea(cAlias)
EndIf
Return .T.

*---------------------------------*
Static Function LimpaOnSwitch(lModo)
*---------------------------------*
// Function: Limpar TRB dos items apagados ao cambiar modo edicao (msGetDb-MsSelect)
// Autor: CDS
// Data : 23/08/04
// Param: lModo = Modo Edicao Atual (.T. Modo MsGet, .F.=Modo MsSelect)
// Retorna: .T.

TRB->(DBSetOrder(0))

// Se estou insirindo um registro vazio no MsGetDB e mudo de modo, apagar o registro
 If lModo
   TRB->(DBGoBottom())
   If Empty(TRB->W1_COD_I)
      TRB->(DBDelete())
   Endif

   TRB->(__DBPack())
 Endif

 TRB->(DBGotop())
 SET DELETED OFF
 While !TRB->(Eof())

   // Mudando do Modo MsGetDb pra MsSelect
   If lModo
      If Empty(TRB->W1_COD_I).or.TRB->W1_FLAG
         TRB->(DbDelete())
      Endif
      // Mudando do Modo MsSelect para MsGetDb
   Else
      IF TRB->(Deleted())
      //    RECALL
         TRB->W1_FLAG:=.T.
      Endif
   Endif
   TRB->(DbSkip())
 End
 SET DELETED ON
 TRB->(DbGotop())
Return(.T.)

*------------------------------------------------------------------*
USER Function SI400ApagaReg()
*------------------------------------------------------------------*
// Function: Recuperar/Apagar da tabela de Apagados no caso Cambio
//           Modo Edicao (msGetDb-MsSelect)
// Autor: CDS
// Data : 23/08/04
// Param: nao
// Retorna: .T.
// Descricao: Funcao chamada desde o MsGetDB
//Local ny
Local lSt:=TRB->W1_FLAG
Local nRc:=TRB->RECNO

//For ny:=1 to len(aSI400Del)
//    If aSI400Del[ny] == nRC
//       If lSt==.T.      		// Estou Recuperando o Registro
//         aSI400Del[ny]:=0
//       else
//         aSI400Del[ny]:=nRc     // Estou apagando o registro
//       Endif
//       Exit						//Sim Achou, sair
//    Endif
//Next

//** PLB 27/09/06 - Nova validaÁ„o para deletar direto na MSGetDB
 Local nPos
 Private lRet := .T.

  IF TRB->W1_QTDE <> TRB->W1_SALDO_Q .AND. !(Type("lEstornaCapa")=="L" .And. lEstornaCapa)  // GFP - 08/04/2014
      Help("", 1, "AVG0000546")//"Item n„o pode ser excluÌdo, processo de importaÁ„o em andamento"###"AtenÁ„o"
      lRet := .F.
  ENDIF
  //SVG 17-11-08
  If lRet
     IF EasyEntryPoint("EICSI400")
        ExecBlock("EICSI400",.F.,.F.,"MSGETDB_DEL")
     Endif
  EndIf

   If lRet
      If ( nPos := AScan(aSI400Del,{ |x| x == nRc } ) ) > 0    // Se encontrar no Array de deletados
         If lSt   // Retira da lista de exclus„o
            ADel(aSI400Del,nPos)
            ASize(aSI400Del,Len(aSI400Del)-1)
         EndIf
      Else
         AAdd(aSI400Del,nRc)  // Inclui na lista de exclus„o
      EndIf
   EndIf
//**

Return(lRet)
*------------------------------------------------------------------------------*
Static Function EICSI400SEEK()
// JBS - 27/12/2004 - Validar a existencia da SI antes de fazer a nova Inclus„o
// O objetivo principal È consistir inclusao simultanea de SI evitando duplicar
*------------------------------------------------------------------------------*
Local nOrdSW0  := SW0->(Indexord())
Local lRetorno := .T.
SW0->(dbSetOrder(1))
If SW0->(dbSeek(xFilial("SW0")+M->W0__CC+M->W0__NUM))
   Help("", 1, "AVG0000683") //   MsgInfo("J· existe outra SI gravada no sistema com este codigo!"+chr(13)+chr(10)+;
                             //            "SI n„o gravada! Altere esta chave e tente novamente.","AtenÁ„o")
   lRetorno := .F.
EndIf
SW0->(dbSetOrder(nOrdSW0))
Return(lRetorno)

*--------------------------*
Static Function ReportDef()
*--------------------------*
Local nInc, nSeq := 1, nTamanho
Local cCampo

Begin Sequence

   //Cria o objeto principal de controle do relatÛrio.
   //Par‚metros:            RelatÛrio ,Titulo ,Pergunte ,CÛdigo de Bloco do Bot„o OK da tela de impress„o.
   aTabelas := {"Work1", "SW3"}

   If Left(cTipo,1) == "2"//ASR 17/10/2006 - Para imprimir todos os itens n„o passar a variavel cCdoI
      oReport := TReport():New("EICSI400",STR0110,"",{|oReport| ReportPrint(oReport, "")},STR0110)
   Else
      oReport := TReport():New("EICSI400",STR0110,"",{|oReport| ReportPrint(oReport, cCodI)},STR0110)
   End If

   oSecao1 := TRSection():New(oReport,"Pedidos de Itens",aTabelas,/*aOrdem*/)


   TRCell():New(oSecao1,"01"        ,     "", AllTrim(STR0113),/*Picture*/, 40        ,/*lPixel*/,{|| If(!lCabec, (TRANS(Work1->W3_FABR,REPL('!',LEN(Work1->W3_FABR)))+' '+Left(Work1->A2_NREDUZ,(nLenReduz-(nLenForn-6)))), cItem) })
   TRCell():New(oSecao1,"W3_PO_NUM" ,"Work1", AllTrim(STR0114),/*Picture*/, 20        ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W2_PO_DT"  ,"Work1", AllTrim(STR0115),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"02"        ,     "", AllTrim(STR0116),cPicQtde   , 15        ,/*lPixel*/   ,{|| IIF(!lCabec,Work1->W3_QTDE,Work1->W1_QTDE) })
   TRCell():New(oSecao1,"03"        ,     "", AllTrim(STR0117),/*Picture*/, 30        ,/*lPixel*/,{|| If(!lCabec, (TRANS(Work1->W2_MOEDA,'!!!')+' '+TRANS((Work1->W3_PR_TOT),_PictPrTot)), STR0123) })//"(Solicitada)"
   TRCell():New(oSecao1,"W3_CC"     ,"Work1", AllTrim(STR0118),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WK_UNI"    ,"Work1", AllTrim(STR0119),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

   AEval(oSecao1:aCell, {|X| X:SetColSpace(3)} )

   //Faz o posicionamento de outros alias para utilizaÁ„o pelo usu·rio na adiÁ„o de novas colunas.
   TRPosition():New(oReport:Section(STR0174),"SW3",1,{|| xFilial("SW3") + Work1->(W3_PO_NUM+W3_CC)}) //STR0174 = "Pedidos de Itens"

End Sequence

Return Nil

*-----------------------------------------*
Static Function ReportPrint(oReport, cCodI)
*-----------------------------------------*
Local cCodItem := "", nCont := 1
Local nRecno := Work1->(Recno())//ASR
Private lCabec := .F., cItem := ""

If !Empty(cCodI)//ASR - !Empty(cCodI)
   Work1->(DbSeek(cCodI))//ASR - Work1->(DbSeek(cCodigoItem))
   Work1->(DbEval({||nCont++},,{||cCodI == W3_COD_I},,,.T.))
   oReport:SetMeter (nCont)
   Work1->(DbSeek(cCodI))//ASR
Else
   oReport:SetMeter (Work1->(EasyRecCount("Work1")))
   Work1->(DbGoTop())//ASR
EndIf

//Work1->(DbSeek(cCodI))//ASR
oSecao1:Init()
While Work1->(!Eof())
   If Empty(cCodI) .Or. cCodI == Work1->W3_COD_I
      If cCodItem <> Work1->W3_COD_I
         If SB1->(DbSeek(xFilial()+Work1->W3_COD_I))
            lCabec := .T.
            AlteraCelulas(.F.)
            cItem := STR0122 + ALLTRIM(Work1->W3_COD_I) + " - " + MSMM(SB1->B1_DESC_P,20,1)
            oSecao1:PrintLine()
            AlteraCelulas(.T.)
            lCabec := .F.
         EndIf
         cCodItem := Work1->W3_COD_I
      EndIf
      oSecao1:PrintLine()
   EndIf
   Work1->(DbSkip())
   oReport:IncMeter()
EndDo
oSecao1:Finish()

Work1->(DbGoTo(nRecno))
Return Nil

*-------------------------------------*
Static Function AlteraCelulas(lVis)
*-------------------------------------*
   oSecao1:Cell("W3_PO_NUM"):lVisible := lVis
   oSecao1:Cell("W2_PO_DT"):lVisible  := lVis
   oSecao1:Cell("W3_CC"):lVisible     := lVis
   oSecao1:Cell("WK_UNI"):lVisible    := lVis
Return Nil


//TRP- 16/02/07 - Adiciona os campos de usu·rio no arquivo tempor·rio
*--------------------------------*
Static Function AddSemSx3(aSemSx3)
*--------------------------------*

   AAdd(aSemSx3, {"RECNO" ,"N", 7                   , 0                   })
   AAdd(aSemSx3, {"SALDO" ,"N",AVSX3("W1_SALDO_Q",3),AVSX3("W1_SALDO_Q",4)})
   AAdd(aSemSx3, {"QTDE"  ,"N",AVSX3("W1_QTDE",3)   ,AVSX3("W1_QTDE",4)   })
   AADD(aSemSx3 ,{"W1_REC_B1","N",10,0})

Return .T.

/*
Autor: Daniel Lima (DRL)
Data: 17/06/09 - 17:30
Objetivo: Habilitar o campo codigo do item na adicao de um novo item na alteracao de SI. Ao tentar adicionar um novo item
          na Alteracao de SI o RECNO nao fica 0 na adicao da primeira linha.
*/
*======================*
Function SI400WhenItem()
*======================*
If oMSSelect:LNEWLINE
   TRB->RECNO := 0
   TRB->W1_REG:= 0
   TRB->W1_SEQ:= 0
EndIf

Return (TRB->RECNO == 0)

/*
Funcao      : SI400Gatilho
Parametros  : cCampo   = refere-se ao campo para a validaÁ„o
Retorno     : cGatilho = texto para o gatilho do campo
Objetivos   : ValidaÁ„o para o gatilho
Autor       : Saimon Vinicius Gava
Revisao     : Jean Victor Rocha - JVR - 11/02/10
Obs.        : Chamada do SX7
*/
*===========================*
Function SI400Gatilho(cCampo)
*===========================*
Local lgatilho := .F.
//Local cGatilho :=""
Local cDescB1
Private cGatilho :=""
Private cCpo:= cCampo
Do Case
   CASE cCampo == "W1_COD_I"
      SB1->(DBSETORDER(1))
      If Type("M->W1_COD_I")!= "U" .And. !Empty(M->W1_COD_I) .AND. SB1->(DBSEEK(XFILIAL("SB1")+M->W1_COD_I))
         lgatilho := .T.
      ElseIf !Empty(SW1->W1_COD_I) .AND. SB1->(DBSEEK(XFILIAL("SB1")+SW1->W1_COD_I))
         lgatilho := .T.
      EndIf

      If lGatilho
         cDescB1 := MSMM(SB1->B1_DESC_P,AVSX3("W1_COD_DES",3))
         cGatilho:= If( !Empty(cDescB1) , cDescB1 , SB1->B1_DESC )
      EndIf

   CASE cCampo == "W1_PRECO"
      SB1->(DBSETORDER(1))
      If Type("M->W1_COD_I")!= "U" .And. !Empty(M->W1_COD_I) .AND. SB1->(DBSEEK(XFILIAL("SB1")+M->W1_COD_I))
         lgatilho := .T.
      ElseIf !Empty(SW1->W1_COD_I) .AND. SB1->(DBSEEK(XFILIAL("SB1")+SW1->W1_COD_I))
         lgatilho := .T.
      EndIf

      If lGatilho //.AND. (EasyGParam("MV_EASY")$cSim)
         cGatilho := 0  //TDF - 07/05/2012 - O gatilho do preÁo ser· feito a partir do campo fabricante (SA5)
      EndIf

   //FDR - 13/01/12 - Gatilho para a GetDb
   CASE cCampo==("W1_FABR")      
       //MFR 15/03/2019 OSSME-2247
       cGatilho := iif(empty(EICRetLoja("TRB","W1_FABLOJ")), AVGatilho(M->W1_FABR,"SA2","1|3"), EICRetLoja("TRB","W1_FABLOJ") )
   //FDR - 13/01/12 - Gatilho para a GetDb
   CASE cCampo==("W1_FORN") //Sequencia 01 do gatilho do campo W1_FORN
        //MFR 15/03/2019 OSSME-2247
       cGatilho :=iif(empty(EICRetLoja("TRB","W1_FORLOJ")), AVGatilho(M->W1_FORN,"SA2","2|3"), EICRetLoja("TRB","W1_FORLOJ") )
   CASE cCampo == "W1_FORN_03" //Sequencia 03 do gatilho do campo W1_FORN
      cGatilho := TRB->W1_PRECO

      If !EMPTY(TRB->W1_FABR)
         SA5->(DBSETORDER(1))

         If SA5->(DBSEEK(XFILIAL("SA5") + M->W1_FORN + TRB->W1_FORLOJ + TRB->W1_COD_I + TRB->W1_FABR + TRB->W1_FABLOJ)) .AND. M->W0_MOEDA == SA5->A5_MOE_US
            cGatilho := SA5->A5_VLCOTUS
         Endif
      EndIf

EndCase

IF(EasyEntryPoint("EICSI400"),Execblock("EICSI400",.F.,.F.,"SI400_GATILHO"),)//Acb - 13/09/2010 - Ponto de entrada para criaÁ„o de gatilho
//SVG - 02/06/2011 -
if cCampo == "W1_PRECO"  .and. !type("cGatilho") =="N"
  cGatilho := Val(cGatilho)
EndIF

Return cGatilho

/*
FunÁ„o:    SI400OrdOpt
Autor:     Caio CÈsar Henrique
Data:      24/07/2009
DescriÁ„o: funÁ„o para criaÁ„o do menu para ordenaÁ„o.
Revis„o:   Jean Victor Rocha - JVR - 11/02/2010
*/
*--------------------------------*
Static Function SI400OrdOpt(oDlg)
*--------------------------------*
Local oMenu

SaveInter()

MENU oMenu POPUP
   MENUITEM STR0175             Action SI400OrdPos("POSICAO") //STR0175 = "Por posiÁ„o"
   MENUITEM STR0176             Action SI400OrdPos("ITEM")    //STR0176 = "Por CÛdigo Item"
   MENUITEM STR0177             Action oMenu:End()           //STR0177 = "cancelar"
ENDMENU

//If lComEdit    // GFP - 18/01/2013
   If SetMDIChild()
      oMenu:Activate(oMainWnd:nRight-235,oMainWnd:nBottom-103,oMainWnd) //oMenu:Activate(250,70,oMainWnd)
   Else
      oMenu:Activate(oMainWnd:nRight-390,803-oMainWnd:nBottom,oMainWnd)//oMenu:Activate(95,150,oMainWnd)
   EndIf
/*Else
   If SetMDIChild()
      oMenu:Activate(370,70,oMainWnd)
   Else
      oMenu:Activate(190,150,oMainWnd)
   EndIf
EndIf
*/
RestInter()

Return Nil

/*
FunÁ„o:    SI400OrdPos
Autor:     Caio CÈsar Henrique
Data:      24/07/2009
DescriÁ„o: FunÁ„o de ordenaÁ„o dos itens na tela Usado no bot„o "Ordena Itens"
Revis„o:   Jean Victor Rocha - JVR - 11/02/2010
*/
*--------------------------------*
Static Function SI400OrdPos(cTipo)
*--------------------------------*

Do Case
   Case cTipo == "POSICAO"
      TRB->(dbSetOrder(1))

   Case cTipo == "ITEM"
      TRB->(dbSetOrder(2))

End Case

oMainWnd:Refresh()
oMSSelect:oBrowse:Refresh()

Return .T.

/*
FunÁ„o:    SI400NumPoItem()
Autor:     Caio CÈsar Henrique
Data:      30/07/2009
DescriÁ„o: FunÁ„o para preenchimento do W1_POSIT quando for MsMget
Revis„o:   Jean Victor Rocha - JVR - 11/02/2010
*/
*------------------------*
Function SI400NumPoItem()
*------------------------*
Local aOrd := SaveOrd("TRB")
Local nPosIt := 0
local lTemVazio := .F., lGrvNum := .F.

   TRB->(DbSetOrder(0))
   TRB->(DbGoTop())
   Do While TRB->(!Eof())
      If (Val(TRB->W1_POSIT) > nPosit) .And. !Empty(TRB->W1_COD_I)//Verifica se o cod. do item est· preenchido pois o registro
         nPosit := Val(TRB->W1_POSIT)                             //pode ser "Lixo" da getdb

      ElseIf Empty(TRB->W1_POSIT) .And. !Empty(TRB->W1_COD_I) //JVR - 11/02/10
         lTemVazio := .T.

      EndIf

      TRB->(DbSkip())
   End Do

   //JVR - 11/02/10 - criaÁ„o da numeraÁ„o para itens antigos ou que n„o tenham numeraÁ„o de posiÁ„o.
   If lTemVazio
      If MSGYESNO(STR0178 + ENTER + ; //STR0178 = "Existe Itens com a posiÁ„o do item n„o preenchida."
                  STR0179)           //str0179 = "Deseja que o sistema crie uma numeraÁ„o automaticamente para estes Itens?

         TRB->(DbGoTop())
         Do While TRB->(!Eof())
            If Empty(TRB->W1_POSIT)
               TRB->(RecLock("TRB",.F.))
               TRB->W1_POSIT := StrZero((nPosIt + 1),4,0)
               nPosIt ++
               TRB->(MsUnLock())
               lGrvNum := .T.
            EndIf
            TRB->(DbSkip())
         EndDo
      EndIf
   EndIf

RestOrd(aOrd,.T.)

IF !lGrvNum
   nPosIt++
EndIf

Return StrZero(nPosIt,4,0)

/*
FunÁ„o    : SIAutoItens()
Objetivos : Definir qual aÁ„o para cada item (Inclusao/Alteracao/Exclusao)
Parametros: aCabItem - Item
Retorno   : lRet
Autor     : Thiago Rinaldi Pinto
Revis„o   :
Data      : 18/05/2011
*/
*------------------------------------*
Static Function SIAutoItens(aCabItem)
*------------------------------------*
Local aItensInc := {}
Local aItensAlt := {}
Local aItensDel := {}
Local i
Local lRet := .T.

For i := 1 TO Len(aCabItem)
   If (nOpcAuto == 4 .OR. nOpcAuto == 5) .AND. EasySeekAuto("TRB", aCabItem[i], 2)
      If (nPOsDelA := aScan(aCabItem[i], {|x| x[1] == "AUTDELETA" .AND. x[2] == "S" })) > 0
         aAdd(aItensDel,aCabItem[i])
      Else
         aAdd(aItensAlt,aCabItem[i])
      EndIf
   Else
      If (nPOsDelA := aScan(aCabItem[i], {|x| x[1] == "AUTDELETA" .AND. x[2] == "S" })) == 0
         aAdd(aItensInc,aCabItem[i])
      EndIf
   Endif
Next i
If Len(aItensInc) > 0
   Private nLinSIAuto := 1
   lRet := MsGetDBAuto("TRB",aItensInc,,{|| TRB->(DbGoTop()),AtuRegAuto(aItensInc,nLinSIAuto), nLinSIAuto++, U_EILinok() .AND. SI400Check(lKit) .AND. IF(lIntLogix,ELD400Valid(),.T.)},aCabAuto,nOpcAuto) .AND. lRet
EndIf

If Len(aItensAlt) > 0
   For i := 1 To Len(aItensAlt)
      If EasySeekAuto("TRB", aItensAlt[i], 2)
         lRet := AltItemAuto(aItensAlt[i],nOpcAuto) .AND. IF(lIntLogix,ELD400Valid(),.T.) .AND. lRet
      Endif
   Next i
EndIf

If Len(aItensDel) > 0
   For i := 1 To Len(aItensDel)
      If EasySeekAuto("TRB", aItensDel[i], 2)
         If U_SI400ApagaReg()
            TRB->(dbDelete())
         Else
            lRet := .F.
         EndIf
      Endif
   Next i
EndIf

Return lRet

/*
FunÁ„o    : AltItemAuto()
Objetivos : Alterar um item na MsGetDB quando ExecAuto
Parametros: aItem - Item
            nOpcAuto
Retorno   : .T./.F.
Autor     : Thiago Rinaldi Pinto
Revis„o   :
Data      : 18/05/2011
*/
*------------------------------------------*
Static Function AltItemAuto(aItem,nOpcAuto)
*------------------------------------------*
RegToMemory("TRB",.F.,.F.,.F.)
//IGOR CHIBA 18/06/14 CAMPO NOVO ENVIADO PELA ROTINA AUTOMATICA DE ADAPTER
IF  Type("lSIAuto") <> 'U' .AND. lSIAuto .AND. (nPos:=ASCAN(aCabItem[1],{|x| x[1]=='W1_COMPLEM' })) <> 0  .AND. SW1->(FIELDPOS('W1_COMPLEM')) <> 0
   TRB->W1_COMPLEM := aCabItem[1][nPos][2]
ENDIF
Return EnchAuto("SW1",aItem,{|| AvReplace("M","TRB"), U_EILinok(),IF(lIntLogix,ELD400Valid(),.T.)},nOpcAuto)

/*
FunÁ„o    : AtuRegAuto()
Objetivos : Assumi o Reg informado no ExecAuto
Parametros: aItensInc - Itens a serem inclusos
            nLinSIAuto - Numeracao do Reg
Retorno   : .T./.F.
Autor     : Thiago Rinaldi Pinto
Revis„o   :
Data      : 18/05/2011
*/
*-----------------------------------------------*
Static Function AtuRegAuto(aItensInc,nLinSIAuto)
*-----------------------------------------------*
Local nPosReg

If Len(aItensInc) >= nLinSIAuto .AND. (nPosReg := aScan(aItensInc[nLinSIAuto],{|X| X[1] == "W1_REG"})) > 0
   TRB->W1_REG := aItensInc[nLinSIAuto][nPosReg][2]
EndIf
//IGOR CHIBA 18/06/14 CAMPO NOVO ENVIADO PELA ROTINA AUTOMATICA DE ADAPTER
IF  Type("lSIAuto") <> 'U' .AND. lSIAuto
   If (nPos:=ASCAN(aCabItem[1],{|x| x[1]=='W1_COMPLEM' })) <> 0  .AND. SW1->(FIELDPOS('W1_COMPLEM')) <> 0
      TRB->W1_COMPLEM := aCabItem[1][nPos][2]
   EndIf
   If (nPos:=ASCAN(aCabItem[1],{|x| x[1]=='W1_C3_NUM' })) <> 0  .AND. SW1->(FIELDPOS('W1_C3_NUM')) <> 0
      TRB->W1_C3_NUM := aCabItem[1][nPos][2]
   EndIf
   If (nPos:=ASCAN(aCabItem[1],{|x| x[1]=='W1_FORN' })) <> 0  .AND. SW1->(FIELDPOS('W1_FORN')) <> 0
      TRB->W1_FORN := aCabItem[1][nPos][2]
   EndIf
   If (nPos:=ASCAN(aCabItem[1],{|x| x[1]=='W1_FORLOJ' })) <> 0  .AND. SW1->(FIELDPOS('W1_FORLOJ')) <> 0
      TRB->W1_FORLOJ := aCabItem[1][nPos][2]
   EndIf
   If (nPos:=ASCAN(aCabItem[1],{|x| x[1]=='W1_CONDPG' })) <> 0  .AND. SW1->(FIELDPOS('W1_CONDPG')) <> 0
      TRB->W1_CONDPG := aCabItem[1][nPos][2]
   EndIf
ENDIF
Return Nil

/*
FunÁ„o    : SI400RELSI()
Objetivos :
Parametros:
Retorno   :
Autor     : Tamires Daglio Ferreira
Revis„o   :
Data      : 23/02/2012
*/
*-----------------------------------------------*
Static Function SI400RELSI()
*-----------------------------------------------*
Local lRet := .T.
Local cDir := "\Comex\"
Local cFile:= "RELSI.xrp"  // GFP - 20/12/2013  //AllTrim(CriaTrab(,.F.))+".xrp"
Private cFiltro

dbSelectArea("SW0")
SW0->(DBGOTO(nRecno))

//FDR - 06/10/2012 - Adicionado o campo WO__CC para a chave do filtro
cFiltro:= SW0->(xFilial("SW0")+W0__CC+W0__NUM)
SET FILTER TO SW0->W0_FILIAL+W0__CC+SW0->W0__NUM == cFiltro

Begin Sequence

   If !lIsDir(cDir) .And. !(MakeDir(cDir) == 0)
      MsgInfo(StrTran("Erro ao criar o diretÛrio tempor·rio '###'. N„o ser· possÌvel executar o relatÛrio.", "###", cDir), "AtenÁ„o")
      lRet := .F.
      Break
   EndIf

   If File(cDir+cFile)  // GFP - 20/12/2013
      FErase(cDir+cFile)
   EndIf

   If !MemoWrite(cDir+cFile, H_RELSI())
      MsgInfo("Erro de Abertura do arquivo.")
      lRet := .F.
      Break
   EndIf

   LoadReport(cDir+cFile)
   FErase(cDir+cFile)
   dbSelectArea("SW0")
   SET FILTER TO

End Sequence

Return lRet

/*
Funcao    : FormRelSI
Descric„o : Tratamento especifico de campos do RelatÛrio de SI
Autor     : Guilherme Fernandes Pilan - GFP
Data      : 23/08/04
Parametros: cCampo
Retorna   : xConteudo - Valor calculado
*/
Function FormRelSI(cCampo)

//Local lRet
Local xConteudo

Do Case
   Case cCampo == "PRCTOTAL"      // Campo Totalizador de Itens do RelatÛrio.
      If Select("SW1") > 0
         xConteudo := SW1->W1_QTDE * SW1->W1_PRECO
      Else
         xConteudo := 0
      EndIf
End Case

Return xConteudo

/*
FunÁ„o    : SI400Sair()
Objetivos : Perguntar se deseja realemten sair ao clicar no bot„o cancelar.
Retorno   : .T./.F.
Autor     : Tamires Daglio Ferreira
Data      : 09/11/2012
*/
*-----------------------------*
Static Function SI400Sair()
*-----------------------------*
Private lSair := .T.

IF(EasyEntryPoint("EICSI400"),Execblock("EICSI400",.F.,.F.,"SI400SAIR"),)
If !lSair
   Return .F.
EndIf

Return MSGYesNo(STR0186,STR0061)


/*
FunÁ„o    : ELDAutoItens()
Objetivos : Rotina executada apenas quando for MSExecAuto e IntegraÁ„o com o Logix
Autor     : Jacomo Abenathar Fernandes Lisa
Data      : 13/05/2014
*/

*-----------------------------*
Static Function ELDAutoItens(aCabELD)
*-----------------------------*
LOCAL nI,nII,cID:=""
LOCAL aID_ELD := {}
IF ValType(aCabELD) # "A" .OR. len(aCabELD) == 0
  RETURN .F.
ENDIF
If(Select("ELD") == 0,ChkFile("ELD"),)
ELD->(DBSETORDER(1))//ELD_FILIAL+ELD_CC+ELD_SI_NUM+ELD_PRGENT

FOR nI := 1 to len(aCabELD)
    IF (nPosChave := ascan(aCabELD[nI], {|x| Alltrim(x[1]) == "ELD_PRGENT"}) ) > 0
       cID := aCabELD[nI][nPosChave][2]
       IF (!ELD->(DBSEEK(xFilial("ELD")+SW0->W0__CC+SW0->W0__NUM+cID )))
          ELD->(RECLOCK("ELD",.T.))
       ELSE
          ELD->(RECLOCK("ELD",.F.))
       ENDIF

       ELD->ELD_FILIAL := xFilial("ELD")
       FOR nII := 1 TO LEN(aCabELD[nI])
           cCampo := aCabELD[nI][nII][1]
           xDados := aCabELD[nI][nII][2]
           ELD->(&(cCampo)) := xDados
       NEXT

       ELD->(MSUNLOCK())
       IF ascan(aID_ELD,cID) == 0
          AADD(aID_ELD,cID)
       ENDIF
    ELSE
       LOOP
    ENDIF
NEXT

ELD->(DBSEEK(xFilial("ELD")+SW0->W0__CC+SW0->W0__NUM))
DO WHILE ELD->(!EOF()) .AND. ;
         ELD->ELD_FILIAL == xFilial("ELD") .AND. ;
         ELD->ELD_CC     == SW0->W0__CC .AND. ;
         ELD->ELD_SI_NUM == SW0->W0__NUM
   IF (ascan(aID_ELD,ELD->ELD_PRGENT)) == 0
      ELD->(RECLOCK("ELD",.F.))
      ELD->(DBDELETE())
      ELD->(MSUNLOCK())
   ENDIF
   ELD->(DBSKIP())
ENDDO

RETURN .T.

/*
FunÁ„o    : ELD400Valid()
Objetivos : Rotina executada apenas quando for MSExecAuto e IntegraÁ„o com o Logix
Autor     : Jacomo Abenathar Fernandes Lisa
Data      : 13/05/2014
*/
*-----------------------------*
Static Function ELD400Valid()
*-----------------------------*
LOCAL nI,nQtdSoli := 0
LOCAL cID := ""
LOCAL lRet := .T.
Local nPos

IF TRB->(EOF()) .AND. TRB->(BOF())
   EasyHelp("Nenhum item informado","Atencao!!")
   RETURN .F.
ENDIF
If ValType(aCabELD) # "A" .OR. len(aCabELD) == 0
   RETURN .T.
EndIf
FOR nI := 1 to len(aCabELD)
    IF (nPosQTD := ascan(aCabELD[nI], {|x| Alltrim(x[1]) == "ELD_QTSOLI"}) ) > 0
       nQtdSoli += aCabELD[nI][nPosQTD][2]
    ELSE
       LOOP
    ENDIF
NEXT

TRB->(DBGOTOP())

//WFS - quantidade do item x quantidade da programaÁ„o de entregas
nPos:= 0
If nOpcAuto == 3 //Inclus„o
    nPos:= AScan(aCabItem[1], {|x| x[1] == "W1_QTDE"})
ElseIf nOpcAuto == 4 //AlteraÁ„o
    nPos:= AScan(aCabItem[1], {|x| x[1] == "W1_SALDO_Q"})
EndIf

//IF TRB->W1_QTDE # nQtdSoli
If nPos > 0 .And. aCabItem[1][nPos][2] <> nQtdSoli
   //EasyHelp("Quantidade total diferente da SI","Atencao!!")
   EasyHelp("A soma das quantidades da programaÁ„o de entregas diverge da quantidade da Ordem/ SolicitaÁ„o de ImportaÁ„o. Favor verificar.","AtenÁ„o!") //wfs 08/08/2014
   lRet := .F.
ENDIF

IF nOpcAuto == 4
   IF SW1->W1_STATUS == "F" .AND. SW1->W1_QTDE # nQtdSoli
      EasyHelp("A Solicitacao de Importacao n„o pode ser atualizada com novos dados da Ordem de Compra"+chr(13)+chr(10)+;
               "Pois o processo encontra-se em fase subsequente"+chr(13)+chr(10)+;
               "Status Atual: "+GetW1Status(),"Atencao!!")
      RETURN .F.
   ELSEIF SW1->W1_STATUS == "F" .AND. SW1->W1_QTDE == nQtdSoli
      lAltSYS := .T.
   ENDIF
ENDIF

RETURN lRet
//TRB->(DBSEEK(cSI_NUM))

/*
FunÁ„o    : ELD400Valid()
Objetivos : Rotina executada apenas quando for MSExecAuto e IntegraÁ„o com o Logix
Autor     : Jacomo Abenathar Fernandes Lisa
Data      : 13/05/2014
*/
*-----------------------------*
Static Function SetW1Status()
*-----------------------------*
LOCAL cStatus := ""
SWS->(DBSETORDER(2))//WS_FILIAL+WS__CC+WS_SI_NUM+WS_COD_I
SW3->(DBSETORDER(4))//W3_FILIAL+W3_CC+W3_SI_NUM
IF (INCLUI .AND. Empty(SW1->W1_C3_NUM)) .OR. (!SWS->(DBSEEK(xFilial("SWS")+SW0->W0__CC+SW0->W0__NUM+TRB->W1_COD_I)) .AND. Empty(SW1->W1_C3_NUM))
   cStatus := "A"
ELSEIF EMPTY(SW1->W1_NR_CONC) .AND. Empty(SW1->W1_C3_NUM)
   cStatus := "B"
ELSEIF EMPTY(SW1->W1_NR_CONC) .AND. !Empty(SW1->W1_C3_NUM) .AND. !SW3->(DbSeek(xFilial("SW3")+SW1->W1_CC+SW1->W1_SI_NUM))
   cStatus := "G"
ELSE
   cStatus := "D"
ENDIF

RETURN cStatus

/*
FunÁ„o    : SYSAutoItens(aCabSYS)
Objetivos : Rotina executada apenas quando for MSExecAuto e IntegraÁ„o com o Logix
Autor     : Jacomo Abenathar Fernandes Lisa
Data      : 27/05/2014
*/
*--------------------------------------*
Static Function SYSAutoItens(aCabSYS)
*--------------------------------------*
LOCAL nI,nII
SYS->(DBSETORDER(1))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_FORLOJ+YS_MOEDA+YS_INVOICE+YS_CC

IF ValType(aCabSYS) # "A"
  RETURN .F.
ENDIF

IF (SYS->(DBSEEK(xFilial("SYS")+"I"+"S"+AVKEY(SW1->W1_SI_NUM,"YS_HAWB")))) .OR. len(aCabSYS) == 0
   DO WHILE SYS->(!EOF()) .AND. SYS->YS_FILIAL == xFilial("SYS") .AND. SYS->YS_HAWB == AVKEY(SW1->W1_SI_NUM,"YS_HAWB") .AND.;
            SYS->YS_TPMODU == "I" .AND. SYS->YS_TIPO =="S"
      SYS->(RECLOCK("SYS",.F.))
      SYS->(DBDELETE())
      SYS->(MSUNLOCK())
      SYS->(DBSKIP())
   ENDDO
ENDIF

IF LEN(aCabSYS) > 0
   FOR nI := 1 to len(aCabSYS)
       SYS->(RECLOCK("SYS",.T.))
       SYS->YS_FILIAL := xFilial("SYS")
       SYS->YS_TPMODU := "I"
       SYS->YS_TIPO   := "S"
       SYS->YS_HAWB   := AVKEY(SW1->W1_SI_NUM,"YS_HAWB")
       FOR nII := 1 TO LEN(aCabSYS[nI])
           cCampo := aCabSYS[nI][nII][1]
           xDados := aCabSYS[nI][nII][2]
           SYS->(&(cCampo)) := xDados
       NEXT
       SYS->(MSUNLOCK())
   NEXT
ENDIF



RETURN .T.
/*
FunÁ„o    : ELD400Exc()
Objetivos : Rotina executada apenas quando for MSExecAuto e IntegraÁ„o com o Logix
Autor     : Jacomo Abenathar Fernandes Lisa
Data      : 27/05/2014
*/
*-----------------------------*
Static Function ELD400Exc()
*-----------------------------*
ELD->(DBSETORDER(1))
SYS->(DBSETORDER(1))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_FORLOJ+YS_MOEDA+YS_INVOICE+YS_CC
IF ELD->(DBSEEK(xFilial("ELD")+SW0->W0__CC+SW0->W0__NUM))
   DO WHILE ELD->(!EOF()) .AND. ELD->ELD_FILIAL == xFilial("ELD") .AND. ;
            ELD->ELD_CC == SW1->W1_CC .AND. ELD->ELD_SI_NUM == SW1->W1_SI_NUM
      ELD->(RECLOCK("ELD",.F.))
      ELD->(DBDELETE())
      ELD->(MSUNLOCK())
      ELD->(DBSKIP())
   ENDDO
ENDIF
IF SYS->(DBSEEK(xFilial("SYS")+"I"+"S"+AVKEY(SW1->W1_SI_NUM,"YS_HAWB")))
   DO WHILE SYS->(!EOF()) .AND. SYS->YS_FILIAL == xFilial("SYS") .AND. SYS->YS_HAWB == AVKEY(SW1->W1_SI_NUM,"YS_HAWB") .AND.;
            SYS->YS_TPMODU == "I" .AND. SYS->YS_TIPO =="S"
      SYS->(RECLOCK("SYS",.F.))
      SYS->(DBDELETE())
      SYS->(MSUNLOCK())
      SYS->(DBSKIP())
   ENDDO
ENDIF
RETURN .T.
/*
FunÁ„o    : GetW1Status()
Objetivos : Rotina executada apenas quando for MSExecAuto e IntegraÁ„o com o Logix
Autor     : Jacomo Abenathar Fernandes Lisa
Data      : 27/05/2014
*/
*-----------------------------*
Static Function GetW1Status()
*-----------------------------*
LOCAL cRet := ""
IF SW1->W1_STATUS=='A'
   cRet := STR0189//"A-Pendente"
ELSEIF SW1->W1_STATUS=='B'
   cRet := STR0190//"B-Em processo de cotacao"
ELSEIF SW1->W1_STATUS=='C'
   cRet := STR0191//"C-Cotado no mercado nacional"
ELSEIF SW1->W1_STATUS=='D'
   cRet := STR0192//"D-Aguardando Purchase Order"
ELSEIF SW1->W1_STATUS=='E'
   cRet := STR0193//"E-Cancelado"
ELSEIF SW1->W1_STATUS=='F'
   cRet := STR0194//"F-Atendida - em fase de Purchase Order"
ELSEIF SW1->W1_STATUS=='G'
   cRet := STR0203//"G-Pendente - Contrato"
ENDIF

Return cRet

/*
Funcao     : SaveTempFiles
Parametros :
Retorno    : LÛgico
Objetivos  : Verificar se est· ativo o controle de reaproveitamento de arquivos tempor·rios - EECCRIATRAB
             Possibilitar centralizar em um ˙nico ponto as verificaÁıes destas condiÁıes.
             Inicialmente o ˙nico cen·rio para a S.I. È a integraÁ„o EAI ou ponto de entrada, que altera a vari·vel __KeepUsrFiles.
Autor      : wfs
Data/Hora  : mar/2017
*/
Static Function SaveTempFiles()
Static lSaveTempFiles

Begin Sequence

   If ValType(lSaveTempFiles) == "U"

      If Type("__KeepUsrFiles") <> "L"
         __KeepUsrFiles:= AvFlags("EIC_EAI")
      EndIf

      lSaveTempFiles:= __KeepUsrFiles
   EndIf


End Sequence

Return lSaveTempFiles


*----------------------------------------*
Static Function GetRecSB1(cCodI,lRestOrd)
*----------------------------------------*
Local nRecno  := 0
Local aOrdSB1 
Default lRestOrd := .F.

   If SB1->(!Eof()) .And. SB1->B1_COD == cCodI
      nRecno := SB1->(Recno())
   Else
      If lRestOrd
         aOrdSB1 := SaveOrd("SB1")
      EndIf
      SB1->(DbSetORder(1))
      If SB1->(DbSeek(xFilial("SB1")+cCodI))
         nRecno := SB1->(Recno())
      EndIf
      If lRestOrd 
         RestOrd(aOrdSB1,.T.)
      EndIf
   EndIf

Return nRecno
