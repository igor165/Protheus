#include "EDCAC400.ch"
#include "Average.ch"
#INCLUDE "TOPCONN.CH"

#define VISUALIZAR 2
#define INCLUIR    3
#define ALTERAR    4
#define ESTORNAR   5

#define GENERICO    "06"
#define DOLAR       "US$"
#define NCMGENERICA "99999999"
#define KILOGRAMA   "KG"

#define TAMDESC     40
#define TAMDESCLI   48
#define TAMDESCEXP  60
#define TAMDESCPED  68

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)

#define SUSPENSAO "1"
#define ISENCAO   "2"
/*
Programa        : EDCAC400.PRW
Objetivo        : Manutenção do Ato Concessório
Autor           : Gustavo Carreiro
Data/Hora       :
Obs.            :
*/
/*
Revisão         : Inclusão de Multi-Filial no Drawback
Objetivo        : Permitir utilização de Produtos Exportados e/ou Itens Importados em qualquer Filial
Autor           : Pedro Baroni
Data/Hora       : 22/06/2007
*/
*-----------------*
Function EDCAC400()
*-----------------*
Local nOrdSX3 := SX3->(IndexOrd())

SX3->(DBSETORDER(2))
if .not. SX3->(DBSeek("ED2_RE"))  .or. .not. SX3->(DBSeek("ED5_TIPO")) // ACSJ - 18/11/2004
   MsgInfo( STR0411 + Chr(13) +;//"Existem atualizacöes a serem realizadas no DrawBack"
            STR0412)//
   Return .t.
Endif

If !AvFlags("INDICEED9")
   Return .F.
EndIf

Private aTabelas:={}, aBotoes:={}, aBotoes2:={}, aBotoes3:={}, aBotoes4:={}, aBotoes5:= {}, lVolta:=.F., lVolta1 := .F.
Private cCadastro := STR0001, aBotEDB:= {}, aBotRes:={}, aBotRes2:={} //"Manutencao de Ato Concessorio "
Private cFilED1:=xFilial("ED1"), cFilED2:=xFilial("ED2"), cFilSYT:=xFilial("SYT")
Private cFilSB1:=xFilial("SB1"), cFilSYD:=xFilial("SYD"), cFilSG1:=xFilial("SG1")
Private cFilEE9:=xFilial("EE9"), cFilSW7:=xFilial("SW7"), cFilSW6:=xFilial("SW6")
Private cFilSW9:=xFilial("SW9"), cFilSW8:=xFilial("SW8"), cFilSY6:=xFilial("SY6")
Private cFilSW2:=xFilial("SW2"), cFilSA2:=xFilial("SA2"), cFilSJ5:=xFilial("SJ5")
Private cFilSW5:=xFilial("SW5"), cFilEEC:=xFilial("EEC"), cFilED0:=xFilial("ED0")
Private cFilSA5:=xFilial("SA5"), cFilED3:=xFilial("ED3"), cFilED4:=xFilial("ED4")
Private cFilED6:=xFilial("ED6"), cFilSX5:=xFilial("SX5"), cFilED8:=xFilial("ED8")
Private cFilED9:=xFilial("ED9"), cFilED5:=xFilial("ED5"), cFilEDA:=xFilial("EDA")
Private cFilEE2:=xFilial("EE2"), cFilSWN:=xFilial("SWN"), cFilEDB:=xFilial("EDB")
Private cFilEDC:=xFilial("EDC"), cFilEDF:=xFilial("EDF")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private nSeq:=1, nLiga:=1, FileWork12, aGuardaAne:= {}
Private cMarca := GetMark(), lInverte := .F., lIncluiAux:=.F., nEstru:=0 //Usado na Função Estrut2
Private nLenSeqED1:=Len(ED1->ED1_SEQ)
Private lAbriuExp := .F.
Private aSelCpos:={}, aSelCpos2:={}, aSelCpos3:={}, aSelCpos4:={} , aSelCpos4A := {}//AOM 09/11/2011 - array para saldo das compras nacionais
Private aSelCpos5:={}, aSelCpos6:={}, aSelCpos7:={}, aSelCpos8:={}
Private aSelCpos9:={}, aSelCpos10:={}, aSelCpos11:={}
Private aSelCpos12 := {} //AOM - 28/10/10
Private lTop := .F., cFilSA2Aux:=cFilSA2, aTaxas:={}, aTelaSis:= {}
Private lAbriuEDA := SX3->(dbSeek("EDA_FILIAL"))
Private lAbriuEDB := SX3->(dbSeek("EDB_FILIAL"))
Private lAbriuEDC := SX3->(dbSeek("EDC_FILIAL"))
// A. Caetano - ACSJ - 04/03/2004
// Verifica se os campos ED1_COEF e ED2_COEF existem no dicionario.
Private lED1Coef  := SX3->(DBSeek("ED1_COEFEC"))
Private lED2Coef  := SX3->(DBSeek("ED2_COEFEC"))
// A. Caetano - ACSJ - 17/11/2004
Private lED1Umanex   := SX3->(DBSeek("ED1_UMANEX"))
Private lED2Umanex   := SX3->(DBSeek("ED2_UMANEX"))
Private lED2Dt_Nf    := SX3->(DBSeek("ED2_DT_NF"))
Private lED2Inat     := SX3->(DBSeek("ED2_INAT"))
Private lED2Percap   := SX3->(DBSeek("ED2_PERCAP"))
Private lED5De       := .T.
Private lED5Para     := .T.
Private lAgrpSld     := ED0->(FieldPos("ED0_AGRSLD")) # 0
Private l010Auto   := .F. //AAF 14/08/2006 - Para funcionamento do botão incluir no F3 do SB1.
Private lCopia     := .F. //AAF 14/08/2006 - Para funcionamento do botão incluir no F3 do SB1.
Private aRotina := MenuDef()
Private lIndPercAg := ED3->(dbSetOrder(1),"ED3_PERCAG" $ IndexKey())

lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE01")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE02")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE03")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE04")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE05")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE06")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE07")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE08")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE09")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE10")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE11")),  .f.)
lED5De   := iif(lED5De,  SX3->(DBSeek("ED5_DE12")),  .f.)

lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA01")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA02")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA03")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA04")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA05")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA06")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA07")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA08")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA09")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA10")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA11")),.f.)
lED5Para := iif(lED5Para,SX3->(DBSeek("ED5_PARA12")),.f.)


Private lMultiFil:= AC400MultiFil()  // WFS 20/12/2013
//-------------------------------------------------------------
// igor chiba 08/04/09    lReExt campos usados se cliente tiver manutenção de RE externo

lReExt:=.F.

IF ED9->(FieldPOs('ED9_DTAVRB')) > 0 .AND. ED9->(FieldPOs('ED9_UMNCM' )) > 0 .AND. ;
   ED9->(FieldPOs('ED9_SALISE')) > 0 .AND. ED9->(FieldPOs('ED9_ISENTO')) > 0 .AND. ;
   ED9->(FieldPOs('ED9_FASEDR')) > 0

   lReExt   := .T.
ENDIF

// Fim igor chiba 08/04/09
SX3->(DBSETORDER(nOrdSX3))

Private lLeadTime := SB1->(FieldPos("B1_LEADTI")) > 0 .AND. EDC->(FieldPos("EDC_LEADTI")) > 0 .and.;
                     SB1->(FieldPos("B1_PRODUC")) > 0 .AND. EDC->(FieldPos("EDC_PRODUC")) > 0 .and.;
                     EasyGParam("MV_AVG0184",.F.,.F.)

#IFDEF TOP
   lTop := .T.
#ENDIF

Private lTemVLCOMPE := ED2->( FieldPos("ED2_VLCOPE") ) > 0 .AND. SG1->( FieldPos("G1_VLCOMPE") ) > 0//AAF 31/05/05

Private lTipoItem := ED7->( FieldPos("ED7_TPITEM") ) > 0  .And.  ED7->( FieldPos("ED7_PD") ) > 0  // PLB 09/11/06

Private lSegInc := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 // EOB - 13/06/08 - Inclusão do tratamento de incoterm com seguro

SX3->(DBSETORDER(nOrdSX3))

If ( EasyGParam("MV_AVG0024",,"") != SM0->M0_CODFIL .Or. Empty( EasyGParam("MV_AVG0024",,"") ) )
   If AmIin(50)
      If Select("SB1EXP") = 0
         lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
      Else
         lAbriuExp := .T.
      Endif
      If lAbriuExp
         cAliasSB1  := "SB1EXP"
         cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
         If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
      Endif

      Private lAbriuSA2 := AbreArqExp("SA2",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))),cFilSA2Aux) // Abre arq. SA2 de outra Empresa/Filial de acordo com os parametros.
      If lAbriuSA2
         cFilSA2Aux   := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
         If(Empty(Alltrim(cFilSA2Aux)),cFilSA2Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
      Endif

      Processa({|| IniCpos(1)}  ,STR0008) //"Inicializando Ambiente"
      Processa({|| AC400Works()},STR0008) //"Inicializando Ambiente"

      ED0->(dbSetOrder(1))
      mBrowse(,,,,"ED0")

      AC400DelWorks()
      If lAbriuSA2
         FechaArqExp("SA2",.T.)
      Endif
   EndIf
Else
   MsgStop("O módulo de Drawback não pode ser utilizado na filial de Off-Shore.")
EndIf

Return .T.


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 17/01/07 - 13:31
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := {}

   aAdd(aRotina,{ STR0002      ,"AxPesqui"  ,0,1})//"Pesquisar"
   aAdd(aRotina,{ STR0003      ,"AC400Manut",0,2})//"Visualizar"
   aAdd(aRotina,{ STR0004      ,"AC400Modal",0,3})//"Incluir"
   aAdd(aRotina,{ STR0005      ,"AC400Manut",0,4})//"Alterar"
   aAdd(aRotina,{ STR0006      ,"AC400Est"  ,0,5})//"Excluir"
   aAdd(aRotina,{ AC401STR(001),"AC400CHist",0,6})//"Histórico"
   aAdd(aRotina,{ STR0007      ,"AC400Copia",0,7})//"Copiar Ato"

If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"MBROWSE"),)

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("DAC400MNU")
	aRotAdic := ExecBlock("DAC400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina


*-----------------------------------*
Function AC400Manut(cAlias,nReg,nOpc)
*-----------------------------------*
Local oDlgA, bOk := {||nOpcao:=1,oDlgA:End()},i
Local nInd, nOpcao:=0, bCancel := {||nOpcao:=0,oDlgA:End()}

Local aNomeFolders  := {} , aNmFldED2 := {} ,  aNmFldED4 := {} //AOM - 09/11/2011
Local aAbrevFolders := {} , aAbFldED2 := {} ,  aAbFldED4 := {} //AOM - 09/11/2011
Local COLUNA_FINAL
Local nFld := 1 , lVldCNPJ,aFolder := {}, aOpc := {}  //AOM - 27/10/10

Local bHide    := {|nTela| If(nTela==aFolder[1],oMark6:oBrowse:Hide(),;
                           If(nTela==aFolder[2],oMark :oBrowse:Hide(),;
                           If(nTela==aFolder[3],/*oMark3:oBrowse:Hide()*/AtuaWKED2ED4(1,,,.F.),;//AOM - 09/11/11
                           If( nTela==aFolder[4],oMark2:oBrowse:Hide(),;
                           If(nTela==aFolder[5],AtuaWKED2ED4(2,,,.F.)/*oMark4:oBrowse:Hide()*/,;//AOM - 09/11/11
                           If(nOpc <> INCLUIR .And. nTela==aFolder[7],oMark8:oBrowse:Hide(),;//AOM - 29/10/10
                           If(nTela==aFolder[8],oMark7:oBrowse:Hide(),))))))) }

                           //If(nTela==aFolder[5],oMark5:oBrowse:Hide(),);

Local bBarras := {||AC400Bar(oFldAC , {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},,If(nOpc=INCLUIR, If(Left(cModal,1)<>"2", Aadd(aTelaSis,{{"NOTE" /*"EDITABLE"*/,{|| FolderSetFocus(oFld, oFldAC), ViewDesc("ED0")},STR0145,""}}), aTelaSis:= {} ), If(M->ED0_MODAL<>"2", Aadd(aTelaSis,{{"NOTE",{|| FolderSetFocus(oFld, oFldAC), ViewDesc("ED0")},STR0145,""}}), aTelaSis:= {} ))),; //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas." # "Retorno do SISCOMEX" //$$ Retorno  // ACSJ - 30/04/2004
                    If(lVldCNPJ,AC400Bar(oFldAC2, {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))}),),; //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas."
                    AC400Bar(oFldED1, {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},,aBotoes),; //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas."
                    AC400Bar(oFldED2, {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},,aBotoes2),; //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas."
                    AC400Bar(oFldED3, {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},,aBotoes4),; //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas."
                    AC400Bar(oFldED4, {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},,aBotoes3),; //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas."
                    If(nOpc <> INCLUIR,AC400Bar(oFldEDD, {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},, aBotoes5),),;
                    AC400Bar(oFldTot, {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))}),; //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas."
                    AC400Bar(oFldRes2,{||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},,aBotRes2),; //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas."
                    AC400Bar(oFldCnpj,{||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)},{||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},,aBotEDB )} //"Deseja Realmente Sair?" # "Todas as alteracoes serao perdidas."

Local bHideAll := {|| Eval(bHide,aFolder[1]), Eval(bHide,aFolder[2]), Eval(bHide,aFolder[3]), Eval(bHide,aFolder[4]), /*Eval(bHide,aFolder[5]),*/ Eval(bHide,aFolder[5]), Eval(bHide,aFolder[7]), Eval(bHide,aFolder[8]) }
Local bClick   := {|| ClicksMark3()}

Local bShow := {|nTela,o| if(nTela==aFolder[2],WorkED1->(dbGoTop()),;
                          if(nTela==aFolder[3],WorkED2->(dbGoTop()),;
                          if(nTela==aFolder[4],WorkED3->(dbGoTop()),;
                          if(nTela==aFolder[5],WorkED4->(dbGoTop()),)))),;
                          o := if(nTela==aFolder[1],oMark6,if(nTela==aFolder[2],oMark,if(nTela==aFolder[3],If(oFld1:nOption == 1,oMark3,oMark3A),if(nTela==aFolder[4],oMark2,/*if(nTela==aFolder[5],oMark5,*/if(nTela==aFolder[5],If(oFld2:nOption == 1,oMark4,oMark4A), if(nTela==aFolder[7],oMark8,if(nTela==aFolder[8],oMark7,)))))))/*)*/:oBrowse,;
                          o:Show(),o:SetFocus(),IIF(nTela==aFolder[3],IIF(oFld1:nOption == 1,AtuaWKED2ED4(1,1,,.T.),AtuaWKED2ED4(1,2,,.T.)),), IIF(nTela==aFolder[5],IIF(oFld2:nOption == 1,AtuaWKED2ED4(2,1,,.T.),AtuaWKED2ED4(2,2,,.T.)),)}  //AOM - 21/06/2012

Private W5_PGI_NUM := "1"
Private oFld, oFldAC, oFldED1, oFldED3, oFldED2, oFldED4, /*oFldRes,*/ oFldCnpj, oFldRes2, oFldEDD, oFldImp1, oFldComp1,oFldImp2, oFldComp2,oFld1,oFld2 //AOM - 29/10/10
Private oMark, oMark2, oMark3, oMark4,/* oMark5,*/ oFldAC2, oFldTot, oMark6, oMark7, oMark8, oMark3A, oMark4A //AOM - 29/10/10
Private aHeader := {}, aCAMPOS := ARRAY(0), fWorkDet
Private cTipoAC, nVal_Ato, nFrete:=0, nSeguro:=0
Private aDelWkED1:={}, aDelWkED2:={}, aDelWkED3:={}, aDelWkED4:={}, aDelWkEDA:={}, aDelWkEDB:={}
Private aSemSX3RE:={}, aSemSX3DI:={}, aSemSX31:={}, aSemSX32:={}, aDelWkEDC:={}
Private Tot_ExpCCob:=0, Tot_ExpSCob:=0, Tot_PercAg:=0, Tot_Exp:=0
Private Tot_ImpCCob:=0, Tot_ImpSCob:=0, Tot_PercPe:=0, Tot_Imp:=0
Private PercAtual:=0, oFont, oSay, nPercTo, oSaySCobE, oSaySCobI
Private nSelec := nOpc // TLM 23/01/2008 - Chamado 068423
Private oMUserEDC := EDCMultiUser()
Private lQuebraPerc := .F.  // NCF-16/11/09
Private aSldDIAnt  := {} //AOM - 27/03/2012 - Guarda os saldos anteriores a serem atualizados.
Private lSiscWeb    := EasyGParam("MV_EDC0005",,.F.) // NCF-022/03/2010
Private aCposED0Tira:={}, aCposED0:= {}
Private lIntegra := .F. //AOM - 25/10/10 - Flag de integração
Private lED0Int  := .T. //AOM - 16/11/10

PRIVATE lRecalcIn:= .T. //TRP - 22/11/2011 - Variável para definir se os Insumos serão recalculados quando um Compromisso de Exportação é alterado.
Private aButtons:= {}
oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o programa todo

// ** PLB 21/11/06 - Verifica se é possivel a alteração do Ato Concessório
If ( nOpc == ALTERAR  .Or.  nOpc == ESTORNAR )  .And.  !oMUserEDC:Reserva("ATO","ALT/EXC")
   Return .F.
EndIf
// **

Processa({|| LimpaTabelas() },STR0009) //"Criando Arquivos Temporarios"
dbSelectArea("ED0")
lQuebraPerc := ED0->(FIELDPOS("ED0_PERCPE")) # 0
aGets:={}
aTela:={}

//Inicializa Variáveis
If nOpc <> INCLUIR

   If !Empty(ED0->ED0_AC) //LGS-11/12/2015
      cCadastro+= " - " + Alltrim(ED0->ED0_AC)
   EndIf

   aCposED0Tira := {}

   If !lSiscWeb
      aAdd(aCposED0Tira,"ED0_PTOTAL")
   EndIf



   FOR i := 1 TO FCount()
      M->&(FIELDNAME(i)) := FieldGet(i)
   NEXT i
   IF !EMPTY(ED0->ED0_OBS)
      M->ED0_VM_OBS:= MSMM(ED0->ED0_OBS,60)
   ENDIF
   nFrete  := M->ED0_FRETE
   nSeguro := M->ED0_SEGURO
   Tot_Imp := M->ED0_FRETE + M->ED0_SEGURO
   If ED0->(FieldPos("ED0_INTEGR")) > 0 .And. Empty(M->ED0_INTEGR)
      M->ED0_INTEGR := "N"
   EndIf


   //AOM - 30/10/10
   If M->ED0_MODAL == "1"
      aAdd(aCposED0Tira,"ED0_PRACA")
      aAdd(aCposED0Tira,"ED0_DELEGA")
      aAdd(aCposED0Tira,"ED0_RUD")
      aAdd(aCposED0Tira,"ED0_FRE_S")
      aAdd(aCposED0Tira,"ED0_DT_PED")
      If AVFLAGS("SEQMI") .And. Empty(M->ED0_TIPINS)
         M->ED0_TIPINS := "0"
      EndIf
   Else
      If AVFLAGS("SEQMI")
         //AOM - 17/11/2011
         aAdd(aCposED0Tira,"ED0_TIPINS")
      EndIF
   EndIf

   SX3->(DbSetOrder(1))                                                                                  //NCF - 22/03/2010 - Retira do array dos campos a serem mostrados
   SX3->(DBSeek("ED0"))                                                                                  //                   na Enchoice, o campo "ED0_PTOTAL"
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "ED0"                                                    //                   quando o parâmetro "MV_EDC0005" estiver ligado.
      If X3Uso(SX3->X3_USADO) .AND. aScan(aCposED0Tira,{|X| AllTrim(X) == AllTrim(SX3->X3_CAMPO)}) == 0
         Aadd(aCposED0,AllTrim(SX3->X3_CAMPO))
      EndIF
      SX3->(dbSkip())
   Enddo

Else

   aCposED0Tira := {}

   If !lSiscWeb
      aAdd(aCposED0Tira,"ED0_PTOTAL")
   EndIf

   //AOM - 30/10/10
   If Left(cModal,1) == "1"
      aAdd(aCposED0Tira,"ED0_PRACA")
      aAdd(aCposED0Tira,"ED0_DELEGA")
      aAdd(aCposED0Tira,"ED0_RUD")
      aAdd(aCposED0Tira,"ED0_FRE_S")
      aAdd(aCposED0Tira,"ED0_DT_PED")
   Else
      //AOM - 17/11/2011
      If AVFLAGS("SEQMI")
         aAdd(aCposED0Tira,"ED0_TIPINS")
      EndIF
   EndIf

   SX3->(DbSetOrder(1))                                                                                  //NCF - 22/03/2010 - Retira do array dos campos a serem mostrados
   SX3->(DBSeek("ED0"))                                                                                  //                   na Enchoice, o campo "ED0_PTOTAL"
   While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "ED0"                                                    //                   quando o parâmetro "MV_EDC0005" estiver ligado.
      If X3Uso(SX3->X3_USADO) .AND. aScan(aCposED0Tira,{|X| AllTrim(X) == AllTrim(SX3->X3_CAMPO)}) == 0
         Aadd(aCposED0,AllTrim(SX3->X3_CAMPO))
      EndIF
      SX3->(dbSkip())
   Enddo

   dbSelectArea("ED0")
   FOR nInd := 1 TO FCount()
      M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
   NEXT

EndIf
cTipoAC := M->ED0_TIPOAC

//AOM - 27/10/10
lVldCNPJ := VldCNPJ()

//Define as folders que serão carregadas as MsSelect
If lVldCNPJ
   If nOpc <> INCLUIR
      aFolder := {3,4,5,6,7,/*7*/,8,10}
      aOpc    := {1,2,9}
   Else
      aFolder := {3,4,5,6,7,/*7*/,,9}
      aOpc    := {1,2,8}
   EndIf
Else
   If nOpc <> INCLUIR
      aFolder := {2,3,4,5,6,/*6*/,7,9}
      aOpc    := {1,8,11}
   Else
      aFolder := {2,3,4,5,6,/*6*/,,8}
      aOpc    := {1,7,11}
   EndIf
EndIf

AADD(aNomeFolders,STR0010)//"&Pedido"
If lVldCNPJ
   AADD(aNomeFolders,STR0011)//"&CNPJ Auxiliares"
EndIf
AADD(aNomeFolders,STR0254)//"C.N.P.J./Filiais"
AADD(aNomeFolders,STR0012)//"Compromissos de Exportação"
AADD(aNomeFolders,STR0014)//"Insumos"
AADD(aNomeFolders,STR0013)//"&Saldos Exportacao"
AADD(aNomeFolders,STR0015)//"Saldos de Insumos"
If nOpc <> INCLUIR
   AADD(aNomeFolders,"Baixa de Insumos")//"Baixa de Insumos"
EndIf
AADD(aNomeFolders,STR0016)//"&Totais"
//AADD(aNomeFolders,STR0198)//"Res. Estruturas"
AADD(aNomeFolders,STR0271)//"Resumo Técnico dos Produtos"



AADD(aAbrevFolders,"AC1")
If lVldCNPJ
   AADD(aAbrevFolders,"AC2")
EndIf
AADD(aAbrevFolders,STR0255)//"C.N.P.J."
AADD(aAbrevFolders,"PAE")
AADD(aAbrevFolders,"PIN")
AADD(aAbrevFolders,"PAI")
If nOpc <> INCLUIR
   AADD(aAbrevFolders,"BAX")
EndIf
AADD(aAbrevFolders,"TOT")
//AADD(aAbrevFolders,"RES")
AADD(aAbrevFolders,"RE2")

nOpcao:=-1
lVolta1 := .F.
//DEFINE MSDIALOG oDlgA TITLE cCadastro FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO ;
//oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

DEFINE MSDIALOG oDlgA TITLE cCadastro FROM oMainWnd:nTop + 90,oMainWnd:nLeft + 3 TO ;
oMainWnd:nBottom - 30,oMainWnd:nRight - 8 OF oMainWnd PIXEL

   oDlgA:lMaximized := .t.

   COLUNA_FINAL := (oDlgA:nClientWidth-4)/2
   nLinha       := (oDlgA:nClientHeight-4)/2
   oFld := TFolder():New(1,1,aNomeFolders,aAbrevFolders,oDlgA,,,,.T.,.F.,COLUNA_FINAL,nLinha)

   aEval(oFld:aControls,{|x| x:SetFont(oDlgA:oFont) })
   oFldAC  := oFld:aDialogs[nFld++]
   If lVldCNPJ
      oFldAC2 := oFld:aDialogs[nFld++]
   EndIf
   oFldCnpj:= oFld:aDialogs[nFld++]
   oFldED1 := oFld:aDialogs[nFld++]
   oFldED2 := oFld:aDialogs[nFld++]
   oFldED3 := oFld:aDialogs[nFld++]
   oFldED4 := oFld:aDialogs[nFld++]
   If nOpc <> INCLUIR
      oFldEDD := oFld:aDialogs[nFld++]
   EndIf
   oFldTot := oFld:aDialogs[nFld++]
   //oFldRES := oFld:aDialogs[nFld++]
   oFldRES2:= oFld:aDialogs[nFld++]


   If nOpc=INCLUIR
      M->ED0_MODAL:=Left(cModal,1)
      // ** PLB 20/06/07
      If M->ED0_MODAL == SUSPENSAO
         M->ED0_DEDUZP := "1"  // "Sim"
      EndIf
      // **
   EndIf

   // Folder A.C.
   oEnch1 := MsMGet():New(cAlias,nReg,nOpc,,,,aCposED0,{15,1,(oFldAC:nClientHeight-4)/2,COLUNA_FINAL},,3,,,,oFldAC)



   Processa({|| IniCpos(2)},STR0008) //"Inicializando Ambiente"

   // Folder CNPJ Auxiliares
   If lVldCNPJ
      AC400CNPJ(nOpc)
   EndIf

   // Folder CNPJ Importadores
   oMark6:= MsSelect():New("WorkEDB",,,aSelCpos10,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldCnpj)

   // Folder Compromissos de Exportação
   nLinha := (oDlgA:nClientHeight-6)/2
   oMark:= MsSelect():New("WorkED1",,,aSelCpos,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldED1)
   oMark:oBrowse:bWhen:={|| oMark:oBrowse:Refresh(),.T.}
   oMark:bAval:={||AC400PEManut(4),oMark:oBrowse:Refresh()/*WorkED1->(dbGoTop())*/}  // PLB 04/12/06 - Atualizar Browse


   //AOM - 09/11/2011 - Criação das Sub-Folders para separar Importados/Compras Nacionais - Insumos
   AADD(aNmFldED2,STR0419)//Importados
   AADD(aNmFldED2,STR0420)//Compras Nacionais
   AADD(aAbFldED2,"IMP")//Importados
   AADD(aAbFldED2,"COM")//Compras Nacionais
   oFld1 := TFolder():New(1,1,aNmFldED2,aAbFldED2,oFldED2,,,,.T.,.F.,,)
   oFld1:Align := CONTROL_ALIGN_ALLCLIENT
   oFldImp1 := oFld1:aDialogs[1]
   oFldComp1:= oFld1:aDialogs[2]

   // Folder Insumos - Importados
   oMark3:= MsSelect():New("WorkED2","ED2_MARCA",,aSelCpos2,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldImp1)
   oMark3:oBrowse:bWhen:={|| oMark3:oBrowse:Refresh(),.T.}
   oMark3:bAval:={||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. M->ED0_MODAL<>ISENCAO .and. Empty(M->ED0_DT_ENC),Eval(bClick),)}

   // Folder Insumos - Compras Nacionais
   oMark3A:= MsSelect():New("WorkED2","ED2_MARCA",,aSelCpos2,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldComp1)
   oMark3A:oBrowse:bWhen:={|| oMark3A:oBrowse:Refresh(),.T.}
   oMark3A:bAval:={||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. M->ED0_MODAL<>ISENCAO .and. Empty(M->ED0_DT_ENC),Eval(bClick),)}


   // Folder Saldos Exportacao
   oMark2:= MsSelect():New("WorkED3",,,aSelCpos3,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldED3)
   oMark2:oBrowse:bWhen:={|| WorkED3->(dbSetOrder(2)),oMark2:oBrowse:Refresh(),.T.}
   oMark2:oBrowse:BLDBLCLICK := {|| AC400AltSeq("WorkED3->ED3_SEQSIS")}      // GFP - 08/10/2012

   //AOM - 09/11/2011 - Criação das Sub-Folders para separar Importados/Compras Nacionais - Saldos Insumos
   AADD(aNmFldED4,STR0421)//"Saldos Importações"
   AADD(aNmFldED4,STR0422)//"Saldos Compras Nacionais"
   AADD(aAbFldED4,"IMP")//Importados
   AADD(aAbFldED4,"COM")//Compras Nacionais
   oFld2 := TFolder():New(1,1,aNmFldED4,aAbFldED4,oFldED4,,,,.T.,.F.,,)
   oFld2:Align := CONTROL_ALIGN_ALLCLIENT
   oFldImp2 := oFld2:aDialogs[1]
   oFldComp2:= oFld2:aDialogs[2]

   // Folder Saldos de Insumos - Importados
   oMark4:= MsSelect():New("WorkED4",,,aSelCpos4,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldImp2)
   oMark4:oBrowse:bWhen:={|| WorkED4->(dbSetOrder(2)),oMark4:oBrowse:Refresh(),.T.}
   oMark4:oBrowse:BLDBLCLICK := {|| AC400AltSeq("WorkED4->ED4_SEQSIS")}      // GFP - 08/10/2012

   // Folder Saldos de Insumos - Compras Nacionais
   oMark4A:= MsSelect():New("WorkED4",,,aSelCpos4A,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldComp2)
   oMark4A:oBrowse:bWhen:={|| If (AvFlags("SEQMI"),WorkED4->(dbSetOrder(6)),WorkED4->(dbSetOrder(2))),oMark4A:oBrowse:Refresh(),.T.}

   //Folder Baixa de Insumos
   If nOpc <> INCLUIR
      oMark8:= MsSelect():New("WorkEDD",,,aSelCpos12,@lInverte,@cMarca,{12,1,368,COLUNA_FINAL},,,oFldEDD)
      oMark8:oBrowse:bWhen:={|| oMark8:oBrowse:Refresh(),.T.}
      oMark8:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // SVG - 28/02/2011 - Tratamento para alinhamento na tela
   EndIf


   // Folder de Totais
   AC400TelaTotais()

   // Folder Resumo das Estruturas
   //oMark5:= MsSelect():New("WorkEDA",,,aSelCpos9,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldRes)- AOM - 27/10/10

   // Folder Resumo Técnico dos Produtos
   oMark7:= MsSelect():New("WorkEDC",,,aSelCpos11,@lInverte,@cMarca,{30,1,nLinha,COLUNA_FINAL},,,oFldRes2)

   If nOpc<>INCLUIR
      Processa({|| AC400GrvWorks()}, STR0017) //"Gravando Arquivos Temporarios"
   EndIf

   If nOpc<>ESTORNAR .and. nOpc<>VISUALIZAR .and. Empty(M->ED0_DT_ENC)
      If M->ED0_MODAL<>ISENCAO  // Suspensão
// *****************   ACSJ - 30/04/2004 - Criado 4º parametro nos arrays abaixo para definir a propriedade *****************************************************************************
//                                         cTitle dos botões na Função AC400Bar, Quando necessario apenas
//                                         incluir o titulo do botão desejado, caso contrario passar NIL.
         // Botoes da Exportação
         Aadd(aBotoes,{"EDIT",{|| FolderSetFocus(oFld, oFldED1), AC400PEManut(3)},STR0004, ""}) //"Incluir"
         Aadd(aBotoes,{"IC_17",{|| FolderSetFocus(oFld, oFldED1), AC400PEManut(4)}, STR0005, ""}) //"Alterar"
         Aadd(aBotoes,{"EXCLUIR",{|| FolderSetFocus(oFld, oFldED1), AC400PEManut(5)}, STR0018, ""}) //"Excluir"
         Aadd(aBotoes,{"PESQUISA",{|| FolderSetFocus(oFld, oFldED1), AC400PesqNCM("WorkED1")}, STR0019, ""/*STR0401*/} ) //"Pesquisar por NCM" //$$ "Pesq."

         // Botoes da Importação
         Aadd(aBotoes2,{"EDIT",{|| FolderSetFocus(oFld, oFldED2), AC400PIManut(3)},STR0004, ""}) //"Incluir"
         Aadd(aBotoes2,{"IC_17",{|| FolderSetFocus(oFld, oFldED2), AC400PIManut(4)}, STR0005, ""}) //"Alterar"
         Aadd(aBotoes2,{"EXCLUIR",{|| FolderSetFocus(oFld, oFldED2), AC400PIManut(5)}, STR0018,""}) //"Excluir"
         Aadd(aBotoes2,{"PESQUISA",{|| FolderSetFocus(oFld, oFldED2), AC400PesqNCM("WorkED2")}, STR0019,""}) //"Pesquisar por NCM" //$$ "Pesq."
         Aadd(aBotoes2,{"LBTIK",{|| FolderSetFocus(oFld, oFldED2), If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,Processa({|| AC400Marca(.T.)}, STR0021),),WorkED2->(dbGoTop())},STR0021,""}) //"Marca/Desmarca Todos" //$$"Todos"
         Aadd(aBotoes2,{"S4WB014B",{|| FolderSetFocus(oFld, oFldED2), ACVinc()},STR0413, ""}) // "Vincular Produto" , "V.Prod"
      Else
         // Botoes da Exportação
         Aadd(aBotoes,{"EDIT",{|| FolderSetFocus(oFld, oFldED1), AC400PEManut(3, M->ED0_MODAL)},STR0004,""}) //"Incluir"
         If nOpc <> INCLUIR //AOM - 04/11/10
            Aadd(aBotoes,{"IC_17",{|| FolderSetFocus(oFld, oFldED1), AC400PEManut(4, M->ED0_MODAL)}, STR0005,""}) //"Alterar"
         EndIf
         Aadd(aBotoes,{"EXCLUIR",{|| FolderSetFocus(oFld, oFldED1), AC400PEManut(5, M->ED0_MODAL)}, STR0018,""}) //"Excluir"
         Aadd(aBotoes,{"POSCLI",{|| FolderSetFocus(oFld, oFldED1), If(ValApuracao("EXP"),AC400Apuracao(),)}, STR0020,""/*STR0403*/}) //"Apuracao" //$$"Apurar"
         Aadd(aBotoes,{"PESQUISA",{|| FolderSetFocus(oFld, oFldED1), ACPesqED1()}, STR0002,""}) //"Pesquisar" //$$ "Pesq."

         // Botoes da Importação
         Aadd(aBotoes2,{"EDIT",{|| FolderSetFocus(oFld, oFldED2), AC400PIManut(3,,M->ED0_MODAL)},STR0004,""}) //"Incluir"
         If nOpc <> INCLUIR //AOM - 04/11/10
            Aadd(aBotoes2,{"IC_17",{|| FolderSetFocus(oFld, oFldED2), AC400PIManut(4,,M->ED0_MODAL)}, STR0005,""}) //"Alterar"
         EndIf
         Aadd(aBotoes2,{"EXCLUIR",{|| FolderSetFocus(oFld, oFldED2), AC400PIManut(5,,M->ED0_MODAL)}, STR0018,""}) //"Excluir"
         Aadd(aBotoes2,{"POSCLI",{|| FolderSetFocus(oFld, oFldED2), If(ValApuracao("IMP"),AC400ApImp(), )}, STR0020,""}) //"Apuracao" //$$ "Apurar"
         Aadd(aBotoes2,{"PESQUISA",{|| FolderSetFocus(oFld, oFldED2), AC400PesqDI()}, STR0002,""})  //"Pesquisar" //$$ "Pesq.
         Aadd(aBotoes2,{"PROJETPMS",{|| FolderSetFocus(oFld, oFldED2), ACDetDI()}, STR0282,""}) //"Utilização do Item" //$$ "Item"
      EndIf

      //AAF 16/12/05 - Alteração de NCM
      If ED2->( FieldPos("ED2_NCMANT") ) > 0
         aAdd(aBotoes3,{"DEVOLNF",{|| FolderSetFocus(oFld, oFldED4), AC400AltNCM("I")}, STR0309,""})//"Alteração de NCM"
      EndIf

      If ED1->( FieldPos("ED1_NCMANT") ) > 0
         aAdd(aBotoes4,{"DEVOLNF",{|| FolderSetFocus(oFld, oFldED3), AC400AltNCM("E")}, STR0309, ""})//"Alteração de NCM"
      EndIf

      Aadd(aBotEDB,{"EDIT",{|| FolderSetFocus(oFld, oFldCnpj), AC400FILIALCNPJ(3)},STR0004,""}) //"Incluir"
      Aadd(aBotEDB,{"EXCLUIR",{|| FolderSetFocus(oFld, oFldCnpj), AC400FILIALCNPJ(5)}, STR0018,""}) //"Excluir"
      Aadd(aBotRes,{"PESQUISA",{||ACPesqRes("WorkEDA")},STR0272,""}) //"Pesquisa Resumo" //$$ "Pesq Res"
      Aadd(aBotRes2,{"PESQUISA",{|| FolderSetFocus(oFld, oFldRES2), ACPesqRes("WorkEDC")},STR0272,""}) //"Pesquisa Resumo"//$$ "Pesq Res"
   Else
      Aadd(aBotoes,{"BMPVISUAL" /*"ANALITICO"*/,{|| FolderSetFocus(oFld, oFldED1), AC400PEManut(2)}, STR0003,STR0405}) //"Visualizar" //$$ "Visualiza"
      Aadd(aBotoes2,{"BMPVISUAL" /*"ANALITICO"*/,{|| FolderSetFocus(oFld, oFldED2), AC400PIManut(2)}, STR0003,STR0405}) //"Visualizar" //$$ "Visualiza"
      If M->ED0_MODAL == ISENCAO  // Suspensão wfs 17/08/11
         Aadd(aBotoes2,{"PROJETPMS",{|| FolderSetFocus(oFld, oFldED2), ACDetDI()}, STR0282,STR0404}) //"Utilização do Item" //$$ "Item"
      EndIf

      //Botão para baixa dos insumos
      AAdd(aBotoes5, {"BMPVISUAL", {|| FolderSetFocus(oFld, oFldEDD), FilterBaixaInsumos("WorkEDD", oFldEDD)}, "Filtrar Baixa de Insumos"}) 
   EndIf

   If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"MBROWSE_BOTOES"),)  // TLM 23/01/2008

// ********************************************************************************************* ACSJ - 30/04/2004 **********************************************************************


   //AOM - 27/10/10
   oFld:bChange := {|nOption,nOldOption| Eval(bHide,nOldOption),;
                   IF(nOption<>aOpc[1]  .and. nOption<>aOpc[2] .and. nOption<>aOpc[3],Eval(bShow,nOption),), If(nOption == aFolder[3],AtuaWKED2ED4(1,oFld1:nOption,,.T.), ) ,;
                   If(nOption == aFolder[4],AtuaWKED2ED4(2,oFld2:nOption,,.T.), ) }

   //AOM - 09/11/2011
   oFld1:bChange := {|nOption,nOldOption| AtuaWKED2ED4(1,nOption,nOldOption,.T.) }
   oFld2:bChange := {|nOption,nOldOption| AtuaWKED2ED4(2,nOption,nOldOption,.T.) }


   Eval(bHideAll)

   //AOM - 09/11/2011
   Eval(oFld1:bChange)
   Eval(oFld2:bChange)

   oFld:Align := CONTROL_ALIGN_ALLCLIENT
   oEnch1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMark2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMark3:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMark3A:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMark4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMark4A:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMark6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMark7:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO - Alteração das propriedades de alinhamento de tela para antes do Init - 02/01/2012

ACTIVATE MSDIALOG oDlgA ON INIT ((Eval(bBarras)), oMainWnd:Hide(),;
                                                  oMainWnd:Show(),;
                                                  EnchoiceBar(oDlgA, {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)}, {||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),Eval(bCancel),),Eval(bCancel))},, @aButtons))

If (nOpcao = -1 .AND. ! lVolta1) .OR. nOpcao = 0
   lVolta := .F.
EndIF
If nOpcao = 1
   dbSelectArea("ED0")
   If nOpc=INCLUIR .or. nOpc=ALTERAR
      EE2->(DbSetOrder(1))
      SB1->(dbSetOrder(1))
      Processa({|| AC400GrvTudo(nOpc)}, STR0022) //"Gravando Ato Concessorio"
      AC400Valid("SOMATORIA")
   ElseIf nOpc=ESTORNAR
      Processa({|| AC400Estorna(nOpc)}, STR0023) //"Apagando Ato Concessorio"
   EndIf
   //ED0->(MSUnlock())
EndIf

aBotoes :={}
aBotoes2:={}
aBotoes3:={}
aBotoes4:={}
aBotoes5:={}
aBotEDB :={}
aBotRes :={}
aBotRes2:={}
aTelaSis:={}
cCadastro := STR0001

oMUserEDC:Fim()  // PLB 27/11/06 - Solta registros presos e reinicializa objeto

If Select("WorkDet") <> 0
   //WorkDet->(dbCloseArea())
   WorkDet->(E_EraseArq(fWorkDet))
EndIf

//Apaga os filtros aplicados na WorkEDD
If nOpc == VISUALIZAR
   If Select("WorkEDD") > 0
      WorkEDD->(DBClearFilter())
   EndIf
EndIf

Return .T.

*-------------------*
Function AC400Copia()   // B
*-------------------*
Local oDlgB
Local cPedido:=Space(Len(ED0->ED0_PD))
Local nOpcao:=0, bOk := {||nOpcao:=1,oDlgB:End()}
Local oPanel

If ED0->ED0_MODAL == ISENCAO
   Help(" ",1,"AVG0005295") //MsgInfo(STR0247) //"Atos Concessórios modalidade Isenção não podem ser copiados."
   Return .T.
EndIf

DEFINE MSDIALOG oDlgB TITLE STR0024 ; //"Novo Pedido"
       FROM 0, 0 TO 15, 80 OF GetWndDefault()

   oPanel:= TPanel():New(0, 0, "", oDlgB,, .F., .F.,,, 90, 165)
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @02,02 SAY   STR0024   of oPanel  //"Novo Pedido"
   @02,08 MSGET cPedido     PICT AVSX3("ED0_PD",6) SIZE 60,8 of oPanel

ACTIVATE MSDIALOG oDlgB ON INIT EnchoiceBar(oDlgB,{||If(NaoVazio(cPedido) .and. ValCopia(cPedido),Eval(bOk),)},{||nOpcao:=0,oDlgB:End()}) CENTERED

If nOpcao=1
   If Select("WorkED0") == 0
      Processa({|| AC400Works(.T.)}, STR0009) //"Criando Arquivos Temporarios"
   EndIf
   Processa({|| LimpaTabelas() }, STR0009) //"Criando Arquivos Temporarios"
   Processa({|| AC400GrvWorks(.T.)}, STR0022) //"Gravando Arquivos Temporarios"
   Processa({|| AC400GrvCopia(cPedido)}, STR0025+Alltrim(ED0->ED0_PD)+; //"Copiando Ato Concessorio "
                                         STR0026+Alltrim(cPedido))      //" para "
EndIf

nOpcao:=0

Return .T.
*------------------------------------*
Static Function AC400GrvCopia(cPedido)
*------------------------------------*
Local nTot, cModal, nTotRec, cSeqSisAux:=1, dDtVal:=avCtoD("  /  /  "), cCGC:=BuscaCNPJ(ED0->ED0_IMPORT),i , cSeqMiAux :=1
Local nQtdCalAux:=0
Local cImport := "" //AOM - 10/11/2011
Private nQtdCalNcm:=0
nTotRec:=WorkED2->(EasyRecCount())+WorkED1->(EasyRecCount())+WorkED3->(EasyRecCount())+WorkED4->(EasyRecCount())
nTotRec+=WorkEDA->(EasyRecCount())
nTotRec+=WorkEDB->(EasyRecCount())
nTotRec+=WorkEDC->(EasyRecCount())
nTot:=If(ED0->ED0_MODAL==SUSPENSAO,1+nTotRec,1)

dDt_Val := AC400ApDtValid(,"ED0")

ED3->(dbSetOrder(1))
ED4->(dbSetOrder(1))

Begin TransAction

cModal := ED0->ED0_MODAL
ProcRegua(nTot)

dbSelectArea("WorkED0")
IncProc(STR0027) //"Gravando Capa do A.C."
ED0->(RecLock("ED0",.T.))
ED0->ED0_FILIAL:= cFilED0  //TRP-08/04/08
FOR i := 1 TO FCount()
   cCampo:=FIELDNAME(i)
   If !cCampo $ ("ED0_AC/ED0_DT_VA2/ED0_DT_PR1/ED0_DT_PR2/ED0_DT_PR3/ED0_PROAP1/ED0_PROAP2/ED0_PROAP3/ED0_DIAG/ED0_ENV/ED0_DT_ENV/ED0_RET/ED0_DT_ENC/ED0_DT_PED/ED0_DEFERI/ED0_DT_REG/ED0_DT_VA1")
      ED0->&(cCampo) := WorkED0->&(cCampo)
   EndIf
NEXT i
ED0->ED0_AC:=""
ED0->ED0_PD:=cPedido
ED0->(msUnlock())

If cModal == SUSPENSAO
   dbSelectArea("WorkED1")
   WorkED1->(dbGoTop())
   Do While !WorkED1->(EOF())
      IncProc(STR0028) //"Gravando Produtos a Exportar"
      ED1->(RecLock("ED1",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         ED1->&(cCampo) := WorkED1->&(cCampo)
      NEXT i
      ED1->ED1_AC:=""
      ED1->ED1_PD:=cPedido
      ED1->(msUnlock())

      If lIndPercAg
         cChaveED3 := cFilED3+ED1->ED1_PD+ED1->ED1_NCM+ED1->ED1_PROD+Str(ED1->ED1_PERCAG,5,2)+;
            iif(lED1Umanex,Iif(Empty(ED1->ED1_UMANEX),ED1->ED1_UMNCM,ED1->ED1_UMANEX),ED1->ED1_UMNCM)
      Else
         cChaveED3 := cFilED3+ED1->ED1_PD+ED1->ED1_NCM+ED1->ED1_PROD+;
            iif(lED1Umanex,Iif(Empty(ED1->ED1_UMANEX),ED1->ED1_UMNCM,ED1->ED1_UMANEX),ED1->ED1_UMNCM)
      EndIf

      If !ED3->(dbSeek(cChaveED3))  // A.Caetano - ACSJ - Verifica existencia do campo no SX3 - 17/11/2004
         ED3->(RecLock("ED3",.T.))
         ED3->ED3_PROD   := ED1->ED1_PROD
         ED3->ED3_SEQSIS := StrZero(cSeqSisAux,3,0)
         ED3->ED3_NCM    := ED1->ED1_NCM
         ED3->ED3_QTD    := ED1->ED1_QTD
         ED3->ED3_UMPROD := ED1->ED1_UMPROD
         ED3->ED3_SALDO  := ED1->ED1_QTD
         ED3->ED3_VAL_EM := ED1->ED1_VAL_EM
         ED3->ED3_VAL_SE := ED1->ED1_VAL_SE
         ED3->ED3_SAL_SE := ED1->ED1_VAL_SE
         ED3->ED3_VALCOM := (ED1->ED1_VAL_EM * ED1->ED1_PERCAG)/100
         ED3->ED3_VAL_CO := ED1->ED1_VAL_EM-((ED1->ED1_VAL_EM * ED1->ED1_PERCAG)/100)
         ED3->ED3_SAL_CO := ED1->ED1_VAL_EM-((ED1->ED1_VAL_EM * ED1->ED1_PERCAG)/100)
         ED3->ED3_UMNCM  := iif(lED1Umanex,If(Empty(ED1->ED1_UMANEX),ED1->ED1_UMNCM,ED1->ED1_UMANEX),ED1->ED1_UMNCM) // A.Caetano - ACSJ - Verifica existencia do campo no SX3 - 17/11/2004

         if lED1Umanex   // A.Caetano - ACSJ - Verifica existencia do campo no SX3 - 17/11/2004
            If Empty(ED1->ED1_UMANEX)
               ED3->ED3_QTDNCM := ED1->ED1_QTDNCM
               ED3->ED3_SALNCM := ED1->ED1_QTDNCM
            Else
               ED3->ED3_QTDNCM := AvTransUnid(ED1->ED1_UMNCM,ED1->ED1_UMANEX,ED1->ED1_PROD,ED1->ED1_QTDNCM)
               ED3->ED3_SALNCM := AvTransUnid(ED1->ED1_UMNCM,ED1->ED1_UMANEX,ED1->ED1_PROD,ED1->ED1_QTDNCM)
            EndIf
         Else
            ED3->ED3_QTDNCM := ED1->ED1_QTDNCM
            ED3->ED3_SALNCM := ED1->ED1_QTDNCM
         Endif

         ED3->ED3_PERCAG := ED1->ED1_PERCAG
         ED3->ED3_PESO   := ED1->ED1_PESO
         ED3->ED3_FILIAL := cFilED3
         ED3->ED3_PD     := ED0->ED0_PD
         ED3->ED3_AC     := ED0->ED0_AC
         ED3->ED3_DT_VAL := dDt_Val
         ED3->ED3_CNPJIM := cCGC
         ED3->(msUnlock())
         cSeqSisAux += 1
      Else
         ED3->(RecLock("ED3",.F.))
         ED3->ED3_QTD    += ED1->ED1_QTD
         ED3->ED3_SALDO  += ED1->ED1_QTD
         ED3->ED3_VAL_EM += ED1->ED1_VAL_EM
         ED3->ED3_VAL_SE += ED1->ED1_VAL_SE
         ED3->ED3_SAL_SE += ED1->ED1_VAL_SE
         ED3->ED3_VALCOM += (ED1->ED1_VAL_EM * ED1->ED1_PERCAG)/100
         ED3->ED3_VAL_CO += ED1->ED1_VAL_EM-((ED1->ED1_VAL_EM * ED1->ED1_PERCAG)/100)
         ED3->ED3_SAL_CO += ED1->ED1_VAL_EM-((ED1->ED1_VAL_EM * ED1->ED1_PERCAG)/100)

         if lED1Umanex   // A.Caetano - ACSJ - Verifica existencia do campo no SX3 - 17/11/2004
            If Empty(ED1->ED1_UMANEX)
               ED3->ED3_SALNCM += ED1->ED1_QTDNCM
               ED3->ED3_QTDNCM += ED1->ED1_QTDNCM
            Else
               ED3->ED3_SALNCM += AvTransUnid(ED1->ED1_UMNCM,ED1->ED1_UMANEX,ED1->ED1_PROD,ED1->ED1_QTDNCM)
               ED3->ED3_QTDNCM += AvTransUnid(ED1->ED1_UMNCM,ED1->ED1_UMANEX,ED1->ED1_PROD,ED1->ED1_QTDNCM)
            EndIf
         Else
            ED3->ED3_SALNCM += ED1->ED1_QTDNCM
            ED3->ED3_QTDNCM += ED1->ED1_QTDNCM
         Endif

         ED3->ED3_PESO   += ED1->ED1_PESO
         ED3->ED3_FILIAL := cFilED3
         ED3->ED3_PD     := ED0->ED0_PD
         ED3->ED3_AC     := ED0->ED0_AC
         ED3->ED3_DT_VAL := dDt_Val
         ED3->ED3_CNPJIM := cCGC

         ED3->ED3_PERCAG := Round(ED3->ED3_VALCOM / ED3->ED3_VAL_EM,4)*100

         ED3->(msUnlock())
      EndIf

      WorkED1->(dbSkip())
   EndDo

  /* dbSelectArea("WorkED3")
   WorkED3->(dbGoTop())
   Do While !WorkED3->(EOF())
      IncProc(STR0028) //"Gravando Produtos a Exportar"
      ED3->(RecLock("ED3",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         ED3->&(cCampo) := WorkED3->&(cCampo)
      NEXT i
      ED3->ED3_AC:=""
      ED3->ED3_PD:=cPedido
      ED3->(msUnlock())
      WorkED3->(dbSkip())
   EndDo */

   dbSelectArea("WorkED2")
   WorkED2->(dbGoTop())
   cSeqSisAux := 1
   Do While !WorkED2->(EOF())
      IncProc(STR0029) //"Gravando Itens a Importar"
      ED2->(RecLock("ED2",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         ED2->&(cCampo) := WorkED2->&(cCampo)
      NEXT i
      ED2->ED2_AC:=""
      ED2->ED2_PD:=cPedido
      ED2->(msUnlock())
      If ED2->ED2_MARCA == "1"

         //AOM - 10/11/2011
         If AvFlags("SEQMI")
            cImport := ED2->ED2_IMPORT
         EndIf

         If ED4->(dbSeek(cFilED4+ED2->ED2_PD+ED2->ED2_NCM+ED2->ED2_ITEM+ED2->ED2_CAMB+Str(ED2->ED2_PERCPE,5,2)+;
            iif(lED2Umanex,Iif(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_UMNCM)+cImport))  // A.Caetano - ACSJ - Verifica existencia do campo no SX3 - 17/11/2004

            ED4->(RecLock("ED4",.F.))
            // ** AAF 14/04/05 - Calculos verificam se percentual de perda é menor que o aprovado.
            nQtdPE:= Max(ED2->ED2_PERCPE - if(lED2Percap,ED2->ED2_PERCAP,0), 0) * ED2->ED2_QTD /100
            nValPE:= Max(ED2->ED2_PERCPE - if(lED2Percap,ED2->ED2_PERCAP,0), 0) * ED2->ED2_VALEMB /100

            ED4->ED4_QTD    += ED2->ED2_QTD
            ED4->ED4_VALEMB += ED2->ED2_VALEMB
            ED4->ED4_QTDCAL += ED2->ED2_QTD    - nQtdPE
            ED4->ED4_VALCAL += ED2->ED2_VALEMB - nValPE
            ED4->ED4_QT_LI  += ED2->ED2_QTD    - nQtdPE
            ED4->ED4_VL_LI  += ED2->ED2_VALEMB - nValPE
            ED4->ED4_QT_DI  += ED2->ED2_QTD    - nQtdPE
            ED4->ED4_VL_DI  += ED2->ED2_VALEMB - nValPE
            // ** AAF 14/04/05

            if lED2Umanex
               if Empty(ED2->ED2_UMANEX)
                  lUmanex2Vazio := .t.
               Else
                  lUmanex2Vazio := .f.
               Endif
            Else
               lUmanex2Vazio := .t.
            Endif

            If lUmanex2Vazio
               ED4->ED4_QTDNCM += ED2->ED2_QTDNCM
               If AvVldUn(ED2->ED2_UMNCM)  // MPG - 14/02/2018

                  if lED2Percap   // ACSJ - 17/11/2004
                     If ED2->ED2_PERCPE > ED2->ED2_PERCAP
                        nQtdCalNCM := ED2->ED2_QTDNCM - ((ED2->ED2_PERCPE - ED2->ED2_PERCAP) * ED2->ED2_QTDNCM)/100
                     Else
                        nQtdCalNCM := ED2->ED2_QTDNCM
                     EndIf
                  Else
                     If ED2->ED2_PERCPE > 0
                        nQtdCalNCM := ED2->ED2_QTDNCM - (ED2->ED2_PERCPE * ED2->ED2_QTDNCM)/100
                     Else
                        nQtdCalNCM := ED2->ED2_QTDNCM
                     EndIf
                  Endif

                  ED4->ED4_SNCMLI += nQtdCalNCM
                  ED4->ED4_SNCMDI += nQtdCalNCM
               Else

                  if lED2Percap   // ACSJ - 17/11/2004
                     If ED2->ED2_PERCPE > ED2->ED2_PERCAP
                        nQtdCalAux := ED2->ED2_QTD - ((ED2->ED2_PERCPE - ED2->ED2_PERCAP) * ED2->ED2_QTD)/100
                     Else
                        nQtdCalAux := ED2->ED2_QTD
                     EndIf
                  Else
                     If ED2->ED2_PERCPE > 0
                        nQtdCalAux := ED2->ED2_QTD - (ED2->ED2_PERCPE * ED2->ED2_QTD)/100
                     Else
                        nQtdCalAux := ED2->ED2_QTD
                     EndIf
                  Endif


                  ED4->ED4_SNCMLI += AVTransUnid(ED2->ED2_UMITEM, iif(lED2Umanex,If(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_UMNCM),ED2->ED2_ITEM,nQtdCalAux)
                  ED4->ED4_SNCMDI += AVTransUnid(ED2->ED2_UMITEM, iif(lED2Umanex,If(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_UMNCM),ED2->ED2_ITEM,nQtdCalAux)
               EndIf
            Else // ACSJ - Não verifico o campo ED2_Umanex abaixo pois so entrara nesta condicao e o campo existir - 17/11/2004
               ED4->ED4_QTDNCM += AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM)
               If AvVldUn(ED2->ED2_UMANEX) // MPG - 14/02/2018

                  if lED2Percap   // ACSJ - 17/11/2004
                     If ED2->ED2_PERCPE > ED2->ED2_PERCAP
                        nQtdCalNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM) - ((ED2->ED2_PERCPE - ED2->ED2_PERCAP) * AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM))/100
                     Else
                        nQtdCalNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM)
                     EndIf
                  Else
                     If ED2->ED2_PERCPE > 0
                        nQtdCalNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM) - (ED2->ED2_PERCPE * AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM))/100
                     Else
                        nQtdCalNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM)
                     EndIf
                  Endif


                  ED4->ED4_SNCMLI += nQtdCalNCM
                  ED4->ED4_SNCMDI += nQtdCalNCM
               Else

                  if lED2Percap   // ACSJ - 17/11/2004
                     If ED2->ED2_PERCPE > ED2->ED2_PERCAP
                        nQtdCalAux := ED2->ED2_QTD - ((ED2->ED2_PERCPE - ED2->ED2_PERCAP) * ED2->ED2_QTD)/100
                     Else
                        nQtdCalAux := ED2->ED2_QTD
                     EndIf
                  Else
                     If ED2->ED2_PERCPE > 0
                        nQtdCalAux := ED2->ED2_QTD - (ED2->ED2_PERCPE * ED2->ED2_QTD)/100
                     Else
                        nQtdCalAux := ED2->ED2_QTD
                     EndIf
                  Endif

                  WorkED4->ED4_SNCMLI += AVTransUnid(ED2->ED2_UMITEM,If(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_ITEM,nQtdCalAux)
                  WorkED4->ED4_SNCMDI += AVTransUnid(ED2->ED2_UMITEM,If(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_ITEM,nQtdCalAux)
               EndIf
            EndIf

            ED4->ED4_PESO   += ED2->ED2_PESO
            ED4->ED4_AC:=""
            ED4->ED4_PD:=cPedido
            ED4->ED4_FILIAL := cFilED4
            ED4->ED4_DT_VAL := dDt_Val
            ED4->ED4_CNPJIM := cCGC
            ED4->(msUnlock())
         Else
            ED4->(RecLock("ED4",.T.))
            ED4->ED4_ITEM   := ED2->ED2_ITEM
            ED4->ED4_NCM    := ED2->ED2_NCM
            ED4->ED4_QTD    := ED2->ED2_QTD
            ED4->ED4_UMITEM := ED2->ED2_UMITEM
            ED4->ED4_VALEMB := ED2->ED2_VALEMB
            ED4->ED4_PERCPE := ED2->ED2_PERCPE

            /*
            ED4->ED4_QTDCAL := ED2->ED2_QTD - ((ED2->ED2_PERCPE - iif(lED2Percap,ED2->ED2_PERCAP,0)) * ED2->ED2_QTD)/100       // ACSJ - 18/11/2004
            ED4->ED4_VALCAL := ED2->ED2_VALEMB - ((ED2->ED2_PERCPE - iif(lED2Percap,ED2->ED2_PERCAP,0)) * ED2->ED2_VALEMB)/100 // ACSJ - 18/11/2004
            ED4->ED4_QT_LI  := ED2->ED2_QTD - ((ED2->ED2_PERCPE - iif(lED2Percap,ED2->ED2_PERCAP,0)) * ED2->ED2_QTD)/100       // ACSJ - 18/11/2004
            ED4->ED4_VL_LI  := ED2->ED2_VALEMB - ((ED2->ED2_PERCPE - iif(lED2Percap,ED2->ED2_PERCAP,0)) * ED2->ED2_VALEMB)/100 // ACSJ - 18/11/2004
            ED4->ED4_QT_DI  := ED2->ED2_QTD - ((ED2->ED2_PERCPE - iif(lED2Percap,ED2->ED2_PERCAP,0)) * ED2->ED2_QTD)/100       // ACSJ - 18/11/2004
            ED4->ED4_VL_DI  := ED2->ED2_VALEMB - ((ED2->ED2_PERCPE - iif(lED2Percap,ED2->ED2_PERCAP,0)) * ED2->ED2_VALEMB)/100 // ACSJ - 18/11/2004
            */

            // ** AAF 14/04/05 - Calculos verificam se percentual de perda é menor que o aprovado.
            nQtdPE:= Max(ED2->ED2_PERCPE - if(lED2Percap,ED2->ED2_PERCAP,0), 0) * ED2->ED2_QTD /100
            nValPE:= Max(ED2->ED2_PERCPE - if(lED2Percap,ED2->ED2_PERCAP,0), 0) * ED2->ED2_VALEMB /100

            ED4->ED4_QTDCAL := ED2->ED2_QTD    - nQtdPE
            ED4->ED4_VALCAL := ED2->ED2_VALEMB - nValPE
            ED4->ED4_QT_LI  := ED2->ED2_QTD    - nQtdPE
            ED4->ED4_VL_LI  := ED2->ED2_VALEMB - nValPE
            ED4->ED4_QT_DI  := ED2->ED2_QTD    - nQtdPE
            ED4->ED4_VL_DI  := ED2->ED2_VALEMB - nValPE
            // ** AAF 14/05/04

            ED4->ED4_CAMB   := ED2->ED2_CAMB
            ED4->ED4_UMNCM  := iif(lED2Umanex,Iif(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_UMNCM) // ACSJ - 17/11/2004

            if lED2Umanex // ACSJ - 17/11/2004
               if Empty(ED2->ED2_UMANEX)
                  lUmanex2Vazio := .t.
               Else
                  lUmanex2Vazio := .f.
               Endif
            Else
               lUmanex2Vazio := .t.
            Endif

            If lUmanex2Vazio
               ED4->ED4_QTDNCM := ED2->ED2_QTDNCM
               If AvVldUn(ED2->ED2_UMNCM) // MPG - 14/02/2018

                  if lED2Percap   // ACSJ - 17/11/2004
                     If ED2->ED2_PERCPE > ED2->ED2_PERCAP
                        nQtdCalNCM := ED2->ED2_QTDNCM - ((ED2->ED2_PERCPE - ED2->ED2_PERCAP) * ED2->ED2_QTDNCM)/100
                     Else
                        nQtdCalNCM := ED2->ED2_QTDNCM
                     EndIf
                  Else
                     If ED2->ED2_PERCPE > 0
                        nQtdCalNCM := ED2->ED2_QTDNCM - (ED2->ED2_PERCPE * ED2->ED2_QTDNCM)/100
                     Else
                        nQtdCalNCM := ED2->ED2_QTDNCM
                     EndIf
                  Endif

                  ED4->ED4_SNCMLI := nQtdCalNCM
                  ED4->ED4_SNCMDI := nQtdCalNCM
               Else
                  if lED2Percap  // ACSJ - 17/11/2004
                     If ED2->ED2_PERCPE > ED2->ED2_PERCAP
                        nQtdCalAux := ED2->ED2_QTD - ((ED2->ED2_PERCPE - ED2->ED2_PERCAP) * ED2->ED2_QTD)/100
                     Else
                        nQtdCalAux := ED2->ED2_QTD
                     EndIf
                  Else
                     If ED2->ED2_PERCPE > 0
                        nQtdCalAux := ED2->ED2_QTD - (ED2->ED2_PERCPE * ED2->ED2_QTD)/100
                     Else
                        nQtdCalAux := ED2->ED2_QTD
                     EndIf
                  Endif

                  ED4->ED4_SNCMLI := AVTransUnid(ED2->ED2_UMITEM,iif(lED2Umanex,If(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_UMNCM),ED2->ED2_ITEM,nQtdCalAux)
                  ED4->ED4_SNCMDI := AVTransUnid(ED2->ED2_UMITEM,iif(lED2Umanex,If(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_UMNCM),ED2->ED2_ITEM,nQtdCalAux)
               EndIf
            Else // ACSJ - Não verifico o campo ED2_Umanex abaixo pois so entrara nesta condicao se o campo existir - 17/11/2004
               ED4->ED4_QTDNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM)
               If AvVldUn(ED2->ED2_UMANEX) // MPG - 14/02/2018
                  if lED2Percap   // ACSJ - 17/11/2004
                     If ED2->ED2_PERCPE > ED2->ED2_PERCAP
                        nQtdCalNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM) - ((ED2->ED2_PERCPE - ED2->ED2_PERCAP) * AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM))/100
                     Else
                        nQtdCalNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM)
                     EndIf
                  Else
                     If ED2->ED2_PERCPE > 0
                        nQtdCalNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM) - (ED2->ED2_PERCPE * AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM))/100
                     Else
                        nQtdCalNCM := AVTransUnid(ED2->ED2_UMNCM,ED2->ED2_UMANEX,ED2->ED2_ITEM,ED2->ED2_QTDNCM)
                     EndIf
                  Endif

                  ED4->ED4_SNCMLI := nQtdCalNCM
                  ED4->ED4_SNCMDI := nQtdCalNCM
               Else
                  If lED2Percap   // ACSJ - 17/11/2004
                     If ED2->ED2_PERCPE > ED2->ED2_PERCAP
                        nQtdCalAux := ED2->ED2_QTD - ((ED2->ED2_PERCPE - ED2->ED2_PERCAP) * ED2->ED2_QTD)/100  // ACSJ - 17/11/2004
                     Else
                        nQtdCalAux := ED2->ED2_QTD
                     EndIf
                  Else
                     If ED2->ED2_PERCPE > 0
                        nQtdCalAux := ED2->ED2_QTD - (ED2->ED2_PERCPE * ED2->ED2_QTD)/100  // ACSJ - 17/11/2004
                     Else
                        nQtdCalAux := ED2->ED2_QTD
                     EndIf
                  Endif

                  ED4->ED4_SNCMLI := AVTransUnid(ED2->ED2_UMITEM,If(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_ITEM,nQtdCalAux)
                  ED4->ED4_SNCMDI := AVTransUnid(ED2->ED2_UMITEM,If(Empty(ED2->ED2_UMANEX),ED2->ED2_UMNCM,ED2->ED2_UMANEX),ED2->ED2_ITEM,nQtdCalAux)
               EndIf
            EndIf


            ED4->ED4_PESO   := ED2->ED2_PESO

            //AOM 11/11/11
            If AvFlags("SEQMI") .And. ED2->ED2_IMPORT == "N"

               If !Empty(ED2->ED2_SEQMI)
                  ED4->ED4_SEQMI := ED2->ED2_SEQMI
                  ED2->ED2_SEQMI := ""
               Else
                  ED4->ED4_SEQMI:= StrZero(cSeqMiAux,4,0)
               EndIf
               cSeqMiAux += 1

            Else

               If !Empty(ED2->ED2_SEQSIS)
                  ED4->ED4_SEQSIS := ED2->ED2_SEQSIS
                  ED2->ED2_SEQSIS := ""
               Else
                  ED4->ED4_SEQSIS := StrZero(cSeqSisAux,3,0)
               EndIf
               cSeqSisAux += 1

            EndIf

            ED4->ED4_AC:=""
            ED4->ED4_PD:=cPedido
            ED4->ED4_FILIAL := cFilED4
            ED4->ED4_DT_VAL := dDt_Val
            ED4->ED4_CNPJIM := cCGC

            //wfs 18/12/13
            If ED4->(FieldPos("ED4_IMPORT")) > 0
            	ED4->ED4_IMPORT:= cImport
            EndIf

            ED4->(msUnlock())

         EndIf
      EndIf

      WorkED2->(dbSkip())
   EndDo

   /*dbSelectArea("WorkED4")
   WorkED4->(dbGoTop())
   Do While !WorkED4->(EOF())
      IncProc(STR0029) //"Gravando Itens a Importar"
      ED4->(RecLock("ED4",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         ED4->&(cCampo) := WorkED4->&(cCampo)
      NEXT i
      ED4->ED4_AC:=""
      ED4->ED4_PD:=cPedido
      ED4->(msUnlock())
      WorkED4->(dbSkip())
   EndDo*/

   dbSelectArea("WorkEDA")
   WorkEDA->(dbGoTop())
   Do While !WorkEDA->(EOF())
      IncProc(STR0200) //"Gravando Resumo de Estruturas"
      EDA->(RecLock("EDA",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         EDA->&(cCampo) := WorkEDA->&(cCampo)
      NEXT i
      EDA->EDA_FILIAL := xFilial("EDA") // AST - 12/09/08
      EDA->EDA_PD:=cPedido
      EDA->(msUnlock())
      WorkEDA->(dbSkip())
   EndDo

   dbSelectArea("WorkEDB")
   WorkEDB->(dbGoTop())
   Do While !WorkEDB->(EOF())
      IncProc(STR0256) //"Gravando C.N.P.J's"
      EDB->(RecLock("EDB",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         EDB->&(cCampo) := WorkEDB->&(cCampo)
      NEXT i
      EDB->EDB_PD:=cPedido
      EDB->(msUnlock())
      WorkEDB->(dbSkip())
   EndDo

   dbSelectArea("WorkEDC")
   WorkEDC->(dbGoTop())
   Do While !WorkEDC->(EOF())
      IncProc(STR0200) //"Gravando Resumo de Estruturas"
      EDC->(RecLock("EDC",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         EDC->&(cCampo) := WorkEDC->&(cCampo)
      NEXT i
      EDC->EDC_FILIAL := xFilial("EDC") // AST - 12/09/08
      EDC->EDC_PD:=cPedido
      EDC->(msUnlock())
      WorkEDC->(dbSkip())
   EndDo

EndIf

End TransAction

Return .T.

*--------------------------*
Function AC400Works(lCopiaX)
*--------------------------*
Local FileWork1, FileWork2, FileWork3, FileWork4, FileWork5, FileWork6
Local FileWork7, FileWork8, FileWork9, FileWork10, FileWork11, FileWork12
Local FileWork13, FileWork14, FileWork15, FileWork16, FileWork17, FileWork18
Local FileWork19, FileWork20, FileWork21, FileWork22, FileWork23, FileWork24
Local FileWork25, FileWork26, FileWork27, FileWork28, FileWork30, FileWork31, FileWork32, FileWork33, FileWork34, FileWork35
Local FileWork36, FileWork37 //Arquivo referente a work de baixa de Insumos - AOM - 28/10/10
Local aSemSX3ED0:={}, aSemSX3ED1:={}, aSemSX3ED3:={}, aSemSX3ED4:={}
Local aSemSX3EDA:={}, aSemSX3EDB:={}, aSemSX3EDC:={}, aSemSX3EDF:={}
Local aSemSX3EDD := {}// AOM - 28/10/10
Local lCopia:=If(lCopiax<>NIL,lCopiax,.F.), i
Private aHeader[0], aCampos:=Array(ED1->(fCount()))  //E_CriaTrab utiliza
Private aSemSX3ED2:={}

If !lCopia
   ProcRegua(11)
Else
   ProcRegua(2)
EndIf

AADD(aSemSX3ED1,{"ED1_FILIAL","C",AVSX3("ED1_FILIAL",3),0})
AADD(aSemSX3ED1,{"ED1_PESO","N",AVSX3("ED1_PESO",3),AVSX3("ED1_PESO",4)})
AADD(aSemSX3ED1,{"ED1_PD","C",AVSX3("ED1_PD",3),0})
AADD(aSemSX3ED1,{"ED1_DESCPD","C",AVSX3("B1_DESC",3),0}) // AOM - 26/05/2010
AADD(aSemSX3ED1,{"ED1_DTRE","D",8,0})
AADD(aSemSX3ED1,{"ED1_DTEMBA","D",8,0})
AADD(aSemSX3ED1,{"ED1_AC","C",AVSX3("ED1_AC",3),0})
AADD(aSemSX3ED1,{"ED1_MOEDA","C",AVSX3("ED1_MOEDA",3),0})
AADD(aSemSX3ED1,{"ED1_TX_USS","N",AVSX3("ED1_TX_USS",3),AVSX3("ED1_TX_USS",4)})
AADD(aSemSX3ED1,{"ED1_PEDIDO","C",AVSX3("ED1_PEDIDO",3),0})
AADD(aSemSX3ED1,{"ED1_SEQ","C",AVSX3("ED1_SEQ",3),0})
AADD(aSemSX3ED1,{"ED1_TX_MOE","N",AVSX3("ED1_TX_MOE",3),AVSX3("ED1_TX_MOE",4)})
AADD(aSemSX3ED1,{"ED1_UMNCM","C",AVSX3("ED1_UMNCM",3),0})
if lED1Umanex   // ACSJ - Verifica existencia do Campo no SX3 - 17/11/2004
   AADD(aSemSX3ED1,{"ED1_UMANEX","C",AVSX3("ED1_UMANEX",3),0})
Endif
AADD(aSemSX3ED1,{"ED1_SEQUEN","C",AVSX3("ED1_SEQUEN",3),0})
AADD(aSemSX3ED1,{"ED1_QTDNCM","N",AVSX3("ED1_QTDNCM",3),AVSX3("ED1_QTDNCM",4)})
AADD(aSemSX3ED1,{"ED1_PREEMB","C",AVSX3("ED1_PREEMB",3),0})
AADD(aSemSX3ED1,{"ED1_RECNO" ,"N",10,0})
AADD(aSemSX3ED1,{"ED1_RE","C",AVSX3("ED1_RE",3),0})
AADD(aSemSX3ED1,{"ED1_VL_MOE","N",AVSX3("ED1_VL_MOE",3),AVSX3("ED1_VL_MOE",4)})
AADD(aSemSX3ED1,{"ED1_QTDORI","N",AVSX3("ED1_QTDORI",3),AVSX3("ED1_QTDORI",4)})
AADD(aSemSX3ED1,{"ED1_COEF","N",AVSX3("ED1_COEF",3),AVSX3("ED1_COEF",4)})
AADD(aSemSX3ED1,{"ED1_ANEXO","C",AVSX3("ED1_ANEXO",3),AVSX3("ED1_ANEXO",4)})
AADD(aSemSX3ED1,{"ED1_VALORI","N",AVSX3("ED1_VALORI",3),AVSX3("ED1_VALORI",4)})
AADD(aSemSX3ED1,{"ED1_COEFEC","N",AVSX3("ED1_COEFEC",3),AVSX3("ED1_COEFEC",4)}) // A. Caetano - ACSJ - 04/03/2004
//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemSX3ED1,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3ED1,{"TRB_REC_WT","N",10,0})
// AAF 26/12/05 - NCM Antiga.
If ED1->( FieldPos("ED1_NCMANT") ) > 0
   AADD(aSemSX3ED1,{"ED1_NCMANT",AVSX3("ED1_NCMANT",2),AVSX3("ED1_NCMANT",3),AVSX3("ED1_NCMANT",4)})
EndIf
If ED1->( FieldPos("ED1_FILORI") ) > 0  //lMultiFil
   AAdd(aSemSX3ED1,{"ED1_FILORI",AVSX3("ED1_FILORI",2),AVSX3("ED1_FILORI",3)+18,AVSX3("ED1_FILORI",4)})
EndIf

AADD(aSemSX3ED2,{"ED2_PD","C",AVSX3("ED2_PD",3),0})
AADD(aSemSX3ED2,{"ED2_DESCPD","C",AVSX3("B1_DESC",3),0})//AOM - 26/05/2010
AADD(aSemSX3ED2,{"ED2_DESCIT","C",AVSX3("B1_DESC",3),0})//AOM - 26/05/2010
AADD(aSemSX3ED2,{"ED2_INVOIC","C",AVSX3("ED2_INVOIC",3),0})
AADD(aSemSX3ED2,{"ED2_AC","C",AVSX3("ED2_AC",3),0})
AADD(aSemSX3ED2,{"ED2_DI_NUM","C",AVSX3("ED2_DI_NUM",3),0})
AADD(aSemSX3ED2,{"ED2_UMNCM","C",AVSX3("ED2_UMNCM",3),0})
if lED2Umanex   // ACSJ - Verifica existencia do Campo no SX3 - 17/11/2004
   AADD(aSemSX3ED2,{"ED2_UMANEX","C",AVSX3("ED2_UMANEX",3),0})
Endif
//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemSX3ED2,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3ED2,{"TRB_REC_WT","N",10,0})
AADD(aSemSX3ED2,{"ED2_PESO","N",AVSX3("ED2_QTDNCM",3),AVSX3("ED2_QTDNCM",4)}) //TAN AADD(aSemSX3ED2,{"ED2_PESO","N",AVSX3("ED2_PESO",3),AVSX3("ED2_PESO",4)})
AADD(aSemSX3ED2,{"ED2_SEQ","C",AVSX3("ED2_SEQ",3),0})
AADD(aSemSX3ED2,{"ED2_PGI_NU","C",AVSX3("ED2_PGI_NU",3),0})
AADD(aSemSX3ED2,{"ED2_ADICAO","C",AVSX3("ED2_ADICAO",3),0})
AADD(aSemSX3ED2,{"ED2_MOEDA","C",AVSX3("ED2_MOEDA",3),0})
AADD(aSemSX3ED2,{"ED2_MARCA","C",2,0})
AADD(aSemSX3ED2,{"ED2_TX_MOE","N",AVSX3("ED2_TX_MOE",3),AVSX3("ED2_TX_MOE",4)})
AADD(aSemSX3ED2,{"ED2_RECNO" ,"N",10,0})
AADD(aSemSX3ED2,{"ED2_POSICA","C",AVSX3("ED2_POSICA",3),0})
AADD(aSemSX3ED2,{"ED2_DTREG","D",8,0})
AADD(aSemSX3ED2,{"ED2_TX_USS","N",AVSX3("ED2_TX_USS",3),AVSX3("ED2_TX_USS",4)})
AADD(aSemSX3ED2,{"ED2_HAWB","C",AVSX3("ED2_HAWB",3),0})
AADD(aSemSX3ED2,{"ED2_QTDNCM","N",AVSX3("ED2_QTDNCM",3),AVSX3("ED2_QTDNCM",4)})
AADD(aSemSX3ED2,{"ED2_VL_MOE","N",AVSX3("ED2_VL_MOE",3),AVSX3("ED2_VL_MOE",4)})
AADD(aSemSX3ED2,{"ED2_PO_NUM","C",AVSX3("ED2_PO_NUM",3),0})
AADD(aSemSX3ED2,{"ED2_FILIAL","C",FWSizeFilial(),0})
AADD(aSemSX3ED2,{"ED2_VALORI","N",AVSX3("ED2_VALORI",3),AVSX3("ED2_VALORI",4)})
AADD(aSemSX3ED2,{"ED2_SEQSIS","C",AVSX3("ED2_SEQSIS",3),0})

//AOM - 11/11/11
If AvFlags("SEQMI")
   AADD(aSemSX3ED2,{"ED2_SEQMI","C",AVSX3("ED2_SEQMI",3),AVSX3("ED2_SEQMI",4)})
EndIf

//AAF 07/12/04 - Verifica se o campo é usado antes de adicionar no array. Para resolver QNC 003353\2004
If !X3Uso(Posicione("SX3",2,"ED2_FRETE","X3_USADO"))
   AADD(aSemSX3ED2,{"ED2_FRETE","N",AVSX3("ED2_FRETE",3),AVSX3("ED2_FRETE",4)})
Endif

AADD(aSemSX3ED2,{"ED2_FR_USS","N",AVSX3("ED2_FR_USS",3),AVSX3("ED2_FR_USS",4)})
AADD(aSemSX3ED2,{"ED2_MOE_FR","C",AVSX3("ED2_MOE_FR",3),0})
AADD(aSemSX3ED2,{"ED2_TX_FR","N",AVSX3("ED2_TX_FR",3),AVSX3("ED2_TX_FR",4)})
AADD(aSemSX3ED2,{"ED2_SEGURO","N",AVSX3("ED2_SEGURO",3),AVSX3("ED2_SEGURO",4)})
AADD(aSemSX3ED2,{"ED2_SE_USS","N",AVSX3("ED2_SE_USS",3),AVSX3("ED2_SE_USS",4)})
AADD(aSemSX3ED2,{"ED2_MOE_SE","C",AVSX3("ED2_MOE_SE",3),0})
AADD(aSemSX3ED2,{"ED2_TX_SE","N",AVSX3("ED2_TX_SE",3),AVSX3("ED2_TX_SE",4)})
AADD(aSemSX3ED2,{"ED2_RE","C",AVSX3("ED2_RE",3),0})
if lED2DT_NF   // ACSJ - 17/11/2004
   AADD(aSemSX3ED2,{"ED2_DT_NF","D",8,0})
Endif
If lED2Coef
   AADD(aSemSX3ED2,{"ED2_COEFEC","N",AVSX3("ED2_COEFEC",3),AVSX3("ED2_COEFEC",4)}) // A. Caetano - ACSJ - 04/03/2004
EndIf

// AAF 26/12/05 - NCM Antiga.
If ED2->( FieldPos("ED2_NCMANT") ) > 0
   AADD(aSemSX3ED2,{"ED2_NCMANT",AVSX3("ED2_NCMANT",2),AVSX3("ED2_NCMANT",3),AVSX3("ED2_NCMANT",4)})
EndIf
If ED2->( FieldPos("ED2_FILORI") ) > 0  //lMultiFil
   AAdd(aSemSX3ED2,{"ED2_FILORI",AVSX3("ED2_FILORI",2),AVSX3("ED2_FILORI",3)+18,AVSX3("ED2_FILORI",4)})
EndIf

//AOM - 23/03/2012 - DI Original
If AVFLAGS("DI_ORIGINAL")
   AADD(aSemSX3ED2,{"ED2_PDANT"  ,AVSX3("ED2_PDANT"  ,2),AVSX3("ED2_PDANT"  ,3),AVSX3("ED2_PDANT"  ,4)})
   AADD(aSemSX3ED2,{"ED2_SEQANT" ,AVSX3("ED2_SEQANT" ,2),AVSX3("ED2_SEQANT" ,3),AVSX3("ED2_SEQANT" ,4)})
   AADD(aSemSX3ED2,{"ED2_ADANT"  ,AVSX3("ED2_ADANT"  ,2),AVSX3("ED2_ADANT"  ,3),AVSX3("ED2_ADANT"  ,4)})
   AADD(aSemSX3ED2,{"ED2_SLDANT" ,AVSX3("ED2_SLDANT" ,2),AVSX3("ED2_SLDANT" ,3),AVSX3("ED2_SLDANT" ,4)})
   AADD(aSemSX3ED2,{"ED2_SEQIT"  ,AVSX3("ED2_SEQIT"  ,2),AVSX3("ED2_SEQIT"  ,3),AVSX3("ED2_SEQIT"  ,4)})
   AADD(aSemSX3ED2,{"ED2_DI_ORI" ,AVSX3("ED2_DI_ORI" ,2),AVSX3("ED2_DI_ORI" ,3),AVSX3("ED2_DI_ORI" ,4)})
ENDIF
// *** GFP - 30/08/2011 - Campos de NF.
If AvFlags("COMPRAS NACIONAIS")
   If ChkFile("ED8")
      If(ED2->(FieldPos("ED2_NF"))    > 0, aAdd(aSemSX3ED2,{"ED2_NF"   ,"C",AVSX3("ED2_NF",3)   ,AVSX3("ED2_NF",4)})   ,)
      If(ED2->(FieldPos("ED2_SERIE")) > 0, aAdd(aSemSX3ED2,{"ED2_SERIE","C",AVSX3("ED2_SERIE",3),AVSX3("ED2_SERIE",4)}),)
      If(ED2->(FieldPos("ED2_FORN"))  > 0, aAdd(aSemSX3ED2,{"ED2_FORN" ,"C",AVSX3("ED2_FORN",3) ,AVSX3("ED2_FORN",4)}) ,)
      If(ED2->(FieldPos("ED2_LOJA"))  > 0, aAdd(aSemSX3ED2,{"ED2_LOJA" ,"C",AVSX3("ED2_LOJA",3) ,AVSX3("ED2_LOJA",4)}) ,)
   EndIf
EndIf

//AOM - 14/03/2012
If ED2->(FieldPos("ED2_DTRE"))  > 0
   AAdd(aSemSX3ED2,{"ED2_DTRE",AVSX3("ED2_DTRE",2),AVSX3("ED2_DTRE",3)+18,AVSX3("ED2_DTRE",4)})
EndIf

//AOM - 14/03/2012
If ED2->(FieldPos("ED2_DTEMB"))  > 0
   AAdd(aSemSX3ED2,{"ED2_DTEMB",AVSX3("ED2_DTEMB",2),AVSX3("ED2_DTEMB",3)+18,AVSX3("ED2_DTEMB",4)})
EndIf

If ED2->(FieldPos("ED2_DTRE"))  > 0
   AAdd(aSemSX3ED2,{"ED2_DTRE",AVSX3("ED2_DTRE",2),AVSX3("ED2_DTRE",3)+18,AVSX3("ED2_DTRE",4)})
EndIf


AADD(aSemSX3ED3,{"ED3_RECNO" ,"N",10,0})
AADD(aSemSX3ED3,{"ED3_ANEXO","C",AVSX3("ED3_ANEXO",3),AVSX3("ED3_ANEXO",4)})
AADD(aSemSX3ED3,{"ED3_PESO","N",AVSX3("ED3_PESO",3),AVSX3("ED3_PESO",4)})
//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemSX3ED3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3ED3,{"TRB_REC_WT","N",10,0})
AADD(aSemSX3ED3,{"ED3_DESCPD","C",AVSX3("B1_DESC",3),0}) //AOM - 26/05/2010


AADD(aSemSX3ED4,{"ED4_RECNO" ,"N",10,0})
AADD(aSemSX3ED4,{"ED4_ANEXO","C",AVSX3("ED4_ANEXO",3),AVSX3("ED4_ANEXO",4)})
AADD(aSemSX3ED4,{"ED4_PESO","N",AVSX3("ED4_PESO",3),AVSX3("ED4_PESO",4)})
AADD(aSemSX3ED4,{"QTD_ESTRUT","N",AVSX3("ED4_QTD",3),AVSX3("ED4_QTD",4)})
AADD(aSemSX3ED4,{"ED4_NCMANT",AVSX3("ED4_NCM",2),AVSX3("ED4_NCM",3),AVSX3("ED4_NCM",4)})
//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemSX3ED4,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3ED4,{"TRB_REC_WT","N",10,0})
AADD(aSemSX3ED4,{"ED4_DESCIT","C",AVSX3("B1_DESC",3),0})  //AOM - 26/05/2010


AADD(aSemSX3EDA,{"EDA_RECNO" ,"N",10,0})
//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemSX3EDA,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3EDA,{"TRB_REC_WT","N",10,0})
AADD(aSemSX3EDA,{"EDA_DESCIT","C",AVSX3("B1_DESC",3),0}) //AOM - 26/05/2010

AADD(aSemSX3EDB,{"EDB_RECNO" ,"N",10,0})
//AOM - 09/04/2012
IF EDC->(FieldPos("EDC_QTDBAS")) > 0
   AADD(aSemSX3EDC,{"EDC_QTDBAS","C",AVSX3("EDC_QTDBAS",3),AVSX3("EDC_QTDBAS",4)})
ENDIF
//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemSX3EDB,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3EDB,{"TRB_REC_WT","N",10,0})

AADD(aSemSX3EDC,{"EDC_RECNO" ,"N",10,0})
//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemSX3EDC,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3EDC,{"TRB_REC_WT","N",10,0})
AADD(aSemSX3EDC,{"EDC_DESCIT","C",AVSX3("B1_DESC",3),0}) //AOM - 26/05/2010
AADD(aSemSX3EDC,{"EDC_DESCPD","C",AVSX3("B1_DESC",3),0}) //AOM - 26/05/2010

//AOM - 28/10/10 - Campos da Baixa de Insumos - para tabelas EDD e EDH
AADD(aSemSX3EDD,{"SEQSII",AVSX3("EDD_SEQSII",2),AVSX3("EDD_SEQSII",3),AVSX3("EDD_SEQSII",4)}) //Seqüência de Saldo de Importação
If AvFlags("SEQMI")
   AADD(aSemSX3EDD,{"SEQMI",AVSX3("EDD_SEQMI",2),AVSX3("EDD_SEQMI",3),AVSX3("EDD_SEQMI",4)})
EndIf
AADD(aSemSX3EDD,{"ITEM"  ,AVSX3("EDD_ITEM",2)  ,AVSX3("EDD_ITEM",3)  ,AVSX3("EDD_ITEM",4)  }) //Código do Item
AADD(aSemSX3EDD,{"TPOCOR","C"                  ,30                   ,0                    }) //Tipo de Ocorrência
AADD(aSemSX3EDD,{"CODOCO",AVSX3("EDD_PREEMB",2),AVSX3("EDD_PREEMB",3),AVSX3("EDD_PREEMB",4)}) //Cód. Ocorrência
AADD(aSemSX3EDD,{"DTOCOR",AVSX3("EDD_DTRE",2)  ,AVSX3("EDD_DTRE",3)  ,AVSX3("EDD_DTRE",4)  }) //Data Ocorrência
AADD(aSemSX3EDD,{"RESOCO","C"                  ,60                   ,0                    }) //Resumo da Ocorrência
AADD(aSemSX3EDD,{"UNIDME",AVSX3("ED4_UMITEM",2),AVSX3("ED4_UMITEM",3),AVSX3("ED4_UMITEM",4)}) //Unidade de Medida
AADD(aSemSX3EDD,{"QTD"   ,AVSX3("EDD_QTD",2)   ,AVSX3("EDD_QTD",3)   ,AVSX3("EDD_QTD",4)   }) //Quantidade Envolvida
AADD(aSemSX3EDD,{"VALOR" ,AVSX3("W8_VL_AC",2)  ,AVSX3("W8_VL_AC",3)  ,AVSX3("W8_VL_AC",4)  }) //Valor Envolvido US$
AADD(aSemSX3EDD,{"HAWB"  ,AVSX3("EDD_HAWB",2)  ,AVSX3("EDD_HAWB",3)  ,AVSX3("EDD_HAWB",4)  }) //Numero do Processo Importação
AADD(aSemSX3EDD,{"NRDI"  ,AVSX3("W6_DI_NUM",2) ,AVSX3("W6_DI_NUM",3) ,AVSX3("W6_DI_NUM",4) }) //Numero da DI
AADD(aSemSX3EDD,{"DTDI"  ,AVSX3("EDD_DTREG",2) ,AVSX3("EDD_DTREG",3) ,AVSX3("EDD_DTREG",4) }) //Data da DI
AADD(aSemSX3EDD,{"CDFORN",AVSX3("W8_FORN",2)   ,AVSX3("W8_FORN",3)   ,AVSX3("W8_FORN",4)   }) //Código do Fornecedor
AADD(aSemSX3EDD,{"LOJA"  ,"C"                  ,02                   ,0                    }) //Loja
AADD(aSemSX3EDD,{"NRINV" ,AVSX3("EDD_INVOIC",2),AVSX3("EDD_INVOIC",3),AVSX3("EDD_INVOIC",4)}) //Numero da Invoice
AADD(aSemSX3EDD,{"NRRE"  ,AVSX3("EE9_RE",2)    ,/*AVSX3("EE9_RE",3)*/ 14,AVSX3("EE9_RE",4)    }) //Numero de RE - tamanho fixado para 14, para atender à DUe
AADD(aSemSX3EDD,{"CDEMB" ,AVSX3("EDD_PREEMB",2),AVSX3("EDD_PREEMB",3),AVSX3("EDD_PREEMB",4)}) //Cód. Embarque
AADD(aSemSX3EDD,{"CDPED" ,AVSX3("EDD_PEDIDO",2),AVSX3("EDD_PEDIDO",3),AVSX3("EDD_PEDIDO",4)    }) //Pedido
AADD(aSemSX3EDD,{"ITEMB" ,AVSX3("EE9_SEQEMB",2),AVSX3("EE9_SEQEMB",3),AVSX3("EE9_SEQEMB",4)}) //Item Embarque
AADD(aSemSX3EDD,{"PRODEX",AVSX3("EDD_PROD",2)  ,AVSX3("EDD_PROD",3  ),AVSX3("EDD_PROD",4)  }) //Prod. Exportado
AADD(aSemSX3EDD,{"UMPROD",AVSX3("ED3_UMPROD",2),AVSX3("ED3_UMPROD",3),AVSX3("ED3_UMPROD",4)}) //Unidade de Medida do produto
AADD(aSemSX3EDD,{"QTDEX" ,AVSX3("EDD_QTD_EX",2),AVSX3("EDD_QTD_EX",3),AVSX3("EDD_QTD_EX",4)}) //Quantidade Exportada

If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"aSemSX3"),)

If !lCopia
   //WorkED1
   IncProc(STR0030+"1") //"Criando Arquivo Temporario "
   FileWork1:=E_CriaTrab("ED1",aSemSX3ED1,"WorkED1",,.F.)
   Aadd(aTabelas,{"WorkED1",FileWork1})
   FileWork2:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork2})
   FileWork3:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork3})
   FileWork13:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork13})
   FileWork16:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork16})
   FileWork23:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork23})
   FileWork26:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork26})
   FileWork31:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork31})

   IncProc(STR0030+"1") //"Criando Arquivo Temporario "
   IndRegua("WorkED1",FileWork1+TEOrdBagExt(),"ED1_PD+ED1_AC+ED1_PROD+ED1_SEQ")
   IndRegua("WorkED1",FileWork2+TEOrdBagExt(),"ED1_PD+ED1_AC+ED1_SEQ")
   IndRegua("WorkED1",FileWork3+TEOrdBagExt(),"ED1_PREEMB+ED1_PEDIDO+ED1_SEQUEN")
   IndRegua("WorkED1",FileWork13+TEOrdBagExt(),"ED1_RE+ED1_PROD")
   IndRegua("WorkED1",FileWork16+TEOrdBagExt(),"ED1_NCM+DTOS(ED1_DTEMBA)+ED1_RE+ED1_PROD")
   IndRegua("WorkED1",FileWork23+TEOrdBagExt(),"ED1_PROD+ED1_RE")
   IndRegua("WorkED1",FileWork26+TEOrdBagExt(),"ED1_PD+ED1_ANEXO")

   If lIndPercAg
      cChaveED1 := "ED1_NCM+ED1_PROD+Str(ED1_PERCAG,5,2)"
   Else
      cChaveED1 := "ED1_NCM+ED1_PROD"
   EndIf

   IndRegua("WorkED1",FileWork31+TEOrdBagExt(),cChaveED1)

   SET INDEX TO (FileWork1+TEOrdBagExt()),(FileWork2+TEOrdBagExt()),(FileWork3+TEOrdBagExt()),(FileWork13+TEOrdBagExt()),(FileWork16+TEOrdBagExt()),(FileWork23+TEOrdBagExt()),(FileWork26+TEOrdBagExt()),(FileWork31+TEOrdBagExt())

   //WorkED2
   IncProc(STR0030+"2") //"Criando Arquivo Temporario "
   FileWork4:=E_CriaTrab("ED2",aSemSX3ED2,"WorkED2",,.F.)
   Aadd(aTabelas,{"WorkED2",FileWork4})
   FileWork5:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork5})
   FileWork6:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork6})
   FileWork8:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork8})
   FileWork19:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork19})
   FileWork24:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork24})
   FileWork25:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork25})
   FileWork30:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork30})
   If AVFLAGS("DI_ORIGINAL")
      FileWork36:=E_Create(,.F.)
      Aadd(aTabelas,{,FileWork36})
   EndIf

   IncProc(STR0030+"2") //"Criando Arquivo Temporario "
   IndRegua("WorkED2",FileWork4+TEOrdBagExt(),"ED2_PD+ED2_AC+ED2_ITEM+ED2_SEQ")
   IndRegua("WorkED2",FileWork5+TEOrdBagExt(),"ED2_PROD+ED2_SEQ")
   IndRegua("WorkED2",FileWork6+TEOrdBagExt(),"ED2_NCM")
   IndRegua("WorkED2",FileWork8+TEOrdBagExt(),"ED2_HAWB+ED2_INVOIC+ED2_PO_NUM+ED2_POSICA+ED2_PGI_NU")
   IndRegua("WorkED2",FileWork19+TEOrdBagExt(),"ED2_DI_NUM+ED2_ITEM+DtoS(ED2_DTREG)")
   IndRegua("WorkED2",FileWork24+TEOrdBagExt(),"ED2_RE+ED2_PROD+ED2_ITEM+ED2_DI_NUM")
   IndRegua("WorkED2",FileWork25+TEOrdBagExt(),"ED2_ITEM+DtoS(ED2_DTREG)")
   IndRegua("WorkED2",FileWork30+TEOrdBagExt(),"ED2_NCM+ED2_ITEM+ED2_CAMB+STR(ED2_PERCPE,5,2)")
   //AOM - 23/03/2012
   IF AVFLAGS("DI_ORIGINAL")
      IndRegua("WorkED2",FileWork36+TEOrdBagExt(),"ED2_PD+ED2_SEQIT")
   EndIf

   //AOM - 23/03/2012
   IF AVFLAGS("DI_ORIGINAL")
      SET INDEX TO (FileWork4+TEOrdBagExt()),(FileWork5+TEOrdBagExt()),(FileWork6+TEOrdBagExt()),(FileWork8+TEOrdBagExt()),(FileWork19+TEOrdBagExt()),(FileWork24+TEOrdBagExt()),(FileWork25+TEOrdBagExt()),(FileWork30+TEOrdBagExt()),(FileWork36+TEOrdBagExt())
   ELSE
      SET INDEX TO (FileWork4+TEOrdBagExt()),(FileWork5+TEOrdBagExt()),(FileWork6+TEOrdBagExt()),(FileWork8+TEOrdBagExt()),(FileWork19+TEOrdBagExt()),(FileWork24+TEOrdBagExt()),(FileWork25+TEOrdBagExt()),(FileWork30+TEOrdBagExt())
   ENDIF

   //WorkED3
   IncProc(STR0030+"3") //"Criando Arquivo Temporario "
   FileWork9:=E_CriaTrab("ED3",aSemSX3ED3,"WorkED3",,.F.)
   Aadd(aTabelas,{"WorkED3",FileWork9})
   FileWork10:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork10})
   FileWork15:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork15})
   FileWork27:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork27})

   If lIndPercAg
      cChaveED3 := "ED3_NCM+ED3_PROD+Str(ED3_PERCAG,5,2)+ED3_UMNCM"
   Else
      cChaveED3 := "ED3_NCM+ED3_PROD+ED3_UMNCM"
   EndIf

   IncProc(STR0030+"3") //"Criando Arquivo Temporario "
   IndRegua("WorkED3",FileWork9+TEOrdBagExt() ,cChaveED3)
   IndRegua("WorkED3",FileWork10+TEOrdBagExt(),"ED3_SEQSIS")
   IndRegua("WorkED3",FileWork15+TEOrdBagExt(),"ED3_ANEXO")
   IndRegua("WorkED3",FileWork27+TEOrdBagExt(),"ED3_PD+ED3_ANEXO")

   SET INDEX TO (FileWork9+TEOrdBagExt()),(FileWork10+TEOrdBagExt()),(FileWork15+TEOrdBagExt()), (FileWork27+TEOrdBagExt())

   //WorkED4
   IncProc(STR0030+"4") //"Criando Arquivo Temporario "
   FileWork11:=E_CriaTrab("ED4",aSemSX3ED4,"WorkED4",,.F.)
   Aadd(aTabelas,{"WorkED4",FileWork11})
   FileWork7:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork7})
   FileWork14:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork14})
   FileWork28:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork28})
   FileWork35:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork35})
   If AvFlags("SEQMI")
      FileWork37 :=E_Create(,.F.)
      Aadd(aTabelas,{,FileWork37})
   EndIf


   IncProc(STR0030+"4") //"Criando Arquivo Temporario "
   If AvFlags("SEQMI")
      IndRegua("WorkED4",FileWork11+TEOrdBagExt(),"ED4_NCM+ED4_ITEM+ED4_CAMB+Str(ED4_PERCPE,5,2)+ED4_UMNCM+ED4_IMPORT")
      IndRegua("WorkED4",FileWork35+TEOrdBagExt(),"ED4_NCM+ED4_ITEM+ED4_CAMB+ED4_UMNCM+ED4_IMPORT")
      IndRegua("WorkED4",FileWork37+TEOrdBagExt(),"ED4_SEQMI")
   Else
      IndRegua("WorkED4",FileWork11+TEOrdBagExt(),"ED4_NCM+ED4_ITEM+ED4_CAMB+Str(ED4_PERCPE,5,2)+ED4_UMNCM")
      IndRegua("WorkED4",FileWork35+TEOrdBagExt(),"ED4_NCM+ED4_ITEM+ED4_CAMB+ED4_UMNCM")
   EndIf
   IndRegua("WorkED4",FileWork7+TEOrdBagExt(),"ED4_SEQSIS")
   IndRegua("WorkED4",FileWork14+TEOrdBagExt(),"ED4_ANEXO")
   IndRegua("WorkED4",FileWork28+TEOrdBagExt(),"ED4_PD+ED4_ANEXO")

   If AvFlags("SEQMI")
      SET INDEX TO (FileWork11+TEOrdBagExt()),(FileWork7+TEOrdBagExt()), (FileWork14+TEOrdBagExt()), (FileWork28+TEOrdBagExt()), (FileWork35+TEOrdBagExt()) ,(FileWork37+TEOrdBagExt())  //NCF-16/11/09
   Else
      SET INDEX TO (FileWork11+TEOrdBagExt()),(FileWork7+TEOrdBagExt()), (FileWork14+TEOrdBagExt()), (FileWork28+TEOrdBagExt()), (FileWork35+TEOrdBagExt())   //NCF-16/11/09
   EndIf

   //WorkEDA
   IncProc(STR0030+"5") //"Criando Arquivo Temporario "
   FileWork17:=E_CriaTrab("EDA",aSemSX3EDA,"WorkEDA",,.F.)
   Aadd(aTabelas,{"WorkEDA",FileWork17})

   IncProc(STR0030+"5") //"Criando Arquivo Temporario "
   IndRegua("WorkEDA",FileWork17+TEOrdBagExt(),"EDA_ITEM")

   SET INDEX TO (FileWork17+TEOrdBagExt())

   //WorkEDB
   IncProc(STR0030+"6") //"Criando Arquivo Temporario "
   FileWork18:=E_CriaTrab("EDB",aSemSX3EDB,"WorkEDB",,.F.)
   Aadd(aTabelas,{"WorkEDB",FileWork18})

   IncProc(STR0030+"6") //"Criando Arquivo Temporario "
   IndRegua("WorkEDB",FileWork18+TEOrdBagExt(),"EDB_IMPORT+EDB_CNPJ")

   SET INDEX TO (FileWork18+TEOrdBagExt())

   //WorkEDC
   IncProc(STR0030+"7") //"Criando Arquivo Temporario "
   FileWork20:=E_CriaTrab("EDC",aSemSX3EDC,"WorkEDC",,.F.)
   Aadd(aTabelas,{"WorkEDC",FileWork20})
   FileWork21:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork21})
   FileWork22:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWork22})

   IncProc(STR0030+"7") //"Criando Arquivo Temporario "
   IndRegua("WorkEDC",FileWork20+TEOrdBagExt(),"EDC_RE+EDC_PROD")
   IndRegua("WorkEDC",FileWork21+TEOrdBagExt(),"EDC_PROD+EDC_RE")
   IndRegua("WorkEDC",FileWork22+TEOrdBagExt(),"EDC_ITEM+EDC_RE+EDC_PROD")

   SET INDEX TO (FileWork20+TEOrdBagExt()),(FileWork21+TEOrdBagExt()),(FileWork22+TEOrdBagExt())

   If ChkFile("EDF",.F.)
      aCposEDF := {"EDF_TABELA","EDF_DESC","EDF_PROD","EDF_ITEM","EDF_SEQ"   ,"EDF_DI_NUM","EDF_POSDI" ,"EDF_INVOIC","EDF_PO_NUM","EDF_PGI_NU","EDF_RE",;
                   "EDF_NCM"   ,"EDF_TIPO","EDF_DATA","EDF_HORA","EDF_USUARI" ,"EDF_DESCAM","EDF_DE"    ,"EDF_PARA"}

      For i:= 1 To Len(aCposEDF)
         If !X3Uso(Posicione("SX3",2,aCposEDF[i],"X3_USADO"))
            aAdd(aSemSX3EDF,{aCposEDF[i],AvSx3(aCposEDF[i],2),AvSx3(aCposEDF[i],3),AvSx3(aCposEDF[i],4)})
         EndIf
      Next

      aAdd(aSemSX3EDF,{"EDF_RECNO" ,"N",10,0})
      //TRP - 01/02/07 - Campos do WalkThru
      AADD(aSemSX3EDF,{"TRB_ALI_WT","C",03,0})
      AADD(aSemSX3EDF,{"TRB_REC_WT","N",10,0})

      IncProc(STR0030+"8") //"Criando Arquivo Temporario "
      FileWork32:=E_CriaTrab("EDF",aSemSX3EDF,"WorkEDF",,.F.)
      Aadd(aTabelas,{"WorkEDF",FileWork32})

      FileWork33:=E_Create(,.F.)
      Aadd(aTabelas,{,FileWork33})
      FileWork34:=E_Create(,.F.)
      Aadd(aTabelas,{,FileWork34})

      IncProc(STR0030+"9") //"Criando Arquivo Temporario "
      IndRegua("WorkEDF",FileWork33+TEOrdBagExt(),"DToS(EDF_DATA)+EDF_HORA")

      dbSelectArea("WorkEDF")

      SET INDEX TO (FileWork33+TEOrdBagExt())
   EndIf

   //AOM -28/10/10 - Criando arquivo de trabalho para Aba Baixa Insumos
   //WorkEDD
   IncProc(STR0030+"10") //"Criando Arquivo Temporario "
   FileWork36:=E_CriaTrab("",aSemSX3EDD,"WorkEDD")
   Aadd(aTabelas,{"WorkEDD",FileWork36})

   IndRegua("WorkEDD",FileWork36+TEOrdBagExt(),"DTOCOR")

   dbSelectArea("WorkEDD")

   SET INDEX TO (FileWork36+TEOrdBagExt())


Else  //Cria Work do ED0 para Copia do Ato Concessorio

   AADD(aSemSX3ED0,{"ED0_CNPJ1","C",AVSX3("ED0_CNPJ1",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ2","C",AVSX3("ED0_CNPJ2",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ3","C",AVSX3("ED0_CNPJ3",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ4","C",AVSX3("ED0_CNPJ4",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ5","C",AVSX3("ED0_CNPJ5",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ6","C",AVSX3("ED0_CNPJ6",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ7","C",AVSX3("ED0_CNPJ7",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ8","C",AVSX3("ED0_CNPJ8",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ9","C",AVSX3("ED0_CNPJ9",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ10","C",AVSX3("ED0_CNPJ10",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ11","C",AVSX3("ED0_CNPJ11",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ12","C",AVSX3("ED0_CNPJ12",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ13","C",AVSX3("ED0_CNPJ13",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ14","C",AVSX3("ED0_CNPJ14",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ15","C",AVSX3("ED0_CNPJ15",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ16","C",AVSX3("ED0_CNPJ16",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ17","C",AVSX3("ED0_CNPJ17",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ18","C",AVSX3("ED0_CNPJ18",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ19","C",AVSX3("ED0_CNPJ19",3),0})
   AADD(aSemSX3ED0,{"ED0_CNPJ20","C",AVSX3("ED0_CNPJ20",3),0})

   IncProc(STR0030+"3") //"Criando Arquivo Temporario "
   FileWork12:=E_CriaTrab("ED0",aSemSX3ED0,"WorkED0",,.F.)
   Aadd(aTabelas,{"WorkED0",FileWork12})

   IncProc(STR0030+"3") //"Criando Arquivo Temporario "
   IndRegua("WorkED0",FileWork12+TEOrdBagExt(),"ED0_PD")

   SET INDEX TO (FileWork12+TEOrdBagExt())

EndIf

Return .T.

*-----------------------------*
Function AC400Valid(cNomeCampo)
*-----------------------------*
Local nRec, nValAux, i
LOCAL nPerda
Local aJaCompEst := {}  // PLB 09/11/06 - Utilizada para armazenar os produtos que já sofreram comparação de Estrutura
Local ni := 1 , aMsg := {} ,  aMsgAux := {}
Local nOrdED9 //igor chiba 07/04/09
Local cTexto := "" , cImport := ""
Private lRet := .T.
Private cCampo := cNomeCampo

If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"VALID"),)

Do Case
   Case cCampo == "ED0_DT_REG"
      If !Empty(M->ED0_DT_VA1) .and. M->ED0_DT_REG > M->ED0_DT_VA1
         Help(" ",1,"AVG0005113") //"Data de Registro nao pode ser maior que a Data de Validade."
         lRet := .F.
      ElseIf !Empty(M->ED0_DT_REG) .and. Empty(M->ED0_DT_VA1)
         M->ED0_DT_VA1 := M->ED0_DT_REG + If(M->ED0_MODAL == SUSPENSAO,EasyGParam("MV_DIASPRD",,180),EasyGParam("MV_DIASPRI",,365))
      ElseIf Empty(M->ED0_DT_REG)
         M->ED0_DT_VA1 := M->ED0_DT_REG
      EndIf

   Case cCampo == "ED0_DT_VA1"
      If !Empty(M->ED0_DT_VA2) .and. M->ED0_DT_VA1 > M->ED0_DT_VA2
         Help(" ",1,"AVG0005114") //"Data de Validade nao pode ser maior que a Data de Validade Após Embarque."
         lRet := .F.
      ElseIf M->ED0_DT_VA1 < M->ED0_DT_REG
         Help(" ",1,"AVG0005115") //"Data de Validade nao pode ser menor que a Data de Registro."
         lRet := .F.
      EndIf
   Case cCampo == "ED0_DT_VA2"
      If !Empty(M->ED0_DT_PR1) .and. M->ED0_DT_VA2 > M->ED0_DT_PR1
         Help(" ",1,"AVG0005116") //"Data de Validade Apos Embarque nao pode ser maior que a Data da 1a Prorrogacao."
         lRet := .F.
      ElseIf !Empty(M->ED0_DT_VA1) .and. M->ED0_DT_VA2 < M->ED0_DT_VA1
         Help(" ",1,"AVG0005117") //"Data de Validade Após Embarque nao pode ser menor que a Data de Validade."
         lRet := .F.
      EndIf
   Case cCampo == "ED0_DT_PR1"
      If Empty(M->ED0_DT_PR1) .and. M->ED0_PROAP1 = "1"
         Help(" ",1,"AVG0005118") //"Data não pode ser vazia pois prorrogação foi aprovada."
         lRet := .F.
      ElseIf !Empty(M->ED0_DT_PR2) .and. M->ED0_DT_PR2 < M->ED0_DT_PR1
         Help(" ",1,"AVG0005119") //"Data nao pode ser maior que a 2a prorrogacao."
         lRet := .F.
      ElseIf M->ED0_DT_PR1 < M->ED0_DT_VA2
         Help(" ",1,"AVG0005120") //"Data nao pode ser menor que a Data de Validade após Embarque."
         lRet := .F.
      EndIf
   Case cCampo == "ED0_DT_PR2"
      If Empty(M->ED0_DT_PR2) .and. M->ED0_PROAP2 = "1"
         Help(" ",1,"AVG0005118") //"Data não pode ser vazia pois prorrogação foi aprovada."
         lRet := .F.
      ElseIf M->ED0_DT_PR2 < M->ED0_DT_PR1
         Help(" ",1,"AVG0005121") //"Data nao pode ser menor que 1a prorrogacao."
         lRet := .F.
      ElseIf !Empty(M->ED0_DT_PR3) .and. M->ED0_DT_PR3 < M->ED0_DT_PR2
         Help(" ",1,"AVG0005122") //"Data nao pode ser maior que a 3a prorrogacao."
         lRet := .F.
      EndIf
   Case cCampo == "ED0_DT_PR3"
      If Empty(M->ED0_DT_PR3) .and. M->ED0_PROAP3 = "1"
         Help(" ",1,"AVG0005118") //"Data não pode ser vazia pois prorrogação foi aprovada."
         lRet := .F.
      ElseIf M->ED0_DT_PR3 < M->ED0_DT_PR2
         Help(" ",1,"AVG0005123") //"Data nao pode ser menor que 2a prorrogacao."
         lRet := .F.
      EndIf
   Case cCampo == "ED0_AC"
      WorkED4->(dbGoTop())
      If !Empty(M->ED0_AC)
         If M->ED0_MODAL == ISENCAO .and. Empty(WorkED4->ED4_ANEXO)
            Help("", 1, "AVG0005275") // AC. não pode ser preenchido. Para preencher o número do AC é necessário emitir o Pedido.
            lRet := .F.
         Else
            nRec := ED0->(RecNo())
            ED0->(dbSetOrder(2))
         If !Empty(M->ED0_AC) .and. ED0->(dbSeek(cFilED0+M->ED0_AC)) .and. ED0->ED0_PD <> M->ED0_PD
               Help("", 1, "AVG0005124",,Alltrim(ED0->ED0_PD),2,27) //"Este numero de Ato Concessorio esta sendo usado para o pedido " # "Entre com um numero valido."
               lRet := .F.
            EndIf
            ED0->(dbSetOrder(1))
            ED0->(dbGoTo(nRec))
         EndIf
      EndIf
   Case cCampo == "ED0_TIPOAC"
      If M->ED0_MODAL==ISENCAO .and. !M->ED0_TIPOAC $("01/02/03")
         Help(" ",1,"AVG0005125") //"Para Modalidade Isencao so sao aceitos Atos Concessorios do tipo Comum, Intermediario ou Solidario."
         lRet := .F.
      ElseIf !Empty(cTipoAC) .and. cTipoAC <> M->ED0_TIPOAC
         If !ExistCPO("SX5","CD"+M->ED0_TIPOAC)
            lRet := .F.
         ElseIf cTipoAC $("02/03") .and. !M->ED0_TIPOAC $("02/03")
            If !MsgYesNo(STR0046) //"Ao alterar o Tipo do A.C. os CNPJ´s auxiliares serao apagados. Confirma alteracao?"
               lRet := .F.
               M->ED0_TIPOAC := cTipoAC
            EndIf
         ElseIf cTipoAC == "03" .and. M->ED0_TIPOAC == "02"
            If !MsgYesNo(STR0047) //"Ao alterar o Tipo do A.C. os CNPJ´s auxiliares do 11 ao 20 serao apagados. Confirma alteracao?"
               lRet := .F.
               M->ED0_TIPOAC := cTipoAC
            EndIf
         EndIf
         If lRet
            If(M->ED0_TIPOAC=="02",nIni:=11,nIni:=1)
            If (M->ED0_TIPOAC<>"02" .and. M->ED0_TIPOAC<>"03") .or. M->ED0_TIPOAC<>"03"
               For i:=nIni to 20
                  M->&("ED0_CNPJ"+Alltrim(Str(i))) := Space(Len(ED0->ED0_CNPJ1))
               Next
            EndIf
         EndIf
      EndIf
      If lRet
         cTipoAC := M->ED0_TIPOAC
         If SX5->(dbSeek(cFilSX5+"CH"+M->ED0_TIPOAC))
            M->ED0_ENQCOD := Alltrim(SX5->X5_DESCRI)
         Else
            M->ED0_ENQCOD := ""
         EndIf
      EndIf
   Case cCampo == "ED0_IMPORT"
      If cFilSYT <> SYT->YT_FILIAL .or. M->ED0_IMPORT <> SYT->YT_COD_IMP
         SYT->(dbSeek(cFilSYT+M->ED0_IMPORT))
      EndIf
      If SYT->YT_IMP_CON <> "1"
         Help(" ",1,"AVG0005126") //"Codigo nao se refere a um importador."
         lRet := .F.
      EndIf
   Case Left(cCampo,8) == "ED0_CNPJ"
      If M->&(cCampo) == BuscaCNPJ(M->ED0_IMPORT,.T.)
         Help(" ",1,"AVG0005127") //"CNPJ nao pode ser igual ao CNPJ do Importador."
         lRet := .F.
      EndIf
      If lRet
         For i:=1 to 20
            If !cCampo=="ED0_CNPJ"+Alltrim(Str(i)) .and. M->&(cCampo)==M->&("ED0_CNPJ"+Alltrim(Str(i)))
               Help(" ",1,"AVG0005128") //"Nao podem haver CNPJs repetidos."
               lRet:=.F.
            EndIf
         Next
      EndIf
   Case cCampo == "ED0_FRETE"
      Tot_Imp -= nFrete
      Tot_Imp += M->ED0_FRETE
      nFrete  := M->ED0_FRETE
      RodapeTotais()
   Case cCampo == "ED0_SEGURO"
      Tot_Imp -= nSeguro
      Tot_Imp += M->ED0_SEGURO
      nSeguro := M->ED0_SEGURO
      RodapeTotais()
   Case cCampo == "ED0_PERCTO"
      If M->ED0_PERCTO > 100
         Help(" ",1,"AVG0005129") //"Percentual de Tolerancia nao pode ser maior que 100%."
         lRet := .F.
      Else
         nPercTo := M->ED0_PERCTO
         RodapeTotais()
      EndIf
   Case cCampo == "ED0_ENQCOD"
      lRet := .F.
      SX5->(dbSeek(cFilSX5+"CH"))
      Do While !SX5->(EOF()) .and. SX5->X5_TABELA == "CH"
         If Alltrim(SX5->X5_DESCRI) == M->ED0_ENQCOD
            lRet := .T.
            Exit
         EndIf
         SX5->(dbSkip())
      EndDo
      If !lRet
         Help(" ",1,"AVG0005130") //"Codigo de Enquadramento invalido. Selecione um codigo valido."
      EndIf
   Case cCampo == "ED1_PROD"
      If cFilSB1Aux <> (cAliasSB1)->B1_FILIAL .or. (cAliasSB1)->B1_COD <> M->ED1_PROD
         (cAliasSB1)->(dbSetOrder(1))
         (cAliasSB1)->(dbSeek(cFilSB1Aux+M->ED1_PROD))
      EndIf
      If cFilSYD <> SYD->YD_FILIAL .or. (cAliasSB1)->B1_POSIPI <> SYD->YD_TEC
         SYD->(dbSetOrder(1))
         SYD->(dbSeek(cFilSYD+(cAliasSB1)->B1_POSIPI))
      EndIf
      If !Empty(SYD->YD_UNID) .and. (nValAux:=AVTransUnid((cAliasSB1)->B1_UM,SYD->YD_UNID,M->ED1_PROD,M->ED1_QTD,.T.)) <> NIL
         M->ED1_UMPROD := (cAliasSB1)->B1_UM
         M->ED1_PRCUNI := (cAliasSB1)->B1_VLREFUS
         If(M->ED1_QTD<>0, M->ED1_VAL_EM := M->ED1_PRCUNI*M->ED1_QTD , M->ED1_VAL_EM := 0 )
         M->ED1_NCM    := (cAliasSB1)->B1_POSIPI
         If M->ED0_MODAL <> ISENCAO
            M->ED1_UMNCM  := SYD->YD_UNID
            /*If M->ED0_MODAL=="2" .and. M->ED1_QTDORI<>0
               nCoefAux := M->ED1_QTD / WorkED1->ED1_QTD
               M->ED1_QTDNCM := nCoefAux * WorkED1->ED1_QTDNCM
            Else
               M->ED1_QTDNCM := nValAux
            EndIf*/
         EndIf
      ElseIf Empty(SYD->YD_UNID)
         Help(" ",1,"AVG0005131") //"Produto nao pode ser selecionado pois sua NCM nao possui Unidade de Medida."
         lRet := .F.
      Else
         Help(" ",1,"AVG0005132",,"("+Alltrim((cAliasSB1)->B1_UM)+STR0054+Alltrim(SYD->YD_UNID)+").", 3,22) //"Produto nao pode ser selecionado pois nao existe conversao entre as Unidades de Medida do Produto (" # ") e da NCM ("
         lRet := .F.
      EndIf

      //AOM - 04/11/10
      If M->ED0_MODAL == "1" //Suspensao
         SG1->(DbSetOrder(1))
         If !(SG1->(DbSeek(xFilial("SG1") + AvKey(M->ED1_PROD,"G1_COD"))))
            lRet := .F.
            MsgInfo("O produto informado não possui estrutura, cadastre uma estrutura para o mesmo ou informe outro produto.","Aviso")
         EndIf
      EndIf
   Case Left(cCampo,10) == "ED1_VAL_EM"
      If (M->ED0_MODAL==ISENCAO .and. M->ED1_QTDORI=0)
         If( cCampo == "ED1_VAL_EM" , M->ED1_VALCOM := (M->ED1_VAL_EM * M->ED1_PERCAG)/100 ,)
         If M->ED1_QTDNCM <> 0
            M->ED1_PRCUNI := M->ED1_VAL_EM / M->ED1_QTDNCM
         ElseIf M->ED1_VAL_EM <> 0
            M->ED1_QTDNCM := M->ED1_VAL_EM / M->ED1_PRCUNI
            M->ED1_QTD    := WorkED1->ED1_QTD * (M->ED1_QTDNCM / WorkED1->ED1_QTDNCM)
         EndIf
      ElseIf M->ED0_MODAL<>ISENCAO
         If( cCampo == "ED1_VAL_EM" , M->ED1_VALCOM := (M->ED1_VAL_EM * M->ED1_PERCAG)/100 ,)
         If M->ED1_QTD <> 0
            M->ED1_PRCUNI := M->ED1_VAL_EM / M->ED1_QTD
         ElseIf M->ED1_VAL_EM <> 0
            M->ED1_QTD := M->ED1_VAL_EM / M->ED1_PRCUNI
         EndIf
      EndIf
   Case cCampo == "ED1_PERCAG"
      M->ED1_VALCOM := (M->ED1_VAL_EM * M->ED1_PERCAG)/100
   Case cCampo == "ED1_NCM"
      If cFilSYD <> SYD->YD_FILIAL .or. M->ED1_NCM <> SYD->YD_TEC
         SYD->(dbSetOrder(1))
         SYD->(dbSeek(cFilSYD+M->ED1_NCM))
      EndIf
      If !Empty(SYD->YD_UNID)
         If M->ED0_MODAL <> ISENCAO
            M->ED1_UMNCM  := SYD->YD_UNID
            M->ED1_QTDNCM := M->ED1_QTD
         EndIf
         If Empty(M->ED1_PROD)
            M->ED1_UMPROD := SYD->YD_UNID
         EndIf
      Else
         Help(" ",1,"AVG0005133") //"NCM nao pode ser selecionada pois nao possui Unidade de Medida."
         lRet := .F.
      EndIf
   Case cCampo == "ED1_QTD"
      If !lIncluiAux .and. !VerED3Saldo("VALID","M") .and. M->ED0_MODAL <> ISENCAO
         Help(" ",1,"AVG0005371",,AllTrim(TRANS((WorkED1->ED1_QTD-WorkED3->ED3_SALDO),AVSX3("ED1_QTD",6)))+".",2,25) //"Quantidade nao pode ser menor que quantidade ja exportada "
         lRet := .F.
         //M->ED1_QTD := WorkED1->ED1_QTD
      ElseIf !Empty(M->ED1_PREEMB)
         If M->ED1_QTDORI <> 0 .and. M->ED1_QTD > M->ED1_QTDORI
            Help(" ",1,"AVG0005135",,Alltrim(TRANS(M->ED1_QTDORI,AVSX3("ED1_QTD",6)))+".",2,20) //"Quantidade nao pode ser maior que a Quantidade Original "
            lRet := .F.
         EndIf
         EE9->(dbSetOrder(1))
      EndIf
      If lRet .and. ValValor("ED1_PESO") .and. ValValor("ED1_QTDNCM")
         //If !Empty(M->ED1_PROD)
         //   M->ED1_QTDNCM := If(!Empty(M->ED1_NCM),AVTransUnid(M->ED1_UMPROD,M->ED1_UMNCM,M->ED1_PROD,M->ED1_QTD),M->ED1_QTD)
         // PLB 18/07/07
         If !Empty(M->ED1_PROD)  .And.  !Empty(M->ED1_NCM)
            M->ED1_QTDNCM := AVTransUnid(M->ED1_UMPROD,M->ED1_UMNCM,M->ED1_PROD,M->ED1_QTD)
         Else
            M->ED1_QTDNCM := M->ED1_QTD
         EndIf
         If M->ED0_MODAL==ISENCAO  .And.  M->ED1_QTDORI <> 0
            nCoefAux := M->ED1_QTD / WorkED1->ED1_QTD
            M->ED1_QTDNCM := nCoefAux * WorkED1->ED1_QTDNCM
         EndIf
         If (M->ED0_MODAL==ISENCAO .and. M->ED1_QTDORI=0) .or. M->ED0_MODAL<>ISENCAO
            M->ED1_PESO:= AC400Peso(M->ED1_UMPROD,M->ED1_PROD,M->ED1_QTD,(cAliasSB1)->B1_PESO) // TDF - 22/03/10
           // M->ED1_PESO   := (cAliasSB1)->B1_PESO * M->ED1_QTD
            If M->ED1_PRCUNI <> 0 .and. ValValor("ED1_VAL_EM")
               M->ED1_VAL_EM := M->ED1_PRCUNI * M->ED1_QTD
            ElseIf M->ED1_VAL_EM <> 0
               M->ED1_PRCUNI := M->ED1_VAL_EM / M->ED1_QTD
            ElseIf lAgrpSld .AND. Len(Alltrim(Str(Int(Round((cAliasSB1)->B1_PESO * M->ED1_QTD,AVSX3("ED1_PESO",4)))))) > (AVSX3("ED1_PESO",3) - AVSX3("ED1_PESO",4)) - 1 .AND. (M->ED0_AGRSLD == "1" .OR. M->ED0_AGRSLD == "3")  // GFP - 22/07/2014
               Return .F.
            EndIf
         EndIf
      Else
         lRet := .F.
      EndIf
   Case cCampo == "ED1_QTDNCM" //AAF 26/09/05 - Valida Alteração da Unidade de Venda

      If lIndPercAg
         cChaveED3 := WorkED1->ED1_NCM+WorkED1->ED1_PROD+Str(WorkED1->ED1_PERCAG,5,2)+;
               iif(lED1Umanex,If(Empty(WorkED1->ED1_UMANEX),WorkED1->ED1_UMNCM,WorkED1->ED1_UMANEX),WorkED1->ED1_UMNCM)
      Else
         cChaveED3 := WorkED1->ED1_NCM+WorkED1->ED1_PROD+;
               iif(lED1Umanex,If(Empty(WorkED1->ED1_UMANEX),WorkED1->ED1_UMNCM,WorkED1->ED1_UMANEX),WorkED1->ED1_UMNCM)
      EndIf

      WorkED3->( dbSetOrder(1) )
      WorkED3->( dbSeek(cChaveED3) )

      If WorkED3->ED3_SALNCM < WorkED3->ED3_QTDNCM
         MsgStop(STR0307)//"U.M. não pode ser alterada pois invalidaria saldo a importar."
         lRet:= .F.
      Else
         //AAF 26/09/05 - Inicializa a Quantidade da NCM alterada.
         nQtdNcm := AvTransUnid(M->ED1_UMPROD,M->ED1_UMNCM,M->ED1_PROD,M->ED1_QTD,.T.)
         nQtdOri := AvTransUnid(WorkED1->ED1_UMNCM,M->ED1_UMNCM,M->ED1_PROD,WorkED1->ED1_QTDNCM,.T.)

         If nQtdNcm <> NIL
            M->ED1_QTDNCM := Round(nQtdNcm,AVSX3("ED1_QTDNCM",4))
         Else
            MsgInfo(AC401STR(002)+"("+M->ED1_UMITEM+") "+AC401STR(003)+"("+M->ED1_UMNCM+")."+;//"Nao existe conversão entre a Unidade do Produto"###" e a Unidade de Venda"
                    Chr(13)+Chr(10)+AC401STR(004))//"Atualize o cadastro de conversão de unidades de medida."
            lRet := .F.
         Endif
         If nQtdOri <> NIL
            M->ED1_QTDORI := Round(nQtdOri,AVSX3("ED1_QTDORI",4))
         Else
            MsgInfo(AC401STR(005)+"("+WorkED1->ED1_UMNCM+") "+AC401STR(006)+"("+M->ED1_UMNCM+")."+;//"Nao existe conversão entre a Unidade Original de Venda"###"e a nova Unidade de Venda"
                    Chr(13)+Chr(10)+AC401STR(004))//"Atualize o cadastro de conversão de unidades de medida."
            lRet := .F.
         Endif
      Endif

   Case cCampo == "ED1_QTDNCM"
      If !Empty(M->ED1_PREEMB)
         If M->ED1_QTDORI <> 0 .and. M->ED1_QTDNCM > M->ED1_QTDORI
            Help(" ",1,"AVG0005135",,Alltrim(TRANS(M->ED1_QTDORI,AVSX3("ED1_QTDNCM",6)))+".",2,20) //"Quantidade nao pode ser maior que a Quantidade Original "
            lRet := .F.
         EndIf
         EE9->(dbSetOrder(1))
      EndIf
      If lRet .and. ValValor("ED1_PESO") .and. ValValor("ED1_QTD")
         If M->ED1_QTDORI<>0
            nCoefAux := M->ED1_QTDNCM / WorkED1->ED1_QTDNCM
            M->ED1_QTD := nCoefAux * WorkED1->ED1_QTD
         //ElseIf !Empty(M->ED1_PROD)
         // PLB 18/07/07
         ElseIf !Empty(M->ED1_PROD)  .And.  !Empty(M->ED1_UMNCM)
            M->ED1_QTD := AVTransUnid(M->ED1_UMNCM,M->ED1_UMPROD,M->ED1_PROD,M->ED1_QTDNCM)
         Else
            M->ED1_QTD := M->ED1_QTDNCM
         EndIf
         If M->ED1_QTDORI=0
            M->ED1_PESO:= AC400Peso(M->ED1_UMPROD,M->ED1_PROD,M->ED1_QTD,(cAliasSB1)->B1_PESO)// TDF - 22/03/10
            //M->ED1_PESO   := (cAliasSB1)->B1_PESO * M->ED1_QTDNCM
            If M->ED1_PRCUNI <> 0 .and. ValValor("ED1_VAL_EM")
               M->ED1_VAL_EM := M->ED1_PRCUNI * M->ED1_QTDNCM
            ElseIf M->ED1_VAL_EM <> 0
               M->ED1_PRCUNI := M->ED1_VAL_EM / M->ED1_QTDNCM
            EndIf
         EndIf
      Else
         lRet := .F.
      EndIf
   Case cCampo == "ED1_PRCUNI"
      If (M->ED0_MODAL==ISENCAO .and. M->ED1_QTDORI=0)
         If M->ED1_QTDNCM <> 0
            If ValValor("ED1_VAL_EM")
               M->ED1_VAL_EM := M->ED1_PRCUNI * M->ED1_QTDNCM
            Else
               lRet:=.F.
            EndIf
         ElseIf M->ED1_VAL_EM <> 0
            M->ED1_QTDNCM := M->ED1_VAL_EM / M->ED1_PRCUNI
            M->ED1_QTD    := WorkED1->ED1_QTD * (M->ED1_QTDNCM / WorkED1->ED1_QTDNCM)
         EndIf
      ElseIf M->ED0_MODAL<>ISENCAO
         If M->ED1_QTD <> 0
            If ValValor("ED1_VAL_EM")
               M->ED1_VAL_EM := M->ED1_PRCUNI * M->ED1_QTD
            Else
               lRet:=.F.
            EndIf
         ElseIf M->ED1_VAL_EM <> 0
            M->ED1_QTD := M->ED1_VAL_EM / M->ED1_PRCUNI
         EndIf
      EndIf
   Case cCampo == "ED1_QTD_PESQ"
      If ValValor("ED1_PESO") .and. ValValor("ED1_QTDNCM","WorkPesq")
         If M->ED1_VAL_EM <> 0
            M->ED1_PRCUNI := M->ED1_VAL_EM / M->ED1_QTD
         ElseIf M->ED1_PRCUNI <> 0 .and. ValValor("ED1_VAL_EM")
            M->ED1_VAL_EM := M->ED1_PRCUNI * M->ED1_QTD
         EndIf
      Else
         lRet := .F.
      EndIf
   Case cCampo == "ED2_ITEM"
      If Empty(M->ED2_ITEM)
         M->ED2_UMITEM := ""
         M->ED2_PRCUNI := 0
         M->ED2_QTDNCM := 0
      Else
         If cFilSB1 <> SB1->B1_FILIAL .or. SB1->B1_COD <> M->ED2_ITEM
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(cFilSB1+M->ED2_ITEM))
         EndIf
         If cFilSYD <> SYD->YD_FILIAL .or. SB1->B1_POSIPI <> SYD->YD_TEC
            SYD->(dbSetOrder(1))
            SYD->(dbSeek(cFilSYD+SB1->B1_POSIPI))
         EndIf
         If !Empty(SYD->YD_UNID) .and. (nValAux:=AVTransUnid(SB1->B1_UM,SYD->YD_UNID,M->ED2_ITEM,M->ED2_QTD,.T.)) <> NIL
            M->ED2_UMITEM := SB1->B1_UM
            M->ED2_PRCUNI := SB1->B1_VLREFUS
            If(M->ED2_QTD<>0, M->ED2_VALEMB := Round(M->ED2_PRCUNI*M->ED2_QTD,AVSX3("ED2_VALEMB",4)) , M->ED2_VALEMB := 0 ) //AAF 09/05/05 - Arredondamento.
            M->ED2_NCM    := SB1->B1_POSIPI
            M->ED2_UMNCM  := SYD->YD_UNID
            If M->ED0_MODAL==ISENCAO .and. M->ED2_QTDORI<>0
               nCoefAux := M->ED2_QTD / WorkED2->ED2_QTD
               M->ED2_QTDNCM := nCoefAux * WorkED2->ED2_QTDNCM
            Else
               M->ED2_QTDNCM := nValAux
            EndIf
         ElseIf Empty(SYD->YD_UNID)
            Help(" ",1,"AVG0005136") //"Item nao pode ser selecionado pois sua NCM nao possui Unidade de Medida."
            lRet := .F.
         Else
            Help(" ",1,"AVG0005137",,"("+Alltrim(SB1->B1_UM)+STR0054+Alltrim(SYD->YD_UNID)+").",3,16) //"Item nao pode ser selecionado pois nao existe conversao entre as Unidades de Medida do Item (" # ") e da NCM ("
            lRet := .F.
         EndIf
      EndIf
   Case cCampo == "ED2_QTD"
      /*
      If M->ED0_MODAL == "2" .AND. M->ED2_QTDORI > 0 .AND. M->ED2_QTD > AvTransUnid(WorkED2->ED2_UMNCM,M->ED2_UMITEM,M->ED2_ITEM,WorkED2->ED2_QTDORI) //AAF 25/08/05 - Conversão para Unidade do Item.
         Help(" ",1,"AVG0005135",,Alltrim(TRANS(M->ED2_QTDORI,AVSX3("ED2_QTD",6)))+".",2,20) //MsgInfo(STR0057+Alltrim(TRANS(M->ED2_QTDORI,AVSX3("ED2_QTD",6)))+".") //"Quantidade nao pode ser maior que a Quantidade Original "
         lRet := .F.
         //M->ED2_QTD := WorkED2->ED2_QTD
      */
     If !lIncluiAux .and. !VerED4Saldo("VALID","M")
        //AAF 23/06/05 - Considera o Percentual de Perda para a quantidade importada.
        nQtdImp:= (WorkED2->ED2_QTDCAL - WorkED4->ED4_QT_LI)  / (1 - Max(M->ED2_PERCPE - M->ED2_PERCAP,0)/100) //WorkED2->ED2_QTDCAL-WorkED4->ED4_QT_LI
        Help(" ",1,"AVG0005134",,Alltrim(TRANS(nQtdImp,AVSX3("ED2_QTD",6)))+".",2,25) //MsgInfo(STR0060+Alltrim(TRANS(WorkED2->ED2_QTD-WorkED4->ED4_QT_LI,AVSX3("ED2_QTD",6)))+".") //"Quantidade nao pode ser menor que quantidade ja importada "
        lRet := .F.
        //M->ED2_QTD := WorkED2->ED2_QTD
     ElseIf ValValor("ED2_PESO") .and. ValValor("ED2_QTDNCM")
        If M->ED0_MODAL==ISENCAO .and. M->ED2_QTDORI<>0 .and. ! AvVldUn( M->ED2_UMNCM ) // MPG - 14/02/2018
           //nCoefAux := M->ED2_QTD / WorkED2->ED2_QTD
           //M->ED2_QTDNCM := nCoefAux * WorkED2->ED2_QTDNCM
           M->ED2_QTDNCM := Round(AvTransUnid(M->ED2_UMITEM,M->ED2_UMNCM,M->ED2_ITEM,M->ED2_QTD),AVSX3("ED2_QTDNCM",4))
        EndIf
        If (M->ED0_MODAL==ISENCAO .and. M->ED2_QTDORI=0) .or. M->ED0_MODAL<>ISENCAO
           M->ED2_PESO:= AC400Peso(M->ED2_UMITEM,M->ED2_ITEM,M->ED2_QTD,SB1->B1_PESO) // TDF - 22/03/10
           //M->ED2_PESO   := SB1->B1_PESO * M->ED2_QTD
           If AvVldUn( M->ED2_UMNCM )  .and. M->ED0_MODAL <> ISENCAO  // MPG - 14/02/2018
              M->ED2_QTDNCM := If(!Empty(M->ED2_NCM),AVTransUnid(M->ED2_UMITEM,M->ED2_UMNCM,M->ED2_ITEM,M->ED2_PESO),M->ED2_PESO)  // GFP - 31/07/2014
           Else
              If !Empty(M->ED2_ITEM)
                 M->ED2_QTDNCM := If(!Empty(M->ED2_NCM),AVTransUnid(M->ED2_UMITEM,M->ED2_UMNCM,M->ED2_ITEM,M->ED2_QTD),M->ED2_QTD)
              Else
                 M->ED2_QTDNCM := M->ED2_QTD
              EndIf
           EndIf
           If M->ED2_PRCUNI <> 0 .and. ValValor("ED2_VALEMB")
              M->ED2_VALEMB := Round(M->ED2_PRCUNI * M->ED2_QTD,AVSX3("ED2_VALEMB",4)) //AAF 09/05/05 - Arredondamento.
           ElseIf M->ED2_VALEMB <> 0
              M->ED2_PRCUNI := M->ED2_VALEMB / M->ED2_QTD
           EndIf
        EndIf
     Else
        lRet := .F.
     EndIf

     If lED2Percap   // ACSJ - 17/11/2004
        If M->ED2_PERCPE > M->ED2_PERCAP
           M->ED2_QTDCAL := M->ED2_QTD - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTD)/100
           M->ED2_VALCAL := M->ED2_VALEMB - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_VALEMB)/100
        Else
           M->ED2_QTDCAL := M->ED2_QTD
           M->ED2_VALCAL := M->ED2_VALEMB
        EndIf
     Else
        If M->ED2_PERCPE > 0
           M->ED2_QTDCAL := M->ED2_QTD - (M->ED2_PERCPE * M->ED2_QTD)/100
           M->ED2_VALCAL := M->ED2_VALEMB - (M->ED2_PERCPE * M->ED2_VALEMB)/100
        Else
           M->ED2_QTDCAL := M->ED2_QTD
           M->ED2_VALCAL := M->ED2_VALEMB
        EndIf
     Endif

   Case cCampo == "ED2_QTDNCM"
      /*
      If M->ED2_QTDORI <> 0 .and. M->ED2_QTDNCM > M->ED2_QTDORI //AAF 16/09/05//AvTransUnid(M->ED2_UMNCM,WorkED2->ED2_UMNCM,M->ED2_ITEM,M->ED2_QTDNCM) > M->ED2_QTDORI
         Help(" ",1,"AVG0005135",,Alltrim(TRANS(M->ED2_QTDORI,AVSX3("ED2_QTDNCM",6)))+".",2,20) //MsgInfo(STR0057+Alltrim(TRANS(M->ED2_QTDORI,AVSX3("ED2_QTD",6)))+".") //"Quantidade nao pode ser maior que a Quantidade Original "
         lRet := .F.
         //M->ED2_QTDNCM := WorkED2->ED2_QTDNCM
      */
      If !lIncluiAux .and. !VerED4Saldo("VALID2","WorkED2")
         Help(" ",1,"AVG0005134",,Alltrim(TRANS(WorkED2->ED2_QTDNCM-WorkED4->ED4_SNCMLI,AVSX3("ED2_QTD",6)))+".",2,25) //MsgInfo(STR0060+Alltrim(TRANS(WorkED2->ED2_QTD-WorkED4->ED4_QT_LI,AVSX3("ED2_QTD",6)))+".") //"Quantidade nao pode ser menor que quantidade ja importada "
         lRet := .F.
         //M->ED2_QTDNCM := WorkED2->ED2_QTDNCM
      EndIf
      /*
      ElseIf ValValor("ED2_PESO") .and. ValValor("ED2_QTD")
         If M->ED0_MODAL=="2" .and. M->ED2_QTDORI<>0
            /* AAF 15/09/05
            nCoefAux := M->ED2_QTDNCM / WorkED2->ED2_QTDNCM
            M->ED2_QTD := nCoefAux * WorkED2->ED2_QTD

            M->ED2_QTD := Round(AvTransUnid(M->ED2_UMNCM,M->ED2_UMITEM,M->ED2_ITEM,M->ED2_QTDNCM),AVSX3("ED2_QTD",4))
         ElseIf !Empty(M->ED2_ITEM)
            M->ED2_QTD := AVTransUnid(M->ED2_UMNCM,M->ED2_UMITEM,M->ED2_ITEM,M->ED2_QTDNCM)
         Else
            M->ED2_QTD := M->ED2_QTDNCM
         EndIf

         if lED2Percap  // ACSJ - 17/11/2004
            If M->ED2_PERCPE > M->ED2_PERCAP
               M->ED2_QTDCAL := M->ED2_QTD - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTD)/100
               M->ED2_VALCAL := M->ED2_VALEMB - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_VALEMB)/100
            Else
               M->ED2_QTDCAL := M->ED2_QTD
               M->ED2_VALCAL := M->ED2_VALEMB
            EndIf
         Else
            If M->ED2_PERCPE > 0
               M->ED2_QTDCAL := M->ED2_QTD - (M->ED2_PERCPE * M->ED2_QTD)/100
               M->ED2_VALCAL := M->ED2_VALEMB - (M->ED2_PERCPE * M->ED2_VALEMB)/100
            Else
               M->ED2_QTDCAL := M->ED2_QTD
               M->ED2_VALCAL := M->ED2_VALEMB
            EndIf
         Endif

         If (M->ED0_MODAL=="2" .and. M->ED2_QTDORI=0)
            M->ED2_PESO   := M->ED2_QTDNCM * SB1->B1_PESO
            If M->ED2_PRCUNI <> 0 .and. ValValor("ED2_VALEMB")
               M->ED2_VALEMB := Round(M->ED2_PRCUNI * M->ED2_QTDNCM,AVSX3("ED2_VALEMB",4)) //AAF 09/05/05 - Arrendondamento.
            ElseIf M->ED2_VALEMB <> 0
               M->ED2_PRCUNI := M->ED2_VALEMB / M->ED2_QTDNCM
            EndIf
         ElseIf M->ED0_MODAL<>"2"
            M->ED2_PESO   := M->ED2_QTD * SB1->B1_PESO
            If M->ED2_PRCUNI <> 0 .and. ValValor("ED2_VALEMB")
               M->ED2_VALEMB := Round(M->ED2_PRCUNI * M->ED2_QTD,AVSX3("ED2_VALEMB",4)) //AAF 09/05/05 - Arredondamento.
            ElseIf M->ED2_VALEMB <> 0
               M->ED2_PRCUNI := M->ED2_VALEMB / M->ED2_QTD
            EndIf
         EndIf
      Else
         lRet := .F.
      EndIf
      */
   Case cCampo == "ED2_PERCPE"
      If VerED4Saldo("MANUT","WorkED2")
         if lED2Percap  // ACSJ - 17/11/2004
            If M->ED2_PERCPE > M->ED2_PERCAP
               M->ED2_QTDCAL := M->ED2_QTD - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTD)/100
               M->ED2_VALCAL := M->ED2_VALEMB - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_VALEMB)/100
            Else
               M->ED2_QTDCAL := M->ED2_QTD
               M->ED2_VALCAL := M->ED2_VALEMB
            EndIf
         Else
            If M->ED2_PERCPE > 0
               M->ED2_QTDCAL := M->ED2_QTD - (M->ED2_PERCPE * M->ED2_QTD)/100
               M->ED2_VALCAL := M->ED2_VALEMB - (M->ED2_PERCPE * M->ED2_VALEMB)/100
            Else
               M->ED2_QTDCAL := M->ED2_QTD
               M->ED2_VALCAL := M->ED2_VALEMB
            EndIf
         Endif

      Else
         MsgInfo(STR0286) //"Percentual de perda incorreto pois invalidaria saldo a importar."
         lRet := .F.
      EndIf
   Case cCampo == "ED2_PERCPE2"

      if lED2Percap   // ACSJ - 17/11/2004
         If M->ED2_PERCPE > M->ED2_PERCAP
            M->ED2_QTDCAL := M->ED2_QTD - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTD)/100
            M->ED2_VALCAL := M->ED2_VALEMB - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_VALEMB)/100
         Else
            M->ED2_QTDCAL := M->ED2_QTD
            M->ED2_VALCAL := M->ED2_VALEMB
         EndIf
      Else
         If M->ED2_PERCPE > 0
            M->ED2_QTDCAL := M->ED2_QTD - (M->ED2_PERCPE * M->ED2_QTD)/100
            M->ED2_VALCAL := M->ED2_VALEMB - (M->ED2_PERCPE * M->ED2_VALEMB)/100
         Else
            M->ED2_QTDCAL := M->ED2_QTD
            M->ED2_VALCAL := M->ED2_VALEMB
         EndIf
      Endif
   Case cCampo == "ED2_VALEMB"
      /*
      If !lIncluiAux .and. !lMarcacao .and. !VerED4Saldo("VALVALOR","M")
         Help(" ",1,"AVG0005138",,Alltrim(TRANS(WorkED2->ED2_VALEMB-WorkED4->ED4_VL_LI,AVSX3("ED2_VALEMB",6)))+".",2,11) //"Valor nao pode ser menor que valor ja importado "
         lRet := .F.
         //M->ED2_VALEMB := WorkED2->ED2_VALEMB
      EndIf
      */
      If (M->ED0_MODAL==ISENCAO .and. M->ED2_QTDORI=0) .or. M->ED0_MODAL<>ISENCAO
         If M->ED0_MODAL <> ISENCAO
            If M->ED2_QTD <> 0
               M->ED2_PRCUNI := M->ED2_VALEMB / M->ED2_QTD
            EndIf
         Else
            If M->ED2_QTDNCM <> 0
               M->ED2_PRCUNI := M->ED2_VALEMB / M->ED2_QTDNCM
            EndIf
         EndIf
      ElseIf M->ED0_MODAL==ISENCAO
         nCoefAux := WorkED2->ED2_VALEMB / M->ED2_VALEMB
         M->ED2_VL_MOE := WorkED2->ED2_VL_MOE / nCoefAux
      EndIf

      if lED2Percap   // ACSJ - 17/11/2004
         If M->ED2_VALEMB<>0 .and. M->ED2_PERCPE > M->ED2_PERCAP
            M->ED2_VALCAL := M->ED2_VALEMB - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_VALEMB)/100
         Else
            M->ED2_VALCAL := M->ED2_VALEMB
         EndIf
      Else
         If M->ED2_VALEMB<>0 .and. M->ED2_PERCPE > 0
            M->ED2_VALCAL := M->ED2_VALEMB - (M->ED2_PERCPE * M->ED2_VALEMB)/100
         Else
            M->ED2_VALCAL := M->ED2_VALEMB
         EndIf
      Endif

   Case cCampo == "ED2_NCM"
      If VerED4Saldo("MANUT","WorkED2")
         If (M->ED0_TIPOAC<>GENERICO .or. Alltrim(M->ED2_NCM) <> NCMGENERICA)
            SYD->(dbSetOrder(1))
            SYD->(dbSeek(cFilSYD+M->ED2_NCM))
            If !Empty(SYD->YD_UNID)
               If M->ED0_MODAL <> ISENCAO
                  M->ED2_UMNCM  := SYD->YD_UNID
                  M->ED2_QTDNCM := M->ED2_QTD
               EndIf
               If Empty(M->ED2_ITEM)
                  M->ED2_UMITEM := SYD->YD_UNID
               EndIf
            Else
               Help(" ",1,"AVG0005133") //MsgInfo(STR0055) //"NCM nao pode ser selecionada pois nao possui Unidade de Medida"
               lRet := .F.
            EndIf
         EndIf
      Else
         MsgInfo(STR0287) //"NCM não pode ser alterada pois invalidaria saldo a importar."
         lRet := .F.
      EndIf
   Case cCampo == "ED2_PRCUNI"
      If (M->ED0_MODAL==ISENCAO .and. M->ED2_QTDORI=0)
         If M->ED2_QTDNCM <> 0
            If ValValor("ED2_VALEMB")
               M->ED2_VALEMB := Round(M->ED2_PRCUNI * M->ED2_QTDNCM,AVSX3("ED2_VALEMB",4)) //AAF 09/05/05 - Arredondamento.
            Else
               lRet := .F.
            EndIf
         ElseIf M->ED2_VALEMB <> 0
            M->ED2_QTDNCM := M->ED2_VALEMB / M->ED2_PRCUNI
            M->ED2_QTD    := WorkED2->ED2_QTD * (M->ED2_QTDNCM / WorkED2->ED2_QTDNCM)
         EndIf
      ElseIf M->ED0_MODAL<>ISENCAO
         If M->ED2_QTD <> 0
            If ValValor("ED2_VALEMB")
               M->ED2_VALEMB := Round(M->ED2_PRCUNI * M->ED2_QTD,AVSX3("ED2_VALEMB",4)) //AAF 09/05/05 - Arredondamento.
            Else
               lRet := .F.
            EndIf
         ElseIf M->ED2_VALEMB <> 0
            M->ED2_QTD := M->ED2_VALEMB / M->ED2_PRCUNI
         EndIf
      EndIf
   Case cCampo == "ED2_QTD_PESQ"
      If ValValor("ED2_PESO") .and. ValValor("ED2_QTDNCM","WorkPesq")
         If M->ED2_VALEMB <> 0
            M->ED2_PRCUNI := M->ED2_VALEMB / M->ED2_QTD
         ElseIf M->ED2_PRCUNI <> 0 .and. ValValor("ED2_VALEMB")
            M->ED2_VAL_EM := M->ED2_PRCUNI * M->ED2_QTD
         EndIf
      Else
         lRet := .F.
      EndIf
   Case cCampo == "ED2_VALEMB_PESQ"
      If M->ED2_QTD <> 0
         M->ED2_PRCUNI := M->ED2_VALEMB / M->ED2_QTD
      ElseIf M->ED2_VALEMB <> 0
         M->ED2_QTD := M->ED2_VALEMB / M->ED2_PRCUNI
      ElseIf M->ED0_TIPOAC <> GENERICO .or. Alltrim(M->ED2_NCM) <> NCMGENERICA
         M->ED2_PRCUNI := 0
      EndIf
   Case cCampo == "ED2_UMNCM" .and. !lIncluiAux
      If !VerED4Saldo("MANUT","WorkED2")
         MsgInfo(STR0288) //"U.M. não pode ser alterada pois invalidaria saldo a importar."
         lRet := .F.
      /*
      ElseIf M->ED2_QTDORI <> 0 .and. AvTransUnid(M->ED2_UMNCM,WorkED2->ED2_UMNCM,M->ED2_ITEM,M->ED2_QTDNCM) > M->ED2_QTDORI
         MsgInfo(STR0297) //"Quantidade não pode ser maior que a quantidade original."
         lRet := .F.
      */
      Else
         //AAF 15/09/05 - Inicializa a Quantidade da NCM alterada.
         nQtdNcm := AvTransUnid(M->ED2_UMITEM,M->ED2_UMNCM,M->ED2_ITEM,M->ED2_QTD,.T.)
         //nQtdOri := AvTransUnid(WorkED2->ED2_UMNCM,M->ED2_UMNCM,M->ED2_ITEM,WorkED2->ED2_QTDORI,.T.)

         If nQtdNcm <> NIL
            M->ED2_QTDNCM := Round(nQtdNcm,AVSX3("ED2_QTDNCM",4))
         Else
            MsgInfo(AC401STR(007)+"("+M->ED2_UMITEM+") "+AC401STR(008)+"("+M->ED2_UMNCM+")."+;//"Nao existe conversão entre a Unidade do Item("###"e a Unidade de Compra"
                    Chr(13)+Chr(10)+AC401STR(004))//"Atualize o cadastro de conversão de unidades de medida."
            lRet := .F.
         Endif
         /*
         If nQtdOri <> NIL
            M->ED2_QTDORI := Round(nQtdOri,AVSX3("ED2_QTDORI",4))
         Else
            MsgInfo("Nao existe conversão entre a Unidade Original de Compra("+WorkED2->ED2_UMNCM+") e a nova Unidade de Compra("+M->ED2_UMNCM+")."+;
                    Chr(13)+Chr(10)+"Atualize o cadastro de conversão de unidades de medida.")
            lRet := .F.
         Endif
         */
      Endif
   Case cCampo == "ED2_UMANEX" .and. !lIncluiAux   // ACSJ - Valid de campo so entra se existir no dicionario - 17/11/2004
      WorkED4->(dbSetOrder(1))
      //lAchou := WorkED4->(dbSeek(WorkED2->ED2_NCM+WorkED2->ED2_ITEM+WorkED2->ED2_CAMB+If(M->ED0_MODAL=="2",Str(0,5,2),Str(WorkED2->ED2_PERCPE,5,2))+If(Empty(WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX)))
      // PLB 09/04/07 - Alteracao do Seek para procurar utilizando Percentual de Perda na chave

      //AOM - 10/11/2011
      If AvFlags("SEQMI")
         cImport := WorkED2->ED2_IMPORT
      EndIf

      lAchou := WorkED4->(dbSeek(WorkED2->ED2_NCM+WorkED2->ED2_ITEM+WorkED2->ED2_CAMB+Str(WorkED2->ED2_PERCPE,5,2)+If(Empty(WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX)+ cImport))

      if lAchou .and. WorkED4->ED4_QTDCAL <> WorkED4->ED4_QT_LI
         MsgInfo(STR0289) //"Campo não pode ser alterado pois item já foi utilizado para comprovação de importação."
         lRet := .F.
      ElseIf !VerED4Saldo("MANUT","WorkED2")
         MsgInfo(STR0288) //"U.M. não pode ser alterada pois invalidaria saldo a importar."
         lRet := .F.
      EndIf

   Case cCampo == "MEDIDA"
      If M->ED0_TIPOAC<>GENERICO .or. Alltrim(M->ED2_NCM) <> NCMGENERICA
         lRet:=.F.
      EndIf
   Case cCampo == "SOMATORIA"
      nPerc := M->ED0_PERCTO
      If Tot_Imp > (Tot_Exp * nPerc)/100
         MsgInfo(STR0062+Alltrim(Str(nPerc))+STR0063+Chr(13)+Chr(10)+; //"Importacao ultrapassou " # "% do valor total da exportacao"
                 STR0064+TRANS(Tot_Exp,AVSX3("ED1_VAL_EM",6))+Chr(13)+Chr(10)+; //"Exportacao: US$"
                 STR0065+TRANS(Tot_Imp,AVSX3("ED2_VALEMB",6))) //"Importacao: US$"
      EndIf
   Case cCampo == "FINALPE"
      If M->ED0_MODAL == ISENCAO .and. Empty(M->ED1_PROD)
	        Help(" ",1,"AVG0005140") //"Produto nao pode ser vazio na modalidade isencao."
	        lRet:=.F.

	  ElseIf M->ED0_MODAL == SUSPENSAO  //Suspensao
         // ** AAF 13/04/05 - Validação para alteração da Quantidade.

         Begin Sequence

         If nOldOpc == ALTERAR .And. M->ED1_QTD <> WorkED1->ED1_QTD
            lRet:= OpcReapuraInsumo()
            //Forçar a saída do bloco caso a reapuração dos insumos tenha sido cancelada ou contenha impedimentos
            If !lRet
               Break
            EndIf
         EndIf

         If (nOldOpc == INCLUIR .And. MsgYesNo(STR0416, STR0417)) .Or.; //"Deseja calcular as quantidades necessárias dos insumos de acordo com o cadastro de estrutura do produto a exportar?","Atenção" - AOM - 03/10/2011
            (ValType(cEstru) == "C" .And. cEstru <> "3") //"3 - Não atualizar" - quando for solicitada atualização dos insumos, seja com base no cadastro de estruturas ou na estrutura do ato concessório, executa a validação

            WorkED2->( dbSetOrder(2) )//"ED2_PROD+ED2_SEQ"
            WorkED4->( dbSetOrder(1) )
            If M->ED1_QTD < WorkED1->ED1_QTD
               aOrd    := SaveOrd({"WorkED2","WorkED4"})
               nValMin := 0

               WorkED2->( dbSeek(M->ED1_PROD+M->ED1_SEQ) )
               Do While !WorkED2->( EoF() ) .AND. WorkED2->( ED2_PROD+ED2_SEQ ) == M->ED1_PROD+M->ED1_SEQ
                  If WorkED4->( dbSeek( WorkED2->( ED2_NCM+ED2_ITEM+ED2_CAMB+Str(ED2_PERCPE,5,2)+If( Empty(ED2_UMANEX), ED2_UMNCM, ED2_UMANEX) )) )

                     nPercPE := Max(WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP, 0) / 100 //Percentual de Perda do Item
                     nQtdEstr:= WorkED2->ED2_QTDORI / WorkED1->ED1_QTD                  //Quantidade da Estrutura (Qtd do item por produto)

                     nQuant := WorkED4->ED4_QTDCAL - (WorkED2->ED2_QTDCAL - (M->ED1_QTD - M->ED1_QTD * nPercPE) * nQtdEstr)
                     //nQuant := WorkED4->ED4_QTDCAL - (WorkED2->ED2_QTDCAL - M->ED1_QTD * (Max(WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP, 0) / 100 * WorkED2->ED2_QTDORI / WorkED1->ED1_QTD))
                     If WorkED4->ED4_QTDCAL - WorkED4->ED4_QT_LI > nQuant
                        lRet := .F.
                        nValMin := Max(nValMin, ( WorkED1->ED1_QTD * (WorkED2->ED2_QTDCAL - WorkED4->ED4_QT_LI) ) / WorkED2->ED2_QTDORI )
                     Endif

                  Endif

                  WorkED2->( dbSkip() )
               EndDo

 	           If !lRet
                  MsgStop(STR0302+AllTrim(TransForm( nValMin, AVSX3("ED1_QTD",6)))+STR0303)//"Quantidade não pode ser menor que "###" pois invalidaria a quantidade de um dos itens na LI."
               Endif

               RestOrd(aOrd)
            EndIf
             //NCF - 30/06/2016 - Nopada toda a verificação abaixo
            /* Para atualizar pelo cadastro de estruturas, os registros da workED2 serão refeitos.
               Neste caso, a exclusão da work só será permitida se não houver insumo em uso na fase de licença de importação */

            /*If ValType(cEstru) == "C" .And. cEstru == "2" .And. M->ED1_QTD <= WorkED1->ED1_QTD //"2 - Cadastro de estruturas"

               WorkED2->(DBSeek(WorkED1->ED1_PROD + WorkED1->ED1_SEQ))
               While WorkED2->ED2_PROD == WorkED1->ED1_PROD .And. WorkED2->ED2_SEQ == WorkED1->ED1_SEQ
                  If !VerED4Saldo("ESTORNO", "WorkED2")
                     MsgStop(STR0441, STR0436) //"A reapuração com base no cadastro de estruturas não poderá prosseguir pois existe(m) item(ns) em uso na Licença de Importação.", Atualização dos Insumos
                     lRet:= .F.
                     Exit
                  EndIf
                  WorkED2->(DBSkip())
               EndDo
            EndIf*/
         Else
            lRecalcIn:= .F.  //TRP - 22/11/2011 - Não recalcular a quantidade dos Insumos.
         Endif
         // **
         // **  PLB 09/11/06 - Validação das estruturas dos Produtos Alternativos
         If lRet  .And.  nOldOpc == INCLUIR  .And.  !Empty(M->ED1_PROD)  .And.  lTipoItem
            ED7->( DBSetOrder(2) )
            If ED7->( DBSeek(xFilial("ED7")+"E"+M->ED1_PROD+M->ED0_PD) )
               cChave := ED7->( ED7_FILIAL+ED7_DE+ED7_PD )
               Do While !ED7->( EoF() )  .And.  ED7->( ED7_FILIAL+ED7_DE+ED7_PD ) == cChave
                  AADD(aJaCompEst,ED7->ED7_PARA)
                  Processa({|| ( aMsgAux := AvCompEstr(M->ED1_PROD,ED7->ED7_PARA,,.F.,.F.,"PEDIDO") ) },AC401STR(023))  //"Comparando Estruturas..."
                  For ni := 1  to  Len(aMsgAux)
                     AAdd(aMsg,aMsgAux[ni])
                  Next ni
                  aMsgAux := {}
                  ED7->( DBSkip() )
               EndDo
            EndIf
            If ED7->( DBSeek(xFilial("ED7")+"E"+M->ED1_PROD+Space(Len(M->ED0_PD)))  )
               cChave := ED7->( ED7_FILIAL+ED7_DE+ED7_PD )
               Do While !ED7->( EoF() )  .And.  ED7->( ED7_FILIAL+ED7_DE+ED7_PD ) == cChave
                  If AScan(aJaCompEst,{ |x| x == ED7->ED7_PARA }) == 0
                     Processa({|| ( aMsgAux := AvCompEstr(M->ED1_PROD,ED7->ED7_PARA,,.F.,.F.,"PEDIDO") ) },AC401STR(023))  //"Comparando Estruturas..."
                     For ni := 1  to  Len(aMsgAux)
                        AAdd(aMsg,aMsgAux[ni])
                     Next ni
                     aMsgAux := {}
                  EndIf
                  ED7->( DBSkip() )
               EndDo
            EndIf
            If Len(aMsg) > 0
               AAdd(aMsg,NIL)
               AIns(aMsg,1)
               aMsg[1] := {AC401STR(024),.T.}  //"O Produto possui itens alternativos e foram encontradas divergências no Cadastro de Estruturas:"

               EECView(aMsg,STR0262)  //"Atenção"

               lRet := MsgYesNo(AC401STR(025))  //"Deseja continuar com a operação?"
            EndIf
         EndIf
         // **
         End Sequence
      EndIf


   Case cCampo == "FINALPI"
      If M->ED2_QTD=0 .and. M->ED2_NCM<>NCMGENERICA
         Help(" ",1,"AVG0005141") //"Necessario Preencher a quantidade."
         lRet:=.F.
      ElseIf M->ED0_MODAL == ISENCAO .and. Empty(M->ED2_ITEM)
	     Help(" ",1,"AVG0005142") //"Item nao pode ser vazio na modalidade isencao."
	     lRet:=.F.
      // ** PLB 05/10/06 - Se tiver Valor Comercial a Perda deve ter porcentual.
      ElseIf lTemVLCOMPE  .And.  M->ED2_VLCOPE $ cSim  .And.  M->ED2_PERCPE == 0
         MsgInfo(AC401STR(0022))  //"O item possui Valor Comercial a Perda, preencha o campo Percentual de Perda."
         lRet := .F.
      // **
      // ** PLB 20/06/07 - Verifica permissão para Dedução de Percentual de Perda
      ElseIf M->ED0_DEDUZP $ cNao  .And.  M->ED2_PERCPE <> M->ED2_PERCAP
         MsgInfo(AC401STR(0028))  //"A Dedução de Percentual de Perda não é permitida. O Percentual Aprovado deve ser o mesmo do Percentual de Perda."
         lRet := .F.
      // **
	  EndIf
   Case cCampo == "PESQUISA1"
      If M->ED1_QTD=0
         Help(" ",1,"AVG0005141") //"Necessario Preencher a quantidade."
         lRet:=.F.
      ElseIf M->ED1_VAL_EM=0
         Help(" ",1,"AVG0005143") //"Necessario Preencher o Valor no Local de Embarque."
         lRet:=.F.
      ElseIf M->ED1_PRCUNI=0
         Help(" ",1,"AVG0005144") //"Necessario Preencher o Preco Unitario."
         lRet:=.F.
      EndIf
   Case cCampo == "PESQUISA2"
      If M->ED2_QTD=0 .and. (M->ED0_TIPOAC<>GENERICO .or. Alltrim(M->ED2_NCM) <> NCMGENERICA)
         Help(" ",1,"AVG0005141") //"Necessario Preencher a quantidade."
         lRet:=.F.
      ElseIf M->ED2_VALEMB=0
         Help(" ",1,"AVG0005143") //"Necessario Preencher o Valor no Local de Embarque."
         lRet:=.F.
      ElseIf M->ED2_PRCUNI=0
         Help(" ",1,"AVG0005144") //"Necessario Preencher o Preco Unitario."
         lRet:=.F.
      EndIf
   Case cCampo == "ED2_PESO"  // TAN
      If AvVldUn( M->ED2_UMNCM ) .and. M->ED0_MODAL <> ISENCAO // MPG - 14/02/2018
         M->ED2_QTDNCM := M->ED2_PESO
      Endif


   Case cCampo == "ED0_STATUS"
      If M->ED0_STATUS == "6" .And. Empty(M->ED0_DEFERI)
         lRet:=.F.
         MsgInfo("Para Situação ser deferido é necessário preencher a data de Deferimento","Aviso")
      EndIf

   //AOM - 09/11/2011
   Case cCampo == 'ED0_TIPINS'

        cTexto += STR0423//"Opção 1 - Todos Importados: Todos os itens da estrutura do produto são considerados como importações "
        cTexto += STR0424 + ENTER + ENTER //"idependentemente da informação colocada no campo(Prod Import.?) do cadastro de produtos."
        cTexto += STR0425//"Opção 2 - Importados e Compras Nacionais: Imprime separadamente os itens importados das compras nacionais, "
        cTexto += STR0426 + ENTER + ENTER //"é feita a verificação através da informação colocada no campo(Prod Import.?) do cadastro de produtos."
        cTexto += STR0427//"Opção 3 - Apenas Importados: Considera o campo(Prod Import.?) do cadastro de produtos, mas imprime "
        cTexto += STR0428 + ENTER + ENTER//"apenas os itens que estão com o conteudo do campo como (Sim - Importados)."
        cTexto += STR0429//"Opção 4 - Apenas Compras Nacionais: Considera o campo(Prod Import.?) do cadastro de produtos, mas imprime "
        cTexto += STR0430//"apenas os itens que estão com o conteudo do campo como (Não - Compras Nacionais)."

        MsgInfo(cTexto,"Aviso")

   Case cCampo == 'VALIDA_INSUMO'  // GFP - 11/08/2014
      If "*" $ Transform(WorkED4->ED4_PESO  + M->ED2_PESO,AVSX3("ED4_PESO",6))
         MsgAlert(STR0433 + ENTER + STR0434,STR0435) //"Peso calculado invalido." ### "O valor da somatória do peso do processo estoura o tamanho do campo." ### "Aviso"
         lRet := .F.
      EndIf
EndCase

Return lRet

*------------------------------------*
Static Function AC400GrvWorks(lCopiaX)
*------------------------------------*
Local cCampo, ED1TotCpos:=ED1->(FCount()), ED2TotCpos:=ED2->(FCount())
Local ED3TotCpos:=ED3->(FCount()), ED4TotCpos:=ED4->(FCount())
Local EDATotCpos, EDBTotCpos
Local lCopia:=If(lCopiax<>NIL,lCopiax,.F.)
Local lAppend:=.T., nTot:=If(lCopia,9,8), i
//AOM - 16/11/10
Local cAto := "", cPed := ""
Local lDIExt := lReExt := .F.

ProcRegua(nTot)

If lCopia //Grava WorkED0 p/ Copia
   IncProc(STR0071) //"Processando..."
   dbSelectArea("ED0")
   WorkED0->(RecLock("WorkED0",.T.))
   FOR i := 1 TO ED0->(FCount())
      cCampo:=FIELDNAME(i)
      WorkED0->&(cCampo) := ED0->&(cCampo)
   NEXT i
   WorkED0->ED0_VM_OBS:= MSMM(ED0->ED0_OBS,60)
   WorkED0->(msUnlock())
EndIf

//WorkED1
IncProc(STR0071) //"Processando..."
dbSelectArea("ED1")
ED1->(dbSetOrder(1))
If ED1->(dbSeek(cFilED1+ED0->ED0_PD))
   Do While !ED1->(EOF()) .and. ED1->ED1_FILIAL==cFilED1 .and. ED1->ED1_PD==ED0->ED0_PD
      WorkED1->(RecLock("WorkED1",.T.))
      FOR i := 1 TO ED1TotCpos
         cCampo:=FIELDNAME(i)
         WorkED1->&(cCampo) := ED1->&(cCampo)
      NEXT i
      If lMultiFil  .And.  ED0->ED0_MODAL == ISENCAO
         WorkED1->ED1_FILORI := Left(WorkED1->ED1_FILORI,2) + " - " + AvgFilName({Left(WorkED1->ED1_FILORI,2)})[1]
      EndIf
      WorkED1->ED1_RECNO  := ED1->(RECNO())
      WorkED1->ED1_VALCOM := (WorkED1->ED1_VAL_EM * WorkED1->ED1_PERCAG)/100
      WorkED1->TRB_ALI_WT := "ED1"
      WorkED1->TRB_REC_WT := ED1->(Recno())
      WorkED1->ED1_DESCPD := Posicione("SB1",1,xFilial("SB1"/*"ED1"*/)+WorkED1->ED1_PROD,"B1_DESC")  // GFP - 30/08/2012
      If !lCopia
         AC400Totais("WorkED1",INCLUIR)
      EndIf
      WorkED1->(msUnlock())

      ED1->(dbSkip())
   EndDo
   WorkED1->(dbGoTop())
EndIf
If !lCopia
   nSeq:=AC400Sequencia("WorkED1")
   If nSeq<=0 .or. ValType(nSeq)<>"N"
      nSeq:=1
   EndIf
EndIf

//WorkED3
IncProc(STR0071) //"Processando..."
dbSelectArea("ED3")
ED3->(dbSetOrder(1))
If ED3->(dbSeek(cFilED3+ED0->ED0_PD))
   Do While !ED3->(EOF()) .and. ED3->ED3_FILIAL==cFilED3 .and. ED3->ED3_PD==ED0->ED0_PD
      WorkED3->(RecLock("WorkED3",.T.))
      FOR i := 1 TO ED3TotCpos
         cCampo:=FIELDNAME(i)
         WorkED3->&(cCampo) := ED3->&(cCampo)
      NEXT i
      WorkED3->ED3_RECNO := ED3->(RECNO())
      WorkED3->TRB_ALI_WT:= "ED3"
      WorkED3->TRB_REC_WT:= ED3->(Recno())
      WorkED3->ED3_DESCPD := Posicione("SB1",1,xFilial("SB1"/*"ED1"*/)+WorkED3->ED3_PROD,"B1_DESC")    // GFP - 30/08/2012
      WorkED3->(msUnlock())

      ED3->(dbSkip())
   EndDo
   WorkED3->(dbGoTop())
EndIf

//WorkED2
IncProc(STR0071) //"Processando..."
dbSelectArea("ED2")
ED2->(dbSetOrder(1))
If ED2->(dbSeek(cFilED2+ED0->ED0_PD))
   Do While !ED2->(EOF()) .and. ED2->ED2_FILIAL==cFilED2 .and. ED2->ED2_PD==ED0->ED0_PD
      WorkED2->(RecLock("WorkED2",.T.))
      FOR i := 1 TO ED2TotCpos
         cCampo:=FIELDNAME(i)
         If WorkED2->(FieldPos(cCampo)) > 0
         	WorkED2->&(cCampo) := ED2->&(cCampo)
         EndIf
      NEXT i
      If lMultiFil  .And.  ED0->ED0_MODAL == ISENCAO
         WorkED2->ED2_FILORI := Left(WorkED2->ED2_FILORI,2) + " - " + AvgFilName({Left(WorkED2->ED2_FILORI,2)})[1]
      EndIf
      If ED2->ED2_MARCA = "1" .and. !lCopia
         WorkED2->ED2_MARCA := cMarca
      EndIf

      if lED2PerCap   // ACSJ - 23/11/2004
         If WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTD)/100
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_VALEMB)/100
         Else
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB
         EndIf
      Else
         If WorkED2->ED2_PERCPE > 0
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD - (WorkED2->ED2_PERCPE * WorkED2->ED2_QTD)/100
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB - (WorkED2->ED2_PERCPE * WorkED2->ED2_VALEMB)/100
         Else
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB
         EndIf
      Endif

      WorkED2->ED2_RECNO  := ED2->(RECNO())
      WorkED2->TRB_ALI_WT := "ED2"
      WorkED2->TRB_REC_WT := ED2->(Recno())
      WorkED2->ED2_DESCIT := Posicione("SB1",1,xFilial("SB1"/*"ED2"*/)+WorkED2->ED2_ITEM,"B1_DESC")  // GFP - 30/08/2012
      WorkED2->ED2_DESCPD := Posicione("SB1",1,xFilial("SB1"/*"ED2"*/)+WorkED2->ED2_PROD,"B1_DESC")  // GFP - 30/08/2012
      If !lCopia
         AC400Totais("WorkED2",INCLUIR)
      EndIf
      WorkED2->(msUnlock())

      ED2->(dbSkip())
   EndDo
   WorkED2->(dbGoTop())
EndIf

//WorkED4
IncProc(STR0071) //"Processando..."
dbSelectArea("ED4")
ED4->(dbSetOrder(1))
If ED4->(dbSeek(cFilED4+ED0->ED0_PD))
   Do While !ED4->(EOF()) .and. ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_PD==ED0->ED0_PD
      WorkED4->(RecLock("WorkED4",.T.))
      FOR i := 1 TO ED4TotCpos
         cCampo:=FIELDNAME(i)
         WorkED4->&(cCampo) := ED4->&(cCampo)
      NEXT i
      WorkED4->ED4_RECNO := ED4->(RECNO())
      WorkED4->TRB_ALI_WT:= "ED4"
      WorkED4->TRB_REC_WT:= ED4->(Recno())
      WorkED4->(msUnlock())
      WorkED4->ED4_DESCIT := Posicione("SB1",1,xFilial("SB1"/*"ED4"*/)+WorkED4->ED4_ITEM,"B1_DESC")  // GFP - 30/08/2012

      ED4->(dbSkip())
   EndDo
   WorkED4->(dbGoTop())
EndIf

//WorkEDA
EDATotCpos:=EDA->(FCount())
IncProc(STR0071) //"Processando..."
dbSelectArea("EDA")
EDA->(dbSetOrder(1))
If EDA->(dbSeek(cFilEDA+ED0->ED0_PD))
   Do While !EDA->(EOF()) .and. EDA->EDA_FILIAL==cFilEDA .and. EDA->EDA_PD==ED0->ED0_PD
      WorkEDA->(RecLock("WorkEDA",.T.))
      FOR i := 1 TO EDATotCpos
         cCampo:=FIELDNAME(i)
         WorkEDA->&(cCampo) := EDA->&(cCampo)
      NEXT i
      WorkEDA->EDA_RECNO := EDA->(RECNO())
      WorkEDA->TRB_ALI_WT:= "EDA"
      WorkEDA->TRB_REC_WT:= EDA->(Recno())
      WorkEDA->EDA_DESCIT := Posicione("SB1",1,xFilial("SB1"/*"EDA"*/)+WorkEDA->EDA_ITEM,"B1_DESC")  // GFP - 30/08/2012
      WorkEDA->(msUnlock())

      EDA->(dbSkip())
   EndDo
   WorkEDA->(dbGoTop())
EndIf

//WorkEDB
EDBTotCpos:=EDB->(FCount())
IncProc(STR0071) //"Processando..."
dbSelectArea("EDB")
EDB->(dbSetOrder(1))
If EDB->(dbSeek(cFilEDB+ED0->ED0_PD))
   Do While !EDB->(EOF()) .and. EDB->EDB_FILIAL==cFilEDB .and. EDB->EDB_PD==ED0->ED0_PD
      WorkEDB->(RecLock("WorkEDB",.T.))
      FOR i := 1 TO EDBTotCpos
         cCampo:=FIELDNAME(i)
         WorkEDB->&(cCampo) := EDB->&(cCampo)
      NEXT i
      WorkEDB->EDB_RECNO := EDB->(RECNO())
      WorkEDB->EDB_PD    := ED0->ED0_PD
      WorkEDB->TRB_ALI_WT:= "EDB"
      WorkEDB->TRB_REC_WT:= EDB->(Recno())
      WorkEDB->(msUnlock())

      EDB->(dbSkip())
   EndDo
   WorkEDB->(dbGoTop())
EndIf

//WorkEDC
EDCTotCpos:=EDC->(FCount())
IncProc(STR0071) //"Processando..."
dbSelectArea("EDC")
EDC->(dbSetOrder(1))
If EDC->(dbSeek(cFilEDC+ED0->ED0_PD))
   Do While !EDC->(EOF()) .and. EDC->EDC_FILIAL==cFilEDC .and. EDC->EDC_PD==ED0->ED0_PD
      WorkEDC->(RecLock("WorkEDC",.T.))
      FOR i := 1 TO EDCTotCpos
         cCampo:=FIELDNAME(i)
         WorkEDC->&(cCampo) := EDC->&(cCampo)
      NEXT i
      WorkEDC->EDC_RECNO := EDC->(RECNO())
      WorkEDC->EDC_PD    := ED0->ED0_PD
      WorkEDC->TRB_ALI_WT:= "EDC"
      WorkEDC->TRB_REC_WT:= EDC->(Recno())
      WorkEDC->EDC_DESCIT := Posicione("SB1",1,xFilial("SB1"/*"EDC"*/)+WorkEDC->EDC_ITEM,"B1_DESC")   // GFP - 30/08/2012
      WorkEDC->EDC_DESCPD := Posicione("SB1",1,xFilial("SB1"/*"EDC"*/)+WorkEDC->EDC_PROD,"B1_DESC")  // GFP - 30/08/2012
         //ER - 25/09/2007
         SX3->(DbSetOrder(2))
         If SX3->(DbSeek("EDC_FATGRO"))
            WorkEDC->EDC_FATGRO := WorkEDC->((EDC_QTDBAS * EDC_QTDEST) / EDC_QTDPRO)
         EndIf

         If SX3->(DbSeek("EDC_FATNET"))
            WorkEDC->EDC_FATNET := WorkEDC->(EDC_FATGRO*(1 - EDC_PERDA/100))
         EndIf

      WorkEDC->(msUnlock())

      EDC->(dbSkip())
   EndDo
   WorkEDC->(dbGoTop())
EndIf


//AOM - 29/10/10 - WorkEDD
If lCopia
   cAto := WorkED0->ED0_AC
   cPed := WorkED0->ED0_PD
Else
   cAto := M->ED0_AC
   cPed := M->ED0_PD
EndIf

QryBxInsumos(cAto,cPed)

IncProc(STR0071) //"Processando..."
QRY->(DbGoTop())
While QRY->(!EOF())
   WorkEDD->(DBAPPEND())

   /*AOM - 06/07/2011 - Verifica se o PO e o Hawb estao preenchidos caso esteja é do EIC caso um dos dois nao esteja ou é DI Externa ou Compras Nacionais */
   If Empty(QRY->EDD_PO_NUM) .Or. Empty(QRY->EDD_HAWB)
      lDIExt := .T.
   EndIf

   /*AOM - 06/07/2011 - Verifica se a exportação foi feita pelo SIGAEEC
   Caso Sim o campo "QRY->EDD_PEDIDO" estará preenchido. */
   If Empty(QRY->EDD_PEDIDO)
      lReExt := .T.
   EndIf

   //AOM - 10/11/2011
   If AvFlags("SEQMI")
      WorkEDD->SEQMI := QRY->EDD_SEQMI
   EndIf

   WorkEDD->SEQSII := QRY->EDD_SEQSII
   WorkEDD->ITEM   := QRY->EDD_ITEM
   WorkEDD->TPOCOR := "Exportação"
   If !Empty(QRY->EDD_PREEMB) .And. Empty(QRY->EDD_PEDIDO)
      WorkEDD->CODOCO := QRY->EDD_PREEMB
   Else
      WorkEDD->CODOCO := QRY->EDD_PEDIDO
   EndIf
   WorkEDD->DTOCOR := QRY->EDD_DTRE
   WorkEDD->RESOCO := "Baixa regular"

   //AOM - 10/11/2011
   If AvFlags("SEQMI") .And. Empty(QRY->EDD_HAWB)
      WorkEDD->UNIDME := Posicione("ED4",8,xFilial("ED4")+AvKey(QRY->EDD_AC,"EDD_AC")+AvKey(QRY->EDD_SEQMI,"EDD_SEQMI"),"ED4_UMITEM")
   Else
      WorkEDD->UNIDME := Posicione("ED4",2,xFilial("ED4")+AvKey(QRY->EDD_AC,"EDD_AC")+AvKey(QRY->EDD_SEQSII,"EDD_SEQSII"),"ED4_UMITEM")
   EndIf
   WorkEDD->QTD    := QRY->EDD_QTD
   WorkEDD->VALOR  := Posicione("SW8",6, IIf(lMultiFil, QRY->EDD_FILIMP, xFilial("SW8"))+QRY->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU),"W8_VL_AC")
   WorkEDD->HAWB   := QRY->EDD_HAWB
   SW6->(DbSetOrder(1))
   If SW6->(DbSeek(IIf(lMultiFil, QRY->EDD_FILIMP, xFilial("SW6"))+AvKey(QRY->EDD_HAWB,"W6_HAWB")))
      WorkEDD->NRDI   :=  SW6->W6_DI_NUM
   EndIf
   WorkEDD->DTDI   := QRY->EDD_DTREG
   WorkEDD->CDFORN := Posicione("SW8",6,IIf(lMultiFil, QRY->EDD_FILIMP, xFilial("SW8"))+QRY->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU),"W8_FORN")
   If EICLoja()
      WorkEDD->LOJA   := Posicione("SW8",6,IIf(lMultiFil, QRY->EDD_FILIMP, xFilial("SW8"))+QRY->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU),"W8_FORLOJ")
   EndIf
   WorkEDD->NRINV  := QRY->EDD_INVOIC
   WorkEDD->CDEMB  := QRY->EDD_PREEMB
   WorkEDD->CDPED  := QRY->EDD_PEDIDO

   EE9->(DbSetOrder(2))
   EEC->(DBSeek(IIf(lMultiFil, QRY->EDD_FILEXP, xFilial("EEC")) + QRY->EDD_PREEMB))
   If EE9->(DbSeek(IIf(lMultiFil, QRY->EDD_FILEXP, xFilial("EE9"))+QRY->(EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN )))
      If !Empty(EEC->EEC_NRODUE)
         WorkEDD->NRRE:= EEC->EEC_NRODUE
      Else
         WorkEDD->NRRE:= EE9->EE9_RE    //Posicione("EE9",2,xFilial("EE9")+QRY->(EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN),"EE9_RE")
      EndIf
      WorkEDD->ITEMB  := EE9->EE9_SEQEMB//Posicione("EE9",2,xFilial("EE9")+QRY->(EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN),"EE9_SEQEMB")
   EndIf

   WorkEDD->PRODEX := QRY->EDD_PROD
   WorkEDD->UMPROD := Posicione("ED3",8,xFilial("ED3")+AvKey(cPed,"ED0_PD")+QRY->EDD_PROD,"ED3_UMPROD")
   WorkEDD->QTDEX  := QRY->EDD_QTD_EX
   If lDIExt
      //AOM - 10/11/2011
      If AvFlags("SEQMI") .And. !Empty(QRY->EDD_SEQMI)
         ED8->(DbSetOrder(8))
         cCampo := QRY->EDD_SEQMI
      Else
         ED8->(DbSetOrder(3))
         cCampo := QRY->EDD_SEQSII
      EndIf

      If ED8->(DbSeek(xFilial("ED8")+QRY->EDD_AC+cCampo))

         While ED8->(!Eof()) .And. ED8->ED8_FILIAL == ED8->(xFilial()) .And. ED8->ED8_AC == QRY->EDD_AC .And.;
               IF(AvFlags("SEQMI") .And. !Empty(QRY->EDD_SEQMI), ED8->ED8_SEQMI, ED8->ED8_SEQSIS) == cCampo

            If left(QRY->EDD_HAWB, Len(ED8->ED8_DI_NUM)) == ED8->ED8_DI_NUM .Or. (Empty(QRY->EDD_HAWB)  .And. AvFlags("SEQMI"))

               WorkEDD->VALOR  := ED8->ED8_VALEMB
               WorkEDD->CDFORN := ED8->ED8_FORN
               WorkEDD->LOJA   := ED8->ED8_LOJA
               WorkEDD->NRDI   := ED8->ED8_DI_NUM

               Exit
            EndIf

            ED8->(DBSkip())
         EndDo
      EndIf


   Else
      //AOM - 06/07/2011 - Invoices
      SW8->(DbSetOrder(6))
      If SW8->(DbSeek(IIf(lMultiFil, QRY->EDD_FILIMP, xFilial("SW8"))+QRY->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU)))
         WorkEDD->VALOR  := SW8->W8_VL_AC//Posicione("SW8",6,xFilial("SW8")+QRY->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU),"W8_VL_AC")
         WorkEDD->CDFORN := SW8->W8_FORN //Posicione("SW8",6,xFilial("SW8")+QRY->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU),"W8_FORN")
         If EICLoja()
            WorkEDD->LOJA   := SW8->W8_FORLOJ//Posicione("SW8",6,xFilial("SW8")+QRY->(EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU),"W8_FORLOJ")
         EndIf
      EndIf

      //AOM - 06/07/2011 - Desembaraço
      SW6->(DbSetOrder(1))
      If SW6->(DbSeek(IIf(lMultiFil, QRY->EDD_FILIMP, xFilial("SW6"))+AvKey(QRY->EDD_HAWB,"W6_HAWB")))
         WorkEDD->NRDI   :=  SW6->W6_DI_NUM
      EndIf

   EndIf

   If lReExt

      WorkEDD->NRRE  := SUBSTR(QRY->EDD_PREEMB,1,14)

   Else

      //AOM - 06/07/2011 - Embarque
      EE9->(DbSetOrder(2))
      EEC->(DBSeek(IIf(lMultiFil, QRY->EDD_FILEXP, xFilial("EEC")) + QRY->EDD_PREEMB))
      If EE9->(DbSeek(IIf(lMultiFil, QRY->EDD_FILEXP, xFilial("EE9"))+QRY->(EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN )))
         If !Empty(EEC->EEC_NRODUE)
            WorkEDD->NRRE:= EEC->EEC_NRODUE
         Else
            WorkEDD->NRRE:= EE9->EE9_RE    //Posicione("EE9",2,xFilial("EE9")+QRY->(EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN),"EE9_RE")
         EndIf
         WorkEDD->ITEMB  := EE9->EE9_SEQEMB//Posicione("EE9",2,xFilial("EE9")+QRY->(EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN),"EE9_SEQEMB")
      EndIf

   EndIf

   QRY->(DbSkip())
 EndDo

 If ChkFile("EDH")
    IncProc(STR0071) //"Processando..."
    QRY2->(DbGoTop())
    While QRY2->(!EOF())
       WorkEDD->(DBAPPEND())
       //AOM - 10/11/2011
       If AvFlags("SEQMI")
          WorkEDD->SEQMI := QRY2->EDH_SEQMI
       EndIf
       WorkEDD->SEQSII := QRY2->EDH_SEQSIS
       WorkEDD->ITEM   := QRY2->EDH_COD_I
       WorkEDD->TPOCOR := BSCXBOX("EDH_TPOCOR",QRY2->EDH_TPOCOR)
       WorkEDD->CODOCO := QRY2->EDH_CODOCO
       WorkEDD->DTOCOR := QRY2->EDH_DTOCOR
       WorkEDD->RESOCO := QRY2->EDH_RESOCO
       WorkEDD->UNIDME := QRY2->EDH_UMPROC
       WorkEDD->QTD    := QRY2->EDH_QTDOCO
       WorkEDD->VALOR  := QRY2->EDH_VALOCO
       WorkEDD->HAWB   := QRY2->EDH_HAWB
       WorkEDD->NRDI   := QRY2->EDH_DI_NUM
       WorkEDD->DTDI   := QRY2->EDH_DT_DI
       WorkEDD->CDFORN := QRY2->EDH_FORN
       WorkEDD->LOJA   := QRY2->EDH_LOJA
       WorkEDD->NRINV  := QRY2->EDH_INVOIC
    QRY2->(DbSkip())
    EndDo

    QRY2->(DbCloseArea())
 EndIf

 QRY->(DbCloseArea())

 WorkEDD->(DbGoTop())
Return .T.

*-----------------------------*
Static Function AC400DelWorks()
*-----------------------------*
Local W

FOR W := 1 TO LEN(aTabelas)
   If !Empty(aTabelas[W,1])
      (aTabelas[W,1])->(E_EraseArq(aTabelas[W,2]))
   Else
      FErase(aTabelas[W,2]+TEOrdBagExt())
   EndIf
NEXT
aTabelas:={}

dbSelectArea("ED0")

Return .T.

*------------------------------------------*
Static Function AC400PEManut(nOpca, cModo)         // C
*------------------------------------------*
Local oDlgC, nSelecao:=0, bOk1:={||nSelecao:=1,oDlgC:End()}, i , nInd
Local aGetsAux:={}, aTelaAux:={}, aAtuCpos:={}, aBotao:={}
Local nOldOrd:=WorkED2->(IndexOrd()), nPos
Local nAltQtd := 0, nTipo:=nOpca, aExport:= {}
Local COLUNA_FINAL
Local cFilter := WorkEd2->(DbFilter()) //LRS - 28/07/2015

Private nRec:=WorkED1->ED1_RECNO, cTit:=STR0072,cEstru := "3"//LRS  //"Manutencao de Produtos a Exportar " //"3 - Não atualizar" - não atualizar os insumos quando houver atualização do compromisso de exportação

// PLB 09/11/06 - Alterado para Private para ser utilizada na função AC400Valid()
Private nOldOpc := nOpca //Guarda a Opção devido a problema no Estorno de Itens(Work)

If nOpca <> INCLUIR //LRS - 29/07/2015
   WorkED2->(DbClearFilter())
EndIF

If cModo == ISENCAO
   Aadd(aExport,"ED1_PROD");   Aadd(aExport,"ED1_NCM")
   Aadd(aExport,"ED1_QTDNCM"); Aadd(aExport,"ED1_PRCUNI")
   Aadd(aExport,"ED1_UMPROD"); Aadd(aExport,"ED1_VAL_EM")
   Aadd(aExport,"ED1_VAL_SE"); Aadd(aExport,"ED1_PERCAG")
   Aadd(aExport,"ED1_VALCOM"); Aadd(aExport,"ED1_PREEMB")
   Aadd(aExport,"ED1_RE");     Aadd(aExport,"ED1_DTRE")
   Aadd(aExport,"ED1_MOEDA");  Aadd(aExport,"ED1_TX_USS")
   Aadd(aExport,"ED1_TX_MOE"); Aadd(aExport,"ED1_DTEMBA")
   Aadd(aExport,"ED1_PESO");   Aadd(aExport,"ED1_UMNCM")

   if lED1Umanex   // ACSJ - 17/11/2004
      Aadd(aExport,"ED1_UMANEX")
   Endif
   Aadd(aExport,"ED1_QTD")
   If ED1->( FieldPos("ED1_NCMANT") ) > 0
      aAdd(aExport,"ED1_NCMANT")
   Endif

   If lMultiFil
      AAdd(aExport,"ED1_FILORI")
   EndIf

Endif

aGetsAux := aClone(aGets)
aTelaAux := aClone(aTela)
If lAbriuExp
   Aadd(aBotao,{"PESQUISA",{|| EDCAC400HLP(@M->ED1_PROD) },STR0073}) //"Pesquisa de Produtos"
EndIf

Do While .T.

   If nOpca <> INCLUIR
      dbSelectArea("WorkED1")
      If WorkED1->(EasyRecCount()) <= 0 .or. (WorkED1->(BOF()) .and. WorkED1->(EOF()))
         Help("", 1, "ARQVAZIO")
         Return .T.
      EndIf
      cTit+=Alltrim(WorkED1->ED1_PROD)
      FOR i := 1 TO FCount()
         M->&(FIELDNAME(i)) := FieldGet(i)
      NEXT i
      M->ED1_VALCOM := M->ED1_VAL_EM * M->ED1_PERCAG / 100 //AAF 20/04/05 - Valor da Comissão do Agente.
   Else
      lIncluiAux := .T.
      dbSelectArea("ED1")
      FOR nInd := 1 TO FCount()
         M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
      NEXT
      M->ED1_RECNO  := 0
      M->TRB_ALI_WT := ""
      M->TRB_REC_WT := 0
      If lAbriuExp
         SETKEY(VK_F4,{||EDCAC400HLP(@M->ED1_PROD)}) // F4 para produtos a exportar
      Endif
   EndIf

   aGets:={}
   aTela:={}
   dbSelectArea("WorkED1")

   If nOpca = VISUALIZAR
      ED1->(dbGoTo(nRec))
   ElseIf nOpca = ESTORNAR
      nOpca := ALTERAR
   EndIf

   DEFINE MSDIALOG oDlgC TITLE cTit ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL

      COLUNA_FINAL := (oDlgC:nClientWidth-4)/2
      nLinha       := (oDlgC:nClientHeight-4)/2

      oEnCht := msmget():New("ED1",nRec,nOpca,,,,If(cModo==ISENCAO,aExport, ),{15,1,nLinha,COLUNA_FINAL},If(nOldOpc=ESTORNAR,{}, ),3)
      oEncht:oBox:Align := CONTROL_ALIGN_ALLCLIENT

      AC400Valid("ED1_VAL_EM")

   ACTIVATE MSDIALOG oDlgC ON INIT EnchoiceBar(oDlgC,;
                                   {|| IIF(nOldOpc==ESTORNAR .Or.;
                                           nOpca=VISUALIZAR .or.;
                                            ( Obrigatorio(aGets,aTela) .and. AC400Valid("FINALPE") .And.;
                                            IIF(nOpca==ALTERAR .And. M->ED1_QTDNCM != WorkED1->ED1_QTDNCM;
                                                ,oMUserEDC:Reserva("ATO","PRODUTO");
                                                ,.T.));
                                           ,Eval(bOk1),)},{||nSelecao:=0,oDlgC:End()},,aBotao)

   WorkED3->(dbGoTop())
   nOpca := nOldOpc
   nAltQtd := 0
   If nSelecao = 1
      dbSelectArea("WorkED1")
      If nOpca=INCLUIR .or. nOpca=ALTERAR
         WorkED3->(dbSetOrder(1))

         If nOpca=ALTERAR .and. (lIndPercAg .AND. M->ED1_PERCAG <> WorkED1->ED1_PERCAG .or.;
         (M->ED1_UMNCM <> WorkED1->ED1_UMNCM .and. iif(lED1Umanex,Empty(M->ED1_UMANEX),.t.)) .or.;      // ACSJ - 17/11/2004
         M->ED1_NCM <> WorkED1->ED1_NCM .or. iif(lED1Umanex,M->ED1_UMANEX <> WorkED1->ED1_UMANEX,.F.))  // ACSJ - 17/11/2004

            If lIndPercAg
               cChaveED3 := WorkED1->ED1_NCM+WorkED1->ED1_PROD+Str(WorkED1->ED1_PERCAG,5,2)+;
               iif(lED1Umanex,If(Empty(WorkED1->ED1_UMANEX),WorkED1->ED1_UMNCM,WorkED1->ED1_UMANEX),WorkED1->ED1_UMNCM)
            Else
               cChaveED3 := WorkED1->ED1_NCM+WorkED1->ED1_PROD+;
               iif(lED1Umanex,If(Empty(WorkED1->ED1_UMANEX),WorkED1->ED1_UMNCM,WorkED1->ED1_UMANEX),WorkED1->ED1_UMNCM)
            EndIf

            If WorkED3->(dbSeek(cChaveED3))
               WorkED3Atu("WorkED1",ESTORNAR)
               nTipo:=INCLUIR
            EndIf
         EndIf
         WorkED3Atu("M",nTipo)
         If(nOpca=ALTERAR , AC400Totais("WorkED1",ESTORNAR) , )
         WorkED1->(RecLock("WorkED1",If(nOpca=INCLUIR,.T.,.F.)))
         If M->ED1_QTD <> WorkED1->ED1_QTD
            nAltQtd := M->ED1_QTD - WorkED1->ED1_QTD
         EndIf
         FOR i := 1 TO FCount()
            If AllTrim(FIELDNAME(i)) == "ED1_DESCPD"
               WorkED1->&(FIELDNAME(i)) := Posicione("SB1",1,xFilial("SB1"/*"ED1"*/)+M->ED1_PROD,"B1_DESC")  // GFP - 30/08/2012
            Else
               WorkED1->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
            EndIf

         NEXT i
         // A. Caetano - ACSJ - 04/03/2004
         If lMultiFil  .And.  M->ED0_MODAL == ISENCAO
            WorkED1->ED1_FILORI := Left(M->ED1_FILORI,2) + " - " + AvgFilName({Left(M->ED1_FILORI,2)})[1]
         EndIf
         If WorkED1->ED1_UMNCM == WorkED1->ED1_UMPROD
            WorkED1->ED1_COEFEC := 1
         Else
            AVTransUnid(WorkED1->ED1_UMNCM,WorkED1->ED1_UMPROD,WorkED1->ED1_PROD,1)
            WorkED1->ED1_COEFEC := iif( ( SJ5->(Eof()) .or. SJ5->(Bof()) ), 0, SJ5->J5_COEF )
         Endif

         If nOpca=INCLUIR
            WorkED1->TRB_ALI_WT:= "ED1"
            WorkED1->TRB_REC_WT:= ED1->(Recno())
         Endif
         //--------------------------------------------------------------------------------
         If lIncluiAux
            WorkED1->ED1_SEQ := StrZero(nSeq,nLenSeqED1)
            nSeq += 1
         EndIf
         AC400Totais("WorkED1",INCLUIR)

         //Verifica se é integrado - AOM - 25/10/10
         If ED0->(FieldPos("ED0_INTEGR")) > 0
            If M->ED0_INTEGR == "S"
               lIntegra := .T.
            EndIf
         EndIf

         If !Empty(Alltrim(WorkED1->ED1_PROD)) .and. M->ED0_MODAL == SUSPENSAO
            If nOpca=INCLUIR
               SG1->(dbSetOrder(1))
               If SG1->(dbSeek(cFilSG1+WorkED1->ED1_PROD)) .And. lRecalcIn
                  nEstru:=0 //Usado na Função Estrut2
                  FileWork12 := AVEstrut2(WorkED1->ED1_PROD,WorkED1->ED1_QTD,"WorkEstru",,,lIntegra)
                  Processa({|| AtuWorkED2(WorkED1->ED1_QTD,M->ED1_VAL_EM - M->ED1_VALCOM)},STR0074) //"Atualizando Itens a Importar"
                  AvFimEstrut2("WorkEstru",FileWork12)
               Else
                  AC400GrvEDA(INCLUIR,WorkED1->ED1_PROD,0,WorkED1->ED1_QTD,cMarca)
                  AC400EDCGrv(INCLUIR,WorkED1->ED1_PROD,WorkED1->ED1_RE,WorkED1->ED1_PROD,0,WorkED1->ED1_QTD,cMarca)
               EndIf
            EndIf

            If nOpca == ALTERAR

               WorkED2->(DBSetOrder(2))
               WorkED2->(DBSeek(WorkED1->ED1_PROD + WorkED1->ED1_SEQ))

               If lRecalcIn

                  If cEstru == "1" //1 - Estrutura do ato concessório // LRS - Atualização normal da estrutura
                     If nAltQtd <> 0
                        Processa({|| AlteraExplodidos(WorkED1->ED1_QTD - nAltQtd)}, STR0074) //"Atualizando Itens a Importar"
                     EndIf
                  ElseIf cEstru == "2" //"2 - Cadastro de estruturas"
                     SG1->(DBSetOrder(1))
                     If SG1->(DBSeek(cFilSG1 + WorkED1->ED1_PROD))
                           Processa({|| ReapurarInsumo(cEstru, WorkED1->ED1_QTD - nAltQtd)}, STR0074) //"Atualizando Itens a Importar"
                     EndIf
                  EndIf

               ElseIf cEstru == "3" // "3 - Não atualizar" - default da variável
                  //Atualização do resumo técnico
                  Processa({|| AlteraExplodidos(WorkED1->ED1_QTD - nAltQtd, .T.)}) //"Atualizando Itens a Importar"
               EndIf
            EndIf
         EndIf

         //AOM - 16/11/10 - Desabilita o campo ED0_INTEGR para alteraçao após inclusão de estrutura
         lED0Int := .F.

      ElseIf nOpca=ESTORNAR
         If !VerED3Saldo("ESTORNO","M") .and. M->ED0_MODAL <> ISENCAO
            Help(" ",1,"AVG0005145") //"Produto não pode ser estornado pois existe movimentacao."
         Else
            If MsgYesNo(STR0076)  .And.  oMUserEDC:Reserva("ATO","PRODUTO") //"Deseja Realmente Excluir este Produto?"
               aAdd(aDelWkED1,WorkED1->ED1_RECNO)
               WorkED3Atu("WorkED1",nOpca)
               WorkED2->(dbSetOrder(2))
               If WorkED2->(dbSeek(WorkED1->ED1_PROD+WorkED1->ED1_SEQ))
                  Processa({|| EstWorkED2(WorkED1->ED1_PROD,WorkED1->ED1_SEQ,.T.)},STR0074) //"Atualizando Itens a Importar"
               Else
                  WorkED2->(dbSetOrder(6))
                  If M->ED0_MODAL == ISENCAO .and. WorkED2->(dbSeek(WorkED1->ED1_RE+WorkED1->ED1_PROD))
                     Processa({|| EstED2Ante(WorkED1->ED1_RE,WorkED1->ED1_PROD)},STR0074) //"Atualizando Itens a Importar"
                  EndIf
               EndIf
               AC400Totais("WorkED1",ESTORNAR)
               SG1->(dbSetOrder(1))
               If SG1->(dbSeek(cFilSG1+WorkED1->ED1_PROD))
                  nEstru:=0 //Usado na Função Estrut2
                  FileWork12 := AVEstrut2(WorkED1->ED1_PROD,WorkED1->ED1_QTD,"WorkEstru",,,lIntegra)
                     AC400GrvEDA(12,,,,,WorkED1->ED1_QTD)
                  AvFimEstrut2("WorkEstru",FileWork12)
                     dbSelectArea("WorkED1") //AAF 12/04/05 - Mantém uma area aberta.
               Else
                  AC400GrvEDA(ESTORNAR,WorkED1->ED1_PROD,0,WorkED1->ED1_QTD)
                  AC400EDCGrv(ESTORNAR,WorkED1->ED1_PROD,WorkED1->ED1_RE,WorkED1->ED1_PROD,0,WorkED1->ED1_QTD)
               EndIf
               WorkED1->(RecLock("WorkED1",.F.,.T.))
               WorkED1->(DBDELETE())
            EndIf
         EndIf

         //AOM - 16/11/10 - Habilita o campo ED0_INTEGR para alteraçao após exclusao de estrutura
         lED0Int := .T.
      EndIf
      WorkED1->(MSUnlock())
   EndIf

   If nOpca<>INCLUIR .or. nSelecao=0
      lIncluiAux := .F.
      dbSelectArea("WorkED1") //LRL 25/05/04
      oMark:oBrowse:Refresh()
      Exit
   EndIf
   nSelecao := 0

EndDo

lRecalcIn:= .T. //TRP - 22/11/2011

aGets := aClone(aGetsAux)
aTela := aClone(aTelaAux)
nSelecao := 0

If lAbriuExp .And. nOpca = INCLUIR  // Desabilita o F4 caso esteja ativo
   SETKEY(VK_F4,NIL)
Endif

//oMark5:oBrowse:Refresh()- AOM - 27/10/10

If nOpca <> INCLUIR .AND. !Empty(cFilter) //LRS - 29/07/2015
   WorkED2->(DBSetFilter(&("{|| " + cFilter + "}"), cFilter )) //LRS - 28/07/2015
EndIF

oMark6:oBrowse:Refresh()
oMark7:oBrowse:Refresh()
WorkED2->(DBSetOrder(nOldOrd))
Return .T.

*-----------------------------------------------*
Static Function AC400PIManut(nOpca,lMarca,cModo)   // D
*-----------------------------------------------*
Local oDlgD, nSelecao:=0, bOk1:={||nSelecao:=1,oDlgD:End()}, i , nInd
Local aGetsAux:={}, aTelaAux:={}, aAtuCpos:={}, nTipo:=nOpca
Local nOldOpc:=nOpca //Guarda a Opção devido a problema no Estorno de Itens(Work)
Local COLUNA_FINAL
Local cImport := "" //AOM - 10/11/2011
Local aIsencao //AOM - 26/03/2012
Private nRec:=WorkED2->ED2_RECNO, aImport:={}, lComp:=.F.
Private nQtdDiEst:=0, nQtdLiEst:=0, nSNcmLiEst:=0, nSNcmDiEst:=0, nValLiEst:=0, nValDiEst:=0
Private nQtdCalEst:=0, nValCalEst:=0, nQtNcmEst:=0, cSeq4Aux:="", cSeqMiAux:= ""
Private cTit:=STR0077 //"Manutencao de Itens a Importar "
lMarca:=If(lMarca<>NIL,lMarca,.F.)
Private lMarcacao:=lMarca

If cModo == ISENCAO
   Aadd(aImport,"ED2_ITEM");   Aadd(aImport,"ED2_PROD")
   Aadd(aImport,"ED2_NCM");    Aadd(aImport,"ED2_COEF")
   Aadd(aImport,"ED2_QTDORI"); Aadd(aImport,"ED2_QTDNCM")
   Aadd(aImport,"ED2_PRCUNI"); Aadd(aImport,"ED2_UMITEM")
   Aadd(aImport,"ED2_VALEMB"); Aadd(aImport,"ED2_PERCPE")
   Aadd(aImport,"ED2_QTDCAL"); Aadd(aImport,"ED2_VALCAL")
   Aadd(aImport,"ED2_CAMB");   Aadd(aImport,"ED2_FRETE")
   Aadd(aImport,"ED2_FR_USS"); Aadd(aImport,"ED2_MOE_FR")
   Aadd(aImport,"ED2_TX_FR");  Aadd(aImport,"ED2_SEGURO")
   Aadd(aImport,"ED2_SE_USS"); Aadd(aImport,"ED2_MOE_SE")
   Aadd(aImport,"ED2_TX_SE");  Aadd(aImport,"ED2_HAWB")
   Aadd(aImport,"ED2_DI_NUM"); Aadd(aImport,"ED2_ADICAO")
   Aadd(aImport,"ED2_DTREG");  Aadd(aImport,"ED2_INVOIC")
   Aadd(aImport,"ED2_MOEDA");  Aadd(aImport,"ED2_TX_MOE")
   Aadd(aImport,"ED2_TX_USS"); Aadd(aImport,"ED2_PESO")
   Aadd(aImport,"ED2_UMNCM");  Aadd(aImport,"ED2_QTD")
   if lED2Umanex   // ACSJ - Verifica se existe o campo no SX3 - 17/11/2004
      Aadd(aImport,"ED2_UMANEX")
   Endif
   if lED2Inat   // ACSJ - 17/11/2004
      Aadd(aImport,"ED2_INAT")
   Endif
   Aadd(aImport,"ED2_RE");     Aadd(aImport,"ED2_PERCAP")

   //AAF - 10/11/05 - Valor com Preço Original na Moeda da Invoice.
   aAdd(aImport,"ED2_VALORI")

   If ED2->( FieldPos("ED2_VLCOPE") ) > 0
      aAdd(aImport,"ED2_VLCOPE")
   Endif
   If ED2->( FieldPos("ED2_NCMANT") ) > 0
      aAdd(aImport,"ED2_NCMANT")
   Endif

   If lMultiFil
      AAdd(aImport,"ED2_FILORI")
   EndIf

   //AOM - 23/03/2012 - DI Original
   If AVFLAGS("DI_ORIGINAL")
      Aadd(aImport,"ED2_DI_ORI"  )
      Aadd(aImport,"ED2_ADANT"   )
   EndIf
   If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"CPOS_IMP_ISEN"),)

Else //AOM - 30/10/10 - Definição dos campos apresentados na enchoice para modalidade Suspensão
   Aadd(aImport,"ED2_ITEM")
   Aadd(aImport,"ED2_PROD")
   Aadd(aImport,"ED2_NCM")
   Aadd(aImport,"ED2_COEF")
   Aadd(aImport,"ED2_QTD")
   Aadd(aImport,"ED2_UMITEM")
   Aadd(aImport,"ED2_PRCUNI")
   Aadd(aImport,"ED2_VALEMB")
   Aadd(aImport,"ED2_PERCPE")
   Aadd(aImport,"ED2_PERCAP")
   Aadd(aImport,"ED2_QTDCAL")
   Aadd(aImport,"ED2_VALCAL")
   Aadd(aImport,"ED2_CAMB")

   If ED2->( FieldPos("ED2_VLCOPE") ) > 0
      aAdd(aImport,"ED2_VLCOPE")
   Endif

   //AOM - 09/11/2011
   If AvFlags("SEQMI")
      aAdd(aImport,"ED2_IMPORT")
   Endif

Endif

aGetsAux := aClone(aGets)
aTelaAux := aClone(aTela)
Do While .T.

   If nOpca <> INCLUIR

      dbSelectArea("WorkED2")
      If WorkED2->(EasyRecCount()) <= 0 .or. (WorkED2->(BOF()) .and. WorkED2->(EOF()))
         Help("", 1, "ARQVAZIO")
         Return .T.
      EndIf
      cTit+=Alltrim(WorkED2->ED2_ITEM)
      FOR i := 1 TO FCount()
         M->&(FIELDNAME(i)) := FieldGet(i)
      NEXT i

      // ** AAF 06/04/05 - Não permite estorno caso o item seja usado em uma PLI.
      // Se o item estiver desmarcado, não é necessário validar o saldo; uma vez desmarcado, o saldo foi consistido.
      If nOpca == ESTORNAR .AND. !Empty(M->ED0_AC) .AND. (WorkED2->ED2_MARCA == cMarca .And. !VerED4Saldo("MARCA","WorkED2"))
         MsgStop(STR0301)//"Item não pode ser excluido pois possui movimentação."
         Return .F.
      Endif
      // **
      aIsencao := aClone(aImport)
      IF AVFLAGS("DI_ORIGINAL")
         aIsencao := AC400IsenED2(aIsencao,{"ED2_QTD","ED2_QTDNCM"})//AOM - 26/03/2012 - Retira os campos de quantidades para nao serem alterados
      EndIf
   Else
      lIncluiAux := .T.
      dbSelectArea("ED2")
      FOR nInd := 1 TO FCount()
         M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
      NEXT
      M->ED2_RECNO := 0
      M->TRB_ALI_WT := ""
      M->TRB_REC_WT := 0
      //AOM - 23/03/2012 - DI Original
      If AVFLAGS("DI_ORIGINAL")
         M->ED2_SEQIT := RetUltSeqIt()
      EndIf
   EndIf

   aGets:={}
   aTela:={}
   dbSelectArea("WorkED2")

   If nOpca == VISUALIZAR
      ED2->(dbGoTo(nRec))
   ElseIf nOpca == ESTORNAR
      nOpca:=ALTERAR
   EndIf

   DEFINE MSDIALOG oDlgD TITLE cTit ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL

      COLUNA_FINAL := (oDlgD:nClientWidth-4)/2
      nLinha       := (oDlgD:nClientHeight-4)/2

      oEncht := msmget():New("ED2",nRec,nOpca,,,,If(cModo==ISENCAO,aImport, ),{15,1,nLinha,COLUNA_FINAL},If(nOldOpc=ESTORNAR,{},IF(nOldOpc=ALTERAR .And. cModo == ISENCAO,aIsencao,)),3,,,,,,.T.)
      oEncht:oBox:Align := CONTROL_ALIGN_ALLCLIENT

      AC400Valid("ED2_PERCPE2")
      If nOpca=INCLUIR .and. M->ED0_TIPOAC==GENERICO
         M->ED2_NCM := NCMGENERICA
      EndIf

   ACTIVATE MSDIALOG oDlgD ON INIT EnchoiceBar(oDlgD,;
                                    {||IIF(nOldOpc=ESTORNAR .Or.;
                                           nOpca=VISUALIZAR .or. ;
                                           ( Obrigatorio(aGets,aTela) .and. AC400Valid("FINALPI") .And.;
                                             IIF(nOpca==ALTERAR .And. M->ED2_QTDNCM != WorkED2->ED2_QTDNCM;
                                                 ,oMUserEDC:Reserva("ATO","ALT/EXC_ITEM");
                                                 ,IIF(nOpca==INCLUIR;
                                                      ,oMUserEDC:Reserva("ATO","INC_ITEM");
                                                      ,.T.)));
                                       ,Eval(bOk1),)},{||nSelecao:=0,oDlgD:End()};
                                    ,,{{"NOTE" /*"EDITABLE"*/,{|| ViewDesc("ED2")},STR0166, STR0166/*STR0410*/}}) //"Descrição da L.I." //$$ "Descr LI"
   // PLB 21/11/06 - AC401MUser() verifica se é possivel a alteração/exclusão do Item a Importar

   nOpca := nOldOpc
   If nSelecao = 1
      WorkED4->(dbSetOrder(1))


      dbSelectArea("WorkED2")
      If nOpca=INCLUIR .or. nOpca=ALTERAR
         If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"COMPARACAO"),)
         If !AC400Valid("VALIDA_INSUMO")  // GFP - 11/08/2014
            Loop
         EndIf
         If nOpca=ALTERAR .and. M->ED2_MARCA==cMarca .and.;
         (M->ED2_PERCPE<>WorkED2->ED2_PERCPE .or. M->ED2_CAMB<>WorkED2->ED2_CAMB .or.;
         M->ED2_NCM<>WorkED2->ED2_NCM .or. (M->ED2_UMNCM<>WorkED2->ED2_UMNCM .and.;
         iif(lED2Umanex,Empty(M->ED2_UMANEX),.t.)) .or.;               // ACSJ - 17/11/2004
         iif(lED2Umanex,M->ED2_UMANEX<>WorkED2->ED2_UMANEX,.F.) .or.;  // ACSJ - 17/11/2004
         M->ED2_PERCAP<>WorkED2->ED2_PERCAP .or. lComp)

            //AOM - 10/11/2011
            If AvFlags("SEQMI")
               cImport := WorkED2->ED2_IMPORT
            EndIf

            If WorkED4->(dbSeek(WorkED2->ED2_NCM+WorkED2->ED2_ITEM+WorkED2->ED2_CAMB+Str(WorkED2->ED2_PERCPE,5,2)+;
               iif(lED2Umanex,If(Empty(WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM)+cImport))  // ACSJ - 17/11/2004

               If WorkED4->ED4_QTDCAL <> WorkED4->ED4_QT_LI
                  //AOM - 10/11/2011
                  If AvFlags("SEQMI") .And. WorkED4->ED4_IMPORT == "N"
                     cSeqMiAux:= WorkED4->ED4_SEQMI
                  Else
                     cSeq4Aux   := WorkED4->ED4_SEQSIS
                  EndIf
                  nValLiEst  := WorkED4->ED4_VL_LI
                  nValDiEst  := WorkED4->ED4_VL_DI
                  nValCalEst := WorkED4->ED4_VALCAL
                  nQtdLiEst  := WorkED4->ED4_QT_LI
                  nQtdDiEst  := WorkED4->ED4_QT_DI
                  nQtdCalEst := WorkED4->ED4_QTDCAL
                  nQtNcmEst  := (WorkED4->ED4_QTDNCM - (WorkED2->ED2_QTDNCM * (Max(WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP,0))) /100) //AAF 14/04/05 - Verifica se o Percentual Aprovado é maior que o de perda.
                  nSNcmLiEst := WorkED4->ED4_SNCMLI
                  nSNcmDiEst := WorkED4->ED4_SNCMDI
               EndIf
               WorkED4Atu("WorkED2",ESTORNAR,,,M->ED0_MODAL==ISENCAO/* .and. WorkED2->ED2_QTDORI<>0*/)
               nTipo:=INCLUIR
            EndIf
         EndIf
         If nOpca=ALTERAR .and. !lMarca
            AC400Totais("WorkED2",ESTORNAR)
            If WorkED2->ED2_MARCA == cMarca
               AC400GrvEDA(ESTORNAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,0)
               AC400EDCGrv(ESTORNAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD,0)
            EndIf
         EndIf
         WorkED2->(RecLock("WorkED2",If(nOpca=INCLUIR,.T.,.F.)))
         If(nOpca=INCLUIR, M->ED2_MARCA:=cMarca,)
         If M->ED2_MARCA == cMarca .or. lMarca
            WorkED4Atu("M",If(!lMarca,nTipo,INCLUIR),,,M->ED0_MODAL==ISENCAO,If(nValCalEst<>0,.T.,.F.))
         EndIf
         FOR i := 1 TO FCount()
            If AllTrim(FIELDNAME(i)) == "ED2_DESCIT"
               WorkED2->&(FIELDNAME(i)) := Posicione("SB1",1,xFilial("SB1"/*"ED2"*/)+M->ED2_ITEM,"B1_DESC")  // GFP - 30/08/2012
            ElseIf AllTrim(FIELDNAME(i)) == "ED2_DESCPD"
               WorkED2->&(FIELDNAME(i)) := Posicione("SB1",1,xFilial("SB1"/*"ED2"*/)+M->ED2_PROD,"B1_DESC")  // GFP - 30/08/2012
            Else
               WorkED2->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
            EndIf
         NEXT i
         If lMultiFil  .And.  M->ED0_MODAL == ISENCAO
            WorkED2->ED2_FILORI := Left(M->ED2_FILORI,2) + " - " + AvgFilName({Left(M->ED2_FILORI,2)})[1]
         EndIf
         // A. Caetano - ACSJ - 04/03/2004
         if WorkED2->ED2_UMNCM == WorkED2->ED2_UMITEM
            WorkED2->ED2_COEFEC := 1
         Else
            AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMITEM,WorkED2->ED2_ITEM,1)
            WorkED2->ED2_COEFEC := iif( ( SJ5->(Eof()) .or. SJ5->(Bof()) ), 0, SJ5->(J5_COEF) )
         Endif
         If nOpca=INCLUIR
            WorkED2->TRB_ALI_WT:= "ED2"
            WorkED2->TRB_REC_WT:= ED2->(Recno())
         Endif

         //--------------------------------------------------------------------------------
         WorkED2->(MSUnlock())
         If M->ED2_MARCA == cMarca .or. lMarca
            AC400Totais("WorkED2",INCLUIR)
         EndIf
         If M->ED2_MARCA == cMarca .and. !lMarca
            AC400GrvEDA(INCLUIR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,0,cMarca)
            AC400EDCGrv(INCLUIR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD,0,cMarca)
         EndIf
         If(lMarca, AC400Marca(.F.,.F.) ,)
      ElseIf nOpca=ESTORNAR
         //AOM - 10/11/2011
         If AvFlags("SEQMI")
            cImport := M->ED2_IMPORT
         EndIf
         WorkED4->(dbSeek(M->ED2_NCM+M->ED2_ITEM+M->ED2_CAMB+Str(M->ED2_PERCPE,5,2)+;
            iif(lED2Umanex,If(Empty(M->ED2_UMANEX),M->ED2_UMNCM,M->ED2_UMANEX),M->ED2_UMNCM)+cImport)) // ACSJ - 17/11/2004

         If (!Empty(M->ED2_MARCA) .And. !VerED4Saldo("ESTORNO","M")) .OR. (!Empty(M->ED2_PROD) .and. M->ED0_MODAL==SUSPENSAO .And. !Empty(M->ED2_MARCA))
            If !Empty(M->ED2_PROD) .and. M->ED0_MODAL==SUSPENSAO
               Help(" ",1,"AVG0005146") //"Item nao pode ser estornado pois possui vinculo com produto a exportar, desmarque o item."
            Else
               Help(" ",1,"AVG0005147") //"Item nao pode ser estornado pois existe movimentacao."
            EndIf
         Else
            If MsgYesNo(STR0080)  .And.  oMUserEDC:Reserva("ATO","ALT/EXC_ITEM") //"Deseja Realmente Excluir este Item?"
               EstWorkED2()
            EndIf
         EndIf
      EndIf
   EndIf

   If nOpca<>INCLUIR .or. nSelecao=0
      lIncluiAux := .F.
      Exit
   EndIf
   nSelecao := 0
EndDo

aGets := aClone(aGetsAux)
aTela := aClone(aTelaAux)
nSelecao := 0

//oMark5:oBrowse:Refresh()- AOM - 27/10/10
//AOM - 20/06/2012
If oMark3:oBrowse:lVisible
   AtuaWKED2ED4(1,1,,.T.)
Else
   AtuaWKED2ED4(1,2,,.T.)
EndIf
oMark7:oBrowse:Refresh()

Return .T.

*-------------------------*
Function AC400PesqNcm(cFld)     // E
*-------------------------*
Local cNCMPesq:=Space(Len(ED1->ED1_NCM))
Local nOp:=0
Local oDlgE
Private FileWork1

//Verifica se é integrado - AOM - 25/10/10
If ED0->(FieldPos("ED0_INTEGR")) > 0
   If M->ED0_INTEGR == "S"
      lIntegra := .T.
   EndIf
EndIf

If cFld=="WorkED1"
   FileWork1:=E_CriaTrab(, aSemSX31, "WorkPesq")
Else
   FileWork1:=E_CriaTrab(, aSemSX32, "WorkPesq")
EndIf

If Empty( Alias() )
   dbSelectArea(cFld)
Endif

DEFINE MSDIALOG oDlgE TITLE STR0081 ; //"NCM a Pesquisar"
       FROM 05,05 TO 20,55 OF GetWndDefault()

   oPanel:= TPanel():New(0,0, "", oDlgE,, .T., ,,,0,0,,.T.) //LGS-02/12/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @02,02 SAY  AVSX3("ED1_NCM",5) Of oPanel
   @02,08 MSGET cNCMPesq F3 "SYD" PICT AVSX3("ED1_NCM",6) VALID ExistCpo("SYD",cNCMPesq) SIZE 60,8 Of oPanel

ACTIVATE MSDIALOG oDlgE ON INIT EnchoiceBar(oDlgE,{||nOp:=1,oDlgE:End()},{||nOp:=0,oDlgE:End()}) CENTERED

If nOp=1
   If NaoVazio(cNCMPesq)
      MsAguarde({|| PesquisaNCM(cNCMPesq,cFld)}, STR0082 ) //"Aguarde Apurando Dados..."
      If !WorkPesq->(EOF()) .and. !WorkPesq->(BOF())
         BrowsePesqNCM(cNCMPesq,cFld)
      Else
         Help(" ",1,"AVG0005148") //"Nenhum item satisfaz a pesquisa."
      Endif
      //WorkPesq->(dbCloseArea())
      dbSelectArea(cFld)
   EndIf
ElseIf nOp=0
   aSemSX3 := {}
   aEdita := {}
EndIf

If Select("WorkPesq") > 0
  WorkPesq->(E_EraseArq(FileWork1))
EndIf

Return .T.

*------------------------------------*
Static Function PesquisaNCM(cNCM,cFld)
*------------------------------------*
Local cQuery, aCondDel, nOrdSB1 := If(cFld=="WorkED2",SB1->(IndexOrd()),(cAliasSB1)->(IndexOrd()))
Local cSB1ArqAux, cCond:="", i
If lTop
   If cAliasSB1 == "SB1"
      cSB1ArqAux:=RetSqlName(cAliasSB1)
   Else
      cSB1ArqAux:="SB1"+Strzero(Val(ALLTRIM(EasyGParam("MV_EMPEXP",,""))),2)+"0"
   EndIf

   aCondDel:={"AND SB1.D_E_L_E_T_ <> '*' ","AND SYD.D_E_L_E_T_ <> '*' ",;
              "AND SJ5.D_E_L_E_T_ <> '*' "}
   cCond+="SB1.B1_FILIAL='"+cFilSB1+"' "+If(TcSrvType()<>"AS/400",aCondDel[1],"")
   cCond+="AND SB1.B1_POSIPI = '"+cNCM+"' AND SYD.YD_TEC = '"+cNCM+"' "
   cCond+="AND SYD.YD_FILIAL='"+cFilSYD+"' "+If(TcSrvType()<>"AS/400",aCondDel[2],"")
   cCond+="AND (SB1.B1_UM=SYD.YD_UNID OR (SJ5.J5_FILIAL='"+cFilSJ5+"' "
   cCond+=If(TcSrvType()<>"AS/400",aCondDel[3],"")+"AND SB1.B1_UM = SJ5.J5_DE "
   cCond+="AND SYD.YD_UNID = SJ5.J5_PARA "
   cCond+="AND (SJ5.J5_COD_I=SB1.B1_COD OR SJ5.J5_COD_I='' OR SJ5.J5_COD_I=' '))) "

   If cFld=="WorkED1"
      cQuery:= "SELECT DISTINCT '  ' ED1_MARCA, SB1.B1_COD ED1_PROD, SB1.B1_POSIPI ED1_NCM, "+;
               "0.0 ED1_QTD, 0.0 ED1_VAL_EM, 0.0 ED1_VAL_SE, 0.0 ED1_PERCAG, SB1.B1_VLREFUS ED1_PRCUNI "+;
               "FROM "+cSB1ArqAux+" SB1, "+RetSqlName("SYD")+" SYD, "+;
               RetSqlName("SJ5")+" SJ5 WHERE "+cCond+" "+;
               "ORDER BY SB1.B1_COD"
   Else
      cQuery:= "SELECT DISTINCT '  ' ED2_MARCA, SB1.B1_COD ED2_ITEM, SB1.B1_UM ED2_UMITEM, SB1.B1_POSIPI ED2_NCM, " +;
               "0.0 ED2_QTD, 0.0 ED2_VALEMB, 0.0 ED2_PERCPE, ' ' ED2_CAMB, SB1.B1_VLREFUS ED2_PRCUNI, "+;
               "'   ' ED2_UMNCM "+;
               "FROM "+RetSqlName("SB1")+" SB1, "+RetSqlName("SYD")+" SYD, "+;
               RetSqlName("SJ5")+" SJ5 WHERE "+cCond+" "+;
               "ORDER BY SB1.B1_COD"
   EndIf

   cQuery:=ChangeQuery(cQuery)

   //AOM - 16/03/2012
   If Select("TRB") > 0
      TRB->( dbCloseArea() )
   Endif

   TcQuery cQuery ALIAS "TRB" NEW

   //TETempReopen(FileWork1,"WorkPesq")
   dbSelectArea("TRB")
   Do While !TRB->(EOF())
      WorkPesq->(RecLock("WorkPesq",.T.))
      FOR i := 1 TO FCount()
         WorkPesq->&(FIELDNAME(i)) := FieldGet(i)
      NEXT i
      If cFld=="WorkED2"
         SYD->(dbSeek(cFilSYD+WorkPesq->ED2_NCM))
         WorkPesq->ED2_UMNCM := SYD->YD_UNID
      EndIf
      WorkPesq->(msUnlock())
      TRB->(dbSkip())
   EndDo

   TRB->(dbCloseArea())
Else
   //TETempReopen(FileWork1,"WorkPesq")
   If cFld=="WorkED1"
      (cAliasSB1)->(DbSetOrder(1))
      (cAliasSB1)->(DbSeek(cFilSB1,.T.))
      Do While (cAliasSB1)->(!Eof()) .And. (cAliasSB1)->B1_FILIAL = cFilSB1Aux
         If (cAliasSB1)->B1_POSIPI = cNCM .and. ValPesqNCM(cFld)
      		    WorkPesq->(RecLock("WorkPesq",.T.))
      		    WorkPesq->ED1_MARCA  := '  '
      		    WorkPesq->ED1_PROD   := (cAliasSB1)->B1_COD
      		    WorkPesq->ED1_NCM    := (cAliasSB1)->B1_POSIPI
      		    WorkPesq->ED1_QTD    := 0
      		    WorkPesq->ED1_VAL_EM := 0
      		    WorkPesq->ED1_VAL_SE := 0
      		    WorkPesq->ED1_PERCAG := 0
      		    WorkPesq->ED1_PRCUNI := (cAliasSB1)->B1_VLREFUS
      		    WorkPesq->(msUnlock())
         Endif
         (cAliasSB1)->(DbSkip())
      Enddo
   Else
      SB1->(DbSetOrder(1))
      SB1->(DbSeek(cFilSB1,.T.))
      Do While SB1->(!Eof()) .And. SB1->B1_FILIAL = cFilSB1
      	 If SB1->B1_POSIPI = cNCM .and. ValPesqNCM(cFld)
      	    WorkPesq->(RecLock("WorkPesq",.T.))
      	    WorkPesq->ED2_MARCA  := '  '
      	    WorkPesq->ED2_ITEM   := SB1->B1_COD
      	    WorkPesq->ED2_UMITEM := SB1->B1_UM
      	    WorkPesq->ED2_NCM    := SB1->B1_POSIPI
      	    WorkPesq->ED2_QTD    := 0
      	    WorkPesq->ED2_VALEMB := 0
      	    WorkPesq->ED2_PERCPE := 0
      	    WorkPesq->ED2_CAMB   := ' '
      	    WorkPesq->ED2_PRCUNI := SB1->B1_VLREFUS
      	    WorkPesq->ED2_UMNCM  := ""
            SYD->(dbSeek(cFilSYD+WorkPesq->ED2_NCM))
            WorkPesq->ED2_UMNCM := SYD->YD_UNID
      	    WorkPesq->(msUnlock())
         Endif
         SB1->(DbSkip())
      Enddo
   EndIf
   SB1->(DbSetOrder(nOrdSB1))
Endif

WorkPesq->(DBGOTOP())

Return .T.

*--------------------------------------*
Static Function BrowsePesqNCM(cNcm,cFld)
*--------------------------------------*
Local oMark, aBotao:={}
Local nOp:=0, cTitulo:=STR0084 //"Pesquisa por NCM"
Local COLUNA_FINAL
Local oPanel
DEFINE MSDIALOG oDlgF TITLE cTitulo FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 150 OF oMainWnd PIXEL

   oPanel:= TPanel():New(0,0, "", oDlgF,, .T., ,,,0,0,,.T.) //LGS-10/12/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   COLUNA_FINAL := (oDlgF:nClientWidth-4)/2
   nLinha       := (oDlgF:nClientHeight-4)/2

   oMark:= MsSelect():New("WorkPesq",Right(cFld,3)+"_MARCA",,If(cFld=="WorkED1",aSelCpos5,aSelCpos6),@lInverte,@cMarca,{1,1,nLinha,COLUNA_FINAL},,,oPanel)
   oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkPesq"),.T.}
   //oMark:bAval:={|| AC400PesqMarca(.F.,cFld)}
   // ** PLB 18/07/07
   If cFld == "WorkED1"
      bValMarca := {|| ValPesqMarca(WorkPesq->ED1_NCM,WorkPesq->ED1_PROD,cFilSB1Aux) }
   Else
      bValMarca := {|| ValPesqMarca(WorkPesq->ED2_NCM,WorkPesq->ED2_ITEM) }
   EndIf
   oMark:bAval:={|| IIF( Eval(bValMarca), AC400PesqMarca(.F.,cFld), ) }
   // **
   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgF ON INIT EnchoiceBar(oDlgF,{||nOp:=1,oDlgF:End()},{||nOp:=0,oDlgF:End()},,aBotao) CENTERED

If nOp = 1
   Processa({|| GrvSelPesq(cFld)},STR0085+If(cFld=="WorkED1",STR0086,STR0087)) //"Gravando " # "Produtos a Exportar" # "Itens a Importar"
EndIf

(cFld)->(dbGoTop())

Return .T.

*------------------------------*
Static Function GrvSelPesq(cFld)
*------------------------------*
Local cAtualiza, cCampo, nSeqSisED2, i

ProcRegua(WorkPesq->(EasyRecCount()))
WorkPesq->(dbGoTop())
Do While !WorkPesq->(EOF())
   IncProc(STR0085+If(cFld=="WorkED1",STR0088+Alltrim(WorkPesq->ED1_PROD),STR0089+Alltrim(WorkPesq->ED2_ITEM))) //"Gravando " # "Produto " # "Item "
   If WorkPesq->&(Right(cFld,3)+"_MARCA") == cMarca
      (cFld)->(RecLock(cFld,.T.))
      FOR i := 1 TO FCount()
        cCampo:=FIELDNAME(i)
        If cCampo<>"ED1_MARCA"
           (cFld)->&(cCampo) := WorkPesq->&(FIELDNAME(i))
        EndIf
      NEXT i
      If cFld=="WorkED1"
         WorkED1->ED1_SEQ    := StrZero(nSeq,nLenSeqED1)
         nSeq += 1
         SYD->(dbSetOrder(1))
         SYD->(dbSeek(cFilSYD+WorkPesq->ED1_NCM))
         WorkED1->ED1_UMNCM  := SYD->YD_UNID
         WorkED1->ED1_PRCUNI := WorkPesq->ED1_VAL_EM / WorkPesq->ED1_QTD
         WorkED1->ED1_VALCOM := (WorkED1->ED1_VAL_EM * WorkED1->ED1_PERCAG)/100
         If (cAliasSB1)->(dbSeek(cFilSB1Aux+WorkPesq->ED1_PROD))
            WorkED1->ED1_UMPROD := (cAliasSB1)->B1_UM
            WorkED1->ED1_QTDNCM := AVTransUnid((cAliasSB1)->B1_UM,SYD->YD_UNID,WorkPesq->ED1_PROD,WorkPesq->ED1_QTD)
            if (cAliasSB1)->B1_UM == SYD->YD_UNID
               WorkED1->ED1_COEFEC := 1
            Else
               WorkED1->ED1_COEFEC := iif( ( SJ5->(Eof()) .or. SJ5->(Bof()) ), 0, SJ5->J5_COEF ) // A. Caetano - ACSJ - 04/03/2004
            Endif
            WorkED1->ED1_PESO:= AC400Peso(WorkED1->ED1_UMPROD,WorkED1->ED1_PROD,WorkED1->ED1_QTD,(cAliasSB1)->B1_PESO)// TDF - 22/03/10
            //WorkED1->ED1_PESO   := (cAliasSB1)->B1_PESO * WorkED1->ED1_QTD
         EndIf
         AC400Totais("WorkED1",INCLUIR)
         WorkED3Atu("WorkED1",INCLUIR)
         SG1->(dbSetOrder(1))
         If SG1->(dbSeek(cFilSG1+WorkED1->ED1_PROD)) .And. lRecalcIn
            nEstru:=0 //Usado na Função Estrut2
            FileWork12 := AVEstrut2(WorkED1->ED1_PROD,WorkED1->ED1_QTD,"WorkEstru",,,lIntegra)
            Processa({|| AtuWorkED2(WorkED1->ED1_QTD,WorkED1->ED1_VAL_EM - WorkED1->ED1_VALCOM)}, STR0074) //"Atualizando Itens a Importar"
            AvFimEstrut2("WorkEstru",FileWork12)
            dbSelectArea("WorkPesq")
         Else
            AC400GrvEDA(INCLUIR,WorkED1->ED1_PROD,0,WorkED1->ED1_QTD,cMarca)
            AC400EDCGrv(INCLUIR,WorkED1->ED1_PROD,WorkED1->ED1_RE,WorkED1->ED1_PROD,0,WorkED1->ED1_QTD,cMarca)
         EndIf
      Else
         WorkED2->ED2_CAMB   := WorkPesq->ED2_CAMB
         SYD->(dbSetOrder(1))
         SYD->(dbSeek(cFilSYD+WorkPesq->ED2_NCM))
         WorkED2->ED2_UMNCM  := SYD->YD_UNID
         WorkED2->ED2_PRCUNI := If(WorkPesq->ED2_QTD>0, WorkPesq->ED2_VALEMB / WorkPesq->ED2_QTD , WorkPesq->ED2_VALEMB)
         If SB1->(dbSeek(cFilSB1+WorkPesq->ED2_ITEM))
            WorkED2->ED2_UMITEM := SB1->B1_UM
            WorkED2->ED2_QTDNCM := AVTransUnid(SB1->B1_UM,SYD->YD_UNID,WorkPesq->ED2_ITEM,WorkPesq->ED2_QTD)
            if SB1->B1_UM == SYD->YD_UNID
               WorkED2->ED2_COEFEC := 1
            Else
               WorkED2->ED2_COEFEC := iif( (SJ5->(Eof()) .or. SJ5->(Bof()) ), 0, SJ5->J5_COEF ) // A. Caetano - ACSJ - 04/03/2004
            Endif
            WorkED2->ED2_PESO:= AC400Peso(WorkED2->ED2_UMITEM,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,SB1->B1_PESO)//TDF - 22/03/10

            //AOM - 10/11/2011
            If AvFlags("SEQMI")

               If SB1->B1_IMPORT <> "N" .Or. M->ED0_TIPINS == "0" //AOM - 08/02/2012 - Tratamento Empty
                  WorkED2->ED2_IMPORT := "S"
               Else
                  WorkED2->ED2_IMPORT := "N"
               EndIf

            EndIf
            //WorkED2->ED2_PESO   := SB1->B1_PESO * WorkED2->ED2_QTD
         EndIf
         // ** PLB 18/07/07
         If WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTD)/100
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_VALEMB)/100
         Else
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB
         EndIf
         // **
         AC400Totais("WorkED2",INCLUIR)
         WorkED4Atu("WorkED2",INCLUIR)
      EndIf
      (cFld)->(msUnlock())
   EndIf
   WorkPesq->(dbSkip())
EndDo

//oMark5:oBrowse:Refresh()- AOM - 27/10/10

Return .T.

*-----------------------------------------*
Static Function AC400PesqMarca(lTodos,cFld)        // G
*-----------------------------------------*
Local oDlgG, nSelecao:=0, bOk1:={||nSelecao:=1,oDlgG:End()}, oCbxCamb , i
Private cTit:=STR0090+If(cFld=="WorkED1",STR0086,STR0087) //"Selecao de " # "Produtos a Exportar" # "Itens a Importar"
Private aCamb:={STR0091,STR0092} //"1 - Sim" # "2 - Nao"

If WorkPesq->&(Right(cFld,3)+"_MARCA") <> cMarca

   dbSelectArea("WorkPesq")
   FOR i := 1 TO FCount()
      M->&(FIELDNAME(i)) := FieldGet(i)
   NEXT i

   dbSelectArea("WorkPesq")

   DEFINE MSDIALOG oDlgG TITLE cTit From 15,03 To 33,46 OF oMainWnd

   If cFld=="WorkED1"

      @10,8 SAY AVSX3("ED1_PROD",5)   SIZE 40,8 PIXEL
      @10,56 MSGET M->ED1_PROD PICTURE AVSX3("ED1_PROD",6) SIZE 95,08 PIXEL WHEN .F.

      @23,8 SAY AVSX3("ED1_NCM",5)    SIZE 40,8 PIXEL
      @23,56 MSGET M->ED1_NCM PICTURE AVSX3("ED1_NCM",6)  SIZE 95,08 PIXEL WHEN .F.

      @36,8 SAY AVSX3("ED1_QTD",5) SIZE 40,8 PIXEL FONT oDlgG:oFont COLOR CLR_HBLUE
      @36,56 MSGET M->ED1_QTD PICTURE AVSX3("ED1_QTD",6) VALID (Positivo(M->ED1_QTD) .and. AC400Valid("ED1_QTD_PESQ")) SIZE 80,08 PIXEL

      @49,8 SAY AVSX3("ED1_PRCUNI",5) SIZE 40,08 PIXEL FONT oDlgG:oFont COLOR CLR_HBLUE
      @49,56 MSGET M->ED1_PRCUNI PICTURE AVSX3("ED1_PRCUNI",6) VALID (Positivo(M->ED1_PRCUNI) .and. AC400Valid("ED1_PRCUNI")) SIZE 80,08 PIXEL

      @62,8 SAY AVSX3("ED1_VAL_EM",5) SIZE 40,08 PIXEL FONT oDlgG:oFont COLOR CLR_HBLUE
      @62,56 MSGET M->ED1_VAL_EM   PICTURE AVSX3("ED1_VAL_EM",6) VALID (Positivo(M->ED1_VAL_EM) .and. AC400Valid("ED1_VAL_EM_PESQ")) SIZE 80,08 PIXEL

      @75,8 SAY AVSX3("ED1_VAL_SE",5) SIZE 40,08 PIXEL
      @75,56 MSGET M->ED1_VAL_SE   PICTURE AVSX3("ED1_VAL_SE",6) VALID (Positivo(M->ED1_VAL_SE) .or. Empty(M->ED1_VAL_SE)) SIZE 80,08 PIXEL

      @88,8 SAY AVSX3("ED1_PERCAG",5) SIZE 40,08 PIXEL
      @88,56 MSGET M->ED1_PERCAG   PICTURE AVSX3("ED1_PERCAG",6) VALID (Positivo(M->ED1_PERCAG) .or. Empty(M->ED1_PERCAG)) SIZE 80,08 PIXEL
   Else
      @10,8 SAY AVSX3("ED2_ITEM",5)   SIZE 40,8 PIXEL
      @10,56 MSGET M->ED2_ITEM   PICTURE AVSX3("ED2_ITEM",6) SIZE 95,08 PIXEL WHEN .F.

      @23,8 SAY AVSX3("ED2_NCM",5)    SIZE 40,8 PIXEL
      @23,56 MSGET M->ED2_NCM PICTURE AVSX3("ED2_NCM",6)  SIZE 95,08 PIXEL WHEN .F.

      If M->ED0_TIPOAC $ GENERICO
         @36,8 SAY AVSX3("ED2_QTD",5)    SIZE 40,8 PIXEL FONT oDlgG:oFont
      Else
         @36,8 SAY AVSX3("ED2_QTD",5)    SIZE 40,8 PIXEL FONT oDlgG:oFont COLOR CLR_HBLUE
      Endif
      @36,56 MSGET M->ED2_QTD PICTURE AVSX3("ED2_QTD",6) VALID (Positivo(M->ED2_QTD) .and. AC400Valid("ED2_QTD_PESQ")) SIZE 80,08 PIXEL WHEN If(M->ED0_TIPOAC $ GENERICO, .F., .T.)

      @49,8 SAY AVSX3("ED2_PRCUNI",5) SIZE 40,08 PIXEL FONT oDlgG:oFont COLOR CLR_HBLUE
      @49,56 MSGET M->ED2_PRCUNI PICTURE AVSX3("ED2_PRCUNI",6) VALID (Positivo(M->ED2_PRCUNI) .and. AC400Valid("ED2_PRCUNI")) SIZE 80,08 PIXEL

      @62,8 SAY AVSX3("ED2_VALEMB",5) SIZE 40,08 PIXEL FONT oDlgG:oFont COLOR CLR_HBLUE
      @62,56 MSGET M->ED2_VALEMB   PICTURE AVSX3("ED2_VALEMB",6) VALID (Positivo(M->ED2_VALEMB) .and. AC400Valid("ED2_VALEMB_PESQ")) SIZE 80,08 PIXEL

      @75,8 SAY AVSX3("ED2_PERCPE",5) SIZE 40,08 PIXEL
      @75,56 MSGET M->ED2_PERCPE   PICTURE AVSX3("ED2_PERCPE",6) VALID (Positivo(M->ED2_PERCPE) .or. Empty(M->ED2_PERCPE)) SIZE 80,08 PIXEL

      @88,8 SAY AVSX3("ED2_CAMB",5) SIZE 40,08 PIXEL FONT oDlgG:oFont COLOR CLR_HBLUE
      M->ED2_CAMB := "2"
      @88,56 ComboBox oCbxCamb Var M->ED2_CAMB Items aCamb SIZE 80,08 of oDlgG PIXEL
   EndIf

      @0.2,0.3 TO 9,20

      DEFINE SBUTTON FROM 105,010 TYPE 1 ACTION(If(AC400Valid(If(cFld=="WorkED1","PESQUISA1","PESQUISA2")),Eval(bOk1),)) ENABLE OF oDlgG PIXEL
      DEFINE SBUTTON FROM 105,050 TYPE 2 ACTION(nSelecao:=0,oDlgG:End()) ENABLE OF oDlgG PIXEL

   ACTIVATE MSDIALOG oDlgG CENTERED

   If nSelecao = 1
      dbSelectArea("WorkPesq")
      WorkPesq->(RecLock("WorkPesq",.F.))
      FOR i := 1 TO FCount()
         WorkPesq->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
      NEXT i
      WorkPesq->&(Right(cFld,3)+"_MARCA") := cMarca
      WorkPesq->(MSUnlock())
   EndIf

   nSelecao := 0
Else
   WorkPesq->&(Right(cFld,3)+"_MARCA") := ""
EndIf

Return .T.

*--------------------------------*
Static Function AC400GrvTudo(nOpc)
*--------------------------------*
Local lAppend:=.T., cCampo, nSeqAux:=0, cNCM, cMerc, dDtEmba, cRE, cProd, i
Local lAtuEE9_SW8:=.F., dDt_Val, lAtuQtd:=.F., lAlterado:=.F.
Local nOldQtd := 0, cCGC:=BuscaCNPJ(M->ED0_IMPORT), nAnexoAux := 0
Local cCamp_ED1Alt:= "ED1_VAL_EM, ED1_PESO, ED1_QTDNCM" //Usados na Funcao AC400GrvAdit
Local cCamp_ED3Alt:= "ED3_VAL_EM, ED3_PESO, ED3_QTDNCM, ED3_NCM"
Local cCamp_ED4Alt:= "ED4_VALEMB, ED4_PESO, ED4_QTDNCM, ED4_NCM", cDescr:="", cDescricao:=""
Local bSeekED4 //AOM - 28/04/2010
Local cImport := "" //AOM - 10/11/2011
Local cChave  := "" //AOM - 16/05/2012

Private nCapaDePeso:= nCapaPaPeso:= nCapaDeQtde := 0
Private nCapaPaQtde:= nCapaDeValor:= nCapaPaValor := 0
Private nPosColEd1 := nPosColEd4 := nPos_Ed1 := nPos_Ed4 := 0
Private nPosColEd3 := nPosColEd3 := nPos_Ed3 := nPos_Ed3 := 0
Private n_De_Ed1 := n_Pa_Ed1 := n_Pa_Ed4 := n_De_Ed4 := 0, nVez:= 0
Private n_De_Ed3 := n_Pa_Ed3 := 0, lEd4 := .F., lED3:=.F., lED1:=.F.
Private aValorED1 := {}, aValorED4 := {},  aValorED3 := {}, cCamp_ED0Alt
Private cPictValor := AVSX3("ED1_VAL_EM", 6), cPictPeso := AVSX3("ED1_PESO", 6)
Private cPictQtd := AVSX3("ED1_QTDNCM", 6), aNCM := {}, lPrim:= .T.
Private cSeguro := ED0->ED0_SEGURO, cFrete := ED0->ED0_FRETE
Private nAnexo := 1, nPagAnexo := 1 //Usados na função BuscaAnexo()

ED5->(DBSETORDER(2))

cCamp_ED0Alt:=  "ED0_DT_VA1, ED0_DT_VA2, ED0_DT_PR2, ED0_DT_PR3"

If(!Inclui .and. !Empty(M->ED0_AC) .and. Empty(ED0->ED0_AC), lAtuEE9_SW8:=.T., )
If(!lAtuEE9_SW8 .and. nOpc<>INCLUIR .and. M->ED0_AC <> ED0->ED0_AC , lAtuEE9_SW8:=.T. , )

dDt_Val := AC400ApDtValid()

Begin TransAction   //Controle de Transação

ProcRegua(WorkED2->(EasyRecCount())+WorkED1->(EasyRecCount())+WorkED3->(EasyRecCount())+WorkED4->(EasyRecCount())+1+WorkEDA->(EasyRecCount())+WorkEDB->(EasyRecCount())+WorkEDC->(EasyRecCount()))

// ** AAF 24/04/08 - Geração de Aditivos
If FindFunction("EDCAditivo") .AND. (M->ED0_MODAL == ISENCAO .OR. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2")) .AND. !Empty(M->ED0_DT_PED)
   oAdit := EDCAditivo():New( xFilial("ED0"), M->ED0_PD)
   oAdit:ChangeCheck()
   oAdit:GeraAditivos()
EndIf
// **

//Grava ED0
dbSelectArea("ED0")
IncProc(STR0027) //"Gravando Capa do A.C."
ED0->(RecLock("ED0",If(nOpc=INCLUIR,.T.,.F.)))
FOR i := 1 TO FCount()
   If nOpc == ALTERAR
      cCampo := FIELDNAME(i)
      If ED0->&(cCampo) <> M->&(cCampo)

         EDCLOG400("ED0"         ,;  //Tabela
                   M->ED0_PD     ,;  //Chave
                   "A"           ,;  //Tipo - "A" = Alteração, "E" = Exclusão, "I" = Inclusão
                   cCampo        ,;  //Campo
                   ED0->&(cCampo),;  //De
                   M->&(cCampo) )    //Para

         If !Empty(Alltrim(M->ED0_AC))
            If cCampo $("ED0_CNPJ/ED0_MODAL/ED0_CAPITA/ED0_TIPOAC/ED0_FRETE/ED0_SEGURO")
               lAlterado := .T.
            EndIf
            //If((M->ED0_MODAL == ISENCAO .OR. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2")) .And. cCampo $ cCamp_ED0Alt, AC400GrvAdit("ED0", i ,cCampo) ,  )
         Endif
         ED0->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
      EndIf
   Else
      ED0->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
   Endif
NEXT i
If (nOpc = INCLUIR .or. lAlterado) .and. !Empty(M->ED0_DT_ENV)
   ED0->ED0_ALTERA := If(ED0->ED0_ALTERA=="2" .or. ED0->ED0_ALTERA=="3","3","1")
   lAlterado := .F.
EndIf
ED0->ED0_FILIAL := cFilED0
MSMM(ED0->ED0_OBS,60,,M->ED0_VM_OBS ,1,,,"ED0","ED0_OBS")
ED0->(MSUnlock())

//Grava ED1
dbSelectArea("WorkED1")
WorkED1->(dbSetOrder(5))
WorkED1->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkED1->(EOF())
      IncProc(STR0028) //"Gravando Produtos a Exportar"
      If Val(WorkED1->ED1_SEQ) > 9999
         ED2AtuSeq(0)
         WorkED1->(dbSkip())
         Loop
      EndIf
      ED1->(RecLock("ED1",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         ED1->&(cCampo) := WorkED1->&(cCampo)
      NEXT i
      ED1->ED1_FILIAL := cFilED1
      ED1->ED1_PD     := ED0->ED0_PD
      ED1->ED1_AC     := ED0->ED0_AC
      If M->ED0_MODAL ==ISENCAO .and. ED1->ED1_QTDNCM<>ED1->ED1_QTDORI
         ED1->ED1_QTDORI := ED1->ED1_QTDNCM
      EndIf
      ED1->(msUnlock())
      //If !Empty(WorkED1->ED1_PREEMB) igor chiba 08/04/09
         EE9_SW8Atualiza("EE9",INCLUIR)
      //EndIf                          Fim igor chiba 08/04/09
      WorkED1->(dbSkip())
   EndDo
Else
   Do While !WorkED1->(EOF())
      IncProc(STR0028) //"Gravando Produtos a Exportar"
      If WorkED1->ED1_RECNO <> 0
         ED1->(dbGoTo(WorkED1->ED1_RECNO))
         If !ED1->(BOF()) .and. !ED1->(EOF())
            lAppend:=.F.
            If WorkED1->ED1_QTDNCM <> ED1->ED1_QTDNCM
               lAtuQtd := .T.
               nOldQtd := ED1->ED1_QTDNCM
            EndIf
         Else
            lAppend:=.T.
         EndIf
      Else
         lAppend:=.T.
      EndIf
      If lAppend
         If nSeqAux=0
            nSeqAux:=AC400Sequencia("ED1")
         Else
            nSeqAux++
         EndIf
         If nSeqAux > 9999
            nSeqAux:=0
            ED2AtuSeq(nSeqAux)
            WorkED1->(dbSkip())
            Loop
         ElseIf nSeqAux<>Val(WorkED1->ED1_SEQ)
            ED2AtuSeq(nSeqAux)
         EndIf
      EndIf
      ED1->(RecLock("ED1",lAppend))
      FOR i := 1 TO ED1->(FCount())
         cCampo:=ED1->(FIELDNAME(i))
         If (cCampo <> "ED1_VALCOM" .and. cCampo <> "ED1_RECNO" .and. cCampo <> "TRB_ALI_WT" .and. cCampo <> "TRB_REC_WT") .and. ED1->&(cCampo) # WorkED1->&(cCampo)
            // ** AAF 02/01/06 - Log da Alteração de NCM.
            If (!lAppend .OR. cCampo == "ED1_PROD") .AND. ( ED1->( FieldPos("ED1_NCMANT") ) == 0 .OR. cCampo <> "ED1_NCMANT" )
               EDCLOG400("ED1"                             ,;  //Tabela
                         WorkED1->(M->ED0_PD+ED1_PROD+ED1_SEQ),;  //Chave
                         If(lAppend,"I","A")               ,;  //Tipo - "A" = Alteração, "E" = Exclusão, "I" = Inclusão
                         cCampo                            ,;  //Campo
                         ED1->&(cCampo)                    ,;  //De
                         WorkED1->&(cCampo) )                //Para
            EndIf
            // **

            /*
            If ! lAppend .and. !Empty(M->ED0_AC) .And. M->ED0_ANEEXP == "1" .And. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2"))  // Se a opcao escolhida for Agrupar por Doctos e for Isencao
               If cCampo $ cCamp_ED1Alt
                  cWork  := "WorkEd1"
                  cAlias := "ED1"
                  AC400GrvAdit("ED1", i , cCampo)
               Endif
            Endif
            */
            ED1->&(cCampo) := WorkED1->&(cCampo)
         EndIf
      NEXT i
      ED1->ED1_AC     := ED0->ED0_AC
      If M->ED0_MODAl==ISENCAO .and. ED1->ED1_QTDNCM<>ED1->ED1_QTDORI
         ED1->ED1_QTDORI := ED1->ED1_QTDNCM
      EndIf
      If lAppend
         ED1->ED1_FILIAL := cFilED1
         ED1->ED1_PD     := ED0->ED0_PD
         ED1->ED1_SEQ    := StrZero(nSeqAux,nLenSeqED1)
         //If !Empty(WorkED1->ED1_PREEMB)  igor chiba 08/04/09
            EE9_SW8Atualiza("EE9",INCLUIR)
         //EndIf						   Fim igor chiba 08/04/09
      Else
         If (lAtuEE9_SW8 .or. lAtuQtd) //.and. !Empty(WorkED1->ED1_PREEMB)  igor chiba 08/04/09
            EE9_SW8Atualiza("EE9",INCLUIR,nOldQtd,If(!lAtuQtd,lAtuEE9_SW8,.F.))
            If lAtuQtd
               lAtuQtd := .F.
               nOldQtd := 0
            EndIf
         EndIf
      EndIf
      ED1->(MSUnlock())
      If lAppend .and. !Empty(M->ED0_AC) .And. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2" )) .And. M->ED0_ANEEXP == "1"// Se for Isencao
         AC400LOG("ED1", INCLUIR)
      Endif
      WorkED1->(dbSkip())
   EndDo
EndIf

//Apaga Estornados ED1
For i:=1 to Len(aDelWkED1)
   If aDelWkED1[i] <> 0
      ED1->(dbGoTo(aDelWkED1[i]))
      If !ED1->(BOF()) .and. !ED1->(EOF())
         If !Empty(M->ED0_AC) .and. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And.  M->ED0_ELETRO == "2" )) .And. M->ED0_ANEEXP == "1"
            AC400LOG("ED1", ESTORNAR)
         Endif
         //If !Empty(ED1->ED1_PREEMB)   igor chiba 08/04/09
            EE9_SW8Atualiza("EE9",ESTORNAR)
         //EndIf                        Fim igor chiba 08/04/09
         EDCLOG400("ED1"                          ,;  //Tabela
                   ED1->(ED1_PD+ED1_PROD+ED1_SEQ) ,;  //Chave
                   "E"                             )  //Tipo - "A" = Alteração, "E" = Exclusão, "I" = Inclusão.

         ED1->(RecLock("ED1",.F.,.T.))
         ED1->(DBDELETE())
         ED1->(msUnlock())
      EndIf
   EndIf
Next i
WorkED1->(dbSetOrder(1))

ED3->(dbSetOrder(1))
//Apaga Estornados ED3
For i:=1 to Len(aDelWkED3)
   If aDelWkED3[i] <> 0
      ED3->(dbGoTo(aDelWkED3[i]))
      If !ED3->(BOF()) .and. !ED3->(EOF())
         If M->ED0_MODAL == SUSPENSAO .AND. (!Empty(Alltrim(M->ED0_AC)) .or. !Empty(M->ED0_DT_ENV))
            GravaED6("ED3")
         EndIf
         If !Empty(M->ED0_AC) .and. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2")) .And. M->ED0_ANEEXP == "2"
            AC400LOG("ED3", ESTORNAR)
         Endif
         ED3->(RecLock("ED3",.F.,.T.))
         ED3->(DBDELETE())
         ED3->(msUnlock())
      EndIf
   EndIf
Next i
//Grava ED3
nPagAnexo := 1
nAnexo    := 1
dbSelectArea("WorkED3")
WorkED3->(dbSetOrder(1))
WorkED3->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkED3->(EOF())
      IncProc(STR0028) //"Gravando Produtos a Exportar"
      ED3->(RecLock("ED3",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         ED3->&(cCampo) := WorkED3->&(cCampo)
      NEXT i
      ED3->ED3_FILIAL := cFilED3
      ED3->ED3_PD     := ED0->ED0_PD
      ED3->ED3_AC     := ED0->ED0_AC
      ED3->ED3_DT_VAL := dDt_Val
      ED3->ED3_CNPJIM := cCGC
      If !Empty(Alltrim(M->ED0_AC)) .or. !Empty(M->ED0_DT_ENV)
         ED3->ED3_ALTERA := "1"  //Foi incluido Produto, enviar ao SISCOMEX
         ED0->(RecLock("ED0",.F.))
         ED0->ED0_ALTERA := If(ED0->ED0_ALTERA=="1" .or. ED0->ED0_ALTERA=="3","3","2")
         ED0->(msUnlock())
      EndIf
      ED3->(msUnlock())
      WorkED3->(dbSkip())
   EndDo
Else
   If M->ED0_MODAL == SUSPENSAO .AND. (AC400ApDtValid(.T.) <> WorkED3->ED3_DT_VAL .and. (!Empty(Alltrim(M->ED0_AC)) .or. !Empty(M->ED0_DT_ENV)))
      GravaED6("DT_VAL")
   EndIf
   nVez:= 0
   Do While !WorkED3->(EOF())
      IncProc(STR0028) //"Gravando Produtos a Exportar"

      If lIndPercAg
         cChaveED3 := cFilED3+ED0->ED0_PD+WorkED3->ED3_NCM+WorkED3->ED3_PROD+Str(WorkED3->ED3_PERCAG,5,2)+WorkED3->ED3_UMNCM
      Else
         cChaveED3 := cFilED3+ED0->ED0_PD+WorkED3->ED3_NCM+WorkED3->ED3_PROD+WorkED3->ED3_UMNCM
      EndIf

      If ED3->(dbSeek(cChaveED3))
         lAppend:=.F.
      Else
         lAppend:=.T.
      EndIf
      ED3->(RecLock("ED3",lAppend))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         If lAppend .or. (cCampo $("ED3_QTDNCM/ED3_VAL_CO/ED3_VAL_SE/ED3_PERCAG") .and. ;
         ED3->&(cCampo) <> WorkED3->&(cCampo))
            lAlterado := .T.
         EndIf
         If ED3->(FieldPos(cCampo) > 0 ) .and. ED3->&(cCampo) <> WorkED3->&(cCampo)
          /*!(cCampo $ "ED3_RECNO,TRB_ALI_WT,TRB_REC_WT")
          NOPADO POR AOM - 22/07/10 - Foi inserida a verificação de "FIELDPOS" pois foi inserido na work mais campos*/

            /*
            If !lAppend .And. !Empty(M->ED0_AC) .and. M->ED0_ANEEXP == "2" .And. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2"))// Se a opcao escolhida for diferente de não imprimir e for Isencao
               If cCampo $ cCamp_ED3Alt
                  cWork  := "WorkEd3"
                  cAlias := "ED3"
                  AC400GrvAdit("ED3", i , cCampo)
               Endif
            EndIf
            */
            ED3->&(cCampo) := WorkED3->&(cCampo)
         Endif
      NEXT i
      ED3->ED3_AC     := ED0->ED0_AC
      ED3->ED3_DT_VAL := dDt_Val
      If lAppend
         ED3->ED3_FILIAL := cFilED3
         ED3->ED3_PD     := ED0->ED0_PD
         ED3->ED3_CNPJIM := cCGC
      EndIf
      If lAlterado .and. (!Empty(Alltrim(M->ED0_AC)) .or. !Empty(M->ED0_DT_ENV))
         ED3->ED3_ALTERA := If(lAppend,"1","2")
         ED0->(RecLock("ED0",.F.))
         ED0->ED0_ALTERA := If(ED0->ED0_ALTERA=="1" .or. ED0->ED0_ALTERA=="3","3","2")
         ED0->(msUnlock())
         lAlterado := .F.
      EndIf
      ED3->(MSUnlock())
      If lAppend .And. !Empty(M->ED0_AC) .and. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2" )) .And. M->ED0_ANEEXP == "2"
         AC400LOG("ED3", INCLUIR)
      Endif
      WorkED3->(dbSkip())
   EndDo
EndIf
WorkED3->(dbSetOrder(1))

//Apaga Estornados ED2
For i:=1 to Len(aDelWkED2)
   If aDelWkED2[i] <> 0
      ED2->(dbGoTo(aDelWkED2[i]))
      If !ED2->(BOF()) .and. !ED2->(EOF())
         If !Empty(ED2->ED2_POSICA)
            EE9_SW8Atualiza("SW8",ESTORNAR)
         EndIf
         If M->ED0_MODAL == SUSPENSAO
            EDCLOG400("ED2"                           ,;  //Tabela
                      ED2->(ED2_PD+ED2_ITEM+ED2_SEQ)  ,;  //Chave
                      "E"                              )  //Tipo - "A" = Alteração, "E" = Exclusão, "I" = Inclusão

         ElseIf M->ED0_MODAL == ISENCAO
            EDCLOG400("ED2"                           ,;  //Tabela
                      ED2->(M->ED0_PD+ED2_ITEM+ED2_PROD+ED2_SEQ+ED2_DI_NUM+ED2_INVOIC+ED2_PO_NUM+ED2_POSICA+ED2_PGI_NU+ED2_RE),;  //Chave
                      "E"                              )  //Tipo - "A" = Alteração, "E" = Exclusão, "I" = Inclusão

         EndIf

         //AOM - 26/03/2012
         IF AVFLAGS("DI_ORIGINAL")
           If !VoltaSldDIAnt()
              DisarmTransaction()
           EndIf
         ENDIF
         ED2->(RecLock("ED2",.F.,.T.))
         ED2->(DBDELETE())
         ED2->(MSUnlock())
      EndIf
   EndIf
Next i
//Grava ED2
dbSelectArea("WorkED2")
//AOM - 16/11/2011
If !Empty(WorkED2->(DBFilter()))
   WorkED2->(DBCLEARFILTER())
EndIf
WorkED2->(dbSetOrder(1))
WorkED2->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkED2->(EOF())
      IncProc(STR0029) //"Gravando Itens a Importar"
      ED2->(RecLock("ED2",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         If AllTrim(cCampo) <> "ED2_DESCIT" .Or. AllTrim(cCampo) <> "ED2_DESCPD"
            ED2->&(cCampo) := WorkED2->&(cCampo)
         EndIf
      NEXT i
      ED2->ED2_FILIAL := cFilED2
      ED2->ED2_PD     := ED0->ED0_PD
      ED2->ED2_AC     := ED0->ED0_AC
      /*
      If M->ED0_MODAl=="2" .and. ED2->ED2_QTDNCM<>ED2->ED2_QTDORI
         ED2->ED2_QTDORI := ED2->ED2_QTDNCM
      EndIf
      */
      If WorkED2->ED2_MARCA == cMarca
         ED2->ED2_MARCA := "1"
      EndIf
      ED2->(msUnlock())
      If !Empty(WorkED2->ED2_POSICA)
         EE9_SW8Atualiza("SW8",INCLUIR)
      EndIf
      WorkED2->(dbSkip())
   EndDo
Else
   Do While !WorkED2->(EOF())
      IncProc(STR0029) //"Gravando Itens a Importar"
      If WorkED2->ED2_RECNO <> 0
         ED2->(dbGoTo(WorkED2->ED2_RECNO))
         If !ED2->(BOF()) .and. !ED2->(EOF())
            lAppend:=.F.
            If WorkED2->ED2_QTDNCM <> ED2->ED2_QTDNCM
               lAtuQtd := .T.
               nOldQtd := ED2->ED2_QTDNCM
            EndIf
         Else
            lAppend:=.T.
         EndIf
      Else
         lAppend:=.T.
      EndIf
      ED2->(RecLock("ED2",lAppend))

      FOR i := 1 TO ED2->(FCount())
         cCampo:=ED2->(FIELDNAME(i))
         If WorkED2->(FieldPos(cCampo)) > 0 //wfs 17/12/13
	        If lAppend .or. (cCampo <> "ED2_RECNO" .and. cCampo <> "ED2_QTDCAL" .and. cCampo <> "TRB_ALI_WT" .and. cCampo <> "TRB_REC_WT" .and.;
         	cCampo <> "ED2_VALCAL" .and. cCampo <> "ED2_PDANT" .and. cCampo <> "ED2_SEQANT" .and. cCampo <> "ED2_SLDANT" .and. cCampo <> "ED2_SEQIT";
         	.and. ED2->&(cCampo) <> WorkED2->&(cCampo)) //RRC - 28/12/2012
            	// ** AAF 02/01/06 - Log da Alteração.
            	If (!lAppend .OR. cCampo == "ED2_ITEM") .AND. (cCampo <> "ED2_MARCA" .OR. ( Empty(ED2->ED2_MARCA) # Empty(WorkED2->ED2_MARCA) )) .AND.;
               	( ED2->( FieldPos("ED2_NCMANT") ) == 0 .OR. cCampo <> "ED2_NCMANT" )
               		If M->ED0_MODAL == SUSPENSAO
                  		EDCLOG400("ED2"                             ,;  //Tabela
                            WorkED2->(M->ED0_PD+ED2_ITEM+ED2_SEQ),;  //Chave
                            If(lAppend,"I","A")               ,;  //Tipo - "A" = Alteração, "E" = Exclusão, "I" = Inclusão
                            cCampo                            ,;  //Campo
                            ED2->&(cCampo)                    ,;  //De
                            WorkED2->&(cCampo) )                  //Para
               		ElseIf M->ED0_MODAL == ISENCAO
                  		EDCLOG400("ED2"                                ,;  //Tabela
                            WorkED2->(M->ED0_PD+ED2_ITEM+ED2_PROD+ED2_SEQ+ED2_NCM+ED2_DI_NUM+ED2_INVOIC+ED2_PO_NUM+ED2_POSICA+ED2_PGI_NU+ED2_RE),;  //Chave
                            If(lAppend,"I","A")                  ,;  //Tipo - "A" = Alteração, "E" = Exclusão, "I" = Inclusão
                            cCampo                               ,;  //Campo
                            ED2->&(cCampo)                       ,;  //De
                            WorkED2->&(cCampo) )                     //Para
               		EndIf
               	EndIf
            EndIf
            // **

            ED2->&(cCampo) := WorkED2->&(cCampo)
         EndIf
      NEXT i
      ED2->ED2_AC     := ED0->ED0_AC
      If M->ED0_MODAl==ISENCAO .and. ED2->ED2_QTDNCM<>ED2->ED2_QTDORI
         ED2->ED2_QTDORI := ED2->ED2_QTDNCM
      EndIf
      If lAppend
         ED2->ED2_FILIAL := cFilED2
         ED2->ED2_PD     := ED0->ED0_PD
         If !Empty(WorkED2->ED2_POSICA)
            EE9_SW8Atualiza("SW8",INCLUIR)
         EndIf
      Else
         If (lAtuEE9_SW8 .or. lAtuQtd) .and. !Empty(WorkED2->ED2_POSICA)
            EE9_SW8Atualiza("SW8",INCLUIR,nOldQtd,If(!lAtuQtd,lAtuEE9_SW8,.F.))
            If lAtuQtd
               lAtuQtd := .F.
               nOldQtd := 0
            EndIf
         EndIf
      EndIf
      If WorkED2->ED2_MARCA == cMarca
         ED2->ED2_MARCA := "1"
      EndIf
      ED2->(MSUnlock())
      WorkED2->(dbSkip())
   EndDo
EndIf

//AOM - 27/03/2012 - Altera os saldos anteriores
For i := 1 To Len(aSldDIAnt)
              //SaldoNCM      , RecnoED2
   AtuSldDIAnt(aSldDIAnt[i][3],aSldDIAnt[i][4])
Next i
If !Empty(WorkED4->(DBFilter()))
   WorkED4->(DBCLEARFILTER())
EndIf
ED4->(dbSetOrder(1))
//Apaga Estornados ED4
For i:=1 to Len(aDelWkED4)
   If aDelWkED4[i] > 0
      ED4->(dbGoTo(aDelWkED4[i]))
      If !ED4->(BOF()) .and. !ED4->(EOF())
         If M->ED0_MODAL == SUSPENSAO .AND. (!Empty(Alltrim(M->ED0_AC)) .or. !Empty(M->ED0_DT_ENV))
            GravaED6("ED4")
         EndIf
         If !Empty(M->ED0_AC) .and. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2" ))
            AC400LOG("ED4", ESTORNAR)
         Endif
         ED4->(RecLock("ED4",.F.,.T.))
         ED4->(DBDELETE())
         ED4->(msUnlock())
      EndIf
   EndIf
Next i

//Grava ED4
dbSelectArea("WorkED4")
WorkED4->(dbSetOrder(1))
WorkED4->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkED4->(EOF())
      IncProc(STR0029) //"Gravando Itens a Importar"
      ED4->(RecLock("ED4",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         ED4->&(cCampo) := WorkED4->&(cCampo)
      NEXT i
      ED4->ED4_FILIAL := cFilED4
      ED4->ED4_PD     := ED0->ED0_PD
      ED4->ED4_AC     := ED0->ED0_AC
      ED4->ED4_DT_VAL := dDt_Val
      ED4->ED4_CNPJIM := cCGC
      If !Empty(Alltrim(M->ED0_AC)) .or. !Empty(M->ED0_DT_ENV)
         ED4->ED4_ALTERA := "1"  //Foi incluido Produto, enviar ao SISCOMEX
         ED0->(RecLock("ED0",.F.))
         ED0->ED0_ALTERA := If(ED0->ED0_ALTERA=="1" .or. ED0->ED0_ALTERA=="3","3","2")
         ED0->(msUnlock())
      EndIf
      ED4->(msUnlock())
      WorkED4->(dbSkip())
   EndDo
Else
   nVez:= 0
   Do While !WorkED4->(EOF())
      IncProc(STR0029) //"Gravando Produtos a Exportar"
      //If ED4->(dbSeek(cFilED4+ED0->ED0_PD+WorkED4->ED4_NCM+WorkED4->ED4_ITEM+WorkED4->ED4_CAMB+If(M->ED0_MODAL=="2",Str(0,5,2),Str(WorkED4->ED4_PERCPE,5,2))+WorkED4->ED4_UMNCM))
      // PLB 09/04/07 - Alteracao do Seek para procurar utilizando Percentual de Perda na chave
      //AOM - 10/11/2011
      If AvFlags("SEQMI")
         cImport := WorkED4->ED4_IMPORT
      EndIf

      //AOM - 28/04/2010 - Verificação para quebra por perca quando o campo Quebra Perca estiver preenchido como "Não"
      If !lQuebraPerc .OR. Empty(M->ED0_PERCPE) .OR. M->ED0_PERCPE == "1"
         bSeekED4 := {||ED4->(dbSeek(cFilED4+ED0->ED0_PD+WorkED4->ED4_NCM+WorkED4->ED4_ITEM+WorkED4->ED4_CAMB+Str(WorkED4->ED4_PERCPE,5,2)+WorkED4->ED4_UMNCM+cImport))}
      Else
         ED4->(DbSetOrder(7))  //ED4_FILIAL+ED4_PD+ED4_NCM+ED4_ITEM+ED4_UMNCM+ED4_IMPORT+ED4_CAMB
         cChave   :=  Left(cFilED4+ED0->ED0_PD+WorkED4->ED4_NCM+WorkED4->ED4_ITEM+WorkED4->ED4_UMNCM+cImport+WorkED4->ED4_CAMB, Len(ED4->&(IndexKey()))  ) //AOM - 16/05/2012
         bSeekED4 := {||ED4->(dbSeek(cChave))}
      EndIf
      If Eval(bSeekED4)
      //If ED4->(dbSeek(cFilED4+ED0->ED0_PD+WorkED4->ED4_NCM+WorkED4->ED4_ITEM+WorkED4->ED4_CAMB+Str(WorkED4->ED4_PERCPE,5,2)+WorkED4->ED4_UMNCM))
         lAppend:=.F.
      Else
         lAppend:=.T.
      EndIf
      ED4->(RecLock("ED4",lAppend))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         If lAppend .or. (cCampo $("ED4_QTDNCM/ED4_VALEMB/ED4_PERCPE") .and. ;
         ED4->&(cCampo) <> WorkED4->&(cCampo))
            lAlterado := .T.
         EndIf
         If cCampo == "ED4_NCMANT" .OR. (ED4->(FieldPos(cCampo)>0) .and. ED4->&(cCampo) <> WorkED4->&(cCampo))
         /*((cCampo <> "ED4_RECNO" .and. cCampo <> "QTD_ESTRUT" .and. cCampo <> "TRB_ALI_WT" .and. cCampo <> "TRB_REC_WT")
         NOPADO POR AOM - 22/07/10 - Foi inserida a verificação de "FIELDPOS" pois foi inserido na work mais campos*/

            /*
            If ! lAppend .And. !Empty(M->ED0_AC) .and. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2" ))
               If cCampo $ cCamp_ED4Alt //.AND. Empty(WorkED4->ED4_NCMANT)
                  cAlias := "ED4"
                  cWork  := "WorkEd4"
                  AC400GrvAdit("ED4", i , cCampo)
               Endif
            EndIf
            */
            //ED4->&(cCampo) := WorkED4->&(cCampo)
         Endif
      NEXT i
      AvReplace("WorkED4","ED4")
      ED4->ED4_AC     := ED0->ED0_AC
      ED4->ED4_DT_VAL := dDt_Val
      If lAppend
         ED4->ED4_FILIAL := cFilED4
         ED4->ED4_PD     := ED0->ED0_PD
         ED4->ED4_CNPJIM := cCGC
      EndIf
      ED2->(dbSetOrder(3))
      ED2->(dbSeek(cFilED2+ED4->ED4_PD+ED4->ED4_NCM+ED4->ED4_ITEM))
      If lAlterado .and. !Empty(ED2->ED2_MARCA) .and. (!Empty(Alltrim(M->ED0_AC)) .or. !Empty(M->ED0_DT_ENV))
         ED4->ED4_ALTERA := If(lAppend,"1","2")
         ED0->(RecLock("ED0",.F.))
         ED0->ED0_ALTERA := If(ED0->ED0_ALTERA=="1" .or. ED0->ED0_ALTERA=="3","3","2")
         ED0->(msUnlock())
         lAlterado := .F.
      EndIf
      ED4->(MSUnlock())
      If lAppend .And. !Empty(M->ED0_AC) .and. (M->ED0_MODAL == ISENCAO .Or. (M->ED0_MODAL == SUSPENSAO .And. M->ED0_ELETRO == "2"))
         AC400LOG("ED4", INCLUIR)
      Endif
      WorkED4->(dbSkip())
   EndDo
EndIf
WorkED4->(dbSetOrder(1))

EDA->(dbSetOrder(1))
//Apaga Estornados EDA
For i:=1 to Len(aDelWkEDA)
   If aDelWkEDA[i] <> 0
      EDA->(dbGoTo(aDelWkEDA[i]))
      If !EDA->(BOF()) .and. !EDA->(EOF())
         EDA->(RecLock("EDA",.F.,.T.))
         EDA->(DBDELETE())
         EDA->(msUnlock())
      EndIf
   EndIf
Next i

//Grava EDA
dbSelectArea("WorkEDA")
WorkEDA->(dbSetOrder(1))
WorkEDA->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkEDA->(EOF())
      IncProc(STR0200) //"Gravando Resumo de Estruturas"
      EDA->(RecLock("EDA",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         EDA->&(cCampo) := WorkEDA->&(cCampo)
      NEXT i
      EDA->EDA_FILIAL := cFilEDA
      EDA->EDA_PD     := ED0->ED0_PD
      EDA->(msUnlock())
      WorkEDA->(dbSkip())
   EndDo
Else
   Do While !WorkEDA->(EOF())
      IncProc(STR0200) //"Gravando Resumo de Estruturas"
      If WorkEDA->EDA_RECNO <> 0
         EDA->(dbGoTo(WorkEDA->EDA_RECNO))
         If !EDA->(BOF()) .and. !EDA->(EOF())
            lAppend:=.F.
         Else
            lAppend:=.T.
         EndIf
      Else
         lAppend:=.T.
      Endif
      EDA->(RecLock("EDA",lAppend))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         If lAppend .or. ( EDA->(FieldPos(cCampo)>0) .and. EDA->&(cCampo) <> WorkEDA->&(cCampo))
         /*cCampo <> "EDA_FILIAL" .and. cCampo <> "EDA_RECNO" .and. cCampo <> "TRB_ALI_WT" .and. cCampo <> "TRB_REC_WT"
         NOPADO POR AOM - 22/07/10 - Foi inserida a verificação de "FIELDPOS" pois foi inserido na work mais campos */
            EDA->&(cCampo) := WorkEDA->&(cCampo)
         EndIf
      NEXT i
      If lAppend
         EDA->EDA_FILIAL := cFilEDA
         EDA->EDA_PD     := ED0->ED0_PD
      EndIf
      EDA->(MSUnlock())
      WorkEDA->(dbSkip())
   EndDo
EndIf

EDB->(dbSetOrder(1))
//Apaga Estornados EDB
For i:=1 to Len(aDelWkEDB)
   If aDelWkEDB[i] <> 0
      EDB->(dbGoTo(aDelWkEDB[i]))
      If !EDB->(BOF()) .and. !EDB->(EOF())
         EDB->(RecLock("EDB",.F.,.T.))
         EDB->(DBDELETE())
         EDB->(msUnlock())
      EndIf
   EndIf
Next i

//Grava EDB
dbSelectArea("WorkEDB")
WorkEDB->(dbSetOrder(1))
WorkEDB->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkEDB->(EOF())
      IncProc("Gravando C.N.P.J's")
      EDB->(RecLock("EDB",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         EDB->&(cCampo) := WorkEDB->&(cCampo)
      NEXT i
      EDB->EDB_FILIAL := cFilEDB
      EDB->EDB_PD     := ED0->ED0_PD
      EDB->(msUnlock())
      WorkEDB->(dbSkip())
   EndDo
Else
   Do While !WorkEDB->(EOF())
      IncProc("Gravando C.N.P.J's")
      If WorkEDB->EDB_RECNO <> 0
         EDB->(dbGoTo(WorkEDB->EDB_RECNO))
         If !EDB->(BOF()) .and. !EDB->(EOF())
            lAppend:=.F.
         Else
            lAppend:=.T.
         EndIf
      Else
         lAppend:=.T.
      Endif
      EDB->(RecLock("EDB",lAppend))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         If lAppend .or. (cCampo <> "EDB_FILIAL" .and. cCampo <> "EDB_RECNO" .and. cCampo <> "TRB_ALI_WT" .and. cCampo <> "TRB_REC_WT" .and.;
         EDB->&(cCampo) <> WorkEDB->&(cCampo))
            EDB->&(cCampo) := WorkEDB->&(cCampo)
         EndIf
      NEXT i
      If lAppend
         EDB->EDB_FILIAL := cFilEDB
         EDB->EDB_PD     := ED0->ED0_PD
      EndIf
      EDB->(MSUnlock())
      WorkEDB->(dbSkip())
   EndDo
EndIf

EDC->(dbSetOrder(1))
//Apaga Estornados EDC
For i:=1 to Len(aDelWkEDC)
   If aDelWkEDC[i] <> 0
      EDC->(dbGoTo(aDelWkEDC[i]))
      If !EDC->(BOF()) .and. !EDC->(EOF())
         EDC->(RecLock("EDC",.F.,.T.))
         EDC->(DBDELETE())
         EDC->(msUnlock())
      EndIf
   EndIf
Next i

//Grava EDC
dbSelectArea("WorkEDC")
WorkEDC->(dbSetOrder(1))
WorkEDC->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkEDC->(EOF())
      IncProc(STR0200) //"Gravando Resumo de Estruturas"
      EDC->(RecLock("EDC",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         EDC->&(cCampo) := WorkEDC->&(cCampo)
      NEXT i
      EDC->EDC_FILIAL := cFilEDC
      EDC->EDC_PD     := ED0->ED0_PD
      EDC->(msUnlock())
      WorkEDC->(dbSkip())
   EndDo
Else
   Do While !WorkEDC->(EOF())
      IncProc(STR0200) //"Gravando Resumo de Estruturas"
      If WorkEDC->EDC_RECNO <> 0
         EDC->(dbGoTo(WorkEDC->EDC_RECNO))
         If !EDC->(BOF()) .and. !EDC->(EOF())
            lAppend:=.F.
         Else
            lAppend:=.T.
         EndIf
      Else
         lAppend:=.T.
      Endif
      EDC->(RecLock("EDC",lAppend))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         If lAppend .or. ( EDC->(FieldPos(cCampo)>0) .and. EDC->&(cCampo) <> WorkEDC->&(cCampo)) //ER - 25/09/2007
         /*cCampo <> "EDC_FILIAL" .and. cCampo <> "EDC_RECNO" .and. cCampo <> "TRB_ALI_WT" .and. cCampo <> "TRB_REC_WT" .and.;
         cCampo <> "EDC_FATNET" .and. cCampo <> "EDC_FATGRO" -
         NOPADO POR AOM - 22/07/10 - Foi inserida a verificação de "FIELDPOS" pois foi inserido na work mais campos */
            EDC->&(cCampo) := WorkEDC->&(cCampo)
         EndIf
      NEXT i
      If lAppend
         EDC->EDC_FILIAL := cFilEDC
         EDC->EDC_PD     := ED0->ED0_PD
      EndIf
      EDC->(MSUnlock())
      WorkEDC->(dbSkip())
   EndDo
EndIf

End TransAction   //Finaliza Controle de Transação

If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"GRAVACAO_ATO"),)  //TRP - 14/02/2012 - Ponto de Entrada para iniciar uma nova transação com SAP.

Return .T.

*----------------------------*
Static Function AC400Estorna()
*----------------------------*
Local nEE9Ord:=EE9->(IndexOrd())
Local nSW8Ord:=SW8->(IndexOrd())
Local nED9Ord:=ED9->(IndexOrd())  //igor chiba 07/04/09
Local nQtdConv:=0
Local cFilAux := ""
Local cChave := "" //RRC - 14/05/2012 - Chave de busca na tabela ED2 (Itens a importar)

Begin TransAction   //Controle de Transação

If M->ED0_MODAL == SUSPENSAO .AND. (!Empty(Alltrim(M->ED0_AC)) .or. !Empty(M->ED0_DT_ENV))
   GravaED6("ED0")
EndIf

ProcRegua(WorkED1->(EasyRecCount())+WorkED2->(EasyRecCount())+WorkED3->(EasyRecCount())+WorkED4->(EasyRecCount())+1+WorkEDA->(EasyRecCount())+WorkEDB->(EasyRecCount())+WorkEDC->(EasyRecCount()))

EE9->(dbSetOrder(2))
SW8->(dbSetOrder(6))

cPedDraw := ED0->ED0_PD

If ED1->(dbSeek(cFilED1+cPedDraw))
   Do While ED1->( !EoF() .AND. ED1_FILIAL==cFilED1 .and. ED1_PD == cPedDraw )
      IncProc(STR0094) //"Apagando Produtos a Exportar"
      If !Empty(ED1->ED1_PREEMB)
         //EE9_SW8Atualiza("EE9",ESTORNAR)
         //If EE9->( dbSeek(cFilEE9+ED1->( ED1_PREEMB+ED1_PEDIDO+ED1_SEQUEN )) )
         If lMultiFil
            cFilAux := ED1->ED1_FILORI
         Else
            cFilAux := cFilEE9
         EndIf
         If EE9->( dbSeek(cFilAux+ED1->( ED1_PREEMB+ED1_PEDIDO+ED1_SEQUEN )) )
            EE9->(msUnlock()) //Libera o SoftLock
            RecLock("EE9",.F.)
            If ED1->ED1_UMNCM<>EE9->EE9_UNIDAD
               nQtdConv := ED1->( AvTransUnid(ED1_UMNCM,EE9->EE9_UNIDAD,ED1_PROD,ED1_QTDNCM) )
            Else
               nQtdConv := ED1->ED1_QTDNCM
            EndIf
            EE9->EE9_ATOCON := ""
            EE9->EE9_FASEDR := ""
            If EE9->EE9_ISENTO == "N"
               EE9->EE9_SALISE += nQtdConv // / ED1->ED1_COEF
               If EE9->EE9_SLDINI <> EE9->EE9_SALISE
                  //AtuIsenParcial(cAlias)
                  EE9->EE9_ATOCON := If(Empty(ED0->ED0_AC),cPedDraw,ED0->ED0_AC)
                  EE9->EE9_FASEDR := If(Empty(ED0->ED0_AC),"1","2")
               Else
                  EE9->EE9_ISENTO := ""
                  EE9->EE9_SALISE := 0
               EndIf
            Else
               EE9->EE9_ISENTO := ""
               EE9->EE9_SALISE := 0
            EndIf
            EE9->(msUnlock())
         EndIf

      //igor chiba 06/04/09 ESTORNO R.E externo

      ElseIf lReExt
         ED9->(DBSETORDER(1)) // ED9_FILIAL + ED9_RE + ED9_PEDIDO + ED9_POSICA
         //IF ED9->( dbSeek(cFilED9 + ED1->ED1_RE +ED1->ED1_AC +ED1->ED1_SEQ ) )
         IF ED9->( dbSeek(cFilED9 + ED1->ED1_RE + ED1->ED1_PEDIDO + ED1->ED1_SEQUEN ) )
            ED9->(msUnlock()) //Libera o SoftLock
            RecLock("ED9",.F.)
            If ED1->ED1_UMNCM <> ED9->ED9_UMNCM
               nQtdConv := ED1->( AvTransUnid(ED1_UMNCM,ED9->ED9_UM,ED1_PROD,ED1_QTDNCM) )
            Else
               nQtdConv := ED1->ED1_QTDNCM
            EndIf
            ED9->ED9_AC     := ""
            ED9->ED9_FASEDR := ""

            If ED9->ED9_ISENTO == "1" //ISENTO
               ED9->ED9_SALISE += nQtdConv
               If ED9->ED9_QTD <> ED9->ED9_SALISE
                  ED9->ED9_AC     := If(Empty(ED0->ED0_AC),cPedDraw,ED0->ED0_AC)
                  EE9->ED9_FASEDR := If(Empty(ED0->ED0_AC),"1","2")
               Else
                  ED9->ED9_ISENTO := ""
                  ED9->ED9_SALISE := 0
               EndIf
            Else
               ED9->ED9_ISENTO := ""
               ED9->ED9_SALISE := 0
            EndIf

            ED9->(msUnlock())
         EndIf

         //FIM igor chiba 06/04/09
      ED9->(DBSETORDER(nED9Ord))
      EndIf

      RecLock("ED1",.F.,.T.)
      ED1->( dbDelete(), MsUnlock(), dbSkip() )
   EndDo
EndIf

If ED3->(dbSeek(cFilED3+cPedDraw))
   Do While ED3->ED3_FILIAL==cFilED3 .and. ED3->ED3_PD==cPedDraw .and. !ED3->(EOF())
      IncProc(STR0094) //"Apagando Produtos a Exportar"
      ED3->(RecLock("ED3",.F.,.T.))
      ED3->(DBDELETE())
      ED3->(MSUnlock())
      ED3->(dbSkip())
   EndDo
EndIf

If ED2->(dbSeek(cFilED2+cPedDraw))
   Do While ED2->( !EoF() .AND. ED2_FILIAL==cFilED2 .and. ED2_PD==cPedDraw )
      IncProc(STR0095) //"Apagando Itens a Importar"
      If !Empty(ED2->ED2_POSICA)
         //EE9_SW8Atualiza("SW8",ESTORNAR)
         If lMultiFil
            cFilAux := ED2->ED2_FILORI
         Else
            cFilAux := cFilSW8
         EndIf
         If SW8->(dbSeek(cFilAux+ED2->(ED2_HAWB+ED2_INVOIC+ED2_PO_NUM+ED2_POSICA+ED2_PGI_NU) ) )
            SW8->(msUnlock()) //Libera o SoftLock
            RecLock("SW8",.F.)

            If ED2->ED2_UMNCM<>SW8->W8_UNID
               nQtdConv := ED2->( AvTransUnid(ED2_UMNCM,SW8->W8_UNID,ED2_ITEM,ED2_QTDNCM) )
            Else
               nQtdConv := ED2->ED2_QTDNCM
            EndIf

            SW8->W8_ACISEN := ""
            SW8->W8_FASEDR := ""
            If SW8->W8_ISENTOT == "N"
               SW8->W8_SALISEN += nQtdConv // / ED2->ED2_COEF
               If SW8->W8_QTDE <> SW8->W8_SALISEN
                  //AtuIsenParcial(cAlias)
                  SW8->W8_ACISEN := If(Empty(ED0->ED0_AC),cPedDraw,ED0->ED0_AC)
                  SW8->W8_ADICAO := ED2->ED2_ADICAO
               Else
                  SW8->W8_ISENTOT := ""
                  SW8->W8_SALISEN := 0
               EndIf
            Else
               SW8->W8_ISENTOT := ""
               SW8->W8_SALISEN := 0
            EndIf
            SW8->(msUnlock())
         // ** AAF 17/08/2006 - Tratamento das DI's Externas no Estorno do Ato Concessório.
         Else //If lDiExt NOPADO POR AOM - 04/11/10
            If Empty(ED2->ED2_DI_NUM) //RRC - 14/05/2012 - Definição da chave de busca para estornar Ato de Isenção de Compra Nacional ou Importação
               ED8->( dbSetOrder(5) ) //Se não tiver DI, é Compra Nacional
               cChave := "ED2_PO_NUM+ED2_POSICA" //Busca pela chave ED8_PEDIDO+ED8_POSDI
            Else
               ED8->( dbSetOrder(4) )
               cChave := "ED2_DI_NUM+ED2_ADICAO+ED2_POSICA" //Busca pela chave ED8_DI_NUM+ED8_ADICAO+ED8_POSDI
            EndIf

            If ED8->(dbSeek(cFilED8+ED2->(&(cChave))))
               ED8->( RecLock("ED8",.F.) )
               If ED2->ED2_UMNCM<>ED8->ED8_UM
                  nQtdConv := ED2->( AvTransUnid(ED2_UMNCM,SW8->W8_UNID,ED2_ITEM,ED2_QTDNCM) )
               Else
                  nQtdConv := ED2->ED2_QTDNCM
               EndIf

               ED8->ED8_ACISEN := ""
               ED8->ED8_FASEDR := ""
               If ED8->ED8_ISETOT == "N"
                  ED8->ED8_SALISE += nQtdConv // / ED2->ED2_COEF
                  If ED8->ED8_QTD <> ED8->ED8_SALISE
                     //AtuIsenParcial(cAlias)
                     ED8->ED8_ACISEN := If(Empty(ED0->ED0_AC),cPedDraw,ED0->ED0_AC)
                     ED8->ED8_ADICAO := ED2->ED2_ADICAO
                  Else
                     ED8->ED8_ISETOT := ""
                     ED8->ED8_SALISE := 0
                  EndIf
               Else
                  ED8->ED8_ISETOT := ""
                  ED8->ED8_SALISE := 0
               EndIf
               ED8->(msUnlock())
            EndIf
         EndIf
         // **
      EndIf

      //AOM - 26/03/2012
      IF AVFLAGS("DI_ORIGINAL")
         If !VoltaSldDIAnt()
            DisarmTransaction()
         EndIf
      ENDIF
      RecLock("ED2",.F.,.T.)
      ED2->( dbDelete(), MsUnLock(), dbSkip() )
   EndDo
EndIf

If ED4->(dbSeek(cFilED4+cPedDraw))
   Do While ED4->ED4_FILIAL==cFilED4 .and. ED4->ED4_PD==cPedDraw .and. !ED4->(EOF())
      IncProc(STR0095) //"Apagando Itens a Importar"
      ED4->(RecLock("ED4",.F.,.T.))
      ED4->(DBDELETE())
      ED4->(MSUnlock())
      ED4->(dbSkip())
   EndDo
EndIf

ED5->(dbSetOrder(3))
If ED5->(dbSeek(cFilED5+cPedDraw))
   Do While !ED5->(EOF()) .and. ED5->ED5_FILIAL==cFilED5 .and. ED5->ED5_PD==cPedDraw
      ED5->(RecLock("ED5",.F.,.T.))
      ED5->(DBDELETE())
      ED5->(MSUnlock())
      ED5->(dbSkip())
   EndDo
EndIf
ED5->(dbSetOrder(1))

If lAbriuEDA .and. EDA->(dbSeek(cFilEDA+cPedDraw))
   Do While !EDA->(EOF()) .and. EDA->EDA_FILIAL==cFilEDA .and. EDA->EDA_PD==cPedDraw
      IncProc(STR0201) //"Apagando Resumo de Estruturas"
      EDA->(RecLock("EDA",.F.,.T.))
      EDA->(DBDELETE())
      EDA->(MSUnlock())
      EDA->(dbSkip())
   EndDo
EndIf

If lAbriuEDC .and. EDC->(dbSeek(cFilEDC+cPedDraw))
   Do While !EDC->(EOF()) .and. EDC->EDC_FILIAL==cFilEDC .and. EDC->EDC_PD==cPedDraw
      IncProc(STR0201) //"Apagando Resumo de Estruturas"
      EDC->(RecLock("EDC",.F.,.T.))
      EDC->(DBDELETE())
      EDC->(MSUnlock())
      EDC->(dbSkip())
   EndDo
EndIf

If lAbriuEDB .and. EDB->(dbSeek(cFilEDB+cPedDraw))
   Do While !EDB->(EOF()) .and. EDB->EDB_FILIAL==cFilEDB .and. EDB->EDB_PD==cPedDraw
      IncProc(STR0257) //"Apagando C.N.P.J''s"
      EDB->(RecLock("EDB",.F.,.T.))
      EDB->(DBDELETE())
      EDB->(MSUnlock())
      EDB->(dbSkip())
   EndDo
EndIf

// ** AAF 03/01/06 - Exclusão do Log de Alterações.
If ChkFile("EDF",.F.)
   EDF->( dbSetOrder(1) )
   EDF->( dbSeek(cFilEDF+cPedDraw) )
   Do While !EDF->( EoF() ) .AND. EDF->EDF_FILIAL == cFilEDF .AND. EDF->EDF_PD == cPedDraw
      IncProc("Apagando Histórico") //"Apagando Histórico"
      RecLock("EDF",.F.,.T.)
      EDF->( dbDelete() )
      EDF->( MsUnLock() )

      EDF->( dbSkip() )
   EndDo
EndIf

IncProc(STR0093) //"Apagando Capa do A.C."
ED0->(RecLock("ED0",.F.,.T.))
ED0->(DBDELETE())
ED0->(MSUnlock())

EE9->(dbSetOrder(nEE9Ord))
SW8->(dbSetOrder(nSW8Ord))

End TransAction   //Finaliza Controle de Transação

If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"ESTORNO_ATO"),)  //TRP - 14/02/2012 - Ponto de Entrada para iniciar uma nova transação com SAP.

Return .T.

*------------------------------------*
Static Function AC400Sequencia(cAlias)
*------------------------------------*
Local nSequen, nOldOrd:=(cAlias)->(IndexOrd())
Local nOldRec:=(cAlias)->(RecNo())

If cAlias=="WorkED1"
   (cAlias)->(dbSetOrder(2))
   (cAlias)->(dbSeek(M->ED0_PD))
Else
   (cAlias)->(dbSetOrder(3))
   (cAlias)->(dbSeek(cFilED1+M->ED0_PD))
EndIf

If (cAlias)->ED1_PD == M->ED0_PD
   Do While !(cAlias)->(EOF()) .and. (cAlias)->ED1_PD == M->ED0_PD
      (cAlias)->(dbSkip())
   EndDo
   (cAlias)->(dbSkip(-1))
   nSequen:=Val((cAlias)->ED1_SEQ) + 1
Else
   nSequen := 1
EndIf

If nSequen>9999 .and. cAlias=="WorkED1"
   Help(" ",1,"AVG0005149") //"Ato Concessório estourou o limite de 9999 produtos. Caso Inclua mais produtos estes não poderão ser gravados."
EndIf

(cAlias)->(dbSetOrder(nOldOrd))
(cAlias)->(dbGoTo(nOldRec))

Return nSequen

*--------------------------------------------*
Function AC400ApDtValid(lAltera,cAlias,cBaixa)
*--------------------------------------------*
Local dData
Local aCposAto := {}
Local N
Local cCposAto  := EasyGParam("MV_AVG0190",,"") //DFS - Parâmetro para selecionar os campos que deve ser considerado no Ato Concessório
Local nDiasBaixa:= EasyGParam("MV_EDC0008",,60)

// DFS - Reformulação de tratamento para vencimento de Ato
If Empty(cCposAto)
   aCposAto := {"ED0_DT_ENC", "ED0_DT_PR3", "ED0_DT_PR2", "ED0_DT_PR1", "ED0_DT_VA2", "ED0_DT_VA1"}
Else
   While Len(cCposAto) > 0
      nPos := AT("/",cCposAto)
      If nPos == 0
         aAdd(aCposAto, cCposAto)
         Exit
      EndIf
      aAdd(aCposAto,SubStr(cCposAto,1,AT("/",cCposAto)-1))
      //Validação do conteudo do parametro.
      If !SubStr(cCposAto,1,AT("/",cCposAto)-1) $ "ED0_DT_ENC/ED0_DT_PR3/ED0_DT_PR2/ED0_DT_PR1/ED0_DT_VA2/ED0_DT_VA1"
         MsgInfo("Existe(m) campo(s) informado(s) no parâmetro 'MV_AVG0190' inválidos. Revalidar o conteúdo do Parâmetro!")
         //DFS - 11/05/11 - Inclusão do array para não dar erro de Invalid Data Type
         aCposAto := {"ED0_DT_ENC", "ED0_DT_PR3", "ED0_DT_PR2", "ED0_DT_PR1", "ED0_DT_VA2", "ED0_DT_VA1"}
        Exit
      EndIf
      cCposAto := SubStr(cCposAto,AT("/",cCposAto)+1, Len(cCposAto))
   EndDo
EndIf

If(lAltera=NIL, lAltera:=.F. , )
If(cAlias =NIL, cAlias :="M" , )

If cAlias="ED0"
   For N:=1 to Len(aCposAto)
     If !Empty( &("ED0->" + aCposAto[n]))
        dData := &("ED0->" + aCposAto[n])
        Exit
     EndIf
   Next N
   If dData == Nil
      dData := &("ED0->" + aCposAto[Len(aCposAto)])
   EndIf

Else
   If lAltera // DFS - Reformulação de tratamento para vencimento de Ato
      For N:=1 to Len(aCposAto)
        If !Empty( &("M->" + aCposAto[n]))
           dData := &("M->" + aCposAto[n])
           Exit
        EndIf
      Next N
      If dData == Nil
         dData := &("M->" + aCposAto[Len(aCposAto)])
      EndIf
   Else
      For N:=1 to Len(aCposAto)
        If aCposAto[n] == "ED0_DT_ENC" .And. !Empty( &("M->"+aCposAto[n]))
           dData := &("M->" + aCposAto[n])
           Exit
        //ElseIf aCposAto[n] $ "ED0_PROAP3/ED0_PROAP2/ED0_PROAP1" .and. &("M->"+aCposAto[n]) == "1"
		ElseIf aCposAto[n] $ "ED0_DT_PR3/ED0_DT_PR2/ED0_DT_PR1" .and.;
			   &("M->ED0_PROAP"+Right(aCposAto[n],1)) == "1"
           //dData := &("M->" + "ED0_DT_PR" + SubStr(aCposAto[n],Len(aCposAto[n])-1, Len(aCposAto[n])))
		   dData := &("M->"+aCposAto[n])
           Exit
        ElseIf aCposAto[n] == "ED0_DT_VA2" .And. !Empty( &("M->"+aCposAto[n]))
           dData := &("M->" + aCposAto[n])
           Exit
        EndIf
      Next n
      If dData == Nil
         dData:= &("M->" + aCposAto[Len(aCposAto)])
      EndIf
   EndIf
EndIf

/*
If cAlias="ED0" // DFS - Reformulação de tratamento para vencimento de Ato
   For N:=1 to Len(aCposAto)
     If ED0->(FieldPos(aCposAto[n])) > 0
        If (aCposAto[n] == "ED0_DT_VA1") .And. !Empty( &("ED0->" + aCposAto[n]))
           dData := &("ED0->" + aCposAto[n])
        EndIf
     Else
        MsgInfo("Existe(m) campo(s) informado(s) no parâmetro 'MV_AVG0190' inválidos. Revalidar o conteúdo do Parâmetro!")
     EndIf
   Next N
Else
   If lAltera // DFS - Reformulação de tratamento para vencimento de Ato
      For N:=1 to Len(aCposAto)
        If ED0->(FieldPos(aCposAto[n])) > 0
           If (aCposAto[n]== "ED0_DT_VA1") .And. !Empty(&("M->" + aCposAto[n]))
              dData := &("M->" + aCposAto[n])
           EndIf
        Else
           MsgInfo("Existe(m) campo(s) informado(s) no parâmetro 'MV_AVG0190' inválido(s). Revalidar o conteúdo do Parâmetro!")
        EndIf
      Next N
   Else
      For N:=1 to Len(aCposAto) // DFS - Reformulação de tratamento para vencimento de Ato
        If ED0->(FieldPos(aCposAto[n])) > 0
           If (aCposAto[n] == "ED0_DT_ENC" .OR. aCposAto[n] == "ED0_DT_VA2" .OR. aCposAto[n] == "ED0_DT_VA1") .and. !Empty( &("M->" + aCposAto[n]))
              dData := &("M->" + aCposAto[n])
              Exit
           EndIf
        Else
           MsgInfo("Existe(m) campo(s) informado(s) no parâmetro 'MV_AVG0190', inválido(s). Revalidar o conteúdo do Parâmetro!")
        EndIf
      Next N
   EndIf
EndIf
*/
If cBaixa == "BAIXA"  //AOM - 14/09/2010

   dData += nDiasBaixa

EndIf

Return dData

/*
Revisão: dez/2012
         Para adequação da identidade visual as ações Cancelar/ Fechar, Confirmar/ Salvar,
         Calculadora, Impressora e Help, que são comuns para todas as pastas, foram migradas
         para a EnchoiceBar. */
*--------------------------------------------------------------*
Function AC400Bar(oDlgH,aOk,bCancel,nOpc,aBotoes)           // H
*--------------------------------------------------------------*
IF aBotoes # NIL
   AAdd(aButtons, {,, oDlgH:cTitle, oDlgH:cTitle,,, aBotoes})
ENDIF

RETURN
*----------------------------*
Static Function IniCpos(nTipo)
*----------------------------*
Local nPos
Local aCposTira := {} //AOM - 30/10/10

ProcRegua(If(nTipo=2,2,7))

If nTipo = 2
   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos := BrowseCpos("ED1","WorkED1")
   AcertaCpos("1")
   If M->ED0_MODAL == ISENCAO  .And.  lMultiFil
      AAdd(aSelCpos,NIL)
      AIns(aSelCpos,14)
      aSelCpos[14] := { "ED1_FILORI", , AVSX3("ED1_FILORI",5), AVSX3("ED1_FILORI",6) }
   EndIf
   //AOM - 26/05/2010 - Adicionando o titulo da descricao do produto
   If (nPos := aScan(aSelCpos, {|x| AllTrim(x[1]) == "ED1_PROD" })) > 0
      aAdd(aSelCpos, Nil)
      aIns(aSelCpos, nPos + 1)
      aSelCpos[nPos+1] := {"ED1_DESCPD", , AvSx3("B1_DESC",5),AVSX3("B1_DESC",6)}
   EndIf

   IncProc(STR0008) //"Inicializando Ambiente"
   If M->ED0_MODAL == SUSPENSAO
      aCposTira := {"ED2_QTDORI","ED2_RE","ED2_INAT","ED2_DT_NF","ED2_UMANEX"}  //AOM - 30/10/10
   EndIf
   aSelCpos2:= BrowseCpos("ED2","WorkED2",aCposTira)
   AcertaCpos("2")
   If M->ED0_MODAL == ISENCAO  .And.  lMultiFil
      AAdd(aSelCpos2,NIL)
      AIns(aSelCpos2,19)
      aSelCpos2[19] := { "ED2_FILORI", , AVSX3("ED2_FILORI",5), AVSX3("ED2_FILORI",6) }
   EndIf
   //AOM - 26/05/2010 - Adicionando o titulo da descricao do produto e Item
   If (nPos := aScan(aSelCpos2, {|x| AllTrim(x[1]) == "ED2_ITEM" })) > 0
      aAdd(aSelCpos2, Nil)
      aIns(aSelCpos2, nPos + 1)
      aSelCpos2[nPos+1] := {"ED2_DESCIT", , AvSx3("B1_DESC",5),AVSX3("B1_DESC",6)}
   EndIf
   If (nPos := aScan(aSelCpos2, {|x| AllTrim(x[1]) == "ED2_PROD" })) > 0
      aAdd(aSelCpos2, Nil)
      aIns(aSelCpos2, nPos + 1)
      aSelCpos2[nPos+1] := {"ED2_DESCPD", , AvSx3("B1_DESC",5),AVSX3("B1_DESC",6)}
   EndIf

   If M->ED0_MODAL == ISENCAO
      AADD(aSemSX3RE,{"MARCA","C",2,0})
      AADD(aSemSX3RE,{"ED1_RE","C",AVSX3("ED1_RE",3),0})
      AADD(aSemSX3RE,{"ED1_DTRE","D",8,0})
      AADD(aSemSX3RE,{"ED1_PROD","C",AVSX3("ED1_PROD",3),0})
      AADD(aSemSX3RE,{"ED1_NCM","C",AVSX3("ED1_NCM",3),0})
      AADD(aSemSX3RE,{"ED1_QTD","N",AVSX3("EE9_SLDINI",3),AVSX3("EE9_SLDINI",4)})
      AADD(aSemSX3RE,{"ED1_VL_MOE","N",AVSX3("ED1_VL_MOE",3),AVSX3("ED1_VL_MOE",4)})
      AADD(aSemSX3RE,{"ED1_MOEDA","C",AVSX3("ED1_MOEDA",3),0})
      AADD(aSemSX3RE,{"ED1_PREEMB","C",AVSX3("ED1_PREEMB",3),0})
      AADD(aSemSX3RE,{"ED1_PEDIDO","C",AVSX3("ED1_PEDIDO",3),0})
      AADD(aSemSX3RE,{"ED1_SEQUEN","C",AVSX3("ED1_SEQUEN",3),0})
      AADD(aSemSX3RE,{"ED1_PESO","N",AVSX3("ED1_PESO",3),AVSX3("ED1_PESO",4)})
      AADD(aSemSX3RE,{"ED1_PERCAG","N",AVSX3("ED1_PERCAG",3),AVSX3("ED1_PERCAG",4)})
      AADD(aSemSX3RE,{"UNID","C",AVSX3("EE9_UNIDAD",3),0})
      AADD(aSemSX3RE,{"EXP","C",AVSX3("EEC_EXPORT",3),0})
      AADD(aSemSX3RE,{"LEXP","C",AVSX3("EEC_EXLOJA",3),0})
      AADD(aSemSX3RE,{"FORN","C",AVSX3("EEC_FORN",3),0})
      AADD(aSemSX3RE,{"LFORN","C",AVSX3("EEC_FOLOJA",3),0})
      AADD(aSemSX3RE,{"ISENTO","C",AVSX3("EE9_ISENTO",3),0})
      AADD(aSemSX3RE,{"SALISE","N",AVSX3("EE9_SALISE",3),AVSX3("EE9_SALISE",4)})
      AADD(aSemSX3RE,{"ED1_VAL_EM","N",AVSX3("ED1_VAL_EM",3),AVSX3("ED1_VAL_EM",4)})
      AADD(aSemSX3RE,{"FABR","C",AVSX3("EE9_FABR",3),0})
      AADD(aSemSX3RE,{"ED1_DTEMBA","D",8,0})
      AADD(aSemSX3RE,{"MENSA","C",230,0}) //LGS-11/12/2015
      // ** PLB 15/03/07
      AADD(aSemSX3RE,{"EE9_PSLQTO",AVSX3("EE9_PSLQTO",2),AVSX3("EE9_PSLQTO",3),AVSX3("EE9_PSLQTO",4)})
      AADD(aSemSX3RE,{"EE9_SLDINI",AVSX3("EE9_SLDINI",2),AVSX3("EE9_SLDINI",3),AVSX3("EE9_SLDINI",4)})
      // **
      //TRP - 01/02/07 - Campos do WalkThru
      AADD(aSemSX3RE,{"TRB_ALI_WT","C",03,0})
      AADD(aSemSX3RE,{"TRB_REC_WT","N",10,0})

      If lMultiFil
         AAdd(aSemSX3RE,{"ED1_FILORI",AVSX3("ED1_FILORI",2),AVSX3("ED1_FILORI",3)+18,AVSX3("ED1_FILORI",4)})
      EndIf

      AADD(aSemSX3DI,{"MARCA","C",2,0})
      AADD(aSemSX3DI,{"ED2_ITEM","C",AVSX3("ED2_ITEM",3),0})
      AADD(aSemSX3DI,{"ED2_NCM","C",AVSX3("ED2_NCM",3),0})
      AADD(aSemSX3DI,{"AC","C",AVSX3("ED2_AC",3),0})
      AADD(aSemSX3DI,{"ED2_QTD","N",AVSX3("ED2_QTD",3),AVSX3("ED2_QTD",4)})
      AADD(aSemSX3DI,{"ED2_PESO","N",AVSX3("ED2_QTDNCM",3),AVSX3("ED2_QTDNCM",4)}) // TAN AADD(aSemSX3DI,{"ED2_PESO","N",AVSX3("ED2_PESO",3),AVSX3("ED2_PESO",4)})
      AADD(aSemSX3DI,{"ED2_DI_NUM","C",AVSX3("ED2_DI_NUM",3),0})
      AADD(aSemSX3DI,{"ED2_VALEMB","N",AVSX3("ED2_VALEMB",3),AVSX3("ED2_VALEMB",4)})
      AADD(aSemSX3DI,{"ED2_DTREG","D",8,0})
      if lED2Dt_Nf   // ACSJ - 17/11/2004
         AADD(aSemSX3DI,{"ED2_DT_NF","D",8,0})
      Endif
      AADD(aSemSX3DI,{"FORN","C",AVSX3("W8_FORN",3),0})
      AADD(aSemSX3DI,{"ED2_VL_MOE","N",AVSX3("ED2_VL_MOE",3),AVSX3("ED2_VL_MOE",4)})
      AADD(aSemSX3DI,{"ED2_HAWB","C",AVSX3("ED2_HAWB",3),0})
      AADD(aSemSX3DI,{"ED2_MOEDA","C",AVSX3("ED2_MOEDA",3),0})
      AADD(aSemSX3DI,{"FREINC","C",AVSX3("W9_FREINC",3),0})
      AADD(aSemSX3DI,{"FRETEIN","N",AVSX3("W9_FRETEIN",3),AVSX3("W9_FRETEIN",4)})
      // EOB - 13/06/08 - Inclusao do tratamento de incoterms com seguro
      IF lSegInc
         AADD(aSemSX3DI,{"SEGINC","C",AVSX3("W9_SEGINC",3),0})
         AADD(aSemSX3DI,{"SEGURIN","N",AVSX3("W9_SEGURO",3),AVSX3("W9_SEGURO",4)})
      ENDIF
      AADD(aSemSX3DI,{"ED2_TX_MOE","N",AVSX3("ED2_TX_MOE",3),AVSX3("ED2_TX_MOE",4)})
      AADD(aSemSX3DI,{"ED2_PO_NUM","C",AVSX3("ED2_PO_NUM",3),0})
      AADD(aSemSX3DI,{"ED2_POSICA","C",AVSX3("ED2_POSICA",3),0})
      AADD(aSemSX3DI,{"ED2_PGI_NU","C",AVSX3("ED2_PGI_NU",3),0})
      AADD(aSemSX3DI,{"ED2_INVOIC","C",AVSX3("ED2_INVOIC",3),0})
      AADD(aSemSX3DI,{"FABR","C",AVSX3("W8_FABR",3),0})
      AADD(aSemSX3DI,{"IMP","C",AVSX3("W2_IMPORT",3),0})
      AADD(aSemSX3DI,{"ED2_ADICAO","C",AVSX3("ED2_ADICAO",3),0})
      AADD(aSemSX3DI,{"ED2_TX_USS","N",AVSX3("ED2_TX_USS",3),AVSX3("ED2_TX_USS",4)})
      AADD(aSemSX3DI,{"UNID","C",AVSX3("W8_UNID",3),0})
      //AADD(aSemSX3DI,{"TIPOFEC","C",AVSX3("W6_TIPOFEC",3),0})
      AADD(aSemSX3DI,{"UNID_A5","C",AVSX3("A5_UNID",3),0})
      AADD(aSemSX3DI,{"ISENTOT","C",AVSX3("W8_ISENTOT",3),0})
      AADD(aSemSX3DI,{"SALISEN","N",AVSX3("W8_SALISEN",3),AVSX3("W8_SALISEN",4)})
      AADD(aSemSX3DI,{"ED2_VLORIT","N",AVSX3("ED2_VALORI",3),AVSX3("ED2_VALORI",4)})
      AADD(aSemSX3DI,{"ED2_VALORI","N",AVSX3("ED2_VALORI",3),AVSX3("ED2_VALORI",4)})
      AADD(aSemSX3DI,{"ED2_FRETE","N",AVSX3("ED2_FRETE",3),AVSX3("ED2_FRETE",4)})
      AADD(aSemSX3DI,{"FRETE","N",AVSX3("W6_VLFRECC",3),AVSX3("W6_VLFRECC",4)})
      AADD(aSemSX3DI,{"SEGURO","N",AVSX3("W6_VL_USSE",3),AVSX3("W6_VL_USSE",4)})
      AADD(aSemSX3DI,{"QTDORITOT","N",AVSX3("ED2_QTD",3),AVSX3("ED2_QTD",4)})
      AADD(aSemSX3DI,{"MENSA","C",230,0}) //LGS-11/12/2015
      AADD(aSemSX3DI,{"ED2_MOE_FR","C",AVSX3("ED2_MOE_FR",3),0})
      AADD(aSemSX3DI,{"ED2_TX_FR","N",AVSX3("ED2_TX_FR",3),AVSX3("ED2_TX_FR",4)})
      AADD(aSemSX3DI,{"ED2_FR_USS","N",AVSX3("ED2_FR_USS",3),AVSX3("ED2_FR_USS",4)})
      AADD(aSemSX3DI,{"ED2_RE","C",AVSX3("ED2_RE",3),0})
      AADD(aSemSX3DI,{"ED2_PROD","C",AVSX3("ED2_PROD",3),0})
      AADD(aSemSX3DI,{"DATAANT","D",8,0})
      AADD(aSemSX3DI,{"QTDORI","N",AVSX3("ED2_QTD",3),AVSX3("ED2_QTD",4)})
      AADD(aSemSX3DI,{"VALEMBORI","N",AVSX3("ED2_VALEMB",3),AVSX3("ED2_VALEMB",4)})
      AADD(aSemSX3DI,{"VLMOEORI","N",AVSX3("ED2_VL_MOE",3),AVSX3("ED2_VL_MOE",4)})
      //TRP - 01/02/07 - Campos do WalkThru
      AADD(aSemSX3DI,{"TRB_ALI_WT","C",03,0})
      AADD(aSemSX3DI,{"TRB_REC_WT","N",10,0})
      //BHF - 28/01/09
      AADD(aSemSX3DI,{"INCOTERM",AVSX3("W6_INCOTERM",2),AVSX3("W6_INCOTERM",3),AVSX3("W6_INCOTERM",4)}) // Incoterm
	  AADD(aSemSX3DI,{"INLAND" , AVSX3("W6_INLAND",2),  AVSX3("W6_INLAND",3),  AVSX3("W6_INLAND",4)})   // Inland
	  AADD(aSemSX3DI,{"PACKING", AVSX3("W6_PACKING",2), AVSX3("W6_PACKING",3), AVSX3("W6_PACKING",4)})  // Packing
	  AADD(aSemSX3DI,{"OUTDESP", AVSX3("W6_OUTDESP",2), AVSX3("W6_OUTDESP",3), AVSX3("W6_OUTDESP",4)})  // OutDesp
	  AADD(aSemSX3DI,{"DESCONT", AVSX3("W6_DESCONT",2), AVSX3("W6_DESCONT",3), AVSX3("W6_DESCONT",4)})  // Descont
      // EOB - 13/06/08 - Inclusao do tratamento de incoterms com seguro
      //IF lSegInc
      //   AADD(aSemSX3DI,{"SEGINC","C",AVSX3("W9_SEGINC",3),0})
      //   AADD(aSemSX3DI,{"SEGURIN","N",AVSX3("W9_SEGURO",3),AVSX3("W9_SEGURO",4)})
      //ENDIF

      if lED2Inat   // ACSJ - 17/11/2004
         AADD(aSemSX3DI,{"ED2_INAT","C",AVSX3("ED2_INAT",3),0})
      Endif
      //AAF 01/06/05 - Valor Comercial a Perda
      If lTemVLCOMPE
         AADD(aSemSX3DI,{"ED2_VLCOPE","C",1,0})
      Endif
      If lMultiFil
         AAdd(aSemSX3DI,{"ED2_FILORI",AVSX3("ED2_FILORI",2),AVSX3("ED2_FILORI",3)+18,AVSX3("ED2_FILORI",4)})
      Endif

      If M->ED0_MODAL <> SUSPENSAO
         if aScan(aSelCpos11[3], "EDC_RE") == 0 // AAF 27/05/04 - Verifica se o campo R.E. já está sendo exibido
            aAdd(aSelCpos11,NIL)
            aIns(aSelCpos11,3)
            aSelCpos11[3] := {"EDC_RE"    ,,AVSX3("EDC_RE"  ,5)}
         endif
      EndIf

      // *** GFP - 30/08/2011 - Campos NF
      If AvFlags("COMPRAS NACIONAIS")
         If ED2->(FieldPos("ED2_NF")) > 0
            aAdd(aSelCpos2,{"ED2_NF", "C", AVSX3("ED2_NF",5), AVSX3("ED2_NF",6)})
            aAdd(aSelCpos8,{"ED2_NF", "C", AVSX3("ED2_NF",5), AVSX3("ED2_NF",6)})
            aAdd(aSemSX3DI,{"ED2_NF", "C", AVSX3("ED2_NF",3), AVSX3("ED2_NF",4)})
         EndIf
         If ED2->(FieldPos("ED2_SERIE")) > 0
            aAdd(aSelCpos2,{"ED2_SERIE", "C", AVSX3("ED2_SERIE",5), AVSX3("ED2_SERIE",6)})
            aAdd(aSelCpos8,{"ED2_SERIE", "C", AVSX3("ED2_SERIE",5), AVSX3("ED2_SERIE",6)})
            aAdd(aSemSX3DI,{"ED2_SERIE", "C", AVSX3("ED2_SERIE",3), AVSX3("ED2_SERIE",4)})
         EndIf
         If ED2->(FieldPos("ED2_FORN")) > 0
            aAdd(aSelCpos2,{"ED2_FORN", "C", AVSX3("ED2_FORN",5), AVSX3("ED2_FORN",6)})
            aAdd(aSelCpos8,{"ED2_FORN", "C", AVSX3("ED2_FORN",5), AVSX3("ED2_FORN",6)})
            aAdd(aSemSX3DI,{"ED2_FORN", "C", AVSX3("ED2_FORN",3), AVSX3("ED2_FORN",4)})
         EndIf
         If ED2->(FieldPos("ED2_LOJA"))  > 0
            aAdd(aSelCpos2,{"ED2_LOJA", "C", AVSX3("ED2_LOJA",5), AVSX3("ED2_LOJA",6)})
            aAdd(aSelCpos8,{"ED2_LOJA", "C", AVSX3("ED2_LOJA",5), AVSX3("ED2_LOJA",6)})
            aAdd(aSemSX3DI,{"ED2_LOJA", "C", AVSX3("ED2_LOJA",3), AVSX3("ED2_LOJA",4)})
         EndIf
      EndIf

      //AOM - 11/11/11
      If AvFlags("SEQMI")
         aAdd(aSemSX3DI,{"ED2_IMPORT", "C", AVSX3("ED2_IMPORT",3), AVSX3("ED2_IMPORT",4)})
      EndIf

      //AOM - 14/03/2012
      If ED2->(FieldPos("ED2_DTRE"))  > 0
         aAdd(aSemSX3DI,{"ED2_DTRE", "D", AVSX3("ED2_DTRE",3), AVSX3("ED2_DTRE",4)})
      EndIf

      //AOM - 14/03/2012
      If ED2->(FieldPos("ED2_DTEMBA"))  > 0
         aAdd(aSemSX3DI,{"ED2_DTEMBA", "D", AVSX3("ED2_DTEMBA",3), AVSX3("ED2_DTEMBA",4)})
      EndIf

      //LGS - 11/12/2015
      AADD(aSemSX3DI,{"ORIGEM","C",3,0})
      //NCF - 31/07/2020 - Melhoria Performance
      AADD(aSemSX3DI,{"PESOITPRC","N", AVSX3("WN_PESOL",3), AVSX3("WN_PESOL",4)})
      AADD(aSemSX3DI,{"PESOITNFE","N", AVSX3("WN_PESOL",3), AVSX3("WN_PESOL",4)})

   Else
      AADD(aSemSX31,{"ED1_MARCA","C",2,0})
      AADD(aSemSX31,{"ED1_PROD","C",AVSX3("ED1_PROD",3),0})
      AADD(aSemSX31,{"ED1_NCM","C",AVSX3("ED1_NCM",3),0})
      AADD(aSemSX31,{"ED1_QTD","N",AVSX3("ED1_QTD",3),AVSX3("ED1_QTD",4)})
      AADD(aSemSX31,{"ED1_VAL_EM","N",AVSX3("ED1_VAL_EM",3),AVSX3("ED1_VAL_EM",4)})
      AADD(aSemSX31,{"ED1_VAL_SE","N",AVSX3("ED1_VAL_SE",3),AVSX3("ED1_VAL_SE",4)})
      AADD(aSemSX31,{"ED1_PERCAG","N",AVSX3("ED1_PERCAG",3),AVSX3("ED1_PERCAG",4)})
      AADD(aSemSX31,{"ED1_PRCUNI","N",AVSX3("ED1_PRCUNI",3),AVSX3("ED1_PRCUNI",4)})

      AADD(aSemSX32,{"ED2_MARCA","C",2,0})
      AADD(aSemSX32,{"ED2_ITEM","C",AVSX3("ED2_ITEM",3),0})
      AADD(aSemSX32,{"ED2_UMITEM","C",AVSX3("ED2_UMITEM",3),0})
      AADD(aSemSX32,{"ED2_NCM","C",AVSX3("ED2_NCM",3),0})
      AADD(aSemSX32,{"ED2_QTD","N",AVSX3("ED2_QTD",3),AVSX3("ED2_QTD",4)})
      AADD(aSemSX32,{"ED2_VALEMB","N",AVSX3("ED2_VALEMB",3),AVSX3("ED2_VALEMB",4)})
      AADD(aSemSX32,{"ED2_PERCPE","N",AVSX3("ED2_PERCPE",3),AVSX3("ED2_PERCPE",4)})
      AADD(aSemSX32,{"ED2_CAMB","C",AVSX3("ED2_CAMB",3),0})
      AADD(aSemSX32,{"ED2_PRCUNI","N",AVSX3("ED2_PRCUNI",3),AVSX3("ED2_PRCUNI",4)})
      AADD(aSemSX32,{"ED2_UMNCM","C",AVSX3("ED2_UMNCM",3),0})

      If aScan(aSelCpos11[3], "EDC_RE") <> 0  // AAF 27/05/04 - Recria ARRAY sem o campo R.E.
         aSelCpos11:={ {"EDC_ITEM"  ,,AVSX3("EDC_ITEM",5)},;
                     {"EDC_PROD"  ,,AVSX3("EDC_PROD",5)},;
                     {"EDC_QTD"   ,,AVSX3("EDC_QTD",5),AVSX3("EDC_QTD",6)},;
                     {"EDC_QTDEST",,STR0196,AVSX3("EDC_QTDEST",6)},; //"Qtd. Estrutura"
                     {{|| WorkEDC->EDC_QTDEST - WorkEDC->EDC_QTD},,STR0197,AVSX3("EDC_QTD",6)} } //"Saldo"
         //ER - 24/09/2007
         If EDC->(FieldPos("EDC_QTDBAS")) > 0
            aAdd(aSelCpos11, {"EDC_QTDBAS" ,,AVSX3("EDC_QTDBAS",5),AVSX3("EDC_QTDBAS",6)})
         EndIf

         If EDC->(FieldPos("EDC_PERDA")) > 0
            aAdd(aSelCpos11, {"EDC_PERDA" ,,AVSX3("EDC_PERDA",5),AVSX3("EDC_PERDA",6)})
         EndIf

         If EDC->(FieldPos("EDC_QTDPRO")) > 0
            aAdd(aSelCpos11, {"EDC_QTDPRO" ,,AVSX3("EDC_QTDPRO",5),AVSX3("EDC_QTDPRO",6)})
         EndIf


         SX3->(DbSetOrder(2))
         If SX3->(DbSeek("EDC_FATNET"))
            aAdd(aSelCpos11, {"EDC_FATNET" ,,AVSX3("EDC_FATNET",5),AVSX3("EDC_FATNET",6)})
         EndIf

         If SX3->(DbSeek("EDC_FATGRO"))
            aAdd(aSelCpos11, {"EDC_FATGRO" ,,AVSX3("EDC_FATGRO",5),AVSX3("EDC_FATGRO",6)})
         EndIf

         If lLeadTime
            aAdd(aSelCpos11, {"EDC_LEADTI" ,,AVSX3("EDC_LEADTI",5),AVSX3("EDC_LEADTI",6)})
            aAdd(aSelCpos11, {"EDC_PRODUC" ,,AVSX3("EDC_PRODUC",5),AVSX3("EDC_PRODUC",6)})
         EndIf
      endif
   EndIf

   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos3:= BrowseCpos("ED3","WorkED3")
   AcertaCpos("3")
   //AOM - 26/05/2010 - Adicionando o titulo da descricao do produto
   If (nPos := aScan(aSelCpos3, {|x| AllTrim(x[1]) == "ED3_PROD" })) > 0
      aAdd(aSelCpos3, Nil)
      aIns(aSelCpos3, nPos + 1)
      aSelCpos3[nPos+1] := {"ED3_DESCPD", , AvSx3("B1_DESC",5),AVSX3("B1_DESC",6)}
   EndIf

   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos4:= BrowseCpos("ED4","WorkED4")
   aSelCpos4A:= BrowseCpos("ED4","WorkED4",aCposTira)
   AcertaCpos("4")
   //AOM - 26/05/2010 - Adicionando o titulo da descricao do Item
   If (nPos := aScan(aSelCpos4, {|x| AllTrim(x[1]) == "ED4_ITEM" })) > 0
      aAdd(aSelCpos4, Nil)
      aIns(aSelCpos4, nPos + 1)
      aSelCpos4[nPos+1] := {"ED4_DESCIT", , AvSx3("B1_DESC",5),AVSX3("B1_DESC",6)}
   EndIf
   //AOM - 09/11/2011
   If AvFlags("SEQMI") .And. (nPos := aScan(aSelCpos4A, {|x| AllTrim(x[1]) == "ED4_SEQSIS" })) > 0
      aSelCpos4A[nPos] := {"ED4_SEQMI", , AvSx3("ED4_SEQMI",5),AVSX3("ED4_SEQMI",6)}
   EndIf
   If (nPos := aScan(aSelCpos4A, {|x| AllTrim(x[1]) == "ED4_ITEM" })) > 0
      aAdd(aSelCpos4A, Nil)
      aIns(aSelCpos4A, nPos + 1)
      aSelCpos4A[nPos+1] := {"ED4_DESCIT", , AvSx3("B1_DESC",5),AVSX3("B1_DESC",6)}
   EndIf

Else

   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos5:= {  {"ED1_MARCA" ,,""},;
                  {"ED1_PROD"  ,,AVSX3("ED1_PROD",5)},;
                  {"ED1_NCM"   ,,AVSX3("ED1_NCM",5),AVSX3("ED1_NCM",6)},;
                  {"ED1_QTD"   ,,AVSX3("ED1_QTD",5),AVSX3("ED1_QTD",6)},;
                  {"ED1_VAL_EM",,AVSX3("ED1_VAL_EM",5),AVSX3("ED1_VAL_EM",6)},;
                  {"ED1_VAL_SE",,AVSX3("ED1_VAL_SE",5),AVSX3("ED1_VAL_SE",6)},;
                  {"ED1_PERCAG",,AVSX3("ED1_PERCAG",5),AVSX3("ED1_PERCAG",6)} }

   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos6:= {  {"ED2_MARCA" ,,""},;
                  {"ED2_ITEM"  ,,AVSX3("ED2_ITEM",5)},;
                  {"ED2_NCM"   ,,AVSX3("ED2_NCM",5),AVSX3("ED2_NCM",6)},;
                  {"ED2_QTD"   ,,AVSX3("ED2_QTD",5),AVSX3("ED2_QTD",6)},;
                  {"ED2_VALEMB",,AVSX3("ED2_VALEMB",5),AVSX3("ED2_VALEMB",6)},;
                  {"ED2_PERCPE",,AVSX3("ED2_PERCPE",5),AVSX3("ED2_PERCPE",6)} }

   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos7:= {  {"MARCA"     ,,""},;
                  {"ED1_RE"    ,,AVSX3("ED1_RE"    ,5),   },; //AVSX3("ED1_RE",6)
                  {"ED1_DTRE"  ,,AVSX3("EE9_DTRE"  ,5),AVSX3("EE9_DTRE",6)},;
                  {"ED1_DTEMBA",,AVSX3("ED1_DTEMBA",5),AVSX3("ED1_DTEMBA",6)},;
                  {"ED1_PREEMB",,AVSX3("ED1_PREEMB",5),AVSX3("ED1_PREEMB",6)},;
                  {"ED1_PEDIDO",,AVSX3("ED1_PEDIDO",5),AVSX3("ED1_PEDIDO",6)},;//AAF 16/05/05 Adicionado campo Pedido.
                  {"ED1_SEQUEN",,AVSX3("ED1_SEQUEN",5),AVSX3("ED1_SEQUEN",6)},;//AAF 16/05/05 Adicionado campo Sequencia.
                  {"ED1_PROD"  ,,AVSX3("ED1_PROD",5)},;
                  {"ED1_NCM"   ,,AVSX3("ED1_NCM",5),AVSX3("ED1_NCM",6)},;
                  {{||If(WorkRE->ISENTO=="N",WorkRE->SALISE,WorkRE->ED1_QTD)} ,,AVSX3("ED1_QTD",5),AVSX3("ED1_QTD",6)},;
                  {"UNID"      ,,STR0169,AVSX3("ED1_UMPROD",6)},; //"U.M. (Embarque)"
                  {"ED1_PESO"  ,,AVSX3("EE9_PSLQUN",5),AVSX3("EE9_PSLQUN",6)},;
                  {{||If(WorkRE->ED1_VAL_EM=0,(WorkRE->ED1_VL_MOE*BuscaTxAC(WorkRE->ED1_MOEDA,WorkRE->ED1_DTRE,,.F.,.T.,"E"))/BuscaTxAC(DOLAR,WorkRE->ED1_DTRE,,.F.,.T.,"E"),WorkRE->ED1_VAL_EM)},,AVSX3("ED1_VAL_EM",5)+" (US$)",AVSX3("ED1_VAL_EM",6)},;
                  {{||(WorkRE->ED1_VL_MOE*BuscaTxAC(WorkRE->ED1_MOEDA,WorkRE->ED1_DTRE,,.F.,.T.,"E"))/BuscaTxAC(DOLAR,WorkRE->ED1_DTRE,,.F.,.T.,"E")},,AVSX3("ED1_VALORI",5)+" (US$)",AVSX3("ED1_VALORI",6)},;
                  {"ED1_PERCAG",,AVSX3("ED1_PERCAG",5),AVSX3("ED1_PERCAG",6)},;
                  {"ED1_MOEDA" ,,AVSX3("ED1_MOEDA",5),AVSX3("ED1_MOEDA",6)},;
                  {"ED1_VL_MOE",,AVSX3("ED1_VL_MOE",5),AVSX3("ED1_VL_MOE",6)},;
                  {{||BuscaTxAC(WorkRE->ED1_MOEDA,WorkRE->ED1_DTRE,,.F.,.T.,"E")},,AVSX3("ED1_TX_MOE",5),AVSX3("ED1_TX_MOE",6)},;
                  {{||BuscaTxAC(DOLAR,WorkRE->ED1_DTRE,,.F.,.T.,"E")},,AVSX3("ED1_TX_USS",5),AVSX3("ED1_TX_USS",6)},;
                  {"MENSA"     ,,STR0195} } //Mensagem
   If lMultiFil
      AAdd( aSelCpos7, NIL )
      AIns( aSelCpos7, 2 )
      aSelCpos7[2] := { "ED1_FILORI", , AVSX3("ED1_FILORI",5), AVSX3("ED1_FILORI",6) }
   EndIf

   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos8:={   {"MARCA"     ,,""},;
                  {"ED2_RE"    ,,AVSX3("ED1_RE",5)    , },; //AVSX3("ED1_RE",6)
                  {"ED2_PROD"  ,,AVSX3("ED2_PROD",5)  ,AVSX3("ED2_PROD"  ,6)},;
                  {"ED2_PO_NUM",,AVSX3("ED2_PO_NUM",5),AVSX3("ED2_PO_NUM",6)},;//AAF 16/05/05 Adicionado campo Numero do PO.
                  {"ED2_POSICA",,AVSX3("ED2_POSICA",5),AVSX3("ED2_POSICA",6)},;//AAF 16/05/05 Adicionado campo Posição.
                  {"ED2_DTREG" ,,AVSX3("W6_DTREG_D",5),AVSX3("W6_DTREG_D",6)},;
                  {"ED2_DI_NUM",,AVSX3("ED2_DI_NUM",5),AVSX3("ED2_DI_NUM",6)},;
                  {"ED2_INVOIC",,AVSX3("ED2_INVOIC",5),AVSX3("ED2_INVOIC",6)},;//AAF 20/07/05 Adicionado campo Nr. Invoice.
                  {"ED2_ITEM"  ,,AVSX3("ED2_ITEM",5)},;
                  {{||If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)} ,,AVSX3("ED2_QTDNCM",5),AVSX3("ED2_QTDNCM",6)},;
                  {"QTDORI"    ,,STR0280,AVSX3("ED2_QTD",6)},;  //"Qtd. Original"
                  {"ED2_ADICAO",,AVSX3("ED2_ADICAO",5),AVSX3("ED2_ADICAO",6)},;
                  {"ED2_HAWB"  ,,AVSX3("ED2_HAWB"  ,5),AVSX3("ED2_HAWB",6)},;
                  {"ED2_NCM"   ,,AVSX3("ED2_NCM",5),AVSX3("ED2_NCM",6)},;
                  {"UNID"      ,,STR0169,AVSX3("ED2_UMITEM",6)},; //"U.M. (Embarque)"
                  {"ED2_PESO"  ,,AVSX3("W7_PESO",5),AVSX3("W7_PESO",6)},;
                  {"ED2_VALEMB",,AVSX3("ED2_VALEMB",5)+" (US$)",AVSX3("ED2_VALEMB",6)},;
                  {"ED2_VALORI",,AVSX3("ED2_VALORI",5)+" (US$)",AVSX3("ED2_VALORI",6)},;
                  {"ED2_MOEDA" ,,AVSX3("ED2_MOEDA",5),AVSX3("ED2_MOEDA",6)},;
                  {"ED2_VL_MOE",,AVSX3("ED2_VL_MOE",5),AVSX3("ED2_VL_MOE",6)},;
                  {"VLMOEORI"  ,,STR0281,AVSX3("ED2_VL_MOE",6)},;  //"Vl. Moe. Orig."
                  {"ED2_TX_MOE",,AVSX3("ED2_TX_MOE",5),AVSX3("ED2_TX_MOE",6)},;
                  {"ED2_TX_USS",,AVSX3("ED2_TX_USS",5),AVSX3("ED2_TX_USS",6)},;
                  {"FRETE"     ,,AVSX3("ED2_FRETE",5)+" D.I.",AVSX3("W6_VLFRECC",6)},;
                  {"SEGURO"    ,,AVSX3("W6_VL_USSE",5)+" D.I.",AVSX3("W6_VL_USSE",6)},;
                  {"MENSA"     ,,STR0195} } //Mensagem

   if lED2Dt_Nf // ACSJ - 17/11/2004
      aAdd(aSelCpos8,NIL)
      aIns(aSelCpos8,11)
      aSelCpos8[11] := {"ED2_DT_NF" ,,AVSX3("W6_DT_NF",5),AVSX3("W6_DT_NF",6)}
   Endif
   if lED2Inat   // ACSJ - 17/11/2004
      aAdd(aSelCpos8,NIL)
      aIns(aSelCpos8,12)
      aSelCpos8[12] := {"ED2_INAT"  ,,AVSX3("ED2_INAT",5)}
   Endif
   If lMultiFil
      AAdd( aSelCpos8, NIL )
      AIns( aSelCpos8, 2 )
      aSelCpos8[2] := { "ED2_FILORI", , AVSX3("ED2_FILORI",5), AVSX3("ED2_FILORI",6) }
   EndIf

   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos9:={  {"EDA_ITEM"  ,,AVSX3("EDA_ITEM",5)},;
                 {"EDA_DESCIT",,AVSX3("B1_DESC",5),AVSX3("B1_DESC",6)},; //AOM - 26/05/2010
                 {"EDA_QTD"   ,,AVSX3("EDA_QTD",5),AVSX3("EDA_QTD",6)},;
                 {"EDA_QTDEST",,STR0196,AVSX3("EDA_QTDEST",6)},; //"Qtd. Estrutura"
                 {{|| WorkEDA->EDA_QTDEST - WorkEDA->EDA_QTD},,STR0197,AVSX3("EDA_QTD",6)} } //"Saldo"

   aSelCpos11:={ {"EDC_ITEM"  ,,AVSX3("EDC_ITEM",5)},;
                 {"EDC_DESCIT",,AVSX3("B1_DESC",5),AVSX3("B1_DESC",6)},; //AOM - 26/05/2010
                 {"EDC_PROD"  ,,AVSX3("EDC_PROD",5)},;
                 {"EDC_DESCPD",,AVSX3("B1_DESC",5),AVSX3("B1_DESC",6)},; //AOM - 26/05/2010
                 {"EDC_QTD"   ,,AVSX3("EDC_QTD",5),AVSX3("EDC_QTD",6)},;
                 {"EDC_QTDEST",,STR0196,AVSX3("EDC_QTDEST",6)},; //"Qtd. Estrutura"
                 {{|| WorkEDC->EDC_QTDEST - WorkEDC->EDC_QTD},,STR0197,AVSX3("EDC_QTD",6)} } //"Saldo"

      //ER - 24/09/2007
      If EDC->(FieldPos("EDC_QTDBAS")) > 0
         aAdd(aSelCpos11, {"EDC_QTDBAS" ,,AVSX3("EDC_QTDBAS",5),AVSX3("EDC_QTDBAS",6)})
      EndIf

      If EDC->(FieldPos("EDC_PERDA")) > 0
         aAdd(aSelCpos11, {"EDC_PERDA" ,,AVSX3("EDC_PERDA",5),AVSX3("EDC_PERDA",6)})
      EndIf

      If EDC->(FieldPos("EDC_QTDPRO")) > 0
         aAdd(aSelCpos11, {"EDC_QTDPRO" ,,AVSX3("EDC_QTDPRO",5),AVSX3("EDC_QTDPRO",6)})
      EndIf

      SX3->(DbSetOrder(2))
      If SX3->(DbSeek("EDC_FATNET"))
         aAdd(aSelCpos11, {"EDC_FATNET" ,,AVSX3("EDC_FATNET",5),AVSX3("EDC_FATNET",6)})
      EndIf

      If SX3->(DbSeek("EDC_FATGRO"))
         aAdd(aSelCpos11, {"EDC_FATGRO" ,,AVSX3("EDC_FATGRO",5),AVSX3("EDC_FATGRO",6)})
      EndIf

      If lLeadTime
         aAdd(aSelCpos11, {"EDC_LEADTI" ,,AVSX3("EDC_LEADTI",5),AVSX3("EDC_LEADTI",6)})
         aAdd(aSelCpos11, {"EDC_PRODUC" ,,AVSX3("EDC_PRODUC",5),AVSX3("EDC_PRODUC",6)})
      EndIf

   IncProc(STR0008) //"Inicializando Ambiente"
   aSelCpos10:={ {"EDB_IMPORT",,AVSX3("EDB_IMPORT",5),AVSX3("EDB_IMPORT",6)},;
                 {"EDB_DESC"  ,,AVSX3("EDB_DESC",5),AVSX3("EDB_DESC",6)},;
                 {"EDB_CNPJ"  ,,AVSX3("EDB_CNPJ",5),AVSX3("EDB_CNPJ",6)},;
                 {"EDB_DELEGA",,AVSX3("EDB_DELEGA",5),AVSX3("EDB_DELEGA",6)}}

   //AOM - 28/10/10 - Campos do MsSelect da aba Baixa de Insumos
   AADD(aSelCpos12,{"SEQSII",,"Seqüência de Saldo de Importação",AVSX3("EDD_SEQSII",6)})//Seqüência de Saldo de Importação
   //AOM - 10/11/2011
   If AvFlags("SEQMI")
      AADD(aSelCpos12,{"SEQMI"  ,,AVSX3("EDD_SEQMI",5) ,AVSX3("EDD_SEQMI",6)  })//Sequencia Mercado Interno
   EndIF
   AADD(aSelCpos12,{"ITEM"  ,,"Código do Item"                  ,AVSX3("EDD_ITEM",6)  })//Código do Item
   AADD(aSelCpos12,{"TPOCOR",,"Tipo de Ocorrência"                                    })//Tipo de Ocorrência
   AADD(aSelCpos12,{"CODOCO",,"Cód. Ocorrência"                                       })//Cód. Ocorrência
   AADD(aSelCpos12,{"DTOCOR",,"Data Ocorrência"                 ,AVSX3("EDD_DTRE",6)  })//Data Ocorrência
   AADD(aSelCpos12,{"RESOCO",,"Resumo da Ocorrência"                                  })//Resumo da Ocorrência
   AADD(aSelCpos12,{"UNIDME",,"Unidade de Medida"               ,AVSX3("ED4_UMITEM",6)})//Unidade de Medida
   AADD(aSelCpos12,{"QTD"   ,,"Quantidade Envolvida"            ,AVSX3("EDD_QTD",6)   })//Quantidade Envolvida
   AADD(aSelCpos12,{"VALOR" ,,"Valor Envolvido US$"             ,AVSX3("W8_VL_AC",6)  })//Valor Envolvido US$
   AADD(aSelCpos12,{"HAWB"  ,,"Numero do Processo Importação"                         })//Numero do Processo Importação
   AADD(aSelCpos12,{"NRDI"  ,,"Numero da DI"                                          })//Numero da DI
   AADD(aSelCpos12,{"DTDI"  ,,"Data da DI"                      ,AVSX3("EDD_DTREG",6) })//Data da DI
   AADD(aSelCpos12,{"CDFORN",,"Código do Fornecedor"                                  })//Código do Fornecedor
   AADD(aSelCpos12,{"LOJA"  ,,"Loja"                                                  })//Loja
   AADD(aSelCpos12,{"NRINV" ,,"Numero da Invoice"                                     })//Numero da Invoice
   AADD(aSelCpos12,{"NRRE"  ,,"Numero da DU-e/ RE"              ,/*AVSX3("EE9_RE",6)*/})//Numero de RE - retirada picture, devido à DUe
   AADD(aSelCpos12,{"CDEMB" ,,"Cód. Embarque"                   ,AVSX3("EDD_PREEMB",6)})//Cód. Embarque
   AADD(aSelCpos12,{"CDPED" ,,"Pedido"                   ,AVSX3("EDD_PEDIDO",6)})//Pedido
   AADD(aSelCpos12,{"ITEMB" ,,"Item Embarque"                   ,AVSX3("EE9_SEQEMB",6)})//Item Embarque
   AADD(aSelCpos12,{"PRODEX",,"Prod. Exportado"                 ,AVSX3("EDD_PROD",6)  })//Prod. Exportado
   AADD(aSelCpos12,{"UMPROD",,"Unidade de Medida do produto"    ,AVSX3("ED3_UMPROD",6)})//Unidade de Medida do produto
   AADD(aSelCpos12,{"QTDEX" ,,"Quantidade Exportada"            ,AVSX3("EDD_QTD_EX",6)})//Quantidade Exportada


EndIf

Return .T.

*--------------------------------------*
Static Function WorkED3Atu(cAlias,nTipo)
*--------------------------------------*
Local cSeqSis, lM:=If(cAlias=="M",.T.,.F.), nValCom
Local nOldOrd:=WorkED3->(IndexOrd())
Local cChaveED3
Local lAgrpED3

If ED0->(FieldPos("ED0_AGRSLD")) > 0 //LRS - 29/07/2015 - Feita a validação pois estava duplicando o registro
  lAgrpED3 := (nTipo == ALTERAR) .Or. (lAgrpSld .AND. (M->ED0_AGRSLD == "1" .OR. M->ED0_AGRSLD == "3"))
Else
  lAgrpED3 := .T.
EndIF

WorkED3->(dbSetOrder(1))

If !lM
   nValCom := ((cAlias)->ED1_VAL_EM * (cAlias)->ED1_PERCAG)/100
EndIf

If lIndPercAg
   If lM
      cChaveED3 := M->ED1_NCM+M->ED1_PROD+Str(M->ED1_PERCAG,5,2)+;
                iif(lED1Umanex,If(Empty(M->ED1_UMANEX),M->ED1_UMNCM,M->ED1_UMANEX),M->ED1_UMNCM)
    Else
      cChaveED3 := (cAlias)->ED1_NCM+(cAlias)->ED1_PROD+Str((cAlias)->ED1_PERCAG,5,2)+;
                iif(lED1Umanex,If(Empty((cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM)
   EndIf
Else
   If lM
      cChaveED3 := M->ED1_NCM+M->ED1_PROD+;
                iif(lED1Umanex,If(Empty(M->ED1_UMANEX),M->ED1_UMNCM,M->ED1_UMANEX),M->ED1_UMNCM)
   Else
      cChaveED3 := (cAlias)->ED1_NCM+(cAlias)->ED1_PROD+;
               iif(lED1Umanex,If(Empty((cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM)
   EndIf
EndIf

If nTipo<>ESTORNAR

   If WorkED3->(dbSeek(cChaveED3)) .AND. lAgrpED3 // ACSJ - 17/11/2004  // GFP - 16/06/2014

      WorkED3->(RecLock("WorkED3",.F.))
      If lM .and. nTipo<>INCLUIR
         nValCom := (WorkED1->ED1_VAL_EM * WorkED1->ED1_PERCAG)/100
         WorkED3->ED3_QTD    += M->ED1_QTD    - WorkED1->ED1_QTD
         WorkED3->ED3_SALDO  += M->ED1_QTD    - WorkED1->ED1_QTD
         WorkED3->ED3_VAL_EM += M->ED1_VAL_EM - WorkED1->ED1_VAL_EM
         WorkED3->ED3_VAL_SE += M->ED1_VAL_SE - WorkED1->ED1_VAL_SE
         WorkED3->ED3_SAL_SE += M->ED1_VAL_SE - WorkED1->ED1_VAL_SE
         WorkED3->ED3_VALCOM += M->ED1_VALCOM - nValCom
         WorkED3->ED3_VAL_CO += (M->ED1_VAL_EM-M->ED1_VALCOM) - (WorkED1->ED1_VAL_EM-nValCom)
         WorkED3->ED3_SAL_CO += (M->ED1_VAL_EM-M->ED1_VALCOM) - (WorkED1->ED1_VAL_EM-nValCom)

         if lED1Umanex   // ACSJ - 17/11/2004
            If Empty(M->ED1_UMANEX)
               WorkED3->ED3_QTDNCM += M->ED1_QTDNCM - WorkED1->ED1_QTDNCM
               WorkED3->ED3_SALNCM += M->ED1_QTDNCM - WorkED1->ED1_QTDNCM
            Else
               WorkED3->ED3_QTDNCM += AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,M->ED1_QTDNCM) - AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,WorkED1->ED1_QTDNCM)
               WorkED3->ED3_SALNCM += AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,M->ED1_QTDNCM) - AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,WorkED1->ED1_QTDNCM)
            Endif
         Else   // ACSJ - 17/11/2004
            WorkED3->ED3_QTDNCM += M->ED1_QTDNCM - WorkED1->ED1_QTDNCM
            WorkED3->ED3_SALNCM += M->ED1_QTDNCM - WorkED1->ED1_QTDNCM
         Endif

         WorkED3->ED3_PESO   += M->ED1_PESO   - WorkED1->ED1_PESO
      Else
         WorkED3->ED3_QTD    += If(lM,M->ED1_QTD,(cAlias)->ED1_QTD)
         WorkED3->ED3_SALDO  += If(lM,M->ED1_QTD,(cAlias)->ED1_QTD)
         WorkED3->ED3_VAL_EM += If(lM,M->ED1_VAL_EM,(cAlias)->ED1_VAL_EM)
         WorkED3->ED3_VAL_SE += If(lM,M->ED1_VAL_SE,(cAlias)->ED1_VAL_SE)
         WorkED3->ED3_SAL_SE += If(lM,M->ED1_VAL_SE,(cAlias)->ED1_VAL_SE)
         WorkED3->ED3_VALCOM += If(lM,M->ED1_VALCOM,nValCom)
         WorkED3->ED3_VAL_CO += If(lM,M->ED1_VAL_EM-M->ED1_VALCOM,(cAlias)->ED1_VAL_EM-nValCom)
         WorkED3->ED3_SAL_CO += If(lM,M->ED1_VAL_EM-M->ED1_VALCOM,(cAlias)->ED1_VAL_EM-nValCom)

         If (lM .and. iif(lED1Umanex,Empty(M->ED1_UMANEX),.t.)) .or.;   // ACSJ - 17/11/2004
            (!lM .and. iif(lED1Umanex,Empty((cAlias)->ED1_UMANEX),.t.)) // ACSJ - 17/11/2004
            WorkED3->ED3_SALNCM += If(lM,M->ED1_QTDNCM,(cAlias)->ED1_QTDNCM)
            WorkED3->ED3_QTDNCM += If(lM,M->ED1_QTDNCM,(cAlias)->ED1_QTDNCM)
         Else  // ACSJ - So Entra na condicao abaixo se o campo ED1_Umanex Existir. - 17/11/2004
            WorkED3->ED3_SALNCM += If(lM,AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,M->ED1_QTDNCM),AvTransUnid((cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX,(cAlias)->ED1_PROD,(cAlias)->ED1_QTDNCM))
            WorkED3->ED3_QTDNCM += If(lM,AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,M->ED1_QTDNCM),AvTransUnid((cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX,(cAlias)->ED1_PROD,(cAlias)->ED1_QTDNCM))
         EndIf
         WorkED3->ED3_PESO   += If(lM,M->ED1_PESO,(cAlias)->ED1_PESO)
      EndIf

      WorkED3->ED3_PERCAG := Round(WorkED3->ED3_VALCOM / WorkED3->ED3_VAL_EM,4)*100

      WorkED3->(msUnlock())
   Else
      cSeqSis := BuscaSeqSis("WorkED3")
      WorkED3->(RecLock("WorkED3",.T.))
      WorkED3->ED3_PROD   := If(lM,M->ED1_PROD,(cAlias)->ED1_PROD)
      WorkED3->ED3_DESCPD := Posicione("SB1",1,xFilial("SB1"/*"ED3"*/)+WorkED3->ED3_PROD,"B1_DESC") // AOM - 26/05/10     // GFP - 30/08/2012
      WorkED3->ED3_SEQSIS := cSeqSis
      WorkED3->ED3_NCM    := If(lM,M->ED1_NCM,(cAlias)->ED1_NCM)
      WorkED3->ED3_QTD    := If(lM,M->ED1_QTD,(cAlias)->ED1_QTD)
      WorkED3->ED3_UMPROD := If(lM,M->ED1_UMPROD,(cAlias)->ED1_UMPROD)
      WorkED3->ED3_SALDO  := If(lM,M->ED1_QTD,(cAlias)->ED1_QTD)
      WorkED3->ED3_VAL_EM := If(lM,M->ED1_VAL_EM,(cAlias)->ED1_VAL_EM)
      WorkED3->ED3_VAL_SE := If(lM,M->ED1_VAL_SE,(cAlias)->ED1_VAL_SE)
      WorkED3->ED3_SAL_SE := If(lM,M->ED1_VAL_SE,(cAlias)->ED1_VAL_SE)
      WorkED3->ED3_VALCOM := If(lM,M->ED1_VALCOM,nValCom)
      WorkED3->ED3_VAL_CO := If(lM,M->ED1_VAL_EM-M->ED1_VALCOM,(cAlias)->ED1_VAL_EM-nValCom)
      WorkED3->ED3_SAL_CO := If(lM,M->ED1_VAL_EM-M->ED1_VALCOM,(cAlias)->ED1_VAL_EM-nValCom)

      WorkED3->ED3_UMNCM  := If(lM, iif(lED1Umanex,If(Empty(M->ED1_UMANEX),M->ED1_UMNCM,M->ED1_UMANEX),M->ED1_UMNCM),iif(lED1Umanex,If(Empty((cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM))  // ACSJ - 17/11/2004

      If (lM .and. iif(lED1Umanex,Empty(M->ED1_UMANEX),.t.)) .or.;   // ACSJ - 17/11/2004
         (!lM .and. iif(lED1Umanex,Empty((cAlias)->ED1_UMANEX),.t.)) // ACSJ - 17/11/2004
         WorkED3->ED3_QTDNCM := If(lM,M->ED1_QTDNCM,(cAlias)->ED1_QTDNCM)
         WorkED3->ED3_SALNCM := If(lM,M->ED1_QTDNCM,(cAlias)->ED1_QTDNCM)
      Else // ACSJ - So Entra na condicao abaixo se o campo ED1_Umanex Existir. - 17/11/2004
         WorkED3->ED3_QTDNCM := If(lM,AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,M->ED1_QTDNCM),AvTransUnid((cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX,(cAlias)->ED1_PROD,(cAlias)->ED1_QTDNCM))
         WorkED3->ED3_SALNCM := If(lM,AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,M->ED1_QTDNCM),AvTransUnid((cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX,(cAlias)->ED1_PROD,(cAlias)->ED1_QTDNCM))
      EndIf

      WorkED3->ED3_PERCAG := If(lM,M->ED1_PERCAG,(cAlias)->ED1_PERCAG)
      WorkED3->ED3_PESO   := If(lM,M->ED1_PESO,(cAlias)->ED1_PESO)
      WorkED3->TRB_ALI_WT := "ED3"
      WorkED3->TRB_REC_WT := 0
      WorkED3->(msUnlock())
   EndIf
Else
   WorkED3->(dbSeek(cChaveED3))

   WorkED3->ED3_QTD -= If(lM,M->ED1_QTD,(cAlias)->ED1_QTD)
   If WorkED3->ED3_QTD = 0
      aAdd(aDelWkED3,WorkED3->ED3_RECNO)
      WorkED3->(RecLock("WorkED3",.F.,.T.))
      WorkED3->(DBDELETE())
      WorkED3->(msUnlock())
//    If( Empty(Alltrim(M->ED0_AC)) , OrganizaSeqSis("WorkED3") ,) ALS - 06/12/2007
      If( Empty(Alltrim(M->ED0_AC)) .and. if( EasyGParam("MV_EDC0005",,.F.), Empty(Alltrim(M->ED0_DT_ENV)), .T.)  , OrganizaSeqSis("WorkED3") ,) //ALS 06/12/2007
   Else
      WorkED3->ED3_SALDO  -= If(lM,M->ED1_QTD,(cAlias)->ED1_QTD)
      WorkED3->ED3_VAL_EM -= If(lM,M->ED1_VAL_EM,(cAlias)->ED1_VAL_EM)
      WorkED3->ED3_VAL_SE -= If(lM,M->ED1_VAL_SE,(cAlias)->ED1_VAL_SE)
      WorkED3->ED3_SAL_SE -= If(lM,M->ED1_VAL_SE,(cAlias)->ED1_VAL_SE)
      WorkED3->ED3_VALCOM -= If(lM,M->ED1_VALCOM,nValCom)
      WorkED3->ED3_VAL_CO -= If(lM,M->ED1_VAL_EM-M->ED1_VALCOM,(cAlias)->ED1_VAL_EM-nValCom)
      WorkED3->ED3_SAL_CO -= If(lM,M->ED1_VAL_EM-M->ED1_VALCOM,(cAlias)->ED1_VAL_EM-nValCom)

     If (lM .and. iif(lED1Umanex,Empty(M->ED1_UMANEX),.t.)) .or.;   // ACSJ - 17/11/2004
         (!lM .and. iif(lED1Umanex,Empty((cAlias)->ED1_UMANEX),.t.)) // ACSJ - 17/11/2004
         WorkED3->ED3_QTDNCM -= If(lM,M->ED1_QTDNCM,(cAlias)->ED1_QTDNCM)
         WorkED3->ED3_SALNCM -= If(lM,M->ED1_QTDNCM,(cAlias)->ED1_QTDNCM)
      Else  // ACSJ - So Entra na condicao abaixo se o campo ED1_Umanex Existir. - 17/11/2004
         WorkED3->ED3_QTDNCM -= If(lM,AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,M->ED1_QTDNCM),AvTransUnid((cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX,(cAlias)->ED1_PROD,(cAlias)->ED1_QTDNCM))
         WorkED3->ED3_SALNCM -= If(lM,AvTransUnid(M->ED1_UMNCM,M->ED1_UMANEX,M->ED1_PROD,M->ED1_QTDNCM),AvTransUnid((cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX,(cAlias)->ED1_PROD,(cAlias)->ED1_QTDNCM))
      EndIf
      WorkED3->ED3_PESO   -= If(lM,M->ED1_PESO,(cAlias)->ED1_PESO)
   EndIf
EndIf

//AAF 01/06/2006 - Ponto de entrada na gravação do WorkED3.
If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"WorkED3Atu"),)

WorkED3->(dbSetOrder(nOldOrd))
//WorkED3->(dbGoTop())

Return .T.
*--------------------------------------------------------------------------------------------------------------*
Static Function WorkED4Atu(cAliasAux,nTipo,aAtuCpos,lMarca,lIsen,lValEst,lExcluiED4,lConsSldLI,lConsSldDI)
*--------------------------------------------------------------------------------------------------------------*
Local cSeqMi:=0,cSeqSis:=0, lM, nAtuQtdCal, nAtuValCal, i
Local nOldOrd:=WorkED4->(IndexOrd()), nValCal, nPos, bSeekED4 // NCF-16/11/2009
Local cImport := "" //AOM - 10/11/2011
Private nSalNCM1, nSalNCM2, nQtdCal, nQtdCalNCM, nQtdOldNCM
Private lMem, nTp:=nTipo, lIsenAux:=lIsen, cAlias:=cAliasAux
lM    :=If(cAlias=="M",.T.,.F.)
lMarca:=If(lMarca<>NIL, lMarca , .F.)
lIsen :=If(lIsen<>NIL, lIsen , .F.)
lValEst:=If(lValEst<>NIL, lValEst , .F.)
lExcluiED4 := IIF(lExcluiED4<>NIL, lExcluiED4, .T.)  // PLB 05/03/07 - Caso .F. permite saldo negativo e não exclui ED4
lConsSldLI := IIF(lConsSldLI<>NIL, lConsSldLI, .T.)  // PLB 22/05/07 - Caso .F. não considera Valor nos Saldo da LI
lConsSldDI := IIF(lConsSldDI<>NIL, lConsSldDI, .T.)  // PLB 22/05/07 - Caso .F. não considera Valor nos Saldo da DI
lMem  :=lM

//AOM - 16/11/2011
If !Empty(WorkED4->(DBFilter()))
   WorkED4->(DBCLEARFILTER())
EndIf

//AOM - 10/11/2011
If AvFlags("SEQMI")
   cImport := &(cAlias+"->ED2_IMPORT")
EndIf

IF SubStr(cImport,1,1) == "'"
   cImport := SubStr(cImport,2,2)
EndiF

//NCF - Seta Ordens e define os Seeks conforme flag do campo ED0_PERCPE
IF !lQuebraPerc .OR. Empty(M->ED0_PERCPE) .OR. M->ED0_PERCPE == "1"
   WorkED4->(dbSetOrder(1))
   bSeekED4 := {||WorkED4->(dbSeek(If(lM,M->ED2_NCM+M->ED2_ITEM+M->ED2_CAMB+Str(M->ED2_PERCPE,5,2)+;
                  iif(lED2Umanex,If(Empty(M->ED2_UMANEX),M->ED2_UMNCM,M->ED2_UMANEX),M->ED2_UMNCM)+cImport,(cAlias)->ED2_NCM+(cAlias)->ED2_ITEM+(cAlias)->ED2_CAMB+Str((cAlias)->ED2_PERCPE,5,2)+;
                  iif(lED2Umanex,If(Empty((cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM,(cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM)+cImport)))}
Else
   WorkED4->(dbSetOrder(5))
   bSeekED4 := {||WorkED4->(dbSeek(If(lM,M->ED2_NCM+M->ED2_ITEM+M->ED2_CAMB+;
                  iif(lED2Umanex,If(Empty(M->ED2_UMANEX),M->ED2_UMNCM,M->ED2_UMANEX),M->ED2_UMNCM)+cImport,(cAlias)->ED2_NCM+(cAlias)->ED2_ITEM+(cAlias)->ED2_CAMB+;
                  iif(lED2Umanex,If(Empty((cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM,(cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM)+cImport)))}
EndIf
//WorkED4->(dbSetOrder(1))

If lM // ACSJ - 17/11/2004
    if lED2Umanex .AND. ! Empty(M->ED2_UMANEX)
    
//      If SB1->( DbSetOrder(1), DbSeek(xFilial("SB1")+M->ED2_ITEM)) .And. SB1->B1_PESO <> 0 .And. AvVldUn(M->ED2_UMANEX) .And. Alltrim(SB1->B1_UM) == Alltrim(M->ED2_UMITEM)
//        nSalNCM1 := SB1->B1_PESO * M->ED2_QTDCAL
//      Else
        nSalNCM1 := AVTransUnid(M->ED2_UMITEM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDCAL)
//      EndIf
    
      If nTipo<>INCLUIR
//        If SB1->( DbSetOrder(1), DbSeek(xFilial("SB1")+WorkED2->ED2_ITEM)) .And. SB1->B1_PESO <> 0 .And. AvVldUn(WorkED2->ED2_UMANEX) .And. Alltrim(SB1->B1_UM) == Alltrim(WorkED2->ED2_UMITEM)
//          nSalNCM2 := SB1->B1_PESO * WorkED2->ED2_QTDCAL
//        Else
          nSalNCM2 := AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDCAL)
//        EndIf
      EndIf
      
    Else   // ACSJ - 17/11/2004
//      If SB1->( DbSetOrder(1), DbSeek(xFilial("SB1")+M->ED2_ITEM)) .And. SB1->B1_PESO <> 0 .And. AvVldUn(M->ED2_UMNCM) .And. Alltrim(SB1->B1_UM) == Alltrim(M->ED2_UMITEM)
//        nSalNCM1 := SB1->B1_PESO * M->ED2_QTDCAL
//      Else
        nSalNCM1 := AVTransUnid(M->ED2_UMITEM,M->ED2_UMNCM,M->ED2_ITEM,M->ED2_QTDCAL)
//      EndIf

      If nTipo<>INCLUIR
//        If SB1->( DbSetOrder(1), DbSeek(xFilial("SB1")+WorkED2->ED2_ITEM)) .And. SB1->B1_PESO <> 0 .And. AvVldUn(WorkED2->ED2_UMNCM) .And. Alltrim(SB1->B1_UM) == Alltrim(WorkED2->ED2_UMITEM)
//          nSalNCM2 := SB1->B1_PESO * WorkED2->ED2_QTDCAL
//        Else
          nSalNCM2 := AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMNCM,WorkED2->ED2_ITEM,WorkED2->ED2_QTDCAL)
//        EndIf
      EndIf
    Endif
Else
    if lED2Umanex .and. ! Empty((cAlias)->ED2_UMANEX)
//      If SB1->( DbSetOrder(1), DbSeek(xFilial("SB1")+WorkED2->ED2_ITEM)) .And. SB1->B1_PESO <> 0 .And. AvVldUn(WorkED2->ED2_UMANEX) .And. Alltrim(SB1->B1_UM) == Alltrim(WorkED2->ED2_UMITEM)
//        nSalNCM1 := SB1->B1_PESO * WorkED2->ED2_QTDCAL
//      Else
        nSalNCM1 := AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDCAL)
//      EndIf
    Else
//      If SB1->( DbSetOrder(1), DbSeek(xFilial("SB1")+WorkED2->ED2_ITEM)) .And. SB1->B1_PESO <> 0 .And. AvVldUn(WorkED2->ED2_UMNCM) .And. Alltrim(SB1->B1_UM) == Alltrim(WorkED2->ED2_UMITEM)
//        nSalNCM1 := SB1->B1_PESO * WorkED2->ED2_QTDCAL
//      Else
        nSalNCM1 := AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMNCM,WorkED2->ED2_ITEM,WorkED2->ED2_QTDCAL)
//      EndIf
    Endif

   If (cAlias)->ED2_PERCPE > (cAlias)->ED2_PERCAP
      nQtdCal := (cAlias)->ED2_QTD - (((cAlias)->ED2_PERCPE - (cAlias)->ED2_PERCAP) * (cAlias)->ED2_QTD)/100
      nValCal := (cAlias)->ED2_VALEMB - (((cAlias)->ED2_PERCPE - (cAlias)->ED2_PERCAP) * (cAlias)->ED2_VALEMB)/100
   Else
      nQtdCal := (cAlias)->ED2_QTD
      nValCal := (cAlias)->ED2_VALEMB
   EndIf

EndIf

If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"NSALDOS"),)

If nTipo<>ESTORNAR
/*
     If WorkED4->(dbSeek(If(lM,M->ED2_NCM+M->ED2_ITEM+M->ED2_CAMB+Str(M->ED2_PERCPE,5,2)+;
      iif(lED2Umanex,If(Empty(M->ED2_UMANEX),M->ED2_UMNCM,M->ED2_UMANEX),M->ED2_UMNCM),(cAlias)->ED2_NCM+(cAlias)->ED2_ITEM+(cAlias)->ED2_CAMB+Str((cAlias)->ED2_PERCPE,5,2)+;
      iif(lED2Umanex,If(Empty((cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM,(cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM))))
*/
   If Eval(bSeekED4)                     //NCF - 16/11/2009 - Executa o Seek
      WorkED4->(RecLock("WorkED4",.F.))
      If aAtuCpos <> NIL
         nQtdPE := Round(WorkED4->ED4_QTDCAL / WorkED4->ED4_QTD,2) //AAF 14/04/05

         For i:=1 to Len(aAtuCpos)
            WorkED4->&(aAtuCpos[i,1]) += aAtuCpos[i,2]
         Next

         // ** AAF 14/04/05 - Calculos corrigido com o percentual de perda - percentual aprovado.
         /*
         nAtuQtdCal := WorkED4->ED4_QTDCAL
         WorkED4->ED4_QTDCAL += (WorkED4->ED4_QTD - (WorkED4->ED4_PERCPE * WorkED4->ED4_QTD / 100)) - WorkED4->ED4_QTDCAL
         WorkED4->ED4_QT_LI  += (WorkED4->ED4_QTD - (WorkED4->ED4_PERCPE * WorkED4->ED4_QTD / 100)) - nAtuQtdCal
         WorkED4->ED4_QT_DI  += (WorkED4->ED4_QTD - (WorkED4->ED4_PERCPE * WorkED4->ED4_QTD / 100)) - nAtuQtdCal
         WorkED4->ED4_SNCMLI += (WorkED4->ED4_QTDNCM - (WorkED4->ED4_PERCPE * WorkED4->ED4_QTD / 100)) - AVTransUnid(SB1->B1_UM,SYD->YD_UNID,WorkED2->ED2_ITEM,nAtuQtdCal)
         WorkED4->ED4_SNCMDI += (WorkED4->ED4_QTDNCM - (WorkED4->ED4_PERCPE * WorkED4->ED4_QTD / 100)) - AVTransUnid(SB1->B1_UM,SYD->YD_UNID,WorkED2->ED2_ITEM,nAtuQtdCal)
         nAtuValCal := WorkED4->ED4_VALCAL
         WorkED4->ED4_VALCAL += (WorkED4->ED4_VALEMB - (WorkED4->ED4_PERCPE * WorkED4->ED4_VALEMB / 100)) - WorkED4->ED4_VALCAL
         WorkED4->ED4_VL_LI  += (WorkED4->ED4_VALEMB  - (WorkED4->ED4_PERCPE * WorkED4->ED4_VALEMB / 100)) - nAtuValCal
         WorkED4->ED4_VL_DI  += (WorkED4->ED4_VALEMB  - (WorkED4->ED4_PERCPE * WorkED4->ED4_VALEMB / 100)) - nAtuValCal
         */
         //Guarda Valores Anteriores
         nAtuValCal := WorkED4->ED4_VALCAL
         nAtuQtdCal := WorkED4->ED4_QTDCAL

         //Atualiza Quantidade Calculada e Valor Calculado
         WorkED4->ED4_QTDCAL := Round(nQtdPE * WorkED4->ED4_QTD   ,AVSX3("ED4_QTDCAL",4))
         WorkED4->ED4_VALCAL := Round(nQtdPE * WorkED4->ED4_VALEMB,AVSX3("ED4_VALCAL",4))

         //Atualiza Saldo Quantidade na LI e DI
         WorkED4->ED4_QT_LI  += Round(WorkED4->ED4_QTDCAL - nAtuQtdCal,AVSX3("ED4_QT_LI",4))
         WorkED4->ED4_QT_DI  += Round(WorkED4->ED4_QTDCAL - nAtuQtdCal,AVSX3("ED4_QT_DI",4))

         //Atualiza Saldo Valor na LI e DI
         If lConsSldLI
            WorkED4->ED4_VL_LI  += Round(WorkED4->ED4_VALCAL - nAtuValCal,AVSX3("ED4_VL_LI",4))
         EndIf
         If lConsSldDI
            WorkED4->ED4_VL_DI  += Round(WorkED4->ED4_VALCAL - nAtuValCal,AVSX3("ED4_VL_DI",4))
         EndIf

         //Atualiza Saldo NCM na LI e DI
         //AAF 12/07/05 - Deduz o percentual de Perda.
         WorkED4->ED4_SNCMLI += Round((nQtdPE * WorkED4->ED4_QTDNCM) - AVTransUnid(SB1->B1_UM,SYD->YD_UNID,WorkED2->ED2_ITEM,nAtuQtdCal),AVSX3("ED4_SNCMLI",4))
         WorkED4->ED4_SNCMDI += Round((nQtdPE * WorkED4->ED4_QTDNCM) - AVTransUnid(SB1->B1_UM,SYD->YD_UNID,WorkED2->ED2_ITEM,nAtuQtdCal),AVSX3("ED4_SNCMDI",4))

         // ** AAF 14/04/05

      ElseIf lM .and. nTipo<>INCLUIR
         If WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP
            nQtdCal := WorkED2->ED2_QTD - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTD)/100
            nValCal := WorkED2->ED2_VALEMB - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_VALEMB)/100
         Else
            nQtdCal := WorkED2->ED2_QTD
            nValCal := WorkED2->ED2_VALEMB
         EndIf

         //NCF/TRP - 17/11/2009
         If lQuebraPerc .AND. ED0->ED0_PERCPE == "2"
            //WorkED4->ED4_PERCPE := (WORKED4->ED4_PERCPE * (WorkED4->ED4_QTD) - WorkED2->ED2_QTD*WorkED2->ED2_PERCPE + M->ED2_QTD*M->ED2_PERCPE)/(WorkED4->ED4_QTD - WorkED2->ED2_QTD + M->ED2_QTD) //Recalculo
            WorkED4->ED4_PERCPE := CalcPPMedio(nTipo,lM)
         Endif

         WorkED4->ED4_QTD    += M->ED2_QTD    - WorkED2->ED2_QTD
         WorkED4->ED4_VALEMB += M->ED2_VALEMB - WorkED2->ED2_VALEMB
         WorkED4->ED4_QTDCAL += M->ED2_QTDCAL - nQtdCal
         WorkED4->ED4_VALCAL += M->ED2_VALCAL - nValCal
         WorkED4->ED4_QT_LI  += M->ED2_QTDCAL - nQtdCal
         If lConsSldLI
            WorkED4->ED4_VL_LI  += M->ED2_VALCAL - nValCal
         EndIf
         WorkED4->ED4_QT_DI  += M->ED2_QTDCAL - nQtdCal
         If lConsSldDI
            WorkED4->ED4_VL_DI  += M->ED2_VALCAL - nValCal
         EndIf
         if lED2Umanex  // ACSJ - 17/11/2004
            if Empty(ED2->ED2_UMANEX)
               lUmanex2Vazio := .t.
            Else
               lUmanex2Vazio := .f.
            Endif
         Else
            lUmanex2Vazio := .t.
         Endif

         If lUmanex2Vazio  // ACSJ - 17/11/2004
            WorkED4->ED4_QTDNCM += M->ED2_QTDNCM - WorkED2->ED2_QTDNCM
            If lIsen .or. AvVldUn( M->ED2_UMNCM ) // MPG - 14/02/2018
               If WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP
                  nQtdOldNCM := WorkED2->ED2_QTDNCM - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTDNCM)/100
               Else
                  nQtdOldNCM := WorkED2->ED2_QTDNCM
               EndIf
               If M->ED2_PERCPE > M->ED2_PERCAP
                  nQtdCalNCM := M->ED2_QTDNCM - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTDNCM)/100
               Else
                  nQtdCalNCM := M->ED2_QTDNCM
               EndIf
               WorkED4->ED4_SNCMLI += nQtdCalNCM - nQtdOldNCM
               WorkED4->ED4_SNCMDI += nQtdCalNCM - nQtdOldNCM
            Else
               WorkED4->ED4_SNCMLI += nSalNCM1 - nSalNCM2
               WorkED4->ED4_SNCMDI += nSalNCM1 - nSalNCM2
            EndIf
         Else  // ACSJ - Não verifico o campo Umanex abaixo pois so entrara nesta condicao e o campo existir - 17/11/2004
            WorkED4->ED4_QTDNCM += AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM) - AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM)
            If lIsen .or. AvVldUn( M->ED2_UMANEX ) // MPG - 14/02/2018
               If WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP
                  nQtdOldNCM := AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM) - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM))/100
               Else
                  nQtdOldNCM := AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM)
               EndIf
               If M->ED2_PERCPE > M->ED2_PERCAP
                  nQtdCalNCM := AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM) - ((M->ED2_PERCPE - M->ED2_PERCAP) * AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM))/100
               Else
                  nQtdCalNCM := AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM)
               EndIf
               WorkED4->ED4_SNCMLI += nQtdCalNCM - nQtdOldNCM
               WorkED4->ED4_SNCMDI += nQtdCalNCM - nQtdOldNCM
            Else
               WorkED4->ED4_SNCMLI += nSalNCM1 - nSalNCM2
               WorkED4->ED4_SNCMDI += nSalNCM1 - nSalNCM2
            EndIf
            If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"NQTD1"),)
         EndIf
         WorkED4->ED4_PESO   += M->ED2_PESO - WorkED2->ED2_PESO
      Else
         WorkED4->ED4_QTD    += If(lM,M->ED2_QTD,(cAlias)->ED2_QTD)
         WorkED4->ED4_VALEMB += If(lM,M->ED2_VALEMB,(cAlias)->ED2_VALEMB)
         WorkED4->ED4_QTDCAL += If(lM,M->ED2_QTDCAL,nQtdCal)
         WorkED4->ED4_VALCAL += If(lM,M->ED2_VALCAL,nValCal)
         WorkED4->ED4_QT_LI  += If(lM,M->ED2_QTDCAL,nQtdCal)

         //NCF-16/11/09 - Calculo do percentual de perca
         //WorkED4->ED4_PERCPE := (WORKED4->ED4_PERCPE * (WorkED4->ED4_QTD - If(lM,M->ED2_QTD,(cAlias)->ED2_QTD)) + If(lM,M->ED2_QTD * M->ED2_PERCPE,(cAlias)->ED2_QTD * (cAlias)->ED2_PERCPE))/WorkED4->ED4_QTD
         WorkED4->ED4_PERCPE := CalcPPMedio(nTipo,lM)
         If lConsSldLI
            WorkED4->ED4_VL_LI  += If(lM,M->ED2_VALCAL,nValCal)
         EndIf
         WorkED4->ED4_QT_DI  += If(lM,M->ED2_QTDCAL,nQtdCal)
         If lConsSldDI
            WorkED4->ED4_VL_DI  += If(lM,M->ED2_VALCAL,nValCal)
         EndIf
         If (lM .and. iif(lED2Umanex,Empty(M->ED2_UMANEX),.t.)) .or.;   // ACSJ - 17/11/2004
            (!lM .and. iif(lED2Umanex,Empty(WorkED2->ED2_UMANEX),.t.))  // ACSJ - 17/11/2004
            WorkED4->ED4_QTDNCM += If(lM,M->ED2_QTDNCM,(cAlias)->ED2_QTDNCM)


            If lIsen .or. (lM .and. AvVldUn( M->ED2_UMNCM ) ) .or.; // MPG - 14/02/2018
               (!lM .and. AvVldUn( WorkED2->ED2_UMNCM ) ) // MPG - 14/02/2018
               If (lM .and. M->ED2_PERCPE > M->ED2_PERCAP) .or. (!lM .and. WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP)
                  If lM
                     nQtdCalNCM := M->ED2_QTDNCM - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTDNCM)/100
                  Else
                     nQtdCalNCM := WorkED2->ED2_QTDNCM - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTDNCM)/100
                  EndIf
               Else
                  If lM
                     nQtdCalNCM := M->ED2_QTDNCM
                  Else
                     nQtdCalNCM := WorkED2->ED2_QTDNCM
                  EndIf
               EndIf
               WorkED4->ED4_SNCMLI += nQtdCalNCM
               WorkED4->ED4_SNCMDI += nQtdCalNCM
            Else
               WorkED4->ED4_SNCMLI += nSalNCM1
               WorkED4->ED4_SNCMDI += nSalNCM1
            EndIf
         Else
            WorkED4->ED4_QTDNCM += If(lM,AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM),AVTransUnid((cAlias)->ED2_UMNCM,(cAlias)->ED2_UMANEX,(cAlias)->ED2_ITEM,(cAlias)->ED2_QTDNCM))
            If lIsen .or. (lM .and. AvVldUn( M->ED2_UMANEX ) ) .or.; // MPG - 14/02/2018
            (!lM .and. AvVldUn( WorkED2->ED2_UMANEX ) ) // MPG - 14/02/2018
               If (lM .and. M->ED2_PERCPE > M->ED2_PERCAP) .or. (!lM .and. WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP)
                  If lM
                     nQtdCalNCM := AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM) - ((M->ED2_PERCPE - M->ED2_PERCAP) * AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM))/100
                  Else
                     nQtdCalNCM := AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM) - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM))/100
                  EndIf
               Else
                  If lM
                     nQtdCalNCM := AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM)
                  Else
                     nQtdCalNCM := AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM)
                  EndIf
               EndIf
               WorkED4->ED4_SNCMLI += nQtdCalNCM
               WorkED4->ED4_SNCMDI += nQtdCalNCM
            Else
               WorkED4->ED4_SNCMLI += nSalNCM1
               WorkED4->ED4_SNCMDI += nSalNCM1
            EndIf
            If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"NQTD2"),)
         EndIf
         WorkED4->ED4_PESO   += If(lM,M->ED2_PESO,(cAlias)->ED2_PESO)
      EndIf
      WorkED4->(msUnlock())
   Else
      //AOM 20/06/12
      If AvFlags("SEQMI") .And. If(lM,M->ED2_IMPORT,WorkED2->ED2_IMPORT) == "N"
         cSeqMi  := BuscaSeqSis("WorkED4",.T.)
      Else
         cSeqSis := BuscaSeqSis("WorkED4")
      EndIf
      WorkED4->(RecLock("WorkED4",.T.))
      WorkED4->ED4_ITEM   := If(lM,M->ED2_ITEM,(cAlias)->ED2_ITEM)
      WorkED4->ED4_DESCIT := Posicione("SB1",1,xFilial("SB1"/*"ED4"*/)+WorkED4->ED4_ITEM ,"B1_DESC") // AOM - 26/05/2010    // GFP - 30/08/2012
      WorkED4->ED4_NCM    := If(lM,M->ED2_NCM,(cAlias)->ED2_NCM)
      WorkED4->ED4_QTD    := If(lM,M->ED2_QTD,(cAlias)->ED2_QTD)
      WorkED4->ED4_UMITEM := If(lM,M->ED2_UMITEM,(cAlias)->ED2_UMITEM)
      WorkED4->ED4_VALEMB := If(lM,M->ED2_VALEMB,(cAlias)->ED2_VALEMB)
      //If M->ED0_MODAL == "2"
      //   WorkED4->ED4_PERCPE := 0
      //Else
         WorkED4->ED4_PERCPE := If(lM,M->ED2_PERCPE,(cAlias)->ED2_PERCPE)
      //EndIf
      WorkED4->ED4_QTDCAL := If(lM,M->ED2_QTDCAL,nQtdCal)
      WorkED4->ED4_VALCAL := If(lM,M->ED2_VALCAL,nValCal)
      WorkED4->ED4_QT_LI  := If(lM,M->ED2_QTDCAL,nQtdCal)
      If lConsSldLI
         WorkED4->ED4_VL_LI  := If(lM,M->ED2_VALCAL,nValCal)
      EndIf
      WorkED4->ED4_QT_DI  := If(lM,M->ED2_QTDCAL,nQtdCal)
      If lConsSldDI
         WorkED4->ED4_VL_DI  := If(lM,M->ED2_VALCAL,nValCal)
      EndIf
      WorkED4->ED4_CAMB   := If(lM,M->ED2_CAMB,(cAlias)->ED2_CAMB)
      WorkED4->ED4_UMNCM  := If(lM,iif(lED2Umanex,If(Empty(M->ED2_UMANEX),M->ED2_UMNCM,M->ED2_UMANEX),M->ED2_UMNCM),iif(lED2Umanex,If(Empty((cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM,(cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM)) // ACSJ - 17/11/2004
      WorkED4->TRB_ALI_WT := "ED4"
      WorkED4->TRB_REC_WT := 0

      If (lM .and. iif(lED2Umanex,Empty(M->ED2_UMANEX),.t.)) .or.;   // ACSJ - 17/11/2004
         (!lM .and. iif(lED2Umanex,Empty(WorkED2->ED2_UMANEX),.t.))  // ACSJ - 17/11/2004
         WorkED4->ED4_QTDNCM := If(lM,M->ED2_QTDNCM,(cAlias)->ED2_QTDNCM)
         If lIsen .or. (lM .and. AvVldUn( M->ED2_UMNCM ) ) .or.; // MPG - 14/02/2018
         (!lM .and. AvVldUn( WorkED2->ED2_UMNCM ) ) // MPG - 14/02/2018
            If (lM .and. M->ED2_PERCPE > M->ED2_PERCAP) .or. (!lM .and. WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP)
               If lM
                  nQtdCalNCM := M->ED2_QTDNCM - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTDNCM)/100
               Else
                  nQtdCalNCM := WorkED2->ED2_QTDNCM - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTDNCM)/100
               EndIf
            Else
               If lM
                  nQtdCalNCM := M->ED2_QTDNCM
               Else
                  nQtdCalNCM := WorkED2->ED2_QTDNCM
               EndIf
            EndIf
            WorkED4->ED4_SNCMLI := nQtdCalNCM
            WorkED4->ED4_SNCMDI := nQtdCalNCM
         Else
            WorkED4->ED4_SNCMLI := nSalNCM1
            WorkED4->ED4_SNCMDI := nSalNCM1
         EndIf
      Else
         WorkED4->ED4_QTDNCM := If(lM,AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM),AVTransUnid((cAlias)->ED2_UMNCM,(cAlias)->ED2_UMANEX,(cAlias)->ED2_ITEM,(cAlias)->ED2_QTDNCM))
         If lIsen .or. (lM .and. AvVldUn( M->ED2_UMANEX ) ) .or.; // MPG - 14/02/2018
         (!lM .and. AvVldUn( WorkED2->ED2_UMANEX ) ) // MPG - 14/02/2018
            If (lM .and. M->ED2_PERCPE > M->ED2_PERCAP) .or. (!lM .and. WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP)
               If lM
                  nQtdCalNCM := AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM) - ((M->ED2_PERCPE - M->ED2_PERCAP) * AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM))/100
               Else
                  nQtdCalNCM := AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM) - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM))/100
               EndIf
            Else
               If lM
                  nQtdCalNCM := AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM)
               Else
                  nQtdCalNCM := AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM)
               EndIf
            EndIf
            WorkED4->ED4_SNCMLI := nQtdCalNCM
            WorkED4->ED4_SNCMDI := nQtdCalNCM
         Else
            WorkED4->ED4_SNCMLI := nSalNCM1
            WorkED4->ED4_SNCMDI := nSalNCM1
         EndIf
         If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"NQTD3"),)
      EndIf
      WorkED4->ED4_PESO   := If(lM,M->ED2_PESO,(cAlias)->ED2_PESO)
      If lValEst
         //AOM 11/11/11
         If AvFlags("SEQMI") .And. If(lM,M->ED2_IMPORT,(cAlias)->ED2_IMPORT) == "N"
            cSeqMi := cSeqMiAux
         Else
            cSeqSis := cSeq4Aux
         EndIf
         If nValCalEst <> WorkED4->ED4_VALCAL
            If lConsSldLI
               WorkED4->ED4_VL_LI  := (nValLiEst / nValCalEst) * WorkED4->ED4_VALCAL
            EndIf
            If lConsSldDI
               WorkED4->ED4_VL_DI  := (nValDiEst / nValCalEst) * WorkED4->ED4_VALCAL
            EndIf
         Else
            If lConsSldLI
               WorkED4->ED4_VL_LI  := nValLiEst
            EndIf
            If lConsSldDI
               WorkED4->ED4_VL_DI  := nValDiEst
            EndIf
         EndIf
         If nQtdCalEst <> WorkED4->ED4_QTDCAL
            WorkED4->ED4_QT_LI  := nQtdLiEst / nQtdCalEst * WorkED4->ED4_QTDCAL
            WorkED4->ED4_QT_DI  := nQtdDiEst / nQtdCalEst * WorkED4->ED4_QTDCAL
         Else
            WorkED4->ED4_QT_LI  := nQtdLiEst
            WorkED4->ED4_QT_DI  := nQtdDiEst
         EndIf
         If nQtNcmEst <> (WorkED4->ED4_QTDNCM - (M->ED2_QTDNCM * (Max(M->ED2_PERCPE - M->ED2_PERCAP,0))) /100) //AAF 14/04/05 - Verifica se Percentual de Aprovado é maior que de Perda.
            If nQtdLiEst = nsNcmLiEst
               WorkED4->ED4_SNCMLI := WorkED4->ED4_QT_LI
               WorkED4->ED4_SNCMDI := WorkED4->ED4_QT_DI
            Else
               WorkED4->ED4_SNCMLI := (nSNcmLiEst / nQtNcmEst) * (WorkED4->ED4_QTDNCM - (M->ED2_QTDNCM * Max(M->ED2_PERCPE - M->ED2_PERCAP,0) /100))
               WorkED4->ED4_SNCMDI := (nSNcmDiEst / nQtNcmEst) * (WorkED4->ED4_QTDNCM - (M->ED2_QTDNCM * Max(M->ED2_PERCPE - M->ED2_PERCAP,0) /100))
            EndIf
         Else
            WorkED4->ED4_SNCMLI := nSNcmLiEst
            WorkED4->ED4_SNCMDI := nSNcmDiEst
         EndIf
      EndIf
      If !Empty(WorkED2->ED2_SEQSIS)
      //   WorkED4->ED4_SEQSIS := WorkED2->ED2_SEQSIS
         WorkED2->ED2_SEQSIS := ""
      //Else
      EndIf

      //AOM - 11/11/11
      If AvFlags("SEQMI") .And. !Empty(WorkED2->ED2_SEQMI)
         WorkED2->ED2_SEQMI := ""
      EndIf

      //AOM - 11/11/11
      If AvFlags("SEQMI")
         WorkED4->ED4_IMPORT := WorkED2->ED2_IMPORT
      EndIf

      //AOM - 20/06/12
      If AvFlags("SEQMI")
         If If(lM,M->ED2_IMPORT,(cAlias)->ED2_IMPORT) == "N"
            WorkED4->ED4_SEQMI := cSeqMi
            WorkED4->ED4_IMPORT := "N"
         Else
            WorkED4->ED4_SEQSIS := cSeqSis
            WorkED4->ED4_IMPORT := "S"
         EndIf
      Else
         WorkED4->ED4_SEQSIS := cSeqSis
      EndIf

      WorkED4->(msUnlock())
   EndIf
Else
/*
   If WorkED4->(dbSeek(If(lM,M->ED2_NCM+M->ED2_ITEM+M->ED2_CAMB+Str(M->ED2_PERCPE,5,2)+;
      iif(lED2Umanex,If(Empty(M->ED2_UMANEX),M->ED2_UMNCM,M->ED2_UMANEX),M->ED2_UMNCM),(cAlias)->ED2_NCM+(cAlias)->ED2_ITEM+(cAlias)->ED2_CAMB+Str((cAlias)->ED2_PERCPE,5,2)+;
      iif(lED2Umanex,If(Empty((cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM,(cAlias)->ED2_UMANEX),(cAlias)->ED2_UMNCM)))) // ACSJ - 17/11/2004
*/
   If Eval(bSeekED4)                                                   //NCF - 16/11/2009 - Executa o Seek
      WorkED4->ED4_VALEMB -= If(lM,M->ED2_VALEMB,(cAlias)->ED2_VALEMB)
      WorkED4->ED4_QTD    -= If(lM,M->ED2_QTD,(cAlias)->ED2_QTD)
      // NCF - 17/11/2009 - Recalcula o percentual de perda
      //WorkED4->ED4_PERCPE := (WORKED4->ED4_PERCPE * (WorkED4->ED4_QTD + If(lM,M->ED2_QTD,(cAlias)->ED2_QTD)) - If(lM,M->ED2_QTD * M->ED2_PERCPE,(cAlias)->ED2_QTD * (cAlias)->ED2_PERCPE))/WorkED4->ED4_QTD
      WorkED4->ED4_PERCPE := CalcPPMedio(nTipo,lM)

      If lExcluiED4  .And.  (((M->ED0_TIPOAC<>GENERICO .or. Alltrim(If(lM,M->ED2_NCM,(cAlias)->ED2_NCM))<>NCMGENERICA) .and. WorkED4->ED4_QTD<=0 ) .or.; //AAF 18/04/05 - Verifica se ED4_QTD ou ED4_VALEMB <= 0
      (M->ED0_TIPOAC==GENERICO .and. Alltrim(If(lM,M->ED2_NCM,(cAlias)->ED2_NCM))==NCMGENERICA .and. WorkED4->ED4_VALEMB<=0))
         aAdd(aDelWkED4,WorkED4->ED4_RECNO)
         //AOM 11/11/11
         If AvFlags("SEQMI") .And. If(lM,M->ED2_IMPORT,(cAlias)->ED2_IMPORT) == "N"
            cSeqMi :=  WorkED4->ED4_SEQMI
         Else
            cSeqSis := WorkED4->ED4_SEQSIS
         EndIf
         WorkED4->(RecLock("WorkED4",.F.,.T.))
         WorkED4->(DBDELETE())
         WorkED4->(msUnlock())
         //If Empty(Alltrim(M->ED0_AC)) ALS - 06/12/2007
         If Empty(Alltrim(M->ED0_AC)) .and. if( EasyGParam("MV_EDC0005",,.F.), Empty(Alltrim(M->ED0_DT_ENV)), .T.)  // ALS - 06/12/2007
            OrganizaSeqSis("WorkED4")
         ElseIf lMarca
            //AOM 11/11/11
            If AvFlags("SEQMI") .And. If(lM,M->ED2_IMPORT,(cAlias)->ED2_IMPORT) == "N"
               WorkED4->ED4_SEQMI := cSeqMi
            Else
               WorkED2->ED2_SEQSIS := cSeqSis
            EndIf
         EndIf
      Else
         If lValEst
            nQtdDiEst := nQtdLiEst := nSNcmLiEst := nSNcmDiEst := nValLiEst := nValDiEst := 0
            nQtdCalEst := nValCalEst := nQtNcmEst := 0
            If AvFlags("SEQMI")
               cSeqMiAux := ""
            EndIf
            cSeq4Aux := ""
         EndIf
         WorkED4->ED4_QTDCAL -= If(lM,M->ED2_QTDCAL,nQtdCal)
         WorkED4->ED4_VALCAL -= If(lM,M->ED2_VALCAL,nValCal)
         WorkED4->ED4_QT_LI  -= If(lM,M->ED2_QTDCAL,nQtdCal)
         If lConsSldLI
            WorkED4->ED4_VL_LI  -= If(lM,M->ED2_VALCAL,nValCal)
         EndIf
         WorkED4->ED4_QT_DI  -= If(lM,M->ED2_QTDCAL,nQtdCal)
         If lConsSldDI
            WorkED4->ED4_VL_DI  -= If(lM,M->ED2_VALCAL,nValCal)
         EndIf
         if lED2Umanex .and. .not. Empty( iif(lM,M->ED2_UMANEX,(cAlias)->ED2_UMANEX) )  // ACSJ - 17/11/2004
            WorkED4->ED4_QTDNCM -= If(lM,AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM),AVTransUnid((cAlias)->ED2_UMNCM,(cAlias)->ED2_UMANEX,(cAlias)->ED2_ITEM,(cAlias)->ED2_QTDNCM))
         Else
            WorkED4->ED4_QTDNCM -= If(lM,M->ED2_QTDNCM,(cAlias)->ED2_QTDNCM)  // ACSJ - 17/11/2004
         Endif

         If (lM .and. iif(lED2Umanex,Empty(M->ED2_UMANEX),.t.)) .or.;   // ACSJ - 17/11/2004
            (!lM .and. iif(lED2Umanex,Empty(WorkED2->ED2_UMANEX),.t.))  // ACSJ - 17/11/2004
            If lIsen .or. (lM .and. AvVldUn( M->ED2_UMNCM ) ) .or.; // MPG - 14/02/2018
            (!lM .and. AvVldUn( WorkED2->ED2_UMNCM ) ) // MPG - 14/02/2018
               If (lM .and. M->ED2_PERCPE > M->ED2_PERCAP) .or. (!lM .and. WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP)
                  If lM
                     nQtdCalNCM := M->ED2_QTDNCM - ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTDNCM)/100
                  Else
                     nQtdCalNCM := WorkED2->ED2_QTDNCM - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTDNCM)/100
                  Endif
               Else
                  If lM
                     nQtdCalNCM := M->ED2_QTDNCM
                  Else
                     nQtdCalNCM := WorkED2->ED2_QTDNCM
                  EndIf
               EndIf
               WorkED4->ED4_SNCMLI -= nQtdCalNCM
               WorkED4->ED4_SNCMDI -= nQtdCalNCM
            Else
               WorkED4->ED4_SNCMLI -= nSalNCM1
               WorkED4->ED4_SNCMDI -= nSalNCM1
            EndIf
         Else
            If lIsen .or. (lM .and. AvVldUn( M->ED2_UMANEX )) .or.; // MPG - 14/02/2018
            (!lM .and. AvVldUn( WorkED2->ED2_UMANEX ) ) // MPG - 14/02/2018
               If (lM .and. M->ED2_PERCPE > M->ED2_PERCAP) .or. (!lM .and. WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP)
                  If lM
                     nQtdCalNCM := AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM) - ((M->ED2_PERCPE - M->ED2_PERCAP) * AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM))/100
                  Else
                     nQtdCalNCM := AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM) - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM))/100
                  Endif
               Else
                  If lM
                     nQtdCalNCM := AVTransUnid(M->ED2_UMNCM,M->ED2_UMANEX,M->ED2_ITEM,M->ED2_QTDNCM)
                  Else
                     nQtdCalNCM := AVTransUnid(WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX,WorkED2->ED2_ITEM,WorkED2->ED2_QTDNCM)
                  EndIf
               EndIf
               WorkED4->ED4_SNCMLI -= nQtdCalNCM
               WorkED4->ED4_SNCMDI -= nQtdCalNCM
            Else
               WorkED4->ED4_SNCMLI -= nSalNCM1
               WorkED4->ED4_SNCMDI -= nSalNCM1
            EndIf
            If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"NQTD4"),)
         EndIf
         WorkED4->ED4_PESO   -= If(lM,M->ED2_PESO,(cAlias)->ED2_PESO)
      EndIf
   EndIf
EndIf

WorkED4->(dbSetOrder(nOldOrd))
//WorkED4->(dbGoTop())

Return .T.

/***
Revisão: nov/2018
inclusão do parâmetro cEstru, para receber a informação sobre qual estrutura os insumos serão atualizados na tabela EDC (resumo técnico);
inclusão do parâmetro nQtdExport, com a quantidade original (antes da alteração do compromisso de exportação) para atualização da tabela EDC (resumo técnico) 
 */
*------------------------------------------------------*
Static Function EstWorkED2(cProd,cSeq,lApaga,aRecDel, cEstru, nQtdExport)
*------------------------------------------------------*
Local aAltProd:= {}, nInd
Local nQtdEstru:= 0
Default aRecDel := {}
Default cEstru:= ""
Default nQtdExport:= 0

//AOM - 16/11/2011
If !Empty(WorkED2->(DBFilter()))
   WorkED2->(DBCLEARFILTER())
EndIf

If cSeq = NIL
   //AOM - 26/03/2012
   IF AVFLAGS("DI_ORIGINAL") .And. M->ED0_MODAL==ISENCAO
      If !VoltaSldDIAnt("WorkED2")
         Return
      EndIf
   EndIf
   aAdd(aDelWkED2,WorkED2->ED2_RECNO)
   If WorkED2->ED2_MARCA == cMarca
      WorkED4Atu("WorkED2",ESTORNAR,,,M->ED0_MODAL==ISENCAO)
      AC400Totais("WorkED2",ESTORNAR)
      AC400GrvEDA(ESTORNAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,0)
      AC400EDCGrv(ESTORNAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD,0)
   Else
      /* Quando o insumo for excluído do ato concessório, remover da estrutura do resumo técnico pois não fará
         parte da estrutura do produto a exportar do ato concessório.
         Para excluir, o item deve estar desmarcado; logo, a quantidade foi subtraída anteriormente. */
      AC400GrvEDA(ESTORNAR, WorkED2->ED2_ITEM, 0, WorkED2->ED2_QTDORI)
      AC400EDCGrv(ESTORNAR, WorkED2->ED2_ITEM, WorkED2->ED2_RE, WorkED2->ED2_PROD, 0, WorkED2->ED2_QTDORI)
   EndIf
   WorkED2->(RecLock("WorkED2",.F.,.T.))
   WorkED2->(DBDELETE())
   WorkED2->(MSUnlock())
Else
   ProcRegua(1)
   WorkED4->(dbSetOrder(1))
   WorkED2->(dbSetOrder(2))
   If WorkED2->(dbSeek(cProd+cSeq))
      Do While cProd==WorkED2->ED2_PROD .and. cSeq=WorkED2->ED2_SEQ

         If Len(aRecDel) > 0 .And. aScan(aRecDel, WorkED2->(Recno()) ) == 0
            WorkED2->(DbSkip())
            Loop
         EndIf

         If lApaga .and. VerED4Saldo("ESTORNO","WorkED2")
            //AOM - 26/03/2012
            IF AVFLAGS("DI_ORIGINAL") .And. M->ED0_MODAL==ISENCAO
               If !VoltaSldDIAnt("WorkED2")
                  Return
               EndIf
            EndIf
            aAdd(aDelWkED2, WorkED2->ED2_RECNO)
            If WorkED2->ED2_MARCA == cMarca
               WorkED4Atu("WorkED2",ESTORNAR,,,M->ED0_MODAL==ISENCAO)
               AC400Totais("WorkED2",ESTORNAR)

               /* se o estorno não foi realizado pela alteração do compromisso de exportação, mantém o tratamento original;
                  caso tenha sido, se o usuário optar por atualizar a partir da estutura existente no ato concessório ou do cadastro de estrutura,
                  serão estornados do Resumo Técnico (EDC) a quantidade atual do insumo e a quantidade original, com base na explosão do cadastro de estruturas. */
               If !Empty(cEstru)
                  nQtdEstru:= WorkED2->ED2_QTDORI
               EndIf
               AC400GrvEDA(ESTORNAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD, nQtdEstru)
               AC400EDCGrv(ESTORNAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD, nQtdEstru,, nQtdExport)
            EndIf
            WorkED2->(RecLock("WorkED2",.F.,.T.))
            WorkED2->(DBDELETE())
            WorkED2->(MSUnlock())
         Else
            aAdd(aAltProd,WorkED2->( RecNo() ))
         EndIf
         WorkED2->(dbSkip())
      EndDo

      // ** AAF 09/05/05 - Limpa o vinculo com produto estornado, já que o item não pode ser estornado.
      For nInd:= 1 To Len(aAltProd)
         WorkED2->( dbGoTo(aAltProd[nInd]) )

            If lAbriuEDC
               AC400EDCGrv(ESTORNAR,WorkED2->ED2_ITEM,Space(Len(WorkED1->ED1_RE)),WorkED2->ED2_PROD,WorkED2->ED2_QTD,0)
            EndIf
            //GFC - Fim
            WorkED2->(RecLock("WorkED2",.F.))
            WorkED2->ED2_SEQ  := ""
            WorkED2->ED2_PROD := ""
            WorkED2->ED2_DESCPD:= ""
            //GFC 20/08/04 - Inicio
            If lAbriuEDC
               AC400EDCGrv(INCLUIR,WorkED2->ED2_ITEM,Space(Len(WorkED1->ED1_RE)),WorkED2->ED2_PROD,WorkED2->ED2_QTD,0,WorkED2->ED2_MARCA)
            EndIf
      Next nInd
      // **
   EndIf
   WorkED2->(dbSetOrder(1))
   IncProc(STR0101) //"Excluindo Registros"
EndIf

//oMark5:oBrowse:Refresh()-- AOM - 27/10/10
oMark7:oBrowse:Refresh()

Return .T.

*----------------------------------*
Function BuscaCNPJ(cCodImp,lInteiro)
*----------------------------------*
Local cCNPJ, nOldSYTOrd:=SYT->(IndexOrd())
Local cOldArea:=Select()
Local hashChave := ""
lInteiro:=If(lInteiro<>NIL,lInteiro,.F.)

hashChave:= cCodImp

If !IsMemVar("oBufferCGC") .Or. oBufferCGC == Nil
   oBufferCGC:= tHashMap():New()
EndIf

If !oBufferCGC:Get(hashChave, @cCNPJ)

   SYT->(dbSetOrder(1))
   SYT->(dbSeek(xFilial("SYT")+cCodImp))
   If lInteiro
      cCNPJ := SYT->YT_CGC
   Else
      cCNPJ := Left(SYT->YT_CGC,8)
   EndIf
   SYT->(dbSetOrder(nOldSYTOrd))

   dbSelectArea(cOldArea)
   oBufferCGC:Set(hashChave, cCNPJ)

EndIf

Return cCNPJ

*-------------------------------------------*
Static Function BuscaSEQSIS(cAlias,lCompNac)
*-------------------------------------------*
Local cSeqSis, nOldArea:=Select()
Local cIniCampo, nOldRec:=(cAlias)->(RecNo())

Default lCompNac := .F.

If(cAlias=="WorkED3", cIniCampo := "ED3_", cIniCampo := "ED4_")

//AOM - 11/11/11
If cAlias=="WorkED4" .And. AvFlags("SEQMI") .And. lCompNac
   (cAlias)->(dbSetOrder(6))
   (cAlias)->(dbGoBottom())
Else
   (cAlias)->(dbSetOrder(2))
   (cAlias)->(dbGoBottom())
   lCompNac := .F.
EndIf

//ALS - 07/12/2007 - Alteração feita para manter sequencia do SEQSIS no caso de uso do Siscomex WEB
if EasyGParam("MV_EDC0005",,.F.) // Integração siscomex Web

   //AOM - 11/11/11
   If lCompNac

      if Empty(M->ED0_MIED4)
         cSeqSis := StrZero(Val((cAlias)->&(cIniCampo+"SEQMI")) + 1,4,0)
      else
         cSeqSis := StrZero(Val(M->ED0_MIED4) + 1,4,0)
      endif

      M->ED0_MIED4 := cSeqSis

   Else

      if Empty(M->&("ED0_SEQ"+Right(cAlias,3)))
         cSeqSis := StrZero(Val((cAlias)->&(cIniCampo+"SEQSIS")) + 1,3,0)
      else
         cSeqSis := StrZero(Val(M->&("ED0_SEQ"+Right(cAlias,3))) + 1,3,0)
      endif

      M->&("ED0_SEQ"+Right(cAlias,3)) := cSeqSis

   EndIf

   (cAlias)->(dbSetOrder(1))
   (cAlias)->(dbGoTo(nOldRec))
   dbSelectArea(nOldArea)

else

   //AOM - 11/11/11
   If lCompNac
     cSeqSis := StrZero(Val((cAlias)->&(cIniCampo+"SEQMI")) + 1,4,0)
   Else
     cSeqSis := StrZero(Val((cAlias)->&(cIniCampo+"SEQSIS")) + 1,3,0)
   EndIf

   (cAlias)->(dbSetOrder(1))
   (cAlias)->(dbGoTo(nOldRec))
   dbSelectArea(nOldArea)
endif

Return cSeqSis

*-------------------------------------*
Static Function AC400Marca(lTodos,lAtu)
*-------------------------------------*
Local lMens:=.T.
local lVlZero := .F.
lAtu:=If(lAtu<>NIL, lAtu , .T.)

If lTodos
   ProcRegua(WorkED2->(EasyRecCount()))
   WorkED2->(dbGoTop())
   If WorkED2->ED2_MARCA == cMarca
      Do While !WorkED2->(EOF())
         IncProc(STR0102 + Alltrim(WorkED2->ED2_ITEM)) //"Processando Item: "
         If VerED4Saldo("MARCA","WorkED2") .AND. WorkED2->ED2_MARCA == cMarca //AAF 09/05/05 - Verifica se o item está marcado.
            WorkED4Atu("WorkED2",ESTORNAR,,.T.)
            AC400Totais("WorkED2",ESTORNAR)
            AC400GrvEDA(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD*-1)
            AC400EDCGrv(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD*-1)
            WorkED2->ED2_MARCA := ""
         ElseIf lMens .and. WorkED2->ED2_MARCA == cMarca
            lMens:=.F.
            Help(" ",1,"AVG0005150") //"Um ou mais itens nao pode(m) ser Desmarcado(s) pois possui(em) Movimentacao."
         EndIf
         WorkED2->(dbSkip())
      EndDo
   Else
      Do While !WorkED2->(EOF())
         IncProc(STR0102 + Alltrim(WorkED2->ED2_ITEM)) //"Processando Item: "
         If WorkED2->ED2_MARCA <> cMarca
            If WorkED2->ED2_VALEMB > 0     //AAF 09/05/05 - Verifica se o Valor do Embarque é maior que zero.
               WorkED2->ED2_MARCA := cMarca
               If lAtu
                  AC400Totais("WorkED2",INCLUIR)
                  WorkED4Atu("WorkED2",INCLUIR)
               EndIf
               AC400GrvEDA(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD)
               AC400EDCGrv(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD)
            Else
               lVlZero := .T.
            EndIf
         EndIf
         WorkED2->(dbSkip())
      EndDo
      If lVlZero
         MsgInfo(STR0414 + chr(13) + chr(10)+ STR0415)//"Há Itens com o valor de embarque zerado!"Informe o valor para que os Itens sejam marcados"
      EndIf
   EndIf
   WorkED2->(dbGoTop())
Else
   If WorkED2->ED2_MARCA <> cMarca
      WorkED2->ED2_MARCA := cMarca
      If lAtu
         AC400Totais("WorkED2",INCLUIR)
         WorkED4Atu("WorkED2",INCLUIR)
      EndIf
      AC400GrvEDA(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD)
      AC400EDCGrv(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD)
   Else
      If !VerED4Saldo("MARCA","WorkED2")
         Help(" ",1,"AVG0005151") //"Item nao pode ser Desmarcado pois possui Movimentacao"
      Else
         AC400Totais("WorkED2",ESTORNAR)
         WorkED4Atu("WorkED2",ESTORNAR,,.T.)
         AC400GrvEDA(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD*-1)
         AC400EDCGrv(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD*-1)
         WorkED2->ED2_MARCA := ""
      EndIf
   EndIf
EndIf

//oMark5:oBrowse:Refresh()-- AOM - 27/10/10

if EasyGParam("MV_EDC0005",,.F.) // integração com Siscomex Web
   M->ED0_PTOTAL := AC401CalcPer() // ALS - 10/12/2007 Atualiza valor do campo virtal quando tiver atualização dos intens a importar
endif
Return .T.

*-------------------------------------------*
Static Function AtuWorkED2(nQuantExp,nValCob)
*-------------------------------------------*
Local cNcm
Local nDecQtd := AVSX3("ED2_QTD",4) //AAF 09/05/05 - Correção de Problemas em Arredondamento.

ProcRegua(WorkEstru->(EasyRecCount()))
WorkEstru->(dbGoTop())
Do While !WorkEstru->(EOF())
   IncProc(STR0105+WorkEstru->COMP) //"Gravando Item "
   If WorkEstru->QUANT > 0
      If cFilSB1 <> SB1->B1_FILIAL .or. WorkEstru->COMP <> SB1->B1_COD
         SB1->(dbSetOrder(1))
         SB1->(dbSeek(cFilSB1+WorkEstru->COMP))
      EndIf
      cNcm := SB1->B1_POSIPI

      // ** AAF 05/07/05 - Verifica se a NCM pode ser utilizada em Drawback.
      SYD->(dbSetOrder(1))
      SYD->(dbSeek(cFilSYD+SB1->( B1_POSIPI+B1_EX_NCM+B1_EX_NBM)))
      If SYD->( FieldPos("YD_PER_AC") ) > 0 .AND. SYD->YD_PER_AC == '2'
         WorkEstru->( dbSkip() )
         Loop
      Endif
      // **


      //AOM - 01/03/2012
      If AvFlags("SEQMI")

         If M->ED0_TIPINS == "2" .And. SB1->B1_IMPORT == "N"
            WorkEstru->(DbSkip())
            Loop
         ElseIf M->ED0_TIPINS == "3" .And. SB1->B1_IMPORT <> "N"
            WorkEstru->(DbSkip())
            Loop
         EndIf

      ElseIf SB1->B1_IMPORT == "N"
         WorkEstru->(DbSkip())
         Loop
      EndIf

      WorkED2->(RecLock("WorkED2",.T.))

      //AOM - 23/03/2012
      IF AVFLAGS("DI_ORIGINAL")
         WorkED2->ED2_SEQIT := RetUltSeqIt()
      ENDIF

      WorkED2->ED2_ITEM   := WorkEstru->COMP
      WorkED2->ED2_DESCIT := Posicione("SB1",1,xFilial("SB1"/*"ED2"*/)+WorkED2->ED2_ITEM,"B1_DESC")  //AOM - 26/05/2010     // GFP - 30/08/2012
      If M->ED0_TIPOAC <> GENERICO .or. Alltrim(WorkED2->ED2_NCM)<>NCMGENERICA
         WorkED2->ED2_QTD    := Round(WorkEstru->QUANT,nDecQtd)
         WorkED2->ED2_QTDCAL := Round(WorkEstru->QUANT - (WorkEstru->PERC * WorkEstru->QUANT)/100,nDecQtd) //AAF 11/04/05 - Quantidade Calculada subtraindo o percentual de perda.
         WorkED2->ED2_QTDORI := Round(WorkEstru->QUANT,nDecQtd)
         WorkED2->ED2_COEF   := Round(WorkEstru->QUANT / nQuantExp,nDecQtd)
      EndIf
      WorkED2->ED2_PROD   := WorkED1->ED1_PROD
      WorkED2->ED2_DESCPD := Posicione("SB1",1,xFilial("SB1"/*"ED2"*/)+WorkED2->ED2_PROD,"B1_DESC")  //AOM - 26/05/2010     // GFP - 30/08/2012
      WorkED2->ED2_SEQ    := WorkED1->ED1_SEQ
      WorkED2->ED2_PERCPE := WorkEstru->PERC
      WorkED2->TRB_ALI_WT := "ED2"
      WorkED2->TRB_REC_WT := 0
      // ** PLB 20/06/07 - Caso nao seja permitida a Dedução de Percentual de Perda, preenche o Percentual Aprovado
      If M->ED0_DEDUZP $ cNao
         WorkED2->ED2_PERCAP := WorkEstru->PERC
      EndIf
      // **

      //AAF 01/06/05 - Valor Comercial a Perda
      If lTemVLCOMPE
         WorkED2->ED2_VLCOPE := WorkEstru->VLCOMPE
      EndIf

      WorkED2->ED2_MARCA  := cMarca
      WorkED2->ED2_NCM    := cNcm
      WorkED2->ED2_CAMB   := If(nValCob>0,"1","2")

      WorkED2->ED2_UMNCM   := SYD->YD_UNID
      If SB1->(dbSeek(cFilSB1+WorkED2->ED2_ITEM))
         If ValValor("ED2_VALEMB","WorkED2")
            //WorkED2->ED2_VALEMB := WorkEstru->QUANT * SB1->B1_VLREFUS
            WorkED2->ED2_VALEMB := WorkED2->ED2_QTD * SB1->B1_VLREFUS
         EndIf
         WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB
         WorkED2->ED2_UMITEM := SB1->B1_UM
         If(WorkED2->ED2_VALEMB = 0 , WorkED2->ED2_MARCA := Space(Len(ED2->ED2_MARCA)) ,)
         If ValValor("ED2_PESO","WorkED2")
            WorkED2->ED2_PESO:= AC400Peso(WorkED2->ED2_UMITEM,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,SB1->B1_PESO)// TDF - 22/03/10
            //WorkED2->ED2_PESO   := SB1->B1_PESO * WorkED2->ED2_QTD
         EndIf
         If M->ED0_TIPOAC <> GENERICO .or. Alltrim(WorkED2->ED2_NCM)<>NCMGENERICA
            WorkED2->ED2_QTDNCM := AVTransUnid(SB1->B1_UM,SYD->YD_UNID,WorkED2->ED2_ITEM,WorkED2->ED2_QTD)
            // A. Caetano - ACSJ - 04/03/2004
            If SB1->B1_UM == SYD->YD_UNID
               WorkED2->ED2_COEFEC := 1
            Else
               WorkED2->ED2_COEFEC := iif( ( SJ5->(Eof()) .or. SJ5->(Bof()) ), 0, SJ5->J5_COEF )
            Endif
         EndIf

         //AOM - 10/11/2011
         If AvFlags("SEQMI")

            If SB1->B1_IMPORT <> "N" .Or. M->ED0_TIPINS == "0" //AOM - 08/02/2012
               WorkED2->ED2_IMPORT := "S"
            Else
               WorkED2->ED2_IMPORT := "N"
            EndIf

         EndIf
      EndIf

      WorkED2->ED2_PRCUNI := If(WorkED2->ED2_QTD>0, WorkED2->ED2_VALEMB / WorkED2->ED2_QTD, )
      WorkED2->(msUnlock())
      If WorkED2->ED2_MARCA == cMarca
         AC400Totais("WorkED2",INCLUIR)
         WorkED4Atu("WorkED2",INCLUIR)
      EndIf
      AC400GrvEDA(INCLUIR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,WorkEstru->QUANT,WorkED2->ED2_MARCA)
      AC400EDCGrv(INCLUIR,WorkED2->ED2_ITEM,WorkED1->ED1_RE,WorkED1->ED1_PROD,WorkED2->ED2_QTD,WorkEstru->QUANT,WorkED2->ED2_MARCA,WorkED1->ED1_QTD)
   EndIf
   WorkEstru->(dbSkip())
EndDo

WorkED2->(dbGoTop())

//oMark5:oBrowse:Refresh()- AOM - 27/10/10

Return .T.

*-----------------------------*
Static Function AC400CNPJ(nOpc)
*-----------------------------*
//cLin := 24  ASK 04/06/2007 - Ajustes para o Protheus 10
cLin := 30

@cLin,2 SAY AVSX3("ED0_CNPJ1",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ1 PICTURE AVSX3("ED0_CNPJ1",6) Valid (Empty(M->ED0_CNPJ1) .or. (AC400Valid("ED0_CNPJ1") .and. CGC(M->ED0_CNPJ1))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ1"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ2",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ2 PICTURE AVSX3("ED0_CNPJ2",6) Valid (Empty(M->ED0_CNPJ2) .or. (AC400Valid("ED0_CNPJ2") .and. CGC(M->ED0_CNPJ2))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ2"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ3",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ3 PICTURE AVSX3("ED0_CNPJ3",6) Valid (Empty(M->ED0_CNPJ3) .or. (AC400Valid("ED0_CNPJ3") .and. CGC(M->ED0_CNPJ3))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ3"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ4",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ4 PICTURE AVSX3("ED0_CNPJ4",6) Valid (Empty(M->ED0_CNPJ4) .or. (AC400Valid("ED0_CNPJ4") .and. CGC(M->ED0_CNPJ4))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ4"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ5",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ5 PICTURE AVSX3("ED0_CNPJ5",6) Valid (Empty(M->ED0_CNPJ5) .or. (AC400Valid("ED0_CNPJ5") .and. CGC(M->ED0_CNPJ5))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ5"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ6",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ6 PICTURE AVSX3("ED0_CNPJ6",6) Valid (Empty(M->ED0_CNPJ6) .or. (AC400Valid("ED0_CNPJ6") .and. CGC(M->ED0_CNPJ6))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ6"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ7",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ7 PICTURE AVSX3("ED0_CNPJ7",6) Valid (Empty(M->ED0_CNPJ7) .or. (AC400Valid("ED0_CNPJ7") .and. CGC(M->ED0_CNPJ7))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ7"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ8",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ8 PICTURE AVSX3("ED0_CNPJ8",6) Valid (Empty(M->ED0_CNPJ8) .or. (AC400Valid("ED0_CNPJ8") .and. CGC(M->ED0_CNPJ8))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ8"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ9",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ9 PICTURE AVSX3("ED0_CNPJ9",6) Valid (Empty(M->ED0_CNPJ9) .or. (AC400Valid("ED0_CNPJ9") .and. CGC(M->ED0_CNPJ9))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ9"))
cLin += 11

@cLin,2 SAY AVSX3("ED0_CNPJ10",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,50 MSGET M->ED0_CNPJ10 PICTURE AVSX3("ED0_CNPJ10",6) Valid (Empty(M->ED0_CNPJ10) .or. (AC400Valid("ED0_CNPJ10") .and. CGC(M->ED0_CNPJ10))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ10"))
cLin += 11

//cLin := 24  ASK 04/06/2007 - Ajustes para o Protheus 10
cLin := 30

@cLin,150 SAY AVSX3("ED0_CNPJ11",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ11 PICTURE AVSX3("ED0_CNPJ11",6) Valid (Empty(M->ED0_CNPJ11) .or. (AC400Valid("ED0_CNPJ11") .and. CGC(M->ED0_CNPJ11))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ11"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ12",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ12 PICTURE AVSX3("ED0_CNPJ12",6) Valid (Empty(M->ED0_CNPJ12) .or. (AC400Valid("ED0_CNPJ12") .and. CGC(M->ED0_CNPJ12))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ12"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ13",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ13 PICTURE AVSX3("ED0_CNPJ13",6) Valid (Empty(M->ED0_CNPJ13) .or. (AC400Valid("ED0_CNPJ13") .and. CGC(M->ED0_CNPJ13))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ13"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ14",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ14 PICTURE AVSX3("ED0_CNPJ14",6) Valid (Empty(M->ED0_CNPJ14) .or. (AC400Valid("ED0_CNPJ14") .and. CGC(M->ED0_CNPJ14))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ14"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ15",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ15 PICTURE AVSX3("ED0_CNPJ15",6) Valid (Empty(M->ED0_CNPJ15) .or. (AC400Valid("ED0_CNPJ15") .and. CGC(M->ED0_CNPJ15))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ15"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ16",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ16 PICTURE AVSX3("ED0_CNPJ16",6) Valid (Empty(M->ED0_CNPJ16) .or. (AC400Valid("ED0_CNPJ16") .and. CGC(M->ED0_CNPJ16))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ16"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ17",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ17 PICTURE AVSX3("ED0_CNPJ17",6) Valid (Empty(M->ED0_CNPJ17) .or. (AC400Valid("ED0_CNPJ17") .and. CGC(M->ED0_CNPJ17))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ17"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ18",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ18 PICTURE AVSX3("ED0_CNPJ18",6) Valid (Empty(M->ED0_CNPJ18) .or. (AC400Valid("ED0_CNPJ18") .and. CGC(M->ED0_CNPJ18))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ18"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ19",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ19 PICTURE AVSX3("ED0_CNPJ19",6) Valid (Empty(M->ED0_CNPJ19) .or. (AC400Valid("ED0_CNPJ19") .and. CGC(M->ED0_CNPJ19))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ19"))
cLin += 11

@cLin,150 SAY AVSX3("ED0_CNPJ20",5) SIZE 40,8 PIXEL of oFldAC2
@cLin,198 MSGET M->ED0_CNPJ20 PICTURE AVSX3("ED0_CNPJ20",6) Valid (Empty(M->ED0_CNPJ20) .or. (AC400Valid("ED0_CNPJ20") .and. CGC(M->ED0_CNPJ20))) SIZE 65,08 PIXEL of oFldAC2 WHEN (nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR .and. ACWhen("CNPJ20"))
cLin += 11

Return .T.

*-----------------------------*
Static Function AC400Apuracao()       // I
*-----------------------------*
Local nOp:=0
Local nEE9Ord:=EE9->(IndexOrd())
Local nSW8Ord:=SW8->(IndexOrd())
Local nInd
Local aPergs := {}
Local aRet := {}

Private cRE:=Space(AVSX3("ED1_RE",3))
Private cDue := Space(AVSX3("EEC_NRODUE",3))
Private cProdAp:=Space(AVSX3("ED1_PROD",3))
Private cNcmAp:=Space(AVSX3("ED1_NCM",3))
Private dDtIni:=avCtoD("  /  /  ")
Private dDtFim:=avCtoD("  /  /  ")
Private cComp  := Space(AVSX3("ED2_ITEM",3)) //CriaVar("ED2_ITEM")

Private cOpc //Variável para receber conteúdo da COMBOBOX
Private fWorkRE, fWorkDI, fWorkExpl, fWorkRE2, fWorkDI2, fWorkDI3, fWorkDI4, fWorkExpl2
Private lUnicoRE:= .F.//AAF 25/08/05
Private lPergunt := EasyGParam("MV_EDC0001",,.F.) //AAF 20/03/06 - Parametro que indica se o usuário pode escolher se deseja incluir
                                             //               RE's sem associação com DI.
Private oDlgI
Private nLinF  := 27
Private cMat   //Variavel private para utilização em RdMakes.
Private nLeadAnt:=EasyGParam("MV_LEADANT",,30), nCoefPeso:=0
Private nIntAnt :=EasyGParam("MV_INT_ANT",,0)
Private cCadastro := "Comprmomisso de Exportação"

// ** PLB 22/06/07
//Private aFil := IIF(lMultiFil,AvgSelectFil(.T.,,"ED1"),{cFilEEC})
Private aFil := IIF(lMultiFil,AvgSelectFil(.T.),{cFilEEC})
Private cFil := ""
Private oBfPesoInv := tHashMap():New() //bufferização da busca pelo peso da invoice
Private oBfPesoPrc := tHashMap():New() //bufferização da busca pelo peso do processo

If !(aFil[1] == "WND_CLOSE")
   For nInd:= 1 to len(aFil)
      If !aFil[nInd] $ EasyGParam("MV_AVG0024",,"")
         cFil+="'"+aFil[nInd]+"'"
         If nInd < len(aFil)
            cFil+=","
         EndIf
      EndIf
   Next i
   // PLB 27/07/07
   If Empty(cFil)
      cFil := "'  '"
   ElseIf SubStr(cFil,Len(cFil),1) == ","
      cFil := SubStr(cFil,1,Len(cFil)-1)
   EndIf
EndIf
// **

EE9->(dbSetOrder(2))
SW8->(dbSetOrder(6))
lVolta1 := .F.

If !lMultiFil  .Or.  !( aFil[1] == "WND_CLOSE" )
   If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"TELA_FILTRO_AP_EXP_A"),)

   //MFR 29/04/2019 OSSME-2916
   bValidDTs := {|| E_Periodo_Ok(MV_PAR05,MV_PAR06) }
   aAdd( aPergs ,{1,"RE"                  , cRE       ,"@!",'.T.'                                                 ,     ,'empty(cDue)',50,.F.})   // 1
   aAdd( aPergs ,{1,AVSX3("EEC_NRODUE",5) , cDue      ,"@!",'.T.'                                                 ,     ,'empty(cRe)' ,50,.F.})   // 2
   //MFR 29/04/2019 OSSME-2916
   aAdd( aPergs ,{1,AVSX3("ED1_PROD",5)   , cProdAp   ,"@!","(Empty(MV_PAR03) .or. ExistCpo(cAliasSB1,MV_PAR03))" ,"SB1",'.T.',50,.F.})           // 3
   aAdd( aPergs ,{1,AVSX3("ED1_NCM",5)    , cNcmAp    ,"@!","(Empty(MV_PAR04) .or. ExistCpo('SYD',MV_PAR04))"       ,"SYD",'.T.',50,.F.})           // 4
   //MFR 29/04/2019 OSSME-2916
   //aAdd( aPergs ,{1,"Data Inicial :"      , dDtIni    ,"@D","!empty(dDtIni)"                                      ,     ,'.T.',50,.F.})           // 5   
   aAdd( aPergs ,{1,"Data Inicial :"      , dDtIni    ,"@D",".T."                                      ,     ,'.T.',50,.F.})           // 5
   aAdd( aPergs ,{1,"Data Final : "       , dDtFim    ,"@D",    ,     ,'.T.',50,.F.}) //getcbsource(AvSX3("ED2_ITEM",7))                          // 6
   aAdd( aPergs ,{1,"Componente : "       , cComp     ,"@!", '.T.' ,AvSX3("ED2_ITEM",8),'.T.',50,.F.})                                            // 7
   aAdd( aPergs ,{2,"Filtrar CNPJ"        , "SIM"         , {"Sim","Não"}, 50,'.T.',.T.})                                                         // 8

   If lAbriuExp
      aAdd( aPergs ,{9,"Posicione no campo DUE ou RE e pressione F4 para escolher produtos a exportar." , 180  , 25, .F. })
      SETKEY(VK_F4,{|| EDCAC400HLP(@cProdAp) })
   endif
               /*aParametros, cTitle  , aRet , bOk         ,aButtons,lCentered,nPosX,nPosy,oDlgWizard,cLoad,lCanSave,lUserSave*/
   if Parambox( aPergs      , STR0106 , aRet ,  bValidDTs  ,        ,   .T.   ,     ,     ,          ,     , .T.    , .T. )

      // ** variáveis de acordo com o retorno do parambox
      cRE      := aRet[1]
      cDue     := aRet[2]
      cProdAp  := aRet[3]
      cNcmAp   := aRet[4]
      dDtIni   := aRet[5]
      dDtFim   := aRet[6]
      cComp    := aRet[7]
      cOpc     := aret[8]

      // ** AAF 25/08/05
      If !Empty(cRE)
         lUnicoRE:= .T.
      Endif

      GeraWKExpl()

      MsAguarde( { || SelectRE(cProdAp,cNcmAp,cRE,cDue,dDtIni,dDtFim,cComp)}, STR0082 ) //"Aguarde, Apurando Dados..."
      If WorkExpl->(EasyRecCount()) > 0
         MsAguarde({|| AC400SelDI(.T.)}, STR0082 ) //"Aguarde, Apurando Dados..."
      EndIf
      //WorkExpl->(dbCloseArea())
      WorkExpl->(E_EraseArq(fWorkExpl,fWorkExpl2))
      //E_EraseArq(fWorkExpl2)
      //WorkRE->(dbCloseArea())
      WorkRE->(E_EraseArq(FWorkRE))
      lVolta1 := .T.

   endif
EndIf

If lAbriuExp   // Desabilita o F4 caso esteja ativo
   SETKEY(VK_F4,NIL)
Endif

EE9->(dbSetOrder(nEE9Ord))
SW8->(dbSetOrder(nSW8Ord))
WorkED1->(dbGoTop())
WorkED2->(dbGoTop())
dbSelectArea("WorkED1") //LRL 25/05/04
Return .T.

*---------------------------------------------------------------------------------------------*
Static Function SelectRE(cProdAp,cNcmAp,cRE,cDue,dDtIni,dDtFim,cComp)
*---------------------------------------------------------------------------------------------*
Local nCod, i
Local nOrdEE9 := EE9->(IndexOrd()), nOrdEEC := EEC->(IndexOrd()),nOrdSG1 := SG1->(IndexOrd()),nOrdED9 := ED9->(IndexOrd()),nOrdED1 := ED1->(IndexOrd())
Private cQuery
Private cCond:=""

FWorkRE :=E_CriaTrab( ,aSemSX3RE, "WorkRE")
FWorkRE2:=E_Create(,.F.)

If lTop
   cDtIni := If( DToS(dDtIni) > GeraValAto(If(nVal_Ato>=1,1,2)),DtoS(dDtIni), GeraValAto(If(nVal_Ato>=1,1,2)) )

   cQuery:= "SELECT DISTINCT " +;
            "CASE WHEN EEC.EEC_NRODUE <> ' ' THEN EEC.EEC_NRODUE ELSE EE9.EE9_RE END AS ED1_RE, "+;
            "CASE WHEN EEC.EEC_NRODUE <> ' ' THEN EEC.EEC_DTDUE  ELSE EE9.EE9_DTRE END AS ED1_DTRE, "+;
            "EE9.EE9_COD_I ED1_PROD, EE9.EE9_POSIPI ED1_NCM, "+;
            "EE9.EE9_SLDINI ED1_QTD, EE9.EE9_PRCINC ED1_VL_MOE, "+;
            "EEC.EEC_MOEDA ED1_MOEDA, "+;
            "EE9.EE9_PREEMB ED1_PREEMB, EE9.EE9_PEDIDO ED1_PEDIDO, EE9.EE9_SEQUEN ED1_SEQUEN, "+;
            "EE9_PSLQTO, EE9_SLDINI, EE9_PSLQTO/EE9_SLDINI ED1_PESO, EE9.EE9_PERCOM ED1_PERCAG, EE9.EE9_UNIDAD UNID, "+; //EE9.EE9_PSLQUN AAF 03/03/06 - Utilizado o campo EE9_PSLQTO pois este é enviado ao siscomex exportação.
            "EEC.EEC_EXPORT EXP, EEC.EEC_EXLOJA LEXP, EEC.EEC_FORN FORN, EEC.EEC_FOLOJA LFORN, "+;
            "EE9.EE9_ISENTO ISENTO, EE9.EE9_SALISE SALISE, EE9.EE9_FABR FABR, "+;
            "EEC.EEC_DTEMBA ED1_DTEMBA "
   If lMultiFil
      cQuery += ", EE9.EE9_FILIAL ED1_FILORI "
   EndIf
   // ** AAF 18/11/2008 - Verificacao do preço FOB
   cQuery+= " , EEC.EEC_INCOTE, EE9.EE9_PRCTOT "
   // **

   cFrom := RetSqlName("EEC")+" EEC, "+RetSqlName("EE9")+" EE9"
   If SYD->( FieldPos("YD_PER_AC") ) > 0
      cFrom += ", "+RetSqlName("SYD")+" SYD"
   endif
   If !Empty(cComp)
      cFrom += ", "+RetSqlName("SG1")+" SG1 "
   endif

   If lMultiFil
      cCond+="EEC.EEC_FILIAL IN ("+cFil+") "
   Else
      cCond+="EEC.EEC_FILIAL='"+cFilEEC+"' "
   EndIf
   cCond+=If(TcSrvType()<>"AS/400"," AND EEC.D_E_L_E_T_ <> '*' "," EEC.@DELETED@ <> '*' ")
   cCond+=If(TcSrvType()<>"AS/400"," AND EE9.D_E_L_E_T_ <> '*' "," EE9.@DELETED@ <> '*' ")

   cCond+="AND EEC.EEC_COBCAM='1' "
   cCond+="AND EEC.EEC_STATUS<>'*' "
   If(!Empty(Alltrim(cDue)),cCond+="AND EEC.EEC_NRODUE='"+cDue+"' ", )
   cCond+=If( !Empty(dDtFim)," AND EEC.EEC_DTEMBA between '"+cDtIni+"' and '"+DtoS(dDtFim)+"' ", " AND EEC.EEC_DTEMBA >= '"+cDtIni+"' " )

   cCond+="AND EE9.EE9_FILIAL = EEC.EEC_FILIAL "
   cCond+="AND EE9.EE9_PREEMB = EEC.EEC_PREEMB "
   cCond+="AND ((EE9.EE9_DTAVRB <> ' ' AND EE9.EE9_RE <> ' ') OR (EEC.EEC_NRODUE<>' ' ) ) "
   cCond+="AND (EE9.EE9_ATOCON = ' ') "
   If(!Empty(Alltrim(cRE)),cCond+="AND EE9.EE9_RE='"+cRE+"' ", )
   If(!Empty(Alltrim(cProdAp)),cCond+="AND EE9.EE9_COD_I='"+cProdAp+"' ",)
   If(!Empty(Alltrim(cNcmAp)),cCond+="AND EE9.EE9_POSIPI='"+cNcmAp+"' ",)
   //cCond+="(EE9.EE9_ISENTO = 'N' AND EE9.EE9_SALISE > 0)) "

   // ** AAF 26/09/2006 - Não permitir utilização de um mesmo RE em mais de um Ato.
   // **                  Verificar se o RE já está sendo utilizado,
   // **                  conforme Item 2 do Anexo "G" da PORTARIA SECEX nº14.
   cCond+= " AND ((CASE WHEN EEC.EEC_NRODUE<>' ' THEN EEC.EEC_NRODUE ELSE EE9.EE9_RE END) "+;
                                 "NOT IN (SELECT ED1.ED1_RE FROM "+RetSqlName("ED1")+" ED1 "+;
                                 " WHERE "+If(TcSrvType()<>"AS/400"," ED1.D_E_L_E_T_ <> '*' "," ED1.@DELETED@ <> '*' ")+;
                                 " AND ED1.ED1_FILIAL = '"+xFilial("ED1")+"' "+;
                                 " AND ED1.ED1_PD <> '"+M->ED0_PD+"'))"

   // ** AAF 05/07/05 - Verifica se a NCM pode ser utilizada em Drawback.
   If SYD->( FieldPos("YD_PER_AC") ) > 0
      cCond+= If(TcSrvType()<>"AS/400","AND SYD.D_E_L_E_T_ <> '*' "," SYD.@DELETED@ <> '*' ")
      cCond+= " AND SYD.YD_FILIAL = '"+cFilSYD+"' AND SYD.YD_TEC = EE9.EE9_POSIPI AND SYD.YD_PER_AC <> '2'"
   Endif

   // ** AAF 26/05/2006 - Adicionado filtro por componente da estrutura.
   If !Empty(cComp)
      cCond+= If(TcSrvType()<>"AS/400"," AND SG1.D_E_L_E_T_ <> '*' "," SG1.@DELETED@ <> '*' ")+;
      " AND SG1.G1_FILIAL = '"+xFilial("SG1")+"' AND SG1.G1_COD = EE9.EE9_COD_I AND SG1.G1_COMP = '"+cComp+"'
   EndIf
   // **

   If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"QUERY_APURA_RE"),)

   cQuery:=ChangeQuery(cQuery+" FROM "+cFrom+" WHERE "+cCond)

   //AOM - 16/03/2012
   If Select("TRB") > 0
      TRB->( dbCloseArea() )
   Endif

   TcQuery cQuery ALIAS "TRB" NEW
   TcSetField("TRB","ED1_DTRE","D")
   TcSetField("TRB","ED1_DTEMBA","D")
   TcSetField("TRB","ED1_PESO"  ,"N",AVSX3("ED1_PESO",3),AVSX3("ED1_PESO",4))
   TcSetField("TRB","EE9_PSLQTO","N",AVSX3("EE9_PSLQTO",3),AVSX3("EE9_PSLQTO",4))
   TcSetField("TRB","EE9_SLDINI","N",AVSX3("EE9_SLDINI",3),AVSX3("EE9_SLDINI",4))

   IndRegua("WorkRE",FWorkRE+TEOrdBagExt() ,"ED1_PROD+DTOS(ED1_DTEMBA)")
   IndRegua("WorkRE",FWorkRE2+TEOrdBagExt(),"ED1_RE+ED1_PROD+DTOS(ED1_DTEMBA)")
   SET INDEX TO (FWorkRE+TEOrdBagExt()),(FWorkRE2+TEOrdBagExt())

   dbSelectArea("TRB")
   Do While !TRB->(EOF())
      WorkRE->(RecLock("WorkRE",.T.))
      FOR i := 1 TO FCount()
         //cCampo := FIELDNAME(i)
         If !TRB->(FieldName(i))  $ "EEC_INCOTE/EE9_PRCTOT" // ! cCampo $ "EEC_INCOTERM/EE9_PRCTOT"
            &("WorkRE->"+TRB->(FieldName(i))) := TRB->(FieldGet(i)) //WorkRE->&(cCampo) :=
         EndIf
      NEXT i
      WorkRE->TRB_ALI_WT:= "ED1"
      WorkRE->TRB_REC_WT:= ED1->(Recno())
      // ** AAF 18/11/2008 - Utilizar o valor no incoterm nos casos abaixo, devido ao envio ao SISCOMEX do SIGAEEC no EECSI100.PRW
      If TRB->EEC_INCOTE $ "EXW/FAS/FOB/FCA"
         WorkRE->ED1_VL_MOE := TRB->EE9_PRCTOT
      EndIf
      // **

      WorkRE->(msUnlock())

      If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"GRV_WORKRE"),)  // TLM 23/01/2008

      TRB->(dbSkip())
   EndDo

   //Igor Chiba 03/04/2009  pesquisando registros da table ED9(R.E externo)

// cQuery := "Select ED9.ED9_NCM   ,ED9.ED9_DTRE  ,ED9.ED9_RE ,ED9.ED9_MOEDA,"+;
//                  "ED9.ED9_DTEMB ,ED9.ED9_EXPORT,ED9.ED9_UM ,ED9.ED9_LOJA ,ED9.ED9_QTD, ED9_POSICA"
   IF lReExt
      cQuery := "Select " +If(TcSrvType()<>"AS/400"," ED9.R_E_C_N_O_ "," ED9.@RECNO@ ")+" REGISTRO "

// If lReExt
//    cQuery +=",ED9.ED9_SALISE,ED9.ED9_ISENTO,ED9.ED9_PROD,ED9.ED9_DTAVRB"
// EndIf

      cFrom  := RETSQLNAME('ED9')+" ED9"

      cCond  := " WHERE ED9.ED9_DTEMB <>'' AND ED9.ED9_AC = '' AND ED9.ED9_DTAVRB <> '' AND "
   //Else
   //   cCond  := " WHERE ED9.ED9_DTEMB <>'' AND ED9.ED9_AC = '' AND "
   //EndIf

      IF !EMPTY(AllTrim(cRE))
         cCond+=" ED9.ED9_RE ='"+cRE+"' AND"
      ENDIF

      IF !EMPTY(dDtIni)
         cCond+=" ED9.ED9_DTEMB >='"+DTOS(dDtIni)+"' AND"
      ENDIF

      IF !EMPTY(dDtFim)
         cCond+=" ED9.ED9_DTEMB <='"+DTOS(dDtFim)+"'  AND"
      ENDIF


      IF !EMPTY(cNcmAp)
         cCond+=" ED9.ED9_NCM ='"+cNcmAp+"' AND"
      ENDIF


      IF !EMPTY(cProdAp)   //Produto exportado
        cCond+=" ED9.ED9_PROD ='"+cProdAp+"' AND"
      ENDIF


      cCond+= " ED9.ED9_RE NOT IN((SELECT ED1.ED1_RE FROM "+RetSqlName("ED1")+" ED1 "+;
                                      " WHERE "+If(TcSrvType()<>"AS/400"," ED1.D_E_L_E_T_ <> '*' "," ED1.@DELETED@ <> '*' ")+;
                                      " AND ED1.ED1_FILIAL = '"+cFilED1+"' "+;
                                      " AND ED1.ED1_PD <> '"+M->ED0_PD+"')) AND "


      cCond+= If(TcSrvType()<>"AS/400"," ED9.D_E_L_E_T_ <> '*'","ED9.@DELETED@ <> '*'")
      cCond+=" AND ED9.ED9_FILIAL='"+cFilED9+"'"

      cQuery:=ChangeQuery(cQuery+" FROM "+cFrom+cCond)

      If Select("WORK") > 0
         Work->(dbCloseArea())
      EndIF

      TcQuery cQuery ALIAS "WORK" NEW

// TcSetField("WORK","ED9_DTRE"  ,"D")
// TcSetField("WORK","ED9_DTEMB" ,"D")
// If lReExt
//    TcSetField("WORK","ED9_SALISE","N",AVSX3('ED9_SALISE',3),AVSX3('ED9_SALISE',4))
//    TcSetField("WORK","ED9_DTAVRB" ,"D")
// EndIf

      Do While !WORK->(EOF())

         ED9->(DBGOTO(WORK->REGISTRO))

         SG1->(DBSETORDER(2))
         IF  !EMPTY(cComp)  //verificar se o componente informado compoe o produto ED9
            IF ! SG1->(DBSEEK(cFilSG1+AVKEY(cComp,'G1_COMP')+ED9->ED9_PROD))
               WORK->(DBSKIP())
               LOOP
            ENDIF
         ENDIF

         If SYD->( FieldPos("YD_PER_AC") ) > 0 .AND. SYD->( dbSeek(cFilSYD+ED9->ED9_NCM ) )
            If SYD->YD_PER_AC == "2"
              WORK->(DBSKIP())
              LOOP
            EndIf
         Endif

         WorkRE->(RecLock("WorkRE",.T.))
         WorkRE->ED1_NCM    := ED9->ED9_NCM
         WorkRE->ED1_DTRE   := ED9->ED9_DTRE
         WorkRE->ED1_RE     := ED9->ED9_RE
         WorkRE->ED1_MOEDA  := ED9->ED9_MOEDA
         WorkRE->ED1_DTEMBA := ED9->ED9_DTEMB
         WorkRE->UNID       := ED9->ED9_UM
         WorkRE->ED1_QTD    := ED9->ED9_QTD
         WorkRE->ED1_SEQUEN := ED9->ED9_POSICA
         WorkRE->ED1_VL_MOE := ED9->ED9_VALMOE
         WorkRE->EE9_PSLQTO := ED9->ED9_PESO
         WorkRE->EE9_SLDINI := ED9->ED9_QTD

         SA2->(DBSETORDER(3))
         IF SA2->(DBSEEK(cFilSA2+ED9->ED9_EXPORT))
            WorkRE->EXP  := SA2->A2_COD
            WorkRE->LEXP := SA2->A2_LOJA
         ENDIF

         WorkRE->ISENTO  := ED9->ED9_ISENTO
         WorkRE->SALISE  := ED9->ED9_SALISE
         WorkRE->ED1_PROD:= ED9->ED9_PROD

         WorkRE->TRB_ALI_WT := "ED9"
         WorkRE->TRB_REC_WT := ED9->(Recno())

         WORK->(DBSKIP())
      EndDo

      WORK->(dbCloseArea())
   EndIf

   //FIM Igor Chiba 03/04/2009
   SG1->(DBSETORDER(nOrdSG1))

   TRB->(dbCloseArea())
   dbSelectArea("WorkRE")
Else
   IndRegua("WorkRE",FWorkRE+TEOrdBagExt() ,"ED1_PROD+DTOS(ED1_DTEMBA)")
   IndRegua("WorkRE",FWorkRE2+TEOrdBagExt(),"ED1_RE+ED1_PROD+DTOS(ED1_DTEMBA)")
   SET INDEX TO (FWorkRE+TEOrdBagExt()),(FWorkRE2+TEOrdBagExt())

   EE9->(DbSetOrder(9))
   EEC->(DbSetOrder(1))
   EEC->(Dbgotop())
   //EEC->(DbSeek(cFilEEC,.T.))
   //Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL == cFilEEC
   If lMultiFil
      bWhile := {||.T.}
   Else
      EEC->(DbSeek(cFilEEC,.T.))
      bWhile := { || EEC->EEC_FILIAL == cFilEEC }
   EndIf
   Do While EEC->( !EoF() )  .And.  Eval(bWhile)
      If lMultiFil
         If !( EEC->EEC_FILIAL $ cFil )
            EEC->( DBSkip() )
            Loop
         EndIf
      EndIf
      MsProcTxt(STR0107+Alltrim(EEC->EEC_PREEMB)) //"Apurando Processo "
      If EEC->EEC_COBCAM = '1' .AND. EEC->EEC_STATUS <> '*' .and.;
      Dtos(EEC->EEC_DTEMBA) >= GeraValAto(If(nVal_Ato>=1,1,2))

         // PLB 22/06/07
         If lMultiFil
            EE9->(DbSeek(EEC->EEC_FILIAL+EEC->EEC_PREEMB, .T.))
            bWhile := { || EE9->EE9_FILIAL == EEC->EEC_FILIAL  .And.  EE9->EE9_PREEMB = EEC->EEC_PREEMB }
         Else
            EE9->(DbSeek(cFilEE9+EEC->EEC_PREEMB, .T.))
            bWhile := { || EE9->EE9_FILIAL == cFilEE9  .And.  EE9->EE9_PREEMB = EEC->EEC_PREEMB }
         EndIf

         Do While EE9->( !Eof() )  .And.  Eval(bWhile)

            If !Empty(Alltrim(cRE))
               If EE9->EE9_RE <> cRE
                  EE9->(DbSkip())
                  Loop
               Endif
            Endif

            If !Empty(Alltrim(cProdAp))
               If EE9->EE9_COD_I <> cProdAp
                  EE9->(DbSkip())
                  Loop
               Endif
            Endif

            If !Empty(Alltrim(cNcmAp))
               If EE9->EE9_POSIPI <> cNcmAp
                  EE9->(DbSkip())
                  Loop
               Endif
            Endif

            // ** AAF 05/07/05 - Verifica se a NCM pode ser usada em Drawback.
            If SYD->( FieldPos("YD_PER_AC") ) > 0 .AND. SYD->( dbSeek(cFilSYD+EE9->EE9_POSIPI ) )
               If SYD->YD_PER_AC == "2"
                  EE9->( dbSkip() )
                  Loop
               EndIf
            Endif
            // **

            If !Empty(EE9->EE9_DTAVRB) .and. !Empty(EE9->EE9_RE) .and. (Empty(EE9->EE9_ATOCON) .or.;
            (EE9->EE9_ISENTO == "N" .and. EE9->EE9_SALISE > 0))
               WorkRE->(RecLock("WorkRE",.T.))
               WorkRE->MARCA      := '  '
               WorkRE->ED1_PROD   := EE9->EE9_COD_I
               WorkRE->ED1_NCM    := EE9->EE9_POSIPI
               WorkRE->ED1_QTD    := EE9->EE9_SLDINI
               WorkRE->ED1_VL_MOE := EE9->EE9_PRCINC
               WorkRE->ED1_DTRE   := EE9->EE9_DTRE
               WorkRE->ED1_RE     := EE9->EE9_RE
               WorkRE->ED1_MOEDA  := EEC->EEC_MOEDA
               WorkRE->ED1_PREEMB := EE9->EE9_PREEMB
               WorkRE->ED1_PEDIDO := EE9->EE9_PEDIDO
               WorkRE->ED1_SEQUEN := EE9->EE9_SEQUEN
               WorkRE->ED1_PESO   := Round(EE9->EE9_PSLQTO/EE9->EE9_SLDINI,AvSx3("ED1_PESO",4)) //EE9->EE9_PSLQUN AAF 03/03/06 - Utilizado o campo EE9_PSLQTO pois este é enviado ao siscomex exportação.
               // ** PLB 15/03/07
               WorkRE->EE9_PSLQTO := EE9->EE9_PSLQTO
               WorkRE->EE9_SLDINI := EE9->EE9_SLDINI
               // **
               WorkRE->ED1_PERCAG := EE9->EE9_PERCOM
               WorkRE->UNID       := EE9->EE9_UNIDAD
               WorkRE->EXP        := EEC->EEC_EXPORT
               WorkRE->LEXP       := EEC->EEC_EXLOJA
               WorkRE->FORN       := EEC->EEC_FORN
               WorkRE->LFORN      := EEC->EEC_FOLOJA
               WorkRE->ISENTO     := EE9->EE9_ISENTO
               WorkRE->SALISE     := EE9->EE9_SALISE
               WorkRE->ED1_VAL_EM := 0
               WorkRE->FABR       := EE9->EE9_FABR
               WorkRE->ED1_DTEMBA := EEC->EEC_DTEMBA
               WorkRE->TRB_ALI_WT := "ED1"
               WorkRE->TRB_REC_WT := ED1->(Recno())
               If lMultiFil
                  WorkRE->ED1_FILORI := EE9->EE9_FILIAL + " - " + AvgFilName({EE9->EE9_FILIAL})[1]
               EndIf
               WorkRE->(msUnlock())
            Endif
            EE9->(DbSkip())
         Enddo
      Endif
      EEC->(DbSkip())
   Enddo

   //igor chiba 06/04/09 appendando registro ED9(RE externo)

   If lReExt

      cCondicao := ".T. "
      IF !EMPTY(dDtIni)
         cCondicao+= '.AND. dDtIni <=  ED9->ED9_DTEMB'
      ENDIF

      IF !EMPTY(dDtFim)
         cCondicao+= ' .AND. dDtFim >=  ED9->ED9_DTEMB '
      ENDIF

      bFiltroED9 := &("{||"+cCondicao+"}")

      ED1->(DBSETORDER(4))
      ED9->(DBSEEK(cFilED9))
      DO WHILE ED9->(!EOF()) .AND. ED9->ED9_FILIAL == cFilED9

         IF !EVAL(bFiltroED9)
            ED9->(DBSKIP())
            LOOP
         ENDIF

         IF !EMPTY(cProdAp) .AND. ED9->ED9_PROD <> AVKEY(cProdAp,'ED9_PROD')   //Produto exportado
            ED9->(DBSKIP())
            LOOP
         ENDIF

         IF EMPTY(ED9->ED9_DTEMB) // ter data embarque preenchida
            ED9->(DBSKIP())
            LOOP
         ENDIF

         IF ED1->(DBSEEK(cFilED1+ED9->ED9_AC))   //nao pode ter um sido usado em um pedido drawback
            ED9->(DBSKIP())
            LOOP
         ENDIF

         IF EMPTY(ED9->ED9_DTAVRB)  // ter a data de averbação preenchida
            ED9->(DBSKIP())
            LOOP
         ENDIF

         IF !EMPTY(ED9->ED9_AC)  // ato concessorio em branco
            ED9->(DBSKIP())
            LOOP
         ENDIF

         SG1->(DBSETORDER(2))
         IF  !EMPTY(cComp) //verificar se o componente informado compoe o produto ED9
            IF ! SG1->(DBSEEK(cFilSG1+AVKEY(cComp,'G1_COMP')+ED9->ED9_PROD))
               ED9->(DBSKIP())
               LOOP
            ENDIF
         ENDIF

         If SYD->( FieldPos("YD_PER_AC") ) > 0 .AND. SYD->( dbSeek(cFilSYD+ED9->ED9_NCM ) )
            If SYD->YD_PER_AC == "2"
              ED9->(DBSKIP())
              LOOP
            EndIf
         Endif

         If !Empty(cNcmAp)
            If ED9->ED9_NCM <> AVKEY(cNcmAp,'ED9_NCM')
               ED9->(DbSkip())
               Loop
            Endif
         Endif

         WorkRE->(RecLock("WorkRE",.T.))
         WorkRE->ED1_NCM    := ED9->ED9_NCM
         WorkRE->ED1_DTRE   := ED9->ED9_DTRE
         WorkRE->ED1_RE     := ED9->ED9_RE
         WorkRE->ED1_MOEDA  := ED9->ED9_MOEDA
         WorkRE->ED1_DTEMBA := ED9->ED9_DTEMB
         WorkRE->UNID       := ED9->ED9_UM
         WorkRE->ED1_QTD    := ED9->ED9_QTD
         WorkRE->ED1_SEQUEN := ED9->ED9_POSICA
         WorkRE->ED1_VL_MOE := ED9->ED9_VALMOE
         WorkRE->EE9_PSLQTO := ED9->ED9_PESO
         WorkRE->EE9_SLDINI := ED9->ED9_QTD

         SA2->(DBSETORDER(3))
         IF SA2->(DBSEEK(cFilSA2+ED9->ED9_EXPORT))
            WorkRE->EXP  := SA2->A2_COD
            WorkRE->LEXP := SA2->A2_LOJA
         ENDIF

         WorkRE->ISENTO     := ED9->ED9_ISENTO
         WorkRE->SALISE     := ED9->ED9_SALISE
         WorkRE->ED1_PROD   := ED9->ED9_PROD

         ED9->(DBSKIP())
      ENDDO

      ED9->(DbSetOrder(nOrdED9))
   EndIf
   //FIM igor chiba 06/04/09 appendando registro ED9(RE externo)

   ED1->(DbSetOrder(nOrdED1))
   SG1->(DbSetOrder(nOrdSG1))
   EEC->(DbSetOrder(nOrdEEC))
   EE9->(DbSetOrder(nOrdEE9))
Endif

//Processa({|| ValidaCGC("WorkRE")},STR0108) //"Apurando..."
Processa({|| AC400PApura("WorkRE")},STR0108) //"Apurando..."

If !WorkRE->(EOF()) .and. !WorkRE->(BOF())
   AC400BrwRe()
Else
   Help(" ",1,"AVG0005152") //"Nenhum Registro Selecionado na Apuracao."
EndIf

Return .T.

*-------------------*
Function AC400BrwRE()
*-------------------*
Local oMark, aBotao:={}, oDlgJ
Local nOp:=0, cTitulo:=STR0110 //"Produtos da Exportacao"
Local COLUNA_FINAL

Aadd(aBotao,{"LBTIK",{|| Processa({|| APMarca(.T.,"WorkRE")},STR0021),WorkRE->(dbGoTop()),oMark:oBrowse:Refresh() },STR0021}) //"Marca/Desmarca Todos"
Aadd(aBotao,{"PESQUISA",{||APURAPESQ("RE")},STR0174}) //"Pesquisa Exportação"

DEFINE MSDIALOG oDlgJ TITLE cTitulo FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

   COLUNA_FINAL := (oDlgJ:nClientWidth-4)/2
   nLinha       := (oDlgJ:nClientHeight-4)/2

   oMark:= MsSelect():New("WorkRE","MARCA",,aSelCpos7,@lInverte,@cMarca,{15,1,nLinha,COLUNA_FINAL})
   oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkRE"),.T.}
   oMark:bAval:={||APMarca(.F.,"WorkRE"),oMark:oBrowse:Refresh()}
   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgJ ON INIT EnchoiceBar(oDlgJ,{||If(MsgYesNo(STR0180+Chr(13)+Chr(10)+STR0181),(nOp:=1, oDlgJ:End()), )},{||If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),(nOp:=0,oDlgJ:End()), )},,aBotao) //"Confirma Gravação da Apuração?"###"Todas as informações serão Salvas."###"Deseja Realmente Sair?"###"Todas as alterações serão perdidas."

If nOp = 1
   Processa({|| ExplodeRE()},STR0111) //"Apuracao de Itens"
   If WorkExpl->(EasyRecCount()) <= 0
      Help(" ",1,"AVG0005152") //"Nenhum Registro Selecionado na Apuracao."
   EndIf
Else
   oMUserEDC:Solta("ATO","FECHA_BROWSE_RE")  // PLB 27/11/06 - Destrava os registros refentes aos Produtos no objeto
EndIf

Return .T.

*------------------------------------*
Static Function APMarca(lTodos,cAlias)
*------------------------------------*
Local /*lMens1:=.F.,*/ lMens2:=.F., lMens3:=.F., lMens4:=.F., lMens5:=.F., lMens6:=.F.
Local cMensa:= "", nSaldoTela:=nQtdExp:= 0, nQtdAux:=0, nRecAux, aArrayAux:={}, nRecAux2

SG1->(dbSetOrder(1))

If !lTodos
   If (cAlias)->MARCA <> cMarca
      (cAlias)->MARCA := cMarca
      If cAlias=="WorkDI"
         ACGetAnt()
         If !Empty(WorkDI->ED2_RE) .and. !Empty(WorkDI->ED2_PROD) .and.;
         WorkExpl->(dbSeek(iif(lED2Inat,If(Empty(WorkDI->ED2_INAT),WorkDI->ED2_ITEM,WorkDI->ED2_INAT),WorkDI->ED2_ITEM)+WorkDI->ED2_RE+WorkDI->ED2_PROD)) // ACSJ - 17/11/2004
            If SB1->B1_FILIAL<>cFilSB1 .or. SB1->B1_COD<>WorkDI->ED2_ITEM
               SB1->(dbSeek(cFilSB1+WorkDI->ED2_ITEM))
            EndIf

            // ** AAF 10/08/2006 - Volta da quantidade convertida para a Unidade Estatistica de acordo com o criterio da baixa.
            If ! AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
               nQtdAux := AVTransUnid(WorkDI->UNID,SB1->B1_UM,WorkDI->ED2_ITEM,If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD))
            Else
               nQtdAux := WorkDI->ED2_PESO
            Endif
            // **

            nSaldoTela:= WorkExpl->QUANT1 - WorkExpl->QUANT2
            nQtdExp:= WorkExpl->QTD
            WorkExpl->QUANT2 -= nQtdAux

            If WorkExpl->QUANT2 < 0 .and. AC400TELAQTD("WorkDI",WorkExpl->QUANT1,nSaldoTela,nQtdAux) .and. !MsgYesNo(STR0112) //"Item estourou o limite da estrutura de produtos. Marcar o item?"
               WorkDI->MARCA   := ""
               WorkDI->ED2_RE  := ""
               WorkDI->ED2_PROD:= ""
               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                  WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF

               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                  WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF


               WorkExpl->QUANT2+= nQtdAux
            EndIf
         EndIf
         If WorkDI->MARCA == cMarca
            If SYD->YD_FILIAL <> cFilSYD .or. WorkDI->ED2_NCM <> SYD->YD_TEC
               SYD->(dbSetOrder(1))
               SYD->(dbSeek(cFilSYD+WorkDI->ED2_NCM))
            EndIf
            If Empty(SYD->YD_UNID)
               Help(" ",1,"AVG0005153") //"Item nao pode ser marcado pois sua NCM nao possui Unidade de Medida."
               WorkDI->MARCA := ""
               WorkDI->ED2_RE  := ""
               WorkDI->ED2_PROD:= ""
               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                  WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF

               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                  WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF
               WorkExpl->QUANT2 += nQtdAux
            ElseIf !Empty(WorkDI->MENSA) .and. Left(WorkDI->MENSA,6) <> STR0183 //"Aviso:"
               Msginfo(STR0205+WorkDI->MENSA, STR0195) //"Item não pode ser marcado, pois "###"Mensagem"
               WorkDI->MARCA := ""
               WorkDI->ED2_RE  := ""
               WorkDI->ED2_PROD:= ""
               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                  WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF

               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                  WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF
               WorkExpl->QUANT2 += nQtdAux
            ElseIf !Empty(WorkDI->MENSA) .and. Left(WorkDI->MENSA,6) == STR0183 //"Aviso:"
               Msginfo(Alltrim(WorkDI->MENSA))
            Endif
            If WorkDI->MARCA == cMarca
               If  ChkFile("ED8",.F.) // lDiExt .AND. - NOPADO POR AOM - 04/11/10
                  ED8->( dbSetOrder(4) )
               EndIf
               //If (SW8->(dbSeek(cFilSW8+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU)) .and. !SoftLock("SW8")) .OR.;
               //   (ED8->(dbSeek(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA)) .and. !SoftLock("ED8"))
               //   Help(" ",1,"AVG0005154") //"Item nao pode ser marcado pois esta marcado para outra apuracao."

               // PLB 27/11/06 - Bloqueio de registros pelo objeto
               //If (SW8->(dbSeek(cFilSW8+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU)) .OR.;
               //    ED8->(dbSeek(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA)))  .And.  !oMUserEDC:Reserva("ATO","MARCA_DI")
               If lMultiFil
                  cFilAux := Left((cAlias)->ED2_FILORI,2)
               Else
                  cFilAux := cFilSW8
               EndIf
               If (SW8->(dbSeek(cFilAux+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU)) .OR.;
                   ED8->(dbSeek(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA)))  .And.  !oMUserEDC:Reserva("ATO","MARCA_DI")
                  WorkDI->MARCA := ""
                  WorkDI->ED2_RE  := ""
                  WorkDI->ED2_PROD:= ""
                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                     WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
                  ENDIF

                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                     WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
                  ENDIF
                  WorkExpl->QUANT2 += nQtdAux
               EndIf
            EndIf
         EndIf
      Else
         If !SG1->(dbSeek(cFilSG1+WorkRE->ED1_PROD))
           MsGInfo (STR0088+"("+Alltrim(WorkRE->ED1_PROD)+") não possui estrutura no Cadastro." ) //LRL 27/01/04 Help(" ",1,"AVG0005271",,"("+Alltrim(WorkRE->ED1_PROD)+") não possui estrutura no Cadastro.", 1,9) //"Produto "
         Endif
         //EE9->(dbSeek(cFilEE9+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN))
         //If !SoftLock("EE9")
         //   Help(" ",1,"AVG0005155") //"Produto nao pode ser marcado pois esta marcado para outra apuracao."
         //Else
         If SYD->YD_FILIAL <> cFilSYD .or. WorkRE->ED1_NCM <> SYD->YD_TEC
            SYD->(dbSetOrder(1))
            SYD->(dbSeek(cFilSYD+WorkRE->ED1_NCM))
         EndIf
         If Empty(SYD->YD_UNID)
            Help(" ",1,"AVG0005156") //"Produto nao pode ser marcado pois sua NCM nao possui Unidade de Medida."
            WorkRE->MARCA := ""
         ElseIf !Empty(WorkRE->MENSA) .and. Left(WorkRE->MENSA,6) <> STR0183 //"Aviso:"
            Msginfo(STR0204+WorkRE->MENSA, STR0195) // "Produto não pode ser marcado, pois "###"Mensagem"
            WorkRE->MARCA := ""
         EndIf
         If WorkRE->MARCA == cMarca  .And.  !oMUserEDC:Reserva("ATO","MARCA_RE")  // PLB 27/11/06 - Bloqueio de registros pelo objeto
            WorkRE->MARCA := ""
         EndIf
            //EE9->(msUnlock())
         //EndIf
      EndIf
   Else
      (cAlias)->MARCA := ""
      If cAlias=="WorkDI"
         If !Empty(WorkDI->ED2_RE) .and. !Empty(WorkDI->ED2_PROD) .and.;
         WorkExpl->(dbSeek(iif(lED2Inat,If(Empty(WorkDI->ED2_INAT),WorkDI->ED2_ITEM,WorkDI->ED2_INAT),WorkDI->ED2_ITEM)+WorkDI->ED2_RE+WorkDI->ED2_PROD))  // ACSJ - 17/11/2004
            If SB1->B1_FILIAL<>cFilSB1 .or. SB1->B1_COD<>WorkDI->ED2_ITEM
               SB1->(dbSeek(cFilSB1+WorkDI->ED2_ITEM))
            EndIf

            // ** AAF 10/08/2006 - Volta da quantidade convertida para a Unidade Estatistica de acordo com o criterio da baixa.
            If ! AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
               nQtdAux := AVTransUnid(WorkDI->UNID,SB1->B1_UM,WorkDI->ED2_ITEM,If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD))
            Else
               nQtdAux := WorkDI->ED2_PESO
            Endif
            // **

            WorkExpl->QUANT2 += nQtdAux

            /*If SW8->(dbSeek(cFilSW8+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
               SW8->(msUnlock())
            ElseIf lDiExt
               ED8->( dbSetOrder(4) )
               If ED8->(dbSeek(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA))
                  ED8->(msUnLock())
               EndIf
            EndIf*/
         EndIf
         nRecAux:=WorkDI->(RecNo())
         aArrayAux:={WorkDI->ED2_ITEM,WorkDI->ED2_HAWB,WorkDI->ED2_INVOIC,WorkDI->ED2_PO_NUM,;
                     WorkDI->ED2_POSICA,WorkDI->ED2_PGI_NU,If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD),;
                     WorkDI->ED2_VALEMB,WorkDI->ED2_VL_MOE}
         If WorkDI->(dbSeek(WorkDI->ED2_ITEM))
            Do While !WorkDI->(EOF()) .and. WorkDI->ED2_ITEM==aArrayAux[1] .and. ;
            (WorkDI->ED2_HAWB<>aArrayAux[2] .or. WorkDI->ED2_INVOIC<>aArrayAux[3] .or. ;
            WorkDI->ED2_PO_NUM<>aArrayAux[4] .or. WorkDI->ED2_POSICA<>aArrayAux[5] .or. ;
            WorkDI->ED2_PGI_NU<>aArrayAux[6] .or. !Empty(WorkDI->ED2_RE) .or.;
            !Empty(WorkDI->ED2_PROD) .or. WorkDI->(RecNo())=nRecAux .or. WorkDI->MARCA==cMarca)
               WorkDI->(dbSkip())
            EndDo
            If WorkDI->ED2_ITEM==aArrayAux[1] .and. WorkDI->ED2_HAWB==aArrayAux[2] .and. ;
            WorkDI->ED2_INVOIC==aArrayAux[3] .and. WorkDI->ED2_PO_NUM==aArrayAux[4] .and. ;
            WorkDI->ED2_POSICA==aArrayAux[5] .and. WorkDI->ED2_PGI_NU==aArrayAux[6] .and. ;
            Empty(WorkDI->ED2_RE) .and. Empty(WorkDI->ED2_PROD) .and. WorkDI->MARCA<>cMarca .and.;
            WorkDI->(RecNo())<>nRecAux
               If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)+=aArrayAux[7]
               WorkDI->ED2_VALEMB += aArrayAux[8]
               WorkDI->ED2_VL_MOE += aArrayAux[9]
               nRecAux2:=WorkDI->(RecNo())
               WorkDI->(dbGoTo(nRecAux))
               WorkDI->(RecLock("WorkDI",.F.,.T.))
               WorkDI->(DBDELETE())
               WorkDI->(msUnlock())
               WorkDI->(dbGoTo(nRecAux2))
               oMarkDI:oBrowse:Refresh()
            Else
               WorkDI->(dbGoTo(nRecAux))
            EndIf
         Else
            WorkDI->(dbGoTo(nRecAux))
         EndIf
         WorkDI->ED2_RE  := ""
         WorkDI->ED2_PROD:= ""
         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTRE")) > 0
            WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
         ENDIF

         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
            WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
         ENDIF
         oMUserEDC:Solta("ATO","DESMARCA_DI")  // PLB 27/11/06 - Destrava os registros refentes ao Item no objeto
      Else
         //EE9->(dbSeek(cFilEE9+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN))
         //EE9->(msUnlock())
         oMUserEDC:Solta("ATO","DESMARCA_RE")  // PLB 27/11/06 - Destrava os registros refentes ao Produto no objeto
      EndIf
   EndIf
Else
   ProcRegua((cAlias)->(EasyRecCount()))
   (cAlias)->(dbGoTop())
   lPrim := .T.
   If (cAlias)->MARCA <> cMarca
      Do While !(cAlias)->(EOF())
         IncProc(STR0071) //"Processando..."
         If (cAlias)->MARCA == cMarca
            (cAlias)->(dbSkip())
            Loop
         EndIf
         (cAlias)->MARCA := cMarca
         If cAlias=="WorkDI"
            ACGetAnt()
            If !Empty(WorkDI->ED2_RE) .and. !Empty(WorkDI->ED2_PROD) .and.;
            WorkExpl->(dbSeek(iif(lED2Inat,If(Empty(WorkDI->ED2_INAT),WorkDI->ED2_ITEM,WorkDI->ED2_INAT),WorkDI->ED2_ITEM)+WorkDI->ED2_RE+WorkDI->ED2_PROD))  // ACSJ - 17/11/2004
               If SB1->B1_FILIAL<>cFilSB1 .or. SB1->B1_COD<>WorkDI->ED2_ITEM
                  SB1->(dbSeek(cFilSB1+WorkDI->ED2_ITEM))
               EndIf

               // ** AAF 10/08/2006 - Volta da quantidade convertida para a Unidade Estatistica de acordo com o criterio da baixa.
               If ! AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
                  nQtdAux := AVTransUnid(WorkDI->UNID,SB1->B1_UM,WorkDI->ED2_ITEM,If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD))
               Else
                  nQtdAux := WorkDI->ED2_PESO
               Endif
               // **

               WorkExpl->QUANT2 -= nQtdAux
               If WorkExpl->QUANT2 < 0
                  lMens2:=.T.
                  WorkDI->MARCA := ""
                  WorkDI->ED2_RE  := ""
                  WorkDI->ED2_PROD:= ""
                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                     WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
                  ENDIF

                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                     WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
                  ENDIF
                  WorkExpl->QUANT2 += nQtdAux
               EndIf
            EndIf
            If WorkDI->MARCA == cMarca
               If Empty(WorkDI->ED2_ADICAO)
                  lMens3:=.T.
                  WorkDI->MARCA := ""
                  WorkDI->ED2_RE  := ""
                  WorkDI->ED2_PROD:= ""
                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                     WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
                  ENDIF

                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                     WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
                  ENDIF
                  WorkExpl->QUANT2 += nQtdAux
               ElseIf !Empty(WorkDI->MENSA) .and. Left(WorkDI->MENSA,6) <> STR0183 //"Aviso:"
                  lMens5:=.T.
                  WorkDI->MARCA := ""
                  WorkDI->ED2_RE  := ""
                  WorkDI->ED2_PROD:= ""
                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                     WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
                  ENDIF

                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                     WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
                  ENDIF
                  WorkExpl->QUANT2 += nQtdAux
               ElseIf !Empty(WorkDI->MENSA) .and. Left(WorkDI->MENSA,6) == STR0183 //"Aviso:"
                  lMens6:=.T.
               Else
                  If SYD->YD_FILIAL <> cFilSYD .or. WorkDI->ED2_NCM <> SYD->YD_TEC
                     SYD->(dbSetOrder(1))
                     SYD->(dbSeek(cFilSYD+WorkDI->ED2_NCM))
                  EndIf
                  If Empty(SYD->YD_UNID)
                     lMens4 := .T.
                     WorkDI->MARCA := ""
                     WorkDI->ED2_RE  := ""
                     WorkDI->ED2_PROD:= ""
                     //AOM - 14/03/2012
                     IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                        WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
                     ENDIF

                     //AOM - 14/03/2012
                     IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                        WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
                     ENDIF
                     WorkExpl->QUANT2 += nQtdAux
                  EndIf
               EndIf
               If WorkDI->MARCA == cMarca
                  //If (SW8->(dbSeek(cFilSW8+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU)) .and. !SoftLock("SW8")) .OR.;
                  //(ED8->(dbSeek(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA)) .and. !SoftLock("ED8"))

                  // PLB 27/11/06 - Bloqueio de registros pelo objeto
                  //If (SW8->(dbSeek(cFilSW8+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))  .OR.;
                  //    ED8->(dbSeek(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA)))  .And.  !oMUserEDC:Reserva("ATO","MARCA_DI")
                  If lMultiFil
                     cFilAux := Left((cAlias)->ED2_FILORI,2)
                  Else
                     cFilAux := cFilSW8
                  EndIf
                  If (SW8->(dbSeek(cFilAux+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))  .OR.;
                      ED8->(dbSeek(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA)))  .And.  !oMUserEDC:Reserva("ATO","MARCA_DI")
                     //lMens1 := .T.
                     WorkDI->MARCA := ""
                     WorkDI->ED2_RE  := ""
                     WorkDI->ED2_PROD:= ""
                     //AOM - 14/03/2012
                     IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                        WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
                     ENDIF

                     //AOM - 14/03/2012
                     IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                        WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
                     ENDIF
                     WorkExpl->QUANT2 += nQtdAux
                  EndIf
               EndIf
            EndIf
         Else
            If !SG1->(dbSeek(cFilSG1+WorkRE->ED1_PROD))
               cMensa+= If(lPrim, Alltrim(WorkRE->ED1_PROD), ", "+Alltrim(WorkRE->ED1_PROD))
            Endif
            //EE9->(dbSeek(cFilEE9+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN))
            //If !SoftLock("EE9")
               //lMens1 := .T.
            If SYD->YD_FILIAL <> cFilSYD .or. WorkRE->ED1_NCM <> SYD->YD_TEC
               SYD->(dbSetOrder(1))
               SYD->(dbSeek(cFilSYD+WorkRE->ED1_NCM))
            EndIf
            If Empty(SYD->YD_UNID)
               lMens4 := .T.
               WorkRE->MARCA := ""
            ElseIf !Empty(WorkRE->MENSA) .and. Left(WorkRE->MENSA,6) <> STR0183 //"Aviso:"
               lMens5 := .T.
               WorkRE->MARCA := ""
            EndIf
            //EE9->(msUnlock())
            // PLB 27/11/06 - Bloqueio de registros pelo objeto
            If (cAlias)->MARCA == cMarca  .And.  !oMUserEDC:Reserva("ATO","MARCA_RE")
               WorkRE->MARCA := ""
            EndIf
         EndIf
         lPrim := .F.
         (cAlias)->(dbSkip())
      EndDo
      If !Empty(cMensa)
         MsGInfo(STR0291 +Alltrim(cMensa)+" está(ão) sem estrutura no Cadastro.") //LRL 27/01/04 Help(" ",1,"AVG0005272",,Alltrim(cMensa)+" está(ão) sem estrutura no Cadastro.", 1,17) // "O(s) produto(s) "+cMensa+ " está(ão) sem estrutura no Cadastro.", "Mensagem")
      EndIf
   Else
      Do While !(cAlias)->(EOF())
         IncProc(STR0071) //"Processando..."
         If (cAlias)->MARCA <> cMarca
            (cAlias)->(dbSkip())
            Loop
         EndIf
         (cAlias)->MARCA := ""
         If cAlias=="WorkDI"
            If !Empty(WorkDI->ED2_RE) .and. !Empty(WorkDI->ED2_PROD) .and.;
            WorkExpl->(dbSeek(iif(lED2Inat,If(Empty(WorkDI->ED2_INAT),WorkDI->ED2_ITEM,WorkDI->ED2_INAT),WorkDI->ED2_ITEM)+WorkDI->ED2_RE+WorkDI->ED2_PROD))  // ACSJ - 17/11/2004
               If SB1->B1_FILIAL<>cFilSB1 .or. SB1->B1_COD<>WorkDI->ED2_ITEM
                  SB1->(dbSeek(cFilSB1+WorkDI->ED2_ITEM))
               EndIf

               // ** AAF 10/08/2006 - Volta da quantidade convertida para a Unidade Estatistica de acordo com o criterio da baixa.
               If ! AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
                  nQtdAux := AVTransUnid(WorkDI->UNID,SB1->B1_UM,WorkDI->ED2_ITEM,If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD))
               Else
                  nQtdAux := WorkDI->ED2_PESO
               Endif
               // **

               WorkExpl->QUANT2 += nQtdAux
               /*If SW8->(dbSeek(cFilSW8+(cAlias)->ED2_HAWB+(cAlias)->ED2_INVOIC+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
                  SW8->(msUnLock())
               ElseIf lDiExt
                  ED8->( dbSetOrder(4) )
                  If ED8->(dbSeek(cFilED8+(cAlias)->ED2_DI_NUM+(cAlias)->ED2_ADICAO+(cAlias)->ED2_POSICA))
                     ED8->(msUnLock())
                  EndIf
               EndIf*/
            EndIf
            nRecAux:=WorkDI->(RecNo())
            aArrayAux:={WorkDI->ED2_ITEM,WorkDI->ED2_HAWB,WorkDI->ED2_INVOIC,WorkDI->ED2_PO_NUM,;
                        WorkDI->ED2_POSICA,WorkDI->ED2_PGI_NU,If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD),;
                        WorkDI->ED2_VALEMB,WorkDI->ED2_VL_MOE}
            If WorkDI->(dbSeek(WorkDI->ED2_ITEM))
               Do While !WorkDI->(EOF()) .and. WorkDI->ED2_ITEM==aArrayAux[1] .and. ;
               (WorkDI->ED2_HAWB<>aArrayAux[2] .or. WorkDI->ED2_INVOIC<>aArrayAux[3] .or. ;
               WorkDI->ED2_PO_NUM<>aArrayAux[4] .or. WorkDI->ED2_POSICA<>aArrayAux[5] .or. ;
               WorkDI->ED2_PGI_NU<>aArrayAux[6] .or. !Empty(WorkDI->ED2_RE) .or.;
               !Empty(WorkDI->ED2_PROD) .or. WorkDI->(RecNo())=nRecAux .or. WorkDI->MARCA==cMarca)
                  WorkDI->(dbSkip())
               EndDo
               If WorkDI->ED2_ITEM==aArrayAux[1] .and. WorkDI->ED2_HAWB==aArrayAux[2] .and. ;
               WorkDI->ED2_INVOIC==aArrayAux[3] .and. WorkDI->ED2_PO_NUM==aArrayAux[4] .and. ;
               WorkDI->ED2_POSICA==aArrayAux[5] .and. WorkDI->ED2_PGI_NU==aArrayAux[6] .and. ;
               Empty(WorkDI->ED2_RE) .and. Empty(WorkDI->ED2_PROD) .and. WorkDI->MARCA<>cMarca .and.;
               WorkDI->(RecNo())<>nRecAux
                  If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)+=aArrayAux[7]
                  WorkDI->ED2_VALEMB += aArrayAux[8]
                  WorkDI->ED2_VL_MOE += aArrayAux[9]
                  WorkDI->(dbGoTo(nRecAux))
                  WorkDI->(RecLock("WorkDI",.F.,.T.))
                  WorkDI->(DBDELETE())
                  WorkDI->(msUnlock())
               Else
                  WorkDI->(dbGoTo(nRecAux))
               EndIf
            Else
               WorkDI->(dbGoTo(nRecAux))
            EndIf
            WorkDI->ED2_RE  := ""
            WorkDI->ED2_PROD:= ""
            //AOM - 14/03/2012
            IF ED2->(FIELDPOS("ED2_DTRE")) > 0
               WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
            ENDIF

            //AOM - 14/03/2012
            IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
               WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
            ENDIF
            oMUserEDC:Solta("ATO","DESMARCA_DI")  // PLB 27/11/06 - Destrava os registros refentes ao Item no objeto
         Else
            //EE9->(dbSeek(cFilEE9+(cAlias)->ED1_PREEMB+(cAlias)->ED1_PEDIDO+(cAlias)->ED1_SEQUEN))
            //EE9->(msUnlock())
            oMUserEDC:Solta("ATO","DESMARCA_RE")  // PLB 27/11/06 - Destrava os registros refentes ao Produto no objeto
         EndIf
         (cAlias)->(dbSkip())
      EndDo
   EndIf
EndIf

//If lMens1
//   Help(" ",1,"AVG0005157") //"Algum(s) item(s) nao pode(m) ser marcado(s) pois esta(o) sendo usado(s) em outra Apuracao."
If lMens2
   Help(" ",1,"AVG0005158") //"Algum(s) item(s) nao pode(m) ser marcado(s) pois esta(o) sendo usado(s) em outra Apuracao ou estoura(m) o limite permitido."
ElseIf lMens3
   Help(" ",1,"AVG0005159") //"Algum(s) item(s) nao pode(m) ser marcado(s) pois nao tem Adicao. Selecione Individualmente."
ElseIf lMens4
   Help(" ",1,"AVG0005160") //"Algum(s) item(s) nao pode(m) ser marcado(s) pois sua(s) NCM(s) nao possui(em) Unidade de Medida."
ElseIf lMens5
   Help(" ",1,"AVG0005296") //MsgInfo(STR0202) //"Algum(s) item(s) nao pode(m) ser marcado(s). Selecione Individualmente."
ElseIf lMens6
   MsgInfo(STR0203) //"Algum(s) item(s) esta(ão) com o(s) Valor(es) desatualizado(s) ou com o(s) Valor(es) atualizados, porém este(s) é(são) menor(es) que o(s) Valor(es) no Embarque."
EndIf

Return .T.

*-------------------------*
Static Function ExplodeRE()
*-------------------------*
Local fEstru, nPos, aPerg:={}, nPosP, cItemGen:=""
Local cProduto:= ""

SG1->(dbSetOrder(1))
SB1->(dbSetOrder(1))

WorkRE->(dbGoTop())
Do While !WorkRE->(EOF())
   If WorkRE->MARCA == cMarca
      cProduto:= IG400BuscaItem("E", WorkRE->ED1_PROD) //wfs 02/01/14 - tratamento para item alternativo de exportação
      //If SG1->(dbSeek(cFilSG1+WorkRE->ED1_PROD))
      If SG1->(dbSeek(cFilSG1+cProduto))
         nEstru:=0
         //fEstru := AVEstrut2(WorkRE->ED1_PROD,WorkRE->ED1_QTD,"WorkEstru")
         fEstru := AVEstrut2(cProduto,WorkRE->ED1_QTD,"WorkEstru")
         ProcRegua(WorkEstru->(EasyRecCount()))
         WorkEstru->(dbGoTop())
         Do While !WorkEstru->(EOF())
            IncProc(STR0121+Alltrim(WorkEstru->COMP)) //"Apurando para Item "
            If WorkEstru->QUANT > 0
               /*
               AC400GrvEDA(INCLUIR,BuscaItemGen(WorkEstru->COMP),0,WorkEstru->QUANT,cMarca)
               AC400EDCGrv(INCLUIR,BuscaItemGen(WorkEstru->COMP),WorkRE->ED1_RE,WorkRE->ED1_PROD,0,WorkEstru->QUANT,cMarca)
               */
               If WorkExpl->(dbSeek(WorkEstru->COMP+WorkRE->ED1_RE+WorkRE->ED1_PROD))
                  WorkExpl->QUANT1+=WorkEstru->QUANT
                  WorkExpl->QUANT2+=WorkEstru->QUANT
               Else
                  WorkExpl->(RecLock("WorkExpl",.T.))
                  WorkExpl->ITEM   := WorkEstru->COMP
                  WorkExpl->RE     := WorkRE->ED1_RE
                  WorkExpl->PROD   := WorkRE->ED1_PROD
                  WorkExpl->QUANT1 := WorkEstru->QUANT
                  WorkExpl->QUANT2 := WorkEstru->QUANT
                  If lTemVLCOMPE
                     WorkExpl->VLCOMPE:= WorkEstru->VLCOMPE
                  Endif
                  WorkExpl->QTD    := WorkRE->ED1_QTD
                  WorkExpl->DT_RE  := WorkRE->ED1_DTRE

                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                     WorkExpl->ED2_DTEMBA  := WorkRE->ED1_DTEMBA
                  EndIf

                  If lLeadTime
                     WorkExpl->LEADTIME:=WorkEstru->LEADTIME
                     WorkExpl->PRODUC  :=WorkEstru->PRODUC
                  EndIf

                  WorkExpl->(msUnlock())
               EndIf
            EndIf
            WorkEstru->(dbSkip())
         EndDo
         AvFimEstrut2("WorkEstru",fEstru)
      Else
         nPosP:=ASCAN(aPerg,{|x| x[1]==WorkRE->ED1_PROD})
         If nPosP = 0
            If SB1->(dbSeek(cFilSB1+WorkRE->ED1_PROD))
               aAdd(aPerg,{WorkRE->ED1_PROD,"S"})
               AC400GrvEDA(INCLUIR,IG400BuscaItem("I",SB1->B1_COD,M->ED0_PD),0,WorkRE->ED1_QTD,cMarca)
               AC400EDCGrv(INCLUIR,IG400BuscaItem("I",SB1->B1_COD,M->ED0_PD),WorkRE->ED1_RE,WorkRE->ED1_PROD,0,WorkRE->ED1_QTD,cMarca)
               If WorkExpl->(dbSeek(SB1->B1_COD+WorkRE->ED1_RE+WorkRE->ED1_PROD))
                  WorkExpl->QUANT1+=WorkRE->ED1_QTD
                  WorkExpl->QUANT2+=WorkRE->ED1_QTD
               Else
                  WorkExpl->(RecLock("WorkExpl",.T.))
                  WorkExpl->ITEM  := SB1->B1_COD
                  WorkExpl->RE    := WorkRE->ED1_RE
                  WorkExpl->PROD  := WorkRE->ED1_PROD
                  WorkExpl->QUANT1:= WorkRE->ED1_QTD
                  WorkExpl->QUANT2:= WorkRE->ED1_QTD
                  WorkExpl->QTD   := WorkRE->ED1_QTD
                  WorkExpl->DT_RE := WorkRE->ED1_DTRE
                  //AOM - 14/03/2012
                  IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                     WorkExpl->ED2_DTEMBA  := WorkRE->ED1_DTEMBA
                  EndIf
                  WorkExpl->(msUnlock())
               EndIf
            Else
               aAdd(aPerg,{WorkRE->ED1_PROD,"N"})
            EndIf
         ElseIf aPerg[nPosP,2] == "S"
            AC400GrvEDA(INCLUIR,IG400BuscaItem("I",SB1->B1_COD,M->ED0_PD),0,WorkRE->ED1_QTD,cMarca)
            AC400EDCGrv(INCLUIR,IG400BuscaItem("I",SB1->B1_COD,M->ED0_PD),WorkRE->ED1_RE,WorkRE->ED1_PROD,0,WorkRE->ED1_QTD,cMarca)
            If WorkExpl->(dbSeek(WorkRE->ED1_PROD+WorkRE->ED1_RE+WorkRE->ED1_PROD))
               WorkExpl->QUANT1+=WorkRE->ED1_QTD
               WorkExpl->QUANT2+=WorkRE->ED1_QTD
            EndIf
         EndIf
      EndIf
   EndIf
   WorkRE->(dbSkip())
EndDo
DbSelectArea("WorkEDA")
//oMark5:oBrowse:Refresh()- AOM - 27/10/10
oMark7:oBrowse:Refresh()

Return .T.

*----------------------------------------------------------------------------------------------*
Function AC400SelDI(lExp,cProdAp,cNcmAp,cDI,dDtIni,dDtFim,cPedido,nTpImp)
*----------------------------------------------------------------------------------------------*
Local nCod, cCond:="", lPVez:=.T., nPos := 0, cItemGen:="", aItemAp:={}
Local nOrdSW2 := SW2->(IndexOrd()), nOrdSW6 := SW6->(IndexOrd()), nOrdSW7 := SW7->(IndexOrd()),;
      nOrdSW8 := SW8->(IndexOrd()), nOrdSW9 := SW9->(IndexOrd()), nOrdSA5 := SA5->(IndexOrd()),;
      nOrdSY6 := SY6->(IndexOrd()), nInd
Local aCondDel:={"AND SW6.D_E_L_E_T_ <> '*' ","AND SW8.D_E_L_E_T_ <> '*' ",;
                 "AND SA5.D_E_L_E_T_ <> '*' ","AND SW9.D_E_L_E_T_ <> '*' ",;
                 "AND SY6.D_E_L_E_T_ <> '*' ","AND SW2.D_E_L_E_T_ <> '*' ",;
                 "AND SW7.D_E_L_E_T_ <> '*' ","AND ED8.D_E_L_E_T_ <> '*' "}
LOCAL i
LOCAL cCondPesoI := ""

Default cPedido := "", nTpImp := 3   // 3 - Todos

Private cQuery
FWorkDI2:=E_Create(,.F.)
FWorkDI3:=E_Create(,.F.)
FWorkDI4:=E_Create(,.F.)
FWorkDI :=E_CriaTrab(, aSemSX3DI, "WorkDI")

If lTop


      IndRegua("WorkDI",FWorkDI+TEOrdBagExt() ,"ED2_ITEM+DTOS(ED2_DTREG)+ED2_RE")//AAF 16/05/05 - Adicionado RE.
      IndRegua("WorkDI",FWorkDI2+TEOrdBagExt(),"ED2_RE+ED2_PROD+DTOS(ED2_DTREG)+ED2_DI_NUM")
      IndRegua("WorkDI",FWorkDI3+TEOrdBagExt(),"ED2_DI_NUM+ED2_ITEM+DTOS(ED2_DTREG)")
      //IndRegua("WorkDI",FWorkDI4+OrdBagExt(),"DESCEND(DTOS(DATAANT))")
      IndRegua("WorkDI",FWorkDI4+TEOrdBagExt(),"DTOS(DATAANT)")
      SET INDEX TO (FWorkDI+TEOrdBagExt()),(FWorkDI2+TEOrdBagExt()),(FWorkDI3+TEOrdBagExt()),(FWorkDI4+TEOrdBagExt())
      WorkDI->(dbSetOrder(1))

   // *** GFP - Condição para não efetuar Query quando opção for 2 (Compras Nacionais)
   If nTpImp <> 2                // Opção 1 - DI

      If lMultiFil
         cCond+="SW6.W6_FILIAL IN ("+cFil+") "
      Else
         cCond+="SW6.W6_FILIAL='"+cFilSW6+"' "
      EndIf

      cCond+=If(TcSrvType()<>"AS/400",aCondDel[1],"")

      //cCond+="AND (SW6.W6_TIPOFEC <> 'DIN' AND SW6.W6_TIPOFEC <> 'DA') "
      // **AAF 27/10/2006 - Permitir associação de DI's desembaraçadas a partir de entreposto.
      cCond+="AND SW6.W6_TIPOFEC <> 'DA' "
      // **

      If(!lExp .and. !Empty(Alltrim(cDI)),cCond+="AND SW6.W6_DI_NUM='"+cDI+"' ",)
      cCond+="AND SW6.W6_DI_NUM <> ' ' AND SW6.W6_TX_US_D <> 0 "
      cCond+="AND SW6.W6_DTREG_D>='"+GeraValAto(If(nVal_Ato>=1,1,2))+"' "
      If(dDtIni<>NIL,cCond+="AND SW6.W6_DTREG_D>='"+DtoS(dDtIni)+"' AND SW6.W6_DTREG_D<='"+DtoS(dDtFim)+"' ",)
     //cCond+="AND SW6.W6_HAWB=SW8.W8_HAWB AND SW8.W8_FILIAL='"+cFilSW8+"' "
      cCond+="AND SW6.W6_HAWB=SW8.W8_HAWB "
      If lMultiFil
         cCond+="AND SW8.W8_FILIAL = SW6.W6_FILIAL "
      Else
         cCond+="AND SW8.W8_FILIAL='"+cFilSW8+"' "
      EndIf
      cCond+=If(TcSrvType()<>"AS/400",aCondDel[2],"")
      If lExp
         cCond+="AND ( "
         WorkExpl->(dbGoTop())
         Do While !WorkExpl->(EOF())
            If aScan(aItemAp,WorkExpl->ITEM) = 0
               If lPVez
                  cCond+="SW8.W8_COD_I = '"+WorkExpl->ITEM+"' "
                  lPVez:=.F.
               Else
                  cCond+="OR SW8.W8_COD_I = '"+WorkExpl->ITEM+"' "
               EndIf
               aAdd(aItemAp,WorkExpl->ITEM)
            EndIf
            cItemGen:=IG400BuscaItem("I",WorkExpl->ITEM,M->ED0_PD)  // PLB 16/11/06
            If cItemGen <> WorkExpl->ITEM
               If aScan(aItemAp,cItemGen) = 0
                  cCond+="OR SW8.W8_COD_I = '"+cItemGen+"' "
                  aAdd(aItemAp,cItemGen)
               EndIf
            EndIF
            WorkExpl->(dbSkip())
         EndDo
         cCond+=") "
      Else
         If(!Empty(Alltrim(cProdAp)),cCond+="AND SW8.W8_COD_I='"+cProdAp+"' ",)
         If(!Empty(Alltrim(cNcmAp)),cCond+="AND SW8.W8_TEC='"+cNcmAp+"' ",)
      EndIf
      cCond+="AND (SW8.W8_ACISEN = ' ' OR (SW8.W8_ISENTOT = 'N' AND SW8.W8_SALISEN > 0)) "
      cCond+="AND SW8.W8_COD_I=SA5.A5_PRODUTO 
      cCond+="AND SW8.W8_FABR=SA5.A5_FABR "
      cCond+="AND SW8.W8_FORN=SA5.A5_FORNECE AND SA5.A5_FILIAL='"+cFilSA5+"' "
      cCond+=If(TcSrvType()<>"AS/400",aCondDel[3],"")
      //TDF 06/12/2010 - ACRESCENTA O HAWB NA CONDIÇÃO DA QRY
      cCond+="AND SW9.W9_INVOICE=SW8.W8_INVOICE AND SW9.W9_FORN=SW8.W8_FORN AND SW9.W9_HAWB=SW8.W8_HAWB "
      If lMultiFil
         cCond+="AND SW9.W9_FILIAL=SW6.W6_FILIAL "+If(TcSrvType()<>"AS/400",aCondDel[4],"")
      Else
         cCond+="AND SW9.W9_FILIAL='"+cFilSW9+"' "+If(TcSrvType()<>"AS/400",aCondDel[4],"")
      EndIf
      cCond+="AND SY6.Y6_COD=SW9.W9_COND_PA AND SY6.Y6_TIPOCOB<>'4' "
      cCond+="AND SY6.Y6_FILIAL='"+cFilSY6+"' "+If(TcSrvType()<>"AS/400",aCondDel[5],"")
      cCond+="AND SW2.W2_PO_NUM=SW8.W8_PO_NUM "
      If lMultiFil
         cCond+="AND SW2.W2_FILIAL=SW6.W6_FILIAL "
      Else
         cCond+="AND SW2.W2_FILIAL='"+cFilSW2+"' "
      EndIf
      cCond+=If(TcSrvType()<>"AS/400",aCondDel[6],"")
      cCond+="AND SW7.W7_HAWB=SW8.W8_HAWB "
      If lMultiFil
         cCond+="AND SW7.W7_FILIAL=SW6.W6_FILIAL "
      Else
         cCond+="AND SW7.W7_FILIAL='"+cFilSW7+"' "
      EndIf
      cCond+=If(TcSrvType()<>"AS/400",aCondDel[7],"")
      cCond+="AND SW7.W7_PO_NUM=SW8.W8_PO_NUM AND SW7.W7_POSICAO=SW8.W8_POSICAO "
      cCond+="AND SW7.W7_PGI_NUM=SW8.W8_PGI_NUM "

      // ** AAF 05/07/05 - Verifica se a NCM pode ser usada em Drawback.
      If SYD->( FieldPos("YD_PER_AC") ) > 0
         cCond+= " AND SYD.YD_FILIAL = '"+cFilSYD+"' AND SYD.YD_TEC = SW8.W8_TEC AND SYD.YD_EX_NCM = SW8.W8_EX_NCM "
         cCond+= " AND SYD.YD_EX_NBM  = SW8.W8_EX_NBM AND SYD.YD_PER_AC <> '2'"
      Endif
      // **
      
      cCondPesoI += "LEFT OUTER JOIN "
      cCondPesoI += "( SELECT WN_FILIAL, WN_HAWB, WN_PGI_NUM, WN_PO_EIC, WN_INVOICE, WN_ITEM, sum(WN_PESOL) PESOITPRC from "+RetSqlName("SWN")+" "
      cCondPesoI += "WHERE WN_TIPO_NF = '1' and D_E_L_E_T_ = ' ' "
      cCondPesoI += "GROUP BY WN_FILIAL, WN_HAWB, WN_PGI_NUM, WN_PO_EIC, WN_INVOICE, WN_ITEM ) SWN "
      cCondPesoI += "ON "+If( lMultifil, "WN_FILIAL = W8_FILIAL ", "WN_FILIAL in ('"+cFilSWN+"') " )
      cCondPesoI += "AND WN_HAWB = W8_HAWB and WN_PGI_NUM = W8_PGI_NUM and WN_PO_EIC = W8_PO_NUM and W8_INVOICE = WN_INVOICE and W8_POSICAO = WN_ITEM "
      cCondPesoI += "LEFT OUTER JOIN "
      cCondPesoI += "( SELECT WN_FILIAL, WN_HAWB, sum(WN_PESOL) PESOITNFE from "+RetSqlName("SWN")+" "
      cCondPesoI += "GROUP BY WN_FILIAL, WN_HAWB ) SWN2 ON "+If( lMultifil, "SWN2.WN_FILIAL = W8_FILIAL ", "SWN2.WN_FILIAL in ('"+cFilSWN+"') " )+" AND SWN2.WN_HAWB = W8_HAWB " 
      
      cQuery:= "SELECT DISTINCT '  ' MARCA, SW8.W8_COD_I ED2_ITEM, SW8.W8_TEC ED2_NCM, SW8.W8_AC AC, "+;
               "SW8.W8_QTDE ED2_QTD, SW7.W7_PESO ED2_PESO, SW6.W6_DI_NUM ED2_DI_NUM, "+;
               "0.0 ED2_VALEMB, SW6.W6_DTREG_D ED2_DTREG, SW6.W6_DT_NF ED2_DT_NF, SW8.W8_FORN FORN, (SW8.W8_PRECO*SW8.W8_QTDE) ED2_VL_MOE, "+;
               "SW8.W8_HAWB ED2_HAWB, SW9.W9_MOE_FOB ED2_MOEDA, SW9.W9_FREINC FREINC, SW9.W9_FRETEIN FRETEIN, "+;
               IF(lSegInc,"SW9.W9_SEGINC SEGINC, SW9.W9_SEGURO SEGURIN, ", "")+;    // EOB 13/06/08 - Inclusão dos campos de seguro da invoice
               "SW9.W9_TX_FOB ED2_TX_MOE, SW8.W8_PO_NUM ED2_PO_NUM, SW8.W8_POSICAO ED2_POSICA, "+;
               "SW8.W8_PGI_NUM ED2_PGI_NU, SW8.W8_INVOICE ED2_INVOIC, SW8.W8_FABR FABR, "+;
               "SW2.W2_IMPORT IMP, SW8.W8_ADICAO ED2_ADICAO, SW6.W6_TX_US_D ED2_TX_USS, "+;
               "SW8.W8_UNID UNID, "+/*SW6.W6_TIPOFEC TIPOFEC*/" SA5.A5_UNID UNID_A5, SW8.W8_ISENTOT ISENTOT, "+;
               "SW8.W8_SALISEN SALISEN, ((SW8.W8_PRECO*SW8.W8_QTDE*SW9.W9_TX_FOB)/SW6.W6_TX_US_D) ED2_VLORIT, 0.0 ED2_VALORI, "+;
               "SW8.W8_FRETEIN ED2_FRETE, (SW6.W6_VLFRECC+SW6.W6_VLFREPP) FRETE, SW6.W6_VL_USSE SEGURO, SW8.W8_QTDE QTDORITOT "//AAF - 07/12/05 - Quantidade Total na DI
      If lMultiFil
         cQuery += ", SW8.W8_FILIAL ED2_FILORI "
      EndIf

      cQuery += ", SW8.*, PESOITPRC, PESOITNFE "  //NCF - 31/07/2020 - Melhoria de performance

      cQuery+= "FROM "+RetSqlName("SW6")+" SW6, "+RetSqlName("SA5")+" SA5, "+;
               " "+RetSqlName("SW9")+" SW9, "+RetSqlName("SY6")+" SY6, "+RetSqlName("SW2")+" SW2, "+;
               " "+RetSqlName("SW7")+" SW7 "+;
               If(SYD->( FieldPos("YD_PER_AC") ) > 0,", "+RetSqlName("SYD")+" SYD ,","")+RetSqlName("SW8")+" SW8 "+cCondPesoI+" WHERE "+cCond //AAF 05/07/05

      If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"APURA_ITEM"),)  //TRP- 15/02/08- Inclusão de ponto de entrada

      cQuery:=ChangeQuery(cQuery)
      //AOM - 16/03/2012
      If Select("TRB") > 0
         TRB->( dbCloseArea() )
      Endif
      TcQuery cQuery ALIAS "TRB" NEW
      TcSetField("TRB","ED2_DTREG","D")
      if lED2Dt_Nf   // ACSJ - 17/11/2004
         TcSetField("TRB","ED2_DT_NF","D")
      Endif
      TcSetField("TRB","PESOITPRC" ,"N", AVSX3("WN_PESOL",3), AVSX3("WN_PESOL",4))
      TcSetField("TRB","PESOITNFE" ,"N", AVSX3("WN_PESOL",3), AVSX3("WN_PESOL",4))

      dbSelectArea("TRB")
      Do While !TRB->(EOF())


         WorkDI->(RecLock("WorkDI",.T.))
         FOR i := 1 TO FCount()
            WorkDI->&(TRB->(FIELDNAME(i))) := FieldGet(i)
         NEXT i
         If lMultiFil
            WorkDI->ED2_FILORI := TRB->ED2_FILORI + " - " + AvgFilName({TRB->ED2_FILORI})[1]
         EndIf

         //AOM - 11/11/11
         If AvFlags("SEQMI")
            WorkDI->ED2_IMPORT := "S"
         EndIf

         WorkDI->DATAANT := iif(lED2Dt_Nf,If(Empty(WorkDI->ED2_DT_NF),WorkDI->ED2_DTREG,WorkDI->ED2_DT_NF),WorkDI->ED2_DTREG)  // ACSJ - 17/11/2004
         WorkDI->TRB_ALI_WT:= "ED2"
         WorkDI->TRB_REC_WT:= ED2->(Recno())
         WorkDI->PESOITPRC := TRB->PESOITPRC
         WorkDI->PESOITNFE := TRB->PESOITNFE
         WorkDI->(msUnlock())

         If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"GRV_WORKDI"),) // TLM 23/01/2008

         TRB->(dbSkip())
      EndDo
      TRB->(dbCloseArea())
   EndIf

   // ** AAF 05/01/06 - Apuração de DIs Externas.
   //If lDiExt -  ChkFile("ED8",.F.)
     cCond:=""
     lPVez:=.T.
     nPos := 0

     cCond+="ED8.ED8_FILIAL= '"+cFilED8+"' "+If(TcSrvType()<>"AS/400",aCondDel[8],"")

     If nTpImp == 1
        If(!lExp .and. !Empty(Alltrim(cDI)),cCond+="AND ED8.ED8_DI_NUM='"+cDI+"' ",)
     ElseIf nTpImp == 2  .And.  AvFlags("COMPRAS NACIONAIS")
        If(!Empty(cPedido),cCond+=" AND ED8.ED8_PEDIDO = '"+cPedido+"' ",)
     EndIf

     cCond+="AND ED8.ED8_TX_USS <> 0 "

     If nTpImp == 1
        cCond+="AND ED8.ED8_DTREG >= '"+GeraValAto(If(nVal_Ato>=1,1,2))+"' "
        If(dDtIni<>NIL,cCond+="AND ED8.ED8_DTREG >= '"+DtoS(dDtIni)+"' AND ED8.ED8_DTREG <= '"+DtoS(dDtFim)+"' ",)
     EndIf

      If lExp
         cCond += " AND ( "
         For nInd := 1 To Len(aItemAp)
            If nInd == 1
               cCond+="ED8.ED8_COD_I = '"+aItemAp[nInd]+"' "
            Else
               cCond+="OR ED8.ED8_COD_I = '"+aItemAp[nInd]+"' "
            EndIf
         Next nInd
         cCond += ") "
      Else
         If(!Empty(Alltrim(cProdAp)),cCond += "AND ED8.ED8_COD_I ='"+cProdAp+"' ",)
         If(!Empty(Alltrim(cNcmAp)),cCond += "AND ED8.ED8_NCM = '"+cNcmAp+"' ",)
      EndIf

         cCond+="AND (ED8.ED8_ACISEN = '' OR ED8.ED8_ACISEN = ' ' OR "
         cCond+="(ED8.ED8_ISETOT = 'N' AND ED8.ED8_SALISE > 0)) "

         // ** AAF 05/07/05 - Verifica se a NCM pode ser usada em Drawback.
         If SYD->( FieldPos("YD_PER_AC") ) > 0
            cCond+= " AND SYD.YD_FILIAL = '"+cFilSYD+"' AND SYD.YD_TEC = ED8.ED8_NCM "
            cCond+= " AND SYD.YD_PER_AC <> '2'"
         Endif
         // **

         /*AOM - 15/10/10 - Filtro na Apuração para não considerar
                         registro da tabela ED8 sem numero de DI*/
         If nTpImp == 1
            cCond+=" AND ED8.ED8_DI_NUM <> '' "
         ElseIf nTpImp == 2 .And. AvFlags("COMPRAS NACIONAIS")
            cCond+=" AND ED8.ED8_PEDIDO <> '' "
         EndIf

         // *** GFP - 01/08/2011 - Inclusão dos campos de Nota Fiscal para Compras Nacionais
         cQuery:= "SELECT DISTINCT '  ' MARCA, ED8.ED8_COD_I ED2_ITEM, ED8.ED8_NCM ED2_NCM, ED8.ED8_AC AC, "+;
                  "ED8.ED8_QTD ED2_QTD, ED8.ED8_PESO ED2_PESO, ED8.ED8_DI_NUM ED2_DI_NUM, "+;
                  "0.0 ED2_VALEMB, 'ED8' ORIGEM"+; //LGS-10/12/2015
                  ", ED8.ED8_DTREG ED2_DTREG, ED8.ED8_EMISSA ED2_DT_NF, '' FORN, ED8_VALORI ED2_VL_MOE, "+;
                  "'' ED2_HAWB, ED8.ED8_MOEDA ED2_MOEDA, '0' FREINC, 0 FRETEIN, "+;
                  IF(lSegInc," '0' SEGINC, 0 SEGURIN, ", "")+; // EOB 13/06/08 - Inclusão dos campos de seguro da invoice
                  "ED8.ED8_TX_MOE ED2_TX_MOE,  ED8.ED8_POSDI ED2_POSICA, "+;
                  "ED8_LI_NUM ED2_PGI_NU, ED8.ED8_INVOIC ED2_INVOIC, '' FABR, "+;
                  "ED8.ED8_IMPORT IMP, ED8.ED8_ADICAO ED2_ADICAO, ED8.ED8_TX_USS ED2_TX_USS, "+;
                  "ED8.ED8_UM UNID, '' UNID_A5, ED8.ED8_ISETOT ISENTOT, "+;
                  "ED8.ED8_SALISE SALISEN, ED8.ED8_VALORI ED2_VALORI, "+;
                  "0 ED2_FRETE, ED8.ED8_FRETE FRETE, ED8.ED8_SEGURO SEGURO"

         If(ED8->(FieldPos("ED8_NF")    > 0),cQuery+= ", ED8.ED8_NF ED2_NF ", " ")
         If(ED8->(FieldPos("ED8_SERIE") > 0),cQuery+= ", ED8.ED8_SERIE ED2_SERIE ", " ")
         If(ED8->(FieldPos("ED8_FORN")  > 0),cQuery+= ", ED8.ED8_FORN ED2_FORN ", " ")
         If(ED8->(FieldPos("ED8_LOJA")  > 0),cQuery+= ", ED8.ED8_LOJA ED2_LOJA ", " ")

         //AOM - 01/03/2012
         If AvFlags("COMPRAS NACIONAIS")
            cQuery+= ", ED8.ED8_PEDIDO ED2_PO_NUM"
         EndIf

         If lMultiFil
            cQuery += ",ED8.ED8_FILIAL+'"+Space(18)+"' ED2_FILORI "
         EndIf

         cQuery+= "FROM "+RetSqlName("ED8")+" ED8 "+;
            If(SYD->( FieldPos("YD_PER_AC") ) > 0,", "+RetSqlName("SYD")+" SYD ","")+" WHERE "+cCond //AAF 05/07/05

         cQuery:=ChangeQuery(cQuery)

         //AOM - 16/03/2012
         If Select("TRB") > 0
            TRB->( dbCloseArea() )
         Endif
         TcQuery cQuery ALIAS "TRB" NEW
         TcSetField("TRB","ED2_DTREG","D")
         if lED2Dt_Nf   // ACSJ - 17/11/2004
            TcSetField("TRB","ED2_DT_NF","D")
         Endif

         dbSelectArea("TRB")
         Do While !TRB->(EOF())
          /*WorkDI->(RecLock("WorkDI",.T.))
            FOR i := 1 TO FCount()
               WorkDI->(FIELDNAME(i)) := FieldGet(i)
            NEXT i   */

            If AvFlags("SEQMI")

               If M->ED0_TIPINS == "2" .And. !EMPTY(TRB->ED2_PO_NUM)
                  TRB->(DbSkip())
   	              Loop
               ElseIf M->ED0_TIPINS == "3" .And. EMPTY(TRB->ED2_PO_NUM)
                  TRB->(DbSkip())
   	              Loop
               EndIf


            EndIf

            WorkDI->(DbAppend())

            AvReplace("TRB","WorkDI")

            //AOM - 11/11/11
            If AvFlags("SEQMI")
               If !EMPTY(WorkDI->ED2_PO_NUM)
                  WorkDI->ED2_IMPORT := "N"
               Else
                  WorkDI->ED2_IMPORT := "S"
               EndIf
            EndIf
            WorkDI->DATAANT := iif(lED2Dt_Nf,If(Empty(WorkDI->ED2_DT_NF),WorkDI->ED2_DTREG,WorkDI->ED2_DT_NF),WorkDI->ED2_DTREG)  // ACSJ - 17/11/2004
            WorkDI->TRB_ALI_WT:= "ED2"
            WorkDI->TRB_REC_WT:= 0

          //WorkDI->(msUnlock())

            If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"GRV_WORKDI"),) // TLM 23/01/2008

            TRB->(dbSkip())
         EndDo
         TRB->(dbCloseArea())
      //EndIf
      // **
      If Select("WorkDI") == 0
         dbSelectArea("WorkDI")
      EndIf
Else

   IndRegua("WorkDI",FWorkDI+TEOrdBagExt() ,"ED2_ITEM+DTOS(ED2_DTREG)+ED2_RE")//AAF 16/05/05 - Adicionado RE.
   IndRegua("WorkDI",FWorkDI2+TEOrdBagExt(),"ED2_RE+ED2_PROD+DTOS(ED2_DTREG)+ED2_DI_NUM")
   IndRegua("WorkDI",FWorkDI3+TEOrdBagExt(),"ED2_DI_NUM+ED2_ITEM+DTOS(ED2_DTREG)")
   IndRegua("WorkDI",FWorkDI4+TEOrdBagExt(),"DTOS(DATAANT)")
   SET INDEX TO (FWorkDI+TEOrdBagExt()),(FWorkDI2+TEOrdBagExt()),(FWorkDI3+TEOrdBagExt()),(FWorkDI4+TEOrdBagExt())
   WorkDI->(dbSetOrder(1))

   SW2->(DbSetOrder(1))
   SW6->(DbSetOrder(1))
   SW7->(DbSetOrder(4))
   SW8->(DbSetOrder(1))
   SW9->(DbSetOrder(1))
   SA5->(DbSetOrder(3))
   SY6->(DbSetOrder(1))

   SW6->(DbGotop())

   If lMultiFil
      bWhile := {||.T.}
   Else
      SW6->(DbSeek(cFilSW6,.T.))
      bWhile := { || SW6->W6_FILIAL == cFilSW6 }
   EndIf

   Do While !SW6->(EOF()) .And. Eval(bWhile)
      If lMultiFil
         If !(SW6->W6_FILIAL $ cFil)
            SW6->( DBSkip() )
            Loop
         EndIf
      EndIf
      MsProcTxt(STR0107+Alltrim(SW6->W6_HAWB)) //"Apurando Processo "
      If !Empty(SW6->W6_DI_NUM) .and. SW6->W6_TX_US_D <> 0 .and. ;
      Dtos(SW6->W6_DTREG_D) >= GeraValAto(If(nVal_Ato>=1,1,2))

         If SW6->W6_TIPOFEC == 'DIN' .or. SW6->W6_TIPOFEC == 'DA'
            SW6->(dbSkip())
            Loop
         EndIf
         If !lExp .and. !Empty(Alltrim(cDI))
            If SW6->W6_DI_NUM <> cDI
               SW6->(DbSkip())
               Loop
            Endif
         EndIf

         If lMultiFil
            SW8->(dbSeek(SW6->W6_FILIAL+SW6->W6_HAWB))
            bWhile := { || SW6->W6_FILIAL==SW8->W8_FILIAL }
         Else
            SW8->(dbSeek(cFilSW8+SW6->W6_HAWB))
            bWhile := { || cFilSW8==SW8->W8_FILIAL }
         EndIf
         Do While !SW8->(EOF()) .and. Eval(bWhile) .and. SW8->W8_HAWB==SW6->W6_HAWB
            If !lExp
               If !Empty(Alltrim(cProdAp))
                  If SW8->W8_COD_I <> cProdAp
                     SW8->(DbSkip())
                     Loop
                  Endif
               Endif
               If !Empty(Alltrim(cNcmAp))
                  If SW8->W8_TEC <> cNcmAp
                     SW8->(DbSkip())
                     Loop
                  Endif
               EndIf
            Else
               If !WorkExpl->(dbSeek(SW8->W8_COD_I))
                  SW8->(DbSkip())
                  Loop
               Endif
            Endif

            // ** AAF 05/07/05 - Verifica se a NCM pode ser usada em Drawback.
            If SYD->( FieldPos("YD_PER_AC") ) > 0 .AND. SYD->( dbSeek(cFilSYD+SW8->( W8_TEC+W8_EX_NCM+W8_EX_NBM ) ))
               If SYD->YD_PER_AC == "2"
                  SW8->( dbSkip() )
                  Loop
               EndIf
            Endif
            // **

            If Empty(SW8->W8_ACISEN) .or. (SW8->W8_ISENTOT=="N" .and. SW8->W8_SALISEN > 0)

               If SA5->(DbSeek(cFilSA5+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN))

                  If lMultiFil
                     cKeySW9 := SW6->W6_FILIAL+SW8->W8_INVOICE+SW8->W8_FORN
                  Else
                     cKeySW9 := cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN
                  EndIf
                  If SW9->(DbSeek(cKeySW9))

                     If SY6->(DbSeek(cFilSY6+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3,0))) .and. SY6->Y6_TIPOCOB <> '4' //AAF 01/07/05 - Adicionado os Dias da Condição de Pagamento.

                        If lMultiFil
                           cKeySW2 := SW6->W6_FILIAL+SW8->W8_PO_NUM
                        Else
                           cKeySW2 := cFilSW2+SW8->W8_PO_NUM
                        EndIf
                        If SW2->(DbSeek(cKeySW2))

                           If lMultiFil
                              cKeySW7 := SW6->W6_FILIAL+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM
                           Else
                              cKeySW7 := cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM
                           EndIf
                           If SW7->(DbSeek(cKeySW7))

                              // Grava na work
                              WorkDI->(RecLock("WorkDI",.T.))
                              WorkDI->MARCA      := '  '
                              WorkDI->ED2_ITEM   := SW8->W8_COD_I
                              WorkDI->ED2_NCM    := SW8->W8_TEC
                              WorkDI->ED2_QTD    := SW8->W8_QTDE
                              WorkDI->ED2_PESO   := SW7->W7_PESO
                              WorkDI->ED2_DI_NUM := SW6->W6_DI_NUM
                              if lED2Dt_Nf   // ACSJ - 17/11/2004
                                 WorkDI->ED2_DT_NF  := SW6->W6_DT_NF
                              Endif
                              WorkDI->ED2_VALEMB := 0
                              WorkDI->ED2_DTREG  := SW6->W6_DTREG_D
                              WorkDI->FORN       := SW8->W8_FORN
                              WorkDI->ED2_HAWB   := SW8->W8_HAWB
                              WorkDI->ED2_MOEDA  := SW9->W9_MOE_FOB
                              WorkDI->ED2_VL_MOE := (SW8->W8_PRECO*SW8->W8_QTDE)
                              WorkDI->ED2_TX_MOE := SW9->W9_TX_FOB
                              WorkDI->ED2_PO_NUM := SW8->W8_PO_NUM
                              WorkDI->ED2_POSICA := SW8->W8_POSICAO
                              WorkDI->ED2_PGI_NU := SW8->W8_PGI_NUM
                              WorkDI->ED2_INVOIC := SW8->W8_INVOICE
                              WorkDI->FABR       := SW8->W8_FABR
                              WorkDI->IMP        := SW2->W2_IMPORT
                              WorkDI->ED2_ADICAO := SW8->W8_ADICAO
                              WorkDI->ED2_TX_USS := SW6->W6_TX_US_D
                              WorkDI->UNID       := SW8->W8_UNID
                              //WorkDI->TIPOFEC    := SW6->W6_TIPOFEC
                              WorkDI->UNID_A5    := SA5->A5_UNID
                              WorkDI->ISENTOT    := SW8->W8_ISENTOT
                              WorkDI->SALISEN    := SW8->W8_SALISEN

                              //AAF - 10/11/05 - Valor Original.
                              WorkDI->ED2_VALORI := iif(SW8->W8_ISENTOT == "N", SW8->W8_PRECO*SW8->W8_SALISEN, SW8->W8_PRECO*SW8->W8_QTDE)
                              WorkDI->ED2_VLORIT := ((SW8->W8_PRECO*SW8->W8_QTDE*SW9->W9_TX_FOB)/SW6->W6_TX_US_D)

                              //AAF - 07/12/05 - Quantidade Total na DI
                              WorkDI->QTDORITOT  := SW8->W8_QTDE

                              WorkDI->ED2_FRETE  := SW8->W8_FRETEIN

                              // EOB - 13/06/08 - Gravação dos campos referente a seguro na invoice
                              IF lSegInc
                                 WorkDI->SEGINC  := SW9->W9_SEGINC
                              	 WorkDI->SEGURIN := SW9->W9_SEGURO
                              ENDIF

                              WorkDI->DATAANT    := If(Empty(SW6->W6_DT_NF),SW6->W6_DTREG_D,SW6->W6_DT_NF)
                              WorkDI->TRB_ALI_WT := "ED2"
                              WorkDI->TRB_REC_WT := ED2->(Recno())
                              If lMultiFil
                                 WorkDI->ED2_FILORI := SW6->W6_FILIAL + " - " + AvgFilName({SW6->W6_FILIAL})[1]
                              EndIf
                              //BHF - 28/01/09 - Despesas
                              WorkDI->INCOTERM   := SW9->W9_INCOTERM
		    	              WorkDI->INLAND     := SW8->W8_INLAND
	                          WorkDI->PACKING    := SW8->W8_PACKING
             	              WorkDI->OUTDESP    := SW8->W8_OUTDESP
	                          WorkDI->DESCONT    := SW8->W8_DESCONT

                              WorkDI->(msUnlock())
                           EndIf
                        Endif
                     Endif
                  Endif
               Endif
            Endif
            SW8->(dbSkip())
         EndDo
      Endif
      SW6->(DbSkip())
   Enddo

   SW2->(DbSetOrder(nOrdSW2))
   SW6->(DbSetOrder(nOrdSW6))
   SW7->(DbSetOrder(nOrdSW7))
   SW8->(DbSetOrder(nOrdSW8))
   SW9->(DbSetOrder(nOrdSW9))
   SA5->(DbSetOrder(nOrdSA5))
   SY6->(DbSetOrder(nOrdSY6))
Endif

//Anterioridade
WorkDI->(dbSetOrder(4))
//Processa({|| ValidaCGC("WorkDI")},STR0108) //"Apurando..."
Processa({|| AC400PApura("WorkDI")},STR0108) //"Apurando..."
WorkDI->(dbSetOrder(1))

If !WorkDI->(EOF()) .and. !WorkDI->(BOF())
   WorkDI->(dbGoTop())
   BrowseDI(If(lExp,"EXP","IMP"))
ElseIf lExp
   If lPergunt
      Processa({|| GrvApuracao(.F.)},STR0108) //"Apurando..."
   Else
      MsgInfo(STR0310,STR0183) //"Não exitem DI's que se relacionam com os RE's selecionados."###"Aviso:"
   EndIf
Else
   Help(" ",1,"AVG0005152") //"Nenhum Registro Selecionado na Apuracao."
EndIf


If Select("WORKDI") > 0
	WorkDI->(E_EraseArq(FWorkDI,FWorkDI2,FWorkDI3))
	FErase(FWorkDI4)
Endif


// ** AAF 21/02/06 - Exibi os resumos a partir do inicio.
If lAbriuEDA
   WorkEDA->( dbGoTop() )
EndIf
If lAbriuEDC
   WorkEDC->( dbGoTop() )
EndIf

dbSelectArea("WorkED2")
//oMark5:oBrowse:Refresh()- AOM - 27/10/10
oMark7:oBrowse:Refresh()

Return .T.
*--------------------------------*
Static Function BrowseDI(cChamada)
*--------------------------------*
Local aBotao:={}, oDlgK
Local nOp:=0, cTitulo:=STR0122 //"Itens Importados"
Local COLUNA_FINAL
Private oMarkDI, aAdicao:={}, fWorkSel

Do While !WorkDI->(EOF())
   If !Empty(WorkDI->ED2_ADICAO)
      aAdd(aAdicao,{WorkDI->ED2_HAWB,WorkDI->ED2_INVOIC,WorkDI->ED2_PO_NUM,WorkDI->ED2_POSICA,WorkDI->ED2_PGI_NU})
   EndIf
   WorkDI->(dbSkip())
EndDo
WorkDI->(dbGoTop())

If cChamada == "EXP"
   Aadd(aBotao,{"LBTIK",{|| Processa({|| APMarca(.T.,"WorkDI")},STR0021),WorkDI->(dbGoTop()),oMarkDI:oBrowse:Refresh() },STR0021}) //"Marca/Desmarca Todos"
Else
   Aadd(aBotao,{"LBTIK",{|| Processa({|| APMarcaImp(.T.)},STR0021),WorkDI->(dbGoTop()),oMarkDI:oBrowse:Refresh() },STR0021}) //"Marca/Desmarca Todos"
EndIf

Aadd(aBotao,{"PESQUISA",{|| APURAPESQ("DI")},STR0175}) //"Pesquisa Importação"

DEFINE MSDIALOG oDlgK TITLE cTitulo FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

   COLUNA_FINAL := (oDlgK:nClientWidth-4)/2
   nLinha       := (oDlgK:nClientHeight-4)/2

   oMarkDI:= MsSelect():New("WorkDI","MARCA",,aSelCpos8,@lInverte,@cMarca,{15,1,nLinha,COLUNA_FINAL})
   oMarkDI:oBrowse:bWhen:={|| DBSELECTAREA("WorkDI"),.T.}
   If cChamada == "EXP"
      oMarkDI:bAval:={||If(ValGetAd(),GetAdicao("EXP"), ( APMarca(.F.,"WorkDI"),oMarkDI:oBrowse:Refresh() ) ) }
   Else
      oMarkDI:bAval:={||If(ValGetAd(),GetAdicao("IMP"), ( APMarcaImp(.F.),oMarkDI:oBrowse:Refresh() ) ) }
   EndIf
   oMarkDI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgK ON INIT EnchoiceBar(oDlgK,{||If(MsgYesNo(STR0180+Chr(13)+Chr(10)+STR0181),(nOp:=1, oDlgK:End()), )},{||If(MsgYesNo(STR0167+Chr(13)+Chr(10)+STR0168),(nOp:=0,oDlgK:End()), )},,aBotao) //"Confirma Gravação da Apuração?"###"Todas as informações serão Salvas."###"Deseja Realmente Sair?"###"Todas as alterações serão perdidas."

If nOp = 1
   If cChamada=="EXP"
      Processa({|| GrvApuracao()},STR0123) //"Gravando Apuracao"
   Else
      Processa({|| GrvApImp(.F.)},STR0123) //"Gravando Apuracao"
      //AOM - 23/03/2012
      IF AVFLAGS("DI_ORIGINAL")
         Processa({|| GrvApDIOri()},"Gravando DI`s Originais")
      ENDIF
   EndIf
ElseIf nOp = 0
   If cChamada=="EXP"
      Processa({|| GrvApuracao(.F.)},STR0123) //"Gravando Apuracao"
   EndIf
   oMUserEDC:Solta("ATO","FECHA_BROWSE_DI")  // PLB 27/11/06 - Destrava os registros refentes aos Itens no objeto
EndIf

If Select("WorkSel") <> 0
   //WorkSel->(dbCloseArea())
   WorkSel->(E_EraseArq(fWorkSel))
EndIf

Return .T.

*-------------------------------*
Static Function GrvApuracao(lImp)
*-------------------------------*
Local cCampo, nValAux1, nValAux2, nQtdAux:=0, cTodos:= "", aCanc := {}, i
Local nPercUtil := 0, nInd := 0
lImp := If(lImp=NIL,.T.,lImp)

WorkDI->( dbSetOrder(2) ) //AAF 25/08/08
WorkExpl->( dbSetOrder(2) ) //AAF 25/08/08

// **AAF 09/08/2006 Verifica se a estrutura já foi adicionada.
WorkExpl->( dbGoTop() )
cChave    := WorkExpl->( RE+PROD )
aPercUtil := {}

Do While WorkExpl->( !EoF() )

   If cChave <> WorkExpl->( RE+PROD )
      aAdd(aPercUtil,{cChave,Min(nPercUtil,1)})
      nPercUtil := 0
   EndIf

   cChave    := WorkExpl->( RE+PROD )
   nPercUtil := Max(nPercUtil,WorkExpl->( (QUANT1 - QUANT2)/QUANT1 ))

   WorkExpl->( dbSkip() )
EndDo

If cChave <> WorkExpl->( RE+PROD )
   aAdd(aPercUtil,{cChave,Min(nPercUtil,1)})
EndIf
// **

WorkExpl->( dbGoTop() )
Do While WorkExpl->( !EoF() )

   nPosUtil := aScan(aPercUtil,{|X| X[1] == WorkExpl->(RE+PROD) })

   If lAbriuEDA
      //AC400GrvEDA(INCLUIR,BuscaItemGen(WorkExpl->ITEM),0,WorkExpl->QUANT1,cMarca)
      AC400GrvEDA(INCLUIR,BuscaItemGen(WorkExpl->ITEM),0,WorkExpl->QUANT1*aPercUtil[nPosUtil][2],cMarca)
   EndIf
   If lAbriuEDC
      //AC400EDCGrv(INCLUIR,BuscaItemGen(WorkExpl->ITEM),WorkExpl->RE,WorkExpl->PROD,0,WorkExpl->QUANT1,cMarca)
      AC400EDCGrv(INCLUIR,BuscaItemGen(WorkExpl->ITEM),WorkExpl->RE,WorkExpl->PROD,0,WorkExpl->QUANT1*aPercUtil[nPosUtil][2],cMarca)
   EndIf

   WorkExpl->( dbSkip() )
EndDo

ProcRegua(WorkRE->(EasyRecCount()))
dbSelectArea("WorkRE")
WorkRE->(dbGoTop())
Do While !WorkRE->(EOF())
   IncProc(STR0124+WorkRE->ED1_PROD) //"Gravando Produto de Exportacao "

   If WorkRE->MARCA == cMarca

      // ** AAF 25/08/05 - Verifica se o RE está associado a DI.
      If !WorkDI->( dbSeek(WorkRE->ED1_RE+WorkRE->ED1_PROD) ) .OR. !lImp //AOM - 07/05/2012 - Adicionado o Produto no Seek, pois pode haver varios produto com a mesma RE.
         If (lUnicoRE .AND. !MsgYesNo(STR0304+WorkRE->ED1_RE+STR0305) ) .OR.;//"O RE "###" não está associado a nenhuma DI. Confirma a inclusão do RE?"
            ( !lUnicoRE .AND. cTodos <> "N" .AND. ( cTodos == "S" .OR. If(lPergunt,!MsgYesNo(STR0306),.T.) ))//"Existem REs não associados à nenhuma DI. Confirma a inclusão dos REs?"

            //AC400EstRes()

            cTodos := "S"

            oMUserEDC:Solta("ATO","DESMARCA_RE")  // PLB 27/11/06 - Destrava os registros refentes ao Produto no objeto
            WorkRE->( dbSkip() )
            Loop
         Else
            cTodos := "N"
         Endif
      Endif
      // **

      // ** AAF 10/08/2006 - Proporcionaliza os campos para a quantidade util do RE.
      nPosUtil := aScan(aPercUtil,{|X| X[1] == WorkRE->(ED1_RE+ED1_PROD) })
      aProp := {"ED1_QTD","ED1_VL_MOE","ED1_PESO","SALISE","ED1_VAL_EM"}
      For nInd := 1 To Len(aProp)
         IF cTodos <> "N"   // TLM 01/04/2008 quando nenhum item das DI's forem marcado não pode ser enfetuada a conta pois o aPercUtil é igual a zero.
            WorkRE->&(aProp[nInd]) := WorkRE->&(aProp[nInd])*aPercUtil[nPosUtil][2]
         EndIf
      Next
      // **

      If WorkRE->ISENTO == "N"
         //WorkRE->ED1_VAL_EM := (WorkRE->ED1_VL_MOE/WorkRE->ED1_QTD) * WorkRE->SALISE //AAF 04/10/05 - Valor Proporcional.
         WorkRE->ED1_QTD := WorkRE->SALISE
      EndIf
      /*If cFilSYD <> SYD->YD_FILIAL .or. WorkRE->ED1_NCM <> SYD->YD_TEC
         SYD->(dbSetOrder(1))
         SYD->(dbSeek(cFilSYD+WorkRE->ED1_NCM))
      EndIf*/
      WorkED1->(RecLock("WorkED1",.T.))
       FOR i := 1 TO WorkRE->(fCount())  // TLM 11/01/2008  Inlcuído o Alias  WorkRE->
         cCampo:=WorkRE->(FIELDNAME(i)) // TLM 11/01/2008  Inlcuído o Alias  WorkRE->
         //If !cCampo $("MARCA/EXP/LEXP/FORN/LFORN/UNID/ISENTO/SALISE/FABR/TRB_ALI_WT/TRB_REC_WT")
         If !cCampo $("MARCA/EXP/LEXP/FORN/LFORN/UNID/ISENTO/SALISE/FABR/EE9_PSLQTO/EE9_SLDINI/TRB_ALI_WT/TRB_REC_WT")  // PLB 20/03/07 - Inclusão de Campos
            WorkED1->&(cCampo) := WorkRE->&(cCampo)
         EndIf
      NEXT i
      WorkED1->ED1_TX_MOE := BuscaTxAC(WorkRE->ED1_MOEDA,WorkRE->ED1_DTRE,,.F.,.T.,"E")
      WorkED1->ED1_TX_USS := BuscaTxAC(DOLAR,WorkRE->ED1_DTRE,,.F.,.T.,"E")
      If WorkED1->ED1_TX_MOE <> WorkED1->ED1_TX_USS
         WorkED1->ED1_VALORI := If(WorkED1->ED1_TX_MOE<>0,WorkED1->ED1_TX_MOE*WorkRE->ED1_VL_MOE,WorkRE->ED1_VL_MOE)
         WorkED1->ED1_VALORI := If(WorkED1->ED1_TX_USS<>0,WorkED1->ED1_VALORI/WorkED1->ED1_TX_USS,WorkED1->ED1_VALORI)
      Else
         WorkED1->ED1_VALORI := WorkRE->ED1_VL_MOE
      EndIf
      If(WorkED1->ED1_VAL_EM == 0 , WorkED1->ED1_VAL_EM := WorkED1->ED1_VALORI ,)
      WorkED1->ED1_SEQ    := StrZero(nSeq,nLenSeqED1)
      nSeq += 1
      WorkED1->ED1_UMNCM  := WorkRE->UNID //SYD->YD_UNID
      //If Len(Alltrim(Str(Int(WorkRE->ED1_QTD * WorkRE->ED1_PESO)))) < (AVSX3("ED1_PESO",3) - AVSX3("ED1_PESO",4)) - 1
         //WorkED1->ED1_PESO  := WorkRE->ED1_QTD * WorkRE->ED1_PESO
      // ** PLB 15/03/07
      nPeso := WorkRE->( ED1_QTD * ( EE9_PSLQTO / EE9_SLDINI ) )
      If Len(Alltrim(Str(Int(nPeso)))) < (AVSX3("ED1_PESO",3) - AVSX3("ED1_PESO",4)) - 1
         WorkED1->ED1_PESO  := nPeso
      Else
         WorkED1->ED1_PESO  := 0
      EndIf
      // **
      If (cAliasSB1)->(dbSeek(cFilSB1Aux+WorkRE->ED1_PROD))
         WorkED1->ED1_UMPROD := (cAliasSB1)->B1_UM
         // ** AAF - 02/01/06 - Grava a NCM Antiga.
         If WorkED1->ED1_NCM <> SB1->B1_POSIPI .AND. ED1->( FieldPos("ED1_NCMANT") ) > 0
            WorkED1->ED1_NCMANT := WorkED1->ED1_NCM
         EndIf
         // **
         WorkED1->ED1_NCM    := (cAliasSB1)->B1_POSIPI
         If !Empty(WorkRE->UNID) .or. AvVldUn( ED1->ED1_UMPROD ) // MPG - 14/02/2018
            If WorkRE->UNID <> WorkED1->ED1_UMPROD
               If ! AvVldUn( WorkED1->ED1_UMPROD ) // MPG - 14/02/2018
                  WorkED1->ED1_QTD    := AVTransUnid(WorkRE->UNID,WorkED1->ED1_UMPROD,WorkRE->ED1_PROD,WorkRE->ED1_QTD)
                  WorkED1->ED1_COEFEC := SJ5->J5_COEF   // A. Caetano - ACSJ - 04/03/2004
               Else
                  WorkED1->ED1_QTD    := WorkED1->ED1_PESO
               Endif
            Else
               WorkED1->ED1_COEFEC := 1
            EndIf
         EndIf
         WorkED1->ED1_QTDNCM := WorkRE->ED1_QTD
         WorkED1->ED1_QTDORI := WorkRE->ED1_QTD
      EndIf
      WorkED1->ED1_COEF := WorkED1->ED1_QTD / WorkRE->ED1_QTD
      If WorkED1->ED1_QTDNCM<>0
         WorkED1->ED1_PRCUNI := WorkED1->ED1_VAL_EM / WorkED1->ED1_QTDNCM
      EndIf
      WorkED1->TRB_ALI_WT:= "SW8"
      WorkED1->TRB_REC_WT:= SW8->(Recno())
      WorkED1->(msUnlock())
      AC400Totais("WorkED1",INCLUIR)
      WorkED3Atu("WorkED1",INCLUIR)
   EndIf
   WorkRE->(dbSkip())
EndDo

If lImp
   Processa({|| GrvApImp(.T.)},STR0123) //"Gravando Apuracao"
   //AOM - 23/03/2012
   IF AVFLAGS("DI_ORIGINAL")
      Processa({|| GrvApDIOri()},"Gravando DI`s Originais")
   ENDIF
EndIf

Return .T.

*--------------------------*
Function AC400PApura(cAlias)
*--------------------------*
Local nSW8Ord:=SW8->(IndexOrd()) //LRL 26/05/04
Private nPesoAux:=0
Private lGravaAnt := .F.
Private nValOriTotMoe := 0
Private oBufferCGC:= tHashMap():New() //bufferização da busca pelo CGC
Private oBfItPrinc:= tHashMap():New() //bufferização da busca pelo Item Genérico
Private oBfTransUM:= tHashMap():New() //bufferização da busca pela Conv.Unidade de Medida 

SWN->(dbSetOrder(3))
SW8->(dbSetOrder(1))
SW7->(DBSETORDER(4))
SW6->(dbSetOrder(1))
WorkED1->(dbSetOrder(3))
WorkED2->(dbSetOrder(4))

ProcRegua((cAlias)->(EasyRecCount()))
(cAlias)->(dbGoTop())
Do While !(cAlias)->(EOF())
   IncProc(STR0108) //"Apurando..."
   ValidaCGC(cAlias)
   If lGravaAnt
      GrvAnterioridade()
   EndIf
   (cAlias)->(dbSkip())
EndDo

SWN->(DBSETORDER(1))
(cAlias)->(dbGoTop())
SW7->(DBSETORDER(1))
SW8->(dbSetOrder(nSW8Ord))
WorkED1->(dbSetOrder(1))
WorkED2->(dbSetOrder(1))

Return .T.

*-------------------------------*
Static Function ValidaCGC(cAlias)
*-------------------------------*

 Local cCNPJ := BuscaCNPJ(M->ED0_IMPORT), nSoma:=0, lDel:=.F., cItemGen, aValidos:={}
 Local nRecED0:=ED0->(RecNo()), nOrdED0:=ED0->(IndexOrd())
 Local xResTrUnid,hashChvUMT := "",hashChvItG := "" 

   Begin Sequence

      lDel := .F.

      If !IsMemVar("oBfTransUM") .Or. oBfTransUM == Nil
         oBfTransUM:= tHashMap():New()
      EndIf
      If !IsMemVar("oBfItPrinc") .Or. oBfItPrinc == Nil
         oBfItPrinc:= tHashMap():New()
      EndIf
   
      If cAlias=="WorkRE"
         If cFilSB1Aux <> (cAliasSB1)->B1_FILIAL .or. WorkRE->ED1_PROD <> (cAliasSB1)->B1_COD
            (cAliasSB1)->(dbSeek(cFilSB1Aux+WorkRE->ED1_PROD))
         EndIf
         If cFilSYD <> SYD->YD_FILIAL .or. WorkRE->ED1_NCM <> SYD->YD_TEC
            SYD->(dbSetOrder(1))
            SYD->(dbSeek(cFilSYD+WorkRE->ED1_NCM))
         EndIf

         hashChvUMT := WorkRE->UNID + (cAliasSB1)->B1_UM + WorkRE->ED1_PROD + Str(WorkRE->ED1_QTD)
         If !oBfTransUM:Get(hashChvUMT, @xResTrUnid)
            xResTrUnid := (AvTransUnid(WorkRE->UNID,(cAliasSB1)->B1_UM,WorkRE->ED1_PROD,WorkRE->ED1_QTD,.T.))
            oBfTransUM:Set(hashChvUMT, xResTrUnid) 
         EndIf

         If xResTrUnid = NIL
            WorkRE->MENSA:= STR0250+" - "+Alltrim(WorkRE->UNID)+STR0251+Alltrim((cAliasSB1)->B1_COD)+" - "+Alltrim((cAliasSB1)->B1_UM)+")." //"não existe conversão entre as Unidades de Medidas do Embarque" # "e do Produto ("
         ElseIf WorkRE->ISENTO <> "N" .and. WorkED1->(dbSeek(WorkRE->ED1_PREEMB+WorkRE->ED1_PEDIDO+WorkRE->ED1_SEQUEN))
            WorkRE->(RecLock("WorkRE",.F.,.T.))
            WorkRE->(DBDELETE())
            WorkRE->(msUnlock())
         ElseIf WorkRE->ISENTO == "N" .and. WorkED1->(dbSeek(WorkRE->ED1_PREEMB+WorkRE->ED1_PEDIDO+WorkRE->ED1_SEQUEN))
            Do While !WorkED1->(EOF()) .and. WorkED1->ED1_PREEMB==WorkRE->ED1_PREEMB .and. WorkED1->ED1_PEDIDO==WorkRE->ED1_PEDIDO .and. WorkED1->ED1_SEQUEN==WorkRE->ED1_SEQUEN
               If WorkED1->ED1_RECNO = 0
                  nSoma += WorkED1->ED1_QTDNCM // / WorkED1->ED1_COEF
               EndIf
               WorkED1->(dbSkip())
            EndDo
            If (WorkRE->ED1_QTD - (nSoma + (WorkRE->ED1_QTD - WorkRE->SALISE))) < 0.01
               WorkRE->(RecLock("WorkRE",.F.,.T.))
               WorkRE->(DBDELETE())
               WorkRE->(msUnlock())
            EndIf
            nSoma:=0
         Else
            If !Empty(WorkRE->EXP) .and. (WorkRE->EXP <> SA2->A2_COD .or. WorkRE->LEXP <> SA2->A2_LOJA .or. cFilSA2Aux <> SA2->A2_FILIAL)
               SA2->(DbSetOrder(1))
               SA2->(dbSeek(cFilSA2Aux+WorkRE->EXP+WorkRE->LEXP))
            ElseIf Empty(WorkRE->EXP) .and. (WorkRE->FORN <> SA2->A2_COD .or. WorkRE->LFORN <> SA2->A2_LOJA .or. cFilSA2Aux <> SA2->A2_FILIAL)
               SA2->(DbSetOrder(1))
               SA2->(dbSeek(cFilSA2Aux+WorkRE->FORN+WorkRE->LFORN))
            EndIf
            //RRC - 10/04/2012
            If Type("cOpc") == "C" .And. cOpc == "SIM" .And. !Empty(M->ED0_IMPORT) //Filtra por CNPJ
               If Left(SA2->A2_CGC,8) <> cCNPJ
                  WorkRE->(RecLock("WorkRE",.F.))
                  WorkRE->(dbDelete())
                  WorkRE->(msUnlock())
               EndIf
            Else
               If Empty(M->ED0_IMPORT) .or. Left(SA2->A2_CGC,8) <> cCNPJ  //Não filtra por CNPJ
                  WorkRE->MENSA:= STR0187 //"C.N.P.J. do Importador difere do C.N.P.J. Exportador/Fornecedor."
               EndIf
            EndIf
         EndIf
      Else
         lGravaAnt := .F.  // PLB 22/06/07
         If aScan(aValidos,WorkDI->(RecNo())) = 0      //GFC 27/11/2003
            aAdd(aValidos,WorkDI->(RecNo()))
         Else
            Break
         EndIf
         If !Empty(WorkDI->ED2_RE) .and. !Empty(WorkDI->ED2_PROD)
            Break
         EndIf

         If !Empty(WorkDI->AC)
            ED0->(dbSetOrder(2))
            ED0->(dbSeek(cFilED0+WorkDI->AC))
            If ED0->ED0_MODAL == SUSPENSAO
               WorkDI->(RecLock("WorkDI",.F.,.T.))
               WorkDI->(DBDELETE())
               WorkDI->(msUnlock())
               lDel := .T.
            EndIf
            ED0->(dbSetOrder(nOrdED0))
            ED0->(dbGoto(nRecED0))
         EndIf

         hashChvItG := "I" + WorkDI->ED2_ITEM + M->ED0_PD
         If !oBfItPrinc:Get(hashChvItG, @cItemGen)
            cItemGen := IG400BuscaItem("I",WorkDI->ED2_ITEM,M->ED0_PD)
            oBfItPrinc:Set(hashChvItG, cItemGen)
         EndIf

         If cItemGen<>WorkDI->ED2_ITEM
            if lED2Inat   // ACSJ - 17/11/2004
               WorkDI->ED2_INAT := WorkDI->ED2_ITEM
            Endif
            WorkDI->ED2_ITEM := cItemGen
         EndIf
         If SB1->B1_FILIAL <> cFilSB1 .or. WorkDI->ED2_ITEM <> SB1->B1_COD
            SB1->(dbSeek(cFilSB1+WorkDI->ED2_ITEM))
         EndIf
         If SYD->YD_FILIAL <> cFilSYD .or. WorkDI->ED2_NCM <> SYD->YD_TEC
            SYD->(dbSeek(cFilSYD+WorkDI->ED2_NCM))
         EndIf

         hashChvUMT := WorkDI->UNID + SB1->B1_UM + WorkDI->ED2_ITEM + Str(WorkDI->ED2_QTD)
         If !oBfTransUM:Get(hashChvUMT, @xResTrUnid)
            xResTrUnid := AVTransUnid(WorkDI->UNID,SB1->B1_UM,WorkDI->ED2_ITEM,WorkDI->ED2_QTD,.T.)
            oBfTransUM:Set(hashChvUMT, xResTrUnid) 
         EndIf

         If xResTrUnid = NIL
            WorkDI->MENSA:= STR0248+Alltrim(WorkDI->ED2_INVOIC)+" - "+Alltrim(WorkDI->UNID)+") "+STR0249+Alltrim(SB1->B1_COD)+" - "+Alltrim(SB1->B1_UM)+")." //"não existe conversão entre as Unidades de Medidas da Invoice" # "e do Item ("
         ElseIf Empty(M->ED0_IMPORT) .or. BuscaCNPJ((cAlias)->IMP) <> cCNPJ
            WorkDI->MENSA:= STR0191 //"C.N.P.J. do Importador(A.C.) difere do C.N.P.J. do Importador(D.I.)."
         EndIf

         If Empty(Alltrim(WorkDI->MENSA)) .and. !lDel
            If Empty(WorkDI->ED2_HAWB) .AND. !Empty(WorkDI->ED2_POSICA) //lDiExt .AND.  - NOPADO POR AOM - 04/11/10
               // AAF 13/01/06 - Peso da DI Externa.
               //WorkDI->ED2_PESO := If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)/WorkDI->ED2_QTD * WorkDI->ED2_PESO

               //WorkDI->ED2_PESO := If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) * WorkDI->ED2_PESO
               //nCoefPeso        := Round(If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) / WorkDI->ED2_PESO,7)
               If ! AvVldUn( WorkDI->UNID ) // MPG - 14/02/2018
                  nCoefPeso := Round( WorkDI->ED2_PESO ^ -1,7) // PLB 07/05/07 - Coeficiente com peso unitário (UNIDADE DI / KG = Unidade da DI por Kilograma).
               Else
                  nCoefPeso := 1
               EndIf
            Else
               nPesoAux:=0
               If lMultiFil
                  cFilAux := Left(WorkDI->ED2_FILORI,2)
               Else
                  cFilAux := cFilSWN
               EndIf
               /*
               If SWN->(dbSeek(cFilAux+WorkDI->ED2_HAWB+"1"))
                  Do While !SWN->(EOF()) .and. SWN->WN_FILIAL==cFilAux .and.;
                  SWN->WN_HAWB==WorkDI->ED2_HAWB .and. SWN->WN_TIPO_NF=="1"
                     If SWN->WN_PGI_NUM==WorkDI->ED2_PGI_NU .and. SWN->WN_PO_EIC==WorkDI->ED2_PO_NUM .and.;
                     SWN->WN_ITEM==WorkDI->ED2_POSICA .and. (Empty(SWN->WN_INVOICE) .or. SWN->WN_INVOICE==WorkDI->ED2_INVOIC)
                        Exit
                     EndIf
                     SWN->(dbSkip())
                  EndDo
                  Do While !SWN->(EOF()) .and. SWN->WN_FILIAL==cFilAux .and.;
                  SWN->WN_HAWB==WorkDI->ED2_HAWB .and. SWN->WN_TIPO_NF=="1" .and.;
                  SWN->WN_PGI_NUM==WorkDI->ED2_PGI_NU .and. SWN->WN_PO_EIC==WorkDI->ED2_PO_NUM .and.;
                  SWN->WN_ITEM==WorkDI->ED2_POSICA .and. (Empty(SWN->WN_INVOICE) .or. SWN->WN_INVOICE==WorkDI->ED2_INVOIC)
                     nPesoAux += SWN->WN_PESOL /// SWN->WN_QUANT
                     SWN->(dbSkip())
                  EndDo
               EndIf
               */
               nPesoAux := WorkDI->PESOITNFE
               If nPesoAux <> 0
                  // ** AAF 11/08/2006 - Peso Total Original.
                  WorkDI->QTDORITOT := nPesoAux
                  //WorkDI->ED2_PESO := (If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) / WorkDI->ED2_QTD) * nPesoAux
                  //nCoefPeso := Round(WorkDI->ED2_QTD / nPesoAux,7)
                  nCoefPeso := Round(WorkDI->ED2_QTD / nPesoAux,7)
               Else
                  // ** AAF 11/08/2006 - Peso Total Original.
                  WorkDI->QTDORITOT := WorkDI->QTDORITOT * WorkDI->ED2_PESO

                  If ! AvVldUn( WorkDI->UNID ) // MPG - 14/02/2018
                     nCoefPeso := Round( WorkDI->ED2_PESO ^ -1,7) //AAF 23/07/05 - Coeficiente com peso unitário (UNIDADE DI / KG - Unidade da DI por Kilograma).
                  Else
                     nCoefPeso := 1
                  EndIf

                  //Verificação da quantidade de casas decimais da parte inteira do campo peso, para evitar o estouro do campo.
                  /*
                  If Len(Alltrim(Str(Int(If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) * WorkDI->ED2_PESO)))) < (AVSX3("ED2_PESO",3) - AVSX3("ED2_PESO",4)) - 1
                     WorkDI->ED2_PESO := If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) * WorkDI->ED2_PESO
                  Else
                     WorkDI->ED2_PESO := 0
                  EndIf
                  */
               EndIf
               // ** AAF 11/08/06 - Conversão feita de acordo com o coeficiente de peso ( UNID_DI / KG - Unidade da Di por Kilograma )
               If AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
                  WorkDI->ED2_QTD  := WorkDI->QTDORITOT * nCoefPeso
                  WorkDI->ED2_PESO := nCoefPeso ^ -1
                  //WorkDI->SALISEN := WorkDI->ED2_PESO * nCoefPeso
               EndIf
               // **
            EndIf

            If WorkDI->ISENTOT <> "N" .and. WorkED2->(dbSeek(WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU))
               Do While !WorkED2->(EOF()) .and. WorkED2->ED2_HAWB==WorkDI->ED2_HAWB .and. WorkED2->ED2_INVOIC==WorkDI->ED2_INVOIC .and. WorkED2->ED2_PO_NUM==WorkDI->ED2_PO_NUM .and. WorkED2->ED2_POSICA==WorkDI->ED2_POSICA .and. WorkED2->ED2_PGI_NU==WorkDI->ED2_PGI_NU
                  If WorkED2->ED2_RECNO = 0
                     nSoma += WorkED2->ED2_QTDNCM //  / WorkED2->ED2_COEF
                  EndIf
                  WorkED2->(dbSkip())
               EndDo
               If nSoma > 0
                  WorkDI->ISENTOT := "N"
                  WorkDI->SALISEN := WorkDI->ED2_QTD - nSoma
                  If WorkDI->SALISEN < 0.01
                     WorkDI->(RecLock("WorkDI",.F.,.T.))
                     WorkDI->(DBDELETE())
                     WorkDI->(msUnlock())
                     lDel := .T.
                  EndIf
               EndIf
               nSoma:=0
            ElseIf WorkDI->ISENTOT == "N" .and. WorkED2->(dbSeek(WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU))
               Do While !WorkED2->(EOF()) .and. WorkED2->ED2_HAWB==WorkDI->ED2_HAWB .and. WorkED2->ED2_INVOIC==WorkDI->ED2_INVOIC .and. WorkED2->ED2_PO_NUM==WorkDI->ED2_PO_NUM .and. WorkED2->ED2_POSICA==WorkDI->ED2_POSICA .and. WorkED2->ED2_PGI_NU==WorkDI->ED2_PGI_NU
                  If WorkED2->ED2_RECNO = 0
                     nSoma += WorkED2->ED2_QTDNCM //  / WorkED2->ED2_COEF
                  EndIf
                  WorkED2->(dbSkip())
               EndDo
               If nSoma > 0
                  WorkDI->SALISEN := WorkDI->SALISEN - nSoma
                  If WorkDI->SALISEN < 0.01
                     WorkDI->(RecLock("WorkDI",.F.,.T.))
                     WorkDI->(DBDELETE())
                     WorkDI->(msUnlock())
                     lDel := .T.
                  EndIf
               EndIf
               nSoma:=0
            EndIf
         EndIf
         If Empty(Alltrim(WorkDI->MENSA)) .and. !lDel

            If nPesoAux <> 0
               WorkDI->ED2_PESO := (If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) / WorkDI->ED2_QTD) * nPesoAux
            Else
               //Verificação da quantidade de casas decimais da parte inteira do campo peso, para evitar o estouro do campo.
               If Len(Alltrim(Str(Int(If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) * WorkDI->ED2_PESO)))) < (AVSX3("ED2_PESO",3) - AVSX3("ED2_PESO",4)) - 1
                  WorkDI->ED2_PESO := If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) * WorkDI->ED2_PESO
               Else
                  WorkDI->ED2_PESO := 0
               EndIf
            EndIf

            //AAF - 10/11/05 - Valor Original.
            WorkDI->ED2_VALORI := Round(iif(WorkDI->ISENTOT == "N", (WorkDI->ED2_VL_MOE/WorkDI->ED2_QTD) * WorkDI->SALISEN, WorkDI->ED2_VL_MOE),AvSx3("ED2_VALORI",4))

            If Empty(WorkDI->UNID)
               If Empty(WorkDI->UNID_A5)
                  If cFilSB1 <> SB1->B1_FILIAL .or. WorkDI->ED2_ITEM <> SB1->B1_COD
                     SB1->(dbSeek(cFilSB1+WorkDI->ED2_ITEM))
                  EndIf
                  WorkDI->UNID := SB1->B1_UM
               Else
                  WorkDI->UNID := WorkDI->UNID_A5
               EndIf
            EndIf
            WorkDI->ED2_VALEMB := CalcValEmb("WorkDI",If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD))
            If WorkDI->ED2_VALEMB = 0
               If WorkDI->ISENTOT == "N"
                  WorkDI->ED2_VALEMB:= ((WorkDI->ED2_VL_MOE/WorkDI->ED2_QTD)*WorkDI->SALISEN*WorkDI->ED2_TX_MOE)/WorkDI->ED2_TX_USS
               Else
                  WorkDI->ED2_VALEMB:= WorkDI->ED2_VLORIT
               EndIf
            EndIf

            // ** AAF 10/11/05 - Alterado Calculo do Valor Atualizado na Moeda da Invoice.
            //nCoefAux := WorkDI->ED2_VLORIT / WorkDI->ED2_VALEMB
            //WorkDI->ED2_VL_MOE := WorkDI->ED2_VL_MOE / nCoefAux
            WorkDI->ED2_VL_MOE := WorkDI->ED2_VALEMB * WorkDI->ED2_TX_USS / WorkDI->ED2_TX_MOE
            // **

            If WorkDI->FREINC=="1"  //SW9->W9_FREINC=="1"
               nFreInv := AC400Rateio("FRETEIN")
               WorkDI->ED2_VALEMB -= nFreInv

               // ** AAF 10/11/05 - Abate o Frete do Valor FOB Original.
               // ** AAF 16/03/06 - Verifica se a moeda do frete é difere da moeda do processo.
               If WorkDI->ED2_MOE_FR <> WorkDI->ED2_MOEDA
                  WorkDI->ED2_VALORI -= WorkDI->ED2_FRETE*WorkDI->ED2_TX_FR/WorkDI->ED2_TX_MOE
               Else
                  WorkDI->ED2_VALORI -= WorkDI->ED2_FRETE
               EndIf
               // **

               //WorkDI->ED2_FRETE  := 0//nFreInv
            EndIf

            // ** AAF 16/07/08 - Soma o valor do Inland e Packing ao valor EXW
            If WorkDI->INCOTERM $ "EXW"
               nDesp := WorkDI->INLAND+WorkDI->PACKING+WorkDI->OUTDESP-WorkDI->DESCONT
               WorkDI->ED2_VALORI += nDesp
               WorkDI->ED2_VALEMB += IF(WorkDI->ED2_MOEDA <> DOLAR, ((nDesp*WorkDI->ED2_TX_MOE)/SW6->W6_TX_US_D), nDesp )
            EndIf
            // **

            // EOB - 13/06/08 - Abate o valor do Seguro se estiver incluso.
            If lSegInc .AND. WorkDI->SEGINC=="1"
               nSegInv := AC400Rateio("SEGURIN")
               WorkDI->ED2_VALEMB -= IF(WorkDI->ED2_MOEDA <> DOLAR, ((nSegInv*WorkDI->ED2_TX_MOE)/SW6->W6_TX_US_D), nSegInv )  // Em dolar
               WorkDI->ED2_VALORI -= nSegInv  // Na moeda da invoice
            EndIf

            If Len(Alltrim(Str(Int(WorkDI->ED2_VALEMB / If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD))))) > (AVSX3("ED2_PRCUNI",3) - AVSX3("ED2_PRCUNI",4)) - 1
               WorkDI->MENSA := STR0199 //"preço unitário é inválido."
            ElseIf Empty(WorkDI->ED2_RE) .and. Empty(WorkDI->ED2_PROD)

               // ** AAF 11/08/06 - Conversão feita de acordo com o coeficiente de peso ( UNID_DI / KG - Unidade da Di por Kilograma )
               If AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
                  WorkDI->QTDORI   := WorkDI->ED2_PESO * nCoefPeso
               Else
                  WorkDI->QTDORI   := If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)
               EndIf
               // **

               WorkDI->VALEMBORI:= WorkDI->ED2_VALEMB
               WorkDI->VLMOEORI := WorkDI->ED2_VL_MOE
               nValOriTotMoe    := WorkDI->ED2_VALORI

               If Select("WorkExpl")<>0
                  //GrvAnterioridade()
                  // PLB 22/06/07
                  lGravaAnt := .T.
               EndIf
            EndIf
         EndIf
      EndIf
   If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"VALIDA"),) // TRP-31/03/2008
   End Sequence


Return NIL


*--------------------------------------------------------------------------------------------*
Static Function EE9_SW8Atualiza(cAlias,nTipo,nOldQtd,lAtu)
*--------------------------------------------------------------------------------------------*
Local nEE9Ord:=EE9->(IndexOrd()), nSW8Ord:=SW8->(IndexOrd()) ,nED9Ord:=ED9->(IndexOrd())
Local cFilAux := ""
// ** PLB 17/09/07
Local nPesoAux := 0
Local nSWNOrd := SWN->( IndexOrd() )
Local cChave := "" //RRC - 14/05/2012 - Chave de busca na tabela ED8 (Manutenção de DI externa)
Private nQtdConv:=0
Private cAliasAtu := cAlias  //TRP-08/04/08
SWN->( DBSetOrder(3) )
// **
If(nOldQtd = NIL, nOldQtd:=0 , )
If(lAtu = NIL, lAtu:=.F. , )

EE9->(dbSetOrder(2))
SW8->(dbSetOrder(6))

If cAlias=="EE9" .AND. !EMPTY(ED1->ED1_PREEMB)//  igor chiba 08/04/09
   //If EE9->(dbSeek(cFilEE9+ED1->ED1_PREEMB+ED1->ED1_PEDIDO+ED1->ED1_SEQUEN))
   If lMultiFil
      cFilAux := ED1->ED1_FILORI
   Else
      cFilAux := cFilEE9
   EndIf
   If EE9->(dbSeek(cFilAux+ED1->ED1_PREEMB+ED1->ED1_PEDIDO+ED1->ED1_SEQUEN))
      EE9->(msUnlock()) //Libera o SoftLock
      EE9->(RecLock("EE9",.F.))
      nQtdConv := AvTransUnid(ED1->ED1_UMNCM,EE9->EE9_UNIDAD,ED1->ED1_PROD,ED1->ED1_QTDNCM)
      If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"ALTERA_VALOR"),) // TRP-07/04/2008
      If nTipo=INCLUIR
         EE9->EE9_ATOCON := If(Empty(M->ED0_AC),M->ED0_PD,M->ED0_AC)
         EE9->EE9_FASEDR := If(Empty(M->ED0_AC),"1","2")
         If !lAtu
            If nQtdConv < EE9->EE9_SLDINI
               If EE9->EE9_ISENTO == "N"
                  If(nOldQtd<>0, EE9->EE9_SALISE += nOldQtd ,) // / ED1->ED1_COEF , )
                  EE9->EE9_SALISE -= nQtdConv
               ElseIf EE9->EE9_SLDINI > nQtdConv
                  EE9->EE9_SALISE := EE9->EE9_SLDINI - nQtdConv
                  EE9->EE9_ISENTO := "N"
               EndIf
            Else
               EE9->EE9_ISENTO := "S"
            EndIf
         EndIf
      Else
         EE9->EE9_ATOCON := ""
         EE9->EE9_FASEDR := ""
         If EE9->EE9_ISENTO == "N"
            EE9->EE9_SALISE += nQtdConv // / ED1->ED1_COEF
            If EE9->EE9_SLDINI <> EE9->EE9_SALISE
               AtuIsenParcial(cAlias)
            Else
               EE9->EE9_ISENTO := ""
               EE9->EE9_SALISE := 0
            EndIf
         Else
            EE9->EE9_ISENTO := ""
            EE9->EE9_SALISE := 0
         EndIf
      EndIf
      EE9->(msUnlock())
   EndIf
//  igor chiba 08/04/09
ELSEIF cAlias=="EE9" .AND. EMPTY(ED1->ED1_PREEMB)

   ED9->(DBSETORDER(1)) // ED9_FILIAL+ED9_RE+ED9_PEDIDO+ED9_POSICA
  // If ED9->(dbSeek(cFilED9+ED1->ED1_RE+ED1->ED1_AC+ED1->ED1_SEQ))
   If ED9->(dbSeek(cFilED9+ED1->ED1_RE+ED1->ED1_PEDIDO+ED1->ED1_SEQUEN))
      ED9->(msUnlock()) //Libera o SoftLock
      ED9->(RecLock("ED9",.F.))
      nQtdConv := AvTransUnid(ED1->ED1_UMNCM,ED9->ED9_UM,ED1->ED1_PROD,ED1->ED1_QTDNCM)
      If nTipo=INCLUIR
         ED9->ED9_AC     := If(Empty(M->ED0_AC),M->ED0_PD,M->ED0_AC)
         ED9->ED9_FASEDR := If(Empty(M->ED0_AC),"1","2")
         If !lAtu
            If nQtdConv < ED9->ED9_QTD
               If ED9->ED9_ISENTO == "2"
                  If(nOldQtd<>0, ED9->ED9_SALISE += nOldQtd ,)
                  ED9->ED9_SALISE -= nQtdConv
               ElseIf ED9->ED9_QTD > nQtdConv
                  ED9->ED9_SALISE := ED9->ED9_QTD - nQtdConv
                  ED9->ED9_ISENTO := "2"
               EndIf
            Else
               ED9->ED9_ISENTO := "1"
            EndIf
         EndIf
      Else
         ED9->ED9_AC     := ""
         ED9->ED9_FASEDR := ""
         If ED9->ED9_ISENTO == "2"
            ED9->ED9_SALISE += nQtdConv // / ED1->ED1_COEF
            If ED9->ED9_QTD <> ED9->ED9_SALISE
               AtuIsenParcial('ED9')
            Else
               ED9->ED9_ISENTO := ""
               ED9->ED9_SALISE := 0
            EndIf
         Else
             ED9->ED9_ISENTO := ""
             ED9->ED9_SALISE := 0
         EndIf
      EndIf
      ED9->(msUnlock())
   EndIf
   ED9->(DBSETORDER(nED9Ord))
// Fim Igor Chiba
Else
   If lMultiFil
      cFilAux := ED2->ED2_FILORI
   Else
      cFilAux := cFilSW8
   EndIf
   If SW8->(dbSeek(cFilAux+ED2->ED2_HAWB+ED2->ED2_INVOIC+ED2->ED2_PO_NUM+ED2->ED2_POSICA+ED2->ED2_PGI_NU))
      SW8->(msUnlock()) //Libera o SoftLock
      SW8->(RecLock("SW8",.F.))
      nQtdConv := AvTransUnid(ED2->ED2_UMNCM,SW8->W8_UNID,ED2->ED2_ITEM,ED2->ED2_QTDNCM)
      If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"ALTERA_VALOR"),) // TRP-07/04/2008
      // ** PLB 17/09/07 - Calcula o peso de acordo com a Nota Fiscal
      nPesoAux := 0
      If AvVldUn( SW8->W8_UNID ) // MPG - 14/02/2018
         If SWN->( DBSeek(cFilSWN+ED2->ED2_HAWB+"1") )
            Do While SWN->( !EoF()  .And.  WN_FILIAL == cFilSWN  .And.  WN_HAWB == ED2->ED2_HAWB  .And.  WN_TIPO_NF == "1" )
               If SWN->( WN_PGI_NUM == ED2->ED2_PGI_NU  .And.  WN_PO_EIC == ED2->ED2_PO_NUM  .And.  WN_ITEM == ED2->ED2_POSICA ;
                  .And.  ( Empty(WN_INVOICE)  .Or.  WN_INVOICE == ED2->ED2_INVOIC ) )
                  Exit
               EndIf
               SWN->( DBSkip() )
            EndDo
            Do While SWN->( !EoF()  .And.  WN_FILIAL == cFilSWN  .And.  WN_HAWB == ED2->ED2_HAWB  .And.  WN_TIPO_NF == "1" ;
                     .And.  WN_PGI_NUM == ED2->ED2_PGI_NU  .And.  WN_PO_EIC == ED2->ED2_PO_NUM  .And.  WN_ITEM == ED2->ED2_POSICA ;
                     .And.  ( Empty(WN_INVOICE)  .Or.  WN_INVOICE == ED2->ED2_INVOIC ) )
               nPesoAux += SWN->WN_PESOL
               SWN->( DBSkip() )
            EndDo
         EndIf
      EndIf
      // **
      If nTipo=INCLUIR
         SW8->W8_ACISEN := If(Empty(M->ED0_AC),M->ED0_PD,M->ED0_AC)
         If Empty(SW8->W8_ADICAO) .or. Alltrim(SW8->W8_ADICAO) == "0"
            SW8->W8_ADICAO := ED2->ED2_ADICAO
         EndIf
         SW8->W8_FASEDR := If(Empty(M->ED0_AC),"1","2")
         If !lAtu
            //If nQtdConv < SW8->W8_QTDE
            If IIF(nPesoAux==0,nQtdConv < SW8->W8_QTDE,nQtdConv < nPesoAux)  // PLB 17/09/07
               If SW8->W8_ISENTOT == "N"
                  If(nOldQtd<>0, SW8->W8_SALISEN += nOldQtd ,) // / ED2->ED2_COEF , )
                  SW8->W8_SALISEN -= nQtdConv
               //ElseIf SW8->W8_QTDE > nQtdConv
               Else
                  //SW8->W8_SALISEN := SW8->W8_QTDE - nQtdConv
                  // ** PLB 17/09/07 - Considerar caso seja Kilograma
                  If nPesoAux == 0
                     SW8->W8_SALISEN := SW8->W8_QTDE - nQtdConv
                  Else
                     SW8->W8_SALISEN := nPesoAux - nQtdConv
                  EndIf
                  // **
                  SW8->W8_ISENTOT := "N"
               EndIf
            Else
               SW8->W8_ISENTOT := "S"
            EndIf
         EndIf
      Else
         SW8->W8_ACISEN := ""
         SW8->W8_FASEDR := ""
         If SW8->W8_ISENTOT == "N"
            SW8->W8_SALISEN += nQtdConv // / ED2->ED2_COEF
            If SW8->W8_QTDE <> SW8->W8_SALISEN
               AtuIsenParcial(cAlias)
            Else
               SW8->W8_ISENTOT := ""
               SW8->W8_SALISEN := 0
            EndIf
         Else
            SW8->W8_ISENTOT := ""
            SW8->W8_SALISEN := 0
         EndIf
      EndIf
      SW8->(msUnlock())
   Else //If lDiExt - NOPADO POR AOM - 04/11/10
      If Empty(ED2->ED2_DI_NUM) //RRC - 14/05/2012 - Definição da chave de busca gravar Ato de Isenção de Compra Nacional ou Importação
         ED8->( dbSetOrder(5) ) //Se não tiver DI, é Compra Nacional
         cChave := "ED2_PO_NUM+ED2_POSICA" //Busca pela chave ED8_PEDIDO+ED8_POSDI
      Else
         ED8->( dbSetOrder(4) )
         cChave := "ED2_DI_NUM+ED2_ADICAO+ED2_POSICA" //Busca pela chave ED8_DI_NUM+ED8_ADICAO+ED8_POSDI
      EndIf

      If ED8->( dbSeek(cFilED8+ED2->( &(cChave))) )
         ED8->( MsUnLock() ) //Libera o SoftLock
         ED8->( RecLock("ED8",.F.) )
         nQtdConv := AvTransUnid(ED2->ED2_UMNCM,ED8->ED8_UM,ED2->ED2_ITEM,ED2->ED2_QTDNCM)
         If nTipo=INCLUIR
            ED8->ED8_ACISEN := If(Empty(M->ED0_AC),M->ED0_PD,M->ED0_AC)
            If Empty(ED8->ED8_ADICAO) .or. Alltrim(ED8->ED8_ADICAO) == "0"
               ED8->ED8_ADICAO := ED2->ED2_ADICAO
            EndIf
            ED8->ED8_FASEDR := If(Empty(M->ED0_AC),"1","2")
            If !lAtu
               If nQtdConv < ED8->ED8_QTD
                  If ED8->ED8_ISETOT == "N"
                     If(nOldQtd<>0, ED8->ED8_SALISE += nOldQtd ,) // / ED2->ED2_COEF , )
                     ED8->ED8_SALISE -= nQtdConv
                  ElseIf ED8->ED8_QTD > nQtdConv
                     ED8->ED8_SALISE := ED8->ED8_QTD - nQtdConv
                     ED8->ED8_ISETOT := "N"
                  EndIf
               Else
                  ED8->ED8_ISETOT := "S"
               EndIf
            EndIf
         Else
            ED8->ED8_ACISEN := ""
            ED8->ED8_FASEDR := ""
            If ED8->ED8_ISETOT == "N"
               ED8->ED8_SALISE += nQtdConv // / ED2->ED2_COEF
               If ED8->ED8_QTD <> ED8->ED8_SALISE
                  AtuIsenParcial(cAlias,.T.)
               Else
                  ED8->ED8_ISETOT := ""
                  ED8->ED8_SALISE := 0
               EndIf
            Else
               ED8->ED8_ISETOT := ""
               ED8->ED8_SALISE := 0
            EndIf
         EndIf
         ED8->( MsUnLock() )
      EndIf
   EndIf
EndIf

EE9->(dbSetOrder(nEE9Ord))
SW8->(dbSetOrder(nSW8Ord))
SWN->( DBSetOrder(nSWNOrd) )  // PLB 17/09/07

Return .T.

*--------------------------------*
Static Function ED2AtuSeq(nSeqAux)
*--------------------------------*
WorkED2->(dbSetOrder(2))
If WorkED2->(dbSeek(WorkED1->ED1_PROD+WorkED1->ED1_SEQ))
   WorkED2->ED2_SEQ := StrZero(nSeqAux,nLenSeqED1)
EndIf

Return .T.

*---------------------------------*
Function AC400Est(cAlias,nReg,nOpc)
*---------------------------------*
Local lRet:=.T.

ED8->(dbSetOrder(3))
ED9->(dbSetOrder(3))

If AC400IsAprop("LI",ED0->ED0_MODAL,ED0->ED0_AC,ED0->ED0_PD,cFilSW5)
   Help(" ",1,"AVG0005162",,Alltrim(SW5->W5_PGI_NUM),2,23) //"Ato nao pode ser estornado pois esta apropriado para L.I. "
   lRet := .F.
ElseIf AC400IsAprop("DI",ED0->ED0_MODAL,ED0->ED0_AC,ED0->ED0_PD,cFilSW8)
   Help(" ",1,"AVG0005163",,Alltrim(SW6->W6_DI_NUM),2,22)//"Ato nao pode ser estornado pois esta apropriado para D.I. "
   lRet := .F.
ElseIf (!Empty(ED0->ED0_AC) .and. ED8->( dbSeek(cFilED8+ED0->ED0_AC) ))// lDiExt .AND.  - NOPADO POR AOM - 04/11/10
   Help(" ",1,"AVG0005163",,Alltrim(ED8->ED8_DI_NUM),2,22)//"Ato nao pode ser estornado pois esta apropriado para D.I. "
   lRet := .F.
ElseIf AC400IsAprop("EMB",ED0->ED0_MODAL,ED0->ED0_AC,ED0->ED0_PD,cFilEE9)
   Help(" ",1,"AVG0005164",,Alltrim(EE9->EE9_PREEMB)+STR0128,2,25 ) //"Ato nao pode ser estornado pois esta apropriado para Embarque " # " (Exportacao)"
   lRet := .F.
ElseIf !Empty(ED0->ED0_AC) .and. ED8->(dbSeek(cFilED8+ED0->ED0_AC))
   Help(" ",1,"AVG0005259")
   lRet := .F.
ElseIf !Empty(ED0->ED0_AC) .and. ED9->(dbSeek(cFilED9+ED0->ED0_AC))
   Help(" ",1,"AVG0005260")
   lRet := .F.
EndIf

ED8->(dbSetOrder(1))
ED9->(dbSetOrder(1))

If lRet
   AC400Manut(cAlias,nReg,nOpc)
EndIf

Return .T.

*---------------------------------------*
Static Function AlteraExplodidos(nQuant1, lSomenteResumoTecnico)
*---------------------------------------*
Local nQuant2, lAtu:=.T., nQtdOriAux:=0, nQtdCalAux:=0, nValCalAux:=0
Local aAtuCpos:={}, lQuebra:=.F., aCposWork:={}, nQtdAux:=0, nQtdNcmAux:=0, nValEmbAux:=0, nPesoAux:=0
Local nAntValEmb:= 0 //AAF 11/05/05 - Valor Anterior
Local cImport := "" //AOM - 10/11/2011
Default lSomenteResumoTecnico:= .F.

/*Do While !WorkED2->(EOF()) .and. WorkED2->ED2_PROD==WorkED1->ED1_PROD .and. WorkED2->ED2_SEQ=WorkED1->ED1_SEQ
   nQuant2 := WorkED2->ED2_QTDORI / nQuant1
   If !VerED4Saldo("ALTERA","WorkED2",nQuant2)
      Help(" ",1,"AVG0005165")
      lAtu := .F.
      Exit
   EndIf
   WorkED2->(dbSkip())
EndDo

WorkED2->(dbGoTo(nRec)) */ //GFC Comentado em 26/07/04



If lAtu
   WorkED4->(dbSetOrder(1))
   Do While !WorkED2->(EOF()) .and. WorkED2->ED2_PROD==WorkED1->ED1_PROD .and. WorkED2->ED2_SEQ=WorkED1->ED1_SEQ

      If lSomenteResumoTecnico
      
         If lAbriuEDC
            AC400EDCGrv(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD, 0, WorkED2->ED2_QTDORI*-1,, nQuant1*-1)
         EndIf
         
         If lAbriuEDA
            AC400GrvEDA(ALTERAR,WorkED2->ED2_ITEM, 0, WorkED2->ED2_QTDORI*-1)
         EndIf

         nOriQtd:= Round((WorkED2->ED2_QTDORI * (1 - WorkED2->ED2_PERCPE/100)),AVSX3("ED2_QTD",4)) / nQuant1 //Quantidade de estrutura Original do Ato.
         nQtdTot:= WorkED1->ED1_QTD * nOriQtd / (1 - WorkED2->ED2_PERCPE/100) //Quantidade da necessaria para o produto exportado. Com percentual de Perda.

         If lAbriuEDC
            AC400EDCGrv(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD, 0, nQtdTot,, WorkED1->ED1_QTD)
         EndIf

         If lAbriuEDA
            AC400GrvEDA(ALTERAR,WorkED2->ED2_ITEM, 0, nQtdTot)
         EndIf
         
         //Atualização da quantidade na estrutura na work dos insumos
         WorkED2->(RecLock("WorkED2",.F.))
         WorkEd2->ED2_QTDORI:= nQtdTot
         WorkED2->(MsUnlock())
      Else

         //LRS - 28/07/2015
         If AvFlags("SEQMI")
            cImport :=  WorkED2->ED2_IMPORT
         EndIf

         WorkED4->(dbSeek(WorkED2->ED2_NCM+WorkED2->ED2_ITEM+WorkED2->ED2_CAMB+Str(WorkED2->ED2_PERCPE,5,2)+;
            iif(lED2Umanex,If(Empty(WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM)+cImport)) // ACSJ - 17/11/2004
         nQuant2 := WorkED2->ED2_QTDORI / nQuant1

         SB1->(dbSeek(cFilSB1+WorkED2->ED2_ITEM))

         nQtdAux   :=0
         nQtdNcmAux:=0
         nValEmbAux:=0
         nPesoAux  :=0
         nQtdOriAux:=0
         nQtdCalAux:=0
         nValCalAux:=0
         aCposWork :={}

         /* AAF 13/04/05 - Comentado pois não havia motivo para quebrar o item, há uma nova validação
                           impedindo que altere a quantidade do produto para menor do que a quantidade na LI
                           de um item.

         //GFC 23/07/04 - Inicio
         If !VerED4Saldo("ALTERA","WorkED2",nQuant2)
            nRecWorkED2 := WorkED2->(RecNo())
            lQuebra := .T.
            For ni:=1 to WorkED2->(FCount())
               aAdd(aCposWork,WorkED2->(FieldGet(ni)))
            Next ni
            WorkED4->(dbSeek(WorkED2->ED2_NCM+WorkED2->ED2_ITEM+WorkED2->ED2_CAMB+Str(WorkED2->ED2_PERCPE,5,2)+;
               iif(lED2Umanex,If(Empty(WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM)))   // ACSJ - 17/11/2004
            WorkED2->(RecLock("WorkED2",.T.))
            For ni:=1 to WorkED2->(FCount())
               WorkED2->&(FIELDNAME(ni)) := aCposWork[ni]
            Next ni
            WorkED2->ED2_PROD   := ""
            WorkED2->ED2_SEQ    := ""
            WorkED2->ED2_QTD    := (WorkED4->ED4_QTDCAL - WorkED4->ED4_QT_LI) - (WorkED2->ED2_QTD+(WorkED1->ED1_QTD * nQuant2 - WorkED2->ED2_QTD))
            WorkED2->ED2_QTDORI := (WorkED4->ED4_QTDCAL - WorkED4->ED4_QT_LI) - (WorkED2->ED2_QTDORI+(WorkED1->ED1_QTD * nQuant2 - WorkED2->ED2_QTDORI))
            WorkED2->ED2_VALEMB := WorkED2->ED2_QTD * WorkED2->ED2_PRCUNI
            WorkED2->ED2_VALCAL := (WorkED2->ED2_QTD * WorkED2->ED2_PRCUNI) - (((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTD)/100)
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD-((((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTD)/100))
            WorkED2->ED2_QTDNCM := WorkED2->ED2_QTDNCM+(AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMNCM,WorkED2->ED2_ITEM,WorkED2->ED2_QTD)-WorkED2->ED2_QTDNCM)
            WorkED2->ED2_PESO   := SB1->B1_PESO * WorkED2->ED2_QTD
            WorkED2->ED2_RECNO  := 0
            WorkED2->(msUnlock())

            nQtdAux    += WorkED2->ED2_QTD
            nQtdNcmAux += WorkED2->ED2_QTDNCM
            nValEmbAux += WorkED2->ED2_VALEMB
            nQtdOriAux += WorkED2->ED2_QTDORI
            nQtdCalAux += WorkED2->ED2_QTDCAL
            nValCalAux += WorkED2->ED2_VALCAL
            If SB1->B1_COD == WorkED2->ED2_ITEM
               nPesoAux += WorkED2->ED2_PESO
            EndIf

               AC400GrvEDA(INCLUIR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,0,WorkED2->ED2_MARCA)
               AC400EDCGrv(INCLUIR,WorkED2->ED2_ITEM,Space(Len(WorkED1->ED1_RE)),WorkED2->ED2_PROD,WorkED2->ED2_QTD,0,WorkED2->ED2_MARCA)
            WorkED2->(dbGoTo(nRecWorkED2))
         EndIf
         //Fim

         AAF 13/04/05 */

         WorkED2->(RecLock("WorkED2",.F.))

         AC400Totais("WorkED2",ESTORNAR) //AAF 14/04/05 - Problema no Valor total da Importação.

         SYD->(dbSetOrder(1))
         SYD->(dbSeek(cFilSYD+WorkED2->ED2_NCM))

         //aAdd(aAtuCpos,{"ED4_QTD"   ,(WorkED1->ED1_QTD * nQuant2 - WorkED2->ED2_QTD)})

         /* Em virutde da alteração do compromisso de exportação, o sistema precisará atualizar o resumo técnico com as informações da quantidade do cadastro de estrutura
            (ED2_QTDORI) e quantidade a exportar (qtd. do produto). */
         If lAbriuEDA
            AC400GrvEDA(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD*-1, WorkED2->ED2_QTDORI*-1)
         EndIf
         If lAbriuEDC
            AC400EDCGrv(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD*-1, WorkED2->ED2_QTDORI*-1,, nQuant1*-1)
         EndIf

         nAntValEmb := WorkED2->ED2_VALEMB //AAF 11/05/05 - Valor Anterior

         // ** AAF 19/08/05 - Alterado calculo para quantidade devido a imprecisão com percentual de perda.
         //WorkED2->ED2_QTD    := WorkED2->ED2_QTD+(WorkED1->ED1_QTD * nQuant2 - WorkED2->ED2_QTD)
         //WorkED2->ED2_QTDORI := WorkED2->ED2_QTDORI+(WorkED1->ED1_QTD * nQuant2 - WorkED2->ED2_QTDORI)

         nOriQtd:= Round((WorkED2->ED2_QTDORI * (1 - WorkED2->ED2_PERCPE/100)),AVSX3("ED2_QTD",4)) / nQuant1 //Quantidade de estrutura Original do Ato.
         nQtdTot:= WorkED1->ED1_QTD * nOriQtd / (1 - WorkED2->ED2_PERCPE/100) //Quantidade da necessaria para o produto exportado. Com percentual de Perda.

         aAdd(aAtuCpos,{"ED4_QTD"   ,Round(nQtdTot - WorkED2->ED2_QTD,AVSX3("ED4_QTD",4))})

         WorkED2->ED2_COEF   := Round(nQtdTot/WorkED1->ED1_QTD ,AVSX3("ED2_COEF",4))
         WorkED2->ED2_QTD    := Round(nQtdTot ,AVSX3("ED2_QTD"   ,4))
         WorkED2->ED2_QTDORI := Round(nQtdTot ,AVSX3("ED2_QTDORI",4))
         WorkED2->ED2_VALEMB := Round(nQtdTot * WorkED2->ED2_PRCUNI,AVSX3("ED2_VALEMB",4))
         // **

         //AAF 14/04/05 - Verifica se Percentual de perda é maior que o aprovado.
         If WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP
   //         WorkED2->ED2_VALCAL := (WorkED2->ED2_QTD * WorkED2->ED2_PRCUNI) - ((Max(WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP,0) * WorkED2->ED2_QTD)/100)
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_VALEMB)/100
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD-((Max(WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP,0) * WorkED2->ED2_QTD)/100) //GFC 23/07/04
         Else
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB
            WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD
         Endif

         If SB1->B1_COD == WorkED2->ED2_ITEM
            //aAdd(aAtuCpos,{"ED4_QTDNCM",(AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMNCM,WorkED2->ED2_ITEM,WorkED1->ED1_QTD * nQuant2) - WorkED2->ED2_QTDNCM)})
            aAdd(aAtuCpos,{"ED4_QTDNCM",Round(AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMNCM,WorkED2->ED2_ITEM,nQtdTot) - WorkED2->ED2_QTDNCM,AVSX3("ED4_QTDNCM",4))})
         EndIf

         //AAF 11/05/05 - Acertos na Baixa dos Valores no ED4.
         //aAdd(aAtuCpos,{"ED4_VALEMB",(WorkED2->ED2_QTD * WorkED2->ED2_PRCUNI - WorkED4->ED4_VALEMB)})
         aAdd(aAtuCpos,{"ED4_VALEMB",Round(WorkED2->ED2_VALEMB - nAntValEmb,AVSX3("ED4_VALEMB",4))})

         /* Em virutde da alteração do compromisso de exportação, o sistema precisará atualizar o resumo técnico com as informações da quantidade do cadastro de estrutura
            (ED2_QTDORI) e quantidade a exportar (qtd. do produto). */
         If lAbriuEDA
            AC400GrvEDA(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD, WorkED2->ED2_QTDORI)
         EndIf
         If lAbriuEDC
            AC400EDCGrv(ALTERAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD, WorkED2->ED2_QTDORI,, WorkED1->ED1_QTD)
         EndIf
         If SB1->B1_COD == WorkED2->ED2_ITEM
            //WorkED2->ED2_QTDNCM := WorkED2->ED2_QTDNCM+(AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMNCM,WorkED2->ED2_ITEM,WorkED2->ED2_QTD)-WorkED2->ED2_QTDNCM)
            WorkED2->ED2_QTDNCM := AVTransUnid(WorkED2->ED2_UMITEM,WorkED2->ED2_UMNCM,WorkED2->ED2_ITEM,WorkED2->ED2_QTD)
            If ValValor("ED2_PESO","WorkED2")
               WorkED2->ED2_PESO:= AC400Peso(WorkED2->ED2_UMITEM,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,SB1->B1_PESO)// TDF - 22/03/10
               //WorkED2->ED2_PESO   := SB1->B1_PESO * WorkED2->ED2_QTD
            EndIf
         EndIf
         WorkED2->(msUnlock())

         nQtdAux    += WorkED2->ED2_QTD
         nQtdNcmAux += WorkED2->ED2_QTDNCM
         nValEmbAux += WorkED2->ED2_VALEMB
         nQtdOriAux += WorkED2->ED2_QTDORI
         nQtdCalAux += WorkED2->ED2_QTDCAL
         nValCalAux += WorkED2->ED2_VALCAL
         If SB1->B1_COD == WorkED2->ED2_ITEM
            nPesoAux += SB1->B1_PESO * WorkED2->ED2_QTD
         EndIf

         If !Empty(WorkED2->ED2_MARCA)//AAF 29/07/05 - Não Atualiza saldo se não estiver marcado.
            If !lQuebra
               WorkED4Atu("WorkED2",ALTERAR,aAtuCpos)  //Atualiza WorkED4 baseado nos dados do array aAtuCpos
            Else
               ED2Quebrado(nQtdAux,nQtdNcmAux,nValEmbAux,nPesoAux,nQtdCalAux,nValCalAux)
            EndIf
         Endif

         AC400Totais("WorkED2",INCLUIR)//AAF 14/04/05 - Problema no valor total da Importação.

      EndIf

      WorkED2->(dbSkip())
      aAtuCpos:={}
   EndDo
EndIf

dbSelectArea("WorkEDA")
//oMark5:oBrowse:Refresh()- AOM - 27/10/10
WorkEDC->(DBGoTop())
Return .T.

*-----------------------------------------------*
Function ConvVal(cMoeda,nVal,dData,cModo,lFiscal,nTxMoeda,nTxDolar) //TAN Aumentou o parâmetro cModo para acerto no Busca Taxa.
*-----------------------------------------------*
Local nConvVal
Local cMoeDolar := EasyGParam("MV_SIMB2",,"US$") //PLB 15/01/07 - Moeda Dolar.
Default nTxMoeda:= 0, nTxDolar := 0 //AOM - 19/11/10

If(lFiscal=NIL,lFiscal:=.F.,)
If(dData=NIL,dData:=dDataBase,)
If cMoeda <> cMoeDolar
   If nTxMoeda <> 0  //AOM - 19/11/10
      nConvVal := nVal * nTxMoeda
   Else                                                                                      //NCF - 09/10/09 - Caso a moeda passada como parâmetro seja a mesma cadastrada no MV_SIMB2,
      nConvVal := nVal * BuscaTaxa(cMoeda,dData,If(lFiscal,.T.,),lFiscal,.T.,cModo)          //                 não efetua a conversão e retorna no valor da moeda passada.
   EndIf                                                                                     //PLB 15/01/07 - Usa Moeda dolar do Parametro MV_SIMB2 "US$"

   If nTxDolar <> 0
      nConvVal := nConvVal / nTxDolar
   Else
      nConvVal := nConvVal / BuscaTaxa(cMoeDolar,dData,If(lFiscal,.T.,),lFiscal,.T.,cModo)
   EndIf
Else
   nConvVal := nVal
EndIf
Return nConvVal

*------------------------------*
Static Function GravaCapa(nTipo)
*------------------------------*
Local nRegED0, lPerg:=.F.
Local aInsumos:= {}

//AOM - 16/11/2011
If !Empty(WorkED2->(DBFilter()))
   WorkED2->(DBCLEARFILTER())
   WorkED2->(DBGOTOP())
EndIf
//AOM - 16/11/2011
If !Empty(WorkED4->(DBFilter()))
   WorkED4->(DBCLEARFILTER())
   WorkED4->(DBGOTOP())
EndIf

If nTipo<>VISUALIZAR .and. nTipo<>ESTORNAR
   If (WorkED2->(EOF()) .and. WorkED2->(BOF())) .or. (WorkED1->(EOF()) .and. WorkED1->(BOF()))
      Help(" ",1,"AVG0005166") //"Ato nao pode ser gravado sem nenhum Produto a Exportar ou Item a Importar."
      Return .F.
   ElseIf Tot_ExpSCob <> Round(Tot_ImpSCob,2)//AAF 23/06/05 - Arredondamento para valores, apenas 2 casas decimais.
      Help(" ",1,"AVG0005167") //"A.C. nao pode ser gravado pois o Total sem Cobertura Cambial da Exportacao difere do Total sem Cobertura Cambial da Importacao."
      Return .F.
   Else
      WorkED1->(dbGoTop())
      Do While !WorkED1->(EOF())
         If WorkED1->ED1_VAL_EM = 0
            Help(" ",1,"AVG0005168") //"Um ou mais produtos nao estao com valor preenchido. Pedido nao pode ser gravado."
            //WorkED1->(dbGoTop())
            Return .F.
         EndIf
         WorkED1->(dbSkip())
      EndDo
      WorkED2->(dbGoTop())
      Do While !WorkED2->(EOF())
         If WorkED2->ED2_VALEMB = 0 .and. WorkED2->ED2_MARCA==cMarca
            Help(" ",1,"AVG0005169") //"Um ou mais Itens nao estao com valor preenchido. Pedido nao pode ser gravado."
            //WorkED2->(dbGoTop())
            Return .F.
         ElseIf WorkED2->ED2_MARCA==cMarca .and. Empty(WorkED2->ED2_PROD) .and. Empty(WorkED2->ED2_SEQ) .and. !lPerg
            lPerg := .T.
            If !MsgYesNo(STR0296)  //"Existem itens marcados que não estão associados a nenhum produto a exportar. Sugere-se que seja feita essa associação para não haver problemas de anterioridade. Confirma gravação?"
               Return .F.
            EndIf
         EndIf

         /* wfs
            Armazenamento dos insumos marcados e das sequencias dos produdos a exportar que estão a estes vinculados.
            Estas informações serão usadas para verificar se na estrutura do ato concessório existe duplicação de insumos através de itens alternativos. */
         If !Empty(WorkED2->ED2_PROD) .and. !Empty(WorkED2->ED2_SEQ)
            If AScan(aInsumos, {|i| i[1] == WorkEd2->ED2_ITEM .And. i[2] == WorkED2->ED2_PROD .And. i[3] == WorkED2->ED2_SEQ}) == 0
               AAdd(aInsumos, {WorkEd2->ED2_ITEM, WorkED2->ED2_PROD, WorkED2->ED2_SEQ}) //insumo, produto a exportar e sequencia a exportar
            EndIf
         EndIf

         WorkED2->(dbSkip())
      EndDo
   EndIf
   
   /* wfs
      Validação de referência no uso de insumos na estrutura do ato concessório. */
   If !ValidaAlternativo(aInsumos)
      WorkED2->(DBGoTop())
      Return .F.
   EndIf

   ED0->(dbSetOrder(2))
   If nTipo=INCLUIR .or. nTipo=ALTERAR
      // A. CAETANO - ACSJ - 04/03/2004
      // Se Existir Ato Concessorio não permite Data de Registro Vazia
      // Se Existir Data do Registro não permite Ato Concessorio Vazio
    //If !Empty(M->ED0_AC) .and. Empty(M->ED0_DT_REG) ALS - 06/12/2007
      If !Empty(M->ED0_AC) .and. if(EasyGParam("MV_EDC0005",,.F.), .F., Empty(M->ED0_DT_REG)) //ALS - 06/12/2007
         MsgStop(STR0291) // "Data de Registro deve ser preenchida."
         Return .f.
      Endif
      If Empty(M->ED0_AC) .and. !Empty(M->ED0_DT_REG)
         MsgStop(STR0292) //"Número de Ato Concessorio deve ser preenchido."
         Return .f.
   	  Endif
   	  //---------------------------------------------------------------
      nRegED0:=ED0->(RecNo())
      If !Empty(M->ED0_AC) .and. ED0->(dbSeek(cFilED0+M->ED0_AC)) .and. M->ED0_PD <> ED0->ED0_PD
         Help(" ",1,"AVG0005124",,Alltrim(ED0->ED0_PD)+". ",2,27) //"Este numero de Ato Concessorio esta sendo usado para o pedido " # "Entre com um numero valido."
         ED0->( dbGoTo(nRegED0) )
         Return .F.
      EndIf
      If nTipo=INCLUIR
         ED0->(dbSetOrder(1))
         If ED0->(dbSeek(cFilED0+M->ED0_PD))
            Help(" ",1,"AVG0005171") //"Ja existe este numero de Pedido de Drawback cadastrado no sistema. Entre com um numero valido."
            Return .F.
         EndIf
      EndIf
      ED0->(dbGoTo(nRegED0))
   EndIf
   ED0->(dbSetOrder(1))
EndIf

Return .T.

*------------------------------------------*
Static Function BrowseCpos(cAlias,cAliasDad,aCposTira)
*------------------------------------------*
Local aOrd := SaveOrd("SX3")
LOCAL aRet := {}
LOCAL aField

Default cAliasDad := cAlias
Default aCposTira := {} //AOM - 30/10/10 - Define os campos para não serem apresentados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))

Do While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias

   IF SX3->X3_NIVEL > cNivel .or. Upper(SX3->X3_BROWSE) != "S" .or. SX3->X3_CONTEXT == "V" .or. aScan(aCposTira,{|x|  x == Alltrim(SX3->X3_CAMPO)}) <> 0
      SX3->(dbSkip())
      Loop
   Endif

   aField := { Alltrim(SX3->X3_CAMPO),"", OemToAnsi(X3TITULO()),Alltrim(SX3->X3_PICTURE) }

   IF aField[1] != Nil
      aAdd(aRet,aField)
   Endif

   SX3->(dbSkip())
Enddo

RestOrd(aOrd)

Return aRet

*---------------------------------*
Static Function GetAdicao(cChamada)
*---------------------------------*
Local cAdicao:=Space(3), nOpcao:=0, oDlgAD

If SYD->YD_FILIAL <> cFilSYD .or. WorkDI->ED2_NCM <> SYD->YD_TEC
   SYD->(dbSetOrder(1))
   SYD->(dbSeek(cFilSYD+WorkDI->ED2_NCM))
EndIf
If Empty(SYD->YD_UNID)
   Help(" ",1,"AVG0005172") //"Item nao pode ser marcado pois sua NCM nao possui Unidade de Medida."
   WorkDI->MARCA := ""
   Return .F.
EndIf

DEFINE MSDIALOG oDlgAD TITLE STR0136 ; //"Entre com a Adicao"
       FROM 12,05 TO 20,55 OF oMainWnd

   cAdicao := WorkDI->ED2_ADICAO
   @02,02 SAY   AVSX3("ED2_ADICAO",5) of oDlgAD
   @02,08 MSGET cAdicao  PICT AVSX3("ED2_ADICAO",6) SIZE 30,8

ACTIVATE MSDIALOG oDlgAD ON INIT EnchoiceBar(oDlgAD,{||nOpcao:=1,oDlgAD:End()},{||nOpcao:=0,oDlgAD:End()}) CENTERED

If nOpcao = 1 .and. !Empty(cAdicao)
   WorkDI->(RecLock("WorkDI",.F.))
   WorkDI->ED2_ADICAO := Alltrim(cAdicao)
   WorkDI->(msUnlock())
   If cChamada=="EXP"
      APMarca(.F.,"WorkDI")
   Else
      APMarcaImp(.F.)
   EndIf
EndIf

Return .T.

*--------------------------*
Static Function AC400ApImp()
*--------------------------*
Local cNcmAp:=Space(AVSX3("ED2_NCM",3)), dDtIni:=avCtoD("  /  /  ")
Local cProdAp:=Space(AVSX3("ED2_ITEM",3)), nOp:=0, dDtFim:=avCtoD("  /  /  ")
Local nSW8Ord:=SW8->(IndexOrd())
Local nInd, nTpImp := 0
Private fWorkDI, fWorkDI2, fWorkDI3, fWorkDI4
Private nLeadAnt:=EasyGParam("MV_LEADANT",,30), nCoefPeso:=0
Private nIntAnt :=EasyGParam("MV_INT_ANT",,0)
Private cDI:=Space(AVSX3("ED2_DI_NUM",3)), cPedido := Space(AVSX3("ED2_PD",3)), cTpImp := "3 - Todos",;
        oCbxTipImp, aItensImp := {"1 - Nr da DI","2 - Pedido","3 - Todos"} // *** GFP - 31/08/2011
Private oDlgL

// ** PLB 22/06/07
Private aFil := IIF(lMultiFil,AvgSelectFil(.T.,,"ED2"),{cFilSW6})
Private cFil := ""
If !(aFil[1] == "WND_CLOSE")
   For nInd:= 1 to len(aFil)
      If !aFil[nInd] $ EasyGParam("MV_AVG0024",,"")
         cFil+="'"+aFil[nInd]+"'"
         If nInd < len(aFil)
            cFil+=","
         EndIf
      EndIf
   Next i
   // PLB 27/07/07
   If Empty(cFil)
      cFil := "'  '"
   ElseIf SubStr(cFil,Len(cFil),1) == ","
      cFil := SubStr(cFil,1,Len(cFil)-1)
   EndIf
EndIf
// **


If !lMultiFil  .Or.  !( aFil[1] == "WND_CLOSE" )

   SW8->(dbSetOrder(6))
   lVolta1 := .F.
   DEFINE MSDIALOG oDlgL TITLE STR0111 ; //"Apuracao de Itens"
          FROM 05,05 TO 30/*25*/,55 OF oMainWnd

      oPanel:= TPanel():New(0,0, "", oDlgL,, .T., ,,,0,0,,.T.) //LGS-11/12/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @02,02 SAY   AVSX3("ED2_DI_NUM",5) of oPanel
      @02,08 MSGET cDI PICT AVSX3("ED2_DI_NUM",6) VALID IIF(!(Empty(cDI) .or.  AC400ValDI(cDI)  .Or.  /*IIF(lDiExt,*/Posicione("ED8",4,cFilED4+cDi,"ED8_DI_NUM")==cDi/*,.F.)*/),(Help(" ",1,"REGNOIS"),.F.),.T.)/*ExistCpo("SW6",cDI,11)*/ SIZE 60,8 of oPanel
      @03,02 SAY   AVSX3("ED2_ITEM",5) of oPanel
      @03,08 MSGET cProdAp F3 "SB1" PICT AVSX3("ED2_ITEM",6) VALID (Empty(cProdAp) .or. ExistCpo("SB1",cProdAp)) SIZE 60,8 of oPanel
      @04,02 SAY   AVSX3("ED2_NCM",5) of oPanel
      @04,08 MSGET cNcmAp F3 "SYD" PICT AVSX3("ED2_NCM",6) VALID (Empty(cNcmAp) .or. ExistCpo("SYD",cNcmAp)) SIZE 60,8 of oPanel
      @05,02 SAY   "Data Inicial" of oPanel
      @05,08 MSGET dDtIni PICT "@D" SIZE 60,8 of oPanel
      @06,02 SAY   "Data Final" of oPanel
      @06,08 MSGET dDtFim PICT "@D" VALID E_Periodo_Ok(@dDtIni,@dDtFim) SIZE 60,8 of oPanel
      // *** GFP - 31/08/2011 - Inclusão de campos referente a Compras Nacionais.
      If AvFlags("COMPRAS NACIONAIS")
         @07,02 SAY   "Pedido" of oPanel
         @07,08 MSGET cPedido PICT "" SIZE 60,8 of oPanel
         @08,02 SAY   "Tipo de Importação" of oPanel
         @103,63 COMBOBOX oCbxTipImp Var cTpImp Items aItensImp VALID AC400VImp() SIZE 60,08 of oPanel PIXEL

         oDlgL:aControls[14]:SetFocus()   // Combobox Tipo de Importação
      EndIf
                                                                                                
   ACTIVATE MSDIALOG oDlgL ON INIT EnchoiceBar(oDlgL,{||nOp:=1, IF(AvFlags("COMPRAS NACIONAIS"),nTpImp := oCbxTipImp:nAt,) ,If(E_Periodo_Ok(@dDtIni,@dDtFim),oDlgL:End(),)},{||nOp:=0,oDlgL:End()}) CENTERED

   If nOp=1
      MsAguarde({ || AC400SelDI(.F.,cProdAp,cNcmAp,cDI,dDtIni,dDtFim,cPedido,nTpImp)}, STR0082 ) //"Aguarde, Apurando Dados..."
      lVolta1 := .T.
   EndIf

EndIf

SW8->(dbSetOrder(nSW8Ord))
WorkED2->(dbGoTop())
dbSelectArea("WorkED2") //LRL 25/05/04
Return .T.

*--------------------------------*
Static Function APMarcaImp(lTodos)  //Anterioridade
*--------------------------------*
Local /*lMens1:=.F.,*/ lMens2:=.F., lMens5:=.F., lMens6:=.F.

//If lDiExt NOPADO POR AOM - 04/11/10
   ED8->( dbSetORder(4) )
//EndIf

If !lTodos
   If WorkDI->MARCA <> cMarca
      WorkDI->MARCA := cMarca
      ACGetAnt()
      //If (SW8->(dbSeek(cFilSW8+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU)) .AND. !SoftLock("SW8")) .OR.;
      //   (lDiExt .AND. ED8->(dbSeek(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA)) .and. !SoftLock("ED8")) //AAF 26/04/2006 - Utiliza alias WorkDI.
      //   Help(" ",1,"AVG0005154") //"Item nao pode ser marcado pois esta marcado para outra apuracao."

      // PLB 27/11/06 - Bloqueio de registros pelo objeto
      //If (SW8->(dbSeek(cFilSW8+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU)) .OR.;
      //    (lDiExt .AND. ED8->(dbSeek(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA))))  .And.  !oMUserEDC:Reserva("ATO","MARCA_DI")
      If lMultiFil
         cFilAux := Left(WorkDI->ED2_FILORI,2)
      Else
         cFilAux := cFilSW8
      EndIf
      If (SW8->(dbSeek(cFilAux+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU)) .OR.;
          (/*lDiExt .AND. - AOM - 04/11/10*/ED8->(dbSeek(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA))))  .And.  !oMUserEDC:Reserva("ATO","MARCA_DI")
         WorkDI->MARCA := ""
         WorkDI->ED2_RE  := ""
         WorkDI->ED2_PROD:= ""
         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTRE")) > 0
            WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
         ENDIF

         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
            WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
         ENDIF
      ElseIf !Empty(WorkDI->MENSA) .and. Left(WorkDI->MENSA,6) <> STR0183 //"Aviso:"
         Msginfo(STR0205+WorkDI->MENSA, STR0195) //"Item não pode ser marcado, pois "###"Mensagem"
         WorkDI->MARCA := ""
         WorkDI->ED2_RE  := ""
         WorkDI->ED2_PROD:= ""
         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTRE")) > 0
            WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
         ENDIF

         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
            WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
         ENDIF
      ElseIf !Empty(WorkDI->MENSA) .and. Left(WorkDI->MENSA,6) == STR0183 //"Aviso:"
         Msginfo(Alltrim(WorkDI->MENSA))
      EndIf
   Else
      WorkDI->MARCA := ""
      /*If SW8->(dbSeek(cFilSW8+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU))
         SW8->(msUnlock())
      ElseIf (lDiExt .AND. ED8->(dbSeek(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA)) )
         ED8->(msUnlock())
      EndIf*/
      oMUserEDC:Solta("ATO","DESMARCA_DI")  // PLB 27/11/06 - Destrava os registros refentes ao Item no objeto
   EndIf
Else
   ProcRegua(WorkDI->(EasyRecCount()))
   WorkDI->(dbGoTop())
   If WorkDI->MARCA <> cMarca
      Do While !WorkDI->(EOF())
         IncProc(STR0102 + Alltrim(WorkDI->ED2_ITEM)) //"Processando Item: "
         WorkDI->MARCA := cMarca
         ACGetAnt()
         If Empty(WorkDI->ED2_ADICAO)
            lMens2:=.T.
            WorkDI->MARCA   := ""
            WorkDI->ED2_RE  := ""
            WorkDI->ED2_PROD:= ""
            //AOM - 14/03/2012
            IF ED2->(FIELDPOS("ED2_DTRE")) > 0
               WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
            ENDIF

            //AOM - 14/03/2012
            IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
               WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
            ENDIF
         Else
            //If ( SW8->(dbSeek(cFilSW8+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU)) .AND. !SoftLock("SW8")) .OR.;
            //   ( lDiExt .AND. ED8->(dbSeek(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA)) .AND. !SoftLock("ED8"))
            //   lMens1:=.T.
            // PLB 27/11/06 - Bloqueio de registro pelo objeto
            //If ( SW8->(dbSeek(cFilSW8+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU)) .OR.;
            //     (lDiExt .AND. ED8->(dbSeek(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA))))  .And.  !oMUserEDC:Reserva("ATO","MARCA_DI")
            If lMultiFil
               cFilAux := Left(WorkDI->ED2_FILORI,2)
            Else
               cFilAux := cFilSW8
            EndIf
            If ( SW8->(dbSeek(cFilAux+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU)) .OR.;
                 (/*lDiExt .AND. - AOM 04/11/10*/ED8->(dbSeek(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA))))  .And.  !oMUserEDC:Reserva("ATO","MARCA_DI")
               WorkDI->MARCA   := ""
               WorkDI->ED2_RE  := ""
               WorkDI->ED2_PROD:= ""
               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                  WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF

               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                  WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
                ENDIF
            ElseIf !Empty(WorkDI->MENSA) .and. Left(WorkDI->MENSA,6) <> STR0183 //"Aviso:"
               lMens5:=.T.
               WorkDI->MARCA   := ""
               WorkDI->ED2_RE  := ""
               WorkDI->ED2_PROD:= ""
               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTRE")) > 0
                  WorkDI->ED2_DTRE:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF

               //AOM - 14/03/2012
               IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
                  WorkDI->ED2_DTEMBA:= CtoD("  /  /  ")//FDR - 06/01/2014
               ENDIF
            ElseIf !Empty(WorkDI->MENSA) .and. Left(WorkDI->MENSA,6) == STR0183 //"Aviso:"
               lMens6:=.T.
            EndIf
         EndIf
         WorkDI->(dbSkip())
      EndDo
   Else
      Do While !WorkDI->(EOF())
         IncProc(STR0102 + Alltrim(WorkDI->ED2_ITEM)) //"Processando Item: "
         WorkDI->MARCA := ""
         /*If SW8->(dbSeek(cFilSW8+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU))
            SW8->(msUnlock())
         ElseIf (lDiExt .AND. ED8->(dbSeek(cFilED8+WorkDI->ED2_DI_NUM+WorkDI->ED2_ADICAO+WorkDI->ED2_POSICA)) )
            ED8->(msUnlock())
         EndIf*/
         oMUserEDC:Solta("ATO","DESMARCA_DI")  // PLB 27/11/06 - Destrava os registros refentes ao Item no objeto
         WorkDI->(dbSkip())
      EndDo
   EndIf
EndIf

//If lMens1
//   Help(" ",1,"AVG0005157") //"Algum(s) item(s) nao pode(m) ser marcado(s) pois esta(o) sendo usado(s) em outra Apuracao."
If lMens2
   Help(" ",1,"AVG0005159") //"Algum(s) item(s) nao pode(m) ser marcado(s) pois nao tem Adicao. Selecione Individualmente."
ElseIf lMens5
   Help(" ",1,"AVG0005296") //MsgInfo(STR0202) //"Algum(s) item(s) nao pode(m) ser marcado(s). Selecione Individualmente."
ElseIf lMens6
   MsgInfo(STR0203) //"Algum(s) item(s) esta(ão) com o(s) Valor(es) desatualizado(s) ou com o(s) Valor(es) atualizados, porém este(s) é(são) menor(es) que o(s) Valor(es) no Embarque."
EndIf

Return .T.

*----------------------------*
Static Function GrvApImp(lExp)
*----------------------------*
Local cCampo, nPos, nOldED2Ord:=ED2->(IndexOrd()), nQtdAux:=0, nQtdOri:=0, i

SYD->(dbSetOrder(1))
SWN->(DBSETORDER(3))
SW7->(DBSETORDER(4))
SW8->(dbSetOrder(6))
SW9->(DBSETORDER(1))
SW6->(dbSetOrder(1))
ED2->(dbSetOrder(4))
SG1->( DBSetOrder(1) ) // PLB 20/06/07

ProcRegua(WorkDI->(EasyRecCount()))

dbSelectArea("WorkDI")
WorkDI->(dbSetOrder(1) ) //AAF 25/08/05
WorkDI->(dbGoTop())
Do While !WorkDI->(EOF())
   IncProc(STR0105+WorkDI->ED2_ITEM) //"Gravando Item "
   If WorkDI->MARCA == cMarca
      nQtdOri := WorkDI->ED2_QTD
      If WorkDI->ISENTOT == "N"
         WorkDI->ED2_QTD := WorkDI->SALISEN
      EndIf
      WorkED2->(RecLock("WorkED2",.T.))
      FOR i := 1 TO fCount()
         cCampo:=FIELDNAME(i)
         If !cCampo $("MARCA/IMP/UNID/UNID_A5/ISENTOT/SALISEN/FABR/FORN/VALEMBORI/QTDORI/VLMOEORI/FREINC/FRETEIN/FRETE/SEGURO/AC/TRB_ALI_WT,TRB_REC_WT")
            if (lED2Dt_Nf .and. cCampo = "ED2_DT_NF") .or. cCampo <> "ED2_DT_NF"   // ACSJ - 17/11/2004
               WorkED2->&(cCampo) := WorkDI->&(cCampo)
            Endif
         EndIf
      NEXT i

      //AOM - 23/12/2012
      IF AVFLAGS("DI_ORIGINAL")
         WorkED2->ED2_SEQIT := RetUltSeqIt()
      ENDIF

      WorkED2->ED2_MARCA := cMarca
      WorkED2->ED2_CAMB  := "1"
      WorkED2->ED2_UMNCM := WorkDI->UNID //SYD->YD_UNID

      If SB1->(dbSeek(cFilSB1+WorkDI->ED2_ITEM))
         WorkED2->ED2_UMITEM := SB1->B1_UM
         // ** AAF - 02/01/06 - Grava a NCM Antiga.
         If WorkED2->ED2_NCM <> SB1->B1_POSIPI .AND. ED2->( FieldPos("ED2_NCMANT") ) > 0
            WorkED2->ED2_NCMANT := WorkED2->ED2_NCM
         EndIf
         // **
         WorkED2->ED2_NCM    := SB1->B1_POSIPI
         If !Empty(WorkDI->UNID) .or. AvVldUn( WorkED2->ED2_UMITEM ) // MPG - 14/02/2018
            If WorkDI->UNID <> WorkED2->ED2_UMITEM
               If ! AvVldUn( WorkED2->ED2_UMITEM ) // MPG - 14/02/2018
                  WorkED2->ED2_QTD    := Round(AVTransUnid(WorkDI->UNID,WorkED2->ED2_UMITEM,WorkDI->ED2_ITEM,WorkDI->ED2_QTD),AVSX3("ED2_QTD",4))
                  WorkED2->ED2_COEFEC := SJ5->J5_COEF   // A. Caetano - ACSJ - 04/03/2004
               Else
                  WorkED2->ED2_QTD    := Round(WorkED2->ED2_PESO,AVSX3("ED2_QTD",4))
               Endif
            Else
               WorkED2->ED2_COEFEC := 1
            EndIf
         EndIf
         WorkED2->ED2_QTDORI := WorkDI->ED2_QTD
         WorkED2->ED2_QTDNCM := WorkDI->ED2_QTD
      EndIf
      WorkED2->ED2_COEF   := (WorkED2->ED2_PESO / WorkDI->QTDORITOT) * 100
      If WorkED2->ED2_QTD<>0
         If Len(Alltrim(Str(Int(WorkED2->ED2_VALEMB / WorkED2->ED2_QTDNCM)))) < (AVSX3("ED2_PRCUNI",3) - AVSX3("ED2_PRCUNI",4)) - 1
            //AAF - 29/09/05 - Arredondamentos.
            WorkED2->ED2_PRCUNI := Round((WorkDI->VALEMBORI / WorkDI->QTDORI),AVSX3("ED2_PRCUNI",4)) //WorkED2->ED2_VALEMB / WorkED2->ED2_QTDNCM
         EndIf
      EndIf
      // ** PLB 20/06/07 - Busca Percentual de Perda do Item Importado
      If !Empty(WorkED2->ED2_PROD)
         If IIF(!Empty(WorkED2->ED2_INAT),SG1->( DBSeek(cFilSG1+WorkED2->ED2_PROD+WorkED2->ED2_INAT) ),.F.)  .Or.  SG1->( DBSeek(cFilSG1+WorkED2->ED2_PROD+WorkED2->ED2_ITEM) )
            WorkED2->ED2_PERCPE := SG1->G1_PERDA
            WorkED2->ED2_PERCAP := SG1->G1_PERDA
         EndIf
      EndIf
      // **
      If WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP
         WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTD)/100
         WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_VALEMB)/100
      Else
         WorkED2->ED2_QTDCAL := WorkED2->ED2_QTD
         WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB
      EndIf

      //Rateio Frete e Seguro
      AC400Rateio("AMBOS") //AAF 23/11/05 - Sempre faz ambos os Rateios.
  
      If lExp
         WorkED2->ED2_SEQ := "0000"
      Endif
      WorkED2->TRB_ALI_WT:= "ED2"
      WorkED2->TRB_REC_WT:= ED2->(Recno())
      WorkED2->(msUnlock())
      AC400Totais("WorkED2",INCLUIR)
      WorkED4Atu("WorkED2",INCLUIR,,,.T.)
      AC400GrvEDA(INCLUIR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,0,WorkED2->ED2_MARCA)
      AC400EDCGrv(INCLUIR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD,0,WorkED2->ED2_MARCA)
   EndIf
   WorkDI->(dbSkip())
EndDo

SWN->(dbSetOrder(1))
SW7->(DBSETORDER(1))
SW8->(dbSetOrder(1))
ED2->(dbSetOrder(nOldED2Ord))

//oMark5:oBrowse:Refresh() - AOM - 27/10/10
oMark7:oBrowse:Refresh()

Return .T.

*----------------------------*
Function EDCAC400HLP(cProduto)    // M
*----------------------------*
LOCAL oDlgM, Tb_Campos:={}, lRetHlp:=.F.
LOCAL cVarProd:=Readvar()
LOCAL bActionHlp:= {||lRetHlp:=.T., cProduto:= (cAliasSB1)->B1_COD,oDlgM:End()}
LOCAL nIndexAtu := (cAliasSB1)->(IndexOrd())
LOCAL oCbxPesq, cTpPesq   := "C", aTpPesq:={STR0137,STR0138}, cPesq := Space(30) //"Codigo" # "Descricao"
PRIVATE oMarkHlp

IF !(cVarProd $ "CPRODAP/M->ED1_PROD/CCODIGO/MV_PAR01/MV_PAR02/M->J5_COD_I/CITEMAP")
   RETURN .F.
ENDIF

dbSelectArea(cAliasSB1)

AADD(Tb_Campos,{"B1_COD"  ,,STR0137})     //"Codigo"
AADD(Tb_Campos,{"B1_DESC" ,,STR0138})     //"Descricao"
AADD(Tb_Campos,{"B1_GRUPO",,STR0139})     //"Grupo"

(cAliasSB1)->(dbGoTop())

DEFINE MSDIALOG oDlgM TITLE STR0073 FROM 4,3 TO 23,65 OF oMainWnd //"Pesquisa de Produtos"

   oPanel:= TPanel():New(0,0, "", oDlgM,, .T., ,,,0,0,,.T.) //LGS-11/12/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   oMarkHlp        := MsSelect():New(cAliasSB1,,,TB_Campos,@lInverte,@cMarca,{10,6,100,200})
   oMarkHlp:baval  := bActionHlp

   @105,010 SAY STR0140 PIXEL of oPanel //"Pesquisa por:"
   @105,045 ComboBox oCbxPesq Var cTpPesq Items aTpPesq Valid MudaOrdPE(cTpPesq) SIZE 150,08 of oPanel PIXEL

   @120,010 SAY STR0141 PIXEL of oPanel //"Localizar:"
   @120,045 MSGET cPesq PICT "@!" VALID PesqOrdPE(cPesq) SIZE 150,8 of oPanel PIXEL

   DEFINE SBUTTON FROM 10,210 TYPE 1 ACTION (EVAL(bActionHlp)) ENABLE OF oPanel PIXEL
   DEFINE SBUTTON FROM 25,210 TYPE 2 ACTION (lRet:=.F.,oDlgM:End()) ENABLE OF oPanel PIXEL

ACTIVATE MSDIALOG oDlgM CENTERED

IF cVarProd $ "M->ED1_PROD"
   If !Empty(M->ED1_PROD) .And. lRetHlp
      AC400VALID("ED1_PROD")
   Endif
Endif

// Volta a Ordem anterior
(cAliasSB1)->(DbSetOrder(nIndexAtu))

RETURN lRetHlp
*------------------------------------------*
Function MudaOrdPE(cOrdem)
*------------------------------------------*
If cOrdem = "C"     // Codigo
   (cAliasSB1)->(DbSetOrder(1))
Else                // Descricao
   (cAliasSB1)->(DbSetOrder(3))
Endif

(cAliasSB1)->(DbGotop())

oMarkHlp:oBrowse:Refresh()

RETURN .T.
*----------------------------------------------*
Function PesqOrdPE(cConteudo)
*----------------------------------------------*
Local nRecPEAtu := (cAliasSB1)->(Recno())

If !(cAliasSB1)->(DbSeek(If(cFilSB1Aux=NIL,xFilial(),cFilSB1Aux)+Alltrim(cConteudo),.T.))  // Caso nao encontre posiciona no registro anterior.
   If (cAliasSB1)->(Eof())
      (cAliasSB1)->(DbGoto(nRecPEAtu))
   Endif
Endif

oMarkHlp:oBrowse:Refresh()

RETURN .T.
*----------------------------*
Static Function LimpaTabelas()
*----------------------------*
Local W
ProcRegua(Len(aTabelas))

FOR W := 1 TO LEN(aTabelas)
   IncProc(STR0030+Alltrim(Str(W))) //"Criando Arquivo Temporario "
   If !Empty(aTabelas[W,1])
      (aTabelas[W,1])->(avzap())
   EndIf
NEXT

Return .T.

*------------------------------*
Static Function AcertaCpos(cCpo)
*------------------------------*
Local nPos

If cCpo=="1"
   If M->ED0_MODAL == ISENCAO
      nPos := ASCAN(aSelCpos,{|x| x[1]=="ED1_QTDORI"})
      If(nPos=0,aAdd(aSelCpos,{"ED1_QTDORI",,AVSX3("ED1_QTDORI",5),AVSX3("ED1_QTDORI",6)}),)
      nPos := ASCAN(aSelCpos,{|x| x[1]=="ED1_PREEMB"})
      If(nPos=0,aAdd(aSelCpos,{"ED1_PREEMB",,AVSX3("ED1_PREEMB",5),AVSX3("ED1_PREEMB",6)}),)
      nPos := ASCAN(aSelCpos,{|x| x[1]=="ED1_RE"})
      If(nPos=0,aAdd(aSelCpos,{"ED1_RE",,AVSX3("ED1_RE",5), "" }),) //AVSX3("ED1_RE",6)
      nPos := ASCAN(aSelCpos,{|x| x[1]=="ED1_DTRE"})
      If(nPos=0,aAdd(aSelCpos,{"ED1_DTRE",,AVSX3("ED1_DTRE",5),AVSX3("ED1_DTRE",6)}),)
      nPos := ASCAN(aSelCpos,{|x| x[1]=="ED1_MOEDA"})
      If(nPos=0,aAdd(aSelCpos,{"ED1_MOEDA",,AVSX3("ED1_MOEDA",5),AVSX3("ED1_MOEDA",6)}),)
      nPos := ASCAN(aSelCpos,{|x| x[1]=="ED1_TX_MOE"})
      If(nPos=0,aAdd(aSelCpos,{"ED1_TX_MOE",,AVSX3("ED1_TX_MOE",5),AVSX3("ED1_TX_MOE",6)}),)
      nPos := ASCAN(aSelCpos,{|x| x[1]=="ED1_TX_USS"})
      If(nPos=0,aAdd(aSelCpos,{"ED1_TX_USS",,AVSX3("ED1_TX_USS",5),AVSX3("ED1_TX_USS",6)}),)
      nPos := ASCAN(aSelCpos,{|x| x[1]="ED1_UMNCM"})
      If(nPos>0,aSelCpos[nPos,3] := "U.M. Venda",)
      nPos := ASCAN(aSelCpos,{|x| x[1]="ED1_QTDNCM"})
      If(nPos>0,aSelCpos[nPos,3] := "Qtde. Venda",)
   ElseIf M->ED0_MODAL == SUSPENSAO
      nPos := ASCAN(aSelCpos,{|x| x[1]=="ED1_SEQ"})
      If(nPos=0,aAdd(aSelCpos,{"ED1_SEQ",,AVSX3("ED1_SEQ",5),AVSX3("ED1_SEQ",6)}),)
   EndIf
ElseIf cCpo=="2"
   nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_MARCA"})
   If nPos > 0
      If M->ED0_MODAL == ISENCAO
         ADEL(aSelCpos2,nPos)
         ASIZE(aSelCpos2,LEN(aSelCpos2)-1)
      Else
         aSelCpos2[nPos,3] := ""
      EndIf
   EndIf
   If M->ED0_MODAL == ISENCAO
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_HAWB"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_HAWB",,AVSX3("ED2_HAWB",5),AVSX3("ED2_HAWB",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_DI_NUM"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_DI_NUM",,AVSX3("ED2_DI_NUM",5),AVSX3("ED2_DI_NUM",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_ADICAO"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_ADICAO",,AVSX3("ED2_ADICAO",5),AVSX3("ED2_ADICAO",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_DTREG"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_DTREG",,AVSX3("ED2_DTREG",5),AVSX3("ED2_DTREG",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_INVOIC"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_INVOIC",,AVSX3("ED2_INVOIC",5),AVSX3("ED2_INVOIC",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_MOEDA"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_MOEDA",,AVSX3("ED2_MOEDA",5),AVSX3("ED2_MOEDA",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_TX_MOE"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_TX_MOE",,AVSX3("ED2_TX_MOE",5),AVSX3("ED2_TX_MOE",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_TX_USS"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_TX_USS",,AVSX3("ED2_TX_USS",5),AVSX3("ED2_TX_USS",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_FRETE"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_FRETE",,AVSX3("ED2_FRETE",5),AVSX3("ED2_FRETE",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_FR_USS"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_FR_USS",,AVSX3("ED2_FR_USS",5),AVSX3("ED2_FR_USS",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_MOE_FR"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_MOE_FR",,AVSX3("ED2_MOE_FR",5),AVSX3("ED2_MOE_FR",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_TX_FR"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_TX_FR",,AVSX3("ED2_TX_FR",5),AVSX3("ED2_TX_FR",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_SEGURO"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_SEGURO",,AVSX3("ED2_SEGURO",5),AVSX3("ED2_SEGURO",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_SE_USS"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_SE_USS",,AVSX3("ED2_SE_USS",5),AVSX3("ED2_SE_USS",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_MOE_SE"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_MOE_SE",,AVSX3("ED2_MOE_SE",5),AVSX3("ED2_MOE_SE",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]=="ED2_TX_SE"})
      If(nPos=0,aAdd(aSelCpos2,{"ED2_TX_SE",,AVSX3("ED2_TX_SE",5),AVSX3("ED2_TX_SE",6)}),)
      nPos := ASCAN(aSelCpos2,{|x| x[1]="ED2_UMNCM"})
      If(nPos>0,aSelCpos2[nPos,3] := "U.M. Compra",)
      nPos := ASCAN(aSelCpos2,{|x| x[1]="ED2_QTDNCM"})
      If(nPos>0,aSelCpos2[nPos,3] := "Qtde. Compra",)
      //AOM - 23/03/2012 - DI Original
      IF AVFLAGS("DI_ORIGINAL")
         nPos := ASCAN(aSelCpos2,{|x| x[1]="ED2_DI_ORI"})
         If(nPos=0,aAdd(aSelCpos2,{"ED2_DI_ORI",,AVSX3("ED2_DI_ORI",5),AVSX3("ED2_DI_ORI",6)}),)
         nPos := ASCAN(aSelCpos2,{|x| x[1]="ED2_ADANT"})
         If(nPos=0,aAdd(aSelCpos2,{"ED2_ADANT",,AVSX3("ED2_ADANT",5),AVSX3("ED2_ADANT",6)}),)
      ENDIF
   EndIf
   nPos := ASCAN(aSelCpos2,{|x| x[1]="ED2_CAMB"})
   If(nPos>0,aSelCpos2[nPos,1] := {||If(WorkED2->ED2_CAMB=="1",STR0142,STR0143)},) //"Sim" # "Não"
ElseIf cCpo=="3"
   If M->ED0_MODAL == ISENCAO
      nPos := ASCAN(aSelCpos3,{|x| x[1]="ED3_UMNCM"})
      If(nPos>0,aSelCpos3[nPos,3] := "U.M. Venda",)
      nPos := ASCAN(aSelCpos3,{|x| x[1]="ED3_QTDNCM"})
      If(nPos>0,aSelCpos3[nPos,3] := "Qtde. Venda",)
      nPos := ASCAN(aSelCpos3,{|x| x[1]="ED3_SALNCM"})
      If(nPos>0,aSelCpos3[nPos,3] := "Saldo Venda",)
   EndIf
ElseIf cCpo=="4"
   If M->ED0_MODAL == ISENCAO
      nPos := ASCAN(aSelCpos4,{|x| x[1]="ED4_UMNCM"})
      If(nPos>0,aSelCpos4[nPos,3] := "U.M. Compra",)
      nPos := ASCAN(aSelCpos4,{|x| x[1]="ED4_QTDNCM"})
      If(nPos>0,aSelCpos4[nPos,3] := "Qtde. Compra",)

      nPos := ASCAN(aSelCpos4A,{|x| x[1]="ED4_UMNCM"})
      If(nPos>0,aSelCpos4A[nPos,3] := "U.M. Compra",)
      nPos := ASCAN(aSelCpos4A,{|x| x[1]="ED4_QTDNCM"})
      If(nPos>0,aSelCpos4A[nPos,3] := "Qtde. Compra",)
   EndIf
   nPos := ASCAN(aSelCpos4,{|x| x[1]="ED4_CAMB"})
   If(nPos>0,aSelCpos4[nPos,1] := {||If(WorkED4->ED4_CAMB=="1",STR0142,STR0143)},) //"Sim" # "Nao"
   nPos := ASCAN(aSelCpos4,{|x| x[1]="ED4_QT_LI"})
   If(nPos>0,aSelCpos4[nPos,1] := {||If(WorkED4->ED4_QT_LI<0,0,WorkED4->ED4_QT_LI)},)
   nPos := ASCAN(aSelCpos4,{|x| x[3]="Saldo Qtd.DI"})
   If(nPos>0,aSelCpos4[nPos,1] := {||If(WorkED4->ED4_QT_DI<0,0,WorkED4->ED4_QT_DI)} ,)
   nPos := ASCAN(aSelCpos4,{|x| x[3]="Saldo NCM LI"})
   If nPos>0
      aSelCpos4[nPos,1] := {||If(WorkED4->ED4_SNCMLI<0,0,WorkED4->ED4_SNCMLI)}
      If(M->ED0_MODAL == ISENCAO,aSelCpos4[nPos,3] := "Saldo Compra LI",)
   EndIf
   nPos := ASCAN(aSelCpos4,{|x| x[3]="Saldo NCM DI"})
   If nPos>0
      aSelCpos4[nPos,1] := {||If(WorkED4->ED4_SNCMDI<0,0,WorkED4->ED4_SNCMDI)}
      If(M->ED0_MODAL == ISENCAO,aSelCpos4[nPos,3] := "Saldo Compra DI",)
   EndIf

   nPos := ASCAN(aSelCpos4A,{|x| x[1]="ED4_CAMB"})
   If(nPos>0,aSelCpos4A[nPos,1] := {||If(WorkED4->ED4_CAMB=="1",STR0142,STR0143)},) //"Sim" # "Nao"
   nPos := ASCAN(aSelCpos4A,{|x| x[1]="ED4_QT_LI"})
   If(nPos>0,aSelCpos4A[nPos,1] := {||If(WorkED4->ED4_QT_LI<0,0,WorkED4->ED4_QT_LI)},)
   nPos := ASCAN(aSelCpos4A,{|x| x[3]="Saldo Qtd.DI"})
   If(nPos>0,aSelCpos4A[nPos,1] := {||If(WorkED4->ED4_QT_DI<0,0,WorkED4->ED4_QT_DI)} ,)
   nPos := ASCAN(aSelCpos4A,{|x| x[3]="Saldo NCM LI"})
   If nPos>0
      aSelCpos4A[nPos,1] := {||If(WorkED4->ED4_SNCMLI<0,0,WorkED4->ED4_SNCMLI)}
      If(M->ED0_MODAL == ISENCAO,aSelCpos4A[nPos,3] := "Saldo Compra LI",)
   EndIf
   nPos := ASCAN(aSelCpos4A,{|x| x[3]="Saldo NCM DI"})
   If nPos>0
      aSelCpos4A[nPos,1] := {||If(WorkED4->ED4_SNCMDI<0,0,WorkED4->ED4_SNCMDI)}
      If(M->ED0_MODAL == ISENCAO,aSelCpos4A[nPos,3] := "Saldo Compra DI",)
   EndIf
EndIf

Return .T.

*------------------------------*
Static Function ViewDesc(cAlias)
*------------------------------*
LOCAL oDLGDescr, mDescGet, oFont1
Local L1:=15, L2:=265, C1:=00, C2:=370
Local LS:=103,CS:=150

Define FONT oFont1 NAME "Courier New" SIZE 0,13

If cAlias=="ED2"
   If !Empty(M->ED2_ITEM)
      If cFilSB1 <> SB1->B1_FILIAL .or. SB1->B1_COD <> M->ED2_ITEM
         SB1->(dbSetOrder(1))
         SB1->(dbSeek(cFilSB1+M->ED2_ITEM))
      EndIf
      mDescGet:=MSMM(SB1->B1_DESC_GI,48)
      cTitulo := STR0166 //"Descrição da L.I."
      //LGS-07/12/2015
      L1:=15; C1:=00; L2:=330; C2:=430
      LS:=100; CS:=206
   Else
      Help(" ",1,"AVG0005174") //"Necessario entrar com o Item para visualizar a Descricao da L.I."
      Return .T.
   EndIf
ElseIf cAlias=="ED0"
   mDescGet:=MSMM(ED0->ED0_RET,60)
   cTitulo := STR0145 //"Retorno do SISCOMEX"
   L1:=125; C1:=00; L2:=600; C2:=795
   LS:=180; CS:=386
EndIf

DEFINE MSDIALOG oDLGDescr TITLE cTitulo From L1,C1 To L2,C2 OF oMainWnd PIXEL

   oDLGDescr:SetFont(oFont1)

   oPanel:= TPanel():New(0,0, "", oDLGDescr,, .T., ,,,0,0,,.T.) //LGS-02/12/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @15,5 GET mDescGet SIZE CS,LS OF oPanel PIXEL HScroll ReadOnly

If cAlias<>"ED0"
   ACTIVATE MSDIALOG oDLGDescr ON INIT EnchoiceBar(oDLGDescr,{||oDLGDescr:End()},{||oDLGDescr:End()}) CENTERED
Else
   ACTIVATE MSDIALOG oDLGDescr ON INIT EnchoiceBar(oDLGDescr,{||oDLGDescr:End()},{||oDLGDescr:End()})
EndIf

RETURN .T.

*----------------------------*
Static Function ACWhen(cCampo)
*----------------------------*
//Local nSW8Ord:=SW8->(IndexOrd()), nSW5Ord:=SW5->(IndexOrd())
//Local nEE9Ord:=EE9->(IndexOrd())
Local aFiliais := {}
Local aAllFil := {}
Local aOrd := {}
Local nInd := 1
Private lRet := .T.

//If lDiExt NOPADO - AOM - 04/10/10
   ED8->( dbSetOrder(3) )
//EndIf

Do Case
   Case cCampo=="AC"
      aOrd := SaveOrd({"EE9","SW5","SW8","ED9"})
      EE9->(dbSetOrder(10))
      SW5->(dbSetOrder(9))
      SW8->(dbSetOrder(5))
      ED9->(DBSETORDER(3))
      If lMultiFil
         aAllFil := AvgSelectFil(.F.)
      EndIf

      If !Empty(M->ED0_AC)

         If lMultiFil
            aFiliais := aAllFil
         Else
            aFiliais := {cFilSW5}
         EndIf
         For nInd := 1  to  Len(aFiliais)
            If SW5->(dbSeek(aFiliais[nInd]+M->ED0_AC))
               lRet := .F.
               Exit
            EndIf
         Next nInd

         If lRet
            If lMultiFil
               aFiliais := aAllFil
            Else
               aFiliais := {cFilSW8}
            EndIf
            For nInd := 1  to  Len(aFiliais)
               If SW8->( DBSeek(aFiliais[nInd]+M->ED0_AC) )
                  lRet := .F.
                  Exit
               EndIf
            Next nInd
         EndIf

         If lRet
            If ED8->( DBSeek(cFilED8+M->ED0_AC) )  //lDiExt  .And.  - NOPADO  AOM - 04/11/10
               lRet := .F.
            EndIf
         EndIf

         If lRet
            If lMultiFil
               aFiliais := aAllFil
            Else
               aFiliais := {cFilEE9}
            EndIf
            For nInd := 1  to  Len(aFiliais)
               If EE9->(dbSeek(aFiliais[nInd]+M->ED0_AC)) .and. M->ED0_MODAL == SUSPENSAO
                  lRet := .F.
                  Exit
               ElseIf !Empty(M->ED0_AC) .and. ED9->(DBSEEK(cFilED9+M->ED0_AC)) // igor chiba 07/04/2009
                  lRet := .F.
                  Exit
               EndIf
            Next nInd
         EndIf
      EndIf
      RestOrd(aOrd)
      //ED9->(DBSETORDER(nED9Ord))
      //EE9->(dbSetOrder(nEE9Ord))
      //SW5->(dbSetOrder(nSW5Ord))
      //SW8->(dbSetOrder(nSW8Ord))
   Case cCampo == "DT_REG"
      If !Empty(M->ED0_DT_VA2)
         lRet := .F.
      EndIf
   Case cCampo == "DT_VA1"
      If Empty(M->ED0_DT_REG) .or. !Empty(M->ED0_DT_VA2)
         lRet := .F.
      EndIf
   Case cCampo == "DT_VA2"
      If Empty(M->ED0_DT_VA1) .or. !Empty(M->ED0_DT_PR1)
         lRet := .F.
      EndIf
   Case cCampo == "DT_PR1"
      If Empty(M->ED0_DT_VA2) .or. M->ED0_PROAP1 == "1"
         lRet := .F.
      EndIf
   Case cCampo == "DT_PR2"
      If Empty(M->ED0_DT_PR1) .or. M->ED0_PROAP1 <> "1" .or. M->ED0_PROAP2 == "1"
         lRet := .F.
      EndIf
   Case cCampo == "DT_PR3"
      If Empty(M->ED0_DT_PR2) .or. M->ED0_PROAP2 <> "1" .or. M->ED0_PROAP3 == "1"
         lRet := .F.
      EndIf
   Case cCampo == "PROAP1"
      If Empty(M->ED0_DT_PR1)
         lRet := .F.
      EndIf
   Case cCampo == "PROAP2"
      If Empty(M->ED0_DT_PR2)
         lRet := .F.
      EndIf
   Case cCampo == "PROAP3"
      If Empty(M->ED0_DT_PR3)
         lRet := .F.
      EndIf
   Case Left(cCampo,4) == "CNPJ"
      If !Right(cCampo,2) $("11/12/13/14/15/16/17/18/19/20")
         If M->ED0_TIPOAC <> "02" .and. M->ED0_TIPOAC <> "03"
            lRet := .F.
         EndIf
      ElseIf M->ED0_TIPOAC <> "03"
         lRet := .F.
      EndIf
   Case cCampo == "PROD"
      If !lIncluiAux .and. !Empty(Alltrim(WorkED1->ED1_PROD))
         lRet:=.F.
      EndIf
   Case cCampo == "1NCM"
      If !Empty(Alltrim(M->ED1_PROD)) .and. M->ED0_MODAL <> ISENCAO
         lRet:=.F.
      EndIf
   Case cCampo == "ITEM"
      If !lIncluiAux .and. !Empty(Alltrim(WorkED2->ED2_ITEM))
         lRet:=.F.
      EndIf
   Case cCampo == "2NCM"
      If !Empty(Alltrim(M->ED2_ITEM)) .and. M->ED0_MODAL <> ISENCAO
         lRet:=.F.
      EndIf
   Case cCampo == "2QTD"
      If M->ED2_NCM == NCMGENERICA
         M->ED2_QTD := 0
         lRet:=.F.
      EndIf
   Case cCampo == "CAMB"
      If M->ED0_MODAL <> SUSPENSAO
         lRet:=.F.
      EndIf
EndCase

Return lRet

*-------------------------------*
Static Function ValCopia(cPedido)
*-------------------------------*
Local nRegED0:=ED0->(RecNo()), lRet:=.T.

If ED0->(dbSeek(cFilED0+cPedido))
   Help(" ",1,"AVG0005171") //"Ja existe este numero de Pedido de Drawback cadastrado no sistema. Entre com um numero valido."
   lRet := .F.
EndIf
ED0->(dbGoTo(nRegED0))

Return lRet

*------------------------*
Static Function ValGetAd()
*------------------------*
Local nPosAdicao

nPosAdicao := ASCAN(aAdicao,{|x| x[1]==WorkDI->ED2_HAWB .and. x[2]==WorkDI->ED2_INVOIC .and. x[3]==WorkDI->ED2_PO_NUM .and. x[4]==WorkDI->ED2_POSICA .and. x[5]==WorkDI->ED2_PGI_NU})
If nPosAdicao > 0 .or. WorkDI->MARCA == cMarca
   Return .F.
Else
   Return .T.
EndIf

*------------------------------*
Static Function GeraValAto(nVal)
*------------------------------*
Local cData, nDec, cAno
nDec := (nVal_Ato - Int(nVal_Ato)) * 100

If nVal = 1
   cAno := Alltrim(Str(Year(dDataBase)-Int(nVal_Ato),4))
   If (Month(dDataBase) - nDec) <= 0
      cData := Alltrim(Str(Val(cAno)-1,4))+Alltrim(StrZero(12+(Month(dDataBase) - nDec),2))+Alltrim(StrZero(Day(dDataBase),2))
   Else
      cData := Alltrim(Str(Val(cAno),4))+Alltrim(StrZero(Month(dDataBase) - nDec,2))+Alltrim(StrZero(Day(dDataBase),2))
   EndIf
Else
   If (Month(dDataBase) - nDec) <= 0
      cData := Alltrim(Str(Year(dDataBase)-1,4))+Alltrim(StrZero(12+(Month(dDataBase) - nDec),2))+Alltrim(StrZero(Day(dDataBase),2))
   Else
      cData := Alltrim(Str(Year(dDataBase),4))+Alltrim(StrZero(Month(dDataBase) - nDec,2))+Alltrim(StrZero(Day(dDataBase),2))
   EndIf
EndIf

Return cData

*-----------------------------------*
Static Function ValApuracao(cChamada)
*-----------------------------------*
Local lRet := .T.
nVal_Ato:=EasyGParam("MV_VAL_ATO",,2)
If Empty(M->ED0_IMPORT) .or. Empty(M->ED0_PD)
   Help(" ",1,"AVG0005176") //"Necessario preencher os campos Importador e Pedido de Drawback para fazer a Apuracao."
   lRet:=.F.
ElseIf nVal_Ato < 0
   Help(" ",1,"AVG0005177",,Alltrim(Str(nVal_Ato))+". ",2,16) //"Parametro MV_VAL_ATO preenchido com um valor invalido " # "Entre com valores positivos."
   lRet:=.F.
ElseIf nVal_Ato = 0
   Help(" ",1,"AVG0005178") //"Parametro MV_VAL_ATO preenchido com um valor invalido "
   lRet:=.F.
ElseIf "," $ SX6->X6_CONTEUD
   Help(" ",1,"AVG0005179") //"Parametro MV_VAL_ATO nao pode ter separador decimal com ',' e sim com '.'"
   lRet:=.F.
ElseIf (nVal_Ato - Int(nVal_Ato)) > 0.11
   Help(" ",1,"AVG0005180") //"Parametro MV_VAL_ATO preenchido com um valor invalido " # "Entre com valores decimais para meses entre 0 e 0.11"
   lRet:=.F.
EndIf

Return lRet

*-----------------------------------*
Function AC400Modal(cAlias,nReg,nOpc)
*-----------------------------------*
Local oDlgMd, nOp:=0, oCbxModal
Private cModal:=Space(1), aModal:={STR0151,STR0152} //"1 - Suspensao" # "2 - Isencao"

If ! lVolta

   DEFINE MSDIALOG oDlgMd TITLE STR0153 ; //"Modalidade do Ato Concessorio"
          FROM 12,05 To 20,45 OF GetwndDefault()

      @01,04 SAY AVSX3("ED0_MODAL",5) of oDlgMd
      cModal := SUSPENSAO
      @01,08 ComboBox oCbxModal Var cModal Items aModal Valid (!Empty(cModal)) SIZE 52,08 of oDlgMd

      DEFINE SBUTTON FROM 40,45 TYPE 1 ACTION (nOp:=1,oDlgMd:End()) ENABLE OF oDlgMd
      DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlgMd:End()) ENABLE OF oDlgMd

   ACTIVATE MSDIALOG oDlgMd CENTERED

   If nOp = 1
      lVolta := .T.
      AC400Manut(cAlias,nReg,nOpc)
   EndIf
Else
   lVolta := .F.
EndIf

Return .T.

*---------------------------*
Static Function ClicksMark3()
*---------------------------*
If WorkED2->ED2_MARCA <> cMarca
   AC400PIManut(4,.T.)
Else
   AC400Marca(.F.)
EndIf

Return .T.

*----------------------------------------------*
Static Function VerED4Saldo(cTipo,cAlias,nQuant)
*----------------------------------------------*
Local lRet:=.T., nOldRec:=WorkED4->(RecNo())
Local nQtdCal, lM:=If(cAlias=="M",.T.,.F.), nQtdCal2
Local cImport := ""

//AOM - 10/11/2011
If AvFlags("SEQMI")
   cImport :=  &(cAlias+"->ED2_IMPORT")
EndIf

WorkED4->(dbSetOrder(1))
If WorkED4->(dbSeek(If(lM,;
                       M->ED2_NCM + M->ED2_ITEM + M->ED2_CAMB + Str(M->ED2_PERCPE,5,2) + iif(lED2Umanex,;
                                                                                             If(Empty(M->ED2_UMANEX), M->ED2_UMNCM, M->ED2_UMANEX),;
                                                                                             M->ED2_UMNCM) + cImport,;
                       (cAlias)->ED2_NCM + (cAlias)->ED2_ITEM + (cAlias)->ED2_CAMB + Str((cAlias)->ED2_PERCPE,5,2) + iif(lED2Umanex,;
                                                                                                                     If(Empty((cAlias)->ED2_UMANEX), (cAlias)->ED2_UMNCM, (cAlias)->ED2_UMANEX),;
                                                                                                                     (cAlias)->ED2_UMNCM) + cImport)))  // ACSJ - 17/11/2004

   If cTipo == "VALID"
      //AAF 16/04/05 - Verifica se a diferenca entre percentual de perda e aprovado é menor que zero.
      If (WorkED4->ED4_QT_DI+(M->ED2_QTD-(((Max(M->ED2_PERCPE - M->ED2_PERCAP,0) * M->ED2_QTD)/100))-WorkED2->ED2_QTDCAL)) < 0 .or. ;
         (WorkED4->ED4_QT_LI+(M->ED2_QTD-(((Max(M->ED2_PERCPE - M->ED2_PERCAP,0) * M->ED2_QTD)/100))-WorkED2->ED2_QTDCAL)) < 0
         lRet := .F.
      EndIf
   ElseIf cTipo == "VALID2"
      nQtdCal  := M->ED2_QTDNCM - (((Max(M->ED2_PERCPE - M->ED2_PERCAP,0) * M->ED2_QTDNCM)/100))
      nQtdCal2 := WorkED2->ED2_QTDNCM - (((Max(WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP,0) * WorkED2->ED2_QTDNCM)/100))
      If (WorkED4->ED4_SNCMDI+Round(nQtdCal-nQtdCal2,5)) < 0 .or. ;
         (WorkED4->ED4_SNCMLI+Round(nQtdCal-nQtdCal2,5)) < 0
         lRet := .F.
      EndIf
   ElseIf cTipo == "ESTORNO"
      If cAlias == "M"
         If (M->ED0_TIPOAC<>GENERICO .or. Alltrim(M->ED2_NCM)<>NCMGENERICA) .and. ((WorkED4->ED4_QT_LI-WorkED2->ED2_QTDCAL) < 0 .or. (WorkED4->ED4_QT_DI-WorkED2->ED2_QTDCAL) < 0)
            lRet := .F.
         ElseIf M->ED0_TIPOAC==GENERICO .and. ((WorkED4->ED4_VL_LI-WorkED2->ED2_VALCAL) < 0 .or. (WorkED4->ED4_VL_DI-WorkED2->ED2_VALCAL) < 0)
            lRet := .F.
         EndIf
      Else
         //AOM - 10/11/2011
         If AvFlags("SEQMI")
            cImport := WorkED2->ED2_IMPORT
         EndIf
         WorkED4->(dbSeek(WorkED2->ED2_NCM+WorkED2->ED2_ITEM+WorkED2->ED2_CAMB+Str(WorkED2->ED2_PERCPE,5,2)+;
            iif(lED2Umanex,If(Empty(WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM,WorkED2->ED2_UMANEX),WorkED2->ED2_UMNCM)+cImport))
         If (M->ED0_TIPOAC<>GENERICO .or. Alltrim(WorkED2->ED2_NCM)<>NCMGENERICA) .and. ((WorkED4->ED4_QT_LI-WorkED2->ED2_QTDCAL) < 0 .or. (WorkED4->ED4_QT_DI-WorkED2->ED2_QTDCAL) < 0)
            lRet := .F.
         ElseIf M->ED0_TIPOAC==GENERICO .and. ((WorkED4->ED4_VL_LI-WorkED2->ED2_VALCAL) < 0 .or. (WorkED4->ED4_VL_DI-WorkED2->ED2_VALCAL) < 0)
            lRet := .F.
         EndIf
      EndIf
   ElseIf cTipo == "ALTERA"
      If (WorkED4->ED4_QT_DI+(WorkED1->ED1_QTD*nQuant-WorkED2->ED2_QTD)) < 0 .or. ;
         (WorkED4->ED4_QT_LI+(WorkED1->ED1_QTD*nQuant-WorkED2->ED2_QTD)) < 0
         lRet := .F.
      EndIf
   ElseIf cTipo == "VALVALOR"
      nQtdCal  := M->ED2_VALEMB - ((((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_VALEMB)/100))
      nQtdCal2 := WorkED2->ED2_VALEMB - ((((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_VALEMB)/100))
      If (WorkED4->ED4_VL_DI+(nQtdCal-nQtdCal2)) < 0 .or. ;
         (WorkED4->ED4_VL_LI+(nQtdCal-nQtdCal2)) < 0
        lRet := .F.
       EndIf
   ElseIf cTipo == "MARCA" .and. Round(WorkED4->ED4_QTDNCM - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED4->ED4_QTDNCM)/100 ,5) <> WorkED4->ED4_SNCMLI
      If WorkED2->ED2_PERCPE > WorkED2->ED2_PERCAP
         nQtdCal := WorkED2->ED2_QTD - ((WorkED2->ED2_PERCPE - WorkED2->ED2_PERCAP) * WorkED2->ED2_QTD)/100
      Else
         nQtdCal := WorkED2->ED2_QTD
      EndIf
      If (M->ED0_TIPOAC<>GENERICO .or. Alltrim(WorkED2->ED2_NCM)<>NCMGENERICA) .and. ((WorkED4->ED4_QT_LI - nQtdCal) < 0 .or. (WorkED4->ED4_QT_DI - nQtdCal) < 0)
         lRet := .F.
      ElseIf M->ED0_TIPOAC==GENERICO .and. ((WorkED4->ED4_VL_LI - nQtdCal) < 0 .or. (WorkED4->ED4_VL_DI - nQtdCal) < 0)
         lRet := .F.
      EndIf
   ElseIf cTipo == "MANUT" .and. WorkED4->ED4_QTDNCM <> WorkED4->ED4_SNCMLI
      If M->ED2_PERCPE > M->ED2_PERCAP
         nQtdCal := ((M->ED2_PERCPE - M->ED2_PERCAP) * M->ED2_QTD)/100
         If (M->ED0_TIPOAC<>GENERICO .or. Alltrim(M->ED2_NCM)<>NCMGENERICA) .and. ((WorkED4->ED4_QT_LI - nQtdCal) < 0 .or. (WorkED4->ED4_QT_DI - nQtdCal) < 0)
            lRet := .F.
         ElseIf M->ED0_TIPOAC==GENERICO .and. ((WorkED4->ED4_VL_LI - nQtdCal) < 0 .or. (WorkED4->ED4_VL_DI - nQtdCal) < 0)
            lRet := .F.
         EndIf
      EndIf
   EndIf
EndIf

If cAlias <> "M"
   WorkED4->(dbGoTo(nOldRec))
EndIf

Return lRet

*----------------------------------------------*
Static Function VerED3Saldo(cTipo,cAlias,nQuant)
*----------------------------------------------*
Local lRet:=.T., nOldRec:=WorkED3->(RecNo())
Local lM:=If(cAlias=="M",.T.,.F.)

If lIndPercAg
   If lM
      cChaveED3 := M->ED1_NCM+M->ED1_PROD+Str(M->ED1_PERCAG,5,2)+;
                iif(lED1Umanex,If(Empty(M->ED1_UMANEX),M->ED1_UMNCM,M->ED1_UMANEX),M->ED1_UMNCM)
   Else
      cChaveED3 := (cAlias)->ED1_NCM+(cAlias)->ED1_PROD+Str((cAlias)->ED1_PERCAG,5,2)+;
                iif(lED1Umanex,If(Empty((cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM)
   EndIf
Else
   If lM
      cChaveED3 := M->ED1_NCM+M->ED1_PROD+;
                iif(lED1Umanex,If(Empty(M->ED1_UMANEX),M->ED1_UMNCM,M->ED1_UMANEX),M->ED1_UMNCM)
   Else
      cChaveED3 := (cAlias)->ED1_NCM+(cAlias)->ED1_PROD+;
                iif(lED1Umanex,If(Empty((cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM,(cAlias)->ED1_UMANEX),(cAlias)->ED1_UMNCM)
   EndIf
EndIf

WorkED3->(dbSetOrder(1))
WorkED3->(dbSeek(cChaveED3))

If cTipo == "VALID"
   If M->ED1_QTD < (WorkED1->ED1_QTD-WorkED3->ED3_SALDO)
      lRet := .F.
   EndIf
ElseIf cTipo == "ESTORNO"
   If (WorkED3->ED3_SALDO-M->ED1_QTD) < 0 .or. (WorkED3->ED3_SAL_SE-M->ED1_VAL_SE) < 0 .or. ;
      (WorkED3->ED3_SAL_CO-(M->ED1_VAL_EM - M->ED1_VALCOM)) < 0
      lRet := .F.
   EndIf
EndIf

If cAlias <> "M"
   WorkED3->(dbGoTo(nOldRec))
EndIf

Return lRet

*------------------------------------*
Static Function AtuIsenParcial(cAlias,lDiED8)
*------------------------------------*
Local nED1Rec:=ED1->(RecNo()), nED2Rec:=ED2->(RecNo()), nED0Rec:=ED0->(RecNo())
Local nED1Ord:=ED1->(IndexOrd()), nED2Ord:=ED2->(IndexOrd()), nED0Ord:=ED0->(IndexOrd())
Local cChave := "" //RRC - 21/05/2012 - Utilizada na chave de busca na tabela ED2 (Itens a Importar)
Default lDiED8 := .F.

If cAlias=="EE9"
   ED1->(dbSetOrder(5))
   If ED1->(dbSeek(cFilED1+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
      ED0->(dbSetOrder(1))
      ED0->(dbSeek(cFilED0+ED1->ED1_PD))
      EE9->EE9_ATOCON := If(Empty(ED0->ED0_AC),ED0->ED0_PD,ED0->ED0_AC)
      EE9->EE9_FASEDR := If(Empty(ED0->ED0_AC),"1","2")
      ED0->(dbSetOrder(nED0Ord))
      ED0->(dbGoTo(nED0Rec))

   EndIf
   ED1->(dbSetOrder(nED1Ord))
   ED1->(dbGoTo(nED1Rec))

ElseIf cAlias == "ED9" .AND. lReExt
// Igor Chiba 07/04/2009
   ED9->ED9_ATOCON := If(Empty(ED0->ED0_AC),ED0->ED0_PD,ED0->ED0_AC)
   ED9->ED9_FASEDR := If(Empty(ED0->ED0_AC),"1","2")
//FIM Igor Chiba 07/04/2009
Else
   ED2->(dbSetOrder(4))
   //RRC - 21/05/2012 - Se existir o campo "ED8_PEDIDO" e for Compra Nacional, a busca será diferente da Importação
   If AvFlags("COMPRAS NACIONAIS") .And. Empty(ED8->ED8_DI_NUM)
      cChave := "ED8->ED8_INVOIC+ED8->ED8_PEDIDO+ED8->ED8_POSDI+ED8->ED8_LI_NUM" //Existem campos válidos para Compra Nacional que não servem para Importação
   Else
      cChave := "ED8->ED8_INVOIC+CriaVar('W8_PO_NUM')+ED8->ED8_POSDI+ED8->ED8_LI_NUM"
   EndIf

   If (!lDiED8 .AND. ED2->(dbSeek(cFilED2+SW8->W8_HAWB+SW8->W8_INVOICE+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM)) ) .OR.;
      (lDiED8 .AND.  ED2->(dbSeek(cFilED2+CriaVar("ED2_HAWB")+&(cChave))) )

      ED0->(dbSetOrder(1))
      ED0->(dbSeek(cFilED0+ED2->ED2_PD))
      If !lDiED8
         SW8->W8_ACISEN := If(Empty(ED0->ED0_AC),ED0->ED0_PD,ED0->ED0_AC)
         SW8->W8_ADICAO := ED2->ED2_ADICAO
      Else
         ED8->ED8_ACISEN := If(Empty(ED0->ED0_AC),ED0->ED0_PD,ED0->ED0_AC)
         ED8->ED8_ADICAO := ED2->ED2_ADICAO
      EndIf
      ED0->(dbSetOrder(nED0Ord))
      ED0->(dbGoTo(nED0Rec))
   EndIf
   ED2->(dbSetOrder(nED2Ord))
   ED2->(dbGoTo(nED2Rec))
EndIf

Return .T.

*-------------------------------------*
Static Function ValValor(cCampo,cAlias)
*-------------------------------------*
Local lRet:=.T., lM:=If(cAlias=NIL,.T.,.F.)

Do Case
   Case cCampo == "ED1_PESO"
      If cFilSB1Aux <> (cAliasSB1)->B1_FILIAL .or. (cAliasSB1)->B1_COD <> If(lM,M->ED1_PROD,(cAlias)->ED1_PROD)
         (cAliasSB1)->(dbSetOrder(1))
         (cAliasSB1)->(dbSeek(cFilSB1Aux+If(lM,M->ED1_PROD,(cAlias)->ED1_PROD)))
      EndIf
      If M->ED0_MODAL <> ISENCAO
         If Len(Alltrim(Str(Int(Round((cAliasSB1)->B1_PESO * If(lM,M->ED1_QTD,(cAlias)->ED1_QTD),AVSX3("ED1_PESO",4)))))) > (AVSX3("ED1_PESO",3) - AVSX3("ED1_PESO",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005181") //"Quantidade estoura o limite de peso."
         EndIf
      Else
         If Len(Alltrim(Str(Int(Round((cAliasSB1)->B1_PESO * If(lM,M->ED1_QTDNCM,(cAlias)->ED1_QTDNCM),AVSX3("ED1_PESO",4)))))) > (AVSX3("ED1_PESO",3) - AVSX3("ED1_PESO",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005181") //"Quantidade estoura o limite de peso."
         EndIf
      EndIf
   Case cCampo == "ED1_VAL_EM"
      If M->ED0_MODAL <> ISENCAO
         If lM .and. Len(Alltrim(Str(Int(Round(M->ED1_QTD * M->ED1_PRCUNI,AVSX3("ED1_VAL_EM",4)))))) > (AVSX3("ED1_VAL_EM",3) - AVSX3("ED1_VAL_EM",4)) -1
            lRet:=.F.
            Help(" ",1,"AVG0005182") //"Valor estoura o limite do Valor no Local de Embarque."
         ElseIf !lM .and. Len(Alltrim(Str(Int(Round((cAlias)->ED1_QTD * (cAlias)->ED1_PRCUNI,AVSX3("ED1_VAL_EM",4)))))) > (AVSX3("ED1_VAL_EM",3) - AVSX3("ED1_VAL_EM",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005182") //"Valor estoura o limite do Valor no Local de Embarque."
         EndIf
      Else
         If lM .and. Len(Alltrim(Str(Int(Round(M->ED1_QTDNCM * M->ED1_PRCUNI,AVSX3("ED1_VAL_EM",4)))))) > (AVSX3("ED1_VAL_EM",3) - AVSX3("ED1_VAL_EM",4)) -1
            lRet:=.F.
            Help(" ",1,"AVG0005182") //"Valor estoura o limite do Valor no Local de Embarque."
         ElseIf !lM .and. Len(Alltrim(Str(Int(Round((cAlias)->ED1_QTDNCM * (cAlias)->ED1_PRCUNI,AVSX3("ED1_VAL_EM",4)))))) > (AVSX3("ED1_VAL_EM",3) - AVSX3("ED1_VAL_EM",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005182") //"Valor estoura o limite do Valor no Local de Embarque."
         EndIf
      EndIf
   Case cCampo == "ED1_QTD"
      //If M->ED1_QTDNCM<>0 .and. Len(Alltrim(Str(Int(Round(AVTransUnid(M->ED1_UMNCM,M->ED1_UMPROD,M->ED1_PROD,M->ED1_QTDNCM),AVSX3("ED1_QTD",4)))))) > (AVSX3("ED1_QTD",3) - AVSX3("ED1_QTD",4)) - 1
      // PLB 18/07/07
      If M->ED1_QTDNCM <> 0  .And.  !Empty(M->ED1_UMNCM)  .And.  Len(Alltrim(Str(Int(Round(AVTransUnid(M->ED1_UMNCM,M->ED1_UMPROD,M->ED1_PROD,M->ED1_QTDNCM),AVSX3("ED1_QTD",4)))))) > (AVSX3("ED1_QTD",3) - AVSX3("ED1_QTD",4)) - 1
         lRet:=.F.
         Help(" ",1,"AVG0005183") //"Quantidade estoura o limite da Quantidade na Unidade de Medida da NCM."
      EndIf
   Case cCampo == "ED1_QTDNCM"
      If lM
         //If M->ED1_QTD<>0 .and. Len(Alltrim(Str(Int(Round(AVTransUnid(M->ED1_UMPROD,M->ED1_UMNCM,M->ED1_PROD,M->ED1_QTD),AVSX3("ED1_QTDNCM",4)))))) > (AVSX3("ED1_QTDNCM",3) - AVSX3("ED1_QTDNCM",4)) - 1
        // PLB 18/07/07
         If M->ED1_QTD <> 0  .And.  !Empty(M->ED1_UMNCM)  .And.  Len(Alltrim(Str(Int(Round(AVTransUnid(M->ED1_UMPROD,M->ED1_UMNCM,M->ED1_PROD,M->ED1_QTD),AVSX3("ED1_QTDNCM",4)))))) > (AVSX3("ED1_QTDNCM",3) - AVSX3("ED1_QTDNCM",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005183") //"Quantidade estoura o limite da Quantidade na Unidade de Medida da NCM."
         EndIf
      Else
         If cFilSB1Aux <> (cAliasSB1)->B1_FILIAL .or. (cAliasSB1)->B1_COD <> M->ED1_PROD
            (cAliasSB1)->(dbSetOrder(1))
            (cAliasSB1)->(dbSeek(cFilSB1Aux+M->ED1_PROD))
         EndIf
         If cFilSYD <> SYD->YD_FILIAL .or. (cAliasSB1)->B1_POSIPI <> SYD->YD_TEC
            SYD->(dbSetOrder(1))
            SYD->(dbSeek(cFilSYD+(cAliasSB1)->B1_POSIPI))
         EndIf
         If Len(Alltrim(Str(Int(Round(AVTransUnid((cAliasSB1)->B1_UM,SYD->YD_UNID,M->ED1_PROD,M->ED1_QTD),AVSX3("ED1_QTDNCM",4)))))) > (AVSX3("ED1_QTDNCM",3) - AVSX3("ED1_QTDNCM",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005183") //"Quantidade estoura o limite da Quantidade na Unidade de Medida da NCM."
         EndIf
      EndIf
   Case cCampo == "ED2_PESO"
      If cFilSB1 <> SB1->B1_FILIAL .or. SB1->B1_COD <> If(lM,M->ED2_ITEM,(cAlias)->ED2_ITEM)
         SB1->(dbSetOrder(1))
         SB1->(dbSeek(cFilSB1+If(lM,M->ED2_ITEM,(cAlias)->ED2_ITEM)))
      EndIf
      If M->ED0_MODAL <> ISENCAO
         If Len(Alltrim(Str(Int(Round(SB1->B1_PESO * If(lM,M->ED2_QTD,(cAlias)->ED2_QTD),AVSX3("ED2_PESO",4)))))) > (AVSX3("ED2_PESO",3) - AVSX3("ED2_PESO",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005181") //"Quantidade estoura o limite de peso."
         EndIf
      Else
         IF FINDFUNCTION("B1PESO")
            SW7->(DbSetOrder(4))
            If !( lMultiFil  .And.  M->ED0_MODAL == ISENCAO )
               cFilAux := cFilSW7
            EndIf
            If lM
               If lMultiFil  .And.  M->ED0_MODAL == ISENCAO
                  cFilAux := M->ED2_FILORI
               EndIf
               SW7->(DbSeek(cFilAux+M->ED2_HAWB+M->ED2_PO_NUM+M->ED2_POSICA+M->ED2_PGI_NU))
            Else
               If lMultiFil  .And.  M->ED0_MODAL == ISENCAO
                  cFilAux := Left((cAlias)->ED2_FILORI,2)
               EndIf
               SW7->(DbSeek(cFilAux+(cAlias)->ED2_HAWB+(cAlias)->ED2_PO_NUM+(cAlias)->ED2_POSICA+(cAlias)->ED2_PGI_NU))
            EndIf
            SW7->(DbSetOrder(1))
            If Len(Alltrim(Str(Int(Round(B1Peso(SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_REG,SW7->W7_FABR,SW7->W7_FORN) * If(lM,M->ED2_QTDNCM,(cAlias)->ED2_QTDNCM),AVSX3("ED2_PESO",4)))))) > (AVSX3("ED2_PESO",3) - AVSX3("ED2_PESO",4)) - 1
               lRet:=.F.
               Help(" ",1,"AVG0005181") //MsgInfo(STR0154) //"Quantidade estoura o limite de peso."
            EndIf
         Else
            If Len(Alltrim(Str(Int(Round(SB1->B1_PESO * If(lM,M->ED2_QTDNCM,(cAlias)->ED2_QTDNCM),AVSX3("ED2_PESO",4)))))) > (AVSX3("ED2_PESO",3) - AVSX3("ED2_PESO",4)) - 1
               lRet:=.F.
               Help(" ",1,"AVG0005181") //MsgInfo(STR0154) //"Quantidade estoura o limite de peso."
            EndIf
         EndIf
      EndIf
   Case cCampo == "ED2_VALEMB"
      If M->ED0_MODAL <> ISENCAO
         If lM .and. Len(Alltrim(Str(Int(Round(M->ED2_QTD * M->ED2_PRCUNI,AVSX3("ED2_VALEMB",4)))))) > (AVSX3("ED2_VALEMB",3) - AVSX3("ED2_VALEMB",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005182") //"Valor estoura o limite do Valor no Local de Embarque."
         ElseIf !lM .and. Len(Alltrim(Str(Int(Round((cAlias)->ED2_QTD * (cAlias)->ED2_PRCUNI,AVSX3("ED2_VALEMB",4)))))) > (AVSX3("ED2_VALEMB",3) - AVSX3("ED2_VALEMB",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005182") //"Valor estoura o limite do Valor no Local de Embarque."
         EndIf
      Else
         If lM .and. Len(Alltrim(Str(Int(Round(M->ED2_QTDNCM * M->ED2_PRCUNI,AVSX3("ED2_VALEMB",4)))))) > (AVSX3("ED2_VALEMB",3) - AVSX3("ED2_VALEMB",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005182") //"Valor estoura o limite do Valor no Local de Embarque."
         ElseIf !lM .and. Len(Alltrim(Str(Int(Round((cAlias)->ED2_QTDNCM * (cAlias)->ED2_PRCUNI,AVSX3("ED2_VALEMB",4)))))) > (AVSX3("ED2_VALEMB",3) - AVSX3("ED2_VALEMB",4)) - 1
            lRet:=.F.
            Help(" ",1,"AVG0005182") //"Valor estoura o limite do Valor no Local de Embarque."
         EndIf
      EndIf
   Case cCampo == "ED2_QTD"
      If !Empty(M->ED2_ITEM) .and. Len(Alltrim(Str(Int(Round(AVTransUnid(M->ED2_UMNCM,M->ED2_UMITEM,M->ED2_ITEM,M->ED2_QTDNCM),AVSX3("ED2_QTD",4)))))) > (AVSX3("ED2_QTD",3) - AVSX3("ED2_QTD",4)) - 1
         lRet:=.F.
         Help(" ",1,"AVG0005183") //"Quantidade estoura o limite da Quantidade na Unidade de Medida da NCM."
      EndIf
   Case cCampo == "ED2_QTDNCM"
      If !Empty(M->ED2_NCM) .and. Len(Alltrim(Str(Int(Round(AVTransUnid(M->ED2_UMITEM,M->ED2_UMNCM,M->ED2_ITEM,M->ED2_QTD),AVSX3("ED2_QTDNCM",4)))))) > (AVSX3("ED2_QTDNCM",3) - AVSX3("ED2_QTDNCM",4)) - 1
         lRet:=.F.
         Help(" ",1,"AVG0005183") //"Quantidade estoura o limite da Quantidade na Unidade de Medida da NCM."
      EndIf
EndCase

Return lRet

*------------------------------*
Static Function ValPesqNCM(cFld)
*------------------------------*
Local lRet := .T.

If cFld=="WorkED1"
   If cFilSYD <> SYD->YD_FILIAL .or. (cAliasSB1)->B1_POSIPI <> SYD->YD_TEC
      SYD->(dbSetOrder(1))
      SYD->(dbSeek(cFilSYD+(cAliasSB1)->B1_POSIPI))
   EndIf
   If (AVTransUnid((cAliasSB1)->B1_UM,SYD->YD_UNID,(cAliasSB1)->B1_COD,0,.T.)) = NIL
      lRet := .F.
   EndIf
Else
   If cFilSYD <> SYD->YD_FILIAL .or. SB1->B1_POSIPI <> SYD->YD_TEC
      SYD->(dbSetOrder(1))
      SYD->(dbSeek(cFilSYD+SB1->B1_POSIPI))
   EndIf
   If (AVTransUnid(SB1->B1_UM,SYD->YD_UNID,SB1->B1_COD,0,.T.)) = NIL
      lRet := .F.
   EndIf
EndIf

Return lRet

*-------------------------------------*
Static Function CalcValEmb(cAlias,nQtd)
*-------------------------------------*
Local nPrcUni, nValEmb:=0, cUnid, lCalcVlEmb := .T.

SA5->(dbSetOrder(3))

If cAlias == "WorkDI"
   If WorkDI->(FieldPos("ORIGEM")) > 0 .And. WorkDI->ORIGEM == "ED8" //LGS-11/12/2015
      cUnid      := SB1->B1_UM
      nPrcUni    := SB1->B1_VLREFUS
      lCalcVlEmb := .F.
   Else
      If SA5->A5_PRODUTO<>WorkDI->ED2_ITEM .or. SA5->A5_FABR<>WorkDI->FABR .or. SA5->A5_FORNECE<>WorkDI->FORN
         SA5->(dbSeek(cFilSA5+WorkDI->ED2_ITEM+WorkDI->FABR+WorkDI->FORN))
      EndIf
   EndIf
EndIf

If lCalcVlEmb
   If cAlias=="WorkRE" .or. Empty(SA5->A5_UNID) .or. SA5->A5_VLCOTUS = 0
      If (cAlias=="WorkRE" .and. (cAliasSB1)->B1_VLREFUS<>0) .or. (cAlias=="WorkDI" .and. SB1->B1_VLREFUS<>0)
         cUnid   := If(cAlias=="WorkRE",(cAliasSB1)->B1_UM,SB1->B1_UM)
         nPrcUni := If(cAlias=="WorkRE",(cAliasSB1)->B1_VLREFUS,SB1->B1_VLREFUS)
      EndIf
   Else
      cUnid   := SA5->A5_UNID
      If SA5->A5_MOE_US <> DOLAR
         nPrcUni := ConvVal(SA5->A5_MOE_US,SA5->A5_VLCOTUS)
      Else
         nPrcUni := SA5->A5_VLCOTUS
      EndIf
   EndIf
EndIf

If !Empty(cUnid)
   If (cAlias=="WorkRE" .and. WorkRE->UNID<>cUnid) .or. (cAlias=="WorkDI" .and. WorkDI->UNID<>cUnid)
      If cAlias=="WorkRE"
         nValEmb := nPrcUni * AVTransUnid(WorkRE->UNID,cUnid,WorkRE->ED1_PROD,nQtd)
      Else
         nValEmb := nPrcUni * AVTransUnid(WorkDI->UNID,cUnid,WorkDI->ED2_ITEM,nQtd)
      EndIf
   Else
      nValEmb := nPrcUni * nQtd
   EndIf
ElseIf nValEmb == 0
   WorkDI->MENSA:= STR0183+STR0192 // "Aviso:" ###" Valor sem atualização. Atualize o valor de referencia no cadastro de produto quando for comprovação externa Val.Ref.US$(B1_VLREFUS) ou no cadastro da amarração Produto/Fornecedor campo Vlr.Cotaçao(A5_VLCOTUS)."
ElseIf nValEmb < WorkDI->ED2_VALORI
   WorkDI->MENSA:= STR0183+STR0193+Alltrim(Trans(nValEmb,AVSX3("ED2_VALORI",6)))+STR0194+Alltrim(Trans(WorkDI->ED2_VALORI,AVSX3("ED2_VALORI",6)))+")." //"Aviso:" ###" Valor Atualizado (" ## ") menor que Valor no Embarque("
EndIf

SA5->(dbSetOrder(1))

If nValEmb == 0
   WorkDI->MENSA:= STR0183+STR0192 // "Aviso:" ###" Valor sem atualização."
EndIf

Return nValEmb

*-------------------------------*
Static Function AC400TelaTotais()
*-------------------------------*
Local cPictEmb:=AVSX3("ED4_VALEMB",6)
nPercTo:=M->ED0_PERCTO
cLin := 25

Define Font oFont Name "Arial" Size 0,-12 Bold

//LayOut
@cLin,10  SAY STR0157 SIZE 300,8 PIXEL FONT oFont of oFldTot //"Percentual de tolerancia para o valor dos Itens a Importar em relacao ao valor dos Produtos a Exportar: "
@cLin,310 MSGET nPercTo PICTURE AVSX3("ED0_PERCTO",6) SIZE 40,08 PIXEL of oFldTot WHEN .F.
cLin += 21
@cLin,10  SAY STR0158 SIZE 40,8 PIXEL FONT oFont of oFldTot //"EXPORTACAO"
@cLin,203 SAY STR0159 SIZE 40,8 PIXEL FONT oFont of oFldTot //"IMPORTACAO"
@4.0,1.3  TO 11,21 of oFldTot
@4.0,25.3 TO 11,46 of oFldTot

//Exportação
cLin += 22
@cLin,15  SAY STR0160 SIZE 80,8 PIXEL FONT oFont of oFldTot //"Total c/ Cobertura: US$"
@cLin,85 MSGET Tot_ExpCCob PICTURE AVSX3("ED3_VAL_CO",6) SIZE 65,08 PIXEL of oFldTot WHEN .F.
cLin += 22
@cLin,15  SAY oSaySCobE Prompt STR0161 SIZE 80,8 PIXEL FONT oFont of oFldTot //"Total s/ Cobertura: US$"
@cLin,85 MSGET Tot_ExpSCob PICTURE AVSX3("ED3_VAL_SE",6) SIZE 65,08 PIXEL of oFldTot WHEN .F.
cLin += 22
@cLin,15  SAY STR0162 SIZE 80,8 PIXEL FONT oFont of oFldTot //"Valor do Agente: US$"
@cLin,85 MSGET Tot_PercAg PICTURE AVSX3("ED3_VALCOM",6) SIZE 65,08 PIXEL of oFldTot WHEN .F.
cLin += 22
@cLin,15  SAY STR0163 SIZE 80,8 PIXEL FONT oFont of oFldTot //"TOTAL: US$"
@cLin,85 MSGET Tot_Exp PICTURE AVSX3("ED3_VAL_EM",6) SIZE 65,08 PIXEL of oFldTot WHEN .F.

//Importação
cLin := 69
@cLin,213  SAY STR0160 SIZE 80,8 PIXEL FONT oFont of oFldTot //"Total c/ Cobertura: US$"
@cLin,283 MSGET Tot_ImpCCob PICTURE cPictEmb SIZE 65,08 PIXEL of oFldTot WHEN .F.
cLin += 22
@cLin,213  SAY oSaySCobI Prompt STR0161 SIZE 80,8 PIXEL FONT oFont of oFldTot //"Total s/ Cobertura: US$"
@cLin,283 MSGET Tot_ImpSCob PICTURE cPictEmb SIZE 65,08 PIXEL of oFldTot WHEN .F.
cLin += 22
@cLin,213  SAY STR0164 SIZE 80,8 PIXEL FONT oFont of oFldTot //"Valor da Perda: US$"
@cLin,283 MSGET Tot_PercPe PICTURE AVSX3("ED4_VALCAL",6) SIZE 65,08 PIXEL of oFldTot WHEN .F.
cLin += 22
@cLin,213  SAY STR0163 SIZE 80,8 PIXEL FONT oFont of oFldTot //"TOTAL: US$"
@cLin,283 MSGET Tot_Imp PICTURE cPictEmb SIZE 65,08 PIXEL of oFldTot WHEN .F.

//Rodapé
@162,010 SAY oSay Prompt STR0165 SIZE 300,8 PIXEL FONT oFont of oFldTot //"Percentual Atual: "
@162,310 MSGET PercAtual PICTURE "@E 999,999.99" SIZE 40,08 PIXEL of oFldTot WHEN .F.

Return .T.

*---------------------------------------*
Static Function AC400Totais(cAlias,nTipo)
*---------------------------------------*
Local nValImp, nValPerda  //, nPerc := M->ED0_PERCTO  --> ACSJ 01/12/2004 - Variavel não é usada.

If nTipo = INCLUIR
   If Right(cAlias,3) == "ED1"
      Tot_ExpCCob += (cAlias)->ED1_VAL_EM
      Tot_ExpSCob += (cAlias)->ED1_VAL_SE
      Tot_PercAg  += (cAlias)->ED1_VALCOM
      Tot_Exp     += (cAlias)->ED1_VAL_EM + (cAlias)->ED1_VAL_SE - (cAlias)->ED1_VALCOM
   ElseIf Right(cAlias,3) == "ED2"

      if lED2PerCap  // ACSJ - 23/11/2004
         If (cAlias)->ED2_PERCPE > (cAlias)->ED2_PERCAP
            nValPerda := (Max((cAlias)->ED2_PERCPE - (cAlias)->ED2_PERCAP,0) * (cAlias)->ED2_VALEMB)/100
            nValImp   := (cAlias)->ED2_VALEMB - nValPerda
            If (cAlias)->ED2_CAMB == "1"
               Tot_ImpCCob += nValImp
            Else
               Tot_ImpSCob += nValImp
            EndIf
            Tot_Imp     += nValImp

            If lTemVLCOMPE .AND. (cAlias)->ED2_VLCOPE $ cSim
               Tot_PercPe += nValPerda  // ** GFC - 04/08/06
            EndIf
         Else
            If (cAlias)->ED2_CAMB == "1"
               Tot_ImpCCob+=(cAlias)->ED2_VALEMB
            Else
               Tot_ImpSCob+=(cAlias)->ED2_VALEMB
            EndIf
            Tot_Imp += (cAlias)->ED2_VALEMB
         EndIf
      Else
         If (cAlias)->ED2_PERCPE > 0
            nValPerda := ((cAlias)->ED2_PERCPE * (cAlias)->ED2_VALEMB)/100
            nValImp   := (cAlias)->ED2_VALEMB - nValPerda
            If (cAlias)->ED2_CAMB == "1"
               Tot_ImpCCob += nValImp
            Else
               Tot_ImpSCob += nValImp
            EndIf
            Tot_Imp     += nValImp
            If lTemVLCOMPE .AND. (cAlias)->ED2_VLCOPE $ cSim
               Tot_PercPe += nValPerda  // ** GFC - 04/08/06
            EndIf
         Else
            If (cAlias)->ED2_CAMB == "1"
               Tot_ImpCCob+=(cAlias)->ED2_VALEMB
            Else
               Tot_ImpSCob+=(cAlias)->ED2_VALEMB
            EndIf
            Tot_Imp += (cAlias)->ED2_VALEMB
         EndIf
      Endif

   EndIf
ElseIf nTipo = ESTORNAR
   If Right(cAlias,3) == "ED1"
      Tot_ExpCCob -= (cAlias)->ED1_VAL_EM
      Tot_ExpSCob -= (cAlias)->ED1_VAL_SE
      Tot_PercAg  -= (cAlias)->ED1_VALCOM
      Tot_Exp     -= (cAlias)->ED1_VAL_EM + (cAlias)->ED1_VAL_SE - (cAlias)->ED1_VALCOM
   ElseIf Right(cAlias,3) == "ED2"
      nValPerda := (Max((cAlias)->ED2_PERCPE - (cAlias)->ED2_PERCAP,0) * (cAlias)->ED2_VALEMB)/100
      nValImp   := (cAlias)->ED2_VALEMB - nValPerda
      If (cAlias)->ED2_PERCPE > (cAlias)->ED2_PERCAP

         If lTemVLCOMPE .AND. (cAlias)->ED2_VLCOPE $ cSim
            Tot_PercPe -= nValPerda  // ** GFC - 04/08/06
         EndIf

         If (cAlias)->ED2_CAMB == "1"
            Tot_ImpCCob -= nValImp
         Else
            Tot_ImpSCob -= nValImp
         EndIf
         Tot_Imp     -= nValImp
      Else
         If (cAlias)->ED2_CAMB == "1"
            Tot_ImpCCob -= (cAlias)->ED2_VALEMB
         Else
            Tot_ImpSCob -= (cAlias)->ED2_VALEMB
         EndIf
         Tot_Imp     -= (cAlias)->ED2_VALEMB
      EndIf
   EndIf
EndIf

RodapeTotais()

 If EasyGParam("MV_EDC0005",,.F.) .and. Right(cAlias,3) == "ED2" // integração com Siscomex Web
    M->ED0_PTOTAL := AC401CalcPer()// ALS - 10/12/2007 Atualiza valor do campo virtal quando tiver atualização dos intens a importar
 endif
Return .T.

*----------------------------*
Static Function RodapeTotais()
*----------------------------*
If(Tot_Exp <> 0 , PercAtual := (Tot_Imp * 100) / Tot_Exp , PercAtual := 100 )

//Rodapé
If PercAtual > M->ED0_PERCTO
   IF TYPE("oSay") = "O"
      oSay:NCLRTEXT := CLR_HRED
   ENDIF
Else
   IF TYPE("oSay") = "O"
      oSay:NCLRTEXT := CLR_BLACK
   ENDIF
EndIf
If Tot_ExpSCob <> Round(Tot_ImpSCob,2)//AAF 23/06/05 - Arredondamento para valores, apenas 2 casas decimais.
   IF TYPE("oSaySCobE") = "O"
      oSaySCobE:NCLRTEXT := CLR_HRED
   ENDIF
   IF TYPE("oSaySCobI") = "O"
      oSaySCobI:NCLRTEXT := CLR_HRED
   ENDIF
Else
   IF TYPE("oSaySCobE") = "O"
      oSaySCobE:NCLRTEXT := CLR_BLACK
   ENDIF
   IF TYPE("oSaySCobI") = "O"
      oSaySCobI:NCLRTEXT := CLR_BLACK
   ENDIF
EndIf

Return .T.

*------------------------------------------------------*
Static Function OrganizaSeqSis(cAlias,lCompNac,lRepeat)
*------------------------------------------------------*
Local nOldOrd:=(cAlias)->(IndexOrd())
Local nOldRec:=(cAlias)->(RecNo()), nSeqAux:=1

Default lCompNac := .F.
Default lRepeat  := .T.

If cAlias=="WorkED4" .And. AvFlags("SEQMI") .And. lCompNac
   (cAlias)->(dbSetOrder(6))
   (cAlias)->(dbGoTop())
Else
   (cAlias)->(dbSetOrder(2))
   (cAlias)->(dbGoTop())
   lCompNac := .F.
EndIf

Do While !(cAlias)->(EOF())
   (cAlias)->(RecLock(cAlias,.F.))
   If lCompNac
      (cAlias)->&(Right(cAlias,3)+"_SEQMI") := StrZero(nSeqAux,4,0)
   Else
      (cAlias)->&(Right(cAlias,3)+"_SEQSIS") := StrZero(nSeqAux,3,0)
   EndIf
   (cAlias)->(msUnlock())
   (cAlias)->(dbSkip())
   nSeqAux += 1
EndDo

(cAlias)->(dbSetOrder(nOldOrd))
(cAlias)->(dbGoTo(nOldRec))

if EasyGParam("MV_EDC0005",,.F.) // integração com Siscomex Web
   If lCompNac
      M->ED0_MIED4 := StrZero(nSeqAux,4,0)  // ALS 07/12/2007 - Atualiza valor do ultimo SeqSis
   Else
      M->&("ED0_SEQ"+Right(cAlias,3)) := StrZero(nSeqAux,3,0)  // ALS 07/12/2007 - Atualiza valor do ultimo SeqSis
   EndIf

endif

If cAlias =="WorkED4"  .And. lRepeat
   OrganizaSeqSis(cAlias,.T.,.F.)
EndIf

Return .T.

*--------------------------------------------------------------------------*
Static Function BuscaTxAC(PInd, PData, PFiscal,lMostraMsg,lAnterior,cImpExp)
*--------------------------------------------------------------------------*
Local nTaxa:=0, nAPos

nAPos := aScan(aTaxas,{|x| x[1]==PInd .and. x[2]==PData .and. x[3]==PFiscal .and. x[4]==lAnterior .and. x[5]==cImpExp})
If nAPos > 0
   nTaxa := aTaxas[nAPos,6]
Else
   nTaxa := BuscaTaxa(PInd, PData, PFiscal,lMostraMsg,lAnterior,cImpExp)
   aAdd(aTaxas,{PInd, PData, PFiscal,lAnterior,cImpExp,nTaxa})
EndIf

Return nTaxa

*-------------------------------------------*
Function AC400GrvAdit(cOpcao, nPos, cCampo)  //Gravacao de um Log(ED5)
*-------------------------------------------*
Local cNome_C := cCampo, aAdit:= {}, lSeek
Local cTotalEx:= "ED1_VAL_EM,ED3_VAL_EM", cTotalIm:= "ED4_VALEMB"
Local cPeso   := "ED1_PESO,ED3_PESO,ED4_PESO" , lAgrupa
Local cPictProd := AVSX3("ED1_PROD", 6), cPictItem := AVSX3("ED4_ITEM", 6)
Local cPictUni:=AVSX3("ED2_PRCUNI",6)

Private cUnMedDe:="" //Alcir Alves - 03-05-05
Private  cDe := cPara := cDeQtd := cParaQtd := cDePreco := cParaPreco := cDePeso := ''
Private cParaPeso := cDeValor := cParaValor := '' , cSeek, cUmDe, cUmPara

If Empty(M->ED0_AC)
   Return .T.
EndIf

SB1->(dbSetOrder(1))

Do Case
   Case cOpcao = "ED0"
      cAlias:= "ED0"
      cWork := M->&(cCampo)
      cSeek := ED0->ED0_AC
   Case cOpcao = "ED1"
      cAlias:= "ED1"
      cWork := "WorkED1"
      cSeek := ED1->ED1_AC
   Case cOpcao = "ED3"
      cAlias:= "ED3"
      cWork := "WorkED3"
      cSeek := ED3->ED3_AC
   Case cOpcao = "ED4"
      cAlias:= "ED4"
      cWork := "WorkED4"
      cSeek := ED4->ED4_AC
EndCase

If cAlias # "ED0"
   If cNome_C == "PRECO" .OR. Valtype((cAlias)->&(cNome_C)) == "N"
      If cNome_C == "ED1_QTDNCM" .Or. cNome_C == "ED3_QTDNCM" .Or. cNome_C == "ED4_QTDNCM"
         AC400GrvAdit(cAlias, , "PRECO")
         cUmDe  :=(cAlias)->&((cAlias)+"_UMNCM")
         cUmPara:=(cWork)->&((cAlias)+"_UMNCM")

         cUnMedDe:=(cAlias)->&((cAlias)+"_UMNCM")  ////Alcir Alves - 03-05-05
         If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"UNIDADE_MEDIDA_IMPRESSAO"),)

         cDe := cPara := STR0206+(cAlias)->&((cAlias)+"_ANEXO")+STR0207+If((cAlias) $ ("ED1/ED3"),'exportados : U.M. ','por importar : U.M. ')+cUnMedDe+" - "
      ElseIf cNome_C == "PRECO"
         If cAlias = "ED1"
            cDe := cPara := STR0210+(cAlias)->&((cAlias)+"_ANEXO")+STR0211 //'Item 9 do Anexo ao Pedido de DrawBack n. '###" - exportados : US$ "
            cDe   += Alltrim(Transf((cAlias)->&(cAlias+"_VAL_EM") - ((cAlias)->&(cAlias+"_VAL_EM") * (cAlias)->&(cAlias+"_PERCAG")/100) / (cAlias)->&(cAlias+"_QTDNCM"), cPictUni)) +"  ("+ Alltrim((cAlias)->&((cAlias)+"_PROD"))+")"
            cPara += Alltrim(Transf((cWork)->&(cAlias+"_VAL_EM")- ((cWork)->&(cAlias+"_VAL_EM") * (cWork)->&(cAlias+"_PERCAG")/100) / (cWork)->&(cAlias+"_QTDNCM"), cPictUni)) +"  ("+ Alltrim((cWork)->&((cAlias)+"_PROD"))+")"
         ElseIf cAlias = "ED4"
            cDe := cPara := STR0210+(cAlias)->&((cAlias)+"_ANEXO")+STR0212 //'Item 9 do Anexo ao Pedido de DrawBack n. '###" - por importar : US$ "
            cDe   += Alltrim(Transf((cAlias)->&(cAlias+"_VALEMB")/(cAlias)->&(cAlias+"_QTDNCM"), cPictUni)) +"  ("+ Alltrim((cWork)->&((cAlias)+"_ITEM"))+")"
            cPara += Alltrim(Transf((cWork)->&(cAlias+"_VALEMB")/(cWork)->&(cAlias+"_QTDNCM"), cPictUni)) +"  ("+ Alltrim((cWork)->&((cAlias)+"_ITEM"))+")"
         Else
            cDe := cPara := STR0210+(cAlias)->&((cAlias)+"_ANEXO")+STR0211 //'Item 9 do Anexo ao Pedido de DrawBack n. '###" - exportados : US$ "
            cDe   += Alltrim(Transf((cAlias)->&(cAlias+"_VAL_EM")/(cAlias)->&(cAlias+"_QTDNCM"), cPictUni)) +"  ("+ Alltrim((cWork)->&((cAlias)+"_PROD"))+")"
            cPara += Alltrim(Transf((cWork)->&(cAlias+"_VAL_EM")/(cWork)->&(cAlias+"_QTDNCM"), cPictUni)) +"  ("+ Alltrim((cWork)->&((cAlias)+"_PROD"))+")"
         Endif
      ElseIf cNome_C $ (cPeso)
         cDe := cPara := STR0213+(cAlias)->&((cAlias)+"_ANEXO")+STR0207+If((cAlias) $ ("ED1/ED3"),"exportados : K.G. ","por importar : K.G. ") //'Item 5 do Anexo ao Pedido de DrawBack n. '###" - "###'exportados : US$ '### 'por importar : US$ '
      Elseif cNome_C $ (cTotalEx) .Or. cNome_C == cTotalIm
         cDe := cPara := STR0214+(cAlias)->&((cAlias)+"_ANEXO")+STR0207+If((cAlias) $ ("ED1/ED3"),STR0208, STR0209) //'Item 10 do Anexo ao Pedido de Drawback n. '###" - "###'exportados : US$ '### 'por importar : US$ '
      Endif

      If Empty(cDe)  .And.  Empty(cPara)
         Return .F.
      Else
         If cNome_C <> "PRECO"
            If cAlias $ ("ED1/ED3")
               cDe   += Alltrim(Transf((cAlias)->&(cNome_C),AVSX3(cNome_C,6))) +"  ("+Transf(Alltrim((cWork)->&((cAlias)+"_PROD")), cPictProd)+")"
               cPara += Alltrim(Transf((cWork)->&(cNome_C),AVSX3(cNome_C,6))) +"  ("+Transf(Alltrim((cWork)->&((cAlias)+"_PROD")), cPictProd)+")"
            Else
               If cNome_C == "ED4_PESO" .And. Empty(ED4->ED4_PESO)
                  SB1->(dbSeek(cFilSB1+(cAlias)->&(cNome_C)))
                  cDe   += Alltrim(Transf(SB1->B1_PESO,AVSX3(cNome_C,6))) +"  ("+Transf(Alltrim((cWork)->&((cAlias)+"_ITEM")), cPictItem)+")"
                  cPara += Alltrim(Transf(SB1->B1_PESO,AVSX3(cNome_C,6))) +"  ("+Transf(Alltrim((cWork)->&((cAlias)+"_ITEM")), cPictItem)+")"
               Else
                  cDe   += Alltrim(Transf((cAlias)->&(cNome_C),AVSX3(cNome_C,6))) +"  ("+Transf(Alltrim((cWork)->&((cAlias)+"_ITEM")), cPictItem)+")"
                  cPara += Alltrim(Transf((cWork)->&(cNome_C),AVSX3(cNome_C,6))) +"  ("+Transf(Alltrim((cWork)->&((cAlias)+"_ITEM")), cPictItem)+")"
               Endif
            Endif
         EndIf
      Endif
   ElseIf cNome_C == "ED4_NCM"
      cDe    := cPara := STR0308+ED4->ED4_ANEXO+STR0226+" NCM: " //"Item 4 do Anexo ao Pedido de DrawBack n. "###" - por importar"
      cDe    += TransForm(ED4->ED4_NCM,AvSx3("ED4_NCM",6))+"( "+ED4->ED4_ITEM+" )"
      cPara  += WorkED4->ED4_NCM+"( "+ED4->ED4_ITEM+" )"
   ElseIf cNome_C == "ED3_NCM"
      cDe    := cPara := "Item 4 do Anexo ao Pedido de DrawBack n. "+ED3->ED3_ANEXO+STR0229+" NCM: " //"Item 4 do Anexo ao Pedido de DrawBack n. "###" - exportados"
      cDe    += TransForm(ED3->ED3_NCM,AvSx3("ED3_NCM",6))+"( "+ED3->ED3_PROD+" )"
      cPara  += WorkED3->ED3_NCM+"( "+ED3->ED3_PROD+" )"
   Endif
Else
   If cNome_C $ cCamp_ED0Alt
      If Valtype((cAlias)->&(cNome_C)) == "N"
         Return .F.
      ElseIf Valtype((cAlias)->&(cNome_C)) == "D"
         If ! Empty((cAlias)->&(cNome_C))
            cDe   := DtoS((cAlias)->&(cNome_C))
            cPara := DtoS(M->&(cNome_C))

            cDe   := SubStr(cDe, 7, 2) +"/"+ SubStr(cDe, 5, 2) +"/"+ SubStr(cDe, 1, 4)
            cPara := SubStr(cPara, 7, 2) +"/"+ SubStr(cPara, 5, 2) +"/"+ SubStr(cPara, 1, 4)

            AC400APPEND_ED5(cOpcao, cNome_C)
         Endif
      Endif
   Endif
Endif

If !cNome_C $ cCamp_ED0Alt
   AC400APPEND_ED5(cOpcao, cNome_C)
Endif

If cAlias <> "ED0"
   AC400GRV_Anexo(cAlias, cWork, cNome_C)
EndIf

*------------------------------------------*
Function AC400APPEND_ED5(cOpcao, cNome_C)   // Gravação dos Itens dentro do Arquivo de LOG
*------------------------------------------*
Local cControle := cOpcao
Local cNomeCampo := cNome_C, lBusca

If nVez>12 .Or. nVez==0
   lBusca:= .T.
Else
   lBusca:= .F.
Endif

lVez:= .F.

ED5->(RecLock("ED5",lBusca))

If nVez == 0 .Or. nVez>12
   ED5->ED5_PD     := M->ED0_PD
   ED5->ED5_AC     := M->ED0_AC
   ED5->ED5_DT_REG := dDataBase

   If cAlias == "ED0"
      ED5->ED5_OPCOES := "01"
   Else
      ED5->ED5_OPCOES := "99"
      If cAlias == "ED1"
         ED5->ED5_IM_EX  := "E"
         ED5->ED5_SEQSIS := ED1->ED1_SEQ
         ED5->ED5_ANEXO  := ED1->ED1_ANEXO
         ED5->ED5_TIPO   := "E"
      ElseIf cAlias == "ED3"
         ED5->ED5_IM_EX  := "E"
         ED5->ED5_SEQSIS := ED3->ED3_SEQSIS
         ED5->ED5_ANEXO  := ED3->ED3_ANEXO
         ED5->ED5_TIPO   := "E"
      Else
         ED5->ED5_IM_EX  := "I"
         ED5->ED5_SEQSIS := ED4->ED4_SEQSIS
         ED5->ED5_ANEXO  := ED4->ED4_ANEXO
         ED5->ED5_TIPO   := "I"
      Endif
   Endif
   ED5->ED5_DE := cDe
   ED5->ED5_PARA  := cPara
Else
   if lED5De
      cCampoDe   :="ED5->ED5_DE"+Strzero(nVez,2)
   Endif
   if lED5Para
      cCampoPara :="ED5->ED5_PARA"+Strzero(nVez,2)
   Endif
   &cCampoDe  := cDe
   &cCampoPara:= cPara
Endif

ED5->(MsUnlock())

If(nVez > 12, nVez:= 1, nVez++)

Return .T.

*----------------------------------------------*
Function AC400GRV_Anexo(cAlias, cWork, cNome_C)  //Gravação dos Totais do Anexo
*----------------------------------------------*
Local nSoQtdDe:=nSoPesoDe:=nSoValDe:=nSoQtdPara:=nSoPesoPara:=nSoValPara:=0
Local cPictQtdNcm:= AVSX3("ED4_QTDNCM",6), cPictPeso:= AVSX3("ED4_PESO",6)
Local cPictVal:= AVSX3("ED4_VALEMB",6)

Private cUnMedDe:=""
If cNome_C == "PRECO"
   Return .T.
Endif

nRecAlias:=(cAlias)->(RecNo())
nOrdAlias:=(cAlias)->(IndexOrd())

If cAlias $ "ED3/ED4"
   (cAlias)->(dbSetOrder(5))
ElseIf cAlias == "ED1"
   (cAlias)->(dbSetOrder(6))
Else
   Return .T.
Endif

cAnexoAlias:= (cAlias)->&((cAlias)+"_ANEXO")

(cAlias)->(dbSeek(xFilial(cAlias)+(cAlias)->&((cAlias)+"_PD")+(cAlias)->&((cAlias)+"_ANEXO")))

While !(cAlias)->(Eof()) .And. ED5->ED5_PD == (cAlias)->&((cAlias)+"_PD")
   If (cAlias)->&((cAlias)+"_ANEXO") <> cAnexoAlias
      (cAlias)->(dbSkip())
      Loop
   Endif
   Do Case
      Case cNome_C $ "ED1_QTDNCM/ED3_QTDNCM/ED4_QTDNCM"
         If cUmDe <> (cAlias)->&((cAlias)+"_UMNCM")
            (cAlias)->(dbSkip())
            Loop
         Endif
         nSoQtdDe+=  (cAlias)->&((cAlias)+"_QTDNCM")
      Case cNome_C $ "ED1_PESO/ED3_PESO/ED4_PESO"
         nSoPesoDe+= (cAlias)->&((cAlias)+"_PESO")
      Case cNome_C $ "ED1_VAL_EM/ED3_VAL_EM/ED4_VALEMB"
         nSoValDe+=  If(cAlias$"ED1/ED3", (cAlias)->&((cAlias)+"_VAL_EM"), (cAlias)->&((cAlias)+"_VALEMB"))
   EndCase
   (cAlias)->(dbSkip())
EndDo

(cAlias)->(dbSetOrder(nOrdAlias))
(cAlias)->(dbGoTo(nRecAlias))

nRecWork:=(cWork)->(RecNo())
nOrdWork:=(cWork)->(IndexOrd())

If cWork $ "WorkED3/WorkED4"
   (cWork)->(dbSetOrder(4))
Else
   (cWork)->(dbSetOrder(6))
Endif

cAnexoWork:= (cWork)->&((cAlias)+"_ANEXO")

(cWork)->(dbSeek((cWork)->&((cAlias)+"_PD")+(cWork)->&((cAlias)+"_ANEXO")))

While !(cWork)->(Eof()) .And. ED5->ED5_PD == (cWork)->&((cAlias)+"_PD")
   If (cWork)->&((cAlias)+"_ANEXO") <> cAnexoWork
      (cWork)->(dbSkip())
      Loop
   Endif
   Do Case
      Case cNome_C $ "ED1_QTDNCM/ED3_QTDNCM/ED4_QTDNCM"
         If cUmPara <> (cWork)->&((cAlias)+"_UMNCM")
            (cWork)->(dbSkip())
            Loop
         Endif
         nSoQtdPara+= (cWork)->&((cAlias)+"_QTDNCM")
      Case cNome_C $ "ED1_PESO/ED3_PESO/ED4_PESO"
         nSoPesoPara+=(cWork)->&((cAlias)+"_PESO")
      Case cNome_C $ "ED1_VAL_EM/ED3_VAL_EM/ED4_VALEMB"
         nSoValPara+= If(cAlias$"ED1/ED3", (cWork)->&((cAlias)+"_VAL_EM"), (cWork)->&((cAlias)+"_VALEMB"))
   EndCase
   (cWork)->(dbSkip())
EndDo

(cWork)->(dbSetOrder(nOrdWork))
(cWork)->(dbGoTo(nRecWork))

If nSoQtdDe<>nSoQtdPara .And. ASCAN(aGuardaAne,{|x| x[1]==(cWork)->&((cAlias)+"_ANEXO") .And. x[2]=="Q"}) == 0
   If nVez>12
      ED5->(RecLock("ED5", .T.))
      ED5->ED5_PD     := M->ED0_PD
      ED5->ED5_AC     := M->ED0_AC
      ED5->ED5_DT_REG := dDataBase
      If cAlias == "ED0"
         ED5->ED5_OPCOES := "01"
      Else
         ED5->ED5_OPCOES := "99"
         If cAlias == "ED1"
            ED5->ED5_IM_EX  := "E"
            ED5->ED5_SEQSIS := ED1->ED1_SEQ
            ED5->ED5_ANEXO  := ED1->ED1_ANEXO
            ED5->ED5_TIPO   := "E"
         ElseIf cAlias == "ED3"
            ED5->ED5_IM_EX  := "E"
            ED5->ED5_SEQSIS := ED3->ED3_SEQSIS
            ED5->ED5_ANEXO  := ED3->ED3_ANEXO
            ED5->ED5_TIPO   := "E"
         Else
            ED5->ED5_IM_EX  := "I"
            ED5->ED5_SEQSIS := ED4->ED4_SEQSIS
            ED5->ED5_ANEXO  := ED4->ED4_ANEXO
            ED5->ED5_TIPO   := "I"
         Endif
      Endif
      cCampoDe   :="ED5->ED5_DE"
      cCampoPara :="ED5->ED5_PARA"
   Else
      ED5->(RecLock("ED5", .F.))
      if lED5De
         cCampoDe   :="ED5->ED5_DE"+Strzero(nVez,2)
      Endif
      if lED5Para
         cCampoPara :="ED5->ED5_PARA"+Strzero(nVez,2)
      Endif
   Endif

   //Alcir Alves - 03-05-05
   cUnMedDe:=cUmDe
   If(EasyEntryPoint("EDCAC400"),ExecBlock("EDCAC400",.F.,.F.,"UNIDADE_MEDIDA_IMPRESSAO"),)

   cDe_Anexo := cPa_Anexo := STR0222+(cAlias)->&((cAlias)+"_ANEXO")+STR0207+If(cAlias$"ED1/ED3",'exportados : U.M. ','por importar : U.M. ')+cUnMedDe+" - " //"Item 12 do Anexo ao Pedido de DrawBack n. "###" - "###'exportados : US$ '
   cDe_Anexo += Alltrim(Transf(nSoQtdDe, cPictQtdNcm))
   cPa_Anexo += Alltrim(Transf(nSoQtdPara, cPictQtdNcm))
   &cCampoDe   := cDe_Anexo
   &cCampoPara := cPa_Anexo
   Aadd(aGuardaAne, {(cWork)->&((cAlias)+"_ANEXO"), "Q"})
   If(nVez > 12, nVez:= 1, nVez++)
Endif

If nSoPesoDe<>nSoPesoPara .And. ASCAN(aGuardaAne,{|x| x[1]==(cWork)->&((cAlias)+"_ANEXO") .And. x[2]=="P"}) == 0
   If nVez>12
      ED5->(RecLock("ED5", .T.))
      ED5->ED5_PD     := M->ED0_PD
      ED5->ED5_AC     := M->ED0_AC
      ED5->ED5_DT_REG := dDataBase
      If cAlias == "ED0"
         ED5->ED5_OPCOES := "01"
      Else
         ED5->ED5_OPCOES := "99"
         If cAlias == "ED1"
            ED5->ED5_IM_EX  := "E"
            ED5->ED5_SEQSIS := ED1->ED1_SEQ
            ED5->ED5_ANEXO  := ED1->ED1_ANEXO
            ED5->ED5_TIPO   := "E"
         ElseIf cAlias == "ED3"
            ED5->ED5_IM_EX  := "E"
            ED5->ED5_SEQSIS := ED3->ED3_SEQSIS
            ED5->ED5_ANEXO  := ED3->ED3_ANEXO
            ED5->ED5_TIPO   := "E"
         Else
            ED5->ED5_IM_EX  := "I"
            ED5->ED5_SEQSIS := ED4->ED4_SEQSIS
            ED5->ED5_ANEXO  := ED4->ED4_ANEXO
            ED5->ED5_TIPO   := "I"
         Endif
      Endif
      cCampoDe   :="ED5->ED5_DE"
      cCampoPara :="ED5->ED5_PARA"
   Else
      ED5->(RecLock("ED5", .F.))
      if lED5De
         cCampoDe   :="ED5->ED5_DE"+Strzero(nVez,2)
      Endif
      if lED5Para
         cCampoPara :="ED5->ED5_PARA"+Strzero(nVez,2)
      Endif
   Endif
   cDe_Anexo := cPa_Anexo := STR0223+(cAlias)->&((cAlias)+"_ANEXO")+STR0207+If(cAlias$"ED1/ED3","exportados : K.G. ","por importar : K.G. ") //"Item 11 do Anexo ao Pedido de DrawBack n. "###" - "###'exportados : US$ '
   cDe_Anexo += Alltrim(Transf(nSoPesoDe, cPictPeso))
   cPa_Anexo += Alltrim(Transf(nSoPesoPara, cPictPeso))
   &cCampoDe   := cDe_Anexo
   &cCampoPara := cPa_Anexo
   Aadd(aGuardaAne, {(cWork)->&((cAlias)+"_ANEXO"), "P"})
   If(nVez > 12, nVez:= 1, nVez++)
Endif

If nSoValDe<>nSoValPara .And. ASCAN(aGuardaAne,{|x| x[1]==(cWork)->&((cAlias)+"_ANEXO") .And. x[2]=="V"}) == 0
   If nVez>12
      ED5->(RecLock("ED5", .T.))
      ED5->ED5_PD     := M->ED0_PD
      ED5->ED5_AC     := M->ED0_AC
      ED5->ED5_DT_REG := dDataBase
      If cAlias == "ED0"
         ED5->ED5_OPCOES := "01"
      Else
         ED5->ED5_OPCOES := "99"
         If cAlias == "ED1"
            ED5->ED5_IM_EX  := "E"
            ED5->ED5_SEQSIS := ED1->ED1_SEQ
            ED5->ED5_ANEXO  := ED1->ED1_ANEXO
            ED5->ED5_TIPO   := "E"
         ElseIf cAlias == "ED3"
            ED5->ED5_IM_EX  := "E"
            ED5->ED5_SEQSIS := ED3->ED3_SEQSIS
            ED5->ED5_ANEXO  := ED3->ED3_ANEXO
            ED5->ED5_TIPO   := "E"
         Else
            ED5->ED5_IM_EX  := "I"
            ED5->ED5_SEQSIS := ED4->ED4_SEQSIS
            ED5->ED5_ANEXO  := ED4->ED4_ANEXO
            ED5->ED5_TIPO   := "I"
         Endif
      Endif
      cCampoDe   :="ED5->ED5_DE"
      cCampoPara :="ED5->ED5_PARA"
   Else
      ED5->(RecLock("ED5", .F.))
      if lED5De
         cCampoDe   :="ED5->ED5_DE"+Strzero(nVez,2)
      Endif
      if lED5Para
         cCampoPara :="ED5->ED5_PARA"+Strzero(nVez,2)
      Endif
   Endif
   cDe_Anexo := cPa_Anexo := STR0220+(cAlias)->&((cAlias)+"_ANEXO")+STR0207+If(cAlias$"ED1/ED3",STR0217,STR0221) //"Item 13 do Anexo ao Pedido de DrawBack n. "###" - "###'exportados : US$ '
   cDe_Anexo += Alltrim(Transf(nSoValDe, cPictVal))
   cPa_Anexo += Alltrim(Transf(nSoValPara, cPictVal))
   &cCampoDe   := cDe_Anexo
   &cCampoPara := cPa_Anexo
   Aadd(aGuardaAne, {(cWork)->&((cAlias)+"_ANEXO"), "V"})
   If(nVez > 12, nVez:= 1, nVez++)
Endif

Return .T.

*---------------------------------*
FUNCTION AC400LOG(cAlias, nTipo)   // Gravação da Inclusao e da Exclusao dentro do Arquivo de LOG
*---------------------------------*
Local cMensagem := ""
Local cPara     := ""
Local cTipo     := ""

If cAlias == "ED4" .And. nTipo == INCLUIR
   If !Empty(WorkED4->ED4_NCMANT)
      cMensagem := cPara := STR0308+WorkED4->ED4_ANEXO+STR0226+" NCM: " //"Item 4 do Anexo ao Pedido de DrawBack n. "###" - por importar"
      cMensagem += WorkED4->ED4_NCMANT+"( "+ED4->ED4_ITEM+" )"
      cPara     += WorkED4->ED4_NCM+"( "+ED4->ED4_ITEM+" )"
      cTipo     := "I"
   Else
      cMensagem := STR0224+Alltrim(ED4->ED4_ITEM )+STR0225+Alltrim(ED4->ED4_ANEXO)+STR0226 //"Item ("###") foi Incluido ao Anexo "###" - por importar"
   EndIf
ElseIf  cAlias == "ED4" .And. nTipo == ESTORNAR
   cMensagem := STR0224+Alltrim(ED4->ED4_ITEM )+STR0227+Alltrim(ED4->ED4_ANEXO)+STR0226 //"Item ("###") foi Excluido do Anexo "###" - por importar"
ElseIf  cAlias == "ED1" .And. nTipo == INCLUIR
   cMensagem := STR0228+Alltrim(ED1->ED1_PROD )+STR0225+Alltrim(ED1->ED1_ANEXO)+STR0229 //"Produto ("###") foi Incluido ao Anexo "###" - exportados"
ElseIf  cAlias == "ED1" .And. nTipo == ESTORNAR
   cMensagem := STR0228+Alltrim(ED1->ED1_PROD )+STR0227+Alltrim(ED1->ED1_ANEXO)+STR0229 //"Produto ("###") foi Excluido do Anexo "###" - exportados"
ElseIf cAlias == "ED3" .And. nTipo == INCLUIR
   cMensagem := STR0230+Alltrim(ED3->ED3_NCM )+STR0231+Alltrim(ED3->ED3_PROD )+STR0225+Alltrim(ED3->ED3_ANEXO)+STR0229 //"NCM ("###") / Produto (" ###") foi Incluido ao Anexo "###" - exportados"
ElseIf  cAlias == "ED3" .And. nTipo == ESTORNAR
   cMensagem := STR0230+Alltrim(ED3->ED3_NCM )+STR0231+Alltrim(ED3->ED3_PROD )+STR0227+Alltrim(ED3->ED3_ANEXO)+STR0229 //"NCM ("###") / Produto ("###") foi Excluido do Anexo "###" - exportados"
Endif

ED5->(RecLock("ED5", .T.))
ED5->ED5_PD     := M->ED0_PD
ED5->ED5_AC     := M->ED0_AC
ED5->ED5_DT_REG := dDataBase
ED5->ED5_DE     := cMensagem
ED5->ED5_PARA   := cPara
ED5->ED5_OPCOES := "99"
ED5->ED5_TIPO   := cTipo
If cAlias == "ED4"
   ED5->ED5_IM_EX := "I"
   cMensagem := STRTRAN(cMensagem,STR0226, Space(15)) //" - por importar"
   cMensagem := Right(Alltrim(cMensagem),3)
   ED5->ED5_ANEXO := cMensagem
Else
   ED5->ED5_IM_EX := "E"
   cMensagem := STRTRAN(cMensagem, STR0229, Space(15)) //" - exportados"
   cMensagem := Right(Alltrim(cMensagem),3)
   ED5->ED5_ANEXO := cMensagem
Endif

ED5->(MsUnlock())

Return .T.

*------------------------------*
Static Function GravaED6(cAlias)
*------------------------------*
ED6->(dbSetOrder(1))

Do Case
   Case cAlias == "ED0"
      If !ED6->(dbSeek(cFilED6+M->ED0_PD+"1"))
         ED6->(RecLock("ED6",.T.))
         ED6->ED6_FILIAL := cFilED6
         ED6->ED6_PD     := ED0->ED0_PD
         ED6->ED6_AC     := ED0->ED0_AC
         ED6->ED6_TIPO   := "1"
         ED6->(msUnlock())
      EndIf
   Case cAlias == "ED3"
      ED6->(RecLock("ED6",.T.))
      ED6->ED6_FILIAL := cFilED6
      ED6->ED6_PD     := ED0->ED0_PD
      ED6->ED6_AC     := ED0->ED0_AC
      ED6->ED6_TIPO   := "2"
      ED6->ED6_PROD   := ED3->ED3_PROD
      ED6->ED6_NCM    := ED3->ED3_NCM
      ED6->ED6_SEQSIS := ED3->ED3_SEQSIS
      ED6->(msUnlock())
   Case cAlias == "ED4"
      ED6->(RecLock("ED6",.T.))
      ED6->ED6_FILIAL := cFilED6
      ED6->ED6_PD     := ED0->ED0_PD
      ED6->ED6_AC     := ED0->ED0_AC
      ED6->ED6_TIPO   := "3"
      ED6->ED6_PROD   := ED4->ED4_ITEM
      ED6->ED6_NCM    := ED4->ED4_NCM
      ED6->ED6_SEQSIS := ED4->ED4_SEQSIS
      ED6->(msUnlock())
   Case cAlias == "DT_VAL"
      If !ED6->(dbSeek(cFilED6+M->ED0_PD+"4"))
         ED6->(RecLock("ED6",.T.))
         ED6->ED6_FILIAL := cFilED6
         ED6->ED6_PD     := ED0->ED0_PD
         ED6->ED6_AC     := ED0->ED0_AC
         ED6->ED6_TIPO   := "4"
         ED6->(msUnlock())
      EndIf
EndCase

Return .T.

*-------------------------------------------------------------------------------------*
Static Function AC400Rateio(cRat)
*-------------------------------------------------------------------------------------*
Local nTotalPESO:=0, nRateio, nRatSeg  //, nRatIPD, nOrdSW8:=SW8->(IndexOrd()) -- ACSJ - 01/12/2004 - Variavel não é usada.
Local nDifSeg:=0 //, nInv:=0 -- ACSJ - 01/12/2004 - Variavel não é usada.
Local lDiED8 := .T.
Local lSeekSWN, cQryTab, cQrySum, cQryWhere, nOldArea, cAliasQry
Local hashChvPes := ""   
nFrete   := SW6->W6_VLFRECC + SW6->W6_VLFREPP
cMoeFre  := SW6->W6_FREMOED
nTxFre   := SW6->W6_TX_FRET
nTxUSD   := SW6->W6_TX_US_D
nVlSegUS := SW6->W6_VL_USSE
cMoeSeg  := SW6->W6_SEGMOED
nTxSeg   := SW6->W6_TX_SEG

If cRat == "FRETE" .or. cRat == "AMBOS"
   If lMultiFil
      cFilAux := Left(WorkED2->ED2_FILORI,2)
   Else
      cFilAux := cFilSWN
   EndIf
   /*
   If SWN->(DBSEEK(cFilAux+WorkED2->ED2_HAWB+"1"))
      DO WHILE SWN->(!EOF()) .AND. SWN->WN_FILIAL  == cFilAux .and.;
                                   SWN->WN_HAWB    == WorkED2->ED2_HAWB   .AND.;
                                   SWN->WN_TIPO_NF == "1"
         nTotalPESO += SWN->WN_PESOL
         SWN->(dbSkip())
      EndDo
   ElseIf SW7->(DBSEEK(cFilAux+WorkED2->ED2_HAWB))
      DO WHILE SW7->(!EOF()) .AND. SW7->W7_HAWB    == WorkED2->ED2_HAWB   .AND.;
                                   SW7->W7_FILIAL  == cFilAux
         nTotalPESO += (SW7->W7_QTDE*SW7->W7_PESO)
         SW7->(dbSkip())
      EndDo */

   If ( lSeekSWN := SWN->(DBSEEK(cFilAux+WorkED2->ED2_HAWB+"1")) ) .Or. SW7->(DBSEEK(cFilAux+WorkED2->ED2_HAWB))
      hashChvPes := cFilAux + WorkED2->ED2_HAWB + If(lSeekSWN,"1","")
      If !IsMemVar("oBfPesoPrc") .Or. oBfPesoPrc == Nil
         oBfPesoPrc:= tHashMap():New()
      EndIf
      If !oBfPesoPrc:Get(hashChvPes, @nTotalPESO)
         If lSeekSWN
            cQryTab   := "% "+RetSQLName("SWN")+" SWN %"
            cQrySum   := "% SUM(WN_PESOL) AS PESOLIQ %"
            cQryWhere := "% SWN.D_E_L_E_T_ = ' ' AND SWN.WN_FILIAL = '"+cFilAux+"' AND SWN.WN_HAWB = '"+WorkED2->ED2_HAWB+"' AND SWN.WN_TIPO_NF = '1' %"
         ElseIf SW7->(DBSEEK(cFilAux+WorkED2->ED2_HAWB))
            cQryTab   := "% "+RetSQLName("SW7")+" SW7 %"
            cQrySum   := "% SUM(SW7.W7_QTDE*SW7.W7_PESO) AS PESOLIQ %"
            cQryWhere := "% SW7.D_E_L_E_T_ = ' ' AND SW7.W7_FILIAL = '"+cFilAux+"' AND SW7.W7_HAWB = '"+WorkED2->ED2_HAWB+"' %"
         EndIf

         nOldArea  := Select()
         cAliasQry := GetNextAlias()
         BeginSQL Alias cAliasQry
            SELECT %Exp:cQrySum% 
            FROM   %Exp:cQryTab%
            WHERE  %Exp:cQryWhere%
         EndSql
         TcSetField(cAliasQry,"PESOLIQ","N", AVSX3("WN_PESOL",3), AVSX3("WN_PESOL",4))
         If (cAliasQry)->(!Eof()) .And. (cAliasQry)->(!Bof())
            nTotalPESO := (cAliasQry)->PESOLIQ
         EndIf
         (cAliasQry)->(DBCloseArea())
         If( nOldArea > 0 , DbSelectArea(nOldArea) , ) 

         oBfPesoPrc:Set(hashChvPes, nTotalPESO)
      EndIf
   Else //If lDiExt   NOPADO POR AOM - 04/11/10
      ED8->( dbSetOrder(4) )
      ED8->( dbSeek(cFIlED8+WorkED2->(ED2_DI_NUM+ED2_ADICAO+ED2_POSICA)) )

      nTotalPESO := ED8->ED8_QTD * ED8->ED8_PESO
   EndIf
EndIf

If cRat<>"FRETEIN" .AND. cRat<>"SEGURIN"
   If lMultiFil
      cFilAux := Left(WorkED2->ED2_FILORI,2)
   Else
      cFilAux := cFilSW8
   EndIf
   If !SW8->(dbSeek(cFilAux+WorkED2->ED2_HAWB+WorkED2->ED2_INVOIC+WorkED2->ED2_PO_NUM+WorkED2->ED2_POSICA+WorkED2->ED2_PGI_NU)) //.AND. lDiExt NOPADO POR AOM - 04/11/10
      ED8->( dbSeek(cFilED8+WorkED2->(ED2_DI_NUM+ED2_ADICAO+ED2_POSICA)) )
      lDiED8 := .T.

      nFrete   := ED8->ED8_FRETE
      cMoeFre  := ED8->ED8_MOE_FR
      nTxFre   := ED8->ED8_TX_FR
      nTxUSD   := ED8->ED8_TX_USS
      nVlSegUS := ED8->ED8_SE_USS
      cMoeSeg  := ED8->ED8_MOE_SE
      nTxSeg   := ED8->ED8_TX_SE
   Else
      If lMultiFil
         SW9->(dbSeek(Left(WorkED2->ED2_FILORI,2)+WorkED2->ED2_INVOIC+SW8->W8_FORN))
         SW6->(dbSeek(Left(WorkED2->ED2_FILORI,2)+WorkED2->ED2_HAWB))
      Else
         SW9->(dbSeek(cFilSW9+WorkED2->ED2_INVOIC+SW8->W8_FORN))
         SW6->(dbSeek(cFilSW6+WorkED2->ED2_HAWB))
      EndIf

      nFrete   := SW6->W6_VLFRECC + SW6->W6_VLFREPP
      cMoeFre  := SW6->W6_FREMOED
      nTxFre   := SW6->W6_TX_FRET
      nTxUSD   := SW6->W6_TX_US_D
      nVlSegUS := SW6->W6_VL_USSE
      cMoeSeg  := SW6->W6_SEGMOED
      nTxSeg   := SW6->W6_TX_SEG
   EndIf
EndIf

If cRat == "FRETE" .or. cRat == "AMBOS"
   //Frete
   nRateio := WorkED2->ED2_PESO/nTotalPESO

   WorkED2->ED2_FRETE  := AC400Round(nRateio*(nFrete),"ED2_FRETE")//Round(nRateio*(SW6->W6_VLFRECC + SW6->W6_VLFREPP),AvSx3("ED2_FRETE",4))
   WorkED2->ED2_MOE_FR := cMoeFre
   WorkED2->ED2_TX_FR  := nTxFre
   If cMoeFre <> DOLAR
      WorkED2->ED2_FR_USS := Round(nTxFre * WorkED2->ED2_FRETE / nTxUSD,AvSx3("ED2_FR_USS",4))
   Else
      WorkED2->ED2_FR_USS := WorkED2->ED2_FRETE
   EndIf
EndIf

If cRat == "FRETEIN"
   //AAF 19/09/05 - Rateio do Peso Total da DI, para o Frete PP.

   If lMultiFil
      cFilAuxSW6 := Left(WorkDI->ED2_FILORI,2)
      cFilAuxSW7 := Left(WorkDI->ED2_FILORI,2)
      cFilAuxSW8 := Left(WorkDI->ED2_FILORI,2)
   Else
      cFilAuxSW6 := cFilSW6
      cFilAuxSW7 := cFilSW7
      cFilAuxSW8 := cFilSW8
   EndIf

   hashChvPes:= cFilAuxSW8+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->FORN
   If !IsMemVar("oBfPesoInv") .Or. oBfPesoInv == Nil
      oBfPesoInv:= tHashMap():New()
   EndIf
   If !oBfPesoInv:Get(hashChvPes, @nTotalPESO)

      SW8->(DbSetOrder(1))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_FORN+W8_FORLOJ
      SW8->(dbSeek(cFilAuxSW8+WorkDI->ED2_HAWB+WorkDI->ED2_INVOIC+WorkDI->FORN))

      nOldArea  := Select()
      cAliasQry := GetNextAlias()
      BeginSQL Alias cAliasQry
         SELECT SUM(SW8.W8_QTDE * SW7.W7_PESO) AS PESOLIQ
         FROM       %Table:SW8% SW8
         INNER JOIN %Table:SW7% SW7
         ON  SW7.W7_FILIAL  = SW8.W8_FILIAL
         AND SW7.W7_HAWB    = SW8.W8_HAWB
         AND SW7.W7_PO_NUM  = SW8.W8_PO_NUM
         AND SW7.W7_POSICAO = SW8.W8_POSICAO
         AND SW7.W7_PGI_NUM = SW8.W8_PGI_NUM
         AND SW8.%NotDel%
         AND SW7.%NotDel%
         AND SW8.W8_FILIAL  = %Exp:cFilAuxSW8%
         AND SW8.W8_HAWB    = %Exp:WorkDI->ED2_HAWB%
         AND SW8.W8_INVOICE = %Exp:WorkDI->ED2_INVOIC%
         AND SW8.W8_FORN    = %Exp:WorkDI->FORN%
      EndSql
      TcSetField(cAliasQry,"PESOLIQ","N", AVSX3("W8_PESO_BR",3), AVSX3("W8_PESO_BR",4))
      If (cAliasQry)->(!Eof()) .And. (cAliasQry)->(!Bof())
         nTotalPESO := (cAliasQry)->PESOLIQ
      EndIf 
      (cAliasQry)->(DBCloseArea())
      If( nOldArea > 0 , DbSelectArea(nOldArea) , ) 

      oBfPesoInv:Set(hashChvPes, nTotalPESO)

   EndIf
/*
   Do While !SW8->(EOF()) .and. SW8->W8_FILIAL==cFilAuxSW8 .and. SW8->W8_HAWB==WorkDI->ED2_HAWB .and.;
   SW8->W8_INVOICE==WorkDI->ED2_INVOIC .and. SW8->W8_FORN==WorkDI->FORN
      SW7->(DbSeek(cFilAuxSW7+SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)))
      nTotalPESO += SW8->W8_QTDE * SW7->W7_PESO
      SW8->(dbSkip())
   EndDo
*/
   SW7->(DbSeek(cFilAuxSW7+WorkDI->ED2_HAWB+WorkDI->ED2_PO_NUM+WorkDI->ED2_POSICA+WorkDI->ED2_PGI_NU))
   SW6->(dbSeek(cFilAuxSW6+WorkDI->ED2_HAWB))

   nRateio := (If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)*SW7->W7_PESO) / SW6->W6_PESOL//nTotalPESO

   If WorkDI->ED2_FRETE = 0
      If SW6->W6_VLFRECC=0 .and. SW6->W6_VLFREPP=0
         WorkDI->ED2_FRETE := nRateio*WorkDI->FRETEIN
      Else
         WorkDI->ED2_FRETE  := nRateio*(SW6->W6_VLFRECC + SW6->W6_VLFREPP)
         WorkDI->ED2_MOE_FR := SW6->W6_FREMOED
         WorkDI->ED2_TX_FR  := SW6->W6_TX_FRET
         If SW6->W6_FREMOED <> DOLAR
            WorkDI->ED2_FR_USS := SW6->W6_TX_FRET * WorkDI->ED2_FRETE / SW6->W6_TX_US_D
         Else
            WorkDI->ED2_FR_USS := WorkDI->ED2_FRETE
         EndIf
      EndIf
   EndIf

   // ** AAF - 23/11/05 - Verifica se é Dolar.
   If SW6->W6_FREMOED <> DOLAR
      nValRet:= nRateio*(SW6->W6_VLFREPP*SW6->W6_TX_FRET/SW6->W6_TX_US_D)
   Else
      nValRet:= nRateio*(SW6->W6_VLFREPP)
   Endif
   // **

   Return nValRet//AAF 08/07/05 - Valor do Frete Prepaid é abatido do Valor Local de Embarque para que fique
                                   //               somente o valor FOB, caso o frete seja incluso.
   //Return nRateio*WorkDI->FRETEIN
EndIf

If cRat == "SEGURO" .or. cRat == "AMBOS"
   //Seguro
   //nRatIPD := DITRANS((SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-SW8->W8_DESCONT+SW8->W8_FRETEIN),2)
   If !lDiED8
      //AST - 26/11/08
      If SW9->(dbSeek(cAuxFilSW9+WorkED2->ED2_INVOIC+SW8->W8_FORN))
         nRatSeg := (Round(SW8->W8_PRECO*WorkDI->ED2_QTD*SW9->W9_TX_FOB,2))/SW6->W6_FOB_TOT
      EndIf
   Else
      nRatSeg := WorkDI->ED2_VALEMB / ED8->ED8_VALEMB
   EndIf

/*   If ED2->(dbSeek(cFilED2+WorkED2->ED2_HAWB+WorkED2->ED2_INVOIC+WorkED2->ED2_PO_NUM+WorkED2->ED2_POSICA+WorkED2->ED2_PGI_NU))
      Do While !ED2->(EOF()) .and. ED2->ED2_FILIAL==WorkED2->ED2_FILIAL .and.;
      ED2->ED2_HAWB==WorkED2->ED2_HAWB .and. ED2->ED2_INVOIC==WorkED2->ED2_INVOIC .and.;
      ED2->ED2_PO_NUM==WorkED2->ED2_PO_NUM .and. ED2->ED2_POSICA==WorkED2->ED2_POSICA .and.;
      ED2->ED2_PGI_NU==WorkED2->ED2_PGI_NU
         nDifSeg += (((Round(SW8->W8_PRECO*ED2->ED2_QTD,2))/SW6->W6_VLMLEMN) * SW6->W6_VL_USSE) - ED2->ED2_SEGURO
         ED2->(dbSkip())
      EndDo
   EndIf*/

   WorkED2->ED2_SEGURO := AC400Round((nRatSeg*nVlSegUS) + nDifSeg,"ED2_SEGURO")
   If WorkED2->ED2_SEGURO < 0
      WorkED2->ED2_SEGURO := 0
   EndIf
   WorkED2->ED2_MOE_SE := cMoeSeg
   WorkED2->ED2_TX_SE  := nTxSeg
   If cMoeSeg <> DOLAR
      WorkED2->ED2_SE_USS := nTxSeg * WorkED2->ED2_SEGURO / BuscaTaxa(DOLAR,WorkED2->ED2_DTREG,,.F.,.T.)
   Else
      WorkED2->ED2_SE_USS := WorkED2->ED2_SEGURO
   EndIf
EndIf

// EOB - 13/06/08 - Retorna o valor do seguro da invoice rateado para o item
If cRat == "SEGURIN"
   If lMultiFil
      cAuxFilSW9:=Left(WorkED2->ED2_FILORI,2)
   Else
      cAuxFilSW9:=cFilSW9
   EndIf
   nValRet := 0
   IF SW9->(dbSeek(cAuxFilSW9+WorkED2->ED2_INVOIC+SW8->W8_FORN))
      nValRet:= WorkDI->SEGURIN * (WorkDi->ED2_VL_MOE/SW9->W9_FOB_TOT)
   Endif

   Return nValRet
EndIf

Return .T.

*-------------------------------------------------------------------------------------*
Static Function APURAPESQ(cApura)         // N
*-------------------------------------------------------------------------------------*
Local oDlgN
Local nOpca:=0, lSeek, cF3:= "SB1", cDiAp
Local bOk := {||nOpca:=1,oDlgN:End()}, cProdAp
Local bCancel := {||nOpca:=0,oDlgN:End()}, cOrd:=STR0277, oCbxOrd
Local cItemAp, dDataAp, cRE, aOrd:={STR0277,STR0278,STR0279}//"1 - RE + Produto + Dt Reg DI + Nro da DI" # "2 - Nro da DI + Item + Dt Reg DI" # "Item + Dt Reg DI"
Local oPanel
While .T.

   nOpca  := 0
   cItemAp:= Space(Len(ED1->ED1_PROD))
   dDataAp:= cTod("")
   cDiAp  :=Space(Len(SW6->W6_DI_NUM))
   cProdAp:=Space(Len(ED1->ED1_PROD))
   cRE    :=Space(Len(EE9->EE9_RE))

   DEFINE MSDIALOG oDlgN TITLE STR0171+If(cApura=="DI",STR0172,STR0173); //"Pesquisa para a"###" Importação"###" Exportação"
       FROM 12,05 TO 29,49 OF GetWndDefault()
    oPanel:=	TPanel():New(0,0, "", oDlgN,, .T., ,,,0,0,,.T.)
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   If cApura == "DI"
      @01,02 SAY   AVSX3("EE9_RE",5) of oPanel
      @01,08 MSGET cRE  SIZE 60,8 of oPanel //PICT AVSX3("EE9_RE",6)
      @02,02 SAY   AVSX3("ED1_PROD",5) of oPanel
      If lAbriuExp // F4 para produtos a exportar
         SETKEY(VK_F4,{||EDCAC400HLP(@cProdAp)})
         @02,08 MSGET cProdAp  PICT AVSX3("ED1_PROD",6) Valid (Empty(cProdAp) .or. ExistCpo("SB1EXP",cProdAp)) SIZE 60,8 of oPanel
         @02,15.5 SAY STR0170 of oPanel //"(F4-Pesquisa)"
      Else
         @02,08 MSGET cProdAp PICT AVSX3("ED1_PROD",6) F3 cF3 Valid (Empty(cProdAp) .or. ExistCpo("SB1", cProdAp)) SIZE 60,8 of oPanel HASBUTTON
      Endif
      @03,02 SAY   AVSX3("W6_DTREG_D",5) of oPanel
      @03,08 MSGET dDataAp PICT AVSX3("W6_DTREG_D",6) SIZE 60,8 of oPanel HASBUTTON
      @04,02 SAY   AVSX3("W6_DI_NUM",5) of oPanel
      @04,08 MSGET cDiAp PICT AVSX3("W6_DI_NUM",6) SIZE 60,8 of oPanel
      @05,02 SAY   AVSX3("ED2_ITEM",5) of oPanel
      @05,08 MSGET cItemAp PICT AVSX3("ED2_ITEM",6) F3 cF3 Valid (Empty(cItemAp) .or. ExistCpo("SB1", cItemAp)) SIZE 60,8 of oPanel HASBUTTON
      @06,02 SAY STR0273 of oPanel //"Ordem"
      @06,08 ComboBox oCbxOrd Var cOrd Items aOrd SIZE 107,08 Valid (Left(cOrd,1)=="1" .or. Left(cOrd,1)=="2" .or. Left(cOrd,1)=="3") of oPanel
   Else
      @01,02 SAY   AVSX3("EE9_RE",5) of oPanel
      @01,08 MSGET cRE  SIZE 60,8 of oPanel //PICT AVSX3("EE9_RE",6)
      @02,02 SAY   AVSX3("ED1_PROD",5) of oPanel
      If lAbriuExp // F4 para produtos a exportar
         SETKEY(VK_F4,{||EDCAC400HLP(@cItemAp)})
         @02,08 MSGET cItemAp  PICT AVSX3("ED1_PROD",6) Valid ACVALPESQ(cApura,cItemAp,dDataAp,cRE) SIZE 60,8 of oPanel HASBUTTON
         @02,15.5 SAY STR0170 of oPanel //"(F4-Pesquisa)"
      Else
         @02,08 MSGET cItemAp PICT AVSX3("ED1_PROD",6) F3 cF3 Valid ACVALPESQ(cApura,cItemAp,dDataAp,cRE) SIZE 60,8 of oPanel HASBUTTON
      Endif
      @03,02 SAY   AVSX3("EEC_DTEMBA",5) of oPanel
      @03,08 MSGET dDataAp PICT AVSX3("EEC_DTEMBA",6) SIZE 60,8 of oPanel HASBUTTON
   EndIf

   ACTIVATE MSDIALOG oDlgN ON INIT EnchoiceBar(oDlgN,{||nOpca:=1, Eval(bOk)},{||nOpca:=0,oDlgN:End()}) CENTERED

   If nOpca==1 .And. ACVALPESQ(cApura,cItemAp,dDataAp,cRE,cProdAp,cDiAp,cOrd)
      If cApura == "DI"
         If Left(cOrd,1)=="1"
            WorkDI->(dbSetOrder(2))
            If !Empty(cProdAp)
               If !Empty(dDataAp)
                  If !Empty(cDiAp)
                     lSeek:= WorkDI->(dbSeek(cRe+cProdAp+DtoS(dDataAp)+cDiAp,.T.))  //SoftSeek
                  Else
                     lSeek:= WorkDI->(dbSeek(cRe+cProdAp+DtoS(dDataAp),.T.))  //SoftSeek
                  EndIf
               Else
                  lSeek:= WorkDI->(dbSeek(cRe+cProdAp,.T.))  //SoftSeek
               EndIf
            Else
               lSeek:= WorkDI->(dbSeek(cRe,.T.))  //SoftSeek
            EndIf
         ElseIf Left(cOrd,1)=="2"
            WorkDI->(dbSetOrder(3))
            If !Empty(cItemAp)
               If !Empty(dDataAp)
                  lSeek:= WorkDI->(dbSeek(cDiAp+cItemAp+DtoS(dDataAp),.T.))  //SoftSeek
               Else
                  lSeek:= WorkDI->(dbSeek(cDiAp+cItemAp,.T.))  //SoftSeek
               EndIf
            Else
               lSeek:= WorkDI->(dbSeek(cDiAp,.T.))  //SoftSeek
            EndIf
         Else
            WorkDI->(dbSetOrder(1))
            If !Empty(dDataAp)
               lSeek:= WorkDI->(dbSeek(cItemAp+DtoS(dDataAp),.T.))  //SoftSeek
            Else
               lSeek:= WorkDI->(dbSeek(cItemAp,.T.))  //SoftSeek
            EndIf
         EndIf
         If !lSeek
            Help(" ",1,"AVG0005273") //"A Pesquisa não encontrou registros com essas Infornmações."
            oMark:oBrowse:Refresh()
         Else
            oMark:oBrowse:Refresh()
         EndIf
      Else
         If Empty(cRE)
            WorkRE->(dbSetOrder(1))
            If !Empty(dDataAp)
               lSeek:= WorkRE->(dbSeek(cItemAp+dtos(dDataAp),.T.))  //SoftSeek
            Else
               lSeek:= WorkRE->(dbSeek(cItemAp,.T.))  //SoftSeek
            Endif
         Else
            WorkRE->(dbSetOrder(2))
            If !Empty(cItemAp)
               If !Empty(dDataAp)
                  lSeek:= WorkRE->(dbSeek(cRE+cItemAp+dtos(dDataAp),.T.))  //SoftSeek
               Else
                  lSeek:= WorkRE->(dbSeek(cRE+cItemAp,.T.))  //SoftSeek
               Endif
            Else
               lSeek:= WorkRE->(dbSeek(cRE,.T.))  //SoftSeek
            EndIf
         EndIf
         If !lSeek
            Help(" ",1,"AVG0005273") //"A Pesquisa não encontrou registros com essas Infornmações."
            oMark:oBrowse:Refresh()
         Else
            oMark:oBrowse:Refresh()
         EndIf
      Endif
   ElseIf nOpca==1
      Loop
   Else
      Exit
   EndIf

   Exit
EndDo

Return .T.

*-------------------------------------------------------------------------------------*
Static Function ACVALPESQ(cApura,cItemAp,dDataAp,cRE,cProdAp,cDiAp,cOrd)
*-------------------------------------------------------------------------------------*
Local lRet := .T.

If cApura=="RE"
   If !Empty(cItemAp)
      If(!ExistCpo(cAliasSB1, cItemAp), lRet:= .F., )
   ElseIf Empty(cRE)
      Help(" ",1,"AVG0005274") //"O produto não foi Preenchido."
      lRet:= .F.
   Endif
ElseIf cApura=="DI"
   If Left(cOrd,1)=="1"
      If Empty(cRE)
         Help(" ",1,"AVG0005281") //"Chave de pesquisa incorreta."
         lRet:= .F.
      EndIf
   ElseIf Left(cOrd,1)=="2"
      If Empty(cDiAp)
         Help(" ",1,"AVG0005281") //"Chave de pesquisa incorreta."
         lRet:= .F.
      EndIf
   Else
      If Empty(cItemAp)
         Help(" ",1,"AVG0005281") //"Chave de pesquisa incorreta."
         lRet:= .F.
      EndIf
   EndIf
EndIf

Return lRet

*-------------------------------------------------------------------------------------*
Static Function AC400TELAQTD(cAlias,Qtd,Saldo,QtdExp)         // O
*-------------------------------------------------------------------------------------*
Local oDlgO

DEFINE MSDIALOG oDlgO TITLE STR0176; //"Demonstrativo de Saldo/Qtd."
       FROM 15,03 To 25,44 OF oMainWnd

   @1,1.5  SAY STR0178 //"Saldo Estrutura de Produto"
   @1,13 SAY Qtd Picture AVSX3("ED1_QTD",6) SIZE 60,7
   @2,1.5  SAY STR0177 //"Saldo Atual (já marcado)"
   @2,13 SAY Saldo Picture AVSX3("ED1_QTD",6) SIZE 60,7
   @3,1.5  SAY STR0179 //"Quantidade Selecionada"
   @3,13 SAY QtdExp Picture AVSX3("ED1_QTD",6) SIZE 60,7

   DEFINE SBUTTON FROM 60,70 TYPE 1 ACTION(oDlgO:End()) ENABLE OF oDlgO

ACTIVATE MSDIALOG oDlgO CENTERED

Return .T.

*-------------------------------------------------------------------------------------*
Static Function AC400GrvEDA(nTipo,cItem,nQtd,nQtdEstru,cMarcado,nQtdAlt)   //Anterioridade
*-------------------------------------------------------------------------------------*

//AAF 22/04/05
If nQtdEstru <> NIL
   nQtdEstru := Round(nQtdEstru,AVSX3("EDA_QTDEST",4))
Endif

If nQtd <> NIL
   nQtd := Round(nQtd,AVSX3("EDA_QTD",4))
Endif

If nTipo = INCLUIR

   If WorkEDA->(dbSeek(cItem))
      If cMarcado == cMarca
         WorkEDA->EDA_QTD += nQtd
      EndIf
      WorkEDA->EDA_QTDEST += nQtdEstru

      /* AAF 09/05/05 - Comentado pois esta rotina causava erros de Arredondamento
      If WorkEDA->EDA_QTD > WorkEDA->EDA_QTDEST .and. (WorkEDA->EDA_QTDEST - WorkEDA->EDA_QTD) > -0.001
         WorkEDA->EDA_QTDEST   += (WorkEDA->EDA_QTDEST - WorkEDA->EDA_QTD) * -1
      ElseIf WorkEDA->EDA_QTD < WorkEDA->EDA_QTDEST .and. (WorkEDA->EDA_QTDEST - WorkEDA->EDA_QTD) < 0.001
         WorkEDA->EDA_QTDEST   -= (WorkEDA->EDA_QTDEST - WorkEDA->EDA_QTD)
      EndIf
      */
   Else
      WorkEDA->(RecLock("WorkEDA",.T.))
      WorkEDA->EDA_ITEM   := cItem
      WorkEDA->EDA_DESCIT := Posicione("SB1",1,xFilial("SB1"/*"EDA"*/)+WorkEDA->EDA_ITEM ,"B1_DESC")  // GFP - 30/08/2012
      If cMarcado == cMarca
         WorkEDA->EDA_QTD    := nQtd
      EndIf
      WorkEDA->EDA_QTDEST := nQtdEstru
      WorkEDA->TRB_ALI_WT := "EDA"
      WorkEDA->TRB_REC_WT := EDA->(Recno())
   EndIf

ElseIf nTipo = ALTERAR
   If WorkEDA->(dbSeek(cItem))
      WorkEDA->EDA_QTD    += nQtd
      If nQtdEstru <> NIL
         WorkEDA->EDA_QTDEST += nQtdEstru
      EndIf
   EndIf
ElseIf nTipo = ESTORNAR
   If WorkEDA->(dbSeek(cItem))
      WorkEDA->EDA_QTD -= nQtd
      WorkEDA->EDA_QTDEST -= nQtdEstru
      If WorkEDA->EDA_QTDEST <= 0 .and. WorkEDA->EDA_QTD <= 0
         aAdd(aDelWkEDA,WorkEDA->EDA_RECNO)
         WorkEDA->(RecLock("WorkEDA",.F.,.T.))
         WorkEDA->(DBDELETE())
      EndIf
   EndIf
ElseIf nTipo = 10
   WorkEstru->(dbGoTop())
   Do While !WorkEstru->(EOF())
      If WorkEDA->(dbSeek(IG400BuscaItem("I",WorkEstru->COMP,M->ED0_PD)))
         WorkEDA->EDA_QTDEST += Round(WorkEstru->QUANT,AvSx3("EDA_QTDEST",4))
      EndIf
      AC400EDCGrv(10)
      WorkEstru->(dbSkip())
   EndDo
ElseIf nTipo = 11
   WorkEstru->(dbGoTop())
   Do While !WorkEstru->(EOF())
      If WorkEDA->(dbSeek(IG400BuscaItem("I",WorkEstru->COMP,M->ED0_PD)))
         WorkEDA->EDA_QTDEST -= Round(WorkEstru->QUANT,AvSx3("EDA_QTDEST",4))
      EndIf
         AC400EDCGrv(11,,,,,,,nQtdAlt)
      WorkEstru->(dbSkip())
   EndDo
ElseIf nTipo = 12
   WorkEstru->(dbGoTop())
   Do While !WorkEstru->(EOF())
      If WorkEDA->(dbSeek(IG400BuscaItem("I",WorkEstru->COMP,M->ED0_PD)))
         WorkEDA->EDA_QTDEST -= Round(WorkEstru->QUANT,AvSX3("EDA_QTDEST",4)) //AAF 25/04/05
         If WorkEDA->EDA_QTDEST <= 0 .and. WorkEDA->EDA_QTD <= 0
            aAdd(aDelWkEDA,WorkEDA->EDA_RECNO)
            WorkEDA->(RecLock("WorkEDA",.F.,.T.))
            WorkEDA->(DBDELETE())
         EndIf
      EndIf
      AC400EDCGrv(12)
         AC400EDCGrv(12,,,,,,,nQtdAlt)
      WorkEstru->(dbSkip())
   EndDo
EndIf

Return .T.

*-------------------------------------*
Static Function AC400FILIALCNPJ(nOpc)
*-------------------------------------*
Local nOpcao:=0, bOk := {||nOpcao:=1,oDlgFl:End()}, cF3:= "SYT"
Local oDlgFl         // ACSJ - 17 de Fev de 2004
Private cImport, cCnpj, nModo:= nOpc, cPictCnpj:= AVSX3("YT_CGC", 06)
Private cDesc:= Space(Len(SYT->YT_NOME)), cDelega:=Space(Len(EDB->EDB_DELEGA))

EDB->(dbSetOrder(1))
SYT->(dbSetOrder(3))

Do While .T.

   aGets:={}
   aTela:={}

   cImport:=Space(Len(SYT->YT_COD_IMP))
   cCnpj  :=Space(Len(EDB->EDB_CNPJ))
   cDelega:=Space(Len(EDB->EDB_DELEGA))

   If nModo <> 3 //Excluir
      cImport:= WorkEDB->EDB_IMPORT
      cCnpj  := WorkEDB->EDB_CNPJ
      cDelega:= WorkEDB->EDB_DELEGA
   Endif

   DEFINE MSDIALOG oDlgFl TITLE STR0258; //"Importador/C.N.P.J."
       FROM 05,05 TO 23,50 OF GetWndDefault() //FDR - 02/01/2012
//     FROM 12,05 TO 21,55 OF GetWndDefault()

   oPanel:= TPanel():New(0,0, "", oDlgFl,, .T., ,,,0,0,,.T.) //LGS-02/12/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @02,02 SAY   STR0259   of oPanel //"Importador"
   @02,08 MSGET cImport    PICT AVSX3("YT_COD_IMP",6) F3 cF3 Valid If(!Empty(cImport), ValImpCNPJ(), ) SIZE 60,8 OF oPanel

   @03,02 SAY   STR0255   of oPanel //"C.N.P.J."
   @03,08 MSGET cCnpj    PICT cPictCnpj SIZE 60,8 OF oPanel

   @04,02 SAY   STR0300   of oPanel //"Delegacia RF"
   @04,08 MSGET cDelega    PICT "@!" SIZE 60,8 OF oPanel

   ACTIVATE MSDIALOG oDlgFl ON INIT EnchoiceBar(oDlgFl,{||If(ValImpCNPJ("OK"),Eval(bOk),)},{||nOpcao:=0,oDlgFl:End()}) CENTERED

   If nOpcao=1
      If nModo == 3
         If EDB->(dbSeek(cFilEDB+ED0->ED0_PD+cImport))
            Help(" ",1,"AVG0005297",,Transf(Alltrim(cCnpj),cPictCnpj)+STR0261,1,10) //Msginfo(STR0260+Transf(Alltrim(cCnpj),cPictCnpj)+STR0261, STR0262) //"Entre com outro C.N.P.J. para este Pedido, pois o C.N.P.J."###" já está cadastrado"###"Atenção"
            Return .F.
         Endif
         WorkEDB->(RecLock("WorkEDB",.T.))
         WorkEDB->EDB_PD    := ED0->ED0_PD
         WorkEDB->EDB_CNPJ  := cCnpj
         WorkEDB->EDB_DESC  := cDesc
         WorkEDB->EDB_IMPORT:= cImport
         WorkEDB->EDB_DELEGA:= cDelega
         WorkEDB->EDB_RECNO := EDB->(RECNO())
         WorkEDB->TRB_ALI_WT:= "EDB"
         WorkEDB->TRB_REC_WT:= EDB->(Recno())
         WorkEDB->(msUnlock())
         oMark6:oBrowse:Refresh()
      Else
         aAdd(aDelWkEDB,WorkEDB->EDB_RECNO)
         WorkEDB->(RecLock("WorkEDB",.F.,.T.))
         WorkEDB->(DBDELETE())
         WorkEDB->(msUnlock())
       Exit
      Endif
   Else
      oMark6:oBrowse:Refresh()
    Exit
   EndIf
   nOpcao:=0
Enddo

aGets := {}
aTela := {}
nOpcao:= 0

oMark6:oBrowse:Refresh()

Return .t.

*---------------------------------*
Static Function ValImpCNPJ(cParam)
*---------------------------------*
Local lRet:= .T.

SYT->(dbSetOrder(1))
EDB->(dbSetOrder(1))

If cParam == "OK"
   If Empty(cImport)
      Help(" ",1,"AVG0005298") //Msginfo(STR0263, STR0264) //"Importador deve ser preenchido!"###"Mensagem"
      lRet:= .F.
   Endif

   If Empty(cCnpj)
      Help(" ",1,"AVG0005299",,Alltrim(cImport)+STR0266,1,23) //Msginfo(STR0265+Alltrim(cImport)+STR0266, STR0264) //"C.N.P.J. do Importador "###" não está cadastrado."###"Mensagem"
      lRet:= .F.
   Endif
Else
   SYT->(dbSeek(cFilSYT+cImport))
   cCnpj:= SYT->YT_CGC
   cDesc:= SYT->YT_NOME

   If !Empty(cImport) .And. WorkEDB->(dbSeek(cImport))
      If nModo == 3 //Somente para Inclusão
         Help(" ",1,"AVG0005300",,Alltrim(ED0->ED0_PD)+STR0268,2,01) //Msginfo(STR0267+Alltrim(ED0->ED0_PD)+STR0268, STR0264) //"C.N.P.J. já cadastrado para o Pedido "###"."###"Mensagem"
         lRet:= .F.
      Endif
   Endif

   If nModo == 3 .And. cImport == ED0->ED0_IMPORT
      Help(" ",1,"AVG0005301",,Transf(Alltrim(cCnpj), cPictCnpj)+STR0269,1,09) //Msginfo(STR0255+Transf(Alltrim(cCnpj), cPictCnpj)+STR0269, STR0264) //"C.N.P.J. "###" já existente na Capa do Pedido."###"Mensagem"
      lRet:= .F.
   Endif

   If Empty(cCnpj)
      Help(" ",1,"AVG0005299",,Alltrim(cImport)+STR0266,1,23) //Msginfo(STR0270+Alltrim(cImport)+STR0266, STR0264) //"C.N.P.J. do Importador "###" não está cadastrado."###"Mensagem"
      lRet:= .F.
   Endif
Endif

Return lRet

*----------------------------*
Static Function AC400PesqDI()         // P
*----------------------------*
Local oDlgP
Local cDIPesq:=Space(Len(ED2->ED2_DI_NUM)), cItemPe:=Space(Len(ED2->ED2_ITEM))
Local cRePe:=Space(Len(ED2->ED2_RE)), cProdPe:=Space(Len(ED2->ED2_PROD))
Local nOp:=0, lRet:= .T., dDtDi:=AvCtoD("  /  /  "), cF3:= "SB1", lSeek, bOk:={||nOp:=1,oDlgP:End()}
Local cOrd:=STR0284, oCbxOrd, aOrd:={STR0284,STR0285,STR0279}// "1 - RE + Produto + Item + Nro da DI" # # "3 - Item + Dt Reg DI"

dbSelectArea("WorkED2")

Do While .T.

   aGets:={}
   aTela:={}
   cDIPesq:=Space(Len(ED2->ED2_DI_NUM))
   cItemPe:=Space(Len(ED2->ED2_ITEM))
   cRePe  :=Space(Len(ED2->ED2_RE))
   cProdPe:=Space(Len(ED2->ED2_PROD))
   dDtDi  :=AvCtoD("  /  /  ")

   DEFINE MSDIALOG oDlgP TITLE STR0002;  //"Pesquisar"
      FROM 05,05 TO 24,55 OF GetWndDefault()

      oPanel:= TPanel():New(0,0, "", oDlgP,, .T., ,,,0,0,,.T.) //LGS-11/12/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @01,02 SAY   AVSX3("EE9_RE",5) of oPanel
      @01,08 MSGET cREPe  SIZE 60,8 of oPanel //PICT AVSX3("EE9_RE",6)
      @02,02 SAY   AVSX3("ED1_PROD",5) of oPanel
      If lAbriuExp // F4 para produtos a exportar
         SETKEY(VK_F4,{||EDCAC400HLP(@cProdPe)})
         @02,08 MSGET cProdPe  PICT AVSX3("ED1_PROD",6) Valid (Empty(cProdPe) .or. ExistCpo("SB1EXP",cProdPe)) SIZE 60,8 of oPanel
         @02,15.5 SAY STR0170 of oPanel //"(F4-Pesquisa)"
      Else
         @02,08 MSGET cProdPe PICT AVSX3("ED1_PROD",6) F3 cF3 Valid (Empty(cProdPe) .or. ExistCpo("SB1", cProdPe)) SIZE 60,8 of oPanel
      Endif
      @03,02 SAY   AVSX3("W6_DTREG_D",5) of oPanel
      @03,08 MSGET dDtDi PICT AVSX3("W6_DTREG_D",6) SIZE 60,8 of oPanel
      @04,02 SAY   AVSX3("W6_DI_NUM",5) of oPanel
      @04,08 MSGET cDiPesq PICT AVSX3("W6_DI_NUM",6) SIZE 60,8 of oPanel
      @05,02 SAY   AVSX3("ED2_ITEM",5) of oPanel
      @05,08 MSGET cItemPe PICT AVSX3("ED2_ITEM",6) F3 cF3 Valid (Empty(cItemPe) .or. ExistCpo("SB1", cItemPe)) SIZE 60,8 of oPanel
      @06,02 SAY STR0273 of oPanel //"Ordem"
      @06,08 ComboBox oCbxOrd Var cOrd Items aOrd SIZE 100,08 Valid (Left(cOrd,1)=="1" .or. Left(cOrd,1)=="2" .or. Left(cOrd,1)=="3") of oPanel

   ACTIVATE MSDIALOG oDlgP ON INIT EnchoiceBar(oDlgP,{||If(AcValPeDi(cItemPe,dDtDi,cREPe,cProdPe,cDiPesq,cOrd),Eval(bOk),)},{||nOp:=0,oDlgP:End()}) CENTERED

   If nOp==1
      If Left(cOrd,1)=="1"
         WorkED2->(dbSetOrder(6))
         If !Empty(cProdPe)
            If !Empty(cItemPe)
               If !Empty(cDiPesq)
                  lSeek:= WorkED2->(dbSeek(cRePe+cProdPe+cItemPe+cDiPesq,.T.))  //SoftSeek
               Else
                  lSeek:= WorkED2->(dbSeek(cRePe+cProdPe+cItemPe,.T.))  //SoftSeek
               EndIf
            Else
               lSeek:= WorkED2->(dbSeek(cRePe+cProdPe,.T.))  //SoftSeek
            EndIf
         Else
            lSeek:= WorkED2->(dbSeek(cRePe,.T.))  //SoftSeek
         EndIf
      ElseIf Left(cOrd,1)=="2"
         WorkED2->(dbSetOrder(5))
         If !Empty(cItemPe)
            lSeek:= WorkED2->(dbSeek(cDiPesq+cItemPe,.T.))  //SoftSeek
         Else
            lSeek:= WorkED2->(dbSeek(cDiPesq,.T.))  //SoftSeek
         EndIf
      Else
         WorkED2->(dbSetOrder(7))
         If !Empty(dDtDi)
            lSeek:= WorkED2->(dbSeek(cItemPe+DtoS(dDtDi),.T.))  //SoftSeek
         Else
            lSeek:= WorkED2->(dbSeek(cItemPe,.T.))  //SoftSeek
         EndIf
      EndIf
      If !lSeek
         Help(" ",1,"AVG0005273") //"A Pesquisa não encontrou registros com essas Infornmações."
         oMark:oBrowse:Refresh()
      Else
         oMark:oBrowse:Refresh()
      EndIf
   ElseIf nOp==1
      Loop
   Else
      Exit
   EndIf

   Exit
EndDo

Return lRet

*-------------------------------------------------------------------------------------*
Static Function AC400EDCGrv(nTipo,cItem,cRE,cProd,nQtd,nQtdEstru,cMarcado,nQtdRE)
*-------------------------------------------------------------------------------------*
Local aOrd:= SaveOrd({"WorkED1"})

If nQtdEstru <> NIL
   nQtdEstru := Round(nQtdEstru,AvSX3("EDC_QTDEST",4))
Endif
If nQtd <> NIL
   nQtd := Round(nQtd,AvSX3("EDC_QTD",4))
Endif

//ER - 25/09/2007
If nQtdRE <> NIL
   If EDC->(FieldPos("EDC_QTDPRO")) > 0
      nQtdRE := Round(nQtdRE,AvSX3("EDC_QTDPRO",4))
   EndIf
EndIf
WorkEDC->(dbSetOrder(3))
If nTipo = INCLUIR

   If WorkEDC->(dbSeek(cItem+cRE+cProd))
      If cMarcado == cMarca
         WorkEDC->EDC_QTD += nQtd
      EndIf
      WorkEDC->EDC_QTDEST += nQtdEstru
      If nQtdRE <> NIL
         If EDC->(FieldPos("EDC_QTDPRO")) > 0
            //WorkEDC->EDC_QTDPRO := nQtdRE //comentado por WFS em 18/08/11
            WorkEDC->EDC_QTDPRO += nQtdRE
         EndIf
      EndIf
   Else
      WorkEDC->(RecLock("WorkEDC",.T.))
      WorkEDC->EDC_ITEM   := cItem
      WorkEDC->EDC_DESCIT := Posicione("SB1",1,xFilial("SB1"/*"EDC"*/)+WorkEDC->EDC_ITEM ,"B1_DESC") // AOM - 26/05/2010      // GFP - 30/08/2012
      WorkEDC->EDC_RE     := cRE
      WorkEDC->EDC_PROD   := cProd
      WorkEDC->EDC_DESCPD := Posicione("SB1",1,xFilial("SB1"/*"EDC"*/)+WorkEDC->EDC_PROD ,"B1_DESC") // AOM - 26/05/2010      // GFP - 30/08/2012
      If cMarcado == cMarca
         WorkEDC->EDC_QTD := nQtd
      EndIf
      WorkEDC->EDC_QTDEST := nQtdEstru
      WorkEDC->TRB_ALI_WT := "EDC"
      WorkEDC->TRB_REC_WT := EDC->(Recno())
      //ER - 25/09/2007
      If EDC->(FieldPos("EDC_QTDBAS")) > 0
         SB1->(DbSetOrder(1))
         If SB1->(DbSeek(cFilSB1Aux+cProd))
            WorkEDC->EDC_QTDBAS := SB1->B1_QB
         EndIf
      EndIf

      If EDC->(FieldPos("EDC_PERDA")) > 0
         SG1->(DbSetOrder(1))
         If SG1->(DbSeek(cFilSG1+cProd))
            WorkEDC->EDC_PERDA := SG1->G1_PERDA
         EndIf
      EndIf

      If nQtdRE <> NIL
         If EDC->(FieldPos("EDC_QTDPRO")) > 0
            WorkEDC->EDC_QTDPRO := nQtdRE
         EndIf
      EndIf

      If lLeadTime
         WorkEDC->EDC_LEADTI := SB1->B1_LEADTI
         WorkEDC->EDC_PRODUC := SB1->B1_PRODUC
      EndIf
   EndIf

ElseIf nTipo = ALTERAR
   If WorkEDC->(dbSeek(cItem+cRE+cProd))
      WorkEDC->EDC_QTD    += nQtd
      If nQtdEstru <> NIL
         WorkEDC->EDC_QTDEST += nQtdEstru
      EndIf

      If nQtdRE <> NIL
         If EDC->(FieldPos("EDC_QTDPRO")) > 0
            WorkEDC->EDC_QTDPRO += nQtdRE
         EndIf
      EndIf
   EndIf
ElseIf nTipo = ESTORNAR
   If WorkEDC->(dbSeek(cItem+cRE+cProd))
      WorkEDC->EDC_QTD    -= nQtd
      WorkEDC->EDC_QTDEST -= nQtdEstru

      If nQtdRE <> NIL
         If EDC->(FieldPos("EDC_QTDPRO")) > 0
            WorkEDC->EDC_QTDPRO -= nQtdRE
         EndIf
      EndIf

      /* Se o produto a exportar não está no compromisso de exportação, não deve ser mantido no resumo técnico */
      WorkED1->(DBSetOrder(6))
      If WorkEDC->EDC_QTDEST <= 0 .and. WorkEDC->EDC_QTD <= 0 .Or. (!WorkED1->(DBSeek(WorkEDC->EDC_PROD + WorkEDC->EDC_RE)) .Or. AScan(aDelWkED1, WorkED1->ED1_RECNO) > 0)
         aAdd(aDelWkEDC,WorkEDC->EDC_RECNO)
         WorkEDC->(RecLock("WorkEDC",.F.,.T.))
         WorkEDC->(DBDELETE())
      EndIf
   EndIf
ElseIf nTipo = 10
   If WorkEDC->(dbSeek(IG400BuscaItem("I",WorkEstru->COMP,M->ED0_PD)+WorkED1->ED1_RE+WorkED1->ED1_PROD))
      WorkEDC->EDC_QTDEST += Round(WorkEstru->QUANT,AvSx3("EDC_QTDEST",4))
   EndIf
ElseIf nTipo = 11
   If WorkEDC->(dbSeek(IG400BuscaItem("I",WorkEstru->COMP,M->ED0_PD)+WorkED1->ED1_RE+WorkED1->ED1_PROD))
      WorkEDC->EDC_QTDEST -= Round(WorkEstru->QUANT,AvSx3("EDC_QTDEST",4))
      If nQtdRE <> NIL
         If EDC->(FieldPos("EDC_QTDPRO")) > 0
            WorkEDC->EDC_QTDPRO += nQtdRE
         EndIf
      EndIf
   EndIf
ElseIf nTipo = 12
   If WorkEDC->(dbSeek(IG400BuscaItem("I",WorkEstru->COMP,M->ED0_PD)+WorkED1->ED1_RE+WorkED1->ED1_PROD))
      WorkEDC->EDC_QTDEST -= Round(WorkEstru->QUANT,AvSX3("EDC_QTDEST",4)) // AAF 25/04/05

      If nQtdRE <> NIL
         If EDC->(FieldPos("EDC_QTDPRO")) > 0
            WorkEDC->EDC_QTDPRO -= nQtdRE
         EndIf
      EndIf

      If WorkEDC->EDC_QTDEST <= 0 .and. WorkEDC->EDC_QTD <= 0
         aAdd(aDelWkEDC,WorkEDC->EDC_RECNO)
         WorkEDC->(RecLock("WorkEDC",.F.,.T.))
         WorkEDC->(DBDELETE())
      EndIf
   EndIf
EndIf

//ER - 25/09/2007
If !WorkEDC->(Deleted())
   SX3->(DbSetOrder(2))
   If SX3->(DbSeek("EDC_FATGRO"))
      WorkEDC->EDC_FATGRO := WorkEDC->((EDC_QTDBAS * EDC_QTDEST) / EDC_QTDPRO)
   EndIf

   If SX3->(DbSeek("EDC_FATNET"))
      WorkEDC->EDC_FATNET := WorkEDC->(EDC_FATGRO*(1 - EDC_PERDA/100))
   EndIf
EndIf

RestOrd(aOrd, .T.)
Return .T.

*---------------------------------------------------------------------------------------------*
Static Function ACPesqRes(cApura)
*---------------------------------------------------------------------------------------------*
Local oDlgQ
Local nOpca:=0, lSeek, cF3:= "SB1", cOrd:=STR0274, oCbxOrd
Local bOk := {||nOpca:=1,oDlgQ:End()}, aOrd:={STR0274,STR0275}//"1 - RE + Produto" # "2 - Produto + RE"
Local bCancel := {||nOpca:=0,oDlgQ:End()}
Local cItemAp:=Space(Len(ED2->ED2_ITEM)), cREAp:=Space(Len(ED2->ED2_RE)), cProdAP:=Space(Len(ED1->ED1_PROD))

While .T.

   nOpca:= 0
   cItemAp:=Space(Len(ED2->ED2_ITEM))
   cREAp  :=Space(Len(ED2->ED2_RE))
   cProdAP:=Space(Len(ED1->ED1_PROD))

   DEFINE MSDIALOG oDlgQ TITLE STR0272; //"Pesquisa Resumo"
       FROM 05,05 TO 20,55 OF GetWndDefault()

   oPanel:= TPanel():New(0,0, "", oDlgQ,, .T., ,,,0,0,,.T.) //LGS-02/12/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   If cApura == "WorkEDA"
      @03,02 SAY   AVSX3("ED2_ITEM",5) of oPanel
      @03,08 MSGET cItemAp PICT AVSX3("ED2_ITEM",6) F3 cF3 Valid ValPesqRes(1,cItemAp) SIZE 60,8 of oPanel
   Else
      @01.5,02 SAY   AVSX3("ED2_ITEM",5) of oPanel
      @01.5,08 MSGET cItemAp PICT AVSX3("ED2_ITEM",6) F3 cF3 Valid ValPesqRes(2,cItemAp,cREAp,cProdAp) SIZE 60,8 of oPanel
      @02.5,02 SAY   AVSX3("EE9_RE",5) of oPanel
      @02.5,08 MSGET cREAp  SIZE 60,8 of oPanel //PICT AVSX3("EE9_RE",6)
      @03.5,02 SAY   AVSX3("ED1_PROD",5) of oPanel
      If lAbriuExp // F4 para produtos a exportar
         SETKEY(VK_F4,{||EDCAC400HLP(@cProdAp)})
         @03.5,08 MSGET cProdAp PICT AVSX3("ED1_PROD",6) Valid (ValPesqRes(3,cItemAp,cREAp,cProdAp)) SIZE 60,8 of oPanel
         @03.5,15.5 SAY STR0170 of oPanel //"(F4-Pesquisa)"
      Else
         @03.5,08 MSGET cProdAp PICT AVSX3("ED1_PROD",6) F3 cF3 Valid (ValPesqRes(3,cItemAp,cREAp,cProdAp)) SIZE 60,8 of oPanel
      Endif
      @04.5,02 SAY STR0273 of oPanel //"Ordem"
      @04.5,08 ComboBox oCbxOrd Var cOrd Items aOrd SIZE 80,08 Valid (Left(cOrd,1)=="1" .or. Left(cOrd,1)=="2") When (Empty(cItemAp) .and. !Empty(cReap) .and. !Empty(cProdAp)) of oPanel
   EndIf

   ACTIVATE MSDIALOG oDlgQ ON INIT EnchoiceBar(oDlgQ,{||nOpca:=1, Eval(bOk)},{||nOpca:=0,oDlgQ:End()}) CENTERED

   If nOpca==1 .And. ValPesqRes(4,cItemAp,cREap,cProdAp)
      If cApura == "WorkEDA"
         If !WorkEDA->(dbSeek(cItemAp))
            Help(" ",1,"AVG0005273") //"A Pesquisa não encontrou registros com essas Infornmações."
            //oMark5:oBrowse:Refresh() - AOM - 27/10/10
         Else
            //oMark5:oBrowse:Refresh() - AOM - 27/10/10
         EndIf
      Else
         If !Empty(cItemAp)
            WorkEDC->(dbSetOrder(3))
            If !Empty(cREAp)
               If !Empty(cProdAp)
                  lSeek:= WorkEDC->(dbSeek(cItemAp+cREap+cProdAp,.T.))  //SoftSeek
               Else
                  lSeek:= WorkEDC->(dbSeek(cItemAp+cREap,.T.))  //SoftSeek
               EndIf
            Else
               lSeek:= WorkEDC->(dbSeek(cItemAp,.T.))  //SoftSeek
            EndIf
         ElseIf !Empty(cREap) .and. !Empty(cProdAp)
            If Left(cOrd,1)=="2"
               WorkEDC->(dbSetOrder(2))
               lSeek:= WorkEDC->(dbSeek(cProdAp+cREap,.T.))  //SoftSeek
            Else
               WorkEDC->(dbSetOrder(1))
               lSeek:= WorkEDC->(dbSeek(cREap+cProdAp,.T.))  //SoftSeek
            EndIf
         ElseIf !Empty(cREap)
            WorkEDC->(dbSetOrder(1))
            lSeek:= WorkEDC->(dbSeek(cREap,.T.))  //SoftSeek
         Else
            WorkEDC->(dbSetOrder(2))
            lSeek:= WorkEDC->(dbSeek(cProdAp,.T.)) //SoftSeek
         EndIf
         If !lSeek
            Help(" ",1,"AVG0005273") //"A Pesquisa não encontrou registros com essas Infornmações."
            oMark7:oBrowse:Refresh()
         Else
            oMark7:oBrowse:Refresh()
         EndIf
      Endif
   ElseIf nOpca==1
      Loop
   Else
      Exit
   EndIf

   Exit
EndDo

Return .T.

*-------------------------------------------------------------------------------------*
Static Function ValPesqRes(nTipoAp,cItemAp,cREAp,cProdAp)
*-------------------------------------------------------------------------------------*
Local lRet := .T.

If nTipoAp = 1
   dbSelectArea("SB1")
   If !Empty(cItemAp) .and. !ExistCpo("SB1",cItemAp)
      lRet:= .F.
   EndIf
ElseIf nTipoAp = 2
   dbSelectArea("SB1")
   If !Empty(cProdAp) .and. Empty(cREAp) .and. !Empty(cItemAp)
      Help(" ",1,"AVG0005278") //"O Item não pode ser Preenchido."
      lRet:= .F.
   ElseIf !Empty(cItemAp) .and. !ExistCpo("SB1",cItemAp)
      lRet:= .F.
   Endif
ElseIf nTipoAp = 3
   If !Empty(cProdAp) .and. Empty(cREAp) .and. !Empty(cItemAp)
      Help(" ",1,"AVG0005276") //"O Produto não pode ser Preenchido."
      lRet:= .F.
   ElseIf !Empty(cProdAp) .and. !ExistCpo(cAliasSB1,cProdAp)
      lRet:= .F.
   Endif
ElseIf nTipoAp = 4
   If !Empty(cProdAp) .and. Empty(cREAp) .and. !Empty(cItemAp)
      Help(" ",1,"AVG0005279") //"Chave de pesquisa incorreta."
      lRet:= .F.
   ElseIf Empty(cItemAp) .and. Empty(cREap) .and. Empty(cProdap)
      Help(" ",1,"AVG0005277") //"O item não foi Preenchido."
      lRet:= .F.
   ElseIf !Empty(cItemAp) .and. !ExistCpo("SB1",cItemAp)
      lRet:= .F.
   ElseIf !Empty(cProdAp) .and. !ExistCpo(cAliasSB1,cProdAp)
      lRet:= .F.
   Endif
EndIf

Return lRet

*-----------------------------------------------------------------------------------------------*
Static Function ACPesqED1()                // R
*-----------------------------------------------------------------------------------------------*
Local oDlgR
Local nOpca:=0, lSeek, cF3:= "SB1", cOrd:=STR0274, oCbxOrd
Local bOk := {||nOpca:=1,oDlgR:End()}, aOrd:={STR0274,STR0275}//"1 - RE + Produto" # "2 - Produto + RE"
Local bCancel := {||nOpca:=0,oDlgR:End()}
Local cRE:=Space(Len(ED2->ED2_RE)), cProd:=Space(Len(ED1->ED1_PROD))

While .T.

   nOpca:= 0
   cRE  :=Space(Len(ED2->ED2_RE))
   cProd:=Space(Len(ED1->ED1_PROD))

   DEFINE MSDIALOG oDlgR TITLE STR0140; //"Pesquisa por:"
       FROM 05,05 TO 21,55 OF GetWndDefault()

   oPanel:= TPanel():New(0,0, "", oDlgR,, .T., ,,,0,0,,.T.) //LGS-11/12/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   @01.5,02 SAY   AVSX3("EE9_RE",5) of oPanel
   @01.5,08 MSGET cRE  SIZE 60,8 of oPanel //PICT AVSX3("EE9_RE",6)
   @02.5,02 SAY   AVSX3("ED1_PROD",5) of oPanel
   If lAbriuExp // F4 para produtos a exportar
      SETKEY(VK_F4,{||EDCAC400HLP(@cProd)})
      @02.5,08 MSGET cProd PICT AVSX3("ED1_PROD",6) Valid ValPesqED1(1,,cProd,cRE) SIZE 60,8 of oPanel
      @02.5,15.5 SAY STR0170 of oPanel //"(F4-Pesquisa)"
   Else
      @02.5,08 MSGET cProd PICT AVSX3("ED1_PROD",6) F3 cF3 Valid ValPesqED1(1,,cProd,cRE) SIZE 60,8 of oPanel
   Endif
   @03.5,02 SAY STR0273 of oPanel //"Ordem"
   @03.5,08 ComboBox oCbxOrd Var cOrd Items aOrd SIZE 80,08 Valid (Left(cOrd,1)=="1" .or. Left(cOrd,1)=="2") of oPanel

   ACTIVATE MSDIALOG oDlgR ON INIT EnchoiceBar(oDlgR,{||nOpca:=1, Eval(bOk)},{||nOpca:=0,oDlgR:End()}) CENTERED

   If nOpca==1 .And. ValPesqED1(2,cOrd,cProd,cRE)
      If Left(cOrd,1)=="1"
         WorkED1->(dbSetOrder(4))
         If !Empty(cRE) .and. !Empty(cProd)
            lSeek:= WorkED1->(dbSeek(cRE+cProd,.T.))  //SoftSeek
         Else
            lSeek:= WorkED1->(dbSeek(cRE,.T.))  //SoftSeek
         EndIf
      Else
         WorkED1->(dbSetOrder(6))
         If !Empty(cRE) .and. !Empty(cProd)
            lSeek:= WorkED1->(dbSeek(cProd+cRE,.T.))  //SoftSeek
         Else
            lSeek:= WorkED1->(dbSeek(cProd,.T.))  //SoftSeek
         EndIf
      EndIf
      If !lSeek
         Help(" ",1,"AVG0005273") //"A Pesquisa não encontrou registros com essas Infornmações."
         WorkED1->(dbSetOrder(1))
         WorkED1->( DBGoTop() )
         oMark:oBrowse:Refresh()
      Else
         WorkED1->(dbSetOrder(1))
         oMark:oBrowse:Refresh()
      EndIf
   ElseIf nOpca==1
      Loop
   Else
      Exit
   EndIf

   Exit
EndDo

Return .T.

*---------------------------------------------------------------------------------------------*
Static Function ValPesqED1(nTipoAp,cOrd,cProd,cRE)
*---------------------------------------------------------------------------------------------*
Local lRet := .T.

DBSelectArea("WORKED1")

If nTipoAp = 1
   If !Empty(cProd) .and. !ExistCpo(cAliasSB1,cProd)
      lRet:= .F.
   EndIf
ElseIf nTipoAp = 2
   If Empty(cProd) .and. Empty(cRE)
      Help(" ",1,"AVG0005279") //"Chave de pesquisa incorreta."
      lRet:= .F.
   ElseIf Empty(cProd) .and. Left(cOrd,1)=="2"
      Help(" ",1,"AVG0005279") //"Chave de pesquisa incorreta."
      lRet:= .F.
   ElseIf Empty(cRE) .and. Left(cOrd,1)=="1"
      Help(" ",1,"AVG0005279") //"Chave de pesquisa incorreta."
      lRet:= .F.
   ElseIf !Empty(cProd) .and. !ExistCpo(cAliasSB1,cProd)
      lRet:= .F.
   Endif
EndIf

Return lRet

*------------------------------------------------------------------------------------------------*
Static Function EstED2Ante(cRe,cProd)
*------------------------------------------------------------------------------------------------*
Do While !WorkED2->(EOF()) .and. WorkED2->ED2_RE==cRe .and. WorkED2->ED2_PROD==cProd
   aAdd(aDelWkED2,WorkED2->ED2_RECNO)
   WorkED4Atu("WorkED2",ESTORNAR,,,M->ED0_MODAL==ISENCAO)
   AC400Totais("WorkED2",ESTORNAR)
   AC400GrvEDA(ESTORNAR,WorkED2->ED2_ITEM,WorkED2->ED2_QTD,0)
   AC400EDCGrv(ESTORNAR,WorkED2->ED2_ITEM,WorkED2->ED2_RE,WorkED2->ED2_PROD,WorkED2->ED2_QTD,0)
   WorkED2->(RecLock("WorkED2",.F.,.T.))
   WorkED2->(DBDELETE())
   WorkED2->(MSUnlock())
   WorkED2->(dbSkip())
EndDo

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function GrvAnterioridade()
*----------------------------------------------------------------------------------------------*
Local nQtdAux:=0, nQtdTrans:=0, nRecDI, aCpoAux:={}, nInd:=0
Local nCalcLead := 0

If ! AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
   nQtdTrans := AVTransUnid(WorkDI->UNID,SB1->B1_UM,WorkDI->ED2_ITEM,If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD))
Else
   nQtdTrans := WorkDI->ED2_PESO
Endif

If WorkExpl->(dbSeek(iif(lED2Inat,If(Empty(WorkDI->ED2_INAT),WorkDI->ED2_ITEM,WorkDI->ED2_INAT),WorkDI->ED2_ITEM)))   // ACSJ - 17/11/2004

   Do While !WorkExpl->(EOF()) .and. WorkExpl->ITEM == iif(lED2Inat,If(Empty(WorkDI->ED2_INAT),WorkDI->ED2_ITEM,WorkDI->ED2_INAT),WorkDI->ED2_ITEM) .and. nQtdTrans > 0  // ACSJ - 17/11/2004
      //If WorkExpl->QUANT2 <= 0 .or. WorkDI->DATAANT > (WorkExpl->DT_RE - If(lLeadTime .AND. WorkExpl->LEADTIME > 0,WorkExpl->LEADTIME,nLeadAnt)) .or. If(nIntAnt<>0, WorkExpl->DT_RE > (WorkDI->DATAANT + nIntAnt) ,.F.)

      If WorkExpl->QUANT2 <= 0
         WorkExpl->(dbSkip())
         Loop
      EndIf

      If lLeadTime
         If WorkExpl->LEADTIME > 0 .and. WorkExpl->PRODUC > 0
            nCalcLead := Int((WorkExpl->QUANT2 * WorkExpl->LEADTIME)/WorkExpl->PRODUC)
         ElseIf WorkExpl->LEADTIME > 0 .and. WorkExpl->PRODUC = 0   //TRP - 05/04/2010
             nCalcLead := Int((WorkExpl->QUANT2 * WorkExpl->LEADTIME)/WorkExpl->QUANT2)
            //nCalcLead := WorkExpl->LEADTIME
         Else
            nCalcLead := nLeadAnt
         EndIf
      Else
         nCalcLead := nLeadAnt
      EndIf

      // BAK - alteração para comparar as datas corretamente - 29/06/2011
      // If WorkDI->DATAANT > nCalcLead
      If WorkDI->DATAANT > (WorkExpl->DT_RE - nCalcLead)
         WorkExpl->(dbSkip())
         Loop
      EndIf

      If nIntAnt<>0 .and. (WorkExpl->DT_RE > (WorkDI->DATAANT + nIntAnt))
         WorkExpl->(dbSkip())
         Loop
      EndIf

      If nQtdTrans <= WorkExpl->QUANT2

         // PLB 27/11/06 - Verifica se pode bloquear os registros
         If !oMUserEDC:Reserva("ATO","MARCA_DI")
            WorkExpl->(dbSkip())
            Loop
         EndIf

         WorkExpl->QUANT2 -= nQtdTrans
         WorkDI->ED2_RE   := WorkExpl->RE
         WorkDI->ED2_PROD := WorkExpl->PROD

         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTRE")) > 0
            WorkDI->ED2_DTRE := WorkExpl->DT_RE
         EndIF

         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
            WorkDI->ED2_DTEMBA := WorkExpl->ED2_DTEMBA
         EndIF

         // ** AAF 01/06/05 - Valor comercial a Perda
         If lTemVLCOMPE
            WorkDI->ED2_VLCOPE:= WorkExpl->VLCOMPE
         EndIf
         // **

         WorkDI->MARCA     := cMarca
         nQtdTrans := 0

      Else
         nRecDI  := WorkDI->(RecNo())
         For nInd:=1 to WorkDI->(FCount())
            aAdd(aCpoAux,WorkDI->(FieldGet(nInd)))
         Next nInd

         If ! AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
            nQtdAux := AVTransUnid(SB1->B1_UM,WorkDI->UNID,WorkDI->ED2_ITEM,WorkExpl->QUANT2)
         Else
            nQtdAux := WorkExpl->QUANT2 * nCoefPeso
         EndIf
         If Round((WorkDI->VALEMBORI / WorkDI->QTDORI) * nQtdAux,2) <= 0
            aCpoAux:= {}
            WorkExpl->(dbSkip())
            Loop
         EndIf

         // PLB 27/11/06 - Verifica se pode bloquear os registros
         If !oMUserEDC:Reserva("ATO","MARCA_DI")
            aCpoAux:= {}
            WorkExpl->(dbSkip())
            Loop
         EndIf

         WorkDI->(RecLock("WorkDI",.T.))   //Registro marcado de acordo com anterioridade
         For nInd:=1 to Len(aCpoAux)
            WorkDI->&(FIELDNAME(nInd)) := aCpoAux[nInd]
         Next nInd
         WorkDI->ED2_RE   := WorkExpl->RE
         WorkDI->ED2_PROD := WorkExpl->PROD
         WorkDI->TRB_ALI_WT:= "ED2"
         WorkDI->TRB_REC_WT:= ED2->(Recno())
         // ** AAF 01/06/05 - Valor comercial a Perda
         If lTemVLCOMPE
            WorkDI->ED2_VLCOPE:= WorkExpl->VLCOMPE
         EndIf

         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTRE")) > 0
            WorkDI->ED2_DTRE := WorkExpl->DT_RE
         EndIF

         //AOM - 14/03/2012
         IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
            WorkDI->ED2_DTEMBA := WorkExpl->ED2_DTEMBA
         EndIF
         // **

         //nQtdAux := AVTransUnid(SB1->B1_UM,WorkDI->UNID,WorkDI->ED2_ITEM,WorkExpl->QUANT2)
         //AAF 28/07/05 - Quantidade na unidade da invoice.
         If ! AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
            If ! AvVldUn( WorkDI->UNID ) // MPG - 14/02/2018
               WorkDI->ED2_PESO   := (nQtdAux / If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)) * WorkDI->ED2_PESO
            Else
               WorkDI->ED2_PESO   := nQtdAux
            EndIf
         Else
            WorkDI->ED2_PESO := WorkExpl->QUANT2
         Endif

         //AAF 05/10/05 - Não permite arredondamento para cima, para não utilizar maior quantidade do que a necessária.
         //If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)  := Int(nQtdAux) + Val("0."+SubStr(Str(nQtdAux),At(".",Str(nQtdAux))+1,At(".",Str(nQtdAux,0))+AvSx3("ED2_QTD",4))) //Unidade da DI.
         //AAF 15/03/06 - Arredondamento para baixo.

         If WorkDI->ISENTOT=="N"
            WorkDI->SALISEN := AC400Round(nQtdAux,"ED2_QTD")//Int(nQtdAux) + Val("0."+SubStr(AllTrim(Str(nQtdAux)),nColIni+1,AvSx3("ED2_QTD",4))) //Unidade da DI.
         Else
            WorkDI->ED2_QTD := AC400Round(nQtdAux,"ED2_QTD")//Int(nQtdAux) + Val("0."+SubStr(AllTrim(Str(nQtdAux)),nColIni+1,AvSx3("ED2_QTD",4))) //Unidade da DI.
         EndIf

         /*
         If WorkDI->ISENTOT=="N"
            WorkDI->SALISEN := Round(nQtdAux,AvSx3("ED2_QTD",4))
         Else
            WorkDI->ED2_QTD := Round(nQtdAux,AvSx3("ED2_QTD",4))
         Endif
         */
         WorkDI->MARCA      := cMarca
         WorkDI->ED2_VALEMB := AC400Round((WorkDI->VALEMBORI / WorkDI->QTDORI) * nQtdAux,"ED2_VALEMB")
         WorkDI->ED2_VL_MOE := AC400Round((WorkDI->VLMOEORI / WorkDI->VALEMBORI) * WorkDI->ED2_VALEMB,"ED2_VALEMB")

         // ** AAF - 10/11/05 - Valor com preço Original.
         WorkDI->ED2_VALORI := AC400Round(If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)/WorkDI->QTDORI * nValOriTotMoe,"ED2_VALORI") //AAF 16/03/06 - Usado o Valor Original total para proporcionalizar. //WorkDI->ED2_VALORI
         // **

         WorkDI->(msUnlock())

         WorkDI->(dbGoTo(nRecDI))   //Registro com acumulado desmarcado

         If ! AvVldUn( WorkDI->UNID ) // MPG - 14/02/2018
            If ! AvVldUn( SB1->B1_UM ) // MPG - 14/02/2018
               WorkDI->ED2_PESO   := ((If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) - nQtdAux) / If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)) * WorkDI->ED2_PESO
            Else
               WorkDI->ED2_PESO   := nQtdTrans - WorkExpl->QUANT2
            EndIf
         Else
            WorkDI->ED2_PESO -= nQtdAux
         Endif

         If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)  -= nQtdAux
         WorkDI->ED2_VALEMB := (WorkDI->VALEMBORI / WorkDI->QTDORI) * If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)
         WorkDI->ED2_VL_MOE := (WorkDI->VLMOEORI / WorkDI->VALEMBORI) * WorkDI->ED2_VALEMB

         //AAF 10/11/05 - Abate valor com preço original associado.
         WorkDI->ED2_VALORI := Round(If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)/WorkDI->QTDORI * nValOriTotMoe,AvSx3("ED2_VALORI",4)) //AAF 16/03/06 - Usado o Valor Original total para proporcionalizar. //WorkDI->ED2_VALORI

         nQtdTrans -= WorkExpl->QUANT2
         WorkExpl->QUANT2 := 0

         aCpoAux:= {}//AAF 18/07/05
      EndIf
      WorkExpl->(dbSkip())
   EndDo
EndIf

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function GeraWKExpl()
*-----------------------------------------------------------------------------------------------*
Local aSX3Expl:={}

AADD(aSX3Expl,{"ITEM"  ,"C",AVSX3("ED2_ITEM",3),0})
AADD(aSX3Expl,{"RE"    ,"C",AVSX3("ED2_RE"  ,3),0})
AADD(aSX3Expl,{"PROD"  ,"C",AVSX3("ED1_PROD",3),0})
AADD(aSX3Expl,{"QUANT1","N",AVSX3("ED2_QTD" ,3),AVSX3("ED2_QTD",4)})
AADD(aSX3Expl,{"QUANT2","N",AVSX3("ED2_QTD" ,3),AVSX3("ED2_QTD",4)})
AADD(aSX3Expl,{"QTD"   ,"N",AVSX3("ED1_QTD" ,3),AVSX3("ED1_QTD",4)})
AADD(aSX3Expl,{"DT_RE" ,"D",8,0})

IF ED2->(FIELDPOS("ED2_DTEMBA")) > 0
   AADD(aSX3Expl,{"ED2_DTEMBA"   ,"D",AVSX3("ED2_DTEMBA",3),AVSX3("ED2_DTEMBA",4)})
ENDIF

//AAF 23/07/09
If lLeadTime
   aAdd(aSX3Expl,{"LEADTIME",AVSX3("B1_LEADTI",AV_TIPO),AVSX3("B1_LEADTI",AV_TAMANHO),AVSX3("B1_LEADTI",AV_DECIMAL)})
   aAdd(aSX3Expl,{"PRODUC"  ,AVSX3("B1_PRODUC",AV_TIPO),AVSX3("B1_PRODUC",AV_TAMANHO),AVSX3("B1_PRODUC",AV_DECIMAL)})
EndIf

If lTemVLCOMPE
   AADD(aSX3Expl,{"VLCOMPE","C",1,0})
EndIf

FWorkExpl2:=E_Create(,.F.)
FWorkExpl := E_CriaTrab(, aSX3Expl, "WorkExpl")
IndRegua("WorkExpl",FWorkExpl+TEOrdBagExt()  ,"ITEM+RE+PROD")
IndRegua("WorkExpl",FWorkExpl2+TEOrdBagExt() ,"RE+PROD")
SET INDEX TO (FWorkExpl+TEOrdBagExt()),(FWorkExpl2+TEOrdBagExt())
WorkExpl->(dbSetOrder(1))

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function ACGetAnt()
*-----------------------------------------------------------------------------------------------*
Local oDlgS, cProd:=WorkDI->ED2_PROD, cRE:=WorkDI->ED2_RE, nOpca:=0, aCpoAux:={}, nInd
Local bOk:={||nOpca:=1,oDlgS:End()}
Private nQtdAux := iif(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)

nLin:=25
nCol:=45
DEFINE MSDIALOG oDlgS TITLE STR0276 FROM 12,05 TO nLin,nCol OF GetWndDefault() //// STR0276 = "Anterioridade"

   If Select("WorkExpl") <> 0
      SETKEY(VK_F4,{||ACHLPPROD(@cRE,@cProd)})
   EndIf
   nLin := 3.5
   nCol := 1
   @nLin,nCol SAY   AVSX3("EE9_RE",5) of oDlgS
   nCol += 5
   @nLin,nCol MSGET cRE  SIZE 60,8 //PICT AVSX3("EE9_RE",6)
   
   nLin := 4.5
   nCol := 1
   @nLin,nCol SAY   AVSX3("ED1_PROD",5) of oDlgS
   nCol += 5
   @nLin,nCol MSGET cProd  PICT AVSX3("ED1_PROD",6) Valid (Empty(cProd) .or. AcExistCpo(cAliasSB1,cProd)) SIZE 60,8

   If Select("WorkExpl") <> 0 .or. lAbriuExp
      nLin := 3.5
      nCol += 8
      @nLin,nCol SAY STR0170 of oDlgS //"(F4-Pesquisa)"
   EndIf

   nLin := 5.5
   nCol := 1
   @nLin,nCol SAY   AVSX3("ED2_QTDNCM",5) of oDlgS
   nCol += 5
   @nLin,nCol MSGET nQtdAux PICT AVSX3("ED2_QTDNCM",6) Valid (nQtdAux>0 .and. nQtdAux<=If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)) SIZE 60,8

ACTIVATE MSDIALOG oDlgS ON INIT EnchoiceBar(oDlgS,{||If(AcValAnt(cRe,cProd),Eval(bOk),)},{||nOpca:=0,oDlgS:End()}) CENTERED

If nOpca=1
   If nQtdAux < If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)
      For nInd:=1 to WorkDI->(FCount())                 //Registro Marcado com a Quant. Selecionada
         aAdd(aCpoAux,WorkDI->(FieldGet(nInd)))
      Next nInd
      If ! AvVldUn( WorkDI->UNID ) // MPG - 14/02/2018
         WorkDI->ED2_PESO   := (nQtdAux / If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)) * WorkDI->ED2_PESO
      Else
         WorkDI->ED2_PESO   := nQtdAux
      EndIf

      nRate := nQtdAux / If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)

      If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD) := nQtdAux
      WorkDI->ED2_VALEMB := (WorkDI->VALEMBORI / WorkDI->QTDORI) * nQtdAux
      WorkDI->ED2_VL_MOE := (WorkDI->VLMOEORI / WorkDI->VALEMBORI) * WorkDI->ED2_VALEMB

      //AAF - 10/11/05 - Valor com Preço Original na moeda da Invoice.
      nValOri            := Round(nRate * WorkDI->ED2_VALORI,AvSx3("ED2_VALORI",4))
      WorkDI->ED2_VALORI := nValOri

      WorkDI->ED2_RE     := cRE
      WorkDI->ED2_PROD   := cProd

      // ** AAF 11/08/2006 - Guarda o registro marcado.
      nRecDI := WorkDI->( RecNo() )

      WorkDI->(RecLock("WorkDI",.T.))                   //Registro com o saldo restante
      For nInd:=1 to Len(aCpoAux)
         WorkDI->&(FIELDNAME(nInd)) := aCpoAux[nInd]
      Next nInd
      /*WorkDI->ED2_RE  := cRE
      WorkDI->ED2_PROD:= cProd*/
      WorkDI->MARCA   := ""
      If ! AvVldUn( WorkDI->UNID ) // MPG - 14/02/2018
         WorkDI->ED2_PESO   := (If(WorkDI->ISENTOT=="N",WorkDI->SALISEN - nQtdAux,WorkDI->ED2_QTD - nQtdAux) / If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)) * WorkDI->ED2_PESO
      Else
         WorkDI->ED2_PESO   := If(WorkDI->ISENTOT=="N",WorkDI->SALISEN - nQtdAux,WorkDI->ED2_QTD - nQtdAux)
      EndIf

      If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)  -= nQtdAux
      WorkDI->ED2_VALEMB := (WorkDI->VALEMBORI / WorkDI->QTDORI) * If(WorkDI->ISENTOT=="N",WorkDI->SALISEN,WorkDI->ED2_QTD)
      WorkDI->ED2_VL_MOE := (WorkDI->VLMOEORI / WorkDI->VALEMBORI) * WorkDI->ED2_VALEMB

      //AAF - 10/11/05 - Valor com Preço Original na Moeda da Invoice.
      WorkDI->ED2_VALORI -= nValOri

      WorkDI->TRB_ALI_WT:= "ED2"
      WorkDI->TRB_REC_WT:= ED2->(Recno())
      WorkDI->(msUnlock())

      // ** AAF 11/08/2006 - Posiciona no registro marcado.
      WorkDI->( dbGoTo(nRecDI) )

      oMarkDI:oBrowse:Refresh()
   Else
      WorkDI->ED2_RE  := cRE
      WorkDI->ED2_PROD:= cProd
   EndIf

EndIf

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function AcValAnt(cRE,cProd)
*-----------------------------------------------------------------------------------------------*
Local lRet := .T.

If Empty(cRE) .and. !Empty(cProd)
   Help(" ",1,"AVG0005280") //Informações incorretas
   lRet := .F.
ElseIf !Empty(cRE) .and. Empty(cProd)
   Help(" ",1,"AVG0005280") //Informações incorretas
   lRet := .F.
ElseIf !Empty(cRE)
   If !AcExistCpo("WorkED1",cRE+cProd,4,.F.,.F.) .and. If(Select("WorkExpl")<>0, !AcExistCpo("WorkExpl",cRE+cProd,2,,.F.), .T.)
      lRet := .F.
   EndIf
ElseIf Round((WorkDI->VALEMBORI / WorkDI->QTDORI) * nQtdAux ,2) <= 0
   MsgInfo(STR0290) //"Quantidade informada zeraria o valor total. Item não poderá ser marcado com o valor zerado."
   lRet := .F.
Endif

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ ACexistcpo ³ Autor ³ Gustavo  		  ³ Data ³			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o criterio de validacao dos campos				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ExpL1:=Existcpo(cAlias,cChave,nOrdem)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias = Alias do arquivo a verificar      				  ³±±
±±³			 ³ cChave = Chave de pesquisa    							  ³±±
±±³			 ³ nOrdem = Ordem para pesquisa no arquivo					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 							    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function AcExistCpo(cAlias,cChave,nOrdem,lMens,lFilial,lRetRec,lRetOrd)
Local xAlias,nSalvReg,cFil,nOldOrder,lRet

If(lMens=NIL,lMens:=.T.,)
If(lRetRec=NIL,lRetRec:=.T.,)
If(lRetOrd=NIL,lRetOrd:=.T.,)
If(lFilial=NIL,lFilial:=.T.,)

If ValType(cChave) == "U"
	cChave := &(ReadVar())
EndIf

xAlias := Alias()
nOldOrder := (cAlias)->(IndexOrd())

// Compatibilizacao da versao SIGACTB / SIGACON -> Somente 6.09!!
If !CtbInUse()
	If cAlias == "CT1"
		cAlias := "SI1"
	EndIf
	If cAlias == "CTD"
		cAlias := "SID"
	EndIf
	If cAlias == "CTT"
		cAlias := "SI3"
	EndIf
	If cAlias == "CT5"
		cAlias := "SI5"
	EndIf
EndIf

DbSelectArea(cAlias)

If Eof() .Or. RecC() == 0
	nSalvReg := 0
Else
	nSalvReg := RecNo()
EndIf

If Subs(cAlias,1,3) $ "SM2#SM0#SX2" .or. !lFilial
	cFil := ""
Else
	cFil := cFilial
EndIf

nOrdem := If(nOrdem == NIL,IndexOrd(),nOrdem)
DbSetOrder(nOrdem)
lRet := DbSeek(cFil+cChave)

If !lRet .and. lMens
	Help(" ",1,"REGNOIS")
EndIf

If nSalvReg > 0 .and. lRetRec
	DbGoTo(nSalvReg)
EndIf
If lRetOrd
   (cAlias)->(DbSetorder(nOldOrder))
EndIf
DbSelectArea(xAlias)
Return lRet

*---------------------------------------------------------------------------------------------*
Static Function ACHLPPROD(cRegistro,cProduto)
*---------------------------------------------------------------------------------------------*
LOCAL oDlgT, Tb_Campos:={},lOK:=.F., oMarkHlp
LOCAL bAction:={||lOK:=.T.,(cProduto:=WorkSel->PROD),(cRegistro:=WorkSel->RE),oDlgT:End()}

IF !ReadVar() $ "CPROD/CRE"
   RETURN .F.
ENDIF

If Select("WorkSel") = 0
   ACGrvHlp()
EndIf

AADD(Tb_Campos,{"RE"  ,,AVSX3("EE9_RE"  ,5)})
AADD(Tb_Campos,{"PROD",,AVSX3("ED1_PROD",5)})

DEFINE MSDIALOG oDlgT TITLE STR0073 FROM 4,3 TO 20,55 OF oMainWnd //"Pesquisa de Produtos"

   dbSelectArea("WorkSel")
   dbGoTop()

   oMarkHlp:= MsSelect():New("WorkSel",,,TB_Campos,@lInverte,@cMarca,{20,6,100,160})
   oMarkHlp:baval:=bAction

   DEFINE SBUTTON FROM 10,165 TYPE 1 ACTION (EVAL(bAction)) ENABLE OF oDlgT PIXEL
   DEFINE SBUTTON FROM 25,165 TYPE 2 ACTION (lOK:=.F.,oDlgT:End()) ENABLE OF oDlgT PIXEL

ACTIVATE MSDIALOG oDlgT CENTERED

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function ACGrvHlp()
*-----------------------------------------------------------------------------------------------*
Local aSemSx3Sel:={}, nRecExpl:=WorkExpl->(RecNo())

AADD(aSemSX3Sel,{"RE"    ,"C",AVSX3("ED2_RE",3),0})
AADD(aSemSX3Sel,{"PROD"  ,"C",AVSX3("ED1_PROD",3),0})
//TRP - 01/02/07 - Campos do WalkThru
AADD(aSemSX3Sel,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3Sel,{"TRB_REC_WT","N",10,0})


FWorkSel :=E_CriaTrab(, aSemSX3Sel, "WorkSel")
IndRegua("WorkSel",FWorkSel+TEOrdBagExt() ,"RE+PROD")
SET INDEX TO (FWorkSel+TEOrdBagExt())

WorkExpl->(dbGoTop())
Do While !WorkExpl->(EOF())
   If !WorkSel->(dbSeek(WorkExpl->RE+WorkExpl->PROD))
      WorkSel->(RecLock("WorkSel",.T.))
      WorkSel->PROD := WorkExpl->PROD
      WorkSel->RE   := WorkExpl->RE
      WorkSel->TRB_ALI_WT:= "ED1"
      WorkSel->TRB_REC_WT:= ED1->(Recno())
      WorkSel->(msUnlock())
   EndIf
   WorkExpl->(dbSkip())
EndDo

WorkExpl->(dbGoTo(nRecExpl))

Return .T.

*---------------------------------------------------------------------------------------------*
Static Function ACDetDI()
*---------------------------------------------------------------------------------------------*
Local aSemSx3Det:={}, cDi:=WorkED2->ED2_DI_NUM, cItem:=WorkED2->ED2_ITEM, oDlgDet, oMarkDet
Local nRecED2:=WorkED2->(RecNo()), nOrdED2:=WorkED2->(IndexOrd()), cPosica:=WorkED2->ED2_POSICA
Local cInv:=WorkED2->ED2_INVOIC, cPo:=WorkED2->ED2_PO_NUM, cPgi:=WorkED2->ED2_PGI_NU, aDetCpos:={}
Local cPd:=M->ED0_PD, cHawb:=WorkED2->ED2_HAWB, nSaldo, nUsado:=0
Local oPanelDet
Local cFilAux := ""
Local cFilOri := ""

If lMultiFil
   cFilOri := WorkED2->ED2_FILORI
EndIf

If WorkED2->(EOF()) .and. WorkED2->(BOF())
   Help("", 1, "ARQVAZIO")
   Return .T.
EndIf

SW8->(dbSetOrder(6))

AADD(aDetCpos,{"AC"     ,,AVSX3("ED0_AC"    ,5),AVSX3("ED0_AC"    ,6)})
AADD(aDetCpos,{"PD"     ,,AVSX3("ED0_PD"    ,5),AVSX3("ED0_PD"    ,6)})
AADD(aDetCpos,{"PROD"   ,,AVSX3("ED1_PROD"  ,5),AVSX3("ED1_PROD"  ,6)})
AADD(aDetCpos,{"RE"     ,,AVSX3("ED1_RE"    ,5),  }) //AVSX3("ED1_RE"    ,6)
AADD(aDetCpos,{"ITEM"   ,,AVSX3("ED2_ITEM"  ,5),AVSX3("ED2_ITEM"  ,6)})
AADD(aDetCpos,{"DI"     ,,AVSX3("ED2_DI_NUM",5),AVSX3("ED2_DI_NUM",6)})
AADD(aDetCpos,{"ADICAO" ,,AVSX3("ED2_ADICAO",5),AVSX3("ED2_ADICAO",6)})
AADD(aDetCpos,{"QT_COMP",,AVSX3("ED2_QTDNCM",5),AVSX3("ED2_QTDNCM",6)})
AADD(aDetCpos,{"QT_ESTO",,AVSX3("ED2_QTD"   ,5),AVSX3("ED2_QTD"   ,6)})
AADD(aDetCpos,{"PESO"   ,,AVSX3("ED2_PESO"  ,5),AVSX3("ED2_PESO"  ,6)})
AADD(aDetCpos,{"VALEMB" ,,AVSX3("ED2_VALEMB",5),AVSX3("ED2_VALEMB",6)})
AADD(aDetCpos,{"FRETE"  ,,AVSX3("ED2_FRETE" ,5),AVSX3("ED2_FRETE" ,6)})
AADD(aDetCpos,{"SEGURO" ,,AVSX3("ED2_SEGURO",5),AVSX3("ED2_SEGURO",6)})

If Select("WorkDet") = 0
   AADD(aSemSx3Det,{"AC"     ,"C",AVSX3("ED0_AC",3),0})
   AADD(aSemSx3Det,{"PD"     ,"C",AVSX3("ED0_PD",3),0})
   AADD(aSemSx3Det,{"PROD"   ,"C",AVSX3("ED1_PROD",3),0})
   AADD(aSemSx3Det,{"RE"     ,"C",AVSX3("ED1_RE",3),0})
   AADD(aSemSx3Det,{"ITEM"   ,"C",AVSX3("ED2_ITEM",3),0})
   AADD(aSemSx3Det,{"DI"     ,"C",AVSX3("ED2_DI_NUM",3),0})
   AADD(aSemSx3Det,{"ADICAO" ,"C",AVSX3("ED2_ADICAO",3),0})
   AADD(aSemSx3Det,{"QT_COMP","N",AVSX3("ED2_QTDNCM",3),AVSX3("ED2_QTDNCM",4)})
   AADD(aSemSx3Det,{"QT_ESTO","N",AVSX3("ED2_QTD",3),AVSX3("ED2_QTD",4)})
   AADD(aSemSx3Det,{"PESO"   ,"N",AVSX3("ED2_PESO",3),AVSX3("ED2_PESO",4)})
   AADD(aSemSx3Det,{"VALEMB" ,"N",AVSX3("ED2_VALEMB",3),AVSX3("ED2_VALEMB",4)})
   AADD(aSemSx3Det,{"FRETE"  ,"N",AVSX3("ED2_FRETE",3),AVSX3("ED2_FRETE",4)})
   AADD(aSemSx3Det,{"SEGURO" ,"N",AVSX3("ED2_SEGURO",3),AVSX3("ED2_SEGURO",4)})
   //TRP - 01/02/07 - Campos do WalkThru
   AADD(aSemSX3Det,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3Det,{"TRB_REC_WT","N",10,0})

   FWorkDet :=E_CriaTrab(, aSemSx3Det, "WorkDet")
   IndRegua("WorkDet",FWorkDet+TEOrdBagExt() ,"PD+ADICAO")
   SET INDEX TO (FWorkDet+TEOrdBagExt())
Else
   WorkDet->(avzap())
EndIf

If lMultiFil
   cFilAux := Left(WorkED2->ED2_FILORI,2)
Else
   cFilAux := cFilSW8
EndIf
SW8->(dbSeek(cFilAux+WorkED2->ED2_HAWB+WorkED2->ED2_INVOIC+WorkED2->ED2_PO_NUM+WorkED2->ED2_POSICA+WorkED2->ED2_PGI_NU))

WorkED2->(dbSetOrder(5))
WorkED2->(dbSeek(cDi+cItem))
Do While !WorkED2->(EOF()) .and. WorkED2->ED2_DI_NUM==cDi .and. WorkED2->ED2_ITEM==cItem
   If WorkED2->ED2_INVOIC==cInv .and. WorkED2->ED2_PO_NUM==cPo .and. WorkED2->ED2_POSICA==cPosica .and.;
   WorkED2->ED2_PGI_NU==cPgi
      WorkDet->(RecLock("WorkDet",.T.))
      If(!Empty(M->ED0_AC), WorkDet->AC := "ATUAL", )
      WorkDet->PD     := "ATUAL"
      WorkDet->PROD   := WorkED2->ED2_PROD
      WorkDet->RE     := WorkED2->ED2_RE
      WorkDet->ITEM   := WorkED2->ED2_ITEM
      WorkDet->DI     := WorkED2->ED2_DI_NUM
      WorkDet->ADICAO := WorkED2->ED2_ADICAO
      WorkDet->QT_COMP:= WorkED2->ED2_QTDNCM
      WorkDet->QT_ESTO:= WorkED2->ED2_QTD
      WorkDet->PESO   := WorkED2->ED2_PESO
      WorkDet->VALEMB := WorkED2->ED2_VALEMB
      WorkDet->FRETE  := WorkED2->ED2_FRETE
      WorkDet->SEGURO := WorkED2->ED2_SEGURO
      WorkDet->TRB_ALI_WT:= "ED2"
      WorkDet->TRB_REC_WT:= ED2->(Recno())
      WorkDet->(msUnlock())
      If WorkED2->ED2_RECNO = 0
         // ** AAF 11/10/05 - Converter da U.M. de Compra do Ato para U.M. de Compra da DI.
         If WorkED2->ED2_UMNCM <> SW8->W8_UNID
            nUsado += AvTransUnid(WorkED2->ED2_UMNCM,SW8->W8_UNID,cItem,WorkED2->ED2_QTDNCM)
         Else
            nUsado += WorkED2->ED2_QTDNCM
         Endif
         // **
      EndIf
   EndIf
   WorkED2->(dbSkip())
EndDo
WorkED2->(dbSetOrder(nOrdED2))
WorkED2->(dbGoTo(nRecED2))

nOrdED2:=ED2->(IndexOrd())
ED2->(dbSetOrder(7))
ED2->(dbSeek(cFilED2+cDi+cItem))
Do While !ED2->(EOF()) .and. ED2->ED2_FILIAL==cFilED2 .and. ED2->ED2_DI_NUM==cDi .and.;
ED2->ED2_ITEM==cItem
   If ED2->ED2_INVOIC==cInv .and. ED2->ED2_PO_NUM==cPo .and. ED2->ED2_POSICA==cPosica .and.;
   ED2->ED2_PGI_NU==cPgi .and. cPd<>ED2->ED2_PD
      WorkDet->(RecLock("WorkDet",.T.))
      WorkDet->AC     := ED2->ED2_AC
      WorkDet->PD     := ED2->ED2_PD
      WorkDet->PROD   := ED2->ED2_PROD
      WorkDet->RE     := ED2->ED2_RE
      WorkDet->ITEM   := ED2->ED2_ITEM
      WorkDet->DI     := ED2->ED2_DI_NUM
      WorkDet->ADICAO := ED2->ED2_ADICAO
      WorkDet->QT_COMP:= ED2->ED2_QTDNCM
      WorkDet->QT_ESTO:= ED2->ED2_QTD
      WorkDet->PESO   := ED2->ED2_PESO
      WorkDet->VALEMB := ED2->ED2_VALEMB
      WorkDet->FRETE  := ED2->ED2_FRETE
      WorkDet->SEGURO := ED2->ED2_SEGURO
      WorkDet->TRB_ALI_WT:= "ED2"
      WorkDet->TRB_REC_WT:= ED2->(Recno())
      WorkDet->(msUnlock())
   EndIf
   ED2->(dbSkip())
EndDo
ED2->(dbSetOrder(nOrdED2))

WorkDet->(dbGoTop())

//If lDiExt - NOPADO POR AOM - 04/11/10
   ED8->( dbSetOrder(4) )
//EndIf

If lMultiFil
   cFilAux := Left(WorkED2->ED2_FILORI,2)
Else
   cFilAux := cFilSW8
EndIf
If SW8->(dbSeek(cFilAux+WorkED2->ED2_HAWB+WorkED2->ED2_INVOIC+WorkED2->ED2_PO_NUM+WorkED2->ED2_POSICA+WorkED2->ED2_PGI_NU))
   If SW8->W8_ISENTOT=="N"
      nSaldo := SW8->W8_SALISEN - nUsado
   ElseIf SW8->W8_ISENTOT=="S"
      nSaldo := 0
   Else
      nSaldo := SW8->W8_QTDE - nUsado
   EndIf
ElseIf ED8->( dbSeek(cFilED8+WorkED2->(ED2_DI_NUM+ED2_ADICAO+ED2_POSICA)) )
   If ED8->ED8_ISETOT=="N"
      nSaldo := ED8->ED8_SALISE - nUsado
   ElseIf ED8->ED8_ISETOT=="S"
      nSaldo := 0
   Else
      nSaldo := ED8->ED8_QTD - nUsado
   EndIf
EndIf

DEFINE MSDIALOG oDlgDet TITLE STR0282 FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO ; //"Utilização do Item"
oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

   @ 00,00 MsPanel oPanelDet Prompt "" Size 60,53 of oDlgDet

   @04,02 SAY   AVSX3("ED2_HAWB",5) of oPanelDet   Pixel
   @03,35 MSGET cHawb PICT AVSX3("ED2_HAWB",6)     When .f. Size 60,8  of oPanelDet Pixel
   @04,200 SAY   AVSX3("ED2_POSICA",5) of oPanelDet Pixel
   @03,233 MSGET cPosica PICT AVSX3("ED2_POSICA",6) When .f. SIZE 60,8  of oPanelDet Pixel
   If lMultiFil
      @04,302 SAY   AVSX3("ED2_FILORI",5) of oPanelDet   Pixel
      @03,335 MSGET cFilOri PICT AVSX3("ED2_FILORI",6)     When .f. Size 60,8  of oPanelDet Pixel
   EndIf

   @22,02 SAY   AVSX3("ED2_INVOIC",5) of oPanelDet Pixel
   @21,35 MSGET cInv PICT AVSX3("ED2_INVOIC",6)    When .F. SIZE 60,8  of oPanelDet Pixel
   @22,200 SAY   AVSX3("ED2_PGI_NU",5) of oPanelDet Pixel
   @21,233 MSGET cPgi PICT AVSX3("ED2_PGI_NU",6)    When .F. SIZE 60,8  of oPanelDet Pixel

   @40,02 SAY   AVSX3("ED2_PO_NUM",5) of oPanelDet Pixel
   @39,35 MSGET cPo PICT AVSX3("ED2_PO_NUM",6)     When .F. SIZE 60,8  of oPanelDet Pixel
   @40,200 SAY   AVSX3("W8_SALISEN",5) of oPanelDet Pixel
   @39,233 MSGET nSaldo PICT AVSX3("W8_SALISEN",6)  When .F. SIZE 60,8  of oPanelDet Pixel

   nLinha  := (oDlgDet:nClientHeight-6)/2
   oMarkDet:= MsSelect():New("WorkDet",,,aDetCpos,@lInverte,@cMarca,{60,1,nLinha,(oDlgDet:nClientWidth-4)/2})

   oPanelDet:Align := CONTROL_ALIGN_TOP
   oMarkDet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT // BCO - Alteração das propriedades de alinhamento de Tela para antes do INIT - 02/01/12

ACTIVATE MSDIALOG oDlgDet ON INIT (EnchoiceBar(oDlgDet,{|| oDlgDet:End()},{|| oDlgDet:End()}))

Return .T.

*----------------------------------------------------------------------------------------------*
Static Function AcValPeDi(cItemPe,dDtDi,cREPe,cProdPe,cDiPesq,cOrd)
*----------------------------------------------------------------------------------------------*
Local lRet := .T.

If Left(cOrd,1)=="1"
   If Empty(cREPe)
      Help(" ",1,"AVG0005281") //"Chave de pesquisa incorreta."
      lRet:= .F.
   EndIf
ElseIf Left(cOrd,1)=="2"
   If Empty(cDiPesq)
      Help(" ",1,"AVG0005281") //"Chave de pesquisa incorreta."
      lRet:= .F.
   EndIf
Else
   If Empty(cItemPe)
      Help(" ",1,"AVG0005281") //"Chave de pesquisa incorreta."
      lRet:= .F.
   EndIf
EndIf

Return lRet

*------------------------------------------------------------------------------------------------*
Static Function ACVinc()
*------------------------------------------------------------------------------------------------*
Local cProdAp:=Space(Len(ED2->ED2_PROD)), cSeqProd:=Space(Len(ED2->ED2_SEQ)), nOpc:=0, oDlg

//AAF 07/04/05 - Verifica se não é EoF.
If WorkED2->( EoF() )
   Return .F.
ElseIf Empty(WorkED2->ED2_PROD) .and. Empty(WorkED2->ED2_SEQ)
   DEFINE MSDIALOG oDlg TITLE STR0413 FROM 15,03 To 25,44 OF oMainWnd //"Vinculação a Produto"

      @01,02 SAY   AVSX3("ED1_PROD",5) of oDlg  //Produto
      If lAbriuExp // F4 para produtos a exportar
         SETKEY(VK_F4,{||EDCAC400HLP(@cProdAp)})
         @01,08 MSGET cProdAp  PICT AVSX3("ED1_PROD",6) Valid (Empty(cProdAp) .or. ExistCpo("SB1EXP",cProdAp)) SIZE 60,8
         @01,15.5 SAY STR0170 of oDlg //"(F4-Pesquisa)"
      Else
         @01,08 MSGET cProdAp PICT AVSX3("ED1_PROD",6) F3 "SB1" Valid (Empty(cProdAp) .or. ExistCpo("SB1", cProdAp)) SIZE 60,8
      Endif
      @02,02 SAY   AVSX3("ED1_SEQ",5) of oDlg //"Seq."
      @02,08 MSGET cSeqProd PICT AVSX3("ED1_SEQ",6) SIZE 60,8

      DEFINE SBUTTON FROM 60,50  TYPE 1 ACTION(If(ValACVinc(cProdAp,cSeqProd),Eval({||nOpc:=1,oDlg:End()}),)) ENABLE OF oDlg
      DEFINE SBUTTON FROM 60,90 TYPE 2 ACTION(nOpc:=0,oDlg:End()) ENABLE OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED

   If nOpc = 1
      If lAbriuEDC
         AC400EDCGrv(ESTORNAR,WorkED2->ED2_ITEM,Space(Len(WorkED1->ED1_RE)),WorkED2->ED2_PROD,WorkED2->ED2_QTD,0)
      EndIf

      WorkED2->ED2_PROD := cProdAp
      WorkED2->ED2_SEQ  := cSeqProd
      WorkED2->ED2_DESCPD:= Posicione("SB1", 1, xFilial("SB1") + cProdAp, "B1_DESC")

      /* Se o insumo for inserido manualmente na estrutura do ato consessório, assumir a quantidade informada como quantidade original (estrutura).
         A WorkED1 estará posicionada pela validação ValACVinc(). Enviar na gravação da tabela EDC a quantidade a exportar do produto. */
      If WorkED2->ED2_QTDORI == 0
         WorkED2->ED2_QTDORI:= WorkED2->ED2_QTD
      EndIf
      If lAbriuEDC
         //AC400EDCGrv(INCLUIR,WorkED2->ED2_ITEM,Space(Len(WorkED1->ED1_RE)),cProdAp,WorkED2->ED2_QTD,0,WorkED2->ED2_MARCA)
         AC400EDCGrv(INCLUIR, WorkED2->ED2_ITEM, WorkED1->ED1_RE, cProdAp, WorkED2->ED2_QTD, WorkED2->ED2_QTDORI, WorkED2->ED2_MARCA, WorkED1->ED1_QTD)
      EndIf
   EndIf
Else
   MsgInfo(STR0294) //"Item já vinculado a um produto de exportação."
EndIf

Return .T.

*------------------------------------------------------------------------------------------------------------*
Static Function ValACVinc(cProdAp,cSeqProd)
*------------------------------------------------------------------------------------------------------------*
Local lRet:=.T.
Local ni         := 0   ,;
      aMsg       := {}  ,;
      aMsgAux    := {}  ,;
      aMarcaED2  := {}  ,;
      aJaCompEst := {}  ,;
      cChave     := ""  ,;
      lFirst     := .T.

WorkED1->(dbSetOrder(1))

If !WorkED1->(dbSeek(ED0->ED0_PD+ED0->ED0_AC+cProdAp+cSeqProd)) .and.;
!WorkED1->(dbSeek(Space(Len(ED0->ED0_PD+ED0->ED0_AC))+cProdAp+cSeqProd))
   MsgInfo(STR0295)  //"Produto e sequência não encontrado"
   lRet := .F.
EndIf

// **  PLB 09/11/06 - Validação das estruturas dos Itens Alternativos
If lRet  .And.  lTipoItem
   lFirst := .T.
   ED7->( DBSetOrder(2) )
   If !Empty(M->ED0_PD)  .And.  ED7->( DBSeek(xFilial("ED7")+"E"+cProdAp+M->ED0_PD) )
      cChave := ED7->( ED7_FILIAL+ED7_DE+ED7_PD )
      Do While !ED7->( EoF() )  .And.  ED7->( ED7_FILIAL+ED7_DE+ED7_PD ) == cChave
         AADD(aJaCompEst,ED7->ED7_PARA)
         // Marca item atual como vinculado para fazer a comparacao
         If !Empty(M->ED0_PD)
            If lFirst
               cProdED2 := WorkED2->ED2_PROD
               cSeqED2  := WorkED2->ED2_SEQ
               nRecED2  := WorkED2->( RecNo() )
               nOrdED2  := WorkED2->( IndexOrd() )
               WorkED2->ED2_PROD := cProdAp
               WorkED2->ED2_SEQ  := cSeqProd
               WorkED2->( DBSetOrder(2) )
               WorkED2->( DBSeek(cProdAp+cSeqProd) )
               Do While !WorkED2->( EoF() )  .And.  WorkED2->( ED2_PROD+ED2_SEQ ) == cProdAp+cSeqProd
                  If WorkED2->ED2_MARCA != cMarca
                     AAdd(aMarcaED2,{WorkED2->( RecNo() ),WorkED2->ED2_MARCA})
                     WorkED2->ED2_MARCA := cMarca
                  EndIf
                  WorkED2->( DBSkip() )
               EndDo
            EndIf
            Processa({|| ( aMsgAux := AvCompEstr(cProdAp,ED7->ED7_PARA,M->ED0_PD,.F.,.F.,"PEDIDO",lFirst) ) },AC401STR(023))  //"Comparando Estruturas..."
            If lFirst
               For ni := 1  to  Len(aMarcaED2)
                  WorkED2->( DBGoTo(aMarcaED2[ni][1]) )
                  WorkED2->ED2_MARCA := aMarcaED2[ni][2]
               Next ni
               WorkED2->( DBSetOrder(nOrdED2) )
               WorkED2->( DBGoTo(nRecED2) )
               WorkED2->ED2_PROD := cProdED2
               WorkED2->ED2_SEQ  := cSeqED2
            EndIf
         Else
            Processa({|| ( aMsgAux := AvCompEstr(cProdAp,ED7->ED7_PARA,Space(Len(M->ED0_PD)),.F.,.F.,"PEDIDO",lFirst) ) },AC401STR(023))  //"Comparando Estruturas..."
         EndIf

         For ni := 1  to  Len(aMsgAux)
            AAdd(aMsg,aMsgAux[ni])
            lFirst := .F.
         Next ni
         aMsgAux := {}
         ED7->( DBSkip() )
      EndDo
   EndIf
   If ED7->( DBSeek(xFilial("ED7")+"E"+cProdAp+Space(Len(M->ED0_PD)))  )
      cChave := ED7->( ED7_FILIAL+ED7_DE+ED7_PD )
      Do While !ED7->( EoF() )  .And.  ED7->( ED7_FILIAL+ED7_DE+ED7_PD ) == cChave
         If AScan(aJaCompEst,{ |x| x == ED7->ED7_PARA }) == 0
            Processa({|| ( aMsgAux := AvCompEstr(cProdAp,ED7->ED7_PARA,,.F.,.F.,"PEDIDO") ) },AC401STR(023))  //"Comparando Estruturas..."
            For ni := 1  to  Len(aMsgAux)
               AAdd(aMsg,aMsgAux[ni])
            Next ni
            aMsgAux := {}
         EndIf
         ED7->( DBSkip() )
      EndDo
   EndIf
   If Len(aMsg) > 0
      AAdd(aMsg,NIL)
      AIns(aMsg,1)
      aMsg[1] := {AC401STR(026),.T.}  //"Este Item Importado não é compatível com a Estrutura do Produto Alternativo ou a Estrutura do Produto principal diverge do Pedido."

      EECView(aMsg,STR0262)  //"Atenção"

      lRet := MsgYesNo(AC401STR(025))  //"Deseja continuar com a operação?"
   EndIf
EndIf
// **

Return lRet

*------------------------------------------------------------------------------------------------------------*
Static Function ED2Quebrado(nQtdAux,nQtdNcmAux,nValEmbAux,nPesoAux,nQtdCalAux,nValCalAux)
*------------------------------------------------------------------------------------------------------------*
Local nAtuQtd1 := 0, nAtuQtd2 := 0, nAtuVal1 := 0, nAtuVal2 := 0

WorkED4->(RecLock("WorkED4",.F.))
WorkED4->ED4_QTD    := nQtdAux
WorkED4->ED4_VALEMB := nValEmbAux
WorkED4->ED4_PESO   := nPesoAux
nAtuQtd1 := WorkED4->ED4_QTDCAL - WorkED4->ED4_QT_LI
nAtuQtd2 := WorkED4->ED4_QTDCAL - WorkED4->ED4_QT_DI
WorkED4->ED4_QTDCAL := nQtdCalAux
WorkED4->ED4_QT_LI  := nQtdCalAux - nAtuQtd1
WorkED4->ED4_QT_DI  := nQtdCalAux - nAtuQtd2
nAtuQtd1 := WorkED4->ED4_QTDNCM - WorkED4->ED4_SNCMLI
nAtuQtd2 := WorkED4->ED4_QTDNCM - WorkED4->ED4_SNCMDI
WorkED4->ED4_QTDNCM := nQtdNcmAux
WorkED4->ED4_SNCMLI := nQtdNCMAux - nAtuQtd1
WorkED4->ED4_SNCMDI := nQtdNCMAux - nAtuQtd2
nAtuVal1 := WorkED4->ED4_VALCAL - WorkED4->ED4_VL_LI
nAtuVal2 := WorkED4->ED4_VALCAL - WorkED4->ED4_VL_DI
WorkED4->ED4_VALCAL := nValCalAux
WorkED4->ED4_VL_LI  := nValCalAux - nAtuVal1
WorkED4->ED4_VL_DI  := nValCalAux - nAtuVal2
WorkED4->(msUnlock())

Return .T.

/*
Função.....: AC400AltNCM()
Parâmetros.: cTipo = Tipo de saldo a ser alterado (Importação="I"/Exportação="E")
Autor......: Alessandro Alves Ferreira (AAF)
Data/Hora..: 16/12/05 - 16:50
Objetivo...: Fazer a troca da NCM do saldo restante de Importação/Exportação.
*/
***************************
Function AC400AltNCM(cTipo,nOpc)
***************************
Local lOK     := .F.
Local aOrd    := SaveOrd({"WorkED2","WorkED4"})
Local bOK     := {|| lOK := .T.,oDlgNCM:End() }
Local bCancel := {|| lOK := .F.,oDlgNCM:End() }
Local cSeqSis := ""
Private cVelhaNCM
Private cNovaNCM

Begin Sequence

   //Verifica se o Ato já foi Encerrado.
   If !Empty(M->ED0_DT_ENC)
      MsgStop(AC401STR(009))//"Alteração não pode ser realizada pois o Ato Concessório já está encerrado."
      BREAK
   ElseIf M->ED0_TIPOAC == "06"
      MsgStop(AC401STR(010))//"Alteração não pode ser relizada em Ato Concessório com NCM Genérica."
      BREAK
   ElseIf nOpc <> INCLUIR .AND. !Empty(M->ED0_AC) .AND. dDataBase > AC400ApDtValid()
      MsgStop(AC401STR(011))//"Alteração não pode ser relizada pois o Ato Concessório está vencido."
      BREAK
   EndIf

   If cTipo == "I"
      If WorkED4->ED4_QT_LI <= 0
         MsgStop(AC401STR(012))//"Não há saldo de quantidade restante para a troca de NCM"
         BREAK
      ElseIf WorkED4->ED4_VL_LI <= 0
         If !MsgYesNo(AC401STR(013))//"Não há saldo de valor restante para a troca de NCM, deseja continuar?"
            BREAK
         EndIF
      EndIf
   ElseIf cTipo == "E"
      If WorkED3->ED3_SALDO <= 0
         MsgStop(AC401STR(012))//"Não há saldo de quantidade restante para a troca de NCM"
         BREAK
      ElseIf WorkED3->ED3_SAL_CO <= 0
         If !MsgYesNo(AC401STR(013))//"Não há saldo de valor restante para a troca de NCM, deseja continuar?"
            BREAK
         EndIF
      EndIf
   EndIf

   SB1->( dbSetOrder(1) )

   //Busca a NCM Antiga
   If cTipo == "I"
      SB1->( dbSeek(xFilial("SB1")+WorkED4->ED4_ITEM) )
      cVelhaNCM := WorkED4->ED4_NCM
   ElseIf cTipo == "E"
      SB1->( dbSeek(xFilial("SB1")+WorkED3->ED3_PROD) )
      cVelhaNCM := WorkED3->ED3_NCM
   EndIf

   cNovaNCM  := SB1->B1_POSIPI

   DEFINE MSDIALOG oDlgNCM TITLE STR0309 FROM 05,10 TO 20,60 OF oMainWnd //"Alteração de NCM"

      oPanel:= TPanel():New(0,0, "", oDlgNCM,, .T., ,,,0,0,,.T.) //LGS-02/12/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 15,13 SAY AC401STR(014) SIZE 40,8  PIXEL Of oPanel //"NCM Atual"
      @ 15,50 MSGET cVelhaNCM PICTURE AVSX3("ED2_NCM",6) SIZE 65,08 When .F. PIXEL of oPanel

      @ 30,13 SAY AC401STR(015) SIZE 40,8 PIXEL Of oPanel //"Nova NCM"
      @ 30,50 MSGET cNovaNCM PICTURE AVSX3("ED2_NCM",6) SIZE 65,08 F3 AVSX3("ED2_NCM",8) PIXEL of oPanel

   ACTIVATE MSDIALOG oDlgNCM ON INIT EnchoiceBar(oDlgNCM,bOK,bCancel) CENTERED

   //AOM - 11/11/11
   If AvFlags("SEQMI") .And. WorkED4->ED4_IMPORT == "N"
      cSeqSis :=  WorkED4->ED4_SEQMI
   Else
      cSeqSis :=  WorkED4->ED4_SEQSIS
   EndIf

   If lOK .AND. cNovaNCM <> cVelhaNCM .AND. MsgYesNo(AC401STR(016)+TransForm(cVelhaNCM,AVSX3("ED2_NCM",6))+AC401STR(017)+; //"Confirma alteração da NCM "###" para NCM "
                                                     TransForm(cNovaNCM,AVSX3("ED2_NCM",6))+AC401STR(018)+cSeqSis+" ?")//" na Sequencia "

      If cTipo == "I"
         AC400NCMImp()
      ElseIf cTipo == "E"
         AC400NCMExp()
      EndIf

   EndIf

End Sequence

RestOrd(aOrd)

Return .T.

/*
Função.....: AC400PropAtu()
Parâmetros.: cAlias  = Area a ser atualizada.
             nCoefic = Coeficiente da proporção.
             aCampos = Array com os campos numéricos a serem proporcionalizados.
Autor......: Alessandro Alves Ferreira (AAF)
Data/Hora..: 20/12/05 - 11:00
Objetivo...: Proporcionalizar os campos de valores numéricos de acordo com o coeficiente.
*/
***********************************************
Function AC400PropAtu(cAlias, nCoefic, aCampos)
***********************************************
Local nInd

For nInd := 1 To Len(aCampos)
   (cAlias)->&(aCampos[nInd]) := (cAlias)->&(aCampos[nInd]) * nCoefic
Next

Return .T.

/*
Função.....: AC400NCMImp()
Parâmetros.: Nenhum.
Autor......: Alessandro Alves Ferreira (AAF)
Data/Hora..: 22/12/05 - 11:30
Objetivo...: Fazer a troca da NCM de uma linha de saldo de importação.
*/
**********************
Function AC400NCMImp()
**********************
Local nInd
 Local lTemSldLI := .T.
 Local lTemSldDI := .T.

//Verifica se saldo para a Nova NCM.
nRecWkED4 := WorkED4->( RecNo() )
nSldRest  := WorkED4->ED4_QT_LI
nSldRestVl:= WorkED4->ED4_VL_LI
nSldRestIn:= WorkED4->ED4_VL_LI
nVlNovo   := 0
nAbate    := 0

lTemUso := WorkED4->ED4_QT_LI < WorkED4->ED4_QTDCAL //Se Houve utilização.

// ** PLB 07/03/07
If lTemUso
   nOldCoef  := WorkED4->( ( ED4_QTDCAL - ED4_QT_LI ) / ( ED4_QTDNCM - ED4_SNCMLI ) )
   nNewCoef  := WorkED4->( ED4_QT_LI / ED4_SNCMLI )
   lTemSldLI := WorkED4->ED4_VL_LI > 0
   lTemSldDI := WorkED4->ED4_VL_DI > 0
EndIf
nSldTot := WorkED4->ED4_QT_LI
// **

WorkED2->( dbSetOrder(8) ) //ED2_NCM+ED2_ITEM+ED2_CAMB+STR(ED2_PERCPE,5,2)+ED2_UMNCM
WorkED2->( dbSeek( WorkED4->(ED4_NCM+ED4_ITEM+ED4_CAMB+ IF(lQuebraPerc .AND. ED0->ED0_PERCPE == "2","",STR(ED4_PERCPE,5,2)) ) )) //NCF - 11/04/2011 - Permitir a alteração de Ncm quando utilizar agrupamento de insumos de diferentes percentuais de perda
Do While !WorkED2->( EoF() ) .AND. WorkED2->(ED2_NCM+ED2_ITEM+ED2_CAMB+  IF(lQuebraPerc .AND. ED0->ED0_PERCPE == "2","",STR(ED2_PERCPE,5,2))  ) ==;
                                   WorkED4->(ED4_NCM+ED4_ITEM+ED4_CAMB+  IF(lQuebraPerc .AND. ED0->ED0_PERCPE == "2","",STR(ED4_PERCPE,5,2))  ) .AND. nSldRest > 0

   If If( Empty(WorkED2->ED2_UMANEX), WorkED2->ED2_UMNCM, WorkED2->ED2_UMANEX) == WorkED4->ED4_UMNCM
      nSldRest  -= WorkED2->ED2_QTDCAL
      nSldRestVL-= WorkED2->ED2_VALCAL//WorkED2->ED2_VALEMB

      If !lTemUso .AND. (M->ED0_MODAL == ISENCAO .OR. Empty(M->ED0_DT_ENV))//Troca todos os itens para a Nova NCM e mantém a mesma linha de saldo.

         //AOM - 11/11/11
         If AvFlags("SEQMI") .And. WorkED4->ED4_IMPORT == "N"
            cSeqSisco := WorkED4->ED4_SEQMI
         Else
            cSeqSisco := WorkED4->ED4_SEQSIS
         EndIf
         WorkED4Atu("WorkED2",ESTORNAR,,,M->ED0_MODAL == ISENCAO)

         RecLock("WorkED2",.F.)
         WorkED2->ED2_NCM    := cNovaNCM
         WorkED2->ED2_NCMANT := cVelhaNCM
         WorkED2->( MsUnLock() )

         WorkED4Atu("WorkED2",INCLUIR ,,,M->ED0_MODAL == ISENCAO)
         RecLock("WorkED4",.F.)
         //AOM - 11/11/11
         If AvFlags("SEQMI") .And. WorkED4->ED4_IMPORT == "N"
            WorkED4->ED4_SEQSIS := cSeqSisco
         Else
            WorkED4->ED4_SEQSIS := cSeqSisco
         EndIf

         WorkED4->ED4_NCMANT := cVelhaNCM
         WorkED4->( MsUnLock() )

      ElseIf nSldRest >= 0 //Troca o item para a Nova NCM caso haja saldo restante.
         WorkED4Atu("WorkED2",ESTORNAR,,,M->ED0_MODAL == ISENCAO,,,lTemSldLI,lTemSldDI)

         nCoefAlt := WorkED2->( ED2_QTD / ED2_QTDNCM ) / nNewCoef

         If nSldRestVl < 0
            RecLock("WorkED2",.F.)
            nVlNovo -= nSldRestVl
            //WorkED2->ED2_VALEMB += nSldRestVl
            //WorkED2->ED2_VL_MOE := WorkED2->ED2_VALEMB / (WorkED2->ED2_VALEMB - nSldRestVl)

            // ** PLB 13/03/07
            nOldValEmb := WorkED2->ED2_VALEMB
            //If nSldRestIn < 0
            //   WorkED2->ED2_VALEMB := 0
            //Else
            //   WorkED2->ED2_VALEMB := nSldRestIn * WorkED2->ED2_QTDCAL / nSldTot
            //EndIf
            // **

            //If WorkED2->ED2_VALEMB == 0
            //   WorkED2->ED2_VALEMB := 0.01
            //   WorkED2->ED2_VL_MOE := 0.01
            //   nAbate += 0.01
            //EndIf

            If M->ED0_MODAL == ISENCAO
               WorkED2->ED2_VALEMB := WorkED2->ED2_VALEMB * nCoefAlt
            EndIf
            WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB * (WorkED2->ED2_QTDCAL / WorkED2->ED2_QTD)
            WorkED2->ED2_VL_MOE := WorkED2->ED2_VL_MOE * ( WorkED2->ED2_VALEMB / nOldValEmb )
            //WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTDCAL

            nSldRestVl := 0
            WorkED2->( MsUnLock() )
         EndIf

         RecLock("WorkED2",.F.)
         WorkED2->ED2_NCM    := cNovaNCM
         WorkED2->ED2_NCMANT := cVelhaNCM
         // ** PLB 07/03/07
         If lED2Coef
            WorkED2->ED2_COEFEC := nNewCoef
         Else
            WorkED2->ED2_COEF := nNewCoef
         EndIf
         WorkED2->ED2_QTDNCM := WorkED2->ED2_QTDCAL / nNewCoef
         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_QTDORI := WorkED2->ED2_QTDORI * nCoefAlt
            WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTDNCM
         ElseIf M->ED0_MODAL == SUSPENSAO
            WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTD
         EndIf
         If AvVldUn( WorkED2->ED2_UMNCM ) // MPG - 14/02/2018
            WorkED2->ED2_PESO := WorkED2->ED2_QTDNCM
         EndIf
         // **
         WorkED2->( MsUnLock() )

         cED4Ane := WorkED4->ED4_ANEXO

         WorkED4Atu("WorkED2",INCLUIR ,,,M->ED0_MODAL == ISENCAO,,,lTemSldLI,lTemSldDI)

         If WorkED4->ED4_RECNO == 0
            RecLock("WorkED4",.F.)
            WorkED4->ED4_NCMANT := cVelhaNCM
            WorkED4->ED4_ANEXO  := cED4Ane
            WorkED4->( MsUnLock() )
         EndIf

      Else

         WorkED4Atu("WorkED2",ESTORNAR,,,M->ED0_MODAL == ISENCAO,,.F.,lTemSldLI,lTemSldDI)  // PLB 07/03/07

         aCposAux := {}

         For nInd := 1 To WorkED2->( FCount() )
            aAdd(aCposAux,WorkED2->( FieldGet(nInd) ))
         Next nInd

         //Proporção da quantidade restante ao total do item.
         nCoefAlt := - nSldRest / WorkED2->ED2_QTDCAL

         //Campos a Serem proporcionalizados.
         aAtuCampos := {"ED2_QTD"   ,"ED2_QTDCAL","ED2_QTDNCM",;
                        /*"ED2_COEF",*/"ED2_VALCAL","ED2_VALORI",;
                        "ED2_VL_MOE","ED2_PESO"  ,"ED2_FRETE" ,;
                        "ED2_FR_USS","ED2_SEGURO","ED2_SE_USS",;
                        "ED2_QTDORI"}

         If M->ED0_MODAL == ISENCAO
            AAdd(aAtuCampos,"ED2_COEF")
         EndIf

         //Ponto de Entrada para gravação de campos customizados.
         If EasyEntryPoint("EDCAC400")
            ExecBlock("EDCAC400",.F.,.F.,"ALTERA_SLD_NCM_IMP")
         EndIf

         //Grava o resto com a NCM Antiga.
         RecLock("WorkED2",.F.)

         AC400PropAtu("WorkED2",nCoefAlt,aAtuCampos)
         //WorkED2->ED2_VALEMB := (nVlNovo -nSldRestVl)/((100-WorkED2->ED2_PERCPE+WorkED2->ED2_PERCAP)/100)//nVlNovo -nSldRestVl
         // ** PLB 13/03/07
         //WorkED2->ED2_VALEMB := ( IIF(nSldRestIn < 0, nSldRestIn, 0) + nVlNovo - nSldRestVl ) / ((100-WorkED2->ED2_PERCPE+WorkED2->ED2_PERCAP)/100)
         // **
         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_VALEMB := WorkED2->( ED2_VALEMB * ( ED2_QTD / ED2_QTDNCM ) / nOldCoef * nCoefAlt )
         ElseIf M->ED0_MODAL == SUSPENSAO
            WorkED2->ED2_VALEMB *= nCoefAlt
         EndIf
         WorkED2->ED2_VL_MOE := WorkED2->ED2_VL_MOE * (WorkED2->ED2_VALEMB / aCposAux[WorkED2->( FieldPos("ED2_VALEMB") )])
         WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB * (WorkED2->ED2_QTDCAL / WorkED2->ED2_QTD)
         //WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTDCAL
         // ** PLB 07/03/07
         If lED2Coef
            WorkED2->ED2_COEFEC := nOldCoef
         Else
            WorkED2->ED2_COEF := nOldCoef
         EndIf
         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_QTDORI := WorkED2->( ED2_QTDORI * ( ED2_QTD / ED2_QTDNCM ) ) / nOldCoef
         EndIf
         WorkED2->ED2_QTDNCM := WorkED2->ED2_QTDCAL / nOldCoef
         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTDNCM
         ElseIf M->ED0_MODAL == SUSPENSAO
            WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTD
         EndIf
         If AvVldUn( WorkED2->ED2_UMNCM ) // MPG - 14/02/2018
            WorkED2->ED2_PESO := WorkED2->ED2_QTDNCM
         EndIf
         // **
         WorkED2->( MsUnLock() )

         WorkED4Atu("WorkED2",INCLUIR ,,,M->ED0_MODAL == ISENCAO,,,lTemSldLI,lTemSldDI)  // PLB 07/03/07
/*
         // ** Atualiza os Saldos do ED4 para NCM Antiga.
         WorkED4->( dbGoTo(nRecWkED4) )

         nReduzQtd  := aCposAux[WorkED2->( FieldPos("ED2_QTDCAL") )] - WorkED2->ED2_QTDCAL
         nReduzVl   := aCposAux[WorkED2->( FieldPos("ED2_VALEMB") )] - WorkED2->ED2_VALEMB
         nReduzVlCal:= aCposAux[WorkED2->( FieldPos("ED2_VALCAL") )] - WorkED2->ED2_VALCAL
         nReduzNCM  := (aCposAux[WorkED2->( FieldPos("ED2_QTDNCM") )] - WorkED2->ED2_QTDNCM)*(100-WorkED2->ED2_PERCPE+WorkED2->ED2_PERCAP)/100//aCposAux[WorkED2->( FieldPos("ED2_QTDNCM") )] - WorkED2->ED2_QTDNCM

         nCoefED4  := 1 - (aCposAux[WorkED2->( FieldPos("ED2_QTDCAL") )] - WorkED2->ED2_QTDCAL) / WorkED4->ED4_QTDCAL

         aAtuED4 := {"ED4_QTD","ED4_QTDCAL","ED4_QTDNCM","ED4_PESO"  }

         RecLock("WorkED4",.F.)
         AC400PropAtu("WorkED4",nCoefED4,aAtuED4)

         WorkED4->ED4_QT_LI  -= nReduzQtd
         WorkED4->ED4_QT_DI  -= nReduzQtd
         WorkED4->ED4_SNCMLI -= nReduzNCM
         WorkED4->ED4_SNCMDI -= nReduzNCM
         WorkED4->ED4_VL_LI  -= nReduzVlCal
         WorkED4->ED4_VL_DI  -= nReduzVlCal
         WorkED4->ED4_VALEMB -= nReduzVl
         WorkED4->ED4_VALCAL := WorkED4->ED4_VALEMB * (WorkED4->ED4_QTDCAL / WorkED4->ED4_QTD)
         WorkED4->ED4_NCMANT := cVelhaNCM

         WorkED4->( MsUnLock() )
         // **
*/
         // ** Proporcionaliza o restante com Nova NCM.
         nCoefAlt := 1 - nCoefAlt

         RecLock("WorkED2",.T.)
         For nInd := 1 To Len(aCposAux)
            WorkED2->&( FieldName(nInd) ) := aCposAux[nInd]
         Next nInd

         WorkED2->ED2_NCM    := cNovaNCM
         WorkED2->ED2_NCMANT := cVelhaNCM
         AC400PropAtu("WorkED2",nCoefAlt,aAtuCampos)

         //WorkED2->ED2_VALEMB += nSldRestVl/((100-WorkED2->ED2_PERCPE+WorkED2->ED2_PERCAP)/100)//nSldRestVl
         //WorkED2->ED2_VL_MOE := WorkED2->ED2_VL_MOE * WorkED2->ED2_VALEMB / (WorkED2->ED2_VALEMB - nSldRestVl)

         // ** PLB 13/03/07
         nOldValEmb := WorkED2->ED2_VALEMB
         //If nSldRestIn < 0
         //   WorkED2->ED2_VALEMB := 0
         //Else
         //   WorkED2->ED2_VALEMB := ( nSldRestIn * WorkED2->ED2_QTDCAL / nSldTot ) / ((100-WorkED2->ED2_PERCPE+WorkED2->ED2_PERCAP)/100)
         //EndIf

         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_VALEMB := WorkED2->( ED2_VALEMB * ( ED2_QTD / ED2_QTDNCM ) / nNewCoef * nCoefAlt )
         ElseIf M->ED0_MODAL == SUSPENSAO
            WorkED2->ED2_VALEMB *= nCoefAlt
         EndIf
         WorkED2->ED2_VL_MOE := WorkED2->ED2_VL_MOE * ( WorkED2->ED2_VALEMB / nOldValEmb )
         // **

         //If WorkED2->ED2_VALEMB == 0
         //   WorkED2->ED2_VALEMB := 0.01
         //   WorkED2->ED2_VL_MOE := 0.01
         //   nAbate += 0.01
         //EndIf
         WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB * (WorkED2->ED2_QTDCAL / WorkED2->ED2_QTD)
         WorkED2->ED2_RECNO  := 0
         //WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTDCAL
         WorkED2->TRB_ALI_WT := "ED2"
         WorkED2->TRB_REC_WT := 0
         // ** PLB 07/03/07
         If lED2Coef
            WorkED2->ED2_COEFEC := nNewCoef
         Else
            WorkED2->ED2_COEF := nNewCoef
         EndIf
         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_QTDORI := WorkED2->( ED2_QTDORI * ( ED2_QTD / ED2_QTDNCM ) ) / nNewCoef
         EndIf
         WorkED2->ED2_QTDNCM := WorkED2->ED2_QTDCAL / nNewCoef
         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTDNCM
         ElseIf M->ED0_MODAL == SUSPENSAO
            WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTD
         EndIf
         If AvVldUn( WorkED2->ED2_UMNCM ) // MPG - 14/02/2018
            WorkED2->ED2_PESO := WorkED2->ED2_QTDNCM
         EndIf
         // **

         WorkED2->( MsUnLock() )

         cED4Ane := WorkED4->ED4_ANEXO

         WorkED4Atu("WorkED2",INCLUIR,,,M->ED0_MODAL == ISENCAO,,,lTemSldLI,lTemSldDI)
         // **

         If WorkED4->ED4_RECNO == 0
            RecLock("WorkED4",.F.)
            WorkED4->ED4_NCMANT := cVelhaNCM
            WorkED4->ED4_ANEXO  := cED4Ane
            WorkED4->( MsUnLock() )
         EndIf

      EndIf

      WorkED4->( dbGoTo(nRecWkED4) )                         //NCF - 11/04/2011 - Permitir a alteração de Ncm quando utilizar agrupamento de insumos de diferentes percentuais de perda
      WorkED2->( dbSeek( WorkED4->(ED4_NCM+ED4_ITEM+ED4_CAMB+IF(lQuebraPerc .AND. ED0->ED0_PERCPE == "2","",STR(ED4_PERCPE,5,2))) ))
   Else
      WorkED2->( dbSkip() )
   EndIf
EndDo

// ** PLB 22/05/07 - Proporcionaliza todos os itens que foram mantidos na NCM antiga
If lTemUso
   WorkED4->( dbGoTo(nRecWkED4) )
   WorkED2->( dbSeek( WorkED4->(ED4_NCM+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2)) ))//NCF - 11/04/2011 - Permitir a alteração de Ncm quando utilizar agrupamento de insumos de diferentes percentuais de perda
   Do While !WorkED2->( EoF() ) .AND. WorkED2->(ED2_NCM+ED2_ITEM+ED2_CAMB+IF(lQuebraPerc .AND. ED0->ED0_PERCPE == "2","",STR(ED2_PERCPE,5,2))) ==;
                                      WorkED4->(ED4_NCM+ED4_ITEM+ED4_CAMB+IF(lQuebraPerc .AND. ED0->ED0_PERCPE == "2","",STR(ED4_PERCPE,5,2))) .And. nSldRest <= 0

      If If( Empty(WorkED2->ED2_UMANEX), WorkED2->ED2_UMNCM, WorkED2->ED2_UMANEX) == WorkED4->ED4_UMNCM  ;
         .And.  !(IIF(lED2Coef,WorkED2->ED2_COEFEC,WorkED2->ED2_COEF) == nOldCoef)
         WorkED4Atu("WorkED2",ESTORNAR,,,M->ED0_MODAL == ISENCAO,,.F.,lTemSldLI,lTemSldDI)
         RecLock("WorkED2",.F.)
         nCoefAlt := WorkED2->( ED2_QTDCAL / ED2_QTDNCM ) / nOldCoef
         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_VALEMB := WorkED2->ED2_VALEMB * nCoefAlt
            WorkED2->ED2_VL_MOE := WorkED2->ED2_VL_MOE * nCoefAlt
         EndIf
         WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB * (WorkED2->ED2_QTDCAL / WorkED2->ED2_QTD)
         If lED2Coef
            WorkED2->ED2_COEFEC := nOldCoef
         Else
            WorkED2->ED2_COEF := nOldCoef
         EndIf
         WorkED2->ED2_QTDNCM := WorkED2->ED2_QTDCAL / nOldCoef
         If M->ED0_MODAL == ISENCAO
            WorkED2->ED2_QTDORI := WorkED2->ED2_QTDORI * nCoefAlt
            WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTDNCM
         ElseIf M->ED0_MODAL == SUSPENSAO
            WorkED2->ED2_PRCUNI := WorkED2->ED2_VALCAL / WorkED2->ED2_QTD
         EndIf
         If AvVldUn( WorkED2->ED2_UMNCM ) // MPG - 14/02/2018
            WorkED2->ED2_PESO := WorkED2->ED2_QTDNCM
         EndIf
         WorkED2->( MsUnLock() )
         WorkED4Atu("WorkED2",INCLUIR,,,M->ED0_MODAL == ISENCAO,,,lTemSldLI,lTemSldDI)
      EndIf
      WorkED2->( dbSkip() )
   EndDo
EndIf

/*
If nAbate > 0
   lAbate := .F.
   WorkED2->( dbSeek( WorkED4->(cNovaNcm+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2)) ))
   Do While !WorkED2->( EoF() ) .AND. WorkED2->(ED2_NCM+ED2_ITEM+ED2_CAMB+STR(ED2_PERCPE,5,2)) ==;
                                      WorkED4->(cNovaNCM+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2))
      If If( Empty(WorkED2->ED2_UMANEX), WorkED2->ED2_UMNCM, WorkED2->ED2_UMANEX) == WorkED4->ED4_UMNCM .AND.;
         WorkED2->ED2_VALEMB > nAbate

         lAbate := .T.
         EXIT
      EndIf

      WorkED2->( dbSkip() )
   EndDo

   // ** PLB 13/03/07 - Caso não encontre saldo, abate da NCM antiga
   If !lAbate
      WorkED2->( dbSeek( WorkED4->(cVelhaNcm+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2)) ))
      Do While !WorkED2->( EoF() ) .AND. WorkED2->(ED2_NCM+ED2_ITEM+ED2_CAMB+STR(ED2_PERCPE,5,2)) ==;
                                         WorkED4->(cVelhaNCM+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2))
         If If( Empty(WorkED2->ED2_UMANEX), WorkED2->ED2_UMNCM, WorkED2->ED2_UMANEX) == WorkED4->ED4_UMNCM .AND.;
            WorkED2->ED2_VALEMB > nAbate

            lAbate := .T.
            EXIT
         EndIf

         WorkED2->( dbSkip() )
      EndDo
   EndIf
   // **

   If lAbate
      RecLock("WorkED2",.F.)
      WorkED2->ED2_VALEMB -= nAbate
      WorkED2->ED2_VL_MOE := WorkED2->ED2_VALEMB / (WorkED2->ED2_VALEMB + nAbate)
      WorkED2->ED2_VALCAL := WorkED2->ED2_VALEMB * (WorkED2->ED2_QTDCAL / WorkED2->ED2_QTD)
      WorkED2->( MsUnLock() )

      WorkED4->( dbSetOrder(1) )
      WorkED4->( dbSeek(WorkED2->( ED2_NCM+ED2_ITEM+ED2_CAMB+STR(ED2_PERCPE,5,2)+ED2_UMNCM )) )

      RecLock("WorkED4",.F.)
      WorkED4->ED4_VALEMB -= nAbate
      WorkED4->ED4_VALCAL := WorkED4->ED4_VALEMB * (WorkED4->ED4_QTDCAL / WorkED4->ED4_QTD)
      WorkED4->ED4_VL_DI  -= nAbate
      WorkED4->ED4_VL_LI  -= nAbate
      WorkED4->( MsUnLock() )
   EndIf

EndIf
*/

// ** PLB 22/05/07 - Faz tratamento para Saldos de Valores negativos
If lTemUso
   nSaldoLI := 0
   nSaldoDI := 0
   WorkED4->( DBGoTo(nRecWkED4) )
   RecLock("WorkED4",.F.)
   If lTemSldLI
      nSaldoLI := WorkED4->ED4_VL_LI
      WorkED4->ED4_VL_LI := 0
   EndIf
   If lTemSldDI
      If WorkED4->ED4_QT_DI <= 0
         nSaldoDI := WorkED4->ED4_VL_DI
         WorkED4->ED4_VL_DI := 0
      EndIf
   EndIf
   WorkED4->( MSUnLock() )

   WorkED4->( DBSetOrder(1) )
   If WorkED4->( DBSeek( cNovaNCM+ED4_ITEM+ED4_CAMB+STR(ED4_PERCPE,5,2)+ED4_UMNCM ) )
      RecLock("WorkED4",.F.)
      If lTemSldLI
         WorkED4->ED4_VL_LI += nSaldoLI
      Else
         WorkED4->ED4_VL_LI := 0
      EndIf
      If lTemSldDI
         WorkED4->ED4_VL_DI += nSaldoDI
      Else
         WorkED4->ED4_VL_DI := 0
      EndIf
      WorkED4->( MSUnLock() )
   EndIf
EndIf
// **

WorkED4->( DBGoTo(nRecWkED4) )

Return .T.

/*
Função.....: AC400NCMExp()
Parâmetros.: Nenhum.
Autor......: Alessandro Alves Ferreira (AAF)
Data/Hora..: 22/12/05 - 11:30
Objetivo...: Fazer a troca da NCM de uma linha de saldo de exportação.
*/
**********************
Function AC400NCMExp()
**********************
Local nInd, cChaveED3

//Verifica se saldo para a Nova NCM.
nRecWkED3 := WorkED3->( RecNo() )
nSldRest  := WorkED3->ED3_SALDO
nSldVlCCb := WorkED3->ED3_SAL_CO
nSldVlSCb := WorkED3->ED3_SAL_SE
nVlNovoCCb:= 0
nVlNovoSCb:= 0
nAbateCCb := 0

lTemUso := WorkED3->ED3_SALDO < WorkED3->ED3_QTD //Se Houve utilização.

If lIndPercAg
   cChaveED3 := WorkED3->(ED3_NCM+ED3_PROD+Str(ED3_PERCAG,5,2))
Else
   cChaveED3 := WorkED3->(ED3_NCM+ED3_PROD)
EndIf

WorkED1->( dbSetOrder(8) ) //ED1_NCM+ED1_PROD+Str(ED1_PERCAG,5,2)
WorkED1->( dbSeek(cChaveED3))
Do While !WorkED1->( EoF() ) .AND. WorkED1->(&(IndexKey())) == cChaveED3 .AND. nSldRest > 0

   nSldRest  -= WorkED1->ED1_QTD
   nSldVLCCb -= WorkED1->ED1_VAL_EM
   nSldVLSCb -= WorkED1->ED1_VAL_SE

   If !lTemUso .AND. (M->ED0_MODAL == ISENCAO .OR. Empty(M->ED0_DT_ENV))//Troca todos os itens para a Nova NCM e mantém a mesma linha de saldo.
      WorkED3Atu("WorkED1",ESTORNAR)

      RecLock("WorkED1",.F.)
      WorkED1->ED1_NCM    := cNovaNCM
      WorkED1->ED1_NCMANT := cVelhaNCM
      WorkED1->( MsUnLock() )

      WorkED3Atu("WorkED1",INCLUIR)
      //RecLock("WorkED3",.F.)
      //WorkED3->ED3_NCMANT := cVelhaNCM
      //WorkED3->( MsUnLock() )

   ElseIf nSldRest >= 0 //Troca o item para a Nova NCM caso haja saldo restante.
      WorkED3Atu("WorkED1",ESTORNAR)

      If nSldVlCCb < 0
         RecLock("WorkED1",.F.)
         nVlNovoCCb -= nSldVlCCb
         WorkED1->ED1_VAL_EM += nSldVlCCb

         If WorkED1->ED1_VAL_EM == 0
            WorkED1->ED1_VAL_EM := 0.01
            nAbateCCb += 0.01
         EndIf

         nSldVlCCb := 0
         WorkED1->( MsUnLock() )
      EndIf

      If nSldVlSCb < 0
         RecLock("WorkED1",.F.)
         nVlNovoSCb -= nSldVlSCb
         WorkED1->ED1_VAL_SE += nSldVlSCb

         nSldVlSCb := 0
         WorkED1->( MsUnLock() )
      EndIf

      RecLock("WorkED1",.F.)
      WorkED1->ED1_NCM    := cNovaNCM
      WorkED1->ED1_NCMANT := cVelhaNCM
      WorkED1->( MsUnLock() )

      WorkED3Atu("WorkED1",INCLUIR)

      WorkED3->( dbGoTo(nRecWkED3) )
   Else
      aCposAux := {}

      For nInd := 1 To WorkED1->( FCount() )
         aAdd(aCposAux,WorkED1->( FieldGet(nInd) ))
      Next nInd

      //Proporção da quantidade restante ao total do item.
      nCoefAlt := - nSldRest / WorkED1->ED1_QTD

      //Campos a Serem proporcionalizados.
      aAtuCampos := {"ED1_QTD" ,"ED1_VALORI","ED1_VALCOM",;
                     "ED1_PESO","ED1_QTDNCM","ED1_QTDORI"}

      //Ponto de Entrada para gravação de campos customizados.
      If EasyEntryPoint("EDCAC400")
         ExecBlock("EDCAC400",.F.,.F.,"ALTERA_NCM_SLD_EXP")
      EndIf

      //Grava o resto com a NCM Antiga.
      RecLock("WorkED1",.F.)

      AC400PropAtu("WorkED1",nCoefAlt,aAtuCampos)
      WorkED1->ED1_VAL_EM := nVlNovoCCb - nSldVlCCb
      WorkED1->ED1_VAL_SE := nVlNovoSCb - nSldVlSCb
      WorkED1->( MsUnLock() )

      // ** Atualiza os Saldos do ED3 para NCM Antiga.
      WorkED3->( dbGoTo(nRecWkED3) )

      nReduzQtd   := aCposAux[WorkED1->( FieldPos("ED1_QTD") )]    - WorkED1->ED1_QTD
      nReduzVlCCb := aCposAux[WorkED1->( FieldPos("ED1_VAL_EM") )] - WorkED1->ED1_VAL_EM
      nReduzVlSCb := aCposAux[WorkED1->( FieldPos("ED1_VAL_SE") )] - WorkED1->ED1_VAL_SE
      nReduzNCM   := aCposAux[WorkED1->( FieldPos("ED1_QTDNCM") )] - WorkED1->ED1_QTDNCM

      nCoefED3    := 1 - (aCposAux[WorkED1->( FieldPos("ED1_QTD") )] - WorkED1->ED1_QTD) / WorkED3->ED3_QTD

      aAtuED3     := {"ED3_QTD","ED3_QTDNCM","ED3_PESO"}

      RecLock("WorkED3",.F.)
      AC400PropAtu("WorkED3",nCoefED3,aAtuED3)

      WorkED3->ED3_SALDO  -= nReduzQtd
      WorkED3->ED3_VAL_EM -= nReduzVlCCb
      WorkED3->ED3_VAL_CO -= nReduzVlCCb
      WorkED3->ED3_SAL_CO -= nReduzVlCCb
      WorkED3->ED3_VAL_SE -= nReduzVlSCb
      WorkED3->ED3_SAL_SE -= nReduzVlSCb
      WorkED3->ED3_SALNCM -= nReduzNCM

      WorkED3->ED3_PERCAG := Round(WorkED3->ED3_VALCOM / WorkED3->ED3_VAL_EM,4)*100

      WorkED3->( MsUnLock() )
      // **

      // ** Proporcionaliza o restante com Nova NCM.
      nCoefAlt := 1 - nCoefAlt

      RecLock("WorkED1",.T.)
      For nInd := 1 To Len(aCposAux)
         WorkED1->&( FieldName(nInd) ) := aCposAux[nInd]
      Next nInd

      WorkED1->ED1_NCM    := cNovaNCM
      WorkED1->ED1_NCMANT := cVelhaNCM
      AC400PropAtu("WorkED1",nCoefAlt,aAtuCampos)
      WorkED1->ED1_VAL_EM += nSldVlCCb
      WorkED1->ED1_VAL_SE += nSldVlSCb

      If WorkED1->ED1_VAL_EM == 0
         WorkED1->ED1_VAL_EM := 0.01
         nAbateCCb += 0.01
      EndIf

      WorkED1->ED1_RECNO  := 0
      WorkED1->TRB_ALI_WT := "ED1"
      WorkED1->TRB_REC_WT := 0
      WorkED1->( MsUnLock() )

      WorkED3Atu("WorkED1",INCLUIR)
      // **

      WorkED3->( dbGoTo(nRecWkED3) )
   EndIf

   WorkED1->( dbSeek(cChaveED3))
EndDo

If nAbateCCb > 0
   If lIndPercAg
      cChaveED3 := WorkED3->(cNovaNCM+ED3_PROD+Str(ED3_PERCAG,5,2))
   Else
      cChaveED3 := WorkED3->(cNovaNCM+ED3_PROD)
   EndIf

   lAbateCCb := .F.
   WorkED1->( dbSeek(cChaveED3))
   Do While !WorkED1->( EoF() ) .AND. WorkED1->(ED1_NCM+ED1_PROD+Str(ED1_PERCAG,5,2)) == cChaveED3

      If WorkED1->ED1_VAL_EM > nAbateCCb
         lAbateCCb := .T.
         EXIT
      EndIf

      WorkED1->( dbSkip() )
   EndDo

   If lAbateCCb
      RecLock("WorkED1",.F.)
      WorkED1->ED1_VAL_EM  -= nAbateCCb
      WorkED1->( MsUnLock() )

      WorkED3->( dbSetOrder(1) )
      WorkED3->( dbSeek(WorkED1->(&(IndexKey()))) )

      RecLock("WorkED3",.F.)
      WorkED3->ED3_VAL_EM -= nAbateCCb
      WorkED3->ED3_SAL_CO -= nAbateCCb

      WorkED3->ED3_PERCAG := Round(WorkED3->ED3_VALCOM / WorkED3->ED3_VAL_EM,4)*100

      WorkED3->( MsUnLock() )
   EndIf

EndIf

Return .T.

//*----------------------------------------------------------------------------------------------
Function EDCLOG400(cTabela,cChave,cTipo,cCampo,cDe,cPara,dData,cHora,cUsua)//,cPD,cProd,cItem,cSeq)
//*----------------------------------------------------------------------------------------------
Default cCampo := "" //LRS - 25/09/2018
cAlias := If(!Empty(Alias()),Alias(),"EDF")

If !ChkFile("EDF",.F.)
   Return .F.
EndIf

/*
if empty(cTabela)
	return .f.
endif
if empty(cChave)
	return .f.
endif
if empty(cTipo)
	return .f.
endif
if empty(cCampo)
	return .f.
endif
*/

IF VALTYPE(cDe)="D"
	cDe:=DTOC(cDe)
ELSEIF VALTYPE(cDe)<>"C"
	//cDe:=STR(cDe)
ENDIF
IF VALTYPE(cPara)="D"
	cPara:=DTOC(cPara)
ELSEIF VALTYPE(cPara)<>"C"
	//cPara:=STR(cPara)
ENDIF

RecLock("EDF",.T.)
EDF->EDF_FILIAL := xFilial("EDF")
EDF->EDF_TABELA := cTabela

If cTabela == "ED0"
   EDF->EDF_PD := cChave
ElseIf cTabela == "ED1"
   // cChave = ED1_PD+ED1_PROD+ED1_SEQ
   EDF->EDF_MODAL  := M->ED0_MODAL

   nIni := 1
   EDF->EDF_PD   := SubStr(cChave,nIni,nIni + AvSx3("ED1_PD"  ,3))
   nIni += AvSx3("ED1_PD",3)
   EDF->EDF_PROD := SubStr(cChave,nIni,nIni + AvSx3("ED1_PROD",3))//If(cProd<>NIL,cProd,ED1->ED1_PROD)
   nIni += AvSx3("ED1_PROD",3)
   EDF->EDF_SEQ  := SubStr(cChave,nIni,nIni + AvSx3("ED1_SEQ" ,3))//If(cSeq <>NIL,cSeq ,ED1->ED1_SEQ )

ElseIf cTabela == "ED2"
   EDF->EDF_MODAL  := M->ED0_MODAL

   If M->ED0_MODAL == SUSPENSAO //Suspenção
      // cChave = ED2_PD+ED2_ITEM+ED2_SEQ
      nIni := 1
      EDF->EDF_PD   := SubStr(cChave,nIni,nIni + AvSx3("ED2_PD"  ,3))
      nIni += AvSx3("ED2_PD",3)
      EDF->EDF_ITEM := SubStr(cChave,nIni,nIni + AvSx3("ED2_ITEM",3))//If(cItem<>NIL,cItem,ED2->ED2_ITEM)
      nIni += AvSx3("ED2_ITEM",3)
      EDF->EDF_SEQ  := SubStr(cChave,nIni,nIni + AvSx3("ED2_SEQ" ,3))
   ElseIf M->ED0_MODAL == ISENCAO //Isenção
      // cChave = ED2_PD+ED2_ITEM+ED2_PROD+ED2_SEQ+ED2_NCM+ED2_DI_NUM+ED2_INVOIC+ED2_PO_NUM+ED2_POSICA+ED2_PGI_NU+ED2_RE
      nIni := 1
      EDF->EDF_PD   := SubStr(cChave,nIni,nIni + AvSx3("ED2_PD"  ,3))
      nIni += AvSx3("ED2_PD",3)
      EDF->EDF_ITEM := SubStr(cChave,nIni,nIni + AvSx3("ED2_ITEM",3))//If(cItem<>NIL,cItem,ED2->ED2_ITEM)
      nIni += AvSx3("ED2_ITEM",3)
      EDF->EDF_PROD := SubStr(cChave,nIni,nIni + AvSx3("ED2_PROD",3))//If(cItem<>NIL,cItem,ED2->ED2_ITEM)
      nIni += AvSx3("ED2_PROD",3)
      EDF->EDF_SEQ  := SubStr(cChave,nIni,nIni + AvSx3("ED2_SEQ" ,3))
      nIni += AvSx3("ED2_SEQ",3)
      EDF->EDF_NCM  := SubStr(cChave,nIni,nIni + AvSx3("ED2_NCM",3))
      nIni += AvSx3("ED2_NCM",3)
      EDF->EDF_DI_NUM := SubStr(cChave,nIni,nIni + AvSx3("ED2_DI_NUM",3))
      nIni += AvSx3("ED2_DI_NUM",3)
      EDF->EDF_INVOIC := SubStr(cChave,nIni,nIni + AvSx3("ED2_INVOIC",3))
      nIni += AvSx3("ED2_INVOIC",3)
      EDF->EDF_PO_NUM := SubStr(cChave,nIni,nIni + AvSx3("ED2_PO_NUM",3))
      nIni += AvSx3("ED2_PO_NUM",3)
      EDF->EDF_POSDI  := SubStr(cChave,nIni,nIni + AvSx3("EDF_POSDI",3))
      nIni += AvSx3("EDF_POSDI",3)
      EDF->EDF_PGI_NU := SubStr(cChave,nIni,nIni + AvSx3("ED2_PGI_NU",3))
      nIni += AvSx3("ED2_PGI_NU",3)
      EDF->EDF_RE := SubStr(cChave,nIni,nIni + AvSx3("ED2_RE",3))
      nIni += AvSx3("ED2_RE",3)
   EndIf

ElseIf cTabela == "ED8"
   // cChave = ED8_DI_NUM+ED8_ADICAO+ED8_POSDI
   nIni := 1
   EDF->EDF_DI_NUM := SubStr(cChave,nIni,nIni + AvSx3("ED8_DI_NUM",3))
   nIni += AvSx3("ED8_DI_NUM",3)
   EDF->EDF_ADICAO  := SubStr(cChave,nIni,nIni + AvSx3("ED8_ADICAO",3))
   nIni += AvSx3("ED8_ADICAO" ,3)
   EDF->EDF_POSDI := SubStr(cChave,nIni,nIni + AvSx3("ED8_POSDI" ,3))
EndIf

EDF->EDF_TIPO   := cTipo
EDF->EDF_DATA   := If(dData<>NIL,dData,dDataBase                        )
EDF->EDF_HORA   := If(cHora<>NIL,cHora,Left(Time(),2)+SubStr(Time(),4,5))
EDF->EDF_USUARI := If(cUsua<>NIL,cUsua,cUserName               )
EDF->EDF_CAMPO  := cCampo
EDF->EDF_DE     := If(AvSX3(cCampo,2) <> "D",LTrim(TransForm(cDe  ,AvSx3(cCampo,6))),cDe  )
EDF->EDF_PARA   := If(AvSX3(cCampo,2) <> "D",LTrim(TransForm(cPara,AvSx3(cCampo,6))),cPara)

EDF->( MsUnLock() )

dbSelectArea(cAlias)
Return .T.

*-------------------------------------------------------------------------------------*
Function AC400CHist()
*-------------------------------------------------------------------------------------*

AC400Hist("ED0")

Return .T.

*-------------------------------------------------------------------------------------*
Function AC400Hist(cTab)
*-------------------------------------------------------------------------------------*
Local oDlgHis, oMarkHist, nInd
Local aBotao:={{"BMPVISUAL" /*"ANALITICO"*/,{|| AC400VisHist()}, STR0003}} //"Visualizar"
Local aCposF := {} , nPos, i
//AOM - 30/10/10
Local aCamposEDF := {"EDF_TIPO","EDF_DATA", "EDF_HORA", "EDF_USUARI", "EDF_TABELA", "EDF_CAMPO", "EDF_DE", "EDF_PARA", "EDF_RE", "EDF_PROD",;
                     "EDF_DI_NUM", "EDF_ITEM", "EDF_NCM", "EDF_ADICAO", "EDF_POSDI", "EDF_PGI_NU", "EDF_PO_NUM", "EDF_INVOIC" }

Private aSelCposF := {}
Private aGets:={}
Private aTela:={}
aOrd := SaveOrd({"SX2","SX3"})

oMainWnd:ReadClientCoords()

If ChkFile("EDF",.F.) .AND. EDF->( dbSeek(xFilial("EDF")+ED0->ED0_PD) )

   SX2->( dbSetOrder(1) )
   SX3->( dbSetOrder(2) )

   WorkEDF->( avzap() )

   If cTab == "ED0"
      EDF->( dbSetOrder(1) )
      Do While !EDF->( EoF() ) .AND. EDF->EDF_FILIAL == xFilial("EDF") .AND. EDF->EDF_PD == ED0->ED0_PD
         WorkEDF->( dbAppend() )

         For nInd := 1 To EDF->( FCount() )
            WorkEDF->&(EDF->(FieldName(nInd))) := EDF->( FieldGet(nInd) )
         Next nInd

         SX2->( dbSeek(WorkEDF->EDF_TABELA) )
         SX3->( dbSeek(WorkEDF->EDF_CAMPO) )

         WorkEDF->EDF_DESC  := AllTrim(X2Nome()) //SX2->X2_NOME
         WorkEDF->EDF_DESCAM:= SX3->X3_TITULO
         WorkEDF->EDF_RECNO := EDF->( RecNo() )
         WorkEDF->TRB_ALI_WT:= "EDF"
         WorkEDF->TRB_REC_WT:= EDF->(Recno())
         EDF->( dbSkip() )
      EndDo
   ElseIf cTab == "ED8"
      EDF->( dbSetOrder(2) )//EDF_FILIAL+EDF_DI_NUM+EDF_ADICAO+EDF_POSDI
      Do While !EDF->( EoF() ) .AND. EDF->EDF_FILIAL == xFilial("EDF")  .AND. EDF->EDF_DI_NUM == ED8->ED8_DI_NUM .AND.;
                                     EDF->EDF_ADICAO == ED8->ED8_ADICAO .AND. EDF->EDF_POSDI  == ED8->ED8_POSDI
         WorkEDF->( dbAppend() )

         For nInd := 1 To EDF->( FCount() )
            WorkEDF->&( EDF->(FieldName(nInd)) ) := EDF->( FieldGet(nInd) )
         Next nInd

         SX2->( dbSeek(WorkEDF->EDF_TABELA) )
         SX3->( dbSeek(WorkEDF->EDF_CAMPO) )

         WorkEDF->EDF_DESCAM:= SX3->X3_TITULO
         WorkEDF->EDF_DESC  := AllTrim(X2Nome()) //SX2->X2_NOME
         WorkEDF->EDF_RECNO := EDF->( RecNo() )
         WorkEDF->TRB_ALI_WT:= "EDF"
         WorkEDF->TRB_REC_WT:= EDF->(Recno())
         EDF->( dbSkip() )
      EndDo
   EndIf

   WorkEDF->( dbGoTop() )

   Define MsDialog oDlgHis Title AC401STR(001) ; //"Histórico"
   From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   Of oMainWnd Pixel

      //AOM - 30/10/10
      aCposF := BrowseCpos("EDF","WorkEDF")
      For i := 1 To Len(aCamposEDF)
         If (nPos := aSCan(aCposF,{|x| x[1] == aCamposEDF[i]})) > 0
            AADD(aSelCposF,{aCposF[nPos][1],aCposF[nPos][2], aCposF[nPos][3], aCposF[nPos][4]})
         EndIf
      Next i

      aSelCposF[aScan(aSelCposF,{|X| X[1] == "EDF_TIPO"})][1] := {|| If(WorkEDF->EDF_TIPO=="I","Inclusão",If(WorkEDF->EDF_TIPO=="A","Alteração","Exclusão")) }
      nPos := aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_USUARI"})
      aAdd(aSelCposF,NIL)
      aAdd(aSelCposF,NIL)
      //aAdd(aSelCposF,NIL)
      aIns(aSelCposF,nPos+1)
      aIns(aSelCposF,nPos+2)
      //aIns(aSelCposF,nPos+3)
      aSelCposF[nPos+1] := {"EDF_DESC"  ,"","Tabela","@!"}
      aSelCposF[nPos+2] := {"EDF_DESCAM","","Campo" ,"@!"}
      //aSelCposF[nPos+3] := {"EDF_INVOIC","","Invoice","@!"}

      AADD(aSelCposF,{"EDF_INVOIC","","Invoice","@!"})

      //TRP-08/05/2007
      nPos:= aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_CAMPO"})
      aDel(aSelCposF,nPos)
      aSize(aSelCposF,LEN(aSelCposF)-1)
      /*If cTab == "ED0"
         nPos:= aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_DI_NUM"})
         aDel(aSelCposF,nPos)
         nPos:= aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_ADICAO"})
         aDel(aSelCposF,nPos)
         nPos:= aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_POSDI"})
         aDel(aSelCposF,nPos)
         aSize(aSelCposF,LEN(aSelCposF)-3)
      ElseIf cTab == "ED8"
         nPos:= aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_PD"})
         aDel(aSelCposF,nPos)
         nPos:= aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_PROD"})
         aDel(aSelCposF,nPos)
         nPos:= aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_ITEM"})
         aDel(aSelCposF,nPos)
         nPos:= aScan(aSelCposF,{|X| ValType(X[1]) == "C" .AND. X[1] == "EDF_SEQ"})
         aDel(aSelCposF,nPos)
         aSize(aSelCposF,LEN(aSelCposF)-4)
      EndIf*/

      oMarkHist := MsSelect():New("WorkEDF",,,aSelCposF,@lInverte,@cMarca,{15,1,(oDlgHis:nClientHeight-6)/2,(oDlgHis:nClientWidth-4)/2})
      oMarkHist:bAval:={|| AC400VisHist() }
      //oMarkHist:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	  oMarkHist:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT// BCO - Alteração das propriedades de alinhamento de Tela para antes do INIT - 02/01/12

   ACTIVATE MSDIALOG oDlgHis ON INIT (EnchoiceBar(oDlgHis,{||oDlgHis:End()},{||oDlgHis:End()},,aBotao),;
                                   WorkEDF->( DBGoTop() ),;
                                   oMarkHist:oBrowse:Refresh() )

Else
   MsgInfo(AC401STR(019)+Alltrim(ED0->ED0_PD)+".") //"Não existem registros de histórico do Pedido de Drawback "
EndIf

RestOrd(aOrd)

Return .T.

*-----------------------------------------------------------------------------------------*
Static Function AC400VisHist()
*-----------------------------------------------------------------------------------------*
Local oDlgHist2, nSelecao:=0, cTit := AC401STR(020), nInd //"Visualização de Histórico"
Private nRec := WorkEDF->EDF_RECNO

EDF->( dbGoTo(nRec) )

dbSelectArea("EDF")
For nInd := 1 To FCount()
   M->&( FieldName(nInd) ) := WorkEDF->&( FieldName(nInd) )
Next nInd

M->EDF_DESC   := WorkEDF->EDF_DESC
M->EDF_DESCAM := WorkEDF->EDF_DESCAM

Define MsDialog oDlgHist2 Title cTit ;
From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
Of oMainWnd Pixel

   aCpos := {}

   For nInd := 1 To Len(aSelCposF)
      If ValType(aSelCposF[nInd][1]) == "C"
         aAdd(aCpos,aSelCposF[nInd][1])
      Else
         aAdd(aCpos,"EDF_TIPO")
      EndIf
   Next nInd

   oEnchHist := MsMGet():New("EDF",nRec,VISUALIZAR,,,,aCpos,{15,1,(oDlgHist2:nClientHeight-4)/2,(oDlgHist2:nClientWidth-4)/2},,3)
   oEnchHist:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Activate MsDialog oDlgHist2 On Init EnchoiceBar(oDlgHist2,{||oDlgHist2:End()},{||oDlgHist2:End()})

Return .T.

/*
AAF 17/03/2006 - Função para Estorno dos RE's sem DI's associadas dos Resumos.
*/
**********************
Function AC400EstRes()
**********************
Local aEstrut := {}
Local nInd

WorkExpl->( dbSeek(WorkRE->ED1_RE+WorkRE->ED1_PROD) )
Do While !WorkExpl->( EoF() ) .AND. WorkExpl->RE == WorkRE->ED1_RE .AND. WorkExpl->PROD == WorkRE->ED1_PROD
   If lAbriuEDA
      AC400GrvEDA(ESTORNAR,IG400BuscaItem("I",WorkExpl->ITEM,M->ED0_PD),0,WorkExpl->QUANT1,cMarca)
      // ** AAF - 20/01/06 - Exclui do Resumo de Estruturas os Produtos não utilizados.
      cItem    := WorkExpl->ITEM
      nRecWork := WorkExpl->( RecNo() )
      aOrd     := SaveOrd({"WorkExpl","WorkEDA"})

      WorkExpl->( dbSetOrder(1) )
      WorkExpl->( dbSeek(cItem) )
      Do While WorkExpl->ITEM == cItem
         /*If aScan(aCanc,WorkExpl->( RecNo() )) == 0
            lAcho := .T.
            EXIT
         EndIf
         */
         If aScan(aEstrut,WorkExpl->PROD) == 0
            aAdd(aEstrut,WorkExpl->PROD)
         EndIf
         WorkExpl->( dbSkip() )
      EndDo
      lAcho := .F.
      WorkED1->( dbSetOrder(6) )
      For nInd:= 1 To Len(aEstrut)
         If WorkED1->( dbSeek(aEstrut[nInd]) )
            lAcho := .T.
            EXIT
         EndIf
      Next

      If !lAcho
         WorkEDA->( dbSetOrder(1) )
         WorkEDA->( dbSeek(cItem) )
         Do While !WorkEDA->( EoF() ) .AND. WorkEDA->EDA_ITEM == cItem
            WorkEDA->( dbDelete(), dbSkip() )
         EndDo
      EndIf

      RestOrd(aOrd)
      WorkExpl->( dbGoTo(nRecWork) )
   // **
   EndIf

   If lAbriuEDC
      AC400EDCGrv(ESTORNAR,IG400BuscaItem("I",WorkExpl->ITEM,M->ED0_PD),WorkRE->ED1_RE,WorkRE->ED1_PROD,0,WorkExpl->QUANT1,cMarca)

      // ** AAF - 20/01/06 - Exclui do Resumo de Produtos os RE's não utilizados.

      aOrd := SaveOrd({"WorkED1","WorkEDC"})

      WorkED1->( dbSetOrder(6) )
      If !WorkED1->( dbSeek(WorkRE->ED1_PROD+WorkRE->ED1_RE) )

         WorkEDC->( dbSetOrder(2) )
         WorkEDC->( dbSeek(WorkRE->ED1_PROD+WorkRE->ED1_RE) )
         Do While WorkEDC->EDC_PROD == WorkRE->ED1_PROD .AND. WorkEDC->EDC_RE == WorkRE->ED1_RE
            WorkEDC->( dbDelete(), dbSkip() )
         EndDo
      EndIf

      RestOrd(aOrd)

   // **
   EndIf

   WorkExpl->( dbSkip() )
EndDo

Return .T.

//AAF 20/03/2006 - Arredondamento para baixo.
***********************************
Function AC400Round(nValor, cCampo)
***********************************
Local nValArred

If EasyGParam("MV_EDC0002",,.T.)
   nValArred := NoRound(nValor,AvSx3(cCampo,4))
   /*
   nValArred := Int(nValor)

   nColIni   := At(".",AllTrim(Str(nValor)))
   If nColIni > 0
      nValArred += Val("0."+SubStr(AllTrim(Str(nValor)),nColIni+1,AvSx3(cCampo,4)))
   EndIf
   */
Else
   nValArred := Round(nValor,AvSx3(cCampo,4))
EndIf

Return nValArred

*-----------------------------------------------------------------------*
Function AC400IsAprop(cTipo,cModo,cAtoCon,cPedido,cFilAux)
*-----------------------------------------------------------------------*

 Local aFiliais := {}   ,;
       aOrd     := {}   ,;
       lIsAprop := .F.  ,;
       nInd     := 1

 Default cAtoCon := ""
 Default cPedido := ""

   If lMultiFil
      aFiliais := AvgSelectFil(.F.)
   Else
      aFiliais := {cFilAux}
   EndIf

   For nInd := 1  to  Len(aFiliais)
      cFilAux := aFiliais[nInd]
      Do Case

         Case cTipo == "EMB"
            aOrd := SaveOrd({"EE9"})
            EE9->( DBSetOrder(10) )
            If cModo == SUSPENSAO  .And.  ( ( !Empty(cAtoCon)  .And.  EE9->( DBSeek(cFilAux+cAtoCon+"2") ) )  .Or.  EE9->( DBSeek(cFilAux+cPedido+"1") ) )
               lIsAprop := .T.
               Exit
            EndIf

         Case cTipo == "DI"
            aOrd := SaveOrd({"SW8"})
            SW8->( DBSetOrder(5) )
            If !Empty(cAtoCon)  .And.  SW8->( DBSeek(cFilAux+cAtoCon) )
               If !( SW6->W6_HAWB == SW8->W8_HAWB )
                  SW6->( DBSeek(cFilAux+SW8->W8_HAWB) )
               EndIf
               lIsAprop := .T.
               Exit
            EndIf

         Case cTipo == "LI"
            aOrd := SaveOrd({"SW5"})
            SW5->( DBSetOrder(9) )
            If ( !Empty(cAtoCon)  .And.  SW5->( DBSeek(cFilAux+cAtoCon) ) )  .Or.  SW5->( DBSeek(cFilAux+AvKey("P"+cPedido,"W5_AC")) )
               lIsAprop := .T.
               Exit
            EndIf

      End Case

   Next nInd

   RestOrd(aOrd)


Return lIsAprop


*-----------------------------------------------------------------------*
Static Function AC400ValDI(cDI)
*-----------------------------------------------------------------------*

 Local aFiliais := {}   ,;
       aOrd     := {}   ,;
       lDIOK    := .F.  ,;
       nInd     := 1

 Default cDi := ""

   aOrd := SaveOrd({"SW6"})
   SW6->( DBSetOrder(11) )

   If lMultiFil
      aFiliais := AvgSelectFil(.F.)
   Else
      aFiliais := {cFilSW6}
   EndIf

   For nInd := 1  to  Len(aFiliais)
      If SW6->( DBSeek(aFiliais[nInd]+cDI) )
         lDIOK := .T.
         Exit
      EndIf
   Next nInd

   RestOrd(aOrd)


Return lDIOK
*-----------------------------------------------------*
Static Function ValPesqMarca(cNCM,cProd,cFilialSB1)
*-----------------------------------------------------*

 Local cMsg       := ""  ,;
       cFilSB1Old := ""  ,;
       lOK  := .T.
 Default cProd := ""  ,;
         cNCM  := ""

   cFilSB1Old := cFilSB1      // Guarda Filial Padrao do SB1
   If Empty(cFilialSB1)
      cFilialSB1 := cFilSB1
   EndIf
   cFilSB1 := cFilialSB1      // Substitui para utilização na Função HaveConvNCM()

   lOK := HaveConvNCM(cProd,cNCM)

   If !lOK
     cMsg := STR0182+AllTrim(cProd)                                         // "Não existe conversão entre as Unidades de Medidas do Produto ("
     cMsg += STR0184+Trans(cNCM,AvSX3("ED1_NCM",6))+")."  // ") e/ou da NCM ("
     cMsg += Chr(13)+Chr(10)+AC401STR(0004)                                 // "Atualize o cadastro de conversão de unidades de medida."
     MsgInfo(cMsg)
   EndIf

   cFilSB1 := cFilSB1Old      // Restaura Filial Padrao do SB1


Return lOK


// PLB 18/07/07 - Verifica se Produto possui Conversão entre sua Unidade de Medida e a da NCM
*-----------------------------------------------------*
Static Function HaveConvNCM(cProd,cNCM)
*-----------------------------------------------------*

 Local aOrd  := {}   ,;
       lHave := .T.
 Default cProd := ""  ,;
         cNCM  := ""

   aOrd := SaveOrd({"SB1","SYD"})

   cProd := AvKey(cProd,"B1_COD")
   cNCM  := AvKey(cNCM,"YD_TEC")

   Begin Sequence

      (cAliasSB1)->( DBSetOrder(1) )
      If (cAliasSB1)->( DBSeek(cFilSB1+cProd) )
         If Empty(cNCM)
            cNCM := (cAliasSB1)->B1_POSIPI
         EndIf
         SYD->( DBSetOrder(1) )
         If !SYD->( DBSeek(cFilSYD+cNCM) )
            lHave := .F.
            Break
         EndIf
      Else
         lHave := .F.
         Break
      EndIf

      lHave := AvCanTrans(SYD->YD_UNID,(cAliasSB1)->B1_UM,cProd)

   End Sequence

   RestOrd(aOrd)


Return lHave

/*
Função.....: AC400Peso()
Parâmetros.: cUMitem = Unidade de medida do item
			 cItem   = Item
			 nQtde   = Quantidade do item
			 nB1Peso   = Peso do produto no SB1
Autor......: Tamires Daglio Ferreira (TDF)
Data/Hora..: 22/03/10 - 11:30
Objetivo...: Verificar se no item,o campo B1_peso esta preeenchido, e fazer os devidos tratamentos.
Retorno....: nPeso
*/
Static Function AC400Peso(cUMitem,cItem,nQtde,nB1Peso)

Local nPeso:= 0

If Empty(nB1Peso)

   If AvVldUn( cUMitem ) // MPG - 14/02/2018
      nPeso:= nQtde
   Else
      nPeso:= AVTransUnid(cUMitem,KILOGRAMA,cItem,nQtde)
   EndIf

Else
   nPeso:= nQtde * nB1Peso
EndIf

Return nPeso


/*
Funcao     : AC400EstSld
Parametros : nQntde    - quantidade envolvida
             cUnid     - Unidade de medida envolvida
             nPeso     - Peso unitario do item envolvido
             nValor    - Valor envolvido
             cMoeda    - Moeda envolvida
             cAto      - Ato Concessório envolvido
             cSeq      - Sequência do Ato Concessório
             lMsg      - Flag para apresentar a mensagem quando não houver conversão
                         de unidade de medida.
             lLI       - Flag para efetuar estorno das quantidades e valores da LI
             lDI       - Flag para efetuar estorno das quantidades e valores da DI
             aQntdConv - Array com quantidades e Unidade de medidas com conversão ja feitas.
                         [1][1] := {Unidade, Quantidade}
             nTxMoeda  - Taxa da Moeda
             nTxDolar  - Taxa do Dolar

Retorno    : lRet
Objetivos  : Efetuar estorno de quantidade de estoque, quantidade NCM e valor no Ato Concessório
Autor      : Allan Oliveira Monteiro
Data/Hora  : 27/09/10 - 10:20
*/

/****************************************************************************************************************/
Function AC400EstSld(nQntde, cUnid, nPeso , nValor, cMoeda, cAto, cSeq,lMsg,lLI,lDI,aQntdConv,nTxMoeda,nTxDolar,lCompra,cSld)
/****************************************************************************************************************/
Local lRet := .T.
Local nQtdNcm ,nQtdEst , nValDolar , nPos
Local cUMItem := ""//AOM - 30/11/2011 - Adicionada a Unidade de Medida para retorno da função
Local aRet := {}
Local lManutAuto := (Type("lManNFAuto") == "L" .And. lManNFAuto) .Or. (Type("lManDIAuto") == "L" .And. lManDIAuto)
Local cSeek := ""
Local lCompNacion := AvFlags("SEQMI") .And. Valtype(lCompra) == "L" .And. lCompra

Default lMsg := .T., lLI := .T., lDI := .T.
Default nTxMoeda := 0 , nTxDolar := 0
Default cSld := "S" //RRC - 25/06/12

Begin Sequence


   //Posicionando no Ato Concessório
   //BAK - 11/11/11
   If lCompNacion
      ED4->(DbSetOrder(8))
      cSeek := xFilial("ED4")+ AvKey(cAto,"ED4_AC") + AvKey(cSeq,"ED4_SEQMI")
   Else
      ED4->(DbSetOrder(2))
      cSeek := xFilial("ED4")+ AvKey(cAto,"ED4_AC") + AvKey(cSeq,"ED4_SEQSIS")
   EndIf

   //Posicionando no Ato Concessório
   If !(ED4->(DbSeek(cSeek)))
      If lMsg
         If !lManutAuto
            MsgInfo("Ato Concessório não encontrado", "Aviso")
         Else
            EasyHelp("Ato Concessório não encontrado")
         EndIf
      EndIf
      lRet := .F.
      Break
   EndIf


   //Obter a informação do Tipo do Ato Concessório
   ED0->(DbSetOrder(2))
   If !(ED0->(DbSeek(xFilial("ED0") + AvKey(cAto,"ED0_AC") )))
      If lMsg
         If !lManutAuto
            MsgInfo("Ato Concessório não encontrado", "Aviso")
         Else
            EasyHelp("Ato Concessório não encontrado")
         EndIf
      EndIf
      lRet := .F.
      Break
   EndIf

   //Verifica se o vetor esta preenchido com a unidade convertida do Estoque
   If ValType(aQntdConv) <> "U" .And. (nPos := aScan(aQntdConv,{|x| x[1]== ED4->ED4_UMITEM})) > 0
      nQtdEst := aQntdConv [nPos][2]
   Else

      //Conversão da Unidade de Medida da Quantidade de Estoque do Ato Cocessório
      If ( ED0->ED0_TIPOAC == GENERICO  .And.  ED4->ED4_NCM == NCMGENERICA )  .Or.  Alltrim(cUnid) == Alltrim(ED4->ED4_UMITEM)
         nQtdEst:= nQntde
      ElseIf AvVldUn( ED4->ED4_UMITEM ) // MPG - 14/02/2018
         nQtdEst := nPeso * nQntde
      Else
         nQtdEst := AVTransUnid(cUnid,ED4->ED4_UMITEM,ED4->ED4_ITEM,nQntde,If(ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCMGENERICA,.T.,.F.))
      EndIf

   EndIf



   //Verificando se foi feita a conversão da Unidade de medida da quantidade de Estoque
   If ValType(nQtdEst) <> "N"
      lRet := .F.
      If lMsg
         If !lManutAuto
            MsgInfo("Não foi cadastrada a conversão de Unidade de medida de "  + AllTrim(cUnid) + " para " + AllTrim(ED4->ED4_UMITEM) + ". Efetue o cadastro de conversão para as unidades selecionadas.","Aviso")
         Else
            EasyHelp("Não foi cadastrada a conversão de Unidade de medida de "  + AllTrim(cUnid) + " para " + AllTrim(ED4->ED4_UMITEM) + ". Efetue o cadastro de conversão para as unidades selecionadas.")
         EndIf
      EndIf
      break
   EndIf


   //Verifica se o vetor esta preenchido com a unidade convertida da NCM
   If ValType(aQntdConv) <> "U" .And. (nPos := aScan(aQntdConv,{|x| x[1]== ED4->ED4_UMNCM})) > 0
      nQtdNcm := aQntdConv [nPos][2]
   Else

      //Conversão da Unidade de Medida da Quantidade NCM do Ato Cocessório
      If ( ED0->ED0_TIPOAC == GENERICO  .And.  ED4->ED4_NCM == NCMGENERICA )  .Or.  cUnid == ED4->ED4_UMNCM
         nQtdNcm := nQntde
      ElseIf AvVldUn( ED4->ED4_UMNCM ) // MPG - 14/02/2018
         nQtdNcm := nPeso * nQntde
      ElseIf ED4->ED4_UMITEM == ED4->ED4_UMNCM
         nQtdNcm := nQtdEst
      Else
         nQtdNcm := AVTransUnid(cUnid,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQntde,If(ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCMGENERICA,.T.,.F.))
         If Empty(nQtdNcm)  .And.  !Empty(nQtdEst)
            nQtdNcm := AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdEst,If(ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCMGENERICA,.T.,.F.))
         EndIf
      EndIf

   EndIf

   //Verificando se foi feita a conversão da Unidade de medida da quantidade NCM
   If ValType(nQtdNcm) <> "N"
      lRet := .F.
      If lMsg
         If !lManutAuto
            MsgInfo("Não foi cadastrada a conversão de Unidade de medida de "  + AllTrim(cUnid) + " para " + AllTrim(ED4->ED4_UMNCM) + ". Efetue o cadastro de conversão para as unidades selecionadas.","Aviso")
         Else
            EasyHelp("Não foi cadastrada a conversão de Unidade de medida de "  + AllTrim(cUnid) + " para " + AllTrim(ED4->ED4_UMNCM) + ". Efetue o cadastro de conversão para as unidades selecionadas.")
         EndIf
      EndIf
      break
   EndIf

   //Conversão do Valor para Dollar
   nValDolar := ConvVal(cMoeda,nValor,,,.T.,nTxMoeda,nTxDolar)
   cUMItem   := ED4->ED4_UMITEM //AOM - 30/11/2011 - Adicionada a Unidade de Medida para retorno da função

   /*Efetuando o estorno no Ato Concessório*/
   If lRet

      ED4->(RecLock("ED4",.F.))
   
      If cSld == "S" //RRC - 25/06/12 - cSld: Verifica se deve fazer o estorno do saldo do item

         If lLI
            ED4->ED4_QT_LI += nQtdEst
            ED4->ED4_VL_LI += nValDolar
            ED4->ED4_SNCMLI+= nQtdNcm
         EndIf

         If lDI
            ED4->ED4_QT_DI += nQtdEst
            ED4->ED4_VL_DI += nValDolar
            ED4->ED4_SNCMDI+= nQtdNcm
         EndIf

      EndIf

      If ED4->(FieldPos("ED4_SNCMEX")) > 0
         ED4->ED4_SNCMEX-= nQtdNcm
      EndIf

      If ED4->(FieldPos("ED4_SQTDEX")) > 0
         ED4->ED4_SQTDEX-= nQtdEst
      EndIf

      ED4->(MsUnlock("ED4"))

      AADD(aRet,{"QTDEST",nQtdEst})
      AADD(aRet,{"QTDNCM",nQtdNcm})
      AADD(aRet,{"VALDOL",nValDolar})
      AADD(aRet,{"UMITEM",cUMItem})  //AOM - 30/11/11

   EndIf

End Sequence

Return IF(Empty(aRet),aRet := Nil, aRet)


/*
Funcao     : AC400BxSld
Parametros : nQntde    - quantidade envolvida
             cUnid     - Unidade de medida envolvida
             nPeso     - Peso unitario do item envolvido
             nValor    - Valor envolvido
             cMoeda    - Moeda envolvida
             cAto      - Ato Concessório envolvido
             cSeq      - Sequência do Ato Concessório
             lMsg      - Flag para apresentar a mensagem quando não houver conversão
                         de unidade de medida.
             lLI       - Flag para efetuar estorno das quantidades e valores da LI
             lDI       - Flag para efetuar estorno das quantidades e valores da DI
             aQntdConv - Array com quantidades e Unidade de medidas com conversão ja feitas.
             [1][1] := {Unidade, Quantidade}
             nTxMoeda  - Taxa da Moeda
             nTxDolar  - Taxa do Dolar

Retorno    : lRet
Objetivos  : Efetuar Baixa de quantidade de estoque, quantidade NCM e valor no Ato Concessório
Autor      : Allan Oliveira Monteiro
Data/Hora  : 28/09/10 - 9:40
*/

/**************************************************************************************************************/
Function AC400BxSld(nQntde, cUnid, nPeso , nValor, cMoeda, cAto, cSeq,lMsg,lLI,lDI,aQntdConv,nTxMoeda,nTxDolar,lCompra,cSld)
/**************************************************************************************************************/
Local lRet := .T.
Local nQtdNcm ,nQtdEst , nValDolar
Local aRet := {}
Local lManutAuto := (Type("lManNFAuto") == "L" .And. lManNFAuto) .Or. (Type("lManDIAuto") == "L" .And. lManDIAuto)
Local lSemVerif := IsInCallStack("EasyDesEDC") // BAK - Se a chamada da função for pela EasyEDCApu, não pode ocorrer a verificação de saldo
Local cSeek := ""
Local lCompNacion := AvFlags("SEQMI") .And. Valtype(lCompra) == "L" .And. lCompra
Local cUMItem := "" //AOM - 30/11/11

Default lMsg := .T., lLI := .T., lDI := .T.
Default nTxMoeda := 0 , nTxDolar := 0
Default cSld := "S" //RRC - 25/06/12
Begin Sequence

   //Posicionando no Ato Concessório
   If lCompNacion
      ED4->(DbSetOrder(8))
      cSeek := xFilial("ED4")+ AvKey(cAto,"ED4_AC") + AvKey(cSeq,"ED4_SEQMI")
   Else
      ED4->(DbSetOrder(2))
      cSeek := xFilial("ED4")+ AvKey(cAto,"ED4_AC") + AvKey(cSeq,"ED4_SEQSIS")
   EndIf

   If !(ED4->(DbSeek(cSeek)))
      If lMsg
         If !lManutAuto
            MsgInfo("Ato Concessório não encontrado", "Aviso")
         Else
            EasyHelp("Ato Concessório não encontrado")
         EndIf
      EndIf
      lRet := .F.
      Break
   EndIf


   //Obter a informação do Tipo do Ato Concessório
   ED0->(DbSetOrder(2))
   If !(ED0->(DbSeek(xFilial("ED0") + AvKey(cAto,"ED0_AC") )))
      If lMsg
         If !lManutAuto
            MsgInfo("Ato Concessório não encontrado", "Aviso")
         Else
            EasyHelp("Ato Concessório não encontrado")
         EndIf
      EndIf
      lRet := .F.
      Break
   EndIf



   //Verifica se o vetor esta preenchido com a unidade convertida do Estoque
   If ValType(aQntdConv) <> "U" .And. (nPos := aScan(aQntdConv,{|x| x[1]== ED4->ED4_UMITEM})) > 0
      nQtdEst := aQntdConv [nPos][2]
   Else

      //Conversão da Unidade de Medida da Quantidade de Estoque do Ato Cocessório
      If ( ED0->ED0_TIPOAC == GENERICO  .And.  ED4->ED4_NCM == NCMGENERICA )  .Or.  cUnid == ED4->ED4_UMITEM
         nQtdEst:= nQntde
      ElseIf AvVldUn( ED4->ED4_UMITEM ) // MPG - 14/02/2018
         nQtdEst := nPeso * nQntde
      Else
         nQtdEst := AVTransUnid(cUnid,ED4->ED4_UMITEM,ED4->ED4_ITEM,nQntde,If(ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCMGENERICA,.T.,.F.))
      EndIf

   EndIf

   //Verificando se foi feita a conversão da Unidade de medida da quantidade de Estoque
   If ValType(nQtdEst) <> "N"
      lRet := .F.
      If lMsg
         If !lManutAuto
            MsgInfo("Não foi possivel a conversão da unidade de medida de "  + AllTrim(cUnid) + " para " + AllTrim(ED4->ED4_UMITEM) + ". Efetue o cadastro de conversão para as unidades selecionadas.","Aviso")
         Else
            EasyHelp("Não foi possivel a conversão da unidade de medida de "  + AllTrim(cUnid) + " para " + AllTrim(ED4->ED4_UMITEM) + ". Efetue o cadastro de conversão para as unidades selecionadas.")
         EndIf
      EndIf
      break
   EndIf



   //Verifica se o vetor esta preenchido com a unidade convertida da NCM
   If ValType(aQntdConv) <> "U" .And. (nPos := aScan(aQntdConv,{|x| x[1]== ED4->ED4_UMNCM})) > 0
      nQtdNcm := aQntdConv [nPos][2]
   Else

       //Conversão da Unidade de Medida da Quantidade NCM do Ato Cocessório
      If ( ED0->ED0_TIPOAC == GENERICO  .And.  ED4->ED4_NCM == NCMGENERICA )  .Or.  cUnid == ED4->ED4_UMNCM
         nQtdNcm := nQntde
      ElseIf AvVldUn( ED4->ED4_UMNCM ) // MPG - 14/02/2018
         nQtdNcm := nPeso * nQntde
      ElseIf ED4->ED4_UMITEM == ED4->ED4_UMNCM
         nQtdNcm := nQtdEst
      Else
         nQtdNcm := AVTransUnid(cUnid,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQntde,If(ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCMGENERICA,.T.,.F.))
         If Empty(nQtdNcm)  .And.  !Empty(nQtdEst)
            nQtdNcm := AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,ED4->ED4_ITEM,nQtdEst,If(ED0->ED0_TIPOAC<>GENERICO .or. ED4->ED4_NCM<>NCMGENERICA,.T.,.F.))
         EndIf
      EndIf

   EndIf

   //Verificando se foi feita a conversão da Unidade de medida da quantidade NCM
   If ValType(nQtdNcm) <> "N"
      lRet := .F.
      If lMsg
         If !lManutAuto
            MsgInfo("Não foi possivel a conversão da unidade de medida de "  + AllTrim(cUnid) + " para " + AllTrim(ED4->ED4_UMNCM) + ". Efetue o cadastro de conversão para as unidades selecionadas.","Aviso")
         Else
            EasyHelp("Não foi possivel a conversão da unidade de medida de "  + AllTrim(cUnid) + " para " + AllTrim(ED4->ED4_UMNCM) + ". Efetue o cadastro de conversão para as unidades selecionadas.")
         EndIf
      EndIf
      Break
   EndIf

   //Conversão do Valor para Dollar
   nValDolar := ConvVal(cMoeda,nValor,,,.T.,nTxMoeda,nTxDolar)
   cUMItem   := ED4->ED4_UMITEM //AOM - 30/11/11

   //Verificações dos saldos
   If lSemVerif // Verifica Saldo
      If lLI .And. (ED4->ED4_QT_LI - nQtdEst) < 0
         lRet := .F.
         If lMsg
            If !lManutAuto
               MsgInfo("Não será possivel efetuar a baixa do Saldo Qtd. LI("+AllTrim(Str(ED4->ED4_QT_LI))+"), pois sua quantidade ficará com valor("+AllTrim(Str(ED4->ED4_QT_LI - nQtdEst))+") negativo.","Aviso")
            Else
               EasyHelp("Não será possivel efetuar a baixa do Saldo Qtd. LI("+AllTrim(Str(ED4->ED4_QT_LI))+"), pois sua quantidade ficará com valor("+AllTrim(Str(ED4->ED4_QT_LI - nQtdEst))+") negativo.")
            EndIf
         EndIf
         Break

      ElseIf lLI .And. (ED4->ED4_SNCMLI - nQtdNcm) < 0
         lRet := .F.
         If lMsg
            If !lManutAuto
                MsgInfo("Não será possivel efetuar a baixa do Saldo NCM LI("+AllTrim(Str(ED4->ED4_SNCMLI))+"), pois sua quantidade ficará com valor("+AllTrim(Str(ED4->ED4_SNCMLI - nQtdNcm))+") negativo.","Aviso")
            Else
                EasyHelp("Não será possivel efetuar a baixa do Saldo NCM LI("+AllTrim(Str(ED4->ED4_SNCMLI))+"), pois sua quantidade ficará com valor("+AllTrim(Str(ED4->ED4_SNCMLI - nQtdNcm))+") negativo.","Aviso")
            EndIf
         EndIf
         Break

      ElseIf lLI .And.(ED4->ED4_VL_LI - nValDolar) < 0
      If lMsg
         If !EasyGParam("MV_ACSLDVL",,.F.)
            If !lManutAuto
               lRet := MsgYesNo("Se a baixa do Saldo Vl. LI("+AllTrim(Str(ED4->ED4_VL_LI))+") for confirmado seu valor("+AllTrim(Str(ED4->ED4_VL_LI - nValDolar))+") ficará negativo. Deseja efetuar a baixa ?","Aviso")
            Else
               lRet := .T.
            Endif
         Else
            lRet := .F.
            If !lManutAuto
               MsgInfo("Não será possivel efetuar a baixa do Saldo Vl. LI("+AllTrim(Str(ED4->ED4_VL_LI))+"), pois seu valor("+AllTrim(Str(ED4->ED4_VL_LI - nValDolar))+") ficará negativo.","Aviso")
            Else
               EasyHelp("Não será possivel efetuar a baixa do Saldo Vl. LI("+AllTrim(Str(ED4->ED4_VL_LI))+"), pois seu valor("+AllTrim(Str(ED4->ED4_VL_LI - nValDolar))+") ficará negativo.","Aviso")
            EndIf
            Break
         EndIf
      Else
         lRet := !EasyGParam("MV_ACSLDVL",,.F.)
      EndIf


      ElseIf lDI .And. (ED4->ED4_QT_DI - nQtdEst) < 0
      lRet := .F.
      If lMsg
         If !lManutAuto
            MsgInfo("Não será possivel efetuar a baixa do Saldo Qtd. DI("+AllTrim(Str(ED4->ED4_QT_DI))+"), pois sua quantidade ficará com valor("+AllTrim(Str(ED4->ED4_VL_LI - nQtdEst))+") negativo.","Aviso")
         Else
            EasyHelp("Não será possivel efetuar a baixa do Saldo Qtd. DI("+AllTrim(Str(ED4->ED4_QT_DI))+"), pois sua quantidade ficará com valor("+AllTrim(Str(ED4->ED4_VL_LI - nQtdEst))+") negativo.","Aviso")
         EndIf
      EndIf
      Break


      ElseIf lDI .And.(ED4->ED4_SNCMDI - nQtdNcm) < 0
      lRet := .F.
      If lMsg
         If !lManutAuto
            MsgInfo("Não será possivel efetuar a baixa do Saldo NCM DI("+AllTrim(Str(ED4->ED4_SNCMDI))+"), pois sua quantidade ficará com valor("+AllTrim(Str(ED4->ED4_SNCMDI - nQtdNcm))+") negativo.","Aviso")
         Else
            EasyHelp("Não será possivel efetuar a baixa do Saldo NCM DI("+AllTrim(Str(ED4->ED4_SNCMDI))+"), pois sua quantidade ficará com valor("+AllTrim(Str(ED4->ED4_SNCMDI - nQtdNcm))+") negativo.","Aviso")
         EndIf
      EndIf
      Break

      ElseIf lDI .And.(ED4->ED4_VL_DI - nValDolar) < 0
      If lMsg
         If !EasyGParam("MV_ACSLDVL",,.F.)
            If !lManutAuto
               lRet := MsgYesNo("Se a baixa do Saldo Vl. DI("+AllTrim(Str(ED4->ED4_VL_DI))+") for confirmado seu valor("+AllTrim(Str(ED4->ED4_VL_DI - nValDolar))+") ficará negativo. Deseja efetuar a baixa ?","Aviso")
            Else
               lRet := .T.
            Endif
         Else
            lRet := .F.
            If !lManutAuto
                MsgInfo("Não será possivel efetuar a baixa do Saldo Vl. DI("+AllTrim(Str(ED4->ED4_VL_DI))+"), pois seu valor("+AllTrim(Str(ED4->ED4_VL_DI - nValDolar))+") ficará negativo.","Aviso")
            Else
                EasyHelp("Não será possivel efetuar a baixa do Saldo Vl. DI("+AllTrim(Str(ED4->ED4_VL_DI))+"), pois seu valor("+AllTrim(Str(ED4->ED4_VL_DI - nValDolar))+") ficará negativo.","Aviso")
            EndIf
            Break
         EndIf
      Else
         lRet := !EasyGParam("MV_ACSLDVL",,.F.)
      EndIf

      EndIf

   EndIf

   /*Efetuando a baixa no Ato Concessório*/
   If lRet

      ED4->(RecLock("ED4",.F.))
      
      If cSld == "S" //RRC - 25/06/12 - cSld: Verifica se deve fazer o abatimento do saldo do item

         If lLI
            ED4->ED4_QT_LI -= nQtdEst
            ED4->ED4_VL_LI -= nValDolar
            ED4->ED4_SNCMLI-= nQtdNcm
         EndIf

         If lDI
            ED4->ED4_QT_DI -= nQtdEst
            ED4->ED4_VL_DI -= nValDolar
            ED4->ED4_SNCMDI-= nQtdNcm
         EndIf

      EndIf

      If ED4->(FieldPos("ED4_SNCMEX")) > 0
         ED4->ED4_SNCMEX+= nQtdNcm
      EndIf

      If ED4->(FieldPos("ED4_SQTDEX")) > 0
         ED4->ED4_SQTDEX+= nQtdEst
      EndIf

      ED4->(MsUnlock("ED4"))

      AADD(aRet,{"QTDEST",nQtdEst})
      AADD(aRet,{"QTDNCM",nQtdNcm})
      AADD(aRet,{"VALDOL",nValDolar})
      AADD(aRet,{"UMITEM",cUMItem})  //AOM - 30/11/11

   EndIf


End Sequence

Return IF(Empty(aRet),aRet := Nil, aRet)


*------------------------*
Static Function VldCNPJ()
*------------------------*
Local lRet := .F.

Begin Sequence

   If !Empty(M->ED0_CNPJ1)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ2)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ3)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ4)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ5)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ6)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ7)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ8)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ9)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ10)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ11)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ12)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ13)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ14)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ15)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ16)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ17)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ18)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ19)
      lRet := .T.
      Break
   EndIf

   If !Empty(M->ED0_CNPJ20)
      lRet := .T.
      Break
   EndIf


End Sequence

Return lRet


/*
Funcao     : QryBxInsumos
Parametros : cAto - Ato Concessório
             cPed - Pedido do Ato
Retorno    : lRet
Objetivos  : Efetuar a Query nas tabelas (EDD e EDH) para apresentar a baixa dos insumos no Ato concessório
Autor      : Allan Oliveira Monteiro
Data/Hora  : 29/10/10 - 10:40
*/
*----------------------*
Function QryBxInsumos(cAto,cPed)
*----------------------*
Local cQuery := "", cQuery2 := "" , cCond := "", cCond2 := ""

 /* NOPADO POR AOM - 05/07/2011 - DISTINCT EDD.EDD_SEQSII, EDD.EDD_ITEM, EDD.EDD_PREEMB, EDD.EDD_DTRE, EDD.EDD_QTD, EDD.EDD_HAWB, EDD.EDD_DTREG, EDD.EDD_INVOIC, EDD.EDD_PROD, " +;
          "EDD.EDD_QTD_EX, EDD.EDD_AC, EDD.EDD_PO_NUM, EDD.EDD_POSICA, EDD.EDD_PGI_NU, EDD.EDD_PEDIDO, EDD.EDD_SEQUEN*/
cQuery := "SELECT * FROM "+RetSqlName("EDD")+" EDD "

cCond  := "WHERE EDD.EDD_AC = '" + cAto + "' AND EDD.EDD_PD = '" + cPed + "' AND (EDD.EDD_PREEMB <> '' OR EDD.EDD_PEDIDO <> '') AND EDD.D_E_L_E_T_ <> '*' "
cCond  += " AND (EDD.EDD_SEQSII <> '' "
If AvFlags("SEQMI")
   cCond  += " OR EDD.EDD_SEQMI <> ''"
EndIf
cCond  += ")"

cQuery:=ChangeQuery(cQuery+cCond)

//AOM - 16/03/2012
If Select("QRY") > 0
   QRY->( dbCloseArea() )
Endif

TcQuery cQuery ALIAS "QRY" NEW


TcSetField("QRY","EDD_QTD"   ,"N", AVSX3("EDD_QTD",3)   , AVSX3("EDD_QTD",4)   ) //Quantidade
TcSetField("QRY","EDD_QTD_EX","N", AVSX3("EDD_QTD_EX",3), AVSX3("EDD_QTD_EX",4)) //Quantidade Exportada
TcSetField("QRY","EDD_DTREG" ,"D", AVSX3("EDD_DTREG",3) , AVSX3("EDD_DTREG",4) ) //Data DI
TcSetField("QRY","EDD_DTRE"  ,"D", AVSX3("EDD_DTRE",3)  , AVSX3("EDD_DTRE",4)  ) //Data RE


If ChkFile("EDH")

   cQuery2 := "SELECT DISTINCT EDH.EDH_SEQSIS, EDH.EDH_COD_I, EDH.EDH_TPOCOR, EDH.EDH_CODOCO, EDH.EDH_DTOCOR, EDH.EDH_RESOCO, EDH.EDH_UMPROC, EDH.EDH_QTDOCO, EDH.EDH_VALOCO, "+;
              "EDH.EDH_HAWB, EDH.EDH_DI_NUM, EDH.EDH_DT_DI, EDH.EDH_FORN, EDH.EDH_LOJA, EDH.EDH_INVOIC "

   If AvFlags("SEQMI")
      cQuery2 += ", EDH.EDH_SEQMI "
   EndIf
   cQuery2 += "FROM " + RetSqlName("EDH") + " EDH "

   cCond2  := "WHERE EDH.EDH_AC = '" + cAto +"' AND EDH.D_E_L_E_T_ <> '*'"

   cQuery2:=ChangeQuery(cQuery2+cCond2)

   //AOM - 16/03/2012
   If Select("QRY2") > 0
      QRY2->( dbCloseArea() )
   Endif

   TcQuery cQuery2 ALIAS "QRY2" NEW

   TcSetField("QRY2","EDH_DTOCOR","D", AVSX3("EDH_DTOCOR",3), AVSX3("EDH_DTOCOR",4)) //Data Ocorrencia
   TcSetField("QRY2","EDH_QTDOCO","N", AVSX3("EDH_QTDOCO",3), AVSX3("EDH_QTDOCO",4)) //Quantidade Ocorrencia
   TcSetField("QRY2","EDH_VALOCO","N", AVSX3("EDH_VALOCO",3), AVSX3("EDH_VALOCO",4)) //Valor Ocorrencia
   TcSetField("QRY2","EDH_DT_DI" ,"D", AVSX3("EDH_DT_DI",3) , AVSX3("EDH_DT_DI",4) ) //Data DI

EndIf

Return Nil

/* *********************************************
Funcao     : CalcPPMedio(nOption,lMemor)
Parametros : nOption - Opção do Menu (3=Incluir; 4=Alterar; 5=Estornar; 2=Visualizar)
             lMemor - Indica se o Alias é da tabela (.F.) ou da memória (.T.)
Retorno    : nPP_Medio - Percentual de perda médio dos itens da Work
Objetivos  : Cálculo do percentual de Perda médio
Autor      : Nilson César C. Filho
Data/Hora  : 26/11/2010
***********************************************/
*-----------------------------------------------------*
FUNCTION CalcPPMedio(nOption,lMemor)
*-----------------------------------------------------*

Local nPP_Medio   := 0
Local nQtdexPP    := 0
Local nQtdeTT     := 0
Local aOrdWrkED2  := SaveOrd("WORKED2")
Local nRecAtuED2  := WORKED2->(RECNO())
Local cChaveAgrup := If(lMemor,M->ED2_NCM+M->ED2_ITEM+M->ED2_CAMB,(cAlias)->(ED2_NCM+ED2_ITEM+ED2_CAMB))
WORKED2->(DbSetOrder(8))
WORKED2->(DbGoTop())
WORKED2->(DbSeek(cChaveAgrup))

IF nOption <> ESTORNAR .And. lMemor
   nQtdexPP += M->ED2_QTD * M->ED2_PERCPE
   nQtdeTT  += M->ED2_QTD
ENDIF

DO WHILE !WORKED2->(EOF()) .And. WORKED2->(ED2_NCM+ED2_ITEM+ED2_CAMB) == cChaveAgrup

   IF WORKED2->(RECNO()) == nRecAtuED2
      IF nOption == ESTORNAR
         WORKED2->(DbSkip())
         Loop
      ELSE
         If !EMPTY(WORKED2->ED2_MARCA)
            nQtdexPP += (WORKED2->ED2_QTD * WORKED2->ED2_PERCPE)
            nQtdeTT  +=  WORKED2->ED2_QTD
         EndIf
      ENDIF
   ELSE
      If !EMPTY(WORKED2->ED2_MARCA)
         nQtdexPP += (WORKED2->ED2_QTD * WORKED2->ED2_PERCPE)
         nQtdeTT  +=  WORKED2->ED2_QTD
      EndIf
   ENDIF

   WORKED2->(DbSkip())

ENDDO

RestOrd(aOrdWrkED2,.T.)
nPP_Medio := nQtdexPP/nQtdeTT

Return nPP_Medio


// ********************************************//
// Funcao     : CondOcor()                    //
// Retorno    : lRet                          //
// Objetivos  : Gatilho do campo EDH_PGI_NU   //
// Autor      : Diogo Felipe dos Santos       //
// Data/Hora  : 30/08/2011                    //
// ********************************************//
*--------------------*
Function CondOcor()
*--------------------*

Local lRet := .T.

lRet := !Empty(M->EDH_LI) .And. !Empty(M->EDH_PGI_NU)

Return lRet

/* *********************************************
Funcao     : AC400VImp()
Parametros : --
Retorno    : Nulo
Objetivos  : Validação das Opções de ComboBox
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 31/08/2011
***********************************************/
*-----------------------------------------------------*
FUNCTION AC400VImp()
*-----------------------------------------------------*

oDlgL:aControls[12]:bWhen := {|| If(Left(cTpImp,1) $ "1/3" ,.F.,.T.)}   // Pedido
oDlgL:aControls[2]:bWhen  := {|| If(Left(cTpImp,1) $ "2/3" ,.F.,.T.)}   // DI

If oCbxTipImp:nAt == 1                   // 1 -  Pedido
   cDI := Space(AVSX3("ED2_DI_NUM",3))
ElseIf oCbxTipImp:nAt == 2               // 2 - DI
   cPedido := Space(AVSX3("ED2_PD",3))
Else
   cDI := Space(AVSX3("ED2_DI_NUM",3))
   cPedido := Space(AVSX3("ED2_PD",3))
EndIf

RETURN Nil





/* *********************************************
Funcao     : AC400When()
Parametros : cCampo
Retorno    : lRet
Objetivos  : Efetuar os tratamentos do campo SX3
             When dos campos do Ato
Autor      : Allan Oliveira Monteiro
Data/Hora  : 08/11/2011
***********************************************/
*----------------------------*
Function AC400When(cCampo)
*----------------------------*
Local lRet := .T.

Begin Sequence

   DO CASE

      Case cCampo == 'ED0_TIPINS'

         If (Select("WORKED2") > 0)
             WORKED2->(DbGoTop())
             If WORKED2->(!EOF())
               lRet := .F.
               Break
             EndIf

         EndIf

         If (Select("WORKED4") > 0)
             WORKED4->(DbGoTop())
             If WORKED4->(!EOF())
               lRet := .F.
               Break
             EndIf

         EndIf

   END CASE

End Sequence

Return lRet


/* *********************************************
Funcao     : AtuaWKED2ED4()
Parametros : nOpcao:= 1- Tratamento da WorkED2 2 - Tratamento da WorkED4
             nOption := Numero da folder selecionada
             nOldOption := Numero da folder anterior
             lExec := Executa o tratamento de filtro na Work
Retorno    : -
Objetivos  : Efetuar os tratamentos de tela para aba "Insumos" e "Saldos Insumos"
Autor      : Allan Oliveira Monteiro
Data/Hora  : 09/11/2011
***********************************************/
Static Function AtuaWKED2ED4(nOpcao,nOption,nOldOption,lExec)

Local lExisteCmp := AvFlags("SEQMI")
Local cFiltro := ""
Default lExec := .F.
Default nOption := 1


Begin Sequence


   If Empty(nOldOption)
      If nOption == 1
         nOldOption := 2
      ElseIf nOption == 2
         nOldOption := 1
      EndIf
   EndIf

   //WorkED2
   If nOpcao == 1
                                                           `

      If nOldOption == 1
         oMark3:oBrowse:Hide()
         oMark3:oBrowse:Refresh()
         oMark3A:oBrowse:Show()
         oMark3A:oBrowse:Refresh()
      ElseIf nOldOption == 2
         oMark3A:oBrowse:Hide()
         oMark3A:oBrowse:Refresh()
         oMark3:oBrowse:Show()
         oMark3:oBrowse:Refresh()
      EndIf

      If !lExec .Or. WorkED2->(EasyRecCount()) == 0
         Break
      EndIf

      If !Empty(WorkED2->(DBFilter()))
         WorkED2->(DBCLEARFILTER())
      EndIf

      If nOption == 1

         If lExisteCmp

            cFiltro := "WorkED2->ED2_IMPORT <> 'N'"//Adicina Filtro para importados //.OR. EMPTY(WorkED2->ED2_IMPORT)

            WorkED2->(DBSetFilter({|| &cFiltro}, cFiltro ))

         EndIf

         Eval(oMark3:oBrowse:bGoTop)
         oMark3:oBrowse:Refresh()
         oMark3:oBrowse:Show()


      ElseIf nOption == 2

         If lExisteCmp
            cFiltro := "WorkED2->ED2_IMPORT == 'N' "//Adicina Filtro para importados //.OR. EMPTY(WorkED2->ED2_IMPORT)
         Else
            cFiltro := " 1 == 2 "
         EndIf

         WorkED2->(DBSetFilter({|| &cFiltro}, cFiltro ))

         Eval(oMark3A:oBrowse:bGoTop)
         oMark3A:oBrowse:Refresh()
         oMark3A:oBrowse:Show()


      EndIf


   //WorkED4
   ElseIf nOpcao == 2


      If nOldOption == 1
         oMark4:oBrowse:Hide()
         oMark4:oBrowse:Refresh()
         oMark4A:oBrowse:Show()
         oMark4A:oBrowse:Refresh()
      ElseIf nOldOption == 2
         oMark4A:oBrowse:Hide()
         oMark4A:oBrowse:Refresh()
         oMark4:oBrowse:Show()
         oMark4:oBrowse:Refresh()
      EndIf

      If !lExec .Or. WorkED4->(EasyRecCount()) == 0
         Break
      EndIf

      If !Empty(WorkED4->(DBFilter()))
         WorkED4->(DBCLEARFILTER())
      EndIf
      WorkED4->(DbGoTop())

      If nOption == 1

         If lExisteCmp

            cFiltro := "WorkED4->ED4_IMPORT <> 'N' "//Adicina Filtro para importados //.OR. EMPTY(WorkED4->ED4_IMPORT)

            WorkED4->(DBSetFilter({|| &cFiltro}, cFiltro ))

         EndIf

         Eval(oMark4:oBrowse:bGoTop)
         oMark4:oBrowse:Refresh()
         oMark4:oBrowse:Show()


      ElseIf nOption == 2

         If lExisteCmp
            cFiltro := "WorkED4->ED4_IMPORT == 'N' "//Adicina Filtro para importados
         Else
            cFiltro := " 1 == 2 "
         EndIf

         WorkED4->(DBSetFilter({|| &cFiltro}, cFiltro ))

         Eval(oMark4A:oBrowse:bGoTop)
         oMark4A:oBrowse:Refresh()
         oMark4A:oBrowse:Show()

      EndIf


   EndIf
End Sequence

Return
/*
Funcao     : AC400AltSeq()
Parametros : cCampo - Campo Siscomex
Retorno    : .T.
Objetivos  : Permitir alteração da Sequencia SISCOMEX
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 08/10/2012 : 15:09
*/
*-----------------------------*
Function AC400AltSeq(cCampo)
*-----------------------------*
Local lGrava := .F.
Local bOk := {|| lGrava := .T.,oDlg:End()}
Local bCancel := {|| oDlg:End()}
Local oPanel

   DEFINE MSDIALOG oDlg TITLE STR0431 FROM 150, 100 TO 280, 600 Of oMainWnd pixel //"Alteração de Sequência"

      oPanel:=TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 0, 0)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @/*24*/18,6 SAY STR0432 PIXEL OF oPanel   //"Informe a Sequência SISCOMEX"   // GFP - 09/10/2012
      @/*24*/18,90 MSGET &(cCampo) SIZE 55,8 RIGHT PIXEL OF oPanel                 // GFP - 09/10/2012

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,,,,,,.F.))

Return .T.

/*
Função.....: RetUltSeqIt()
Parâmetros.: cAlias - Alias utilizado como referencia para buscar a sequencia do item.
             cKey   - Chave para buscar a ultima sequencia do item
Autor......: Allan Oliveira Monteiro(AOM)
Data/Hora..: 23/03/12 - 10:15
Objetivo...: Função para buscar a ultima sequencia do item para um pedido de Drawback
*/
*----------------------------------------*
Function RetUltSeqIt(cAlias, cKey)
*----------------------------------------*
Local nOrdAnt, nRecWkED2
Default cAlias := "WorkED2"

nOrdAnt  := (cAlias)->(IndexOrd())
nRecWkED2:= (cAlias)->(Recno())
(cAlias)->(DbSetOrder(9))//ED2_PD + ED2_SEQIT
If cAlias == "WorkED2"
   (cAlias)->(DbGoBottom())
Else
   (cAlias)->(AVSeekLast(xFilial("ED2")+cKey))
EndIf
cSeqIt := SomaIt((cAlias)->ED2_SEQIT)
(cAlias)->(DbSetOrder(nOrdAnt))
If nRecWkED2 > 0
   (cAlias)->(DbGoTo(nRecWkED2))
EndIf

Return cSeqIt

/*
Função.....: GrvApDIOri()
Parâmetros.: Nenhum
Autor......: Allan Oliveira Monteiro(AOM)
Data/Hora..: 26/03/12 - 9:15
Objetivo...: Funçao principal para verificar os itens a importar que necessitam
             serem quebrados atraves das DI`s Originais.
*/
*--------------------*
Function GrvApDIOri()
*--------------------*
Local nOrdAnt, nRecWkED2, i, nRecWkED2a
Local aDIChave
Local aDadosED2 := {} , aRetDI := {}
Local lRet := .T.


nOrdAnt  := WorkED2->(IndexOrd())
nRecWkED2:= WorkED2->(Recno())
WorkED2->(DbSetOrder(9))//ED2_PD + ED2_SEQIT


WorkED2->(DbGoTop())
While WorkED2->(!EOF())

   nRecWkED2a := WorkED2->(Recno())
   If !Empty(WorkED2->ED2_DI_ORI)
      WorkED2->(DbSkip())
      Loop
   EndIf
   WorkED2->ED2_SLDANT := WorkED2->ED2_QTDNCM

   //Função que busca as chaves das DI`s anteriores
   aRetDI   := AC400FindKeyDI()
   lRet     := aRetDI[1][1]
   aDIChave := aRetDI[1][2]

   If !lRet
      Exit
   EndIf

   //Se nao tiver preenchido as proprias DI`s e adicoes sao originais
   If Empty(aDIChave)
      WorkED2->ED2_DI_ORI := WorkED2->ED2_DI_NUM
      WorkED2->ED2_ADANT  := WorkED2->ED2_ADICAO
   Else
      For i := 1 To WorkED2->(FCount())
         AADD(aDadosED2,WorkED2->&(FieldName(i)) )
      Next i
      //Atualiza DI`s, Adicoes e Saldos / Se Necessario efetua as Quebras
      AC400DIOri(aDIChave,"WorkED2",aDadosED2)
   EndIf

   WorkED2->(DbGoto(nRecWkED2a))

WorkED2->(DbSkip())
EndDo

WorkED2->(DbSetOrder(nOrdAnt))
WorkED2->(DbGoto(nRecWkED2))

Return

/*
Função.....: AC400FindKeyDI()
Parâmetros.: cAlias   - Alias utilizado como referencia para buscar as chaves das DI`s Originais.
             lTela    - Indica se foi uma alteraçao pela rotina de manutenção(.T.) ou por update(.F.).
Autor......: Allan Oliveira Monteiro(AOM)
Data/Hora..: 23/03/12 - 16:35
Objetivo...: Busca todas as chaves das DI`s originais referente a um item a importar
*/
*-------------------------------------------------------------------------------------------------------------------*
Function AC400FindKeyDI(cAlias, lTela)
*-------------------------------------------------------------------------------------------------------------------*
Local aChaveAnt := {} ,aOrd := {} , aRet := {}
Local lImport := .F. , lDIExt := .F. , lMercInt := .F.
Local nRecED2 , nRecED4, nRecED0, nRecED8, nRecSW8
Local nQtdNCM,  nSaldo
Local cUMNCM, cHawb, cInvoice, cPoNum, cPosicao, cPgiNum, cDiNum, cPedido, cSeqIt, cAdicao
Local bPosItem, bPosItED4
Local lRet := .T. , lIncSldAnt := .T.


Local nSldED2Ant, nQtdED2Ant, nQtdVinc, nQtdVincAnt
Local nPos := 0

Default cAlias:= "WorkED2"
Default lTela := .T.


nQtdNCM := (cAlias)->ED2_QTDNCM
cUMNCM  := (cAlias)->ED2_UMNCM
cHawb   := (cAlias)->ED2_HAWB
cInvoice:= (cAlias)->ED2_INVOIC
cPoNum  := (cAlias)->ED2_PO_NUM
cPosicao:= (cAlias)->ED2_POSICA
cPgiNum := (cAlias)->ED2_PGI_NU
cDiNum  := (cAlias)->ED2_DI_NUM
cPedido := (cAlias)->ED2_PD
cSeqIt  := (cAlias)->ED2_SEQIT
cAdicao := (cAlias)->ED2_ADICAO

If !Empty(cHawb) .And. !Empty(cPoNum)
   lImport := .T.
   SW8->(DbSetOrder(6))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
   ED4->(DbSetOrder(2))//ED4_FILIAL+ED4_AC+ED4_SEQSIS
   bPosItem := {|| SW8->(DbSeek(xFilial("SW8") + AVKEY(cHawb,"W8_HAWB") + AVKEY(cInvoice,"W8_INVOICE") + AVKEY(cPoNum,"W8_PO_NUM") + AVKEY(cPosicao,"W8_POSICAO") + AVKEY(cPgiNum,"W8_PGI_NUM"))) .And. !Empty(SW8->W8_AC) }
   bPosItED4:= {|| ED4->(DbSeek(xFilial("ED4") + SW8->W8_AC + SW8->W8_SEQSIS)) }
ElseIf Empty(cPoNum) .And. !Empty(cDiNum)
   lDIExt := .T.
   ED8->(DbSetOrder(4))//ED8_FILIAL+ED8_DI_NUM+ED8_ADICAO+ED8_POSDI
   ED4->(DbSetOrder(2))//ED4_FILIAL+ED4_AC+ED4_SEQSIS
   bPosItem := {|| ED8->(DbSeek(xFilial("ED8") + AVKEY(cDiNum,"ED8_DI_NUM") + AVKEY(cAdicao,"ED8_ADICAO") + AVKEY(cPosicao,"ED8_POSDI"))) .And. !Empty(ED8->ED8_AC) }
   bPosItED4:= {|| ED4->(DbSeek(xFilial("ED4") + ED8->ED8_AC + ED8->ED8_SEQSIS)) }
ElseIf !Empty(cPoNum) .And. !Empty(cPosicao)
   lMercInt := .T.
   ED8->(DbSetOrder(5))//ED8_FILIAL+ED8_PEDIDO+ED8_POSDI
   ED4->(DbSetOrder(8))//ED4_FILIAL+ED4_AC+ED4_SEQMI
   bPosItem := {|| ED8->(DbSeek(xFilial("ED8") + AVKEY(cPedido,"ED8_PEDIDO") + AVKEY(cPosicao,"ED8_POSDI"))) .And. !Empty(ED8->ED8_AC) }
   bPosItED4:= {|| ED4->(DbSeek(xFilial("ED4") + ED8->ED8_AC + ED8->ED8_SEQMI)) }
Else
   AADD(aRet,{lRet,aChaveAnt})
   Return aRet
EndIf

aOrd    := SaveOrd({"ED2","ED0","ED4","ED8","SW8"})

If Select("ED2") > 0
   nRecED2 := ED2->(Recno())
EndIf

If Select("ED4") > 0
   nRecED4 := ED4->(Recno())
EndIf

If Select("ED0") > 0
   nRecED0 := ED0->(Recno())
EndIf

If Select("ED8") > 0
   nRecED8 := ED8->(Recno())
EndIf

If Select("SW8") > 0
   nRecSW8 := SW8->(Recno())
EndIf


Begin Sequence

If Type("aSldDIAnt") <> "A"
   aSldDIAnt:= {}
EndIf

If Eval(bPosItem)
   If Eval(bPosItED4)
      /*
         nopado por RNLP 24/09/2020 - Função não compilada - trecho não utilizado no código
      If  Type("aPedDraw") == "A"  .And. FindFunction("ProcessED2")
         ProcessED2(ED4->ED4_PD)
      EndIf
      */
      ED2->(DbSetOrder(1))//ED2_FILIAL+ED2_PD+ED2_ITEM+ED2_SEQ
      If ED2->(DbSeek(xFilial("ED2") + ED4->ED4_PD + ED4->ED4_ITEM))
         ED0->(DbSetOrder(1))//ED0_FILIAL+ED0_PD
         IF ED0->(DbSeek(xFilial("ED0") + ED2->ED2_PD)) .And. !SoftLock("ED0")
            MsgInfo("O Pedido: " + ED2->ED2_PD + "esta sendo alterado por outro usuario, não será possivel localizar a DI Anterior.","Atenção")
            lRet := .f.
            Break
         EndIf
         nSaldo := nQtdNCM
         While ED2->(!EOF()) .And. ED2->ED2_FILIAL == ED4->ED4_FILIAL .And. ED2->ED2_PD == ED4->ED4_PD .AND. ;
                                   ED2->ED2_ITEM = ED4->ED4_ITEM .AND. nSaldo > 0

            IF ED2->ED2_NCM == ED4->ED4_NCM .And. ED2->ED2_CAMB == ED4->ED4_CAMB .And. ;
               IIF(ED0->(FIELDPOS("ED0_PERCPE")) # 0  .And. ED0->ED0_PERCPE <> "2", Str(ED2->ED2_PERCPE,5,2) == Str(ED4->ED4_PERCPE,5,2), .T.) .And. ;
               IIF(ED2->(FIELDPOS("ED2_UMANEX")) # 0 .And. !Empty(ED2->ED2_UMANEX),ED2->ED2_UMANEX, ED2->ED2_UMNCM) == ED4->ED4_UMNCM


               If ED2->ED2_PD == "SAFETY_WALK2 " .And. ED2->ED2_SEQIT == "00028"
                  MsgInfo(ED2->ED2_SEQANT)
               EndIf

               nSldED2Ant := ED2->ED2_SLDANT


               //Tratamento feito ao gravar a WorkED2 e verifica os saldos de acordo com a workED2
               If lTela
                  If (nPos := ASCAN(aSldDIAnt,{|X| X[1] == ED2->ED2_PD .And. X[2] == ED2->ED2_SEQIT })) > 0
                     nSldED2Ant += aSldDIAnt[nPos][7]
                     If nSldED2Ant <= 0
                        ED2->(DbSkip())
                        Loop
                     EndIf
                  EndIf
               EndIf



               IF cUMNCM <> ED2->ED2_UMNCM
                  nQtdED2Ant := nSldED2Ant * IF(lImport,SW8->(W8_QTDE/W8_QT_AC2),ED8->(ED8_QTD/ED8_QT_AC2))
                  nQtdVinc   := Min(nSaldo,nQtdED2Ant)
                  nQtdVincAnt:= nQtdVinc * IF(lImport,SW8->(W8_QT_AC2/W8_QTDE),ED8->(ED8_QT_AC2/ED8_QTD))
                  nSaldo     -= nQtdVinc
               Else
                  nQtdVinc   := Min(nSaldo,nSldED2Ant)
                  nQtdVincAnt:= nQtdVinc
                  nSaldo     -= nQtdVinc
               EndIf

               If nQtdVinc > 0 //Pedido Drawback atual ,Seq. Atual, Pedido Drawback Anterior,Seq. Anterior  , Qtd. NCM Atual , UM. Atual ,Qtd. NCM Anterior                   ,UM. Anterior     , Recno  Anterior
                  aAdd(aChaveAnt,{cPedido              , cSeqIt   ,ED2->ED2_PD              , ED2->ED2_SEQIT, nQtdVinc       ,cUmNCM     ,nQtdVincAnt                         , ED2->ED2_UMNCM  , ED2->(Recno())})
               EndIf

               //Adiciona o saldos no array de controle
               If lTela .And. nQtdVinc > 0
                  If nPos > 0
                     aSldDIAnt[nPos][7] -= nQtdVincAnt
                  Else
                                  // Pedido Drawback Anterior ,Seq. Anterior  ,Qtd. NCM Anterior                   , Recno  Anterior
                     AADD(aSldDIAnt,{ED2->ED2_PD              , ED2->ED2_SEQIT,-nQtdVincAnt                        , ED2->(Recno())  })
                  EndIf
               EndIf

            EndIf

            ED2->(DbSkip())
         EndDo

         //Adiciona um Array em com dados anteriores em branco pois nao haverá DI original para o item
         If nSaldo > 0.0001
                        //Pedido Drawback atual ,Seq. Atual, Pedido Drawback Anterior,Seq. Anterior  , Qtd. NCM Atual , UM. Atual ,Qtd. NCM Anterior                   ,UM. Anterior     , Recno  Anterior
           aAdd(aChaveAnt,{cPedido              , cSeqIt   ,""                       , ""            , nSaldo         ,cUmNCM     ,0                                   ,""               , 0               })
         EndIf
      EndIf
   EndIf
EndIf

End Sequence

AADD(aRet,{lRet,aChaveAnt})
RestOrd(aOrd)


If Select("ED2") > 0
   ED2->(DbGoto(nRecED2))
EndIf

If Select("ED4") > 0
   ED4->(DbGoto(nRecED4))
EndIf

If Select("ED0") > 0
   ED0->(DbGoto(nRecED0))
EndIf

If Select("ED8") > 0
   ED8->(DbGoto(nRecED8))
EndIf

If Select("SW8") > 0
   SW8->(DbGoto(nRecSW8))
EndIf


Return aRet

/*
Função.....: VoltaSldDIAnt()
Parâmetros.: cAlias - Alias
Autor......: Allan Oliveira Monteiro(AOM)
Data/Hora..: 23/03/12 - 13:15
Objetivo...: Funçao para voltar o saldo do item anterior quando um item associado a uma DI Original for deletado.
*/
*-----------------------------*
Function VoltaSldDIAnt(cAlias)
*-----------------------------*
Local lImport := .F. , lDIExt := .F. , lMercInt := .F.
Local nRecED2 , aOrd , nRecED0
Local nQtdNCM, cUMNCM, cHawb, cInvoice, cPoNum, cPosicao, cPgiNum, cDiNum, cPedido, cSeqIt, cAdicao , nQtdSld ,cPedAnt, cSeqAnt

Local nPos := 0
Local bPosItem
Local lRet := .T.

Default cAlias := "ED2"

nQtdNCM := (cAlias)->ED2_QTDNCM
cUMNCM  := (cAlias)->ED2_UMNCM
cHawb   := (cAlias)->ED2_HAWB
cInvoice:= (cAlias)->ED2_INVOIC
cPoNum  := (cAlias)->ED2_PO_NUM
cPosicao:= (cAlias)->ED2_POSICA
cPgiNum := (cAlias)->ED2_PGI_NU
cDiNum  := (cAlias)->ED2_DI_NUM
cPedido := (cAlias)->ED2_PD
cSeqIt  := (cAlias)->ED2_SEQIT
cAdicao := (cAlias)->ED2_ADICAO
cPedAnt := (cAlias)->ED2_PDANT
cSeqAnt := (cAlias)->ED2_SEQANT

If !Empty(cHawb) .And. !Empty(cPoNum)
   lImport := .T.
   SW8->(DbSetOrder(6))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
   bPosItem := {|| SW8->(DbSeek(xFilial("SW8") + AVKEY(cHawb,"W8_HAWB") + AVKEY(cInvoice,"W8_INVOICE") + AVKEY(cPoNum,"W8_PO_NUM") + AVKEY(cPosicao,"W8_POSICAO") + AVKEY(cPgiNum,"W8_PGI_NUM"))) .And. !Empty(SW8->W8_AC) }
ElseIf Empty(cPoNum) .And. !Empty(cDiNum)
   lDIExt := .T.
   ED8->(DbSetOrder(4))//ED8_FILIAL+ED8_DI_NUM+ED8_ADICAO+ED8_POSDI
   bPosItem := {|| ED8->(DbSeek(xFilial("ED8") + AVKEY(cDiNum,"ED8_DI_NUM") + AVKEY(cAdicao,"ED8_ADICAO") + AVKEY(cPosicao,"ED8_POSDI"))) .And. !Empty(ED8->ED8_AC) }
Else
   lMercInt := .T.
   ED8->(DbSetOrder(5))//ED8_FILIAL+ED8_PEDIDO+ED8_POSDI
   bPosItem := {|| ED8->(DbSeek(xFilial("ED8") + AVKEY(cPedido,"ED8_PEDIDO") + AVKEY(cPosicao,"ED8_POSDI"))) .And. !Empty(ED8->ED8_AC) }
EndIf

If Select("ED2") > 0
   nRecED2 := ED2->(Recno())
EndIf

If Select("ED0") > 0
   nRecED0 := ED0->(Recno())
EndIf

aOrd    := SaveOrd({"ED2","ED0"})

Begin Sequence

If Eval(bPosItem)
   ED2->(DbSetOrder(9))//ED2_FILIAL+ED2_PD+ED2_SEQIT
      If ED2->(DbSeek(xFilial("ED2") + cPedAnt + cSeqAnt))
         ED0->(DbSetOrder(1))//ED0_FILIAL+ED0_PD
         IF cAlias == "ED2" .And. ED0->(DbSeek(xFilial("ED0") + ED2->ED2_PD)) .And. !SoftLock("ED0")
            MsgInfo("O Pedido: " + ED2->ED2_PD + "esta sendo alterado por outro usuario, não será possivel localizar a DI Anterior. A Gravação do Ato nao será realizada.","Atenção")
            lRet := .f.
            Break
         EndIf

         IF cUMNCM <> ED2->ED2_UMNCM
            nQtdSld := nQtdNCM * IF(lImport,SW8->(W8_QT_AC2/W8_QTDE),ED8->(ED8_QT_AC2/ED8_QTD))
         Else
            nQtdSld := nQtdNCM
         EndIf

         If Type("aSldDIAnt") == "A"
            If (nPos := ASCAN(aSldDIAnt,{|X| X[1] == ED2->ED2_PD .And. X[2] == ED2->ED2_SEQIT})) == 0

                             // Pedido Drawback Anterior ,Seq. Anterior   ,Qtd. NCM Anterior   , Recno  Anterior
               AADD(aSldDIAnt, {ED2->ED2_PD              , ED2->ED2_SEQIT ,nQtdSld             , ED2->(Recno())  })

            Else
               aSldDIAnt[nPos][3] += nQtdSld
               If aSldDIAnt[nPos][3] == 0
                  aDel(aSldDIAnt,nPos)
                  aSize(aSldDIAnt, Len(aSldDIAnt) - 1)
               EndIf
            EndIf
         EndIf
      EndIf
EndIf

End Sequence

RestOrd(aOrd)

If Select("ED2") > 0
   ED2->(DbGoto(nRecED2))
EndIf

If Select("ED2") > 0
   ED0->(DbGoto(nRecED0))
EndIf


Return lRet


/*
Função.....: AC400DIOri()
Parâmetros.: aChaveDI - Array com todas as chaves de DI`s anteriores associadas
             cAlias   - Alias utilizado para gravação das DI`s e adicoes
             aDadosED2- Dados do item anterior
Autor......: Allan Oliveira Monteiro(AOM)
Data/Hora..: 23/03/12 - 13:15
Objetivo...: Executar a gravação das DI`s e adiçoes, efetuar a quebra dos itens de acordo com Array de Chaves de DI
*/
*----------------------------------------------------*
Function AC400DIOri(aChaveDI,cAlias,aDadosED2)
*----------------------------------------------------*
Local i,j
Local nCoef := 0 , nQtdNCMTot
Local lSeek
Local aOrd    := SaveOrd({"ED2"})
Local aAtuCampos := {"ED2_QTD"   ,"ED2_QTDNCM",;
                     "ED2_VALORI","ED2_QTDORI",;
                     "ED2_VL_MOE","ED2_PESO"  ,"ED2_FRETE" ,;
                     "ED2_FR_USS","ED2_SEGURO","ED2_SE_USS",;
                     "ED2_VALEMB"}
Local aDiOri := {}
Default cAlias := "WorkED2"
Default aDadosED2 := {}

If ED2->(FieldPos("ED2_VALCAL")) > 0
   AADD(aAtuCampos,"ED2_VALCAL")
EndIf

If ED2->(FieldPos("ED2_QTDCAL")) > 0
   AADD(aAtuCampos,"ED2_QTDCAL")
EndIf

//Inicializa a quantidade total para efetuar o coeficiente corretamente
nQtdNCMTot := (cAlias)->ED2_QTDNCM

For i := 1 To Len(aChaveDI)

  //Atualiza saldos das DI`s Originais anteriores
  If cAlias == "ED2" .And. aChaveDI[i][9] <> 0
     AtuSldDIAnt(-aChaveDI[i][7],aChaveDI[i][9])
  EndIf


  nCoef := aChaveDI[i][5] / nQtdNCMTot
  lSeek := i > 1
  If (cAlias)->(RecLock(cAlias,lSeek))
     If lSeek
        For j := 1 To (cAlias)->(FCount())
           (cAlias)->(FieldPut(j, aDadosED2[j]))
        Next j
        (cAlias)->ED2_SEQIT := RetUltSeqIt(cAlias,(cAlias)->ED2_PD)
     EndIf
     If nCoef < 1
        AC400PropAtu(cAlias,nCoef,aAtuCampos)
     EndIf


     (cAlias)->ED2_PDANT  := aChaveDI[i][3]
     (cAlias)->ED2_SEQANT := aChaveDI[i][4]
     If aChaveDI[i][9] <> 0
        aDiOri := BuscDIOri(aChaveDI[i][9])
        (cAlias)->ED2_SLDANT := aChaveDI[i][5]
        (cAlias)->ED2_DI_ORI := aDiOri[1][1]
        (cAlias)->ED2_ADANT  := aDiOri[1][2]
     Else
        (cAlias)->ED2_DI_ORI := ""
        (cAlias)->ED2_ADANT  := ""
        (cAlias)->ED2_SLDANT := 0
     EndIf

     (cAlias)->(MsUnLock())
  EndIf
Next i

//Inicializa o vetor
aDadosED2 := {}

RestOrd(aOrd)

Return


/*
Função.....: BuscDIOri()
Parâmetros.: nRecAnt - Recno do item a importar anterior
Autor......: Allan Oliveira Monteiro(AOM)
Data/Hora..: 23/03/12 - 11:00
Objetivo...: Buscar a DI original percorrendo o caminho através dos itens associados
*/
*---------------------------------*
Function BuscDIOri(nRecAnt)
*---------------------------------*
Local cPedAnt , cSeqAnt, nRec
Local aChaveDI := {}
Local aOrd := SaveOrd({"ED2"})

nRec := ED2->(Recno())
ED2->(DbGoTo(nRecAnt))
cPedAnt := ED2->ED2_PDANT
cSeqAnt := ED2->ED2_SEQANT
ED2->(DbSetOrder(9))

While !Empty(cPedAnt) .And. !Empty(cSeqAnt)
   If ED2->(DbSeek(xFilial("ED2") + cPedAnt + cSeqAnt))
      cPedAnt := ED2->ED2_PDANT
      cSeqAnt := ED2->ED2_SEQANT
   EndIf
EndDo

AADD(aChaveDI,{ED2->ED2_DI_NUM,ED2->ED2_ADICAO})

RestOrd(aOrd)
ED2->(DbGoTo(nRec))

Return aChaveDI


/*
Função.....: AC400IsenED2()
Parâmetros.: nRecAnt - Recno do item a importar anterior
Autor......: Allan Oliveira Monteiro(AOM)
Data/Hora..: 26/03/12 - 17:00
Objetivo...: Retira campos do array de visualizaçao de um enchoice
*/
*---------------------------------*
Function AC400IsenED2(aArray,aDel)
*---------------------------------*
Local i,nPos

For i:= 1 To Len(aDel)

   IF (nPos := ASCAN(aArray, {|x|  x == aDel[i] })) > 0
      ADEL(aArray,nPos)
      aSize(aArray, Len(aArray) - 1)
   EndIf

Next i

Return aArray


/*
Função.....: AtuSldDIAnt()
Parâmetros.: nSldAnt - Quantidade a ser abatida do Saldo
             nRecED2 - Recno do item a importar
Autor......: Allan Oliveira Monteiro(AOM)
Data/Hora..: 26/03/12 - 18:00
Objetivo...: Atualiza o saldo anterior do item a importar
*/
*-------------------------------------------*
Function AtuSldDIAnt(nSldAnt,nRecED2)
*-------------------------------------------*
Local nRec := 0

nRec := ED2->(Recno())
ED2->(DbGoTo(nRecED2))
If ED2->(RecLock("ED2",.F.))
  ED2->ED2_SLDANT += nSldAnt
  ED2->(MsUnlock())
EndIf
ED2->(DbGoTo(nRec))


Return


/*
Função.....: AC400MultiFil()
Parâmetros.:
Autor......: Wilsimar Fabricio Silva - WFS
Data/Hora..: 10/12/13
Objetivo...: Verificar se o ambiente está preparado/ configurado para tratamento multi filial
*/
Function AC400MultiFil()
Local lRet:= .F.

Begin Sequence

	lRet:= VerSenha(115)  ;
            .And.  FWModeAccess("ED1",3) == "C" ;
            .And.  FWModeAccess("ED2",3) == "C" ;
            .And.  FWModeAccess("EDD",3) == "C" ;
            .And.  FWModeAccess("EE9",3) == "E" ;
            .And.  FWModeAccess("SW8",3) == "E" ;
            .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
            .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
            .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
            .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0

End Sequence

Return lRet

/*
Função.....: OpcReapuraInsumo()
Parâmetros.:
Autor......: Wilsimar Fabricio Silva - WFS
Data/Hora..: dez/2015
Objetivo...: Tela de opção de reapuração dos insumos (suspensão)
*/
Static Function OpcReapuraInsumo()
Local oDlgOpc, oPanel, oCmb
Local bOk    := {|| lOk:= .T., oDlgOpc:End()}
Local bCancel:= {|| oDlgOpc:End()}
Local lOk:= .F.

Begin Sequence

   Define MsDialog oDlgOpc Title STR0436 From 10, 0 To 20, 85 Of oMainWnd //Atualização dos Insumos

      oPanel:= TPanel():New(0, 0, "", oDlgOpc,, .F., .F.,,, 0, 0)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 18, 020 Say STR0437  Of oPanel Pixel //Atualizar insumos considerando:
      @ 14, 120 MsComboBox oCmb Var cEstru Items {STR0438,; //"1 - Estrutura do ato concessório"
      	                                           STR0439,; //"2 - Cadastro de estruturas"
      	                                           STR0440} Size 100, 180 Of oPanel Pixel //"3 - Não atualizar"

   Activate MsDialog oDlgOpc on Init EnchoiceBar(oDlgOpc, bOk , bCancel,,,,,,,.F.) Centered

   If lOk
      cEstru:= Left(cEstru, 1)
      If cEstru == "2" .And. !SG1->(DBSeek(cFilSG1 + M->ED1_PROD))
         lOk:= .F.
         MsgStop(STR0442, STR0262) //"O cadastro de estruturas para este produto não foi encontrato na filial corrente."
      EndIf
   Else
      cEstru:= "3"
   EndIf


End Sequence

Return lOk

/*
Função.....: ReapurarInsumo()
Parâmetros.: cEstru - por qual estrutura ocorrerá a atualização dos insumos necessário no ato concessório
             nQtdOriExport - quantidade original a exportar
Autor......: Wilsimar Fabricio Silva - WFS
Data/Hora..: dez/2015
Objetivo...: Reapura o saldo do insumo com base no cadastro de estruturas
Revisão....: nov/2018 - inclusão dos parâmetros cEstru e nQtdOriExport para atualização do resumo técnico na gravação do estorno
*/
Static Function ReapurarInsumo(cEstru, nQtdOriExport)
Local cFileEstru

Begin Sequence

   nEstru:= 0 //Usado na Função AvEstrut2
   cFileEstru:= AVEstrut2(WorkED1->ED1_PROD, WorkED1->ED1_QTD, "WorkEstru",,,lIntegra) //Estrutura com base na SG1

   aRecDel := aClone( GetRcDlED2(WorkED1->ED1_PROD,WorkED1->ED1_SEQ) )

   //EstWorkED2(WorkED1->ED1_PROD,WorkED1->ED1_SEQ,.T.) //estornar a estrutura
   AtuWorkED2(WorkED1->ED1_QTD,M->ED1_VAL_EM - M->ED1_VALCOM) // recriar a estrutura
   EstWorkED2(WorkED1->ED1_PROD,WorkED1->ED1_SEQ,.T.,aRecDel, cEstru, nQtdOriExport) //estornar a estrutura  //NCF - 30/06/2016 - Movida para baixo para estornar registro após atualização da estrutura

   AvFimEstrut2("WorkEstru", cFileEstru)

   WorkEDC->(DBGoTop())
End Sequence

Return

/*
Função.....: GetRcDlED2()
Parâmetros.:
Autor......: Nilson César C. Filho - NCF
Data/Hora..: dez/2015
Objetivo...: Retornar array com registros que serão deletados pela função EstWorkED2
*/
Function GetRcDlED2(cProd,cSeq)
Local aRecDelWED2 := {}

   WorkED2->(dbSetOrder(2))
   If WorkED2->(dbSeek(cProd+cSeq))
      Do While cProd==WorkED2->ED2_PROD .and. cSeq=WorkED2->ED2_SEQ
         aAdd(aRecDelWED2, WorkED2->(RecNo()) )
         WorkED2->(dbSkip())
      EndDo
   EndIf
   WorkED2->(dbSetOrder(1))

Return aRecDelWED2


/*
Função      : FilterBaixaInsumos(cAlias, oDlgFld)
Parametros  : cAlias - Work onde o filtro será aplicado.
              oDlgFld - Tela onde a interface será inserida.
Retorno     : cFilter - Filtro montado pelo usuário.
Objetivos   : Exibir tela para montagem de filtro.
Autor       : wfs
Data/Hora   : nov/2018
*/
Static Function FilterBaixaInsumos(cAlias, oDlgFld)
Local aCampos:= {}
Local cFiltro:= ""
Local cExpFiltro:= ""
Local nCont

   /* Campos que serão exibidos no filtro
   aAdd(aCampos, {Campo  ,  Titulo                        ,Usado, Ordem, Tamanho                        , Picture                        , Tipo                        , Decimal) }) */
   AAdd(aCampos,{"SEQSII", "Sequencia de Saldo Importação", .T. ,      , AvSx3("EDD_SEQSII", AV_TAMANHO), AvSx3("EDD_SEQSII", AV_PICTURE), AvSx3("EDD_SEQSII", AV_TIPO), AvSx3("EDD_SEQSII", AV_DECIMAL)})
   AAdd(aCampos,{"SEQMI" , "Sequencia Mercado Interno"    , .T. ,      , AvSx3("EDD_SEQMI", AV_TAMANHO) , AvSx3("EDD_SEQMI", AV_PICTURE) , AvSx3("EDD_SEQMI", AV_TIPO) , AvSx3("EDD_SEQMI", AV_DECIMAL)})
   AAdd(aCampos,{"ITEM"  , "Código do Item"               , .T. ,      , AvSx3("EDD_ITEM", AV_TAMANHO)  , AvSx3("EDD_ITEM", AV_PICTURE)  , AvSx3("EDD_ITEM", AV_TIPO)  , AvSx3("EDD_ITEM", AV_DECIMAL)})
   AAdd(aCampos,{"SEQMI" , "Tipo de Ocorrência"           , .T. ,      , 30                             , ""                             , "C"                         , 0})
   AAdd(aCampos,{"CODOCO", "Cód. Ocorrência"              , .T. ,      , AvSx3("EDD_PREEMB", AV_TAMANHO), ""                             , AvSx3("EDD_PREEMB", AV_TIPO), AvSx3("EDD_PREEMB", AV_DECIMAL)})
   AAdd(aCampos,{"DTOCOR", "Data Ocorrência"              , .T. ,      , AvSx3("EDD_DTRE", AV_TAMANHO)  , AvSx3("EDD_DTRE", AV_PICTURE)  , AvSx3("EDD_DTRE", AV_TIPO)  , AvSx3("EDD_DTRE", AV_DECIMAL)})
   AAdd(aCampos,{"RESOCO", "Resumo da Ocorrência"         , .T. ,      , 60                             , ""                             , "C"                         , 0})
   AAdd(aCampos,{"UNIDME", "Unidade de Medida"            , .T. ,      , AvSx3("ED4_UMITEM", AV_TAMANHO), AvSx3("ED4_UMITEM", AV_PICTURE), AvSx3("ED4_UMITEM", AV_TIPO), AvSx3("ED4_UMITEM", AV_DECIMAL)})
   AAdd(aCampos,{"QTD"   , "Quantidade Envolvida"         , .T. ,      , AvSx3("EDD_QTD", AV_TAMANHO)   , AvSx3("EDD_QTD", AV_PICTURE)   , AvSx3("EDD_QTD", AV_TIPO)   , AvSx3("EDD_QTD", AV_DECIMAL)})
   AAdd(aCampos,{"VALOR" , "Valor Envolvido US$"          , .T. ,      , AvSx3("W8_VL_AC", AV_TAMANHO)  , AvSx3("W8_VL_AC", AV_PICTURE)  , AvSx3("W8_VL_AC", AV_TIPO)  , AvSx3("W8_VL_AC", AV_DECIMAL)})
   AAdd(aCampos,{"HAWB"  , "Número do Processo Importação", .T. ,      , AvSx3("EDD_HAWB", AV_TAMANHO)  , ""                             , AvSx3("EDD_HAWB", AV_TIPO)  , AvSx3("EDD_HAWB", AV_DECIMAL)})
   AAdd(aCampos,{"NRDI"  , "Número da DI"                 , .T. ,      , AvSx3("W6_DI_NUM", AV_TAMANHO) , ""                             , AvSx3("W6_DI_NUM", AV_TIPO) , AvSx3("W6_DI_NUM", AV_DECIMAL)})
   AAdd(aCampos,{"DTDI"  , "Data da DI"                   , .T. ,      , AvSx3("EDD_DTREG", AV_TAMANHO) , AvSx3("EDD_DTREG", AV_PICTURE) , AvSx3("EDD_DTREG", AV_TIPO) , AvSx3("EDD_DTREG", AV_DECIMAL)})
   AAdd(aCampos,{"CDFORN", "Código do Fornecedor"         , .T. ,      , AvSx3("W8_FORN", AV_TAMANHO)   , AvSx3("W8_FORN", AV_PICTURE)   , AvSx3("W8_FORN", AV_TIPO)   , AvSx3("W8_FORN", AV_DECIMAL)})
   AAdd(aCampos,{"LOJA"  , "Loja"                         , .T. ,      , AvSx3("W8_FORLOJ", AV_TAMANHO) , AvSx3("W8_FORLOJ", AV_PICTURE) , AvSx3("W8_FORLOJ", AV_TIPO) , AvSx3("W8_FORLOJ", AV_DECIMAL)})
   AAdd(aCampos,{"NRINV" , "Número da Invoice"            , .T. ,      , AvSx3("EDD_INVOIC", AV_TAMANHO), AvSx3("EDD_INVOIC", AV_PICTURE), AvSx3("EDD_INVOIC", AV_TIPO), AvSx3("EDD_INVOIC", AV_DECIMAL)})
   AAdd(aCampos,{"NRINV" , "Número da DU-e/ RE"           , .T. ,      , AvSx3("EDD_INVOIC", AV_TAMANHO), ""                             , AvSx3("EDD_INVOIC", AV_TIPO), AvSx3("EDD_INVOIC", AV_DECIMAL)})   
   AAdd(aCampos,{"CDEMB" , "Cód. Embarque"                , .T. ,      , AvSx3("EDD_PREEMB", AV_TAMANHO), AvSx3("EDD_PREEMB", AV_PICTURE), AvSx3("EDD_PREEMB", AV_TIPO), AvSx3("EDD_PREEMB", AV_DECIMAL)})   
   AAdd(aCampos,{"CDPED" , "Pedido"                       , .T. ,      , AvSx3("EDD_PEDIDO", AV_TAMANHO), AvSx3("EDD_PEDIDO", AV_PICTURE), AvSx3("EDD_PEDIDO", AV_TIPO), AvSx3("EDD_PEDIDO", AV_DECIMAL)})   
   AAdd(aCampos,{"ITEMB" , "Item Embarque"                , .T. ,      , AvSx3("EE9_SEQEMB", AV_TAMANHO), AvSx3("EE9_SEQEMB", AV_PICTURE), AvSx3("EE9_SEQEMB", AV_TIPO), AvSx3("EE9_SEQEMB", AV_DECIMAL)})   
   AAdd(aCampos,{"PRODEX", "Prod. Exportado"              , .T. ,      , AvSx3("EDD_PROD", AV_TAMANHO)  , AvSx3("EDD_PROD", AV_PICTURE)  , AvSx3("EDD_PROD", AV_TIPO)  , AvSx3("EDD_PROD", AV_DECIMAL)})   
   AAdd(aCampos,{"UMPROD", "Unidade de medida do produto" , .T. ,      , AvSx3("ED3_UMPROD", AV_TAMANHO), AvSx3("ED3_UMPROD", AV_PICTURE), AvSx3("ED3_UMPROD", AV_TIPO), AvSx3("ED3_UMPROD", AV_DECIMAL)})   
   AAdd(aCampos,{"QTDEX" , "Quantidade Exportada"         , .T. ,      , AvSx3("EDD_QTD_EX", AV_TAMANHO), AvSx3("EDD_QTD_EX", AV_PICTURE), AvSx3("EDD_QTD_EX", AV_TIPO), AvSx3("EDD_QTD_EX", AV_DECIMAL)}) 

   /* Ordenando os campos por título */
   ASort(aCampos,,,{|x, y| x[2] < y[2]})

   /* Preenche a ordem dos campos */
   For nCont:= 1 To Len(aCampos)
      aCampos[nCont][4]:= StrZero(ncont, 2)
   Next

   /* Recupera a expressão de filtro corrente */
   cExpFiltro:= (cAlias)->(DBFilter())

   /* Tela para montagem do filtro */
   (cAlias)->(DBClearFilter())
   cExpFiltro := BuildExpr(cAlias, oDlgFld, cExpFiltro,,,,,,,, aCampos)
   
   /* Aplicação do filtro */
   If Empty(cExpFiltro)
      (cAlias)->(DBClearFilter())
   Else
      (cAlias)->(DBClearFilter())
      (cAlias)->(DBSetFilter(&("{|| " + cExpFiltro + "}"), cExpFiltro))
   EndIf
   (cAlias)->(DBGoTop())

Return cFiltro


/*
Função      : FolderSetFocus(oFldPai, oFldFilho)
Parametros  : oFldPai - Objeto folder principal
              oFldFilho - folder a ser selecionada
Retorno     : 
Objetivos   : Selecionar a pasta referenciada na ação
Autor       : wfs
Data/Hora   : nov/2018
*/
Static Function FolderSetFocus(oFldPai, oFldFilho)
Local nPos

   nPos:= AScan(oFldPai:aPrompts, oFldFilho:cTitle)
   If nPos > 0
      oFldPai:SetOption(nPos)
   EndIf

Return



/*******
 */
Static Function ValidaAlternativo(aInsPrinc)
Local lRet:= .T.
Local x
Local aInsAlter:= {}
Local aEstrutAlt:= {}
Local cMsg:= ""
Local nPos:= 0

Begin Sequence

   /* busca os itens alternativos existentes para os insumos da estrutura do ato concessório */
   For x:= 1 To Len(aInsPrinc)
      aInsAlter:= {}
      aInsAlter:= IG400AllItens("I", aInsPrinc[x][1],, .T.)
      If Len(aInsAlter) > 0
         MontaEstruAlter(aInsAlter, @aEstrutAlt, aInsPrinc[x][2], aInsPrinc[x][3], aInsPrinc[x][1]) //aInsPrinc[x][2] = produto a exportar, aInsPrinc[x][3] = sequencia a exportar e aInsPrinc[x][1] = insumo principal
      EndIf
   Next

   /* verifica se o insumo informado na estrutura do ato concessório é item alternativo de outro insumo informado na estrutura, para o mesmo
      produto a exportar */
   For x:= 1 To Len(aInsPrinc)
      If (nPos:= AScan(aEstrutAlt, {|a| a[1] == aInsPrinc[x][1] .And. a[2] == aInsPrinc[x][2] .And. a[3] == aInsPrinc[x][3] })) > 0
         If !lRet
            cMsg += ENTER
         EndIf         
         cMsg += StrTran(StrTran(STR0443, "###", AllTrim(aInsPrinc[x][1])), "$$$", AllTrim(aInsPrinc[x][2])) + ENTER//"O insumo ### consta em duplicidade no ato concessório para o produto a exportar $$$."
         cMsg += StrTran(StrTran(STR0444, "###", AllTrim(aInsPrinc[x][3])), "$$$", AllTrim(aEstrutAlt[nPos][4])) //"Ele está informado como insumo principal para a sequência ### do produto a exportar e como insumo alternativo para o item $$$."
         lRet:= .F.
      EndIf
   Next

   If !lRet
      cMsg += ENTER + ENTER + STR0445//"Solução: revise a estrutura do produto a exportar, mantendo apenas um dos itens na estrutura como insumo principal."
      Help("", 1, "AVG", STR0435, cMsg, 1, 0, .F.)
      Break
   EndIf
End Sequence

Return lRet

/*******
 */
Static Function MontaEstruAlter(aInsAlter, aEstrutAlt, cProdutoExportacao, cSequencia, cInsPrincipal)
Local x

   For x:= 1 To Len(aInsAlter)
      AAdd(aEstrutAlt, {aInsAlter[x][1], cProdutoExportacao, cSequencia, cInsPrincipal})
   Next

Return