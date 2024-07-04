//ATENÇÃO, NÃO PODE MAIS SER INCLUÍDO NENHUM STR NESSE PROGRAMA, TODOS DEVEM SER CRIADOS NO EFFEX401
#INCLUDE "EFFEX400.ch"
#INCLUDE "AVERAGE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Dbstruct.ch"
#INCLUDE "FWBROWSE.CH"

#define VISUALIZAR 2
#define INCLUIR    3
#define ALTERAR    4
#define ESTORNAR   5

#define MOEDA_REAIS     "R$ "
#define ACC             "01"
#define ACE             "02" 
#define PRE_PAGTO       "03"
#define SECURITIZACAO   "04"
#define FINIMP          "05"
#define EV_PRINC        "100"
#define EV_PRINC2       "101"
#define EV_EMBARQUE     "600"
#define EV_PJ           "520"
#define EV_EST_PJ       "510"  //525
#define EV_TJ           "650"
#define EV_VC_PJ1       "550"
#define EV_VC_PJ2       "569"
#define EV_JUR_CNT      "620" //NCF - 07/01/2015
#define EV_VC_JUR_CNT   "580" //AAF - 20/01/2015 - Variação cambial do juros antecipado (580 á 599)
#define EV_LIQ_PRC      "630"
#define EV_LIQ_JUR      "640"
#define EV_VC_PRC       "500"
#define EV_VC_PRC1      "501"
#define EV_DESCON       "801"
#define EV_COM_FIN      "140"  //Comissão Financeira
#define EV_VC_COM_FIN_S "596"  //V.C Comissão Financeira taxa subiu
#define EV_VC_COM_FIN_D "597"  //V.C Comissão Financeira taxa desceu
#define EV_P_COM_FIN    "615"  //Pagamento da Comissão Financeira
#define EV_D_COM_FIN    "808"  //Desconto da Comissão Financeira
#define EV_LIQ_PRC_FC   "660"  //Liquidação do principal apenas no contrato
#define EV_LIQ_JUR_FC   "670"  //Liquidação do juros apenas no contrato
#define EV_PRINC_PREPAG "700"  //Principal das parcelas de pré-pagamento/securitização
#define EV_JUROS_PREPAG "710"  //Parcelas de juros de pré-pagamento/securitização
#define EV_DIF_JUR      "720"  //Diferença de juros de pré-pagamento/securitização
#define EV_ESTORNO      "999"
// ** GFC - 24/08/05 - IR
#define EV_PROV_IR      "770"  //Evento de provisão de IR
#define EV_IR           "780"  //Evento de IR
#define EV_EST_IR       "790"  //Evento de estorno de provisão de IR
// **
// ** GFC - 04/11/05 - Pagamento de Juros antecipado
#define EV_JR_ANT       "680"  //Pagamento de Juros antecipado
#define EV_VC_JA1       "050"  //Variação Cambial de Juros Antecipado
#define EV_VC_JA2       "069"  //Variação Cambial de Juros Antecipado
// **
#define EV_ENC_PRC      "180"  //AAF - 01/11/05 - Encerramento.
#define EV_TRANS_PRC    "190"  //AAF - 01/11/05 - Transferência.

// PLB 19/12/06
#Define EVENTOS_DE_JUROS (Left(EV_EST_PJ,2)  +"/"+ ;  // 510
                          Left(EV_PJ,2)      +"/"+ ;  // 520
                          Left(EV_VC_PJ1,2)  +"/"+ ;  // 550
                          Left(EV_LIQ_JUR,2) +"/"+ ;  // 640
                          Left(EV_TJ,2)      +"/"+ ;  // 650
                          Left(EV_LIQ_JUR_FC,2))      // 670

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2

#define ORDEM_BROWSE    8

#define EXP "E"
#define IMP "I"

// ** PLB 04/01/07 - Prazos para Vinculação e Vencimento dos contratos de ACC e ACE
#Define PRAZO_VINC_ACC   360
#Define PRAZO_VENC_ACC   390
#Define PRAZO_VINC_ACE   180
#Define PRAZO_VENC_ACE   180
// **

/*
Programa        : EFFEX400.PRW
Objetivo        : Manutenção do Financiamento da Exportação
Autor           : Gustavo Carreiro
Data/Hora       :
Revisao         : Lucas Rolim R Lopes.
                  Substituição das variaveis cFil para xFilial , adaptação para o conceito MultiFilial
                  Alessandro Porta (AJP) - 20/10/06
                  Comissao ao Deduzir da fatura já esta calculada pelo módulo exportação. Não deve ser
                  deduzida novamente do valor da parcela
*/


*-----------------*
Function EFFEX401(nRecEF1,nOpcBrowse)
*-----------------*

If EX401Var("lEFFTpMod",.F.)

   EFFEX500(IMP,nRecEF1,nOpcBrowse)

Else
   MsgStop(STR0264)//"Ambiente desatualizado para o funcionamento desta rotina. Entre em contato com o Suporte Average."
EndIf

Return .T.

*-----------------*
Function EFFEX400(nRecEF1, nOpcBrowse)
*-----------------*

EFFEX500(EXP,nRecEF1,nOpcBrowse)

Return .T.


*-----------------*
Function EFFEX500(cParMod,nRecEF1,nOpcBrowse)
*-----------------*
Local oUpdAtu // FSM - 22/03/2012 - Tratamento para carga padrão da tabela EC6
Local cFilterEF1
Private lLogix := EasyGParam("MV_EECI010",,.F.)
Private aTabelas:={}, aBotoes:={}
Private cCadastro := If(cParMod == EXP,STR0001,STR0259) //"Manutenção de Financiamento da Exportação "###"Manutenção de Financiamento da Importação "
Private cMarca := GetMark(), lInverte := .F., lIncluiAux:=.F.
Private aSelCpos:={}, aSelCpos2:={}, aSelCpos3:={}, aSelCpos4:={}
Private lTop := .F., aMostraCpos:={}
Private lIntExp := EasyGParam("MV_EEC_EFF",,.F.) //Verifica se existe a integração com o Módulo SIGAEEC
Private cTX_100, cTX_520, lParFin := EEQ->(FieldPos("EEQ_PARFIN")) > 0
Private cTPMODU := ""
Private bTPMODUECF
private bTPMODUECE
private dVencIni   := dVencFim  := CtoD(Space(8))   // ACSJ - 07/01/2004
private cInvoice   := cProcesso := Space(20)		// ACSJ - 07/01/2004
private nValIni    := nValFim   := 0				// ACSJ - 07/01/2004
Private cImport    := Space(Len(EEC->EEC_IMPORT)) 	// ACSJ - 07/01/2004
private cCondPagto := Space(5)		    	     	// ACSJ - 07/01/2004
private nDias      := 0                             // ACSJ - 07/01/2004
Private lMultiFil
Private oGetMS
Private lDataCred  := EF1->(FieldPos("EF1_DTCRED")) > 0//FSY - 10/02/2014
Private lEF3Ct := EF3->( FieldPos( "EF3_DT_CTB" ) ) > 0 .AND. EF3->( FieldPos( "EF3_TX_CTB" ) ) > 0 ;
                  .AND. EF3->( FieldPos( "EF3_DT_ANT" ) ) > 0 .AND. EF3->( FieldPos( "EF3_TX_ANT" ) ) > 0 //MCF - 26/07/2016

// ** AAF - 21/02/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
EX401Var("lEFFTpMod",.T.)
FI400Ini(EF7->(!DBSeek(xFilial("EF7")))) //THTS - 05/02/2019 - Inicializa o cadastro EF7 - Tipos de Financiamento

/*
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0
*/

//Tabela de cadastro de Financiamentos.
Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9")
If lCadFin
   bDescEve := {|cCodEve| EC6->( dbSeek(cFilEC6+"FI"+If(cMod == EXP,"EX","IM")+M->EF1_TP_FIN+cCodEve+"    ") .OR.;
                                 dbSeek(cFilEC6+"FI"+If(cMod == EXP,"EX","IM")+M->EF1_TP_FIN+cCodEve+"1000"),;
                                 EC6_DESC )}
   cROFAtual := ""
   cLinCredit:= ""
EndIf
// **

// PLB 28/05/07 - Identifica se ha tratamento para Baixa Manual de Juros por Período
Private lLiqPeriodo := EF2->( FieldPos("EF2_SEQPER") ) > 0  .And.  EF3->( FieldPos("EF3_SEQPER") ) > 0

If !Empty(EasyGParam("MV_AVG0024",,"")) .and. cFilAnt $ EasyGParam("MV_AVG0024",,"")
   MsgStop(EX401STR(42))  //"Financiamento desabilitado para filiais off-shore."
   Return .F.
EndIf

SX3->(DbSetOrder(2))
lMultiFil  := VerSenha(115) .and. Posicione("SX2",1,"EF1","X2_MODO") == "C" .and.;
              Posicione("SX2",1,"EEQ","X2_MODO") == "E" .AND. SX3->(DbSeek("EF3_FILORI"))
Private lTemPgJuros:=  SX3->(DBSeek("EF1_PGJURO"))  // ACSJ - Caetano - 22/01/2005

// ACSJ - 08/02/2005
// Testa se existe os campos nos arquivos
Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
                     SX3->(DBSeek("EF3_OBS"))   .AND. SX3->(DBSeek("EF3_NROP"))
// ---------------------------------------
Private lEF4_MOTIVO := EF4->(FieldPos("EF4_MOTIVO")) > 0
Private lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0
Private lEF3_EV_FO  := EF3->(FieldPos("EF3_EV_FO" )) > 0
Private lEF2_INVOIC := EF2->(FieldPos("EF2_INVOIC")) > 0 .and. EF2->(FieldPos("EF2_PARC")) > 0 .and.;
                       EF2->(FieldPos("EF2_FILORI")) > 0
Private lEF1_JR_ANT := EF1->(FieldPos("EF1_JR_ANT")) > 0
Private lEF1_LIQPER := EF1->(FieldPos("EF1_LIQPER")) > 0
Private lEF1_DTBONI := EF1->(FieldPos("EF1_DTBONI")) > 0 .and. EF2->(FieldPos("EF2_BONUS")) > 0
Private lEEQ_TP_CON := EEQ->(FieldPos("EEQ_TP_CON")) > 0
Private lEF3_CTDEST := EF3->(FieldPos("EF3_CTDEST")) > 0 .and. EF3->(FieldPos("EF3_PRDEST")) > 0

// ** GFC - Pré-Pagamento/Securitização
Private lPrePag     := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
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
                       EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
                       EF3->(FieldPos("EF3_SLDVIN")) > 0

Private cWHENSA1:="EEC_CLIENT"
Private lLiqAuto := EasyGParam("MV_LIQAUTO",,.F.)
Private cMod := cParMod

Private lGerAdEEC := .F.
If EasyGParam("MV_EFF0006",.T.)
   lGerAdEEC := EasyGParam("MV_EFF0006",,.F.)
EndIf

// **
If cMod == IMP
   Private lAumVlCont := .F.  // PLB 25/07/06 - Variavel que verifica se o usuario aumentou o Valor do Contrato de Importacao pelas Vinculacoes
   Private nOldVlCont := 0
EndIf

Private aRotina := MenuDef(ProcName(1))
Private lRefinimp := EF3->(FieldPos("EF3_TPMOOR")) > 0 .and. EF3->(FieldPos("EF3_CONTOR")) > 0 .and.;
                     EF3->(FieldPos("EF3_BAN_OR")) > 0 .and. EF3->(FieldPos("EF3_PRACOR")) > 0 .and.;
                     EF3->(FieldPos("EF3_SQCNOR")) > 0 .and. EF3->(FieldPos("EF3_CDEVOR")) > 0 .and.;
                     EF3->(FieldPos("EF3_PARCOR")) > 0 .and. EF3->(FieldPos("EF3_IVIMOR")) > 0 .and.;
                     EF3->(FieldPos("EF3_LINOR")) > 0  .and. cMod == IMP // GFP - 09/10/2015

// FSM - 22/03/2012 - Tratamento para carga padrão da tabela EC6
If FindFunction("AvUpdate01")
   oUpdAtu := AvUpdate01():New()
   oUpdAtu:aChamados := {{nModulo,{|o| EX400AtuDic(o)}}}
   oUpdAtu:Init(,.T.)
EndIf

SX3->(DbSetOrder(1))

EC6->(DbSetOrder(6))
EC6->(DbSeek(xFilial("EC6")+"FIEX01"+'100'))
cTX_100 := EC6->EC6_TXCV
EC6->(DbSeek(xFilial("EC6")+"FIEX01"+'520'))
cTX_520 := EC6->EC6_TXCV
EC6->(DbSetOrder(1))

cTPMODU:='EXPORT'
bTPMODUECF := {|| ECF->ECF_TPMODU = 'EXPORT' }
bTPMODUECE := {|| ECE->ECE_TPMODU = 'EXPORT' }

#IFDEF TOP
   lTop := .T.
#ENDIF

If AmIin(30) .Or. AmIin(31)  // Financiamento ou Contabil

   SX3->( DBSetOrder(1) )

   If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"MBROWSE"),)

   Processa({|| IniCpos(1)}  ,STR0007) //"Inicializando Ambiente"
   Processa({|| EX400Works()},STR0007) //"Inicializando Ambiente"

   cFilterEF1:= ""
   If lEFFTpMod
      If cParMod == EXP
         //Filtro por Contratos de Exportação
         If lTop
            cFilterEF1:= "EF1_TPMODU = 'E'"
         Else
            EF1->( dbSetFilter({||EF1_TPMODU == EXP},"EF1_TPMODU = 'E'") )
         EndIf
      ElseIf cParMod == IMP
         //Filtro por Contratos de Importação
         If lTop
            cFilterEF1:= "EF1_TPMODU = 'I'"
         Else
            EF1->( dbSetFilter({||EF1_TPMODU == IMP},"EF1_TPMODU = 'I'") )
         EndIf
      EndIf
   EndIf

   EF1->(dbSetOrder(1))
   If ValType(nOpcBrowse) == "N" .AND. ValType(nRecEF1) == "N" .AND.;
      nOpcBrowse <= Len(aRotina) .AND. EF1->(dbGoTo(nRecEF1),!EoF())

      Eval(&("{|| "+aRotina[nOpcBrowse][2]+"('EF1',EF1->(RecNo()),"+Str(nOpcBrowse)+")}"))
   Else
      //mBrowse(,,,, "EF1") //comentado por wfs
      mBrowse(,,,, "EF1",,,,,,,,,,,,,, cFilterEF1)
   EndIf

   EF1->( dbClearFilter() )

   EX400DelWorks()
Endif

Return .T.


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 31/01/07 - 11:12
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina  := {}
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

If nModulo == 30
   aAdd(aRotina, { STR0002     , "AxPesqui"  , 0, 1})//"Pesquisar"
   aAdd(aRotina, { STR0003     , "EX400Manut", 0, 2})//"Visualizar"
   aAdd(aRotina, { STR0004     , "EX400Manut", 0, 3})//"Incluir"
   aAdd(aRotina, { STR0005     , "EX400Manut", 0, 4})//"Alterar"
   aAdd(aRotina, { STR0006     , "EX400Manut", 0, 5})//"Estornar"
   aAdd(aRotina, { STR0164     , "EX400CHist", 0, 6})//"Histórico"
   aAdd(aRotina, { STR0255     , "EX401Copia", 0, 7})//"Copiar"
   aAdd(aRotina, { EX401STR(59), "EX401TotCo", 0, 8})//"Tot.p/Contrato"
   //RMD - 28/10/14 - Novo Relatório de Contratos
   aAdd(aRotina, { EX401STR(184), "EX401RelCont", 0, 8})//Relatório de Contratos

Else
   aAdd(aRotina, { STR0002     , "AxPesqui"  , 0, 1})//"Pesquisar"
   aAdd(aRotina, { STR0003     , "EX400Manut", 0, 2})//"Visualizar"
EndIf

// P.E. utilizado para adicionar itens no Menu da mBrowse
If cOrigem $ "EFFEX401"//Importação
   If EasyEntryPoint("FEX401MNU")
      aRotAdic := ExecBlock("FEX401MNU",.f.,.f.)
      If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf

ElseIf cOrigem $ "EFFEX400"//Exportação
   If EasyEntryPoint("FEX400MNU")
      aRotAdic := ExecBlock("FEX400MNU",.f.,.f.)
      If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIF
EndIf

Return aRotina
*-------------------------------------------------------*
Function EX400Manut(cAlias,nReg,nOpc,aReserv1,lCopiaCont)
*-------------------------------------------------------*
Local aTiraCampos := {}
Local oDlg, bOk := {||nOpcao:=1,oDlg:End()}
Local nOpcao:=0, bCancel := {||nOpcao:=0,oDlg:End()}
Local aPosEnc, aPosMark, cTitulo := cCadastro
Local oFont1, oMemo, i, nInd
Local aRLockList := {}    // PLB 21/07/06 - Variavel para Tratamento Multi-Usuario
Local nOld := If(type("n")=="N",n,0) //ISS - 10/02/11 - Tratamento para guardar e recuperar o "n" do getdados.
Local aContrato:= Array(0)
Local bOnError := If(Type('bOnError')=='B', bOnError , { |cFuncName, nOpc| AF200RetLiq(aContrato,cFuncName,nOpc,"MANUTCONTR")} )    //NCF - 11/09/2014
Local cMsg := "" //MCF - 13/11/2015
Define FONT oFont1 NAME "Courier New" SIZE 0,15

If(lCopiaCont=NIL,lCopiaCont:=.F.,)

Private cFilEF1:=xFilial("EF1"), cFilEF2:=xFilial("EF2"), cFilEF3:=xFilial("EF3")
Private cFilEC6:=xFilial("EC6"), cFilEEC:=xFilial("EEC"), cFilEEQ:=xFilial("EEQ")
Private cFilEE9:=xFilial("EE9"), cFilSX5:=xFilial("SX5"), cFilECF:=xFilial("ECF")
Private cFilSA6:=xFilial("SA6"), cFilEF4:=xFilial("EF4"), cFilEF5:=xFilial("EF5")
Private cFilEF6:=xFilial("EF6"), cFilEF8:=xFilial("EF8")


// ** AAF 10/11/2009
Private oEFFContrato := AvEFFContra():LoadEF1()
// **

Private bBarOk := {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)}
Private bBarCancel := {||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0008+Chr(13)+Chr(10)+STR0009),Eval(bCancel),),Eval(bCancel))} //"Deseja Realmente Sair?"###"Todas as alterações serão perdidas."

Private oMark, aHeader := {}, /*aCAMPOS := ARRAY(0),*/ oEnc, cFilAux, nOrdFil := 0 //cFilAux é utilizado na função SetaFiltro()
Private aDelWkEF2:={}, aDelWkEF3:={}, aDelEF3:={}
Private lACCACE := .T., lSai := .T., aAlterados:={} //EasyGParam("MV_ACC_ACE",,.T.)
Private nOpcSel := nOpc //LDB 26/04/2006 - Para uso em rdmakes
Private aHeaderEnc:= {}
Private aColsEnc:= {}, aCols:={}
// ** GFC - 25/04/06 - Alterar Encargos
Private cTipAl:="M", lWhen2:=.T.
Private cComp3 := {|| cMod==IMP}
Private cComp5 := {|| cMod==EXP}
Private cChav2 := {|| xFilial("EC6")+cTipFin+M->EF1_TP_FIN+&cNameField+"1000"}
Private cChav3 := {|| xFilial("EC6")+cTipFin+M->EF1_TP_FIN+&cNameField+"    "}
Private cLocal := "MANUTENÇÃO"
Private lRetContr := .T.  // PLB 13/10/06
// **
Private cEvento := Space(Len(EF3->EF3_CODEVE)), cInv := "", cParc := ""
Private oDlgFocus := NIL  // PLB 21/03/07 - Variavel utilizada para a chamada da funcao AvSetFocus()
Private lIsContab := .F.  // PLB 13/06/07 - Identifica se o Contrato de Financiamento foi Contabilizado
Private lLogix := AVFLAGS('EEC_LOGIX')  //NCF - 11/09/2014
Private aDataContr := If( Type('aDataContr')=='U',ARRAY(0),aDataContr )
Private lGerTitEvEnc := EasyGParam("MV_EFF0009",,.F.)
Private lEsLqSldCrt := .F.
Private cFiltRef := "", aRefinimp := {}  // GFP - 09/10/2015
Private aEF3AltEAI := If( IsMemVar("aEF3AltEAI"), aEF3AltEAI, ARRAY(0) )

oInt := AvEFF_FIN():New() //MCF - 13/11/2015
For i:=1 To Len(oInt:aError)
   cMsg += oInt:aError[i] + If(Len(oInt:aError)>1 ,ENTER + ENTER,"")
Next

If !Empty(cMsg) //MCF - 13/11/2015
   MsgInfo(cMsg,STR0094)
   Return .F.
Endif

If cMod == IMP
   cInv  := Space(Len(EF3->EF3_INVIMP))
   cParc := Space(Len(EF3->EF3_LINHA))
Else
   cInv  := Space(Len(EF3->EF3_INVOIC))
   cParc := Space(Len(EF3->EF3_PARC))
EndIf

oMainWnd:ReadClientCoords()//So precisa declarar uma vez para o programa todo

Processa({|| LimpaTabelas() },STR0010) //"Criando Arquivos Temporários"
dbSelectArea("EF1")
aGets:={}
aTela:={}

If (nOpc = ALTERAR .or. nOpc = ESTORNAR) .and. !EF1->(RecLock("EF1",.F.))
   Return .F.
EndIf

// ** PLB 13/06/07
If cMod == EXP
   If AvFlags("SIGAEFF_SIGAFIN") .OR. !EasyGParam("MV_EEC_ECO",,.F.)
      lIsContab := !Empty(EF1->EF1_DT_CTB)
   Else
      lIsContab := EX401IsCtb(EF1->EF1_CONTRA,IIF(lTemChave,EF1->EF1_BAN_FI,""),IIF(lTemChave,EF1->EF1_PRACA,""),IIF(lEFFTpMod,EF1->EF1_SEQCNT,""))
   EndIf
EndIf
// **

//Inicializa Variáveis
If nOpc <> INCLUIR .or. lCopiaCont
   cTitulo += " - "+Alltrim(EF1->EF1_CONTRA) //FSM - 17/10/2012

   RegToMemory("EF1",.F.,.T.)

   IF !EMPTY(EF1->EF1_OBS)
      M->EF1_VM_OBS:= MSMM(EF1->EF1_OBS,60)
   ENDIF
   If lCopiaCont
      M->EF1_CONTRA := Space(Len(EF1->EF1_CONTRA))
      If lEFFTpMod
         nOrd := EF1->( IndexOrd() )
         nRec := EF1->( RecNo() )

         EF1->( dbSetOrder(1) )
         EF1->( AvSeekLast(xFilial("EF1")+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA) )

         M->EF1_CONTRA := EF1->EF1_CONTRA
         M->EF1_SEQCNT := StrZero(Val(EF1->EF1_SEQCNT)+1,2) // AAF 04/03/06 - Sequencia do Contrato.

         cROFAtual := M->EF1_ROF
         cLinCredit:= M->EF1_LINCRE

         // ** PLB 22/09/06 - Limpa data de início de juros para contratos de FINIMP
         If cMod == IMP
            M->EF1_DT_JUR := CToD("  /  /  ")
            M->EF1_SLD_PM := M->EF1_VL_MOE
            M->EF1_SLD_PR := 0
            M->EF1_SLD_JM := 0
            M->EF1_SLD_JR := 0
            M->EF1_LIQPRM := 0
            M->EF1_LIQPRR := 0
            M->EF1_LIQJRM := 0
            M->EF1_LIQJRR := 0
         EndIf
         // **

         EF1->( dbSetOrder(nOrd) )
         EF1->( dbGoTo(nRec) )
      EndIf
      // ** PLB 29/06/07 - Não copia dados contábeis
      M->EF1_DT_CTB := CToD("  /  /  ")
      M->EF1_TX_CTB := 0
      M->EF1_DT_ANT := CToD("  /  /  ")
      M->EF1_TX_ANT := 0

	  // ** AAF 11/07/08 - Não copiar dados da transferencia de contratos
	  M->EF1_VLTRAN := 0
	  M->EF1_DT_ENC := CToD("  /  /  ")
	  // **

      // **
   EndIf

   // ** AAF 11/07/08 - Não existe valor transferido negativo.
   If M->EF1_VLTRAN < 0
      M->EF1_VLTRAN := 0
   EndIF
   // **

   // ** PLB 28/05/07 - Somente exibe campos de Juros para Contratos sem Parcelas de Financiamento
   If M->EF1_CAMTRA == "1"
      nPos := AScan( aMostraCpos, { |x| x == "EF1_PG_JUR" } )
      If nPos > 0
         ADel( aMostraCpos, nPos )
         ASize( aMostraCpos, Len(aMostraCpos)-1 )
      EndIf
      nPos := AScan( aMostraCpos, { |x| x == "EF1_JR_ANT" } )
      If nPos > 0
         ADel( aMostraCpos, nPos )
         ASize( aMostraCpos, Len(aMostraCpos)-1 )
      EndIf
      nPos := AScan( aMostraCpos, { |x| x == "EF1_LIQPER" } )
      If nPos > 0
         ADel( aMostraCpos, nPos )
         ASize( aMostraCpos, Len(aMostraCpos)-1 )
      EndIf
   Else
      nPos := AScan( aMostraCpos, { |x| x == "EF1_PG_JUR" } )
      If nPos == 0
         AAdd( aMostraCpos, "EF1_PG_JUR" )
      EndIf
      nPos := AScan( aMostraCpos, { |x| x == "EF1_JR_ANT" } )
      If nPos == 0
         AAdd( aMostraCpos, "EF1_JR_ANT" )
      EndIf
      nPos := AScan( aMostraCpos, { |x| x == "EF1_LIQPER" } )
      If nPos == 0
         AAdd( aMostraCpos, "EF1_LIQPER" )
      EndIf
   EndIf
   // **

   If AScan(aMostraCpos,{ |x| x=="EF1_LIQPRM" }) == 0  .Or.  ;
      AScan(aMostraCpos,{ |x| x=="EF1_LIQPRR" }) == 0  .Or.  ;
      AScan(aMostraCpos,{ |x| x=="EF1_LIQJRM" }) == 0  .Or.  ;
      AScan(aMostraCpos,{ |x| x=="EF1_LIQJRR" }) == 0
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aIns(aMostraCpos,22)
      aIns(aMostraCpos,23)
      aIns(aMostraCpos,24)
      aIns(aMostraCpos,25)
      aMostraCpos[22] := "EF1_LIQPRM"
      aMostraCpos[23] := "EF1_LIQPRR"
      aMostraCpos[24] := "EF1_LIQJRM"
      aMostraCpos[25] := "EF1_LIQJRR"
   EndIf
   If !((lPrePag .AND. M->EF1_CAMTRA == "1") .Or. cMod==IMP)//!(lPrePag .and. M->EF1_TP_FIN $ ("03/04"))
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aIns(aMostraCpos,22)
      aIns(aMostraCpos,23)
      aIns(aMostraCpos,24)
      aIns(aMostraCpos,25)
      aMostraCpos[22] := "EF1_SL2_PM"
      aMostraCpos[23] := "EF1_SL2_PR"
      aMostraCpos[24] := "EF1_SL2_JM"
      aMostraCpos[25] := "EF1_SL2_JR"
   Else
      Do While (nPos := AScan(aMostraCpos,{ |x| x=="EF1_SL2_PM" .Or.  ;
                                                x=="EF1_SL2_PR" .Or.  ;
                                                x=="EF1_SL2_JM" .Or.  ;
                                                x=="EF1_SL2_JR" })) > 0
         ADel(aMostraCpos,nPos)
         ASize(aMostraCpos,Len(aMostraCpos))
      EndDo
   EndIf
Else
   RegToMemory("EF1",.T.,.T.)
   M->EF1_VM_IMP := ""
   // ACSJ - 09/01/2004 - Verifica se os eventos contabeis estão cadastrados no EC6
   If nOpc == 3 //.And. cMod==EXP  //INCLUIR

      cTitEvnt := STR0131 + CHR(13) + CHR(10) // "Para cadastrar um contrato de financiamento é necessário que os eventos"
      cTitEvnt += STR0132 + CHR(13) + CHR(10) // "abaixo estejam cadastrados no Cadastro de Eventos Contabéis."
      cEventos := ""
      cTxtOK   := ""

      EC6->(DBSetOrder(1))

      If lCadFin
         EF7->( DBSetOrder(1) )
         //EF7->( DBGoTop() )
         cFilEF7 := xFilial("EF7")
         EF7->( DBSeek(cFilEF7) )
         cCond  := "EF7->( !EOF() .And. EF7_FILIAL==cFilEF7 )"
      Else
         SX5->(DBSetOrder(1))
         SX5->(DBSeek(xFilial("SX5")+"CG"))
         cCond := "!SX5->(Eof()) .and. SX5->X5_TABELA == 'CG'"
         // ** PLB 09/10/06
         If !lEFFTpMod
            cCond += "  .And.  !(SX5->X5_CHAVE $ '"+FINIMP+"')"
         EndIf
         If !lPrepag
            cCond += "  .And.  !(SX5->X5_CHAVE $ '"+PRE_PAGTO+"/"+SECURITIZACAO+"')"
         EndIf
         // **
      EndIf

      Do While &(cCond)

         If lCadFin  .And.  cMod <> EF7->EF7_TP_FIN
            EF7->( DBSkip() )

         Else
            If lCadFin
               cBusca   := xFilial("EC6")+"FI"+IIF(cMod==EXP,"EX","IM")+EF7->EF7_FINANC
            Else
               cBusca   := xFilial("EC6")+"FIEX"+Substr(SX5->X5_CHAVE,1,2)
            EndIf

            If .not. EC6->( DBSeek(cBusca + "100") )
               cEventos += STR0133 + CHR(13) + CHR(10) // "100 - Contratação de Financiamento"
            Endif
            If .not. EC6->( DBSeek(cBusca + "520") )
               cEventos += STR0136 + CHR(13) + CHR(10) // "520 - Provisão de Juros"
            Endif
            If .not. EC6->( DBSeek(cBusca + "510") )
               cEventos += STR0139 + CHR(13) + CHR(10) // "510 - Estorno da Provisão de Juros"
            Endif
            If .not. EC6->( DBSeek(cBusca + "600") )
               cEventos += STR0140 + CHR(13) + CHR(10) // "600 - Embarques"
            Endif
            If .not. EC6->( DBSeek(cBusca + "630") )
               cEventos += STR0141 + CHR(13) + CHR(10) // "630 - Liquidação Principal"
            Endif

            // **  PLB 09/10/06
            If cMod == EXP
               If .not. EC6->( DBSeek(cBusca + "500") )
                  cEventos += STR0134 + CHR(13) + CHR(10) // "500 - Variação Cambial do Principal (Taxa Subiu)"
               Endif
               If .not. EC6->( DBSeek(cBusca + "501") )
                  cEventos += STR0135 + CHR(13) + CHR(10) // "501 - Variação Cambial do Principal (Taxa Desceu)"
               Endif
               If .not. EC6->( DBSeek(cBusca + "550") )
                  cEventos += STR0137 + CHR(13) + CHR(10) // "550 - Variação Cambial da Provisão de Juros (CR) Taxa Desceu"
               Endif
               If .not. EC6->( DBSeek(cBusca + "551") )
                  cEventos += STR0138 + CHR(13) + CHR(10) // "551 - Variação Cambial da Provisão de Juros (DB) Taxa Subiu"
               Endif
               If .not. EC6->( DBSeek(cBusca + "640") )
                  cEventos += STR0142 + CHR(13) + CHR(10) // "640 - Liquidação de Juros"
               Endif
               If .not. EC6->( DBSeek(cBusca + "650") )
                  cEventos += STR0143 + CHR(13) + CHR(10) // "650 - Tranferência de Juros ACC/ACE"
               Endif
            EndIf
            If Right(cBusca,2) $ PRE_PAGTO+"/"+SECURITIZACAO+"/"+FINIMP
               If !EC6->( DBSeek(cBusca + "700") )
                  cEventos += EX401STR(142) + CHR(13) + CHR(10) // "700 - Parcela do Principal"
               EndIf

               If !EC6->( DBSeek(cBusca + "710") )
                  cEventos += EX401STR(143) + CHR(13) + CHR(10) // "710 - Parcela de Juros"
               EndIf
            EndIf
            // **

            If .not. empty(cEventos)
               cTxtOK += Space(80) + Chr(13) + Chr(10)
               If lCadFin
                  cTxtOK += STR0144 + Alltrim(EF7->EF7_DESCRI) + "    "+"FI" + IIF(cMod==EXP,"EX","IM") + EF7->EF7_FINANC + " " + CHR(13) + CHR(10) // "EVENTOS "
               Else
                  cTxtOK += STR0144 + Alltrim(SX5->X5_DESCRI)  + "    FIEX" + SX5->X5_CHAVE + " " + CHR(13) + CHR(10) // "EVENTOS "
               EndIf
               cTxtOK += Space(80) + Chr(13) + Chr(10)
               cTxtOK += cEventos
               cEventos := ""
            Endif

         EndIf

            If lCadFin
               EF7->( DBSkip() )
            Else
               SX5->(DBSkip())
            EndIf

      Enddo
      If .not. Empty(cTxtOK)

         cTitEvnt += Space(80) + Chr(13) + Chr(10) + cTxtOK

         DEFINE MSDIALOG oDlg TITLE STR0145 From 125,00 To 450,600 OF oMainWnd PIXEL // "Atenção"

            oDlg:SetFont(oFont1)
            @15,5 GET oMemo Var cTitEvnt MEMO HScroll SIZE 290,130 ReadOnly OF oDlg PIXEL

            oMemo:EnableVScroll(.t.)

            Define sButton from 150,270 Type 1 Action( oDlg:End() ) Enable of oDlg Pixel

         ACTIVATE MSDIALOG oDlg CENTERED

         Return .t.
      Endif
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aAdd(aMostraCpos,NIL)
      aIns(aMostraCpos,22)
      aIns(aMostraCpos,23)
      aIns(aMostraCpos,24)
      aIns(aMostraCpos,25)
      aMostraCpos[22] := "EF1_LIQPRM"
      aMostraCpos[23] := "EF1_LIQPRR"
      aMostraCpos[24] := "EF1_LIQJRM"
      aMostraCpos[25] := "EF1_LIQJRR"
      If cMod != IMP  // PLB 01/11/06
         aAdd(aMostraCpos,NIL)
         aAdd(aMostraCpos,NIL)
         aAdd(aMostraCpos,NIL)
         aAdd(aMostraCpos,NIL)
         aIns(aMostraCpos,22)
         aIns(aMostraCpos,23)
         aIns(aMostraCpos,24)
         aIns(aMostraCpos,25)
         aMostraCpos[22] := "EF1_SL2_PM"
         aMostraCpos[23] := "EF1_SL2_PR"
         aMostraCpos[24] := "EF1_SL2_JM"
         aMostraCpos[25] := "EF1_SL2_JR"
      EndIf
   EndIf

EndIf

If lEFFTpMod
   M->EF1_TPMODU := cMod
   If nOpcSel == INCLUIR .AND. !lCopiaCont
      M->EF1_SEQCNT := "00"
   EndIf
EndIf

//Alcir Alves - 18-11-05 - inclusão dos campos PRACA e DES_PR e mudança do posicionamento desta condição.
If lTemChave
   aAdd(aMostraCpos,"EF1_AGENFI")
   aAdd(aMostraCpos,"EF1_NCONFI")
   aAdd(aMostraCpos,"EF1_AGENMO")
   aAdd(aMostraCpos,"EF1_NCONMO")
   aAdd(aMostraCpos,"EF1_PRACA")
   aAdd(aMostraCpos,"EF1_DES_PR")

   If lEFFTpMod
      aAdd(aMostraCpos,"EF1_SEQCNT")
      If SX3->( dbSetOrder(2), dbSeek("EF1_ENCARG") )
         aAdd(aMostraCpos,"EF1_ENCARG")
      EndIf
   EndIf
EndIf
//

// ** GFC - Pré-Pagamento/Securitização
If lPrePag
   aAdd(aMostraCpos,"EF1_CAREPR")
   aAdd(aMostraCpos,"EF1_TPCAPR")
   aAdd(aMostraCpos,"EF1_PARCPR")
   aAdd(aMostraCpos,"EF1_PERIPR")
   aAdd(aMostraCpos,"EF1_TPPEPR")
   aAdd(aMostraCpos,"EF1_CAREJR")
   aAdd(aMostraCpos,"EF1_TPCAJR")
   aAdd(aMostraCpos,"EF1_PARCJR")
   aAdd(aMostraCpos,"EF1_PERIJR")
   aAdd(aMostraCpos,"EF1_TPPEJR")
   aAdd(aMostraCpos,"EF1_PERFIX")
   aAdd(aMostraCpos,"EF1_CALCJR")
   aAdd(aMostraCpos,"EF1_PREPAG")
   aAdd(aMostraCpos,"EF1_CLIENT")
   aAdd(aMostraCpos,"EF1_CLLOJA")
   aAdd(aMostraCpos,"EF1_ROF")

   // ** AAF - 07/11/05 - Transferência de contrato.
   aAdd(aMostraCpos,"EF1_VLTRAN")
   // **
EndIf
// **
//NCF - 23/09/2014
aReg := {}
FOR i:=1 To EF1->(Fcount())
   aAdd(aReg, &("EF1->"+EF1->(FIELDNAME(i)) ) )
Next i
aAdd(aContrato, aReg)

If EasyEntryPoint("EFFEX400A")
	lSair := .F.
	ExecBlock("EFFEX400A",.F.,.F.,"BROWSE_EF1")
	If lSair
		Return .F.
	EndIf
Endif

Processa({|| EX400GrvWorks(nOpc,lCopiaCont)}, STR0011) //"Gravando Arquivos Temporários"
//SVG - 03/10/08 - Bloqueando estorno de contrato que possua invoices vinculadas
WorkEF3->(dbSetOrder(5))
IF WorkEF3->(DBSEEK("600")) .And. nOpc == EXCLUIR
   MSGINFO(STR0265)  //Contrato não pode ser estornado pois já possui invoices viculada.
   RETURN .F.
ENDIF
WorkEF3->(dbSetOrder(ORDEM_BROWSE))
WorkEF3->(dbGoTop())

//ASK 22/10/2007 - Atualização de todos os saldos do Contrato
EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

Do While .T.

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO ;
      oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

      nLinha := (oDlg:nClientHeight-4)/2

      // ** AAF 09/03/06 - Adicionado Filtro por Modulo no F3 de Financiamentos e ROF.
      cFiltroF3Fin := cMod
      cFiltroF3Rof := cMod
      lEvCont      := .F.
      // **

      // Dados da Capa
      oEnc := Msmget():New(cAlias,nReg,nOpc,,,,aMostraCpos,{15,1,FINAL_ENCHOICE,COLUNA_FINAL},,3,,,,oDlg,,IIF(nOpc==2,.T.,))

      If EF3->(FIELDPOS("EF3_TITFIN")) # 0 .And. !AVFLAGS("EEC_LOGIX")//AvFlags("SIGAEFF_SIGAFIN") - NOPADO POR AOM - 01/06/2011
         AADD(aTiraCampos ,"EF3_TITFIN")
      EndIf

      If !AvFlags("SIGAEFF_SIGAFIN") .And. !AVFLAGS("EEC_LOGIX") //AOM - 01/06/2011
         AADD(aTiraCampos ,"EF3_NUMTIT")
         AADD(aTiraCampos ,"EF3_PARTIT")
         AADD(aTiraCampos ,"EF3_TPTIT")
         AADD(aTiraCampos ,"EF3_PREFIX")
         AADD(aTiraCampos ,"EF3_RELACA")
      EndIf

      // Browse dos Itens
      // ** GFC - 05/10/05 - Carrega de novo este array pois pode ter sido alterado em outra rotina
      aSelCpos := BrowseCpos("EF3","WorkEF3",aTiraCampos)
      AcertaCpos("1")
      //

      If lCadFin .AND. lEFFTpMod//cMod == IMP

         SX3->( dbSetOrder(2) )
         If SX3->( dbSeek("EF1_ENCARG") )
            cSeekEF8  := ""
            bWhileEF8 := {|| ""}
            //If nOpc <> INCLUIR .OR. lCopiaCont
               cSeekEF8  := cFilEF8+AvKey(M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+EF1->EF1_SEQCNT,"EF8_CHAVE")
               //bWhileEF8 := {|| CFILEF8+AVKEY(M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+EF1->EF1_SEQCNT,"EF8_CHAVE")}
               bWhileEF8 := {|| EF8->(EF8_FILIAL+EF8_CHAVE) }
            //EndIf

            //AAF 27/10/2008 - Retirados campos não utilizados na manutenção de financiamento.
            aNoFields := {"EF8_TAXA","EF8_VL_RS","EF8_CARGA"}

            FillGetDados(nOpc, "EF8", 2, cSeekEF8, bWhileEF8, /*bSeekFor*/, aNoFields, /*aYesFields*/,,,,,,,/*{|a| SetCols(a, lCopiaCont) }*/,,{|a| AddHeader(a) })
            SetCols(aCols,.F.) //Carrega descrições

            aAlteraGD := {"EF8_CODEVE","EF8_CODEAS","EF8_CODEBA","EF8_TIP_EV","EF8_VL_PCT","EF8_PCT_RJ","EF8_LIQ"}

            If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
               aAdd(aAlteraGD,"EF8_FORN")
               aAdd(aAlteraGD,"EF8_LOJA")
            EndIf

            SX3->( dbSeek("EF1_ENCARG") )
            oGetMs:= MsGetDados():New(10,10,10,(oDlg:nClientWidth-4)/2, If(nOpc=INCLUIR .OR. nOpc=ALTERAR, 4, nOpc), "FI400LinOK", , , If(nOpc <> INCLUIR .and. nOpc <> ALTERAR, .F., .T.), aAlteraGD, , .T. ,9999,"FI400CpoOK",,,, oEnc:oBox:aDialogs[Val(SX3->X3_FOLDER)])
            oGetMS:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

            //ISS - 10/02/11 - Tratamento para guardar e recuperar o "n" do getdados.
            IF nOld <> 0
               n := nOld
            EndIf

            If nOpc <> INCLUIR .and. nOpc <> ALTERAR
               oGetMS:oBROWSE:bADD  := {|| .F.}
            Else
               //AAF 27/10/2008 - Adicionado tratamento de linha em branco.
               oGetMS:oBROWSE:bADD  := {|| If( Len(aCols) == 0 .OR. !(Empty(aCols[Len(aCols)][1])  .And.  Empty(aCols[Len(aCols)][3])  .And. Empty(aCols[Len(aCols)][5]) ),( oGetMS:ADDLINE(), aAdd(aCols[Len(aCols)],NIL), aIns(aCols[Len(aCols)],Len(aHeader)+1), aCols[Len(aCols)][Len(aHeader)+1]:=0, aCols[Len(aCols),aScan(aHeader,{|X| X[2] == "EF8_TP_REL"})]:="M"),oGetMS:lNewLine := .F.) }
            EndIf

            aEval(aCols,{|X| if(empty(X[GDFieldPos("EF8_TP_REL")]),X[GDFieldPos("EF8_TP_REL")]:="M",)})

         EndIf
      EndIf
      nLinha := (oDlg:nClientHeight-6)/2
      oMark:= MsSelect():New("WorkEF3",,,aSelCpos,@lInverte,@cMarca,{FINAL_ENCHOICE+1,1,FINAL_SELECT,COLUNA_FINAL})

      //FSM - 24/04/2012
      oMark:oBrowse:bHeaderClick := {|oBrw,nCol| EX400OrdEventos(oBrw,nCol),WorkEF3->(DBGoTOP()),oBrw:Refresh()}

      oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkEF3"),.T.}
      //oMark:bAval:={||EX400EVManut(2),WorkEF3->(dbGoTop()), SetKEY(15,bBarOk), SetKEY(24,bBarCancel) }

      If nModulo <> 30  .Or.  nOpc == 2// AAF - 28/07/04 - No modulo 31 - Contabil, não existe opção 4 - Alterar no aRotina.
         oMark:bAval:={|| SetaFiltro(1), EX400EVManut(2,"S"), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2), oMark:oBrowse:Refresh() }
      else
         oMark:bAval:={|| SetaFiltro(1), EX400EVManut(4,"S"), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2), oMark:oBrowse:Refresh() }
      endif
      WorkEF3->(dbSetOrder(ORDEM_BROWSE))
      WorkEF3->(dbGoTop())
      oMark:oBrowse:Refresh()
      //Processa({|| EX400GrvWorks(nOpc)}, STR0011) //"Gravando Arquivos Temporários"

      If nOpc<>ESTORNAR .and. nOpc<>VISUALIZAR .and. Empty(M->EF1_DT_ENC)
         aBotoes := { {"BTCALEND" /*"BMPCALEN"*/,{|| SetaFiltro(1), If(!Empty(M->EF1_TP_FIN),EX400Periodos(nOpc),MsgInfo(STR0012)), SetaFiltro(2) }, STR0013,STR0146},; //"Necessário preencher o tipo do financiamento."###"Períodos do Contrato" - "Periodos"
                      {"BAIXATIT" /*"VERNOTA"*/ ,{|| SetaFiltro(1), If(EX400Valid("VINC_INVOICES"),EX400fltIv(),) }, STR0015, STR0015 /*STR0192*/ } ,; //"Aguarde, Apurando Dados..."###"Vincular Invoices" # "Vincular"
                      {"BMPCPO"  ,{|| EX400Filtro(), SetKEY(15,bBarOk), SetKEY(24,bBarCancel) }, STR0016,STR0147} ,;   //"Selecionar Filtro" - "Filtro"
                      {"BMPVISUAL" /*"ANALITIC"*/,{|| SetaFiltro(1), EX400EVManut(2,"S"), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2) }, STR0105,STR0003/*STR0148*/} ,; //"Visualizar Evento" - "Visualizar" //FSM - 04/09/2012
                      {"BMPINCLUIR" /*"EDIT"*/ ,{|| SetaFiltro(1), EX400EVManut(3), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2) }, STR0017,STR0150} ,; //"Incluir Evento" - "Incluir"
                      {"EDIT" /*"IC_17"*/      ,{|| SetaFiltro(1), EX400EVManut(4), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2) }, STR0018,STR0149} ,; //"Alterar Evento" - "Alterar"
                      {"EXCLUIR" ,{|| SetaFiltro(1), If(EX400Valid("EX_EVENTO"),EX400EVManut(5),), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2) }, STR0019,STR0151} } //"Excluir Evento" - "Excluir"
                      //{"LIQCHECK",{|| EX401Amort("LIQ")}, STR0179,STR0191} ,; //"Liquidação" # "Liquidar"
                      //{"NOCHECKED" /*"BMPDEL"*/  ,{|| EX401Amort("EST")}, STR0196,STR0197} }  //"Estorno da Liquidacao" # "Est.Liq."

         // ** PLB 06/09/07 - Botões de Liquidação somente devem ser exibidos alteração
         If nOpc <> INCLUIR
            AAdd( aBotoes, {"LIQCHECK",  {|| SetaFiltro(1), EX401Amort("LIQ"), SetaFiltro(2)}, STR0179,STR0191} )  //"Liquidação" # "Liquidar"
            AAdd( aBotoes, {"NOCHECKED", {|| SetaFiltro(1), EX401Amort("EST"), SetaFiltro(2)}, STR0196,STR0196/*STR0197*/} )  //"Estorno da Liquidacao" # "Est.Liq." //FSM - 04/09/2012
         EndIf
         // **

         // ** GFC - Pré-Pagamento/Securitização
         If lPrepag .And. (nOpc == INCLUIR .OR. M->EF1_CAMTRA $ " /1") //M->EF1_TP_FIN $ "  /03/04" // Somente para pré-pagamento e securitização VI
            aAdd(aBotoes,{"RECALC",{|| SetaFiltro(1),If(EX400Valid("RECALC"),Processa({|| EX401Recalc() }, STR0206+M->EF1_VM_FIN/*If(M->EF1_TP_FIN == "03",STR0207,STR0208)*/ ),), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2)}, STR0203/*,STR0204*/}) //"Gerando parcelas de " # "Pré-Pagamento" / "Securitização" # "Calcular Juros e Principal" # "Calc.Prev."
         EndIf
         // **

         // ** AAF - 31/03/2006 - FINIMP
         If lPrepag .And. lEFFTpMod .AND. M->EF1_CAMTRA $ " /1" .AND. cMod == IMP
            aAdd(aBotoes,{"SDUAPPEND" /*"BMPPARAM"*/,{|| SetaFiltro(1),If(EX400Valid("CINVS"),Processa({|| EX401CInvs() }, "" ),), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2)}, "Transf. Invoices","Transf.Inv"})
         EndIf

         If lRefinimp  // GFP - 09/10/2015
            aAdd(aBotoes, {"BAIXATIT" ,{|| SetaFiltro(1), EX401Refinim(), SetaFiltro(2)}, STR0282, STR0282 }) //"Refinanciar" ## "Refinanciar"
         EndIf
         // **
         //LDB - 04/04/2006
         If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"BOTOES1"),)
         //

      Else
         aBotoes := { {"BTCALEND" /*"BMPCALEN"*/ ,{|| SetaFiltro(1), EX400Periodos(nOpc),SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2) }, STR0013,STR0146},; //"Períodos do Contrato"
                      {"BMPCPO"   ,{|| EX400Filtro(), SetKEY(15,bBarOk), SetKEY(24,bBarCancel) }, STR0016,STR0147} ,;     //"Selecionar Filtro"
                      {"BMPVISUAL" /*"ANALITICO"*/,{|| SetaFiltro(1), EX400EVManut(2), SetKEY(15,bBarOk), SetKEY(24,bBarCancel), SetaFiltro(2) }, STR0003,STR0003/*STR0148*/} }    //"Visualizar"- "Ver" //FSM - 04/09/2012

         aEvEncContr := {{'670',.F.,.F.}}     //NCF - 04/12/2014 - {Evento,lTemTitulo,lEstaLiquidado} - Liberar os botões para as rotinas de liquidação e estorno em caso de encerramento de contrato
         If lGerTitEvEnc                       //                                                        sem liquidação automática do título a pagar gerado
            aAdd(aEvEncContr,{'180',.F.,.F.})
            aAdd(aEvEncContr,{'190',.F.,.F.})
         EndIf
         aEval(aEvEncContr,{|x| If(  EF3->(DbSeek( &( EF1->(EF1->(INDEXKEY())) )+x[1])) ,  If( x[2] := !Empty(EF3->EF3_TITFIN), x[3] := !Empty(EF3->EF3_SEQBX) , ) , ) })
         If lLogix .And. nOpc <> INCLUIR
            If aScan(aEvEncContr, {|x| x[2] .and. !x[3] } ) > 0
               AAdd( aBotoes, {"LIQCHECK",  {|| EX401Amort("LIQ")}, STR0179,STR0191} )  //"Liquidação" # "Liquidar"
            EndIf
            If aScan(aEvEncContr, {|x| x[2] .and. x[3] } ) > 0
               AAdd( aBotoes, {"NOCHECKED", {|| EX401Amort("EST")}, STR0196,STR0196/*STR0197*/} )  //"Estorno da Liquidacao" # "Est.Liq." //FSM - 04/09/2012
            EndIf
         EndIf
      EndIf
   oDlg:lMaximized := .T.
   oDlgFocus := oDlg  // PLB 21/03/07 - Variavel utilizada para chamada da funcao AvSetFocus()

   ACTIVATE MSDIALOG oDlg ON INIT ((EnchoiceBar(oDlg,bBarOK,bBarCancel,,aBotoes),;
                                   oEnc:oBox:Align:=CONTROL_ALIGN_TOP,;          //LRL 03/06/04
                                   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT),;
                                   IIF(lCopiaCont .And. cMod == EXP .And. IIF(lEFFTPMod,M->EF1_CAMTRA=="1",lPrepag .And. M->EF1_TP_FIN $ PREPAGTO+"\"+SECURITIZACAO),EX401Recalc(),),; // PLB 23/04/07
                                   WorkEF3->( DBGoTop() ),;  //PLB 28/07/06
                                   oMark:oBrowse:Refresh(),; //PLB 25/10/06
                                   EX401VerRof()) //Alinhamento MDI
   lSai := .T.

   SET FILTER TO  //Para limpar qualquer filtro que tenha sido utilizado pelo usuário

   // ** PLB 21/07/06 - Tratamento Multi-Usuario
   aRLockList := EEQ->( DBRLockList() )
   For i := 1  to  Len(aRLockList)
      EEQ->( DBGoTo(aRLockList[i]) )
      EEQ->( MSUnLock() )
   Next i
   aRLockList := SWB->( DBRLockList() )
   For i := 1  to  Len(aRLockList)
      SWB->( DBGoTo(aRLockList[i]) )
      SWB->( MSUnLock() )
   Next i
   // **

   If nOpcao = 1
      WorkEF3->(dbSetOrder(2))
      dbSelectArea("EF1")
      If nOpc=INCLUIR .or. nOpc=ALTERAR
         /* - FSM - 28/02/2012
         If lPrePag .and. (M->EF1_TP_FIN == "03" .or. M->EF1_TP_FIN == "04") .and. nOpc=INCLUIR
            If !WorkEF3->(dbSeek(EV_PRINC_PREPAG))
               Processa({|| EX401Recalc() }, STR0206+If(M->EF1_TP_FIN == "03",STR0207,STR0208) ) //"Gerando parcelas de " # "Pré-Pagamento" / "Securitização"
            EndIf
         EndIf
         */
         EF1->(msUnlock())

         EasyEAIBuffer("INICIO")                                                                       //NCF - 11/09/2014

         Processa({|| If( !EX400GrvTudo(nOpc), lSai := .F.,) }, STR0021) //"Gravando Financiamento"

         If !EasyEAIBuffer("FIM",bOnError)                                            //NCF - 11/09/2014
            Af200RevFin()
         EndIf

      ElseIf nOpc=ESTORNAR
         If MSGYESNO(EX401STR(173),EX401STR(174))
            EF1->(msUnlock())
            Processa({|| EX400Estorna(nOpc)}, STR0022) //"Apagando Financiamento"
         Else
            EF1->(msUnlock())
         EndIf
      EndIf
      WorkEF3->(dbSetOrder(ORDEM_BROWSE))
   Else
      EF1->(msUnlock())
   EndIf

   aTela := {}
   aGets := {} //FSM - 28/02/2012
   aBotoes:={}
   aCols:= {}
   n:=0
   msUnlockAll()
   aHeader := {} //GFP - 05/06/2012

   If lSai
      Exit
   Endif
Enddo

Return .T.

*-----------------------*
Static Function IniCpos()
*-----------------------*
ProcRegua(5)

IncProc(STR0007) //"Inicializando Ambiente"
aSelCpos := BrowseCpos("EF3","WorkEF3")
AcertaCpos("1")

IncProc(STR0007) //"Inicializando Ambiente"
aSelCpos2:= BrowseCpos("EF2","WorkEF2")
//AcertaCpos("2")

IncProc(STR0007) //"Inicializando Ambiente"
/*
aSelCpos3:= {  {"MARCA",,""},;
               {"EF3_INVOIC",,AVSX3("EF3_INVOIC",5)},;
               {"EF3_PREEMB",,AVSX3("EF3_PREEMB",5)},;
               {"EF3_DT_FIX",,AVSX3("EF3_DT_FIX",5)},;
               {"EF3_MOE_IN",,AVSX3("EF3_MOE_IN",5)},;
               {"TIPCOM"+' '+If(TIPCOM $ '1', 'A Remeter', If(TIPCOM $ '2', 'Conta Gráfica', 'Deduzir da Fatura')) ,,AVSX3("EEC_TIPCOM",5)},;
               {"VALCOM"    ,,AVSX3("EEC_VALCOM",5)},;
               {"EF3_VL_INV",,AVSX3("EF3_VL_INV",5),AVSX3("EF3_VL_INV",6)} }
*/
IncProc(STR0007) //"Inicializando Ambiente"

// ACSJ - 08/01/2004 - Consiste a existencia dos campos EF1_EXPORT/EF1_LOJA/EF1_VM_EXP no EF1
// ----------------------------------------------------------------------------------------//
aMostraCpos := {}

Aadd(aMostraCpos, "EF1_CONTRA")
Aadd(aMostraCpos, "EF1_TP_FIN")
Aadd(aMostraCpos, "EF1_VM_FIN")
Aadd(aMostraCpos, "EF1_CC")
Aadd(aMostraCpos, "EF1_DESCCC")
Aadd(aMostraCpos, "EF1_MOEDA")
If cMod == EXP
   Aadd(aMostraCpos, "EF1_EXPORT")
   Aadd(aMostraCpos, "EF1_LOJA")
   Aadd(aMostraCpos, "EF1_VM_EXP")
   Aadd(aMostraCpos, "EF1_DT_VIN")
   Aadd(aMostraCpos, "EF1_TX_MOE") // GCC - 02/01/2014 - Adição do campo taxa para inclusão da parcela principal - 744644
   If AvFlags("SIGAEFF_SIGAFIN")
      SX3->(DBSetOrder(2))
      If SX3->(DBSeek("EF1_PROCTR"))
         AAdd(aMostraCpos, "EF1_PROCTR")
      EndIf
   EndIf
ElseIf cMod == IMP
   Aadd(aMostraCpos, "EF1_IMPORT")
   //Aadd(aMostraCpos, "EF1_LOJAIM")
   Aadd(aMostraCpos, "EF1_VM_IMP")
   Aadd(aMostraCpos, "EF1_LINCRE")
EndIf
Aadd(aMostraCpos, "EF1_TX_MOE") //MCF - 13/01/2016 - Replicado alteração para o EIC.
Aadd(aMostraCpos, "EF1_VL_MOE")
Aadd(aMostraCpos, "EF1_DT_CON")
Aadd(aMostraCpos, "EF1_DT_JUR")
Aadd(aMostraCpos, "EF1_MODPAG")
Aadd(aMostraCpos, "EF1_MDPDES")
Aadd(aMostraCpos, "EF1_DT_VEN")
Aadd(aMostraCpos, "EF1_BAN_FI")
Aadd(aMostraCpos, "EF1_DES_FI")
Aadd(aMostraCpos, "EF1_BAN_MO")
Aadd(aMostraCpos, "EF1_DES_MO")
Aadd(aMostraCpos, "EF1_TIP_PA")
Aadd(aMostraCpos, "EF1_TIP_VC")
Aadd(aMostraCpos, "EF1_CAMTRA")
//Aadd(aMostraCpos, "EF1_LIQFIX")  //PLB 17/02/06 - Campo EF1_LIQFIX excluido do Dicionario
Aadd(aMostraCpos, "EF1_SLD_PM")
Aadd(aMostraCpos, "EF1_SLD_PR")
Aadd(aMostraCpos, "EF1_SLD_JM")
Aadd(aMostraCpos, "EF1_SLD_JR")
Aadd(aMostraCpos, "EF1_VM_OBS")
Aadd(aMostraCpos, "EF1_DT_ENC")
If lTemPgJuros .And. cMod <> IMP //FSM - 07/03/2012
   Aadd(aMostraCpos, "EF1_PGJURO") // ACSJ - Caetano - 22/01/2005
Endif
If lEF1_JR_ANT .And. cMod <> IMP //FSM - 07/03/2012
   Aadd(aMostraCpos, "EF1_JR_ANT")
EndIf
If lEF1_LIQPER .And. cMod <> IMP //FSM - 07/03/2012
   Aadd(aMostraCpos, "EF1_LIQPER")
EndIf
//If lEF1_DTBONI  // PLB 14/09/06
   //Aadd(aMostraCpos, "EF1_DTBONI")
//EndIf

If EF1->( FieldPos("EF1_FORN") ) > 0 .AND. EF1->( FieldPos("EF1_LOJAFO") ) > 0
   Aadd(aMostraCpos, "EF1_FORN"  )
   Aadd(aMostraCpos, "EF1_LOJAFO")
EndIf
If lDataCred//FSY - 10/02/2014
   Aadd(aMostraCpos, "EF1_DTCRED"  )
EndIf


/*
aMostraCpos:= { "EF1_CONTRA" , "EF1_TP_FIN" , "EF1_VM_FIN" , "EF1_CC"     , "EF1_DESCCC" ,;
                "EF1_MOEDA"  , "EF1_EXPORT" , "EF1_LOJA" , "EF1_VM_EXP",;      //LRL 17/12/03
                "EF1_VL_MOE" , "EF1_DT_CON" , "EF1_DT_JUR" , "EF1_MODPAG" , "EF1_MDPDES" ,;
                "EF1_DT_VIN" ,;
                "EF1_DT_VEN" , "EF1_BAN_FI" , "EF1_DES_FI" , "EF1_BAN_MO" , "EF1_DES_MO" ,;
                "EF1_TIP_PA" , "EF1_TIP_VC" ,;
                "EF1_CAMTRA" , "EF1_LIQFIX" , "EF1_SLD_PM" , "EF1_SLD_PR" , "EF1_SLD_JM" ,;
                "EF1_SLD_JR" , "EF1_VM_OBS" , "EF1_DT_ENC" }*/
// ACSJ - 08/01/2004 ---------------------------------------------------------------------- //

IncProc(STR0007) //"Inicializando Ambiente"
aSelCpos4 := {  {"EF4_DATA"  ,,AVSX3("EF4_DATA"  ,5)},;
                {"EF4_HORA"  ,,AVSX3("EF4_HORA"  ,5)},;
                {"EF4_CAMPO" ,,AVSX3("EF4_CAMPO" ,5)},;
                {"EF4_DE"    ,,AVSX3("EF4_DE"    ,5)},;
                {"EF4_PARA"  ,,AVSX3("EF4_PARA"  ,5)},;
                {"EF4_USUARI",,AVSX3("EF4_USUARI",5)},;
                {"EF4_TP_EVE",,AVSX3("EF4_TP_EVE",5)},;
                {"EF4_PREEMB",,AVSX3("EF4_PREEMB",5)},;
                {"EF4_INVOIC",,AVSX3("EF4_INVOIC",5)},;
                {"EF4_PARC"  ,,AVSX3("EF4_PARC"  ,5)},;
                {"EF4_CODEVE",,AVSX3("EF4_CODEVE",5)} }
If lEF4_MOTIVO
   aAdd(aSelCpos4,NIL)
   aIns(aSelCpos4,6)
   aSelCpos4[6] := {"EF4_MOTIVO",,AVSX3("EF4_MOTIVO",5)}
EndIf

Return .T.

*-----------------------------------------------*
Function BrowseCpos(cAlias,cAliasDad,aTiraCampos)
*-----------------------------------------------*
Local aOrd := SaveOrd("SX3")
LOCAL aRet := {}
LOCAL aField

Default cAliasDad   := cAlias
Default aTiraCampos := {}

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))

Do While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias

   IF SX3->X3_NIVEL > cNivel .or. Upper(SX3->X3_BROWSE) != "S" .OR. aScan(aTiraCampos,{|X| AllTrim(X) == AllTrim(SX3->X3_CAMPO)}) > 0 // .or. SX3->X3_CONTEXT == "V"
      SX3->(dbSkip())
      Loop
   Endif

   aField := { Alltrim(SX3->X3_CAMPO),"", OemToAnsi(X3TITULO()),Alltrim(SX3->X3_PICTURE) }
   If Alltrim(SX3->X3_CAMPO) == "EF2_TIPJUR"
      aField := { { || WorkEF2->EF2_TIPJUR + " - " + FDESC("SX5","CV"+WorkEF2->EF2_TIPJUR,"X5_DESCRI") },"", OemToAnsi(X3TITULO()),"@!" }
   //ElseIf Alltrim(SX3->X3_CAMPO) == "EF2_BONUS"
      //aField := { { || BSCXBOX("EF2_BONUS",WorkEF2->EF2_BONUS) },"", OemToAnsi(X3TITULO()),"" }
   // ** PLB 13/09/06
   ElseIf Alltrim(SX3->X3_CAMPO) == "EF2_USEINV"
      aField := { { || BSCXBOX("EF2_USEINV",WorkEF2->EF2_USEINV) },"", OemToAnsi(X3TITULO()),"" }
   ElseIf Alltrim(SX3->X3_CAMPO) == "EF2_TP_FIN"
      aField := { { || WorkEF2->EF2_TP_FIN + " - " + IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+WorkEF2->EF2_TP_FIN,"EF7_DESCRI"),FDESC("SX5","CG"+WorkEF2->EF2_TP_FIN,"X5_DESCRI")) },"", OemToAnsi(X3TITULO()),"@!" }
   // **
   EndIf
   IF aField[1] != Nil
      aAdd(aRet,aField)
   Endif

   SX3->(dbSkip())
Enddo

RestOrd(aOrd)

Return aRet

*--------------------------*
Static Function EX400Works()
*--------------------------*
Local FileWork1, FileWork2, FileWork3, FileWork4, FileWork5, FileWork6, FileWork7, FileWork8
Local FileWork9, FileWork10, FileWork11, FileWork12, FileWork13, FileWorkI01, FileWorkI2, FileWorkTInv
Local FileWork14, FileWork15, FileWork16, FileWork17
Local aSemSX3EF3:={}, aSemSX3Est:={}, aSemSX3EF4:={}, aSemSX3TInv:= {}
Private aHeader[0]//, aCampos:=Array(EF1->(fCount()))  //E_CriaTrab utiliza #### THTS - 27/09/2017 - Quando nao existe o aCampos, o E_CriaTrab o cria.
Private aSemSX3Inv:={}

ProcRegua(8)

aSemSX3Inv := { {"MARCA","C",2,0} ,;
                {"EF3_INVOIC","C",AVSX3("EF3_INVOIC",3),0} ,;
                {"EF3_PREEMB","C",AVSX3("EF3_PREEMB",3),0} ,;
                {"EF3_DT_FIX","D",AVSX3("EF3_DT_FIX",3),0} ,;
                {"DT_VEN"    ,"D",AVSX3("EEQ_VCT",3),0} ,;
                {"EF3_MOE_IN","C",AVSX3("EF3_MOE_IN",3),0} ,;
                {"EF3_VL_INV","N",AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4)} ,;
                {"DT_AVERB"  ,"D",AVSX3("EE9_DTAVRB",3),0} ,;
                {"EF3_PARC"  ,"C",AVSX3("EF3_PARC",3),0} ,;
                {"VL_ORI"    ,"N",AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4)} ,;
                {"VL_INV"    ,"N",AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4)} ,;
                {"VL_PAR"    ,"N",AVSX3("EEQ_VL_PAR",3),AVSX3("EEQ_VL_PAR",4)} ,;
                {"FI_TOT"    ,"C",AVSX3("EEQ_FI_TOT",3),0} ,;
                {"TIPCOM"    ,"C",AVSX3("EEC_TIPCOM",3),0} ,;
                {"VALCOM"    ,"N",AVSX3("EEC_VALCOM",3),AVSX3("EEC_VALCOM",4)} ,;
                {"TIPCVL"    ,"C",AVSX3("EEC_TIPCVL",3),0},;
                {"DT_VINC"   ,"D",AVSX3("EE9_DTAVRB",3),0},;
                {"TX_VINC"   ,"N",AVSX3("EF3_TX_MOE",3),AVSX3("EF3_TX_MOE",4)},;
                {"BANC_INV"  ,"C",AVSX3("EEQ_BANC",3),0},;
                {"VL_VINC"   ,"N",AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4)},;
                {"VINCULADO" ,"N",AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4)},;
                {"PARFIN"    ,"C",AVSX3("EEQ_PARFIN",3),0},;
                {"DTEMBA"    ,"D",AVSX3("EEC_DTEMBA",3),0},;
                {"IMPORT"    ,"C",AVSX3("EEC_IMPORT",3),0},;
                {"IMPODE"    ,"C",AVSX3("EEC_IMPODE",3),0},;
                {"PAIS"      ,"C",AVSX3("EEC_PAISDT",3),0},;
                {"PAISDE"    ,"C",AVSX3("YA_DESCR",3),0},;
                {"DTCE"      ,"D",AVSX3("EEQ_DTCE",3),0},;
                {"EEQ_MODAL" ,"C",AVSX3("EEQ_MODAL",3),0},;
                {"TIPO"      ,"C",AVSX3("EEQ_TIPO",3),0}}

If EF3->(FieldPos("EF3_DTDOC")) >0
   aAdd( aSemSX3Inv, {"EF3_DTDOC" ,"D",AVSX3("EF3_DTDOC" ,3),0} )
EndIf

If lEFFTpMod

   aSemSX3TInv := { {"MARCA"  ,"C",2,0},;
                    {"PERMITE","C",3,0},;
                    {"EF3_SEQCNT","C",AVSX3("EF3_SEQCNT",3) ,0},;
                    {"EF3_FORN"  ,"C",AVSX3("EF3_FORN",3),0}   ,;
                    {"EF3_LOJAFO","C",AVSX3("EF3_LOJAFO",3) ,0},;
                    {"EF3_HAWB"  ,"C",AVSX3("EF3_HAWB",3),0}   ,;
                    {"EF3_INVOIC","C",AVSX3("EF3_INVOIC",3) ,0},;
                    {"EF3_PARC"  ,"C",AVSX3("EF3_PARC",3)   ,0},;
                    {"EF3_MOE_IN","C",AVSX3("EF3_MOE_IN",3) ,0},;
                    {"EF3_VL_INV","N",AVSX3("EF3_VL_INV",3) ,AVSX3("EF3_VL_INV",4)},;
                    {"EF3_VL_MOE","N",AVSX3("EF3_VL_MOE",3) ,AVSX3("EF3_VL_MOE",4)},;
                    {"EF3_TX_MOE","N",AVSX3("EF3_TX_MOE",3) ,AVSX3("EF3_TX_MOE",4)},;
                    {"EF3_VL_REA","N",AVSX3("EF3_VL_REA",3) ,AVSX3("EF3_VL_REA",4)},;
                    {"EF3_DT_EVE","D",AVSX3("EF3_DT_EVE",3) ,AVSX3("EF3_DT_EVE",4)},;
                    {"EF3_ORIGEM","C",AVSX3("EF3_ORIGEM",3) ,AVSX3("EF3_ORIGEM",4)},;
                    {"EF3_INVIMP","C",AVSX3("EF3_INVIMP",3) ,AVSX3("EF3_INVIMP",4)},;
                    {"EF3_LINHA" ,"C",AVSX3("EF3_LINHA",3)  ,0},;
                    {"RECNO"     ,"N", 7, 0} }

EndIf

If cMod == IMP
   aAdd(aSemSX3Inv,{"EF3_HAWB"  ,"C",AVSX3("EF3_HAWB"  ,3),0})
   aAdd(aSemSX3Inv,{"EF3_INVIMP","C",AVSX3("EF3_INVIMP",3),0})
   aAdd(aSemSX3Inv,{"EF3_LINHA" ,"C",AVSX3("EF3_LINHA" ,3),0})
   aAdd(aSemSX3Inv,{"EF3_FORN"  ,"C",AVSX3("EF3_FORN"  ,3),0})
   aAdd(aSemSX3Inv,{"EF3_LOJAFO","C",AVSX3("EF3_LOJAFO",3),0})
   aAdd(aSemSX3Inv,{"EF3_PO_DI" ,"C",AVSX3("EF3_PO_DI" ,3),0})
/* //NCF - 01/12/2014 - O campo já foi adicionado incondicionalmente acima.
Else
   If EF3->(FieldPos("EF3_DTDOC")) > 0// FSY - 17/04/2013
      aAdd(aSemSX3Inv,{"EF3_DTDOC" ,AVSX3("EF3_DTDOC" ,AV_TIPO),AVSX3("EF3_DTDOC" ,AV_TAMANHO),0})
   EndIf*/
EndIf

If lEFFTpMod
   aAdd(aSemSX3Inv,{"EF3_ORIGEM","C",AVSX3("EF3_ORIGEM",3),0})
EndIf

If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"WORK_INVOICES"),)

//LRL 14/12/04 - Filial Original ,conceito de Multifilais----------------------------------------------
Aadd(aSemSX3Inv,{"EF3_FILORI",AVSX3("EF3_FILIAL",2),AVSX3("EF3_FILIAL",3),AVSX3("EF3_FILIAL",4)})
//----------------------------------------------LRL 14/12/04 - Filial Original conceito de Multifilais

//TRP - 02/02/07 - Campos do WalkThru
AADD(aSemSX3Inv,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3Inv,{"TRB_REC_WT","N",10,0})

aSemSX3EF2 := { {"EF2_FILIAL","C",AVSX3("EF2_FILIAL",3),0} }

If lEFFTpMod
   aAdd(aSemSX3EF2,{"EF2_TPMODU","C",AVSX3("EF2_TPMODU",3),0}) // AAF 04/03/06 - Campo Tipo de Modulo - "I" - Importação e "E" - Exportação.
EndIf

aAdd(aSemSX3EF2,{"EF2_CONTRA","C",AVSX3("EF2_CONTRA",3),0}) // ACSJ - 09/02/2005

If lTemChave
   aAdd(aSemSX3EF2,{"EF2_BAN_FI","C",AVSX3("EF2_BAN_FI",3),0}) // ACSJ - 09/02/2005
   aAdd(aSemSX3EF2,{"EF2_PRACA", "C",AVSX3("EF2_PRACA", 3),0}) // ACSJ - 09/02/2005
   If lEFFTpMod
      aAdd(aSemSX3EF2,{"EF2_SEQCNT", "C",AVSX3("EF2_SEQCNT", 3),0}) // AAF 04/03/06 - Campo Sequência do Contrato.
   EndIf
EndIf
If lLiqPeriodo  // PLB 28/05/07
   AAdd( aSemSX3EF2, { "EF2_SEQPER", AVSX3("EF2_SEQPER", AV_TIPO), AVSX3("EF2_SEQPER", AV_TAMANHO), AVSX3("EF2_SEQPER", AV_DECIMAL) } )
EndIf
aAdd(aSemSX3EF2,{"EF2_RECNO","N",10,0})

//TRP - 02/02/07 - Campos do WalkThru
AADD(aSemSX3EF2,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3EF2,{"TRB_REC_WT","N",10,0})

aSemSX3EF3 := { {"EF3_FILIAL","C",AVSX3("EF3_FILIAL",3),0} }

If lEFFTpMod
   aAdd(aSemSX3EF3,{"EF3_TPMODU","C",AVSX3("EF3_TPMODU",3),0}) // AAF 04/03/06 - Campo Tipo de Modulo - "I" - Importação e "E" - Exportação.
EndIf

aAdd(aSemSX3EF3,{"EF3_CONTRA","C",AVSX3("EF3_CONTRA",3),0})

If lTemChave
   aAdd(aSemSX3EF3,{"EF3_BAN_FI","C",AVSX3("EF3_BAN_FI",3),0})  // ACSJ - 09/02/2005
   aAdd(aSemSX3EF3,{"EF3_AGENFI","C",AVSX3("EF3_AGENFI",3),0})
   aAdd(aSemSX3EF3,{"EF3_NCONFI","C",AVSX3("EF3_NCONFI",3),0})
   aAdd(aSemSX3EF3,{"EF3_PRACA", "C",AVSX3("EF3_PRACA", 3),0})  // ACSJ - 09/02/2005
   If lEFFTpMod
      aAdd(aSemSX3EF3,{"EF3_SEQCNT","C",AVSX3("EF3_SEQCNT",3),0}) // AAF 04/03/06 - Campo Sequência do Contrato.
   EndIf
   aAdd(aSemSX3EF3,{"EF3_OBS", "C",AVSX3("EF3_OBS", 3),0})  // ACSJ - 09/02/2005
EndIf
aAdd(aSemSX3EF3,{"EF3_TP_EVE","C",AVSX3("EF3_TP_EVE",3),0})
aAdd(aSemSX3EF3,{"EF3_SEQ"   ,"C",AVSX3("EF3_SEQ"   ,3),0})
aAdd(aSemSX3EF3,{"EF3_PARC"  ,"C",AVSX3("EF3_PARC"  ,3),0})

//LGS-08/05/2014 - Campos Integração EEC via Mensagem Única
If EF3->(FieldPos("EF3_TPTIT"))>0
	aAdd(aSemSX3EF3,{"EF3_TPTIT"  ,"C",AVSX3("EF3_TPTIT"  ,3),0})
EndIf
If EF3->(FieldPos("EF3_PREFIX"))>0
	aAdd(aSemSX3EF3,{"EF3_PREFIX" ,"C",AVSX3("EF3_PREFIX" ,3),0})
EndIf
If EF3->(FieldPos("EF3_RELACA"))>0
	aAdd(aSemSX3EF3,{"EF3_RELACA" ,"C",AVSX3("EF3_RELACA" ,3),0})
EndIf
/*
If lTemChave
   aAdd(aSemSX3EF3,{"EF3_BANC"  ,"C",AVSX3("EF3_BANC"  ,3),0})
   aAdd(aSemSX3EF3,{"EF3_AGEN"  ,"C",AVSX3("EF3_AGEN"  ,3),0})
   aAdd(aSemSX3EF3,{"EF3_NCON"  ,"C",AVSX3("EF3_NCON"  ,3),0})
EndIf
*/
If lEF3_EV_FO
   aAdd(aSemSX3EF3,{"EF3_EV_FO" ,"C",AVSX3("EF3_EV_FO" ,3),0})
EndIf

// ** GFC - Pré-Pagamento/Securitização
If lPrePag
   aAdd(aSemSX3EF3,{"EF3_SLDLIQ","N",AVSX3("EF3_SLDLIQ",3),AVSX3("EF3_SLDLIQ",4)})
   aAdd(aSemSX3EF3,{"EF3_LIQ_RS","N",AVSX3("EF3_LIQ_RS",3),AVSX3("EF3_LIQ_RS",4)})
EndIf
// **

If lEFFTpMod
   aAdd(aSemSX3EF3,{"EF3_ORIGEM",AVSX3("EF3_ORIGEM",2),AVSX3("EF3_ORIGEM",3),AVSX3("EF3_ORIGEM",4)})
EndIf
// GFP - 09/10/2015
//If lRefinimp  // MPG - 25/10/2018
   AAdd(aSemSX3EF3,{"ALTERADO","L",1,0})
//EndIf

aAdd(aSemSX3EF3,{"EF3_RECNO" ,"N",10,0})

//TRP - 02/02/07 - Campos do WalkThru
AADD(aSemSX3EF3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3EF3,{"TRB_REC_WT","N",10,0})


//LRL 14/12/04 - Filial Original ,conceito de Multifilais----------------------------------------------
If LMultiFil
   Aadd(aSemSX3EF3,{"EF3_FILORI",AVSX3("EF3_FILIAL",2),AVSX3("EF3_FILIAL",3),AVSX3("EF3_FILIAL",4)})
EndIF
//----------------------------------------------LRL 14/12/04 - Filial Original conceito de Multifilais

// ** AAF - 07/11/05 - Transferência de Contrato.
If lEF3_CTDEST
   aAdd(aSemSX3EF3,{"EF3_CTDEST",AVSX3("EF3_CTDEST",2),AVSX3("EF3_CTDEST",3),AVSX3("EF3_CTDEST",4)})
   aAdd(aSemSX3EF3,{"EF3_PRDEST",AVSX3("EF3_PRDEST",2),AVSX3("EF3_PRDEST",3),AVSX3("EF3_PRDEST",4)})
EndIf
// **
If lLiqPeriodo  // PLB 28/05/07
   AAdd( aSemSX3EF3, { "EF3_SEQPER", AVSX3("EF3_SEQPER", AV_TIPO), AVSX3("EF3_SEQPER", AV_TAMANHO), AVSX3("EF3_SEQPER", AV_DECIMAL) } )
EndIf

If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
   AAdd( aSemSX3EF3, { "EF3_NUMTIT", AVSX3("EF3_NUMTIT", AV_TIPO), AVSX3("EF3_NUMTIT", AV_TAMANHO), AVSX3("EF3_NUMTIT", AV_DECIMAL) } )
   AAdd( aSemSX3EF3, { "EF3_PARTIT", AVSX3("EF3_PARTIT", AV_TIPO), AVSX3("EF3_PARTIT", AV_TAMANHO), AVSX3("EF3_PARTIT", AV_DECIMAL) } )
   // BAK - Tratamento para integrado o logix
   //If lLogix - Nopado por AAF - 13/09/2013 - Sempre deve criar o campo EF3_TITFIN na work quando a integração com SIGAFIN ou LOGIX estiver ligada.
      AAdd( aSemSX3EF3, { "EF3_TITFIN", AVSX3("EF3_TITFIN", AV_TIPO), AVSX3("EF3_TITFIN", AV_TAMANHO), AVSX3("EF3_TITFIN", AV_DECIMAL) } )
      AAdd( aSemSX3EF3, { "EF3_SEQBX", AVSX3("EF3_SEQBX", AV_TIPO), AVSX3("EF3_SEQBX", AV_TAMANHO), AVSX3("EF3_SEQBX", AV_DECIMAL) } )               //NCF - 20/06/2016 - Colocar também o Sq.Bx
   //EndIf
EndIf

//MCF - 26/07/2016
If lEF3Ct
   aAdd(aSemSX3EF3,{"EF3_DT_CTB",AVSX3("EF3_DT_CTB",AV_TIPO),AVSX3("EF3_DT_CTB",AV_TAMANHO),AVSX3("EF3_DT_CTB",AV_DECIMAL)})
   aAdd(aSemSX3EF3,{"EF3_TX_CTB",AVSX3("EF3_TX_CTB",AV_TIPO),AVSX3("EF3_TX_CTB",AV_TAMANHO),AVSX3("EF3_TX_CTB",AV_DECIMAL)})
   aAdd(aSemSX3EF3,{"EF3_DT_ANT",AVSX3("EF3_DT_ANT",AV_TIPO),AVSX3("EF3_DT_ANT",AV_TAMANHO),AVSX3("EF3_DT_ANT",AV_DECIMAL)})
   aAdd(aSemSX3EF3,{"EF3_TX_ANT",AVSX3("EF3_TX_ANT",AV_TIPO),AVSX3("EF3_TX_ANT",AV_TAMANHO),AVSX3("EF3_TX_ANT",AV_DECIMAL)})
EndIf

aSemSX3EF4 := {}

aAdd(aSemSX3EF4,{"EF4_RECNO" ,"N",10,0} )

//TRP - 02/02/07 - Campos do WalkThru
AADD(aSemSX3EF4,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3EF4,{"TRB_REC_WT","N",10,0})

aSemSX3Est := { {"ECE_CONTRA","C",AVSX3("ECE_CONTRA",3),0} }
If lTemChave
   aAdd(aSemSX3Est,{"ECE_BANCO" ,"C",AVSX3("ECE_BANCO" ,3),0})
   aAdd(aSemSX3Est,{"ECE_PRACA" ,"C",AVSX3("ECE_PRACA" ,3),0})
   If lEFFTpMod .AND. ChkFile("ECE") .AND. ECE->( FieldPos("ECE_SEQCNT") ) > 0
      aAdd(aSemSX3Est,{"ECE_SEQCNT","C",AVSX3("ECE_SEQCNT",3),0})
   EndIf
EndIf
aAdd(aSemSX3Est,{"ECE_PREEMB","C",AVSX3("ECE_PREEMB",3),0})
aAdd(aSemSX3Est,{"ECE_INVEXP","C",AVSX3("ECE_INVEXP",3),0})
aAdd(aSemSX3Est,{"ECE_SEQ"   ,"C",AVSX3("ECE_SEQ"   ,3),0})
aAdd(aSemSX3Est,{"ECE_IDENTC","C",AVSX3("ECE_IDENTC",3),0})
aAdd(aSemSX3Est,{"DESC_EVENT","C",AVSX3("EC6_DESC"  ,3),0})
aAdd(aSemSX3Est,{"ECE_ID_CAM","C",AVSX3("ECE_ID_CAM",3),0})
aAdd(aSemSX3Est,{"TIPO_EVE"  ,"C",03                   ,0})
aAdd(aSemSX3Est,{"ECE_CTA_DB","C",AVSX3("ECE_CTA_DB",3),0})
aAdd(aSemSX3Est,{"ECE_CTA_CR","C",AVSX3("ECE_CTA_CR",3),0})
aAdd(aSemSX3Est,{"ECE_VL_MOE","N",AVSX3("ECE_VL_MOE",3),AVSX3("ECE_VL_MOE",4)})
aAdd(aSemSX3Est,{"ECE_TX_ATU","N",AVSX3("ECE_TX_ATU",3),AVSX3("ECE_TX_ATU",4)})
aAdd(aSemSX3Est,{"ECE_VALOR" ,"N",AVSX3("ECE_VALOR" ,3),AVSX3("ECE_VALOR" ,4)})

If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"aSemSX3"),)

//WorkEF2
IncProc(STR0023) //"Criando Arquivo Temporário 1"
FileWork1:=E_CriaTrab("EF2",aSemSX3EF2,"WorkEF2",,.F.)
Aadd(aTabelas,{"WorkEF2",FileWork1})
If lLiqPeriodo
   FileWork14 := E_Create(,.F.)
   Aadd( aTabelas, { , FileWork14 } )
EndIf


IncProc(STR0023) //"Criando Arquivo Temporário 1"
IndRegua("WorkEF2",FileWork1+TEOrdBagExt(),If(lEF2_INVOIC,"EF2_FILORI+EF2_INVOIC+EF2_PARC+","")+"EF2_TP_FIN+"+If(lEF2_TIPJUR,"EF2_TIPJUR+","")+"DtoS(EF2_DT_INI)+DtoS(EF2_DT_FIM)")
// ** PLB 28/05/07
If lLiqPeriodo
   IndRegua("WorkEF2",FileWork14+TEOrdBagExt() ,"EF2_SEQPER")
   SET INDEX TO (FileWork1+TEOrdBagExt()),(FileWork14+TEOrdBagExt())
Else
   SET INDEX TO (FileWork1+TEOrdBagExt())
EndIf
// **



//WorkEF3
IncProc(STR0024) //"Criando Arquivo Temporário 2"
FileWork2:=E_CriaTrab("EF3",aSemSX3EF3,"WorkEF3",,.F.)
Aadd(aTabelas,{"WorkEF3",FileWork2})
FileWork3:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork3})
FileWork4:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork4})
FileWork5:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork5})
FileWork9:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork9})
FileWork10:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork10})
FileWork12:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork12})
FileWork13:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork13})
FileWork18:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork18})

If cMod == IMP  // PLB 26/06/06
   FileWorkI01:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWorkI01})
   FileWorkI2:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWorkI2})
EndIf

IncProc(STR0024) //"Criando Arquivo Temporário 2"
IndRegua("WorkEF3",FileWork2+TEOrdBagExt()  ,"EF3_SEQ+EF3_CODEVE")
IndRegua("WorkEF3",FileWork3+TEOrdBagExt()  ,"EF3_CODEVE+EF3_INVOIC+EF3_PARC+DtoS(EF3_DT_EVE)")
IndRegua("WorkEF3",FileWork4+TEOrdBagExt()  ,"EF3_INVOIC+EF3_PARC+EF3_PREEMB")
IndRegua("WorkEF3",FileWork5+TEOrdBagExt()  ,"EF3_SEQ")
IndRegua("WorkEF3",FileWork9+TEOrdBagExt()  ,"EF3_CODEVE") //IndRegua("WorkEF3",FileWork9+OrdBagExt(),"EF3_CONTRA+"+If(lTemChave,"EF3_BAN_FI+EF3_PRACA+","")+"EF3_CODEVE")
// ** PLB 28/05/07 - Inclui sequencia do Periodo caso exista tratamento para Baixa Manual de Juros por Período
If lLiqPeriodo
   IndRegua("WorkEF3",FileWork10+TEOrdBagExt() ,"EF3_INVOIC+EF3_PARC+EF3_CODEVE+EF3_SEQPER")
Else
   IndRegua("WorkEF3",FileWork10+TEOrdBagExt() ,"EF3_INVOIC+EF3_PARC+EF3_CODEVE")
EndIf
// **
IndRegua("WorkEF3",FileWork12+TEOrdBagExt() ,"EF3_INVOIC+EF3_CODEVE")

If lPrePag
   IndRegua("WorkEF3",FileWork13+TEOrdBagExt(),"DtoS(EF3_DT_EVE)+EF3_EV_VIN+EF3_CODEVE")
Else
   IndRegua("WorkEF3",FileWork13+TEOrdBagExt(),"DtoS(EF3_DT_EVE)+EF3_CODEVE")
EndIf

If cMod == IMP
   IndRegua("WorkEF3",FileWorkI01+TEOrdBagExt(),"EF3_CODEVE+EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA")
   IndRegua("WorkEF3",FileWorkI2+TEOrdBagExt(),"EF3_INVIMP+EF3_LINHA+EF3_CODEVE")  // PLB 25/10/06 - Utilizado para validação do filtro por invoice
   If lRefinimp  // GFP - 09/10/2015
      IndRegua("WorkEF3",FileWork18+TEOrdBagExt(),"EF3_FILIAL+EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR")
      SET INDEX TO (FileWork2+TEOrdBagExt()),(FileWork3+TEOrdBagExt()),(FileWork4+TEOrdBagExt()),(FileWork5+TEOrdBagExt()),(FileWork9+TEOrdBagExt()),(FileWork10+TEOrdBagExt()),(FileWork12+TEOrdBagExt()),(FileWork13+TEOrdBagExt()),(FileWorkI01+TEOrdBagExt()),(FileWorkI2+TEOrdBagExt()),(FileWork18+TEOrdBagExt())
   Else
      SET INDEX TO (FileWork2+TEOrdBagExt()),(FileWork3+TEOrdBagExt()),(FileWork4+TEOrdBagExt()),(FileWork5+TEOrdBagExt()),(FileWork9+TEOrdBagExt()),(FileWork10+TEOrdBagExt()),(FileWork12+TEOrdBagExt()),(FileWork13+TEOrdBagExt()),(FileWorkI01+TEOrdBagExt()),(FileWorkI2+TEOrdBagExt())
   EndIf
Else
   SET INDEX TO (FileWork2+TEOrdBagExt()),(FileWork3+TEOrdBagExt()),(FileWork4+TEOrdBagExt()),(FileWork5+TEOrdBagExt()),(FileWork9+TEOrdBagExt()),(FileWork10+TEOrdBagExt()),(FileWork12+TEOrdBagExt()),(FileWork13+TEOrdBagExt())
EndIf

//WorkInv
IncProc(STR0025) //"Criando Arquivo Temporário 3"

//THTS - 26/09/2017 - TE-6431 - Temporario no Banco de Dados
FileWork6 := E_CriaTrab(,aSemSX3Inv,"WorkInv")

Aadd(aTabelas,{"WorkInv",FileWork6})
FileWork8:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork8})
FileWork10:=E_Create(,.F.)
Aadd(aTabelas,{,FileWork10})

IncProc(STR0025) //"Criando Arquivo Temporário 3"
IndRegua("WorkInv",FileWork6 +TEOrdBagExt(),"EF3_FILORI+EF3_PREEMB+DtoS(EF3_DT_FIX)+EF3_INVOIC")
IndRegua("WorkInv",FileWork8 +TEOrdBagExt(),"EF3_FILORI+EF3_PREEMB+EF3_INVOIC+EF3_PARC")
IndRegua("WorkInv",FileWork10+TEOrdBagExt(),"EF3_FILORI+EF3_INVOIC+EF3_PARC")

SET INDEX TO (FileWork6+TEOrdBagExt()), (FileWork8+TEOrdBagExt()), (FileWork10+TEOrdBagExt())

//WorkEst
IncProc(STR0075) //"Criando Arquivo Temporário 4"

//THTS - 26/09/2017 - TE-6431 - Temporario no Banco de Dados
FileWork7 := E_CriaTrab(,aSemSX3Est,"WorkEst")

Aadd(aTabelas,{"WorkEst",FileWork7})

//WorkEF4
IncProc(Left(STR0075,Len(STR0075)-1)+"5") //"Criando Arquivo Temporário 5"
FileWork11:=E_CriaTrab("EF4",aSemSX3EF4,"WorkEF4",,.F.)
Aadd(aTabelas,{"WorkEF4",FileWork11})

If lEFFTpMod
   //WorkTInv
   IncProc(Left(STR0075,Len(STR0075)-1)+"6") //"Criando Arquivo Temporário 6"

   //THTS - 26/09/2017 - TE-6431 - Temporario no Banco de Dados
   FileWorkTInv := E_CriaTrab(,aSemSX3TInv,"WorkTInv")

   Aadd(aTabelas,{"WorkTInv",FileWorkTInv})
   FileWorkT0:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWorkT0})
   FileWorkT1:=E_Create(,.F.)
   Aadd(aTabelas,{,FileWorkT1})

   IndRegua("WorkTInv",FileWorkT0+TEOrdBagExt(),"MARCA")
   IndRegua("WorkTInv",FileWorkT1+TEOrdBagExt(),"PERMITE")

   SET INDEX TO (FileWorkT0+TEOrdBagExt()),(FileWorkT1+TEOrdBagExt())
EndIf

If lRefinimp  // GFP - 09/10/2015
   aSemSX3 := {}
   AADD(aSemSX3,{"EF2_CONTRA",AvSX3("EF2_CONTRA",AV_TIPO),AvSX3("EF2_CONTRA",AV_TAMANHO),AvSX3("EF2_CONTRA",AV_DECIMAL)})
   AADD(aSemSX3,{"EF1_BAN_FI",AvSX3("EF1_BAN_FI",AV_TIPO),AvSX3("EF1_BAN_FI",AV_TAMANHO),AvSX3("EF1_BAN_FI",AV_DECIMAL)})
   AADD(aSemSX3,{"EF1_PRACA" ,AvSX3("EF1_PRACA",AV_TIPO) ,AvSX3("EF1_PRACA",AV_TAMANHO) ,AvSX3("EF1_PRACA",AV_DECIMAL)})
   AADD(aSemSX3,{"EF1_SEQCNT",AvSX3("EF1_SEQCNT",AV_TIPO),AvSX3("EF1_SEQCNT",AV_TAMANHO),AvSX3("EF1_SEQCNT",AV_DECIMAL)})
   AADD(aSemSX3,{"DT_VINC"   ,AvSX3("EF1_DT_VEN",AV_TIPO),AvSX3("EF1_DT_VEN",AV_TAMANHO),AvSX3("EF1_DT_VEN",AV_DECIMAL)})
   AADD(aSemSX3,{"VL_VINC"   ,AvSX3("EF3_VL_MOE",AV_TIPO),AvSX3("EF3_VL_MOE",AV_TAMANHO),AvSX3("EF3_VL_MOE",AV_DECIMAL)})
   AADD(aSemSX3,{"TX_VINC"   ,AvSX3("EF3_TX_MOE",AV_TIPO),AvSX3("EF3_TX_MOE",AV_TAMANHO),AvSX3("EF3_TX_MOE",AV_DECIMAL)})
   AADD(aSemSX3,{"VL_MNAC"   ,AvSX3("EF3_VL_MOE",AV_TIPO),AvSX3("EF3_VL_MOE",AV_TAMANHO),AvSX3("EF3_VL_MOE",AV_DECIMAL)})
   AADD(aSemSX3,{"EF1_MOEDA" ,AvSX3("EF1_MOEDA" ,AV_TIPO),AvSX3("EF1_MOEDA" ,AV_TAMANHO),AvSX3("EF1_MOEDA" ,AV_DECIMAL)})
   AADD(aSemSX3,{"EF1_DT_VEN",AvSX3("EF1_DT_VEN",AV_TIPO),AvSX3("EF1_DT_VEN",AV_TAMANHO),AvSX3("EF1_DT_VEN",AV_DECIMAL)})

   AADD(aSemSX3,{"EF3_TPMOOR",AvSX3("EF3_TPMOOR",AV_TIPO),AvSX3("EF3_TPMOOR",AV_TAMANHO),AvSX3("EF3_TPMOOR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_CONTOR",AvSX3("EF3_CONTOR",AV_TIPO),AvSX3("EF3_CONTOR",AV_TAMANHO),AvSX3("EF3_CONTOR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_BAN_OR",AvSX3("EF3_BAN_OR",AV_TIPO),AvSX3("EF3_BAN_OR",AV_TAMANHO),AvSX3("EF3_BAN_OR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_PRACOR",AvSX3("EF3_PRACOR",AV_TIPO),AvSX3("EF3_PRACOR",AV_TAMANHO),AvSX3("EF3_PRACOR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_SQCNOR",AvSX3("EF3_SQCNOR",AV_TIPO),AvSX3("EF3_SQCNOR",AV_TAMANHO),AvSX3("EF3_SQCNOR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_CDEVOR",AvSX3("EF3_CDEVOR",AV_TIPO),AvSX3("EF3_CDEVOR",AV_TAMANHO),AvSX3("EF3_CDEVOR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_PARCOR",AvSX3("EF3_PARCOR",AV_TIPO),AvSX3("EF3_PARCOR",AV_TAMANHO),AvSX3("EF3_PARCOR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_IVIMOR",AvSX3("EF3_IVIMOR",AV_TIPO),AvSX3("EF3_IVIMOR",AV_TAMANHO),AvSX3("EF3_IVIMOR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_LINOR" ,AvSX3("EF3_LINOR",AV_TIPO) ,AvSX3("EF3_LINOR",AV_TAMANHO) ,AvSX3("EF3_LINOR",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_VL_MOE",AvSX3("EF3_VL_MOE",AV_TIPO),AvSX3("EF3_VL_MOE",AV_TAMANHO),AvSX3("EF3_VL_MOE",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_TX_MOE",AvSX3("EF3_TX_MOE",AV_TIPO),AvSX3("EF3_TX_MOE",AV_TAMANHO),AvSX3("EF3_TX_MOE",AV_DECIMAL)})
   AADD(aSemSX3,{"EF3_MOE_IN",AvSX3("EF3_MOE_IN",AV_TIPO),AvSX3("EF3_MOE_IN",AV_TAMANHO),AvSX3("EF3_MOE_IN",AV_DECIMAL)})

   //THTS - 26/09/2017 - TE-6431 - Temporario no Banco de Dados 
   AADD(aSemSX3 , {"DBDELETE","L",1,0}) 
   FileWork15 := E_CriaTrab(,aSemSX3,"WKREFINIMP")

   FileWork16:=E_Create(,.F.)
   FileWork17:=E_Create(,.F.)

   IndRegua("WKREFINIMP",FileWork16+TEOrdBagExt(),"EF3_CONTOR+EF3_LINOR+EF3_CDEVOR")
   IndRegua("WKREFINIMP",FileWork17+TEOrdBagExt(),"EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR")

   SET INDEX TO (FileWork16+TEOrdBagExt()),(FileWork17+TEOrdBagExt())

   Aadd(aTabelas,{"WKREFINIMP",FileWork15})
   Aadd(aTabelas,{,FileWork16})
   Aadd(aTabelas,{,FileWork17})
EndIf

Return .T.

*-----------------------------*
Static Function EX400DelWorks()
*-----------------------------*
Local W

FOR W := 1 TO LEN(aTabelas)
   If !Empty(aTabelas[W,1])
      (aTabelas[W,1])->(E_EraseArq(aTabelas[W,2]))
   Else
      FERASE(aTabelas[W,2]+TEOrdBagExt())
   EndIf
NEXT
aTabelas:={}

dbSelectArea("EF1")

Return .T.

*----------------------------*
Static Function LimpaTabelas()
*----------------------------*
Local W
ProcRegua(Len(aTabelas))

WorkEF3->(dbSetOrder(0))

FOR W := 1 TO LEN(aTabelas)
   IncProc(STR0026+Alltrim(Str(W))) //"Criando Arquivo Temporário "
   If !Empty(aTabelas[W,1])
      (aTabelas[W,1])->(avzap())
   EndIf
NEXT

Return .T.

*-----------------------------------------------------------------------------------------------------*
Static Function EX400GrvWorks(nTipo,lCopiaCont)
*-----------------------------------------------------------------------------------------------------*
Local cCodEve := ""
Local cCampo, EF3TotCpos:=EF3->(FCount()), EF2TotCpos:=EF2->(FCount()), i
Local aOrd

If(lCopiaCont=NIL,lCopiaCont:=.F.,)
If(nTipo<>INCLUIR, ProcRegua(2), ProcRegua(1))

If nTipo<>INCLUIR .or. lCopiaCont
   //WorkEF2
   IncProc(STR0027) //"Processando..."
   dbSelectArea("EF2")
   EF2->(dbSetOrder(1))
   If EF2->(dbSeek(xFilial("EF2")+If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+iif(lTemChave,EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),"")))
      Do While !EF2->(EOF()) .AND. EF2->EF2_FILIAL==xFilial("EF2") .AND. If(lEFFTpMod,EF2->EF2_TPMODU == EF1->EF1_TPMODU,.T.) .AND. EF2->EF2_CONTRA==EF1->EF1_CONTRA .and.;
               If(lTemChave,EF2->EF2_BAN_FI == EF1->EF1_BAN_FI .and. EF2->EF2_PRACA == EF1->EF1_PRACA .AND. if(lEFFTpMod,EF2->EF2_SEQCNT == EF1->EF1_SEQCNT,.T.),.T.) // ACSJ - 09/02/2005

         WorkEF2->(RecLock("WorkEF2",.T.))
         FOR i := 1 TO EF2TotCpos
            cCampo:=FIELDNAME(i)
            WorkEF2->&(cCampo) := EF2->&(cCampo)
         NEXT i
         WorkEF2->EF2_RECNO  := EF2->(RECNO())
         WorkEF2->TRB_ALI_WT := "EF2"
         WorkEF2->TRB_REC_WT := EF2->(Recno())
         WorkEF2->(msUnlock())

         EF2->(dbSkip())
      EndDo
      WorkEF2->(dbGoTop())
   EndIf
EndIf

//WorkEF3
IncProc(STR0027) //"Processando..."
If nTipo<>INCLUIR .or. lCopiaCont
   dbSelectArea("EF3")
   EF3->(dbSetOrder(1))
   If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+iif(lTemChave,EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),"")))
      Do While !EF3->(EOF()) .AND. EF3->EF3_FILIAL==xFilial("EF3") .and. If(lEFFTpMod,EF3->EF3_TPMODU == EF1->EF1_TPMODU,.T.) .AND. EF3->EF3_CONTRA==EF1->EF1_CONTRA .and.;
      If(lTemChave,EF3->EF3_BAN_FI == EF1->EF1_BAN_FI .and. EF3->EF3_PRACA == EF1->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == EF1->EF1_SEQCNT,.T.),.T.)  // ACSJ - 09/02/2005
         //If !lCopiaCont .or. ( cMod == EXP .And.  (EF3->EF3_CODEVE $ (EV_PRINC+"/"+EV_PRINC_PREPAG) .or.;  // PLB 22/09/06 - Para FINIMP nao copia parcelas de pagamento
         //Left(EF3->EF3_CODEVE,2) $ (Left(EV_JUROS_PREPAG,2))))
         // PLB 23/04/07 - Não copia Parcelas de Pagamento caso exista
         If !lCopiaCont .or. ( cMod == EXP .And. EF3->EF3_CODEVE == EV_PRINC )
            WorkEF3->(RecLock("WorkEF3",.T.))
            FOR i := 1 TO EF3TotCpos
               cCampo:=FIELDNAME(i)
               WorkEF3->&(cCampo) := EF3->&(cCampo)
            NEXT i
            // ** PLB 29/06/07 - Não copia dados contabeis
            If lCopiaCont
               WorkEF3->EF3_NR_CON := ""
               /* não copiar dados de integração com o SIGAFIN */
               WorkEF3->EF3_TITFIN := ""
               If lLogix //NCF - 18/02/2019
                  WorkEF3->EF3_RELACA := ""
                  WorkEF3->EF3_NRLOTE := ""    
               EndIf
            EndIf
            // **
            //ER - 07/12/2006
            WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", EF3->EF3_CODEVE)
            // ** PLB 19/12/06 - Caso nao encontre o evento
            If Empty(WorkEF3->EF3_DESCEV)  .And.  Left(WorkEF3->EF3_CODEVE,2) $ EVENTOS_DE_JUROS  // (510,520,550,640,650,670)
               If Left(WorkEF3->EF3_CODEVE,2) == Left(EV_VC_PJ1,2)  .And.  ( Val(WorkEF3->EF3_CODEVE) % 2 ) != 0   // 550  .And.  Impar
                  cCodEve := Left(WorkEF3->EF3_CODEVE,2)+"1"
               Else
                  cCodEve := Left(WorkEF3->EF3_CODEVE,2)+"0"
               EndIf
               WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", cCodEve)
            EndIf
            // **

            If AvFlags("SIGAEFF_SIGAFIN")
               WorkEF3->EF3_NUMTIT := Posicione("SE2",1,WorkEF3->EF3_TITFIN,"E2_NUM")
               WorkEF3->EF3_PARTIT := Posicione("SE2",1,WorkEF3->EF3_TITFIN,"E2_PARCELA")

		ElseIf WorkEF3->(FieldPos("EF3_NUMTIT")) > 0 .And. WorkEF3->(FieldPos("EF3_TITFIN")) > 0 // FSM - 27/01/2012
		       WorkEF3->EF3_NUMTIT := WorkEF3->EF3_TITFIN
            EndIf

            WorkEF3->EF3_RECNO  := EF3->(RECNO())
            WorkEF3->TRB_ALI_WT := "EF3"
            WorkEF3->TRB_REC_WT := EF3->(Recno())

            If !lCopiaCont .AND. WorkEF3->(FieldPos("EF3_TITFIN"))>0
               WorkEF3->EF3_TITFIN := EF3->EF3_TITFIN
            EndIf
            // GFP - 09/10/2015
            //If lRefinimp  // MPG - 25/10/2018
               WorkEF3->ALTERADO := .F.
            //EndIf

            WorkEF3->(msUnlock())
            If lCopiaCont .and. WorkEF3->EF3_CODEVE == EV_PRINC
               M->EF1_SLD_PM := WorkEF3->EF3_VL_MOE
               M->EF1_SLD_PR := WorkEF3->EF3_VL_REA
               M->EF1_SLD_JM := 0
               M->EF1_SLD_JR := 0
               M->EF1_SL2_PM := 0
               M->EF1_SL2_PR := 0
               M->EF1_SL2_JM := 0
               M->EF1_SL2_JR := 0
               M->EF1_LIQPRM := 0
               M->EF1_LIQPRR := 0
               M->EF1_LIQJRM := 0
               M->EF1_LIQJRR := 0
               // PLB 13/06/07
               //M->EF1_DT_CTB := M->EF1_DT_JUR
               //M->EF1_TX_CTB := WorkEF3->EF3_TX_MOE
            EndIf

            If AvFlags("SIGAEFF_SIGAFIN") .And. WorkEF3->EF3_CODEVE == EV_PRINC
               M->EF1_PROCTR:= SubStr(WorkEF3->EF3_TITFIN, TamSx3("EF1_FILIAL")[1]+1, TamSx3("E5_PROCTRA")[1])
            EndIf
         EndIf

         EF3->(dbSkip())
      EndDo
      WorkEF3->(dbGoTop())
   EndIf

   If lRefinimp  // GFP - 09/10/2015
      aOrd := SaveOrd("EF3")
      Do While WorkEF3->(!Eof())
         If WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG .OR. WorkEF3->EF3_CODEVE == EV_JUROS_PREPAG
            EF3->(DbSetOrder(10))  //"EF3_FILIAL+EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR+EF3_CODEVE"
            If EF3->(DbSeek(xFilial("EF3")+WorkEF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+WorkEF3->EF3_CODEVE+EF3_PARC+EF3_INVIMP+EF3_LINHA)))
               WKREFINIMP->(DbSetOrder(2))  //"EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR"
               If !WKREFINIMP->(DbSeek(WorkEF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA)))
                  WKREFINIMP->(reclock("WKREFINIMP",.T.))
                  EX401VlContr(EF3->(EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT),.T.)
               EndIf
            EndIf
         EndIf
         WorkEF3->(DbSkip())
      EndDo
      RestOrd(aOrd,.T.)
      WorkEF3->(dbGoTop())
   EndIf
Else
   If cMod == EXP
      WorkEF3->(RecLock("WorkEF3",.T.))
      WorkEF3->EF3_CODEVE := EV_PRINC
      WorkEF3->EF3_SEQ    := "0001"
      WorkEF3->EF3_DT_EVE := If(!Empty(M->EF1_DT_JUR), M->EF1_DT_JUR, dDataBase)
      If !Empty(M->EF1_MOEDA)
         WorkEF3->EF3_MOE_IN := M->EF1_MOEDA
      EndIf
      WorkEF3->TRB_ALI_WT := "EF3"
      WorkEF3->TRB_REC_WT := 0

      //FSM - 28/03/2012
      WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

      WorkEF3->( MsUnLock() )
   EndIf
EndIf

Return .T.

*------------------------------*
Static Function GravaCapa(nTipo)
*------------------------------*
Local nRegEF1, aAux:={}, nInd, /*lRet:=.T.,*/ nValTot:=0, nParc:=0
Private lValid := .T. //LDB 25/05/2006

EF1->(dbSetOrder(1))
If nTipo=INCLUIR
   nRegEF1:=EF1->(RecNo())
   
   IF Empty(M->EF1_CAMTRA) .AND. M->EF1_TP_FIN == FINIMP  //LRS - 29/11/2017
      MsgInfo(STR0284,STR0094)//"Necessário preencher o campo 'Parcelamento?' no cadastro de Tipo de Financiamento"
      Return .F.
   EndIF
   
   If !Empty(M->EF1_CONTRA) .and. EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA+iif( lTemChave,M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),"")))
      Help(" ",1,"AVG0005237") //MsgInfo(STR0028) //"Este numero de Contrato ja esta sendo usado. Selecione um numero de contrato valido"
      Return .F.
   // ** GFC - Pré-Pagamento/Securitização
   ElseIf lPrePag .and. (M->EF1_TP_FIN == "03" .or. M->EF1_TP_FIN == "04")
      aAux := {/*{M->EF1_DT_JUR,"EF1_DT_JUR"},*/{M->EF1_PARCPR,"EF1_PARCPR"},{M->EF1_TPCAPR,"EF1_TPCAPR"},;
               /*{M->EF1_CAREPR,"EF1_CAREPR"},*/{M->EF1_TPPEPR,"EF1_TPPEPR"},{M->EF1_PERIPR,"EF1_PERIPR"},;
               {M->EF1_VL_MOE,"EF1_VL_MOE"},{M->EF1_PARCJR,"EF1_PARCJR"},{M->EF1_TPCAJR,"EF1_TPCAJR"},;
               /*{M->EF1_CAREJR,"EF1_CAREJR"},*/{M->EF1_TPPEJR,"EF1_TPPEJR"},{M->EF1_PERIJR,"EF1_PERIJR"},;  // PLB 14/06/06 - Campos comentados para permitir carencia zero
               {M->EF1_MOEDA ,"EF1_MOEDA"}}
      For nInd:=1 to Len(aAux)
         If Empty(aAux[nInd,1])
            MsgInfo(STR0209+Alltrim(AvSX3(aAux[nInd,2],5))+STR0210) //"É necessário preencher a(o) " # " para gerar as parcelas."
            Return .F.
         EndIf
      Next nInd
   // **
   ElseIf WorkEF2->(BOF()) .and. WorkEF2->(EOF())  .And.  IIF(lEFFTpMod .And. cMod == IMP,!Empty(M->EF1_DT_JUR),.T.)  // PLB 17/08/06 - Na importação somente verifica se tiver data de inicio de juros
      Help(" ",1,"AVG0005285") //MsgInfo(STR0076)  //"Não há período(s) para este contrato. Cadastre o(s) período(s)."
      Return .F.
   EndIf
   EF1->(dbGoTo(nRegEF1))
EndIf

If nTipo=INCLUIR .or. nTipo=ALTERAR
   lValid := EX400Valid("EF1_DT_VEN")  .And.  EX400Valid("EF1_DT_VIN") // ;
             //.And.  IIF(lEFFTpMod  .And.  lCadFin  .And.  cMod == IMP, EX400Valid("EF1_LINCRE"), .T.)  // PLB 21/03/07
   
   if lValid .and. ( ( !empty(M->EF1_BAN_FI ) .and. (empty(M->EF1_AGENFI) .or. empty(M->EF1_NCONFI))) .or. ;
                     ( !empty(M->EF1_BAN_MO ) .and. (empty(M->EF1_AGENMO) .or. empty(M->EF1_NCONMO))) )
      EasyHelp( STR0291, STR0094) // "Agência ou Conta não informado para o banco de fechamento ou movimentação.", "Aviso"
      lValid := .F.
   endif

   If lValid  .And.  cMod == EXP .AND. lPrePag .AND. M->EF1_CAMTRA == "1" //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
      WorkEF3->( DBClearFilter() )   // PLB 19/06/06 - Limpa qualquer filtro existente nos eventos
      WorkEF3->(dbSetOrder(2))
      If !WorkEF3->(dbSeek(EV_PRINC_PREPAG)) .AND. !Empty(M->EF1_DT_JUR)
         Processa({|| EX401Recalc() }, STR0206+M->EF1_VM_FIN) //"Gerando Parcelas de " ##
      EndIf
      WorkEF3->(dbSetOrder(2))
      WorkEF3->(dbSeek(EV_PRINC_PREPAG))
      Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE==EV_PRINC_PREPAG
         nValTot += WorkEF3->EF3_VL_MOE
         nParc ++
         WorkEF3->(dbSkip())
      EndDo

      If !Empty(M->EF1_DT_JUR)
         If nValTot <> M->EF1_VL_MOE
            MsgInfo(STR0238+"("+M->EF1_MOEDA+" "+Alltrim(Trans(nValTot,AVSX3("EF1_SLD_PM",6)))+")"+STR0248+"("+M->EF1_MOEDA+" "+Alltrim(Trans(M->EF1_VL_MOE,AVSX3("EF1_SLD_PM",6)))+")"+STR0239+"("+M->EF1_MOEDA+" "+Alltrim(Trans(M->EF1_VL_MOE-nValTot,AVSX3("EF1_SLD_PM",6)))+")") //"A somatoria das parcelas do principal" # ", difere do total do contrato." # " O contrato nao pode ser gravado"
            lValid := .F.
         ElseIf nParc <> M->EF1_PARCPR
            MsgInfo(STR0240+STR0239) //"O numero de parcelas difere do estipulado no contrato." # " O contrato nao pode ser gravado"
            lValid := .F.
         EndIf
      EndIf
   EndIf
   // ** PLB 25/10/06 - Validação dos encargos do contrato
   If lValid  .And.  lCadFin
      If SX3->( DBSetOrder(2), DBSeek("EF1_ENCARG") )  .And.  !( lValid := FI400LinOk() )
         oEnc:oBox:nOption := Val(SX3->X3_FOLDER)  // Posiciona no folder de encargos
      EndIf
   EndIf
   // **
EndIf

//FSM - 12/07/2012
If nTipo == ESTORNAR
   WorkEF3->(dbSetOrder(2))
   If WorkEF3->(dbSeek(EV_PRINC))
      If !Empty(M->EF1_DT_JUR)
         EasyHelp(STR0270,STR0145) //#STR0270->"Não é possível estornar este contrato pois o campo 'Data de Início de Juros' esta preenchido." ##STR0145->"Atenção"
         lValid := .F.
      ElseIf WorkEF3->(FieldPos("EF3_TITFIN")) > 0 .And. !Empty(WorkEF3->EF3_TITFIN)
         EasyHelp(STR0272,STR0145) //#STR0272->"Não é possível estornar o contrato pois ainda ha movimentação bancária no módulo Financeiro referente à ele." ##STR0145->"Atenção"
         lValid := .F.
      EndIf
   EndIf
EndIf

If lValid
   If lGerAdEEC
      If cMod == EXP .and. lIntExp //Contrato de Exportação e integração SigaEFF e SigaEEC habilitada.
         If M->EF1_CAMTRA == "1" .and.  M->EF1_PREPAG == "2" //Parcelas de Pagamento igual a "Sim" e Credor igual a "Cliente"

            EEQ->(DbSetOrder(4))
            If EEQ->(DbSeek(xFilial("EEQ")+AvKey(M->EF1_CONTRA,"EEQ_NRINVO")+AvKey(AvKey(M->EF1_CLIENT,"A1_COD") + AvKey(M->EF1_CLLOJA,"A1_LOJA"),"EEQ_PREEMB")))

               ////////////////////////////////////////////////////
               //ER - 19/08/2008.                                //
               //Exclusão do adiantamento no módulo de Exportação//
               ////////////////////////////////////////////////////
               If nTipo == ESTORNAR

                  If EEQ->EEQ_VL > EEQ->EEQ_SALDO //Verifica se o adiantamento foi utilizado.
                     MsgInfo(STR0273,STR0145) //FSM - 09/08/2012 - #STR0273->"O contrato não poderá ser estornado porque foi utilizado como adiantamento no módulo de exportação (SigaEEC)." ##STR0145->"Atenção"
                     lValid := .F.
                  EndIf

               /////////////////////////////////////////////////////
               //ER - 19/08/2008.                                 //
               //Alteração do adiantamento no módulo de Exportação//
               /////////////////////////////////////////////////////
               ElseIf nTipo == ALTERAR

                  WorkEF3->(dbSetOrder(2))
                  If WorkEF3->(dbSeek(EV_PRINC))
                     If EEQ->EEQ_SALDO < WorkEF3->EF3_VL_MOE //Verifica se o adiantamento foi utilizado.
                        MsgInfo(STR0274,STR0145) //FSM - 09/08/2012 - #STR0274->"O contrato não poderá ser alterado porque foi utilizado como adiantamento no módulo de exportação (SigaEEC)." ##STR0145->"Atenção"
                        lValid := .F.
                     EndIf
                  EndIf
               EndIf

            EndIf

         EndIf
      EndIf
   EndIf
EndIf

If lValid .AND. (AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix) //MCF - 19/02/2016 - Acrescentado validação Financeiro.
   lValid := oEFFContrato:ValidaCampo("GRAVA_CAPA_OK")
EndIf

If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"VALIDA_CAPA_EF1"),) //LDB - 25/05/06

Return lValid

*--------------------------------*
Static Function EX400GrvTudo(nOpc)
*--------------------------------*
Local cCampo, i, nInd
Local cBanco,cAgencia,cConta
Local loldSai := If(ValType("lSai")=="L", lSai, .T.) //FSM - 16/08/2012
Local lEvEncCtr := .F. //NCF - 09/12/2014
Local aEve630 := {}  // GFP - 09/10/2015
Local lOkInt := .T., lDisarmTran := .F.  //NCF - 04/04/2017 - Flag de controle para desarme de transação em caso de falha na integração.
Local cManEF3EAI := ""
Private lAppend:=.T., nOpcRdm:=nOpc
Static lExcEIncCN := .F.
If WorkEF2->(BOF()) .and. WorkEF2->(EOF())  .And.  IIF(lEFFTpMod .And. cMod == IMP,!Empty(M->EF1_DT_JUR),.T.)  // PLB 17/08/06 - Na importação somente verifica se tiver data de inicio de juros
   Help(" ",1,"AVG0005285") //MsgInfo(STR0076)  //"Não há período(s) para este contrato. Cadastre o(s) período(s)."
   Return .F.
Endif

// ** AAF 17/11/2009
oEFFContrato:AtualizaSaldos()
lDtIniNaoVazio := !Empty(EF1->EF1_DT_JUR)
lMudouDtIni    := M->EF1_DT_JUR <> EF1->EF1_DT_JUR
// **

Begin TransAction   //Controle de Transação

If nOpc=INCLUIR .and. lEF1_JR_ANT .and. M->EF1_JR_ANT == "1"
   EX401GrvJA("M","WorkEF2","WorkEF3",M->EF1_DT_JUR,,M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,NIL,NIL,NIL,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
EndIf

EEQ->(dbSetOrder(1))
If cMod == IMP
   SWB->( dbSetOrder(1) )
EndIf

If lEFFTpMod .AND. cMod == IMP .AND. M->EF1_CAMTRA == "1" .AND. !Empty(M->EF1_LINCRE)

   //Baixa do Saldo da Linha de Crédito e do ROF
   If Empty(EF1->EF1_DT_JUR) .AND. !Empty(M->EF1_DT_JUR)

      EFA->( dbSetOrder(1) )
      EFA->( dbSeek(xFilial("EFA")+M->EF1_LINCRE) )

      //NCF - 27/08/2014 - Fazer backup do EFA caso seja alteração de registro existente
      If lLogix
         AF200BkpInt("EFA","EFF_MNCT_ALT",,{'EF1',EF1->(Recno())},,)
      EndIf

      RecLock("EFA",.F.)
      EFA->EFA_SALDO -= EX400Conv(M->EF1_MOEDA,EFA->EFA_MOEDA,M->EF1_VL_MOE)
      EFA->( MsUnLock() )
      EF9->(dbSetOrder(1))
      If EF9->(dbSeek(xFilial("EF9")+M->EF1_ROF))

         //NCF - 27/08/2014 - Fazer backup do EF9 caso seja alteração de registro existente
         If lLogix
            AF200BkpInt("EF9","EFF_MNCT_ALT",,{'EF1',EF1->(Recno())},,)
         EndIf

         EF9->(RecLock("EF9",.F.))
         EF9->EF9_SALDO -= EX400Conv(M->EF1_MOEDA,EF9->EF9_MOEDA,M->EF1_VL_MOE)
         EF9->(msUnlock())
      EndIf

   ElseIf nOpc <> INCLUIR .AND. !Empty(EF1->EF1_DT_JUR) .AND. Empty(M->EF1_DT_JUR)

      EFA->( dbSetOrder(1) )
      EFA->( dbSeek(xFilial("EFA")+M->EF1_LINCRE) )

      //NCF - 27/08/2014 - Fazer backup do EFA caso seja alteração de registro existente
      If lLogix
         AF200BkpInt("EFA","EFF_MNCT_ALT",,{'EF1',EF1->(Recno())},,)
      EndIf
      RecLock("EFA",.F.)
      EFA->EFA_SALDO += EX400Conv(M->EF1_MOEDA,EFA->EFA_MOEDA,M->EF1_VL_MOE)
      EFA->( MsUnLock() )

      EF9->(dbSetOrder(1))
      If EF9->(dbSeek(xFilial("EF9")+M->EF1_ROF))
         //NCF - 27/08/2014 - Fazer backup do EF9 caso seja alteração de registro existente
         If lLogix
            AF200BkpInt("EF9","EFF_MNCT_ALT",,{'EF1',EF1->(Recno())},,)
         EndIf

         EF9->(RecLock("EF9",.F.))
         EF9->EF9_SALDO += EX400Conv(M->EF1_MOEDA,EF9->EF9_MOEDA,M->EF1_VL_MOE)
         EF9->(msUnlock())
      EndIf

   EndIf
EndIf

ProcRegua(WorkEF2->(EasyRecCount())+WorkEF3->(EasyRecCount())+1)

//Grava EF1
dbSelectArea("EF1")
EF1->(dbSetOrder(1))
EF1->(dbSeek(xFilial("EF1")+IIF(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+IIF(lEFFTpMod,M->EF1_SEQCNT,"")))
IncProc(STR0029) //"Gravando Capa do Financiamento"

If lLogix//NCF - 27/08/2014 - Fazer backup do EF9 caso seja alteração de registro existente
   AF200BkpInt("EF1","EFF_MNCT_ALT",,{'EF1',EF1->(Recno())},,)
EndIf

EF1->(RecLock("EF1",If(nOpc=INCLUIR,.T.,.F.)))
FOR i := 1 TO FCount()
   If lEFFTpMod .OR. !(FIELDNAME(i) $ "EF1_TPMODU/EF1_SEQCNT")
      If EF1->&(FIELDNAME(i)) <> M->&(FIELDNAME(i)) .and. nOpc=ALTERAR
         aAdd(aAlterados,{"EF1",EF1->(FIELDNAME(i)),EF1->&(FIELDNAME(i)),M->&(FIELDNAME(i)),0,"","","","",""})
      EndIf
      EF1->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
   EndIf
NEXT i
EF1->EF1_FILIAL := xFilial("EF1")
MSMM(EF1->EF1_OBS,60,,M->EF1_VM_OBS ,1,,,"EF1","EF1_OBS")
EF1->(MSUnlock())

oEFFContrato := AvEFFContra():LoadEF1()

//Apaga Estornados EF2
For i:=1 to Len(aDelWkEF2)
   EF2->(dbGoTo(aDelWkEF2[i]))
   If !EF2->(BOF()) .and. !EF2->(EOF())

      //NCF - 27/08/2014 - Fazer backup do EF2 caso seja alteração de registro existente
      If lLogix
         If !lAppend
            AF200BkpInt("EF2","EFF_MNCT_DEL",,{'EF1',EF1->(Recno())},,)
         EndIf
      EndIf

      EF2->(RecLock("EF2",.F.)) //FSM - 09/03/2012
      EF2->(DBDELETE())
      EF2->(msUnlock())
   EndIf
Next i

//Grava EF2
dbSelectArea("WorkEF2")
WorkEF2->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkEF2->(EOF())
      IncProc(STR0030) //"Gravando Períodos do Contrato"
      EF2->(RecLock("EF2",.T.))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         EF2->&(cCampo) := WorkEF2->&(cCampo)
      NEXT i
      EF2->EF2_FILIAL := xFilial("EF2")
      EF2->EF2_CONTRA := EF1->EF1_CONTRA

      If lEFFTpMod
         EF2->EF2_TPMODU := EF1->EF1_TPMODU
      EndIf

      If lTemChave
         EF2->EF2_BAN_FI := EF1->EF1_BAN_FI
         EF2->EF2_PRACA  := EF1->EF1_PRACA
         If lEFFTpMod
            EF2->EF2_SEQCNT := EF1->EF1_SEQCNT
         EndIf
      Endif
      EF2->(msUnlock())
      WorkEF2->(dbSkip())
   EndDo
Else
   Do While !WorkEF2->(EOF())
      IncProc(STR0030) //"Gravando Períodos do Contrato"
      EF2->(dbGoTo(WorkEF2->EF2_RECNO))
      If !EF2->(BOF()) .and. !EF2->(EOF())
         lAppend:=.F.
      Else
         lAppend:=.T.
      EndIf
      //NCF - 27/08/2014 - Fazer backup do EF2 caso seja alteração de registro existente
      If lLogix
         If !lAppend
            AF200BkpInt("EF2","EFF_MNCT_ALT",,{'EF1',EF1->(Recno())},,)
         EndIf
      EndIf

      EF2->(RecLock("EF2",lAppend))
      FOR i := 1 TO FCount()
         cCampo:=FIELDNAME(i)
         EF2->&(cCampo) := WorkEF2->&(cCampo)
      NEXT i
      EF2->EF2_FILIAL := xFilial("EF2")
      EF2->EF2_CONTRA := EF1->EF1_CONTRA

      If lEFFTpMod
         EF2->EF2_TPMODU := EF1->EF1_TPMODU
      EndIf

      If lTemChave
         EF2->EF2_BAN_FI := EF1->EF1_BAN_FI
         EF2->EF2_PRACA  := EF1->EF1_PRACA
         If lEFFTpMod
            EF2->EF2_SEQCNT := EF1->EF1_SEQCNT
         EndIf
      Endif
      EF2->(MSUnlock())

      //NCF - 27/08/2014 - Fazer backup do EF2 caso seja inclusão de registro existente
      If lLogix .And. lAppend
         AF200BkpInt("EF2","EFF_MNCT_INC",,{'EF1',EF1->(Recno())},,)
      EndIf

      WorkEF2->(dbSkip())
   EndDo

EndIf

// ** AAF 04/04/06 - Transferência de Invoices no FINIMP
If Select("WorkTInv") > 0

   EF3->( dbSetOrder(5) )
   WorkTInv->( dbSetOrder(1), dbSeek(cMarca) )
   Do While WorkTInv->( !Eof() .AND. MARCA == cMarca )
      EF3->( dbGoTo(WorkTInv->RECNO) )

      cChave := EF3->( cFilEF3+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_INVOIC+EF3_PARC+EF3_INVIMP+EF3_LINHA )

      EF3->( dbSetOrder(6) )//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_INVOIC+EF3_PARC+EF3_INVIMP+EF3_LINHA
      EF3->( dbSeek(cChave) )
      Do While !EF3->( EoF() ) .AND. EF3->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_INVOIC+EF3_PARC+EF3_INVIMP+EF3_LINHA) == cChave

         RecLock("EF3",.F.) //FSM - 09/03/2012
         EF3->( dbDelete() )
         EF3->( MsUnLock() )

         EF3->( dbSkip() )
      EndDo

      WorkTInv->( dbSkip() )
   EndDo
EndIf

//Grava EF3
dbSelectArea("WorkEF3")
WorkEF3->(dbSetOrder(1))
WorkEF3->(dbGoTop())
If nOpc=INCLUIR
   Do While !WorkEF3->(EOF())
      IncProc(STR0031) //"Gravando Eventos"
      EF3->(RecLock("EF3",.T.))
      /* FSM - 07/02/2012 - Tratamento para Gravação, pois da segunda passada para frente a alias ativa é alterada, o que influencia no FCount()
      FOR i := 1 TO FCount()
         cCampo:=WorkEF3->( FIELDNAME(i) )
         EF3->&(cCampo) := WorkEF3->&(cCampo)
      NEXT i*/

      If EasyEntryPoint("EFFEX400")//RMD - 03/10/2014
         ExecBlock("EFFEX400",.F.,.F.,"ANTES_GRAVA_EF3")
      Endif
      
      If lLogix
         EX400EF3Alt(3,"INCLUSAO") 
      EndIf

      AvReplace("WorkEF3","EF3")
      EF3->EF3_FILIAL := xFilial("EF3")
      EF3->EF3_CONTRA := EF1->EF1_CONTRA

      If lEFFTpMod
         EF3->EF3_TPMODU := EF1->EF1_TPMODU
      EndIf

      //EF3->EF3_TP_EVE := If(M->EF1_TP_FIN $(ACC+"/"+ACE), If(Empty(WorkEF3->EF3_TP_EVE), "01", WorkEF3->EF3_TP_EVE) ,If(M->EF1_TP_FIN $(PRE_PAGTO+"/"+SECURITIZACAO), If(Empty(WorkEF3->EF3_TP_EVE), M->EF1_TP_FIN, WorkEF3->EF3_TP_EVE),"00"))  //If(M->EF1_TP_FIN $(ACC+"/"+ACE+"/"+PRE_PAGTO), M->EF1_TP_FIN, "00")
      EF3->EF3_TP_EVE := If(M->EF1_TP_FIN $(ACC+"/"+ACE),If (WorkEF3->EF3_CODEVE == EV_PRINC, M->EF1_TP_FIN,If(Empty(WorkEF3->EF3_TP_EVE), "01", WorkEF3->EF3_TP_EVE)) ,If(M->EF1_TP_FIN $(PRE_PAGTO+"/"+SECURITIZACAO), If(Empty(WorkEF3->EF3_TP_EVE), M->EF1_TP_FIN, WorkEF3->EF3_TP_EVE),"00"))  //If(M->EF1_TP_FIN $(ACC+"/"+ACE+"/"+PRE_PAGTO), M->EF1_TP_FIN, "00")
      //ACSJ 09/02/2005
      if lTemChave
         EF3->EF3_BAN_FI := EF1->EF1_BAN_FI
         EF3->EF3_AGENFI := EF1->EF1_AGENFI
         EF3->EF3_NCONFI := EF1->EF1_NCONFI
         EF3->EF3_PRACA  := EF1->EF1_PRACA
         If lEFFTpMod
            EF3->EF3_SEQCNT := EF1->EF1_SEQCNT
            // ** GFC - 19/04/06
            If Empty(EF3->EF3_ROF)
               EF3->EF3_ROF := EF1->EF1_ROF
            EndIf
            // **
         EndIf
      Endif
	   If EasyEntryPoint("EFFEX400A")
         ExecBlock("EFFEX400A",.F.,.F.,"GRAVANDO_EF3")
      Endif
      EF3->(msUnlock())

      // ** AAF 29/03/06 - Considerado o SWB.
      If EF3->EF3_CODEVE == EV_EMBARQUE
         If ( !lEFFTpMod .OR. cMod == EXP .OR. WorkEF3->EF3_ORIGEM == "EEQ" )
            AtuEEQ(INCLUIR)
         Else
            AtuSWB(INCLUIR)
         EndIf
      EndIf

      If(EF3->EF3_CODEVE == EV_TRANS_PRC, EX401AtuCon(INCLUIR)  ,)//AAF 04/11/05 - Transferência de Contrato.

      oEFFContrato:EventoEF3("INCLUSAO")

      WorkEF3->(dbSkip())
      If EasyEntryPoint("EFFEX400A")
         ExecBlock("EFFEX400A",.F.,.F.,"INC_EF3")
      Endif
   EndDo
Else
   Do While !WorkEF3->(EOF())
      IncProc(STR0031) //"Gravando Eventos"
      EF3->(dbGoTo(WorkEF3->EF3_RECNO))
      If !EF3->(BOF()) .and. !EF3->(EOF())
         lAppend:=.F.
      Else
         lAppend:=.T.
      EndIf

	  //** AAF 26/01/2015 - Se mudou a taxa do evento 100, é necessário reintegrar o movimento bancário.
	  If WorkEF3->EF3_CODEVE == "100" .AND. WorkEF3->EF3_RECNO > 0 .AND. WorkEF3->EF3_TX_MOE <> EF3->EF3_TX_MOE
	     lMudouDtIni := .T.
	     lExcEIncCN := .T.
	  EndIf
	  //**

      If lLogix
         cManEF3EAI := If( lAppend .Or. ( WorkEF3->EF3_RECNO == 0 .And. Empty(WorkEF3->EF3_TITFIN) ) , "INCLUSAO" ,"ALTERACAO")
         EC6->(DbSeek(xFilial("EC6")+"FIEX"+WorkEF3->EF3_TP_EVE+WorkEF3->EF3_CODEVE))
         lIncEBxEv := EC6->(FieldPos("EC6_DESINT")) > 0 .And. Left(WorkEF3->EF3_CODEVE,2)  $ "64/71" .And. EC6->EC6_DESINT == '2'  //NCF - 23/06/2015 - Ativação de flag que indica alteração do evento com
         lEvEncCtr := WorkEF3->EF3_CODEVE $ '670/180/190'                                                                          //                   integração de inc./est. do título e inc/est. da baixa
         //NCF - 27/08/2014 - Fazer backup do EF3 caso seja alteração de registro existente
         cOperac := If(lAppend,If( lEvEncCtr, 'ENC','EFF')+"_MNCT_INC",If( lEvEncCtr, 'ENC','EFF')+"_MNCT_ALT")
         If !lAppend
            AF200BkpInt("EF3",If( lEvEncCtr, 'ENC','EFF')+"_INBX_ALT",,{'WORKEF3',WORKEF3->(RECNO())},,)
         EndIf

         If !Empty(WorkEF3->EF3_TX_MOE) .AND. Empty(EF3->EF3_TX_MOE)
    	      oEFFContrato:EventoEF3("LIQUIDACAO",lMudouDtIni,lDtIniNaoVazio)
            cManEF3EAI := "LIQUIDACAO"    
    	      If lAppend
    	         cOperac := If( lEvEncCtr, 'ENC','EFF')+"_INBX_INC"
    	      Else
    	         cOperac := If( lEvEncCtr, 'ENC','EFF')+If(lIncEBxEv,"_ITIB_ALT","_INBX_ALT")    //NCF - 23/06/2015 - Alteração do evento com inclusão e baixa do título integrado
    	      EndIf
         ElseIf Empty(WorkEF3->EF3_TX_MOE) .AND. !Empty(EF3->EF3_TX_MOE)
	      oEFFContrato:EventoEF3("ESTORNO_LIQUIDACAO",lMudouDtIni,lDtIniNaoVazio)
	      cOperac := If( lEvEncCtr, 'ENC','EFF')+If(lIncEBxEv,"_EBET_ALT","_ESBX_ALT")       //NCF - 23/06/2015 - Alteração do evento com estorno de baixa e estorno do título integrado
            cManEF3EAI := "ESTORNO_LIQUIDACAO"
	   ElseIf WorkEF3->EF3_TX_MOE <> EF3->EF3_TX_MOE
    	      oEFFContrato:EventoEF3("LIQUIDACAO",lMudouDtIni,lDtIniNaoVazio)
	    	oEFFContrato:EventoEF3("ESTORNO_LIQUIDACAO",lMudouDtIni,lDtIniNaoVazio)
	    	cOperac := If( lEvEncCtr, 'ENC','EFF')+If(lIncEBxEv,"_ITIB_ALT","_INBX_ALT")       //NCF - 23/06/2015 - Alteração do evento com alteração e baixa do título integrado
            cManEF3EAI := "ALTERA_LIQUIDACAO"    
	   EndIf
      EndIf

      EF3->(RecLock("EF3",lAppend))
      /* FSM - 07/02/2012 - Tratamento para Gravação, pois da segunda passada para frente a alias ativa é alterada, o que influencia no FCount()
      FOR i := 1 TO FCount()
         cCampo:=WorkEF3->(FIELDNAME(i))
         EF3->&(cCampo) := WorkEF3->&(cCampo)
      NEXT i*/

	  If EasyEntryPoint("EFFEX400")//RMD - 03/10/2014
         ExecBlock("EFFEX400",.F.,.F.,"ANTES_GRAVA_EF3")
      Endif
      
      If lLogix .And. ChekAltEF3()
         EX400EF3Alt(3,cManEF3EAI)
      EndIf

      AvReplace("WorkEF3","EF3")

      EF3->EF3_FILIAL := xFilial("EF3")
      EF3->EF3_CONTRA := EF1->EF1_CONTRA
      If lEFFTpMod
         EF3->EF3_TPMODU := EF1->EF1_TPMODU
      EndIf
      EF3->EF3_TP_EVE := If(M->EF1_TP_FIN $(ACC+"/"+ACE), If(Empty(WorkEF3->EF3_TP_EVE), "01", WorkEF3->EF3_TP_EVE) ,If(M->EF1_TP_FIN $(PRE_PAGTO+"/"+SECURITIZACAO), If(Empty(WorkEF3->EF3_TP_EVE), M->EF1_TP_FIN, WorkEF3->EF3_TP_EVE),M->EF1_TP_FIN))  //If(M->EF1_TP_FIN $(ACC+"/"+ACE+"/"+PRE_PAGTO), M->EF1_TP_FIN, "00")
      // ACSJ - 09/02/2005
      If lTemChave
         EF3->EF3_BAN_FI := EF1->EF1_BAN_FI
         EF3->EF3_AGENFI := EF1->EF1_AGENFI
         EF3->EF3_NCONFI := EF1->EF1_NCONFI
         EF3->EF3_PRACA  := EF1->EF1_PRACA
         If lEFFTpMod
            EF3->EF3_SEQCNT := EF1->EF1_SEQCNT
            If Empty(EF3->EF3_ROF)
               EF3->EF3_ROF := EF1->EF1_ROF
            EndIf
         EndIf
      Endif
	  If EasyEntryPoint("EFFEX400A")
         ExecBlock("EFFEX400A",.F.,.F.,"GRAVANDO_EF3")
      Endif
      EF3->(MSUnlock())

      //NCF - 27/08/2014 - Fazer backup do EF3 caso seja inclusão
      If lLogix
         If lAppend
            AF200BkpInt("EF3",cOperac,,{'WORKEF3',WORKEF3->(RECNO())},,)
         Else
            AF200BkpInt("EF3",cOperac,,{'EF1',EF1->(Recno())},,.T.)
         EndIf
      EndIf

      If lAppend .AND. EF3->EF3_CODEVE == EV_EMBARQUE
         If ( !lEFFTpMod .OR. cMod == EXP .OR. WorkEF3->EF3_ORIGEM == "EEQ" )
            AtuEEQ(INCLUIR)
         Else
            AtuSWB(INCLUIR)
            dbSelectArea("WorkEF3")
         EndIf
      EndIf

      If(lAppend .AND. EF3->EF3_CODEVE == EV_TRANS_PRC, EX401AtuCon(INCLUIR)  ,)//AAF 04/11/05 - Transferência de Contrato.

      If lAppend
         cOperacao := "INCLUSAO"
      Else
         cOperacao := "ALTERACAO"
      EndIf

      /* WFS ago/2016
         Se o movimento bancário não foi excluído, reintegrar para realizar o estorno */
      If !lMudouDtIni .And. Empty(EF1->EF1_DT_JUR) .And. !Empty(M->EF1_PROCTR)
         lDtIniNaoVazio := .T.
         lMudouDtIni    := .T.
      EndIf

      // ** AAF 10/11/2009
      lOkInt := oEFFContrato:EventoEF3(cOperacao,lMudouDtIni,lDtIniNaoVazio)
      If !lOkInt
         lDisarmTran := .T.
      EndIf
      WorkEF3->(dbSkip())
      If EasyEntryPoint("EFFEX400A")
         ExecBlock("EFFEX400A",.F.,.F.,"INC_EF3")
      EndIf
   EndDo

EndIf

//Apaga Estornados EF3
For i:=1 to Len(aDelWkEF3)
   WorkEF3->(dbGoTo(aDelWkEF3[i]))
   If !WorkEF3->(BOF()) .and. !WorkEF3->(EOF())

      If WorkEF3->EF3_EV_EST == EV_EMBARQUE
         If ( !lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ" )
            AtuEEQ(ESTORNAR)
         Else
            AtuSWB(ESTORNAR)
         EndIf
      EndIf

   EndIf
Next i
For i:=1 to Len(aDelEF3)
   EF3->(dbGoTo(aDelEF3[i]))
   If !EF3->(BOF()) .and. !EF3->(EOF())

      If lLogix                   //NCF - 18/02/2019
         EX400EF3Alt(3,"ESTORNO")
      EndIf
      // ** AAF 10/11/2009
      oEFFContrato:EventoEF3("ESTORNO")
      // **

      If EF3->EF3_CODEVE == EV_EMBARQUE
         If ( !lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ" .OR. !Empty(EEQ->EEQ_FI_TOT) ) //LRS - 19/02/2018
            AtuEEQ(ESTORNAR,"EF3")
         Else
            AtuSWB(ESTORNAR,"EF3")
         EndIf
      ElseIf EF3->EF3_CODEVE == EV_TRANS_PRC
         EX401AtuCon(ESTORNAR)
      ElseIf EF3->EF3_CODEVE == EV_LIQ_PRC .and. EEQ->(dbSeek(If(lMultiFil,EF3->EF3_FILORI,xFilial("EEQ"))+EF3->EF3_PREEMB+EF3->EF3_PARC))//EEQ->(dbSeek(xFilial("EEQ")+EF3->EF3_PREEMB+EF3->EF3_PARC)) LRL 20/12/04 - Conceito MultiFil
         Do While !EEQ->(EOF()) .and. EEQ->EEQ_PREEMB==EF3->EF3_PREEMB .and.;
         If(lParFin,EEQ->EEQ_PARFIN,EEQ->EEQ_PARC)==EF3->EF3_PARC .and. ((AF200VLFCam("EEQ"))<>EF3->EF3_VL_MOE .or.;
         EEQ->EEQ_TX<>EF3->EF3_TX_MOE .or. EEQ->EEQ_DTCE<>EF3->EF3_DT_EVE)
            EEQ->(dbSkip())
         EndDo
         /* AJP 20/10/06
         //         If(lParFin,EEQ->EEQ_PARFIN,EEQ->EEQ_PARC)==EF3->EF3_PARC .and. ((EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0))<>EF3->EF3_VL_MOE .or.; AJP 20/10/06
         If EEQ->EEQ_PREEMB==EF3->EF3_PREEMB .and. If(lParFin,EEQ->EEQ_PARFIN,EEQ->EEQ_PARC)==EF3->EF3_PARC .and.;
         (EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0))=EF3->EF3_VL_MOE .and. EEQ->EEQ_TX=EF3->EF3_TX_MOE .and.;
         EEQ->EEQ_DTCE=EF3->EF3_DT_EVE
*/
         If EEQ->EEQ_PREEMB==EF3->EF3_PREEMB .and. If(lParFin,EEQ->EEQ_PARFIN,EEQ->EEQ_PARC)==EF3->EF3_PARC .and.;
         (AF200VLFCam("EEQ"))=EF3->EF3_VL_MOE .and. EEQ->EEQ_TX=EF3->EF3_TX_MOE .and.;
         EEQ->EEQ_DTCE=EF3->EF3_DT_EVE .AND. EEQ->EEQ_EVENT <> "603" //AAF 03/03/09 - Vinculacao de adiantamento pos-embarque.
            EEQ->(RecLock("EEQ",.F.))
            EEQ->EEQ_DTCE  := AVCTOD("  /  /  ")
            EEQ->EEQ_PGT   := AVCTOD("  /  /  ")
            EEQ->EEQ_DTNEGO:= AVCTOD("  /  /  ")
            EEQ->EEQ_NROP  := ""
            EEQ->EEQ_TX    := 0
            EEQ->(msUnlock())
         EndIf
      EndIf
      If EF3->EF3_CODEVE == EV_EMBARQUE .or. EF3->EF3_CODEVE == EV_LIQ_PRC .or. EF3->EF3_CODEVE == EV_LIQ_PRC_FC
         EX400MotHis(If(EF3->EF3_CODEVE $ (EV_LIQ_PRC+"/"+EV_LIQ_PRC_FC),"LIQ","VINC"),M->EF1_CONTRA,If(lTemChave,M->EF1_BAN_FI,),If(lTemChave,M->EF1_PRACA,),M->EF1_TP_FIN,EF3->EF3_PREEMB,EF3->EF3_INVOIC,EF3->EF3_PARC,EF3->EF3_CODEVE,EF3->EF3_SEQ,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
      EndIf

      If EasyEntryPoint("EFFEX400A")
         ExecBlock("EFFEX400A",.F.,.F.,"EXC_PARCELAS")
      Endif

      //NCF - 27/08/2014 - Fazer backup do EF3 caso seja estorno de registro existente
      If lLogix
         lEvEncCtr := EF3->EF3_CODEVE $ '670/180/190/501/520'
         AF200BkpInt("EF3",If(lEvEncCtr,'ENC_MNCT_DEL','EFF_MNCT_DEL'),,{'WORKEF3',WORKEF3->(RECNO())},,)
      EndIf

      EF3->(RecLock("EF3",.F.)) //FSM - 09/03/2012
      EF3->(DBDELETE())
      EF3->(msUnlock())
   EndIf
Next i

If(lRefinimp,GeraEvRefin(aRefinimp),)  // GFP - 09/10/2015

//Grava EF4 do array e da work
For i:=1 to Len(aAlterados)
   EF4->(RecLock("EF4",.T.))
   EF4->EF4_FILIAL := xFilial("EF4")
   If lEFFTpMod
      EF4->EF4_TPMODU := M->EF1_TPMODU
   EndIf
   EF4->EF4_CONTRA := M->EF1_CONTRA
   EF4->EF4_TP_EVE := M->EF1_TP_FIN
   EF4->EF4_CAMPO  := AvSX3(aAlterados[i,2],5)
   If aAlterados[i,1] == "EF3"
      EF4->EF4_PREEMB := aAlterados[i,6]
      EF4->EF4_INVOIC := aAlterados[i,7]
      EF4->EF4_PARC   := aAlterados[i,8]
      EF4->EF4_CODEVE := aAlterados[i,9]
      EF4->EF4_SEQ    := aAlterados[i,10]
   EndIf
   If ValType(aAlterados[i,3]) = "N"
      EF4->EF4_DE     := AVSX3(aAlterados[i,2],5)+STR0110+Alltrim(Transf(aAlterados[i,3],AVSX3(aAlterados[i,2],6))) //" de "
      EF4->EF4_PARA   := AVSX3(aAlterados[i,2],5)+STR0111+Alltrim(Transf(aAlterados[i,4],AVSX3(aAlterados[i,2],6))) //" para "
   ElseIf ValType(aAlterados[i,3]) = "D"
      EF4->EF4_DE     := AVSX3(aAlterados[i,2],5)+STR0110+Alltrim(DtoC(aAlterados[i,3]))
      EF4->EF4_PARA   := AVSX3(aAlterados[i,2],5)+STR0111+Alltrim(DtoC(aAlterados[i,4]))
   Else
      EF4->EF4_DE     := AVSX3(aAlterados[i,2],5)+STR0110+Alltrim(aAlterados[i,3])
      EF4->EF4_PARA   := AVSX3(aAlterados[i,2],5)+STR0111+Alltrim(aAlterados[i,4])
   EndIf
   EF4->EF4_USUARI := cUserName
   EF4->EF4_DATA   := dDataBase
   EF4->EF4_HORA   := SubStr(Time(),1,5)
   If lTemChave
      EF4->EF4_BAN_FI := EF1->EF1_BAN_FI
      EF4->EF4_PRACA  := EF1->EF1_PRACA
      If lEFFTpMod
         EF4->EF4_SEQCNT := EF1->EF1_SEQCNT
      EndIf
   Endif
   EF4->(msUnlock())

   //NCF - 27/08/2014 - Fazer backup do EF4 caso seja inclusão de registro
   If lLogix
     AF200BkpInt("EF4","EFF_MNCT_INC",,{'EF1',EF1->(Recno())},,)
   EndIf

Next i

dbSelectArea("WorkEF4")
WorkEF4->(dbGoTop())
Do While !WorkEF4->(EOF())
   IncProc(STR0030) //"Gravando Log de alterações"
   EF4->(RecLock("EF4",.T.))
   FOR i := 1 TO FCount()
      cCampo:=FIELDNAME(i)
      EF4->&(cCampo) := WorkEF4->&(cCampo)
   NEXT i
   EF4->EF4_FILIAL := xFilial("EF4")
   EF4->EF4_CONTRA := EF1->EF1_CONTRA

   If lEFFTpMod
      EF4->EF4_TPMODU := EF1->EF1_TPMODU
   EndIf

   If lTemChave
      EF4->EF4_BAN_FI := EF1->EF1_BAN_FI
      EF4->EF4_PRACA  := EF1->EF1_PRACA
      If lEFFTpMod
         EF4->EF4_SEQCNT := EF1->EF1_SEQCNT
      EndIf
   Endif
   EF4->(msUnlock())

   //NCF - 27/08/2014 - Fazer backup do EF4 caso seja inclusão de registro
   If lLogix
     AF200BkpInt("EF4","EFF_MNCT_INC",,{'EF1',EF1->(Recno())},,)
   EndIf

   WorkEF4->(dbSkip())
EndDo

// ** AAF 04/04/06 - Encargos
If lCadFin
   EF8->( dbSetOrder(2) )
   EF8->(dbSeek(cFilEF8+AvKey(M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+M->EF1_SEQCNT,"EF8_CHAVE")))
   Do While EF8->( EF8_FILIAL+EF8_CHAVE ) == cFilEF8+AvKey(M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+M->EF1_SEQCNT,"EF8_CHAVE")

      nRec := EF8->( RecNo() )
      If aScan(aCols,{|X| X[Len(aHeader)] == nRec .AND. !X[Len(X)]}) == 0

         //NCF - 27/08/2014 - Fazer backup do EF8 caso seja inclusão de registro
         If lLogix
            AF200BkpInt("EF8","EFF_MNCT_DEL",,{'EF1',EF1->(Recno())},,)
         EndIf

         EF8->( RecLock("EF8",.F.), dbDelete(), MsUnLock() ) //FSM - 09/03/2012
      EndIf

      EF8->( dbSkip() )
   EndDo
EndIf

If Len(aCols) > 0 .and. !Empty(aCols[1,1])

   For nInd := 1 To Len(aCols)
      If !aCols[nInd,Len(aCols[nInd])]  .And.  !Empty(aCols[nInd][GDFieldPos("EF8_CODEVE")])   // PLB 19/06/06 - Nao grava caso encontre um evento em branco
         If aCols[nInd,Len(aHeader)] > 0
            EF8->( dbGoTo(aCols[nInd,Len(aHeader)]) )
            If lLogix
               cOperac :=  "EFF_MNCT_ALT"
            EndIf
            RecLock("EF8",.F.)
         Else
            If lLogix
               cOperac :=  "EFF_MNCT_INC"
            EndIf
            RecLock("EF8",.T.)
            EF8->EF8_FILIAL := cFilEF8
            EF8->EF8_CHAVE  := M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+M->EF1_SEQCNT
         EndIf

         //NCF - 27/08/2014 - Fazer backup do EF3 caso seja alteração de registro existente
         If lLogix
            If cOperac == "EFF_MNCT_ALT"
               AF200BkpInt("EF8",cOperac,,{'EF1',EF1->(Recno())},,)
            EndIf
         EndIf

         EF8->EF8_CODEVE := aCols[nInd,aScan(aHeader,{|X| X[2] == "EF8_CODEVE"})]
         EF8->EF8_CODEAS := aCols[nInd,aScan(aHeader,{|X| X[2] == "EF8_CODEAS"})]
         EF8->EF8_CODEBA := aCols[nInd,aScan(aHeader,{|X| X[2] == "EF8_CODEBA"})]
         EF8->EF8_TIP_EV := aCols[nInd,aScan(aHeader,{|X| X[2] == "EF8_TIP_EV"})]
         EF8->EF8_VL_PCT := aCols[nInd,aScan(aHeader,{|X| X[2] == "EF8_VL_PCT"})]
         EF8->EF8_PCT_RJ := aCols[nInd,aScan(aHeader,{|X| X[2] == "EF8_PCT_RJ"})]
         EF8->EF8_LIQ    := aCols[nInd,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_LIQ"   })]
         EF8->EF8_TP_REL := aCols[nInd,aScan(aHeader,{|X| X[2] == "EF8_TP_REL"})]

         If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
            EF8->EF8_FORN := aCols[nInd,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_FORN"})]
            EF8->EF8_LOJA := aCols[nInd,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_LOJA"})]
         EndIf

         EF8->( MsUnLock() )

         //NCF - 27/08/2014 - Fazer backup do EF8 caso seja inclusão de registro existente
         If lLogix
            If cOperac == "EFF_MNCT_INC"
               AF200BkpInt("EF8",cOperac,,{'EF1',EF1->(Recno())},,)
            EndIf
         EndIf

      EndIf
   Next nInd

EndIf

/////////////////////////////////////////////////////////////
//ER - 18/08/2008.                                         //
//Tratamento para geração de adiantamento no SigaEEC quando//
//o contrato for do tipo Pre-Pagamento de Cliente.         //
/////////////////////////////////////////////////////////////
If lGerAdEEC

   If cMod == EXP .and. lIntExp //Contrato de Exportação e integração SigaEFF e SigaEEC habilitada.

      If M->EF1_CAMTRA == "1" .and.  M->EF1_PREPAG == "2" //Parcelas de Pagamento igual a "Sim" e Credor igual a "Cliente"

         If nOpc == INCLUIR .or. nOpc == ALTERAR

            //Verifica se a moeda do contrato é a mesma do cadastro do Cliente.
            EXJ->(DbSetOrder(1))
            If EXJ->(DbSeek(xFilial("EXJ")+AvKey(M->EF1_CLIENT,"EXJ_COD")+AvKey(M->EF1_CLLOJA,"EXJ_LOJA")))

               If M->EF1_MOEDA == EXJ->EXJ_MOEDA
                  //Gera o Adiantamento no SigaEEC.
                  EX400GerAdian(nOpc)
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
EndIf

If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
   oEFFContrato:EventoFinanceiro("ATUALIZA_PROVISORIOS")
EndIf

If EasyGParam("MV_EFF_FIN",,.F.) .And. lDisarmTran .And. Len(oEFFContrato:aError) > 0 //NCF - 04/04/2017 - Se ocorrer erro na integração com SIGAFIN, não deve efetivar as ocorrências 
   DisarmTransaction()                                                           //                   no contrato e deverá voltar para a tela de manutenção.
   lOldSai := .F.
EndIf

End TransAction   //Finaliza Controle de Transação

If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
   oEFFContrato:ShowErrors()
EndIf

If EasyEntryPoint("EFFEX400A")
   ExecBlock("EFFEX400A",.F.,.F.,"INC_PARCELAS")
Endif

lSai := loldSai //FSM - 18/08/2012

Return .T.

*----------------------------*
Static Function EX400Estorna()
*----------------------------*

Begin TransAction   //Controle de Transação

ProcRegua(WorkEF2->(EasyRecCount())+WorkEF3->(EasyRecCount())+1+Len(aHeader))

////////////////////////////////////////////////////
//ER - 19/08/2008.                                //
//Exclusão do adiantamento no módulo de Exportação//
////////////////////////////////////////////////////
If lGerAdEEC
   If cMod == EXP .and. lIntExp //Contrato de Exportação e integração SigaEFF e SigaEEC habilitada.
      If M->EF1_CAMTRA == "1" .and.  M->EF1_PREPAG == "2" //Parcelas de Pagamento igual a "Sim" e Credor igual a "Cliente"

         EEQ->(DbSetOrder(4))
         If EEQ->(DbSeek(xFilial("EEQ")+AvKey(M->EF1_CONTRA,"EEQ_NRINVO")+AvKey(AvKey(M->EF1_CLIENT,"A1_COD") + AvKey(M->EF1_CLLOJA,"A1_LOJA"),"EEQ_PREEMB")))
            If EEQ->EEQ_VL == EEQ->EEQ_SALDO //Verifica se a parcela não foi utilizada.
               EEQ->(RecLock("EEQ",.F.))
               EEQ->(DbDelete())
               EEQ->(MsUnlock())
            EndIf
         EndIf
      EndIf
   EndIf
EndIf

If EF2->(dbSeek(xFilial("EF2")+if(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+iif(lTemChave,EF1->EF1_BAN_FI+EF1->EF1_PRACA+if(lEFFTpMod,EF1->EF1_SEQCNT,""),"")))
   Do While EF2->EF2_FILIAL==xFilial("EF2") .and. EF2->EF2_CONTRA==EF1->EF1_CONTRA .AND. If(lEFFTpMod,EF2->EF2_TPMODU==EF1->EF1_TPMODU,.T.) .AND.;
            If(lTemChave,EF2->EF2_BAN_FI == EF1->EF1_BAN_FI .and. EF2->EF2_PRACA == EF1->EF1_PRACA .AND. If(lEFFTPMod,EF2->EF2_SEQCNT == EF1->EF1_SEQCNT,.T.),.T.) .and.; // ACSJ - 09/02/2005
            !EF2->(EOF())
      IncProc(STR0033) //"Apagando Períodos do Contrato"
      EF2->(RecLock("EF2",.F.)) //FSM - 09/03/2012
      EF2->(DBDELETE())
      EF2->(MSUnlock())
      EF2->(dbSkip())
   EndDo
EndIf

If cMod == IMP .AND. !Empty(M->EF1_LINCRE)

   EFA->( dbSetOrder(1) )
   EFA->( dbSeek(xFilial("EFA")+M->EF1_LINCRE) )

   /* FSM - 02/03/2012
   RecLock("EFA",.F.)
   EFA->EFA_SALDO += EX400Conv(M->EF1_MOEDA,EFA->EFA_MOEDA,M->EF1_VL_MOE)
   EFA->( MsUnLock() )*/

   EF9->(dbSetOrder(1))
   If EF9->(dbSeek(xFilial("EF9")+M->EF1_ROF))
      EF9->(RecLock("EF9",.F.))
      EF9->EF9_SALDO += EX400Conv(M->EF1_MOEDA,EF9->EF9_MOEDA,M->EF1_VL_MOE)
      EF9->(msUnlock())
   EndIf

EndIf

If Len(aCols) > 0

   EF8->( dbSetOrder(2) )
   EF8->(dbSeek(cFilEF8+AvKey(M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+M->EF1_SEQCNT,"EF8_CHAVE")))
   Do While EF8->( EF8_FILIAL+EF8_CHAVE ) == cFilEF8+AvKey(M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+M->EF1_SEQCNT,"EF8_CHAVE")

      EF8->( RecLock("EF8",.F.), dbDelete(), MsUnLock() ) //FSM - 09/03/2012

      EF8->( dbSkip() )
   EndDo

EndIf

If EF3->(dbSeek(xFilial("EF3")+if(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+Iif(lTemChave,EF1->EF1_BAN_FI+EF1->EF1_PRACA+if(lEFFTpMod,EF1->EF1_SEQCNT,""),"")))
   Do While EF3->EF3_FILIAL==xFilial("EF3") .and. EF3->EF3_CONTRA==EF1->EF1_CONTRA .AND. If(lEFFTpMod,EF3->EF3_TPMODU==EF1->EF1_TPMODU,.T.) .and.;
            If(lTemChave,EF3->EF3_BAN_FI == EF1->EF1_BAN_FI .and. EF3->EF3_PRACA == EF1->EF1_PRACA .AND. If(lEFFTPMod,EF3->EF3_SEQCNT == EF1->EF1_SEQCNT,.T.),.T.) .and.;  // ACSJ - 09/02/2005
            !EF3->(EOF())
      IncProc(STR0034) //"Apagando Eventos do Contrato"
      If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
         oEFFContrato:EventoEF3("ESTORNO")
      EndIf
      If EF3->EF3_CODEVE == EV_EMBARQUE
         If ( !lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ" )
            If !Empty(EF3->EF3_PREEMB)
               AtuEEQ(ESTORNAR,"EF3")
            EndIf
         ElseIf !Empty(EF3->EF3_HAWB)
            AtuSWB(ESTORNAR,"EF3")
         EndIf
      EndIf
      If EasyEntryPoint("EFFEX400A")
         ExecBlock("EFFEX400A",.F.,.F.,"EXC_PARCELAS")
      Endif
      EF3->(RecLock("EF3",.F.)) //FSM - 09/03/2012
      EF3->(DBDELETE())
      EF3->(MSUnlock())
      EF3->(dbSkip())
   EndDo
EndIf

ECF->(DbSetOrder(8))
   If ECF->(dbSeek(xFilial("ECF")+cTPMODU+EF1->EF1_CONTRA+If(lTemChave,EF1->EF1_BAN_FI+EF1->EF1_PRACA,"")))
      Do While ECF->ECF_FILIAL==xFilial("ECF") .and. ECF->ECF_CONTRA==EF1->EF1_CONTRA .and.;
      If(lTemChave,ECF->ECF_BANCO == EF1->EF1_BAN_FI .and. ECF->ECF_PRACA == EF1->EF1_PRACA,.T.) .and.;
      !ECF->(EOF()) .and. Eval(bTPMODUECF)
         IncProc(STR0072) //"Apagando Variações Cambiais do Contrato"

         // Grava na WorkEst para que seja impresso o relatorio no final
         WorkEst->(RecLock("WorkEst",.T.))
         WorkEst->ECE_CONTRA := ECF->ECF_CONTRA
         If lTemChave
            WorkEst->ECE_BANCO  := ECF->ECF_BANCO
            WorkEst->ECE_PRACA  := ECF->ECF_PRACA
         EndIf
         WorkEst->ECE_PREEMB := ECF->ECF_PREEMB
         WorkEst->ECE_INVEXP := ECF->ECF_INVEXP
		 WorkEst->ECE_SEQ    := ECF->ECF_SEQ
		 WorkEst->ECE_IDENTC := ECF->ECF_IDENTC
         WorkEst->ECE_ID_CAM := ECF->ECF_ID_CAM
         WorkEst->DESC_EVENT := If(EC6->(DbSeek(xFilial("EC6")+"FIEX"+ECF->ECF_TP_EVE+ECF->ECF_ID_CAM)), EC6->EC6_DESC, "")
         WorkEst->TIPO_EVE   := If(ECF->ECF_TP_EVE = '01', 'ACC', 'ACE')
		 WorkEst->ECE_CTA_DB := ECF->ECF_CTA_DB
		 WorkEst->ECE_CTA_CR := ECF->ECF_CTA_CR
		 WorkEst->ECE_VL_MOE := ECF->ECF_VL_MOE
		 WorkEst->ECE_TX_ATU := ECF->ECF_PARIDA
		 WorkEst->ECE_VALOR  := ECF->ECF_VALOR
         WorkEst->(MSUnlock())

         // Grava no ECE - Arq. Estorno Contábil
         ECE->(RecLock("ECE",.T.))
         ECE->ECE_FILIAL := xFilial("ECF")
         ECE->ECE_CONTRA := ECF->ECF_CONTRA
         If lTemChave
            ECE->ECE_BANCO  := ECF->ECF_BANCO
            ECE->ECE_PRACA  := ECF->ECF_PRACA
         EndIf
         ECE->ECE_TP_EVE := ECF->ECF_TP_EVE
         ECE->ECE_PREEMB := ECF->ECF_PREEMB
         ECE->ECE_INVEXP := ECF->ECF_INVEXP
         ECE->ECE_ID_CAM := EV_ESTORNO
		 ECE->ECE_IDENTC := ECF->ECF_IDENTC
		 ECE->ECE_NR_CON := '0000'
		 ECE->ECE_DT_EST := dDataBase
		 ECE->ECE_VALOR  := ECF->ECF_VALOR
		 ECE->ECE_MOE_FO := ECF->ECF_MOEDA
		 ECE->ECE_SEQ    := ECF->ECF_SEQ
		 ECE->ECE_ORIGEM := ECF->ECF_ORIGEM
		 ECE->ECE_TX_ATU := ECF->ECF_PARIDA
		 ECE->ECE_TX_ANT := ECF->ECF_FLUTUA
		 ECE->ECE_LINK   := ECF->ECF_LINK
		 ECE->ECE_CTA_DB := ECF->ECF_CTA_DB
		 ECE->ECE_CTA_CR := ECF->ECF_CTA_CR
		 ECE->ECE_FORN   := ECF->ECF_FORN
		 ECE->ECE_TPMODU := cTPMODU
         ECE->(MSUnlock())

         // Apaga o ECF
         ECF->(RecLock("ECF",.F.)) //FSM - 09/03/2012
         ECF->(DBDELETE())
         ECF->(MSUnlock())
         ECF->(dbSkip())

   EndDo
Endif
ECF->(DbSetOrder(1))

If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"FIM_ESTORNO"),)  // GFP - 25/09/2014

IncProc(STR0032) //"Apagando Capa do Financiamento"
EF1->(RecLock("EF1",.F.))//FSM - 09/03/2012
EF1->(DBDELETE())
EF1->(MSUnlock())

// Imprime Relatório de Estorno
IF WorkEst->(!EOF()) .AND. WorkEst->(!BOF())
   Processa({||EFFEX400Imprime()},STR0074)    //"Aguarde... Imprimindo..."
   WorkEst->(avzap())
ENDIF

End TransAction   //Finaliza Controle de Transação

Return .T.

*------------------------------------*
Function EX400Valid(cNomeCampo)
*------------------------------------*
Local nRec, nValAux:=0, cCarAux, nInd, i, aAux:={}, dDtEmba, cCpoParc:="", nParcAux := 0, nNotCalc := 0
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Local cCodEve := ""
Local nWorkEF3Rec := WorkEF3->(RecNo())
Local nRecEC6 := 0 //FSM - 19/03/2012
Local nOrdEC6 := 0 //FSM - 19/03/2012
Private lRet:=.T., cCampo:=If(cNomeCampo=NIL,"",cNomeCampo), lAddCols:=.F.

Do Case
   Case cCampo == "EF1_DT_JUR"    
      If !Empty(M->EF1_DT_JUR)  .And.  lEFFTpMod  .And.  cMod == IMP  .And.  M->EF1_CAMTRA == "1"
         //If M->EF1_CAREPR == 0
         //   cCpoParc := AVSX3("EF1_CAREPR",5)
         If M->EF1_PARCPR == 0
            cCpoParc := AVSX3("EF1_PARCPR",5)
         ElseIf M->EF1_PERIPR == 0
            cCpoParc := AVSX3("EF1_PERIPR",5)
         //ElseIf M->EF1_CAREJR == 0
         //   cCpoParc := AVSX3("EF1_CAREJR",5)
         ElseIf M->EF1_PARCJR == 0
            cCpoParc := AVSX3("EF1_PARCJR",5)
         ElseIf M->EF1_PERIJR == 0
            cCpoParc := AVSX3("EF1_PERIJR",5)
         EndIf
      EndIf
      WorkEF3->(dbSetOrder(1))
      WorkEF3->(dbSeek(StrZero(1,Len(EF3->EF3_SEQ))))
      If !Empty(M->EF1_DT_JUR) .And. M->EF1_DT_JUR < M->EF1_DT_CON .and. !(lPrePag .AND. M->EF1_CAMTRA == "1")//!M->EF1_TP_FIN $ ("03/04")
         MsgInfo(STR0093,STR0094) //"Data de Início dos Juros não pode ser menor que a Data do Contrato!", "Aviso"
         lRet:= .F.
      ElseIf !Empty(M->EF1_DT_JUR)  .And.  !EX401VerJur(cCampo)   // PLB 18/07/06 - Verifica se a Data de Inicio de Juros esta compreendida em algum periodo de Juros
         MsgInfo(EX401STR(43),STR0094) //"Data de Inicio dos Juros precisa estar compreendida em algum Periodo de Juros!", "Aviso"
         lRet:= .F.
      ElseIf !Empty(cCpoParc)
         MsgInfo(STR0209+cCpoParc)  //"E necessario preencher a(o) " ###
         lRet:= .F.
      ElseIf cMod == EXP .AND. Empty(WorkEF3->EF3_NR_CON) .And. !VerifEmb(.T.,"EF1_DT_JUR")
         // PLB 13/06/07
         //M->EF1_DT_CTB := M->EF1_DT_JUR

         WorkEF3->EF3_VL_MOE := M->EF1_VL_MOE
         /* wfs 20/05/16
            atualização do saldo passa a ser executada pela função EX401Saldo()
         M->EF1_SLD_PM       := M->EF1_VL_MOE
         If !Empty(M->EF1_MOEDA)
            /* GCC - 03/01/2014 - Calculo dos campos estarão sendo feitos na validação do campo EF1_TX_MOE
            WorkEF3->EF3_VL_REA := EX400Conv(M->EF1_MOEDA,, M->EF1_VL_MOE, If(!Empty(M->EF1_DT_JUR), M->EF1_DT_JUR, ) )
            WorkEF3->EF3_TX_MOE := WorkEF3->EF3_VL_REA / WorkEF3->EF3_VL_MOE
            *//*
            If !Empty(M->EF1_SLD_PM)
               M->EF1_SLD_PR := WorkEF3->EF3_VL_REA
            Endif
            // PLB 13/06/07
            // Grava a Data de Contabilização conforme a Taxa do Inicio de Juros caso nao tenha vinculação
            //If WorkEF3->EF3_CODEVE = '100'
            //   M->EF1_TX_CTB := WorkEF3->EF3_TX_MOE
            //Endif
         Endif*/

         EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)
      Elseif cMod == EXP .AND. M->EF1_DT_JUR # EF1->EF1_DT_JUR .AND. !AvFlags("SIGAEFF_SIGAFIN")
         M->EF1_DT_JUR := EF1->EF1_DT_JUR
         If !Empty(WorkEF3->EF3_NR_CON)
            Help(" ",1,"AVG0005286") //MsgInfo(STR0087)  //"Contrato de Câmbio já esta Contabilizado !!!"
         EndIf
         lRet := .F.
      EndIf
      //FSM - 19/03/2012
      If !Empty(M->EF1_DT_JUR)
         nRecEC6 := EC6->(Recno())
         nOrdEC6 := EC6->(IndexOrd())
         EC6->(DbSetOrder(6))
         If EC6->(DbSeek(xFilial("EC6")+"FI"+IIF(cMod==IMP,"IM","EX")+M->EF1_TP_FIN+'100')) .And. BuscaTaxa(M->EF1_MOEDA,M->EF1_DT_JUR,,.F.,.F.,,EC6->EC6_TXCV) == 0
            MsgInfo(STR0266 + AllTrim(BSCXBOX("EC6_TXCV",EC6->EC6_TXCV)) +STR0267+AllTrim(M->EF1_MOEDA)+STR0268 + AllTrim(DToC(M->EF1_DT_JUR)) + ".",STR0094) //#"Cotação de " ##" da moeda "###" não encontrada para a data "
//            lRet := .F.
         EndIf
         EC6->(DbSetOrder(nOrdEC6))
         EC6->(DbGoTo(nRecEC6))
      EndIf
      //FSM - 13/07/2012
      If EasyGParam("MV_EFF_FIN",,.F.) .AND. ALTERA .AND. !Empty(EF1->EF1_DT_JUR) .AND. !(M->EF1_DT_JUR==EF1->EF1_DT_JUR) .AND. EF1->EF1_DT_JUR < EasyGParam("MV_DATAFIN")
         EasyHelp(STR0271,STR0145) //#STR0271->"Não é possível alterar a data de inicio de juros pois há movimentação bancária no financeiro." ##STR0145->"Atenção"
         lRet := .F.
      EndIf

      If lRet  .And.  cMod == IMP .AND. M->EF1_CAMTRA == "1"
         WorkEF3->( dbSetOrder(2) )

         Begin Sequence

            If !WorkEF3->( dbSeek(EV_PRINC) )

               If !Empty(M->EF1_DT_JUR)

                  If Empty(M->EF1_LINCRE)
                     MsgStop(EX401STR(44),STR0094)  //"Linha de credito deve estar preenchida." ## "Aviso"
                     lRet:= .F.
                     BREAK
                  EndIf

                  If !EX400Valid("RECALC")
                     lRet:= .F.
                     BREAK
                  EndIf

                  nLiqs     := 0
                  nTotLiq   := 0
                  nTotLiqRs := 0
                  WorkEF3->( dbSetOrder(2) )
                  WorkEF3->( dbSeek(EV_LIQ_PRC) )
                  Do While WorkEF3->( !EoF() .AND. EF3_CODEVE == EV_LIQ_PRC )
                     nTotLiq   += WorkEF3->EF3_VL_MOE
                     nLiqs++

                     WorkEF3->( dbSkip() )
                  EndDo
                  nTotLiq := Round(nTotLiq,nDecValor)

                  nVincs    := 0
                  WorkEF3->( dbSeek(EV_EMBARQUE) )
                  Do While WorkEF3->( !EoF() .AND. EF3_CODEVE == EV_EMBARQUE )
                     nVincs++

                     WorkEF3->( dbSkip() )
                  EndDo

                  EFA->( dbSetOrder(1) )
                  EFA->( dbSeek(xFilial("EFA")+M->EF1_LINCRE) )

                  EF9->(dbSetOrder(1))
                  EF9->(dbSeek(xFilial("EF9")+M->EF1_ROF))

                  If nTotLiq == 0
                     MsgStop(EX401STR(45))  //"Nao ha vinculacoes liquidadas neste contrato."
                     lRet:= .F.
                     BREAK
                  ElseIf nVincs > nLiqs
                     MsgStop(EX401STR(46))  //"Ha invoices vinculadas nao liquidadas."
                     lRet:= .F.
                     BREAK
                  ElseIf EX400Conv(EFA->EFA_MOEDA,M->EF1_MOEDA,EFA->EFA_SALDO) < nTotLiq
                     MsgStop(EX401STR(47),STR0094)  //"Nao ha saldo suficiente nesta Linha de Credito." ## "Aviso"
                     lRet:= .F.
                     BREAK
                  ElseIf !Empty(M->EF1_ROF) .and. EX400Conv(EF9->EF9_MOEDA,M->EF1_MOEDA,EF9->EF9_SALDO) < nTotLiq
                     MsgStop(EX401STR(48),STR0094)  //"Nao ha saldo suficiente neste ROF." ## "Aviso"
                     lRet:= .F.
                     BREAK
                  ElseIf !Empty(M->EF1_ROF) .and. EF9->EF9_DT_VEN <= M->EF1_DT_JUR
                     MsgInfo(EX401STR(49),STR0094)  //"Este ROF esta vencido." ## "Atenção"
                  ElseIf EFA->EFA_DT_VEN <= M->EF1_DT_JUR
                     MsgInfo(EX401STR(50),STR0094)  //"Esta Linha de Credito esta vencida." ## "Atenção"
                  EndIf

                  If nTotLiq == M->EF1_VL_MOE .OR. MsgYesNo(EX401STR(51)+;  //"O Valor do contrato difere do valor das vinculacoes. Deseja alterar o valor do contrato para "
                                                             M->EF1_MOEDA+" "+AllTrim(TransForm(nTotLiq,AvSX3("EF1_VL_MOE",6)))+" ?","Aviso")


                     M->EF1_SLD_PM := nTotLiq
                     M->EF1_SLD_PR := EX400Conv(M->EF1_MOEDA,, nTotLiq, M->EF1_DT_JUR)
                     M->EF1_VL_MOE := nTotLiq
                     WorkEF3->(RecLock("WorkEF3",.T.))
                     WorkEF3->EF3_CODEVE := EV_PRINC
                     WorkEF3->EF3_SEQ    := BuscaEF3Seq()
                     WorkEF3->EF3_DT_EVE := M->EF1_DT_JUR
                     WorkEF3->EF3_MOE_IN := M->EF1_MOEDA
                     WorkEF3->EF3_VL_MOE := nTotLiq
                     If EF1->(FieldPos("EF1_TX_MOE")) > 0 .AND. !Empty(M->EF1_TX_MOE) //MCF - 13/01/2016 - Replicado tratamento para Importação.
                        WorkEF3->EF3_VL_REA := WorkEF3->EF3_VL_MOE * M->EF1_TX_MOE
                        WorkEF3->EF3_TX_MOE := M->EF1_TX_MOE
                     Else
                        WorkEF3->EF3_VL_REA := EX400Conv(M->EF1_MOEDA,, nTotLiq, M->EF1_DT_JUR)
                        WorkEF3->EF3_TX_MOE := WorkEF3->EF3_VL_REA / WorkEF3->EF3_VL_MOE
                     Endif
                     WorkEF3->TRB_ALI_WT := "EF3"
                     WorkEF3->TRB_REC_WT := 0
                     WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)
                     WorkEF3->( MsUnLock() )

                     If lCadFin
                        EX401GrEncargos("WorkEF3")
                     EndIf

                     Processa({|| EX401Recalc() }, STR0206+If(M->EF1_TP_FIN == "03",STR0207,STR0208) )

                  EndIf
               EndIf
            Else
               If Empty(M->EF1_DT_JUR)
                  aSeqs := {}

                  WorkEF3->( dbSeek(EV_PRINC) )
                  aAdd(aSeqs,WorkEF3->EF3_SEQ)
                  //aAdd(aDelEF3,WorkEF3->EF3_RECNO)
                  //WorkEF3->( dbDelete() )

                  WorkEF3->( dbSeek(Left(EV_PRINC_PREPAG,1)) )
                  Do While WorkEF3->( !EoF() .AND. Left(EF3_CODEVE,1) == Left(EV_PRINC_PREPAG,1) )
                     If WorkEF3->EF3_TX_MOE <> 0
                        lRet := .F.
                        MsgInfo(EX401STR(52),STR0094)  //"Nao e permitido retirar a data de inicio dos juros pois existem liquidacoes." ## "Aviso"
                        BREAK
                     EndIf

                     If aScan(aSeqs, WorkEF3->EF3_SEQ) == 0
                        aAdd(aSeqs,WorkEF3->EF3_SEQ)
                     EndIf

                     WorkEF3->( dbSkip() )
                  EndDo

                  WorkEF3->( dbSetOrder(4) )
                  For nInd := 1 To Len(aSeqs)
                     WorkEF3->( dbSeek(aSeqs[nInd]) )
                     Do While WorkEF3->( !EoF() .AND. EF3_SEQ == aSeqs[nInd] )
                        aAdd(aDelEF3,WorkEF3->EF3_RECNO)
                        WorkEF3->( dbDelete() )

                        WorkEF3->( dbSkip() )
                     EndDo
                  Next

               Else
                  Processa({|| EX401Recalc() }, STR0206+If(M->EF1_TP_FIN == "03",STR0207,STR0208) )
               EndIf

            EndIf

         End Sequence
      ElseIf lRet .And. cMod <> IMP
         nOldDtJur := WorkEF3->EF3_DT_EVE
         If  !lDataCred//FSY - 10/02/2014 - Caso nao contenha o Campo EF1_DTCRED realizar o tratamento antigo.
            WorkEF3->EF3_DT_EVE:= If(!Empty(M->EF1_DT_JUR), M->EF1_DT_JUR, dDataBase)
         End If

         If EF1->(FieldPos("EF1_TX_MOE")) > 0 .AND. !Empty(M->EF1_TX_MOE) //MCF - 06/06/2016
            WorkEF3->EF3_VL_REA := WorkEF3->EF3_VL_MOE * M->EF1_TX_MOE
            WorkEF3->EF3_TX_MOE := M->EF1_TX_MOE
         Else
            WorkEF3->EF3_VL_REA := EX400Conv(M->EF1_MOEDA,, WorkEF3->EF3_VL_MOE, M->EF1_DT_JUR)
            WorkEF3->EF3_TX_MOE := WorkEF3->EF3_VL_REA / WorkEF3->EF3_VL_MOE
         Endif

         If lEFFTpMod  .And.  M->EF1_CAMTRA == "1"    // PLB 19/07/06
            //Processa({|| EX401Recalc() }, STR0206+AllTrim(M->EF1_VM_FIN) ) //"Gerando Parcelas de " ##
         //ElseIf lPrePag  .And.  M->EF1_TP_FIN $ ("03/04")
            //Processa({|| EX401Recalc() }, STR0206+If(M->EF1_TP_FIN == "03",STR0207,STR0208) ) //"Gerando Parcelas de " ## "Pré-Pagamento / Securitização"

            If Empty(M->EF1_DT_JUR)
               aSeqs := {}

               //WorkEF3->( dbSeek(EV_PRINC) )
               //aAdd(aSeqs,WorkEF3->EF3_SEQ)
               //aAdd(aDelEF3,WorkEF3->EF3_RECNO)
               //WorkEF3->( dbDelete() )

               WorkEF3->(dbSetOrder(5))
               WorkEF3->(dbSeek(Left(EV_PRINC_PREPAG,1)) )
               Do While WorkEF3->( !EoF() .AND. Left(EF3_CODEVE,1) == Left(EV_PRINC_PREPAG,1) )
                  If WorkEF3->EF3_TX_MOE <> 0
                     lRet := .F.
                     MsgInfo(EX401STR(52),STR0094)  //"Nao e permitido retirar a data de inicio dos juros pois existem liquidacoes." ## "Aviso"
                     BREAK
                  EndIf

                  If aScan(aSeqs, WorkEF3->EF3_SEQ) == 0
                     aAdd(aSeqs,WorkEF3->EF3_SEQ)
                  EndIf

                  WorkEF3->( dbSkip() )
               EndDo

               WorkEF3->( dbSetOrder(4) )
               For nInd := 1 To Len(aSeqs)
                  WorkEF3->( dbSeek(aSeqs[nInd]) )
                  Do While WorkEF3->( !EoF() .AND. EF3_SEQ == aSeqs[nInd] )
                     aAdd(aDelEF3,WorkEF3->EF3_RECNO)
                     WorkEF3->( dbDelete() )

                     WorkEF3->( dbSkip() )
                  EndDo
               Next

            Else
               Processa({|| EX401Recalc() }, STR0206+If(M->EF1_TP_FIN == "03",STR0207,STR0208) )
            EndIf

         Else
             // ** AAF 27/10/2008 - Gerar encargos do evento 100 em ACC/ACE.
             cMsgEnc := "Deseja regerar os encargos relacionados ao evento "+AllTrim(Eval(bDescEve,EV_PRINC))+" ?"

             nEF3OldOrd := WorkEF3->(IndexOrd())
             nEF3OldRec := WorkEF3->(Recno())

             WorkEF3->(dbSetOrder(2))
             WorkEF3->(dbSeek(EV_PRINC))
             nEF3Rec100 := WorkEF3->(Recno())

             WorkEF3->(dbSetOrder(8))//DtoS(EF3_DT_EVE)+EF3_EV_VIN+EF3_CODEVE

             If !(lEFFTpMod  .And.  M->EF1_CAMTRA == "1" .AND. lPrePag .And. M->EF1_TP_FIN $ ("03/04") ) .AND. lCadFin;
                .AND. (!WorkEF3->(dbSeek(DToS(nOldDtJur)+EV_PRINC)) .OR. MsgYesNo(cMsgEnc) )

                Do While WorkEF3->(!EoF() .AND. DtoS(EF3_DT_EVE)+EF3_EV_VIN == DToS(nOldDtJur)+EV_PRINC)
                   aAdd(aDelEF3,WorkEF3->EF3_RECNO)
                   WorkEF3->(dbDelete())

                   WorkEF3->(dbSkip())
                EndDo

                WorkEF3->(dbGoTo(nEF3Rec100))

                If !Empty(M->EF1_DT_JUR)
                   EX401GrEncargos("WorkEF3")
                EndIf
             EndIf

             WorkEF3->(dbSetOrder(nEF3OldOrd))
             WorkEF3->(dbGoTo(nEF3OldRec))

			 If EF1->(FieldPos("EF1_TX_MOE")) > 0 .AND. !Empty(M->EF1_TX_MOE)
                WorkEF3->EF3_VL_REA := WorkEF3->EF3_VL_MOE * M->EF1_TX_MOE  //LRS - 12/09/2014 - Validação da EF3_TX_MOE após preencher o campo EF1_DT_JUR
                WorkEF3->EF3_TX_MOE := M->EF1_TX_MOE
			 Else
			    If !Empty(M->EF1_DT_JUR) .AND. (Empty(WorkEF3->EF3_TX_MOE) .Or. MsgYesNo(STR0283,STR0117))  //MCF - 14/01/2016
			    	WorkEF3->EF3_VL_REA := EX400Conv(M->EF1_MOEDA,, WorkEF3->EF3_VL_MOE, M->EF1_DT_JUR)   //LRS - 12/09/2014 - Validação da EF3_TX_MOE após preencher o campo EF1_DT_JUR
			    	WorkEF3->EF3_TX_MOE := WorkEF3->EF3_VL_REA / WorkEF3->EF3_VL_MOE
			    Endif
			 EndIf
             // **
         EndIf
      EndIf

      WorkEF3->(dbSetOrder(ORDEM_BROWSE))
      oMark:oBrowse:Refresh()

      IF !lRet
         M->EF1_DT_JUR := CTOD('  /  /  ')  // JWJ 26/01/2007
      Endif

   Case cCampo == "EF1_TP_FIN"
      // ** AAF 09/03/06 - Valida contra o Cadastro de Financiamentos.
      //If !ExistCpo("EF7",M->EF1_TP_FIN)
         //lRet := .F.
      //EndIf

      If lCadFin
         EF7->( dbSetOrder(1) )
         If !EF7->( dbSeek(xFilial("EF7")+M->EF1_TP_FIN) ) .OR. EF7->EF7_TP_FIN <> cMod
            MsgStop(STR0260)//"Código de Financiamento não encontrado."
            lRet := .F.
         ElseIf lEFFTpMod .AND. !Empty(M->EF1_TP_FIN)

            Begin Sequence
            nPos  := aScan(aHeader,{|X| X[2] == "EF8_TP_REL"})
            If Len(aCols) > 0  .And.  aScan(aCols,{|X| X[nPos] == "F"  .And.  !Empty(x[GDFieldPos("EF8_CODEVE")]) }) > 0
               If MsgYesNo(EX401STR(53),EX401STR(54))  //"Deseja atualizar os encargos para esse tipo de financiamento?" ## "Encargos"
                  //Exclui os encargos com tipo "F"
                  aDelEnca:= {}
                  aEval(aCols,{|X,Y| If(X[nPos] == "F",aAdd(aDelEnca,Y),)})
                  aEval(aDelEnca,{|X,Y| aDel(aCols,X+1-Y)})
                  aSize(aCols,Len(aCols)-Len(aDelEnca))
                  aDelEnca:= {}
               Else
                  BREAK
               EndIf
            ElseIf Len(aCols) = 1 .and. Empty(aCols[1][1])
               aCols    := {}
               lAddCols := .T.
            EndIf

            cFilEC6 := xFilial("EC6")
            EC6->( dbSetOrder(1) )
            EF8->( dbSetOrder(1) )
            EF8->( dbSeek(cFilEF8+"F"+AvKey(M->EF1_TP_FIN,"EF8_CHAVE")) )
            Do While EF8->( EF8_FILIAL+EF8_TP_REL+EF8_CHAVE ) == cFilEF8+"F"+AvKey(M->EF1_TP_FIN,"EF8_CHAVE")
               If EF8->EF8_CARGA == "1"
                  //aAdd(aCols,Array(Len(aHeader)+2))

                  //AAF 27/10/2008 - Inclusão com tratamento de linha em branco.
                  Eval(oGetMS:oBrowse:bAdd)

                  nPos := Len(aCols)
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEVE"})] := EF8->EF8_CODEVE
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEVE"})] := Eval(bDescEve,EF8->EF8_CODEVE)//EF8->EF8_DESEVE
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEAS"})] := EF8->EF8_CODEAS
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEAS"})] := Eval(bDescEve,EF8->EF8_CODEAS)//EF8->EF8_DESEAS
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEBA"})] := EF8->EF8_CODEBA
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEBA"})] := Eval(bDescEve,EF8->EF8_CODEBA)//EF8->EF8_DESEBA
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_TIP_EV"})] := EF8->EF8_TIP_EV
                  If EF8->EF8_TP_REL == "R" .and. EF8->EF8_TIP_EVE == "1" .and. EF9->(dbSeek(xFilial("EF9")+M->EF1_ROF))
                     aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_VL_PCT"})] := EX400Conv(EF9->EF9_MOEDA,M->EF1_MOEDA,EF8->EF8_VL_PCT)
                  Else
                     aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_VL_PCT"})] := EF8->EF8_VL_PCT
                  EndIf
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_PCT_RJ"})] := EF8->EF8_PCT_RJ
                  aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_LIQ"   })] := EF8->EF8_LIQ
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_TP_REL"})] := "F"

                  If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
                     aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_FORN"})] := EF8->EF8_FORN
                     aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_LOJA"})] := EF8->EF8_LOJA
                  EndIf

                  aCols[nPos,Len(aHeader)] := 0
                  aCols[nPos,Len(aHeader)+1] := .F.
               EndIf
               EF8->( dbSkip() )
            EndDo

            //RMD - Padronização na inclusão de linhas
            Eval(oGetMS:oBrowse:bAdd)
            oGetMS:oBrowse:Refresh()
            End Sequence

         EndIf
      EndIf
      // **

      If lRet .AND. !Empty(M->EF1_DT_CON)
         If M->EF1_TP_FIN == ACC
            M->EF1_DT_VIN := M->EF1_DT_CON + PRAZO_VINC_ACC
            M->EF1_DT_VEN := M->EF1_DT_CON + PRAZO_VENC_ACC
         ElseIf M->EF1_TP_FIN == ACE
            M->EF1_DT_VIN := M->EF1_DT_CON + PRAZO_VINC_ACE
            M->EF1_DT_VEN := M->EF1_DT_CON + PRAZO_VENC_ACE
         EndIf
      EndIF

      If lRet .and. !Empty(M->EF1_TP_FIN)

         //ER - 07/12/2006 - Atualiza a Descrição dos Eventos
         nRec := WorkEF3->(RecNo())
         WorkEF3->(DbGoTop())
         While WorkEF3->(!EOF())
            WorkEF3->(RecLock("WorkEF3",.F.))

            WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)
            If Empty(WorkEF3->EF3_DESCEV)  .And.  Left(WorkEF3->EF3_CODEVE,2) $ EVENTOS_DE_JUROS  // (510,520,550,640,650,670)
               If Left(WorkEF3->EF3_CODEVE,2) == Left(EV_VC_PJ1,2)  .And.  ( Val(WorkEF3->EF3_CODEVE) % 2 ) != 0   // 550  .And.  Impar
                  cCodEve := Left(WorkEF3->EF3_CODEVE,2)+"1"
               Else
                  cCodEve := Left(WorkEF3->EF3_CODEVE,2)+"0"
               EndIf
               WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", cCodEve)
            EndIf
            WorkEF3->EF3_TP_EVE:= RetTpEve()
            WorkEF3->(MsUnlock())
            WorkEF3->(DbSkip())
         EndDo

         WorkEF3->(DbGoTo(nRec))
         oMark:oBrowse:Refresh()
      EndIf

   Case cCampo == "EF1_VL_MOE"
      IF !Empty(M->EF1_DT_JUR)
         MsgStop("Não é permitido alterar o valor pois a Data de Inicio de Juros já foi preenchida.")
         lRet := .F.
      Else
         lRet := .T.
      ENDIF

      If lRet .AND. cMod == EXP
         WorkEF3->(dbSetOrder(1))
         WorkEF3->(dbSeek(StrZero(1,Len(EF3->EF3_SEQ))))
      EndIf
      If lRet .AND. (cMod == IMP .OR. ( Empty(WorkEF3->EF3_NR_CON) .And. !VerifEmb(.T.,"EF1_VL_MOE") ))
         If cMod == EXP
            WorkEF3->EF3_VL_MOE := M->EF1_VL_MOE
         EndIf
         /* wfs 23/05/16
            atualização do saldo passa a ser executada pela função EX401Saldo()
         M->EF1_SLD_PM       := M->EF1_VL_MOE */
         EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

         /* GCC - 03/01/2014 - Tratamento foi incluido na validação do campo Taxa Moeda (EF1_TX_MOE)
         If !Empty(M->EF1_MOEDA)
            If cMod == EXP
               WorkEF3->EF3_VL_REA := EX400Conv(M->EF1_MOEDA,, M->EF1_VL_MOE, If(!Empty(M->EF1_DT_JUR), M->EF1_DT_JUR, ))
               WorkEF3->EF3_TX_MOE := WorkEF3->EF3_VL_REA / WorkEF3->EF3_VL_MOE
               // PLB 19/06/06 - Grava a Data de Contabilização conforme a Taxa do Inicio de Juros caso nao tenha vinculação
               //If WorkEF3->EF3_CODEVE = '100'
                  //M->EF1_TX_CTB := WorkEF3->EF3_TX_MOE
               //Endif
            EndIf
            M->EF1_SLD_PR := WorkEF3->EF3_VL_REA
         EndIf
         */

         // ** GFC - Pré-Pagamento/Securitização
         If lPrePag .AND. M->EF1_CAMTRA == "1"//lPrePag .and. M->EF1_TP_FIN $ ("03/04")
            nInd := WorkEF3->(IndexOrd())
            If cMod == EXP
               /*
                 WorkEF3->(dbSetOrder(2))

               //Recalcula valor das parcelas 700
               WorkEF3->(dbSeek(EV_PRINC_PREPAG))
               Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG
                  WorkEF3->EF3_VL_MOE := M->EF1_VL_MOE / M->EF1_PARCPR
                  WorkEF3->EF3_SLDLIQ := M->EF1_VL_MOE / M->EF1_PARCPR
                  WorkEF3->(dbSkip())
               EndDo

               //Recalcula os juros
               Processa({|| EX401AltPrePag(,,"M","WorkEF3") } ,STR0215) //"Recalculando parcelas de juros..."

               WorkEF3->(dbSetOrder(nInd))
               WorkEF3->(dbGoTop())
               */

               /* wfs 06/09/16 */
               If !Empty(M->EF1_DT_JUR)
                  // PLB 19/04/07
                  EX401Recalc()
               EndIf
               WorkEF3->(dbGoTop())
            EndIf
         EndIf
         // **
      Elseif M->EF1_VL_MOE # EF1->EF1_VL_MOE
         M->EF1_VL_MOE := EF1->EF1_VL_MOE
         If !Empty(WorkEF3->EF3_NR_CON)
            Help(" ",1,"AVG0005286") //MsgInfo(STR0087)  //"Contrato de Câmbio já esta Contabilizado !!!"
         EndIf
         lRet := .F.
      Endif
      WorkEF3->(dbSetOrder(ORDEM_BROWSE))
      oMark:oBrowse:Refresh()
   //ElseIf cMod == IMP

   Case cCampo == "EF1_MOEDA"
      nRecno := WorkEF3->(Recno())
      WorkEF3->(DBGOTOP())
      lRet := .T.
      While !WorkEF3->(EOF())
         IF WorkEF3->EF3_CODEVE != "100"
            lRet := .F.
            Exit
         ENDIF
         WorkEF3->(DBSKIP())
      Enddo
      WorkEF3->(DBGOTO(nRecNo))
      IF !lRet
         MsgStop(STR0275, STR0098 ) //FSM - 09/08/2012 - #STR0275->"Não é permitido alterar a moeda do contrato se há um evento diferente de 100" ##STR0098->"Atenção"
      ENDIF

      If lRet .AND. cMod == EXP
         WorkEF3->(dbSetOrder(1))
         WorkEF3->(dbSeek(StrZero(1,Len(EF3->EF3_SEQ))))
         If M->EF1_VL_MOE > 0
            WorkEF3->EF3_VL_MOE := M->EF1_VL_MOE
            WorkEF3->EF3_VL_REA := EX400Conv(M->EF1_MOEDA,,M->EF1_VL_MOE)
            WorkEF3->EF3_TX_MOE := WorkEF3->EF3_VL_REA / WorkEF3->EF3_VL_MOE
            M->EF1_SLD_PR       := WorkEF3->EF3_VL_REA
         EndIf
         WorkEF3->EF3_MOE_IN := M->EF1_MOEDA

         WorkEF3->(dbSetOrder(ORDEM_BROWSE))
         oMark:oBrowse:Refresh()
      ElseIf lRet .AND. cMod == IMP
         nRecNo:= WorkEF3->( RecNo() )
         WorkEF3->( dbGoTop() )

      EndIf
   Case cCampo == "EF1_DT_CON"
      If !Empty(M->EF1_DT_JUR) .and. M->EF1_DT_JUR < M->EF1_DT_CON .and. !M->EF1_CAMTRA == "1"//!M->EF1_TP_FIN $ ("03/04")
         MsgInfo(STR0093,STR0094) //"Data de Início dos Juros não pode ser menor que a Data do Contrato!", "Aviso"
         lRet:= .F.
      Else
         If M->EF1_TP_FIN == ACC
            M->EF1_DT_VIN := M->EF1_DT_CON + PRAZO_VINC_ACC
            M->EF1_DT_VEN := M->EF1_DT_CON + PRAZO_VENC_ACC
         ElseIf M->EF1_TP_FIN == ACE
            M->EF1_DT_VIN := M->EF1_DT_CON + PRAZO_VINC_ACE
            M->EF1_DT_VEN := M->EF1_DT_CON + PRAZO_VENC_ACE
         EndIf
      EndIf
   Case cCampo == "EF1_INI_IR"
      If (!Empty(M->EF1_FIM_IR) .and. !Empty(M->EF1_INI_IR)) .and. M->EF1_INI_IR > M->EF1_FIM_IR
         Help(" ",1,"AVG0005207") //MsgInfo(STR0036) //"Data Final deve ser maior que a Data Inicial."
         lRet := .F.
      EndIf
   Case cCampo == "EF1_FIM_IR"
      If (!Empty(M->EF1_FIM_IR) .and. !Empty(M->EF1_INI_IR)) .and. M->EF1_INI_IR > M->EF1_FIM_IR
         Help(" ",1,"AVG0005207") //MsgInfo(STR0036) //"Data Final deve ser maior que a Data Inicial."
         lRet := .F.
      Else
         // ** GFC - 24/08/05 - IR
         If M->EF1_FIM_IR < EF1->EF1_FIM_IR .or. Empty(EF1->EF1_FIM_IR)
            EX401DtIR()
         EndIf
         // **
      EndIf
   // ** GFC - 17/08/05 - Validação da data de encerramento
   Case cCampo == "EF1_DT_ENC"
      If !EX401ValEnc()
         lRet := .F.
      EndIf
   // **
   // ** GFC - 04/11/05 - Validação do pagamento de juros antecipado
   Case cCampo == "EF1_JR_ANT"
      If !EX401VlJRA()
         lRet := .F.
      EndIf
      WorkEF3->(dbSetOrder(ORDEM_BROWSE))
      oMark:oBrowse:Refresh()
   // **
   // ** GFC - 04/11/05 - Validação dos juros por períodos
   Case cCampo == "EF1_LIQPER"
      EX401LiqPer()
      WorkEF3->(dbSetOrder(ORDEM_BROWSE))
      WorkEF3->(dbGoTop())
      oMark:oBrowse:Refresh()
   // **

   // GCC - 03/01/2014 - Cálculo do valor da parcela principal em função da taxa informada na capa do financiamento
   Case cCampo == "EF1_TX_MOE"
      If !Empty(M->EF1_TX_MOE)
	     WorkEF3->(dbSetOrder(2))
         If WorkEF3->(dbSeek(EV_PRINC)) .AND. M->EF1_VL_MOE > 0 .AND. cMod == EXP
            WorkEF3->EF3_TX_MOE := M->EF1_TX_MOE
	        WorkEF3->EF3_VL_REA := M->EF1_VL_MOE * M->EF1_TX_MOE
         EndIf
         M->EF1_SLD_PR := WorkEF3->EF3_VL_REA
      EndIf

      WorkEF3->(dbSetOrder(ORDEM_BROWSE))
      oMark:oBrowse:Refresh()

   Case cCampo == "EF2_TIPJUR"
      If nTpManut = INCLUIR .and. WorkEF2->(AvSeekLast(If(lEF2_INVOIC,M->EF2_INVOIC+M->EF2_PARC,"")+M->EF2_TP_FIN+If(lEF2_TIPJUR,M->EF2_TIPJUR,"")))
         M->EF2_DT_INI:=WorkEF2->EF2_DT_FIM+1
      EndIf

   Case cCampo == "EF2_DT_INI"
      If !Empty(M->EF2_DT_INI)
         If !Empty(M->EF2_DT_FIM) .and. M->EF2_DT_INI > M->EF2_DT_FIM
            Help(" ",1,"AVG0005238") //MsgInfo(STR0035) //"Data Inicial deve ser menor que a Data Final."
            lRet := .F.
         Else
            nRec := WorkEF2->(RecNo())
            If nTpManut = INCLUIR .and. WorkEF2->(AvSeekLast(IIF(lMultiFil,M->EF2_FILORI,Space(Len(EF2->EF2_FILORI)))+If(lEF2_INVOIC,M->EF2_INVOIC+M->EF2_PARC,"")+M->EF2_TP_FIN+If(lEF2_TIPJUR,M->EF2_TIPJUR,"")))
               If WorkEF2->EF2_DT_FIM <> (M->EF2_DT_INI - 1)
                  MsgInfo(STR0099+DtoC(WorkEF2->EF2_DT_FIM)) //"Período deve começar exatamente depois do último período cadastrado. Data final do último período: " #
                  lRet := .F.
               EndIf
            ElseIf nTpManut = ALTERAR
               If !WorkEF2->(DbSeek(If(lEF2_INVOIC,If(lMultiFil,M->EF2_FILORI,Space(Len(EF2->EF2_FILORI)))+M->EF2_INVOIC+M->EF2_PARC,"")+M->EF2_TP_FIN+If(lEF2_TIPJUR,M->EF2_TIPJUR,"")+DtoS(M->EF2_DT_INI),.T.))
                  WorkEF2->(dbSkip(-1))
               EndIf
               If WorkEF2->(RecNo()) <> nRec .and. M->EF2_DT_INI >= WorkEF2->EF2_DT_INI .and.;
               M->EF2_DT_INI <= WorkEF2->EF2_DT_FIM
                  MsgInfo(STR0237) //"A data inicial informada não pode estar dentro de outro período."
                  lRet := .F.
               EndIf
               WorkEF2->(dbGoTo(nRec))
            EndIF
         EndIf
         If lRet
            If M->EF2_DT_INI < M->EF1_DT_JUR
               MsgInfo(STR0236,STR0094) //"A data inicial informada é menor que a data de início do juros." # "Aviso"
               lRet := .F.
            EndIf
         EndIf
      EndIf
   Case cCampo == "EF2_DT_FIM"
      If !Empty(M->EF2_DT_FIM)
         If M->EF2_DT_FIM < M->EF2_DT_INI
            Help(" ",1,"AVG0005207") //MsgInfo(STR0036) //"Data Final deve ser maior que a Data Inicial."
            lRet := .F.
         ElseIf !Empty(M->EF1_DT_CTB)  .And.  lIsContab  .And.  M->EF2_DT_FIM < M->EF1_DT_CTB
            Help(" ",1,"AVG0005239") //MsgInfo(STR0037) //"Data Final do periodo nao pode ser menor que a Data da Ultima Contabilização."
            lRet := .F.
         ElseIf nTpManut = ALTERAR
            nRec := WorkEF2->(RecNo())
            WorkEF2->(DbSeek(If(lEF2_INVOIC,If(lMultiFil,M->EF2_FILORI,Space(Len(EF2->EF2_FILORI)))+M->EF2_INVOIC+M->EF2_PARC,"")+M->EF2_TP_FIN+If(lEF2_TIPJUR,M->EF2_TIPJUR,"")))
            Do While !WorkEF2->(EOF()) .and. If(lEF2_INVOIC,M->EF2_INVOIC+M->EF2_PARC==WorkEF2->EF2_INVOIC+WorkEF2->EF2_PARC,.T.) .and.;
            WorkEF2->EF2_TP_FIN==M->EF2_TP_FIN .and. If(lEF2_TIPJUR,WorkEF2->EF2_TIPJUR==M->EF2_TIPJUR,.T.)
               If WorkEF2->(RecNo()) <> nRec .and. M->EF2_DT_FIM >= WorkEF2->EF2_DT_INI .and.;
               M->EF2_DT_FIM <= WorkEF2->EF2_DT_FIM
                  MsgInfo(STR0226) //"A data final informada não pode estar dentro de outro período."
                  lRet := .F.
                  Exit
               EndIf
               WorkEF2->(dbSkip())
            EndDo
            WorkEF2->(dbGoTo(nRec))
         EndIf
         If lRet  .And.  !Empty(M->EF1_DT_JUR)
            lRet := EX401VerJur(cCampo)  // PLB 18/07/06
         EndIf
      EndIf
   Case cCampo == "EF2_TX_FIX"
      M->EF2_TX_DIA := (M->EF2_TX_FIX + M->EF2_TX_VAR) / 360
   Case cCampo == "EF2_TX_VAR"
      M->EF2_TX_DIA := (M->EF2_TX_FIX + M->EF2_TX_VAR) / 360
   Case cCampo == "EF2_TP_FIN"
      If M->EF2_TP_FIN <> ACC .and. M->EF2_TP_FIN <> ACE
         Help(" ",1,"AVG0005240") //MsgInfo(STR0038) //"O tipo do Financiamento deve ser ACC ou ACE."
         lRet := .F.
      EndIf
   Case cCampo == "EF2_FILORI"
      lRet:= .F.
      For i:=1 To Len(aFiliais)
         If aFiliais[i] == M->EF2_FILORI
            lRet := .T.
            Exit
         EndIf
      Next i
   Case cCampo == "EF2_INVOIC"
      If lIntExp
         If !Empty(M->EF2_INVOIC)
            EEQ->(dbSetOrder(5))
            If lMultiFil
               lRet:= .F.
               For i:= 1 To Len(aFiliais)
                  If EEQ->(DBSEEK(aFiliais[i]+M->EF2_INVOIC+EV_PRINC2))
                     lRet := .T.
                     Exit
                  EndIf
               Next
               If !lRet
                  Help("",1,"REGNOIS")
               EnDIf
            Else
               M->EF2_PARC := EEQ->EEQ_PARC
               If !EEQ->(dbSeek(xFilial("EEQ")+M->EF2_INVOIC+EV_PRINC2))
                  Help("",1,"REGNOIS")
                  lRet := .F.
               EndIf
            EnDIF
            EEQ->(dbSetOrder(1))
         EndIf
      EndIf
   Case cCampo == "EF2_PARC"
      If lIntExp
         If !Empty(M->EF2_INVOIC) .and. !Empty(M->EF2_PARC)
            //EEQ->(dbSetOrder(4))
            EEQ->(dbSetOrder(5))  // PLB 25/08/06 - Alteraçao devido EF2 nao possuir PREEMB
            If lMultiFil
               lRet:= .F.
               For i:= 1 To Len(aFiliais)
                  //If EEQ->(DBSEEK(aFiliais[i]+M->EF2_INVOIC+M->EF2_INVOIC+M->EF2_PARC+EV_PRINC2))
                  If EEQ->(DBSEEK(aFiliais[i]+M->EF2_INVOIC+EV_PRINC2) )
                     // ** PLB 25/08/06
                     Do While !EEQ->( EoF() )  .And.  EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT) == aFiliais[i]+M->EF2_INVOIC+EV_PRINC2
                        If EEQ->EEQ_PARC == M->EF2_PARC
                           lRet := .T.
                           Exit
                        EndIf
                        EEQ->( DBSkip() )
                     EndDo
                     If lRet
                        Exit
                     EndIf
                     // **
                  EndIf
               Next
               If !lRet
                  Help("",1,"REGNOIS")
               EnDIf
            Else
               lRet := .F.
               //If !EEQ->(dbSeek(xFilial("EEQ")+M->EF2_INVOIC+M->EF2_INVOIC+M->EF2_PARC+EV_PRINC2))
               // ** PLB 25/08/06
               //If EEQ->(dbSeek(cFilEEQ+M->EF2_INVOIC+EV_PRINC2))
               If EEQ->(dbSeek(IIF(lMultiFil,M->EF2_FILORI,cFilEEQ)+M->EF2_INVOIC+EV_PRINC2)) //AAF 25/09/07 - Tratar multifiliais
                  Do While !EEQ->( EoF() )  .And.  EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT) == cFilEEQ+M->EF2_INVOIC+EV_PRINC2
                     If EEQ->EEQ_PARC == M->EF2_PARC
                        lRet := .T.
                        Exit
                     EndIf
                     EEQ->( DBSkip() )
                  EndDo
               EndIf
               // **
               If !lRet
                  Help("",1,"REGNOIS")
               EndIf
            EndIf
            EEQ->(dbSetOrder(1))
         EndIf
      EndIf
   Case cCampo == "EF3_VL_MOE"
      If !Empty(M->EF3_INVOIC) .and. M->EF3_VL_MOE <> 0 .and. !Left(M->EF3_CODEVE,1) $ ("3/4") .and. !Left(M->EF3_CODEVE,2) $ ("64") //FSM - 27/06/2012
         EEQ->(dbSetOrder(4))
         EEQ->(dbSeek(if(lMultiFil,M->EF3_FILORI,xFilial("EEQ"))+M->EF3_INVOIC+M->EF3_PREEMB+M->EF3_PARC))
         //EEC->(dbSeek(if(lMultiFil,M->EF3_FILORI,xFilial("EEC"))+EEQ->EEQ_PREEMB)) - GFC - 01/12/05
         nValAux := EX400Conv(M->EF1_MOEDA,EEQ->EEQ_MOEDA,M->EF3_VL_MOE,M->EF3_DT_EVE)
/* AJP 20/10/06
         If EEQ->EEQ_FI_TOT == "S" .or. ;
         (EEQ->EEQ_FI_TOT=="N" .and. nValAux > (EEQ->EEQ_VL_PAR-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0))) .or. nValAux > (EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0))
*/
         If EEQ->EEQ_FI_TOT == "S" .or. ;
         (EEQ->EEQ_FI_TOT=="N" .and. nValAux > (EEQ->EEQ_VL_PAR - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON)) .or. nValAux > (AF200VLFCam("EEQ"))
            Help(" ",1,"AVG0005241") //MsgInfo(STR0072) //"Valor maior que saldo disponível na Parcela da Invoice."
            lRet := .F.
         EndIf
         EEQ->(dbSetOrder(1))
      EndIf
      If lRet
         If !Empty(M->EF3_TX_MOE)
            M->EF3_VL_REA := M->EF3_VL_MOE * M->EF3_TX_MOE
         EndIf
         M->EF3_VL_INV := nValAux
      EndIf
      
      //NCF - 11/04/2018 - Ajuste dos saldos a vincular e a liquidar quando a parcela é alterada para valor a menor.
      If lRet .And. cMod == EXP .And. M->EF1_CAMTRA == "1" .And. M->EF3_CODEVE == EV_PRINC_PREPAG .And. Val(M->EF3_PARC) == M->EF1_PARCPR 
         If M->EF3_VL_MOE - WorkEF3->EF3_VL_MOE + M->EF3_SLDVIN < 0                               // Indica que a parcela é a última conforme quantidade definida de parcelas no contrato.
            EasyHelp(STR0285)//"Alteração não permitida. Existem invoices vinculadas à parcela onde o montante é maior que o valor informado."
            lRet:= .F.
         ElseIf M->EF3_VL_MOE - WorkEF3->EF3_VL_MOE + M->EF3_SLDLIQ < 0
            EasyHelp(STR0286)//"Alteração não permitida. Existem invoices liquidadas à parcela onde o montante é maior que o valor informado."
            lRet:= .F.
         Else
            M->EF3_SLDVIN += (M->EF3_VL_MOE - WorkEF3->EF3_VL_MOE)
            M->EF3_SLDLIQ += (M->EF3_VL_MOE - WorkEF3->EF3_VL_MOE)
         EndIf
      EndIf

   Case cCampo == "EF3_VL_REA"
      If !Empty(M->EF3_VL_MOE)
         M->EF3_TX_MOE := M->EF3_VL_REA / M->EF3_VL_MOE
      EndIf
   Case cCampo == "EF3_TX_MOE"
      If VerifEmb(.T.,"EF3_TX_MOE")
         lRet := .F.
      ElseIf !Empty(M->EF3_VL_MOE)
         M->EF3_VL_REA := M->EF3_VL_MOE * M->EF3_TX_MOE
      EndIf
   Case cCampo == "EF3_CODEVE"
      EC6->(dbSetOrder(1))
      If Empty(M->EF1_TP_FIN)
        Help(" ",1,"AVG0005242") //MsgInfo(STR0039) //"Tipo do Financiamento não preenchido na capa."
      ElseIf !EC6->(dbSeek(xFilial("EC6")+"FI"+IIF(cMod==IMP,"IM","EX")+M->EF1_TP_FIN+M->EF3_CODEVE))
         Help("",1,"REGNOIS")
         lRet := .F.
      ElseIf M->EF3_CODEVE == EV_PRINC .or. M->EF3_CODEVE == EV_LIQ_PRC .or. M->EF3_CODEVE $ (EV_VC_COM_FIN_S+"/"+EV_VC_COM_FIN_D)  .Or.  M->EF3_CODEVE == EV_EMBARQUE
         Help(" ",1,"AVG0005243",,M->EF3_CODEVE+STR0041,1,10) //MsgInfo(STR0040+M->EF3_CODEVE+STR0041) //"O Evento "###" não pode ser incluso manualmente."
         lRet := .F.
      Elseif ! Left(M->EF3_CODEVE,1) $ "3,4"
         MsgStop(EX401STR(168)) //"Só é permitido incluir evento entre 300 e 499"
         lRet := .F.
      Else
         M->EF3_DESCEV := EC6->EC6_DESC
      EndIf
   Case cCampo == "EF3_INVOIC"
      If lIntExp
         EEQ->(dbSetOrder(5))
         If !Empty(M->EF3_INVOIC)
            //LRL 21/12/04 -----Outras Filiais---------------------------------------------------------
            If lMultiFil
               lRet:= .F.
               For i:= 1 To Len(aFiliais)
                  If EEQ->(DBSEEK(aFiliais[i]+M->EF3_INVOIC+EV_PRINC2))
                     lRet := .T.
                     Exit
                  EndIf
               Next
               If !lRet
                  Help("",1,"REGNOIS")
               EnDIf
            Else
               M->EF3_PARC   := EEQ->EEQ_PARC
               If !EEQ->(dbSeek(if(lMultiFil,M->EF3_FILORI,xFilial("EEQ"))+M->EF3_INVOIC+EV_PRINC2))
                  If M->EF3_CODEVE $ (EV_EMBARQUE+"/"+EV_LIQ_PRC+"/"+EV_LIQ_PRC_FC)
                     Help("",1,"REGNOIS")
                     lRet := .F.
                  EndIf
               EndIf
            EnDIF
            If lRet
            //---------------------------------------------------------LRL 21/12/04 -----Outras Filiais
               If M->EF3_VL_MOE <> 0 .and. !Left(M->EF3_CODEVE,1) $ ("3/4")
                  nValAux := EX400Conv(M->EF1_MOEDA,EEQ->EEQ_MOEDA,M->EF3_VL_MOE,M->EF3_DT_EVE)
                  If EEQ->EEQ_FI_TOT == "S" .or. ;
                  (EEQ->EEQ_FI_TOT=="N" .and. nValAux > (EEQ->EEQ_VL_PAR - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON)) .or. nValAux > (AF200VLFCam("EEQ"))
                     Help(" ",1,"AVG0005244") //MsgInfo(STR0073) //"O saldo disponível na Parcela da Invoice é menor que valor do Evento."
                     lRet := .F.
                  Else
                     M->EF3_PREEMB := EEQ->EEQ_PREEMB
                     M->EF3_MOE_IN := EEQ->EEQ_MOEDA
                     M->EF3_VL_INV := nValAux
                     If EF3->( FieldPos("EF3_FILORI") ) > 0
                        M->EF3_FILORI := EEQ->EEQ_FILIAL
                     EnDIF
                  EndIf
               Else
                  //EEC->(dbSeek(If(lMultiFil,aFiliais[i],xFilial("EEC"))+EEQ->EEQ_PREEMB))
                  M->EF3_PREEMB := EEQ->EEQ_PREEMB
                  M->EF3_MOE_IN := EEQ->EEQ_MOEDA
                  If EF3->( FieldPos("EF3_FILORI") ) > 0
                     M->EF3_FILORI := EEQ->EEQ_FILIAL
                  EnDIF
               EndIf
            EndIf
         Else
            M->EF3_PREEMB := ""
            M->EF3_PARC   := ""
            M->EF3_MOE_IN := ""
            M->EF3_FILORI := ""
         EndIf
         /*If !EEQ->(dbSeek(cFilEEQ+M->EF3_INVOIC+EV_PRINC2)) .and.;
         M->EF3_CODEVE $ ("600/630") .and. !Empty(M->EF3_INVOIC)
            Help("",1,"REGNOIS")
            lRet := .F.
         Else
            If M->EF3_VL_MOE <> 0 .and. !Empty(M->EF3_INVOIC) .and. !Left(M->EF3_CODEVE,1) $ ("3/4")
               EEC->(dbSeek(cFilEEC+EEQ->EEQ_PREEMB))
               nValAux := EX400Conv(M->EF1_MOEDA,EEC->EEC_MOEDA,M->EF3_VL_MOE)
               If EEQ->EEQ_FI_TOT == "S" .or. ;
               (EEQ->EEQ_FI_TOT=="N" .and. nValAux > EEQ->EEQ_VL_PAR) .or. nValAux > EEQ->EEQ_VL
                  Help(" ",1,"AVG0005244") //MsgInfo(STR0073) //"O saldo disponível na Parcela da Invoice é menor que valor do Evento."
                  lRet := .F.
               EndIf
            EndIf
            If lRet
               M->EF3_PREEMB := EEQ->EEQ_PREEMB
               M->EF3_PARC   := EEQ->EEQ_PARC
               EEC->(dbSeek(cFilEEC+EEQ->EEQ_PREEMB))
               M->EF3_MOE_IN := EEC->EEC_MOEDA
               M->EF3_VL_INV := nValAux
            EndIf
         EndIf*/
         EEQ->(dbSetOrder(1))
      EndIf
   // ** GFC - Pré-Pagamento/Securitização
   Case cCampo == "EF3_DT_EVE"
      If lPrePag .and. WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG
         nRec := WorkEF3->(RecNo())
         WorkEF3->(dbSkip())
         Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE <> EV_PRINC_PREPAG
            WorkEF3->(dbSkip())
         EndDo
         If M->EF3_DT_EVE >= WorkEF3->EF3_DT_EVE
            MsgInfo(STR0217) //"A data desta parcela não pode ser maior que a data da próxima parcela."
            lRet := .F.
         EndIf
         WorkEF3->(dbGoTo(nRec))
      ElseIf lPrePag .and. Left(WorkEF3->EF3_CODEVE,2) = Left(EV_JUROS_PREPAG,2)
         nRec := WorkEF3->(RecNo())
         WorkEF3->(dbSkip())
         Do While !WorkEF3->(EOF()) .and. Left(WorkEF3->EF3_CODEVE,2) <> Left(EV_JUROS_PREPAG,2)
            WorkEF3->(dbSkip())
         EndDo
         If M->EF3_DT_EVE >= WorkEF3->EF3_DT_EVE
            MsgInfo(STR0217) //"A data desta parcela não pode ser maior que a data da próxima parcela."
            lRet := .F.
         EndIf
         WorkEF3->(dbGoTo(nRec))
      EndIf
   // **
   Case cCampo == "EX_EVENTO"
      If WorkEF3->EF3_CODEVE == EV_PRINC
         Help(" ",1,"AVG0005243",,EV_PRINC+STR0042,1,10)//MsgInfo(STR0040+EV_PRINC+STR0042) //"O Evento "###" não pode ser excluído."
         lRet:=.F.
      ElseIf WorkEF3->EF3_CODEVE == EV_EMBARQUE

         nRec := WorkEF3->(RecNo())
         nInd := WorkEF3->(IndexOrd())

         If !lEFFTpMod .Or. WorkEF3->EF3_ORIGEM <> "SWB"
            WorkEF3->(dbSetOrder(2))
            cChave := WorkEF3->( EF3_INVOIC+EF3_PARC )
         Else
            WorkEF3->(dbSetOrder(9))
            cChave := WorKEF3->( EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA )
         EndIf

         If WorkEF3->(dbSeek(EV_LIQ_PRC+cChave)) .or.;
            WorkEF3->(dbSeek(EV_LIQ_PRC_FC+cChave)) .OR.;
            WorkEF3->(dbSeek(EV_LIQ_JUR+cChave)) .OR.;
            WorkEF3->(dbSeek(EV_LIQ_JUR_FC+cChave))
            Help(" ",1,"AVG0005252")
            lRet:=.F.
         EndIf
         WorkEF3->(dbGoTo(nRec))
         WorkEF3->(dbSetOrder(nInd))

      ElseIf WorkEF3->EF3_CODEVE == EV_LIQ_PRC  //.and. !Empty(WorkEF3->EF3_PREEMB)  // PLB 22/09/06
         // ** PLB 15/09/06 - Verifica se existe evento 600 quando ACC/ACE
         If !(IIF(lEFFTpMod,M->EF1_CAMTRA=="1",lPrePag  .And.  M->EF1_TP_FIN $ ("03/04") ))
            nRec := WorkEF3->( RecNo() )
            nInd := WorkEF3->( IndexOrd() )
            WorkEF3->( DBSetOrder(6) )
            If WorkEF3->( DBSeek(WorkEF3->EF3_INVOIC+WorkEF3->EF3_PARC+EV_EMBARQUE) )
      	       // Caso esteja liquidado nao permite exclusao
	           EEQ->( DBSetOrder(4) )
               If EEQ->( DBSeek(IIF(lMultiFil,WorkEF3->EF3_FILORI,cFilEEQ)+WorkEF3->EF3_INVOIC+WorkEF3->EF3_PREEMB+WorkEF3->EF3_PARC) )
                  Do While IIF(lMultiFil,WorkEF3->EF3_FILORI,cFilEEQ)+WorkEF3->(EF3_INVOIC+EF3_PREEMB+EF3_PARC) == EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB+EEQ_PARC) ;
                           .And.  !EEQ->( EoF() )
                     If EV_PRINC2 == EEQ->EEQ_EVENT .And. !Empty(EEQ->EEQ_PGT)
	                    MsgInfo(EX401STR(55,57)+".")  //"O evento de liquidacao do principal nao pode ser excluido. " ##"Estorne a liquidacao pela rotina de FFC ou pela manutencao de cambio"
                  	    lRet:=.F.

                     ElseIf EEQ->EEQ_EVENT == "605" .And. !Empty(EEQ->EEQ_PGT) //FSM - 09/10/2012
                        EasyHelp(STR0277+If(EEQ->EEQ_FASE=="P", STR0278, STR0279), STR0098)//STR0277->"O evento de liquidação do principal não pode ser excluido. Estorne a liquidação pela rotina de adiantamento de " //STR0278->"Pedido." //STR0279->"Cliente." //STR0098->"Atenção"
                  	    lRet:=.F.
            	     EndIf
                     EEQ->( DBSkip() )
                  EndDo
               EndIf
            EndIf
            WorkEF3->(dbGoTo(nRec))
            WorkEF3->(dbSetOrder(nInd))
            // **
         Else
            MsgInfo(EX401STR(55,57)+".")  //"O evento de liquidacao do principal nao pode ser excluido. " ##"Estorne a liquidacao pela rotina de FFC ou pela manutencao de cambio"
            lRet:=.F.
         EndIf
         // **
      ElseIf Left(WorkEF3->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2)
         If lLiqPeriodo  .And.  !Empty(WorkEF3->EF3_SEQPER)
            If WorkEF3->EF3_TX_MOE > 0
               MsgStop(EX401STR(0056,0181))  //"O evento de liquidacao do juros nao pode ser excluido." ## "Estorne a liquidacao do juros."
               lRet := .F.
            EndIf
         ElseIf M->EF1_PGJURO == "1"  // PLB 06/06/06 - Apenas restringe exclusao se for Baixa Automatica de Juros
            MsgInfo(EX401STR(56,57,58))  //"O evento de liquidacao do juros nao pode ser excluido. " ## "Estorne a liquidacao pela rotina de FFC ou pela manutencao de cambio" ## " ou estorne a liquidacao do juros."
            lRet:=.F.
         EndIf
      ElseIf WorkEF3->EF3_CODEVE $ (EV_COM_FIN+"/"+EV_D_COM_FIN+"/"+EV_VC_COM_FIN_S+"/"+EV_VC_COM_FIN_D)
         nRec := WorkEF3->(RecNo())
         nInd := WorkEF3->(IndexOrd())
         WorkEF3->(dbSetOrder(2))
         If WorkEF3->(dbSeek(EV_P_COM_FIN+WorkEF3->EF3_INVOIC+WorkEF3->EF3_PARC))
            MsgInfo(STR0173) //"Evento não pode ser excluído pois já existe pagamento para a comissão financeira."
            lRet:=.F.
         ElseIf WorkEF3->EF3_CODEVE == EV_COM_FIN .and. (WorkEF3->(dbSeek(EV_D_COM_FIN+WorkEF3->EF3_INVOIC+WorkEF3->EF3_PARC)) .or.;
         WorkEF3->(dbSeek(EV_VC_COM_FIN_S+WorkEF3->EF3_INVOIC+WorkEF3->EF3_PARC))) .or. WorkEF3->(dbSeek(EV_VC_COM_FIN_D+WorkEF3->EF3_INVOIC+WorkEF3->EF3_PARC))
            MsgInfo(STR0174) //"Evento não pode ser excluído pois existe(m) outro(s) evento(s) ligado(s) a comissão financeira."
            lRet:=.F.
         EndIf
         WorkEF3->(dbGoTo(nRec))
         WorkEF3->(dbSetOrder(nInd))
      ElseIf IIF(lEFFTpMod,M->EF1_CAMTRA == "1",lPrepag .And. M->EF1_TP_FIN$"03/04") .and. WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG .or. Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2) //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
         nRec := WorkEF3->(RecNo())
         nInd := WorkEF3->(IndexOrd())
         WorkEF3->(dbSetOrder(2))
         If WorkEF3->(dbSeek(WorkEF3->EF3_CODEVE+WorkEF3->EF3_INVOIC+StrZero(Val(WorkEF3->EF3_PARC)+1,AvSX3("EF3_PARC",3))))
            MsgInfo(STR0241) //"Esta parcela não pode ser excluída pois existe parcela com vencimento posterior."
            lRet:=.F.
         EndIf
         WorkEF3->(dbGoTo(nRec))
         WorkEF3->(dbSetOrder(nInd))
      EndIf
      if cMod == IMP .and.  SE2->( dbsetorder(1),DBSEEK( WORKEF3->EF3_TITFIN ) )
            //"E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ"
            if SE5->( dbsetorder(7),dbseek( SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) ) )
                  lRet:= .F.
                  EasyHelp(STR0288,STR0094) //"Essa parcela não pode ser excluída pois o título teve a conciliação bancária efetuada, estorne a conciliação para poder prosseguir com a ação.","Aviso"
            endif
      endif
   Case cCampo == "EX_PERIODO"
      //If M->EF1_DT_JUR <> M->EF1_DT_CTB .and. M->EF1_DT_CTB >= WorkEF2->EF2_DT_INI //.and. ;
      //M->EF1_DT_CTB <= WorkEF2->EF2_DT_FIM
      If !Empty(M->EF1_DT_CTB)  .And.  lIsContab  .And.  M->EF1_DT_CTB >= WorkEF2->EF2_DT_INI  // PLB 13/06/07
	     EasyHelp("Período não pode ser excluído pois o contrato foi contabilizado ("+DTOC(M->EF1_DT_CTB)+") após o inicio deste periodo ("+DTOC(WorkEF2->EF2_DT_INI)+").") //AAF 20/07/2015
         lRet := .F.
      EndIf
   Case cCampo == "GRV_EVE"
      If M->EF1_TP_FIN == ACE .and. M->EF1_CAMTRA == "1" .and. ; //M->EF1_LIQFIX == "2" .and.;  //PLB 17/02/06 - Campo EF1_LIQFIX excluido do Dicionario
      Empty(M->EF3_DT_FIX)
         Help(" ",1,"AVG0005245") //MsgInfo(STR0043) //"Data Fixa deve ser preenchida."
         lRet := .F.
      ElseIf M->EF3_CODEVE $(EV_EMBARQUE+"/"+EV_LIQ_PRC+"/"+EV_LIQ_PRC_FC) .and. ( ( (cMod == EXP .OR. M->EF3_ORIGEM == "EEQ") .AND. Empty(M->EF3_INVOIC)).OR.(cMod==IMP .AND. M->EF3_ORIGEM == "SWB" .AND. Empty(M->EF3_INVIMP)) )
         Help(" ",1,"AVG0005246") //MsgInfo(STR0044) //"Necessário selecionar uma Invoice para este tipo de Evento."
         lRet := .F.
      ElseIf M->EF3_CODEVE $ (EV_P_COM_FIN+"/"+EV_D_COM_FIN)
         nOrdEF3 := WorkEF3->(IndexOrd())
         WorkEF3->(dbSetOrder(2))
         If lIncluiAux .and. M->EF3_CODEVE == EV_P_COM_FIN .and. WorkEF3->(dbSeek(EV_P_COM_FIN+M->EF3_INVOIC+M->EF3_PARC))
            nValAux := M->EF3_VL_MOE
            Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE==EV_P_COM_FIN .and. WorkEF3->EF3_INVOIC==M->EF3_INVOIC .and.;
            WorkEF3->EF3_PARC == M->EF3_PARC
               nValAux += WorkEF3->EF3_VL_MOE
               WorkEF3->(dbSkip())
            EndDo
         EndIf
         If lRet .and. lIncluiAux
            If !WorkEF3->(dbSeek(EV_COM_FIN+M->EF3_INVOIC+M->EF3_PARC))
               MsgInfo(STR0176) //"Este evento não pode ser incluído pois não existe evento de Comissão Financeira (140)."
               lRet:=.F.
            ElseIf M->EF3_VL_MOE > WorkEF3->EF3_VL_MOE
               MsgInfo(STR0194) //"O valor deste evento não pode ser maior que o valor do evento de Comissão Financeira (140)."
               lRet:=.F.
            ElseIf M->EF3_CODEVE == EV_P_COM_FIN .and. nValAux > WorkEF3->EF3_VL_MOE
               MsgInfo(STR0195) //"O valor dos pagamentos não pode ser maior que o valor do evento de Comissão Financeira (140)."
               lRet:=.F.
            EndIf
         EndIf
         WorkEF3->(dbSetOrder(nOrdEF3))
      ElseIf M->EF3_CODEVE == EV_COM_FIN
         nOrdEF3 := WorkEF3->(IndexOrd())
         WorkEF3->(dbSetOrder(2))
         If lIncluiAux .and. WorkEF3->(dbSeek(EV_COM_FIN+M->EF3_INVOIC+M->EF3_PARC))
            MsgInfo(STR0177) //"Já existe evento de Comissão Financeira (140) para esta invoice e parcela."
            lRet:=.F.
         EndIf
         WorkEF3->(dbSetOrder(nOrdEF3))
      EndIf
   Case cCampo == "nValInv"
      nValFin := Round(( nValInv * nTaxaVinc ) / nTaxaFin,nDecValor)   // PLB 30/10/06
      If nValInv <= 0
         Help(" ",1,"AVG0005247") //MsgInfo(STR0045) //"Valor deve ser maior que zero."
         lRet := .F.
      ElseIf nTaxaVinc <= 0
         MsgInfo(STR0202) //"A taxa de vinculação deve ser maior que zero"
         lRet := .F.
      ElseIf nValInv > WorkInv->VL_ORI
         Help(" ",1,"AVG0005248") //MsgInfo(STR0046) //"Valor nao pode ser maior que valor da Invoice."
         lRet := .F.
      ElseIf (cMod == EXP .And. cTipoVinc=="1" .and. nValFin > nSaldoRest /*M->EF1_SLD_PM*/) // PLB 30/10/06
      //ElseIf (cMod == EXP .And. cTipoVinc=="1" .and. EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc) > M->EF1_SLD_PM) // GFC - 27/07/05 - CnValInv > M->EF1_SLD_PM
         //If cMod == EXP
            MsgInfo(STR0113+Trans(nSaldoRest/*M->EF1_SLD_PM*/,AVSX3("EF1_SLD_PM",6));   //"Valor a vincular não pode ser maior que saldo do contrato. "
                    +CHR(10)+CHR(13);
                    +"Saldo na Moeda da Invoice: "+Trans(Int(((nSaldoRest/*M->EF1_SLD_PM*/*nTaxaFin)/nTaxaVinc)*(10^2))/(10^2),AVSX3("EF1_SLD_PM",6)))  //PLB 19/12/06 - Arredondamento sempre para baixo quando especificar o saldo na moeda da invoice.
            lRet := .F.
         //ElseIf (lRet := MsgYesNo("Valor a Vincular e maior que o valor do contrato."+CHR(13)+CHR(10)+"Deseja efetivar a vinculacao e aumentar o valor do contrato para "+M->EF1_MOEDA+" "+AllTrim(Trans(EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc),AVSX3("EF1_SLD_PM",6)))+"?"))
               //lAumVlCont := .T.
               //M->EF1_VL_MOE := EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc)
         //EndIf
      //ElseIf (cMod == EXP .And. cTipoVinc=="1" .And. (nVincTot+nValFin) > nSaldoRest /*M->EF1_SLD_PM*/)  // PLB 30/10/06 //MCF - 07/04/2016 - A variável nSaldoRest é atualizada a todo momento com o saldo
      ElseIf (cMod == EXP .And. cTipoVinc=="1" .and. nValFin > nSaldoRest /*M->EF1_SLD_PM*/)
      //ElseIf (cMod == EXP .And. cTipoVinc=="1" .and. (nVincTot+EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc)) > M->EF1_SLD_PM) // GFC - 27/07/05 - (nVincTot+nValInv) > M->EF1_SLD_PM
         //If cMod == EXP
            //MsgInfo(STR0114+"("+Alltrim(Trans(nVincTot+EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc),AVSX3("EF1_SLD_PM",6)))+")"+STR0115+Trans(M->EF1_SLD_PM,AVSX3("EF1_SLD_PM",6))) //"O valor total das invoices marcadas " # " não pode ultrapassar o saldo do contrato. "
            //MsgInfo(STR0114+"("+Alltrim(Trans(nVincTot+nValFin,AVSX3("EF1_SLD_PM",6)))+")"+STR0115+Trans(M->EF1_SLD_PM,AVSX3("EF1_SLD_PM",6))) //"O valor total das invoices marcadas " # " não pode ultrapassar o saldo do contrato. "
            MsgInfo(STR0114+"("+Alltrim(Trans(nVincTot+nValFin,AVSX3("EF1_SLD_PM",6)))+")"+STR0115+Trans(Int(((nSaldoRest/*M->EF1_SLD_PM*/*nTaxaFin)/nTaxaVinc)*(10^2))/(10^2),AVSX3("EF1_SLD_PM",6)))
            lRet := .F.
         //ElseIf (lRet := MsgYesNo(STR0114+"e maior que o valor do contrato."+CHR(13)+CHR(10)+"Deseja efetiva a vinculacoes e aumentar o valor do contrato para "+M->EF1_MOEDA+" "+AllTrim(Trans(nVincTot+EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc),AVSX3("EF1_SLD_PM",6)))+"?"))
               //lAumVlCont := .T.
               //M->EF1_VL_MOE := nVincTot+EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc)
         //EndIf
      EndIf
      If lRet .And. (cMod == IMP .And. cTipoVinc=="1" .and. (nJaVinc+nVincTot+nValFin) > M->EF1_SLD_PM) //PLB 14/08/06
         If (lRet := MsgYesNo(EX401STR(60)+CHR(13)+CHR(10)+EX401STR(61)+M->EF1_MOEDA+" "+AllTrim(Trans(nJaVinc+nVincTot+nValFin,AVSX3("EF1_SLD_PM",6)))+"?"))  //"Valor a Vincular e maior que o valor do contrato." ## "Deseja efetivar a vinculacao e aumentar o valor do contrato para "
            lAumVlCont := .T.
            M->EF1_VL_MOE := nJaVinc+nVincTot+nValFin  // PLB 30/10/06
         EndIf
      EndIf
      //If lRet//  .And.  lMEDif
      //   nValFin := ( nValInv * nTaxaVinc ) / nTaxaFin   // PLB 30/10/06
      //EndIf
   // ** PLB 29/06/06
   Case cCampo == "FILTROS"
      If cFiltro == aFiltro[1]   // "Por Invoice e Evento"
         lGetInv := .T.
         lGetPar := .T.
         lGetEve := .T.
         If Empty(cEvento)
            cEvento := Space( Len(WorkEF3->EF3_CODEVE) )
         EndIf
      ElseIf cFiltro == aFiltro[2]   // "Por Invoice"
         lGetInv := .T.
         lGetPar := .T.
         lGetEve := .F.
         cEvento := Space( Len(cEvento) )
      ElseIf cFiltro == aFiltro[3]   // "Por Evento"
         lGetInv := .F.
         lGetPar := .F.
         lGetEve := .T.
         cInv    := Space( Len(cInv)  )
         cParc   := Space( Len(cParc) )
         If Empty(cEvento)
            cEvento := Space( Len(WorkEF3->EF3_CODEVE) )
         EndIf
      ElseIf cFiltro == aFiltro[4]  // "Limpar Filtro"
         lGetInv := .F.
         lGetPar := .F.
         lGetEve := .T.
         cInv    := Space( Len(cInv)    )
         cParc   := Space( Len(cParc)   )
         cEvento := ""
      EndIF
   // **
   Case cCampo == "FILTRO_INVOICE"
      cCarAux := WorkEF3->(dbFilter())
      SET FILTER TO
      If cMod == IMP
         WorkEF3->( DBSetOrder(10) )  // PLB 25/10/06
         If !WorkEF3->(dbSeek(AVKey(cInv,"EF3_INVIMP")))
            Help(" ",1,"AVG0005249") //MsgInfo(STR0047) //"Invoice não existe nos Eventos do Contrato."
            lRet := .F.
         EndIf
      Else
         WorkEF3->(dbSetOrder(3))
         If !WorkEF3->(dbSeek(cInv))
            Help(" ",1,"AVG0005249") //MsgInfo(STR0047) //"Invoice não existe nos Eventos do Contrato."
            lRet := .F.
         EndIf
      EndIf
      If lRet
         lGetPar := .T.
      Else
         lGetPar := .F.
      EndIf
      SET FILTER TO &cCarAux
   Case cCampo == "FILTRO_EVENTO"
      If !Empty(cEvento)
         cCarAux := WorkEF3->(dbFilter())
         SET FILTER TO
         If !EC6->(dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. M->EF1_TPMODU <> IMP,"FIEX","FIIM")+M->EF1_TP_FIN+cEvento))
            Help("",1,"REGNOIS")
            lRet := .F.
         Endif
         SET FILTER TO &cCarAux
      EndIf
   // ** PLB 25/10/06
   Case cCampo == "FILTRO_OK"
      If cFiltro == aFiltro[1]   // "Por Invoice e Evento"
         If Empty(cInv)
            MsgInfo(EX401STR(0172)+STR0122+".")  //"Preencha o campo Invoice."
            lRet := .F.
         ElseIf Empty(cEvento)
            MsgInfo(EX401STR(0172,0109)+".")  //"Preencha o campo Evento."
            lRet := .F.
         EndIf
      ElseIf cFiltro == aFiltro[2]   // "Por Invoice"
         If Empty(cInv)
            MsgInfo(EX401STR(0172)+STR0122+".")  //"Preencha o campo Invoice."
            lRet := .F.
         EndIf
      ElseIf cFiltro == aFiltro[3]   // "Por Evento"
         If Empty(cEvento)
            MsgInfo(EX401STR(0172,0109)+".")  //"Preencha o campo Evento."
            lRet := .F.
         EndIf
      EndIf
   // **
   Case (cCampo == "dDataVinc" .Or. cCampo == "dDataGeral")
      If (cCampo = "dDataVinc" .And. Empty(dDataVinc)) .Or. (cCampo = "dDataGeral" .And. Empty(dDataGeral))
         Help(" ",1,"AVG0005287") //MsgInfo(STR0080)  //"Data de Vinculação deve ser preenchida."
         lRet := .F.
      ElseIf ( cCampo == "dDataVinc"  .And.  dDataVinc < M->EF1_DT_CON )  .Or.  ( cCampo == "dDataGeral"  .And.  dDataGeral < M->EF1_DT_CON )
         MsgInfo(EX401STR(0183)+" ("+DToC(M->EF1_DT_CON)+").")  //"Data de Vinculação não pode ser menor que a Data de Início do Contrato"
         lRet := .F.
      /*ElseIf M->EF1_TP_FIN == "01" .And. EEC->(dbSeek(xFilial("EEC")+WorkInv->EF3_PREEMB)) .And. EEC->EEC_DTEMBA < M->EF1_DT_CON
            easyhelp(STR0290) //"Não é permitido vincular Invoice com data de embarque inferior à data de contrato(Rotina Manut. Contrato) do tipo ACC."
            lRet := .F.      */
      /*ElseIf (cCampo == "dDataVinc" ).AND. WorkInv->EF3_ORIGEM == "EEQ" .AND. !Empty(WorkInv->DTCE) .And. dDataVinc>WorkInv->DTCE//FSY - Função para validar o campo da data de vinculação ao marcar caixa mark na rotina "Efetivo". 10/04/2013
         MsgInfo("Data de Vinculação não pode ser maior que a Data de credito exterior ("+ DtoC(WorkInv->DTCE) +").")
         lRet := .F.*/
      Else
         If cCampo == "dDataVinc"
            //MFR 28/10/2019 OSSME-3908
            EEC->(DBSETORDER(1))
            If M->EF1_TP_FIN == "01" .And. EEC->(dbSeek(xFilial("EEC")+WorkInv->EF3_PREEMB)) .And. EEC->EEC_DTEMBA < M->EF1_DT_CON .And. !(EasyVerModal("WorkInv") .And. WorkInv->TIPO == "A")
                  easyhelp(STR0290) //"Não é permitido vincular Invoice com data de embarque inferior à data de contrato do tipo ACC."
                  lRet := .F.
            ElseIf EEC->(dbSeek(xFilial("EEC")+WorkInv->EF3_PREEMB))
               dDtEmba := EEC->EEC_DTEMBA
            Else
               dDtEmba := dDataVinc
            EndIf
            If lRet .And. dDataVinc < dDtEmba
               MsgInfo(STR0112+" ("+DtoC(dDtEmba)+")") //"Data de Vinculação não pode ser menor que a Data de Embarque."
               lRet := .F.
            ElseIf lRet .And. dDataVinc > dDataBase
               MsgInfo(EX401STR(0147)) //"A Data de Vinculação não pode ser maior que a data corrente do sistema."
               lRet := .F.
            Else
               //Alcir Alves - 23-06-05 - caso a taxa original tenha sido alterado na acionar o valid
               if !nTaxaAlt // .or. dDataVinc<>dDataGeral
                  nTaxaVinc  := BuscaTaxa(WorkInv->EF3_MOE_IN,dDataVinc,,.F.,.T.,,cTX_100)
                  If !lMEDif
                     nTaxaFin := nTaxaVinc   // PLB 30/10/06
                  EndIf
                  nValFin := ( nValInv * nTaxaVinc ) / nTaxaFin   // PLB 30/10/06
               endif
               //
            EndIf
         Elseif cCampo == "dDataGeral"           
            nTaxaGeral := BuscaTaxa(M->EF1_MOEDA,dDataGeral,,.F.,.T.,,cTX_100)
            //Alcir Alves - 23-06-05 - atribui a taxa original do dia
            nTaxaOri:= nTaxaGeral
            nTaxaAlt:=.f.
            //
         Endif

         // ** PLB 20/10/06 - Valida se a data de vinculação é maior que a data da parcela de pagamento
         If lRet  .And.  cMod == EXP  .And.  IIF(lEFFTPMod,M->EF1_CAMTRA=="1",lPrepag .And. M->EF1_TP_FIN $ PRE_PAGTO+"/"+SECURITIZACAO)

            cEvento := if(cTipoVinc == "1","70","71")
            nOldRec := WorkEF3->(RecNo())
            nOldOrd := WorkEF3->(IndexOrd())

            WorkEF3->(dbSetOrder(2))
            WorkEF3->(dbSeek(cEvento))
            Do While !WorkEF3->(EOF()) .and. Left(WorkEF3->EF3_CODEVE,2) == cEvento
               If WorkEF3->EF3_SLDVIN > 0 .AND. WorkEF3->EF3_VL_REA == 0
                  Exit
               EndIf
               WorkEF3->(dbSkip())
            EndDo

            If !WorkEF3->(EOF()) .and. Left(WorkEF3->EF3_CODEVE,2) == cEvento  .And.  &cCampo > WorkEF3->EF3_DT_EVE
               MsgInfo(EX401STR(0146)+DToC(WorkEF3->EF3_DT_EVE))  //"A Data de Vinculação não pode ser maior do que a data da primeira parcela em aberto: "
               lRet := .F.
            EndIf

            WorkEF3->(dbSetOrder(nOldOrd))
            WorkEF3->(dbGoTo(nOldRec))
         EndIf
         // **
      EndIF       
   Case cCampo == "nTaxaVinc"
      If nTaxaVinc <= 0
         MsgInfo(STR0202) //"A taxa de vinculação deve ser maior que zero"
         lRet := .F.
      Else
         If !lMEDif
            nTaxaFin := nTaxaVinc
         EndIf
         nValFin := ( nValInv * nTaxaVinc ) / nTaxaFin   // PLB 30/10/06
      Endif

   // ** PLB 30/10/06
   Case cCampo == "nTaxaFin"
      If Empty(nTaxaFin)
         Help(" ",1,"AVG0005247") //"Valor deve ser maior que zero."
         lRet := .F.
      Else
         nValFin := ( nValInv * nTaxaVinc ) / nTaxaFin
      Endif
   // **

   //Alcir Alves - 23-06-05 - caso a taxa original do dia tenha sido modificada
   Case cCampo == "nTaxaGeral"
      if nTaxaGeral<>nTaxaOri
         nTaxaAlt:=.t.
      endif
   //
   Case cCampo == "OK"
      lRet := .T.
   Case cCampo == "EF1_BAN_FI"
      If !Empty(M->EF1_BAN_FI) .And. !SA6->(DbSeek(xFilial("SA6")+M->EF1_BAN_FI))
         Help(" ",1,"AVG0005288") //MsgInfo(STR0092)  //"Banco não Cadastrado !!!"
         lRet := .F.
      Endif
   Case cCampo == "EF1_BAN_MO"
      If !Empty(M->EF1_BAN_MO) .And. !SA6->(DbSeek(xFilial("SA6")+M->EF1_BAN_MO))
         Help(" ",1,"AVG0005288") //MsgInfo(STR0092)  //"Banco não Cadastrado !!!"
         lRet := .F.
      Endif
   Case cCampo == "EF1_AGENFI"
      If !Empty(M->EF1_AGENFI) .and. !SA6->(DbSeek(xFilial("SA6")+M->EF1_BAN_FI+M->EF1_AGENFI))
         EasyHelp( STR0292 , STR0094 ) // "Agência de fechamento não cadastrada para o banco informado." ### "Aviso"
         lRet := .F.
      Endif
   Case cCampo == "EF1_AGENMO"
      If !Empty(M->EF1_AGENMO) .And. !SA6->(DbSeek(xFilial("SA6")+M->EF1_BAN_MO+M->EF1_AGENMO))
         EasyHelp( STR0293 , STR0094 ) // "Agência de movimentação não cadastrada para o banco informado." ### "Aviso"
         lRet := .F.
      Endif
   Case cCampo == "EF1_NCONFI"
      If !Empty(M->EF1_NCONFI) .And. !SA6->(DbSeek(xFilial("SA6")+M->EF1_BAN_FI+M->EF1_AGENFI+M->EF1_NCONFI))
         EasyHelp( STR0294 , STR0094 ) // "Conta de fechamento não cadastrada para a agência e banco informado." ### "Aviso"
         lRet := .F.
      Endif
   Case cCampo == "EF1_NCONMO"
      If !Empty(M->EF1_NCONMO) .And. !SA6->(DbSeek(xFilial("SA6")+M->EF1_BAN_MO+M->EF1_AGENMO+M->EF1_NCONMO))
         EasyHelp( STR0295 , STR0094 ) // "Conta de movimentação não cadastrada para a agência e banco informado." ### "Aviso"
         lRet := .F.
      Endif

   // ACSJ - Caetano - 26/01/2005
   Case iif( lTemChave,cCampo == "EF1_PRACA",.f.)
      If !Empty(M->EF1_PRACA) .and. !EF5->(DbSeek(xFilial("EF5")+M->EF1_PRACA))
         MsgInfo(STR0153)  // "Praça não cadastrada !!!
         lRet := .f.
      Endif
   // ---------------------------
   Case cCampo == "EF1_DT_VIN"  //TAN
      If !Empty(M->EF1_DT_VIN)
         If Empty(M->EF1_DT_CON)
            MsgInfo(EX401STR(0148),STR0094) //"É necessário preencher a data do contrato.", "Aviso"
            lRet := .F.
         Else
            If !Empty(M->EF1_DT_JUR)  .And.  M->EF1_DT_VIN < M->EF1_DT_JUR
               MsgInfo(STR0095,STR0094) //"Data de Vinculação deve ser maior que a Data de Início dos Juros!", "Aviso"
               lRet := .F.
            // ** PLB 24/10/06
            ElseIf !Empty(M->EF1_DT_CON)  .And.  M->EF1_DT_VIN < M->EF1_DT_CON
               MsgInfo(EX401STR(0149),STR0094) //"Data de Vinculação deve ser maior que a Data do Contrato!", "Aviso"
               lRet := .F.
            //Nopado por TRP em 18/02/08 para permitir entrega posterior de documentos.
            /*ElseIf !Empty(M->EF1_DT_VEN)  .And.  M->EF1_DT_VIN > M->EF1_DT_VEN
               MsgInfo(EX401STR(0150),STR0094) //"Data de Vinculação deve ser menor ou igual a Data de Vencimento!", "Aviso"
               lRet := .F.*/
            // **
            EndIf
         Endif
         If !lRet
            AvSetFocus("EF1_DT_VIN",oDlgFocus)
         EndIf
      EndIf
   Case cCampo == "EF1_DT_VEN"  // TAN
      // ** PLB 21/03/07
      If !Empty(M->EF1_DT_VEN)
         If Empty(M->EF1_DT_CON)
            MsgInfo(EX401STR(0148),STR0094) //"É necessário preencher a data do contrato.", "Aviso"
            lRet := .F.
         Else
            //Nopado por TRP em 18/02/08 para permitir entrega posterior de documentos.
            /*If !Empty(M->EF1_DT_VIN)  .And.  M->EF1_DT_VEN < M->EF1_DT_VIN
               MsgInfo(STR0096,STR0094) //"Data de Vencimento deve ser maior que a Data de Vinculação!", "Aviso"
               lRet := .F.*/
            If !Empty(M->EF1_DT_JUR)  .And.  M->EF1_DT_VEN < M->EF1_DT_JUR
               MsgInfo(EX401STR(0170),STR0094) //"Data de Vencimento deve ser maior que a Data de Início dos Juros!", "Aviso"
               lRet := .F.
            ElseIf M->EF1_DT_VEN < M->EF1_DT_CON
               MsgInfo(EX401STR(0171),STR0094) //"Data de Vencimento deve ser maior que a Data do Contrato!", "Aviso"
               lRet := .F.
            EndIf
         EndIf
         If !lRet
            AvSetFocus("EF1_DT_VEN",oDlgFocus)
         EndIf
      EndIf
      // **
   Case cCampo == "BX_JUROS"
      If lPrePag .AND. M->EF1_CAMTRA == "1" // ** GFC - Pré-Pagamento / Securitização //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
         nRec     := WorkEF3->(RecNo())
         nInd     := WorkEF3->(IndexOrd())
         cParcVin := WorkEF3->EF3_PARC
         cEvVin   := WorkEF3->EF3_CODEVE
         WorkEF3->(dbSetOrder(2))
         If !(Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2))
            MsgInfo(STR0233) //"Somente parcelas do juros podem ser liquidadas."
            lRet := .F.
         ElseIf WorkEF3->(dbSeek(EV_EMBARQUE))
            Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE == EV_EMBARQUE
               If WorkEF3->EF3_PARVIN == cParcVin .and. WorkEF3->EF3_EV_VIN == cEvVin
                  Exit
               EndIf
               WorkEF3->(dbSkip())
            EndDo
            If !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE == EV_EMBARQUE .and. WorkEF3->EF3_PARVIN == cParcVin .and.;
            WorkEF3->EF3_EV_VIN == cEvVin
               WorkEF3->(dbGoTo(nRec))
               If WorkEF3->EF3_SLDLIQ > 0  .And.  WorkEF3->EF3_SLDVIN <= 0   // PLB 26/06/06 - Somente se estiver totalmente vinculada
                  MsgInfo(STR0223) //"Esta parcela não pode ser liquidada pois não possui o suficiente de invoices pagas vinculadas a ela."
                  lRet := .F.
               EndIf
            EndIf
         EndIf
         If lRet
            WorkEF3->(dbGoTo(nRec))
            cEvAux := WorkEF3->EF3_CODEVE
            WorkEF3->(dbSetOrder(2))
            WorkEF3->(dbSkip(-1))
            If WorkEF3->EF3_CODEVE == cEvAux .and. WorkEF3->EF3_TX_MOE == 0//WorkEF3->EF3_TX_MOE <> 0
               MsgInfo(STR0227) //"Esta parcela não pode ser liquidada pois a parcela anterior ainda não foi paga."
               lRet := .F.
            EndIf
         EndIf
         WorkEF3->(dbGoTo(nRec))
         WorkEF3->(dbSetOrder(nInd))
      EndIf
   // ** PLB 26/10/06 - Valida estorno de liquidação de Juros
   Case cCampo == "EST_BX_JUROS"
      If IIF(lEFFTpMod,M->EF1_CAMTRA == "1",lPrePag .And. M->EF1_TP_FIN $ PRE_PAGTO+"/"+SECURITIZACAO)
         If Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)
            nRec := WorkEF3->(RecNo())
            nInd := WorkEF3->(IndexOrd())
            cEvAux := Left(WorkEF3->EF3_CODEVE,2)
            WorkEF3->(dbSetOrder(2))
            WorkEF3->(dbSkip(1))
            If Left(WorkEF3->EF3_CODEVE,2) == cEvAux .And. ( WorkEF3->EF3_TX_MOE > 0  .Or.  IIF(cMod==EXP,WorkEF3->(EF3_VL_MOE != EF3_SLDVIN),.F.) )
               MsgInfo(EX401STR(0156)) //"Esta amortização não pode ser estornada pois a Parcela posterior já foi vinculada e/ou liquidada."
               lRet := .F.
            EndIf
            WorkEF3->(dbGoTo(nRec))
            WorkEF3->(dbSetOrder(nInd))
         EndIf
      EndIf
   // **

   Case cCampo == "BX_FORCADA"
      If !(IIF(lEFFTpMod,M->EF1_CAMTRA == "1",lPrePag .AND. M->EF1_TP_FIN $ ("03/04"))) // ** GFC - Pré-Pagamento / Securitização //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
         If !(WorkEF3->EF3_CODEVE == EV_PRINC .and. lEF3_CTDEST)// ** AAF 31/10/05 - Encerramento/Transferência.
            If WorkEF3->EF3_CODEVE <> EV_EMBARQUE
               MsgInfo(STR0183) //"É necessário estar posicionado em um evento de embarque(600) para realizar a baixa no contrato"
               lRet := .F.
            ElseIf !MsgYesNo(EX401STR(40,41))  //"Esta liquidacao nao ira tirar a pendencia do cliente no cambio de exportacao. " # "Confirma a liquidacao?"
               lRet := .F.
            Else
               nRec := WorkEF3->(RecNo())
               nInd := WorkEF3->(IndexOrd())
               cInvAux  := WorkEF3->EF3_INVOIC
               cParcAux := WorkEF3->EF3_PARC
               WorkEF3->(dbSetOrder(2))
               If WorkEF3->(dbSeek(EV_LIQ_PRC+cInvAux+cParcAux)) .or. WorkEF3->(dbSeek(EV_LIQ_PRC_FC+cInvAux+cParcAux))
                  MsgInfo(STR0184) //"Já existe baixa para esta parcela."
                  lRet := .F.
               EndIf
               WorkEF3->(dbGoTo(nRec))
               WorkEF3->(dbSetOrder(nInd))
               oMark:oBrowse:Refresh()
            EndIf
         Endif
      Else
         If !(WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG) // .or. Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)
            MsgInfo(STR0228) //"Somente parcelas do principal podem ser liquidadas."
            lRet := .F.
         ElseIf cMod == EXP .AND. WorkEF3->EF3_SLDLIQ > 0
            MsgInfo(STR0223) //"Esta parcela não pode ser liquidada pois não possui o suficiente de invoices pagas vinculadas a ela."
            lRet := .F.
         Else
            nRec := WorkEF3->(RecNo())
            nInd := WorkEF3->(IndexOrd())
            cEvAux := WorkEF3->EF3_CODEVE
            WorkEF3->(dbSetOrder(2))
            WorkEF3->(dbSkip(-1))
            If WorkEF3->EF3_CODEVE == cEvAux .and. WorkEF3->EF3_TX_MOE == 0//WorkEF3->EF3_TX_MOE <> 0
               MsgInfo(STR0227) //"Esta parcela não pode ser liquidada pois a parcela anterior ainda não foi paga."
               lRet := .F.
            EndIf
            WorkEF3->(dbGoTo(nRec))
            WorkEF3->(dbSetOrder(nInd))
         EndIf
      EndIf
      If Empty(EF1_DT_JUR) .and. WorkEF3->EF3_CODEVE == EV_PRINC
         MsgStop(STR0276,STR0098) //FSM - 09/08/2012 - #STR0276->"Não é possível liquidar o evento sem que a Data de Início de Juros esteja preenchida" ##STR0098->"Atenção"
         lRet := .F.
      EndIf
   Case cCampo == "EST_BX_FORCADA"
      // ** PLB 26/10/06
      If IIF(lEFFTpMod,M->EF1_CAMTRA == "1",lPrePag .And. M->EF1_TP_FIN $ PRE_PAGTO+"/"+SECURITIZACAO)
         If WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG
            nRec := WorkEF3->(RecNo())
            nInd := WorkEF3->(IndexOrd())
            cEvAux := WorkEF3->EF3_CODEVE
            WorkEF3->(dbSetOrder(2))
            WorkEF3->(dbSkip(1))
            If WorkEF3->EF3_CODEVE == cEvAux .And. ( WorkEF3->EF3_TX_MOE > 0  .Or.  IIF(cMod==EXP,WorkEF3->(EF3_VL_MOE != EF3_SLDVIN),.F.) )
               MsgInfo(EX401STR(0156)) //"Esta amortização não pode ser estornada pois a Parcela posterior já foi vinculada e/ou liquidada."
               lRet := .F.
            EndIf
            WorkEF3->(dbGoTo(nRec))
            WorkEF3->(dbSetOrder(nInd))
         EndIf
      ElseIf WorkEF3->EF3_CODEVE <> EV_LIQ_PRC_FC
         MsgInfo(STR0201) //"É necessário estar posicionado em um evento de liquidação forçada do principal(660) para estornar a baixa forçada."
         lRet := .F.
      EndIf
      // **
   // ** GFC - Pré-Pagamento/Securitização
   Case cCampo == "RECALC"
      WorkEF3->(dbSetOrder(2))
      If cMod == EXP .AND. !M->EF1_CAMTRA == "1"//M->EF1_TP_FIN <> "03" .and. M->EF1_TP_FIN <> "04"
         MsgInfo(EX401STR(62)) //"Calculo somente para Parcelas de Pagamento." //STR0205 - "Calculo utilizado apenas para contratos de Pré-Pagamento ou Securitização."
         lRet := .F.
      ElseIf WorkEF2->(EasyRecCount()) <= 0
         MsgInfo(STR0211) //"É necessário incluir os períodos do contrato para efetuar o cálculo das parcelas."
         lRet := .F.
      Else
         aAux := {{M->EF1_DT_JUR,"EF1_DT_JUR"},{M->EF1_PARCPR,"EF1_PARCPR"},{M->EF1_TPCAPR,"EF1_TPCAPR"},;
                  {M->EF1_TPPEPR,"EF1_TPPEPR"},{M->EF1_PERIPR,"EF1_PERIPR"},; //{M->EF1_CAREPR,"EF1_CAREPR"}
                  {M->EF1_VL_MOE,"EF1_VL_MOE"},{M->EF1_PARCJR,"EF1_PARCJR"},{M->EF1_TPCAJR,"EF1_TPCAJR"},;
                  {M->EF1_TPPEJR,"EF1_TPPEJR"},{M->EF1_PERIJR,"EF1_PERIJR"},; //{M->EF1_CAREJR,"EF1_CAREJR"}
                  {M->EF1_MOEDA ,"EF1_MOEDA"}}
         For nInd:=1 to Len(aAux)
            If Empty(aAux[nInd,1])
               MsgInfo(STR0209+Alltrim(AvSX3(aAux[nInd,2],5))+STR0210) //"É necessário preencher a(o) " # " para gerar as parcelas."
               lRet := .F.
               Exit
            EndIf
         Next nInd
      EndIf
      WorkEF3->(dbSetOrder(ORDEM_BROWSE))
   // **
   Case cCampo == "VINC_INVOICES"
      If cMod == EXP
         If WorkEF2->(EasyRecCount()) <= 0  //.And.  cMod == EXP
            MsgInfo(STR0246) //"É necessário incluir os períodos de juros para vincular faturas ao contrato."
            lRet := .F.
         ElseIf Empty(M->EF1_DT_JUR)  //.And.  cMod == EXP
            MsgInfo(EX401STR(63)) //"É necessário preencher a data de início do juros para vincular invoices ao contrato."
            lRet := .F.
         ElseIf lPrePag .AND. M->EF1_CAMTRA == "1" //.AND. cMod == EXP//lPrePag .and. M->EF1_TP_FIN $ ("03/04")
            WorkEF3->(dbSetOrder(2))
            If !WorkEF3->(dbSeek(EV_PRINC_PREPAG))
               MsgInfo(STR0247) //"É necessário calcular as parcelas do principal e do juros para vincular faturas ao contrato."
               lRet := .F.
            EndIf
            WorkEF3->(dbSetOrder(ORDEM_BROWSE))
         EndIf
      ElseIf cMod == IMP
         If !Empty(M->EF1_DT_JUR)
            MsgStop(EX401STR(64)) //"Não podem ser feitas novas vinculações neste contrato pois a data de inicio dos juros já está preenchida."
            lRet := .F.
         EndIf
      EndIf

   // ** FSM - 08/03/2012
   Case cCampo == "EF1_PERIPR"
      If !Empty(M->EF1_DT_JUR)
/*         WorkEF3->(dbSetOrder(2)) // MPG - 16/01/2018 - Validação removida porque não faz sentido, onde mesmo que com vinculação a rotina deve permitir alterar os tempos e recalcular os saldos
         //Verifica se existe vinculação.
         If WorkEF3->(dbSeek(EV_EMBARQUE))
            Do While ! WorkEF3->(Eof()) .And. WorkEF3->EF3_CODEVE = EV_EMBARQUE
               If WorkEF3->EF3_EV_VIN = EV_PRINC_PREPAG
                  MsgStop(STR0269, STR0098) //#"Periodicidade não pode ser alterada pois o contrato já possui vinculação." ##Atenção
                  lRet := .F.
                  Exit
               EndIf
               WorkEF3->(dbSkip())
            EndDo
         EndIf
         WorkEF3->(dbSetOrder(ORDEM_BROWSE))
         If lRet
            //If M->EF1_PARCPR # 0 .And. M->EF1_PARCJR # 0 .And. M->EF1_CAREPR # 0 .And. M->EF1_CAREJR # 0 //FSM - 08/03/2012
               EX401Recalc()
            //EndIf
         EndIf
         WorkEF3->(dbGoTop())
*/
            EX401Recalc()
         oMark:oBrowse:Refresh()
      EndIf

   Case cCampo == "EF1_PERIJR"
      If !Empty(M->EF1_DT_JUR)
/*         WorkEF3->(dbSetOrder(2)) // MPG - 16/01/2018 - Validação removida porque não faz sentido, onde mesmo que com vinculação a rotina deve permitir alterar os tempos e recalcular os saldos
         //Verifica se existe vinculação.
         If WorkEF3->(dbSeek(EV_EMBARQUE))
            Do While ! WorkEF3->(Eof()) .And. WorkEF3->EF3_CODEVE = EV_EMBARQUE
               If WorkEF3->EF3_EV_VIN = EV_JUROS_PREPAG
                  MsgStop(STR0249) //"Carência não pode ser alterada pois o contrato já possui vinculação."
                  lRet := .F.
                  Exit
               EndIf
               WorkEF3->(dbSkip())
            EndDo
         EndIf
         WorkEF3->(dbSetOrder(ORDEM_BROWSE))
         If lRet
            //If M->EF1_PARCPR # 0 .And. M->EF1_PARCJR # 0 .And. M->EF1_CAREPR # 0 .And. M->EF1_CAREJR # 0 //FSM - 08/03/2012
               EX401Recalc()
            //EndIf
         EndIf
         WorkEF3->(dbGoTop())
*/
         EX401Recalc()
         oMark:oBrowse:Refresh()
      EndIf
   // ** FSM

   Case cCampo == "EF1_CAREPR"
      If !Empty(M->EF1_DT_JUR)
/*         WorkEF3->(dbSetOrder(2)) // MPG - 16/01/2018 - Validação removida porque não faz sentido, onde mesmo que com vinculação a rotina deve permitir alterar os tempos e recalcular os saldos
         //Verifica se existe vinculação.
         If WorkEF3->(dbSeek(EV_EMBARQUE))
            Do While ! WorkEF3->(Eof()) .And. WorkEF3->EF3_CODEVE = EV_EMBARQUE
               If WorkEF3->EF3_EV_VIN = EV_PRINC_PREPAG
                  MsgStop(STR0249) //"Carência não pode ser alterada pois o contrato já possui vinculação."
                  lRet := .F.
                  Exit
               EndIf
               WorkEF3->(dbSkip())
            EndDo
         EndIf
         WorkEF3->(dbSetOrder(ORDEM_BROWSE))
         If lRet
            //If M->EF1_PARCPR # 0 .And. M->EF1_PARCJR # 0 .And. M->EF1_PERIPR # 0 .And. M->EF1_PERIJR # 0 //FSM - 08/03/2012
               EX401Recalc()
            //EndIf
         EndIf
         WorkEF3->(dbGoTop())
*/
            EX401Recalc()
         oMark:oBrowse:Refresh()
      EndIf

   Case cCampo == "EF1_CAREJR"
      If !Empty(M->EF1_DT_JUR)
/*         WorkEF3->(dbSetOrder(2)) // MPG - 16/01/2018 - Validação removida porque não faz sentido, onde mesmo que com vinculação a rotina deve permitir alterar os tempos e recalcular os saldos
         //Verifica se existe vinculação.
         If WorkEF3->(dbSeek(EV_EMBARQUE))
            Do While ! WorkEF3->(Eof()) .And. WorkEF3->EF3_CODEVE = EV_EMBARQUE
               If WorkEF3->EF3_EV_VIN = EV_JUROS_PREPAG
                  MsgStop(STR0249) //"Carência não pode ser alterada pois o contrato já possui vinculação."
                  lRet := .F.
                  Exit
               EndIf
               WorkEF3->(dbSkip())
            EndDo
         EndIf
         WorkEF3->(dbSetOrder(ORDEM_BROWSE))
         If lRet
            //If M->EF1_PARCPR # 0 .And. M->EF1_PARCJR # 0 .And. M->EF1_PERIPR # 0 .And. M->EF1_PERIJR # 0 //FSM - 08/03/2012
               EX401Recalc()
            //EndIf
         EndIf
         WorkEF3->(dbGoTop())
*/
          EX401Recalc()
         oMark:oBrowse:Refresh()
      EndIf

   Case cCampo == "EF1_PARCPR"
      If !Empty(M->EF1_DT_JUR)
         WorkEF3->(dbSetOrder(2))
         //Verifica se existe vinculação.
         // ** PLB 26/10/06 - Validação para Importação
         If cMod == IMP
            If WorkEF3->( DBSeek(EV_PRINC_PREPAG) )
               Do While !WorkEF3->( EoF() )  .And.  WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG
                  If WorkEF3->EF3_TX_MOE > 0
                     nParcAux += 1
                     nNotCalc += WorkEF3->EF3_VL_MOE
                  EndIf
                  WorkEF3->( DBSkip() )
               EndDo
            EndIf
         // **
         Else
            If WorkEF3->(dbSeek(EV_EMBARQUE))
               Do While ! WorkEF3->( EoF() ) .And. WorkEF3->EF3_CODEVE = EV_EMBARQUE
                  If WorkEF3->EF3_EV_VIN = EV_PRINC_PREPAG .And. Val(WorkEF3->EF3_PARVIN) > nParcAux
                     nParcAux := Val(WorkEF3->EF3_PARVIN)
                  EndIf
                  WorkEF3->(dbSkip())
               EndDo
            EndIf
            // ** PLB 26/10/06 - Soma os valores das parcelas com vinculação
            If nParcAux > 0   .And.   WorkEF3->( DBSeek(EV_PRINC_PREPAG) )
               Do While !WorkEF3->( EoF() )  .And.  WorkEF3->EF3_CODEVE = EV_PRINC_PREPAG
                  If Val(WorkEF3->EF3_PARC) <= nParcAux  // Não colocar no laço pois a Work não ordena por parcela
                     nNotCalc += WorkEF3->EF3_VL_MOE
                  EndIf
                  WorkEF3->(dbSkip())
               EndDo
            EndIf
            // **
         EndIf
         WorkEF3->(dbSetOrder(ORDEM_BROWSE))

         // ** PLB 26/10/06 - Caso todas as parcelas estiverem comprometidas (vinculadas ou liquidadas)
         If nNotCalc == M->EF1_VL_MOE
            MsgStop(EX401STR(0154))  //"Quantidade de Parcelas não pode ser alterada pois todas as Parcelas já foram vinculadas e/ou liquidadas."
            lRet := .F.
         ElseIf nParcAux == M->EF1_PARCPR
            MsgStop(EX401STR(0155)+AllTrim(Str(nParcAux)))  //"Quantidade de Parcelas não pode ser igual à quantidade de parcelas já vinculadas e/ou liquidadas: " ###
            lRet := .F.
         // **
         ElseIf nParcAux > M->EF1_PARCPR
            MsgStop(STR0250+Alltrim(Str(nParcAux))) //"Quantidade de Parcelas não pode ser inferior a quantidade de parcelas já vinculadas e/ou liquidadas: "
            lRet := .F.
         Else
            //If M->EF1_PARCPR # 0 .And. M->EF1_PARCJR # 0 .And. M->EF1_PERIPR # 0 .And. M->EF1_PERIJR # 0 //FSM - 08/03/2012
               EX401Recalc(nParcAux,nNotCalc)  // PLB 26/10/06 - Inclusão dos parametros
            //EndIf
         EndIf
         WorkEF3->(dbGoTop())
         oMark:oBrowse:Refresh()
      EndIf

   Case cCampo == "EF1_PARCJR"
      If !Empty(M->EF1_DT_JUR)
         WorkEF3->(dbSetOrder(2))
         //Verifica se existe vinculação.
         // ** PLB 26/10/06 - Validação para Importação
         If cMod == IMP
            If WorkEF3->( DBSeek(EV_JUROS_PREPAG) )
               Do While !WorkEF3->( EoF() )  .And.  WorkEF3->EF3_CODEVE == EV_JUROS_PREPAG
                  If WorkEF3->EF3_TX_MOE > 0
                     nParcAux  += 1
                  EndIf
                  WorkEF3->( DBSkip() )
               EndDo
            EndIf
         // **
         Else
            /*If WorkEF3->(dbSeek(EV_EMBARQUE))
               Do While ! WorkEF3->(Eof()) .And. WorkEF3->EF3_CODEVE = EV_EMBARQUE
                  If WorkEF3->EF3_EV_VIN = EV_JUROS_PREPAG .And. Val(WorkEF3->EF3_PARVIN) > nParcAux
                     nParcAux := Val(WorkEF3->EF3_PARVIN)
                  EndIf
                  WorkEF3->(dbSkip())
               EndDo
            EndIf*/
            // ** PLB 26/10/06 - Verifica tanto os Juros com vinculação quanto os Juros liquidados sem vinculação
            If WorkEF3->( DBSeek(EV_JUROS_PREPAG) )
               Do While !WorkEF3->( EoF() )  .And.  WorkEF3->EF3_CODEVE == EV_JUROS_PREPAG
                  If WorkEF3->( EF3_TX_MOE > 0  .Or.  ( EF3_SLDVIN != EF3_VL_MOE ) )
                     nParcAux += 1
                  EndIf
                  WorkEF3->( DBSkip() )
               EndDo
            EndIf
            // **
         EndIf
         WorkEF3->(dbSetOrder(ORDEM_BROWSE))

         If nParcAux > M->EF1_PARCJR
            MsgStop(STR0250+Alltrim(Str(nParcAux))) //"Quantidade de Parcelas não pode ser inferior a quantidade de parcelas já vinculadas e/ou liquidadas: "
            lRet := .F.
         Else
            //If M->EF1_PARCPR # 0 .And. M->EF1_PARCJR # 0 .And. M->EF1_PERIPR # 0 .And. M->EF1_PERIJR # 0 //FSM - 08/03/2012
               EX401Recalc()
            //EndIf
         EndIf
         WorkEF3->(dbGoTop())
         oMark:oBrowse:Refresh()
      EndIf

   Case cCampo == "EF1_ROF"
      If lEFFTpMod .AND. lCadFin .AND. !Empty(M->EF1_ROF)
         If !EF9->( dbSetOrder(1), ExistCpo("EF9",M->EF1_ROF) )
            lRet := .F.
         ElseIf EF9->( dbSeek(xFilial("EF9")+M->EF1_ROF) )
            If EF9->EF9_TP_ROF <> cMod
               MsgStop(STR0261+If(cMod==EXP,STR0262,STR0263))//"Selecione um ROF de "###"Exportação"###"Importação"
               lRet := .F.
            EndIf
         EndIf
      EndIf

      If lRet .AND. lCadFin .AND. lEFFTpMod

         Begin Sequence

         nPos := aScan(aHeader,{|X| X[2] == "EF8_TP_REL"})
         If Len(aCols) > 0 .AND. aScan(aCols,{|X| X[nPos] == "R"}) > 0
            If MsgYesNo(EX401STR(65),EX401STR(54))  //"Deseja atualizar os encargos para esse ROF?" ## "Encargos"
               //Exclui os engarcos com tipo "R"
               //aEval(aCols,{|X,Y| If(X[nPos] == "R",Eval({|Z| aDel(aCols,Z),aSize(aCols,Len(aCols)-1)},Y),)})

                  //Exclui os engarcos com tipo "F"
                  aDelEnca:= {}
                  aEval(aCols,{|X,Y| If(X[nPos] == "R",aAdd(aDelEnca,Y),)})

                  aEval(aDelEnca,{|X,Y| aDel(aCols,X+1-Y)})

                  aSize(aCols,Len(aCols)-Len(aDelEnca))
                  aDelEnca:= {}

               If (nPos:=aScan(aAlterados,{|x| x[1]=="EF8" .and. x[2]="EF1_ROF"})) > 0
                  aAlterados[nPos,4] := M->EF1_ROF
               Else
                  aAdd(aAlterados,{"EF8","EF1_ROF",cROFAtual,M->EF1_ROF,;
                  , , , , , })
               EndIf

            Else
               BREAK
            EndIf
         EndIf

         If !Empty(M->EF1_ROF)

            EF8->( dbSetOrder(1) )
            EF8->(dbSeek(cFilEF8+"R"+AvKey(M->EF1_ROF,"EF8_CHAVE")))
            Do While EF8->( EF8_FILIAL+EF8_TP_REL+EF8_CHAVE ) == cFilEF8+"R"+AvKey(M->EF1_ROF,"EF8_CHAVE")
               If EF8->EF8_CARGA == "1"
                  //aAdd(aCols,Array(Len(aHeader)+2))

                  //AAF 27/10/2008 - Inclusão com tratamento de linha em branco.
                  Eval(oGetMS:oBrowse:bAdd)

                  nPos := Len(aCols)
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEVE"})] := EF8->EF8_CODEVE
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEVE"})] := Eval(bDescEve,EF8->EF8_CODEVE)//EF8->EF8_DESEVE
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEAS"})] := EF8->EF8_CODEAS
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEAS"})] := Eval(bDescEve,EF8->EF8_CODEAS)//EF8->EF8_DESEAS
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEBA"})] := EF8->EF8_CODEBA
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEBA"})] := Eval(bDescEve,EF8->EF8_CODEBA)//EF8->EF8_DESEBA
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_TIP_EV"})] := EF8->EF8_TIP_EV
                  If EF8->EF8_TP_REL == "R" .and. EF8->EF8_TIP_EVE == "1"
                     aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_VL_PCT"})] := EX400Conv(EF9->EF9_MOEDA,M->EF1_MOEDA,EF8->EF8_VL_PCT)
                  Else
                     aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_VL_PCT"})] := EF8->EF8_VL_PCT
                  EndIf
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_PCT_RJ"})] := EF8->EF8_PCT_RJ
                  aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_LIQ"   })] := EF8->EF8_LIQ
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_TP_REL"})] := "R"

                  If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
                    aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_FORN"})] := EF8->EF8_FORN
                    aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_LOJA"})] := EF8->EF8_LOJA
                  EndIf

                  aCols[nPos,Len(aHeader)]           := 0
                  aCols[nPos,Len(aHeader)+1]           := .F.
               EndIf
               EF8->( dbSkip() )
            EndDo

            Eval(oGetMS:oBrowse:bAdd)
         EndIf

         oGetMS:oBrowse:Refresh()

         End Sequence

      EndIf

   Case cCampo == "EF1_LINCRE"
      If lEFFTpMod .AND. lCadFin
         If !Empty(M->EF1_LINCRE)
            If !EFA->( dbSetOrder(1), ExistCpo("EFA",M->EF1_LINCRE) )
               lRet := .F.
            EndIf
         Else
            // ** PLB 07/10/06
            If M->EF1_CAMTRA == "1"  .And.  cMod == IMP  .And.  !Empty(M->EF1_DT_JUR)
               MsgStop(EX401STR(141),STR0094)  //"Linha de Crédito não pode ser alterada pois o contrato já possui Parcelas de Pagamento." ## "Aviso"
               lRet := .F.
            EndIf
            // **
         EndIf

         //ER - 06/12/2006
         If lRet .And. !Empty(M->EF1_LINCRE)
            EFA->(DbSetOrder(1))
            If EFA->(DbSeek(xFilial("EFA")+M->EF1_LINCRE))
               If EFA->EFA_CREDOR <> M->EF1_PREPAG   ;
                  .Or.  EFA->(EFA_CLIENT+EFA_LOJCLI) != M->(EF1_CLIENT+EF1_CLLOJA)  ;  // PLB 22/03/07
                  .Or.  EFA->(EFA_FORN+EFA_LOJFOR) != M->(EF1_FORN+EF1_LOJAFO)         // PLB 22/03/07
                  If MsgYesNo(EX401STR(166),STR0098)//"O Credor da Linha de Crédito selecionada não é o mesmo do Contrato.Deseja atualizar o Credor do Contrato?"###"Atenção"
                     M->EF1_PREPAG := EFA->EFA_CREDOR
                     // ** PLB 22/03/07 - Atualiza informações sobre o credor
                     M->EF1_CLIENT := EFA->EFA_CLIENT
                     M->EF1_CLLOJA := EFA->EFA_LOJCLI
                     M->EF1_FORN   := EFA->EFA_FORN
                     M->EF1_LOJAFO := EFA->EFA_LOJFOR
                     // **
                  Else
                     lRet := .F.
                  EndIf
               EndIf
            EndIf
         EndIf
      EndIf

      If lRet

         Begin Sequence

         nPos := aScan(aHeader,{|X| X[2] == "EF8_TP_REL"})
         If Len(aCols) > 0 .AND. aScan(aCols,{|X| X[nPos] == "L"}) > 0
            If MsgYesNo(EX401STR(66),EX401STR(54)) //"Deseja atualizar os encargos para essa Linha de Crédito?" ## "Encargos"
               //Exclui os engarcos com tipo "R"

                  aDelEnca:= {}
                  aEval(aCols,{|X,Y| If(X[nPos] == "L",aAdd(aDelEnca,Y),)})

                  aEval(aDelEnca,{|X,Y| aDel(aCols,X+1-Y)})

                  aSize(aCols,Len(aCols)-Len(aDelEnca))
                  aDelEnca:= {}

               If (nPos:=aScan(aAlterados,{|x| x[1]=="EF8" .and. x[2]="EF1_LINCRE"})) > 0
                  aAlterados[nPos,4] := M->EF1_LINCRE
               Else
                  aAdd(aAlterados,{"EF8","EF1_LINCRE",cLinCredit,M->EF1_LINCRE,;
                  , , , , , })
               EndIf

            Else
               BREAK
            EndIf
         EndIf

         If !Empty(M->EF1_LINCRE)

            EF8->( dbSetOrder(1) )
            EF8->(dbSeek(cFilEF8+"L"+AvKey(M->EF1_LINCRE,"EF8_CHAVE")))
            Do While EF8->( EF8_FILIAL+EF8_TP_REL+EF8_CHAVE ) == cFilEF8+"L"+AvKey(M->EF1_LINCRE,"EF8_CHAVE")
               If EF8->EF8_CARGA == "1"
                  /*
                  If Len(aCols) <> 1 .Or. !Empty(GdFieldGet("EF8_CODEVE", 1))//Não adiciona linha caso o aCols possuir apenas uma linha em branco
                     aAdd(aCols,Array(Len(aHeader)+2))
                  EndIf
                  */

                  //AAF 27/10/2008 - Inclusão com tratamento de linha em branco.
                  Eval(oGetMS:oBrowse:bAdd)

                  nPos := Len(aCols)
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEVE"})] := EF8->EF8_CODEVE
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEVE"})] := Eval(bDescEve,EF8->EF8_CODEVE)//EF8->EF8_DESEVE
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEAS"})] := EF8->EF8_CODEAS
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEAS"})] := Eval(bDescEve,EF8->EF8_CODEAS)//EF8->EF8_DESEAS
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_CODEBA"})] := EF8->EF8_CODEBA
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_DESEBA"})] := Eval(bDescEve,EF8->EF8_CODEBA)//EF8->EF8_DESEBA
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_TIP_EV"})] := EF8->EF8_TIP_EV
                  If EF8->EF8_TP_REL == "L" .and. EF8->EF8_TIP_EVE == "1"
                     aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_VL_PCT"})] := EX400Conv(EFA->EFA_MOEDA,M->EF1_MOEDA,EF8->EF8_VL_PCT)
                  ElseIf EF8->EF8_TP_REL == "R" .and. EF8->EF8_TIP_EVE == "1" .and. EF8->(dbSeek(xFilial("EF8")+M->EF1_ROF))
                     aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_VL_PCT"})] := EX400Conv(EF9->EF9_MOEDA,M->EF1_MOEDA,EF8->EF8_VL_PCT)
                  Else
                     aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_VL_PCT"})] := EF8->EF8_VL_PCT
                  EndIf
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_PCT_RJ"})] := EF8->EF8_PCT_RJ
                  aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_LIQ"   })] := EF8->EF8_LIQ
                  //aCols[nPos,GdFieldPos("EF8_CARGA")] := EF8->EF8_CARGA //ASK
                  aCols[nPos,aScan(aHeader,{|X| X[2] == "EF8_TP_REL"})] := "L"

                  If AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix
                     aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_FORN"})] := EF8->EF8_FORN
                     aCols[nPos,aScan(aHeader,{|X| AllTrim(X[2]) == "EF8_LOJA"})] := EF8->EF8_LOJA
                  EndIf

                  aCols[nPos,Len(aHeader)]           := 0
                  aCols[nPos,Len(aHeader)+1]           := .F.
               EndIf
               EF8->( dbSkip() )
            EndDo

            Eval(oGetMS:oBrowse:bAdd)
         EndIf

         oGetMS:oBrowse:Refresh()

         End Sequence

      EndIf

   Case cCampo == "CINVS"
      If !Empty(M->EF1_DT_JUR)
         MsgStop(EX401STR(64)) //"Não podem ser feitas novas vinculações neste contrato pois a data de inicio dos juros já está preenchida."
         lRet := .F.
      EndIf


   // ** PLB 26/10/06
   Case cCampo == "EF1_CLIENT"
      If !Empty(M->EF1_CLIENT)
         lRet := ExistCpo("SA1",M->EF1_CLIENT)
         // ** PLB 22/03/07 - Validacao do Credor da Linha de Credito e do Credor do Contrato
         If lRet  .And.  lEFFTpMod  .And.  lCadFin  .And.  !Empty(M->EF1_LINCRE)
            EFA->(DbSetOrder(1))
            If EFA->(DbSeek(xFilial("EFA")+M->EF1_LINCRE))
               If EFA->EFA_CLIENT != M->EF1_CLIENT
                  MsgInfo(EX401STR(167),STR0098)//"O Credor do Contrato deve ser o mesmo Credor da Linha de Crédito"###"Atenção"
                  lRet := .F.
               EndIf
            EndIf
         EndIf
         If lRet  .And.  ( Empty(M->EF1_CLLOJA)  .Or.  SA1->( DBSetOrder(1), !DBSeek( xFilial("SA1")+M->( EF1_CLIENT+EF1_CLLOJA ) ) ) )
            M->EF1_CLLOJA := Posicione("SA1",1,xFilial("SA1")+M->EF1_CLIENT,"A1_LOJA")
         EndIf
         // **
      Else
         M->EF1_CLLOJA := Space(Len(M->EF1_CLLOJA))
      EndIf

   Case cCampo == "EF1_CLLOJA"
      If Empty(M->EF1_CLIENT)
         If !Empty(M->EF1_CLLOJA)
            MsgInfo(EX401STR(0172)+AllTrim(AvSX3("EF1_CLIENT",AV_TITULO)),STR0098)  //"Preencha o campo" ### "Atenção"
            lRet := .F.
         EndIf
      Else
         lRet := ExistCpo("SA1",M->EF1_CLIENT+M->EF1_CLLOJA)
         // ** PLB 22/03/07 - Validacao do Credor da Linha de Credito e do Credor do Contrato
         If lRet  .And.  lEFFTpMod  .And.  lCadFin  .And.  !Empty(M->EF1_LINCRE)
            EFA->(DbSetOrder(1))
            If EFA->(DbSeek(xFilial("EFA")+M->EF1_LINCRE))
               If EFA->(EFA_CLIENT+EFA_LOJCLI) != M->(EF1_CLIENT+EF1_CLLOJA)
                  MsgInfo(EX401STR(167),STR0098)//"O Credor do Contrato deve ser o mesmo Credor da Linha de Crédito"###"Atenção"
                  lRet := .F.
               EndIf
            EndIf
         EndIf
         // **
      EndIf

   Case cCampo == "EF1_FORN"
      If !Empty(M->EF1_FORN)
         lRet := ExistCpo("SA2",M->EF1_FORN)
         // ** PLB 22/03/07 - Validacao do Credor da Linha de Credito e do Credor do Contrato
         If lRet  .And.  lEFFTpMod  .And.  lCadFin  .And.  !Empty(M->EF1_LINCRE)
            EFA->(DbSetOrder(1))
            If EFA->(DbSeek(xFilial("EFA")+M->EF1_LINCRE))
               If EFA->EFA_FORN != M->EF1_FORN
                  MsgInfo(EX401STR(167),STR0098)//"O Credor do Contrato deve ser o mesmo Credor da Linha de Crédito"###"Atenção"
                  lRet := .F.
               EndIf
            EndIf
         EndIf
         If lRet  .And.  ( Empty(M->EF1_LOJAFO)  .Or.  SA2->( DBSetOrder(1), !DBSeek( xFilial("SA2")+M->( EF1_FORN+EF1_LOJAFO ) ) ) )
            M->EF1_LOJAFO := Posicione("SA2",1,xFilial("SA2")+M->EF1_FORN,"A2_LOJA")
         EndIf
         // **
      Else
         M->EF1_LOJAFO := Space(Len(M->EF1_LOJAFO))
      EndIf

   Case cCampo == "EF1_LOJAFO"
      If Empty(M->EF1_FORN)
         If !Empty(M->EF1_LOJAFO)
            MsgInfo(EX401STR(0172)+AllTrim(AvSX3("EF1_FORN",AV_TITULO)),STR0098)  //"Preencha o campo" ### "Atenção"
            lRet := .F.
         EndIf
      Else
         lRet := ExistCpo("SA2",M->EF1_FORN+M->EF1_LOJAFO)
         // ** PLB 22/03/07 - Validacao do Credor da Linha de Credito e do Credor do Contrato
         If lRet  .And.  lEFFTpMod  .And.  lCadFin  .And.  !Empty(M->EF1_LINCRE)
            EFA->(DbSetOrder(1))
            If EFA->(DbSeek(xFilial("EFA")+M->EF1_LINCRE))
               If EFA->(EFA_FORN+EFA_LOJFOR) != M->(EF1_FORN+EF1_LOJAFO)
                  MsgInfo(EX401STR(167),STR0098)//"O Credor do Contrato deve ser o mesmo Credor da Linha de Crédito"###"Atenção"
                  lRet := .F.
               EndIf
            EndIf
         EndIf
         // **
      EndIf

   Case cCampo == "EF1_PREPAG"

      //ER - 06/12/2006
      If !Empty(M->EF1_PREPAG)
         If lRet  .And.  lEFFTpMod  .And.  lCadFin  .And.  !Empty(M->EF1_LINCRE)
            EFA->(DbSetOrder(1))
            If EFA->(DbSeek(xFilial("EFA")+M->EF1_LINCRE))
               If EFA->EFA_CREDOR <> M->EF1_PREPAG
                  MsgInfo(EX401STR(167),STR0098)//"O Credor do Contrato deve ser o mesmo Credor da Linha de Crédito"###"Atenção"
                  lRet := .F.
               EndIf
            EndIf
         EndIf
      EndIf

      If M->EF1_PREPAG != "2" .And. lRet   // Cliente
         If !Empty(M->EF1_CLIENT)  .Or.  !Empty(M->EF1_CLLOJA)
            MsgInfo(EX401STR(0152)+AllTrim(AVSX3("EF1_CLIENT",5))+" e "+AllTrim(AVSX3("EF1_CLLOJA",5))+EX401STR(0153))  //"Para alterar o Credor é necessário que os campos " ### " não estejam preenchidos."
            lRet:= .F.
         EndIf
      ElseIf M->EF1_PREPAG != "3" .And. lRet  // Fornecedor
         If !Empty(M->EF1_FORN)  .Or.  !Empty(M->EF1_LOJAFO)
            MsgInfo(EX401STR(0152)+AllTrim(AVSX3("EF1_FORN",5))+" e "+AllTrim(AVSX3("EF1_LOJAFO",5))+EX401STR(0153))  //"Para alterar o Credor é necessário que os campos " ### " não estejam preenchidos."
            lRet:= .F.
         EndIf
      EndIf

   // **

   // ** PLB 30/10/06 - Valida botão 'marca todas' na vinculação de invoices ao contrato de financiamento
   Case cCampo == "MARCA_INVOICES"
      If Len(aMEDif) > 0
         lRet := MsgYesNo(EX401STR(0157))  //"Existem Invoices com Moeda diferente da Moeda do Contrato. Deseja continuar a marcação?"
         If lRet
            cMsg := EX401STR(0158)+DToC(dDataGeral)+":"  //"As Invoices que possuem Moeda diferente da Moeda do Contrato serão vinculadas com as taxas de conversão de acordo com as cotações do dia " ###
            cMsg += CHR(13)+CHR(10)+CHR(13)+CHR(10)
            cMsg += "MOEDA  TAXA"+CHR(13)+CHR(10)
            For i := 1  to  Len(aMEDif)
               cMsg += aMEDif[i]+"        "+AllTrim(Transform(BuscaTaxa(aMEDif[i],dDataGeral,,.F.,.T.,,cTX_100),AVSX3("EF1_VL_MOE",AV_PICTURE)))+CHR(13)+CHR(10)
            Next i
            cMsg += CHR(13)+CHR(10)+EX401STR(0159)  //"Deseja especificar outras taxas de conversão para moedas diferentes?"
            lAltTx := MsgYesNo(cMsg)
         EndIf
      EndIf
   // **

   // ** PLB 05/01/07
   Case cCampo == "EF1_MODPAG"
      If !Empty(M->EF1_MODPAG)
         If cMod == EXP
            If ( lRet := ExistCpo("EEF",M->EF1_MODPAG) )
               M->EF1_MDPDES := Posicione("EEF",1,xFilial("EEF")+M->EF1_MODPAG,"EEF_DESC")
            EndIf
         Else
            If ( lRet := ExistCpo("SJ6",AvKey(M->EF1_MODPAG,"J6_COD")) )
               M->EF1_MDPDES := Posicione("SJ6",1,xFilial("SJ6")+AvKey(M->EF1_MODPAG,"J6_COD"),"J6_DESC")
            EndIf
         EndIf
      Else
         M->EF1_MDPDES := ""
      EndIf
   // **

  Case cCampo == "LIQ_PERIODO"
     If WorkEF2->(EasyRecCount() ) <= 0
        Help("", 1, "ARQVAZIO")
        lRet := .F.
     ElseIf EX401PELiq()
        MsgStop(EX401STR(0178),STR0094)  //"Juros do Período já foram gerados." , "Atenção"
        lRet := .F.
     ElseIf EX401PEInv()
        MsgStop(EX401STR(0179),STR0094)  //"Não é possível gerar Juros de um Período referente a uma Invoice específica." , "Atenção"
        lRet := .F.
     ElseIf !MsgYesNo(EX401STR(0182))  //"Deseja gerar Juros referente a este Período do Contrato?"
        lRet := .F.
     EndIf

   Case cCampo == "EF1_DTCRED" .And. !Empty(M->EF1_DTCRED) .And. EXWhen("EF1_DT_JUR")//FSY - 17/02/2014 - Ajuste para bloquear a alteração do campo EF1_DT_JUR e o EF3_DT_EVE se conter evento 600
      M->EF1_DT_JUR := DaySum( M->EF1_DTCRED , 1 )
      If EX400Valid("EF1_DT_JUR")
         WorkEF3->(dbSetOrder(2))
         If WorkEF3->(dbSeek(EV_PRINC))
            WorkEF3->EF3_DT_EVE := M->EF1_DTCRED
            If Type("oMark") == "O"
               oMark:oBrowse:Refresh()
            End If
         EndIf
      Else
         lRet := .F.
      EndIf
   Case cCampo == "BX_ENCERRAMENTO"
      If (WorkEF3->(FieldPos("EF3_DTOREV")) > 0 .And. !Empty(WorkEF3->EF3_DTOREV)) .Or. ( WorkEF3->EF3_VL_REA <> 0 .and. WorkEF3->EF3_TX_MOE <> 0 )
         MsgStop("Saldo de encerramento já foi liquidado.")
         lRet := .F.
      EndIf

   Case cCampo == "EF3_FORN"
      If ExistCpo("SA2",M->EF3_FORN)
         M->EF3_LOJAFO := SA2->A2_LOJA
      Else
         M->EF3_LOJAFO := ""
         lRet := .F.
      EndIf

EndCase

If lRet .AND. (AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix)
   lRet := oEFFContrato:ValidaCampo(cNomeCampo)
EndIf

If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"EX400Valid"),)

WorkEF3->(dbGoTo(nWorkEF3Rec))
oMark:oBrowse:Refresh()

If WorkEF3->(Eof()) .Or. WorkEF3->(Bof())
   WorkEF3->(dbgotop())
   oMark:oBrowse:Refresh()
EndIf
Return lRet

*--------------------------------*
Function EXWhen(cNomeCampo)
*--------------------------------*
Local nOrd , nRec
Private lRet:=.T., cCampo:=If(cNomeCampo=NIL,"",cNomeCampo)

Do Case
   Case cCampo == "EF1_DT_JUR"
      nOrd := WorkEF3->(IndexOrd())  //JWJ 05/02/07: Não permitir digitar dt de juros se houver evento 600
      nRec := WorkEF3->(Recno())
      WorkEF3->(DBSETORDER(2))
      lRet := IF(cMod == EXP, !WorkEF3->(DBSEEK("600")), .T.)
      WorkEF3->(DBSETORDER(nOrd))
      WorkEF3->(DBGoto(nRec))

      //If cMod == EXP .AND. M->EF1_DT_JUR <> M->EF1_DT_CTB .AND. !lRet
      // PLB 13/06/07
      If !lRet  .And.  cMod == EXP .AND. !Empty(M->EF1_DT_CTB)  .And.  lIsContab
         lRet := .F.
      EndIf
   Case cCampo == "EF1_MOEDA"
      nRec := WorkEF3->( RecNo() )
      WorkEF3->(dbGoTop())
      lRet := (WorkEF3->( BoF() ) .AND. WorkEF3->( EoF() ))
      WorkEF3->( DBGoTo(nRec) )
   Case cCampo == "EF1_CONTRA"
      If nOpcSel <> INCLUIR
         lRet := .F.
      End If
   Case cCampo == "EF1_CAMTRA"
      // ** AAF 09/03/06
      //If M->EF1_TP_FIN <> ACE
      //   lRet := .F.
      //EndIf
      // **
      nRec := WorkEF3->( RecNo() )
      nOrd := WorkEF3->( IndexOrd() )
      WorkEF3->( dbSetOrder(2) )
      If cMod == IMP// .AND. !(WorkEF3->( BoF() ) .AND. WorkEF3->( EoF() ))
         lRet := .F.
      ElseIf WorkEF3->(dbSeek(EV_EMBARQUE))
         lRet := .F.
      EndIf
      WorkEF3->( dbSetOrder(nOrd) )
      WorkEF3->( DBGoTo(nRec) )
//   Case cCampo == "EF1_LIQFIX"     //PLB 17/02/06 - Campo EF1_LIQFIX excluido do Dicionario
//      If M->EF1_CAMTRA <> "1" //<> Sim
//         lRet := .F.
//      EndIf
     If EF7->(FieldPos('EF7_FINPRC')) > 0 .And. POSICIONE('EF7',1,xFilial('EF7')+M->EF1_TP_FIN,'EF7_FINPRC') == '2'  //NCF - 10/10/2014
         lRet := .F.
     EndIf

   Case cCampo == "EF1_DT_ENC"
      /*If M->EF1_SLD_PM > 0 .and. Empty(M->EF1_DT_ENC)  // ** GFC - Comentado pois agora será feito através de validação
         lRet := .F.
      EndIf*/
   Case cCampo == "EF1_JR_ANT"
      If M->EF1_TP_FIN == "03" .or. M->EF1_TP_FIN == "04" .or. If(lEF1_LIQPER,M->EF1_LIQPER=="1",.F.)
         lRet := .F.
      EndIf
   Case cCampo == "EF1_LIQPER"
      If M->EF1_TP_FIN == "03" .or. M->EF1_TP_FIN == "04" .or. If(lEF1_JR_ANT,M->EF1_JR_ANT=="1",.F.)
         lRet := .F.
      EndIf
   Case cCampo == "EF2_TIPJUR"
      If nTpManut == ALTERAR
         lRet := .F.
      EndIf
   Case cCampo == "EF2_DT_INI"
      If !Empty(M->EF2_DT_INI)  .And.  !Empty(M->EF1_DT_CTB)  .And.  lIsContab  .And.  M->EF1_DT_CTB >= M->EF2_DT_INI
         lRet := .F.
      EndIf
   Case cCampo == "EF2_TX_FIX"
      If (!AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix) .And. !Empty(M->EF1_DT_CTB)  .And.  lIsContab  .And.  M->EF1_DT_CTB >= M->EF2_DT_INI  .And. ;
         M->EF1_DT_CTB <= M->EF2_DT_FIM
         lRet := .F.
      EndIf
   Case cCampo == "EF2_TX_VAR"
      If (!AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix) .And. !Empty(M->EF1_DT_CTB)  .And.  lIsContab  .And.  M->EF1_DT_CTB >= M->EF2_DT_INI  .And.  M->EF1_DT_CTB <= M->EF2_DT_FIM
         lRet := .F.
      EndIf
   Case cCampo == "EF2_TP_FIN"
      If M->EF1_TP_FIN <> ACC
         M->EF2_TP_FIN := M->EF1_TP_FIN
         lRet := .F.
      ElseIf nTpManut == ALTERAR
         lRet := .F.
      EndIf
   Case cCampo == "EF3_CODEVE"
      If nOpAux == 4  .Or.  nOpAux == 6
         lRet := .F.
      EndIf
   Case cCampo == "EF3_CTA_DB"
      If !Empty(M->EF3_DT_CTB)
         lRet := .F.
      EndIf
   Case cCampo == "EF3_CTA_CR"
      If !Empty(M->EF3_DT_CTB)
         lRet := .F.
      EndIf

   // ** GFC - Pré-Pagamento/Securitização
   /** AAF - 10/03/06 - When do campo de acordo com EF1_PREPAG.
   Case cCampo == "EF1_CLIENT"
      If (M->EF1_TP_FIN <> "03" .and. M->EF1_TP_FIN <> "04") .or. M->EF1_PREPAG <> "2"
         lRet := .F.
      EndIf
   Case cCampo == "EF1_CLLOJA"
      If (M->EF1_TP_FIN <> "03" .and. M->EF1_TP_FIN <> "04") .or. M->EF1_PREPAG <> "2"
         lRet := .F.
      EndIf
   **/
   // **

EndCase

Return lRet

*---------------------------------------------------*
Function EX400EVManut(nOpca,cVisual,lEstorBL)
*---------------------------------------------------*
Local oDlg, nSelecao:=0, bOk1:={||nSelecao:=1,oDlg:End()}, cAltera:="", nDif:=0
Local nRecAux, cParcAux, oEnCh //LRL 03/06/04
Local aGetsAux:={}, aTelaAux:={}, nPos, cSeq, nOldRec, i, nInd, aOrdRef := {}
Local nOldOrd:=WorkEF3->(IndexOrd()), nOldOpc:=nOpca //Guarda a Opção devido a problema no Estorno de Itens(Work)
Local cCodEve := ""
Local nRec_WorkEF3 := 1 //ISS - 09/02/11 - Variável usada para guardar o recno da WorkEF3.
Local lDesabIntg := .F.
Local dDataCt := CToD("  /  /  ") //MCF - 26/07/2016
Local nTxCt := 0
Default lEstorBL := .F. //LRL 18/03/05 Caso .T. Fara o Estorno da Baixa da Liquidação
Private nRec:=WorkEF3->EF3_RECNO, cTit:=STR0048, nOpAux:=nOpca //"Manutenção de Eventos "
Private aFiliais := If(lMultiFil,AvgSelectFil(.F.),{xFilial("EEQ")})
Private aVisual:={} //passou a ser private para ser utilizada em rdmake
Private nRWEF3 := 0, nDiferenca := 0 //FSM - 22/03/2012
Private lSair := .F.  // GFP - 25/09/2014
If(cVisual<>NIL, cVisual, cVisual:= "")

lEvCont := .T.  // PLB 14/06/06 - Utilizada no F3 do Tipo de Modulo para os Eventos Contabeis

If nOpca = 6
   nOpca   := INCLUIR
   nOldOpc := INCLUIR
EndIf
aGetsAux := aClone(aGets)
aTelaAux := aClone(aTela)

If lRefinimp  // GFP - 09/10/2015
   aOrdRef := SaveOrd("EF3")
   If nOpca == ALTERAR .OR. nOpca == EXCLUIR
      If WorkEF3->ALTERADO
         Help(" ",1,"EFF0000003")  //"Existem vinculações de contratos para refinanciamento pendentes de gravação." ## "É necessário salvar as alterações deste contrato antes de prosseguir."
         Return
      Else
         EF3->(DbSetOrder(10))  //"EF3_FILIAL+EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR+EF3_CODEVE"
         If EF3->(DbSeek(xFilial("EF3")+WorkEF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVIMP+EF3_LINHA)))
            Help(" ",1,"EFF0000005")  //"Não é possivel efetuar manutenção neste evento, pois o mesmo possui vinculação de contratos para refinanciamento." ## "É necessário efetuar o estorno da vinculação do contrato de refinanciamento para prosseguir com a manutenção."
            RestOrd(aOrdRef,.T.)
            Return
         EndIf
      EndIf
   EndIf
   RestOrd(aOrdRef,.T.)
EndIf

// MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
If WorkEF3->( fieldpos("ALTERADO") ) > 0 .and. WorkEF3->ALTERADO
      msgstop(STR0289,STR0094) //"Existem alterações nessa parcela pendentes de gravação, salve o contrato primeiro para depois executar a ação desejada.","Aviso"
      Return .T.
endif

Do While .T.

   If EC6->(dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. M->EF1_TPMODU <> IMP,"FIEX","FIIM")+M->EF1_TP_FIN+WorkEF3->EF3_CODEVE))
      lDesabIntg := EC6->(FieldPos("EC6_DESINT")) > 0 .And. EC6->EC6_DESINT == '1'
   EndIf

   lRetContr := .T.
   // ** AAF 24/07/05 - Eventos de V.C. e Provisão de Juros não podem ser alterados.
   If  nOpca == ALTERAR  .Or.  nOpca == ESTORNAR
      If WorkEF3->EF3_CODEVE == EV_PRINC .And. EF1->(FieldPos("EF1_TX_MOE")) > 0 //MCF - 18/12/2015 - Acrescentado validação FieldPos
         WorkEF3->( dbSetOrder(5) )
         If WorkEF3->( dbSeek(EV_EMBARQUE) )
            MsgStop(EX401STR(67)) //"Não são permitidas alterações neste evento."
            WorkEF3->( dbSeek(EV_PRINC) )
            EXIT
         EndIf
         WorkEF3->( dbSeek(EV_PRINC) )
      //ElseIf WorkEF3->EF3_CODEVE $ "100/500/501" .OR. Left(WorkEF3->EF3_CODEVE,2) $ "51/52/55/56"

      // AAF 25/05/2015 - Permitir as exclusões. Caso esteja contabilizado, será automaticamente gerado evento de estorno.
      ElseIf nOpca == ALTERAR .AND. (WorkEF3->EF3_CODEVE $ "100" .OR. Left(WorkEF3->EF3_CODEVE,2) $ "50/51/52/55/56") .And. EF1->(FieldPos("EF1_TX_MOE")) > 0 //MCF - 18/12/2015 - Acrescentado validação FieldPos
         MsgStop(EX401STR(67)) //"Não são permitidas alterações neste evento."
         EXIT
      EndIf
      //FSM - 23/03/2012
      If !( Left(WorkEF3->EF3_CODEVE,2) $ "60/63" ).And. WorkEF3->EF3_CODEVE >= "300" .And. WorkEF3->EF3_CODEVE <= "799" .And. !(WorkEF3->EF3_CODEVE $ "500/501") .And. (WorkEF3->EF3_CODEVE $ "620" .And. !lDesabIntg)
         If !Empty(WorkEF3->EF3_TX_MOE)
            MsgInfo("Este encargo "+"já foi amortizado.",STR0094)  //# ##"Atenção"
            EXIT
         EndIf
      EndIf
   EndIf
   // **

   dbSelectArea("WorkEF3")
   RegToMemory("EF3",.T.,.T.)
   If lRefinimp
      M->ALTERADO := CriaVar("W4_DECIMAL")  // GFP - 17/02/2016 - Necessário criação de variavel de memoria lógica
   EndIf
   If nOpca <> INCLUIR
      If WorkEF3->(EasyRecCount()) <= 0
         Help("", 1, "ARQVAZIO")
         lEvCont := .F.  // PLB 14/06/06 - Utilizada no F3 do Tipo de Modulo para os Eventos Contabeis
         Return .T.
      EndIf
      cTit+=Alltrim(WorkEF3->EF3_CODEVE)

      FOR i := 1 TO FCount()
         M->&(FIELDNAME(i)) := FieldGet(i)
      NEXT i
      // ** PLB 19/12/06 - Carrega descrição do evento caso inicializador Padrão não tenha encontrado evento
      If Empty(M->EF3_DESCEV)  .And.  Left(M->EF3_CODEVE,2) $ EVENTOS_DE_JUROS  // (510,520,550,640,650,670)
         If Left(M->EF3_CODEVE,2) == Left(EV_VC_PJ1,2)  .And.  ( Val(M->EF3_CODEVE) % 2 ) != 0   // 550  .And.  Impar
            cCodEve := Left(M->EF3_CODEVE,2)+"1"
         Else
            cCodEve := Left(M->EF3_CODEVE,2)+"0"
         EndIf
         M->EF3_DESCEV := EX400DescEv("M", "M", cCodEve)
      EndIf
      // **
   Else
      lIncluiAux := .T.
      dbSelectArea("EF3")
      FOR nInd := 1 TO FCount()
         M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
      NEXT
      M->EF3_RECNO := 0
   EndIf

   aGets:={}
   aTela:={}

   If nOpca == ALTERAR .And. !Empty(WorkEF3->EF3_NR_CON)
      // Nao Permite alterar eventos ja contabilizados
      Help(" ",1,"AVG0005289") //MsgInfo(STR0090)  // "Evento não pode ser alterado, já possui contabilizações !!!"
      EX400EVManut(2,"S")
      WorkEF3->(dbGoTop())
      Exit
   Endif

   If !lEFFTpMod .OR. WorkEF3->EF3_ORIGEM == "EEQ"//M->EF1_TPMODU == EXP
      aVisual := {"EF3_CODEVE", "EF3_DESCEV", "EF3_INVOIC", "EF3_PREEMB", "EF3_VL_MOE", "EF3_TX_MOE",;
                  "EF3_VL_REA", "EF3_DT_EVE" , "EF3_NR_CON", "EF3_DT_EST", "EF3_EV_EST", "EF3_DT_FIX",;
                  "EF3_TX_CON", "EF3_MOE_IN" , "EF3_VL_INV", "EF3_DT_CIN", "EF3_GERECO", "EF3_CTA_DB",;
                  "EF3_CTA_CR", "EF3_BANC"   , "EF3_AGEN"  , "EF3_NCON"  , "EF3_NROP"  , "EF3_EV_VIN",;
                  "EF3_PARVIN", "EF3_SLDVIN" , "EF3_RELACA", "EF3_FORN"   , "EF3_LOJAFO"}  // GFP - 20/01/2012
   ElseIf WorkEF3->EF3_ORIGEM == "SWB" //M->EF1_TPMODU == IMP
      aVisual := {"EF3_CODEVE", "EF3_DESCEV", "EF3_INVIMP", "EF3_HAWB"  , "EF3_PO_DI" ,"EF3_VL_MOE" ,;
                  "EF3_TX_MOE", "EF3_FORN"   , "EF3_LOJAFO", "EF3_LINHA" , "EF3_ORIGEM",;
                  "EF3_VL_REA", "EF3_DT_EVE" , "EF3_NR_CON", "EF3_DT_EST", "EF3_EV_EST", "EF3_DT_FIX",;
                  "EF3_TX_CON", "EF3_MOE_IN" , "EF3_VL_INV", "EF3_DT_CIN", "EF3_GERECO", "EF3_CTA_DB",;
                  "EF3_CTA_CR", "EF3_BANC"   , "EF3_AGEN"  , "EF3_NCON"  , "EF3_NROP"  , "EF3_EV_VIN",;
                  "EF3_PARVIN", "EF3_SLDVIN" }
   Else
      aVisual := {"EF3_CODEVE", "EF3_DESCEV", "EF3_VL_MOE", "EF3_TX_MOE", "EF3_VL_REA", "EF3_DT_EVE",;
                  "EF3_NR_CON", "EF3_DT_EST" , "EF3_EV_EST", "EF3_DT_FIX", "EF3_TX_CON", "EF3_GERECO",;
                  "EF3_CTA_DB", "EF3_CTA_CR" , "EF3_BANC"  , "EF3_AGEN"  , "EF3_NCON"  , "EF3_NROP"  ,;
                  "EF3_EV_VIN", "EF3_PARVIN" , "EF3_SLDVIN", "EF3_RELACA","EF3_FORN"   , "EF3_LOJAFO" } // GFP - 20/01/2012
   EndIf

   If nOpca == VISUALIZAR
      EF3->(dbGoTo(nRec))
      If nRec = 0
         nRec := WorkEF3->(Recno())
      Endif
      If AmIin(31) .And. cModulo == "ECO"
         cVisual := "S"
         aVisual := {"EF3_CODEVE", "EF3_DESCEV", "EF3_INVOIC", "EF3_PREEMB", "EF3_VL_MOE", "EF3_TX_MOE",;
                     "EF3_VL_REA", "EF3_DT_EVE" , "EF3_NR_CON", "EF3_DT_EST", "EF3_EV_EST", "EF3_DT_FIX",;
                     "EF3_TX_CON", "EF3_MOE_IN" , "EF3_VL_INV", "EF3_DT_CIN", "EF3_GERECO", "EF3_CTA_DB",;
                     "EF3_CTA_CR", "EF3_BANC"   , "EF3_AGEN"  , "EF3_NCON"}
      Else
         nOpca   := ALTERAR
         cVisual := "S"
      EndIf
   ElseIf nOpca = ESTORNAR
      nOpca   := ALTERAR
   EndIf

   lSair := .F.  // GFP - 25/09/2014
   If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"BROWSE_EF3"),)
   If lSair  // GFP - 25/09/2014
      Return .F.
   EndIf

   DEFINE MSDIALOG oDlg TITLE cTit ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL

      nLinha :=(oDlg:nClientHeight-4)/2

      //ISS - 09/02/11 - Necessário guarda o recno da workEF3 pois a mesma será desposicionada pelo seek seguinte.
      nRec_WorkEF3 := WorkEF3->(RecNo())

      // AAF - 28/07/04 - No modulo 31 - Contabil, não existe opção 4 - Alterar no aRotina.
      If nModulo <> 30
         nOpca:= 2
      EndIf

      // PLB 03/08/06 - Nao exibe Taxa da Moeda e Valor em Reais na alteracao de eventos 700 e 71? nao liquidados
      //If WorkEF3->EF3_TX_MOE == 0  .And.  ( WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG  .Or.  Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2) )
      // SVG - 06/01/2011 -  Inclusão dos campos apenas para contratos de exp , eventos 100 e sem vinculação
      If /*(M->EF1_TPMODU != EXP .And. WorkEF3->(DBSEEK("600"))) .Or. */WorkEF3->EF3_CODEVE <> EV_PRINC //MCF - 13/01/2016
         If ( nPos := AScan( aVisual, { |x| x == "EF3_TX_MOE" } ) ) > 0
            ADel( aVisual, nPos )
            ASize( aVisual , Len(aVisual)-1 )
         EndIf
         If ( nPos := AScan( aVisual, { |x| x == "EF3_VL_REA" } ) ) > 0
            ADel( aVisual, nPos )
            ASize( aVisual , Len(aVisual)-1 )
         EndIf
      EndIf

      oEnCh:=MsMGet():New( "EF3",nRec,nOpca,,,,aVisual,{15,1,nLinha,COLUNA_FINAL},If(nOldOpc=ESTORNAR .Or. nOldOpc=VISUALIZAR,{},),3,,,,,,.T.) //NCF - 16/04/2018 - Usar Var.Memória na edição

      If nOpAux = 6
         M->EF3_CODEVE := EV_LIQ_PRC
         M->EF3_DESCEV := EX400DescEv("M", "M", M->EF3_CODEVE)
      EndIf
      oDlg:lMaximized:=.T. //LRL 03/06/04 - Maximiliza Janela

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||If((nOldOpc=ESTORNAR .or. nOpca=VISUALIZAR .or. !Empty(cVisual) .or. Obrigatorio(aGets,aTela)) .and. EX400Valid("GRV_EVE") ,Eval(bOk1),)},{||nSelecao:=0,oDlg:End()}),;
                                   oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT) //LRL 03/06/04 - Alinhamento MDi

   nOpca := nOldOpc
   If nSelecao = 1
      dbSelectArea("WorkEF3")

      //ISS - 09/02/11 - Reposicionando o registro da WorkEF3, assim evitando o uso da mesma quando ela estiver em EOF.
      WorkEF3->(DbGoTo(nRec_WorkEF3))

      //FSM - 20/03/2012
      nRWEF3 := nRec_WorkEF3
      nDiferenca := M->EF3_DT_EVE - WorkEF3->EF3_DT_EVE

      If nOpca=INCLUIR .or. nOpca=ALTERAR
         WorkEF3->(RecLock("WorkEF3",If(nOpca=INCLUIR,.T.,.F.)))
         FOR i := 1 TO FCount()
            if !(UPPER(WorkEF3->(FIELDNAME(i))) $ "EF3_RECNO/TRB_ALI_WT/TRB_REC_WT")   //Alcir Alves - 21-06-05
               If nOpca=ALTERAR .and. WorkEF3->&(FIELDNAME(i)) <> M->&(FIELDNAME(i))
                  If (nPos:=aScan(aAlterados,{|x| x[2]==FIELDNAME(i) .and. x[5]=WorkEF3->EF3_RECNO})) >0
                     aAlterados[nPos,4] := M->&(FIELDNAME(i))
                  Else
                     aAdd(aAlterados,{"EF3",FIELDNAME(i),WorkEF3->&(FIELDNAME(i)),M->&(FIELDNAME(i)),;
                     WorkEF3->EF3_RECNO,WorkEF3->EF3_PREEMB,WorkEF3->EF3_INVOIC,WorkEF3->EF3_PARC,;
                     WorkEF3->EF3_CODEVE,WorkEF3->EF3_SEQ})
                  EndIf
                  // ** PLB 04/08/06 - Atualiza saldo caso haja alteração no valor em reais das parcelas de pagamento
                  If FieldName(i) == "EF3_VL_REA"  .And.  IIF(lEFFTpMod,M->EF1_CAMTRA == "1",lPrePag  .And.  M->EF1_TP_FIN $ "03/04") ;
                     .And.  ( M->EF3_CODEVE == EV_PRINC_PREPAG  .Or.  Left(M->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2) )

                     If M->EF3_CODEVE == EV_PRINC_PREPAG
                        M->EF1_LIQPRR -= WorkEF3->&(FieldName(i))
                        M->EF1_LIQPRR += M->&(FieldName(i))

                     ElseIf Left(M->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)
                        M->EF1_LIQJRR -= WorkEF3->&(FieldName(i))
                        M->EF1_LIQJRR += M->&(FieldName(i))
                     EndIf

                  EndIf
                  // **
                  If FieldName(i) == "EF3_DT_EVE" .and. Empty(cAltera)
                     cAltera := FieldName(i)
                  ElseIf FieldName(i) == "EF3_VL_MOE"
                     cAltera := FieldName(i)
                     nDif := WorkEF3->EF3_VL_MOE - M->EF3_VL_MOE
                  EndIf
               EndIf
               WorkEF3->&(FIELDNAME(i)) := If(  IsMemVar(  "M->"+(WorkEF3->(FieldName(i)))  ) ,  M->&(FIELDNAME(i)) , WorkEF3->&(FIELDNAME(i)) )   //NCF - 04/02/2019 - Previne erro para campo não criados em var. memória
               If FieldName(i) == "ALTERADO" .And. aScan(aAlterados,{|x| x[5] == WorkEF3->EF3_RECNO }) > 0
                  WorkEF3->ALTERADO := .T.
               EndIf
            endif //Alcir Alves - 21-06-05
         NEXT i
         If lIncluiAux
            If (Empty(M->EF3_INVOIC) .and. !(WorkEF3->EF3_CODEVE==EV_PRINC_PREPAG .or.;
            Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)))  .AND.;
            !(WorkEF3->EF3_CODEVE >= "301" .and. WorkEF3->EF3_CODEVE <= "499")  // GFP - 12/11/2014
               WorkEF3->EF3_SEQ := "0001"
            Else
               WorkEF3->EF3_SEQ := BuscaEF3Seq()
            EndIf
            If lPrePag .AND. M->EF1_CAMTRA == "1" .and. (WorkEF3->EF3_CODEVE==EV_PRINC_PREPAG .or.; //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
            Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2))
               nRecAux := WorkEF3->(RecNo())
               WorkEF3->(dbSetOrder(2))
               If WorkEF3->(AvSeekLast(WorkEF3->EF3_CODEVE+Space(Len(WorkEF3->EF3_INVOIC))))
                  cParcAux := StrZero(Val(WorkEF3->EF3_PARC)+1,AvSX3("EF3_PARC",3))
               Else
                  cParcAux := StrZero(1,AvSX3("EF3_PARC",3))
               EndIf
               WorkEF3->(dbGoTo(nRecAux))
               WorkEF3->EF3_PARC := cParcAux
            EndIf
            If lACCACE .and. WorkEF3->EF3_CODEVE $(EV_EMBARQUE+"/"+EV_LIQ_PRC)
               Processa({|| GeraEventos(WorkEF3->EF3_CODEVE)}  ,STR0049) //"Gerando Eventos..."
            ElseIf WorkEF3->EF3_CODEVE == EV_P_COM_FIN
               Processa({|| EX400VCCom()}  ,STR0172) //"Gerando Variação Cambial da comissão..."
            EndIf
         Else
            // ** GFC - Pré-Pagamento/Securitização
            If lPrePag  .And.  !Empty(cAltera)  .And.  ;
               (WorkEF3->EF3_CODEVE==EV_PRINC_PREPAG .Or. Left(WorkEF3->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))
               If cAltera == "EF3_DT_EVE"
                  Processa({|| EX401Recalc() } ,STR0215) //"Recalculando parcelas de juros..."
               ElseIf cAltera == "EF3_VL_MOE"
                  If WorkEF3->EF3_CODEVE==EV_PRINC_PREPAG
                     EXParcPrePag(nDif)
                  ElseIf WorkEF3->EF3_CODEVE==EV_JUROS_PREPAG
                     ExGerEvAlJur(nDif)
                  EndIf
               EndIf
               cAltera := ""
               nDif := 0
            EndIf
            // **
         EndIf
         // Grava a Data de Contabilização conforme a Taxa do Inicio de Juros
         If WorkEF3->EF3_CODEVE = EV_PRINC .And. Empty(WorkEF3->EF3_NR_CON)
            //M->EF1_TX_CTB := WorkEF3->EF3_TX_MOE
            // Atualiza os Saldos
            M->EF1_SLD_PR := WorkEF3->EF3_VL_REA
         Endif

         If nOpca=INCLUIR
            WorkEF3->TRB_ALI_WT := "EF3"
            WorkEF3->TRB_REC_WT := 0
            // FSM - 29/02/2012
            WorkEF3->EF3_MOE_IN := M->EF1_MOEDA
         EndIf
         //FSM - 28/03/2012
         WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)
         
         WorkEF3->(MSUnlock())

         If nOpca==INCLUIR  .And.  lCadFin
            EX401GrEncargos("WorkEF3")
         EndIf
      ElseIf nOpca=ESTORNAR
         SWB->( DBSetOrder(1) )
         EEQ->( DBSetOrder(1) )
         If !(WorkEF3->EF3_CODEVE==EV_ESTORNO .and. !Empty(WorkEF3->EF3_NR_CON)) .and.;
         MsgYesNo(STR0050) .and. If(!Empty(WorkEF3->EF3_NR_CON),MsgYesNo(STR0104),.T.) ;//"Deseja Realmente Excluir este Evento?" # "ATENÇÃO! Evento já contabilizado. Confirma exclusão?"
         .And. IIF(WorkEF3->EF3_CODEVE==EV_EMBARQUE,IIF(lEFFTpMod .And. WorkEF3->EF3_ORIGEM == "SWB",IIF(SWB->( DBSeek(IIF(lMultiFil,WorkEF3->EF3_FILORI,xFilial("SWB"))+WorkEF3->EF3_HAWB+WorkEF3->EF3_PO_DI+WorkEF3->EF3_INVIMP+WorkEF3->EF3_FORN+WorkEF3->EF3_LOJAFO+WorkEF3->EF3_LINHA) ),SoftLock("SWB"),.T.),IIF(EEQ->( DBSeek(IIF(lMultiFil,WorkEF3->EF3_FILORI,cFilEEQ)+WorkEF3->EF3_PREEMB+WorkEF3->EF3_PARC) ),SoftLock("EEQ"),.T.)),.T.)  // PLB 24/07/06 - Tratamento Multi-Usuario //AAF 25/09/07 - Tratar multifiliais
            If WorkEF3->EF3_CODEVE == EV_LIQ_PRC .or. WorkEF3->EF3_CODEVE == EV_EMBARQUE .or.;
            WorkEF3->EF3_CODEVE == EV_LIQ_PRC_FC .or.;
            ( Left(WorkEF3->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2)); // ** GFC - 01/09/05 - Incluído o EV_LIQ_JUR (640) para casos de pré-pagamento
            .OR. (lPrePag .AND. (WorkEF3->EF3_CODEVE == EV_ENC_PRC .OR. WorkEF3->EF3_CODEVE == EV_TRANS_PRC));//AAF 07/11/05 - Encerramento/Transferência de Contrato.
            .OR. ( Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUR_CNT,2) .And. lDesabIntg )
               EX400EstEV(WorkEF3->EF3_SEQ)
               If (M->EF3_CODEVE == EV_LIQ_PRC .or. M->EF3_CODEVE == EV_LIQ_PRC_FC) .And. dDataBase > M->EF3_DT_EVE .and.;
               !Empty(WorkEF3->EF3_NR_CON)// Gera V.C refentes ao periodo em que houve liquidaçao
                  GeraEventos(EV_ESTORNO)
               Endif
            Else
               nOldRec:=WorkEF3->(RecNo())
               If WorkEF3->EF3_CODEVE == EV_VC_PRC .or. WorkEF3->EF3_CODEVE == EV_VC_PRC1 .or.;
               (Val(WorkEF3->EF3_CODEVE)>=Val(EV_VC_PJ1) .and. Val(WorkEF3->EF3_CODEVE)<=Val(EV_VC_PJ2)) .or.;
               Left(WorkEF3->EF3_CODEVE,2) $ (Left(EV_LIQ_JUR,2)+"/"+Left(EV_LIQ_JUR_FC,2)+"/"+Left(EV_PJ,2)+;
                                              "/"+Left(EV_EST_PJ,2)+"/"+Left(EV_TJ,2))+"/"+Left(EV_JR_ANT,2)
                  cSeq := WorkEF3->EF3_SEQ
                  WorkEF3->(dbSetOrder(1))
                  If Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JR_ANT,2)
                     WorkEF3->(dbGoTo(nOldRec))
                     EX400AtuSaldos("ANT","M","WorkEF3","EFF")
                  ElseIf WorkEF3->(dbSeek(cSeq+EV_EMBARQUE))
                     WorkEF3->(dbGoTo(nOldRec))
                     EX400AtuSaldos("VIN","M","WorkEF3","EFF")
                  ElseIf WorkEF3->(dbSeek(cSeq+EV_LIQ_PRC)) .or. WorkEF3->(dbSeek(cSeq+EV_LIQ_PRC_FC))
                     WorkEF3->(dbGoTo(nOldRec))
                     EX400AtuSaldos("LIQ","M","WorkEF3","EFF")
                  Else
                     WorkEF3->(dbGoTo(nOldRec))
                  EndIf
               EndIf
               cSeqEvAtu := WorkEF3->EF3_SEQ      //NCF - 09/01/2014
               WorkEF3->(RecLock("WorkEF3",.F.))
               If !Empty(WorkEF3->EF3_NR_CON)
                  aAdd(aDelWkEF3,WorkEF3->(RecNo()))
                  WorkEF3->EF3_EV_EST := WorkEF3->EF3_CODEVE //WorkEF3->(DBDELETE())
                  WorkEF3->EF3_DT_EST := dDataBase //AAF 24/07/05 - Grava a Data do Evento Estornado.
                  WorkEF3->EF3_CODEVE := EV_ESTORNO
                  WorkEF3->EF3_NR_CON := Space(Len(WorkEF3->EF3_NR_CON))
               Else
                  aAdd(aDelEF3,WorkEF3->EF3_RECNO)
                  WorkEF3->(dbDelete())
               EndIf
               WorkEF3->(MSUnlock())
               EX400EstEV(cSeqEvAtu)              //NCF - 09/01/2014 - Para excluir eventos gerados na sequencia de contabilização
            EndIf

            If lEF3Ct
               WorkEF3->(DbGoTop()) //MCF - 26/07/2016
               While WorkEF3->(!EOF())
                  If WorkEF3->EF3_DT_CTB > dDataCt
                     dDataCt := WorkEF3->EF3_DT_CTB
                     nTxCt   := WorkEF3->EF3_TX_CTB
                  EndIf
                  WorkEF3->(DbSkip())
               EndDo

               If M->EF1_DT_CTB <> dDataCt
                  M->EF1_DT_ANT := M->EF1_DT_CTB
                  M->EF1_TX_ANT := M->EF1_TX_CTB
                  M->EF1_DT_CTB := dDataCt
                  M->EF1_TX_CTB := nTxCt
               EndIf
            EndIf
         Else
            lRetContr := .F.
         EndIf
      //LRL 18/03/05 - Estorno da baixa da Vinculação------------------------------------
      ElseIf nOpca = VISUALIZAR .And. lEstorBL .and. MsgYesNo(EX401STR(68)) //"Confirma estorno da baixa forçada?"
         EX401DelBxF()
      EndIf
      //------------------------------------LRL 18/03/05 - Estorno da baixa da Vinculação

      // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
      if WorkEF3->(!eof()) .and. WorkEF3->( fieldpos("ALTERADO") ) > 0
            reclock("WorkEF3",.F.)
            WorkEF3->ALTERADO := .T.
            WorkEF3->(msunlock())
      endif

   Else
      lRetContr := .F.
   EndIf

   If nOpca<>INCLUIR .or. nSelecao=0
      lIncluiAux := .F.
      //WorkEF3->(dbGoTop())
      Exit
   EndIf
   nSelecao := 0

EndDo

WorkEF3->(dbSetOrder(ORDEM_BROWSE))

aGets := aClone(aGetsAux)
aTela := aClone(aTelaAux)
nSelecao := 0
oMark:oBrowse:Refresh()

lEvCont := .F.  // PLB 14/06/06 - Utilizada no F3 do Tipo de Modulo para os Eventos Contabeis

//RMD - 04/10/17 - Atualiza os saldos do contrato
EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

Return .T.

*---------------------------*
Static Function EX400Filtro()
*---------------------------*
Local oCbxCamb, nOp:=0, cAliasOld := Alias(), nInd
Local cDBFilt1   := ""  ,;
      cDBFilt2   := ""  ,;
      lFound     := .F.     // PLB 25/10/06
Private aFiltro:={STR0051,STR0052,STR0088,"Eventos com valor e contábeis",EX401STR(0151)} //"Por Invoice e Evento" , "Por Invoice" , "Por Evento" , "Limpar Filtro"
Private cFiltro:="", lGetInv := .T., lGetPar := .T., lGetEve := .T.
Private cInvBrow := "", cInvParc := ""
If cMod == IMP
   cInvBrow := Space(Len(EF3->EF3_INVIMP))
   cInvParc := Space(Len(EF3->EF3_LINHA) )
Else
   cInvBrow := Space(Len(EF3->EF3_INVOIC))
   cInvParc := Space(Len(EF3->EF3_PARC)  )
EndIf

nInd := WorkEF3->(IndexOrd())

// Limpa Variaveis
cInv    := Space( Len(cInv)    )
cEvento := Space( Len(cEvento) )
cParc   := Space( Len(cParc)   )

DEFINE MSDIALOG oDlg TITLE STR0053 ; //"Seleção de Filtro para Eventos"
       FROM 12,05 TO 24,50 OF GetWndDefault()

   @03,02 SAY  STR0054 of oDlg //"Filtrar Eventos por"
   @03,08 ComboBox oCbxCamb Var cFiltro Items aFiltro SIZE 100,08 ON CHANGE EX400Valid("FILTROS") of oDlg
   @04,02 SAY   AVSX3("EF3_INVOIC",5) of oDlg
   @04,08 MSGET cInv F3 "E36"/*"EF3"*/ PICT AVSX3("EF3_INVOIC",6) WHEN lGetInv /*If(cFiltro <> aFiltro[2], .T., .F.)*/ VALID EX400Valid("FILTRO_INVOICE") SIZE 60,8
   @05,02 SAY   AVSX3("EF3_PARC",5) of oDlg
   @05,08 MSGET cParc PICT AVSX3("EF3_PARC",6) WHEN lGetPar /*If(cFiltro <> aFiltro[2] .And. !Empty(cInv), .T., .F.)*/ SIZE 60,8
   @06,02 SAY   AVSX3("EF3_CODEVE",5) of oDlg
   @06,08 MSGET cEvento F3 "ECZ" PICT AVSX3("EF3_CODEVE",6) WHEN lGetEve /*If(cFiltro == aFiltro[3], .T., .F.)*/ VALID EX400Valid("FILTRO_EVENTO") SIZE 60,8

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(EX400Valid("FILTRO_OK"),(nOp:=1,oDlg:End()),)},{||nOp:=0,oDlg:End()}) CENTERED

If nOp == 1
   DbSelectArea("WorkEF3")
   SET FILTER TO
   WorkEF3->(dbGoTop())
   /*
   If Empty(cInv)
      If cFiltro == aFiltro[1]    //Todos
         WorkEF3->(dbGoTop())
         oMark:oBrowse:Refresh()
      ElseIf cFiltro == aFiltro[2] //Invoice
         WorkEF3->(DBSETFILTER({||EF3_INVOIC==Space(Len(EF3->EF3_INVOIC))},"EF3_INVOIC=='"+Space(Len(EF3->EF3_INVOIC))+"'"))
      ElseIf cFiltro == aFiltro[3] .And. !Empty(cEvento) //Evento
         WorkEF3->(dbSetOrder(2))
         If WorkEF3->(dbSeek(cEvento))
            WorkEF3->(DBSETFILTER({||EF3_CODEVE==cEvento},"EF3_CODEVE=='"+cEvento+"'"))
         Else
            Msginfo(STR0097,STR0098) //"Não foi possível encontrar Registros com essas Especificações!"###"Atenção"
         Endif
      EndIf
      WorkEF3->(dbGoTop())
      oMark:oBrowse:Refresh()
   Else
      If cFiltro == aFiltro[3]
         If !Empty(cParc)
            WorkEF3->(dbSetOrder(6))
            If WorkEF3->(dbSeek(cInv+cParc+cEvento))
               WorkEF3->(DBSETFILTER(&("{||EF3_INVOIC=='"+cInv+"' .And. EF3_PARC == '"+cParc+"' .And. EF3_CODEVE=='"+cEvento+"'}"),"EF3_INVOIC=='"+cInv+"' .AND. EF3_PARC=='"+cParc+"' .AND. EF3_CODEVE=='"+cEvento+"'"))
            Else
               Msginfo(STR0097,STR0098) //"Não foi possível encontrar Registros com essas Especificações!"###"Atenção"
            Endif
         Else
            WorkEF3->(dbSetOrder(7))
            If WorkEF3->(dbSeek(cInv+cEvento))
               WorkEF3->(DBSETFILTER({||EF3_INVOIC==cInv .And. EF3_CODEVE==cEvento},"EF3_INVOIC=='"+cInv+"' .AND. EF3_CODEVE=='"+cEvento+"'"))
            Else
               Msginfo(STR0097,STR0098) //"Não foi possível encontrar Registros com essas Especificações!"###"Atenção"
            Endif
         Endif
      Else
         WorkEF3->(dbSetOrder(3))
         If !Empty(cParc)
            If WorkEF3->(dbSeek(cInv+cParc))
               WorkEF3->(DBSETFILTER(&("{||EF3_INVOIC=='"+cInv+"' .And. EF3_PARC == '"+cParc+"' }"),"EF3_INVOIC=='"+cInv+"' .AND. EF3_PARC=='"+cParc+"'"))
            Else
               Msginfo(STR0097,STR0098) //"Não foi possível encontrar Registros com essas Especificações!"###"Atenção"
            Endif
         Else
            If WorkEF3->(dbSeek(cInv))
               WorkEF3->(DBSETFILTER({||EF3_INVOIC==cInv },"EF3_INVOIC=='"+cInv+"'"))
            Else
               Msginfo(STR0097,STR0098) //"Não foi possível encontrar Registros com essas Especificações!"###"Atenção"
            Endif
         Endif
      Endif
      WorkEF3->(dbGoTop())
      oMark:oBrowse:Refresh()
   EndIf
   */
   // ** PLB 25/10/06
   If cFiltro == aFiltro[1]  // Por Invoice e Evento
      If cMod == IMP
         cDBFilt1 := "EF3_INVIMP == cInv"
         cDBFilt2 := "EF3_INVIMP =='"+cInv+"'"
      Else
         cDBFilt1 := "EF3_INVOIC == cInv"
         cDBFilt2 := "EF3_INVOIC =='"+cInv+"'"
      EndIf
      If !Empty(cParc)
         If cMod == IMP
            cDBFilt1 += " .And. EF3_LINHA == cParc"
            cDBFilt2 += " .And. EF3_LINHA =='"+cParc+"'"
         Else
            cDBFilt1 += " .And. EF3_PARC == cParc"
            cDBFilt2 += " .And. EF3_PARC =='"+cParc+"'"
         EndIf
      EndIf
      cDBFilt1 += " .And. EF3_CODEVE == cEvento"
      cDBFilt2 += " .And. EF3_CODEVE =='"+cEvento+"'"
      If cMod == IMP
         WorkEF3->( DBSetOrder(10) )
      Else
         WorkEF3->( DBSetOrder(6)  )
      EndIf
      If !Empty(cParc)
         lFound := WorkEF3->( DBSeek(cInv+cParc+cEvento) )
      ElseIf WorkEF3->( DBSeek(cInv) )
         Do While !WorkEF3->( EoF() )  .And.  WorkEF3->EF3_INVOIC == cInv
            If WorkEF3->EF3_CODEVE == cEvento
               lFound := .T.
               Exit
            EndIf
            WorkEF3->( DBSkip() )
         EndDo
      EndIf
   ElseIf cFiltro == aFiltro[2]  // Por Invoice
      If cMod == IMP
         cDBFilt1 := "EF3_INVIMP == cInv"
         cDBFilt2 := "EF3_INVIMP =='"+cInv+"'"
      Else
         cDBFilt1 := "EF3_INVOIC == cInv"
         cDBFilt2 := "EF3_INVOIC =='"+cInv+"'"
      EndIf
      If !Empty(cParc)
         If cMod == IMP
            cDBFilt1 += " .And. EF3_LINHA == cParc"
            cDBFilt2 += " .And. EF3_LINHA =='"+cParc+"'"
         Else
            cDBFilt1 += " .And. EF3_PARC == cParc"
            cDBFilt2 += " .And. EF3_PARC =='"+cParc+"'"
         EndIf
      EndIf
      If cMod == IMP
         WorkEF3->( DBSetOrder(10) )
      Else
         WorkEF3->( DBSetOrder(6)  )
      EndIf
      If !Empty(cParc)
         lFound := WorkEF3->( DBSeek(cInv+cParc) )
      Else
         lFound := WorkEF3->( DBSeek(cInv) )
      EndIf
   ElseIf cFiltro == aFiltro[3]  // Por Evento
      cDBFilt1 := "EF3_CODEVE == cEvento"
      cDBFilt2 := "EF3_CODEVE =='"+cEvento+"'"
      WorkEF3->( DBSetOrder(5) )
      lFound := WorkEF3->( DBSeek(cEvento) )
   ElseIf cFiltro == aFiltro[4]
      //cDBFilt1 := 'EF3_VL_MOE == 0 .And. EF3_VL_REA == 0 .And. Posicione( "EC6" , 1 , xFilial("EC6") +  If(EF3->EF3_TPMODU <> "I","FIEX","FIIM") + EF3->EF3_TP_EVE + AvKey(EF3->EF3_CODEVE,"EC6_ID_CAM") ,"EC6_CONTAB" ) == "2"'
      //cDBFilt1 := '(EF3_VL_MOE > 0 .And. EF3_VL_REA > 0) .Or. !EMPTY(EF3_TITFIN) .Or. (Posicione( "EC6" , 1 , xFilial("EC6") +  If(EF3_TPMODU <> "I","FIEX","FIIM") + EF3_TP_EVE + AvKey(EF3_CODEVE,"EC6_ID_CAM") ,"EC6_CONTAB" ) == "1" .And. EF3_VL_REA > 0)'
      //cDBFilt2 := '(EF3_VL_MOE > 0 .And. EF3_VL_REA > 0) .Or. !EMPTY(EF3_TITFIN) .Or. (Posicione( "EC6" , 1 , xFilial("EC6") +  If(EF3_TPMODU <> "I","FIEX","FIIM") + EF3_TP_EVE + AvKey(EF3_CODEVE,"EC6_ID_CAM") ,"EC6_CONTAB" ) == "1" .And. EF3_VL_REA > 0)'
	  cDBFilt1 := 'Left(EF3_CODEVE,1) $ "3/4" .OR. Left(EF3_CODEVE,2) $ "18/19/71/62/64/67" .OR. EF3_CODEVE $ "100/600/630/700/660" .Or. (Posicione( "EC6" , 1 , xFilial("EC6") +  If(EF3_TPMODU <> "I","FIEX","FIIM") + EF3_TP_EVE + AvKey(EF3_CODEVE,"EC6_ID_CAM") ,"EC6_CONTAB" ) == "1" .And. EF3_VL_REA > 0)'
	  cDBFilt2 := cDBFilt1
      lFound := .T.
   EndIf
   //Posicione( "EC6" , 1 , xFilial("EC6") +  If(EF3->EF3_TPMODU <> "I","FIEX","FIIM") + EF3->EF3_TP_EVE + AvKey(EF3->EF3_CODEVE,"EC6_ID_CAM") ,"EC6_CONTAB" )
   If lFound
      WorkEF3->( DBSetFilter({ || &cDBFilt1 },cDBFilt2) )
   ElseIf !Empty(cDBFilt1)
      MsgInfo(STR0097,STR0098) //"Não foi possível encontrar Registros com essas Especificações!" , "Atenção"
   EndIf
   // **
   DbSelectArea(cAliasOld)
//Else
//   SET FILTER TO
//   WorkEF3->(dbGoTop())
//   oMark:oBrowse:Refresh()
EndIf

WorkEF3->( DBSetOrder(ORDEM_BROWSE) )
WorkEF3->( DBGoTop() )
oMark:oBrowse:Refresh()

Return .T.

*----------------------------------*
Static Function EX400Periodos(nTipo)
*----------------------------------*
Local nSelecao, aBotoes2:={}, nOrd:=WorkEF3->(IndexOrd())
Local bBarOk2:={||nSelecao:=1,oDlg:End()}, bBarCanc2:={||nSelecao:=0,oDlg:End()}
Local nPos := 0
Private lModificado := .F. // FSM - 29/03/2012
Private oMark1
Private aFiliais := If(lMultiFil,AvgSelecTFil(.F.),{xFilial("EEQ")})

//LRL 06/04/06 - 4 parametro - Titulo para versão MDI , se não houver deve se passado como Nil
If nTipo <> VISUALIZAR .and. nTipo <> ESTORNAR
   aBotoes2 := { {"BMPVISUAL" /*"ANALITICO"*/,{|| EX400PEManut(2), SetKEY(15,bBarOk2), SetKEY(24,bBarCanc2) }, STR0003,STR0003/*STR0148*/} ,; //"Visualizar" - "Ver" //FSM - 04/09/2012
                 {"BMPINCLUIR" /*"EDIT"*/    , {|| EX400PEManut(3), SetKEY(15,bBarOk2), SetKEY(24,bBarCanc2) }, STR0055,STR0150} ,; //"Incluir Período" - "Incluir"
                 {"EDIT" /*"IC_17"*/   , {|| EX400PEManut(4), SetKEY(15,bBarOk2), SetKEY(24,bBarCanc2) }, STR0056,STR0149} ,; //"Alterar Período" - "Aletrar"
                 {"EXCLUIR" , {|| If(EX400Valid("EX_PERIODO"),EX400PEManut(5),), SetKEY(15,bBarOk2), SetKEY(24,bBarCanc2) }, STR0057,STR0151} } //"Excluir Período" - "Excluir"
   // ** PLB 28/05/07 - Botão para Liquidação de Juros por Período - É necessário que não exista qualquer liquidação automática de Juros
   If lLiqPeriodo  .And.  M->EF1_CAMTRA=="2"  .And.  M->EF1_JR_ANT=="2"  .And.  M->EF1_LIQPER == "2"
      AAdd( aBotoes2, {"RECALC" , {|| IIF(EX400Valid("LIQ_PERIODO"),EX401PEJur(),), SetKEY(15,bBarOk2), SetKEY(24,bBarCanc2) }, EX401STR(0176), EX401STR(0176)/*EX401STR(0177)*/ } )  //"Gerar Juros do Período" - //FSM - 04/09/2012 - "Ger.Jr.Per"
   EndIf
   // **
Else
   aBotoes2 := { {"BMPVISUAL" /*"ANALITICO"*/,{|| EX400PEManut(2), SetKEY(15,bBarOk2), SetKEY(24,bBarCanc2) }, STR0003,STR0148} } //"Visualizar"
EndIf

WorkEF2->(dbGoTop())

nSelecao:=0
DEFINE MSDIALOG oDlg TITLE STR0058 ; //"Manutenção de Períodos"
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
       OF oMainWnd PIXEL

   nLinha :=(oDlg:nClientHeight-4)/2


   // ** PLB 14/09/06
   // Verifica o Tipo de Financiamento para exibição do campo 'Vinc. Fatura?'
   aSelCpos2:= BrowseCpos("EF2","WorkEF2")
   If (nPos := AScan(aSelCpos2,{|x| AllTrim(x[3]) == AllTrim(AvSX3("EF2_USEINV",5)) } )) > 0
      If !IIF(lEFFTpMod,M->EF1_CAMTRA=="1" .And. cMod==EXP,lPrepag .And. M->EF1_TP_FIN$("03/04"))
         ADel(aSelCpos2,nPos)
         ASize(aSelCpos2,Len(aSelCpos2)-1)
      EndIf
   EndIf
   // Nao exibe o campo 'Bonificacao'
   If lEF1_DTBONI  .And.  (nPos := AScan(aSelCpos2,{ |x| AllTrim(x[3]) == AllTrim(AvSX3("EF2_BONUS",5)) }) ) > 0
      ADel(aSelCpos2,nPos)
      ASize(aSelCpos2,Len(aSelCpos2)-1)
   EndIf
   // **
   oMark1:= MsSelect():New("WorkEF2",,,aSelCpos2,@lInverte,@cMarca,{15,1,nLinha,COLUNA_FINAL})
   oMark1:oBrowse:bWhen:={|| DBSELECTAREA("WorkEF2"),.T.}
//   oMark1:bAval:={||AC400PEManut(4),WorkEF2->(dbGoTop()), SetKEY(15,bBarOk2), SetKEY(24,bBarCanc2) }

   oDlg:lMaximized:=.T. //LRL 03/06/04 - Maximiliza  Janela
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bBarOK2, bBarCanc2,, aBotoes2), oMark1:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT) CENTERED //FSM - 04/09/2012

// FSM - 29/03/2012
If lModificado .And. !Empty(M->EF1_DT_JUR)
   //Processa({|| EX401AltPrePag(,,"M","WorkEF3", .F.) } ,STR0215) //"Recalculando parcelas de juros..."
   Processa({|| EX401Recalc(,,.F.,.F.,.F.)} ,STR0215) //"Recalculando parcelas de juros..."
EndIf

WorkEF3->(dbSetOrder(ORDEM_BROWSE))

Return .T.

*---------------------------------*
Static Function EX400PEManut(nOpca)
*---------------------------------*
Local oDlg, nSelecao:=0, bOk1:={||nSelecao:=1,oDlg:End()}
Local oEnCh //LRL 03/06/04
Local aGetsAux:={}, aTelaAux:={}, nPos, i, nInd, nRecWork, nTxOld
Local nOldOrd:=WorkEF3->(IndexOrd()), nOldOpc:=nOpca //Guarda a Opção devido a problema no Estorno de Itens(Work)
Local nTxJrAnt
Private nRec:=WorkEF2->EF2_RECNO, cTit:=STR0059, nTpManut:=nOpca //"Manutenção de Períodos "

aGetsAux := aClone(aGets)
aTelaAux := aClone(aTela)

Do While .T.

   dbSelectArea("WorkEF2")
   If nOpca <> INCLUIR
      If WorkEF2->(EasyRecCount()) <= 0
         Help("", 1, "ARQVAZIO")
         Return .T.
      EndIf
      cTit+=DtoC(WorkEF2->EF2_DT_INI)+STR0060+DtoC(WorkEF2->EF2_DT_FIM) //" a "
      FOR i := 1 TO WorkEF2->( FCount() )
         M->&(WorkEF2->( FIELDNAME(i) )) := WorkEF2->(FieldGet(i))
      NEXT i
   Else
      lIncluiAux := .T.
      RegToMemory("EF2",.T.,.T.)
      //dbSelectArea("EF2")
      //FOR nInd := 1 TO FCount()
      //   M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
      //NEXT
      M->EF2_RECNO := 0
   EndIf

   aGets:={}
   aTela:={}

   If nOpca == VISUALIZAR
      EF2->(dbGoTo(nRec))
   ElseIf nOpca == ESTORNAR
      nOpca := ALTERAR
   EndIf

   DEFINE MSDIALOG oDlg TITLE cTit ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL

      nLinha :=(oDlg:nClientHeight-4)/2

      // ** AAF 10/03/06 - Campos Visiveis na Manutenção de Períodos.
      aCposEF2 := { "EF2_TP_FIN", "EF2_VM_FIN", "EF2_TIPJUR", "EF2_VM_JUR", "EF2_DT_INI", "EF2_DT_FIM",;
                    "EF2_TX_FIX", "EF2_TP_VAR", "EF2_DEC_VA", "EF2_TX_VAR", "EF2_TX_DIA"/*, "EF2_BONUS"*/ }  // PLB 14/09/06

      // ** PLB 17/08/06
      If IIF(lEFFTpMod,M->EF1_CAMTRA == "1",lPrepag .And. M->EF1_TP_FIN $ (PRE_PAGTO+"/"+SECURITIZACAO))
         If cMod == EXP
            aAdd(aCposEF2,"EF2_USEINV")
         EndIf
      Else
         If lMultiFil
            aAdd(aCposEF2,"EF2_FILORI")
         EndIf
         AAdd(aCposEF2,"EF2_INVOIC")
         AAdd(aCposEF2,"EF2_PARC"  )
      EndIf
      // **

      //If cMod == EXP  .And.  IIF(lEFFTpMod,M->EF1_CAMTRA == "1",.T.)
         //aAdd(aCposEF2,"EF2_USEINV")
      //EndIf
      // **

      // PLB 24/10/06 - 16º parametro força a exibição dos dados de memoria
      oEnCh:=MSMGet():New("EF2",nRec,nOpca,,,,aCposEF2,{15,1,nLinha,COLUNA_FINAL},If(nOldOpc=ESTORNAR,{},),3,,,,,,IIF(nOpca==VISUALIZAR,.T.,))

      oDlg:lMaximized:=.T. //LRL 03/06/04 - Maximiliza Janela
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||If(nOldOpc=ESTORNAR .or. nOpca=VISUALIZAR .or. (Obrigatorio(aGets,aTela) .and. EX401ValPer("OK",nOpca)) ,Eval(bOk1),)},{||nSelecao:=0,oDlg:End()}),;
                                   oEnCh:oBox:Align:=CONTROL_ALIGN_ALLCLIENT) //LRL 03/06/04 - ALinhamento MDI

   nOpca := nOldOpc
   If nSelecao = 1
      If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"OK_MANUT_PERIODO"),)
      dbSelectArea("WorkEF2")
      If nOpca=INCLUIR .or. nOpca=ALTERAR
         nTxOld := WorkEF2->EF2_TX_FIX
         WorkEF2->(RecLock("WorkEF2",If(nOpca=INCLUIR,.T.,.F.)))
         FOR i := 1 TO FCount()
            if !(upper(WorkEF2->(FIELDNAME(i))) $ "EF2_RECNO/TRB_ALI_WT/TRB_REC_WT")  //Alcir Alves - 21-06-05
               If WorkEF2->&(FIELDNAME(i)) <> M->&(FIELDNAME(i)) .and. nOpca=ALTERAR
                  If (nPos:=aScan(aAlterados,{|x| x[2]==FIELDNAME(i) .and. x[5]=WorkEF2->EF2_RECNO})) >0
                     aAlterados[nPos,4] := M->&(FIELDNAME(i))
                  Else
                     aAdd(aAlterados,{"EF2",FIELDNAME(i),WorkEF2->&(FIELDNAME(i)),M->&(FIELDNAME(i)),WorkEF2->EF2_RECNO,"","","","",""})
                  EndIf
                  If WorkEF2->(FieldName(i)) == "EF2_TX_DIA"
                     nRecWork := WorkEF2->(RecNo())
                     EX401AltTaxa("M","WorkEF2","WorkEF3",WorkEF2->EF2_INVOIC,WorkEF2->EF2_PARC,WorkEF2->EF2_DT_INI,WorkEF2->EF2_CONTRA,WorkEF2->EF2_BAN_FI,WorkEF2->EF2_PRACA,If(lEF2_TIPJUR,WorkEF2->EF2_TIPJUR,"0"),M->EF2_TX_FIX,nTxOld,nRecWork,If(lEFFTpMod,WorkEF2->EF2_TPMODU,),If(lEFFTpMod,WorkEF2->EF2_SEQCNT,))
                     WorkEF2->(dbGoTo(nRecWork))
                  EndIf
               EndIf
               //FSM - 29/03/2012
               If !(M->&(FIELDNAME(i)) == WorkEF2->&(FIELDNAME(i)))
                  lModificado := .T.
               EndIf

               WorkEF2->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
            endif
         NEXT i
         //ACSJ - 09/02/2005
         WorkEF2->EF2_CONTRA := M->EF1_CONTRA

         If lEFFTpMod
            WorkEF2->EF2_TPMODU := M->EF1_TPMODU
         EndIf

         if lTemChave
            WORKEF2->EF2_BAN_FI := M->EF1_BAN_FI
            WORKEF2->EF2_PRACA  := M->EF1_PRACA
            If lEFFTpMod
               WorkEF2->EF2_SEQCNT := M->EF1_SEQCNT
            EndIf
         Endif
         // -----------------
         // ** PLB 28/05/07
         If lLiqPeriodo  .And.  nOpca == INCLUIR
            If WorkEF2->( Empty(EF2_FILORI+EF2_INVOIC+EF2_PARC) )
               WorkEF2->EF2_SEQPER := BuscaEF2Seq()
            EndIf
         EndIf
         // **
         If nOpca=INCLUIR
            WorkEF2->TRB_ALI_WT := "EF2"
            WorkEF2->TRB_REC_WT := 0
         EndIf

         WorkEF2->(MSUnlock())

         // ** GFC - 08/11/05 - Juros Antecipados
         If nOpca=INCLUIR .and. lEF1_JR_ANT .and. !Inclui .and. M->EF1_JR_ANT == "1"
            nTxJrAnt := BuscaTaxa(M->EF1_MOEDA,WorkEF2->EF2_DT_INI,,.F.,.T.,,cTX_100)
            EX401GrvJA("M","WorkEF2","WorkEF3",WorkEF2->EF2_DT_INI,WorkEF2->EF2_DT_FIM,M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,nTxJrAnt,WorkEF2->EF2_DT_INI,If(lEF2_TIPJUR,{WorkEF2->EF2_TIPJUR},),If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
         EndIf
         // **

         // ** GFC - 16/11/05 - Liquidação por Períodos
         If nOpca=INCLUIR .and. lEF1_LIQPER .and. M->EF1_LIQPER == "1"
            EX401GrvLP("M","WorkEF2","WorkEF3",M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,WorkEF2->EF2_DT_INI,WorkEF2->EF2_DT_FIM,If(lEF2_TIPJUR,WorkEF2->EF2_TIPJUR,"0"),nOpca,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
         EndIf
         // **
      ElseIf nOpca=ESTORNAR
         If MsgYesNo(STR0050) //"Deseja Realmente Excluir este Evento?"
            // ** GFC - 16/11/05 - Liquidação por Períodos
            If lEF1_LIQPER .and. M->EF1_LIQPER == "1"
               EX401GrvLP("M","WorkEF2","WorkEF3",M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,WorkEF2->EF2_DT_INI,WorkEF2->EF2_DT_FIM,If(lEF2_TIPJUR,WorkEF2->EF2_TIPJUR,"0"),nOpca,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
            EndIf
            // **
            aAdd(aDelWkEF2,WorkEF2->EF2_RECNO)
            WorkEF2->(RecLock("WorkEF2",.F.)) //FSM - 09/03/2012
            WorkEF2->(DBDELETE())
            WorkEF2->(MSUnlock())
         EndIf
      EndIf
   EndIf

   If nOpca<>INCLUIR .or. nSelecao=0
      lIncluiAux := .F.
      WorkEF2->(dbGoTop())
      Exit
   EndIf
   nSelecao := 0

EndDo

aGets := aClone(aGetsAux)
aTela := aClone(aTelaAux)
nSelecao := 0

Return .T.

*-----------------------------*
Static Function EX400Invoices()
*-----------------------------*
Local i
Local nOrdEE9 := EE9->(IndexOrd()), nOrdEEC := EEC->(IndexOrd())
Private cQuery, cCond:=""
Private aMEDif := {}  // PLB 30/10/06 - Array contendo as moedas (das invoices) que diferem da moeda do contrato
Private lAltTx := .F.

/*Msgstop("Opção ainda não disponível, vincular através da manutenção de câmbio.")
l:=.t.
If l
  Return .t.
EndIf*/

WorkInv->(avzap())

If lTop

   If cMod == EXP
      If cTpCon == "1"
         cCond+="EEC.EEC_FILIAL IN (" + getFilial("EEC") + ") AND "+If(TcSrvType()<>"AS/400","EEC.D_E_L_E_T_ <> '*' ","EEC.@DELETED@ <> '*' ")
         cCond+="AND EEC.EEC_STATUS <> '*' " //AND (EEC.EEC_NRINVO <> '' OR EEC.EEC_NRINVO <> ' ') "
         cCond+="AND EEQ.EEQ_PREEMB = EEC.EEC_PREEMB "
         cCond+="AND EEQ.EEQ_FILIAL IN (" + getFilial("EEQ") + ") AND "+If(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_ <> '*' ","EEQ.@DELETED@ <> '*' ")
         cCond+="AND (EEQ.EEQ_NRINVO <> '' AND EEQ.EEQ_NRINVO <> ' ') "
         cCond+="AND (EEQ.EEQ_PGT = '' OR EEQ.EEQ_PGT = ' ') "
         cCond+="AND ((EEQ.EEQ_FI_TOT <> 'N' AND EEQ.EEQ_FI_TOT <> 'S') "

         cCond+="OR (EEQ.EEQ_FI_TOT = 'N' AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON > 0)) "

         cCond+="AND EEQ.EEQ_EVENT = '101' "//"AND ( EEQ.EEQ_TIPO = 'R' OR EEQ.EEQ_TIPO = '' OR EEQ.EEQ_TIPO = ' ') "
         If .not. Empty( dVencIni )
            cCond+="AND EEQ.EEQ_VCT >= '" + DtoS( dVencIni ) + "' "
         Endif
         If .not. Empty( dVencFim )
            cCond+="AND EEQ.EEQ_VCT <= '" + DtoS( dVencFim ) + "' "
         Endif
         If .not. Empty( cInvoice )
            //cCond+="AND  EEC.EEC_NRINVO = '" + Alltrim( cInvoice ) + "' "   //NCF - 06/07/2017
            cCond+="AND  EEQ.EEQ_NRINVO = '" + Alltrim( cInvoice ) + "' "
         Endif
         If .not. Empty( cProcesso )
            cCond+="AND EEC.EEC_PREEMB = '" + Alltrim( cProcesso ) + "' "
         Endif
         If .not. Empty( nValIni )
            cCond+="AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON >= " + Str( nValIni, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
         Endif
         If .not. Empty( nValFim )
            cCond+="AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON <= " + Str( nValFim, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
         Endif
         If lEEQ_TP_CON
            cCond+="AND (EEQ.EEQ_TP_CON = '1' OR EEQ.EEQ_TP_CON = '3') "
         EndIf
         If .not. Empty( cCondPagto )
            cCond+="AND EEC.EEC_CONDPA = '" + Alltrim(cCondPagto) + "' AND EEC.EEC_DIASPA = " + Str(nDias, AVSX3("EEC_DIASPA",3), AVSX3("EEC_DIASPA",4) ) + " "
         Endif
         If .not. Empty( cImport )
            cCond+="AND EEC.EEC_IMPORT = '" + Alltrim( cImport ) + "' "
         Endif
         If !Empty(cPais)
            cCond+="AND EEC.EEC_PAISDT = '" + Alltrim( cPais ) + "' "
         EndIf
         cCond+="AND SYA.YA_CODGI = EEC.EEC_PAISDT AND "
         cCond+="SYA.YA_FILIAL='"+xFilial("SYA")+"' AND "+If(TcSrvType()<>"AS/400","SYA.D_E_L_E_T_ <> '*' ","SYA.@DELETED@ <> '*' ")

         //FSM - 04/10/2012
         cCond+= "AND (EEQ.EEQ_PROR='  ' OR (EEQ.EEQ_MODAL = '2' AND EEQ.EEQ_DTCE <> ' ')) "

         If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"CONDICAO_VINCULACAO_TOP"),)

/* AJP 20/10/06
*/
      cQuery:= "SELECT DISTINCT '  ' MARCA, " +;
               " EEQ.EEQ_NRINVO EF3_INVOIC, EEQ.EEQ_PREEMB EF3_PREEMB, "+;
               "'"+DtoS(avCtoD("  /  /  "))+"' EF3_DT_FIX, EEQ.EEQ_VCT DT_VEN, EEC.EEC_MOEDA EF3_MOE_IN, "+;
               "EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON EF3_VL_INV, '"+DtoS(avCtoD("  /  /  "))+"' DT_AVERB, "+;
               "EEQ.EEQ_PARC EF3_PARC, EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_ORI, EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_INV, "+;
               "EEQ.EEQ_VL_PAR - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_PAR, EEQ.EEQ_FI_TOT FI_TOT, EEC.EEC_TIPCOM TIPCOM, "+If(EECFlags("FRESEGCOM"),"EEQ.EEQ_CGRAFI","0.00")+" VALCOM, EEC.EEC_TIPCVL TIPCVL, "+;
               "'"+DtoS(avCtoD("  /  /  "))+"' DT_VINC, 0.00 TX_VINC, EEQ.EEQ_BANC BANC_INV, "+;
               "EEQ.EEQ_VL_PAR - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_VINC, 0.00 VINCULADO, EEQ.EEQ_PARFIN PARFIN, "+;
               "EEC.EEC_DTEMBA DTEMBA, EEC.EEC_IMPORT IMPORT, EEC.EEC_IMPODE IMPODE, EEC.EEC_PAISDT PAIS, "+;
                  "SYA.YA_DESCR PAISDE, EEQ.EEQ_DTCE DTCE "+If(lEFFTpMod,", 'EEQ' EF3_ORIGEM ","")

         If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"CAMPOS_QUERY_INVOICES"),)

         //LRL 14/12/04 - Filial Original conceito de Multifilais-------------------------------
         cQuery+= " , EEQ.EEQ_FILIAL EF3_FILORI "
         //------------------------------LRL 14/12/04 - Filial Original Conceito de Multifilais
         cQuery+= ", EEQ.EEQ_TIPO TIPO, EEC.EEC_NRINVO EEC_NRINVO, EEQ.EEQ_MODAL"
         cQuery+= "FROM "+RetSqlName("EEC")+" EEC, "+RetSqlName("EEQ")+" EEQ, "+RetSqlName("SYA")+" SYA "
         cQuery+= "WHERE "+cCond+"ORDER BY EEQ.EEQ_PREEMB, EEC.EEC_NRINVO"

      ElseIf cTpCon == "3"
         If !lMultiFil .OR. Posicione("SX2",1,"EEC","X2_MODO") == "C"
            cCond+="EEQ.EEQ_FILIAL='"+xFilial("EEQ")+"' AND "+If(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_ <> '*' ","EEQ.@DELETED@ <> '*' ")
         Else
            cCond+="EEQ.EEQ_FILIAL IN ("+cFil+") AND "+If(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_ <> '*' ","EEQ.@DELETED@ <> '*' ")
         EndIf
         cCond+="AND (EEQ.EEQ_NRINVO <> '' AND EEQ.EEQ_NRINVO <> ' ') "
         cCond+="AND (EEQ.EEQ_PGT = '' OR EEQ.EEQ_PGT = ' ') "
         cCond+="AND ((EEQ.EEQ_FI_TOT <> 'N' AND EEQ.EEQ_FI_TOT <> 'S') "

         cCond+="OR (EEQ.EEQ_FI_TOT = 'N' AND EEQ.EEQ_VL_PAR - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON > 0)) "

         cCond+="AND EEQ.EEQ_EVENT = '101' "//"AND ( EEQ.EEQ_TIPO = 'R' OR EEQ.EEQ_TIPO = '' OR EEQ.EEQ_TIPO = ' ') "
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
            cCond+="AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON >= " + Str( nValIni, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
         Endif
         If .not. Empty( nValFim )
            cCond+="AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON <= " + Str( nValFim, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
         Endif
         If lEEQ_TP_CON
            cCond+="AND EEQ.EEQ_TP_CON = '3' "
         EndIf
         If .not. Empty( cImport )
            cCond+="AND EEQ.EEQ_IMPORT = '" + Alltrim( cImport ) + "' "
         Endif
         cCond+="AND SA1.A1_COD = EEQ.EEQ_IMPORT AND SA1.A1_LOJA = EEQ.EEQ_IMLOJA AND "
         cCond+="SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "+If(TcSrvType()<>"AS/400","SA1.D_E_L_E_T_ <> '*' ","SA1.@DELETED@ <> '*' ")

         If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"CONDICAO_VINCULACAO_TOP"),)

/*  AJP 20/10/06
*/
      cQuery:= "SELECT DISTINCT '  ' MARCA, " +;
               " EEQ.EEQ_NRINVO EF3_INVOIC, EEQ.EEQ_PREEMB EF3_PREEMB, "+;
               "'"+DtoS(avCtoD("  /  /  "))+"' EF3_DT_FIX, EEQ.EEQ_VCT DT_VEN, EEQ.EEQ_MOEDA EF3_MOE_IN, "+;
               "EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON EF3_VL_INV, '"+DtoS(avCtoD("  /  /  "))+"' DT_AVERB, "+;
               "EEQ.EEQ_PARC EF3_PARC, EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_ORI, EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_INV, "+;
               "EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_PAR, EEQ.EEQ_FI_TOT FI_TOT, ' ' TIPCOM, "+If(EECFlags("FRESEGCOM"),"EEQ.EEQ_CGRAFI","0.00")+" VALCOM, ' ' TIPCVL, "+;
               "'"+DtoS(avCtoD("  /  /  "))+"' DT_VINC, 0.00 TX_VINC, EEQ.EEQ_BANC BANC_INV, "+;
               "EEQ.EEQ_VL_PAR - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_VINC, 0.00 VINCULADO, EEQ.EEQ_PARFIN PARFIN, "+;
               "EEQ.EEQ_SOL DTEMBA, EEQ.EEQ_IMPORT IMPORT, SA1.A1_NOME IMPODE, ' ' PAIS, "+;
                  "' ' PAISDE, EEQ.EEQ_DTCE DTCE "+If(lEFFTpMod,", 'EEQ' EF3_ORIGEM ","")

         If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"CAMPOS_QUERY_INVOICES"),)

         //LRL 14/12/04 - Filial Original conceito de Multifilais-------------------------------
         cQuery+= " , EEQ.EEQ_FILIAL EF3_FILORI "
         //------------------------------LRL 14/12/04 - Filial Original Conceito de Multifilais
         cQuery+= ", EEQ.EEQ_TIPO TIPO, EEQ.EEQ_NRINVO EEC_NRINVO, EEQ.EEQ_MODAL"
         cQuery+= "FROM "+RetSqlName("EEQ")+" EEQ, "+RetSqlName("SA1")+" SA1 "
         cQuery+= "WHERE "+cCond+"ORDER BY EEQ.EEQ_PREEMB, EEQ.EEQ_NRINVO"

      EndIf

   ElseIf cMod == IMP

      cQuery  := ""
      cCond   := ""

      If !lMultiFil .OR. Posicione("SX2",1,"SWB","X2_MODO") == "C"
         cCond+="SWB.WB_FILIAL='"+xFilial("SWB")+"' AND "+If(TcSrvType()<>"AS/400","SWB.D_E_L_E_T_ <> '*' ","SWB.@DELETED@ <> '*' ")
      Else
         cCond+="SWB.WB_FILIAL IN ("+cFil+") AND "+If(TcSrvType()<>"AS/400","SWB.D_E_L_E_T_ <> '*' ","SWB.@DELETED@ <> '*' ")
      EndIf

      // ** PLB 08/06/06
      If lParfin
         cCond+=" AND (SWB.WB_PARFIN = '' OR SWB.WB_PARFIN = ' ') "
      EndIf
      // **
      cCond+="AND (SWB.WB_CA_DT = '' OR SWB.WB_CA_DT = ' ') "

      //AOM - 04/07/2012 - Tratamento para carregar invoices antecipadas
      cCond+="AND (SW6.W6_FILIAL = SWB.WB_FILIAL AND SW6.W6_HAWB = SWB.WB_HAWB OR SW2.W2_FILIAL = SWB.WB_FILIAL AND SW2.W2_PO_NUM = SWB.WB_HAWB ) "

      //AOM - 04/07/2012 - Foi separado os deletes para o tratamento para carregar invoices antecipadas
      cCond+="AND "+If(TcSrvType()<>"AS/400","SW6.D_E_L_E_T_ <> '*' ","SW6.@DELETED@ <> '*' ")
      cCond+="AND "+If(TcSrvType()<>"AS/400","SW2.D_E_L_E_T_ <> '*' ","SW2.@DELETED@ <> '*' ")

      cCond+="AND SWB.WB_EVENT = '101' "//"AND ( EEQ.EEQ_TIPO = 'R' OR EEQ.EEQ_TIPO = '' OR EEQ.EEQ_TIPO = ' ') "
      If .not. Empty( dVencIni )
         cCond+="AND SWB.WB_DT_VEN >= '" + DtoS( dVencIni ) + "' "
      Endif
      If .not. Empty( dVencFim )
         cCond+="AND SWB.WB_DT_VEN <= '" + DtoS( dVencFim ) + "' "
      Endif
      If .not. Empty( cInvoice )
         cCond+="AND SWB.WB_INVOICE = '" + Alltrim( cInvoice ) + "' "
      Endif
      If .not. Empty( cProcesso )
         cCond+="AND SWB.WB_HAWB = '" + Alltrim( cProcesso ) + "' "
      Endif

      If .not. Empty( nValIni )
         If SWB->( FieldPos("WB_COMAG") ) > 0
            cCond+="AND (SWB.WB_FOBMOE+SWB.WB_PGTANT)-SWB.WB_COMAG >= " + Str( nValIni, AVSX3("WB_FOBMOE",3), AVSX3("WB_FOBMOE",4) ) + " "  //AOM - 04/07/2012
         Else
            cCond+="AND SWB.WB_FOBMOE+SWB.WB_PGTANT >= " + Str( nValIni, AVSX3("WB_FOBMOE",3), AVSX3("WB_FOBMOE",4) ) + " " //AOM - 04/07/2012
         EndIf
      Endif
      If .not. Empty( nValFim )
         If SWB->( FieldPos("WB_COMAG") ) > 0
            cCond+="AND (SWB.WB_FOBMOE+SWB.WB_PGTANT)-SWB.WB_COMAG <= " + Str( nValFim, AVSX3("WB_FOBMOE",3), AVSX3("WB_FOBMOE",4) ) + " " //AOM - 04/07/2012
         Else
            cCond+="AND SWB.WB_FOBMOE+SWB.WB_PGTANT <= " + Str( nValFim, AVSX3("WB_FOBMOE",3), AVSX3("WB_FOBMOE",4) ) + " " //AOM - 04/07/2012
         EndIf
      Endif

      // ** GFC - 13/04/06
      If SWB->( FieldPos("WB_COMAG") ) > 0
         cCond+="AND (SWB.WB_FOBMOE+SWB.WB_PGTANT)-SWB.WB_COMAG > 0 " //AOM - 04/07/2012
      Else
         cCond+="AND SWB.WB_FOBMOE+SWB.WB_PGTANT > 0 " //AOM - 04/07/2012
      EndIf
      // **

      cCond+="AND (SWB.WB_TP_CON = '2' OR SWB.WB_TP_CON = '4') "

      If .not. Empty( cFornec )
         cCond+="AND SWB.WB_FORN = '" + Alltrim( cFornec ) + "' "
      Endif

      cCond+=" AND SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND "+If(TcSrvType()<>"AS/400","SA2.D_E_L_E_T_ <> '*' ","SA2.@DELETED@ <> '*' ")
      cCond+=" AND SWB.WB_FORN = SA2.A2_COD "//MPG - 26/10/2018 - //AND SW6.W6_DT_EMB <> ''

      //cCond+=" AND SYA.YA_FILIAL='"+xFilial("SYA")+"' AND "+If(TcSrvType()<>"AS/400","SYA.D_E_L_E_T_ <> '*' ","SYA.@DELETED@ <> '*' ")

      If !Empty(cPais)
         cCond+=" AND SA2.A2_PAIS = '" + Alltrim( cPais ) + "' "
      EndIf

      //cCond+=" AND SYA.YA_CODGI = SA2.A2_PAIS "      //PLB 11/09/06 - Nao traz Invoices com Pais do Fornecedor em Branco

      cQuery:= "SELECT DISTINCT '' EF3_INVOIC, '' EF3_PARC, '' EF3_PREEMB, SWB.WB_INVOICE EF3_INVIMP, SWB.WB_LINHA EF3_LINHA, SWB.WB_HAWB EF3_HAWB, SWB.WB_PO_DI EF3_PO_DI, SWB.WB_DT_VEN DT_VEN, SWB.WB_MOEDA EF3_MOE_IN, "+;
               "(SWB.WB_FOBMOE+SWB.WB_PGTANT)+"+If( SWB->( FieldPos("WB_COMAG") ) > 0,"-SWB.WB_COMAG","")+" EF3_VL_INV, "+;
               "(SWB.WB_FOBMOE+SWB.WB_PGTANT)"+If(SWB->( FieldPos("WB_COMAG") ) > 0,"-SWB.WB_COMAG","")+" VL_ORI, (SWB.WB_FOBMOE+SWB.WB_PGTANT)"+If(SWB->( FieldPos("WB_COMAG") ) > 0,"-SWB.WB_COMAG","")+" VL_INV, "+;
               "SWB.WB_TIPOCOM TIPCOM, "+If(SWB->( FieldPos("WB_COMAG") ) > 0,"SWB.WB_COMAG","0.00")+" VALCOM, "+; // EEC.EEC_TIPCVL TIPCVL, "+;
               "SWB.WB_BANCO BANC_INV, "+;//SW6.W6_DT_EMB,  EEQ.EEQ_PARFIN PARFIN, "+; //AOM - 23/07/2012
               "SWB.WB_FORN EF3_FORN, SWB.WB_LOJA EF3_LOJAFO,"+ If(!Empty(cPais)," SA2.A2_PAIS PAIS, ","")+;  //"SYA.YA_DESCR PAISDE, "+;  // PLB 11/09/06 //LRS - 02/08/2018
               "'        ' DTCE, SWB.WB_TIPOC TIPO, SWB.WB_FILIAL EF3_FILORI"+If(lEFFTpMod,", 'SWB' EF3_ORIGEM ","") //, .EEQ_DTCE DTCE "

      cQuery+= " FROM "+RetSqlName("SA2")+" SA2, "+;  //+RetSqlName("SYA")+" SYA, "
               RetSqlName("SWB")+" SWB, "+RetSqlName("SW6")+" SW6, "+RetSqlName("SW2")+" SW2 "//+; //AOM - 04/07/2012

      cQuery+= " WHERE "+cCond//+"ORDER BY SWB.WB_HAWB, SWB.WB_INVOICE "

      cCond := ""

      If !lMultiFil .OR. Posicione("SX2",1,"EEC","X2_MODO") == "C"
         cCond+="EEQ.EEQ_FILIAL='"+xFilial("EEQ")+"' AND "+If(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_ <> '*' ","EEQ.@DELETED@ <> '*' ")
      Else
         cCond+="EEQ.EEQ_FILIAL IN ("+cFil+") AND "+If(TcSrvType()<>"AS/400","EEQ.D_E_L_E_T_ <> '*' ","EEQ.@DELETED@ <> '*' ")
      EndIf

      cCond+="AND (EEQ.EEQ_NRINVO <> '' AND EEQ.EEQ_NRINVO <> ' ') "
      cCond+="AND (EEQ.EEQ_PGT = '' OR EEQ.EEQ_PGT = ' ') "
      cCond+="AND ((EEQ.EEQ_FI_TOT <> 'N' AND EEQ.EEQ_FI_TOT <> 'S') "

      cCond+="OR (EEQ.EEQ_FI_TOT = 'N' AND EEQ.EEQ_VL_PAR - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON > 0)) "
      
      //LRS - 08/02/2018 - Nopado pois a query deve trazer todas as parcelas com o tipo a pagar
      //cCond+="AND (EEQ.EEQ_EVENT = '101' OR EEQ.EEQ_EVENT = '105')"//"AND ( EEQ.EEQ_TIPO = 'R' OR EEQ.EEQ_TIPO = '' OR EEQ.EEQ_TIPO = ' ') "  // GFP - 18/06/2015
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
         cCond+="AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON >= " + Str( nValIni, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
      Endif
      If .not. Empty( nValFim )
         cCond+="AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON <= " + Str( nValFim, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4) ) + " "
      Endif

      If lEEQ_TP_CON
         cCond+="AND EEQ.EEQ_TP_CON = '4' "
      EndIf

      If .not. Empty( cFornec )
         cCond+="AND EEQ.EEQ_FORN = '" + Alltrim( cFornec ) + "' "
      Endif

      cCond+="AND SA2.A2_COD = EEQ.EEQ_FORN AND SA2.A2_LOJA = EEQ.EEQ_FOLOJA AND "
      cCond+="SA2.A2_FILIAL='"+xFilial("SA2")+"' AND "+If(TcSrvType()<>"AS/400","SA2.D_E_L_E_T_ <> '*' ","SA2.@DELETED@ <> '*' ")

      // PLB 11/09/06 - Nao traz Invoices que com Pais do fornecedor em branco
      //cCond+=" AND SYA.YA_FILIAL='"+xFilial("SYA")+"' AND "+If(TcSrvType()<>"AS/400","SYA.D_E_L_E_T_ <> '*' ","SYA.@DELETED@ <> '*' ")
      //cCond+=" AND SYA.YA_CODGI = SA2.A2_PAIS "

      cQuery+= " UNION SELECT DISTINCT EEQ.EEQ_NRINVO EF3_INVOIC, EEQ.EEQ_PARC EF3_PARC, EEQ.EEQ_PREEMB EF3_PREEMB, EEQ.EEQ_NRINVO EF3_INVIMP, '' EF3_LINHA, '' EF3_HAWB, ' ' EF3_PO_DI, "+;  // GFP - 18/06/2015
                  " EEQ.EEQ_VCT DT_VEN, EEQ.EEQ_MOEDA EF3_MOE_IN, "+;
                  "EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON EF3_VL_INV, "+;
                  "EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_ORI, EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_INV, "+;
                  "' ' TIPCOM, "+If(EECFlags("FRESEGCOM"),"EEQ.EEQ_CGRAFI+EEQ.EEQ_ADEDUZ","0.00")+" VALCOM, "+;
                  "EEQ.EEQ_BANC BANC_INV, EEQ.EEQ_FORN EF3_FORN, EEQ.EEQ_FOLOJA EF3_LOJAFO,"+ If(!Empty(cPais)," SA2.A2_PAIS PAIS, ","")+; //EEQ.EEQ_SOL DTEMBA,SYA.YA_DESCR PAISDE, "+;//AOM - 23/07/2012// LRS - 08/20/2018
                  "EEQ.EEQ_DTCE DTCE, EEQ.EEQ_TIPO TIPO, EEQ.EEQ_FILIAL EF3_FILORI"+If(lEFFTpMod,", 'EEQ' EF3_ORIGEM ","")

      If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"CAMPOS_QUERY_INVOICES"),)

      //LRL 14/12/04 - Filial Original conceito de Multifilais-------------------------------
      //------------------------------LRL 14/12/04 - Filial Original Conceito de Multifilais
      cQuery+= " FROM "+RetSqlName("EEQ")+" EEQ, "+RetSqlName("SA2")+" SA2 "//+RetSqlName("SYA")+" SYA "
      cQuery+= " WHERE "+cCond//+"ORDER BY EEQ.EEQ_PREEMB, EEQ.EEQ_NRINVO "

   EndIf

   cQuery:=ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW

   If cMod == EXP
      TcSetField("TRB","EF3_DT_FIX","D")
      TcSetField("TRB","DT_VEN","D")
      TcSetField("TRB","DT_AVERB","D")
      TcSetField("TRB","DT_VINC","D")
      TcSetField("TRB","TX_VINC","N",AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4))
      TcSetField("TRB","DTEMBA","D")
      TcSetField("TRB","DTCE","D")

   ElseIf cMod == IMP
      TcSetField("TRB","DT_VEN","D")
      //TcSetField("TRB","DT_VINC","D")
      //TcSetField("TRB","TX_VINC","N",AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4))
      //TcSetField("TRB","DTEMBA","D")
      TcSetField("TRB","DTCE","D")

   EndIf

   If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"TRANSF_CAMPOS_QUERY_INVOICES"),)

   dbSelectArea("TRB")
   TRB->( dbGoTop() )
   Do While !TRB->( EoF() )
      WorkInv->(RecLock("WorkInv",.T.))
      FOR i := 1 TO FCount()
         WorkInv->&(TRB->( FIELDNAME(i) )) := FieldGet(i)
      NEXT i
      If WorkInv->FI_TOT <> "N"
         WorkInv->VL_VINC := WorkInv->VL_ORI
      Endif
      WorkInv->EF3_FILORI := TRB->EF3_FILORI
      If cMod == IMP    // PLB 11/09/06
         IF !Empty(cPais)//LRS - 09/02/2017
             WorkInv->PAISDE := Posicione("SYA",1,xFilial("SYA")+TRB->PAIS,"YA_DESCR")
         Else
             WorkInv->PAISDE := ""
         EndIF
      EndIf

      //------------------------------LRL 14/12/04 - Grava Filial Original Conceito de Multifilais
      WorkInv->TRB_ALI_WT := "EEQ"
      WorkInv->TRB_REC_WT := 0

      WorkInv->(msUnlock())
      TRB->(dbSkip())
   EndDo

   TRB->(dbCloseArea())

   //FSM - 03/10/2012
   If cMod == EXP
      EX400InvoAdiant()
   EndIf

   dbSelectArea("WorkInv")
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
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "(EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON) >= nValIni "
   Endif
   If .not. Empty( nValFim )
      cCond+=iif(.not. Empty(cCond), ".AND.","") + "(EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON) <= nValFim "
   Endif
   If .not. Empty( cImport )
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_IMPORT = '" + Alltrim( cImport ) + "' "
   Endif
   If .not. Empty( cCondPagto )
      cCond+=iif(.not. Empty(cCond), ".AND. ","") + "EEC->EEC_CONDPA = '" + Alltrim(cCondPagto) + "' .AND. EEC->EEC_DIASPA = nDias"
   Endif

   If Empty (cCond)
      cCond := ".t."
   Endif

   EEQ->(DbSetOrder(1))
   EEC->(DbSetOrder(1))
   EEC->(Dbgotop())
   // EEC->(DbSeek(xFilial("EEC"),.T.)) LRL - Conceito MultiFilial
   For i:=1 to Len(aFil)
      Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL == aFil[i]  //xFilial("EEC")
         MsProcTxt(STR0061+Alltrim(EEC->EEC_PREEMB)) //"Apurando Processo "
         If EEC->EEC_STATUS <> '*'
            If EEQ->(dbSeek(aFil[i]+EEC->EEC_PREEMB)) //EEQ->(dbSeek(xFilial("EEQ")+EEC->EEC_PREEMB)) LRL 15/12/04
               Do While !EEQ->(EOF()) .and. EEQ->EEQ_PREEMB == EEC->EEC_PREEMB
/* AJP 20/10/06
                  If !Empty(EEQ->EEQ_NRINVO) .and.;
               (!EEQ->EEQ_FI_TOT $("N/S") .or. (EEQ->EEQ_FI_TOT == "N" .and. (EEQ->EEQ_VL_PAR-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0)) > 0)) .and. !EEQ->EEQ_TIPO $ "AP" .And.;
                  Empty(EEQ->EEQ_PGT) .AND. &cCond
*/
                  If !Empty(EEQ->EEQ_NRINVO) .and.;
               (!EEQ->EEQ_FI_TOT $("N/S") .or. (EEQ->EEQ_FI_TOT == "N" .and. (EEQ->EEQ_VL_PAR - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON) > 0)) .and. !EEQ->EEQ_TIPO $ "AP" .And.;
                  Empty(EEQ->EEQ_PGT) .AND. &cCond
                     If !Empty(cPais)
                        SA1->(dbSeek(xFilial("SA1")+cImport))
                     EndIf
                     If Empty(cPais) .or. SA1->A1_PAIS == cPais
                        WorkInv->(RecLock("WorkInv",.T.))
                        WorkInv->MARCA      := '  '
                        WorkInv->EF3_INVOIC := EEQ->EEQ_NRINVO
                        WorkInv->EF3_PREEMB := EEC->EEC_PREEMB
/* AJP 20/10/06
                        WorkInv->VL_ORI     := EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0)
                        WorkInv->VL_ORI     := EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0)
                        WorkInv->EF3_VL_INV := EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0)
                        WorkInv->VL_INV     := EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0)
                        WorkInv->VL_PAR     := EEQ->EEQ_VL_PAR-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0)
*/
                        WorkInv->VL_ORI     := AF200VLFCam("EEQ")//EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI,0)
                        WorkInv->EF3_VL_INV := AF200VLFCam("EEQ")//EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI,0)
                        WorkInv->VL_INV     := AF200VLFCam("EEQ")//EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI,0)
                        WorkInv->EF3_DT_FIX := avCtoD("  /  /  ")
                        WorkInv->DT_VEN     := EEQ->EEQ_VCT
                        WorkInv->EF3_MOE_IN := EEC->EEC_MOEDA
                        WorkInv->EF3_PARC   := EEQ->EEQ_PARC
                        WorkInv->VL_PAR     := EEQ->EEQ_VL_PAR - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON
                        WorkInv->FI_TOT     := EEQ->EEQ_FI_TOT
                        WorkInv->TIPCOM     := EEC->EEC_TIPCOM
                        WorkInv->VALCOM     := EEC->EEC_VALCOM
                        WorkInv->TIPCVL     := EEC->EEC_TIPCVL
                        WorkInv->BANC_INV   := EEQ->EEQ_BANC
                        WorkInv->VL_VINC    := iif(WorkInv->FI_TOT <> "N", EEQ->EEQ_VL, EEQ->EEQ_VL_PAR) - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON
                        WorkInv->VINCULADO  := 0.00
                        WorkInv->EF3_FILORI := EEQ->EEQ_FILIAL
                        WorkInv->PARFIN     := EEQ->EEQ_PARFIN
                        WorkInv->TRB_ALI_WT := "EEQ"
                        WorkInv->TRB_REC_WT := EEQ->(Recno())
                        WorkInv->(msUnlock())
                     Endif
                  EndIf
                  EEQ->(dbSkip())
               EndDo
            EndIf
         Endif
         EEC->(DbSkip())
      Enddo
   Next
Endif

Processa({|| ValInvoices()}  ,STR0062) //"Validando Invoices"

If WorkInv->(EOF()) .and. WorkInv->(BOF())
   Help(" ",1,"AVG0005250") //MsgInfo(STR0063) //"Nenhuma Invoice Selecionada na Apuração."
Else
   BrowseInv()
EndIf

WorkEF3->(DbGotop())

Return .T.

*-------------------------*
Static Function BrowseInv()
*-------------------------*
Local nSelecao, aBotoes2:={}
Local oPanel //LRL 03/06/04
// ** GFC - Pré-Pagamento / Securitização
Local cTpVinc:=cTipoVinc, nValParc, nSaldoParc, cParcela, nSize:=35, nLinIni:=45
// **
Local nSpace,nAdCol, nLinha  // PLB 20/07/06 - Variaveis para controle de diferentes resolucoes
Local i := 1
Private aEEQLockList := {} ,;
        aSWBLockList := {}     // PLB 24/07/06 - Variaveis para tratamento multi-usuario
Private oMark2, nVincTot:=0 , nJaVinc := 0
Private dDataGeral:=dDataBase
Private nTaxaGeral:=BuscaTaxa(M->EF1_MOEDA,dDataGeral,,.F.,.T.,,cTX_100)
Private nTaxaAlt:=.F. //Alcir Alves - caso retorna .T. caso a data inicial da taxa - 23-06-05
Private nTaxaOri:=0 //Alcir Alves - taxa original do dia - 23-06-05
Private oGetSld, nSaldoRest, oSaySld //Apresenta o saldo da parcela menos as faturas que estão sendo marcadas
Private dEntrGeral := dDataBase  // FSY 11/04/2013

//PLB 14/08/06 - Valor total ja vinculado
nJaVinc := EX401EvSum(EV_EMBARQUE,"WorkEF3",cFilEF1+IIF(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_BAN_FI+M->EF1_PRACA+IIF(lEFFTpMod,M->EF1_SEQCNT,""))

EF6->( DBSetOrder(2) )

aSelCpos3:= {  {"MARCA",,""} }

IF EF1->EF1_TP_FIN == "05" //LRS - 21/02/2018
   nTaxaGeral := EF1->EF1_TX_MOE
EndIF

//LRL 14/12/04 - Filial Original ,conceito de Multifilais----------------------------------------------
If lMultiFil
   Aadd(aSelCpos3,{"EF3_FILORI", ,"Filial"})
EndIF

If cMod == EXP
   Aadd(aSelCpos3,{"EF3_PREEMB",,AVSX3("EF3_PREEMB",5)})
   Aadd(aSelCpos3,{"EF3_PARC",,AVSX3("EF3_PARC",5)})
   Aadd(aSelCpos3,{"EF3_INVOIC",,AVSX3("EF3_INVOIC",5)})
ElseIf cMod == IMP
   Aadd(aSelCpos3,{{||If(Empty(WorkInv->EF3_PREEMB),WorkInv->EF3_HAWB  ,WorkInv->EF3_PREEMB)},,AVSX3("EF3_PREEMB",5)})
   Aadd(aSelCpos3,{{||If(cMod <> IMP,WorkInv->EF3_PARC  ,WorkInv->EF3_LINHA )},,AVSX3("EF3_PARC",5)})//If(Empty(WorkInv->EF3_PARC)
   Aadd(aSelCpos3,{{||If(cMod <> IMP,WorkInv->EF3_INVOIC,WorkInv->EF3_INVIMP)},,AVSX3("EF3_INVOIC",5)})//If(Empty(WorkInv->EF3_INVOIC),
EndIf

Aadd(aSelCpos3,{"EF3_DT_FIX",,AVSX3("EF3_DT_FIX",5)})
Aadd(aSelCpos3,{"EF3_MOE_IN",,AVSX3("EF3_MOE_IN",5)})
Aadd(aSelCpos3,{{||(WorkInv->BANC_INV + " - " + If(SA6->(DbSeek(xFilial("SA6")+WorkInv->BANC_INV)), SA6->A6_NREDUZ,"")) } ,,AVSX3("EEQ_BANC",5)})
Aadd(aSelCpos3,{"VL_INV",,AVSX3("EF3_VL_INV",5),AVSX3("EF3_VL_INV",6)})
Aadd(aSelCpos3,{{||(If(WorkInv->TIPCOM = '1', STR0077, If(WorkInv->TIPCOM = '2', STR0078, If(WorkInv->TIPCOM="3",STR0079,""))))} ,,AVSX3("EEC_TIPCOM",5)})
Aadd(aSelCpos3,{"VALCOM"    ,,AVSX3("EEC_VALCOM",5),AVSX3("EEC_VALCOM",6)})
Aadd(aSelCpos3,{"VL_VINC"   ,,STR0085,AVSX3("EF3_VL_INV",6)}) //"Vl a Vincular"
Aadd(aSelCpos3,{"DT_VEN"    ,,AVSX3("EEQ_VCT",5),AVSX3("EF3_VL_INV",6)})
Aadd(aSelCpos3,{"DT_VINC"   ,,STR0116})                         // "Data do Evento"
Aadd(aSelCpos3,{"TX_VINC"   ,,STR0117, AVSX3("EF3_TX_MOE",6)})  // "Taxa da Moeda"
Aadd(aSelCpos3,{"VINCULADO" ,,STR0118, AVSX3("EF3_VL_MOE",6)} ) // "Valor Vinculado"
Aadd(aSelCpos3,{"DTEMBA"    ,,AVSX3("EEC_DTEMBA",5), AVSX3("EEC_DTEMBA",6)} )
If cMod == EXP
   Aadd(aSelCpos3,{{||Alltrim(WorkInv->IMPORT)+" - "+Alltrim(WorkInv->IMPODE)} ,,AVSX3("EEC_IMPORT",5), AVSX3("EEC_IMPORT",6)} )
   Aadd(aSelCpos3,{{||Alltrim(WorkInv->PAIS)+" - "+Alltrim(WorkInv->PAISDE)} ,,AVSX3("EEC_PAISDT",5), AVSX3("EEC_PAISDT",6)} )
   Aadd(aSelCpos3,{"DTCE"      ,,AVSX3("EEQ_DTCE",5)  , AVSX3("EEQ_DTCE",6)} )
   Aadd(aSelCpos3,{{||WorkInv->EEQ_MODAL+"-"+BSCXBOX("EEQ_MODAL",WorkInv->EEQ_MODAL)} ,,AVSX3("EEQ_MODAL",5), AVSX3("EEQ_MODAL",6)} )
   Aadd(aSelCpos3,{{||WorkInv->TIPO+"-"+BSCXBOX("EEQ_TIPO",WorkInv->TIPO)} ,,AVSX3("EEQ_TIPO",5), ""} )
   If EF3->(FieldPOs("EF3_DTDOC"))>0// FSY - 17/04/2013  // GFP - 23/09/2014
      Aadd(aSelCpos3,{"EF3_DTDOC"    ,,AVSX3("EF3_DTDOC",5), AVSX3("EF3_DTDOC",6)})
   EndIf
ElseIf cMod == IMP
   Aadd(aSelCpos3,{{||Alltrim(WorkInv->EF3_FORN)+" - "+Alltrim(Posicione("SA2",1,xFilial("SA2")+WorkInv->EF3_FORN+WorkInv->EF3_LOJAFO,"A2_NREDUZ"))},,AVSX3("EF3_FORN",5), AVSX3("EF3_FORN",6)} )
   Aadd(aSelCpos3,{{||Alltrim(WorkInv->PAIS)+" - "+Alltrim(WorkInv->PAISDE)} ,,AVSX3("A2_PAIS",5), AVSX3("A2_PAIS",6)} )
EndIf
//----------------------------------------------------------------------------------------------------
               //{{||(WorkInv->EF3_VL_INV - WorkInv->VALCOM) },, STR0085,AVSX3("EF3_VL_INV",6) } }

aBotoes2 := { {"LBTIK"   ,{|| IIF(EX400Valid("MARCA_INVOICES"),Processa({|| InvMarca(.T.)},STR0064),),WorkInv->(dbGoTop()) },STR0064, Ex401str(175) } ,; //"Marca/Desmarca Todos"###"Marca/Desmarca Todos"
              {"PESQUISA",{|| EX4PesqInv()                                              },STR0002} }  //"Pesquisar"

If cMod == IMP
   nOldVlCont := M->EF1_VL_MOE
EndIf

If cMod == EXP .AND. lPrePag .AND. M->EF1_CAMTRA == "1" //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
// ** GFC - Pré-Pagamento / Securitização
   WorkEF3->(dbSetOrder(2))

   nSaldoParc := EXPosPrePag("WorkEF3",M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,.T.,cTpVinc,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
   nSaldoRest := nSaldoParc
   cParcela   := WorkEF3->EF3_PARC
   nLinIni    := 50
   nSize      := 40
// **
ElseIf cMod == EXP
   nSaldoParc := M->EF1_VL_MOE - EX401EvSum("600","WorkEF3",,.T.) - EX401EvSum("190","WorkEF3",,.T.) //THTS - 15/09/2017 - Subtrai o valor do evento de transferencia (190) do saldo
   nSaldoRest := nSaldoParc
Else
   nSaldoParc := M->EF1_SLD_PM
   nSaldoRest := nSaldoParc - nJaVinc
EndIf

If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"BROWSE_INVOICES"),)

nSelecao:=0
DEFINE MSDIALOG oDlg TITLE STR0015 ; //"Vincular Invoices"
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
       OF oMainWnd PIXEL


   @ 00,00 MsPanel oPanel Prompt "" Size (oMainWnd:nClientWidth/16),nSize of oDlg   // PLB 20/07/06

   // PLB 20/07/06
   nSpace := Round(((oPanel:nClientWidth/2))/4,0) // 4 campos por linha
   nLinha := 0.5
   nAdCol := 2

   //Linha 1
   @nLinha, nAdCol SAY STR0081  of oPanel   //"Data da Vinculação"
   @nLinha, nAdCol + 7 MSGET dDataGeral PICT AVSX3("EF3_DT_FIX",6) Valid EX400Valid("dDataGeral") SIZE 60,8 of oPanel HASBUTTON

   nAdCol += nSpace
   @nLinha, nAdCol SAY   STR0082  of oPanel    //"Taxa da Vinculação"
   @nLinha, nAdCol + 7 MSGET nTaxaGeral PICT AVSX3("EF3_TX_MOE",6) Valid EX400Valid("nTaxaGeral") SIZE 60,8 of oPanel HASBUTTON

   If EF3->(FieldPos('EF3_DTDOC')) > 0// FSY - 17/04/2013
      nAdCol += nSpace
      @nLinha, nAdCol  SAY AVSX3('EF3_DTDOC',AV_TITULO)  Of oPanel //Dt.Ent.Doc
      @nLinha, nAdCol + 7  MsGet dEntrGeral  PICT AVSX3('EF3_DTDOC',AV_PICTURE) WHEN .T.   Size 60,6 of oPanel HASBUTTON
   EndIf

   // ** GFC - Pré-Pagamento / Securitização
   If lPrePag .AND. M->EF1_CAMTRA == "1" //lPrePag .and. M->EF1_TP_FIN $ ("03/04"

      //Linha 2
      nLinha += 1.2
      nAdCol := 2
      @nLinha, nAdCol SAY   STR0253 of oPanel    //"Saldo da Parcela"
      @nLinha, nAdCol + 7 MSGET nSaldoParc PICT AVSX3("EF1_SLD_PM",6) SIZE 60,8 of oPanel When .F. HASBUTTON

      //FSY 19/06/2013 - adicionado nAdcol
      nAdCol += nSpace
      @nLinha, nAdCol SAY   STR0251 of oPanel    //"Saldo a Vincular"
      @nLinha, nAdCol + 7 MSGET oGetSld Var nSaldoRest PICT AVSX3("EF1_SLD_PM",6) SIZE 60,8 of oPanel When .F. HASBUTTON

      nAdCol += nSpace
      @nLinha, nAdCol SAY   STR0252  of oPanel    //"Tipo"
      @nLinha, nAdCol + 7 MSGET If(cTpVinc=="1",STR0230,STR0231) PICT "@!" SIZE 60,8 of oPanel When .F.

      nAdCol += nSpace
      @nLinha, nAdCol SAY   STR0170  of oPanel    //"Parcela"
      @nLinha, nAdCol + 7 MSGET cParcela PICT AVSX3("EF3_PARC",6) SIZE 30,8 of oPanel When .F.

      If cMod == EXP
         @2.5,2 SAY oSaySld Prompt STR0254 SIZE 300,8 of oPanel //"O excedente selecionado será distribuído para as próximas parcelas."
         oSaySld:NCLRTEXT := CLR_HRED
         oSaySld:Hide()
         oSaySld:Refresh()
      EndIf
   Else

      //Linha 2
      nLinha += 1.2
      nAdCol := 2

      @nLinha, nAdCol SAY   STR0253 of oPanel    //"Saldo da Parcela"
      @nLinha, nAdCol + 7 MSGET nSaldoParc PICT AVSX3("EF1_SLD_PM",6) SIZE 60,8 of oPanel When .F. HASBUTTON

      nAdCol += nSpace
      @nLinha, nAdCol SAY   STR0251 of oPanel    //"Saldo a Vincular"
      @nLinha, nAdCol + 7 MSGET oGetSld Var nSaldoRest PICT AVSX3("EF1_SLD_PM",6) SIZE 60,8 of oPanel When .F. HASBUTTON
   EndIf
   // **

   nLinha :=(oDlg:nClientHeight-4)/2

   oMark2:= MsSelect():New("WorkInv","MARCA",,aSelCpos3,@lInverte,@cMarca,{nLinIni,1,nLinha,COLUNA_FINAL})
   oMark2:oBrowse:bWhen:={|| DBSELECTAREA("WorkInv"),.T.}
   oMark2:bAval:={||If(WorkInv->MARCA<>cMarca,(EX400ChkItem(WorkInv->EF3_PREEMB),GetValInv()),InvMarca(.F.))}

   oDlg:lMaximized:=.T. //LRL 03/05/04
ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||IIF(cMod==EXP .Or. (cMod==IMP .And. IIF(lAumVlCont,EX400Valid("EF1_VL_MOE"),.T.)),(nSelecao:=1,oDlg:End()),)},{||nSelecao:=0,oDlg:End()},,aBotoes2),;
                                oPanel:Align:=CONTROL_ALIGN_TOP,;              // LRL 03/06/04
                                oMark2:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT) // Alinhamento MDI.

If nSelecao = 1
   // PLB 24/07/06 - Tratamento Multi-Usuário
   aEEQLockList := EEQ->( DBRLockList() )
   aSWBLockList := SWB->( DBRLockList() )

   Processa({|| GrvEventos(cTpVinc)}  ,STR0065) //"Gravando Eventos."

   For i := 1  to  Len(aEEQLockList)
      EEQ->( DBGoTo(aEEQLockList[i]) )
      SoftLock("EEQ")
   Next i
   For i := 1  to  Len(aSWBLockList)
      SWB->( DBGoTo(aSWBLockList[i]) )
      SoftLock("SWB")
   Next i

ElseIf nSelecao == 0
   // ** PLB 21/07/06 - Tratamento Multi-Usuário
   EEQ->( DBSetOrder(1) )
   SWB->( DBSetOrder(1) )
   WorkInv->( DBGoTop() )
   Do While !WorkInv->( EoF() )
      If WorkInv->MARCA == cMarca
         If lEFFTpMod  .And.  WorkInv->EF3_ORIGEM == "SWB"
            SWB->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,xFilial("SWB"))+WorkInv->EF3_HAWB+WorkInv->EF3_PO_DI+WorkInv->EF3_INVIMP+WorkInv->EF3_FORN+WorkInv->EF3_LOJAFO+WorkInv->EF3_LINHA) ) //AAF 25/09/07 - Tratar multifiliais
            SWB->( MSUnLock() )
         Else
            EEQ->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,cFilEEQ)+WorkInv->EF3_PREEMB+WorkInv->EF3_PARC) ) //AAF 25/09/07 - Tratar multifiliais
            EEQ->( MSUnLock() )
         EndIf
      EndIf
      WorkInv->( DBSkip() )
   EndDo
   // **
   If cMod == IMP
      M->EF1_VL_MOE := nOldVlCont
   EndIf
EndIf

If cMod == IMP
   lAumVlCont := .F.
   nOldVlCont := M->EF1_VL_MOE
EndIf

Return .T.

*------------------------------*
Static Function InvMarca(lTodos)
//Manutenção: ACSJ - 12/01/2004
//Validação de Vinculação quando lTodos = .t.
*------------------------------*
Local cPreenche   := Space(Len(cMarca))
Local lResp := NIL
Local nSaldoCtr
Private lStop:=.F., cMens:="", dDtEmba

If lTodos
   EEQ->( DBSetOrder(1) )
   SWB->( DBSetOrder(1) )
   WorkInv->(dbGoTop())
   If WorkInv->MARCA <> cMarca
      cPreenche := cMarca
   EndIf
   //MFR 05/10/2021 OSSME-6276
   nSaldoCtr := if (M->EF1_TP_FIN=="02",M->EF1_VL_MOE - EX401EvSum("600","EF3",xFilial("EF3")+"E" + M->EF1_CONTRA + M->EF1_BAN_FI + M->EF1_PRACA + M->EF1_SEQCNT,.T.),M->EF1_SLD_PM)
   Do While !WorkInv->(EOF())
      If EEC->(dbSeek(xFilial("EEC")+WorkInv->EF3_PREEMB))
         dDtEmba := EEC->EEC_DTEMBA
      Else
         dDtEmba := dDataGeral
      EndIf

      //FSM - 04/10/2012
      If !EX400ValAdiant()
         WorkInv->( DBSkip() )
         Loop
      EndIf
      If If(Empty(WorkInv->MARCA), EX400ChkItem(WorkInv->EF3_PREEMB), .T.) .and. dDataGeral >= dDtEmba
         // ** PLB 21/07/06 - Tratamento Multi-Usuario
         If lEFFTpMod  .And.  WorkInv->EF3_ORIGEM == "SWB"
            SWB->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,xFilial("SWB"))+WorkInv->EF3_HAWB+WorkInv->EF3_PO_DI+WorkInv->EF3_INVIMP+WorkInv->EF3_FORN+WorkInv->EF3_LOJAFO+WorkInv->EF3_LINHA) ) //AAF 25/09/07 - Tratar multifiliais
            If Empty(cPreenche)
               SWB->( MSUnLock() )
            Else
               If !SoftLock("SWB")
                  WorkInv->( DBSkip() )
                  Loop
               EndIf
            EndIf
         Else
            EEQ->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,cFilEEQ)+WorkInv->EF3_PREEMB+WorkInv->EF3_PARC) )//AAF 25/09/07 - Tratar multifiliais
            If Empty(cPreenche)
               EEQ->( MSUnLock() )
            Else
               If !SoftLock("EEQ")
                  WorkInv->( DBSkip() )
                  Loop
               EndIf
            EndIf
         EndIf
         // **
         // ** PLB - Verifica se Invoice esta Pre-Vinculada
         If Empty(WorkInv->MARCA)  .And.  cMod == EXP  .And.  EF6->( DBSeek(cFilEF6+WorkInv->EF3_PREEMB+WorkInv->EF3_INVOIC+WorkInv->EF3_PARC) )
            If !MsgYesNo(STR0100+AllTrim(WorkInv->EF3_INVOIC)+", "+STR0170+AllTrim(WorkInv->EF3_PARC)+EX401STR(35)+AllTrim(EF6->EF6_CONTRA)+IIF(lTemChave,","+EX401STR(37)+AllTrim(EF6->EF6_BANCO)+","+EX401STR(38)+AllTrim(EF6->EF6_PRACA),"")+IIF(lEFFTpMod,","+EX401STR(39)+AllTrim(EF6->EF6_SEQCNT),"")+"."+CHR(13)+CHR(10)+EX401STR(36)+"?")  //"Invoice: " # "Parcela" # " esta Pre-Vinculada ao Contrato " # "Banco" # "Praca" # "Sequencia" # "Confirma a Vinculacao"
               WorkInv->( DBSkip() )
               Loop
            EndIf
         EndIf
         // **
         WorkInv->(RecLock("WorkInv",.F.))
         WorkInv->MARCA := cPreenche
         If Empty(cPreenche)
            If cMod == IMP  .And.  lAumVlCont
               M->EF1_VL_MOE -= WorkInv->VINCULADO
               If M->EF1_VL_MOE == nOldVlCont
                  lAumVlCont := .F.
               EndIf
            EndIf
            nVincTot -= WorkInv->VINCULADO
            //MFR-2 OSSME-6276 07/10/2021
            nSaldoRest          += WorkInv->VINCULADO
            WorkInv->EF3_VL_INV := WorkInv->VL_ORI
            WorkInv->DT_VINC    := CtoD(Space(8))
            WorkInv->TX_VINC    := 0
            WorkInv->VINCULADO  := 0
            WorkInv->VL_VINC    := WorkInv->VL_ORI
            
         Else
            If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"VALIDA_MARCA_TODAS_INVOICES"),)
            If lStop
               WorkInv->MARCA := Space(2)
               WorkInv->(dbSkip())
               Loop
            EndIf

            // ** PLB 30/10/06
            If WorkInv->EF3_MOE_IN != M->EF1_MOEDA
               If lAltTx
                  nTaxaVinc := GetValInv(.T.)
               Else
                  nTaxaVinc := IIF(Empty(WorkInv->TX_VINC),BuscaTaxa(WorkInv->EF3_MOE_IN,IIF(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC),,.F.,.T.,,cTX_100),WorkInv->TX_VINC)
               EndIf
               nValFin   := ( WorkInv->VL_VINC * nTaxaVinc ) / nTaxaGeral
            Else
               nTaxaVinc := IIF(Empty(WorkInv->TX_VINC),nTaxaGeral,WorkInv->TX_VINC)
               nValFin   := WorkInv->VL_VINC
            EndIf
            // **

            // ** GFC - Pré-Pagamento/Securitização
            If lPrePag .AND. M->EF1_CAMTRA == "1"//lPrePag .and. M->EF1_TP_FIN $ ("03/04")
               nOrd:=WorkEF3->(IndexOrd())
               WorkEF3->(dbSetOrder(2))

               //Posiciona na primeira parcela em aberto
               nSaldoVin := EXPosPrePag("WorkEF3",M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,.T.,cTipoVinc,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))

               //Caso o valor a vincular seja maior que o saldo, verifica se pode deduzir da próxima
               //If EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,WorkInv->VL_VINC,If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC)) > nSaldoVin //WorkInv->VL_VINC > nSaldoVin
               //If IIF(WorkInv->EF3_MOE_IN!=M->EF1_MOEDA,(WorkInv->VL_VINC*IIF(Empty(WorkInv->TX_VINC),BuscaTaxa(WorkInv->EF3_MOE_IN,IIF(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC),,.F.,.T.,,cTX_100),WorkInv->TX_VINC))/nTaxaGeral,WorkInv->VL_VINC) > nSaldoVin
               If nValFin > nSaldoVin
                  WorkEF3->(dbSkip())

                  If !WorkEF3->(EOF()) .and. If(cTipoVinc=="1",WorkEF3->EF3_CODEVE==EV_PRINC_PREPAG,Left(WorkEF3->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2)) .and.;
                  WorkEF3->EF3_VL_MOE - (nValFin - nSaldoVin) < 0
                  //WorkEF3->EF3_VL_MOE - (EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,WorkInv->VL_VINC,If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC)) - nSaldoVin) < 0
                     WorkInv->MARCA := Space(2)
                     WorkInv->(dbSkip())
                     Loop
                  EndIf
               EndIf
               WorkEF3->(dbSetOrder(nOrd))
            EndIf
            // **

            //If (nVincTot + EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,WorkInv->VL_VINC,If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC))) > M->EF1_SLD_PM
            //MFR 05/10/2021 OSSME-6276
            If (nVincTot + nValFin) > nSaldoCtr
               MsgInfo( STR0129 + WORKINV->EF3_INVOIC + STR0130 + ;
                       Transform( ( nSaldoCtr - nVincTot ), AVSX3("EF1_SLD_PM",6) ) )   // ACSJ - 12/01/2004
               WorkInv->MARCA := Space(2)
               Exit
			ElseIf !Empty(M->EF1_DT_CTB) .AND. !Empty(M->EF1_DT_JUR) .AND. M->EF1_DT_CTB <> M->EF1_DT_JUR .AND.;
			If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC) < M->EF1_DT_CTB .AND.;
			if(ValType(lResp)=="U",!(lResp:=MsgYesNo("Este contrato foi contabilizado em "+TransForm(M->EF1_DT_CTB,"@D")+". Tem certeza que deseja vincular uma invoice com data anterior?")),!lResp)
               WorkInv->MARCA := Space(2)
               Exit
            Else
               //nVincTot           += EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,WorkInv->VL_VINC,If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC)) //WorkInv->VL_VINC
               //WorkInv->TX_VINC   := If(Empty(WorkInv->TX_VINC), IIF(WorkInv->EF3_MOE_IN != M->EF1_MOEDA,BuscaTaxa(WorkInv->EF3_MOE_IN,dDataGeral,,.F.,.T.,,cTX_100),nTaxaGeral), WorkInv->TX_VINC)  // PLB
               //WorkInv->VINCULADO := EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,WorkInv->VL_VINC,If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC)) //WorkInv->VL_VINC
               nVincTot           += nValFin    // PLB 30/10/06
               WorkInv->TX_VINC   := nTaxaVinc  // PLB 30/10/06
               WorkInv->VINCULADO := nValFin    // PLB 30/10/06
               WorkInv->DT_VINC   := If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC)
               WorkInv->VL_VINC   := 0.00
               //MFR-2 OSSME-6276 07/10/2021
               nSaldoRest         -= nValFin
	        Endif
	        If WorkInv->DT_VEN > M->EF1_DT_VEN
               cMens += STR0122+" "+Alltrim(WorkInv->EF3_INVOIC)+" "+STR0170+Alltrim(WorkInv->EF3_PARC)+" "+STR0171+Chr(10)+Chr(13) //"Invoice" # "Parcela " # "possui data de vencimento maior que a data de vencimento do contrato"
            EndIf
         Endif
         WorkInv->(msUnlock())
      Endif
      WorkInv->(dbSkip())
   EndDo
Else
   If WorkInv->MARCA <> cMarca
      cPreenche := cMarca
   EndIf
   WorkInv->(RecLock("WorkInv",.F.))
   WorkInv->MARCA := cPreenche
   If Empty(cPreenche)
      // ** PLB 21/07/06 - Tratamento Multi-Usuario
      If lEFFTpMod  .And.  WorkInv->EF3_ORIGEM == "SWB"
         SWB->( DBSetOrder(1) )
         SWB->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,xFilial("SWB"))+WorkInv->EF3_HAWB+WorkInv->EF3_PO_DI+WorkInv->EF3_INVIMP+WorkInv->EF3_FORN+WorkInv->EF3_LOJAFO+WorkInv->EF3_LINHA) ) //AAF 25/09/07 - Tratar multifiliais
         SWB->( MSUnLock() )
      Else
         EEQ->( DBSetOrder(1) )
         EEQ->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,cFilEEQ)+WorkInv->EF3_PREEMB+WorkInv->EF3_PARC) )//AAF 25/09/07 - Tratar multifiliais
         EEQ->( MSUnLock() )
      EndIf
      // **
      If cMod == IMP  .And.  lAumVlCont
         if WorkInv->Vinculado > (nOldVlCont-nJaVinc)           
               M->EF1_VL_MOE := nOldVlCont           
         else
            M->EF1_VL_MOE -= WorkInv->VINCULADO
         endif

         If M->EF1_VL_MOE == nOldVlCont
            lAumVlCont := .F.
         EndIf
      EndIf
      nVincTot -= WorkInv->Vinculado
      // ** GFC - 30/06/05
      if cMod == IMP .And. WorkInv->Vinculado > (nOldVlCont-nJaVinc)   
            nSaldoRest := (nOldVlCont-nJaVinc)
      else
         nSaldoRest += WorkInv->Vinculado
      endif
      If cMod == EXP  .And.  lPrePag .AND. M->EF1_CAMTRA == "1" //Pré-Pagamento / Securitização //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
         If (nSaldoRest - WorkInv->Vinculado) < 0 .and. nSaldoRest >= 0
            oSaySld:Hide()
            oSaySld:Refresh()
         EndIf
      EndIf
      oGetSld:Refresh()
      // **
      WorkInv->EF3_VL_INV := WorkInv->VL_ORI
      WorkInv->VL_VINC    := ( WorkInv->VL_VINC + EX400Conv(M->EF1_MOEDA,WorkInv->EF3_MOE_IN,WorkInv->VINCULADO,If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC)) )
      WorkInv->VINCULADO  := 0.00
      WorkInv->DT_VINC    := CtoD(Space(8))
      WorkInv->TX_VINC    := 0.00
   Else
      If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"VALIDA_MARCA_INVOICE"),)
      If lStop
         WorkInv->MARCA := Space(2)
      Else
         If WorkInv->DT_VEN > M->EF1_DT_VEN
            MsgInfo(STR0122+" "+Alltrim(WorkInv->EF3_INVOIC)+" "+STR0170+Alltrim(WorkInv->EF3_PARC)+" "+STR0171) //"Invoice" # "Parcela " # "possui data de vencimento maior que a data de vencimento do contrato"
         EndIf
      EndIf
   Endif
   WorkInv->(msUnlock())
EndIf

If !Empty(cMens)
   MsgInfo(cMens)
EndIf

Return .T.

*-------------------------------------*
Static Function GetValInv(lMarcaTodas)
*-------------------------------------*
Local nOpcao:=0, oDlgAD
Local nC1:=45, nL1:=23
Local lGet := M->EF1_CAMTRA = "1" //.and. M->EF1_LIQFIX = "2"  //PLB 17/02/06 - Campo EF1_LIQFIX excluido do Dicionario
Private nValInv:=WorkInv->EF3_VL_INV, dDataRec := WorkInv->EF3_DT_FIX
If lMarcaTodas == NIL
   lMarcaTodas := .F.
EndIf
Private dDataVinc:=If(Empty(WorkInv->DT_VINC), dDataGeral, WorkInv->DT_VINC)
Private nTaxaVinc:=If(Empty(WorkInv->TX_VINC), IIF(lMarcaTodas,BuscaTaxa(WorkInv->EF3_MOE_IN,dDataVinc,,.F.,.T.,,cTX_100),nTaxaGeral), WorkInv->TX_VINC)

// ** PLB 30/10/06 - Variaveis usadas quando a moeda da invoice for diferente da moeda do contrato
Private lMEDif := M->EF1_MOEDA != WorkInv->EF3_MOE_IN   ,;
        cMEInv   := WorkInv->EF3_MOE_IN                 ,;
        cMEFin   := M->EF1_MOEDA                        ,;
        nTaxaFin := nTaxaGeral                          ,;
        nValFin  := ( nValInv * nTaxaVinc ) / nTaxaFin
// **
Private dEntrega := dEntrGeral  // FSY 11/04/2013

If lGet
   nL1 := 21
EndIf

// Abate a Comissao do Agente
If WorkInv->TIPCOM = '2'   // Conta Gráfica
   nValInv := WorkInv->VL_VINC   //EF3_VL_INV - WorkInv->VALCOM
   nValFin := ( nValInv * nTaxaVinc ) / nTaxaFin   // PLB 30/10/06
Endif

If EF3->(FieldPos('EF3_DTDOC')) > 0// FSY - 17/04/2013
   If(!Empty(WorkInv->DTCE).AND.dDataVinc>WorkInv->DTCE,dDataVinc:=WorkInv->DTCE,)
EndIf

DEFINE MSDIALOG oDlgAD TITLE IIF(lMarcaTodas,STR0100+AllTrim(WorkInv->EF3_INVOIC)+" - "+STR0170+AllTrim(WorkInv->EF3_PARC),STR0066+If(lGet,STR0067,STR0068)) ; //"Invoice: " ### "Parcela: " ###     -   "Entre com o"###"s Dados"###" Valor da Invoice"
       FROM 12,05 TO 31,90 OF oMainWnd

   //If lMEDif  // PLB 30/10/06 - Controle de Taxas quando Moeda diferente entre Invoie e Contrato

      //MCF 08/01/2016 - Alinhamento de objetos na tela.
      @0.3,01 TO 2.9,41 Label AllTrim(EX401STR(0110))+IIF(lGet,"s","") of oDlgAD  //"Data"

      @0.9,02 SAY   STR0081  of oDlgAD    //"Data da Vinculação"
      @0.9,10 MSGET dDataVinc PICT AVSX3("EF3_DT_FIX",6) Valid EX400Valid("dDataVinc") When !lMarcaTodas SIZE 60,8 HASBUTTON

      If lGet
         @2,23 SAY AVSX3("EF3_DT_FIX",5) of oDlgAD
         @2,31 MSGET dDataRec PICT AVSX3("EF3_DT_FIX",6) When !lMarcaTodas SIZE 60,8 HASBUTTON
      EndIf

      If EF3->(FieldPos('EF3_DTDOC')) > 0// FSY - 17/04/2013
         @ 0.9,23  SAY AVSX3('EF3_DTDOC',AV_TITULO) Of oDlgAD
         @ 0.9,31  MsGet dEntrega PICT AVSX3('EF3_DTDOC',AV_PICTURE) WHEN .T. Size 60,6 HASBUTTON
         nAdCol := 1
      EndIf

      @3.0,01 TO 8,20 Label EX401STR(0160) of oDlgAD  //"Dados da Invoice"

      @4.0,02 SAY   EX401STR(0161)  of oDlgAD  //"Moeda da Invoice"
      @4.0,10 MSGET cMEInv PICT AVSX3("EF1_MOEDA",6) WHEN .F. SIZE 60,8

      @5.0,02 SAY   STR0082  of oDlgAD    //"Taxa da Vinculação"
      @5.0,10 MSGET nTaxaVinc PICT AVSX3("EF3_TX_MOE",6) Valid EX400Valid("nTaxaVinc") SIZE 60,8 HASBUTTON

      @6.0,02 SAY   STR0086 of oDlgAD //"Vl. da Invoice"
      @6.0,10 MSGET nValInv PICT AVSX3("EF3_VL_INV",6) Valid EX400Valid("nValInv") When !lMarcaTodas SIZE 60,8 HASBUTTON

      @3.0,22 TO 8,41 Label EX401STR(0162) of oDlgAD  //"Dados do Contrato"

      @4.0,23 SAY   EX401STR(0163)  of oDlgAD  //"Moeda do Contrato"
      @4.0,31 MSGET cMEFin PICT AVSX3("EF1_MOEDA",6) WHEN .F. SIZE 60,8

      @5.0,23 SAY   EX401STR(0164)  of oDlgAD  //"Taxa ME Contrato"
      @5.0,31 MSGET nTaxaFin PICT AVSX3("EF3_TX_MOE",6) Valid EX400Valid("nTaxaFin") When lMEDif .And. !lMarcaTodas SIZE 60,8 HASBUTTON

      @6.0,23 SAY   EX401STR(0165) of oDlgAD  //"Valor ME Contrato"
      @6.0,31 MSGET nValFin PICT AVSX3("EF3_VL_INV",6) WHEN .F. SIZE 60,8 HASBUTTON

      DEFINE SBUTTON FROM 120,135 TYPE 1 ACTION IIF(IIF(lMarcaTodas,.T.,EX400Valid("nValInv").And.EX400ValAdiant()),(nOpcao:=1,oDlgAD:End()),) ENABLE OF oDlgAD //FSM - 17/10/2012
      If !lMarcaTodas
         DEFINE SBUTTON FROM 120,175 TYPE 2 ACTION (nOpcao:=0,oDlgAD:End()) ENABLE OF oDlgAD
      EndIf

   //Else
   /*
      @01,02 SAY   STR0081  of oDlgAD    //"Data da Vinculação"
      @01,08 MSGET dDataVinc PICT AVSX3("EF3_DT_FIX",6) Valid EX400Valid("dDataVinc") SIZE 60,8

      @02,02 SAY   STR0082  of oDlgAD    //"Taxa da Vinculação"
      @02,08 MSGET nTaxaVinc PICT AVSX3("EF3_TX_MOE",6) Valid EX400Valid("nTaxaVinc") SIZE 60,8

      @03,02 SAY   STR0086 of oDlgAD //"Vl. da Invoice"
      @03,08 MSGET nValInv PICT AVSX3("EF3_VL_INV",6) Valid EX400Valid("nValInv") SIZE 60,8

      If lGet
         @04,02 SAY AVSX3("EF3_DT_FIX",5) of oDlgAD
         @04,08 MSGET dDataRec PICT AVSX3("EF3_DT_FIX",6) SIZE 60,8
      EndIf

      DEFINE SBUTTON FROM If(lGet,70,60),45 TYPE 1 ACTION If(EX400Valid("nValInv"),(nOpcao:=1,oDlgAD:End()),) ENABLE OF oDlgAD
      DEFINE SBUTTON FROM If(lGet,70,60),90 TYPE 2 ACTION (nOpcao:=0,oDlgAD:End()) ENABLE OF oDlgAD

   EndIf   */

ACTIVATE MSDIALOG oDlgAD CENTERED

//ACTIVATE MSDIALOG oDlgAD ON INIT EnchoiceBar(oDlgAD,{||nOpcao:=1,oDlgAD:End()},{||nOpcao:=0,oDlgAD:End()}) CENTERED

If nOpcao == 1  .And.  !lMarcaTodas
   // ** PLB 21/07/06 - Tratamento Multi-Usuario
   If lEFFTpMod  .And.  WorkInv->EF3_ORIGEM == "SWB"
      SWB->( DBSetOrder(1) )
      SWB->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,xFilial("SWB"))+WorkInv->EF3_HAWB+WorkInv->EF3_PO_DI+WorkInv->EF3_INVIMP+WorkInv->EF3_FORN+WorkInv->EF3_LOJAFO+WorkInv->EF3_LINHA) ) //AAF 25/09/07 - Tratar multifiliais
      If !SoftLock("SWB")
         Return .F.
      EndIf
   Else
      EEQ->( DBSetOrder(1) )
      //EEQ->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,cFilEEQ)+WorkInv->EF3_PREEMB+WorkInv->EF3_PARC) ) //AAF 25/09/07 - Tratar multifiliais
      EEQ->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,cFilEEQ)+ AvKey(WorkInv->EF3_PREEMB,"EEQ_PREEMB")+ AvKey(WorkInv->EF3_PARC,"EEQ_PARC")) ) //MCF - 07/04/2016 - Adicionado AvKey
      If !SoftLock("EEQ")
         Return .F.
      EndIf
   EndIf
   // **
   // ** PLB - Verifica se Invoice esta Pre-Vinculada
   If cMod == EXP  .And.  EF6->( DBSeek(cFilEF6+WorkInv->EF3_PREEMB+WorkInv->EF3_INVOIC+WorkInv->EF3_PARC) )
      If !MsgYesNo(STR0100+AllTrim(WorkInv->EF3_INVOIC)+", "+STR0170+AllTrim(WorkInv->EF3_PARC)+EX401STR(35)+AllTrim(EF6->EF6_CONTRA)+IIF(lTemChave,","+EX401STR(37)+AllTrim(EF6->EF6_BANCO)+","+EX401STR(38)+AllTrim(EF6->EF6_PRACA),"")+IIF(lEFFTpMod,","+EX401STR(39)+AllTrim(EF6->EF6_SEQCNT),"")+"."+CHR(13)+CHR(10)+EX401STR(36)+"?")  //"Invoice: " # "Parcela" # " esta Pre-Vinculada ao Contrato " # "Banco" # "Praca" # "Sequencia" # "Confirma a Vinculacao"
         Return .F.
      EndIf
   EndIf
   // **

   //** AAF 26/01/2015
   If !Empty(M->EF1_DT_CTB) .AND. !Empty(M->EF1_DT_JUR) .AND. M->EF1_DT_CTB <> M->EF1_DT_JUR .AND. dDataVinc <= M->EF1_DT_CTB .AND.;
   !MsgYesNo(STR0296 + TransForm(M->EF1_DT_CTB,"@D") + ". " + STR0297,STR0098)//"Este contrato foi contabilizado em "#### "Tem certeza que deseja vincular uma invoice com data igual ou anterior a esta contabilização?"###"Atenção"
      Return .F.
   EndIf
   //**

   WorkInv->(RecLock("WorkInv",.F.))
   WorkInv->EF3_VL_INV := nValInv
   WorkInv->EF3_DT_FIX := dDataRec
   WorkInv->DT_VINC    := dDataVinc
   WorkInv->TX_VINC    := nTaxaVinc
   WorkInv->VINCULADO  := nValFin //EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc) //nValInv
   WorkInv->VL_VINC    := ( WorkInv->VL_VINC - nValInv )

   If WorkInv->(FieldPos("EF3_DTDOC")) > 0// FSY - 17/04/2013
      WorkInv->EF3_DTDOC    := dEntrega
   EndIf

   WorkInv->(msUnlock())
   nVincTot += nValFin  //EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc) // GFC - 27/07/05 - nValInv
   InvMarca(.F.)

   // ** GFC - 30/06/05
   if nSaldoRest - nValFin < 0
      nSaldoRest := 0
   else
      nSaldoRest -= nValFin  //EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc) // GFC - 27/07/05 - nValInv
   endif
   If cMod == EXP  .And.  lPrePag .AND. M->EF1_CAMTRA == "1" //Pré-Pagamento / Securitização //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
      //If (nSaldoRest + EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,nValInv,dDataVinc)) >= 0 .and. nSaldoRest < 0
      If (nSaldoRest + nValFin) >= 0 .and. nSaldoRest < 0  // PLB 30/10/06
         oSaySld:Show()
         oSaySld:Refresh()
      EndIf
   EndIf
   oGetSld:Refresh()
   // **

EndIf

Return IIF(lMarcaTodas,nTaxaVinc,.T.)

*---------------------------------*
Static Function GrvEventos(cTpVinc)
*---------------------------------*
Local nOrd, nRec, aCopia:={}, ni, cParc:="", cFilOri:="", cInvoice:="", nPos:=0
Local nTxConv := 0
If(cTpVinc=NIL,cTpVinc:="1",)

ProcRegua(WorkInv->(EasyRecCount()))

dbSelectArea("WorkInv")
WorkInv->(DbGotop())
WorkEF3->(dbSetOrder(2))
Do While !WorkInv->(EOF())
   IncProc(STR0069+Alltrim(WorkInv->EF3_INVOIC)) //"Gravando Eventos para Invoice "

   If WorkInv->MARCA == cMarca
      If Empty(WorkInv->DT_VINC)
         WorkInv->DT_VINC    := dDataGeral
         WorkInv->TX_VINC    := nTaxaGeral
      Endif

      // PLB 30/10/06
      //If WorkInv->EF3_VL_INV > WorkInv->VL_VINC
         //WorkInv->EF3_VL_INV := EX400Conv(M->EF1_MOEDA,WorkInv->EF3_MOE_IN,WorkInv->VINCULADO,WorkInv->DT_VINC) //WorkInv->VINCULADO  // A. Caetano Jr. - 07/01/2004
      //Endif

      // ** GFC - Pré-Pagamento/Securitização
      If lPrePag .AND. M->EF1_CAMTRA == "1"// .and. cTpVinc=="2" //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
         nOrd:=WorkEF3->(IndexOrd())

         //Posiciona na primeira parcela em aberto
         nSaldoVin := EXPosPrePag("WorkEF3",M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,.T.,cTpVinc,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))

         If nSaldoVin > 0
            //Caso o valor a vincular seja maior que o saldo vai vinculando as próximas parcelas
            //If WorkInv->EF3_VL_INV > nSaldoVin
            If WorkInv->VINCULADO > nSaldoVin
               For ni := 1 To WorkInv->(FCount())
                  aAdd(aCopia,WorkInv->&(FieldName(ni)))
               Next ni
               nRec := WorkInv->(RecNo())
               WorkInv->(RecLock("WorkInv",.T.))
               For ni := 1 To WorkInv->(FCount())
                  WorkInv->&(FieldName(ni)) := aCopia[ni]
               Next ni
               aCopia := {}
               //WorkInv->EF3_VL_INV := WorkInv->EF3_VL_INV - nSaldoVin
               //WorkInv->VINCULADO  := EX400Conv(WorkInv->EF3_MOE_IN,M->EF1_MOEDA,WorkInv->EF3_VL_INV,WorkInv->DT_VINC) //WorkInv->EF3_VL_INV
               // PLB 30/10/06
               nTxConv := WorkInv->( VINCULADO / EF3_VL_INV )
               WorkInv->EF3_VL_INV := WorkInv->EF3_VL_INV - (nSaldoVin*WorkInv->(EF3_VL_INV/VINCULADO))
               WorkInv->VINCULADO  := WorkInv->EF3_VL_INV * nTxConv
               If Empty(cParc) .or. cFilOri <> WorkInv->EF3_FILORI .or. cInvoice <> If(cMod <> IMP,WorkInv->EF3_INVOIC,WorkInv->EF3_INVIMP)
                  If cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ"
                     WorkInv->EF3_PARC := EX401EEQParc("EEQ",SomaIt(WorkInv->EF3_PARC),WorkInv->EF3_PREEMB)
                     cParc    := WorkInv->EF3_PARC
                     cInvoice := WorkInv->EF3_INVOIC
                  ElseIf WorkInv->EF3_ORIGEM == "SWB"
                     WorkInv->EF3_LINHA := EX401SWBParc("SWB",SomaIt(WorkInv->EF3_LINHA),WorkInv->(EF3_HAWB+EF3_PO_DI+EF3_INVIMP+EF3_FORN+EF3_LOJAFO+EF3_LINHA))
                     cParc    := WorkInv->EF3_LINHA
                     cInvoice := WorkInv->EF3_INVIMP
                  EndIf

                  cFilOri  := WorkInv->EF3_FILORI
               Else
                  WorkInv->EF3_PARC := SomaIt(cParc)
                  cParc := WorkInv->EF3_PARC  // ** PLB 24/05/06 - Atualiza a variavel cParc para que continue a sequencia das parcelas
               EndIf
               //WorkInv->EF3_PARC   := SomaIt(WorkInv->EF3_PARC)
               WorkInv->TRB_ALI_WT := "EF3"
               WorkInv->TRB_REC_WT := 0
               WorkInv->(msUnlock())

               WorkInv->(dbGoTo(nRec))
               //WorkInv->EF3_VL_INV := nSaldoVin
               WorkInv->EF3_VL_INV := nSaldoVin * WorkInv->( EF3_VL_INV / VINCULADO )  // PLB 30/10/06
               WorkInv->VINCULADO  := nSaldoVin
            EndIf

            WorkEF3->(dbSetOrder(nOrd))
         EndIf
      EndIf
      // **

      If !(lPrePag .AND. M->EF1_CAMTRA == "1" .and. nSaldoVin<=0) //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
         EX400GrvEventos(M->EF1_CONTRA,If(!lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ",WorkInv->EF3_INVOIC,WorkInv->EF3_INVIMP),If(!lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ",WorkInv->EF3_PREEMB,WorkInv->EF3_HAWB),WorkInv->EF3_VL_INV,;
         dDataBase,WorkInv->EF3_MOE_IN,If(!lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ",WorkInv->EF3_PARC  ,WorkInv->EF3_LINHA ),M->EF1_MOEDA,"M","WorkEF3","MANUT1",,WorkInv->TX_VINC,;
         WorkInv->DT_VINC,If(lMulTiFil,WorkInv->EF3_FILORI,Nil),If(lTemChave,M->EF1_BAN_FI,),;
         If(lTemChave,M->EF1_PRACA,),cTpVinc,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,),If(lEFFTpMod,WorkInv->EF3_ORIGEM,),If(cMod == IMP,WorkInv->EF3_FORN,),If(cMod == IMP,WorkInv->EF3_LOJAFO,),If(cMod == IMP,WorkInv->EF3_PO_DI,),;
         WorkInv->((EF3_VL_INV*TX_VINC)/VINCULADO))  // PLB 30/10/06
      Else
         MsgInfo(STR0243+Alltrim(EF3->EF3_MOE_IN)+" "+Alltrim(Transf(WorkInv->EF3_VL_INV,AVSX3("EF3_VL_INV",6)))+STR0244+Alltrim(WorkInv->EF3_INVOIC)+STR0245) //"Um valor de " # " da fatura " # " não foi vinculado pois as parcelas foram esgotadas."
         // ** PLB 24/07/06 - Tratamento Multi-Usuario
         If lEFFTpMod  .And.  WorkInv->EF3_ORIGEM == "SWB"
            If SWB->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,xFilial("SWB"))+WorkInv->EF3_HAWB+WorkInv->EF3_PO_DI+WorkInv->EF3_INVIMP+WorkInv->EF3_FORN+WorkInv->EF3_LOJAFO+WorkInv->EF3_LINHA) ) //AAF 25/09/07 - Tratar multifiliais
               SWB->( MSUnLock() )
            EndIf
            nPos := aScan( aSWBLockList , { |x| x == SWB->( RecNo() ) } )
            If nPos > 0
               aDel(aSWBLockList,nPos)
               aSize(aSWBLockList,Len(aSWBLockList)-1)
            EndIf
         Else
            If EEQ->( DBSeek(IIF(lMultiFil,WorkInv->EF3_FILORI,cFilEEQ)+WorkInv->EF3_PREEMB+WorkInv->EF3_PARC) ) //AAF 25/09/07 - Tratar multifiliais
               EEQ->( MSUnLock() )
            EndIf
            nPos := aScan( aEEQLockList , { |x| x == EEQ->( RecNo() ) } )
            If nPos > 0
               aDel(aEEQLockList,nPos)
               aSize(aEEQLockList,Len(aEEQLockList)-1)
            EndIf
         EndIf
         // **
      EndIf

   EndIf

   WorkInv->(dbSkip())
EndDo

WorkEF3->(dbSetOrder(ORDEM_BROWSE))
WorkEF3->(dbGoTop())
oMark:oBrowse:Refresh()

Return .T.

*--------------------------------------------------*
Function BuscaEF3Seq(cAlias,cContrato,cBanco,cPraca,cTpModu,cSeqCon)
*--------------------------------------------------*
Local cSeq, nOldRec, nOldOrd
nOrdSX3:= SX3->( IndexOrd() )

SX3->( dbSetOrder(2) )

Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
                     SX3->(DBSeek("EF3_OBS"))    .and. SX3->(DBSeek("EF3_NROP"))

SX3->( dbSetOrder(nOrdSX3) )

If(cAlias=NIL,cAlias := "WorkEF3",)
nOldRec := (cAlias)->(RecNo())
nOldOrd := (cAlias)->(IndexOrd())

If cAlias=="WorkEF3"
   (cAlias)->(dbSetOrder(1))
   (cAlias)->(dbGoBottom())
   cSeq := StrZero(Val((cAlias)->EF3_SEQ) + 1,4,0)
Else
   (cAlias)->(dbSetOrder(4))
   If (cAlias)->(avSeekLast(xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContrato+If(lTemChave,cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")))  //(cAlias)->EF3_CONTRA == cContrato
      cSeq := StrZero(Val((cAlias)->EF3_SEQ) + 1,4,0)
   Else
      cSeq := StrZero(1,4,0)
   EndIf
EndIf

(cAlias)->(dbGoTo(nOldRec))
(cAlias)->(dbSetOrder(nOldOrd))

Return cSeq

*---------------------------------------------------------*
Function EX400Conv(cMoeda,cMoeda2,nVal,dData,lTaxaFiscal)
*---------------------------------------------------------*
Local nConvVal
If(dData=NIL,dData:=dDataBase,)
If(cMoeda=NIL,cMoeda:="",)
If(cMoeda2=NIL,cMoeda2:="",)
If(lTaxaFiscal=NIL,,lTaxaFiscal)
If cMoeda <> cMoeda2
   If !Empty(cMoeda2) .and. !Empty(cMoeda) .and. cMoeda2 <> MOEDA_REAIS   //De Moeda para Moeda
      nConvVal := nVal * BuscaTaxa(cMoeda,dData,,.F.,.T.,,cTX_100)
      nConvVal := nConvVal / BuscaTaxa(cMoeda2,dData,,.F.,.T.,,cTX_100)
   ElseIf Empty(cMoeda)                                                   //De Reais para Moeda
      nConvVal := nVal / BuscaTaxa(cMoeda2,dData,,.F.,.T.,,cTX_100)
   ElseIf cMoeda <> MOEDA_REAIS                                           //De Moeda para Reais
      nConvVal := nVal * BuscaTaxa(cMoeda,dData,,.F.,.T.,,cTX_100)
   Else
      nConvVal := nVal
   EndIf
Else
   nConvVal := nVal
EndIf

Return nConvVal

*---------------------------*
Static Function ValInvoices()
*---------------------------*
Local nSoma:=0 //, cInvoice := "", cProcesso := ""
Local lVerME := .T.  // PLB 30/10/06

EE9->(dbSetOrder(3))
ProcRegua(WorkInv->(EasyRecCount()))
WorkInv->(DbSetOrder(2))

If !lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ"
   WorkEF3->(DbSetOrder(2))
Else
   WorkEF3->(DbSetOrder(9))
EndIf
WorkInv->(dbGoTop())
Do While !WorkInv->(EOF())
   lVerME := .T.
   // Calcula Comissão
   IncProc(STR0083+Alltrim(WorkInv->EF3_PREEMB)+", "+STR0100+Alltrim(WorkInv->EF3_INVOIC)+".") //"Validando Invoice " # " do Processo "

   nSoma:=0
   If WorkInv->FI_TOT <> "N" .and. ( (( !lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ") .AND. WorkEF3->(dbSeek(EV_EMBARQUE+WorkInv->EF3_INVOIC+WorkInv->EF3_PARC))) .OR.;//If(!Empty(WorkInv->PARFIN),WorkInv->PARFIN,WorkInv->EF3_PARC)))
                                      (  lEFFTpMod .And.                 WorkInv->EF3_ORIGEM == "SWB"  .AND. WorkEF3->(dbSeek(EV_EMBARQUE+WorkInv->EF3_FORN+WorkInv->EF3_LOJAFO+WorkInv->EF3_INVIMP+WorkInv->EF3_LINHA))) )
      WorkInv->(DBDELETE())
      lVerME := .F.
   ElseIf WorkInv->FI_TOT == "N" .and. If(!lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ", WorkEF3->(dbSeek(EV_EMBARQUE+WorkInv->EF3_INVOIC+If(!Empty(WorkInv->PARFIN),WorkInv->PARFIN,WorkInv->EF3_PARC))),;
                                                                           WorkEF3->(dbSeek(EV_EMBARQUE+WorkInv->EF3_FORN+WorkInv->EF3_LOJAFO+WorkInv->EF3_INVIMP+If(!Empty(WorkInv->PARFIN),WorkInv->PARFIN,WorkInv->EF3_LINHA))) )
      If !lEFFTpMod .OR. cMod == EXP .OR. WorkInv->EF3_ORIGEM == "EEQ"
         Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE==EV_EMBARQUE .and.;
         WorkEF3->EF3_INVOIC==WorkInv->EF3_INVOIC .and. WorkEF3->EF3_PARC == If(!Empty(WorkInv->PARFIN),WorkInv->PARFIN,WorkInv->EF3_PARC)
            If WorkEF3->EF3_RECNO = 0
               nSoma += WorkEF3->EF3_VL_INV
            EndIf
            WorkEF3->(dbSkip())
         EndDo
      Else
         Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE==EV_EMBARQUE .and.;
         WorkEF3->EF3_INVIMP==WorkInv->EF3_INVIMP .and. WorkEF3->EF3_LINHA == If(!Empty(WorkInv->PARFIN),WorkInv->PARFIN,WorkInv->EF3_LINHA)
            If WorkEF3->EF3_RECNO = 0
               nSoma += WorkEF3->EF3_VL_INV
            EndIf
            WorkEF3->(dbSkip())
         EndDo
      EndIf

      If nSoma > 0
         WorkInv->VL_PAR -= nSoma
         If WorkInv->VL_PAR < 0.01
            WorkInv->(DBDELETE())
            lVerME := .F.
         Else
            WorkInv->EF3_VL_INV := WorkInv->VL_PAR
            WorkInv->VL_ORI     := WorkInv->VL_PAR
            If EE9->(dbSeek(xFilial("EE9")+WorkInv->EF3_PREEMB))
               WorkInv->DT_AVERB := EE9->EE9_DTAVRB
            EndIf
         EndIf
      ElseIf WorkInv->VL_PAR > 0
         WorkInv->EF3_VL_INV := WorkInv->VL_PAR
         WorkInv->VL_ORI     := WorkInv->VL_PAR
         If EE9->(dbSeek(xFilial("EE9")+WorkInv->EF3_PREEMB))
            WorkInv->DT_AVERB := EE9->EE9_DTAVRB
         EndIf
      EndIf
   ElseIf WorkInv->VL_PAR > 0
      WorkInv->EF3_VL_INV := WorkInv->VL_PAR
      WorkInv->VL_ORI     := WorkInv->VL_PAR
      If EE9->(dbSeek(xFilial("EE9")+WorkInv->EF3_PREEMB))
         WorkInv->DT_AVERB := EE9->EE9_DTAVRB
      EndIf
   Endif
   // ** PLB 30/10/06 - Array contendo as moedas das invoices quando forem diferentes da moeda do contrato
   If lVerME
      If WorkInv->EF3_MOE_IN != M->EF1_MOEDA  .And.  AScan(aMEDif,{|x| x==WorkInv->EF3_MOE_IN }) == 0
         AADD(aMEDif,WorkInv->EF3_MOE_IN)
      EndIf
   EndIf
   // **
   WorkInv->(dbSkip())
EndDo

WorkEF3->(dbSetOrder(ORDEM_BROWSE))
WorkInv->(dbGoTop())

Return .T.

*----------------------------------*
Static Function AtuEEQ(nTipo,cAlias)
*----------------------------------*
Local nRecAux:=0, nVlVolta:=0, nRecEF1, nOrdAux
If(cAlias=NIL,cAlias:="WorkEF3",)

// PLB 23/08/07
Private cFilOriAux := IIF(lMultiFil,(cAlias)->EF3_FILORI,xFilial("EEQ"))

If nTipo = INCLUIR
   If EEQ->(dbSeek(cFilOriAux + (cAlias)->EF3_PREEMB+(cAlias)->EF3_PARC)) //LRL 20/12/04 - Conceito MultiFil   EEQ->(dbSeek(xFilial("EEQ")+EF3->EF3_PREEMB+EF3->EF3_PARC))

      Do While !EEQ->(EOF()) .and. EEQ->EEQ_FILIAL == cFilOriAux .And. EEQ->EEQ_PREEMB==(cAlias)->EF3_PREEMB
         If EEQ->EEQ_PARC==(cAlias)->EF3_PARC  //If(lParFin .and. !Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARFIN,EEQ->EEQ_PARC)==(cAlias)->EF3_PARC
            nRecAux := EEQ->(RecNo())
         EndIf
         EEQ->(dbSkip())
      EndDo

      EEQ->(dbGoTo(nRecAux))

      // ** GFC - 29/09/05 - Quebra automática de parcelas de cambio
//      If (cAlias)->EF3_VL_INV < EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0) AJP 20/10/06
      If (cAlias)->EF3_VL_INV < AF200VLFCam("EEQ")
         EX401QuebraEEQ(AF200VLFCam("EEQ"),(cAlias)->EF3_VL_INV,cFilOriAux,EEQ->EEQ_PREEMB,EEQ->EEQ_NRINVO,EEQ->EEQ_PARC,nRecAux)
         EEQ->(dbGoTo(nRecAux))
      EndIf
      // **
      //NCF - 27/08/2014 - Fazer backup do EEQ caso seja atualização de referência a parcela de financiamento
      If lLogix
         AF200BkpInt("EEQ","EFF_MNCT_ALT",,{'EF1',EF1->(Recno())},,)
      EndIf

      EEQ->(RecLock("EEQ",.F.))
//      If (cAlias)->EF3_VL_INV < EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0) AJP 20/10/06
      If (cAlias)->EF3_VL_INV < AF200VLFCam("EEQ")
         If EEQ->EEQ_FI_TOT == "N"
            EEQ->EEQ_VL_PAR -= (cAlias)->EF3_VL_INV
         Else
            EEQ->EEQ_VL_PAR := AF200VLFCam("EEQ") - (cAlias)->EF3_VL_INV
            EEQ->EEQ_FI_TOT := "N"
         EndIf
      Else
         EEQ->EEQ_FI_TOT := "S"
      EndIf
      If lTemChave .and. Empty(EEQ->EEQ_BANC)
         //Alcir Alves - 03-11-05 - considerar o banco de movimentação nas vinculações - conforme chamado 020324
         if !empty(M->EF1_BAN_MO)
            EEQ->EEQ_BANC   := M->EF1_BAN_MO
            EEQ->EEQ_AGEN   := M->EF1_AGENMO
            EEQ->EEQ_NCON   := M->EF1_NCONMO
            If SA6->(DBSeek(xFilial("SA6")+M->EF1_BAN_MO))
               EEQ->EEQ_NOMEBC := SA6->A6_NOME
            Else
               EEQ->EEQ_NOMEBC := M->EF1_DES_MO
            EndIf
            //
         else
            EEQ->EEQ_BANC   := M->EF1_BAN_FI
            EEQ->EEQ_AGEN   := M->EF1_AGENFI
            EEQ->EEQ_NCON   := M->EF1_NCONFI
            If SA6->(DBSeek(xFilial("SA6")+M->EF1_BAN_FI))
               EEQ->EEQ_NOMEBC := SA6->A6_NOME
            Else
               EEQ->EEQ_NOMEBC := M->EF1_DES_FI
            EndIf
         endif
      EndIf
      EEQ->EEQ_NROP   := EF1->EF1_CONTRA
      // ** GFC - 04/10/05 - Gravar o Parfin do EEQ para toda vinculação pois o contábil utiliza
      If lParFin .and. Empty(EEQ->EEQ_PARFIN)
         //EEQ->EEQ_PARFIN := EEQ->EEQ_PARC
         EEQ->EEQ_PARFIN := (cAlias)->EF3_PARC
      EndIf
      // **

      // PLB 23/08/07 - Criado para Electrolux referente chamado 058136
      IIF(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"APOS_ATU_EEQ"),)

      EEQ->(msUnlock())
   EndIf
Else
   //If EEQ->(dbSeek(If(lMultiFil,(cAlias)->EF3_FILORI,xFilial("EEQ"))+(cAlias)->EF3_PREEMB+(cAlias)->EF3_PARC)) //LRL 20/12/04 If(lMultiFil,EF3_FILORI,xFilial("EEQ")) EEQ->(dbSeek(xFilial("EEQ")+(cAlias)->EF3_PREEMB+(cAlias)->EF3_PARC))
   // PLB 24/08/07 - Para verificação quando EEQ_PARFIN for diferente do EEQ_PARC
   nRecAux := 0
   EEQ->( DBSeek(cFilOriAux + (cAlias)->EF3_PREEMB) )
   Do While !EEQ->(EOF()) .and. EEQ->EEQ_FILIAL == cFilOriAux .And. EEQ->EEQ_PREEMB==(cAlias)->EF3_PREEMB
      If If(lParFin .and. !Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARFIN,EEQ->EEQ_PARC)==(cAlias)->EF3_PARC
         nRecAux := EEQ->(RecNo())
      EndIf
      EEQ->(dbSkip())
   EndDo
   If nRecAux > 0
      EEQ->(dbGoTo(nRecAux))
      nVlVolta:=(cAlias)->EF3_VL_INV
      Do While !EEQ->(BOF()) .and. EEQ->EEQ_FILIAL == cFilOriAux .And. EEQ->EEQ_PREEMB==(cAlias)->EF3_PREEMB .and. nVlVolta > 0
         //FSM - 05/10/2012
         lIsAdiantamento := EX401IsAdiant(EEQ->EEQ_NRINVO, EEQ->EEQ_PREEMB, EEQ->EEQ_PARC)

         If If(lParFin .and. !Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARFIN,EEQ->EEQ_PARC)==(cAlias)->EF3_PARC

            //NCF - 27/08/2014 - Fazer backup do EEQ caso seja atualização de referência a parcela de financiamento
            If lLogix
               AF200BkpInt("EEQ","EFF_MNCT_ALT",,{'EF1',EF1->(Recno())},,)
            EndIf

            EEQ->(RecLock("EEQ",.F.))
            If EEQ->EEQ_FI_TOT == "N"
               If EEQ->EEQ_VL - (EEQ->EEQ_VL_PAR + nVlVolta) <= 0
                  nVlVolta += EEQ->EEQ_VL_PAR
                  EEQ->EEQ_VL_PAR := EEQ->EEQ_VL  //+=
                  nVlVolta -= EEQ->EEQ_VL
               Else
                  EEQ->EEQ_VL_PAR += nVlVolta
                  nVlVolta := 0
               EndIf
               If EEQ->EEQ_VL == EEQ->EEQ_VL_PAR
                  EEQ->EEQ_FI_TOT := ""
                  EEQ->EEQ_VL_PAR := 0
                  If lParfin
                     EEQ->EEQ_PARFIN := ""
                  EndIf
               EndIf
            ElseIf EEQ->EEQ_FI_TOT == "S"
//               If (nVlVolta - (EEQ->EEQ_VL-If(EECFlags("FRESEGCOM"),EEQ->EEQ_CGRAFI-EEQ->EEQ_ADEDUZ,0))) < 0 AJP 20/10/06
               If (nVlVolta - (AF200VLFCam("EEQ"))) < 0
                  EEQ->EEQ_FI_TOT := "N"
                  EEQ->EEQ_VL_PAR := nVlVolta
                  nVlVolta := 0
               Else
                  EEQ->EEQ_FI_TOT := ""
                  EEQ->EEQ_VL_PAR := 0
                  If lParfin
                     EEQ->EEQ_PARFIN := ""
                  EndIf
                  nVlVolta -= AF200VLFCam("EEQ")//EEQ->EEQ_VL
               EndIf
            EndIf
            If lTemChave .and. Alltrim(EEQ->EEQ_NROP) == Alltrim(M->EF1_CONTRA) .and. cAlias=="EF3"
               nRecAux := EF3->(RecNo())
               nOrdAux := EF3->(IndexOrd())
               EF3->(dbSetOrder(3))
               If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,M->EF1_TPMODU,"")+EEQ->EEQ_NRINVO+If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARC,EEQ->EEQ_PARFIN)+EV_EMBARQUE))
                  Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and. EF3->EF3_INVOIC==EEQ->EEQ_NRINVO .and.;
                  EF3->EF3_PARC==If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARC,EEQ->EEQ_PARFIN) .and. EF3->EF3_CODEVE==EV_EMBARQUE
                     If EF3->(RecNo()) <> nRecAux
                        Exit
                     EndIf
                     EF3->(dbSkip())
                  EndDo
                  If !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and. EF3->EF3_INVOIC==EEQ->EEQ_NRINVO .and.;
                  EF3->EF3_PARC==If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARC,EEQ->EEQ_PARFIN) .and. EF3->EF3_CODEVE==EV_EMBARQUE
                     nRecEF1 := EF1->(RecNo())
                     EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA))
                     //Alcir Alves - 03-11-05 - considerar o banco de movimentação nas vinculações  - conforme chamado 020324
                     if !empty(EF1->EF1_BAN_MO)
                        EEQ->EEQ_BANC   := EF1->EF1_BAN_MO
                        EEQ->EEQ_AGEN   := EF1->EF1_AGENMO
                        EEQ->EEQ_NCON   := EF1->EF1_NCONMO
                        If SA6->(DBSeek(xFilial("SA6")+EF1->EF1_BAN_MO))
                           EEQ->EEQ_NOMEBC := SA6->A6_NOME
                        Else
                           EEQ->EEQ_NOMEBC := EF1->EF1_DES_MO
                        EndIf
                        //
                     else
                        EEQ->EEQ_BANC   := EF1->EF1_BAN_FI
                        EEQ->EEQ_AGEN   := EF1->EF1_AGENFI
                        EEQ->EEQ_NCON   := EF1->EF1_NCONFI
                        If SA6->(DBSeek(xFilial("SA6")+EF1->EF1_BAN_FI))
                           EEQ->EEQ_NOMEBC := SA6->A6_NOME
                        Else
                           EEQ->EEQ_NOMEBC := EF1->EF1_DES_FI
                        EndIf
                     endif
                     EEQ->EEQ_NROP   := EF1->EF1_CONTRA
                     EF1->(dbGoTo(nRecEF1))
                  Else
                     If !lIsAdiantamento //FSM - 05/10/2012
                        EEQ->EEQ_BANC   := ""
                        EEQ->EEQ_AGEN   := ""
                        EEQ->EEQ_NCON   := ""
                        EEQ->EEQ_NOMEBC := ""
                     EndIf
                     EEQ->EEQ_NROP   := ""
                  EndIf
               Else
                  If !lIsAdiantamento //FSM - 05/10/2012
                     EEQ->EEQ_BANC   := ""
                     EEQ->EEQ_AGEN   := ""
                     EEQ->EEQ_NCON   := ""
                     EEQ->EEQ_NOMEBC := ""
                  EndIf
                  EEQ->EEQ_NROP   := ""
               EndIf
               EF3->(dbSetOrder(nOrdAux))
               EF3->(dbGoTo(nRecAux))
            EndIf
            EEQ->(msUnlock())
         EndIf
         EEQ->(dbSkip(-1))
      EndDo
   EndIf
EndIf

Return .T.

*----------------------------------*
Static Function AtuSWB(nTipo,cAlias)
*----------------------------------*
Local nRecAux, nVlVolta:=0, nRecEF1, nOrdAux
If(cAlias=NIL,cAlias:="WorkEF3",)

//WB_FILIAL+WB_HAWB+WB_PO_DI+WB_INVOICE+WB_FORN+WB_LOJA+WB_LINHA

If nTipo = INCLUIR
   If SWB->(dbSeek((cAlias)->( If(lMultiFil,EF3_FILORI,xFilial("SWB"))+EF3_HAWB+EF3_PO_DI+EF3_INVIMP+EF3_FORN+EF3_LOJAFO+EF3_LINHA)))

      // ** GFC - 29/09/05 - Quebra automática de parcelas de cambio
      If (cAlias)->EF3_VL_INV < SWB->WB_FOBMOE-If(SWB->(FieldPos("WB_COMAG"))>0,SWB->WB_COMAG,0)
         nRecAux := SWB->( RecNo() )
         EX401QSWB(SWB->WB_FOBMOE-If(SWB->(FieldPos("WB_COMAG"))>0,SWB->WB_COMAG,0),(cAlias)->EF3_VL_INV,If(lMultiFil,WorkInv->EF3_FILORI,""),SWB->WB_HAWB,SWB->WB_INVOICE,SWB->WB_LINHA,nRecAux)
         SWB->( dbGoTo(nRecAux) )
      EndIf
      // **
      RecLock("SWB",.F.)

      If Empty(SWB->WB_BANCO)
         If !Empty(M->EF1_BAN_MO)
            SWB->WB_BANCO   := M->EF1_BAN_MO
            SWB->WB_AGENCIA := M->EF1_AGENMO
            If SWB->( FieldPos("WB_CONTA") ) > 0
               SWB->WB_CONTA   := M->EF1_NCONMO
            EndIf
         Else
            SWB->WB_BANCO   := M->EF1_BAN_FI
            SWB->WB_AGENCIA := M->EF1_AGENFI
            If SWB->( FieldPos("WB_CONTA") ) > 0
               SWB->WB_CONTA   := M->EF1_NCONFI
            EndIf
         Endif
      EndIf
      SWB->WB_CA_NUM := M->EF1_CONTRA
      SWB->WB_NR_ROF := M->EF1_ROF
      // ** GFC - 04/10/05 - Gravar o Parfin do EEQ para toda vinculação pois o contábil utiliza
      If lParFin .and. Empty(SWB->WB_PARFIN)
         SWB->WB_PARFIN := SWB->WB_LINHA
      EndIf
      // **
      SWB->( MsUnLock() )
   EndIf
Else
   If SWB->(dbSeek((cAlias)->( If(lMultiFil,EF3_FILORI,xFilial("SWB"))+EF3_HAWB+EF3_PO_DI+EF3_INVIMP+EF3_FORN+EF3_LOJAFO+EF3_LINHA)))

      nVlVolta:=(cAlias)->EF3_VL_INV
      Do While !SWB->(BOF()) .and. SWB->WB_HAWB==(cAlias)->EF3_HAWB .and. nVlVolta > 0
         If If(lParFin .and. !Empty(SWB->WB_PARFIN),SWB->WB_PARFIN,SWB->WB_LINHA)==(cAlias)->EF3_LINHA
            RecLock("SWB",.F.)
            SWB->WB_PARFIN := ""
            nVlVolta -= SWB->WB_FOBMOE
            If AllTrim(SWB->WB_CA_NUM) == AllTrim(M->EF1_CONTRA) .and. cAlias == "EF3"
               nRecAux := EF3->(RecNo())
               nOrdAux := EF3->(IndexOrd())
               EF3->(dbSetOrder(7))
               If EF3->(dbSeek(xFilial("EF3")+M->EF1_TPMODU+SWB->WB_HAWB+SWB->WB_FORN+SWB->WB_LOJA+SWB->WB_INVOICE+If(Empty(SWB->WB_PARFIN),SWB->WB_LINHA,SWB->WB_PARFIN)+EV_EMBARQUE))
                  Do While !EF3->( EoF() ) .AND. EF3->EF3_FILIAL == xFilial("EF3") .AND. EF3->EF3_FORN == SWB->WB_FORN .AND. EF3->EF3_HAWB == SWB->WB_HAWB .AND. EF3->EF3_LOJAFO == SWB->WB_LOJA .AND. EF3->EF3_INVIMP==SWB->WB_INVOICE .and.;
                  EF3->EF3_LINHA==If(Empty(SWB->WB_PARFIN),SWB->WB_LINHA,SWB->WB_PARFIN) .AND. EF3->EF3_CODEVE == EV_EMBARQUE
                     If EF3->( RecNo() ) <> nRecAux
                        Exit
                     EndIf
                     EF3->( dbSkip() )
                  EndDo
                  If !EF3->( EoF() ) .AND. EF3->EF3_FILIAL == xFilial("EF3") .AND. EF3->EF3_TPMODU == M->EF1_TPMODU .AND.;
                     EF3->EF3_FORN == SWB->WB_FORN .AND. EF3->EF3_LOJAFO == SWB->WB_LOJA .AND. EF3->EF3_INVIMP == SWB->WB_INVOICE .AND.;
                     EF3->EF3_LINHA == If(Empty(SWB->WB_PARFIN),SWB->WB_LINHA,SWB->WB_PARFIN) .AND. EF3->EF3_CODEVE == EV_EMBARQUE

                     nRecEF1 := EF1->( RecNo() )
                     EF1->( dbSeek(xFilial("EF1")+EF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT)) )
                     //Alcir Alves - 03-11-05 - considerar o banco de movimentação nas vinculações  - conforme chamado 020324
                     If !Empty(EF1->EF1_BAN_MO)
                        SWB->WB_BANCO   := EF1->EF1_BAN_MO
                        SWB->WB_AGENCIA := EF1->EF1_AGENMO
                        If SWB->( FieldPos("WB_CONTA") ) > 0
                           SWB->WB_CONTA := EF1->EF1_NCONMO
                        EndIf
                     Else
                        SWB->WB_BANCO   := EF1->EF1_BAN_FI
                        SWB->WB_AGENCIA := EF1->EF1_AGENFI
                        If SWB->( FieldPos("WB_CONTA") ) > 0
                           SWB->WB_CONTA := EF1->EF1_NCONFI
                        EndIf
                     EndIf
                     SWB->WB_CA_NUM := EF1->EF1_CONTRA
                     SWB->WB_NR_ROF := EF1->EF1_ROF
                     EF1->( dbGoTo(nRecEF1) )
                  Else
                     SWB->WB_BANCO   := ""
                     SWB->WB_AGENCIA := ""
                     If SWB->( FieldPos("WB_CONTA") ) > 0
                        SWB->WB_CONTA := ""
                     EndIf
                     SWB->WB_CA_NUM  := ""
                     SWB->WB_NR_ROF  := ""
                  EndIf
               Else
                  SWB->WB_BANCO   := ""
                  SWB->WB_AGENCIA := ""
                  If SWB->( FieldPos("WB_CONTA") ) > 0
                     SWB->WB_CONTA := ""
                  EndIf
                  SWB->WB_CA_NUM  := ""
                  SWB->WB_NR_ROF  := ""
               EndIf
               EF3->( dbSetOrder(nOrdAux) )
               EF3->( dbGoTo(nRecAux) )
            EndIf
            SWB->( msUnLock() )
         EndIf
         SWB->( dbSkip(-1) )
      EndDo
   EndIf
EndIf

Return .T.

/*
Funcao      : EFFEX400()
Parametros  :
Retorno     : nTipo
Objetivos   : Executar EX400GeraE
Autor       : Thomson Reuters
Data/Hora   : 25/09/2020
Obs.        :
*/
*------------------
Function EX400GeraE(cCodigo)
*------------------
Return GeraEventos(cCodigo)


*-----------------------------------*
Static Function GeraEventos(cCodigo)
*-----------------------------------*
Local cSeq, nVal, dDt

cSeq := WorkEF3->EF3_SEQ
dDt  := WorkEF3->EF3_DT_EVE

If cCodigo == EV_EMBARQUE .and. lACCACE

   nVal := EX400Conv(M->EF1_MOEDA,M->EF3_MOE_IN,WorkEF3->EF3_VL_MOE)
   EX400GrvEventos(M->EF1_CONTRA,M->EF3_INVOIC,M->EF3_PREEMB,nVal,,M->EF3_MOE_IN,M->EF3_PARC,;
                   M->EF1_MOEDA,"M","WorkEF3","MANUT2",WorkEF3->EF3_TX_MOE,,,If(lTemChave,M->EF1_BAN_FI,),If(lTemChave,M->EF1_PRACA,),If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))

   WorkEF3->(dbGoTop())
   oMark:oBrowse:Refresh()

ElseIf (cCodigo == EV_LIQ_PRC .or. cCodigo == EV_LIQ_PRC_FC) .and. lACCACE

   EX400Liquida(M->EF1_CONTRA,M->EF3_INVOIC,M->EF3_PARC,M->EF3_PREEMB,M->EF3_VL_INV,M->EF3_MOE_IN,;
                M->EF1_MOEDA,"M","WorkEF3","MANUT2",WorkEF3->EF3_TX_MOE,,,,,,,,;
                If(lTemChave,M->EF1_BAN_FI,),If(lTemChave,M->EF1_PRACA,),NIL,NIL,NIL,NIL,NIL,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))

   WorkEF3->(dbGoTop())
   oMark:oBrowse:Refresh()

ElseIf cCodigo == EV_ESTORNO .and. lACCACE

   EX400EvEstorno(M->EF1_CONTRA,M->EF3_INVOIC,M->EF3_PARC,M->EF3_PREEMB,M->EF3_VL_INV,M->EF3_MOE_IN,;
                  M->EF1_MOEDA,"M","WorkEF3","MANUT2",WorkEF3->EF3_TX_MOE,M->EF3_DT_EVE,M->EF3_SEQ,If(lMulTiFil,M->EF3_FILORI,),;
                  If(lTemChave,M->EF1_BAN_FI,),If(lTemChave,M->EF1_PRACA,),If(lEFFTpMod,M->EF1_TPMODU,""),If(lEFFTpMod,M->EF1_SEQCNT,""))

   WorkEF3->(dbGoTop())
   oMark:oBrowse:Refresh()

ElseIf cCodigo == "ESTORNO_BX_FORC"

   EX400EvEstorno(M->EF1_CONTRA,cInv,cParc,cPreemb,nVlInv,cMoeIn,;
                  M->EF1_MOEDA,"M","WorkEF3","MANUT2",nTxMoe,dDtEve,cSeqAux,If(lMulTiFil,cFilOri,),;
                  If(lTemChave,M->EF1_BAN_FI,),If(lTemChave,M->EF1_PRACA,),If(lEFFTpMod,M->EF1_TPMODU,""),If(lEFFTpMod,M->EF1_SEQCNT,""))

   WorkEF3->(dbGoTop())
   oMark:oBrowse:Refresh()

EndIF

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato
EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

Return .T.
/*
Revisão: out/2017 -adicionado o parâmetro dDtEve600, referente à data de vinculação da invoice
*/
*----------------------------------------------------------------------------------------------------*
Function EX400BusTx(cTipo,dData,dData2,cAliasEF1,cAliasEF2,cTipJur,lPrimPar,cFilOri,cInvoice,cParc,;
                    lRecursiva,lBonif, dDtEve600)
*----------------------------------------------------------------------------------------------------*
Local aTaxa:={}, nDias:=0, nEF2Ord, lMaisPeriodos:=.F.
Local nMV_EFF0003 := 1 //EasyGParam("MV_EFF0003",,0)
Local lTemBonus := .F., lRodouRec := .F. // GFC - 23/01/06 - Bonificação
Local i := 0, j := 0, aAuxTaxa := {}, cTxTipo := "" //FSM - Ajuste na busca das taxas dos juros de tipo ACC/ACE
Local cChavePER,cTpModu1,cContra1,cChave1,cInvoice1,cTpJur1,cTpFin1
Local cChaveCONTR,cTpModu2,cContra2,cChave2,cInvoice2,cTpJur2

If(lPrimPar=Nil,lPrimPar:=.F.,)
If(lRecursiva=NIL,lRecursiva:=.F.,)
If(lBonif=NIL,lBonif:=.F.,)

lEF2_INVOIC := EF2->(FieldPos("EF2_INVOIC")) > 0 .and. EF2->(FieldPos("EF2_PARC")) > 0 .and.;
               EF2->(FieldPos("EF2_FILORI")) > 0


If lEF2_INVOIC
   If(cInvoice=NIL,cInvoice:=Space(Len(EF2->EF2_INVOIC)),)
   If(cParc=NIL,cParc:=Space(Len(EF2->EF2_PARC)),)
EndIf

If cAliasEF2 == "EF2"
   nEF2Ord:=EF2->(IndexOrd())
   EF2->(dbSetOrder(2))
EndIf

lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0

If(cAliasEF1=NIL,cAliasEF1:="M",)
If(cAliasEF2=NIL,cAliasEF2:="WorkEF2",)
If(cTipJur=NIL  ,cTipJur  :="",)
dData  := If(dData=NIL,dDataBase,dData)
dData2 := If(dData2=NIL,If(cAliasEF1=="M",M->EF1_DT_JUR,EF1->EF1_DT_JUR),dData2+If(lRecursiva, 0 , nMV_EFF0003))

SX3->(DbSetOrder(2))
lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
             SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
             SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
             SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
             SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
             SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
             SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
             SX3->(DBSeek("EF3_OBS"))    .and. SX3->(DBSeek("EF3_NROP"))
SX3->(DbSetOrder(1))

If dData2 < If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)
   dData2 := If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)
EndIf

//FSM - 15/02/2012 - Ajuste na busca das taxas dos juros de tipo ACC/ACE
If !( If(cAliasEF1=="M", M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1" )

   If &(cAliasEF1+"->EF1_TP_FIN") == ACE //Se for contrato ACE, considera invoice vinculada antes do período.
      aAuxTaxa := EX401PerJur(dData2,dData,dData2-1,cTipJur,xFilial("EEQ")+cInvoice+cParc,cTipo, cAliasEF2)
   Else
      aAuxTaxa := EX401PerJur(dData2,dData,dDtEve600,cTipJur,xFilial("EEQ")+cInvoice+cParc,cTipo, cAliasEF2)
   EndIf

   For i := 1 To Len(aAuxTaxa)
       For j := 1 To Len(aAuxTaxa[i][2])
           cTxTipo := aAuxTaxa[i][1]
           aAdd(aTaxa, {aAuxTaxa[i][2][j][3],aAuxTaxa[i][2][j][2]-aAuxTaxa[i][2][j][1]+1,cTxTipo})
        Next
   Next i

Else

   If lEF2_INVOIC .and. !Empty(cInvoice) .and. !Empty(cParc) .and. !Empty(cFilOri) .and. !lRecursiva .and.;
   ((cAliasEF2 == "EF2" .and. EF2->(dbSeek(xFilial("EF2")+If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+iif(lTemChave,EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),"")+cFilOri+cInvoice+cParc))) .or.;
   (cAliasEF2 == "WorkEF2" .and. (cAliasEF2)->(dbSeek(cFilOri+cInvoice+cParc))))
      aTaxa := EX400BusTx(cTipo,dData,dData2,cAliasEF1,cAliasEF2,cTipJur,lPrimPar,cFilOri,cInvoice,cParc,.T.,lBonif)
      lRodouRec := .T.
   ElseIf lBonif .and. !lRecursiva
      MsgInfo(Alltrim(cInvoice)+" - "+STR0256) //"Invoice com direito a bonificação, porém não possui período com bonificação cadastrado"
   EndIf

   If Len(aTaxa) = 0 .or. aTaxa[1,2] <= 0

      If cAliasEF2 == "EF2"
         (cAliasEF2)->(dbSeek(xFilial("EF2")+If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA,If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA)+;
                              iif(lTemChave, iif(cAliasEF1=="M",M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA)+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+;
                              If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC))),"")+;
                              cTipo+If(lEF2_TIPJUR,cTipJur,"")+DtoS(dData2),.T.))
      Else
         (cAliasEF2)->(dbSeek(If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC))),"")+cTipo+If(lEF2_TIPJUR,cTipJur,"")+DtoS(dData2),.T.))
      EndIf

      If (cAliasEF2)->(Eof()) .or. If(lEFFTpMod,(cAliasEF2)->EF2_TPMODU+(cAliasEF2)->EF2_SEQCNT <> If(cAliasEF1=="M",M->EF1_TPMODU+M->EF1_SEQCNT,(cAliasEF1)->EF1_TPMODU+(cAliasEF1)->EF1_SEQCNT),.F.) .OR.;
      (cAliasEF2)->EF2_CONTRA <> If(cAliasEF1=="M",M->EF1_CONTRA,(cAliasEF1)->EF1_CONTRA) .or.;
      (cAliasEF2)->EF2_TP_FIN <> cTipo .or. iif(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA<>iif(cAliasEF1=="M",M->EF1_BAN_FI+M->EF1_PRACA,(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA),.F.) .or.;
      If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC)))<>(cAliasEF2)->EF2_FILORI+(cAliasEF2)->EF2_INVOIC+(cAliasEF2)->EF2_PARC,.F.) .or.;
      If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR<>cTipJur,.F.)

         (cAliasEF2)->(dbSkip(-1))

      Endif

      If (cAliasEF2)->EF2_DT_INI > dData2
         nRec := (cAliasEF2)->( RecNo() )
         (cAliasEF2)->(dbSkip(-1))

         If (cAliasEF2)->(BOF()) .or. If(lEFFTpMod,(cAliasEF2)->EF2_TPMODU+(cAliasEF2)->EF2_SEQCNT <> If(cAliasEF1=="M",M->EF1_TPMODU+M->EF1_SEQCNT,(cAliasEF1)->EF1_TPMODU+(cAliasEF1)->EF1_SEQCNT),.F.) .OR.;
         (cAliasEF2)->EF2_CONTRA <> If(cAliasEF1=="M",M->EF1_CONTRA,(cAliasEF1)->EF1_CONTRA) .or.;
         (cAliasEF2)->EF2_TP_FIN <> cTipo .or. iif(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA<>iif(cAliasEF1=="M",M->EF1_BAN_FI+M->EF1_PRACA,(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA),.F.) .or.;
         If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC)))<>(cAliasEF2)->EF2_INVOIC+(cAliasEF2)->EF2_PARC,.F.) .or.;
         If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR<>cTipJur,.F.)
            If (cAliasEF2)->(BOF())
               (cAliasEF2)->(dbGoTo(nRec)) //AAF 12/04/06 - Devido a problema com dbskip no BoF.
            Else
               (cAliasEF2)->(dbSkip())
            EndIf
            nDias := (cAliasEF2)->EF2_DT_FIM - (cAliasEF2)->EF2_DT_INI + nMV_EFF0003 //Somar mais um sempre - 19/09/05 //FSM - 15/02/2012 - Alterado 'dData2' para '(cAliasEF2)->EF2_DT_INI'
            aAdd(aTaxa,{((cAliasEF2)->EF2_TX_FIX + (cAliasEF2)->EF2_TX_VAR) / 360 , nDias, If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR,)}) // MJA 12/02/05
            // ** GFC - 23/01/06 - Bonificação
            If lBonif .and. lRecursiva .and. !lTemBonus .and. (cAliasEF2)->EF2_BONUS $ cSim
               lTemBonus := .T.
            EndIf
            // **
         EndIf
      EndIf
      If (cAliasEF2)->EF2_DT_FIM < dData
         // ** GFC - 23/06/05 - Para saber se existe mais de uma taxa de juros para o período solicitado.
         (cAliasEF2)->(dbSkip())
         If !(cAliasEF2)->(EOF()) .and. If(lEFFTpMod,(cAliasEF2)->EF2_TPMODU+(cAliasEF2)->EF2_SEQCNT == If(cAliasEF1=="M",M->EF1_TPMODU+M->EF1_SEQCNT,(cAliasEF1)->EF1_TPMODU+(cAliasEF1)->EF1_SEQCNT),.T.) .AND. (cAliasEF2)->EF2_DT_INI <= dData .and. (cAliasEF2)->EF2_TP_FIN == cTipo .and.;
         (cAliasEF2)->EF2_CONTRA+If(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA,"") = If(cAliasEF1=="M",M->EF1_CONTRA+If(lTemChave,M->EF1_BAN_FI+M->EF1_PRACA,""),(cAliasEF1)->EF1_CONTRA+If(lTemChave,(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA,"")) .and.;
         If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC)))==(cAliasEF2)->EF2_INVOIC+(cAliasEF2)->EF2_PARC,.T.) .and.;
         If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR==cTipJur,.T.)
            lMaisPeriodos := .T. //somar mais 1 sempre - 19/09/05
         Else
            lMaisPeriodos := .F.
         EndIf
         (cAliasEF2)->(dbSkip(-1))
         // **
         nTxAux:=0
         dDataFimAux:=(cAliasEF2)->EF2_DT_FIM
         Do While !(cAliasEF2)->(EOF()) .and. (cAliasEF2)->EF2_DT_FIM <= dData .and. (cAliasEF2)->EF2_TP_FIN == cTipo .and.;
                   If(lEFFTpMod,(cAliasEF2)->(EF2_TPMODU+EF2_SEQCNT),"")+(cAliasEF2)->EF2_CONTRA+If(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA,"") = If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU+M->EF1_SEQCNT,"")+M->EF1_CONTRA+If(lTemChave,M->EF1_BAN_FI+M->EF1_PRACA,""),If(lEFFTpMod,(cAliasEF1)->(EF1_TPMODU+EF1_SEQCNT),"")+(cAliasEF1)->EF1_CONTRA+If(lTemChave,(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA,"")) .and.;
                   If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC)))==(cAliasEF2)->EF2_INVOIC+(cAliasEF2)->EF2_PARC,.T.) .and.;
                   If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR==cTipJur,.T.)

            nDias := (cAliasEF2)->EF2_DT_FIM - dData2 + If(lPrimPar,1,If(lMaisPeriodos,1,nMV_EFF0003)) //(cAliasEF2)->EF2_DT_INI
            If nDias > 0
               aAdd(aTaxa,{((cAliasEF2)->EF2_TX_FIX + (cAliasEF2)->EF2_TX_VAR) / 360 , nDias, If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR,)}) // MJA 12/02/05
            EndIf
            // ** GFC - 23/01/06 - Bonificação
            If lBonif .and. lRecursiva .and. !lTemBonus .and. (cAliasEF2)->EF2_BONUS $ cSim
               lTemBonus := .T.
            EndIf
            // **
            nTxAux:=((cAliasEF2)->EF2_TX_FIX + (cAliasEF2)->EF2_TX_VAR) / 360
            dDataFimAux:=(cAliasEF2)->EF2_DT_FIM
            (cAliasEF2)->(dbSkip())
            dData2 := (cAliasEF2)->EF2_DT_INI //GFC - 22/07/05 - Para que considere período por período
         EndDo

         // ** AAF 09/08/2008 - Separado if de 908 colunas.
         //If !(cAliasEF2)->(EOF()) .and. If(lEFFTpMod,(cAliasEF2)->EF2_TPMODU,"")+(cAliasEF2)->EF2_CONTRA+If(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA+If(lEFFTpMod,(cAliasEF2)->EF2_SEQCNT,""),"")+If(lEF2_INVOIC,(cAliasEF2)->EF2_INVOIC+(cAliasEF2)->EF2_PARC,"")+If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR,"")+(cAliasEF2)->EF2_TP_FIN = If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA+If(lTemChave,M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),"")+If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC))),"")+If(lEF2_TIPJUR,cTipJur,""),If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,"")+(cAliasEF1)->EF1_CONTRA+If(lTemChave,(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC))),"")+If(lEF2_TIPJUR,cTipJur,""))+cTipo
         cTpModu1 := If(lEFFTpMod,(cAliasEF2)->EF2_TPMODU,"")
         cContra1 := (cAliasEF2)->EF2_CONTRA
         cChave1  := If(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA+If(lEFFTpMod,(cAliasEF2)->EF2_SEQCNT,""),"")
         cInvoice1:= If(lEF2_INVOIC,(cAliasEF2)->EF2_INVOIC+(cAliasEF2)->EF2_PARC,"")
         cTpJur1  := If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR,"")
         cTpFin1  := (cAliasEF2)->EF2_TP_FIN

         If cAliasEF1=="M"
            cTpModu2 := If(lEFFTpMod,M->EF1_TPMODU,"")
            cContra2 := M->EF1_CONTRA
            cChave2  := If(lTemChave,M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),"")
            cInvoice2:= If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC))),"")
            cTpJur2  := If(lEF2_TIPJUR,cTipJur,"")
         Else
            cTpModu2 := If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")
            cContra2 := (cAliasEF1)->EF1_CONTRA
            cChave2  := If(lTemChave,(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")
            cInvoice2:= If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC))),"")
            cTpJur2  := If(lEF2_TIPJUR,cTipJur,"")
         EndIf

         cChavePER   := cTpModu1+cContra1+cChave1+cInvoice1+cTpJur1+cTpFin1
         cChaveCONTR := cTpModu2+cContra2+cChave2+cInvoice2+cTpJur2+cTipo

         If !(cAliasEF2)->(EOF()) .and. cChavePER == cChaveCONTR
         // **

            nDias := dData - (cAliasEF2)->EF2_DT_INI + nMV_EFF0003
            // ** GFC - 23/07/05 - Para retirar os dias a mais que foram considerados no período anterior, com a taxa anterior
            If nDias < 0
               (cAliasEF2)->(dbSkip(-1))
            EndIf
            // **
            aAdd(aTaxa,{((cAliasEF2)->EF2_TX_FIX + (cAliasEF2)->EF2_TX_VAR) / 360 , nDias, If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR,)}) // MJA 12/02/05
            // ** GFC - 23/01/06 - Bonificação
            If lBonif .and. lRecursiva .and. !lTemBonus .and. (cAliasEF2)->EF2_BONUS $ cSim
               lTemBonus := .T.
            EndIf
            // **

         ElseIf !lPrimPar .and. ((cAliasEF2)->(EOF()) .or. (cAliasEF2)->EF2_CONTRA+If(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA,"")+If(lEF2_INVOIC,(cAliasEF2)->EF2_INVOIC+(cAliasEF2)->EF2_PARC,"")+If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR,"")+(cAliasEF2)->EF2_TP_FIN <> If(cAliasEF1=="M",M->EF1_CONTRA+If(lTemChave,M->EF1_BAN_FI+M->EF1_PRACA,"")+If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC))),"")+If(lEF2_TIPJUR,cTipJur,"")+cTipo,(cAliasEF1)->EF1_CONTRA+If(lTemChave,(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA,"")+If(lEF2_INVOIC,If(lRecursiva,cFilOri+cInvoice+cParc,Space(Len(EF2->EF2_INVOIC+EF2->EF2_PARC))),"")+If(lEF2_TIPJUR,cTipJur,"")+cTipo))
            /* PLB 17/05/07 - Não deve calcular Juros sobre dias que não há Periodos de Juros cadastrados
            // Somente quando não existir mais períodos.
            nDias := dData - (dDataFimAux+1) + nMV_EFF0003  //somar mais um sempre - 19/09/05
            aAdd(aTaxa,{nTxAux , nDias, If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR,)}) // MJA 12/02/05
            */
            // ** GFC - 23/01/06 - Bonificação
            If lBonif .and. lRecursiva .and. !lTemBonus .and. (cAliasEF2)->EF2_BONUS $ cSim
               lTemBonus := .T.
            EndIf
            // **
         EndIf
      Else
         aAdd(aTaxa,{((cAliasEF2)->EF2_TX_FIX + (cAliasEF2)->EF2_TX_VAR) / 360 , dData - dData2 + nMV_EFF0003, If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR,)}) // MJA 12/02/05
         // ** GFC - 23/01/06 - Bonificação
         If lBonif .and. lRecursiva .and. !lTemBonus .and. (cAliasEF2)->EF2_BONUS $ cSim
            lTemBonus := .T.
         EndIf
         // **
      EndIf

   EndIf

EndIf

If cAliasEF2 == "EF2"
   EF2->(dbSetOrder(nEF2Ord))
EndIf

If lBonif .and. lRecursiva .and. !lTemBonus .and. !lRodouRec
   MsgInfo(Alltrim(cInvoice)+" - "+STR0256) //"Invoice com direito a bonificação, porém não possui período com bonificação cadastrado"
   aAdd(aTaxa,{0,0,"BONUS"})
ElseIf lBonif .and. !lRecursiva .and. !lRodouRec
   aAdd(aTaxa,{0,0,"BONUS"})
EndIf

Return aTaxa

*---------------------------------------------------------*
Function EX400AtuSaldos(cTipo,cAliasEF1,cAliasEF3,cOrigem)
*---------------------------------------------------------*
Local nOrdAux, nRecAux, nValAux1, nValAux2
Local lLogix := AvFlags("EEC_LOGIX")
Local lLocked
If(cAliasEF1=NIL, cAliasEF1:="EF1", )
If(cAliasEF3=NIL, cAliasEF3:="EF3", )
If(cOrigem=NIL, cOrigem:="EFF", )

If EasyEntryPoint("EFFEX400")
   ExecBlock("EFFEX400",.F.,.F.,"EXC_PARCELA_2")
Endif

//tratar chamada do câmbio 3/4 - EECAF500
If lPrePag .And. cOrigem == "EEC" .AND. (AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix)
   oEFFContrato := AvEFFContra():LoadEF1()
EndIf

If(cAliasEF1<>"M", (cAliasEF1)->(RecLock(cAliasEF1,.F.)) ,)
If cTipo == "VIN"
   If (cAliasEF3)->EF3_CODEVE == EV_EMBARQUE //600
      If /*cOrigem == "IMP" .or.*/ (cOrigem == "EFF" .AND. cMod == IMP) .OR.;
      !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1") //If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) // ** GFC - Pré-Pagamento/Securitização
         If cMod != IMP  // PLB 16/08/06 - Não altera saldos caso seja Importação
            If cAliasEF1 <> "M"
               (cAliasEF1)->EF1_SLD_PM += (cAliasEF3)->EF3_VL_MOE
               (cAliasEF1)->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
               (cAliasEF1)->EF1_SL2_PM -= (cAliasEF3)->EF3_VL_MOE
               (cAliasEF1)->EF1_SL2_PR -= (cAliasEF3)->EF3_VL_REA
            Else
               M->EF1_SLD_PM += (cAliasEF3)->EF3_VL_MOE
               M->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
               M->EF1_SL2_PM -= (cAliasEF3)->EF3_VL_MOE
               M->EF1_SL2_PR -= (cAliasEF3)->EF3_VL_REA
            EndIf
         EndIf
         // Gera V.C e Provisao de Juros referentes aos períodos em que houve transferência - EDS 19/12//02
         If cAliasEF1 <> "M" .And. !Empty((cAliasEF3)->EF3_NR_CON)
            If cOrigem = "EFF"       // Indica qual a origem da chamada da funcao
               EX400GeraVc((cAliasEF1)->EF1_CONTRA,If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_INVOIC,(cAliasEF3)->EF3_INVIMP),If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_PARC,(cAliasEF3)->EF3_LINHA),If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_PREEMB,(cAliasEF3)->EF3_HAWB),(cAliasEF3)->EF3_VL_INV,(cAliasEF3)->EF3_MOE_IN,;
                           (cAliasEF1)->EF1_MOEDA,"M","WorkEF3","MANUT2",(cAliasEF3)->EF3_TX_MOE,(cAliasEF3)->EF3_DT_EVE,(cAliasEF3)->EF3_SEQ,If(lTemChave,(cAliasEF1)->EF1_BAN_FI,),If(lTemChave,(cAliasEF1)->EF1_PRACA,),;
                           If(lMulTiFil,(cAliasEF3)->EF3_FILORI,Nil),If(lEFFTpMod,(cAliasEF3)->EF3_TPMODU,""),If(lEFFTpMod,(cAliasEF3)->EF3_SEQCNT,""),If(lEFFTpMod .AND. cMod == IMP,(cAliasEF3)->EF3_ORIGEM,""))
            Else
               EX400GeraVc((cAliasEF1)->EF1_CONTRA,If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_INVOIC,(cAliasEF3)->EF3_INVIMP),If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_PARC,(cAliasEF3)->EF3_LINHA),If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_PREEMB,(cAliasEF3)->EF3_HAWB),(cAliasEF3)->EF3_VL_INV,(cAliasEF3)->EF3_MOE_IN,;
                           (cAliasEF1)->EF1_MOEDA,"EF1","EF3","CAMB",(cAliasEF3)->EF3_TX_MOE,(cAliasEF3)->EF3_DT_EVE,(cAliasEF3)->EF3_SEQ,If(lTemChave,(cAliasEF1)->EF1_BAN_FI,),If(lTemChave,(cAliasEF1)->EF1_PRACA,),;
                           If(lMulTiFil,(cAliasEF3)->EF3_FILORI,Nil),If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,""),If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),If(lEFFTpMod .AND. cMod == IMP,(cAliasEF3)->EF3_ORIGEM,""))
            EndIf
         ElseIf cAliasEF1 = "M" .And. !Empty((cAliasEF3)->EF3_NR_CON)
            EX400GeraVc(M->EF1_CONTRA,If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_INVOIC,(cAliasEF3)->EF3_INVIMP),If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_PARC,(cAliasEF3)->EF3_LINHA),If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_PREEMB,(cAliasEF3)->EF3_HAWB),(cAliasEF3)->EF3_VL_INV,(cAliasEF3)->EF3_MOE_IN,;
                        M->EF1_MOEDA,"M","WorkEF3","MANUT2",(cAliasEF3)->EF3_TX_MOE,(cAliasEF3)->EF3_DT_EVE,(cAliasEF3)->EF3_SEQ,If(lTemChave,M->EF1_BAN_FI,),If(lTemChave,M->EF1_PRACA,),;
                        If(lMulTiFil,M->EF3_FILORI,Nil),If(lEFFTpMod,M->EF1_TPMODU,""),If(lEFFTpMod,M->EF1_SEQCNT,""),If(lEFFTpMod .AND. cMod == IMP,(cAliasEF3)->EF3_ORIGEM,""))
         Endif
      ElseIf cMod == EXP/*( cAliasEF1 == "M" .AND. M->EF1_TPMODU == "E" ) .OR. (cAliasEF1)->EF1_TPMODU == "E"*/
         nOrdAux  := (cAliasEF3)->(IndexOrd())
         nRecAux  := (cAliasEF3)->(RecNo())
         nValAux1 := (cAliasEF3)->EF3_VL_MOE

         If cAliasEF3 == "EF3"
            (cAliasEF3)->(dbSetOrder(1))
         Else
            (cAliasEF3)->(dbSetOrder(2))
         EndIf

         (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(cAliasEF1<>"M",If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,"")),"")+(cAliasEF3)->EF3_EV_VIN+If(cAliasEF3=="WorkEF3",Space(Len(EF3->EF3_INVOIC)),"")+(cAliasEF3)->EF3_PARVIN))
         (cAliasEF3)->(RecLock(cAliasEF3,.F.))
         (cAliasEF3)->EF3_SLDVIN += nValAux1
         (cAliasEF3)->(msUnlock())
         (cAliasEF3)->(dbSetOrder(nOrdAux))
         (cAliasEF3)->(dbGoTo(nRecAux))
      EndIf
   ElseIf Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_PJ,2) //520
      If cAliasEF1 <> "M"
         (cAliasEF1)->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
      Else
         M->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
         M->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_EST_PJ,2) //510
      If cAliasEF1 <> "M"
         (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
      Else
         M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
         M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_TJ,2)  //650
      If cAliasEF1 <> "M"
         (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
         (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
      Else
         M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
         M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
         M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
         M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf Val((cAliasEF3)->EF3_CODEVE) >= Val(EV_VC_PJ1) .and. Val((cAliasEF3)->EF3_CODEVE) <= Val(EV_VC_PJ2) .and.;  //550
   Val((cAliasEF3)->EF3_CODEVE) % 2 = 0
      If cAliasEF1 <> "M"
//       (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
      Else
//       M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
         M->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf Val((cAliasEF3)->EF3_CODEVE) >= Val(EV_VC_PJ1) .and. Val((cAliasEF3)->EF3_CODEVE) <= Val(EV_VC_PJ2) .and.;
   Val((cAliasEF3)->EF3_CODEVE) % 2 <> 0
      If cAliasEF1 <> "M"
//       (cAliasEF1)->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
      Else
//       M->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
         M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf (cAliasEF3)->EF3_CODEVE == EV_VC_PRC .or. (cAliasEF3)->EF3_CODEVE == EV_VC_PRC1 //500/501
      If cAliasEF1 <> "M"
         // PLB 29/06/07 - Tratamento para estorno de vinculação em contrato ACE
         If (cAliasEF1)->EF1_TP_FIN == ACE  .And.  (cAliasEF3)->EF3_DT_EVE < (cAliasEF1)->EF1_DT_JUR
            (cAliasEF1)->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF1)->EF1_SL2_PR -= (cAliasEF3)->EF3_VL_REA
         Else
            (cAliasEF1)->EF1_SLD_PR -= (cAliasEF3)->EF3_VL_REA
         EndIf
      Else
         // PLB 29/06/07 - Tratamento para estorno de vinculação em contrato ACE
         If M->EF1_TP_FIN == ACE  .And.  (cAliasEF3)->EF3_DT_EVE < M->EF1_DT_JUR
            M->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
            M->EF1_SL2_PR -= (cAliasEF3)->EF3_VL_REA
         Else
            M->EF1_SLD_PR -= (cAliasEF3)->EF3_VL_REA
         EndIf
      EndIf
   EndIf
ElseIf cTipo == "LIQ"
   //NCF - 05/09/2014
   If cAliasEF1 <> "M" .and. lLogix
      AF200BkPInt( cAliasEF1 , "EEC_ESBX_ALT",,{'EEQ',EEQ->(Recno())},,)
   EndIf

   If (cAliasEF3)->EF3_CODEVE == EV_LIQ_PRC .or. (cAliasEF3)->EF3_CODEVE == EV_LIQ_PRC_FC  //630 ou 660
      If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) // ** GFC - Pré-Pagamento/Securitização
         If cAliasEF1 <> "M"
            (cAliasEF1)->EF1_SL2_PM += (cAliasEF3)->EF3_VL_MOE
            (cAliasEF1)->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF1)->EF1_LIQPRM -= (cAliasEF3)->EF3_VL_MOE
            (cAliasEF1)->EF1_LIQPRR -= (cAliasEF3)->EF3_VL_REA
         Else
            M->EF1_SL2_PM += (cAliasEF3)->EF3_VL_MOE
            M->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
            M->EF1_LIQPRM -= (cAliasEF3)->EF3_VL_MOE
            M->EF1_LIQPRR -= (cAliasEF3)->EF3_VL_REA
         EndIf
      EndIf
      // ** GFC - Pré-Pagamento/Securitização
      If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
         nOrdAux  := (cAliasEF3)->(IndexOrd())
         nRecAux  := (cAliasEF3)->(RecNo())
         nValAux1 := (cAliasEF3)->EF3_VL_MOE
         nValAux2 := (cAliasEF3)->EF3_VL_REA
         cEvVin   := (cAliasEF3)->EF3_EV_VIN
         cParcVin := (cAliasEF3)->EF3_PARVIN
         If cAliasEF3 == "EF3"
            (cAliasEF3)->(dbSetOrder(1))
         Else
            (cAliasEF3)->(dbSetOrder(2))
         EndIf

         (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(cAliasEF1<>"M",If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,"")),"")+(cAliasEF3)->EF3_EV_VIN+If(cAliasEF3=="WorkEF3",Space(Len(EF3->EF3_INVOIC)),"")+(cAliasEF3)->EF3_PARVIN))
         Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and.;
         If(cAliasEF1<>"M",If(lEFFTpMod,EF3->EF3_TPMODU == (cAliasEF1)->EF1_TPMODU,.T.) .AND.EF3->EF3_CONTRA==(cAliasEF1)->EF1_CONTRA .and. EF3->EF3_BAN_FI==(cAliasEF1)->EF1_BAN_FI .and.;
         EF3->EF3_PRACA==(cAliasEF1)->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == (cAliasEF1)->EF1_SEQCNT,.T.),If(lEFFTpMod,EF3->EF3_TPMODU == M->EF1_TPMODU,.T.) .AND. EF3->EF3_CONTRA==M->EF1_CONTRA .and.;
         EF3->EF3_BAN_FI==M->EF1_BAN_FI .and. EF3->EF3_PRACA==M->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == M->EF1_SEQCNT,.T.)),.T.) .and.;
         (cAliasEF3)->EF3_CODEVE==cEvVin .and.;
         If(cAliasEF3=="WorkEF3",(cAliasEF3)->EF3_INVOIC==Space(Len(EF3->EF3_INVOIC)),.T.) .and. (cAliasEF3)->EF3_PARC==cParcVin
            //NCF - 05/09/2014
            If lLogix
               AF200BkPInt( cAliasEF3 , "EEC_ESBX_ALT",,{'EEQ',EEQ->(Recno())},,)
            EndIf

            (cAliasEF3)->(RecLock(cAliasEF3,.F.))
            (cAliasEF3)->EF3_SLDLIQ += nValAux1
            (cAliasEF3)->EF3_LIQ_RS -= nValAux2
            If (cAliasEF3)->EF3_TX_MOE <> 0

               If cAliasEF1 <> "M"
                  (cAliasEF1)->EF1_SLD_PM += (cAliasEF3)->EF3_VL_MOE
                  (cAliasEF1)->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
                  (cAliasEF1)->EF1_LIQPRM -= (cAliasEF3)->EF3_VL_MOE
                  (cAliasEF1)->EF1_LIQPRR -= (cAliasEF3)->EF3_VL_REA
               Else
                  M->EF1_SLD_PM += (cAliasEF3)->EF3_VL_MOE
                  M->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
                  M->EF1_LIQPRM -= (cAliasEF3)->EF3_VL_MOE
                  M->EF1_LIQPRR -= (cAliasEF3)->EF3_VL_REA
               EndIf

               (cAliasEF3)->EF3_TX_MOE := 0
               (cAliasEF3)->EF3_VL_REA := 0

               If cOrigem == "EEC" .AND. (AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix)
                  oEFFContrato:EventoEF3("ALTERACAO")
                  If ((cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG .Or. Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2)) .And. (IsInCallStack("AF500ELQFIN") .Or. IsInCallStack("FAF2ESTLIQ"))
				       lLocked:= .F.
				       If (cAliasEF3)->(!IsLocked())
				          (cAliasEF3)->(RecLock(cAliasEF3, .F.))
				          lLocked:= .T.
				       EndIf
				       (cAliasEF3)->EF3_DTOREV:= CtoD("")
				       If lLocked
				          (cAliasEF3)->(MsUnlock())
				       EndIf
				    EndIf
               EndIf

               Exit
            EndIf
            (cAliasEF3)->(msUnlock())

            (cAliasEF3)->(dbSkip())
         EndDo

         (cAliasEF3)->(dbSetOrder(nOrdAux))
         (cAliasEF3)->(dbGoTo(nRecAux))
      EndIf
      // **
   ElseIf Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_PJ,2) //520
      If cAliasEF1 <> "M"
         (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
      Else
         M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
         M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2) .or. Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_LIQ_JUR_FC,2) //640 ou 670
      If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //.and. !Empty((cAliasEF3)->EF3_TX_MOE) // ** GFC - Pré-Pagamento/Securitização
         If cAliasEF1 <> "M"
            (cAliasEF1)->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
            (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF1)->EF1_LIQJRM -= (cAliasEF3)->EF3_VL_MOE
            (cAliasEF1)->EF1_LIQJRR -= (cAliasEF3)->EF3_VL_REA
         Else
            M->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
            M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
            M->EF1_LIQJRM -= (cAliasEF3)->EF3_VL_MOE
            M->EF1_LIQJRR -= (cAliasEF3)->EF3_VL_REA
         EndIf
      EndIf
      // ** GFC - Pré-Pagamento/Securitização
      If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
         nOrdAux  := (cAliasEF3)->(IndexOrd())
         nRecAux  := (cAliasEF3)->(RecNo())
         cEvVin   := (cAliasEF3)->EF3_EV_VIN
         cParcVin := (cAliasEF3)->EF3_PARVIN
         If cAliasEF3 == "EF3"
            (cAliasEF3)->(dbSetOrder(1))
         Else
            (cAliasEF3)->(dbSetOrder(2))
         EndIf

         // ** GFC - 27/09/05
         nValAux1 := (cAliasEF3)->EF3_VL_MOE
         nValAux2 := (cAliasEF3)->EF3_VL_REA
         // **

         (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(cAliasEF1<>"M",If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,"")),"")+(cAliasEF3)->EF3_EV_VIN+If(cAliasEF3=="WorkEF3",Space(Len(EF3->EF3_INVOIC)),"")+(cAliasEF3)->EF3_PARVIN))

         Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and.;
         If(cAliasEF1<>"M",EF3->EF3_CONTRA==(cAliasEF1)->EF1_CONTRA .and. EF3->EF3_BAN_FI==(cAliasEF1)->EF1_BAN_FI .and.;
         EF3->EF3_PRACA==(cAliasEF1)->EF1_PRACA,EF3->EF3_CONTRA==M->EF1_CONTRA .and.;
         EF3->EF3_BAN_FI==M->EF1_BAN_FI .and. EF3->EF3_PRACA==M->EF1_PRACA),.T.) .and.;
         (cAliasEF3)->EF3_CODEVE==cEvVin .and.;
         If(cAliasEF3=="WorkEF3",(cAliasEF3)->EF3_INVOIC==Space(Len(EF3->EF3_INVOIC)),.T.) .and.;
         (cAliasEF3)->EF3_PARC=cParcVin
            //NCF - 05/06/2014
            If lLogix
               AF200BkPInt( cAliasEF3 , "EEC_ESBX_ALT",,{'EEQ',EEQ->(Recno())},,)
            EndIf

            (cAliasEF3)->(RecLock(cAliasEF3,.F.))
            (cAliasEF3)->EF3_SLDLIQ += nValAux1
            (cAliasEF3)->EF3_LIQ_RS -= nValAux2

            If cOrigem == "EEC" .AND. (AvFlags("SIGAEFF_SIGAFIN") .OR. lLogix)
               If (cAliasEF3)->EF3_CODEVE == EV_JUROS_PREPAG .And. (IsInCallStack("AF500ELQFIN") .Or. IsInCallStack("FAF2ESTLIQ"))
                  (cAliasEF3)->EF3_DTOREV:= CtoD("")
				 EndIf
		     EndIf

            (cAliasEF3)->(msUnlock())

            If (cAliasEF3)->EF3_TX_MOE <> 0
               (cAliasEF3)->(RecLock(cAliasEF3,.F.))

               If cAliasEF1 <> "M"
                  (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
                  //(cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
                  (cAliasEF1)->EF1_SLD_JR := ((cAliasEF1)->EF1_SLD_JR/((cAliasEF1)->EF1_SLD_JM-(cAliasEF3)->EF3_VL_MOE))*(cAliasEF1)->EF1_SLD_JM  // PLB 19/07/06 - Saldo do Juros em Reais de acordo com a Taxa do Evento 100
                  (cAliasEF1)->EF1_LIQJRM -= (cAliasEF3)->EF3_VL_MOE
                  (cAliasEF1)->EF1_LIQJRR -= (cAliasEF3)->EF3_VL_REA
               Else
                  M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
                  //M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
                  M->EF1_SLD_JR := ( M->EF1_SLD_JR / ( M->EF1_SLD_JM - (cAliasEF3)->EF3_VL_MOE ) ) * M->EF1_SLD_JM  // PLB 19/07/06 - Saldo do Juros em Reais de acordo com a Taxa do Evento 100
                  M->EF1_LIQJRM -= (cAliasEF3)->EF3_VL_MOE
                  M->EF1_LIQJRR -= (cAliasEF3)->EF3_VL_REA
               EndIf

               (cAliasEF3)->EF3_TX_MOE := 0
               (cAliasEF3)->EF3_VL_REA := 0

               (cAliasEF3)->(msUnlock())
               Exit
            EndIf

            (cAliasEF3)->(dbSkip())
         EndDo

         (cAliasEF3)->(dbSetOrder(nOrdAux))
         (cAliasEF3)->(dbGoTo(nRecAux))
      EndIf
      // **
   ElseIf Val((cAliasEF3)->EF3_CODEVE) >= Val(EV_VC_PJ1) .and. Val((cAliasEF3)->EF3_CODEVE) <= Val(EV_VC_PJ2) .and.; //550
   Val((cAliasEF3)->EF3_CODEVE) % 2 = 0
      If cAliasEF1 <> "M"
         (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
      Else
         M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf Val((cAliasEF3)->EF3_CODEVE) >= Val(EV_VC_PJ1) .and. Val((cAliasEF3)->EF3_CODEVE) <= Val(EV_VC_PJ2) .and.;
   Val((cAliasEF3)->EF3_CODEVE) % 2 <> 0
      If cAliasEF1 <> "M"
         (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
      Else
         M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf (cAliasEF3)->EF3_CODEVE == EV_VC_PRC .or. (cAliasEF3)->EF3_CODEVE == EV_VC_PRC1// 500/501
      If cAliasEF1 <> "M"
         // ** PLB 19/07/06
         If (lEFFTpMod  .And.  (cAliasEF1)->EF1_CAMTRA == "1") .Or. (lPrePag .And. (cAliasEF1)->EF1_TP_FIN $ ("03/04"))
            (cAliasEF1)->EF1_SLD_PR -= (cAliasEF3)->EF3_VL_REA
         EndIf
         // **
         (cAliasEF1)->EF1_SL2_PR -= (cAliasEF3)->EF3_VL_REA
      Else
         // ** PLB 19/07/06
         If (lEFFTpMod  .And.  M->EF1_CAMTRA == "1")  .Or.  (lPrePag .And. M->EF1_TP_FIN $ ("03/04"))
            M->EF1_SLD_PR -= (cAliasEF3)->EF3_VL_REA
         EndIf
         // **
         M->EF1_SL2_PR -= (cAliasEF3)->EF3_VL_REA
      EndIf
   ElseIf Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_EST_PJ,2)  //510
      If cAliasEF1 <> "M"
         (cAliasEF1)->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
      Else
         M->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
         M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
      EndIf
   EndIf
// ** AAF 07/11/05 - Encerramento/Transferência de Contrato
ElseIf cTipo == "ENC"
   If (cAliasEF3)->EF3_CODEVE == EV_ENC_PRC .OR. (cAliasEF3)->EF3_CODEVE == EV_TRANS_PRC
      M->EF1_SLD_PM += (cAliasEF3)->EF3_VL_MOE
      M->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
      M->EF1_LIQPRM -= (cAliasEF3)->EF3_VL_MOE
      M->EF1_LIQPRR -= (cAliasEF3)->EF3_VL_REA
      M->EF1_DT_ENC := CToD("")

   ElseIf (cAliasEF3)->EF3_CODEVE == EV_VC_PRC .OR. (cAliasEF3)->EF3_CODEVE == EV_VC_PRC1 //500/501
      M->EF1_SLD_PR -= (cAliasEF3)->EF3_VL_REA

   ElseIf Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_PJ,2)
      M->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
      M->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA

   ElseIf Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_LIQ_JUR_FC,2)
      M->EF1_SLD_JM += WorkEF3->EF3_VL_MOE
      M->EF1_SLD_JR += WorkEF3->EF3_VL_REA
      M->EF1_LIQJRM -= WorkEF3->EF3_VL_MOE
      M->EF1_LIQJRR -= WorkEF3->EF3_VL_REA

   Endif
// **
// ** GFC - 08/02/06 - Juros Antecipados
ElseIf cTipo == "ANT"
   If Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_JR_ANT,2)
      &(cAliasEF1+"->EF1_SLD_JM") -= (cAliasEF3)->EF3_VL_MOE
      &(cAliasEF1+"->EF1_SLD_JR") -= (cAliasEF3)->EF3_VL_REA
   EndIf
// **
// ** GFC - 09/02/06 - Juros por Períodos
ElseIf cTipo == "LJP"
   If Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2)
      &(cAliasEF1+"->EF1_SLD_JM") -= (cAliasEF3)->EF3_VL_MOE
      &(cAliasEF1+"->EF1_SLD_JR") -= (cAliasEF3)->EF3_VL_REA
   EndIf
// **
EndIf
If(cAliasEF1 <> "M", (cAliasEF1)->(msUnlock()) ,)

//AAF 18/07/2015 - Atualizacao de saldos garantida
EX401Saldo(cAliasEF1,IIF(lEFFTpMod,cMod,),&(cAliasEF1+"->EF1_CONTRA"),IIF(lTemChave,&(cAliasEF1+"->EF1_BAN_FI"),),IIF(lTemChave,&(cAliasEF1+"->EF1_PRACA"),),IIF(lEFFTpMod,&(cAliasEF1+"->EF1_SEQCNT"),),cAliasEF3,.T.)

Return .T.

*-----------------------------------------------------------------------------------------*
// ** AAF 22/02/06 - Adicionados os parametros:
//                  cSeqCon - Sequencia do Contrato - EF?_SEQCNT
//                  cTpModu - Tipo de Modulo - "E" = Exportação, "I" = Importação - EF?_TPMODU

Function EX400GrvEventos(cContrato,cInvoice,cPreemb,nVlInv,dDtInv,cMoeInv,cParc,cMoeCont,;
                         cAliasEF1,cAliasEF3,cChamada,nTx,nTxVinc,dDataVinc,cFilORI,cBanco,;
                         cPraca,cTpVinc,cTpModu,cSeqCon,cOrigem, cForn, cLoja, cPoDI,nTxConv,dDtDoc,lEvRefi,aNfLoteEF3)
********************************************************************************************


If cChamada=="CAMB" .AND. IsLocked("EEQ")

   xRet := EX400GrvTrans(cContrato,cInvoice,cPreemb,nVlInv,dDtInv,cMoeInv,cParc,cMoeCont,;
                         cAliasEF1,cAliasEF3,cChamada,nTx,nTxVinc,dDataVinc,cFilORI,cBanco,;
                         cPraca,cTpVinc,cTpModu,cSeqCon,cOrigem, cForn, cLoja, cPoDI,nTxConv,dDtDoc,,aNfLoteEF3)

Else

   Begin TransAction

      xRet := EX400GrvTrans(cContrato,cInvoice,cPreemb,nVlInv,dDtInv,cMoeInv,cParc,cMoeCont,;
                            cAliasEF1,cAliasEF3,cChamada,nTx,nTxVinc,dDataVinc,cFilORI,cBanco,;
                            cPraca,cTpVinc,cTpModu,cSeqCon,cOrigem, cForn, cLoja, cPoDI,nTxConv,dDtDoc,lEvRefi,aNfLoteEF3)

   End TransAction

EndIf


Return xRet

*-----------------------------------------------------------------------------------------*
Static Function EX400GrvTrans(cContrato,cInvoice,cPreemb,nVlInv,dDtInv,cMoeInv,cParcAux,cMoeCont,;
                              cAliasEF1,cAliasEF3,cChamada,nTx,nTxVinc,dDataVinc,cFilORI,cBanco,;
                              cPraca,cTpVinc,cTpModu,cSeqCon,cOrigem, cForn, cLoja, cPoDI,nTxConv,dDtDoc,lEvRefi,aNfLoteEF3)
*-----------------------------------------------------------------------------------------*
Local nVal, nTaxa, dDt, dDtOld, aTx_Dia:={}, aTx_Ctb:={}, nSaldoOr := 0// FSY 19/06/2013 Adicionado a variavel dDtOld
Local cSeq, nValAux1:=0, nValAux2:=0, i, lPVez:=.T., nSaldoVin:=0
Local dDataEvento := If(dDataVinc = NIL, dDataBase, dDataVinc)
Local nTxCtb := 0, nOrdEF3, nTx100:=0, nRec600
Local nTxJuros1, nTxJuros2, aJuros:={}, ni
//GFC - 19/09/05
Local nMV_EFF0003 := 1 //EasyGParam("MV_EFF0003",,0)
//
Local aTx_Bonus:={}, nValBonif:=0 //GFC - 23/01/06 - Bonificação

Local nDecValor := AVSX3("EF3_VL_MOE",4)
Local nDecTaxa := AVSX3("EF3_TX_MOE",4)
// ACSJ - Caetano - 24/01/2005
Local nInd := SX3->(IndexOrd())
Local cFilEF3:=xFilial("EF3") // TLM 15/08/2008
Local lNewEFFObj := .F.
Local nTx520Ctb // AAF 19/09/2012
Local nPosEve := 0
Default lEvRefi := .F.  // GFP - 09/10/2015

If nTxConv == NIL   // PLB 30/10/06
   nTxConv := 0
EndIf

If(cOrigem==NIL .OR. Empty(cOrigem),cOrigem:="EEQ",)

SX3->(DbSetOrder(2))
Private cChamaPRW := cChamada  //Alcir Alves - 20-09-05 - define como private o cChamada para tratamento em rdmakes
Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
                     SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
                     SX3->(DBSeek("EF3_OBS"))    .and. SX3->(DBSeek("EF3_NROP"))

Private lTemPgJuros:=  SX3->(DBSeek("EF1_PGJURO"))

Private cChamAux   := cChamada  ,;
        cOriAux    := cOrigem   ,;
        cFilOriAux := cFilOri   ,;
        cParc      := cParcAux

// PLB - Criado para Electrolux referente chamado 058136
IIF(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"ANTES_GRAVA_EVENTOS"),)

SX3->(DbSetOrder(nInd))
cParcVin  := ""
cEvVin    := ""
//----------------------------------------------------
lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0
lEF1_DTBONI := EF1->(FieldPos("EF1_DTBONI")) > 0 .and. EF2->(FieldPos("EF2_BONUS")) > 0

// ** GFC - Pré-Pagamento/Securitização
If(cTpVinc=NIL,cTpVinc:="1",)
// **

// ** PLB 13/06/07 - Verifica se o Contrato está contabilizado
//If !Empty(cTpModu)  .And.  cTpModu == EXP
If cTpModu == NIL .OR. cTpModu <> IMP  //AAF 24/10/2007 - Também é necessário verificar a contabilidade caso não haja cTpModu
   If AvFlags("SIGAEFF_SIGAFIN") .OR. !EasyGParam("MV_EEC_ECO",,.F.)
      lIsContab := !Empty(EF1->EF1_DT_CTB)
   Else
      lIsContab := EX401IsCtb(cContrato,IIF(lTemChave,cBanco,""),IIF(lTemChave,cPraca,""),IIF(lEFFTpMod,cSeqCon,""))
   EndIf
Else
   lIsContab := .F.
EndIf
// **

If cChamada=="CAMB" .AND. Type("oEFFContrato") <> "O"
   lNewEFFObj := .T.
   oEFFContrato := AvEFFContra():LoadEF1()
EndIf

Begin TransAction

nOrdEF3:= (cAliasEF3)->(IndexOrd())
//(cAliasEF3)->(dbSetOrder(2))
//(cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3"),"")+EV_PRINC))  //100
If cAliasEF3 == "EF3"
   EF3->( DBSetOrder(1) )
   EF3->( DBSeek(cFilEF3+cTpModu+cContrato+cBanco+cPraca+cSeqCon+EV_PRINC) )
   nTx100 := EF3->EF3_TX_MOE
Else
   (cAliasEF3)->(dbSetOrder(2))
   (cAliasEF3)->(dbSeek(EV_PRINC))  //100
   nTx100 := (cAliasEF3)->EF3_TX_MOE
EndIf

If cMoeInv # cMoeCont // VI 26/07/05
   //nVal    := EX400Conv(cMoeInv,cMoeCont,nVlInv,dDataEvento)  // VI 26/07/05
   If nTxConv > 0  // PLB 30/10/06 - Caso o parametro de taxa na moeda do contrato tenha sido passado
      nVal    := (nVlInv * nTxVinc) / nTxConv
      nTxVinc := nTxConv
   Else
      nVal    := (nVlInv * nTxVinc) / BuscaTaxa(cMoeCont,dDataEvento,,.F.,.T.,,cTX_100)  // PLB 27/07/06
      nTxVinc := (nVlInv * nTxVinc) / nVal  // VI 26/07/05
   EndIf
Else
   nVal    := nVlInv
EndIf
nVal := Round(nVal,nDecValor)

// ** GFC - Pré-Pagamento/Securitização
If lPrePag .and. cMod == EXP .AND. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1"//If(cAliasEF1 == "M", M->EF1_TP_FIN, (cAliasEF1)->EF1_TP_FIN) $ ("03/04") //PLB 23/06/06
   //Posiciona na primeira parcela em aberto
   nSaldoVin := EXPosPrePag(cAliasEF3,cContrato,cBanco,cPraca,.T.,cTpVinc,cTpModu,cSeqCon)
   cParcVin  := (cAliasEF3)->EF3_PARC
   cEvVin    := (cAliasEF3)->EF3_CODEVE

   //Atualiza saldo a vincular da parcela
   //If nVal <= nSaldoVin

   // ** AAF 19/02/08 - Sempre abater do saldo da parcela o valor vinculado
   (cAliasEF3)->(RecLock(cAliasEF3,.F.))
   If nVal <= nSaldoVin
      (cAliasEF3)->EF3_SLDVIN := Round(nSaldoVin - nVal,nDecValor)
   Else
      (cAliasEF3)->EF3_SLDVIN := 0
   EndIf
   (cAliasEF3)->(msUnlock())
   // **
EndIf
// **

(cAliasEF3)->(dbSetOrder(nOrdEF3))

//dContab := If(If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB)=If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)-nMV_EFF0003,If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB)) // VI 27/07/05
// ** PLB 13/06/07
If cAliasEF1 == "M"
   If Empty(M->EF1_DT_CTB)  .Or.  !lIsContab
      dContab := M->EF1_DT_JUR - nMV_EFF0003
   Else
      dContab := M->EF1_DT_CTB
   EndIf
Else
   If Empty((cAliasEF1)->EF1_DT_CTB)  .Or.  !lIsContab
      dContab := (cAliasEF1)->EF1_DT_JUR - nMV_EFF0003
   Else
      dContab := (cAliasEF1)->EF1_DT_CTB
   EndIf
EndIf
// **

nTxJuros1 := Round(BuscaTaxa(cMoeCont, dDataVinc,,.F.,,,cTX_520),nDecTaxa)
//nTxJuros2 := Round(BuscaTaxa(cMoeCont, If(cAliasEF1 == "M", M->EF1_DT_CTB, (cAliasEF1)->EF1_DT_CTB),,.T.,,,cTX_520),nDecTaxa)
// PLB 13/06/07

dDataTx2  := IIF(cAliasEF1=="M",IIF(Empty(M->EF1_DT_CTB) .Or. !lIsContab,M->EF1_DT_JUR,M->EF1_DT_CTB),IIF(Empty((cAliasEF1)->EF1_DT_CTB) .Or. !lIsContab,(cAliasEF1)->EF1_DT_JUR,(cAliasEF1)->EF1_DT_CTB))
If !Empty(dDataTx2)
   nTxJuros2 := IIF(cAliasEF1=="M",M->EF1_TX_CTB,EF1->EF1_TX_CTB) //FSM - 04/09/2012
   If Empty(nTxJuros2)
      nTxJuros2 := Round(BuscaTaxa(cMoeCont,dDataTx2,,.F.,,,cTX_520),nDecTaxa)
   EndIf
Else
   nTxJuros2 := nTxJuros1
End If

If cAliasEF1=="M"
// nTxCtb := IF(Empty(M->EF1_TX_CTB), BuscaTaxa(M->EF1_MOEDA,M->EF1_DT_JUR,,.F.,.T.), M->EF1_TX_CTB)
   nTxCtb := If(Empty(M->EF1_TX_CTB),nTx100,M->EF1_TX_CTB)
Else
// nTxCtb := IF(Empty((cAliasEF1)->EF1_TX_CTB), BuscaTaxa((cAliasEF1)->EF1_MOEDA,(cAliasEF1)->EF1_DT_JUR,,.F.,.T.), (cAliasEF1)->EF1_TX_CTB)
   nTxCtb := If(Empty((cAliasEF1)->EF1_TX_CTB),nTx100,(cAliasEF1)->EF1_TX_CTB)
EndIf
nTxCtb := Round(nTxCtb,nDecTaxa)

If cChamada <> "MANUT2"
   cSeq  := BuscaEF3Seq(cAliasEF3,cContrato,cBanco,cPraca,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))
   nTaxa := If(nTxVinc = NIL, EX400Conv(cMoeCont,,nVal) / nVal, nTxVinc)
   nTaxa := Round(nTaxa,nDecTaxa)
   //Grava Evento 600 - Embarque
   (cAliasEF3)->(RecLock(cAliasEF3,.T.))
   (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
   If ValType(cFilORI) == "C"
      (cAliasEF3)->EF3_FILORI := cFilORI
   EndIf
   If lEFFTpMod
      (cAliasEF3)->EF3_TPMODU := cTpModu
      (cAliasEF3)->EF3_ORIGEM := cOrigem
   EndIf

   (cAliasEF3)->EF3_CONTRA := cContrato

   // ACSJ - 06/02/2005
   if lTemChave
      (cAliasEF3)->EF3_BAN_FI := cBanco
      (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
      (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,(cAliasEF1)->EF1_NCONFI)
      (cAliasEF3)->EF3_PRACA  := cPraca
      If lEFFTpMod
         (cAliasEF3)->EF3_SEQCNT := cSeqCon
      EndIf
   Endif

   If cOrigem == "EEQ"
      (cAliasEF3)->EF3_INVOIC := cInvoice
      (cAliasEF3)->EF3_PREEMB := cPreemb
      (cAliasEF3)->EF3_PARC   := cParc
   Else
      (cAliasEF3)->EF3_INVIMP := cInvoice
      (cAliasEF3)->EF3_HAWB   := cPreemb
      (cAliasEF3)->EF3_LINHA  := cParc
      (cAliasEF3)->EF3_FORN   := cForn
      (cAliasEF3)->EF3_LOJAFO := cLoja
      (cAliasEF3)->EF3_PO_DI  := cPoDi
   EndIf

   (cAliasEF3)->EF3_VL_INV := nVlInv
   If cAliasEF1 == "M"
      If M->EF1_CAMTRA = "1" .and. cChamada == "CAMB"  //M->EF1_LIQFIX = "2" .and.   //PLB 17/02/06 - Campo EF1_LIQFIX excluido do Dicionario
         (cAliasEF3)->EF3_DT_FIX := dDtInv
      EndIf
      (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
   Else
      If (cAliasEF1)->EF1_CAMTRA = "1" .and. cChamada == "CAMB"  //(cAliasEF1)->EF1_LIQFIX = "2" .and.    //PLB 17/02/06 - Campo EF1_LIQFIX excluido do Dicionario
         (cAliasEF3)->EF3_DT_FIX := dDtInv
      EndIf
      (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
   EndIf
   (cAliasEF3)->EF3_MOE_IN := cMoeInv
   (cAliasEF3)->EF3_CODEVE := EV_EMBARQUE
   (cAliasEF3)->EF3_VL_MOE := nVal
   (cAliasEF3)->EF3_VL_REA := nVal * nTaxa
   (cAliasEF3)->EF3_TX_MOE := nTaxa
   // ** PLB 19/10/06
   If IIF(cAliasEF1=="M",M->EF1_MOEDA,(cAliasEF1)->EF1_MOEDA) == cMoeInv
      (cAliasEF3)->EF3_TX_CON := nTaxa
   Else
      (cAliasEF3)->EF3_TX_CON := (cAliasEF3)->EF3_VL_REA / (cAliasEF3)->EF3_VL_INV
   EndIf
   // ** PLB 29/06/07                                                   //NCF - 27/06/2014 - Gravar data da vinculação para transferência ACC > ACE em vinculação de invoice
   If IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACE  .OR. IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACC//"02" ou "01"
      (cAliasEF3)->EF3_DT_EVE := dDataEvento
   Else
      (cAliasEF3)->EF3_DT_EVE := IF(dDataEvento<If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),dDataEvento)
   EndIf
   // **
   If IsLocked("EF6")//FSY - 16/04/2013
      If dDtDoc <> NIL .AND. EF6->(FieldPos("EF6_DTDOC")) > 0
         EF6->EF6_DTDOC := dDtDoc
      EndIf
   Else
      If dDtDoc <> NIL .AND. EF3->(FieldPos("EF3_DTDOC")) > 0
         (cAliasEF3)->EF3_DTDOC := dDtDoc
      EndIf
   EndIf

   (cAliasEF3)->EF3_DT_CIN := dDataBase
   (cAliasEF3)->EF3_SEQ    := cSeq

   // ** GFC - Pré-Pagamento/Securitização
   If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1"//If(cAliasEF1 == "M", M->EF1_TP_FIN, (cAliasEF1)->EF1_TP_FIN) $ ("03/04")
      (cAliasEF3)->EF3_PARVIN := cParcVin
      (cAliasEF3)->EF3_EV_VIN := cEvVin
   EndIf
   // **

   // ** GFC - 19/04/06
   If lEFFTpMod
      (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
   EndIf
   // **
   //FSM - 10/04/2012
   If Upper(cAliasEF3) == "WORKEF3"
     (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
   EndIf

   If lEvRefi  // GFP - 09/10/2015
      (cAliasEF3)->EF3_TPMOOR := WKREFINIMP->EF3_TPMOOR
      (cAliasEF3)->EF3_CONTOR := WKREFINIMP->EF3_CONTOR
      (cAliasEF3)->EF3_BAN_OR := WKREFINIMP->EF3_BAN_OR
      (cAliasEF3)->EF3_PRACOR := WKREFINIMP->EF3_PRACOR
      (cAliasEF3)->EF3_SQCNOR := WKREFINIMP->EF3_SQCNOR
      (cAliasEF3)->EF3_CDEVOR := WKREFINIMP->EF3_CDEVOR
      (cAliasEF3)->EF3_PARCOR := WKREFINIMP->EF3_PARCOR
      (cAliasEF3)->EF3_IVIMOR := WKREFINIMP->EF3_IVIMOR
      (cAliasEF3)->EF3_LINOR  := WKREFINIMP->EF3_LINOR
   EndIf

   If AvFLags("EEC_LOGIX") .And. !Empty(aNfLoteEF3) .And. (nPosEve := aScan(aNfLoteEF3,{|x| x[1] == (cAliasEF3)->EF3_CODEVE})) > 0
      (cAliasEF3)->EF3_NRLOTE := aNfLoteEF3[nPosEve][2][1]
      (cAliasEF3)->EF3_RELACA := aNfLoteEF3[nPosEve][2][2]
      (cAliasEF3)->EF3_NR_CON := aNfLoteEF3[nPosEve][2][3]
      (cAliasEF3)->EF3_DT_CTB := aNfLoteEF3[nPosEve][2][4]
      (cAliasEF3)->EF3_TX_CTB := aNfLoteEF3[nPosEve][2][5]
   EndIf

   (cAliasEF3)->(msUnlock())
   nRec600 := (cAliasEF3)->(RecNo())

   If cOrigem == "EEQ" .AND. cChamada == "CAMB"
      FAF2ValParc(3,cTipo)
   EndIf

   If cChamada=="CAMB"
      oEFFContrato:EventoEF3("INCLUSAO")
   EndIf

   If lCadFin
      EX401GrEncargos(cAliasEF3)
   EndIf
Else
   cSeq  := (cAliasEF3)->EF3_SEQ
   nTaxa := If(nTxVinc = NIL, nTx, nTxVinc)
   nTaxa := Round(nTaxa,nDecTaxa)
EndIf

If lACCACE .and. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
   If lEF2_TIPJUR
      aJuros := EX400BusJur(If(cChamada=="CAMB","EF2","WorkEF2"),cAliasEF1)
   Else
      aJuros := {"0"}
   EndIf

   For ni:=1 to len(aJuros)

      If ni > 1
         lPVez := .F.
      EndIf

      dDt := If(!Empty((cAliasEF3)->EF3_DT_EVE),(cAliasEF3)->EF3_DT_EVE,dDataEvento)
      //dDt := IF(dDt<If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),dDt) // VI 02/06/03
      // ** PLB 29/06/07                                                     //NCF - 27/06/2014 - Considerar data da Vinculação (quando antes do início de juros) em ACC
      If !( IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACE .OR. IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACC )    //"02" ou "01"
         dDt := IF(dDt<If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),dDt)
      EndIf
      // **

      //*** FSY 19/06/2013 Chamado THAXDV
      If cOrigem == "EEQ" .AND. Val(EasyGParam("MV_EFF0008",,"1")) == 2
         aOrdEEQ := {EEQ->(RecNo()),EEQ->(IndexOrd())}
         EEQ->(dbSetOrder(4))
         EEQ->(dbSeek(if(lMultiFil,(cAliasEF3)->EF3_FILORI,xFilial("EEQ"))+(cAliasEF3)->EF3_INVOIC+(cAliasEF3)->EF3_PREEMB+(cAliasEF3)->EF3_PARC))
         dDtOld := dDt
         If !Empty(EEQ->EEQ_DTCE)
            dDt := EEQ->EEQ_DTCE
         EndIf
      EndIf
      //***
      /*
      dDtCtb := If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB)
      If Empty(dDtCtb)
         dDtCtb := NIL
      EndIf
      */
      //FSM - 01/03/2012
	  cTpEve := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
	  If cTpEve == ACE
	     cTpEve := ACC
	  EndIf

      aTx_Dia  := EX400BusTx(cTpEve,dDt,,If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc) //FSM - 01/03/2012
//    aTx_Ctb  := EX400BusTx(cTpEve,dDt,If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB),If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni])

    //dContab := Max(Max(GetTxCtb(cAliasEF3, "52"+aJuros[ni],cTpModu, "", "")[2],GetTxCtb(cAliasEF3, "51"+aJuros[ni],cTpModu, "", "")[2]),M->EF1_DT_JUR - nMV_EFF0003)
      dContab := Max(Max(GetTxCtb(cAliasEF3, "52"+aJuros[ni],cTpModu, "", "")[2],GetTxCtb(cAliasEF3, "51"+aJuros[ni],cTpModu, "", "")[2]), If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR) - nMV_EFF0003) // GFP - 03/06/2015

      // ** GFC - 23/01/06 - Bonificação - THTS - 29/09/2022 - Campo de Bonificação não é mais usado
/*      If lEF1_DTBONI .and. (cAliasEF3)->EF3_DT_EVE <= &(cAliasEF1+"->EF1_DTBONI")
         aTx_Bonus:= EX400BusTx(cTpEve,dDt,IIF(dContab>dDt,,dContab),If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc,, .T. ) //FSM - 01/03/2012
         If Len(aTx_Bonus) > 0 .and. aTx_Bonus[Len(aTx_Bonus),3] <> "BONUS"
            aTx_Ctb  := EX400BusTx(cTpEve,dDt,IIF(dContab>dDt,,dContab),If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni]) //FSM - 01/03/2012
         Else
            aTx_Bonus:= {}
            aTx_Ctb  := EX400BusTx(cTpEve,dDt,IIF(dContab>dDt,,dContab),If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc) //FSM - 01/03/2012
         EndIf
      Else*/
         aTx_Bonus:= {}
         aTx_Ctb  := EX400BusTx(cTpEve,dDt,IIF(dContab>dDt,,dContab),If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc) //FSM - 01/03/2012
      //EndIf
      // **
      //***FSY 19/06/2013 Chamado THAXDV
      If cOrigem == "EEQ" .AND. Val(EasyGParam("MV_EFF0008",,"1")) == 2
         EEQ->(dbSetOrder(aOrdEEQ[2]),dbGoTo(aOrdEEQ[1]))
         dDt := dDtOld
      EndIf

	  // Calculo do valor total da transferencia (550)
	  nValAux1 := 0
      For i:=1 to Len(aTx_Dia)
         //nValAux1 += ((If(cAliasEF1=="M",M->EF1_SL2_PM,(cAliasEF1)->EF1_SL2_PM) + nVal) * aTx_Dia[i,1] * aTx_Dia[i,2]) /100
         nValAux1 += Round((nVal * aTx_Dia[i,1] * aTx_Dia[i,2]) /100,nDecValor)
      Next i
      // ** PLB 29/06/07 - Trata Vinculações antes da data de Inicio de Juros
      If nValAux1 < 0
         nValAux1 := 0
      EndIf
      // **
	  //***
      //Grava Evento 520 - Provisão de Juros
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf
      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
         (cAliasEF3)->EF3_ORIGEM := cOrigem
      EndIf
      (cAliasEF3)->EF3_CONTRA := cContrato

      // ACSJ - 06/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif

      (cAliasEF3)->EF3_CODEVE := Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))

      If cOrigem == "EEQ"
         (cAliasEF3)->EF3_INVOIC := cInvoice
         (cAliasEF3)->EF3_PREEMB := cPreemb
         (cAliasEF3)->EF3_PARC   := cParc
      Else
         (cAliasEF3)->EF3_INVIMP := cInvoice
         (cAliasEF3)->EF3_HAWB   := cPreemb
         (cAliasEF3)->EF3_LINHA  := cParc
         (cAliasEF3)->EF3_FORN   := cForn
         (cAliasEF3)->EF3_LOJAFO := cLoja
         (cAliasEF3)->EF3_PO_DI  := cPoDi
      EndIf

      nValaux2:=0
      For i:=1 to Len(aTx_Ctb)
         nValAux2 += Round((nVal * aTx_Ctb[i,1] * aTx_Ctb[i,2]) /100,nDecValor)
      Next i
      // ** PLB 29/06/07 - Trata Vinculações antes da data de Inicio de Juros
      If nValAux2 < 0
         nValAux2 := 0
      EndIf
      // **
      (cAliasEF3)->EF3_MOE_IN := cMoeInv
      (cAliasEF3)->EF3_VL_MOE := nValAux2
   // (cAliasEF3)->EF3_VL_REA := nValAux2 * nTaxa // PROVISÓRIO
      (cAliasEF3)->EF3_VL_REA := nValAux2 * nTxJuros1
   // (cAliasEF3)->EF3_TX_MOE := nTaxa
      (cAliasEF3)->EF3_TX_MOE := nTxJuros1
      (cAliasEF3)->EF3_DT_EVE := dDt // dDataEvento
      (cAliasEF3)->EF3_SEQ    := cSeq

      If cAliasEF1 == "M"
         M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE //nValAux2
   //    M->EF1_SLD_JR += nValAux2 * nTaxa
         M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA //Round(nValAux2 * nTxJuros1,2)
         (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
      Else
         (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE //nValAux2
   //    (cAliasEF1)->EF1_SLD_JR += nValAux2 * nTaxa
         (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA //nValAux2 * nTxJuros1
         (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
      EndIf

      // ** GFC - 19/04/06
      If lEFFTpMod
         (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
      EndIf
      // **

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf

      If AvFLags("EEC_LOGIX") .And. !Empty(aNfLoteEF3) .And. (nPosEve := aScan(aNfLoteEF3,{|x| x[1] == (cAliasEF3)->EF3_CODEVE})) > 0
         (cAliasEF3)->EF3_NRLOTE := aNfLoteEF3[nPosEve][2][1]
         (cAliasEF3)->EF3_RELACA := aNfLoteEF3[nPosEve][2][2]
         (cAliasEF3)->EF3_NR_CON := aNfLoteEF3[nPosEve][2][3]
         (cAliasEF3)->EF3_DT_CTB := aNfLoteEF3[nPosEve][2][4]
         (cAliasEF3)->EF3_TX_CTB := aNfLoteEF3[nPosEve][2][5]
      EndIf

      (cAliasEF3)->(msUnlock())
      If EasyEntryPoint("EFFEX400") //Alcir Alves - 19-09-05
         ExecBlock("EFFEX400",.F.,.F.,"APOS_GRV_520")
      Endif

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf

      // ** GFC - 23/01/06 - Bonificação
      If lEF1_DTBONI .and. Len(aTx_Bonus) > 0
         nValBonif := 0
         For i:=1 to Len(aTx_Bonus)
            nValBonif += Round((nVal * aTx_Bonus[i,1] * aTx_Bonus[i,2]) /100,nDecValor)
         Next i

         //Grava Evento 510 - Estorno da Provisão de Juros
         (cAliasEF3)->(RecLock(cAliasEF3,.T.))
         (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
         If ValType(cFilORI) == "C"
            (cAliasEF3)->EF3_FILORI := cFilORI
         EndIf
         If lEFFTpMod
            (cAliasEF3)->EF3_TPMODU := cTpModu
            (cAliasEF3)->EF3_ORIGEM := cOrigem
         EndIf
         (cAliasEF3)->EF3_CONTRA := cContrato

         If lTemChave
            (cAliasEF3)->EF3_BAN_FI := cBanco
            (cAliasEF3)->EF3_AGENFI := &(cAliasEF1+"->EF1_AGENFI")
            (cAliasEF3)->EF3_NCONFI := &(cAliasEF1+"->EF1_NCONFI")
            (cAliasEF3)->EF3_PRACA  := cPraca
            If lEFFTpMod
               (cAliasEF3)->EF3_SEQCNT := cSeqCon
            EndIf
         Endif

         (cAliasEF3)->EF3_CODEVE := Left(EV_EST_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
         If cOrigem == "EEQ"
            (cAliasEF3)->EF3_INVOIC := cInvoice
            (cAliasEF3)->EF3_PREEMB := cPreemb
            (cAliasEF3)->EF3_PARC   := cParc
         Else
            (cAliasEF3)->EF3_INVIMP := cInvoice
            (cAliasEF3)->EF3_HAWB   := cPreemb
            (cAliasEF3)->EF3_LINHA  := cParc
            (cAliasEF3)->EF3_FORN   := cForn
            (cAliasEF3)->EF3_LOJAFO := cLoja
            (cAliasEF3)->EF3_PO_DI  := cPoDi
         EndIf
         (cAliasEF3)->EF3_MOE_IN := cMoeInv
         (cAliasEF3)->EF3_VL_MOE := nValAux2 - nValBonif
         (cAliasEF3)->EF3_VL_REA := (nValAux2 - nValBonif) * nTxJuros1
         (cAliasEF3)->EF3_TX_MOE := nTxJuros1
         (cAliasEF3)->EF3_DT_EVE := dDt
         (cAliasEF3)->EF3_SEQ    := cSeq

         If(cAliasEF1=="EF1", (cAliasEF1)->(RecLock(cAliasEF1,.F.)), )
         &(cAliasEF1+"->EF1_SLD_JM") -= (cAliasEF3)->EF3_VL_MOE //nValAux2
         &(cAliasEF1+"->EF1_SLD_JR") -= (cAliasEF3)->EF3_VL_REA //nValAux2 * nTxJuros1
         If(cAliasEF1=="EF1", (cAliasEF1)->(msUnlock()), )

         (cAliasEF3)->EF3_TP_EVE := &(cAliasEF1+"->EF1_TP_FIN")

         // ** GFC - 19/04/06
         If lEFFTpMod
            (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
         EndIf
         // **

         //FSM - 10/04/2012
         If Upper(cAliasEF3) == "WORKEF3"
            (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
         EndIf

         (cAliasEF3)->(msUnlock())

         If lCadFin
            EX401GrEncargos(cAliasEF3)
         EndIf
      EndIf
      // **

      //Grava Evento 650 - Transferencia de Juros
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_CODEVE := Left(EV_TJ,2)+Alltrim(Str(Val(aJuros[ni])))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf
      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
         (cAliasEF3)->EF3_ORIGEM := cOrigem
      EndIf
      (cAliasEF3)->EF3_CONTRA := cContrato

      // ACSJ - 06/02/2005
      if lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif

      If cOrigem == "EEQ"
         (cAliasEF3)->EF3_INVOIC := cInvoice
         (cAliasEF3)->EF3_PREEMB := cPreemb
         (cAliasEF3)->EF3_PARC   := cParc
      Else
         (cAliasEF3)->EF3_INVIMP := cInvoice
         (cAliasEF3)->EF3_HAWB   := cPreemb
         (cAliasEF3)->EF3_LINHA  := cParc
         (cAliasEF3)->EF3_FORN   := cForn
         (cAliasEF3)->EF3_LOJAFO := cLoja
         (cAliasEF3)->EF3_PO_DI  := cPoDi
      EndIf

      /* GCC - 17/09/2013
      nValAux1 := 0
      For i:=1 to Len(aTx_Dia)
         //nValAux1 += ((If(cAliasEF1=="M",M->EF1_SL2_PM,(cAliasEF1)->EF1_SL2_PM) + nVal) * aTx_Dia[i,1] * aTx_Dia[i,2]) /100
         nValAux1 += Round((nVal * aTx_Dia[i,1] * aTx_Dia[i,2]) /100,nDecValor)
      Next i
      // ** PLB 29/06/07 - Trata Vinculações antes da data de Inicio de Juros
      If nValAux1 < 0
         nValAux1 := 0
      EndIf
      // **
      */

      (cAliasEF3)->EF3_MOE_IN := cMoeInv
      (cAliasEF3)->EF3_VL_MOE := nValAux1
   // (cAliasEF3)->EF3_VL_REA := nValAux1 * nTaxa
      (cAliasEF3)->EF3_VL_REA := nValAux1 * nTxJuros1
   // (cAliasEF3)->EF3_TX_MOE := nTaxa
      (cAliasEF3)->EF3_TX_MOE := nTxJuros1
      (cAliasEF3)->EF3_DT_EVE := dDataEvento
      (cAliasEF3)->EF3_SEQ    := cSeq

      If cAliasEF1 == "M"
         M->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
         M->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
         M->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
         M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
         If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
            (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN  //'01'  // GFP - 04/11/2014
         Else
            (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
         EndIf
      Else
         (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         (cAliasEF1)->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
         (cAliasEF1)->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
         //MFR 05/10/2021 OSSME-6276
         //If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
         //   (cAliasEF3)->EF3_TP_EVE := "01"
         //Else
            (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
         //EndIf
      EndIf

      // ** GFC - 19/04/06
      If lEFFTpMod
         (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
      EndIf
      // **

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf

      If AvFLags("EEC_LOGIX") .And. !Empty(aNfLoteEF3) .And. (nPosEve := aScan(aNfLoteEF3,{|x| x[1] == (cAliasEF3)->EF3_CODEVE})) > 0
         (cAliasEF3)->EF3_NRLOTE := aNfLoteEF3[nPosEve][2][1]
         (cAliasEF3)->EF3_RELACA := aNfLoteEF3[nPosEve][2][2]
         (cAliasEF3)->EF3_NR_CON := aNfLoteEF3[nPosEve][2][3]
         (cAliasEF3)->EF3_DT_CTB := aNfLoteEF3[nPosEve][2][4]
         (cAliasEF3)->EF3_TX_CTB := aNfLoteEF3[nPosEve][2][5]
      EndIf

      (cAliasEF3)->(msUnlock())

      If cChamada=="CAMB"
         oEFFContrato:EventoEF3("INCLUSAO")
      EndIf

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf

      // AAF 19/09/2012 - Utilizar a taxa da ultima contabilização do evento para que não ocorrem divergencias entre taxa de compra e venda.
      If Empty(nTx520Ctb := GetTxCtb(cAliasEF3, "52"+aJuros[ni],cTpModu, "", "",dDataEvento)[1])
         nTx520Ctb := nTxJuros2
      EndIf

      //Grava Evento 550/551 - Variação Cambial sobre Provisão de Juros
      //nVcProv := (nValAux1 - nValAux2) * (nTxJuros1 - nTx520Ctb) // AAF 19/09/2012

	  //AAF 17/07/2015 - Nova forma de calculo para evitar diferença de 1 centavo para cada 520 gerado na contabilização ACC.
	  //Valor da transferencia em R$ - valor dos juros gerados já atualizados em R$ - valor dos juros anteriores em R$ na ultima correção
	  nVcProv := Round((nValAux1 - nValAux2) * nTxJuros1,2) - Round((nValAux1 - nValAux2) * nTx520Ctb,2) //Round(nValAux1 * nTxJuros1,2) - Round(nValAux2 * nTxJuros1,2) - Round((nValAux1 - nValAux2) * nTx520Ctb,2)

      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf
      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
         (cAliasEF3)->EF3_ORIGEM := cOrigem
      EndIf
      (cAliasEF3)->EF3_CONTRA := cContrato

      // ACSJ - 06/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif

      //(cAliasEF3)->EF3_CODEVE := EV_VC_PJ
      // (cAliasEF3)->EF3_CODEVE := IF(((nValAux2 - nValAux1) * nTaxa) - ((nValAux2 - nValAux1) * nTxCtb)>0,'550','551')
      (cAliasEF3)->EF3_CODEVE := IF(nVcProv>0,Alltrim(Str(550+(Val(aJuros[ni])*2))),Alltrim(Str(551+(Val(aJuros[ni])*2))))
      If cOrigem == "EEQ"
         (cAliasEF3)->EF3_INVOIC := cInvoice
         (cAliasEF3)->EF3_PREEMB := cPreemb
         (cAliasEF3)->EF3_PARC   := cParc
      Else
         (cAliasEF3)->EF3_INVIMP := cInvoice
         (cAliasEF3)->EF3_HAWB   := cPreemb
         (cAliasEF3)->EF3_LINHA  := cParc
         (cAliasEF3)->EF3_FORN   := cForn
         (cAliasEF3)->EF3_LOJAFO := cLoja
         (cAliasEF3)->EF3_PO_DI  := cPoDi
      EndIf
      // (cAliasEF3)->EF3_VL_REA := ((nValAux2 - nValAux1) * If(cAliasEF1=="M",M->EF1_TX_CTB,(cAliasEF1)->EF1_TX_CTB) - ((nValAux2 - nValAux1) * nTaxa))
      (cAliasEF3)->EF3_MOE_IN := cMoeInv
      // (cAliasEF3)->EF3_VL_REA := ((nValAux2 - nValAux1) * nTaxa) - ((nValAux2 - nValAux1) * nTxCtb)
      (cAliasEF3)->EF3_VL_REA := nVcProv // VI 27/07/05
      // (cAliasEF3)->EF3_TX_MOE := nTaxa
      (cAliasEF3)->EF3_TX_MOE := nTxJuros1
      (cAliasEF3)->EF3_DT_EVE := dDataEvento
      (cAliasEF3)->EF3_SEQ    := cSeq

      // ** GFC - 19/04/06
      If lEFFTpMod
         (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
      EndIf
      // **

      //If ((nValAux1 - nValAux2) * nTxJuros1) - ((nValAux1 - nValAux2) * nTxJuros2) > 0 //(cAliasEF3)->EF3_CODEVE = '550' VI 27/07/05 //FSM - 04/09/2012
         If cAliasEF1 == "M"
   //       M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
            M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
         Else
            //(cAliasEF1)->(RecLock(cAliasEF1,.F.)) //FSM - 04/09/2012
   //       (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
            (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
         EndIf
      /*Else //FSM - 04/09/2012
         If cAliasEF1 == "M"
   //       M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
            M->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
           (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
         Else
            (cAliasEF1)->(RecLock(cAliasEF1,.F.))
   //       (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
            (cAliasEF1)->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
            (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
         EndIf

      Endif*/

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf
      
      If AvFLags("EEC_LOGIX") .And. !Empty(aNfLoteEF3) .And. (nPosEve := aScan(aNfLoteEF3,{|x| x[1] == (cAliasEF3)->EF3_CODEVE})) > 0
         (cAliasEF3)->EF3_NRLOTE := aNfLoteEF3[nPosEve][2][1]
         (cAliasEF3)->EF3_RELACA := aNfLoteEF3[nPosEve][2][2]
         (cAliasEF3)->EF3_NR_CON := aNfLoteEF3[nPosEve][2][3]
         (cAliasEF3)->EF3_DT_CTB := aNfLoteEF3[nPosEve][2][4]
         (cAliasEF3)->EF3_TX_CTB := aNfLoteEF3[nPosEve][2][5]
      EndIf

      (cAliasEF3)->(msUnlock())

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf

      If lPVez
         //Grava Evento 500/501 - Variação Cambial do Principal

         //** AAF - 28/01/2015 - Utilizar cotação da ultima contabilização. Pode ser diferente do gravado no campo EF1_TX_CTB (pode ser compra/venda).
		 aTx500 := GetTxCtb(cAliasEF3, "500",cTpModu, "", "",dDataEvento)
		 aTx501 := GetTxCtb(cAliasEF3, "501",cTpModu, "", "",dDataEvento)

       If Empty(aTx500[2]) .And. Empty(aTx501[2])
         If dDataEvento < dContab
            nTxCtb := nTx100
         EndIf
       Else
         If aTx500[2] > aTx501[2]
            nTxCtb := aTx500[1]
         ElseIf aTx501[2] > aTx500[2] .OR. !Empty(aTx501[2])
            nTxCtb := aTx501[1]
         EndIf
       EndIf
		 //**

         // PLB 29/06/07 - Identifica tratamento ACE
         lVincACE := IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACE  .And.  dDataEvento < IIF(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)
         (cAliasEF3)->(RecLock(cAliasEF3,.T.))
         (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
         If ValType(cFilORI) == "C"
            (cAliasEF3)->EF3_FILORI := cFilORI
         EndIf
         If lEFFTpMod
            (cAliasEF3)->EF3_TPMODU := cTpModu
            (cAliasEF3)->EF3_ORIGEM := cOrigem
         EndIf
         (cAliasEF3)->EF3_CODEVE := EV_VC_PRC
         (cAliasEF3)->EF3_CONTRA := cContrato

         // ACSJ - 06/02/2005
         if lTemChave
            (cAliasEF3)->EF3_BAN_FI := cBanco
            (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
            (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,(cAliasEF1)->EF1_NCONFI)
            (cAliasEF3)->EF3_PRACA  := cPraca
            If lEFFTpMod
               (cAliasEF3)->EF3_SEQCNT := cSeqCon
            EndIf
         Endif

         If cOrigem == "EEQ"
            (cAliasEF3)->EF3_INVOIC := cInvoice
            (cAliasEF3)->EF3_PREEMB := cPreemb
            (cAliasEF3)->EF3_PARC   := cParc
         Else
            (cAliasEF3)->EF3_INVIMP := cInvoice
            (cAliasEF3)->EF3_HAWB   := cPreemb
            (cAliasEF3)->EF3_LINHA  := cParc
            (cAliasEF3)->EF3_FORN   := cForn
            (cAliasEF3)->EF3_LOJAFO := cLoja
            (cAliasEF3)->EF3_PO_DI  := cPoDi
         EndIf
         // (cAliasEF3)->EF3_VL_REA := (nVal * nTaxa) - (nVal * If(cAliasEF1=="M",M->EF1_TX_CTB,(cAliasEF1)->EF1_TX_CTB))
         (cAliasEF3)->EF3_MOE_IN := cMoeInv
         (cAliasEF3)->EF3_VL_REA := Round(nVal * nTaxa, nDecValor) - Round(nVal * nTxCtb, nDecValor) //FSM - 09/11/2012
         (cAliasEF3)->EF3_TX_MOE := nTaxa
         (cAliasEF3)->EF3_TX_CON := (cAliasEF3)->EF3_VL_REA / (cAliasEF3)->EF3_VL_INV
         (cAliasEF3)->EF3_DT_EVE := dDataEvento
         (cAliasEF3)->EF3_DT_CIN := dDataBase
         (cAliasEF3)->EF3_SEQ    := cSeq
         If cAliasEF1 == "M"
            M->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
            If (cAliasEF3)->EF3_VL_REA < 0
			      (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
			   EndIf
         Else
            (cAliasEF1)->(RecLock(cAliasEF1,.F.))
            //(cAliasEF1)->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF1)->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
            //MFR 05/10/2021 OSSME-6276
            //If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
            //   (cAliasEF3)->EF3_TP_EVE := "01"
            //Else
               (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
            //EndIf
            /*If (cAliasEF1)->EF1_TX_CTB > 0 .and. (cAliasEF3)->EF3_TX_MOE < (cAliasEF1)->EF1_TX_CTB
               (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
            ElseIf (cAliasEF1)->EF1_TX_CTB <= 0 .and. (cAliasEF3)->EF3_TX_MOE < nTx100
               (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
            EndIf*/
			   If (cAliasEF3)->EF3_VL_REA < 0
			      (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
   			EndIf
         EndIf

         // ** GFC - 19/04/06
         If lEFFTpMod
            (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
         EndIf
         // **

         // ** PLB 29/06/07 - Trata vinculação antes da data de início de Juros (para Contratos ACE)
         /*If lVincACE
            If (cAliasEF3)->EF3_CODEVE == EV_VC_PRC
               (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
            ElseIf (cAliasEF3)->EF3_CODEVE == EV_VC_PRC1
               (cAliasEF3)->EF3_CODEVE := EV_VC_PRC
            EndIf
            (cAliasEF3)->EF3_VL_REA *= -1
            (cAliasEF3)->EF3_TX_CON *= -1
            If cAliasEF1 == "M"
               M->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
            Else
               (cAliasEF1)->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
            EndIf
         EndIf*/  //NCF - 14/01/2014 - Nopado o tratamento não aderente a contabilização de cliente da integração via Mensagem Única.
         // **    //                   NEcessário alinhar o conceito caso seja necessário voltar este tratamento.

         //FSM - 10/04/2012
         If Upper(cAliasEF3) == "WORKEF3"
            (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
         EndIf

         If AvFLags("EEC_LOGIX") .And. !Empty(aNfLoteEF3) .And. (nPosEve := aScan(aNfLoteEF3,{|x| x[1] == (cAliasEF3)->EF3_CODEVE})) > 0
            (cAliasEF3)->EF3_NRLOTE := aNfLoteEF3[nPosEve][2][1]
            (cAliasEF3)->EF3_RELACA := aNfLoteEF3[nPosEve][2][2]
            (cAliasEF3)->EF3_NR_CON := aNfLoteEF3[nPosEve][2][3]
            (cAliasEF3)->EF3_DT_CTB := aNfLoteEF3[nPosEve][2][4]
            (cAliasEF3)->EF3_TX_CTB := aNfLoteEF3[nPosEve][2][5]
         EndIf
         
         (cAliasEF3)->(msUnlock())

         If lCadFin
            EX401GrEncargos(cAliasEF3)
         EndIf
      EndIf

   Next ni

   If cChamada == "MANUT1"
      cSeq := StrZero(Val(cSeq) + 1,4,0)
   EndIf

ElseIf cChamada == "MANUT1"
   cSeq := StrZero(Val(cSeq) + 1,4,0)
EndIf

If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) // ** GFC - Pré-Pagamento/Securitização
   If cAliasEF1 == "M"
      If (cAliasEF3)->EF3_TP_EVE <> ACE //NCF - 30/03/2016 - apurar saldo do contrato ACE corretamente apos vinculacao de invoice
         M->EF1_SLD_PM -= nVal
         M->EF1_SLD_PR -= nVal * nTaxa
         M->EF1_SL2_PM += nVal
         M->EF1_SL2_PR += nVal * nTaxa
      EndIf
   Else
      (cAliasEF1)->(RecLock(cAliasEF1,.F.))
      If (cAliasEF3)->EF3_TP_EVE <> ACE     //NCF - 30/03/2016 - apurar saldo do contrato ACE corretamente apos vinculacao de invoice
         (cAliasEF1)->EF1_SLD_PM -= nVal
         (cAliasEF1)->EF1_SLD_PR -= nVal * nTaxa
         (cAliasEF1)->EF1_SL2_PM += Round(nVal,2) //nVal
         (cAliasEF1)->EF1_SL2_PR += Round(nVal * nTaxa, 2) //nVal * nTaxa
      EndIf
      (cAliasEF1)->(msUnlock())
   EndIf
EndIf

// Verifica se houve Saldo menor que 0.50
nSaldoOr := If(cAliasEF1 == "M", If( M->EF1_TP_FIN <> ACE, M->EF1_SLD_PR, M->EF1_SL2_PR ), If( (cAliasEF1)->EF1_TP_FIN <> ACE, (cAliasEF1)->EF1_SLD_PR, (cAliasEF1)->EF1_SL2_PR )  ) //NCF - 30/03/2016 - apurar saldo do contrato ACE corretamente
//nSaldo   := If(cAliasEF1 == "M", M->EF1_SLD_PR, (cAliasEF1)->EF1_SLD_PR) * If(nSaldo < 0, -1, 1)

If Abs(nSaldoOr) <= 0.5 .And. lACCACE
   // Zera Saldo
   If cAliasEF1 <> "M"
      (cAliasEF1)->(RecLock(cAliasEF1,.F.))
      (cAliasEF1)->EF1_SLD_PR := 0.00
      (cAliasEF1)->(msUnlock())
   Else
      M->EF1_SLD_PR := 0.00
   Endif
   // Joga a Diferença do Saldo na V.C. 500
   (cAliasEF3)->(RecLock(cAliasEF3,.F.))
   (cAliasEF3)->EF3_VL_REA += nSaldoOr
   (cAliasEF3)->(msUnlock())
Endif

If cChamada=="CAMB"
   oEFFContrato:EventoFinanceiro("ATUALIZA_PROVISORIOS")
   If lNewEFFObj
      oEFFContrato:ShowErrors()
   EndIf
EndIf

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato.
EX401Saldo(cAliasEF1,IIF(lEFFTpMod,cMod,),&(cAliasEF1+"->EF1_CONTRA"),IIF(lTemChave,&(cAliasEF1+"->EF1_BAN_FI"),),IIF(lTemChave,&(cAliasEF1+"->EF1_PRACA"),),IIF(lEFFTpMod,&(cAliasEF1+"->EF1_SEQCNT"),),cAliasEF3,.T.)

End TransAction
//Alcir Alves -19-10-05
If EasyEntryPoint("EFFEX400")
   ExecBlock("EFFEX400",.F.,.F.,"GRV_EVENTO_EFF")
Endif
//
Return nRec600

*------------------------------------------------------------------------------*
//AAF 23/02/2006 - Adicionado os parâmetros:
//                 cSeqCon - Sequencia do Contrato - EF1_SEQCNT
//                 cTpModu - Modulo "E" - Exportação e "I" - Importação.
Function EX400Liquida(cContrato,cInvoice,cParc,cPreemb,nValor,cMoeInv,cMoeCont,;
                      cAliasEF1,cAliasEF3,cChamada,nTx,dData,dDtLiq,dDtRealLiq,cFilOri,;
                      nVlMoeAnt,nVlMoeAtu,nVlReaAnt,nVlReaAtu,cBanco,cAgencia,;
                      cConta,cPraca,lBxForc,nValorRea,cParcAux,cNrOp,nRecEF3Liq,;
                      cTpModu,cSeqCon,cOrigem,cForn,cLojaFo,cPo_Di,nVlMoeLiq,lEvRefi,lExecLiq)
*------------------------------------------------------------------------------*
Local cSeq, nVal1, nTaxa1, aTx_Dia:={}, nValAux1:=0, dDt, i, aTx_Ctb:={}, nOldRec, nValAux2:=0
Local nPJAnt:=0, nEF3Ord := (cAliasEF3)->(IndexOrd()), nTxCtb := 0, nTxVinc := 0
Local nOrdEF3, nRecEF3, nTx600:=0, dDtProvJur, nVLMOE640:=0, nVLREAL640 :=0, nVLMOE520:=0, nVLREAL520 :=0   //HVR 27/04/06 nRecEF3
Local dDtCont:=EasyGParam("MV_MESPEXP",,""), dDtEve600:=avCtoD("  /  /  "), dDtEve100:=avCtoD("  /  /  ")
Local nTxJuros1, nTxJuros2, nPJAntR:=0, ni, aJuros:={}, lPVez:=.T., lBaixouParc:=.F., lAlterouData:=.F., nj
Local nRec630, nMOE520Dif:=0, nREAL520Dif:=0 //GFC - 22/07/05
Local nRec640, nRec550 // ** GFC - 21/09/05
Local nEFF0002:=EasyGParam("MV_EFF0002",,0)
// ACSJ - Caetano - 24/01/2005
Local nInd := SX3->(IndexOrd())
Local nMV_EFF0003 := 1 //EasyGParam("MV_EFF0003",,0)
// ** GFC - Pré-Pagamento/Securitização
Local cParcVin:="", cEvVin:="", nValMoeEF3
Local cEvLiq:=""
Local lLiquida := IIF(nVlMoeLiq==NIL,.F.,.T.)
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Local nDecTaxa := AVSX3("EF3_TX_MOE",4)
Local dDtEve650   //NCF - 06/06/2014
local lLogix := AVFLAGS("EEC_LOGIX")
Local aCpsRefin := {}
Local dDt520Ate
Local aDadosEF3,iCpoEF3
Local nRecAnt
Private aEF3AltEAI := If( IsMemVar("aEF3AltEAI"), aEF3AltEAI, ARRAY(0) )
Default lEvRefi := .F.  // GFP - 09/10/2015

If lEvRefi
   aAdd(aCpsRefin,EF3->EF3_TPMOOR)
   aAdd(aCpsRefin,EF3->EF3_CONTOR)
   aAdd(aCpsRefin,EF3->EF3_BAN_OR)
   aAdd(aCpsRefin,EF3->EF3_PRACOR)
   aAdd(aCpsRefin,EF3->EF3_SQCNOR)
   aAdd(aCpsRefin,EF3->EF3_PARCOR)
   aAdd(aCpsRefin,EF3->EF3_IVIMOR)
   aAdd(aCpsRefin,EF3->EF3_LINOR)
   aAdd(aCpsRefin,EF3->EF3_CDEVOR)
EndIf

If(cTpModu==NIL .Or. Empty(cTpModu),cTpModu:="E",)
If(cOrigem==NIL,cOrigem:="EEQ",)

If cChamada == "CAMB" .or. If( lLogix, cChamada $ "CAMB/FFC", .F. )  //NCF - 16/10/2014
   oEFFContrato := AvEFFContra():LoadEF1()
EndIf

Default lExecLiq:= .F.
/* WFS - a flag será ativada por passagem de parâmetro na chamada da função.
   O parâmetro será considerado na chamada da função (origem). */
lLiqAuto := lExecLiq//EasyGParam("MV_LIQAUTO",,.F.)
// **
//dDtCont := If(cAliasEF1=="M",Strzero(Month(M->EF1_DT_CTB),2,0)+Strzero(Year(M->EF1_DT_CTB),4,0),Strzero(Month((cAliasEF1)->EF1_DT_CTB),2,0)+Strzero(Year((cAliasEF1)->EF1_DT_CTB),4,0))

// ** PLB 13/06/07
//If !Empty(cTpModu)  .And.  cTpModu == EXP
If cTpModu == NIL .OR. cTpModu <> IMP //AAF 24/10/2007 - Também é necessário verificar a contabilidade caso não haja cTpModu
   //Verifica se o Contrato está contabilizado
   If AvFlags("SIGAEFF_SIGAFIN") .OR. !EasyGParam("MV_EEC_ECO",,.F.)
      lIsContab := !Empty(EF1->EF1_DT_CTB)
   Else
      lIsContab := EX401IsCtb(cContrato,IIF(lTemChave,cBanco,""),IIF(lTemChave,cPraca,""),IIF(lEFFTpMod,cSeqCon,""))
   EndIf
Else
   lIsContab := .F.
EndIf

If cAliasEF1=="M"
   If Empty(M->EF1_DT_CTB)  .Or.  !lIsContab
      dDtCont := Strzero(Month(M->EF1_DT_JUR),2,0)+Strzero(Year(M->EF1_DT_JUR),4,0)
   Else
      dDtCont := Strzero(Month(M->EF1_DT_CTB),2,0)+Strzero(Year(M->EF1_DT_CTB),4,0)
   EndIf
Else
   If Empty((cAliasEF1)->EF1_DT_CTB)  .Or.  !lIsContab
      dDtCont := Strzero(Month((cAliasEF1)->EF1_DT_JUR),2,0)+Strzero(Year((cAliasEF1)->EF1_DT_JUR),4,0)
   Else
      dDtCont := Strzero(Month((cAliasEF1)->EF1_DT_CTB),2,0)+Strzero(Year((cAliasEF1)->EF1_DT_CTB),4,0)
   EndIf
EndIf
// **

SX3->(DbSetOrder(2))
Private lTemPgJuros:=  SX3->(DBSeek("EF1_PGJURO"))
SX3->(DbSetOrder(nInd))
//----------------------------------------------------
Private cChamaPRW := cChamada  //Alcir Alves - 20-09-05 - define como private o cChamada para tratamento em rdmakes
Private dDataLiq

lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0
lEF3_EV_FO  := EF3->(FieldPos("EF3_EV_FO" )) > 0
lEF4_MOTIVO := EF4->(FieldPos("EF4_MOTIVO")) > 0
lEF1_JR_ANT := EF1->(FieldPos("EF1_JR_ANT")) > 0
lEF1_DTBONI := EF1->(FieldPos("EF1_DTBONI")) > 0 .and. EF2->(FieldPos("EF2_BONUS")) > 0
If(lBxForc=NIL,lBxForc:=.F.,)

dData    := If(dData<>NIL ,dData ,dDataBase)
dDataLiq := If(dDtLiq<>NIL.and.!Empty(dDtLiq),dDtLiq,dData)
dDtRealLiq := If(dDtRealLiq<>NIL.and.!Empty(dDtRealLiq),dDtRealLiq,dDataLiq)

If EasyEntryPoint("EFFEX400")
   ExecBlock("EFFEX400",.F.,.F.,"LIQUIDACAO FINANCIAMENTO")
Endif

If lLiquida
   nVal1 := nVlMoeLiq
Else
   nVal1 := EX400Conv(cMoeInv,cMoeCont,nValor)
EndIf
nVal1 := Round(nVal1,nDecValor)

nTaxa1 := If(nTx = NIL, EX400Conv(cMoeCont,,nVal1) / nVal1, nTx)
nTaxa1 := Round(nTaxa1,nDecTaxa)

nRecEF3 := (cAliasEF3)->(Recno())               //HVR 27/04/06
nInd := (cAliasEF3)->(IndexOrd())
If cAliasEF3 == "EF3"
   EF3->(dbSetOrder(1))
   cSeqLiq := EF3->EF3_SEQ
Else
   If cTpModu == "E"
      WorkEF3->(dbSetOrder(2))//"EF3_CODEVE+EF3_INVOIC+EF3_PARC+DtoS(EF3_DT_EVE)"
   Else
      WorkEF3->(dbSetOrder(9))//"EF3_CODEVE+EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA"
   EndIf
   cEvLiq  := (cAliasEF3)->EF3_CODEVE
   cSeqLiq := (cAliasEF3)->EF3_SEQ
EndIf

If ( /*cMod == IMP .AND.*/ ( (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG .OR. Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2) )) .OR. ;  //PLB 23/06/06
   (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")+EV_EMBARQUE+If(cAliasEF3=="WorkEF3",If(!lEFFTpMod .OR. cTpModu=="E",cInvoice,cForn+cLojaFo+cInvoice),"")+If(cAliasEF3 == "EF3" .AND. (cOrigem == "SWB" .OR. cOrigem == "EF3"),Space(AvSx3("EF3_PARC",3))+If(cAliasEF3=="EF3",Space(AvSx3("EF3_INVOIC",3)),""),"")+IIF((cOrigem == "SWB" .OR. cOrigem == "EF3"),If(cAliasEF3=="EF3",cInvoice,"")+If(cParcAux<>NIL,cParcAux,cParc),If(cParcAux<>NIL,cParcAux,cParc)+If(cAliasEF3=="EF3",cInvoice,"")))) //600


   // ** GFC - 26/05/05
   If nRecEF3Liq = NIL .or. nRecEF3Liq = 0
      nOldRec := (cAliasEF3)->(RecNo())
      If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+if(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")+If(!lPrePag .or. (cAliasEF3)->EF3_EV_VIN==EV_PRINC_PREPAG,EV_LIQ_PRC,EV_LIQ_JUR)+If(cAliasEF3=="WorkEF3",If(!lEFFTpMod .OR. cTpModu=="E",cInvoice,cForn+cLojaFo+cInvoice),"")+If((cOrigem == "SWB" .OR. cOrigem == "EF3"),Space(AvSx3("EF3_PARC",3))+If(cAliasEF3=="EF3",Space(AvSx3("EF3_INVOIC",3)),""),"")+If(cAliasEF3=="EF3",cInvoice,"")+cParc)) //630 ou 640
         ni:=0
         Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and.;
         If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA==If(lEFFTpMod,cTpModu,"")+cContrato .and. EF3->EF3_BAN_FI==cBanco .and. EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==cPraca+If(lEFFTpMod,cSeqCon,""),.T.) .and.;
         (cAliasEF3)->EF3_CODEVE==If(!lPrePag .or. (cAliasEF3)->EF3_EV_VIN==EV_PRINC_PREPAG,EV_LIQ_PRC,EV_LIQ_JUR) .and.;
         If(cAliasEF3=="WorkEF3",If(!lEFFTpMod .OR. cOrigem == "EEQ",(cAliasEF3)->EF3_INVOIC+(cAliasEF3)->EF3_PARC==cInvoice+cParc,(cAliasEF3)->(EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA) == cForn+cLojaFo+cInvoice+cParc),.T.)
            ni++
            If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1" //AAF - 30/03/2006 - FINIMP - If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04") // ** GFC - Pré-Pagamento/Securitização
               cSeq      := (cAliasEF3)->EF3_SEQ
            EndIf
            (cAliasEF3)->(dbSkip())
         EndDo
         (cAliasEF3)->(dbGoTo(nOldRec))
         (cAliasEF3)->(dbSkip(ni))
         If !(!(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and.;
         If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA==If(lEFFTpMod,cTpModu,"")+cContrato .and. EF3->EF3_BAN_FI==cBanco .and. EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==cPraca+If(lEFFTpMod,cSeqCon,""),.T.) .and.;
         (cAliasEF3)->EF3_CODEVE==EV_EMBARQUE .and. If(cAliasEF3=="WorkEF3",If(!lEFFTpMod .OR. cOrigem == "EEQ",EF3->EF3_INVOIC+EF3->EF3_PARC==cInvoice+If(cParcAux<>NIL,cParcAux,cParc),(cAliasEF3)->(EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA)==cForn+cLojaFo+cInvoice+If(cParcAux<>NIL,cParcAux,cParc)),.T.) )
            (cAliasEF3)->(dbGoTo(nOldRec))
         EndIf
      Else
         (cAliasEF3)->(dbGoTo(nOldRec))
         Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and.;
         If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA==If(lEFFTpMod,cTpModu,"")+cContrato .and. EF3->EF3_BAN_FI==cBanco .and. EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==cPraca+If(lEFFTpMod,cSeqCon,""),.T.) .and.;
         (cAliasEF3)->EF3_CODEVE==EV_EMBARQUE .and. If(cAliasEF3=="WorkEF3",If(!lEFFTpMod .OR. cTpModu=="E",EF3->EF3_INVOIC+EF3->EF3_PARC==cInvoice+If(cParcAux<>NIL,cParcAux,cParc),(cAliasEF3)->(EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA)==cForn+cLojaFo+cInvoice+If(cParcAux<>NIL,cParcAux,cParc)),.T.) .and.;
         nVal1 <> (cAliasEF3)->EF3_VL_MOE
            (cAliasEF3)->(dbSkip())
         EndDo
         If !(!(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and.;
         If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA==If(lEFFTpMod,cTpModu,"")+cContrato .and. EF3->EF3_BAN_FI==cBanco .and. EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,"")==cPraca+If(lEFFTpMod,cSeqCon,""),.T.) .and.;
         (cAliasEF3)->EF3_CODEVE==EV_EMBARQUE .and. If(cAliasEF3=="WorkEF3",If(!lEFFTpMod .OR. cTpModu=="E",EF3->EF3_INVOIC+EF3->EF3_PARC==cInvoice+If(cParcAux<>NIL,cParcAux,cParc),(cAliasEF3)->(EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA)==cForn+cLojaFo+cInvoice+If(cParcAux<>NIL,cParcAux,cParc)),.T.) )
            (cAliasEF3)->(dbGoTo(nOldRec))
         EndIf
      EndIf
   Else
      (cAliasEF3)->(dbGoTo(nRecEF3Liq))
   Endif
   // **

   nTx600    := (cAliasEF3)->EF3_TX_MOE
   dDtEve600 := (cAliasEF3)->EF3_DT_EVE
   // ** GFC - 08/08/05
   If cMoeInv <> cMoeCont
      If lLiquida
         nVal1 := nVlMoeLiq
      Else                                       //Valor Ev.600 Conv.                                          //Valor conforme tx. Liquidação
         nVal1  := If( cMoeCont <> MOEDA_REAIS , ((cAliasEF3)->EF3_VL_MOE / (cAliasEF3)->EF3_VL_INV) * nValor , nValorRea )
      EndIf
      nVal1 := Round(nVal1,nDecValor)
      nTaxa1 := Round(EX400Conv(cMoeCont,,nVal1) / nVal1,nDecTaxa)
   EndIf
   // **
   If lEF3_EV_FO .and. lBxForc
      (cAliasEF3)->EF3_EV_FO := "1"
   EndIf
   // ** GFC - Pré-Pagamento/Securitização
   If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04") //cTpModu == EXP .and.
      If cAliasEF3 == "EF3"
         (cAliasEF3)->(dbSetOrder(1))
      Else
         WorkEF3->(dbSetOrder(2))//"EF3_CODEVE+EF3_INVOIC+EF3_PARC+DtoS(EF3_DT_EVE)"
      EndIf
      cParcVin   := (cAliasEF3)->EF3_PARVIN
      cEvVin     := (cAliasEF3)->EF3_EV_VIN
      If  (/*cMod == IMP .AND.*/ ( (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG .OR. Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)) ; //PLB 23/06/06
         .Or. (cMod == EXP .AND. (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")+(cAliasEF3)->EF3_EV_VIN+If(cAliasEF3=="WorkEF3",Space(Len(EF3->EF3_INVOIC)),"")+(cAliasEF3)->EF3_PARVIN))));
         .And. If(lEF3_EV_FO,(cAliasEF3)->EF3_EV_FO <> "1" .or. lBxForc,.T.)
         If cChamada $ ("CAMB/FFC") .and. lLogix
            AF200BkPInt( cAliasEF3 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
            aDadosEF3 := {}
            For iCpoEF3 := 1 To EF3->(FCount())
               aAdd(aDadosEF3, EF3->(FieldGet(iCpoEF3)))
            Next iCpoEF3
         EndIf
         (cAliasEF3)->(RecLock(cAliasEF3,.F.))
         nValMoeEF3:=(cAliasEF3)->EF3_VL_MOE
         If cChamada <> "MANUT2" .OR. ( /*cMod == IMP .AND.*/ ( (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG .OR. Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2) ))
            If cMod == EXP  .And.  Left(cEvLiq,2) == Left(EV_JUROS_PREPAG,2)  // PLB 26/06/06
               (cAliasEF3)->EF3_SLDLIQ := 0
               (cAliasEF3)->EF3_LIQ_RS := nValorRea
            Else
               /* WFS set-2016: controla a atualização dos registros, para que não ocorra duas vezes. */
               If !lLiqAuto
                  (cAliasEF3)->EF3_SLDLIQ -= nVal1
                  (cAliasEF3)->EF3_LIQ_RS += nValorRea
               Else
                  (cAliasEF3)->EF3_SLDLIQ += ((cAliasEF3)->EF3_SLDLIQ - nVal1)
                  (cAliasEF3)->EF3_LIQ_RS += (nValorRea - (cAliasEF3)->EF3_LIQ_RS)
               EndIf
            EndIf
         EndIf
         If (cAliasEF3)->EF3_SLDLIQ <= 0
            (cAliasEF3)->EF3_SLDLIQ := 0

            /* Flag indicará que a liquidação automática poderá ocorrer, já que o evento foi totalmente liquidado. */
            lExecLiq:= .T.
            If lLiqAuto .or. cChamada == "MANUT2"

               //Grava Log da alteração
               If (cAliasEF3)->EF3_DT_EVE <> dDtRealLiq
                  lAlterouData := .T.
                  If cChamada $ ("CAMB/FFC")
                     EF4->(RecLock("EF4",.T.))
                     EF4->EF4_FILIAL := xFilial("EF4")
                     EF4->EF4_CONTRA := cContrato

                     If lEFFTpMod
                        EF4->EF4_TPMODU := cTpModu
                     EndIf

                     If lTemChave
                        EF4->EF4_BAN_FI := cBanco
                        EF4->EF4_PRACA  := cPraca
                        If lEFFTpMod
                           EF4->EF4_SEQCNT := cSeqCon
                        EndIf
                     Endif
                     If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                        EF4->EF4_TP_EVE := "02"
                     Else
                        EF4->EF4_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                     EndIf
                     EF4->EF4_CAMPO  := AVSX3("EF3_DT_EVE",5)
                     EF4->EF4_CODEVE := (cAliasEF3)->EF3_CODEVE
                     EF4->EF4_SEQ    := (cAliasEF3)->EF3_SEQ
                     EF4->EF4_DE     := AVSX3("EF3_DT_EVE",5)+STR0110+DtoC((cAliasEF3)->EF3_DT_EVE) // " de "
                     EF4->EF4_PARA   := AVSX3("EF3_DT_EVE",5)+STR0111+DtoC(dDtRealLiq) //" para "
                     EF4->EF4_USUARI := cUserName
                     EF4->EF4_DATA   := dDataBase
                     EF4->EF4_HORA   := SubStr(Time(),1,5)
                     If lEF4_MOTIVO
                        EF4->EF4_MOTIVO := STR0222//"PAGAMENTO DA PARCELA"
                     EndIf
                     EF4->(msUnlock())
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( "EF4" , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                  Else
                     WorkEF4->(reclock("WorkEF4",.T.))
                     WorkEF4->EF4_CONTRA := cContrato
                     If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                        WorkEF4->EF4_TP_EVE := "02"
                     Else
                        WorkEF4->EF4_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                     EndIf
                     WorkEF4->EF4_CAMPO  := AVSX3("EF3_DT_EVE",5)
                     WorkEF4->EF4_CODEVE := (cAliasEF3)->EF3_CODEVE
                     WorkEF4->EF4_SEQ    := (cAliasEF3)->EF3_SEQ
                     WorkEF4->EF4_DE     := AVSX3("EF3_DT_EVE",5)+STR0110+DtoC((cAliasEF3)->EF3_DT_EVE) // " de "
                     WorkEF4->EF4_PARA   := AVSX3("EF3_DT_EVE",5)+STR0111+DtoC(dDtRealLiq) //" para "
                     WorkEF4->EF4_USUARI := cUserName
                     WorkEF4->EF4_DATA   := dDataBase
                     WorkEF4->EF4_HORA   := SubStr(Time(),1,5)
                     WorkEF4->TRB_ALI_WT := "EF4"
                     WorkEF4->TRB_REC_WT := 0
                     If lEF4_MOTIVO
                        WorkEF4->EF4_MOTIVO := STR0222//"PAGAMENTO DA PARCELA"
                     EndIf
                  EndIf
               EndIf

               //LRS - 17/08/2018
               If Empty((cAliasEF3)->EF3_DTOREV) //AAF 18/07/2015 - Verifica se ja está preenchido
                  (cAliasEF3)->EF3_DT_EVE := dDtRealLiq
                  (cAliasEF3)->EF3_DTOREV := (cAliasEF3)->EF3_DT_EVE//NCF - 27/03/2014 - Gravação da data de liquidação
               EndIf
			   /* Substituido pois o código abaixo sempre ignora o que foi digitado pelo usuário
			   If nTaxa1 = Round((cAliasEF3)->EF3_LIQ_RS/(cAliasEF3)->EF3_VL_MOE,AvSX3("EEQ_TX",4))
                  (cAliasEF3)->EF3_TX_MOE := nTaxa1
               Else
                  (cAliasEF3)->EF3_TX_MOE := Round((cAliasEF3)->EF3_LIQ_RS/(cAliasEF3)->EF3_VL_MOE,nDecTaxa)
               EndIf
			   */
               /* Caso vazio, preenche com o banco de fechamento, para sugerir na liquidação do evento */
               If (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG
                  If Empty((cAliasEF3)->EF3_BANC) .And. Empty((cAliasEF3)->EF3_AGEN) .And. Empty((cAliasEF3)->EF3_NCON)
                     (cAliasEF3)->EF3_BANC:= cBanco
                     (cAliasEF3)->EF3_AGEN:= cAgencia
                     (cAliasEF3)->EF3_NCON:= cConta
                  EndIf
               EndIf

               If nTaxa1 > 0
                  (cAliasEF3)->EF3_TX_MOE := nTaxa1
               Else
                  (cAliasEF3)->EF3_TX_MOE := Round((cAliasEF3)->EF3_LIQ_RS/(cAliasEF3)->EF3_VL_MOE,nDecTaxa)
               EndIf
               (cAliasEF3)->EF3_VL_REA := (cAliasEF3)->EF3_LIQ_RS

               If cEvVin == EV_PRINC_PREPAG .OR. ( /*cMod == IMP .AND.*/ ( (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG .OR. Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)) )//PLB 23/06/06
                  If cAliasEF1 == "M"
                     If Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)  // PLB 09/06/06
                        /* WFS set-2016: controla a atualização dos registros, para que não ocorra duas vezes. */
                        If !lLiqAuto
                           M->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
                        //M->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
                           M->EF1_SLD_JR := ( M->EF1_SLD_JR / (M->EF1_SLD_JM + (cAliasEF3)->EF3_VL_MOE) ) * M->EF1_SLD_JM  // PLB 19/07/06 - Saldo Principal de Juros em Reais de acordo com a Taxa do Evento 100
                           M->EF1_LIQJRM += (cAliasEF3)->EF3_VL_MOE
                           M->EF1_LIQJRR += (cAliasEF3)->EF3_VL_REA
                        Else
                           M->EF1_SLD_JM += M->EF1_SLD_JM - (cAliasEF3)->EF3_VL_MOE
                           M->EF1_SLD_JR := ( M->EF1_SLD_JR / (M->EF1_SLD_JM + (cAliasEF3)->EF3_VL_MOE) ) * M->EF1_SLD_JM  // PLB 19/07/06 - Saldo Principal de Juros em Reais de acordo com a Taxa do Evento 100
                           M->EF1_LIQJRM += (cAliasEF3)->EF3_VL_MOE - M->EF1_LIQJRM
                           M->EF1_LIQJRR += (cAliasEF3)->EF3_VL_REA - M->EF1_LIQJRR
                        EndIf
                     Else
                        M->EF1_SLD_PM -= (cAliasEF3)->EF3_VL_MOE
                        M->EF1_SLD_PR -= (cAliasEF3)->EF3_VL_REA
                        M->EF1_LIQPRM += (cAliasEF3)->EF3_VL_MOE
                        M->EF1_LIQPRR += (cAliasEF3)->EF3_VL_REA
                     EndIf
                     // ** GFC - 08/08/05 - Caso o saldo restante do contrato esteja menor que o valor informado no MV_EFF0002 deve preencher a data de encerramento automaticamente.
                     If M->EF1_SLD_PM < nEFF0002 .And. IIF(lEFFTpMod .And. M->EF1_CAMTRA=="1",M->EF1_SLD_JM == 0,!EX401JrOpen(cAliasEF1,cAliasEF3)) .and.;
                     lTemPgJuros .and. M->EF1_PGJURO $ cSim
                        If cChamada <> "FFC"
                           EX401Encerra(cContrato,cBanco,cPraca,M->EF1_SLD_PM,cAliasEF1,dDtRealLiq,NIL,NIL,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))
                        ElseIf cBaixaCont == "2"
                           If MsgYesNo(EX401STR(69)) //"Confirma o encerramente automatico dos processos?"
                              M->EF1_DT_ENC := dDtRealLiq
                              cBaixaCont := "1"
                           Else
                              cBaixaCont := "3"
                           EndIf
                        ElseIf cBaixaCont == "1"
                           M->EF1_DT_ENC := dDtRealLiq
                        EndIf
                     EndIf
                     // **
                  Else
                     (cAliasEF1)->(RecLock(cAliasEF1,.F.))
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                     If Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)  // PLB 09/06/06 - Se for juros baixa saldo
                        /* WFS set-2016: controla a atualização dos registros, para que não ocorra duas vezes. */
                        If !lLiqAuto
                           (cAliasEF1)->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
                           //(cAliasEF1)->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
                           (cAliasEF1)->EF1_SLD_JR := ( (cAliasEF1)->EF1_SLD_JR / ((cAliasEF1)->EF1_SLD_JM + (cAliasEF3)->EF3_VL_MOE) ) * (cAliasEF1)->EF1_SLD_JM  // PLB 19/07/06 - Saldo Principal de Juros em Reais de acordo com a Taxa do Evento 100
                           (cAliasEF1)->EF1_LIQJRM += (cAliasEF3)->EF3_VL_MOE
                           (cAliasEF1)->EF1_LIQJRR += (cAliasEF3)->EF3_VL_REA
                        Else
                           (cAliasEF1)->EF1_SLD_JM += (cAliasEF1)->EF1_SLD_JM - (cAliasEF3)->EF3_VL_MOE
                           (cAliasEF1)->EF1_SLD_JR := ( (cAliasEF1)->EF1_SLD_JR / ((cAliasEF1)->EF1_SLD_JM + (cAliasEF3)->EF3_VL_MOE) ) * (cAliasEF1)->EF1_SLD_JM  // PLB 19/07/06 - Saldo Principal de Juros em Reais de acordo com a Taxa do Evento 100
                           (cAliasEF1)->EF1_LIQJRM += (cAliasEF3)->EF3_VL_MOE - (cAliasEF1)->EF1_LIQJRM
                           (cAliasEF1)->EF1_LIQJRR += (cAliasEF3)->EF3_VL_REA - (cAliasEF1)->EF1_LIQJRR
                        EndIf
                     Else
                        (cAliasEF1)->EF1_SLD_PM -= (cAliasEF3)->EF3_VL_MOE
                        (cAliasEF1)->EF1_SLD_PR -= (cAliasEF3)->EF3_VL_REA
                        (cAliasEF1)->EF1_LIQPRM += (cAliasEF3)->EF3_VL_MOE
                        (cAliasEF1)->EF1_LIQPRR += (cAliasEF3)->EF3_VL_REA
                     EndIf

                     // ** GFC - 08/08/05 - Caso o saldo restante do contrato esteja menor que o valor informado no MV_EFF0002 deve preencher a data de encerramento automaticamente.
                     If (cAliasEF1)->EF1_SLD_PM < nEFF0002 .and. IIF(lEFFTpMod .And. (cAliasEF1)->EF1_CAMTRA=="1",(cAliasEF1)->EF1_SLD_JM == 0,!EX401JrOpen(cAliasEF1,cAliasEF3)) .and.;
                     lTemPgJuros .and. EF1->EF1_PGJURO $ cSim
                        If cChamada <> "FFC"
                           EX401Encerra(cContrato,cBanco,cPraca,(cAliasEF1)->EF1_SLD_PM,cAliasEF1,dDtRealLiq,IIF((cAliasEF1)->EF1_CAMTRA=="1",.T.,NIL),NIL,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,),IIF((cAliasEF1)->EF1_CAMTRA=="1",(cAliasEF1)->EF1_SLD_JM,))  // PLB 08/06/06 - Inclusao dos Parametros de Juros
                        ElseIf cBaixaCont == "2"
                           If MsgYesNo(EX401STR(69)) //"Confirma o encerramente automatico dos processos?"
                              (cAliasEF1)->EF1_DT_ENC := dDtRealLiq
                              cBaixaCont := "1"
                           Else
                              cBaixaCont := "3"
                           EndIf
                        ElseIf cBaixaCont == "1"
                           (cAliasEF1)->EF1_DT_ENC := dDtRealLiq
                        EndIf
                     EndIf
                     (cAliasEF1)->(msUnlock())
                     // **
                  EndIf
               ElseIf Left(cEvVin,2) == Left(EV_JUROS_PREPAG,2)
                  If cAliasEF1 == "M"
                     M->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
                     //M->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
                     M->EF1_SLD_JR := ( M->EF1_SLD_JR / (M->EF1_SLD_JM + (cAliasEF3)->EF3_VL_MOE) ) * M->EF1_SLD_JM  // PLB 19/07/06 - Saldo Principal de Juros em Reais de acordo com a Taxa do Evento 100
                     M->EF1_LIQJRM += (cAliasEF3)->EF3_VL_MOE
                     M->EF1_LIQJRR += (cAliasEF3)->EF3_VL_REA
                  Else
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( "EF1" , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                     (cAliasEF1)->(RecLock(cAliasEF1,.F.))
                     (cAliasEF1)->EF1_SLD_JM -= (cAliasEF3)->EF3_VL_MOE
                     //(cAliasEF1)->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
                     (cAliasEF1)->EF1_SLD_JR := ( (cAliasEF1)->EF1_SLD_JR / ((cAliasEF1)->EF1_SLD_JM + (cAliasEF3)->EF3_VL_MOE) ) * (cAliasEF1)->EF1_SLD_JM  // PLB 19/07/06 - Saldo Principal de Juros em Reais de acordo com a Taxa do Evento 100
                     (cAliasEF1)->EF1_LIQJRM += (cAliasEF3)->EF3_VL_MOE
                     (cAliasEF1)->EF1_LIQJRR += (cAliasEF3)->EF3_VL_REA
                     (cAliasEF1)->(msUnlock())
                  EndIf
               Endif

               lBaixouParc := .T.
            EndIf
         EndIf
         (cAliasEF3)->(msUnlock())

         If lLogix .And. ChekAltEF3("M",aDadosEF3)
            EX400EF3Alt(3, If( lExecLiq .And. lBaixouParc , "LIQUIDACAO",  "ALTERACAO") )
         EndIf

         If cChamada == "CAMB" .or. If( lLogix, cChamada $ "CAMB/FFC", .F. ) //NCF - 16/10/2014
            oEFFContrato:EventoEF3( If( lExecLiq .And. lBaixouParc , "LIQUIDACAO",  "ALTERACAO") )
         EndIf

         If lBaixouParc
            nOldRec := (cAliasEF3)->(RecNo())

            //Atualiza o numero da parcela nos eventos ligados a ela
            //ExAtuDtVin(cAliasEF3,cEvVin,cParcVin,dDtRealLiq,cContrato,cBanco,cPraca)

            (cAliasEF3)->(dbGoTo(nOldRec))
            //dDtVin     := dDtRealLiq
         EndIf

      EndIf
   EndIf
   // **
Else
   MsgStop(STR0108+cInvoice+"/"+If(cParcAux<>NIL,cParcAux,cParc)+STR0109) //"Evento de vinculação da invoice " # " não encontrado"
   nTx600 := 0
   dDtEve600 := avCtoD("  /  /  ")
EndIf

//NCF - 06/06/2014 - Para tratar a variação cambial quando a cambial principal
//                   vinculada antes da data de inicio de juros é liquidada
//                   em contrato ACC. Evento 650 grava com data real da vinculação.
nRecAnt := (cAliasEF3)->(Recno()) 
If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")+EV_TJ+If(cAliasEF3=="WorkEF3",If(!lEFFTpMod .OR. cTpModu=="E",cInvoice,cForn+cLojaFo+cInvoice),"")+If(cAliasEF3 == "EF3" .AND. (cOrigem == "SWB" .OR. cOrigem == "EF3"),Space(AvSx3("EF3_PARC",3))+If(cAliasEF3=="EF3",Space(AvSx3("EF3_INVOIC",3)),""),"")+IIF((cOrigem == "SWB" .OR. cOrigem == "EF3"),If(cAliasEF3=="EF3",cInvoice,"")+If(cParcAux<>NIL,cParcAux,cParc),If(cParcAux<>NIL,cParcAux,cParc)+If(cAliasEF3=="EF3",cInvoice,""))))
   dDtEve650 := (cAliasEF3)->EF3_DT_EVE
EndIf

(cAliasEF3)->(dbSetOrder(nOrdEF3))
(cAliasEF3)->(dbGoTo(nRecAnt))    //HVR 27/04/06

If If(lEF3_EV_FO,(cAliasEF3)->EF3_EV_FO <> "1" .or. lBxForc,.T.)

   If cAliasEF1=="M"
      /*nTxCtb := IF(Empty(M->EF1_TX_CTB), BuscaTaxa(M->EF1_MOEDA,M->EF1_DT_JUR,,.F.,.T.,,cTX_100), M->EF1_TX_CTB)*/                        //NCF - 02/04/2014
      nRecnoEF3 := EF3->(Recno())
      EF3->(DbSeek(xFilial("EF3")+ M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+M->EF1_SEQCNT +AvKey("100","EF3_CODEVE")))
      nTxCtb := IF(Empty(M->EF1_TX_CTB), EF3->EF3_TX_MOE, M->EF1_TX_CTB)
      dDtEve100 := EF3->EF3_DT_EVE
      EF3->(DbGoTo(nRecnoEF3))
   Else
      /*nTxCtb := IF(Empty((cAliasEF1)->EF1_TX_CTB), BuscaTaxa((cAliasEF1)->EF1_MOEDA,(cAliasEF1)->EF1_DT_JUR,,.F.,.T.,,cTX_100), (cAliasEF1)->EF1_TX_CTB)*/ //NCF - 02/02/2014 - Nopado
      nRecnoEF3 := EF3->(Recno())                                                                                                           //NCF - 02/04/2014
      EF3->(DbSeek(xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)+AvKey("100","EF3_CODEVE")))
      nTxCtb := IF(Empty(EF1->EF1_TX_CTB), EF3->EF3_TX_MOE, EF1->EF1_TX_CTB)
      dDtEve100 := EF3->EF3_DT_EVE
      EF3->(DbGoTo(nRecnoEF3))
   Endif

   //If cMod == EXP .and. !Empty(dDtEve600) .and. ((Month(dDtEve600) = Month(dDtRealLiq) .and.;
   //year(dDtEve600) = year(dDtRealLiq)) .or. &(cAliasEF1+"->EF1_DT_JUR") == &(cAliasEF1+"->EF1_DT_CTB")); // .and. Month(dDtEve600) = Month(dDtEve100) .and. year(dDtEve600) = year(dDtEve100)
   //.And. !(lPrePag .AND. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1")
   // PLB 13/06/07
   If cMod == EXP  .And.  !Empty(dDtEve600)  ;
      .And.  ( (Month(dDtEve600) == Month(dDtRealLiq)  .And. Year(dDtEve600) == Year(dDtRealLiq) )  ;
               .Or.   Empty(&(cAliasEF1+"->EF1_DT_CTB"))  .Or.  !lIsContab )  ;
      .And. !(lPrePag .AND. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1")  ;
      .And. ( !(IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACE)  .Or.  dDtEve600 >= dDtEve100 )

      nTxCtb := nTx600
   EndIf

   nTxJuros1 := Round(BuscaTaxa(cMoeCont, dDtRealLiq,,.F.,,,cTX_520),nDecTaxa) //BuscaTaxa(cMoeCont, dData, .T.,.T.) //	GCC - 17/09/2013
   //nTxJuros2 := Round(BuscaTaxa(cMoeCont, If(cAliasEF1 == "M", M->EF1_DT_CTB, (cAliasEF1)->EF1_DT_CTB),,.T.,,,cTX_520),nDecTaxa)
   // PLB 13/06/07
   nTxJuros2 := Round(BuscaTaxa(cMoeCont, IIF(cAliasEF1=="M", IIF(Empty(M->EF1_DT_CTB) .Or. !lIsContab,M->EF1_DT_JUR,M->EF1_DT_CTB), IIF(Empty((cAliasEF1)->EF1_DT_CTB) .Or. !lIsContab,(cAliasEF1)->EF1_DT_JUR,(cAliasEF1)->EF1_DT_CTB)),,.F.,,,cTX_520),nDecTaxa)

   /* wfs set-2016
      Criará o evento na liquidação da invoice. Na liquidação do evento principal, o evento 630 existirá. */
   If !lLiqAuto .And. cChamada <> "MANUT2" .and. If(lPrePag .and. cTpModu == EXP .AND. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1", cEvVin == EV_PRINC_PREPAG, .T.)
      cSeq  := BuscaEF3Seq(cAliasEF3,cContrato,cBanco,cPraca,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))
      //Grava Evento 630 - Liquidação do Principal
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
      If ValType(cFilOri) == "C"
         (cAliasEF3)->EF3_FILORI := cFilOri
      EndIf

      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := If(cAliasEF1 == "M", M->EF1_TPMODU, (cAliasEF1)->EF1_TPMODU)
         // ** GFC - 19/04/06
         (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
         // **
      EndIf
      (cAliasEF3)->EF3_CONTRA := cContrato

      // ACSJ - 06/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BANC   := cBanco
         (cAliasEF3)->EF3_AGEN   := cAgencia
         (cAliasEF3)->EF3_NCON   := cConta
         (cAliasEF3)->EF3_PRACA  := cPraca
         (cAliasEF3)->EF3_BAN_FI := If(cAliasEF1 == "M", M->EF1_BAN_FI, (cAliasEF1)->EF1_BAN_FI)
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1 == "M", M->EF1_AGENFI, (cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1 == "M", M->EF1_NCONFI, (cAliasEF1)->EF1_NCONFI)

         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := If(cAliasEF1 == "M",M->EF1_SEQCNT,(cAliasEF1)->EF1_SEQCNT)
         EndIf
      Endif

      If cOrigem == "EEQ"
         (cAliasEF3)->EF3_INVOIC := cInvoice
         (cAliasEF3)->EF3_PREEMB := cPreemb
         (cAliasEF3)->EF3_PARC   := cParc
      Else
         (cAliasEF3)->EF3_INVIMP := cInvoice
         (cAliasEF3)->EF3_HAWB   := cPreemb
         (cAliasEF3)->EF3_LINHA  := cParc
         (cAliasEF3)->EF3_FORN   := cForn
         (cAliasEF3)->EF3_LOJAFO := cLojaFo
         (cAliasEF3)->EF3_PO_DI  := cPo_Di
      EndIf

      If lEFFTpMod
         (cAliasEF3)->EF3_ORIGEM := cOrigem
      EndIf

      (cAliasEF3)->EF3_VL_INV := nValor
      (cAliasEF3)->EF3_MOE_IN := cMoeInv
      (cAliasEF3)->EF3_CODEVE := If(cChamada<>"BXFORC",EV_LIQ_PRC,EV_LIQ_PRC_FC)
      (cAliasEF3)->EF3_VL_MOE := nVal1
      (cAliasEF3)->EF3_VL_REA := If(nValorRea<>NIL, nValorRea, nVal1 * nTaxa1) //GFC em 19/04/05 p/ considerar valor em reais digitado.
      If cMoeInv <> cMoeCont .and. nValorRea<>NIL
         nTaxa1 := Round((cAliasEF3)->EF3_VL_REA / (cAliasEF3)->EF3_VL_MOE,nDecTaxa)
      EndIf
      (cAliasEF3)->EF3_TX_MOE := nTaxa1
      (cAliasEF3)->EF3_TX_CON := (cAliasEF3)->EF3_VL_REA / (cAliasEF3)->EF3_VL_INV
      (cAliasEF3)->EF3_DT_EVE := dDtRealLiq
      //NCF - 27/03/2014 - Gravação da data de liquidação
      If (cAliasEF3)->(FieldPos("EF3_DTOREV")) > 0
         (cAliasEF3)->EF3_DTOREV := (cAliasEF3)->EF3_DT_EVE
      EndIf
      //NCF - 02/06/2014 - Gravação da data de emissão do título relativo ao evento
      If (cAliasEF3)->(FieldPos("EF3_DTEMTT")) > 0
         (cAliasEF3)->EF3_DTEMTT := dDtRealLiq
      EndIf
      (cAliasEF3)->EF3_DT_CIN := dDataBase
      // ** GFC - Pré-Pagamento/Securitização
      If lPrePag .and. cTpModu == EXP .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
         (cAliasEF3)->EF3_PARVIN := cParcVin
         (cAliasEF3)->EF3_EV_VIN := cEvVin
      EndIf
      // **
      (cAliasEF3)->EF3_NROP   := cNrOp
      (cAliasEF3)->EF3_SEQ    := cSeq
      If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
         (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
      Else
         (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
      EndIf

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf

      If lEvRefi .AND. Len(aCpsRefin) # 0  // GFP - 09/10/2015
         (cAliasEF3)->EF3_TPMOOR := aCpsRefin[1]
         (cAliasEF3)->EF3_CONTOR := aCpsRefin[2]
         (cAliasEF3)->EF3_BAN_OR := aCpsRefin[3]
         (cAliasEF3)->EF3_PRACOR := aCpsRefin[4]
         (cAliasEF3)->EF3_SQCNOR := aCpsRefin[5]
         (cAliasEF3)->EF3_PARCOR := aCpsRefin[6]
         (cAliasEF3)->EF3_IVIMOR := aCpsRefin[7]
         (cAliasEF3)->EF3_LINOR  := aCpsRefin[8]
         (cAliasEF3)->EF3_CDEVOR := aCpsRefin[9]
      EndIf

      (cAliasEF3)->(msUnlock())

      //NCF - 29/08/2014
      If cChamada $ ("CAMB/FFC") .and. lLogix
         AF200BkPInt( cAliasEF3 , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
      EndIf

      nRec630 := (cAliasEF3)->(RecNo())

      If EasyEntryPoint("EFFEX400") //Alcir Alves - 19-09-05
         ExecBlock("EFFEX400",.F.,.F.,"APOS_GRV_630")
      EndIf

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf

   ElseIf cMod == IMP  .Or.  ( (cSeq == NIL  .Or.  Empty(cSeq))  .And.  cSeqLiq != NIL  .And.  !Empty(cSeqLiq) )  // PLB 23/10/06
      cSeq  := cSeqLiq
   EndIf

   // ** GFC - Pré-Pagamento/Securitização
   If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04"))
      If cAliasEF1 == "M"
         M->EF1_SL2_PM -= (cAliasEF3)->EF3_VL_MOE //nVal1
         M->EF1_SL2_PR -= (cAliasEF3)->EF3_VL_REA //nVal1 * nTaxa1
         M->EF1_LIQPRM += (cAliasEF3)->EF3_VL_MOE
         M->EF1_LIQPRR += (cAliasEF3)->EF3_VL_REA
         // ** GFC - 08/08/05 - Caso o saldo restante do contrato esteja menor que o valor informado no MV_EFF0002 deve preencher a data de encerramento automaticamente.
         If M->EF1_SLD_PM < nEFF0002 .and. M->EF1_SL2_PM < nEFF0002  .And.  !EX401JrOpen(cAliasEF1,cAliasEF3) .and.;
         lTemPgJuros .and. M->EF1_PGJURO $ cSim
            If cChamada <> "FFC"
               EX401Encerra(cContrato,cBanco,cPraca,M->EF1_SL2_PM,cAliasEF1,dDtRealLiq,NIL,NIL,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))
            ElseIf cBaixaCont == "2"
               If MsgYesNo(EX401STR(69)) //"Confirma o encerramente automatico dos processos?"
                  M->EF1_DT_ENC := dDtRealLiq
                  cBaixaCont := "1"
               Else
                  cBaixaCont := "3"
               EndIf
            ElseIf cBaixaCont == "1"
               M->EF1_DT_ENC := dDtRealLiq
            EndIf
         EndIf
         // **
      Else
         //NCF - 29/08/2014
         If cChamada $ ("CAMB/FFC") .and. lLogix
            AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
         EndIf
         (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         (cAliasEF1)->EF1_SL2_PM -= (cAliasEF3)->EF3_VL_MOE //nVal1
         (cAliasEF1)->EF1_SL2_PR -= (cAliasEF3)->EF3_VL_REA //nVal1 * nTaxa1
         (cAliasEF1)->EF1_LIQPRM += (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_LIQPRR += (cAliasEF3)->EF3_VL_REA
         // ** GFC - 08/08/05 - Caso o saldo restante do contrato esteja menor que o valor informado no MV_EFF0002 deve preencher a data de encerramento automaticamente.
         If (cAliasEF1)->EF1_SLD_PM < nEFF0002 .and. (cAliasEF1)->EF1_SL2_PM < nEFF0002  .And.  !EX401JrOpen(cAliasEF1,cAliasEF3) .and.;
         lTemPgJuros .and. EF1->EF1_PGJURO $ cSim
            If cChamada <> "FFC"
               EX401Encerra(cContrato,cBanco,cPraca,(cAliasEF1)->EF1_SL2_PM,cAliasEF1,dDtRealLiq,NIL,NIL,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))
            ElseIf cBaixaCont == "2"
               If MsgYesNo(EX401STR(69)) //"Confirma o encerramente automatico dos processos?"
                  (cAliasEF1)->EF1_DT_ENC := dDtRealLiq
                  cBaixaCont := "1"
               Else
                  cBaixaCont := "3"
               EndIf
            ElseIf cBaixaCont == "1"
               (cAliasEF1)->EF1_DT_ENC := dDtRealLiq
            EndIf
         EndIf
         // **
         (cAliasEF1)->(msUnlock())
      EndIf
   EndIf

   If cChamada == "CAMB" .or. If( lLogix, cChamada $ "CAMB/FFC" , .F. ) //NCF - 16/10/2014
      oEFFContrato:EventoEF3("INCLUSAO")
   EndIf

   If lACCACE
      nOldRec := (cAliasEF3)->(RecNo())
      If cAliasEF3 == "EF3"
         If (cOrigem == "SWB" .OR. cOrigem == "EF3")
            (cAliasEF3)->(dbSetOrder(7))
         Else
            (cAliasEF3)->(dbSetOrder(2))
         EndIf
      Else
         If (cOrigem <> "SWB" .OR. cOrigem <> "EF3")
            (cAliasEF3)->(dbSetOrder(2))
         Else
            (cAliasEF3)->(dbSetOrder(9))
         EndIf
      EndIf
      If (cAliasEF3<>"EF3" .and. If((cOrigem <> "SWB" .OR. cOrigem <> "EF3"), (cAliasEF3)->(dbSeek(EV_EMBARQUE+cInvoice+If(cParcAux<>NIL,cParcAux,cParc))), (cAliasEF3)->(dbSeek(EV_EMBARQUE+cForn+cLojaFo+cInvoice+If(cParcAux<>NIL,cParcAux,cParc))))) .or.;
      (cAliasEF3=="EF3" .and. cOrigem=="EEQ" .and. (cAliasEF3)->(dbSeek(xFilial("EF3")+IIF(lEFFTpMod,cTpModu,"")+EV_EMBARQUE+cInvoice+If(cParcAux<>NIL,cParcAux,cParc)))) .or.;
      (cAliasEF3=="EF3" .and. (cOrigem == "SWB" .OR. cOrigem == "EF3") .and. (cAliasEF3)->(dbSeek(xFilial("EF3")+cTpModu+cPreemb+cForn+cLojaFo+cInvoice+If(cParcAux<>NIL,cParcAux,cParc)+EV_EMBARQUE)))
         If cAliasEF3 == "EF3" .and. (cAliasEF3)->EF3_CONTRA <> cContrato
            Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL+If(lEFFTpMod,EF3->EF3_TPMODU,"")==xFilial("EF3")+If(lEFFTpMod,cTpModu,"") .and. EF3->EF3_CODEVE==EV_EMBARQUE .and.;
            If(cOrigem=="EEQ", EF3->EF3_INVOIC == cInvoice .and. EF3->EF3_PARC == If(cParcAux<>NIL,cParcAux,cParc), .T.) .and.;
            If((cOrigem == "SWB" .OR. cOrigem == "EF3"), EF3->EF3_HAWB==cPreemb .and. EF3->EF3_FORN==cForn .and. EF3->EF3_LOJAFO==cLojaFo .and.;
            EF3->EF3_INVIMP==cInvoice .and. EF3->EF3_LINHA==If(cParcAux<>NIL,cParcAux,cParc), .T.) .and.;
            (cAliasEF3)->EF3_CONTRA <> cContrato
               EF3->(dbSkip())
            EndDo
         EndIf
         If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
            dDtVinc := If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)
         ElseIf If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACE  //Vinculação é a data de inicio de juros (incluindo a data) no caso ACE.
            dDtVinc := If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)-1
         Else
            dDtVinc := (cAliasEF3)->EF3_DT_EVE
         EndIf
         lMesmoMes := .F.
         //If dDtVinc > dData  .Or.  ( Month(dDtVinc) = Month(dData) .AND. Year(dDtVinc) = Year(dData) ) // VI 26/09/03

         // PLB 03/06/07 - Mesmo que a Data de Liquidacao seja no mesmo mês da Vinculação, este mês pode já ter sido Contabilizado.
         If dDtVinc > dData  .Or.  ( Month(dDtVinc) == Month(dData) .AND. Year(dDtVinc) == Year(dData)  .And.  IIF(!Empty(IIF(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB)) .And. lIsContab,dData > IIF(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB),.T.))
            dDtProvJur := dDtVinc
         Else
            If cMod == IMP//lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
               dDtProvJur := dDtVinc
            //ElseIf ! If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04") .And. If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB) = If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)
            //ElseIf ! If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1" .And. If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB) = If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)

            // PLB 03/06/07 - Mesmo que a Liquidacao seja em mes diferente da Vinculação, a Vinculação pode ter sido feita em data posterior a última Contabilização
            //ElseIf ! If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1" .And. ;
            //       ( If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB) = If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR) ;
            //         .Or.  dData > If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB) )

            // PLB 13/06/07 - Verifica se não foi contabilizado ou se a Vinculação foi feita depois da última Contabilização
            ElseIf ( Empty(IIF(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB)) .Or. !lIsContab ; //! IIF(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1" .And. ;
                   .Or.  dDtVinc > If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB) )
               dDtProvJur := dDtVinc //- nMV_EFF0003
            Else
               //dDtProvJur := dData  VI 27/07/05
               //dDtProvJur := If(If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB)=If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)-nMV_EFF0003,If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB))
               // ** PLB 13/06/07
               If cAliasEF1=="M"
                  If Empty(M->EF1_DT_CTB)  .Or.  !lIsContab
                     dDtProvJur := M->EF1_DT_JUR - nMV_EFF0003
                  Else
                     dDtProvJur := M->EF1_DT_CTB
                  EndIf
               Else
                  If Empty((cAliasEF1)->EF1_DT_CTB)  .Or.  !lIsContab
                     dDtProvJur := (cAliasEF1)->EF1_DT_JUR - nMV_EFF0003
                  Else
                     dDtProvJur := (cAliasEF1)->EF1_DT_CTB
                  EndIf
               EndIf
               // **
            EndIf
/*            If Month(dDtVinc) <> Month(dData) .AND. ;
               Val(Strzero(Year(dDtProvJur),4,0)+Strzero(Month(dDtProvJur),2,0)) = Val(Right(dDtCont,4)+Left(dDtCont,2)) .AND. ! lMesmoMes .And.;
               If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB) # If(cAliasEF1=="M", M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)
               dDtProvJur := CTOD('01/'+Str(Month(dData))+'/'+Str(Year(dData))) - 1
               lMesmoMes  := .T.
            Endif*/
         EndIf

   /*    If Month(dDtVinc) <> Month(dData)
            dDtVinc := CTOD('01/'+Str(Month(dData))+'/'+Str(Year(dData))) - 1
         Endif*/
      ElseIf lPrePag  .And.  IIF(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"
         dDtProvJur :=If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)
      EndIf

      If lEF2_TIPJUR
         aJuros := EX400BusJur(If(cChamada $ ("CAMB/FFC"),"EF2","WorkEF2"),cAliasEF1)
      Else
         aJuros := {"0"}
      EndIf

      (cAliasEF3)->(dbSetOrder(nEF3Ord))
      (cAliasEF3)->(dbGoTo(nOldRec))
      dDt         := If(!Empty(dData),dData,If(!Empty((cAliasEF3)->EF3_DT_EVE),(cAliasEF3)->EF3_DT_EVE,dDataBase))
   // aTx_Dia     := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),dDt,dDtVinc,If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"))
   // nTxVinc     := BuscaTaxa(cMoeInv,dDtVinc,,.F.,.T.)
      nTxVinc     := BuscaTaxa(cMoeInv,dDtProvJur,,.F.,.T.,,cTX_100)

      For ni:=1 to len(aJuros)

         If ni > 1
            lPVez := .F.
         EndIf

         nPJAnt  := 0
         nPJAntR := 0

         IF cAliasEF1 =="M" //LRS - 16/04/2015 - Validação que corrige o erro log de Index errado.
	         If !Empty(M->EF1_DT_CTB)
	            dDtProvJur := Max(Max(GetTxCtb(cAliasEF3, "52"+aJuros[ni],cTpModu,cInvoice,cParc)[2],GetTxCtb(cAliasEF3, "51"+aJuros[ni],cTpModu,cInvoice,cParc)[2]),If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR) - nMV_EFF0003)
	         EndIf
	     ElseIf cAliasEF1 =="EF1"
	      	  If !Empty(EF1->EF1_DT_CTB)
	            dDtProvJur := Max(Max(GetTxCtb(cAliasEF3, "52"+aJuros[ni],cTpModu,cInvoice,cParc)[2],GetTxCtb(cAliasEF3, "51"+aJuros[ni],cTpModu,cInvoice,cParc)[2]),If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR) - nMV_EFF0003)
	         EndIf
         EndIF

         If cAliasEF3=="EF3"
            EF3->(dbSetOrder(6))
         Else
            If (cOrigem <> "SWB" .OR. cOrigem <> "EF3")
               (cAliasEF3)->(dbSetOrder(2))
            Else
               (cAliasEF3)->(dbSetOrder(9))
            EndIf
         EndIf
         If (cAliasEF3<>"EF3" .and. If((cOrigem <> "SWB" .OR. cOrigem <> "EF3"), (cAliasEF3)->(dbSeek(Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))+cInvoice+If(cParcAux<>NIL,cParcAux,cParc))), (cAliasEF3)->(dbSeek(Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))+cForn+cLojaFo+cInvoice+If(cParcAux<>NIL,cParcAux,cParc))))) .or.;
         (cAliasEF3=="EF3" .and. (cAliasEF3)->(dbSeek(xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,"")+If(cOrigem=="EEQ", cInvoice+If(cParcAux<>NIL,cParcAux,cParc), Space(Len(EF3->EF3_INVOIC+EF3->EF3_PARC))+cInvoice+If(cParcAux<>NIL,cParcAux,cParc)))))

//          Do While (cAliasEF3)->(!Eof()) .And. If(cAliasEF3=="EF3",(cAliasEF3)->EF3_FILIAL = xFilial("EF3") .and.;
//          EF3->EF3_CONTRA==cContrato .and. EF3->EF3_BAN_FI==cBanco .and. EF3->EF3_PRACA==cPraca,.T.) .And. ;
//          If(cAliasEF3<>"EF3",(cAliasEF3)->EF3_CODEVE = Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni]))),.T.) .And.;
//          (cAliasEF3)->EF3_INVOIC = cInvoice .and. (cAliasEF3)->EF3_PARC = If(cParcAux<>NIL,cParcAux,cParc)
//             If (cAliasEF3=="EF3" .and. (cAliasEF3)->EF3_CODEVE = Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))) .or.;
//             cAliasEF3<>"EF3"
//                nPJAnt += (cAliasEF3)->EF3_VL_MOE
//                nPJAntR+= (cAliasEF3)->EF3_VL_REA
//             EndIf
//             (cAliasEF3)->(DbSkip())
//          Enddo
            /*For i:=1 to Len(aTx_Ctb)//FSY - 19/06/2013 Dopado chamado THAXDV
                //nPJAnt += aTx_Ctb[i,2] * (aTx_Ctb[i,1] / 100) * If(lPrePag.and.If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04"),nValMoeEF3,nVal1)
               If IIF(lEF2_TIPJUR,aTx_Ctb[i][3] == aJuros[ni],.T.)  // PLB 24/08/06 - Verifica Provisão de Juros Anterior de cada tipo de Juros
                  nPJAnt += Round(aTx_Ctb[i,2] * (aTx_Ctb[i,1] / 100) * If(lPrePag.and.cMod=EXP.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nValMoeEF3,nVal1),nDecValor)
               EndIf
            Next i
            nPJAntR += Round(nPJAnt * nTxJuros2,nDecValor)*/
         EndIf
         (cAliasEF3)->(dbSetOrder(nEF3Ord))
         (cAliasEF3)->(dbGoTo(nOldRec))


            // PLB 09/08/06 - Verifica periodo de Transferencias de Juros de ACC para ACE
            If cMod == EXP  .And.  IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACC
               If dDtProvJur < dDtEve600
                  aTx_Dia := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),dDtEve600,dDtProvJur,If(cChamada $ ("CAMB/FFC"),"EF1","M"),If(cChamada $ ("CAMB/FFC"),"EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc,,,dDtEve600)
                  aTxAux  := EX400BusTx(IIF(EX401ExACE(cChamada,aJuros[ni],cFilOri,cInvoice,cParc) .OR. EX401ExACE(cChamada,aJuros[ni],Space(Len(EF2->EF2_FILIAL)),Space(Len(EF2->EF2_INVOIC)),Space(Len(EF2->EF2_PARC))),ACE,ACC),dDt,dDtEve600,If(cChamada $ ("CAMB/FFC"),"EF1","M"),If(cChamada $ ("CAMB/FFC"),"EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc,,,dDtEve600)
                  For nj := 1  to  Len(aTxAux)
                     AAdd(aTx_Dia,aTxAux[nj])
                  Next nj
               Else
                  aTx_Dia := EX400BusTx(IIF(EX401ExACE(cChamada,aJuros[ni],cFilOri,cInvoice,cParc) .OR. EX401ExACE(cChamada,aJuros[ni],Space(Len(EF2->EF2_FILIAL)),Space(Len(EF2->EF2_INVOIC)),Space(Len(EF2->EF2_PARC))),ACE,ACC),dDt,dDtProvJur,If(cChamada $ ("CAMB/FFC"),"EF1","M"),If(cChamada $ ("CAMB/FFC"),"EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc,,,dDtEve600)
               EndIf
            Else
               aTx_Dia := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),dDt,dDtProvJur,If(cChamada $ ("CAMB/FFC"),"EF1","M"),If(cChamada $ ("CAMB/FFC"),"EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc,,,dDtEve600)
            EndIf

            // PLB 13/06/07 - dDtProvJur já está com a data corretamente verificada (se é a data da Contabilização ou da Vinculação)
            If dDtProvJur == If(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB) //FSM -22/08/2012
               If Empty(nTaxaVCJuros := GetTxCtb(cAliasEF3, "52"+aJuros[ni],cTpModu,cInvoice,cParc)[1]) // AAF 19/09/2012
                  nTaxaVCJuros := IIF(cAliasEF1=="M",M->EF1_TX_CTB,(cAliasEF1)->EF1_TX_CTB)
               EndIf
            Else
               //nTaxaVCJuros := BuscaTaxa(cMoeCont, dDtProvJur,,.F.,,,cTX_520)
               nTaxaVCJuros := If( (ValType(dDtEve600) == 'D' .And. !Empty(dDtEve600)) .And. (ValType(dDtEve650) == 'D' .And. !Empty(dDtEve650)) , ;       //NCF - 06/06/2014 - Para tratar a variação cambial quando a cambial principal
                               If(dDtEve600 > dDtEve650 ,  BuscaTaxa(cMoeCont, dDtEve650,,.F.,,,cTX_520) , BuscaTaxa(cMoeCont, dDtProvJur,,.F.,,,cTX_520)) , ; //                   vinculada antes da data de inicio de juros é liquidada
                               BuscaTaxa(cMoeCont, dDtProvJur,,.F.,,,cTX_520)    )                                                                             //                   em contrato ACC. Neste caso, a taxa deve ser a taxa da data real de vinculação.
            EndIf

         // ** AAF 02/04/08 - Busca ultima provisão de juros gerada para o pré-pagamento
         If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1" .AND. cMod <> IMP

            nRecAntEF3:=(cAliasEF3)->(RecNo())
            nOrdAntEF3:=(cAliasEF3)->(IndexOrd())

            If cAliasEF3 == "EF3"
               (cAliasEF3)->(dbSetOrder(1))
               (cAliasEF3)->(dbSeek(xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,"")))
               cAliasEF1 := "EF1"
               cAliasEF2 := "EF2"
            Else
               (cAliasEF3)->(dbGoTop())
               cAliasEF1 := "M"
               cAliasEF2 := "WorkEF2"
            EndIf

            dDtUltPr := CToD("  /  /  ")
            nUltTxPr := 0

            Do While !(cAliasEF3)->(EOF()) .and.;
            If(cAliasEF3=="EF3",(cAliasEF3)->(EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,""))==xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),.T.)
               If (cAliasEF3)->EF3_DT_EVE <= dDtRealLiq .AND. (cAliasEF3)->EF3_CODEVE == Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni]))) .AND.;
               (cAliasEF3)->EF3_DT_EVE > dDtUltPr
                  dDtUltPr := (cAliasEF3)->EF3_DT_EVE
                  nUltTxPr := (cAliasEF3)->EF3_TX_MOE
               EndIf
               (cAliasEF3)->(dbSkip())
            EndDo

            (cAliasEF3)->(dbGoTo(nRecAntEF3))
            (cAliasEF3)->(dbSetOrder(nOrdAntEF3))

            If dDtUltPr >= dDtProvJur
               nTaxaVCJuros := nUltTxPr
               dDtProvJur   := dDtUltPr
            Else
               nTaxaVCJuros := BuscaTaxa(cMoeCont, dDtProvJur,,.F.,,,cTX_520)
            EndIf
         EndIf
         // **
         // PLB 09/08/06 - Verifica periodo de Transferencias de Juros de ACC para ACE
         If cMod == EXP  .And.  IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACC
            aTx_Ctb := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),dDtEve600,If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)-nMV_EFF0003,If(cChamada $ ("CAMB/FFC"),"EF1","M"),If(cChamada $ ("CAMB/FFC"),"EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc,, lEF1_DTBONI .and. dDtEve600 <= &(cAliasEF1+"->EF1_DTBONI"), dDtEve600)
            aTxAux  := EX400BusTx(IIF(EX401ExACE(cChamada,aJuros[ni],cFilOri,cInvoice,cParc) .OR. EX401ExACE(cChamada,aJuros[ni],Space(Len(EF2->EF2_FILIAL)),Space(Len(EF2->EF2_INVOIC)),Space(Len(EF2->EF2_PARC))),ACE,ACC),dDt,dDtEve600,If(cChamada $ ("CAMB/FFC"),"EF1","M"),If(cChamada $ ("CAMB/FFC"),"EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc,, lEF1_DTBONI .and. dDtEve600 <= &(cAliasEF1+"->EF1_DTBONI"), dDtEve600 )
            For nj := 1  to  Len(aTxAux)
               AAdd(aTx_Ctb,aTxAux[nj])
            Next nj
         Else
            aTx_Ctb := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),dDt,If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)-nMV_EFF0003,If(cChamada $ ("CAMB/FFC"),"EF1","M"),If(cChamada $ ("CAMB/FFC"),"EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc,, lEF1_DTBONI .and. dDtEve600 <= &(cAliasEF1+"->EF1_DTBONI"), dDtEve600)
         EndIf

         If dDt >= If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR)

            /* comentado por wfs
            If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1") .OR.;//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) .or.; // ** GFC - Pré-Pagamento/Securitização
            (Left(cEvVin,2) == Left(EV_JUROS_PREPAG,2) .and. cChamada<>"MANUT2" .and. Alltrim(Str(Val(aJuros[ni]))) == Right(cEvVin,1))

            Quando for liquidação automática, impedir a duplicação dos eventos de juros no contrato PPE. */
            If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1") .OR.; // ** GFC - Pré-Pagamento/Securitização
            (!lLiqAuto .And. Left(cEvVin,2) == Left(EV_JUROS_PREPAG,2) .and. cChamada<>"MANUT2" .and. Alltrim(Str(Val(aJuros[ni]))) == Right(cEvVin,1))

               //If lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04") .and. Left(cEvVin,2) == Left(EV_JUROS_PREPAG,2)
               If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1" .and. Left(cEvVin,2) == Left(EV_JUROS_PREPAG,2)
                  cSeq  := BuscaEF3Seq(cAliasEF3,cContrato,cBanco,cPraca,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))
               EndIf
               //Grava Evento 640 - Liquidação de Juros
               (cAliasEF3)->(RecLock(cAliasEF3,.T.))
               (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
               If ValType(cFilOri) == "C"
                  (cAliasEF3)->EF3_FILORI := cFilOri
               EndIf
               If lEFFTpMod
                  (cAliasEF3)->EF3_TPMODU := cTpModu
                  // ** GFC - 19/04/06
                  (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
                  // **
               EndIf
               (cAliasEF3)->EF3_CODEVE := Left(If(!lBxForc,EV_LIQ_JUR,EV_LIQ_JUR_FC),2)+Alltrim(Str(Val(aJuros[ni])))
               (cAliasEF3)->EF3_CONTRA := cContrato

               // ACSJ - 06/02/2005
               If lTemChave
                  (cAliasEF3)->EF3_BANC   := cBanco
                  (cAliasEF3)->EF3_AGEN   := cAgencia
                  (cAliasEF3)->EF3_NCON   := cConta
                  (cAliasEF3)->EF3_PRACA  := cPraca
                  (cAliasEF3)->EF3_BAN_FI := If(cAliasEF1 == "M", M->EF1_BAN_FI, (cAliasEF1)->EF1_BAN_FI)
                  (cAliasEF3)->EF3_AGENFI := If(cAliasEF1 == "M", M->EF1_AGENFI, (cAliasEF1)->EF1_AGENFI)
                  (cAliasEF3)->EF3_NCONFI := If(cAliasEF1 == "M", M->EF1_NCONFI, (cAliasEF1)->EF1_NCONFI)
                  If lEFFTpMod
                     (cAliasEF3)->EF3_SEQCNT := cSeqCon
                  EndIf
               Endif

               (cAliasEF3)->EF3_PREEMB := cPreemb
               (cAliasEF3)->EF3_INVOIC := cInvoice
               (cAliasEF3)->EF3_PARC   := cParc

               nValAux1 := 0
               For i:=1 to Len(aTx_Ctb)
                  //nValAux1 += aTx_Ctb[i,2] * (aTx_Ctb[i,1] / 100) * If(lPrePag.and.If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04"),nValMoeEF3,nVal1)
                  nValAux1 += Round(aTx_Ctb[i,2] * (aTx_Ctb[i,1] / 100) * If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nValMoeEF3,nVal1),nDecValor)
               Next i
               (cAliasEF3)->EF3_MOE_IN := cMoeInv

               If (lEF1_JR_ANT .and. &(cAliasEF1+"->EF1_JR_ANT") <> "1") .or.; // ** GFC - 08/11/05 - Juros Antecipados
               !lEF1_JR_ANT
                  (cAliasEF3)->EF3_VL_MOE := If(nVlMoeAtu=NIL,If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nVal1/*nValMoeEF3*/,nValAux1),nVlMoeAtu)  // PLB 21/06/06 - nVal1
                  nValAux2 := Round((cAliasEF3)->EF3_VL_MOE * If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nTaxa1,nTxJuros1),nDecValor)//AAF 05/04/06 - FINIMP // MJA 04/01/05

                  // --- ACSJ - Caetano - 19/01/2005
                  // Se o parametro EF1_PGJURO estiver ligado ira gravar taxa de juros / valor em reais / data do evento.
                  If ( lTemPgJuros .and. ( iif(cAliasEF1 = "M", M->EF1_PGJURO, EF1->EF1_PGJURO) $ cSim ) ) .or. .not. lTemPgJuros .or.;
                  (lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1" .and.;//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
                  Left(cEvVin,2) == Left(EV_JUROS_PREPAG,2) .and. cChamada<>"MANUT2")
                     (cAliasEF3)->EF3_TX_MOE := If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nTaxa1,nTxJuros1)
                     (cAliasEF3)->EF3_VL_REA := If(nVlReaAtu=NIL,nValAux2,nVlReaAtu) // nValAux1 * nTxJuros1 //(para pegar a taxa de venda provisóriamente)
                     (cAliasEF3)->EF3_DT_EVE := dDtRealLiq //dData	// GCC - 17/09/2013
                     //NCF - 27/03/2014 - Gravação da data de liquidação
                     If (cAliasEF3)->(FieldPos("EF3_DTOREV")) > 0
                        (cAliasEF3)->EF3_DTOREV := (cAliasEF3)->EF3_DT_EVE
                     EndIf
                  ENDIF
                  // --------------------------------
               EndIf

               //NCF - 02/06/2014 - Gravação da data de emissão do título relativo ao evento
               If (cAliasEF3)->(FieldPos("EF3_DTEMTT")) > 0
                  (cAliasEF3)->EF3_DTEMTT := dDtRealLiq
               EndIf

               // ** GFC - Pré-Pagamento/Securitização
               If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
                  (cAliasEF3)->EF3_PARVIN := cParcVin
                  (cAliasEF3)->EF3_EV_VIN := cEvVin
                  (cAliasEF3)->EF3_NROP   := cNrOp
               EndIf
               // **
               (cAliasEF3)->EF3_SEQ    := cSeq
               If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                  (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
               Else
                  (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
               Endif

               If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1")//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04"))
                  If cAliasEF1 == "M"
                     M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                     M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
                     M->EF1_LIQJRM += (cAliasEF3)->EF3_VL_MOE
                     M->EF1_LIQJRR += (cAliasEF3)->EF3_VL_REA
                  Else
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                     (cAliasEF1)->(RecLock(cAliasEF1,.F.))
                     (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                     (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
                     (cAliasEF1)->EF1_LIQJRM += (cAliasEF3)->EF3_VL_MOE
                     (cAliasEF1)->EF1_LIQJRR += (cAliasEF3)->EF3_VL_REA
                  EndIf
               EndIf
               nVLMOE640  := (cAliasEF3)->EF3_VL_MOE
               nVLREAL640 := (cAliasEF3)->EF3_VL_REA
               // ** PLB 18/05/07 - Quando a Baixa de Juros não for automatica, calcula nVLREAL640 de acordo com a taxa da Provisao de Juros
               If lTemPgJuros  .And.  IIF( cAliasEF1 == "M", M->EF1_PGJURO, EF1->EF1_PGJURO ) $ cNao
                  nVLREAL640 := nVLMOE640 * nTxJuros1
               EndIf

               If nVlMoeAnt = NIL .and. cChamada $ ("CAMB/FFC") .and. cOrigem=="EEQ"   //GFC 07/01/2005
         //                          1         2     3         4                     5                       6                     7                         8       9    10     11                    12
                  aAdd(aGetProv,{cContrato,cInvoice,cParc,(cAliasEF3)->EF3_VL_MOE,(cAliasEF3)->EF3_VL_REA,(cAliasEF3)->EF3_VL_MOE,(cAliasEF3)->EF3_VL_REA,cBanco,cPraca,nRec630,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,)})
               EndIf

               //FSM - 10/04/2012
               If Upper(cAliasEF3) == "WORKEF3"
                  (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
               EndIf

               //NCF - 26/11/2014
               If lLogix
                  (cAliasEF3)->EF3_FORN   := cForn
                  (cAliasEF3)->EF3_LOJAFO := cLojaFo
               EndIf

               (cAliasEF3)->(msUnlock())

               //NCF - 29/08/2014
               If cChamada $ ("CAMB/FFC") .and. lLogix
                  AF200BkPInt( cAliasEF3 , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
               EndIf
               // ** GFC - 21/09/05
               nRec640 := (cAliasEF3)->(RecNo())
               // **

               If EasyEntryPoint("EFFEX400") //Alcir Alves - 19-09-05
                  ExecBlock("EFFEX400",.F.,.F.,"APOS_GRV_640")
               Endif

               If lCadFin
                  EX401GrEncargos(cAliasEF3)
               EndIf

               If cChamada == "CAMB" .or. If( lLogix, cChamada $ "CAMB/FFC", .F. ) //NCF - 16/10/2014
                  If lLogix .And. (cAliasEF3)->EF3_TX_MOE <> 0 .And. (cAliasEF3)->EF3_VL_REA <> 0 .And. !Empty( (cAliasEF3)->EF3_DT_EVE )  //NCF - 12/09/2014
                     oEFFContrato:EventoEF3("LIQUIDACAO")
                     lLiqJurEF3Auto := .T.
                  EndIf
                  oEFFContrato:EventoEF3("INCLUSAO")
               EndIf

               // ** GFC - 08/11/05 - Juros Antecipados
               If lEF1_JR_ANT .and. &(cAliasEF1+"->EF1_JR_ANT") == "1"
                  EX401VarJA(cAliasEF1,cAliasEF3,dDtRealLiq,cContrato,cBanco,cPraca,nTxJuros1,aJuros[ni],if(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))	// GCC - 17/09/2013
               EndIf
               // **

			   //** AAF 23/01/2015
			   If iif(cAliasEF1 = "M", M->EF1_PGJURO, EF1->EF1_PGJURO) $ cSim

			      //Variação Cambial do 620 (Juros Antecipados)
				  nVal620  := EX401EvSum("62"+Alltrim(Str(Val(aJuros[ni]))),cAliasEF3,if(cAliasEF3=="EF3",EF1->(xFilial("EF1")+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),),.T.,)
			      nVal620R := EX401EvSum("62"+Alltrim(Str(Val(aJuros[ni]))),cAliasEF3,if(cAliasEF3=="EF3",EF1->(xFilial("EF1")+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),),.F.,)

				  nVal620R += EX401EvSum(AllTrim(Str(580+Val(aJuros[ni])*2)),cAliasEF3,if(cAliasEF3=="EF3",EF1->(xFilial("EF1")+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),),.F.,)
			      nVal620R += EX401EvSum(AllTrim(Str(581+Val(aJuros[ni])*2)),cAliasEF3,if(cAliasEF3=="EF3",EF1->(xFilial("EF1")+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),),.F.,)


				  nVal620  -= EX401EvSum("64"+Alltrim(Str(Val(aJuros[ni]))),cAliasEF3,if(cAliasEF3=="EF3",EF1->(xFilial("EF1")+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),),.T.,{||(cAliasEF3)->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0) .AND. (cAliasEF3)->(RecNo()) <> nRec640})
			      nVal620R -= EX401EvSum("64"+Alltrim(Str(Val(aJuros[ni]))),cAliasEF3,if(cAliasEF3=="EF3",EF1->(xFilial("EF1")+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),),.F.,{||(cAliasEF3)->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0) .AND. (cAliasEF3)->(RecNo()) <> nRec640})

				  (cAliasEF3)->(dbGoTo(nRec640))

				  nTxVc620 := (cAliasEF3)->EF3_TX_MOE

			      //Variacao cambial de juros antecipado.
                  nVc620RS := Round(nVal620 * nTxVc620 - nVal620R,2)

				  If nVc620RS <> 0

                    (cAliasEF3)->(RecLock(cAliasEF3,.T.))
                    (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
                    If ValType(cFilOri) == "C"
                       (cAliasEF3)->EF3_FILORI := cFilOri
                    EndIf

                    If lEFFTpMod
                       (cAliasEF3)->EF3_TPMODU := cTpModu
                    EndIf
                    (cAliasEF3)->EF3_CODEVE := AllTrim(Str(580+if(nVc620RS>=0,0,1)+Val(aJuros[ni])*2))
                    If Upper(cAliasEF3) == "WORKEF3"
                        (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, "WorkEF3", (cAliasEF3)->EF3_CODEVE)
                    EndIf
                    (cAliasEF3)->EF3_CONTRA := cContrato

                    If lTemChave
                       (cAliasEF3)->EF3_BANC   := cBanco
                       (cAliasEF3)->EF3_AGEN   := cAgencia
                       (cAliasEF3)->EF3_NCON   := cConta
                       (cAliasEF3)->EF3_PRACA  := cPraca
                       (cAliasEF3)->EF3_BAN_FI := If(cAliasEF1 == "M", M->EF1_BAN_FI, (cAliasEF1)->EF1_BAN_FI)
                       (cAliasEF3)->EF3_AGENFI := If(cAliasEF1 == "M", M->EF1_AGENFI, (cAliasEF1)->EF1_AGENFI)
                       (cAliasEF3)->EF3_NCONFI := If(cAliasEF1 == "M", M->EF1_NCONFI, (cAliasEF1)->EF1_NCONFI)
                       If lEFFTpMod
                         (cAliasEF3)->EF3_SEQCNT := cSeqCon
                       EndIf
                    Endif

                    (cAliasEF3)->EF3_DT_EVE := dDtRealLiq
                    (cAliasEF3)->EF3_TX_MOE := nTxVc620
                    (cAliasEF3)->EF3_VL_REA := nVc620RS
					
					(cAliasEF3)->EF3_SEQ    := cSeq
                    (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)

   		        (cAliasEF3)->(msUnlock())
				  EndIf

			   EndIf
			   //**

************************************************************************************************* // MJA 05/01/05 & GFC 07/01/05
               If nVlMoeAnt <> NIL .and. (nVlMoeAnt # nVlMoeAtu) // verifica se houve alteracao no valor da moeda e grava no EF4
                  EF4->(RecLock("EF4",.T.))
                  EF4->EF4_FILIAL := xFilial("EF4")
                  EF4->EF4_CONTRA := cContrato

                  If lEFFTpMod
                     EF4->EF4_TPMODU := cTpModu
                  EndIf

                  // ACSJ - 06/02/2005
                  If lTemChave
                     EF4->EF4_BAN_FI := cBanco
                     EF4->EF4_PRACA  := cPraca
                     If lEFFTpMod
                        EF4->EF4_SEQCNT := cSeqCon
                     EndIf
                  Endif
                  //MFR 05/10/2021 OSSME-6276
                  //If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                  //   EF4->EF4_TP_EVE := "01"
                  //Else
                     EF4->EF4_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                  //EndIf
                  EF4->EF4_CAMPO  := AVSX3("EF3_VL_MOE",5)

                  EF4->EF4_PREEMB := cPreemb
                  EF4->EF4_INVOIC := cInvoice
                  EF4->EF4_PARC   := cParc

                  EF4->EF4_CODEVE := Left(If(lBxForc,EV_LIQ_JUR,EV_LIQ_JUR_FC),2)+Alltrim(Str(Val(aJuros[ni])))
                  EF4->EF4_SEQ    := cSeq
                  EF4->EF4_DE     := STR0180+STR0110+STR(nVlMoeAnt) // "Valor da Provisao de Juros em Reais" # " de "
                  EF4->EF4_PARA   := STR0180+STR0111+STR(nVlMoeAtu) //"Valor da Provisao de Juros em Reais" # " para "
                  EF4->EF4_USUARI := cUserName
                  EF4->EF4_DATA   := dDataBase
                  EF4->EF4_HORA   := SubStr(Time(),1,5)
                  EF4->(msUnlock())
                  //NCF - 29/08/2014
                  If cChamada $ ("CAMB/FFC") .and. lLogix
                     AF200BkPInt( "EF4" , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
                  EndIf
               EndIf

               If nVlReaAnt <> NIL .and. (nVlReaAnt # nVlReaAtu)// verifica se houve alteracao no valor em Reais e grava no EF4
                  EF4->(RecLock("EF4",.T.))
                  EF4->EF4_FILIAL := xFilial("EF4")
                  EF4->EF4_CONTRA := cContrato

                  If lEFFTpMod
                     EF4->EF4_TPMODU := cTpModu
                  EndIf

                  // ACSJ - 06/02/2005
                  If lTemChave
                     EF4->EF4_BAN_FI := cBanco
                     EF4->EF4_PRACA  := cPraca
                     If lEFFTpMod
                        EF4->EF4_SEQCNT := cSeqCon
                     EndIf
                  Endif
                  //MFR 05/10/2021 OSSME-6276
                  //If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                  //   EF4->EF4_TP_EVE := "01"
                  //Else
                     EF4->EF4_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                  //EndIf
                  EF4->EF4_CAMPO  := AVSX3("EF3_VL_REA",5)

                  EF4->EF4_PREEMB := cPreemb
                  EF4->EF4_INVOIC := cInvoice
                  EF4->EF4_PARC   := cParc

                  EF4->EF4_CODEVE := Left(If(lBxForc,EV_LIQ_JUR,EV_LIQ_JUR_FC),2)+Alltrim(Str(Val(aJuros[ni])))
                  EF4->EF4_SEQ    := cSeq
                  EF4->EF4_DE     := STR0180+STR0110+STR(nVlReaAnt) //"Valor da Provisao de Juros em Reais" # " de "
                  EF4->EF4_PARA   := STR0180+STR0111+STR(nVlReaAtu) //"Valor da Provisao de Juros em Reais" # " para "
                  EF4->EF4_USUARI := cUserName
                  EF4->EF4_DATA   := dDataBase
                  EF4->EF4_HORA   := SubStr(Time(),1,5)
                  EF4->(msUnlock())
                  //NCF - 29/08/2014
                  If cChamada $ ("CAMB/FFC") .and. lLogix
                     AF200BkPInt( "EF4" , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
                  EndIf
               endif
*************************************************************************************************
            EndIf

            nValAux1 := 0

            If nVlMoeAnt <> NIL .and. (nVlMoeAnt # nVlMoeAtu) // verifica se houve alteracao no valor da moeda e grava no EF4
               //Grava Evento 520 ou 510 - Estorno de Provisão ou Provisão de Juros (diferença)
               (cAliasEF3)->(RecLock(cAliasEF3,.T.))
               (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
               If ValType(cFilOri) == "C"
                  (cAliasEF3)->EF3_FILORI := cFilOri
               EndIf
               If lEFFTpMod
                  (cAliasEF3)->EF3_TPMODU := cTpModu
                  // ** GFC - 19/04/06
                  (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
                  // **
               EndIf
               If (nVlMoeAnt - nVlMoeAtu) < 0
                  (cAliasEF3)->EF3_CODEVE := Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
               Else
                  (cAliasEF3)->EF3_CODEVE := Left(EV_EST_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
               EndIf
               (cAliasEF3)->EF3_CONTRA := cContrato

               // ACSJ - 06/02/2005
               If lTemChave
                  (cAliasEF3)->EF3_BANC   := cBanco
                  (cAliasEF3)->EF3_AGEN   := cAgencia
                  (cAliasEF3)->EF3_NCON   := cConta
                  (cAliasEF3)->EF3_PRACA  := cPraca
                  (cAliasEF3)->EF3_BAN_FI := If(cAliasEF1 == "M", M->EF1_BAN_FI, (cAliasEF1)->EF1_BAN_FI)
                  (cAliasEF3)->EF3_AGENFI := If(cAliasEF1 == "M", M->EF1_AGENFI, (cAliasEF1)->EF1_AGENFI)
                  (cAliasEF3)->EF3_NCONFI := If(cAliasEF1 == "M", M->EF1_NCONFI, (cAliasEF1)->EF1_NCONFI)
                  If lEFFTpMod
                     (cAliasEF3)->EF3_SEQCNT := cSeqCon
                  EndIf
               Endif

               (cAliasEF3)->EF3_PREEMB := cPreemb
               (cAliasEF3)->EF3_INVOIC := cInvoice
               (cAliasEF3)->EF3_PARC   := cParc

               (cAliasEF3)->EF3_MOE_IN := cMoeInv
               (cAliasEF3)->EF3_VL_MOE := If((nVlMoeAnt - nVlMoeAtu) < 0, (nVlMoeAnt - nVlMoeAtu) * -1, (nVlMoeAnt - nVlMoeAtu))
               (cAliasEF3)->EF3_VL_REA := If((nVlMoeAnt - nVlMoeAtu) < 0, (nVlMoeAnt - nVlMoeAtu) * -1, (nVlMoeAnt - nVlMoeAtu)) * nTxJuros1
               (cAliasEF3)->EF3_TX_MOE := nTxJuros1
               (cAliasEF3)->EF3_DT_EVE := dData  //dDataLiq //dData   // PLB 18/10/06
               //NCF - 27/03/2014 - Gravação da data de liquidação
               If (cAliasEF3)->(FieldPos("EF3_DTOREV")) > 0
                  (cAliasEF3)->EF3_DTOREV := (cAliasEF3)->EF3_DT_EVE
               EndIf
               //NCF - 02/06/2014 - Gravação da data de emissão do título relativo ao evento
               If (cAliasEF3)->(FieldPos("EF3_DTEMTT")) > 0
                  (cAliasEF3)->EF3_DTEMTT := dDtRealLiq
               EndIf

               (cAliasEF3)->EF3_SEQ    := cSeq

               If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                  (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
               Else
                  (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
               EndIf

               If Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_PJ,2) //520
                  If cAliasEF1 == "M"
                     M->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
                     M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
                  Else
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                     (cAliasEF1)->(RecLock(cAliasEF1,.F.))
                     (cAliasEF1)->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
                     (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
                  EndIf
                  // ** GFC - 23/07/05
                  nMOE520Dif  := (cAliasEF3)->EF3_VL_MOE
                  nREAL520Dif := (cAliasEF3)->EF3_VL_REA
                  // **
                  nPJAnt  += (cAliasEF3)->EF3_VL_MOE
                  nPJAntR += (cAliasEF3)->EF3_VL_REA
               Else // ** GFC - 24/07/05 - Reduz os saldos no caso de estorno da provisão de juros //510
                  If cAliasEF1 == "M"
                     M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                     M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
                  Else
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                     (cAliasEF1)->(RecLock(cAliasEF1,.F.))
                     (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                     (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
                  EndIf
                  // ** GFC - 23/07/05
                  nMOE520Dif  := (cAliasEF3)->EF3_VL_MOE * -1
                  nREAL520Dif := (cAliasEF3)->EF3_VL_REA * -1
                  // **
                  nPJAnt  -= (cAliasEF3)->EF3_VL_MOE
                  nPJAntR -= (cAliasEF3)->EF3_VL_REA
               EndIf

               //FSM - 10/04/2012
               If Upper(cAliasEF3) == "WORKEF3"
                  (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
               EndIf

               (cAliasEF3)->(msUnlock())

               //NCF - 29/08/2014
               If cChamada $ ("CAMB/FFC") .and. lLogix
                  AF200BkPInt( cAliasEF3 , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
               EndIf

               If EasyEntryPoint("EFFEX400") //Alcir Alves - 19-09-05
                  ExecBlock("EFFEX400",.F.,.F.,"APOS_GRV_520")
               Endif

               If lCadFin
                  EX401GrEncargos(cAliasEF3)
               EndIf
            EndIf

            If !(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1") .OR.;//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) .or.;
            ( ( lBaixouParc .and. Left(cEvVin,2)==Left(EV_JUROS_PREPAG,2) .And. Right(cEvVin,1)==aJuros[ni] ) .OR. ( lBaixouParc .AND. /*cMod == IMP .AND.*/ Left(cEvLiq,2) == Left(EV_JUROS_PREPAG,2) .and. Right(cEvLiq,1)==aJuros[ni] ) ) // ** GFC - Pré-Pagamento/Securitização   // PLB 20/06/06 - Verifica o Tipo de Juros quando for EV_JUROS_PREPAG  //PLB 23/06/06
               //NCF - 12/11/2018 - Definir a data de cálculo da provisão de juros(520) e variaçao cambial de juros(551) para liquidação antecipada sem alteração do evento 710(juros PPE)
               If Left(cEvLiq,2) == Left(EV_JUROS_PREPAG,2) .And. !Empty( (cAliasEF3)->EF3_DTOREV ) .And. (cAliasEF3)->EF3_DTOREV < (cAliasEF3)->EF3_DT_EVE
                  dDt520Ate := (cAliasEF3)->EF3_DT_EVE
               Else
                  dDt520Ate := dDtRealLiq
               EndIf

               //Grava Evento 520 - Provisão de Juros
               (cAliasEF3)->(RecLock(cAliasEF3,.T.))
               (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
               If ValType(cFilOri) == "C"
                  (cAliasEF3)->EF3_FILORI := cFilOri
               EndIf
               If lEFFTpMod
                  (cAliasEF3)->EF3_TPMODU := cTpModu
                  // ** GFC - 19/04/06
                  (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
                  // **
               EndIf
               (cAliasEF3)->EF3_CODEVE := Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
               (cAliasEF3)->EF3_CONTRA := cContrato

               // ACSJ - 06/02/2005
               If lTemChave
                  (cAliasEF3)->EF3_BANC   := cBanco
                  (cAliasEF3)->EF3_AGEN   := cAgencia
                  (cAliasEF3)->EF3_NCON   := cConta
                  (cAliasEF3)->EF3_PRACA  := cPraca
                  (cAliasEF3)->EF3_BAN_FI := If(cAliasEF1 == "M", M->EF1_BAN_FI, (cAliasEF1)->EF1_BAN_FI)
                  (cAliasEF3)->EF3_AGENFI := If(cAliasEF1 == "M", M->EF1_AGENFI, (cAliasEF1)->EF1_AGENFI)
                  (cAliasEF3)->EF3_NCONFI := If(cAliasEF1 == "M", M->EF1_NCONFI, (cAliasEF1)->EF1_NCONFI)
                  If lEFFTpMod
                     (cAliasEF3)->EF3_SEQCNT := cSeqCon
                  EndIf
               Endif

               // ** GFC - 25/08/05 - O cálculo do valor da provisão de juros, no Pré-pagamento, é baseado no saldo.
               If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
                  //nValMoeEF3 := Round(EX401ProvJr(cContrato,cBanco,cPraca,cAliasEF3,dDataLiq,IIF(/*cMod==IMP*/Left(cEvLiq,2)==Left(EV_JUROS_PREPAG,2),cEvLiq,cEvVin),cTpModu,cSeqCon,cForn,cLojaFo),nDecValor)  // PLB 12/06/06 - IIF(cMod) Se o modulo for importacao passa o proprio evento como parametro
                  // ** AAF 01/04/08 - Adicionado parâmetro para o inicio da provisão.
                  If cMod == EXP
                     /*nValMoeEF3 := Round(;
                                          EX401ProvJr(cContrato,cBanco,cPraca,cAliasEF3,dDtRealLiq,dDtProvJur,;
                                          IIF(Left(cEvLiq,2)==Left(EV_JUROS_PREPAG,2),cEvLiq,cEvVin),cTpModu,cSeqCon);
                                   ,nDecValor)*/
                     nValMoeEF3 := EX401ProvTot(cAliasEF1, cAliasEF3,dDt520Ate/*dDtRealLiq*/,dDtProvJur,Alltrim(Str(Val(aJuros[ni]))))
                  Else
                     nValMoeEF3 := Round(EX401ProvJr(cContrato,cBanco,cPraca,cAliasEF3,dDtRealLiq,,IIF(Left(cEvLiq,2)==Left(EV_JUROS_PREPAG,2),cEvLiq,cEvVin),cTpModu,cSeqCon),nDecValor)  // PLB 12/06/06 - IIF(cMod) Se o modulo for importacao passa o proprio evento como parametro	// GCC - 17/09/2013
                  EndIf
                  // **
               EndIf
               // **

               (cAliasEF3)->EF3_PREEMB := cPreemb
               (cAliasEF3)->EF3_INVOIC := cInvoice
               (cAliasEF3)->EF3_PARC   := cParc

               For i:=1 to Len(aTx_Dia)
                  //nValAux1 += aTx_Dia[i,2] * (aTx_Dia[i,1] / 100) * If(lPrePag.and.If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04"),nValMoeEF3,nVal1)
                  nValAux1 += Round(aTx_Dia[i,2] * (aTx_Dia[i,1] / 100) * If(lPrePag.and.cMod==EXP.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nValMoeEF3,nVal1),nDecValor)
               Next i
               (cAliasEF3)->EF3_MOE_IN := cMoeInv
               (cAliasEF3)->EF3_VL_MOE := If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nValMoeEF3,nValAux1)
         //    (cAliasEF3)->EF3_VL_REA := nValAux1 * nTaxa1
               (cAliasEF3)->EF3_VL_REA := If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nTaxa1*nValMoeEF3,nValAux1*nTxJuros1)

               // **Arredonda valores da provisão
               If (nVLMOE640 - ((cAliasEF3)->EF3_VL_MOE + nPJAnt)) > 0 .and.;         //GFC 26/09/03
               (nVLMOE640 - ((cAliasEF3)->EF3_VL_MOE + nPJAnt)) < 0.02
                  (cAliasEF3)->EF3_VL_MOE += (nVLMOE640 - ((cAliasEF3)->EF3_VL_MOE + nPJAnt))
               ElseIf  (nVLMOE640 - ((cAliasEF3)->EF3_VL_MOE + nPJAnt)) < 0 .and.;    //GFC 26/09/03
               (nVLMOE640 - ((cAliasEF3)->EF3_VL_MOE + nPJAnt)) > -0.02
                  (cAliasEF3)->EF3_VL_MOE += (nVLMOE640 - ((cAliasEF3)->EF3_VL_MOE + nPJAnt))
               EndIf
               If (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR)) > 0 .and.;         //GFC 26/09/03
               (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR)) < 0.02
                  (cAliasEF3)->EF3_VL_REA += (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR))
               ElseIf  (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR)) < 0 .and.;    //GFC 26/09/03
               (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR)) > -0.02
                  (cAliasEF3)->EF3_VL_REA += (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR))
               EndIf
               // **

               // ** GFC - 21/12/05 - Não gravar provisão negativa, gravar o estorno de provisão (510)
               If (cAliasEF3)->EF3_VL_MOE >= 0
                  (cAliasEF3)->EF3_CODEVE := Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
               Else
                  (cAliasEF3)->EF3_CODEVE := Left(EV_EST_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
                  (cAliasEF3)->EF3_VL_MOE := Abs((cAliasEF3)->EF3_VL_MOE)
                  (cAliasEF3)->EF3_VL_REA := (cAliasEF3)->EF3_VL_MOE * If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nTaxa1,nTxJuros1)
               EndIf
               // **

               (cAliasEF3)->EF3_TX_MOE := If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nTaxa1,nTxJuros1)
               (cAliasEF3)->EF3_DT_EVE := dDt520Ate //dDtRealLiq  //dDataLiq //dData   // PLB 18/10/06 ASK 19/10/07
               //NCF - 27/03/2014 - Gravação da data de liquidação
               If (cAliasEF3)->(FieldPos("EF3_DTOREV")) > 0
                  (cAliasEF3)->EF3_DTOREV := (cAliasEF3)->EF3_DT_EVE
               EndIf
               //NCF - 02/06/2014 - Gravação da data de emissão do título relativo ao evento
               If (cAliasEF3)->(FieldPos("EF3_DTEMTT")) > 0
                  (cAliasEF3)->EF3_DTEMTT := dDtRealLiq
               EndIf
               (cAliasEF3)->EF3_SEQ    := cSeq

               // ** GFC - 21/12/05 - Não gravar provisão negativa, gravar o estorno de provisão (510)
               If Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_PJ,2) //520
                  If cAliasEF1 == "M"
                     M->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
                     M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
                  Else
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                     (cAliasEF1)->(RecLock(cAliasEF1,.F.))
                     (cAliasEF1)->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
                     (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
                  EndIf
                  nVLMOE520  := (cAliasEF3)->EF3_VL_MOE
                  nVLREAL520 := (cAliasEF3)->EF3_VL_REA
                  If (nVLMOE640-(nVLMOE520+nMOE520Dif)) = nPJAnt
                     nJurosAnt := nPJAnt
                  Else
                     nJurosAnt := (nVLMOE640-(nVLMOE520+nMOE520Dif))
                  EndIf
                  // ** GFC - 23/07/05
                  nPJAnt  += (cAliasEF3)->EF3_VL_MOE
                  nPJAntR += (cAliasEF3)->EF3_VL_REA
                  // **
               Else
                  If cAliasEF1 == "M"
                     M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                     M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
                  Else
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                     (cAliasEF1)->(RecLock(cAliasEF1,.F.))
                     (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                     (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
                  EndIf
                  nVLMOE520  := (cAliasEF3)->EF3_VL_MOE * -1
                  nVLREAL520 := (cAliasEF3)->EF3_VL_REA * -1
                  If (nVLMOE640-(nVLMOE520+nMOE520Dif)) = nPJAnt
                     nJurosAnt := nPJAnt
                  Else
                     nJurosAnt := (nVLMOE640-(nVLMOE520+nMOE520Dif))
                  EndIf
                  // ** GFC - 23/07/05
                  nPJAnt  -= (cAliasEF3)->EF3_VL_MOE
                  nPJAntR -= (cAliasEF3)->EF3_VL_REA
                  // **
               EndIf
               // **

               If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                  (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
               Else
                  (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
               EndIf

               // ** GFC - Pré-Pagamento/Securitização
               If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
                  (cAliasEF3)->EF3_PARVIN := cParcVin
                  (cAliasEF3)->EF3_EV_VIN := cEvVin
               EndIf
               // **

               //FSM - 10/04/2012
               If Upper(cAliasEF3) == "WORKEF3"
                  (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
               EndIf

               (cAliasEF3)->(msUnlock())

               //NCF - 29/08/2014
               If cChamada $ ("CAMB/FFC") .and. lLogix
                  AF200BkPInt( cAliasEF3 , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
               EndIf

               If EasyEntryPoint("EFFEX400") //Alcir Alves - 19-09-05
                  ExecBlock("EFFEX400",.F.,.F.,"APOS_GRV_520")
               Endif
               nTxAux1  := (cAliasEF3)->EF3_TX_MOE

               If lCadFin
                  EX401GrEncargos(cAliasEF3)
               EndIf

               // PLB 18/05/07 - Condicao inteira barrada pois sempre que houver Provisão de Juros deve calcular Variação Cambial

               //If ( lTemPgJuros .and. (iif(cAliasEF1 = "M", M->EF1_PGJURO, EF1->EF1_PGJURO) $ cSim) ) .or. .not. lTemPgJuros .or.;
               //(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1" .AND.;//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04") .and.;
               //Left(cEvVin,2) == Left(EV_JUROS_PREPAG,2) .and. (cChamada<>"MANUT2" .Or. (cMod==EXP .And. Left(cEvLiq,2) == Left(EV_JUROS_PREPAG,2)) ) ) //PLB 23/06/06

                  //Grava Evento 550/551 - Variação Cambial sobre Provisão de Juros
                  (cAliasEF3)->(RecLock(cAliasEF3,.T.))
                  (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
                  If ValType(cFilOri) == "C"
                     (cAliasEF3)->EF3_FILORI := cFilOri
                  EndIf
                  If lEFFTpMod
                     (cAliasEF3)->EF3_TPMODU := cTpModu
                     // ** GFC - 19/04/06
                     (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
                     // **
                  EndIf
                  //(cAliasEF3)->EF3_CODEVE := EV_VC_PJ
                  //(cAliasEF3)->EF3_CODEVE := IF(((nVLMOE640-nVLMOE520) * nTxJuros1) - ((nVLMOE640-nVLMOE520) * nTaxaVCJuros)>0,Alltrim(Str(550+(Val(aJuros[ni])*2))),Alltrim(Str(551+(Val(aJuros[ni])*2))))	//Alexandre

                  If lPrePag  .And.  If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"
                     If cMod <> IMP
                        nProvTot := EX401ProvTot(cAliasEF1, cAliasEF3,dDt520Ate/*dDtRealLiq*/,,Alltrim(Str(Val(aJuros[ni]))))
                        nProvTot -= nValMoeEF3

						   //AAF 18/07/2015 - Retirar não atualizar o saldo de juros que ja está pago.
						   nProvTot -= EX401EvSum("71"+Alltrim(Str(Val(aJuros[ni]))),cAliasEF3,if(cAliasEF3=="EF3",EF1->(xFilial("EF1")+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),),.T.,{|| (cAliasEF3)->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0 .AND. RecNo() <> nRecEF3)})

                        nVariacao := Round(nProvTot * (nTaxa1 - nTaxaVCJuros),nDecValor)
                     Else
                        nVariacao := Round(((nValMoeEF3 - (nVLMOE520 + nMOE520Dif) ) * nTaxa1) - ((nValMoeEF3-(nVLMOE520+nMOE520Dif)) * nTaxaVCJuros) , 2)
                     EndIf
                  Else
                     nVariacao := (Round(nVLREAL640,2) - Round(((nVLMOE520+nMOE520Dif) * nTxJuros1),2)) - Round(((nVLMOE640-(nVLMOE520+nMOE520Dif)) * nTaxaVCJuros),2) //FSM - 13/12/2012
                  EndIf

                  (cAliasEF3)->EF3_CODEVE := IIF(nVariacao>0,Alltrim(Str(550+(Val(aJuros[ni])*2))),Alltrim(Str(551+(Val(aJuros[ni])*2))))
                  (cAliasEF3)->EF3_CONTRA := cContrato

                  // ACSJ - 06/05/2005
                  If lTemChave
                     (cAliasEF3)->EF3_BANC   := cBanco
                     (cAliasEF3)->EF3_AGEN   := cAgencia
                     (cAliasEF3)->EF3_NCON   := cConta
                     (cAliasEF3)->EF3_PRACA  := cPraca
                     (cAliasEF3)->EF3_BAN_FI := If(cAliasEF1 == "M", M->EF1_BAN_FI, (cAliasEF1)->EF1_BAN_FI)
                     (cAliasEF3)->EF3_AGENFI := If(cAliasEF1 == "M", M->EF1_AGENFI, (cAliasEF1)->EF1_AGENFI)
                     (cAliasEF3)->EF3_NCONFI := If(cAliasEF1 == "M", M->EF1_NCONFI, (cAliasEF1)->EF1_NCONFI)
                     If lEFFTpMod
                        (cAliasEF3)->EF3_SEQCNT := cSeqCon
                     EndIf
                  Endif

                  (cAliasEF3)->EF3_PREEMB := cPreemb
                  (cAliasEF3)->EF3_INVOIC := cInvoice
                  (cAliasEF3)->EF3_PARC   := cParc

                  /*
         //       (cAliasEF3)->EF3_VL_REA := ((nVLMOE640-nVLMOE520) * nTaxa1) - ((nVLMOE640-nVLMOE520) * nTaxaVC) //(nJurosAnt * nTaxa1) - (nJurosAnt * nTaxaVC)
                  // ** PLB 22/06/06 - Se tiver Parcela de Pagamento nValMoeEF3 e nTaxa1
                  If lPrePag  .And.  If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"
                     (cAliasEF3)->EF3_VL_REA := Round(((nValMoeEF3 - (nVLMOE520 + nMOE520Dif) ) * nTaxa1) - ((nValMoeEF3-(nVLMOE520+nMOE520Dif)) * nTaxaVCJuros) , 2)
                  Else
                     //(cAliasEF3)->EF3_VL_REA := (nVLREAL640 - Round(((nVLMOE520+nMOE520Dif) * If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nTaxa1,nTxJuros1)),2)) - Round(((nVLMOE640-(nVLMOE520+nMOE520Dif)) * nTaxaVCJuros),2) //(nJurosAnt * nTaxa1) - (nJurosAnt * nTaxaVC)
                     (cAliasEF3)->EF3_VL_REA := (nVLREAL640 - Round(((nVLMOE520+nMOE520Dif) * nTxJuros1),2)) - Round(((nVLMOE640-(nVLMOE520+nMOE520Dif)) * nTaxaVCJuros),2)
                  EndIf
                  // **
                  */

                  (cAliasEF3)->EF3_VL_REA := nVariacao

                  (cAliasEF3)->EF3_MOE_IN := cMoeInv
         //       (cAliasEF3)->EF3_TX_MOE := nTaxa1
                  (cAliasEF3)->EF3_TX_MOE := If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nTaxa1,nTxJuros1)
                  (cAliasEF3)->EF3_DT_EVE := dDt520Ate //dDtRealLiq // dData	// GCC - 17/09/2013
                  //NCF - 27/03/2014 - Gravação da data de liquidação
                  If (cAliasEF3)->(FieldPos("EF3_DTOREV")) > 0
                     (cAliasEF3)->EF3_DTOREV := (cAliasEF3)->EF3_DT_EVE
                  EndIf
                  //NCF - 02/06/2014 - Gravação da data de emissão do título relativo ao evento
                  If (cAliasEF3)->(FieldPos("EF3_DTEMTT")) > 0
                     (cAliasEF3)->EF3_DTEMTT := dDtRealLiq
                  EndIf
                  (cAliasEF3)->EF3_SEQ    := cSeq

                  // ** GFC - 23/07/05 - Arredonda valores da variação do juros
                  /*If (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR)) > 0 .and.;                 //NCF - 03/06/2014 - Nopado
                  (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR)) < 0.02
                     (cAliasEF3)->EF3_VL_REA += (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR))
                  ElseIf  (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR)) < 0 .and.;
                  (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR)) > -0.02
                     (cAliasEF3)->EF3_VL_REA += (nVLREAL640 - ((cAliasEF3)->EF3_VL_REA + nPJAntR))
                  EndIf*/
                  // **

                  If (If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nValMoeEF3*nTaxa1,nVLREAL640) - Round(((nVLMOE520+nMOE520Dif) * If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nTaxa1,nTxJuros1)),2)) - Round(((If(lPrePag.and.If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1",nValMoeEF3,nVLMOE640)-(nVLMOE520+nMOE520Dif)) * nTaxaVCJuros),2) > 0   // PLB 22/06/06 - Se tiver Parcela de Pagamento nValMoeEF3 e nTaxa1
                     If cAliasEF1 == "M"
            //          M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                        M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
                        If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                           (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
                        Else
                           (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                        Endif
                     Else
                        //NCF - 29/08/2014
                        If cChamada $ ("CAMB/FFC") .and. lLogix
                           AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                        EndIf
                        (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         //             (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                        (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
                        If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                           (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
                        Else
                           (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                        Endif
                     EndIf
                  Else
                     If cAliasEF1 == "M"
         //             M->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
                        M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
                        If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                           (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
                        Else
                           (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                        Endif
                     Else
                        //NCF - 29/08/2014
                        If cChamada $ ("CAMB/FFC") .and. lLogix
                           AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                        EndIf
                        (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         //             (cAliasEF1)->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
                        (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
                        If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                           (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
                        Else
                           (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                        Endif
                     EndIf
                  EndIf

                  //FSM - 10/04/2012
                  If Upper(cAliasEF3) == "WORKEF3"
                     (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
                  EndIf

                  (cAliasEF3)->(msUnlock())

                  //NCF - 29/08/2014
                  If cChamada $ ("CAMB/FFC") .and. lLogix
                     AF200BkPInt( cAliasEF3 , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
                  EndIf

                  nRec550 := (cAliasEF3)->(RecNo())

                  If lCadFin
                     EX401GrEncargos(cAliasEF3)
                  EndIf
               //Endif
//--------------------------------------------------------------

               // ** PLB 31/07/06
               If cChamada == "MANUT2"  .And.  IIF( lEFFTpMod, M->EF1_CAMTRA=="1", lPrepag .And. M->EF1_TP_FIN $ "03/04")  .And.  Left(cEvLiq,2) == Left(EV_JUROS_PREPAG,2)
                  If nVlMoe640 == 0
                     (cAliasEF3)->( DBGoTo(nRecEF3) )
                     nVlMoe640 := (cAliasEF3)->EF3_VL_MOE
                  EndIf
               EndIf
               // **

               If cMod == EXP .and. Abs(((nVLMOE640-nVLMOE520) - nPJAnt) * nTxJuros2 ) > 0.05 .and. nPJAnt > nVLMOE640 // VI 11/09/03
                  //Grava Evento de Estorno da Provisao de Juros 510
                  (cAliasEF3)->(RecLock(cAliasEF3,.T.))
                  (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
                  If ValType(cFilOri) == "C"
                     (cAliasEF3)->EF3_FILORI := cFilOri
                  EndIf
                  If lEFFTpMod
                     (cAliasEF3)->EF3_TPMODU := cTpModu
                     // ** GFC - 19/04/06
                     (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
                     // **
                  EndIf
                  (cAliasEF3)->EF3_CODEVE := Left(EV_EST_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
                  (cAliasEF3)->EF3_CONTRA := cContrato

                  // ACSJ - 06/02/2005
                  If lTemChave
                     (cAliasEF3)->EF3_BANC   := cBanco
                     (cAliasEF3)->EF3_AGEN   := cAgencia
                     (cAliasEF3)->EF3_NCON   := cConta
                     (cAliasEF3)->EF3_PRACA  := cPraca
                     (cAliasEF3)->EF3_BAN_FI := If(cAliasEF1 == "M", M->EF1_BAN_FI, (cAliasEF1)->EF1_BAN_FI)
                     (cAliasEF3)->EF3_AGENFI := If(cAliasEF1 == "M", M->EF1_AGENFI, (cAliasEF1)->EF1_AGENFI)
                     (cAliasEF3)->EF3_NCONFI := If(cAliasEF1 == "M", M->EF1_NCONFI, (cAliasEF1)->EF1_NCONFI)
                     If lEFFTpMod
                        (cAliasEF3)->EF3_SEQCNT := cSeqCon
                     EndIf
                  Endif

                  (cAliasEF3)->EF3_PREEMB := cPreemb
                  (cAliasEF3)->EF3_INVOIC := cInvoice
                  (cAliasEF3)->EF3_PARC   := cParc

                  (cAliasEF3)->EF3_VL_MOE := (nPJAnt - nVLMOE640)
         //       (cAliasEF3)->EF3_VL_REA := (nPJAnt - nVLMOE640) * If(cAliasEF1 == "M", M->EF1_TX_CTB, (cAliasEF1)->EF1_TX_CTB)//nTaxa1
                  (cAliasEF3)->EF3_VL_REA := (nPJAnt - nVLMOE640) * nTxJuros2
                  (cAliasEF3)->EF3_MOE_IN := cMoeInv
         //       (cAliasEF3)->EF3_TX_MOE := nTaxa1
                  (cAliasEF3)->EF3_TX_MOE := nTxJuros2
                  (cAliasEF3)->EF3_DT_EVE := dDtRealLiq
                  //NCF - 27/03/2014 - Gravação da data de liquidação
                  If (cAliasEF3)->(FieldPos("EF3_DTOREV")) > 0
                     (cAliasEF3)->EF3_DTOREV := (cAliasEF3)->EF3_DT_EVE
                  EndIf
                  //NCF - 02/06/2014 - Gravação da data de emissão do título relativo ao evento
                  If (cAliasEF3)->(FieldPos("EF3_DTEMTT")) > 0
                     (cAliasEF3)->EF3_DTEMTT := dDtRealLiq
                  EndIf

                  (cAliasEF3)->EF3_SEQ    := cSeq
                  If cAliasEF1 == "M"
                     M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                     M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
                     If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                        (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
                     Else
                        (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                     Endif
                  Else
                     //NCF - 29/08/2014
                     If cChamada $ ("CAMB/FFC") .and. lLogix
                        AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
                     EndIf
                     (cAliasEF1)->(RecLock(cAliasEF1,.F.))
                     (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
                     (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
                     If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                        (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
                     Else
                        (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
                     Endif
                  EndIf

                  //FSM - 10/04/2012
                  If Upper(cAliasEF3) == "WORKEF3"
                     (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
                  EndIf
                  (cAliasEF3)->(msUnlock())

                  //NCF - 29/08/2014
                  If cChamada $ ("CAMB/FFC") .and. lLogix
                     AF200BkPInt( cAliasEF3 , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
                  EndIf

                  If lCadFin
                     EX401GrEncargos(cAliasEF3)
                  EndIf
               EndIf
            EndIf
         EndIf

         If lPVez .and. (!(lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1") .OR.;//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) .or.;
         (lBaixouParc .and. cEvVin == EV_PRINC_PREPAG) .OR. ( lBaixouParc .AND. cMod == IMP .AND. cEvLiq == EV_PRINC_PREPAG ) )// ** GFC - Pré-Pagamento/Securitização

			//** AAF - 28/01/2015 - Utilizar cotação da ultima contabilização. Pode ser diferente do gravado no campo EF1_TX_CTB (pode ser compra/venda).
		    aTx500 := GetTxCtb(cAliasEF3, "500",cTpModu, cInvoice, cParc)
		    aTx501 := GetTxCtb(cAliasEF3, "501",cTpModu, cInvoice, cParc)

		    If aTx500[2] > aTx501[2]
		       nTxCtb := aTx500[1]
		    ElseIf aTx501[2] > aTx500[2] .OR. !Empty(aTx501[2])
  		       nTxCtb := aTx501[1]
		    EndIf
			//**

			//Grava Evento 500/501 - Variação Cambial do Principal
            (cAliasEF3)->(RecLock(cAliasEF3,.T.))
            (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
            If ValType(cFilOri) == "C"
               (cAliasEF3)->EF3_FILORI := cFilOri
            EndIf
            If lEFFTpMod
               (cAliasEF3)->EF3_TPMODU := cTpModu
               // ** GFC - 19/04/06
               (cAliasEF3)->EF3_ROF := &(cAliasEF1+"->EF1_ROF")
               // **
            EndIf
            (cAliasEF3)->EF3_CODEVE := EV_VC_PRC
            (cAliasEF3)->EF3_CONTRA := cContrato

            // ACSJ- 06/02/2005
            If lTemChave
               (cAliasEF3)->EF3_BANC   := cBanco
               (cAliasEF3)->EF3_AGEN   := cAgencia
               (cAliasEF3)->EF3_NCON   := cConta
               (cAliasEF3)->EF3_PRACA  := cPraca
               (cAliasEF3)->EF3_BAN_FI := If(cAliasEF1 == "M", M->EF1_BAN_FI, (cAliasEF1)->EF1_BAN_FI)
               (cAliasEF3)->EF3_AGENFI := If(cAliasEF1 == "M", M->EF1_AGENFI, (cAliasEF1)->EF1_AGENFI)
               (cAliasEF3)->EF3_NCONFI := If(cAliasEF1 == "M", M->EF1_NCONFI, (cAliasEF1)->EF1_NCONFI)
               If lEFFTpMod
                  (cAliasEF3)->EF3_SEQCNT := cSeqCon
               EndIf
            Endif

            (cAliasEF3)->EF3_PREEMB := cPreemb
            (cAliasEF3)->EF3_INVOIC := cInvoice
            (cAliasEF3)->EF3_PARC   := cParc

            // (cAliasEF3)->EF3_VL_REA := (nVal1 * nTaxa1) - (nVal1 * If(cAliasEF1=="M",M->EF1_TX_CTB,(cAliasEF1)->EF1_TX_CTB))
            (cAliasEF3)->EF3_MOE_IN := cMoeInv

            If cMod <> IMP .AND. (lBaixouParc .and. cEvVin == EV_PRINC_PREPAG)
               // ** AAF 09/04/08 - Calcular variação sobre todo principal liquidado no pré-pagamento.
               (cAliasEF3)->EF3_VL_REA := nValMoeEF3 * nTaxa1 - nValMoeEF3 * nTxCtb
               // **
            Else
               (cAliasEF3)->EF3_VL_REA := If(nValorRea<>NIL,nValorRea,(nVal1 * nTaxa1)) - (nVal1 * nTxCtb) //(nVal1 * nTaxa1) - (nVal1 * nTxCtb)
            EndIf
            (cAliasEF3)->EF3_TX_MOE := nTaxa1
            (cAliasEF3)->EF3_TX_CON := (cAliasEF3)->EF3_VL_REA / (cAliasEF3)->EF3_VL_INV
            (cAliasEF3)->EF3_DT_EVE := dDtRealLiq
            //NCF - 27/03/2014 - Gravação da data de liquidação
            If (cAliasEF3)->(FieldPos("EF3_DTOREV")) > 0
               (cAliasEF3)->EF3_DTOREV := (cAliasEF3)->EF3_DT_EVE
            EndIf
            //NCF - 02/06/2014 - Gravação da data de emissão do título relativo ao evento
            If (cAliasEF3)->(FieldPos("EF3_DTEMTT")) > 0
               (cAliasEF3)->EF3_DTEMTT := dDtRealLiq
            EndIf
            (cAliasEF3)->EF3_DT_CIN := dDataBase
            (cAliasEF3)->EF3_SEQ    := cSeq
            // ** GFC - Pré-Pagamento/Securitização
            If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
               (cAliasEF3)->EF3_PARVIN := cParcVin
               (cAliasEF3)->EF3_EV_VIN := cEvVin
            EndIf
            // **
            // ** PLB 19/04/07 - Verifica se a Variação Cambial é negativa e troca o Código
            If (cAliasEF3)->EF3_VL_REA <= 0
               (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
            EndIf
            // **
            If cAliasEF1 == "M"
               M->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
               // ** PLB 19/07/06  -  Soma Variação Cambial ao Saldo de Juros em Reais
               If (lEFFTpMod  .And.  M->EF1_CAMTRA == "1") .Or. (lPrePag .And. M->EF1_TP_FIN $ ("03/04"))
                  M->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
               EndIf
               // **
               If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                  (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
               Else
                  (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
               Endif
               /*
               If M->EF1_TX_CTB > 0 .and. (cAliasEF3)->EF3_TX_MOE < M->EF1_TX_CTB
                  (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
               ElseIf M->EF1_TX_CTB <= 0 .and. (cAliasEF3)->EF3_TX_MOE < nTx600
                  (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
               EndIf
               */
            Else
               //NCF - 29/08/2014
               If cChamada $ ("CAMB/FFC") .and. lLogix
                  AF200BkPInt( cAliasEF1 , "EEC_INBX_ALT",,{'EEQ',EEQ->(Recno())},,)
               EndIf
               (cAliasEF1)->(RecLock(cAliasEF1,.F.))
               (cAliasEF1)->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
               // ** PLB 19/07/06  -  Soma Variação Cambial ao Saldo de Juros em Reais
               If (lEFFTpMod  .And.  (cAliasEF1)->EF1_CAMTRA == "1") .Or. (lPrePag .And. (cAliasEF1)->EF1_TP_FIN $ ("03/04"))
                  (cAliasEF1)->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
               EndIf
               // **
               If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
                  (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
               Else
                  (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
               Endif
               /*
               If (cAliasEF1)->EF1_TX_CTB > 0 .and. (cAliasEF3)->EF3_TX_MOE < (cAliasEF1)->EF1_TX_CTB
                  (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
               ElseIf (cAliasEF1)->EF1_TX_CTB <= 0 .and. (cAliasEF3)->EF3_TX_MOE < nTx600
                  (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
               EndIf
               */
            EndIf
            (cAliasEF3)->EF3_EV_VIN := EV_LIQ_PRC  // GFP - 04/08/2014
            //FSM - 03/04/2012
            If Upper(cAliasEF3) == "WORKEF3"
               (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
            EndIf

            (cAliasEF3)->(msUnlock())

            //NCF - 29/08/2014
            If cChamada $ ("CAMB/FFC") .and. lLogix
               AF200BkPInt( cAliasEF3 , "EEC_INBX_INC",,{'EEQ',EEQ->(Recno())},,)
            EndIf

            If lCadFin
               EX401GrEncargos(cAliasEF3)
            EndIf
         EndIf

      Next ni

   EndIf

   // ** GFC - 18/07/05
   If lBaixouParc
      If cAliasEF3 == "EF3"
         (cAliasEF3)->(dbSetOrder(1))
      Else
         (cAliasEF3)->(dbSetOrder(2))
      EndIf
      If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")+cEvVin+If(cAliasEF3=="WorkEF3",Space(Len(EF3->EF3_INVOIC)),"")+cParcVin))
         //WFS - não exibir a tela quando estiver em uma transação
         If !lLiqAuto
            EX401SelLiq(.F.,.T.,cSeq,cInvoice,cParc,cPreemb,cChamada)
         EndIf
      EndIf
      (cAliasEF3)->(dbSetOrder(nOrdEF3))
      (cAliasEF3)->(dbGoTo(nRecEF3))     //HVR 27/04/06
   EndIf
   // **

   /* AAF 29/01/2015 - Não fazer ajuste de saldo modificando evento de liquidação.
   // ** GFC - 21/09/05 - Zerar valores de saldo compreendidos entre 0,5 e -0,5
   If nRec640 <> NIL
      (cAliasEF3)->(dbGoTo(nRec640))
      If cAliasEF1 == "M"
         If (M->EF1_SL2_JM < 0.5 .and. M->EF1_SL2_JM > 0) .or. (M->EF1_SL2_JM < 0 .and. M->EF1_SL2_JM > -0.5)
            (cAliasEF3)->EF3_VL_MOE += M->EF1_SL2_JM
            M->EF1_LIQJRM += M->EF1_SL2_JM
            M->EF1_SL2_JM := 0
         EndIf

         If ((M->EF1_SL2_JR < 0.5 .and. M->EF1_SL2_JR > 0) .or. (M->EF1_SL2_JR < 0 .and. M->EF1_SL2_JR > -0.5)) .And. nRec550 <> Nil
            (cAliasEF3)->EF3_VL_REA += M->EF1_SL2_JR
            M->EF1_LIQJRR += M->EF1_SL2_JR
            (cAliasEF3)->(dbGoTo(nRec550))
            (cAliasEF3)->EF3_VL_REA += M->EF1_SL2_JR
            M->EF1_SL2_JR := 0
         EndIf
      Else

		 If ((cAliasEF1)->EF1_SL2_JM < 0.5 .and. (cAliasEF1)->EF1_SL2_JM > 0) .or.;
         ((cAliasEF1)->EF1_SL2_JM < 0 .and. (cAliasEF1)->EF1_SL2_JM > -0.5)
            (cAliasEF3)->EF3_VL_MOE += (cAliasEF1)->EF1_SL2_JM
            (cAliasEF1)->EF1_LIQJRM += (cAliasEF1)->EF1_SL2_JM
            (cAliasEF1)->EF1_SL2_JM := 0
         EndIf

         If (((cAliasEF1)->EF1_SL2_JR < 0.5 .and. (cAliasEF1)->EF1_SL2_JR > 0) .or.;
         ((cAliasEF1)->EF1_SL2_JR < 0 .and. (cAliasEF1)->EF1_SL2_JR > -0.5)) .And. nRec550 <> Nil
            (cAliasEF3)->EF3_VL_REA += (cAliasEF1)->EF1_SL2_JR
            (cAliasEF1)->EF1_LIQJRR += (cAliasEF1)->EF1_SL2_JR
            (cAliasEF3)->(dbGoTo(nRec550))
            (cAliasEF3)->EF3_VL_REA += (cAliasEF1)->EF1_SL2_JR
            (cAliasEF1)->EF1_SL2_JR := 0
         EndIf

      EndIf
   EndIf
   // **
   */
EndIf

If !Empty(If(cAliasEF1 == "M",M->EF1_DT_ENC,EF1->EF1_DT_ENC))
   EX401EncJr(cAliasEF1 == "M",If(cAliasEF1 == "M",M->EF1_DT_ENC,EF1->EF1_DT_ENC),If(cAliasEF1=="M",BuscaEF3Seq(),BuscaEF3Seq(cAliasEF3,cContrato,cBanco,cPraca,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))))
EndIf

If cChamada == "CAMB" .or. If( lLogix, cChamada $ "CAMB/FFC", .F. ) //NCF - 16/10/2014
   oEFFContrato:EventoFinanceiro("ATUALIZA_PROVISORIOS")

   oEFFContrato:ShowErrors()
EndIf

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato
EX401Saldo(cAliasEF1,IIF(lEFFTpMod,cMod,),&(cAliasEF1+"->EF1_CONTRA"),IIF(lTemChave,&(cAliasEF1+"->EF1_BAN_FI"),),IIF(lTemChave,&(cAliasEF1+"->EF1_PRACA"),),IIF(lEFFTpMod,&(cAliasEF1+"->EF1_SEQCNT"),),cAliasEF3,.T.)

Return .T.

*-------------------------------------------------------------------------------------------*
Function EX400EvEstorno(cContrato,cInvoice,cParc,cPreemb,nValor,cMoeInv,cMoeCont,;
                        cAliasEF1,cAliasEF3,cChamada,nTx,dDataEve,cSeq,cFilOri,cBanco,cPraca,cTpModu,cSeqCon)
*-------------------------------------------------------------------------------------------*
Local nTaxaEve := 0, nTaxaAtu := 0, nValAux := 0, ni, aJuros:={}, lPVez:=.T., i
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Local nDecTaxa := AVSX3("EF3_TX_MOE",4)
Private cChamaPRW := cChamada  //Alcir Alves - 20-09-05 - define como private o cChamada para tratamento em rdmakes

lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0

nTaxaEve  := Round(BuscaTaxa(cMoeInv,dDataEve,,.F.,.T.,,cTX_100),nDecTaxa)
nTaxaEveJuros := Round(BuscaTaxa(cMoeInv,dDataEve,,.F.,.T.,,cTX_520),nDecTaxa)
nTaxaAtu  := Round(BuscaTaxa(cMoeInv,dDataBase,,.F.,.T.,,cTX_100),nDecTaxa)
nTaxaAtuJuros := Round(BuscaTaxa(cMoeInv,dDataBase,,.F.,.T.,,cTX_520),nDecTaxa)

dDt       := If(!Empty((cAliasEF3)->EF3_DT_EVE),(cAliasEF3)->EF3_DT_EVE,dDataBase)

If lEF2_TIPJUR
   aJuros := EX400BusJur(If(cChamada=="CAMB","EF2","WorkEF2"),cAliasEF1)
Else
   aJuros := {"0"}
EndIf

For ni:=1 to len(aJuros)

   If ni > 1
      lPVez := .F.
   EndIf

   // PLB 09/08/06 - Verifica periodo de Transferencias de Juros de ACC para ACE
   If cMod == EXP  .And.  IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) == ACC
      aTx_Dia   := EX400BusTx(IIF(EX401ExACE(cChamada,aJuros[ni],cFilOri,cInvoice,cParc) .OR. EX401ExACE(cChamada,aJuros[ni],Space(Len(EF2->EF2_FILIAL)),Space(Len(EF2->EF2_INVOIC)),Space(Len(EF2->EF2_PARC))),ACE,ACC),dDataBase,dDataEve,If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc)
   Else
      aTx_Dia   := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),dDataBase,dDataEve,If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc)
   EndIf

   //Grava Evento 520 - Provisão de Juros
   For i:=1 to Len(aTx_Dia)
       nValAux += Round(aTx_Dia[i,2] * (aTx_Dia[i,1] / 100) * If(cAliasEF1=="M",M->EF1_SL2_PM,(cAliasEF1)->EF1_SL2_PM),nDecValor)
   Next i

   If nValAux > 0
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf

      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
      EndIf

      (cAliasEF3)->EF3_CODEVE := Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
      (cAliasEF3)->EF3_CONTRA := cContrato
      // ACSJ - 09/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif
      //-------------------
      (cAliasEF3)->EF3_PREEMB := cPreemb
      (cAliasEF3)->EF3_INVOIC := cInvoice
      (cAliasEF3)->EF3_PARC   := cParc
      (cAliasEF3)->EF3_VL_MOE := nValAux
      //(cAliasEF3)->EF3_VL_REA := nValAux * nTaxaAtu
      (cAliasEF3)->EF3_VL_REA := nValAux * nTaxaAtuJuros
      //(cAliasEF3)->EF3_TX_MOE := nTaxaAtu
      (cAliasEF3)->EF3_TX_MOE := nTaxaAtuJuros
      (cAliasEF3)->EF3_DT_EVE := dDataBase
      (cAliasEF3)->EF3_SEQ    := cSeq
      (cAliasEF3)->EF3_MOE_IN := cMoeInv
      If cAliasEF1 == "M"
         M->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
         M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
         (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
      Else
         //NCF - 29/08/2014
         If cChamada $ ("CAMB/FFC") .and. lLogix
            AF200BkPInt( cAliasEF1 , "EEC_ESBX_ALT",,{'EEQ',EEQ->(Recno())},,)
         EndIf
         (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         (cAliasEF1)->EF1_SL2_JM += (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
         If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
            (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
         Else
            (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
         EndIf
      EndIf

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf

      (cAliasEF3)->(msUnlock())
      If EasyEntryPoint("EFFEX400") //Alcir Alves - 19-09-05
         ExecBlock("EFFEX400",.F.,.F.,"APOS_GRV_520")
      Endif

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf
   EndIf

   nVcJurRea := (If(cAliasEF1=="M",M->EF1_SL2_JM,(cAliasEF1)->EF1_SL2_JM) * nTaxaAtuJuros) - (If(cAliasEF1=="M",M->EF1_SL2_JM,(cAliasEF1)->EF1_SL2_JM) * nTaxaEveJuros)

   If nVcJurRea <> 0
      //Grava Evento 550 - Variação Cambial sobre Provisão de Juros
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf

      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
      EndIf

      //(cAliasEF3)->EF3_CODEVE := EV_VC_PJ
      //(cAliasEF3)->EF3_CODEVE := IF((If(cAliasEF1=="M",M->EF1_SL2_JM,(cAliasEF1)->EF1_SL2_JM) * nTaxaAtu) - (If(cAliasEF1=="M",M->EF1_SL2_JM,(cAliasEF1)->EF1_SL2_JM) * nTaxaEve)>0,'550','551')	//Alexandre
      (cAliasEF3)->EF3_CODEVE := IF(nVcJurRea>0,Alltrim(Str(550+(Val(aJuros[ni])*2))),Alltrim(Str(551+(Val(aJuros[ni])*2))))	//Alexandre
      (cAliasEF3)->EF3_CONTRA := cContrato
      // ACSJ - 09/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif
      //-------------------
      (cAliasEF3)->EF3_PREEMB := cPreemb
      (cAliasEF3)->EF3_INVOIC := cInvoice
      (cAliasEF3)->EF3_PARC   := cParc
      //(cAliasEF3)->EF3_VL_REA := (If(cAliasEF1=="M",M->EF1_SL2_JM,(cAliasEF1)->EF1_SL2_JM) * nTaxaAtu) - (If(cAliasEF1=="M",M->EF1_SL2_JM,(cAliasEF1)->EF1_SL2_JM) * nTaxaEve)
      (cAliasEF3)->EF3_VL_REA := nVcJurRea
      //(cAliasEF3)->EF3_TX_MOE := nTaxaAtu
      (cAliasEF3)->EF3_TX_MOE := nTaxaAtuJuros
      (cAliasEF3)->EF3_DT_EVE := dDataBase
      (cAliasEF3)->EF3_SEQ    := cSeq
      (cAliasEF3)->EF3_MOE_IN := cMoeInv
      If (If(cAliasEF1=="M",M->EF1_SL2_JM,(cAliasEF1)->EF1_SL2_JM) * nTaxaAtuJuros) - (If(cAliasEF1=="M",M->EF1_SL2_JM,(cAliasEF1)->EF1_SL2_JM) * nTaxaEveJuros) > 0
         If cAliasEF1 == "M"
            M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
         Else
            (cAliasEF1)->(RecLock(cAliasEF1,.F.))
            (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
            If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
               (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
            Else
               (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
            EndIf
         EndIf
      Else
         If cAliasEF1 == "M"
            M->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
         Else
            (cAliasEF1)->(RecLock(cAliasEF1,.F.))
            (cAliasEF1)->EF1_SL2_JR += (cAliasEF3)->EF3_VL_REA
            If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
               (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
            Else
               (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
            EndIf
         EndIf
      EndIf

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf

      (cAliasEF3)->(msUnlock())

      //NCF - 29/08/2014
      If cChamada $ ("CAMB/FFC") .and. lLogix
         AF200BkPInt( cAliasEF3 , "EEC_ESBX_INC",,{'EEQ',EEQ->(Recno())},,)
      EndIf

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf
   EndIf

   nVcPrRea := (If(cAliasEF1=="M",M->EF1_SL2_PM,(cAliasEF1)->EF1_SL2_PM) * nTaxaAtu) - (If(cAliasEF1=="M",M->EF1_SL2_PM,(cAliasEF1)->EF1_SL2_PM) * nTaxaEve)

   If lPVez .AND. nVcPrRea <> 0
      //Grava Evento 500 - Variação Cambial do Principal
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf
      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
      EndIf
      (cAliasEF3)->EF3_CODEVE := EV_VC_PRC
      (cAliasEF3)->EF3_CONTRA := cContrato
      // ACSJ - 09/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif
      //-------------------
      (cAliasEF3)->EF3_PREEMB := cPreemb
      (cAliasEF3)->EF3_INVOIC := cInvoice
      (cAliasEF3)->EF3_PARC   := cParc
      (cAliasEF3)->EF3_VL_REA := nVcPrRea
      (cAliasEF3)->EF3_TX_MOE := nTaxaAtu
      (cAliasEF3)->EF3_TX_CON := (cAliasEF3)->EF3_VL_REA / (cAliasEF3)->EF3_VL_INV
      (cAliasEF3)->EF3_DT_EVE := dDataBase
      (cAliasEF3)->EF3_DT_CIN := dDataBase
      (cAliasEF3)->EF3_SEQ    := cSeq
      (cAliasEF3)->EF3_MOE_IN := cMoeInv

      If (cAliasEF3)->EF3_VL_REA < 0
         (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
      EndIf

      If cAliasEF1 == "M"
         M->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
         (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
      Else
         //NCF - 29/08/2014
         If cChamada $ ("CAMB/FFC") .and. lLogix
            AF200BkPInt( cAliasEF1 , "EEC_ESBX_ALT",,{'EEQ',EEQ->(Recno())},,)
         EndIf
         (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         (cAliasEF1)->EF1_SL2_PR += (cAliasEF3)->EF3_VL_REA
         If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
            (cAliasEF3)->EF3_TP_EVE := RetAceAcc((cAliasEF3)->EF3_INVOIC) // "02"
         Else
            (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
         Endif
      EndIf

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf

      (cAliasEF3)->(msUnlock())

      //NCF - 29/08/2014
      If cChamada $ ("CAMB/FFC") .and. lLogix
         AF200BkPInt( cAliasEF3 , "EEC_ESBX_INC",,{'EEQ',EEQ->(Recno())},,)
      EndIf

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf

   EndIf

Next ni

Return .T.

*------------------------*
Function EX400EstEV(cSeq,cTipo,lParcPag,lEstRef)
*------------------------*
Local nOrd:=WorkEF3->(IndexOrd())//, cTipo:=""
Default lEstRef := .F.

If Type('lGerTitEvEnc') <> 'L'
   lGerTitEvEnc:= .F.
EndIf

IIF(cTipo   ==NIL,cTipo   :="" ,)  // PLB 23/10/06  -  Parametro em substituica a variavel local
IIF(lParcPag==NIL,lParcPag:=.F.,)  // PLB 23/10/06  -  Parametro que verifica se é estorno de eventos gerados a partir da liquidacao de uma parcela de pagamento

If !lEstRef
   If Empty(cTipo)
      WorkEF3->(dbSetOrder(1))
      If WorkEF3->(dbSeek(cSeq+EV_EMBARQUE))
         cTipo := "VIN"
      // ** AAF 07/11/05 - Encerramento/Transferência de Contrato.
      ElseIf WorkEF3->( dbSeek(cSeq+EV_ENC_PRC) ) .OR. WorkEF3->( dbSeek(cSeq+EV_TRANS_PRC) )
         cTipo := "ENC"
      // **
      ElseIf WorkEF3->(dbSeek(cSeq+EV_LIQ_PRC)) .or. WorkEF3->(dbSeek(cSeq+EV_LIQ_PRC_FC)) .or.;
      WorkEF3->(dbSeek(cSeq+Left(EV_LIQ_JUR,2)))  // ** GFC - 01/09/05
         cTipo := "LIQ"
      EndIf
   EndIf

   WorkEF3->(dbSetOrder(4))
   WorkEF3->(dbSeek(cSeq))
   Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_SEQ == cSeq
   If WorkEF3->EF3_CODEVE <> EV_ESTORNO  .And.  ;
      IIF(lParcPag,WorkEF3->EF3_CODEVE!=EV_PRINC_PREPAG .And. Left(WorkEF3->EF3_CODEVE,2)!=Left(EV_JUROS_PREPAG,2) /*.And. WorkEF3->EF3_EV_VIN!=EV_PRINC_PREPAG .And. Left(WorkEF3->EF3_EV_VIN,2)!=Left(EV_JUROS_PREPAG,2)*/, WorkEF3->EF3_CODEVE <> EV_PRINC) /*.T.)*/
         EX400AtuSaldos(cTipo,"M","WorkEF3","EFF")

         If lLogix .And. lGerTitEvEnc
            AF200BkPInt("WORKEF3" , "ENC_MNCT_DEL",,{'EF1',EF1->(Recno())},,)
         EndIf

         WorkEF3->(RecLock("WorkEF3",.F.))
         If !Empty(WorkEF3->EF3_NR_CON)
            aAdd(aDelWkEF3,WorkEF3->(RecNo()))
            WorkEF3->EF3_EV_EST := WorkEF3->EF3_CODEVE //WorkEF3->(DBDELETE())
            WorkEF3->EF3_DT_EST := dDataBase //AAF 24/07/05 - Grava a Data do Evento Estornado.
            WorkEF3->EF3_CODEVE := EV_ESTORNO
            WorkEF3->EF3_NR_CON := Space(Len(WorkEF3->EF3_NR_CON))
         Else
            aAdd(aDelEF3,WorkEF3->EF3_RECNO)
            WorkEF3->(dbDelete())
         EndIf
         WorkEF3->(MSUnlock())
      EndIf
      WorkEF3->(dbSkip())
   EndDo

   WorkEF3->(dbSetOrder(nOrd))

Else
   EX400AtuSaldos(cTipo,"EF1","EF3","EFF")
   If EF3->(RecLock("EF3",.F.))
      EF3->(dbDelete())
      EF3->(MSUnlock())
   EndIf
EndIf

Return .T.

*---------------------------------*
Function AcertaCpos(cOrigem)
*---------------------------------*
If cOrigem == "1" .or. cOrigem == "2" .or. cOrigem == "3"
   /*
   aAdd(aSelCpos,NIL)
   aIns(aSelCpos,2)
   aSelCpos[2] := {{|| RetDesc(If(cOrigem=="2",WorkVinc->EF3_TP_EVE,If(cOrigem=="3",WorkLiq->EF3_TP_EVE,)),If(cOrigem=="2",WorkVinc->EF3_CODEVE,If(cOrigem=="3",WorkLiq->EF3_CODEVE,)))},,AVSX3("EF3_DESCEV",5),AVSX3("EF3_DESCEV",6)}
   */
   aAdd(aSelCpos,{"EF3_EV_EST",,AVSX3("EF3_EV_EST",5),AVSX3("EF3_EV_EST",6)})
   aAdd(aSelCpos,{"EF3_DT_EST",,AVSX3("EF3_DT_EST",5),AVSX3("EF3_DT_EST",6)})//AAF 25/07/05 - Campo data do estorno.
   If lPrePag
      //Descricao do Evento de Vinculacao - LDB 14/06/2005
      aAdd(aSelCpos,NIL)
      aIns(aSelCpos,13)
      aSelCpos[13] := {{|| RetDesc(If(cOrigem=="2",WorkVinc->EF3_TP_EVE,If(cOrigem=="3",WorkLiq->EF3_TP_EVE,M->EF1_TP_FIN)),If(cOrigem=="2",WorkVinc->EF3_EV_VIN,If(cOrigem=="3",WorkLiq->EF3_EV_VIN,WorkEF3->EF3_EV_VIN)))},,AVSX3("EF3_DESCEVE",5),AVSX3("EF3_DESCEVE",6)}
      //aSelCpos[13] := {{|| Posicione("EC6",1,XFilial("EC6")+"FIEX"+M->EF1_TP_FIN+;
      //WorkEF3->EF3_EV_VIN,"EC6_DESC")},,AVSX3("EF3_DESCEVE",5),AVSX3("EF3_DESCEVE",6)}
      //-----------//
   Else
      //AAF 19/11/14 - Acerto da descrição do evento no browse.
      If (nPos:=aScan(aSelCpos,{|X| ValType(X[1]) == "C" .AND. X[1] == "EF3_DESCEVE"})) > 0
         aSelCpos[nPos][1] := {|| RetDesc() }
      EndIf
   EndIf
   // ** AAF 28/03/06 - FINIMP
   If cMod == IMP
      If (nPos:=aScan(aSelCpos,{|X| If(ValType(X[1])=="C",X[1] == "EF3_INVOIC",.F.)})) > 0
         aSelCpos[nPos][1] := {|| If(WorkEF3->EF3_ORIGEM <> "SWB",WorkEF3->EF3_INVOIC,WorkEF3->EF3_INVIMP)}
      EndIf
      If (nPos:=aScan(aSelCpos,{|X| If(ValType(X[1])=="C",X[1] == "EF3_PREEMB",.F.)})) > 0
         aSelCpos[nPos][1] := {|| If(WorkEF3->EF3_ORIGEM <> "SWB",WorkEF3->EF3_PREEMB,WorkEF3->EF3_HAWB)}
      EndIf
      If (nPos:=aScan(aSelCpos,{|X| If(ValType(X[1])=="C",X[1] == "EF3_PARC",.F.)})) > 0
         aSelCpos[nPos][1] := {|| If(WorkEF3->EF3_ORIGEM <> "SWB",WorkEF3->EF3_PARC,WorkEF3->EF3_LINHA)}

         aAdd(aSelCpos,NIL)
         aIns(aSelCpos,nPos+1)
         aSelCpos[nPos+1]  := {{|| If(WorkEF3->EF3_ORIGEM == "SWB","IMPORTAÇÃO",If(WorkEF3->EF3_ORIGEM == "EEQ","EXPORTAÇÃO",""))},,AVSX3("EF3_ORIGEM",5),AVSX3("EF3_ORIGEM",6)}
      EndIf
      If lRefinimp  // GFP - 09/10/2015
         If (nPos := aScan(aSelCpos,{|X| If(ValType(X[1])=="C", X[1] == "EF3_SEQ", .F.)})) > 0
            aAdd(aSelCpos,NIL)
            aIns(aSelCpos,nPos+1)
            aSelCpos[nPos+1] := {"EF3_CONTOR",,AVSX3("EF3_CONTOR",5),AVSX3("EF3_CONTOR",6)}
            aAdd(aSelCpos,{"EF3_TPMOOR",,AVSX3("EF3_TPMOOR",5),AVSX3("EF3_TPMOOR",6)})
            aAdd(aSelCpos,{"EF3_BAN_OR",,AVSX3("EF3_BAN_OR",5),AVSX3("EF3_BAN_OR",6)})
            aAdd(aSelCpos,{"EF3_PRACOR",,AVSX3("EF3_PRACOR",5),AVSX3("EF3_PRACOR",6)})
            aAdd(aSelCpos,{"EF3_SQCNOR",,AVSX3("EF3_SQCNOR",5),AVSX3("EF3_SQCNOR",6)})
            aAdd(aSelCpos,{"EF3_CDEVOR",,AVSX3("EF3_CDEVOR",5),AVSX3("EF3_CDEVOR",6)})
            aAdd(aSelCpos,{"EF3_PARCOR",,AVSX3("EF3_PARCOR",5),AVSX3("EF3_PARCOR",6)})
            aAdd(aSelCpos,{"EF3_IVIMOR",,AVSX3("EF3_IVIMOR",5),AVSX3("EF3_IVIMOR",6)})
            aAdd(aSelCpos,{"EF3_LINOR" ,,AVSX3("EF3_LINOR",5) ,AVSX3("EF3_LINOR" ,6)})
         EndIf
      EndIf
   EndIf
   // **
   If lMultiFil
      aAdd(aSelCpos,NIL)
      aIns(aSelCpos,1)
      aSelCpos[1] := {"EF3_FILORI",,AVSX3("EF3_FILORI",5),AVSX3("EF3_FILORI",6)}
   EndIf
EndIf

Return .T.

*-------------------------------------*
Static Function RetDesc(cTpEve,cCodEve)
*-------------------------------------*
Local xDesc
If(cTpEve=NIL,cTpEve:=If(!Empty(WorkEF3->EF3_TP_EVE),WorkEF3->EF3_TP_EVE,M->EF1_TP_FIN),)
If(cCodEve=NIL,cCodEve:=WorkEF3->EF3_CODEVE,)
// ** PLB 19/12/06 - Caso nao encontre descricao para eventos de Tipo de Juros diferentes de "0"
If !EC6->(dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. M->EF1_TPMODU <> IMP,"FIEX","FIIM")+cTpEve+cCodEve+"    ") .OR.;
          dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. M->EF1_TPMODU <> IMP,"FIEX","FIIM")+cTpEve+cCodEve+"1000") ) ;//AAF 23/07/05 - Utilizar o tipo do Evento para descrição.
   .And.  Left(cCodEve,2) $ EVENTOS_DE_JUROS  // (510,520,550,640,650,670)

   If Left(cCodEve,2) == Left(EV_VC_PJ1,2)  .And.  ( Val(cCodEve) % 2 ) != 0  // 550 .And. Impar
      cCodEve := Left(cCodEve,2)+"1"
   Else
      cCodEve := Left(cCodEve,2)+"0"
   EndIf
   EC6->(dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. M->EF1_TPMODU <> IMP,"FIEX","FIIM")+cTpEve+cCodEve+"    ") .OR.;
         dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. M->EF1_TPMODU <> IMP,"FIEX","FIIM")+cTpEve+cCodEve+"1000") )
EndIf
// **

If Select("WORKEF3") > 0 .And. !Empty(WORKEF3->EF3_DESCEV)
   xDesc := WORKEF3->EF3_DESCEV
Else
   xDesc := EC6->EC6_DESC
EndIf

Return xDesc

*-------------------------------*
Static FUNCTION EFFEX400Imprime()
*-------------------------------*
Local TB_Campos := {}
Local aRCampos := {}

/* Juliano Paulino Alves - JPA
*  30/08/2006
*  Ajustar o relatório para a versão 811 - Release 4
*/
If FindFunction("TRepInUse") .And. TRepInUse()
   Private oReport

   oReport := ReportDef()
   oReport:PrintDialog()
Else
   Private aDados := {"WorkEst",;
                      EX401STR(70),;  //"Este programa tem como objetivo imprimir relatório de acordo com os parametros informados pelo usuário."
                      EX401STR(71),;  //"Relatório de Estorno Contrato/Processo"
                      "",;
                      "G",;
                      132,;
                      "",;
                      "",;
                      EX401STR(71)+" : "+ Alltrim(WorkEst->ECE_CONTRA) + " - Data : " + DTOC(dDataBase),;  //"Relatório de Estorno Contrato/Processo
                      { EX401STR(72), 1,EX401STR(73), 1, 1, 1, "",1 },;  //"Zebrado"  ##  "Contabil"
                        "EEFEX400" ,;
                      { {|| .T. } , {|| .T. }}}

   WorkEst->(DbGotop())
   AADD(TB_Campos,{{ ||WorkEst->ECE_PREEMB }  								,, AVSX3("ECE_PREEMB"  ,05)} )
   AADD(TB_Campos,{{ ||WorkEst->ECE_INVEXP }       						,, AVSX3("ECE_INVEXP",05)} )
   AADD(TB_Campos,{{ ||WorkEst->ECE_SEQ  }   								,, AVSX3("ECE_SEQ"   ,05)} )
   AADD(TB_Campos,{{ ||WorkEst->ECE_IDENTC }   							,, AVSX3("ECE_IDENTC",05)} )
   AADD(TB_Campos,{{ ||Trans(WorkEst->ECE_ID_CAM, AVSX3("ECE_ID_CAM",06))} ,, AVSX3("ECE_ID_CAM",05)} )
   AADD(TB_Campos,{{ ||WorkEst->DESC_EVENT }                               ,, 'Descrição'           } )
   AADD(TB_Campos,{{ ||WorkEst->TIPO_EVE }   								,, AVSX3("ECE_TP_EVE",05)} )
   AADD(TB_Campos,{{ ||WorkEst->ECE_CTA_DB }   							,, AVSX3("ECE_CTA_DB",05)} )
   AADD(TB_Campos,{{ ||WorkEst->ECE_CTA_CR }   							,, AVSX3("ECE_CTA_CR",05)} )
   AADD(TB_Campos,{{ ||Trans(WorkEst->ECE_VL_MOE, AVSX3("ECE_VL_MOE",06))} ,, AVSX3("ECE_VL_MOE",05)} )
   AADD(TB_Campos,{{ ||Trans(WorkEst->ECE_TX_ATU, AVSX3("ECE_TX_ATU",06))} ,, AVSX3("ECE_TX_ATU",05)} )
   AADD(TB_Campos,{{ ||Trans(WorkEst->ECE_VALOR,  AVSX3("ECE_VALOR",06)) } ,, AVSX3("ECE_VALOR" ,05)} )

   aRCampos:= E_CriaRCampos(TB_Campos)
   E_Report(aDados,aRCampos)

EndIf

Return .T.

/*
Funcao      : ReportDef
Objetivos   : Definições do relatório personalizável
Autor       : Juliano Paulino Alves - JPA
Data 	    : 30/08/2006
Obs         :
Revisão     :
*/
****************************
Static Function ReportDef()
****************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTables := {"ECF"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo,  Pergunte, Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EFFEX400", EX401STR(71)+" : "+ Alltrim(WorkEst->ECE_CONTRA) + " - Data : " + DTOC(dDataBase),"", {|oReport| ReportPrint(oReport)}, EX401STR(70))

//ER - 20/10/2006 - Inicia o relatório como paisagem.
oReport:oPage:lLandScape := .T.
oReport:oPage:lPortRait := .F.

//Define os objetos com as seções do relatório
oSecao1 := TRSection():New(oReport,"Eventos do Contrato",aTables,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"ECE_PREEMB" , "WorkEst", AVSX3("ECE_PREEMB"  ,05)   , /*Picture*/            , AVSX3("ECE_PREEMB"  ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_INVEXP" , "WorkEst", AVSX3("ECE_INVEXP"  ,05)   , /*Picture*/            , AVSX3("ECE_INVEXP"  ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_SEQ"    , "WorkEst", AVSX3("ECE_SEQ"     ,05)   , /*Picture*/            , AVSX3("ECE_SEQ"     ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_IDENTC" , "WorkEst", AVSX3("ECE_IDENTC"  ,05)   , /*Picture*/            , AVSX3("ECE_IDENTC"  ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_ID_CAM" , "WorkEst", AVSX3("ECE_ID_CAM"  ,05)   , AVSX3("ECE_ID_CAM",06) , AVSX3("ECE_ID_CAM"  ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DESC_EVENT" , "WorkEst", "Descrição"   	          , /*Picture*/            , 25                       , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TIPO_EVE"   , "WorkEst", "Tipo Evento"              , /*Picture*/            , 04                       , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_CTA_DB" , "WorkEst", AVSX3("ECE_CTA_DB"  ,05)   , /*Picture*/            , AVSX3("ECE_CTA_DB"  ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_CTA_CR" , "WorkEst", AVSX3("ECE_CTA_CR"  ,05)   , /*Picture*/            , AVSX3("ECE_CTA_CR"  ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_VL_MOE" , "WorkEst", AVSX3("ECE_VL_MOE"  ,05)   , AVSX3("ECE_VL_MOE",06) , AVSX3("ECE_VL_MOE"  ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_TX_ATU" , "WorkEst", AVSX3("ECE_TX_ATU"  ,05)   , AVSX3("ECE_TX_ATU",06) , AVSX3("ECE_TX_ATU"  ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"ECE_VALOR"  , "WorkEst", AVSX3("ECE_VALOR"   ,05)   , AVSX3("ECE_VALOR" ,06) , AVSX3("ECE_VALOR"   ,03) , /*lPixel*/, /*{|| code-block de impressao }*/)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Eventos do Contrato")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Eventos do Contrato"),"ECF",8,{|| xFilial("ECF")+cTPMODU+EF1->EF1_CONTRA+If(lTemChave,EF1->EF1_BAN_FI+EF1->EF1_PRACA,"")})

oReport:SetMeter(WorkEst->(EasyRecCount()))
WorkEst->(dbGoTop())

//Desabilita a impressão dos perguntes.
//oReport:oParamPage:Disable()

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Eventos do Contrato"):Init()

//Laço principal
Do While WorkEst->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Eventos do Contrato"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso

   WorkEst->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Eventos do Contrato"):Finish()

Return .T.

*------------------------------------------------------------------------------*
Function EX400GeraVC(cContrato,cInvoice,cParc,cPreemb,nValor,cMoeInv,cMoeCont,;
                     cAliasEF1,cAliasEF3,cChamada,nTx,dDtEve,cSeq,cBanco,cPraca,;
                     cFilOri,cTpModu,cSeqCon,cOrigem)
*------------------------------------------------------------------------------*
Local nTaxaEve := 0, nTaxaAtu := 0, nValAux := 0, i
//Local cMesProc := AllTrim(EasyGParam("MV_MESPEXP",,StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4)))
//Local cMesProc := StrZero(Month(IIF(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB)),2)+StrZero(Year(IIF(cAliasEF1=="M",M->EF1_DT_CTB,(cAliasEF1)->EF1_DT_CTB)),4)
Local cMesProc := ""
Local dDtCont := CToD("  /  /  ")
Local dDtJur  := CToD("  /  /  ")
Local cMes, cAno, dDtMesAnt := CTOD(' / / ')
Local nRecnoEF3 := (cAliasEF3)->(Recno()), ni, aJuros:={}, lPVez:=.T.
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Local nDecTaxa := AVSX3("EF3_TX_MOE",4)
//If(cOrigem==NIL,cOrigem:="EEQ",)
IIF(Empty(cOrigem),cOrigem:="EEQ",)
Private cChamaPRW := cChamada  //Alcir Alves - 20-09-05 - define como private o cChamada para tratamento em rdmakes

// ** PLB 13/06/07
//If !Empty(cTpModu)  .And.  cTpModu == EXP
If cTpModu == NIL .OR. cTpModu <> IMP //AAF 24/10/2007 - Também é necessário verificar a contabilidade caso não haja cTpModu
   //Verifica se o Contrato está contabilizado
   If AvFlags("SIGAEFF_SIGAFIN") .OR. !EasyGParam("MV_EEC_ECO",,.F.)
      lIsContab := !Empty(EF1->EF1_DT_CTB)
   Else
      lIsContab := EX401IsCtb(cContrato,IIF(lTemChave,cBanco,""),IIF(lTemChave,cPraca,""),IIF(lEFFTpMod,cSeqCon,""))
   EndIf
Else
   lIsContab := .F.
EndIf

If cAliasEF1 == "M"
   dDtCont := M->EF1_DT_CTB
   dDtJur  := M->EF1_DT_JUR
Else
   dDtCont := (cAliasEF1)->EF1_DT_CTB
   dDtJur  := (cAliasEF1)->EF1_DT_JUR
EndIf
If Empty(dDtCont)  .Or.  !lIsContab
   cMesProc := StrZero(Month(dDtJur),2)+StrZero(Year(dDtJur),4)
Else
   cMesProc := StrZero(Month(dDtCont),2)+StrZero(Year(dDtCont),4)
EndIf
// **

nValor := Round(nValor,nDecValor)
//cSeq := "0001"
cSeq  := BuscaEF3Seq(cAliasEF3,cContrato,cBanco,cPraca,cTpModu,cSeqCon)
lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0

// Mes Anterior da Data do Evento
cMes  := StrZero(Month(dDtEve),2)
cAno  := Right(Str(Year(dDtEve)),2)
dDtEveAnt := AVCTOD("01/"+cMes+"/"+cAno) - 1
// ** PLB 10/08/06 - Verifica se e menor que a data do contrato
If dDtEveAnt < IIF(cAliasEF1=="M",M->EF1_DT_CON,(cAliasEF1)->EF1_DT_CON)
   dDtEveAnt := IIF(cAliasEF1=="M",M->EF1_DT_CON,(cAliasEF1)->EF1_DT_CON)
EndIf
// **

// Mes Anterior ao Atual
cMes  := StrZero(Val(Left(cMesProc,2))+1,2)
cAno  := Right(cMesProc,2)
dDtMesAnt := AVCTOD("01/"+cMes+"/"+cAno) - 1

nTaxaEve  := Round(BuscaTaxa(cMoeInv,dDtEveAnt,,.F.,.T.,,cTX_100),nDecTaxa)       // Taxa do Evento
nTaxaEveJuros := Round(BuscaTaxa(cMoeInv,dDtEveAnt,,.F.,.T.,,cTX_520),nDecTaxa)   // Taxa do Evento
nTaxaAtu  := Round(BuscaTaxa(cMoeInv,dDtMesAnt,,.F.,.T.,,cTX_100),nDecTaxa)       // Taxa do Mes Anterior ao Atual do parâmetro MV_MESPEXP
nTaxaAtuJuros := Round(BuscaTaxa(cMoeInv,dDtMesAnt,,.F.,.T.,,cTX_520),nDecTaxa)   // Taxa do Mes Anterior ao Atual do parâmetro MV_MESPEXP

dDt := (cAliasEF3)->EF3_DT_EVE

If lEF2_TIPJUR
   aJuros := EX400BusJur(If(cChamada=="CAMB","EF2","WorkEF2"),cAliasEF1)
Else
   aJuros := {"0"}
EndIf

For ni:=1 to len(aJuros)

   If ni > 1
      lPVez := .F.
   EndIf

   aTx_Dia := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),dDtMesAnt,dDtEveAnt-IIF(dDtEveAnt==IIF(cAliasEF1=="M",M->EF1_DT_CON,(cAliasEF1)->EF1_DT_CON),1,0),If(cChamada=="CAMB","EF1","M"),If(cChamada=="CAMB","EF2","WorkEF2"),aJuros[ni],,cFilOri,cInvoice,cParc)
   For i:=1 to Len(aTx_Dia)
      nValAux += Round(aTx_Dia[i,2] * (aTx_Dia[i,1] / 100) * nValor,nDecValor)
   Next i

   If nValAux > 0
      //Grava Evento 520 - Provisão de Juros
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")

      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
      EndIf

      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf
      (cAliasEF3)->EF3_CODEVE := Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
      (cAliasEF3)->EF3_CONTRA := cContrato

      //ACSJ - 06/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif

      If cOrigem == "EEQ"
         (cAliasEF3)->EF3_INVOIC := cInvoice
         (cAliasEF3)->EF3_PREEMB := cPreemb
         (cAliasEF3)->EF3_PARC   := cParc
      Else
         (cAliasEF3)->EF3_INVIMP := cInvoice
         (cAliasEF3)->EF3_HAWB   := cPreemb
         (cAliasEF3)->EF3_LINHA  := cParc
         //(cAliasEF3)->EF3_FORN   := cForn
         //(cAliasEF3)->EF3_LOJAFO := cLoja
         //(cAliasEF3)->EF3_PO_DI  := cPoDi
      EndIf

      (cAliasEF3)->EF3_VL_MOE := nValAux
      //(cAliasEF3)->EF3_VL_REA := nValAux * nTaxaAtu
      (cAliasEF3)->EF3_VL_REA := Round(nValAux * nTaxaAtuJuros,nDecValor)
      //(cAliasEF3)->EF3_TX_MOE := nTaxaAtu
      (cAliasEF3)->EF3_TX_MOE := nTaxaAtuJuros
      (cAliasEF3)->EF3_DT_EVE := dDataBase
      (cAliasEF3)->EF3_SEQ    := cSeq
      (cAliasEF3)->EF3_MOE_IN := cMoeInv
      If cAliasEF1 == "M"
         M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
         M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
         (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
      Else
         (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
         (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
         //MFR 05/10/2021 OSSME-6276
         //If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
         //   (cAliasEF3)->EF3_TP_EVE := "01"
         //Else
            (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
         //EndIf
      EndIf

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf

      (cAliasEF3)->(msUnlock())

      If EasyEntryPoint("EFFEX400") //Alcir Alves - 19-09-05
         ExecBlock("EFFEX400",.F.,.F.,"APOS_GRV_520")
      Endif

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf
   EndIf

   nVcPr := Round(nValAux * nTaxaAtuJuros,nDecValor) - Round(nValAux * nTaxaEveJuros,nDecValor)

   If nVcPr <> 0
      //Grava Evento 550 - Variação Cambial sobre Provisão de Juros
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")

      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
      EndIf

      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf
      //(cAliasEF3)->EF3_CODEVE := EV_VC_PJ
      //(cAliasEF3)->EF3_CODEVE := IF(((nValAux * nTaxaAtu) - (nValAux * nTaxaEve))>0,'550','551')	//Alexandre
      (cAliasEF3)->EF3_CODEVE := IF(nVcPr>0,Alltrim(Str(550+(Val(aJuros[ni])*2))),Alltrim(Str(551+(Val(aJuros[ni])*2))))	//Alexandre
      (cAliasEF3)->EF3_CONTRA := cContrato

      //ACSJ - 06/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif

      If cOrigem == "EEQ"
         (cAliasEF3)->EF3_INVOIC := cInvoice
         (cAliasEF3)->EF3_PREEMB := cPreemb
         (cAliasEF3)->EF3_PARC   := cParc
      Else
         (cAliasEF3)->EF3_INVIMP := cInvoice
         (cAliasEF3)->EF3_HAWB   := cPreemb
         (cAliasEF3)->EF3_LINHA  := cParc
      EndIf

      //(cAliasEF3)->EF3_VL_REA := (nValAux * nTaxaAtu) - (nValAux * nTaxaEve)
      (cAliasEF3)->EF3_VL_REA := nVcPr
      (cAliasEF3)->EF3_TX_MOE := nTaxaAtu
      (cAliasEF3)->EF3_DT_EVE := dDataBase
      (cAliasEF3)->EF3_SEQ    := cSeq
      (cAliasEF3)->EF3_MOE_IN := cMoeInv
      If (Round(nValAux * nTaxaAtuJuros,nDecValor) - Round(nValAux * nTaxaEveJuros,nDecValor)) > 0 //(cAliasEF3)->EF3_CODEVE = '550'
         If cAliasEF1 == "M"
            M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
            (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
         Else
            (cAliasEF1)->(RecLock(cAliasEF1,.F.))
            (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
            //MFR 05/10/2021 OSSME-6276
            //If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
            //   (cAliasEF3)->EF3_TP_EVE := "01"
            //Else
               (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
            //EndIf
         EndIf
      Else //551
         If cAliasEF1 == "M"
            M->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
            (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
         Else
            (cAliasEF1)->(RecLock(cAliasEF1,.F.))
            (cAliasEF1)->EF1_SLD_JR -= (cAliasEF3)->EF3_VL_REA
            //MFR 05/10/2021 OSSME-6276
            //If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
            //   (cAliasEF3)->EF3_TP_EVE := "01"
            //Else
               (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
            //EndIf
         EndIf
      EndIf

      //FSM - 10/04/2012
      If Upper(cAliasEF3) == "WORKEF3"
         (cAliasEF3)->EF3_DESCEV := EX400DescEv(cAliasEF1, cAliasEF3, (cAliasEF3)->EF3_CODEVE)
      EndIf

      (cAliasEF3)->(msUnlock())

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf
   EndIf

   nVCPr := Round(nValor * nTaxaAtu,nDecValor) - Round(nValor * nTaxaEve,nDecValor)

   If lPVez .AND. nVCPr <> 0
      //Grava Evento 500 - Variação Cambial do Principal
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")

      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
      EndIf

      If ValType(cFilORI) == "C"
         (cAliasEF3)->EF3_FILORI := cFilORI
      EndIf
      (cAliasEF3)->EF3_CODEVE := EV_VC_PRC
      (cAliasEF3)->EF3_CONTRA := cContrato

      //ACSJ - 06/02/2005
      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_AGENFI)
         (cAliasEF3)->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_AGENFI,(cAliasEF1)->EF1_NCONFI)
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif

      If cOrigem == "EEQ"
         (cAliasEF3)->EF3_INVOIC := cInvoice
         (cAliasEF3)->EF3_PREEMB := cPreemb
         (cAliasEF3)->EF3_PARC   := cParc
      Else
         (cAliasEF3)->EF3_INVIMP := cInvoice
         (cAliasEF3)->EF3_HAWB   := cPreemb
         (cAliasEF3)->EF3_LINHA  := cParc
      EndIf

      (cAliasEF3)->EF3_VL_REA := nVCPr
      (cAliasEF3)->EF3_TX_MOE := nTaxaAtu
      (cAliasEF3)->EF3_TX_CON := (cAliasEF3)->EF3_VL_REA / (cAliasEF3)->EF3_VL_INV
      (cAliasEF3)->EF3_DT_EVE := dDataBase
      (cAliasEF3)->EF3_DT_CIN := dDataBase
      (cAliasEF3)->EF3_SEQ    := cSeq
      (cAliasEF3)->EF3_MOE_IN := cMoeInv

      If (cAliasEF3)->EF3_VL_REA <= 0
         (cAliasEF3)->EF3_CODEVE := EV_VC_PRC1
      EndIf

      If cAliasEF1 == "M"
         M->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
         (cAliasEF3)->EF3_TP_EVE := M->EF1_TP_FIN
      Else
         (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         (cAliasEF1)->EF1_SLD_PR += (cAliasEF3)->EF3_VL_REA
         //MFR 05/10/2021 OSSME-6276
         //If cMod == EXP .AND. !(lPrePag .and. If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")) //GFC - Pré-Pagamento/Securitização
         //   (cAliasEF3)->EF3_TP_EVE := "01"
         //Else
            (cAliasEF3)->EF3_TP_EVE := (cAliasEF1)->EF1_TP_FIN
         //Endif
      EndIf
      (cAliasEF3)->(msUnlock())

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf
   EndIf

Next ni

(cAliasEF3)->(DbGoto(nRecnoEF3))

Return .T.

*-------------------------------*
Function EX400ChkItem(cPreemb)
*-------------------------------*
Local aOrdEEc := EEC->(getArea())

EEC->(DbSetOrder(1))
EEC->(dbSeek(xFilial("EEC")+cPreemb))
If Empty(EEC->EEC_DUEAVR )
   Help(" ",1,"AVG0005290",,Alltrim(cPreemb)+" "+STR0084,1,12) //MsgInfo(STR0083 + " " + Alltrim(cPreemb) + " " + STR0084 ) // Processo : ### "não possui data de averbação"
Endif

restArea(aOrdEEC)
Return .T.

*-------------------------------------*
Static Function VerifEmb(lMens,cCampo)
*-------------------------------------*
Local lRet := .F., nRecAtu := WorkEF3->(Recno()), nIndexOrd := WorkEF3->(IndexOrd())

If !lIncluiAux .and. WorkEF3->EF3_CODEVE = EV_PRINC
   WorkEF3->(DbSetOrder(5))
   //If WorkEF3->(DbSeek(M->EF1_CONTRA+If(lTemChave,M->EF1_BAN_FI+M->EF1_PRACA,"")+EV_EMBARQUE))
   If WorkEF3->( dbSeek(EV_EMBARQUE) )//AAF - Alteração do Indice para conter apenas o campo evento.
      If cMod == EXP .Or. EF1->(FieldPos("EF1_TX_MOE")) > 0 //MCF - 13/01/2016
         lRet := .T.
         If lMens
            MsgInfo(AVSX3(cCampo,5) + STR0091 ) //" não pode ser alterada, Contrato já Possui Vinculações !!!")
         Endif
      Endif
   ElseIf lPrePag .AND. M->EF1_CAMTRA == "1" .and.; //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
   WorkEF3->( dbSeek(EV_LIQ_PRC) )//WorkEF3->(DbSeek(M->EF1_CONTRA+If(lTemChave,M->EF1_BAN_FI+M->EF1_PRACA,"")+EV_LIQ_PRC))
      lRet := .F.
      If lMens
         MsgInfo(AVSX3(cCampo,5) + STR0232 ) //" não pode ser alterada(o). Contrato já possui liquidações !!!"
      EndIf
   Endif
Endif

WorkEF3->(DbSetOrder(nIndexOrd))
WorkEF3->(DbGoto(nRecAtu))

Return lRet

/*-------------------------------------------*
Static Function CalComis(cProcesso,cInvoice)
*-------------------------------------------*
Local nRecAtu := WorkInv->(Recno()), nIndexOrd := WorkInv->(IndexOrd())
Local nVlrComis := 0, nVlrVinc := 0, nTotInv := 0, aInvoice := {}, x
Local nValCom := WorkInv->VALCOM, cTIPCVL := WorkInv->TIPCVL, cTipCom := WorkInv->TIPCOM

WorkInv->(DbSetOrder(2))
WorkInv->(DbSeek(cProcesso+cInvoice))
Do While WorkInv->(!Eof()) .And. (cProcesso+cInvoice) == (WorkInv->EF3_PREEMB+WorkInv->EF3_INVOIC)

   nTotInv += WorkInv->EF3_VL_INV
   AAdd(aInvoice, {WorkInv->EF3_VL_INV, WorkInv->(Recno())} )

   WorkInv->(DbSkip())
Enddo

If cTipCom = '2'   // Conta Gráfica
   If cTIPCVL $ "1/3"           // Tipo Percentual
      nVlrComis := (nTotInv * (nValCom/100))
   Else                         // Tipo Valor Fixo
      nVlrComis := nValCom
   Endif
Endif

// Calcula a Comissão para aInvoices apartir da ultima parcela
For x:=Len(aInvoice) to 1 Step -1
   AAdd(aInvoice, {WorkInv->EF3_VL_INV, WorkInv->(Recno())} )
   nVlrVinc := aInvoice[x,1] - nVlrComis
   If nVlrVinc <= 0
      nVlrComis := nVlrVinc * -1
      nVlrAuxCom:= nVlrComis
      nVlrVinc  := 0
   Else
      nVlrAuxCom:= nVlrComis
      nVlrComis := 0
   Endif
   WorkInv->(DbGoto(aInvoice[x,2]))
   WorkInv->(RecLock("WorkInv",.F.))
   WorkInv->VALCOM := nVlrAuxCom
//   WorkInv->VL_VINC:= nVlrVinc
   WorkInv->(MsUnlock())
   nVlrAuxCom := nVlrComis
Next

WorkInv->(DbSetOrder(nIndexOrd))
WorkInv->(DbGoto(nRecAtu))

Return .T.*/

*----------------------------*

Static Function EX400AtuDic(o)
*----------------------------*
//FSM - 22/03/2012
Local aSx5Jur := {}, aEventos := {}
local i := 0, j := 0

   aEventos := MontaCarga(.F.)

   If SX5->(dbSeek(xFilial("SX5")+"CV"))
      Do While SX5->(!EOF()) .And. SX5->X5_TABELA == "CV"
         aAdd( aSx5Jur , { AllTrim(SX5->X5_CHAVE), AllTrim(SX5->X5_DESCRI) })
         SX5->(DBSkip())
      EndDo
   EndIf

   o:TableStruct( "EC6", { "EC6_FILIAL"           , "EC6_TPMODU"       , "EC6_ID_CAM"                                 , "EC6_DESC"                               ,"EC6_IDENTC"    , "EC6_CTA_DB" , "EC6_CTA_CR" , "EC6_COD_HI", "EC6_NO_CAM" , "EC6_COM_HI" , "EC6_FINANC"   , "EC6_CDBEST" , "EC6_CCREST" , "EC6_EVE_AS" , "EC6_CA_EVE"  , "EC6_CONTAB"  , "EC6_DIAMES"  , "EC6_RATEIO"  , "EC6_TXCV"   , "EC6_RECDES"  , "EC6_NATURE" , "EC6_NATFIN" , "EC6_TPTIT", "EC6_MOTBX"},1)

   For i := 1 To Len(aEventos)

       //Eventos que não são de juros
       If !aEventos[i][11]
               o:TableData("EC6"  ,{xFilial("EC6"), aEventos[i,1]      , aEventos[i,2]                                , aEventos[i][3]                           ,""               ,              ,              ,             ,              ,              ,aEventos[i,4]   ,              ,              ,              ,aEventos[i,5]  ,aEventos[i,6]  ,aEventos[i,7]  ,aEventos[i,8]  ,aEventos[i,9] ,aEventos[i,10] ,              ,              ,            ,            },,.F.)
       Else
          //Eventos de base em juros
          For j := 1 To Len(aSx5Jur)
                o:TableData("EC6"  ,{xFilial("EC6"), aEventos[i,1]      , Left(aEventos[i,2],2)+aSx5Jur[j,1]          , StrTran(aEventos[i][3],"#",aSx5Jur[j,2]) ,""               ,              ,              ,             ,              ,              ,aEventos[i,4]   ,              ,              ,              ,aEventos[i,5]  ,aEventos[i,6]  ,aEventos[i,7]  ,aEventos[i,8]  ,aEventos[i,9] ,aEventos[i,10] ,              ,              ,            ,            },,.F.)
          Next j

       EndIf
   Next i

   //Eventos Especiais ( Positivos e Negativos )
   aEventos := MontaCarga(.T.)

   For i := 1 To Len(aEventos)

        For j := 1 To Len(aSx5Jur)

            //Positivo
            cEvento := PadL( AllTrim(Str(   ( Val(aEventos[i,2]) + Val(AllTrim(aSx5Jur[j,1])) * 2 )  )) ,3 ,"0")
            o:TableData("EC6"  ,{xFilial("EC6"), aEventos[i,1]      , cEvento          , StrTran(aEventos[i][3],"#","+ "+aSx5Jur[j,2]) ,""               ,              ,              ,             ,              ,              ,aEventos[i,4]   ,              ,              ,              ,aEventos[i,5]  ,aEventos[i,6]  ,aEventos[i,7]  ,aEventos[i,8]  ,aEventos[i,9] ,aEventos[i,10] ,              ,              ,            ,            },,.F.)

            //Negativo
            cEvento := PadL(AllTrim(Str(Val(cEvento)+1)) ,3 ,"0")
            o:TableData("EC6"  ,{xFilial("EC6"), aEventos[i,1]      , cEvento          , StrTran(aEventos[i][3],"#","- "+aSx5Jur[j,2]) ,""               ,              ,              ,             ,              ,              ,aEventos[i,4]   ,              ,              ,              ,aEventos[i,5]  ,aEventos[i,6]  ,aEventos[i,7]  ,aEventos[i,8]  ,aEventos[i,9] ,aEventos[i,10] ,              ,              ,            ,            },,.F.)

        Next j

   Next i

Return Nil

/*
Funcao      : EFFEX400()
Parametros  :
Retorno     : nTipo
Objetivos   : Executar setafiltro
Autor       : Thomson Reuters
Data/Hora   : 25/09/2020
Obs.        :
*/
*------------------
Function Ex400SetaF(nTipo)
*------------------
Return SetaFiltro(nTipo)

*---------------------------------------------------------------------------------------------*
Static Function SetaFiltro(nTipo)
*---------------------------------------------------------------------------------------------*

If nTipo = 1
   cFilAux := WorkEF3->(dbFilter())
   nOrdFil := WorkEF3->(IndexOrd()) //LRS - 19/02/2018
   SET FILTER TO
Else
   dbSelectArea("WorkEF3")
   WorkEF3->(DBSETORDER(nOrdFil))
   SET FILTER TO &cFilAux
   WorkEF3->(dbGoTop())
   oMark:oBrowse:Refresh()
Endif

Return .T.

*-----------------------------------------------------------------------------------------------*
Static Function EX4PesqInv()
*-----------------------------------------------------------------------------------------------*
Local nOpca:=0, lSeek, cF3:= "SB1", bOk := {||nOpca:=1,cGetFilOri:=Left(cGetFilOri,2),oDlgPesq:End()}, oDlgPesq
Local bCancel := {||nOpca:=0,oDlgPesq:End()}, cInv:=Space(Len(EF3->EF3_INVOIC))
Local cGetFilOri:=Space(Len(EF3->EF3_FILIAL))
Local oCbxFil,i, nx
Local aFil :=AvgSelecTFil(.F.)

For i:= 1 to len(aFil)
   aFil[i] := aFil[i] + " - " + AvgFilName({aFil[i]})[1]
Next
// ** GFC - 28/07/05 - Opção de pesquisar em todas as filiais
If lMultiFil
   aAdd(aFil,NIL)
   aIns(aFil,1)
   aFil[1] := "TODAS"
EndIf
// **

While .T.

   nOpca:= 0
   cInv:=Space(Len(EF3->EF3_INVOIC))
   cGetFilOri:=Space(Len(EF3->EF3_FILIAL))

   cFilAtual := cFilAnt

   DEFINE MSDIALOG oDlgPesq TITLE STR0102; //"Pesquisar Invoice"
       FROM 00,05 TO 19,50 OF GetWndDefault()

       @ 00,00 MsPanel oPanel Prompt "" Size 1,1 of oDlgPesq

   @01.5,02 SAY   AVSX3("EF3_FILIAL",5) of oPanel
   //@01.5,08 MSGET cGetFilOri PICT AVSX3("EF3_FILIAL",6) SIZE 60,8 When lMultifil
   @01.5,08 ComboBox oCbxFil Var cGetFilOri Items aFil On Change If(Left(cGetFilOri, 2) <> "TO", cFilAnt := Left(cGetFilOri,AVSX3("EF3_FILIAL",AV_TAMANHO)),cFilAnt := cFilAtual) SIZE 60,08 of oPanel When lMultifil
   @02.5,02 SAY   AVSX3("EF3_INVOIC",5) of oPanel
   @02.5,08 MSGET cInv F3 "E18" PICT AVSX3("EF3_INVOIC",6) Of oPanel SIZE 60,8
   oPanel:Align:=CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlgPesq ON INIT EnchoiceBar(oDlgPesq,{||nOpca:=1, Eval(bOk)},{||nOpca:=0,oDlgPesq:End()}) CENTERED
   cFilAnt := cFilAtual
   If nOpca==1 .And. !Empty(cInv)
      WorkInv->(dbSetOrder(3))
      If lMultiFil .and. cGetFilOri == "TO"
         For nx:=2 to Len(aFil)
            If (lSeek:= WorkInv->(dbSeek(Left(aFil[nx],AVSX3("EF3_FILIAL",AV_TAMANHO))+Alltrim(cInv),.T.)))
               Exit
            EndIf
         Next nx
      Else
         //RMD - 07/05/08 - Se não for multifilial deve ser utilizado o xFilial(), já que a work recebe a filial sempre
         //lSeek:= WorkInv->(dbSeek(If(lMultifil,cGetFilOri,Space(Len(cGetFilOri)))+cInv,.T.))  //SoftSeek
         lSeek:= WorkInv->(dbSeek(If(lMultifil,cGetFilOri,xFilial("EF1"))+cInv,.T.))  //SoftSeek
      EndIf
      If !lSeek
         MsgInfo(STR0103) //"A Pesquisa não encontrou registros com essas Infornmações."
         oMark:oBrowse:Refresh()
      Else
         oMark:oBrowse:Refresh()
      EndIf
   Else
      Exit
   EndIf

   Exit
EndDo

Return .T.

*---------------------------------------------------------------------------------------------*
Function EX4BrowEF3()
*---------------------------------------------------------------------------------------------*
LOCAL oDlgBrow, Tb_Campos:={}, lRetHlp:=.F.
LOCAL cVarProd:=Readvar(), nIndexAtu:=WorkEF3->(IndexOrd())
LOCAL bActionHlp:= {||lRetHlp:=.T., cInvBrow:=IIF(cMod==IMP,WorkEF3->EF3_INVIMP,WorkEF3->EF3_INVOIC), cInvParc:=IIF(cMod==IMP,WorkEF3->EF3_LINHA,WorkEF3->EF3_PARC), oDlgBrow:End()}
LOCAL oCbxPesq, cTpPesq   := "C", aTpPesq:={STR0100}, cPesq := Space(30) //"Invoice:"
PRIVATE oMarkHlp

/*IF !(cVarProd $ "CPRODAP/M->ED1_PROD/CCODIGO/MV_PAR01/MV_PAR02/M->J5_COD_I/CITEMAP")
   RETURN .F.
ENDIF*/

dbSelectArea("WorkEF3")

If cMod == IMP  // PLB 25/10/06
   AADD(Tb_Campos,{"EF3_INVIMP",,avSX3("EF3_INVIMP",5)})
   AADD(Tb_Campos,{"EF3_HAWB"  ,,avSX3("EF3_HAWB"  ,5)})
   AADD(Tb_Campos,{"EF3_LINHA" ,,avSX3("EF3_LINHA" ,5)})
Else
   AADD(Tb_Campos,{"EF3_INVOICE",,avSX3("EF3_INVOICE",5)})
   AADD(Tb_Campos,{"EF3_PREEMB" ,,avSX3("EF3_PREEMB" ,5)})
   AADD(Tb_Campos,{"EF3_PARC"   ,,avSX3("EF3_PARC"   ,5)})
EndIf

WorkEF3->(dbSetOrder(3))
WorkEF3->(DBSETFILTER({||!Empty(IIF(cMod==IMP,EF3_INVIMP,EF3_INVOIC)) .and. EF3_CODEVE="600"},"!Empty("+IIF(cMod==IMP,"EF3_INVIMP","EF3_INVOIC")+") .and. EF3_CODEVE='600'"))
WorkEF3->(dbGoTop())

DEFINE MSDIALOG oDlgBrow TITLE STR0073 FROM 4,3 TO 23,65 OF oMainWnd //"Pesquisa de Produtos"

   oMarkHlp        := MsSelect():New("WorkEF3",,,TB_Campos,@lInverte,@cMarca,{10,6,100,200})
   oMarkHlp:baval  := bActionHlp

   @105,010 SAY STR0106 PIXEL of oDlgBrow //"Pesquisa por:"
   @105,045 ComboBox oCbxPesq Var cTpPesq Items aTpPesq SIZE 150,08 of oDlgBrow PIXEL When .F.

   @120,010 SAY STR0107 PIXEL of oDlgBrow //"Localizar:"
   @120,045 MSGET cPesq PICT "@!" VALID EX4PesqOrd(cPesq) SIZE 150,8 of oDlgBrow PIXEL

   DEFINE SBUTTON FROM 10,210 TYPE 1 ACTION (EVAL(bActionHlp)) ENABLE OF oDlgBrow PIXEL
   DEFINE SBUTTON FROM 25,210 TYPE 2 ACTION (lRet:=.F.,oDlgBrow:End()) ENABLE OF oDlgBrow PIXEL

ACTIVATE MSDIALOG oDlgBrow CENTERED

/*IF cVarProd $ "M->ED1_PROD"
   If !Empty(M->ED1_PROD) .And. lRetHlp
      AC400VALID("ED1_PROD")
   Endif
Endif*/

// Volta a Ordem anterior
WorkEF3->(DbSetOrder(nIndexAtu))

SET FILTER TO

RETURN lRetHlp

Return .T.

*---------------------------------------------------------------------------------------------*
Function EX4PesqOrd(cConteudo)
*---------------------------------------------------------------------------------------------*
Local nRecAtu := WorkEF3->(Recno())

If !WorkEF3->(DbSeek(Alltrim(cConteudo),.T.))  // Caso nao encontre posiciona no registro anterior.
   If WorkEF3->(Eof())
      WorkEF3->(DbGoto(nRecAtu))
   Endif
Endif

oMarkHlp:oBrowse:Refresh()

RETURN .T.

//-----------------------------------------------------------------------------------------------
// A. Caetano Sciancalepre Jr. - 07/01/2004
// Filtros para facilitar vinculações de invoices a contratos.
Function EX400FltIv()   // EX400FiltraInvoices
// ----------------------------------------------------------------------------------------------
Local lRet
//Local bBarOk := {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)}
//Local bBarCancel := {||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0008+Chr(13)+Chr(10)+STR0009),Eval(bCancel),),Eval(bCancel))} //"Deseja Realmente Sair?"###"Todas as alterações serão perdidas."
Local oCmbFil, oComboTip, aTipo:={STR0230,STR0231} // "1-Principal" # "2-Juros"
Local i, oComboTpCo
Private cTipoVinc:="1"
Private cTpCon := "1"   // GFC - 26/01/06
Private cFil :="", nLin:=002, nLinButton:=120, nColButton:=175, cGetAux:="", oDlgFilt, cGetAux2:=""
// FSM - 17/08/2012
//Private aFil := If(lMulTiFil,AvgSelectFil(.T.,,"EF3"),{xFilial("EEQ")})
Private aFil := If(lMulTiFil,AvgSelectFil(.T.),{xFilial("EEQ")})
//FIM ** FSM - 17/08/2012
Private aCps := {}

If aFil[1]=="WND_CLOSE"
   Return .F.
EndIf

For i:= 1 to len(aFil)
   If !aFil[i] $ EasyGParam("MV_AVG0024",,"")
      cFil+="'"+aFil[i]+"'"
      If i < len(aFil)
         cFil+=","
      EndIf
   EndIf
Next i

dVencIni   := dVencFim  := CtoD(Space(8))   // ACSJ - 07/01/2004
cInvoice   := Space(Len(EEC->EEC_NRINVO))
cProcesso  := Space(Len(EEC->EEC_PREEMB))   // ACSJ - 07/01/2004
nValIni    := nValFim   := 0				// ACSJ - 07/01/2004
cImport    := Space(Len(EEC->EEC_IMPORT)) 	// ACSJ - 07/01/2004
cLoja      := Space(Len(EEC->EEC_IMLOJA))
cCondPagto := Space(Len(EEC->EEC_CONDPA))  	// ACSJ - 07/01/2004
nDias      := 0                             // ACSJ - 07/01/2004
cPais      := Space(Len(SA1->A1_PAIS))
cTpCon     := "1"   // GFC - 26/01/06
lRet       := .f.

// ** AAF 11/03/06 - Filtros por Fornecedor e Moeda em Financiamentos de Importação.
If cMod == IMP
   cFornec   := CriaVar("A2_COD",.F.)   //TRP - 11/10/2011 - Preenchimento do segundo parâmetro da Função Criavar como .F. para não executar o Ini. Padrão do campo.
   cMoeda    := CriaVar("YF_MOEDA")
EndIf
// **

/*
If oMainWnd:nRight > 804

	DEFINE MSDIALOG oDlgFilt TITLE STR0119;   // "Filtro das invoices"
    	   FROM oMainWnd:nTop+125,oMainWnd:nLeft+55 TO oMainWnd:nBottom-240,oMainWnd:nRight - 500 ;
       	   OF oMainWnd PIXEL
Else
	DEFINE MSDIALOG oDlgFilt TITLE STR0119;   // "Filtro das invoices"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+55 TO oMainWnd:nBottom-100,oMainWnd:nRight-270 ;
          OF oMainWnd PIXEL
Endif
*/
Define MsDialog oDlgFilt Title STR0119 From 10,10 TO 300,600 ;  // "Filtro das invoices"
       Of oMainWnd Pixel
/*   If VerSenha(115)
      @ 012, 16 Say "Filial"    of oDlgFilt Pixel
      @ 011, 64 ComboBox oCmbFil Var cFil Items aFil  Of oDlgFilt Pixel Size 60,8
   EndIF                                                                        */

   If cMod == EXP
      aTpCon:={STR0257,STR0258} //"1-Cambio de Exportacao" # "3-Recebimento tipo 3"

      @nLin,002 SAY   STR0120                of oDlgFilt   // "Vencimento Inicial"
      @nLin,010 MSGET dVencIni                                           SIZE 60,8 Of oDlgFilt HASBUTTON
      @nLin,019 Say   STR0121                of oDlgFilt   // "Final"
      @nLin,027 MSGET dVencFim                                           SIZE 60,8 Of oDlgFilt HASBUTTON
      nLin += 001
      @nLin,002 Say   STR0122                of oDlgFilt   // "Invoice"
      @nLin,010 MSGET cInvoice   Pict AVSX3("EEC_NRINVO",6)              SIZE 60,8 Of oDlgFilt F3 "EEQ_MF" HASBUTTON
      @nLin,019 Say   STR0123                of oDlgFilt   // "Processo"
      @nLin,027 MSGET cProcesso  Pict AVSX3("EEC_PREEMB",6)              SIZE 60,8 Of oDlgFilt F3 AVSX3("EF3_PREEMB",8) HASBUTTON
      nLin += 001
      @nLin,002 Say   STR0124                of oDlgFilt   // "Valor Entre"
      @nLin,010 MSGET nValIni    Pict AVSX3("EEQ_VL",6)                  SIZE 60,8 Of oDlgFilt HASBUTTON
      @nLin,019 Say   STR0125                of oDlgFilt   // "e"
      @nLin,027 MSGET nValFim    Pict AVSX3("EEQ_VL",6)                  SIZE 60,8 Of oDlgFilt HASBUTTON
      nLin += 001
      @nLin,002 Say   STR0126                of oDlgFilt     // "Cliente"
      @nLin,010 MSGET cImport    Pict AVSX3("EEC_IMPORT",6) F3 "SA1" Valid (Empty(cImport) .or. ExistCpo("SA1",cImport)) SIZE 60,8 Of oDlgFilt HASBUTTON
      @nLin,019 Say   Left(AVSX3("EEC_IMLOJA",5),4)  of oDlgFilt     // "Loja"
      @nLin,027 MSGET cLoja      Pict AVSX3("EEC_IMLOJA",6) Valid (Empty(cLoja) .or. ExistCpo("SA1",cImport+cLoja)) SIZE 60,8 Of oDlgFilt
      nLin += 001
      @nLin,002 Say   STR0169                of oDlgFilt     // "País"
      @nLin,010 MSGET cPais      Pict AVSX3("EEC_PAIS",6) F3 "SYA" Valid (Empty(cPais) .or. ExistCpo("SYA",cPais)) SIZE 60,8 Of oDlgFilt HASBUTTON
      @nLin,019 Say   STR0127                of oDlgFilt     // "Condição de Pagto"
      @nLin,027 MSGET cCondPagto Pict AVSX3("EEC_CONDPA",6)   F3 "SY6" Valid (Empty(cCondPagto) .or. ExistCpo("SY6",cCondPagto)) SIZE 60,8 Of oDlgFilt HASBUTTON
      nLin += 001

      @nLin,002 Say   STR0128                of oDlgFilt     // "Dias"
      @nLin,010 MSGET nDias      Pict AVSX3("EEC_DIASPA",6)              SIZE 60,8 Of oDlgFilt

      // ** GFC - 26/01/06
      If lEEQ_TP_CON
         @nLin,019 Say   AVSX3("EEQ_TP_CON",5)  of oDlgFilt     // "Tipo Contra."
         @nLin,027 ComboBox oComboTpCo Var cTpCon Items aTpCon SIZE 78,08 of oDlgFilt
      EndIf
      // **

      nLin += 001

      // ** GFC - Pré-Pagamento/Securitização
      If lPrePag .AND. M->EF1_CAMTRA == "1" //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
         @nLin,002 Say   STR0229             of oDlgFilt     // "Vincular à"
         @nLin,010 ComboBox oComboTip Var cTipoVinc Items aTipo SIZE 60,08 of oDlgFilt
      EndIf
      // **

   ElseIf cMod == IMP
      aTpCon:={EX401STR(74),EX401STR(75)}  //"2 - Cambio de Importação" ## "4 - Remessa p/ Exterior"

      @nLin,002 SAY   STR0120                of oDlgFilt     // "Vencimento Inicial"
      @nLin,010 MSGET dVencIni                                           SIZE 60,8 Of oDlgFilt HASBUTTON
      @nLin,019 Say   STR0121                of oDlgFilt     // "Final"
      @nLin,027 MSGET dVencFim                                           SIZE 60,8 Of oDlgFilt HASBUTTON
      nLin += 001

      @nLin,002 Say   STR0123                of oDlgFilt     // "Processo"
      @nLin,010 MSGET cProcesso  Pict AVSX3("WB_HAWB",6)              SIZE 60,8 Of oDlgFilt F3 AVSX3("EF3_HAWB",8) HASBUTTON
      @nLin,019 Say   STR0122                of oDlgFilt     // "Invoice"
      @nLin,027 MSGET cInvoice   Pict AVSX3("WB_INVOICE",6)           SIZE 60,8 Of oDlgFilt F3 AVSX3("EF3_INVIMP",8) HASBUTTON
      nLin += 001

      @nLin,002 Say   STR0124                of oDlgFilt     // "Valor Entre"
      @nLin,010 MSGET nValIni    Pict AVSX3("EEQ_VL",6)                  SIZE 60,8 Of oDlgFilt HASBUTTON
      @nLin,019 Say   STR0125                of oDlgFilt     // "e"
      @nLin,027 MSGET nValFim    Pict AVSX3("EEQ_VL",6)                  SIZE 60,8 Of oDlgFilt HASBUTTON
      nLin += 001

      @nLin,002 Say   EX401STR(76)           of oDlgFilt     // "Fornecedor"
      @nLin,010 MSGET cFornec    Pict AVSX3("WB_FORN",6) F3 "SA2" Valid (Empty(cFornec) .OR. ExistCpo("SA2",cFornec)) SIZE 60,8 Of oDlgFilt HASBUTTON
      @nLin,019 Say   Left(AVSX3("WB_LOJA",5),4)  of oDlgFilt     // "Loja"
      @nLin,027 MSGET cLoja      Pict AVSX3("WB_LOJA",6) Valid (Empty(cLoja) .or. ExistCpo("SA2",cFornec+cLoja)) SIZE 60,8 Of oDlgFilt
      nLin += 001

      @nLin,002 Say   STR0169                of oDlgFilt     // "País"
      @nLin,010 MSGET cPais      Pict AVSX3("A2_PAIS" ,6) F3 "SYA" Valid (Empty(cPais) .or. ExistCpo("SYA",cPais)) SIZE 60,8 Of oDlgFilt HASBUTTON
      @nLin,019 Say   "Moeda"                of oDlgFilt     // "Moeda"
      @nLin,027 MSGET cMoeda     Pict AVSX3("WB_MOEDA",6) F3 "SYF" Valid (Empty(cPais) .or. ExistCpo("SYF",cMoeda)) SIZE 60,8 Of oDlgFilt HASBUTTON
      nLin += 001

   EndIf

   If(EasyEntryPoint("EFFEX400"),ExecBlock("EFFEX400",.F.,.F.,"TELA_FILTRO_INVOICES"),)

   Define sButton from nLinButton,nColButton Type 1 Action(  lRet:=.t., oDlgFilt:End() ) Enable of oDlgFilt

Activate Msdialog oDlgFilt Centered

// ------------------------------------------------------------- //
If lRet
   cFil := StrTran(cFil,",'"+Alltrim(EasyGParam("MV_AVG0024",,""))+"'")
   If Right(Alltrim(cFil),1) == ","
      cFil := Left(cFil,len(cFil)-1)
   EndIf
   cTipoVinc := Left(cTipoVinc,1)
   cTpCon    := Left(cTpCon,1)
   MsAguarde( {|| EX400Invoices()}, STR0014 )
   SetKEY(15,bBarOk)
   SetKEY(24,bBarCancel)
   SetaFiltro(2)
Endif

WorkEF3->(dbSetOrder(ORDEM_BROWSE))

Return lRet

// --------------------------------------------------------
FUNCTION BAIXAJUROS(PTipo)
// ACSJ - Caetano - 20/01/2005
// Permite baixar juros não baixados com o principal (EF1_PGJURO $ cSim)
// --------------------------------------------------------
Local oGetDados, cFilOri:="", nValVC:=0, dDtVinc, dDtProvJur, dDtCont
Local ni        := 0, i:=0
Local aAlter    := {}, nxi:=0
Local lOk       := .f.
Local nEFF0002:=EasyGParam("MV_EFF0002",,0) //GFC
Local cContrato
// ACSJ - 09/02/2005
Local cBanco
Local cPraca
// -----------------
Local cInvoice
Local cPreemb
Local cMoeInv
Local cSeq
Local cParc
Local cTxMoe
Local dDtEve
Local nInc
Local aTx_Ctb
Local aTx_Dia
Local nVal1
Local nValAux1 := 0
Local nValAux2 := 0
Local nTxJuros1
Local nTxJuros2
Local nTaxaVCJuros
Local nVLREAL640:=0, nVLMOE640:=0, nPJAntR:=0
Local nVLMOE520:=0, aJuros:={}, lPVez:=.T.
Local aHeaderAux := aClone(aHeader), aHeaderAx2:= {}
Local aColsAux   := aClone(aCols)  , aColsAx2  := {}
Local nOldN := N //FSM - 28/06/2012
Local nTx520 := 0  // PLB 06/06/06 - Taxa de Provisao de Juros
Local nRecAux := WorkEF3->( RecNo() )
Local nDecTaxa := AVSX3("EF3_TX_MOE",4)
Local aYesFields
Local nOld := If(type("n")=="N",n,) //ISS - 10/02/11 - Tratamento para guardar e recuperar o "n" do getdados.
Local lCpoDtLqEv := WorkEF3->(FieldPos("EF3_DTOREV")) > 0
Local aVLEve := {}, nTxMoeJr := 0  // GFP - 28/07/2014
Local cEventLiq := ""
Private oDlg2
Private aBotoes := {} /* LDB 26/04/2006 - Inclusao na EnchoiceBar */
Default PTipo := "LQ_JR_NRM"
aHeader := {}
aCols   := {}

lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0

Aadd(aAlter, "EF3_TX_MOE")
Aadd(aAlter, "EF3_DT_EVE")
Aadd(aAlter, "EF3_VL_MOE") //NCF - 12/11/2013 - Diferença de Juros
IF lCpoDtLqEv/*PTipo == "LQ_JR_ANT"*/
   Aadd(aAlter, "EF3_DTOREV")
EndIf

//Abertura de campos para ser possível escolher em qual será realizada a liquidação dos juros.
AAdd(aAlter, "EF3_BANC")
AAdd(aAlter, "EF3_AGEN")
AAdd(aAlter, "EF3_NCON")

If lEF2_TIPJUR
   Aadd(aHeader, {AVSX3("EF2_TIPJUR",5),"EF2_TIPJUR",AVSX3("EF2_TIPJUR",6),AVSX3("EF2_TIPJUR",3),AVSX3("EF2_TIPJUR",4),nil,nil,AVSX3("EF2_TIPJUR",2),nil,nil })
EndIf
aYesFields := {"EF3_INVOIC", "EF3_PARC", "EF3_VL_MOE", "EF3_TX_MOE", "EF3_VL_REA", "EF3_DT_EVE", "EF3_BANC", "EF3_AGEN", "EF3_NCON"}
If lCpoDtLqEv/*PTipo == "LQ_JR_ANT"*/
   Aadd(aYesFields,"EF3_DTOREV")
EndIf

FillGetDados(ALTERAR, "EF3", 1, "", {|| "" }, /*bSeekFor*/, /*aNoFields*/, aYesFields,,,{|| MontCols("BAIXA",nRecAux) },,,,,,)
//Remove a validação padrão dos campos, que é específica para Manutenção de Eventos no Contrato de Financiamento

For nInc := 1 To Len(aHeader)
   aHeader[nInc][6] := ""
Next


/* LDB 26/04/2006 */
If EasyEntryPoint("EFFEX400")
   lSair := .F.
   ExecBlock("EFFEX400",.F.,.F.,"ANTES_DIALOG")
   If lSair
      Return .F.
   EndIf
EndIf

If .not. Empty(aCols)
   M->EF3_CODEVE := WORKEF3->EF3_CODEVE

   DEFINE MSDIALOG oDlg2 TITLE STR0181 FROM 00,00 TO 400,800 OF oMainWnd PIXEL //"Baixa de Provisão de Juros"

   //                             1   2   3    4   5     6               7            8       9   10        11             12        13    14
      oGetDados := MsGetDados():New(30, 01, 202, 400, 4,"AllwaysTrue()",,,.F.,aAlter,,,Len(aCols),"EX400FIELDOK",,,, oDlg2)
      oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   ACTIVATE MSDIALOG oDlg2 ON INIT ENCHOICEBAR(oDlg2,{||lOk:=VLdBxJuros(), iif(lOk,oDlg2:End(),) },{||oDlg2:End()},,aBotoes) CENTERED
Else
   MsgStop(STR0182) //"Não existem juros a serem liquidados"
Endif

//ISS - 10/02/11 - Tratamento para guardar e recuperar o "n" do getdados.
IF Type("nOld")=="N"
   n := nOld
EndIf

if lOk

   For i := 1 to Len(aCols)
      if aCols[i,5] <> 0   // TX_MOE
            // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
            if WorkEF3->( fieldpos("ALTERADO") ) > 0
                  WorkEF3->ALTERADO := .T.
            endif

         // 640
         WORKEF3->(DBGoTo(aCols[i,Len(aHeader)+2/*10*/]))
         If lLogix                                                  //NCF - 11/09/2014
            AF200BkPInt( 'WORKEF3' , "EFF_INBX_ALT",,{'EF1',EF1->(Recno())},,)
         EndIf
         cEventLiq := WORKEF3->EF3_CODEVE
         Reclock("WORKEF3",.f.)
         WORKEF3->EF3_TX_MOE := aCols[i,GdFieldPos("EF3_TX_MOE")]
         WORKEF3->EF3_VL_REA := aCols[i,GdFieldPos("EF3_VL_REA")]

         WORKEF3->EF3_DT_EVE := If( !Empty(aCols[i,GdFieldPos("EF3_DT_EVE")]) /*.And. If(PTipo<>"LQ_JR_ANT",.T.,.F.)*/ , aCols[i,GdFieldPos("EF3_DT_EVE")], dDataBase)

         If lCpoDtLqEv
            If aCols[i,GdFieldPos("EF3_DTOREV")] < aCols[i,GdFieldPos("EF3_DT_EVE")]
               PTipo := "LQ_JR_ANT"                                                  //NCF - 21/05/2014 - Liquidacao de Juros Antecipado(sem reapuração de valor)
            EndIf

            If PTipo == "LQ_JR_ANT"
               WORKEF3->EF3_DTOREV := aCols[i,GdFieldPos("EF3_DTOREV")]             //NCF - 21/08/2014 - Tratamento do campo removido para dentro do bloco que valida se o mesmo existe.
            Else
               //RMD - 01/12/14 - Considerar a data de liquidação digitada na tela.
               WORKEF3->EF3_DTOREV := If( !Empty(aCols[i,GdFieldPos("EF3_DTOREV")] ) , aCols[i,GdFieldPos("EF3_DTOREV")] , aCols[i,GdFieldPos("EF3_DT_EVE")])
            EndIf
         EndIf

         WORKEF3->EF3_BANC := aCols[i,GdFieldPos("EF3_BANC")]
         WORKEF3->EF3_AGEN := aCols[i,GdFieldPos("EF3_AGEN")]
         WORKEF3->EF3_NCON := aCols[i,GdFieldPos("EF3_NCON")]

         MsUnlock()
         nTxMoeJr := WORKEF3->EF3_TX_MOE // GFP - 29/07/2014

         // ** GFC - 23/07/05 - Atualiza saldos do contrato
         If !(lPrePag .AND. M->EF1_CAMTRA == "1") // ** GFC - Pré-Pagamento/Securitização
            M->EF1_SL2_JR -= WorkEF3->EF3_VL_REA
            M->EF1_LIQJRR += WorkEF3->EF3_VL_REA
         EndIf
         // **

         If lEFFTpMod
            cTpModu := WorkEF3->EF3_TPMODU
         EndIf
         cContrato   :=   WORKEF3->EF3_Contra
         If lTemChave
            cBancoFI    :=   WORKEF3->EF3_BAN_FI
            cAgenFI     :=   WORKEF3->EF3_AGENFI
            cContaFI    :=   WORKEF3->EF3_NCONFI
            cPraca      :=   WORKEF3->EF3_PRACA
            cBanco      :=   WORKEF3->EF3_BANC
            cAgen       :=   WORKEF3->EF3_AGEN
            cConta      :=   WORKEF3->EF3_NCON
            If lEFFTpMod
               cSeqCon  := WorkEF3->EF3_SEQCNT
            EndIf
         EndIf
         cInvoice    :=   WORKEF3->EF3_Invoice
         cPreemb     :=   WORKEF3->EF3_Preemb
         cMoeInv     :=   WORKEF3->EF3_MOE_IN
         cSeq        :=   WORKEF3->EF3_SEQ
         cParc	     :=   WORKEF3->EF3_PARC
         cTxMoe      :=   WORKEF3->EF3_TX_MOE
         dDtEve      :=   WORKEF3->EF3_DT_EVE
         nValor      :=   WORKEF3->EF3_VL_INV
         If lMultiFil
            cFilORI := WorkEF3->EF3_FILORI
         EndIf

         nVal1        := EX400Conv(cMoeInv,EF1_MOEDA,nValor)
         nTxJuros1    := BuscaTaxa(M->EF1_MOEDA, dDataBase    ,,.T.,,,cTX_520)
         nTxJuros2    := BuscaTaxa(M->EF1_MOEDA, IIF(Empty(M->EF1_DT_CTB) .Or. !lIsContab,M->EF1_DT_JUR,M->EF1_DT_CTB),,.T.,,,cTX_520)
         nTaxaVCJuros := BuscaTaxa(M->EF1_MOEDA, IIF(Empty(M->EF1_DT_CTB) .Or. !lIsContab,M->EF1_DT_JUR,M->EF1_DT_CTB),,.T.,,,cTX_520)

         nVLREAL640  := WORKEF3->EF3_VL_REA
         nVLMOE640   := WORKEF3->EF3_VL_MOE

         // ** GFC - 23/07/05 - Busca provisões de juros existentes para esse juros
         WorkEF3->(dbSetOrder(2))

         // GCC - 17/09/2013
         dDtProvJur := NIL
         WorkEF3->(dbSeek(Left(EV_PJ,2)+Right(aCols[i,Len(aHeader) + 4],1)+IF( M->EF1_TP_FIN <> "03", cInvoice+cParc, '' )))             //NCF - 24/06/2015 - Evento 520 de PPE não possui invoice+parcela informada no Work
         Do While WorkEF3->(!Eof()) .And. WorkEF3->EF3_CODEVE == Left(EV_PJ,2)+Right(aCols[i,Len(aHeader) + 4],1) .And.;
         IF( M->EF1_TP_FIN <> "03", WorkEF3->EF3_INVOIC == cInvoice .and. WorkEF3->EF3_PARC == cParc , .T. )
            If WorkEF3->EF3_SEQ == cSeq
               nVLMOE520 += WORKEF3->EF3_VL_MOE  // PLB 06/06/06 - Recebe valor apenas uma vez
               nPJAntR   += WORKEF3->EF3_VL_REA
            Else
               nPJAntR   += WORKEF3->EF3_VL_REA
            EndIf

            If dDtProvJur == NIL .OR. dDtProvJur <= WorkEF3->EF3_DT_EVE
               nTx520    := WORKEF3->EF3_TX_MOE  // PLB 06/06/06 - Taxa da ultima provisao de Juros para calculo de Variacao Cambial
               dDtProvJur:= WorkEF3->EF3_DT_EVE
            EndIf

            WorkEF3->(dbSkip())
         Enddo

         If Empty(M->EF1_DT_CTB)  .Or.  !lIsContab
            dDtCont := Strzero(Month(M->EF1_DT_JUR),2,0)+Strzero(Year(M->EF1_DT_JUR),4,0)
         Else
            dDtCont := Strzero(Month(M->EF1_DT_CTB),2,0)+Strzero(Year(M->EF1_DT_CTB),4,0)
         EndIf
         // **
         If WorkEF3->(dbSeek(EV_EMBARQUE+IF( M->EF1_TP_FIN <> "03", cInvoice+cParc, '' )))                                               //NCF - 24/06/2015 - Evento 520 de PPE não possui invoice+parcela informada no Work
            If lPrePag .AND. M->EF1_CAMTRA == "1"
               dDtVinc := M->EF1_DT_JUR
            Else
               dDtVinc := WorkEF3->EF3_DT_EVE
            EndIf
            lMesmoMes := .F.
            If dDtProvJur == Nil // GCC - 17/09/2013
	            If dDtVinc > dDatabase
	               dDtProvJur := dDtVinc
	            ElseIf Month(dDtVinc) = Month(dDatabase) .AND. Year(dDtVinc) = Year(dDatabase)  // VI 26/09/03
	               dDtProvJur := dDtVinc
	            Else
	               If lPrePag .AND. M->EF1_CAMTRA == "1"
	                  dDtProvJur := dDtVinc
	               ElseIf !(M->EF1_CAMTRA == "1")  .And.  ( Empty(M->EF1_DT_CTB)  .Or.  !lIsContab )
	                  dDtProvJur := dDtVinc
	               Else
	                  dDtProvJur := dDatabase
	               EndIf
	               If Month(dDtVinc) <> Month(dDatabase) .AND. ;
	               Val(Strzero(Year(dDtProvJur),4,0)+Strzero(Month(dDtProvJur),2,0)) = Val(Right(dDtCont,4)+Left(dDtCont,2)) .AND. !lMesmoMes .And.;
	               !Empty(M->EF1_DT_CTB)  .And.  lIsContab  //M->EF1_DT_CTB # M->EF1_DT_JUR   // PLB 13/06/07
	                  dDtProvJur := CTOD('01/'+Str(Month(dDatabase))+'/'+Str(Year(dDatabase))) - 1
	                  lMesmoMes  := .T.
	               Endif
	            EndIf
            EndIf
         EndIf
         If !Empty(dDtProvJur)
            If Val(Strzero(Year(dDtProvJur),4,0)+Strzero(Month(dDtProvJur),2,0)) < Val(Right(dDtCont,4)+Left(dDtCont,2)) .AND. !lMesmoMes
               //nTxJuros1 := Round(BuscaTaxa(M->EF1_MOEDA, M->EF1_DT_CTB,,.T.,,,cTX_520),nDecTaxa)
               // PLB 13/06/07
               nTxJuros1 := Round(BuscaTaxa(M->EF1_MOEDA, IIF(Empty(M->EF1_DT_CTB) .Or. !lIsContab,M->EF1_DT_JUR,M->EF1_DT_CTB),,.T.,,,cTX_520),nDecTaxa)
            Else
               nTxJuros1 := Round(BuscaTaxa(M->EF1_MOEDA, dDtProvJur,,.T.,,,cTX_520),nDecTaxa)
            EndIf
         EndIf

      If M->EF1_TPMODU == IMP
         // 520 - Provisão de Juros   // GFP - 28/07/2014
         aVLEve    := EX400CalcVlr("520")
         nVLMOE520 := aVLEve[1]
         nTx520    := nTxMoeJr
         WORKEF3->(RecLock("WORKEF3",.T.))
         WORKEF3->EF3_FILIAL := xFilial("EF3")
         WORKEF3->EF3_CONTRA := cContrato

         If lEFFTpMod
            WorkEF3->EF3_TPMODU := cTpModu
         EndIf

         If lEFFTpMod
            WorkEF3->EF3_SEQCNT := cSeqCon
         EndIf

         WORKEF3->EF3_CODEVE := if(aVLEve[1]>0,"52","51")+aVLEve[2]
         WORKEF3->EF3_VL_MOE := aVLEve[1]
         WORKEF3->EF3_VL_REA := aVLEve[1]*nTxMoeJr

         WORKEF3->EF3_TX_MOE := nTxMoeJr
         WORKEF3->EF3_PARC   := cParc
         WORKEF3->EF3_DT_EVE := dDtEve
         WORKEF3->EF3_SEQ    := cSeq
         If lMultiFil
            WorkEF3->EF3_FILORI := cFilORI
         EndIf
         M->EF1_SL2_JR -= WORKEF3->EF3_VL_REA
         If cMod == EXP .AND. !(lPrePag .and. M->EF1_TP_FIN $ ("03/04"))
            WORKEF3->EF3_TP_EVE := RetAceAcc(WORKEF3->EF3_INVOIC) // "02"
         Else
            WORKEF3->EF3_TP_EVE := M->EF1_TP_FIN
         EndIf

         WorkEF3->EF3_EV_VIN := cEventLiq /*EV_LIQ_JUR*/  // 640

         WorkEF3->TRB_ALI_WT := "EF3"
         WorkEF3->TRB_REC_WT := 0

         WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

            // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
            if WorkEF3->( fieldpos("ALTERADO") ) > 0
                  WorkEF3->ALTERADO := .T.
            endif

         WORKEF3->(msUnlock())
      ENDIF

         // 550/551
         WORKEF3->(RecLock("WORKEF3",.T.))
         WORKEF3->EF3_FILIAL := xFilial("EF3")
         WORKEF3->EF3_CONTRA := cContrato

         If lEFFTpMod
            WorkEF3->EF3_TPMODU := cTpModu
         EndIf

         // ACSJ - 09/02/2005
         if lTemChave
            WORKEF3->EF3_BAN_FI := cBancoFI
            WORKEF3->EF3_AGENFI := cAgenFI
            WORKEF3->EF3_NCONFI := cContaFI
            WORKEF3->EF3_PRACA  := cPraca
            WORKEF3->EF3_BANC   := cBanco
            WORKEF3->EF3_AGEN   := cAgen
            WORKEF3->EF3_NCON   := cConta
            If lEFFTpMod
               WorkEF3->EF3_SEQCNT := cSeqCon
            EndIf
         Endif
         // -----------------

         WORKEF3->EF3_CODEVE := IF(((nVLREAL640- Round((nVLMOE520 * nTx520/*cTxMoe*/),2)) - Round(((nVLMOE640-nVLMOE520) * nTxJuros1),2)) > 0,Alltrim(Str(550+(Val(Right(aCols[i,Len(aHeader)+4],1))*2))),Alltrim(Str(551+(Val(Right(aCols[i,Len(aHeader)+4],1))*2))))  // PLB 18/05/07 //FSM - 12/11/2012
         WORKEF3->EF3_INVOIC := cInvoice
         WORKEF3->EF3_PREEMB := cPreemb
         WORKEF3->EF3_MOE_IN := cMoeInv

   //       WORKEF3->EF3_VL_REA := ((nValAux2 - nValAux1) * nTxJuros1) - ((nValAux2 - nValAux1) * nTxJuros2)
         //WORKEF3->EF3_VL_REA := ((nVLREAL640- Round((nVLMOE520 * nTx520/*cTxMoe*/),2)) - Round(((nVLMOE640-nVLMOE520) * nTxJuros1),2)) + nValVC    // PLB 06/06/06 - nTx520
         WORKEF3->EF3_VL_REA := ((nVLREAL640- Round((nVLMOE520 * nTx520/*cTxMoe*/),2)) - Round(((nVLMOE640-nVLMOE520) * nTxJuros1),2))    // PLB 18/05/07

         WORKEF3->EF3_TX_MOE := cTxMoe
         WORKEF3->EF3_PARC   := cParc
         WORKEF3->EF3_DT_EVE := dDtEve
         WORKEF3->EF3_SEQ    := cSeq
         If lMultiFil
            WorkEF3->EF3_FILORI := cFilORI
         EndIf

         M->EF1_SL2_JR += WORKEF3->EF3_VL_REA
         //WORKEF3->EF3_TP_EVE := M->EF1_TP_FIN - FSM - 12/11/2012
         If cMod == EXP .AND. !(lPrePag .and. M->EF1_TP_FIN $ ("03/04"))
            WORKEF3->EF3_TP_EVE := RetAceAcc(WORKEF3->EF3_INVOIC) // "02"
         Else
            WORKEF3->EF3_TP_EVE := M->EF1_TP_FIN
         EndIf

         // PLB 18/05/07 - Identifica que o evento de Variação Cambial foi gerado em funcao da Liquidacao dos Juros
         WorkEF3->EF3_EV_VIN := cEventLiq /*EV_LIQ_JUR*/  // 640

         WorkEF3->TRB_ALI_WT := "EF3"
         WorkEF3->TRB_REC_WT := 0

         //FSM - 23/05/2012
         WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

            // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
            if WorkEF3->( fieldpos("ALTERADO") ) > 0
                  WorkEF3->ALTERADO := .T.
            endif

         WORKEF3->(msUnlock())

	     //** AAF 23/01/2015
		 //If M->EF1_PGJURO $ cSim

			cJuros  := Right(aCols[i,Len(aHeader)+4],1)
			nRec640 := aCols[i,Len(aHeader)+2]

		    //Variação Cambial do 620 (Juros Antecipados)
			nVal620  := EX401EvSum("62"+Alltrim(Str(Val(cJuros))),"WorkEF3",,.T.,)
			nVal620R := EX401EvSum("62"+Alltrim(Str(Val(cJuros))),"WorkEF3",,.F.,)

			nVal620R += EX401EvSum(AllTrim(Str(580+Val(cJuros)*2)),"WorkEF3",,.F.,)
			nVal620R += EX401EvSum(AllTrim(Str(581+Val(cJuros)*2)),"WorkEF3",,.F.,)

 		    nVal620  -= EX401EvSum("64"+Alltrim(Str(Val(cJuros))),"WorkEF3",,.T.,{||WorkEF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0) .AND. WorkEF3->(RecNo()) <> nRec640})
			nVal620R -= EX401EvSum("64"+Alltrim(Str(Val(cJuros))),"WorkEF3",,.F.,{||WorkEF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0) .AND. WorkEF3->(RecNo()) <> nRec640})

			WorkEF3->(dbGoTo(nRec640))
  		    nTxVc620 := WorkEF3->EF3_TX_MOE

			//Variacao cambial de juros antecipado.
            nVc620RS := nVal620 * nTxVc620 - nVal620R

			If nVc620RS <> 0

			   WorkEF3->(RecLock("WorkEF3",.T.))
               WorkEF3->EF3_FILIAL := xFilial("EF3")
               /*If ValType(cFilOri) == "C"
                  WorkEF3->EF3_FILORI := cFilOri
               EndIf*/

               If lEFFTpMod
                  WorkEF3->EF3_TPMODU := cTpModu
               EndIf
               WorkEF3->EF3_CODEVE := AllTrim(Str(580+if(nVc620RS>=0,0,1)+Val(cJuros)*2))
               WorkEF3->EF3_TP_EVE := M->EF1_TP_FIN
               WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)
               WorkEF3->EF3_CONTRA := cContrato

               If lTemChave
                  WORKEF3->EF3_BAN_FI := cBancoFI
                  WORKEF3->EF3_AGENFI := cAgenFI
                  WORKEF3->EF3_NCONFI := cContaFI
                  WORKEF3->EF3_PRACA  := cPraca
                  WORKEF3->EF3_BANC   := cBanco
                  WORKEF3->EF3_AGEN   := cAgen
                  WORKEF3->EF3_NCON   := cConta
                  If lEFFTpMod
                        WorkEF3->EF3_SEQCNT := cSeqCon
                  EndIf
               Endif

			   WorkEF3->EF3_DT_EVE := dDtEve
			   WorkEF3->EF3_TX_MOE := nTxVc620
			   WorkEF3->EF3_VL_REA := nVc620RS
			   WorkEF3->EF3_SEQ    := cSeq

			   WorkEF3->(msUnlock())
			EndIf

         If lLogix                                                  //NCF - 11/09/2014
            AF200BkPInt( 'WORKEF3' , "EFF_INBX_INC",,{'EF1',EF1->(Recno())},,)
         EndIf

         aHeaderAx2 := aClone(aHeader)
         aColsAx2   := aClone(aCols)
         aHeader := aClone(aHeaderAux)
         aCols   := aClone(aColsAux)
         If lCadFin
            EX401GrEncargos("WorkEF3")
         EndIf
         aHeader := aClone(aHeaderAx2)
         aCols   := aClone(aColsAx2)
         // ** PLB 30/05/07 - Atualização de todos os saldos do Contrato
         EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)
         //ASK - 23/10/2007 - Inclusão 8ªparâmetro como .T., para atualizar os campos de Saldo do EF1.
      Endif
   Next i

   // ** GFC - 17/08/05 - Caso o saldo restante do contrato esteja menor que o valor informado no MV_EFF0002
   //                    deve preencher a data de encerramento automaticamente.
   If M->EF1_SLD_PM < nEFF0002 .and. M->EF1_SL2_PM < nEFF0002  .And. !EX401JrOpen("M","WorkEF3")
      EX401Encerra(M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,M->EF1_SL2_PM,"M",dDtEve, , ,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
   EndIf
   // **

Endif

WorkEF3->(dbSetOrder(ORDEM_BROWSE))
WorkEF3->(dbgoto(nRecAux))
oMark:oBrowse:Refresh()

aHeader := aClone(aHeaderAux)
aCols   := aClone(aColsAux)
N := nOldN //FSM - 28/06/2012

return .t.

/*/{Protheus.doc} VldBxJuros()
      Função para validar se as moedas do cadastro do banco utilizado na baixa estão iguais
      @type  Static Function
      @author user
      @since 26/10/2018
      @version version
      @param param, param_type, param_descr
      @return returno,return_type, return_description
      @example
      (examples)
      @see (links_or_references)
      /*/
Static Function VldBxJuros()
Local lRet := .T.
Local nPosBanc := aScan( aHeader , {|x| alltrim(x[2]) == "EF3_BANC" })
Local nPosAgen := aScan( aHeader , {|x| alltrim(x[2]) == "EF3_AGEN" })
Local nPosNcon := aScan( aHeader , {|x| alltrim(x[2]) == "EF3_NCON" })
Local cSeekSA6 := ""
Local cMsgBanco:= ""
Local nB := 1

// MPG - 26/10/2018 - VALIDAÇÃO PARA QUE NÃO PERMITA O USO DE UM BANCO COM AS MOEDAS DIFERENTES DE ACORDO COM MÓDULOS E PARÂMETROS
for nB := 1 to len(aCols)
      cSeekSA6 := xfilial("SA6")+ avkey(aCols[nB][nPosBanc],"A6_COD") + AVKEY(aCols[nB][nPosAgen],"A6_AGENCIA") + AVKEY(aCols[nB][nPosNcon],"A6_NUMCON")
      If SA6->( dbsetorder(1),dbseek( cSeekSA6 ))
            if SYF->( dbsetorder(1),dbseek(xfilial("SYF")+SA6->A6_MOEEASY) ) .and. SA6->A6_MOEDA <> SYF->YF_MOEFAT
                  lRet := .F.
                  cMsgBanco := STR0287
                  cMsgBanco := strtran( cMsgBanco , "BBB" , Alltrim(aCols[nB][nPosBanc]) )
                  cMsgBanco := strtran( cMsgBanco , "AAA" , Alltrim(aCols[nB][nPosAgen]) )
                  cMsgBanco := strtran( cMsgBanco , "CCC" , Alltrim(aCols[nB][nPosNcon]) )
                  msgstop(cMsgBanco,STR0094) //"Banco: BBB Agencia: AAA Conta: CCC não pode ser ultilizado, pois os campos de moeda não podem estar diferentes um do outro.","Atenção"
            endif
      endif
next

Return lRet

//------------------------------------------
// ACSJ - Caetano - 20/01/2005
FUNCTION EX400FIELDOK()
// Valida o Campo DTEVE e calcula valor em R$ baseado na taxa digitada
//------------------------------------------
LOCAL lRet := .f.
LOCAL nInd := WORKEF3->(IndexOrd())
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Local aOrdWkEF3 := SaveOrd("WorkEF3")
PCampo := ReadVar()
if PCampo == "M->EF3_TX_MOE"
   If &Pcampo < 0  // PLB 24/08/06
      Help(" ",1,"AVG0005247")  //"Valor deve ser maior que zero."
   Else
      GDFieldPut("EF3_VL_REA",(Round(aCols[n,3]*M->EF3_TX_MOE,nDecValor)), n)
      lRet := .t.
   EndIf
elseif PCampo == "M->EF3_DT_EVE"
   WORKEF3->(DBSetOrder(1))
   If WORKEF3->(DBSeek( aCols[n,Len(aHeader)+3] + EV_LIQ_PRC )) .or. WORKEF3->(DBSeek( aCols[n,Len(aHeader)+3] + EV_LIQ_PRC_FC ))
      if WORKEF3->EF3_DT_EVE <= M->EF3_DT_EVE
         lRet := .t.
      Else
         MsgInfo(STR0163) //"A Data do evento deve ser maior ou igual a data de liquidação do principal."
      Endif
   EndIf
   WORKEF3->(DBSetOrder(nInd))
ElseIf PCampo == "M->EF3_DTOREV"  //NCF - 25/03/2014
   If M->EF3_DTOREV == aCols[n,GdFieldPos("EF3_DT_EVE")]
      lRet := .T.
   ElseIf !Empty(M->EF3_DTOREV) .And. M->EF3_DTOREV < aCols[n,GdFieldPos("EF3_DT_EVE")]
      If MsgYesNo("Este evento está sendo liquidado antecipadamente!"+CHR(13)+CHR(10)+;
                  "Clique em 'SIM' se deseja efetuar a liquidação agora, informe a data de liquidação e os juros não serão recalculados. "+;
                  "Clique em 'NAO' para retornar (Tecla 'ESC' para sair do campo) e alterar a data do evento para que os juros sejam recalculados antes da liquidação. ",STR0117) //# ##"Aviso"
         lRet := .T.
      Else
         lRet := .F.
      EndIf
   ElseIf !((Left(M->EF3_CODEVE,2) == Left(EV_LIQ_JUR_FC,2)) .Or. (Left(M->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2))) //RMD - 28/11/14 - Permite liquidar o evento 670 ou 710 em data posterior.
      MsgAlert("Data de Liquidação deve ser igual ou anterior à data do evento!","Aviso")
      lRet := .F.
   Else
      lRet := .T.
   EndIf

ElseIf PCampo == "M->EF3_BANC"

   lRet := Vazio() .Or. ExistCpo("SA6", M->EF3_BANC +;
                           If(!Empty(GdFieldGet("EF3_AGEN", n)), GdFieldGet("EF3_AGEN", n), "") +;
                           If(!Empty(GdFieldGet("EF3_NCON", n)), GdFieldGet("EF3_NCON", n), ""), 1)
ElseIf PCampo == "M->EF3_AGEN"
   lRet := Vazio() .Or. ExistCpo("SA6", GdFieldGet("EF3_BANC", n) + M->EF3_AGEN, 1)
ElseIf PCampo == "M->EF3_NCON"
   lRet := Vazio() .Or. ExistCpo("SA6", GdFieldGet("EF3_BANC", n) + GdFieldGet("EF3_AGEN", n) + M->EF3_NCON, 1)
Endif
RestOrd(aOrdWkEF3,.T.)
Return lRet

*-------------------------------------------------------------------------------------*
Function EstBxJuros()
*-------------------------------------------------------------------------------------*
Local oGetDados, cFilOri:="", cSeqAux, nOldRec, aEvento:={}
Local ni        := 0, i:=0
Local aAlter    := {}, nxi:=0
Local lOk       := .f.
Local aBotao := {}
Local aHeaderAux := aClone(aHeader)
Local aColsAux   := aClone(aCols)
Local aHeader2   := {} //FSM - 15/05/2012
Local nOldN := N //FSM - 28/06/2012
Local aCols2     := {}
Local nRecAux    := WorkEF3->( RecNo() )
Local aYesFields
Local nOld := If(type("n")=="N",n,) //ISS - 10/02/11 - Tratamento para guardar e recuperar o "n" do getdados.
Local cEvEstLiq := ""
Private oDlg2

aHeader := {}
aCols   := {}

lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0

WorkEF3->(dbSetOrder(1))

Aadd(aHeader, {"Status","STATUS","@!",7,0,nil,nil,"C",nil,nil })
If lEF2_TIPJUR
   Aadd(aHeader, {AVSX3("EF2_TIPJUR",5),"EF2_TIPJUR",AVSX3("EF2_TIPJUR",6),AVSX3("EF2_TIPJUR",3),AVSX3("EF2_TIPJUR",4),nil,nil,AVSX3("EF2_TIPJUR",2),nil,nil })
EndIf

aYesFields := {"EF3_INVOIC", "EF3_PARC", "EF3_VL_MOE", "EF3_TX_MOE", "EF3_VL_REA", "EF3_DT_EVE", "EF3_BANC", "EF3_AGEN", "EF3_NCON"}
FillGetDados(ALTERAR, "EF3", 1, "", {|| "" }, /*bSeekFor*/, /*aNoFields*/, aYesFields,,,{|| MontCols("ESTORNO",nRecAux) },,,,,,)

if .not. Empty(aCols)
   M->EF3_CODEVE := aCols[Len(aCols)][Len(aHeader)+4]

   DEFINE MSDIALOG oDlg2 TITLE STR0181 FROM 00,00 TO 400,800 OF oMainWnd PIXEL //"Baixa de Provisão de Juros"

   //                             1   2   3    4   5     6               7            8       9   10        11             12        13    14
      oGetDados := MsGetDados():New(30, 01, 202, 400, 4,"AllwaysTrue()",,,.F.,aAlter,,,Len(aCols),,,,, oDlg2)
      oGetDados:oBrowse:blDblClick:= {||If(Empty(aCols[n,1]),aCols[n,1]:="ESTORNA",aCols[n,1]:=""),oGetDados:ForceRefresh()}
      oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   ACTIVATE MSDIALOG oDlg2 ON INIT ENCHOICEBAR(oDlg2,{||lOk:= .T., oDlg2:End() },{||lOk:= .F., oDlg2:End()},,) CENTERED
Else
   MsgStop(STR0200) //"Não existe baixa de juros a ser estornada."
Endif

//ISS - 10/02/11 - Tratamento para guardar e recuperar o "n" do getdados.
IF Type("nOld")=="N"
   n := nOld
EndIf

if lOk

   For i := 1 to Len(aCols)
      if aCols[i,1] == "ESTORNA"   //Status

            // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
            if WorkEF3->( fieldpos("ALTERADO") ) > 0
                  WorkEF3->ALTERADO := .T.
            endif

         // 640
         WORKEF3->(DBGoTo(aCols[i,Len(aHeader)+2/*11*/]))
         cEvEstLiq := WorkEF3->EF3_CODEVE
         If !Empty(WorkEF3->EF3_NR_CON)
            nOldRec := WorkEF3->(RecNo())

            For ni := 1 To WorkEF3->(FCount())
               aAdd(aEvento,WorkEF3->&(FieldName(ni)))
            Next ni
            WorkEF3->(RecLock("WorkEF3",.T.))
            For ni := 1 To WorkEF3->(FCount())
               WorkEF3->&(FieldName(ni)) := aEvento[ni]
            Next ni
            WorkEF3->EF3_EV_EST := WorkEF3->EF3_CODEVE //WorkEF3->(DBDELETE())
            WorkEF3->EF3_DT_EST := dDataBase //AAF 24/07/05 - Grava a Data do Evento Estornado.
            WorkEF3->EF3_CODEVE := EV_ESTORNO
            WorkEF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
            WorkEF3->TRB_ALI_WT := "EF3"
            WorkEF3->TRB_REC_WT := 0

            //FSM - 23/04/2012
            WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

            WorkEF3->(msUnlock())

            If lLogix                                          //NCF - 11/09/2014
               AF200BkPInt( "WORKEF3" , "EFF_ESBX_INC",,{'EF1',EF1->(Recno())},,)
            EndIf

            //FSM - 15/05/2012
            aHeader2 := aClone(aHeader)
            aCols2   := aClone(aCols)
            aHeader  := aClone(aHeaderAux)
            aCols    := aClone(aColsAux)
            If lCadFin
               EX401GrEncargos("WorkEF3")
            EndIf
            aHeader := aClone(aHeader2)
            aCols   := aClone(aCols2)

            aEvento := {}

            WorkEF3->(dbGoTo(nOldRec))
         EndIf

         // ** GFC - 23/07/05 - Atualiza saldos do contrato
         If !(lPrePag .AND. M->EF1_CAMTRA == "1") // ** GFC - Pré-Pagamento/Securitização //lPrePag .and. M->EF1_TP_FIN $ ("03/04")
            //M->EF1_SL2_JM += WorkEF3->EF3_VL_MOE
            M->EF1_SL2_JR += WorkEF3->EF3_VL_REA
            //M->EF1_LIQJRM -= WorkEF3->EF3_VL_MOE
            M->EF1_LIQJRR -= WorkEF3->EF3_VL_REA
         EndIf
         // **

         WorkEF3->EF3_NR_CON := Space(Len(EF3->EF3_NR_CON))
         WORKEF3->EF3_TX_MOE := 0
         WORKEF3->EF3_VL_REA := 0
         //WORKEF3->EF3_DT_EVE := AvCtoD("  /  /  ") // ** GFC - 24/07/05 - Comentado a pedidos.
         If WORKEF3->(FieldPos("EF3_DTOREV")) > 0
            WORKEF3->EF3_DTOREV := AvCtoD("  /  /  ")
         EndIf
         cSeqAux := WorkEF3->EF3_SEQ

         WorkEF3->(dbSeek(cSeqAux+EV_VC_PJ1,.T.))
         Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_SEQ == cSeqAux .and.;
         Val(WorkEF3->EF3_CODEVE) >= Val(EV_VC_PJ1) .and. Val(WorkEF3->EF3_CODEVE) <= Val(EV_VC_PJ2)
            If Empty(WorkEF3->EF3_NR_CON)  .And.  WorkEF3->EF3_EV_VIN == cEvEstLiq /*EV_LIQ_JUR*/  // PLB 18/05/07 - Somente estorna evento de variacao cambial gerado no momento da liquidacao
               If Val(WorkEF3->EF3_CODEVE) >= Val(EV_VC_PJ1) .and. Val(WorkEF3->EF3_CODEVE) <= Val(EV_VC_PJ2) .and.;
               Val(WorkEF3->EF3_CODEVE) % 2 = 0 // '550'
                  M->EF1_SL2_JR -= WORKEF3->EF3_VL_REA
               Else
                  M->EF1_SL2_JR -= WORKEF3->EF3_VL_REA
               EndIf
               aAdd(aDelEF3,WorkEF3->EF3_RECNO)

               If lLogix                                                  //NCF - 11/09/2014
                  AF200BkPInt( 'WORKEF3' , "EFF_ESBX_EST",,{'EF1',EF1->(Recno())},,)
               EndIf

               WorkEF3->(RecLock("WorkEF3",.F.)) //FSM - 09/03/2012
               WorkEF3->(dbDelete())
               WorkEF3->(msUnlock())
            EndIf
            WorkEF3->(dbSkip())
         EndDo
         //NCF - 08/01/2015 - Excluir evento 510 quando gerado pelo evento 620
         If WorkEF3->EF3_CODEVE == '620'
            If WorkEF3->(dbSeek(cSeqAux+EV_EST_PJ))
               aAdd(aDelEF3,WorkEF3->EF3_RECNO)
               If lLogix                                                  //NCF - 11/09/2014
                  AF200BkPInt( 'WORKEF3' , "EFF_ESBX_EST",,{'EF1',EF1->(Recno())},,)
               EndIf
               WorkEF3->(RecLock("WorkEF3",.F.)) //FSM - 09/03/2012
               WorkEF3->(dbDelete())
               WorkEF3->(msUnlock())
            EndIf
         EndIf

      Endif
   Next i
EndIf

WorkEF3->(dbSetOrder(ORDEM_BROWSE))
WorkEF3->(dbGoTo(nRecAux) )
oMark:oBrowse:Refresh()

aHeader := aClone(aHeaderAux)
aCols   := aClone(aColsAux)
N := nOldN //FSM - 28/06/2012

Return .T.

*-------------------*
Function EX400CHist()
*-------------------*

EX400Hist(EF1->EF1_FILIAL,EF1->EF1_CONTRA,If(lTemChave,EF1->EF1_BAN_FI,),If(lTemChave,EF1->EF1_PRACA,),If(lEFFTpMod,EF1->EF1_TPMODU,),If(lEFFTpMod,EF1->EF1_SEQCNT,))

Return .T.

*-------------------------------------------------------------------------------------*
//AAF 04/03/06 - Adicionados os parâmetros:
//               cTpMod  = Tipo de Modulo "E" - Exportação e "I" - Importação.
//               cSeqCon = Sequência do Contrato
Function EX400Hist(cFilAux,cContra,cBanco,cPraca,cTpMod,cSeqCon)
*-------------------------------------------------------------------------------------*
Local oDlg, oMarkHist
Local aBotao:={{"BMPVISUAL" /*"ANALITICO"*/,{|| EXVisHist()}, STR0003}} //"Visualizar"

If EF4->(dbSeek(cFilAux+If(lEFFTpMod,cTpMod,"")+cContra+If(lTemChave,cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),"")))
   dbSelectArea("WorkEF4")
   WorkEF4->(avzap())
   Do While !EF4->(EOF()) .and. EF4->EF4_FILIAL==cFilAux .AND. If(lEFFTpMod,EF4->EF4_TPMODU == cTpMod,.T.) .and. EF4->EF4_CONTRA==cContra .and.;
   If(lTemChave,EF4->EF4_BAN_FI==cBanco,.T.) .and. If(lTemChave,EF4->EF4_PRACA==cPraca,.T.) .AND. if(lEFFTpMod,EF4->EF4_SEQCNT == cSeqCon,.T.)
      WorkEF4->(reclock("WorkEF4",.T.))
      WorkEF4->EF4_CAMPO  := EF4->EF4_CAMPO
      WorkEF4->EF4_DE     := EF4->EF4_DE
      WorkEF4->EF4_PARA   := EF4->EF4_PARA
      If lEF4_MOTIVO
         WorkEF4->EF4_MOTIVO := EF4->EF4_MOTIVO
      EndIf
      WorkEF4->EF4_USUARI := EF4->EF4_USUARI
      WorkEF4->EF4_HORA   := EF4->EF4_HORA
      WorkEF4->EF4_DATA   := EF4->EF4_DATA
      WorkEF4->EF4_TP_EVE := EF4->EF4_TP_EVE
      WorkEF4->EF4_PREEMB := EF4->EF4_PREEMB
      WorkEF4->EF4_INVOIC := EF4->EF4_INVOIC
      WorkEF4->EF4_PARC   := EF4->EF4_PARC
      WorkEF4->EF4_CODEVE := EF4->EF4_CODEVE
      WorkEF4->EF4_RECNO  := EF4->(RecNo())
      WorkEF4->TRB_ALI_WT := "EF4"
      WorkEF4->TRB_REC_WT := EF4->(Recno())
      EF4->(dbSkip())
   EndDo
   WorkEF4->(dbGoTop())

   DEFINE MSDIALOG oDlg TITLE STR0166 ; //"Histórico"
   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   OF oMainWnd PIXEL

      oMarkHist := MsSelect():New("WorkEF4",,,aSelCpos4,@lInverte,@cMarca,{15,1,FINAL_SELECT,COLUNA_FINAL})
      oMarkHist:bAval:={|| EXVisHist() }
      oMarkHist:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aBotao),oMarkHist:oBrowse:Refresh())

Else
   MsgInfo(EX401STR(77)+Alltrim(EF1->EF1_CONTRA)+If(lTemChave,EX401STR(37)+Alltrim(EF1->EF1_BAN_FI)+EX401STR(38)+Alltrim(EF1->EF1_PRACA),""))  //"Não existe histórico para o contrato " ## " banco " ## " praça "
EndIf

Return .T.

*-----------------------------------------------------------------------------------------*
Static Function EXVisHist()
*-----------------------------------------------------------------------------------------*
Local oDlg, nSelecao:=0, cTit:=STR0165 //"Visualização de Histórico"
Private nRec:=WorkEF4->EF4_RECNO

EF4->(dbGoTo(nRec))

DEFINE MSDIALOG oDlg TITLE cTit ;
FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
OF oMainWnd PIXEL

   EnChoice( "EF4",nRec,VISUALIZAR,,,,,{30,1,(oDlg:nClientHeight-4)/2,COLUNA_FINAL},,3)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

Return .T.

*------------------------------------------------------------------------------------------*
Function EX400MotHis(cTipo,cContra,cBanco,cPraca,cTpEve,cPreemb,cInvoice,cParc,cEve,cSeq,cTpModu,cSeqCon,cOrigem,cForn,cLoja, cMotivo, cFFCMot) //HVR 24/04/06 - ADICIONADO cMotivo //HVR cFFCMot para gravar no motivo
*------------------------------------------------------------------------------------------*
Local oDlgMot, /*cMot:="",*/ nOpc:=0, cDesc:=""
Local cEveAux := cEve
Local nPosMotivo := 0
Private oGetMot ,cMot:="" //LDB 25/04/2006

lEF4_MOTIVO := EF4->(FieldPos("EF4_MOTIVO")) > 0

EC6->( dbSetOrder(1) )
// ** PLB 19/12/06 - Caso nao encontre descricao para eventos de Tipo de Juros diferentes de "0"
If !EC6->(dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. cTpModu <> "I","FIEX","FIIM")+cTpEve+cEveAux+"    ") .OR.;
          dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. cTpModu <> "I","FIEX","FIIM")+cTpEve+cEveAux+"1000"))    ;//AAF 23/07/05 - Utilizar o tipo do Evento para descrição.
   .And.  Left(cEveAux,2) $ EVENTOS_DE_JUROS  // (510,520,550,640,650,670)

   If Left(cEveAux,2) == Left(EV_VC_PJ1,2)  .And.  ( Val(cEveAux) % 2 ) != 0  // 550 .And. Impar
      cEveAux := Left(cEveAux,2)+"1"
   Else
      cEveAux := Left(cEveAux,2)+"0"
   EndIf
   EC6->( DBSeek(xFilial("EC6")+If(!lEFFTpMod .OR. cTpModu <> "I","FIEX","FIIM")+cTpEve+cEveAux+"    ")  .Or.  ;
          DBSeek(xFilial("EC6")+If(!lEFFTpMod .OR. cTpModu <> "I","FIEX","FIIM")+cTpEve+cEveAux+"1000"))
EndIf
// **

cDesc := EC6->EC6_DESC

IF cMotivo == "" .OR. cMotivo == NIL //HVR 24/04/06 - Se o Motivo estiver vazio apresenta a tela para preencher caso contrario grava sempre o mesmo ultimo motivo
   If lEF4_MOTIVO
      if IsMemVar("lExecAuto") .and. lExecAuto
         if (nPosMotivo := ascan( aAutoItens , {|x| x[1]=="AUTMOTIVO"} )) > 0
            if !empty( aAutoItens[nPosMotivo][2] )
               cMot := alltrim( aAutoItens[nPosMotivo][2] )
               nOpc := 1
            else
               nOpc := 0
               easyhelp(STR0168,STR0145)
            endif
         else
            nOpc := 0
            easyhelp(STR0168,STR0145)
         endif
      else
         // caso não seja uma liquidação via execauto exibe a tela justificativa normalmente
         cMot:=Space(Len(EF4->EF4_MOTIVO))
         Do While nOpc = 0
            nOpc:=0
            DEFINE MSDIALOG oDlgMot TITLE STR0167; //"Motivo do Estorno"
            FROM 12,05 TO 27,100 OF GetWndDefault()
               @0.1,0.3 TO 6.4,46 Label EX401STR(78) of oDlgMot  //"Informações"
               If !lEFFTpMod
                  @0.8,02 SAY   AVSX3("EF1_CONTRA",5) of oDlgMot
                  @0.8,07 MSGET cContra PICT AVSX3("EF1_CONTRA",6) SIZE 60,8 When .F.

                  @0.8,17 SAY   AVSX3("EF1_BAN_FI",5) of oDlgMot
                  @0.8,22 MSGET cBanco PICT AVSX3("EF1_BAN_FI",6) SIZE 60,8 When .F.

                  @0.8,32 SAY   AVSX3("EF1_PRACA",5) of oDlgMot
                  @0.8,37 MSGET cPraca PICT AVSX3("EF1_PRACA",6) SIZE 60,8 When .F.

                  @1.9,02 SAY   AVSX3("EEC_PREEMB",5) of oDlgMot
                  @1.9,07 MSGET cPreemb PICT AVSX3("EEC_PREEMB",6) SIZE 60,8 When .F.

                  @1.9,17 SAY   AVSX3("EF3_INVOIC",5) of oDlgMot
                  @1.9,22 MSGET cInvoice PICT AVSX3("EF3_INVOIC",6) SIZE 60,8 When .F.

                  @1.9,32 SAY   AVSX3("EF3_PARC",5) of oDlgMot
                  @1.9,37 MSGET cParc PICT AVSX3("EF3_PARC",6) SIZE 60,8 When .F.

                  @3.0,02 SAY   AVSX3("EF3_CODEVE",5) of oDlgMot
                  @3.0,07 MSGET cEve PICT AVSX3("EF3_CODEVE",6) SIZE 60,8 When .F.

                  @3.0,17 SAY   AVSX3("EF3_DESCEVE",5) of oDlgMot
                  @3.0,22 MSGET cDesc PICT AVSX3("EF3_DESCEVE",6) SIZE 90,8 When .F.

                  @5.1,02 SAY   AVSX3("EF4_MOTIVO",5) of oDlgMot
                  //@5.1,07 MSGET cMot PICT AVSX3("EF4_MOTIVO",6) Valid !Empty(cMot) SIZE 250,8

                  /* LDB 25/04/2006 */
                  @5.1,07 MSGET oGetMot Var cMot PICT AVSX3("EF4_MOTIVO",6) Valid !Empty(cMot) SIZE 250,8

               Else
                  @0.8,02 SAY   AVSX3("EF1_CONTRA",5) of oDlgMot
                  @0.8,07 MSGET cContra PICT AVSX3("EF1_CONTRA",6) SIZE 60,8 When .F.

                  @0.8,17 SAY   AVSX3("WB_TP_CON",5) of oDlgMot
                  @0.8,22 MSGET If(cTpModu <> "I",STR0262,STR0263) PICT AVSX3("EF1_CONTRA",6) SIZE 60,8 When .F.  //"Exportação" ## "Importação"

                  @0.8,32 SAY   AVSX3("EF1_SEQCNT",5) of oDlgMot
                  @0.8,37 MSGET cSeqCon PICT AVSX3("EF1_SEQCNT",6) SIZE 60,8 When .F.

                  @1.9,02 SAY   AVSX3("EF1_BAN_FI",5) of oDlgMot
                  @1.9,07 MSGET cBanco PICT AVSX3("EF1_BAN_FI",6) SIZE 60,8 When .F.

                  @1.9,17 SAY   AVSX3("EF1_PRACA",5) of oDlgMot
                  @1.9,22 MSGET cPraca PICT AVSX3("EF1_PRACA",6) SIZE 60,8 When .F.

                  @3.0,02 SAY   AVSX3("EEC_PREEMB",5) of oDlgMot
                  @3.0,07 MSGET cPreemb PICT AVSX3("EEC_PREEMB",6) SIZE 60,8 When .F.

                  @3.0,17 SAY   AVSX3("EF3_INVOIC",5) of oDlgMot
                  @3.0,22 MSGET cInvoice PICT AVSX3("EF3_INVOIC",6) SIZE 60,8 When .F.

                  @3.0,32 SAY   AVSX3("EF3_PARC",5) of oDlgMot
                  @3.0,37 MSGET cParc PICT AVSX3("EF3_PARC",6) SIZE 60,8 When .F.

                  If cOrigem == "SWB"
                     @4.1,02 SAY   AVSX3("EF3_FORN",5) of oDlgMot
                     @4.1,07 MSGET cForn PICT AVSX3("EEC_PREEMB",6) SIZE 60,8 When .F.

                     @4.1,17 SAY   AVSX3("EF3_LOJAFO",5) of oDlgMot
                     @4.1,22 MSGET cLoja PICT AVSX3("EF3_INVOIC",6) SIZE 60,8 When .F.

                     @5.2,02 SAY   AVSX3("EF3_CODEVE",5) of oDlgMot
                     @5.2,07 MSGET cEve PICT AVSX3("EF3_CODEVE",6) SIZE 60,8 When .F.

                     @5.2,17 SAY   AVSX3("EF3_DESCEVE",5) of oDlgMot
                     @5.2,22 MSGET cDesc PICT AVSX3("EF3_DESCEVE",6) SIZE 90,8 When .F.
                  Else
                     @4.1,02 SAY   AVSX3("EF3_CODEVE",5) of oDlgMot
                     @4.1,07 MSGET cEve PICT AVSX3("EF3_CODEVE",6) SIZE 60,8 When .F.

                     @4.1,17 SAY   AVSX3("EF3_DESCEVE",5) of oDlgMot
                     @4.1,22 MSGET cDesc PICT AVSX3("EF3_DESCEVE",6) SIZE 90,8 When .F.

                  EndIf

                  @7.4,02 SAY   AVSX3("EF4_MOTIVO",5) of oDlgMot
                  //@7.4,07 MSGET cMot PICT AVSX3("EF4_MOTIVO",6) Valid !Empty(cMot) SIZE 250,8

                  /* LDB 25/04/2006 */
                  @7.4,07 MSGET oGetMot Var cMot PICT AVSX3("EF4_MOTIVO",6) Valid !Empty(cMot) SIZE 250,8

               EndIf

               If(EasyEntryPoint("EFFEX400A"),ExecBlock("EFFEX400A",.F.,.F.,"TELA_MOTIVO_ESTORNO"),)

               DEFINE SBUTTON FROM 95,335 TYPE 1 ACTION If(!Empty(cMot),(nOpc:=1,oDlgMot:End()),MsgInfo(STR0168)) ENABLE OF oDlgMot //"O preenchimento do motivo é obirgatório."

            ACTIVATE MSDIALOG oDlgMot CENTERED// ON INIT EnchoiceBar(oDlgMot,{||nOpc:=1, oDlgMot:End()},{||nOpc:=0,oDlgMot:End()})
         EndDo
      endif
   Else
      nOpc := 1
   EndIf
ELSE  //HVR 24/04/06 - Não Mostra a Tela se o Motivo já foi preenchido
   cMot := cMotivo //HVR grava o mesmo motivo para o EF4 informado.
   nOpc := 1
ENDIF //HVR***

If nOpc = 1
   EF4->(RecLock("EF4",.T.))
   EF4->EF4_FILIAL := xFilial("EF4")
   EF4->EF4_CONTRA := cContra
   If lTemChave
      EF4->EF4_BAN_FI := cBanco
      EF4->EF4_PRACA  := cPraca
      If lEFFTpMod
         EF4->EF4_TPMODU := cTpModu
         EF4->EF4_SEQCNT := cSeqCon
      EndIf
   Endif
   EF4->EF4_TP_EVE := cTpEve
   EF4->EF4_CAMPO  := "ESTORNO"
   EF4->EF4_PREEMB := cPreemb
   EF4->EF4_INVOIC := cInvoice
   EF4->EF4_PARC   := cParc
   EF4->EF4_CODEVE := cEve
   EF4->EF4_SEQ    := cSeq

   IF cTipo == "LIQ"
      EF4->EF4_DE     := STR0196 //"Estorno da Liquidação"
      EF4->EF4_PARA   := STR0196 //"Estorno da Liquidação"
   ELSEIF cTipo == "FFC"
      EF4->EF4_DE     := EX401STR(80) + cFFCMot  //"Estorno da Liquidação do FFC "
      EF4->EF4_PARA   := EX401STR(80) + cFFCMot  //"Estorno da Liquidação do FFC "
   ELSE
      EF4->EF4_DE     := EX401STR(79) //"Estorno da Vinculação"
      EF4->EF4_PARA   := EX401STR(79) //"Estorno da Vinculação"
   ENDIF

   If lEF4_MOTIVO
      EF4->EF4_MOTIVO := cMot
   EndIf
   EF4->EF4_USUARI := cUserName
   EF4->EF4_DATA   := dDataBase
   EF4->EF4_HORA   := SubStr(Time(),1,5)
   EF4->( MsUnLock() )
EndIf

Return (cMot) //HVR 24/04/06 - Retorna cMot para identificar que o Motivo já foi preenchido e reautilizalo

*---------------------------------------------------------------------------------------------------*
Function EX400BusJur(cAliasEF2,cAliasEF1)
*---------------------------------------------------------------------------------------------------*
Local aArrayAux:={}, nOrdEF2:=If(cAliasEF2 == "WorkEF2", ,EF2->(IndexOrd()))
Local aWorkEF2 := SaveOrd({cAliasEF2})

lEF2_INVOIC := EF2->(FieldPos("EF2_INVOIC")) > 0 .and. EF2->(FieldPos("EF2_PARC")) > 0 .and.;
               EF2->(FieldPos("EF2_FILORI")) > 0

SX3->(DbSetOrder(2))
lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
             SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
             SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
             SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
             SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
             SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI")) .and.;
             SX3->(DBSeek("ECE_BANCO"))  .and. SX3->(DBSeek("ECE_PRACA"))  .and.;
             SX3->(DBSeek("EF3_OBS"))    .and. SX3->(DBSeek("EF3_NROP"))
SX3->(DbSetOrder(1))

If cAliasEF2 == "WorkEF2"

   WorkEF2->(dbGoTop()) //AAF 28/08/2015 - Não precisa incluir o restante da chave. Deve carregar todos os tipos de juros para todo tipo de invoice e financiamento.
   //WorkEF2->(dbSeek(If(lEF2_INVOIC,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC)),"")+If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN)))

   Do While !WorkEF2->(EOF()) //.and. WorkEF2->EF2_TP_FIN==If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN) //AAF 28/08/2015 - Não precisa incluir o restante da chave. Deve carregar todos os tipos de juros para todo tipo de invoice e financiamento.
      If aScan(aArrayAux,Alltrim(WorkEF2->EF2_TIPJUR)) = 0
         aAdd(aArrayAux,Alltrim(WorkEF2->EF2_TIPJUR))
      EndIf
      WorkEF2->(dbSkip())
   EndDo
Else
   EF2->(dbSetOrder(2))
   EF2->(dbSeek(xFilial("EF2")+If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA,If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA)+;
                        If(lTemChave, If(cAliasEF1=="M",M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,"")),"")))
						/* AAF 28/08/2015 - Não precisa incluir o restante da chave. Deve carregar todos os tipos de juros para todo tipo de invoice e financiamento.
						+
                        If(lEF2_INVOIC,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC)),"")+;
                        If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN)))
						*/
   Do While !EF2->(EOF()) .and. If(lEFFTpMod,EF2->EF2_TPMODU,"")+EF2->EF2_CONTRA==If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA,If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA) .and.;
   If(lTemChave, If(cAliasEF1=="M",M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""))==EF2->EF2_BAN_FI+EF2->EF2_PRACA+If(lEFFTpMod,EF2->EF2_SEQCNT,""),.T.)
   /* AAF 28/08/2015 - Não precisa incluir o restante da chave. Deve carregar todos os tipos de juros para todo tipo de invoice e financiamento.
   .and.;
   EF2->EF2_TP_FIN==If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN)
   */
      If aScan(aArrayAux,Alltrim(EF2->EF2_TIPJUR)) = 0
         aAdd(aArrayAux,Alltrim(EF2->EF2_TIPJUR))
      EndIf
      EF2->(dbSkip())
   EndDo
   EF2->(dbSetOrder(nOrdEF2))
EndIf

RestOrd(aWorkEF2,.T.)

Return aArrayAux

*-----------------------------------------------------------------------------------------------*
Function EX400VCCom()
*-----------------------------------------------------------------------------------------------*
Local nOrdEF3:=WorkEF3->(IndexOrd()), cInvoice:=WorkEF3->EF3_INVOIC, cParcela:=WorkEF3->EF3_PARC
Local nRecEF3:=WorkEF3->(RecNo()), nValRea:=0, cSeq, cFilOri:=""
Local nTx1:=0, nTx2:=0, nTx:=0, nTxAtu:=0, dDtAux1:=AvCtoD("  /  /  "), dDtAux2:=AvCtoD("  /  /  ")
Local nDecValor := AVSX3("EF3_VL_MOE",4)

WorkEF3->(dbSetOrder(2))
/*WorkEF3->(dbSeek(EV_COM_FIN+cInvoice+cParcela))   //Pesquisa 140
nValCom += WorkEF3->EF3_VL_MOE
nValRea += WorkEF3->EF3_VL_REA*/

/*If WorkEF3->(dbSeek(EV_D_COM_FIN+cInvoice+cParcela))   //Pesquisa 808
   nValCom -= WorkEF3->EF3_VL_MOE
   nValRea -= WorkEF3->EF3_VL_REA
EndIf*/

If WorkEF3->(AvSeekLast(EV_VC_COM_FIN_S+cInvoice+cParcela))   //Pesquisa 596
   dDtAux1 := WorkEF3->EF3_DT_EVE
   nTx1    := WorkEF3->EF3_TX_MOE
EndIf

If WorkEF3->(AvSeekLast(EV_VC_COM_FIN_D+cInvoice+cParcela))   //Pesquisa 597
   dDtAux2 := WorkEF3->EF3_DT_EVE
   nTx2    := WorkEF3->EF3_TX_MOE
EndIf

If Empty(dDtAux1) .and. Empty(dDtAux2)
   WorkEF3->(dbSeek(EV_COM_FIN+cInvoice+cParcela))   //Pesquisa 140
   nTx := WorkEF3->EF3_TX_MOE
ElseIf dDtAux1 > dDtAux2
   nTx := nTx1
Else
   nTx := nTx2
EndIf

WorkEF3->(dbSetOrder(nOrdEF3))
WorkEF3->(dbGoTo(nRecEF3))   //Volta para o 615

nValRea  := WorkEF3->EF3_VL_REA - Round(WorkEF3->EF3_VL_MOE * nTx,nDecValor)
nTxAtu   := WorkEF3->EF3_TX_MOE
cInvoice := WorkEF3->EF3_INVOIC
cPreemb  := WorkEF3->EF3_PREEMB
cMoeInv  := WorkEF3->EF3_MOE_IN
cParc    := WorkEF3->EF3_PARC
If lMultiFil
   cFilOri := WorkEF3->EF3_FILORI
EndIf

If nValRea <> 0
   cSeq  := BuscaEF3Seq("WorkEF3")

   //Grava Evento 596/597 - V.C. da Comissão
   WorkEF3->(RecLock("WorkEF3",.T.))

   WorkEF3->EF3_FILIAL := xFilial("EF3")
   If lMultiFil
      WorkEF3->EF3_FILORI := cFilOri
   EndIf
   If lEFFTpMod
      WorkEF3->EF3_TPMODU := M->EF1_TPMODU
   EndIf
   WorkEF3->EF3_CONTRA := M->EF1_CONTRA
   If lTemChave
      WorkEF3->EF3_BANC   := M->EF1_BAN_FI
      WorkEF3->EF3_AGEN   := M->EF1_AGENFI
      WorkEF3->EF3_NCON   := M->EF1_NCONFI
      WorkEF3->EF3_PRACA  := M->EF1_PRACA
      WorkEF3->EF3_BAN_FI := M->EF1_BAN_FI
      WorkEF3->EF3_AGENFI := M->EF1_AGENFI
      WorkEF3->EF3_NCONFI := M->EF1_NCONFI
      If lEFFTpMod
         WorkEF3->EF3_SEQCNT := M->EF1_SEQCNT
      EndIf
   Endif
   WorkEF3->EF3_INVOIC := cInvoice
   WorkEF3->EF3_PREEMB := cPreemb
//   WorkEF3->EF3_VL_INV := nValCom
   WorkEF3->EF3_MOE_IN := cMoeInv
   WorkEF3->EF3_PARC   := cParc
   WorkEF3->EF3_CODEVE := If(nValRea > 0, EV_VC_COM_FIN_S, EV_VC_COM_FIN_D)
//   WorkEF3->EF3_VL_MOE := nValCom
   WorkEF3->EF3_VL_REA := nValRea
   WorkEF3->EF3_TX_MOE := nTxAtu
//   WorkEF3->EF3_TX_CON := WorkEF3->EF3_VL_REA / WorkEF3->EF3_VL_INV
   WorkEF3->EF3_DT_EVE := dDataBase
   WorkEF3->EF3_DT_CIN := dDataBase
   WorkEF3->EF3_SEQ    := cSeq
   WorkEF3->TRB_ALI_WT := "EF3"
   WorkEF3->TRB_REC_WT := 0

   //FSM - 23/04/2012
   WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

   WorkEF3->(msUnlock())
   If lCadFin
      EX401GrEncargos("WorkEF3")
   EndIf
EndIf

Return .T.

Function EX400DElOK()

/*If !aCols[n,Len(aHeader)+2]
   aCols[n,Len(aHeader)+2] := .T.
Else
   aCols[n,Len(aHeader)+2] := .F.
EndIf*/

Return .T.

*--------------------------------------------------------------------------------------------------*
Function EX400FldOpt()
*--------------------------------------------------------------------------------------------------*

If(oEnc:oBox:nOption = 4, MsgInfo(EX401STR(81)), MsgInfo(EX401STR(82)))  //"Opção 4"  ##  "Outra Opção"

Return .T.

//Adiciona no aHeader com os campos de usuário/não usados
Static Function AddHeader(aHeader)

AAdd(aHeader, { "Relacao", "EF8_TP_REL", AVSX3("EF8_TP_REL", 06), AVSX3("EF8_TP_REL", 03), 0, "" , NIL, "C", NIL, NIL})

Return Nil

//Alimenta os campos de descrição
Static Function SetCols(aItCols, lCopiaCont)
Local aCpos := {{"EF8_CODEVE", "EF8_DESEVE"},;
                {"EF8_CODEAS", "EF8_DESEAS"},;
                {"EF8_CODEBA", "EF8_DESEBA"}}
Local nInc, i
Local nLin
Default aItCols = aCols
Default lCopiaCont = .F.

nLin := Len(aItCols)

For i := 1 To nLin
   For nInc := 1 To Len(aCpos)
      If GdFieldPos(aCpos[nInc][1]) > 0 .And. GdFieldPos(aCpos[nInc][2]) > 0
         aItCols[i][GdFieldPos(aCpos[nInc][2])] := Eval(bDescEve, aItCols[i][GdFieldPos(aCpos[nInc][1])])
      EndIf
   Next nInc
   /*
   aAdd(aItCols[nLin], Nil)
   aIns(aItCols[nLin], Len(aHeader)+1)
   aItCols[nLin][Len(aHeader)+1] := If(lCopiaCont, 0, EF8->(Recno()))
   */
Next i

Return Nil
*/
/*
Função     : MontCols()
Objetivos  : Alimentar o aCols que será utilizado na rotina de baixa de juros e estorno de baixa de juros.
Parâmetros : cOpc - Indica de onde a função foi chamada.
Retorno    : Nenhum
Autor      : Rodrigo Mendes Diaz
Data       : 01/03/06
*/
Static Function MontCols(cOpc,nRecPosAtu)
Local cAlias := "WorkEF3", cCpo
Local nInc, nLin
Local nTxDiaSug

Default nRecPosAtu := (cAlias)->(recno())
Default cOpc := ""

Begin Sequence
   If !(cOpc $ "BAIXA/ESTORNO")
      Break
   EndIf

   (cAlias)->(DBGotop())

   Do While (cAlias)->(!Eof())                                                                                               //NCF - 08/11/2013 - Permitir liquidar juros do Pré-Pagamento antecipadamente sem recálculo dos juros
      If EX400EVJuros((cAlias)->EF3_CODEVE) //(Left((cAlias)->EF3_CODEVE,2) == Left(EV_LIQ_JUR,2) .or. Left((cAlias)->EF3_CODEVE,2) == Left(EV_LIQ_JUR_FC,2) .or. Left((cAlias)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2) ) //convertido para função para ser reutilizada do EFFEX401
         If cOpc == "BAIXA"
            If !(EMPTY((cAlias)->EF3_TX_MOE) .and. !Empty((cAlias)->EF3_VL_MOE))
               (cAlias)->(DBSkip())
               Loop
            EndIf
         EndIf
         If cOpc == "ESTORNO"
            If EMPTY((cAlias)->EF3_TX_MOE)
               (cAlias)->(DBSkip())
               Loop
            EndIf
         EndIf
         aAdd(aCols,Array(Len(aHeader)+4))
         nLin := Len(aCols)

         If SX5->(dbSeek(xFilial("SX5")+"CV"+Right(WorkEF3->EF3_CODEVE,1)))
            For nInc := 1 To Len(aHeader)
               cCpo := AllTrim(aHeader[nInc][2])
               If Type(cAlias+"->"+cCpo) <> "U"
                  aCols[nLin][nInc] := &(cAlias+"->"+cCpo)
               Else
                  If(cCpo == "EF2_TIPJUR", aCols[nLin][nInc] := Alltrim(X5Descri()), )
                  If(cCpo == "STATUS", aCols[nLin][nInc] := "", )
                  If(cCpo == "EF3_ALI_WT", aCols[nLin][nInc] := "EF3", )
                  If(cCpo == "EF3_REC_WT", aCols[nLin][nInc] := (cAlias)->EF3_RECNO,)
               EndIf
            Next
            aCols[nLin, Len(aHeader) + 1] := .f.
            aCols[nLin, Len(aHeader) + 2] := (cAlias)->(RecNo())
            aCols[nLin, Len(aHeader) + 3] := (cAlias)->EF3_SEQ
            aCols[nLin, Len(aHeader) + 4] := (cAlias)->EF3_CODEVE
            //NCF - 15/01/2015 - Sugerir taxa do dia na liquidação de juros.
            if cOpc == "ESTORNO" 
                  aCols[nLin][ aScan( aHeader,   {|x| x[2] ==  "EF3_TX_MOE"} )  ] := (cAlias)->EF3_TX_MOE
                  aCols[nLin][AScan(aHeader, {|x| AllTrim(x[2]) == "EF3_VL_REA"})]:= (cAlias)->EF3_VL_REA
            else
                  If ( nTxDiaSug := BuscaTaxa( (cAlias)->EF3_MOE_IN ,  dDataBase ,        ,.T.       ,         ,       , '1') ) <> NIL .And. nRecPosAtu == (cAlias)->(RecNo())  // NCF - 17/04/2018 - sugerir apens para a parcela posicionada.
                        aCols[nLin][ aScan( aHeader,   {|x| x[2] ==  "EF3_TX_MOE"} )  ] := nTxDiaSug

                        //Gatilha o valor em Reais, com base na taxa sugeriad
                        aCols[nLin][AScan(aHeader, {|x| AllTrim(x[2]) == "EF3_VL_REA"})]:= nTxDiaSug * aCols[nLin][AScan(aHeader, {|x| x[2] == "EF3_VL_MOE"})]
                  EndIf
            endif

            //Informações do banco para baixa
            If AScan(aHeader, {|x| AllTrim(x[2]) == "EF3_BANC"}) > 0
               aCols[nLin][AScan(aHeader, {|x| AllTrim(x[2]) == "EF3_BANC"})]:= (cAlias)->EF3_BANC
               aCols[nLin][AScan(aHeader, {|x| AllTrim(x[2]) == "EF3_AGEN"})]:= (cAlias)->EF3_AGEN
               aCols[nLin][AScan(aHeader, {|x| AllTrim(x[2]) == "EF3_NCON"})]:= (cAlias)->EF3_NCON
            EndIf
         EndIf
      Endif
      (cAlias)->(DBSkip())
   Enddo

End Sequence

Return Nil
*---------------------------------*
Static Function EX400GerAdian(nOpc)
*---------------------------------*
Local lRet   := .T.
Local nParc  := 1
Local nSaldo := 0

Begin Sequence

   WorkEF3->(dbSetOrder(2))
   If WorkEF3->(dbSeek(EV_PRINC))

      EEQ->(DbSetOrder(1))
      If EEQ->(AvSeekLast(xFilial("EEQ")+AvKey(AvKey(M->EF1_CLIENT,"A1_COD") + AvKey(M->EF1_CLLOJA,"A1_LOJA"),"EEQ_PREEMB")))
         nParc := Val(EEQ->EEQ_PARC)
         nParc++
      EndIf

      If nOpc == INCLUIR
         EEQ->(RecLock("EEQ",.T.))
         cOperac := "EFF_MNCT_INC"
      Else

         EEQ->(DbSetOrder(4))
         If EEQ->(DbSeek(xFilial("EEQ")+AvKey(M->EF1_CONTRA,"EEQ_NRINVO")+AvKey(AvKey(M->EF1_CLIENT,"A1_COD") + AvKey(M->EF1_CLLOJA,"A1_LOJA"),"EEQ_PREEMB")))
            EEQ->(RecLock("EEQ",.F.))
            cOperac := "EFF_MNCT_ALT"
            nSaldo := WorkEF3->EF3_VL_MOE - EEQ->EEQ_VL

         Else
            EEQ->(RecLock("EEQ",.T.))
            cOperac := "EFF_MNCT_INC"
         EndIf
      EndIf

      //NCF - 27/08/2014 - Fazer backup do EEQ caso seja alteração da parcela de adiantamento
      If lLogix
         If cOperac == "EFF_ALT"
            AF200BkpInt("EEQ",cOperac,,{'EF1',EF1->(Recno())},,)
         EndIf
      EndIf

      ////////////////////////////
      //Gravação do Adiantamento//
      ////////////////////////////

      EEQ->EEQ_FILIAL := xFilial("EEQ")
      EEQ->EEQ_PREEMB := AvKey(M->EF1_CLIENT,"A1_COD") + AvKey(M->EF1_CLLOJA,"A1_LOJA")
      EEQ->EEQ_FASE   := "C"
      EEQ->EEQ_TIPO   := "A"
      EEQ->EEQ_FAOR   := "F"
      EEQ->EEQ_PARC   := "01"
      EEQ->EEQ_EVENT  := "605"
      EEQ->EEQ_NRINVO := M->EF1_CONTRA
      EEQ->EEQ_PARC   := AvKey(StrZero(nParc,2,0),"EEQ_PARC")
      EEQ->EEQ_MOEDA  := M->EF1_MOEDA
      EEQ->EEQ_VL     := WorkEF3->EF3_VL_MOE

      If nSaldo <> 0
         EEQ->EEQ_SALDO := EEQ->EEQ_SALDO + nSaldo
      Else
         EEQ->EEQ_SALDO := WorkEF3->EF3_VL_MOE
      EndIf

      EEQ->EEQ_DTCE   := WorkEF3->EF3_DT_EVE
      EEQ->EEQ_SOL    := WorkEF3->EF3_DT_EVE
      EEQ->EEQ_DTNEGO := M->EF1_DT_CON
      EEQ->EEQ_DECAM  := "2"
      EEQ->EEQ_BANC   := M->EF1_BAN_FI
      EEQ->EEQ_AGEN   := M->EF1_AGENFI
      EEQ->EEQ_NCON   := M->EF1_NCONFI
      EEQ->EEQ_NOMEBC := Posicione("SA6",1,xFilial("SA6")+AvKey(M->EF1_BAN_FI,"A6_COD")+AvKey(M->EF1_AGENFI,"A6_AGENCIA")+AvKey(M->EF1_NCONFI,"A6_NUMCON"),"A6_NOME")
      EEQ->EEQ_IMPORT := AvKey(M->EF1_CLIENT,"A1_COD")
      EEQ->EEQ_IMLOJA := AvKey(M->EF1_CLLOJA,"A1_LOJA")
      EEQ->EEQ_OBS    := M->EF1_CONTRA
      EEQ->EEQ_TP_CON := "1"

      EEQ->(MsUnlock())

      //NCF - 27/08/2014 - Fazer backup do EEQ caso seja inclusão da parcela de adiantamento
      If lLogix
         If cOperac == "EFF_MNCT_INC"
            AF200BkpInt("EEQ",cOperac,,{'EF1',EF1->(Recno())},,)
         EndIf
      EndIf

   EndIf

End Sequence

Return lRet


*--------------------------------------*
Function EX400AdEFF(cFaseOr,cPrOr,cPaOr)
*--------------------------------------*
Local lRet := .F.
Local aOrd := SaveOrd({"EEQ"})

Begin Sequence

   EEQ->(DbSetOrder(6))
   If EEQ->(DbSeek(xFilial("EEQ")+AvKey(cFaseOr,"EEQ_FASE")+AvKey(cPrOr,"EEQ_PREEMB")+AvKey(cPaOr,"EEQ_PARC")))

      If cFaseOr == "C"

         If EEQ->EEQ_FAOR == "F"
            lRet := .T.
            Break
         EndIf

      ElseIf cFaseOr == "P"

         If EEQ->EEQ_FAOR == "C"

            If EX400AdEFF(EEQ->EEQ_FAOR,EEQ->EEQ_PROR,EEQ->EEQ_PAOR)
               lRet := .T.
               Break
            EndIf

         EndIf
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao   : MontaCarga
Objetivo : Monta a estrutura para a carga dos eventos de financiamento.
Autor    : Felipe S. Martinez - FSM
Data     : 09/04/2012
*/
Static Function MontaCarga(lPosNeg)
Local aCarga := {}
Default lPosNeg := .F.

//                 Tip.Financ  ,Eventos     ,Descricao              , "EC6_FINANC" , "EC6_CA_EVE" , "EC6_CONTAB" , "EC6_DIAMES" , "EC6_RATEIO" , "EC6_TXCV" , "EC6_RECDES",Juros
If !lPosNeg
   aCarga :=      { {"FIEX01"  , "100"      ,"ACC Contrato"         ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"2"         ,"1"         , .F. },;
                    {"FIEX02"  , "100"      ,"ACE Contrato"         ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"2"         ,"1"          ,.F. },;
                    {"FIEX03"  , "100"      ,"Pre Pagamento Contra" ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"2"         ,"1"          ,.F. },;
                    {"FIEX04"  , "100"      ,"Securit. Contrato"    ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"2"         ,"1"          ,.F. },;
                    {"FIIM05"  , "100"      ,"FINIMP Contrato"      ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"2"         ,"1"          ,.F. },;
                    {"FIEX01"  , "180"      ,"Encerr Contrato ACC"  ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "180"      ,"Encerr Contrato ACC"  ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "190"      ,"Transf Cont ACC/PREP" ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "190"      ,"Transf Cont ACC/PREP" ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "500"      ,"V.C. ACC"             ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "501"      ,"V.C. ACC"             ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "500"      ,"V.C. ACE"             ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "501"      ,"V.C. ACE"             ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX03"  , "500"      ,"V.C. Principal"       ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX04"  , "500"      ,"V.C. Principal"       ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIIM05"  , "500"      ,"V.C. Principal"       ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX03"  , "501"      ,"V.C. Principal"       ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX04"  , "501"      ,"V.C. Principal"       ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIIM05"  , "501"      ,"V.C. Principal"       ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "600"      ,"Transf.ACC P/ACE"     ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "600"      ,"Invoice Exportacao"   ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX03"  , "600"      ,/*Invoice Exportacao*/"Vinculação Invoice"   ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX04"  , "600"      ,/*Invoice Exportacao*/"Vinculação Invoice"   ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIIM05"  , "600"      ,"Invoice Importacao"   ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "620"      ,"# antecipado"         ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "620"      ,"# antecipado"         ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "630"      ,"Liquidacao Principal" ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "630"      ,"Liquidacao Principal" ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX03"  , "630"      ,/*Liquidacao Principal*/"Liquidação Invoice" 	 ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX04"  , "630"      ,/*Liquidacao Principal*/"Liquidação Invoice"   ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIIM05"  , "630"      ,"Liquidacao Invoice"   ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "660"      ,"Liq Principal Forc"   ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "660"      ,"Liq Principal Forc"   ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "999"      ,"Estorno"              ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "999"      ,"Estorno"              ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX03"  , "999"      ,"Estorno"              ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX04"  , "999"      ,"Estorno"              ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIIM05"  , "999"      ,"Estorno"              ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "510"      ,"Est Prov #"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "510"      ,"Est Prov #"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX03"  , "510"      ,"Est Prov #"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX04"  , "510"      ,"Est Prov #"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIIM05"  , "510"      ,"Est Prov #"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "520"      ,"Prov # ACC"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "520"      ,"Prov # ACE"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX03"  , "520"      ,"Provisao de #"        ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX04"  , "520"      ,"Provisao de #"        ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIIM05"  , "520"      ,"Provisao de #"        ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "640"      ,"Liq. de # "           ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "640"      ,"Liq. de # "           ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX03"  , "640"      ,"Liq. de # "           ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX04"  , "640"      ,"Liq. de # "           ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIIM05"  , "640"      ,"Liq. de # "           ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "650"      ,"Transf # ACE"         ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "650"      ,"Transf #"             ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX03"  , "650"      ,"Transf # ACC/ACE"     ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX04"  , "650"      ,"Transf # ACC/ACE"     ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "670"      ,"Liq # Forc"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "670"      ,"Liq # Forc"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "680"      ,"Liq. # Antecipado"    ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "680"      ,"Liq. # Antecipado"    ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "700"      ,"Parcela do Principal" ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX02"  , "700"      ,"Parcela do Principal" ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX03"  , "700"      ,"Parcela do Principal" ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX04"  , "700"      ,"Parcela do Principal" ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIEX01"  , "710"      ,"Parcela #"            ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "710"      ,"Parcela #"            ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX03"  , "710"      ,"Parcela #"            ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX04"  , "710"      ,"Parcela #"            ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIIM05"  , "700"      ,"Parcela do Principal" ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.F. },;
                    {"FIIM05"  , "710"      ,"Parcela #"            ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIIM05"  , "720"      ,"Diferenca #"          ,"2"           ,"2"           ,"2"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "580"      ,"V.C. # ACC Ant."      ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "580"      ,"V.C. # ACE Ant."      ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "920"      ,"Estorno # "           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "920"      ,"Estorno # "           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. };
                  }
Else
   aCarga :=      { {"FIEX01"  , "050"      ,"V.C. # Antecipado"    ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "050"      ,"V.C. # Antecipado"    ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "550"      ,"V.C. # ACC"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "550"      ,"V.C. # ACE"           ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX03"  , "550"      ,"V.C. #"               ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX04"  , "550"      ,"V.C. #"               ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIIM05"  , "550"      ,"V.C. #"               ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX01"  , "580"      ,"V.C. # ACC Ant."      ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. },;
                    {"FIEX02"  , "580"      ,"V.C. # ACE Ant."      ,"2"           ,"1"           ,"1"           ,"2"           ,"1"           ,"1"         ,"2"          ,.T. };
                  }
EndIf


Return aClone(aCarga)


/*
Funcao   : EX400OrdEventos
Objetivo : Ordena os eventos de acordo com a coluna selecionada.
Autor    : Felipe S. Martinez - FSM
Data     : 24/04/2012
*/
Static Function EX400OrdEventos(oBrw,nCol)
Local cColCpo := ""

If Type("aSelCpos") == "A"
   cColCpo := Upper(AllTrim(aSelCpos[nCol][1]))
EndIf

If cColCpo == "EF3_CODEVE"
   WorkEF3->(DBSetOrder(2)) //"EF3_CODEVE+EF3_INVOIC+EF3_PARC+DtoS(EF3_DT_EVE)"
ElseIf cColCpo == "EF3_SEQ"
   WorkEF3->(DBSetOrder(1)) //"EF3_SEQ+EF3_CODEVE"
ElseIf cColCpo == "EF3_INVOIC"
   WorkEF3->(DBSetOrder(3)) //EF3_INVOIC+EF3_PARC+EF3_PREEMB
ElseIf cColCpo == "EF3_DT_EVE"
   WorkEF3->(DBSetOrder(8)) //DTOS(EF3_DT_EVE)+EF3_EV_VIN+EF3_CODEVE
EndIf

Return .T.

//AAF 19/09/2012 - Retorna a taxa da ultima contabilização do evento
Static Function GetTxCtb(cAliasEF3, cEvento,cTpModu, cInvoice, cParc, dDataEvento)

Local nTx520Ctb, cSeekLast, cNewFilter, cOldEF3Filter, nOldRecEF3, nOldOrdEF3, dDtCtb
Local cQry520Enc := cSeek520En := cEvents := ""

nOldRecEF3 := (cAliasEF3)->(RecNo())
nOldOrdEF3 := (cAliasEF3)->(IndexOrd())

//cSeekLast := cEvento+AvKey(cInvoice,"EF3_INVOIC")+AvKey(cParc,"EF3_PARC")

//If cAliasEF3 == "EF3"

   cQry520Enc := "SELECT EF3_SEQ SEQUENCIA"
   If cAliasEF3 == "EF3"
      cQry520Enc += " FROM "+RetSQLName(cAliasEF3) + " "
   Else
      cQry520Enc += " FROM "+TETempName(cAliasEF3) + " "
   EndIf
   cQry520Enc += " WHERE D_E_L_E_T_ = ' '"      + ;
   " AND EF3_FILIAL = '"+ xFilial("EF3")  + "'" + ;
   " AND EF3_TPMODU = '"+ cTpModu         + "'" + ;
   " AND EF3_CONTRA = '"+ EF1->EF1_CONTRA + "'" + ;
   " AND EF3_BAN_FI = '"+ EF1->EF1_BAN_FI + "'" + ;
   " AND EF3_PRACA  = '"+ EF1->EF1_PRACA  + "'" + ;
   " AND EF3_SEQCNT = '"+ EF1->EF1_SEQCNT + "'" + ;
   " AND EF3_CODEVE = '"+ '190'           + "'"

   cQuery:=ChangeQuery(cQry520Enc)
   TcQuery cQuery ALIAS "SEQ520" NEW
   dbSelectArea("SEQ520")
   //SEQ520->(dbGoTop())
   If SEQ520->(!Eof())
      //cSeek520En += " .And. ( EF3_CODEVE == '520' .And. !( EF3_SEQ $ '"

      Do While SEQ520->(!Eof())
         cEvents += SEQ520->SEQUENCIA + "','"
         SEQ520->(DbSkip())
      EndDo

/*      If cEvents <> ""
         cSeek520En := " .And. ( EF3_CODEVE == '520' .And. !( EF3_SEQ $ '" + cEvents + "') )"
      EndIf
*/
   EndIf
   SEQ520->(dbCloseArea())

/* THTS - 15/09/2017 - NOPADO - MTRADE-1457 - O filtro estava invalidando a Work
   cOldEF3Filter := EF3->(dbFilter())
   cNewFilter    := "EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT == '"+xFilial("EF3")+cTpModu+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+"'"
   cNewFilter    += cSeek520En
   EF3->(dbSetFilter(&("{||"+cNewFilter+"}"),cNewFilter))
*/
   cQuery := "SELECT EF3_TX_MOE, EF3_DT_EVE "
   If cAliasEF3 == "EF3"
      cQuery += " FROM "+RetSQLName(cAliasEF3) + " "
   Else
      cQuery += " FROM "+TETempName(cAliasEF3) + " "
   EndIf
   cQuery += " WHERE D_E_L_E_T_ = ' '"          + ;
   " AND EF3_FILIAL = '"+ xFilial("EF3")  + "'" + ;
   " AND EF3_TPMODU = '"+ cTpModu         + "'" + ;
   " AND EF3_CONTRA = '"+ EF1->EF1_CONTRA + "'" + ;
   " AND EF3_BAN_FI = '"+ EF1->EF1_BAN_FI + "'" + ;
   " AND EF3_PRACA  = '"+ EF1->EF1_PRACA  + "'" + ;
   " AND EF3_SEQCNT = '"+ EF1->EF1_SEQCNT + "'" + ;
   " AND EF3_INVOIC = '"+ AvKey(cInvoice,"EF3_INVOIC") + "'" + ;
   " AND EF3_PARC   = '"+ AvKey(cParc,"EF3_PARC") + "'" + ;
   " AND EF3_CODEVE = '"+ cEvento          + "'" +;
   " AND EF3_SEQ Not In ('" + cEvents + "') "
   If !Empty(dDataEvento)
      cQuery += " AND EF3_DT_EVE <= '"+ DToS(dDataEvento) +"' "
   EndIf
   cQuery += " Order By EF3_DT_EVE Desc"

   cQuery:=ChangeQuery(cQuery)
   TcQuery cQuery ALIAS "QRYEVE" NEW
   dbSelectArea("QRYEVE")

  If QRYEVE->(!Eof())
     nTxCtb := QRYEVE->EF3_TX_MOE
     dDtCtb := STOD(QRYEVE->EF3_DT_EVE)
  Else
     nTxCtb := 0
     dDtCtb := CTOD("  /  /  ")
  EndIf
  QRYEVE->(DbCloseArea())
/*
ElseIf cAliasEF3 == "WorkEF3"

   (cAliasEF3)->(DbGotop())
   Do While (cAliasEF3)->(!Eof())
      If (cAliasEF3)->EF3_CODEVE == '190'
         cEvents +=  (cAliasEF3)->EF3_SEQ + "/"
      EndIf
      (cAliasEF3)->(DbSkip())
   EndDo
*/
/* THTS - 15/09/2017 - NOPADO - MTRADE-1457 - O filtro estava invalidando a Work
   If cEvents <> ""
      cSeek520En := " .And. ( EF3_CODEVE == '520' .And. !( EF3_SEQ $ '" + cEvents + "') )"
   EndIf

   cOldEF3Filter := (cAliasEF3)->(dbFilter())
   cNewFilter    := "EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT == '"+xFilial()+cTpModu+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+"'"
   cNewFilter    += cSeek520En
   (cAliasEF3)->(dbSetFilter(&("{||"+cNewFilter+"}"),cNewFilter))

   cSeekLast := xFilial("EF3")+cTpModu+cSeekLast
*/
   //(cAliasEF3)->(DbGotop())


  //THTS - 15/09/2017 - MTRADE-1457 - Tratamento para ignorar evento caso o mesmo pertenca a uma transferencia (190)
  /*(cAliasEF3)->(dbSetOrder(2))//EF3_CODEVE+EF3_INVOIC+EF3_PARC+DTOS(EF3_DT_EVE)
  If (cAliasEF3)->(AvSeekLast(cSeekLast))
      
      While (cAliasEF3)->(!Bof())
          If (cAliasEF3)->EF3_SEQ $ cEvents
              (cAliasEF3)->(dbSkip(-1))
          Else
              nTxCtb := (cAliasEF3)->EF3_TX_MOE
              dDtCtb := (cAliasEF3)->EF3_DT_EVE
              Exit
          EndIf
      End

  Else
    nTxCtb := 0
    dDtCtb := CTOD("  /  /  ")
  EndIf

EndIf
*/
/*  THTS - 15/09/2017 - NOPADO - MTRADE-1457 - O filtro foi nopado, nao precisa mais limpar
//If cAliasEF3 == "EF3"
   (cAliasEF3)->(dbClearFilter())
   If !Empty(cOldEF3Filter)
      (cAliasEF3)->(dbSetFilter(&("{||"+cOldEF3Filter+"}"),cOldEF3Filter))
   EndIf
//EndIf
*/
(cAliasEF3)->(dbSetOrder(nOldOrdEF3))
(cAliasEF3)->(dbGoTo(nOldRecEF3))

Return {nTxCtb,dDtCtb}


Static Function getFilial(cAlias)
If FWModeAccess(cAlias) == "C" .Or. !lMultifil
      Return "'" + xFilial(cAlias) + "'"
Else // Quando não compartilhado e multifilial
      Return cFil
EndIf

/*
Funcao   : EX400InvoAdiant
Objetivo : Adiciona os adiantamentos a lista de Invoice a serem selecionadas.
Autor    : Felipe S. Martinez - FSM
Data     : 03/10/2012
*/
Static Function EX400InvoAdiant()
Local aOrd := SaveOrd({"EEQ"})
Local cQuery := ""
Local i := 0

EEQ->(DBSetOrder(6)) //FILIAL+FASE+PREEMB+PARC

   cQuery := "SELECT DISTINCT '  ' MARCA, EEQ.EEQ_PREEMB EF3_PREEMB, EEQ.EEQ_NRINVO EF3_INVOIC ,'        ' EF3_DT_FIX,EEQ.EEQ_VCT DT_VEN,EEQ.EEQ_MOEDA EF3_MOE_IN,EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON EF3_VL_INV,'        ' DT_AVERB,EEQ.EEQ_PARC EF3_PARC,"+;
             "EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_ORI,EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_INV,EEQ.EEQ_VL_PAR - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_PAR,EEQ.EEQ_FI_TOT FI_TOT,'  ' TIPCOM,EEQ.EEQ_CGRAFI VALCOM,'   ' TIPCVL,'        ' DT_VINC,0.00 TX_VINC,EEQ.EEQ_BANC BANC_INV,"+;
             "EEQ.EEQ_VL_PAR - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON VL_VINC,0.00 VINCULADO,EEQ.EEQ_PARFIN PARFIN, '  ' DTEMBA,EEQ.EEQ_IMPORT IMPORT, SA1.A1_NOME IMPODE, EEQ.EEQ_IMLOJA IMLOJA , SYA.YA_CODGI PAIS,SYA.YA_DESCR PAISDE,EEQ.EEQ_DTCE DTCE,'EEQ' EF3_ORIGEM,EEQ.EEQ_FILIAL EF3_FILORI,EEQ.EEQ_TIPO TIPO "

   cQuery += " FROM "+RetSqlName("EEQ")+" EEQ, "+RetSqlName("EEC")+" EEC, "+RetSqlName("SA1")+" SA1 left outer join "+RetSqlName("SYA")+" SYA on SYA.YA_FILIAL='"+ xFilial("SYA")+"' and SYA.YA_CODGI=SA1.A1_PAIS AND SYA.D_E_L_E_T_ <> '*' " //AAF 20/01/2017 - Ajuste para trazer mesmo que nao haja pais informado.

   cQuery += " WHERE  EEC.EEC_FILIAL IN (" + getFilial("EEC") + ") AND EEQ.EEQ_FILIAL IN ("+ getFilial("EEQ")+") AND SA1.A1_FILIAL in ("+ getFilial("SA1")+") "+; //Filiais
             " AND EEC.D_E_L_E_T_ <> '*' AND EEQ.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*'"+; //Deletado
             " AND EEQ.EEQ_PREEMB <> EEC.EEC_PREEMB AND EEQ.EEQ_IMPORT = SA1.A1_COD AND EEQ.EEQ_IMLOJA = SA1.A1_LOJA "+; //Relacionamentos
             " AND EEQ.EEQ_PGT = ' ' AND ((EEQ.EEQ_FI_TOT <> 'N' AND EEQ.EEQ_FI_TOT <> 'S') OR (EEQ.EEQ_FI_TOT = 'N' AND EEQ.EEQ_VL_PAR - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON > 0))"+; //outras Condições
             " AND EEQ.EEQ_EVENT <> '101' "

   //Condições do Filtro:
   If !Empty(dVencIni)
      cQuery+=" AND EEQ.EEQ_VCT >= '" + DtoS(dVencIni) + "' "
   Endif
   If !Empty(dVencFim)
      cQuery+=" AND EEQ.EEQ_VCT <= '" + DtoS(dVencFim) + "' "
   Endif
   If !Empty(cInvoice)
      cQuery+=" AND  EEQ.EEQ_NRINVO = '" + Alltrim(cInvoice) + "' "
   Endif
   If !Empty(cProcesso)
      cQuery+=" AND EEQ.EEQ_PREEMB = '" + Alltrim(cProcesso) + "' "
   Endif
   If !Empty(nValIni)
      cQuery+=" AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON >= " + Str(nValIni, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4)) + " "
   Endif
   If !Empty(nValFim)
      cQuery+=" AND EEQ.EEQ_VL - EEQ.EEQ_CGRAFI + EEQ.EEQ_ACRESC - EEQ.EEQ_DECRES + EEQ.EEQ_MULTA + EEQ.EEQ_JUROS - EEQ.EEQ_DESCON <= " + Str(nValFim, AVSX3("EEQ_VL",3), AVSX3("EEQ_VL",4)) + " "
   Endif
   If lEEQ_TP_CON
      cQuery+=" AND (EEQ.EEQ_TP_CON = '1' OR EEQ.EEQ_TP_CON = '3') "
   EndIf
   If !Empty(cCondPagto)
      cQuery+=" AND SA1.A1_CONDPAG = '" + Alltrim(cCondPagto) + "' AND SA1.A1_DIASPAG = " + Str(nDias, AVSX3("A1_DIASPAG",3), AVSX3("A1_DIASPAG",4)) + " "
   Endif
   If !Empty(cImport)
      cQuery+=" AND EEQ.EEQ_IMPORT = '" + Alltrim(cImport) + "' "
   Endif
   If !Empty(cPais)
      cQuery+=" AND SA1.A1_PAIS = '" + Alltrim(cPais) + "' "
   EndIf

   cQuery += " ORDER BY  EEQ.EEQ_PREEMB "

   cQuery:=ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "ADI" NEW

   TcSetField("ADI","EF3_DT_FIX","D")
   TcSetField("ADI","DT_VEN","D")
   TcSetField("ADI","DT_AVERB","D")
   TcSetField("ADI","DT_VINC","D")
   TcSetField("ADI","TX_VINC","N",AVSX3("EF3_VL_INV",3),AVSX3("EF3_VL_INV",4))
   TcSetField("ADI","DTEMBA","D")
   TcSetField("ADI","DTCE","D")

   dbSelectArea("ADI")
   ADI->(dbGoTop())
   Do While !ADI->(EoF())
      WorkInv->(RecLock("WorkInv",.T.))
      FOR i := 1 TO FCount()
         WorkInv->&(ADI->(FIELDNAME(i))) := FieldGet(i)
      NEXT i
      If WorkInv->FI_TOT <> "N"
         WorkInv->VL_VINC := WorkInv->VL_ORI
      Endif
      WorkInv->EF3_FILORI := ADI->EF3_FILORI
      WorkInv->TRB_ALI_WT := "EEQ"
      WorkInv->TRB_REC_WT := 0

      WorkInv->(msUnlock())
      ADI->(dbSkip())
   EndDo

   ADI->(dbCloseArea())

RestOrd(aOrd)
Return Nil

/*
Funcao   : EX400ValAdiant
Objetivo : Valida se a invoice de Adiantamento esta correta
Autor    : Felipe S. Martinez - FSM
Data     : 04/10/2012
*/
Static Function EX400ValAdiant(cInvo, cPreemb)
Local lRet     := .T.
Default cInvo  := IIF(cMod==IMP, WorkInv->EF3_INVIMP, WorkInv->EF3_INVOIC)
Default cPreemb:= IIF(cMod==IMP, WorkInv->EF3_HAWB  , WorkInv->EF3_PREEMB)

If Empty(cInvo)
   EasyHelp(STR0280+AllTrim(cPreemb)+STR0281, STR0098) //#STR0280 - >"O processo " ##->" não possui o número de Invoice." ###STR0098->"Atenção"
   lRet := .F.
EndIf

Return lRet

/*
Funcao   : EX400BxTFin
Objetivo : Verifica se existe portador para Baixa
Retorno  : aRet, onde:
           aRet[1]    := Tipo Lógico que indica se o título está vinculado a contrato de Financiamento.
           aRet[2][1] := Tipo Caracter - Portador da Baixa cadastrado em "Tipos de Financiamento"
           aREt[2][2] := Tipo Carcater - Tipo do Portador da Baixa cadastrado em "Tipos de Financiamento"
Autor    : Nilson César
Data     : 12/11/2013
*/
*--------------------*
Function EX400BxTFin()
*--------------------*
Local aTitBxPort := {.F.,{"",""}}
Local aOrd := SaveOrd({"EF3","EF1"}) //FSM - 21/03/2012

Begin Sequence

   EF3->(dbSetOrder(2))
   If EF3->(dbSeek(xFilial("EF3")+if(EEQ->EEQ_TP_CON $ ("2/4"),"I","E")+"600"+EEQ->(EEQ_NRINVO+EEQ->EEQ_PARC)) )
      aTitBxPort[1] := .T.
      EF1->( DbSetOrder(1) ) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
      If EF1->( DbSeek( xFilial("EF3")+EF3->EF3_TPMODU+EF3->EF3_CONTRA+EF3->EF3_BAN_FI+EF3->EF3_PRACA+EF3->EF3_SEQCNT ) )
         //NCF - 15/01/2014 - Busca o portador e tipo de portador da conta principal do banco de movimento do contrato
         //                   quando a cambial é vinculada a contrato de financiamento
         aTitBxPort[2][1] := EasyHolderCode(EF1->EF1_BAN_FI ,EF1->EF1_AGENFI,EF1->EF1_NCONFI,EF1->EF1_BAN_MO,EF1->EF1_AGENMO,EF1->EF1_NCONMO,"FIEX"+EF1->EF1_TP_FIN,EC6->EC6_ID_CAM,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,"1"    )
         aTitBxPort[2][2] := EasyTypeHolder(EF1->EF1_BAN_FI ,EF1->EF1_AGENFI,EF1->EF1_NCONFI,EF1->EF1_BAN_MO,EF1->EF1_AGENMO,EF1->EF1_NCONMO,"FIEX"+EF1->EF1_TP_FIN,EC6->EC6_ID_CAM,EEQ->EEQ_IMPORT,EEQ->EEQ_IMLOJA,EEQ->EEQ_FORN,EEQ->EEQ_FOLOJA,"1"    )
         //NCF - 15/01/2014 - Caso não encontre, busca o portador e tipo de portador no cadastro de tipo de contrato
         If Empty(aTitBxPort[2][1]) .Or. Empty(aTitBxPort[2][2])
            If EF7->(FieldPos("EF7_PORTAD")) > 0
               aTitBxPort[2][1] := Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_PORTAD")
            EndIf
            If EF7->(FieldPos("EF7_TPPORT")) > 0
               aTitBxPort[2][2] := Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_TPPORT")
            EndIf
         EndIf

      EndIf
   EndIf

End Sequence

RestOrd(aOrd)

Return aTitBxPort

*---------------------------*
 Function ExGerEvAlJur(nDif)
*---------------------------*
//WorkEF3->EF3_NR_CON -> numero da contabilizacao
Local aNovaParc:={}
Local cSeqEF3:=BuscaEF3Seq()
Local ni,cEvGerador,cDscEvGera,cParcEvGer

If nDif # 0

   WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WORKEF3->EF3_CODEVE) //LRS - 20/02/18 - Gravar novamente a descricao da despesa 710
   FOR ni := 1 TO WorkEF3->(FCount())
      aAdd(aNovaParc,WorkEF3->&(FIELDNAME(ni)))
   NEXT ni
   cEvGerador := WORKEF3->EF3_CODEVE
   cParcEvGer := WORKEF3->EF3_PARC
   cDscEvGera := Posicione("EC6",1,xFilial("EC6")+If(!lEFFTpMod .OR. M->EF1_TPMODU <> IMP,"FIEX","FIIM")+M->EF1_TP_FIN+WorkEF3->EF3_CODEVE,"EC6_DESC")
   WorkEF3->(RecLock("WorkEF3",.T.))
   FOR ni := 1 TO WorkEF3->(FCount())
      WorkEF3->&(FIELDNAME(ni)) := aNovaParc[ni]
   NEXT ni
   WORKEF3->EF3_CODEVE := AllTrim(Str(720+if(nDif>=0,0,1)+Val(Right(cEvGerador,1))*2))
   WorkEF3->EF3_DT_EVE := WorkEF3->EF3_DT_EVE + 1
   WorkEF3->EF3_VL_MOE := nDif
   WorkEF3->EF3_VL_REA := nDif * WorkEF3->EF3_TX_MOE
   WorkEF3->EF3_SEQ    := cSeqEF3
   WorkEF3->EF3_EV_VIN := EV_JUROS_PREPAG
   WorkEF3->EF3_DESCEV := EX400DescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)
   WorkEF3->EF3_PARVIN := cParcEvGer
   WorkEF3->EF3_NUMTIT := "" //LRS - 15/02/2018 - Não salvar o mesmo numero do titulo original 
   WorkEF3->EF3_RECNO := 0 //LRS - 15/02/2018 - Nao salvar o mesmo recno do titulo original
   WorkEF3->EF3_TITFIN := ""
   WorkEF3->(msUnlock())

EndIf

Return

/*
Funcao     : EX400CalcVlr()
Parametros : cEvento
Retorno    : nValor
Objetivos  : Calcula valor do evento
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 28/07/2014 :: 17:19
*/
*----------------------------------------*
Function EX400CalcVlr(cEvento,lWork,nSaldo,nTx)
*----------------------------------------*
Local aOrd := {}, nValor := 0, nSldPrc := 0, cTpJur := "", cAliasEF3 := "", lMemory := .F., cChave := "", cIndice := "", dDtCont := CTOD("")
Default lWork := .T.

cAliasEF3 := If(lWork,"WORKEF3","EF3")
lMemory   := If(cAliasEF3 == "EF3",.F.,.T.)
aOrd := SaveOrd({cAliasEF3,"EF2"})
EF2->(dbSetOrder(2))
/* RMD - 02/12/14 - Chave incorreta, falta o número do contrato
(cAliasEF3)->(DbSetOrder(If(cAliasEF3 == "EF3",2,5)))
cIndice := If(cAliasEF3 == "EF3","EF3_FILIAL+EF3_TPMODU","")
*/
(cAliasEF3)->(DbSetOrder(If(cAliasEF3 == "EF3",1,5)))
cIndice := If(cAliasEF3 == "EF3","EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE","")

dDtCont := If(!Empty(EF1->EF1_DT_CTB),EF1->EF1_DT_CTB,CTOD(""))
If cEvento $ "500"
   cEvento := If(!Empty(EF1->EF1_DT_CTB),cEvento,"100")
EndIf
//RMD - 02/12/14 - Corrigida a chave
If (cAliasEF3)->(DbSeek(If(cAliasEF3 == "EF3",xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),"")+cEvento)) .OR. (cAliasEF3)->(DbSeek(If(cAliasEF3 == "EF3",xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),"")+"100"))
   cChave := If(!Empty(cIndice),((cAliasEF3)->(&(cIndice))),"")+If(cEvento $ (cAliasEF3)->EF3_CODEVE,cEvento,(cAliasEF3)->EF3_CODEVE)
   If EF2->(dbSeek(xFilial("EF2")+(cAliasEF3)->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT)))
      cTpJur := EF2->EF2_TIPJUR
   EndIf
   If cEvento == "520"
      nSldPrc := CalcSldPrc(cAliasEF3,If(lMemory,M->EF1_SLD_PM,EF1->EF1_SLD_PM),dDtCont,cIndice)
      Do While (cAliasEF3)->(!Eof()) .AND. cChave $ If(!Empty(cIndice),((cAliasEF3)->(&(cIndice+"+EF3_CODEVE"))),((cAliasEF3)->(&("EF3_CODEVE"))))
         nValor := (dDataBase - If(!Empty(dDtCont),dDtCont,(cAliasEF3)->EF3_DT_EVE)) * /*(cAliasEF3)->EF3_VL_MOE*/ nSldPrc * ((EF2->EF2_TX_FIX+EF2->EF2_TX_VAR) / 360 / 100) //AAF 18/06/2015 - Considerar taxa variavel.
         (cAliasEF3)->(DbSkip())
      EndDo
   ElseIf cEvento $ "500/501" .OR. cEvento == "100" //RMD - 02/12/14 - Considerar também o evento 501
      If cEvento $ "500/501" .AND. !Empty(dDtCont)  //RMD - 02/12/14 - Considerar também o evento 501
         Do While (cAliasEF3)->(!Eof()) .AND. cChave $ If(!Empty(cIndice),((cAliasEF3)->(&(cIndice+"+EF3_CODEVE"))),((cAliasEF3)->(&("EF3_CODEVE"))))
            If (cAliasEF3)->EF3_DT_EVE == dDtCont .AND. Empty((cAliasEF3)->EF3_EV_VIN)
               Exit
            EndIf
            (cAliasEF3)->(DbSkip())
         EndDo
      EndIf
      nValor := nSaldo * (nTx - (cAliasEF3)->EF3_TX_MOE)
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return {nValor, cTpJur}

/*
Funcao     : CalcSldPrc()
Parametros : cAliasEF3,nValSld, dDataCont, cIndice
Retorno    : nValSld
Objetivos  : Calcula o saldo do Principal pendente para contabilização
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 05/08/2014 :: 11:01
*/
*----------------------------------------------------------------*
Static Function CalcSldPrc(cAliasEF3,nValSld, dDataCont, cIndice)
*----------------------------------------------------------------*
Local aOrd := SaveOrd(cAliasEF3)
Local cChave := If(!Empty(cIndice),((cAliasEF3)->(&(cIndice))),"")+"700"

Begin Sequence
   If cAliasEF3 == "EF3"
      Break
   EndIf
   If !Empty(cIndice)
      (cAliasEF3)->(DbSeek(xFilial("EF3")+EF1->EF1_TPMODU+"700"))
   Else
      (cAliasEF3)->(DbSeek("700"))
   EndIf

   Do While (cAliasEF3)->(!Eof()) .AND. cChave $ If(!Empty(cIndice),((cAliasEF3)->(&(cIndice+"+EF3_CODEVE"))),((cAliasEF3)->(&("EF3_CODEVE"))))
      If (cAliasEF3)->EF3_DT_EVE <= dDataBase .AND. (cAliasEF3)->EF3_DT_EVE >= dDataCont
         nValSld += EF3_VL_MOE
      EndIf
      (cAliasEF3)->(DbSkip())
   EndDo
End Sequence

RestOrd(aOrd,.T.)
Return nValSld

/*
Função     : EX400EVJuros()
Objetivos  : Verificar se é um evento de juros
Parâmetros : código do evento
Retorno    : Lógico
Autor      : WFS
Data       : 01/12/14
*/
Function EX400EVJuros(cEvento)
Local lRet:= .F.

Begin Sequence

  If Left(cEvento, 2) == Left(EV_LIQ_JUR, 2) .Or.;
     Left(cEvento, 2) == Left(EV_LIQ_JUR_FC, 2) .Or.;
     Left(cEvento, 2) == Left(EV_JUROS_PREPAG, 2) .Or.;
     Left(cEvento, 2) == Left(EV_JUR_CNT, 2)

     lRet:= .T.
  EndIf

End Sequence

Return lRet

/*
Função     : Ex400ExcInc()
Objetivos  : Retornar e manipular a variável estática lExcEIncCN
Parâmetros : Nenhum
Retorno    : Lógico
Autor      : Nilson César
Data       : 11/02/2015
*/
Function Ex400ExcInc()
Local lRet := .F.

If lExcEIncCN
   lRet := .T.
EndIf

lExcEIncCN := .F.

Return lRet

/*
Função     : GeraEvRefin()
Objetivos  : Geração de Eventos de Refinanciamento
Parâmetros : aEve630 - Registros para gravação de eventos 630
Retorno    : NIL
Autor      : Guilherme Fernandes Pilan - GFP
Data       : 09/10/2015
*/
*------------------------------------*
Static Function GeraEvRefin(aEve630)
*------------------------------------*
Local aOrd := SaveOrd({"EF1","EF2","EF3"}), i,nParidMvRf
Default aEve630 := {}

Begin Sequence

   //********** Geração de Eventos 600 **********//
   WKREFINIMP->(DbGoTop())
   Do While WKREFINIMP->(!Eof())
      EF1->(DbSetOrder(1))  //"EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT"
      If EF1->(DbSeek(xFilial("EF1")+AvKey(WKREFINIMP->EF3_TPMOOR,"EF1_TPMODU")+;
                                     AvKey(WKREFINIMP->EF2_CONTRA,"EF1_CONTRA")+;
                                     AvKey(WKREFINIMP->EF1_BAN_FI,"EF1_BAN_FI")+;
                                     AvKey(WKREFINIMP->EF1_PRACA,"EF1_PRACA")+;
                                     AvKey(WKREFINIMP->EF1_SEQCNT,"EF1_SEQCNT")))
         EF3->(DbSetOrder(10))  //"EF3_FILIAL+EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR+EF3_CODEVE"
         If !WKREFINIMP->DBDELETE
            If !EF3->(DbSeek(xFilial("EF3")+AvKey(WKREFINIMP->EF3_TPMOOR,"EF3_TPMOOR")+;
                                        AvKey(WKREFINIMP->EF3_CONTOR,"EF3_CONTOR")+;
                                        AvKey(WKREFINIMP->EF3_BAN_OR,"EF3_BAN_OR")+;
                                        AvKey(WKREFINIMP->EF3_PRACOR,"EF3_PRACOR")+;
                                        AvKey(WKREFINIMP->EF3_SQCNOR,"EF3_SQCNOR")+;
                                        AvKey(WKREFINIMP->EF3_CDEVOR,"EF3_CODEVE")+;
                                        AvKey(WKREFINIMP->EF3_PARCOR,"EF3_PARCOR")+;
                                        AvKey(WKREFINIMP->EF3_IVIMOR,"EF3_IVIMOR")+;
                                        AvKey(WKREFINIMP->EF3_LINOR,"EF3_LINOR")))
               EX400GrvEventos(EF1->EF1_CONTRA,WKREFINIMP->EF3_IVIMOR,"",WKREFINIMP->EF3_VL_MOE,dDataBase,WKREFINIMP->EF3_MOE_IN,WKREFINIMP->EF3_PARCOR,EF1->EF1_MOEDA,;
                               "EF1","EF3","MANUT1",WKREFINIMP->EF3_TX_MOE,WKREFINIMP->TX_VINC,WKREFINIMP->DT_VINC,"",EF1->EF1_BAN_FI,;
                               EF1->EF1_PRACA,,EF1->EF1_TPMODU,EF1->EF1_SEQCNT,"EF3",,,,,,.T.)
            EndIf
         Else
            If EF3->(DbSeek(xFilial("EF3")+AvKey(WKREFINIMP->EF3_TPMOOR,"EF3_TPMOOR")+;
                                        AvKey(WKREFINIMP->EF3_CONTOR,"EF3_CONTOR")+;
                                        AvKey(WKREFINIMP->EF3_BAN_OR,"EF3_BAN_OR")+;
                                        AvKey(WKREFINIMP->EF3_PRACOR,"EF3_PRACOR")+;
                                        AvKey(WKREFINIMP->EF3_SQCNOR,"EF3_SQCNOR")+;
                                        AvKey(WKREFINIMP->EF3_CDEVOR,"EF3_CODEVE")+;
                                        AvKey(WKREFINIMP->EF3_PARCOR,"EF3_PARCOR")+;
                                        AvKey(WKREFINIMP->EF3_IVIMOR,"EF3_IVIMOR")+;
                                        AvKey(WKREFINIMP->EF3_LINOR,"EF3_LINOR")))
               EX400EstEv(EF3->EF3_SEQ,"LIQ",,.T.)
            EndIf
         EndIf
      EndIf

      WKREFINIMP->(DbSkip())
   EndDo

   //********** Geração de Eventos 630 **********//
   If Len(aEve630) # 0
      For i := 1 To Len(aEve630)
         If aEve630[i][1] == "LIQ"
            EF3->(DbSetOrder(10))  //"EF3_FILIAL+EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR+EF3_CODEVE"
            If EF3->(DbSeek(aEve630[i][2]))
               EF1->(DbSetOrder(1))  //"EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT"
               If EF1->(DbSeek(xFilial("EF1")+AvKey(EF3->EF3_TPMODU,"EF1_TPMODU")+;
                                              AvKey(EF3->EF3_CONTRA,"EF1_CONTRA")+;
                                              AvKey(EF3->EF3_BAN_FI,"EF1_BAN_FI")+;
                                              AvKey(EF3->EF3_PRACA,"EF1_PRACA")+;
                                              AvKey(EF3->EF3_SEQCNT,"EF1_SEQCNT")))                 
                  nParidMvRf := If( aEve630[i][5] <> EF1->EF1_MOEDA .And. EF1->EF1_MOEDA <> MOEDA_REAIS , aeve630[i][4]/EF3->EF3_VL_MOE , aEve630[i][3] )
                  EX400Liquida(EF1->EF1_CONTRA,"","","",EF3->EF3_VL_MOE,EF3->EF3_MOE_IN,EF1->EF1_MOEDA,;
                              "EF1","EF3","MANUT1",nParidMvRf,EF3->EF3_DT_EVE,,EF3->EF3_DT_EVE,"",;
                               ,,,,EF1->EF1_BAN_FI,EF1->EF1_AGENFI,EF1->EF1_NCONFI,EF1->EF1_PRACA,NIL,aEve630[i][4],;
                               NIL,NIL,NIL,EF1->EF1_TPMODU,EF1->EF1_SEQCNT,"EF3","","",,,.T.)
               EndIf
            EndIf
         ElseIf aEve630[i][1] == "EST"
            EF3->(DbSetOrder(10))  //EF3_FILIAL+EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR"
            If EF3->(DbSeek(aEve630[i][2]))
               EF1->(DbSetOrder(1))  //"EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT"
               If EF1->(DbSeek(xFilial("EF1")+AvKey(EF3->EF3_TPMODU,"EF1_TPMODU")+;
                                              AvKey(EF3->EF3_CONTRA,"EF1_CONTRA")+;
                                              AvKey(EF3->EF3_BAN_FI,"EF1_BAN_FI")+;
                                              AvKey(EF3->EF3_PRACA,"EF1_PRACA")+;
                                              AvKey(EF3->EF3_SEQCNT,"EF1_SEQCNT")))
                  EX400EstEv(EF3->EF3_SEQ,"LIQ",,.T.)
               EndIf
            EndIf
         EndIf
      Next i
   EndIf

End Sequence

RestOrd(aOrd,.T.)
Return NIL

/*
Função     : Ex400BloqCampo()
Objetivos  : Bloquear edição do campo EF3_TX_MOE e EF3_VL_REA.
Parâmetros : Nenhum
Retorno    : Lógico
Autor      : Marcos Roberto Ramos Cavini Filho - MCF
Data       : 13/01/2016
*/
Function Ex400BloqCampo()
Local lRet := .T.

If cMod == EXP
   If WorkEF3->EF3_CODEVE == "100"
      If !Empty(M->EF1_DT_JUR) .OR. EF1->(FieldPos("EF1_TX_MOE")) > 0
         lRet := .F.
      Endif
   Endif
EndIf

Return lRet
/*
Função     : RetTpEve
Objetivos  : retornar o tipo de contrato/ evento
Parâmetros :
Retorno    : tipo de contrato/ evento
Autor      : wfs
Data       : mai/2015
Observação : Criado inicialmente para preenchimento do tipo de contrato no evento para processos ACE (cliente Durli).
             Deve ser complementado com os demais eventos, conforme demanda.
*/
Static Function RetTpEve()
Local cRet:= ""

   If M->EF1_TP_FIN == ACE .And. WorkEF3->EF3_CODEVE == EV_PRINC
      cRet:= M->EF1_TP_FIN
   EndIf

Return cRet


/*
Função     : XBFFEX400
Objetivos  : Consulta padrao para o campo EF1_MODPAG
Parâmetros :
Retorno    : Modalidade de Pagamento
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data       : 20/07/2017
*/
Function XBFFEX400()
Local cRetorno := ""

Do Case
   Case cMod == EXP
      cRetorno := ConPad1(,,,'EEF',,)
   Case cMod == IMP
      cRetorno := ConPad1(,,,'SJ6',,)
End Case

Return cRetorno

/*
Função     : INIFFEX400
Objetivos  : Inicializador padrao para o campo EF1_MDPDES
Parâmetros :
Retorno    : Modalidade de Pagamento
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data       : 20/07/2017
*/
Function INIFFEX400()
Local cRetorno := ""

Do Case
   Case cMod == EXP
      cRetorno := Posicione('EEF',1,xFilial('EEF')+M->EF1_MODPAG,'EEF_DESC')
   Case cMod == IMP
      cRetorno := Posicione('SJ6',1,xFilial('SJ6')+AvKey(M->EF1_MODPAG,'J6_COD'),'J6_DESC')
End Case

Return cRetorno

/*
Funcao     : EX400DescEv()
Parametros : cAliasEF1
             cAliasEF3
             cEvento
Retorno    : Descrição do evento contábil
Objetivos  : Retornar a descrição do evento contábil do contrato de financiamento, conforme tipo de financiamento do evento, tratando os casos de transferência ACC/ACE
Autor      : WFS
Data/Hora  : out/2017
*/
Function EX400DescEv(cAliasEF1, cAliasEF3, cEvento)
Local cTpModulo:= "",;
      cTpFinanc:= "",;
      cAuxTpFinanc:= ""

   //inicializa as variáveis com base no alias da tabela EF1
   If cAliasEF1 == "M"
      cTpModulo:= M->EF1_TPMODU
      cTpFinanc:= M->EF1_TP_FIN
   Else
      cTpModulo:= (cAliasEF1)->EF1_TPMODU
      cTpFinanc:= (cAliasEF1)->EF1_TP_FIN
   EndIf

   //inicializa as variáveis com base no alias da tabela EF3
   If cAliasEF3 == "M"
      cAuxTpFinanc:= M->EF3_TP_EVE
   Else
      cAuxTpFinanc:= (cAliasEF3)->EF3_TP_EVE
   EndIf

   //Financimanento de importação ou exportação
   If cTpModulo == IMP
      cTpModulo:= "FIIM"
   Else
      cTpModulo:= "FIEX"
   EndIf

   //Tipo de financiamento
   If !Empty(cAuxTpFinanc)
      cTpFinanc:= cAuxTpFinanc
   EndIf

Return Posicione("EC6", 1, EC6->(xFilial()) + cTpModulo + cTpFinanc + cEvento, "EC6_DESC")


/*
 * Eli James de Souza Aguiar - 12/09/2018 - Consulta Padrão customizada para parcela.
 */
Function F3EEQ()
      Local aFiliais := aFil
      Local cQuery := ""
      Local workInv := "WORK_INVOICE"
      Local lRet := .T.
      Local cSeek := ""

      Begin Sequence

            // Cria uma string de consulta
            cQuery := invExpSQL(aFiliais)
            // Cria work de consulta da parcela

            If select(workInv) > 0
                  (workInv)->(dbclosearea())
            Endif
            EasyWkQuery(cQuery, workInv)
            // Cria o Browse, e a work ficará posicionada após o usuário selecionar o registro e confirmar.
            cSeek := constructBrowse(workInv)
            // Posiciona no registro da tabela original EEQ
            EEQ->(dbSetOrder(1))
            If cSeek == ""
                  lRet := .F.
            Else
                  EEQ->(dbSeek((cSeek)))
            Endif
            (workInv)->(dbCloseArea())
      End Sequence

Return lRet

Static Function filiaisSQL(aFiliais)
      Local cFilMulti := ""
      Local nI := 0
      If temFilial(aFiliais)
            For nI := 1 To Len(aFiliais)
                  if nI <> 1
                        cFilMulti += ","
                  EndIf
                  cFilMulti += "'" + aFiliais[nI] + "'"
            Next
      EndIf
Return cFilMulti

Static Function temFilial(aFiliais)
      Return  aFiliais != Nil .And. Len(aFiliais) > 0
Return

// SQL para consulta padrão de invoices de exportação
Static Function invExpSQL(aFiliais)
      Local cQuery
      cQuery := "SELECT EEQ_FILIAL, EEQ_NRINVO, EEQ_PREEMB, EEQ_PARC, EEQ_VCT, EEQ_FASE FROM " + RetSqlName("EEQ")  + " WHERE 1=1"

      If temFilial(aFiliais)
            cQuery += " AND EEQ_FILIAL IN (" + filiaisSQL(aFiliais) +  ") "
      EndIf

      If TcSrvType() <> "AS/400"
            cQuery+= " AND D_E_L_E_T_ <> '*'" 
      EndIf
Return cQuery

Static Function EEQEachFld(aField, oColumn, oBrowse)
      If aField[DBS_NAME] $ "EEQ_FILIAL|EEQ_NRINVO|EEQ_PREEMB|EEQ_PARC|EEQ_VCT"   //aField[DBS_NAME] != "DELETE" .And. aField[DBS_NAME] != "R_E_C_N_O_"
            ADD COLUMN oColumn DATA &("{ ||" + aField[DBS_NAME] + " }") TITLE AvSx3(aField[DBS_NAME], AV_TITULO) SIZE AvSx3(aField[DBS_NAME], AV_TAMANHO) OF oBrowse
      EndIf
Return

static function constructBrowse(work)
      Local nopc:=0
      Local oColumn
      Local oDlg
      Local bOk := {|| nopc:=1 , oDlg:End()}
      Local bCancel := {|| oDlg:End()}
      Local oBrowse
      Local cRet := ""

      Define MSDialog oDlg Title EEQ->(X2Nome()) FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
      DEFINE FWBROWSE oBrowse DATA TABLE ALIAS work OF oDlg
      AEval((work)->(DBSTRUCT()), { |aField| EEQEachFld(aField, oColumn, oBrowse)})
      ACTIVATE FWBROWSE oBrowse
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel)) CENTERED

      if nopc == 1
            cRet := (work)->(EEQ_FILIAL + EEQ_PREEMB + EEQ_PARC + EEQ_FASE)
      endif
Return cRet


/*
Funcao     : ChekAltEF3()
Parametros : <Nenhum>
Retorno    : lRet - .T. quando existir alteração e .F. caso contrário 
Objetivos  : Verificar se existe alteração entre work e tabela nos campos determinados para integração EAI(Logix)
Autor      : NCF
Data/Hora  : Jan/2019
*/
Static Function ChekAltEF3(cAlias,aDadosEF3)

Local aCposAlt := {"EF3_DT_EVE","EF3_VL_MOE","EF3_TX_MOE","EF3_MOE_IN","EF3_FORN"}
Local lRet     := .F.
Local i
Local cEvent   := ""
Default cAlias := "WorkEF3"
cEvent         := If( cAlias == "M" ,  If( Valtype(aDadosEF3) == "A" .And. Len(aDadosEF3) >= EF3->(FieldPos("EF3_CODEVE")) , aDadosEF3[EF3->(FieldPos("EF3_CODEVE"))] , EF3->EF3_CODEVE )  , (cAlias)->EF3_CODEVE   )
Default aDadosEF3 := Array( EF3->(FCount()) )

Begin Sequence
//Indica a Inclusão/Alteração de campos com título não integrado
If ( Left(cEvent,1) $ '3|4' .Or. Left(cEvent,2) $ ('18|19|62|64|66|67|70|71') )

   //Indica falha na integração anterior deste evento
   If cAlias == "WorkEF3" .And. Empty((cAlias)->EF3_TITFIN)
      lRet := .T.
      Break
   EndIf

   //Indica a alteração de campos sensíveis à integração, obrigando re-integração.
   For i := 1 To EF3->(Fcount())
      If aScan( aCposAlt , {|x| x == EF3->(FieldName(i)) }   )
         If cAlias == "WorkEF3"
            If EF3->( FieldGet(i) )  #  WorkEF3->(FieldGet( FieldPos(  EF3->(FieldName(i))  )  )) .Or. WorkEF3->EF3_RECNO == 0
               lRet := .T.
               Break
            EndIf
         Else
            If aDadosEF3[i] # NIL .And. EF3->( FieldGet(i) )  #  aDadosEF3[i]
               lRet := .T.
               Break
            EndIf  
         EndIf
      EndIf
   Next i

EndIf

End Sequence

Return lRet

/*
Funcao     : EX400EF3Alt()
Parametros : nOpc: 3-inclui no array, 4-retorna se existe no array, 5-apaga do array
             cTipoManut: Tipo da manutenção sobre o registro
Retorno    : lRet - Retorno da execução ou verificação quando nopc=4
Objetivos  : Fazer manutenção no array aEF3AltEAI que guarda os recnos das parcelas de financiamento que tiveram 
             alterações em campos os quais se torna necessário atualizar no ERP externo via inteeg. EAI(Logix)
Autor      : NCF
Data/Hora  : Jan/2019
*/
Function EX400EF3Alt(nOpc,cTipoManut) 

Local lRet := .F.
Local nPos 

Do Case
   Case nOpc == 3
      If IsMemVar("aEF3AltEAI") .And. aScan(aEF3AltEAI, {|x| x[1] == EF3->(Recno()) .And. x[2] == cTipoManut  }  ) == 0
         aAdd( aEF3AltEAI , { EF3->(Recno()) , cTipoManut } )
         If cTipoManut == "LIQUIDACAO" .And. Empty(EF3->EF3_TITFIN) .And. aScan(aEF3AltEAI, {|x| x[1] == EF3->(Recno()) .And. ("ALTERACAO" $ x[2] .Or. "INCLUSAO" $ x[2] )} ) == 0
            aAdd( aEF3AltEAI , { EF3->(Recno()) , If( Empty(WorkEF3->EF3_RECNO) , "INCLUSAO" , "ALTERACAO" ) } )    
         EndIf
         lRet := .T.    
      EndIf 

   Case nOpc == 4
      aTipoManut := {"INCLUSAO","ALTERACAO","ATUALIZA","ESTORNO"}
      If IsMemVar("aEF3AltEAI") 
         If ( nPos := aScan(aTipoManut, {|x| x $ cTipoManut}) ) > 0  
            If "ALTERACAO" $ cTipoManut      // Só retornar OK para integrar alteração caso tenha título e não tenha liquidação ou estorno da liquidação a fazer na mesma parcela.
               If !Empty(EF3->EF3_TITFIN)
                  If aScan(aEF3AltEAI, {|x| x[1] == EF3->(Recno()) .And. aTipoManut[nPos] $ x[2] }) > 0 .And. aScan(aEF3AltEAI, {|x| x[1] == EF3->(Recno()) .And. "LIQUIDACAO" $ x[2] }) == 0
                     lRet := .T.
                  EndIf
               Else
                  If aScan(aEF3AltEAI, {|x| x[1] == EF3->(Recno()) .And. aTipoManut[nPos] $ x[2] }) > 0
                     lRet := .T.
                  EndIf
               EndIf
            Else
               If aScan(aEF3AltEAI, {|x| x[1] == EF3->(Recno()) .And. aTipoManut[nPos] $ x[2] }) > 0
                  lRet := .T.
               EndIf               
            EndIf
         Else     
            If aScan(aEF3AltEAI, {|x| x[1] == EF3->(Recno()) .And. "LIQUIDACAO" $ x[2] }) > 0
               lRet := .T.
            EndIf
         EndIf
      EndIf

   Case nOpc == 5
      If IsMemVar("aEF3AltEAI") .And. ( nPos := aScan(aEF3AltEAI, {|x| x[1] == EF3->(Recno()) .And. x[2] == cTipoManut}) ) > 0
         aDel(aEF3AltEAI, nPos)
         aSize(aEF3AltEAI, Len(aEF3AltEAI)-1)
         lRet := .T.
      EndIf
EndCase

Return lRet
