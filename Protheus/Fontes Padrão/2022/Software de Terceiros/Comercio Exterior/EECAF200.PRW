/*
Programa : EECAF200.PRW
Objetivo : MANUTENCAO DE CAMBIO
Autor    : LUCIANO CAMPOS DE SANTANA
Data/Hora: 20/04/2001 14:23
Revisao  : Alcir Alves - 03-11-05 - considerar o banco/agencia/conta de movimentação no EEQ caso estejam preenchidas  - conforme chamado 020324
         : Jeferson Barros Jr. - 05/07/2001 - 14:10
         : Gustavo F.C. - 05/06/2002 - Alterações para Financiamento
         : Emerson Dib  - 05/10/2002 - Alterações para Financiamento
         : Cristiano A. Ferreira - 14/01/2003 (Simplificar o fonte)
         : A. Caetano Sciancalepre Jr. - 08/12/2003
         : Henrique Raineire - 25/04/2006
         : Fabrício (WFS) - 22/05/2009 - Alterações pós embarque para câmbio do tipo adiantamento. A circular
           nº 3.436 de 06/02/2009 (RMCCI nº 28) permite que a liquidação do contrato de câmbio seja realizada
           posteriormente ao embarque da mercadoria ou da prestação do serviço, tendo como limite o último dia
           útil do décimo segundo mês subsequente.
Obs.     : Algumas funções deste programas são utilizadas pelo Embarque.
         : Este programa trabalha integrado com os módulos ECO e EFF.
*/

#include "EEC.CH"
#include "EECAF200.ch"
#include "FWBrowse.Ch"

//Eventos.
#define EV_PRINC      "100"
#define EV_PRINC2     "101"
#define EV_EMBARQUE   "600"
#define EV_PJ         "520"
#define EV_TJ         "650"
#define EV_VC_PJ      "550"
#define EV_LIQ_PRC    "630"
#define EV_LIQ_PRC_FC "660"
#define EV_LIQ_JUR    "640"
#define EV_VC_PRC     "500"
#define EV_VLCOR      "530"
#define EV_DESCON     "801"
#define EV_ESTORNO    "999"
#define EV_COM_AR     "120" // Comissão do Tipo A Remeter. (Utilizada nos tratamentos de Frete Seguro e Comissão).
#define EV_COM_CG     "121" // Comissão do Tipo Conta Gráfica. (Utilizada nos tratamentos de Frete Seguro e Comissão).
#define EV_COM_DF     "122" // Comissão do Deduzir da Fatura. (Utilizada nos tratamentos de Frete Seguro e Comissão).
// ** AAF 02/02/05 - Eventos de Demurrage/Despatch
#define EV_DEM_PG     "131" // Demurrage/Despatch a Pagar. (Utilizada nos tratamentos de Frete Seguro e Comissão).
#define EV_DEM_RC     "132" // Demurrage/Despatch a Receber. (Utilizada nos tratamentos de Frete Seguro e Comissão).
#define EV_WASHOUT_OUT "134" //Wash-Out a Pagar
#define EV_WASHOUT_IN  "135" //Wash-Out a Receber
// ** GFC - Pré-Pagamento/Securitização
#define EV_PRINC_PREPAG "700"  //Principal das parcelas de pré-pagamento/securitização
#define EV_JUROS_PREPAG "710"  //Parcelas de juros de pré-pagamento/securitização
// **

//Opções da função AF200DetMan
#define LIQ_DET     99
#define ELQ_DET     98
#define BXG_DET     97//Baixa Gerencial - RMD - 08/11/07

//Define da Função Ae107AtuSld
#Define LC_SUBTRAIR 1
#Define LC_SOMAR    2

//Define de status do embarque/Câmbio
#define ST_ME "R" //Processo com câmbio em movimento no exterior         //NCF - 25/11/2015

*--------------------------------------------------------------------
Function EECAF200(xAutoCab,xOpcBrwAuto,xAutoItens,xOpcDetAuto)
Local cUsado //LRL 27/07/04 - Usado para acerto no Dicionario
Local aLiqAux:={} //GFC 14/01/05
Local nInd   //AAF 21/02/2006 - Variavel local para o For.
Local nEFFParc := nParc := nParOri := nParvin := nOrigem := 0 //LRS - 02/02/2017
//Novo tratamento para execauto
Private lBrowseAuto := ValType(xAutoCab) == "A" .And. ValType(xOpcBrwAuto) == "N"
Private lExecAuto := ValType(xAutoItens) == "A" .And. ValType(xOpcDetAuto) == "N"
Private aAutoCab := xAutoCab
Private aAutoItens := xAutoItens
Private nOpcBrwAuto := xOpcBrwAuto
Private nOpcDetAuto := xOpcDetAuto 

Private cCADASTRO := STR0001 //"Manutenção de Câmbio"

Private aROTINA := MenuDef()

// Campos da Enchoice (EEC) nas opções Visualizar e Alterar
Private aEEC := {"EEC_PREEMB","EEC_PEDREF","EEC_DTPROC","EEC_STTDES",;
                 "EEC_MOTSIT","EEC_DSCMTS","EEC_IMPORT","EEC_IMPODE","EEC_CLIENT","EEC_CLIEDE",;
                 "EEC_FORN","EEC_FORNDE","EEC_EXPORT","EEC_EXPODE","EEC_CONSIG",;
                 "EEC_CONSDE","EEC_CONDPA","EEC_DIASPA","EEC_DESCPA","EEC_FRPPCC",;
                 "EEC_VIA","EEC_VIA_DE","EEC_ORIGEM","EEC_DEST","EEC_INCOTE","EEC_PGTANT",;
                 "EEC_SL_LC","EEC_LC_NUM","EEC_EMBAFI","EEC_IDIOMA","EEC_TIPCOM","EEC_VALCOM",;
                 "EEC_TIPCVL","EEC_FRPREV","EEC_SEGPRE","EEC_MOEDA","EEC_OBS","EEC_REFIMP",;
                 "EEC_MARCAC","EEC_OBSPED","EEC_PRECOA","EEC_CUBAGE","EEC_SEGURO","EEC_GENERI",;
                 "EEC_SL_EME","EEC_LICIMP","EEC_DSCORI","EEC_DSCDES","EEC_REFAGE","EEC_MPGEXP",;
                 "EEC_DSCMPE","EEC_FOLOJA","EEC_IMLOJA","EEC_EXLOJA","EEC_COLOJA","EEC_BELOJA",;
                 "EEC_CLLOJA","EEC_BENEF","EEC_BENEDE","EEC_ENDBEN","EEC_ENDIMP","EEC_TIPTRA",;
                 "EEC_FRPINT","EEC_FRPCOM","EEC_INSCOD","EEC_ENQCOD","EEC_OBSREM",;
                 "EEC_EXLIMP","EEC_DTLIMP","EEC_URFDSP","EEC_URFENT","EEC_PAISDT","EEC_PAISET",;
                 "EEC_REGVEN","EEC_OPCRED","EEC_SECEX","EEC_LIMOPE","EEC_MRGNSC","EEC_ANTECI",;
                 "EEC_VISTA" ,"EEC_NPARC","EEC_PARCEL","EEC_VLMNSC","EEC_VLCONS","EEC_COBCAM",;
                 "EEC_FINCIA","EEC_DECPES","EEC_DECQTD","EEC_DECPRC","EEC_END2IM","EEC_END2BE",;
                 "EEC_RESPON","EEC_DESCON","EEC_DESPIN","EEC_AMOSTR", "EEC_CALCEM","EEC_CONFEC",;
                 "EEC_PACKAG","EEC_ONTHEP","EEC_QUANTI","EEC_UNIT","EEC_NETWGT","EEC_GROSSW","EEC_DTEMBA"}

//LGS-28/08/2014
If EEQ->(FieldPos('EEQ_MOTIVO')) > 0
   AADD(aEEC,'EEQ_MOTIVO')
   AADD(aEEC,'EEQ_MODAL' )
   AADD(aEEC,'EEQ_BCOEXT')
   AADD(aEEC,'EEQ_AGCEXT')
   AADD(aEEC,'EEQ_CNTEXT')
   AADD(aEEC,'EEQ_NBCEXT')

   IF AVFLAGS("CAMBIO_EXP_MOV_EXT")
      AADD(aEEC,'EEQ_MOEBCO')
      AADD(aEEC,'EEQ_PRINBC' )
      AADD(aEEC,'EEQ_VLMBCO')
   ENDIF

EndIf

IF EECFlags("FRESEGCOM")
   aDel(aEEC,aScan(aEEC,"EEC_TIPCOM"))
   aDel(aEEC,aScan(aEEC,"EEC_VALCOM"))
   aDel(aEEC,aScan(aEEC,"EEC_TIPCVL"))
   aSize(aEEC,Len(aEEC)-3)
   aAdd(aEEC,"EEC_DSCCOM")
Endif

IF AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")    //NCF - 22/07/2015
   AADD(aEEC,'EEQ_ACRESC')
   AADD(aEEC,'EEQ_DECRES' )
   AADD(aEEC,'EEQ_MULTA')
   AADD(aEEC,'EEQ_JUROS')
ENDIF

//RMD - 12/07/18 - Exibe os campos da DUE
If AVFlags("DU-E")
	aAdd(aEEC, "EEC_EMFRRC")
	aAdd(aEEC, "EEC_RECALF")
	aAdd(aEEC, "EEC_STTDUE")
	aAdd(aEEC, "EEC_EMFRRC")
	aAdd(aEEC, "EEC_RECALF")
	If EEC->(FieldPos("EEC_RECEMB")) > 0
		aAdd(aEEC, "EEC_RECEMB")
	EndIf
	If AvFlags("DU-E2")
		aAdd(aEEC, "EEC_FOREXP")
		aAdd(aEEC, "EEC_DESFOR")
		aAdd(aEEC, "EEC_OBSFOR")
		aAdd(aEEC, "EEC_SITESP")
		aAdd(aEEC, "EEC_DESSIT")
		aAdd(aEEC, "EEC_OBSSIT")
		aAdd(aEEC, "EEC_ESPTRA")
		aAdd(aEEC, "EEC_DESTRA")
		aAdd(aEEC, "EEC_OBSTRA")
		aAdd(aEEC, "EEC_MOTDIS")
		aAdd(aEEC, "EEC_DESDIS")
		aAdd(aEEC, "EEC_OBSDIS")
		aAdd(aEEC, "EEC_FOREXP")
		aAdd(aEEC, "EEC_OBSFOR")
		aAdd(aEEC, "EEC_SITESP")
		aAdd(aEEC, "EEC_OBSSIT")
		aAdd(aEEC, "EEC_ESPTRA")
		aAdd(aEEC, "EEC_OBSTRA")
		aAdd(aEEC, "EEC_MOTDIS")
		aAdd(aEEC, "EEC_OBSDIS")
	EndIf
EndIf
//Os campos abaixo devem ser exibidos independentemente de a integração com a DUE estar habilitada, por isso verificar somente a existência dos campos
If EEC->(FieldPos("EEC_NRODUE")) > 0
	aAdd(aEEC, "EEC_NRODUE")
EndIf
If EEC->(FieldPos("EEC_NRORUC")) > 0
	aAdd(aEEC, "EEC_NRORUC")
EndIf
If EEC->(FieldPos("EEC_DTDUE")) > 0
	aAdd(aEEC, "EEC_DTDUE")
EndIf
If EEC->(FieldPos("EEC_CHVDUE")) > 0
	aAdd(aEEC, "EEC_CHVDUE")
EndIf

Private cTpModu := ""

// Verifica se o campo Evento existe na base de dados
Private lOkEVENT := EEQ->(FieldPos("EEQ_EVENT")) > 0

// ** By JBJ - 12/11/2002 - Flag pagamento antecipado.
Private lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)

// Verifica o valor máximo permitido para alteraçào do valor em Reais.
Private nVlMaximo := EasyGParam("MV_AVGVLMX",,0) // MJA 09/12/04

// ** By JBJ - 10/01/2002 - Flag Manutencao de cotaçao fechamento de câmbio.
Private lCotaCambio := .f.

// ** By JBJ - 11/03/2003 - Flag Parcela de vinculação
Private lParVin := EEQ->(FieldPos("EEQ_PARVIN")) > 0

// ** By VI - 17/03/2003 - Flag Parcela de vinculação FINANCIAMENTO
Private lParFin := EEQ->(FieldPos("EEQ_PARFIN")) > 0

// ** By JBJ - 20/05/2003 - Flag Estorno de Parcela com variação cambial.
Private lEstParVC := EasyGParam("MV_AVG0046",,.f.)

Private oGet // LGV 11/07/03

SX3->(DbSetOrder(2))
Private lMultiFil  := VerSenha(115) .and. Posicione("SX2",1,"EF1","X2_MODO") == "C" .AND. SX3->(DbSeek("EF3_FILORI")) //LRL 20/12/04
// ** AAF 15/01/05 - Verifica se existe a Filial de Origem
Private lEF3FilOri := SX3->(DbSeek("EF3_FILORI"))
// **

Private lTemLiqPrm := SX3->(DbSeek("EF1_LIQPRM")) .And. SX3->(DbSeek("EF1_LIQPRR")) .And. SX3->(DbSeek("EF1_LIQJRM")) .And. ;
                      SX3->(DbSeek("EF1_LIQJRR"))
Private nTipoOPC //LGS-28/08/2014
lTemEC6New := SX3->(DbSeek("EC6_TPMODU"))
lTemTpModu := SX3->(DBSeek("ECF_TPMODU"))

If lTemTPMODU
   cTPMODU:='EXPORT'
   bTPMODUECF := {|| ECF->ECF_TPMODU = 'EXPORT' }
Else
   bTPMODUECF := {|| .T. }
EndIf

// ACSJ - Caetano - 27/01/2005
// Testa se existe os campos nos arquivos
Private lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                     SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                     SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                     SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                     SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                     SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI"))

// ** AAF - 21/02/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND.;
                     EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. EF1->(FieldPos("EF1_CAMTRA")  ) > 0 //HVR 25/04/06 - VERIFICA SE EF1_CAMTRA EXISTE .and. EF1->(FieldPos("EF1_CAMTRA")) > 0 .and.;
Private cMod := "E"
// **

//Tabela de cadastro de Financiamentos.
Private lCadFin := Select("EF7") > 0 .AND. Select("EF8") > 0
// **

//*** RMD - 17/10/14 - Carrega os campos de usuário
Private aUserFields := {}

	SX3->(DbSetOrder(1))
	SX3->(DbSeek("EEQ"))
	While SX3->(!Eof() .And. X3_ARQUIVO == "EEQ")
		If SX3->X3_PROPRI == "U"
			aAdd(aUserFields, SX3->X3_CAMPO)
		EndIf
		SX3->(DbSkip())
	EndDo
//***

SX3->(DbSetOrder(1))

If Select("EXG") > 0
   lCotaCambio := EXG->(FieldPos("EXG_PREEMB")) > 0 .And. EXG->(FieldPos("EXG_TX")) > 0
EndIf

// ** By EDS - 11/12/2002 - Variaveis para verificação de campos para estorno da contabilização
Private lOkEsTor := .f.
Private lContEst  := EasyGParam("MV_CONTEST",,.T.)   // Gera Estorno para contabilização
Private lIntCont  := EasyGParam("MV_EEC_ECO",,.F.)   // Define Integração entre SIGAEEC - SIGAECO
Private cFilECF, cFilEEC:= xFilial("EEC"), cFilEE9:= xFilial("EE9"), cFilSA6:= xFilial("SA6")
Private cTX_100, cTX_520

// *** Variaveis para integracao com o Financiamento
Private cFilEF3,;
        cFilEF2,;
        cFilEF1,;
        cFilEC6,;
        cFilEF5,; //ACSJ - 11/02/2005
        lFinanciamento := EasyGParam("MV_EFF",,.F.),;
        lIntFina   := EasyGParam("MV_EEC_EFF",,.F.),;
        lACCACE    := .T. //EasyGParam("MV_ACC_ACE",,.T.)

Private lTelaVincula := .F. //FSM - 01/03/2012

// ** GFC - Pré-Pagamento/Securitização
Private lPrePag     := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
                       EF1->(FieldPos("EF1_PREPAG")) > 0 .and.;
                       EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
                       EF1->(FieldPos("EF1_ROF"))    > 0 .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
                       EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
                       EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
                       EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
                       EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
                       EF3->(FieldPos("EF3_SLDVIN")) > 0
// **
Private lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0
Private lEF2_INVOIC := EF2->(FieldPos("EF2_INVOIC")) > 0 .and. EF2->(FieldPos("EF2_PARC")) > 0
Private lEEQ_TP_CON := EEQ->(FIELDPOS("EEQ_TP_CON")) > 0 //Alcir Alves  - 28-11-05
Private lEF1_DTBONI := EF1->(FieldPos("EF1_DTBONI")) > 0 .and. EF2->(FieldPos("EF2_BONUS")) > 0
Private aRepact     := {}, aClickRep := {} // ** GFC - 31/01/06

Private lIsCambio := .t. // Flag para identificar a rotina de cambio.

Private nCGrafica:=0, nARemeter:=0, nADeduzir:=0

Private aDiscount := {{"801","101"},; // Desconto sobre invoice.
                      {"802","101"},; // Abatimento sobre invoice.
                      {"803","102"},; // Desconto sobre frete.
                      {"804","103"},; // Desconto sobre seguro.
                      {"805","120"},; // Desconto sobre comissão - A Remeter.
                      {"806","121"},; // Desconto sobre comissão - Conta Gráfica.
                      {"807","122"}}  // Desconto sobre comissão - Deduzir da Fatura.

Private lNRotinaLC := .f.
Private lIncCAPCCG := lExcCAPCCG := .F.

lNRotinaLC :=    (EEL->(FieldPos("EEL_SLDVNC")) # 0) ;
           .And. (EEL->(FieldPos("EEL_SLDEMB")) # 0) ;
           .And. (EEL->(FieldPos("EEL_RENOVA")) # 0) //JPM - 20/01/05 - Novos Tratamentos de Carta de Crédito

If lIntCont
   lOkEsTor   := ECF->(FieldPos("ECF_PREEMB")) > 0 .And. ECF->(FieldPos("ECF_FASE")) > 0 .And. ;
	             EEQ->(FieldPos("EEQ_FASE")) > 0 .And. EEQ->(FieldPos("EEQ_EVENT")) > 0 .And. ;
	             EEQ->(FieldPos("EEQ_NR_CON")) > 0 .And. EET->(FieldPos("EET_DTDEMB")) > 0
EndIf

If lIntCont .OR. lIntFina
   If !ChkFile("EC6")
      EasyHelp(STR0093) //"Arquivo de eventos contábeis não pôde ser aberto."
      Return .T.
   EndIf
   cFilEC6:=xFilial("EC6")
   EC6->(DbSetOrder(6))
   EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX01","")+'100'))
   cTX_100 := EC6->EC6_TXCV
   EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX01","")+'520'))
   cTX_520 := EC6->EC6_TXCV
   EC6->(DbSetOrder(1))
EndIf

If lOkEstor
   cFilECF := xFilial("ECF")
Endif

//-----------------------------------------------------------------------------------------
// Integrar com o Financiamento se os dois MVs estiverem ativos
lFinanciamento := lFinanciamento .And. lIntFina .and. !cFilAnt $ EasyGParam("MV_AVG0024",,"")

If lFinanciamento
   cFilEF6 := xFilial("EF6")
   cFilEF3 := xFilial("EF3")
   cFilEF2 := xFilial("EF2")
   cFilEF1 := xFilial("EF1")
   If lTemChave
      //ACSJ - 11/02/2005
      cFilEF5 := xFilial("EF5")
      // ----------------
   EndIf
EndIf

/*
Ponto de Entrada : EECAF200, passando como parametro "PE_MBROWSE".
Autor            : Alexsander Martins dos Santos
Data e Hora      : 13/01/2004 às 17:45.
Objetivo         : Incluir opções customizadas no menu do mBrowse.
*/
If EasyEntryPoint("EECAF200")
   ExecBlock("EECAF200", .f., .f., "PE_MBROWSE")
Endif


DBSELECTAREA("EEC")
//EEC->(DBSETORDER(1))

//DFS - 21/07/12 - Para conter os parametros de configurações financeiros na rotina de cambio de exportacão
If IsIntEnable("001")
   SetKey (VK_F12,{|a,b| AF201PergFin()})
EndIf

//LRS - 21/10/2016 - verificação dos tamanho do campo EEQ_PARC e EEQ_PARVIN, caso for diferente, não abrir o Embarque
SX3->(DbSetOrder(2))
IF EasyGParam("MV_EEC_EFF",,.F.)
   IF SX3->(Dbseek("EF3_PARC"))
      nEFFParc := SX3->X3_TAMANHO
   EndIF
EndIF

If SX3->(DbSeek("EEQ_PARC"))
   nParc := SX3->X3_TAMANHO
EndIF

If SX3->(DbSeek("EEQ_PARVIN"))
   nParvin := SX3->X3_TAMANHO
EndIF

If SX3->(DbSeek("EEQ_PAOR"))
   nParOri := SX3->X3_TAMANHO
EndIF

If SX3->(DbSeek("EEQ_ORIGEM"))
   nOrigem := SX3->X3_TAMANHO
EndIF

IF ((nParvin <> nParc) .OR. (nParOri <> nParc) .OR. (nOrigem <> nParc) .OR. (EasyGParam("MV_EEC_EFF",,.F.) .AND. nEFFParc <> nParc)) .AND. EasyGParam("MV_AVG0131",,.F.)
   EasyHelp(STR0288+ cValToChar(nParvin)+ " "+STR0289+ cValToChar(nParc)+ " "+;
   STR0290+ cValToChar(nParOri) + ", campo Origem (EEQ_ORIGEM) Tamanho: "+ cValToChar(nOrigem) + IIF(EasyGParam("MV_EEC_EFF",,.F.), " " + STR0292 + cValToChar(nEFFParc), ""), STR0014) //Foi encontrado um problema com o dicionário da dados . Para acessar essa rotina o campo Nro.Parc.Vin (EEQ_PARVIN) Tamanho : deve possuir o mesmo tamanho do campo Nro. Parcela(EEQ_PARC) Tamanho : do mesmo modo o campo Parcela Origem(EEQ_PAOR)  Tamanho:
   //Break
EndIF

//Novo tratamento para ExecAuto    
If !lBrowseAuto //.or. (lBrowseAuto .and. nOpcBrwAuto == 3)
   EEC->(DBSETORDER(13)) 
   MBROWSE( 6, 1,22,75,"EEC")
Else
   MBrowseAuto(nOpcBrwAuto,aAutoCab,"EEC",,.T.)
EndIf

RETURN(.T.)


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 02/02/07 - 15:20
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { {STR0002,"AF201PES",0,1},; //"Pesquisar "
                    {STR0003,"AF200MAN",0,2},; //"Visualizar"
                    {STR0004,"AF200MAN",0,4},; //"Alterar "  // By JBJ 13/12/02 - 10:48.
                    {STR0021,"AF200REL",0,4},; //"Follow-Up"
                    {STR0132,"AF200VIS",0,2}}  //"Visual. Rápida" // AAF 13/01/05 - 09:40

//ER - 19/04/2007
If EasyGParam("MV_AVG0039",,.f.)
    if ! AVFLAGS("EEC_LOGIX")
        If AvFlags("ADTFOREAI")//THTS - 24/03/2017 - Se tiver adt a fornecedor, muda o nome da chamada dos adt de cliente
            aAdd(aRotina,{STR0293,"AF201Adian",0,6}) //"Adiantamento recebido"
        Else
            aAdd(aRotina,{STR0230,"AF201Adian",0,6}) //"Adiantamentos"
        EndIf
    EndIf
EndIf

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAF200MNU")
	aRotAdic := ExecBlock("EAF200MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

/*
Funcao      : AF200MAN
Parametros  : cAlias, nReg, nOpc
Retorno     :
Objetivos   : Visualização/Alteração de Câmbio
Autor       :
Data/Hora   :
Obs.        :
*/
FUNCTION AF200MAN(cAlias,nReg,nOpc)

Local lShowMsg := .F.
LOCAL oDlg,aPOS,Z,nBTOP,nOldOpc:=nOpc,;
      aORDANT  := SAVEORD({"EEC","EEQ","SX3"}),;
      bCANCEL  := {|| If(lEstorno,If(MsgYesNo(STR0022,STR0016),(nBTOP := 0,oDLG:End()),Nil),(nBTOP := 0,oDLG:End()))},; //"Deseja sair sem salvar as alterações ?"###"Aviso"
      bOK      := If( Avflags("ADTFOREAI"),{|| nBTOP := 1,If(!lExecAuto, oDLG:End(), )},{|| If(Af200ValCambio(),(nBTOP := 1,If(!lExecAuto, oDLG:End(), )),nil)} ) //NCF - 23/03/2016 - Não executa nada se estiver ativada rotina de
                                                                                                                               //                   adiantamento à fornecedor via EAI
Local aSemSX3 := {}, cCpo, oMSELECT, nZ, aCpo:={}, h, nPosLiq
Local bVin    := {|| GrvWkEEQ('VINC'),FAF200Vinc("INCLUIR"),IIF(Avflags("ADTFOREAI"),GrvAF200Mn(),)}
Local bEstVin := {|| GrvWkEEQ('EST') ,FAF200Vinc("ESTORNAR"),IIF(Avflags("ADTFOREAI"),(GrvAF200Mn(),aExcVinculo:={}),)}
Local aSemSX3EEQ := {}, aHeaderOld := {}
Local aOrdTmp, cChave, cParVin:="", ni:=0, nOldOrd:=0, i, lRetPto
Local aChaves
Local aCposInt:= {"EEQ_FORN", "EEQ_FOLOJA", "EEQ_IMPORT", "EEQ_IMLOJA", "EEQ_BANC", "EEQ_VCT", "EEQ_VL"}
Local lAltTit:= .F.
Local lIncTit := .F., nRecTMPInc := 0
Local aRecPosEmb:= {}
// ** GFC - Pré-Pagamento
Local nSaldoVin, aCopia:={}, nTamArray:=0
// **
//Local cSeek:= ""
Local aRLockList := {}    // PLB 21/07/06 - Variavel para Tratamento Multi-Usuario
Local aTmpOrd
Local nRecTmp:= 0
Local aOldModulo := {cModulo,nModulo} //FSM - 29/02/2012
Local nTmpOrd := 0 //FSM - 07/03/2012
Local aParcLiq   := {}
Local bOnError := { |cFuncName, nOpc| AF200RetLiq(aParcLiq,cFuncName,nOpc,"CAMBIO")}
//RRC - 17/12/2013 - Integração SIGAEEC x SIGAESS baseada nas despesas internacionais
Local lEECESS := EasyGParam("MV_ESS0014",,.T.) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EXL->(FieldPos("EXL_NBSFR")) > 0 .And. EXL->(FieldPos("EXL_NBSSE")) > 0 .And. EXL->(FieldPos("EXL_NBSFA")) > 0
Local aReg := {}
Local aTMPEstBx := {}, nRecOpTmp := 0, nPosTmp := 0
Local aCAMPOS    := ARRAY(EEQ->(FCOUNT()))  // NCF - 10/04/2018 - Escopo local para evitar erro: array out of bounds ( 1 of 0 )  on CRIAESTRU(MATXFUNA.PRX)
Private cSeek:= "" // TDF - 09/09/11 - Alteração do tipo da variável para utilização em ponto de entrada
Private lOkEsTor := .f.  // GFP - 06/11/2013
Private aDataContr := {}
// **FSM - 29/02/2012 - Tratamento para correta baixa de titulo no financeiro
cModulo := "EEC"
nModulo := 29

If Type("lBrowseAuto") == "L" .And. lBrowseAuto .And. Type("lExecAuto") == "L" .And. !lExecAuto
    //Se for chamada do browse automática mas não for integração automática, religa a exibição de mensagens (desligada pelo mBrowseAuto)
    _SetAutoMode(.F.)
    HelpInDark(.F.)
EndIf

//** RMD - 26/11/14 - Recarrega as variáveis das filiais para o caso de Browse Multifilial.
If Type("lFinanciamento") == "L" .And. lFinanciamento
   cFilEF6 := xFilial("EF6")
   cFilEF3 := xFilial("EF3")
   cFilEF2 := xFilial("EF2")
   cFilEF1 := xFilial("EF1")
   If lTemChave
      //ACSJ - 11/02/2005
      cFilEF5 := xFilial("EF5")
      // ----------------
   EndIf
EndIf
//***

If Type("lIntFina") <> "L"
   lIntFina:= EasyGParam("MV_EEC_EFF",,.F.)
EndIf
If Type("lOkEvent") <> "L"
   // Verifica se o campo Evento existe na base de dados
   lOkEVENT := EEQ->(FieldPos("EEQ_EVENT")) > 0
EndIf

//OAP - Necessário para que as rotinas que necessitem de "Select("EXG") > 0" seja executadas.
DbSelectArea("EXG")

If Type("lCotaCambio") <> "L"   //Type("lCotaCambio") == "L"   //   - OAP
   lCotaCambio := Select("EXG") > 0 .And. EXG->(FieldPos("EXG_PREEMB")) > 0 .And. EXG->(FieldPos("EXG_TX")) > 0
EndIf
If Type("lParVin") <> "L"
   lParVin := EEQ->(FieldPos("EEQ_PARVIN")) > 0
EndIf
If Type("lPagtoAnte") <> "L"
   lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)
EndIf
If Type("lEEQ_TP_CON") <> "L"
   lEEQ_TP_CON := EEQ->(FIELDPOS("EEQ_TP_CON")) > 0
EndIf
If Type("nCGrafica") <> "N"
   nCGrafica := 0
EndIf
If Type("nARemeter") <> "N"
   nARemeter := 0
EndIf
If Type("nADeduzir") <> "N"
   nADeduzir := 0
EndIf
If Type("lNRotinaLC") <> "L"
   lNRotinaLC := (EEL->(FieldPos("EEL_SLDVNC")) # 0);
                  .And. (EEL->(FieldPos("EEL_SLDEMB")) # 0);
                  .And. (EEL->(FieldPos("EEL_RENOVA")) # 0)
EndIf
If Type("lIntCont") <> "L"
   lIntCont  := EasyGParam("MV_EEC_ECO",,.F.)
EndIf
If Type("lParFin") <> "L"
   lParFin := EEQ->(FieldPos("EEQ_PARFIN")) > 0
EndIf

If Type("lFinanciamento") <> "L"
   lFinanciamento := EasyGParam("MV_EFF",,.F.) .And. lIntFina .and. !cFilAnt $ EasyGParam("MV_AVG0024",,"")
EndIf

If Type("lTemChave") <> "L"
   SX3->(DbSetOrder(2))
   lTemChave := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA")) .and.;
                SX3->(DBSeek("EF1_AGENFI")) .and. SX3->(DBSeek("EF1_NCONFI")) .and.;
                SX3->(DBSeek("EF3_AGENFI")) .and. SX3->(DBSeek("EF3_NCONFI"))
EndIf

If Type("lEFFTpMod") <> "L"
   lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND.;
                EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. EF1->(FieldPos("EF1_CAMTRA")  ) > 0
EndIf

If Type("lEF2_INVOIC") <> "L"
   lEF2_INVOIC := EF2->(FieldPos("EF2_INVOIC")) > 0 .and. EF2->(FieldPos("EF2_PARC")) > 0
EndIf

If Type("lTemEC6New") <> "L"
   lTemEC6New := SX3->(DbSeek("EC6_TPMODU"))
EndIf

If Type("cTX_100") == "U" .or. Type("cTX_520") == "U"
   If lIntCont .or. lIntFina
      cFilEC6:=xFilial("EC6")
      EC6->(DbSetOrder(6))
      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX01","")+'100'))
      cTX_100 := EC6->EC6_TXCV
      EC6->(DbSeek(cFilEC6+If(lTemEC6New,"FIEX01","")+'520'))
      cTX_520 := EC6->EC6_TXCV
      EC6->(DbSetOrder(1))
   EndIf
EndIf

If Type("lPrePag") <> "L"
   lPrePag := EF1->(FieldPos("EF1_CAREPR")) > 0 .and. EF1->(FieldPos("EF1_TPCAPR")) > 0 .and.;
              EF1->(FieldPos("EF1_PARCPR")) > 0 .and. EF1->(FieldPos("EF1_PERIPR")) > 0 .and.;
              EF1->(FieldPos("EF1_TPPEPR")) > 0 .and. EF1->(FieldPos("EF1_CAREJR")) > 0 .and.;
              EF1->(FieldPos("EF1_TPCAJR")) > 0 .and. EF1->(FieldPos("EF1_PARCJR")) > 0 .and.;
              EF1->(FieldPos("EF1_PERIJR")) > 0 .and. EF1->(FieldPos("EF1_TPPEJR")) > 0 .and.;
              EF1->(FieldPos("EF1_PREPAG")) > 0 .and.;
              EF1->(FieldPos("EF1_CLIENT")) > 0 .and. EF1->(FieldPos("EF1_CLLOJA")) > 0 .and.;
              EF1->(FieldPos("EF1_ROF"))    > 0 .and. EF1->(FieldPos("EF1_INI_IR")) > 0 .and.;
              EF1->(FieldPos("EF1_FIM_IR")) > 0 .and. EF1->(FieldPos("EF1_PERCIR")) > 0 .and.;
              EF1->(FieldPos("EF1_REAJIR")) > 0 .and. EF3->(FieldPos("EF3_SLDLIQ")) > 0 .and.;
              EF3->(FieldPos("EF3_LIQ_RS")) > 0 .and. EF3->(FieldPos("EF3_NROP")) > 0 .and.;
              EF3->(FieldPos("EF3_EV_VIN")) > 0 .and. EF3->(FieldPos("EF3_PARVIN")) > 0 .and.;
              EF3->(FieldPos("EF3_SLDVIN")) > 0
EndIf

If Type("aClickRep") <> "A"
   aClickRep := {}
EndIf

If Type("aRepact") <> "A"
   aRepact := {}
EndIf

If Type("lMultiFil") <> "L"
   lMultiFil  := VerSenha(115) .and. Posicione("SX2",1,"EF1","X2_MODO") == "C" .AND. SX3->(DbSeek("EF3_FILORI"))
EndIf

If Type("lCadFin") <> "L"
   lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9")
EndIf

If Type("lACCACE") <> "L"
   lACCACE := .T.
EndIf

If Type("cMod") <> "C"
   cMod := "E"
EndIf

If Type("lRollBack") <> "L"
   lRollBack := .F.
EndIf

// ** JPM - 29/11/04 - variáveis utilizadas em consultas específicas
Private cWHENOD,cVIA,cWHENSA1,cWHENSA2, nSelecao := nOpc, aApropria := {}

Private aDemurrage := {} //AAF 03/02/05 - Processos de Demurrage.
PRIVATE cWORKEEQ, cWORKEEQ2,cWORKEEQ3,cWORKEEQ4,cWorkEEQ6,lMV0029,;
        aTELA[0,0],aGETS[0],;
        lINVERTE   := .F.,;
        lAltera    := .F.,;
        aHEADER    := {},;
        cMARCA     := GETMARK(),;
        aBUTTONS   := {},;
        aCAMPOTMP  := ARRAYBROWSE("EEQ","TMP"),;
        aDeletados := {},;
        lEstorno   := .f.,;
        aExcVinculo:= {},;
        aArrayEEQ  := {},;
        nSeqArray  := 1, oGet, aLiquida:={}, aParcVinc:={},;
        aLogEEQ    := {}

Private nP_OPC, aRestSaldo := {}

// ** By JBJ - 12/11/2002 - Flag pagamento antecipado.
Private cArq:="", aDelCotCam := {}

// ** By EDS - 11/12/2002 - Variaveis para verificação de campos para estorno da contabilização
Private aEstornaECF:={}, aIncluiECF:={}

// ** By JBJ - 31/02/03 - Flag para possibilitar a inclusão de parcelas de câmbio para processos não embarcados.
Private lSemEmbarque := Empty(EEC->EEC_DTEMBA) .And. lOkEVENT

// GFC - 13/01/05 - Para dar os gets das provisões de juros (financiamento)
Private aGetProv := {}, aLiqConf:={}

Private oGet_x, cGet_x :=""

// JPM - 03/08/05
Private aRestItens := {}, aTotInvoice := {}, lTodasLiquidadas := .t., lTodasLiqBase := .t.,;
                                             lNaoHaLiquidadas := .t., lNaoHaLiqBase := .t.

Private nParcEst, lAlt_Pgt := .F.//Integração com o SIGAFIN

//RMD - Controle de alterações/liquidações quando integrado com SigaFin.
Private lParcAlt := .F., lParcLiq := .F.
//WFS variável usada para armazenar o tipo de operação antes da alteração da variável nTipo (AF200DetMan e AF200ESTPARC)
Private nOldTipo := 0

//THTS - 28/03/2017 - Adiantamento de Fornecedores - Controle de adiantamento vinculado
Private lAdtForVin := .F.
Private lAdtForEst := .F.
Private lAdtForBkp := .F.
Private lCompenFor := .F.
Private nRecAdtFor := 0

//MPG - 26/06/2018 - Adiantamento de Fornecedores - Controle de adiantamento vinculado
Private lAdtCliVin := .F.
private lAdtCliEst := .F.

Private nValorBaixa:= 0
Private dDtBaixa
Private lIntAltLGX := If(Type("lIntAltLGX")=="L",lIntAltLGX,.F.) //NCF - 20/08/2014 - Flag que permite alteração de vcto. de título integrado ao Logix
//Define as despesas que geram contas a pagar
Private cDespIntFin := "120/102/103/127/150/129" //THTS - 16/05/2017 - adicionado o evento 129 na lista de dispesas
Private aTMPAlt := {}
Private lModalExt := .F. //LGS-28/08/2014
Private lCpoAcrDcr := AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") //NCF - 14/08/2015 - Tratamento Acresc./Decres./Multa/Juros/Desconto no controle de cambio SIGAEEC x SIGAFIN
Private lLiqCAPExt := AVFLAGS("CAMBIO_EXP_MOV_EXT")
Private lLiqAutoFinancing:= .F., aLiqAuto:= {}

If lFinanciamento
   Private lIsContab := .F.  // PLB 18/06/07 - Identifica se o Contrato foi Contabilizado
   Private aVinList := {}
   aSemSX3EEQ := { {"EF2_CONTRA","C",AVSX3("EF2_CONTRA",AV_TAMANHO),0} ,;
                   {"DT_VINC"   ,"D",AVSX3("EEQ_VCT"   ,AV_TAMANHO),0} ,;
                   {"VL_ORI"    ,"N",AVSX3("EEQ_VL"    ,AV_TAMANHO),AVSX3("EEQ_VL",AV_DECIMAL)} ,;
                   {"EEC_VALCOM","N",AVSX3("EEC_VALCOM",AV_TAMANHO),AVSX3("EEC_VALCOM",AV_DECIMAL)},;
                   {"EEQ_VL"    ,"N",AVSX3("EEQ_VL"    ,AV_TAMANHO),AVSX3("EEQ_VL",AV_DECIMAL)} ,;
                   {"EEQ_VCT"   ,"D",AVSX3("EEQ_VCT"   ,AV_TAMANHO),0} ,;
                   {"DT_RECEB"  ,"D",AVSX3("EF3_DT_FIX",AV_TAMANHO),0} ,;
                   {"EEQ_DTCE"  ,"D",AVSX3("EEQ_DTCE"  ,AV_TAMANHO),0} ,;
                   {"EEQ_PARC"  ,"C",AVSX3("EEQ_PARC"  ,AV_TAMANHO),0} ,;
                   {"TX_VINC"   ,"N",AVSX3("EF3_TX_MOE",AV_TAMANHO),AVSX3("EF3_TX_MOE",AV_DECIMAL)},;
                   {"SEQ"       ,"C",AVSX3("EF3_SEQ"   ,AV_TAMANHO),0} ,;
                   {"SEQARRAY"  ,"N",4,0},;
                   {"CONTAB"    ,"C",1,0},;
                   {"EEC_MOEDA" ,"C",AVSX3("EEC_MOEDA" ,AV_TAMANHO),0} ,;
                   {"EF2_BAN_FI","C",if(lTemChave,AVSX3("EF1_BAN_FI",AV_TAMANHO),3),0} ,;
                   {"EEQ_AGEN"  ,"C",AVSX3("EEQ_AGEN"  ,AV_TAMANHO),0} ,; //FDR - 10/02/2017
                   {"EEQ_NCON"  ,"C",AVSX3("EEQ_NCON"  ,AV_TAMANHO),0} ,; //FDR - 10/02/2017
                   {"EF1DESFIN","C",if(lTemChave,AVSX3("EF1_DES_FI",AV_TAMANHO),3),0} ,;
                   {"EEQ_PGT"   ,"D",AVSX3("EEQ_PGT"   ,AV_TAMANHO),0} ,;
                   {"EEQ_DTNEGO","D",AVSX3("EEQ_DTNEGO",AV_TAMANHO),0} ,;
                   {"EEQ_NRINVO","C",AVSX3("EEQ_NRINVO",AV_TAMANHO),0},;
                   {"EEQ_NROP"  ,"C",AVSX3("EEQ_NROP"  ,AV_TAMANHO),0},;
                   {"EF3_REC"   ,"N",10,0},;
                   {"TIPOVINC"  ,"C",1,0}}

                   // ACSJ - 03/02/2005
                   if lTemChave
                      Aadd(aSemSX3EEQ, {"EF3_PRACA", "C",AVSX3("EF3_PRACA", AV_TAMANHO),0})
                      Aadd(aSemSX3EEQ, {"EF5_DESCRI","C",AVSX3("EF5_DESCRI",AV_TAMANHO),0})
                      // ** AAF - 21/02/2006 - Adiciona o campo Sequência do contrato na Work.
                      If lEFFTpMod
                         aAdd(aSemSX3EEQ, {"EF3_SEQCNT","C",AVSX3("EF3_SEQCNT",AV_TAMANHO),0})
                      EndIf
                      // **
                   Endif
                   //------------------

   If lParFin
      aAdd(aSemSX3EEQ,{"EEQ_PARFIN","C",AVSX3("EEQ_PARFIN",AV_TAMANHO),0})
   EndIf
   //HVR 26/05/06 - CAMPO PARA SER USADO NOS SEEKS
   If lEFFTpMod
      aAdd(aSemSX3EEQ,{"EEQ_TP_CON","C",AVSX3("EEQ_TP_CON",AV_TAMANHO),0})
   EndIf
   // ** PLB 30/10/06 - Campos para conversão de moedas entre Invoice e Contrato de Financiamento
   aAdd(aSemSX3EEQ,{"EF1_MOEDA","C",AVSX3("EF1_MOEDA" ,AV_TAMANHO),0                             })
   aAdd(aSemSX3EEQ,{"VL_ME_FIN","N",AVSX3("EEQ_VL"    ,AV_TAMANHO),AVSX3("EEQ_VL",AV_DECIMAL)    })
   aAdd(aSemSX3EEQ,{"TX_ME_FIN","N",AVSX3("EF3_TX_MOE",AV_TAMANHO),AVSX3("EF3_TX_MOE",AV_DECIMAL)})
   aAdd(aSemSX3EEQ,{"EEQ_EVENT","C",AVSX3("EEQ_EVENT",AV_TAMANHO),0})
   //FSY - 15/04/2013
   If EF3->(FieldPos("EF3_DTDOC")) > 0
      aAdd(aSemSX3EEQ,{"EF3_DTDOC","D",AVSX3("EF3_DTDOC",AV_TAMANHO),0})
   EndIf

EndIf

IF EEC->EEC_STATUS = ST_PC
   Help(" ",1,"AVG0005222") //MSGINFO(STR0020,STR0016) //"Processo de exportação cancelado !"###"Aviso"
   RETURN(NIL)
ENDIF

// ** JPM - 21/03/06 - Ponto de entrada para validar a opção.
If EasyEntryPoint("EECAF200")
   If ValType((lRetPto := ExecBlock("EECAF200",.F.,.F.,{"VALIDA_MAN",nOpc}))) <> "L"
      lRetPto := .T.
   EndIf
   If !lRetPto
      Return Nil
   EndIf
Endif
// **

IF nOpc = VISUALIZAR // Visualização de Câmbio
   aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| AF200DetMan(VIS_DET),oMSELECT:oBrowse:Refresh()},STR0003/*,STR0220*/}) //"Visualizar"  //"Visual."
   If lFinanciamento
      aAdd(aButtons,{"BAIXATIT" ,{|| GrvWkEEQ('VINC',"VISUALIZAR"),FAF200Vinc("VISUALIZAR") ,oMSELECT:oBrowse:Refresh() },STR0025,STR0221}) //"Vinculação"  "Vincular"
   EndIf

ELSE // Alteração de Câmbio

   IF lOkEVENT
      aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/     ,{|| AF200DetMan(INC_DET),oMSELECT:oBrowse:Refresh()},STR0005} ) //"Incluir"
   Endif

   aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/,{|| AF200DetMan(ALT_DET),oMSELECT:oBrowse:Refresh()},STR0004} ) //"Alterar "
   aAdd(aButtons,{"EXCLUIR"  ,{|| lEstorno:=.t.,AF200ESTPARC(),AF200STATUS(),oMSELECT:oBrowse:Refresh()},STR0035,STR0053}) //"Excluir/Estornar"   "Excluir"

   If !lSemEmbarque
      // ** By JBJ - 10/01/03 - Cotação de Fechamento de Cambio.
      If lCotaCambio
         aAdd(aButtons,{"PRECO"  ,{||AF200CotaCam(nOpc)},STR0036}) //"Cotação de Câmbio"
      EndIf

      If lFinanciamento
         aAdd(aButtons,{"BAIXATIT" ,{|| If(ValFina("VINC"), EX400ChkItem(M->EEC_PREEMB) .And. Eval(bVin),),oMSELECT:oBrowse:Refresh() },STR0025,STR0221}) //"Vinculação"  "Vincular"
         aAdd(aButtons,{"EXCLUIR" /*"BMPDEL"*/   ,{|| If(ValFina("VINCEST"),Eval(bEstVin),),oMSELECT:oBrowse:Refresh()},STR0023,STR0023}) //"Estorno da Vinculação"  "Est.Vinc."// LGV parametro de VINC para VINCEST 11/07/03
         If lEF2_INVOIC
            aAdd(aButtons,{"BTCALEND" /*"BMPCALEN"*/,{|| FAF2Repact(),oMSELECT:oBrowse:Refresh()},STR0215,STR0223}) //"Repactuação"  "Repact."
         EndIf
      EndIf
   EndIf

   aAdd(aButtons,{"LIQCHECK" ,{|| If(ValFina("LIQ"),AF200DetMan(LIQ_DET),),oMSELECT:oBrowse:Refresh()},STR0026,STR0054}) //"Liquidação"  "Liquidar"
   aAdd(aButtons,{"NOCHECKED",{|| If(ValFina("LIQEST"),AF200DetMan(ELQ_DET),),oMSELECT:oBrowse:Refresh()},STR0024/*,STR0224*/}) //"Estorno da Liquidação"  "Est.Liq."
   //RMD - 10/11/07 - Nova legislação de câmbio
   If EECFlags("CAMBIO_EXT")
      aAdd(aButtons,{"BUDGET",{|| AF200DetMan(BXG_DET),oMSELECT:oBrowse:Refresh() },STR0235,STR0236})//STR0235	"Baixa Gerencial" //STR0236	"Bx. Geren."
   EndIf
   
   //THTS - 24/03/2017 - Adiciona botao de adiatnamento de fornecedores
   If AvFlags("ADTFOREAI")
   		aAdd(aButtons,{"EDIT",{|| AF200AdtFor(),oMSELECT:oBrowse:Refresh()},"Associação de Adiantamento"} ) //"Pagamentos ao fornecedor" -- Associação de Adiantamento
   EndIf

   EEC->(RECLOCK("EEC",.F.))
Endif

AADD(aCpo,{"EEQ_DTVC","EEQ_VLVC","EEQ_ORIGEM","EEQ_FFC","EEQ_PREEMB","EEQ_FILIAL","EEQ_BANC"})

/* By JBJ - 18/08/04 - Para a inclusão de parcela de câmbio, com os tratamentos para o evento da parcela,
                       (Despesa/Receita), os campos EEQ_IMPORT e EEQ_IMLOJA deverão estar na work, mesmo
                       sendo não usados. */
If EECFlags("FRESEGCOM")
   aAdd(aCpo[1],"EEQ_IMPORT") ; aAdd(aCpo[1],"EEQ_IMLOJA") ; AADD(aCpo[1],"EEQ_DESIMP")  // PLB 11/10/06 - DESIMP passou a ser não-usado
EndIf

SX3->(dbSetOrder(2))
For nZ = 1 to LEN(aCPO[1])
    cCpo := aCpo[1,nZ]
    IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
       aAdd(aSemSX3,{cCpo,AVSX3(cCpo,AV_TIPO),AVSX3(cCpo,AV_TAMANHO),AVSX3(cCpo,AV_DECIMAL)})
    Endif
Next

cCpo := "EEQ_VL"
aAdd(aSemSX3,{"TMP_RECNO","N",07,0})

// ** By JBJ - 07/03/03
SX3->(DbSetOrder(2))
SX3->(DbSeek("EEQ_PARVIN"))

If !lParVin .Or. !X3Uso(SX3->X3_USADO)
   aAdd(aSemSX3,{"EEQ_PARVIN","C",02,0})
EndIf

// ** By JBJ - 11/03/03 - Campo para armazenar o nro da parcela e a referencia da parcela filha (Ex: 01A, 01B)
aAdd(aSemSX3,{"TMP_PARC" ,"C",03,0})

//RMD - 10/11/07 - Nova legislação de câmbio
If EECFlags("CAMBIO_EXT") .Or. AVFLAGS("CAMBIO_EXP_MOV_EXT")
   aAdd(aSemSX3, {"EEQ_INTERN" , AvSx3("EEQ_INTERN", AV_TIPO), AvSx3("EEQ_INTERN", AV_TAMANHO), AvSx3("EEQ_INTERN", AV_DECIMAL)})
EndIf

If (IsIntEnable("001") .OR. IsIntEnable("010")) .And. (aScan(aSemSx3, {|x| AllTrim(x[1]) == "EEQ_FINNUM" }) == 0)
   aAdd(aSemSX3, {AvKey("EEQ_FINNUM", "X3_CAMPO"), AvSx3("EEQ_FINNUM", AV_TIPO), AvSx3("EEQ_FINNUM", AV_TAMANHO), AvSx3("EEQ_FINNUM", AV_DECIMAL)})
   aAdd(aCampoTMP, {{|| TMP->EEQ_FINNUM },"", AvSx3("EEQ_FINNUM", AV_TITULO)})
EndIf

If AVFLAGS("EEC_LOGIX") .And. aScan(aSemSx3, {|x| AllTrim(x[1]) == "EEQ_SEQBX" }) == 0
   aAdd(aSemSX3, {AvKey("EEQ_SEQBX", "X3_CAMPO"), AvSx3("EEQ_SEQBX", AV_TIPO), AvSx3("EEQ_SEQBX", AV_TAMANHO), AvSx3("EEQ_SEQBX", AV_DECIMAL)})
   aAdd(aCampoTMP, {{|| TMP->EEQ_SEQBX },"", AvSx3("EEQ_SEQBX", AV_TITULO)})
   
   aAdd(aSemSX3, {AvKey("EEQ_DESCON", "X3_CAMPO"), AvSx3("EEQ_DESCON", AV_TIPO), AvSx3("EEQ_DESCON", AV_TAMANHO), AvSx3("EEQ_DESCON", AV_DECIMAL)})
   aAdd(aCampoTMP, {{|| AllTrim(TransForm(TMP->EEQ_DESCON,AVSX3("EEQ_DESCON",6))) },"", AvSx3("EEQ_DESCON", AV_TITULO)})
EndIf

If lCpoAcrDcr
   aAdd(aSemSX3, {AvKey("EEQ_ACRESC", "X3_CAMPO"), AvSx3("EEQ_ACRESC", AV_TIPO), AvSx3("EEQ_ACRESC", AV_TAMANHO), AvSx3("EEQ_ACRESC", AV_DECIMAL)})
   aAdd(aCampoTMP, {{|| AllTrim(TransForm(TMP->EEQ_ACRESC,AVSX3("EEQ_ACRESC",6))) },"", AvSx3("EEQ_ACRESC", AV_TITULO)})

   aAdd(aSemSX3, {AvKey("EEQ_DECRES", "X3_CAMPO"), AvSx3("EEQ_DECRES", AV_TIPO), AvSx3("EEQ_DECRES", AV_TAMANHO), AvSx3("EEQ_DECRES", AV_DECIMAL)})
   aAdd(aCampoTMP, {{|| AllTrim(TransForm(TMP->EEQ_DECRES,AVSX3("EEQ_DECRES",6))) },"", AvSx3("EEQ_DECRES", AV_TITULO)})

   aAdd(aSemSX3, {AvKey("EEQ_MULTA", "X3_CAMPO"), AvSx3("EEQ_MULTA", AV_TIPO), AvSx3("EEQ_MULTA", AV_TAMANHO), AvSx3("EEQ_MULTA", AV_DECIMAL)})
   aAdd(aCampoTMP, {{|| AllTrim(TransForm(TMP->EEQ_MULTA,AVSX3("EEQ_MULTA",6))) },"", AvSx3("EEQ_MULTA", AV_TITULO)})

   aAdd(aSemSX3, {AvKey("EEQ_JUROS", "X3_CAMPO"), AvSx3("EEQ_JUROS", AV_TIPO), AvSx3("EEQ_JUROS", AV_TAMANHO), AvSx3("EEQ_JUROS", AV_DECIMAL)})
   aAdd(aCampoTMP, {{|| AllTrim(TransForm(TMP->EEQ_JUROS,AVSX3("EEQ_JUROS",6))) },"", AvSx3("EEQ_JUROS", AV_TITULO)})

   aAdd(aSemSX3, {AvKey("EEQ_DESCON", "X3_CAMPO"), AvSx3("EEQ_DESCON", AV_TIPO), AvSx3("EEQ_DESCON", AV_TAMANHO), AvSx3("EEQ_DESCON", AV_DECIMAL)})
   aAdd(aCampoTMP, {{|| AllTrim(TransForm(TMP->EEQ_DESCON,AVSX3("EEQ_DESCON",6))) },"", AvSx3("EEQ_DESCON", AV_TITULO)})
EndIf

//TRP - 29/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

cWORKEEQ  := E_CRIATRAB("EEQ",aSemSX3,"TMP")
//ASK 14/03/07 - Retirado o campo EEQ_EVENT do aHeader e do aCampoTMP para nao duplicar a informação no browse
nPos:= aScan(aHeader,{|x|x[2]="EEQ_EVENT"})
If nPos > 0
   nPos2:= aScan(aCampoTMP,{|x|x[3]=aHeader[nPos][1]})
   If nPos2>0
      aDel(aCampoTMP,nPos2)
      aSize(aCampoTMP,len(aCampoTMP)-1)
   EndIf
   aDel(aHeader,nPos)
   aSize(aHeader,len(aHeader)-1)
EndIf

//MFR OSSME-3630 14/08/2019
if funname() != "EECAF900"
   nPos:= aScan(aHeader,{|x|x[2]="EEQ_DTEMBA"})
   If nPos > 0
      nPos2:= aScan(aCampoTMP,{|x|x[3]=aHeader[nPos][1]})
      If nPos2>0
         aDel(aCampoTMP,nPos2)
         aSize(aCampoTMP,len(aCampoTMP)-1)
      EndIf
      aDel(aHeader,nPos)
     aSize(aHeader,len(aHeader)-1)
   EndIf
EndIf   

INDREGUA("TMP",cWORKEEQ+TEOrdBagExt(),"EEQ_PARC" ,"AllwayTrue()","AllwaysTrue()",STR0008) //"Processando Arquivo Temporario"

cWORKEEQ2  := CRIATRAB(,.F.)
INDREGUA("TMP",cWORKEEQ2+TEOrdBagExt(),"EEQ_ORIGEM" ,"AllwayTrue()","AllwaysTrue()",STR0008) //"Processando Arquivo Temporario"

cWorkEEQ5  := CriaTrab(,.F.)
IndRegua("TMP",cWorkEEQ5+TEOrdBagExt(),"EEQ_PARVIN+EEQ_PARC","AllwayTrue()","AllwaysTrue()",STR0008) //"Processando Arquivo Temporario"

If EECFlags("FRESEGCOM")
   cWorkEEQ6  := CriaTrab(,.f.)
   IndRegua("TMP",cWorkEEQ6+TEOrdBagExt(),"EEQ_EVENT","AllwayTrue()","AllwaysTrue()",STR0008)
   Set Index to (cWORKEEQ+TEOrdBagExt()),(cWORKEEQ2+TEOrdBagExt()),(cWORKEEQ5+TEOrdBagExt()),(cWorkEEQ6+TEOrdBagExt()) // ** JPM
Else
   Set Index to (cWORKEEQ+TEOrdBagExt()),(cWORKEEQ2+TEOrdBagExt()),(cWORKEEQ5+TEOrdBagExt()) // ** JPM
EndIf
   //Set Index to (cWORKEEQ+OrdBagExt()),(cWORKEEQ2+OrdBagExt()),(cWORKEEQ5+OrdBagExt()),(cWorkEEQ6+OrdBagExt())

If lFinanciamento
   aCAMPOS := ARRAY(0)
   aHEADER    := {}
   cWORKEEQ3  := E_CriaTrab(,aSemSX3EEQ,"WorkEEQ")
   cWORKEEQ4  := E_Create(,.F.)
   INDREGUA("WorkEEQ",cWORKEEQ3+TEOrdBagExt(),"EEQ_PARC+EF2_CONTRA"+If(lTemChave,"+EF2_BAN_FI+EF3_PRACA"+If(lEFFTpMod,"+EF3_SEQCNT",""),""),"AllwayTrue()","AllwaysTrue()",STR0008) //"Processando Arquivo Temporario"
   INDREGUA("WorkEEQ",cWORKEEQ4+TEOrdBagExt(),"EEQ_NRINVO+EEQ_PARC","AllwayTrue()","AllwaysTrue()",STR0008) //"Processando Arquivo Temporario"
   Set Index to (cWORKEEQ3+TEOrdBagExt()), (cWORKEEQ4+TEOrdBagExt())

   FAF2Header()
   EF3->(dbSetOrder(3))

   aHeaderOld := aClone(aHeader)
EndIf

EEC->(dbSetOrder(1))
EEQ->(DBSETORDER(1))
EEQ->(DBSEEK(XFILIAL("EEQ")+EEC->EEC_PREEMB))

Begin Sequence
   DO WHILE ! EEQ->(EOF()) .AND.;
      EEQ->(EEQ_FILIAL+EEQ_PREEMB) = (XFILIAL("EEQ")+EEC->EEC_PREEMB)

      // ** By JBJ - 12/11/2002 - 17:18.
      If lPagtoAnte
         If EEQ->EEQ_TIPO = "A" // Verifica se o lançamento é um adiantamento.
            IF !EECFlags("FRESEGCOM") .Or. EEQ->EEQ_FASE <> "E"
               EEQ->(DbSkip())
               Loop
            EndIf
         Endif
      EndIf

      TMP->(reclock("TMP",.T.)) //DBAPPEND()
      //Para evitar erro nos inicializadores padrão na chamada do AvReplace (alguns campos da memória são considerados).
      RegToMemory("EEQ",,, .F.)
      AVREPLACE("EEQ","TMP")
      TMP->TMP_RECNO := EEQ->(RecNo())
      TMP->TRB_ALI_WT:= "EEQ"
      TMP->TRB_REC_WT:= EEQ->(Recno())

      If !SoftLock("EEQ")
         Break
      EndIf

      /* Carrega o Valor para Fechamento de Câmbio.
      Vl.Fech.Cambio = Valor da parcela subtraído da Soma de comissão do tipo conta gráfica mais o total de comissão do tipo deduzir da fatura. */
      TMP->EEQ_VLFCAM := AF200VLFCAM("TMP")

      If Empty(TMP->EEQ_PARVIN) .And. Empty(TMP->EEQ_ORIGEM)
         TMP->EEQ_PARVIN := TMP->EEQ_PARC
      ElseIf Empty(TMP->EEQ_PARVIN) .And. !Empty(TMP->EEQ_ORIGEM)
         nPosTmp := Tmp->(RecNo())
         aOrdTmp := SaveOrd("Tmp")

         Tmp->(DbSetOrder(1))
         If Tmp->(DbSeek(TMP->EEQ_ORIGEM))
            cParVin := TMP->EEQ_PARVIN
         EndIf

         Tmp->(DbGoTo(nPosTmp))
         Tmp->EEQ_PARVIN := cParVin
         RestOrd(aOrdTmp)
      EndIf

      If AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal("TMP")  .And. !Empty(TMP->EEQ_BCOEXT) .And. TMP->EEQ_MOEDA == Posicione("SA6",1, xFilial("SA6")+ AvKey(TMP->EEQ_BCOEXT,"A6_COD") + AvKey(TMP->EEQ_AGCEXT,"A6_AGENCIA") + AvKey(TMP->EEQ_CNTEXT,"A6_NUMCON"), "A6_MOEEASY")     
         TMP->EEQ_MOEBCO := Posicione("SA6",1, xFilial("SA6")+ AvKey(TMP->EEQ_BCOEXT,"A6_COD") + AvKey(TMP->EEQ_AGCEXT,"A6_AGENCIA") + AvKey(TMP->EEQ_CNTEXT,"A6_NUMCON"), "A6_MOEEASY")
         TMP->EEQ_PRINBC := 1
      EndIf

      If EasyEntryPoint("EECAF200")
         ExecBlock("EECAF200", .f., .f., "ACERTA_TMP")
      Endif

      If lFinanciamento
         GrvArrayFAF2()
      EndIf

      // ** AAF 04/02/05 - Processos de Demurrage
      If EEQ->EEQ_EVENT == EV_DEM_PG .OR. EEQ->EEQ_EVENT == EV_DEM_RC
         aAdd(aDemurrage,EEQ->EEQ_PROR)
      Endif

      if TMP->( islocked() )
         TMP->( msunlock() )
      endif

      EEQ->(DBSKIP())
   ENDDO

   Tmp->(DbGoTop())

   // ** By JBJ - 13/01/03 - Work para cotação de cambio.
   If lCotaCambio
      aCampos:= Array(EXG->(FCount()))
      Aadd(aSemSx3,{"RECNO","N",10,0})
      cArq   := E_CriaTrab("EXG",aSemSx3,"Work_Cot")
      IndRegua("Work_Cot",cArq+TEOrdBagExt(),"EXG_PREEMB+EXG_PARC+EXG_BANC+EXG_CORR",,,STR0037) //"Processando Arquivo Temporário..."
      Set Index To (cArq+TEOrdBagExt())
      aCampos:=Array(EEQ->(FCount()))

      EXG->(DbSetOrder(1))

      Do While TMP->(!Eof())
         If EXG->(DbSeek(xFilial("EXG")+TMP->EEQ_PREEMB+TMP->EEQ_PARC))
            Do While EXG->(!Eof()) .And. EXG->EXG_FILIAL == xFilial("EXG")  .And.;
                                         EXG->EXG_PREEMB == TMP->EEQ_PREEMB .And.;
                                         EXG->EXG_PARC   == TMP->EEQ_PARC
               Work_Cot->(DbAppend())
               AvReplace("EXG","Work_Cot")
               Work_Cot->RECNO := EXG->(RecNo())
               Work_Cot->TRB_ALI_WT:= "EXG"
               Work_Cot->TRB_REC_WT:= EXG->(Recno())
               EXG->(DbSkip())
            EndDo
         EndIf

         TMP->(DbSkip())
      EndDo
      TMP->(DBGOTOP())
   EndIf

   aHeader := aClone(aHeaderOld)

   If lFinanciamento
      EF3->(dbSetOrder(1))
   EndIf

   DBSELECTAREA("EEC")
   FOR Z := 1 TO EEC->(FCOUNT())
       M->&(EEC->(FIELDNAME(Z))) := EEC->(FIELDGET(Z))
   NEXT

   // ** By JBJ - 20/01/03 - 16:59.
   If EasyEntryPoint("EECAF200")
      ExecBlock("EECAF200",.F.,.F.,{"PE_INICIO",nOpc})
   Endif

   // ** By JBJ - 11/03/03 - (Inclusão do campo Parcela)
   aSize(aCampoTmp,Len(aCampoTmp)+1)

   If !lOkEVENT
      aIns(aCampoTmp,1)
      aCampoTmp[1] := {{||TMP->TMP_PARC},"",STR0237} //STR0237	"Origem"
   Else
      aIns(aCampoTmp,2)
      aCampoTmp[2] := {{||TMP->TMP_PARC},"",STR0237}//STR0237	"Origem"
   EndIf

   If EECFlags("FRESEGCOM")
      /* Tratamentos para inclusão de coluna com o tipo da parcela de câmbio.
         - Adiantamentos/Cambio a Pagar/Cambio a Receber */
      aSize(aCampoTmp,Len(aCampoTmp)+3)
      aIns(aCampoTmp,1)
      aCampoTmp[1] := {{||AllTrim(BscXBox("EEQ_TIPO",TMP->EEQ_TIPO))},"",AvSx3("EEQ_TIPO",AV_TITULO)}

      // Tratamentos para inclusão de coluna com o Valor de Fechamento de Câmbio.
      aIns(aCampoTmp,8)
      aCampoTmp[8] := {{||AllTrim(Transf(Tmp->EEQ_VLFCAM,AVSX3("EEQ_VLFCAM",AV_PICTURE)))},"",;
                                                         AvSx3("EEQ_VLFCAM",AV_TITULO)}

      // ** GFC - 01/12/05 - Incluir o evento e sua respectiva descrição, e o Tipo do Contrato.
      aIns(aCampoTmp,2)
      aCampoTmp[2] := {{|| TMP->EEQ_EVENT+" - "+Posicione("EC6",1,XFilial("EC6")+"EXPORT"+TMP->EEQ_EVENT,"EC6_DESC") },"",AvSx3("EEQ_EVENT",AV_TITULO)}

      If lEEQ_TP_CON
         aAdd(aCampoTmp,{{||AllTrim(BscXBox("EEQ_TP_CON",TMP->EEQ_TP_CON))},"",AvSx3("EEQ_TP_CON",AV_TITULO)})
      EndIf
      // **
   EndIf

   // ** By JBJ - 12/03/03 (Set da origem da(s) parcela(s).)
   AF200SetOrigem()

   Tmp->(DbSetOrder(3))
   Tmp->(DbGoTop())

   If Type("lEEQAuto") == "L" .And. lEEQAuto
      If Type("bEEQAuto") == "B"
         Eval(bEEQAuto)
      EndIf
      If Af200ValCambio()
         nBTOP := 1
      Else
         nBTOP := 0
      EndIf
   ElseIf lExecAuto
      Do Case
         Case nOpcDetAuto == LIQ_DET
            If EasySeekAuto("TMP", aAutoItens, 1)
               If ValFina("LIQ") .And. AF200DetMan(LIQ_DET)
                  Eval(bOk)
               Else
                  EasyHelp(STR0310,STR0016)//"Erro na execução da rotina automática. Não foi possível liquidar a parcela."  #Aviso
               EndIf
            Else
               EasyHelp(STR0311,STR0016) //"Erro na execução da rotina automática. A parcela não foi localizada."  #Aviso
            EndIf
        Case nOpcDetAuto == ELQ_DET
            If EasySeekAuto("TMP", aAutoItens, 1)
               If ValFina("LIQEST") .And. AF200DetMan(ELQ_DET)
                  Eval(bOk)
               Else
                  EasyHelp(STR0312, STR0016) //"Erro na execução da rotina automática. Não foi possível estornar a liquidação da parcela."  #Aviso
               EndIf
            Else
               EasyHelp(STR0311,STR0016) //"Erro na execução da rotina automática. A parcela não foi localizada."  #Aviso
            EndIf
         Case nOpcDetAuto == ALT_DET
            If EasySeekAuto("TMP", aAutoItens, 1)
               If AF200DetMan(ALT_DET)
                  Eval(bOk)
               Else
                  EasyHelp(STR0310,STR0016) //"Erro na execução da rotina automática. Não foi possível atualizar a parcela."  #Aviso
               EndIf
            Else
               EasyHelp(STR0311,STR0016) //"Erro na execução da rotina automática. A parcela não foi localizada."  #Aviso
            EndIf
         Case nOpcDetAuto == INC_DET
            If AF200DetMan(INC_DET)
               Eval(bOk)
            Else
               EasyHelp(STR0313,STR0016) //"Erro na execução da rotina automática. Não foi possível incluir a parcela."  #Aviso
            EndIf
         Case nOpcDetAuto == 95 // exclusão da parcela
            If EasySeekAuto("TMP", aAutoItens, 1)
               lEstorno:=.t.
               AF200ESTPARC()
               AF200STATUS()
               Eval(bOk)
            Else
               EasyHelp(STR0314,STR0016) //"Erro na execução da rotina automática. Não foi possível excluir a parcela."  #Aviso
            EndIf
      EndCase
   Else
      DEFINE MSDIALOG oDlg TITLE STR0009 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Câmbio"  #Aviso
         aPOS     := POSDLGUP(oDlg)
		 aPos[1] -= 3  // MCF - 11/09/2015
         ENCHOICE("EEC",RECNO(),nOpc,,,,aEEC,aPOS,{})
         aPOS     := POSDLGDOWN(oDlg)
		 aPos[3] -= 3  // MCF - 11/09/2015
         oMSELECT := MsSelect():New("TMP",,,aCampoTMP,@lInverte,@cMarca,aPOS)
         oMSELECT:BAVAL := {|| AF200DetMan(IF(nOpc <> VISUALIZAR,ALT_DET,VIS_DET)),;
                                           oMSELECT:oBrowse:Refresh(),;
                                           oGet_x:SetFocus(),;
                                           oMSelect:oBrowse:SetFocus()}

         @200,200 MsGet oGet_x Var cGet_x Of oDlg
         oDlg:lMaximized:=.T.
       ACTIVATE MSDIALOG oDlg ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS)
   EndIf

   nTmpOrd  := TMP->(IndexOrd())//FSM - 07/03/2012

   aRLockList := EEQ->( DBRLockList() )
   For i := 1  to  Len(aRLockList)
      EEQ->( DBGoTo(aRLockList[i]) )
      EEQ->( MSUnLock() )
   Next i

   // ** PLB 21/07/06 - Tratamento Multi-Usuario
   If lFinanciamento
      aRLockList := EF1->( DBRLockList() )
      For i := 1  to  Len(aRLockList)
         EF1->( DBGoTo(aRLockList[i]) )
         EF1->( MSUnLock() )
      Next i
   EndIf

   IF nBTOP = 1  .And. nOpc <> VISUALIZAR

      If !Avflags("ADTFOREAI")
         GrvAF200Mn() // NCF - 23/03/2017 - Função única para onde foi migrada toda a gravação do câmbio
      EndIf

      // PLB 10/08/07
      If lRollBack
         lRollBack := .F.
         Break
      EndIf

      // ** By JBJ - 20/01/03 - 17:20.
      If EasyEntryPoint("EECAF200")
         aTmpOrd := SaveOrd("TMP")
         ExecBlock("EECAF200",.F.,.F.,{"PE_AF200MAN_GRVOK",nOpc})
         If Select("TMP") > 0
            TMP->(DbCloseArea())
         EndIf
         
         Af200AbTmp()
         RestOrd(aTmpOrd, .T.)
         
      Endif

   ENDIF
End Sequence

If nOpc <> VISUALIZAR
   EEC->(MsUnlock())
EndIf

If Select("TMP") > 0  //TRP-18/12/07
   If EECFlags("FRESEGCOM")
      TMP->(E_EraseArq(cWORKEEQ,cWorkEEQ2,cWorkEEQ5))
      fErase(cWORKEEQ6+TEOrdBagExt())
   Else
      TMP->(E_EraseArq(cWORKEEQ,cWorkEEQ2,cWorkEEQ5))
   EndIf
Endif

If lFinanciamento
   WorkEEQ->(E_EraseArq(cWORKEEQ3,cWorkEEQ3,cWorkEEQ4))
EndIf

If lCotaCambio
   Work_Cot->(E_EraseArq(cArq))
EndIf

if EasyEntryPoint("EECAF200")
	ExecBlock("EECAF200", .f., .f., "GERA_MOV_MS")
ENDIF

//RRC - 17/12/2013 - Integração SIGAEEC x SIGAESS (Despesas Internacionais)
If lEECESS .And. nBTOP = 1 .And. (!Empty(EEC->EEC_DTEMBA) .Or. nOpc == ALTERAR .Or. nOpc  == EXCLUIR)
   AE100ESS(EEC->EEC_PREEMB,ALTERAR)
EndIf

// **FSM - 29/02/2012 - Tratamento para correta baixa de titulo no financeiro
cModulo := aOldModulo[1]
nModulo := aOldModulo[2]

RETURN(NIL)

/*
Função     : Af200DetMan()
Objetivos  : Manutenção de parcelas de câmbio
Parâmetros : nTipo    - Inclusão, Alteração, Exclusão, Visualização, Liquidação e Estorno de Liquidação.
             lCotacao - Chamada da rotina de cotação de câmbio.
             lAuto    - manutenção automática
             bAltera  - codeblock executado imediatamente antes da dialog, para edição de variáveis de memória
*/

Function AF200DetMan(nTipo,lCotacao,lAuto,bAltera)

LOCAL oDLG,Z,aPOS,nBTOP,oBTN,cTitulo:="",;
      aBUTTONS := {},;
      cALIAS   := ALIAS(),;
      ;// bCANCEL  := nil,; JPM - passou a ser private para uso em rdmake
      aOrd     := SaveOrd("TMP"),;
      cPictDt := "  /  /  "

Local nLinha := 0, nCol1:=0,nCol2:=0,nCol3:=0
Local oLbCGrafica, oLbARemeter, oLbADeduzir
Local cParVin, nRecTmp := 0, nTamCol:=0

// ** GFC 11/08/05 - Variáveis para financiamento
Local aVinc:={}, nx, ni, nVlVincPar:=0, nSaldo:=0, nIncPos:=0, nPosSaldo  := 0
Local nValCamb := 0, nValVinc := 0, nValDesc := 0, nTipOpc
Local lTemFinanc := .F.
Local aOrdFinanc := {}
// **

Default lAuto := .F., bAltera := {|| }

PRIVATE aTELA[0,0],aGETS[0]

Private nTipoDet := nTipo, nVlSaldo := 0
Private oGetCGrafica, oGetARemeter, oGetADeduzir
Private aALTERA  := {}, bOK := nil // By JPP - 31/08/2005 - 14:15 - A variavel aAltera passou a ser private para customização em ponto de entrada.
Private aMostra := {} //Fernando Rossetti. Variavel passou a ser private para uso em rdmake.

// JPM - 15/12/05 - declarado novo aRotina, mas com opção de inclusão, para que possa editar os campos-chave na enchoice
Private aROTINA := {{STR0002,"AxPesqui",0,1},; //"Pesqu1isar "
                    {STR0003,"AF200MAN",0,2},; //"Visualizar"
                    {"","",0,3}             ,;
                    {STR0004,"AF200MAN",0,4},; //"Alterar "
                    {STR0021,"AF200REL",0,4}}  //"Follow-Up"

Private bCancel //JPM - 24/04/06

Begin Sequence
   nTipoOPC := nTipOpc := nTipo

   // Consistências para alteração das parcelas
   If nTipo <> INC_DET .And. Tmp->(Eof()) .AND. Tmp->(Bof())
      HELP(" ",1,"AVG0000632") // "Não existem registros para a manutenção !"
      Break
   EndIf

   If nTipo == LIQ_DET
      If !Empty(Tmp->EEQ_PGT)
         EasyHelp(STR0077+Transf(Tmp->EEQ_PGT,cPictDt)+".",STR0014) //"Esta parcela foi liquidada em : "###"Atenção"
         If lExecAuto
            Break
         Else
            nTipo := VIS_DET
         EndIf
      EndIf
   EndIf

   If nTipo == ALT_DET
      nOldTipo:= nTipo
      If !Empty(TMP->EEQ_PGT)
         //RMD - 17/10/14 - Permite editar a parcela caso existam campos de usuário
         If Type("aUserFields") <> "A" .Or. Len(aUserFields) == 0
            Help(" ",1,"AVG0005075") //MSGINFO("Parcela Com Câmbio Contratado !","Atenção")
            Af200DetMan(VIS_DET)
            Break
         EndIf
      EndIf
   EndIf

   //ER - 19/03/2007 - Parcelas de Desconto não podem ser liquidadas.
   If nTipo == LIQ_DET
      If Left(TMP->EEQ_EVENT,1) == "8"
         easyhelp(STR0238) //MsgInfo(STR0238)//	STR0238	"Parcelas de Desconto não podem ser Liquidadas."
         Break
      EndIf
   EndIf

   If nTipo <> VIS_DET  .And.  nTipo <> INC_DET
      If !Empty(TMP->EEQ_DTVC) .And. !lEstParVC
         Help(" ",1,"AVG0005223") //"A variação cambial dessa parcela já foi processada !"###"Aviso"
         AF200DetMan(VIS_DET)
         Break

      //RMD - 28/01/15 - Permite alterar os campos de usuário de parcelas com FFC, mas exibe o aviso.
      ElseIf !Empty(TMP->EEQ_FFC) .And. If(Type("aUserFields") <> "A" .Or. Len(aUserFields) == 0, .T., (HELP(" ",1,"AVG0005076"), .F.))
         HELP(" ",1,"AVG0005076") //MSGINFO("Parcela Com FFC !","Atenção")
         AF200DetMan(VIS_DET)
         Break

      // ** JPM - 10/12/2009 - Nova Legislação Cambial
      // ** Obs: essa validação não é necessária na rotina de FFC, pois no momento em que uma parcela de FFC é
      //         associada a um câmbio de importação, a mesma é excluída da FFC e passa a ser tratada individualmente.
      ElseIf EECFlags("CAMBIO_EXT") .And. (Type("lAd101VImp") <> "L" .Or. !lAd101VImp) .And.; // só faz a validação se não estiver sendo alterada pela rotina da importação
             !Empty(TMP->(EEQ_EICFIL+EEQ_EICHAW+EEQ_EICPOD+EEQ_EICINV+EEQ_EICFOR+EEQ_EICLOJ+EEQ_EICLIN))

         EasyHelp(STR0239+ENTER+ENTER+;//	STR0239	"Esta parcela foi liquidada através de Transferência no Exterior, pela seguinte parcela de câmbio de importação:"
                 AllTrim(AvSx3("EEQ_EICFIL",AV_TITULO))+": "+AllTrim(TMP->EEQ_EICFIL)+ENTER+;
                 AllTrim(AvSx3("EEQ_EICHAW",AV_TITULO))+": "+AllTrim(TMP->EEQ_EICHAW)+ENTER+;
                 AllTrim(AvSx3("EEQ_EICPOD",AV_TITULO))+": "+AllTrim(TMP->EEQ_EICPOD)+ENTER+;
                 AllTrim(AvSx3("EEQ_EICINV",AV_TITULO))+": "+AllTrim(TMP->EEQ_EICINV)+ENTER+;
                 AllTrim(AvSx3("EEQ_EICFOR",AV_TITULO))+": "+AllTrim(TMP->EEQ_EICFOR)+ENTER+;
                 AllTrim(AvSx3("EEQ_EICLOJ",AV_TITULO))+": "+AllTrim(TMP->EEQ_EICLOJ)+ENTER+;
                 AllTrim(AvSx3("EEQ_EICLIN",AV_TITULO))+": "+AllTrim(TMP->EEQ_EICLIN);
                 ,STR0014) //STR0014  	"Atenção"
         If !lExecAuto
            AF200DetMan(VIS_DET)
         EndIf
         Break
      EndIf
   Endif
	
	//THTS - 29/03/2017 - Nao permite estorno de liquidacao para parcela vinculada a adiantamento ao fornecedor.
	If !avflags("EEC_LOGIX") .and. TMP->EEQ_EVENT == "603" .And. !EasyVerModal("TMP") .And. nTipo == ELQ_DET .And. TMP->EEQ_TIPO $ "A" // MPG - 26/06/2018 - não permite estorno de liquidação de nenhum registro integração EAI
		EasyHelp(STR0295)// STR0295 - "Esta parcela foi liquidada com adiantamento. Para estornar, utilize a rotina 'Associação de Adiantamento'."
        If !lExecAuto
		   AF200DetMan(VIS_DET)
        EndIf
		Break
	EndIf

   If EECFlags("FRESEGCOM") .And. (nTipo <> INC_DET .And. nTipo <> VIS_DET)
      /* by jbj - Verifica se a parcela poderá ser editada. (Para todas as opções).
                  As parcelas de adiatamentos não poderão sofrer nenhum tipo de alteração. */
      // WFS 15/05/09 - Vide revisão no cabeçalho.
      If !(EasyGParam("MV_AVG0180", .F., .F.) .And. Tmp->EEQ_TIPO == "A" .And. (nTipo == LIQ_DET .Or. nTipo == ELQ_DET)) // Parcela de Adiantamento.
         If Type("lGerAdEEC") == "U" .or. !lGerAdEEC
            If !af201CanModify(nTipo)
               If (nTipo = INC_DET .Or. nTipo = ALT_DET)
                  nTipo := VIS_DET
               Else
                  Break
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
   If IsIntEnable("001")
      If (nTipo == ALT_DET .Or. nTipo == EXC_DET) .And. lParcLiq
         EasyHelp(STR0240, STR0016)//	STR0240	"Como foi acessada a rotina de liquidação, não será possível alterar parcelas até que a manutenção seja confirmada/cancelada." //STR0016	 "Aviso"
         Break
      EndIf
      If (nTipo == LIQ_DET .Or. nTipo == ELQ_DET) .And. lParcAlt
         EasyHelp(STR0241, STR0016) //STR0241	"Como foi acessada a rotina de alteração, não será possível liquidar/estornar parcelas até que a manutenção seja confirmada/cancelada." //STR0016	 "Aviso"
         Break
      EndIf
   EndIf
   If AvFlags("EEC_LOGIX")                               //NCF - 17/12/2014
      If nTipo == ELQ_DET .And. !Empty(TMP->EEQ_SEQBX)
         cFinNum := TMP->EEQ_FINNUM
         cSeqBx  := TMP->EEQ_SEQBX
         nRecTMP := TMP->(Recno())
         lEstBx  := .T.

         TMP->(DbGoTop())
         Do While TMP->(!Eof())
            If TMP->(Recno()) == nRecTMP .Or. Empty(TMP->EEQ_SEQBX)
               TMP->(DbSkip())
               Loop
            EndIf
            If TMP->EEQ_FINNUM == cFinNum .And. VAL(TMP->EEQ_SEQBX) > VAL(cSeqBx) .AND. !Empty(TMP->EEQ_PGT)
               EasyHelp(STR0315,STR0016) // 'Existem parcelas baixadas posteriormente a esta! É necessário estornar estas baixas para estornar a baixa da parcela atual' #Aviso
               lEstBx  := .F.
               EXIT
            EndIf
            TMP->(DbSkip())
         EndDo

         TMP->(DbGoto(nRecTMP))

         If !lEstBx
            Break
         EndIf
      EndIf
   EndIf

   // ** GFC - 30/06/05 - Se o parâmetro MV_MV_LIQPARC estiver ativado, não irá permitir liquidar a parcela caso a
   //                    mesma não seja totalmente câmbio pronto ou totalmente vinculada a contrato de financiamento
   If lFinanciamento .and. nTipo == LIQ_DET .and. EasyGParam("MV_LIQPARC",,.F.) .and. !VerLiqPar()
      Break
   EndIf
   // **

  // ** JPM - 29/12/2009 - Somente permite baixa gerencial de parcelas a receber
   If nTipo == BXG_DET
      If !IsReceita(TMP->EEQ_EVENT)
         EasyHelp(STR0242,STR0014)//STR0242	"Só é possível efetuar a baixa gerencial de parcelas a receber." //STR0014  	"Atenção"
         Break
      EndIf
   EndIf
   // ** Set das ações para os botões.
   If Avflags("ADTFOREAI")
      bOk := IF(nTipo == VIS_DET,{||nBtop := 0, oDlg:End()},;
                                 {||nBtop := 1, If(Obrigatorio(aGets,aTela) .And. AF200Valid("BT_OK")      .And.;                               
                                                   AF200Valid("EEQ_EVENT")  .And. AF200Valid("EEQ_NRINVO") .And.;
                                                   AF200Valid("EEQ_VL")     .And. AF200Valid("EEQ_EQVL")   .And.;
                                                   AF200Valid("EEQ_PARI")   .And. AF200BXPARC(nTipo)       .And.;
                                                   GrvDetMan(nBtop,nTipo)   .And. Af200ValCambio()         .And.;
                                                   GrvAF200Mn(), If(!lExecAuto, oDLG:End(), ),nBtop:=0)})
   Else
      bOk := IF(nTipo == VIS_DET,{||nBtop := 0, oDlg:End()},;
                                 {||nBtop := 1, If(Obrigatorio(aGets,aTela) .And. AF200Valid("BT_OK")      .And.;
                                                   AF200Valid("EEQ_EVENT")  .And. AF200Valid("EEQ_NRINVO") .And.;
                                                   AF200Valid("EEQ_VL")     .And. AF200Valid("EEQ_EQVL")   .And.;
                                                   AF200Valid("EEQ_PARI")   .And. AF200BXPARC(nTipo),;
                                                   if(!lExecAuto, oDLG:End(),),nBtop:=0)})
   EndIf

   bCancel := {|| nBtop:=0, oDLG:End()}

   IF nTipo == ELQ_DET
      cTitulo := STR0031//"Estorno de Liquidação da Parcela"
   Elseif nTipo == ALT_DET
      cTitulo := STR0011 //"Alteração de Parcela"
   Elseif nTipo == LIQ_DET
      cTitulo := STR0030//"Liquidação da Parcela"
   Elseif nTipo == INC_DET
      cTitulo := STR0038 //"Inclusão de Parcela"
   ElseIf nTipo == BXG_DET
      cTitulo := STR0235 //STR0235	"Baixa Gerencial"
   Else
      cTitulo := STR0010//"Visualização de Parcela"
   EndIf

   // ** By JBJ - 13/01/03 - Liquidacao pela tela de cotacao de cambio.
   Default lCotacao := .f.

   DBSELECTAREA("TMP")
   TMP->(dbSetOrder(1))
   If nTipo <> INC_DET
      FOR Z := 1 TO TMP->(FCOUNT())
          M->&(TMP->(FIELDNAME(Z))) := TMP->(FIELDGET(Z))
      NEXT
      // ** PLB 11/10/06
      If EECFlags("FRESEGCOM")
         M->EEQ_DESIMP := Posicione("SA1",1,XFilial("SA1")+M->EEQ_IMPORT, "A1_NREDUZ")
      EndIf
      // **
   Else
      M->EEQ_IMPORT := CriaVar("EEQ_IMPORT")
      M->EEQ_IMLOJA := CriaVar("EEQ_IMLOJA")
      FOR Z := 1 TO TMP->(FCOUNT())
         If Left(TMP->(FIELDNAME(Z)),3) == "EEQ"
            M->&(TMP->(FIELDNAME(Z))) := CRIAVAR(TMP->(FIELDNAME(Z)))
         EndIf
      NEXT
      TMP->(dbGoBottom())

      // ** By EMS/VI 11/04/03
      M->EEQ_PARC    := SomaIt(TMP->EEQ_PARC)
      M->EEQ_PREEMB  := EEC->EEC_PREEMB
      M->EEQ_FILIAL  := xFilial("EEQ")//RMD - 06/06/19 - Para evitar erro no inicializador browse dos campos do novo registro no browse de parcelas (MsSelect)
      M->EEQ_EMISSA  := dDataBase

   EndIf

   If Type("aEEQAuto") == "A"
      aEval(aEEQAuto, {|x| Eval(MemVarBlock(x[1]), x[2]) })
   EndIf

   If lFinanciamento //.and. nTipo == LIQ_DET
      aOrdFinanc := SaveOrd({"EF3","WorkEEQ"})
		EF3->(dbSetOrder(3))
      WorkEEQ->(dbSetOrder(2))
      If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,If(TMP->EEQ_TP_CON $ "2/4","I","E"),"")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)+EV_EMBARQUE)) .Or.  WorkEEQ->(dbSeek(TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN))) //TAN //HVR SEEK
         lTemFinanc := .T.
			If nTipo == LIQ_DET
				Do While !WorkEEQ->(EOF()) .and. WorkEEQ->EEQ_NRINVO==TMP->EEQ_NRINVO .and.;
				WorkEEQ->EEQ_PARC==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN) .and. Empty(WorkEEQ->EF2_CONTRA)
					WorkEEQ->(dbSkip())
				EndDo
				If EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+iif(lTemChave, EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,""), ""))) .Or.;
					EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,If(WorkEEQ->EEQ_TP_CON $ "2/4","I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave, WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA, ""))) // ACSJ - 01/02/2005 //HVR SEEK

					If (aScan(aExcVinculo,{|x| x[1]==TMP->EEQ_PARC .and.;
					If(lEFFTpMod,x[10],"")+x[2]+iif(lTemChave,x[6]+x[7]+If(lEFFTpMod,x[9],""),"")==If(lEFFTpMod,If(WorkEEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+WorkEEQ->EF2_CONTRA+iif(lTemChave,WorkEEQ->EF2_BAN_FI+WorkEEQ->EF3_PRACA+If(lEFFTpMod,WorkEEQ->EF3_SEQCNT,""),"") .and. x[3]==1})) = 0
						M->EEQ_NROP := EF1->EF1_CONTRA
						If Empty(M->EEQ_BANC)
							//Alcir Alves - 03-11-05 - considerar o banco de movimentação nas vinculações  - conforme chamado 020324
							IF !EMPTY(EF1->EF1_BAN_MO)
								M->EEQ_BANC := EF1->EF1_BAN_MO
								M->EEQ_Agen   := EF1->EF1_AGENMO
								M->EEQ_NCon   := EF1->EF1_NCONMO
								SA6->(DbSetOrder(1))
								IF SA6->(DbSeek ( xFilial("SA6") + EF1->EF1_BAN_MO + EF1->EF1_AGENMO + EF1->EF1_NCONMO ))
									M->EEQ_NomeBC := SA6->A6_Nome
								ENDIF
							ELSE
								M->EEQ_BANC := EF1->EF1_BAN_FI
								M->EEQ_Agen   := EF1->EF1_AGENFI
								M->EEQ_NCon   := EF1->EF1_NCONFI
								SA6->(DbSetOrder(1))
								IF SA6->(DbSeek ( xFilial("SA6") + EF1->EF1_BAN_FI + EF1->EF1_AGENFI + EF1->EF1_NCONFI ))
									M->EEQ_NomeBC := SA6->A6_Nome
								ENDIF
							ENDIF
							//
						EndIf
						If lTemChave
							M->EF3_PRACA := EF1->EF1_PRACA
							If EF5->(DBSeek(EF1->EF1_PRACA))
								M->EF5_DESCRI := EF5->EF5_DESCRI
							Endif
							If lEFFTpMod
								M->EF3_SEQCNT := EF3->EF3_SEQCNT
							EndIf
						Endif
					Endif
				Endif
			EndIf
      EndIf
      RestOrd(aOrdFinanc,.t.)
   EndIf

   // ** By JBJ - 13/01/03 - Carrega as informações da cotação de fechamento de câmbio.
   If lCotacao
      M->EEQ_TX    := Work_Cot->EXG_TX
      M->EEQ_BANC  := Work_Cot->EXG_BANC
      M->EEQ_AGEN  := Work_Cot->EXG_AGEN
      M->EEQ_NCON  := Work_Cot->EXG_NCON
      M->EEQ_NOMEBC:= Work_Cot->EXG_NOMEBC
      M->EEQ_CORR  := Work_Cot->EXG_CORR
      M->EEQ_RFBC  := Work_Cot->EXG_RFBC
      M->EEQ_VLCOR := Work_Cot->EXG_VLCOR
   EndIf

   // Campos que seram apresentados na Enchoice
   aMOSTRA := {"EEQ_PARC","EEQ_VCT","EEQ_VL","EEQ_SOL","EEQ_DTNEGO",;
              /*"EEQ_DECAM",*/"EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC","EEQ_CORR","EEQ_FFC","EEQ_DTCE"}  //,"EEQ_EQVL"} - //FSM - 27/02/2012

   If EEQ->(FieldPos("EEQ_HVCT")) > 0
      aAdd(aMOSTRA,"EEQ_HVCT")
   EndIf

   If lOkEVENT
      aAdd(aMostra,"EEQ_EVENT")
      aAdd(aMostra,"EEQ_NRINVO")
   Endif

   IF nTipo == LIQ_DET .Or. nTipo == ELQ_DET .Or. nTipo == VIS_DET
      aAdd(aMostra,"EEQ_NROP")
      aAdd(aMostra,"EEQ_PGT")
      aAdd(aMostra,"EEQ_TX")
      aAdd(aMostra,"EEQ_EQVL")
   Endif

   // ** AAF 28/02/05 - Campo numero da operação deve ser exibido na alteração.
   If nTipo == ALT_DET
      aAdd(aMostra,"EEQ_NROP")
   EndIf
   // **

   If EEQ->(FieldPos("EEQ_OBS")) > 0
      aAdd(aMostra,"EEQ_OBS")
   EndIf

   /* By JBJ - 18/08/04 - Para realizar os  tratamentos para o evento da parcela, (Despesa/Receita)
                          os campos abaixo deverão ser manutenciados. */
   If EECFlags("FRESEGCOM")
      aAdd(aMostra,"EEQ_CODEMP")
      aAdd(aMostra,"EEQ_FORN")
      aAdd(aMostra,"EEQ_FOLOJA")
      aAdd(aMostra,"EEQ_MOEDA")
      aAdd(aMostra,"EEQ_PARI")
      aAdd(aMostra,"EEQ_TIPO")

      // ** JPM 15/04/05
      AAdd(aMostra,"EEQ_IMPORT")
      AAdd(aMostra,"EEQ_IMLOJA")
      AAdd(aMostra,"EEQ_DESIMP")  // PLB 11/10/06 - DESIMP passou a ser não-usado

      /* Campos referente aos tipos de comissão existentes.
         (Conta Gráfica/A remeter/ Deduzir da Fatura) */
      If (Tmp->EEQ_EVENT == EV_PRINC2 .And. TMP->EEQ_TIPO <> "A" .And. nTipo <> INC_DET)
         aAdd(aMostra,"EEQ_CGRAFI")
         aAdd(aMostra,"EEQ_AREMET")
         aAdd(aMostra,"EEQ_ADEDUZ")
      EndIf
      aAdd(aMostra,"EEQ_VLFCAM")
   EndIf

   //RMD - 08/11/07 - Baixa Gerencial
   If nTipo == BXG_DET
      aMostra := {}
      aAdd(aMostra, IncSpace("EEQ_DTCE", Len(SX3->X3_CAMPO), .F.))
   EndIf
   If !AvFlags("EEC_LOGIX") .or. ( isreceita(TMP->EEQ_EVENT) .and. AvFlags("EEC_LOGIX") )
      aAdd(aMostra, IncSpace("EEQ_BCOEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aMostra, IncSpace("EEQ_CNTEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aMostra, IncSpace("EEQ_AGCEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aMostra, IncSpace("EEQ_NBCEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aMostra, IncSpace("EEQ_NROPAG", Len(SX3->X3_CAMPO), .F.))
      aAdd(aMostra, IncSpace("EEQ_MOEBCO", Len(SX3->X3_CAMPO), .F.))
      aAdd(aMostra, IncSpace("EEQ_PRINBC", Len(SX3->X3_CAMPO), .F.))
      aAdd(aMostra, IncSpace("EEQ_VLMBCO", Len(SX3->X3_CAMPO), .F.))
      aAdd(aMostra, "EEQ_INTERN")
   EndIf

   IF lCpoAcrDcr
         If nTipo == INC_DET .OR. nTipo == ALT_DET
         //If IsReceita(TMP->EEQ_EVENT) //THTS - 30/07/2019 - NOPADO DTRADE-2802 - Permitir a utilizacao de Acrescimo e Descrescimo para eventos a pagar.
            aAdd(aMostra,"EEQ_ACRESC")
            aAdd(aMostra,"EEQ_DECRES")
				AAdd(aMostra, "EEQ_DESCON")
         //EndIf
      ElseIf nTipo == LIQ_DET
         aAdd(aMostra,"EEQ_ACRESC")
         aAdd(aMostra, "EEQ_DECRES")
         AAdd(aMostra, "EEQ_MULTA")
         AAdd(aMostra, "EEQ_JUROS")
         If aScan(aMostra, "EEQ_DESCON") == 0
            AAdd(aMostra, "EEQ_DESCON")
         EndIf
      EndIf
   ENDIF
   // Campos que serem editaveis na Enchoice
   aAltera := {}

   If nTipo == INC_DET .Or. nTipo == ALT_DET .Or. nTipo == LIQ_DET
      aALTERA:={"EEQ_DTCE" ,"EEQ_SOL"  ,"EEQ_DTNEGO",/*"EEQ_DECAM",*/;
                "EEQ_BANC" ,"EEQ_AGEN" ,"EEQ_NCON"  ,"EEQ_NOMEBC",;
                "EEQ_RFBC","EEQ_CORR","EEQ_PGT","EEQ_TX","EEQ_DTCE","EEQ_OBS","EEQ_VCT","EEQ_EQVL"}

		If !lTemFinanc //Caso a parcela possua contrato vinculado, nao permite alterar o campo Nr Operacao
			aAdd(aAltera,"EEQ_NROP")
		EndIf

      IF nTipo <> LIQ_DET
         aAdd(aAltera,"EEQ_VL")
      Endif

      If (nTipo == INC_DET .Or. nTipo == ALT_DET) .And. lOkEVENT
         aAdd(aAltera,"EEQ_NRINVO")
      Endif
      If nTipo == INC_DET .And. lOkEVENT
         aAdd(aAltera,"EEQ_EVENT")
      EndIf
      If EasyGParam("MV_EEC_ECO",,.f.) .Or. IsIntEnable("001") //NCF - 11/11/2009 - Verificação de Integração dom SIGAECO e SIGAEFF. Caso esteja
         aAdd(aAltera,"EEQ_FORN")                         //                   libera os campos para pre-enchimento pois na validação de
         aAdd(aAltera,"EEQ_FOLOJA")                       //                   alteração da parcela, os mesmos não podem estar vazios.
      EndIF

      If EECFlags("FRESEGCOM")
         If (nTipo == INC_DET .Or. nTipo == ALT_DET)
            aAdd(aAltera,"EEQ_CODEMP")
            aAdd(aAltera,"EEQ_PARI")

            // ** JPM - 15/04/05
            //AAF 24/07/05 - Só permitir alteração de Importador e Fornecedor nos eventos de outras despesas não contabilizadas.
            If nTipo == INC_DET .OR. ( Left(TMP->EEQ_EVENT,1) $ "3/4" .AND. If(lIntCont,Empty(TMP->EEQ_NR_CON),.T.) )
               AAdd(aAltera,"EEQ_IMPORT")
               AAdd(aAltera,"EEQ_IMLOJA")
               AAdd(aAltera,"EEQ_FORN")
               AAdd(aAltera,"EEQ_FOLOJA")
            Endif

            If nTipo == INC_DET
               aAdd(aAltera,"EEQ_MOEDA")
            EndIf

            // by jbj - Campos para controle dos tipos de comissões.
            If (Tmp->EEQ_EVENT == EV_PRINC2 .And. TMP->EEQ_TIPO <> "A" .And. nTipo <> INC_DET) .And. !IsIntEnable("010")
               if EECFlags("ALT_EASYLINK")
                  aAdd(aAltera,"EEQ_AREMET")
                  aAdd(aAltera,"EEQ_ADEDUZ")
               else
                  aAdd(aAltera,"EEQ_CGRAFI")
                  aAdd(aAltera,"EEQ_AREMET")
                  aAdd(aAltera,"EEQ_ADEDUZ")
               endif
            EndIf
         EndIf
      EndIf

      If EECFlags("CAMBIO_EXT") .And. !AVFLAGS("CAMBIO_EXP_MOV_EXT")
         aAdd(aAltera,"EEQ_NROPAG") //AAF 04/03/08 - Adicionado campo para ordem de pagamento.
      EndIf
      //LGS-28/08/2014 - Inclui os campos nos dois arrays para serem apresentados na tela e deixar editaveis para o cliente.
      If (nTipo == ALT_DET .Or. nTipo == LIQ_DET) .And. EEQ->(FieldPos("EEQ_MOTIVO")) > 0

         If !AvFlags("EEC_LOGIX") .or. AvFlags("EEC_LOGIX") .and. isreceita(TMP->EEQ_EVENT)
           aAdd(aMostra,'EEQ_MODAL' )
        EndIf

   		 If EasyGParam("MV_AVG0131",,.F.)
   		    aAdd(aMostra,'EEQ_MOTIVO')
   		 EndIf

    	 //Posiciona na parcela na base de dados para verificar se houve alteração nos campos.
    	 If TMP->TMP_RECNO <> 0
    	 	EEQ->(dbGoTo(TMP->TMP_RECNO))
    	 EndIf

         //RMD - 18/06/20 - O Tratamento do When dos campos já possui tratamento para avaliar quando estes campos podem ser alterados, e os critérios não estavam iguais. Removido para concentrar o tratamento no When.
         //If (Empty(TMP->EEQ_DTCE) .And. Empty(TMP->EEQ_PGT)) .And. (TMP->TMP_RECNO == 0 .Or. Empty(EEQ->EEQ_DTCE) .And. Empty(EEQ->EEQ_PGT))

            If EasyGParam("MV_AVG0131",,.F.)
               aAdd(aAltera,'EEQ_MOTIVO')
            EndIf

            //if !( IsReceita(TMP->EEQ_EVENT) .and. AvFlags("EEC_LOGIX") ) .or. ( IsReceita(TMP->EEQ_EVENT) .and. AvFlags("EEC_LOGIX") ) .and. nTipo != LIQ_DET
               If af200w('EEQ_MODAL')
                  aAdd(aAltera,'EEQ_MODAL' )
               Endif
               aAdd(aAltera, IncSpace("EEQ_BCOEXT", Len(SX3->X3_CAMPO), .F.))
               aAdd(aAltera, IncSpace("EEQ_AGCEXT", Len(SX3->X3_CAMPO), .F.))
               aAdd(aAltera, IncSpace("EEQ_CNTEXT", Len(SX3->X3_CAMPO), .F.))
               aAdd(aAltera, IncSpace("EEQ_NBCEXT", Len(SX3->X3_CAMPO), .F.))
               aAdd(aAltera, IncSpace("EEQ_MOEBCO", Len(SX3->X3_CAMPO), .F.))
               aAdd(aAltera, IncSpace("EEQ_PRINBC", Len(SX3->X3_CAMPO), .F.))
               aAdd(aAltera, IncSpace("EEQ_VLMBCO", Len(SX3->X3_CAMPO), .F.))
            /*endif
         Else
	        If EasyGParam("MV_AVG0131",,.F.) .And. Empty(EEQ->EEQ_PGT) .And. TMP->TMP_RECNO <> 0
	           aAdd(aAltera,'EEQ_MOTIVO') //LGS-09/03/2015
	        EndIf
	     EndIf*/
	  ElseIf nTipo == LIQ_DET .And. EEQ->(FieldPos("EEQ_MODAL")) > 0 .AND. !AVFLAGS("EEC_LOGIX") .And. (IsIntEnable("001") .OR. IsIntEnable("010"))
	  	 If AF200TITFIN(TMP->EEQ_FINNUM,1,TMP->EEQ_PARC)//RMD - 21/01/15 - Deve enviar a parcela.
		  	Do While aScan(aAltera, "EEQ_DTCE") > 0
	           aDel(aAltera, aScan(aAltera, "EEQ_DTCE"))
	           aSize(aAltera, Len(aAltera) - 1)
	        EndDo
	     EndIf
 	  EndIf

      // ** By JBJ - 12/02/04 - Tratamentos para alteração de campos de usuário.
      Sx3->(DbSetOrder(1),DbSeek("EEQ"))
      Do While Sx3->(!Eof()) .And. Sx3->X3_ARQUIVO == "EEQ"
         If Sx3->X3_PROPRI == "U"
            If (X3Uso(SX3->X3_USADO) .And. aScan(aAltera,AllTrim(Sx3->X3_CAMPO)) = 0)
               aAdd(aAltera,AllTrim(Sx3->X3_CAMPO))
            EndIf
         EndIf
         Sx3->(DbSkip())
      EndDo
   Endif

   //RMD - 07/11/07 - Baixa Gerencial
   If nTipo == BXG_DET
      If !Empty(TMP->EEQ_PGT)
         Help(" ",1,"AVG0005075")//"Parcela Com Câmbio Contratado !"
         nTipo := VIS_DET
         aAltera := {}
      Else
         aAdd(aAltera, IncSpace("EEQ_DTCE"  , Len(SX3->X3_CAMPO), .F.))
         aAdd(aAltera, IncSpace("EEQ_BCOEXT", Len(SX3->X3_CAMPO), .F.))
         aAdd(aAltera, IncSpace("EEQ_CNTEXT", Len(SX3->X3_CAMPO), .F.))
         aAdd(aAltera, IncSpace("EEQ_AGCEXT", Len(SX3->X3_CAMPO), .F.))
         aAdd(aAltera, IncSpace("EEQ_NBCEXT", Len(SX3->X3_CAMPO), .F.))
         If !AVFLAGS("CAMBIO_EXP_MOV_EXT")
            aAdd(aAltera,"EEQ_NROPAG")
         EndIf
         If AVFLAGS("CAMBIO_EXP_MOV_EXT")
            aAdd(aAltera, IncSpace("EEQ_MOEBCO", Len(SX3->X3_CAMPO), .F.))
            aAdd(aAltera, IncSpace("EEQ_PRINBC", Len(SX3->X3_CAMPO), .F.))
            aAdd(aAltera, IncSpace("EEQ_VLMBCO", Len(SX3->X3_CAMPO), .F.))
         EndIf
      EndIf
   ElseIf EECFlags("CAMBIO_EXT")
      // ** JPM - 29/12/2009 - Somente força a baixa gerencial se for uma parcela a receber.
      If IsReceita(TMP->EEQ_EVENT)
         Do While aScan(aAltera, "EEQ_DTCE") > 0
            aDel(aAltera, aScan(aAltera, "EEQ_DTCE"))
            aSize(aAltera, Len(aAltera) - 1)
         EndDo
      EndIf
   EndIf

   // ** Calcula o saldo disponível com relação ao valor negociado para alocacao na parcela.
   nRecTmp  := TMP->(Recno())
   TMP->(DbSetOrder(3))

   cParVin  := TMP->EEQ_PARVIN

   TMP->(DBSeek(cParVin))
   Do While TMP->(!Eof()) .And. TMP->EEQ_PARVIN == cParVin
      If Empty(TMP->EEQ_PGT)
         nVlSaldo += TMP->EEQ_VL
      EndIf
      TMP->(DbSkip())
   EndDo

   TMP->(DbGoTo(nRecTmp))
   RestOrd(aOrd)

   // WFS 15/05/09 - Vide revisão no cabeçalho. ---
   If (EasyGParam("MV_AVG0180", .F., .F.) .Or. EasyVerModal("TMP")) .And. Tmp->EEQ_TIPO == "A" // Parcela de Adiantamento. //Caso seja adiantamento recebido no exterior, deixa liquidar
      If nTipo == LIQ_DET
         //Ativa o gatilho para buscar a taxa quando o campo EEQ_PGT for preenchido
         lIsEmb:= .T.
         M->EEQ_VM_REC:= Tmp->EEQ_VL
         //Campos que poderão ser alterados quando o câmbio for de adiantamento
         AAdd(aMostra, "EEQ_PGT")
         AAdd(aMostra, "EEQ_TX")
         AAdd(aMostra, "EEQ_EQVL")
         AAdd(aAltera, "EEQ_PGT")
         //Campos que não deverão ser mostrados quando o câmbio for de adiantamento
         ADel(aMostra, AScan(aMostra, "EEQ_VCT"))
         ADel(aMostra, AScan(aMostra, "EEQ_PARI"))
         M->EEQ_PARI:= 1
      ElseIf nTipo == VIS_DET .Or. nTipo == ELQ_DET
         ADel(aMostra, AScan(aMostra, "EEQ_VCT"))
      EndIf
   EndIf
   //---
   If lCpoAcrDcr .And. nTipo <> VIS_DET .And. !lTemFinanc
      If nTipo <> LIQ_DET
         //If IsReceita(TMP->EEQ_EVENT) //THTS - 30/07/2019 - NOPADO DTRADE-2802 - Permitir a utilizacao de Acrescimo e Descrescimo para eventos a pagar.
            AAdd(aAltera, "EEQ_ACRESC")
            AAdd(aAltera, "EEQ_DECRES")
				AAdd(aAltera, "EEQ_DESCON")
         //EndIf
      Else
         AAdd(aAltera, "EEQ_MULTA")
         AAdd(aAltera, "EEQ_JUROS")
         If aScan(aALtera, "EEQ_DESCON") == 0
            AAdd(aAltera, "EEQ_DESCON")
         EndIf
      EndIf
   ElseIf AvFlags("EEC_LOGIX") .And. nTipo <> VIS_DET .And. !lTemFinanc
        AAdd(aAltera, "EEQ_DESCON")
   EndIf
   // BAK - Apresentaçao do campo de desconto quando for integrado com o logix
   If EEQ->(FieldPos("EEQ_DESCON")) > 0 .And. AvFlags("EEC_LOGIX")
      AAdd(aMostra, "EEQ_DESCON")
   EndIf

   If Type("lIsEmb") == "U"
      //Ativa o gatilho para buscar a taxa quando o campo EEQ_PGT for preenchido
      lIsEmb:= .T.
   EndIf

   //RMD - 17/10/14 - Permite editar a parcela caso existam campos de usuário
   If Type("aUserFields") <> "A"
      aUserFields:= {}
   EndIf

   If nTipo == ALT_DET .And. !Empty(TMP->EEQ_PGT)
      aAltera := aUserFields
   EndIf

   If Type("lEEQAuto") <> "L"
      lEEQAuto:= .F.
   EndIf

   cProcOrigem:= IIf(Type("cProcOrigem") == "C", cProcOrigem, "")
   
   If Type("bEEQAuto") <> "B"
      bEEQAuto := {|| }
   EndIf
   
   While .T.
      If lEEQAuto
         
         If cProcOrigem <> "AD103MAN" .And. cProcOrigem <> "AD104MAN"
            Eval(bEEQAuto)
         EndIf
         // ** AAF 26/02/08 - Necessário carregar variaveis e executar a Af201LoadSld() para quebra de parcelas em execução automática.
         If (EECFlags("FRESEGCOM") .And. Tmp->EEQ_EVENT == EV_PRINC2 .And. Tmp->EEQ_TIPO <> "A" .And.;
                nTipo <> INC_DET)
            Af201LoadSld()
         EndIf
         If AF200BXPARC(nTipo)
            nBtop:=1
         Else
            nBtop:=0
         EndIf

      ElseIf lExecAuto
         If nTipo == LIQ_DET .And. aScan(aAutoItens, {|x| x[1] == "EEQ_MODAL" .And. x[2] == "1" }) > 0 .And. !Empty(M->EEQ_BCOEXT)
            /* Caso seja uma liquidação de pagamento no exterior com contratação de câmbio e o banco já tiver sido preenchido devido a uma operação anterior,
               força apagar o conteúdo das variáveis para executar a validação dos campos e preencher as taxas, pois se for informado o mesmo banco a validação não é executada */
            M->EEQ_BCOEXT := AvKey("","EEQ_BCOEXT")
            M->EEQ_AGCEXT := AvKey("","EEQ_AGCEXT")
            M->EEQ_CNTEXT := AvKey("","EEQ_CNTEXT")
            M->EEQ_NBCEXT := AvKey("","EEQ_NBCEXT")
         EndIf
         If (nTipo == ALT_DET .Or. (nTipo == LIQ_DET .And. !IsReceita(autoConten("EEQ_EVENT", aAutoItens)))) .And. aScan(aAutoItens, {|x| x[1] == "EEQ_MODAL" .And. x[2] == "2" }) > 0
            M->EEQ_BCOEXT := autoConten("EEQ_BCOEXT", aAutoItens)
            M->EEQ_AGCEXT := autoConten("EEQ_AGCEXT", aAutoItens)
            M->EEQ_CNTEXT := autoConten("EEQ_CNTEXT", aAutoItens)
         EndIf
         If nTipo <> ELQ_DET
            AADD(aAltera,"EEQ_LTBX")
            AADD(aAltera,"EEQ_LTPG")
            AADD(aAltera,"EEQ_LTRC")
            EnchAuto("EEQ",ValidaEnch(aAutoItens,aAltera), {|| Obrigatorio(aGets,aTela)}, 3)
         EndIf
         If !lMsErroAuto
            Eval(bOk)
         EndIf
      Else
         DEFINE MSDIALOG oDlg TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
            aPOS := POSDLG(oDLG)

            If EECFlags("FRESEGCOM")
               If (Tmp->EEQ_EVENT == EV_PRINC2 .And. Tmp->EEQ_TIPO <> "A" .And. nTipo <> INC_DET)
                  aPos[3] -= 50//28
               EndIf
            EndIf
            If nTipo != INC_DET  .And.  !Empty(TMP->EEQ_FFC)  // By JPP - 31/08/2005 - 14:15
               If Len(aUserFields) > 0 //RMD - 27/01/15 - Permite alterar os campos de usuário mesmo com FFC.
                  aAltera := aUserFields
               Else
                  aALTERA := {}
               EndIf
            EndIf
            If EasyEntryPoint("EECAF200") // By JPP - 31/08/2005 - 14:15 - Inclusão do ponto de Entrada
               ExecBlock("EECAF200", .f., .f., {"PE_ENCHOICE_EEQ",nTipOpc})
            Endif

            Enchoice("EEQ",0,3,,,,aMOSTRA,aPOS,aALTERA,3,,,,,,.T.)

            If (EECFlags("FRESEGCOM") .And. Tmp->EEQ_EVENT == EV_PRINC2 .And. Tmp->EEQ_TIPO <> "A" .And.;
                nTipo <> INC_DET)

               /* Carrega o saldo a vincular para os três tipos de comissões:
                                   (Conta Gráfica/A Remeter/ Deduzir da Fatura) */
               Af201LoadSld()

               aPos[1] := aPos[3]+2
               aPos[3] := aPos[1]+50//28

               @ aPos[1],aPos[2] To aPos[3],aPos[4] Label STR0110 Pixel //"Comissões - Saldo a Vincular"

               nTamCol := (aPos[4]-aPos[2])/3

               nLinha := aPos[1]+10
               nCol1  := aPos[2]+10
               nCol2  := nCol1 + nTamCol
               nCol3  := nCol2 + nTamCol

               @ nLinha,nCol1 Say oLbCGrafica Var AvSx3("EEQ_CGRAFI",AV_TITULO) Pixel Size 40,7 Of oDlg
               @ nLinha,nCol1+45 MsGet oGetCGrafica Var nCGrafica;
                                                    Picture AvSx3("EEQ_CGRAFI",AV_PICTURE);
                                                    Pixel Size 50,7 Of oDlg When .f.

               @ nLinha,nCol2 Say oLbARemeter Var AvSx3("EEQ_AREMET",AV_TITULO) Pixel Size 40,7 Of oDlg
               @ nLinha,nCol2+45 MsGet oGetARemeter Var nARemeter;
                                                    Picture AvSx3("EEQ_AREMET",AV_PICTURE);
                                                    Pixel Size 50,7 Of oDlg When .f.

               @ nLinha,nCol3 Say oLbADeduzir Var AvSx3("EEQ_ADEDUZ",AV_TITULO) Pixel Size 40,7 Of oDlg
               @ nLinha,nCol3+40 MsGet oGetADeduzir Var nADeduzir;
                                                 Picture AvSx3("EEQ_ADEDUZ",AV_PICTURE);
                                                 Pixel Size 50,7 Of oDlg When .f.
            EndIf

            DEFINE SBUTTON oBTN FROM 5000,235 TYPE 1 ENABLE OF oDlg

         ACTIVATE MSDIALOG oDlg ON INIT (ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS),;
                                         If(lAuto,(Eval(bAltera),Eval(bOk)),Nil) ) // JPM - 24/04/06 - Manutenção automática (lAuto).
      EndIf

      If !Avflags("ADTFOREAI")
         If !GrvDetMan(nBTop,nTipo) // NCF - 23/03/2017 - Função única para onde foi migrada toda a gravação da manutenção em tela para o arquivo de trabalho TMP
            Loop
         EndIf
      Else
         aDeletados := {}
      EndIf

      Exit
   EndDo

End Sequence

RestOrd(aOrd)

DBSELECTAREA(cALIAS)

If lExecAuto .Or. Type("lEEQAuto") == "L" .And. lEEQAuto
   Return nBTop == 1
Else
   RETURN(NIL)
EndIf
/********************************************************/
/* Retira campos que não podem ser editados no EnchAuto */
/********************************************************/
Static Function ValidaEnch(aAuto, aEdita)
Local i, nPos
Local aReturn := aClone(aAuto)
Local aRetira := {}

    For i := 1 To Len(aReturn)
        If aScan(aEdita, aReturn[i][1]) == 0
            aAdd(aRetira, aReturn[i][1])
        EndIf
    Next
    For i := 1 To Len(aRetira)
        If (nPos := aScan(aReturn, {|x| AllTrim(Upper(x[1])) == AllTrim(Upper(aRetira[i])) })) > 0
            aDel(aReturn, nPos)
            aSize(aReturn, Len(aReturn)-1)
        EndIf
    Next

Return aReturn
/*****************************************************
* Funcão: autoConten(cField, aAutoItens)
* 
*****************************************************/
Static Function autoConten(cField, aAutoItens)
Local nIndex := 0
Local cValue := ""
nIndex := aScan(aAutoItens, {|x| x[1] == cField})
cValue := aAutoItens[nIndex][2]
Return cValue

*-----------------------*
FUNCTION AF200VALID(cCPO)
*-----------------------*
LOCAL nOLDAREA:=SELECT(), x, nValTot:=0, xRet, aOrd
Local nPos, cEveVin, cParcVin, cBanco:="", cPraca:="" // ** GFC - Pré-Pagamento / Securitização
Local cChaveBanc := ""
Local nDias      := 0
Local lDtNego    := .F.
Local lExist     := .F. //RRC - 06/08/2013
Local nOrd   //FSY - 19/06/2013
Local nRecno //FSY - 19/06/2013
Local aOrdSA6
Local lCallVldAdi:= ( IsInCallStack('Ap100AdiMan') .Or. IsInCallStack('AC100Adian') ) .and. Select('Work_Pgto') > 0 .And. Type('M->EEQ_EVENT') <> 'U' .And. M->EEQ_EVENT $ '602/605/606/607'  //NCF - 01/10/2015 - Adiant. com Mov. Exterior //NCF - 04/07/2019
Local lBxCAPMvEx := .F.           //NCF - 09/11/2015
Local nTxMoeInv := nTxMoeBco := 0 //NCF - 10/11/2015
Local cTaxaInf := cExcDecTx := ""
Local nVlrCompRS := nMaxVarCmb := nDifInfxPa := 0
Local BlAtuPgt  := {|| ((nTipoDet == LIQ_DET .And. !IsReceita(M->EEQ_EVENT)) .Or. lCallVldAdi ) .And. lLiqCAPExt .And. EasyVerModal("M") }
Local cC6_TXCV
Private lRET     := .T.
Private lSair    := .F.
Private lBloqMoe := .T. //DFS - 15/04/13 - Inclusão de variável private para manipulação no ponto de entrada
Private lCpoAcrDcr:= IF(Type("lCpoAcrDcr") ="U" , AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") ,lCpoAcrDcr)
Private lLiqCapExt:= IF(Type("lLiqCapExt") ="U" , AVFLAGS("CAMBIO_EXP_MOV_EXT") ,lLiqCapExt)
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND.;
                     EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. EF1->(FieldPos("EF1_CAMTRA")  ) > 0 // GFP - 24/01/2014

// ** JPM - 16/12/2009
Default cCpo := AllTrim(SubStr(ReadVar(),4))

If Type("nTipoDet") = "U" .Or. nTipoDet = Nil    // Trata a Variavel caso a chamada da função não seja do controle de câmbio
   nTipoDet := 0
Endif

If Type("lParFin") = "U" .Or. lParFin = Nil    // GFP - 29/01/2014  // Trata a Variavel caso a chamada da função não seja do controle de câmbio
   lParFin := .F.
Endif

If Type("lEmbarcado") == "U"  // By JPP - 12/10/2006 - 10:00 - .T. - Esta validação está sendo feita após um embarque.
   Private lEmbarcado := .T. //                               .F. - Esta validação está sendo feita antes de um embarque. Ex: Adiantamento
Endif

//WFS - gatilho da fase de adiantamento
If Type("M->EEQ_VLFCAM") == "N"
   M->EEQ_VLFCAM:= AF200VLFCam("M","LIQ")//Round((M->EEQ_VL - M->EEQ_CGRAFI + If(lCpoAcrDcr,M->EEQ_ACRESC - M->EEQ_DECRES,0) ), 2)
EndIf

BEGIN SEQUENCE

   //ISS - 05/01/11 - Ponto de entrada para a criação ou alteração de uma validação.
   If EasyEntryPoint("EECAF200")
      ExecBlock("EECAF200", .F., .F., "AF200VALID_VALCAMPO")
   EndIf

   If lSair
      Break
   EndIf

   IF cCPO = "EEQ_CORR" //CORRETOR
      IF !lFinanciamento .and. Empty(M->EEQ_CORR)
         M->EEQ_VLCOR := 0
      Else
         If !Empty(M->EEQ_CORR)
            SY5->(DBSETORDER(3))
            IF (SY5->(DBSEEK(XFILIAL("SY5")+AVKEY("5-CORRETORA CAMBIO","Y5_TIPOAGE")+M->EEQ_CORR)))
               M->EEQ_CRNO := SY5->Y5_NOME
            ELSE
               HELP(" ",1,"AVG0005078") //Msginfo("Corretora não cadastrada !","Aviso")
               lRET:=.F.
            ENDIF
         EndIf
      Endif
************************************************************      MJA 09/12/04
   Elseif cCpo = "EEQ_EQVL"
      //AAF 29/11/05 - Não é necessário validar o resto caso o tipo de contrato seja 3 ou 4.
	  // GFP - 13/01/2014 - Sistema deve validar o valor quando a origem for SIGAESS.
      If !(IsInCallStack("EICPS400")) .AND. (EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. M->EEQ_TP_CON $ "3/4")
         lRet:= .T.
         BREAK
      EndIf

      //RMD - 20/10/06 - Quando for FFC, compara com o valor total da soma das parcelas, e não só com  o valor de uma.
      If IsLiqFFC()  // By JPP - 07/12/2006 - Correção na definição do valor da variável nValComp
         nValComp := nTotFFC //Valor total do FFC
      Else
         nValComp := M->EEQ_VLFCAM //M->EEQ_VL //Valor da parcela comentado por WFS
      EndIf
      
      nVlrCompRS := AF200CnvCmb( "M",nValComp,TAMSX3("EEQ_EQVL")[2], ,nTipoDet )
      nMaxVarCmb := EasyGParam("MV_AVGVLMX",,0)
      nDifInfxPa := ABS(nVlrCompRS - M->EEQ_EQVL) 
                                                                                                                                                         //NCF - 05/08/2015
      If nDifInfxPa > nMaxVarCmb    // GFP - 13/01/2014 - Validação para SIGAESS
         //Não validar se for retirada da data de crédito no exterior, quando a modalidade for câmbio no exterior
         If (nTipoDet == LIQ_DET) .Or. IsLiqFFC() //THTS - 16/05/2017 - Somente deve validar na liquidacao
            EasyHelp(STR0158+ENTER+;
                    "Valor Fech. Câmbio (R$)  :"+cValTochar(nVlrCompRS)+ENTER+;
                    "Valor da Invoice (R$)    :"+cValToChar(M->EEQ_EQVL)+ENTER+;
                    "Valor abs. do excesso    :"+cValToChar(nDifInfxPa)+ENTER+;
                    "Valor Max. Var. permitido:"+cValToChar(nMaxVarCmb),STR0016)//"A variação do valor em Reais excede o permitido."//"Aviso"
            lRet := .f.
            BREAK
         EndIf
      EndIf

************************************************************
   Elseif cCpo = "EEQ_VCT"
      IF (Type("lEmbarcado") == "U" .Or. lEmbarcado) .And. M->EEQ_VCT < EEC->EEC_DTEMBA //ER - 17/10/2006
         HELP(" ",1,"AVG0005079") //MsgInfo("A data de vencimento deverá ser maior ou igual a data do embarque.","Aviso")
         lRet := .f.
      Endif
   Elseif cCpo = "EEQ_SOL"
      If Type("lTelaLote") <> "L" .Or. !lTelaLote
         IF ! EMPTY(M->EEQ_SOL) .AND. (Type("lEmbarcado") == "U" .Or. lEmbarcado) .AND. M->EEQ_SOL < EEC->EEC_DTEMBA //ER - 17/10/2006
            HELP(" ",1,"AVG0005080") //MsgInfo("A data de solicitação de câmbio deverá ser maior ou igual a data do embarque.","Aviso")
            lRet := .f.
         Endif
      EndIf
   Elseif cCpo = "EEQ_DTNEGO"
      If Type("lTelaLote") <> "L" .Or. !lTelaLote
         If EasyVerModal("M")  // GFP - 10/09/2015
            Break
         EndIf
         //Ponto de entrada para tratamentos customizados na validação da data de negociação (EEQ_DTNEGO)
         If EasyEntryPoint("EECAF200")
            lDtNego:= ExecBlock("EECAF200",.F.,.F., "DTNEGO_VALID")
         EndIf
         If !lDtNego
            If Type("lAF300") = "L" // By JPP - 20/02/2006 - 17:00 - Validação Chamada do programa EECAF300
               Break
            EndIf
            If Empty(M->EEQ_DTCE) .and. !Empty(M->EEQ_DTNEGO)
               EasyHelp(STR0096, "Aviso") //"É necessário informar a Data de Crédito no Exterior."
               lRet := .f.                           //NCF - 13/10/2015
            ElseIf M->EEQ_DTNEGO < M->EEQ_DTCE .And. nTipoDet <> 0
               EasyHelp(STR0097, "Aviso") //"Data de negociação não pode ser anterior a Data de Crédito no Exterior."
               lRet := .f.                                                   //NCF - 13/10/2015
            ElseIF !Empty(M->EEQ_SOL) .and. M->EEQ_DTNEGO < M->EEQ_SOL .And. nTipoDet <> 0
               EasyHelp(STR0098, "Aviso") //"Data de negociação não pode ser anterior a Data de Solicitação."
               lRet := .f.
            Endif
         EndIf
      EndIf
   ElseIf cCpo = "EEQ_PGT"

      // RMD - 18/06/20 - Quando for painel de câmbio, a data do crédito no exterior é preenchida obrigatóriamente antes de executar a operação de liquidação
      If !Empty(M->EEQ_PGT) .And. Empty(M->EEQ_DTCE) .And. IsReceita(M->EEQ_EVENT) .And. !(Type("lTelaLote") == "L" .And. lTelaLote) 
         EasyHelp(STR0316, STR0016) //"Data de Crédito no Exterior deve ser preenchida para que seja possível liquidar a parcela."
         lRet := .F.
         Break
      EndIf

      If !Empty(M->EEQ_PGT) .AND. M->EEQ_PGT < M->EEQ_DTNEGO
         EasyHelp(STR0099, "Aviso") //"Data de liquidação do contrato não pode ser anterior a Data de negociação."
         lRet := .f.
         Break
      EndIf

      //RMD - 18/06/20 - Não deve validar os próximos itens na tela do Painel de Cãmbio, pois não está posicionado em uma parcela específica.
      If (Type("lTelaLote") == "L" .And. lTelaLote)
         lRet := .T.
         Break
      EndIf

      //ER - 11/10/2006
      If !Empty(M->EEQ_VCT)
         If M->EEQ_PGT > M->EEQ_VCT
            nDias := M->EEQ_PGT - M->EEQ_VCT
            If nDias > EasyGParam("MV_AVG0128",,9999)//RMD - 08/12/06 - Para permitir que o intervalo seja personalizado
               EasyHelp(StrTran(STR0216, "###", AllTrim(Str(EasyGParam("MV_AVG0128",,9999)))), STR0014) //"Data de liquidação do contrato não pode ser superior a 10 dias da Data de Vencimento." "Atenção"
               lRet := .f.
               Break
            EndIf
         EndIf
      EndIf

      aOrd:=SaveOrd({"EEC"})

      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(xFilial("EEC")+M->EEQ_PREEMB))
         If !Empty(EEC->EEC_DTENDC)
            If M->EEQ_PGT > EEC->EEC_DTENDC
               nDias := M->EEQ_PGT - EEC->EEC_DTENDC
               If nDias > EasyGParam("MV_AVG0129",,9999)//RMD - 08/12/06 - Para permitir que o intervalo seja personalizado
                  EasyHelp(StrTran(STR0217, "###", AllTrim(Str(EasyGParam("MV_AVG0129",,9999)))), STR0014) //"Data de liquidação do contrato não pode ser superior a ### dias da Data de Entrega de Documentos." "Atenção"
                  lRet := .f.
                  RestOrd(aOrd,.t.)
                  Break
               EndIf
            EndIf
         EndIf
      EndIf

      RestOrd(aOrd,.t.)

      // ** PLB 13/10/06 - Verifica se a data de liquidação é maior do que a data de vinculacao ao financiamento
      If lRet  .And.  lFinanciamento  .And.  Type("aArrayEEQ") == "A"
         If ( ni := aScan(aArrayEEQ,{|x| x[20]==TMP->(RecNo())}) ) > 0 .And. !Empty(aArrayEEQ[ni,5])  .And.  aArrayEEQ[ni,10] > M->EEQ_PGT
            EasyHelp(STR0218+DToC(aArrayEEQ[ni,10])+".")  //"A Data de Liquidação não pode ser menor do que a Data de Vinculação da Parcela ao Financiamento: "
            lRet := .F.
         EndIf
      EndIf
      // **
   Elseif cCpo = "EEQ_TX"

      //AAF 29/11/05 - Não é necessário validar o resto caso o tipo de contrato seja 3 ou 4.
      If (EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. M->EEQ_TP_CON $ "3/4")
         lRet:= .T.
         BREAK
      EndIf

      IF IF( /*EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. M->EEQ_MODAL == "2"*/ EasyVerModal("M"),Empty(M->EEQ_DTCE),Empty(M->EEQ_PGT)) .And. !Empty(M->EEQ_TX)//AOM - 28/08/2012
         HELP(" ",1,"AVG0005081") //MsgInfo("Para digitar a taxa é necessario informar a data de fechamento.","Aviso")
         lRet := .F.
      Endif
       
      If IntegFIN(cModulo) .And. ( nTipoDet == LIQ_DET .Or. IsLiqFFC() .Or. lCallVldAdi ) //NCF - 26/03/2019
         cTaxaInf := Alltrim(Str(M->EEQ_TX))
         cExcDecTx := Substr(  cTaxaInf , At(".", cTaxaInf ) + TamSX3("E1_TXMOEDA")[2] + 1  )
         If Val(cExcDecTx) > 0
            EasyHelp( StrTran( STR0306 ,"####", Alltrim(Str(TamSX3("E1_TXMOEDA")[2]))) ,STR0016) //"O número de casas decimais informada deve ser igual a #### para que possa ocorrer a integração com o módulo Financeiro!"
            lRet := .F.
         EndIf
      EndIf

   Elseif cCpo = "EEQ_BANC"
      //DFS - 15/04/13 - Caso o RdMake retorne .T., sistema efetua a verificação.
      //RRC - Caso RdMake retorne .F., fará a validação se for rotina do SIGAESS
      //LRS - 2/10/2015 - Modificado a validação do banco para os modulos EEC e ESS
      IF !Empty(M->EEQ_BANC) .AND. (lBloqMoe .AND. !nModulo == 85 .AND. EasyGParam("MV_AVG0131",,.f.) .AND. EasyGParam("MV_EECFAT",,.f.) .OR.;
          nModulo == 85 .AND. (IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100")) .AND. EasyGParam("MV_ESS0013",,.F.)   )
         lRet := ExistCpo("SA6",M->EEQ_BANC)
         If (EasyGParam("MV_AVG0131") .AND. EasyGParam("MV_EECFAT"))   //GFP - 11/12/2012
            SYF->(DbSetOrder(1)) //YF_FILIAL+YF_MOEDA
            SYF->(DbSeek(xFilial("SYF")+SA6->A6_MOEEASY))
            If SA6->A6_MOEDA > 1 .AND. SA6->A6_MOEDA <> SYF->YF_MOEFAT
               //DFS - 18/01/13 - Retirado bloqueio na alteração do cambio, caso a moeda seja diferente.
               lRet := .F.
               EasyHelp(STR0257,STR0014)   //"Moeda cadastrada no banco diverge com a informada no cadastro de Moedas." ### "Atenção"
            EndIf
         EndIf
      Endif

   //RRC - 05/08/2013 - Valida a agência e o número da conta
   ElseIf (cCpo == "EEQ_AGEN" .Or. cCpo == "EEQ_NCON") .And. (lBloqMoe .Or. nModulo == 85 .Or. IsInCallStack("ESSPS400")  .Or.  IsInCallStack("ESSIN100") .Or. IsInCallStack("DI505ESS"))
      If !((cCpo == "EEQ_AGEN" .And. Empty(M->EEQ_AGEN)) .Or. (cCpo == "EEQ_NCON" .And. Empty(M->EEQ_NCON)))
         aOrd := SaveOrd({"SA6"})
         SA6->(DbSetOrder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
         cChaveBanc := xFilial("SA6")+AvKey(M->EEQ_BANC,"A6_COD")+AvKey(M->EEQ_AGEN,"A6_AGENCIA")

         If (lRet := SA6->(DbSeek(cChaveBanc))) .And. cCpo == "EEQ_NCON" //Só percorre o loop caso a validação seja para o número da conta, devido a chave primária da SA6
            Do While !lExist .And. !SA6->(Eof()) .And. cChaveBanc == SA6->(A6_FILIAL+A6_COD+A6_AGENCIA)
               lExist := (SA6->A6_NUMCON == AvKey(M->EEQ_NCON,"A6_NUMCON"))
               SA6->(DbSkip())
            EndDo
            lRet := lExist
         EndIf

         If !lRet .And. cCpo == "EEQ_AGEN"
            EasyHelp(STR0317,STR0016)//"Agência informada não é válida.","Aviso"
         ElseIf !lRet .And. cCpo == "EEQ_NCON"
            EasyHelp(STR0318,STR0016)//"Número da conta informado não é válido.","Aviso"
         EndIf

         //LRS - 05/09/2017
         If lRet .And. !Empty(M->EEQ_NCON) .And. SA6->(DbSeek(xFilial("SA6") + M->EEQ_BANC + M->EEQ_AGEN + M->EEQ_NCON)) .And. SA6->A6_MOEDA <> 1   
             EasyHelp(STR0304,STR0109)//"Necessário informar uma conta em moeda nacional. Para utilizar uma conta em moeda estrangeira, utilize a opção 'Movimento no Exterior' "
             lRet := .F.
         EndIf         
         RestOrd(aOrd,.T.)
      EndIf
   Elseif cCpo = "EEC_DTEMBA"
      aOrd := SaveOrd("EEQ",1)
      lRet := .t.

      // So exite parcela no EEQ, se o processo ja estava embarcado (EEC_DTEMBA <> vazio)
      EEQ->(dbSeek(xFilial()+M->EEC_PREEMB))
      DO While EEQ->(!Eof() .And. EEQ_FILIAL == xFilial("EEQ")) .And. EEQ->EEQ_PREEMB == EEC->EEC_PREEMB
         IF !Empty(EEQ->EEQ_PGT) .Or. !Empty(EEQ->EEQ_DTVC)
            HELP(" ",1,"AVG0005082") //MsgInfo("Data de embarque não pode ser alterada ! Existe(m) parcela(s) de câmbio contratada(s).","Aviso")
            lRet := .f.
            Exit
         Endif
         EEQ->(dbSkip())
      Enddo

      RestOrd(aOrd,.t.)
   ELSEIF cCPO = "EEQ_VL"

      //RMD - 10/02/17 - Não permite estornar o crédito se a parcela tiver sido desmembada após o recebimento no exterior
      //THTS - 24/03/2017 - valida se existe o TMP para nao dar erro
      If nTipoDet = ALT_DET .And. Select("TMP") > 0 .And. EasyVerModal("TMP") .AND. M->EEQ_VL <> TMP->EEQ_VL
         If M->EEQ_DTCE <> TMP->EEQ_DTCE .AND. !Empty(TMP->EEQ_DTCE)
            EasyHelp(STR0319,STR0016) //"Esta parcela será desmembrada devido a alteração do valor. Confirme o desmembramento para alterar o crédito no exterior." #Aviso
            lRet := .F.
            Break
         ElseIf TMP->TMP_RECNO > 0 .AND. EEQ->(dbGoTo(TMP->TMP_RECNO),M->EEQ_DTCE <> EEQ->EEQ_DTCE)
            EasyHelp(STR0320,STR0016) //"Esta parcela teve o crédito no exterior alterado. Confirme a alteração para realizar um desmembramento de parcelas." #Aviso
            lRet := .F.
            Break
         EndIf
      EndIf

      // ** By JBJ - 27/02/03 - 13:28.
      If M->EEQ_VL <= 0
         EasyHelp(STR0039,STR0014) //"Valor da parcela inválido."###"Atenção"
         lRet:=.f.
         Break
      EndIf

      If IsMemVar("lCpoAcrDcr") .AND. lCpoAcrDcr .And. M->EEQ_VLFCAM  < 0
         MsgVLFCAM() //THTS - 05/08/2019 - Mensagem de informando que o valor de fechamento de cambio é inválido
         lRet := .F.
		 BREAK
      EndIf

      //AAF 29/11/05 - Não é necessário validar o resto caso o tipo de contrato seja 3 ou 4.
      If (EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. M->EEQ_TP_CON $ "3/4")
         lRet:= .T.
         BREAK
      EndIf

      // ** By JBJ - 14/03/03 - 08:50.
      //RMD - 17/10/14 - Verifica também se é alteração de parcela liquidada (somente campos de usuário)
      If nTipoDet = ALT_DET .And. Empty(M->EEQ_PGT) .AND. !( M->EEQ_EVENT == EV_DEM_PG .OR. M->EEQ_EVENT == EV_DEM_RC )//AAF 02/02/05 - Valor pode ser alterado livremente para o demurrage
         If (nVlSaldo-M->EEQ_VL) < 0
            HELP(" ",1,"AVG0005094") //MsgInfo("Valor da parcela maior que o valor negociado! ","Aviso")
            lRet := .F.
            Break
         EndIf
      EndIf

      IF !lFinanciamento .and. M->EEQ_VL < M->EEQ_DESCON
          HELP(" ",1,"AVG0005083") //MSGINFO("Valor da Parcela Não Pode Ser Menor Que o Desconto !","Atenção")
          lRET := .F.
      ENDIF
      If lFinanciamento .and. lRet .AND. Type("aArrayEEQ") == "A"
         // ** PLB 20/10/06
         //If (nPos:=aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)})) > 0  ;
         //   .And. !Empty(aArrayEEQ[nPos,5])  .And.  M->EEQ_VL > TMP->EEQ_VL
         If (nPos:=aScan(aArrayEEQ,{|x| x[3] == TMP->EEQ_PARC })) > 0  .And. !Empty(aArrayEEQ[nPos,5])  .And.  M->EEQ_VL > TMP->EEQ_VL
            EasyHelp(STR0225,STR0016)  //"A parcela está vinculada a um contrato de financiamento e seu valor não pode ser alterado para maior.###Aviso"
            lRet := .F.
         // **
         Else
            For x:= 1 to Len(aArrayEEQ)
               If !Empty(aArrayEEQ[x,5])
                  nValTot += aArrayEEQ[x,1]
               EndIf
            Next x
         EndIf
      EndIf
      // ** AAF 01/02/05 - 16:48 - Validação para os Eventos de Demurrage.
      If ( M->EEQ_EVENT == EV_DEM_PG .OR. M->EEQ_EVENT == EV_DEM_RC ) .AND. lRet
         lRet := DM100ValCamb()
      Endif
      // **
   ELSEIF cCPO = "EEQ_DESCON" //.and. !lFinanciamento
       IF M->EEQ_DESCON > M->EEQ_VL
          HELP(" ",1,"AVG0005084") //MSGINFO("Desconto Não Pode Ser Maior Que o Valor da Parcela !","Atenção")
          lRET := .F.
       ENDIF
       If lRet .And. lCpoAcrDcr
          If M->EEQ_VLFCAM  < 0
             MsgVLFCAM() //Mensagem de informando que o valor de fechamento de cambio é inválido
             lRet := .F.
          Else
             If !Empty(M->EEQ_TX)
                M->EEQ_EQVL:= M->EEQ_TX *( M->EEQ_VLFCAM + M->EEQ_MULTA + M->EEQ_JUROS )
             EndIf
          EndIf
       EndIf
   ElseIf cCpo == "EEQ_NRINVO"
      //AAF 29/11/05 - Não é necessário validar caso o tipo de contrato seja 3 ou 4.
      If (EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. M->EEQ_TP_CON $ "3/4")
         lRet:= .T.
         BREAK
      ElseIf lOkEVENT .and. M->EEQ_EVENT $("101/"+EV_PJ+"/530/613/801") .and. Empty(M->EEQ_NRINVO)
         Help(" ",1,"AVG0005225") //MsgInfo("Necessário preencher a Invoice.")
         lRet := .F.
      EndIf

   Elseif cCpo == "EEQ_EVENT"  .And. lOkEVENT
      IF nTipoDet == INC_DET
         IF M->EEQ_EVENT == EV_PRINC2
            EasyHelp(STR0040+EV_PRINC2+STR0041,STR0016) //"Não é possivel a inclusão de registros do evento ("###"), altere o Valor da Parcela e uma parcela de saldo será gerada automaticamente."###"Aviso"
            lRet := .F.
         Endif
      Endif
   ElseIf cCpo == "BT_OK"

      // *** RMD - 19/12/07 - Validação do banco
      If !Empty(M->EEQ_BANC) .And. !Empty(M->EEQ_AGEN) .And. !Empty(M->EEQ_NCON)
         If !(lRet := AF200Valid("EEQ_NCON"))
            Break
         EndIf
      EndIf

      If (EECFlags("FRESEGCOM") .And. lOkEvent .And. nTipoDet == INC_DET)

         /* Na inclusão de parcelas, o sistema analisa o evento de acordo com o conteúdo dos mv´s
            de tratamento de eventos (MV_EVENT??). Para validar as dependências entre os eventos
            possíveis criados pelo usuário */

         If !Af200CanInsert()
            lRet:= .f.
            Break
         EndIf

         /* Na inclusão de eventos de desconto, seja padrão ou evento criado pelo usuário, o sistema
            valida a inclusão do valor de desconto considerando a possibilidade de abatimento dos
            valores das parcelas onde o desconto é aplicado. */

         If Left(M->EEQ_EVENT,1) == "8"
            If !Af201VldDiscount()
               lRet:= .f.
               Break
            EndIf
         EndIf
      EndIf

      If lRet .and. nTipoDet == LIQ_DET
                                  
         if IsReceita(M->EEQ_EVENT) .or. !EasyVerModal("M")
            If Empty(M->EEQ_BANC) .or. Empty(M->EEQ_AGEN) .or. Empty(M->EEQ_NCON)
               easyhelp(STR0308,STR0014) //"Não é possível liquidar uma parcela de câmbio sem um banco, agência ou conta definido para o contrato, selecione o banco, agência e conta no Contrato de Câmbio." #Atenção
               lRet:= .f.
               Break
            EndIf
         endif
      

         If !Empty(M->EEQ_NROP) .And. (nPos := aScan(aArrayEEQ,{|x| x[20]=TMP->(RecNo()) .and. !Empty(x[5]) /*.and. x[16] <> NIL*/ })) == 0
            lRet := AF200VldOpr()
         Endif

         If lFinanciamento .and. EasyGParam("MV_EFF0001",,.F.) // ** GFC - Pré-Pagamento / Securitização
            If (nPos := aScan(aArrayEEQ,{|x| x[20]=TMP->(RecNo()) })) > 0
               EF3->(dbSetOrder(1))
               For x:=nPos to Len(aArrayEEQ)
                  If aArrayEEQ[x,20]==TMP->(RecNo()) .and. !Empty(aArrayEEQ[x,5]) .and. aArrayEEQ[x,16] <> NIL
                     EF3->(dbGoTo(aArrayEEQ[x,16]))
                     EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+iif(lTemChave, EF3->EF3_BAN_FI+EF3->EF3_PRACA+If(lEFFTpMod,EF3->EF3_SEQCNT,""), ""))) //HVR 25/04/06 -
                     If lPrePag .and. IF(lEFFTpMod, EF1->EF1_CAMTRA == "1", EF3->EF3_TP_EVE $ ("03/04")) //HVR 25/04/06 - DE: EF3->EF3_TP_EVE $ ("03/04") PARA: (IF EF1->EF1_CAMTRA == "1", .T., IF EF3->EF3_TP_EVE $ ("03/04")) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO
                        cContra  := EF3->EF3_CONTRA
                        If lTemChave
                           cBanco   := EF3->EF3_BAN_FI
                           cPraca   := EF3->EF3_PRACA
                           If lEFFTpMod
                              cSeqCon := EF3->EF3_SEQCNT
                           EndIf
                        EndIf
                        cEveVin  := EF3->EF3_EV_VIN
                        cParcVin := EF3->EF3_PARVIN
                        If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+cContra+If(lTemChave,cBanco+cPraca+if(lEFFTpMod,cSeqCon,""),"")+cEveVin+cParcVin)) .and.;
                        M->EEQ_PGT < EF3->EF3_DT_EVE
                           FAF2NaoLiq(cContra,cBanco,cPraca,cEveVin,cParcVin,M->EEQ_PGT,EF3->EF3_DT_EVE,If(lEFFTpMod,cSeqCon,""))
                           lRet := .F.
                           Break
                        EndIf
                     EndIf
                  EndIf
               Next x
            EndIf
         EndIf
      EndIf

      If EECFlags("FRESEGCOM")
         If (nTipoDet == INC_DET) .Or. (nTipoDet == ALT_DET)

            If !IsReceita(M->EEQ_EVENT) // Despesa.
               //If Empty(M->EEQ_CODEMP) .And. M->EEQ_EVENT <> "129"
               If Empty(M->EEQ_CODEMP) .And. !(M->EEQ_EVENT $ "129/133") //RMD - 08/02/18 - Considera também o evento da Invoice a Pagar Off Shore
                  EasyHelp(STR0111+AllTrim(AvSx3("EEQ_CODEMP",AV_TITULO))+STR0112+ENTER+; //"O campo '"###"' deve ser informado para "
                          STR0113,STR0109) //"eventos contábeis do tipo 'Despesa'."###"Atenção"
                  lRet:=.f.
                  Break
               EndIf

               If (Empty(M->EEQ_FORN) .OR. Empty(M->EEQ_FOLOJA)) .AND. (EasyGParam("MV_EEC_ECO",,.f.) .Or. IsIntEnable("001")) //NCF - 11/11/2009
                  EasyHelp(STR0114+AllTrim(AvSx3("EEQ_FORN",AV_TITULO))+STR0115+AllTrim(AvSx3("EEQ_FOLOJA",AV_TITULO))+STR0116+ENTER+; //"Os campos '"###"' e '"###"' devem ser "
                          STR0117,STR0109) //"informados para eventos contábeis do tipo 'Despesa'."###"Atenção"
                  lRet:=.f.
                  Break
               EndIf
            EndIf
         EndIf
      EndIf

      // ** PLB 21/07/06 - Tratamento Multi-Usuario Financiamento
      If lRet .And. lFinanciamento .And. (nTipoDet==ALT_DET .Or. nTipoDet==EXC_DET .Or. nTipoDet==LIQ_DET .Or. nTipoDet==ELQ_DET)
         EF3->( DBSetOrder(3) )
         If EF3->( DBSeek(cFilEF3+IIF(lEFFTpMod,IIF(M->EEQ_TP_CON $ ("2/4"),"I","E"),"")+M->EEQ_NRINVO+M->EEQ_PARC+EV_EMBARQUE) )
            EF1->( DBSetOrder(1) )
            EF1->( DBSeek(cFilEF1+IIF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->EF3_CONTRA+IIF(lTemChave,EF3->EF3_BAN_FI+EF3->EF3_PRACA,"")+IIF(lEFFTpMod,EF3->EF3_SEQCNT,"")) )
            If !SoftLock("EF1")
               lRet := .F.
               Break
            EndIf
         EndIf
      EndIf
      // **

      // *** RMD - 07/11/07 - Baixa Gerencial
      If lRet .And. nTipoDet == BXG_DET .And. M->EEQ_CONTMV $ cSim
         SA6->(DbSetOrder(1))
         If !(lRet := SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT))))
            EasyHelp(STR0243 + ENTER + STR0244, STR0016)//"Aviso" //STR0243	"A conta informada não existe no cadastro de bancos." //STR0244	"Escolha uma conta válida."
            Break
         EndIf
         If !(lRet := SA6->A6_MOEEASY == M->EEQ_MOEDA)
            EasyHelp(STR0245 + ENTER + STR0246, STR0014) //	STR0245	"A moeda da conta escolhida é diferente da moeda da parcela." //STR0246	"Escolha uma conta na mesma moeda da parcela."//	STR0014  	"Atenção"
            Break
         EndIf
         // ** AAF 03/03/08 - Verifica se existe natureza associada ao evento
         If !(lRet := !Empty(GetNatureza("EXP", M->EEQ_EVENT)) )
            EasyHelp(STR0247, STR0014)// STR0247	"Não é possivel realizar a movimentação no exterior pois não há natureza de movimentação associada a este evento. Verifique o cadastro de eventos contábeis."//	STR0014  	"Atenção"
            Break
         EndIf
         // **
      EndIf
      /* *** RMD - 21/12/16 - Validação das taxas cadastradas quando utilizada a baixa de câmbio com banco em uma moeda estrangeira
                              diferente da moeda da parcela.
                              Isso porque o financeiro depende das taxas cadastradas para ambas as moedas (parcela e banco) na data da baixa
                              para efetuar os calculos corretos. */
      //Checa se possui o tratamento para movimento no exterior e se a data de crédito no exterior foi preenchida na operação atual
      if !avflags("EEC_LOGIX") //.or. avflags("EEC_LOGIX") .and. isreceita(M->EEQ_EVENT)
         If EasyVerModal("M") .And. !Empty(M->EEQ_DTCE) .And. (TMP->TMP_RECNO == 0 .Or. Empty(TMP->EEQ_DTCE))
            //Verifica se o banco no exterior foi preenchido e localiza o seu cadastro
            If !Empty(M->EEQ_BCOEXT) .And. !Empty(M->EEQ_AGCEXT).And. !Empty(M->EEQ_CNTEXT) .And. SA6->(DbSetOrder(1),DbSeek(xFilial("SA6")+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT))) .And. SA6->A6_MOEEASY <> M->EEQ_MOEDA

               If lRet := Af200ChkMd(SA6->A6_MOEEASY, M->EEQ_DTCE, "YF_MOEFAT",M->EEQ_EVENT) //ver nos outros fontes
                  lRet := Af200ChkMd(M->EEQ_MOEDA, M->EEQ_DTCE, "YF_MOEFAT",M->EEQ_EVENT)
               EndIf
            EndIf
         EndIf
      endif

      If EasyEntryPoint("EECAF200")
         xRet := ExecBlock("EECAF200",.F.,.F.,{"PE_VALIDA",nTipoDet})
         If ValType(xRet) = "L"
            lRet := xRet
         EndIf
      EndIf

      //RMD - 25/11/08 - Quando integrado com SigaFin, se alguma parcela for alterada, não poderá ser feita nenhuma liquidação, e vice-versa.
      If lRet
        If nTipoDet==ALT_DET
            lParcAlt := .T.
        ElseIf (nTipoDet == LIQ_DET .Or. nTipoDet == ELQ_DET)
            lParcLiq := .T.
        EndIf
      EndIf

   ElseIf cCpo == "EEQ_CODEMP"

      aOrd:=SaveOrd({"SY5"})
      If SY5->(DbSetOrder(1),DbSeek(xFilial("SY5")+M->EEQ_CODEMP))
         If Empty(SY5->Y5_FORNECE) .Or. Empty(SY5->Y5_LOJAF)

            EasyHelp(STR0118+ENTER+; //"Problema:"
                    STR0119+AllTrim(Transf(SY5->Y5_COD,Avsx3("Y5_COD",AV_PICTURE)))+; //"A empresa '"
                                  STR0120+Replic(ENTER,2)+; //"' não possue todos os dados necessários para seleção."
                    STR0121+ENTER+; //"Detalhes:"
                    STR0114+Avsx3("Y5_FORNECE",AV_TITULO)+"','"+Avsx3("Y5_LOJAF",AV_TITULO)+; //"Os campos '"
                                      STR0122,STR0109) //"' devem ser informados no cadastro de empresas."###"Atenção"
            lRet := .f.
         EndIf
      EndIf
      RestOrd(aOrd,.t.)

   ElseIf cCpo == "EEQ_PARI" //ER - 18/10/2006

      If !Empty(M->EEQ_PREEMB)
         aOrd:=SaveOrd({"EEC"})
         EEC->(DbSetOrder(1))
         If EEC->(DbSeek(xFilial("EEC")+M->EEQ_PREEMB))
            If M->EEQ_MOEDA == EEC->EEC_MOEDA .And. M->EEQ_PARI <> 1
               RestOrd(aOrd,.t.)
               lRet := .F.
               EasyHelp(STR0219,STR0109)//"O Valor do campo Paridade deve ser igua a '1', quando a moeda for a mesma do Embarque."###"Atenção"
            EndIf
         EndIf
         RestOrd(aOrd,.t.)
      EndIf

// ** JPM 16/12/2009 - nova legis cambial, validação do campo de banco
   //RMD - 07/01/15 - Aproveita a validação para a agência e conta.
   ElseIf (cCpo == "EEQ_BCOEXT" .And. !EMpty(M->EEQ_BCOEXT)) .Or. (cCpo == "EEQ_AGCEXT" .And. !EMpty(M->EEQ_AGCEXT)) .Or. (cCpo == "EEQ_CNTEXT" .And. !EMpty(M->EEQ_CNTEXT))
      SA6->(DbSetOrder(1))

      If !SA6->(DbSeek(xFilial("SA6")+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT)))
         If "EEQ_CNTEXT" $ ReadVar()
	        EasyHelp(STR0248,STR0014)//STR0248	"Banco/Agência/Conta não encontrado."//STR0014  	"Atenção"
	        lRet := .F.
         Else
	         If !SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT+EEQ_AGCEXT)))
	            If "EEQ_AGCEXT" $ ReadVar()
	               EasyHelp(STR0248,STR0014)//STR0248	"Banco/Agência/Conta não encontrado."//STR0014  	"Atenção"
	               lRet := .F.
	            Else
		            If !SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT)))
		               EasyHelp(STR0248,STR0014)//STR0248	"Banco/Agência/Conta não encontrado."//STR0014  	"Atenção"
		               lRet := .F.
		            Else
		               M->EEQ_CNTEXT := SA6->A6_NUMCON
		               M->EEQ_AGCEXT := SA6->A6_AGENCIA
		               M->EEQ_NBCEXT := SA6->A6_NOME
		            EndIf
		        EndIf
	         Else
	            M->EEQ_CNTEXT := SA6->A6_NUMCON
	            M->EEQ_NBCEXT := SA6->A6_NOME
                if cCpo == "EEQ_AGCEXT"
                    AF200LoadCpo("CAMBEXT")
                EndIf
	         EndIf
	     EndIf
      Else
         M->EEQ_NBCEXT := SA6->A6_NOME
         M->EEQ_AGCEXT := SA6->A6_AGENCIA
         M->EEQ_CNTEXT := SA6->A6_NUMCON
         if cCpo == "EEQ_CNTEXT"
               AF200LoadCpo("CAMBEXT")
         EndIf
      EndIf
      If lRet
         M->EEQ_CONTMV := SA6->A6_CONEXP
      EndIf

      // BAK - 28/09/2012
      If lRet .And. !Empty(SA6->A6_COD_P) .And. "105" $ SA6->A6_COD_P
         EasyHelp(STR0321 + AllTrim(AvSx3("A6_COD_P", AV_TITULO)) + STR0322 ,STR0109) //"Informe um banco válido no Exterior. Deve ser informado no campo '" ###  "' (A6_COD_P) um país diferente de Brasil (105)."
         lRet := .F.
      EndIf

      If BlqBxMdDif() // Função que bloqueia a liquidação de invoice com moeda diferente do banco conforme verificações.
          EasyHelp(STR0259 + ENTER + STR0273 + cValToChar(AllTrim(SA6->A6_MOEEASY)) + STR0274 + cValToChar(AllTrim(M->EEQ_MOEDA)) + STR0275,STR0016)
          lRet := .F.
      EndIf

      If lLiqCapExt
         If !EMpty(M->EEQ_BCOEXT) .And. !EMpty(M->EEQ_AGCEXT).And. !EMpty(M->EEQ_CNTEXT) .And. (!IsReceita(M->EEQ_EVENT) .Or. lCallVldAdi ) .And. !Empty(M->EEQ_DTCE)
            M->EEQ_MOEBCO := SA6->A6_MOEEASY
            //MFR 11/10/2020 OSSME-5319
            If empty(M->EEQ_MOEBCO)
               EasyHelp(STR0357, STR0016) //Banco no exterior sem moeda cadastrada
               lRet := .F.
            Else 
               cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV")
               nTxMoeInv := BuscaTaxa(M->EEQ_MOEDA ,M->EEQ_DTCE,,,,,,cC6_TXCV)
               nTxMoeBco := BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,,cC6_TXCV)
               M->EEQ_PRINBC := If( nTxMoeInv > 0 .And. nTxMoeBco > 0 , Round(BuscaTaxa(M->EEQ_MOEDA,M->EEQ_DTCE,,,,,,cC6_TXCV) / BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,,cC6_TXCV), TAMSX3(If(IntegFIN(cModulo),"E1_TXMOEDA","EEQ_PRINBC"))[2]) , 0)
               M->EEQ_VLMBCO := If( M->EEQ_MOEBCO == M->EEQ_MOEDA, M->EEQ_VLFCAM ,If(M->EEQ_PRINBC > 0, M->EEQ_VLFCAM * M->EEQ_PRINBC ,0) )
               M->EEQ_EQVL := If( M->EEQ_MOEBCO == M->EEQ_MOEDA, M->EEQ_VLMBCO, M->EEQ_VLFCAM)  * BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,,cC6_TXCV)
               M->EEQ_TX   := If( !Empty(M->EEQ_DTCE), Round(BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,,cC6_TXCV),TAMSX3(If(IntegFIN(cModulo),"E1_TXMOEDA","EEQ_TX"))[2]) , 0)
               If lCallVldAdi
                  M->EEQ_BANC   := M->EEQ_BCOEXT   //NCF - 29/10/2015
                  M->EEQ_AGEN   := M->EEQ_AGCEXT
                  M->EEQ_NCON   := M->EEQ_CNTEXT
               EndIf
            EndIf
         EndIf
      EndIf

   ElseIf cCpo == "EEQ_MOEDA"
      If Select("Work_Pgto") > 0 .And. Work_Pgto->(FieldPos("EEQ_MOEDA")) > 0 .And. Type("cAdiMoeda") == "C"
         If !(AllTrim(Upper(cAdiMoeda)) == AllTrim(Upper(M->EEQ_MOEDA)))
            M->EEQ_PGT := cToD("")
            M->EEQ_TX  := 0
            M->EEQ_EQVL := 0
            cAdiMoeda := M->EEQ_MOEDA
         EndIf
      EndIf
   //**FSY - 15/04/2013
   ElseIf cCpo == "EEQ_DTCE"
      //MFR 10/11/2020 OSSME-5319 Transferido esse código antes do controle lTelaLote pois não estava gatilhando o campo M->EEQ_PGT
      If Eval(BlAtuPgt)
            M->EEQ_PGT := M->EEQ_DTCE
      EndIf

      //RMD - 18/06/20 - Não deve validar na tela do Painel de Cãmbio, pois não está posicionado em uma parcela específica.
      If (Type("lTelaLote") == "L" .And. lTelaLote)  
         lRet := .T.
         Break
      EndIf
       
      If !Empty(M->EEQ_PGT) .And. Empty(M->EEQ_DTCE) .And. IsReceita(M->EEQ_EVENT) .and. M->EEQ_TIPO # "A"
         EasyHelp(STR0316,STR0016) //"Data de Crédito no Exterior deve ser preenchida para que seja possível liquidar a parcela."
         lRet := .F.
         Break
      EndIf

      //RMD - 10/02/17 - Não permite estornar o crédito se a parcela tiver sido desmembada após o recebimento no exterior
      //THTS - 24/03/2017 - valida se existe o TMP para nao dar erro
      If nTipoDet = ALT_DET .And. Select("TMP") > 0 .And. M->EEQ_DTCE <> TMP->EEQ_DTCE .And. Empty(M->EEQ_DTCE)
         If QbPosMvExt()//IsQbrMExt("TMP")
            EasyHelp(STR0323,STR0016) //"Esta parcela foi desmembrada após o crédito no exterior. Para alterar, exclua as parcelas residuais e execute a operação na parcela principal."
            lRet := .F.
            Break
         //NCF - 24/05/2017 - Não permitir alterar/quebrar e liquidar na mesma manutenção.
         ElseIf EasyVerModal("TMP") .AND. (M->EEQ_VL <> TMP->EEQ_VL .AND. !Empty(TMP->EEQ_DTCE) .OR. avflags("EEC_LOGIX") .And. TMP->TMP_RECNO > 0 .AND. EEQ->(dbGoTo(TMP->TMP_RECNO),M->EEQ_VL <> EEQ->EEQ_VL))
            EasyHelp(STR0324,STR0016) //"Esta parcela será desmembrada devido a alteração do valor. Confirme o desmembramento para alterar o crédito no exterior."
            lRet := .F.
            Break
         Endif
      EndIf

      If ! empty(M->EEQ_VCT) .and. ! empty(M->EEQ_DTCE) .and. EasyVerModal("M")
         If M->EEQ_DTCE > M->EEQ_VCT
            nDias := M->EEQ_DTCE - M->EEQ_VCT
            If nDias > EasyGParam("MV_AVG0128",,9999)//RMD - 08/12/06 - Para permitir que o intervalo seja personalizado
               EasyHelp(StrTran(STR0216, "###", AllTrim(Str(EasyGParam("MV_AVG0128",,9999)))), STR0014) //"Data de liquidação do contrato não pode ser superior a 10 dias da Data de Vencimento." "Atenção"
               lRet := .f.
               Break
            EndIf
         EndIf
      EndIf

      If lFinanciamento
         nOrd := EF3->(IndexOrd())
         nRecno := EF3->(Recno())

         EF3->(DbSetOrder(2))
         If EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(M->EEQ_TP_CON $ ("2/4"),"I","E"),"")+"600"+M->(EEQ_NRINVO+If(!lParFin .Or. Empty(M->EEQ_PARFIN), M->EEQ_PARC, M->EEQ_PARFIN) )) ) //HVR SEEK I OU E
            If !Empty(M->EEQ_DTCE) .And. M->EEQ_DTCE < EF3->EF3_DT_EVE//data do credito sempre maior que a data do evento.
               EasyHelp(STR0258+DtoC(EF3->EF3_DT_EVE) )//"Data do credito exterior deve ser maior que a data do evento no contrato de financiamento. Deve ser maior que: "
               lRet := .F.
            End If
         End If

         EF3->(DbSetOrder(nOrd))
         EF3->(DbGoTo(nRecno))
      EndIf

      If Eval(BlAtuPgt)
             
            If !EMpty(M->EEQ_BCOEXT) .And. !EMpty(M->EEQ_AGCEXT).And. !EMpty(M->EEQ_CNTEXT)         //NCF - 05/11/2015

               SA6->(DbSetOrder(1))
               If !SA6->(DbSeek(xFilial("SA6")+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT)))
                  If "EEQ_CNTEXT" $ ReadVar()
	                 EasyHelp(STR0248,STR0014)//STR0248	"Banco/Agência/Conta não encontrado."//STR0014  	"Atenção"
	                 lRet := .F.
                  Else
	                 If !SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT+EEQ_AGCEXT)))
	                    If "EEQ_AGCEXT" $ ReadVar()
	                       EasyHelp(STR0248,STR0014)//STR0248	"Banco/Agência/Conta não encontrado."//STR0014  	"Atenção"
	                       lRet := .F.
	                    Else
		                   If !SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT)))
		                      EasyHelp(STR0248,STR0014)//STR0248	"Banco/Agência/Conta não encontrado."//STR0014  	"Atenção"
		                      lRet := .F.
		                   Else
		                      M->EEQ_CNTEXT := SA6->A6_NUMCON
		                      M->EEQ_AGCEXT := SA6->A6_AGENCIA
		                      M->EEQ_NBCEXT := SA6->A6_NOME
		                   EndIf
		                EndIf
	                 Else
	                    M->EEQ_CNTEXT := SA6->A6_NUMCON
	                    M->EEQ_NBCEXT := SA6->A6_NOME
	                 EndIf
	              EndIf
               Else
                  M->EEQ_NBCEXT := SA6->A6_NOME
                  M->EEQ_AGCEXT := SA6->A6_AGENCIA
                  M->EEQ_CNTEXT := SA6->A6_NUMCON
               EndIf

               M->EEQ_MOEBCO := SA6->A6_MOEEASY
               cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV")
               nTxMoeInv := BuscaTaxa(M->EEQ_MOEDA ,M->EEQ_DTCE,,,,,cC6_TXCV)
               nTxMoeBco := BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,cC6_TXCV)
               M->EEQ_PRINBC := If( nTxMoeInv > 0 .And. nTxMoeBco > 0 , Round(BuscaTaxa(M->EEQ_MOEDA,M->EEQ_DTCE,,,,,cC6_TXCV) / BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,cC6_TXCV), TAMSX3(If(IntegFIN(cModulo),"E1_TXMOEDA","EEQ_PRINBC"))[2]) , 0)
               M->EEQ_VLMBCO := If( M->EEQ_MOEBCO == M->EEQ_MOEDA, M->EEQ_VLFCAM ,If(M->EEQ_PRINBC > 0, M->EEQ_VLFCAM * M->EEQ_PRINBC ,0) )
               M->EEQ_EQVL   := If( M->EEQ_MOEBCO == M->EEQ_MOEDA, M->EEQ_VLMBCO, M->EEQ_VLFCAM)  * BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,cC6_TXCV)
               M->EEQ_TX     := IF( !Empty(M->EEQ_DTCE), Round(BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,cC6_TXCV),TAMSX3(If(IntegFIN(cModulo),"E1_TXMOEDA","EEQ_TX"))[2]) , 0)

               If lCallVldAdi
                  M->EEQ_BANC   := M->EEQ_BCOEXT   //NCF - 29/10/2015
                  M->EEQ_AGEN   := M->EEQ_AGCEXT
                  M->EEQ_NCON   := M->EEQ_CNTEXT
               EndIf
            EndIf

         
      EndIf

   ElseIf cCpo == "EEQ_ACRESC" .OR. cCpo == "EEQ_DECRES"
      If M->EEQ_DECRES > 0 .And. M->EEQ_ACRESC > 0
         EasyHelp(STR0271) //"Não poderá ser informado acréscimo e decréscimo para a mesma parcela. Informe apenas o acréscimo ou o decréscimo!"
         lRet := .F.
      EndIf

      If cCpo == "EEQ_DECRES"
         If M->EEQ_DECRES > (M->EEQ_VL - M->EEQ_CGRAFI)
            EasyHelp(STR0272) //"O valor de decréscimo informado é igual ou excede o valor da parcela !"
            lRet := .F.
         EndIF
      EndIf
      
      If lRet .And. lCpoAcrDcr .And. M->EEQ_VLFCAM  < 0
         MsgVLFCAM() //THTS - 05/08/2019 - Mensagem de informando que o valor de fechamento de cambio é inválido
         lRet := .F.
      EndIf

    ElseIF cCpo =="EEQ_MULTA" .Or. cCpo =="EEQ_JUROS"
       If M->EEQ_VLFCAM < 0
          EasyHelp(STR0262) //"A somatória dos Decréscimos e Descontos é igual ou excede o valor da parcela somados o Acréscimos, Juros e Multa!"
          lRet := .F.
       EndIf

   EndIf
   //**
   //LRS - 26/08/2015 - Validação do banco caso seja bloqueado.
   IF !Empty(M->EEQ_BANC) .And. !Empty(M->EEQ_AGEN) .And. !Empty(M->EEQ_NCON)
       aOrdSA6 := SaveOrd("SA6")
       SA6->(DbSetOrder(1))
	   IF SA6->(DbSeek ( xFilial("SA6")+M->EEQ_BANC+M->EEQ_AGEN+M->EEQ_NCON))
		   IF SA6->A6_BLOCKED == "1"
		      Help( " ", 1, "CCBLOCKED" )
             M->EEQ_BANC   := AvKey("","EEQ_BANC")
             M->EEQ_AGEN   := AvKey("","EEQ_AGEN")
             M->EEQ_NCON   := AvKey("","EEQ_NCON")
             M->EEQ_NOMEBC := AvKey("","EEQ_NOMEBC")
		   EndIF
	   EndIF
	   RestOrd(aOrdSA6,.T.)
   EndIF

   If cCpo == "EEQ_PRINBC"

      If IntegFIN(cModulo) .And. ( nTipoDet == LIQ_DET .Or. IsLiqFFC() .Or. lCallVldAdi ) //NCF - 26/03/2019
         cTaxaInf := Alltrim(Str(M->EEQ_PRINBC))
         cExcDecTx := Substr(  cTaxaInf , At(".", cTaxaInf ) + TamSX3("E1_TXMOEDA")[2] + 1  )
         If Val(cExcDecTx) > 0
            EasyHelp( StrTran( STR0306 ,"####", Alltrim(Str(TamSX3("E1_TXMOEDA")[2]))) ,STR0016) //"O número de casas decimais informada deve ser igual a #### para que possa ocorrer a integração com o módulo Financeiro!"
            lRet := .F.
            BREAK
         EndIf
      EndIf

      If Empty(M->EEQ_DTCE)
         EasyHelp(STR0276) //"Data do Crédito/Débito no exterior (Dt.Cre./Deb.) deve ser informada!"
         lRet := .F.
      Else
         cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV")
         M->EEQ_EQVL := If( M->EEQ_MOEBCO == M->EEQ_MOEDA, M->EEQ_VLMBCO, M->EEQ_VLFCAM)  * BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,cC6_TXCV)//M->EEQ_VLMBCO := M->EEQ_VL * M->EEQ_PRINBC
         M->EEQ_TX   := Round(BuscaTaxa(M->EEQ_MOEBCO,M->EEQ_DTCE,,,,,cC6_TXCV),TAMSX3(If(IntegFIN(cModulo),"E1_TXMOEDA","EEQ_TX"))[2]) //M->EEQ_PRINBC   NCF - 09/11/2015
      EndIf

   EndIf

   If cCpo == "EEQ_VLMBCO"

      //RMD - 20/10/06 - Quando for FFC, compara com o valor total da soma das parcelas, e não só com  o valor de uma.
      If IsLiqFFC()  // By JPP - 07/12/2006 - Correção na definição do valor da variável nValComp
         nValComp := nTotFFC //Valor total do FFC
      Else
         nValComp := M->EEQ_VLFCAM //M->EEQ_VL //Valor da parcela comentado por WFS
      EndIf

      lBxCAPMvEx := AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal("M")
      nVlrCompRS := AF200CnvCmb( "M",nValComp,TAMSX3(If(lBxCAPMvEx,"EEQ_VLMBCO","EEQ_EQVL"))[2] ,"EEQ_VLMBCO",nTipoDet)
      nMaxVarCmb := EasyGParam("MV_AVGVLMX",,0) 
      nDifInfxPa := ABS(nVlrCompRS - If( lBxCAPMvEx, M->EEQ_VLMBCO , M->EEQ_EQVL ) )

      If nDifInfxPa > nMaxVarCmb   
         EasyHelp(STR0277 + ENTER + STR0278 + cValtoChar(nDifInfxPa) + ENTER + ;
         STR0279 + cValtochar( EasyGParam("MV_AVGVLMX",,0) ) ,STR0016)  //""A variação do valor na moeda do banco em relação à taxa/paridade excede o permitido conforme configurado no parâmetro MV_AVGVLMX.""//"Aviso"
         lRet := .f.
      EndIf

   EndIf

   If cCpo == "EEQ_MODAL"
      If ( (nTipoDet <> LIQ_DET .And. nTipoDet <> 0) .Or. lCallVldAdi  ) .And. EasyVerModal("M")  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
         If !IsReceita(M->EEQ_EVENT)
            M->EEQ_DTCE := cTod("  /  /  ")
         ElseIf lCallVldAdi
            If Empty(M->EEQ_PGT) .And. !Empty(M->EEQ_DTCE)
               M->EEQ_PGT := M->EEQ_DTCE
            EndIf
         EndIf
      ElseIf EasyVerModal("M") .and. nTipoDet == LIQ_DET
         If Empty(M->EEQ_PGT) .And. !Empty(M->EEQ_DTCE)
            M->EEQ_PGT := M->EEQ_DTCE
         EndIf
      EndIf
   EndIf

END SEQUENCE

DBSELECTAREA(nOLDAREA)

RETURN(lRET)

/*
Funcao      : AF200W.
Parametros  : cCpo    - Nome do campo a ser validado.
Objetivos   : Habilitar/Desabilitar o campo passado como parâmetro.
Retorno     : .t./.f.
Autor       :
Data/Hora   :
Revisão     : Jeferson Barros Jr. 18/08/04 - 17:33.
*/
*-------------------*
FUNCTION AF200W(cCPO)
*-------------------*
LOCAL lRET:=.T.,nOLDAREA:=SELECT()
Local aOrd:=SaveOrd({"EC6", "EF3"})
Local lCallVldAdi := ( IsInCallStack('Ap100AdiMan')  .Or. IsInCallStack('AC100Adian') ) .and. Select('Work_Pgto') > 0 .And. Type('M->EEQ_EVENT') <> 'U' .And. M->EEQ_EVENT $ '602/605/606/607'  //NCF - 01/10/2015 - Adiant. com Mov. Exterior  //NCF - 04/07/2019
Local cAliasWork := If(lCallVldAdi, "Work_Pgto", "TMP")
Private lLiqCapExt:= IF(Type("lLiqCapExt") ="U" , AVFLAGS("CAMBIO_EXP_MOV_EXT") ,lLiqCapExt)

If Type("nTipoDet") = "U" .Or. nTipoDet = Nil    // Trata a Variavel caso a chamada da função não seja do controle de câmbio
   nTipoDet := 0
Endif

If Type("nOpcAdClPd") = "U" .Or. nOpcAdClPd = Nil    //NCF - 01/10/2015 - Adiant. com Mov. Exterior(Variável para flag de When das rotinas de Adiant. Cliente e Pedido)
   nOpcAdClPd := 0
Endif

If Type("nTipoOpc") = "U" .Or. nTipoOpc = Nil                                              //NCF - 04/12/2015 - variável utilizada na função AF200TITFIN
   If lCallVldAdi .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal('Work_Pgto')
      nTipoOpc := nOpcAdClPd
   Else
      nTipoOpc := nTipoDet
   EndIf
EndIf

If Type("lParFin") = "U" .Or. ValType(lParFin) <> "L"
   lParFin := .F.
Endif

Begin Sequence

   cCpo := AllTrim(Upper(cCpo))

   Do Case
      Case cCpo == "EEQ_VLCOR"
          If !lFinanciamento
             lRet := ! Empty(M->EEQ_CORR)
          EndIf

      Case cCpo == "EEQ_MOEDA"
          //AAF 29/11/05 - É Permitido alteração caso o tipo de contrato seja 3 ou 4.
          If (EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. M->EEQ_TP_CON $ "3/4" .OR. Empty(M->EEQ_TP_CON)) //LRS - 19/03/2018
             lRet:= .T.
             BREAK
          EndIf

          If ValType(M->EEQ_EVENT) <> "U"
             lRet := !IsReceita(M->EEQ_EVENT)
          EndIf

      Case cCpo $ ("EEQ_CODEMP/EEQ_PARI")
          If M->EEQ_EVENT <> "101"
             lRet := !IsReceita(M->EEQ_EVENT)
             If !lRet
                M->&(cCpo)    := CriaVar(cCpo)
                M->EEQ_FORN   := CriaVar("EEQ_FORN")
                M->EEQ_FOLOJA := CriaVar("EEQ_FOLOJA")
                M->EEQ_PARI   := 1
             EndIf
          EndIf

      // ** JPM - 15/04/05
      Case cCpo $ "EEQ_IMPORT/EEQ_IMLOJA"
          If M->EEQ_EVENT <> "101"
             lRet := IsReceita(M->EEQ_EVENT)
             If !lRet
                M->&(cCpo) := CriaVar(cCpo)
             EndIf
          EndIf

      Case cCpo == "EEQ_CGRAFI"
           If (Tmp->EEQ_EVENT <> EV_PRINC2)
              lRet:=.f.
              Break
           EndIf

           If !Af200TemComissao("EEQ_CGRAFI")
              lRet:=.f.
              Break
           EndIf

           EF3->(DbSetOrder(3))
           If EF3->(DbSeek(xFilial("EF3")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)))
              lRet:=.f.
           EndIf

      Case cCpo == "EEQ_AREMET"

           If (Tmp->EEQ_EVENT <> EV_PRINC2)
              lRet:=.f.
              Break
           EndIf

           If !Af200TemComissao("EEQ_AREMET")
              lRet:=.f.
              Break
           EndIf

           EF3->(DbSetOrder(3))
           If EF3->(DbSeek(xFilial("EF3")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)))
              lRet:=.f.
           EndIf

      Case cCpo == "EEQ_ADEDUZ"

           If (Tmp->EEQ_EVENT <> EV_PRINC2)
              lRet:=.f.
              Break
           EndIf

           If !Af200TemComissao("EEQ_ADEDUZ")
              lRet:=.f.
              Break
           EndIf

           EF3->(DbSetOrder(3))
           If EF3->(DbSeek(xFilial("EF3")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)))
              lRet:=.f.
           EndIf

      Case cCpo == "EEQ_EMISSA" // BAK - 27/09/2012
         If EEQ->(FieldPos("EEQ_EMISSA")) > 0 .And. !INCLUI
            lRet:= .f.
         EndIf

      Case cCpo == "EEQ_BANC" .Or. cCpo == "EEQ_AGEN" .Or. cCpo == "EEQ_NCON" .Or. cCpo == "EEQ_NOMEBC" // BAK - 27/09/2012
		 //RMD - 18/06/20 - Quando estiver na tela de painel de câmbio, o que irá definir a possibilidade de edição do campo no lote será a modalidade
         If IsMemVar('lAF300') .And. lAF300 //Se for FFC
            lRet := .T. //Quando é FFC, os campo de banco devem ficar liberados para digitação sempre.
         Else
            
            If (Type("lTelaLote") == "L" .And. lTelaLote) .Or. !IsReceita(M->EEQ_EVENT)
               lRet := !Empty(M->EEQ_MODAL) .And. !EasyVerModal("M")
               Break            
            EndIf            
            If (Select("TMP") > 0)  .Or. lCallVldAdi .Or. M->EEQ_TP_CON == "3" //NCF - 01/10/2015 - Adiant. com Mov. Exterior

               If IsInCallStack("EECAF500") .And. M->EEQ_TP_CON == "3"
                  cAliasWork:= "EEQ"
               EndIf

               If Type("lLiqParWhen") == "U"
                  lLiqParWhen:= .F.
               EndIf

               If !lCallVldAdi .And. EasyVerModal("M") ;
                  .And. (lLiqParWhen .Or. !Empty((cAliasWork)->EEQ_DTCE)) ;
                  .And. !IsQbrMExt(cAliasWork) ;
                  .And. ( If( Type('INCLUI') == 'L' .And. Type('ALTERA') == 'L', INCLUI .Or. ALTERA, .F.) .Or. lLiqParWhen);
                  .And. (!AF200TITFIN( (cAliasWork)->EEQ_FINNUM,3,(cAliasWork)->EEQ_PARC, cAliasWork ) .and. !avflags("EEC_LOGIX") ) ;
                  .And. !((cAliasWork)->EEQ_EVENT == "101" .And. (cAliasWork)->EEQ_TIPO == "A")// Movimento no Exterior
                     lRet := .F.
                     Break
               EndIf
               
               If !lCallVldAdi .And. !empty((cAliasWork)->EEQ_PGT)
                  lRet:= .F.
                  Break
               elseif EasyVerModal("M") .and. (empty((cAliasWork)->EEQ_DTCE) .Or. lCallVldAdi .Or. nTipoDet == ALT_DET) //RNLP -- O Teste da Data de Credito é devido ao EECAF500 e ao Câmbio do tipo a pagar
                  lRet:= .F.
                  Break
               EndIf
            
               /* Quando a parcela estiver vinculada à um contrato de financiamento, deve ser considerado o banco deste contrato.*/
               If lFinanciamento
                  EF3->(DBSetOrder(3))//EF3_FILIAL+EF3_TPMODU+EF3_INVOIC+EF3_PARC+EF3_CODEVE
                  If EF3->(DBSeek(xFilial("EF3") + "E" + M->EEQ_NRINVO +;
                     IIf(!lParFin .Or. Empty((cAliasWork)->EEQ_PARFIN), (cAliasWork)->EEQ_PARC, (cAliasWork)->EEQ_PARFIN) +;
                     EV_EMBARQUE)) .And. !Empty(&("M->" + cCpo))

                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf
         EndIf
         
      Case cCpo == 'EEQ_BCOEXT' .Or. cCpo == "EEQ_AGCEXT" .Or. cCpo == "EEQ_CNTEXT" .Or. cCpo == "EEQ_NBCEXT" // BAK - 27/09/2012
         //RMD - 18/06/20 - Quando estiver na tela de painel de câmbio, o que irá definir a possibilidade de edição do campo no lote será a modalidade
         If Type("lTelaLote") == "L" .And. lTelaLote
            lRet := !Empty(M->EEQ_MODAL) .And. EasyVerModal("M")
            Break
         EndIf

         If (Select("TMP") > 0)  .Or. lCallVldAdi .Or. M->EEQ_TP_CON == "3"
            If IsInCallStack("EECAF500") .And. M->EEQ_TP_CON == "3"
               cAliasWork:= "EEQ"
            EndIf
            
            If ! lCallVldAdi .and. ! EasyVerModal("M") ;
               .And. ( If( Type('INCLUI') == 'L' .And. Type('ALTERA') == 'L', INCLUI .Or. ALTERA, .F.) ;
                     .Or. Type("lLiqParWhen") == "L" .And. lLiqParWhen) ;
               .And. Empty(M->EEQ_BCOEXT)// Contrato de Cambio	
                  lRet := .F.
                  Break
            EndIf
            
            if lCallVldAdi .and. !easyVerModal("M")
               lret := .F.
               break
            endif

            If ! EasyVerModal("M") .And. !INCLUI .And. !Empty((cAliasWork)->EEQ_DTCE) .And. !Empty((cAliasWork)->EEQ_BCOEXT)
               lRet:= .F.
               Break
            EndIf
		   EndIF
      Case cCpo $ "EEQ_DTCE"
         If iIf( Type('INCLUI') == 'L' .And. Type('ALTERA') == 'L', INCLUI .Or. ALTERA, .T.) ;
            .And. (!IsReceita(M->EEQ_EVENT) .Or. lCallVldAdi ;
                  .Or. (M->EEQ_EVENT == "101" .And. M->EEQ_TIPO == "A") );
            .And. lLiqCAPExt  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
            If EasyVerModal("M")
               /* If lCallVldAdi
                  If nOpcAdClPd <> 5 .And. !Empty(M->EEQ_DTCE)
                     lRet := .F.
                  EndIf
               Else */If (M->EEQ_EVENT == "101" .And. M->EEQ_TIPO == "A")
                  lRet := .F. //O crédito no exterior dos adiantamentos somente pode ser removido na manutenção de adiantamentos
               Else
                  If nTipoDet <> LIQ_DET .And. nTipoDet <> 0 //!Empty(M->EEQ_DTCE)
                     lRet := .F.
                  EndIf
               EndIF
            EndIf
         EndIf

      Case cCpo $ "EEQ_SOL/EEQ_DTNEGO"
         If EasyVerModal("M") .And. (!IsReceita(M->EEQ_EVENT) .Or. lCallVldAdi ) .And. lLiqCAPExt
            lRet := .F.
         EndIf

      Case cCpo $ "EEQ_PGT/EEQ_TX/EEQ_EQVL/EEQ_SOL/EEQ_DTNEGO"
         IF ( (nTipoDet == LIQ_DET .And. !IsReceita(M->EEQ_EVENT)) .Or. lCallVldAdi ) .And. lLiqCAPExt  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
            If EasyVerModal("M")
               //If If(lCallVldAdi , cCpo <> 'EEQ_PGT' .Or. nOpc <> 5 , .T.)
                  lRet := .F.
               //EndIf
            EndIf
         EndIf
      Case cCpo $ "EEQ_MOEBCO/EEQ_PRINBC/EEQ_VLMBCO"
         If !EasyVerModal("M") .And. ( If(!Empty(M->EEQ_FFC),.T.,INCLUI) .Or. ALTERA .Or. Type("lLiqParWhen") == "L" .And. lLiqParWhen) .Or. ( nTipoDet <> LIQ_DET .And. nTipoDet <> 0)
            lRet := .F.
         Else
            If cCpo == "EEQ_PRINBC"
               If M->EEQ_MOEBCO == M->EEQ_MOEDA
                  lRet := .F.
               EndIf
            EndIf
         EndIf
      Case cCpo == "EEQ_MODAL"  //NCF - 04/07/2019
         If lCallVldAdi .And. !AvFlags("EEC_LOGIX") .And. M->EEQ_EVENT == "606"
            lRet := .F.
            Break
         EndIf

         If (Select("TMP") > 0)         
            If !lCallVldAdi .And. (!Empty(TMP->EEQ_DTCE) .And. IsReceita(TMP->EEQ_EVENT)  .Or. !Empty(TMP->EEQ_PGT))
               lRet := .F.
               Break
            EndIf
            if isMemVar('nTipoDet') .and. nTipoDet == LIQ_DET .And. IsReceita(TMP->EEQ_EVENT)
               lRet := .F.
               Break
            EndIf   

         EndIf

        
   EndCase

End Sequence

RestOrd(aOrd)

DBSELECTAREA(nOLDAREA)

RETURN(lRET)

*--------------------------------------------------------------------
FUNCTION AF200EST(cP_ALIAS,nP_REG,nP_OPC)
EEC->(RECLOCK("EEC",.F.))
BEGIN SEQUENCE
   EEQ->(DBSETORDER(1))
   IF (EEQ->(DBSEEK(XFILIAL("EEQ")+EEC->EEC_PREEMB)))
      IF ! EMPTY(EEQ->EEQ_FFC)
         HELP(" ",1,"AVG0005085") //MSGINFO("Não é Possível Realizar o Estorno."+ENTER+"Parcela Com FFC.","Atenção")
         BREAK
      ENDIF
      IF MSGNOYES(STR0013,STR0014) //"Confirma o Estorno ?"###"Atenção"
         DO WHILE ! EEQ->(EOF()) .AND.;
            EEQ->(EEQ_FILIAL+EEQ_PREEMB) = (XFILIAL("EEQ")+EEC->EEC_PREEMB)
            *
            EEQ->(RECLOCK("EEQ",.F.))
            EEQ->EEQ_SOL    := AVCTOD("  /  /  ")
            EEQ->EEQ_DECAM  := SPACE(01)
            EEQ->EEQ_NROP   := SPACE(20)
            EEQ->EEQ_PGT    := AVCTOD("  /  /  ")
            EEQ->EEQ_DTCE   := AVCTOD("  /  /  ")
            If(!lFinanciamento,EEQ->EEQ_DTCC := AVCTOD("  /  /  "),)
            EEQ->EEQ_TX     := 0
            EEQ->EEQ_EQVL   := 0
            EEQ->EEQ_BANC   := SPACE(03)
            EEQ->EEQ_AGEN   := SPACE(05)
            EEQ->EEQ_NCON   := SPACE(10)
            EEQ->EEQ_NOMEBC := SPACE(40)
            EEQ->EEQ_RFBC   := SPACE(20)
            EEQ->EEQ_CORR   := SPACE(15)
            If(lFinanciamento,EEQ->EEQ_JRAA := 0,)
            If(!lFinanciamento,EEQ->EEQ_ADIA := 0,)
            If(lFinanciamento,EEQ->EEQ_RESP := SPACE(35),)
            If(!lFinanciamento,EEQ->EEQ_CTDC := SPACE(01),)
            EEQ->EEQ_DTNEGO := AVCTOD("  /  /  ")
            If(!lFinanciamento,EEQ->EEQ_VLCOR  := 0,)
            EEQ->(MSUNLOCK(),DBSKIP())
         ENDDO
      ENDIF
   ENDIF
END SEQUENCE
EEC->(MSUNLOCK())
RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION AF200GPARC(cFil)
Static cEventosOK   // Tratamento dos campos novos frete/seguro/comissão, sem a configuração de parametros para geração de contas a pagar.

Static aDespesas := {} // ** JPM - 03/03/05 - Declarada como estática, pois o retorno do X3DIReturn só é atribuido a
                       // ela na 1ª vez.
Local Z,I,lMUDA,nTOTAL := 0//,aPARC  := {}
Local nVlEmbarque := EEC->EEC_TOTPED, aOrd:=SaveOrd({"EEQ", "EEC"})
Local nParcAux
Local lAchouParcela
Local nValor, dDtBase, aEventos, nEvento, aParcDI, aParcCom, nPos, nEEQRegOld, nEEQIndexOrd
Local cCondPag, nSeqParc := 0, j
Local cCondPagCb := "" //MCF - 20/01/2017
Local nEECRecno //, aParcOffShore
Local cKey
Local aRecNoEEQ :={} // LRS - Varialvel para troca data Contas Receber

Local nVlAdiant := 0, nAdiantRest := 0, nAdiantAtual := 0
Local nComRest := 0, nComAtual := 0, nCont
Local bWhileExp := {|| EXP->(!EoF()) .And. (xFilial("EXP")+EEC->EEC_PREEMB == EXP->(EXP_FILIAL+EXP_PREEMB) ) }

Local lRet := .T.
Local aParcNew := {}
Local aPropCampo := TamSX3("EEQ_ORIGEM") //MFR 23/04/2019 OSSME-2859  
Local lAltDtEmb := (IsMemVar('dDtEmb') .And. IsMemVar('dDtMemEmb') .And. dDtEmb != dDtMemEmb) //THTS - 12/09/2019 - Quando vindo do Embarque, define se a data de embarque foi alterada
Local cC6_TXCV 
Private aParcAux := {}
Private aParc := {}, aParcOffShore := {}
Private nCMP_VLR, dCMP_VCT, lFilOffShore
Private lParcdeAdiant := .F.

Private cEventosNaoGerados, lInicializa := .F. //JPM
Private dDTEMBA := EEC->EEC_DTEMBA
Private cNatureza:= ""

//Define as despesas que geram contas a pagar
Private cDespIntFin := "120/102/103/127/150/129" //THTS - 16/05/2017 - adicionado o evento 129 na lista de despesas"
Private lGrvCamCon  := .T. //LRS - 27/06/2017

Default cFil := xFilial("EEC")

/*ISS - 5/01/11 - Ponto de entrada para a alteração da variável dDTEMBA que guarda a data do campo EEC_DTEMBA,
                  este campo será usado em diversas validações abaixo. */
If EasyEntryPoint("EECAF200")
   ExecBlock("EECAF200", .F., .F., "AF200GPARC_ALTDTEMBA")
EndIf

If Type("lAltValPosEmb") = "U"
   Private lAltValPosEmb := EasyGParam("MV_AVG0081",,.f.)
EndIf

If Type("lDtEmba") = "U"
   Private lDtEmba := .f.
EndIf

lEEQ_TP_CON := EEQ->(FIELDPOS("EEQ_TP_CON")) > 0 //Alcir Alves  - 28-11-05

lFilOffShore := cFil == cFilEx

If EECFlags("INVOICE") // JPM - 02/08/05
   EXP->(DbSetOrder(1))
EndIf

/*
AMS - 03/02/2005 às 17:36. Posicionamento no processo da filial de Off-Shore.
*/
If lFilOffShore
   EEC->( dbSetOrder(1),;
          dbSeek(cFil+EEC_PREEMB) )
EndIf

/*
AMS - 03/02/2005 às 11:46. Definição das variaveis lParVin e lOkEvent quando a AF200GParc é envocada do embarque.
*/
If Type("lParVin") = "U"
   Private lParVin := EEQ->(FieldPos("EEQ_PARVIN")) > 0
EndIf

If Type("lOkEVENT") = "U"
   Private lOkEVENT := EEQ->(FieldPos("EEQ_EVENT")) > 0
EndIf

If Type("lIntermed") = "U"
   Private lIntermed := .F.
EndIf

//RMD - 13/06/08 - Recria a variável cEventosOK caso tenha alternado entre a gravação do processo na filial Off-Shore e na Brasil
If ValType(cEventosOK) == "C"
   If lIntermed .And. lFilOffShore .And. !("133" $ cEventosOK)
      lInicializa := .T.
   ElseIf !(lIntermed .And. lFilOffShore) .And. ("133" $ cEventosOK)
      lInicializa := .T.
   EndIf
EndIf

If Type("lRollBack") <> "L"
   lRollBack := .F.
EndIf

EEQ->(DbSetOrder(1))
If IsIntEnable("001") .And. EEC->(FieldPos("EEC_TITCAM")) > 0 .And. !Empty(EEC->EEC_TITCAM) .And. !EEQ->(DbSeek(xFilial()+EEC->EEC_PREEMB))  // GFP - 01/10/2014
	SE1->(DbSetOrder(1))
	If SE1->(DbSeek(xFilial()+"EEC"+AllTrim(EEC->EEC_TITCAM)))
		If EEC->(isLocked())
			EEC->(RecLock("EEC", .F.))
			EEC->EEC_TITCAM := EECGetFinN("SE1")
			EEC->(MsUnlock())
		Else
			EEC->EEC_TITCAM := EECGetFinN("SE1")
		EndIf
	EndIf
EndIf

If EasyEntryPoint("EECAF200")
   ExecBlock("EECAF200",.f.,.f.,"INICIALIZA_EVENTOS")
Endif

// by CAF 06/01/2005 Testar conteudo dos MV para os campos da tela de Despesas Internacionais X EC6
IF ValType(cEventosOK) <> "C" .Or. lInicializa
   cEventosOK := "101/"

   IF EECFlags("FRESEGCOM")
      cEventosOK += "120/121/122/" // Adicionar eventos de comissão.
      aDespesas := X3DIReturn()
   Endif

   For j := 1 To Len(aDespesas)
      If !EasyGParam("MV"+SubStr(aDespesas[j][2], 4), .T.)
         Loop
      EndIf

      If !EC6->(dbSeek(xFilial()+AVKey("EXPORT", "EC6_TPMODU")+AVKey(EasyGParam("MV"+SubStr(aDespesas[j][2], 4)), "EC6_ID_CAM")))
         Loop
      EndIf

      cEventosOK += AVKey(EasyGParam("MV"+SubStr(aDespesas[j][2],4)),"EC6_ID_CAM")+"/"
   Next

   If lIntermed .And. lFilOffShore
      If !("133" $ cEventosOK)
         cEventosOK += "133/"
      EndIf
   EndIf

   // ** JPM - 15/04/05 - Retirar eventos que não devem ser gerados
   cEventosNaoGerados := EasyGParam("MV_AVG0087",,"",cFil)
   If EasyEntryPoint("EECAF200") // ** JPM - ponto de entrada para retirar eventos específicos para 1 embarque.
      ExecBlock("EECAF200",.f.,.f.,"EVENTOS_NAO_GERADOS")
   Endif
   nPos := 1
   While nPos < Len(cEventosNaoGerados)
      cEvento := SubStr(cEventosNaoGerados,nPos,3)
      If (nPosEvento := At(cEvento,cEventosOk)) > 0
         cEventosOk := SubStr(cEventosOk,1,nPosEvento - 1) + SubStr(cEventosOk,nPosEvento + 4)
      EndIf
      nPos += 4
   EndDo
Endif

// By JBJ - 03/07/03 - 09:59 - Não gerar parcelas de câmbio para os status abaixo. 
If lGrvCamCon //LRS - 27/06/2017
   IF (EEC->EEC_STATUS $ ST_CC+ST_EP+ST_CO .And. !lAltValPosEmb) .Or. EEC->EEC_STATUS == ST_CO .AND. lAltValPosEmb .AND. EEC->EEC_PRECOA == "1"
	  Return (Nil)
   EndIF
EndIf

/* ISS - 06/08/10 - Não gera parcelas de câmbio quando a condição de pagamento e o modo de pagamento forem consignados,
   somente aplicada quando o embarque for feito através da rotina "Consig. Rem. Exp." (Remessa de Exportação por Consignação). */
If ( EEC->EEC_MPGEXP == "002" .And. cTipoProc == PC_RC )
   Return (Nil)
EndIf

aAdt := AE102ADTVLD() // retorno {nPercEsp, nTotEsp, nPercAss, nTotAss, nDif, aAdtAssd}
Eval({|x| nVlEmbarque := x[1], nSeqParc := x[2], nVlAdiant := x[3]}, AF200TotParc(cFil))

Begin Sequence

//ISS - 05/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA para atender o ponto de entrada "AF200GPARC_ALTDTEMBA"
If !Empty(dDTEMBA)


   If EECFlags("INVOICE") .And. EXP->(DbSeek(xFilial("EXP")+EEC->EEC_PREEMB ))// JPM - 02/08/05 - Geração de parcelas por invoice
        aParc      := {}
        nVlInvoice := 0

        While Eval(bWhileEXP)

            if nVlAdiant > 0
                if EXP->EXP_TOTPED == M->EEC_TOTPED
                    nVlInvoice := Round( EXP->EXP_TOTPED - nVlAdiant , AvSx3("EEQ_VL",AV_DECIMAL) )
                else
                    nVlInvoice := EXP->EXP_TOTPED - Round( EXP->EXP_TOTPED/M->EEC_TOTPED * nVlAdiant , AvSx3("EEQ_VL",AV_DECIMAL) )
                endif
            else
                nVlInvoice := EXP->EXP_TOTPED
            endif

            aParcAtu := AF200GPCD(  nVlInvoice ,;
                                    EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)),;
                                    dDTEMBA ,;
                                    EV_PRINC2 ,;
                                    EEC->EEC_FORN ,;
                                    EEC->EEC_FOLOJA ,;
                                    "" ,;
                                    EXP->EXP_NRINVO )

            //ordena as parcelas de acordo com a data de vencimento 
            Eval({|x, y| aSize( x,Len(x)+Len(y) ) , aCopy( y, x,,,Len(x)-Len(y)+1 )}, aParc, aParcAtu)
    
            EXP->(DbSkip())
        EndDo

   Else
      //ISS - 05/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA para atender o ponto de entrada "AF200GPARC_ALTDTEMBA"
      aParc := AF200GPCD( nVlEmbarque,;
                          EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)),;
                          dDTEMBA,;
                          EV_PRINC2,;
                          EEC->EEC_FORN,;
                          EEC->EEC_FOLOJA,;
                          "" )
   EndIf

   //ER - 24/01/2007
   If EasyEntryPoint("EECAF200")
      ExecBlock("EECAF200",.F.,.F.,"PE_ALT_PARC")
   EndIf

   /*
   AMS - 08/02/2005 às 17:44. Geração de parcela(s) de cambio para filial da Off-Shore
                              com o evento 133 - Pagamento de Invoice.
   */
   If lIntermed .And. If(EECFlags("CAFE"),If(EEC->EEC_TIPO == "W" .And. M->EXL_TIPOWO $(ST_WI+ST_WO),.F.,.T.),.T.)//RMD - 21/02/06 - Não vale para Wash-Out de Contrato

      If lFilOffShore

         nEECRecno := EEC->(Recno())

         If lMultiOffShore
            cKey := If(!Empty(EEC->EEC_NIOFFS),cFilEx+EEC->EEC_PEDREF,;
                                               cFilBr+EEC->EEC_PREEMB)
         Else
            cKey := cFilBr+EEC->EEC_PREEMB
         EndIf

         If EEC->(dbSeek(cKey))
            //ISS - 05/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA para atender o ponto de entrada "AF200GPARC_ALTDTEMBA"
            aParcOffShore := AF200GPCD( AF200TotParc(cFilBr)[1],;
                                        EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)),;
                                        dDTEMBA,;
                                        "133",;
                                        EEC->EEC_FORN,;
                                        EEC->EEC_FOLOJA,;
                                        "" )
         EndIf

         EEC->(dbGoTo(nEECRecno))

         Eval({|x, y| aSize(x, Len(x)+Len(y)),;
                      aCopy(y, x,,, Len(x)-Len(y)+1 )}, aParc, aParcOffShore)

      EndIf

   EndIf

   If !lFilOffShore

      /*
      AMS - 29/09/2004 às 14:00. Despesas Internacionais (Geração de Parcelas).
                                 A função X3DIReturn, com base no SX3 retorna as despesas(padrão/customizadas).
      */
      For z := 1 To Len(aDespesas)
       //If !Empty(EXL->&("EXL_VD"+aDespesas[z][1])) //Verifica se existe valor para Despesa.
         If !Empty(EXL->&("EXL_VD"+aDespesas[z][1])) .and. EasyGParam("MV"+SubStr(aDespesas[z][2], 4), .T.) //Verifica se existe valor e o parametro para Despesa.
            cCondPag := EXL->&("EXL_CP"+aDespesas[z][1])+Str(EXL->&("EXL_DP"+aDespesas[z][1]), 3)
               //ISS - 05/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA para atender o ponto de entrada "AF200GPARC_ALTDTEMBA"
               aParcDI  := AF200GPCD( EXL->&("EXL_VD"+aDespesas[z][1]),;  //EEC->&(aDespesas[z][2]) //Valor.
                                      If(Empty(EXL->&("EXL_CP"+aDespesas[z][1])), EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)), cCondPag),; //Cond.Pagto.
                                      EXL->(Eval({|x| If(Empty(x), dDTEMBA, x)}, &("EXL_DT"+aDespesas[z][1]))),; //Data Base.
                                      EasyGParam("MV"+SubStr(aDespesas[z][2], 4)),; //Evento.
                                      EXL->&("EXL_FO"+aDespesas[z][1]),; //Fornecedor
                                      EXL->&("EXL_LF"+aDespesas[z][1]),; //Loja
                                      EXL->&("EXL_EM"+aDespesas[z][1]),; //Empresa
                                      ,;                                 //Invoice
                                      EXL->&("EXL_NAT"+aDespesas[z][1])) //Natureza

           cCondPagCb := If(Empty(M->&("EXL_CP"+aDespesas[z][1])), M->(EEC_CONDPA+Str(EEC_DIASPA, 3)), cCondPag) //MCF - 20/01/2017
           SY6->(DbSetOrder(1))
           SY6->(dbSeek(xFilial()+cCondPagCb))

           If SY6->Y6_MDPGEXP <> "006"
            Eval({|x, y| aSize(x, Len(x)+Len(y)),;
                         aCopy(y, x,,, Len(x)-Len(y)+1 )}, aParc, aParcDI)
           EndIf

         EndIf
      Next

   EndIf
    /*
    AMS - 30/09/2004 às 15:38. Comissão por Agente(s) (Geração de Parcelas).
    */
    If EECFlags("FRESEGCOM")

        aEventos := { { "120", "EEQ_AREMET" },; //A Remeter.
                    { "121", "EEQ_CGRAFI" },; //Conta Gráfica.
                    { "122", "EEQ_ADEDUZ" } } //A Deduzir.

        EEB->(dbSetOrder(1))

        If EEB->(dbSeek(xFilial()+EEC->EEC_PREEMB+OC_EM))
        While EEB->(!Eof() .and. EEB_FILIAL == xFilial() .and. EEB_PEDIDO == EEC->EEC_PREEMB .and. EEB_OCORRE == OC_EM)

            If EEB->EEB_TOTCOM <= 0 .or. Left(EEB->EEB_TIPOAG, 1) <> CD_AGC //Ag.Rec.Com.
                EEB->(dbSkip())
                Loop
            EndIf
            // JPM - 02/08/05 - Geração de parcelas por invoice
            If EECFlags("INVOICE") .And. EXP->(DbSeek(xFilial("EXP")+EEC->EEC_PREEMB ))
                nComRest  := EEB->EEB_TOTCOM
                nComAtual := 0
                aParcCom  := {}

                While Eval(bWhileEXP)
                    EXP->(DbSkip())    // vai para o próximo registro para saber se o registro atual é o último.
                    If !Eval(bWhileEXP)// se for o último...
                     nComAtual := nComRest // a comissão para esta invoice é o restante
                    Else
                     nComAtual := Round( (EXP->EXP_TOTPED / EEC->EEC_TOTPED) * EEB->EEB_TOTCOM, AvSx3("EEQ_VL",AV_DECIMAL) )
                    EndIf
                    EXP->(DbSkip(-1))  // Volta para o registro atual
                    //ISS - 05/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA para atender o ponto de entrada "AF200GPARC_ALTDTEMBA"
                    aParcAtu := AF200GPCD( nComAtual,;                            //Valor.
                                        EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)),; //Cond.Pagto.
                                        dDTEMBA,;                      //Data Base.
                                        aEventos[Val(EEB->EEB_TIPCOM)][1],;    //Evento.
                                        EEB->EEB_FORNEC,;                      //Fornecedor
                                        EEB->EEB_LOJAF,;                       //Loja
                                        EEB->EEB_CODAGE,;                      //Empresa
                                        EXP->EXP_NRINVO )                      //Número da Invoice

                    Eval({|x, y| aSize(x, Len(x)+Len(y)), aCopy(y, x,,, Len(x)-Len(y)+1 )}, aParcCom, aParcAtu)
                    nComRest -= nComAtual
                    EXP->(DbSkip())
                EndDo

            Else
                //ISS - 05/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA para atender o ponto de entrada "AF200GPARC_ALTDTEMBA"
                aParcCom := AF200GPCD( EEB->EEB_TOTCOM,;                      //Valor.
                                        EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)),; //Cond.Pagto.
                                        dDTEMBA,;                      //Data Base.
                                        aEventos[Val(EEB->EEB_TIPCOM)][1],;    //Evento.
                                        EEB->EEB_FORNEC,;                      //Fornecedor
                                        EEB->EEB_LOJAF,;                       //Loja
                                        EEB->EEB_CODAGE )                      //Empresa
            EndIf

            Eval({|x, y| aSize(x, Len(x)+Len(y)), aCopy(y, x,,, Len(x)-Len(y)+1 )}, aParc, aParcCom)
            EEB->(dbSkip())
        End
        EndIf
    EndIf

   lMUDA := lAltDtEmb

   /*
   AMS - 02/11/2004 às 20:31. Ordenação do aParc para gravar as parcelas ordenadas pelo
                              evento da parcela + data de vencimento.
   */
   //MFR OSSME-3630 14/08/2019
   EasyAsort(aParc,,, {|x, y| x[3]+dtos(x[2]) < y[3]+dtos(y[2]) })

   //RMD - 22/02/17 - Possibilitar a alteração das parcelas que serão criadas no EEQ com base no array aParc
   If EasyEntryPoint("EECAF200")
      Execblock("EECAF200",.F.,.F.,"AF200GPARC_DEF_PARC")
   EndIf

   EEQ->(DbSetOrder(1))
   IF EEQ->(DBSEEK(cFil+EEC->EEC_PREEMB)) //XFILIAL("EEQ")

      //ER - 05/11/2007 - Posiciona em Parcela que não é do tipo adiantamento.
      While EEQ->(!EOF() .and. EEQ->(EEQ_FILIAL + EEQ_PREEMB) == cFil+EEC->EEC_PREEMB)

         //Verifica se é o mesmo evento
         If EEQ->EEQ_TIPO == "A" .Or. EEQ->EEQ_FASE <> "E" .Or. !AVFLAGS("EEC_LOGIX") .AND. If (!Empty(aParc),AllTrim(EEQ->EEQ_EVENT) <> AllTrim(aParc[1][3]),.F.) // LRS 27/08/2013 - 14:28 - chamado 101920
            EEQ->(DbSkip())
            Loop
         Else                             //NCF - 14/03/2014 - Nao integra câmbio/título quando há data de embarque e a mesma não foi alterada
            If AVFLAGS("EEC_LOGIX") .And. !Empty(cEvDtEmba)// .AND. Type("lSegGrava") == "L" .AND. lSegGrava .AND. !Empty(M->EEC_DTEMBA) .AND. !lDtEmba
               If Val(EEQ->EEQ_PARC) <= Len(aParc) .AND. AllTrim(EEQ->EEQ_EVENT) == AllTrim(aParc[Val(EEQ->EEQ_PARC)][3]) .AND. EEQ->EEQ_PARC == EEQ->EEQ_PARVIN
                  If EEQ->EEQ_VCT <> aParc[Val(EEQ->EEQ_PARC)][2] .OR. EEQ->EEQ_VL <> aParc[Val(EEQ->EEQ_PARC)][1]
                     EEQ->(RecLock("EEQ", .F.))
                     EEQ->EEQ_VCT := aParc[Val(EEQ->EEQ_PARC)][2]
                     EEQ->EEQ_VL  := aParc[Val(EEQ->EEQ_PARC)][1]
                     EEQ->(MsUnLock())

                     If IsReceita(EEQ->EEQ_EVENT)
                        AvStAction("006")
                     ElseIf EEQ->EEQ_EVENT $ cDespIntFin .Or. (!AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT )
                        AvStAction("011")
                     EndIf
                  EndIf

                  aParc[Val(EEQ->EEQ_PARC)] := NIL //Não gerar cambio pois ja existe parcela
               Else
                  If EEQ->EEQ_PARC == EEQ->EEQ_PARVIN .And. Empty(EEQ->EEQ_ORIGEM)           //NCF - 08/04/2014 - Verifica se a parcela original (não desmembrada)
                     //Se a parcela não existe mais ou o evento é diferente, excluir parcela.
                     If IsReceita(EEQ->EEQ_EVENT)
                        AvStAction("007")
                     ElseIf EEQ->EEQ_EVENT $ cDespIntFin .Or. (!AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT )
                        AvStAction("012")
                     EndIf
                  EndIf

                  EEQ->(RecLock("EEQ",.F.))
                  EEQ->(dbDelete())
                  EEQ->(MsUnLock())
               EndIf
            ElseIf AVFLAGS("EEC_LOGIX")
			      aParc := {}
               Exit
            EndIf
         EndIf

         EEQ->(dbSkip())
      EndDo

      If AVFLAGS("EEC_LOGIX")// .AND. Type("lSegGrava") == "L" .AND. lSegGrava .AND. !Empty(M->EEC_DTEMBA) .AND. !lDtEmba
         z := 1
         Do While z <= Len(aParc)
            If aParc[z] == NIL
               aDel(aParc,z)
               aSize(aParc,Len(aParc)-1)
               z--
            EndIf
            z++
         EndDo
      Else

         // VERIFICA SE HOUVE MUDANCA DA CONDICAO DE PAGAMENTO
         nParcAux:= 0
         FOR Z := 1 TO LEN(aPARC)
            //EEQ->(DbSeek(xFilial()+aParc[z][8]+STRZERO(Z,2,0)))  // RMD - 16/01/2015
            //MFR 23/04/2019 OSSME-2859
            nParcAux++
            lAchouParcela:= EEQ->(DbSeek(xFilial()+EEC->EEC_PREEMB+STRZERO(nParcAux,aPropCampo[1],0)))
            If lAchouParcela
               While lAchouParcela .And. (!(EEQ->EEQ_EVENT $ cEventosOK) .Or. EEQ->EEQ_TIPO == "A" .Or. EEQ->EEQ_FASE != "E")
                  nParcAux++
                  lAchouParcela:= EEQ->(DbSeek(xFilial()+EEC->EEC_PREEMB+STRZERO(nParcAux,aPropCampo[1],0)))
               EndDo
            EndIf
            if lAchouParcela
               IF EEQ->(!Eof()) .And. (EEQ->(EEQ_FILIAL+EEQ_PREEMB) # EEC->(cFil+EEC_PREEMB) .OR.; //XFILIAL("EEQ")
                  EEQ->EEQ_PARC  # STRZERO(nParcAux,aPropCampo[1],0) .OR.;  //MFR 23/04/2019 OSSME-2859
                  EEQ->EEQ_VCT   # aPARC[Z,2]     .OR.;
                  EEQ->EEQ_VL    # aPARC[Z,1]     .OR.;
                  EEQ->EEQ_TIPO  == "A" .OR.;
                  (lOkEVENT .and. EEQ->EEQ_EVENT # Eval({|x| If(Len(x) > 2, x[3], EV_PRINC2)}, aParc[z])) )
						
                  If !lDtEmba .Or. lAltDtEmb
                     If lOkEvent .And. AllTrim(EEQ->EEQ_EVENT) <> "129"
                        If !(lRet := AF200DPARC(cFil,cEventosOk))
                           Break
                        EndIf
                        lMUDA := .T.
                        EXIT
                     EndIf
                  ElseIf lAltValPosEmb
                     If EEQ->EEQ_VCT # aPARC[z, 2]
                        EEQ->(RecLock("EEQ", .F.))
                        EEQ->EEQ_VCT := aPARC[z, 2]
                       	aAdd(aRecNoEEQ, EEQ->(Recno())) //LRS - Captura o Recno para troca o vencimento do contas a receber, quando troca a data de embarque
								EEQ->(MsUnLock())
                        lMUDA := .T.
                        Exit
                     EndIf
                  EndIf
               ENDIF
            else
               AAdd(aParcNew, aParc[z])
            endif
         NEXT

         If Len(aParcNew) > 0
               aPARC := aClone(aParcNew)
               aSort(aParc,,, {|x, y| x[3]+dtos(x[2]) < y[3]+dtos(y[2]) })
               lMUDA := .T.
         EndIF
      EndIf
   ENDIF
    //THTS - 22/05/2019 - Alteração de valor Pós-Embarque
   If !lMUDA .And. lDtEmba .And. lAltValPosEmb
        If (nPos101 := AScan(aParcAlter, {|x| x[2] == EV_PRINC2})) > 0
            If aParcAlter[nPos101][1] <> 0
                lMUDA := .T. //Houve alteração por embarque
            EndIf
        EndIf
   EndIf

   IF lMUDA

	  //LRS- Troca a data vencimento no contas a receber quando troca a data de embarque
      If lDtEmba .And. lAltValPosEmb .AND. /*!AVFLAGS("EEC_LOGIX") .And.*/ !lAltDtEmb
         For z:= 1 to len (aRecNoEEQ)
         	EEQ->(DbGoTo(aRecNoEEQ[z]))  // RMD - 22/12/14 - Informado o Recno correto.
				If EasyGParam("MV_EEC0042",,.F.) .And. IsIntEnable('001') .And. !AvFlags("EEC_LOGIX")
					If (lRet := AF200ESTCR(EEC->EEC_PREEMB,.T.))
						EEQ->(DbGoTo(aRecNoEEQ[z]))
					Else
						lRet := .F.
						Break
					EndIf
				Else
					//RMD - 03/02/15 - Não altera caso esteja baixado
						If (!EasyVerModal("EEQ") .And. Empty(EEQ->EEQ_PGT)) .Or. (EasyVerModal("EEQ") .And. Empty(EEQ->EEQ_DTCE))
							If !AvStAction("006")
								lRet:= .F.
							EndIf
						EndIf
					EndIf
         NEXT
         lRet := Af200AcParc(cFil)
         Break
      EndIf

      nSeqParc := 0

      If AVFLAGS("CAMBIO_EXP_MOV_EXT")
         aParcAux := aClone(aParc)
         aParcAux := AF200RatCG(aParcAux) //NCF - 30/10/2015 - Guarda os percentuais de comissão em conta gráfica nas parcelas
      EndIf                               //                   de saldo a receber quando há adiantamento com Mov. Exterior

      //RMD - 22/02/17 - Possibilitar a alteração do rateio das comissões no array aParcAux caso o array aParc tenha sido customizado
      If EasyEntryPoint("EECAF200")
         Execblock("EECAF200",.F.,.F.,"AF200GPARC_DEF_COMI")
      EndIf

      // GRAVA AS PARCELAS DA CONDICAO DE PAGAMENTO
      FOR Z := 1 TO LEN(aPARC)

         // by CAF 08/01/2005 - Gerar parcelas para os eventos parametrizados.
         IF ! (aParc[z,3] $ cEventosOK)
           	Loop
         Endif

          // By JPP - 02/06/2005 14:45 - Não gerar parcelas de cambio quando o embarque for amostra, sem cobertura cambial e o evento for uma receita.
          If EEC->EEC_AMOSTR $ cSim  .Or. EEC->EEC_MPGEXP == "006" .Or. EEC->EEC_COBCAM $ cNao
             //IF aParc[z,7] = "1" // Receita
             IF aParc[z,7] <> "2" // Despesa - ER - 04/05/2007 - Alterado para não gerar parcelas quando a tabela EC6 não estiver correta.
                Loop
             Endif
          EndIf

          Do While EEQ->(dbSeek(xFilial()+EEC->EEC_PREEMB+SomaIt(StrZero((nSeqParc+z)-1, AvSx3("EEQ_PARC", AV_TAMANHO), 0))+AvKey("E","EEQ_FASE")))  //LRS - 28/10/2016
             nSeqParc++
          EndDo

          /*
          AMS - 20/10/2004 às 14:00. Substituido a gravação da seq. da parcela para iniciar apartir
                                     da parc.de adiantamento.
         */
         EEQ->(RECLOCK("EEQ",.T.))

         For i:=1 To EEQ->(FCount())
            EEQ->(&("EEQ->"+FieldName(i)) := CriaVar(FieldName(i)))
         Next

         EEQ->EEQ_FILIAL := cFil //XFILIAL("EEQ")
         EEQ->EEQ_PREEMB := EEC->EEC_PREEMB

          If EEQ->(FieldPos("EEQ_EMISSA")) > 0 // BAK - 25/09/2012
             EEQ->EEQ_EMISSA := EEC->EEC_DTEMBA
          EndIf

          //Alcir Alves - 28-11-05 - Força o Tip de contrato igual a 1
          IF lEEQ_TP_CON  //HVR JA VERIFICA EEQ_TP_CON
             EEQ->EEQ_TP_CON:="1"
          ENDIF
          //
          //EEQ->EEQ_PARC   := SomaIt(StrZero((nSeqParc+z)-1,2, 0))
          EEQ->EEQ_PARC   := StrZero((nSeqParc+z), AvSx3("EEQ_PARC", AV_TAMANHO)) //LRS - 06/09/2016
          EEQ->EEQ_VCT    := aPARC[Z,2]
          If EEQ->(FieldPos("EEQ_HVCT")) > 0
             EEQ->EEQ_HVCT:= aPARC[Z,2] //WFS 19/03/10 - Histórico
          EndIf
          EEQ->EEQ_VL     := aPARC[Z,1]

         // ** By JBJ - 11/03/03 - Grava a Parcela de vinculação.
         If lParVin
            EEQ->EEQ_PARVIN := EEQ->EEQ_PARC
         EndIf
         If lOkEVENT
            EEQ->EEQ_NRINVO := aPARC[Z,8] //EEC->EEC_NRINVO - JPM - Geração de parcelas por invoice
            EEQ->EEQ_EVENT  := Eval({|x| If(Len(x) > 2, x[3], EV_PRINC2)}, aParc[z])
         EndIf
         IF lPagtoAnte
            EEQ->EEQ_FASE = "E"
         ENDIF

         If EECFlags("FRESEGCOM")

            For nPos := 1 To Len(aDespesas)
               If EasyGParam("MV"+SubStr(aDespesas[nPos][2], 4), .T.) .and. EasyGParam("MV"+SubStr(aDespesas[nPos][2], 4)) == AllTrim(EEQ->EEQ_EVENT)
                  Exit
               EndIf
            Next

             EEQ->EEQ_MOEDA  := If(nPos > Len(aDespesas), EEC->EEC_MOEDA, Eval({|x| If(Empty(x), EEC->EEC_MOEDA, x)}, EXL->&("EXL_MD"+aDespesas[nPos][1])))
             EEQ->EEQ_PARI   := 1
             EEQ->EEQ_FORN   := aParc[z][4]
             EEQ->EEQ_FOLOJA := aParc[z][5]
             EEQ->EEQ_CODEMP := aParc[z][6]
             EEQ->EEQ_TIPO   := If(AllTrim(EEQ->EEQ_EVENT) == "101", "R", "P")

             If AllTrim(EEQ->EEQ_EVENT) == "101"

                EEQ->EEQ_IMPORT := EEC->EEC_IMPORT
                EEQ->EEQ_IMLOJA := EEC->EEC_IMLOJA

               /* WFS 29/06/11 - Gravação dos campos: EEQ_AREMET, EEQ_CGRAFI e EEQ_ADEDUZ*/
                For nCont:= 1 To Len(aParc)
                   If (nPos := AScan(aEventos, {|x| x[1] == AllTrim(aParc[nCont][3])})) > 0 .And.;
                      aParc[nCont][2] == aParc[z][2] .And.; //mesmo vencimento
                      (!EECFlags("INVOICE") .Or. aParc[nCont][8] == aParc[z][8]) //mesma invoice
                      EEQ->&(aEventos[nPos][2]) += If(!AVFLAGS("CAMBIO_EXP_MOV_EXT"), aParc[nCont][1], aParcAux[nCont][1])  //NCF - 30/10/2015 - Como o array aParcAux é uma cópia do aParc, as posicoes
                   EndIf                                                                                                    //                   são as mesmas, só muda o valor calculado.
                Next
             EndIf

             //RMD - 08/02/06 - Manutenção de Wash-Out
             If EECFlags("CAFE") .And. EEC->EEC_TIPO = "W"
                If EXL->EXL_TIPOWO == ST_WI
                   EEQ->EEQ_EVENT := EV_WASHOUT_IN
                   EEQ->EEQ_TIPO  := "R"
                ElseIf EXL->EXL_TIPOWO == ST_WO
                   EEQ->EEQ_EVENT := EV_WASHOUT_OUT
                   EEQ->EEQ_TIPO  := "P"
                EndIf
             EndIf

             If !AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .AND. "121" $ EEQ->EEQ_EVENT
                EEQ->EEQ_MODAL := '2'
             EndIf

            //THTS - 06/04/2017 - Grava o campo de versão do adapter a ser utilizado quando integrado ao Logix.
            If ! EEQ->EEQ_TIPO $ "A|R" .And. AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0
                EEQ->EEQ_EAIVRS := "2"
            ElseIf EEQ->(FieldPos("EEQ_EAIVRS")) > 0
                EEQ->EEQ_EAIVRS := "1"
            EndIf
 
            //CCH - 01/09/2008 - Testa se a integração com o Financeiro está ligada antes de executar a rotina
               If !IsIntEnable("001") .Or. !Empty(Posicione("SYF", 1, xFilial("SYF") + EEQ->EEQ_MOEDA, "YF_MOEFAT"))
                  If IsReceita(EEQ->EEQ_EVENT)
                     If !Empty(EEQ->EEQ_IMPORT) .And. !Empty(EEQ->EEQ_IMLOJA)
                        If !(lRet := AvStAction("005"))//Inclusão de título a receber no SIGAFIN
                          Break
                        EndIf
                     EndIf
                  ElseIf EEQ->EEQ_EVENT $ cDespIntFin .Or. (!AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT )//Gera contas a pagar para despesas internacionais e comissão a remeter.
                     //ISS - 05/01/11 - Alterado uso do campo EEC->EEC_DTEMBA para a variavel private dDTEMBA para atender o ponto de entrada "AF200GPARC_ALTDTEMBA"
                     If !Empty(EEQ->EEQ_FORN) .And. !Empty(EEQ->EEQ_FOLOJA) .And. !Empty(dDTEMBA) .And. !Empty(EEQ->EEQ_VCT) .And. !Empty(EEQ->EEQ_VL) .And. (!IsIntEnable("001") .Or. !Empty(SYE->YE_MOE_FIN))
                        cNatureza:= aParc[Z][9]
                        If !(lRet := AvStAction("010")) //Inclusão de título a pagar no SIGAFIN
                           Break
                        EndIf
                     EndIf
                  EndIf
               ELSE
                  EasyHelp(STR0232 + EEQ->EEQ_MOEDA) //"Não existe cotação para a moeda do processo - "
                  lRet := .F.
                  Break
               ENDIF
               //NCF - 19/02/2014 - Gravar a data de embarque como data de liquidação da comissão a deduzir, taxa e valor convertido.
               If AvFlags("EEC_LOGIX")
                  If Alltrim(EEQ->EEQ_EVENT) == '122'
                     EEQ->EEQ_PGT  := M->EEC_DTEMBA
                     EEQ->EEQ_TX   := BuscaTaxa(EEC->EEC_MOEDA, dDTEMBA,,.F.,,,If(EC6->EC6_TXCV=='2','2','1'))
                     EEQ->EEQ_EQVL := Round(EEQ->EEQ_VL*BuscaTaxa(EEC->EEC_MOEDA, dDTEMBA,,.F.,,,If(EC6->EC6_TXCV=='2','2','1')),AvSX3("EEQ_EQVL",AV_DECIMAL))
                  EndIf
               EndIf

            //Final da Gravação.
            EEQ->(MsUnLock())
         EndIf

      NEXT

      aParcAux := {}

      If ( AvFlags("EEC_LOGIX") .And. !IsIntEnable("001") ) .Or. (!AvFlags("EEC_LOGIX") .And. IsIntEnable("001") .And. EasyGParam("MV_EEC0042",,.F.) )

         aCompTit :={}

         EEQ->(dbSetOrder(1))
         EEQ->(DBSEEK(cFil+EEC->EEC_PREEMB))
         Do While EEQ->(!EOF() .and. EEQ->(EEQ_FILIAL + EEQ_PREEMB) == cFil+EEC->EEC_PREEMB)
      	    If EEQ->EEQ_TIPO == "A" .AND. EEQ->EEQ_FASE == "E" .AND. Empty(EEQ->EEQ_FINNUM)

      	 	   If !(lRet := AvStAction("005"))
      	 	      Break
      	 	   EndIf

      	 	      aAdd (aCompTit,{EEQ->(RECNO()),SE1->(RECNO()),0})

      	    EndIf
      	    EEQ->(dbSkip())
      	    Loop
	     EndDo
      EndIf

      If IsIntEnable("001")
      	 If EasyGParam("MV_EEC0042",,.F.) .And. !AvFlags("EEC_LOGIX")
      	 	If !(lRet := AF200COMPCR(aCompTit))
      	 	   Break
      	 	EndIf
      	 Else
            If lAltDtEmb //Houve alteração da data de embarque, devera ser feito o estorno do RA e a baixa novamente
               If Type("lEmbEstAdi") == "L" .And. lEmbEstAdi .And. !(lRet := EECRABaixa(.T.))
                  Break
               EndIf
               If !(lRet := EECRABaixa(.F.))
                  Break
               EndIf
            EndIf
      	 EndIf
      EndIf

      // ** By JBJ - 21/05/03 - 13:38.
      If EasyEntryPoint("EECAF200")
         ExecBlock("EECAF200",.f.,.f.,"PE_GERPARC")
      Endif

   ENDIF
ELSE
   If !(lRet := AF200DPARC(cFil,cEventosOk))
      Break
   EndIf
   If EasyGParam("MV_EEC0042",,.F.) .And. !AvFlags("EEC_LOGIX")
      If !(lRet := AF200ESTCR(EEC->EEC_PREEMB))
         Break
      EndIf
   ElseIf IsIntEnable("001") .And. Type("lEmbEstAdi") == "L" .And. lEmbEstAdi .And. !(lRet := EECRABaixa(.T.))
      Break
   EndIf
ENDIF

End Sequence

RestOrd(aOrd, .T.)

RETURN lRet

/*
Funcao      : AF200AcParc()
Parametros  : Nenhum.
Retorno     : Nil.
Objetivos   : Efetua acerto nas parcelas de câmbio quando houve alteração de valores após o embarque e
              gera parcelas para os valores de despesas internacionais que tenham sido incluidos.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 06/03/05 - 11:21
Obs.        :
*/
*------------------------------*
Static Function AF200AcParc(cFil)
*------------------------------*
Local lRet := .T.
Local i,j,z, aEEQ, aComSemVinc
Local cCampoCom, nVlRestante, nVlAbatido, aDel := {}
Local aEEQ101 := {}
Local cEventos := ""  //eventos que não foram gerados, por terem sido incluidos após o embarque
Local lEventos := .f. //define se houveram eventos que não foram gerados
Local aDespesas, aParc, aParcDI, nPos
Local lDelTitulo := .F. //LGS-17/07/2015
Local lAltEasyLi := .F.
Local lCriaNewCo := .F.
Local nTotalParcs
Local nTotalComis
Local nTotalDesc
Local nDescCGraf:= 0
Private cNatureza:= ""
Begin Sequence
   
   lPagtoAnte:= EasyGParam("MV_AVG0039",,.F.)

   EEQ->(DbSetOrder(5))
   //-AAdd(aParcAlter,M->EEC_TOTPED - nTotPed,"101")
   For i := 1 to Len(aParcAlter)
      aComSemVinc := {0,0,0}
      If aParcAlter[i][1] <> 0 //se houve alteração no valor...
         //adiciona no array do EEQ as parcelas do evento atual (aParcAlter[i][2])
         aEEQ := {}
         EEQ->(DbSeek(xFilial()+AvKey(EEC->EEC_NRINVO,"EEQ_NRINVO")+AvKey(aParcAlter[i][2],"EEQ_EVENT")))
         While EEQ->(!Eof()) .And.;
               EEQ->(xFilial())+AvKey(EEC->EEC_NRINVO,"EEQ_NRINVO")+AvKey(aParcAlter[i][2],"EEQ_EVENT") ==;
               EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT)

            // ** GFC - 01/12/05 - Nos loops do EEQ verificar se o processo do eeq é o mesmo do eec
            If EEQ->EEQ_PREEMB <> EEC->EEC_PREEMB  .Or. ( EEQ->EEQ_EVENT == EV_PRINC2 .And. !Empty(EEQ->EEQ_DTCE) ) // NCF - 16/05/2019 - Desconsidera câmbio a receber já recebido no exterior.
               EEQ->(dbSkip())
               Loop
            EndIf
            // **

            If EEQ->(Empty(EEQ_DTCE) .And. Empty(EEQ_PGT) .And. Empty(EEQ_NROP) .And. AF200VLFCAM("EEQ") > 0 .And.;
               (aParcAlter[i][2] <> EV_PRINC2 .Or. (Empty(EEQ_FI_TOT) .Or.;
               (aParcAlter[i][1] > 0 .Or. (!Empty(EEQ_FI_TOT) .And. EEQ_VL_PAR > 0) ) ) ) )

               AAdd(aEEQ,{DtoS(EEQ->EEQ_VCT),EEQ->(RecNo()),If(Empty(EEQ->EEQ_FI_TOT),AF200VLFCAM("EEQ"),EEQ->EEQ_VL_PAR),EEQ->EEQ_PARC, EEQ->EEQ_DESCON, { EEQ->EEQ_AREMET , EEQ->EEQ_CGRAFI, EEQ->EEQ_ADEDUZ } })

            EndIf

            EEQ->(DbSkip())
         EndDo

         If Len(aEEQ) == 0 .And. aParcAlter[i][1] > 0 //THTS - 21/05/2019 - Valor positivo deve permitir alterar, mesmo sem parcela em aberto
            cEventos += "\" + aParcAlter[i][2]
            lEventos := .t.
            Loop
         EndIf

         If Len(aEEQ) > 0 //aParcAlter[i][1] > 0                     //se o valor foi alterado para maior
         //   aSort(aEEQ    ,,, {|x, y| x[1] < y[1] .And. x[4] < y[4] }) //o valor será acrescentado 1º nas parcelas de menor vencimento
         //Else                                        //senão
            aSort(aEEQ    ,,, {|x, y| x[1] > y[1] .Or. x[4] > y[4] }) //o valor será abatido das parcelas de maior vencimento
         EndIf

         //Valor que resta pra ser abatido/acrescido
         nVlRestante := Abs(aParcAlter[i][1])

         //ER - 05/11/2007 - Para verificar a alteração de uma parcela, o valor do
         //                  adiantamento também deve ser considerado.
         If lPagtoAnte .And. Len(aParcAlter[i]) > 2
            nVlRestante -= Abs(aParcAlter[i][3])
         EndIf


         //NCF - 16/05/2019 - Distrib. do valor alterado em eventos 101 - INICIO
         //======================================================================        
         If aParcAlter[i][2] $ (EV_PRINC2 + "/" + EV_COM_AR + "/" + EV_COM_CG + "/" + EV_COM_DF) .And. aParcAlter[i][1] <> 0
            nVariacao   := aParcAlter[i][1]
            aEEQAux     := aClone(aEEQ)
            nTotalParcs := 0
            nTotalComis := 0
            nTotalDesc  := 0
            If Len(aEEQAux) == 0
                EEQ->(AvSeekLast(xFilial()+AvKey(EEC->EEC_NRINVO,"EEQ_NRINVO")+AvKey(aParcAlter[i][2],"EEQ_EVENT")))
                AAdd(aEEQAux,{DtoS(EEQ->EEQ_VCT),;
                              EEQ->(RecNo()),;
                              If(Empty(EEQ->EEQ_FI_TOT),AF200VLFCAM("EEQ"),EEQ->EEQ_VL_PAR),;
                              EEQ->EEQ_PARC,;
                              { EEQ->EEQ_AREMET , EEQ->EEQ_CGRAFI, EEQ->EEQ_ADEDUZ } })
            Else
                aEval(aEEQAux,{|x| nTotalParcs += x[3], nTotalDesc += x[5], nTotalComis += x[6][2] })
            EndIf
            If lPagtoAnte .And. Len(aParcAlter[i]) > 2
               nVariacao -= Abs(aParcAlter[i][3])
            EndIf
            
            If nVariacao > 0 //Variou para MAIOR
               If EECFlags("ALT_EASYLINK") .Or. AvFlags("EEC_LOGIX") .Or. lAltEasyLi
                  lAltEasyLi := .T.
                  nDescCGraf := 0
                  If aParcAlter[i][2] == EV_PRINC2
                        aEval(aParcAlter,{|x| IIF(x[2] == EV_COM_CG .And. x[1] < 0, nDescCGraf := Abs(x[1]),)})
                  EndIf
                  aEEQNew := CriaParcDif( nVariacao + nDescCGraf, aEEQAux , nTotalParcs)    //Cria nova parcela com a Diferença
                  If !aEEQNew[1]
                     lRet := .F.
                     Break
                  Else
                     aEEQ := aEEQNew[2]
                  EndIf
               Else
                  If nTotalParcs > 0
                     aEEQNew := RatVlrDif( nVariacao,"EEQ_VL" , nTotalParcs, nTotalDesc, nTotalComis, aEEQAux, aParcAlter[i][2] == EV_PRINC2)  //Rateia Valor da diferença( no valor da parcela)
                     If !aEEQNew[1]
                        lRet := .F.
                        Break
                     Else
                        aEEQ := aEEQNew[2]
                     EndIf
                  Else
                     aEEQNew := CriaParcDif( nVariacao, aEEQAux , nTotalParcs ) //Cria nova parcela com a Diferença
                     If !aEEQNew[1]
                        lRet := .F.
                        Break
                     Else
                        aEEQ := aEEQNew[2]
                     EndIf
                  EndIf
               EndIf    //MFR 19/02/2020 OSSME-4269
           ElseIf  nVariacao < 0            //Variou para MENOR
               If EECFlags("ALT_EASYLINK")  .Or. AvFlags("EEC_LOGIX") .Or. lAltEasyLi
                  lAltEasyLi := .T.
                  If nTotalParcs > 0 .And. !(nTotalParcs < Abs(nVariacao))
                     aEEQNew := RatVlrDif( nVariacao,"EEQ_DESCON" , nTotalParcs, nTotalDesc, nTotalComis, aEEQAux, aParcAlter[i][2] == EV_PRINC2 )  //Rateia Valor da diferença( no campo de descontos )
                     If !aEEQNew[1]
                        lRet := .F.
                        Break
                     Else
                        aEEQ := aEEQNew[2]
                     EndIf
                  EndIf
               Else
                  If nTotalParcs > 0 .And. !(nTotalParcs < Abs(nVariacao))
                    aEEQNew := RatVlrDif( nVariacao,"EEQ_VL" , nTotalParcs, nTotalDesc, nTotalComis, aEEQAux, aParcAlter[i][2] == EV_PRINC2 )  //Rateia Valor da diferença( no valor da parcela)
                    If !aEEQNew[1]
                       lRet := .F.
                       Break
                    Else
                       aEEQ := aEEQNew[2]
                    EndIf
                  EndIf
               EndIf               
            EndIf
          EndIf
          //=====================================================================
          //NCF - 16/05/2019 - Distrib. do valor alterado em eventos 101 - FIM

         For j := 1 to Len(aEEQ)
            If nVlRestante <= 0 .Or. aParcAlter[i][2] $ (EV_PRINC2 + "/" + EV_COM_AR + "/" + EV_COM_CG + "/" + EV_COM_DF)
               Exit
            EndIf

            EEQ->(DbGoTo(aEEQ[j][2]))
            EEQ->(RecLock("EEQ",.f.))
            If aParcAlter[i][1] < 0
               nVlAbatido := If(nVlRestante > aEEQ[j][3], aEEQ[j][3], nVlRestante)
               If AvFlags("EEC_LOGIX")
                    EEQ->EEQ_DESCON += nVlAbatido
               Else
                    EEQ->EEQ_VL -= nVlAbatido
               EndIf

               If !Empty(EEQ->EEQ_FI_TOT)//verifica se está financiada
                  EEQ->EEQ_VL_PAR -= nVlAbatido
                  If EEQ->EEQ_VL_PAR = 0
                     EEQ->EEQ_FI_TOT := "S"
                  EndIf
               EndIf

               If EEQ->EEQ_VL = 0
                  If aParcAlter[i][2] == EV_PRINC2
                     aComSemVinc[1] += EEQ->EEQ_AREMET
                     aComSemVinc[2] += EEQ->EEQ_CGRAFI
                     aComSemVinc[3] += EEQ->EEQ_ADEDUZ
                  EndIf

                  If (EEQ->EEQ_EVENT $ "102/103/127/150" .Or. ( !AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT ) ) .And. !Empty(EEQ->EEQ_FINNUM) //LGS-17/07/2015
                     If !AvStAction("012") //Exclusão de título a pagar no SIGAFIN
                        lRet := .F.
                        Break
                     EndIf
                     lDelTitulo := .T.
                  EndIf

                  AAdd(aDel,EEQ->(RecNo()))
                  EEQ->(DbDelete())
               EndIf

               nVlRestante -= nVlAbatido
            Else
               If AvFlags("EEC_LOGIX")
                    lCriaNewCo := .T.
               Else
                    EEQ->EEQ_VL += nVlRestante
               EndIf

               If !Empty(EEQ->EEQ_FI_TOT)
                  EEQ->EEQ_VL_PAR += nVlRestante
                  EEQ->EEQ_FI_TOT := "N"
               EndIf

               If !lCriaNewCo
                    nVlRestante := 0
               EndIf

            EndIf

            EEQ->EEQ_NR_CON := Replicate("X",AvSx3("EEQ_NR_CON",AV_TAMANHO))

            EEQ->(MsUnlock())
            If lCriaNewCo
                CriaParcDif( nVlRestante, aEEQ )
                nVlRestante := 0
            EndIf
            If /*IsIntEnable("001") .And.*/ (EEQ->EEQ_EVENT $ "102/103/127/150" .Or. ( !AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT ) ) .And. !lDelTitulo //LGS-17/07/2015 //DFS - 28/12/2010 - Testa se a integração com o Financeiro está ligada antes de executar a rotina

               If !AvFlags("EEC_LOGIX") .And. !Empty(EEQ->EEQ_FINNUM)
                  If !AvStAction("011")//Alteração de título a pagar no SIGAFIN
                      lRet := .F.
                      Break
                  EndIf
               Else
                  If lCriaNewCo .And. !AvStAction("010")//Inclusão de título a pagar no SIGAFIN
                      lRet := .F.
                      Break
                  EndIf
               Endif
            Endif
            lCriaNewCo := .F.
         Next

         If aComSemVinc[1] > 0 .Or. aComSemVinc[2] > 0 .Or. aComSemVinc[3] > 0
            For j := 1 to Len(aEEQ)
               If AScan(aDel,aEEQ[j][2]) <> 0
                  Loop
               EndIf
               EEQ->(DbGoTo(aEEQ[j][2]))
               EEQ->(RecLock("EEQ",.f.))
               EEQ->EEQ_AREMET += aComSemVinc[1]
               EEQ->EEQ_CGRAFI += aComSemVinc[2]
               EEQ->EEQ_ADEDUZ += aComSemVinc[3]

               EEQ->(MsUnlock())
               Exit
            Next
         EndIf
/*
         If aParcAlter[i][2] $ (EV_COM_AR + "/" + EV_COM_CG + "/" + EV_COM_DF)

            aEEQ101 := {}
            EEQ->(DbSeek(xFilial()+AvKey(EEC->EEC_NRINVO,"EEQ_NRINVO")+AvKey(EV_PRINC2,"EEQ_EVENT")))
            While EEQ->(!Eof()) .And.;
                  (xFilial()+AvKey(EEC->EEC_NRINVO,"EEQ_NRINVO")+AvKey(EV_PRINC2,"EEQ_EVENT")) ==;
                  EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT)

               // ** GFC - 01/12/05 - Nos loops do EEQ verificar se o processo do eeq é o mesmo do eec
               If EEQ->EEQ_PREEMB <> EEC->EEC_PREEMB
                  EEQ->(dbSkip())
                  Loop
               EndIf
               // **

               If Empty(EEQ->EEQ_PGT)
                  AAdd(aEEQ101,{DtoS(EEQ->EEQ_VCT),EEQ->(RecNo()),If(aParcAlter[i][2] = EV_COM_AR,EEQ->EEQ_AREMET,;
                                                                  If(aParcAlter[i][2] = EV_COM_CG,EEQ->EEQ_CGRAFI,;
                                                                     EEQ->EEQ_ADEDUZ)),EEQ->EEQ_PARC })
               EndIf

               EEQ->(DbSkip())
            EndDo

            If Len(aEEQ101) > 0 //aParcAlter[i][1] > 0
               //aSort(aEEQ101 ,,, {|x, y| x[1] < y[1] })
            //Else
               aSort(aEEQ101 ,,, {|x, y| x[1] > y[1] .Or. x[4] > y[4] })
            EndIf

         EndIf

         If Len(aEEQ101) > 0
            nVlRestante := Abs(aParcAlter[i][1])
            If aParcAlter[i][2] = EV_COM_AR
               cCampoCom := "EEQ->EEQ_AREMET"
            ElseIf aParcAlter[i][2] = EV_COM_CG
               cCampoCom := "EEQ->EEQ_CGRAFI"
            Else
               cCampoCom := "EEQ->EEQ_ADEDUZ"
            EndIf
         EndIf

         For j := 1 to Len(aEEQ101)
            If nVlRestante <= 0
               Exit
            EndIf

            EEQ->(DbGoTo(aEEQ101[j][2]))

            EEQ->(RecLock("EEQ",.f.))

            If aParcAlter[i][1] < 0
               nVlAbatido := If(nVlRestante > aEEQ101[j][3], aEEQ101[j][3], nVlRestante)
               &(cCampoCom) -= nVlAbatido

               nVlRestante  -= nVlAbatido
            Else

               &(cCampoCom) += nVlRestante

               nVlRestante  := 0

            EndIf

            EEQ->EEQ_NR_CON := Replicate("X",AvSx3("EEQ_NR_CON",AV_TAMANHO))
            EEQ->(MsUnlock())
         Next
*/
      EndIf

   Next

   If lEventos
      aDespesas := X3DIReturn()
      aParc := {}
      For i := 1 to Len(aDespesas)
         If EasyGParam("MV"+SubStr(aDespesas[i][2], 4)) $ cEventos //se foi um evento não gerado

            If !Empty(EXL->&("EXL_VD"+aDespesas[i][1])) //Verifica se existe valor para Despesa.
               cCondPag := EXL->&("EXL_CP"+aDespesas[i][1])+Str(EXL->&("EXL_DP"+aDespesas[i][1]), 3)

               aParcDI    := AF200GPCD( EXL->&("EXL_VD"+aDespesas[i][1]),;  //Valor.
                                      If(Empty(EXL->&("EXL_CP"+aDespesas[i][1])), EEC->(EEC_CONDPA+Str(EEC_DIASPA, 3)), cCondPag),; //Cond.Pagto.
                                      EXL->(Eval({|x| If(Empty(x), EEC->EEC_DTEMBA, x)}, &("EXL_DT"+aDespesas[i][1]))),; //Data Base.
                                      EasyGParam("MV"+SubStr(aDespesas[i][2], 4)),; //Evento.
                                      EXL->&("EXL_FO"+aDespesas[i][1]),; //Fornecedor
                                      EXL->&("EXL_LF"+aDespesas[i][1]),; //Loja
                                      EXL->&("EXL_EM"+aDespesas[i][1]),; //Empresa
                                      ,;                                 //Invoice
                                      EXL->&("EXL_NAT"+aDespesas[i][1])) //Natureza //RRC - 13/08/2013 - Alterada variável z para i para buscar conteúdo do array aDespesas

               cCondPagCb := If(Empty(M->&("EXL_CP"+aDespesas[i][1])), M->(EEC_CONDPA+Str(EEC_DIASPA, 3)), cCondPag) //MCF - 20/01/2017
               SY6->(DbSetOrder(1))
               SY6->(dbSeek(xFilial()+cCondPagCb))

               If SY6->Y6_MDPGEXP <> "006"
               Eval({|x, y| aSize(x, Len(x)+Len(y)),;
                            aCopy(y, x,,, Len(x)-Len(y)+1 )}, aParc, aParcDI)
            EndIf
         EndIf

         EndIf
      Next

      EEQ->(DbSetOrder(1))
      EEQ->(AvSeekLast(xFilial("EEQ")+EEC->EEC_PREEMB))
      nSeqParc := Val(EEQ->EEQ_PARC)

      FOR z := 1 to Len(aParc)
         // By JPP - 02/06/2005 14:45 - Não gerar parcelas de cambio quando o embarque for amostra, sem cobertura cambial e o evento for uma receita.
         If EEC->EEC_AMOSTR $ cSim  .Or. EEC->EEC_MPGEXP == "006" .Or. EEC->EEC_COBCAM $ cNao
            //IF aParc[z,7] = "1" // Receita
            IF aParc[z,7] <> "2" // Despesa - ER - 04/05/2007 - Alterado para não gerar parcelas quando a tabela EC6 não estiver correta.
               Loop
            Endif
         EndIf

         EEQ->(RecLock("EEQ",.T.))

         For i:=1 To EEQ->(FCount())
            EEQ->(&("EEQ->"+FieldName(i)) := CriaVar(FieldName(i)))
         Next

         EEQ->EEQ_FILIAL := cFil //XFILIAL("EEQ")
         EEQ->EEQ_PREEMB := EEC->EEC_PREEMB

//       EEQ->EEQ_PARC   := StrZero(nSeqParc+z,2, 0)
         EEQ->EEQ_PARC   := StrZero(nSeqParc+z,AvSx3("EEQ_PARC", AV_TAMANHO)/*, 0*/) //LRS - 06/09/2016
         EEQ->EEQ_VCT    := aParc[Z,2]
         EEQ->EEQ_VL     := aParc[Z,1]

         If lParVin
            EEQ->EEQ_PARVIN := EEQ->EEQ_PARC
         EndIf

         If lOkEVENT
            EEQ->EEQ_NRINVO := EEC->EEC_NRINVO
            EEQ->EEQ_EVENT  := aParc[z][3]
            If !AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .AND. "121" $ EEQ->EEQ_EVENT
               EEQ->EEQ_MODAL := '2'
            EndIf
         EndIf

         IF lPagtoAnte
            EEQ->EEQ_FASE = "E"
         EndIf

         If EECFlags("FRESEGCOM")

            For nPos := 1 To Len(aDespesas)
               If EasyGParam("MV"+SubStr(aDespesas[nPos][2], 4)) == AllTrim(EEQ->EEQ_EVENT)
                  Exit
               EndIf
            Next

            EEQ->EEQ_MOEDA  := If(nPos > Len(aDespesas), EEC->EEC_MOEDA, Eval({|x| If(Empty(x), EEC->EEC_MOEDA, x)}, EXL->&("EXL_MD"+aDespesas[nPos][1])))
            EEQ->EEQ_PARI   := 1
            EEQ->EEQ_FORN   := aParc[z][4]
            EEQ->EEQ_FOLOJA := aParc[z][5]
            EEQ->EEQ_CODEMP := aParc[z][6]
            EEQ->EEQ_TIPO   := "P"
            EEQ->EEQ_EMISSA := dDataBase //LGS-08/07/2015 - Foi utilizado a data base para a emissao por que a data da despesa pode ser diferente e ser utilizada
                                         // a data da negociação e ser diferente para calcular o vencimento da parcela.
         EndIf
         EEQ->(MsUnlock())
         //DFS - Inclusão de chamada de evento para inclusão de titulos
         If /*IsIntEnable("001") .And.*/ EEQ->EEQ_EVENT $ "102/103/127/150" .Or. ( !AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT ) //DFS - 28/12/2010 - Testa se a integração com o Financeiro está ligada antes de executar a rotina
            cNatureza:= aParc[Z][9]
            If !AvStAction("010")//Inclusão de título a pagar no SIGAFIN
               lRet := .F.
               Break
            EndIf
         EndIf

      NEXT

   EndIf

End Sequence

Return lRet

*-----------------------------------------*
Static Function AF200DPARC(cFil,cEventosOk)
*-----------------------------------------*
Local lRet := .T.
//Define as despesas que geram contas a pagar
Private cDespIntFin := "120/102/103/127/150/129" //THTS - 16/05/2017 - adicionado o evento 129 na lista de dispesas"

Default cFil := xFilial("EEQ")
Default cEventosOk := ""

Begin Sequence

EEQ->(DBSETORDER(1))

If Type("lPagtoAnte") = "U"
   lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)
EndIf

// ** By JBJ - 03/02/2003.
If Type("lOkEvent") = "U"
   lOkEvent := EEQ->(FieldPos("EEQ_EVENT")) > 0
EndIf

// ** By JBJ - 16/12/2002 - 14:00 - Tratamento para exclusão de cotações de cambio.
If Type("lCotaCambio") = "U"
   lCotaCambio := .f.
   If Select("EXG") > 0
      lCotaCambio := EXG->(FieldPos("EXG_PREEMB")) > 0
   EndIf
EndIf

If lCotaCambio
   EXG->(DbSetOrder(1))
EndIf

EEQ->(DBSEEK(cFil+EEC->EEC_PREEMB)) //XFILIAL("EEQ")

While EEQ->(!Eof() .and. EEQ_FILIAL == cFil .and. EEQ_PREEMB == EEC->EEC_PREEMB) //xFilial()

   If !lOkEvent .Or. EEQ->EEQ_EVENT $ cEventosOk // JPM - 06/03/06 - Só deleta os eventos gerados pelo sistema

    //private para uso no ponto de entrada, indicando se deverá pular a exclusão do registro
      lDLoopEEQ:= .F.
      If EasyEntryPoint("EECAF200")
         ExecBlock("EECAF200", .F., .F., "AF200DPARC_PARCELA_CAMBIO")
      EndIf

      If lDLoopEEQ
         EEQ->(DBSkip())
         Loop
      EndIf

      //If (EEQ->EEQ_FASE = "E" .And. EEQ->EEQ_TIPO $ "RP ")
      If ((lPagtoAnte .and. EEQ->EEQ_FASE = "E") .or. !lPagtoAnte) .And. EEQ->EEQ_TIPO $ "RP "
         // ** By JBJ - 13/01/03 - Deleta as cotações de câmbio para as parcelas.
         If lCotaCambio
            If EXG->(DbSeek(cFil+EEQ->EEQ_PREEMB+EEQ->EEQ_PARC)) //xFilial("EXG")
               Do While EXG->(!Eof()) .And. EXG->EXG_FILIAL == cFil .And.; //xFilial("EXG")
                                            EXG->EXG_PREEMB == EEQ->EEQ_PREEMB .And.;
                                            EXG->EXG_PARC   == EEQ->EEQ_PARC
                  EXG->(RecLock("EXG",.f.))
                  EXG->(DbDelete())
                  EXG->(MsUnLock())
                  EXG->(DbSkip())
               EndDo
            EndIf
         EndIf
         //EEQ->(RECLOCK("EEQ",.F.),DBDELETE(),MSUNLOCK())
         EEQ->(RECLOCK("EEQ",.F.))
         If IsReceita(EEQ->EEQ_EVENT) .And. !Empty(EEQ->EEQ_FINNUM) .And. (!EECFlags("TIT_PARCELAS") .And. !EECFlags("ALT_EASYLINK") .Or. (EEQ->EEQ_PARVIN == EEQ->EEQ_PARC))
            If !(lRet := AvStAction("007"))//Exclusão de título a receber no SIGAFIN
               Break
            EndIf
         //ElseIf EEQ->EEQ_EVENT $ "121/122" .And. !Empty(EEQ->EEQ_FINNUM)
         ElseIf (EEQ->EEQ_EVENT $ cDespIntFin .Or. (!AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT ) ).And. !Empty(EEQ->EEQ_FINNUM) //Estorna o contas a pagar de despesas internacionais e comissão a remeter.
            If !(lRet := AvStAction("012"))//Exclusão de título a pagar no SIGAFIN
               Break
            EndIf
         EndIF
         If !EEQ->(IsLocked())
            EEQ->(RecLock("EEQ", .F.))
         EndIf
         EEQ->(DBDELETE())
         EEQ->(MSUNLOCK())
      //NCF - 21/03/2013 - Exclusão de título a receber no LOGIX referente ao(s) adiantamento(s)
      ElseIf (lPagtoAnte .and. EEQ->EEQ_FASE = "E") .And. EEQ->EEQ_TIPO == "A" .And. AvFlags("EEC_LOGIX")

         If !(lRet := AvStAction("007"))
            Break
         EndIf

      ENDIF

   EndIf

   EEQ->(DBSKIP())

End

End Sequence

RETURN lRet
*----------------------------------------------------------------------------
/*
Funcao      : AF200STATUS()
Parametros  :
Retorno     :
Objetivos   : Mudanca de Status na Manutencao de Cambio.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/07/2001 - 15:40
Revisao     : Cristiano A. Ferreira - 10/04/2004
Obs.        : Status do EEC:
                  Embarcado           - EEQ_DTSOL e EEQ_PGT de todas as parcelas vazio.
                  Cambio a Contratar  - EEQ_DTSOL de alguma parcela preenchido e EEQ_PGT de todas as parcelas vazio
                  Cambio Parcial      - EEQ_PGT de alguma parcela preenchido e EEQ_PGT de alguma vazio.
                  Cambio Contratado   - EEQ_PGT de todas as parcelas preenchido.
*/
*--------------------------------------------------------------------
/*ISS - 19/01/11 - Alteração dos parâmetros iniciais para que os mesmos sejam "transformados" em private para
                   o uso do ponto de entrada EECAF200, parâmetro AF200STATUS_ALTSTATUS */
//Function AF200STATUS(cP_ALIAS,lP_FFC,lRecEEC)
Function AF200STATUS(cLP_ALIAS,lLP_FFC,lLRecEEC)
Local cStatus,nRecno//,nParc := 0

// by CAF 10/04/2004 - Cambio Parcial
Local lTemParcLiq := .f.    // tem parcela liquidada?
// by JPM 04/10/2004
Local lTemParcNaoLiq := .f. // tem parcela não liquidada?
Local lTemSolSemLiq := .f.  // tem parcela com solicitação mas sem liquidação?
Local lEvent101Liq :=.f.
Local lNaoValidAdiant := .F., lValid_A := .F., lValid_R := .F. // By JPP - 09/03/2007 - 14:00 - Flag para checar se a validação está sendo feita apenas sobre o adiantamento.
Local lTCamMovEx := .F.   //NCF - 25/11/2015 - Tem Câmbio Principal a receber com Movimento no Exterior
PRIVATE cALIAS
Private lSair := .F.
Private lRet := .T.
Private cP_ALIAS := cLP_ALIAS
Private lP_FFC   := lLP_FFC
Private lRecEEC  := lLRecEEC
lP_FFC := IF(lP_FFC=NIL,.F.,lP_FFC)

Default lRecEEC := .f.
Begin Sequence

   //ISS - 05/01/11 - Ponto de entrada para alterar o status do câmbio.
   If EasyEntryPoint("EECAF200")
      ExecBlock("EECAF200", .F., .F., "AF200STATUS_ALTSTATUS")
   EndIf

   If lSair
      Break
   EndIf

   //ER - 13/07/06 Verifica se a Data de Embarque está vazia.
   If Empty(EEC->EEC_DTEMBA)
      Break
   EndIf

   // ** By JBJ - 16/12/2002 - 14:00
   If Type("lPagtoAnte") = "U"
      lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)
   EndIf

   If Type("lOkEvent") = "U"
      lOkEvent := EEQ->(FieldPos("EEQ_EVENT")) > 0
   EndIf

   IF cP_ALIAS # NIL
      cStatus := ST_CO   //Cambio Contratado
      cALIAS  := "EEQ"
      EEQ->(DBSETORDER(1))
      EEQ->(DBSEEK(XFILIAL("EEQ")+EEC->EEC_PREEMB))
   ELSE
      cStatus := ST_CO   //Cambio Contratado
      cALIAS := "TMP"
      nRECNO := TMP->(RECNO())
      TMP->(DBGOTOP())
   ENDIF

   Do While ! (cALIAS)->(Eof()) .And. (cALIAS)->EEQ_PREEMB = EEC->EEC_PREEMB
      //nParc ++

      // ** JBJ - 12/11/02 - Considera os adiantamentos - (Pagamento Antecipado).
      If lPagtoAnte .And. (cAlias)->EEQ_TIPO == "A"
         If !lP_FFC .And. Empty(M->EEC_DTEMBA) // By JPP - 09/03/2007 - 14:00 - O pagamento antecipado deve ser considerado na determinação do status do processo, no preenchimento da data de embarque.
            (cAlias)->(DbSkip())
            Loop
         EndIf
         If !lValid_A  // By JPP - 09/03/2007 - 14:00
            lNaoValidAdiant := .T.
            lValid_A := .T.
         EndIf
      EndIf


      If lOkEvent .And. ;
         ((cAlias)->EEQ_EVENT <> "101" .And.;
         (lPagtoAnte .And. (cAlias)->EEQ_TIPO <> "A"))

         (cAlias)->(DbSkip())
         Loop
      EndIf

      If lOkEvent .And. lPagtoAnte
         lEvent101Liq := ((cAlias)->EEQ_EVENT == "101" .And. !Empty((cAlias)->EEQ_PGT) .And.;
                          (cAlias)->EEQ_TIPO <> "A")
      EndIf

      // ** JPM - Início - 04/11/04 - correção na verificação do status
      If empty((cAlias)->EEQ_PGT)
         lTemParcNaoLiq := .t.
         if lTemParcLiq
            exit
         Endif
         If !Empty((cAlias)->EEQ_SOL)
            lTemSolSemLiq := .t.
            If !lValid_R  // By JPP - 09/03/2007 - 14:00
               If (cAlias)->EEQ_TIPO <> "A"
                  lNaoValidAdiant := .F.
                  lValid_R := .T.
               EndIf
            EndIf
            (cAlias)->(DbSkip())
            loop
         ElseIf AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal(cAlias)    //NCF - 25/11/2015
            If IsReceita( (cAlias)->EEQ_EVENT ) .And. !Empty( (cAlias)->EEQ_DTCE )
               lTCamMovEx := .T.
            EndIf
         EndIf
      Else
            lTemParcLiq := .t.
         If !lValid_R // By JPP - 09/03/2007 - 14:00
            If (cAlias)->EEQ_TIPO <> "A"
               lNaoValidAdiant := .F.
               lValid_R := .T.
            EndIf
         EndIf
      Endif
      (cALIAS)->(dbSkip())
   Enddo

   if !lTemSolSemLiq .and. !lTemParcLiq
      cStatus := ST_EM //Embarcado
      If EECFlags("CAFE") .And. Type("M->EEC_TIPO") == "C" .And. M->EEC_TIPO == "W" //RMD - Restaura o status do contrato de Wash-Out
         aOrdEXL := SaveOrd("EXL")
         EXL->(DbSetOrder(1))
         EXL->(DbSeek(xFilial("EXL")+M->EEC_PREEMB))
         cStatus := EXL->EXL_TIPOWO
         RestOrd(aOrdEXL, .T.)
      EndIf
      If lTCamMovEx
         cStatus := ST_ME //Câmbio Rec. com Mov. Exterior
      EndIf
   Elseif lTemSolSemLiq .and. !lTemParcLiq
      cStatus := ST_CC //Câmbio a Contratar

   Elseif lTemParcNaoLiq .and. lTemParcLiq
      cStatus := ST_EP //Câmbio Parcial
   Endif    // Senão, continua como câmbio contratado

   If M->EEC_STATUS <> cStatus
      M->EEC_STATUS := cStatus // Grava codigo do Status
      DSCSITEE7(.F.,OC_EM)     // Grava descricao do Status no Alias de Memoria(.F.) .
   ENDIF

   //JAP - 21/06/06 - 09:21 - Grava o status de cambio contratado no caso de haver adiant. com o valor total do processo.
   If !lP_FFC .And. lRecEEC
       If EEC->(RecLock("EEC",.f.))
          EEC->EEC_STATUS := M->EEC_STATUS
          EEC->EEC_STTDES := M->EEC_STTDES
       EndIf
   EndIf
   IF cP_ALIAS = NIL
      TMP->(DbGoTo(nRecno))
   ELSEIF lP_FFC
          If EEC->(RecLock("EEC",.f.))
             EEC->EEC_STATUS := M->EEC_STATUS
             EEC->EEC_STTDES := AvTabela("YC",EEC->EEC_STATUS) // M->EEC_STTDES
          EndIf
   ELSEIF M->EEC_STATUS = ST_CC .And. !lNaoValidAdiant // By JPP - 09/03/2007 - 14:00 - O aviso não poderá ser dado se a validação tiver sido feita apenas sobre a parcela de adiantamento.
          If cStatus == ST_CC .And. M->EEC_DTEMBA <> EEC->EEC_DTEMBA //Câmbio a Contratar
              HELP(" ",1,"AVG0005089") //MSGINFO("Dt.Embarque Não Alterada. Processo Com Solicitação de Câmbio !","Atenção")
              lRET := .F.
              M->EEC_DTEMBA:= EEC->EEC_DTEMBA
          EndIf
   ELSEIF M->EEC_STATUS = ST_EP .And. !lNaoValidAdiant .And. Empty(M->EEC_DTEMBA)// By JPP - 09/03/2007 - 14:00 - O aviso não poderá ser dado se a validação tiver sido feita apenas sobre a parcela de adiantamento.
          HELP(" ",1,"AVG0005090") //MSGINFO("Dt.Embarque Não Alterada. Processo Embarcado Parcialmente !","Atenção")
          lRET := .F.
   ELSEIF cSTATUS = ST_CO .And. !lNaoValidAdiant // By JPP - 09/03/2007 - 14:00 - O aviso não poderá ser dado se a validação tiver sido feita apenas sobre a parcela de adiantamento.
          If lEvent101Liq .And. M->EEC_DTEMBA <> EEC->EEC_DTEMBA
             HELP(" ",1,"AVG0005091") //MSGINFO("Dt.Embarque Não Alterada. Processo Com Contratação de Câmbio !","Atenção")
             lRET := .F.
          EndIf
   ENDIF

   /*
   AMS - 18/08/2005. Ponto de entrada para customização de status.
   */
   If EasyEntryPoint("EECAF200")
      ExecBlock("EECAF200", .f., .f., "PE_STATUS")
   EndIf

End Sequence

Return(lRet)
*--------------------------------------------------------------------
/*
Funcao      : AF200BXPARC()
Parametros  :
Retorno     :
Objetivos   : Baixa Parcial de Parcelas
Autor       : Jeferson Barros Jr.
Data/Hora   : 10/07/2001 - 08:10
Obs.        :
*/

*--------------------------------------------------------------------
Static Function AF200BXPARC(nTipo)

Local lRet:=.T., nSaldoR:=0
Local nRecno := TMP->(Recno()), aOrd := SaveOrd("TMP")
Local lCposBcoEx := EEQ->(FieldPos('EEQ_DTCE')) > 0 .And. EEQ->(FieldPos('EEQ_MODAL')) > 0 .And. EEQ->(FieldPos('EEQ_BCOEXT')) > 0 .And. EEQ->(FieldPos('EEQ_AGCEXT')) > 0 .And. EEQ->(FieldPos('EEQ_CNTEXT')) > 0

Begin Sequence
If nTipo <> INC_DET // .and. (!lOkEVENT .or. M->EEQ_EVENT == EV_PRINC2)
   If nTipo == ELQ_DET .or. nTipo == LIQ_DET
      IF EMPTY(M->EEQ_PGT)
         HELP(" ",1,"AVG0005092") //MSGINFO("Contratação Não Efetuada. Data do Fechamento Deve Ser Preenchida !","Atenção")
         lRET := .F.
         BREAK
                                                         //MFR 10/11/2020 OSSME-5319
      ELSEIF ! EMPTY(M->EEQ_PGT) .AND. EMPTY(M->EEQ_TX) .And. !EasyVerModal("M")
         HELP(" ",1,"AVG0005093") //MSGINFO("Contratação Não Efetuada. Valor da Taxa Deve Ser Preenchido !","Atençao")
         lRET := .F.
         BREAK
      Elseif !Empty(M->EEQ_PGT) .And. !( If( lCposBcoEx .And. EasyVerModal("M") , ;
                                                 !Empty(M->EEQ_BCOEXT) .And. !Empty(M->EEQ_AGCEXT) .And. !Empty(M->EEQ_CNTEXT) ,;
                                                 !Empty(M->EEQ_BANC) .And. !Empty(M->EEQ_AGEN) .And. !Empty(M->EEQ_NCON) ) )
         EasyHelp(STR0043,STR0044) //"Contratação Não Efetuada. Banco deve ser preenchido !"###"Atençao"
         lRET := .F.
         BREAK

	  ElseIf !AF200VCom(nTipo) //AAF - 21/10/2013
         lRet := .F.
         Break
      /*ElseIf nTipo == ELQ_DET .AND. !AF200VCom(nTipo)
         lRet := .F.
         Break  */
      EndIf
   Else

      //MFR OSSME-1951 -Validar se estiver informando  a data de crédito e (o campo Acrescimo e/ou Decrescimo) dar a mensagem
      if (EEQ->EEQ_ACRESC <> M->EEQ_ACRESC .Or. EEQ->EEQ_DECRES <> M->EEQ_DECRES) .And. !Empty(M->EEQ_DTCE) .And. M->EEQ_Modal == "2"
         EasyHelp(STR0305)  //Antes de preencher a data de crédito no exterior, a parcela de câmbio deve ser salva com os novos valores de acréscimo/ decréscimo. Confirme a alteração da parcela antes de prosseguir.
         lRet := .F.
         Break
      EndIf 
   
      //lCposBcoEx := EEQ->(FieldPos('EEQ_DTCE')) > 0 .And. EEQ->(FieldPos('EEQ_MODAL')) > 0 .And. EEQ->(FieldPos('EEQ_BCOEXT')) > 0
      If nTipo == ALT_DET .And. lCposBcoEx .And. !Empty(M->EEQ_DTCE) .And. (Type("M->EEQ_MODAL") <> "C" .Or. (M->EEQ_MODAL == "2" .And. Empty(M->EEQ_BCOEXT))) //LGS-28/08/2014 //NCF - 28/11/2014 //RMD - 28/11/14 - Teste para verificar se a variável existe.
      	 EasyHelp(STR0043,STR0044) //"Contratação Não Efetuada. Banco deve ser preenchido !"###"Atençao"
         lRet := .F.
         Break
      EndIf

      If lOkEvent .And. M->EEQ_EVENT <> "101" .And. !EECFlags("FRESEGCOM")
         Break
      EndIf

      // ** JPM - 05/01/2010 - Essa validação não se aplica à baixa gerencial
      If nTipo == BXG_DET
         Break
      EndIf

      If !AF200VCom(ALT_DET)
         lRet := .F.
         break
      EndIf

      // ** By JBJ 12/03/03. (Verifica se existe saldo a receber. - De acordo com o valor negociado.)
      nSaldoR := nVlSaldo-M->EEQ_VL

      If !(nTipo == ALT_DET .And. !Empty(M->EEQ_PGT)) .And. nSaldoR < 0 //RMD - 17/10/14 - Verifica também se é alteração de parcela liquidada (somente campos de usuário)
         HELP(" ",1,"AVG0005094") //MsgInfo("Valor da parcela maior que o valor negociado! ","Aviso")
         lRet := .F.
         Break
      Else
         /* **By JBJ - 14/03/03 - Tratamentos gerais para a alteração de parcelas no caso de disponibilidade de
                                  saldo de acordo com o valor negociado. */
         // ** GFC - 12/08/05 - Verificar o retorno da função Af200TrataParc()
         If !Af200TrataParc()
            lRet := .F.
            Break
         EndIf
         // **
      EndIf

   EndIf
Else
   If lOkEVENT .and. Empty(M->EEQ_EVENT)
      Help(" ",1,"AVG0005226") //MsgInfo(STR0029) //"O Campo Cod. Evento deve ser preenchido."
      lRet := .F.
      Break
   EndIf
EndIf
End Sequence

RestOrd(aOrd)

TMP->(dbGoTo(nRecno))

Return(lRet)

/*
Funcao      : AF200TrataParc()
Parametros  : lAutomatico - Indica se a quebra da parcela foi automatica (.T.) ou manual via alteração (.F., default).
Retorno     : Nil.
Objetivos   : Tratamento diversos na(s) parcelas de Câmbio.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/03/2003 - 16:10.
Obs.        :  Para a rotina de frete seguro e comissão, os valores vinculados para
               cada tipo de comissão são distribuídos proporcionalmente à distribuição
               do valor da parcela.
               Esta função também é chamada do programa EFFAF200.PRW
*/
*------------------------------------------*
Function AF200TrataParc(lAutomatico)
*------------------------------------------*
Local nRec := 0, nVlAtual:= 0, nVlOld := 0, cNumParc:=0, nPos:=0, nTxvAux:=0
Local lRet:=.t., aOrd, cParc, cOrigem, nRecTemp:=0, dDtVincAux:=AvCtoD("  /  /  ")
Local cSequAux:=If(lFinanciamento,Space(Len(EF3->EF3_SEQ)),""),;
      cContrAux:=If(lFinanciamento,Space(Len(EF3->EF3_CONTRA)),"")
// ACSJ - 05/02/2005
Local cBanco := If(lFinanciamento .and. lTemChave, Space(Len(EF3->EF3_BAN_FI)),"")
Local cPraca := If(lFinanciamento .and. lTemChave, Space(Len(EF3->EF3_PRACA)),"")
Local cSeqCon:= If(lFinanciamento .and. lTemChave .And. lEFFTpMod, Space(Len(EF3->EF3_SEQCNT)),"")

// ** Variáveis utilizadas nos tratamentos de frete/seguro e comissão.
Local nCGrafi := 0, nADeduz := 0, nAremet := 0, nPerc := 0
Local nIniCGrafi := 0, nIniADeduz := 0, nIniARemet := 0,;
      nRecCGrafi := 0, nRecADeduz := 0, nRecARemet := 0, nRecIni:=0
Local nIniAcresc := 0
Local nIniDecres := 0
Local nIniDescon := 0
Local nRecAcresc := 0
Local nRecDecres := 0
Local nRecDescon := 0

Local lTemDiferenca := .f.

//Variáveis utilizadas para o financiamento
Local ni, nVlArrayEEQ:=0, cParFinAux, nVlParfin:=0, nRecAux, nVlParAux:=0, nx, cParcAux:=""

//AMS - 03/08/2005.
Local aSaveOrd      := SaveOrd({"TMP", "EF3"})
Local nVlAjuste     := 0
Local nTotParcAgrup := 0
// ** GFC - 29/09/05
Local nTotCGRAFI    := 0
Local nTotADEDUZ    := 0
Local nTotAREMET    := 0
Local cWorkEEQContra:= ""
// **
Local aParcAgrup    := {}
Local nRecno        := TMP->(Recno())
Local aParcela      := {}
Local cEvento       := ""
Local cCodEmp       := ""
Local aNewVinc      := {} //ASK 18/07/07

// ** JPM - setar variável com a nova parcela que recebeu o valor alterado. Vide EECAD101.PRW
Local bSetNewParc := {|x| If(Type("cNewParcResiduo")="C",cNewParcResiduo := x,Nil)}

Private lAjuste:= .T.  //TRP - 12/12/2011 - Variável a ser utilizada em rdmake para desviar ajuste de parcela.

If(lAutomatico=NIL,lAutomatico:=.F.,) // ** GFC - 29/09/05

Begin Sequence

   If lOkEvent                  // By JPP - 27/09/2005 - 17:10
      cEvento := TMP->EEQ_EVENT // A variavel cEvento será incializada apenas se o campo EEQ_EVENT existir na base.
      cCodEmp := TMP->EEQ_CODEMP     
   EndIf

   For nPos := 1 To TMP->(fCount())
      aAdd(aParcela, TMP->(FieldGet(nPos)))
   Next

   nRecIni  := TMP->(RecNo())
   nVlAtual := M->EEQ_VL
   nVlOld	:= TMP->EEQ_VL
	
   If EECFlags("FRESEGCOM")
      If TMP->EEQ_EVENT == EV_PRINC2
         aOrd:=SaveOrd("TMP")
         TMP->(DbSetOrder(4))
         If TMP->(DbSeek(EV_PRINC2))
            Do While TMP->(!Eof()) .And. TMP->EEQ_EVENT == EV_PRINC2
               nIniCGrafi += TMP->EEQ_CGRAFI
               nIniADeduz += TMP->EEQ_ADEDUZ
               nIniARemet += TMP->EEQ_AREMET
				nIniAcresc += TMP->EEQ_ACRESC
				nIniDecres += TMP->EEQ_DECRES
				nIniDescon += TMP->EEQ_DESCON
               TMP->(DbSkip())
            EndDo
         EndIf
         RestOrd(aOrd,.t.)
      EndIf
   EndIf

   /*
   AMS - Reprogramação de Recebimentos/Vencimentos p/ mais de duas parcelas.
   */
   nVlAjuste := (nVlOld - nVlAtual)
   cParcAux  := TMP->EEQ_PARC // ** GFC - 12/08/05
   lBcoRef    := IIF(EasyVerModal("M"),Empty(M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT)),Empty(M->(EEQ_BANC+EEQ_AGEN+EEQ_NCON+EEQ_RFBC))) // GFP - 28/05/2014

   // ** JPM - setar variável com a nova parcela que recebeu o valor alterado. Vide EECAD101.PRW
   Eval(bSetNewParc,TMP->EEQ_PARC)

   If nVlAjuste = 0
      Break
   EndIf

   TMP->(dbSetOrder(3))
   TMP->(dbSkip())

   /*
   Ajuste Positivo
   */
   If nVlAjuste > 0

      cParc := M->EEQ_PARC

      /*
      Procura abaixo da parcela alterada, uma parcela em aberto. Encontrando, a mesma tera no
      seu valor, acrescido o valor de ajuste.
      */

      //TRP - 12/12/2011 - Ponto de Entrada para desviar Ajuste.
      If EasyEntryPoint("EECAF200")
         ExecBlock("EECAF200", .f., .f., "DESVIA_AJUSTE")
      Endif

      If lAjuste
         // GFP - 28/05/2014 - O sistema deve quebrar a parcela caso a mesma possua referencias bancarias.
         While lBcoRef .AND. (TMP->(!Eof()) .and. !lAutomatico  .And.  AScan(aArrayEEQ,{|x|x[20]==nRecno .And. !Empty(x[5])}) == 0)

            If EECFlags("TIT_PARCELAS")
            	TMP->(DbSkip())
            	Loop
            EndIf
            If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
               TMP->(dbSkip())
               Loop
            EndIf
            If Avflags("EEC_LOGIX") .And. If(TMP->(FieldPos("EEQ_FINNUM")) > 0,!Empty(TMP->EEQ_FINNUM),.F.) //NCF - 28/10/2014
               TMP->(dbSkip())
               Loop
            EndIf
            If (!EasyVerModal("TMP") .And. Empty(TMP->EEQ_PGT)) .Or. (EasyVerModal("TMP") .And. Empty(TMP->EEQ_DTCE))

               // ** JPM - setar variável com a nova parcela que recebeu o valor alterado. Vide EECAD101.PRW
               Eval(bSetNewParc,TMP->EEQ_PARC)

               TMP->EEQ_VL += nVlAjuste
               AjustaComissao((nVlAjuste/(TMP->EEQ_VL-nVlAjuste)), "TMP")
               Exit
            EndIf

            TMP->(dbSkip())

         End

      Endif
      /*
      Não encontrando a parcela em aberto é criada uma parcela igual a alterada com o valor
      do ajuste.
      */
      If !lBcoRef  // GFP - 28/05/2014
         TMP->(DbGoTo(TMP->(EasyRecCount())+1))
      EndIf

      If TMP->(Eof()) .or. lAutomatico  .Or.  AScan(aArrayEEQ,{|x|x[20]==nRecno .And. !Empty(x[5])}) > 0

         TMP->(dbGoTo(nRecno)) //Posiciona na parcela alterada.

         /*
         Calcula e atualiza variaveis para parcelas de financiamento.
         */
         If lFinanciamento // GFC 13/10/03
            //nPos := aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)})
            // PLB 23/08/07
            nPos := aScan(aArrayEEQ,{|x| x[3] == TMP->EEQ_PARC })
            If nPos>0
               For ni:=nPos to Len(aArrayEEQ)
                  //If aArrayEEQ[ni,3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN) .and. !Empty(aArrayEEQ[ni,5])
                  // PLB 23/08/07
                  If aArrayEEQ[ni,3] == TMP->EEQ_PARC  .And.  !Empty(aArrayEEQ[ni,5])
                     nVlArrayEEQ += aArrayEEQ[ni,1]
                  EndIf
               Next ni
               nVlParAux:=0
               If !Empty(aArrayEEQ[nPos,5]) .and. nVlAtual < nVlArrayEEQ //aArrayEEQ[nPos,1]
                  cContrAux     := aArrayEEQ[nPos,5]
                  cBanco        := aArrayEEQ[nPos,14]
                  nVlParAux     := M->EEQ_VL_PAR
                  M->EEQ_VL_PAR := 0
                  M->EEQ_FI_TOT := "S"
               ElseIf !Empty(aArrayEEQ[nPos,5]) .and. nVlAtual = nVlArrayEEQ
                  nVlParAux     := M->EEQ_VL_PAR
                  M->EEQ_VL_PAR := 0
                  M->EEQ_FI_TOT := "S"
               EndIf
               cSequAux        := aArrayEEQ[nPos,6]
               dDtVincAux      := aArrayEEQ[nPos,10]
               nTxvAux         := aArrayEEQ[nPos,11]
               //M->EEQ_VL_PAR   := M->EEQ_VL - (TMP->EEQ_VL - TMP->EEQ_VL_PAR)
               // ACSJ - 05/02/2005
               if lTemChave
                  cPraca       := aArrayEEQ[nPos,15]
                  If lEFFTpMod
                     cSeqCon := aArrayEEQ[nPos,21]
                  EndIf
               Endif
               // -----------------
               // ** PLB 16/10/06
               aArrayEEQ[nPos][1]  := nVlAtual
               aArrayEEQ[nPos][6]  := ""
               aArrayEEQ[nPos][7]  := NIL
               aArrayEEQ[nPos][16] := NIL
               aNewVinc := aClone(aArrayEEQ[nPos])
               /*If (ni := aScan(aExcVinculo,{|x| x[8]==aArrayEEQ[nPos,16]})) == 0
                  aAdd(aExcVinculo,;
                      {aArrayEEQ[nPos,3],;
                       aArrayEEQ[nPos,5],;
                       1,;
                       0,;
                       aArrayEEQ[nPos,6],;
                       iif(lTemChave,aArrayEEQ[nPos,14],""),;
                       iif(lTemChave,aArrayEEQ[nPos,15],""),;
                       aArrayEEQ[nPos,16],;
                       If(lEFFTpMod,aArrayEEQ[nPos,21],),;
                       If(lEFFTpMod,"E",)})
               EndIf*/
               // **
            EndIf
         EndIF

         /*
         Recupera o número da ultima parcela.
         */
         TMP->(dbSetOrder(1),;
               dbGoBottom(),;
               cNumParc := EEQ_PARC)

         TMP->(dbAppend())

         /*
         A parcela criada, irá conter os dados sem alteração da parcela alterada.
         */
         For nPos := 1 To Len(aParcela)
            TMP->(FieldPut(nPos, aParcela[nPos]))
         Next

         //Limpa a informação do título anterior.
		 //AAF - Verificar apenas se o EEQ_FINNUM existe na work para não comprometer integrações com outros ERPs
         If TMP->(FieldPos("EEQ_FINNUM")) > 0 //If EasyGParam("MV_AVG0131",,.T.) //LRS - 25/09/2013 - Verifica se tem a integração entre o EEC e o FIN
            If !(AvFlags("EEC_LOGIX"))
         	   If (!EECFlags("TIT_PARCELAS") .And. !EECFlags("ALT_EASYLINK")) .Or. !IsReceita(TMP->EEQ_EVENT) //RMD - 06/10/12 - Mantem a referencia do titulo original quando possuir tratamento de parcelas.
                  //RMD - 03/02/17 - Caso seja movimento no exterior e já tenha crédito no exterior, o título já foi baixado e deverá ser mantido na parcela do resíduo.
	              If !EasyVerModal("TMP") .Or. Empty(TMP->EEQ_DTCE) .OR. TMP->TMP_RECNO > 0 .AND. EEQ->(dbGoTo(TMP->TMP_RECNO), Empty(EEQ->EEQ_DTCE)) //AAF 14/02/2017 - Permitir a quebra do titulo pois não baixou com o movimento no exterior ainda.
                     TMP->EEQ_FINNUM := ""
                  EndIf
         	   EndIf
            EndIf
         EndIf

         TMP->(EEQ_VL     := nVlAjuste,;
               EEQ_PARC   := SomaIt(cNumParc),;
               EEQ_ORIGEM := M->EEQ_PARC,;
					TMP_RECNO  := 0)

         //THTS - 20/04/2017
         If  AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0 .And. EEQ->EEQ_EAIVRS == "2"
            TMP->EEQ_FINNUM := "" //Limpa o campo para gerar um novo titulo.
            aAdd(aDeletados,EEQ->(Recno()))
         EndIf

         AjustaComissao(nVlAjuste/nVlOld, "TMP",  .T./*Atribui valores*/ )

         // ** JPM - setar variável com a nova parcela que recebeu o valor alterado. Vide EECAD101.PRW
         Eval(bSetNewParc,TMP->EEQ_PARC)

         /*
         Inicio da gravação da parcela de financiamento.
         */
         If lAutomatico
            aArrayEEQ[nSeqArray-1,3] := TMP->EEQ_PARC
         EndIf
         If lParFin .and. lFinanciamento
            // ** GFC - 09/08/05 - Será apurado a seguir se é parcela de financiamento
            TMP->EEQ_PARFIN := ""
            TMP->EEQ_NROP   := ""
            // **
            cWorkEEQContra := WorkEEQ->EF2_CONTRA

            /* AAF 25/10/2007 - Removida a gravação do ParFin pois está é feita na gravação do câmbio.
            EF3->(dbSetOrder(3))
            IF EF3->(dbSeek(xFilial("EF3")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(M->EEQ_PARFIN), cParc, M->EEQ_PARFIN)+EV_EMBARQUE))
               nVlArrayEEQ := 0
               nRecAux := EF3->(RecNo())
               Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and. EF3->EF3_INVOIC==TMP->EEQ_NRINVO .and.;
               EF3->EF3_PARC==If(!lParFin .Or. Empty(M->EEQ_PARFIN), cParc, M->EEQ_PARFIN) .and.;
               EF3->EF3_CODEVE == EV_EMBARQUE
                  nVlArrayEEQ += EF3->EF3_VL_INV //EF3->EF3_VL_MOE
                  EF3->(dbSkip())
               EndDo
               EF3->(dbGoTo(nRecAux))

               //Soma todas parcelas com mesmo Parfin
               nRecAux := TMP->(RecNo())
               nVlParfin := 0
               TMP->(dbGoTop())
               Do While !TMP->(EOF())
                  If TMP->(RecNo()) <> nRecIni .and. (TMP->EEQ_PARFIN == EF3->EF3_PARC .or.;
                  (Empty(TMP->EEQ_PARFIN) .and. TMP->EEQ_PARC == EF3->EF3_PARC))
                     nVlParfin += If(EECFlags("FRESEGCOM"),TMP->EEQ_VLFCAM,TMP->EEQ_VL)
                  EndIf
                  TMP->(dbSkip())
               EndDo
               TMP->(dbGoTo(nRecAux))

               If (nVlAtual + nVlParfin) < nVlArrayEEQ //EF3->EF3_VL_MOE
                  TMP->EEQ_PARFIN := EF3->EF3_PARC
                  TMP->EEQ_NROP   := EF3->EF3_CONTRA
               ElseIf WorkEEQ->(dbSeek(TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(M->EEQ_PARFIN), cParc, M->EEQ_PARFIN)))
                  TMP->EEQ_PARFIN := EF3->EF3_PARC
                  TMP->EEQ_NROP   := EF3->EF3_CONTRA
               Else
                  For ni:=nPos to Len(aArrayEEQ)
                     If aArrayEEQ[ni,3]==EF3->EF3_PARC .and. Empty(aArrayEEQ[ni,5])
                        aArrayEEQ[ni,3]  := TMP->EEQ_PARC
                        aArrayEEQ[ni,13] := TMP->EEQ_PARC
                     EndIf
                  Next ni
               Endif
            ElseIf WorkEEQ->(dbSeek(TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(M->EEQ_PARFIN), cParc, M->EEQ_PARFIN)))
               TMP->EEQ_PARFIN := EF3->EF3_PARC
               TMP->EEQ_NROP   := EF3->EF3_CONTRA
            Endif
            */

            If lAutomatico .and. Empty(cWorkEEQContra)
               TMP->EEQ_VL_PAR := 0
               TMP->EEQ_FI_TOT := ""
            ElseIf nVlParAux > 0
//               If nVlParAux <> TMP->EEQ_VL
                  TMP->EEQ_VL_PAR := nVlParAux
                  TMP->EEQ_FI_TOT := "N"
//               EndIf
            ElseIf nVlArrayEEQ > 0
               If If(EECFlags("FRESEGCOM"),TMP->EEQ_VLFCAM,TMP->EEQ_VL) + nVlAtual <= nVlArrayEEQ
                  TMP->EEQ_VL_PAR := 0
                  TMP->EEQ_FI_TOT := "S"
               Else
                  TMP->EEQ_VL_PAR := nVlArrayEEQ - (If(EECFlags("FRESEGCOM"),TMP->EEQ_VLFCAM,TMP->EEQ_VL) + nVlAtual)
                  TMP->EEQ_FI_TOT := "N"
               EndIf
            EndIf

            // ** PLB 16/10/06
            If !Empty(aNewVinc) //ASK 18/07/07
               AAdd(aArrayEEQ,aNewVinc)
               aArrayEEQ[Len(aArrayEEQ)][1]  := nVlAjuste
               aArrayEEQ[Len(aArrayEEQ)][3]  := TMP->EEQ_PARC
               aArrayEEQ[Len(aArrayEEQ)][8]  := nSeqArray+1
               aArrayEEQ[Len(aArrayEEQ)][13] := TMP->EEQ_PARC
               aArrayEEQ[Len(aArrayEEQ)][17] := nVlAjuste
               aArrayEEQ[Len(aArrayEEQ)][20] := TMP->(RecNo())
               aNewVinc := {}
            EndIf
            // **
         EndIF
         /*
         Final da gravação da parcela de financiamento.
         */

      EndIf

   /*
   Ajuste Negativo
   */
   Else

      /*
      Procura abaixo da parcela alterada, uma parcela em aberto cuja seu valor seja igual ao
      valor de ajuste (valor absoluto). Encontrando, a mesma é excluida. 25/06/2019
      */
      While TMP->(!Eof())

         If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
            TMP->(dbSkip())
            Loop
         EndIf
         If Empty(TMP->EEQ_PGT) .and. TMP->EEQ_VL == ABS(nVlAjuste) 
            // ** GFC - 12/08/05 - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
            If lFinanciamento .and.;
            (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,5]) .and.;
            !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux
               EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
               lRet := .F.
               Break
            // **
            Else
               // ** GFC - 09/08/05
               If lFinanciamento
                  If Empty(TMP->EEQ_FI_TOT)
                     nVlParAux := TMP->EEQ_VL
                  ElseIf TMP->EEQ_FI_TOT == "N"
                     nVlParAux := TMP->EEQ_VL_PAR
                  Else
                     nVlParAux := 0
                  EndIf
               EndIf
               // **
               If !Empty(TMP->TMP_RECNO)
                  aAdd(aDeletados,TMP->TMP_RECNO)
               Endif
               TMP->(dbDelete())
            EndIf
            Exit
         EndIf

         TMP->(dbSkip())

      End

      If TMP->(Eof())

         TMP->(dbGoTo(nRecno))
         TMP->(dbSkip(-1))

         /*
         Procura acima da parcela alterada, uma parcela em aberto cuja seu valor seja igual ao
         valor de ajuste (valor absoluto). Encontrando, a mesma é parcela é excluida.
         */
         While TMP->(!Bof())

            If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
               TMP->(dbSkip(-1))
               Loop
            EndIf

            If Empty(TMP->EEQ_PGT) .and. TMP->EEQ_VL = ABS(nVlAjuste)
               // ** GFC - 12/08/05 - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
               If lFinanciamento .and.;
               (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,5]) .and.;
               !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux
                  EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                  lRet := .F.
                  Break
               // **
               Else
                  // ** GFC - 09/08/05
                  If lFinanciamento
                     If Empty(TMP->EEQ_FI_TOT)
                        nVlParAux := TMP->EEQ_VL
                     ElseIf TMP->EEQ_FI_TOT == "N"
                        nVlParAux := TMP->EEQ_VL_PAR
                     Else
                        nVlParAux := 0
                     EndIf
                  EndIf
                  // **
                  If !Empty(TMP->TMP_RECNO)
                     aAdd(aDeletados,TMP->TMP_RECNO)
                  Endif
                  TMP->(dbDelete())
               EndIf

               Exit
            EndIf

            TMP->(dbSkip(-1))

         End

         If TMP->(Bof())

            TMP->(dbGoTo(nRecno))
            TMP->(dbSkip())

            /*
            Procura abaixo da parcela alterada, uma parcela em aberto cuja seu valor seja maior que
            o valor de ajuste (valor absoluto). Encontrando, a mesma tera no seu valor, um abatimento
            do valor de ajuste.
            */
            While TMP->(!Eof())

               If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
                  TMP->(dbSkip())
                  Loop
               EndIf

               If Empty(TMP->EEQ_PGT) .and. TMP->EEQ_VL > ABS(nVlAjuste)
                  // ** GFC - 12/08/05 - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                  If lFinanciamento .and. (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and.;
                  !Empty(aArrayEEQ[nPos,5]) .and. !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux .and.;
                  (TMP->EEQ_VL - ABS(nVlAjuste)) < aArrayEEQ[nPos,1]
                     EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                     lRet := .F.
                     Break
                  // **
                  Else
                     // ** GFC - 09/08/05
                     If lFinanciamento
                        If Empty(TMP->EEQ_FI_TOT)
                           nVlParAux := ABS(nVlAjuste)
                        ElseIf TMP->EEQ_FI_TOT == "N"
                           If Abs(nVlAjuste) >= TMP->EEQ_VL_PAR
                              nVlParAux       := TMP->EEQ_VL_PAR
                              TMP->EEQ_VL_PAR := 0
                              TMP->EEQ_FI_TOT := "S"
                           Else
                              nVlParAux       := Abs(nVlAjuste)
                              TMP->EEQ_VL_PAR -= Abs(nVlAjuste)
                           EndIf
                           //If (TMP->EEQ_VL - Abs(nVlAjuste)) - TMP->EEQ_VL_PAR < 0
                           //   TMP->EEQ_VL_PAR := TMP->EEQ_VL
                           //   nVlParAux := Abs((TMP->EEQ_VL - Abs(nVlAjuste)) - TMP->EEQ_VL_PAR)
                           //EndIf
                        Else
                           nVlParAux := 0
                        EndIf
                     EndIf
                     // **
                     TMP->EEQ_VL += nVlAjuste
                     AjustaComissao((nVlAjuste/(TMP->EEQ_VL-nVlAjuste)), "TMP")
                  EndIf

                  Exit
               EndIf

               TMP->(dbSkip())

            End

            If TMP->(Eof())

               TMP->(dbGoTo(nRecno))
               TMP->(dbSkip(-1))

               /*
               Procura acima da parcela alterada, uma parcela em aberto cuja seu valor seja maior que
               o valor de ajuste (valor absoluto). Encontrando, a mesma tera no seu valor, um abatimento
               do valor de ajuste.
               */
               While TMP->(!Bof())

                  If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
                     TMP->(dbSkip(-1))
                     Loop
                  EndIf

                  If Empty(TMP->EEQ_PGT) .and. TMP->EEQ_VL > ABS(nVlAjuste)
                     // ** GFC - 12/08/05 - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                     If lFinanciamento .and. (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and.;
                     !Empty(aArrayEEQ[nPos,5]) .and. !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux .and.;
                     (TMP->EEQ_VL - ABS(nVlAjuste)) < aArrayEEQ[nPos,1]
                        EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                        lRet := .F.
                        Break
                     // **
                     Else
                        // ** GFC - 09/08/05
                        If lFinanciamento .and. Abs(nVlAjuste) > 0
                           If Empty(TMP->EEQ_FI_TOT)
                              nVlParAux := ABS(nVlAjuste)
                           ElseIf TMP->EEQ_FI_TOT == "N"
                              If Abs(nVlAjuste) >= TMP->EEQ_VL_PAR
                                 nVlParAux       := TMP->EEQ_VL_PAR
                                 TMP->EEQ_VL_PAR := 0
                                 TMP->EEQ_FI_TOT := "S"
                              Else
                                 nVlParAux       := Abs(nVlAjuste)
                                 TMP->EEQ_VL_PAR -= Abs(nVlAjuste)
                              EndIf
                              //If (TMP->EEQ_VL - Abs(nVlAjuste)) - TMP->EEQ_VL_PAR < 0
                              //   TMP->EEQ_VL_PAR := TMP->EEQ_VL
                              //   nVlParAux := Abs((TMP->EEQ_VL - Abs(nVlAjuste)) - TMP->EEQ_VL_PAR)
                              //EndIf
                           Else
                              nVlParAux := 0
                           EndIf
                        EndIf
                        // **
                        TMP->EEQ_VL += nVlAjuste
                        AjustaComissao((nVlAjuste/(TMP->EEQ_VL-nVlAjuste)), "TMP")
                     EndIf

                     Exit
                  EndIf

                  TMP->(dbSkip(-1))

               End

               If TMP->(Bof())

                  TMP->(dbGoTo(nRecno))
                  TMP->(dbSkip())

                  /*
                  Procura abaixo da parcela alterada, um agrupamento de parcelas não liquidadas, onde
                  seu valor seja igual ou maior ao valor do ajuste. Encontrando e o valor sendo igual,
                  ao valor de ajuste, serao excluidas as parcelas que formam o agrupamento. O valor do
                  agrupamento sendo maior que o valor de ajuste, serão agrupadas em uma unica parcela
                  e tera no seu valor, um abatimento do valor de ajuste.
                  */
                  While TMP->(!Eof())

                     If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
                        TMP->(dbSkip())
                        Loop
                     EndIf

                     If Empty(TMP->EEQ_PGT)
                        aAdd(aParcAgrup, TMP->(Recno()))

                        nTotParcAgrup += TMP->EEQ_VL

                        If EECFlags("FRESEGCOM")
                           TMP->(nTotCGRAFI += EEQ_CGRAFI,;
                                 nTotADEDUZ += EEQ_ADEDUZ,;
                                 nTotAREMET += EEQ_AREMET)
                        EndIf

                        Do Case

                           Case nTotParcAgrup == ABS(nVlAjuste)

                              // ** GFC - 12/08/05 - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                              If lFinanciamento
                                 For nx:=1 to Len(aParcAgrup)
                                    TMP->(dbGoTo(aParcAgrup[nx]))
                                    If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,5]) .and.;
                                    !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux
                                       EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                       lRet := .F.
                                       Break
                                    EndIf
                                 Next nx
                                 nVlParAux := ABS(nVlAjuste)
                              EndIf
                              // **

                              TMP->(aEval(aParcAgrup, {|x| dbGoTo(x),;
                                                           If(!Empty(TMP_RECNO), aAdd(aDeletados, TMP_RECNO),),;
                                                           dbDelete()}))

                              Exit

                           Case nTotParcAgrup > ABS(nVlAjuste)

                              // ** GFC - 12/08/05 - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                              If lFinanciamento
                                 For nx:=2 to Len(aParcAgrup)
                                    TMP->(dbGoTo(aParcAgrup[nx]))
                                    If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,5]) .and.;
                                    !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux
                                       EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                       lRet := .F.
                                       Break
                                    EndIf
                                 Next nx

                                 TMP->(dbGoTo(aParcAgrup[1]))

                                 If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,5]) .and.;
                                 !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux .and.;
                                 (TMP->EEQ_VL - ABS(nVlAjuste)) < aArrayEEQ[nPos,1]
                                    EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                    lRet := .F.
                                    Break
                                 EndIf
                              EndIf
                              // **

                              TMP->(aEval(aParcAgrup, {|x| dbGoTo(x),;
                                                           If(!Empty(TMP_RECNO), aAdd(aDeletados, TMP_RECNO),),;
                                                           If(lFinanciamento,If(Empty(TMP->EEQ_FI_TOT), nVlParAux += nVlAjuste, If(TMP->EEQ_FI_TOT == "N", (nVlParAux += nVlAjuste, TMP->EEQ_VL_PAR += nVlAjuste), nVlParAux += 0)),),; // ** GFC - 10/08/05
                                                           dbDelete()}, 2))

                              TMP->(dbGoTo(aParcAgrup[1]),;
                                    EEQ_VL := nTotParcAgrup)

                              If EECFlags("FRESEGCOM")
                                 TMP->(EEQ_CGRAFI := nTotCGRAFI,;
                                       EEQ_ADEDUZ := nTotADEDUZ,;
                                       EEQ_AREMET := nTotAREMET)
                              EndIf

                              // ** GFC - 10/08/05
                              If lFinanciamento
                                 If Empty(TMP->EEQ_FI_TOT)
                                    nVlParAux := ABS(nVlAjuste)
                                 ElseIf TMP->EEQ_FI_TOT == "N"
                                    If Abs(nVlAjuste) >= TMP->EEQ_VL_PAR
                                       nVlParAux       := TMP->EEQ_VL_PAR
                                       TMP->EEQ_VL_PAR := 0
                                       TMP->EEQ_FI_TOT := "S"
                                    Else
                                       nVlParAux       := Abs(nVlAjuste)
                                       TMP->EEQ_VL_PAR -= Abs(nVlAjuste)
                                    EndIf
                                    //If (TMP->EEQ_VL - Abs(nVlAjuste)) - TMP->EEQ_VL_PAR < 0
                                    //   TMP->EEQ_VL_PAR := TMP->EEQ_VL
                                    //   nVlParAux := Abs((TMP->EEQ_VL - Abs(nVlAjuste)) - TMP->EEQ_VL_PAR)
                                    //EndIf
                                 Else
                                    nVlParAux := 0
                                 EndIf
                              EndIf
                              // **

                              TMP->EEQ_VL += nVlAjuste

                              AjustaComissao((nVlAjuste/(TMP->EEQ_VL-nVlAjuste)), "TMP")
                              Exit

                        End Case

                     EndIf

                     TMP->(dbSkip())

                  End

                  If TMP->(Eof())

                     aParcAgrup    := {}
                     nTotParcAgrup := 0
                     nTotCGRAFI    := 0
                     nTotADEDUZ    := 0
                     nTotAREMET    := 0

                     TMP->(dbGoTop())

                     /*
                     Procura a partir da primeira parcela, um agrupamento de parcelas não liquidadas, onde
                     seu valor seja igual ou maior ao valor do ajuste. Encontrando e o valor sendo igual,
                     ao valor de ajuste, serao excluidas as parcelas que formam o agrupamento. O valor do
                     agrupamento sendo maior que o valor de ajuste, serão agrupadas em uma unica parcela
                     e tera seu valor, um abatimento do valor de ajuste.
                     */
                     While TMP->(!Eof())

                        If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
                           TMP->(dbSkip())
                           Loop
                        EndIf

                        If TMP->(Recno()) <> nRecno .and. Empty(TMP->EEQ_PGT)

                           aAdd(aParcAgrup, TMP->(Recno()))

                           nTotParcAgrup += TMP->EEQ_VL

                           If EECFlags("FRESEGCOM")
                              TMP->(nTotCGRAFI += EEQ_CGRAFI,;
                                    nTotADEDUZ += EEQ_ADEDUZ,;
                                    nTotAREMET += EEQ_AREMET)
                           EndIf

                           Do Case

                              Case nTotParcAgrup == ABS(nVlAjuste)

                                 // ** GFC - 12/08/05 - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                                 If lFinanciamento
                                    For nx:=1 to Len(aParcAgrup)
                                       TMP->(dbGoTo(aParcAgrup[nx]))
                                       If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,5]) .and.;
                                       !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux
                                          EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                          lRet := .F.
                                          Break
                                       EndIf
                                    Next nx
                                 EndIf
                                 // **

                                 TMP->(aEval(aParcAgrup, {|x| dbGoTo(x),;
                                                              If(!Empty(TMP_RECNO), aAdd(aDeletados, TMP_RECNO),),;
                                                              If(lFinanciamento,If(Empty(TMP->EEQ_FI_TOT), nVlParAux += nVlAjuste, If(TMP->EEQ_FI_TOT == "N", (nVlParAux += nVlAjuste, TMP->EEQ_VL_PAR += nVlAjuste), nVlParAux += 0)),),; // ** GFC - 10/08/05
                                                              dbDelete()}))

                                 Exit

                              Case nTotParcAgrup > ABS(nVlAjuste)

                                 // ** GFC - 12/08/05 - Não permitir que o novo valor da parcela invalide os valores vinculados a contratos de financiamento
                                 If lFinanciamento
                                    For nx:=2 to Len(aParcAgrup)
                                       TMP->(dbGoTo(aParcAgrup[nx]))
                                       If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,5]) .and.;
                                       !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux
                                          EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                          lRet := .F.
                                          Break
                                       EndIf
                                    Next nx

                                    TMP->(dbGoTo(aParcAgrup[1]))

                                    If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,5]) .and.;
                                    !Empty(aArrayEEQ[nPos,16]) .and. aArrayEEQ[nPos,13] <> cParcAux .and.;
                                    (TMP->EEQ_VL - ABS(nVlAjuste)) < aArrayEEQ[nPos,1]
                                       EasyHelp(STR0210+Alltrim(TMP->EEQ_PARC)) //"O valor informado não será permitido pois invalidaria as vinculações da parcela "
                                       lRet := .F.
                                       Break
                                    EndIf
                                 EndIf
                                 // **

                                 TMP->(aEval(aParcAgrup, {|x| dbGoTo(x),;
                                                              If(!Empty(TMP_RECNO), aAdd(aDeletados, TMP_RECNO),),;
                                                              If(lFinanciamento,If(Empty(TMP->EEQ_FI_TOT), nVlParAux += nVlAjuste, If(TMP->EEQ_FI_TOT == "N", (nVlParAux += nVlAjuste, TMP->EEQ_VL_PAR += nVlAjuste), nVlParAux += 0)),),; // ** GFC - 10/08/05
                                                              dbDelete()}, 2))

                                 TMP->(dbGoTo(aParcAgrup[1]),;
                                       EEQ_VL := nTotParcAgrup)

                                 If EECFlags("FRESEGCOM")
                                    TMP->(EEQ_CGRAFI := nTotCGRAFI,;
                                          EEQ_ADEDUZ := nTotADEDUZ,;
                                          EEQ_AREMET := nTotAREMET)
                                 EndIf

                                 // ** GFC - 10/08/05
                                 If lFinanciamento
                                    If Empty(TMP->EEQ_FI_TOT)
                                       nVlParAux := ABS(nVlAjuste)
                                    ElseIf TMP->EEQ_FI_TOT == "N"
                                       If Abs(nVlAjuste) >= TMP->EEQ_VL_PAR
                                          nVlParAux       := TMP->EEQ_VL_PAR
                                          TMP->EEQ_VL_PAR := 0
                                          TMP->EEQ_FI_TOT := "S"
                                       Else
                                          nVlParAux       := Abs(nVlAjuste)
                                          TMP->EEQ_VL_PAR -= Abs(nVlAjuste)
                                       EndIf
                                       //If (TMP->EEQ_VL - Abs(nVlAjuste)) - TMP->EEQ_VL_PAR < 0
                                       //   TMP->EEQ_VL_PAR := TMP->EEQ_VL
                                       //   nVlParAux := Abs((TMP->EEQ_VL - Abs(nVlAjuste)) - TMP->EEQ_VL_PAR)
                                       //EndIf
                                    Else
                                       nVlParAux := 0
                                    EndIf
                                 EndIf
                                 // **

                                 TMP->EEQ_VL += nVlAjuste

                                 AjustaComissao((nVlAjuste/(TMP->EEQ_VL-nVlAjuste)), "TMP")

                                 Exit

                           End Case

                        EndIf

                        TMP->(dbSkip())

                     End

                     /*
                     AMS - 08/03/2005. A condição abaixo não deve ser atendida, caso seja, o campo EEQ_VL está sem a validação para não
                                       permitir que seja informado valores menor que zero ou maior que o total das parcelas em aberto.
                     */
                     If TMP->(Eof())
                        EasyHelp(STR0211, STR0014) //"O valor informado não é válido para atualização das parcelas."###"Atenção"
                        lRet := .F.
                        Break
                     EndIf

                  EndIf

               EndIf

            EndIf

         EndIf

      EndIf

   EndIf

   AjustaComissao(((M->EEQ_VL-nVlOld)/nVlOld), "M")

   If EECFlags("FRESEGCOM") .And. TMP->EEQ_EVENT == EV_PRINC2
      nRecCGrafi += M->EEQ_CGRAFI
      nRecADeduz += M->EEQ_ADEDUZ
      nRecARemet += M->EEQ_AREMET
		nRecAcresc += M->EEQ_ACRESC
		nRecDecres += M->EEQ_DECRES
		nRecDescon += M->EEQ_DESCON

      aOrd:=SaveOrd("TMP")
      TMP->(DbSetOrder(4))
      If TMP->(DbSeek(EV_PRINC2))
         Do While TMP->(!Eof()) .And. TMP->EEQ_EVENT == EV_PRINC2
            If TMP->(RecNo()) <> nRecIni
               nRecCGrafi += TMP->EEQ_CGRAFI
               nRecADeduz += TMP->EEQ_ADEDUZ
               nRecARemet += TMP->EEQ_AREMET
					nRecAcresc += TMP->EEQ_ACRESC
					nRecDecres += TMP->EEQ_DECRES
					nRecDescon += TMP->EEQ_DESCON					
            EndIf
            TMP->(DbSkip())
         EndDo
      EndIf
      RestOrd(aOrd,.t.)

      If (nRecCGrafi <> nIniCGrafi) .Or. (nRecADeduz <> nIniADeduz) .Or. (nRecARemet <> nIniARemet) .Or. (nRecAcresc <> nIniAcresc) .Or. (nRecDecres <> nIniDecres) .Or. (nRecDescon <> nIniDescon)
         lTemDiferenca := .t.
      EndIf

      If lTemDiferenca
         aOrd:=SaveOrd("TMP")
         TMP->(DbSetOrder(4))
         If TMP->(AvSeekLast(EV_PRINC2))
            Do While TMP->(!Bof()) .And. TMP->EEQ_EVENT == EV_PRINC2
               If TMP->(RecNo()) <> nRecIni .Or. !Empty(TMP->EEQ_PGT)
                  TMP->EEQ_CGRAFI += Round(nIniCGrafi-nRecCGrafi,3)
                  TMP->EEQ_ADEDUZ += Round(nIniADeduz-nRecADeduz,3)
                  TMP->EEQ_AREMET += Round(nIniARemet-nRecARemet,3)
						TMP->EEQ_ACRESC += Round(nIniAcresc-nRecAcresc,3)
						TMP->EEQ_DECRES += Round(nIniDecres-nRecDecres,3)
						TMP->EEQ_DESCON += Round(nIniDescon-nRecDescon,3)
                  Af201SetVlFCam("TMP") // Atualiza o campo valor de fechamento cambial.
                  Exit
               EndIf
               TMP->(DbSkip(-1))
            EndDo
         EndIf
         RestOrd(aOrd,.t.)
      EndIf
   EndIf

   AF200SetOrigem() // Tratamentos para geração das informações exibidas na coluna 'Origem' do Browse.
   TMP->(dbGoTo(nRecno))

   // ** GFC - 10/08/05 - Acerta saldo para vinculação a contratos de financiamento
   If lFinanciamento .and. nVlAjuste < 0
      If M->EEQ_FI_TOT == "S"
         M->EEQ_VL_PAR := nVlParAux
         If M->EEQ_VL_PAR > 0
            M->EEQ_FI_TOT := "N"
         Else
            M->EEQ_FI_TOT := "S"
         EndIf
      ElseIf M->EEQ_FI_TOT == "N"
         M->EEQ_VL_PAR += nVlParAux
      Else
         nVlParAux += TMP->EEQ_VL
         If nVlParAux = M->EEQ_VL
            M->EEQ_FI_TOT := ""
            M->EEQ_VL_PAR := 0
         Else
            M->EEQ_VL_PAR := nVlParAux
            M->EEQ_FI_TOT := "N"
         EndIf
      EndIf
   EndIf
   // **

   // JPM - 24/08/05 - Atualizar o campo virtual de valor de fechamento cambial da parcela.
   Af201SetVlFCam()

End Sequence

Return lRet

/*
Funcao      : AF200ESTPARC()
Parametros  :
Retorno     :
Objetivos   : Estorno/Exclusao de Parcelas
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/07/2001 - 16:20.
Obs.        :
*/
*----------------------------*
Function AF200ESTPARC()
*----------------------------*
Local nRecno := TMP->(RecNo()), aOrd := SaveOrd("TMP"), nVlOld:=0
Local nPos, cOrigem, cParFinAux := TMP->EEQ_PARC
Local lParcPaiLiq:=.f. // Parcela pai liquidada.

// ** Variáveis para utilização no controle de Frete/Seguro e Comissão.
Local nCGrafi := 0, nAremet := 0, nADeduz := 0, z:=0
Local lTrataFilhas := .f., nRecArray:=0

//AMS - 05/08/2005.
Local nVlParc := 0
Local cEvento := ""
Local cCodEmp := ""
Local lParc_Found := .F.
Local lQbrMExt := .F.

// PLB 27/10/06
Local  lOrigem := .F.  ,;
       nRecOri := 0    ,;
       cParVin := ""

Local lExcParcSaldo := .F. //LBL - 14/11/2013
Local nPosDelAtu  //NCF - 23/03/2017
Local nRecAuxEEQ //THTS - 24/04/2017
Local nAcrescimo
Local nDecrescimo
Local nDesconto
Local cNumTit
Local cSeqBx
Local cBcoExt
Local cAgExt
Local cCCExt
Local dDtCE
Local dDtPGT
Local lModal

Begin Sequence

   If lOkEvent
      cEvento := TMP->EEQ_EVENT
      cCodEmp := TMP->EEQ_CODEMP
   EndIf

   If Tmp->(Eof()) .AND. Tmp->(Bof())
      HELP(" ",1,"AVG0000632") // "Não existem registros para a manutenção !"
      Break
   EndIf

   If !Empty(TMP->EEQ_PGT)
      nOldTipo:= EXC_DET
      HELP(" ",1,"AVG0005075") // "Parcela Com Câmbio Contratado !"
      AF200DetMan(VIS_DET)
      Break
   EndIf

   // ** PLB 27/10/06 - Impede exclusão caso parcela possua vinculação
   //If (nPos:=aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)})) > 0  ;
   //   .And. !Empty(aArrayEEQ[nPos,5])
   If (nPos:=aScan(aArrayEEQ,{|x| x[3] == TMP->EEQ_PARC })) > 0  .And.  !Empty(aArrayEEQ[nPos,5])
      EasyHelp(STR0226+AllTrim(aArrayEEQ[nPos,5]))  //"Não é possível efetuar a exclusão. Parcela está vinculada ao contrato de financiamento "
      AF200DetMan(VIS_DET)
      Break
   EndIf
   // **
   //THTS - 14/05/2020
   If IsIntEnable("001") .And. lParcLiq
      EasyHelp(STR0354, STR0016)//"Como foi acessada a rotina de estorno da liquidação, não será possível excluir parcelas até que a manutenção seja confirmada/cancelada."###"Aviso"
      Break
   EndIf

   If IsIntEnable("001") .And. EasyVerModal("TMP") .And. !Empty(TMP->EEQ_DTCE) .And. !IsQbrMExt("TMP")
      EasyHelp(STR0355, STR0016)//"Esta parcela foi desmembrada antes do crédito no exterior. Para que seja possível excluir, altere a parcela retirando a data de crédito no exterior."###"Aviso"
      Break
   EndIf

   If EECFlags("FRESEGCOM")
      // ** Verifica se as parcelas podem ser manutenciadas (Para o caso de parcelas de adiantamento).
      If !af201CanModify(EXC_DET)
         Break
      EndIf

      // ** Tratamentos especiais para exclusão de parcelas de desconto.
      If Left(Tmp->EEQ_EVENT,1) = "8"
         If lExecAuto .Or. MsgYesNo(STR0046+TMP->EEQ_PARC+" ?" ,STR0016) //###"Aviso" //"Confirma a exclusão da parcela "

            /* Realiza os tratamentos para distribuir o valor a ser adicionado em função da exclusão do
               desconto. */
            Af201DelDiscount()

            If !Empty(TMP->TMP_RECNO)
               aAdd(aDeletados,TMP->TMP_RECNO)
            EndIf

            TMP->(RecLock("TMP",.F.,.T.))
            TMP->(dbDelete())
            TMP->(msUnlock())
         EndIf
         Break
      EndIf
   EndIf

   If !lOkEvent
      lTrataFilhas := .f.
   Else
      /* Carrega todos os eventos que obrigatóriamente devem receber tratamentos na exclusão
         para atualizar as parcelas filhas. */
      aEventos := Af200ChkEvento()

      nPos := aScan(aEventos,TMP->EEQ_EVENT)
      If nPos <> 0
         // ** A parcela atual tem evento que deve ser tratada as parcelas filhas.
         lTrataFilhas := .t.

      Else  // ** Parcelas com eventos incluídos por usuário.
         lTrataFilhas := .f.

         /* Verifica se a parcela poderá ser excluída considerando o mv de configuração das dependências
            de eventos (MV_EVENT??) */

         If !Af201CanExclude("TMP")
            Break
         EndIf
      EndIf
   EndIf

   If lTrataFilhas

      IF ! EMPTY(TMP->EEQ_DTVC)
         Help(" ",1,"AVG0005227") //MSGINFO(STR0019,STR0014) //"Estorno Não Realizado. Parcela Com Variação Cambial !"###"Atenção"
         Break

      ELSEIF ! EMPTY(TMP->EEQ_FFC)
         HELP(" ",1,"AVG0005096") //MSGINFO("Estorno Não Realizado. Parcela Com FFC !","Atenção")
         Break

      // ** PLB 27/10/06 - Impede exclusão caso evento seja automático de câmbio
      ElseIf lOkEvent  .And.  (TMP->EEQ_EVENT == EV_PRINC2 .Or. !IsReceita(TMP->EEQ_EVENT)) .And.  Empty(TMP->EEQ_ORIGEM)  //Caso usuário tente excluir parcela de origem
         EasyHelp(STR0227,STR0016)  //"Não é possível efetuar a exclusão. Evento foi gerado automaticamente pelo câmbio."
         Break
      // **
      Endif

      lQbrMExt := IsQbrMExt("TMP")

      // Caso não haja parcela do mesmo título disponível para aglutinar o saldo excluído, o sistema não deverá permitir a exclusão!
      If AvFlags("EEC_LOGIX") .AND. TMP->EEQ_PARC <> TMP->EEQ_PARVIN .and. !lHasPrcAb()   //STR0350: "Exclusão desta parcela não pode ser realizada porque não existe outra parcela da qual esta tenha sido desmembrada"
         EasyHelp(STR0350 + If(lQbrMExt,STR0351,STR0352) + ", " + STR0353 ,STR0016)       //STR0351: " após o crédito no exterior e pendente de liquidação em banco nacional via contrato de fechamento de câmbio"
         Break                                                                            //STR0352: " e que possua liquidação em banco pendente em alguma modalidade (contrato de câmbio ou movimento em banco no exterior)"      
      EndIf                                                                               //STR0353: "para que tal parcela seja atualizada com o valor da parcela a ser excluída!"

      IF !lExecAuto .And. !MsgYesNo(STR0015+TMP->EEQ_PARC+" ?" ,STR0016) //"Confirma o estorno da parcela "###"Aviso"
         Break
      EndIf 

      FOR Z := 1 TO TMP->(FCOUNT())
          M->&(TMP->(FIELDNAME(Z))) := TMP->(FIELDGET(Z))
      NEXT

      // ** Controle para estorno de parcelas que possuem parcela de origem.
      cOrigem := TMP->EEQ_ORIGEM
      cParVin := TMP->EEQ_PARVIN
      cNumTit := TMP->EEQ_FINNUM
      cSeqBx  := TMP->EEQ_SEQBX
      cBcoExt := TMP->EEQ_BCOEXT
      cAgExt  := TMP->EEQ_AGCEXT
      cCCExt  := TMP->EEQ_CNTEXT
      dDtCE   := TMP->EEQ_DTCE
      dDtPGT  := TMP->EEQ_PGT
      lModal  := EasyVerModal("TMP")

      /*
      AMS - 18/10/2005. Localiza abaixo da parcela a ser excluida uma parcela em aberto para ser amortizada.
      */
      While TMP->(!Eof())

         If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
            TMP->(dbSkip())
            Loop
         EndIf

         If TMP->(Recno() <> nRecno .and. (EasyVerModal("TMP") .And. Empty(EEQ_DTCE) .Or. !EasyVerModal("TMP") .And. Empty(EEQ_PGT) .Or. CanExcPrEx(EasyVerModal("TMP"),lModal,cNumTit,cSeqBx,cBcoExt,cAgExt,cCCExt,cParVin,dDtCE)))  .And.  TMP->EEQ_PARVIN == cParVin  // PLB 27/10/06
            lParc_Found := .T.
            Exit
         EndIf

         TMP->(dbSkip())

      End

      /*
      Não encontrando, é verificada as parcelas acima da parcela a ser excluida.
      */
      If !lParc_Found

         TMP->(dbGoTo(nRecno))
         While TMP->(!Bof())

            If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
               TMP->(dbSkip(-1))
               Loop
            EndIf

            If TMP->(Recno() <> nRecno .And. ((lModal <> EasyVerModal("TMP")  .And. (Empty(EEQ_DTCE) .And. Empty(dDtCE) .And. Empty(EEQ_PGT) .And. Empty(dDtPGT))) .Or. (lModal == EasyVerModal("TMP")  .And. ( lModal .And. EEQ_DTCE == dDtCE .And. EEQ_PGT == dDtPGT .Or. !lModal .And. EEQ_PGT == dDtPGT))) .And.;
            ((EasyVerModal("TMP") .And. (EEQ_DTCE == dDtCE .Or. cOrigem == TMP->EEQ_PARC)) .Or. !EasyVerModal("TMP") .And. Empty(EEQ_PGT) .or. CanExcPrEx(EasyVerModal("TMP"),lModal,cNumTit,cSeqBx,cBcoExt,cAgExt,cCCExt,cParVin,dDtCE)))  .And.;
            (TMP->EEQ_PARVIN == cParVin  .Or.  Empty(TMP->EEQ_ORIGEM)) //AOM - 03/08/2010 - Verifica a origem para ser reconstituida na parcela correta.
               lParc_Found := .T.
               lOrigem     := .T.
               nRecOri     := TMP->( RecNo() )
               Exit
            EndIf

            TMP->(dbSkip(-1))

         End

      EndIf

	  //LBL - 14/11/2013
     If !(EECFlags("TIT_PARCELAS") .AND. EECFlags("ALT_EASYLINK") .OR. lQbrMExt) .And. !lParc_Found .And. (lExecAuto .Or. MsgYesNo(STR0340,STR0016)) //"Ao excluir a parcela, o valor será eliminado, pois todas as outras parcelas já foram liquidadas. Deseja continuar?"  #Aviso
         If Tmp->(DbSeek(cOrigem))
            lExcParcSaldo := .T.
            lParc_Found := .T.
            nRecOri     := TMP->( RecNo() )
         EndIf
         TMP->(dbGoTo(nRecno))
      EndIf

      /*
      TMP->(DbSetOrder(2))
      If TMP->(DbSeek(M->EEQ_PARC)) .And. !Empty(TMP->EEQ_PGT)
      */

      If !lParc_Found
         HELP(" ",1,"AVG0005077") //MsgInfo("Parcela de saldo já foi contratada! ","Aviso")
         Break

      ElseIf lParc_Found   // Parcela desmembrada

         If lOrigem  // PLB 27/10/06 - Caso for parcela Filha atribuíra o valor à parcela Pai
            TMP->(DBGOTO(NRECNO))  // Posiciona para armazenar os dados da parcela filha
         EndIf

         If lFinanciamento
            // ** PLB 27/10/06 - Verifica se a parcela de origem está vinculada
            If lOrigem
               TMP->( DBGoTo(nRecOri) )
               If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0
                  If !Empty(aArrayEEQ[nPos,5])
                     EasyHelp(STR0228+TMP->EEQ_PARC+STR0229+Alltrim(aArrayEEQ[nPos,5])+".")  //"Parcela não pode ser excluída pois a parcela de origem " ### " está vinculada ao contrato " ###
                     Break
                  EndIf
               EndIf
               TMP->( DBGoTo(nRecNo) )
            EndIf
            // **
            If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0
               If !Empty(aArrayEEQ[nPos,5])
                  Help(" ",1,"AVG0005228",,TMP->EEQ_PARC+ STR0045+Alltrim(aArrayEEQ[nPos,5])+".",2,21) //MsgInfo("Parcela não pode ser excluída pois a parcela desmembrada "+TMP->EEQ_PARC+" está vinculada ao contrato "+Alltrim(aArrayEEQ[nPos,5])+".") //" está vinculada ao contrato "
                  Break
               EndIf
               aAdd(aLogEEQ,{aArrayEEQ[nPos,1], aArrayEEQ[nPos,2], aArrayEEQ[nPos,3], aArrayEEQ[nPos,4], aArrayEEQ[nPos,5],;
                             aArrayEEQ[nPos,6], aArrayEEQ[nPos,7], aArrayEEQ[nPos,8], aArrayEEQ[nPos,9], aArrayEEQ[nPos,10],;
                             aArrayEEQ[nPos,11], aArrayEEQ[nPos,12], aArrayEEQ[nPos,13],;
                             If(lTemChave,aArrayEEQ[nPos,14],), If(lTemChave,aArrayEEQ[nPos,15],), If(lEFFTpMod,aArrayEEQ[nPos,21],),;
                             aArrayEEQ[nPos,22],aArrayEEQ[nPos,23]})

//                                     1                 2           3 4       5                 6                                      7                                    8                             9                          10
               aAdd(aExcVinculo,{aArrayEEQ[nPos,3],aArrayEEQ[nPos,5],1,0,aArrayEEQ[nPos,6],iif(lTemChave,aArrayEEQ[nPos,14],""),iif(lTemChave,aArrayEEQ[nPos,15],""),aArrayEEQ[nPos,16],If(lEFFTpMod,aArrayEEQ[nPos,21],),If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),)})
               aDel(aArrayEEQ,nPos)
               aSize(aArrayEEQ,LEN(aArrayEEQ)-1)
               nSeqArray -= 1
            EndIf
            If Empty(TMP->EEQ_FI_TOT)
               nVlParAux := TMP->EEQ_VL
            ElseIf TMP->EEQ_FI_TOT == "N"
               nVlParAux := TMP->EEQ_VL_PAR
            Else
               nVlParAux := 0
            EndIf
         EndIf

         //LBL - 14/11/2013
         If !lExcParcSaldo
	         nVlOld  := TMP->EEQ_VL
         Else
             nVlOld := 0
         EndIf
         cOrigem := TMP->EEQ_ORIGEM

         If EECFlags("FRESEGCOM")
            If TMP->EEQ_EVENT == EV_PRINC2
               If !lExcParcSaldo
                  nCGrafi := TMP->EEQ_CGRAFI
                  nAremet := TMP->EEQ_AREMET
                  nADeduz := TMP->EEQ_ADEDUZ
               EndIf
            EndIf
         EndIf

			If AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
				nAcrescimo	:= TMP->EEQ_ACRESC
				nDecrescimo	:= TMP->EEQ_DECRES
				nDesconto	:= TMP->EEQ_DESCON
			EndIf

         IF !Empty(TMP->TMP_RECNO)
            aAdd(aDeletados,TMP->TMP_RECNO)
         EndIf

         TMP->(DbDelete())

         If lOrigem  // PLB 27/10/06 - Caso for parcela Filha posiciona na parcela Pai
            TMP->( DBGoTo(nRecOri) )
         EndIf

      // ** Controle para estorno de parcelas filhas.
      /*ElseIf !Empty(cOrigem) // Verifica se a parcela é derivada de outra parcela.

         // ** Verifica se a parcela de origem possui liquidação.
         Tmp->(DbSetOrder(1))
         Tmp->(DbSeek(AvKey(cOrigem,"EEQ_ORIGEM")))

         If !Empty(Tmp->EEQ_PGT)
            lParcPaiLiq := .t.
         Else
            Tmp->(DbGoTo(nRecNo))
            nVlOld := TMP->EEQ_VL // Guarda valor para atualização das informações da parcela de origem.

            If EECFlags("FRESEGCOM")
               If TMP->EEQ_EVENT == EV_PRINC2
                  nCGrafi := TMP->EEQ_CGRAFI
                  nAremet := TMP->EEQ_AREMET
                  nADeduz := TMP->EEQ_ADEDUZ
               EndIf
            EndIf

            IF !Empty(TMP->TMP_RECNO)
               aAdd(aDeletados,TMP->TMP_RECNO)
            Endif
            TMP->(DbDelete())
         EndIf*/
      EndIf

      // ** Verifica se a parcela de origem já possui liquidação.
//      If !lParcPaiLiq
         // Posiciona na parcela de origem para atualização das informações.
//         Tmp->(DbSetOrder(1))
//         Tmp->(DbSeek(cOrigem))
//      Else
      If !lOrigem  // PLB 27/10/06
         TMP->(DBGOTO(NRECNO))
      EndIf

      If lFinanciamento
         cContAux := ''
         If (nPos := aScan(aArrayEEQ,{|x| x[3]==cParFinAux})) > 0 .and. !Empty(aArrayEEQ[nPos,3])
            cContAux := aArrayEEQ[nPos,5]
            cBanco   := aArrayEEQ[nPos,14]
            If lTemChave
               cPraca   := aArrayEEQ[nPos,15]
               If lEFFTpMod
                  cSeqCon := aArrayEEQ[nPos,21]
               EndIf
            EndIf
            cSeqAux  := aArrayEEQ[nPos,06]
            nRecArray:= aArrayEEQ[nPos,16]
            aArrayEEQ[nPos,5] := ""
            aArrayEEQ[nPos,6] := ""

            /*If (aScan(aExcVinculo,{|x| x[1]==cParFinAux .and.;
                x[2]+iif(lTemChave,x[6]+x[7],"")==cContAux+iif(lTemChave,cBanco+cPraca,"") .and.;
                x[5]==cSeqAux .and. x[3]==1})) = 0 .and. (aScan(aArrayEEQ,{|x| x[5]==cContAux })) = 0 */
            If (aScan(aExcVinculo,{|x| x[8]=nRecArray})) = 0 .and.;
            (aScan(aArrayEEQ,{|x| x[5]==cContAux })) = 0
               aAdd(aExcVinculo,{cParFinAux,cContAux,1,0,cSeqAux,cBanco,iif(lTemChave,cPraca,""),nRecArray,If(lEFFTpMod,cSeqCon,""),If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),)})
            EndIf
         EndIf
         If (nPos := aScan(aArrayEEQ,{|x| x[3]==TMP->EEQ_PARC})) > 0 .and. !Empty(aArrayEEQ[nPos,3]) .and.;
         !Empty(Alltrim(cContAux)) .and. aArrayEEQ[nPos,5] = cContAux
            aArrayEEQ[nPos,1] := TMP->EEQ_VL+nVlOld
         EndIf
         If TMP->EEQ_FI_TOT == "S"
            TMP->EEQ_VL_PAR := nVlParAux
            If TMP->EEQ_VL_PAR > 0
               TMP->EEQ_FI_TOT := "N"
            Else
               TMP->EEQ_FI_TOT := "S"
            EndIf
         ElseIf TMP->EEQ_FI_TOT == "N"
            TMP->EEQ_VL_PAR += nVlParAux
         Else
            nVlParAux += TMP->EEQ_VL
            If nVlParAux = TMP->EEQ_VL+nVlOld
               TMP->EEQ_FI_TOT := ""
               TMP->EEQ_VL_PAR := 0
            Else
               TMP->EEQ_VL_PAR := nVlParAux
               TMP->EEQ_FI_TOT := "N"
            EndIf
         EndIf
      EndIf

      // ** Atualiza o valor da parcela.
      TMP->EEQ_VL := TMP->EEQ_VL+nVlOld

      If EECFlags("FRESEGCOM")
         // ** Atribui os valores para cada tipo de comissão.
         If TMP->EEQ_EVENT == EV_PRINC2
            TMP->EEQ_CGRAFI += nCGrafi
            TMP->EEQ_ADEDUZ += nADeduz
            TMP->EEQ_AREMET += nAremet
            Af201SetVlFCam("TMP") // Atualiza o campo valor de fechamento cambial.
         EndIf
      EndIf
		If AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
			TMP->EEQ_ACRESC	+= nAcrescimo
			TMP->EEQ_DECRES	+= nDecrescimo
			TMP->EEQ_DESCON	+= nDesconto
			Af201SetVlFCam("TMP") // Atualiza o campo valor de fechamento cambial.
		EndIf
      
		TMP->EEQ_SOL    := AVCTOD("")
      TMP->EEQ_PGT    := AVCTOD("")
      //TMP->EEQ_DTCE   := AVCTOD("")  // By JPP - 18/10/2006 - 15:18 - Não apagar a data de crédito no exterior quando a parcela de câmbio for estornada.
      TMP->EEQ_DTNEGO := AVCTOD("")
      TMP->EEQ_EQVL   := 0
      TMP->EEQ_TX     := 0
      TMP->EEQ_DECAM  := SPACE(01)
      TMP->EEQ_NROP   := SPACE(20)
      TMP->EEQ_BANC   := SPACE(03)
      TMP->EEQ_AGEN   := SPACE(05)
      TMP->EEQ_NCON   := SPACE(10)
      TMP->EEQ_NOMEBC := SPACE(40)
      TMP->EEQ_RFBC   := SPACE(20)
      TMP->EEQ_CORR   := SPACE(15)

      If(!lFinanciamento,TMP->EEQ_DTCC   := AVCTOD(""),)
      If(!lFinanciamento,TMP->EEQ_DESCON := 0,)
      If(!lFinanciamento,TMP->EEQ_JRAA   := 0,)
      If(!lFinanciamento,TMP->EEQ_RESP   := SPACE(35),)
      If(!lFinanciamento,TMP->EEQ_CTDC   := SPACE(01),)
      If(!lFinanciamento,TMP->EEQ_VLCOR  := 0,)

      If !lFinanciamento .And. TMP->(FieldPos("EEQ_ADIA")) > 0
         TMP->EEQ_ADIA := 0
      EndIf
      
      //THTS - 28/04/2017 - atualiza o valor do campo Vl. Fecham. Cambio
      TMP->EEQ_VLFCAM:= AF200VLFCAM("TMP")//Round((TMP->EEQ_VL - TMP->EEQ_CGRAFI + If(lCpoAcrDcr,TMP->EEQ_ACRESC - TMP->EEQ_DECRES,0) ), 2)
    
      //THTS - 20/04/2017 - Trata a parcela atual para gerar um novo titulo quando integrado ao Logix via EECAF520
      nRecAuxEEQ := EEQ->(Recno())
      EEQ->(dbGoTo(TMP->TMP_RECNO))
      If  AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0 .And. EEQ->EEQ_EAIVRS == "2"
         aAdd(aDeletados,TMP->TMP_RECNO)
         TMP->EEQ_FINNUM := "" //Gera um novo titulo no Logix
         TMP->TMP_RECNO  := 0  //Gera uma nova parcela na EEQ.
      EndIf
      EEQ->(dbGoTo(nRecAuxEEQ))

      // Estorno da Contabilidade
      If lIntCont
         If lOkEstor .And. lContEst .And. !Empty(M->EEQ_NR_CON)
            //AAdd(aEstornaECF, {M->EEQ_PREEMB, M->EEQ_FASE, M->EEQ_NRINVOIC, If(!lParFin .Or. Empty(M->EEQ_PARFIN), M->EEQ_PARC, M->EEQ_PARFIN), M->EEQ_EVENT } )
            // PLB 23/08/07
            AAdd(aEstornaECF, {M->EEQ_PREEMB, M->EEQ_FASE, M->EEQ_NRINVOIC, M->EEQ_PARC, M->EEQ_EVENT } )
         Endif
      Endif

   Else
      IF lExecAuto .Or. MsgYesNo(STR0046+TMP->EEQ_PARC+" ?" ,STR0016) //###"Aviso" //"Confirma a exclusão da parcela "

         // ** AAF 03/02/05 - Verifica parcela a ser excluida do demurrage.
         If ( TMP->EEQ_EVENT == EV_DEM_PG .OR. TMP->EEQ_EVENT == EV_DEM_RC )
            If !DM100EstDem()
               Break
            Endif
         Endif
         // **
         // Estorno da Contabilidade
         If lIntCont
            If lOkEstor .And. lContEst .And. !Empty(TMP->EEQ_NR_CON)
               //AAdd(aEstornaECF, {TMP->EEQ_PREEMB, TMP->EEQ_FASE, TMP->EEQ_NRINVOIC, If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN), TMP->EEQ_EVENT } )
               // PLB 23/08/07
               AAdd(aEstornaECF, {TMP->EEQ_PREEMB, TMP->EEQ_FASE, TMP->EEQ_NRINVOIC, TMP->EEQ_PARC, TMP->EEQ_EVENT } )
            Endif
         Endif

         IF !Empty(TMP->TMP_RECNO)
            aAdd(aDeletados,TMP->TMP_RECNO)
         Endif
         //Tratamentos para quando não houver o campo EEQ_PARVIN. É limpado o campo origem das parcelas que foram
         if !lParVin                 									 //originadas da parcela que sera deletada
            // JPM
            aOrd   := SaveOrd("TMP")
            cParc := TMP->EEQ_PARC
            nRec2 := 0
            TMP->(DbSetOrder(2)) // chave = origem
            If TMP->(Dbseek(cParc))
               While tmp->(!eof()) .and. cParc == TMP->EEQ_ORIGEM
                  TMP->(DbSkip())         // como o EEQ_ORIGEM é a chave de pesquisa, não se pode limpá-lo, pois
                  nRec2 := TMP->(RecNo()) // o mesmo seria reposicionado. Então pega o recno do próximo registro,
                  TMP->(DbSkip(-1))       // limpa o EEQ_ORIGEM e posiciona no registro que seria o próximo
                  TMP->EEQ_ORIGEM := ""
                  TMP->(DbGoTo(nRec2))
               EndDo
            Endif
            RestOrd(aOrd,.t.)
         Endif

         /*
         AMS - 05/08/2005. Controle para acrescer no valor da parcela mais proxima em aberto, o valor do parcela
                           excluida.
         */
         TMP->(dbSetOrder(3))
         TMP->(dbGoTo(nRecno))

         nVlParc := TMP->EEQ_VL

         TMP->(dbSkip(-1))

         /*
         Procura acima da parcela a ser excluida, uma parcela em aberto. Encontrando, a mesma terá no valor um acrescimo
         do valor da parcela a ser excluida.
         */
         While TMP->(!Bof())

            If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
               TMP->(dbSkip(-1))
               Loop
            EndIf

            If Empty(TMP->EEQ_PGT)
               TMP->EEQ_VL += nVlParc
               AjustaComissao((nVlParc/(TMP->EEQ_VL-nVlParc)), "TMP")
               Exit
            EndIf

            TMP->(dbSkip(-1))

         End

         If TMP->(Bof())

            TMP->(dbGoTo(nRecno))
            TMP->(dbSkip())

            /*
            Procura abaixo da parcela a ser excluida, uma parcela em aberto. Encontrando, a mesma terá no valor um acrescimo
            do valor da parcela a ser excluida.
            */
            While TMP->(!Eof())

               If lOkEvent .and. (TMP->EEQ_EVENT <> cEvento .or. TMP->EEQ_CODEMP <> cCodEmp)
                  TMP->(dbSkip())
                  Loop
               EndIf

               If Empty(TMP->EEQ_PGT)
                  TMP->EEQ_VL += nVlParc
                  AjustaComissao((nVlParc/(TMP->EEQ_VL-nVlParc)), "TMP")
                  Exit
               EndIf

               TMP->(dbSkip())

            End

            /*
            Não encontrando uma parcela em aberto, acima ou abaixo da parcela a ser excluida é apresentada mensagem, confirmando
            a exclusão da parcela sem acrescer seu valor em outra parcela.
            */
            If TMP->(Eof())
               //MsgInfo(STR0212, STR0014) //"O valor da parcela excluida não será acrescido em uma outra parcela, por não existir parcelas de cambio em aberto com o mesmo evento."###"Atenção"
               easyhelp(STR0212, STR0014)
            EndIf

         EndIf

         TMP->(dbGoTo(nRecno))
         TMP->(dbDelete())

      Endif
   EndIf

   If Avflags("ADTFOREAI")    //NCF - 23/03/2017 - Tratamentos para deletar na EEQ via botão escolha da pergunta.
      GrvAF200Mn()
      aDeletados := {}
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return(Nil)

*---------------------------------*
FUNCTION AF200REL(cALIAS,nREG,nOPC)
*---------------------------------*

PRIVATE aCAMPOS := ARRAY(EEQ->(FCOUNT())),;
        aHeader[0],aTela[0][0],aGets[0],;
        cSEQREL
IF EasyEntryPoint("EECPRL15")
   ExecBlock("EECPRL15",.F.,.F.,{cAlias,nReg,nOpc})
Else
   EECPRL15("EECPRL15")
Endif
RETURN(NIL)

*-------------------------------*
Function AF200EstCtb(aEst, aInc)
*-------------------------------*
Local cPreemb, cFase, cInvoice, cParc, cEvento, nVariacao := 0, aDeletaECF := {}, z, x, h, cMes, cAno, nTaxa := 0
Local dData_Fim := CTOD(' / / '), dData := CTOD(' / / ')
Local cMesProc  := AllTrim(EasyGParam("MV_MESPEXP",,StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4)))
cFilECF:=xFilial("ECF")
ECF->(DbSetOrder(9))

For h:=1 to Len(aInc)

    // Estorna os eventos de estorno caso ainda não sejam contabilizados.
    cPreemb    := aInc[h,1]
    cFase      := aInc[h,2]
    cInvoice   := AvKey(aInc[h,3], "ECF_INVEXP")
    cParc      := AvKey(aInc[h,4], "ECF_SEQ")
    cEvento    := If(aInc[h,5] = EV_PRINC2, '607', aInc[h,5])
    nTaxa      := aInc[h,6]
    dData      := aInc[h,7]
    lDeleta    := .F.
    aDeletaECF := {}

    ECF->(DbSeek(cFilECF+cTpModu+"EX"+cPreemb+cFase+cInvoice+cParc))

    Do While ECF->(!Eof()) .And. ECF->ECF_ORIGEM = 'EX' .And. ECF->ECF_FILIAL = cFilECF .And. ECF->ECF_PREEMB = cPreemb .And.;
             ECF->ECF_FASE = cFase .And. ECF->ECF_INVEXP = cInvoice .And. ECF->ECF_SEQ = cParc .and. Eval(bTPMODUECF)

       If Empty(ECF->ECF_NR_CON) .And. (ECF->ECF_ID_CAM = '999' .Or. ECF->ECF_LINK = '999')

          If (ECF->ECF_LINK = cEvento .Or. ECF->ECF_LINK = '999') .And. (ECF->ECF_PARIDA = nTaxa .And. ECF->ECF_DTCONV = dData)
             lDeleta := .T.
          Endif

          Aadd( aDeletaECF, ECF->(Recno()) )
       Endif

       ECF->(DbSkip())
    Enddo

    If lDeleta
       For z := 1 to Len(aDeletaECF)
          ECF->(DbGoto(aDeletaECF[z]))
          ECF->(RecLock("ECF",.F.))
   		  ECF->(DbDelete())
   		  ECF->(MsUnlock())
       Next
    Endif
Next

For h:=1 to Len(aEst)

    cPreemb    := aEst[h,1]
    cFase      := aEst[h,2]
    cInvoice   := AvKey(aEst[h,3], "ECF_INVEXP")
    cParc      := AvKey(aEst[h,4], "ECF_SEQ")
    cEvento    := If(aEst[h,5] = EV_PRINC2, '607', aEst[h,5])
    aDeletaECF := {}

    ECF->(DbSeek(cFilECF+cTpModu+"EX"+cPreemb+cFase+cInvoice+cParc))

    Do While ECF->(!Eof()) .And. ECF->ECF_ORIGEM = 'EX' .And. ECF->ECF_FILIAL = cFilECF .And. ECF->ECF_PREEMB = cPreemb .And.;
             ECF->ECF_FASE = cFase .And. ECF->ECF_INVEXP = cInvoice .And. ECF->ECF_SEQ = cParc .and. Eval(bTPMODUECF)

       Aadd( aDeletaECF, ECF->(Recno()) )

       ECF->(DbSkip())
    Enddo

    For z := 1 to Len(aDeletaECF)

     Begin Transaction

        ECF->(DbGoto(aDeletaECF[z]))

        FOR x := 1 TO ECF->(FCount())
            M->&(ECF->(FIELDNAME(x))) := ECF->(FIELDGET(x))
   		NEXT

   		// Não deleta pagamento apenas gera evento de estorno
   		If ECF->ECF_ID_CAM # '607' .And. Left(ECF->ECF_ID_CAM,1) #  "5"
           ECF->(RecLock("ECF",.F.))
           ECF->(DbDelete())
   		   ECF->(MsUnlock())
        Endif

   		// Grava Registro de Estorno
        ECF->(RecLock("ECF",.T.))
   		AvReplace("M","ECF")
        ECF->ECF_ID_CAM := EV_ESTORNO
        ECF->ECF_NR_CON := Space(04)
        ECF->ECF_DTCONT := dDataBase
        ECF->ECF_DTCONV := M->ECF_DTCONT
   		ECF->(MsUnlock())

   		// Gera V.C caso seja estorna a liquidação
   		If M->ECF_ID_CAM $ '607/605/602'

   		   cMes  := Substr(cMesProc,1,2)
		   cAno  := Substr(cMesProc,3,4)
		   dData_Fim := AVCTOD("01/"+cMes+"/"+cAno) - 1

   		   If M->ECF_ID_CAM == '607'
   			  cEvento2 := '101'
   		   Else
   			  cEvento2 := M->ECF_ID_CAM
   		   Endif

           EC6->(DbSetOrder(6))
           EC6->(DbSeek(xFilial("EC6")+If(lTemEC6New,"EXPORT","")+cEvento2))
           cTX := EC6->EC6_TXCV
           EC6->(DbSetOrder(1))

		   nTaxa     := BuscaTaxa(M->ECF_MOEDA, dData_Fim,,,,,cTX)
   		   nVariacao := (M->ECF_VL_MOE * nTaxa) - (M->ECF_VL_MOE * M->ECF_FLUTUA)

   		   If M->ECF_ID_CAM $ '607'
   			  cEvento := If(nVariacao > 0, "582", "583")
   		   Elseif M->ECF_ID_CAM $ '605'
   			  cEvento := If(nVariacao > 0, "590", "591")
   		   Elseif M->ECF_ID_CAM $ '602'
   		      cEvento := If(nVariacao > 0, "594", "595")
   		   Endif

   		   // Grava V.C
   		   If nVariacao <> 0
        	  ECF->(RecLock("ECF",.T.))
   			  AvReplace("M","ECF")
   			  ECF->ECF_ID_CAM := cEvento
   			  ECF->ECF_LINK   := '999'
   			  ECF->ECF_VALOR  := nVariacao
   			  ECF->ECF_VL_MOE := M->ECF_VL_MOE
   			  ECF->ECF_PARIDA := nTaxa
   			  ECF->ECF_FLUTUA := M->ECF_FLUTUA
   			  ECF->ECF_DESCR  := STR0076 + If(nVariacao > 0, "(CR)", "(DB)") //"V.C. CAMBIAL AJUSTE "
              ECF->ECF_NR_CON := Space(04)
              ECF->ECF_DTCONT := dDataBase
              ECF->(MsUnlock())
           Endif
   		Endif
   	 End Transaction
    Next
Next

ECF->(DbSetOrder(1))

Return NIL

/*
Funcao      : AF200CotaCam(nP_OPC)
Parametros  : nP_OPC.
Retorno     : .t./.f.
Objetivos   : Manutencao de Cotaçao e Fechamento de Cambio.
Autor       : Jeferson Barros Jr.
Data/Hora   : 10/01/2003 14:32.
Revisao     :
Obs.        :
*/
*---------------------------*
Function AF200CotaCam(nP_OPC)
*---------------------------*
Local cArq, cPictDt:="  /  /  ", cPictVl := "@E 999,999,999,999.99", cTit, cProcesso, cParcela
Local aButtons := {}, aCpos := {}, aOrd:=SaveOrd({"EEC","EXG"}), aSemSx3:={}
Local bOk := {|| oDlg:End()} , bCancel := {|| oDlg:End()}
Local dDtVct := AvCTod(""), dDtPgt := AvCTod("")
Local nVlParc := 0, nTaxa :=0
Local oDlg, oMsSelect
Local lRet:= .t.

Begin Sequence

  // ** Definição dos botoes da Enchoice Bar.
  aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/, {|| AF200CotMan(VIS_DET)},STR0003}) //"Visualizar"

  If Empty(TMP->EEQ_PGT)   // ** Verifica se a parcela não está liquidada.
     aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/, {|| AF200CotMan(INC_DET,oMsSelect)},STR0005}) //"Incluir"
     aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/   , {|| AF200CotMan(ALT_DET,oMsSelect)},STR0052}) //"Alterar"
     aAdd(aButtons,{"EXCLUIR"  , {|| AF200CotMan(EXC_DET,oMsSelect)},STR0053}) //"Excluir"
     aAdd(aButtons,{"LIQCHECK" , {|| If(AF200LiqParc(nP_OPC),Eval(bOk),Nil)},STR0054}) //"Liquidar"
  EndIf

  // ** Colunas para o Browse ...
  aCpos := {{{|| AllTrim(Work_Cot->EXG_BANC)+"-"+AllTrim(Work_Cot->EXG_NOMEBC)},"",STR0055+Space(50)},; //"Banco"
            {{|| Work_Cot->EXG_AGEN} ,"",STR0056},; //"Agencia"
            {{|| Work_Cot->EXG_NCON} ,"",STR0057},; //"Nro.Conta"
            {{|| AllTrim(Transf(Work_Cot->EXG_TX,AVSX3("EXG_TX",AV_PICTURE)))} ,"",STR0058},; //"Taxa"
            {{|| AllTrim(Transf(Work_Cot->EXG_DSPBCO,AVSX3("EXG_DSPBCO",AV_PICTURE)))} ,"",STR0059},; //"Desp.Bco."
            {{|| AllTrim(Work_Cot->EXG_CORR)+"-"+AllTrim(Posicione("SY5",1,xFilial("SY5")+Work_Cot->EXG_CORR,"Y5_NOME"))} ,"",STR0060+Space(50)},; //"Corretor"
            {{|| AllTrim(Transf(Work_Cot->EXG_VLCOR,AVSX3("EXG_VLCOR",AV_PICTURE)))} ,"",STR0061+Space(200)}} //"Vl.Corretagem"

  Work_Cot->(DbSetFilter({||EXG_PARC==TMP->EEQ_PARC},"EXG_PARC=='"+TMP->EEQ_PARC+"'"))
  Work_Cot->(DbGoTop())

  // ** Set das variáveis...
  cTit  := STR0062 //"Cotação de Taxas Para Fechamento de Câmbio. "
  aTela := {} ;  aGets := {}
  cProcesso := TMP->EEQ_PREEMB
  cParcela  := TMP->EEQ_PARC
  nVlParc   := TMP->EEQ_VL
  dDtVct    := TMP->EEQ_VCT
  dDtPgt    := TMP->EEQ_PGT
  nTaxa     := TMP->EEQ_TX

  DEFINE MSDIALOG oDlg TITLE cTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

     @ 15,007 Say STR0063 Size 80,07 PIXEL Of oDlg //"Processo "
     @ 15,140 Say STR0064 Size 80,07 PIXEL Of oDlg //"Parcela  "
     @ 15,280 Say STR0065+AllTrim(EEC->EEC_MOEDA)+")" Size 80,07 PIXEL Of oDlg //"Valor ("

     @ 26,007 Say STR0066 Size 80,07 PIXEL Of oDlg //"Vencto  "
     @ 26,140 Say STR0067 Size 80,07 PIXEL Of oDlg //"Pagto   "
     @ 26,280 Say STR0068 Size 80,07 PIXEL Of oDlg //"Taxa    "

     @ 15,050 MSGET cProcesso PICTURE AVSX3("EEC_PREEMB",AV_PICTURE) Size 050,07  Pixel Of oDlg When .f.
     @ 15,190 MSGET cParcela  PICTURE AVSX3("EEQ_PARC",AV_PICTURE)   Size 050,07  Pixel Of oDlg When .f.
     @ 15,330 MSGET nVlParc   PICTURE AVSX3("EEQ_VL",AV_PICTURE)     Size 050,07  Pixel Of oDlg When .f.

     @ 26,050 MSGET dDtVct    PICTURE AVSX3("EEQ_VCT",AV_PICTURE)    Size 050,07  Pixel Of oDlg When .f.
     @ 26,190 MSGET dDtPgt    PICTURE AVSX3("EEQ_PGT",AV_PICTURE)    Size 050,07  Pixel Of oDlg When .f.
     @ 26,330 MSGET nTaxa     PICTURE AVSX3("EEQ_TX",AV_PICTURE)     Size 050,07  Pixel Of oDlg When .f.

     aPos := PosDlgDown(oDlg)
     aPos[1] := 40

    // CRF - 22/11/2010 10:23
     aCpos := AddCpoUser(aCpos,"EXG","5","Work_Cot")


     oMsSelect := MsSelect():New("Work_Cot",,,aCpos,,,aPos)
     oMsSelect:bAval := {|| AF200CotMan(VIS_DET)}

  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AF200CotMan(nTipo,oMsSelect)
Parametros  : nTipo  := VIS_DET/INC_DET/ALT_DET/EXC_DET
              oMsSelect := Objeto para refresh.
Retorno     : .T.
Objetivos   : Manutencao de Cotação de fechamento de câmbio.
Autor       : Jeferson Barros Jr.
Data/Hora   : 10/01/03 16:34.
Obs.        :
*/
*------------------------------------------*
Static Function AF200CotMan(nTipo,oMsSelect)
*------------------------------------------*
Local bOk:={|| If(AF200ValCot(nTipo,nReg),(nOpcao := 1,oDlg:End()),Nil)}, bCancel:={|| oDlg:End()}
Local aEnchoice := {}, aPos := {}, aSemSx3 := {}, aButtons:={}
Local cTit := STR0069 //"Taxas de Câmbio."
Local nOpcao := 0, nReg, i:=0
Local lRet := .t.

Begin Sequence

   IF nTipo != INC_DET .And. Work_Cot->(Eof()) .AND. Work_Cot->(Bof())
      HELP(" ",1,"AVG0000632") // "Não existem registros para a manutenção !"
      Break
   EndIf

   // ** Campos da enchoice.
   aEnchoice:={"EXG_PREEMB","EXG_PARC","EXG_TX","EXG_CORR","EXG_CRNO" ,"EXG_VLCOR",;
               "EXG_BANC","EXG_NOMEBC","EXG_AGEN","EXG_NCON","EXG_DSPBCO", "EXG_DSPCON","EXG_RFBC"}

   If nTipo == INC_DET
      For i := 1 TO EXG->(FCount())
         M->&(EXG->(FieldName(i))) := CriaVar(EXG->(FieldName(i)))
      Next
      M->EXG_PREEMB := TMP->EEQ_PREEMB
      M->EXG_PARC   := TMP->EEQ_PARC
   Else
      For i := 1 TO Work_Cot->(FCount())
         M->&(Work_Cot->(FieldName(i))) := Work_Cot->(FieldGet(i))
      Next
   EndIf

   nReg := Work_Cot->(RecNo())

   DEFINE MSDIALOG oDlg TITLE cTit FROM 9,0 TO 35,80 OF oMainWnd
      aPos := PosDlg(oDlg)
      EnChoice("EXG",,IF(nTipo=INC_DET,3,4),,,,aEnchoice,aPos,IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

   If nOpcao = 1
      If nTipo == INC_DET
         Work_Cot->(DbAppend())
         nReg := Work_Cot->(RecNo())
         AvReplace("M","Work_Cot")
      ElseIf nTipo == ALT_DET
         AvReplace("M","Work_Cot")
      EndIf

      If nTipo <> VIS_DET
         oMsSelect:oBrowse:Refresh()
         Work_Cot->(DbGoTop())
      EndIf
   EndIf

End Sequence

Return lRet
/*
Funcao      : AF200RecCot().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Gravar Cotações de Câmbio.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/01/2003 - 11:41.
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function AF200RecCot()
*---------------------------*
Local lRet := .t., i:=0

Begin Sequence

   Work_Cot->(DbClearFilter())
   Work_Cot->(DbGoTop())

   Do While Work_Cot->(!Eof())
      If Work_Cot->RECNO == 0
         EXG->(RecLock("EXG",.t.))
         EXG->EXG_FILIAL := xFilial("EXG")
         AvReplace("Work_Cot","EXG")
      Else
         EXG->(dbGoTo(Work_Cot->RECNO))
         EXG->(RecLock("EXG",.f.))
         AvReplace("Work_Cot","EXG")
      EndIf

      Work_Cot->(DbSkip())
   EndDo

   For i:=1 To Len(aDelCotCam)
      EXG->(DbGoTo(aDelCotCam[i]))
      EXG->(RecLock("EXG",.f.))
      EXG->(DbDelete())
      EXG->(MSUnlock())
   Next

End Sequence

Return lRet

/*
Funcao      : AF200ValCot(nTipo,nReg).
Parametros  : nTipo => Opcao
              nReg  => Nro. Registro.
Retorno     : .t./.f.
Objetivos   : Efetuar validação do registro para exclusão.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/01/03 13:41.
Obs.        :
*/
*-------------------------------------*
Static Function AF200ValCot(nTipo,nReg)
*-------------------------------------*
Local lRet:=.t., nRecNo:=0

Begin Sequence

   If Str(nTipo,1) $ Str(INC_DET,1)+"/"+Str(ALT_DET,1)
      If !Obrigatorio(aGets,aTela)
         lRet := .f.
         Break
      Endif

      nRecNo:= Work_Cot->(Recno())

      If Work_Cot->(DbSeek(M->EXG_PREEMB+M->EXG_PARC+M->EXG_BANC+M->EXG_CORR))
         If nTipo == INC_DET
            EasyHelp(STR0070,STR0014) //"Já existe cotação de câmbio para este banco e corretora."###"Atenção"
            lRet:=.f.
            Break
         Else
            If Work_Cot->(RecNO()) <> nRecNo
               EasyHelp(STR0070,STR0014) //"Já existe cotação de câmbio para este banco e corretora."###"Atenção"
               lRet:=.f.
               Break
            EndIf
         EndIf
      EndIf

   ElseIf nTipo == EXC_DET

      If MsgNoYes(STR0071,STR0016) //"Confirma exclusão do Registro Atual ?"###"Aviso"
         Work_Cot->(DbGoTo(nReg))

         If Work_Cot->RECNO != 0
            aAdd(aDelCotCam,Work_Cot->RECNO)
         EndIf

         Work_Cot->(DbDelete())
         Work_Cot->(DbGoTop())
      Else
         lRet := .F.
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : AF200LiqParc(nP_OPC).
Parametros  : nP_OPC
Retorno     : .t./.f.
Objetivos   : Efetuar liquidacao da parcela com base na cotação selecionada.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/01/03 15:41.
Obs.        :
*/
*-----------------------------------*
Static Function AF200LiqParc(nP_OPC)
*-----------------------------------*
Local lRet:=.f.

Begin Sequence

   If Work_Cot->(Eof()) .AND. Work_Cot->(Bof())
      Help(" ",1,"AVG0000632") // "Não existem registros para a manutenção !"
      Break
   EndIf

   AF200DetMan(LIQ_DET,.t.)

   If !Empty(TMP->EEQ_PGT)
      lRet:=.t.
   EndIf

End Sequence

Return lRet

/*
Funcao      : AF200SetOrigem().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Setar a origem das parcelas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/03/03 08:18.
Obs.        :
*/
*------------------------------*
Static Function AF200SetOrigem()
*------------------------------*
Local aOrd:=SaveOrd("TMP"), nFilhas:=1
Local cOldParc, cSeqParc := " ABCDEFGHIJKLMNOPQRSTUWXYZ"

Begin Sequence
   Tmp->(DbSetOrder(3))
   Tmp->(DbGoTop())

   cOldParc := TMP->EEQ_PARVIN
   Do While Tmp->(!Eof())
      TMP->TMP_PARC := TMP->EEQ_PARVIN+SubStr(cSeqParc,nFilhas,1)
      nFilhas ++

      Tmp->(DbSkip())

      If cOldParc <> TMP->EEQ_PARVIN
         nFilhas := 1
         cOldParc := TMP->EEQ_PARVIN
      EndIf
   EndDo

End Sequence

RestOrd(aOrd)

Return Nil

/*
Funcao      : AF200ValCambio().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Validação final da manutenção de cambio.
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/01/04 16:11.
Obs.        :
*/
*------------------------------*
Static Function AF200ValCambio()
*------------------------------*
Local lRet:=.t.
Local aOrdTMP := SaveOrd("TMP")  //NCF - 23/03/2017
Begin Sequence

   /* Realiza as validações com relação aos tratamentos para frete, seguro e comissão na fase de câmbio.
      - Valida a vinculação dos valores de comissão. */

   If EECFlags("FRESEGCOM")
      If !Af201VldSld()
         lRet:=.f.
         Break
      EndIf
   EndIf

   If EasyEntryPoint("EECAF200")
      xRet := ExecBlock("EECAF200",.F.,.F.,"PE_VLDFIM")
      If ValType(xRet) = "L"
         lRet := xRet
      EndIf
   EndIf

End Sequence
RestOrd(aOrdTMP,.T.)            //NCF - 23/03/2017
Return lRet

/*
Funcao      : AF200LoadCpo().
Parametros  : cCampo - Nome do campo a ser carregado.
Retorno     : xRet - Retorno que será gravado no contra dominio do gatilho.
Objetivos   : Carregar campos. (Chamada do SX7).
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/08/04 10:54.
Obs.        :
*/
*---------------------------*
Function AF200LoadCpo(cCampo,cOrdem)
*---------------------------*
Local xRet

Begin Sequence

   cCampo := AllTrim(Upper(cCampo))

   If Type("M->"+cCampo) <> "U" .And. cOrdem == nil
      xRet := &("M->"+cCampo)
      Break
   EndIf

   Do Case
      Case cCampo == "EEQ_MOEDA"

         If Type("lIsCambio") = "U"
            xRet := CriaVar("EEQ_MOEDA")
            Break
         EndIf

         xRet := M->EEC_MOEDA

      Case cCampo == "EEQ_TIPO"
         xRet := If(IsReceita(M->EEQ_EVENT),;
                                        "R",; // Cambio a Receber.
                                        "P")  // Cambio a Pagar.

      Case cCampo $ "EEQ_FORN/EEQ_FOLOJA"

         If Type("lIsCambio") == "U"
            xRet := CriaVar(cCampo)
            Break
         EndIf

         xRet := CriaVar(cCampo)
         If IsReceita(M->EEQ_EVENT)
            xRet := If(cCampo=="EEQ_FORN",M->EEQ_FORN,M->EEQ_FOLOJA)
         EndIf

      Case cCampo $ "EEQ_IMPORT/EEQ_IMLOJA"

         If Type("lIsCambio") == "U"
            xRet := CriaVar(cCampo)
            Break
         EndIf


         xRet := CriaVar(cCampo)
         If IsReceita(M->EEQ_EVENT)
            xRet := If(cCampo=="EEQ_IMPORT",M->EEQ_IMPORT,M->EEQ_IMLOJA)
         EndIf

      //FSY - Adicionado dois case para limpar os campos EEQ_DESFOR e EEQ_DESIMP.
      Case cCampo == "EEQ_DESFOR"
         If Type("lIsCambio") = "U"
            xRet := CriaVar("EEQ_DESFOR")
            Break
         EndIf
         xRet := M->EEQ_DESFOR

      Case cCampo == "EEQ_DESIMP"
         If Type("lIsCambio") = "U"
            xRet := CriaVar("EEQ_DESIMP")
            Break
         EndIf
         xRet := M->EEQ_DESIMP


      Case cCampo $ "EEQ_CODEMP"
         xRet := M->EEQ_CODEMP

         If IsReceita(M->EEQ_EVENT)
            xRet:= CriaVar("EEQ_CODEMP")
         EndIf

      Case cCampo == "EEQ_PARI"
         /* Verifica se o gatilho foi disparado a partir da rotina de cambio. No caso
            do gatilho ser chamado a partir da rotina de pagamento antecipado, a regra
            irá sempre retornar '1' para o contra dominio. */

         If Type("lIsCambio") = "U"
            xRet := 1
            Break
         EndIf

         xRet := M->EEQ_PARI

         If M->EEC_MOEDA == M->EEQ_MOEDA
            xRet := 1
         Else
            If M->EEQ_PARI <= 1
               xRet := 0
            EndIf
         EndIf

      Case cCampo == "CAMBEXT"
         If EasyVerModal("M")
            cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV")
            M->EEQ_MOEBCO:= Posicione("SA6", 1, xFilial("SA6") + AvKey(M->EEQ_BCOEXT,"A6_COD") + AvKey(M->EEQ_AGCEXT,"A6_AGENCIA") + AvKey(M->EEQ_CNTEXT,"A6_NUMCON") , "A6_MOEEASY")
            M->EEQ_PRINBC:= Round( BuscaTaxa(M->EEQ_MOEDA, If(Empty(M->EEQ_DTCE), dDataBase, M->EEQ_DTCE),,,,,cC6_TXCV) / BuscaTaxa(M->EEQ_MOEBCO, If(Empty(M->EEQ_DTCE), dDataBase, M->EEQ_DTCE),,,,,cC6_TXCV) , TAMSX3(If(IntegFIN(cModulo),"E1_TXMOEDA","EEQ_PRINBC"))[2] )
            If M->EEQ_MOEBCO == M->EEQ_MOEDA
               M->EEQ_VLMBCO:= M->EEQ_VLFCAM
            Else
               M->EEQ_VLMBCO:= M->EEQ_VLFCAM * M->EEQ_PRINBC
            EndIf
            xRet:= M->EEQ_MOEBCO
         Else
            xRet:= ""
         EndIf
      Case cCampo == "EEQ_PGT"
            Do Case
            Case cOrdem == "001"
                 xRet := BUSCATAXA(M->EEQ_MOEDA,M->EEQ_PGT,,,,,Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV"))  
            Case cOrdem == "002"
                 xRet := BuscaTaxa(Posicione("EXJ",1,xFilial("EXJ")+M->EEQ_IMPORT+M->EEQ_IMLOJA,"EXJ_MOEDA"),M->EEQ_PGT,,,,,Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV"))
            Case cOrdem == "003"     
                 xRet := BUSCATAXA(EE7->EE7_MOEDA,M->EEQ_PGT,,,,,Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV"))  
            EndCase     
   EndCase

End Sequence

Return xRet

/*
Funcao      : IsReceita(cEvento,cModulo).
Parametros  : cEvento - Código do evento a ser analisado.
              cModulo - Módulo para que o evento deverá ser analisado.
Retorno     : .t. -> Evento do tipo "Receita".
              .f. -> Evento do tipo "Despesa".
Objetivos   : Verificar no EC6 se o evento é do tipo Receita ou do tipo Despesa.
Autor       : Jeferson Barros Jr.
Data/Hora   : 23/08/04 10:54.
Obs.        :
*/
*---------------------------------*
Function IsReceita(cEvento,cModulo)
*---------------------------------*
Local lRet:=.f., aOrd:=SaveOrd({"EC6"})

Default cModulo := "EXPORT"

Begin Sequence

   // BAK - 10/10/2012
   If IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSRS403") .Or. IsInCallStack("ESSPS401") .Or. IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100") .Or. (IsInCallStack("EECAF900") .And. EEQ->EEQ_SOURCE = "ESS" .And. cEvento $ "001|501")
      cModulo := "SISCSV"
   EndIf

   cEvento := AvKey(cEvento,"EC6_ID_CAM")
   cModulo := AvKey(cModulo,"EC6_TPMODU")

   EC6->(DbSetOrder(1))
   If EC6->(DbSeek(xFilial("EC6")+cModulo+cEvento))
      lRet := (EC6->EC6_RECDES == "1") // EC6_RECDES = 1 (Receita)/ EC6_RECDES = 2 (Despesa)
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Af200CanInsert().
Parametros  : Nenhum.
Retorno     : .t. -> Evento está ok.
              .f. -> O evento não poderá ser incluído.
Objetivos   : Aprovar/Reprovar inclusão de evento.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/08/04 16:36.
Obs.        :
*/
*-----------------------*
Function Af200CanInsert()
*-----------------------*
Local cEvento, cConteudo, cMv, cCheck, cMsg
Local lRet := .t., lOk := .f.
Local j:=1, nPos := 0, nTam := AvSx3("EEQ_EVENT",AV_TAMANHO), nRec:=0
Local aEventos := {}

Begin Sequence

   cEvento := AllTrim(M->EEQ_EVENT)

   // ** Para os eventos de descontos padrão, não valida o conteúdo do(s) mv(s).
   If (cEvento $ "801/802/803/804/805/806/807")
      Break
   EndIf

   /* Validação para os eventos que não poderão ser incluídos manualmente
      pelo usuário. */
   aEventos := Af200ChkEvento()
   nPos     := aScan(aEventos,cEvento)
   If nPos > 0
      EasyHelp(STR0124+aEventos[nPos]+STR0125,STR0109) //"Parcelas com evento '"###"' não podem ser incluídas manualmente."###"Atenção"
      lRet:=.f.
      Break
   EndIf

   /* Serão verificados todos os MV´s "MV_EVENT??" de 01 até 10, a fim de analisar se o evento poderá ser
      incluido ou não. */

   Do While ((j<=10) .And. !lOk)
      cMv := "MV_EVENT"+StrZero(j,2)

      // ** Verifica se o mv existe e se o mesmo está preenchido.
      If EasyGParam(cMv,.t.) .And. !Empty(EasyGParam(cMv))
         cConteudo := AllTrim(EasyGParam(cMv))

         // ** JPM - 17/03/06 - Correção no tratamento do evento.
         If Right(cConteudo,1) <> "/"
            cConteudo += "/"
         EndIf
         If Left(cConteudo,1) <> "/"
            cConteudo := "/" + cConteudo
         EndIf
         // **

         nPos := At(cEvento,cConteudo) // Verifica se o evento digitado pelo usuário está relacionado neste mv.

         If nPos <= 0
            j++
            Loop
         EndIf

         If nPos = 1 // O evento digitado pelo usuário é o primento evento no conteúdo do MV.

            /* Verifica se o evento digitado pelo usuário é um evento que independe
               de outros eventos ou condições para inclusão. (Caso ótimo) */

            If SubStr(cConteudo,nPos+nTam,1) = "/"  .Or. SubStr(cConteudo,nPos+nTam,1) = "-"
               lOk := .t.
               Loop
            EndIf
         Else
            Do Case
               /* Verifica se o evento digitado pelo usuário é um evento que independe
                  de outros eventos ou condições para inclusão. (Caso ótimo) */

               Case (SubStr(cConteudo,nPos-1   ,1) == "/" .And.; // Caso ótimo.
                    (SubStr(cConteudo,nPos+nTam,1) == "/" .Or. SubStr(cConteudo,nPos+nTam,1) == "-"))

                  lOk := .t.
                  Loop

               Case (SubStr(cConteudo,nPos-1,1) == "-")

                  /* Neste caso, o evento digitado pelo usuário depende da existência de outro evento
                     pertencente a parcelas previamente lançadas. A work das parcelas é analisada a
                     fim de verificar se o evento existe ou não. */

                  cCheck := AvKey(SubStr(cConteudo, nPos-(nTam+1),nTam),"EEQ_EVENT")

                  nRec := TMP->(Recno())
                  TMP->(DbGoTop())
                  Do While TMP->(!Eof())
                     If TMP->EEQ_EVENT == cCheck
                        lOk := .t.
                        Exit
                     EndIf
                     TMP->(DbSkip())
                  EndDo
                  TMP->(DbGoTo(nRec))

                  If !lOk
                     Exit
                  EndIf
            EndCase
         EndIf
      EndIf
      j++
   EndDo

   If !lOk
      If !Empty(cCheck)
         cMsg := STR0118+ENTER+; //"Problema:"
                 STR0126+AllTrim(cEvento)+"'."+Replic(ENTER,2)+; //"Não é possível incluir parcelas com o evento '"
                 STR0121+ENTER+; //"Detalhes:"
                 STR0127+AllTrim(cEvento)+STR0128+ENTER+; //"Para inclusão de parcela com o evento'"###"' é necessário que exista uma parcela "
                 STR0129+cCheck+"'." //"previamente lançada com evento '"
      Else
         cMsg := STR0118+ENTER+; //"Problema:"
                 STR0126+AllTrim(cEvento)+"'."+Replic(ENTER,2)+; //"Não é possível incluir parcelas com o evento '"
                 STR0121+ENTER+; //"Detalhes:"
                 STR0130+ENTER+; //"O evento não foi encontrado no(s) parâmetro(s) para tratamento de eventos. "
                 STR0131 //"Verifique o conteúdo do(s) parâmetro(s) 'MV_EVENT??'."
      EndIf

      EasyHelp(cMsg,STR0109) //"Atenção"
      lRet:=.f.
      Break
   EndIf

End Sequence

Return lRet


/*
Função      : AF200GPCD
Parametros  : Valor(n)
              Condição de Pagamento(c)
              Data Base(d)
              Evento(c)
              Fornecedor (c)
              Loja (c)
              Empresa (c)
              Número da Invoice (c) (JPM - 02/08/05)
              cNatureza
Objetivo    : Geração de parcelas de cambio para Comissão por Agente(s) e Despesas Internacionais.
Retorno     : Array bidimensional, com a(s) parcela(s) de cambio.
              aArray[1] = Valor da Parcela.
              aArray[2] = Dt. de Vencimento.
              aArray[3] = Evento.
Autor       : Alexsander Martins dos Santos
Data e Hora : 27/09/2004 às 14:17.
*/

Function AF200GPCD(nValor, cCondPagto, dDtBase, cEvento, cFornecedor, cLoja, cEmpresa, cNrInvo, cNat)

Local aParcelas      := {}
Local nParcela       := 0
Local nPercentual    := 0
Local nDias          := 0
Local nTotal         := 0
Local aSaveOrd       := SaveOrd({"SY6","EC6"}, 1)  // By JPP - 02/06/2005 - 13:50
Local cRecDesp       := Space(3) // By JPP - 02/06/2005 - 13:50
Local nParcs         := 0
Local nVlParc        := 0
Local nDecParc       := AvSX3("EEQ_VL",AV_DECIMAL)

Default cEvento      := EV_PRINC2
Default cNrInvo      := EEC->EEC_NRINVO
Default cNat         := ""

Private nValParPE      := nValor
Private cCondPagtoPE   := cCondPagto
Private dDtBasePE      := dDtBase
Private cEventoPE      := cEvento
Private cFornecedorPE  := cFornecedor
Private cLojaPE        := cLoja
Private cEmpresaPE     := cEmpresa
Private cNrInvoPE      := cNrInvo
Private cNatPE         := cNat
Private lRetPE         := .F.
Private nValorPE       := 0

Begin Sequence

    IF EasyEntryPoint("EECAF200")

         Execblock("EECAF200",.F.,.F.,"VALIDA_PARCELA")
      
         If nValorPE <> 0  // GFP - 17/12/2013
               nValor := nValorPE
         EndIf
         
         if lRetPE
            break
         endif
         
    endif

    //RMD - 23/08/05 - Impede que sejam geradas parcelas quando o valor total é igual a 0.
    If nValor == 0 .AND. !lRetPE  // GFP - 13/12/2013
        Break
    EndIf

    EC6->(DbSetOrder(1))   // By JPP - 02/06/2005 - 13:50 - Define se a parcela de Cambio é receita ou despesa.
    EC6->(DbSeek(xFilial("EC6")+AvKey("EXPORT","EC6_TPMODU")+AvKey(cEvento,"EC6_ID_CAM")))
    cRecDesp :=EC6->EC6_RECDES

    SY6->(dbSeek(xFilial()+cCondPagto))

    Do Case

        Case SY6->Y6_TIPO = "1"

            dDtEMBNew:=EECProximoMes(dDtBase,SY6->Y6_COD,SY6->Y6_DIAS_PA)

            aAdd(aParcelas, {nValor, dDtEMBNew+SY6->Y6_DIAS_PA, cEvento, cFornecedor, cLoja, cEmpresa, cRecDesp, cNrInvo, cNat}) // By JPP - 02/06/2005 - 13:50 - Inclusão do parametro cRecDesp.

        Case SY6->Y6_TIPO = "2"

            aAdd(aParcelas, {nValor, dDtBase, cEvento, cFornecedor, cLoja, cEmpresa,cRecDesp, cNrInvo, cNat})  // By JPP - 02/06/2005 - 13:50 - Inclusão do parametro cRecDesp.

        Otherwise

            dDtEMBNew:=EECProximoMes(dDtBase,SY6->Y6_COD,SY6->Y6_DIAS_PA)
            aAdt := AE102ADTVLD(,cCondPagto) // retorno {nPercEsp, nTotEsp, nPercAss, nTotAss, nDif, aAdtAssd,aParcADT,aParcPOS}
            // aParcADT e aParcPOS { nParc , &("SY6->Y6_PERC_"+nParc) , &("SY6->Y6_DIAS_"+nParc) , ((EEC->EEC_TOTPED *  &("SY6->Y6_PERC_"+nParc))/100) })

             // corre o array das parcelas pós embarque
            for nParcela := 1 to len(aAdt[8])

                nPercentual := aAdt[8,nParcela,2]
                nDias       := aAdt[8,nParcela,3]

                if aAdt[1] > 0 //.and. aAdt[5] == 0
                    nVlParc := Round( nValor * ( nPercentual/(100 - aAdt[1]) ) , nDecparc )
                else
                    nVlParc := Round( nValor * ( nPercentual/100 ) , nDecParc )
                endif

                //dDtEMBNew := datavalida(dDtEMBNew+nDias,.T.)
                aAdd(aParcelas, {nVlParc, dDtEMBNew+nDias, cEvento, cFornecedor, cLoja, cEmpresa,cRecDesp, cNrInvo, cNat})
				nTotal += nVlParc
            next

            // quando houver diferença e não tiver parcelas pós embarque será gerado uma parcela com o valor da diferença e data para o próximo dia útil.
            if (aAdt[5] > 0 .and. len(aAdt[8]) == 0) .or. aAdt[1] == 100

                nVlParc := Round( nValor , nDecParc )
                dDtEMBNew := datavalida(dDtEMBNew+1,.T.)
                aAdd(aParcelas, {nVlParc, dDtEMBNew, cEvento, cFornecedor, cLoja, cEmpresa,cRecDesp, cNrInvo, cNat})
                nTotal += nVlParc
            endif

             If Len(aParcelas) > 0
                If nValor <> nTotal
                    aParcelas[nParcela-1][1] += (nValor-nTotal)
                EndIf
            EndIf

    End Case

End Sequence

RestOrd(aSaveOrd)

Return(aParcelas)

//AWR 06/04/2002
*-----------------------------------------*
Function EECProximoMes(dData,cCond,nDias)
*-----------------------------------------*
IF SY6->(FIELDPOS("Y6_PROMES")) # 0 .AND. SY6->(DBSEEK(xFilial()+cCond+STR(nDias,3)))
   IF SY6->Y6_PROMES $ cSim
      nMesAtual:=MONTH(dData)
      DO WHILE .T.
         dData++
         nMes:=MONTH(dData)
         IF MONTH(dData) # nMesAtual
            EXIT
         ENDIF
      ENDDO
      dData:=(dData-1)
   ENDIF
ENDIF

Return dData

/*
Função      : Af200TemComissao().
Parametros  : cTipCom - Tipo da comissão a ser validado.
Objetivo    : Verificar se existem parcelas para o tipo de comissão passada como parâmetro.
Retorno     : .t./.f.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/10/2004 - 09:52.
*/
*---------------------------------------*
Static Function Af200TemComissao(cTipCom)
*---------------------------------------*
Local lRet:=.t.
Local aOrd:=SaveOrd("TMP")

Begin Sequence

   cTipCom := AllTrim(Upper(cTipCom))

   Tmp->(DbSetOrder(4))

   Do Case
      Case cTipCom == "EEQ_CGRAFI"
           lRet := Tmp->(DbSeek(EV_COM_CG))

      Case cTipCom == "EEQ_AREMET"
           lRet:= Tmp->(DbSeek(EV_COM_AR))

      Case cTipCom == "EEQ_ADEDUZ"
           lRet:= Tmp->(DbSeek(EV_COM_DF))
   EndCase

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Af200ChkEvento().
Parametros  : Nenhum.
Retorno     : aEventos.
Objetivos   : Levantar todos os eventos de invoice, comissão e despesas internacionais.
Autor       : Jeferson Barros Jr.
Data/Hora   : 11/07/2001 - 16:20.
Obs.        :
*/
*--------------------------------*
Static Function Af200ChkEvento()
*--------------------------------*
Local aEventos:={}, aDespesas:={}
Local cEvent
Local nPos :=0, j:=0

Begin Sequence

   aEventos:={"101",;  // Invoice
              "120",;  // Comissão do Tipo "A Remeter".
              "121",;  // Comissão do Tipo "Conta Gráfica".
              "122",;  // Comissão do Tipo "Deduzir da Fatura".
              "129"}   // Compra Back to Back

   aDespesas := X3DIReturn()

   If Len(aDespesas) > 0
      For j:=1 To Len(aDespesas)
         cEvent := Alltrim(EasyGParam("MV"+SubStr(aDespesas[j][2],4),,""))
         If !Empty(cEvent)
            nPos := aScan(aEventos,AvKey(cEvent,"EEQ_EVENT"))
            If nPos = 0
               aAdd(aEventos,AvKey(cEvent,"EEQ_EVENT"))
            EndIf
         EndIf
      Next
   EndIf

End Sequence

Return aEventos

/*
Funcao      : AF200VIS()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exibir para consulta rápida, informações da Invoice, Contratos de financiamento, etc.
Autor       : Alessandro Alves Ferreira.
Data/Hora   : 13/01/2005 - 09:50.
Obs.        :
*/
*------------------------*
Function AF200VIS()
*------------------------*
Local i
Private nLin := 3
Private nCol1:= 5
Private nCol2:= 62
Private nCol3:= 192
Private nCol4:= 262
Private cMoeDolar := EasyGParam("MV_SIMB2",,"US$")
Private aGets, aAgentes, aColsAgen, aContratos, aColsCont, nVlFOB
Private nSay := 1
Private bInit:= {||.T.}
Private aLabels
Private nTotalCon:= 0, nTotalLiq:= 0

//Procura Vencimentos
cFilEEQ      := xFilial("EEQ")
cVencimentos := ""
EEQ->( dbSetOrder(5) )
EEQ->( dbSeek(cFilEEQ+EEC->EEC_NRINVO+'101') )
Do While !EEQ->( EoF() ) .AND. EEQ->( EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT ) == cFilEEQ+EEC->EEC_NRINVO+'101'
   // ** GFC - 01/12/05 - Nos loops do EEQ verificar se o processo do eeq é o mesmo do eec
   If EEQ->EEQ_PREEMB <> EEC->EEC_PREEMB
      EEQ->(dbSkip())
      Loop
   EndIf
   // **

   cVencimentos += DtoC(EEQ->EEQ_VCT)
   EEQ->( dbSkip() )

   If !EEQ->( EoF() ) .AND. EEQ->( EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT+EEQ_PREEMB ) == cFilEEQ+EEC->EEC_NRINVO+'101'+EEC->EEC_PREEMB
      cVencimentos += ", "
   Endif
EndDo

//Calcula valor da mercadoria
nVlFOB  := 0
cNumSD  := ""
cNumRE  := ""
cFilEE9 := xFilial("EE9")
EE9->( dbSetOrder(2) )
EE9->( dbSeek(cFilEE9+EEC->EEC_PREEMB) )
Do While !EE9->( EoF() ) .AND. EE9->( EE9_FILIAL+EE9_PREEMB ) == cFIlEE9+EEC->EEC_PREEMB
   nVlFOB += EE9->EE9_PRCINC
   cNumSD += AllTrim(TransForm(EE9->EE9_NRSD,AVSX3("EE9_NRSD",6)))
   cNumRE += AllTrim(TransForm(EE9->EE9_RE,AVSX3("EE9_RE",6)))

   EE9->( dbSkip() )
   If !EE9->( EoF() ) .AND. EE9->( EE9_FILIAL+EE9_PREEMB ) == cFIlEE9+EEC->EEC_PREEMB
      If !Empty(EE9->EE9_NRSD)
         cNumSD += ", "
      Endif
      If !Empty(EE9->EE9_RE) .AND. !EE9->EE9_RE $ cNumRE
         cNumRE += ", "
      Endif
   Endif
Enddo

//Carrega Campos

aGets := {}

//Fatura
aAdd(aGets,{EEC->EEC_NRINVO      ,;
            STR0133              ,;//"Fatura"
            AVSX3("EEC_NRINVO",6)})
//Fornecedor
aAdd(aGets,{AllTrim(EEC->EEC_FORN) + " - " + Posicione("SA2",1,xFilial("SA2")+EEC->EEC_FORN+EEC->EEC_FOLOJA,"A2_NREDUZ"),;
            STR0134                                                                                                     ,;//"Fornecedor"
            "@!"                                                                                                        })
//Importador
aAdd(aGets,{AllTrim(EEC->EEC_IMPORT) + " - " + Posicione("SA1",1,xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA,"A1_NREDUZ"),;
            STR0135                                                                                                         ,;//"Importador"
            "@!"                                                                                                            })
//Endereco
aAdd(aGets,{EEC->EEC_ENDIMP  ,;
            STR0136          ,;//"Endereço"
            AVSX3("A1_END",6)})
//País
aAdd(aGets,{Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR") ,;
            STR0137                                                   ,;//"País"
            AVSX3("YA_DESCR",6)                                       })
//Data BL
aAdd(aGets,{DtoC(EEC->EEC_DTCONH),;
            STR0138            ,;//"Data BL"
            "@!"                 })
//Valor Total
aAdd(aGets,{AllTrim(EEC->EEC_MOEDA) + " " + AllTrim(Transform(EEC->EEC_TOTPED,AVSX3("EEC_TOTPED",6))),;
            STR0139                                                                                  ,;//"Valor Total"
            "@!"                                                                                     })

//Valor FOB
aAdd(aGets,{AllTrim(EEC->EEC_MOEDA) + " " + AllTrim(Transform(nVlFOB,AVSX3("EEC_TOTPED",6))),;
            STR0140                                                                         ,;//"Valor FOB"
            "@!"                                                                            })
// ** AAF 27/01/05 - Novos Campos com Frete e Seguro
//Valor Frete
aAdd(aGets,{AllTrim(EEC->EEC_MOEDA) + " " + AllTrim(Transform(EEC->EEC_FRPREV,AVSX3("EEC_FRPREV",6))),;
            STR0159                                                                                  ,;//"Frete"
            "@!"                                                                                     })

//Valor Seguro
aAdd(aGets,{AllTrim(EEC->EEC_MOEDA) + " " + AllTrim(Transform(EEC->EEC_SEGPRE,AVSX3("EEC_SEGPRE",6))),;
            STR0160                                                                                  ,;//"Seguro"
            "@!"                                                                                     })
// **
//L/C
aAdd(aGets,{EEC->EEC_LC_NUM      ,;
            AVSX3("EEC_LC_NUM",5),;
            AVSX3("EEC_LC_NUM",6)})
//Modalidade
aAdd(aGets,{Posicione("EEF",1,xFilial("EEF")+EEC->EEC_MPGEXP,"EEF_DESC"),;
            STR0141                                                     ,;//"Modalidade"
            AVSX3("EEF_DESC",6)                                         })
//Período
aAdd(aGets,{Transform(EEC->EEC_DIASPA,"@!") + STR0249,;//STR0249	" dias"
            STR0142                                  ,;//"Período"
            "@!"                                     })
//Vencimentos
aAdd(aGets,{cVencimentos ,;
            STR0143      ,;//"Vencimentos"
            "@!"         })
//Número SD
aAdd(aGets,{cNumSD     ,;
            STR0144    ,;//"Número SD"
            "@!"       })
//Número RE
aAdd(aGets,{cNumRE ,;
            STR0145,;//"Número RE"
            "@!"   })
//Variaveis para GetDados de Contratos.
aContratos := {}
aColsCont  := {}

//Campos de Contratos
aAdd(aContratos,{STR0055              ,"EF1_BAN_FI","@!"                 ,AVSX3("EF1_BAN_FI",3)   ,0                    ,nil,nil,AVSX3("EF1_BAN_FI",2),nil,nil } )//"Banco"
aAdd(aContratos,{AVSX3("EF3_CONTRA",5),"EF3_CONTRA",AVSX3("EF3_CONTRA",6),AVSX3("EF3_CONTRA",3)   ,AVSX3("EF3_CONTRA",4),nil,nil,AVSX3("EF3_CONTRA",2),nil,nil } )
If lEFFTpMod  //### PLB 02/03/06 - Inclui Sequencia do Contrato na GetDados de Contratos
   aAdd(aContratos,{AVSX3("EF1_SEQCNT",5),"EF1_SEQCNT",AVSX3("EF1_SEQCNT",6),AVSX3("EF1_SEQCNT",3)   ,AVSX3("EF1_SEQCNT",4),nil,nil,AVSX3("EF1_SEQCNT",2),nil,nil } )//"Sequencia"
EndIf
aAdd(aContratos,{STR0149              ,"EF3_VL_MOE",AVSX3("EF3_VL_MOE",6),AVSX3("EF3_VL_MOE",3)   ,AVSX3("EF3_VL_MOE",4),nil,nil,AVSX3("EF3_VL_MOE",2),nil,nil } )//"Valor"
aAdd(aContratos,{STR0025              ,"EF3_DT_EVE",AVSX3("EF3_DT_EVE",6),AVSX3("EF3_DT_EVE",3)   ,AVSX3("EF3_DT_EVE",4),nil,nil,AVSX3("EF3_DT_EVE",2),nil,nil } )//"Vinculação"
aAdd(aContratos,{AVSX3("EF3_CODEVE",5),"EF3_CODEVE",AVSX3("EF3_CODEVE",6),AVSX3("EF3_CODEVE",3)+20,AVSX3("EF3_CODEVE",4),nil,nil,AVSX3("EF3_CODEVE",2),nil,nil } )//"Evento"
aAdd(aContratos,{STR0147              ,"EEQ_PARC"  ,"@!"                  ,8                      ,AVSX3("EEQ_PARC",4)  ,nil,nil,AVSX3("EEQ_PARC",2)  ,nil,nil } )//"Parcela"
aAdd(aContratos,{STR0146              ,"EEQ_RFBC"  ,AVSX3("EEQ_RFBC",6)  ,AVSX3("EEQ_RFBC",3)     ,AVSX3("EEQ_RFBC",4)  ,nil,nil,AVSX3("EEQ_RFBC",2)  ,nil,nil } )//"Referencia"
If lParfin
   aAdd(aContratos,{AVSX3("EEQ_PARFIN",5),"EEQ_PARFIN","@!"                  ,8                      ,AVSX3("EEQ_PARFIN",4)  ,nil,nil,AVSX3("EEQ_PARFIN",2)  ,nil,nil } )//"Parcela Financiamento"
EndIf

aLiquidado := {}
aColsLiq   := {}

//Campos de Liquidação
aAdd(aLiquidado,{STR0147              ,"EEQ_PARC","@!"                ,AVSX3("EEQ_PARC",3),AVSX3("EEQ_PARC",4),nil,nil,AVSX3("EEQ_PARC",2),nil,nil } )//"Parcela"
aAdd(aLiquidado,{AVSX3("EEQ_DTCE",5)  ,"EEQ_DTCE",AVSX3("EEQ_DTCE",6) ,0                  ,0                  ,nil,nil,"C"                ,nil,nil } )
aAdd(aLiquidado,{STR0026              ,"EEQ_PGT" ,AVSX3("EEQ_PGT" ,6) ,0                  ,0                  ,nil,nil,"C"                ,nil,nil } )//"Liquidação"
aAdd(aLiquidado,{STR0149              ,"EEQ_VL"  ,AVSX3("EEQ_VL"  ,6) ,5                  ,2                  ,nil,nil,"N"                ,nil,nil } )//"Valor"
aAdd(aLiquidado,{AVSX3("EEQ_OBS",5)   ,"EEQ_OBS" ,AVSX3("EEQ_OBS" ,6) ,AVSX3("EEQ_OBS" ,3),AVSX3("EEQ_OBS" ,4),nil,nil,AVSX3("EEQ_OBS" ,2),nil,nil } )

aLiquidado := AddCpoUser(aLiquidado,"EEQ","4")

aAgentes   := {}
aColsAgen  := {}

//Campos de Agentes
aAdd(aAgentes,{STR0150              ,"EEB_CODAGE","@!"                 ,AVSX3("EEB_CODAGE",3)+20,AVSX3("EEB_CODAGE",4),nil,nil,"C"                  ,nil,nil } )//"Agente"
aAdd(aAgentes,{STR0058              ,"EEB_TXCOMI",AVSX3("EEB_TXCOMI",6),AVSX3("EEB_TXCOMI",3)   ,AVSX3("EEB_TXCOMI",4),nil,nil,AVSX3("EEB_TXCOMI",2),nil,nil } )//"Taxa"
aAdd(aAgentes,{AVSX3("EEB_VALCOM",5),"EEB_VALCOM",AVSX3("EEB_VALCOM",6),AVSX3("EEB_VALCOM",3)   ,AVSX3("EEB_VALCOM",4),nil,nil,AVSX3("EEB_VALCOM",2),nil,nil } )
aAdd(aAgentes,{AVSX3("EEB_TIPCOM",5),"EEB_TIPCOM",AVSX3("EEB_TIPCOM",6),AVSX3("EEB_TIPCOM",3)   ,AVSX3("EEB_TIPCOM",4),nil,nil,AVSX3("EEB_TIPCOM",2),nil,nil } )
aAdd(aAgentes,{STR0151              ,"EEQ_VCT"   ,AVSX3("EEQ_VCT",6)   ,AVSX3("EEQ_VCT",3)      ,AVSX3("EEQ_VCT",4)   ,nil,nil,AVSX3("EEQ_VCT",2)   ,nil,nil } )//"Vencimento"
aAdd(aAgentes,{STR0152              ,"EEQ_PGT"   ,AVSX3("EEQ_PGT",6)   ,AVSX3("EEQ_PGT",3)      ,AVSX3("EEQ_PGT",4)   ,nil,nil,AVSX3("EEQ_PGT",2)   ,nil,nil } )//"Pagamento"
aAdd(aAgentes,{AVSX3("EEQ_NOMEBC",5),"EEQ_NOMEBC",AVSX3("EEQ_NOMEBC",6),AVSX3("EEQ_NOMEBC",3)   ,AVSX3("EEQ_NOMEBC",4),nil,nil,AVSX3("EEQ_NOMEBC",2),nil,nil } )//"Pagamento"

DEFINE MSDIALOG oDlg TITLE STR0153 FROM 10,10 TO 539,790 OF oMainWnd PIXEL//"Visualização Rápida"
DEFINE FONT oFont NAME "Courier New" SIZE 0,-14

//Labels
aLabels := { {nLin,2  ,125,391,STR0133},;//"Fatura"      Posicão do 1o @TO
             {127 ,2  ,189,208,STR0154},;//"Contratos"   Posicão do 2o @TO
             {127 ,210,189,391,STR0155},;//"Liquidações" Posicão do 3o @TO
             {190 ,2  ,265,391,STR0156} }//"Agentes"     Posicão do 4o @TO

//GetDados
aPosDados := { {135,006,185,204},; //Posiçao da 1a GetDados
               {135,214,185,387},; //Posiçao da 2a GetDados
               {198,006,262,387} } //Posiçao da 3a GetDados
//ScrollBox
aScrBox := { 9,4,114,385 }

//Carrega Dados nos GetDados
AF200CDados('101')//Carrega Invoices
AF200CDados('120')//Carrega Comissão

//Adiciona Total vinculado
If Len(aColsCont) > 0
   aAdd(aColsCont,Array(Len(aContratos)+1))

   aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EF1_BAN_FI"})] := STR0157  //"Total:"
   aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EF3_VL_MOE"})] := EEC->EEC_TOTPED //nTotalCon

   //Marca como não deletado
   aColsCont[Len(aColsCont)][Len(aContratos)+1] := .F.
Endif

//Adiciona Total Liquidado
If Len(aColsLiq) > 0
   aAdd(aColsLiq,Array(Len(aLiquidado)+1))

   aColsLiq[Len(aColsLiq)][aScan(aLiquidado,{|X|X[2]=="EEQ_PARC"})] := STR0157  //"Total:"
   aColsLiq[Len(aColsLiq)][aScan(aLiquidado,{|X|X[2]=="EEQ_VL"})]   := nTotalLiq

   //Marca como não deletado
   aColsLiq[Len(aColsLiq)][Len(aLiquidado)+1] := .F.
Endif

//Inicializa o Array do GetDados caso esteja vazio.
/*
If Len(aColsCont) == 0
   aVazio := {}
   For i:= 1 to Len(aContratos)
      aAdd(aVazio,iIF(aContratos[i][8] == "N",0,""))
   Next
   aAdd(aVazio,.F.)
   aAdd(aColsCont,aVazio)
Endif
*/

//Inicializa o Array do GetDados caso esteja vazio.
If Len(aColsLiq) == 0
   aVazio := {}
   For i:= 1 to Len(aLiquidado)
      aAdd(aVazio,iIF(aLiquidado[i][8] == "N",0,""))
   Next
   aAdd(aVazio,.F.)
   aAdd(aColsLiq,aVazio)
Endif

//Inicializa o Array do GetDados caso esteja vazio.
If Len(aColsAgen) == 0
   aVazio := {}
   For i:= 1 to Len(aAgentes)
      aAdd(aVazio,iIF(aAgentes[i][8] == "N",0,""))
   Next
   aAdd(aVazio,.F.)
   aAdd(aColsAgen,aVazio)
Endif


If EasyEntryPoint("EECAF200")
   ExecBlock("EECAF200", .f., .f., "TELA_VIS_RAP")
Endif

oScrBox := TScrollBox():New(oDlg,aScrBox[1],aScrBox[2],aScrBox[3],aScrBox[4],.T.,.T.,.T.)//Cria controles dentro do scrollbox

@ aLabels[1][1] ,aLabels[1][2] TO aLabels[1][3],aLabels[1][4] Label aLabels[1][5] of oDlg Pixel
@ aLabels[2][1] ,aLabels[2][2] TO aLabels[2][3],aLabels[2][4] Label aLabels[2][5] of oDlg Pixel
@ aLabels[3][1] ,aLabels[3][2] TO aLabels[3][3],aLabels[3][4] Label aLabels[3][5] of oDlg Pixel
@ aLabels[4][1] ,aLabels[4][2] TO aLabels[4][3],aLabels[4][4] Label aLabels[4][5] of oDlg Pixel
//Monta os Says e Gets
nLin    += 3
nCont   := 0
nColSay := nCol1
nColGet := nCol2
For i:= 1 To Len(aGets)
   nCont += 1
   If nCont == 2
      nColSay := nCol3
      nColGet := nCol4
   Else

   Endif

   @ nLin, nColSay SAY   AF200VGet("SAY") of oScrBox Pixel FONT oFont SIZE 120,08
   @ nLin, nColGet MSGET AF200VGet("GET") Picture aGets[i][3] SIZE 115,08 Pixel of oScrBox When .F.

   If nCont == 2
      nLin    += 10
      nCont   := 0
      nColSay := nCol1
      nColGet := nCol2
   Endif
Next

//Monta as GetDados
oMsGCon := MsNewGetDados():New(aPosDados[1][1],aPosDados[1][2],aPosDados[1][3], aPosDados[1][4], 2,/*LinOk*/,/*TudoOk*/,"",{},/*freeze*/,1000,/*fieldok*/,/*superdel*/,/*delok*/, oDlg, aContratos, aColsCont)
oMsGLiq := MsNewGetDados():New(aPosDados[2][1],aPosDados[2][2],aPosDados[2][3], aPosDados[2][4], 2,/*LinOk*/,/*TudoOk*/,"",{},/*freeze*/,1000,/*fieldok*/,/*superdel*/,/*delok*/, oDlg, aLiquidado, aColsLiq )
oMsGAge := MsNewGetDados():New(aPosDados[3][1],aPosDados[3][2],aPosDados[3][3], aPosDados[3][4], 2,/*LinOk*/,/*TudoOk*/,"",{},/*freeze*/,1000,/*fieldok*/,/*superdel*/,/*delok*/, oDlg, aAgentes  , aColsAgen)

ACTIVATE MSDIALOG oDlg ON INIT Eval(bInit) CENTERED

Return .T.

/*
Funcao      : AF200CDados()
Parametros  : Nenhum
Retorno     : Nenhum
Objetivos   : Carregar dados para tela de visualização rápida.
Autor       : Alessandro Alves Ferreira.
Data/Hora   : 14/01/2005 - 10:50.
Obs.        :
*/
Function AF200CDados(cCodEve)
Local nVin:= 0, nLiq:= 0, nPosAuxEF3:=0, aArrayEF3:={}, nPosEF3:=0
cFilEEQ    := xFilial("EEQ")
cFilEF3    := xFilial("EF3")
cFilEEB    := xFilial("EEB")
cFilEC6    := xFilial("EC6")
nPosParc   := aScan(aContratos,{|X|X[2]=="EEQ_PARC"  })
nPosVl     := aScan(aContratos,{|X|X[2]=="EF3_VL_MOE"})
nEvent     := aScan(aContratos,{|X|X[2]=="EF3_CODEVE"})
nPosParFin := aScan(aContratos,{|X|X[2]=="EEQ_PARFIN"})

//Carrega dados das vinculações de contratos e Liquidações.
EEQ->( dbSetOrder(1) )
EF1->( dbSetOrder(1) )
EF3->( dbSetOrder(2) )

If cCodEve <> '120'
   EEQ->(dbSeek(cFilEEQ+EEC->EEC_PREEMB))
   Do While !EEQ->(EoF()) .AND. EEQ->(EEQ_FILIAL+EEQ_PREEMB) == cFilEEQ+EEC->EEC_PREEMB
      If EEQ->EEQ_EVENT == '101'
         EF3->(dbSeek(xFilial("EF3")+If(lEFFTpMod,IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+"600"+EEQ->(EEQ_NRINVO+If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN) )) ) //HVR SEEK I OU E
         Do While !EF3->(EoF()) .AND. EF3->(EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CODEVE+EF3_INVOIC+EF3_PARC) == xFilial("EF3")+If(lEFFTpMod,IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"),"")+"600"+EEQ->(EEQ_NRINVO+If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN))//HVR
            nPosEF3:=aScan(aArrayEF3,EF3->(RECNO()))

            If (!lEF3FilOri .OR. Empty(EF3->EF3_FILORI) .Or. EF3->EF3_FILORI == EEQ->EEQ_FILIAL) .And. nPosEF3 = 0
               nPosAuxEF3:=aScan(aColsCont,{|X| X[If(!lParFin, nPosParc, nPosParFin)] == If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN) .And. X[2]==EF3->EF3_CONTRA})
               If nPosAuxEF3 = 0
                  aAdd(aArrayEF3,EF3->(RECNO()))
                  aAdd(aColsCont,Array(Len(aContratos)+1))

                  EF1->( dbSeek(xFilial("EF1")+If(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3->(EF3_CONTRA+If(lTemChave,EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,""),""))) )   //HVR SEEK I OU E

                  //Grava os campos
                  aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EEQ_PARC"  })] := EEQ->EEQ_PARC
                  aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EF3_CODEVE"})] := EF3->EF3_CODEVE + " - " + Posicione("EC6",1,cFilEC6+EF3->( "FIEX"+EF3_TP_EVE+EF3_CODEVE ),"EC6_DESC")
                  aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EF3_VL_MOE"})] := EF3->EF3_VL_MOE
                  aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EF3_DT_EVE"})] := EF3->EF3_DT_EVE
                  aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EF1_BAN_FI"})] := If(Empty(EF1->EF1_BAN_MO), EF1->EF1_BAN_FI, EF1->EF1_BAN_MO)
                  If lEFFTpMod  //### PLB 02/03/06 - Carrega Sequencia do Contrato
                     aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EF1_SEQCNT"})] := EF1->EF1_SEQCNT
                  EndIf
                  aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EF3_CONTRA"})] := EF3->EF3_CONTRA
                  aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EEQ_RFBC"  })] := EEQ->EEQ_RFBC
                  If lParfin
                     aColsCont[Len(aColsCont)][aScan(aContratos,{|X|X[2]=="EEQ_PARFIN"})] := If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN)
                  EndIf
                  nVin      += EF3->EF3_VL_MOE
                  nTotalCon += EF3->EF3_VL_MOE

                  //Marca como não deletado
                  aColsCont[Len(aColsCont)][Len(aContratos)+1] := .F.

                  /*
                  nReg:= EF3->( RecNo() )
                  If EF3->( dbSeek(cFilEF3+"630"+EEQ->( EEQ_NRINVO+EEQ_PARC )) )
                     aColsCont[Len(aColsCont)][08] := EF3->EF3_DT_EVE
                     aColsCont[Len(aColsCont)][09] := EF3->EF3_VL_MOE
                  Endif
                  EF3->( dbGoTo(nReg) )
                  */
               Else
                  nVin += EF3->EF3_VL_MOE
                  aColsCont[nPosAuxEF3,aScan(aContratos,{|X|X[2]=="EF3_VL_MOE"})]+=EF3->EF3_VL_MOE
                  aAdd(aArrayEF3,EF3->(RECNO()))
               EndIf
            Endif

            EF3->( dbSkip() )
         EndDo

         nPos := aScan(aColsCont,{|X| X[If(!lParFin, nPosParc, nPosParFin)] == If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN) })
         If nPos > 0
            If EEQ->EEQ_VL - nVin > 0 //Alcir Alves - 09-08-05
               aAdd(aColsCont,NIL)
               aIns(aColsCont,nPos)
               aColsCont[nPos]:= Array(Len(aContratos)+1)

               //Grava os campos
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EEQ_PARC"  })] := EEQ->EEQ_PARC
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_CODEVE"})] := EEQ->EEQ_EVENT  + " - " + Posicione("EC6",1,cFilEC6+'EXPORT'+EEQ->EEQ_EVENT,"EC6_DESC")
//             aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_VL_MOE"})] := EEQ->EEQ_VL - nVin
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_DT_EVE"})] := DtoC(EEQ->EEQ_PGT)
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_VL_MOE"})] := EEQ->EEQ_VL_PAR
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF1_BAN_FI"})] := EEQ->EEQ_BANC
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_CONTRA"})] := EEQ->EEQ_NROP
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EEQ_RFBC"  })] := EEQ->EEQ_RFBC
               If lParFin
                  aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EEQ_PARFIN"})] := If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN)
               EndIf

               nTotalCon += EEQ->EEQ_VL - nVin
               //nTotalCon += EEQ->EEQ_VL_PAR
               //Marca como não deletado
               aColsCont[nPos][Len(aContratos)+1] := .F.
            Endif
         Else
            aAdd(aColsCont,Array(Len(aContratos)+1))
            nPos:= Len(aColsCont)

            //Grava os campos
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EEQ_PARC"  })] := EEQ->EEQ_PARC
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_CODEVE"})] := EEQ->EEQ_EVENT + " - " + Posicione("EC6",1,cFilEC6+'EXPORT'+EEQ->EEQ_EVENT,"EC6_DESC")
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_VL_MOE"})] := EEQ->EEQ_VL
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF1_BAN_FI"})] := EEQ->EEQ_BANC
            If !Empty(EEQ->EEQ_PGT)
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_CONTRA"})] := EEQ->EEQ_NROP
            EndIf
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EEQ_RFBC"  })] := EEQ->EEQ_RFBC
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_DT_EVE"})] := DtoC(EEQ->EEQ_PGT)
            If lParFin
               aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EEQ_PARFIN"})] := If(!lParFin .Or. Empty(EEQ->EEQ_PARFIN), EEQ->EEQ_PARC, EEQ->EEQ_PARFIN)
            EndIf

            nTotalCon += EEQ->EEQ_VL

            //Marca como não deletado
            aColsCont[nPos][Len(aContratos)+1] := .F.
         Endif

         If !Empty(EEQ->EEQ_DTCE) .OR. !Empty(EEQ->EEQ_PGT) //Alcir Alves - 29-07-05
            aAdd(aColsLiq,Array(Len(aLiquidado)+1))

            aColsLiq[Len(aColsLiq)][aScan(aLiquidado,{|X|X[2]=="EEQ_PARC"})] := EEQ->EEQ_PARC
            aColsLiq[Len(aColsLiq)][aScan(aLiquidado,{|X|X[2]=="EEQ_DTCE"})] := DtoC(EEQ->EEQ_DTCE)
            aColsLiq[Len(aColsLiq)][aScan(aLiquidado,{|X|X[2]=="EEQ_PGT" })] := DtoC(EEQ->EEQ_PGT)
            aColsLiq[Len(aColsLiq)][aScan(aLiquidado,{|X|X[2]=="EEQ_VL"  })] := EEQ->EEQ_VL
            aColsLiq[Len(aColsLiq)][aScan(aLiquidado,{|X|X[2]=="EEQ_OBS"  })] := EEQ->EEQ_OBS
            nLiq      += EEQ->EEQ_VL
            nTotalLiq += EEQ->EEQ_VL
            //Marca como não deletado
            aColsLiq[Len(aColsLiq)][Len(aLiquidado)+1] := .F.
         Endif

         If EEQ->EEQ_TIPO == 'A'
            nPos := Max(nPos,1)
            //aAdd(aColsCont,NIL)
            //aIns(aColsCont,nPos)
            aColsCont[nPos]:= Array(Len(aContratos)+1)
            nRecEEQ:= EEQ->( RecNo() )
            nOrdEEQ:= EEQ->( IndexOrd() )
            EEQ->( dbSetOrder(5) )
            cChave := cFilEEQ + EEQ->EEQ_NRINVO + EEQ->EEQ_EVENT //'605'  //NCF - 02/07/2019

            EEQ->( dbSeek(cChave) )

            //Grava os campos
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EEQ_PARC"  })] := EEQ->EEQ_PARC
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_CODEVE"})] := EEQ->EEQ_EVENT + " - " + Posicione("EC6",1,cFilEC6+'EXPORT'+EEQ->EEQ_EVENT,"EC6_DESC")
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_VL_MOE"})] := EEQ->EEQ_VL
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF1_BAN_FI"})] := EEQ->EEQ_BANC
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EF3_CONTRA"})] := EEQ->EEQ_NROP
            aColsCont[nPos][aScan(aContratos,{|X|X[2]=="EEQ_RFBC"  })] := EEQ->EEQ_RFBC

            nTotalCon += EEQ->EEQ_VL

            aColsCont[nPos][Len(aContratos)+1] := .F.
            EEQ->( dbSetOrder(nOrdEEQ) )
            EEQ->( dbGoTo(nRecEEQ) )
         Endif
      Endif

      nLiq:= 0
      nVin:= 0
      EEQ->( dbSkip() )
   EndDo
Endif

If cCodEve == '120'
   //Procura com softseek para encontrar qualquer um dos eventos de comissão
   EEQ->(dbsetorder(5)) //Alcir Alves - 10-08-05 - braskem in loco
   EEQ->( dbSeek(cFilEEQ+EEC->EEC_NRINVO+'120',.T.) )
   Do While !EEQ->( EoF() ) .AND. EEQ->( EEQ_FILIAL+EEQ_NRINVO ) == cFilEEQ+EEC->EEC_NRINVO .AND. EEQ->EEQ_EVENT $ "120/121/122"

      // ** GFC - 01/12/05 - Nos loops do EEQ verificar se o processo do eeq é o mesmo do eec
      If EEQ->EEQ_PREEMB <> EEC->EEC_PREEMB
         EEQ->(dbSkip())
         Loop
      EndIf
      // **

      aAdd(aColsAgen,Array(Len(aAgentes)+1))

      aColsAgen[Len(aColsAgen)][aScan(aAgentes,{|X|X[2]=="EEB_CODAGE"})] := EEQ->EEQ_CODEMP + " - " + Posicione("SY5",1,xFilial("SY5")+EEQ->EEQ_CODEMP,"Y5_NOME") //Alcir Alves - 10-08-05 - braskem in loco
      aColsAgen[Len(aColsAgen)][aScan(aAgentes,{|X|X[2]=="EEB_TXCOMI"})] := (EEQ->EEQ_VL / nVlFOB) * 100
      aColsAgen[Len(aColsAgen)][aScan(aAgentes,{|X|X[2]=="EEB_VALCOM"})] := EEQ->EEQ_VL
      aColsAgen[Len(aColsAgen)][aScan(aAgentes,{|X|X[2]=="EEB_TIPCOM"})] := iIF(EEQ->EEQ_EVENT == EV_COM_AR,"1",iIF(EEQ->EEQ_EVENT == EV_COM_CG,"2","3"))
      aColsAgen[Len(aColsAgen)][aScan(aAgentes,{|X|X[2]=="EEQ_VCT"   })] := EEQ->EEQ_VCT
      aColsAgen[Len(aColsAgen)][aScan(aAgentes,{|X|X[2]=="EEQ_PGT"   })] := EEQ->EEQ_PGT
      aColsAgen[Len(aColsAgen)][aScan(aAgentes,{|X|X[2]=="EEQ_NOMEBC"})] := EEQ->EEQ_NOMEBC

      //Marca como não deletado
      aColsAgen[Len(aColsAgen)][Len(aAgentes)+1] := .F.

      EEQ->( dbSkip() )
   EndDo
Endif

Return .T.

/*
Funcao      : AF200VGet()
Parametros  : cTip = "SAY" ou "GET"
Retorno     : Texto a ser exibido.
Objetivos   : Controlar o texto a ser exibido de acordo com array aGets.
Autor       : Alessandro Alves Ferreira.
Data/Hora   : 15/01/2005 - 10:00.
Obs.        :
*/
Function AF200VGet(cTip)

If nSay > Len(aGets)
   nSay := 1
Endif

If cTip == "SAY"
   cRet := aGets[nSay][2]
Else
   cRet := aGets[nSay][1]
   nSay++
Endif

Return cRet


/*
Função      : AF200TotParc
Objetivo    : Retornar o valor total das parcelas através do total do embarque, com exceção das parcelas
              de adiantamento já lançadas e a ultima sequencia da parcela encontrada.
Parametro   : cFil     = Filial em que se deve obter o total.
Retorno     : Array[1] = Total das parcelas.
                   [2] = Sequencia da ultima parcela.
                   [3] = Total das Parcelas de Adiantamento - By JPM - 02/08/05
                   [4] = Total de parcelas do tipo adiantamento.
Autor       : Alexsander Martins dos Santos
Data e Hora : 08/02/2005 às 17:58.
*/

Function AF200TotParc(cFil,bCondAdic)

Local aSaveOrd := SaveOrd("EEQ", 6)
Local aRet     := {0, 0, 0, 0}
Local nCont    := 0
Default bCondAdic := {||.T.}

Begin Sequence

   aRet[1] := EEC->EEC_TOTPED
   If lPagtoAnte
      EEQ->(dbSeek(cFil+"E"+EEC->EEC_PREEMB))

      While EEQ->(!Eof() .and. EEQ_FILIAL == cFil .and. EEQ_FASE = "E" .and. EEQ_PREEMB == EEC->EEC_PREEMB)

         If EEQ->EEQ_TIPO == "A" .And. Eval(bCondAdic)
            aRet[1] -= EEQ->EEQ_VL
            aRet[3] += EEQ->EEQ_VL // JPM - 02/08/05
            nCont++
         EndIf

         aRet[2] := Val(EEQ->EEQ_PARC)

         EEQ->(dbSkip())
      EndDo
      aRet[4]:= nCont
   EndIf

End Sequence

RestOrd(aSaveOrd, .T.)

Return(aRet)


/*
Função      : Af200CtrRen()
Objetivo    : Fazer o controle de/efetuar renovação de saldo de L/Cs renováveis
Parametros  : nParte = 1 - calcular quanto no máximo deve ser restaurado de cada sequencia de item
                       2 - efetuar as restaurações/os abatimentos
                       3 - efetuar acertos caso todas as parcelas foram liquidadas no momento
                       4 - efetuar acertos caso todas as parcelas foram estornadas no momento
Retorno     : Nenhum
Autor       : João Pedro Macimiano Trabbold
Data e Hora : 03/08/2005 às 11:49.
*/
*--------------------------------------------*
Function Af200CtrRen(nParte,cFil,cPreemb,lFFC)
*--------------------------------------------*

Local nRec, lDesc := EasyGParam("MV_AVG0085",,.f.)
Local cLcNum, cSeqLc, cAlias, cUnid, cKey1, cKey2,;
      lInvoices, lCtProd, lCtrQtd,;
      bWhile,;
      nValor, nFator, nQtd, nVl, nOption, i,;
      aChavesEEQ := {}

//ER - 06/09/2007 - Define se o Desconto será subtraído(.T.) ou somado(.F.) no Valor Fob, quando o preço for fechado.
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)
Local cCampoDt := ""
Local cFilEEL  := ""

Default cFil    := xFilial("EEQ")
Default cPreemb := EEC->EEC_PREEMB
Default lFFC    := .f.

Begin Sequence

   If !EECFlags("ITENS_LC")
      Break
   EndIf

   EXT->(DbSetOrder(1))

   If nParte == 1

      nRec := Tmp->(RecNo())

      Tmp->(DbGoTop())
      While Tmp->(!EoF())

         If Tmp->EEQ_EVENT <> "101"
            Tmp->(DbSkip())
            Loop
         EndIf

         If ( nPos := AScan(aTotInvoice,{|x| x[1] == If(lFFC,Left(Tmp->EEQ_FILORI,2),cFil) .And. x[2] == Tmp->EEQ_NRINVO} ) ) = 0
            AAdd(aTotInvoice,{If(lFFC,Left(Tmp->EEQ_FILORI,2),cFil),Tmp->EEQ_NRINVO,0})
            nPos := Len(aTotInvoice)
         EndIf

         If AScan(aChavesEEQ,{|x| x[1]+x[2] == aTotInvoice[nPos][1]+Tmp->EEQ_PREEMB }) = 0
            AAdd(aChavesEEQ,{aTotInvoice[nPos][1],Tmp->EEQ_PREEMB})
         EndIf

         If !lFFC
            aTotInvoice[nPos][3] += Tmp->EEQ_VL
         EndIf

         Tmp->(DbSkip())
      EndDo

      Tmp->(DbGoTo(nRec))

      If lFFC
         nRec := EEQ->(RecNo())
         EEQ->(DbSetOrder(5))
         For i := 1 to Len(aTotInvoice)
            EEQ->(DbSeek(aTotInvoice[i][1]+aTotInvoice[i][2]+"101"))
            While EEQ->(!EoF()) .And. EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT) == (aTotInvoice[i][1]+aTotInvoice[i][2]+"101")
               // ** GFC - 01/12/05 - Nos loops do EEQ verificar se o processo do eeq é o mesmo do eec
               If EEQ->EEQ_PREEMB <> cPreemb
                  EEQ->(dbSkip())
                  Loop
               EndIf
               // **

               aTotInvoice[i][3] += EEQ->EEQ_VL

               EEQ->(DbSkip())
            EndDo
         Next
         EEQ->(DbGoTo(nRec))
      EndIf

      If EECFlags("INVOICE")
         EXP->(DbSetOrder(1))
         EXR->(DbSetOrder(1))
      EndIf

      EEL->(DbSetOrder(1))
      EXS->(DbSetOrder(1))
      EE9->(DbSetOrder(3))

      For i := 1 To Len(aChavesEEQ)
         If EECFlags("INVOICE") .and. EXP->(DbSeek( aChavesEEQ[i][1] + aChavesEEQ[i][2] ))
            While EXP->(!Eof()) .And. (aChavesEEQ[i][1] + aChavesEEQ[i][2] == EXP->(EXP_FILIAL+EXP_PREEMB))

               If Empty(EXP->EXP_LC_NUM)
                  EXP->(dbSkip())
                  Loop
               EndIf

               EEL->(DbSeek(aChavesEEQ[i][1]+EXP->EXP_LC_NUM))

               If EEL->EEL_RENOVA $ cNao
                  EXP->(dbSkip())
                  Loop
               EndIf

               EXR->(DbSeek(aChavesEEQ[i][1]+EXP->(EXP_PREEMB+EXP_NRINVO)))
               While EXR->(!EoF()) .And. (aChavesEEQ[i][1]+EXP->(EXP_PREEMB+EXP_NRINVO) == EXR->(EXR_FILIAL+EXR_PREEMB+EXR_NRINVO))
                  EE9->(DbSeek(aChavesEEQ[i][1]+EXR->(EXR_PREEMB+EXR_SEQEMB)))

                  //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
                  If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. EEC->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
                     EXR->(Af200HelpRen(EXR_PRCTOT - If(lDesc,EXR_VLDESC,0),EXR_SLDINI,EE9->EE9_UNIDAD,aChavesEEQ[i][1],aChavesEEQ[i][2]))
                  Else
                     EXR->(Af200HelpRen(EXR_PRCTOT + If(lDesc,EXR_VLDESC,0),EXR_SLDINI,EE9->EE9_UNIDAD,aChavesEEQ[i][1],aChavesEEQ[i][2]))
                  EndIf

                  EXR->(DbSkip())
               EndDo

               EXP->(DbSkip())
            EndDo
         Else

            EE9->(DbSeek(aChavesEEQ[i][1] + aChavesEEQ[i][2]))
            While EE9->(!EoF()) .And. (aChavesEEQ[i][1] + aChavesEEQ[i][2] == EE9->(EE9_FILIAL+EE9_PREEMB) )
               If Empty(EE9->EE9_LC_NUM)
                  EE9->(DbSkip())
                  Loop
               EndIf

               EEL->(DbSeek(aChavesEEQ[i][1]+EE9->EE9_LC_NUM))

               If EEL->EEL_RENOVA $ cNao
                  EE9->(dbSkip())
                  Loop
               EndIf

               EE9->(Af200HelpRen(Ae107CalcTot(),EE9_SLDINI,EE9_UNIDAD,aChavesEEQ[i][1],aChavesEEQ[i][2]))

               EE9->(DbSkip())
            EndDo

         EndIf

      Next

   ElseIf nParte == 2

      // para abater/restaurar saldo, temos as seguintes condições:

      If TMP->EEQ_EVENT <> "101" // 1) deve ser parcela referente a invoice
         Break
      EndIf

      //MFR 22/07/2020 OSSME-4919
      cCampoDt := if(EasyVerModal("TMP"),"EEQ_DTCE","EEQ_PGT")
      If Empty(TMP->&cCampoDt) == (Empty(EEQ->&cCampoDt))
         break
      EndIf

      If Empty(TMP->&cCampoDt)     // se é estorno
         nOption := LC_SUBTRAIR  // abate o saldo novamente
      Else                       // se é liquidação
         nOption := LC_SOMAR     // restaura o saldo
      EndIf

      nValor := Tmp->EEQ_VL
      nFator := nValor / aTotInvoice[ AScan(aTotInvoice,{|x| x[1] == cFil .And. x[2] == Tmp->EEQ_NRINVO}) ][3]

      If EECFlags("INVOICE") .and. EXP->(DbSeek(cFil + cPreemb + Tmp->EEQ_NRINVO ))
         cLcNum := EXP->EXP_LC_NUM
         If Empty(cLcNum)
            Break
         EndIf
         lInvoices := .t.
      Else
         cLcNum := EEC->EEC_LC_NUM
         If Empty(cLcNum)
            Break
         EndIf
         lInvoices := .f.
      EndIf

      cFilEEL := if(empty(xFilial("EEL")),xFilial("EEL"),cFil)
      EEL->(DbSeek(cFilEEL+cLcNum))
      If EEL->EEL_RENOVA $ cNao
         Break
      EndIf
      lCtProd := (EEL->EEL_CTPROD $ cSim)

      If lInvoices
         EXR->(DbSeek(cFil+EXP->(EXP_PREEMB+EXP_NRINVO)))
         bWhile := {|| EXR->(!EoF()) .And. (EXR->(EXR_FILIAL+EXR_PREEMB+EXR_NRINVO) == cFil+EXP->(EXP_PREEMB+EXP_NRINVO)) }
         cAlias := "EXR"
      Else
         EE9->(DbSeek(cFil + cPreemb))
         bWhile := {|| EE9->(!EoF()) .And. ( EE9->(EE9_FILIAL+EE9_PREEMB) == cFil + cPreemb ) }
         cAlias := "EE9"
      EndIf

      While Eval(bWhile)
         If lInvoices
            EE9->(DbSeek( cFil+EXR->(EXR_PREEMB+EXR_SEQEMB) ))
         EndIf

         If lCtProd
            EXS->(DbSeek(cFil+EE9->(EE9_LC_NUM+EE9_SEQ_LC) ))
            lCtrQtd := (EXS->EXS_CTRQTD $ cSim)
         Else
            lCtrQtd := .f.
         EndIf

         If lInvoices
            //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
            If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. EEC->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
               nVl := EXR->(EXR_PRCTOT - If(lDesc,EXR_VLDESC,0))
            Else
               nVl := EXR->(EXR_PRCTOT + If(lDesc,EXR_VLDESC,0))
            EndIf

            If lCtrQtd
               nQtd  := EXR->EXR_SLDINI
               cUnid := EE9->EE9_UNIDAD
            EndIf
         Else
            nVl := Ae107CalcTot()
            If lCtrQtd
               nQtd  := EE9->EE9_SLDINI
               cUnid := EE9->EE9_UNIDAD
            EndIf
         EndIf

         nVl := nVl * nFator

         If lCtrQtd
            nQtd := nQtd * nFator
         EndIf

         If lCtProd
            nAux  := Ae107AtuSld("EXS_SLDVNC",nVl,EEC->EEC_MOEDA,nOption)
            Ae107AtuSld("EXS_SLDEMB",nAux,Nil,nOption)
            Ae107AtuSld("EEL_SLDVNC",nAux,Nil,nOption)
            Ae107AtuSld("EEL_SLDEMB",nAux,Nil,nOption)
            If lCtrQtd
               nAux2 := Ae107AtuSld("EXS_QTDVNC",nQtd,Nil,nOption,cUnid)
               Ae107AtuSld("EXS_QTDVNC",nAux2,Nil,nOption)
            EndIf
            cKey1 := EXS->EXS_LC_NUM
            cKey2 := EXS->EXS_SEQUEN
         Else
            nAux  := Ae107AtuSld("EEL_SLDVNC",nVl,EEC->EEC_MOEDA,nOption)
            Ae107AtuSld("EEL_SLDEMB",nAux,Nil,nOption)
            cKey1 := EEL->EEL_LC_NUM
            cKey2 := ""
         EndIf
         // ordem 1 - EXT_FILIAL+EXT_PREEMB+EXT_LC_NUM+EXT_SEQ_LC
         If EXT->(DbSeek(cFil+cPreemb+cKey1+cKey2))
            EXT->(RecLock("EXT",.F.))
         Else
            EXT->(RecLock("EXT",.T.))
            EXT->EXT_FILIAL := cFil
            EXT->EXT_PREEMB := cPreemb
            EXT->EXT_LC_NUM := cKey1
            EXT->EXT_SEQ_LC := cKey2
            EXT->EXT_VALOR  := 0
            EXT->EXT_QTD    := 0
         EndIf

         If nOption == LC_SUBTRAIR
            nAux := -nAux
            If lCtrQtd
               nAux2 := -nAux2
            EndIf
         EndIf

         EXT->EXT_VALOR += nAux
         If lCtrQtd
            EXT->EXT_QTD += nAux2
         EndIf

         EXT->(MsUnlock())

         (cAlias)->(DbSkip())
      EndDo

   ElseIf nParte == 3 .Or. nParte == 4 // Executa acertos nas restaurações de saldo

      cLcNum := ""
      cSeqLc := ""
      // ordem 1 - EXT_FILIAL+EXT_PREEMB+EXT_LC_NUM+EXT_SEQ_LC
      EXT->(DbSeek(cFil + cPreemb))
      While EXT->(!Eof()) .And. (EXT->(EXT_FILIAL+EXT_PREEMB) == cFil + cPreemb)

         If cLcNum <> EXT->EXT_LC_NUM
            EEL->(DbSeek(cFil+EXT->EXT_LC_NUM))
            If (lCtProd := EEL->EEL_CTPROD $ cSim)
               EXS->(DbSeek(cFil+EXT->(EXT_LC_NUM+EXT_SEQ_LC)))
            EndIf
         Else
            If (lCtProd := EEL->EEL_CTPROD $ cSim) .And. cSeqLc <> EXT->EXT_SEQ_LC
               EXS->(DbSeek(cFil+EXT->(EXT_LC_NUM+EXT_SEQ_LC)))
            EndIf
         EndIf

         EXT->(RecLock("EXT",.f.))

         If nParte == 3
            If (nPos := AScan(aRestItens, {|x| x[1]+x[2]+x[3]+x[4] == EXT->(EXT_FILIAL+EXT_PREEMB+EXT_LC_NUM+EXT_SEQ_LC) } )) > 0
               nVl  := aRestItens[nPos][5] - EXT->EXT_VALOR
               nQtd := aRestItens[nPos][6] - EXT->EXT_QTD

               EXT->EXT_VALOR += nVl
               EXT->EXT_QTD   += nQtd

               If lCtProd
                  If nVl <> 0
                     Ae107AtuSld("EXS_SLDVNC",nVl,Nil,LC_SOMAR)
                     Ae107AtuSld("EXS_SLDEMB",nVl,Nil,LC_SOMAR)
                     Ae107AtuSld("EEL_SLDVNC",nVl,Nil,LC_SOMAR)
                     Ae107AtuSld("EEL_SLDEMB",nVl,Nil,LC_SOMAR)
                  EndIf
                  If EXS->EXS_CTRQTD $ cSim .And. nQtd <> 0
                     Ae107AtuSld("EXS_QTDVNC",nQtd,Nil,LC_SOMAR)
                     Ae107AtuSld("EXS_QTDVNC",nQtd,Nil,LC_SOMAR)
                  EndIf
               ElseIf nVl <> 0
                  Ae107AtuSld("EEL_SLDVNC",nVl,Nil,LC_SOMAR)
                  Ae107AtuSld("EEL_SLDEMB",nVl,Nil,LC_SOMAR)
               EndIf
            EndIf

         ElseIf nParte == 4

            nVl  := EXT->EXT_VALOR
            nQtd := EXT->EXT_QTD

            EXT->EXT_VALOR := 0
            EXT->EXT_QTD   := 0

            If lCtProd
               If nVl <> 0
                  Ae107AtuSld("EXS_SLDVNC",nVl,Nil,LC_SUBTRAIR)
                  Ae107AtuSld("EXS_SLDEMB",nVl,Nil,LC_SUBTRAIR)
                  Ae107AtuSld("EEL_SLDVNC",nVl,Nil,LC_SUBTRAIR)
                  Ae107AtuSld("EEL_SLDEMB",nVl,Nil,LC_SUBTRAIR)
               EndIf
               If EXS->EXS_CTRQTD $ cSim .And. nQtd <> 0
                  Ae107AtuSld("EXS_QTDVNC",nQtd,Nil,LC_SUBTRAIR)
                  Ae107AtuSld("EXS_QTDVNC",nQtd,Nil,LC_SUBTRAIR)
               EndIf
            ElseIf nVl <> 0
               Ae107AtuSld("EEL_SLDVNC",nVl,Nil,LC_SUBTRAIR)
               Ae107AtuSld("EEL_SLDEMB",nVl,Nil,LC_SUBTRAIR)
            EndIf

         EndIf

         cLcNum := EXT->EXT_LC_NUM
         cSeqLc := EXT->EXT_SEQ_LC

         EXT->(MsUnlock())

         EXT->(DbSkip())
      EndDo

   EndIf

End Sequence

Return Nil

/*
Função      : Af200HelpRen()
Objetivo    : Ajudar na apuração dos valores que devem ser restaurados da Carta de Crédito
Parametros  : nValor   = valor do item
              nQtde    = qtde do item
              cUnidade = Unidade de Medida de Peso do Item

Retorno     : Nenhum
Autor       : João Pedro Macimiano Trabbold
Data e Hora : 03/08/2005 às 11:26.
*/

Function Af200HelpRen(nValor,nQtde,cUnidade,cFil,cPreemb)

Begin Sequence

   If EEL->EEL_CTPROD $ cSim
      EXS->(DbSeek(cFil+EE9->(EE9_LC_NUM+EE9_SEQ_LC)))
      If EXS->(nPos := AScan(aRestItens,{|x| x[1]+x[2]+x[3]+x[4] == cFil+cPreemb+EXS_LC_NUM+EXS_SEQUEN }) ) = 0

         AAdd(aRestItens,{cFil,cPreemb,EXS->EXS_LC_NUM,EXS->EXS_SEQUEN,0,0} )
         nPos := Len(aRestItens)

      EndIf
   Else
      If EEL->(nPos := AScan(aRestItens,{|x| x[1]+x[2]+x[3] == cFil+cPreemb+EEL_LC_NUM }) ) = 0

         AAdd(aRestItens,{cFil,cPreemb,EEL->EEL_LC_NUM,CriaVar("EXS_SEQUEN"),0,0} )
         nPos := Len(aRestItens)

      EndIf
   EndIf

   aRestItens[nPos][5] += EECCalcTaxa(EEC->EEC_MOEDA,EEL->EEL_MOEDA,nValor,AvSx3("EXS_SLDVNC",AV_DECIMAL) )

   If EEL->EEL_CTPROD $ cSim .And. EXS->EXS_CTRQTD $ cSim
      aRestItens[nPos][6] += Round(AvTransUnid(cUnidade, EXS->EXS_UNIDAD, EXS->EXS_COD_I,nQtde,.f.),AvSx3("EXS_QTDVNC",AV_DECIMAL))
   EndIf

End Sequence

Return Nil


/*
Função      : AjustaComissao
Objetivo    : Ajustar os valores nos campos de tipos de comissão através do percentual de ajuste sob o valor da parcela.
Parametro   : nPercAjuste = Percentual de ajuste sob o valor da parcela.
              cAlias      = Alias da tabela que ira ser atualizada.
Retorno     : Nil
Autor       : Alexsander Martins dos Santos
Data e Hora : 03/08/2005 às 17:51.
Observação  : Caso seja uma tabela a ser atualizada, deve-se estar posicionado no registro a ser ajustado.
*/

Function AjustaComissao(nPercAjuste, cAlias, lAtribui) // ** GFC - 04/10/05 - Retirei o Static da função para ser utilizada
                                             //em outros programas
Local nPerc := 0
Local lAcrDecFlg := AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
Local lFreSegFlg := EECFlags("FRESEGCOM")

Default lAtribui := .F.

Begin Sequence   
   If !lAtribui //somatorio
      If lAcrDecFlg
         &(cAlias+"->EEQ_ACRESC") += Round(&(cAlias+"->EEQ_ACRESC") * nPercAjuste, 2)
         &(cAlias+"->EEQ_DECRES") += Round(&(cAlias+"->EEQ_DECRES") * nPercAjuste, 2)
         &(cAlias+"->EEQ_DESCON") += Round(&(cAlias+"->EEQ_DESCON") * nPercAjuste, 2)
      EndIf   
      If lFreSegFlg .And. &(cAlias+"->EEQ_EVENT") == EV_PRINC2
         &(cAlias+"->EEQ_CGRAFI") += Round(&(cAlias+"->EEQ_CGRAFI")*nPercAjuste, 2)
         &(cAlias+"->EEQ_ADEDUZ") += Round(&(cAlias+"->EEQ_ADEDUZ")*nPercAjuste, 2)
         &(cAlias+"->EEQ_AREMET") += Round(&(cAlias+"->EEQ_AREMET")*nPercAjuste, 2)            
      EndIf
   Else //atribui valores aos campos do cAlias
      If lAcrDecFlg
         &(cAlias+"->EEQ_ACRESC") := Round(&(cAlias+"->EEQ_ACRESC") * nPercAjuste, 2)
         &(cAlias+"->EEQ_DECRES") := Round(&(cAlias+"->EEQ_DECRES") * nPercAjuste, 2)
         &(cAlias+"->EEQ_DESCON") := Round(&(cAlias+"->EEQ_DESCON") * nPercAjuste, 2)       
      EndIf
      If lFreSegFlg .And. &(cAlias+"->EEQ_EVENT") == EV_PRINC2
         &(cAlias+"->EEQ_CGRAFI") := Round(&(cAlias+"->EEQ_CGRAFI")*nPercAjuste, 2)
         &(cAlias+"->EEQ_ADEDUZ") := Round(&(cAlias+"->EEQ_ADEDUZ")*nPercAjuste, 2)
         &(cAlias+"->EEQ_AREMET") := Round(&(cAlias+"->EEQ_AREMET")*nPercAjuste, 2)            
      EndIf
   EndIf     
   AF201SetVlFCam(cAlias) //Atualiza o campo valor de fechamento cambial.
End Sequence

Return(Nil)

/*
Funcao      : Af200AbTmp()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Reabrir o arquivo temporário TMP caso o ele tenha sido fechado no ponto de entrada
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 26/03/08 - 17:45
Obs.        :
*/
Function Af200AbTmp()

   If Select("TMP") == 0     

      TETempReopen(cWorkEEQ, "TMP") //THTS - 13/10/2017 - Projeto Temporario no banco de dados
      
      If EECFlags("FRESEGCOM")
         Set Index to (cWORKEEQ+TEOrdBagExt()),(cWORKEEQ2+TEOrdBagExt()),(cWORKEEQ5+TEOrdBagExt()),(cWorkEEQ6+TEOrdBagExt()) // ** JPM
      Else
         Set Index to (cWORKEEQ+TEOrdBagExt()),(cWORKEEQ2+TEOrdBagExt()),(cWORKEEQ5+TEOrdBagExt()) // ** JPM
      EndIf
   EndIf
Return

/*
Função      : BuscaMoeFin()
Objetivo    : Posiciona o Registro na Tabela de Cotação de Moedas (SYE).  -
Parametro   : cMoeda = Moeda a ser posicionada.
              dData  = Data da cotação.
Retorno     : .T. = O Registro foi posicionado.
              .F. = A moeda não foi encontrada na tabela de cotação.
Autor       : Eduardo C. Romanini
Data e Hora : 13/03/2008 às 17:02.
*/
*--------------------------------*
Function BuscaMoeFin(cMoeda,dData)
*--------------------------------*
Local lRet := .F.

Begin Sequence

   SYE->(DbSetOrder(2))
   //Pesquisa pela moeda e pela data informada.
   If SYE->(dbSeek(xFilial("SYE")+cMoeda+DtoS(dData)))
      lRet := .T.
      Break
   //Posiciona no ultimo registro da moeda, caso não encontre a data passada como parâmetro..
   ElseIf SYE->(AvSeekLast(xFilial("SYE")+cMoeda))
      lRet := .T.
      Break
   EndIf

End Sequence

Return lRet

*------------------------------------*
Function AF200AutoVincAd(aAdEFF,cTipo)
*------------------------------------*
Local lRet := .T.

Local nInc := 0
Local cC6_TXCV

Private lAF200Auto := .T.
Private bAF200Auto
Private bEQAuto

Begin Sequence

   For nInc := 1 To Len(aAdEFF)

      TMP->(DbSetOrder(1))
      If TMP->(DbSeek(aAdEFF[nInc]))

         If cTipo == "INC_VINC"

            //////////////////////////////////////////////
            //Vinculação com o Contrato no Financiamento//
            //////////////////////////////////////////////

            bAF200Auto := {|| WorkEEQ->EF2_CONTRA := TMP->EEQ_NRINVO,M->EF2_CONTRA := AllTrim(TMP->EEQ_NRINVO), ValFina("CONTRA")}

            GrvWkEEQ("VINC")

            Faf200Vinc("INCLUIR")

            /////////////////////////////////////////
            //Liquidação da Parcela de Adiantamento//
            /////////////////////////////////////////
            cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV")
            bEEQAuto := {|| M->EEQ_PGT := EEC->EEC_DTEMBA, M->EEQ_TX := BuscaTaxa(TMP->EEQ_MOEDA,EEC->EEC_DTEMBA,,,,,cC6_TXCV), M->EEQ_EQVL := M->EEQ_VL * M->EEQ_TX}

            AF200DetMan(LIQ_DET)

         ElseIf cTipo == "EST_LIQ"

            ////////////////////////////////////////////////////
            //Estorno da Liquidação da Parcela de Adiantamento//
            ////////////////////////////////////////////////////

            bEEQAuto := {|| }

            AF200DetMan(ELQ_DET)

         ElseIf cTipo == "EST_VINC"

            /////////////////////////////////////////////////
            //Desvinculação com o Contrato no Financiamento//
            /////////////////////////////////////////////////
            bAF200Auto := {|| WorkEEQ->(DbSetOrder(2)), WorkEEQ->(DbSeek(TMP->EEQ_NRINVO + TMP->EEQ_PARC)),FAF2EstVinc()}

            GrvWkEEQ("EST")

            FAF200Vinc("ESTORNAR")

         EndIf

      EndIf
   Next

End Sequence

Return lRet

/*
Função      : AF200AtualTit()
Objetivo    : Atualizar os títulos NF no módulo SigaFin quando houver liquidação de adiantamentos
              pós embarque
Parametro   : Array com os RecNo's das parcelas a serem alteradas
Retorno     : .T. se a integração foi realizada com sucesso
              .F. se a integração não foi realizada
Autor       : Wilsimar Fabrício
Data e Hora : 12/08/11
*/
Function AF200AtualTit(aRecPosEmb)
Local aOrd:= SaveOrd({"EEQ", "SE1"})
Local lRet:= .T.
Local nCont
Private cParcAF200Bx:= AvKey(" ", "E1_PARCELA")

Begin Sequence

   SE1->(DBSetOrder(1))
   For nCont:= 1 To Len(aRecPosEmb)

      EEQ->(DBGoTo(aRecPosEmb[nCont]))
      cParcAF200Bx := EECGetFinParc(EEQ->EEQ_PARC)
      //TRP - 22/12/2011 - Ponto de Entrada para tratar o campo Parcela do Título a ser Alterado.
      If EasyEntryPoint("EECAF200")
         ExecBlock("EECAF200", .F., .F., "ALTERA_PARCELA")
      EndIf

      If !IsIntEnable("001") .OR. SE1->(DBSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+cParcAF200Bx+AvKey("NF","E1_TIPO"))) .And.;
         (EEQ->EEQ_VL-EEQ->EEQ_CGRAFI) <> SE1->E1_VALOR

         If !AvStAction("006")//Alteração de título a receber no SIGAFIN
            lRet:= .F.
            Break
         EndIf

      EndIf

   Next

End Sequence

RestOrd(aOrd, .T.)
Return lRet

Function EECRatItEmb(cPreemb, nValor)
Local aRet := {}
Local aOrd := SaveOrd({"EEC", "EE9"})
Local nPos := 0 , nTotValCalc := 0
Local cCCusto := ""
Local nVlr := 0
Local nComDedEmb //NCF - 16/08/2019 - Apurar valor de comissão a deduzir para rateio

   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(xFilial("EEC")+AvKey(cPreemb,"EEC_PREEMB") ))

      EE9->(DbSetOrder(3))
      EE9->(DbSeek(xFilial("EE9")+EEC->EEC_PREEMB))

	  nComDedEmb := AE102CalcAg("EEB" , xFilial("EEB")+AvKey( EEC->EEC_PREEMB ,"EEB_PEDIDO")+"Q" ) //NCF - 16/08/2019

      While EE9->(!Eof() .And. EE9_FILIAL+EE9_PREEMB == xFilial()+EEC->EEC_PREEMB)

         If EES->(FieldPos('EES_CCERP')) > 0
            cCCusto := Posicione('EES',1,xFilial('EES')+AvKey(EE9->EE9_PREEMB,'EES_PREEMB')+AvKey(EE9->EE9_NF,'EES_NRNF')+AvKey(EE9->EE9_SERIE,'EES_SERIE')+AvKey(EE9->EE9_PEDIDO,'EES_PEDIDO')+AvKey(EE9->EE9_SEQUEN,'EES_SEQUEN'),'EES_CCERP')
         EndIf

         If Empty(cCCusto)
            cCCusto := Posicione('EYJ',1,xFilial('EYJ')+AvKey(EE9->EE9_COD_I,'EYJ_COD'),'EYJ_CCERP')
         EndIf

         If (nPos := aScan(aRet, {|x| x[1] == cCCusto })) == 0
            aAdd(aRet, {cCCusto, 0})
            nPos := Len(aRet)
         EndIf

         nVlr := Round((EE9->EE9_PRCTOT/ (EEC->EEC_TOTPED + nComDedEmb) ) * nValor, 2)
         aRet[nPos][2] += nVlr
         nTotValCalc += nVlr

         EE9->(DbSkip())
      EndDo

      If Len(aRet) > 0 .And. nValor <> nTotValCalc
         aRet[Len(aRet)][2] += (nValor - nTotValCalc)
      EndIf

   EndIf

RestOrd(aOrd, .T.)
Return aClone(aRet)

Function EasyHolderCode(cBancoContrato,cAgenContrato,cContaContrato,cBancoMov,cAgenMov,cContaMov,cTpModu,cEvento,cCodCli,cLojaCli,cForn,cLojaForn,cTpCont)
Local nOrderECI := ECI->(IndexOrd())
Local nRecECI := ECI->(Recno())
//Local cTpCont := ""
Local cRet := ""
Default cTpCont := "1" // 1 - Conta Principal

Begin Sequence


   //If lAdiantamento
      //cTpCont := "A" // A - Adiantamento
   //EndIf

   ECI->(DbSetOrder(2)) // ECI_FILIAL+ECI_BANCOD+ECI_AGENCI+ECI_NUMCON+ECI_TPMODU+ECI_TPCONT
   If ECI->(DbSeek(xFilial('ECI')+AvKey(cBancoMov,"ECI_BANCOD")+AvKey(cAgenMov,"ECI_AGENCI")+AvKey(cContaMov,"ECI_NUMCON")+AvKey(cTpModu,"ECI_TPMODU")+AvKey(cTpCont,"ECI_TPCONT")))
      cRet := ECI->ECI_PORTAD
   EndIf

   /*If lAdiantamento .And. Empty(cRet) .And. EasyGParam("MV_AVG0215",.T.)
      cRet := EasyGParam("MV_AVG0215",.T.,"")
   EndIf*/

   /*If lAdiantamento
      cRet := "900"
   Else
     cRet := "0001"
   EndIf*/

End Sequence

ECI->(DbSetOrder(nOrderECI))
ECI->(DbGoTo(nRecECI))

//Verificar se esta vinculado com EFF
Return cRet

Function EasyTypeHolder(cBancoContrato,cAgenContrato,cContaContrato,cBancoMov,cAgenMov,cContaMov,cTpModu,cEvento,cCodCli,cLojaCli,cForn,cLojaForn,cTpCont)
Local nOrderECI := ECI->(IndexOrd())
Local nRecECI := ECI->(Recno())

//Local cTpCont := ""
Local cRet := ""

Begin Sequence

   Default cTpCont := "1" // 1 - Conta Principal
   /*If lAdiantamento
      cTpCont := "A" // A - Adiantamento
   EndIf*/

   ECI->(DbSetOrder(2))
   If  ECI->(DbSeek(xFilial('ECI')+AvKey(cBancoMov,"ECI_BANCOD")+AvKey(cAgenMov,"ECI_AGENCI")+AvKey(cContaMov,"ECI_NUMCON")+AvKey(cTpModu,"ECI_TPMODU")+AvKey(cTpCont,"ECI_TPCONT")))
      cRet := ECI->ECI_TPPORT
   EndIf

   /*If lAdiantamento .And. Empty(cRet) .And. EasyGParam("MV_AVG0216",.T.)
      cRet := EasyGParam("MV_AVG0216",,"")
   EndIf*/

   /*   If lAdiantamento
      cRet := "C"
   Else
      cRet := "B"
   EndIf*/

End Sequence

ECI->(DbSetOrder(nOrderECI))
ECI->(DbGoTo(nRecECI))

//Verificar se esta vinculado com EFF
Return cRet

Function AF200RetLiq(aRegistro,cFuncName,nOpc,cChamada)
Local nOrder := EEQ->(IndexOrd())
Local nRecno := EEQ->(Recno())
Local nPos
Local i
Default aRegistro := {}

   DO CASE
      CASE cFuncName == 'EECAF210' // Inclusão/Exclusão de título a receber
          nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
          AF200BKPInt('EEQ' , 'EEC_MNCT_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )

      CASE cFuncName $ 'EECAF233' // Baixa de Título a receber
         if !empty(EEQ_PGT)
            nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
            AF200BKPInt('EEQ' , 'EEQ_MOV_EXT_BXA', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )
         else
            nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
            AF200BKPInt('EEQ' , 'EEQ_MOV_EXT_EST', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )
         endif

      CASE cFuncName $ 'EECAF213' // Baixa de Título a receber
          nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
          AF200BKPInt('EEQ' , 'EEC_INBX_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )

      CASE cFuncName $ 'EECAF221' // Estorno de Baixa de Título a receber
          nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
          AF200BKPInt('EEQ' , 'EEC_ESBX_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )

      //THTS - 19/04/2017 - Se deu erro na compensacao do adiantamento a fornecedores
      CASE cFuncName $ 'EECAF215|EECAF521|EECAF227' // Baixa de Título a pagar
          nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
          AF200BKPInt('EEQ' , 'EEC_INBX_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )
          
      //THTS - 19/04/2017 - Se deu erro no estorno da compensacao do adiantamento a fornecedores
      CASE cFuncName $ 'EECAF222|EECAF522|EECAF230' // Estorno de Baixa de Título a pagar
          nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
          AF200BKPInt('EEQ' , 'EEC_ESBX_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )

      CASE cFuncName == 'EECAF217' // Inclusão/Alteração em contrato
          nPos := aScan(aRegistro,{|X| X[EF1->(FieldPos("EF1_CONTRA"))] == EF1->EF1_CONTRA})
          AF200BKPInt('EF1' , 'EFF_MNCT_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )

      CASE cFuncName == 'EECAF218' // Inclusão/Exclusão de Parc. Princ/ Parc. Juros/ Encargos de contrato
         If cChamada $ 'CAMBIO/FFC'
            nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
            If nOpc == 3
               AF200BKPInt('EEQ' , 'EEC_INBX_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)),                        , .F. )
               AF200BKPInt('EF3' , 'EEC_INBX_INC',                , {'EEQ',EEQ->(Recno())} , .F. )
            Else
               AF200BKPInt('EEQ' , 'EEC_ESBX_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)),                       , .F. )
               AF200BKPInt('EF3' , 'EEC_ESBX_DEL',                , {'EEQ',EEQ->(Recno())}, .F. )
            EndIf
         ElseIf cChamada == 'MANUTCONTR'
            If nOpc == 3
               AF200BKPInt('EF3' , 'EFF_MNCT_INC',  , {'EF1',EF1->(Recno())} , .F. )
            Else
               AF200BKPInt('EF3' , 'EFF_MNCT_DEL',  , {'EF1',EF1->(Recno())} , .F. )
            EndIf
         EndIf

      CASE cFuncName == 'EECAF226' // Liquidação de Parc. Princ/ Parc. Juros/ Encargos de contrato
         If cChamada $ 'CAMBIO/FFC'
            nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
            AF200BKPInt('EEQ' , 'EEC_INBX_ALT'         , If(nPos <> 0,aRegistro[nPos],Array(0)),                        , .F. )
            AF200BKPInt('EF3' , 'EEC_INBX_INC',                , {'EEQ',EEQ->(Recno())} , .F. )
         ElseIf cChamada == 'MANUTCONTR'
            AF200BKPInt('EF3' , 'EFF_MNCT_INC' ,  , {'EF1',EF1->(Recno())} , .F. )
         EndIf

      CASE cFuncName == 'EECAF229' // Estorno de Liquidação de Parc. Princ/ Parc. Juros/ Encargos de contrato
         If cChamada $ 'CAMBIO/FFC'
            nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
            AF200BKPInt('EEQ' , 'EEC_ESBX_ALT' , If(nPos <> 0,aRegistro[nPos],Array(0)),                        , .F. )
            AF200BKPInt('EF3' , 'EEC_ESBX_DEL' ,                                       , {'EEQ',EEQ->(Recno())} , .F. )
         ElseIf cChamada == 'MANUTCONTR'
            AF200BKPInt('EF3' , 'EFF_MNCT_DEL' ,  , {'EF1',EF1->(Recno())} , .F. )
         EndIf

      CASE cFuncName == 'EECAF231'// Liquidação da parcela de comissão conta gráfica manual
          nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
          AF200BKPInt('EEQ' , 'EEC_INBX_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )

      CASE cFuncName == 'EECAF232'// Estorno da liquidação da parcela de comissão conta gráfica manual
          nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
          AF200BKPInt('EEQ' , 'EEC_ESBX_ALT', If(nPos <> 0,aRegistro[nPos],Array(0)), , .F. )

      CASE cFuncName == 'EECLC510'
            nPos := aScan(aRegistro,{|X| X[EEQ->(FieldPos("EEQ_PARC"))] == EEQ->EEQ_PARC})
            If nOpc == 3
               AF200BKPInt('EEQ' , 'EEC_INBX_ALT'         , If(nPos <> 0,aRegistro[nPos],Array(0)),                        , .F. )
               AF200BKPInt('ECF' , 'EEC_INBX_INC'         ,                                       , {'EEQ',EEQ->(Recno())} , .F. )
            Else
               AF200BKPInt('EEQ' , 'EEC_ESBX_ALT'         , If(nPos <> 0,aRegistro[nPos],Array(0)),                        , .F. )
               AF200BKPInt('ECF' , 'EEC_ESBX_DEL'         ,                                       , {'EEQ',EEQ->(Recno())} , .F. )
            EndIf

   ENDCASE

Return

/*
Função     : AF200SE1Integ
Parâmetros : nOpc-> Opção da manutenção (Incluir/Alterar/Excluir)
Retorno    : lRet -> .T./.F.
Objetivos  : Chamada atraves do EasyLink, tem o objetivo de integrar alterações de
             títulos gerados do módulo EEC com o módulo Financeiro (FIN).
Autor      : Felipe Sales Martinez - FSM
Data/Hora  : 02/08/12 - 12:10
Revisao    :
Obs.       :
*/
Function AF200SE1Integ(nOpc)
Local lRet := .T.
Local aSE1 := {}
Local cError := "", cNum := "", cParc := "", cOpc := ""
Local nValor := 0, nTaxa := 0, nVlCruz := 0, nMoeda := 0
Local dVencRea := cToD("  /  /  "), dEvento := cToD("  /  /  "), dVencOri := cToD("  /  /  ")
Local cC6_TXCV
Private lCpoAcrDcr := IF(Type("lCpoAcrDcr") == "U" , AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") ,lCpoAcrDcr)
cNum      := If(EECFlags("TIT_PARCELAS").And.!Empty(EEC->EEC_TITCAM), EEC->EEC_TITCAM, If(nOpc==3,EECGetFinN(),EEQ->EEQ_FINNUM)) //FSM - 28/08/2012
cParc     := EECGetFinParc(EEQ->EEQ_PARC)
dEvento   := If(Empty(EEQ->EEQ_VCT),EEQ->EEQ_PGT,EEQ->EEQ_VCT)
dVencRea  := DataValida(dEvento ,.T.)
dVencOri  := dEvento
nValor    := EEQ->EEQ_VL - EEQ->EEQ_CGRAFI
cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+EEQ->EEQ_EVENT,"EC6_TXCV")
nTaxa     := BuscaTaxa(EEQ->EEQ_MOEDA,If(EEQ->(FieldPos("EEQ_EMISSA"))>0,EEQ->EEQ_EMISSA,dDataBase),,,,,cC6_TXCV) //RRC - Alterado para considerar a Data de Emissão para o BuscaTaxa()
nVlCruz   := nValor*nTaxa
nMoeda    := VAL(SYE->YE_MOE_FIN)
cNatureza := If(!Empty(Posicione("SA1", 1, xFilial("SA1")+EEQ->(EEQ_IMPORT+EEQ_IMLOJA), "A1_NATUREZ")), Posicione("SA1", 1, xFilial("SA1")+EEQ->(EEQ_IMPORT+EEQ_IMLOJA), "A1_NATUREZ"), EasyGParam("MV_AVG0178",, "AVG"))


/* RMD - 06/10/12 - Somente altera a data de vencimento de título. As demais informações não podem ser alteradas, e o valor, quando alterado no cambio,
                    será transferido para as parcelas filhas, referenciadas ao mesmo título.
*/
aAdd(aSE1, { "E1_FILIAL"  , xFilial("SE1")          , Nil } )
aAdd(aSE1, { "E1_NUM"     , cNum                    , Nil } )
aAdd(aSE1, { "E1_PREFIXO" , "EEC"                   , Nil } )
aAdd(aSE1, { "E1_PARCELA" , cParc                   , Nil } )
aAdd(aSE1, { "E1_TIPO"    , "NF"                    , Nil } )
//aAdd(aSE1, { "E1_NATUREZ" , cNatureza               , Nil } )
aAdd(aSE1, { "E1_CLIENTE" , EEQ->EEQ_IMPORT         , Nil } )
aAdd(aSE1, { "E1_LOJA"    , EEQ->EEQ_IMLOJA         , Nil } )
//aAdd(aSE1, { "E1_EMISSAO" , EEC->EEC_DTEMBA         , Nil } )
aAdd(aSE1, { "E1_VENCTO"  , dEvento                 , Nil } )
aAdd(aSE1, { "E1_VENCREA" , dVencRea                , Nil } )
//aAdd(aSE1, { "E1_VENCORI" , dVencOri                , Nil } )
//aAdd(aSE1, { "E1_VALOR"   , nValor                  , Nil } )
//aAdd(aSE1, { "E1_EMIS1"   , EEC->EEC_DTEMBA         , Nil } )
//aAdd(aSE1, { "E1_TXMOEDA" , nTaxa                   , Nil } )
//aAdd(aSE1, { "E1_VLCRUZ"  , nVlCruz                 , Nil } )
//aAdd(aSE1, { "E1_MOEDA"   , nMoeda                  , Nil } )
//aAdd(aSE1, { "E1_HIST"    , "Emb.:"+EEC->EEC_PREEMB , Nil } )
//aAdd(aSE1, { "E1_BCOCLI"  , EEQ->EEQ_BANC           , Nil } )
//aAdd(aSE1, { "E1_ORIGEM"  , INT101RetMod()          , Nil } )

If lCpoAcrDcr
   aAdd(aSE1, { "E1_ACRESC"  , EEQ->EEQ_ACRESC         , Nil } )
   aAdd(aSE1, { "E1_DECRESC" , EEQ->EEQ_DECRES         , Nil } )
EndIf

if nOpc == 4 .and. EECFLAGS('ALT_EASYLINK') .and. FwIsInCallStack("EECFAT3")
   aAdd(aSE1, { "E1_VALOR"   , nValor                  , Nil } )
   aAdd(aSE1, { "E1_TXMOEDA" , nTaxa                   , Nil } )
   aAdd(aSE1, { "E1_VLCRUZ"  , nVlCruz                 , Nil } )
endif

If nOpc == 3
   cOpc := "INCLUIR"
ElseIf nOpc == 4
   cOpc := "ALTERAR"
ElseIf nOpc == 5
   cOpc := "EXCLUIR"
EndIf

If (lRet := Empty( cError := EECInFin(aSE1, "SE1", cOpc) ) )
   If !EEQ->(IsLocked())
      If EEQ->( RecLock("EEQ", .F.) )
         EEQ->EEQ_FINNUM := cNum
         EEQ->( MSUnlock() )
      EndIf
   Else
      EEQ->EEQ_FINNUM := cNum
   EndIf

Else
   EECView(STR0251+ Lower(cOpc) +STR0252+cNum+"-"+cParc+"."+Replic(ENTER,2)+cError,STR0253,STR0253) //#STR0251 -> "Não foi possível " ##STR0252->" o título no financeiro: " ###STR0253->"Mensagens"
EndIf

Return lRet

/*
Function  : AF200GetLastVct(cPreemb, cOrigem, cParc)
Parâmetros: cPreemb - Código do Embarque referente à parcela
            cOrigem - Código da parcela de origem
            cParc   - Código da parcela atual (será desconsiderada na busca, caso a mesma estiver sendo atualizada)
Autor     : Rodrigo Mendes Diaz
Data      : 06/10/12
*/
Function AF200GetLastVct(cPreemb, cOrigem, cParc)
Local aOrd := SaveOrd("EEQ")
Local dVct := Nil
Default cParc := ""

	EEQ->(DbSetOrder(1))
	EEQ->(DbSeek(xFilial()+cPreemb))
	While EEQ->(!Eof() .And. EEQ_FILIAL+EEQ_PREEMB == xFilial()+cPreemb)
		If EEQ->EEQ_PARVIN == cOrigem .And. EEQ->EEQ_PARC <> cParc
			If dVct == Nil .Or. EEQ->EEQ_VCT > dVct
				dVct := EEQ->EEQ_VCT
			EndIf
		EndIf
		EEQ->(DbSkip())
	EndDo

	//Caso não encontre a parcela de origem ou as parcelas vinculadas a ela, retorna a data da própria parcela
	If dVct == Nil .And. !Empty(cParc) .And. EEQ->(DbSeek(xFilial()+cPreemb+cParc))
		dVct := EEQ->EEQ_VCT
	EndIf


RestOrd(aOrd, .T.)
Return dVct

/*
Função     : AF200ParcLiq
Parâmetros : cKey - Chave para Seek na tabela EEQ, sempre na ordem 1 (EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE)
Retorno    : lRet -> .T./.F.
Objetivos  : Verificar se a parcela de câmbio já está liquidada.
Autor      : Allan Oliveira Monteiro - AOM
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
*-------------------------*
Function AF200ParcLiq(cKey)
*-------------------------*
Local lRet := .F.
Default cKey := "" // BAK - 24/09/12

// EEQ->(DbSetOrder(1))//EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE // BAK - 24/09/2012

If !Empty(cKey)
   EEQ->(DbSetOrder(1))//EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
   EEQ->(DbSeek(cKey))
EndIf

If EEQ->(!EOF())

   If EasyVerModal("EEQ") //EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->EEQ_MODAL == "2"
      If !Empty(EEQ->EEQ_DTCE) //Data de Credito no Exterior
         lRet:= .T.
      EndIf
   Else
      If !Empty(EEQ->EEQ_PGT) // Data de Liquidação
         lRet:= .T.
      EndIf
   EndIf
EndIf


Return lRet

/*
Função     : AF200DtEmissa
Parâmetros : Nil
Retorno    : lRet -> .T./.F.
Objetivos  : Retornar a data de emissao da parcela, função utilizada no EasyLink
Autor      : Bruno Akyo Kubagawa - BAK
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
Function AF200DtEmissa()
Local dData := cToD("")
                                                                                             /*---------------------Se for uma parcela referente a associacao de adto ao embarque-----------------------------*/
If EEQ->(FieldPos("EEQ_EMISSA")) > 0 .And. EEQ->(!EOF()) .And. !Empty(EEQ->EEQ_EMISSA) .And. !(EasyGParam("MV_EEC0042",,.F.) .And. EEQ->EEQ_TIPO == "A" .AND. EEQ->EEQ_FASE == "E" .AND. Empty(EEQ->EEQ_FINNUM))
   dData := EEQ->EEQ_EMISSA
Else
   dData := EEC->EEC_DTEMBA
EndIf

Return dData

/*
Função     : AF200DtVec
Parâmetros : Nil
Retorno    : lRet -> .T./.F.
Objetivos  : Retornar a data de vencimento da parcela, função utilizada no EasyLink
Autor      : Tiago Tudisco
Data/Hora  : 09/10/2018
Revisao    :
Obs.       :
*/
Function AF200DtVec()
Local dData := IIf (Empty(EEQ->EEQ_VCT),EEQ->EEQ_PGT,EEQ->EEQ_VCT)

If AF200DtEmissa() > dData
   dData := AF200DtEmissa()
EndIf

Return dData



/*
Função     : AF200HisEmb
Parâmetros : Nil
Retorno    : cHist -> historico onde indica o processo
Objetivos  : Retornar o numero do embarque para a integração, caso esteja posicionado na EEQ ou EEC
Autor      : Bruno Akyo Kubagawa - BAK
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
Function AF200HisEmb()
Local cHist := ""

If EEQ->(!EOF()) .And. !Empty(EEQ->EEQ_PREEMB)
   cHist := 'Emb.:' + EEQ->EEQ_PREEMB
Else
   cHist := 'Emb.:' + EEC->EEC_PREEMB
EndIf

Return cHist

/*
Função     : AF200Banco
Parâmetros : Nil
Retorno    : 1 = Banco ,  2 = Agencia , 3 = Conta
Objetivos  : Retorna o banco, agencia ou a conta, função utilizada no easylink
Autor      : Bruno Akyo Kubagawa - BAK
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
Function AF200Banco(cParametro)
Local cDado := ""
Local cBanco := ""
Local cAgencia := ""
Local cConta := ""

Begin Sequence

   If Valtype(cParametro) <> "C"
      Break
   EndIf

   If EEQ->(!EOF())
      //If EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->(FieldPos("EEQ_BCOEXT")) > 0 .And. ;
      //   EEQ->(FieldPos("EEQ_CNTEXT")) > 0 .And. EEQ->(FieldPos("EEQ_AGCEXT")) > 0 .And. ;
      //   EEQ->EEQ_MODAL == "2" // Movimento de crédito no Exterior
      If EasyVerModal().And. EEQ->(FieldPos("EEQ_BCOEXT")) > 0 .And. ;
         EEQ->(FieldPos("EEQ_CNTEXT")) > 0 .And. EEQ->(FieldPos("EEQ_AGCEXT")) > 0
         cBanco := EEQ->EEQ_BCOEXT
         cAgencia := EEQ->EEQ_AGCEXT
         cConta := EEQ->EEQ_CNTEXT
      Else  // Contrato de Cambio
         cBanco := EEQ->EEQ_BANC
         cAgencia := EEQ->EEQ_AGEN
         cConta := EEQ->EEQ_NCON
      EndIf
   EndIf

   cParametro := AllTrim(Upper(cParametro))
   Do Case
      Case cParametro == "1" // Banco
         cDado := cBanco
      Case cParametro == "2" // Agencia
         cDado := cAgencia
      Case cParametro == "3" // Conta
         cDado := cConta
   EndCase

End Sequence

Return cDado

/*
Função     : AF200AutValRec
Parâmetros : Nil
Retorno    : nValor -> Valor da parcela em reais
Objetivos  : Retorna o valor da baixa, função utilizada no easylink
Autor      : Bruno Akyo Kubagawa - BAK
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
Function AF200AutValRec()
Local nValor := 0
Local nDecimais := TAMSX3("EEQ_EQVL")[2]
Private lCpoAcrDcr:= IF(!IsMemVar("lCpoAcrDcr"), AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") ,lCpoAcrDcr) //LRS - 26/10/2018

Begin Sequence

   If Type("nValorBaixa") == "N"                               //NCF - 30/09/2015
      nValor := If(EasyVerModal() .And. !Empty(EEQ->EEQ_DTCE), EEQ->EEQ_VL-EEQ->EEQ_CGRAFI +;
      If( lCpoAcrDcr, (EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES) + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON , 0), nValorBaixa) //LRS - 26/10/2018
      Break
   EndIf

   If EEQ->(!EOF())
      //nValor := EEQ->EEQ_EQVL
      If EEQ->EEQ_EQVL = 0
         nValor := Round(EEQ->EEQ_VL * AF200VLTX(),nDecimais)
      Else
         nValor := EEQ->EEQ_EQVL
      EndIf
   EndIf

End Sequence

Return nValor

/*
Função     : AF200DtBaixa
Parâmetros : cAlias - EEQ ou M
Retorno    : dData -> data da baixa
Objetivos  : Retorna a data da baixa, caso seja data credito no exterior ou data de liquidacao,
             função utilizada no easylink
Autor      : Bruno Akyo Kubagawa - BAK
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
Function AF200DtBaixa(cAlias)
Local dData := cToD("")
Default cAlias := "EEQ"

If EasyVerModal(cAlias) //EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. &(cAlias+"->EEQ_MODAL") == "2"
   dData := &(cAlias+"->EEQ_DTCE") //Data de Credito no Exterior
Else
   dData := &(cAlias+"->EEQ_PGT") // Data de Liquidação
EndIf

Return dData

Function EECVlNFCC(cPreemb, cNota, cSerie,lGeraLanc, nIni)
Local aRet := {}
Local aOrd := SaveOrd("EES")
Local cCCusto := ""
Local nPos := 0
Default lGeraLanc := .F.
Default nIni := 0

   EES->(DbSetOrder(1)) // EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE+EES_PEDIDO+EES_SEQUEN
   EES->(DbSeek(xFilial("EES")+AvKey(cPreemb,"EES_PREEMB")+AvKey(cNota,"EES_NRNF")+AvKey(cSerie,"EES_SERIE")))
   Do While EES->(!Eof()) .And. EES->(EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE) == xFilial("EEM")+EEM->EEM_PREEMB+EEM->EEM_NRNF+EEM->EEM_SERIE

      If EES->(FieldPos('EES_CCERP')) > 0 .And. !Empty(EES->EES_CCERP)
         cCCusto := EES->EES_CCERP
      Else
         cCCusto := Posicione('EYJ',1,xFilial('EYJ')+AvKey(EES->EES_COD_I,'EYJ_COD'),'EYJ_CCERP')
      EndIf

      If (nPos := aScan(aRet, {|x| x[1] == cCCusto })) == 0
         aAdd(aRet, {cCCusto,;
		             0,;
					 if(lGeraLanc,AllTrim(Str(Len(aRet)+1+nIni)),EES->EES_LANCAM),;
					 EES->EES_RELACA})
         nPos := Len(aRet)
      EndIf

	  If lGeraLanc
         If EES->(RecLock("EES",.F.))
            EES->EES_LANCAM := aRet[nPos][3]
            EES->(MsUnlock())
         EndIf
	  EndIf

      EE9->(DbSetOrder(2)) // EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN
      EE9->(DbSeek(xFilial('EE9')+AvKey(cPreemb,"EE9_PREEMB")+AvKey(EES->EES_PEDIDO,"EE9_PEDIDO")+AvKey(EES->EES_SEQUEN,"EE9_SEQUEN")))

      // Valor em moeda
      //aRet[nPos][2] += EE9->EE9_PRECO*EES->EES_QTDE
	  //aRet[nPos][2] += EE9->EE9_PRCTOT*EES->EES_QTDE
	  aRet[nPos][2] += EE9->EE9_PRCUN*EES->EES_QTDE

      EES->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)

Return aClone(aRet)

/*
Função     : AF200Descr
Parâmetros : cEvento - EEQ ou M
Retorno    : cDescr - Descricao
Objetivos  : Retornar a descricao do evento no inicializador padrao ou inicializador do browse
Autor      : Bruno Akyo Kubagawa - BAK
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
Function AF200Descr(cEvento)
Local cDescr := ""
Local cTpModu := "EXPORT"
Local aOrd := SaveOrd("EC6")

If IsInCallStack("EECAF200") .and. SELECT("TMP") > 0 .And. TMP->(!Eof()) .And. TMP->(!Bof())  //NCF - o Metodo Refresh( ) executa a atualização dos registro no browser fazendo loop na tabela
   cEvento := TMP->EEQ_EVENT                                                                  //      Temporária onde dese ser obtido o evento do câmbio posicionado, pois a Memória e tabela EEQ
EndIf                                                                                         //      neste momento estão fixas isso faz com que a mesma descrição seja gravada em todas as parcelas.

If IsInCallStack("ESSRS400") .Or. IsInCallStack("ESSRS403") .Or. IsInCallStack("ESSPS401") .Or. IsInCallStack("ESSPS400") .Or. IsInCallStack("ESSIN100") .Or. (IsInCallStack("EECAF900") .And. EEQ->EEQ_SOURCE = "ESS")
   cTpModu := "SISCSV"
EndIf

EC6->(dbSetOrder(6))
If EC6->(dbSeek(xFilial("EC6")+cTpModu+cEvento))
   cDescr := EC6->EC6_DESC
EndIf

RestOrd(aOrd,.T.)

Return cDescr

/*
Função     : AF200VLTX
Parâmetros :
Retorno    : Retornar o valor da taxa
Objetivos  : Retornar de acordo com a modalidade, ou seja, movimento no exterior ou contrato de cambio o valor da taxa do dia.
             Caso seja movimento no exterior, buscar a taxa de acordo com a data de crédito. Senão enviar a taxa do campo EEQ_TX
Autor      : Bruno Akyo Kubagawa - BAK
Data/Hora  : 23/08/12 - 14:55
Revisao    :
Obs.       :
*/
Function AF200VLTX()
Local nValorTx := 0
Local aOrdSA6  := SaveOrd({"SA6"})
Local cC6_TXCV 

If EEQ->(!EOF())
   If AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal() //EEQ->(FieldPos("EEQ_MODAL")) > 0 .And. EEQ->EEQ_MODAL == "2"
      SA6->(DbSetOrder(1))
      SA6->(DbSeek(xFilial("SA6")+EEQ->(EEQ_BCOEXT+ EEQ_AGCEXT+ EEQ_CNTEXT))) //LGS-18/05/2015
      If !Empty(EEQ->EEQ_DTCE) //Data de Credito no Exterior
         If !IsReceita(EEQ->EEQ_EVENT) //.And.  EEQ->EEQ_MOEDA <> SA6->A6_MOEEASY //NCF - 11/09/2015 - No caso de contas a pagar com movimento no exterior deve pegar a taxa
            If !Empty(EEQ->EEQ_PGT) // Data de Liquidação                         //                   (paridade) negociada quando a moeda da invoice é diferente da moeda do banco
               nValorTx := Round(EEQ->EEQ_VLMBCO/AF200VLFCAM("EEQ"),TAMSX3(If(IntegFIN(cModulo),"E1_TXMOEDA","EEQ_PRINBC"))[2])  //EEQ->EEQ_TX  //NCF - 10/11/2015 - a Paridade a ser enviada como taxa para que o SIGAFIN faça a baixa na moeda do banco é campo virtual,
            EndIf                                                                                                         //                     portanto é necessário recuperar pelos valores da invoice e na moeda do banco.
         Else
            If SE1->E1_MOEDA > 1
               nValorTx :=  RecMoeda(dDATABASE,SE1->E1_MOEDA)
            Else
               //RMD - 13/01/15 - Não há variação cambial caso o título em moeda estrangeira seja recebido em uma conta com a mesma moeda (banco no exterior deverá ser sempre na moeda do título).
               cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+M->EEQ_EVENT,"EC6_TXCV")               
               nValorTx := Round( BuscaTaxa(EEQ->EEQ_MOEDA,EEQ->EEQ_DTCE,,,,,cC6_TXCV) , TAMSX3(If(IntegFIN(cModulo),"E1_TXMOEDA","EEQ_TX"))[2] )
            EndIf
         EndIf
      EndIf
   Else
      If !Empty(EEQ->EEQ_PGT) // Data de Liquidação
         nValorTx := EEQ->EEQ_TX
      EndIf
   EndIf
EndIf
RestOrd(aOrdSA6,.T.)
Return nValorTx

Static Function AF200VCom(nTipo)
Local lRet := .T.
Local bValRec, bComiss, bComPgt
Local nValRec, nValCom, nValPgt
Local cMsg

If M->EEQ_EVENT $ EV_PRINC2+"/"+EV_COM_AR+"/"+EV_COM_CG//(nTipo == LIQ_DET .AND. M->EEQ_EVENT $ EV_COM_AR+"/"+EV_COM_CG+"/"+EV_COM_DF) .OR. (nTipo <> LIQ_DET .AND. M->EEQ_EVENT == EV_PRINC2)
                                                                                 //MCF - 05/04/16 - Considerar o evento 603 - Adiant. Pós Embarque
   bValRec := {|| (TMP->EEQ_EVENT == EV_PRINC2 .AND. (!Empty(TMP->EEQ_DTCE) .Or. !Empty(TMP->EEQ_PGT))) .Or. (TMP->EEQ_EVENT == "603" .AND. (!Empty(TMP->EEQ_DTCE) .Or. !Empty(TMP->EEQ_PGT)))} //Valor Recebido
   nValRec := AF200GetVParc("EEQ_VL",bValRec)
                                                                               ///NCF - 21/11/13 - Fornecedor e loja da comissão pode ser diferente do principal
   bComiss := &("{|| TMP->EEQ_EVENT $ '"+EV_COM_AR+"/"+EV_COM_CG+"' .AND. (nTipo <> "+Alltrim(Str(LIQ_DET))+" .OR. TMP->(EEQ_FORN+EEQ_FOLOJA) == '"+M->EEQ_FORN+M->EEQ_FOLOJA+"') }") //Comissoes desse agente
   nValCom := AF200GetVParc("EEQ_VL",bComiss)

   bComPgt := &("{|| TMP->EEQ_EVENT $ '"+EV_COM_AR+"/"+EV_COM_CG+"' .AND. (nTipo <> "+Alltrim(Str(LIQ_DET))+" .OR. TMP->(EEQ_FORN+EEQ_FOLOJA) == '"+M->EEQ_FORN+M->EEQ_FOLOJA+"') .AND. (!Empty(TMP->EEQ_DTCE) .Or. !Empty(TMP->EEQ_PGT)) }") //Comissoes pagas desse agente
   nValPgt := AF200GetVParc("EEQ_VL",bComPgt)

   If M->EEQ_EVENT == EV_PRINC2

      If !Empty(TMP->EEQ_DTCE) .Or. !Empty(TMP->EEQ_PGT)
         nValRec -= M->EEQ_VL //AAF 14/02/2017 - Validação pelo memória pois o valor pode ser alterado para quebrar a parcela.
      EndIf

      If !Empty(M->EEQ_DTCE) .Or. !Empty(M->EEQ_PGT)
         nValRec += M->EEQ_VL
      EndIf

   ElseIf M->EEQ_EVENT $ EV_COM_AR+"/"+EV_COM_CG

      If !Empty(TMP->EEQ_DTCE) .Or. !Empty(TMP->EEQ_PGT)
         nValPgt -= TMP->EEQ_VL
      EndIf

      If !Empty(M->EEQ_DTCE) .Or. !Empty(M->EEQ_PGT)
         nValPgt += M->EEQ_VL
      EndIf

   EndIf

   If M->EEQ_EVENT == "120" .And. nTipo = ELQ_DET
        lRet := .T. //Nao valida de for estorno de comissao a
   Else
        lRet := nValPgt <= (nValCom * nValRec / EEC->EEC_TOTPED)
   EndIf

   If !lRet
      If nTipo == LIQ_DET
         cMsg := STR0325 + ENTER //"Não é possível efetuar pagamento de comissão para agente antes do crédito no exterior ou liquidação do pagamento do cliente."
      Else
         cMsg := STR0326 + ENTER //"Não é possível efetuar estorno do principal pois já foi realizado pagamento do agente comissionado."
      EndIf

      cMsg += ENTER
      cMsg += "Total a receber: "+Transform(EEC->EEC_TOTPED,AvSX3("EEC_TOTPED",AV_PICTURE))+ENTER
      cMsg += "Total recebido : "+Transform(nValRec,AvSX3("EEC_TOTPED",AV_PICTURE))+ENTER
      cMsg += "% recebido : "+Transform(100 * nValRec / EEC->EEC_TOTPED,AvSX3("EEC_TOTPED",AV_PICTURE))+ENTER
      cMsg += ENTER
      cMsg += "Agente: "+M->EEQ_FORN+" Loja: "+M->EEQ_FOLOJA+ENTER
      cMsg += "Total de Comissão ao Agente: "+Transform(nValCom,AvSX3("EEC_TOTPED",AV_PICTURE))+ENTER
      cMsg += "Limite de Comissão ao Agente: "+Transform((nValCom * nValRec / EEC->EEC_TOTPED),AvSX3("EEC_TOTPED",AV_PICTURE))+ENTER
      cMsg += "Total de Comissão ao Agente já paga: "+Transform(nValPgt - M->EEQ_VL,AvSX3("EEC_TOTPED",AV_PICTURE))+ENTER

	   if lExecAuto
         easyhelp(cMsg,"Atenção")   
      else
         EECVIEW(cMsg,"Atenção")
      endif
   EndIf
EndIf

Return lRet

//AAF - 21/10/2013 - Retorna o valor já recebido do cliente.
Static Function AF200GetVParc(cCampo,bCond)
Local nRec := TMP->(RecNo())
Local nValRet := 0

TMP->(dbGoTop())
Do While TMP->(!Eof())
   If ValType(bCond) <> "B" .OR. Eval(bCond)
      nValRet += TMP->(&(cCampo))
   EndIf

   TMP->(dbSkip())
EndDo

TMP->(dbGoTo(nRec))

Return nValRet


/*
Funcao     : AF200BkpInt()
Parametros : cAlias  - Alias da tabela a ser feito o backup
             cOperac - Tipo de operação sobre o registro
             aReg    - Array com dados iniciais dos campos do registro
             avinc   - Alias e Recno que definirá quando a reversão será executada
             lStatus - Define se houve retorno de erro na integração deste registro
             lAltOper- Define se altera a operação atual do registro
Retorno    : Nenhum
Objetivos  : Fazer o backup dos dados de Contrato para possível reversão
             em caso de falha na integração com o ERP Logix
Autor      : Nilson Cesar - NCF
Data/Hora  : 27/08/2014 - 19:00
*/
*----------------------------------------------------------------*
Function AF200BkpInt(cAlias,cOperac,aReg,aVinc,lStatus,lAltOper)
*----------------------------------------------------------------*
Local i
Default aReg     := {}
Default aVinc    := {}
Default lStatus  := .T.
Default lAltOper := .F.

If ValType(cAlias) == 'C'
   If (nPos := aScan( aDataContr,{|x|x[1] == cAlias .And. x[2] == &(cAlias)->(Recno())} )) == 0
      If Len(aReg) == 0
         For i:=1 To &(cAlias)->(Fcount())
            aAdd(aReg, &(cAlias+"->"+&(cAlias)->(FIELDNAME(i))) )
         Next i
      EndIf

      If Len(aVinc) == 2 .And. Left(aVinc[1],4) == 'WORK'
         If (nPosRfWork := aScan( aDataContr,{|x|x[1] == 'WORK'+cAlias .And. x[2] == aVinc[2] } )) <> 0
            cOperac := aDataContr[nPosRfWork][3]
            aDel(aDataContr,nPosRfWork)
            aSize(aDatacontr, Len(aDataContr)-1)
         EndIf
         If Left(cOperac,3)=='EFF' .And. cAlias == 'EF3'
            aVinc := {'EF1',EF1->(Recno())}
         EndIf
      EndIf

      aAdd( aDataContr, { cAlias, &(cAlias)->(Recno()) , cOperac , aReg, aVinc, lStatus } )
   Else
      If Len(aDataContr[nPos][5]) == 0
         aDataContr[nPos][5] := aclone(aVinc)
      EndIf
      aDataContr[nPos][6] := lStatus
      If lAltOper
         aDataContr[nPos][3] := cOperac
      EndIf
   EndIf
EndIf

Return

/*
Funcao     : AF200RevFIN()
Parametros : lAll - Invalidar todas as ações realizadas
Retorno    : Nenhum
Objetivos  : Fazer a reversão das atualizações no contrato de
             financiamento quando ocorrer reversão de dados da
             parcela cambial vinculada ao contrato na integra-
             ção EEC/EFF x LOGIX
Autor      : Nilson Cesar - NCF
Data/Hora  : 28/08/2014 - 19:00
*/
*----------------------------*
FUNCTION AF200RevFIN(lAll)
*----------------------------*
Local aOrdEF := SaveOrd({"EEQ","EFA","EF1","EF2","EF3","EF4","EF8","EF9"})
Local i,j,lEstTtCAP,lEstBxCAP,lEstTtCRE,lEstBxCRE
Local cInCPEF3   := '055'//-Evento de Inclusão de Título no Contas a Pagar referente a Evento de contrato de Financiamento
Local cEsCPEF3   := '067'//-Evento de Estorno de Títulos no Contas a Pagar referente a Evento de contrato de Financiamento
Local cBxCPEF3   := '069'//-Evento de Baixa em Título do Contas a Pagar referente a Evento de contrato de Financiamento
Local cEsBxCPEF3 := '071'//-Evento de Estorno de Baixa em Título Contas a Pagar referente a Evento de contrato de Financiamento
Local cBxCPEEQ   := '013'//-Evento de Baixa em Título do Contas a Pagar referente a Evento de Câmbio
Local cEsBxCPEEQ := '014'//-Evento de Estorno de Baixa em Título Contas a Pagar referente a Evento de Câmbio
Local cBxCREEQ   := '004'//-Evento de Baixa em Título do Contas a Receber referente a Evento de Câmbio
Local cEsBxCREEQ := '009'//-Evento de Estorno de Baixa em Título Contas a Receber referente a Evento de Câmbio
Local aRevEEQs   := {}
Local aRevEF1    := {}
Local nVlAdt     := 0 //THTS - 29/03/2017	

//Local aOldOrdEF3
Default lAll := .F.

If !lAll
   For i:=1 To Len(aDataContr)
      If aDataContr[i][1] == 'EEQ'
         If !aDataContr[i][6]
            For j:=1 To Len(aDataContr)                                                             //Loop para buscar possiveis eventos vinculados
               If aDataContr[j][1] $ 'EF1\EF2\EF3\EF4\EF8\EF9\ECF'
                  If Len(aDataContr[j][5]) > 0                                                      //Verifica se existe vinculo com algum EEQ
                     If aDataContr[j][5][1] == 'EEQ' .And. aDataContr[j][5][2] == aDataContr[i][2]  //Verifica se há o vinculo com o registro EEQ atual
                        aDataContr[j][6] := .F.                                                     //Invalida o evento para reversão
                     EndIf
                  EndIf
               EndIf
            Next j
         EndIf
      ElseIf aDataContr[i][1] == 'EF1'
         If !aDataContr[i][6]
            For j:=1 To Len(aDataContr)                                                             //Loop para buscar possiveis eventos vinculados
               If aDataContr[j][1] $ 'EEQ\EF2\EF3\EF4\EF8\EF9'
                  If Len(aDataContr[j][5]) > 0                                                      //Verifica se existe vinculo com algum EEQ
                     If aDataContr[j][5][1] == 'EF1' .And. aDataContr[j][5][2] == aDataContr[i][2]  //Verifica se há o vinculo com o registro EEQ atual
                        aDataContr[j][6] := .F.                                                     //Invalida o evento para reversão
                     EndIf
                  EndIf
               EndIf
            Next j
         EndIf
      ElseIf aDataContr[i][1] == 'EF3'
         If !aDataContr[i][6]
            If Len(aDataContr[i][5]) > 0                                                            //Verifica se existe vinculo com algum EEQ
               For j:=1 To Len(aDataContr)                                                          //Loop para buscar possível EEQ ao qual está vinculado
                  If aDataContr[j][1] == 'EEQ' .And. aDataContr[j][6]                               //Verifica se Integração da EEQ está válida
                     If aDataContr[i][5][1] == 'EEQ' .And. aDataContr[i][5][2] == aDataContr[j][2]  //Verifica se há o vinculo com o registro EEQ atual
                        aDataContr[j][6] := .F.                                                     //Invalida o EEQ para reversão
                     EndIf
                  ElseIf aDataContr[j][1] $ 'EF1\EF2\EF3\EF4'                                           //Invalida demais lançamentos no Contrato
                     If aDataContr[i][4][ &(aDataContr[i][1])->(FieldPos( aDataContr[i][1]+"_CONTRA" )) ]  == ;
                     AvKey( aDataContr[j][4][ &(aDataContr[j][1])->(FieldPos( aDataContr[j][1]+"_CONTRA" )) ]  ,  aDataContr[i][1]+"_CONTRA"  )
                        aDataContr[j][6] := .F.
                     EndIf
                  EndIf
               Next j
            EndIf
         EndIf
      ElseIf aDataContr[i][1] == 'ECF'
         If !aDataContr[i][6]
            For j:=1 To Len(aDataContr)                                                             //Loop para buscar possiveis eventos vinculados
               If aDataContr[j][1] $ 'EEQ'
                  If Len(aDataContr[j][5]) > 0                                                      //Verifica se existe vinculo com algum EEQ
                     If aDataContr[j][5][1] == 'ECF' .And. aDataContr[j][5][2] == aDataContr[i][2]  //Verifica se há o vinculo com o registro EEQ atual
                        aDataContr[j][6] := .F.                                                     //Invalida o evento para reversão
                     EndIf
                  EndIf
               EndIf
            Next j
         EndIf
      EndIf

   Next i
Else
   aEval(aDataContr,{|x| x[6] := .F. })
EndIf

i := Len(aDataContr)

	Do While i > 0

	   DO CASE

	      CASE aDataContr[i][1] == "EEQ" .And. !aDataContr[i][6]

	         If aDataContr[i][3] $ "EEQ_MOV_EXT_EST|EEQ_MOV_EXT_BXA"
               // rollback para os títulos com movimento no exterior e luquidação ou estorno para a movimentação bancária - MPG - OSSME-3496
	            EEQ->(DbGoto(aDataContr[i][2]))
	            If EEQ->(!Eof()) .and. EEQ->(!Bof())
	               EEQ->(RecLock("EEQ",.F.))
	               j := 1
	               aEval( aDataContr[i][4],{|x| EEQ->&(EEQ->(FIELDNAME(j))) := x , j++ })
	               EEQ->(MsUnlock())
	            EndIf
	         elseIf aDataContr[i][3] $ "EEC_MNCT_ALT|EFF_MNCT_ALT"
	            EEQ->(DbGoto(aDataContr[i][2]))
	            If EEQ->(!Eof()) .and. EEQ->(!Bof())
	               EEQ->(RecLock("EEQ",.F.))
	               j := 1
	               aEval( aDataContr[i][4],{|x| EEQ->&(EEQ->(FIELDNAME(j))) := x , j++ })
	               EEQ->(MsUnlock())
	            EndIf
	         ElseIf aDataContr[i][3] == "EEC_INBX_ALT"
	            EEQ->(DbGoto(aDataContr[i][2]))
	            If EEQ->(!Eof()) .and. EEQ->(!Bof())
	               If !Empty(EEQ->EEQ_FINNUM)
	                  If !Empty(EEQ->EEQ_SEQBX)              //NCF - 10/09/2014 - Integração foi invalidada em evento vinculado
	                     If EEQ->EEQ_TIPO == 'R'
	                        AvStAction(cEsBxCREEQ)
	                     Else
	                        AvStAction(cEsBxCPEEQ)
	                     EndIf
	                  EndIf
                     If !Empty(EEQ->EEQ_PGT)
                  
                        //THTS - 29/03/2017 - Restaura o saldo do adiantamento de fornecedores
                        If AvFlags("ADTFOREAI") .And. lAdtForBkp .And. !Empty(EEQ->EEQ_PROR) .And. !Empty(EEQ->EEQ_FAOR) .And. !Empty(EEQ->EEQ_PAOR) //Esta vinculando o adiantamento 

                           nVlAdt	:= EEQ->EEQ_VL
                                 If EEQ->EEQ_TIPO == "L"
                                       EEQ->(dbSetOrder(16))//EEQ_FILIAL, EEQ_PREEMB, EEQ_EVENT, EEQ_FASE, EEQ_FORN, EEQ_FOLOJA, EEQ_PARC
                                       EEQ->(dbSeek(xFilial("EEQ") + EEQ->EEQ_PROR + "609" + "F" + EEQ->EEQ_FORN + EEQ->EEQ_FOLOJA + EEQ->EEQ_PAOR))
                                 ElseIf EEQ->EEQ_TIPO == "A"
                                       EEQ->( dbsetorder(6),dbSeek(EEQ->(EEQ_FILIAL+EEQ_FAOR+EEQ_PROR+EEQ_PAOR)) )
                                 EndIf
                           EEQ->(RecLock("EEQ",.F.))
                           EEQ->EEQ_SALDO := EEQ->EEQ_SALDO + nVlAdt
                           EEQ->(MsUnlock())
      
                           lAdtForBkp := .F.
                           EEQ->(DbGoto(aDataContr[i][2]))
                           
                        EndIf

                        If EEQ->(RecLock('EEQ',.F.))
                           EEQ->EEQ_PGT  := cToD("")
                           EEQ->EEQ_SOL  := cToD("")
                           EEQ->EEQ_DTCE := cToD("")
                           EEQ->EEQ_TX   := 0
                           EEQ->EEQ_EQVL := 0
                           
                           If AvFlags("ADTFOREAI") .and. EEQ->EEQ_FAOR $ "F|P|C"

                              EEQ->EEQ_PROR := " "
                              EEQ->EEQ_FAOR := " "
                              EEQ->EEQ_PAOR := " "

                              If EEQ->EEQ_TIPO == "L"//THTS - 29/03/2017 - volta os valores da EEQ caso falhe o adt de fornecedor
                                    EEQ->EEQ_TIPO := "P"
                              ElseIf EEQ->EEQ_TIPO == "A" // MPG - 26/06/2018 - associação de adiantamento a receber
                                    EEQ->EEQ_TIPO := "R"
                                    EEQ->EEQ_EVENT := "101"
                              EndIf
                           
                           EndIf
                           
                           EEQ->(MsUnlock())
                        EndIf
                     elseif !empty(EEQ->EEQ_DTCE)
                        // rollback para os títulos com movimento no exterior e baixa pela data de crédito no exterior - MPG - OSSME-3496
                        EEQ->(DbGoto(aDataContr[i][2]))
                        If EEQ->(!Eof()) .and. EEQ->(!Bof())
                           EEQ->(RecLock("EEQ",.F.))
                           j := 1
                           aEval( aDataContr[i][4],{|x| EEQ->&(EEQ->(FIELDNAME(j))) := x , j++ })
                           EEQ->(MsUnlock())
                        EndIf
                     EndIf
	               EndIf
	            EndIf
	         ElseIf aDataContr[i][3] == "EEC_ESBX_ALT"
	            EEQ->(DbGoto(aDataContr[i][2]))
	            If EEQ->(!Eof()) .and. EEQ->(!Bof())
	               If Empty(EEQ->EEQ_SEQBX) .And. !Empty( aDataContr[i][4][ EEQ->(FieldPos("EEQ_SEQBX")) ] )
	                  lEstBxCRE := .T.
	               EndIf

	               EEQ->(RecLock("EEQ",.F.))
	               j := 1
	               aEval( aDataContr[i][4],{|x| EEQ->&(EEQ->(FIELDNAME(j))) := x , j++ })
	               If lEstBxCRE
                     EEQ->EEQ_SEQBX := ""
                  EndIf
	               EEQ->(MsUnlock())

                  //THTS - 29/03/2017 - Restaura o saldo do adiantamento de fornecedores
                  If AvFlags("ADTFOREAI") .And. lAdtForBkp .And. !Empty(EEQ->EEQ_PROR) .And. !Empty(EEQ->EEQ_FAOR) .And. !Empty(EEQ->EEQ_PAOR) //Esta vinculando o adiantamento 
                     nVlAdt	:= EEQ->EEQ_VL
                     If EEQ->EEQ_TIPO == "P"
                           EEQ->(dbSetOrder(16))//EEQ_FILIAL, EEQ_PREEMB, EEQ_EVENT, EEQ_FASE, EEQ_FORN, EEQ_FOLOJA, EEQ_PARC
                           EEQ->(dbSeek(xFilial("EEQ") + EEQ->EEQ_PROR + "609" + "F" + EEQ->EEQ_FORN + EEQ->EEQ_FOLOJA + EEQ->EEQ_PAOR))
                     ElseIf EEQ->EEQ_TIPO $ "R|A"
                           EEQ->( dbsetorder(6),dbSeek(EEQ->(EEQ_FILIAL+EEQ_FAOR+EEQ_PROR+EEQ_PAOR)) )
                     EndIf

                     EEQ->(RecLock("EEQ",.F.))
                     EEQ->EEQ_SALDO := EEQ->EEQ_SALDO - nVlAdt
                     EEQ->(MsUnlock())

                     lAdtForBkp := .F.
                     EEQ->(DbGoto(aDataContr[i][2]))
                  EndIf

                  If Empty(EEQ->EEQ_SEQBX)
                     If EEQ->EEQ_TIPO == 'R'
                        AvStAction(cBxCREEQ)
                     Elseif EEQ->EEQ_TIPO == 'P'
                        AvStAction(cBxCPEEQ)
                     EndIf
                  EndIf
                  lEstBxCRE := .F.

               EndIf
   	      EndIf

	      CASE aDataContr[i][1] == "EFA" //.And. !aDataContr[i][6]

	         If aDataContr[i][3] == "EFF_MNCT_ALT"
	            EFA->(DbGoto(aDataContr[i][2]))
	            If EFA->(!Eof()) .and. EFA->(!Bof())
	               EFA->(RecLock("EFA",.F.))
	               j := 1
	               aEval( aDataContr[i][4],{|x| EFA->&(EFA->(FIELDNAME(j))) := x , j++ })
	               EFA->(MsUnLock())
	            EndIf
	         EndIf

	      CASE aDataContr[i][1] == "EF1" .And. !aDataContr[i][6]

	         If Left( aDataContr[i][3], 8) $ 'EEC_INBX|EFF_INBX|EEC_ESBX|EFF_ESBX|EFF_MNCT'
	            EF1->(DbGoto(aDataContr[i][2]))
	            If EF1->(!Eof()) .and. EF1->(!Bof())
	               EF1->(RecLock("EF1",.F.))
	               j := 1
	               aEval( aDataContr[i][4],{|x| EF1->&(EF1->(FIELDNAME(j))) := x , j++ })
	               EF1->(MsUnLock())
	               If aScan( aRevEF1,{|x|x[1] == aDataContr[i][1] .And. x[2] == aDataContr[i][2]} ) == 0
	                  aAdd(aRevEF1, {aDataContr[i][1],aDataContr[i][2]} )
	               EndIf
	            EndIf
	         EndIf

	      CASE aDataContr[i][1] == "EF2" .And. !aDataContr[i][6]

	         If Right(aDataContr[i][3],3) == "INC"
	            EF2->(DbGoto(aDataContr[i][2]))
	            If EF2->(!Eof()) .and. EF2->(!Bof())
	               EF2->(RecLock("EF2",.F.))
	               EF2->(dbDelete())
	               EF2->(MsUnLock())
	            EndIf
	         ElseIf Right(aDataContr[i][3],3) == "ALT"
	            EF2->(DbGoto(aDataContr[i][2]))
	            If EF2->(!Eof()) .and. EF2->(!Bof())
	               EF2->(RecLock("EF2",.F.))
	               j := 1
	               aEval( aDataContr[i][4],{|x| EF2->&(EF2->(FIELDNAME(j))) := x , j++ })
	               EF2->(MsUnLock())
	            EndIf
	         Else
	            EF2->(DbGoto(aDataContr[i][2]))
	            If EF2->(!Eof()) .and. EF2->(!Bof()) .And. EF2->(Deleted())
	               EF2->(RecLock("EF2",.F.))
	               EF2->(dbRecall())
	               EF2->(MsUnLock())
	            EndIf
	         EndIf
	      CASE aDataContr[i][1] == "EF3" .And. !aDataContr[i][6]

	         If Left( aDataContr[i][3], 8) $ 'EEC_INBX|EFF_INBX|ENC_INBX|EFF_ITIB' .Or. aDataContr[i][3] $ 'EFF_MNCT_INC|ENC_MNCT_INC' //.Or.  Left( aDataContr[i][3], 8) $ 'MAN_INBX'               //$ "LIQ_CAMB_INC|LIQ_CAMB_ALT|LIQ_EVE_INC|LIQ_EVE_ALT"
	            EF3->(DbGoto(aDataContr[i][2]))
	            If EF3->(!Eof()) .and. EF3->(!Bof())
	               If !Empty(EF3->EF3_TITFIN)
	                  If !Empty(EF3->EF3_SEQBX)
                         If EF3->EF3_CODEVE              $ "700/660"      //PRINCIPAL
                            cEsBxCPEF3 := '070'
                         ElseIf Left(EF3->EF3_CODEVE,2)  $ "62/64/67/71/18/19"     //JUROS       //NCF - 04/12/2014 - Adicionado os eventos de encerramento de contrato (180 e 190)
                            //If Left(EF3->EF3_CODEVE,2)  <> "71"                                //NCF - 23/06/2015 - Permitir reversão de baixa seguida de exclusão dos ev. 640/710
                               cEsBxCPEF3 := '071'
                            //EndIf
                         ElseIf Left(EF3->EF3_CODEVE,1)  $ "3/4" .Or.  Left(EF3->EF3_CODEVE,2) $ '18/19'         //ENCARGOS\ENCERRAMENTO
                            cEsBxCPEF3 := '077'
                         EndIf
                         If !Empty(cEsBxCPEF3)
	                        AvStAction(cEsBxCPEF3) // NCF - 29/08/2014 - Estorno de Baixa em Título Contas a Pagar referente a Evento de contrato de Financiamento
	                     EndIf
	                     cEsBxCPEF3 := ""
	                  EndIf
	                  If EF3->EF3_TX_MOE <> 0
	                     EF3->(RecLock('EF3',.F.))
	                     EF3->EF3_TX_MOE := 0
	                     EF3->EF3_VL_REA := 0
	                     If EF3->(FieldPos("EF3_DTOREV")) > 0
	                        EF3->EF3_DTOREV := cToD('  /  /  ')
	                     EndIf
	                     EF3->(MsUnlock())
	                  EndIf
	                  If Right(aDataContr[i][3],8) $ "INBX_INC|MNCT_INC|ITIB_ALT"
	                     If EF3->EF3_CODEVE              $ "700/660"      //PRINCIPAL
                            cEsCPEF3 := '066'
                         ElseIf Left(EF3->EF3_CODEVE,2)  $ "62/64/67/71"     //JUROS
                            cEsCPEF3 := '067'
                         ElseIf Left(EF3->EF3_CODEVE,1)  $ "3/4" .Or.  Left(EF3->EF3_CODEVE,2) $ '18/19'   //ENCARGOS\ENCERRAMENTO
                            cEsCPEF3 := '063'
                         EndIf
                         If !Empty(cEsCPEF3)
	                        AvStAction(cEsCPEF3)      // NCF - 29/08/2014 - Estorno de Títulos no Contas a Pagar referente a Evento de contrato de Financiamento
	                     EndIf
	                     cEsCPEF3 := ""
	                  EndIf
	               EndIf
	               If Right(aDataContr[i][3],8) $ "INBX_INC|MNCT_INC" .Or. ( Right(aDataContr[i][3],8) $ "ITIB_ALT" .And. Left(EF3->EF3_CODEVE,2)  <> "71" )    //NCF - 23/06/2015 - Não deleta em reversão eventos 710
	                  EF3->(RecLock("EF3",.F.))
	                  EF3->(dbDelete())
	                  EF3->(MsUnLock())
	               EndIf
	            EndIf
	         ElseIf Left( aDataContr[i][3], 8) $ 'EEC_ESBX|EFF_ESBX|ENC_ESBX|EFF_EBET' .Or. aDataContr[i][3] $ 'ENC_MNCT_DEL|EFF_MNCT_DEL|EFF_MNCT_ALT'
	            EF3->(DbGoto(aDataContr[i][2]))
	            If EF3->(!Eof()) .and. EF3->(!Bof())
	               If Right(aDataContr[i][3],8) $ "ESBX_DEL|MNCT_DEL" .And. EF3->(Deleted())
	                  EF3->(RecLock("EF3",.F.))
	                  EF3->(DbRecall())
	                  EF3->(MsUnLock())
	               EndIf
	               //If Empty(EF3->EF3_TITFIN) .And. !Empty( aDataContr[i][4][ EF3->(FieldPos("EF3_TITFIN")) ] )
	                  If Empty(EF3->EF3_TITFIN) .And. !Empty( aDataContr[i][4][ EF3->(FieldPos("EF3_TITFIN")) ] )
	                     lEstTtCAP := .T.
	                  EndIf
	                  If Empty(EF3->EF3_SEQBX) .And. !Empty( aDataContr[i][4][ EF3->(FieldPos("EF3_SEQBX")) ] )
	                     lEstBxCAP := .T.
	                  EndIf

	                  EF3->(RecLock("EF3",.F.))
	                  j := 1
	                  aEval( aDataContr[i][4],{|x| EF3->&(EF3->(FIELDNAME(j))) := x , j++ })
	                  If lEstTtCAP
                         EF3->EF3_TITFIN := ""
                      EndIf
	                  If lEstBxCAP
                         EF3->EF3_SEQBX  := ""
                      EndIf
	                  EF3->(MsUnlock())

	                  If lEstTtCAP
	                     If EF3->EF3_CODEVE              $ "700/660"      //PRINCIPAL
                            cInCPEF3 := '054'
                         ElseIf Left(EF3->EF3_CODEVE,2)  $ "62/64/67/71/18/19"     //JUROS         //NCF - 04/12/2014 - Adicionado os eventos de encerramento de contrato (180 e 190)
                            cInCPEF3 := '055'
                         ElseIf Left(EF3->EF3_CODEVE,1)  $ "3/4" .Or.  Left(EF3->EF3_CODEVE,2) $ '18/19'         //ENCARGOS\ENCERRAMENTO
                            cInCPEF3 := '051'
                         EndIf
                         If !Empty(cInCPEF3)
	                        AvStAction(cInCPEF3)      //NCF - 05/09/2014 - Inclusão de Títulos no Contas a Pagar referente a Evento de contrato de Financiamento
	                     EndIf
	                     cInCPEF3 := ""
	                  EndIf

	                  If lEstBxCAP
	                     If EF3->EF3_CODEVE              $ "700/660"      //PRINCIPAL
                            cBxCPEF3 := '068'
                         ElseIf Left(EF3->EF3_CODEVE,2)  $ "62/64/67/71"     //JUROS
                            cBxCPEF3 := '069'
                         ElseIf Left(EF3->EF3_CODEVE,1)  $ "3/4"          //ENCARGOS
                            cBxCPEF3 := '076'
                         EndIf
                         If !Empty(cBxCPEF3)
	                        AvStAction(cBxCPEF3)   //NCF - 05/09/2014 - Baixa em Título Contas a Pagar referente a Evento de contrato de Financiamento
	                     EndIf
	                     cBxCPEF3 := ""
	                  EndIf
	                  lEstBxCAP := lEstTtCAP := .F.
	               //EndIf
	            EndIf
	         EndIf

	      CASE aDataContr[i][1] == "EF4" .And. !aDataContr[i][6]

	         If Left( aDataContr[i][3], 8) $ "EFF_MNCT"
	            EF4->(DbGoto(aDataContr[i][2]))
	            If EF4->(!Eof()) .and. EF4->(!Bof())
	               EF4->(RecLock("EF4",.F.))
	               EF4->(dbDelete())
	               EF4->(MsUnLock())
	            EndIf
	         EndIf

	      CASE aDataContr[i][1] == "EF8" //.And. !aDataContr[i][6]

	         If Right(aDataContr[i][3],3) == "INC"
	            EF8->(DbGoto(aDataContr[i][2]))
	            If EF8->(!Eof()) .and. EF8->(!Bof())
	               EF8->(RecLock("EF8",.F.))
	               EF8->(dbDelete())
	               EF8->(MsUnLock())
	            EndIf
	         ElseIf Right(aDataContr[i][3],3) == "ALT"
	            EF8->(DbGoto(aDataContr[i][2]))
	            If EF8->(!Eof()) .and. EF8->(!Bof())
	               EF8->(RecLock("EF8",.F.))
	               j := 1
	               aEval( aDataContr[i][4],{|x| EF8->&(EF8->(FIELDNAME(j))) := x , j++ })
	               EF8->(MsUnLock())
	            EndIf
	         Else
	            EF8->(DbGoto(aDataContr[i][2]))
	            If EF8->(!Eof()) .and. EF8->(!Bof()) .And. EF8->(Deleted())
	               EF8->(RecLock("EF8",.F.))
	               EF8->(dbRecall())
	               EF8->(MsUnLock())
	            EndIf
	         EndIf

	      CASE aDataContr[i][1] == "EF9" //.And. !aDataContr[i][6]

	         If aDataContr[i][3] == "ALTERACAO"
	            EF9->(DbGoto(aDataContr[i][2]))
	            If EF9->(!Eof()) .and. EF9->(!Bof())
	               EF9->(RecLock("EF9",.F.))
	               j := 1
	               aEval( aDataContr[i][4],{|x| EF9->&(EF9->(FIELDNAME(j))) := x , j++ })
	               EF9->(MsUnLock())
	            EndIf
	         EndIf

	       CASE aDataContr[i][1] == "ECF"

	         If Left( aDataContr[i][3], 8) $ 'EEC_INBX'
	            ECF->(DbGoto(aDataContr[i][2]))
	            If ECF->(!Eof()) .and. ECF->(!Bof())
	               If !Empty(ECF->ECF_LOTERP) .And. !Empty(ECF->ECF_RELACA)
	                  aRegECF := {ECF->(Recno())}
                     If FindFunction("EECLC510")                     
	                     EasyExRdm("EECLC510", aRegECF,5,ECF->ECF_NR_CON)                        
                     EndIf   
	                  If aRegECF[1] <> ECF->(Recno())      //NCF - Chamada da integração desposiciona
	                     ECF->(DbGoto(aRegECF[1]))
	                  EndIf
	               EndIf
	               If Empty(ECF->ECF_CONTAB) .Or. ECF->ECF_CONTAB == '2'
	                  If !ECF->(Deleted())
	                     ECF->(RecLock("ECF",.F.))
	                     ECF->(dbDelete())
	                     ECF->(MsUnlock())
	                  EndIf
	               EndIf
	            EndIf
	         ElseIf Left( aDataContr[i][3], 8) $ 'EEC_ESBX'
	            ECF->(DbGoto(aDataContr[i][2]))
	            If ECF->(!Eof()) .and. ECF->(!Bof())
	               If ECF->ECF_ID_CAM == '999'
	                  If ( If(ECF->ECF_CONTAB <> '2',!Empty(ECF->ECF_LOTERP) .And. !Empty(ECF->ECF_RELACA), Empty(ECF->ECF_LOTERP) .And. Empty(ECF->ECF_RELACA) ) )
	                     aRegECF := {ECF->(Recno())}
                        If FindFunction("EECLC510")
                           EasyExRdm("EECLC510", aRegECF,5,ECF->ECF_NR_CON)	                        
                        EndIf   
	                     If aRegECF[1] <> ECF->(Recno())      //NCF - Chamada da integração desposiciona
	                        ECF->(DbGoto(aRegECF[1]))
	                     EndIf
	                  EndIf
	                  If Empty(ECF->ECF_CONTAB) .Or. ECF->ECF_CONTAB == '2'
	                     If !ECF->(Deleted())
	                        ECF->(RecLock("ECF",.F.))
	                        ECF->(dbDelete())
	                        ECF->(MsUnlock())
	                     EndIf
	                  EndIf
	               Else
	                  If Empty(ECF->ECF_LOTERP) .And. Empty(ECF->ECF_RELACA)
	                     aRegECF := {ECF->(Recno())}
                        If FindFunction("EECLC510")
	                        EasyExRdm("EECLC510", aRegECF,3,ECF->ECF_NR_CON)                           
                        EndIf   
	                     If aRegECF[1] <> ECF->(Recno())      //NCF - Chamada da integração desposiciona
	                        ECF->(DbGoto(aRegECF[1]))
	                     EndIf
	                  EndIf
	                  If ECF->(DELETED())
	                     ECF->(RecLock("ECF",.F.))
	                     ECF->(dbRecall())
	                     ECF->(MsUnlock())
	                  EndIf
	               EndIf
	            EndIf
	         EndIf

	   ENDCASE
	   i--
	EndDo
	/* //NCF - 01/12/2014 - Desativada esta integração visto que a integração com o módulo contábil Externo para contabilizar a captaçõa de contrato deve ser única e não permite
	                        aleração, ou seja, cada envio é tratado como uma nova inclusão no ERP Destino e gerando como retorno um novo número de controle da contabilização.
	If Len(aRevEF1) > 0
	   For i:=1 To Len(aRevEF1)
	      &(aRevEF1[i][1])->(DbGoTo(aRevEF1[i][2]))
	      If &(aRevEF1[i][1])->(!Eof()) .And. &(aRevEF1[i][1])->(!Bof())
	         aOldOrdEF3 := SaveOrd('EF3')
	         EF3->(DbSetOrder(1))
             EF3->(DbSeek( xFilial('EF3') + EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)+'100'))   //NCF - 27/11/2014 - Posicionar o evento 100 para reversão dos dados do documento.
             If EF3->(!Eof()) .and. EF3->(!Bof()) .And. Empty(EF3->EF3_TITFIN)
	            AvStAction('050') //Inclusão/Alteração do contrato de Financiamento
	         EndIf
	         RestOrd(aOldOrdEF3,.T.)
	      EndIf
	   Next i
	EndIf
	*/
    aDataContr := {} //Limpa o buffer de reversão
    RestOrd(aOrdEF,.T.)

Return

/*
Funcao     : AF200TITFIN()
Parametros : Nro do titulo a ser pesquisado e opção
Retorno    : Nenhum ou (.T./.F.)
Objetivos  : Posicionar na tabela SE1 para consultar se o titulo esta baixado ou aberto
Autor      : Laercio G S Junior - LGS
Data/Hora  : 28/08/2014 17:01:00
Revisão    : 01/10/2015 [NCF] - Adiant. com Mov. Exterior
*/
*------------------------------------------------*
Function AF200TITFIN(cTitFin,nOp,cTitParc,cAliasWk)
*------------------------------------------------*
Local lRet  := lCpoModal := .F.
Default nOp := 0,cTitParc:= ""
Default cAliasWk := "TMP"
lCpoModal := If ((cAliasWk)->(FieldPos("EEQ_MODAL")) > 0,.T.,.F.)
cTitParc  := If ( Empty(cTitParc), "", EECGetFinParc(cTitParc) )
cAliasPesq := If(IsReceita((cAliasWk)->EEQ_EVENT),"SE1","SE2")
If lCpoModal

   If !Empty(cTitFin)
      If cAliasPesq == "SE1"
         SE1->(DbSetOrder(1))
         SE1->(DbSeek(xFilial("SE1")+"EEC"+cTitFin+cTitParc))
      Else
         SE2->(DbSetOrder(1))
         SE2->(DbSeek(xFilial("SE2")+"EEC"+cTitFin+cTitParc+AvKey("NF","E2_TIPO")+AvKey((cAliasWk)->EEQ_FORN,"E2_FORNECE")+ AvKey((cAliasWk)->EEQ_FOLOJA,"E2_LOJA") ))
      EndIf
   EndIf

   If EasyGParam("MV_AVG0131",,.F.)
      //Considerar baixa parcial do título para permitir a liquidação da parcela de câmbio (nop == 3)
      If (nOp == 1 .Or. nOp == 3) .And.;
         (&(cAliasPesq+'->'+Right(cAliasPesq, 2)+'_STATUS') == "B" .Or. (nOp == 3 .And. &(cAliasPesq+'->'+Right(cAliasPesq, 2)+ '_VALLIQ') <> 0));
          .And. nTipoOPC <> 5
         nOp:= 1
         lRet := .T.
      EndIf
   ElseIf !EasyGParam("MV_AVG0131",,.F.) .And. nOp == 1 .And. nTipoOPC == LIQ_DET
      lRet := .T.
   EndIf

   If nOp == 2
      (cAliasWk)->EEQ_TX     := 0
      (cAliasWk)->EEQ_EQVL   := 0
      (cAliasWk)->EEQ_MODAL  := "1"
      (cAliasWk)->EEQ_MOTIVO := AvKey("","EEQ_MOTIVO")
      (cAliasWk)->EEQ_BCOEXT := AvKey("","EEQ_BCOEXT")
      (cAliasWk)->EEQ_AGCEXT := AvKey("","EEQ_AGCEXT")
      (cAliasWk)->EEQ_CNTEXT := AvKey("","EEQ_CNTEXT")
      (cAliasWk)->EEQ_NBCEXT := AvKey("","EEQ_NBCEXT")
   EndIf

EndIf

Return If (nOp == 1, lRet, Nil)


/*
Funcao     : TransfBanco()
Parametros : lEstorno
Retorno    :
Objetivos  :
Autor      :
Data/Hora  :
Revisão    : Set/2016 - wfs
             - Correção na data da movimentação
             - Tratadas parcelas vinculadas aos contratos de financiamento, para que não haja internação na liquidação
             - Alterada a ação na chamada da rotina automática de integração com o financeiro, para uso das regras de negócio
               do financeiro nas tratativas de movimento e estorno/ cancelamento
*/
Static Function TransfBanco(lEstorno)
Local aSE5 := {}
Local cAlias := "TMP"
Local cError := ""
Local lRet := .T.
Local nRecTMP := TMP->(Recno())
Local nIndexTMP := TMP->(IndexOrd())
Local lIsBxMovEx := AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal(cAlias) .And. IsReceita( (cAlias)->EEQ_EVENT ).And. !Empty((cAlias)->EEQ_DTCE) .And. !Empty((CAlias)->EEQ_BCOEXT)
Local dOldDataBase:= dDataBase
Local lEmptyNroMovimento

Begin Sequence

	//RMD - 23/01/15 - Se não for estorno considera os dados da work (ainda não foram gravados). Se for estorno considera do EEQ (ainda não foi sobrescrito).
   If !lEstorno
      cAlias := "TMP"
      /* WFS
         Posicionar SE1/ SE2 */
      AF200TITFIN((cAlias)->EEQ_FINNUM, 1,, cAlias)
   Else
      cAlias := "EEQ"
   EndIf

   /* Data do movimento não pode ser menor que a data base. */
   dDataBase:= (cAlias)->EEQ_PGT

   //Remove valor da conta no exterior
   aAdd(aSE5,{"E5_FILIAL" , xFilial("SE5")                                                                     , NIL})
   aAdd(aSE5,{"E5_BANCO"  , (cAlias)->EEQ_BCOEXT                                                               , NIL})
   aAdd(aSE5,{"E5_AGENCIA", (cAlias)->EEQ_AGCEXT                                                               , NIL})
   aAdd(aSE5,{"E5_CONTA"  , (cAlias)->EEQ_CNTEXT                                                               , NIL})
   aAdd(aSE5,{"E5_DATA"   , (cAlias)->EEQ_PGT                                                                  , NIL})
   aAdd(aSE5,{"E5_VALOR"  , AF200VLFCam(cAlias)                                                                , NIL})
   aAdd(aSE5,{"E5_MOEDA"  , "M" + AllTrim(AF200BCO((cAlias)->EEQ_BCOEXT, (cAlias)->EEQ_AGCEXT, (cAlias)->EEQ_CNTEXT)) , NIL})   
   AAdd(aSE5,{"E5_TXMOEDA", (cAlias)->EEQ_TX                                                                   , NIL})
   
   If lEstorno .And. Empty((cAlias)->EEQ_NROPAG)
      aAdd(aSE5,{"E5_RECPAG" , "R"                                                                             , NIL})
   Else
      aAdd(aSE5,{"E5_RECPAG" , "P"                                                                             , NIL})
   EndIf

   aAdd(aSE5,{"E5_TIPODOC", "  "																						   , NIL})

   If IsReceita((cAlias)->EEQ_EVENT)
      AAdd(aSE5, {"E5_NATUREZ", If(!Empty(SE1->E1_NATUREZ), SE1->E1_NATUREZ, EasyGParam("MV_AVG0178",, "EASY"))      , NIL})
   Else
      AAdd(aSE5, {"E5_NATUREZ", If(!Empty(SE2->E2_NATUREZ), SE2->E2_NATUREZ, EasyGParam("MV_AVG0178",, "EASY"))      , NIL})
   EndIf

   aAdd(aSE5,{"E5_HISTOR" , "EMB.: " + AllTrim((cAlias)->EEQ_PREEMB) + " Parc.: " + AllTrim((cAlias)->EEQ_PARC) , NIL})
   aAdd(aSE5,{"E5_DTDIGIT", dDataBase                                                                           , NIL})
   aAdd(aSE5,{"E5_DTDISPO", (cAlias)->EEQ_PGT                                                                   , NIL})

   If !lEstorno .Or. Empty((cAlias)->EEQ_NROPAG)
      aAdd(aSE5,{"E5_PROCTRA", EasyGetMVSeq("E5_PROCTRA")                                                       , NIL})
   Else
      aAdd(aSE5,{"E5_PROCTRA", (cAlias)->EEQ_NROPAG                                                             , NIL})
   EndIf

   If SE5->(FieldPos("E5_ORIGEM")) > 0
      aAdd(aSE5,{"E5_ORIGEM", "SIGAEEC"                                                                         , NIL})
   EndIf
   aAdd(aSE5,{"INDEX"     ,15            																			       , NIL})

   lEmptyNroMovimento:= Empty((cAlias)->EEQ_NROPAG)

    //Necessario posicionar na SE5 antes de chamar estorno - RNLP - OSSME-4066
   If lEstorno .And. !lEmptyNroMovimento
      SE5->(DbSetOrder(15)) //E5_FILIAL+E5_PROCTRA 
      SE5->(DbSeek(xFilial("SE5")+(cAlias)->EEQ_NROPAG))  
   EndIf

   TMP->(DbCloseArea())

   /* WFS - revisão dos conceitos de movimentação */
   If lEstorno .And. lEmptyNroMovimento
      Processa({|| cError := EECInFin(aSE5, "SE5", "RECEBER")}, STR0284)//"Estorno da movimentação da conta no exterior"
   Else
      Processa({|| cError := EECInFin(aSE5, "SE5", If(lEstorno, "EXCLUIR", "PAGAR"))}, If(lEstorno, STR0284, STR0285)) //"Estorno da movimentação da conta no exterior", "Movimentação da conta no exterior"
   EndIf
   If !Empty(cError)
      if lExecAuto
         easyhelp(STR0286 + ENTER + cError, STR0016) //"Movimento bancário com a conta no exterior não concluído.", "Aviso"
      else
         EECView(STR0286 + ENTER + cError, STR0016,,,, .T.) //"Movimento bancário com a conta no exterior não concluído.", "Aviso"
      endif
      lRet := .F.
      Break
   EndIf

   aSE5 := {}
   cAlias := "TMP"
   If Select("TMP") > 0
      TMP->(DbCloseArea())
   EndIf
   Af200AbTmp()
   TMP->(dbSetOrder(nIndexTMP))
   TMP->(DBGoTo(nRecTmp))

   (cAlias)->(RecLock(cAlias, .F.))
   If lEstorno
      (cAlias)->EEQ_NROPAG:= ""
   Else
      (cAlias)->EEQ_NROPAG:= SE5->E5_PROCTRA
   EndIf
   (cAlias)->(MsUnlock())

   /* Quando for financiamento com câmbio liquidado no exterior, não haverá transferência para a conta Brasil.
      A quantia é transferida para o banco da contratação do financiamento; desta forma, não registra movimento
      de entrada no SIGAFIN */
   EF3->(DBSetOrder(3))//EF3_FILIAL+EF3_TPMODU+EF3_INVOIC+EF3_PARC+EF3_CODEVE
   If !lFinanciamento .Or. !EF3->(DBSeek(xFilial("EF3") + "E" + (cAlias)->EEQ_NRINVO +;
      If(!lParFin .Or. Empty((cAlias)->EEQ_PARFIN), (cAlias)->EEQ_PARC, (cAlias)->EEQ_PARFIN) +;
      EV_EMBARQUE))

      //Soma o valor na conta do Brasil
      aAdd(aSE5,{"E5_FILIAL" , xFilial("SE5")                                                                     ,NIL})
      aAdd(aSE5,{"E5_BANCO"  , (cAlias)->EEQ_BANC                                                                 ,NIL})
      aAdd(aSE5,{"E5_AGENCIA", (cAlias)->EEQ_AGEN                                                                 ,NIL})
      aAdd(aSE5,{"E5_CONTA"  , (cAlias)->EEQ_NCON                                                                 ,NIL})
      aAdd(aSE5,{"E5_DATA"   , (cAlias)->EEQ_PGT                                                                  ,NIL})
      aAdd(aSE5,{"E5_VALOR"  , (cAlias)->EEQ_EQVL                                                                 ,NIL})      
      aAdd(aSE5,{"E5_MOEDA"  , "M" + AllTrim(AF200BCO((cAlias)->EEQ_BANC, (cAlias)->EEQ_AGEN, (cAlias)->EEQ_NCON)) ,NIL})
      aAdd(aSE5,{"E5_VLMOED2", AF200VLFCam(cAlias)                                                                ,NIL})
      AAdd(aSE5,{"E5_TXMOEDA", (cAlias)->EEQ_TX                                                                   ,NIL})

      If lEstorno .And. Empty((cAlias)->EEQ_INTERN)
         aAdd(aSE5,{"E5_RECPAG" , "P"                                                                             ,NIL})
      Else
         aAdd(aSE5,{"E5_RECPAG" , "R"                                                                             ,NIL})
      EndIf

      aAdd(aSE5,{"E5_TIPODOC", "  "                                                                               ,NIL})

      If IsReceita((cAlias)->EEQ_EVENT)
         AAdd(aSE5, {"E5_NATUREZ", If(!Empty(SE1->E1_NATUREZ), SE1->E1_NATUREZ, EasyGParam("MV_AVG0178",, "EASY"))     ,NIL})
      Else
         AAdd(aSE5, {"E5_NATUREZ", If(!Empty(SE2->E2_NATUREZ), SE2->E2_NATUREZ, EasyGParam("MV_AVG0178",, "EASY"))     ,NIL})
      EndIf

      aAdd(aSE5,{"E5_HISTOR" , "EMB.: " + AllTrim((cAlias)->EEQ_PREEMB) + " Parc.: " + AllTrim((cAlias)->EEQ_PARC),NIL})
      aAdd(aSE5,{"E5_DTDIGIT", dDataBase                                                                          ,NIL})
      aAdd(aSE5,{"E5_DTDISPO", (cAlias)->EEQ_PGT                                                                  ,NIL})

      If !lEstorno .Or. Empty((cAlias)->EEQ_INTERN)
         aAdd(aSE5,{"E5_PROCTRA", EasyGetMVSeq("E5_PROCTRA")                                                      ,NIL})
      Else
         aAdd(aSE5,{"E5_PROCTRA", (cAlias)->EEQ_INTERN                                                            ,NIL})
      EndIf

      If SE5->(FieldPos("E5_ORIGEM"))>0
         aAdd(aSE5,{"E5_ORIGEM","SIGAEEC"                                                                        ,NIL})
      EndIf

      aAdd(aSE5,{"INDEX"     ,15                                                                                  ,NIL})


      lEmptyNroMovimento:= Empty((cAlias)->EEQ_INTERN)

      //Necessario posicionar na SE5 antes de chamar estorno - RNLP - OSSME-4066
      If lEstorno .And. !lEmptyNroMovimento
         SE5->(DbSetOrder(15)) //E5_FILIAL+E5_PROCTRA 
         SE5->(DbSeek(xFilial("SE5")+(cAlias)->EEQ_INTERN)) //E5_FILIAL+E5_PROCTRA  
      EndIf

      TMP->(DbCloseArea())   

      /* WFS - revisão dos conceitos de movimentação */
      If lEstorno .And. lEmptyNroMovimento
         Processa({|| cError:= EECInFin(aSE5, "SE5", "PAGAR")}, STR0284)//"Estorno da movimentação da conta no exterior")
      Else
         Processa({|| cError:= EECInFin(aSE5, "SE5", If(lEstorno, "EXCLUIR", "RECEBER"))}, If(lEstorno, STR0284, STR0285)) //"Estorno da movimentação da conta no exterior", "Movimentação da conta no exterior"
      EndIf

      If !Empty(cError)
         if lExecAuto
            easyhelp(STR0287 + ENTER + cError, STR0016) //"Movimento bancário na conta de liquidação da parcela de cambio não concluído.", "Aviso"
         else
            EECView(STR0287 + ENTER + cError, STR0016,,,, .T.) //"Movimento bancário na conta de liquidação da parcela de cambio não concluído.", "Aviso"
         endif
         lRet := .F.
         Break
      EndIf

      If Select("TMP") > 0
         TMP->(DbCloseArea())
      EndIf
      Af200AbTmp()
      TMP->(dbSetOrder(nIndexTMP))
      TMP->(DBGoTo(nRecTmp))

      (cAlias)->(RecLock(cAlias, .F.))
      If lEstorno
         (cAlias)->EEQ_INTERN:= ""
      Else
         (cAlias)->EEQ_INTERN:= SE5->E5_PROCTRA
      EndIf
	  (cAlias)->(MsUnlock())

   EndIf

End Sequence

dDataBase:= dOldDataBase
Return lRet

/*
Funcao     : AF200BCO()
Parametros : Codigo Banco
Retorno    : Codigo da moeda cadastrado para o banco
Autor      : Laercio G S Junior - LGS
Data/Hora  : 12/11/2014
*/
Static Function AF200BCO(cBanco, cAgencia, cConta)
Local cMoeda := '1'

default cBanco   := ""
default cAgencia := ""
default cConta   := ""

cBanco := AVKEY( cBanco, "A6_COD" ) 
cAgencia := AVKEY(cAgencia, "A6_AGENCIA" )
cConta := AVKEY(cConta, "A6_NUMCON" )
SA6->(DbSetOrder(1)) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
If SA6->(DbSeek( xFilial("SA6") + cBanco + cAgencia + cConta ))
   cMoeda := If (!Empty(SA6->A6_MOEDA), cValToChar(SA6->A6_MOEDA), cMoeda)
Endif

Return cMoeda

/*
Funcao     : AF200COMPCR()
Parametros : Array aCompTit com o Recno da EEQ e SE1 - Baixa por Compensação
Retorno    : .T. ou .F.
Autor      : Laercio G S Junior - LGS
Data/Hora  : 14/01/2015
*/
Function AF200COMPCR(aCompTit)
Local i, j
Local aArea 	:= GetArea()
Local aSaveOrd  := SaveOrd({"SE1","EEQ"})
Local lRetOK	:= .T.
Local lAdiant	:= .F.
Local cFaseOri  := cPrOri := cParOri := ""
Local nTaxa     := 0
Local aTaxa     := {}
Local lSeek
Local cFil
Local aFil := {}
Local nVlComp //RMD - 05/10/17
Local aDadosPcAd
Local nMoedaFin
Local xFilialSE1

//** AAF 06/01/2017 - Tratamento multifiliais
cFil := xFilial("EEQ")
If Empty(cFil)
   aAdd(aFil,cFil)
Else
   //Seleciona todas as Filiais
   aFil := AvgSelectFil(.F.)
EndIf
//**

Begin Sequence
If !EasyGParam("MV_AVG0131",,.F.)
    If AvFlags("EEC_LOGIX") //THTS - 28/03/2018
        lRetOK := AvStAction("078")
    Else
        lRetOK := .F.
	    Break
    EndIf
Else
    /** Compensação dos titulos no financeiro - Baixa **/
	SE1->(DbSetOrder(2))
	EEQ->(DbSetOrder(1))

   Pergunte("FIN330",.F.)
   lContabiliza:= MV_PAR09 == 1
   lDigita     := MV_PAR07 == 1

   For i:=1 To Len(aCompTit)
		EEQ->(DbGoTo(aCompTit[i][1]))
		cFaseOri := EEQ->EEQ_FAOR
		cPrOri   := EEQ->EEQ_PROR
		cParOri  := EEQ->EEQ_PAOR
      If IsInCallStack("AF201GrvEEQ") //RMD - 05/10/17 - A compensação automática de adiantamento pós embarque pode ser parcial, guarda o valor a ser considerado
         nVlComp := EEQ->EEQ_VL
      EndIf

      For j := 1 To Len(aFil)
         lSeek := EEQ->(DbSeek( aFil[j] + AvKey(cPrOri,"EEQ_PREEMB") + AvKey(cParOri,"EEQ_PARC") + AvKey(cFaseOri,"EEQ_FASE") ))  //NCF - 29/10/2015 - Inserido ajuste de tamanho da chave
         If lSeek
            EXIT
         EndIf
      Next j

		If lSeek

           //NCF - 04/07/2019 - Caso a parcela de adiantamento (602) tenha os campos de origem preenchidos, se trata de um adiantamento de cliente (605/606) associado no adiantamento de Pedido.
           //                   Portanto, necessita reposicionar nesta parcela para que seja retornado o tipo de adiantamento (RA/NCC) do evento que é chave para posicionar o SE1/SE5. 
           If !Empty(EEQ->EEQ_FAOR) .And. !Empty(EEQ->EEQ_PROR) .And. !Empty(EEQ->EEQ_PAOR)
              aDadosPcAd := GetAdFinInf( aFil )
           Else
              aDadosPcAd := { EEQ->EEQ_FINNUM , TETpTitEEQ("EEQ") }
           EndIf 

		   //LRS - 05/05/2016 - Correção para a compensação correta no financeiro
		   cParcela := If(EECFlags("TIT_PARCELAS") .And. EEQ->EEQ_TIPO <> "A",EECGetFinParc(EEQ->EEQ_PARC),AvKey(" ", "E1_PARCELA"))

		   /** Posiciona no RA de Origem para utilizar na compensação **/
         If FWModeAccess("SE1") == "C" .Or. (FWModeAccess("SE1") == "E" .And. FWModeAccess("EEQ") == "C")
            xFilialSE1 := xFilial("SE1")
         Else
            xFilialSE1 := aFil[j]
         EndIf
		   IF SE1->(DbSeek(xFilialSE1 + EEQ->(EEQ_IMPORT+EEQ_IMLOJA+"EEC"+AvKey(aDadosPcAd[1],"E1_NUM")+cParcela+AvKey(aDadosPcAd[2],"E1_TIPO"))))
		      aCompTit[i][3]:= SE1->(RECNO())
		      lAdiant       := .T.
		   EndIf

		   /** Efetua a compensação dos titulos RA x NF Adiantamento **/
		   If lAdiant
              aRecSE1	:= {aCompTit[i][2]}
              aRecRA		:= {aCompTit[i][3]}
              nMoedaFin := Posicione("SYF", 1, xFilial("SYF")+EEQ->EEQ_MOEDA, "YF_MOEFAT")
              If IsInCallStack("AF201GrvEEQ") //RMD - 05/10/17 - Considerar a taxa do dia da compensação no adiantamento pós embarque
                 //nTaxa := BuscaTaxa(EEQ->EEQ_MOEDA,dDataBase)
                 nTaxa := RecMoeda(dDtTaxa:= dDataBase,nMoedaFin)
                 nVlComp := nVlComp * nTaxa
              Else
                 nTaxa := If(FindFunction('AF200DtEmissa'),RecMoeda(dDtTaxa:= AF200DtEmissa(), nMoedaFin),;
                             RecMoeda(dDtTaxa:= dDataBase,nMoedaFin))
              EndIF
              aTaxa := {{nMoedaFin, nTaxa}} //LRS - 14/12/2016 - Colocado a moeda da SE1 para o funcionamento correto da comparação da taxa da moeda
              If nTaxa == 0 .Or. !MaIntBxCR(3,aRecSE1,,aRecRA,,{lContabiliza,,lDigita,.F.,.F.,.F.},,,,,nVlComp,,,,nTaxa,aTaxa)
                 EasyHelp(STR0327 + DtoC(dDtTaxa) + ".", STR0328) //"Não foi possível a compensação do titulo do adiantamento. Verifique a taxa no módulo Financeiro (SIGAFIN) para a data "  #"Aviso - Compensação" 
                 lRetOK := .F.
                 Break
              EndIf
           EndIf
        Else
           lRetOK := .F.
           EasyHelp(STR0291 + Alltrim(cPrOri)+"-"+ Alltrim(cParOri)+"-"+ Alltrim(cFaseOri)) //LRS - 28/10/2016 - Não foi possível localizar o registro para efetuar a compensação dos títulos com as seguintes chaves (Processo - Parcela - Fase): "
           Break
        EndIf
	Next
EndIF
End Sequence

RestArea(aArea)
RestOrd(aSaveOrd)
Return lRetOK

/*
Funcao     : AF200ESTCR()
Parametros : Numero do processo de embarque - Estorno da Compensação
Retorno    : .T. ou .F.
Autor      : Laercio G S Junior - LGS
Data/Hora  : 14/01/2015
*/
Function AF200ESTCR(cPreemb,lGeraTit,aTitEEQ)//RMD - 05/10/17
Local i
Local aArea 	:= GetArea()
Local aDadosPcAd
Local aSaveOrd  := SaveOrd({"SE1","SE5","EEQ"})
Local lRetOK	:= .T.
Local lAdiant	:= .F.
Local cPrOrigem := ""
Local lXCallEmb := IsInCallStack("AE100GRAVA")
Local cFil
Local aFil := {}
Local j
Local lSeek
Default lGeraTit:= .F.
Default aTitEEQ   := {} //RMD - 05/10/17 - Possibilita referenciar as parcelas que serão estornadas

Begin Sequence

If !EasyGParam("MV_AVG0131",,.F.)
    If AvFlags("EEC_LOGIX") //THTS - 28/03/2018
        lRetOK := AvStAction("079")
    EndIf
Else

    //** THTS - 19/10/2018 - Tratamento multifiliais
   cFil := xFilial("EEQ")
   If Empty(cFil)
        aAdd(aFil,cFil)
   Else
   //Seleciona todas as Filiais
        aFil := AvgSelectFil(.F.)
   EndIf
   //**

   Pergunte("FIN330",.F.)
   lContabiliza:= MV_PAR09 == 1
   lDigita     := MV_PAR07 == 1

   EEQ->(DbSetOrder(1))
   If Len(aTitEEQ) == 0 //RMD - 05/10/17 - Possibilita referenciar as parcelas que serão estornadas
      If EEQ->(DbSeek(xFilial("EEQ")+cPreemb))
         cPrOrigem := EEQ->EEQ_PREEMB
         Do While EEQ->EEQ_FILIAL == EEQ->(xFilial()) .And. EEQ->EEQ_PREEMB == cPreemb .And. EEQ->(!Eof())
            If cPrOrigem == EEQ->EEQ_PREEMB .And. !Empty(EEQ->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR))
               aAdd (aTitEEQ,{EEQ->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR),EEQ->(RECNO())})
            EndIf
            EEQ->(DbSkip())
         EndDo
      EndIf
   Else
      cPrOrigem := cPreemb
   EndIF

   EEQ->(DbSetOrder(7))
   For i:= 1 To Len(aTitEEQ)
      If EEQ->(DBSETORDER(7),DbSeek(xFilial("EEQ")+aTitEEQ[i][1]))

         Do While EEQ->(!Eof()) .And. aTitEEQ[i][1] == EEQ->(EEQ_FAOR+EEQ_PROR+EEQ_PAOR) //MCF - 12/12/2016
              
            //RMD - 05/10/17 - Verifica se é a parcela correta (pode ter mais de uma parcela referenciada ao mesmo adiantamento)
            If EEQ->(Recno()) <> aTitEEQ[i][2]
               EEQ->(DbSkip())
               Loop//RMD - 21/03/18
            EndIf

            If EEQ->EEQ_PREEMB == cPrOrigem //MCF - 12/12/2016 - Mesmo adiantamento em diferentes processos

               cParcela := If(EECFlags("TIT_PARCELAS"),EECGetFinParc(EEQ->EEQ_PARC),AvKey(" ", "E1_PARCELA"))

               /** Posiciona no NF para utilizar no estorno da compensação **/
               SE1->(DbSetOrder(2))
               //RMD - 12/03/18 - Se for um adiantamento pós-embarque, posiciona no evento 101 correspondente a partir do campo EEQ_PARVIN para obter o título do evento 101. 
                  IF SE1->(DbSeek(xFilial("SE1")+EEQ->EEQ_IMPORT+EEQ->EEQ_IMLOJA+"EEC"+EEQ->EEQ_FINNUM+cParcela+AvKey("NF","E1_TIPO")))
                     lAdiant := .T.
                     aRecSE1 := {SE1->(Recno())}
                  EndIf
                //THTS - 19/10/2018 - Posiciona o RA
                EEQ->(DbSetOrder(6))
                For j := 1 To Len(aFil)
                    lSeek := EEQ->(DbSeek( aFil[j] + aTitEEQ[i][1] ))
                    If lSeek
                        EXIT
                    EndIf
                Next j
                
                If !lSeek
                    EasyHelp(STR0329) //"Não foi possível efetuar o estorno da compensação, pois o adiantamento não foi encontrado."
                    lRetOK := .F.
                    Break
                EndIf

                //NCF - 04/07/2019 - Caso a parcela de adiantamento (602) tenha os campos de origem preenchidos, se trata de um adiantamento de cliente (605/606) associado no adiantamento de Pedido.
                //                   Portanto, necessita reposicionar nesta parcela para que seja retornado o tipo de adiantamento (RA/NCC) do evento que é chave para posicionar o SE1/SE5. 
                If !Empty(EEQ->EEQ_FAOR) .And. !Empty(EEQ->EEQ_PROR) .And. !Empty(EEQ->EEQ_PAOR)
                   aDadosPcAd := GetAdFinInf( aFil )
                Else
                   aDadosPcAd := { EEQ->EEQ_FINNUM , TETpTitEEQ("EEQ") }
                EndIf 

               //RMD - 12/03/18 - Monta a chave do RA e posiciona no registro do 603 no EEQ
               cChaveRA := AvKey("EEC", "E1_PREFIXO") + aDadosPcAd[1] + AvKey("", "E1_PARCELA") + AvKey(aDadosPcAd[2], "E1_TIPO")
               
               EEQ->(DbSetOrder(7))
               EEQ->(dbGoTo(aTitEEQ[i][2]))

               /** Efetua o estorno da compensação dos titulos NF Adiantamento **/
               If lAdiant
                  SE5->(DbSetOrder(7))
                  If SE5->(DbSeek(xFilial("SE5")+AvKey("EEC", "E5_PREFIXO")+SE1->(E1_NUM+E1_PARCELA+E1_TIPO)))// RMD - 14/08/17 - Envia a parcela e tipo na chave / Adiciona AvKey SE5->(DbSeek(xFilial("SE5")+"EEC"+SE1->E1_NUM))

                     Do While SE5->(!Eof() .And. E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO == xFilial("SE5")+AvKey("EEC", "E5_PREFIXO")+SE1->(E1_NUM+E1_PARCELA+E1_TIPO)) //RMD - 05/10/17 - faltava checar o título
				        //If !Empty(SE5->E5_DOCUMEN) RMD - 12/03/18 - Verifica se é o E5 correto com base na chave do RA (pode ter ocorrido mais de uma compensação)
                        If !Empty(SE5->E5_DOCUMEN) .And. Left(SE5->E5_DOCUMEN, Len(cChaveRA)) == cChaveRA
                           lAdiant		:= .F.
                           aEstorno		:= {}
                           aAdd(aEstorno,{SE5->E5_DOCUMEN})
                           //MFR 14/02/2019 OSSME-2277
                           If MaIntBxCR(3,aRecSE1,,      ,,{lContabiliza,,lDigita,.F.,.F.,.F.},, aEstorno)
                                If lXCallEmb
                                    If (lRetOK := AvStAction("007")) // (IsInCallStack("AE100RECADIAN") .And. EEQ_EVENT == "603" .And. EECFlags("ALT_EASYLINK")) .Or. 
                                        EEQ->EEQ_NR_CON	:= ""
                                        EEQ->EEQ_FINNUM	:= ""
                                        lAdiant         := If (lGeraTit, AF200RECCR(aTitEEQ[i][2]), .T.)
                                    Else
                                        lAdiant := .T.
                                    EndIf
                                Else
                                    lAdiant := .T.
                                EndIf
                                If !lRetOK
                                    Break
                                EndIf
                           EndIf
                           Exit
                        EndIf
                        SE5->(DbSkip())
                     EndDo
                     If !lAdiant
				        Help("XAFCMPAD",1,"HELP","XAFCMPAD","Não foi possível o estorno da compensação"+CRLF+" do titulo do adiantamento",1,0)
				        lRetOK := .F.
				        Break
				     EndIf
                  Else
                     lRetOK := .F.
                     easyhelp( STR0330+Alltrim(SE1->(E1_NUM+E1_PARCELA+E1_TIPO))+"." )// MENSAGEM de que não achou a movimentação financeira da compensação
                     Break
                  EndIf
               EndIf
            EndIf
            EEQ->(DBSKIP())
         ENDDO
      Else
         easyhelp( StrTran(STR0331, "###", Alltrim(aTitEEQ[i][1]) ) )  //"Parcela de câmbio: ### não foi encontrada."
         lRetOK := .F.
         Break
      EndIf
   Next
EndIF
End Sequence

RestArea(aArea)
RestOrd(aSaveOrd, .T.)
Return lRetOK

/*
Funcao     : AF200RECCR()
Parametros : Recno da EEQ para recriar o titulo no financeiro
Retorno    : .T. ou .F.
Autor      : Laercio G S Junior - LGS
Data/Hora  : 14/01/2015
*/
Function AF200RECCR(nRecno)
Local lRetOk:= .T.
Local lLock := .F.

Begin Sequence
EEQ->(DbGoTo(nRecno))
If !EEQ->(IsLocked())
	EEQ->(RecLock("EEQ",.F.))
	lLock := .T.
EndIf

EEQ->EEQ_EMISSA := EEC->EEC_DTEMBA
EEQ->EEQ_VCT    := aPARC[1,2]
If EEQ->(FieldPos("EEQ_HVCT")) > 0
   EEQ->EEQ_HVCT:= aPARC[1,2]
EndIf

If lLock
   EEQ->(MsUnLock())
EndIf

/** Grava novamente o titulo no financeiro apartir da alteração de data
    e faz a compensação com o RA de refencia **/
If (lRet := AvStAction("005"))
	aCompTit :={}
	aAdd (aCompTit,{EEQ->(RECNO()),SE1->(RECNO()),0})
	If !(lRet := AF200COMPCR(aCompTit))
		lRetOk:= .F.
		Break
	EndIf
EndIf
End Sequence

Return lRetOk


/*
Funcao     : AF200RatCG()
Parametros : Array de parcelas de câmbio de exportação para geração
Retorno    : aParcelas - arrays das parcelas com o ajuste no valor das parcelas de comissão
Autor      : Nilson Cesar
Data/Hora  : 30/10/2015
*/
Static Function AF200RatCG(aParcelas)

Local nVlComCGraf := 0
Local nQtdPrcCGf  := 0
Local nVlResPrc   := 0
local nVlrCGfAdt  := 0
Local aInfAdtMEx  := AF200TotParc(xFilial("EEQ"),{|| EEQ->EEQ_MODAL == '2' })
Local nTotAdMovEx := aInfAdtMEx[3]
Local nPosPrcP    := 0
Local i
Default aParcelas := {}

aEval( aParcelas, {|x|  If(x[3] == '101', nVlResPrc   += x[1], )                                          }  )
aEval( aParcelas, {|x|  If(x[3] == '121', nVlComCGraf += x[1], ) , If(x[3] == '121', nQtdPrcCGf++, )      }  )

If nVlComCGraf > 0

   oRatComCG  := EasyRateio():New(nVlComCGraf, nVlResPrc + nTotAdMovEx ,nQtdPrcCGf+1,2) //Acrescenta 1 na qtde. de parcelas para considerar o valor rat. para o adiant.
   nVlrCGfAdt := oRatComCG:GetItemRateio(nTotAdMovEx) //Valor da Comissão Conta Grafica da parc. de Adiantamento
   For i := 1 To Len(aParcelas)
      If aParcelas[i][3] == '121'                     //Parcela de principal que possua mesmo vencimento e mesma invoice da parcela de comissão conta gráfica
         If( nPosPrcP :=  Ascan(aParcelas,{|y| y[3] == '101' .And. aParcelas[i][2] == y[2] .And. aParcelas[i][8] == y[8] }) ) > 0
            aParcelas[i][1] := oRatComCG:GetItemRateio(aParcelas[nPosPrcP][1])
         EndIf
      EndIf
   Next i

EndIf

Return aParcelas

Function Af200ChkMd(cMoeda, dData, cCampo, cEvento)
Local lRet := .T.
Local cModulo := If(cCampo <> Nil .And. cCampo == "YF_MOEFAT", "exportação", "importação")
Local cMoedaERP := If(cCampo <> Nil, Posicione("SYF", 1, xFilial("SYF")+cMoeda, cCampo), SimbToMoeda(cMoeda))
Local cMensagem :=	STR0332 + ENTER +; //"Foi identificada uma divergência no cadastro de cotação de moedas entre o módulo de MSG01 e o financeiro."
					STR0333 + ENTER +; //"Considerando a moeda 'MSG02' e a data da operação 'MSG03', foi identificado que:"
					STR0334 + ENTER +; //"No módulo de MSG01 foi cadastrada a taxa de 'MSG04', enquanto que no módulo financeiro foi cadastrada a taxa 'MSG05'."
					STR0335            //"Será necessário ajustar os cadastros antes de efetuar a baixa da parcela, visto que as informações divergentes poderiam ocasionar em diferenças na integração entre os módulos."
Local aMensagens, cTexto, i
Local cC6_TXCV 
Local nTaxaEasy 
Local nTaxaERP := RecMoeda(dData, cMoedaERP)

   If cEvento != NIL
      cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+If(cModulo=="exportação","EXPORT","IMPORT")+cEvento,"EC6_TXCV")
   ENDIF
   
   nTaxaEasy := BuscaTaxa(cMoeda, dData,, .F.,,,cC6_TXCV) 

   If empty(cMoeda) .And.  EasyVerModal("M")
      EasyHelp(STR0357, STR0016) //Banco no exterior sem moeda cadastrada
      Return .F.
   EndIf

	If !(lRet := nTaxaEasy == nTaxaERP)
		aMensagens := {cModulo, cMoeda, dData, nTaxaEasy, nTaxaERP}
		For i := 1 To Len(aMensagens)
			cTexto := ""
			Do Case
				Case ValType(aMensagens[i]) == "C"
					cTexto := AllTrim(aMensagens[i])
				Case ValType(aMensagens[i]) == "N"
					cTexto := AllTrim(Str(aMensagens[i], 11, 8))
				Case ValType(aMensagens[i]) == "D"
					cTexto := DToC(aMensagens[i])
			EndCase
			cMensagem := StrTran(cMensagem, "MSG"+StrZero(i, 2), cTexto)
		Next
		EasyHelp(cMensagem, "Aviso")
    EndIf

Return lRet

//RMD - 10/02/17 - Checa se a parcela foi quebrada após a data de crédito no exterior ter sido preenchida
//Considera o TMP posicionado
Function IsQbrMExt(cAlias)
Local lRet := .F.
Local nVal := 0
Local cTitulo := (cAlias)->EEQ_FINNUM
Local cParc := (cAlias)->EEQ_PARC
Local cSeqBx := (cAlias)->EEQ_SEQBX
Local cParVin:= (cAlias)->EEQ_PARVIN
Local nRecno := (cAlias)->(Recno())
Local aAreaAlias:= (cAlias)->(getArea())
Local nParcAnt
Default cAlias := "TMP"

	If !EECFlags("ALT_EASYLINK") .And. EasyVerModal(cAlias) .And. !Empty((cAlias)->EEQ_DTCE) .and. !avflags("EEC_LOGIX")

      nVal := iIf(EasyGParam("MV_AVG0214",,.F.) , 0 , (cAlias)->EEQ_CGRAFI )
      if (cAlias)->EEQ_VL - nVal <> Posicione("SE1", 1, xFilial("SE1")+AvKey("EEC", "E1_PREFIXO")+AvKey((cAlias)->EEQ_FINNUM, "E1_NUM")+AvKey(If(EECFlags("TIT_PARCELAS"),EECGetFinParc((cAlias)->EEQ_PARC),''), "E1_PARCELA"), "E1_VALOR")
		   lRet := .T.
      endif
   elseif (avflags("EEC_LOGIX") .Or. EECFlags("ALT_EASYLINK")) .And. !Empty((cAlias)->EEQ_DTCE) .And. EasyVerModal(cAlias)
      (cAlias)->(dbSetOrder(1))//TMP: EEQ_PARC ### EEQ: EEQ_FILIAL+EEQ_PREEMB+EEQ_PARC+EEQ_FASE
      cChaveAlias := StrTran((cAlias)->(IndexKey()),"EEQ_PARC","EEQ_ORIGEM")
      If (cAlias)->(dbSeek(&cChaveAlias))//Achou a parcela de Origem
         If cParc <> (cAlias)->EEQ_PARC .and. cTitulo+cSeqBx == (cAlias)->(EEQ_FINNUM+EEQ_SEQBX) // NCF - 25/11/2019 - Só é quebra da mesma parcela após crédito no exterior quando Nro.Tíutlo+Seq.Baixa são os mesmos pois 
            lRet := .T.
         EndIf
      Else//Não achou a parcela de origem, verificar se existem outras parcelas para receber o valor (EEQ_PARVIN)
         (cAlias)->(dbGoTo(nRecno))
         nParcAnt := (val(&cChaveAlias)-1)
         While nParcAnt > 0
            If (cAlias)->(dbSeek(StrZero(nParcAnt,AvSx3("EEQ_PARC", AV_TAMANHO)))) .And. cParVin == (cAlias)->EEQ_PARVIN .And. cTitulo+cSeqBx == (cAlias)->(EEQ_FINNUM+EEQ_SEQBX)
               lRet := .T.
               Exit
            EndIf
            nParcAnt--
         End
      EndIf
      RestArea(aAreaAlias)
	EndIf

Return lRet

/*
Funcao     : GrvAF200Mn()
Parametros : <Nenhum>
Retorno    : lGrvMntCmb
Objetivo   : Migrada toda a gravação do câmbio para esta função sem nenhum prejuízo de código,
             visando possibilitar o disparo da gravação direta em outros pontos da manutenção.
Autor      : Nilson Cesar
Data/Hora  : 23/03/2017
*/
STATIC Function GrvAF200Mn()

Local lIncTit := .F.
Local aRecPosEmb:= {}
// ** GFC - Pré-Pagamento
Local nSaldoVin, aCopia:={}
Local nRecTmp:= 0
Local nTmpOrd := 0 //FSM - 07/03/2012
Local aCposInt:= {"EEQ_FORN", "EEQ_FOLOJA", "EEQ_IMPORT", "EEQ_IMLOJA", "EEQ_BANC", "EEQ_VCT", "EEQ_VL"}
Local aParcLiq   := {}
Local bOnError := { |cFuncName, nOpc| AF200RetLiq(aParcLiq,cFuncName,nOpc,"CAMBIO")}
Local aReg := {}
Local aTMPEstBx := {}, nRecOpTmp := 0, nPosTmp := 0
Local lGrvMntCmb := !lRollback
Local i,z
Local aOrdAdt	:= {} //THTS - 29/03/2017
Local lSE5Posic
Local lTitExp := .F.
Local cC6_TXCV
Local aNfLoteEF3 := {}
Private aEAIAF520 := {} //THTS - 26/04/

      If Type("lIntAltLGX") <> "L"
         lIntAltLGX:= .F.
      EndIf

      EasyEAIBuffer("INICIO")
      Begin Transaction
         // ** By JBJ - Cotação de Cambio.
         If lCotaCambio
            AF200RecCot()
         EndIf

         //JPM - 30/12/04
         If lNRotinaLC .and. !Empty(EEC->EEC_LC_NUM) .and. len(aRestSaldo) > 0
            EEL->(DbSetOrder(1))
            EEL->(DbSeek(xFilial("EEL")+EEC->EEC_LC_NUM))
            RecLock("EEL",.f.)
            For i := 1 to len(aRestSaldo)
               If aRestSaldo[i][3] == "R" //Restaurar Saldo
                  EEL->EEL_SLDVNC += aRestSaldo[i][2]
                  EEL->EEL_SLDEMB += aRestSaldo[i][2]
               ElseIf aRestSaldo[i][3] == "A" //Abater Saldo
                  EEL->EEL_SLDVNC -= aRestSaldo[i][2]
                  EEL->EEL_SLDEMB -= aRestSaldo[i][2]
               Endif
            Next
            EEL->(MsUnlock())
         Endif
         
         TMP->(dbCloseArea())
         For z:=1 To Len(aDeletados)
            EEQ->(dbGoTo(aDeletados[z]))
            //RMD - 10/11/07 - Nova legislação de câmbio
            If EECFlags("CAMBIO_EXT")
               //Exclui movimentações
               AD101GrvInv("EEQ", "EEQ", "EXPBXG", .T.)
               AD101GrvInv("EEQ", "EEQ", "EXPLIQ", .T.)
            EndIf
            //ALCIR ALVES
            If EasyEntryPoint("EECAF200")
              ExecBlock("EECAF200", .f., .f., "EXC_CAMBIO")
            Endif
            EEQ->(RecLock("EEQ",.F.))
            If IsReceita(EEQ->EEQ_EVENT) .And. !Empty(EEQ->EEQ_FINNUM) .And. !IsQbrMExt("EEQ") .And. (!EECFlags("TIT_PARCELAS") .And. !EECFlags("ALT_EASYLINK") .Or. (EEQ->EEQ_PARVIN == EEQ->EEQ_PARC))//RMD - 06/10/12 - Não gera título para parcelas "filhas".
               If !AvStAction("007")//Exclusão de título a receber no SIGAFIN
                  lRollBack := .T.
                  Exit
               EndIf
            //ElseIf EEQ->EEQ_EVENT $ "121/122" .And. !Empty(EEQ->EEQ_FINNUM)
            ElseIf ( EEQ->EEQ_EVENT $ cDespIntFin .Or. ( !AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT )) .And. !Empty(EEQ->EEQ_FINNUM) //Estorna o contas a pagar de despesas internacionais e comissão a remeter.
               If !AvStAction("012")//Exclusão de título a pagar no SIGAFIN
                  lRollBack := .T.
                  Exit
               EndIf
            EndIf
            EEQ->(dbDelete())

            EEQ->(MsUnlock())

         Next

         If !lRollBack

            //FSM - 07/03/2012 - Reabre a Work TMP
            If Select("TMP") > 0
                TMP->(dbCloseArea())
            EndIf
            
            Af200AbTmp()
            TMP->(dbSetOrder(nTmpOrd))
            

            Af200CtrRen(1) //Controle de Renovação de Saldo de L/Cs renováveis - 1ª parte

            //GFP - 19/05/2011
            If AvFlags("WORKFLOW")
               aChaves := EasyGroupWF("CAMBIO_EEC")
            EndIf

            If AVFLAGS("EEC_LOGIX")
               TMP->(DBGOTOP())
               aTMPEstBx := {}
               DO WHILE !TMP->(EOF()) .And. !lRollBack
                  aReg := {}
                  FOR i:=1 To TMP->(Fcount())
                     aAdd(aReg, &("TMP->"+TMP->(FIELDNAME(i)) ) )
                  Next i
                  aAdd(aTMPAlt, aReg)
                  aAdd(aTMPEstBx, { TMP->(Recno()), TMP->EEQ_FINNUM, TMP->EEQ_SEQBX })
                  TMP->(DbSkip())
               ENDDO
               ASORT(aTMPAlt,,, {|x,y| VAL( x[ TMP->(FieldPos("EEQ_FINNUM")) ]) > VAL(y[ TMP->(FieldPos("EEQ_FINNUM")) ])   .And.  x[ TMP->(FieldPos("EEQ_VCT")) ] > y[ TMP->(FieldPos("EEQ_VCT")) ]    } )
	           ASORT(aTMPEstBx,,, {|x,y| x[2]+x[3] > y[2]+y[3]} )
            EndIf

            TMP->(DBGOTOP())
            aLiqAux := aClone(aLiquida)  //GFC 14/01/05

            nPosTmp := 0
            DO WHILE !TMP->(EOF()) .And. !lRollBack

               If AvFlags("EEC_LOGIX")
                  nRecOpTmp := TMP->(RecNo())
                  nPosTmp++
                  TMP->(dbGoTo(aTMPEstBx[nPosTmp][1]))
               EndIf

               lAlt_Pgt := .F.	  // EOB
               lAltTit  := .F.
               lIncTit  := .F.

				 //THTS - 29/03/2017 - Atualiza o saldo do adiantamento de fornecedores
                If AvFlags("ADTFOREAI") .And. TMP->(Recno()) == nRecAdtFor .And. (((lAdtForVin .Or. lAdtForEst) .And. (TMP->EEQ_TIPO == "P" .Or. TMP->EEQ_TIPO == "L" )) ;
                                                                             .or. ( (lAdtCliVin .or. lAdtCliEst) .and. (TMP->EEQ_TIPO == "A" .Or. TMP->EEQ_TIPO == "R") ))
                    aOrdAdt := SaveOrd({"EEQ"})
                    EEQ->(dbGoTo(TMP->TRB_REC_WT))
                    
                    If lAdtForVin .And. !lAdtForEst .And. !Empty(TMP->EEQ_PROR) .And. !Empty(TMP->EEQ_FAOR) .And. !Empty(TMP->EEQ_PAOR) //Esta vinculando o adiantamento a fornecedor
                        EEQ->(dbSetOrder(16))//EEQ_FILIAL, EEQ_PREEMB, EEQ_EVENT, EEQ_FASE, EEQ_FORN, EEQ_FOLOJA, EEQ_PARC
                        EEQ->(dbSeek(xFilial("EEQ") + TMP->EEQ_PROR + "609" + "F" + TMP->EEQ_FORN + TMP->EEQ_FOLOJA + TMP->EEQ_PAOR))
                        EEQ->(RecLock("EEQ",.F.))
                        EEQ->EEQ_SALDO := EEQ->EEQ_SALDO - TMP->EEQ_VL
                        EEQ->(MsUnlock())
                        lAdtForVin := .F.
                        lAdtForBkp := .T.
                    ElseIf !lAdtForVin .And. lAdtForEst  .And. !Empty(EEQ->EEQ_PROR) .And. !Empty(EEQ->EEQ_FAOR) .And. !Empty(EEQ->EEQ_PAOR) //Esta estornando a vinculacao do adiantamento a fornecedor
                        EEQ->(dbSetOrder(16))//EEQ_FILIAL, EEQ_PREEMB, EEQ_EVENT, EEQ_FASE, EEQ_FORN, EEQ_FOLOJA, EEQ_PARC
                        EEQ->(dbSeek(xFilial("EEQ") + EEQ->EEQ_PROR + "609" + "F" + EEQ->EEQ_FORN + EEQ->EEQ_FOLOJA + EEQ->EEQ_PAOR))
                        EEQ->(RecLock("EEQ",.F.))
                        EEQ->EEQ_SALDO := EEQ->EEQ_SALDO + TMP->EEQ_VL
                        EEQ->(MsUnlock())	
                        lAdtForEst := .F.
                        lAdtForBkp := .T.
                    ElseIf lAdtCliVin .And. !lAdtCliEst  .And. !Empty(TMP->EEQ_PROR) .And. !Empty(TMP->EEQ_FAOR) .And. !Empty(TMP->EEQ_PAOR) //Esta vinculando o adiantamento a cliente
                        EEQ->( dbsetorder(6),dbSeek(TMP->(EEQ_FILIAL+EEQ_FAOR+EEQ_PROR+EEQ_PAOR)))
                        EEQ->(RecLock("EEQ",.F.))
                        EEQ->EEQ_SALDO := EEQ->EEQ_SALDO - TMP->EEQ_VL
                        EEQ->(MsUnlock())

                        EEQ->( dbgoto( TMP->TMP_RECNO ) )
                        EEQ->(RecLock("EEQ",.F.))
                            AvReplace("TMP","EEQ")
                        EEQ->(MsUnlock())

                        //Compensa o título com a integração 
                        lRollBack := !AF200COMPCR({{ EEQ->( recno() ) }})

                        lAdtCliVin := .F.
                        lAdtForBkp := .T.
                    ElseIf !lAdtCliVin .And. lAdtCliEst  .And. !Empty(EEQ->EEQ_PROR) .And. !Empty(EEQ->EEQ_FAOR) .And. !Empty(EEQ->EEQ_PAOR) //Esta estornando a vinculacao do adiantamento a cliente
                        EEQ->( dbsetorder(6),dbSeek(EEQ->(EEQ_FILIAL+EEQ_FAOR+EEQ_PROR+EEQ_PAOR)))
                        EEQ->(RecLock("EEQ",.F.))
                        EEQ->EEQ_SALDO := EEQ->EEQ_SALDO + TMP->EEQ_VL
                        EEQ->(MsUnlock())

                        //Estorna o título com a integração
                        EEQ->( dbgoto( TMP->TMP_RECNO ) )
                        lRollBack := !AF200ESTCR(EEQ->EEQ_PREEMB,,{{ EEQ->( recno() ) }})

                        lAdtCliEst := .F.
                        lAdtForBkp := .T.
                    EndIf
                    RestOrd(aOrdAdt,.T.)
                EndIf

               IF TMP->TMP_RECNO == 0
                  //RMD - 10/11/07 - Nova legislação de câmbio
                  If EECFlags("CAMBIO_EXT")
                     //Grava as movimentações
                     AD101GrvInv("EEQ", "TMP", "EXPBXG",, TMP->TMP_RECNO <> 0)
                     AD101GrvInv("EEQ", "TMP", "EXPLIQ",, TMP->TMP_RECNO <> 0)
                  EndIf

                  EEQ->(RecLock("EEQ",.T.))
                  nRecTMPInc := TMP->(Recno())   //NCF 23/03/2017
                  lIncTit := .T.
               Else
                  EEQ->(dbGoTo(TMP->TMP_RECNO))
                  Af200CtrRen(2) //Controle de Renovação de Saldo de L/Cs renováveis - 2ª parte

                  //RMD - 10/11/07 - Nova legislação de câmbio
                  If EECFlags("CAMBIO_EXT")
                     //Grava as movimentações
                     AD101GrvInv("EEQ", "TMP", "EXPBXG",, TMP->TMP_RECNO <> 0)
                     AD101GrvInv("EEQ", "TMP", "EXPLIQ",, TMP->TMP_RECNO <> 0)
                  EndIf

                  EEQ->(RECLOCK("EEQ",.F.))

                  // lAltTit:= AvGeraTit("TMP","EEQ",aCposInt) //Verifica se houve alteração que implica na recriação dos títulos no financeiro (sigafin)
               Endif

               //RMD - 09/01/15 - Guarda o recno do novo registro
               nRegAtuEEQ := EEQ->(Recno())

               If Tmp->EEQ_EVENT == "101"
                  If lTodasLiquidadas .And. Empty(Tmp->EEQ_PGT) //para controle de renovação de saldos de L/C
                     lTodasLiquidadas := .f.
                  EndIf
                  If lTodasLiqBase .And. Empty(EEQ->EEQ_PGT)
                     lTodasLiqBase := .f.
                  EndIf

                  If lNaoHaLiquidadas .And. !Empty(Tmp->EEQ_PGT) //para controle de renovação de saldos de L/C
                     lNaoHaLiquidadas := .f.
                  EndIf
                  If lNaoHaLiqBase .And. !Empty(EEQ->EEQ_PGT)
                     lNaoHaLiqBase := .f.
                  EndIf
               EndIf
			   //LGS-28/08/2014
               lModalExt := If (TMP->(FieldPos("EEQ_MODAL")) > 0,.T.,.F.)

               If !lModalExt .Or. !EasyVerModal("TMP") .Or. Empty(TMP->EEQ_MODAL) //MCF - 20/01/2016 - Validação para campo em branco //TMP->EEQ_MODAL = "1"
	               If (TMP->EEQ_PGT <> EEQ->EEQ_PGT .And. TMP->TMP_RECNO <> 0) .OR. (TMP->TMP_RECNO == 0 .AND. !Empty(TMP->EEQ_PGT))
		               lAlt_Pgt := .T.
	               EndIf
               Else
                  If AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal("TMP") .And. !IsReceita(TMP->EEQ_EVENT)  .And. !Empty(TMP->EEQ_BCOEXT) .And. ;
                     ( (TMP->EEQ_PGT <> EEQ->EEQ_PGT .And. TMP->TMP_RECNO <> 0) .OR. (TMP->TMP_RECNO == 0 .AND. !Empty(TMP->EEQ_PGT)) )
                     If TMP->EEQ_MOEBCO <> TMP->EEQ_MOEDA                                //NCF - 30/09/2015 - Taxa de câmbio a pagar (paridade) negociada entre moeda da invoice
                        TMP->EEQ_TX   := TMP->EEQ_PRINBC 				                 //                   e moeda do banco no exterior onde será feita a baixa.
                        TMP->EEQ_EQVL := (TMP->EEQ_TX * (TMP->EEQ_VL))
                     EndIf
                     lAlt_Pgt := .T.
                  Else
                     If TMP->EEQ_DTCE <> EEQ->EEQ_DTCE .And. TMP->TMP_RECNO <> 0 .OR. TMP->TMP_RECNO == 0 .AND. !Empty(TMP->EEQ_DTCE) .AND. Empty(TMP->EEQ_FINNUM)
                        lAlt_Pgt := .T.
                        if !avflags("EEC_LOGIX")
                           AF200TITFIN(TMP->EEQ_FINNUM,,TMP->EEQ_PARC)//RMD - 21/01/15 - Deve enviar a parcela, e o alias correto é "TMP".
                        endif
                        If !Empty(TMP->EEQ_DTCE) .And. (SE1->E1_STATUS == "A" .or. avflags("EEC_LOGIX") .and. empty(TMP->EEQ_SEQBX) )  	  //Baixa do Titulo no Financeiro
                           lTitExp := .T.
                           cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+TMP->EEQ_EVENT,"EC6_TXCV")
                           TMP->EEQ_TX   := BuscaTaxa(TMP->EEQ_MOEDA,TMP->EEQ_DTCE,,,,,cC6_TXCV) 						  //Taxa cambio do dia
                           TMP->EEQ_EQVL := TMP->EEQ_TX * TMP->EEQ_VLFCAM 
                        ElseIf Empty(TMP->EEQ_DTCE) .And. (SE1->E1_STATUS == "B" .or. avflags("EEC_LOGIX") .and. !empty(TMP->EEQ_SEQBX) )//Estorno do Titulo no Financeiro
                           lTitExp := .F.
                           AF200TITFIN("",2)
                        EndIf
                     EndIf
                     If TMP->EEQ_PGT <> EEQ->EEQ_PGT .And. TMP->TMP_RECNO <> 0 .OR. TMP->TMP_RECNO == 0 .AND. !Empty(TMP->EEQ_PGT)
                        if !avflags("EEC_LOGIX")
                           //MFR OSSME-2277 12/02/2019
                           If IsIntEnable("001") .And. MovBcoBx(EECGetMotBx("TMP", EasyVerModal("TMP") .And. !Empty(EEQ->EEQ_DTCE)),.T.) .And. !TransfBanco(Empty(TMP->EEQ_PGT))
                              lRollBack := .T.
                              Exit
                           EndIf
                        else
                           if EC6->(fieldpos("EC6_MVBCLQ")) > 0 .and. EC6->(DbSeek(xFilial("EC6")+AVKey("EXPORT", "EC6_TPMODU")+M->EEQ_EVENT)) .AND. EC6->EC6_MVBCLQ = '1'
                              //EasyEAIBuffer("INICIO")
                              if ! EECAF233() // ADAPTER DE MOVIMENTAÇÃO DO TÍTULO NO EXTERIOR -ACCOUNTRECEIVABLEDOCUMENTDISCHARGE
                                 lRollBack := .T.
                              endif
                           endif
                        endif
	                 EndIf
	              EndIf
               EndIf

               If lCpoAcrDcr
                  aAdd(aCposInt, "EEQ_ACRESC" )
                  aAdd(aCposInt, "EEQ_DECRES")
               EndIf

               If AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ TMP->EEQ_EVENT
                  aAdd(aCposInt, "EEQ_MODAL")
               EndIf
               
               //Verifica se houve alteração que implica na recriação dos títulos no financeiro (sigafin)
               lAltTit:= AvGeraTit("TMP","EEQ",aCposInt)
               
               //NCF - 20/08/2014 - Flag que permite alteração de vcto. de título integrado ao Logix
               If TMP->EEQ_PGT <> EEQ->EEQ_PGT .Or. lIntAltLGX .OR. ( TMP->EEQ_DTCE <> EEQ->EEQ_DTCE .AND. EasyVerModal("M") )
                  aReg := {}
                  FOR i:=1 To EEQ->(Fcount())
                     aAdd(aReg, &("EEQ->"+EEQ->(FIELDNAME(i)) ) )
                  Next i
                  aAdd(aParcLiq, aReg)
               EndIf

               //RMD - 09/01/15 - Retorna o registro do EEQ (caso tenha sido desposicionado na integração do movimento bancário).
               If EEQ->(Recno()) != nRegAtuEEQ
                    EEQ->(DbGoTo(nRegAtuEEQ))
               EndIf
               If !EEQ->(IsLocked())
                  EEQ->(RecLock("EEQ",.F.))
               EndIf
                
                // 27/07/2018 - Mpg - valor e data para correto posicionamento na SE5 quando estorno de uma parcela e quando 
                nVlrBx      := getValorBx(EasyVerModal("EEQ"),EEQ->EEQ_BANC,EEQ->EEQ_AGEN,EEQ->EEQ_NCON) //iif( !EasyVerModal("EEQ"), EEQ->EEQ_EQVL , EEQ->EEQ_VL   )
                dDtBxSE5    := iif( !EasyVerModal("EEQ"), EEQ->EEQ_PGT  , EEQ->EEQ_DTCE )
                
                AvReplace("TMP","EEQ")

               IF lPagtoAnte
                  EEQ->EEQ_FASE = "E"
               ENDIF

               //THTS - 06/04/2017 - Grava o campo de versão do adapter a ser utilizado quando integrado ao Logix.
               If ! EEQ->EEQ_TIPO $ "A|R" .And. AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0
                   EEQ->EEQ_EAIVRS := "2"
               ElseIf EEQ->(FieldPos("EEQ_EAIVRS")) > 0
                   EEQ->EEQ_EAIVRS := "1"
               EndIf

               EEC->(RecLock("EEC",.F.))
               EEC->EEC_STATUS := M->EEC_STATUS
               EEC->EEC_STTDES := M->EEC_STTDES

               // Compatibilização com a versão anterior
               IF VAL(TMP->EEQ_PARC) = 1                // BY JPP - 07/12/04 -16:55 - Os campos abaixo foram retirados, por que eles não existem mais na base de dados.
                  EEC->EEC_DECAM  := TMP->EEQ_DECAM
               ENDIF
               EEC->(msUnlock())
               If EasyEntryPoint("EECAF200")
                   ExecBlock("EECAF200", .f., .f., "PE_STATUS_A")
               EndIf

               If lFinanciamento .and. TMP->EEQ_EVENT == "101"
                  nSaldoVin := 0
                  h:=1
                  lShowMsg := .F.
                  Do While h <= Len(aArrayEEQ) //For h:=1 to Len(aArrayEEQ)
                     // Atualiza Valores no Array para Invoices Vinculadas
                     If WorkEEQ->(DbSeek(aArrayEEQ[h,3]+aArrayEEQ[h,5]+iif(lTemChave,aArrayEEQ[h,14]+aArrayEEQ[h,15]+If(lEFFTpMod,aArrayEEQ[h,21],""),"")))
                        If aArrayEEQ[h,1] == WorkEEQ->VL_ORI .And. WorkEEQ->EEQ_VL # WorkEEQ->VL_ORI
                           aArrayEEQ[h,1] := WorkEEQ->EEQ_VL
                        Endif
                     Endif

                     // ** GFC - Pré-Pagamento/Securitização
                     If aArrayEEQ[h,16] = NIL
                        EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,If(TMP->EEQ_TP_CON $ ("2/4"),"I","E"),"")+aArrayEEQ[h,5]+iif(lTemChave,aArrayEEQ[h,14]+aArrayEEQ[h,15]+If(lEFFTpMod,aArrayEEQ[h,21],""),""))) //HVR SEEK I OU E
                        If lPrePag .and. IF(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $ ("03/04")) //HVR 25/04/06 - DE: EF1->EF1_TP_FIN $ ("03/04") PARA:(IF EF1->EF1_CAMTRA == "1",.T.,IF EF1->EF1_TP_FIN $ ("03/04")) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO

                           //Posiciona na primeira parcela em aberto
                           //If nSaldoVin == 0
	                          nSaldoVin := EXPosPrePag("EF3",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,.T.,aArrayEEQ[h,19],IF(lEFFTpMod,EF1->EF1_TPMODU,""),IF(lEFFTpMod,EF1->EF1_SEQCNT,"") )
	                       /*Else
                              EXPosPrePag("EF3",EF1->EF1_CONTRA,EF1->EF1_BAN_FI,EF1->EF1_PRACA,.F.,aArrayEEQ[h,19],IF(lEFFTpMod,EF1->EF1_TPMODU,""),IF(lEFFTpMod,EF1->EF1_SEQCNT,"") )
                              EF3->( DBSkip() )
                              If !EF3->( EoF() )  .And.  ;
                                 EF3->(EF3_FILIAL+IIF(lEFFTpMod,EF3_TPMODU,"")+IIF(lTemChave,EF3_BAN_FI+EF3_PRACA,"")+IIF(lEFFTpMod,EF3_SEQCNT,"")) == ;
                                 EF1->(EF1_FILIAL+IIF(lEFFTpMod,EF1_TPMODU,"")+IIF(lTemChave,EF1_BAN_FI+EF1_PRACA,"")+IIF(lEFFTpMod,EF1_SEQCNT,"")) ;
                                 .And.  EF3->EF3_TX_MOE == 0  ;
                                 .And.  IIF(aArrayEEQ[h,19]=="1",EF3->EF3_CODEVE==EV_PRINC_PREPAG,Left(EF3->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))
                                 nSaldoVin := EF3->EF3_SLDVIN
                              EndIf
	                       EndIf*/

                           If nSaldoVin > 0
                              //Caso o valor a vincular seja maior que o saldo vai vinculando as próximas parcelas
                              If aArrayEEQ[h,1] > nSaldoVin
                                 aCopia := aClone(aArrayEEQ[h])

                                 aAdd(aArrayEEQ,NIL)
                                 aIns(aArrayEEQ,h+1)
                                 aArrayEEQ[h+1] := aClone(aCopia)

                                 aCopia := {}
                                 aArrayEEQ[h+1,1] := aArrayEEQ[h+1,1] - nSaldoVin

                                 aArrayEEQ[h,1] := nSaldoVin
                              EndIf
                           EndIf
                        EndIf
                        // **

                        If !(lPrePag .and. IF(lEFFTpMod,EF1->EF1_CAMTRA == "1",EF1->EF1_TP_FIN $ ("03/04")) .and. nSaldoVin<=0) //HVR 25/04/06 - DE: EF1->EF1_TP_FIN $ ("03/04") .and. nSaldoVin<=0) PARA: .and. (IF EF1->EF1_CAMTRA == "1",.T.,IF EF1->EF1_TP_FIN $ ("03/04")) .and. nSaldoVin<=0) VERIFICAR SE CONTRATO POSSUI PARCELAS DE PAGAMENTO
                           If aArrayEEQ[h,3] == TMP->EEQ_PARC
                              AtuVincEF3(,,,h,@aNfLoteEF3)
                           EndIf
                        ElseIf !lShowMsg
                           EasyHelp(STR0177+Alltrim(EF3->EF3_MOE_IN)+" "+Alltrim(Transf(aArrayEEQ[h,1],AVSX3("EF3_VL_INV",6)))+STR0178+Alltrim(EF3->EF3_INVOIC)+STR0179) //"Um valor de " # " da fatura " # " não foi vinculado pois as parcelas foram esgotadas."
                           lShowMsg := .T.
                        EndIf
                     // ** PLB 16/10/06
                     Else
                        EF3->( DBGoTo(aArrayEEQ[h,16]) )
                        If EF3->EF3_VL_INV != aArrayEEQ[h,1]
                           FAF2AtuFin(h,@aNfLoteEF3)
                        EndIf
                     // **
                     EndIf
                     h++
                  EndDo
                  Do While (nPosLiq:=aScan(aLiquida,{|x| x[1]== TMP->EEQ_PARC })) > 0
                     nRecTmp:= TMP->(RecNo())
                     Processa({|| GeraLiq(aLiquida[nPosLiq,2],aLiquida[nPosLiq,3],.F.,aLiquida[nPosLiq,4])}, STR0283 + " - " + aLiquida[nPosLiq,2]) //"Contratos de financiamento"
                     aDel(aLiquida,nPosLiq)
                     aSize(aLiquida,LEN(aLiquida)-1)

                     //TDF - 23/12/2011 - Reabre a Work TMP
                     If Select("TMP") > 0
                        TMP->(DbCloseArea())
                     EndIf
             
                     Af200AbTmp()
                     TMP->(dbSetOrder(nTmpOrd))
                     TMP->(DBGoTo(nRecTmp))
                     
                     aAdd(aLiqConf,TMP->&(EasyGParam("MV_CPODTJR",,"EEQ_DTCE")))

                  EndDo
               EndIf

               If TMP->EEQ_NROP <> EEQ->EEQ_NROP
                  EEQ->(RecLock("EEQ", .F.))
                  EEQ->EEQ_NROP := TMP->EEQ_NROP
                  EEQ->(MsUnlock())
               EndIf

               // ** Integração com o módulo SIGAFIN
               SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
               SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
               SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
               nRecTmp:= TMP->(RecNo())
               TMP->(DBCloseArea())
               //Inclusão de novos títulos através da manutenção de câmbio
               If Empty(EEQ->EEQ_FINNUM)

                  If IsReceita(EEQ->EEQ_EVENT)
                     //WFS 20/05/2009 - Vide revisão no cabeçalho.
                     If (EEQ->EEQ_TIPO == "A" .And. EasyGParam("MV_AVG0180",, .F.) .And. !Empty(EEQ->EEQ_PGT))
                        If !AvStAction("001") //Inclusão do título de adiantamento no SigaFin
                           lRollBack:= .T.
                        EndIf
                        //Atualiza os títulos no financeiro após a liquidação do título RA
                        If !lRollBack .And. EEQ->EEQ_EVENT == "603"
                           If !AF200AtualTit(aRecPosEmb)
                              lRollBack := .T.
                              Exit
                           EndIf
                        EndIf
                     ElseIf EEQ->EEQ_TIPO <> "A"
                        If !AvStAction("005") //Inclusão de título a receber no SIGAFIN
                           lRollBack := .T.
                           Exit
                        EndIf
                     EndIf

                     If EEQ->EEQ_TIPO == "A"
                        cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(" ", "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))'   //NCF - 04/07/2019

                     //FSM - 03/08/2012
                     ElseIf EEQ->EEQ_TIPO == "P"
                        cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(" ", "E1_PARCELA")+AvKey("NF","E1_TIPO")))'
                     Else
                        cParc := If(EECFlags("TIT_PARCELAS"),'EECGetFinParc(EEQ->EEQ_PARC)','AvKey(" ", "E1_PARCELA")')
                        cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+'+cParc+'+AvKey("NF","E1_TIPO")))'
                     EndIf

                     //TDF - 09/09/11 - Ponto de entrada para manipulação do cSeek
                     If EasyEntryPoint("EECAF200")
                        ExecBlock("EECAF200", .f., .f., "ALTERA_CSEEK_1")
                     Endif

                     If !IsIntEnable("001") .or. (&cSeek)

                        If !Empty(EEQ->EEQ_PGT)

                           If EEQ->EEQ_TIPO <> "A"

                              nValorBaixa:= EEQ->EEQ_EQVL
                              If !AvStAction("004")//Baixa do titulo a receber alterado
                                 lRollBack := .T.
                                 Exit
                              EndIf
                           EndIf

                           //Adiantamento pós-embarque
                           If EEQ->EEQ_TIPO == "A" .And. EasyGParam("MV_AVG0180",,.F.) .And. !Empty(EEC->EEC_DTEMBA)

                              nValorBaixa:= EEQ->EEQ_EQVL
					          dDtBaixa   := EEQ->EEQ_PGT
                              If !AvStAction("008")//Baixa do titulo de adiantamento
                                 lRollBack := .T.
                                 Exit
                              EndIf
                           EndIf
                        EndIf

                     EndIf
                  ElseIf EEQ->EEQ_EVENT $ cDespIntFin //"120/102/103/127/150/129" //Gera contas a pagar para despesas internacionais e comissão a remeter.
                     If EasyGParam("MV_AVG0081",, .F.)
                        If !Empty(EEQ->EEQ_FORN) .And. !Empty(EEQ->EEQ_FOLOJA) .And. !Empty(EEC->EEC_DTEMBA) .And. !Empty(EEQ->EEQ_VCT) .And. !Empty(EEQ->EEQ_VL) .And. (!Empty(SYE->YE_MOE_FIN) .OR. !IsIntEnable("001"))
                           If !AvStAction("010")//Inclusão de título a pagar no SIGAFIN
                              //Break
                              lRollBack := .T.
                              Exit
                           EndIf
                        EndIf
                     Else
                        If lIncTit
                           If !AvStAction("010")//Inclusão de título a pagar no SIGAFIN
                              //Break
                              lRollBack := .T.
                              Exit
                           EndIf
                        EndIf
                     EndIf

                     If !IsIntEnable("001") .OR. SE2->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+AvKey(" ", "E2_PARCELA")+AvKey("NF","E2_TIPO")+EEQ->EEQ_FORN+EEQ->EEQ_FOLOJA))
                        If !Empty(EEQ->EEQ_PGT)
                           If !AvStAction("013")//Baixa do titulo a pagar alterado
                              //Break
                              lRollBack := .T.
                              Exit
                           EndIf
                        EndIf
                     EndIf

                  ElseIf !AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT
                     If lAltTit .and. lIncCAPCCG
                        If !AvStAction("010") //Inclusão de título a pagar no SIGAFIN
                           lRollBack := .T.
                        EndIf
                     EndIf
                  EndIf
               Else
                  If IsReceita(EEQ->EEQ_EVENT) .And. !Empty(EEQ->EEQ_FINNUM)

                     //If Empty(EEQ->EEQ_PGT) .And. !lAlt_Pgt .And. lAltTit //RMD - 03/02/15 - Considera também a baixa por movimento no exterior
                     If (!EasyVerModal("EEQ") .And. Empty(EEQ->EEQ_PGT)) .Or. (EasyVerModal("EEQ") .And. Empty(EEQ->EEQ_DTCE))
                        If !lAlt_Pgt .And. lAltTit
                           If !AvStAction("006")//Alteração de título a receber no SIGAFIN (recria)
                              lRollBack := .T.
                              Exit
                           EndIf
                        EndIf
                     EndIf

                     If EEQ->EEQ_TIPO == "A"
                        cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(" ", "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))'   //NCF - 04/07/2019

                        //FSM - 03/08/2012
                     ElseIf EEQ->EEQ_TIPO == "P"
                        cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(" ", "E1_PARCELA")+AvKey("NF","E1_TIPO")))'
                     Else
                        cParc := If(EECFlags("TIT_PARCELAS"),'EECGetFinParc(EEQ->EEQ_PARC)','AvKey(" ", "E1_PARCELA")')
                        cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+'+cParc+'+AvKey("NF","E1_TIPO")))'
                     EndIf

                     //TDF - 09/09/11 - Ponto de entrada para manipulação do cSeek
                     If EasyEntryPoint("EECAF200")
                        ExecBlock("EECAF200", .f., .f., "ALTERA_CSEEK_2")
                     Endif

                     If lAlt_Pgt .And. (!IsIntEnable("001") .OR. (&cSeek))
                        If !Empty(EEQ->EEQ_PGT) .Or. (lTitExp .And. lModalExt)//LGS-28/08/2014

                           If EEQ->EEQ_TIPO == "A"
                              //Adiantamento pós-embarque
                              If EasyGParam("MV_AVG0180",,.F.) .And. !Empty(EEC->EEC_DTEMBA)
                                 nValorBaixa:= EEQ->EEQ_EQVL
                                 dDtBaixa   := EEQ->EEQ_PGT
                                 If !AvStAction("008")//Baixa do titulo de adiantamento
                                    lRollBack := .T.
                                    Exit
                                 EndIf
                              EndIf
                           Else
                              nValorBaixa:= EEQ->EEQ_EQVL
                              If !AvStAction("004")//Baixa do titulo a receber alterado
                                 //Break
                                 lRollBack := .T.
                                 Exit
                              EndIf
                           EndIf
                        //WFS 27/06/11
                        ElseIf !IsIntEnable("001") .OR. (lSE5Posic := AF201PosicSE5("SE1",dDtBxSE5, nVlrBx) )

                           //WFS 20/05/2009 - Vide revisão no cabeçalho.
                           If EEQ->EEQ_TIPO == "A"
                              If EasyGParam("MV_AVG0180",,.F.)
                                 If !Empty(EEC->EEC_DTEMBA)
                                    If !AvStAction("009") //Estorno do título de adiantamento no SigaFin
                                       lRollBack:= .T.
                                       Exit
                                    EndIf
                                 EndIf
                                 If !AvStAction("002") //Exclusão do título de adiantamento no SigaFin
                                    lRollBack:= .T.
                                    Exit
                                 EndIf

                                 //Atualiza os títulos no financeiro após o estorno da liquidação do título RA
                                 If !lRollBack .And. EEQ->EEQ_EVENT == "603"
                                    If !AF200AtualTit(aRecPosEmb)
                                       lRollBack := .T.
                                       Exit
                                    EndIf
                                 EndIf
                              EndIf
                           ElseIf EEQ->EEQ_TIPO == "R" .and. EEQ->EEQ_EVENT != "603"
                              If !AvStAction("009") //Estorno da baixa do titulo a receber alterado
                                 lRollBack := .T.
                                 Exit
                              EndIf
                           EndIf
                        ElseIf !lSE5Posic
                           lRollBack := .T.
                           EasyHelp(STR0358,STR0016) //"O movimento bancário da liquidação do título não foi localizado." ## "Aviso"
                           Exit                               
                        EndIf
                     EndIf

                     //Armazena registros das parcelas principais para posterior verificação de alteração no valor do
                     //título, para atualização após liquidação do título RA, quando estiver habilitado o tratamento de
                     //adiantamentos pós embarque
                     If EasyGParam("MV_AVG0180",,.F.) .And. EEQ->EEQ_TIPO <> "A" .And. Empty(EEQ->EEQ_PGT)
                        AAdd(aRecPosEmb, EEQ->(RecNo()))
                     EndIf

                  //Altera contas a pagar para despesas internacionais e comissão a remeter. comentado por wfs em 22/09/11
                  ElseIf EEQ->EEQ_EVENT $ cDespIntFin /*"120/102/103/127/150/129"*/ .And. !Empty(EEQ->EEQ_FINNUM)

                     If Empty(EEQ->EEQ_PGT) .And. !lAlt_Pgt .And. lAltTit .And. !AvStAction("011")//Alteração de título a pagar no SIGAFIN
                       //Break
                       lRollBack := .T.
                       Exit
                     EndIf
                     //NCF - 30/09/2013
                     If lAlt_Pgt
                        If SE2->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+AvKey(" ", "E2_PARCELA")+AvKey("NF","E2_TIPO")+EEQ->EEQ_FORN+EEQ->EEQ_FOLOJA))
                           If !Empty(EEQ->EEQ_PGT)
                              If !AvStAction("013")//Baixa do titulo a pagar alterado
                                 //Break
                                 lRollBack := .T.
                                 Exit
                              EndIf

                              //WFS 27/06/11
                              //Procura uma sequência válida
                           ElseIf !IsIntEnable("001") .OR. ( lSE5Posic := AF201PosicSE5("SE2",dDtBxSE5, nVlrBx) )
                              If !AvStAction("014")//Estorno da baixa do titulo a pagar alterado
                                 //Break
                                 lRollBack := .T.
                                 Exit
                              EndIf
                           ElseIf !lSE5Posic
                              lRollBack := .T.                              
                              EasyHelp(STR0358,STR0016) //"O movimento bancário da liquidação do título não foi localizado." ## "Aviso"
                              Exit                               
                           EndIf
                        ElseIf !IsIntEnable("001") .and. IsIntEnable("010") //NCF - 30/09/2013 - Baixa/Estorno da Baixa de títulos via Mensagem Única
                           If AvFlags("ADTFOREAI") .And. (lCompenFor) //THTS - 31/03/2017 - Verifica se foi compensacao com adiantamento de fornecedor//THTS - 31/03/2017 - Verifica se foi compensacao com adiantamento de fornecedor
	                           If !Empty(EEQ->EEQ_PGT)
	                              If !AvStAction("093") //Baixa do titulo a pagar alterado
	                                 lRollBack := .T.
	                                 Exit
	                              EndIf
	                           Else
	                              If !AvStAction("014") //Estorno da Baixa do titulo a pagar alterado
	                                 lRollBack := .T.
	                                 Exit
	                              EndIf
	                           EndIf
                                lCompenFor := .F.
                           Else
	                           If !Empty(EEQ->EEQ_PGT)
	                              If !AvStAction("013") //Baixa do titulo a pagar alterado
	                                 lRollBack := .T.
	                                 Exit
	                              EndIf
	                           Else
	                              If !AvStAction("014") //Estorno da Baixa do titulo a pagar alterado
	                                 lRollBack := .T.
	                                 Exit
	                              EndIf
	                           EndIf
                           EndIf
                        EndIf
                     EndIf
                  ElseIf !AvFlags("EEC_LOGIX") .And. AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. "121" $ EEQ->EEQ_EVENT

                     If lAltTit .And. lExcCAPCCG
                        If !AvStAction("012")//Exclusão de título a pagar no SIGAFIN
                           lRollBack := .T.
                           Exit
                        /*Else
                           lAltTit := .F.*/
                        EndIf
                     EndIF

                     If lAlt_Pgt
                        If SE2->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E2_NUM")+AvKey(" ", "E2_PARCELA")+AvKey("NF","E2_TIPO")+EEQ->EEQ_FORN+EEQ->EEQ_FOLOJA))
                           If !Empty(EEQ->EEQ_PGT)
                              If !AvStAction("013")//Baixa do titulo a pagar alterado
                                 //Break
                                 lRollBack := .T.
                                 Exit
                              EndIf
                              //NCF - 08/03/2016 - Contabilização das comissões em Conta Gráfica                              
                              IF !EasyGParam('MV_EEC_ECO',,.F.) .AND. EasyGParam('MV_EEC0048',,.T.) .And. FindFunction("L50GEVCTRA") .And. FindFunction("L50GEVCCAMB") .AND. "121" $ EEQ->EEQ_EVENT
                                 EasyExRdm("L50GEVCTRA", 'TN') //Contabilização (613 - Pagamento da Comissão)
                                 EasyExRdm("L50GEVCCAMB", 'TN')  //Contabilização (576[+], 577[-] - Variação cambial pós pagamento da Comissão)
                              ENDIF                              
                           //WFS 27/06/11
                           //Procura uma sequência válida
                           ElseIf !IsIntEnable("001") .OR. ( lSE5Posic := AF201PosicSE5("SE2",dDtBxSE5, nVlrBx) )

                              If !AvStAction("014")//Estorno da baixa do titulo a pagar alterado
                                 //Break
                                 lRollBack := .T.
                                 Exit
                              EndIf
                              //NCF - 08/03/2016 - Estorno da contabilização das comissões em Conta Gráfica                              
                              IF !EasyGParam("MV_EEC_ECO",,.F.) .AND. EasyGParam('MV_EEC0048',,.T.) .And. FindFunction("L50ECANCTB") .And. FindFunction("L50ERETREG")
                                 aRegs613:=EasyExRdm("L50ERETREG", xFilial("EEC"),EEC->EEC_PREEMB,"'613'"      ,'TN', EEQ->EEQ_CODEMP+"32"+EEQ->EEQ_PARC )
                                 EasyExRdm("L50ECANCTB", aRegs613)
                                 aRegs57X:= EasyExRdm("L50ERETREG", xFilial("EEC"),EEC->EEC_PREEMB,"'576','577'",'TN', EEQ->EEQ_CODEMP+"32"+EEQ->EEQ_PARC )
                                 EasyExRdm("L50ECANCTB", aRegs57X)
                              ENDIF                              
                           ElseIf !lSE5Posic
                              lRollBack := .T.
                              EasyHelp(STR0358,STR0016) //"O movimento bancário da liquidação do título não foi localizado." ## "Aviso"
                              Exit                               
                           EndIf
                        EndIf
                     EndIf

                  //NCF - 20/11/2014 - //(Baixa/Estorno de baixa) manual da comissão conta gráfica na integração com ERP Externo
                  ElseIf (!IsIntEnable("001") .and. IsIntEnable("010")) .And. !IsReceita(EEQ->EEQ_EVENT) .And. "121" $ EEQ->EEQ_EVENT .And. !Empty(EEQ->EEQ_FINNUM)
                     If !Empty(EEQ->EEQ_PGT)
                        If !AvStAction('013') //("085") //Baixa da comissão conta gráfica //NCF - 14/06/2016
                           lRollBack := .T.
                           Exit
                        EndIf
                        //NCF - 08/03/2016 - Contabilizacao                        
                        IF !EasyGParam('MV_EEC_ECO',,.F.) .AND. EasyGParam('MV_EEC0048',,.F.) .AND. FindFunction("L50GEVCTRA") .AND. FindFunction("L50GEVCCAMB")
                           EasyExRdm("L50GEVCTRA", 'TN')   //Contabilização (613 - Pagamento da Comissão)
                           EasyExRdm("L50GEVCCAMB", 'TN')  //Contabilização (576[+], 577[-] - Variação cambial pós pagamento da Comissão)
                        ENDIF                        
                     Else
                        If !AvStAction('014')//("086") //Estorno da baixa de comissão de conta gráfica //NCF - 14/06/2016
                           lRollBack := .T.
                           Exit
                        EndIf
                        //NCF - 08/03/2016 - Estorno da Contabilizacao                        
                        IF !EasyGParam('MV_EEC_ECO',,.F.) .AND. EasyGParam('MV_EEC0048',,.F.) .AND. FindFunction("L500CANCTB") .And. FindFunction("L50ERETREG")
                           aRegs613:=EasyExRdm("L50ERETREG",xFilial("EEC"),EEC->EEC_PREEMB,"'613'"      ,'TN', EEQ->EEQ_CODEMP+"32"+EEQ->EEQ_PARC )
                           EasyExRdm("L50ECANCTB", aRegs613)
                           aRegs57X:= EasyExRdm("L50ERETREG", xFilial("EEC"),EEC->EEC_PREEMB,"'576','577'",'TN', EEQ->EEQ_CODEMP+"32"+EEQ->EEQ_PARC )
                           EasyExRdm("L50ECANCTB", aRegs57X)
                        ENDIF                        
                     EndIf
                  EndIf
               EndIf

               SE5->(DbSetOrder(1))

               //ALCIR ALVES  - 17-10-05 - CHAMADA A CADA GRAVAÇÃO DEITEM NO EEQ
               //O AVREPLACE NÃO ESTA ATUALIZANDO DETERMINADOS CAMPOS MESMO SENDO REAL E DO USUÁRIO
               //ESTE PONTO PODERÁ FORÇAR A GRAVAÇÃO DESTES SUPOSTOS CAMPOS DESCONSIDERADOS PELO AVREPLACE
               If EasyEntryPoint("EECAF200")
                  ExecBlock("EECAF200", .f., .f., "GRV_ITEM_CAMBIO")
               Endif
               //
               EEQ->(msUnlock())

               //Caso a work seja fechada durante alguma integração, força a reabertura.
               If Select("TMP") > 0
                  TMP->(DbCloseArea())
               EndIf
               
               Af200AbTmp()
               TMP->(dbSetOrder(nTmpOrd))
               TMP->(DBGoTo(nRecTmp))
            
               
               If Avflags("ADTFOREAI") .And. lIncTit
                  TMP->(DBGoTo(nRecTMPInc))
                  If TMP->TRB_REC_WT <> 0 .And. TMP->TMP_RECNO == 0 //NCF - 23/03/2017 - Atualizar o registro da EEQ na work visto que o
                    TMP->TMP_RECNO  := nRegAtuEEQ                  //                   o antigo é cópia da parc. original na quebra.
                    TMP->TRB_REC_WT := nRegAtuEEQ
                  EndIF
                  TMP->(DBGoTo(nRecTmp))
               EndIf
               
               If AvFlags("EEC_LOGIX")
                  TMP->(dbGoTo(nRecOpTmp))
               EndIf
               TMP->(DBSKIP())
            ENDDO

            // *** GFP - 25/04/2011 :: 15:26 - Tratamento de Workflow na rotina de Cambio
            If AvFlags("WORKFLOW")
               EasyGroupWF("CAMBIO_EEC",aChaves)
            EndIf
            // *** Fim GFP

            // PLB 10/08/07
            If !lRollBack

               If !lTodasLiqBase .And. lTodasLiquidadas
                  Af200CtrRen(3) // faz acertos, caso todas as parcelas de invoice tenham sido liquidadas no momento
               EndIf

               If !lNaoHaLiqBase .And. lNaoHaLiquidadas
                  Af200CtrRen(4) // faz acertos, caso todas as parcelas de invoice tenham sido estornadas no momento
               EndIf

               //GFC 14/01/05 - INICIO
               If lFinanciamento .and. aLiquida <> {} .and. FAF2GetProv()
                  nOldOrd := EF3->(IndexOrd())
                  aLiquida := aClone(aLiqAux)
                  TMP->(dbGoTop())
                  Do While !TMP->(EOF())
                     Do While (nPosLiq:=aScan(aLiquida,{|x| x[1]== TMP->EEQ_PARC })) > 0
                        If aLiquida[nPosLiq,2]=="INCLUIR"
                           EF3->(dbSetOrder(3))
                           If EF3->(dbSeek(xFilial("EF3")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)+EV_LIQ_PRC)) .or.;
                           EF3->(dbSeek(xFilial("EF3")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)+EV_LIQ_PRC_FC))
                              Do While !EF3->(EOF()) .and. EF3->EF3_FILIAL==xFilial("EF3") .and. EF3->EF3_INVOIC==TMP->EEQ_NRINVO .and.;
                              EF3->EF3_PARC==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN) .and.;
                              (EF3->EF3_CODEVE==EV_LIQ_PRC .or. EF3->EF3_CODEVE==EV_LIQ_PRC_FC)
                                 If aScan(aGetProv,{|x| x[10] = EF3->(RecNo())}) > 0
                                    FAF2EstLiq(EF3->EF3_CONTRA,EF3->EF3_SEQ,If(lTemChave,EF3->EF3_BAN_FI,),If(lTemChave,EF3->EF3_PRACA,),.F.,If(lEFFTpMod,EF3->EF3_SEQCNT,""))
                                 EndIf
                                 EF3->(dbSkip())
                              EndDo
                              GeraLiq(aLiquida[nPosLiq,2],aLiquida[nPosLiq,3],.T.,aLiquida[nPosLiq,4])
                           EndIf
                        EndIf
                        aDel(aLiquida,nPosLiq)
                        aSize(aLiquida,LEN(aLiquida)-1)
                     EndDo
                     TMP->(dbSkip())
                  EndDo
                  aGetProv := {}
                  EF3->(dbSetOrder(nOldOrd))
               EndIf
               //GFC 14/01/05 - FIM

               //ALCIR ALVES
               If EasyEntryPoint("EECAF200")
                  ExecBlock("EECAF200", .f., .f., "INC_CAMBIO")
               Endif

               If lFinanciamento
                  EF2->(dbSetOrder(2))
                  For z:=1 To Len(aExcVinculo)
                      If aExcVinculo[z,3] = 1
                         AtuVincEF3("EXCLUIR",z)
                      EndIf
                  Next

                  EF3->(dbSetOrder(1))
                  EF2->(dbSetOrder(1))

                  // ** GFC 31/01/06 - Gravação da Repactuação
                  If lEF2_INVOIC //AAF 01/05/2006 - Verificar o Flag lEF2_INVOIC.
                     FAF2GrvRep()
                  EndIf
                  // **
               EndIf

               // Estorno para a contabilidade
               If lIntCont
                  If lOkEstor .And. lContEst
                     AF200EstCtb(aEstornaECF, aIncluiECF)
                  Endif
               Endif

               // ** AAF 03/02/05 - Gravação do Demurrage.
               If Len(aDemurrage) > 0
                  DM100GrvDem()
               Endif
               // **
            Else


               //DFS - 06/10/12 - Chamada da função para salvar as integrações no LogViewer
               ELinkRollBackTran()
            EndIf

         Else


            //DFS - 06/10/12 - Chamada da função para salvar as integrações no LogViewer
            ELinkRollBackTran()
         EndIf

      End Transaction
      // PLB 10/08/07
      If lRollBack 
         EasyElinkError("FIN", !(lExecAuto .Or. (IsMemVar("lEEQAuto") .And. lEEQAuto)))
      EndIf


      ELinkClearID()  // GFP - 20/08/2012

      //EasyEAIOrd("EECAF221",5,"EEQ","EEQ_SEQBX")

      If !EasyEAIBuffer("FIM",bOnError)
         AF200RevFin()
      EndIf

      /* WFS set-2016 - execução da liquidação do evento principal.
         Migrado para fora da transação, para abertura de tela.
         Objetivos: possibilitar ao usuário informar os dados para liquidação do evento e
         executar a tela fora da transação.
         A flag lLiqAutoFinancing será alterada para verdadeiro quando o evento principal (700) for totalmente liquidado. */
      If lFinanciamento
         If EasyGParam("MV_LIQAUTO",, .F.) .And. lLiqAutoFinancing

            //Variáveis privadas utilizadas no EFFEX400 e EFFEX401
            Private aGetProv := {}  ,;
                    lInverte := .F. ,;
                    cMod     := "E" ,;
                    cTX_100  := ""  ,;
                    cTX_520  := ""

            Processa({|| AF201SelLiq(aLiqAuto)}, "Integração Easy Financing", "Liquidação do Financiamento.")
         EndIf
      EndIf

      lGrvMntCmb := !lRollback

      //THTS - 27/04/2017 - Atualiza a TMP com as informações atualizadas da EEQ
      If Avflags("ADTFOREAI")
        aOrdAdt := SaveOrd({"TMP","EEQ"})
        TMP->(dbGoTop())
        While !TMP->(Eof())
            EEQ->(DbGoTo(TMP->TRB_REC_WT))
            AvReplace("EEQ","TMP")
            TMP->(dbSkip())
        End
        RestOrd(aOrdAdt,.T.)
      EndIf    

Return lGrvMntCmb



/*
Funcao     : GrvDetMan(nBClick,nTipo)
Parametros : nBClick (1=SALVAR; 2=CANCELAR)
             nTipo (Código numérico do tipo de manutenção na parcela)
Retorno    : lRet (.T.=Validado, .F.=Não Validado)
Objetivo   : Migrada toda a gravação feitas após clicar no OK da tela de manutenção da parcela
             sem nenhum prejuízo de código, visando possibilitar o disparo da gravação direta
             em outros pontos da manutenção.
Autor      : Nilson Cesar
Data/Hora  : 23/03/2017
*/
STATIC FUNCTION GrvDetMan(nBClick,nTipo)

Local nBClick
Local cALIAS := ALIAS()
Local nRecTmp := 0
Local aVinc:={}, nx, ni, nVlVincPar:=0, nSaldo:=0, nIncPos:=0, nPosSaldo  := 0
Local nValCamb := 0, nValVinc := 0, nValDesc := 0
Local lRet := .T.
Local lZeraDesco := .F.

      // ACSJ - Caetano - 26/01/2005
      If M->EEQ_EVENT == "801" .or. M->EEQ_EVENT == "802" .and. nBClick = 1 
         nEEQRec := EEQ->(RecNo())
         nEEQInd := EEQ->(IndexOrd())

         nValCamb := 0
         nValVinc := 0
         nValDesc := 0

         EEQ->(DBSetOrder(1))
         If EEQ->(DBSeek(EEC->EEC_FILIAL + EEC->EEC_PREEMB))
            Do While .not. EEQ->(EoF()) .and. EEQ->EEQ_FILIAL == EEC->EEC_FILIAL .and.;
               EEQ->EEQ_PREEMB == EEC->EEC_PREEMB

               If EEQ->EEQ_EVENT == "101"
                  nValCamb += EEQ->EEQ_VL
                  nValVinc += EEQ->EEQ_VL_PAR
               Elseif EEQ->EEQ_EVENT = "801" .or. EEQ->EEQ_EVENT = "802"
                  nValDesc += EEQ->EEQ_VL
               Endif

               EEQ->(DBSKIP())

            Enddo

            If nValCamb == nValVinc .or. ( nValCamb - (nValVinc+nValDesc+M->EEQ_VL) < 0 )
               if M->EEQ_EVENT == "801"
                  cTxt := STR0163 //"o desconto"
               else
                  cTxt := STR0164 //"a devolução"
               Endif
               nBClick = 0
               EasyHelp( STR0161 + cTxt + STR0162) // STR0161 "Evento não pode ser lançado pois "
                                                  // STR0162 " é maior que o saldo"
            Endif
         Endif
         EEQ->(DBSetOrder(nEEQInd))
         EEQ->(DBGoTo(nEEQRec))
      Endif
      // ---------------------------

      IF nBClick = 1

         lLoop := .F.
         IF EasyEntryPoint("EECPFN03")
            ExecBlock("EECPFN03",.F.,.F.,nP_OPC)
         Endif
         If lLoop
            //Loop
            lRet := .F.
            aGets := {}
            aTela := {}
            Return lRet
         EndIf

         // ** GFC - 27/01/06
         If lFinanciamento .and. nTipo == LIQ_DET
            lLoop := .F.
            EF3->(dbSetOrder(3))
            If EF3->(dbSeek(xFilial("EF3")+M->EEQ_NRINVO+If(!lParFin .Or. Empty(M->EEQ_PARFIN),M->EEQ_PARC,M->EEQ_PARFIN)+EV_EMBARQUE))
               Do While !EF3->(EOF()) .and. xFilial("EF3")==EF3->EF3_FILIAL .and. EF3->EF3_INVOIC==M->EEQ_NRINVO .and.;
               EF3->EF3_PARC==If(!lParFin .Or. Empty(M->EEQ_PARFIN), M->EEQ_PARC, M->EEQ_PARFIN) .and.;
               EF3->EF3_CODEVE == EV_EMBARQUE
                  If M->EEQ_PGT < EF3->EF3_DT_EVE
                     EasyHelp(STR0214+" ("+DtoC(EF3->EF3_DT_EVE)+").") //"A Data de Liquidação não pode ser menor que a Data de Vinculação"
                     lLoop := .T.
                     Exit
                  EndIf
                  EF3->(dbSkip())
               EndDo
            EndIf
            If lLoop
               aGets := {}
               aTela := {}
               //Loop
               lRet := .F.
               Return lRet
            EndIf
         EndIf
         // **
         //THTS - 17/05/2019 - Ao estornar uma parcela que possua o campo EEQ_DESCON com algum valor, informar que a parcela possui desconto e este será mantido na parcela.
         If (!IsMemVar("lExecAuto") .Or. !lExecAuto) .And. nTipo == ELQ_DET .And. !Empty(TMP->EEQ_DESCON)
             If !MsgYesNo(STR0336+ENTER+; //"Esta parcela de câmbio possui Desconto."
                          STR0337,STR0016)//"Após finalizar o Estorno, deseja manter o valor de desconto para a parcela?" ##Aviso
                lZeraDesco := .T.
             EndIf
         EndIf
         //JPM - 30/12/04
         If lNRotinaLC .And. M->EEQ_EVENT == "101" .And. (nTipo == LIQ_DET .Or. nTipo == ELQ_DET)

            If !EECFlags("ITENS_LC")

               If !Empty(EEC->EEC_LC_NUM) .And. Posicione("EEL",1,xFilial("EEL")+EEC->EEC_LC_NUM,"EEL_RENOVA") == "1"

                  nVal := EECCalcTaxa(EEC->EEC_MOEDA,EEL->EEL_MOEDA,M->EEQ_VL,2)

                  If nTipo == LIQ_DET

                     AAdd(aRestSaldo,{M->EEQ_FILIAL+M->EEQ_PREEMB+M->EEQ_PARC,nVal,"R"})

                  ElseIf nTipo == ELQ_DET

                     AAdd(aRestSaldo,{M->EEQ_FILIAL+M->EEQ_PREEMB+M->EEQ_PARC,nVal,"A"})

                  Endif

               EndIf
            EndIf
         EndIf
         //JPM - Fim

         // ** Tratamentos para inclusão/alteração de descontos.
         If nTipo == INC_DET
            If EECFlags("FRESEGCOM")
               If Left(M->EEQ_EVENT,1) = "8"
                  Af201AddDiscount(M->EEQ_EVENT,nTipo)
               EndIf
            EndIf
         EndIf

         If nTipo == INC_DET
            If lIntCont
               If lOkEstor .And. lContEst .And. !Empty(M->EEQ_NR_CON)
                  //AAdd(aIncluiECF, {M->EEQ_PREEMB, M->EEQ_FASE, M->EEQ_NRINVOIC, If(!lParFin .Or. Empty(M->EEQ_PARFIN), M->EEQ_PARC, M->EEQ_PARFIN), M->EEQ_EVENT, M->EEQ_TX, M->EEQ_PGT } )
                  // PLB 23/08/07
                  AAdd(aIncluiECF, {M->EEQ_PREEMB, M->EEQ_FASE, M->EEQ_NRINVOIC, M->EEQ_PARC, M->EEQ_EVENT, M->EEQ_TX, M->EEQ_PGT } )
               Endif
            Endif
            TMP->(RecLock("TMP",.T.))
         EndIf

//         If lFinanciamento .and. nTipo == ALT_DET .and. M->EEQ_VL <> TMP->EEQ_VL  // ** Comentado por GFC
//            If (nPos := aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)})) > 0
//               If Empty(aArrayEEQ[nPos,5]) .or. Len(aArrayEEQ)=1 .or.;
//               (Len(aArrayEEQ) > nPos .and. aArrayEEQ[nPos+1,3]<>aArrayEEQ[nPos,3])
//                  aArrayEEQ[nPos,1] := M->EEQ_VL
//               EndIf
//            EndIf
//         EndIf

         // JPM - 06/03/06 - Recalcular valor de fechamento cambial.
         Af201SetVlFCam()

         If EasyEntryPoint("EECAF200")
            ExecBlock("EECAF200", .f., .f., {"ANTES_GRV_TMP",nTipo})
         EndIf

         AvReplace("M","TMP")

         //THTS - 20/04/2017 - Trata a parcela atual para gerar um novo titulo quando integrado ao Logix via EECAF520
         if !IsReceita(TMP->EEQ_EVENT)
                
            If  AvFlags("ADTFOREAI") .And. EEQ->(FieldPos("EEQ_EAIVRS")) > 0 
               EEQ->(DBGoTo(TMP->TMP_RECNO))
               If EEQ->EEQ_EAIVRS == "2" .And. EEQ->EEQ_VL <> TMP->EEQ_VL
                  if aScan(aDeletados,TMP->TMP_RECNO) = 0
                     aAdd(aDeletados,TMP->TMP_RECNO)
                  EndIf   
                  If !TMP->(IsLocked())
                     TMP->(RecLock("TMP", .F.))
                     TMP->TMP_RECNO := 0 //Gera uma nova parcela na EEQ.
                     TMP->EEQ_FINNUM:= ""//Gera um novo titulo
                     TMP->(MsUnlock())
                  Else
                     TMP->TMP_RECNO := 0 //Gera uma nova parcela na EEQ.
                     TMP->EEQ_FINNUM:= ""//Gera um novo titulo
                  EndIf
               EndIf
            EndIf
         EndIf

         If lFinanciamento
            If lIntCont
               If lOkEstor .And. lContEst
                  If nTipo == LIQ_DET // Liquidaçao
                     //AAdd(aIncluiECF, {TMP->EEQ_PREEMB, TMP->EEQ_FASE, TMP->EEQ_NRINVOIC, If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN), TMP->EEQ_EVENT, TMP->EEQ_TX, TMP->EEQ_PGT } )
                     // PLB 23/08/07
                     AAdd(aIncluiECF, {TMP->EEQ_PREEMB, TMP->EEQ_FASE, TMP->EEQ_NRINVOIC, TMP->EEQ_PARC, TMP->EEQ_EVENT, TMP->EEQ_TX, TMP->EEQ_PGT } )

                  Elseif nTipo == ELQ_DET  // Estorno da Liquidação
                     If !Empty(TMP->EEQ_NR_CON)
                        //AAdd(aEstornaECF, {TMP->EEQ_PREEMB, TMP->EEQ_FASE, TMP->EEQ_NRINVOIC, If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN), TMP->EEQ_EVENT } )
                        // PLB 23/08/07
                        AAdd(aEstornaECF, {TMP->EEQ_PREEMB, TMP->EEQ_FASE, TMP->EEQ_NRINVOIC, TMP->EEQ_PARC, TMP->EEQ_EVENT } )
                     Endif
                  Endif
               Endif
            Endif

            If nTipo == ALT_DET //.and. M->EEQ_VL <> TMP->EEQ_VL
               // ** GFC - 11/08/05 - Reorganiza o Array de controle de vinculações
               //Congela as vinculações não confirmadas
               EF3->(dbSetOrder(3))
               For nx:=1 to Len(aArrayEEQ)
                  If !Empty(aArrayEEQ[nx,5]) .and. Empty(aArrayEEQ[nx,16])
                     aAdd(aVinc,aArrayEEQ[nx])
                  EndIf
               Next nx

               //Grava novamente o Array de vinculações
               nRecTmp  := TMP->(Recno())
               aArrayEEQ := {}
               nSeqArray := 1
               TMP->(dbGoTop())
               Do While !TMP->(EOF())
                  GrvArrayFAF2()
                  TMP->(dbSkip())
               EndDo
               nIncPos := 0
               //nx      := 1
               //Do While nx <= Len(aVinc)
               For nx := 1  to  Len(aVinc)
                  If (nPos:=aScan(aArrayEEQ,{|x| x[3]==aVinc[nx,3]})) > 0 .and. aVinc[nx,1] > 0
                     nSaldo     := 0
                     nVlVincPar := 0
                     nPosSaldo  := 0
                     For ni:=nPos to Len(aArrayEEQ)
                        If aArrayEEQ[ni,3] == aVinc[nx,3]
                           If !Empty(aArrayEEQ[ni,5])
                              nVlVincPar += aArrayEEQ[ni,1]
                           Else
                              nSaldo    := aArrayEEQ[ni,1]
                              nPosSaldo := ni
                           EndIf
                        EndIf
                     Next ni
                     If nPosSaldo > 0
                        TMP->(dbGoTo(aArrayEEQ[nPosSaldo,20]))

                        aAdd(aArrayEEQ,aClone(aVinc[nx]))
                        If nSaldo >= aVinc[nx,1]
                           If nSaldo = aVinc[nx,1]
                              aDel(aArrayEEQ,nPosSaldo)
                              aSize(aArrayEEQ,Len(aArrayEEQ)-1)
                              nSeqArray := FAF200BusSeq() //AOM - 03/08/2010 - indica a sequencia correta do vetro aArrayEEQ
                           Else
                              aArrayEEQ[nPosSaldo,1]  -= aVinc[nx,1]
                              aArrayEEQ[nPosSaldo,17] -= aVinc[nx,1]
                           EndIf

                           aArrayEEQ[Len(aArrayEEQ),3]  := TMP->EEQ_PARC
                           aArrayEEQ[Len(aArrayEEQ),8]  := nSeqArray
                           aArrayEEQ[Len(aArrayEEQ),12] := ""
                           aArrayEEQ[Len(aArrayEEQ),13] := TMP->EEQ_PARFIN
                           aArrayEEQ[Len(aArrayEEQ),20] := TMP->(RecNo())

                           //nSeqArray   += 1 - NOPADO - AOM - 03/08/10 - a Função FAF200BusSeq já efetua o tratamento
                           //nx          += 1
                        Else
                           aDel(aArrayEEQ,nPosSaldo)
                           aSize(aArrayEEQ,Len(aArrayEEQ)-1)

                           aArrayEEQ[Len(aArrayEEQ),1]  := nSaldo
                           aArrayEEQ[Len(aArrayEEQ),3]  := TMP->EEQ_PARC
                           aArrayEEQ[Len(aArrayEEQ),8]  := nSeqArray-1
                           aArrayEEQ[Len(aArrayEEQ),12] := ""
                           aArrayEEQ[Len(aArrayEEQ),13] := TMP->EEQ_PARFIN
                           aArrayEEQ[Len(aArrayEEQ),17] := nSaldo
                           aArrayEEQ[Len(aArrayEEQ),20] := TMP->(RecNo())

                           aVinc[nx,1] -= nSaldo
                           aVinc[nx,3] := StrZero(Val(aVinc[nx,3])+1,Len(EEQ->EEQ_PARC))
                        EndIf
                     Else
                        aVinc[nx,3] := StrZero(Val(aVinc[nx,3])+1,Len(EEQ->EEQ_PARC))
                     EndIf
                  EndIf
               //EndDo
               Next nx
               aVinc := {}
               EF3->(dbSetOrder(1))
               TMP->(dbGoTo(nRecTmp))
               // **
            Else
               //nPos := aScan(aArrayEEQ,{|x| x[3]==If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN)})   // Verifica se a parcela esta vinculada
               // PLB 23/08/07
               nPos := aScan(aArrayEEQ,{|x| x[3] == TMP->EEQ_PARC })
               EF3->(dbSetOrder(3))
               If EF3->(dbSeek(xFilial("EF3")+TMP->EEQ_NRINVO+If(!lParFin .Or. Empty(TMP->EEQ_PARFIN), TMP->EEQ_PARC, TMP->EEQ_PARFIN))) .Or. ;
               If(nPos > 0, !Empty(aArrayEEQ[nPos,5]), .F.)
                  If nTipo == LIQ_DET
                     aAdd(aLiquida,{TMP->EEQ_PARC,"INCLUIR",TMP->EEQ_TX,})
                  ElseIf nTipo == ELQ_DET
                     aAdd(aLiquida,{TMP->EEQ_PARC,"ESTORNAR",,aArrayEEQ[nPos,1]/*-(TMP->EEQ_CGRAFI+TMP->EEQ_ADEDUZ)*/})  // PLB 15/09/06 - A comissao ja foi deduzida no aArrayEEQ
                  EndIf
               EndIf
            Endif
         EndIf

         // Grava a parcela de Origem da vinculação
         //If lParVin .And. Empty(TMP->EEQ_ORIGEM)
         If Empty(TMP->EEQ_ORIGEM)
            TMP->EEQ_PARVIN := TMP->EEQ_PARC
            TMP->TMP_PARC   := TMP->EEQ_PARVIN
         EndIf

         // Grava a parcela de Origem do FINANCIAMENTO
//         If lParFin .and. lFinanciamento   // ** Comentado por GFC
//            IF !EF3->(EOF())
//               TMP->EEQ_PARFIN := EF3->EF3_PARC
//            Endif
//         EndIf

         If lFinanciamento
            EF3->(dbSetOrder(1))
         Endif

         If nTipo == ELQ_DET
            //TMP->EEQ_DTCE   := AVCTOD("")  // By JPP - 18/10/2006 - 15:18 - Não apagar a data de crédito no exterior quando a parcela de câmbio for estornada.
            TMP->EEQ_PGT    := AVCTOD("")
            TMP->EEQ_DTNEGO := AVCTOD("")
            //TMP->EEQ_NROP   := "" // MCF - 02/06/2016 - Não apagar o Nro de Operação quando a parcela de câmbio for estornada.
            TMP->EEQ_TX     := 0
            TMP->EEQ_EQVL   := 0
            If lZeraDesco
                TMP->EEQ_DESCON := 0 //LRS - 26/07/2017
            EndIf
            If AVFLAGS("CAMBIO_EXP_MOV_EXT") .And. EasyVerModal("TMP") .And. !IsReceita( TMP->EEQ_EVENT )
               TMP->EEQ_DTCE   := AVCTOD("")
               TMP->EEQ_VLMBCO := 0
            EndIf
         EndIf

         If EECFlags("FRESEGCOM")
            If (nTipo == INC_DET)
               If IsReceita(M->EEQ_EVENT)
                  EEC->(DbSetOrder(1))
                  If EEC->(DbSeek(xFilial("EEC")+M->EEQ_PREEMB))
                     TMP->EEQ_IMPORT := EEC->EEC_IMPORT
                     TMP->EEQ_IMLOJA := EEC->EEC_IMLOJA
                  EndIf
               EndIf
            EndIf
         EndIf

         TMP->EEQ_VLFCAM := AF200VLFCAM("TMP",If(nTipoDet == LIQ_DET,"LIQ","ALT"))         
		   If Empty(TMP->EEQ_TP_CON)
            TMP->EEQ_TP_CON := "1" //Cambio Exportação
         EndIf
         AF200STATUS()

         AF200STATUS()
      EndIf

Return lRet


/*
Funcao     : AF200AdtFor()
Parametros : 
Retorno    : 
Autor      : Tiago Henrique Tudisco dos Santos THTS
Data/Hora  : 24/03/2017
*/
Function AF200AdtFor()

Local lRet			:= .F.
Local aFil			:= {}
Local cFil			:= ""
Local nI			:= 0
Local cQuery		:= ""
Local aIndice		:= {"EEQ_FILIAL+EEQ_PREEMB+EEQ_EVENT+EEQ_FASE+EEQ_FORN+EEQ_FOLOJA+EEQ_PARC"}
Local aColunas	:= {}
Local aStruct		:= {}
Local aCampos		:= {"EEQ_FILIAL","EEQ_PREEMB","EEQ_FASE","EEQ_PROR","EEQ_FAOR","EEQ_PAOR","EEQ_DTCE","EEQ_SOL","EEQ_DTNEGO","EEQ_NROP","R_E_C_N_O_","DELETE"}//Campos que nao serao exibidos na tela
Local oDlgAdtFor
Local oBrowseAdt
Local oColumn
Local bOk	        := {|| IF(AF200VLADF("bOK"),(AF200GrvAd(),lRet:= .T.,oDlg:End()),nil)}
Local bCancel       := {|| lRet:= .F., oDlg:End()}
Local aOrdEEQ       := SaveOrd({"EEQ"})
Local cTitOdlg      := ""
Local cTitTela      := "Associação de Adiantamentos"

Begin Sequence

If AF200VLADF("VINCULADO") .and. AF200VLADF("DTCE") .and. AF200VLADF("SOL") // AF200VLADF("TIPO") .And.  - MPG - 26/06/2018 - associação de adiantemntos a clientes não valida mais só a pagar

	aFil := AvgSelectFil(,"EEQ");

	If Len(aFil) > 0
		For nI:= 1 To len(aFil)
			cFil += "'"+aFil[nI]+"'"
			If nI < Len(aFil)
				cFil += ","
			EndIF
		Next
	
		cQuery := AF200QryAdt(cFil,TMP->EEQ_TIPO)//Monta a query para exibicao na FwBrowse
		EasyWkQuery(cQuery,"TMPADT", aIndice)
		
		Define MsDialog oDlg Title cTitTela From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM, DLG_COL_FIM Of oMainWnd Pixel // STR0294 - "Pagamentos ao fornecedor" -- Associação de Adiantamentos
	
            oBrowseAdt:= FWBrowse():New(oDlg)
                
                If TMP->EEQ_TIPO $ "P|L"
                    cTitOdlg := cTitTela + " - " + Alltrim(GetAdvFVal( "SA2" , "A2_NOME" , XFilial("SA2")+TMP->EEQ_FORN+TMP->EEQ_FOLOJA , 1 ))
                ElseIf TMP->EEQ_TIPO $ "R"
                    cTitOdlg := cTitTela + " - " + Alltrim(GetAdvFVal( "SA1" , "A1_NOME" , XFilial("SA1")+TMP->EEQ_IMPORT+TMP->EEQ_IMLOJA , 1 ))
                EndIf

                oBrowseAdt:SetDescription( cTitOdlg +;
                                            STR0296 + Alltrim(TMP->EEQ_MOEDA) + " " + Alltrim(cValToChar(TMP->EEQ_VL))) //" / Valor - "
                oBrowseAdt:SetDataTable()
                oBrowseAdt:SetAlias( "TMPADT" )
                
                aStruct := ("TMPADT")->(dbStruct())
                aColunas := {}
                For nI := 1 To Len(aStruct)
                    
                    If !(aScan(aCampos,{|x| x == aStruct[nI,1]}) > 0)
                    
                        oColumn := FWBrwColumn():New()
                
                        oColumn:SetType(AvSX3(aStruct[nI,1])[2])
                        oColumn:SetTitle(Alltrim(RetTitle(aStruct[nI,1])))
                        oColumn:SetSize(aStruct[nI,3])
                        oColumn:SetDecimal(aStruct[nI,4])
                        oColumn:SetPicture(AvSX3( aStruct[nI][1], 6, "TMPADT" ))
                
                        If AvSX3(aStruct[nI,1])[2] == "D"
                            oColumn:SetData(&('{ || DToC(' + ("TMPADT")->(aStruct[nI,1]) + ') }'))
                        Else
                            oColumn:SetData(&('{ || ' + ("TMPADT")->(aStruct[nI,1]) + ' }'))
                        EndIf
                        aAdd(aColunas,oColumn)
                        
                    EndIf
            
                Next nI
            
            oBrowseAdt:SetColumns(aColunas)
            oBrowseAdt:Activate()
            oBrowseAdt:Refresh()
	
		Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))
		
		("TMPADT")->(dbCloseArea())
		RestOrd(aOrdEEQ,.T.)
	EndIf
EndIf

End Sequence

Return


/*
Funcao     : AF200VLADF()
Parametros : 
Retorno    : Retorno da validacao
Autor      : Tiago Henrique Tudisco dos Santos THTS
Data/Hora  : 27/03/2017
*/
Static Function AF200VLADF(cValida)

Local lRet      := .T.
Local cEventTMP := ""
Local cTipo     := ""

Do Case
	Case cValida == "bOK"
		If TMP->EEQ_VL > ("TMPADT")->(EEQ_SALDO)
			lRet := .F.
			EasyHelp(STR0297) //"Não há saldo no adiantamento. Quebre a parcela de câmbio em um valor menor para vincular o adiantamento."
		EndIf

		If lRet 
			lRet := MsgYesNo(STR0298,STR0299) //"Confirma a vinculação do adiantamento?"###"Adiantamento a Fornecedor"
		EndIf

    Case cValida == "SOL"
        If ! Empty(TMP->EEQ_SOL)
            lRet := .F.
            EasyHelp(STR0338) //"Não é possível associar uma parcela que já tenha data de solicitação de câmbio preenchida!"
        EndIf

    Case cValida == "DTCE"
        If ! Empty(TMP->EEQ_DTCE)
            lRet := .F.
            EasyHelp(STR0339) //"Não é possível associar uma parcela que já tenha data de crédito no exterior preenchida!"
        EndIf

//	Case cValida == "TIPO"  /// MPG - 26/06/2018 assovciação de adiantamento para clientes não valida mais se é apenas a pagar
//		If !(TMP->EEQ_TIPO $ "P|L")
//			lRet := .F.
//			EasyHelp(STR0300)//"Só é possível executar a opção 'Pagamentos ao fornecedor' para câmbios do tipo a pagar."
//		EndIf
		
	Case cValida == "VINCULADO"
		If !Empty(TMP->EEQ_PROR) .And. !Empty(TMP->EEQ_FAOR) .And. !Empty(TMP->EEQ_PAOR)
			lRet := .F.
			If MsgYesNo(STR0301 +ENTER+; //"Esta parcela já possui adiantamento vinculado."
					  STR0302,"Associação de Adiantamento") //" STR0299 Deseja estornar a compensação do adiantamento?"###"Adiantamento a Fornecedor"
                
                If TMP->EEQ_TIPO $ "L"
                    cTipo := "P"
                    lAdtForVin	:= .F.
                    lAdtForEst	:= .T.
                    lCompenFor	:= .T.

                ElseIf TMP->EEQ_TIPO $ "A"
                    cTipo := "R"
                    lAdtCliVin	:= .F.
                    lAdtCliEst	:= .T.
                    lAdtForBkp  := .F.
                EndIf

                //estornar parcela
				TMP->(Reclock("TMP",.F.))
				TMP->EEQ_PROR 	:= ""
				TMP->EEQ_FAOR 	:= ""
				TMP->EEQ_PAOR 	:= ""
				TMP->EEQ_PGT	:= cToD("")
                TMP->EEQ_SOL	:= cToD("")
                TMP->EEQ_DTCE	:= cToD("")
				TMP->EEQ_TX		:= 0
				TMP->EEQ_EQVL	:= 0
				TMP->EEQ_TIPO	:= cTipo
				TMP->(MsUnlock())
				
				nRecAdtFor	:= TMP->(Recno())
				
				//Efetiva a gravacao no banco
				GrvAF200Mn()
				
				TMP->(dbGoTo(nRecAdtFor))
				EEQ->(DbGoTo(TMP->TRB_REC_WT))
                If EEQ->EEQ_EVENT == "603" .AND. EEQ->EEQ_TIPO == "R"
                    EEQ->(RecLock("EEQ",.F.))
                    EEQ->EEQ_EVENT := "101"
                    EEQ->(msunlock())
                EndIf

				AvReplace("EEQ","TMP")

				nRecAdtFor	:= 0
                lAdtCliEst	:= .F.
				lAdtForVin	:= .F.
				lAdtForEst	:= .F.
			EndIf
		EndIf
		
		If lRet .And. !Empty(TMP->EEQ_PGT)
			lRet := .F.
			EasyHelp(STR0077+Transf(Tmp->EEQ_PGT,"  /  /    ")+"." + ENTER+; //"Esta parcela foi liquidada em : "
					 STR0303,STR0014) //###"Atenção"###"Para vincular um adiantamento, primeiro deve ser feito o estorno da liquidação."
		EndIf
		
EndCase

Return lRet

/*
Funcao     : AF200QryAdt()
Parametros : cFil - filiais selecionadas por Multi Filiais
Retorno    : Query para montar o browse de adiantamento de fornecedores
Autor      : Tiago Henrique Tudisco dos Santos THTS
Data/Hora  : 24/03/2017
*/
Static Function AF200QryAdt(cFil,cTipo)

Local cRet := ""

cRet := " SELECT EEQ_FILIAL,EEQ_PREEMB,EEQ_EVENT,EEQ_NRINVO,EEQ_PARC,EEQ_EMISSA,EEQ_VCT,EEQ_MOEDA,EEQ_VL,EEQ_SALDO,EEQ_PGT,EEQ_TX,EEQ_EQVL,EEQ_FORN,EEQ_FOLOJA,EEQ_BANC,EEQ_AGEN,EEQ_NCON,EEQ_NOMEBC,EEQ_PROR,EEQ_FAOR,EEQ_PAOR,EEQ_DTCE,EEQ_SOL,EEQ_DTNEGO,EEQ_FASE,EEQ_NROP,EEQ_FINNUM,R_E_C_N_O_" 
cRet += " FROM " + RetSQLName("EEQ") + " EEQ "
cRet += " WHERE EEQ_FILIAL	IN (" + cFil + ") "

if cTipo $ "P|L" // MPG - 26/06/2018 - implementado associação de adiantamento para clientes

    cRet += "  AND EEQ_FASE		= 'F' "
    cRet += "  AND EEQ_PREEMB	= '" + TMP->EEQ_FORN 	+"' "
    cRet += "  AND EEQ_EVENT	= '609' "
    cRet += "  AND EEQ_FORN		= '" + TMP->EEQ_FORN 	+ "' "
    cRet += "  AND EEQ_FOLOJA	= '" + TMP->EEQ_FOLOJA	+ "' "
    cRet += "  AND EEQ_TIPO		= 'A' "
    cRet += "  AND EEQ_SALDO	> 0 "
    cRet += "  AND EEQ_PGT		!= ' ' "
    cRet += "  AND EEQ_TX		> 0 "
    cRet += "  AND EEQ_MOEDA	= '" + TMP->EEQ_MOEDA + "' "

Elseif cTipo $ "R"

    cRet += "  AND EEQ_TIPO		= 'A' "
    cRet += "  AND EEQ_SALDO	> 0 "
    cRet += "  AND EEQ_TX		> 0 "
    cRet += "  AND EEQ_PGT		!= ' ' "
    cRet += "  AND EEQ_MOEDA	= '" + TMP->EEQ_MOEDA + "' "
    cRet += "  AND ((EEQ_FASE = 'C' AND EEQ_IMPORT+EEQ_IMLOJA = '" + TMP->EEQ_IMPORT + TMP->EEQ_IMLOJA + "' )
    cRet += "  OR  ( EEQ_FASE = 'P' AND EEQ_PREEMB IN (SELECT EE9_PEDIDO FROM " + RetSQLName("EE9") + " WHERE EE9_FILIAL = '" + TMP->EEQ_FILIAL + "' AND EE9_PREEMB = '" + TMP->EEQ_PREEMB + "')))

Endif

cRet += iIF( TcSrvType()=="AS/400"," AND EEQ.@DELETED@ <> '*' "," AND EEQ.D_E_L_E_T_ <> '*' ")

Return cRet

/*
Funcao     : AF200GrvAd()
Parametros : 
Retorno    : Se nao houver nenhum erro na integracao Logix e gravacoes EEQ
Autor      : Tiago Henrique Tudisco dos Santos THTS
Data/Hora  : 28/03/2017
*/
Static Function AF200GrvAd()

Local lRet 		:= .T.

If TMP->EEQ_TIPO $ "P"
    cTipo := "L"
    lAdtForVin	:= .T.
    lAdtForEst	:= .F.
    lCompenFor	:= .T.
ElseIf TMP->EEQ_TIPO $ "R"
    cTipo := "A"
    lAdtCliVin	:= .T.
    lAdtCliEst	:= .F.
EndIf

TMP->(Reclock("TMP",.F.))
    If TMP->EEQ_TIPO $ "R"
        TMP->EEQ_EVENT := "603"
    EndIf
    TMP->EEQ_PROR 	:= ("TMPADT")->(EEQ_PREEMB)	            //Processo Origem
    TMP->EEQ_FAOR 	:= ("TMPADT")->(EEQ_FASE)	            //Fase Origem
    TMP->EEQ_PAOR 	:= ("TMPADT")->(EEQ_PARC)	            //Parcela Origem
    TMP->EEQ_DTCE 	:= ("TMPADT")->(EEQ_DTCE)	            //Data de Cred. Exterior
    TMP->EEQ_SOL	:= ("TMPADT")->(EEQ_SOL)	            //Data de Solicitacao Cambio
    TMP->EEQ_DTNEGO	:= ("TMPADT")->(EEQ_DTNEGO)	            //Data de Negociacao
    TMP->EEQ_PGT	:= ("TMPADT")->(EEQ_PGT)	            //Data de Liquidacao
    TMP->EEQ_TX		:= ("TMPADT")->(EEQ_TX)		            //Taxa da Moeda
    TMP->EEQ_EQVL	:= TMP->EEQ_VL * ("TMPADT")->(EEQ_TX)   //Valor * Taxa da Moeda
    TMP->EEQ_BANC	:= ("TMPADT")->(EEQ_BANC)	            //Banco
    TMP->EEQ_AGEN	:= ("TMPADT")->(EEQ_AGEN)	            //Agencia
    TMP->EEQ_NCON	:= ("TMPADT")->(EEQ_NCON)	            //Conta
    TMP->EEQ_NOMEBC	:= ("TMPADT")->(EEQ_NOMEBC)	            //Nome do banco
    TMP->EEQ_TIPO	:= cTipo                                // "L" //L=Pago Adiantado
    TMP->EEQ_NROP   := ("TMPADT")->(EEQ_NROP)               //Numero da OPeracao
//Quando implementar a compensacao, verificar a necessidade de gravar o titulo do adiantamento
TMP->(MsUnlock())

nRecAdtFor	:= TMP->(Recno()) 

//Efetiva a gravacao no banco
GrvAF200Mn()

TMP->(dbGoTo(nRecAdtFor))
EEQ->(DbGoTo(TMP->TRB_REC_WT))
AvReplace("EEQ","TMP")

nRecAdtFor	:= 0
lAdtForVin	:= .F.
lAdtForEst	:= .F.
lAdtCliVin	:= .F.

Return lRet


/*
Funcao     : getValorBx()
Parametros : lMovExt    - Se .T. o câmbio é Movimento no Exterior; Se .F. é contrato de câmbio (EEQ_MODAL)
             cBanco     - Banco utilizado na liquidação. Se movimento no exterior, não precisa validar a moeda do banco;
             cAgencia   - Agencia utilizada na liquidação.
             cConta     - Conta utilizada na liuqidação
Retorno    : Retorna o valor da liquidação. Se movimento no exterior, ou liquidação com banco estrangeiro, retorna o valor na moeda estrangeira,
             caso contrário, retorna valor em moeda nacional;
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 07/11/2018
*/
Static Function getValorBx(lMovExt,cBanco,cAgencia,cConta)
Local nRet      := 0
Local aAreaSA6  := SA6->(GetArea())

If lMovExt //Se Modalidade é cambio no exterior, retorna o valor em moeda estrangeira EEQ_VL
    nRet := AF200VLFCam("EEQ","LIQ")//EEQ->EEQ_VL //THTS - 31/07/2019 - Alterado para utilizar o valor do fechamento de cambio, pois o valor da parcela pode conter desconto, decréscimo, etc.
Else
    //Caso a modalidade seja contrato de cambio EEQ_MODAL, verificar a moeda do banco utilizado na liquidação
    SA6->(dbSetOrder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
    If IsReceita(EEQ->EEQ_EVENT) .Or. (SA6->(dbSeek(xFilial("SA6") + cBanco + cAgencia + cConta)) .And. SA6->A6_MOEDA < 2) //Se o banco da liquidação é moeda 1, retorna o valor em moeda nacional
        nRet := EEQ->EEQ_EQVL
    Else
        nRet := AF200VLFCam("EEQ","LIQ")//EEQ->EEQ_VL //THTS - 31/07/2019 - Alterado para utilizar o valor do fechamento de cambio, pois o valor da parcela pode conter desconto, decréscimo, etc.
    EndIf

EndIf

RestArea(aAreaSA6)
Return nRet


/*
Função     : AF200VLFCam
Parâmetros : cAlias - Alias dos campos da parcela de câmbio(M-Memória ou EEQ-Tabela)
Retorno    : nValor -> Valor do fechamento de câmbio
Objetivos  : Retorna o valor do fechamento de câmbio considerando acrescimos/decrescimos/multas/juros/descontos caso houver.
Autor      : Nilson Cesr C. Filho - NCF
Data/Hora  : 21/03/2019 - 14:55
Obs.       :
*/
Function AF200VLFCam(cAlias,cTipoOp)

Local nValorMoe :=  nValorConv  := nTaxaRs := 0
Local lCpoAcrDcr:= AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
Default cTipoOp := "ALT"

If !IsLiqFFC()
   If cAlias == "M" 
      nValorMoe := &(cAlias+"->EEQ_VL") - &(cAlias+"->EEQ_CGRAFI") 
      If lCpoAcrDcr 
         nValorMoe += &(cAlias+"->EEQ_ACRESC") - &(cAlias+"->EEQ_DECRES")
         //THTS - 29/08/2019 - Mesmo na alteração, pode ocorrer de ter DESCONTO devido a alteração de preço pos embarque. Também não é possível informar multa e juros na alteracao.
         //If cTipoOp == "LIQ" 
            nValorMoe += &(cAlias+"->EEQ_MULTA") + &(cAlias+"->EEQ_JUROS") 
         //EndIf
      EndIf
      If EEQ->(FieldPos("EEQ_DESCON")) > 0
         nValorMoe -= &(cAlias+"->EEQ_DESCON")
      EndIf
   Else
      nValorMoe := (cAlias)->EEQ_VL - (cAlias)->EEQ_CGRAFI
      If lCpoAcrDcr 
         nValorMoe += (cAlias)->EEQ_ACRESC - (cAlias)->EEQ_DECRES
         //If cTipoOp == "LIQ"
            nValorMoe += (cAlias)->EEQ_MULTA + (cAlias)->EEQ_JUROS
         //EndIf
      EndIf
      If EEQ->(FieldPos("EEQ_DESCON")) > 0
         nValorMoe -= (cAlias)->EEQ_DESCON
      EndIf
   EndIf
Else
   nValorMoe := If( cAlias == "M" , &(cAlias+"->EEQ_VLFCAM") , (cAlias)->EEQ_VLFCAM )
EndIf
   
Return nValorMoe

/*
Função     : AF200CnvCmb
Parâmetros : cAlias - Alias dos campos da parcela de câmbio(M-Memória,EEQ-Tabela ou TRB-Work)
Retorno    : nValMd - Valor do fechamento de câmbio na moeda do câmbio
Objetivos  : Retornar o valor convertido pela taxa conforme a modalidade de câmbio, caso houver.
Autor      : Nilson Cesr C. Filho - NCF
Data/Hora  : 21/03/2019 - 14:55
Obs.       :
*/
Static Function AF200CnvCmb(cAlias,nValMd,nDecimais,cCpoVld,nTipoOpcX)

Local nValorConv := nValMd
Default nDecimais := TAMSX3("EEQ_EQVL")[2]
Default cCpoVld   := ""

   If !EasyVerModal(cAlias)
      //NCF - 02/04/2019 - Liquidação via Contrato de Câmbio
      nValorConv  := Round( If( cAlias == "M", &(cAlias+"->EEQ_TX")  ,(cAlias)->EEQ_TX ) * nValMd , nDecimais )
   Else
      //NCF - 02/04/2019 - Liquidação via Movimento em banco no exterior
      If !Empty( If( cAlias == "M", &(cAlias+"->EEQ_DTCE")  ,(cAlias)->EEQ_DTCE ) ) 
            //Liquidação em banco no exterior (receita) pela data do crédido              //Liquidação em banco no exterior (despesa) pela data de liquidação                        
         If nTipoOpcX == ALT_DET .And. Empty( If( cAlias == "M", &(cAlias+"->EEQ_PGT")  ,(cAlias)->EEQ_PGT ) ) .Or. ( cCpoVld == "EEQ_VLMBCO" .And. !IsReceita(  If( cAlias == "M", &(cAlias+"->EEQ_EVENT")  ,(cAlias)->EEQ_EVENT ) ) )
            nValorConv := Round( If( cAlias == "M", &(cAlias+"->EEQ_PRINBC")  ,(cAlias)->EEQ_PRINBC ) * nValMd , nDecimais )
         Else
            //Movimentação de saída da conta em banco no exterior para entrada na conta em banco nacional
            nValorConv  := Round( If( cAlias == "M", &(cAlias+"->EEQ_TX")  ,(cAlias)->EEQ_TX ) * nValMd , nDecimais )
         EndIf
      EndIf
   EndIf

Return nValorConv

/*
Função     : IntegFIN
Parâmetros : cMod - Modulo a verificar
Retorno    : lRet - (.T. - Tem intgração, .F. - não tem integração)
Objetivos  : Verificar se o módulo ativo tem integração com o SIGAFIN
Autor      : Nilson Cesr C. Filho - NCF
Data/Hora  : 21/03/2019 - 14:55
Obs.       :
*/
Static function IntegFIN(cMod)
Local lRet      := .F.
Local cModu     := Alltrim(cMod)
Local cModulChk := Alltrim(cModulo)

If cModu $ cModulChk
   If "EEC" $ cModu
      lRet := IsIntEnable("001")
   ElseIf "ESS" $ cModu
      lRet := IsIntEnable("004")
   EndIf
EndIf

Return lRet

/*
Função     : IsLiqFFC
Parâmetros : <Nenhum>
Retorno    : lRet - (.T. - Liquidação de FFC, .F. - Outras rotinas)
Objetivos  : Retornar se a operação atual é uma liquidação de FFC
Autor      : Nilson Cesr C. Filho - NCF
Data/Hora  : 27/03/2019
Obs.       :
*/
Static Function IsLiqFFC()
Local lRet := .F.
   lRet := !Empty(M->EEQ_FFC) .And. IsMemVar("nTotFFC") .And. IsMemVar("nTipoDet") .And. nTipoDet == 0
Return lRet

/*
Função     : AF200AutDescon
Parâmetros : Nil
Retorno    : Valor do Desconto em Reais
Objetivos  : Retorna o valor do Desconto. Função utilizada no easylink.
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 10/06/2019
*/
Function AF200AutDescon()
Local nComiss := 0
Local nDescon := 0
Local nDecimais := TAMSX3("EEQ_EQVL")[2]
Local nTaxa

If EasyGParam('MV_EEC0056',,.F.)
    nComiss := EEQ->EEQ_CGRAFI
EndIf
nDescon := EEQ->EEQ_DESCON
If EasyVerModal("EEQ")
   nTaxa := 1
Else
   nTaxa :=  AF200VlTx()
EndIf
Return Round((nDescon + nComiss) * nTaxa, nDecimais)

/*
Função:    GetAdFinInf()
Autor:     Nilson César C. Filho
Objetivos: Obter o número do título e tipo do título da parcela original vinculada ao adiantamento de pedido
Parâmetro: aFiliais - array de Filiais nas quais serão feitas as pesquisas de parcelas.
Retorno:   aFinNum: [1]-Título / [2]-Tipo do título
Data:      04/07/2019
*/
Static Function GetAdFinInf( aFiliais )

Local j
Local cFaseOri := EEQ->EEQ_FAOR
Local cPrOri   := EEQ->EEQ_PROR
Local cParOri  := EEQ->EEQ_PAOR
Local aOrd     := SaveOrd("EEQ")
Local aFinNum  := {"",""}
Local lSeek
   EEQ->(DbSetOrder(6))
   For j := 1 To Len(aFiliais)
      lSeek := EEQ->(DbSeek( aFiliais[j] + cFaseOri + cPrOri + cParOri ) )
      If lSeek
         EXIT
      EndIf
   Next j
   
   If lSeek
      aFinNum[1] :=  EEQ->EEQ_FINNUM
      aFinNum[2] :=  TETpTitEEQ("EEQ")
   EndIf

   RestOrd(aOrd,.T.)

Return aFinNum


/*
Função     : TETpTitEEQ
Objetivo   : Retornar o tipo de título da parcela de adiantamento posicionada
Retorno    : Nil
Autor      : NCF - Nilson César
Data/Hora  : 02/07/2019
*/
Function TETpTitEEQ(cAlias)
Local cTipoTit := ""
Local aOrd     := SaveOrd("EC6")

   If IsReceita( If( cAlias == "M" , &(cAlias+"->EEQ_EVENT") , (cAlias)->EEQ_EVENT ) )
      EC6->(DbSetOrder(6))
      If  EC6->(DbSeek( xFilial("EC6")+"EXPORT"+  If( cAlias == "M" , &(cAlias+"->EEQ_EVENT") , (cAlias)->EEQ_EVENT ) ))
         cTipoTit := EC6->EC6_TPTIT
      EndIf
      RestOrd(aOrd,.T.)

      If Empty(cTipoTit) .And. ( If( cAlias == "M" , &(cAlias+"->EEQ_TIPO") , (cAlias)->EEQ_TIPO ) == "A" )
         cTipoTit := "RA"
      EndIf
   EndIf

Return cTipoTit

/*
Função     : MsgVLFCAM
Objetivo   : Exibir a mensagem de valor de fechamento de cambio inválido.
Retorno    : Nil
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 05/08/2019
*/
Static Function MsgVLFCAM()
EasyHelp(STR0262+CHR(13)+CHR(10)+; //"A somatória dos Decréscimos e Descontos é igual ou excede o valor da parcela somados o Acréscimos, Juros e Multa!"
        STR0263+STR(M->EEQ_VL,AvSx3("EEQ_VL",AV_TAMANHO),AvSx3("EEQ_VL",AV_DECIMAL))    +CHR(13)+CHR(10)+;
        STR0264+STR(M->EEQ_CGRAFI,AvSx3("EEQ_CGRAFI",AV_TAMANHO),AvSx3("EEQ_CGRAFI",AV_DECIMAL))+CHR(13)+CHR(10)+;
        STR0265+STR(M->EEQ_ACRESC,AvSx3("EEQ_ACRESC",AV_TAMANHO),AvSx3("EEQ_ACRESC",AV_DECIMAL))+CHR(13)+CHR(10)+;
        STR0266+STR(M->EEQ_DECRES,AvSx3("EEQ_DECRES",AV_TAMANHO),AvSx3("EEQ_DECRES",AV_DECIMAL))+CHR(13)+CHR(10)+;
        STR0267+STR(M->EEQ_DESCON,AvSx3("EEQ_DESCON",AV_TAMANHO),AvSx3("EEQ_DESCON",AV_DECIMAL))+CHR(13)+CHR(10)+;
        STR0268+STR(M->EEQ_MULTA ,AvSx3("EEQ_MULTA" ,AV_TAMANHO),AvSx3("EEQ_MULTA" ,AV_DECIMAL))+CHR(13)+CHR(10)+;
        STR0269+STR(M->EEQ_JUROS ,AvSx3("EEQ_JUROS" ,AV_TAMANHO),AvSx3("EEQ_JUROS" ,AV_DECIMAL))+CHR(13)+CHR(10)+;
        STR0270+STR(M->EEQ_VLFCAM,AvSx3("EEQ_VL",AV_TAMANHO),AvSx3("EEQ_VL",AV_DECIMAL)),"ATENÇÃO")
Return

//==============================================//
// Função para criar nova parcela com diferença
//==============================================//
Static Function RatVlrDif( nVariacao, cCpoDistr, nTotalParcs, nTotalDesc, nTotalComis, aEEQAux, lEvent101)
Local oRatVlrVar, i
Local oRatComiss
Local aVlrsAtu := {}
Local aRet := {.F.,aClone(aEEQAux)}
Local lRet := .T.
Local nTotComAR := nTotComCG := nTotComDD := 0
Local oRatComAR
Local oRatComCG
Local oRatComDD
Local aVlrComAR := {}
Local aVlrComCG := {}
Local aVlrComDD := {}
Local lParcComis:= .F. //Identifica se devera ser gerada uma nova parcela para tratamento de comissao. Cenario identificado ao utilizar preco aberto igual a nao.
//Utilizado para converter os valores quando negativo. Somente utilizado para alteasylink .F.
Local nFator101 := 1 
Local nFator120 := 1
Local nFator121 := 1
Local nFator122 := 1

    oRatVlrVar := EasyRateio():New(  Abs(nVariacao) , nTotalParcs /*- nTotalDesc - nTotalComis */, Len(aEEQAux) , TAMSX3("EEQ_VL")[2]  )
    aEval(aEEQAux,{|x| aAdd(aVlrsAtu, (oRatVlrVar:GetItemRateio(x[3] /*- x[5] - x[6][2]*/) ) ) })

    //Apura os valores de comissões das parcelas em aberto e zera os valores percentuais de cada comissão nas parcelas
    If lEvent101
        aEval(aParcAlter,{|x| IIf(x[2] == EV_COM_AR, nTotComAR := x[1], IIF(x[2] == EV_COM_CG, nTotComCG := x[1], IIF(x[2] == EV_COM_DF, nTotComDD := x[1], )))})
        If cCpoDistr=="EEQ_DESCON" .And. (nTotComCG > 0)
			lParcComis := .T.
		EndIf
		If !Empty(nTotComAR) //.And. nTotComAR < 0
            oRatComAR := EasyRateio():New(  Abs(nTotComAR) , nTotalParcs /*- nTotalDesc - nTotalComis */, Len(aEEQAux) , TAMSX3("EEQ_VL")[2]  )
            aEval(aEEQAux,{|x| aAdd(aVlrComAR, (oRatComAR:GetItemRateio(x[3] - x[5]) ) ) })
        EndIf
        If !Empty(nTotComCG)// .And. nTotComCG < 0
            oRatComCG := EasyRateio():New(  Abs(nTotComCG) , nTotalParcs /*- nTotalDesc - nTotalComis*/ , Len(aEEQAux) , TAMSX3("EEQ_VL")[2]  )
            aEval(aEEQAux,{|x| aAdd(aVlrComCG, (oRatComCG:GetItemRateio(x[3] - x[5] - x[6][2]) ) ) })
        EndIf
        If !Empty(nTotComDD) //.And. nTotComDD < 0
            oRatComDD := EasyRateio():New(  Abs(nTotComDD) , nTotalParcs /*- nTotalDesc - nTotalComis*/ , Len(aEEQAux) , TAMSX3("EEQ_VL")[2]  )
            aEval(aEEQAux,{|x| aAdd(aVlrComDD, (oRatComDD:GetItemRateio(x[3] - x[5]) ) ) })
        EndIf
    EndIf
    
    For i := 1 To Len(aEEQAux)
        EEQ->(DbGoTo(aEEQAux[i][2]))     // Posiciona a EEQ no registro da parcela
        EEQ->(RecLock("EEQ",.F.))
        If cCpoDistr == "EEQ_VL"
            IIf(nVariacao < 0,nFator101 := -1,nFator101 := 1)
            IIf(nTotComAR < 0,nFator120 := -1,nFator120 := 1)
            IIf(nTotComCG < 0,nFator121 := -1,nFator121 := 1)
            IIf(nTotComDD < 0,nFator122 := -1,nFator122 := 1)
            EEQ->EEQ_VL +=  aVlrsAtu[i] * nFator101
            If !Empty(EEQ->EEQ_FI_TOT)    //Abate para o financiamento
                EEQ->EEQ_VL_PAR += aVlrsAtu[i]
                If EEQ->EEQ_VL_PAR = 0
                    EEQ->EEQ_FI_TOT := "S"
                EndIf
            EndIf
            If Len(aVlrComAR) > 0
                EEQ->EEQ_AREMET += aVlrComAR[i] * nFator120
            EndIf
            If Len(aVlrComCG) > 0
                EEQ->EEQ_CGRAFI += aVlrComCG[i] * nFator121
            EndIf
            If Len(aVlrComDD) > 0
                EEQ->EEQ_ADEDUZ += aVlrComDD[i] * nFator122
            EndIf
        ElseIf cCpoDistr == "EEQ_DESCON"
            If EasyGParam("MV_EEC0056",,.f.)
                EEQ->EEQ_DESCON += aVlrsAtu[i]
            Else
                If Len(aVlrComCG) > 0
					If lParcComis
						EEQ->EEQ_DESCON += Abs(aVlrsAtu[i]) + Abs(aVlrComCG[i])
					Else
                    	EEQ->EEQ_DESCON += Abs(aVlrsAtu[i]) - Abs(aVlrComCG[i])
					EndIf
                EndIf
                If  Len(aVlrComCG) == 0
                    EEQ->EEQ_DESCON += Abs(aVlrsAtu[i])
                EndIf
            EndIf
        EndIf
        EEQ->(MsUnlock())
                                                                  //MFR 19/02/2020 OSSME-4269
        If cCpoDistr == "EEQ_VL" .And. EEQ->EEQ_EVENT != EV_COM_DF .And. EasyGParam("MV_AVG0131",,.F.) //Não integra quando EEC_LOGIX ou ALT_EASYLINK
            If !Empty(EEQ->EEQ_FINNUM)
                If EEQ->EEQ_VL == 0
                    If lEvent101
                        If !AvStAction("007")//Exclusão de título a receber no SIGAFIN
                            lRet := .F.
                            Exit
                        EndIf
                    Else
                        If !AvStAction("012") //Exclusão de título a pagar no SIGAFIN
                            lRet := .F.
                        	Break
                        EndIf
                    EndIf
                    EEQ->(RecLock("EEQ",.F.))
                    EEQ->(dbDelete())
                    EEQ->(MsUnLock())
                    aDel(aEEQAux,i)
                    aSize(aEEQAux,Len(aEEQAux)-1)
                Else
                    If lEvent101
                        If !AvStAction("006")//Alteração de título a receber no SIGAFIN
                            lRet := .F.
                            Exit
                        EndIf
                    Else
                        If !AvStAction("011")//Alteração de título a pagar no SIGAFIN
                            lRet := .F.
                            Break
                        EndIf
                    EndIf
                EndIf
            Else
                If lEvent101
                    If AvStAction("005")//Inclusão de título a receber no SIGAFIN
                        lRet := .F.
                        Exit
                    EndIf
                Else
                    If !AvStAction("010")//Inclusão de título a pagar no SIGAFIN
                        lRet := .F.
                        Break
                    EndIf
                EndIf
            EndIf
        EndIf
    Next i
	If lParcComis
		CriaParcDif( nTotComCG + 0.01, aEEQAux , nTotalParcs, 0.01 )
	EndIf
    If lRet
        aRet := {.T.,aClone(aEEQAux)}
    EndIf

Return aRet
// Distribuir nas parcelas do array aEEQ
// Executar o Action de integração em modo de alteração

//==============================================//
// Função para criar nova parcela com diferença
// - Cria nova parcela no EEQ com a Diferença
// - Verificar como será atribuído o título nesta parcela conforme Flag("TIT_PARCELAS")
// - Não carregar campos da EEQ 
//==============================================//
Static Function CriaParcDif( nVariacao, aEEQAux , nTotalParcs, nDesc ) 

Local aDadosEEQ := {}
Local nTotComAR := nTotComCG := nTotComDD := 0
Local oRatComAR , oRatComCG , oRatComDD, i, aOrd, cSeqParc
Local lRet := .T. 
Local aRet := {.F.,aClone(aEEQAux)}
Local aAreaEC6 := EC6->(GetArea())
Default nDesc := 0
//aSort(aEEQAux    ,,, {|x, y| x[1] < y[1] }) // Ordena da menor para maior data de vencimento das parcelas.
EEQ->(DbGoTo(aEEQAux[1][2]))     // Posiciona a EEQ no registro da parcela com maior vencimento

aOrdEEQ := SaveOrd("EEQ")                   
EEQ->(DbSetOrder(1))
EEQ->(AvSeekLast(xFilial("EEQ")+EEC->EEC_PREEMB))  //Pega a ultima seq. de parcelas do câmbio
cSeqParc := EEQ->EEQ_PARC
RestOrd(aOrdEEQ,.T.)

FOR i:=1 To EEQ->(Fcount())                 // Copia os dados da parcela para atribuição dos dados na nova parcela.
   aAdd(aDadosEEQ , &("EEQ->"+EEQ->(FIELDNAME(i)) ) )
Next i

EEQ->(RecLock("EEQ",.T.))                   // Cria nova parcela
   FOR i:=1 To EEQ->(Fcount())              // Copia todos os dados
      EEQ->&((FIELDNAME(i))) :=  aDadosEEQ[i] 
   Next i
   EEQ->EEQ_VL      := nVariacao             //Atribui dados da nova parcela
   EEQ->EEQ_FINNUM  := "" 
   EEQ->EEQ_PARC    := SomaIt(cSeqParc)
   EEQ->EEQ_PARVIN  := EEQ->EEQ_PARC
   EEQ->EEQ_DTCE    := AVCTOD("  /  /  ")
   EEQ->EEQ_SOL     := AVCTOD("  /  /  ")
   EEQ->EEQ_DTNEGO  := AVCTOD("  /  /  ")
   EEQ->EEQ_PGT     := AVCTOD("  /  /  ")
   EEQ->EEQ_NROP    := ""
   EEQ->EEQ_TX      := 0
   EEQ->EEQ_EQVL    := 0
   EEQ->EEQ_BANC    := ""
   EEQ->EEQ_AGEN    := ""
   EEQ->EEQ_NCON    := ""
   EEQ->EEQ_NOMEBC  := ""
   If nDesc > 0
		EEQ->EEQ_DESCON  := nDesc
   Else
   		EEQ->EEQ_DESCON  := 0
   EndIf
   EEQ->EEQ_AREMET  := 0
   EEQ->EEQ_CGRAFI  := 0
   EEQ->EEQ_ADEDUZ  := 0
   EEQ->EEQ_ACRESC  := 0
   EEQ->EEQ_DECRES  := 0
   EEQ->EEQ_MULTA   := 0
   EEQ->EEQ_JUROS   := 0
   If AvFlags("EEC_LOGIX") .And. EEQ->EEQ_EVENT == EV_COM_DF
        EC6->(DbSetOrder(1))
        EC6->(DbSeek(xFilial("EC6") + "EXPORT" + EEQ->EEQ_EVENT))
        EEQ->EEQ_PGT  := M->EEC_DTEMBA
        EEQ->EEQ_TX   := BuscaTaxa(EEC->EEC_MOEDA, dDTEMBA,,.F.,,,If(EC6->EC6_TXCV=='2','2','1'))
        EEQ->EEQ_EQVL := Round(EEQ->EEQ_VL * EEQ->EEQ_TX, AvSX3("EEQ_EQVL",AV_DECIMAL))
        RestArea(aAreaEC6)
   EndIf
EEQ->(MsUnlock())

//Apura os valores de comissões das parcelas em aberto e zera os valores percentuais de cada comissão nas parcelas
aEval(aParcAlter,{|x| IIf(x[2] == EV_COM_AR, nTotComAR := x[1], IIF(x[2] == EV_COM_CG, nTotComCG := x[1], IIF(x[2] == EV_COM_DF, nTotComDD := x[1], )))})
If EEQ->EEQ_EVENT == EV_PRINC2 .And. (!Empty(nTotComAR) .Or. !Empty(nTotComCG) .Or. !Empty(nTotComDD))
    EEQ->(RecLock("EEQ",.F.))
    EEQ->EEQ_AREMET  := IIF(nTotComAR > 0,nTotComAR,0)
    EEQ->EEQ_CGRAFI  := IIF(nTotComCG > 0,nTotComCG,0)
    EEQ->EEQ_ADEDUZ  := IIF(nTotComDD > 0,nTotComDD,0)
    EEQ->(MsUnlock())
EndIf

//Atualiza Array de parcelas com a nova parcela
AAdd(aEEQAux,{DtoS(EEQ->EEQ_VCT),EEQ->(RecNo()),If(Empty(EEQ->EEQ_FI_TOT),EEQ->EEQ_VL,EEQ->EEQ_VL_PAR),EEQ->EEQ_PARC ,{ 0 , 0,  0 } })

If EEQ->EEQ_EVENT == EV_PRINC2
    If !AvStAction("005")//Inclusão de título a Receber integrado ao FINANCEIRO Protheus/Logix
        lRet := .F.
    EndIf
ElseIf !AvFlags("EEC_LOGIX") .And. EEQ->EEQ_EVENT $ (EV_COM_AR + "/" + EV_COM_CG + "/")
    If !AvStAction("010")//Inclusão de título a pagar no SIGAFIN
        lRet := .F.
    EndIf
ElseIf AvFlags("EEC_LOGIX") .And. EEQ->EEQ_EVENT == EV_COM_AR
    If !AvStAction("010")//Inclusão de título a pagar no SIGAFIN
        lRet := .F.
    EndIf
ElseIf AvFlags("EEC_LOGIX") .And. EasyGParam("MV_EEC0025",,.T.) .And. EEQ->EEQ_EVENT == EV_COM_DF
    If !AvStAction("087")
        lRet := .F.
    EndIf
EndIf

If lRet
   aRet := {.T.,aClone(aEEQAux)}
EndIf

Return aRet

/*==========================================================================================//
//Função     : HasParcCtr
//Objetivo   : Função para retornar existência de parcelas baixadas em um contrato de câmbio
               do mesmo banco/agência/conta mas com informações de taxa, moeda e liquidação 
               diferentes. Caso a integração via EAI esteja ligada, avalia também os campos
               de data de solicitação e fechamento do contrato de câmbio.
//Retorno    : (Tipo Lógico).T. - Caso exista e .F. caso contrário
//Observação : Exije EEQ posicionada no registro da parcela baixada.
//Autor      : NCF - Nilson César
//Data/Hora  : 02/07/2019
//==========================================================================================*/
*-------------------------------------------------*
Static Function HasParcCtr( nReqEEQ, cBanc, cAg, cConta, cContrato, nTaxa, cMoeda, dDataLiqui, dDataSolic, dDataNegoc )
*-------------------------------------------------*
Local aRet  := {}
Local cQry  := ""
Local cQryEEQ := getnextalias()
Local nPos  := 0

cQry += "Select EEQ_TIPO,EEQ_PGT,EEQ_BANC,EEQ_AGEN,EEQ_NCON,EEQ_NROP,EEQ_TX,"
cQry += "EEQ_MOEDA,EEQ_PGT,EEQ_SOL,EEQ_DTNEGO,EEQ_PARC,D_E_L_E_T_,R_E_C_N_O_"
cQry += " FROM "+retsqlname("EEQ")
cQry += " WHERE D_E_L_E_T_ <> '*'"
cQry += " AND EEQ_TIPO IN ('R','A')"
cQry += " AND EEQ_PGT <> ' '"
cQry += " AND R_E_C_N_O_ <> "+ Str(nReqEEQ)
cQry += " AND EEQ_BANC  = '"+cBanc+"'"
cQry += " AND EEQ_AGEN  = '"+cAg+"'"
cQry += " AND EEQ_NCON  = '"+cConta+"'"
cQry += " AND EEQ_NROP  = '"+cContrato+"'"
cQry += " AND ( EEQ_TX    <>  "+Str(nTaxa)+""
cQry += " OR EEQ_MOEDA <> '"+cMoeda+"'"
cQry += " OR EEQ_PGT   <> '"+DToS(dDataLiqui)+"'"
If AvFlags("EEC_LOGIX")
   cQry += " OR EEQ_SOL    <> '"+DToS(dDataSolic)+"'"
   cQry += " OR EEQ_DTNEGO <> '"+DToS(dDataNegoc)+"'"
EndIf
cQry += " ) "
cQry += " ORDER BY EEQ_PARC"

cQry:=ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), cQryEEQ , .F., .T.)

(cQryEEQ)->(DBGoTop())
Do While ((cQryEEQ)->(!Bof()) .AND. (cQryEEQ)->(!Eof()))
   aAdd(aRet,{ (cQryEEQ)->EEQ_TX ,(cQryEEQ)->EEQ_MOEDA ,STod((cQryEEQ)->EEQ_PGT) ,STod((cQryEEQ)->EEQ_SOL), STod((cQryEEQ)->EEQ_DTNEGO) } )
   (cQryEEQ)->(dBSkip())
EndDo

(cQryEEQ)->(DbCloseArea())

Return aRet

*-------------------------------------------------*
Static Function lHasPrcAb(cChave,cEEQRec)
*-------------------------------------------------*
Local lRet  := .F.
Local cQry  := ""
Local cQryEEQ := getnextalias()

cQry += "Select R_E_C_N_O_ FROM "+TETempName("TMP")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += " AND EEQ_FILIAL = '"+TMP->EEQ_FILIAL+"'"
cQry += " AND EEQ_PREEMB = '"+TMP->EEQ_PREEMB+"'"
cQry += " AND EEQ_EVENT  = '"+TMP->EEQ_EVENT+"'"
cQry += " AND EEQ_TIPO   = '"+TMP->EEQ_TIPO+"'"
cQry += " AND EEQ_FASE   = '"+TMP->EEQ_FASE+"'"
cQry += " AND EEQ_PARVIN = '"+TMP->EEQ_PARVIN+"'"
cQry += " AND EEQ_FINNUM = '"+TMP->EEQ_FINNUM+"'"
cQry += " AND R_E_C_N_O_ <> "+Alltrim(Str(TMP->(Recno())))
cQry += " AND (EEQ_MODAL = '2' AND (EEQ_SEQBX  = ' ' OR ( EEQ_SEQBX  = '"+TMP->EEQ_SEQBX+"' AND EEQ_PGT = ' ' ))" //Sem movimento no exterior ou caso tenha, sem contrato de fechamento de câmbio.
cQry += " OR EEQ_MODAL = '1' AND EEQ_SEQBX  = ' ')"                                                              //Sem contrato de fechamento de câmbio.

cQry:=ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), cQryEEQ , .F., .T.)
(cQryEEQ)->(DBGoTop())
If ((cQryEEQ)->(!Bof()) .AND. (cQryEEQ)->(!Eof()))
   lRet := .T.
EndIf
(cQryEEQ)->(DbCloseArea())

Return lRet

/*==========================================================================================//
//Função     : BlqBxMdDif
//Objetivo   : Retornar se o bloqueio da baixa de câmbio no exterior com moeda da invoice 
               diferente da moeda do banco pode ser realizada.
//Retorno    : (Tipo Lógico).T. - Caso bloqueie e .F. caso contrário
//Observação : N/A
//Autor      : NCF - Nilson César
//Data/Hora  : 28/02/2020
//==========================================================================================*/
Static Function BlqBxMdDif()
Local lRet

lRet := "EEQ_CNTEXT" $ ReadVar()/*RMD - 17/06/20 - Validar na edição da conta, e não do banco*/                           .And. ; //Se está validando último campo da chave
        ( (cModulo == "EEC" .And. IsIntEnable("001") ) .Or. (cModulo == "ESS" .And. EasyGParam("MV_AVG0226",.F.,.F.)) )   .And. ; //Se é EEC ou ESS integrado com SIGAFIN
        ( EasyVerModal("M") )                                                                                             .And. ; //Se é câmbio com movimento no exterior
        ( !Empty(M->EEQ_BCOEXT) .And. !Empty(M->EEQ_AGCEXT).And. !Empty(M->EEQ_CNTEXT) )                                  .And. ; //Se os campos da chave da conta bancária estão preenchidos
        ( SA6->(DbSetOrder(1),DbSeek(xFilial("SA6")+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT))) )                             .And. ; //Se existe o banco no arquivo conforme a chave
        ( SA6->A6_MOEEASY <> M->EEQ_MOEDA )                                                                               .And. ; //Se a moeda deste banco é diferente da moeda da invoice
        ( M->EEQ_TIPO == "R"  .Or. !EasyGParam("MV_MOEDBCO",.F.,.F.) )                                                            //Se o parâmetro que permite liq. com moedas diferentes estiver habilitado em caso de câmbio a pagar

Return lRet

*------------------------------------------------------------------------------------------------------------------*
*                                        FIM DO PROGRAMA EECAF200                                                  *
*------------------------------------------------------------------------------------------------------------------*
Function AF200VldOpr()
Local lRet := .T.
Local aParcCtrLq   := HasParcCtr( EEQ->(Recno()), M->EEQ_BANC, M->EEQ_AGEN, M->EEQ_NCON, M->EEQ_NROP, M->EEQ_TX, M->EEQ_MOEDA, M->EEQ_PGT, M->EEQ_SOL, M->EEQ_DTNEGO )
Local cMsgLqCtCa, nOpcLqCtCa

   If Len(aParcCtrLq) > 0
      //"Existem uma ou mais parcelas liquidadas com esse mesmo contrato de fechamento de câmbio e neste mesmo banco, porém com as informações de #CAMPOS# diferentes da atual.", #Atenção
      //"taxa, moeda ou data de liquidação " # "taxa, moeda, data de liquidação, data de solicitação ou fechamento do contrato "                
      cMsgLqCtCa := StrTran( STR0307 , "#CAMPOS#", If( AvFlags("EEC_LOGIX") , STR0341 , STR0342 ) ) + ENTER + ENTER 
      cMsgLqCtCa += STR0343 + Alltrim( Str(aParcCtrLq[1][1],TamSX3("EEQ_TX")[1],TamSX3("EEQ_TX")[2])  )+ENTER             //"Taxa do contrato...: "
      cMsgLqCtCa += STR0344 + Alltrim( aParcCtrLq[1][2] )+ENTER                                                           //"Moeda do contrato..: "
      If AvFlags("EEC_LOGIX")
         cMsgLqCtCa += STR0345 + DToC(aParcCtrLq[1][3])+ENTER                                                          //"Data de pagamento..: "
         cMsgLqCtCa += STR0346 + DToC(aParcCtrLq[1][4]) +ENTER                                                      //"Data de solicitação: "   
         cMsgLqCtCa += STR0347 + DToC(aParcCtrLq[1][5]) +ENTER                                                      //"Data de negociação.: "  
      EndIf
      cMsgLqCtCa += ENTER + StrTran( STR0348, "#CAMPOS#", If( AvFlags("EEC_LOGIX") , STR0341 , STR0342 ) ) + ENTER + ENTER //"Caso prossiga com a operação, serão carregadas as informações do contrato para os campos: #CAMPOS#."
      cMsgLqCtCa += STR0349 + ENTER + ENTER                                                                               //"Deseja prosseguir com a liquidação do contrato de câmbio ?"
      If (Ismemvar("lExecAuto") .And. lExecAuto) .Or. MsgYesNo(cMsgLqCtCa,STR0014)
         M->EEQ_TX    := aParcCtrLq[1][1]
         M->EEQ_EQVL  := aParcCtrLq[1][1] * M->EEQ_VLFCAM
         //M->EEQ_MOEDA := aParcCtrLq[1][2]
         If AvFlags("EEC_LOGIX")
            M->EEQ_PGT     := aParcCtrLq[1][3]
            M->EEQ_SOL     := aParcCtrLq[1][4] 
            M->EEQ_DTNEGO  := aParcCtrLq[1][5]
         EndIf
      Else
         lRet:= .f.
      EndIf
   EndIf

Return lRet

/*==========================================================================================//
//Função     : CanExcPrEx
//Objetivo   : Verificar se a parcela tem vinculo com a parcela anterior, para que na exclusão possa ter os valores somados (parcela originada de uma quebra)
//Retorno    : (Tipo Lógico).T. - Parcela tem mesma Origem e mesmo vinculo / .F. - Parcelas sem vinculos uma com a outra
//Autor      : THTS - Tiago Tudisco
//Data/Hora  : 05/09/2022
//==========================================================================================*/
Static Function CanExcPrEx(lModalPrEx,lModalNext,cNumTit,cSeqBx,cBcoExt,cAgExt,cCCExt,cParVin,dDtCE)
Local lRet := .F.

If !Empty(TMP->EEQ_DTCE) .And. lModalPrEx .And. lModalNext .And. TMP->EEQ_FINNUM == cNumTit .And. TMP->EEQ_SEQBX == cSeqBx .And. TMP->EEQ_BCOEXT == cBcoExt .And. TMP->EEQ_AGCEXT == cAgExt .And. TMP->EEQ_CNTEXT == cCCExt .And.;
   TMP->EEQ_PARVIN == cParVin .And. TMP->EEQ_DTCE == dDtCE
   lRet := .T.
EndIf

Return lRet

/*==========================================================================================//
//Função     : QbPosMvExt
//Objetivo   : Verifica se existe alguma parcela originada após o movimento no exterior
//Retorno    : (Tipo Lógico).T. - Existe parcela originada apos o movimento no exterior / .F. - Não existe parcela originada apos o movimento no exterior
//Autor      : THTS - Tiago Tudisco
//Data/Hora  : 05/09/2022
//==========================================================================================*/
Static Function QbPosMvExt()
Local lRet := .F.
Local cQuery

cQuery := "SELECT EEQ_PARC "
cQuery += " FROM " + TETempName("TMP") + " "
cQuery += " WHERE EEQ_EVENT   = '" + M->EEQ_EVENT  + "' "
cQuery += "    AND EEQ_NRINVO = '" + M->EEQ_NRINVO + "' "
cQuery += "    AND (EEQ_ORIGEM = '" + M->EEQ_PARC   + "' "
cQuery += "         OR EEQ_PARC= '" + M->EEQ_ORIGEM + "' "
cQuery += "         OR (EEQ_ORIGEM = ' ' "
cQuery += "         AND EEQ_PARC = '" + M->EEQ_PARVIN + "')) "
cQuery += "    AND EEQ_PARVIN = '" + M->EEQ_PARVIN + "' "
cQuery += "    AND EEQ_FINNUM = '" + M->EEQ_FINNUM + "' "
cQuery += "    AND EEQ_SEQBX  = '" + M->EEQ_SEQBX  + "' "
cQuery += "    AND EEQ_BCOEXT = '" + M->EEQ_BCOEXT + "' "
cQuery += "    AND EEQ_AGCEXT = '" + M->EEQ_AGCEXT + "' "
cQuery += "    AND EEQ_CNTEXT = '" + M->EEQ_CNTEXT + "' "
cQuery += "    AND R_E_C_N_O_ <> "+ Str(TMP->(Recno())) + " "
cQuery += "    AND D_E_L_E_T_ = ' ' "

If EasyQryCount(cQuery) > 0
   lRet := .T.
EndIf

Return lRet