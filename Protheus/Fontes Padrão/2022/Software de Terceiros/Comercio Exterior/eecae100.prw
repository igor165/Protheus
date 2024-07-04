#INCLUDE "EECAE100.ch"
#INCLUDE "FILEIO.CH"
#include 'topconn.ch'


#define PC_CF "8" //Processo de exportação de café
#define PC_CM "9" //Processo de exportação de commodites
#define ST_CD "Q" //processo/embarque cancelado por devolução (EE7/EEC)  //NCF - 25/05/2015
#define ST_ME "R" //Processo com câmbio em movimento no exterior         //NCF - 25/11/2015

#define ENTER CHR(13)+CHR(10)
/*
Programa        : EECAE100.PRW
Objetivo        : Manutencao de Embarques de processos de exportacao
Autor           : Heder M Oliveira
Data/Hora       : 26/01/99 12:44
Obs.            :
Revisão         : Alcir Alves - Adaptação da rotina de rateio para criação de novas categorias,inclusão de uma nova campo no array de rateio definindo uma categoria de rateio
Data/Hora       : 08/11/05 16:00
Revisao         : Osman Medeiros Jr.
Data/Hora       : 04/06/01 17:11
Revisao         : Jeferson Barros Jr. - Melhoria no desempenho da manutenção de processos.
Data/Hora       : 24/07/01 13:00
Revisao         : Gustavo Carreiro    - Integração com Drawback
Data/Hora       : 15/02/02 15:20
Revisao         : Osman Medeiros Jr.  - Manutençao de Invoices.
Data/Hora       : 22/06/05 10:11
*/
#include "EEC.CH"

#COMMAND E_RESET_AREA => EEC->(dbSetOrder(1)) ;;
                         WorkIP->(EECEraseArq(cNomARQIP,cNomArq5)) ;;
                         WorkDe->(EECEraseArq(cNomArq1))  ;;
                         WorkAg->(EECEraseArq(cNomArq2))  ;;
                         WorkIn->(EECEraseArq(cNomArq3))  ;;
                         WorkEm->(EECEraseArq(cNomArq4))  ;;
                         WorkNF->(EECEraseArq(cNomArq6))  ;;
                         WorkNo->(EECEraseArq(cNomArq7))  ;;
                         IF(Select("WorkDoc")  > 0,WorkDoc->(EECEraseArq(cNomArq8,cNomArq82)),) ;;
                         IF(Select("WorkCalc") > 0,WorkCalc->(EECEraseArq(cNomArq9)),) ;;
                         IF(Select("WorkInv") > 0,WorkInv->(EECEraseArq(cArqCapInv)),) ;;
                         IF(Select("WorkDetInv") > 0,WorkDetInv->(EECEraseArq(cArqDetInv,cArq2DetInv)),) ;;
                         If(Select("WORKSLD_AD") > 0,WORKSLD_AD->(EECEraseArq(cArqAdiant)),) ;; // By JPP - 08/02/2006 - 10:50
                         If(Select("WkEY5") > 0,WkEY5->(EECEraseArq(cArqWkEY5, cArq2WkEY5)),) ;;
                         If(Select("WkEY6") > 0,WkEY6->(EECEraseArq(cArqWkEY6)),) ;;
                         If(Select("WkEY7") > 0,WkEY7->(EECEraseArq(cArqWkEY7, cArq2WkEY7)),) ;;
                         IF(Select("WorkGrp")  > 0, WorkGrp->(EECEraseArq(cNomArqGrp)),) ;;
                         IF(Select("WorkOpos") > 0,WorkOpos->(EECEraseArq(cNomArqOpos)),) ;;
                         If(Select("WKEXZ") > 0, WKEXZ->(EECEraseArq(cArqCapOIC)),) ;;
                         If(Select("WKEY2") > 0, WKEY2->(EECEraseArq(cArqDetOIC)),) ;;
                         If(Select("WkArm") > 0, WkArm->(EECEraseArq(cWorkArmazem)),) ;;
                         If(Select("WkEYU") > 0, WkEYU->(EECEraseArq(cArqWkEYU)),) ;; // By JPP - 14/11/2007 - 14:00
                         If(Select("Wk_NfRem") > 0, Wk_NfRem->(EECEraseArq(cArqNFRem, cArq2NFRem, cArq3NFRem)),) ;;//RMD - 07/02/17 - Incluídos os arquivos dos índices
                         If(Select("WorkEDG") > 0, WorkEDG->(EECEraseArq(cArqDrawSC)),) ;; //TRP-16/02/2009
                         If(Select("WKEWI") > 0, WKEWI->(EECEraseArq(cArqWkEWI)),)

//DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
#COMMAND E_ZAP_AREA =>EEC->(DBSETORDER(1))  ;;
                        AvZap("WorkIP")     ;;
                        AvZap("WorkDe")     ;;
                        AvZap("WorkAg")     ;;
                        AvZap("WorkIn")     ;;
                        AvZap("WorkEm")     ;;
                        AvZap("WorkNF")     ;;
                        AvZap("WorkNo")     ;;
                        IF(Select("WorkDoc")  > 0,AvZap("WorkDoc") ,) ;;
                        IF(Select("WorkCalc") > 0,AvZap("WorkCalc"),) ;;
                        IF(Select("WorkInv")  > 0,AvZap("WorkInv"),)  ;;
                        IF(Select("WorkDetInv")  > 0,AvZap("WorkDetInv"),) ;;
                        IF(Select("WkEY5")  > 0,AvZap("WkEY5"),) ;;
                        IF(Select("WkEY6")  > 0,AvZap("WkEY6"),) ;;
                        IF(Select("WkEY7")  > 0,AvZap("WkEY7"),) ;;
                        If(Select("WkArm") > 0,AvZap("WkArm"),) ;;
                        IF(Select("WorkGrp")  > 0,AvZap("WorkGrp"),) ;;
                        IF(Select("WorkOpos") > 0,AvZap("WorkOpos"),) ;;
                        If(Select("WKEXZ") > 0, AvZap("WKEXZ"),) ;;
                        If(Select("WKEY2") > 0, AvZap("WKEY2"),) ;;
                        If(Select("WkArm") > 0, AvZap("WkArm"),) ;;
                        If(Select("WkEYU") > 0, AvZap("WkEYU"),) ;; // By JPP - 14/11/2007 - 14:00
                        If(Select("Wk_NfRem") > 0, AvZap("Wk_NfRem"),) ;;
                        If(Select("WorkEDG") > 0, AvZap("WorkEDG"),);;  //TRP-16/02/2009
                        If(Select("WKEWI") > 0, AvZap("WKEWI"),)

#xTranslate SumTotal() => Eval(bTotal,"SOMA")
#xTranslate SubTotal() => Eval(bTotal,"SUBTRAI")

Static cFilterBrw  := ""

/*
Funcao      : EECAE100()
Parametros  :
Retorno     : .T.
Objetivos   : Executar mbrowse
Autor       : Heder M Oliveira
Data/Hora   : 26/01/99 14:13
Revisao     : Jeferson Barros Jr - 24/07/01 13:25 - Melhoria no desempenho da manutenção de processos.
Obs.        :
*/
*------------------
Function EECAE100(nRecEEC,nOpcBrowse,xAuto,cOpcComp)//RMD - 26/10/17 - xAuto recebe dados para execauto
*------------------
Local nOrderSX3 := SX3->(IndexOrd()), i
Local lRet:=.T.,cOldArea:=select(),cAlias:="EEC",cAVG0034

Local cExpFilter := ""  // PLB 03/08/07 - Filtro a ser aplicado antes do MBrowse

Local cCodId   := UPPER(AvKey(EasyGParam("MV_AVG0035",,"PORT."),"X5_CHAVE")) //FSM - 12/05/11
Local nPos
//Private oUpdAtu //LRS - 20/10/2017 - Nopado
Private lValLC := .F. //LGS-04/07/2014
Private lCpoAcrDcr := AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") //NCF - 14/08/2015 - Tratamento Acresc./Decres./Multa/Juros/Desconto no controle de cambio SIGAEEC x SIGAFIN
Private lExcTitEET := .F.  // GFp - 19/08/2016
Private lFlagdue3   := AvFlags("DU-E3")
Private lAE100Auto := ValType(xAuto) == "A"
Private aAE100Auto := xAuto
Private lLiberaBloq := .F.
Private nTotEmbBr := 0
If lAe100Auto .And. Type("lMsErroAuto") <> "L"
    Private lMsErroAuto := .F.
EndIf
AvlSX3Buffer(.T.)//RMD - 08/12/17 - Melhoria de performance

// *** GFP - Tratamento para carga padrão da tabela EYG - 19/08/2011
/* // LRS - 20/10/2017 - Nopado, trecho movido para o UPDEEC
If FindFunction("AvUpdate01")
   oUpdAtu := AvUpdate01():New()
EndIf

If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
   If ChkFile("EYG")
      oUpdAtu:aChamados := {{nModulo,{|o| EDadosEYG(o)}}}
      oUpdAtu:Init(,.T.)
   EndIf
EndIf
// *** Fim GFP
*/

// by CAF 13/01/2005 - Abrir o EXB, na 8.11 o Protheus não abre os arquivos pelo menu.
dbSelectArea("EXB")
dbSelectArea("SYS")
IF SX2->(dbSeek("EXL"))
   dbSelectArea("EXL")
Endif
IF SX2->(dbSeek("EXM"))
   dbSelectArea("EXM")
Endif
IF SX2->(dbSeek("EES"))
   dbSelectArea("EES")
Endif
IF SX2->(dbSeek("EXP"))
   dbSelectArea("EXP")
Endif
IF SX2->(dbSeek("EXR"))
   dbSelectArea("EXR")
Endif

//Tabelas de Armazéns
IF SX2->(dbSeek("EY5"))
   dbSelectArea("EY5")
Endif
IF SX2->(dbSeek("EY7"))
   dbSelectArea("EY7")
Endif

dbSelectArea("EEF")

//Private lIntegra:=if(valtype(EasyGParam("MV_EECFAT"))=="L",EasyGParam("MV_EECFAT"),.F.)
Private lIntegra:=IsIntFat() // ** By JBJ 29/05/02

Private lInt := lIntegra // lIntegra nao cabia no x3_when do ee9_sldini

Private cFilSB1Aux  := xFilial("SB1"), lAbriuExp:= .F.
Private cTIPMEN:=TM_SIT,cIDCAPA

Private cCadastro:=AVTITCAD("EEC")//"Embarque"

// caf 25/03/2004
Private cWHENOD,cVIA,cWHENSA1,cWHENSA2,lMV0039,aMEMOITEM

Private bTotal := {|x| x := if(x=="SOMA",1,-1),;
                      M->EEC_PESLIQ += x*If(lConvUnid,AvTransUnid(IIF(!Empty(WorkIp->EE9_UNPES),WorkIp->EE9_UNPES,"KG"),If(!Empty(M->EEC_UNIDAD),M->EEC_UNIDAD,"KG"),WorkIp->EE9_COD_I,WorkIp->EE9_PSLQTO,.F.),WorkIp->EE9_PSLQTO),;
                      M->EEC_PESBRU += x*If(lConvUnid,AvTransUnid(IIF(!Empty(WorkIp->EE9_UNPES),WorkIp->EE9_UNPES,"KG"),If(!Empty(M->EEC_UNIDAD),M->EEC_UNIDAD,"KG"),WorkIp->EE9_COD_I,WorkIp->EE9_PSBRTO,.F.),WorkIp->EE9_PSBRTO),;
                      M->EEC_TOTPED += x*WorkIP->EE9_PRCINC,;
                      M->EEC_TOTITE += x*1,;
                      if(!ismemvar("lAutom") .OR. !lAutom,AE100TTela(.F.),)}
                      // Ae100PrecoI(.t.),; //MFR 27/05/2019 OSSME-3013 / OSSME-4778

Private aMemos := { {"EEC_CODMAR","EEC_MARCAC"},;
                    {"EEC_DSCGEN","EEC_GENERI"},;
                    {"EEC_CODMEM","EEC_OBS"},;
                    {"EEC_CODOBP","EEC_OBSPED"},;
                    {"EEC_INFGER","EEC_VMINGE"} } // GFP - 28/05/2014

Private lLibPes:= GetNewPar("MV_AVG0009",.F.)

Private aCampoPed:={}, aPITDELETADOS:={}, aPITPOS, lPITGRAVA, cNOMARQ, cNOMARQIP

Private aCAMPOPIT:={}

Private lSITUACAO:=.T.

Private oItens,oVlrTotSCob, oPedido, oLiquido, oBruto,oSayPesLiq,oSayPesBru,oSayVlrSCob, oTotEmbBr,cITEPIC:="@E 999,999,999,999",;
        cTPEPIC:=AVSX3("EEC_TOTPED",AV_PICTURE), cPLIPIC:=AVSX3("EEC_PESLIQ",AV_PICTURE),;
        cPBRPIC:=AVSX3("EEC_PESBRU",AV_PICTURE),cPESQDESP,aHDENCHOICE

Private aCamposEXL := {}
Private aCposStDUE := {}

Private cNomArq5 // Indice 2 para o WorkIP

//cria variaveis para Embalagens
Private cNOMARQ4

//Cria variaveis para Cambio
Private aITEMCAMBIO

//Cria variaveis para Itens processos
Private aITEMENCHOICE

//Cria variaveis para Registro documentos
Private aITEMREGDOC

//Cria variaveis para transito
Private aITEMTRANSITO

//Cria variaveis para faturamento
Private aITEMFATURA

// Cria variaveis para Depesas ...
Private aDeEnchoice, aDePos, aDeBrowse
Private cNomArq1, cNomArq1A, cNomArq1B, cNomArq1C//RMD - 24/02/20

// Cria variaveis para agentes/empresas
Private aAgEnchoice, aAgPos, aAgBrowse
Private cNomArq2

// Cria variaveis para instituicoes
Private aInEnchoice, aInPos, aInBrowse
Private cNomArq3

// Alterado por Heder M Oliveira - 8/13/1999
Private cCodImport := Space(AVSX3("EEC_IMPORT",AV_TAMANHO)) // Usado na funcao AE100IMPORT

// Cria variaveis para Notas Fiscais AWR Sexta Feira 13/08/1999
Private aNFDeletados:={}
Private cNomArq6

// Cria variaveis para Notify's.
Private aNoEnchoice, aNoPos, aNoBrowse
Private cNomArq7

Private lFilter := .T.  //TRP - 28/11/2011 - Variável criada para a Kaefer (088686), que será utilizada em rdmake para desabilitar os filtros da mBrowse.
Private cCodIt := ""  // GFP - 04/03/2013

// Cria variaveis para a agenda de atividades.
Private aDocBrowse, aDocDeletados:={}
Private cNomArq8, cNomArq82
Private cTPMODU := ""
Private lTemTPMODU
Private bTPMODUECF

Private aPreCalcBrowse, aPreCalcDeletados:={}
Private cNomArq9

//RMD - Verifica se possui tratamentos de consignação
Private lConsign := EECFlags("CONSIGNACAO")
If lConsign .And. !Type("cTipoProc") == "C"
   Private cTipoProc := PC_RG
EndIf

// ** AAF - 13/09/04 - Trata Back To Back ?
Private lBACKTO    := EasyGParam("MV_BACKTO",,.F.) .AND. ChkFile("EXK") ;
                      .AND. EE8->( FieldPos("EE8_INVPAG") > 0 ) .AND. EE9->( FieldPos("EE9_INVPAG") > 0  );
                      .And. (!lConsign .Or. cTipoProc $ PC_BN+PC_BC)
                      //RMD - 02/05/06 - Não inclui o tratamento de Back To Back no pedido regular quando estiver habilitada a rotina específica de Back to Back.

//Cria variáveis para uso nas funções do Drawback
Private lIntDraw := (!lConsign .OR. !lBackTo) .And. EasyGParam("MV_EEC_EDC",,.F.) .And. ( EasyGParam("MV_AVG0024",,"") != AvGetM0Fil() .Or. Empty( EasyGParam("MV_AVG0024",,"") ) )//PLB 07/02/06 - Verifica se existe a integração com o Módulo SIGAEDC e se está na filial de Off-Shore
Private lIntFina := EasyGParam("MV_EEC_EFF",,.F.) //Verifica se existe a integração com o Módulo SIGAEFF
SX3->(DBSETORDER(2))
Private lExistEDD   := SX3->(dbSeek("EDD_FILIAL"))  //GFC - 18/07/2003 - Drawback Anterioridade
Private lOkEE9_ATO  := SX3->(dbSeek("EE9_ATOCON"))
Private lYSTPMODU   := SX3->(DBSEEK("YS_TPMODU")) .AND. SX3->(DBSEEK("YS_MOEDA"))
Private lOkYS_PREEMB:= SX3->(dbSeek("YS_PREEMB")) .and. SX3->(dbSeek("YS_INVEXP"))
lTemTPMODU := SX3->(DbSeek("ECF_TPMODU"))

//RMD - 17/05/06
If lIntDraw .And. lConsign .And. cTipoProc $ PC_VR+PC_VB
   lIntDraw := .F.
EndIf

//Selecionar Pedido(Integrado com Faturamento - SIGAFAT) não Faturado.
Private lSelNotFat := EasyGParam("MV_AVG0067", .F., .F., xFilial("EE9")) .Or. (AvFlags("EEC_LOGIX") .And. cTipoProc $ PC_BN+PC_BC) //MCF - 19/07/2016


Private lNRotinaLC := .f.
//JPM - 23/12/04 - Define se é a nova rotina de Carta de Crédito
lNRotinaLC :=    (EEL->(FieldPos("EEL_SLDVNC")) # 0) ;
           .And. (EEL->(FieldPos("EEL_SLDEMB")) # 0) ;
           .And. (EEL->(FieldPos("EEL_RENOVA")) # 0)

//JPM - 01/02/05 - Define se é o tratamento de comissão com mais de um agente por item.
Private lTratComis := EasyGParam("MV_AVG0077",,.F.)

Private cOcorre := OC_EM

// By OMJ - 17/06/05 - Tratamento de Faturas
Private cArqCapInv
Private aInvEnchoice, aInvBrowse

Private cArqDetInv,cArq2DetInv
Private aDetInvBrowse
Private aDetInvEnchoice,aAltDetInv
Private aCInvDeletados := {}
Private aDInvDeletados := {}
Private lRefazRateio   := .F.

//Manutenção de OIC´s
Private aCapOICDel := {}
Private aDetOICDel := {}
Private aEXZBrowse := {}
Private aEY2Browse := {}
Private aSafras    := {}

//Bruno Akyo Kubagawa - 27 de Janeiro de 2011
//Verificar quebra por OIC e tratamento para marcação do OIC
Private lQuebraOIC := EasyGParam("MV_AVG0199",,.F.)
Private lMarcacao  := EasyGParam("MV_AVG0200",,.F.)
//TRP - 17/02/2009 - Variáveis para o controle de drawback sem cobertura cambial
Private lDrawSC := ChkFile("EDG")   //Verifica se a tabela para Draw Back sem cobertura cambial existe (EDG)
Private aDelEdg := {}
Private cArqDrawSC
//RMD - 09/05/06 - Tratamento de venda por consignação
Private cArqWkEY5, cArq2WkEY5, cArqWkEY6, cArqWkEY7, cArq2WkEY7
Private aEY7Deletados := {}

//TRP - 29/10/10 - Notas Fiscais dos Fabricantes
Private aEWIDel:= {}
Private cArqWkEWI
//Retorno do F3 nos Itens do Pedido
Private cRetF3BtB

Private cArqWkEYU, aCampoEYU, lItFabric := EasyGParam("MV_AVG0138",,.F.), aItFabPos, aEYUDel,nRegFabrIt  // By JPP - 14/11/2007 - 14:00

Private lIntEmb := EECFlags("INTEMB")
// PLB 21/06/07 - Verifica se o Drawback possui Multi-Filial
Private lMFilEDC  := VerSenha(115)  ;
                     .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                     .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                     .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                     .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                     .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                     .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                     .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                     .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
                     .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0

//FSM - 12/05/11
Private cSXBID    := IncSpace(cCodId+"-"+Tabela("ID",cCodId),AVSX3("EE4_IDIOMA",AV_TAMANHO),.f.)

Private nTotPesBru := 0, nPesBrEmb := 0   // GFP - 07/01/2014

Private lTotRodape := EEC->(FieldPos("EEC_TOTFOB")) # 0  .AND. EEC->(FieldPos("EEC_TOTLIQ")) # 0   // GFP - 11/04/2014

If Select("Header_p") = 0
   AbreEEC()
EndIf

If lTemTPMODU
   cTPMODU:='EXPORT'
   bTPMODUECF := {|| ECF->ECF_TPMODU = 'EXPORT' }
Else
   bTPMODUECF := {|| .T. }
EndIf

If lIntDraw
   If lExistEDD
      Private fWorkAnt, fWorkAnt2, fWorkAnt3, fWorkAnt4, fWorkAnt5
   EndIf
EndIf

SX3->(DBSETORDER(nOrderSX3))

Private cFilED3, cFilSA5:=xFilial("SA5"), cFilED0, cFilEE9:=xFilial("EE9"), cFilEDD, cFilED1, cFilED2
Private cFilEE8:=xFilial("EE8"), cFilSYS:=xFilial("SYS"), cFilEDE

// Flag para verificacao de intermediario na geracao do embarque...
Private lIntermed :=.f.

Private cItens:=""

Private lALTERA:=.T.

//RMD - 06/05/08 - Declarado lCambio como .F. para caso algum campo customizado para a fase de câmbio utilize esta variável na condição de when.
Private lCambio := .F.

// Flag para conversao de unidades ...
Private lConvUnid:=.f.

// Flag para tratamento de commodities ...
Private lCommodity:=.f. // ** By JBJ - 22/06/2002 - 17:36 ...

// ** By JBJ - 11/11/2002 - Flag para acionamento de Adiantamentos (pagamento antecipado).
Private lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)

// ** By JBJ - 06/12/2002 - Flag para teste nos gatilhos na manutencao de pagamento antecipado.
Private lIsEmb := .t.

// ** By JBJ - 29/10/2003 - Flag para habilitar botão de digitação dos dados do siscomex. (RE/SD/Ato concessório).
Private lDigDataSis := .f.

Private lRecriaPed := .f., lAtuFil := .f.

Private aEECCamposEditaveis := {}

/* Array de controle de dados importantes para os tratamentos de pré-calculo. Os valores que serão gravados
   no array, servirá para verificar qdo as despesas terão que se reapuradas. */
Private aDadosPreCalc := {}

Private cFilBr := "", cFilEx := ""

Private lB2BFat := IsProcNotFat()

Private bTiraMark := {|| WorkIP->WP_FLAG:="",;
                       If((lIntegra .Or. AvFlags("EEC_LOGIX") ) .and. !lB2BFat .and. !lSelNotFat, WorkIP->WP_SLDATU := WorkIP->EE9_SLDINI, WorkIP->WP_SLDATU += WorkIP->EE9_SLDINI ),; //ER - 03/12/2008. Apenas quando for integração com o Faturamento, sem a possibilidade de incluir Embarques sem Nota e em processos regulares que o saldo será copiado e não adicionado ao campo WP_SLDATU.
                       WORKIP->WP_OLDINI := WorkIP->EE9_SLDINI,;
                       WorkIP->EE9_SLDINI := 0,;
                       SubTotal(),;
                       WorkIP->EE9_PRCTOT := 0,;
                       WorkIP->EE9_PRCINC := 0,;
                       If(!lLibPes,WorkIP->EE9_PSLQTO := 0,),; // JPM - !lLibPes - 23/02/06 - Não zerar os pesos quando for digitação manual.
                       If(!lLibPes,WorkIP->EE9_PSBRTO := 0,),;
                       WorkIP->EE9_QTDEM1 := 0,;
                       AEAntMarca(3), AE108VlMark(.F.) }
                      

// ** JPM - 03/03/05 - Define se haverão os novos tratamentos de alteração de valores após o embarque.
Private lAltValPosEmb := EasyGParam("MV_AVG0081",,.f.)

// ** JPM - 09/03/05 - Habilita os novos tratamentos de multi Off-Shore
Private lMultiOffShore := EasyGParam("MV_AVG0083",,.f.) .And. EEC->(FieldPos("EEC_NIOFFS")) > 0;
                                                   .And. EEC->(FieldPos("EEC_CLIENF")) > 0;
                                                   .And. EEC->(FieldPos("EEC_CLOJAF")) > 0


/* By JBJ - 24/02/2005 - Flag para habilitar/desabilitar a rotina de
                         levantamento de campos e replicação de dados na filial de off-shore. */
Private lReplicaDados := EasyGParam("MV_AVG0079",,.f.)

Private aProdComDif:={}

//JPM - variável que define se é uma replicacao de processo - Novos tratamentos de Multi Off-Shore
Private lReplicacao := .f.

// ** Variáveis utilizadas na função de replicação de dados.
Private cArqMain, cArqMain2, cArqMain3, cArqMain4

// By JPP - 08/02/2006 - 10:50 - Arquivo temporário utilizado na validação e controle de adiantamentos.
Private cArqAdiant

//ER - 13/11/2008.
Private lNfRemessa:= AvFlags("FIM_ESPECIFICO_EXP")
Private aNfRemDeletados := {}, aSaldoNFE:= {}
Private cArqNFRem, cArq2NFRem, cArq3NFRem//RMD - 07/02/17 - Não estava declarando os arquivos dos índices, impossibilitando a exclusão

If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-30/10/2015
   aaDD(aMemos,{"EEC_INFCOF","EEC_VMDCOF"})
EndIf

/* JPM - 22/09/05 - Substituído por função genérica
// ** By JBJ - 22/06/2002 - 17:38 ...
cAVG0034 := EasyGParam("MV_AVG0034",,"")
cAVG0034 := IF(ALLTRIM(cAVG0034)=".","",cAVG0034)
If EasyGParam("MV_AVG0029",,.F.) .And. !Empty(cAVG0034)
   lCommodity:=.t.
EndIf
*/

lCommodity := EECFlags("COMMODITY")
if lReplicaDados .and. lCommodity .and. lMultiOffShore .and. !EECFlags("COMMODITY_OPCIONAL")
   Easyhelp('Para o correto funcionamento do sistema é necessário desligar o parâmetro de replicação MV_AVG0079 ou o de commodities MV_AVG0029',STR0063)
   Return .F.
endif

// ** By JBJ - 14/06/2002 - 15:35 ...
If (EEC->(FieldPos("EEC_UNIDAD")) # 0) .And. (EE9->(FieldPos("EE9_UNPES")) # 0) .And.;
   (EE9->(FieldPos("EE9_UNPRC")) # 0)
   lConvUnid :=.t.
EndIf

/* JPM - 22/09/05 - Substituído por função genérica (Inclusive joga o conteúdo das variáveis cFilBr e cFilEx
cFilBr := EasyGParam("MV_AVG0023",,"")
cFilBr := IF(ALLTRIM(cFilBr)=".","",cFilBr)
cFilEx := EasyGParam("MV_AVG0024",,"")
cFilEx := IF(ALLTRIM(cFilEx)=".","",cFilEx)
If !Empty(cFilBr) .And. !Empty(cFilEx) .And.;
      (EEC->(FieldPos("EEC_INTERM")) # 0) .And. (EEC->(FieldPos("EEC_COND2")) # 0) .And.;
      (EEC->(FieldPos("EEC_DIAS2")) # 0) .And. (EEC->(FieldPos("EEC_INCO2")) # 0) .And.;
      (EEC->(FieldPos("EEC_PERC")) # 0)
   lIntermed := .T.
EndIf
*/
lIntermed := EECFlags("INTERMED")

// ** JPM - 20/10/05 - variáveis referentes à rotina de controle de quantidades entre filiais Brasil e Off-Shore
If EECFlags("INTERMED")  // If EECFlags("CONTROL_QTD")  // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
   Private aConsolida := {}
   Ap104KeyX3(aConsolida) // acerta tamanho

   // Campos da work de agrupamento e da msselect
   Private aGrpCpos  := {"WP_FLAG",;
                         "EE9_PEDIDO","EE9_ORIGEM","EE9_COD_I" ,"EE9_VM_DES",;
                         "EE9_FORN"  ,"EE9_FOLOJA","EE9_FABR"  ,"EE9_FALOJA",;
                         "EE9_PART_N","EE9_PRECO" ,"EE9_UNIDAD","EE9_SLDINI",;
                         "EE9_PRCTOT","EE9_PRCINC","EE9_PSLQUN","EE9_PSLQTO",;
                         "EE9_EMBAL1","EE9_QTDEM1","EE9_QE"    ,"EE9_PSBRUN",;
                         "EE9_PSBRTO","WP_SLDATU"}
   Ap104KeyX3(aGrpCpos) // acerta tamanho

   // Informações referentes aos campos acima. "S" - Sempre igual, "N" - Não é sempre igual, "T" - Totaliza
   // Obs.: para cada posição do aGrpCpos, deve ter uma posição correspondente no aGrpInfo
   Private aGrpInfo  := {"S",;
                         "S","S","S","S",; // "S","S","S","N",; // By JPP - 06/11/2006 - 14:40 - Para o campo EE9_VM_DES as informações devem ser sempre iguais para todo o grupo. Se for "N" o campo não aparece na enchoice.
                         "S","S","S","S",;
                         "S","N","S","T",;
                         "T","T","S","T",;
                         "S","T","S","S",;
                         "T","T"}

   Private bConsolida, cGrpFilter, cConsolida := Ap104StrCpos(aConsolida)// variáveis para filtro
   Private b2Consolida, c2GrpFilter // filtro da filial oposta

   ASize(aGrpCpos,Len(aGrpCpos)+Len(aConsolida)) //redimensiona para colocar os campos do aConsolida.
   ASize(aGrpInfo,Len(aGrpCpos))
   For i := 1 To Len(aConsolida)
      If (nPos := AScan(aGrpCpos,aConsolida[i])) > 0
         aGrpInfo[nPos] := "S"
         ASize(aGrpCpos,Len(aGrpCpos)-1)
         ASize(aGrpInfo,Len(aGrpCpos))
      Else
         AIns(aGrpCpos,i+4)
         aGrpCpos[i+4] := aConsolida[i]
         AIns(aGrpInfo,i+4)
         aGrpInfo[i+4] := "S" // sempre igual
      EndIf
   Next
EndIf

Private cNomArqGrp, cNomArqOpos // arquivos das works WorkGrp(agrupamentos) e WorkOpos(Itens da filial oposta)
Private aGrpBrowse

If EECFLAGS("CAFE")
   Private cEmpOIC, cComplOic // By JPP - 03/01/2005 10:40
EndIF

Private cWorkArmazem // Manutenção de Armazéns
Private cArqCapOIC, cArqDetOIC, cArq2CapOIC, cArq2DetOIC//Nome dos arquivos das works usadas na manutenção de OIC´s

Private cFilAtu  := xFilial("EEC")
Private lFilBr   := cFilAtu == cFilBr
Private cFilOpos := If(lFilBr,cFilEx,cFilBr)
Private lFilEx   := !lFilBr

// ** By JPP - 14/03/2007 - Desabilita/Habilita mensagem(opção) para eliminar saldo de pedidos embarcados parcialmente.
Private lMsgZeraSaldo := EasyGParam("MV_AVG0136",,.F.)

Private aRotina := MenuDef(If(cTipoProc == PC_RG, "EECAE100", ProcName(1)), .T.)
//RMD - 17/08/12 - Cria backup do aRotina por conta de problemas em builds específicos
Private __BkpAROT := aClone(aRotina)

// ** By JBJ - 29/10/2003 - Flag para habilitar botão de digitação dos dados do siscomex. (RE/SD/Ato concessório).

Private lGrade := AvFlags("GRADE")

lDigDataSis := !lIntDraw//EasyGParam("MV_AVG0054",,.f.)

If lIntDraw .and. lOkEE9_ATO
   cFilED3 := xFilial("ED3")
   cFilED0 := xFilial("ED0")
   cFilED1 := xFilial("ED1")
   cFilED2 := xFilial("ED2")
   ED2->(dbSetOrder(2))
   ED0->(dbSetOrder(2))
   ED1->(dbSetOrder(1))
   If lExistEDD
      cFilEDD := xFilial("EDD")
      cFilEDE := xFilial("EDE")
   EndIf
EndIf
lMV0039 := EasyGParam("MV_AVG0039",,.F.)

// CAMPO MEMO DOS ITENS
aMEMOITEM := {{"EE9_DESC","EE9_VM_DES"}}

If EECFlags("AMOSTRA")
   aAdd(aMEMOITEM,{"EE9_QUADES","EE9_DSCQUA"})
EndIf

If EECFlags("INTTRA")
   aAdd(aMemoItem, {"EE9_DINTCD", "EE9_DINT"})
EndIf

//AOM - 26/04/2011 - Operação Especial
Private lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL")

//RMD - 11/04/14
Private lLeadTime := SB1->(FieldPos("B1_LEADTI")) > 0 .AND. EDC->(FieldPos("EDC_LEADTI")) > 0 .and.;
             SB1->(FieldPos("B1_PRODUC")) > 0 .AND. EDC->(FieldPos("EDC_PRODUC")) > 0 .and.;
             EasyGParam("MV_AVG0184",.F.,.F.)

// ** Cria arquivos temporários
If !lAE100Auto
    MsAguarde({||AE102CriaWork()},STR0017)
Else
   AE102CriaWork()
EndIf

If Type("EEC->EEC_TSISC") <> "U" // FJH 13/10/05 Adicionando campo EEC_TSISC
   aAdd(aEECCamposEditaveis,"EEC_TSISC")
   aAdd(aHdEnchoice,"EEC_TSISC")
Endif

//GFP - 07/01/2014
If EasyGParam("MV_EEC0037",,.F.)
   aAdd(aEECCamposEditaveis,"EEC_QTDEMB")
   aAdd(aHdEnchoice,"EEC_QTDEMB")
EndIf

If EEC->(FieldPos("EEC_DESSEG")) > 0 //LRS 11/09/2015
   aAdd(aEECCamposEditaveis,"EEC_DESSEG")
   aAdd(aHdEnchoice,"EEC_DESSEG")
EndIf

If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-12/11/2015
   aAdd(aEECCamposEditaveis,"EEC_VMDCOF")
   aAdd(aHdEnchoice,"EEC_VMDCOF")
EndIf

/*
Rotina para incluir no aEECCamposEditaveis os campos de usuário.
Autor: Alexsander Martins dos Santos
Data e Hora: 13/08/2004 às 17:20
*/

If EasyEntryPoint("EECAE100")
   ExecBlock("EECAE100",.F.,.F.,{ "ALTERA_FILTRO" })
Endif

Begin Sequence
// Verifica se o Modulo ativo eh o SIGAEEC ou SIGAEDC
   IF ! AmIin(29,50)
      Help(" ",1,"AVG0000624") // ("Função não autorizada para este módulo !","Aviso")
      Break
   Endif

   IF EasyEntryPoint("EECPEM42")
      If ! ExecBlock("EECPEM42",.F.,.F.,"EMBARQUE")
         Break
      Endif
   Endif
   If lConsign
      If cTipoProc == PC_BN
         cCadastro := STR0152//"Embarque de Back To Back Regular"
      ElseIf cTipoProc == PC_RC
         cCadastro := STR0153 //"Embarque de Remessa por Consignação"
      ElseIf cTipoProc == PC_BC
         cCadastro := STR0154//"Embarque de Remessa por Consignação com Back To Back"
      ElseIf cTipoProc == PC_VR
         cCadastro := STR0155//"Embarque de Venda por Consignação"
      ElseIf cTipoProc == PC_VB
         cCadastro := STR0156//"Embarque de Venda por Consignação com Back To Back"
      ElseIf cTipoProc == PC_CF
         cCadastro := STR0202 //STR0202	"Embarque de Exportação de Café"
      ElseIf cTipoProc == PC_CM
         cCadastro := STR0203 //STR0203	"Embarque de Exportação de Açúcar"
      EndIf
   EndIf
  /*
   EECFilterProc("EEC", If(Type("cTipoProc") == "C", cTipoProc, Nil))
   // ** By JBJ - 10/11/03  - 11:12.
   SetMbrowse(cAlias)
   // mBrowse( 6, 1,22,75,cAlias)
   EE7->(DbClearFilter())
  */

   //FSM - 02/08/2012
   If EECFlags("TIT_PARCELAS")
      bSetKey:=SetKey(VK_F11)
      SetKey(VK_F11,{|| AE100F11() })
   EndIf

     //LRS - 21/10/2016 - verificação dos tamanho do campo EEQ_PARC e EEQ_PARVIN, caso for diferente, não abrir o Embarque
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek("EEQ_PARC"))
	   nParc := SX3->X3_TAMANHO
	EndIF

	If SX3->(DbSeek("EEQ_PARVIN"))
	   nParvin := SX3->X3_TAMANHO
	EndIF

	If SX3->(DbSeek("EEQ_PAOR"))
	   nPaor := SX3->X3_TAMANHO
	EndIF

	IF (nParvin <> nParc .OR. nPaor <> nParc).AND. EasyGParam("MV_AVG0131",,.F.)
	   EasyHelp(STR0250+ cValToChar(nParvin)+ " "+STR0252+ cValToChar(nPaor)+ " " +STR0251+ cValToChar(nParc) ,STR0035) //Foi encontrado um problema com o dicionário da dados . Para acessar essa rotina o campo Nro.Parc.Vin (EEQ_PARVIN) Tamanho : deve possuir o mesmo tamanho do campo Nro. Parcela(EEQ_PARC) Tamanho :.
	   Break
	EndIF

   If lAE100Auto//RMD - 26/10/17 - Trata o MsExecAuto
      //Verifica se foram enviados dados da capa do embarque
      If (nPos := aScan(aAE100Auto, {|x| x[1] == "EEC" })) > 0
         AvKeyAuto(aAE100Auto[nPos][2])
         //Valida se foi enviado um proceso de OffShore. Estes processos não serão atendidos pela integração via ExecAuto
         If EECFlags("INTERMED") .And. (nCpo := aScan(aAe100Auto[nPos][2], {|x| x[1] = "EEC_INTERM" })) > 0 .And. aAe100Auto[nPos][2][nCpo][2] == "1"
            Easyhelp(STR0255, STR0063) //"A rotina automática não está disponível para processos de Intermediação"###"Aviso"
            lMsErroAuto := .T.
         //Verifica se o tipo de processo é igual a regular. Se não for bloqueia a integração via ExecAuto
         ElseIf cTipoProc <> PC_RG
            Easyhelp(STR0256, STR0063) //"A rotina automática somente está disponível para processos do tipo regular."###"Aviso"
            lMsErroAuto := .T.
         Else
            //Verifica se foi informada alguma rotina complementar para execução
            If ValType(cOpcComp) == "C"
                //Busca a rotina complementar no aRotina (Menudef) e identifica a posição no array
                If (nOpcBrowse := aScan(aRotina, {|x| Upper(x[2]) == Upper(cOpcComp) })) > 0
                    If EasySeekAuto("EEC", aAE100Auto[nPos][2], 1)//A função MBrowseAuto não posiciona automaticamente o registro quando a opção é diferente de 4 ou 5
                        //Executa a rotina complementar via MBrowseAuto
                        MBrowseAuto(nOpcBrowse, aAE100Auto[nPos][2], "EEC",, .T.)
                    Else
                        EasyHelp(STR0257, STR0063) //"O embarque informado não foi localizado"###"Aviso"
                        lMsErroAuto := .T.
                    EndIf
                Else
                    EasyHelp(StrTran(STR0258, "XXX", cOpcComp), STR0063) //"A rotina complementar informada ('XXX') não foi localizada."###"Aviso"
                    lMsErroAuto := .T.
                EndIf
            Else
                //Executa a manutenção automática
                MBrowseAuto(nOpcBrowse, aAE100Auto[nPos][2], "EEC",, .T.)
            EndIf
         EndIf
      EndIf

   ElseIf ValType(nOpcBrowse) == "N" .AND. ValType(nRecEEC) == "N" .AND.;
      nOpcBrowse <= Len(aRotina) .AND. EEC->(dbGoTo(nRecEEC),!EoF())
      Private inclui:=.F.
      Private altera:=.F.
      Eval(&("{|| "+aRotina[nOpcBrowse][2]+"('EEC',EEC->(RecNo()),"+Str(nOpcBrowse)+")}"))
   Else
      // ** PLB 03/08/07 - Quando for TOP o filtro será utilizado como parâmetro do MBrowse, a tabela NÂO será filtrada com DBSetFilter()
      If lFilter
         cExpFilter := EECFilterProc("EEC", If(Type("cTipoProc") == "C", cTipoProc, Nil), , .T. )
         SetMbrowse(cAlias,cExpFilter)
         EEC->( DBClearFilter() )
      Else
         SetMbrowse(cAlias)
      Endif
      // **
   EndIf

End Sequence

// Abre novamente o arquivo de SB1(Itens)-Importação caso tenha sido aberto o SB1(Produtos)-Exportacao
If nModulo == 50                 // Verifica se esta no SIGAEDC
   If lAbriuExp
      FechaArqExp("SB1",.T.)
   Endif
EndIf

// ** Apaga os arquivos temporários
E_RESET_AREA

If( EasyEntryPoint("EECAE100") , ExecBlock("EECAE100",.F.,.F.,{"FINAL"}) , )

If lIntDraw .and. lOkEE9_ATO
   ED2->(dbSetOrder(1))
   ED0->(dbSetOrder(1))
EndIf

//FSM - 02/08/2012
If EECFlags("TIT_PARCELAS")
   SetKey(VK_F11,bSetKey)
EndIf

//DFS - 21/07/12 - Para conter os parametros de configurações financeiros na rotina de cambio de exportacão
If IsIntEnable("001")
	SetKey (VK_F12,{|a,b| AF201PergFin()})  //MCF - 18/09/2014
EndIf

dbSelectArea(cOldArea)

AvlSX3Buffer(.F.)//RMD - 08/12/17 - Melhoria de performance
Return lRet

/*
Funcao     : MenuDef()
Parametros : cOrigem, lMBrowse
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 05/02/07 - 15:16
*/

Static Function MenuDef(cOrigem, lMBrowse)
Local aRotAdic := {}
Local aExcCanc := {{ STR0005, "AE100CANCE", 0, 5}, { STR0270, "AE100MAN", 0, 5}}//"Cancelar" ### "Excluir"
Local aRotina  := { { STR0001, "AxPesqui" , 0 , 1},;  //"Pesquisar "
                    { STR0002, "AE100MAN" , 0 , 2},;  //"Visualizar"
                    { STR0003, "AE100MAN" , 0 , 3},;  //"Incluir   "
                    { STR0004, "AE100MAN" , 0 , 4},;  //"Alterar   "
                    { STR0005, "AE100MAN" , 0 , 4/*,3*/}} //"Cancelar  "  // DFS - Alteração do numero, para posicionar no registro cancelado //LRS - 28/08/2017

//Default lMBrowse := .F. - Nopado pois é necessário retornar todas as opções da rotina. Apenas o menufuncional não pode exibi-las (funcao GETMENUDEF é do menu funcional).
Default lMBrowse := OrigChamada()
Default cOrigem  := AvMnuFnc()

Begin Sequence

//RMD - 19/06/19 - Separa as opções de cancelar e excluir em um submenu, se não for ExecAuto (Neste caso mantém o modelo anterior)
If !(IsMemVar("lAE100Auto") .And. lAE100Auto)
   aRotina[5] :=  {STR0005+"/"+STR0270, aExcCanc, 0 , 5} //"Alterar/Excluir"
EndIf

//LRS - 23/05/2017 - variaveis necessarias para o MenuDef Rodar sem erro log, quando chamado do SigaCFG

IF lMBrowse
    IF(Type("cFilSB1Aux")   == "U", cFilSB1Aux := xFilial("SB1") , cFilSB1Aux ) // mpg - 17/01/2018 - incluído variavel que não retorne error log se chamado por outro menu
    IF(Type("lConsign")     == "U", lConsign  :=EECFlags("CONSIGNACAO"), )
    IF(Type("cFilEx")       == "U", cFilEx    := EasyGParam("MV_AVG0024",,""), )
    IF(Type("cTipoProc")    == "U", cTipoProc := IF(Type("cTipoProc") <> "C"," ",cTipoProc), )
    IF(Type("lCommodity")   == "U", lCommodity := EECFlags("COMMODITY") , )
    IF(Type("lIntermed")    == "U", lIntermed  := EECFlags("INTERMED") , )

    IF(Type("lBACKTO")      == "U", lBACKTO   := EasyGParam("MV_BACKTO",,.F.)    .AND. ChkFile("EXK") ;
                                                                            .AND. EE8->( FieldPos("EE8_INVPAG") > 0 );
                                                                            .AND. EE9->( FieldPos("EE9_INVPAG") > 0  );
                                                                            .And. (!lConsign .Or. cTipoProc $ PC_BN+PC_BC) , )

    IF(Type("lIntDraw")     == "U", lIntDraw  := (!lConsign .OR. !lBackTo)  .And. EasyGParam("MV_EEC_EDC",,.F.);
                                                                            .And. ( EasyGParam("MV_AVG0024",,"") != AvGetM0Fil();
                                                                            .Or. Empty( EasyGParam("MV_AVG0024",,"") ) ) , )

    IF(Type("lMultiOffShore")== "U", lMultiOffShore := EasyGParam("MV_AVG0083",,.f.) .And. EEC->(FieldPos("EEC_NIOFFS")) > 0;
                                                                                .And. EEC->(FieldPos("EEC_CLIENF")) > 0;
                                                                                .And. EEC->(FieldPos("EEC_CLOJAF")) > 0 , )
EndIF
   
   //RMD - 19/06/19 - Caso for Logix adiciona a opção de cancelamento por devolução no submenu
   If lMBrowse .And. AVFLAGS("EEC_LOGIX") .And. EES->(FieldPos("EES_QTDDEV")) > 0 .and. EES->(FieldPos("EES_VALDEV")) > 0 .And. EES->(FieldPos("EES_QTDORI")) > 0
      aExcCanc := {{ STR0005, "AE100CANCE", 0, 5}, { STR0271, "AE100DEV", 0, 5}, { STR0270, "AE100MAN", 0, 5}} //"Cancelar por Devolução" ### "Excluir"
      aRotina[5][2] := aExcCanc
   EndIf

   If lMBrowse .And. !EECFlags("ESTUFAGEM")
      aAdd(aRotina, {STR0151,"EECAE104",0,4}) //"Container/Lotes"
   EndIf

   // Verifica se esta no SIGAEDC
   If lMBrowse .And. nModulo == 50
      lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"  ")),cFilSB1Aux) // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
      If lAbriuExp
         cFilSB1Aux   := If(Empty(ALLTRIM(GETNEWPAR("MV_FILEXP","  "))), Space(02), ALLTRIM(GETNEWPAR("MV_FILEXP","  ")))
         aRotina := { { STR0001, "AxPesqui" , 0 , 1},;  //"Pesquisar "
                      { STR0002, "AE100MAN" , 0 , 2}}   //"Visualizar"
      Endif
   EndIf

   If lMBrowse .And. lIntDraw
      aAdd(aRotina,{ STR0124, "AE100ESTAC", 0 , 6}) //"Estornar Ato"
   EndIf

   If EasyGParam("MV_AVG0039",,.f.)
      aAdd(aRotina,{STR0118,"AE100Adian",0,4})  //"Adiantamentos"
                                                ////DFS - Alteração de 8 para 4, para que posicione no registro correto
   EndIf

   If EasyGParam("MV_AVG0041",,.F.)
      aAdd(aRotina,{STR0119,"EECLO100",0,2})  //"Lotes"
   EndIf

   If lMBrowse .And. lIntermed .And. lCommodity
      //DFS - 20/09/2010 - Nopado para que o sistema faça de acordo com a novo tratamento de commodities feito pelo governo, onde não é obrigado a confecção de RV.
      //If (xFilial("EEC") == cFilEx) //AvKey(EasyGParam("MV_AVG0024"),"EEC_FILIAL"))
      // ** Disponibiliza a opção de fixação de preço no embarque somente na filial de off-shore.
      aAdd(aRotina,{STR0128,"AE105FixPrice",0,7}) //"Fixação Preço"
      //EndIf
   EndIf

   If lMBrowse .And. EECFlags("CAFE")
      //RMD - 07/05/08 - Deve ser informado "1" na quarta posição, indicando pesquisa, caso contrário a mBrowse reposiciona a tabela no final da execução.
      //aAdd(aRotina,{STR0159,"AE108BuscaOic",0,7}) //"Pesquisa por OIC"
      //aAdd(aRotina,{STR0159,"AE108BuscaOic",0,1}) //"Pesquisa por OIC"
      aAdd(aRotina,{STR0204,"AE108BuscaOic",0,1}) //"Pesquisa por OIC" //DFS - Alteração para que o atalho funcione corretamente (ALT + E) //STR0204	"Pesquisa por OIC"
   EndIf

   If lMBrowse .And. lMultiOffShore .And. (xFilial("EEC") == cFilEx)
      aAdd(aRotina,{STR0205,"AE108MultiOff",0,4}) //STR0205	"Repl. Embarque"
   EndIf

   If lMBrowse .And. EECFlags("ESTUFAGEM")
      aAdd(aRotina,{STR0206,"AE110ESTUF",0,4})//STR0206	"Estufagem"
      aAdd(aRotina,{STR0248,"AE110BuscaCont",0,1}) //RMD - 17/10/14 - Busca por container "Busca Containers"
   EndIf

   If lMBrowse .And. EECFlags("INTTRA")
      aAdd(aRotina,{STR0207,"AVFRM101",0,4}) //STR0207	"IMonitor"
      aAdd(aRotina,{STR0208,"AE110HISTPROC",0,4}) //STR0208	"Histórico"
      aAdd(aRotina,{STR0209,"EICY0100",0,4}) //STR0209	"Hist. de Documentos"
   EndIf

   aADD(aRotina,{ STR0210, "MsDocument", 0, 4 } ) //STR0210	"Conhecimento"

   //Integração Itaú por carta remessa eletronica, FRS - 04/12/09
   /* WFS 26/07/2010 - implementada a chamada de menu.
   If lMBrowse .And. AvFlags("INTITAU")
      aAdd(aRotina, {"Carta Remessa", "EI200INTITAU()", 0, 7})
   EndIf*/

   //NCF - 03/05/2017 - Geração da D.U-E (Declaração Unica de Exportação)
   If lMBrowse .And. AvFlags("DU-E")
        If AvFlags("DU-E3")
            aRotDue := { { "Gerar Declaração"  , "EECDU400()", 0, 7} ,; // TRANSFORMADO EM SUB MENU E ADCIONADO ROTINAS
                         { "Gerar DUE em Lote" , "EECDU200()", 0, 7} ,;
                         { "Trans DUE em Lote" , "EECDU300()", 0, 7} ,;
                         { "Transmissão DUE"   , "EECDU100()", 0, 7} }// MPG - 27/03/2018
            If AvFlags("STATUS_DUE")
               aAdd( aRotDue, { STR0279  , "EECDU101()", 0, 7} )  //NCF - 07/10/2020 - "Consultar Status"
            EndIF
                        
            aAdd(aRotina, {STR0253, aRotDue , 0, 0}) //"Declaração Unica de Exportação"
        Else
            aAdd(aRotina, {STR0253, "EECDU400()" , 0, 0}) //"Declaração Unica de Exportação"
        endif
   EndIf
   
   //MPG - 19/08/2019 - OSSME-2810 - embarque em lote
   aAdd(aRotina,{"Embarque em Lote","EECAE114",0,2})  //"Embarqu em Lotes"
   
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   Do Case

      Case Upper(cOrigem) $ "EECAE100" //Processo de Exportação
           If EasyEntryPoint("EAE100MNU")
	          aRotAdic := ExecBlock("EAE100MNU",.f.,.f.)
           EndIf

      Case Upper(cOrigem) $ "AE100B2BREG" //Processo de Exportação com Back to Back
           If EasyEntryPoint("EB2BEMNU")
	          aRotAdic := ExecBlock("EB2BEMNU",.f.,.f.)
           EndIf

      Case Upper(cOrigem) $ "AE100REMCONSIG" //Embarques de Consignação do Tipo Remessa
           If EasyEntryPoint("EB2BRCEMNU")
	          aRotAdic := ExecBlock("EB2BRCEMNU",.f.,.f.)
           EndIf

      Case Upper(cOrigem) $ "AE100B2BCONSIG" //Embarques de Remessa de Consignação com Back to Back
           If EasyEntryPoint("EB2BCEMNU")
	          aRotAdic := ExecBlock("EB2BCEMNU",.f.,.f.)
           EndIf

      Case Upper(cOrigem) $ "AE100VENDREG" //Embarques de Consignação do Tipo Venda Regular
           If EasyEntryPoint("EAE100VMNU")
	          aRotAdic := ExecBlock("EAE100VMNU",.f.,.f.)
           EndIf

      Case Upper(cOrigem) $ "AE100VENDB2B" //Embarques de Consignação do Tipo Venda com Back To Back
           If EasyEntryPoint("EAE100VCMNU")
	          aRotAdic := ExecBlock("EAE100VCMNU",.f.,.f.)
           EndIf
   End Case

	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf

End Sequence

Return aRotina

/*
Funcao      : AE100B2BReg()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manutenção de embarques de back to back regular.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*---------------------*
Function AE100B2BReg()
*---------------------*
Private cTipoProc := PC_BN
Return EECAE100()

/*
Funcao      : AE100RemConsig()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manutenção de embarque para Embarques de Consignação do Tipo Remessa
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*------------------------*
Function AE100RemConsig()
*------------------------*
Private cTipoProc := PC_RC
Return EECAE100()

/*
Funcao      : AP100B2BConsig()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manutenção de embarques de Remessa de Consignação com Back to Back.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*------------------------*
Function AE100B2BConsig()
*------------------------*
Private cTipoProc := PC_BC
Return EECAE100()

/*
Funcao      : AP100VendReg()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manutenção de embarque para embarques de Consignação do Tipo Venda Regular
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*----------------------*
Function AE100VendReg()
*----------------------*
Private cTipoProc := PC_VR
Return EECAE100()

/*
Funcao      : AP100VendB2B()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manutenção de embarque para embarques de Consignação do Tipo Venda com Back To Back
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*----------------------*
Function AE100VendB2B()
*----------------------*
Private cTipoProc := PC_VB
Return EECAE100()

/*
Funcao      : AE100CAFE()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manutenção de embarque para embarques de Exportação de Café
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 26/05/08
*/
*----------------------*
Function AE100Cafe()
*----------------------*
Private cTipoProc := PC_CF
Return EECAE100()

/*
Funcao      : AE100COMM()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manutenção de embarque para embarques de Exportação de commodities
Autor       : Igor de Araújo Chiba
Data/Hora   :  12/06/2008
*/
*----------------------*
Function AE100COMM()
*----------------------*
Private cTipoProc := PC_CM
Return EECAE100()

/*
Funcao      : AE100MAN(cAlias,nReg,nOpc )
Parametros  : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida
Retorno     : .T.
Objetivos   : Executar enchoice
Autor       : Heder M Oliveira
Data/Hora   : 26/01/98 15:20
Revisao     : Jeferson Barros Jr - 24/07/01 13:46 - Melhoria no desempenho da manutenção de processos.
Obs.        :
*/
*----------------------------------
Function AE100MAN(cAlias,nReg,nOpc)
*----------------------------------

Local lRet:=.T.,cOldArea:=select(), i
Local lGravaOk, lOK:=.T.
Local aAltera
Local aPos
Local oDlg
Local aOrd:=SaveOrd("EEC")
Local aDespInt := X3DIReturn()
Local bCancel := {|| IF(nOpc == VISUALIZAR .Or. nOpc == EXCLUIR .Or. MsgYesNo(STR0164,STR0063),(nOpcA:=0,oDlg:End()),) } //"Confirma cancelar entrada de dados ?"LRL 07/03/05 //STR0063  "Aviso"
Local lInverte := .f.
Local nOrdemSX3 := SX3->(IndexOrd()), nInc:=0
Local lGRV := .T.  //LRL 08/12/2003 - Premite a gravação
Local cFolder, nRecAux := 0
Local aEnchoiceAux := aClone(aItemEnchoice), j:=0, aDelItem:={}, aDelCapa:={}
Local aHdEnchAux   := aClone(aHdEnchoice)
Local aAuxOrd
Local lRetPto      := .T.
Local aGrp
Local aBackupEdit
Local cChave := "" //CRF
Local dDtFim
Local cStEmb := ""
Local cDescStEmb := ""
Local lEaiBuffer := .F.
Local lDtEmbAux := .F. //TRP - 09/03/2015 - Variável auxiliar
//RRC - Integração SIGAEEC x SIGAESS (Despesas Internacionais)
Local lEECESS := EasyGParam("MV_ESS0014",,.T.) .And. AvFlags("CONTROLE_SERVICOS_AQUISICAO") .And. EXL->(FieldPos("EXL_NBSFR")) > 0 .And. EXL->(FieldPos("EXL_NBSSE")) > 0 .And. EXL->(FieldPos("EXL_NBSFA")) > 0
Local nForAuto
Local lStatusDUE := nOpc <> INCLUIR .And. AvFlags("STATUS_DUE") .And. AvExisteFunc({"DU101SqEK0"}) //NCF - 16/10/2020
Local aGetsEKK, aColsEKK, aCordPnDUE, aCordGdDUE, aCordBtDUE
Local cClearArr := "Eval({|| aSize(aCordPnDUE,0) , aSize(aCordGdDUE,0) })"

//RMD - 19/06/2019 - Verifica qual das sub-operações de exclusão está sendo executada e recarrega o aRotina com o array principal (quando existe um submenu o aRotina é enviado somente com o submenu para a manutenção)
If aRotina[nOpc][4] == 5
   nOpc := 5
   If !IsMemVar("lAE100CANCE")
      lAE100CANCE := .F.
   EndIf
   If !IsMemVar("lAE100DEV")
      lAE100DEV := .F.
   EndIf
   aRotina := Menudef()
EndIf

Private lPedAdia := .F.
Private lCliAdia := .F.
Private cEvDtEmba := ""
Private dDtEmbarque
Private oMacroCapa //CRF
Private oMacroDet //CRF
Private lEECMarks:= .T. //TRP - 05/12/2011 - Variável utilizada em rdmake para desabilitar a Pergunta referente a sobreposição da Marcação.
Private lMensaAg := .F., lTemAgente := .F.
Private lOkFinal:= .F. //MCF - 21/12/2015
Private cRetifiDUE:= "0" //THTS - 14/05/2018 - Utilizada para validacao da DUE. Controla se o processo precisara de retificacao ou nao (0=DUE OK; 1=Exclui DUE gerada; 2=Marca DUE para Retificar);

Ap100InitFil()

Private aInterm
Private nOpcA:=0

Private aEncOffShore

If Type("aDadosOffShore") = "A"
   lReplicacao := .t.
Else
   lReplicacao := .f.
EndIf

//define se é um processo replicado
Private lProcReplicado

If lReplicacao .Or. (nOpc <> INCLUIR .And. lMultiOffShore .And. !Empty(EEC->EEC_NIOFFS))
   lProcReplicado := .t.
Else
   lProcReplicado := .f.
EndIf

Private lDtEmba := If(nOpc == ALTERAR .And. !lReplicacao,!Empty(EEC->EEC_DTEMBA),.f.)

If Type("lNotShowScreen") <> "L" // Para não mostrar a tela principal
   Private lNotShowScreen := .F.
EndIf

Private aButtons := {}
Private aTela[0][0],aGets[0],nUsado:=0
Private cMarca := GetMark(), oMsSelect

Private aCampos:={},aHeader:={},lSITUACAO:=.T.
Private lDescIt := EasyGParam("MV_AVG0119",, .F.) // FJH 03/02/06

Private aAgDeletados:={}, aInDeletados:={}, aDeDeletados:={}, aNoDeletados:={}

// ** By EDS - 11/12/2002 - Variaveis para verificação de campos para estorno da contabilização
Private aEstornaECF:={}, aIncluiECF:={}, cFilECF, cFilECG
SX3->(DBSETORDER(2))
Private lOkEstor:= SX3->(dbSeek("ECF_PREEMB")) .And. SX3->(dbSeek("ECF_FASE")) .And. SX3->(dbSeek("ECF_PREEMB")) .And. ;
			       SX3->(dbSeek("EEQ_FASE")) .And. SX3->(dbSeek("EEQ_EVENT")) .And. SX3->(dbSeek("EEQ_NR_CON")) .And. ;
			       SX3->(dbSeek("EET_DTDEMB"))
Private lContEst  := EasyGParam("MV_CONTEST",,.T.)   // Gera Estorno para contabilização
Private lIntCont  := EasyGParam("MV_EEC_ECO",,.F.)   // Define Integração entre SIGAEEC - SIGAECO
Private lAchou := .F. //LRL08/12/2003
Private lLockInv := .F.  // PLB 20/09/06 - Utilizada na Função AE108ManutInv()

Private lItEstufado := .F.
Private aAtuEstufagem := {}

If lOkEstor
   cFilECF := xFilial("ECF")
   cFilECG := xFilial("ECG")
Endif

SX3->(DBSETORDER(nOrdemSX3))

Private lMUserEDC := FindFunction("EDCMultiUser")
If lIntDraw
   If lMUserEDC
      Private oMUserEDC := EDCMultiUser():Novo()  // PLB 05/12/06 - Inicializa objeto para controle multi-usuário do Drawback
   EndIf
   If lExistEDD .and. Select("WorkAnt")<>0
      //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
      AvZap("WorkAnt")
   EndIf
EndIf

// **By JBJ - 09/08/2001 - Para uso na função VIAODF3()
Private nSelecao := nOpc, aApropria := {}

// AMS - 02/08/2004. Indica se a função AE104NFCompara() foi executada.
Private lNFCompara := .F.

//Guarda as invoices e os campos do Back To Back
Private aColsBtB   :={}
Private aHeaderBtB :={}

//Necessario para que o filtro possa ser atualizado
Private cFilter

//Usada nas validações da vinculação dos itens
Private aItemVinc := {}
Private aDetail := {}

Private nItFab, onItFab
If lBACKTO
   cFilEXK := xFilial("EXK")
   AP106Cols(OC_EM)
Endif
// **
// ** JPM - 20/10/05 - Define se o controle de quantidades entre Br e Off-Shore está ativo.
Private lConsolida := EECFlags("INTERMED")  // EECFlags("CONTROL_QTD")  // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
Private lConsolOffShore := .f. // define se tem offshore
//JPM - 23/12/04 - Array de pedidos a desvincular de carta de crédito na gravação
Private aDesvinculados := {} // Controle de Saldo de L/C.
Private aItensDesv     := {}
Private lContNfCompara := EasyGParam("MV_AVG0130",,.T.) // By JPP - 13/12/2006 - 16:00 - Habilitar a rotina de comparação de notas fiscais na integração com o Contábil
Private oEncCapa //ASK
Private oEncEXL,oEncDUE //ASK
Private nTotVlrSCob // GFP - 31/10/2012
//AOM - Operações Especiais - 04/05/2011
If AvFlags("OPERACAO_ESPECIAL")
   Private oOperacao := EASYOPESP():New() //AOM - 28/04/2011 - Inicializando a classe para tratamento de operações especiais
EndIf

Private lExibeTela := .T.

// *** Guarda os filtros definidos pelo usuário
Private cUserFiltroEE9 := ""
// ***


Private lEmbEstAdi := .F.
Private nOpcPE := nOpc   // GFP - 15/01/2013
//DFS - 03/06/13 - Inclusão de variáveis para manipulação via ponto de entrada.
Private dDtEmb
Private dDtMemEmb
Private aControleAlt := {}  // GFP - 19/08/2014
Private aOpcPedFat   := {}  // NCF - 11/03/2015
Private lDevTotItEmb := AVFLAGS("EEC_LOGIX") .And. EES->(FieldPos("EES_QTDDEV")) > 0 ;
                                             .And. EES->(FieldPos("EES_VALDEV")) > 0 ;
                                             .And. EES->(FieldPos("EES_QTDORI")) > 0 // NCF - 25/05/2015

//THTS - 07/04/2017 - Array utilizado no EECAF214 para tratar qual adapter utilizar na inclusao de desp. internacional
Private aEAIAF520 := {}

Private bVal_Ok//RMD - 10/04/18

//JAP - 26/06/06 - O lAltera deve ser iniciado como .T. permitindo a edição dos campos no incluir após uma alteração.
If !lAltera
   lAltera := .T.
EndIf

//*** 16/07/13 - Verifica se o fluxo alternativo foi utilizado (legado)
If nOpc <> INCLUIR .And. !lIntEmb .And. EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT)
	lIntEmb := .T.
EndIf
//***

//Zera WorkArea das NFs de Entrada vinculadas
If Select("WK_NFRem")
   WK_NFRem->(AvZap())
EndIf

Begin Sequence
   //Variáveis de controle da rotina de notas fiscais de remessa com fim específico de exportação
   aNfRemDeletados := {}
   aSaldoNFE:= {}

   nTotVlrSCob := 0 // GFP - 31/10/2012

   //Limpa os registros de insumos já deletados
   aDelEdg := {}

   /* Para a filial de off-shore, os campos referentes ao siscomex, não são exibidos
      na tela de itens. */
   If lIntermed .And. AvGetM0Fil() == cFilEx
      aDelCapa := {"EEC_INTERM","EEC_COND2","EEC_DIAS2","EEC_INCO2","EEC_PERC","EEC_VLRIE"}
      For j:=1 To Len(aDelCapa)
          nPos := aScan(aHdEnchoice,aDelCapa[j])
          If nPos > 0
             aHdEnchoice := aDel(aHdEnchoice,nPos)
             aHdEnchoice := aSize(aHdEnchoice,Len(aHdEnchoice)-1)
          EndIf
      Next

      aDelItem:={"EE9_RE","EE9_DTRE","EE9_NRSD","EE9_DTAVRB","EE9_ATOCON","EE9_RV","EE9_FINALI","EE9_RC","EE9_MAXCOM"}
      For j:=1 To Len(aDelItem)
          nPos := aScan(aItemEnchoice,aDelItem[j])
          If nPos > 0
             aItemEnchoice := aDel(aItemEnchoice,nPos)
             aItemEnchoice := aSize(aItemEnchoice,Len(aItemEnchoice)-1)
          EndIf
      Next
   EndIf

   If EEC->(FieldPos("EEC_VLRIE")) # 0 .AND. WorkIP->(FieldPos("EE9_VLRIE")) > 0 // GFP - 17/12/2015 - LRS - 21/01/2016
      aAdd(aHdEnchoice,"EEC_VVLIE")
   EndIf

   If EEC->(FieldPos("EEC_INFGER")) # 0  // GFP - 28/05/2014
      aAdd(aHdEnchoice,"EEC_VMINGE")
   EndIf

   // ** Limpa os arquivos temporários.
   E_ZAP_AREA

   IF lDevTotItEmb .And. nOpc == ALTERAR                           //NCF - 25/05/2015 - Devolução de Embarque Faturado.
      If EEC->EEC_STATUS == ST_CD
         EasyHelp(STR0259,STR0035) //"Processo devolvido não pode sofrer alterações!"###"Atenção"
         Break
      EndIf
   Endif

   // ** AAF 13/09/04 - Adiciona botão da rotina de Back to Back
   If lBACKTO
      AP106EnchBar(OC_EM)
   Endif
   // **

   IF nOpc # INCLUIR .And. nOpc # ALTERAR
      aAdd(aButtons,{"NOTE",{|| IF(Empty(M->EEC_PREEMB),Help(" ",1,"AVG0000020"),EECAA101(M->EEC_IDIOMA,,OC_EM,M->EEC_PAISET,,M->EEC_PREEMB)) },STR0007/*,STR0187*/}) //"Documentos/Fax"### "Docto/Fax"
   Endif

   // ** by jbj - 21/09/04 - 11:12 (Botão para manutenção de histórico para pre-calculo.
   If (EECFlags("HIST_PRECALC") .And. nOpc == VISUALIZAR)
      aAdd(aButtons,{"PESQUISA" /*"BMPCONS"*/,{|| aE104ViewHistPreCalc()},STR0140/*,STR0171*/}) //"Histórico Pré-Calculo"### "His.Pré-C"
   EndIf

   // ** by jbj - 16/09/04 - 11:42 (Botão para manutenção dos dados adicionais de embarque).
   SX3->(DbSetOrder(2))
   SXA->(DbSetOrder(1))
   If !EECFlags("COMPLE_EMB") .And. !EECFlags("COMPLE_EMB_CAPA")
      aAdd(aButtons,{"BMPTABLE",{|| Ae106Man(cAlias,nReg,nOpc)},STR0141/*,STR0172*/}) //"Dados Complementares"### "D.Compl"
   EndIf

   SX3->(DbSetOrder(1))

   // ** By JBJ - 08/08/2002 - 16:65
   If Select("EXB") > 0 .And. Select("WorkDoc") > 0
      aAdd(aButtons,{"S4SB014N",{|| IF(Empty(M->EEC_PREEMB),Help(" ",1,"AVG0000020"),If(Empty(M->EEC_IMPORT),;
           EasyHelp(STR0142,STR0035),AP100Agenda(OC_EM)))},STR0143/*,STR0173*/})//"Informe o código do importador."###"Atenção"###"Agenda de Atividades/Documentos"### "Ag.At/Do"
   EndIf

   // *** EnchoiceBar ...
   IF !EasyGParam("MV_AVG0005") // Deixar de gravar embalagens ?
      If !EECFlags("ESTUFAGEM")
         aAdd(aButtons,{"CONTAINR" /*"DBG14"*/,{|| IF(Empty(M->EEC_PREEMB),Help(" ",1,"AVG0000020"),AE100Volume()) }, STR0006}) //"Volumes"
      EndIf
   Endif

   If EECFlags("FRESEGCOM")
      aAdd(aButtons,{"POSCLI",  {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100AGEN(OC_EM, nOpc)) }, STR0133/*,STR0174*/}) //"Agentes de Comissão"### "Ag.Comis"
      aAdd(aButtons,{"PRECO",   {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100DespNac(OC_EM, nOpc)) }, STR0134/*,STR0175*/}) //"Despesas Nacionais"### "Desp.Nac"
      aAdd(aButtons,{"SIMULACAO", {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AE100DespInt(nOpc)) }, STR0135/*,STR0176*/}) //"Despesas Internacionais"### "Desp.Int"
   Else
      aAdd(aButtons,{"POSCLI",  {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100AGEN(OC_EM,nOpc)) }, STR0008}) //"Empresas"
      aAdd(aButtons,{"PRECO" ,  {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), (M->cPESQDESP:=M->EEC_PREEMB, AP100DESP(OC_EM,nOpc)))}, STR0010}) //"Despesas"
   EndIf

   aAdd(aButtons,{"TABPRICE" /*"SALARIOS"*/,{|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100INST(OC_EM,nOpc)) },STR0009/*,STR0177*/}) //"Institui‡äes Banc rias"### "Inst.Ban"
   aAdd(aButtons,{"VENDEDOR",{|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100Notify(OC_EM,nOpc))},STR0011}) //"Notify's"
   aAdd(aButtons,{"BUDGET" , {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AE100FATURA(cALIAS,nREG,nOPC))},STR0013/*,STR0178*/}) //"Faturamento"### "Faturam."

   // ** By JBJ - 18/09/03 - Manutenção de Fechamento de Praça.
   aAdd(aButtons,{"S4WB014A",{ || Ae105FechaPrc()}, STR0179/*, STR0180*/}) // "Fecham. de Praça"###"Fech.Pra"

   // ** By JBJ - 29/10/03 - Opção para digitação manual dos dados Siscomex. (RE/SD/Ato Concessório).
   If (lDigDataSis .And. nOpc # VISUALIZAR .And. nOpc # EXCLUIR)
      //aAdd(aButtons,{"BMPTRG",{ || Ae105DigDataSis()}, STR0130/*,STR0181*/}) //"RE/SD/Ato Concessório"### "RE/SD/Ato"

      aAdd(aButtons,{"BMPTRG",{ || Ae105DigDataSis(), If( EEC->(FieldPos("EEC_INFGER")) # 0, M->EEC_VMINGE := GeraInfGerais(), ) }, STR0130/*,STR0181*/}) //"RE/SD/Ato Concessório"### "RE/SD/Ato" //NCF - 11/11/2014
   EndIf

   If EECFlags("INVOICE")  // ** By OMJ - 17/06/05 - Manutenção de Invoice.
      aAdd(aButtons,{"EDITWEB"/*"INVOICE1"*/,{ || Ae108ManutInv(nOpc) }, STR0182})// "Invoices"//RMD - 18/05/07 - Atualização da imagem utilizada no botão
   EndIf

   If EECFlags("CAFE") // RMD - 15/11/05 - Manutenção de OIC´s
      aAdd(aButtons,{"AVGLBPAR1"/*"AVGOIC1"*/	,{ || AE108ManOIC(nOpc) }, STR0160/*,STR0183*/}) //"Manutenção de OIC´s"### "Man.OICs"//RMD - 18/05/07 - Atualização da imagem utilizada no botão
      aAdd(aButtons,{"AVGBOX1",{|| Ae109Armazens() }, STR0165/*, STR0166*/})//"Controle de Armazéns"###"Armazéns"
   EndIf
   If lConsign .And. (cTipoProc == PC_VR .Or. cTipoProc == PC_VB)
      aAdd(aButtons, {"ARMAZEM",{|| Ae108SelItArm(nOpc) },STR0158/*,STR0184*/})//"Selecionar Produtos"### "Sel.Prod"
   EndIf

   //TRP - 09/03/2015
   lDtEmbAux:= lDtEmba

    If EasyEntryPoint("EECAE100")
       ExecBlock("EECAE100",.F.,.F.,{"BUTTON_REMESSA"})
    Endif

   //DFS - 04/10/12 - Quando o parametro referente a nota fiscal de remessa estiver habilitado e data de embarque preenchida, sistema deve permitir a inclusão de NF's de Entrada também.
   /* WFS jun/2016 - melhoria na rotina.
      Funcionalidade passa a ser chamada para os itens do embarque e não mais para os itens do pedido selecionados no embarque. */
   If (AvFlags("FIM_ESPECIFICO_EXP") .And. (lDtEmba .Or. NFRemFimEsp()))
      aAdd(aButtons,{"PEDIDO",{|| AE110VincNfEnt(nOpc)},If(AVFLAGS("EEC_LOGIX"),"Notas fiscais de remessa",STR0220)/*, STR0221*/}) // STR0220	"Vincular NFs de Entrada" //STR0221	"NFs Entr."
   EndIf

   //TRP - 09/03/2015
   lDtEmba:= lDtEmbAux

   /*
   Substituido condição, para implementar o botão de alteração de item quando o embarque estiver efetivado.
   Autor : Alexsander Martins dos Santos
   Data e Hora : 04/06/04 às 12:10

   IF (nOpc != VISUALIZAR .And. nOpc != EXCLUIR .AND. lALTERA)
      //aAdd(aButtons,{"NOVACELULA",{|| If(EMPTY(M->EEC_PREEMB).OR.EMPTY(M->EEC_IMPORT),MSGINFO("Deve ser informado N. do Processo e Importador.","Aviso"),AE100DETMAN(WorkIP->EE9_PEDIDO))},"Processos"})
      aAdd(aButtons,{"NOVACELULA",{|| If(EMPTY(M->EEC_PREEMB).OR.EMPTY(M->EEC_IMPORT),HELP(" ",1,"AVG0000627"),AE100DETMAN(WorkIP->EE9_PEDIDO))},STR0014}) //"Processos"
   Else
      aAdd(aButtons,{"ANALITICO",{|| AE100VIEWIT() },STR0002}) //"Visualizar"
   Endif
   */

   Do Case
      Case nOpc = INCLUIR
           aAdd(aButtons, {"SDURECALL" /*"NOVACELULA"*/, {|| If(EMPTY(M->EEC_PREEMB) .OR. EMPTY(M->EEC_IMPORT), HELP(" ",1,"AVG0000627"), AE100DETMAN(WorkIP->EE9_PEDIDO))}, STR0014}) //"Processos"

      Case nOpc = ALTERAR

           If lProcReplicado .Or. (lIntermed .And. AvGetM0Fil() == cFilEx)
              If !lProcReplicado
                 aAuxOrd := SaveOrd({"EEC"})
                 EEC->(DbSetOrder(1))
                 If EEC->(DbSeek(cFilBr+EEC->EEC_PREEMB))
                    aAdd(aButtons, {"EDIT" /*"ALT_CAD"*/, {|| AE100DetIP()}, STR0004}) //"Alterar"
                 EndIf
                 RestOrd(aAuxOrd,.t.)
              Else
                 aAdd(aButtons, {"EDIT" /*"ALT_CAD"*/, {|| AE100DetIP()}, STR0004}) //"Alterar"
              EndIf

           ElseIf lIntermed .And. AvGetM0Fil() == cFilBr .And. EEC->EEC_INTERM $ cSim

              lLockInv := !Ax101IsEmbExt(EEC->EEC_PREEMB)  // PLB 20/09/06 - Utilizada na Funcao AE108ManutInv
              //If !Ax101IsEmbExt(EEC->EEC_PREEMB)
              If lLockInv
                 aAdd(aButtons, {"EDIT" /*"ALT_CAD"*/, {|| AE100DetIP()}, STR0004}) //"Alterar"
              Else
                 aAdd(aButtons, {"SDURECALL" /*"BMPINCLUIR"*/ /*"NOVACELULA"*/, {|| If (EMPTY(M->EEC_PREEMB) .OR. EMPTY(M->EEC_IMPORT), HELP(" ",1,"AVG0000627"), AE100DETMAN(WorkIP->EE9_PEDIDO))}, STR0014}) //"Processos"
              EndIf
              //RMD - 03/05/08 - Compara notas na filial Brasil
              If Empty(EEC->EEC_DTEMBA)
                 If (lIntegra .and. lSelNotFat) .or. (lIntCont .And. lContNfCompara) .Or. AvFlags("NFS_DESVINC") // By JPP - 13/12/2006 - 16:00
                    aAdd(aButtons, {"BMPVISUAL" /*"VERNOTA"*/, {|| AE104NFCompara(, If(lIntegra,"SD2","EES") )}, STR0136/*,STR0185*/}) //"Comparação dos Itens da NF contra os Itens do Embarque."### "Comp.NF."
                 EndIf
              EndIf

           ElseIf Empty(EEC->EEC_DTEMBA)
              aAdd(aButtons, {"SDURECALL" /*"BMPINCLUIR"*/ /*"NOVACELULA"*/, {|| If(EMPTY(M->EEC_PREEMB) .OR. EMPTY(M->EEC_IMPORT), HELP(" ",1,"AVG0000627"), AE100DETMAN(WorkIP->EE9_PEDIDO))}, STR0014}) //"Processos"

              If (lIntegra .and. lSelNotFat) .or. (lIntCont .And. lContNfCompara) .Or. AvFlags("NFS_DESVINC")
                 aAdd(aButtons, {"BMPVISUAL" /*"VERNOTA"*/, {|| AE104NFCompara(, If(lIntegra,"SD2","EES") )}, STR0136/*,STR0185*/}) //"Comparação dos Itens da NF contra os Itens do Embarque."### "Comp.NF."
              EndIf
           ElseIf !Empty(EEC->EEC_DTEMBA) .And. AvFlags("NFS_DESVINC")
                aAdd(aButtons, {"BMPVISUAL" /*"VERNOTA"*/, {|| AE104NFCompara(, If(lIntegra,"SD2","EES") )}, STR0136/*,STR0185*/}) //"Comparação dos Itens da NF contra os Itens do Embarque."### "Comp.NF."  
                aAdd(aButtons, {"EDIT" /*"ALT_CAD"*/, {|| AE100DetIP()}, STR0004}) //"Alterar"
           Else
              aAdd(aButtons, {"EDIT" /*"ALT_CAD"*/, {|| AE100DetIP()}, STR0004}) //"Alterar"
           EndIf
      Otherwise
         aAdd(aButtons, {"BMPVISUAL" /*"ANALITICO"*/, {|| If(lConsolida,AE100DetIp(,,,,.t.),AE100VIEWIT())}, STR0002/*,STR0186*/}) //"Visualizar"### "Visualiz"
   EndCase
   IF nOpc == INCLUIR
      bVal_OK:={||lOkFinal := .T.,If(AE100LinOk(),(nOpcA:=1,If(!lNotShowScreen,oDlg:End(),)),nOpca:=0)} //MCF - 21/12/2015
      /*
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next nInc
      */
      RegToMemory("EEC",.T.)
      M->EEC_STATUS := ST_DC //aguardando confeccao documentos
      DSCSITEE7(.F.,OC_EM)
      cIDCAPA       := M->EEC_IDIOMA
      M->EEC_MARCAC := ""
      M->EEC_GENERI := ""
      M->EEC_OBSPED := ""
      M->EEC_OBS    := ""
      If EEC->(FieldPos("EEC_INFGER")) # 0  // GFP - 28/05/2014
         M->EEC_VMINGE := ""
      EndIf
      If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-30/10/2015
         M->EEC_VMDCOF := ""
      EndIf
      // ** RMD - 28/04/06 - Tratamento para novos tipos de Pedido
      If lConsign
         M->EEC_TIPO := cTipoProc
      EndIf
      // **

      If EECFlags("COMPLE_EMB")
         /*
         For nInc := 1 TO EXL->(FCount())
            M->&(EXL->(FieldName(nInc))) := CriaVar(EXL->(FieldName(nInc)))
         Next*/
         RegToMemory("EXL",.T.) // Para criar os virtuais

         If EECFlags("INTTRA")
            M->EXL_BKCOM  := ""
            M->EXL_BKTPCO := ""
            M->EXL_SICOM  := ""
            M->EXL_BLCLM1 := ""
            M->EXL_BLCLM2 := ""
            M->EXL_BLCLM3 := ""
            M->EXL_SIRINS := ""
         EndIf

      EndIf
   Else
      IF nOPC = EXCLUIR .AND. ! EMPTY(EEC->EEC_DTEMBA)
         HELP(" ",1,"AVG0000075",,STR0015+TRANSF(DTOC(EEC->EEC_DTEMBA),"@d"),1,16) //"Embarcado em "
         BREAK
      ELSEIF nOPC = EXCLUIR .AND. ! AE100EEQ()
             // ** By JBJ - 03/02/03 - 14:36.
             EasyHelp(STR0120,STR0035) //"Embarque possui adiantamento(s) ou parcela(s) de câmbio e não pode ser Excluido/Cancelado."###"Atenção"
             
             BREAK
      ElseIf nOpc = EXCLUIR .And. Ae102Nfc() // By JPP - 08/07/2005 15:35
             Break  // Não é Permitido excluir Embarque que possua nota fiscal Complementar.
      ElseIf nOpc == EXCLUIR .And. EECFlags("AMOSTRA") .And. !Am100VldEmb("EXCLUSAO", EEC->EEC_PREEMB)
         Break
      ENDIF

      For nInc := 1 TO (cAlias)->(FCount())
          M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
      Next nInc

      cIDCAPA       := M->EEC_IDIOMA
      M->EEC_MARCAC := MSMM(EEC->EEC_CODMAR,AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
      M->EEC_GENERI := MSMM(EEC->EEC_DSCGEN,AVSX3("EEC_GENERI",AV_TAMANHO),,,LERMEMO)
      M->EEC_OBSPED := MSMM(EEC->EEC_CODOBP,AVSX3("EEC_OBSPED",AV_TAMANHO),,,LERMEMO)
      M->EEC_OBS    := MSMM(EEC->EEC_CODMEM,AVSX3("EEC_OBS",AV_TAMANHO),,,LERMEMO)
      If EEC->(FieldPos("EEC_INFGER")) # 0  // GFP - 28/05/2014
         M->EEC_VMINGE := If(!Empty(MSMM(EEC->EEC_INFGER,AVSX3("EEC_VMINGE",AV_TAMANHO),,,LERMEMO)),MSMM(EEC->EEC_INFGER,AVSX3("EEC_VMINGE",AV_TAMANHO),,,LERMEMO),GeraInfGerais())
      EndIf
      If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-30/10/2015
         M->EEC_VMDCOF := MSMM(EEC->EEC_INFCOF,AVSX3("EEC_VMDCOF",AV_TAMANHO),,,LERMEMO)
      EndIf
      //DFS - 19/07/12 - Carrega os campos virtuais para que não apresente error.log ao visualizar o embarque na rotina de Geração de R.E
      M->EEC_CLIEDE :=IF(!EMPTY(M->EEC_CLIENT),POSICIONE("SA1",1,XFILIAL("SA1")+M->EEC_CLIENT+M->EEC_CLLOJA,"A1_NOME"),"")
      M->EEC_EXPODE :=IF(!EMPTY(M->EEC_EXPORT),BUSCAF_F(M->EEC_EXPORT+M->EEC_EXLOJA,.F.),"")
      M->EEC_CONSDE :=IF(!EMPTY(M->EEC_CONSIG), if( empty(M->EEC_CONSDE), POSICIONE("SA1",1,XFILIAL("SA1")+M->EEC_CONSIG+M->EEC_COLOJA,"A1_NOME"), M->EEC_CONSDE),"")

      // ** AAF - 13/09/04 - Carrega Dados no aColsBtB para o Back To Back
      IF lBACKTO .AND. nOpc <> INCLUIR
         AP106Dados(OC_EM)
      EndIF
      // **

      If EECFlags("COMPLE_EMB")
         EXL->(DbSetOrder(1))
         If EXL->(DbSeek(xFilial("EXL")+M->EEC_PREEMB))

            RegToMemory("EXL",.T.) // Para criar os virtuais

            For nInc := 1 TO EXL->(FCount())
                M->&(EXL->(FieldName(nInc))) := EXL->(FieldGet(nInc))
            Next

            //Campos Virtuais
            For nInc:= 1 To Len(aDespInt)
               SY6->(DBSetOrder(1))
               SY6->(DBSeek(xFilial()+M->&("EXL_CP"+aDespInt[nInc][1])+Str(M->&("EXL_DP"+aDespInt[nInc][1]), 3)))
               M->&("EXL_DC" + aDespInt[nInc][1]):= MSMM(SY6->Y6_DESC_P, 50)

               SY5->(DBSetOrder(1))
               SY5->(DBSeek(xFilial()+M->&("EXL_EM"+aDespInt[nInc][1])))
               M->&("EXL_DE" + aDespInt[nInc][1]):= SY5->Y5_NOME
            Next

            If EECFlags("INTTRA")
               M->EXL_BKCOM  := MSMM(EXL->EXL_CBKCOM,AVSX3("EXL_BKCOM" ,AV_TAMANHO),,,LERMEMO)
               M->EXL_BKTPCO := MSMM(EXL->EXL_CBKTCO,AVSX3("EXL_BKTPCO",AV_TAMANHO),,,LERMEMO)
            EndIf

         Else
            RegToMemory("EXL",.T.) // Para criar os virtuais
            /*
            For nInc := 1 TO EXL->(FCount())
               M->&(EXL->(FieldName(nInc))) := CriaVar(EXL->(FieldName(nInc)))
            Next */

            If EECFlags("INTTRA")
               M->EXL_BKCOM  := ""
               M->EXL_BKTPCO := ""
               M->EXL_SICOM  := ""
               M->EXL_SIRINS := ""
            EndIf

         EndIf
      EndIf

      If Type("M->EXL_DTREC") == "D"
         M->EEC_DTREC := M->EXL_DTREC
      EndIf

      IF nOpc == VISUALIZAR
         bVal_OK:={||oDlg:End(),lRet := .F.}
      ElseIf nOpc == ALTERAR .or. nOpc == APRVCRED
         IF ! EEC->(RecLock("EEC",.F.,,.T.)) // By JPP - 20/07/2005 10:15 - Inclusão do quarto parametro.
            Break
         Endif

         /*JPM - na replicação de embarque, no início é uma alteração, e na gravação é simulada uma inclusão
         bVal_OK:={||If(AE100LinOk(),(nOpcA:=2,oDlg:End()),nOpca:=0)}*/

         bVal_OK:={||lOkFinal := .T., If(AE100LinOk(),; //MCF - 23/12/2015
                     (If(lReplicacao,nOpcA:=1,nOpcA:=2),If(!lNotShowScreen, oDlg:End(),),lRet := .T.),;
                     (nOpca:=0, lRet := .F.))}
                                                          //ST_TR - Embarcado - Em Trânsito; ST_EC - Embarcado - Estocado em consignação
         If (M->EEC_STATUS $ ST_EM+ST_PC+ST_CC+ST_EP+ST_CO+ST_TR+ST_EC)
            lALTERA:=.F.
            If (M->EEC_STATUS $ ST_EM+ST_CC+ST_EP+ST_CO+ST_TR+ST_EC)

               If EasyEntryPoint("EECAE100")
                  lRetPto := ExecBlock("EECAE100",.F.,.F.,{"EXIBEMSG"})

                  If ValType(lRetPto) <> "L"
                     lRetPto := .T.
                  EndIf
               EndIf

               If lRetPto .and. !lAE100Auto
                  HELP(" ",1,"AVG0000075",,STR0015+TRANSF(DTOC(M->EEC_DTEMBA),"@d"),1,16) //"Embarcado em "
               EndIf

            ELSEIF (M->EEC_STATUS = ST_PC)
               //RMD - 21/06/19 - Ajusta a mensagem, porque o Help informava que o usuário deveria acessar a rotina em alteração e apagar a data de cancelamento, o que não é possível (já que a rotina é aberta em modo visualização)
               //HELP(" ",1,"AVG0000075",,STR0016+TRANSF(DTOC(M->EEC_FIM_PE),"@d"),1,16) //"Cancelado em "
               EasyHelp(StrTran(STR0273, "XXX", DToC(M->EEC_FIM_PE)), STR0272) //"Este embarque foi cancelado em 'XXX'. A operação será executada em modo de visualização." ### "Operação Inválida"
               cCadastro := StrTran(cCadastro, Upper(STR0004), Upper(STR0002))
               /* By JBJ - 12/05/04 - Para processos cancelados, não permitir alteração. Alterando a
                  opção para visualização. */

               AE100MAN(cAlias,nReg,VISUALIZAR)
               Return lRet
            ENDIF
         Else
            lALTERA := .T.
         Endif
      ElseIf nOpc == EXCLUIR
         //RMD - 21/06/19 - Exibe mensagem para informar que não poderá cancelar novamente o pedido já cancelado
         If M->EEC_STATUS = ST_PC .And. ((IsMemVar("lAE100CANCE") .And. lAE100CANCE) .Or. (IsMemVar("lAE100DEV") .And. lAE100DEV))
            EasyHelp(StrTran(STR0273, "XXX", DToC(M->EEC_FIM_PE)), STR0272) //"Este embarque foi cancelado em 'XXX'. A operação será executada em modo de visualização." ### "Operação Inválida"
            cCadastro := StrTran(cCadastro, Upper(STR0005), Upper(STR0002))
            Return AE100MAN(cAlias,nReg,VISUALIZAR)
         Else
            IF ! EEC->(RecLock("EEC",.F.,,.T.))  // By JPP - 20/07/2005 10:15 - Inclusão do quarto parametro.
               Break
            Endif
            bVal_OK:={||nOpca:=0,IF(AE100MANE(),(If(!lNotShowScreen, oDlg:End(), ),lRet := .T.),lRet := .T.)}
         EndIf
      Endif
   Endif

   // GFP - 25/07/2012 - Campo "Categoria de Cota"
   If EE9->(FieldPos("EE9_CATCOT")) > 0
      aAdd(aItemEnchoice,"EE9_CATCOT")
   EndIf

   // GFP - 17/12/2015 - Tratamento Imposto de Exportação
   If EE9->(FieldPos("EE9_PERIE")) > 0
      aAdd(aItemEnchoice,"EE9_PERIE")
   EndIf
   If EE9->(FieldPos("EE9_BASIE")) > 0
      aAdd(aItemEnchoice,"EE9_BASIE")
   EndIf
   If EE9->(FieldPos("EE9_VLRIE")) > 0
      aAdd(aItemEnchoice,"EE9_VLRIE")
   EndIf

   M->EEC_PESLIQ:=M->EEC_PESBRU:=M->EEC_TOTITE:=M->EEC_TOTPED:=0
   lConsolOffShore := ((M->EEC_INTERM $ cSim) .And. lConsolida)

   // Carrrega dados do embarque
   MsAguarde({|| If(Type("oText") == "O",MsProcTxt(STR0070),.T.), lOK:=EECAE102()},STR0017)  //"Embarque"

   IF !lOK
      Break
   Endif
   //Verifica se será permitida a alteração do processo após o preenchimento da data de embarque. Quando Existir Invoice (Tabela EXP), nao será permitida a alteração pós-embarque
   //Quando tiver adiantamento pos embarque (603) também nao sera permitida alteração pos-embarque
   //Quando tiver mais de um agente diferente, não será permitida alteração pos-embarque
   lAltValPosEmb := EasyGParam("MV_AVG0081",,.f.)
   If !Empty(M->EEC_DTEMBA) .And. lAltValPosEmb .And. (WorkInv->(EasyRecCount()) > 0 .Or. VldAltPEmb())
        lAltValPosEmb := .F.
   EndIf
   
   //Verifica o parametro de conferencia de peso = .T., sendo ! Atribui o valor do banco.
   //Não traz os pesos totais na inclusão - ASK 03/10/06 - 12:35
   If nOpc <> INCLUIR
     If EasyGParam( "MV_AVG0004" )
	    M->EEC_PESLIQ := EEC->EEC_PESLIQ
	    M->EEC_PESBRU := EEC->EEC_PESBRU
     EndIf
   EndIf

   If EECFlags("HIST_PRECALC") .And. nOpc == ALTERAR
      Ae104TrataValores() // Apura os valores iniciais que são base para apuração das despesas.
   EndIf

   //JPM - 10/03/05 - campos da pasta intermediação não aparecem quando o usuário está logado na filial Exterior
   aEncOffShore := {}
   If lMultiOffShore .And. AvGetM0Fil() == cFilEx

      // Tratamentos para os campos referentes a intermediação na filial do exterior.
      SXA->(DbSetOrder(1))
      If SXA->(DbSeek("EEC"))
         Do While SXA->(!Eof()) .And. SXA->XA_ALIAS == "EEC"
            If AllTrim(SXA->XA_DESCRIC) == "Intermediacao"
               cFolder := SXA->XA_ORDEM
               Exit
            EndIf
            SXA->(DbSkip())
         EndDo
      EndIf

      aInterm := {}
      SX3->(DbSetOrder(1))
      SX3->(DbSeek("EEC"))

      While SX3->(!EoF()) .And. SX3->X3_ARQUIVO == "EEC"
         If SX3->X3_FOLDER == cFolder
            AAdd(aInterm,SX3->X3_CAMPO)
            If Type("M->"+aInterm[Len(aInterm)]) <> "U"
               &("M->"+aInterm[Len(aInterm)]) := CriaVar(aInterm[Len(aInterm)])
            EndIf
         EndIf
         SX3->(DbSkip())
      EndDo

      For i := 1 to len(aHDEnchoice)
         If AScan(aInterm,aHDEnchoice[i]) = 0
            AAdd(aEncOffShore,aHdEnchoice[i])
         Endif
      Next

   EndIf

   //JPM - 09/03/05
   If lReplicacao
      For i := 1 to Len(aDadosOffShore)
         If !Empty(aDadosOffShore[i][1])
            M->&(aDadosOffShore[i][1]) := aDadosOffShore[i][3]
         EndIf
      Next
      //Muda o campo de amarração com o embarque
      Ae108TrataWorks()
   EndIf
   If lConsolida
      WorkGrp->(DbSetFilter({|| WP_FLAG <> 'N'},"WP_FLAG <> 'N'"))
      WorkGrp->(dbGoTop())
   Else
      WorkIP->(DbSetFilter({|| WP_FLAG == cMarca },"WP_FLAG =='"+cMarca+"'"))
      WorkIP->(dbGoTop())
   EndIf

   /////////////////////////////////////////////////////////////
   //ER - Verifica se o Embarque não está integrado com o novo//
   //fluxo de integração entre SigaEEC e SigaFAT.             //
   /////////////////////////////////////////////////////////////
   If lIntEmb
      If !FAT3IntFat(M->EEC_PREEMB,nOpc)

         ///////////////////////////////////////
         //Retira os campos TES e CF dos itens//
         ///////////////////////////////////////
         nPos := aScan(aItemEnchoice,"EE9_TES")
         If nPos > 0
            aItemEnchoice := aDel(aItemEnchoice,nPos)
            aItemEnchoice := aSize(aItemEnchoice,Len(aItemEnchoice)-1)
         EndIf

         nPos :=  aScan(aItemEnchoice,"EE9_CF")

         If nPos > 0
            aItemEnchoice := aDel(aItemEnchoice,nPos)
            aItemEnchoice := aSize(aItemEnchoice,Len(aItemEnchoice)-1)
         EndIf

      EndIf
   EndIf

   If !lExibeTela
	lRet := .F.
      Break
   EndIf

   // JPM - 06/12/05
   aBackupEdit := AClone(aEECCamposEditaveis)
   If nOpc <> INCLUIR
      If Len(aEECCamposEditaveis) <> 0
         If (nPos := AScan(aEECCamposEditaveis,"EEC_PREEMB")) > 0
            ADel(aEECCamposEditaveis,nPos)
            ASize(aEECCamposEditaveis,Len(aEECCamposEditaveis)-1)
         EndIf
      Else
         aEECCamposEditaveis := EECAClone(aHDEnchoice,"EEC_PREEMB")
      EndIf
   EndIf

   //OAP-31/01/2011 - Adequação para que tais campos de enquadramento não sejam visuais.
   If EECFlags("NOVOEX")
      If Len(aEncOffShore) > 0 .And. ASCAN(aEncOffShore,"EEC_ENQCO4") > 0 .And. ASCAN(aEncOffShore,"EEC_ENQCO5") > 0//RMD - 06/02/17 - Não estava verificando se existe no array antes de excluir
         ADEL(aEncOffShore,ASCAN(aEncOffShore,"EEC_ENQCO4"))
         ASize(aEncOffShore,Len(aEncOffShore)-1) //AOM - 11/05/2012
         ADEL(aEncOffShore,ASCAN(aEncOffShore,"EEC_ENQCO5"))
         ASize(aEncOffShore,Len(aEncOffShore)-1) //AOM - 11/05/2012
      ElseIf ASCAN(aHDEnchoice,"EEC_ENQCO4") > 0 .And. ASCAN(aHDEnchoice,"EEC_ENQCO5") > 0//RMD - 06/02/17 - Não estava verificando se existe no array antes de excluir
         ADEL(aHDEnchoice,ASCAN(aHDEnchoice,"EEC_ENQCO4"))
         ASize(aHDEnchoice,Len(aHDEnchoice)-1) //AOM - 11/05/2012
         ADEL(aHDEnchoice,ASCAN(aHDEnchoice,"EEC_ENQCO5"))
         ASize(aHDEnchoice,Len(aHDEnchoice)-1) //AOM - 11/05/2012
      EndIf
   EndIf

   //FSM - 21/07/2012
   If EECFlags("TIT_PARCELAS")
      aAdd(aHDEnchoice, "EEC_TITCAM")
   EndIf
   If EEC->(Fieldpos("EEC_SISORI")) > 0 //THTS - 31/08/2018 - Projeto Execauto no pedido/Embarque
        aAdd(aHDEnchoice, "EEC_SISORI")
   EndIf
   //NCF - 11/05/2017
   If AVFlags("DU-E")
      aAdd(aHDEnchoice, "EEC_EMFRRC")
      aAdd(aHDEnchoice, "EEC_RECALF")
      aAdd(aHDEnchoice, "EEC_STTDUE")
      aAdd(aEECCamposEditaveis, "EEC_EMFRRC")
      aAdd(aEECCamposEditaveis, "EEC_RECALF")

      //RMD - 11/07/18 - Caso exista o campo de recinto alfandegado de embarque, inclui na tela e deixa editável
      If EEC->(FieldPos("EEC_RECEMB")) > 0
         aAdd(aHDEnchoice, "EEC_RECEMB")
         aAdd(aEECCamposEditaveis, "EEC_RECEMB")
      EndIf
      If EEC->(FieldPos("EEC_RESPDE")) > 0
         aAdd(aHDEnchoice, "EEC_RESPDE")
         aAdd(aEECCamposEditaveis, "EEC_RESPDE")
      EndIf
      If EEC->(FieldPos("EEC_LATDES")) > 0
         aAdd(aHDEnchoice, "EEC_LATDES")
         aAdd(aEECCamposEditaveis, "EEC_LATDES")
      EndIf
      If EEC->(FieldPos("EEC_LONDES")) > 0
         aAdd(aHDEnchoice, "EEC_LONDES")
         aAdd(aEECCamposEditaveis, "EEC_LONDES")
      EndIf
      If EEC->(FieldPos("EEC_ENDDES")) > 0
         aAdd(aHDEnchoice, "EEC_ENDDES")
         aAdd(aEECCamposEditaveis, "EEC_ENDDES")
      EndIf
      If EEC->(FieldPos("EEC_DUEAVR")) > 0
         aAdd(aHDEnchoice, "EEC_DUEAVR")
         aAdd(aEECCamposEditaveis, "EEC_DUEAVR")
      EndIf
      If EEC->(FieldPos("EEC_JUSRET")) > 0
         aAdd(aHDEnchoice, "EEC_JUSRET")
         aAdd(aEECCamposEditaveis, "EEC_JUSRET")
      EndIf
      If AvFlags("DU-E3") .and. EEC->(FieldPos("EEC_DUEMAN")) > 0
         aAdd(aHDEnchoice, "EEC_DUEMAN")
         aAdd(aEECCamposEditaveis, "EEC_DUEMAN")
      EndIf

      If AvFlags("DU-E2")
        /*WHRS TE-6464 542022 - MTRADE-1806 - Ajustes nos dados do XML da DUE*/
        aAdd(aHDEnchoice, "EEC_FOREXP")
        aAdd(aHDEnchoice, "EEC_DESFOR")
        aAdd(aHDEnchoice, "EEC_OBSFOR")
        aAdd(aHDEnchoice, "EEC_SITESP")
        aAdd(aHDEnchoice, "EEC_DESSIT")
        aAdd(aHDEnchoice, "EEC_OBSSIT")
        aAdd(aHDEnchoice, "EEC_ESPTRA")
        aAdd(aHDEnchoice, "EEC_DESTRA")
        aAdd(aHDEnchoice, "EEC_OBSTRA")
        aAdd(aHDEnchoice, "EEC_MOTDIS")
        aAdd(aHDEnchoice, "EEC_DESDIS")
        aAdd(aHDEnchoice, "EEC_OBSDIS")

        aAdd(aEECCamposEditaveis, "EEC_FOREXP")
        aAdd(aEECCamposEditaveis, "EEC_OBSFOR")
        aAdd(aEECCamposEditaveis, "EEC_SITESP")
        aAdd(aEECCamposEditaveis, "EEC_OBSSIT")
        aAdd(aEECCamposEditaveis, "EEC_ESPTRA")
        aAdd(aEECCamposEditaveis, "EEC_OBSTRA")
        aAdd(aEECCamposEditaveis, "EEC_MOTDIS")
        aAdd(aEECCamposEditaveis, "EEC_OBSDIS")

        //WHRS TE-5041 542634 - Permitir retificação da DUE
        aAdd(aHDEnchoice, "EEC_NRODUE")
        aAdd(aHDEnchoice, "EEC_NRORUC")

         If EEC->(FieldPos("EEC_DTDUE")) > 0
            aAdd(aHDEnchoice, "EEC_DTDUE")
               aAdd(aEECCamposEditaveis, "EEC_DTDUE")
        EndIf
         If EEC->(FieldPos("EEC_CHVDUE")) > 0
            aAdd(aHDEnchoice, "EEC_CHVDUE")
        EndIf
         aAdd(aEECCamposEditaveis, "EEC_NRORUC")
      EndIf

   Else //THTS - 20/06/2018 - Quando a DUE estiver desabilitada, mas existir os campos EEC_NRODUE e EEC_NRORUC, mostrar eles na tela
        If DUEExistCP()
            aAdd(aHDEnchoice, "EEC_NRODUE")
            aAdd(aHDEnchoice, "EEC_NRORUC")
            aAdd(aEECCamposEditaveis, "EEC_NRODUE")
            aAdd(aEECCamposEditaveis, "EEC_NRORUC")
            If EEC->(FieldPos("EEC_DTDUE")) > 0
                aAdd(aHDEnchoice, "EEC_DTDUE")
               if !EasyGParam("MV_EEC0053",, .T.)
                  aAdd(aEECCamposEditaveis, "EEC_DTDUE")
               endif
            EndIf
            If EEC->(FieldPos("EEC_CHVDUE")) > 0
                aAdd(aHDEnchoice, "EEC_CHVDUE")
                aAdd(aEECCamposEditaveis, "EEC_CHVDUE")
            EndIf
            If EEC->(FieldPos("EEC_DUEAVR")) > 0
                aAdd(aHDEnchoice, "EEC_DUEAVR")
                aAdd(aEECCamposEditaveis, "EEC_DUEAVR")
            EndIf
        EndIf
   EndIf

    // 4 PACOTE DA DUE, VALIDAR QUANDO FOR DUE OU RE  - MPG -
    if nOpc == ALTERAR .and. AVFlags("DU-E")

        if (!empty(EEC->EEC_GEDERE) .or. !empty(EEC->EEC_GDRPRO)) .and. (AVFlags("DU-E2") .And. (empty(EEC->EEC_NRODUE) .or. empty(EEC->EEC_NRORUC)))
            aDelEditaveis := {"EEC_NRODUE"}
            aDelItem:={"EE9_CODUE"}
        elseif (empty(EEC->EEC_GEDERE) .or. empty(EEC->EEC_GDRPRO)) .and. IF( AVFlags("DU-E2"),(!empty(EEC->EEC_NRODUE) .or. !empty(EEC->EEC_NRORUC)),.T.)
            aDelEditaveis := {"EEC_GEDERE","EEC_GDRPRO",/*"EEC_URFENT","EEC_PAISET","EEC_INSCOD","EEC_ENQCOX",*/;
            "EEC_REGVEN","EEC_OPCRED","EEC_LIMOPE","EEC_DIRIVN","EEC_SECEX","EEC_MRGNSC","EEC_VLMNSC","EEC_ANTECI",;
            "EEC_VISTA","EEC_NPARC","EEC_PARCEL","EEC_VLCONS","EEC_FINCIA","EEC_LIBSIS","EEC_PTCROM"/*,"EEC_SITESP","EEC_ESPTRA","EEC_MOTDIS"*/ }
            aDelItem:={"EE9_RE","EE9_DTRE","EE9_NRSD","EE9_DTDDE"}
            If !ExibCpoAvb()
               aAdd(aDelItem , "EE9_DTAVRB" )
            EndIf
        else
            aDelEditaveis := {}
            aDelItem:={}
        EndIf

        For j:=1 To Len(aDelEditaveis)
            nPos := aScan(aEECCamposEditaveis, {|x| Alltrim(x)==aDelEditaveis[j] } )
            If nPos > 0
                aEECCamposEditaveis := aDel(aEECCamposEditaveis,nPos)
                aEECCamposEditaveis := aSize(aEECCamposEditaveis,Len(aEECCamposEditaveis)-1)
            EndIf
        Next

        For j:=1 To Len(aDelItem)
            nPos := aScan(aItemEnchoice, {|x| Alltrim(x)==aDelItem[j] } )
            If nPos > 0
                aItemEnchoice := aDel(aItemEnchoice,nPos)
                aItemEnchoice := aSize(aItemEnchoice,Len(aItemEnchoice)-1)
            EndIf
        Next

    endif

   //CRF
   If FindFunction("EasyMacroDesc") .And. ChkFile("EWX")
      oMacroCAPA := EASYMACROLIST():New(STR0211)//STR0211	"Selecione o campo para alteração da macro."
      oMacroDet  := EASYMACROLIST():New(STR0211)//STR0211	"Selecione o campo para alteração da macro."

      If (nOpc == INCLUIR .Or. nOpc == ALTERAR)
         cValidBotao := "{||If ( Empty(M->EEC_PREEMB) , EasyHelp('"+STR0212+"','"+STR0213+"'), oMacroCAPA:List() )}" //STR0212	'Informe o numero do processo' //STR0213 'Atenção'
         oMacroCAPA:AddButton(aButtons, cValidBotao,"MPWIZARD")
      EndIf

      If nOpc == INCLUIR
         cChave := ""
      Else
         cChave := xFilial("EEC")+M->EEC_PREEMB
      EndIf

      oMacroCAPA:Add("M", cChave, "EEC_GENERI", {{"EEC", "M"}, {"EXL", "M"}})
      oMacroCAPA:Add("M", cChave, "EEC_OBS"   , {{"EEC", "M"}, {"EXL", "M"}})
      oMacroCAPA:Add("M", cChave, "EEC_OBSPED", {{"EEC", "M"}, {"EXL", "M"}})
      oMacroDet:Add("M", cChave, "EE9_VM_DES", {{"EE9", "M"}})
   EndIf

   If EasyGParam("MV_EEC0037",,.F.)  // GFP - 07/01/2014
      EE5->(DbSetOrder(1))  //EE5_FILIAL+EE5_CODEMB
      EE5->(DbSeek(xFilial("EE5")+M->EEC_EMBAFI))
      nPesBrEmb  := EE5->EE5_PESO * M->EEC_QTDEMB
      M->EEC_PESBRU += nPesBrEmb
      nTotPesBru := M->EEC_PESBRU
   Else
      nTotPesBru := M->EEC_PESBRU // GFP - 10/03/2014
   EndIf

   If EEC->(FieldPos("EEC_VLRIE")) # 0 .AND. WorkIP->(FieldPos("EE9_VLRIE")) > 0  // GFP - 17/12/2015 LRS - 21/01/2016
      M->EEC_VVLIE := AE100VLRIE(1)
   EndIf

    If EEC->(FieldPos("EEC_DTADTE")) > 0 //.and. EEC->(FieldPos("EEC_STADTO")) > 0
        aAdd(aHDEnchoice, "EEC_STADTO")
        aAdd(aEECCamposEditaveis, "EEC_STADTO")
        aAdd(aHDEnchoice, "EEC_DTADTE")
        aAdd(aEECCamposEditaveis, "EEC_DTADTE")
    EndIf
   //MFR 30/09/2020 OSSME-5179 SÓ ALTEROU DE LUGAR
   If EasyEntryPoint("EECAE100")
      ExecBlock("EECAE100",.F.,.F.,{"ANTES_TELA_PRINCIPAL",nOpc})
   EndIf

   If !lAE100Auto//RMD - 26/10/17 - Trata o MsExecAuto

        DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL

            aPosEnc:= PosDlgUp(oDlg)
            aPosEnc[3] += 30

            If lStatusDUE
               aPosEnc[4] -= 75
            EndIf

            //EnChoice( cAlias, nReg, nOpc, , , ,If(Len(aEncOffShore) > 0,aEncOffShore,aHDEnchoice), aPosEnc, If(Len(aEECCamposEditaveis) <> 0, aEECCamposEditaveis,) ) ateste
            oEncCapa := Msmget():New( cAlias, nReg, nOpc, , , ,If(Len(aEncOffShore) > 0,aEncOffShore,aHDEnchoice), aPosEnc, If(Len(aEECCamposEditaveis) <> 0, aEECCamposEditaveis,),,,,,oDlg )

            SX3->(DbSetOrder(2))
            SXA->(DbSetOrder(1))
            If EECFlags("COMPLE_EMB") .And. EECFlags("COMPLE_EMB_CAPA");
                .And. ValType(nFolderExl := Val(RetAsc(Right(AllTrim(aGets[aScan(aGets, {|x| IncSpace("EEC_EXL", 10, .F.) $ x })]),1),1,.F.))) == "N" .And. nFolderExl > 0 //DFS - 02/03/11 - Tratamento para ordenação de pastas customizadas, independente da numeração.
                                    //      Val(Right(AllTrim(aGets[aScan(aGets, {|x| IncSpace("EEC_EXL", 10, .F.) $ x })]),1))))
                oFolderExl := oEncCapa:oBox:aDialogs[nFolderExl]
                aGetsEEC := aClone(aGets)
                aTelaEEC := aClone(aTela)
                aGets := {}
                aTela := {}
                oEncEXL := MsmGet():New("EXL",nReg,nOpc,,,,aCamposEXL,;
                                    {1,1,(oFolderExl:nClientHeight-6)/2,(oFolderExl:nClientWidth-4)/2},,,,,,;
                                    oFolderExl)
                oEncEXL:oBox:Align := CONTROL_ALIGN_ALLCLIENT
                aGets := aClone(aGetsEEC)
                aTela := aClone(aTelaEEC)
            EndIf

            If lStatusDUE

               oFolderDUE := oEncCapa:oBox:aDialogs[5] //Aba "DUE" no ATUSX para a tabela EEC
               aGetsEEC := aClone(aGets)
               aTelaEEC := aClone(aTela)
               aGets := {}
               aTela := {}
               aGetsEKK := {}
               aColsEKK := {}
               aCordPnDUE := { 1,oFolderDUE:nClientWidth - ((oFolderDUE:nClientWidth-4)/15),(oFolderDUE:nClientWidth-4)/15,(oFolderDUE:nClientHeight-6)/2 }

               oPanelDUE := TPanel():New(aCordPnDUE[1] ,aCordPnDUE[2],"",oFolderDUE,,.F.,.F.,,,aCordPnDUE[3],aCordPnDUE[4],,)
               oPanelDUE:align:= CONTROL_ALIGN_RIGHT

               aCordBtDUE := { oPanelDUE:nTop ,  oPanelDUE:nLeft  }
               oDetSttBtn := SButton():New( aCordBtDUE[1] , aCordBtDUE[2] , 15 , {||GetDtStDUE(oGetDadEKK)}, oPanelDUE , .T., "Detalhes do Status da DUE posicionado!" ,  )
               oDetSttBtn:Align := CONTROL_ALIGN_TOP
               
               aCordGdDUE := { oPanelDUE:nTop + 20 , oPanelDUE:nLeft , oPanelDUE:nBottom, oPanelDUE:nRight   }
               AE100LdEKK(aGetsEKK,aColsEKK)
               oGetDadEKK := MsNewGetDados():New(aCordGdDUE[1],aCordGdDUE[2],aCordGdDUE[3], aCordGdDUE[4],2,,,"",{},,1000,,,,oPanelDUE,aGetsEKK,aColsEKK)
               oGetDadEKK:AddAction("EKK_DETAST",{||GetDtStDUE(oGetDadEKK)})
               oGetDadEKK:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

               aGets := aClone(aGetsEEC)
               aTela := aClone(aTelaEEC)

               &(cClearArr) //Limpeza de arrays já utilizados (boas práticas para liberação de memória)
            EndIf

            SX3->(DbSetOrder(1))

            //FDR - 25/06/12
            oEncCapa:oBox:Align := CONTROL_ALIGN_TOP

            aPos := PosDlg(oDlg)
            aPos[1] += 30
            aPos[3] -= 36

            oPanel1:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
            oPanel1:Align:= CONTROL_ALIGN_ALLCLIENT

            aPos[3] := aPos[3]/2
            aPos[4] := aPos[4]/2

            If lConsolida // JPM - 21/10/05 - consolidação de itens, na rotina de Controle de quantidades entre filiais Br e Ex
                aGrp := AClone(aGrpBrowse)
                ADel(aGrp,1) //tira coluna de flag.
                ASize(aGrp,Len(aGrp)-1)
                oMsSelect := MsSelect():New("WorkGrp",,,aGrp,@lInverte,@cMarca,aPos,,,oPanel1)
                oMsSelect:bAval := {|| AE100DetIp(,,,,.t.) } // Visualizar
            Else
                oMsSelect := MsSelect():New("WorkIP",,,aCampoPED,@lInverte,@cMarca,aPos,,,oPanel1)
                oMsSelect:bAval := {|| AE100ViewIt() }
            EndIf

            //FDR - 25/06/12
            oMsSelect:oBrowse:Align:= CONTROL_ALIGN_TOP

            aPos[1] := aPos[3]
            aPos[3] := aPos[1]+28

            oPanel2:=	TPanel():New(aPos[1],aPos[2], "", oPanel1,, .F., .F.,,, aPos[4], 40)
            oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT

            aPos[3] := aPos[3]*2
            aPos[4] := aPos[4]*2

            AE100TTELA(.T.,aPos,oPanel2)

            oDlg:lMaximized := .T.

            //RMD - 18/05/07 - Tira o foco da enchoice, para evitar erro de validação do campo EEC_DTEMBA
            If !Empty(M->EEC_DTEMBA)
                oMsSelect:oBrowse:SetFocus()
            EndIf

        // DFS - Troca da função EnchoiceBar por AvButtonBar, onde os botões não utilizados na capa do Embarque, foram retirados.
        ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bVal_Ok,bCancel,,aButtons),If(lNotShowScreen,Eval(bVal_Ok),Nil))
   Else
      If (nPos := aScan(aAE100Auto, {|x| x[1] == "EEC" })) > 0
         aVldFim := {}
         AvKeyAuto(aAE100Auto[nPos][2]) //THTS - 15/08/2018 - Realiza a formatacao dos campos do array com base no avkey dos campos
         //Carrega os campos da Capa do Embarque via EnchAuto
         //EnchAuto(cAlias,aAE100Auto[nPos][2],{|| Obrigatorio(aGets,aTela)},nOpc, If(Len(aEncOffShore) > 0,aEncOffShore,aHDEnchoice))
         If nOpc == ALTERAR
            AutFrtSeg(aEECCamposEditaveis)//Caso seja alteração, não deve integrar Frete e Seguro
         EndIf
         If (nPosDt := aScan(aAE100Auto[nPos][2], {|x| x[1] == "EEC_DTEMBA" .And. !Empty(x[2]) })) > 0
            aAdd(aVldFim, aAE100Auto[nPos][2][nPosDt])
            aDel(aAE100Auto[nPos][2], nPosDt)
            aSize(aAE100Auto[nPos][2], len(aAE100Auto[nPos][2])-1)
         EndIf
         If Len(aAE100Auto[nPos][2]) > 0
            EnchAuto(cAlias,ValidaEnch(aAE100Auto[nPos][2], If(Len(aEECCamposEditaveis) <> 0, aEECCamposEditaveis,)),{|| Obrigatorio(aGets,aTela)},nOpc, If(Len(aEncOffShore) > 0,aEncOffShore,aHDEnchoice))
         EndIf
         lNotShowScreen := .T.//Variável padrão da manutenção de itens para não exibir a tela
         If !lMsErroAuto .And. nSelecao <> 5 .And. (nPos := aScan(aAE100Auto, {|x| x[1] == "EE9" })) > 0
            For nForAuto := 1 To Len(aAe100Auto[nPos][2])
                AvKeyAuto(aAe100Auto[nPos][2][nForAuto])//THTS - 15/08/2018 - Realiza a formatacao dos campos do array com base no avkey dos campos
            Next
            //Executa a manutenção dos Itens
            Ae100AutoItens(aAe100Auto[nPos][2])
         EndIf
         //Executa a integração dos dados adicionais (tabelas auxiliares)
         If nSelecao <> 5 .And. !lMsErroAuto
            IntegAux(aAe100Auto, nOpc)
         EndIf
         If !lMsErroAuto .And. Len(aVldFim) > 0
            EnchAuto(cAlias,ValidaEnch(aVldFim, If(Len(aEECCamposEditaveis) <> 0, aEECCamposEditaveis,)),{|| Obrigatorio(aGets,aTela)},nOpc, If(Len(aEncOffShore) > 0,aEncOffShore,aHDEnchoice))
         EndIf
         //Executa a ação do botão OK, incluindo as validações finais
         If !lMsErroAuto
            Eval(bVal_Ok)
         EndIf
      EndIf
   EndIf

   aEECCamposEditaveis := AClone(aBackupEdit)

   WorkIP->(dbClearFilter())
   If lConsolida
      WorkGrp->(dbClearFilter())
   EndIf
   //JPM - Se é uma replicação de processo, no começo simula uma alteraçào, e agora passa para inclusão
   If lReplicacao
      Inclui   := .t.
      nOpc     := INCLUIR
      nSelecao := nOpc
   EndIf

    If EasyEntryPoint("EECPEM36")
      ExecBlock("EECPEM36",.F.,.F.,{"FECHA_TELA_PRINCIPAL"})
   Endif

   IF nOpcA == 0
      IF nOpc == INCLUIR
         While __lSX8
            RollBackSX8()
         Enddo
      Endif
   Elseif nOpcA == 1 .or. nOpcA == 2 //Inclusão ou Alteração
   //LRL 08/12/2003
   // MJA 20/06/05 Para tratar em quais ocasiões pode-se alterar a data do embarque
      If lIntCont .AND.( nOpcA == 2 ).AND. (M->EEC_DTEMBA != EEC->EEC_DTEMBA) .AND. !EMPTY(EEC->EEC_DTEMBA)  // Caso Alteração Testa Integração e se Data foi Alterada
         // ** AAF 09/01/08 - Tratamento do Estorno contábil na alteração da data de embarque
         AE100EstCon("ALTERA_DTEMBA")
         // **
      EndIf

      If lGRV
         For i := 1 To 2
            If FindFunction("EasyEAIBuffer")
               lEaiBuffer := .T.
               EasyEAIBuffer("INICIO")
            EndIf
            Begin Transaction

               If nOpc == INCLUIR
                  EEC->(dbGoBottom())
                  EEC->(dbSkip())
               EndIf

               dDtEmbarque := EEC->EEC_DTEMBA
               dDtFim := EEC->EEC_FIM_PE
               cStEmb := EEC->EEC_STATUS
               cDescStEmb := EEC->EEC_STTDES
               cEvDtEmba := ""

               //DFS - 03/06/13 - As variáveis recebem o conteúdo da tabela e da memória
               dDtEmb    := EEC->EEC_DTEMBA
               dDtMemEmb := M->EEC_DTEMBA

               //DFS - 03/06/13 - Inclusão de ponto de entrada para manipulação das datas.
               If EasyEntryPoint("EECAE100")
                  ExecBlock("EECAE100",.F.,.F.,{"FECHAMENTO_EMBARQUE"})
               Endif

               //DFS - 03/06/13 - Mudança no tratamento para customização via ponto de entrada.
               If (nOpc == INCLUIR .OR. Empty(dDtEmb)) .AND. !Empty(dDtMemEmb)
                  cEvDtEmba := "072"
               ElseIf nOpc <> INCLUIR .AND. !Empty(dDtEmb) .AND. Empty(dDtMemEmb)
                  cEvDtEmba := "074"
               ElseIf nOpc <> INCLUIR .AND. dDtEmb <> dDtMemEmb
                  cEvDtEmba := "073"
               EndIf

               lEmbEstAdi := cEvDtEmba $ "073/074"

               If !Empty(cEvDtEmba) .AND. cEvDtEmba $ "073/074" .And. ( !IsIntEnable("001") .And. AvFlags("EEC_LOGIX") ) //NCF - 02/08/2017 - Não Duplicar título na integ. SIGAEEC x SIGAFIN
                  AE100EstAdi() //ESTORNO DA COMPENSACAO
                  AE100GerCom(.T.) //ESTORNO DE COMISSÕES BAIXADAS NO FINANCEIRO (deduzir/conta gráfica)
               EndIf

               //Processa({||lGravaOk:=AE100Grava(Inclui),If(!Inclui .And. lGravaOk,Ap101AtuFil(OC_EM),nil)})
               Processa({||lGravaOk:=AE100Grava(Inclui)}, , ,.F.)

               // CRF
               If lGravaOk
                  If nOpcA == 1
                     cChave := xFilial("EEC")+M->EEC_PREEMB
                     oMacroCAPA:SaveMacro(cChave)
                     oMacroDet:SaveMacro(cChave)
                  ElseIf nOpcA == 2
                     oMacroCAPA:SaveMacro()
                     oMacroDet:SaveMacro()
                  EndIf
               EndIf

               if AvFlags("DU-E3") .And. FindFunction("DUESeqHist") .And. FindFunction("getStatDUE");
                  .and. EEC->(FieldPos("EEC_DUEMAN")) > 0 .and. ! empty(EEC->EEC_DUEMAN)
                     cStatusDUE := getStatDUE(EEC->EEC_PREEMB,DUESeqHist(EEC->EEC_PREEMB))
                     if empty(cStatusDUE) .or. cStatusDUE <> "5" //.or. cStatusDUE == "5" .and. ! StDUERetif()
                        lMsErroAuto := .F.
                        aCapaEK0    := {}
                        aAdd(aCapaEK0,{"EK0_FILIAL", xFilial("EK0")  , Nil})
                        aAdd(aCapaEK0,{"EK0_PROCES", EEC->EEC_PREEMB , Nil})
                        // EasyMVCAuto("EECDU100",3,{{"EK0MASTER",aCapaEK0}})
                        MsExecAuto( { |x,y| EECDU100(x,y) },aCapaEK0,3 )
                     endif
                     DU400GrvStatus()
               endif

      		   If lGravaOk .AND. !Empty(cEvDtEmba)
	   		      lGravaOk := AvStAction(cEvDtEmba)
	      	   EndIf

               If lGravaOk .AND. cEvDtEmba $ "072/073" .And. ( !IsIntEnable("001") .And. AvFlags("EEC_LOGIX") ) //NCF - 02/08/2017 - Não Duplicar título na integ. SIGAEEC x SIGAFIN
                  AE100GerCom(.F.) //Geração de títulos a receber referente a comissão (deduzir/conta gráfica)
               EndIf

               lChangeEmb := !Empty(cEvDtEmba)

               //NCF - 27/01/2016 - CONTABILIZAÇÃO                         //Default é .F.                           
               IF !EasyGParam("MV_EEC_ECO",,.F.) .AND. EasyGParam('MV_EEC0048',,.T.) .And. FindFunction("L50EGERCTB") //se o modulo sigaeco estiver desligado                  
                  IF nOPC <> 3  .and. lChangeEmb .And. FindFunction("L50ERETREG")//!EMPTY(SW6->W6_DT_EMB)//IF !EMPTY(SW6->W6_DT_EMB)
                     aRegs:= EasyExRdm("L50ERETREG", xFilial("EEC"),EEC->EEC_PREEMB,"'121'",'')
                     EasyExRdm("L50ECANCTB", aRegs)
                  ENDIF                  
                  IF !EMPTY(EEC->EEC_DTEMBA)
                     EasyExRdm("L50EGERCTB",'TE')
                  ENDIF
               ENDIF              
               If !lGravaOk
                  /* AAF 21/07/2017 - Não tem porque fazer este loop infinito.
                  IF Inclui
                     While __lSX8
                        ELinkRollBackTran()
                     Enddo
                  Endif
                  */
                  //Help(" ",1,"A110NAORE")
                  //EasyHelp(STR0260) //"A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
                  ELinkRollBackTran()
               Else

                  //Processa Gatilhos
                  EvalTrigger()
                  If __lSX8
                    ConfirmSX8()
                  Endif
               Endif

            End Transaction

            If lGravaOk 
                If lPedAdia .Or. lCliAdia
                    Private lShowMsg := .T.
                    IF EasyEntryPoint("EECAE100")
                        ExecBlock("EECAE100",.F.,.F., "MSG_ADIANT_NAO_UTILIZADO")
                    Endif
                    If lShowMsg .and. !lAE100Auto
                        EECMsg(STR0121+ENTER+; //"Este embarque possui adiantamento(s) não utilizado(s)."
                            STR0122,STR0063) //"Faça a vinculação do(s) mesmo(s) na manutenção de adiantamento(s)."###"Aviso"
                    EndIf
                EndIf
            Else
                EasyElinkError("FIN", !lAE100Auto)
            EndIf
            If !AvFlags("EEC_LOGIX")
                ELinkClearID()
            EndIf
            bOnError := {|cFunName,nOpc| AP101RevReg(cFuncName,nOpc) }    //NCF - 08/08/2014 - Reverter dados de algumas tabelas quando integrado ao Logix em modo de alteração
            If lEaiBuffer .And. !EasyEAIBuffer("FIM",bOnError,lChangeEmb) //     de registro e o retorno Logix for inválido.
               If EEC->EEC_DTEMBA == dDtEmbarque
                  Exit
               EndIf
               M->EEC_DTEMBA := dDtEmbarque
               M->EEC_FIM_PE := dDtFim
               M->EEC_STATUS := cStEmb
               M->EEC_STTDES := cDescStEmb
               lDtEmba := !lDtEmba

               If nOpc == INCLUIR
                  nOpc := ALTERAR
               EndIf

               M->EXL_LOTCON := EXL->EXL_LOTCON //Carregar com o conteudo da base, que está atualizado com relação a integração.
            Else
               Exit
            EndIf

         Next
      EndIf
   Endif

   IF EasyEntryPoint("EECPEM41")
      ExecBlock("EECPEM41",.F.,.F.,{"FINAL",nOpca})
   Endif

   If nOpc == EXCLUIR
      If EEC->(Bof()) .Or. EEC->EEC_FILIAL <> xFilial("EEC")
         EEC->(DbSeek(xFilial("EEC")))
      EndIf
   EndIf

   //RRC - 13/12/2013 - Integração SIGAEEC x SIGAESS (Despesas Internacionais)
   If lEECESS .And. ValType(lGravaOk) == "L" .And. lGravaOk .And. (!Empty(EEC->EEC_DTEMBA) .Or. nOpc == ALTERAR .Or. nOpc  == EXCLUIR)
      Processa({|| AE100ESS(EEC->EEC_PREEMB,nOpc) }, "Integração SISCOSERV") //RMD - 31/08/17 - Incluida janela de processamento
   EndIf

End Sequence

aItemEnchoice := aClone(aEnchoiceAux)
aHdEnchoice   := aClone(aHdEnchAux)

dbSelectArea(cOldArea)

//If(lIntDraw .and. lOkEE9_ATO, ED3->(msUnlockAll()) ,)
If lIntDraw  .And.  lMUserEDC
   oMUserEDC:Fim()  // PLB 05/12/06 - Solta registros presos e reinicializa objeto
EndIf

//AOM - 28/04/2011 - Operacao Especial
If AvFlags("OPERACAO_ESPECIAL")
   oOperacao:DeleteWork()
EndIf

RestOrd(aOrd)

/* by jbj - 09/06/05 - Irá disparar o camando MsUnLockAll() para todas as tabelas utilizadas
                       na rotina de embarque e pedido. */
Ae100UnLock()
/*@lValLC*/ lValLC := .F. //LGS-04/07/2014
Return lRet

/*
Funcao     : AE100CANCE(cAlias,nReg,nOpc)
Objetivos  : Executa a operação de cancelamento do embarque, criando a variável lAE100CANCE para indicar a sub-operação do processo de exclusão.
Autor      : Rodrigo Mendes Diaz
*/
Function AE100CANCE(cAlias,nReg,nOpc)
Private lAE100CANCE := .T.
Return AE100MAN(cAlias,nReg,nOpc)

/*
Funcao     : AE100DEV(cAlias,nReg,nOpc)
Objetivos  : Executa a operação de cancelamento por devolução do embarque, criando a variável lAE100DEV para indicar a sub-operação do processo de exclusão.
Autor      : Rodrigo Mendes Diaz
*/
Function AE100DEV(cAlias,nReg,nOpc)
Private lAE100DEV := .T.
Return AE100MAN(cAlias,nReg,nOpc)

/*
Funcao      : Ae100AutoItens
Parametros  : aAuto - Array Multidimensional com os itens a serem atualizados
Objetivos   : Efetuar a integração automática de itens do embarque
Autor       : Rodrigo Mendes Diaz
*/
Function Ae100AutoItens(aAuto)
Local aPedidos := {}
Local lRet := .T.
Local i, j

    //Identifica os pedidos envolvidos entre os itens integrados e registra no array a Pedidos
    For i := 1 To Len(aAuto)
        If (j := aScan(aAuto[i], {|x| x[1] == "EE9_PEDIDO" })) > 0 .And. aScan(aPedidos, aAuto[i][j][2]) == 0
            aAdd(aPedidos, Avkey(aAuto[i][j][2], "EE8_PEDIDO"))
        EndIf
    Next

    //Para cada pedido informado, executa a função EECPME01 para carregar os itens envolvidos na WorkIp
    For i := 1 To Len(aPedidos)
        EECPME01(aPedidos[i])
    Next

    //Executa a integração automática dos itens
    AE100DetMan(, aAuto)

Return Nil

/*
Funcao      : AE100Grava(lInclui,lIntegracao)
Parametros  : lIntegracao => Chamada a partir de integração.
Retorno     :
Objetivos   :
Autor       : Cristiano A. Ferreira
              Heder M Oliveira
Data/Hora   : 02/08/99 10:30
Revisao     : WFS - Revisão dos tratamentos de saldo para itens da grade
Obs.        :
*/
Function AE100Grava(lInclui, lIntegracao, lAuto)

Local nSelect := Select()
Local lRet := .F.

Local aOrd := SaveOrd({"EEK","EE7","EE9","EE8","SE1"})

// Declara array aProcs.
// aProcs por dimensao:
//    aProcs[n,1] := Nro. do Processo
//    aProcs[n,2] := Status:
//       1, o Processo foi marcado.
//       2, nao sera necessario alterar o status do Processo.
//       3, o Processo foi desmarcado.
Local aProcs := {}
Local nProc  := 0, i, lALTSTS:=.T., nQtde, lTemSaldo:=.F. // bLastHandler // JBJ
Local nCubagem, nOrdEE9
Local nTotComis := 0, nTotFob := 0,nComisItem:=0
Local cForn, nTaxaFob, cMoedaFob, cCCAux
Local cProc
Local nOrderSX3 := SX3->(IndexOrd())
Local lOkEE9_CC, lTemAgente:=.f., xi:=0, z:=0, nInc:=0
Local nRecnoIt := 0

Local lITCubagem := EasyGParam("MV_AVG0010", .F., .F., xFilial("EE7"))
Local nITCubagem := 0
Local nCountAg   := 0, lMensaAg
Local lFirst     := .f.

Local aProc:= {} //AAF 09/03/05
Local aDespInt, nRec
Local nPesoLiq  := 0 //LRL 11/03/05
Local nPesoBru  := 0 //LRL 11/03/05

Local nRecnoEEC := 0
Local aOrdEEC

Local lVerNFDev := .F. //ER - 06/03/2007
Local nQtdDev   := 0
Local aOrdEE8   := {}
Local aOrdSF2   := {} //LRS = 29/05/2015
Local cFatIt    := ""

Local aFil      := {}, cFil := ""

Local nTotAdia := 0

Local lAltPedAdian := .T.

//RMD - 15/01/08 - Define se serão eliminados os resíduos do pedido de venda no faturamento
Local lElimResFat := .F.
Local lChkResFat  := .F.

Local aAdEFF := {}
Local aChaves := {}

Local dAntDtemba := EEC->EEC_DTEMBA

Local cOldFilter
Local bOldFilter

Local lGerouTit := .F.
Local lGeraTit  := .F.

Local aTit := {},;
      nCont:= 0
Local aParcelas := {}     //LGS - 14/08/2015
Local lTitparcelas := .F. //FSM - 27/08/2012
Local nTotPesoBrt  := 0   //LGS - 19/03/2015
Local dInvo := M->EEC_DTINVO // CtoD("  /  /  ") //LRS - 10/08/2017
Local aOrdWorkInv   := {} //LRS = 10/08/2017
Local cNroDue     := ""
Private cMoeda    := ""
Private cTitFin   := ""
Private cFinNum   := ""
Private cParcFin  := ""
Private cNatFin   := ""
Private cTipTit   := ""
Private cFinForn  := ""
Private cFinLoja  := ""
Private nMoeFin   := 0
Private nValorFin := 0
Private dDtEmis
Private dDtVenc

Private lEEQAuto := .F.
Private bEEQAuto

Private aParcAlter := {}
Private aAltProc:= {} // AAF - 09/03/05 Processos a replicar alterações.
Private lAcertaSld := .T. //JPM - Variável private para ser alterada por ponto de entrada.

If Type("lItFabric") <> "L"
   Private lItFabric := EasyGParam("MV_AVG0138",,.F.)
EndIf

Default lIntegracao := .f.
Default lAuto := .F.

If Type("lSched") <> "L"
   Private lSched := lAuto
EndIf
If lSched .And. Type("oEECLog") <> "O"
   Private oEECLog := EECLog():New()
EndIf

If ValType(lITCubagem) <> "L"
   lITCubagem := .F.
EndIf

Private lGerAdEEC := .F.
If EasyGParam("MV_EFF0006",.T.)
   lGerAdEEC := EasyGParam("MV_EFF0006",,.F.)
EndIf

If EasyEntryPoint("EECAE100")
   ExecBlock("EECAE100",.F.,.F.,{"GRV_EMBARQUE_INI"})
EndIf

//JPM - 10/03/05
If lReplicacao
   nRec := EEC->(RecNo())

   If lAcertaSld
      //executa acerto no saldo de itens do pedido
      Ae108AtuSld(.t.)
   EndIf

   //Atualiza campos do processo de origem
   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial()+aDadosOffShore[1][3]))
   EEC->(RecLock("EEC",.f.))
   For i := 1 to Len(aDadosOffShore)
      If !Empty(aDadosOffShore[i][2])
         EEC->&(aDadosOffShore[i][2]) := aDadosOffShore[i][3]
      EndIf
   Next
   EEC->(DbGoTo(nRec))

EndIf


SX3->(DBSETORDER(2))
lOkEE9_CC  := SX3->(dbSeek("EE9_CC"))
SX3->(DBSETORDER(nOrderSX3))

//AMS - 30/07/2004 às 17:09.
EE8->(dbSetOrder(1))

Private cInvoice, Wind, nTotalR:=0, a_CC:={}

//WFS - 12/01/09
If EECFlags("INTERMED")
   If Type("cConsolida") == "U"
      cConsolida := Ap104StrCpos(aConsolida)
   EndIf
EndIf

Begin Sequence

   //Prepara objeto para receber as mensagens retornadas pelas funções de gravação,
   //para não exibir mensagens na tela quando for chamada a partir de rotinas agendadas
   If lSched
      oEECLog:AddProc(StrTran(StrTran(STR0188 , "XXX", AllTrim(M->EEC_PREEMB)), "YYY", xFilial("EEC")))//"Gravação do embarque número: 'XXX' na filial: 'YYY'"
   EndIf


   //GFP - 19/05/2011
   If AvFlags("WORKFLOW")
      aChaves := EasyGroupWF("EMBARQUE_EEC")
   EndIf

   If !lIntegracao
      ProcRegua(LEN(aDeDeletados)+WorkDe->(EasyRecCount("WorkDe"))+;
                LEN(aAgDeletados)+WorkAg->(EasyRecCount("WorkAg"))+;
                LEN(aNFDeletados)+WorkNF->(EasyRecCount("WorkNF"))+;// AWR Sexta Feira 13/08/1999
                LEN(aInDeletados)+WorkIn->(EasyRecCount("WorkIn"))+;
                LEN(aNoDeletados)+WorkNo->(EasyRecCount("WorkNo"))+;
                WorkIP->(EasyRecCount("WorkIP"))+3)

      IncProc(STR0018+Transf(M->EEC_PREEMB,AvSx3("EEC_PREEMB",AV_PICTURE))) //"Gravando dados do Processo: "
   EndIf

   If EECFlags("INTTRA") .AND. Type("aHDEnchoice") == "A"   //TRP - 13/03/2013
      //RMD - 29/11/09 - Registra o histórico de alterações no processo.
      cHistorico := Ae110MonHistProc("EEC", "EEC", "M")
      cHistorico += Ae110MonHistProc("EXL", "EXL", "M")
      If !Empty(Alltrim(cHistorico))
         Ae110CadHistProc(OC_EM, M->EEC_PREEMB, "", cHistorico)
      EndIf
   EndIf

   If !EECFlags("COMISSAO")
      // ** By JBJ - 02/04/02 14:32 - Carrega o valor FOB e a % de comissao...
      nTotFob := (M->EEC_TOTPED+M->EEC_DESCON)-(M->EEC_FRPREV+M->EEC_FRPCOM+M->EEC_SEGPRE+M->EEC_DESPIN+AvGetCpo("M->EEC_DESP1")+AvGetCpo("M->EEC_DESP2"))
      If M->EEC_TIPCVL="1"
         nTotComis := M->EEC_VALCOM  // Percetual (Pegar direto)
      ElseIf M->EEC_TIPCVL="2"
         nTotComis := Round(100*(M->EEC_VALCOM/nTotFob),2)
      ElseIf M->EEC_TIPCVL="3"
         SetComissao(OC_EM)  // ** By JBJ 25/03/03 - 15:54. (Cálculo da comissao por item).
      EndIf
   Else
      If !AvFlags("COMISSAO_VARIOS_AGENTES")
         // ** Efetua rateio para calcular o percentual para os agentes com comissão do tipo 'Valor Fixo'.
         EECComVlFix(OC_EM)
      EndIf

      // JPM - 27/01/05 - Não são mais dadas mensagens referentes a agentes na gravação quando está ativo o
      // novo tratamento de comissão com mais de um agente por item, exceto quando são agentes de perc. p/
      // item e em nenhum item há agentes preenchidos.

      If AvFlags("COMISSAO_VARIOS_AGENTES")
         If lTemAgente
            EECTotCom(OC_EM,, .T.)
         EndIf
      EndIf

	  // LGS - 15/10/13 - Quando um item é desmarcado do embarque, pesquisa o mesmo na tabela "EXA" - Lotes Por Container e faz a exclusão do mesmo
      If EasyGParam("MV_AVG0005",,.F.)
      	WorkIp->(DbGoTop())
       	DbSelectArea("EXA")
       	DbSetOrder(2)
	    Do While WorkIP->(!Eof())
	    	 If WorkIP->(!Eof()) .And. Empty(WorkIP->WP_FLAG)
	   			EXA->(DbSeek(xFilial("EXA") + WorkIP->EE9_PREEMB + WorkIP->EE9_SEQEMB))
				If !Empty(EXA->EXA_COD_I)
		 			If EXA->EXA_COD_I  == WorkIP->EE9_COD_I .And.;
		 			   EXA->EXA_SEQEMB == WorkIP->EE9_SEQEMB
		 			     EXA->(dbGoTo(Recno()))
		    			 EXA->(RecLock("EXA",.F.))
		    			 EXA->(dbDelete())
		    			 EXA->(MsUnlock())
		    		EndIf
		    	EndIf
	     	    WorkIP->(DbSkip())
             Else
              WorkIP->(DbSkip())
             EndIf
	    EndDo
      EndIf
      /* by jbj - Acumular os valores de comissão dos agentes e gravar no campo de valor da comissao
                  na capa do processo.
                - Gravação do campo EEB_FOBAGE com o valor FOB total dos itens em que o agente foi
                  vinculado.  */

      WorkAg->(DbGoTop())
      M->EEC_VALCOM := 0
      lTemAgente    := .f.
      lFirst        := .t.
      nCountAg      := 0

      Do While WorkAg->(!Eof())
         If SubStr(WorkAg->EEB_TIPOAG,1,1) = CD_AGC  // Considera apenas os agentes recebedores de comissao.

            If lFirst
               M->EEC_TIPCOM := WorkAg->EEB_TIPCOM
               M->EEC_TIPCVL := "2" // Valor fixo.
               M->EEC_REFAGE := WorkAg->EEB_REFAGE
               lTemAgente := .t.
               lFirst     := .f.
            EndIf

            // ** Acumula o total de comissão.
            M->EEC_VALCOM += WorkAg->EEB_TOTCOM

            If EEB->(FieldPos("EEB_FOBAGE")) > 0
               WorkAg->EEB_FOBAGE := SumFobItEmb(WorkAg->EEB_CODAGE,WorkAg->EEB_TIPCOM)
            EndIf

            // ** Caso existirem agentes com tipo de comissão diferetes a capa do processo fica em branco..
            If M->EEC_TIPCOM <> WorkAg->EEB_TIPCOM
               M->EEC_TIPCOM := " "
            Endif
            nCountAg += 1
         EndIf
         WorkAg->(DbSkip())
      EndDo

      /* Caso existir mais de um agente de comissão a refencia do agente na capa do processo
         é gravada em branco. */
      If nCountAg > 1
         M->EEC_REFAGE := ""
      Endif

      If !lTemAgente  // Caso nenhum agente seja encontrado os valore de comissao da capa são zerados.
         M->EEC_VALCOM := 0
         M->EEC_REFAGE := ""
         M->EEC_TIPCOM := ""
         M->EEC_TIPCVL := ""
      EndIf
   EndIf

   // ** By CAF - 29/04/2002 - 13:58 - Correção no calculo do preco I (Compatibilização 508)
   Ae100PrecoI(.t., .f.)

   // ** By JBJ - 14/12/02 - 17:20 - Gravação do campo EEC_NRINVO, caso vazio.
   If Empty(M->EEC_NRINVO)
      M->EEC_NRINVO := AvKey(AllTrim(M->EEC_PREEMB),"EEC_NRINVO")
   EndIf

   // ** By JBJ - 10/11/03 - Gravação de chave para ordenação de processos.
   If lInclui .And. EECFlags("ORD_PROC")
      M->EEC_VLNFC := AP101GetKey(OC_EM)
   EndIf

   If EECFlags("HIST_PRECALC")
      /* Tratamentos para apuração de despesas de acordo com o cadastro de tabela de pré-calculo.
         Inclusão e alteração de processos de embarque. */

      //DFS - 29/11/12 - Caso não exista a variavel de memoria, cria de acordo com o campo.
      If Type("M->EXL_TABPRE") == "U"
         M->EXL_TABPRE := CriaVar("EXL_TABPRE")
      EndIf

      Do Case
         Case !lInclui .And. !Empty(M->EXL_TABPRE)
              If !Ae104TrataValores(.t.)
                 M->EXL_TABPRE := ""
              EndIf

         Case (lInclui .And. !Empty(M->EXL_TABPRE))
              If !aE104ApuraDesp() // Apura e grava a work das despesas.
                 M->EXL_TABPRE := ""
              EndIf

         Case Empty(M->EXL_TABPRE)
            dbselectarea("WorkCalc")
            WorkCalc->(DbGoTop())
            If !WorkCalc->(Bof() .And. Eof())
               Do While WorkCalc->(!Eof())
                  aAdd(aPreCalcDeletados,WorkCalc->WK_RECNO)
                  WorkCalc->(DbDelete())
                  WorkCalc->(DbSkip())
               EndDo
            EndIf
      End Case
   EndIf

   //JPM - 21/12/04 - 17:18 - Atualização dos campos de saldo da carta de crédito
   If lNRotinaLC /* .And. (!lIntermed .Or. cFilEx <> xFilial("EEC")) */ // Nova rotina de Carta de Crédito
      If lReplicacao
         If !Empty(M->EEC_LC_NUM)
            AAdd(aDesvinculados,{cFilEx,M->EEC_PEDREF})
         EndIf
         If EECFlags("ITENS_LC")
            WorkIp->(DbGoTop())
            While WorkIp->(!Eof())
               If !Empty(WorkIp->EE9_LC_NUM) // Se não estiver vazio o nro da lc
                  If !Empty(WorkIp->EE9_SEQ_LC) .Or.; // só considera a seq. da L/C vazia se a L/C não controlar produtos.
                     Posicione("EEL",1,cFilEx+WorkIp->EE9_LC_NUM,"EEL_CTPROD") $ cNao

                     AAdd(aItensDesv,{cFilEx,M->EEC_PEDREF,WorkIp->EE9_SEQEMB})
                  EndIf
               EndIf
               WorkIp->(DbSkip())
            EndDo
         EndIf
      EndIf

      AE107AtuLC(lInclui)
   Endif

   //JPM - Alteração em valores após o embarque
   If lDtEmba .And. lAltValPosEmb .And. !Empty(M->EEC_DTEMBA)

      EEC->(DbSetOrder(1))
      EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))

      aParcelas := AF200TotParc(xFilial("EEC"))
      nTotPed   := aParcelas[1]
      nPgtAdt   := aParcelas[3] //LGS-14/08/2015

      If nPgtAdt > 0
         AAdd(aParcAlter,{M->EEC_TOTPED - nTotPed,"101",nPgtAdt})
      Else
         AAdd(aParcAlter,{M->EEC_TOTPED - nTotPed,"101"})
      EndIf

      If EECFlags("FRESEGCOM")
         If Type("M->EXL_MDFR") == "C"
            EC6->(DbSetOrder(1))
            EXL->(DbSetOrder(1))
            EXL->(DbSeek(xFilial("EXL")+M->EEC_PREEMB))

            aDespInt := X3DIReturn()

            For i := 1 to Len(aDespInt)

               If !EasyGParam("MV"+SubStr(aDespInt[i][2], 4), .T.)
                  Loop
               EndIf

               If !EC6->(DbSeek(xFilial("EC6")+AVKey("EXPORT", "EC6_TPMODU")+AVKey(EasyGParam("MV"+SubStr(aDespInt[i][2], 4)), "EC6_ID_CAM")))
                  Loop
               EndIf
               AAdd(aParcAlter,{&("M->EXL_VD"+aDespInt[i][1]) -;
                                &("EXL->EXL_VD"+aDespInt[i][1]),EasyGParam("MV"+SubStr(aDespInt[i][2], 4))})
            Next
         EndIf

         WorkAg->(DbGoTop())
         EEB->(DbSetOrder(1))
         While WorkAg->(!EoF())
            If Left(WorkAg->EEB_TIPOAG,1) <> CD_AGC
               WorkAg->(DbSkip())
               Loop
            EndIf
            EEB->(DbSeek(xFilial()+M->EEC_PREEMB+OC_EM+WorkAg->(EEB_CODAGE+EEB_TIPOAG)+;
                         If(FieldPos("EEB_TIPCOM") > 0,WorkAg->EEB_TIPCOM,"")           ))//JPM - 02/06/05
            If AvFlags("EEC_LOGIX") .And. WorkAg->EEB_TIPCOM == "3" .And. EasyGParam("MV_EEC0025",,.T.)
                AAdd(aParcAlter,{WorkAg->EEB_TOTCOM - TOTCOMEEQ(M->EEC_PREEMB,"122"),"122"})
            Else
                AAdd(aParcAlter,{WorkAg->EEB_TOTCOM - EEB->EEB_TOTCOM,;
                                If(WorkAg->EEB_TIPCOM = "1","120",If(WorkAg->EEB_TIPCOM = "2","121","122"))})
            EndIf
            WorkAg->(DbSkip())
         EndDo
      EndIf
   EndIf

   If lInclui    // By JPP - 05/08/2005 - 14:45 - Não permite Incluir processos com o mesmo Código.
      EEC->(DbSetOrder(1))
      Do While .t.
         If lIntegracao
            If EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))
               AE102TelaNProc(.T.)  // Exibe Mensagem de Cancelamento da gravação no servidor
               Break
            Else
               Exit
            EndIf
         Else
            If EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))
               If ! AE102TelaNProc(.F.) // Exibe tela solicitando a digitação de novo codigo para o processo.
                  Break
               EndIf
            Else
               Exit
            EndIf
         EndIf
      EndDo
   EndIf

   If lIntegra

      If lIntEmb

         ///////////////////////////////////////////////////
         //Integração com Faturamento (Gravação)          //
         //Geração de Pedido de Venda a partir do Embarque//
         ///////////////////////////////////////////////////
         If !(lBackTo .and. Ap106IsBackTo()) .or. (lConsign .and. (ValType(cTipoProc) == "C" .and. (cTipoProc == PC_BC .or. cTipoProc == PC_RC )))

            ////////////////////////////////////////////////
            //Realiza novas validações para verificar se o//
            //Pedido de Venda poderá ser gerado através   //
            //do Embarque (Nova Integração.)              //
            ////////////////////////////////////////////////
            If FAT3IntFat(M->EEC_PREEMB,If(lInclui,INCLUIR,ALTERAR))

               lRet := FAT3EmbGerPV(If(lInclui,INCLUIR,ALTERAR),"GRV")
               If !lRet
                  Break
               Endif
            EndIf
         EndIf
      EndIf

      //ER - 06/03/2007 - Verifica se existe Parcela de Cambio para Notas de Devolução
      If Empty(M->EEC_DTEMBA) .and. !Empty(EEC->EEC_DTEMBA)  .And.  FindFunction("FAT3VerNFDev")
         lVerNFDev := .T. //Irá verificar a Presença de NFs de Devolução
      EndIf
   EndIf

   If IsIntEnable("001")
      If !(lRet := EECBxFiTit())//Baixa de titulos gerados pelo faturamento no SIGAFIN e compensação dos títulos de RA
         Break
      EndIf

      If !(lRet := AE100DespPr())
         Break
      EndIf
   EndIf

   // ***** Grava capa do embarque ***** \\
   // Alterado por Heder M Oliveira - 2/15/2000
   // *** by CAF 16/08/2000 17:10 Problemas com o envio ao SISCOMEX 3M AE100CRIT("EEC_NPARC") //RECALCULAR VALOR DA PARCELA, ESTUDAR MAIS POSSIBILIDADES DE ALTERACAO
   E_Grava("EEC",lInclui)

   If EasyGParam("MV_EEC0037",,.F.)  // GFP - 08/01/2013
      If EEC->(RecLock("EEC",.F.))
         EEC->EEC_QTDEMB := M->EEC_QTDEMB
         EEC->(MsUnlock())
      EndIf
   EndIf

   If EEC->(FieldPos("EEC_VLRIE")) # 0 .AND. WorkIP->(FieldPos("EE9_VLRIE")) > 0 // GFP - 17/12/2015 - LRS - 21/01/2016
      If EEC->(RecLock("EEC",.F.))
         EEC->EEC_VLRIE := AE100VLRIE(2)
         EEC->(MsUnlock())
      EndIf
   EndIf

   If EEC->(FieldPos("EEC_NRODUE") > 0)
      cNroDue:= EEC->EEC_NRODUE
   EndIf

   //LRS - 09/08/2017
   aOrdWorkInv := SaveOrd({"WorkInv"})
 
   WorkInv->(DBGoTop())

   While WorkInv->(!EOF()) //.and. WorkInv->EXP_PREEMB == M->EEC_PREEMB
      IF Empty(dInvo) .or. WorkInv->EXP_DTINVO > dInvo
         dInvo:= WorkInv->EXP_DTINVO
      EndIF
      WorkInv->(DbSkip())
   EndDo

   If EEC->(RecLock("EEC",.F.))
      EEC->EEC_DTINVO := dInvo
      EEC->(MsUnlock())
   EndIF
   RestOrd(aOrdWorkInv)

   // GFP - 15/01/2013
   If( EasyEntryPoint("EECAE100") , ExecBlock("EECAE100",.F.,.F.,{"GRV_CPOS_CUSTOM"}) , )

   // Gravacao dos campos memo ...
   If !lInclui // Alteracao - registros excluir
      MSMM(M->EEC_CODMAR,,,,EXCMEMO)
      MSMM(M->EEC_DSCGEN,,,,EXCMEMO)
      MSMM(M->EEC_CODOBP,,,,EXCMEMO)
      MSMM(M->EEC_CODMEM,,,,EXCMEMO)
      If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-12/11/2015
         MSMM(M->EEC_INFCOF,,,,EXCMEMO)
      EndIf
   Endif

   MSMM(,AVSX3("EEC_MARCAC",AV_TAMANHO),,M->EEC_MARCAC,INCMEMO,,,"EEC","EEC_CODMAR")
   MSMM(,AVSX3("EEC_GENERI",AV_TAMANHO),,M->EEC_GENERI,INCMEMO,,,"EEC","EEC_DSCGEN")
   MSMM(,AVSX3("EEC_OBSPED",AV_TAMANHO),,M->EEC_OBSPED,INCMEMO,,,"EEC","EEC_CODOBP")
   MSMM(,AVSX3("EEC_OBS",AV_TAMANHO),,M->EEC_OBS,INCMEMO,,,"EEC","EEC_CODMEM")
   If EEC->(FieldPos("EEC_INFGER")) # 0  // GFP - 28/05/2014
      MSMM(,AVSX3("EEC_VMINGE",AV_TAMANHO),,M->EEC_VMINGE,INCMEMO,,,"EEC","EEC_INFGER")
   EndIf
   If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-30/10/2015
      If Type("EEC_VMDCOF") == "U"
         M->EEC_VMDCOF := ""
      EndIf
      MSMM(,AVSX3("EEC_VMDCOF",AV_TAMANHO),,M->EEC_VMDCOF,INCMEMO,,,"EEC","EEC_INFCOF")
   EndIf
   // ***** ////////////////////// ***** \\

   // ***** Gravacao das Despesas/Agentes/Instituicoes/NFs ***** \\
   // BAK - Tratamento para Roolback
   lRet := AP100DSGrava(.F.,OC_EM,lIntegracao)
   If Valtype(lRet) == "L" .And. !lRet  // GRAVAR EET  // GFP - 15/01/2013
      Break
   EndIf

   AP100AGGrava(.F.,OC_EM,lIntegracao)  // GRAVAR EEB
   AP100INSGrava(.F.,OC_EM,lIntegracao) // GRAVAR EEJ
   AP100NoGrv(.F.,OC_EM,lIntegracao)    // GRAVAR EEN
   AE101Grava(.F.,aNFDeletados,lIntegracao)// GRAVAR EEM AWR Sexta Feira 13/08/1999

   /////////////////////////////////////////
   //ER - 14/11/2008                      //
   //Gravação das Notas Fiscais de Remessa//
   /////////////////////////////////////////
   If AvFlags("FIM_ESPECIFICO_EXP")
      AE110GravaNfRem(aNfRemDeletados)
   EndIf

   If EECFlags("INVOICE")  // ** By OMJ - 17/06/05 - Manutenção de Invoice.
      AE108InvGrv(.F.,"CAPA"   ,lIntegracao)    // GRAVAR EXP
      AE108InvGrv(.F.,"DETALHE",lIntegracao)    // GRAVAR EXR
   EndIf

   //If lConsign //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
      If Empty(M->EEC_TIPO) .Or. M->EEC_TIPO $ (PC_RC+PC_BC+PC_VR+PC_VB)
         //RMD - 04/05/06 - Atualiza a tabela de produtos estocados em consignação.
         Ae108AtuEstoque(nSelecao, M->EEC_TIPO)
         If M->EEC_TIPO $ (PC_VR+PC_VB)
            //RMD - 11/05/06 - Grava tabela de vinculação entre o embarque e os armazéns
            Ae108CSGrava()
         EndIf
      EndIf
   //EndIf
   If EECFlags("CAFE") .And. (Type("cStatus") <> "C" .Or. !(cStatus $ ST_WI+ST_WO+ST_WN+ST_WR+ST_WA))
      Ae108WkOIC(.T.,"EXZ") //Grava tabelas referentes a Manutenção de OIC´s
      Ae108WkOIC(.T.,"EY2")
      Ae109GrvArm()//Grava Tabela de armazens de café
   EndIf
//WFS - 14/01/09
//   If lItFabric  // By JPP - 14/11/2007 - 14:00
   If Type ("lItFabric") == "L" .And. lItFabric
      AE109WKEYU(.T.,"EYU")
   EndIf

   //TRP - 17/02/2009 - Gravação dos insumos do produto exportado.
   If Type ("lDrawSC") == "L" .and. lDrawSC
      AE100GrvInsumos()
   Endif
   //TRP - 29/1010 - Gravacão de Notas Fiscais
   If ChkFile("EWI")
       AE109WKEWI(.T.,"EWI")
   Endif
   If lOkYS_PREEMB .AND. EasyGParam("MV_EEC_ECO",,.F.)
      AE100CCGrv(.F.)          // GRAVAR SYS
   EndIf

   If EasyEntryPoint("EECAE100") //ER - 06/10/2006
      ExecBlock("EECAE100",.F.,.F.,"PE_GRAVA")
   EndIf

   If !lIntegracao
      // ** By JBJ - 12/08/2002 - 17:19
      // ** Grava os dados da agenda... (EXB)
      IF Select("WorkDoc") > 0 .And. Select("EXB") > 0
         If WorkDoc->(EasyRecCount("WorkDoc")) <> 0
            Ap100DocGrava(.f.,OC_EM) // Gravar EXB
         Else
            // ** Carrega os documentos obrigatorios para o importador ...
            AddTarefa(Posicione("SA1",1,xFilial("SA1")+M->EEC_IMPORT+M->EEC_IMLOJA,"A1_PAIS"),M->EEC_IMPORT+M->EEC_IMLOJA,.f.)
            If WorkDoc->(EasyRecCount("WorkDoc")) <> 0
               Ap100DocGrava(.f.,OC_EM)
            EndIf
         EndIf
      Endif
   EndIf

   // ***** Exclui embalagens ***** \\
   IF !EasyGParam("MV_AVG0005") // Deixar de gravar embalagens ?
      EEK->(dbSetOrder(2))
      IF EEK->(dbSeek(xFilial()+OC_EM+M->EEC_PREEMB))
         While ! EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
               EEK->EEK_TIPO == OC_EM .And. EEK->EEK_PEDIDO == M->EEC_PREEMB
            EEK->(RecLock("EEK",.F.))
            EEK->(dbDelete())
            EEK->(MSUnlock())

            EEK->(dbSkip())
         Enddo
      Endif
   Endif
   // ***** ///////////////// ***** \\

   If EECFlags("COMPLE_EMB")
      Ae106Grava(lInclui)
   EndIf

   If EECFlags("HIST_PRECALC")
      AP100PreCalcGrv(.f.,OC_EM)
   EndIf

   // ***** Gravacao dos itens embarcados/embalagens ***** \\
   aNFApaga :={}//AWR - 29/09/2005

   If Type("lConsolida") <> "L"
      lConsolida:= .F.
   EndIf

   If Type("aAtuEstufagem") <> "A"
      aAtuEstufagem:= {}
   EndIf

   If(lIntDraw .and. lOkEE9_ATO , ED3->(dbSetOrder(2)) ,)
   WorkIP->(dbGoTop())

   While ! WorkIP->(EOF())

      If !Empty(WorkIP->WP_FLAG)
         If WorkIP->WP_RECNO <> 0
            //ER - 06/03/2007 - Verifica a Existencia de NFs de Devolução
            If lIntegra
               If lVerNFDev
                  aOrdEE8 := SaveOrd({"EE8","EE7","SC5"})  // GFP - 30/09/2014

                  EE8->(DbSetOrder(1))
                  If EE8->(DbSeek(xFilial("EE8")+WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN))
                     cFatIt := EE8->EE8_FATIT
                  EndIf

                  nQtdDev := FAT3VerNFDev(M->EEC_PREEMB,WorkIp->EE9_NF,WorkIp->EE9_SERIE,cFatIt)

                  If nQtdDev > 0
                     WorkIp->EE9_SLDINI := WorkIp->EE9_SLDINI - nQtdDev //Qtde da NF de Saída - Qtde da NF de Devolução

                     WorkIp->EE9_PSLQTO := WorkIp->EE9_SLDINI*WorkIp->EE9_PSLQUN //Peso Liquido Total
                     WorkIp->EE9_PSBRTO := WorkIp->EE9_SLDINI*WorkIp->EE9_PSBRUN //Peso Bruto Total

                     //Apaga o Saldo do item do Pedido
                     If EE8->(DbSeek(xFilial("EE8")+WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN))
                        EE8->(RecLock("EE8",.F.))
                        EE8->EE8_SLDATU := EE8->EE8_SLDATU - nQtdDev
                        EE8->(MsUnlock())
                     EndIf

                  EndIf

                  RestOrd(aOrdEE8)
               EndIf

            EndIf
         EndIf
      EndIf

      If !lIntegracao
         IncProc()
      Else
         //LRL 11/03/05-----------------------------------------------
         If (WorkIp->EE9_SLDINI % WorkIp->EE9_QE) != 0
             WorkIp->EE9_QTDEM1 := Int(WorkIp->EE9_SLDINI /WorkIp->EE9_QE)+1
         Else
             WorkIp->EE9_QTDEM1 := Int(WorkIp->EE9_SLDINI/WorkIp->EE9_QE)
         Endif
            Ap101CalcPsBr(OC_EM,.T.,lLibPes)
            nPesoBru+= WorkIp->EE9_PSBRTO
            nPesoLiq+= WorkIp->EE9_PSLQTO
         //-----------------------------------------------LRL 11/03/05
      EndIf

      nTotPesoBrt += WorkIp->EE9_PSBRTO

      IF (nProc:=aScan(aProcs,{|x| x[1] == WorkIP->EE9_PEDIDO})) == 0
         aAdd(aProcs, {WorkIP->EE9_PEDIDO,0})
         nProc := Len(aProcs)
      Endif

      IF EMPTY(WorkIP->WP_FLAG)
         IF WorkIP->WP_RECNO != 0
            // Desmarcou ...
            IF aProcs[nProc][2] == 0 .Or. aProcs[nProc][2] == 2
               aProcs[nProc][2] := 3
            Endif

            // *** CAF 07/06/2000 11:02
            IF lIntegra

               //////////////////////////////////////////////////////////////////////////////
               //ER - 04/12/2008                                                           //
               //Grava o Filtro da tabela EE7, para que filtros customizados não interfirem//
               //na busca da tabela.                                                       //
               //////////////////////////////////////////////////////////////////////////////
               cOldFilter := EE7->(dbFilter())
               bOldFilter := &("{|| "+if(Empty(cOldFilter),".T.",cOldFilter)+" }")

               ////////////////////////////
               //Apaga o filtro existente//
               ////////////////////////////
               If !Empty(cOldFilter)
                  EE7->(DbClearFilter())
               EndIf

               EE7->(DBSETORDER(1))
               EE7->(DBSEEK(XFILIAL("EE7")+WORKIP->EE9_PEDIDO))
               IF (EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM )
                  AE100GrvItSD2(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN," ",WorkIP->EE9_NF,WorkIP->EE9_SERIE)
               ENDIF

               /////////////////////
               //Restaura o filtro//
               /////////////////////
               If !Empty(cOldFilter)
                  EE7->(dbSetFilter(bOldFilter,cOldFilter))
               Endif

            Endif

            EE9->(DBGOTO(WorkIP->WP_RECNO))

            //AADD(aNFApaga,AvKey(EE9->EE9_NF,"EEM_NRNF")+AvKey(EE9->EE9_SERIE,"EEM_SERIE")) nopado por WFS em 21/09/09
            AADD(aNFApaga,AvKey(EE9->EE9_NF,"EEM_NRNF")+AvKey(EE9->EE9_SERIE,"EEM_SERIE") + EEM->(Ap101FilNf()))
            If lIntDraw .and. lOkEE9_ATO .and. !Empty(EE9->EE9_ATOCON) .and. !Empty(EE9->EE9_SEQED3)
               ED3->(dbSeek(cFilED3+EE9->EE9_ATOCON+EE9->EE9_SEQED3))
               If !ED3->( IsLocked() )
                  ED3->(RECLOCK("ED3",.F.))
               EndIf
               ED3->ED3_SALDO += EE9->EE9_QT_AC
               ED3->ED3_SALNCM += AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,EE9->EE9_QT_AC)
               If(M->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=EE9->EE9_VL_AC,ED3->ED3_SAL_SE+=EE9->EE9_VL_AC)

               If EE9->(FieldPos("EE9_VLSCOB")) > 0
                  ED3->ED3_SAL_SE+=EE9->EE9_VLSCOB
               EndIf

               //WFS 18/12/08 - 076773
               If EasyEntryPoint("EECAE100")
                  ExecBlock("EECAE100",.F.,.F.,"AE100GRAVA_SLD_ED3")
               EndIf
               ED3->(msUnlock())
               Ae101DelEDD() //AOM - 15/04/2010
            EndIf
            MSMM(EE9->EE9_DESC,,,,EXCMEMO)
            EE9->(RecLock("EE9",.F.))
            nQtde := EE9->EE9_SLDINI
            EE9->(dbDelete())
            EE9->(MSUnlock())

            If lIntegra .And. nQtde == 0 .And. !lChkResFat
               If AEFatSaldo(EE9->EE9_PEDIDO,EE9->EE9_SEQUEN) // TLM 31/01/2008 Verifica se a quantidade embarcada do item é igual a liberada pelo faturamento
                  If !lAuto
                     Do Case // SVG 26/08/08 1 exibe a mensagem , 2 Não exibe e elimina , 3 Não exibe e não elimina
                        Case EasyGParam("MV_AVG0169") == "1"
                           lElimResFat := MsgYesNo(STR0193, STR0035)//"Deseja eliminar os resíduos de todos os pedidos de venda associados ao embarque?"###"Atenção"
                        Case EasyGParam("MV_AVG0169") == "2"
                           lElimResFat := .T.
                        Case EasyGParam("MV_AVG0169") == "3"
                           lElimResFat := .F.
                     EndCase
                       //lElimResFat := MsgYesNo(STR0193, STR0035)//"Deseja eliminar os resíduos de todos os pedidos de venda associados ao embarque?"###"Atenção"
                     lChkResFat  := .T.
                  Else
                     lElimResFat := .T.
                  EndIf
               EndIf
            EndIf
            AE100Saldo(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,nQtde,.T., lElimResFat,WorkIp->EE9_COD_I)
         Endif

         If lConsolida .And. !lIntegra //JPM - 10/11/05
            WorkGrp->(DbSeek(WorkIp->(Ap104SeqIt()))) // Se o item não estiver marcado, mas o grupo estiver, então, atualiza o saldo, pois o usuário pode ter liquidado o saldo
            While WorkGrp->(!EoF()) .And. WorkIp->(Ap104SeqIt()) == WorkGrp->(EE9_PEDIDO+EE9_ORIGEM)
               If WorkGrp->&(cConsolida) == WorkIp->&(cConsolida) .And. WorkGrp->WP_FLAG <> "N"
                  EE8->(DbSeek(xFilial("EE8")+WorkIp->(EE9_PEDIDO+EE9_SEQUEN))) //posiciona no item de pedido correspondente
                  EE8->(RecLock("EE8",.f.))
                  EE8->EE8_SLDATU := WorkIp->WP_SLDATU
                  EE8->(MsUnlock())
                  Exit
               EndIf
               WorkGrp->(DbSkip())
            EndDo
         EndIf

         WorkIP->(dbSkip())
         Loop
      Endif

      IF !EasyGParam("MV_AVG0004 ",,.F.) //LRS - 1/10/2014 se a conferencia de peso estiver ativa não atualizar com o pso da EE9
         If EEC->(Islocked())
            EEC->EEC_PESBRU  := IF (nTotPesoBrt <> M->EEC_PESBRU, nTotPesoBrt, M->EEC_PESBRU) //WorkIp->EE9_PSBRTO    //LGS-19/03/2015
         Else
            Reclock("EEC",.F.) //MCF - 24/02/2014
            EEC->EEC_PESBRU  := IF (nTotPesoBrt <> M->EEC_PESBRU, nTotPesoBrt, M->EEC_PESBRU) //WorkIp->EE9_PSBRTO    //LGS-19/03/2015
            EEC->(Msunlock())
         EndIf
      EndIF

      If lOkYS_PREEMB .and. lOkEE9_CC  .AND. EasyGParam("MV_EEC_ECO",,.F.)
         //Prepara Array p/ SYS
         cInvoice := EEC->EEC_NRINVO
         cForn    := WorkIP->EE9_FORN
         cMoedaFob:= EEC->EEC_MOEDA
         //nTaxaFob := BuscaTaxa(cMoedaFob,dDataBase,.T.,.F.,.T.)
         cCCAux   := WorkIP->EE9_CC

         Ind:= ASCAN(a_CC,{|Tab|Tab[1]+Tab[2]+Tab[3] == cCCAux+cForn+cMoedaFob})
         IF Ind == 0
            AADD(a_CC,{cCCAux,cForn,cMoedaFob,WorkIP->EE9_SLDINI*WorkIP->EE9_PRECO,"H"})  //Alcir Alves - 08-11-05 - inclusão da posição 5 com o tipo de rateio
         ELSE
            a_CC[Ind,4]+=WorkIP->EE9_SLDINI*WorkIP->EE9_PRECO
         ENDIF

         nTotalR+=WorkIP->EE9_SLDINI*WorkIP->EE9_PRECO
      EndIf

      If WorkIP->WP_RECNO <> 0

         IF aProcs[nProc][2] == 0
            aProcs[nProc][2] := 2
         Endif

         EE9->(dbGoTo(WorkIP->WP_RECNO))

         RecLock("EE9", .F.)

         If lIntDraw .and. lOkEE9_ATO
            SaldosED3(.F.)
         EndIf

         /*
         Atualização do saldo no pedido.
         Autor : Alexsander Martins dos Santos
         Date e Hora : 02/08/2004 às 11:49.
         */
         // ** by jbj - 25/05/05 - Geração de log para documentar histórico de atualização de saldo do preço.
         If !lConsolida .And. !IsInCallStack("FAT3GRAVA") //NCF - 29/06/2018 - Não verificar quando o salto já estiver sido atualizado em tempo de execução por inclusão de nota de devolução no Compras
            If EE8->(dbSeek(xFilial()+WorkIP->(EE9_PEDIDO+EE9_SEQUEN)))
               RecLock("EE8", .F.)
               EE8->EE8_SLDATU += WorkIP->EE9_SLDINI
               EE8->(MsUnLock())
            Else
               EECMsg(STR0214+AllTrim(WorkIp->EE9_SEQEMB)+"'."+ENTER+; //STR0214	"O saldo do pedido não foi atualizado corretamente para o item: '"
                      STR0215,STR0035) //STR0215	"Enviar o arquivo saldo.log para a Trade-Easy"//STR0035	"Atenção"
               Ae100LogSaldo(lInclui)
            EndIf
         EndIf
      Else

         // IF aProcs[nProc][2] != 2
         aProcs[nProc][2] := 1
         // Endif
         RecLock("EE9",.T.)  // bloquear e incluir registro vazio
         If lIntDraw .and. lOkEE9_ATO
            SaldosED3(.T.)
         EndIf

      Endif

      If EECFlags("ESTUFAGEM")
         If (nPos := aScan(aAtuEstufagem, WorkIp->EE9_SEQEMB)) > 0 .And. WorkIp->EE9_SLDINI == EE9->EE9_SLDINI
            aDel(aAtuEstufagem, nPos)
            aSize(aAtuEstufagem, Len(aAtuEstufagem) - 1)
         EndIf
      EndIf

      AVReplace("WorkIP","EE9")

      EE9->EE9_FILIAL  := xFilial("EE9")
      EE9->EE9_PREEMB  := M->EEC_PREEMB
      If lIntDraw .and. lOkEE9_ATO
         EE9->EE9_FASEDR  := If(Empty(EE9->EE9_ATOCON), "" , "2")
      EndIf

      If !EECFlags("COMISSAO")
         // ** By JBJ - 01/04/2002 - 16:59  Impede comissao maior que 100%
         If M->EEC_TIPCVL = "1" .Or. M->EEC_TIPCVL = "2"
            EE9->EE9_PERCOM := If(nTotComis>99.99,99.99,Round(nTotComis,AVSX3("EE9_PERCOM",AV_DECIMAL)))
         EndIf
      EndIf

     //MFR 13/02/2020 OSSME-4353
     FOR I := 1 TO LEN(aMEMOITEM)
         IF EE9->(FIELDPOS(aMEMOITEM[I,1])) > 0
            if WorkIP->WP_RECNO # 0 //na alteração do campo memo gera primeiro a exclusão e em seguida a inclusão
               MSMM(EE9->&(aMEMOITEM[I,1]),,,,EXCMEMO) 
            EndIf   
            EE9->(MSMM(,AVSX3(aMEMOITEM[I,2],AV_TAMANHO),,WORKIP->&(aMEMOITEM[I,2]),INCMEMO,,,"EE9",aMEMOITEM[I,1]))
         ENDIF
     NEXT

      EE9->(MsUnlock())

      If lIntegra .And. WorkIP->WP_SLDATU == 0 .And. !lChkResFat
          If AEFatSaldo(EE9->EE9_PEDIDO,EE9->EE9_SEQUEN) // TLM 31/01/2008 Verifica se a quantidade embarcada do item é igual a liberada pelo faturamento
             If !lAuto
                Do Case// SVG 26/08/08 1 exibe a mensagem , 2 Não exibe e elimina , 3 Não exibe e não elimina
                   Case EasyGParam("MV_AVG0169") == "1"
                      lElimResFat := MsgYesNo(STR0193, STR0035)//"Deseja eliminar os resíduos de todos os pedidos de venda associados ao embarque?"###"Atenção"
                   Case EasyGParam("MV_AVG0169") == "2"
                      lElimResFat := .T.
                   Case EasyGParam("MV_AVG0169") == "3"
                      lElimResFat := .F.
                EndCase
                //lElimResFat := MsgYesNo(STR0193, STR0035)//"Deseja eliminar os resíduos de todos os pedidos de venda associados ao embarque?"###"Atenção"
                lChkResFat  := .T.
             Else
                lElimResFat := .T.
             EndIf
         EndIf
      EndIf
      // Atualiza saldo no EE8
      If !lConsolida
         AE100Saldo(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIP->WP_SLDATU,, lElimResFat,WorkIp->EE9_COD_I)
      Else
         If nSelecao == INCLUIR
            AE100Saldo(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIp->EE9_SLDINI*-1, .T., lElimResFat,WorkIP->EE9_COD_I)
         Else
            AE100Saldo(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,If(WorkIp->WP_OLDINI > 0, WorkIp->WP_OLDINI - WorkIp->EE9_SLDINI, WorkIp->EE9_SLDINI*-1), .T., lElimResFat,WorkIP->EE9_COD_I)
         EndIf
      EndIf

      // *** CAF 07/06/2000 11:02
      IF lIntegra

         //////////////////////////////////////////////////////////////////////////////
         //ER - 04/12/2008                                                           //
         //Grava o Filtro da tabela EE7, para que filtros customizados não interfirem//
         //na busca da tabela.                                                       //
         //////////////////////////////////////////////////////////////////////////////
         cOldFilter := EE7->(dbFilter())
         bOldFilter := &("{|| "+if(Empty(cOldFilter),".T.",cOldFilter)+" }")

         ////////////////////////////
         //Apaga o filtro existente//
         ////////////////////////////
         If !Empty(cOldFilter)
            EE7->(DbClearFilter())
         EndIf

         EE7->(DBSETORDER(1))
         EE7->(DBSEEK(XFILIAL("EE7")+WORKIP->EE9_PEDIDO))
         IF EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM
            AE100GrvItSD2(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,M->EEC_PREEMB,WorkIP->EE9_NF,WorkIP->EE9_SERIE,WorkIp->(Ap101FilNf()))
            If (WorkIP->WP_RECNO = 0 ;//AWR - 29/09/2005 - Só inclui NF
                .AND. !(lSelNotFat .and. Empty(WorkIP->EE9_NF) .and. Empty(WorkIP->EE9_SERIE))) ;// FJH 11/10/05 Evita que sejam gravados no EEM registros sem Num. da Nota (MV_AVG0067 == .T.)
                .OR. lNFCompara // Grava o EEM e EES se o botão de comparação de notas for utilizado
               AE100GrvEEM(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIP->EE9_NF,WorkIP->EE9_SERIE,WorkIp->(Ap101FilNf()))
            ENDIF
         ENDIF

         /////////////////////
         //Restaura o filtro//
         /////////////////////
         If !Empty(cOldFilter)
            EE7->(dbSetFilter(bOldFilter,cOldFilter))
         Endif

      ElseIf WorkIP->(FieldPos("EE9_NF")) > 0 .And. WorkIP->(FieldPos("EE9_SERIE")) > 0  .And. AvFlags("NFS_DESVINC") // BAK - 18/05/2012
         //FSM - 17/01/2012 - Tratamento para gravar os campos EEM-PREEMB e EES_PREEMB
         AE100EEMGrv(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIP->EE9_NF,WorkIP->EE9_SERIE)

      Endif

      IF !EasyGParam("MV_AVG0005") // Deixar de gravar embalagens ?
         AE100GrvEmb()
      Endif

      /*
      Recalculo de Cubagem através dos itens.
      Autor: Alexsander Martins dos Santos
      Data e Hora: 15/07/2004 às 09:58.
      */
      If lITCubagem
         nITCubagem += AP100Cubagem(.T., "IQ")
      EndIf
      //Final da rotina.

      If EECFlags("ESTUFAGEM")
         //RMD - 01/06/09 - Atualização do peso do item na relação de estufagem.
         AtuPesItEstuf()
         If WorkIp->WP_RECNO == 0
            Ae110AddItNE(M->EEC_PREEMB, WorkIp->(EE9_SEQEMB))
         EndIf
      EndIf

      If EasyEntryPoint("EECAE100")
         ExecBlock("EECAE100", .F., .F., {"PE_GRV_EE9"})
      EndIf

      WorkIP->(DBSKIP())

   Enddo

   If EECFlags("ESTUFAGEM") .And. Type("aAtuEstufagem") == "A"
      //RMD - 01/06/09 - Recalcula os totais da estufagem, com os pesos atualizados.
      AtuPesEstuf()
      For nInc := 1 To Len(aAtuEstufagem)
         Ae110RmItem(M->EEC_PREEMB, aAtuEstufagem[nInc])
         Ae110AddItNE(M->EEC_PREEMB, aAtuEstufagem[nInc])
      Next
   EndIf

   //ER - 27/02/2008 - Gravação do Custo Realizado, rateado por Item.
    ChkFile("EYW")
   If Select("EYW") > 0
      Ae109GrvCusto()
   EndIf

   IF lIntegra .Or. AvFlags("EEC_LOGIX")//AWR - 03/10/2005
      AE100DelEEM(aNFApaga)
   Endif

   //LRL-11/03/05----------------------------------------------
   If lIntegracao
      RecLock("EEC",.F.)
      EEC->EEC_PESLIQ := nPesoLiq
      EEC->EEC_PESBRU := nPesoBru

      If !Empty(EEC->EEC_DTEMBA)
         EEC->EEC_STATUS := ST_EM
         EEC->EEC_FIM_PE := dDataBase
      ElseIf Empty(EEC->EEC_DTEMBA) .And. EEC->EEC_STATUS=ST_EM
         EEC->EEC_STATUS := ST_AE
         EEC->EEC_FIM_PE := AVCTOD("")
      EndIf
      DSCSITEE7(.T.,OC_EM)

      EEC->(MsUnlock())
      AE100PrecoI(.T., .F.)
   EndIf
   //----------------------------------------------LRL-11/03/05
   //WFS (IF MV_AVG0010 == .T.) - 14/10/2008
   If lITCubagem
      M->EEC_CUBAGE := nITCubagem
   EndIf

   If(lIntDraw .and. lOkEE9_ATO, ED3->(dbSetOrder(1)) ,)

   If lOkYS_PREEMB .AND. EasyGParam("MV_EEC_ECO",,.F.)
      AE100CCGrv(.T.) //Grava SYS
   EndIf


   //WFS - Gravação do campo E1_HIST do título da NF
   If IsIntEnable("001") .And. IsIntFat()

      aTit:= AClone(INT101BuscaTit("WORKIP"))

      For nCont:= 1 To Len(aTit)

         SE1->(DbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

         //E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, RecNo
         If SE1->(DBSeek(xFilial() + AvKey(aTit[nCont][1], "E1_PREFIXO") + AvKey(aTit[nCont][2], "E1_NUM") + ;
            AvKey(aTit[nCont][3], "E1_PARCELA") + AvKey(aTit[nCont][4], "E1_TIPO")))

            If Empty(SE1->E1_HIST)
               SE1->(RecLock("SE1", .F.))
               SE1->E1_HIST:= 'Emb.:' + EEC->EEC_PREEMB
               SE1->(MsUnlock())
            EndIf
         EndIf

      Next

   EndIF

   If lIntDraw .and. lExistEDD .and. Select("WorkAnt") <> 0
      nOrdEE9 := EE9->(IndexOrd())
      EE9->(dbSetOrder(2))
      /* wfs 13/nov/18
         Bloco de gravação substituído pela função RE400GrvEDD()
      dbSelectArea("WorkAnt")
      WorkAnt->(dbGoTop())
      Do While !WorkAnt->(EOF())
         EDD->(dbGoTo(WorkAnt->EDD_REC))
         If !(EDD->(BOF()) .or. EDD->(EOF())) //GFC - 09/12/04
            //AOM - 19/12/2011
            IF AvFlags("SEQMI") .AND. Empty(EDD->EDD_HAWB)
               ED4->(dbSetOrder(8))  //ED4_AC+ ED4_SEQMI
               cSeqEDD := AvKey(WorkAnt->EDD_SEQMI,"ED4_SEQMI")
            ELSE
               ED4->(DbSetOrder(2))  //ED4_AC+ ED4_SEQSIS
               cSeqEDD := AvKey(WorkAnt->EDD_SEQSII,"ED4_SEQSIS")
            ENDIF
            //AOM - 29/09/10
            If ED4->(DbSeek(xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + cSeqEDD))
               If ED4->(RecLock("ED4",.F.))
                  If !Empty(WorkAnt->EDD_PREEMB) .Or. !Empty(WorkAnt->EDD_PEDIDO)
                     If !Empty(EDD->EDD_PREEMB) .Or. !Empty(EDD->EDD_PEDIDO)
                        ED4->ED4_SNCMEX += ((EDD->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL) - (WorkAnt->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL))
                        ED4->ED4_SQTDEX +=  (EDD->EDD_QTD - WorkAnt->EDD_QTD)
                     Else
                        ED4->ED4_SNCMEX -= WorkAnt->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL
                        ED4->ED4_SQTDEX -= WorkAnt->EDD_QTD
                     EndIf
                  EndIf
               ED4->(MsUnlock())
               EndIf
            EndIf


            EDD->(RecLock("EDD",.F.))
            FOR xi := 1 TO FCount()
               cCampo := FIELDNAME(xi)
               If EDD->(FieldPos(cCampo)) # 0
                  EDD->&(cCampo) := WorkAnt->&(cCampo)
               EndIf
            NEXT xi
            EDD->(msUnlock())
            If EDD->EDD_QTD < 0
               AELogAnt()
            EndIf
         Else
            EDD->(RecLock("EDD",.T.))
            EDD->EDD_FILIAL := xFilial("EDD")
            FOR xi := 1 TO FCount()
               cCampo := FIELDNAME(xi)
               If EDD->(FieldPos(cCampo)) # 0
                  EDD->&(cCampo) := WorkAnt->&(cCampo)
               EndIf
            NEXT xi

            //AOM - 19/12/2011
            IF AvFlags("SEQMI") .AND. !Empty(WorkAnt->EDD_SEQMI)
               ED4->(DbSetOrder(8)) //ED4_AC+ ED4_SEQMI
               cSeqEDD := AvKey(WorkAnt->EDD_SEQMI,"ED4_SEQMI")
            ELSE
               ED4->(dbSetOrder(2))  //ED4_AC+ ED4_SEQSIS
               cSeqEDD := AvKey(WorkAnt->EDD_SEQSII,"ED4_SEQSIS")
            ENDIF
            //AOM - 29/09/10
            If ED4->(DbSeek(xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + cSeqEDD ))
               If ED4->(RecLock("ED4",.F.))
                  If !Empty(EDD->EDD_PREEMB) .Or. !Empty(EDD->EDD_PEDIDO)
                     ED4->ED4_SNCMEX -= Abs( EDD->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL )  //NCF - 04/05/2018
                     ED4->ED4_SQTDEX -= Abs( EDD->EDD_QTD )
                  EndIf
               ED4->(MsUnlock())
               EndIf
            EndIf

            EDD->(msUnlock())
            If EDD->EDD_QTD < 0
               AELogAnt()
            EndIf
         EndIf
         WorkAnt->(dbSkip())
      EndDo */
      /* wfs
         O campo EDE_RE não comporta o número da DU-e. Após efetuar o ajuste do tamanho do campo, liberar a gravação da informação (bloco abaixo).
         RE400GrvEDD(IIf(!Empty(EEC->EEC_NRODUE), EEC->EEC_NRODUE, EE9->EE9_RE)) */
      
      RE400GrvEDD(EE9->EE9_RE)

      EE9->(dbSetOrder(nOrdEE9))
   EndIf

   // ***** //////////////////////////////////////// ***** \\

   EE8->(dbSetOrder(1))    // JBJ
   EE9->(dbSetOrder(1))
   EE7->(dbSetOrder(1))

   // ***** Atualizando Status dos Processos ***** \\

   For i:=1 To Len(aProcs)

      IF aProcs[i][2] == 2 // Nao altera o Status ...
         Loop
      Endif

      AE100Status(aProcs[i][1])

   Next i

   // ***** //////////////////////////////// ***** \\

   IF !EasyGParam("MV_AVG0005") // Deixar de gravar embalagens ?
      If !lIntegracao
         IncProc()
      EndIf

      nCubagem := M->EEC_CUBAGE
//    M->EEC_CUBAGE := 0   -- WFS -- 14/10/08

      // ***** Exclui Volumes ***** \\
      EEO->(dbSetOrder(1))
      EEO->(dbSeek(xFilial()+M->EEC_PREEMB))

      While EEO->(!Eof() .and. EEO_FILIAL == xFilial("EEO") .and. EEO_PREEMB == M->EEC_PREEMB)
         EEO->(RecLock("EEO",.F.))
         EEO->(dbDelete())
         EEO->(MsUnLock())
         EEO->(dbSkip())
      Enddo
      // ***** ////////////// ***** \\

      AE100Volume(.T.) // Grava Volumes no EEO ...

      IF (EEC->(RecLock("EEC",.F.)))
         EEC->EEC_TOTVOL := M->EEC_TOTVOL

         /*
         Condição para recalculo de cubagem.
         Autor: Alexsander Martins dos Santos
         Data e Hora: 21/07/2004 às 15:01.
         */

         //DFS - 21/12/12 - Retirado tratamento que somava valores na cubagem ao alterar qualquer registro do Embarque, salvar, quando não houvesse volume EEC_EMBAFI preenchido.
         /*If lITCubagem
	         EEC->EEC_CUBAGE := nCubagem
         Else
	         EEC->EEC_CUBAGE := M->EEC_CUBAGE
         Endif*/

         EEC->EEC_CUBAGE := nCubagem

         IF Inclui .Or. Empty(EEC->EEC_NETWGT)
            EEC->EEC_NETWGT := Transf(PesoPallet("L"),"@E 999,999,999.99")
         Endif
         IF Inclui .Or. Empty(EEC->EEC_GROSSW)
            EEC->EEC_GROSSW := Transf(PesoPallet("B"),"@E 999,999,999.99")
         Endif
         EEC->(MsUnlock())
      ENDIF
   Else
      If !lIntegracao
         IncProc()
      EndIf
   Endif

   /* by jbj - 12/03/2005 - Atualização da filial de off-shore com os detalhes da
                            filial brasil. */

   If AvGetM0Fil() == cFilBr .And. M->EEC_INTERM $ cSim
      aOrdEEC := SaveOrd("EEC")

      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(cFilEx+M->EEC_PREEMB))
         If EEC->(RecLock("EEC",.F.))
            EEC->EEC_IMPORT := M->EEC_CLIENT
            EEC->EEC_IMLOJA := M->EEC_CLLOJA
            EEC->EEC_IMPODE := Posicione("SA1",1,xFilial("SA1")+M->EEC_CLIENT,"A1_NOME")
            EEC->EEC_ENDIMP := EECMEND("SA1",1,M->EEC_CLIENT+M->EEC_CLLOJA,.T.,,1)
            EEC->EEC_END2IM := EECMEND("SA1",1,M->EEC_CLIENT+M->EEC_CLLOJA,.T.,,2)
            EEC->EEC_FORN   := If(!Empty(M->EEC_EXPORT),M->EEC_EXPORT,M->EEC_FORN)
            EEC->EEC_FOLOJA := If(!Empty(M->EEC_EXLOJA),M->EEC_EXLOJA,M->EEC_FOLOJA)

            If !Empty(M->EEC_COND2) .And. !Empty(M->EEC_DIAS2)
               EEC->EEC_CONDPA := M->EEC_COND2
               EEC->EEC_DIASPA := M->EEC_DIAS2
            EndIf

            If !Empty(M->EEC_INCO2)
               EEC->EEC_INCOTE := M->EEC_INCO2
            EndIf
         EndIf
      EndIf
      RestOrd(aOrdEEC,.t.)
   EndIf

   IF EasyEntryPoint("EECAE100")   //GFC - 22/11/2004
      ExecBlock("EECAE100",.F.,.F.,{"ANTES_PARCELA",EEC->EEC_PREEMB})
   Endif

   If Type("lPagtoAnte") == "L" .And. lPagtoAnte .And. Select("WORKSLD_AD") > 0     // By JPP - 09/02/2006 - 11:10
      AE105GrvEstAd()  // Gravação do estorno dos adiantamentos vinculados
   EndIf
   // *** caf 21/04/2001 Gravacao de parcelas de cambio com tratamento
   // de erros para evitar problemas com patch
   //bLastHandler := ErrorBlock({||.t.})
   If EECFlags("CAFE") .And. EEC->EEC_TIPO == "W"
      If M->EXL_TIPOWO $(ST_WI+ST_WO)
         EEC->(RecLock("EEC",.F.))
         nAux := M->EEC_TOTPED
         EEC->EEC_TOTPED := nCambioWO
         EEC->(MsUnlock())
         If !AvFlags("EEC_LOGIX")
            Begin Sequence
               AF200GPARC()  // GFP - 15/01/2013
            End Sequence
         Else
            // BAK - Tratamento para Roolback integrado
            lRet := AF200GPARC()
            If Valtype(lRet) == "L" .And. !lRet  // GFP - 15/01/2013
               Break
            EndIf
         EndIf
         EEC->(RecLock("EEC",.F.))
         EEC->EEC_TOTPED := nAux
         EEC->(MsUnlock())
      ElseIf M->EXL_TIPOWO == ST_WR

         If !AvFlags("EEC_LOGIX")
            Begin Sequence
               AF200GPARC()  // GFP - 15/01/2013
            End Sequence
         Else
            // BAK - Tratamento para Roolback integrado
            lRet := AF200GPARC()
            If Valtype(lRet) == "L" .And. !lRet  // GFP - 15/01/2013
               Break
            EndIf
         EndIf
      EndIf
   Else
      //Begin Sequence
         /*
            ER - 31/07/2006
            Verifica se o Embarque é uma remessa, em caso positivo não gera Parcela de Cambio
         */
         If !lConsign .or. (lConsign .and. (ValType(cTipoProc) == "C" .and. (cTipoProc <> PC_BC .or. cTipoProc <> PC_RC )))
            //FSM - 27/08/2012
         	lTitparcelas := EECFlags("TIT_PARCELAS")
         	If lTitparcelas .And. Empty(EEC->EEC_TITCAM)
         		If EEC->(RecLock("EEC", .F.))
         		   EEC->EEC_TITCAM := If(Empty(M->EEC_TITCAM), EECGetFinN("SE1"), M->EEC_TITCAM)
         		   EEC->(MsUnlock())
         		EndIf
         	EnDIf
            // BAK - Tratamento para Roolback integrado
            lRet := AF200GPARC()
            If Valtype(lRet) == "L" .And. !lRet  // GFP - 15/01/2013
               Break
            EndIf
         EndIf
         // ** AAF 20/09/04 - Gravação das Parcelas das Invoices a Pagar
         If lBACKTO .AND. Len(aColsBtB) > 0
            If !(lRet := AP106GrvParc())
               Break
            EndIf
         Endif
         // **
      //End Sequence

      //ErrorBlock(bLastHandler)
   EndIf

   /* Os tratamentos abaixo foram substituídos pelas novas regras do controle de quantidades
      para ambientes com a rotina de off-shore habilitada. */
   /*
   If !lInclui .And. lIntermed
      // Para os ambientes com a rotina de replicação de dados ativa, o sistema irá realizar automaticamente
      // o acerto das quantidades para a filial do exterior.

      Do Case
         Case AvGetM0Fil() == cFilBr .And. (M->EEC_INTERM $ cSim)
              Ap101VldQtde(OC_EM,,.f.)
              If lIntegracao
                 Ap101AtuFil(OC_EM)
              EndIf

         Case AvGetM0Fil() == cFilEx
              Ap101VldQtde(OC_EM,,.f.)
              If lIntegracao
                 Ap101AtuFil(OC_EM,.f.,cFilEx)
              EndIf
      EndCase
   EndIf
   */

   //ER - 24/09/2007 -  Esta função está sendo chamada após a função AE100GerEmb().
   // ** Acerta as quantidades para os embarques nas filiais de off-shore.
   //If lIntegracao .And. lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EEC_INTERM $ cSim .And. !EECFlags("CAFE")
   //   Ax101SetQtde(OC_EM)
   //EndIf

   If !lIntegracao
      // ** By JBJ - 12/11/2002 - 10:53 (Aviso de Adiantamentos disponíveis).
      If lPagtoAnte

         If Empty(M->EEC_DTEMBA)

            EEQ->(DbSetOrder(6))

            cFil := xFilial("EEQ")

            //ER - 29/06/2007 - Quando a tabela EEQ for compatilhada, o cFil será igual à "  ".
            If Empty(cFil)
               aAdd(aFil,cFil)
            Else
               //Seleciona todas as Filiais
               aFil := AvgSelectFil(.F.)
            EndIf

            For i:=1 to Len(aFil)
               If !EEQ->(DbSeek(xFilial("EEQ")+"E"+M->EEC_PREEMB))
                  // ** Verifica se existe adiantamentos com saldo para o importador.
                  If EEQ->(DbSeek(aFil[i]+"C"+AvKey(AllTrim(M->EEC_IMPORT+M->EEC_IMLOJA),"EEQ_PREEMB")))
                     Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == aFil[i] .And.;
                                                  EEQ->EEQ_FASE   == "C" .And.;
                                                  EEQ->EEQ_PREEMB == AvKey(AllTrim(M->EEC_IMPORT+M->EEC_IMLOJA),"EEQ_PREEMB") .And.;
                                                  !lCliAdia
                        If EEQ->EEQ_SALDO > 0
                           lCliAdia:=.t.
                        EndIf

                        EEQ->(DbSkip())
                     EndDo
                  EndIf
               EndIf
            Next

            If !lCliAdia // Caso não tenha adiantamentos para o cliente verifica os pedidos.
               EE9->(DbSetOrder(2))
               If EE9->(DbSeek(xFilial("EE9")+M->EEC_PREEMB))
                  cProc        := EE9->EE9_PEDIDO
                  lAltPedAdian := .T.
                  Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
                                               EE9->EE9_PREEMB == M->EEC_PREEMB .And. !lPedAdia
                     //If cProc <> EE9->EE9_PEDIDO
                     If lAltPedAdian
                        //If EEQ->(DbSeek(xFilial("EEQ")+"P"+cProc))
                        If EEQ->(DbSeek(xFilial("EEQ")+"P"+EE9->EE9_PEDIDO))
                           Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                                        EEQ->EEQ_FASE   == "P" .And.;
                                                        EEQ->EEQ_PREEMB == EE9->EE9_PEDIDO .And. !lPedAdia
                              If EEQ->EEQ_SALDO > 0
                                 lPedAdia:=.t.
                              EndIf
                              EEQ->(DbSkip())
                           EndDo
                        EndIf

                        cProc := EE9->EE9_PEDIDO
                     EndIf

                     EE9->(DbSkip())

                     //ER - 17/05/2007
                     If cProc <> EE9->EE9_PEDIDO
                        lAltPedAdian := .T.
                     Else
                        lAltPedAdian := .F.
                     EndIf

                  EndDo
               EndIf
            EndIf

         EndIf
      EndIf

      // ** By JBJ 26/03/03 - 10:36 (Mostra aviso, caso as comissões não estejam corretas (Comissao por item).
      Ap100ValCom(OC_EM,.f.)
   EndIf

   ////////////////////////////////////////////////////
   // Integração com Faturamento (Gravação)          //
   // Geração de Pedido de Venda a Partir do Embarque//
   ////////////////////////////////////////////////////
   If lIntegra
      If lIntEmb
         //////////////////////////////////////////////////////////////////////////////////////////
         //Verifica se o Pedido é Back to Back  ou Remessa, em caso Positivo não gera Faturamento//
         //////////////////////////////////////////////////////////////////////////////////////////
         If !((lBackTo .and. Ap106IsBackTo()) .or. (lConsign .and. (ValType(cTipoProc) == "C" .and. (cTipoProc == PC_BC .or. cTipoProc == PC_RC ))))

            ////////////////////////////////////////////////
            //Realiza novas validações para verificar se o//
            //Pedido de Venda poderá ser gerado através   //
            //do Embarque (Nova Integração.)              //
            ////////////////////////////////////////////////
            If FAT3IntFat(M->EEC_PREEMB,If(lInclui,INCLUIR,ALTERAR))

               ////////////////////////////////////////////////////////////////////////////////////////////////
               //Verifica se não existe falha na integridade entre o Pedido de Exportacao e o Pedido de Venda//
               ////////////////////////////////////////////////////////////////////////////////////////////////
               FAT3VerInt()

               ///////////////////////////////////////////////////
               //Exibe Mensagem com o nùmero do Pedido de Venda.//
               ///////////////////////////////////////////////////
               If !FAT3EmbGerPV(If(lInclui,INCLUIR,ALTERAR),"MSG")
                  Break
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
   // ** Se a flag de Intermediacao estiver ligada gera o embarque na filial do exterior.
   If lIntermed .and. !(lReplicaDados .and. nSelecao == ALTERAR)
      If !(lRet := AE100GerEmb(lInclui))
         Break
      EndIf
   EndIf

   //LRS - 24/03/2016 - Nopado
   //**LGS-22/05/2014 - Se for inclusao e tiver com o campo WP_FLAG vazio na work, chamo a função para gravar o campo D2_PREEMB
   //**                 Dessa forma sempre que incluir um embarque o campo será atualizado.
   //If EMPTY(WorkIP->WP_FLAG) .And. nSelecao == INCLUIR
   //	  AE100GrvItSD2(EE9->EE9_PEDIDO,EE9->EE9_SEQUEN,M->EEC_PREEMB,EE9->EE9_NF,EE9->EE9_SERIE,EE9->(Ap101FilNf()))
   //EndIf

   If nSelecao == ALTERAR
      // ** Acerta as quantidades para os embarques nas filiais de off-shore.
      If lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EEC_INTERM $ cSim  .And. !EECFlags("COMMODITY")
         Ax101SetQtde(OC_EM)
      //EndIf WFS 09/01/09
      ElseIf EECFlags("COMMODITY")
         If !(lRet := AE100GerEmb(.F.))
            Break
         EndIf
      EndIf
   EndIf
   // ** AAF 14/09/04 - Grava Invoices a Pagar do Back to Back
   If lBACKTO
      AP106Grv(OC_EM)
   Endif
   // **

   If !lIntegracao
      // by CAF 13/03/2000 14:57
      IF EasyEntryPoint("EECPEM00")
         ExecBlock("EECPEM00",.F.,.F.)
      Endif

      IncProc()
   EndIf   
   // ** AAF 09/03/05 - Replica alterações
   If lReplicaDados .And. Select("WK_MAIN") > 0 .And. !lIntegracao
         If lConsolOffShore .and. !Empty(cFilEx) .and. !EECFLags("COMMODITY")
            Ae104AtuFil(cFilEx)
         EndIf

      WK_MAIN->( dbSetOrder(2) )
      WK_MAIN->( dbGoTop() )
      Do While !WK_MAIN->( EoF() )

         aProc := AX100GrvRpl( WK_MAIN->WK_FILIAL, WK_MAIN->WK_PROC, WK_MAIN->WK_FASE )

         If Len(aProc) > 0
            aAdd(aAltProc,aProc)
         Endif

         //WK_MAIN->( dbSkip() )
      EndDo
      WK_MAIN->( E_EraseArq(cArqMain) )
      FErase(cArqMain2+OrdBagExt())
      FErase(cArqMain3+OrdBagExt())
      FErase(cArqMain4+OrdBagExt())

      nRecnoEEC := EEC->(Recno())
      If Len(aAltProc) > 0
         Processa({|| ProcRegua( Len(aAltProc) ),;//Acerta a base com as gravações das alterações replicadas para off-shore.
                      AX100GrvProcs(aAltProc)  },;
                      STR0216)//""//STR0216	"Atualizando processos relacionados"
      Endif

      EEC->(dbGoTo(nRecnoEEC))
   Endif
   //JAP - Verifica se o total de adiantametos é igual ao total do processo e altera o status para "Cambio Contratado"
   If lPagtoAnte .And. !Empty(M->EEC_DTEMBA)
      /* // By JPP 09/03/2006 - 11:00 - Definir status do cambio para o processo quando existir adiantamentos(Parcial/Total) e a data de embarque for preenchida.
      EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
      EEQ->(DbSeek(xFilial("EEQ")+"E"+EEC->EEC_PREEMB))

      Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                               EEQ->EEQ_FASE   == "E" .And.;
                               EEQ->EEQ_PREEMB == EEC->EEC_PREEMB

         If EEQ->EEQ_TIPO = "A"
            // ** Acumula os adiantamentos.
            nTotAdia += EEQ->EEQ_VL
         EndIf

         EEQ->(DbSkip())
      EndDo

      If nTotAdia == M->EEC_TOTPED
      */
         aF200Status("EEQ",nil,.t.)
      //EndIf
   EndIf


   /* ---------------------------------------------
   Atualização do status de transmissão da DU-E
   ------------------------------------------------*/
   If AvFlags("DU-E")
        If AvFlags("DU-E3") .And. ismemvar("cRetifiDUE") .and. cRetifiDUE != "0" .And. FindFunction("DUESeqHist")
            cSeqDUE := DUESeqHist(M->EEC_PREEMB)
            EK0->(dbSetOrder(1))
            EK0->(dbSeek(xFilial("EK0") + M->EEC_PREEMB + cSeqDUE))
            If cRetifiDUE == "1" //Exclui a DUE
                aCapaEK0 := {}
                aAdd(aCapaEK0,{"EK0_FILIAL", xFilial("EK0"), Nil})
                aAdd(aCapaEK0,{"EK0_PROCES", M->EEC_PREEMB , Nil})
                aAdd(aCapaEK0,{"EK0_NUMSEQ", cSeqDUE       , Nil})
                EasyMVCAuto("EECDU100",EXCLUIR,{{"EK0MASTER",aCapaEK0}})
            ElseIf cRetifiDUE == "2"
                EK0->(RecLock("EK0",.F.))
                EK0->EK0_RETIFI := "2" //1=Due Válida; 2=Necessário Retificar;
                EK0->(MsUnlock())
            ElseIf cRetifiDUE == "3"
                EK0->(RecLock("EK0",.F.))
                EK0->EK0_RETIFI := "1" //1=Due Válida; 2=Necessário Retificar;
                EK0->(MsUnlock())
            EndIf
            cRetifiDUE := "0"
        EndIf
      DU400GrvStatus()
   EndIf

   ///////////////////////////////////////////////////////////////////////
   //ER - 19/08/2008.                                                   //
   //Se o adiantamento foi gerado por título no EFF, este será vinculado//
   //automaticamente no preenchimento da data de embarque.              //
   ///////////////////////////////////////////////////////////////////////
   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))

   If lGerAdEEC

      If lPagtoAnte
         /////////////////////////////////////////////////////////////////
         //Verifica se existe parcela de adiantamento para esse embarque//
         /////////////////////////////////////////////////////////////////
         EEQ->(DbSetOrder(6))
         If EEQ->(DbSeek(xFilial("EEQ")+"E"+M->EEC_PREEMB))

            Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                         EEQ->EEQ_FASE   == "E" .And.;
                                         EEQ->EEQ_PREEMB == M->EEC_PREEMB

               ///////////////////////////
               //Parcela de Adiantamento//
               ///////////////////////////
               If EEQ->EEQ_TIPO == "A"

                  ////////////////////////////////////////////////////
                  //Verifica se a parcela de adiantamento foi gerada//
                  //automaticamente por contrato do EFF.            //
                  ////////////////////////////////////////////////////
                  If EX400AdEFF(EEQ->EEQ_FAOR,EEQ->EEQ_PROR,EEQ->EEQ_PAOR)
                     aAdd(aAdEFF,EEQ->EEQ_PARC)
                  EndIf

               EndIf

               EEQ->(DbSkip())
            EndDo
         EndIf

         ///////////////////////////////////////////////////////////////////
         //Emula a vinculação automatica da parcela de adiantamento gerada//
         //pelo EFF com o contrato do Financiamento.                      //
         ///////////////////////////////////////////////////////////////////
         If Len(aAdEFF) > 0
            EEC->(DbSetOrder(1))
            If EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))

               /////////////////////////////////////
               //Preenchimento da Data de Embarque//
               /////////////////////////////////////
               If (!Empty(M->EEC_DTEMBA) .and. Empty(dAntDtemba))

                  lEEQAuto := .T.

                  //Emula a Liquidação e Vinculação da Parcela de Adiantamento.
                  bEEQAuto := {|| AF200AutoVincAd(aAdEFF,"INC_VINC")}

                  AF200Man(EEC->EEC_PREEMB,EEQ->(RecNo()),ALTERAR)

               ////////////////////////////////
               //Retirada da Data de Embarque//
               ////////////////////////////////
               ElseIf(Empty(M->EEC_DTEMBA) .and. !Empty(dAntDtemba))

                  lEEQAuto := .T.


                  //Emula o Estorno da Liquidação da Parcela de Adiantamento.
                  bEEQAuto := {|| AF200AutoVincAd(aAdEFF,"EST_LIQ")}

                  AF200Man(EEC->EEC_PREEMB,EEQ->(RecNo()),ALTERAR)

                  //Emula o Estorno da Vinculação da Parcela de Adiantamento.
                  bEEQAuto := {|| AF200AutoVincAd(aAdEFF,"EST_VINC")}

                  AF200Man(EEC->EEC_PREEMB,EEQ->(RecNo()),ALTERAR)

               /////////////////////////////////
               //Alteração da Data de Embarque//
               /////////////////////////////////
               ElseIf M->EEC_DTEMBA <> dAntDtemba

                  lEEQAuto := .T.

                  //Emula o Estorno da Liquidação da Parcela de Adiantamento.
                  bEEQAuto := {|| AF200AutoVincAd(aAdEFF,"EST_LIQ")}

                  AF200Man(EEC->EEC_PREEMB,EEQ->(RecNo()),ALTERAR)

                  //Emula o Estorno da Vinculação da Parcela de Adiantamento.
                  bEEQAuto := {|| AF200AutoVincAd(aAdEFF,"EST_VINC")}

                  AF200Man(EEC->EEC_PREEMB,EEQ->(RecNo()),ALTERAR)

                  //Emula a Liquidação e Vinculação da Parcela de Adiantamento.
                  bEEQAuto := {|| AF200AutoVincAd(aAdEFF,"INC_VINC")}

                  AF200Man(EEC->EEC_PREEMB,EEQ->(RecNo()),ALTERAR)

               EndIf

            EndIf

         EndIf
      EndIf
   EndIf
   lRet := .t.

   //AOM - 27/04/2011 - Operacao Especial
   If AvFlags("OPERACAO_ESPECIAL") .AND. Type("oOperacao") == "O"  // GFP - 07/08/2015
      oOperacao:SaveOperacao(cNroDue)
   EndIf


End Sequence

// *** GFP - 30/03/2011 :: 15h46 - Tratamento de WorkFlow.
If AvFlags("WORKFLOW")
   EasyGroupWF("EMBARQUE_EEC",aChaves)
EndIf

//Imprime log das mensagens retornadas
If lSched
   oEECLog:PrintLog()
EndIf

RestOrd(aOrd) // Restaura ordem dos alias ...

Select(nSelect)

Return lRet

/*
Função    : AtuPesItEstuf()
Autor     : Rodrigo Mendes Diaz
Data      : 01/06/09
Objetivo  : Atualizar o peso líquido do item atual (conforme posicionamento da WorkIp) na rotina de estufagem.
Parâmetros: Nenhum
Retorno   : Nenhum
*/
Static Function AtuPesItEstuf()
Local aOrd := SaveOrd("EYH")
Local nInc, cChave

   EYH->(DbSetOrder(2))
   For nInc := 1 To 2
      /*
         Configura a chave de busca (EYH_FILIAL+EYH_ESTUF+EYH_PREEMB+EYH_SEQEMB) para buscar primeiro por itens não estufados (EYH_ESTUF = N)
         e depois por itens estufados (EYH_ESTUF = S)
      */
      cChave := xFilial()+If(nInc == 1, "N", "S")+M->EEC_PREEMB+WorkIp->EE9_SEQEMB

      //Atualiza o peso líquido do item em todas as referências ao item na tabela de estufagem
      If EYH->(DbSeek(cChave))
         While EYH->(!Eof() .And. EYH_FILIAL+EYH_ESTUF+EYH_PREEMB+EYH_SEQEMB == cChave)
            EYH->(RecLock("EYH", .F.))
            EYH->EYH_PSLQUN := WorkIp->EE9_PSLQUN
            EYH->(MsUnlock())
            EYH->(DbSkip())
         EndDo
      EndIf
   Next

RestOrd(aOrd, .T.)
Return Nil

/*
Função    : AtuPesEstuf()
Autor     : Rodrigo Mendes Diaz
Data      : 01/06/09
Objetivo  : Atualizar todos os pesos da estufagem do embarque atual (considerando que os peso líquido dos itens já foi atualizado na função AtuPesItEstuf()).
Parâmetros: Nenhum
Retorno   : Nenhum
*/
Static Function AtuPesEstuf()
Local aOrd := SaveOrd("EX9")

   //Atualiza primeiro o peso das embalagens/itens não estufados:
   Ae110AtuPeso("EYH", xFilial("EYH")+"N"+M->EEC_PREEMB, StrZero(0, AvSx3("EYH_ID", AV_TAMANHO)))

   //Agora atualiza as embalagens da composição de cada container relacionado ao embarque:
   EX9->(DbSetOrder(1))
   EX9->(DbSeek(xFilial()+M->EEC_PREEMB))
   While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+M->EEC_PREEMB)
      Ae110AtuPeso("EYH", xFilial("EYH")+"S"+M->EEC_PREEMB, EX9->EX9_ID)
      EX9->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return Nil

//----------------------------------------------------------------------
Function PesoPallet(cTipo)
// Parametro: cTipo => "B" - Peso Bruto
//            cTipo => "L" - Peso Liquido

Local nPeso := 0
Local aOrd  := SaveOrd("EEO",1)
Local nNroEmb := 0

// Embalagem da Capa
IF !Empty(EEC->EEC_EMBAFI)
   nNroEmb := nNroEmb+1
Endif

// Embalagem dentro da outra
EEO->(dbSeek(xFilial()+EEC->EEC_PREEMB+AvKey(1,"EEO_SEQ")))

While EEO->(!Eof() .And. EEO_FILIAL==xFilial("EEO")) .And.;
      EEO->EEO_SEQ == AvKey(1,"EEO_SEQ") .And. nNroEmb < 3



   IF EEO->EEO_TIPO == TIPO_ITEM
      EEO->(dbSkip())
      Loop
   Endif

   IF EEO->EEO_CODEMB != EEC->EEC_EMBAFI
      nNroEmb := nNroEmb + 1
   Endif

   EEO->(dbSkip())
Enddo

IF cTipo == "B" // Peso Bruto
   // Posiciona no Pallet ...
   EEO->(dbSeek(xFilial()+EEC->EEC_PREEMB+AvKey(1,"EEO_SEQ")))
   IF nNroEmb > 2
      nPeso := EEO->EEO_PESBRU/EEO->EEO_QTDE
   Else
      nPeso := EEO->EEO_PESBRU
   Endif
Elseif cTipo == "L"
   EEO->(dbSeek(xFilial()+EEC->EEC_PREEMB+AvKey(1,"EEO_SEQ")))
   IF nNroEmb > 2
      nPeso := EEO->EEO_PESLIQ/EEO->EEO_QTDE
   Else
      nPeso := EEO->EEO_PESLIQ
   Endif
Endif

RestOrd(aOrd)

Return nPeso

/*
Funcao      : AE100LINOK
Parametros  :
Retorno     :
Objetivos   :
Autor       : Heder M Oliveira
Data/Hora   :
Revisao     :
Obs.        :
*/
Static Function AE100LinOk
   Local lRet:=.T.,cOldArea:=select(), nInc:=0
   
   //Local cFilEx:=EasyGParam("MV_AVG0024",,"")
   //Local cFilBr:=EasyGParam("MV_AVG0023",,"")
   Local nRecEEC := 0
   Local bVldEmbarque, cOldReadVar  // By JPP - 20/07/2005 10:25
   Local nPos := 0
   Local aOrdWorkIP := SaveOrd("WorkIp")//FDR - 17/12/12
   Local cSeqDUE := ""
   Local aCapaEK0:= {}
   Local cStatusDUE := ""
   Local cMsg
    LOCAL nOrdEXZ := EXZ->(INDEXORD())
   Private aCampoVld :={}   // JPP - 01/08/2005 16:37
   Private lMsgCrit := .T. //Define se a mensagem de critica dos campos será exibida.

   Begin Sequence

      IF WorkIP->(BOF()).AND.WorkIP->(EOF()) .and. !EasyGParam("MV_AVG0008",,.T.)
         lRET:=.F.
         HELP(" ",1,"AVG0000070")
         BREAK
      ENDIF

      If M->EEC_VALCOM >= M->EEC_TOTFOB 
         EasyHelp(STR0282,STR0035)  //"O valor da comissão deve ser inferior ao valor FOB."###"Atenção"
         lRet := .F.
         Break
      EndIf

      If !Ap104ValProc(nSelecao,OC_EM) // By JPP - 12/05/2006 - 13:30 - Não permitir a inclusão de processos já cadastrados em outra filial.
         lRET := .F.
         Break
      EndIf

      /*
      Nopado por ER - 18/09/2008.

      If lItFabric // By JPP 14/11/2007 - 14:00
         If !AE109VlEmb()
            lRet := .F.
            Break
         EndIf
      EndIf
      */

      /*
      ER - 16/09/05. 11:20
      Tratamento para verificar se dois usuários estão tentando incluir um embarque com o mesmo código,
      ao mesmo tempo.
      */
      IF nSelecao == INCLUIR .And. !FreeForUse("EEC",xFilial("EEC")+M->EEC_PREEMB)
         lRET:=.F.
         BREAK
      EndIf

      //MFR 18/01/2021 OSSME-5509
      //Valida o número da oic
      If EECFlags("CAFE")
         EXZ->(DbSetOrder(3))
         WKEXZ->(DbGoTop())
         While WKEXZ->(!Eof())
            EXZ->(Dbseek(xFilial("EXZ") + WKEXZ->EXZ_SAFRA + WKEXZ->EXZ_OIC))
            IF EXZ->(!EOF()) .And. WKEXZ->EXZ_PREEMB # EXZ->EXZ_PREEMB
               lRet := .F.
               cMsg := StrTran(STR0280, "######",  WKEXZ->EXZ_OIC)
               cMsg := StrTran(cMsg, "XXXXXX", EXZ->EXZ_PREEMB)

               EasyHelp(cMsg,STR0160) //"Número da OIC já existente: ###### Embarque: ########. Reconsidere o número da OIC"
               EXZ->(DBSETORDER(nOrdEXZ))
               Break
            EndIf
            WKEXZ->(DbSkip())
         EndDo
         EXZ->(DBSETORDER(nOrdEXZ))
      EndIf

      //FJH 25/08/05 Chamada da função que verifica se os campos obrigatorios dos agentes
      //             de comissao vinculados ao processo estão preenchidos.
      if(!AE106VerAgCom())
         lRet:=.F.
         Break
      Endif

      If ! Obrigatorio(aGets,aTela)
        lRET := .F.
         Break
      Endif

      If lConsign
         If (cTipoProc == PC_VR .Or. cTipoProc == PC_VB) .And. !Ae108ConsistArm()
            lRet := .F.
            Break
         EndIf
      EndIf

      /*
      //DFS - 06/06/13 - Inclusão de verificação caso não tenha sido preenchido o campo Volume
      If M->EEC_CALCEM == "1" .AND. Empty(M->EEC_EMBAFI)
         EasyHelp(STR0238)//O campo 'Volume' não foi preenchido na pasta 'Embalagens'. Favor verificar!
      EndIf
      */

      If EECFlags("COMPLE_EMB")
         If !Ae106Obrigat()
            lRET := .F.
            Break
         EndIf
      EndIf

      ///////////////////////////////////////////////////////////////
      //ER - 14/11/2008
      //Apura as Notas Fiscais de Remessa com os itens do Embarque.//
      ///////////////////////////////////////////////////////////////
      If AvFlags("FIM_ESPECIFICO_EXP")
         /* Caso o usuário tenha removido um item do processo sem acessar a rotina de notas fiscais de remessa
            com fim específico de exportação, será necessário garantir que as notas vinculadas à este item sejam
            removidos também. */
         If NFRemFimEsp() .And. WK_NFRem->(EasyRecCount("WK_NFRem")) == 0
            AE110LoadEYY()
         EndIf
         AE110LoadNfRem()
      EndIf

      //FDR - 17/12/12
      WorkIP->( DBGoTop() )
      Do While WorkIp->(!EOF())
         If EE7->(DBSeek(xFilial("EE7")+WorkIp->EE9_PEDIDO))
            If EE7->EE7_IMPORT+EE7->EE7_IMLOJA # M->EEC_IMPORT+M->EEC_IMLOJA
               HELP(" ",1,"AVG0000626") // ("O importador do pedido é diferente do importador do processo atual !","Atenção")
               lRet:= .F.
               Break
            EndIf
         EndIf
         WorkIP->( DBSkip() )
      EndDo
      RestOrd(aOrdWorkIP,.t.)

      IF EasyEntryPoint("EECAE100")   // JPP - 01/08/2005 16:37 - Inclusão do ponto de entrada.
         ExecBlock("EECAE100",.F.,.F.,{"EMB_LINOK"})
      Endif

      /// LCS - 25/04/2002 - ALTERACAO P/ HENCKEL/REGINA
      IF lALTERA
         For nInc:=1 TO LEN(aHDEnchoice)
            If Ascan(aCampoVld,aHDEnchoice[nInc]) > 0
               Loop
            EndIf
            If ! AE100Crit(aHDEnchoice[nInc], aHDEnchoice[nInc] $ "EEC_FRPREV|EEC_SEGURO|EEC_SEGPRE" .and. lAltValPosEmb )
               If lMsgCrit
                  EasyHelp(STR0147+AVSX3(aHDEnchoice[nInc], AV_TITULO)+STR0148+AVSX3(aHDEnchoice[nInc], 15)+".", STR0035) //"Verifique o campo "###" na pasta "###"Atenção"
               Else
                  lMsgCrit := .T.
               EndIf
               lRet:=.F.
               Break
            Endif
         Next nInc

         // By JPP - 09/06/2005 11:10 - Criticar campo EEC_NRINVO
         If ! AE100Crit("EEC_NRINVO")
            lRet := .F.
            Break
         EndIf
      EndIf

      // JPM - 05/03/05 - Validação para alteração de valores após o embarque
      If lAltValPosEmb .And. lDtEmba .And. !Empty(M->EEC_DTEMBA) //Se o sistema foi gravado anteriormente com a Data de Embarque e está ativa a rotina
         Ae100PrecoI(.t.)
         If !AE106AltVld()
            lRet := .f.
            Break
         EndIf
      EndIf

      If !EECFlags("ITENS_LC")
         // JPM - 22/12/04 - Tela para desvinculacao de carta de crédito e abatimento de saldo de outros processos
         If !Empty(M->EEC_LC_NUM) .and. lNRotinaLC // .And. (!lIntermed .Or. cFilEx <> xFilial("EEC"))
            If !AE107DesLC()
               lRet := .f.
               Break
            EndIf
         EndIf
      Else
         If !Ae107ValIt(OC_EM)
            lRet := .f.
            Break
         EndIf

      EndIf

      If lIntermed
         Do Case
            Case (AvGetM0Fil() == cFilBr .And. nSelecao == INCLUIR .And. !(M->EEC_INTERM $ cSim))
               /* Para a filial do brasil, na opção de inclusão, caso o processo não tenha tratamentos de off-shore,
                  se o processo não puder ser deletado na filial de off-shore, a inclusão é bloqueada */

               If !AE105VldOffShore(nSelecao)
                  lRet:=.f.
                  Break
               EndIf

            Case (AvGetM0Fil() == cFilBr .And. (M->EEC_INTERM $ cSim)) // Fil. Br com tratamento de Off-Shore

                // JPM - 06/12/05 - Valida se os campos de intermediação foram preenchidos.
                If !Ap104ValInterm()
                   lRet := .f.
                   Break
                EndIf

               /* Realiza todas as validações para lançamento de processos com
                  tratamentos de off-shore. */

               If !AE105VldOffShore(nSelecao)
                  lRet:=.f.
                  Break
               EndIf

               // ** PLB 19/09/06 - Verifica se o Cliente Final dos Pedidos é o mesmo do Embarque
               If lIntermed  .And.  M->EEC_INTERM $ cSim  .And.  xFilial("EEC") == cFilBr
                  aIpItens := {{"",""}}
                  EE7->( DBSetOrder(1) )
                  WorkIP->( DBGoTop() )
                  Do While !WorkIP->( EoF() )
                     If WorkIP->WP_FLAG == cMarca
                        If EE7->( DBSeek(xFilial("EE7")+WorkIp->EE9_PEDIDO) )  .And.  EE7->EE7_CLIENT != M->EEC_CLIENT
                           If AScan(aIpItens,{|x|x[1]==EE7->EE7_PEDIDO}) == 0
                              AAdd(aIpItens,Array(2))
                              AIns(aIpItens,1)
                              aIpItens[1] := {EE7->EE7_PEDIDO,EE7->EE7_CLIENT}
                           EndIf
                        EndIf
                     EndIf
                     WorkIP->( DBSkip() )
                  EndDo
                  WorkIP->( DBGoTop() )
                  ASize(aIpItens,Len(aIpItens)-1)
                  ASort(aIpItens,,,{|x,y|x[1]<y[1]})
                  If Len(aIpItens) > 0
                     aMsg := {}
                     aAdd(aMsg, {STR0167 + ENTER + ENTER, .T.})//"Os seguintes pedidos nao podem ter itens vinculados ao embarque pois o seu cliente final difere do cliente do embarque."
                     aAdd(aMsg, {STR0168 + ENTER + ENTER, .T.})//"Processos com tratamento off-shore devem ter o mesmo cliente no pedido e no embarque."
                     aAdd(aMsg, {EECMontaMsg({"EE9_PEDIDO", "EE7_CLIENT"}, aIpItens), .F.})
                     aAdd(aMsg, {ENTER + ENTER + STR0169 +M->EEC_CLIENT, .T.})//"Cliente do Embarque: "
                     EECView(aMsg, STR0058) // "Atenção"
                     lRet := .F.
                     Break
                  EndIf
                  aIpItens := {}
               EndIf
               // **

               nRecEEC := EEC->(Recno())
               lRecriaPed := .f.

               EEC->(dBSetOrder(1))
               If EEC->(DbSeek(cFilEx+M->EEC_PREEMB)) // ** Verifica se o Embarque existe na filial de off-shore.

                  /* by jbj - 08/03/2005 - 21:50.
                     O sistema não irá solicitar confirmação do usuário se a rotina de replicação de dados
                     estiver ativa */

                  If lReplicaDados
                     lRecriaPed := .f.
                  Else
                     lPergunta := .T.
                     If(EasyEntryPoint("EECAE100"),ExecBlock("EECAE100",.F.,.F.,{"EMB_RECRIAPED"}), )
                     If lPergunta
                        lRecriaPed := MsgYesNo(STR0097) //"Recriar o embarque na filial do exterior ?"
                     EndIf
                  EndIf

                  /* by jbj - 11/04/05 - Tratamentos retirados em função das novas críticas dos tratamentos
                                         de off-shore. */

                  /*
                  If !lRecriaPed
                     // Como o embarque não será recriado na filial de offshore,
                     //   valida as qtdes dos produtos entre as filiais.

                     If !Ap101VldQtde(OC_EM,!lReplicaDados)
                        EEC->(DbGoTo(nRecEEC))
                        lRet:=.f.
                        Break
                     EndIf
                  EndIf
                  */
               EndIf

               EEC->(DbGoTo(nRecEEC))

            Case (AvGetM0Fil() == cFilEx)

               /* by jbj - 24/02/2005. (11:13).
                  Caso a rotina de replicação de dados esteja habilitada, neste ponto para a opção de alteração,
                  o sistema irá analisar todos os campos alterados e disponibilizar opções para que o usuário
                  indique onde deseja replicar as alterações. (embarques de off-shore).*/

               If lReplicaDados
                  If nSelecao == ALTERAR
                     If !AxFieldUpdate(OC_EM)
                        lRet:=.f.
                        Break
                     EndIf
                  EndIf
               EndIf

               /* Realiza todas as validações para a filial de off-shore, para os processos com tratamento de
                  off-shore no brasil. */

               If !AE105VldOffShore(nSelecao,.f.)
                  lRet:=.f.
                  Break
               EndIf
         EndCase
      EndIf

      If EECFlags("INVOICE")  // ** By OMJ - 17/06/05 - Manutenção de Invoice.
         If !Ae108ValCpo("GRAVA_EMBARQUE")
            lRet := .F.
            Break
         EndIf

         If EECFlags("ITENS_LC")
            If !Ae107ValInv()
               lRet := .F.
               Break
            EndIf
         EndIf
      EndIf

      ////////////////////////////////////////////////////
      // Integração com Faturamento (Validação)         //
      // Geração de Pedido de Venda a Partir do Embarque//
      ////////////////////////////////////////////////////
      If lIntegra
         If lIntEmb

            ///////////////////////////////////////////////////////////////////////////////////////////
            //Verifica se existe o campo EE7_GPV nos Pedidos de Exportação que serão embarcados, e se//
            //algum estiver configurado para não gerar Pedido de Venda (EE7_GPV = 2 - Não) o embarque//
            //não poderá ser gerado com a nova integração entre SigaEEC e SigaFAT.                   //
            ///////////////////////////////////////////////////////////////////////////////////////////
            If EE7->(FieldPos("EE7_GPV")) <> 0
               If !FAT3VerGPV(nSelecao)
                  lRet := .F.
                  Break
               EndIf
            EndIf

            //////////////////////////////////////////////////////////////////////////////////////////
            //Verifica se o Pedido é Back to Back  ou Remessa, em caso Positivo não gera Faturamento//
            //////////////////////////////////////////////////////////////////////////////////////////
            If !(lBackTo .and. Ap106IsBackTo()) .or. (lConsign .and. (ValType(cTipoProc) == "C" .and. (cTipoProc == PC_BC .or. cTipoProc == PC_RC )))

               ////////////////////////////////////////////////
               //Realiza novas validações para verificar se o//
               //Pedido de Venda poderá ser gerado através   //
               //do Embarque (Nova Integração.)              //
               ////////////////////////////////////////////////
               If FAT3IntFat(M->EEC_PREEMB,nSelecao)

                  lRet := FAT3EmbGerPV(nSelecao,"VLD")
               EndIf
            EndIf
         Endif
      EndIf

      IF Inclui        // By jpp 20/07/2005 10:25 - Verificar se o embarque já existe antes da gravação.
         bVldEmbarque := AVSX3("EEC_PREEMB",AV_VALID)
         cOldReadVar := __readvar
         __readvar := "M->EEC_PREEMB"
         lRet := Eval(bVldEmbarque)
         __readvar := cOldReadVar

         IF ! lRet
            Break
         Endif
      Endif
      IF EasyEntryPoint("EECPEM36")
         lRet := ExecBlock("EECPEM36",.F.,.F.)
         IF ValType(lRet) <> "L"
            lRet := .T.
         Elseif ! lRet
            Break
         Endif
      Endif

      /* by jbj - 24/02/2005. (11:13).
         Caso a rotina de replicação de dados esteja habilitada, neste ponto para a opção de alteração,
         o sistema irá analisar todos  os  campos alterados e disponibilizar opções para que o usuário
         indique onde deseja replicar as alterações. (embarques de off-shore).*/

      If lReplicaDados
         If !lIntermed .Or. (lIntermed .And. AvGetM0Fil() == cFilBr)
            If nSelecao == ALTERAR
               If !AxFieldUpdate(OC_EM)
                  lRet:=.f.
                  Break
               EndIf
            EndIf
         EndIf
      EndIf

      /* by jbj - 11/04/05 - 17:20 - O sistema irá executar os tratamentos para acerto das alterações nas quantidades,
                                     a serem replicadas na filial do exterior. */
      /* ER - 24/09/2007 - Está função será chamada no AE100Grava.
      If nSelecao == ALTERAR
         If lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EEC_INTERM $ cSim  .And. !EECFlags("CAFE")
            Ax101SetQtde(OC_EM)
         EndIf
      EndIf
      */

      IF EasyGParam("MV_AVG0004") //RMD - 08/09/05 - Conferencia dos Pesos
         If !lAE100Auto .And. !EECGetPesos(OC_EM)
            lRet:=.f.
            Break                     
         EndIf   
      Endif
      If Type("lPagtoAnte") == "L" .And. lPagtoAnte     // By JPP - 08/02/2006 - 14:00 - Rotina de pagamento antecipado(adiantamentos) Habilitada.
         If ! AE105VldAdiant() // Se o Valor Total de adiantamento vinculado for maior que o valor total do embarque.
            If ! AE105AtuAdiant() // Se a tela de estorno do adiantamento vinculado não for confirmada.
               lRet := .f.
               Break
            EndIf
         EndIf
      EndIf

      //ER - 09/02/2007
      If lBackTo
         /* Função que irá verificar se existe alguma invoice que não tenha sido vinculada
            a itens. Em caso positivo, a função irá exibir msg de alerta ao usuário. */
         lRet := Ap106ChkVincInv()
         If !lRet
            Break
         EndIf
      EndIf

      If EECFlags("ESTUFAGEM")
         nRecnoWkIp := WorkIp->(Recno())
         cFiltroAtu := WorkIp->(DbFilter())
         WorkIp->(DbClearFilter())
         aItEstuf := {}
         WorkIp->(DbGoTop())
         While WorkIp->(!Eof())
            If WorkIp->(Empty(WP_FLAG) .And. WP_RECNO <> 0)
               If Ae110IsEstuf(M->EEC_PREEMB, WorkIp->EE9_SEQEMB)
                  aAdd(aItEstuf, WorkIp->({EE9_SEQEMB, EE9_COD_I}))
               Else
                  Ae110RmItem(M->EEC_PREEMB, WorkIp->EE9_SEQEMB)
               EndIf
            EndIf
            WorkIp->(DbSkip())
         EndDo
         If Len(aItEstuf) > 0
            EECView({{STR0217 + ENTER + ENTER, .T.},; //STR0217	"Os seguintes itens foram desmarcados, porém eles já haviam sido estufados:"
                     {EECMontaMsg({"EE9_SEQEMB", "EE9_COD_I"}, aItEstuf) + ENTER, .F.},;
                     {STR0218 +; //STR0218	"Para poder desmarcar efetivamente estes itens do processo de embaque, cancele a estufagem destes itens movendo-os para a aba "
                      STR0219, .T.}}) //STR0219	"'Itens não estufados' na rotina de Estufagem."
            lRet := .F.
         EndIf
         If !Empty(cFiltroAtu)
            WorkIp->(DbSetFilter((&("{||" + cFiltroAtu + "}")), cFiltroAtu))
         EndIf
         WorkIp->(DbGoTop())
         WorkIp->(DbGoTo(nRecnoWkIp))
      EndIf

      lTemAgente := .F.
      lMensaAg := .F.
      // ** Verifica se existe algum item não agenciado.
      WorkAg->(DbGoTop())
      Do While WorkAg->(!Eof()) .And. !lTemAgente
         If Left(WorkAg->EEB_TIPOAG,1) = CD_AGC
            lTemAgente := .t.
            lMensaAg := .t.
            If AvFlags("COMISSAO_VARIOS_AGENTES")
               If WorkAg->EEB_TIPCVL <> "3"
                  lMensaAg := .f.
               Else
                  WorkIp->(DbGoTop())
                  While WorkIp->(!EoF())
                     If !Empty(WorkIp->EE9_CODAGE)
                        lMensaAg := .f.
                        Exit
                     EndIf
                     WorkIp->(DbSkip())
                  EndDo
               EndIf
            EndIf
            If lMensaAg
               If EECTrataIt(nil,OC_EM) .And. !AvFlags("COMISSAO_VARIOS_AGENTES")
                  EECTotCom(OC_EM,, .T.)
                  EECComVlFix(OC_EM) // ** Efetua rateio para calcular o percentual para os agentes com comissão do tipo 'Valor Fixo'.
               EndIf
            EndIf
         EndIf
         WorkAg->(DbSkip())
      EndDo
      lTemAgente := .F.
      lMensaAg := .F.

      //THTS - 09/05/2018 - DU-E: Verifica se algum campo da due foi alterado com base nas tabelas de historico (DU-E3)
      If nSelecao == ALTERAR .And. AvFlags("DU-E3") .And. FindFunction("DUESeqHist") .And. FindFunction("getStatDUE")
         cStatusDUE := getStatDUE(M->EEC_PREEMB,DUESeqHist(M->EEC_PREEMB))
         If ! empty(cStatusDUE) .and. isDUEChange() //Existe diferenca entre o processo que esta sendo alterado e a DUE gerada pra ele
            If cStatusDUE == "1" //Aguardando Transmissao
               If MsgYesNo("Há uma declaração da DUE gerada e não transmitida para este processo."+ENTER+;
                  "Para continuar com a alteração do embarque o sistema irá excluir esta declaração e será necessário gerar uma nova para transmiti-la. Deseja prosseguir?", STR0035) //""###"Atenção"
                  //Exclui a DUE gerada para o processo
                  cRetifiDUE := "1" //Exclui a DUE gerada
               Else
                  lRet := .F.
                  Break
               EndIf
            ElseIf cStatusDUE $ "2|5" //Transmitida ou DUE Manual
               cRetifiDUE := "2" //marca DUE como Retificar
            EndIf
         else
            if cStatusDUE $ "2|5" .and. StDUERetif()
               cRetifiDUE := "3" //marca DUE Valida
            endif
         EndIf
      EndIf

   End Sequence

   dbSelectArea(cOldArea)

Return lRet

/*
Funcao      :
Parametros  :
Retorno     :
Objetivos   :
Autor       : Heder M Oliveira
Data/Hora   :
Revisao     : Leandro Diniz de Brito - Substituicao dos botoes(button) por Radio - 18/07/2003
Obs.        :
*/
Static Function AE100MANE( )

Local lRet:=.T.,cOldArea:=select(),cFilItem:=Xfilial("EE9"),bDel,lEstorna
Local oDlgID,aExecutar:={STR0019,STR0020,STR0021} //"&Cancelar"###"&Eliminar"###"&Retornar"

//Local bOk:={|| nOpcao:=1, oDLGID:END()} /*bBotao1*/
//Local bBotao2:={||cExecutar:=aExecutar[2], nOpcao:=1, oDLGID:END()} /*cExecutar:=aExecutar[1],*/
//Local bCancel:={||nOpcao:=0, lRet:=.F., oDLGID:END()}   /*bBotao3*/

Local cTit:=STR0022+ALLTRIM(M->EEC_PREEMB)+STR0023 //"Cancelar ou Eliminar Registro do Processo : "###" ?"
Local cExecutar:=aExecutar[3]

Local lLoop:= .F.

Local aProcs := {}
Local i, bDelFat,bLastHandler, lRetPE, lALTSTS:= .T.
Local aItens:={STR0005,STR0144} //"Cancelar"###"Eliminar"
Local lEXC //LRL 08/12/2003 - Permite a exclusão
Local lIsFilBr := .f.
Local cFil, j:=0
Local aSaveOrd := SaveOrd({"EEM","EEC"})
Local aProcMultiOffShore :={}, lEliminar := .f.
Local lExcluiPV := .F.
Local nValDev := 0
Local lOMacroCAPA:= .F.
Private nOpcao:=0   //TRP - 23/11/2011 - Variável utilizada em rdmake.
Private aAlias
Private lAtuStatus := .T.
Private nRadio:=1 //AAF - 24/09/04 - Declarada como private
Private xAtuPed := .f.
Private lPE_Exclui := .T.

   If !lAE100Auto .And. lDevTotItEmb    //NCF - 25/05/2015 - Devolução de Embarque Faturado.
      aAdd(aExecutar,"&Devolver")
      aAdd(aItens   ,"Cancelar por Devolução")
   EndIf

   If Type("oMacroCAPA") == "O" .And. Type("oMacroDet") == "O"
      lOMacroCAPA:= .T.
   EndIf

   IF lIntegra
      IF !Empty(EEC->EEC_PEDDES) .Or. !Empty(EEC->EEC_PEDEMB)
         HELP(" ",1,"AVG0000628") //("Primeiro estorne as notas complementares !","Aviso")
         lRet := .F.
      Endif
   Endif

   If EECFlags("CAFE") .And. EXL->(FieldPos("EXL_TIPOWO")) > 0
      If !Empty(M->EXL_TIPOWO)
         EasyHelp(STR0154, STR0035)//"Não é possível excluir porque este embarque faz parte de um processo de Wash-Out"###"Atenção"
         lRet := .F.
      EndIf
   EndIf

   ///////////////////////////////////////////////////////////////////
   //Ponto de Entrada para verificações adicionais antes da exclusão//
   ///////////////////////////////////////////////////////////////////
   If EasyEntryPoint("EECPAE01")
      ExecBlock("EECPAE01",.F.,.F.,{"VAL_EXCLUIR"})
   Endif

   If !lPE_Exclui
      lRet := .F.
   EndIf

   DO WHILE lRet

      nOpcao := 0
      If !lAE100Auto
         /*RMD - 19/06/2019 - Não exibe a tela pois a opção já foi definida no submenu da tela principal
            DEFINE MSDIALOG oDlgID FROM 20,30 TO /*27/30,80  TITLE cTit OF oMAINWND //FSM - 26/07/2011
               If AVFLAGS("EEC_LOGIX") .And. Len(aItens) >= 3
                  @ 40,027 Radio nRadio  ITEMS aItens[1],aItens[2],aItens[3]  size /*50/70,10 of oDlgID pixel
               Else
                  @ 40,027 Radio nRadio  ITEMS aItens[1],aItens[2]  size 50,10 of oDlgID pixel
               EndIf
            ACTIVATE MSDIALOG oDlgID ON INIT EnchoiceBar(oDlgID,bOk,bCancel) CENTERED
            */
         If IsMemVar("lAE100CANCE") .And. lAE100CANCE
            If MsgYesNo(STR0274, STR0063) //"Confirma o cancelamento do Embarque?" ### "Aviso"
               nRadio := 1
               nOpcao := 1
               if avflags("DU-E3") .and. VldSttDUE(xFilial("EK0"),EEC->EEC_PREEMB) ; //EK0->(dbsetorder(1),msseek(xFilial("EK0")+EEC->EEC_PREEMB)) ;
                  .and. ! MsgYesNo("Este embarque possui due gerada, caso prossiga todas as DUEs ficarão como histórico no sistema, mas com status de 'Embarque Cancelado'. Deseja prosseguir?", STR0063)
                     nOpcao:=0
                     lRet:=.F.
               endif
            Else
               nOpcao:=0
               lRet:=.F.
            EndIf
         ElseIf IsMemVar("lAE100DEV") .And. lAE100DEV
            If MsgYesNo(STR0275, STR0063) //"Confirma o cancelamento por devolução do Embarque?" ### "Aviso"
               nRadio := 3
               nOpcao := 1
            Else
               nOpcao:=0
               lRet:=.F.
            EndIf
         Else
            If MsgYesNo(STR0276, STR0063) //"Confirma a exclusão do Embarque?" ### "Aviso"
               nRadio := 2
               nOpcao := 1
               if avflags("DU-E3") .and. VldSttDUE(xFilial("EK0"),EEC->EEC_PREEMB) ; //EK0->(dbsetorder(1),msseek(xFilial("EK0")+EEC->EEC_PREEMB)) ;
                  .and. ! MsgYesNo("Este embarque possui due gerada, caso prossiga todas as DUEs ficarão como histórico no sistema, mas com status de 'Embarque Cancelado'. Deseja prosseguir?", STR0063)
                     nOpcao:=0
                     lRet:=.F.
               endif
            Else
               nOpcao:=0
               lRet:=.F.
            EndIf
         EndIf
      Else
         //Define a opção de exclusão automaticamente quando tiver sido chamado de ExecAuto
         nOpcao := 1
         nRadio := 2
      EndIf

      //TRP - 23/11/2011 - Ponto de Entrada para customização do Avinteg Exportação.
      If EasyEntryPoint("EECAE100")
         ExecBlock("EECAE100",.F.,.F., {"AE100MANE_POS_TELA"})
      Endif

      Begin Transaction // JPM - 06/04/06 - colocado o tratamento de transações.

         Begin Sequence

            If nOpcao == 1

               If lIntDraw  .And.  lMUserEDC  .And.  !oMUserEDC:Reserva("EMBARQUE_EXP","ESTORNA")  // PLB 05/12/06
                  lRet := .F.
                  Break
               EndIf

               //AOM - 28/04/2011- Operacao especial
               If !VldOpeAE100("EXC_EMB")
                  lRet := .F.
                  Break
               EndIf

               /*
               AMS - 22/11/2004 - 11:42. Na exclusão do embarque caso existe NF relacionada, irá apresentar msg de
                                          confirmação para exclusão.
               */
               If EEM->(dbSeek(xFilial()+M->EEC_PREEMB))
                  If !lIntEmb
                     If !lAe100Auto .And. !MsgYesNo(STR0137+lower(aItens[nRadio])+STR0138, STR0035) //"Foram encontradas NF(s) para este embarque. Deseja "###" o embarque?"###"Atenção"
                        lRet := .F.
                        Break
                     EndIf
                  Else
                     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                     //Quanto o fluxo alternativo de integração entre SigaEEC e SigaFat está habilitado, o embarque não poderá ser excluído caso//
                     //exista NFs vinculadas a este.                                                                                            //
                     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                     EasyHelp(STR0195,STR0035)//"Foram encontradas NF(s) para este embarque. As NF(s) devem ser estornadas para o cancelamento/exclusão do embarque."###"Atenção"
                     lRet := .F.
                     Break
                  EndIf
               EndIf

               /* by jbj - 20/07/04 - Para processos com tratamento de intermediação, o sistema valida se o cancelamento
                                       ou a eliminação poderá ser realizada, visto que para a rotina de off-shore, os
                                       pedidos cancelados/eliminados e uma filial são automaticamente cancelados ou
                                       eliminados na outra filial que faz parte da intermediação. */
               If lIntermed
                  If nRadio == 1 // Opção de cancelamento.
                     If !Ap104CanCancel(OC_EM)
                        lRet := .F.
                        Break
                     EndIf
                  EndIf

                  If !Ae100Crit("EEC_INTERM")
                     lRet := .F.
                     Break
                  EndIf
               EndIf

               If lIntegra
                  If lIntEmb
                     //////////////////////////////////////////////////////////////////////////////////////////
                     //Verifica se o Pedido é Back to Back  ou Remessa, em caso Positivo não gera Faturamento//
                     //////////////////////////////////////////////////////////////////////////////////////////
                     If !(lBackTo .and. Ap106IsBackTo()) .or. (lConsign .and. (ValType(cTipoProc) == "C" .and. (cTipoProc == PC_BC .or. cTipoProc == PC_RC) ))
                        ////////////////////////////////////////////////
                        //Realiza novas validações para verificar se o//
                        //Pedido de Venda poderá ser gerado através   //
                        //do Embarque (Nova Integração.)              //
                        ////////////////////////////////////////////////
                        If FAT3IntFat(M->EEC_PREEMB,EXCLUIR)
                           ////////////////////////////////////////////////////////////////////////////////////////////////
                           //Caso o Pedido esteja cancelado e a opção escolhida seja Excluir, não exclui Pedido de Venda,//
                           //já que este foi excluido ao Cancelar o Pedido.                                              //
                           ////////////////////////////////////////////////////////////////////////////////////////////////
                           If (cExecutar == aExecutar[2] .and. EEC->EEC_STATUS <> ST_PC) .or. cExecutar <> aExecutar[2]
                              lExcluiuPV := FAT3EmbGerPV(EXCLUIR,"GRV") //cancelar
                              If !lExcluiuPV
                                 lRet := .F.
                                 Break
                              Endif
                           EndIf
                        EndIf
                     EndIf
                  EndIf
               EndIf

               If Empty(cTipoProc) .Or. cTipoProc $ (PC_RC+PC_VR+PC_VB) //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
                  Ae108AtuEstoque(EXCLUIR, cTipoProc)
               EndIf

               IF EasyEntryPoint("EECAE100")
                  lRetPE := ExecBlock("EECAE100",.F.,.F.,{"PE_EXC",EEC->EEC_PREEMB})
                  // Verifica o retorno do ponto de entrada, se retornar false cancela a exclusao
               Endif

               IF ValType(lRetPE) == "L" .And. ! lRetPE
                  lRet := .F.
                  Break
               Endif

               If lIntCont
                  // ** AAF 09/01/08 - Tratamento dos eventos de estorno no contábil
                  If !AE100EstCon("ELIMINA_EMBARQUE")
                     Break
                  EndIf
                  // **
               EndIf

               IF EasyEntryPoint("EECAE100")
                  lRetPE := ExecBlock("EECAE100",.F.,.F.,{"PE_EXC",EEC->EEC_PREEMB})
                  // Verifica o retorno do ponto de entrada, se retornar false cancela a exclusao
               Endif

               IF ValType(lRetPE) == "L" .And. ! lRetPE
                  lRet := .F.
                  Break
               Endif

               // Validação para a opção de cancelar para processos cancelados.
               IF nRadio == 1  .AND. (EEC->EEC_STATUS==ST_PC)
                  MsgAlert(STR0198) //"Não é possível alterar o processo, pois o mesmo encontra-se cancelado."
                  lLoop:= .T.
                  Break
               Endif

               If lOkYS_PREEMB .AND. EasyGParam("MV_EEC_ECO",,.F.)
                  AE100CCGRV(.F.)
               EndIf

               If(lIntDraw .and. lOkEE9_ATO , ED3->(dbSetOrder(2)) ,)

               EE9->(dbSetOrder(2))
               If EE9->(dbSeek(cFilItem+EEC->EEC_PREEMB))
                  While !EE9->(EOF()) .AND. ;
                     cFilItem+EEC->EEC_PREEMB==EE9->EE9_FILIAL+EE9->EE9_PREEMB

                     If lIntDraw .and. lOkEE9_ATO .and. !Empty(EE9->EE9_ATOCON)
                        VoltaSaldoED3("C")
                        If lExistEDD  //GFC - 18/07/2003 - Drawback Anterioridade
                           EDD->(dbSetOrder(3))
                           If EDD->(dbSeek(cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EE9->EE9_COD_I+EE9->EE9_ATOCON+EE9->EE9_SEQED3))
                              ACDelAnt()
                           EndIf
                        EndIf
                     EndIf

                     RECLOCK("EE9",.F.)
                     If lIntDraw .and. lOkEE9_ATO
                        EE9->EE9_ATOCON := ""
                        EE9->EE9_SEQED3 := ""
                        EE9->EE9_QT_AC  := 0
                        EE9->EE9_VL_AC  := 0
                     EndIf
                     //NCF - 25/05/2015 - "Cancelar por devolução"
                     If lDevTotItEmb .and. nRadio == 3
                        //EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE+EES_PEDIDO+EES_SEQUEN
                        If ChkFile("EES")
                           EES->(DbSetOrder(1))
                           If EES->(DbSeek( xFilial("EES") + AvKey(EE9->EE9_PREEMB,"EES_PREEM") + AvKey(EE9->EE9_NF,"EES_NRNF") + AvKey(EE9->EE9_SERIE,"EES_SERIE") + AvKey(EE9->EE9_PEDIDO,"EES_PEDIDO") + AvKey(EE9->EE9_SEQUEN,"EES_SEQUEN")  ))
                              EES->(RecLock("EES",.F.))
                              EES->EES_QTDDEV := EES->EES_QTDE
                              EES->EES_VALDEV := EES->EES_QTDDEV * ( EES->EES_VLMERC / EES->EES_QTDORI)  //NCF - 10/05/2017
                              EES->EES_QTDE   := 0
                              EES->(MsUnLock())
                           EndIf
                        EndIf
                     EndIf

                     If nRadio == 1                          //NCF - 25/05/2015 - "Cancelar por devolução"
                        EE9->EE9_STATUS := ST_PC
                     ElseIf If( lDevTotItEmb , nRadio == 3, .F.)
                        EE9->EE9_STATUS := ST_CD
                        EE9->EE9_SLDINI := 0
                     EndIf

                     EE9->(MsUnlock())
                     EE9->(DBSKIP(1))
                  Enddo
               Endif

               If(lIntDraw .and. lOkEE9_ATO , ED3->(dbSetOrder(1)) ,)

               If nRadio == 1 .Or. If( lDevTotItEmb , nRadio == 3, .F.) //Cancelar   //NCF - 25/05/2015 - "Cancelar por devolução"

                  EEC->(RecLock("EEC",.F.))
                  //cancelar pedido
                  EEC->EEC_FIM_PE:=dDATABASE

                  If nRadio == 1
                     EEC->EEC_STATUS:=ST_PC
                  ElseIf nRadio == 3                        //NCF - 25/05/2015 - "Cancelar por devolução"
                     EEC->EEC_STATUS:=ST_CD
                  EndIf

                  //atualizar descricao de status
                  DSCSITEE7(.T.,OC_EM)
                  EEC->(MsUnlock())

                  If lIntermed
                     cFil := If(AvGetM0Fil()==cFilBr,cFilEx,cFilBr)
                     AE100CanEmb(cFil)
                     /* by jbj - 18/04/05 - Caso o ambiente possua habilitado os tratamentos de MultiOffShore,
                                             o sistema  irá  cancelar automaticamente  os níveis  de  off-shore
                                             existentes. */
                     If lMultiOffShore
                        aProcMultiOffShore := LoadEmbOffShore(AvGetM0Fil(),EEC->EEC_PREEMB)
                        For j:=1 To Len(aProcMultiOffShore)
                           Ae100CanEmb(cFilEx,aProcMultiOffShore[j][2])
                        Next
                     EndIf
                  EndIf
               EndIf

               // Cancelar DUEs.
               if avflags("DU-E3") .and. (nRadio == 2 .or. nRadio == 1)
                  // se houver DUE gerada e a mesma não tiver sindo transmitida ou tiver falha na transmissão
                  DU100CancelDue( xFilial("EEC")+EEC->EEC_PREEMB )
                  DU400GrvStatus()
               endif

               //JPM - 29/12/04 - Atualização dos campos relativos a carta de crédito
               If lNRotinaLC .And. !Empty(EEC->EEC_LC_NUM)// .And. (!lIntermed .Or. cFilEx <> xFilial("EEC"))
                  AE107DelLC()
               Endif

               If nRadio == 2  // Eliminar.

                  If lIntermed
                     If lMultiOffShore .And. EEC->EEC_INTERM $ cSim
                        aProcMultiOffShore := LoadEmbOffShore(AvGetM0Fil(),EEC->EEC_PREEMB,.t.)
                        For j:= 1 To Len(aProcMultiOffShore)
                           EEC->(DbGoTo(aProcMultiOffShore[j][3]))

                           xAtuPed   := Empty(EEC->EEC_NIOFFS)
                           lIsFilBr  := EEC->EEC_FILIAL  == cFilBr
                           lEliminar := (EEC->EEC_FILIAL == cFilEx .And. Empty(EEC->EEC_NIOFFS))

                           // JPM - 05/04/06 - Desvio para definir se o saldo será atualizado.
                           If EasyEntryPoint("EECAE100")
                              ExecBlock("EECAE100",.F.,.F.,{"DEL_MULTI_OFFSHORE"})
                           EndIf

                           If !(lRet := Ae100DelEmb(lIsFilBr,nil,xAtuPed,lEliminar))
                              Break
                           EndIf
                        Next
                     Else
                        lIsFilBr := (AvGetM0Fil() <> cFilEx)
                        If !(lRet :=  Ae100DelEmb(lIsFilBr,nil,nil,.t.))
                           lLoop := .F.
                           Break
                        EndIf
                     EndIf
                  Else
                     If !(lRet := Ae100DelEmb())
                        lLoop := .F.
                        Break
                     EndIf
                  EndIf
                  //CRF
                  If lOMacroCAPA
                     oMacroCapa:ExcluiMacro()
                     oMacroDet:ExcluiMacro()
                  EndIf
               Endif

               // *** caf 21/04/2001 Gravacao de parcelas de cambio com tratamento
               // de erros para evitar problemas com patch
               bLastHandler := ErrorBlock({||.t.})
               //Begin Sequence
               If !(lRet := AF200GPARC())
                  lLoop := .F.
                  Break
               EndIf
               //End Sequence
               ErrorBlock(bLastHandler)
               // ***

               If EasyEntryPoint("EECPAE01")
                  ExecBlock("EECPAE01",.F.,.F.,"EXCLUINDO TUDO")
               Endif

                  //AOM - 27/04/2011 - Operacao Especial
               If AvFlags("OPERACAO_ESPECIAL")
                  oOperacao:SaveOperacao()
               EndIf

               lRet:=.T.
            EndIf

         End Sequence
         
         if !lRet 
            ELinkRollBackTran()
         endif

      End Transaction

      ELinkClearID()

      If lLoop
         lLoop:= .F.
         LOOP
      Endif

      EXIT
   Enddo

dbSelectArea(cOldArea)

RestOrd(aSaveOrd,.t.)

Return lRet

/*
Funcao      : AE100DETMAN(cPedido)
Parametros  : cPedido
Retorno     : .T.
Objetivos   : Permitir manutencao pedidos p/embarcar
Autor       : Heder M Oliveira
Data/Hora   : 28/01/99 11:47
Revisao     : Cristiano A. Ferreira
Obs.        : 11/08/1999 13:42
*/
Static Function AE100DetMan(cPedido, xAuto)

   Local lRet  :=.T., nOldArea:=Select()
   Local nOpcA := 0
   Local oDlg, oBtnProc

   Local cBOTITULO:=AVSX3("EE7_PEDIDO",AV_TITULO)
   //Local bMarca, bDesMarca // , bTiraMark // By JPP - 26/04/2006 - 17:45 - Passou de local para private.

   Local bCont := {|| if(!empty(WorkIP->WP_FLAG),SumTotal(),) }
   Local cFileBak1, cFileBak2, cFileBak3, cFileBak4, cFileBak5, cFileBak6, cFileBak7
   Local aPos, lInverte := .f.

   Local bSelProc := {|| ADDPEDIDO(cPedido,oMark,oBrwPed,oGetPedido,aPedCampo,.T.,cWKAlias) }
   Local bSelAll := {|| MsAguarde({|| If(Type("oText") == "O",MsProcTxt(STR0071),.T.),SelAllItens(aPedCampo,oBrwPed:nAt,cWKAlias)},STR0017) }

   Local cOldFilter := WorkIP->(dbFilter())
   Local bOldFilter := &("{|| "+if(Empty(cOldFilter),".t.",cOldFilter)+" }")

   Local lOk
   Local oLayer, oColPedi, nPercHeight, nPercWidth
   Local aCoors := FWGetDialogSize( oMainWnd )

   Local aCapDelete := aClone(aCInvDeletados)
   Local aDetDelete := aClone(aDInvDeletados)

   Local c2OldFilter, b2OldFilter
   Local oPanel1, oPanel2
   Local i
   Local cChave2 := ""
   Local oBrwPed
   Local aPedCampo := {}
   Local oPedCol
   Local cWKAlias
   Local aSeek := {}
   Private aButtons := {{"NOTE" /*"EDITABLE"*/,bSelProc,cBoTitulo},;
                      {"LBTIK",bSelAll ,STR0026/*,STR0189*/}};
  //                    {"FILTRO",FilterX3Brw(cAlias, oDlg, oMsSelect:oBrowse:Refresh()}} //"Marca/Desmarca Todos" , "Marc./Des."

   Private lChamada := .t. //JPM
   Private oGetPsLiq, oGetPsBru, oGetPreco, oGetItens, oGetPrecoI, oSayPLiqIt, oSayPBruIt
   Private aTela[0][0],aGets[0],nUsado:=0

   //Private bOk     := {|| nOpcA:=1, oDlg:End()}
   Private bOk     := {|| If (AE108VldItDe(),(nOpcA:=1, If(!lAe100Auto, oDlg:End(),)),) }

   Private bCancel := {|| oDlg:End()}

   Private oMark

   Private bMarca, bDesMarca

   Private oGet_X, cGet_X := ""

   Private aItensAuto := xAuto

   If lConsolida
      c2OldFilter := WorkGrp->(dbFilter())
      b2OldFilter := &("{|| "+if(Empty(c2OldFilter),".t.",c2OldFilter)+" }")
   EndIf

   Begin Sequence

      //AOM - 28/04/2011 - Inicializa procedimento de transação das Operações especiais
      If AvFlags("OPERACAO_ESPECIAL")
         oOperacao:InitTrans()
      EndIf

      CursorWait()

      If lIntDraw .and. lOkEE9_ATO
         aAdd(aButtons,{"AUTOM",{||MsAguarde({|| ApuraItens(If(Inclui,"I","A"),aPedCampo,oBrwPed:nAt)},STR0082),oMark:oBrowse:Refresh()},STR0072/*,STR0190*/}) //"Apuração do Ato Concessorio" , "Ato Conces."
      EndIf

      ///////////////////////////////////////////////////////////////////////////
      //ER - 13/11/2008                                                        //
      //Botão que executa a rotina de preenchimento de Notas Fiscais de Entrada//
      //refrentes a mercadorias adquiridas com o fim especifico de Exportação. //
      ///////////////////////////////////////////////////////////////////////////
      /* WFS jun/2016 - melhoria na rotina.
         Funcionalidade passa a ser chamada para os itens do embarque e não mais para os itens do pedido selecionados no embarque. */
      If AvFlags("FIM_ESPECIFICO_EXP") .And. !NFRemFimEsp()
         AAdd(aButtons,{"PEDIDO",{|| AE110VincNfEnt()},If(AVFLAGS("EEC_LOGIX"),"Notas fiscais de remesa",STR0220)/*, STR0221*/}) // STR0220	"Vincular NFs de Entrada" //STR0221	"NFs Entr."
      EndIf

      //TDF - 15/03/2011
      aAdd(aButtons,{"FILTRO"  ,{|| FilterX3Brw("WorkIP", oDlg, aPedCampo[oBrwPed:nAt]), oMsSelect:oBrowse:Refresh() }, STR0222, STR0223}) //STR0222	"Filtrar registros" //STR0223	"Filtrar"

      IF Empty(cPedido)
         WorkIP->(dbGoTop())
         cPedido := WorkIP->EE9_PEDIDO
      Endif

      // ** By JBJ - 07/01/04  - 10:41 (Limpa o filtro p/ não gerar erro no 'copy to').
      WorkIp->(DbClearFilter())

      cFileBak1 := CriaTrab(,.f.)
      dbSelectArea("WorkIP")
      DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
      //copy to (cFileBak1+GetdbExtension())
      TETempBackup(cFileBak1) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      // ** By JBJ - 07/01/04  - 10:43 (Restaura o filtro).
      If !Empty(cOldFilter)
         WorkIp->(DbClearFilter())
         WorkIP->(DbSetFilter(bOldFilter,cOldFilter))
         WorkIP->(dbGoTop())
      Endif

      cFileBak2 := CriaTrab(,.f.)
      dbSelectArea("WorkEm")
      DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
      //copy to (cFileBak2+GetdbExtension())
      TETempBackup(cFileBak2) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      If EECFlags("INVOICE") //By OMJ - 22/06/2005 15:35 - Tratamento de Invoice

         cFileBak3 := CriaTrab(,.f.)
         dbSelectArea("WorkInv")
         DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
         //copy to (cFileBak3+GetdbExtension())
         TETempBackup(cFileBak3) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

         cFileBak4 := CriaTrab(,.f.)
         dbSelectArea("WorkDetInv")
         DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
         //copy to (cFileBak4+GetdbExtension())
         TETempBackup(cFileBak4) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      EndIf
      // ** JPM - 21/10/05 - Controle de quantidades entre filiais Br e Ex
      If lConsolida
         WorkGrp->(DbClearFilter())

         cFileBak5 := CriaTrab(,.f.)
         dbSelectArea("WorkGrp")
         //copy to (cFileBak5+GetdbExtension())
         TETempBackup(cFileBak5) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

         If !Empty(c2OldFilter)
            WorkGrp->(DbSetFilter(b2OldFilter,c2OldFilter))
            WorkGrp->(dbGoTop())
         Endif

         cFileBak6 := CriaTrab(,.f.)
         dbSelectArea("WorkOpos")
         //copy to (cFileBak6+GetdbExtension())
         TETempBackup(cFileBak6) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

      EndIf
      // **

      //THTS - 10/11/2017 - Trata Work das NFs
      cFileBak7 := CriaTrab(,.f.)
      dbSelectArea("WorkNF")
      DbGoTop()
      TETempBackup(cFileBak7)

      // ** AAF 02/08/05 - Guarda as apropriações já realizadas.
      If lIntDraw
         aOldAprop := aClone(aApropria)
      Endif
      // **
      CursorArrow()

      bMarca := {|| MarcDesmIt((cWKAlias)->EE9_PEDIDO,.T.,oMark,oBrwPed:nAt) }

      bDesMarca := {|| Eval(bTiraMark),;
                       AE100PrecoI(),;
                       If((lIntegra .Or. AvFlags("EEC_LOGIX")) .and. !Empty(WorkIP->EE9_NF), AE100MarkNF(.F., bTiraMark),),;
                       If(!lAE100Auto, oMark:oBrowse:Refresh(), )}

      IF ! Empty(M->EEC_PEDREF)
         cPedido := M->EEC_PEDREF
      Endif

      // Não mostra nenhum registro na primeira vez, força o usuário digitar o processo.
      If lConsolida
         WorkGrp->(DbClearFilter())
         WorkGrp->(DbSetFilter({||.f.},".f."))
         cWKAlias := "WorkGrp"
      ElseIf !lAE100Auto
         WorkIP->(DbClearFilter())
         WorkIP->(DbSetFilter({||EE9_PEDIDO==" "},"EE9_PEDIDO==' '"))
         cWKAlias := "WorkIP"
      EndIf

      /*
      AMS - 24/06/2005. Criação do ponto de entrada para customizar a rotina de marca/desmarca de itens.
      */
      If EasyEntryPoint("EECAE100")
         ExecBlock("EECAE100", .F., .F., {"PE_MARK_OK"})
      EndIf

      If !lAE100Auto

         aPedCampo := VERPEDIDOS(cWKAlias) //Verifica todos os pedidos da work
         If Len(aPedCampo) > 1
            cPedido := AvKey("","EE7_PEDIDO")
         Endif
         oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],"Seleção de Itens - " + Alltrim(M->EEC_PREEMB),,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,) 

         //Inicia a barra de botões
         EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

         //Cria as separações na tela
         oLayer := FWLayer():new()
         oLayer:Init(oDlg,.F.)

         nPercWidth := Round((290 / oLayer:oPanel:nClientWidth)*100,2)//Define o percentual dinamicamente com base na largura mínima de 290pxls para a seção do campo do pedido
         oLayer:AddCollumn('COL_PEDI',nPercWidth,.F.) //Lado esquerdo com os codigos dos pedidos
         oLayer:AddCollumn('COL_ITEM',100-nPercWidth,.F.) //Lado direito contendo os itens dos pedidos

         oColPedi := oLayer:getColPanel('COL_PEDI')
         nPercHeight := Round((115 / oColPedi:nClientHeight)*100,2)//Define o percentual dinamicamente com base na altura mínima de 115pxls para a seção do campo do pedido
         oLayer:AddWindow('COL_PEDI','PED_TOP', "Adicionar Pedidos",nPercHeight,.F.,.f.) //Adicionar Pedidos
         oLayer:AddWindow('COL_PEDI','PED_DOWN',"Pedidos",100-nPercHeight,.F.,.f.)//Pedidos
         oLayer:setColSplit('COL_PEDI',CONTROL_ALIGN_RIGHT)

         oLayer:AddWindow('COL_ITEM','PED_RIGHT',"Seleção de Itens",100,.F.,.f.) //Seleção de Itens

         //Get para informar um novo pedido
         @ 06,5 SAY "Pedido:"  PIXEL of oLayer:getWinPanel('COL_PEDI','PED_TOP')
         @ 14,5 MSGET oGetPedido VAR cPedido  SIZE 120,10 F3 "EE7"  PICTURE AVSX3("EE7_PEDIDO",AV_PICTURE) PIXEL of oLayer:getWinPanel('COL_PEDI','PED_TOP') HASBUTTON
         oGetPedido:bLostFocus := {|| IIF(ADDPedido(cPedido,oMark,oBrwPed,oGetPedido,aPedCampo,.F.,cWKAlias),cPedido := AvKey("","EE7_PEDIDO"),) }
         //Browse com os pedidos ja adicionados ao embarque
         oBrwPed:= FWBrowse():New(oLayer:getWinPanel('COL_PEDI','PED_DOWN'))
         oBrwPed:SetProfileID("BRPED")
         oBrwPed:SetDataArray()
         oBrwPed:SetArray(aPedCampo) 
         //oBrwPed:SetDescription("Pedidos")
         oBrwPed:DisableSeek()
         //oBrwPed:DisableConfig()
         oBrwPed:DisableFilter()
         oBrwPed:DisableLocate()
         oBrwPed:DisableReport()

         // Adiciona as colunas do Browse
         oPedCol := FWBrwColumn():New()
         oPedCol:SetData(&("{|| aPedCampo[oBrwPed:nAt]}"))
         oPedCol:SetTitle(AvSx3("EE9_PEDIDO"   , AV_TITULO))
         oPedCol:SetSize(AvSx3("EE9_PEDIDO", AV_TAMANHO))
         oPedCol:bHeaderClick := { || }
         oBrwPed:SetColumns({oPedCol})
         
         AAdd(aSeek, {AvSx3("EE9_PEDIDO"   , AV_TITULO), {{"", AvSx3("EE9_PEDIDO"   , AV_TIPO), AvSx3("EE9_PEDIDO"   , AV_TAMANHO), AvSx3("EE9_PEDIDO"   , AV_DECIMAL), AvSx3("EE9_PEDIDO"    , AV_TITULO)}}})
         oBrwPed:SetSeek(, aSeek)
         If lConsolida
            oMark := MsSelect():New("WorkGrp","WP_FLAG",,aGrpBrowse,@lInverte,@cMarca,,,,oLayer:getWinPanel('COL_ITEM','PED_RIGHT'))
            oMark:bAval := {|| If(WorkGrp->WP_FLAG="N",Eval(bMarca),If(AEAntVal(), MarcDesmIt((cWKAlias)->EE9_PEDIDO,.F.,oMark,oBrwPed:nAt) ,))  }
            oMark:oBrowse:aColumns[1]:lBitmap := .t.
            oMark:oBrowse:aColumns[1]:lNoLite := .T.
            oMark:oBrowse:aColumns[1]:bData := {|| If(WorkGrp->WP_FLAG = "N","LBNO",If(WorkGrp->WP_FLAG = "P","AVGOIC1"/*"AVGLBPAR1"*/,"LBOK")) }//RMD - 18/05/07 - Atualização da imagem utilizada
         Else
            //oMark := MsSelect():New("WorkIP","WP_FLAG",,aCampoPIT,@lInverte,@cMarca,aPos,,,oPanel2)
            oMark := MsSelect():New("WorkIP","WP_FLAG",,aCampoPIT,@lInverte,@cMarca,,,,oLayer:getWinPanel('COL_ITEM','PED_RIGHT'))
            oMark:bAval := {|| if(Empty(WorkIP->WP_FLAG),Eval(bMarca),If(AEAntVal(), MarcDesmIt((cWKAlias)->EE9_PEDIDO,.F.,oMark,oBrwPed:nAt) ,))  }
         EndIf
         oMark:oBrowse:BALLMARK := bSelAll
         oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
         //AE100SLPE(cPedido,oMark,.F.)
         oBrwPed:bChange := { || FilBrwItem(cWKAlias,aPedCampo[oBrwPed:nAt]),(cWKAlias)->(dbGoTop()),oMark:oBrowse:Refresh() } //BLoco de codigo para filtrar ao trocar as linhas com os codigos do pedido
         oBrwPed:Activate()
         oGetPedido:SetFocus()
         ACTIVATE MSDIALOG oDlg// ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) RMD - 17/09/20 - Movido o EnchoiceBar para antes da criação do Layer, para que as dimensões sejam calculadas corretamente
         
      Else
         aAutDeleta := {}
         //Executa a integração automática dos itens
         For i := 1 To Len(aItensAuto)
            WorkIp->(DbClearFilter())
            WorkIp->(DbSetOrder(1))
            //Localiza o item na work
            cChave2 := "EE9_SEQEMB"
            If aScan(aItensAuto[i], {|x| x[1] == "EE9_NF" }) > 0 .And. aScan(aItensAuto[i], {|x| x[1] == "EE9_SERIE" }) > 0
                cChave2 += "+EE9_NF+EE9_SERIE"
            EndIf
            If ((nSelecao == 3 .Or. aScan(aItensAuto[i], {|x| x[1] == "EE9_SEQEMB" }) == 0) .And. EasySeekAuto("WorkIp",aItensAuto[i],1)) .Or. (nSelecao <> 3 .And. EasySeekAuto("WorkIp",aItensAuto[i],2,,,cChave2))
                //Sempre desmarca o item antes de atualizar
                If !Empty(WorkIp->WP_FLAG)
                   //Valida a possibilidade de desmarcar
                   If AEAntVal()
                      //Executa a função que desmarca o item
                      Ae100Desmarca()
                   Else
                      lMsErroAuto := .T.
                      Exit
                   EndIf
                EndIf
                If aScan(aItensAuto[i], {|x| x[1] == "AUTDELETA" .And. X[2] == "S" }) == 0 //Verifica se não é uma exclusão
                    //Marca o item, registrando os campos recebidos
                    If (lMsErroAuto := !Ae100Marca(aItensAuto[i]))
                        Exit
                    EndIf
                Else
                    aAdd(aAutDeleta, WORKIP->(Recno()))
                EndIf
            Else
                cMsgChave := ""
                If (nPos := aScan(aItensAuto[i], {|x| x[1] == "EE9_PEDIDO" })) > 0
                    cMsgChave += "Pedido: " + Alltrim(aItensAuto[i][nPos][2]) + " "
                EndIf
                If (nPos := aScan(aItensAuto[i], {|x| x[1] == "EE9_SEQUEN" })) > 0
                    cMsgChave += "Sequência no Pedido: " + Alltrim(aItensAuto[i][nPos][2]) + " "
                EndIf
                If (nPos := aScan(aItensAuto[i], {|x| x[1] == "EE9_SEQEMB" })) > 0
                    cMsgChave += "Sequência no Embarque: " + Alltrim(aItensAuto[i][nPos][2]) + " "
                EndIf
                If Empty(cMsgChave)
                    cMsgChave := "Posição " + AllTrim(Str(i)) + "do array de itens "
                EndIf
                If aScan(aItensAuto[i], {|x| x[1] == "AUTDELETA" .And. X[2] == "S" }) == 0 //Verifica se não é uma exclusão
                    EasyHelp(STR0261 + cMsgChave + STR0262, STR0063)//"Não foi possível marcar o item "### ". Verifique se a chave está correta ou se não existem pendências de faturamento." ###"Aviso"
                    lMsErroAuto := .T.
                    Exit
                Else
                    EasyHelp(STR0263 + cMsgChave + STR0264, STR0063)//"Não foi possível excluir o item "###". Verifique se a chave está correta."###"Aviso"
                    lMsErroAuto := .T.
                    Exit
                EndIf
            EndIf
         Next
         For i := 1 To Len(aAutDeleta)
            WORKIP->(DbGoTo(aAutDeleta[i]))
            If !Empty(WorkIp->WP_FLAG)
                EasyHelp(StrTran(STR0265, "XXX", AllTrim(WORKIP->EE9_SEQEMB)), STR0063) //"Erro ao desmarcar o item de sequência: 'XXX'. Verifique se não existem outros itens da mesma nota fiscal marcados para embarque"###"Aviso"
                lMsErroAuto := .T.
            EndIf
         Next
         If !lMsErroAuto
            //Executa o OK final
            Eval(bOk)
         EndIf
      EndIf

      WorkIP->(DBCLEARFILTER())
      If lConsolida
         WorkGrp->(DbClearFilter())
      EndIf

      AE100VlrSCob()  // GFP - 12/11/2012

      IF nOpcA != 1 // Cancel
         CursorWait()
         M->EEC_PESLIQ:=M->EEC_PESBRU:=M->EEC_TOTITE:=M->EEC_TOTPED:=0
         dbSelectArea("WorkIP")
         AvZap()
         TERestBackup(cFileBak1)
         dbGoTop()
         dbEval(bCont)

         dbSelectArea("WorkEm")
         AvZap()
         TERestBackup(cFileBak2)

         If EECFlags("INVOICE") //By OMJ - 22/06/2005 15:35 - Tratamento de Invoice

            dbSelectArea("WorkInv")
            AvZap()
            TERestBackup(cFileBak3)

            dbSelectArea("WorkDetInv")
            AvZap()
            TERestBackup(cFileBak4)

            aCInvDeletados := aClone(aCapDelete)
            aDInvDeletados := aClone(aDetDelete)

         EndIf

         // ** JPM - 21/10/05 - Controle de quantidades entre filiais Br e Ex
         If lConsolida
            dbSelectArea("WorkGrp")
            AvZap()
            TERestBackup(cFileBak5)

            dbSelectArea("WorkOpos")
            AvZap()
            TERestBackup(cFileBak6)
         EndIf
         // **
         //THTS - 10/11/2017 - Volda o backup da workNF
         dbSelectArea("WorkNF")
         AvZap()
         TERestBackup(cFileBak7)

         CursorArrow()

         // ** AAF 02/08/05 - Guarda as apropriações já realizadas.
         If lIntDraw
            aApropria := {}
            aApropria := aOldAprop

            //WFS 05/09/11
            //Se a gravação da seleção de itens for cancelada, a apropriação também deve ser desfeita.
            //Para os processos que já possuem ato concessório vinculado, o controle do que já está gravado é realizado pelo array aApropria,
            //e, neste caso, a work não chega a ser recriada.
            If Select("WorkAnt") > 0
               If IsMemVar("FWorkAnt")
                  E_EraseArq(fWorkAnt,fWorkAnt2,fWorkAnt3)
               Else
                  WorkAnt->(DBCloseArea())
               EndIf
            EndIf

         Endif
         // **

         IF(AvFlags("OPERACAO_ESPECIAL"),oOperacao:EndTrans(.F.),) /*AOM - Encerra o processo de transição*/
         WorkIP->(dbGoTop())
         WorkEm->(dbGoTop())

         //MFR 05/07/2021 OSSME-5987
          EECTotCom(OC_EM,, .T.)  //qunando cancela tem que gerar a comissão de novo, pois se eu desmarco todos e cancelo, fica com o valor da comissão zerado no rodapé
      Else

         If lBackTo .and. Len(aColsBtb) > 0
            AP106VlInv(OC_EM)
         EndIf

         If EECFlags("COMISSAO")
            EECTotCom(OC_EM,, .T.)
         EndIf
         If EECFlags("INVOICE") //By OMJ - 22/06/2005 15:35 - Tratamento de Invoice
            Ae108ApDesp(.T.)
         EndIf

         IF(AvFlags("OPERACAO_ESPECIAL"),oOperacao:EndTrans(.T.),) /*AOM - Encerra o processo de transição*/
         /*
         AMS - 20/12/2004 às 10:54. Na alteração dos itens à embarcar, a flag lNFCompara recebe o valor .F.
                                    para que a qtde dos itens do embarque seja comparado com a qtde dos itens
                                    da NF.
         */
         //lNFCompara := .F. nopado por WFS em 31/05/2010 - o campo quantidade é bloqueado para alteração.

         If EEC->(FieldPos("EEC_INFGER")) # 0  // GFP - 28/05/2014
            M->EEC_VMINGE := GeraInfGerais()
         EndIf

      Endif

      If EEC->(FieldPos("EEC_VLRIE")) # 0 .AND. WorkIP->(FieldPos("EE9_VLRIE")) > 0 // GFP - 17/12/2015 - LRS - 21/01/2016
         M->EEC_VVLIE := AE100VLRIE(1)
      EndIf

      FErase(cFileBak1+GetDBExtension())
      FErase(cFileBak2+GetDBExtension())

      If EECFlags("INVOICE") //By OMJ - 22/06/2005 15:35 - Tratamento de Invoice
         FErase(cFileBak3+GetDBExtension())
         FErase(cFileBak4+GetDBExtension())
      EndIf

      IF !Empty(cOldFilter)
         WorkIP->(dbSetFilter(bOldFilter,cOldFilter))
         WorkIP->(dbGoTop())
      Endif

      If !Empty(c2OldFilter)
         WorkGrp->(DbSetFilter(b2OldFilter,c2OldFilter))
         WorkGrp->(dbGoTop())
      Endif

      // FJH 08/02/06
      If EasyGParam("MV_AVG0119",,.F.) .and. EE9->(FieldPos("EE9_DESCON")) > 0
         EECCALCDESC("Q")
      Endif
      Ae100PrecoI()
   End Sequence
   If(lConsolida,WorkOpos->(DbClearFilter()),)
   dbSelectArea(nOldArea)

   //If EasyGParam("MV_EEC0037",,.F.)  // GFP - 07/01/2014
      nTotPesBru := M->EEC_PESBRU
   //EndIf

   If !lAe100Auto .And. ValType(oMsSelect:oBrowse) = "O"
      oMsSelect:oBrowse:Refresh()
   EndIf

Return lRet

/*
Funcao      : AE100SelAll()
Parametros  :
Retorno     : Nil
Objetivos   : Marcar/Desmarcar todos (simplificar bSelAll)
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 21/10/05
Obs.        :
*/
*--------------------*
Function Ae100SelAll()
*--------------------*

Begin Sequence

   AE100MarkIt(bTiraMark)

   oMark:oBrowse:Refresh()

   If !Empty(cItens)
      If MsgYesNo(STR0105,STR0063) //"Deseja visualizar problema(s) na seleção de item(ns) ?"###"Aviso"
         AE100ShowIt()
      EndIf
   EndIf

   If lConsolida
      Ap104LoadGrp()  // Atualiza os agrupamentos de itens
   EndIf

End Sequence

Return Nil

/*
Funcao      : AE100Marca()
Parametros  :
Retorno     : Nil
Objetivos   : Marcar Item ou Consolidação de Itens (Simplificar edição do bMarca)
Autor       : João Pedro Macimiano Trabbold
Data        : 21/10/05
Obs.        :
*/
*-------------------*
Function Ae100Marca(xAuto)
*-------------------*
Local aFilter, nRec, aItens := {}, i, lRetIp := .F., lGpv
Private aEE9Auto := xAuto

Begin Sequence
   If lConsolida
      nRec := WorkGrp->(RecNo())
      aFilter := Ae104GrpFilter() // seta o filtro na WorkIp, baseado na WorkGrp
      WorkIp->(DbGoTop())
      While WorkIp->(!EoF())
         WorkIp->(AAdd(aItens,{RecNo(),WP_FLAG}))
         WorkIp->(DbSkip())
      EndDo
      WorkIp->(DbGoTop())
   EndIf

   lRetIp := Ae100DetIp() 

   If lConsolida
      EECRestFilter(aFilter[1]) // restaura filtro anterior
   EndIf

   If lRetIp
      lGpv := Ae100GPV()
      If lConsolida
         For i := 1 To Len(aItens)
            WorkIp->(DbGoTo(aItens[i][1]))
            If Empty(aItens[i][2]) .And. !Empty(WorkIP->WP_FLAG) // se o item foi marcado
               AE108VlMark(.T.)
               If lGpv .And. !Empty(WorkIP->EE9_NF)
                  cFiltroAtu := WorkIp->(DbFilter())
                  WorkIp->(DbClearFilter())
                  WorkIp->(DbSetFilter((&("{||" + cFiltroAtu + "}")), cFiltroAtu))
                  AE100MarkNF(.T.)
               EndIf
            ElseIf !Empty(aItens[i][2]) .And. Empty(WorkIP->WP_FLAG) // se o item foi desmarcado
               Eval(bDesmarca)
            EndIf
         Next
      Else
         If lGpv
            If !Empty(WorkIP->EE9_NF)
               AE100MarkNF(.T.)  
            EndIF
         EndIf
      EndIf
   EndIf

   If lConsolida
      If lRetIp
         If !lGpv
            Ae104GrpFilter() // só os itens do grupo. Atualizará apenas um registro da WorkGrp.
         EndIf
         Ap104LoadGrp() // atualiza os grupos
         If !lGpv
            EECRestFilter(aFilter[1])
         EndIf
      EndIf
      WorkGrp->(DbGoTo(nRec))
   EndIf


End Sequence

If Type("aFilter") == "A"
   EECRestFilter(aFilter[1]) // restaura filtro anterior
EndIf

If !lAE100Auto
    oMark:oBrowse:Refresh()
EndIf

Return lRetIp

/*
Funcao      : AE100Desmarca()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Desmarcar Item ou Consolidação de Itens (Simplificar edição do bDesMarca)
Autor       : João Pedro Macimiano Trabbold
Data        : 24/10/05
Obs.        :
*/
*----------------------*
Function Ae100Desmarca()
*----------------------*
Local aFilter, nRec, nRecIp

Begin Sequence

   If lConsolida
      nRec := WorkGrp->(RecNo())
      aFilter := Ae104GrpFilter() // seta o filtro na WorkIp, baseado na WorkGrp
      WorkIp->(DbGoTop())
      While WorkIp->(!EoF())
         If !Empty(WorkIp->WP_FLAG)
            nRecIp := WorkIp->(RecNo())
            EECRestFilter(aFilter[1]) // restaura filtro somente por pedido
            WorkIp->(DbGoTo(nRecIp))
            Eval(bDesmarca)
            EECRestFilter(aFilter[2]) // restaura filtro por agrupamentos
            WorkIp->(DbGoTo(nRecIp))
         EndIf
         WorkIp->(DbSkip())
      EndDo
      Ap104LoadGrp()
      EECRestFilter(aFilter[1])

      WorkGrp->(DbGoTo(nRec))

      If lConsolOffShore
         aFilter := Ae104GrpFilter(,"WorkOpos") // seta o filtro na WorkOpos, baseado na WorkGrp
         WorkOpos->(DbGoTop())
         While WorkOpos->(!EoF())
            If !Empty(WorkOpos->WP_FLAG)
               WorkOpos->WP_FLAG := "  "
               WorkOpos->WP_SLDATU  += WorkOpos->EE9_SLDINI
               WorkOpos->WP_OLDINI  := WorkOpos->EE9_SLDINI
               WorkOpos->EE9_SLDINI := 0
            EndIf
            WorkOpos->(DbSkip())
         EndDo
         EECRestFilter(aFilter[1])
         WorkGrp->(DbGoTo(nRec))
      EndIf
   Else
      If VldDesmOpe() //wfs 11/03/2020 - VldOpeAE100("DESMARC_IT")//AOM - 28/04/2011 - Operacao especial
         Eval(bDesmarca)
      EndIf
   EndIf

End Sequence

If Type("aFilter") == "A"
   EECRestFilter(aFilter[1]) // restaura filtro anterior
EndIf

If !lAe100Auto
   oMark:oBrowse:Refresh()
EndIf

Return Nil

/*
Funcao      : VldDesmOpe()
Parametros  : Nenhum
Retorno     : Lógico
Objetivos   : Validar se todos os itens que possuem vínculo com embalagens especiais podem ser desmarcados
Autor       : wfs
Data/Hora   : 11/03/2020
Revisao     :
Obs.        :
*/
Static Function VldDesmOpe()
Local lRet:= .T.
Local nOldRecno

Begin Sequence

   If !AvFlags("OPERACAO_ESPECIAL")
      Break
   EndIf

   /* Quando integrado, o sistema precisa desmarcar todas os itens/ todas as notas; logo, todo o processamento realizado anteriormente
      referente ao saldos das embalagens especiais deve ser desfeito */
   If lIntegra .Or. AvFlags("EEC_LOGIX")
      nOldRecno:= WorkIp->(Recno())
      WorkIp->(DBGoTop())
      While WorkIp->(!Eof())
         lRet:= VldOpeAE100("DESMARC_IT")
         WorkIp->(DBSkip())
      EndDo
      WorkIp->(DBGoTo(nOldRecno))
   Else
      lRet:= VldOpeAE100("DESMARC_IT")
   EndIf

End Sequence

Return lRet

/*
Funcao      : AE100SLPE()
Parametros  : Nenhum
Retorno     : Processo exportacao
Objetivos   : Selecionar processos de exportacao
Autor       : Heder M Oliveira
Data/Hora   : 27/01/99 13:46
Revisao     :
Obs.        :
*/
Static Function AE100SLPE(cPedido,oMark,lTela)
   Local cRet := cPedido, cTITULO:=AVSX3("EE7_PEDIDO",AV_TITULO)
   Local cARQF3 := "EE7", oDlg, nOLDAREA:=SELECT()
   Local bValid := {||AEPEDCRIT(cPedido)}, nOpcA:=0, lITPED:=.T.
   Local oPanel
   Local cSolucao := ""
   Default lTela := .T.
   Begin Sequence

       IF EasyEntryPoint("AE100SLPE",.F.,.F.)
           cBlock := EXECBLOCK("AE100SLPE",.F.,.F.)
           If ValType(cBlock)=="C"
              Return cBlock
           EndIf
       End If

      While .T.
         If lTela
            nOpcA:=0

            DEFINE MSDIALOG oDlg TITLE STR0030+cTITULO From 9,0 To 22,50 OF oMAINWND //"Seleção de "

               oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop))

               @ 0.4,0.8 TO 3.4,24.3 LABEL cTITULO+STR0031 of oPanel

               @ 1.4,1.2 MSGET cPedido SIZE 80,8 F3 cArqF3 VALID (NaoVazio(cPEDIDO)) PICTURE AVSX3("EE7_PEDIDO",AV_PICTURE) of oPanel HASBUTTON

               //wfs - alinhamento de tela
               oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

            ACTIVATE MSDIALOG oDlg ON INIT ;
               EnchoiceBar(oDlg,{||nOpcA:=1,If(Eval(bValid),oDlg:End(),nOpcA:=0)},;
                     {||nOpcA:=0,oDlg:End()}) CENTERED
         Else  
            If !Empty(cPedido)
               nOpcA:=1
            Else
               nOpcA := 0
            EndIf
         EndIf
         IF nOpcA == 1
            WorkIP->(DBCLEARFILTER())
            WorkIP->(dbGoTop())

            If lConsolida
               WorkOpos->(DbClearFilter())
               WorkOpos->(DbGoTop())
               WorkGrp->(DbClearFilter())
               WorkGrp->(DbGoTop())
            EndIf
            //NCF - 11/03/2015
            If AvFlags('EEC_LOGIX')
               aOpcPedFat := {}
               Do While WorkIP->(!Eof())
                  If ( nPosWkIP := aScan(aOpcPedFat, {|x| AvKey(x[1],'EE9_PEDIDO') == WorkIP->EE9_PEDIDO   } ) ) == 0
                     aAdd( aOpcPedFat , { WorkIP->EE9_PEDIDO, If( Empty(WorkIP->EE9_NF),.T.,.F.)  }  )
                  Else
                     aOpcPedFat[nPosWkIP][2] := If( Empty(WorkIP->EE9_NF),.T.,.F.)
                  EndIf
                  WorkIP->(DbSkip())
               EndDo
               WorkIP->(dbGoTop())
            EndIf

            PROCESSA({||lITPED:=EECPME01(cPEDIDO,,,@cSolucao)},STR0032+cTitulo,STR0033) //"Gravando informa‡äes do "###"Preparação de Embarque"

            IF !(lITPED)
               //Help(" ",1,"AVG0000625") // ("Não existem itens disponíveis para este Processo!","Aviso")
               EasyHelp(STR0281,STR0063,cSolucao)//"Não existem itens disponíveis para este Processo!"####"Aviso"
               If lTela
                  Loop
               Else
                  cRET:=""
                  Exit
               EndIf
            Endif

            cRET:=cPEDIDO
            //WorkIP->(DBSETFILTER({||EE9_PEDIDO==cPEDIDO},"EE9_PEDIDO=='"+cPEDIDO+"'"))
            //TDF 30/03/2011
            SetFilterWk(.T.,cPedido) //Filtra

            //oMark:oBrowse:ResetLen()
            oMark:oBrowse:Refresh()

         Endif

         Exit
      Enddo

   End Sequence

   dbSelectArea(nOldArea)

Return cRet

/*
Funcao      : AEPEDCRIT(cPEDIDO)
Parametros  : cPEDIDO
Retorno     : .t. /.f.
Objetivos   : Validar processo exportacao escolhido
Autor       : Heder M Oliveira
Data/Hora   : 05/02/99 14:23
Revisao     :
Obs.        :
*/
Function AEPEDCRIT(cPEDIDO)
    Local lRet:=.T.,cOldArea:=select(), lRetPe

    Private lB2BFat := IsProcNotFat()

    Begin Sequence
        EE7->(dbSetOrder(1))
        EE7->(dbSeek(XFILIAL("EE7")+cPEDIDO))

        //Do Case
           //Case lConsign
           // PLB 12/09/06 - Permitir a validacao dos outros itens mesmo com lConsign = True
           If lConsign
              If (cTipoProc == PC_VR .Or. cTipoProc == PC_VB)
                 If EE7->EE7_TIPO <> PC_VC
                    EasyHelp(STR0157, STR0035)//"O pedido informado não pode ser utilizado pois é de tipo diferente do Embarque."###"Atenção"
                    lRet := .F.
                    Break
                 EndIf
              ElseIf cTipoProc <> EE7->EE7_TIPO
                 EasyHelp(STR0157, STR0035)//"O pedido informado não pode ser utilizado pois é de tipo diferente do Embarque."###"Atenção"
                 lRet := .F.
                 Break
              EndIf
           EndIf

        Do Case
           Case EE7->EE7_STATUS == ST_RV
               EasyHelp(STR0129, STR0035) //"O pedido selecionado não pode ser integrado ao embarque, por ser um pedido especial, gerado para R.V. sem vinculação."
               lRet := .F.
               Break

           Case EE7->EE7_IMPORT+EE7->EE7_IMLOJA # M->EEC_IMPORT+M->EEC_IMLOJA
                HELP(" ",1,"AVG0000626") // ("O importador do pedido é diferente do importador do processo atual !","Atenção")
                lRet:= .f.

           Case lIntegra .AND.(EE7->(FIELDPOS("EE7_GPV")) > 0 .AND. EE7->EE7_GPV $ cSIM)//LRS 04/10/2016
                *
                // Integrado com sigafat nao verifica status
                Break

           // AMS - 16/03/2004 às 16:42. Case EE7->EE7_STATUS $ ST_PC+ST_SC+ST_LC+"Z"//Z-Customizacao Esmaltec
           Case EE7->EE7_STATUS $ ST_PC+ST_SC+ST_LC
                EasyHelp(STR0034+Tabela("YC",EE7->EE7_STATUS),STR0035) //"Processo "###"Atenção"
                lRet:=.F.
                Break

           // ** AAF 14/09/04 - Valida pedido para Back to Back
           Case lBACKTO .AND. !AP106Valid("EM_VAL_PEDIDO")
                //Verifica se o Pedido é o mesmo do primeiro item inserido em Caso de Back to Back
                lRet := .F.
                Break
           // **
        End Case

        /* by jbj - 11/04/05 - Neste ponto o sistema irá  validar se o  pedido poderá  ser selecionado  para
                               embarque na  filial do  exterior, visto  que, para  processos com off-shore o
                               embarque deverá ser realizado no brasil e criado automaticamente pelo sistema
                               na filial de off-shore. */

        If lIntermed // .And.  AvGetM0Fil() == cFilEx  // PLB 12/09/06 - Validacao na funcao AE108VldSelPel
           If !Ae108VldSelPed(cPedido)
              lRet:=.f.
              Break
           EndIf
        EndIf

        // ** By JBJ - 09/01/04 - Pto de Entrada para validacao da selecao de pedidos.
        If EasyEntryPoint("EECAE100")
           lRetPE := ExecBlock("EECAE100",.f.,.f.,{"PE_VLDSELPED",cPedido})

           IF ValType(lRetPE) == "L" .And. !lRetPe
              lRet:=.f.
           Endif
        Endif

    End Sequence

    dbSelectArea(cOldArea)
Return lRet

/*
Funcao      : AE100TTELA()
Parametros  : lTela:= .T. desenha tela
                      .F. refresh gets
              aPos := {Y inicial, X inicial, Y final, X final}
Retorno     : Nenhum
Objetivos   : Apresentar detalhe com totais
Autor       : Heder M Oliveira
Data/Hora   : 27/01/9917:51
Revisao     :
Obs.        :
*/
Function AE100TTELA(lTela, aPos, oPanel2)

   Local cUm_Peso := "Kg"
   //Local nTotVlrSCob := 0   // GFP - 31/10/2012
   Local nRecnoIP
   Local nTOTPEDCOM
   
   Private oRodape
   Private nL1,nL2,nC1,nC2,nC3,nC4

   //WFS 22/04/09 - Para verificar se houve alteração na unidade de medida da capa do processo
   Static cOldUn:= ""

   // SVG - 01/07/2010 -
   If Type ("lDrawSC") == "L" .and. lDrawSC .And. EE9->(FieldPos("EE9_VLSCOB")) > 0
      //DFS - Tratamento para não dar loop infinito ao desmarcar um item e cacelar a operação no Embarque
      If !lConsolida
         nRecnoIp := WorkIp->(Recno())
         WorkIp->(dbGoTop())
         /*  Nopado por GFP - 12/11/2012
         While WorkIp->(!EOF())
            nTotVlrSCob += WorkIp->EE9_VLSCOB
            WorkIp->(dbSkip())
         EndDo
         */
         If lTela  // GFP - 12/11/2012
            AE100VlrSCob()
         EndIf
         WorkIp->(DbGoTo(nRecnoIp))
      EndIf
   EndIf
   Begin Sequence
         
      cUm_Peso := M->EEC_UNIDAD

      //WFS - 22/04/09 ---
      /*Atualização dos pesos na capa do embarque de exportação sempre que houver alteração da unidade
        na capa do processo.*/
      If lTela .And. !Empty(M->EEC_UNIDAD)
         cOldUn:= cUm_Peso
      EndIf

      If !lTela .And. Upper(cOldUn) <> Upper(cUm_Peso)
         If AvTransUnid(IIF(!Empty(Upper(cOldUn)),Upper(cOldUn),"KG"), IIF(!Empty(Upper(cUm_Peso)),Upper(cUm_Peso),"KG"), , M->EEC_PESBRU, .T.) == Nil
            EasyHelp(STR0224 + AllTrim(cOldUn) + STR0225 + AllTrim(cUm_Peso) + STR0226 + ENTER +; //STR0224	"A conversão de " //STR0225	" para " //STR0226	" não está cadastrada."
                    STR0227, STR0035) //Atenção //STR0227	"Acesse Atualizações/ Tabelas Siscomex para realizar o cadastro."
            M->EEC_UNIDAD:= cOldUn
            Break
         Else
            M->EEC_PESBRU:= AvTransUnid(IIF(!Empty(Upper(cOldUn)),Upper(cOldUn),"KG"), IIF(!Empty(Upper(cUm_Peso)),Upper(cUm_Peso),"KG"), , M->EEC_PESBRU, .F.)
            M->EEC_PESLIQ:= AvTransUnid(IIF(!Empty(Upper(cOldUn)),Upper(cOldUn),"KG"), IIF(!Empty(Upper(cUm_Peso)),Upper(cUm_Peso),"KG"), , M->EEC_PESLIQ, .F.)
            cOldUn:= cUm_Peso
         EndIf
      EndIf
      //---
      nTotEmbBr := M->EEC_TOTPED + AE102CalcAg()
      // MFR 12/04/2020 OSSME-5384
      // Ponto de entrada que permite manipular as variáveis de totais do rodapé 
      If(EasyEntryPoint("EECAE100"),Execblock("EECAE100",.F.,.F.,"ANTES_REFRESH_RODAPE"),)  
      IF lTela
         nL1:= 4//aPos[1]+6 /* 126 */
         nL2:= nL1+9 /* 135*/
         nL3:= nL2+9
         nL4:= nL3+9

         nTamCol := (aPos[4]-aPos[2])/6

         nC1:=aPos[2]+1 /* 02 */
         nC2:=nC1+nTamCol /* 50 */
         nC3:=nC2+nTamCol /* 120 */
         nC4:=nC3+nTamCol /* 162 */
         nC5:=nC4+nTamCol  // GFP - 11/04/2014
         nC6:=nC5+nTamCol  // GFP - 11/04/2014

         //@ 120,01 TO 143,310 PIXEL
         @ aPos[1],aPos[2] TO aPos[3]+10,aPos[4] PIXEL OF oPanel2//oRodape  // SVG - 01/07/2010 -

         //ER - 31/05/2007
         If EasyEntryPoint("EECAP100")
            ExecBlock("EECAP100",.F.,.F.,{"ROD_CAPA_EMB",aPos})
         EndIf

         @ nL1,nC1 SAY STR0036 PIXEL SIZE 50,7 OF oPanel2//"Total Itens"
         @ nL1,nC5 SAY oSayPesLiq VAR STR0037+cUm_Peso PIXEL SIZE 50,7 OF oPanel2//oRodape //"Peso Liquido "
         @ nL2,nC1 SAY STR0038+M->EEC_MOEDA PIXEL SIZE 50,7 OF oPanel2//oRodape //"Total Embarque "
         @ nL2,nC5 SAY oSayPesBru VAR STR0039+cUm_Peso PIXEL SIZE 50,7 OF oPanel2//oRodape //"Peso Bruto "
         // SVG - 01/07/2010 -
         If Type ("lDrawSC") == "L" .and. lDrawSC .And. EE9->(FieldPos("EE9_VLSCOB")) > 0
            @ nL3,nC1 SAY oSayVlrSCob VAR STR0197 PIXEL SIZE 50,7 OF oPanel2//oRodape // "Vlr Tot S/ Cob"
            @ nL3,nC2 MSGET oVlrTotSCob   VAR nTotVlrSCob   PICTURE cITEPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2//oRodape
         EndIf

         
         @ nL4,nC1 SAY   oSayTotBru  VAR STR0269+M->EEC_MOEDA PIXEL SIZE 60,7 OF oPanel2//oRodape // //"Total Embarque (Bruto)"  
         @ nL4,nC2 MSGET oTotEmbBr   VAR nTotEmbBr  PICTURE cTPEPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2//oRodape  

         @ nL1,nC2 MSGET oItens   VAR M->EEC_TOTITE   PICTURE cITEPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2//oRodape
         @ nL1,nC6 MSGET oLiquido VAR M->EEC_PESLIQ   PICTURE cPLIPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2//oRodape

         @ nL2,nC2 MSGET oPedido  VAR M->EEC_TOTPED   PICTURE cTPEPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2//oRodape

         @ nL2,nC6 MSGET oBruto   VAR M->EEC_PESBRU   PICTURE cPBRPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2//oRodape
         If lTotRodape  // GFP - 11/04/2014
            @ nL1,nC3 SAY oSayTotFOB VAR STR0239+M->EEC_MOEDA PIXEL SIZE 53,7 OF oPanel2  //"Total FOB "
            @ nL2,nC3 SAY oSayTotCom VAR STR0240+M->EEC_MOEDA PIXEL SIZE 53,7 OF oPanel2  //"Total Comissão "
            @ nL3,nC3 SAY oSayTotLiq VAR STR0241+M->EEC_MOEDA PIXEL SIZE 53,7 OF oPanel2  //"Total Liquido "

            @ nL1,nC4 MSGET oTotFOB  VAR M->EEC_TOTFOB   PICTURE cTPEPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2
            @ nL2,nC4 MSGET oTotCom  VAR M->EEC_VALCOM   PICTURE cTPEPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2
            @ nL3,nC4 MSGET oTotLiq  VAR M->EEC_TOTLIQ   PICTURE cTPEPIC WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel2
         EndIf
      Else

         /*
         AMS - 10/11/2005. Imposta condição para não executar o metodo "Refresh" nos objetos de totais da capa do processo,
                           quando a chamada da função for da marcação/desmarcação de todos os itens no embarque.
         */
         If Type("lMarkall") = "L" .and. lMarkall
            Break
         EndIf

         If Type("oSayPesLiq") == "O"
            oSayPesLiq:SetText(STR0037+cUm_Peso)
            oSayPesBru:SetText(STR0039+cUm_Peso)
            oSayPesLiq:Refresh()
            oSayPesBru:Refresh()
         Endif

         IF Type("oItens") == "O"
            oItens:Refresh()
            oLiquido:Refresh()
            oPedido:Refresh()
            oBruto:Refresh()
            If( Type("oTotEmbBr") == "O" , oTotEmbBr:Refresh() ,    ) //oTotEmbBr:Refresh()
         Endif

      EndIf
      If IsMemVar("nTotPesBru")
         nTotPesBru := M->EEC_PESBRU
      EndIf
   End Sequence

Return NIL

/*
    Funcao   : AE100W(cCAMPOWHEN)
    Autor    : Heder M Oliveira
    Data     : 23/07/99 14:57
    Revisao  : 23/07/99 14:57
    Uso      : Regras para When
    Recebe   :
    Retorna  :

*/
FUNCTION AE100W(cCAMPOWHEN)

   Local lRET:=.T.,cNRAVSGANO,nNRAVSG,aBloqCmp
   Local cWhenRE := AllTrim(Substr(ReadVar(),4))

   cCAMPOWHEN := Alltrim(cCAMPOWHEN)

   DO CASE
      // *** Executa antes da edicao do campo ...
      CASE cWhenRE == "EEC_ORIGEM" //  cCAMPOWHEN="EEC_ORIGEM"
          cWHENOD:="O"
          cVIA:=M->EEC_VIA
      CASE cWhenRE == "EEC_DEST" //  cCAMPOWHEN="EEC_DEST"
          cWHENOD:="D"
          cVIA:=M->EEC_VIA
      CASE cWhenRE == "EEC_IMPORT" // cCAMPOWHEN="EEC_IMPORT"
          cWHENSA1:="EEC_IMPORT"
      CASE cWhenRE == "EEC_CLIENT"
          cWHENSA1:="EEC_CLIENT"
      CASE cWhenRE == "EEC_CONSIG"
          cWHENSA1:="EEC_CONSIG"
      CASE cWhenRE == "EEC_FORN"
          cWHENSA2:="EEC_FORN"
      CASE cWhenRE == "EEC_EXPORT"
          cWHENSA2:="EEC_EXPORT"
      CASE cWhenRE == "EEC_BENEF"
          cWHENSA2:="EEC_BENEF"
      CASE cWhenRE $ "EEC_PARCEL/EEC_ANTECI"
         IF (M->EEC_PARCEL==0 .AND. M->EEC_NPARC#0 .AND. M->EEC_TOTPED#0)
            IF M->EEC_DIASPA = -1
               M->EEC_PARCEL := 0
            ELSE
               M->EEC_PARCEL := (AE100VLPROC()-M->EEC_ANTECI)/M->EEC_NPARC
            ENDIF
         ENDIF
      CASE cWhenRE == "EEC_VLMNSC"
         IF (M->EEC_VLMNSC==0 .AND. M->EEC_MRGNSC#0)
            M->EEC_VLMNSC:=M->EEC_TOTPED*(M->EEC_MRGNSC/100)
         ENDIF
      CASE cWhenRE == "EEC_NRAVSG"
         IF EMPTY(M->EEC_NRAVSG)
            nNRAVSG   := VAL(LEFT(EasyGParam("MV_NRAVSG"),AT("/",EasyGParam("MV_NRAVSG"))-1))+1
            cNRAVSGANO:= SUBS(EasyGParam("MV_NRAVSG"),AT("/",EasyGParam("MV_NRAVSG"))+1)
            /*
            M->EEC_NRAVSG:=STRZERO(nNRAVSG,LEN(LEFT(EasyGParam("MV_NRAVSG"),AT("/",EasyGParam("MV_NRAVSG"))-1)),0)+"/"+cNRAVSGANO
            SETMV("MV_NRAVSG",M->EEC_NRAVSG)
            */
         ENDIF

      // *** Execute sempre que troca de campo ...
      CASE cCAMPOWHEN $ "EEC_ORIGEM/EEC_DEST/EEC_IMPORT/EEC_CLIENT/"+;
                        "EEC_CONSIG/EEC_FORN/EEC_EXPORT/EEC_BENEF/"
         IF ! lALTERA
            lRET:=.F.
         Endif
      CASE cCAMPOWHEN $ "EEC_PARCEL/EEC_ANTECI"
         IF ( lALTERA .AND. M->EEC_PARCEL==0 .AND. M->EEC_NPARC#0 .AND. M->EEC_TOTPED#0)
            IF M->EEC_DIASPA = -1
               M->EEC_PARCEL := 0
            ELSE
               M->EEC_PARCEL := (AE100VLPROC()-M->EEC_ANTECI)/M->EEC_NPARC
            ENDIF
         ELSEIF !LALTERA
            lRET:=.F.
         ENDIF
      CASE cCAMPOWHEN="EEC_VLMNSC"
         IF (lALTERA .AND. M->EEC_VLMNSC==0 .AND. M->EEC_MRGNSC#0)
            M->EEC_VLMNSC:=M->EEC_TOTPED*(M->EEC_MRGNSC/100)
         ELSEIF !LALTERA
            lRET:=.F.
         ENDIF
      CASE cCAMPOWHEN="EEC_NRAVSG"
         IF ( lALTERA .AND. EMPTY(M->EEC_NRAVSG) )
            nNRAVSG   := VAL(LEFT(EasyGParam("MV_NRAVSG"),AT("/",EasyGParam("MV_NRAVSG"))-1))+1
            cNRAVSGANO:= SUBS(EasyGParam("MV_NRAVSG"),AT("/",EasyGParam("MV_NRAVSG"))+1)
            /*
            M->EEC_NRAVSG:=STRZERO(nNRAVSG,LEN(LEFT(EasyGParam("MV_NRAVSG"),AT("/",EasyGParam("MV_NRAVSG"))-1)),0)+"/"+cNRAVSGANO
            SETMV("MV_NRAVSG",M->EEC_NRAVSG)
            */
         ELSEIF !LALTERA
            lRET:=.F.
         ENDIF
      CASE cCAMPOWHEN="EEC_PEDREF"
         IF ( lALTERA )
            IF !INCLUI
               lRET:=.F.
               //MSGSTOP("Pode ser usado apenas na Inclusão","Atenção")
            endif
         ELSE
            lRET:=.F.
         ENDIF
      CASE cCAMPOWHEN="EEC_RESPON"
         IF (lALTERA .AND. EMPTY(M->EEC_FORN))
            //MSGSTOP("Necessário informar Fornecedor","Atenção")
            lRET:=.F.
         ELSEIF !LALTERA
            lRET:=.F.
         ENDIF
      CASE cCAMPOWHEN="EEC_TIPTRA"
         IF ( lALTERA ) .AND. !lAE100Auto
            IF Empty(M->EEC_VIA)
               //MsgStop("Necessário informar a VIA !","Aviso")
               lRet:=.F.
            Else
               IF EMPTY(M->EEC_ORIGEM)
                  //MsgStop("Necessário informar a Origem !","Aviso")
                  lRet:=.F.
               Else
                  IF EMPTY(M->EEC_DEST)
                     //MsgStop("Necessário informar o Destino !","Aviso")
                     lRet:=.F.
                  Endif
               Endif
            Endif
         ELSEIF !LALTERA
            lRET:=.F.
         Endif
      // CASE cCAMPOWHEN="EEC_DTEMBA"
      //      lRET:=.T.
      CASE cCampoWhen=="EEC_SEGPRE"
         If Empty(M->EEC_PEDDES)     // By JPP - 07/07/2005 - 15:40
            lRet:= (lAltera .Or. lAltValPosEmb) .And. Empty(M->EEC_SEGURO)
         Else
            lRet:= .F.
         EndIf
      CASE cCampoWhen=="EEC_VALCOM"  // ** By JBJ - 02/04/02 - 13:28
         lRet:= .f. // lRet:=If(M->EEC_TIPCVL="3",.f.,.t.)
      CASE cCAMPOWHEN = "EE9_DTRE"  /// LCS - 08/05/2002
           IF ! lALTERA
              lRET := .F.
           ELSE
              lRET := IF(EMPTY(M->EE9_RE),.F.,.T.)
           ENDIF

     Case cCampoWhen $ "EE9_PERCOM/EE9_VLCOM" //LRS - 27/11/2014 - colocado na validação o campo EE8_VLCOM
        If EECFlags("COMISSAO")
           If !Empty(M->EE9_CODAGE)
              //If WorkAg->(DbSeek(M->EE9_CODAGE+CD_AGC)) - JPM - 01/06/05 - Tipo de Comissão por Item
              If WorkAg->(DbSeek(M->EE9_CODAGE+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+;
                                 If(EE9->(FieldPos("EE9_TIPCOM")) > 0,M->EE9_TIPCOM,"")))
                 If WorkAg->EEB_TIPCVL = "1" // Percentual.
                    lRet := .f.
                 ElseIf WorkAg->EEB_TIPCVL = "2" // Valor Fixo.
                    lRet := .f.
                 EndIf
              EndIf
           Else
              lRet:=.f.
           EndIf
           lRet := (lRet .And. If(Type("lDtEmba") == "L", !lDtEmba, Empty(M->EEC_DTEMBA)))
        Else
           lRet:= M->EEC_TIPCVL == "3"
        EndIf
     Case cCampoWhen=="EE9_CODAGE"
        lRet := Ap100W("EE8_CODAGE")//é o mesmo tratamento

     Case cCampoWhen $ "EE9_SLDINI/EE9_EMBAL1/EE9_QTDEM1/EE9_QE"

          If lIntermed .And. AvGetM0Fil() == cFilEx
             aOrd:=SaveOrd({"EEC"})
             EEC->(DbSetOrder(1))
             If EEC->(DbSeek(cFilBr+M->EEC_PREEMB))
                lRet:=.f.
             EndIf
             RestOrd(aOrd,.t.)

          ElseIf lIntermed .And. AvGetM0Fil() == cFilBr

             aOrd:=SaveOrd({"EEC"})
             EEC->(DbSetOrder(1))
             If EEC->(DbSeek(cFilEx+M->EEC_PREEMB))
                If !Empty(EEC->EEC_DTEMBA)
                   lRet:=.f.
                EndIf
             EndIf
             RestOrd(aOrd,.t.)
          EndIf

          If EECFlags("ESTUFAGEM")
             If Type("lItEstufado") == "L" .And. lItEstufado
                lRet := .F.
             EndIf
          EndIf

      Case cCampoWhen = "EE9_SEQ_LC"

         If Empty(M->EE9_LC_NUM)
            lRet := .f.
         ElseIf Posicione("EEL",1,xFilial("EEC")+M->EE9_LC_NUM,"EEL_CTPROD") $ cNao //Se não controla produto
            lRet := .f.
         EndIf

         If !lRet
            M->EE9_SEQ_LC := CriaVar("EE8_SEQ_LC")
         EndIf

      //LBL - 01/11/13
      Case cCampoWhen = "EE9_NRSD"
         If Type("M->EXL_DSE") == "C"
         	lRet := Empty(M->EXL_DSE)
         EndIf

      case cCampoWhen $ "EEC_DUEMAN|EEC_DTDUE|EEC_NRORUC"

         if ALTERA

            if avflags("DU-E2")
               // SE NÃO EXISTIR DUE OU SE O STATUS DA DUE FOR DIFERENTE DE DUE REGISTRADA
               cAuxDUE := getStatDUE(M->EEC_PREEMB,DUESeqHist(M->EEC_PREEMB))

               if cCampoWhen $ "EEC_DUEMAN"
                  if ! empty(cAuxDUE) .and. cAuxDUE $ "2|5" .or. DU100DUE()
                     lRet := .f.
                  endif
               endif

               if cCampoWhen $ "EEC_DTDUE|EEC_NRORUC" .and. ! empty(M->EEC_NRODUE) .and. empty(M->EEC_DUEMAN)
                  lRet := .f.
               endif

            else

               if EasyGParam("MV_EEC0053",, .T.)
                  lRet := .f.
               endif

            endif

         endif

   END CASE

   /*
   AMS - 24/06/2005. Tratamento para bloquear campos quando o parametro MV_AVG0094 estiver habilitado e
                     o campo "EE7_INTEGR"(origem do pedido) estiver igual "S".
   */
   If (Type("lEE7Auto") <> "L" .Or. !lEE7Auto) .And. EasyGParam("MV_AVG0094",, .F.) .and. EE7->(FieldPos("EE7_INTEGR") > 0 .and. EE7_INTEGR = "S")

      aBloqCmp := { "EEC_IMPORT",;
                    "EEC_IMLOJA",;
                    "EEC_FORN",;
                    "EEC_FOLOJA" }

      If aScan(aBloqCmp, cCampoWhen) > 0
         lRet := .F.
      EndIf

   EndIf

   //AAF 30/08/04
   IF EasyEntryPoint("EECAE100")
      uRET := ExecBlock("EECAE100",.F.,.F.,{"AE100WHEN",cCAMPOWHEN,cWhenRE,lRET})
      if ValType(uRET) == "L"
         lRET:= uRET
      endif
   Endif

RETURN lRET

/*
Funcao      : AE100DETIP(lAuto)
Parametros  : lAuto := Marca o item automaticamente
              lMarca := define se a função é chamada do 'Marca Todos' - By JPM - 05/08/05
              lP_MSG := se .t. mostra a msg de liquidacao de saldo
              lP_ATULSD := se .t., liquida o saldo automaticamente quando o lP_MSG
                           for .t.. Este parametro so é valido quando lP_MSG := .T.
              lVis  := Modo de visualização - JPM 24/10/05
Retorno     : .T.
Objetivos   : Permitir manutencao de outras descricoes da moeda
Autor       : Heder M Oliveira
Data/Hora   : 25/11/98 11:47
Revisao     :
Obs.        :
*/


*-----------------------------------------------------*
Function AE100DetIP(lAuto,lMarca,lP_MSG,lP_ATUSLD,lVis)
*-----------------------------------------------------*
   Local lRet:=.T.,cOldArea:=Alias(),oDlg,nInc, i, cNewtit,cSEQEMB
   //Local nOldOrd := indexOrd()
   Local nRecno, nOpcA := 0
   Local bOk_Det:={||nOpcA:=1,If(AE100VALDET(ALT_DET,nRECNO,aALTERA,oDLG),,nOpcA:=0)}//RMD 21/05/09 - Somente valida se lVis for falso.

   Local lIncDet := .f.
   Local aOrd := if(!Empty(cOldArea),SaveOrd({"EE8","EE7","SX3","EE9","SB1","SYD","SX3",cOldArea}),SaveOrd({"EE8","EE7","SX3","EE9","SB1","SYD","SX3"}))
   Local nQtdeOld := IF(EMPTY(WorkIP->WP_OLDINI),WorkIP->WP_SLDATU,WorkIP->WP_OLDINI)

   Local nPos, nEmbarcado := 0
   Local cFILTRO := WORKIP->(DBFILTER())
   Local bFILTRO := &("{|| "+cFILTRO+" }")
   Local aBloqCmp := {}
   Local aFilterBk, aButtons := {}
   Local aBackupItem := AClone(aItemEnchoice)
   Local lTipoItem := ChkFile("ED7") .And. ED7->(FieldPos("ED7_TPITEM")) > 0 .And. ED7->(FieldPos("ED7_PD")) > 0  //PLB 23/11/06
   Local nRecCont
   Local nSum
   Local cBack2EDG := CriaTrab(,.F.)
   Local cAliasWk := "WorkIp"
   Local lMemoria, aSldItWkIP  //NCF - 06/03/2018
   Local cBkpWkNF := CriaTrab(,.f.)
   Local lRestBkpNF := .F.
   Default lAuto     := .f.
   Default lMarca := .f. // By JPM - 05/08/05
   DEFAULT lP_MSG    := .T.
   DEFAULT lP_ATUSLD := .F.
   Default lVis  := .f.
   Private cIt := ""  //PLB 23/11/06
   Private lOldConsol := lConsolida, lOldOffShore := lConsolOffShore
   Private aPos, aAltera := aClone(aItemEnchoice) //AAF - 16/09/04 - Declarado como private para uso no Back to Back
   Private aTela[0][0],aGets[0], nQtdAux, lAtuAc:=.F.
   Private nSldOld := WorkIP->WP_SLDATU+WorkIP->EE9_SLDINI
   /* JPM - 25/10/05 - Variáveis da rotina de controle de quantidades entre filiais Brasil e Off-Shore */
   // Browse com itens da filial logada
   Private aCposDifAtu, aCposGDAtu, aHeaderAtu, aColsAtu, aHeadAdicAtu, aColsAdicAtu
   Private aAllCpos, aDifValid, aTotaliza

   // Browse com itens da filial Oposta (geralmente a off-shore)
   Private aCposDifOpos, aCposGDOpos, aHeaderOpos, aColsOpos, aHeadAdicOpos, aColsAdicOpos

   Private cTituloAtu, cTituloOpos
   Private lGDFilAtu := Nil
   Private aObjs := {}, oMsmGet
   Private aNotEditGetDados := {}
   Private lVisual := lVis, nOpcFolder := 1// grava última folder acessada
   Private oFolder, n, lArtificial := .f.
   /* JPM - 25/10/05 - Fim */

   Private lCalc := EasyGParam("MV_AVG0059",, .T.) //RMD - 26/04/07 - Quando esta variável era Static, causava erro na chamada da função MenuDef

   Private lAutom := lAuto
   Private aItButtons := {} // By JPP 14/11/2007 - 14:00

   lConsolida := lConsolida .And. !lAuto
   lConsolOffShore := lConsolOffShore .And. lConsolida

   If Type("lChamada") <> "L"
      lChamada:= Nil
   EndIf

   If lConsolida .And. (lVis .Or. ValType(lChamada) <> "L") // visualização ou alteração
      aFilterBk := Ae104GrpFilter() //seta filtro na WorkIp
   EndIf

   Begin Sequence
      If lItFabric // By JPP 14/11/2007 - 14:00
         aAdd(aItButtons,{"AVG_FABRIC",{|| AE109FabrIt(oDlg)},STR0191,STR0191}) // "Fabricantes Itens" 
      EndIf
      //TRP - 16/02/2009
      If Select("WorkEDG") > 0 .And. Type ("lDrawSC") == "L" .and. lDrawSC .And. !Empty(WorkIP->EE9_ATOCON)
         aAdd(aItButtons,{"CTBREPLA",{|| AE100Insumos(oDlg, 4)},STR0228,STR0228}) //STR0228	"Insumos"
      Endif
      //ER - 24/11/2006 - Caso o item não possua quebra de linha, não será tratado como consolidação.
      If lConsolida

         WorkIp->(DbGoTop())
         nRecCont := 0

         While WorkIp->(!EOF())
            nRecCont ++
            WorkIp->(DbSkip())
         EndDo

         WorkIp->(DbGoTop())

         If nRecCont < 1 .or. nRecCont == 1 .and. empty(WORKIP->(EE9_NF)) //WHRS 12/07/17 -TE-6185 524753 / MTRADE-1186 - Quantidades no Embarque no processo Off shore
            lConsolida := .F.
            lConsolOffShore := .F.
         EndIf

      EndIf

      If lConsolida //JPM - 25/10/05
         Ae104LoadArrays(cFilAtu,@aCposDifAtu,@aCposGDAtu,@aHeaderAtu)     // cria Arrays para MsGetDados - Itens Filial Atual
         If lConsolOffShore
            Ae104LoadArrays(cFilOpos,@aCposDifOpos,@aCposGDOpos,@aHeaderOpos) // cria Arrays para MsGetDados - Itens Filial Oposta
         EndIf
         Ae104CpoAdic() // trata campos adicionais que não são armazenados no aCols / aHeader
         Ae104LoadCols() // Carrega os itens no aCols e aCols adicional de cada filial
         M->EE9_TOTAL := 0 // Inicializa variável para GetDados
         M->REC_NO := 0 // Inicializa variável para GetDados
         // MFR 13/02/2020 OSSME-4353
         If lConsolOffShore .And. cFilAtu == cFilEx
            cAliasWk := "WorkOpos" //NCF - 06/03/2018 - Carregar a visualização com os dados do Item agrupado.
         EndIf
         lMemoria := .T.
      Else
         WorkNF->(TETempBackup(cBkpWkNF))
         lRestBkpNF := .T.
         AE108VlMark(.T.)
      EndIf

      For nInc := 1 TO (cAliasWk)->(FCount())
          M->&((cAliasWk)->(FieldName(nInc))) := (cAliasWk)->(FieldGet(nInc))
      Next nInc

      If lVisual //NCF - 06/03/2018
         aSldItWkIP := GetCpoIPVw()
         aEval( aSldItWkIP, {|x|  M->&(x[1]) := x[2]  })
      EndIf

      //AOM - 20/05/2011
      If AvFlags("OPERACAO_ESPECIAL")
         M->EE9_DESOPE := Posicione('EJ0',1,xFilial('EJ0') + M->EE9_CODOPE ,'EJ0_DESC')
      EndIf

      /* RMD - 22/12/15 - Não carrega os gatilhos para não sobrescrever o valor já calculado.
      If EE9->(FieldPos("EE9_PERIE")) > 0 .AND. EE9->(FieldPos("EE9_BASIE")) > 0 .AND. EE9->(FieldPos("EE9_VLRIE")) > 0   // GFP - 17/12/2015
         cNCM := Posicione('SB1',1,xFilial('SB1') + M->EE9_COD_I ,'B1_POSIPI')
         M->EE9_PERIE := Posicione('SYD',1,xFilial('SYD') + AvKey(cNCM,"YD_TEC") ,'YD_PER_IE')
         If Posicione("SX3",2,"EE9_PERIE","X3_TRIGGER") == "S"
            RunTrigger(1)
         EndIf
      EndIf
      */


      /* JPM - tratamentos para bloqueios de campos e validação de seleção de item - passados para função,
               para serem usados pela MsGetDados também, no caso de Consolidação de itens */

      If !lVis
         If !lConsolida .And. !Ae100VldSel() // todos os tratamentos para bloqueio de seleção de itens devem ser feitos nessa função, considerando variáveis de memória
            lRet := .f.
            Break
         EndIf

         If !lAuto
            aBloqCmp := Ae100BloqIt() // todos os tratamentos para bloqueio de campos devem ser feitos nessa função, considerando variáveis de memória

            For i := 1 To Len(aBloqCmp)
               If (nPos := AScan(aAltera,AllTrim(aBloqCmp[i]))) > 0
                  ADel(aAltera,nPos)
                  ASize(aAltera,Len(aAltera)-1)
               EndIf
            Next
         EndIf
      EndIf
      // **

      If EasyEntryPoint("EECAE100")
         lRet := ExecBlock("EECAE100",.F.,.F.,{"PE_MARK"})

         If ValType(lRet) = "L"
            If !lRet
               Break
            EndIf
         Else
            lRet:=.t.
         EndIf
      EndIf

      i := 0
      While .t.
         If lConsolida
            i++
            Ae104AuxIt(2,cFilAtu,.f.,i)
         EndIf

         If !lVis
            //lcs - 21/05/2001
            IF Empty(WorkIP->EE9_SEQEMB)
               lIncDet := .t.
               nRecNo  := WorkIP->(RecNo())
               WorkIp->(DbClearFilter()/*,DbGoTop()*/)
               WorkIp->(DbSetOrder(2))
               WorkIp->(DbGoBottom())
               cSeqEmb := Str(Val(WorkIP->EE9_SEQEMB)+1,AvSx3("EE9_SEQEMB",AV_TAMANHO))
               If !Empty(cFiltro)                                                          //NCF - 08/12/2015
                  WorkIp->(DbSetFilter(bFiltro,cFiltro))
               EndIf
               WorkIp->(DbSetOrder(1))
               WorkIp->(DbGoTo(nRecNo))
               WorkIp->EE9_SEQEMB := cSeqEmb
               M->EE9_SEQEMB:=cSeqEmb
               AE100WkEmb(M->EEC_PREEMB,WorkIP->EE9_SEQEMB,WorkIP->EE9_EMBAL1,WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,.T.)
            Endif

            If Empty(WorkIP->WP_FLAG)

               //If !lOldConsol .Or. !lOldOffShore
               If !lConsolida
                  //RMD - 05/05/08 - Se o bMarca já tiver definido o WorkIp->EE9_SLDINI, que carrega o M->EE9_SLDINI, respeita esse valor
                  If M->EE9_SLDINI == 0
                     M->EE9_SLDINI := IF(EMPTY(WorkIP->WP_OLDINI),WorkIP->WP_SLDATU,WorkIP->WP_OLDINI)
                  EndIf

                  IF lIncDet .And. AtualizaPesos() //(!lPesLib .Or. lPesLib .And.   // CAF 06/06/2000 WorkIP->WP_SLDATU != WorkIP->EE9_SLDINI .AND. nQtdeOld==0

                     SX3->(DbSetOrder(2))
                     SX3->(DbSeek("EE9_SLDINI"))
                     If SX3->X3_TRIGGER == "S"
                        RunTrigger(1)
                     Endif
                     __readvar := "EE9_SLDINI"
                     Eval(AVSX3("EE9_SLDINI",7)) // Valid
                     __readvar := space(10)
                  Endif
               EndIf

            ElseIf ValType(lChamada) <> "L"

               If !lAuto .or. lCalc
                  SubTotal()
               EndIf

            Endif
            EE8->(dbSetOrder(1))
            EE8->(DBSeek(XFILIAL()+WORKIP->(EE9_PEDIDO+EE9_SEQUEN)))
            IF EE8->EE8_SLDINI <> M->EE9_SLDINI //LRS - 23/10/2017
                //DFS - 26/09/12 - Retirado tratamento que calculava erroneamente a quantidade de embalagem do Embarque, quando copiado Pedido de Exportação.
                If M->EE9_SLDINI % M->EE9_QE == 0
                M->EE9_QTDEM1 := M->EE9_SLDINI/M->EE9_QE //FDR - 01/10/2012
                Else
                M->EE9_QTDEM1 := Int(M->EE9_SLDINI/M->EE9_QE)+1 //QUANT.DE EMBAL.
                EndIf

                If EasyEntryPoint("EECAE100")
                ExecBlock("EECAE100", .F., .F., {"APOS_CALC_EMBALAGEM"})
                EndIf
            Else
                M->EE9_QTDEM1 := EE8->EE8_QTDEM1
            EndIF

            //Ap101CalcPsBr(OC_EM,.f.,.f.,.t.) //Nopado. AMS - 27/12/2005.
            AE100CALC("PESOS")

         EndIf

         M->EE9_FINALI:=IF(EMPTY(M->EE9_FINALI),LEFT(COMBOX3BOX("EE9_FINALI")[2],AVSX3("EE9_FINALI",AV_TAMANHO)),M->EE9_FINALI)
         If !lOldConsol
            M->WP_SLDATU := (WorkIP->WP_SLDATU+WorkIP->EE9_SLDINI)-M->EE9_SLDINI
         EndIf

         If lConsolida
            Ae104AuxIt(3,cFilAtu,.f.,i)
            If i = Len(aColsAtu)
               Exit
            EndIf
         Else
            Exit
         EndIf
      EndDo

      If lIntDraw .and. lOkEE9_ATO
         If !Empty(WorkIP->EE9_ATOCON) .and. (ED3->ED3_AC <> M->EE9_ATOCON .or. ED3->ED3_SEQSIS<>M->EE9_SEQED3)
            ED3->(dbSetOrder(2))
            ED3->(dbSeek(cFilED3+M->EE9_ATOCON+M->EE9_SEQED3))
            ED3->(dbSetOrder(1))
         EndIf
         // ** PLB 23/11/06 - Itens Alternativos para F3 'EI1'
         If lTipoItem
            cIt := M->EE9_COD_I+"///"+IG400BuscaItem("E",M->EE9_COD_I)
         EndIf
         // **
      EndIf

      IF !lAuto
         cNewTit := (STR0040+Transf(M->EEC_PREEMB,AVSX3("EE9_PREEMB",AV_PICTURE))) //"Definição de Produtos para o Embarque "

         //AAF - 14/09/04 - Adiciona campos do Back to Back caso o Pedido seja Back to Back
         If lBACKTO
            AP106ItemEnc(OC_EM,EE7->EE7_PEDIDO)
         Endif

         If lConsolida // JPM - 25/10/05
            Ae104TratEdit() // trata campos da enchoice
         EndIf

         If lVis
            aAltera := {}
         EndIf

         If lConsolida .And. !(lVis .Or. ValType(lChamada) <> "L")
            aButtons := { {"LBTIK",{|| Processa({|| Ae104MarkAll()}) } ,STR0026} }//"Marca/Desmarca Todos" //JPM - 09/11/05
         EndIf

         If Type("M->EE9_DINT") == "C" //LRS 12/11/2014
	         If EECFlags("INTTRA") .And. Empty(M->EE9_DINT)
	            M->EE9_DINT := M->EE9_VM_DES
	         EndIf
         EndIF

         //TRP- 18/02/2009 - Guarda os dados da WorkEDG para caso seja acionada a opção cancelar
         If Type ("lDrawSC") == "L" .and. lDrawSC
            DbSelectArea("WorkEDG")
            //COPY TO (cBack2EDG)
            TETempBackup(cBack2EDG) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
         Endif

         //OAP -11/11/2010- Inclusão de campos que foram criados pelo usuário em aAltera, permitindo que os campos sejam alterados na Enchoice
         aAltera := AddCpoUser(aAltera,"EE9","1")

         //CRF - 23/02/2010
         If Type("oMacroDet") == "O"
            cValidBotao := "{|| oMacroDet:List()}"
            oMacroDet:AddButton(aItButtons, cValidBotao,"MPWIZARD")
         EndIf

         If !lAE100Auto

            DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

                aPos := PosDlg(oDlg)
                aPos[3] -= 28 // Rodape

                // - JPM - passado para MsMGet para retornar objeto
                If lConsolida // JPM - cria tela de itens consolidados
                    oFolder := TFolder():New(aPos[1],aPos[2],{"&"+STR0090,(STR0088 + AllTrim(WorkGrp->EE9_PEDIDO) + STR0089 + " &" + AllTrim(WorkGrp->EE9_ORIGEM))},;//"Geral" # "Itens Pedido " ## ", Origem "
                                            {"PASTA","ITENS"},oDlg,,,,.T.,.F.,aPos[4],aPos[3]-14)

                    oMsmGet := MsMGet():New("EE9", , 3, , , , aItemEnchoice, PosDlg(oFolder:aDialogs[1]), aAltera, If(!lVisual,3,2),,,,oFolder:aDialogs[1],,lMemoria)
                    oMsmGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT
                    oFolder:Align := CONTROL_ALIGN_TOP //WHRS 12/07/17 -TE-6185 524753 / MTRADE-1186 - Quantidades no Embarque no processo Off shore
                    Ae104TelaIt(oDlg)
                Else
                    //RMD - 17/08/12 - Recarrega o aRotina por conta de problemas em builds específicos
                    aRotina := aClone(__BkpAROT)
                    //FDR - 26/06/12
                    oMsmGet := MsMGet():New("EE9", , 3, , , , aItemEnchoice, aPos, aAltera, 3, , , ,oDlg)
                    oMsmGet:oBox:Align := CONTROL_ALIGN_TOP
                    //EnChoice( "EE9", , 3, , , , aItemEnchoice, aPos, aAltera, 3 )
                EndIf

                aPos[1] := aPos[3]
                aPos[3] := aPos[1]+28

                //FDR - 26/06/12
                oPanel:= TPanel():New(aPos[1],aPos[2], "", oDlg,, .F., .F.,,, aPos[4], 40,,.T.)
                oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

                AE100DetTela(.T.,aPos,ALT_DET,oPanel)

                // Puxar memo do work ...
                ///M->EE9_VM_DES := WorkIP->EE9_VM_DES
                /*
                AMS - 05/11/2003 às 13:00, Substituido a rotina abaixo, pq os campos do aMemoItens já
                                        estão sendo carregados no aFieldVirtual e tendo o seu conteúdo
                                        carregado pelo X3_RELACAO e gravado no WorkIP.
                                        Obs. Os campos de tipo "MEMO" devem ter o X3_RELACAO preenchido.

                FOR I := 1 TO LEN(aMEMOITEM)
                    IF WORKIP->(FIELDPOS(aMEMOITEM[I,2])) > 0
                    M->&(aMEMOITEM[I,2]) := WORKIP->&(aMEMOITEM[I,2])
                    ENDIF
                NEXT
                */

                oDlg:lMaximized := .T.

                If EasyEntryPoint("EECAE100")
                    ExecBlock("EECAE100", .F., .F., "DETIP_ACTIVATE_DLG")
                EndIf

            ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(lVis, (nOpca:=0, oDlg:End()),If(AE100ValAto("TELA"),Eval(bOk_Det),))},{||nOpcA:=0,oDlg:End()},,aItButtons)
         Else
            //Executa a integração dos campos do item selecionado para marcação automática
            //EnchAuto("EE9",aEE9Auto, {|| Obrigatorio(aGets,aTela)}, 3, aItemEnchoice)
            EnchAuto("EE9",ValidaEnch(aEE9Auto, aAltera), {|| Obrigatorio(aGets,aTela)}, 3, aItemEnchoice)

            //Valida e executa a ação do botão ok
            If(AE100ValAto("TELA"),Eval(bOk_Det),)
         EndIf

         //TRP- 18/02/2009 - Caso acionado o botão cancelar voltar as informações guardadas da WorkEDG referente aos insumos de importação
         If Type ("lDrawSC") == "L" .and. lDrawSC
            If nOpca == 0 .And. !lVis

               dbSelectArea("WorkEDG")
               AvZap()
               TERestBackup(cBack2EDG)
               WorkEDG->(DbGoTop())
            Endif
         Endif
      Else
         EE9->(dbSetOrder(3))
         EE9->(dbSeek(xFilial()+WorkIP->EE9_PREEMB+WorkIP->EE9_SEQEMB))
         If !lOldConsol
            EE8->(dbSetOrder(1))
            EE8->(DBSeek(XFILIAL()+WORKIP->(EE9_PEDIDO+EE9_SEQUEN)))
            EE9->(dbSetOrder(3))
            IF EE9->(dbSeek(xFilial()+WorkIP->EE9_PREEMB+WorkIP->EE9_SEQEMB))
               nEmbarcado := EE9->EE9_SLDINI
            Endif

            IF Empty(WorkIP->WP_FLAG) // Esta marcando ...
               M->WP_SLDATU := (EE8->EE8_SLDATU+nEmbarcado)-M->EE9_SLDINI
            Else
               M->WP_SLDATU := (EE8->EE8_SLDATU+nEmbarcado)
            Endif

            If !EECFlags("COMMODITY") .Or. Empty(M->EE9_RV) // JPM - 10/01/06 - se tiver r.v. não liquida saldo.
               // LCS - 23/11/2001
               IF lP_MSG
                  IF (lIntDraw .and. VerACParcial()) .or. (lIntegra .Or. AvFlags("EEC_LOGIX")).And. !Empty(M->EE9_NF) .OR.;
                     (!lMsgZeraSaldo .And. M->WP_SLDATU > 0 .AND. MSGNOYES(STR0041   +WORKIP->EE9_PEDIDO+CRLF+; //"Pedido: " // ** By JPP - 14/03/2007 - lMsgZeraSaldo - Desabilita/Habilita mensagem(opção) para eliminar saldo de pedidos embarcados parcialmente.
                                                      STR0042+WORKIP->EE9_SEQUEN+CRLF+; //"Sequencia: "
                                                      STR0043     +WORKIP->EE9_COD_I+CRLF+; //"Item: "
                                                      STR0044    +TRANSFORM(M->WP_SLDATU,AVSX3("EE8_SLDATU",AV_PICTURE))+CRLF+; //"Saldo: "
                                                      STR0045,STR0046)) //"Deseja Liquidar O Saldo ?"###"Embarque Parcial"
                     M->WP_SLDATU := 0
                  ENDIF
               ELSEIF lP_ATUSLD
                      M->WP_SLDATU := 0
               ENDIF
            EndIf
         EndIf
         nOpcA := 1
      Endif

      If Type("lMarkAll") <> "L"
         lMarkAll:= Nil
      EndIf

      IF nOpcA == 1 .And. !lVis // Ok
         AE100CALC("EMBALA")
         AE100CALC("PESOS")

         For i := 1 To If(lConsolida,Len(aColsAtu),1)

            //AOM - 27/04/2011 - Operacao especial
            If !VldOpeAE100("MARC_ITS_EMB")
               Return .F.
            EndIf

            //GFP - 31/10/2012 - Quando Cond. Pagamento for "Sem Cobertura Cambial", sistema deve carregar o campo EE9_VLSCOB com o valor do item.
            If !lIntDraw .AND. M->EEC_MPGEXP == '006' .AND. EE9->(FieldPos("EE9_VLSCOB")) <> 0 // Sem Cobertura Cambial
               M->EE9_VLSCOB := M->EE9_SLDINI * M->EE9_PRECOI //TRANSF(M->EE9_SLDINI * M->EE9_PRECOI,AVSX3("EE9_SLDINI",6))
            EndIf

            If lConsolida
               Ae104AuxIt(2,,.f.,i,,) // simula variáveis de memória de acordo com o aCols da GetDados
               If Empty(M->WP_FLAG)
                  M->WP_RECNO := WorkIp->WP_RECNO
                  AvReplace("M","WorkIP")
                  If !Empty(WorkIP->WP_FLAG)
                     WorkIP->WP_FLAG := "  "
                     SumTotal()
                  EndIf
                  Ae104AuxIt(3,,.f.,i,.t.,)
                  Loop
               EndIf
            EndIf

            If lIntDraw .and. lOkEE9_ATO
               AE100AtuAC(.T.)   //Atualiza dados do Ato Concessório
            EndIf

            //WHRS COLOCAR O CONTROLE DE SALDO AQUI DO VALID
            atuaSaldRe()
            M->WP_RECNO := WorkIp->WP_RECNO
            AVREPLACE("M","WorkIP")
            WorkIP->WP_FLAG   := cMARCA

            If !Empty(WorkIP->WP_FLAG)
               SumTotal()
            EndIf
            // MFR 19/10/2020 OSSME-5231
            //If ValType(lMarkAll) <> "L" .Or. Eval( {|| WorkIp->(DbSkip(),lEoF := EoF(),DbSkip(-1),lEof ) } ) //By JPM - 31/10/05
            If (!lAuto)// .Or. Eval( {|| WorkIp->(DbSkip(),lEoF := EoF(),DbSkip(-1),lEof ) } )) .and. !lNf
               // ** By JBJ - 10/06/03 - 10:33 - Calcular o total da comissão para os agentes.
               If EECFlags("COMISSAO")
                  EECTotCom(OC_EM)
               EndIf
               AE100PrecoI()
            EndIf

            If lIntDraw .and. lOkEE9_ATO .and. lAtuAc
               AE100AtuAC(.F.)   //Atualiza dados do Ato Concessório
            EndIf

            If lConsolida
               Ae104AuxIt(3,,.f.,i,.t.,) // restaura variáveis de memória
            EndIf

         Next

         If lConsolOffShore  //Grava itens da filial oposta do aCols para a Work.
            For i := 1 To Len(aColsOpos)
               Ae104AuxIt(2,cFilOpos,.f.,i,,)
               WorkOpos->(DbGoTo(GdFieldGet("REC_NO", i , .f. , aHeadAdicOpos , aColsAdicOpos )))
               M->WP_RECNO := WorkOpos->WP_RECNO
               AvReplace("M","WorkOpos")
               If !Empty(WorkOpos->WP_FLAG)
                  WorkOpos->WP_FLAG := cMarca
               EndIf
               Ae104AuxIt(3,cFilOpos,.f.,i,.t.,)
            Next

         ///////////////////////////////////////////////////////////////////////////////////
         //ER - 17/02/2009                                                                //
         //No caso de o processo não for consolidado, porém a rotina estiver habilitada no//
         //ambiente, a WorkOpos é gravada com base na WorkIp(apenas na inclusão de item). //
         ///////////////////////////////////////////////////////////////////////////////////
         ElseIf lOldOffShore .and. !lConsolOffShore
            If lFilBr //Realizado apenas na filia Brasil.
               If WorkOpos->(DbSeek(WorkIp->(EE9_PEDIDO+EE9_SEQUEN)))
                  If !Empty(WorkIp->WP_FLAG)
                     ////////////////////////////////////////////////////////////////////
                     //Atualiza o preço unitário com o preço negociado da Filial Brasil//
                     ////////////////////////////////////////////////////////////////////
                     If WorkIp->WP_RECNO == 0 //Inclusão

                        AvReplace("WorkIp","WorkOpos")                        
                        EE8->(DbSetOrder(1))
                        If EE8->(DBSeek(cFilBr+WorkIp->(EE9_PEDIDO+EE9_SEQUEN)))
                           WorkOpos->EE9_PRECO := EE8->EE8_PRENEG
                        EndIf
                     Else  //Alteração
                        EE9->(DbSetOrder(1))
                        If EE9->(DbSeek(cFilEx+WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN))
                           WorkOpos->WP_RECNO := EE9->(RecNo())
                        EndIf
                     EndIf
                     WorkOpos->WP_FLAG := cMarca

                  EndIf
               EndIf
            EndIf
         EndIf

         /* If lItFabric // By JPP 14/11/2007 - 14:00 - Inclusão da função AE109QBRIT().
            AE109QBRIT()
         EndIf */

      ElseIf !lVis // Cancel - não visualizar...
         If lRestBkpNF
            WorkNF->(AvZap())
            WorkNF->(TERestBackup(cBkpWkNF))
            lRestBkpNF := .F.
         EndIf

         If !lConsolida
            If !Empty(WorkIp->WP_FLAG)
               SumTotal()
            EndIf
         EndIf

         /*
         AMS - 09/11/2005. Imposta a chamada das funções AE100PrecoI e EECTotCom no cancelamento da MSDialog do item para
                           que os valores sejam recalculados, caso os mesmos tenham sidos alterados, decorrentes
                           a valores informados no item.
         */
         If (ValType(lMarkall) = "L" .and. !lMarkall) .or. !lAuto

            AE100PrecoI()

            If EECFlags("COMISSAO")
               EECTotCom(OC_EM)
            EndIf

         EndIf

         lRET:=.F.
      Endif

   End Sequence

   If lConsolida .And. lVis
      EECRestFilter(aFilterBk[1]) //Restaura filtro anterior
   EndIf

   RestOrd(aOrd)
   if !Empty(cOldArea)
      dbSelectArea(cOldArea)
   Else
      dbSelectArea("WORKIP")
   EndIf
   //dbSetOrder(nOldOrd)
   lConsolida := lOldConsol
   lConsolOffShore := lOldOffShore
   aItemEnchoice := AClone(aBackupItem)

Return lRet

/*
Função      : Ae100BloqIt
Objetivos   : Bloquear edição de itens
Parâmetros  : lArray - se .t.-> retorna array de campos a serem bloqueados
                       se .f.-> retorna .t. ou .f., se o campo cVar poderá ser editado.
              cVar - campo para validar o When (no caso da MsGetDados)
Retorno     : de acordo com os parâmetros acima
Autor       : João Pedro Macimiano Trabbold
Data e Hora : 26/10/05 - 10:45
*/
*-------------------------------*
Function Ae100BloqIt(lArray,cVar)
*-------------------------------*
   Local xRet, /*aBloq := {},*/ aBloqCmp, nInc, i

   Default lArray := .t.
   Default cVar := SubStr(ReadVar(),4)
   Private aBloq := {}

   If Type("aCposDifAtu") <> "A" .Or. !lConsolida
      aCposDifAtu := {}
   EndIf

   Begin Sequence

      // BAK - Bloquear o campo de quantidade embarcada, caso esteja tambem integrado com Logix - 19/10/2012
      IF (lIntegra .Or. AvFlags("EEC_LOGIX")) .and. !Empty(M->EE9_NF) // by CAF 16/02/2005 - !lSelNotFat
         EE7->(DbSetOrder(1))
         EE7->(DbSeek(xFilial("EE7")+M->EE9_PEDIDO))
         IF EE7->(FIELDPOS("EE7_GPV") = 0 .OR. EE7->EE7_GPV $ cSIM)
            If AScan(aBloq,"EE9_SLDINI") = 0
               AAdd(aBloq,"EE9_SLDINI")
            EndIf
         EndIf
      EndIf

      If lCommodity
         /* Tratamentos para as situações abaixo:
            Sit.1 : Caso o item não tenha preço em fase de pedido,
                    não permite alteração no preço na fase de embarque.

            Sit.2 : Caso o item possua fixação de preço em fase de pedido,
                    não permite alteração no preço na fase de embarque. */

         EE8->(DbSetOrder(1))
         If EE8->(DbSeek(xFilial("EE8")+M->EE9_PEDIDO+M->EE9_SEQUEN))
            If Empty(EE8->EE8_PRECO) .Or. !Empty(EE8->EE8_DTFIX)
               If AScan(aBloq,"EE9_PRECO ") = 0
                  AAdd(aBloq,"EE9_PRECO ")
               EndIf
            EndIf
         EndIf
      EndIf

      /*
      AMS - 24/06/2005. Tratamento para bloquear campos, quando o item for de um pedido originário da integração e
                        o parametro MV_AVG0094 estiver habilitado.
      */
      If EasyGParam("MV_AVG0094",, .F.) .and. EE7->(FieldPos("EE7_INTEGR")) > 0

         EE7->(dbSetOrder(1),;
               dbSeek(xFilial()+M->EE9_PEDIDO))

         If EE7->EE7_INTEGR = "S"

            aBloqCmp := { "EE9_COD_I ",;
                          "EE9_PRECO ",;
                          "EE9_SLDINI"}

            For nInc := 1 To Len(aBloqCmp)
               If AScan(aBloq, aBloqCmp[nInc]) = 0
                  AAdd(aBloq,aBloqCmp[nInc])
               EndIf
            Next

         EndIf

      EndIf

      If lDtEmba //RMD - 24/05/06
         If IsMemVar("lAltValPosEmb") .And. !lAltValPosEmb
            aAdd(aBloq, "EE9_PRECO")
         EndIf
         aAdd(aBloq, "EE9_SLDINI")
         aAdd(aBloq, "EE9_FORN")
         aAdd(aBloq, "EE9_FOLOJA")
         aAdd(aBloq, "EE9_FABR")
         aAdd(aBloq, "EE9_FALOJA")
         aAdd(aBloq, "EE9_PART_N")
         aAdd(aBloq, "EE9_EMBAL1")
         aAdd(aBloq, "EE9_QE")
         aAdd(aBloq, "EE9_PSLQUN")
         aAdd(aBloq, "EE9_PSBRUN")
         aAdd(aBloq, "EE9_UNIDAD")
         aAdd(aBloq, "EE9_FPCOD")
         aAdd(aBloq, "EE9_GPCOD")
         aAdd(aBloq, "EE9_DPCOD")
         aAdd(aBloq, "EE9_POSIPI")
         aAdd(aBloq, "EE9_TIPCOM")
//ASK 14/06/07 - Campos bloqueados quando Data de embaque estiver preenchida.
      EndIf

      ////////////////////////////////////////////////////////////////////////////
      //ER - 04/09/2009.                                                        //
      //Bloqueio de campos, para itens que já possuem ato concessório vinculado.//
      ////////////////////////////////////////////////////////////////////////////
      If lIntDraw .and. lOkEE9_ATO .and. !Empty(M->EE9_ATOCON)
         aAdd(aBloq, "EE9_PRECO")
         aAdd(aBloq, "EE9_SLDINI")
         aAdd(aBloq, "EE9_FORN")
         aAdd(aBloq, "EE9_FOLOJA")
         aAdd(aBloq, "EE9_FABR")
         aAdd(aBloq, "EE9_FALOJA")
         aAdd(aBloq, "EE9_PART_N")
         aAdd(aBloq, "EE9_EMBAL1")
         aAdd(aBloq, "EE9_QE")
         aAdd(aBloq, "EE9_PSLQUN")
         aAdd(aBloq, "EE9_PSBRUN")
         aAdd(aBloq, "EE9_UNIDAD")
         aAdd(aBloq, "EE9_FPCOD")
         aAdd(aBloq, "EE9_GPCOD")
         aAdd(aBloq, "EE9_DPCOD")
         aAdd(aBloq, "EE9_POSIPI")
         aAdd(aBloq, "EE9_TIPCOM")
      EndIf

   // TDF-16/03/2011
      If lIntegra
         If EE9->(FieldPos("EE9_TES")) <> 0 .and.  EE9->(FieldPos("EE9_CF")) <> 0
            aAdd(aBloq,"EE9_TES")
            aAdd(aBloq,"EE9_CF")
         EndIf
      EndIf

      If EasyEntryPoint("EECAE100")
         ExecBlock("EECAE100",.F.,.F.,{"BLOQIT_CAMPOS"})
      Endif

      If lArray
         i := 1
         While i <= Len(aBloq)
            If AScan(aCposDifAtu,aBloq[i]) > 0
               ADel(aBloq,i)
               ASize(aBloq,Len(aBloq)-1)
            Else
               i++
            EndIf
         EndDo
         xRet := aBloq
      Else
         xRet := (AScan(aBloq,cVar) = 0)
      EndIf

   End Sequence

Return xRet

/*
Função      : Ae100VldSel
Objetivos   : Validar se o item pode ser selecionado
Parâmetros  : filial que está sendo validada
Retorno     : .t./.f.
Autor       : João Pedro Macimiano Trabbold
Data e Hora : 26/10/05 - 11:13
*/
*--------------------------*
Function Ae100VldSel(cAlias)
*--------------------------*
   Local lRet := .t.
   Local cFil := If(Type("lGdFilAtu") = "L",If(lGDFilAtu,cFilAtu,cFilOpos),cFilAtu)
   Local aAux

   Default cAlias := "M"

   If cAlias = "WorkOpos"
      cFil := cFilOpos
   EndIf

   Begin Sequence

      If &(cAlias+"->EE9_PRECO") = 0
         If !lIntermed .Or. (lIntermed .And. cFil == cFilBr)
            lRet := .f.

            If EasyEntryPoint("EECAE100")
               uRet := ExecBlock("EECAE100",.F.,.F.,{"VLDSEL_PRCFIX",lRet})
               If ValType(uRet) == "L"
                  lRet := uRet
               EndIf
            EndIf

            If !lRet
               If !lAutom
                  EasyHelp(STR0106+ENTER+; //"Item sem definição de preço, selecione para o embarque "
                          STR0107,STR0035)   //"apenas item(ns) com preço(s) definido(s)."###"Atenção"
               Else
                  If cFil = cFilAtu
                     cItens+= IncSpace(&(cAlias+"->EE9_COD_I"),AVSX3("EE9_COD_I",AV_TAMANHO),.f.)+Space(2)+&(cAlias+"->EE9_PEDIDO")+ENTER
                  EndIf
               EndIf
               Break
            EndIf
         EndIf
      EndIf

   End Sequence

   If !lRet .And. Type("aSelAtu") = "A"// se não conseguiu selecionar, adiciona no array para tratamentos entre filiais Brasil e Off-Shore
      aAux := If(cFil = cFilAtu,aSelAtu,aSelOpos)
      AAdd(aAux,AClone(&(cAlias+"->({Ap104SeqIt(),EE9_SLDINI+WP_SLDATU})" )))
   EndIf

   If lRet .And. cAlias == "WorkOpos" .And. !lSelNotFat .And. Empty(WorkOpos->EE9_NF)
      lRet := .F.
   EndIf

Return lRet

/*
    Funcao   : AE100CAMBIO()
    Autor    : Heder M Oliveira
    Data     : 02/08/99 11:20
    Revisao  : 02/08/99 11:20
    Uso      : Manutencao campos de cambio
    Recebe   :
    Retorna  :
    Obs      : Função Substituída pela rotina de Câmbio. (EECAF200).
    Data     : 05/01/04 - 16:46.
*/
/*
FUNCTION AE100CAMBIO(cALIAS,nREG,nOPC,lManutCambio)
   Local lRET:=.T.,oDLG,nOpc1:=0
   Local aPos, nTamCol,nOUTROS

   Local nFobValue, nComis, nTotLiq, nFrete
   Local nFobValueRS, nComisRS, nTotLiqRS, nFreteRS, nSegRS, nTotalRS, nOutrosRS

   Private aTELA[0][0],aGets[0],nUsado:=0

   Default lManutCambio := .f.

   Begin Sequence
      M->EEC_CBBCNO := BUSCAINST(M->EEC_PREEMB,OC_EM,BC_COC)
      M->EEC_CBCRNO := BUSCAEMPRESA(M->EEC_PREEMB,OC_EM,CD_COC)
      IF TYPE("cAF110BANC") # "UI" .AND. TYPE("cAF110BANC") # "U"
         M->EEC_CBBANC := cAF110BANC
         M->EEC_CBAGEN := cAF110AGEN
         M->EEC_CBNCON := cAF110CONT
         M->EEC_CBBCNO := cAF110NOBC
      ELSEIF !EMPTY(M->EEC_CBBCNO)
             M->EEC_CBBANC := EEJ->EEJ_CODIGO
             M->EEC_CBAGEN := EEJ->EEJ_AGENCI
             M->EEC_CBNCON := EEJ->EEJ_NUMCON
      ELSE
         M->EEC_CBBANC := SPACE(AVSX3("EEJ_CODIGO",AV_TAMANHO))
         M->EEC_CBAGEN := SPACE(AVSX3("EEJ_AGENCI",AV_TAMANHO))
         M->EEC_CBNCON := SPACE(AVSX3("EEJ_NUMCON",AV_TAMANHO))
         M->EEC_CBBCNO := SPACE(AVSX3("EEJ_NOME",AV_TAMANHO))
      ENDIF
      IF TYPE("cAF110CORR") # "UI" .AND. TYPE("cAF110CORR") # "U"
         M->EEC_CBCORR := cAF110CORR
         M->EEC_CBCRNO := cAF110NOCO
      ELSEIF ! EMPTY(M->EEC_CBCRNO)
             M->EEC_CBCORR := EEB->EEB_CODAGE
      ELSE
         M->EEC_CBCORR := SPACE(AVSX3("EEB_CODAGE",AV_TAMANHO))
         M->EEC_CBCRNO := SPACE(AVSX3("EEB_NOME",AV_TAMANHO))
      ENDIF

      DEFINE MSDIALOG oDlg TITLE STR0047+M->EEC_PREEMB FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Câmbio do Embarque "

         aPos := PosDlg(oDlg)

         IF lManutCambio
            aPos[3] -= 37+34 // Rodape
         Endif

         EnChoice( cAlias, nReg, nOpc, , , ,aITEMCAMBIO,aPos)

         IF lManutCambio
            aPos[1] := aPos[3]
            aPos[3] := aPos[1]+37

            nTamCol := (aPos[4]-aPos[2])/6

            // *** Rodape com os Totais ...
            @ aPos[1],aPos[2] TO aPos[3],aPos[4] PIXEL

            // Na Moeda do Processo
            @ aPos[1]+06,aPos[2]+1 SAY STR0048+M->EEC_MOEDA PIXEL SIZE 50,7 //"Total Incoterm "
            @ aPos[1]+15,aPos[2]+1 SAY STR0049+M->EEC_MOEDA PIXEL SIZE 50,7 //"Total FOB "
            @ aPos[1]+24,aPos[2]+1 SAY STR0050+M->EEC_MOEDA PIXEL SIZE 50,7 //"Total Liquido "

            nFobValue := (M->EEC_TOTPED+M->EEC_DESCON)-(M->EEC_FRPREV+M->EEC_FRPCOM+M->EEC_SEGPRE+M->EEC_DESPIN+AvGetCpo("M->EEC_DESP1")+AvGetCpo("M->EEC_DESP2"))
            nComis    := If(EEC->EEC_TIPCVL == "1",((M->EEC_TOTPED*M->EEC_VALCOM)/100),M->EEC_VALCOM)
			nTotLiq   := M->EEC_TOTPED-nCOMIS

            @ aPos[1]+06,(aPos[2]+1)+nTamCol MSGET M->EEC_TOTPED WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_TOTPED",AV_PICTURE)
            @ aPos[1]+15,(aPos[2]+1)+nTamCol MSGET nFobValue     WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_TOTPED",AV_PICTURE)
            @ aPos[1]+24,(aPos[2]+1)+nTamCol MSGET nTotLiq       WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_TOTPED",AV_PICTURE)

            @ aPos[1]+06,(aPos[2]+1)+2*nTamCol SAY STR0051  PIXEL SIZE 50,7 //"Frete"
            @ aPos[1]+15,(aPos[2]+1)+2*nTamCol SAY STR0052 PIXEL SIZE 50,7 //"Seguro"

            nFrete := M->EEC_FRPREV+M->EEC_FRPCOM
            @ aPos[1]+06,(aPos[2]+1)+3*nTamCol MSGET nFrete        WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_FRPREV",AV_PICTURE)
            @ aPos[1]+15,(aPos[2]+1)+3*nTamCol MSGET M->EEC_SEGPRE WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_SEGPRE",AV_PICTURE)

            @ aPos[1]+06,(aPos[2]+1)+4*nTamCol SAY STR0053   PIXEL SIZE 50,7 //"Outros"
            @ aPos[1]+15,(aPos[2]+1)+4*nTamCol SAY STR0054 PIXEL SIZE 50,7 //"Comissao"

            nOUTROS := M->EEC_DESPIN+AvGetCpo("M->EEC_DESP1")+AvGetCpo("M->EEC_DESP2")
            @ aPos[1]+06,(aPos[2]+1)+5*nTamCol MSGET nOUTROS WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_DESPIN",AV_PICTURE)
            @ aPos[1]+15,(aPos[2]+1)+5*nTamCol MSGET nComis WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_VALCOM",AV_PICTURE)

            // Em Reais
            aPos[1] := aPos[3]
            aPos[3] := aPos[1]+34

            @ aPos[1]+06,aPos[2]+1 SAY STR0055 PIXEL SIZE 50,7 //"Total Incoterm R$"
            @ aPos[1]+15,aPos[2]+1 SAY STR0056 PIXEL SIZE 50,7 //"Total FOB R$"
            @ aPos[1]+24,aPos[2]+1 SAY STR0057 PIXEL SIZE 50,7 //"Total Liquido R$"

            nFobValueRS := nFobValue*M->EEC_CBTX
            nComisRS    := nComis*M->EEC_CBTX
			nTotLiqRS   := nTotLiq*M->EEC_CBTX
            nTotalRS    := M->EEC_TOTPED*M->EEC_CBTX

            @ aPos[1]+06,(aPos[2]+1)+nTamCol MSGET nTotalRS       WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_TOTPED",AV_PICTURE)
            @ aPos[1]+15,(aPos[2]+1)+nTamCol MSGET nFobValueRS    WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_TOTPED",AV_PICTURE)
            @ aPos[1]+24,(aPos[2]+1)+nTamCol MSGET nTotLiqRS      WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_TOTPED",AV_PICTURE)

            @ aPos[1]+06,(aPos[2]+1)+2*nTamCol SAY STR0051  PIXEL SIZE 50,7 //"Frete"
            @ aPos[1]+15,(aPos[2]+1)+2*nTamCol SAY STR0052 PIXEL SIZE 50,7 //"Seguro"

            nFreteRS := nFrete*M->EEC_CBTX
            nSegRS   := M->EEC_SEGPRE*M->EEC_CBTX

            @ aPos[1]+06,(aPos[2]+1)+3*nTamCol MSGET nFreteRS  WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_FRPREV",AV_PICTURE)
            @ aPos[1]+15,(aPos[2]+1)+3*nTamCol MSGET nSegRS    WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_SEGPRE",AV_PICTURE)

            @ aPos[1]+06,(aPos[2]+1)+4*nTamCol SAY STR0053   PIXEL SIZE 50,7 //"Outros"
            @ aPos[1]+15,(aPos[2]+1)+4*nTamCol SAY STR0054 PIXEL SIZE 50,7 //"Comissao"

            nOutrosRS := (M->EEC_DESPIN+AvGetCpo("M->EEC_DESP1")+AvGetCpo("M->EEC_DESP2"))*M->EEC_CBTX

            @ aPos[1]+06,(aPos[2]+1)+5*nTamCol MSGET nOutrosRS WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_DESPIN",AV_PICTURE)
            @ aPos[1]+15,(aPos[2]+1)+5*nTamCol MSGET nComisRS  WHEN .F. SIZE 50,6 RIGHT PIXEL PICTURE AVSX3("EEC_VALCOM",AV_PICTURE)
         Endif

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc1:=1,IF(Obrigatorio(aGets,aTela),oDlg:End(),nOpc1:=0)},{||oDlg:End()}))

      IF nOpc1 == 1
         IF EasyEntryPoint("EECPFN02")
            ExecBlock("EECPFN02",.F.,.F.)
         Endif
      Endif

   END Sequence

RETURN lRET
*/

/*
    Funcao   : AE100REGDOC(cALIAS,nREG,nOPC)
    Autor    : Heder M Oliveira
    Data     : 04/08/99 18:06
    Revisao  :
    Uso      : Manutencao campos de registro de documentos
    Recebe   :
    Retorna  :

*/
FUNCTION AE100REGDOC(cALIAS,nREG,nOPC)

IF EMPTY(M->EEC_NRINVO)
   M->EEC_NRINVO:=M->EEC_PREEMB
Endif

lRET:=AE101DetEEM(cALIAS,nREG,nOPC,STR0058+M->EEC_PREEMB,; //"Registro dos Documentos do Embarque "
                  aITEMREGDOC,EEM_IN)

//   Nopado por AWR Sexta Feira 13/08/1999

*  LOCAL lRET:=.T.,oDLG,nOpc1:=0
*  Private aTela[0][0],aGets[0],nUsado:=0
*  Begin Sequence
*     DEFINE MSDIALOG oDlg TITLE STR0058+M->EEC_PREEMB FROM 9,0 TO 28,80 OF oMAINWND //"Registro dos Documentos do Embarque "
*        EnChoice( cAlias, nReg, nOpc, , , ,aITEMREGDOC,{ 15, 1, 140, 315})
*     ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc1:=1,IF(Obrigatorio(aGets,aTela),oDlg:End(),nOpc1:=0)},{||oDlg:End()}))
*  END Sequence

RETURN lRET

/*
    Funcao   : AE100TRANSITO(cALIAS,nREG,nOPC)
    Autor    : Heder M Oliveira
    Data     : 04/08/99 20:04
    Revisao  :
    Uso      : Manutencao campos de transito
    Recebe   :
    Retorna  :

*/
FUNCTION AE100TRANSITO(cALIAS,nREG,nOPC)
   LOCAL lRET:=.T.,oDLG,nOpc1:=0
   Private aTela[0][0],aGets[0],nUsado:=0

   Begin Sequence

      DEFINE MSDIALOG oDlg TITLE STR0059+M->EEC_PREEMB FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Trânsito do Embarque "

         EnChoice( cAlias, nReg, nOpc, , , ,aITEMTRANSITO,PosDlg(oDlg))

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc1:=1,IF(Obrigatorio(aGets,aTela),oDlg:End(),nOpc1:=0)},{||oDlg:End()}))

   END Sequence
RETURN lRET

/*
    Funcao   : AE100FATURA(cALIAS,nREG,nOPC)
    Autor    : Heder M Oliveira
    Data     : 04/08/99 20:04
    Revisao  :
    Uso      : Manutencao campos de faturamento
    Recebe   :
    Retorna  :
*/

FUNCTION AE100FATURA(cALIAS,nREG,nOPC)

IF !AVFLAGS("EEC_LOGIX")
   lRET:=AE101DetEEM(cALIAS,nREG,nOPC,STR0060+M->EEC_PREEMB,; //"Faturamento do Embarque "
                  aITEMFATURA,EEM_NF)

//   Nopado por AWR Sexta Feira 13/08/1999

*  LOCAL lRET:=.T.,oDLG,nOpc1:=0
*  Private aTela[0][0],aGets[0],nUsado:=0
*  Begin Sequence
*     DEFINE MSDIALOG oDlg TITLE STR0060+M->EEC_PREEMB FROM 9,0 TO 28,80 OF oMAINWND //"Faturamento do Embarque "
*        EnChoice( cAlias, nReg, nOpc, , , ,aITEMFATURA,{ 15, 1, 70, 315})
*     ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc1:=1,IF(Obrigatorio(aGets,aTela),oDlg:End(),nOpc1:=0)},{||oDlg:End()}))
*  END Sequence
ELSE
   EasyHelp(STR0266) //NCF - 02/06/2016 //'Ambiente integrado a ERP Externo! Verifique o faturamento na rotina "Notas Fiscais de Saída" no menu! '
   lRET := .F.
ENDIF

RETURN lRET


/*
Funcao      : AE100DetTela
Parametros  : lTela:= .T. desenha tela
                      .F. refresh gets
Retorno     : .T.
Objetivos   : Apresentar detalhe com totais
Autor       : Cristiano A. Ferreira
Data/Hora   : 28/07/99 11:43
Revisao     : HEDER M OLIVEIRA 06/08/99
Obs.        :
*/
Function AE100DetTela(lTela,aPos,nTipo,oPanel)

   Local lRet := .T.
   Local cUm_Peso := "Kg"
   Local nPrcTot
   Local nTotPed
   Private oRodape
   Private nL1,nL2,nTamCol,C1,nC2,nC3,nC4

   Begin Sequence

      IF M->EE9_PRCINC == 0
         //AAF 22/12/2015 - Chama a precoi para calcular o valor fob quando o incoterm é CIF, CFR, etc...            //                   onde se informa o RE.
	     cFlag := WorkIP->WP_FLAG
	     nSLD  := WorkIp->EE9_SLDINI
        nPrcTot:= WorkIP->EE9_PRCTOT
        nTotPed:= M->EEC_TOTPED
	     WorkIP->WP_FLAG := cMarca
	     WorkIP->EE9_SLDINI := M->EE9_SLDINI
        //MFR 09/06/2021 OSSME-5869
        //Valor sendo calculado corretamente na função AE100CALC
		  Ae100PrecoI(.t., .f.) // como não vamos mais usar as variáveis nPRCTOI e nPRECOInc entendo qeu nao precisa mais chamar esta funcao


		   WorkIP->WP_FLAG := cFlag
         WorkIP->EE9_SLDINI := nSld
         WorkIP->EE9_PRCINC := 0
         WorkIP->EE9_PRCTOT := nPrcTot
         M->EEC_TOTPED := nTotPed
      EndIF

      IF ! GetNewPar("MV_AVG0009",.F.)
         lLibPes := SB1->(FieldPos("B1_REPOSIC")) > 0 .And. Posicione("SB1",1,cFilSB1Aux+M->EE9_COD_I,"B1_REPOSIC") $ cSim
      Endif

      If lConvUnid
         EE2->(dbSetOrder(1))
         IF EE2->(dbSeek(xFilial()+MC_TUNM+TM_GER+M->EEC_IDIOMA+M->EE9_UNPES)) .And.;
              !Empty(EE2->EE2_DESCMA)

            cUm_Peso := AllTrim(EE2->EE2_DESCMA)
         Elseif !Empty(M->EE9_UNPES)
            cUm_Peso := M->EE9_UNPES
         EndIf
      Else
         // *** CAF 17/04/2001 Unidade de Medida do Peso ...
         IF Type("M->EEC_UNIDAD") <> "U"
            EE2->(dbSetOrder(1))
            IF EE2->(dbSeek(xFilial()+MC_TUNM+TM_GER+M->EEC_IDIOMA+M->EEC_UNIDAD))
               IF !Empty(EE2->EE2_DESCMA)
                  cUm_Peso := AllTrim(EE2->EE2_DESCMA)
               Elseif !Empty(M->EEC_UNIDAD)
                  cUm_Peso := M->EEC_UNIDAD
               Endif
            Endif
         Endif
      EndIf

      If EasyEntryPoint("EECAE100")  //Ponto de entrada para digitação manual de pesos
         ExecBlock("EECAE100", .F., .F.,"DIG_PESOS")
      Endif

      IF lTela
         nL1:= 4//aPos[1]+6 /* 126 */
         nL2:= nL1+9 /* 135*/

         nTamCol := (aPos[4]-aPos[2])/4

         nC1:=aPos[2]+1 /* 02 */
         nC2:=nC1+nTamCol /* 50 */
         nC3:=nC2+nTamCol /* 120 */
         nC4:=nC3+nTamCol /* 162 */

         //@ 120,01 TO 143,310 PIXEL
         @ aPos[1],aPos[2] TO aPos[3],aPos[4] PIXEL OF oPanel//oRodape

         //ER - 31/05/2007
         If EasyEntryPoint("EECAP100")
            ExecBlock("EECAP100",.F.,.F.,{"ROD_ITENS_EMB",aPos})
         EndIf

         @ nL1,nC1 SAY STR0049+M->EEC_MOEDA PIXEL SIZE 50,7 OF oPanel//oRodape//"Total FOB "
         @ nL1,nC3 SAY oSayPLiqIt VAR STR0037+cUm_Peso PIXEL SIZE 50,7 OF oPanel//oRodape//"Peso Liquido "
         @ nL2,nC1 SAY STR0048+M->EEC_MOEDA PIXEL SIZE 50,7 OF oPanel//oRodape//"Total Incoterm "
         @ nL2,nC3 SAY oSayPBruIt VAR STR0039+cUm_Peso PIXEL SIZE 50,7 OF oPanel//oRodape//"Peso Bruto "
         //MFR 06/02/2021 @ nL1,nC2 MSGET oGetPrecoI VAR nPRCTOI       PICTURE EECPreco("EE9_PRCINC", AV_PICTURE) WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel//oRodape      
         @ nL1,nC2 MSGET oGetPrecoI VAR M->EE9_PRCINC       PICTURE EECPreco("EE9_PRCINC", AV_PICTURE) WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel//oRodape                  
         @ nL1,nC4 MSGET oGetPsLiq  VAR M->EE9_PSLQTO PICTURE AVSX3("EE9_PSLQTO",6) WHEN (nTipo == ALT_DET .Or. nTipo == INC_DET) .And. lLibPes SIZE 65,6 RIGHT PIXEL VALID (Positivo() .And. AllwaysTrue(AvExecGat("EE9_PSLQTO"))) OF oPanel//oRodape
         //MFR 06/02/2021  @ nL2,nC2 MSGET oGetPreco  VAR nPRCINC       PICTURE EECPreco("EE9_PRCTOT", AV_PICTURE) WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel//oRodape
         @ nL2,nC2 MSGET oGetPreco  VAR M->EE9_PRCTOT       PICTURE EECPreco("EE9_PRCTOT", AV_PICTURE) WHEN .F. SIZE 65,6 RIGHT PIXEL OF oPanel//oRodape
         @ nL2,nC4 MSGET oGetPsBru  VAR M->EE9_PSBRTO PICTURE AVSX3("EE9_PSBRTO",6) WHEN (nTipo == ALT_DET .Or. nTipo == INC_DET) .And. lLibPes SIZE 65,6 RIGHT PIXEL VALID (Positivo() .And. AllwaysTrue(AvExecGat("EE9_PSBRTO"))) OF oPanel//oRodape

      Else
        If Type("oSayPLiqIt") == "O"
            oSayPLiqIt:SetText(STR0037+cUm_Peso)
            oSayPBruIt:SetText(STR0039+cUm_Peso)
            oSayPLiqIt:Refresh()
            oSayPBruIt:Refresh()
        Endif
        If Type("oGetPrecoI") == "O"
            oGetPrecoI:Refresh()
            oGetPsLiq:Refresh()
            oGetPreco:Refresh()
            oGetPsBru:Refresh()
        Endif

      Endif
   End Sequence

Return lRet

/*
Funcao      : AE100VALDET(nTipo,nRecno,aP_ALTERA)
Parametros  : nTipo
              nRecno:= n.registro.
              aP_ALTERA := CAMPOS QUE PODEM SER ALTERADOS NA ENCHOICE
Retorno     : .T. / .F.
Objetivos   : validar/aceitar exclusao
Autor       : Heder M Oliveira
Data/Hora   : 25/11/98 11:51
Revisao     :
Obs.        :
*/
Function AE100VALDET(nTipo,nRecno,aP_ALTERA,oDLG)

Local lRet:=.T.,cOldArea:=select(), j, i
Local aOrd := SaveOrd({"EE8","EE9"})
Local nEmbarcado := 0
Local lRestaurou := .t.
Private lRetorno := .t.  // By JPP - 10/05/05 09:50

Begin Sequence

   If nTipo == INC_DET .OR. nTipo = ALT_DET

      // JPM - validações específicas para controle de qtdes entre Brasil e Off-Shore
      lGDFilAtu := .T.
      If lConsolida
         Ae104AuxIt(7) // recalcula totais.
         If !Ae104AuxIt(4)
            lRet := .f.
            Break
         EndIf
      EndIf
      For i := 1 To If(lConsolida,Len(aColsAtu),1)

         If lConsolida
            Ae104AuxIt(2,,.f.,i,,) // simula variáveis de memória de acordo com o aCols da GetDados
            lRestaurou := .f.
         EndIf

         If !lConsolida .Or. !Empty(M->WP_FLAG)

            If EECFlags("COMISSAO")

               // JPM - 03/08/05 - validação da Carta de Crédito
               If EECFlags("ITENS_LC")
                  If !Ae107VldProd(OC_EM)
                     lRet := .f.
                     Break
                  EndIf
               EndIf

               // JPM - 31/05/05 - Campo novo: tipo de comissão no item
               If EE9->(FieldPos("EE9_TIPCOM")) > 0 .And. !Empty(M->EE9_CODAGE) .And. Empty(M->EE9_TIPCOM)
                  EasyHelp(STR0149 + "'" + AllTrim(AvSx3("EE9_TIPCOM",AV_TITULO)) + "'",STR0063)//"Preencha o campo " ## "Aviso"
                  lRet := .f.
                  Break
               EndIf
            EndIf

            IF SB1->(FieldPos("B1_REPOSIC")) > 0
               IF Posicione("SB1",1,cFilSB1Aux+   m->EE9_COD_I,"B1_REPOSIC") $cSim
                  lAltQtd := !EMPTY(m->EE9_SLDINI)
                  lAltFor := !EMPTY(m->EE9_FORN)
                  lAltLoj := !EMPTY(m->EE9_FOLOJA)
                  lAltEmb := !EMPTY(m->EE9_EMBAL1)
                  lAltQE  := !EMPTY(m->EE9_QE)
                  lAltQem := !EMPTY(m->EE9_QTDEM1)
                  lAltNcm := !EMPTY(m->EE9_POSIPI)
                  HELP(" ",1,"AVG0000629") //("Este é um produto para reposição, os valores serão zerados","Aviso")
                  m->EE9_SLDINI := IF(laltQtd,m->EE9_SLDINI,1)
                  m->EE9_FORN   := IF(laltFor,m->EE9_FORN,".")
                  m->EE9_FOLOJA := IF(laltLoj,m->EE9_FOLOJA,".")
                  m->EE9_EMBAL1 := IF(laltEmb,m->EE9_EMBAL1,".")
                  m->EE9_QE     := IF(laltQE,m->EE9_QE,1)
                  m->EE9_QTDEM1 := IF(laltQem,m->EE9_QTDEM1,1)
                  m->EE9_POSIPI := IF(laltNcm,m->EE9_POSIPI,".")
                  m->EE9_PSLQUN := 1
                  m->EE9_PSBRUN := 1
                  m->EE9_PRECO  := 1
                  m->EE9_PRECOI := 1
                  m->EE9_PRCTOT := 1
                  m->EE9_PRCINC := 1
               ENDIF
            ENDIF

            If EECFlags("INVOICE") //By OMJ - 22/06/2005 15:35 - Tratamento de Invoice
               If !Ae108AltItem("EE9_SLDINI",If(Empty(WorkIP->WP_FLAG) ,;
                                                IF(EMPTY(WorkIP->WP_OLDINI),WorkIP->WP_SLDATU,WorkIP->WP_OLDINI) ,;
                                                WorkIP->EE9_SLDINI) ,;
                                                M->EE9_SLDINI)
                  lRet := .F.
                  Break
               EndIf
            EndIf

            If lCommodity .And. lIntermed .And.;
                                (xFilial("EEC") == cFilEx) //AvKey(EasyGParam("MV_AVG0024"),"EEC_FILIAL"))

               // ** Caso o item tenha fixação de preço na fase de pedido, o sistema não permite o embarque sem preço.
               If Empty(M->EE9_PRECO)
                  If !Empty(WorkIp->EE9_PRECO)
                     EasyHelp(STR0131+ENTER+; //"Este item possue fixação de preço na fase de pedido, o preço "
                             STR0132,STR0035) //"deve ser informado."###"Atenção"
                     lRet:=.f.
                     Break
                  EndIf
               EndIf

               nTmpPreco := M->EE9_PRECO
               M->EE9_PRECO := 1
               lRet:=Obrigatorio(aGets,aTela)
               M->EE9_PRECO:=nTmpPreco
            Else
               lRet:=Obrigatorio(aGets,aTela)
            EndIf
            If !lRet
               Break
            EndIf

            IF SB1->(FieldPos("B1_REPOSIC")) > 0
               IF Posicione("SB1",1,cFilSB1Aux+m->EE9_COD_I,"B1_REPOSIC") $cSim
                  m->EE9_SLDINI := IF(laltQtd,m->EE9_SLDINI,0)
                  m->EE9_FORN   := IF(laltFor,m->EE9_FORN,"")
                  m->EE9_FOLOJA := IF(laltLoj,m->EE9_FOLOJA,"")
                  m->EE9_EMBAL1 := IF(laltEmb,m->EE9_EMBAL1,"")
                  m->EE9_QE     := IF(laltQE,m->EE9_QE,0)
                  m->EE9_QTDEM1 := IF(laltQem,m->EE9_QTDEM1,0)
                  m->EE9_POSIPI := IF(laltNcm,m->EE9_POSIPI,"")
                  m->EE9_PSLQUN := 0
                  m->EE9_PSBRUN := 0
                  m->EE9_PRECO  := 0
                  m->EE9_PRECOI := 0
                  m->EE9_PRCTOT := 0
                  m->EE9_PRCINC := 0
               ENDIF
            ENDIF

         EndIf

         EE8->(dbSetOrder(1))
         EE8->(DBSeek(XFILIAL()+WORKIP->(EE9_PEDIDO+EE9_SEQUEN+EE9_COD_I)))
         EE9->(dbSetOrder(3))
         IF EE9->(dbSeek(xFilial()+WorkIP->EE9_PREEMB+WorkIP->EE9_SEQEMB))
            nEmbarcado := EE9->EE9_SLDINI
         Endif

         If !lConsolida
            If (nSelecao == ALTERAR .and. !Empty(EEC->EEC_DTEMBA) .Or.;
               (lIntermed .And. nSelecao == ALTERAR .And. cFilEx == AvGetM0Fil()))

               M->WP_SLDATU := (EE8->EE8_SLDATU+nEmbarcado)-M->EE9_SLDINI
            Else
               IF Empty(WorkIP->WP_FLAG) // Esta marcando ...
                  M->WP_SLDATU := (EE8->EE8_SLDATU+nEmbarcado)-M->EE9_SLDINI
               Else
                  //M->WP_SLDATU := (EE8->EE8_SLDATU+nEmbarcado)
                  M->WP_SLDATU := EE8->EE8_SLDATU+(WorkIp->EE9_SLDINI-M->EE9_SLDINI)
               Endif
            EndIf
         EndIf

         // ** AAF 27/09/04 - Valida o Item para Back to Back
         If lBACKTO .AND. lRet .AND. !Empty(M->EE9_INVPAG)
            lRet := AP106Valid("EE9_VLPAG")
         Endif
         // **

         If !EECFlags("COMMODITY") .Or. Empty(M->EE9_RV) // JPM - 10/01/06 - se tiver r.v. não liquida saldo.
            If ((lIntegra .Or. AvFlags("EEC_LOGIX")) .And. !Empty(M->EE9_NF)) .And. !lOldConsol
               IF (lIntDraw .and. VerACParcial()) .or. ((lIntegra .Or. AvFlags("EEC_LOGIX")) .And. !Empty(M->EE9_NF)) .OR.;
                  (!lMsgZeraSaldo .And. M->WP_SLDATU > 0 .AND. MSGNOYES(STR0041   +WORKIP->EE9_PEDIDO+CRLF+; //"Pedido: " // ** By JPP - 14/03/2007 - lMsgZeraSaldo - Desabilita/Habilita mensagem(opção) para eliminar saldo de pedidos embarcados parcialmente.
                                                  STR0042+WORKIP->EE9_SEQUEN+CRLF+; //"Sequencia: "
                                                  STR0043     +WORKIP->EE9_COD_I+CRLF+; //"Item: "
                                                  STR0044    +TRANSFORM(M->WP_SLDATU,AVSX3("EE8_SLDATU",AV_PICTURE))+CRLF+; //"Saldo: "
                                                  STR0045,STR0046)) //"Deseja Liquidar o Saldo ?"###"Embarque Parcial"

                  If lConsolOffShore //JPM - 07/11/05 - também liquida saldo da outra filial
                     For j := 1 To Len(aObjs[3]:aCols)
                        If M->WP_SLDATU >= GdFieldGet("WP_SLDATU", j,, aHeaderOpos, @aObjs[3]:aCols) //M->WP_SLDATU
                           M->WP_SLDATU -= GdFieldGet("WP_SLDATU", j,, aHeaderOpos, @aObjs[3]:aCols)
                           GdFieldPut("WP_SLDATU", 0, j, aHeaderOpos, @aObjs[3]:aCols)
                        Else
                           GdFieldPut("WP_SLDATU", (M->WP_SLDATU - M->WP_SLDATU), j, aHeaderOpos, @aObjs[3]:aCols)
                           M->WP_SLDATU := 0
                        EndIf
                        If M->WP_SLDATU == 0
                           Exit
                        EndIf
                     Next
                     aColsOpos := aClone(aObjs[3]:aCols)
                  EndIf
                  M->WP_SLDATU := 0
               EndIf
            EndIf
         EndIf
         // essa deve ser a última validação.

         If lConsolida
            Ae104AuxIt(3,,.f.,i,.t.,) // restaura variáveis de memória
            lRestaurou := .t.
         EndIf

      Next

      // LCS - 27/09/2002 - INCLUI A CHAMADA DO PONTO DE ENTRADA
      IF (EasyEntryPoint("EECPEM48"))
         EXECBLOCK("EECPEM48",.F.,.F.)
      ENDIF

      //TRP - 14/12/2011 - Padronização do Ponto de Entrada EECAE100.
      If EasyEntryPoint("EECAE100")
         ExecBlock("EECAE100",.F.,.F.,{"VALIDA_ITEM"})
      Endif

      If ! lRetorno     // By JPP - 10/05/05 09:50 - A variável lretorno pode ser alterada pelo ponto de entrada.
         lRet := lRetorno
      EndIf
   Endif

   //DFS - Inclusão de tratamento para que, os dados sejam preenchidos corretamente.
   If (Empty(M->EE9_NRSD) .And. Empty(M->EE9_DTDDE) .And. !Empty(M->EE9_DTAVRB)) .OR. (Empty(M->EE9_NRSD) .And. !Empty(M->EE9_DTDDE))  .Or. (!Empty(M->EE9_NRSD) .And. Empty(M->EE9_DTDDE))
       EasyHelp(STR0234,STR0213) //"Dados incompletos para o S.D. Revise os campos 'Nro S.D.' e 'Data S.D.'."###"Atenção"
       lRet:= .F.
       Break
   EndIf

   // O metodo :End() faz validação dos dados da Enchoice atraves dos valids do SX3, quando existem
   // informações inconsistentes o mesmo não fecha a janela.
   If !lAE100Auto .And. !oDlg:End()
   //IF oDlg:nResult == 2
      // Não fechou a janela
      lRET := .F.
   Endif

   If lRet .And. EECFlags("INTTRA")
      M->EE9_DINT   := Ae110ChgTags(M->EE9_DINT)
      M->EE9_VM_DES := Ae110ChgTags(M->EE9_VM_DES)
   EndIf

End Sequence

If !lRestaurou
   Ae104AuxIt(3,,.f.,i,.t.,) // restaura variáveis de memória
EndIf

RestOrd(aOrd)
dbSelectArea(cOldArea)

Return lRet

/*
Funcao      : AE100Volume
Parametros  : nenhum
Retorno     : nenhum
Objetivos   : Apresentar os volumes do pedido
Autor       : Cristiano A. Ferreira
Data/Hora   : 20/07/99 10:10
Revisao     :
Obs.        :
*/
Static Function AE100Volume(lGravar)

Local nRecIP  := WorkIP->(RecNo())

Local cSequen, i
Local oDlg, oLbx, oMsBtn, oFont

Local aEmb    := {}
Local aLista  := {}

Local aOrd:= SaveOrd("EEK",2) // Salva a Ordem do EEK, e seta a ordem 2
Local nQtde, cEmbalagem, nPenultimo
Local nQtd_Vol, nVolume

Local lITCubagem := EasyGParam("MV_AVG0010", .F., .F., xFilial("EE7"))

Default lGravar := .f.

If ValType(lITCubagem) <> "L"
   lITCubagem := .F.
EndIf

If Type("lSched") == "U"
   lSched:= .F.
EndIf

Begin Sequence
   //JVR - 17/12/09
   If EECFLAGS("INTTRA")
      Break
   EndIf

   If !lITCubagem // AMS - 16/07/2004 às 17:22.

      If !EasyGParam("MV_AVG0008",,.f.) // se .T., permite gravar embarque sem itens.
         While .T.
            WorkIp->(DbGoTop())
            lExit := .f.
            While WorkIp->(!EoF())
               If !Empty(WorkIp->WP_FLAG) // JPM - se achar item marcado, não dá mensagem.
                  lExit := .t.
                  Exit
               EndIf
               WorkIp->(DbSkip())
            EndDo
            If lExit
               Exit
            EndIf
            EECHelp(" ",1,"AVG0000630")
            BREAK
         EndDo
      EndIf


      IF ! Empty(M->EEC_EMBAFI)
         IF M->EEC_CALCEM == "1"
            // Calculo por Volume
            IF Empty(M->EEC_CUBAGE)
               IF ! EE5->(dbSeek(xFilial()+M->EEC_EMBAFI))
                  EECMsg(STR0061+M->EEC_EMBAFI+STR0062,STR0063) //"Volume "###" não foi encotrado no Cadastro de Embalagens !"###"Aviso"
                  Break
               Endif

               IF Empty(EE5->EE5_HALT*EE5->EE5_LLARG*EE5->EE5_CCOM)
                  EECHelp(" ",1,"AVG0000631") //("Cubagem do Volume não foi preenchido !","Aviso")
                  Break
               Endif

               M->EEC_CUBAGE := EE5->EE5_HALT*EE5->EE5_LLARG*EE5->EE5_CCOM
            Endif
         Endif
         //DFS - 06/06/13 - Retirado tratamento que força o calculo ser por quantidade, quando nao houver embalagem preenchida, visto que, o certo é forçar o preenchimento do campo volume
         /*Else
             M->EEC_CALCEM := "2" // Calculo por Qtde.
         */
      Endif

   EndIf


   WorkIP->(dbGoTop())

   While ! WorkIP->(Eof())

      IF Empty(WorkIP->WP_FLAG)
         WorkIP->(dbSkip())
         Loop
      Endif

      cSequen := WorkIP->EE9_SEQEMB

      // *** Posiciona o Work de Embalagens no ultimo item de uma
      // *** determinada sequencia do pedido atual.
      // caf 21/01/2000 11:24 IF WorkEm->(dbSeek(M->EEC_PREEMB+cSequen,,.T.))
      IF WorkEm->(AVSeekLast(M->EEC_PREEMB+cSequen))
         IF M->EEC_CALCEM == "2"
            IF !Empty(M->EEC_EMBAFI)
               // *** Calculo por Quantidade
               IF WorkEm->EEK_EMB != M->EEC_EMBAFI
                  IF lSched .Or. ! EECGetVol(StrZero(Val(WorkEm->EEK_SEQ)+1,2),WorkIP->EE9_COD_I,M->EEC_EMBAFI,WorkEm->EEK_QTDE,M->EEC_PREEMB,WorkIP->EE9_SEQUEN,WorkIP->EE9_EMBAL1,OC_EM)
                     Break
                  Endif
               Endif
            Endif

            nVolume := WorkEm->EEK_QTDE

            WorkEm->(dbSkip(-1))
            IF ! WorkEm->(Bof()) .And. WorkEm->EEK_SEQUEN == cSequen
               cEmbalagem := WorkEm->EEK_EMB
               nQtde      := WorkEm->EEK_QTDE
            Else
               cEmbalagem := WorkIP->EE9_EMBAL1
               nQtde      := WorkIP->EE9_QTDEM1
            Endif

            nVolume := nQtde/nVolume
         ELSE
            // *** Calculo por Volume
            IF WorkEm->EEK_EMB == M->EEC_EMBAFI
               WorkEm->(dbSkip(-1))
            Endif

            IF ! WorkEm->(Bof()) .And. WorkEm->EEK_SEQUEN == cSequen
               cEmbalagem := WorkEm->EEK_EMB
               nQtde      := WorkEm->EEK_QTDE
            Else
               cEmbalagem := WorkIP->EE9_EMBAL1
               nQtde      := WorkIP->EE9_QTDEM1
            ENDIF
         ENDIF
      Else
         // A embalagem digitado no item ja e a embalagem final
         cEmbalagem := WorkIP->EE9_EMBAL1
         nQtde      := WorkIP->EE9_QTDEM1

         IF M->EEC_CALCEM == "2" // Calculo por Quantidade
            IF !Empty(M->EEC_EMBAFI)
               IF lSched .Or. ! EECGetVol(StrZero(Val(WorkEm->EEK_SEQ)+1,2),WorkIP->EE9_COD_I,M->EEC_EMBAFI,WorkEm->EEK_QTDE,M->EEC_PREEMB,WorkIP->EE9_SEQUEN,WorkIP->EE9_EMBAL1,OC_EM)
                  Break
               Endif

               nVolume := nQtde/WorkEm->EEK_QTDE
            Else
               nVolume := WorkIP->EE9_QE
            Endif
         Endif
      Endif

      IF ! EE5->(dbSeek(xFilial()+cEmbalagem))
         EECMsg(STR0064+cEmbalagem+STR0065,STR0035) //"Erro de integridade, embalagem "###" não encontrada no cadastro de embalagens !"###"Atenção"
         WorkIP->(dbSkip())
         Loop
      Endif

      IF M->EEC_CALCEM == "2"
         // Calculo por Quantidade
         nQtd_Vol := nVolume
      Else
         // Calculo por Volume
         nQtd_Vol := EE5->(EE5_HALT*EE5_LLARG*EE5_CCOM)
      Endif

      aAdd(aEmb,{EE5->EE5_CODEMB,AllTrim(EE5->EE5_DESC),nQtde,EE5->EE5_PESO,nQtd_Vol,WorkIP->EE9_SEQEMB,WorkIP->EE9_SLDINI,WorkIP->EE9_COD_I})

      WorkIP->(dbSkip())
   Enddo

   IF Empty(aEmb)
      Break
   Endif

   // *** Gera aLista, baseado em aEmb ...
   EECBuildList(aLista,aEmb,M->EEC_EMBAFI,M->EEC_CALCEM,M->EEC_PREEMB,OC_EM,lGravar,M->EEC_CUBAGE)

   IF lSched .Or. lGravar
      Break
   Endif

   If Len(aLista) > 0

      DEFINE FONT oFont NAME "Courier New" SIZE 0,-12

      DEFINE MSDIALOG oDlg TITLE STR0006 FROM 7,3 TO 20,75 OF oMainWnd //"Volumes"

         @ 0.5,0.6 LISTBOX oLbx ITEMS aLista SIZE 275,70 OF oDlg FONT oFont

         DEFINE SBUTTON oMsBtn FROM 80,253 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg

         // *** Disabilita o Cancel (x) da Dialog ...
         oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
         // ***

         oDlg:bStart := {|| oMsBtn:SetFocus() }

      ACTIVATE MSDIALOG oDlg CENTERED

      WorkIP->(dbGoTo(nRecIP))

      oFont:End()
   EndIf
End Sequence

RestOrd(aOrd) // Restaura ordem dos alias ...

Return NIL

/*
Funcao      : AE100Saldo
Parametros  : cPedido := Nro do Pedido no EE8
              cSequen := Nro da Sequencia pedido
              nSaldo  := Saldo do item
Retorno     : nenhum
Objetivos   : Atualizar saldo do processo
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/08/99 09:41
Revisao     : WFS 08/03/2010 - Revisão dos tratamentos de atualização dos itens da grade.
Obs.        :
*///-----------------------------------------------------------------
FUNCTION AE100Saldo(cPedido,cSequen,nSaldo,lSoma, lElimResFat, cProduto)
Local aOrd := SaveOrd({"EE7","EE8","EE9","SC6"}),;
      lExistEmbarq := .f.


If !EasyGParam("MV_AVG0067",, .F.) .And. lElimResFat
   aOrd := SaveOrd({"EE7","EE8","EE9","SC6"})
Else
   aOrd := SaveOrd({"EE7","EE8","EE9"})
EndIf

Default lSoma := .f.
Default cProduto := ""

Begin Sequence

      If !Empty(cProduto)
         If !AvFlags("GRADE")
            cProduto := ""
         EndIf
      EndIf

      EE9->(dbSetOrder(1))
      EE8->(dbSetOrder(1))
      IF ! EE8->(dbSeek(XFILIAL("EE8")+cPedido+cSequen+cProduto))
         EECMsg(STR0066+CRLF+;                //"Erro de integridade na função AE100Saldo:"
                 STR0067+cPedido+CRLF+;       //"Processo: "
                 STR0068+cSequen+CRLF+CRLF+;  //"Sequência: "
                 STR0069, STR0063, "MsgStop") //"Não encontrado no EE8 !"###"Aviso"
         Break
      Endif
      EE9->(dbSeek(xFilial()+cPedido+cSequen))
      DO While EE9->(!Eof() .And. EE9_FILIAL == xFilial("EE9")) .And. EE9->(EE9_PEDIDO+EE9_SEQUEN) == cPedido+cSequen
         IF EE9->EE9_STATUS <> ST_PC
            lExistEmbarq := .t.
            Exit
         Endif
         EE9->(dbSkip())
      Enddo

      EE8->(RecLock("EE8",.F.))

      /*
      AMS - 07/11/2005. Implementada condição para não executar a função "MARESDOFAT" quando o parametro MV_AVG0067 for .T.
      */
      //RMD - 15/01/08 - Só elimina o resíduo caso o usuário tenha confirmado
      If !EasyGParam("MV_AVG0067",, .F.) .And. lElimResFat
         IF lIntegra .And. lExistEmbarq .And. ! lSoma .And. nSaldo == 0
            EE7->(DBSETORDER(1))
            EE7->(DBSEEK(XFILIAL("EE7")+EE8->EE8_PEDIDO))
            IF EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM
               SC6->(dbSetOrder(1))
               IF SC6->(dbSeek(xFilial()+AvKey(EE7->(POSICIONE("EE7",1,xFilial()+EE8->EE8_PEDIDO,"EE7_PEDFAT")),"C6_NUM")+AvKey(EE8->EE8_FATIT,"C6_ITEM")))
                  MARESDOFAT(SC6->(RecNo()), .F.,.T.)
               Endif
            ENDIF
         ENDIF
      EndIf

      If !IsInCallStack("FAT3GRAVA") //NCF - 29/06/2018 - Não verificar quando o salto já estiver sido atualizado em tempo de execução por inclusão de nota de devolução no Compras
         IF !lExistEmbarq
            EE8->EE8_SLDATU := If(EE8->EE8_SLDINI > 0, EE8->EE8_SLDINI, 0)
         Else
            IF lSoma
               EE8->EE8_SLDATU += nSaldo
            Else
               /* by JBJ - 15/06/04 - Caso o SigaEEC esteja integrado com o SigaFat() o controle de saldo
                                    é realizado com base apenas no campo de quantidade (EE9_SLDINI).
                                    Visando atender as situações de embarques parciais com um único item
                                    em mais de uma nota no SigaFat. */
               If !(lIntegra .Or. AvFlags("EEC_LOGIX")) .Or. Empty(WorkIP->EE9_NF)
                  EE8->EE8_SLDATU := nSaldo
               Else
                  EE8->EE8_SLDATU -= WorkIp->EE9_SLDINI
               EndIf
            Endif
            If EE8->EE8_SLDATU < 0 // nSaLdo < 0
               EE8->EE8_SLDATU := 0
            EndIf
         Endif
      EndIf
      EE8->(MSUnlock())

End Sequence
RestOrd(aOrd,.t.)
Return NIL

/*
Funcao      : AE100GrvEmb
Parametros  : nenhum
Retorno     : NIL
Objetivos   : Grava informacoes do Work de embalagens no EEK
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/08/99 10:30
Revisao     :
Obs.        :
*/
FUNCTION AE100GrvEmb

Begin Sequence

   IF !WorkEm->(dbSeek(M->EEC_PREEMB+EE9->EE9_SEQEMB))
      Break
   Endif

   While ! WorkEm->(Eof()) .And. WorkEm->(EEK_PEDIDO+EEK_SEQUEN) == ;
                                 M->EEC_PREEMB+EE9->EE9_SEQEMB

      EEK->(RecLock("EEK",.T.))

      AVReplace("WorkEm","EEK")

      EEK->EEK_TIPO   := OC_EM
      EEK->EEK_PEDIDO := M->EEC_PREEMB
      EEK->EEK_SEQUEN := EE9->EE9_SEQEMB
      EEK->EEK_FILIAL := xFilial("EEK")  // By JPP - 12/04/2006 - 11:00

      EEK->(MSUNLOCK())

      WorkEm->(dbSkip())
   Enddo

End Sequence

Return NIL


/*
Funcao      : AE100VIEWIT()
Parametros  :
Retorno     : NIL
Objetivos   : Permitir manutencao de outras descricoes da moeda
Autor       : Heder M Oliveira
Data/Hora   : 25/11/98 11:47
Revisao     : Cristiano A.Ferreira
              20/01/2000 15:18
Obs.        :
*/
STATIC Function AE100VIEWIT()

    Local oDlg,nInc,aPos, cOldTit
    Local nSelect := Select()

    Local bOk := {|| nOpc1 := 1, oDlg:End() }
    Local bCancel := {|| oDlg:End() },nOpc1:=0

    Private aTela[0][0],aGets[0]
    Private aItButtons := {}// By JPP 14/11/2007 - 14:00
    Private oEnch //FDR - 26/06/12

    Begin Sequence
       If lItFabric // By JPP 14/11/2007 - 14:00
          aAdd(aItButtons,{"AVG_FABRIC",{|| AE109FabrIt() },STR0191,STR0191}) // "Fabricantes Itens"
       EndIf

      //TRP- 20/02/2009
      If Select("WorkEDG") > 0 .and. !IsVazio("WorkEDG") .and. Type ("lDrawSC") == "L" .and. lDrawSC
         aAdd(aItButtons,{"CTBREPLA",{|| AE100Insumos(oDlg, 1)},STR0228,STR0228}) //STR0228	"Insumos"
      Endif
       For nInc := 1 TO WorkIP->(FCount())
          M->&(WorkIP->(FIELDNAME(nInc))) := WorkIP->(FIELDGET(nInc))
       Next nInc

//     MFR 19/04/2017 TE-5368 WCC-511005, abria a tela em branco como se fosse uma tela de inclusão
       EE9->(dbGoTo(WorkIP->WP_RECNO))



       cOldTit:= cCadastro
       cCadastro:=(STR0040 + AllTrim(M->EE9_PREEMB) + " - " + STR0002) //"Definição de Produtos para o Embarque "

       DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

          aPos := PosDlg(oDlg)
          aPos[3] -= 28 // Rodape

          If lAbriuExp
             //"Definição do Arotina para a Visualização do Drawback"
             Private aRotina:= {{"","",0,0},{"","",0,0},{"","",0,3}}
          Endif

          oEnch := MsMGet():New("EE9", , 2, , , ,aItemEnchoice,aPos,,3,,,,oDlg,,.T.)
          oEnch:oBox:Align := CONTROL_ALIGN_TOP

          aPos[1] := aPos[3]
          aPos[3] := aPos[1]+28

          //FDR - 26/06/12 - Criado oPanel para o rodapé
          oPanel:=	TPanel():New(aPos[1],aPos[2], "", oDlg,, .F., .F.,,, aPos[4], 40,,.T.)
          oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

          AE100DetTela(.T.,aPos,VIS_DET,oPanel)

          oDlg:lMaximized := .T.

       ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aItButtons)

       cCadastro:= cOldTit

    End Sequence

    // Porque a Enchoice muda a area corrente para o EE9, e o double-click
    // na tela anterior nao funcionava.
    Select(nSelect)

Return NIL
/*
    Funcao   : AE100VLPROC()
    Autor    : Heder M Oliveira
    Data     : 23/02/00 14:50
    Revisao  : 23/02/00 14:50
    Uso      : Calcular Valor do Processo com todos os custos
    Recebe   :
    Retorna  : Valor do Processo

*/
FUNCTION AE100VLPROC()
LOCAL nRET:=0
nRET := M->EEC_TOTPED
RETURN(nRET)
*--------------------------------------------------------------------
/*
Funcao      : AE100DelEEM(aNFApaga)
Parametros  : aNFApaga: Tabela com Nota e Serie para delecao
Retorno     : nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 07/06/2000 11:20
Revisao     : Alex Wallauer (AWR) - 30/09/2005
Obs.        :
*/
Static Function AE100DelEEM(aNFApaga)

/*
Local aOrd := SaveOrd("EEM"), cFilEES

Local bExec := {|| EEM->(RecLock("EEM",.F.)),;
                   EEM->(dbDelete()),;
                   EEM->(MsUnlock()) }

Local bFor  := {|| EEM->EEM_TIPONF==EEM_SD .AND. ASCAN(aNFApaga,EEM->EEM_NRNF+EEM->EEC_SERIE) # 0 }

Local bWhile:= {|| EEM->EEM_FILIAL==xFilial("EEM") .And.;
                   EEM->EEM_PREEMB==EEC->EEC_PREEMB .And.;
                   EEM->EEM_TIPOCA==EEM_NF }
*/

/*
AMS - 04/11/2005. Definida variavel lExistEES para tratar utilização da tabela EES quando existir.
*/
Local lExistEES := Select("EES") > 0
Local lExistEK6 := AvFlags("NOTAS_FISCAIS_SAIDA_LOTE_EXPORTACAO") .And. Select("EK6") > 0
Local aOrd, nRec, nRecEEM
Local cChaveEK6

If lExistEES
   aOrd := If(!lExistEK6 , SaveOrd({"EEM","EES"}) , SaveOrd({"EEM","EES","EK6"}))
   EEM->(dbSetOrder(1))
   EES->(dbSetOrder(1))
   If lExistEK6
      EK6->(dbSetOrder(2))
   EndIf
Else
   aOrd := SaveOrd("EEM")
   EEM->(dbSetOrder(1))
EndIf

IF LEN(aNFApaga) = 0 //AWR - 30/09/2005
   RETURN
ENDIF

/*
AMS - 04/11/2005. Correção da rotina de exclusão de NF.
                  Deve-se excluir os registros no EEM(capa) e depois EES(detalhes).
*/
If EEM->(dbSeek(xFilial()+EEC->EEC_PREEMB))

   While EEM->(!Eof() .and. EEM_FILIAL == xFilial() .and. EEM_PREEMB == EEC->EEC_PREEMB)

     If AvFlags("EEC_LOGIX")
        EEM->(dbSkip())
        nRecEEM := EEM->(RecNo())
        EEM->(dbSkip(-1))
	  EndIf

      If aScan(aNFApaga, EEM->(EEM_NRNF+EEM_SERIE+Ap101FilNf())) > 0 // JPM - Ap101FilNf() - 27/12/05 - Geração de Notas Fiscais em Várias Filiais.

         // ** AAF 09/01/08 - Estorna a Nota Fiscal no Contábil
         If lIntCont .AND. !AvFlags("EEC_LOGIX")
            AE100EstCon("ESTORNA_NF")
         EndIf
         // **

         If lExistEES .and. EES->(dbSeek(xFilial()+EEM->EEM_PREEMB))

            While EES->(!Eof() .and. EES_FILIAL == xFilial() .and. EES_PREEMB == EEM->EEM_PREEMB)

               If AvFlags("EEC_LOGIX")
                  EES->(dbSkip())
                  nRec := EES->(RecNo())
                  EES->(dbSkip(-1))
               EndIf

               If aScan(aNFApaga, EES->(EES_NRNF+EES_SERIE+Ap101FilNf())) > 0  // JPM - Ap101FilNf() - 27/12/05 - Geração de Notas Fiscais em Várias Filiais.

                  EES->(RecLock("EES", .F.))
                  If AvFlags("EEC_LOGIX")
                     EES->EES_PREEMB := ""
                     AE102ESSEYY("2")       //NCF - 21/11/2017
                     AE102EESEK6("2")       //NCF - 06/12/2018
                  Else
                     //NCF - 06/12/2018 - Deletar as notas fiscais de formação de lote de exportação associadas.
                     If lExistEK6 .And. EK6->(DbSeek( cChaveEK6 := xfilial("EK6") + EES->( EES_PREEMB + EES_PEDIDO + EES_SEQUEN + EES_NRNF + EES_SERIE + EES_FATSEQ ) ))
                        Do While EK6->(!Eof()) .And. Left(EK6->&(IndexKey()),Len( cChaveEK6 )) == cChaveEK6
                           EK6->(RecLock("EK6", .F.))
                           EK6->(DbDelete())
                           EK6->(MsUnlock())
                           EK6->(DbSkip())
                        EndDo
                     EndIf
                     EES->(dbDelete())
                  EndIf
                  EES->(MsUnlock())
               EndIf

			    If AVFLAGS("EEC_LOGIX")
			       EES->(dbGoTo(nRec))
			    Else
                   EES->(dbSkip())
			    EndIf

            End

         EndIf

         EEM->(RecLock("EEM", .F.))
         If AvFlags("EEC_LOGIX")
            EEM->EEM_PREEMB := ""
         Else
            EEM->(dbDelete())
         EndIf
         EEM->(MsUnlock())

      EndIf

      If AVFLAGS("EEC_LOGIX")
         EEM->(dbGoTo(nRecEEM))
      Else
      EEM->(dbSkip())
      Endif

   End

EndIf

/*
EEM->(dbSetOrder(1)) // FILIAL+PREEMB+TIPOCA+NRNF+TIPONF
EEM->(dbSeek(xFilial()+EEC->EEC_PREEMB+EEM_NF))
EEM->(dbEval(bExec,bFor,bWhile))

If lExistEES
   //AWR - 30/09/2005
   bExec := {|| EES->(RecLock("EES",.F.)),;
                EES->(dbDelete()),;
                EES->(MsUnlock()) }

   bFor  := {|| ASCAN(aNFApaga,EES->EES_NRNF+EES->EES_SERIE) # 0 }

   bWhile:= {|| EES->EES_FILIAL==cFilEES .And.;
                EES->EES_PREEMB==EES->EES_PREEMB }

   cFilEES:=xFilial("EES")

   EES->(dbSetOrder(1))//EES_FILIAL+EES_PREEMB+EES_NRNF
   EES->(dbSeek(cFilEES+EEM->EEM_PREEMB))
   EES->(dbEval(bExec,bFor,bWhile))
   //AWR - 30/09/2005
EndIf
*/

RestOrd(aOrd)

Return NIL

/*
Funcao      : AE100GrvEEM(cPedido,cSequen,cNota,cSerie)
Parametros  :
Retorno     : nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 07/06/2000 11:20
Revisao     : Alexsander Martins dos Santos
Data/Hora   : 21/02/2006 14:45
Obs.        :
*/
//Static Function AE100GrvEEM(cPedido,cSequen,cNota,cSerie,cFilNf)
Function AE100GrvEEM(cPedido,cSequen,cNota,cSerie,cFilNf, nSD1Quant, nSD1Total)

Local aOrd := SaveOrd({"SF2","SD2","EEM"})
Local lFound:=.f., nRecnoEEM:=1
Local cChaveFat := ""                //NCF - 07/12/2015
Local cPedFat, cItPedFat
Local dDtNf
Private  nTaxa := 0
Default cFilNf := xFilial("SD2")
Begin Sequence

   cNota := AvKey(cNota , "EEM_NRNF")
   cSerie:= AvKey(cSerie, "EEM_SERIE")
   cFilNf:= AvKey(cFilNf, "EEM_FILIAL")

   EEM->(dbSetOrder(1)) // FILIAL + PREEMB + TIPOCA + NRNF + TIPONF
   IF EEM->(dbSeek(xFilial()+EEC->EEC_PREEMB+EEM_NF+cNota+EEM_SD))
      DO While EEM->(!Eof() .And. EEM_FILIAL == xFilial("EEM")) .And.;
               EEM->EEM_PREEMB == EEC->EEC_PREEMB .And.;
               EEM->EEM_TIPOCA == EEM_NF .And.;
               EEM->EEM_NRNF   == cNota

         IF EEM->EEM_SERIE == cSerie .And. EEM->(Ap101FilNf()) == cFilNf
            lFound   := .T.
            nRecnoEEM:= EEM->(RECNO())
            Exit
         Endif

         EEM->(dbSkip())
      Enddo
   ENDIF

   //IF !lFound
      SF2->(dbSetOrder(1))
      //SF2->(dbSeek(xFilial("SF2")+AvKey(cNota,"F2_DOC")+AvKey(cSerie,"F2_SERIE")))  // GFP - 14/11/2014
      SF2->(dbSeek(cFilNf+AvKey(cNota,"F2_DOC")+AvKey(cSerie,"F2_SERIE"))) //LRS - 18/04/2018

      If !lFound
         EEM->(RecLock("EEM",.T.))
      Else
         EEM->(RecLock("EEM",.F.))
      EndIf

      EEM->EEM_FILIAL:= xFilial("EEM")
      EEM->EEM_PREEMB:= EEC->EEC_PREEMB
      EEM->EEM_TIPOCA:= EEM_NF //Nota Fiscal
      EEM->EEM_NRNF  := cNota
      EEM->EEM_SERIE := cSerie

      //RMD - 24/02/15 - Projeto Chave NF
      SerieNfId("EEM",1,"EEM_SERIE",,,,EEM->EEM_SERIE)
      dDtNf := iif(SF2->(FieldPos('F2_DTTXREF')) > 0 .And. !empty(SF2->F2_DTTXREF),SF2->F2_DTTXREF,SF2->F2_EMISSAO) //MFR 07/08/2020 OSSME-4883
      EEM->EEM_DTNF  := SF2->F2_EMISSAO  
      EEM->EEM_TIPONF:= EEM_SD // Saida
      EEM->EEM_VLNF  := SF2->F2_VALBRUT
      EEM->EEM_VLMERC:= SF2->F2_VALMERC
      EEM->EEM_VLFRET:= SF2->F2_FRETE
      EEM->EEM_VLSEGU:= SF2->F2_SEGURO
      EEM->EEM_OUTROS:= SF2->F2_DESPESA
      EEM->EEM_MODNF := AModNot(SF2->F2_ESPECIE)
      IF EECFlags("FATFILIAL") // JPM - 26/12/05
         EEM->EEM_FIL_NF := cFilNf
      ENDIF
      If EEM->(FieldPos("EEM_CHVNFE")) > 0 //LGS-16/06/2015 - Campo para DE-WEB
         EEM->EEM_CHVNFE := SF2->F2_CHVNFE
      EndIf
      nRecnoEEM := EEM->(RECNO())
   //ENDIF

   If SX2->(dbSetOrder(1), dbSeek("EES")) .and. Select("EES") = 0
      dbSelectArea("EES")
   EndIf

   If Select("EES") = 0
      Break
   EndIf

   lFound := .F.

   //WFS 16/07/2009 ---
   //Tratamento para as notas fiscais de devolução quando usado o fluxo alternativo
   //de integração entre o SigaEEC e o SigaFat.
   //As tabelas EEC e EE9 são posicionadas no programa EECFAT3.
   If (EECFlags("INTEMB") .Or. (EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT))) .And. cModulo = "COM"
      cPedFat:= cPedido
      cItPedFat:= cSequen

      //A tabela EE9 é posicionada no programa EECFAT3.
      cPedido:= EE9->EE9_PEDIDO
      cSequen:= EE9->EE9_SEQUEN
   ElseIf (EECFlags("INTEMB") .Or. (EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT))) .and. (ChkFile("EXD") .and. Select("EXD") > 0)

      //Verifica se a nota fiscal já foi devolvida alguma vez.
      //Neste caso, o número e o item do pedido de vendas será outro.
      EXD->(DBSetOrder(1)) //EXD_FILIAL + EXD_PREEMB + EXD_SEQEMB + EXD_ITEM + EXD_PEDFAT + EXD_ITEMPV
      If EXD->(AvSeekLast(xFilial() + AvKey(WorkIp->EE9_PREEMB, "EXD_PREEMB") + AvKey(WorkIp->EE9_SEQEMB, "EXD_SEQEMB")))
         cPedFat:= AvKey(EXD->EXD_PEDFAT, "D2_PEDIDO")
         cItPedFat:= AvKey(EXD->EXD_ITEMPV, "D2_ITEMPV")
      Else
         cPedFat:= Posicione("EEC", 1, EEC->(xFilial()) + WorkIp->EE9_PREEMB, "EEC_PEDFAT")
         cItPedFat:= Posicione("EE9", 1, EE9->(xFilial()) + cPedido + cSequen, "EE9_FATIT")
      EndIf

   Else
      cPedFat   := Posicione("EE7", 1, xFilial("EE7")+cPedido, "EE7_PEDFAT")
      cItPedFat := Posicione("EE8", 1, xFilial("EE8")+cPedido+cSequen, "EE8_FATIT")
   EndIf
   // ---

   //If !lFound

      /* nopado por WFS em 16/07/2009
      cPedFat   := Posicione("EE7", 1, xFilial("EE7")+cPedido, "EE7_PEDFAT")
      cItPedFat := Posicione("EE8", 1, xFilial("EE8")+cPedido+cSequen, "EE8_FATIT") */

      cNota     := AvKey(cNota,  "D2_DOC")
      cSerie    := AvKey(cSerie, "D2_SERIE")

      SD2->(dbSetOrder(3),;
            dbSeek(cFilNf+cNota+cSerie))

      While SD2->(!Eof() .and. D2_FILIAL == cFilNf .and. D2_DOC == cNota .and. D2_SERIE == cSerie)

		  EES->(dbSetOrder(1))//EES_FILIAL+EES_PREEMB+EES_NRNF
		  cFilEES:= xFilial("EES")
		  cChaveFat := cFilEES + EEM->EEM_PREEMB + EEM->EEM_NRNF + AvKey(cSerie, "EES_SERIE") + AvKey(cPedido,"EES_PEDIDO") + AvKey(cSequen,"EES_SEQUEN")
		  cChaveFat += If( "EES_FATSEQ" $ EES->(IndexKey()) , AvKey(SD2->D2_ITEM,"EES_FATSEQ") , "")
		  IF EES->(dbSeek(cChaveFat/*cFilEES+EEM->EEM_PREEMB+EEM->EEM_NRNF*/))
		      /*
		      Do While !EES->(Eof()) .And.;
		                EES->EES_FILIAL == cFilEES         .And.;
		                EES->EES_PREEMB == EEM->EEM_PREEMB .And.;
		                EES->EES_NRNF   == EEM->EEM_NRNF

		          IF EES->EES_SERIE  == AvKey(cSerie, "EES_SERIE")	.AND.;
		             EES->EES_PEDIDO == AvKey(cPedido,"EES_PEDIDO")	.AND.;
		             EES->EES_SEQUEN == AvKey(cSequen,"EES_SEQUEN")	.And.;
		             EES->(Ap101FilNf()) == cFilNf					.And.;
		             EES->EES_FATSEQ == AvKey(SD2->D2_ITEM,"EES_FATSEQ") // LGS - 12/08/15-Deve pesquisar se existe na EES se possui o registro no Loop da SD2.
		             lFound := .t.
		             Exit
		          ENDIF*/
		      //NCF - 07/12/2015 - Melhoria na comparação para evitar perda de performance na função AvKey()
		      Do While EES->( !Eof() .And. Left(&(IndexKey()),Len(cChaveFat)) == cChaveFat )
		         If EES->(Ap101FilNf()) == cFilNf .And. If( "EES_FATSEQ" $ EES->(IndexKey()) , .T. , EES->EES_FATSEQ == AvKey(SD2->D2_ITEM,"EES_FATSEQ") )
		            lFound := .T.
		            Exit
		         EndIf
		         EES->(dbSkip())
		      Enddo
		  EndIf

         If SD2->(D2_PEDIDO == cPedFat .and.;
                  D2_ITEMPV == cItPedFat)

            If !lFound
               EES->(RecLock("EES", .T.))
            Else
               EES->(RecLock("EES", .F.))
            EndIF

            EES->EES_FILIAL := xFilial("EES")
            EES->EES_PREEMB := EEC->EEC_PREEMB
            EES->EES_NRNF   := cNota
            EES->EES_SERIE  := cSerie

            //RMD - 24/02/15 - Projeto Chave NF
            SerieNfId("EES",1,"EES_SERIE",,,,EES->EES_SERIE)

            EES->EES_DTNF   := SD2->D2_EMISSAO
            EES->EES_VLNF   := SD2->D2_VALBRUT
            EES->EES_VLMERC := SD2->D2_TOTAL
            EES->EES_VLFRET := SD2->D2_VALFRE
            EES->EES_VLSEGU := SD2->D2_SEGURO
            EES->EES_COD_I  := SD2->D2_COD
            EES->EES_PEDIDO := cPedido
            EES->EES_SEQUEN := cSequen
            EES->EES_QTDE   := SD2->D2_QUANT
            If EES->(FieldPos("EES_FATSEQ")) > 0   // By JPP - 27/06/2006 - Novo campo criado para correção no X2_UNICO, utilizado apenas na integração Microsiga.
               EES->EES_FATSEQ := SD2->D2_ITEM
            EndIf

            If EECFlags("FATFILIAL") //JPM - 26/12/05
               EES->EES_FIL_NF := cFilNf
            EndIf

            If EES->(FieldPos("EES_VLOUTR") > 0 .and. FieldPos("EES_VLNFM")  > 0 .and.;
                     FieldPos("EES_VLMERM") > 0 .and. FieldPos("EES_VLFREM") > 0 .and.;
                     FieldPos("EES_VLSEGM") > 0 .and. FieldPos("EES_VLOUTM") > 0)

               SYF->(dbSetOrder(1),;
                     dbSeek(xFilial()+EEC->EEC_MOEDA))

               If EECFLAGS("CAFE")

                  /////////////////////////////////////////////////////////////////////////////////////
                  //ER - 02/12/2008.                                                                 //
                  //A taxa de câmbio é digitada no final do dia, por isso quando as Notas Fiscais são//
                  //geradas, a taxa ainda não foi cadastrada e por isso elas são geradas com a taxa  //
                  //do dia anterior.                                                                 //
                  /////////////////////////////////////////////////////////////////////////////////////
                  nTaxa := RecMoeda(dDtNf-1, SYF->YF_MOEFAT)  //MFR 07/08/2020 OSSME-4883
               Else
                  nTaxa := RecMoeda(dDtNf, SYF->YF_MOEFAT)  //MFR 07/08/2020 OSSME-4883
               EndIf

               If EasyEntryPoint("EECAE100")
                  ExecBlock("EECAE100",.F.,.F.,{"ALT_TAXA"})
               Endif

               EES->EES_VLOUTR := SD2->D2_DESPESA
               EES->EES_VLNFM  := Round((EES->EES_VLNF/nTaxa),   AvSX3("EES_VLNFM",  AV_DECIMAL))
               EES->EES_VLMERM := Round((EES->EES_VLMERC/nTaxa), AvSX3("EES_VLMERM", AV_DECIMAL))
               EES->EES_VLFREM := Round((EES->EES_VLFRET/nTaxa), AvSX3("EES_VLFREM", AV_DECIMAL))
               EES->EES_VLSEGM := Round((EES->EES_VLSEGU/nTaxa), AvSX3("EES_VLSEGM", AV_DECIMAL))
               EES->EES_VLOUTM := Round((EES->EES_VLOUTR/nTaxa), AvSX3("EES_VLOUTM", AV_DECIMAL))

               //ER - 28/02/2007 - Tratamento para Notas Fiscais de Devolução
               /* nopado por WFS em 17/07/2009
               If EES->(FieldPos("EES_QTDDEV")) > 0 .and. EES->(FieldPos("EES_VALDEV")) > 0
                  EES->EES_QTDDEV := SD2->D2_QTDEDEV
                  EES->EES_VALDEV := SD2->D2_VALDEV
               EndIf */

               //WFS 17/07/2009 ---
               //Tratamento para as notas fiscais de devolução quando usado o fluxo alternativo
               //de integração entre o SigaEEC e o SigaFat.
               If EES->(FieldPos("EES_QTDDEV")) > 0 .and. EES->(FieldPos("EES_VALDEV")) > 0
                  If (EECFlags("INTEMB") .Or. (EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT))) .And. cModulo = "COM"
                     EES->EES_QTDDEV := nSD1Quant
                     EES->EES_VALDEV := nSD1Total
                  Else
                     //ER - 28/02/2007 - Tratamento para Notas Fiscais de Devolução
                     EES->EES_QTDDEV := SD2->D2_QTDEDEV
                     EES->EES_VALDEV := SD2->D2_VALDEV
                  EndIf
               EndIf

               If EEM->(FieldPos("EEM_TXTB")) > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_TXTB   := nTaxa
                  EEM->(MSUnlock())
               EndIF

               If EEM->(FieldPos("EEM_TXFRET")) > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_TXFRET := nTaxa
                  EEM->(MSUnlock())
               EndIF

               If EEM->(FieldPos("EEM_TXSEGU")) > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_TXSEGU := nTaxa
                  EEM->(MSUnlock())
               EndIF

               IF EEM->(FieldPos("EEM_TXOUDE")) > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_TXOUDE := nTaxa
                  EEM->(MSUnlock())
               EndIF

               IF EEM->(FieldPos("EEM_VLNFM"))  > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_VLNFM  += EES->EES_VLNFM
                  EEM->(MSUnlock())
               EndIF

               IF EEM->(FieldPos("EEM_VLMERM")) > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_VLMERM += EES->EES_VLMERM
                  EEM->(MSUnlock())
               EndIF

               IF EEM->(FieldPos("EEM_VLFREM")) > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_VLFREM += EES->EES_VLFREM
                  EEM->(MSUnlock())
               EndIF

               IF EEM->(FieldPos("EEM_VLSEGM")) > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_VLSEGM += EES->EES_VLSEGM
                  EEM->(MSUnlock())
               EndIF

               IF EEM->(FieldPos("EEM_OUTROM")) > 0
                  EEM->(RecLock("EEM", .F.))
                  EEM->EEM_OUTROM += EES->EES_VLOUTM
                  EEM->(MSUnlock())
               ENdIF

            EndIf

            EES->(MsUnLock())

            If EEM->(FieldPos("EEM_CF") > 0 .and. Empty(EEM_CF))
               EEM->(RecLock("EEM", .F.))
               EEM->EEM_CF := SD2->D2_CF
               EEM->(MSUnlock())
            EndIf

         EndIf

         SD2->(dbSkip())

      End

   //EndIf

End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : AE100MarkNF
Parametros  : lMarca
Retorno     : nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/06/2000 11:20
Revisao     :
Obs.        :
*/
Static Function AE100MarkNF(lMarca,bTiraMark)
Local nRecOld := WorkIP->(RecNo())
Local cNF     := WorkIP->EE9_NF
Local cSerie  := WorkIP->EE9_SERIE
Local cFilNf  := WorkIp->(Ap101FilNf()) // JPM - 26/12/05 - geração de notas fiscais em várias filiais.
Local cFatSeq := If(Avflags("EEC_LOGIX"),WorkIP->EE9_FATSEQ,"") //NCF - 23/11/2017
Local bForDet := If( !Avflags("EEC_LOGIX") , {|| WorkIP->(EE9_NF+EE9_SERIE+Ap101FilNf()) == cNF+cSerie+cFilNf } , {|| WorkIP->(EE9_NF+EE9_SERIE+Ap101FilNf()+EE9_FATSEQ) == cNF+cSerie+cFilNf+cFatSeq } )
Local bMarca, bDesMarca
Local aDif, nDif, nPos
Private lAutom := .T.
Begin Sequence

   WorkIp->(dbGoTop())

   If lConsolida
      aDif := {}
      While WorkIp->(!EoF())
         If Eval(bForDet) // se for a mesma NF
            nDif := 0
            If lMarca
               If !Empty(WorkIp->WP_FLAG) // armazena qtde utilizada anteriormente
                  nDif -= WorkIp->EE9_SLDINI
               EndIf
               WorkIp->(EE9_SLDINI += WP_SLDATU, WP_SLDATU := 0) // sempre marca total SVG ch. 076097
               //WorkIp->(EE9_SLDINI := WP_SLDATU, WP_SLDATU := 0) // sempre marca total SVG ch. 076097 substituido pelo acima
               AE100DETIP(.T.) // marca
               If Empty(WorkIp->WP_FLAG) // se não pode marcar, volta a quantidade utilizada
                  WorkIp->(WP_SLDATU += EE9_SLDINI, EE9_SLDINI := 0)
               EndIf
               nDif += WorkIp->EE9_SLDINI // soma a quantidade que foi usada, para saber a diferença
            Else
               If !Empty(WorkIp->WP_FLAG)
                  nDif -= WorkIp->EE9_SLDINI // quando desmarca, a diferença é sempre negativa
                  Eval(bTiraMark)
               EndIf
            EndIf
            If nDif <> 0 // se houve diferença na quantidade, armazena em um array, para que possa ser replicado na work da filial oposta
               If (nPos := AScan(aDif,{|x| x[1] == WorkIp->(Ap104SeqIt()) })) = 0
                  AAdd(aDif,{WorkIp->(Ap104SeqIt()),0})
                  nPos := Len(aDif)
               EndIf
               aDif[nPos][2] += nDif
            EndIf
         EndIf
         WorkIp->(DbSkip())
      EndDo

      If lConsolOffShore .And. Len(aDif) > 0
         WorkOpos->(DbGoTop())
         While WorkOpos->(!EoF())
            If (nPos := AScan(aDif,{|x| x[1] == WorkOpos->(Ap104SeqIt()) })) > 0 // procura no array se há diferença para esta sequência de origem.
               If aDif[nPos][2] = 0 .Or.; // se não há diferença
                  (aDif[nPos][2] > 0 .And. WorkOpos->WP_SLDATU = 0) //ou não há saldo para acrescentar...
                  WorkOpos->(DbSkip()) // desconsidera
                  Loop
               EndIf
               If aDif[nPos][2] > 0 // se é para aumentar
                  If aDif[nPos][2] > WorkOpos->WP_SLDATU
                     WorkOpos->(EE9_SLDINI += WP_SLDATU)
                     aDif[nPos][2] -= WorkOpos->WP_SLDATU
                     WorkOpos->WP_SLDATU := 0
                  Else
                     WorkOpos->EE9_SLDINI += aDif[nPos][2]
                     WorkOpos->WP_SLDATU  -= aDif[nPos][2]
                     aDif[nPos][2] := 0
                  EndIf
               Else // diminuir
                  If -aDif[nPos][2] > WorkOpos->EE9_SLDINI
                     WorkOpos->(WP_SLDATU += EE9_SLDINI)
                     aDif[nPos][2] += WorkOpos->EE9_SLDINI
                     WorkOpos->EE9_SLDINI := 0
                  Else
                     WorkOpos->EE9_SLDINI += aDif[nPos][2]
                     WorkOpos->WP_SLDATU  -= aDif[nPos][2]
                     aDif[nPos][2] := 0
                  EndIf
               EndIf
               If WorkOpos->EE9_SLDINI = 0
                  WorkOpos->WP_FLAG := ""
               Else
                  WorkOpos->WP_FLAG := cMarca
               EndIf
               If !Empty(WorkOpos->WP_FLAG)
                  Ap101CalcPsBr(OC_EM,.T.,,.F.,"WorkOpos") // recalcula pesos liquido e bruto.
               EndIf
            EndIf
            WorkOpos->(DbSkip())
         EndDo

      EndIf
   Else
      bMarca    := {|| IF(Empty(WorkIP->WP_FLAG),AE100DETIP(.T.),) }
      bDesMarca := {|| IF(!Empty(WorkIP->WP_FLAG),Eval(bTiraMark),) }
      WorkIP->(dbEval(IF(lMarca,bMarca,bDesMarca),bForDet))
      
      AE100TTela(.F.)

      If EECFlags("COMISSAO")
         EECTotCom(OC_EM)
      EndIf
      AE100PrecoI()


   EndIf

End Sequence

If lConsolida
   Ap104LoadGrp() //atualiza os agrupamentos de itens
EndIf

WorkIP->(dbGoTo(nRecOld))

//THTS - 11/11/2017 - Grava a NF na WorkNF após marcar ou apaga após desmarcar
If !Empty(WorkIP->EE9_NF)
    If lMarca
        If !WorkNF->(dbSeek(EEM_NF +AvKey(WorkIP->EE9_NF,"EEM_NRNF") + AvKey(WorkIP->EE9_SERIE,"EEM_SERIE")))
            AE100WrkNF(WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIP->EE9_NF,WorkIP->EE9_SERIE,WorkIp->(Ap101FilNf()))
        EndIf
    Else
        If WorkNF->(dbSeek(EEM_NF +AvKey(WorkIP->EE9_NF,"EEM_NRNF") + AvKey(WorkIP->EE9_SERIE,"EEM_SERIE")))
            RecLock("WorkNF",.F.)
            WorkNF->(dbDelete())
            WorkNF->(MsUnlock())
        EndIf
    EndIf
EndIf

If AVFLAGS("EEC_LOGIX")                                          //NCF - 23/11/2017
   AE102ESSEYY( If(lMarca,"1","2") ,WorkIP->EE9_PREEMB,"WORKIP")
EndIf

Return NIL

/*
Funcao      : AE100MarkIt
Parametros  : lMarca
Retorno     : nenhum
Objetivos   :
Autor       : Cristiane C. Figueiredo
Data/Hora   : 15/08/2000 10:00
Revisao     :
Obs.        :
*/
Static Function AE100MarkIt(bTiraMark)

Local nRecOld := WorkIP->(RecNo())
Local bMarca   := {|| AE100DETIP(.T.,.t.) }
Local bDesMarca:= {|| VldOpeAE100("DESMARC_IT") .And. Eval(bTiraMark) }
Local cBackFilter
Local i, j, aAux, aOldFilter, cWork
Local aOrdWorkIP
Private  bForMarca := {|| Empty(WorkIP->WP_FLAG) }  //igor chiba 02/02/2010 passado para private para alterar no ponto de entrada
Private  bForDesMarca :={|| ! Empty(WorkIP->WP_FLAG) }//igor chiba 02/02/2010 passado para private para alterar no ponto de entrada
Private  lMarkall := .t., lAutom := .t.
If lConsolOffShore
   Private aSelAtu := {}
   Private aSelOpos := {}
EndIf

Begin Sequence
   If lConsolida
      lMarca := (WorkGrp->WP_FLAG == "N ")
      bMarca    := {|| WorkIp->(EE9_SLDINI += WP_SLDATU, WP_SLDATU := 0),AE100DETIP(.T.),If(Empty(WorkIp->WP_FLAG),WorkIp->(WP_SLDATU += EE9_SLDINI , EE9_SLDINI := 0),) }
      //bForMarca := {|| If(Empty(WorkIP->WP_FLAG),bDesMarca,), .t. }
      bForMarca := {||.t.} //sempre marca total qdo marca todos.
   Else
      lMarca := Empty(WorkIP->WP_FLAG)
   EndIf

   //RMD - Como a rotina de consolidação altera várias vezes o filtro da Workit, algumas vezes o sistema travava ao dar DbGoTop na WorkIt
   //      por isso, o filtro é limpo e aplicado novamente

   If EasyEntryPoint("EECAE100")
      ExecBlock("EECAE100", .F., .F.,"ALTMARCA")  //igor chiba 02/02/2010 ponto de entrada para alterar bformarca e bfordesmarca
   EndIf

   cBackFilter := WorkIp->(DbFilter())
   WorkIp->(DbClearFilter())
   If !Empty(cBackFilter)                                               //NCF - 08/12/2015
      WorkIp->(DbSetFilter(&("{|| " + cBackFilter + " }"),cBackFilter))
   Endif

   cItens:=""
   IF lMarca //.and. AEAntMarca(1) NOPADO POR AOM - 04/07/2011 //GFC
         aOrdWorkIP := SaveOrd("WorkIP")
      WorkIp->(dbSetOrder(0))
      WorkIP->(dbGoTop())
      WorkIP->(dbEval(bMarca,bForMarca))
      restOrd(aOrdWorkIP)
   ElseIf AEAntVal()
      WorkIP->(dbGoTop())         //GFC
      While WorkIp->(!Eof()) //28/11/2019
         //WorkIP->(dbEval(bDesMarca,bForDesMarca))
         If !Empty(WorkIP->WP_FLAG)
            Eval(bDesMarca)
         EndIf
         WorkIp->(DBSkip())
      EndDo 
   Endif

   If lConsolOffShore
      WorkOpos->(DbGoTop())
      While WorkOpos->(!EoF())
         If lMarca
            If Ae100VldSel("WorkOpos")
               WorkOpos->(WP_FLAG := cMarca, EE9_SLDINI += WP_SLDATU, WP_SLDATU := 0)
            EndIf
         Else
            If !Empty(WorkOpos->WP_FLAG)
               WorkOpos->WP_FLAG   := "  "
               WorkOpos->(WP_SLDATU += EE9_SLDINI)
               WorkOpos->EE9_SLDINI := 0
            EndIf
         EndIf
         WorkOpos->(DbSkip())
      EndDo
      // trata as quantidades que não puderam ser selecionadas
      // cancela as quantidades de cada filial...
      j := Len(aSelOpos)
      For i := Len(aSelAtu) To 1 Step -1 //
         If j <= 0
            Exit
         EndIf
         If aSelAtu[i][2] > aSelOpos[j][2]
            aSelAtu[i][2] -= aSelOpos[j][2]
            aSelOpos[j][2] := 0
         ElseIf aSelAtu[i][2] < aSelOpos[j][2]
            aSelOpos[j][2] -= aSelAtu[i][2]
            aSelAtu[i][2] := 0
         Else
            aSelOpos[j][2] := 0
            aSelAtu[i][2] := 0
         EndIf
         If aSelOpos[j][2] == 0
            j--
         EndIf
         If aSelAtu[i][2] <> 0
            i++
         EndIf
      Next
      //tira as qtds zeradas
      i := 1
      While i <= Len(aSelAtu)
         If aSelAtu[i][2] = 0
            ADel(aSelAtu[i][2])
            ASize(aSelAtu,Len(aSelAtu)-1)
         Else
            i++
         EndIf
      EndDo
      i := 1
      While i <= Len(aSelOpos)
         If aSelOpos[i][2] = 0
            ADel(aSelOpos[i][2])
            ASize(aSelOpos,Len(aSelOpos)-1)
         Else
            i++
         EndIf
      EndDo
      // balanceia as seleções..
      If Len(aSelAtu) > 0
         aAux := aSelAtu
         cWork := "WorkOpos"
      ElseIf Len(aSelOpos) > 0
         aAux := aSelOpos
         cWork := "WorkIp"
      Else
         Break
      EndIf
      ASort(aAux,,, {|x, y| x[1] < y[1] })

      WorkGrp->(DbSeek(aAux[i][1]))
      aOld := Ae104GrpFilter(,cWork) //seta filtros

      For i := 1 To Len(aAux)
         If aAux[i][1] <> WorkGrp->(EE9_PEDIDO+EE9_ORIGEM)
            WorkGrp->(DbSeek(aAux[i][1]))
            Ae104GrpFilter(,cWork)
            (cWork)->(DbGoBottom())
         EndIf
         While (cWork)->(!BoF())
            If (cWork)->EE9_SLDINI > aAux[i][2]
               (cWork)->EE9_SLDINI -= aAux[i][2]
               (cWork)->WP_SLDATU += aAux[i][2]
               aAux[i][2] := 0
            ElseIf (cWork)->EE9_SLDINI < aAux[i][2]
               aAux[i][2] -= (cWork)->EE9_SLDINI
               (cWork)->WP_SLDATU := (cWork)->EE9_SLDINI
               (cWork)->EE9_SLDINI := 0
            Else
               aAux[i][2] := 0
               (cWork)->WP_SLDATU += (cWork)->EE9_SLDINI
               (cWork)->EE9_SLDINI := 0
            EndIf
            If (cWork)->EE9_SLDINI == 0
               (cWork)->WP_FLAG := "  "
               (cWork)->(DbSkip(-1))
            Else
               (cWork)->WP_FLAG := cMarca
            EndIf
            If !Empty((cWork)->WP_FLAG)
               Ap101CalcPsBr(OC_EM,.T.,,.F.,cWork) // recalcula pesos liquido e bruto.
            EndIf
            If aAux[i][2] == 0
               Exit
            EndIf
         EndDo
      Next
   EndIf

End Sequence

/*
AMS - 09/11/2005. Imposta a chamada das funções AE100PrecoI, EECTotCom e AE100TTela, para que o valores sejam atualizados uma unica vez
                  no final da marcação/desmarcação.
*/
AE100PrecoI(.T.)

If EECFlags("COMISSAO")
   EECTotCom(OC_EM,, .T.)
EndIf

lMarkall := .F.
AE100TTela(.F.)
If Type("aOld") = "A"
   EECRestFilter(aOld[1])
EndIf

If lConsolida
   Ap104LoadGrp() // atualiza os agrupamentos de itens
EndIf

Workip->(dbgoto(nRecOld))

Return NIL

/*
Funcao      : AE100STATUS
Parametros  : cProcesso = Nro. Processo
              cPedFat = Número do Pedido do Faturamento
Retorno     : .F.
Objetivos   : Atualizar Status do Processo (EE7->EE7_STATUS)
Autor       : Jeferson Barros Jr.
Data/Hora   : 17/09/2000 15:22
Revisao     :
Obs.        :
*/
*-------------------------------------*
Function AE100Status(cProcesso,cPedFat)
*-------------------------------------*
Local lRet := .F., aOrd := SaveOrd({"EE7","EE8","EE9","SD2"}),;
      lEECFAT := IsIntFat() // ** By JBJ 29/05/02
      //lEECFAT  := EasyGParam("MV_EECFAT")
Local i
Local lTemSaldoAF   // ** Tem saldo aguardando faturamento ...
Local lTEMSALDO := .F.
Local lTemNFAE      // ** Tem nota fiscal aguardando embarque ...
Local lTemNf

Local lNenhumNFEmb    //Nenhum item do pedido foi embarcado
Local lNenhumEmb
Local lTodosEmb

Local cFase    := OC_PE

Local aFiliais := {} // JPM - 27/12/05 - Geração de notas fiscais em várias filiais.
Local lFilNf   := EECFlags("FATFILIAL")

Private lIntEmb  := EECFlags("INTEMB")
Private cStatus
// ** JPM - 26/07/06
If Type("lLibCredAuto") <> "L"
   Private lLibCredAuto := AvFlags("LIBERACAO_CREDITO_AUTO") //EasyGParam("MV_AVG0057",,.F.)
EndIf

Default cPedFat := ""

EE7->(DbSetOrder(1))
EE8->(DbSetOrder(1))
EE9->(DbSetOrder(1))
SD2->(DbSetOrder(8))
EEC->(DbSetOrder(1))

Begin Sequence

    /////////////////////////////////////////////////////////////////////////////////////////////////
    //Se a nova rotina de integração entre SigaEEC e SigaFAT estiver habilitada e o Pedido de Venda//
    //estiver relacionado ao Embarque, a função não será executada.                                //
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //Verifica se o pedido tem algum item com saldo
    If EasyQryCount("SELECT EE8_SLDATU FROM " + RetSQLName("EE8") + " WHERE EE8_FILIAL = '" + xFilial("EE8") + "' AND EE8_PEDIDO = '" + cProcesso + "' AND EE8_SLDATU <> 0 AND D_E_L_E_T_ = ' ' ") > 0
      lTemSaldo := .T.
    EndIf
  
    If lIntEmb  .Or. (EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT))
        If !Empty(cPedFat)
            cFase := FatFasePV(cPedFat)

        	If cFase == OC_EM
	            lRet := .T.
	            Break
         	EndIf

      	EndIf
  	EndIf

    If !EE7->(dbSeek(xFilial("EE7")+cProcesso ))
        Break
    Endif

    If lEECFAT .And. (Type("cTipoProc") <> "C" .Or. !(cTipoProc $ PC_BN+PC_BC+PC_RC))// Integrado  ...

      aFiliais := Ap101RetFil() // JPM - 27/12/05 - Filiais em que se deve buscar a nota.

      If !lFilNf
         lTemNf := !Empty(EE7->EE7_PEDFAT) .And. (SD2->(DbSeek(xFilial("SD2")+EE7->EE7_PEDFAT))) // ** Se existir Nota Fiscal ...  // RMD - 01/09/2014
      EndIf

      If lTemNF

            EE8->(DbSeek(xFilial("EE8")+cProcesso)) // ** Verifica os itens ...

            lTemNFAE := .F.
            lTemSaldoAF := .F.
            lNenhumNFEmb := .T.
            lTodosEmb := .T.
            lNenhumEmb := .T.

            Do While (EE8->EE8_FILIAL+EE8->EE8_PEDIDO == xFilial("EE8")+cProcesso) .And. !(EE8->(EOF()))

                EE9->(DbSetOrder(1)) //EE9_FILIAL, EE9_PEDIDO, EE9_SEQUEN

                If lTodosEmb
                    lTodosEmb := EE9->(DbSeek(xFilial("EE9")+EE8->EE8_PEDIDO+EE8->EE8_SEQUEN))
                EndIf

                If lNenhumEmb
                    lNenhumEmb := !EE9->(DbSeek(xFilial("EE9")+EE8->EE8_PEDIDO+EE8->EE8_SEQUEN))
                EndIf

                For i := 1 To Len(aFiliais) // JPM - 27/12/05 - Geração de Notas Fiscais em Várias Filiais.

                    If SD2->(DbSeek(aFiliais[i]+EE7->EE7_PEDFAT+EE8->EE8_FATIT))

                        EE9->(DbSetOrder(2)) //EE9_FILIAL, EE9_PREEMB, EE9_PEDIDO, EE9_SEQUEN

                        Do While !(SD2->(Eof())) .And. SD2->D2_FILIAL == aFiliais[i] .And. SD2->D2_PEDIDO == EE7->EE7_PEDFAT .And.;
                                    SD2->D2_ITEMPV == EE8->EE8_FATIT .And. !lTemNFAE

                            If aOrd[4][3] == SD2->(recno()) .And. IsInCallStack("MADELNFS")//LRS - 06/07/2017
                                SD2->(DbSkip())
                                Loop
                            EndIF

                            If !lTemNFAE
                                lTemNFAE := !EE9->(DbSeek(xFilial("EE9")+SD2->D2_PREEMB+EE8->EE8_PEDIDO+EE8->EE8_SEQUEN))
                                If !lTemNFAE
                                    lNenhumNFEmb := .F.
                                EndIf
                            EndIf

                            SD2->(DBSkip())

                        EndDo

                    EndIf

                Next

                IF !lTemSaldoAF // Não tem saldo Aguardando Faturamento
                    lTemSaldoAF := !isFaturado(cProcesso,EE8->EE8_SEQUEN, .T.)
                Endif

                EE8->(DBSkip())

            EndDo

      EndIf

        If !lTemNf
            //Nenhum item faturado
            If !lTemSaldo .And. !EE9->(DbSeek(xFilial("EE9")+cProcesso)) //Nao tem saldo e nao tem embarque
               cStatus := ST_PC //processo/embarque cancelado
            Else
               cStatus := ST_AF // ** Aguardando Faturamento ...
            EndIf
        Else

            If !lTemSaldoAF
                //Todos itens faturados
                If !lTemNFAE
                    //Todos itens embarcados
                    cStatus := ST_PE  // Lançado na fase de embarque

                ElseIf lNenhumNFEmb
                    //Nenhum item embarcado
                    cStatus := ST_FA // Faturado

                Else
                    //Parcialmente embarcado
                    cStatus := ST_LP //Lanc.Parcialmente na fase de embarque
                EndIf
            Else
                //Alguns itens faturados
                //Como saber qual item ta embarcado sem NF?
                If lNenhumEmb .Or. lTodosEmb //Verificar se todos estao embarcados
                    //Nenhum item embarcado
                    cStatus := ST_FP // Faturado Parcialmente

                Else
                    //Parcialmente Embarcado
                    cStatus := ST_LP //Lanc.Parcialmente na fase de embarque
                EndIf
            EndIF

        EndIf

    Else // Nao Integrado ...
      
      If (EE9->(DbSeek(xFilial("EE9")+cProcesso ))) // ** Se existir embarque ...

         If (lTemSaldo,cStatus := ST_LP,"")  // ** Lanc. Parcial na fase de embarque ..

      Else // ** Se nao existir embarque ...
         If !lTemSaldo
            cStatus := ST_PC //processo/embarque cancelado
         Else
            If Empty(EE7->EE7_DTAPCR);
               .And. !lLibCredAuto // JPM - 26/07/06 - qdo libera crédito automático, não pode voltar para "aguardando solicitação" ou "liberação"
               If Empty(EE7->EE7_DTSLCR)
                  cStatus:= ST_SC  // ** Aguardando Solicitação de Crétido ...
               Else
                  cStatus:= ST_LC  // ** Aguardando Liberação de Credito ...
               EndIf
            Else
               cStatus:= ST_CL     // ** Credito Liberado ...
            EndIf
         EndIf
      EndIf
    EndIf

    If EasyEntryPoint("EECAE100")
        ExecBlock("EECAE100", .F., .F.,{"STATUS"})
    EndIf
    If EE7->EE7_STATUS <> cStatus
        EE7->(RecLock("EE7",.F.))

        //Gravação da data do termino, quando não existir saldo no pedido.
        If lEECFAT
            If !lTemSaldoAF
            EE7->EE7_FIM_PE := dDataBase
            EndIf
        Else
            If !lTemSaldo
            EE7->EE7_FIM_PE := dDataBase
            EndIf
        EndIf

        EE7->EE7_STATUS := cStatus
        DSCSITEE7(.T.,OC_PE)    // ** Grava descricao do status
        EE7->(MSUnlock())
    EndIf

End Sequence
RestOrd(aOrd,.T.)
Return lRet

*------------------------------------------*
Function BuscaCGCFor(cCodFor,cLoja,lInteiro)
*------------------------------------------*
Local cCNPJ, nOldSA2Ord:=SA2->(IndexOrd())
Local cOldArea:=Select()
lInteiro:=If(lInteiro<>NIL,lInteiro,.F.)

SA2->(dbSetOrder(1))
SA2->(dbSeek(xFilial("SA2")+cCodFor+cLoja))
If lInteiro
   cCNPJ := SA2->A2_CGC
Else
   cCNPJ := Left(SA2->A2_CGC,8)
EndIf
SA2->(dbSetOrder(nOldSA2Ord))

dbSelectArea(cOldArea)

Return cCNPJ

/*
Função          : Conjunto de funções para Drawback
Objetivo        : Apropriação de Ato Concessório
Data/Hora       :
Obs.            :
*/

*----------------------------------------*
Static Function MontaProd(nOldRec,cSequen)
*----------------------------------------*
Local nSldIni:=0

Do While !WorkIP->(EOF()) .and. cSequen == WorkIP->EE9_SEQUEN
   nSldIni += WorkIP->EE9_SLDINI + WorkIP->WP_SLDATU
   WorkIP->(RecLock("WorkIP",.F.,.T.))
   WorkIP->(dbDelete())
   WorkIP->(msUnlock())
   WorkIP->(dbSkip())
EndDo

WorkIP->(dbGoTo(nOldRec))
WorkIP->(RecLock("WorkIP",.F.))
WorkIP->EE9_SLDINI += nSldIni
WorkIP->EE9_PRCTOT := WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI
WorkIP->EE9_PRCINC := WorkIP->EE9_PRCTOT
WorkIP->EE9_PSLQTO := WorkIP->EE9_PSLQUN*WorkIP->EE9_SLDINI
WorkIP->EE9_PSBRTO := WorkIP->EE9_SLDINI*WorkIP->EE9_PSBRUN
IF !EMPTY(WorkIP->EE9_QE)
   IF (M->EE9_SLDINI%M->EE9_QE)==0
      WorkIP->EE9_QTDEM1:=Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE) //QUANT.DE EMBAL.
   Else
      WorkIP->EE9_QTDEM1:=Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE)+1 //QUANT.DE EMBAL.
   EndIf
EndIf
WorkIP->(msUnlock())
AE100PrecoI()

Return .T.

*----------------------------*
Static Function VerACParcial()
*----------------------------*
Local lYes := .F., nRecAtu, nSomaSld:=0
Local lMatriz:=.F., cSequen:="", lDif, nOldIPRec
Local cNF

If M->WP_SLDATU > 0

   If AvFlags("GRADE")
      If !Empty(WorkIp->Wk_ITEMGR)
         Return lYes
      EndIf
   EndIf

   nOldIPRec := WorkIP->(RecNo())
   cSequen   := WorkIP->EE9_SEQUEN
   cNF       := WorkIP->EE9_NF
   lDif      := WorkIP->EE9_ATOCON <> M->EE9_ATOCON

   WorkIP->(dbSkip())

   lMatriz:= cSequen == WorkIP->EE9_SEQUEN .And. If( IsIntFat(), cNF == WorkIP->EE9_NF, .T.)

   If lMatriz .and. lDif
      MontaProd(nOldIPRec,cSequen)
   Else
      WorkIP->(dbSeek(M->EE9_PEDIDO+M->EE9_SEQUEN))
      Do While !WorkIP->(EOF()) .and. WorkIP->EE9_SEQUEN == cSequen
         nRecAtu := WorkIP->(RecNo())
         If nOldIPRec <> nRecAtu
            nSomaSld += WorkIP->EE9_SLDINI + WorkIP->WP_SLDATU
         ElseIf Empty(WorkIP->WP_FLAG)
            nSomaSld += M->EE9_SLDINI
         EndIf
         WorkIP->(dbSkip())
      EndDo
      WorkIP->(dbGoTo(nOldIPRec))
      If nSomaSld > M->EE9_SLDINI
         IF Empty(WorkIP->WP_FLAG) // Esta marcando ...
            M->WP_SLDATU := WorkIP->WP_SLDATU - M->EE9_SLDINI
            If lMatriz .and. M->WP_SLDATU > 0
               WorkIP->(dbGoTo(nRecAtu))
               WorkIP->(RecLock("WorkIP",.F.))
               WorkIP->WP_SLDATU += M->WP_SLDATU
               WorkIP->(msUnlock())
               WorkIP->(dbGoTo(nOldIPRec))
               M->WP_SLDATU := 0
            EndIf
            If(M->WP_SLDATU = 0 , lYes:=.T. ,)
         Else
            M->WP_SLDATU := (EE8->EE8_SLDATU+nEmbarcado) - nSomaSld
         Endif
      EndIf
   EndIf
EndIf

Return lYes

/*
Funcao      : AE100GerEmb()
Parametros  : lNewPed  => .t. Inclusao (Default).
                          .f. Alteracao.
Retorno     : .T.
Objetivos   : Gerar novo embarque para filial exterior.
Autor       : Jeferson Barros Jr.
Data/Hora   : 27/05/2002 16:58.
Revisao     :
Obs.        :
*/
*----------------------------------*
Static Function AE100GerEmb(lNewPed)
*----------------------------------*
Local lRet:=.t.,aOrd:=SaveOrd({"EEC","EE9","EE8","EE7"}),nX:=0,nRec:=0,cAlias:="",nRecEEC:=0
Local aPedidos:={},cPedido:="",nPos:=0,nSldItem:=0,nSld:=0
Local cField, bGetSetEE8, cFieldEE9, bGetSetEE9,cPedRef,cEmb,i
Local nSeqEmb := 1, lErro := .t., lIsOffShore := .f., z:=0, j:=0
Local cFilOd, cProc, cOldProc, x, cAux
Local aDespesasInt:={}, aNotCopy := {}, cId, aCapaNotCopy:={}
Local lConsolida := EECFlags("INTERMED")  // EECFlags("CONTROL_QTD")  // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
Local lConsolOffShore := ((EEC->EEC_INTERM $ cSim) .And. lConsolida)
Default lNewPed:=.t. // Inclusao

If Type("lConsolida") <> "L"
   lConsolida := .f.
EndIf

Begin Sequence

   cPedRef := EEC->EEC_PEDREF
   nRecEEC := EEC->(Recno())
   cEmb    := EEC->EEC_PREEMB

   If Empty(cFilBr) .Or. Empty(cFilEx)
      Break
   EndIf

   /* Caso a filial ativa for a filial de off-shore, não gera o pedido na filial do brasil. */
   If AvGetM0Fil()  == cFilEx
      // ** JPM - 01/11/05
      If lConsolOffShore
         Ae104AtuFil(cFilBr) //Atualiza filial oposta com os registros da WorkOpos
      EndIf
      // **
      Break
   EndIf

   // ** Verifica a flag de OffShore do processo na filial Brasil.
   lIsOffShore := (EEC->EEC_INTERM $ cSim)

   EEC->(dBSetOrder(1))
   If EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))
      // ** Caso o processo já esteja embarcado, nenhuma alteração é realizada.
      If !Empty(EEC->EEC_DTEMBA)
         EEC->(dbGoTo(nRecEEC))
         lErro := .f.
         Break
      Else
         If lIsOffShore .And. !lRecriaPed
            EEC->(dbGoTo(nRecEEC)) //WFS 15/01/2009
            // ** JPM - 01/11/05
            If lConsolOffShore
               Ae104AtuFil(cFilEx) //Atualiza filial oposta com os registros da WorkOpos
            EndIf
            // **/
            lErro := .f.
            //Break
         Else
            If !lIsOffShore
               // Para alteração passando de offshore para processo normal na filial brasil.
               EEC->(DbGoTo(nRecEEC))
               Ae100DelEmb(.f.,.f.)
               lErro := .f.
               Break
            EndIf
         EndIf
      EndIf
   Else
      If lIsOffShore
         lNewPed := .t. // Set da flag p/ processamento de inclusão.
      EndIf
   Endif

   EEC->(dbGoTo(nRecEEC))
   If !lIsOffShore //.or. (lIsOffShore .And. !lRecriaPed)
      Break
   EndIf

   // ** Verificacao da conformidade dos pedidos da filial Brasil com os da filial do exterior...
   EE9->(dbSetorder(2))
   If EE9->(DbSeek(xFilial("EE9")+EEC->EEC_PREEMB))
      While !EE9->(EOF()) .AND. xFilial("EE9")+EEC->EEC_PREEMB==EE9->EE9_FILIAL+EE9->EE9_PREEMB
         nPos := aScan(aPedidos,{|x| x[1]==EE9->EE9_PEDIDO .and. x[2]== EE9->EE9_SEQUEN } )

         If nPos > 0
            aPedidos[nPos][3] += EE9->EE9_SLDINI
         Else
            aAdd(aPedidos,{EE9->EE9_PEDIDO,EE9->EE9_SEQUEN,EE9->EE9_SLDINI})
         EndIf

         EE9->(DbSkip())
      EndDo
   EndIf
   EE9->(dbSeek(cFilBr+AvKey(M->EEC_PREEMB,"EE9_PREEMB")))

   If lNewPed .And. !lConsolida// Novo embarque na filial do exterior ...
      EE8->(DbSetOrder(1))
      For i:=1 To Len(aPedidos)
         nSld:=aPedidos[i][3]

         If EE8->(DbSeek(cFilEx+aPedidos[i][1]+aPedidos[i][2]))
            // Faz a verificacao do saldo ...
            nSld-=EE8->EE8_SLDATU

            // ** Para processos com commodity verifica se o preço foi fixado.
            If lCommodity .And. EE8->EE8_PRECO == 0 .And. !lConsolida
               EECMsg(STR0098+AllTrim(Transf(aPedidos[i][1],AvSx3("EE7_PEDIDO",AV_PICTURE)))+STR0123,STR0063) //"Problema: Este embarque não podera ser gerado na filial do exterior, o pedido "###       //" não tem preço definido"

               // ** Grava na filial brasil a flag de intermediação = não.
               EEC->(DbGoTo(nRecEEC))
               If EEC->(RecLock("EEC",.f.))
                  EEC->EEC_INTERM := "2"
                  EEC->(MsUnLock())
               EndIf
               Break
            Endif

         Else // ** Pedido nao encontrado na filial exterior ...
            EECMsg(STR0098+AllTrim(Transf(aPedidos[i][1],AvSx3("EE7_PEDIDO",AV_PICTURE)))+STR0102,STR0063) //"o pedido "###" não exite."###"Aviso"

            // ** Grava na filial brasil a flag de intermediação = não.
            EEC->(DbGoTo(nRecEEC))
            If EEC->(RecLock("EEC",.f.))
               EEC->EEC_INTERM := "2"
               EEC->(MsUnLock())
            EndIf
            Break
         EndIf

         // ** Quantidade à ser embarcada maior que a qtde disponível para embarque ...
         If nSld > 0
            EECMsg(STR0098+AllTrim(Transf(aPedidos[i][1],AvSx3("EE7_PEDIDO",AV_PICTURE)))+;
                    STR0117,STR0063) //"o pedido "###" "###"Aviso" //" não possue disponível a quantidade à ser embarcada."

            // ** Grava na filial brasil a flag de intermediação = não.
            EEC->(DbGoTo(nRecEEC))
            If EEC->(RecLock("EEC",.f.))
               EEC->EEC_INTERM := "2"
               EEC->(MsUnLock())
            EndIf
            Break
         EndIf
      Next

   ElseIf lNewPed .And. lConsolida
      For i := 1 To Len(aPedidos)
         If !EE8->(DbSeek(cFilEx+aPedidos[i][1]))
            EECMsg(STR0098+AllTrim(Transf(aPedidos[i][1],AvSx3("EE7_PEDIDO",AV_PICTURE)))+STR0102,STR0063) //"o pedido "###" não exite."###"Aviso"
            Break
         EndIf
      Next

   Else // Alteracao ...

      EEC->(dBSetOrder(1))

      If EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))
         EE7->(DbSetOrder(1))
         For nX:=1 To Len(aPedidos)
            If EE7->(DbSeek(cFilEx+aPedidos[nX][1]))
               If EE7->EE7_STATUS == ST_PC
                  EECMsg(STR0098+AllTrim(Transf(aPedidos[nX][1],AvSx3("EE7_PEDIDO",AV_PICTURE)))+STR0101,STR0063) //"o pedido "###" está cancelado."###"Aviso"
                  Break
               EndIf
            Else
               EECMsg(STR0098+AllTrim(Transf(aPedidos[nX][1],AvSx3("EE7_PEDIDO",AV_PICTURE)))+STR0102,STR0063) //"o pedido "###" não exite."###"Aviso"
               Break
            EndIf
         Next
      Else
         Break
      EndIf

      // ** By JBJ - 27/08/03 - 15:26 ...
      EEC->(DbGoTo(nRecEEC))
      If !(lRet := Ae100DelEmb(.f.,.f.))
         Break
      EndIf
   EndIf

   // ** Flag para indicar se o processo foi gerado/alterado na filial de OffShore.
   lErro := .f.

   EEC->(DbGoTo(nRecEEC))
   For nX := 1 TO EEC->(FCount())
       M->&(EEC->(FIELDNAME(nX))):=EEC->(FieldGet(nX))
   Next

   If lNewPed
      M->EEC_LC_NUM := Space(Avsx3("EEC_LC_NUM",AV_TAMANHO))//"" // Número de LC não é gerado na filial de off-shore.
   Else
      // ** Mantém o valor que já existe na filial de off-shore.
      If EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))
         M->EEC_LC_NUM := EEC->EEC_LC_NUM
      EndIf
      EEC->(DbGoTo(nRecEEC))
   EndIf

   /* by jbj - 07/03/05. 15:25.
      Para os ambientes em que a tabela de complemento de  dados do embarque esteja habilitada, o
      sistema deverá replicar na filial de off-shore os dados do EXL.
      Obs: a) Os dados das despesas internacionais, não  serão  replicadas na filial de off-shore;
           b) Os dados dos tratamentos de pré-cálculo não serão replicados na filial de off-shore. */

   If EECFlags("COMPLE_EMB")

      // Array de controle dos campos do EXL, que não serão copiados para a filial de Off-shore.
      aNotCopy := {}

      If EECFlags("FRESEGCOM")

         /* Realiza o levantamento dos campos utilizados nos tratamentos de despesas internacionais.
            Obs: O sistema irá considerar também as despesas customizadas de acordo com as regras de
                 criação de 'pacotes' de campos para cada despesa. (Moeda, Cond.Pagto, etc.). */

         aDespesasInt := X3DIReturn()
         For j:=1 To Len(aDespesasInt)
            cId := aDespesasInt[j][1]

            aAdd(aNotCopy,"EXL_MD" +cId)  // Moeda.
            aAdd(aNotCopy,"EXL_VD" +cId)  // Valor na moeda da despesa.
            aAdd(aNotCopy,aDespesasInt[j][2]) // Valor da Despesa na moeda do processo.
            aAdd(aNotCopy,"EXL_PA" +cId)  // Paridade.
            aAdd(aNotCopy,"EXL_EM" +cId)  // Empresa.
            aAdd(aNotCopy,"EXL_DE" +cId)  // Nome da Empresa.
            aAdd(aNotCopy,"EXL_FO" +cId)  // Fornecedor.
            aAdd(aNotCopy,"EXL_LF" +cId)  // Loja do Fornecedor.
            aAdd(aNotCopy,"EXL_CP" +cId)  // Condição de Pagamento.
            aAdd(aNotCopy,"EXL_DP" +cId)  // Dias de Pagamento.
            aAdd(aNotCopy,"EXL_DC" +cId)  // Descrição da Condição de Pagamento.
            aAdd(aNotCopy,"EXL_DT" +cId)  // Data Base.
         Next
      EndIf

      If EECFlags("HIST_PRECALC")
         aAdd(aNotCopy,"EXL_TABPRE")
      EndIf

      EXL->(DbSetOrder(1))
      If EXL->(DbSeek(xFilial("EXL")+EEC->EEC_PREEMB))

        For j := 1 TO EXL->(FCount())
           cAux := AllTrim(EXL->(FieldName(j)))
           M->&(cAux) := If(aScan(aNotCopy,cAux) = 0,;
                                  EXL->(FieldGet(j)),;
                                  CriaVar(EXL->(FieldName(j))))
        Next

        M->EXL_FILIAL := cFilEx
        M->EXL_PREEMB := EEC->EEC_PREEMB
      EndIf
   EndIf

   M->EEC_FILIAL := cFilEx
   M->EEC_OBS    := EEC->(MSMM(EEC_CODMEM,TAMSX3("EEC_OBS")[1]   ,,,LERMEMO))
   M->EEC_MARCAC := EEC->(MSMM(EEC_CODMAR,TAMSX3("EEC_MARCAC")[1],,,LERMEMO))
   M->EEC_OBSPED := EEC->(MSMM(EEC_CODOBP,TAMSX3("EEC_OBSPED")[1],,,LERMEMO))
   M->EEC_GENERI := EEC->(MSMM(EEC_DSCGEN,TAMSX3("EEC_GENERI")[1],,,LERMEMO))
   If EEC->(FieldPos("EEC_INFGER")) # 0  // GFP - 28/05/2014
      M->EEC_VMINGE := EEC->(MSMM(EEC_INFGER,TAMSX3("EEC_VMINGE")[1],,,LERMEMO))
   EndIf
   If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-30/10/2015
      M->EEC_VMDCOF := EEC->(MSMM(EEC_INFCOF,TAMSX3("EEC_VMDCOF")[1],,,LERMEMO))
   EndIf

   /* Grava as informações da pasta intermediação a partir do embarque da filial Brasil.
      Tratamentos para os campos específicos para intermediação. */

   M->EEC_IMPORT := M->EEC_CLIENT
   M->EEC_IMLOJA := M->EEC_CLLOJA
   M->EEC_IMPODE := Posicione("SA1",1,xFilial("SA1")+M->EEC_CLIENT,"A1_NOME")
   M->EEC_ENDIMP := EECMEND("SA1",1,M->EEC_IMPORT+M->EEC_IMLOJA,.T.,,1)
   M->EEC_END2IM := EECMEND("SA1",1,M->EEC_IMPORT+M->EEC_IMLOJA,.T.,,2)
   M->EEC_FORN   := If(!Empty(M->EEC_EXPORT),M->EEC_EXPORT,M->EEC_FORN)
   M->EEC_FOLOJA := If(!Empty(M->EEC_EXLOJA),M->EEC_EXLOJA,M->EEC_FOLOJA)
   M->EEC_CONDPA := EEC->EEC_CONDPA
   M->EEC_DIASPA := EEC->EEC_DIASPA
   M->EEC_INCOTE := EEC->EEC_INCOTE
   M->EEC_INTERM := "2"

// If !Empty(M->EEC_COND2) .And. !Empty(M->EEC_DIAS2) - AMS - 03/11/2005.
   If !Empty(M->EEC_COND2)

      /* by jbj - Neste ponto, caso a condição de pagamento da filial do exterior seja diferente
                  da filial brasil, o sistem irá carregar os dados da modalidade de pagamento de
                  acordo com o código da condição de pagamento. */

      SY6->(DBSETORDER(1))
      SY6->(DBSEEK(XFILIAL("SY6")+M->EEC_COND2+STR(M->EEC_DIAS2,3,0)))
      M->EEC_CONDPA := M->EEC_COND2
      M->EEC_DIASPA := M->EEC_DIAS2
      M->EEC_MPGEXP := SY6->Y6_MDPGEXP
      M->EEC_COND2  := ""
      M->EEC_DIAS2  := 0
   EndIf

   If !Empty(M->EEC_INCO2)
      M->EEC_INCOTE := M->EEC_INCO2
      M->EEC_INCO2  := ""
   EndIf

   M->EEC_PERC := 0

   If EasyEntryPoint("EECAE100")
      ExecBlock("EECAE100",.F.,.F.,{"PE_OFFSHORE_GERA_CAPA"})
   Endif

   /* by jbj - Após o carregamento das informações a partir do embarque da filial brasil, o  sistema irá  efetuar
               tratamento específico para os campos que devem  ser  carregados a  partir do  pedido da  filial de
               off-shore, além de  tratamentos para  os campos que deverão  ser carregados a partir dos campos de
               intermediação do embarque na filial brasil. */

   aCapaNotCopy:={"EEC_IMPORT","EEC_IMLOJA","EEC_IMPODE","EEC_ENDIMP","EEC_END2IM",;
                  "EEC_FORN"  ,"EEC_FOLOJA","EEC_CONDPA","EEC_DIASPA","EEC_INCOTE",;
                  "EEC_INTERM","EEC_MPGEXP","EEC_COND2" ,"EEC_DIAS2" ,"EEC_INCOTE",;
                  "EEC_PERC"  ,"EEC_STATUS"}

   // Carrega os campos a partir do pedido da filial exterior. (EEC/EXL).
   EE7->(DbSetOrder(1))
   If EE7->(DbSeek(cFilEx+M->EEC_PEDREF))
      For i:=1 To EE7->(FCount())
          cField := EE7->(FieldName(i))
          cVar := SubStr(AllTrim(cField),4)

          nPos:= aScan(aCapaNotCopy,"EEC"+cVar)
          If nPos = 0
             Do Case
                Case EEC->(FieldPos("EEC"+cVar)) > 0
                     cVar := "EEC"+cVar
                Case Select("EXL") > 0 .and. EXL->(FieldPos("EXL"+cVar)) > 0
                     cVar := "EXL"+cVar
                Otherwise
                     Loop
             End Case

             bVar := MemVarBlock(cVar)
             If Type(cVar) = "U"
                Loop
             Endif
             Eval(bVar, EE7->(FieldGet(i)))
          EndIf
      Next
   EndIf
   If EasyEntryPoint("EECAE100")  // By LCS - 26/08/2005
      ExecBlock("EECAE100",.F.,.F.,{"PE_OFFSHORE_DEPOIS_EE7"})
   Endif

   //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
   AvZap("WorkIP")

   //WFS 13/01/09
   //If lConsolOffShore // JPM - 01/11/05 - grava dados da WorkOpos
   If lConsolOffShore .And. !lCommodity
      WorkOpos->(DbClearFilter())
      WorkOpos->(DbGoTop())
      EE8->(DbSetOrder(1))
      nSeq := 0
      While WorkOpos->(!EoF())
         // ** Atualiza o saldo do item no pedido
         EE8->(DbSeek(cFilOpos+WorkOpos->(EE9_PEDIDO+EE9_SEQUEN)))
         EE8->(RecLock("EE8",.f.))
         EE8->EE8_SLDATU := WorkOpos->WP_SLDATU
         EE8->(MsUnlock())

         If Empty(WorkOpos->WP_FLAG)
            WorkOpos->(DbSkip())
            Loop
         EndIf
         nSeq++
         WorkIp->(DbAppend())
         AvReplace("WorkOpos","WorkIp")
         WorkIp->WP_FLAG    := cMarca
         WorkIp->EE9_SEQEMB := Str(nSeq,AvSx3("EE9_SEQEMB",AV_TAMANHO))
         WorkIp->EE9_PREEMB := cEmb
         WorkIp->TRB_ALI_WT := "EE9"
         WorkIp->TRB_REC_WT := EE9->(Recno())
         WorkOpos->(DbSkip())
      EndDo

   ElseIf lCommodity
      EE8->(dbSetOrder(1)) // Filial + Pedido + Sequencia.
      EE9->(dbSetOrder(1))

      For i:= 1 To Len(aPedidos)
         If EE8->(dbSeek(cFilEx + aPedidos[i][1] + aPedidos[i][2]))

            nSld:=aPedidos[i][3]

            WorkIP->( dbAppend() )

            For z:=1 To EE8->(FCount())
               cField     := EE8->(FieldName(z))
               bGetSetEE8 := FIELDWBLOCK(cFIELD,SELECT("EE8"))
               cFieldEE9  := "EE9"+SubStr(AllTrim(cField),4)
               bGetSetEE9 := FieldWBlock(cFieldEE9,Select("WorkIP"))

               If (WorkIP->(FieldPos(cFieldEE9))#0)
                  Eval(bGetSetEE9,Eval(bGetSetEE8))
               Endif
            Next
            WorkIp->TRB_ALI_WT:= "EE8"
            WorkIp->TRB_REC_WT:= EE8->(Recno())

            If nSld > EE8->EE8_SLDATU
               WorkIP->EE9_SLDINI:=EE8->EE8_SLDATU

               EE8->(Reclock("EE8",.F.))
               EE8->EE8_SLDATU:=0
               EE8->(MsUnlock())

               nSld -=WorkIP->EE9_SLDINI
            Else
               WorkIP->EE9_SLDINI:=nSld

               Ap101CalcPsBr(OC_EM)    // By JPP - 29/04/05 - 17:15 - O sistema deverá recalcular o peso bruto total.

               EE8->(Reclock("EE8",.F.))
               EE8->EE8_SLDATU -= WorkIP->EE9_SLDINI
               EE8->(MsUnlock())

               nSld:=0
            EndIf

            For x:=1 To Len(aMemoItem)
               If WorkIp->(FieldPos(aMemoItem[x][2])) > 0 .And. EE8->(FieldPos("EE8_"+SubStr(AllTrim(aMemoItem[x][1]), 5))) > 0
                  WorkIp->&(aMemoItem[x][2]) := MSMM(EE8->&("EE8_"+SubStr(AllTrim(aMemoItem[x][1]),5)),TAMSX3(aMemoItem[x][2])[1],,,LERMEMO)
               EndIf
            Next

            WorkIp->WP_FLAG    := cMarca
            WorkIp->EE9_QTDEM1 := WorkIp->EE9_SLDINI/WorkIp->EE9_QE
            WorkIp->EE9_PREEMB := cEmb
            WorkIp->EE9_SEQEMB := EE8->EE8_SEQUEN
         EndIf
      Next
   Else
      EE9->(dbSetorder(2))
      EE9->(dbSeek(cFilBr+M->EEC_PREEMB))
      M->EEC_PESLIQ := M->EEC_PESBRU := 0

      While EE9->(!Eof())  .AND. EE9->EE9_FILIAL == cFilBr  .AND. EE9->EE9_PREEMB == M->EEC_PREEMB
          nRec := EE9->(RecNo())

          For nX := 1 TO EE9->(FCount())
             M->&(EE9->(FIELDNAME(nX))) := EE9->(FieldGet(nX))
          Next

          //AOM - 20/05/2011
          If AvFlags("OPERACAO_ESPECIAL")
             M->EE9_DESOPE := Posicione('EJ0',1,xFilial('EJ0') + M->EE9_CODOPE ,'EJ0_DESC')
          EndIf

          For i:=1 To Len(aMemoItem)
             If EE9->(FieldPos(aMemoItem[i][1])) > 0
                M->&(aMemoItem[i][2]) := MSMM(EE9->&(aMemoItem[i][1]),TAMSX3(aMemoItem[i][2])[1],,,LERMEMO)
             EndIf
          Next

          WorkIP->(Reclock("WorkIP",.T.))
          AvReplace("M","WorkIP")
          WorkIP->EE9_PRECO  := Posicione("EE8",1,cFilEx+EE9->(EE9_PEDIDO+EE9_SEQUEN),"EE8_PRECO")         
          /* ** JPM - Esses valores são recalculados na Ae100PrecoI()
          WorkIp->EE9_PRCTOT := EE8->EE8_PRCTOT
          Workip->EE9_PRECOI := EE8->EE8_PRECOI
          Workip->EE9_PRCINC := EE8->EE8_PRCINC
          */
          WorkIp->WP_FLAG    := cMarca

          For i:=1 To Len(aMemoItem)
             If WorkIp->(FieldPos(aMemoItem[i][2])) > 0
                WorkIp->&(aMemoItem[i][2]) := MSMM(M->&(aMemoItem[i][1]),TAMSX3(aMemoItem[i][2])[1],,,LERMEMO)
             EndIf
          Next
          WorkIP->(MsUnlock()) //WFS 15/01/09
          // Recalcula os totais de peso da capa.
          M->EEC_PESLIQ += If(lConvUnid,AvTransUnid(WorkIp->EE9_UNPES,If(!Empty(M->EEC_UNIDAD),M->EEC_UNIDAD,"KG"),WorkIp->EE9_COD_I,;
                                                WorkIp->EE9_PSLQTO,.F.),WorkIp->EE9_PSLQTO)
          M->EEC_PESBRU += If(lConvUnid,AvTransUnid(WorkIp->EE9_UNPES,If(!Empty(M->EEC_UNIDAD),M->EEC_UNIDAD,"KG"),WorkIp->EE9_COD_I,;
                                                WorkIp->EE9_PSBRTO,.F.),WorkIp->EE9_PSBRTO)

          // ** Abate o valor lancado do saldo do pedido ...
          EE8->( RecLock("EE8", .F.) )
          //EE8->EE8_SLDATU := If((EE8->EE8_SLDINI - EE9->EE9_SLDINI) > 0,(EE8->EE8_SLDINI - EE9->EE9_SLDINI),0)

          EE8->EE8_SLDATU -= EE9->EE9_SLDINI
          If EE8->EE8_SLDATU < 0
             EE8->EE8_SLDATU := 0
          EndIf

          EE8->(msunlock())

          EE9->(DbGoTo(nRec))
          EE9->(DbSkip())
      Enddo
      If EECFlags("ITENS_LC")  // By JPP - 12/09/2005 - 10:25 - Copiar os Dados da LC dos Itens dos Itens do processo da filial Exterior.
         WORKIP->(DbGoTop())
         Do While WORKIP->(!Eof())
            EE8->(dbSetOrder(1)) // Filial + Pedido + Sequencia.
            If EE8->(dbSeek(cFilEx + WORKIP->EE9_PEDIDO + WORKIP->EE9_SEQUEN))
               WORKIP->EE9_LC_NUM := EE8->EE8_LC_NUM
               WORKIP->EE9_SEQ_LC := EE8->EE8_SEQ_LC
            EndIf
            WORKIP->(DbSkip())
         EndDo
      EndIf
   EndIf

   AE100DadosEmb("EET",cFilEx)         // Grava as despesas ...
   AE100DadosEmb("EEB",cFilEx)         // Grava as empresas ...
   AE100DadosEmb("EEJ",cFilEx,lNewPed) // Grava os bancos   ...
   AE100DadosEmb("EEN",cFilEx)         // Grava notifys     ...

   WorkIP->(dbSetFilter({|| EE9_PRECO <> 0 },"EE9_PRECO <> 0"))

   AE100PRECOI(.t.)  // Recalcula Precos

   Workip->(dbclearfilter())

   Workip->(DbGoTop())

   // ** Grava os itens do embarque ...
   While !WorkIp->(Eof())
      EE9->(Reclock("EE9", .t.))
      AVReplace("WorkIp", "EE9")
      EE9->EE9_FILIAL := cFilEx

      For i:=1 To Len(aMemoItem)
         If EE9->(FieldPos(aMemoItem[i][1])) > 0
            MSMM(,AvSX3(aMemoItem[i][2],AV_TAMANHO),,WorkIp->&(aMemoItem[i][2]),INCMEMO,,,"EE9",aMemoItem[i][1])
         EndIf
      Next

      //RMD - 24/02/14 - Projeto Chave NF
      SerieNfId("EE9",1,"EE9_SERIE",,,,EE9->EE9_SERIE)

      EE9->(MsUnlock())
      WorkIp->(dbSkip())
   EndDo

   // ** Grava o embarque ...
   EEC->(RecLock("EEC", .T.))
   AVREPLACE("M","EEC")
   EEC->EEC_FILIAL := cFilEx
   MSMM(,TAMSX3("EEC_OBS")[1],,M->EEC_OBS,INCMEMO,,,"EEC","EEC_CODMEM")
   MSMM(,TAMSX3("EEC_MARCAC")[1],,M->EEC_MARCAC,INCMEMO,,,"EEC","EEC_CODMAR")
   MSMM(,TAMSX3("EEC_OBSPED")[1],,M->EEC_OBSPED,INCMEMO,,,"EEC","EEC_CODOBP")
   MSMM(,TAMSX3("EEC_GENERI")[1],,M->EEC_GENERI,INCMEMO,,,"EEC","EEC_DSCGEN")
   If EEC->(FieldPos("EEC_INFGER")) # 0  // GFP - 28/05/2014
      MSMM(,TAMSX3("EEC_VMINGE")[1],,M->EEC_VMINGE,INCMEMO,,,"EEC","EEC_INFGER")
   EndIf
   If EEC->(FieldPos("EEC_INFCOF")) # 0 //LGS-30/10/2015
      MSMM(,TAMSX3("EEC_VMDCOF")[1],,M->EEC_VMDCOF,INCMEMO,,,"EEC","EEC_EEC_INFCOF")
   EndIf
   EEC->(RecLock("EEC",.F.))   // By JPP - 24/05/2006 10:30 - Deve-se bloquear a tabela EEC para a função DSCSITEE7() funcionar.
   DSCSITEE7(.t.,OC_EM)
   EEC->(MsUnLock())

   /* by jbj - Controles para atualização do status do(s) pedido(s) na filial de intermediação.
               a variavel cFilAnt, é configurada de acordo com a filial de intermediação, após a
               execução a variavel cFilAnt é reconfigurada de acordo com a filial logada. */

   If Len(aPedidos) > 0
      cFilOld  := AvGetM0Fil()
      cFilAnt  := cFilEx

      EE7->(DbSetOrder(1))
      For i:=1 To Len(aPedidos)
         cProc := AvKey(aPedidos[i][1],"EE7_PEDIDO")

         If cProc <> cOldProc
            If EE7->(DbSeek(xFilial("EE7")+cProc))
               Ae100Status(cProc)
            EndIf
            cOldProc := cProc
         EndIf
      Next

      cFilAnt := cFilOld
   EndIf

   /* by jbj - Para os ambiente com a tabela de complemento de embarque habilitada,
               o sitema irá gerar os dados do EXL, na filial de off-shore. */

   If EECFlags("COMPLE_EMB")
      If EXL->(RecLock("EXL", .t.))
         AvReplace("M","EXL")
         EXL->EXL_FILIAL := cFilEx
         EXL->(MsUnLock())
      EndIf
   EndIf

   If lNewPed .and. !Empty(M->EEC_LC_NUM)

      EEL->(dbSetOrder(1),;
            dbSeek(cFilEx+M->EEC_LC_NUM))

      nDecVl := AvSX3("EEL_LCVL", AV_DECIMAL)
      nTaxa  := EECCalcTaxa(M->EEC_MOEDA, EEL->EEL_MOEDA)

      EEL->(RecLock("EEL", .F.))
      EEL->EEL_SLDVNC -= Round(M->EEC_TOTPED*nTaxa, nDecVl)
      If !Empty(M->EEC_DTEMBA)
         EEL->EEL_SLDEMB -= Round(M->EEC_TOTPED*nTaxa, nDecVl)
      EndIf
      EEL->(MsUnLock())

   EndIf

   /*
   AMS - 05/02/2005 às 17:12. Geração de parcelas de cambio para filial da Off-Shore.
   */
   bLastHandler := ErrorBlock({||.T.})
   //Begin Sequence
      If !(lRet := AF200GParc(cFilEx))
         Break
      EndIf
   //End Sequence
   ErrorBlock(bLastHandler)

End Sequence

EEC->(DbGoTo(nRecEEC))

RestOrd(aOrd)

Return lRet

User Function AE100CanEmb(cFil,cProc)
Return AE100CanEmb(cFil,cProc)

/*
Funcao      : AE100CanEmb().
Parametros  : cFil -> Filial para cancelamento do processo.
Retorno     : .t./.f.
Objetivos   : Cancelar embarque na filial do exterior.
Autor       : Jeferson Barros Jr.
Data/Hora   : 28/05/2002 17:26.
Revisao     :
Obs.        :
*/
*-------------------------------------*
Function AE100CanEmb(cFil,cProc)
*-------------------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EEC","EE9"})
Local cFilOld  // By JPP - 29/08/2005 - 11:55 -
Default cProc := EEC->EEC_PREEMB
Default cFil  := cFilBr

Begin Sequence

   EEC->(dBSetOrder(1))
   If EEC->(DbSeek(cFil+cProc))
      If EEC->(Reclock("EEC",.f.))
         EE9->(dbSetOrder(2))

         If EE9->(dbSeek(cFil+cProc))
            While !EE9->(EOF()) .And. cFil+cProc == EE9->EE9_FILIAL+EE9->EE9_PREEMB
               If EE9->(RecLock("EE9",.F.))
                  EE9->EE9_STATUS := ST_PC
                  EE9->(MsUnlock())
               EndIf
               EE9->(DbSkip())
            Enddo
         EndIf

         If lNRotinaLC .And. !Empty(EEC->EEC_LC_NUM) // By JPP - 29/08/2005 - 11:55 - Estornar o saldo da L/C para Embarques cancelados.
            cFilOld := cFilAnt
            cFilAnt := cFil
            AE107DelLC()
            cFilAnt := cFilOld
         Endif

         //cancelar embarque...
         EEC->EEC_FIM_PE := dDataBase
         EEC->EEC_STATUS := ST_PC

         //atualizar descricao de status...
         DSCSITEE7(.T.,OC_EM)
         EEC->(MsUnlock())
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AE100DelEmb().
Parametros  : lIsFilBr  = .t. - Filial Brasil (Default).
                          .f. - Filial Exterior.
              lShowMsg  = .t. - Exibe Mensagens (Default).
                          .f. - Não exibe mensagens.
              xAtuPed   = .t. - Atualiza o saldo do EE8.
                          .f. - Não atualiza o saldo do EE8.
              lEliminar = .t. - Chamada na rotina de eliminação de processos.
                          .f. - Outras chamadas (Default).
Retorno     : .t.
Objetivos   : Deletar Processo de Embarque - (Tabelas Utilizadas na Manutenção de Embarque).
Autor       : Jeferson Barros Jr.
Data/Hora   : 27/08/2003 14:40.
Revisao     :
Obs.        :
*/
*-------------------------------------------------------*
Function AE100DelEmb(lIsFilBr,lShowMsg,xAtuPed,lEliminar)
*-------------------------------------------------------*
Local aAlias := {}, aProcs:={}, aOrd:=SaveOrd({"EEC","EE9","EE7","EE8"})
Local lRet := .t., lMv_0043, lMv_0044
Local bDel, bDelFat, bDelED3
Local nRecEEC:= 0, nX:=0, j:=0, nRecEE7:=0
Local cFilAux, cProc, cFilOld
Local cFilBr1 := cFilBr, i
Local cFilcpy    // By JPP - 29/08/2005 - 13:45
Local lRecNoAtu

//RMD - 15/01/08 - Define se serão eliminados os resíduos do pedido de venda no faturamento
Local lElimResFat := .F.
Local lChkResFat  := .F.

Default lIsFilBr  := .t.
Default lShowMsg  := .t.
Default xAtuPed   := .t.
Default lEliminar := .f.

//AMS - 15/10/2003 às 10:40.
If Val( cFilBr1 ) = 0
   cFilBr1 := xFilial("EEC")
EndIf

Begin Sequence
   If Type("lItFabric") == "U"  // By JPP - 14/11/2007 - 14:00
      lItFabric := EasyGParam("MV_AVG0138",,.F.)
   EndIf
   lRecNoAtu := (ValType(xAtuPed) = "A")

   cFilAux := If(lIsFilBr,cFilBr1,cFilEx)

   aAlias:={}
   aAdd(aAlias,{"EE9",2,cFilAux +EEC->EEC_PREEMB, {||cFilAux==EE9->EE9_FILIAL.AND.EEC->EEC_PREEMB==EE9->EE9_PREEMB }})

   If !lIntegra .AND. AvFlags("EEC_LOGIX")
      //Para logix, não há exclusão da Nota fiscal e nem dos itens, apenas a desassociação do embarque.
	  //Necessário seekar para repocionar, pois o preemb está no indice.
      aAdd(aAlias,{"EES",1,cFilAux +EEC->EEC_PREEMB, {|| EES->(dbSeek(cFilAux+EEC->EEC_PREEMB)) }})
   Else
      aAdd(aAlias,{"EES",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EES->EES_FILIAL .And. EES->EES_PREEMB == EEC->EEC_PREEMB }})
   EndIf

   aAdd(aAlias,{"EEM",1,cFilAux +EEC->EEC_PREEMB, {||cFilAux==EEM->EEM_FILIAL.AND.EEC->EEC_PREEMB==EEM->EEM_PREEMB }})
   aAdd(aAlias,{"EEB",1,cFilAux +EEC->EEC_PREEMB+OC_EM, {||cFilAux==EEB->EEB_FILIAL.AND.EEC->EEC_PREEMB==EEB->EEB_PEDIDO.AND.EEB->EEB_OCORRE==OC_EM }})
   aAdd(aAlias,{"EEJ",1,cFilAux +EEC->EEC_PREEMB+OC_EM, {||cFilAux==EEJ->EEJ_FILIAL.AND.EEC->EEC_PREEMB==EEJ->EEJ_PEDIDO.AND.EEJ->EEJ_OCORRE==OC_EM }})
   aAdd(aAlias,{"EEK",2,cFilAux +OC_EM+EEC->EEC_PREEMB, {||cFilAux==EEK->EEK_FILIAL.AND.EEC->EEC_PREEMB==EEK->EEK_PEDIDO.AND.EEK->EEK_TIPO  ==OC_EM }})
   aAdd(aAlias,{"EET",1,cFilAux +AvKey(EEC->EEC_PREEMB,"EET_PEDIDO")+OC_EM, {||cFilAux==EET->EET_FILIAL .AND. AvKey(EEC->EEC_PREEMB,"EET_PEDIDO")==EET->EET_PEDIDO .AND. EET->EET_OCORRE==OC_EM }})
   aAdd(aAlias,{"EEN",1,cFilAux +EEC->EEC_PREEMB+OC_EM, {||cFilAux==EEN->EEN_FILIAL .AND.EEC->EEC_PREEMB==EEN->EEN_PROCES .AND.EEN->EEN_OCORRE==OC_EM }})
   aAdd(aAlias,{"EEO",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EEO->EEO_FILIAL .And. EEO->EEO_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EEZ",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EEZ->EEZ_FILIAL .And. EEZ->EEZ_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EEX",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EEX->EEX_FILIAL .And. EEX->EEX_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EX1",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EX1->EX1_FILIAL .And. EX1->EX1_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EX0",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EX0->EX0_FILIAL .And. EX0->EX0_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EX2",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EX2->EX2_FILIAL .And. EX2->EX2_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EXA",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EXA->EXA_FILIAL .And. EXA->EXA_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EX9",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EX9->EX9_FILIAL .And. EX9->EX9_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EXB",1,cFilAux +EEC->EEC_PREEMB+Space(AVSX3("EE7_PEDIDO",AV_TAMANHO)), {|| cFilAux==EXB->EXB_FILIAL .And. EXB->EXB_PREEMB == EEC->EEC_PREEMB .And. Empty(EXB->EXB_PEDIDO) }})
   aAdd(aAlias,{"EER",2,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EER->EER_FILIAL .And. EER->EER_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EEU",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EEU->EEU_FILIAL .And. EEU->EEU_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EXI",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EXI->EXI_FILIAL .And. EXI->EXI_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EXG",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EXG->EXG_FILIAL .And. EXG->EXG_PREEMB == EEC->EEC_PREEMB }})
   aAdd(aAlias,{"EEQ",1,cFilAux +EEC->EEC_PREEMB, {|| cFilAux==EEQ->EEQ_FILIAL .And. EEQ->EEQ_PREEMB == EEC->EEC_PREEMB }})

   If EECFlags("COMPLE_EMB")
      aAdd(aAlias,{"EXL",1,cFilAux+EEC->EEC_PREEMB, {|| cFilAux==EXL->EXL_FILIAL .And. EXL->EXL_PREEMB == EEC->EEC_PREEMB}})
   EndIf

   If EECFlags("HIST_PRECALC")
      aAdd(aAlias,{"EXM",1,cFilAux+EEC->EEC_PREEMB, {|| cFilAux==EXM->EXM_FILIAL .And. EXM->EXM_PREEMB == EEC->EEC_PREEMB}})
   EndIf

   // ** AAF 10/09/04 - Exclusão do Back To Back
   if lBACKTO
      aAdd(aAlias,{"EXK",1,cFilAux + OC_EM + EEC->EEC_PREEMB,{||cFilAux==EXK->EXK_FILIAL .AND. EXK->EXK_TIPO == OC_EM .AND. EXK->EXK_PROC==EEC->EEC_PREEMB}})
   endif
   // **

   If EECFlags("INVOICE") //By OMJ - 22/06/2005 15:35 - Tratamento de Invoice
      aAdd(aAlias,{"EXP",1,cFilAux+EEC->EEC_PREEMB, {|| cFilAux==EXP->EXP_FILIAL .And. EXP->EXP_PREEMB == EEC->EEC_PREEMB}})
      aAdd(aAlias,{"EXR",1,cFilAux+EEC->EEC_PREEMB, {|| cFilAux==EXR->EXR_FILIAL .And. EXR->EXR_PREEMB == EEC->EEC_PREEMB}})
   EndIf

   If EECFlags("CAFE")// RMD - Manutenção de OIC´s - 16/11/05
      aAdd(aAlias,{"EXZ",1,cFilAux+EEC->EEC_PREEMB,{|| cFilAux==EXZ->EXZ_FILIAL .And. EEC->EEC_PREEMB == EXZ->EXZ_PREEMB}})
      aAdd(aAlias,{"EY2",1,cFilAux+EEC->EEC_PREEMB,{|| cFilAux==EY2->EY2_FILIAL .And. EEC->EEC_PREEMB == EY2->EY2_PREEMB}})
      // ** JPM - 09/12/05 - Exclusão dos registros de armazém
      aAdd(aAlias,{"EY9",1,cFilAux+EEC->EEC_PREEMB,{|| cFilAux==EY9->EY9_FILIAL .And. EEC->EEC_PREEMB == EY9->EY9_PREEMB}})
      // **
   EndIf

   If lItFabric // By JPP - 14/11/2007 - 14:00
      aAdd(aAlias,{"EYU",1,cFilAux+EEC->EEC_PREEMB,{|| cFilAux==EYU->EYU_FILIAL .And. EEC->EEC_PREEMB == EYU->EYU_PREEMB}})
   EndIf

   If EECFlags("ESTUFAGEM")
      aAdd(aAlias,{"EYH",1,cFilAux+"N"+EEC->EEC_PREEMB,{|| cFilAux+"N"+EEC->EEC_PREEMB == EYH->(EYH_FILIAL+EYH_ESTUF+EYH_PREEMB) }})
      aAdd(aAlias,{"EYH",1,cFilAux+"S"+EEC->EEC_PREEMB,{|| cFilAux+"S"+EEC->EEC_PREEMB == EYH->(EYH_FILIAL+EYH_ESTUF+EYH_PREEMB) }})
   EndIf

   //ER - 27/02/2008
   ChkFile("EYW")
   If Select("EYW") > 0
      aAdd(aAlias,{"EYW",1,cFilAux+EEC->EEC_PREEMB,{|| cFilAux==EYW->EYW_FILIAL .And. EEC->EEC_PREEMB == EYW->EYW_PREEMB}})
   EndIf

   If AvFlags("FIM_ESPECIFICO_EXP")
      If !lIntegra .AND. AvFlags("EEC_LOGIX") //NCF - 23/11/2017
         //Para logix, não há exclusão da Nota fiscal e nem dos itens, apenas a desassociação do embarque.
	      //Necessário seekar para repocionar, pois o preemb está no indice.
         aAdd(aAlias,{"EYY",1,cFilAux+EEC->EEC_PREEMB,{|| EYY->(dbSeek(cFilAux+EEC->EEC_PREEMB)) }})
      Else
         aAdd(aAlias,{"EYY",1,cFilAux+EEC->EEC_PREEMB,{|| cFilAux+EEC->EEC_PREEMB == EYY->(EYY_FILIAL+EYY_PREEMB) }})
      EndIf
   EndIf

   If AvFlags("NOTAS_FISCAIS_SAIDA_LOTE_EXPORTACAO")
      If !lIntegra .AND. AvFlags("EEC_LOGIX")
         aAdd(aAlias,{"EK6",2,cFilAux+EEC->EEC_PREEMB,{|| EK6->(dbSeek(cFilAux+EEC->EEC_PREEMB)) }})
      Else
         aAdd(aAlias,{"EK6",2,cFilAux+EEC->EEC_PREEMB,{|| cFilAux+EEC->EEC_PREEMB == EK6->(EK6_FILIAL+EK6_PREEMB) }})
      EndIf
   EndIf

   //TRP- 02/03/2009
   If Type ("lDrawSC") == "L" .and. lDrawSC
      aAdd(aAlias,{"EDG",1,cFilAux+EEC->EEC_PREEMB,{|| cFilAux+EEC->EEC_PREEMB == EDG->(EDG_FILIAL+EDG_PREEMB) }})
   EndIf
   IF lIntegra
      bDel:={|| Eval(bDelFat),If(lIntDraw,Eval(bDelED3),nil), RECLOCK(Alias(),.F.),DBDELETE()}
   ElseIf AvFlags("EEC_LOGIX")                     //NCF - 21/11/2017
      bDel:={|| RecLock(Alias(),.F.), if(Alias() $ "EEM/EES/EYY", &(Alias()+"_PREEMB") := "" , DbDelete())  ,MsUnLock()}
   Else
      bDel:={||RecLock(Alias(),.F.),DbDelete(),MsUnLock()}
   Endif

   bDelFat := {|| IF(Alias()=="EE9",AE100GrvItSD2(EE9->EE9_PEDIDO,EE9->EE9_SEQUEN," ",EE9->EE9_NF,EE9->EE9_SERIE,EE9->(Ap101FilNf())),) }
   bDelED3 := {|| If(Alias()=="EE9",VoltaSaldoED3("E"),) }

   If lOkYS_PREEMB .AND. EasyGParam("MV_EEC_ECO",,.F.)
      AE100CCGRV(.F.)
   EndIf

   If(lIntDraw .and. lOkEE9_ATO, ED3->(dbSetOrder(2)),nil)

   bDelMemo := {|| MSMM(EEC->EEC_CODMAR,,,,EXCMEMO),;
                   MSMM(EEC->EEC_CODOBP,,,,EXCMEMO),;
                   MSMM(EEC->EEC_CODMEM,,,,EXCMEMO),;
                   MSMM(EEC->EEC_DSCGEN,,,,EXCMEMO)}

   If lIsFilBr // **  Filial Brasil.

      If lIntermed
         If (AvGetM0Fil() == cFilEx)
            cFilOld := cFilAnt
            cFilAnt := cFilBr1
         EndIf
      EndIf

      Begin Transaction

         If IsIntEnable("001")
            // Excluir os titulos provisorios
            If !(lRet := AE100DespPr(.T.))
               Break
            EndIf

            // Excluir as despesas nacionais
            If !(lRet := AE100DespNac())
               Break
            EndIf
         EndIf

         // ** Deleta os campos memo da capa do processo de embarque.
         Eval(bDelMemo)

         EE9->(DbSetOrder(2))
         EE9->(DbSeek(cFilBr1+EEC->EEC_PREEMB))
         Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == cFilBr1 .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB

            If If(lRecNoAtu,AScan(xAtuPed,EE9->(RecNo())) > 0,xAtuPed)
               If lIntegra .And. EE9->EE9_SLDINI == 0 .And. !lChkResFat
                  If AEFatSaldo(EE9->EE9_PEDIDO,EE9->EE9_SEQUEN)// TLM 31/01/2008 Verifica se a quantidade embarcada do item é igual a liberada pelo faturamento
                     If lShowMsg
                        Do Case// SVG 26/08/08 1 exibe a mensagem , 2 Não exibe e elimina , 3 Não exibe e não elimina
                           Case EasyGParam("MV_AVG0169") == "1"
                              lElimResFat := MsgYesNo(STR0193, STR0035)//"Deseja eliminar os resíduos de todos os pedidos de venda associados ao embarque?"###"Atenção"
                           Case EasyGParam("MV_AVG0169") == "2"
                              lElimResFat := .T.
                           Case EasyGParam("MV_AVG0169") == "3"
                              lElimResFat := .F.
                        EndCase
                      //lElimResFat := MsgYesNo(STR0193, STR0035)//"Deseja eliminar os resíduos de todos os pedidos de venda associados ao embarque?"###"Atenção"
                        lChkResFat  := .T.
                     Else
                        lElimResFat := .T.
                        lChkResFat  := .T.
                     EndIf
                  EndIf
               EndIF
               // ** Atualiza o saldo dos itens dos pedidos.
               Ae100Saldo(EE9->EE9_PEDIDO,EE9->EE9_SEQUEN,EE9->EE9_SLDINI,.t., lElimResFat)
            EndIf

            If aScan(aProcs,{|x| x == EE9->EE9_PEDIDO}) == 0
               aAdd(aProcs,EE9->EE9_PEDIDO)
            Endif

            // ** Exclui os campos memo dos itens.
            For i:=1 To Len(aMemoItem)
               If EE9->(FieldPos(aMemoItem[i][1])) > 0
                  MSMM(EE9->&(aMemoItem[i][1]),,,,EXCMEMO)
               EndIf
            Next

            EE9->(DbSkip())
         EndDo

         EEC->(RecLock("EEC",.F.))
         If lNRotinaLC .And. !Empty(EEC->EEC_LC_NUM) // By JPP - 29/08/2005 - 13:45 - Estornar o saldo da L/C para Embarques cancelados.
            cFilcpy := cFilAnt
            cFilAnt := cFilBr1
            AE107DelLC()
            cFilAnt := cFilcpy
         Endif

         //THTS - 27/11/2018 - Antes de executar as exclusões, é necessário verificar se exsite nota de remessa vinculada ao embarque.
         //Caso exista, é necessário voltar o saldo do campo D1_SLDEXP antes de excluir as linhas da EYY.
         If AvFlags("FIM_ESPECIFICO_EXP") .And. lIntegra .AND. !AvFlags("EEC_LOGIX") .And. NFRemNewStruct()
            AtD1SLDEXP(cFilAux, EEC->EEC_PREEMB) //Atualiza o saldo do campo D1_SLDEXP
         EndIf

         Processa({||ProcRegua(Len(aAlias)),;
                     AeVal(aAlias,{|aArq| If(Select(aArq[1])>0, AP100Del(aArq,bDel),nil)})},STR0025) //"Processando Estorno..."

         //EEC->(RecLock("EEC",.F.))

         EEC->(DbDelete())
         EEC->(MsUnLock())

         nRecEE7 := EE7->(RecNo())
         EE7->(DbSetOrder(1))

         For j:=1 To Len(aProcs)
            AE100Status(aProcs[j])

            // ** Neste ponto a data de finalização do pedido será eliminada.
            If EE7->(DbSeek(xFilial("EE7")+aProcs[j]))
               If EE7->(RecLock("EE7",.F.))
                  EE7->EE7_FIM_PE := AvCToD("")
               EndIf
            EndIf
         Next

         EE7->(DbGoTo(nRecEE7))

         If lIntermed .And. !lMultiOffShore
            If (EEC->EEC_INTERM $ cSim .And. AvGetM0Fil() == cFilBr1) // Testa a filial pq a rotina tb é chamada da filial de off-shore.
               AE100DelEmb(.f.,nil,nil,lEliminar)  // ** Deleta o processo na filial de off-shore.

            ElseIf (AvGetM0Fil() == cFilEx)
               cFilAnt := cFilOld
            EndIf
         EndIf

      End Transaction

      If !lRet .And. !AvFlags("EEC_LOGIX") //DFS - 16/05/12 - Mensagem impeditiva, a variavel logica for .T.
         ELinkClearID()
      EndIf

   Else // ** Filial Exterior.

      lMv_0043 := EasyGParam("MV_AVG0043",,.f.)
      lMv_0044 := EasyGParam("MV_AVG0044",,.f.)
      nRecEEC := EEC->(Recno())

      If AvGetM0Fil() == cFilBr1
         EEC->(dBSetOrder(1))
         If !EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))
            EEC->(DbGoTo(nRecEEC))
            lRet:=.f.
            Break
         EndIf
      EndIf

      Begin Transaction

         If IsIntEnable("001")
            // Excluir os titulos provisorios
            If !(lRet := AE100DespPr(.T.))
               Break
            EndIf

            // Excluir as despesas nacionais
            If !(lRet := AE100DespNac())
               Break
            EndIf
         EndIf

         EE8->(DbSetOrder(1))
         EE9->(DbSetOrder(2))
         If EE9->(DbSeek(cFilEx+EEC->EEC_PREEMB))
            While !EE9->(EOF()) .AND. cFilEx+EEC->EEC_PREEMB==EE9->EE9_FILIAL+EE9->EE9_PREEMB
               If aScan(aProcs,{|x| x == EE9->EE9_PEDIDO}) == 0
                  aAdd(aProcs,EE9->EE9_PEDIDO)
               EndIf

               If If(lRecNoAtu,AScan(xAtuPed,EE9->(RecNo())) > 0,xAtuPed)
                  // ** Atualizar o saldo no pedido ...
                  If EE8->(DbSeek(cFilEx+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
                     EE8->(RecLock("EE8"),.F.)
                     EE8->EE8_SLDATU := If((EE8->EE8_SLDATU + EE9->EE9_SLDINI) > 0,;
                                           (EE8->EE8_SLDATU + EE9->EE9_SLDINI),0)
                     EE8->(MsUnlock())
                  EndIf
               EndIf

               EE9->(DbSkip())
            EndDo
         EndIf

         // ** Deleta os campos memo da capa do processo de embarque.
         Eval(bDelMemo)

         // ** Deleta os campos memo do(s) item(ns) do processo de embarque.
         EE9->(DbSetOrder(2))
         EE9->(DbSeek(cFilEx+EEC->EEC_PREEMB))
         Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == cFilEx .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB
            For i:=1 To Len(aMemoItem)
               If EE9->(FieldPos(aMemoItem[i][1])) > 0
                  MSMM(EE9->&(aMemoItem[i][1]),,,,EXCMEMO)
               EndIf
            Next
            EE9->(DbSkip())
         EndDo

         EEC->(RecLock("EEC",.F.))
         If lNRotinaLC .And. !Empty(EEC->EEC_LC_NUM) // By JPP - 29/08/2005 - 13:45 - Estornar o saldo da L/C para Embarques cancelados.
            cFilcpy := cFilAnt
            cFilAnt := cFilEx
            AE107DelLC()
            cFilAnt := cFilcpy
         Endif

         Processa({||ProcRegua(Len(aAlias)),;
                     AeVal(aAlias,{|aArq| If(Select(aArq[1])>0, AP100Del(aArq,bDel),nil)})},STR0025) //"Processando Estorno..."

         cProc := EEC->EEC_PREEMB

         // EEC->(RecLock("EEC",.F.))

         EEC->(DbDelete())
         EEC->(MsUnLock())

         // ** Atualiza o status dos pedidos na filial exterior ...
         EE7->(DbSetOrder(1))
         For nX:=1 To Len(aProcs)
            If EE7->(DbSeek(cFilEx+aProcs[nX]))
               EE7->(RecLock("EE7",.F.))
               EE7->EE7_STATUS := ST_CL
               DSCSITEE7(.T.,OC_PE)

               If EasyEntryPoint("EECAE100")
                  ExecBlock("EECAE100", .F., .F., "DELEMB_ATUPEDIDO_OFFSHORE")
               EndIf

               EE7->(MsUnLock())
            EndIf
         Next

         If lEliminar
            /* Elimina o embarque na filial do brasil. */
            If EEC->(DbSeek(cFilBr1+cProc))
               lRet := AE100DelEmb()
            EndIf
         EndIf

      End Transaction

      If !lRet .And. !AvFlags("EEC_LOGIX") //DFS - 16/05/12 - Mensagem impeditiva, a variavel logica for .T.
         ELinkClearID()
      EndIf

      EEC->(DbGoto(nRecEEC))
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AE100DadosEmb()
Parametros  : cAlias => Alias do arquivo a ser pesquisado
              cFilEx => Filial do exterior
Retorno     : .T.
Objetivos   : Gravar Despesas, Bancos, Notifys e empresas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 28/05/2002 14:31
Revisao     :
Obs.        :
*/
*--------------------------------------------------*
Static Function AE100DadosEmb(cAlias,cFilEx,lNewPed)
*--------------------------------------------------*
Local lRet:=.t., nRecNo:=0, nX:=0,nOldArea:=Select()
Local lRepDespNac := EasyGParam("MV_AVG0173",.F.,.T.)

Default lNewPed := .f.

Begin Sequence

   (cAlias)->(DbSeek(cFilBr+M->EEC_PREEMB))

   ///////////////////////////////////////////////////////////////////////////////////
   //ER - 04/11/2008                                                                //
   //Através do parametro MV_AVG0173, define se as informações de despesas nacionais//
   //serão ou não replicadas para a Filial Off-Shore.                               //
   ///////////////////////////////////////////////////////////////////////////////////
   If !lRepDespNac
      If cAlias == "EET"
         lRet := .F.
         Break
      EndIf
   EndIf

   While (cAlias)->(!Eof()) .And. Eval(fieldwblock(cAlias+If(cAlias # "EEN","_PEDIDO","_PROCES"),Select(cAlias))) == M->EEC_PREEMB .And.;
         Eval(fieldwblock(cAlias+"_FILIAL",Select(cAlias))) == cFilBr

      /* Neste ponto o sistema irá desconsiderar os bancos cadastrados com o tipo
         banco do importador. */
      If cAlias == "EEJ"
         If Left(AllTrim(EEJ->EEJ_TIPOBC),1) == BC_DIM
            EEJ->(DbSkip())
            Loop
         EndIf
      EndIf

      If Eval(fieldwblock(cAlias+"_OCORRE",Select(cAlias))) == "P"
         (cAlias)->(dbskip())
         Loop
      EndIf

      ///////////////////////////////////////////////////////////////
      //ER - 04/11/2008                                            //
      //Apenas as empresas que não são do tipo "Agente de Comissão"//
      //serão gravadas na Filial Off-Shore.                        //
      ///////////////////////////////////////////////////////////////
      If !lRepDespNac
         If cAlias == "EEB"
            If Left(EEB->EEB_TIPOAG,1) <> "3"
               (cAlias)->(Dbskip())
               Loop
            EndIf
         EndIf
      EndIf

      nRecNo := (cAlias)->(recno())
      For nX := 1 TO (cAlias)->(FCount())
          M->&((cAlias)->(FIELDNAME(nX))) := (cAlias)->(FieldGet(nX))
      Next

      If (cAlias)->(Reclock(cAlias,.T.))
         AvReplace("M",cAlias)
         (cAlias)->&(AllTrim(cAlias)+"_FILIAL") := cFilEx
         (cAlias)->(MsUnlock())
      Endif
      (cAlias)->(Dbgoto(nRecno))
      (cAlias)->(Dbskip())
   EndDo

   If lNewPed .And. cAlias == "EEJ"
      If EEJ->(DbSeek(cFilEx+M->EEC_PEDREF+OC_PE))
         Do While EEJ->(!Eof()) .And. EEJ->EEJ_FILIAL == cFilEx .And. EEJ->EEJ_PEDIDO == M->EEC_PEDREF .And.;
                                      EEJ->EEJ_OCORRE == OC_PE

            If Left(AllTrim(EEJ->EEJ_TIPOBC),1) == BC_DIM
               nRecNo := (cAlias)->(recno())

               For nX := 1 TO EEJ->(FCount())
                   M->&(EEJ->(FIELDNAME(nX))) := EEJ->(FieldGet(nX))
               Next

               If EEJ->(Reclock("EEJ",.t.))
                  AvReplace("M","EEJ")
                  EEJ->EEJ_FILIAL := cFilEx
                  EEJ->EEJ_PEDIDO := M->EEC_PREEMB
                  EEJ->EEJ_OCORRE := OC_EM
                  EEJ->(MsUnlock())
               Endif
            EndIf

            EEJ->(DbSkip())
         EndDo
      EndIf
   EndIf

End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : AE100ShowIt
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Apresenta tela com todos os detalhes da selecao de itens efetuada.
              Alem de informativo, disponibiliza a opção de edição das informações pelo NotePad.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/06/02 - 10:58
Revisao     :
Obs.        :
*/
*----------------------------*
Static Function AE100ShowIt()
*----------------------------*
Local lRet := .t.
Local oDlg,oMemo, oFont := TFont():New("Courier New",09,15)
Local bOk := {|| oDlg:End(),AE100NoteIt(.t.)}, bCancel := {||oDlg:End(),AE100NoteIt(.t.)}
Local cTitulo:=STR0108+AllTrim(M->EEC_PREEMB)+STR0109 //"Embarque: "###" - Seleção de itens."
Local aButtons := {{"NOTE" ,{||AE100NoteIt()},STR0110}}  //"NotePad"

Private cMemo:=""

Begin Sequence

   cMemo:=STR0111+AllTrim(M->EEC_PREEMB)+Replic(ENTER,2) //"Seleção de itens - Embarque: "
   cMemo+=STR0112+Replic(ENTER,2) //"São selecionados para embarque apenas itens com preço definido."
   cMemo+=STR0113+Replic(ENTER,2) //"Abaixo segue(m) o(s) item(ns) sem definição de preço."
   cMemo+=IncSpace(STR0114,aVSX3("EE9_COD_I",AV_TAMANHO),.f.)+Space(2)+STR0115+Replic(ENTER,2) //"Cod.Item"###"Nro. Pedido de Venda"

   cMemo+=AllTrim(cItens)

   EECView(cMemo,cTitulo)

   /*DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 35,85 of oDlg

      @ 15,05 To 190,330 Label STR0116  PIXEL OF oDlg //"Detalhes da seleção de itens"
      @ 25,10 GET oMemo VAR cMemo MEMO HSCROLL FONT oFont SIZE 315,160 READONLY OF oDlg  PIXEL

      oMemo:lWordWrap := .F.

      oMemo:EnableVScroll(.t.)
      oMemo:EnableHScroll(.t.)

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED
*/
End Sequence

Return lRet

/*
Funcao      : AE100ViewIt()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Auxiliar a função AE100ShowIt. Abre o NotePad com todos os detalhes da seleção
              efetuada, a fim de proporcionar ao usuário imprimir ou salvar em arquivo para
              futura conferência.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/06/2002 11:08
Revisao     :
Obs.        :
*/
*---------------------------------*
Static Function AE100NoteIt(lApaga)
*---------------------------------*
Local lRet:=.t., cDir:= GetTempPath()/*GetWinDir()+"\TEMP\"*/,hFile  //ER - 31/08/05. Função Alterada para funcionar em Linux.

Default lApaga:=.f. // Se .t. apaga arquivo temporário no windows ...

Begin Sequence

   If !lApaga

      hFile := EasyCreateFile(cDir+"Itens.Txt")

      fWrite(hFile,cMemo,Len(cMemo))

      fClose(hFile)

      WinExec("NotePad "+cDir+"Itens.Txt")
   Else
      If File(cDir+"Itens.Txt")
         fErase(cDir+"Itens.Txt")
      EndIf
   EndIf

End Sequence

Return lRet

*----------------------------------*
Static Function AE100CCGrv(lIncluir)
*----------------------------------*
Local wind := 0,i
Private aTpRateio := {'H'}
Private TotValor:=0 // Alcir Alves - 08-11-05 - valor do saldo inicial * preco
Private aArrayAux:={}, aArrayDesp:={}, aArrayAux2:={} //Alcir Alves - 08-11-05 - variaveis para mannipulação dos pontos de entrada GRAVA_OS_RATEIOS
If(EasyEntryPoint("EECAE100"),ExecBlock("EECAE100",.F.,.F.,"TIPO_DE_RATEIO"),) // MJA 23/05/05

If !lIncluir
   //Apaga
   SYS->(DbSetOrder(2))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_PREEMB+YS_FORN+YS_MOEDA+YS_INVEXP+YS_CC
   For i:=1 to len(aTpRateio) // MJA 23/05/05 Para excluir todos os tipos de rateio do Processo
       SYS->(DbSeek(cFilSYS+IF(lYSTPMODU,"E","")+aTpRateio[i]+M->EEC_PREEMB))
       DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_PREEMB==M->EEC_PREEMB .AND. SYS->YS_TIPO = aTpRateio[i]
          SYS->(RecLock("SYS",.F.,.T.))
          SYS->(DBDELETE())
          SYS->(MSUnlock())
          SYS->(DBSKIP())
       EndDo
   Next i
   SYS->(dbSetOrder(1))
Else
   FOR Wind := 1 TO LEN(a_CC)
       SYS->(RecLock("SYS",.T.))
       SYS->YS_FILIAL  := cFilSYS
       IF lYSTPMODU
          SYS->YS_TPMODU  := "E"      //Modulo I=Importacao E=Exportacao(Campo Chave)
          SYS->YS_MOEDA   := a_CC[Wind,3]
       ENDIF
       SYS->YS_TIPO    := a_CC[Wind,5] //Alcir Alves - 08-11-05 //"H"
       SYS->YS_PREEMB  := M->EEC_PREEMB
       SYS->YS_CC      := a_CC[Wind,1]
       SYS->YS_FORN    := a_CC[Wind,2]
       TotValor:=a_CC[Wind,4]
       SYS->YS_PERC    := TotValor / nTotalR
       SYS->YS_INVEXP  := cInvoice
       SYS->(MSUnlock())
       If(EasyEntryPoint("EECAE100"),ExecBlock("EECAE100",.F.,.F.,"ATUALIZA_OS_RATEIOS"),) //Alcir Alves - 08-11-05
   NEXT Wind
   If(EasyEntryPoint("EECAE100"),ExecBlock("EECAE100",.F.,.F.,"GRAVA_OS_RATEIOS"),) // MJA 23/05/05
EndIf

*************************************************************

Return .T.
*--------------------------------------------------------------------
STATIC FUNCTION AE100EEQ()
LOCAL lRet := .T.
local aAreaEEQ := EEQ->(getarea())
*
/*
lRET := .T.
IF lMV0039
   EEQ->(DBSETORDER(1))
   IF (EEQ->(DBSEEK(XFILIAL("EEQ")+AVKEY(EEC->EEC_PREEMB,"EEQ_PREEMB"))))
      lRET := .F.
   ENDIF
ENDIF
RETURN(lRET)
*/

If lMV0039
   EEQ->( dbSetOrder( 1 ) )
   If EEQ->( dbSeek( xFilial("EEQ") + AVKey( EEC->EEC_PREEMB, "EEQ_PREEMB" ) ) )
      While EEQ->( !Eof() .and. EEQ_FILIAL == xFilial( "EEQ" ) ) .and. EEQ->EEQ_PREEMB == AVKey( EEC->EEC_PREEMB, "EEQ_PREEMB" )
         If ( Empty( EEQ->EEQ_TIPO ) .and. !Empty( EEQ->EEQ_PGT ) ) .or. (EEQ->EEQ_TIPO = "A" .And. EEQ->EEQ_FASE == "E") //Alterado por ER - 11/08/05
            lRet := .F.
            Exit
         EndIf
         EEQ->( dbSkip() )
      End
   EndIf
EndIf

restarea(aAreaEEQ)
Return( lRet )
*--------------------------------------------------------------------
STATIC FUNCTION AE100GPV(lP_MODO)
LOCAL lRET,aORD
*
aORD    := SAVEORD({"EE7"})
lRET    := .F.
lP_MODO := IF(lP_MODO=NIL,.T.,lP_MODO)
*

Begin Sequence

   IF lP_MODO .And. (lIntegra .Or. AvFlags("EEC_LOGIX"))
      *
      EE7->(DBSETORDER(1))
      EE7->(DBSEEK(XFILIAL("EE7")+WORKIP->EE9_PEDIDO))
      IF EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM
         lRET := .T.
     ENDIF
   ENDIF

End Sequence

RETURN(lRET)

/*
Autor: Alcir Alves
Data: 28-11-05
Funcao AE100VPROC
função de validação do numero do processo - EEC_PREEMB- Verifica se existe cambio no EEQ na
diigtação de um novo Nº de processo
*/
Function AE100VPROC()
Local lRet:=.t.
Local nLastInd:=EEQ->(indexord())
Local nLastrec:=EEQ->(Recno())
EEQ->(Dbsetorder(1))
if EEQ->(dbseek(M->EEC_FILIAL+M->EEC_PREEMB))
  lRet:=.f.
endif
EEQ->(dbsetorder(nLastInd))
EEQ->(dbgoto(nLastrec))
return lRet


/*
Funcao      : AE100VALATO
Parametros  : cCampo
Retorno     :
Objetivos   : Função solicitada pela Microsiga (Alfredo), em 15/12/2003 para manter a função
              AE100VALATO no programa original de criação.
Autor       : Cristiano A. Ferreira
Data/Hora   : 15/12/2003 11:17
Revisao     :
Obs.        :
*/
Function AE100ValAto(cCampo)
Return AE101ValAto(cCampo) // Estah no EECAE101 tiramos do EECAE100 por causa do CH

/*
Funcao      : AE100ESTAC
Parametros  :
Retorno     :
Objetivos   : Função solicitada pela Microsiga (Alfredo), em 15/12/2003 para manter a função
              AE100ESTAC no programa original de criação.
Autor       : Cristiano A. Ferreira
Data/Hora   : 15/12/2003 11:17
Revisao     :
Obs.        :
*/
Function AE100ESTAC
Return AE101ESTAC() // Estah no EECAE101 tiramos do EECAE100 por causa do CH


/*
Funcao      : SumFobItEmb()
Parametros  : cCodAge - Código do Agente.
Retorno     : nTotFob - Total Fob.
Objetivos   : Apurar o valor Fob total dos itens em que o agente está vinculado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/12/2004 14:42
Revisao     :
Obs.        : JPM - Tratamento de Tipo de Comissão por Item - parâmetro cTipCom
              Considera que está posicionado corretamente na work de agentes
*/
*------------------------------------------*
Static Function SumFobItEmb(cCodAge,cTipCom)
*------------------------------------------*
Local nTotFob:=0
Local aOrd:=SaveOrd({"WorkIp"})
Local lFobDescontado := EasyGParam("MV_AVG0086",,.f.)
Local lTipCom := EE9->(FieldPos("EE9_TIPCOM")) > 0
Default cTipCom := ""

Begin Sequence

   If Empty(cCodAge) .Or. (lTipCom .And. Empty(cTipCom))
      Break
   EndIf

   cCodAge := AvKey(cCodAge,"EEB_CODAGE")
   cTipCom := AvKey(cTipCom,"EEB_TIPCOM")

   If !AvFlags("COMISSAO_VARIOS_AGENTES") .Or.;         // faz o loop se não for o tratamento de comissão com mais de um agente por item
      WorkAg->EEB_TIPCVL = "3"  // e se for, só faz o loop se forem agentes de comissão percentual por item,
                                // pois apenas agentes deste tipo são vinculados a itens neste tratamento
      WorkIp->(DbGoTop())
      Do While WorkIp->(!Eof())
         If !Empty(WorkIp->WP_FLAG)
            If (WorkIp->EE9_CODAGE == cCodAge) .And.;
               If(lTipCom,WorkIp->EE9_TIPCOM == cTipCom,.t.)

               nTotFob += WorkIp->EE9_PRCINC - If(lFobDescontado,WorkIp->EE9_VLDESC,0)
            EndIf
         EndIf

         WorkIp->(DbSkip())
      EndDo

   Else
      nTotFob := EECFob(OC_EM) - If(lFobDescontado,M->EEC_DESCON,0)
   EndIf

End Sequence

RestOrd(aOrd)

Return nTotFob

/*
Funcao      : LoadEmbOffShore()
Parametros  : cFil  - Filial atual. A mesma será utilizada para início da leitura dos processos.
              cProc - Nro do processo de embarque.
              lProcOrigem - .t. = Retorna o processo de origem tb, no caso cProc
                            .f. = Não retorna o processo de origem.
Retorno     : aRet  - Array com os números dos embarques que fazem parte dos tratamentos de off-shore de cProc,
                      o sistema irá considerar todos os níveis de off-shore.
Objetivos   : Retornar o número de todos os processos de embarque encontrados nos níveis de off-shore de cProc.
              Obs: Caso a função receba cfil = filial brasil, a função irá retornar tb o processo na filial de off-shore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/04/05 - 11:00.
Obs.        : aRet por dimensão: aRet[1][1] - Filial.
                                     [1][2] - Nro do processo de embarque.
                                     [1][3] - Recno.
*/
*----------------------------------------------*
Function LoadEmbOffShore(cFil,cProc,lProcOrigem)
*----------------------------------------------*
Local aRet := {}, aOrd:=SaveOrd("EEC")
Local cKey

Default lProcOrigem := .f.

Begin Sequence

   // Validações iniciais.
   If !lIntermed .Or. Empty(cFil) .Or. Empty(cProc)
      Break
   EndIf

   If cFil == cFilEx .And. !lMultiOffShore
      Break
   EndIf

   If lProcOrigem
      aAdd(aRet,{EEC->EEC_FILIAL,EEC->EEC_PREEMB,EEC->(RecNo())})
   EndIf

   cFil  := AvKey(AllTrim(Upper(cFil)) ,"EEC_FILIAL")
   cProc := AvKey(AllTrim(Upper(cProc)),"EEC_PREEMB")

   If cFil == cFilBr
      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(cFilEx+EEC->EEC_PREEMB))
         aAdd(aRet,{EEC->EEC_FILIAL,EEC->EEC_PREEMB,EEC->(RecNo())})
      Else
         //aRet:={}
         Break
      EndIf
   EndIf

   EEC->(DbSetOrder(14))
   cKey := cFilEx+cProc

   Do While EEC->(DbSeek(cKey))
      Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL+EEC->EEC_PEDREF == cKey
         If !Empty(EEC->EEC_NIOFFS)
            aAdd(aRet,{EEC->EEC_FILIAL,EEC->EEC_PREEMB,EEC->(RecNo())})
            Exit
         EndIf
         EEC->(DbSkip())
      EndDo
      cKey := cFilEx+EEC->EEC_PREEMB
   EndDo

End Sequence

RestOrd(aOrd,.t.)

Return aRet

/*
Funcao      : AtualizaPesos()
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Verificar se os pesos totais da linha deverá ser calculado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 29/04/05 - 20:15
Obs.        :
*/
*-----------------------------*
Static Function AtualizaPesos()
*-----------------------------*
Local lRet:= .t.
Local aOrd:= SaveOrd({"EE8"})

Begin Sequence

   EE8->(DbSetOrder(1))
   If EE8->(DbSeek(xFilial("EE8")+WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN))
      If EE8->EE8_SLDINI == EE8->EE8_SLDATU
         lRet := .f.
         Break
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Ae100LogSaldo.
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Montagem de log para acerto de saldo.
Autor       : Jeferson Barros Jr.
Data/Hora   : 25/05/05 - 17:15.
Obs.        :
*/
*------------------------------------*
Static Function Ae100LogSaldo(lInclui)
*------------------------------------*
Local lRet := .t., hFile
Local j:=0
Local cBuffer := "", cBody := ENTER, cFile :="saldo.log"

Begin Sequence

   If !File(cFile)
      hFile := EasyCreateFile(cFile)
      If ! (hFile > 0)
         EECMsg(STR0229+Replic(ENTER,2)+; //STR0229	"O arquivo de log dos tratamentos de acerto de saldo não pode ser gerado."
                 STR0230+ENTER+; //STR0230	"Detalhes:"
                 STR0231+cFile+".",STR0063) //STR0231	"Erro na criação do arquivo: " //STR0063	"Aviso"
         lRet:=.f.
         Break
      Endif
      fClose(hFile)
   EndIf

   cBody += "Arquivo de Log - Rotina de acerto de saldo de itens do pedido."+Replic(ENTER,2)
   cBody += "Data    : " + Transf(dDataBase,"  /   /  ")+ENTER
   cBody += "Hora    : " + Time()+ENTER
   cBody += "Item+Seq: " + WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN+Replic(ENTER,2)

   cBody += "Dados Adicionais Proc. Embarque: "+ENTER
   cBody += "Filial   : "+M->EEC_FILIAL+ENTER
   cBody += "Processo : "+M->EEC_PREEMB+ENTER
   cBody += "Ped.Ref. : "+M->EEC_PEDREF+Replic(ENTER,2)

   cBody += "Variáveis : "+ENTER
   cBody += "MV_AVG0023: "+EasyGParam("MV_AVG0023")+ENTER
   cBody += "MV_AVG0024: "+EasyGParam("MV_AVG0024")+ENTER
   cBody += "lIntegra  : "+If(lIntegra,".t.",".f.") +ENTER
   cBody += "lIntermed : "+If(lIntermed,".t.",".f.")+ENTER
   cBody += "xFilial   : "+xFilial()+ENTER
   cBody += "lInclui   : "+If(lInclui,".t.",".f.")+ENTER
   cBody += "Alias     : "+Alias()+Replic(ENTER,2)

   cBody += "Dados Adicionais do EE8: "+ENTER
   cBody += "Chave EE8: "+EE8->(IndexKey())+Replic(ENTER,2)

   cBody += "Campos SM0:"+ENTER
   For j:=1 To SM0->(FCount())
      cBody += IncSpace(SM0->(FieldName(j)),10,.f.)+" : "+Transf(SM0->(FieldGet(j)),"")+ENTER
   Next

   cBody += ENTER

   cBody += "Campos WorkIp - Registro ref. item em processamento:"+ENTER
   cBody += "Indice Atual (Key): "+WorkIp->(IndexKey())+Replic(ENTER,2)
   cBody += "Campos:"+ENTER

   For j:=1 To WorkIp->(FCount())
      cBody += IncSpace(WorkIp->(FieldName(j)),10,.f.)+" : "+Transf(WorkIp->(FieldGet(j)),"")+ENTER
   Next

   cBody += ENTER
   cBody += Replic("*",100)+ENTER

   cBuffer:=MemoRead(cFile)
   MemoWrite(cFile,cBuffer+ENTER+cBody)

End Sequence

Return lRet

/*
Funcao      : Ae100UnLock().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Disparar o MsUnLockAll() para todas as tabelas utilizadas na rotina de embarque.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/06/05 - 11:15.
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function Ae100UnLock()
*---------------------------*
Local lRet:=.t.
Local j:=0
Local aAlias:={}
Local nOldArea := Select()

Begin Sequence

   aAlias := {"EE9","EEM","EEB","EEJ","EEK","EET","EEN","EEO","EEX","EEZ","EES",;
              "EX0","EX1","EX2","EX9","EXA","EXB","EER","EEU","EXI","EXG","EEQ","EE7","EE8","EXL","EXM","EXK"}

   For j:=1 To Len(aAlias)
      If Select(aAlias[j]) > 0
         (aAlias[j])->(MsUnLockAll())
      EndIf
   Next

End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : AE100EstCon()
Parametros  : cTipo = Tipo de estorno.
Retorno     : lRet = True se conseguir estornar todos os eventos
Objetivos   : Tratamento do estorno dos eventos contábeis na integração com SIGAECO.
Autor       : Alessandro Alves Ferreira
Data/Hora   : 09/01/08
Observação  : No Estorno de NF, assume que esteja posicionado o EEM.
*/
*--------------------------------*
Function AE100EstCon(cTipo,cProcesso)
*--------------------------------*
Local lTem101 := .F.
Local cFilECF := xFilial("ECF")
Local cEveUsuario := EasyGParam("MV_ECO0003",,"") //Eventos de Usuário para estorno contábil.

Private cEventos:= ""
Private lRet    := .T.
Private bCond

If ECF->(FieldPos("ECF_TPMODU")) > 0
   cTPMODU:='EXPORT'
   bTPMODUECF := {|| ECF->ECF_TPMODU = 'EXPORT' }
Else
   cTPMODU:=""
   bTPMODUECF := {|| .T. }
EndIf

Default cProcesso := EEC->EEC_PREEMB

Begin Sequence

If cTipo == "ALTERA_DTEMBA"
   cEventos := "101/"+; //Parcela de Invoice a Receber
               "582/"+; //V.C. Invoice(Taxa Subiu)
               "583/"+; //V.C. Invoice(Taxa Desceu)
               "102/"+; //Frete Após o Embarque
               "103/"+; //Seguro após o Embarque
               "120/"+; //Comissão a Remeter após o Embarque
               "121/"+; //Comissão Conta Gráfica após o Embarque
               "122/"+; //Comissão a Deduzir da Fatura após o Embarque
               "127/"+; //Despesas Internas após o Embarque
               "129/"+; //Invoice a Pagar Back To Back
               "570/"+; //V.C. Frete (Taxa Subiu) após Embarque
               "571/"+; //V.C. Frete (Taxa Desceu) após Embarque
               "572/"+; //V.C. Seguro (Taxa Subiu) após Embarque
               "573/"+; //V.C. Seguro (Taxa Desceu) após Embarque
               "574/"+; //V.C. Comissão a Remeter (Taxa Subiu) após o Embarque
               "575/"+; //V.C. Comissão a Remeter (Taxa Desceu) após o Embarque
               "576/"+; //V.C. Comissão Conta Gráfica (Taxa Subiu) após o Embarque
               "577/"+; //V.C. Comissão Conta Gráfica (Taxa Desceu) após o Embarque
               "578/"+; //V.C. Comissão A Deduzir da Fatura (Taxa Subiu) após o Embarque
               "579/"+; //V.C. Comissão A Deduzir da Fatura (Taxa Desceu) após o Embarque
               "542/"+; //V.C. Outras Despesas (Taxa Subiu) após o Embarque
               "543"    //V.C. Outras Despesas (Taxa Desceu) após o Embarque

   bCond := {|| ECF->ECF_ID_CAM $ cEventos }

   ECF->(dbSetOrder(9))
   ECF->(dbSeek(cFilECF+cTPMODU+"EX"+cProcesso))
   Do While ECF->( !EoF() .AND. ECF_FILIAL == cFilECF .AND. ECF_ORIGEM == "EX" .AND.;
                    ECF_PREEMB == cProcesso .AND. Eval(bTPMODUECF) )

      If ECF->ECF_ID_CAM = '101'
         lTem101:=.T.
      EndIf

      ECF->(dbSkip())
   EndDo

   If lTem101 .and. MONTH(M->EEC_DTEMBA) == MONTH(EEC->EEC_DTEMBA) .AND. YEAR(M->EEC_DTEMBA) == YEAR(EEC->EEC_DTEMBA)
      //Não temos tratamento para recalcular variação câmbial de processo com data de embarque alterada para o mesmo mês
      EasyHelp(STR0232) //STR0232	'Ajuste o sistema contábil em relação a este processo...'
      Break
   ElseIf lTem101
      ECG->(dbSetOrder(4))
      If ECG->(dbSeek(xFilial("ECG")+'EXPORT'+'EX'+cProcesso))
         ECG->(RecLock("ECG",.F.))
         ECG->(dbDelete())
         ECG->(MSUnlock())
      EndIf
   EndIf

ElseIf cTipo == "ESTORNA_NF" .OR. cTipo == "ELIMINA_EMBARQUE"

   cEventos := "104/"+;  //Frete Após a NF
               "105/"+;  //Seguro após a NF
               "107/"+;  //NF
               "123/"+;  //Comissão A Remeter após a NF
               "124/"+;  //Comissão Conta Gráfica após a NF
               "125/"+;  //Comissão A Deduzir da Fatura após a NF
               "126/"+;  //Despesas Internas após NF
               "530/"+;  //V.C. Frete (Taxa Subiu) após a NF
               "531/"+;  //V.C. Frete (Taxa Desceu) após a NF
               "532/"+;  //V.C. Seguro (Taxa Subiu) após a NF
               "533/"+;  //V.C. Seguro (Taxa Desceu) após a NF
               "534/"+;  //V.C. Comissão A Remeter (Taxa Subiu) após a NF
               "535/"+;  //V.C. Comissão A Remeter (Taxa Desceu) após a NF
               "536/"+;  //V.C. Comissão Conta Gráfica (Taxa Subiu) após a NF
               "537/"+;  //V.C. Comissão Conta Gráfica (Taxa Desceu) após a NF
               "538/"+;  //V.C. Comissão A Deduzir da Fatura (Taxa Subiu) após a NF
               "539/"+;  //V.C. Comissão A Deduzir da Fatura  (Taxa Desceu) após a NF
               "540/"+;  //V.C. Outras Despesas (Taxa Subiu) após NF
               "541/"+;  //V.C. Outras Despesas (Taxa Desceu) após NF
               "580/"+;  //V.C. NF (Taxa Subiu)
               "581"     //V.C. NF (Taxa Desceu)

   If cTipo == "ESTORNA_NF"
      bCond := {|| ECF->ECF_NRNF == EEM->EEM_NRNF .AND. ECF->ECF_ID_CAM $ cEventos }
   Else
      bCond := {|| ECF->ECF_ID_CAM $ cEventos }
   EndIf
EndIf

If !Empty(cEveUsuario)
   cEventos += "/" + cEveUsuario
EndIf

cEstornados := ""

If(EasyEntryPoint("EECAE100"),ExecBlock("EECAE100",.F.,.F.,"ANTES_ESTORNOS_CONTABEIS"),)

//Code-block pra fazer o loop nos registros do contabil
bExec   := {|cOrigem| ECF->( dbSetOrder(9),;
                             dbSeek(cFilECF+cTPMODU+cOrigem+cProcesso),;
                             dbEval(bDo,bFor,bWhile) ) }

//Verifica existência de outros eventos no contábil
If cTipo == "ELIMINA_EMBARQUE"
   dbSelectArea("ECF")
   ECF->(dbSetOrder(9))

   //Adiciona na string os eventos que já possuem lançamentos de estorno
   bDo    := {|| cEstornados += ECF->ECF_LINK+"/" }
   bFor   := {|| ECF->ECF_ID_CAM == "999" .AND. !(ECF->ECF_ID_CAM $ cEstornados)}
   bWhile := {|| ECF->( !EoF() .AND. ECF_FILIAL == cFilECF .AND. ECF_PREEMB == cProcesso )}

   Eval(bExec,"EX")
   Eval(bExec,"CO")
   Eval(bExec,"  ")

   cRestante := ""

   //Adiciona na string os eventos que não estão sendo tratados no estorno
   bDo := {|| cRestante += STR0125+ECF->ECF_ID_CAM+Chr(13)+Chr(10) }
   bFor:= {|| ECF->(ECF_NR_CON != "9999" .AND. ECF_NR_CON != "0000" .AND. !Empty(ECF_NR_CON) .AND. Empty(ECF_CONTRA) .AND.;
                    !(ECF_ID_CAM $ cRestante+cEstornados+cEventos)) }

   Eval(bExec,"EX")
   Eval(bExec,"CO")
   Eval(bExec,"  ")

   If !Empty(cRestante)
      lRet:= MsgYesNo(STR0126+; //"Existem eventos contábeis que não possuem tratamento para estorno automático:"
                      Chr(13)+Chr(10)+;
                      Chr(13)+Chr(10)+;
                      cRestante+;
                      Chr(13)+Chr(10)+;
                      STR0127)  //"Deseja continuar com a operação de estorno do embarque (podem ficar pendências para estorno manual na contabilidade)?"
      If !lRet
         BREAK
      EndIf
   EndIf

EndIf

//Executa o estorno dos eventos
bDo    := {|| ECF->( AE100EstEvC() ) }
bFor   := bCond
bWhile := {|| ECF->( !EoF() .AND. ECF_FILIAL == cFilECF .AND. ECF_PREEMB == cProcesso )}

Eval(bExec,"EX")
Eval(bExec,"CO")
Eval(bExec,"  ")

End Sequence

Return lRet

/*
Funcao      : AE100EstEvC()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Gravação do evento de estorno dos eventos contábeis na integração com SIGAECO.
Autor       : Alessandro Alves Ferreira
Data/Hora   : 09/01/08
*/
*-----------*
Static Function AE100EstEvC()
*-----------*

//Gravação do evento na tabela de estorno contabil
ECE->(RecLock("ECE",.T.))
ECE->ECE_FILIAL := ECF->ECF_FILIAL
ECE->ECE_HAWB   := ECF->ECF_HAWB
ECE->ECE_PREEMB := ECF->ECF_PREEMB
ECE->ECE_INVOIC := ECF->ECF_INVOIC
ECE->ECE_DI_NUM := ECF->ECF_DI_NUM
ECE->ECE_DT_LAN := ECF->ECF_DTCONT
ECE->ECE_CTA_DB := ECF->ECF_CTA_DB
ECE->ECE_CTA_CR := ECF->ECF_CTA_CR
ECE->ECE_VALOR  := ECF->ECF_VALOR
ECE->ECE_IDENTC := ECF->ECF_IDENTC
ECE->ECE_HOUSE  := ECF->ECF_HAWB
ECE->ECE_ID_CAM := "999"            // Grava evento contabil de estorno 999
ECE->ECE_LINK   := ECF->ECF_LINK

// ** AAF 27/04/07 - Gravação das contas de estorno
If EC6->( FieldPos("EC6_CDEST") > 0 .AND. FieldPos("EC6_CREST") > 0 )
   EC6->(dbSeek(xFilial("EC6")+ECF->ECF_TPMODU+ECF->ECF_ID_CAM+ECF->ECF_IDENTC))
   ECE->ECE_CDBEST := EC6->EC6_CDEST
   ECE->ECE_CCREST := EC6->EC6_CREST
EndIf
// **

/** AAF 27/04/07 - Evento de estorno ainda não foi contabilizado.
ECE->ECE_NR_CON := ECF->ECF_NR_CON
**/

ECE->ECE_DT_EST := Date()
ECE->ECE_MOE_FO := ECF->ECF_MOEDA
ECE->ECE_FORN   := ECF->ECF_FORN
ECE->ECE_SEQ    := ECF->ECF_SEQ
ECE->ECE_TPMODU := ECF->ECF_TPMODU
ECE->ECE_TX_ANT := ECF->ECF_PARIDA
ECE->ECE_TX_ATU := ECF->ECF_FLUTUA
ECE->(MSUnlock())

//Exclusão do evento contábil
ECF->(RecLock("ECF",.F.))
ECF->(dbDelete())
ECF->(MSUnlock())

Return .T.
/*
Funcao      : AeFatSaldo()
Parametros  : cPedido,cSequencia
Retorno     : Lógico .f. ou .t.
Objetivos   : Verifica se existe saldo do item no pedido de venda no faturamento
Autor       : Tiago Luiz Mendonça
Data/Hora   : 31/01/2008
Obs.        : 11:40
*/

Static Function AeFatSaldo(cPedido,cSequencia)

Local lRet:=.F.
Local aOrd:= SaveOrd({"EE7","EE8","SC6","SC9"})
Local nTotal:=0

EE7->(DBSETORDER(1))
EE7->(DBSEEK(XFILIAL("EE7")+cPedido))
IF EE7->(FIELDPOS("EE7_GPV")) == 0 .OR. EE7->EE7_GPV $ cSIM
   If EE8->(Dbseek(xFilial()+cPedido+cSequencia))
      SC6->(dbSetOrder(1))
      IF SC6->(dbSeek(xFilial()+AvKey(EE7->EE7_PEDFAT,"C6_NUM")+AvKey(EE8->EE8_FATIT,"C6_ITEM")))
         SC9->(dbSetOrder(1))
         IF SC9->(dbSeek(xFilial()+AvKey(SC6->C6_NUM,"C9_PEDIDO")+AvKey(SC6->C6_ITEM,"C9_ITEM")))
            Do While SC9->( !EOF() .And. SC9->C9_PEDIDO+SC9->C9_ITEM == SC6->C6_NUM+SC6->C6_ITEM )
               nTotal+= SC9->C9_QTDLIB
               SC9->(DbSkip())
            EndDo
            If (nTotal < SC6->C6_QTDVEN)
               lRet:=.T.
            EndIf
         EndIF
      EndIf
   EndIf
EndIF

RestOrd(aOrd,.T.)

Return lRet
/*
Funcao      : Ae100Insumos()
Parametros  : Nenhum.
Retorno     : Nil
Objetivos   : Manutenção dos Insumos utilizados no Produto a Exportar.
Autor       : Thiago Rinaldi Pinto
Data/Hora   : 16/02/2009
*/
*------------------------------------------*
Static Function AE100Insumos(oObjPai, nPos)
*------------------------------------------*
Local cOldArea := Select()
Local oDlg, oGetEDG
Local nOpcao := 0
Local bOk  := {|| nOpcao := 1 , oDlg:End() }
Local bCancel  := {|| nOpcao := 0 , oDlg:End() }
Local nVlSCob := 0
Local i
Local aEnchEE9 := {"EE9_SEQEMB","EE9_COD_I","EE9_POSIPI","EE9_ATOCON","EE9_SEQED3"}
Local aAltWorkEDG
Local cBack1EDG := CriaTrab(,.F.)

Private aTela[0][0],aGets[0],aHeader[0]

aHeader := {{"Insumo"                  ,  "EDG_ITEM"    , AVSX3("EDG_ITEM",6)   , AVSX3("EDG_ITEM",3)   ,0,nil,nil,"C",nil,nil},;
            {"NCM"                     ,  "EDG_NCM"     , AVSX3("EDG_NCM",6)    , AVSX3("EDG_NCM",3)    ,0,nil,nil,"C",nil,nil},;
            {"Unid. Medida"            ,  "EDG_UNID"    , AVSX3("EDG_UNID",6)   , AVSX3("EDG_UNID",3)   ,0,nil,nil,"C",nil,nil},;
            {"Qtde Insumo"             ,  "EDG_QTD"     , AVSX3("EDG_QTD",6)    , AVSX3("EDG_QTD",3)    ,AVSX3("EDG_QTD",4),'EVAL(AVSX3("EDG_QTD",7)   )',nil,"N",nil,nil},;
            {"Preço Unit US$"          ,  "EDG_PRCUNI"  , AVSX3("EDG_PRCUNI",6) , AVSX3("EDG_PRCUNI",3) ,AVSX3("EDG_PRCUNI",4),'EVAL(AVSX3("EDG_PRCUNI",7)   )',nil,"N",nil,nil},;
            {"Vlr Local Embarque US$"  ,  "EDG_VALEMB"  , AVSX3("EDG_VALEMB",6) , AVSX3("EDG_VALEMB",3) ,AVSX3("EDG_VALEMB",4),nil,nil,"N",nil,nil} }


If Empty(M->EEC_DTEMBA) //.and. Empty(M->EE9_RE) - nopado por WFS em 23/09/09
   aAltWorkEDG:= {"EDG_QTD","EDG_PRCUNI"}
   aAltWorkEDG:= AddCpoUser(aAltWorkEDG,"EDG","1")
Else
   aAltWorkEDG:= {}
Endif

Begin Sequence


   DbSelectArea("WorkEDG")
   //COPY TO (cBack1EDG)
   TETempBackup(cBack1EDG) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   WorkEDG->(dbGoTop())

   WorkEDG->(DbSetFilter({|| EDG_SEQEMB == WORKIP->EE9_SEQEMB },"EDG_SEQEMB =='"+WORKIP->EE9_SEQEMB+"'"))

   WorkEDG->(dbGoTop())

   nOpcao := 0

   // FDR - 15/10/10
   aHeader := AddCpoUser(aHeader,"EDG","4")

   Define MsDialog oDlg Title STR0233 From 9,0 TO 28,110  Of oObjPai //STR0233	"Manutenção de Insumos"

      aPos := PosDlgUp(oDlg)

      oench := Msmget():new("EE9",,3, , , ,aEnchEE9,PosDlgUp(oDlg),{},3,,,,,,,,,.T.)
      oench:obox:align := CONTROL_ALIGN_TOP

      aPos := PosDlgDown(oDlg)

      WorkEDG->(oGetEDG:=MsGetDb():New( aPos[1], aPos[2], aPos[3], aPos[4], nPos, , , ,.F., aAltWorkEDG, , .T.,,"WorkEDG") )

      oGetEDG:oBrowse:BADD := {||.F.}
      oDlg:lMaximized := .T.
      oGetEDG:oBrowse:Refresh()
      oGetEDG:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel)

   If nOpcao == 1

      WorkEDG->(DbGotop())

      While !WorkEDG->(EOF())

         WorkEDG->(RecLock("WorkEDG",.F.))
         WorkEDG->EDG_VALEMB:= (WorkEDG->EDG_QTD * WorkEDG->EDG_PRCUNI)
         WorkEDG->(MsUnlock())

         nVlSCob+= WorkEDG->EDG_VALEMB

         WorkEDG->(DbSkip())

      Enddo


      M->EE9_VLSCOB:= nVlSCob


      nVlSCob:= 0

   Elseif nOpcao == 0

      dbSelectArea("WorkEDG")
      AvZap()
      TERestBackup(cBack1EDG)
      WorkEDG->(DbGoTop())

   Endif

   WorkEDG->(dbclearfilter())

End Sequence

dbselectarea(cOldArea)

SetDlg(oObjPai)  //Seta o foco na dialog dos itens.

Return nil

/*
Funcao      : Ae100GrvInsumos()
Parametros  : Nenhum.
Retorno     : Nil
Objetivos   : Gravação dos Insumos utilizados no Produto Exportado.
Autor       : Thiago Rinaldi Pinto
Data/Hora   : 17/02/2009
*/
*---------------------------------*
Static Function AE100GrvInsumos()
*---------------------------------*
Local lRet:= .T.
Local i
Local lSeek := .F.

Begin Sequence

   If Select("WorkEDG") == 0
      Break
   EndIf

   For i := 1 To Len(aDelEDG)
      EDG->(dbGoTo(aDelEDG[i]))
      EDG->(RecLock("EDG",.F.))
      EDG->(dbDelete())
      EDG->(MsUnlock())
   Next

   WorkEDG->(DbGoTop())
   While WorkEDG->(!Eof())
      If WorkEDG->EDG_RECNO > 0
         EDG->(dbGoTo(WorkEDG->EDG_RECNO))
      Endif
      If WorkEDG->EDG_FLAG
         //AOM - 15/07/2010 - Adicionado o codigo do Item "WorkEDG->EDG_ITEM" no indice para que seja gravado todos os insumos
         lSeek := WorkEDG->EDG_RECNO == 0 .AND. !dbSeek(xFilial("EDG")+M->EEC_PREEMB+WorkEDG->EDG_SEQEMB+WorkEDG->EDG_ITEM)
         If EDG->(RecLock("EDG", lSeek ))
            AvReplace("WorkEDG","EDG")
            EDG->EDG_FILIAL := xFilial("EDG")
            EDG->EDG_PREEMB := M->EEC_PREEMB
         EDG->(MsUnlock())
         EndIf
      Else
         WorkEDG->(DbSkip())
         Loop
      Endif

      WorkEDG->(DbSkip())
   EndDo

End Sequence

Return lRet

/*
Função     : AE100LoadEDG
Parâmetros : Nenhum
Retorno    : lRet = .T. ou .F.
Objetivos  : Gravação da WorkEDG com os dados da tabela EDG
Autor      : Thiago Rinaldi Pinto
Data/Hora  : 17/02/2009
*/
*---------------------*
Function AE100LoadEDG()
*---------------------*
Local lRet := .T.

Begin Sequence

   If Select("WorkEDG") == 0
      Break
   EndIf

   aDelEdg := {}

   EDG->(DbSetOrder(1))
   If EDG->(DbSeek(xFilial("EDG")+M->EEC_PREEMB))
      While EDG->(!EOF()) .and. EDG->(EDG_FILIAL + EDG_PREEMB) == xFilial("EDG")+M->EEC_PREEMB

         WorkEDG->(DbAppend())

         AvReplace("EDG", "WorkEDG")
         WorkEDG->EDG_RECNO := EDG->(RecNo())
         WorkEDG->EDG_FLAG  := .T.

         EDG->(DbSkip())

      EndDo
   Endif
End Sequence

Return lRet

/*
Função     : VldOpeAE100
Parâmetros : cParam - informa o trecho que será feito o tratamento de operação especial
Retorno    : lRet = .T. ou .F.
Objetivos  : Efetuar os tratamentos de operações especiais
Autor      : Allan Oliveira Monteiro
Data/Hora  : 27/04/2011
*/
*---------------------------*
Function VldOpeAE100(cParam)
*---------------------------*
Local lRet := .T. , lSeek := .F.

Begin Sequence

   If !AvFlags("OPERACAO_ESPECIAL")
      Break
   EndIf


   DO CASE

      CASE cParam == "EXC_EMB"

         EE9->(DbSetOrder(3))//EE9_FILIAL + EE9_SEQEMB
         WorkIp->(DbGoTop())

         DO WHILE WorkIp->(!EOF())

            lSeek := EE9->(DbSeek(xFilial("EE9") + WorkIp->EE9_PREEMB + WorkIp->EE9_SEQEMB ))
            If lSeek .And. !Empty(EE9->EE9_CODOPE)
               If !oOperacao:InitOperacao(EE9->EE9_CODOPE, "EE9", {{"EE9","EE9"},{"EEC","EEC"}},.F.,.T.,cParam)//Estorno
                  lRet:= .F.
                  Break
               EndIf
            EndIf

         WorkIp->(DbSkip())
         ENDDO


      CASE cParam == "DESMARC_IT"


         If !Empty(WorkIP->WP_FLAG) .And. !Empty(WorkIP->EE9_CODOPE)
            If !oOperacao:InitOperacao(WorkIP->EE9_CODOPE, "EE9", {{"EE9","WorkIP"},{"EEC","M"}},.F.,.T.,cParam)//Estorno
               lRet:= .F.
               Break
            EndIf
         EndIf


      CASE cParam == "MARC_ITS_EMB"

         If Empty(WorkIP->WP_FLAG) .And. !Empty(M->EE9_CODOPE)
            If !oOperacao:InitOperacao(M->EE9_CODOPE, "EE9", {{"EE9","M"},{"EEC","M"}},.T.,.T.,cParam)//Inclusão
               lRet:= .F.
               Break
            EndIf
         EndIf


   ENDCASE

End Sequence

Return lRet

/*
Função      : FilterX3Brw(cAlias, oDlg, cFilter, lSetFilter)
Parametros  : cAlias - Work onde o filtro será aplicado.
              oDlg - Tela onde a interface será inserida.
              cFilter - Filtro atual.
              lSetFilter - Indica se o filtro será aplicado na tabela.
Retorno     : cFilter - Filtro montado pelo usuário.
Objetivos   : Exibir tela para montagem de filtro.
Autor       : Tamires Daglio Ferreira
Data/Hora   : 16/03/11
*/
Static Function FilterX3Brw(cAlias, oDlg, cPedido)
Local nInc, aCampos := {}, cCampo
Local cFiltroBase := ""
Local cExpFiltro := ""

   // *** Define os campos que serão exibidos no filtro
   For nInc := 1 To Len(aItemEnchoice)
      cCampo := aItemEnchoice[nInc]
      aAdd(aCampos, {cCampo, AvSx3(cCampo, AV_TITULO), .T., StrZero(nInc, 2), AvSx3(cCampo, AV_TAMANHO), "", AvSx3(cCampo, AV_TIPO), AvSx3(cCampo, AV_DECIMAL) })
   Next
   // ***
   If cPedido != "TODOS"
      cFiltroBase := 'EE9_PEDIDO == "' + cPedido + '" '
   EndIF
   // *** Exibe a tela de filtro
   (cAlias)->(DbClearFilter())
   cExpFiltro := BuildExpr(cAlias, oDlg, cUserFiltroEE9, , , , , , , ,aCampos)
   cUserFiltroEE9 := cExpFiltro
   // ***

   // *** Aplica o filtro
   (cAlias)->(DbClearFilter())
   cFiltro := cFiltroBase + If(Empty(cExpFiltro), "", If(Empty(cFiltroBase),cExpFiltro,".And. " + cExpFiltro))
   If Empty(cFiltro)
      cFiltro := '.T.'
   EndIF
   (cAlias)->(DbSetFilter(&("{|| " + cFiltro + "}"), cFiltro))
   (cAlias)->(DbGoTop())
   // ***


Return cFiltro

/*
Funcao      : AE100EEMGrv(cPedido,cSequen,cNota,cSerie)
Parametros  :
Retorno     : nenhum
Objetivos   : Efetuar a gravao do campo EEM_PREEMB e EES_PREEM em suas respectivas tabelas
Autor       : Felipe Sales Martinez
Data/Hora   : 17/01/2012 11:50
Revisao     :
Data/Hora   :
Obs.        :
*/
Static Function AE100EEMGrv(cPedido,cSequen,cNota,cSerie)
Local aOrd := SaveOrd({"EEM","EES"})

Begin Sequence

   EEM->(dbSetOrder(1)) // FILIAL + PREEMB + TIPOCA + NRNF + TIPONF
   If EEM->(dbSeek(xFilial()+AvKey("","EEM_PREEMB")+EEM_NF+AvKey(cNota , "EEM_NRNF")))
      If EEM->(RecLock("EEM",.F.))
         EEM->EEM_PREEMB:= EEC->EEC_PREEMB
         EEM->(MsUnlock())
      EndIf
   EndIf

   EES->(dbSetOrder(1))//EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE+EES_PEDIDO+EES_SEQUEN
   If !AVFLAGS("EEC_LOGIX")
      IF EES->(dbSeek(xFilial()+AvKey("","EES_PREEMB")+AvKey(cNota , "EES_NRNF")+AvKey(cSerie , "EES_SERIE")+AvKey(cPedido,"EES_PEDIDO")+AvKey(cSequen , "EES_SEQUEN")))

         If EES->(RecLock("EES", .F.))
            EES->EES_PREEMB := EEC->EEC_PREEMB
            EES->(MsUnlock())
         EndIf

      EndIf
   Else

      Do While EES->(dbSeek(xFilial()+AvKey("","EES_PREEMB")+AvKey(cNota , "EES_NRNF")+AvKey(cSerie , "EES_SERIE")+AvKey(cPedido,"EES_PEDIDO")+AvKey(cSequen , "EES_SEQUEN")))
         If EES->(RecLock("EES", .F.))
            EES->EES_PREEMB := EEC->EEC_PREEMB
            EES->(MsUnlock())
            AE102ESSEYY("1",EES->EES_PREEMB)     //NCF - 21/11/2017
         EndIf
      EndDo

   EndIf

End Sequence

RestOrd(aOrd)

Return NIL


Static Function AE100EstAdi()
Local lOk := .T.
Local aOrd := SaveOrd({"EEQ"})

   EEQ->(DbSetOrder(6))
   If EEQ->(DbSeek(xFilial("EEQ")+"E"+M->EEC_PREEMB))
      Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                   EEQ->EEQ_FASE   == "E" .And.;
                                   EEQ->EEQ_PREEMB == M->EEC_PREEMB .And. lOk

         ///////////////////////////
         //Parcela de Adiantamento//
         ///////////////////////////
         If EEQ->EEQ_TIPO == "A" .AND. !Empty(EEQ->EEQ_FINNUM)
           	// "078" - "Compensação do Adiantamento"
			// "079" - "Estorno da Compensação do Adiantamento"
			// Obs: a Compensação esta sendo realizado quando o campo EEQ_FINNUM esta sendo preenchido no adapter de recebimento do numero do financiamento
            lOk := AvStAction("079")
         EndIf

         EEQ->(DbSkip())
      EndDo
   EndIf

   RestOrd(aOrd,.T.)
Return lOk

Static Function AE100GerCom(lEstorno)
Local lOk := .T.
Local aOrd := SaveOrd({"EEQ"})
Default lEstorno := .F.

   EEQ->(DbSetOrder(6))
   If EasyGParam("MV_EEC0025",,.T.) .AND. EEQ->(DbSeek(xFilial("EEQ")+"E"+M->EEC_PREEMB))
      Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                   EEQ->EEQ_FASE   == "E" .And.;
                                   EEQ->EEQ_PREEMB == M->EEC_PREEMB

         ///////////////////////////////////////
         //Parcela de Comissao Deduz/C.Grafica//
         ///////////////////////////////////////
         If EEQ->EEQ_EVENT == "122"// .AND. (!lEstorno .AND. Empty(EEQ->EEQ_FINNUM) .OR. lEstorno .AND. !Empty(EEQ->EEQ_FINNUM))
            lOk := AvStAction(if(lEstorno,"086","087")) //Estorno de baixa, pois comissão a deduzir é automaticamente baixada na inclusao.
		    //NOPADO - THTS - 31/10/2019 - Retirado o tratamento da Conta Grafica, pois o sistema nao esta preparado para fazer corretamente os tratamentos de conta grafica no Logix
            //ElseIf EEQ->EEQ_EVENT == "121" //AAF 13/07/2015 - Tratamento para receita referente a parcela de comissão conta grafica.
		    //   lOk := AvStAction(if(lEstorno,/*'012'*/"088",/*'010'*/"087")) //Estorno de título, pois comissão conta grafica fica pendente de baixa pela usuário. // NCF - 15/06/2016 - Conta Gráfica controla como Contas a Pagar
         EndIf

         EEQ->(DbSkip())
      EndDo
   EndIf

   RestOrd(aOrd,.T.)
Return lOk

/*
Funcao      : AE100GetEmpr(cPreemb,cTipoEmpresa,cRetorno)
Parametros  :
Retorno     : Genérico
Objetivos   : Retornar informações sobre empresas utilizadas no embarque de exportação.
Autor       : Alessandro Alves Ferreira
Data/Hora   : 01/08/2012 11:50
Revisao     :
Data/Hora   :
Obs.        : Caso não encontre a empresa, posiciona em fim de arquivo para que o retorno seja em branco.
*/

Function AE100GetEmpr(cPreemb,cTipoEmpresa,cRetorno)
Local uRet
Local aCodEmpr := {"EXL_EMFR","EXL_EMSE","EXL_EMFA","EXL_EMDI"}
Local i
Local lOk := .F.

EXL->(dbSetOrder(1))
SY5->(dbSetOrder(1))

If EXL->(dbSeek(xFilial("EXL")+cPreemb))
   For i := 1 To Len(aCodEmpr)
      If SY5->(dbSeek(xFilial("SY5")+EXL->(&(aCodEmpr[i]))) .AND. Left(Y5_TIPOAGE,1) == cTipoEmpresa)
	     lOk := .T.
		 EXIT
	  EndIf
   Next i
EndIf
If !lOk
   SY5->(dbGoBottom())
   SY5->(dbSkip())
EndIf

uRet := SY5->( &(cRetorno) )

Return uRet

/*
Funcao      : AE100F11()
Parametros  : Nenhum
Retorno     : lRet -> .T./.F.
Objetivos   : Efetuar a gravao do campo EEM_PREEMB e EES_PREEM em suas respectivas tabelas
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 02/08/2012 17:00
*/
Function AE100F11()
Local lRet    := .F.
Local nLin    := 30, nCol := 12 //WHRS TE-5151 - 508022 / MTRADE-647 / 766- Ao clicar em F11 apresenta a tela sobreposta no Embarque
Local bOk     := {|| lRet := .T., oDlg:End() }, bCancel := {|| oDlg:End() }
Local oDlg
Local cTitulo   := STR0235 //#"Configuração de Parâmetros do Embarque"
Local cNatureza := EasyGParam("MV_AVG0178",,"EASY")

cNatureza += Space( AvSx3("A1_NATUREZ",AV_TAMANHO)-Len(cNatureza) )

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 1,1 To 150,400 OF oMainWnd PIXEL //WHRS TE-5151 - 508022 / MTRADE-647 / 766- Ao clicar em F11 apresenta a tela sobreposta no Embarque

      @ nLin, 6 To 65, 192 Label STR0236 Of oDlg Pixel //#"Paramêtros" //WHRS TE-5151 - 508022 / MTRADE-647 / 766- Ao clicar em F11 apresenta a tela sobreposta no Embarque
      nLin += 10

      @ nLin,nCol Say STR0237 Size 250,08 PIXEL OF oDlg //#"Código da Natureza utilizada nos títulos de RA:"
      nLin += 10

      @ nLin,nCol MSGET cNatureza Size 55,08  F3 "SED" PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If lRet
      SetMv("MV_AVG0178", cNatureza )
   EndIf

Return lRet

Static Function AE100DespPr(lElimina)
Local aDespInt  := X3DIReturn()
Local z         := 0
Local nInc      := 0
Local lGeraTit  := .F.
Local lGerouTit := .F.
Local aCposInt  := {}
Local cCondPag  := ""
Local cCondPagCb := ""
Local aParcDI   := {}
Local lAltValPosEmb := EasyGParam("MV_AVG0081",,.f.)
Local lRet := .T.
Local cEvento
Local aAreaSE2 := SE2->(GetArea())
Private cC6_TXCV
Private cMoeda    := ""
Private cTitFin   := ""
Private cFinNum   := ""
Private cParcFin  := ""
Private cNatFin   := ""
Private cTipTit   := ""
Private cFinForn  := ""
Private cFinLoja  := ""
Private nMoeFin   := 0
Private nValorFin := 0
Private dDtEmis
Private dDtVenc
Private cUltParc := ""  // GFP - 21/01/2014
Default lElimina := .F.

Begin Sequence

   ///////////////////////////////////////////////////////////////////////////////////////
   //Caso a data de embarque não tenha sido preenchida, irá gerar os títulos provisórios//
   //das despesas internacionais.                                                       //
   ///////////////////////////////////////////////////////////////////////////////////////
   If EXL->(FieldPos("EXL_TITFR")) > 0 .And. Empty(M->EEC_DTEMBA)

      For z := 1 To Len(aDespInt)
         Do Case
            Case aDEspInt[z][1] == "FR"
               cEvento := "102"
            Case aDEspInt[z][1] == "SE"
               cEvento := "103
            Case aDEspInt[z][1] == "FA"
               cEvento := "333"
            Case aDEspInt[z][1] == "DI"
               cEvento := "411"
         EndCase

         If cEvento != nil
            cC6_TXCV := Posicione("EC6",1,xFilial("EC6")+"EXPORT"+ cEvento,"EC6_TXCV")
         Endif   

         If Type("M->EXL_TIT"+aDespInt[z][1]) <> "U"
            lGeraTit := .F.
            aCposInt := {"EXL_MD"+aDespInt[z][1],"EXL_VD"+aDespInt[z][1],"EXL_EM"+aDespInt[z][1],"EXL_CP"+aDespInt[z][1],"EXL_DT"+aDespInt[z][1],"EXL_NAT"+aDespInt[z][1]}
            cFinNum  := AvKey(EXL->&("EXL_TIT"+aDespInt[z][1]),"E2_NUM")
            cFinForn := AvKey(EXL->&("EXL_FO" +aDespInt[z][1]),"E2_FORNECE")
            cFinLoja := AvKey(EXL->&("EXL_LF" +aDespInt[z][1]),"E2_LOJA")
            If !Empty(cFinNum)
               /////////////////////////////////////////////////////////////////////////////////////
               //Verifica se houve alterações significativas para que seja incluido um novo título//
               /////////////////////////////////////////////////////////////////////////////////////
               If AvGeraTit("M","EXL",aCposInt) .Or. lElimina
                  SE2->(DbSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
                  If SE2->(DbSeek(xFilial("SE2") + cFinForn + cFinLoja + AvKey("EEC","E2_PREFIXO") + cFinNum))
                     While SE2->(!EOF()) .and. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == xFilial("SE2") + cFinForn + cFinLoja + AvKey("EEC","E2_PREFIXO") + cFinNum
                        If SE2->E2_TIPO == AvKey("PR","E2_TIPO")
                           If lRet := AvStAction("018") //Exclusão do título provisório de desp. internacional
                              lGeraTit := .T.
                           Else
                              Break
                           EndIf
                           ///////////////////////////////////////
                           //Zera o campo com o número do título//
                           ///////////////////////////////////////
                           M->&("EXL_TIT"+aDespInt[z][1]) := ""
                        EndIf
                        SE2->(DbSkip())
                     EndDo
                  EndIf
               EndIf
            Else
               lGeraTit := .T.
            EndIf

            If !lElimina .And. lGeraTit
               If M->&("EXL_VD"+aDespInt[z][1]) > 0 .and. EasyGParam("MV"+SubStr(aDespInt[z][2], 4), .T.) //Verifica se existe valor e o parametro para Despesa.
                  cCondPag := M->&("EXL_CP"+aDespInt[z][1])+Str(M->&("EXL_DP"+aDespInt[z][1]), 3)
                  //////////////////////////////////////////////////////////////////////////////////////
                  //Gera as parcelas de cada despesa, de acordo com a condição de pagamento da despesa//
                  //////////////////////////////////////////////////////////////////////////////////////
                  aParcDI  := AF200GPCD( M->&("EXL_VD"+aDespInt[z][1]),;  //Valor.
                                         If(Empty(M->&("EXL_CP"+aDespInt[z][1])), M->(EEC_CONDPA+Str(EEC_DIASPA, 3)), cCondPag),; //Cond.Pagto.
                                         M->(Eval({|x| If(Empty(x), dDataBase, x)}, &("EXL_DT"+aDespInt[z][1]))),; //Data Base.
                                         EasyGParam("MV"+SubStr(aDespInt[z][2], 4)),; //Evento.
                                         M->&("EXL_FO"+aDespInt[z][1]),; //Fornecedor
                                         M->&("EXL_LF"+aDespInt[z][1]),; //Loja
                                         M->&("EXL_EM"+aDespInt[z][1])) //Empresa

                  cTitFin   := EECGetFinN()
                  //////////////////////////////////////////////////////////
                  //Gera os títulos provisórios de despesas internacionais//
                  //////////////////////////////////////////////////////////
                  lGerouTit := .F.

                  For nInc := 1 To Len(aParcDI)
                     cParcFin  := EasyGetParc(nInc)   // GFP - 21/01/2014  //AllTrim(Str(nInc))
                     cTipTit   := "PR"
                     cFinForn  := M->&("EXL_FO"+aDespInt[z][1])
                     cFinLoja  := M->&("EXL_LF"+aDespInt[z][1])
                     cNatFin   := M->&("EXL_NAT"+aDespInt[z][1])
                     dDtEmis   := M->(Eval({|x| If(Empty(x), dDataBase, x)}, &("EXL_DT"+aDespInt[z][1])))
                     dDtVenc   := aParcDi[nInc][2]
                     nValorFin := aParcDi[nInc][1]
                     cMoeda    := M->&("EXL_MD"+aDespInt[z][1])

                     If BuscaMoeFin(M->&("EXL_MD"+aDespInt[z][1]),dDtEmis) .and. !Empty(SYE->YE_MOE_FIN)
                        nMoeFin := Val(SYE->YE_MOE_FIN)
                     EndIf

                     cCondPagCb := If(Empty(M->&("EXL_CP"+aDespInt[z][1])), M->(EEC_CONDPA+Str(EEC_DIASPA, 3)), cCondPag) //MCF - 20/01/2017
                     SY6->(DbSetOrder(1))
                     SY6->(dbSeek(xFilial()+cCondPagCb))

                     If EasyGParam("MV_AVG0081",, .F.)
                        If !Empty(cFinForn) .And. !Empty(cFinLoja) .And. !Empty(cNatFin) .And. !Empty(dDtEmis) .And. !Empty(dDtVenc) .And. !Empty(nValorFin) .And. !Empty(cMoeda) .And. SY6->Y6_MDPGEXP <> "006"
                           If EasyGParam("MV_EEC0008",, .T.)  // GFP - 16/01/2013                           
                              If lRet := AvStAction("017") //Inclusão do título provisório de desp. internacional
                                 lGerouTit := .T.
                              Else
                                 Break
                              EndIf
                           Else
                              Break
                           EndIf    // Fim GFP - 16/01/2013
                        EndIf
                     ElseIf SY6->Y6_MDPGEXP <> "006"
                        If EasyGParam("MV_EEC0008",, .T.)  // GFP - 16/01/2013
                           If lRet := AvStAction("017") //Inclusão do título provisório de desp. internacional
                              lGerouTit := .T.
                           Else
                              Break
                           EndIf
                        Else
                           Break
                        EndIf    // Fim GFP - 16/01/2013
                     EndIf
                  Next
                  ///////////////////////////////////////////////
                  //Se gerou ao menos um título, grava o número//
                  ///////////////////////////////////////////////
                  If lGerouTit
                     M->&("EXL_TIT"+aDespInt[z][1]) := cTitFin
                  EndIf
               EndIf
            EndIf
         EndIf
      Next

   ElseIf EXL->(FieldPos("EXL_TITFR")) > 0
      ///////////////////////////////////////////////////////////////////////////////////////
      //Apaga os títulos provisórios de despesas internacionais para a geração dos efetivos//
      ///////////////////////////////////////////////////////////////////////////////////////
      For z := 1 To Len(aDespInt)
         If Type("M->EXL_TIT"+aDespInt[z][1]) <> "U"
            cFinNum  := AvKey(EXL->&("EXL_TIT"+aDespInt[z][1]),"E2_NUM")
            cFinForn := AvKey(EXL->&("EXL_FO" +aDespInt[z][1]),"E2_FORNECE")
            cFinLoja := AvKey(EXL->&("EXL_LF" +aDespInt[z][1]),"E2_LOJA")
            If !Empty(cFinNum)
               SE2->(DbSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
               If SE2->(DbSeek(xFilial("SE2") + cFinForn + cFinLoja + AvKey("EEC","E2_PREFIXO") + cFinNum))
                  While SE2->(!EOF()) .and. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == xFilial("SE2") + cFinForn + cFinLoja + AvKey("EEC","E2_PREFIXO") + cFinNum
                     If SE2->E2_TIPO == AvKey("PR","E2_TIPO")
                        If lRet := AvStAction("018") //Exclusão do título provisório de desp. internacional
                           lGeraTit := .T.
                        Else
                           Break
                        EndIf
                     EndIf
                     SE2->(DbSkip())
                  EndDo
               EndIf
               ///////////////////////////////////////
               //Zera o campo com o número do título//
               ///////////////////////////////////////
               M->&("EXL_TIT"+aDespInt[z][1]) := Space(AvSX3("EXL_TIT"+aDespInt[z][1],AV_TAMANHO))
            EndIf
            If Empty(cFinNum) .And. lAltValPosEmb //DFS - 30/12/10 - Chamada de verificação da geração de titulos
               lGeraTit := .T.
            EndIf
         EndIf
      Next
   EndIf

End Sequence
RestArea(aAreaSE2)
Return lRet

Static Function AE100DespNac()
Local lRet := .T.
Local aOrd := SaveOrd("EET")
Private cTipoTit // LRS 18/11/2013 - Deletar embarque com despesas nacionais

EET->(DbSetOrder(1)) // EET_FILIAL+EET_PEDIDO+EET_OCORRE
If EET->(DbSeek(xFilial("EET")+AvKey(EEC->EEC_PREEMB,"EET_PEDIDO")+AvKey(OC_EM,"EET_OCORRE")))
   Do While !EET->(Eof()) .And. EET->(EET_FILIAL+EET_PEDIDO+EET_OCORRE) == xFilial("EET")+AvKey(EEC->EEC_PREEMB,"EET_PEDIDO")+AvKey(OC_EM,"EET_OCORRE")
      If EET->(FieldPos("EET_FINNUM")) > 0 .And. !Empty(EET->EET_FINNUM)
         SE2->(DbSetOrder(1)) //LRS 18/11/2013
         	If SE2->(DbSeek(xFilial("SE2")+AvKey("EEC","E2_PREFIXO")+AvKey(EET->EET_FINNUM,"E2_NUM")))
          		cTipoTit := SE2->E2_TIPO//LRS 18/11/2013
          		EET->(RecLock("EET", .F.))//LRS 18/11/2013
				If !(lRet := AvStAction("016"))
					EET->(MsUnlock())//LRS 18/11/2013
            		Exit
         		EndIf
         		EET->(MsUnlock())//LRS 18/11/2013
            EndIf
      EndIf
      EET->(DbSkip())
   EndDo
EndIf

RestOrd(aOrd)

Return lRet

/*
Funcao      : AE100VlrSCob()
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 12/11/2012
*/
*------------------------*
Function AE100VlrSCob()
*------------------------*

If M->EEC_MPGEXP == "006"
   nTotVlrSCob := M->EEC_TOTPED
Else
   nTotVlrSCob := 0
EndIf

Return Nil

/*
Programa   : AE100ESS()
Objetivo   : Integrar o embarque ao módulo SIGAESS (Easy Siscoserv) para geração do processo de aquisição e da invoice relativo a cada despesa internacional do embarque
Parâmetros : cEmb - Embarque, nOpc - Operação a ser realizada
Autor      : Rafael Ramos Capuano
Data       : 09/08/2013 - 10:20
Revisão    : 13/12/2013 - 13:42
*/

Function AE100ESS(cEmb,nOpc)
Local aCab          := {}
Local aDocs         := {} //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
Local aOrd          := SaveOrd({"EXL","EJW","SYB","EEC","EEQ"})
Local aItens        := {}
Local cCodDesp      := ""
Local cCodAux       := ""
Local cProc         := ""
Local lExistProc    := .F.
Local lAtuaProc     := .F.
Local nOpcAux       := nOpc
Local nRecEEC       := EEC->(Recno())
Local nRecEXL       := EXL->(Recno())
Local nRecEEQ       := EEQ->(Recno())
Local cEvComiss     := ""
Local cInvoice      := AvKey(EEC->EEC_NRINVO,"EEQ_NRINVO")
Local cPreemb       := AvKey(EEC->EEC_PREEMB,"EEQ_PREEMB")
Local aOrdEEQ       := {}
Default cEmb        := ""
Private lMsErroAuto := .F.
Private cCodPrdEC6  := ""
EEC->(DbSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
EXL->(DbSetOrder(1)) //EXL_FILIAL + EXL_PREEMB
EJW->(DbSetOrder(1)) //EJW_FILIAL + EJW_TPPROC + EJW_PROCES
SYB->(DbSetOrder(1)) //YB_FILIAL  + YB_DESP
If SIX->(dbSeek("EEB2"))
   EEB->(DbSetOrder(2)) //EEB_FILIAL + EEB_PEDIDO + EEB_OCORRE + EEB_FORNEC + EEB_LOJAF + EEB_TIPOAG + EEB_TIPCOM
EndIf
EC6->(DbSetOrder(1)) //EC6_FILIAL + EC6_TPMODU + EC6_ID_CAM + EC6_IDENTC

Begin Sequence
If Empty(cEmb) .Or. ValType(nOpc) <> "N" .Or. !(EXL->(FieldPos("EXL_NBSFR")) > 0 .And. EXL->(FieldPos("EXL_NBSSE")) > 0 .And. EXL->(FieldPos("EXL_NBSFA")) > 0) .Or. !EXL->(DbSeek(xFilial("EXL")+AvKey(cEmb,"EXL_PREEMB")))
   Break
EndIf

//RRC - 17/12/2013 - Verifica se existe algum processo de serviços cuja despesa já foi excluída do embarque
//A chave do Processo é composta pelo Processo do Embarque mais o caractere "/" e o código da despesa, logo verifica todos os processos que podem ter sido
//gerados por esse embarque, por isso o uso do AllTrim()
If EJW->(DbSeek(xFilial("EJW")+"A"+AllTrim(cEmb))) .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEEC"
   Do While EJW->(!Eof()) .And. EJW->EJW_FILIAL == xFilial("EJW") .And. EJW->EJW_TPPROC == "A" .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEEC" .And. AllTrim(cEmb) == SubStr(EJW->EJW_PROCES,1,Len(AllTrim(cEmb)))
      cCodDesp := SubStr(EJW->EJW_PROCES,Len(AllTrim(cEmb))+2,AvSx3("YB_DESP",AV_TAMANHO))
      If !(cCodDesp $ "120/121/122")
         If !EXL->(DbSeek(xFilial("EXL")+AvKey(cEmb,"EXL_PREEMB")))
            cCodDesp := SubStr(EJW->EJW_PROCES,Len(AllTrim(cEmb))+2,AvSx3("YB_DESP",AV_TAMANHO))
            Do Case
               Case cCodDesp == "102"
                  cCodAux := "FR"
               Case cCodDesp == "103"
                  cCodAux := "SE"
               Case cCodDesp == "333"
                  cCodAux := "FA"
               Case cCodDesp == "411"
                  cCodAux := "DI"
            EndCase
            aCab   := MontaCapa(cCodAux,EXCLUIR,EJW->EJW_PROCES)
            aItens := MontaItens(cCodAux,EXCLUIR,cCodDesp,EJW->EJW_PROCES)
            If AeGerParc(cCodAux,EXCLUIR,EJW->EJW_PROCES) .And. AeGerInv(cCodAux,EXCLUIR,EJW->EJW_PROCES)
               MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,EXCLUIR)
            EndIf
         EndIf
      Else
         /*NCF - 06/10/2015 - [P1] - Verificação de Agentes/Comissões exclusos do embarque */
         cCodAux := cCodDesp
         If !EEB->(DbSeek( xfilial("EEB") + AvKey(cEmb,"EEB_PEDIDO") + AvKey("Q","EEB_OCORRE") + AvKey(EJW->EJW_EXPORT,"EEB_FORNEC" ) + AvKey(EJW->EJW_LOJEXP,"EEB_LOJAF" ) + AvKey("3-AGENTE (RECEBEDOR COMIS","EEB_TIPOAG")  + AvKey(If(cCodDesp == '120','1', If(cCodDesp=='121','2','3') ),"EEB_TIPCOM")  ))
            aCab   := MontaCapa(cCodAux,EXCLUIR,EJW->EJW_PROCES)
            aItens := MontaItens(cCodAux,EXCLUIR,cCodDesp,EJW->EJW_PROCES)
            If AeGerParc(cCodAux,EXCLUIR,EJW->EJW_PROCES) .And. AeGerInv(cCodAux,EXCLUIR,EJW->EJW_PROCES)
               MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,EXCLUIR)
            EndIf
         EndIf

      EndIf
      EJW->(DbSkip())
   EndDo
EndIf

//A integração somente ocorrerá caso hajam despesas internacionais
If !EEC->(DbSeek(xFilial("EEC")+cEmb)) .Or. Empty(EEC->EEC_DTEMBA)
   nOpc := EXCLUIR
EndIf

//Despesa Internacional de Frete
If SYB->(DbSeek(xFilial("SYB")+"102")) //Pesquisa se existe a despesa de frete
   cCodDesp := AllTrim(SYB->YB_DESP)
Else
   cCodDesp := ""
EndIf
cProc := AllTrim(      If( Empty(EEC->EEC_PREEMB), M->EEC_PREEMB,  EEC->EEC_PREEMB    ))+"/"+cCodDesp  //NCF - 07/10/2015 - [Cod. Preventivo] - Verificar porque o EEC->EEC_PREEMB está vazio neste ponto.

If !Empty(cCodDesp)
   lExistProc := EJW->(DbSeek(xFilial("EJW")+"A"+AvKey(cProc,"EJW_PROCES"))) .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEEC"
   lAltProc   := (nOpc == ALTERAR .And. !((Empty(EXL->EXL_VDFR) .Or. Empty(EXL->EXL_NBSFR) .Or. Empty(EXL->EXL_FOFR) .Or. Empty(EXL->EXL_LFFR) .Or. Empty(EXL->EXL_PAFR)) .And. !lExistProc))

   If (nOpc == INCLUIR .And. !Empty(EEC->EEC_DTEMBA) .And. !Empty(EXL->EXL_VDFR) .And. !Empty(EXL->EXL_NBSFR) .And. !Empty(EXL->EXL_FOFR) .And. !Empty(EXL->EXL_LFFR) .And. !Empty(EXL->EXL_PAFR)) .Or. lAltProc .Or. (nOpc == EXCLUIR .And. lExistProc)
      //Caso esteja alterando o embarque retirando o valor da despesa e o processo equivalente já tiver sido cadastrado no SIGAESS, será realizada a exclusão do mesmo
      //Se estiver alterando o embarque incluindo um valor da despesa, ou seja, processo ainda não gerado no SIGAESS, o sistema já entende que é uma inclusão
      //Verifica campos obrigatórios para o Processo no SIGAESS
      If nOpc == ALTERAR .And. (Empty(EXL->EXL_VDFR) .Or. Empty(EXL->EXL_NBSFR) .Or. Empty(EXL->EXL_FOFR) .Or. Empty(EXL->EXL_LFFR) .Or. Empty(EXL->EXL_PAFR))
         nOpcAux := EXCLUIR
      Else
         nOpcAux := nOpc
      EndIf
      aCab    := MontaCapa("FR",nOpcAux,cProc)
      aItens  := MontaItens("FR",nOpcAux,cCodDesp,cProc)
      aDocs   := MontaDocs("FR",nOpcAux,cCodDesp,cProc) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
      If nOpcAux <> EXCLUIR .And. !(nOpcAux == ALTERAR .And. lExistProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
         If !lMsErroAuto
            If AeGerInv("FR",nOpcAux,cProc)
               AeGerParc("FR",nOpcAux,cProc)
            EndIf
            If EJX->EJX_VL_MOE <> M->EEC_FRPREV .and. !( AvFlags("INTEG_EEC_X_ESS_DESP_E_COMISS") .And. !Empty(EXL->EXL_MDFR) .And. !Empty(EXL->EXL_SMOEFR) .And. EXL->EXL_MDFR <>  EXL->EXL_SMOEFR )  //LRS - 28/07/2014 - Correção de Valores caso a moeda de despesa seja diferente da moeda do embarque
            	CorrSaldo(cProc,aItens[1][12][2]/aItens[1][13][2],aItens[1][12][2],aCab[3][2],aItens[1][2][2])                                                                                         //NCF - 15/10/2015 - Não corrigir saldo quando moeda da despesa for diferente da moeda do Fornecedor
            EndIF
         EndIf
         //Caso seja uma exclusão ou alteração de um processo já existente no SIGAESS deve atualizar a invoice primeiro.
         //É importante alterar a invoice primeiro porque o valor da despesa pode ser menor do que o atual, no SIGAESS, não pode alterar o valor do processo
         //caso na invoice o mesmo seja maior
      ElseIf nOpcAux == EXCLUIR .And. AeGerParc("FR",nOpcAux,cProc) .And. AeGerInv("FR",nOpcAux,cProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,nOpcAux)
      ElseIf nOpcAux <> EXCLUIR .And. AeGerInv("FR",nOpcAux,cProc) .And. AeGerParc("FR",nOpcAux,cProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
      EndIf
      aCab    := {}
      aItens  := {}
   EndIf
EndIf

//Despesa Internacional de Seguro
If SYB->(DbSeek(xFilial("SYB")+"103")) //Pesquisa se existe a despesa de seguro
   cCodDesp := AllTrim(SYB->YB_DESP)
Else
   cCodDesp := ""
EndIf
cProc := AllTrim(      If( Empty(EEC->EEC_PREEMB), M->EEC_PREEMB,  EEC->EEC_PREEMB    ))+"/"+cCodDesp  //NCF - 07/10/2015 - [Cod. Preventivo] - Verificar porque o EEC->EEC_PREEMB está vazio neste ponto.

If !Empty(cCodDesp)
   lExistProc := EJW->(DbSeek(xFilial("EJW")+"A"+AvKey(cProc,"EJW_PROCES"))) .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEEC"
   lAltProc   := (nOpc == ALTERAR .And. !((Empty(EXL->EXL_VDSE) .Or. Empty(EXL->EXL_NBSSE) .Or. Empty(EXL->EXL_FOSE) .Or. Empty(EXL->EXL_LFSE) .Or. Empty(EXL->EXL_PASE)) .And. !lExistProc))

   If (nOpc == INCLUIR .And. !Empty(EEC->EEC_DTEMBA) .And. !Empty(EXL->EXL_VDSE) .And. !Empty(EXL->EXL_NBSSE) .And. !Empty(EXL->EXL_FOSE) .And. !Empty(EXL->EXL_LFSE) .And. !Empty(EXL->EXL_PASE)) .Or. lAltProc .Or.  (nOpc == EXCLUIR .And. lExistProc)
      //Caso esteja alterando o embarque retirando o valor da despesa e o processo equivalente já tiver sido cadastrado no SIGAESS, será realizada a exclusão do mesmo
      //Se estiver alterando o embarque incluindo um valor da despesa, ou seja, processo ainda não gerado no SIGAESS, o sistema já entende que é uma inclusão
      //Verifica campos obrigatórios para o Processo no SIGAESS
      If nOpc == ALTERAR .And. (Empty(EXL->EXL_VDSE) .Or. Empty(EXL->EXL_NBSSE) .Or. Empty(EXL->EXL_FOSE) .Or. Empty(EXL->EXL_LFSE) .Or. Empty(EXL->EXL_PASE))
         nOpcAux := EXCLUIR
      Else
         nOpcAux := nOpc
      EndIf
      aCab   := MontaCapa("SE",nOpcAux,cProc)
      aItens := MontaItens("SE",nOpcAux,cCodDesp,cProc)
      aDocs  := MontaDocs("SE",nOpcAux,cCodDesp,cProc) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
      //Se estiver alterando o embarque incluindo um valor da despesa, ou seja, processo ainda não gerado no SIGAESS, o sistema já entende que é uma inclusão
      If nOpcAux <> EXCLUIR .And. !(nOpcAux == ALTERAR .And. lExistProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
         If !lMsErroAuto
            If AeGerInv("SE",nOpcAux,cProc)
               AeGerParc("SE",nOpcAux,cProc)
            EndIf
            If EJX->EJX_VL_MOE <> M->EEC_SEGPRE .and. !( AvFlags("INTEG_EEC_X_ESS_DESP_e_COMISS") .And. !Empty(EXL->EXL_MDSE) .And. !Empty(EXL->EXL_SMOESE) .And. EXL->EXL_MDSE <>  EXL->EXL_SMOESE )  //LRS - 28/07/2014 - Correção de Valores caso a moeda de despesa seja diferente da moeda do embarque
            	CorrSaldo(cProc,aItens[1][12][2]/aItens[1][13][2],aItens[1][12][2],aCab[3][2],aItens[1][2][2])                                                                                         //NCF - 15/10/2015 - Não corrigir saldo quando moeda da despesa for diferente da moeda do Fornecedor
            EndIF
         EndIf
      //Caso seja uma exclusão ou alteração de despesa que já possui um processo no SIGAESS, deve atualizar a invoice primeiro
      ElseIf nOpcAux == EXCLUIR .And. AeGerParc("SE",nOpcAux,cProc) .And. AeGerInv("SE",nOpcAux,cProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,nOpcAux)
      ElseIf nOpcAux <> EXCLUIR .And. AeGerInv("SE",nOpcAux,cProc) .And. AeGerParc("SE",nOpcAux,cProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
      EndIf
      aCab    := {}
      aItens  := {}
   EndIf
EndIf

//Despesa Internacional de Frete Adicional
If SYB->(DbSeek(xFilial("SYB")+"333")) //Pesquisa se existe a despesa de frete adicional
   cCodDesp := AllTrim(SYB->YB_DESP)
Else
   cCodDesp := ""
EndIf
cProc := AllTrim(      If( Empty(EEC->EEC_PREEMB), M->EEC_PREEMB,  EEC->EEC_PREEMB    ))+"/"+cCodDesp  //NCF - 07/10/2015 - [Cod. Preventivo] - Verificar porque o EEC->EEC_PREEMB está vazio neste ponto.

If !Empty(cCodDesp)
   lExistProc := EJW->(DbSeek(xFilial("EJW")+"A"+AvKey(cProc,"EJW_PROCES"))) .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEEC"
   lAltProc   := (nOpc == ALTERAR .And. !((Empty(EXL->EXL_VDFA) .Or. Empty(EXL->EXL_NBSFA) .Or. Empty(EXL->EXL_FOFA) .Or. Empty(EXL->EXL_LFFA) .Or. Empty(EXL->EXL_PAFA)) .And. !lExistProc))

   If (nOpc == INCLUIR .And. !Empty(EEC->EEC_DTEMBA) .And. !Empty(EXL->EXL_VDFA) .And. !Empty(EXL->EXL_NBSFA) .And. !Empty(EXL->EXL_FOFA) .And. !Empty(EXL->EXL_LFFA) .And. !Empty(EXL->EXL_PAFA)) .Or. lAltProc .Or. (nOpc == EXCLUIR .And. lExistProc)
      //Caso esteja alterando o embarque retirando o valor da despesa e o processo equivalente já tiver sido cadastrado no SIGAESS, será realizada a exclusão do mesmo
      //Se estiver alterando o embarque incluindo um valor da despesa, ou seja, processo ainda não gerado no SIGAESS, o sistema já entende que é uma inclusão
      //Verifica campos obrigatórios para o Processo no SIGAESS
      If nOpc == ALTERAR .And. (Empty(EXL->EXL_VDFA) .Or. Empty(EXL->EXL_NBSFA) .Or. Empty(EXL->EXL_FOFA) .Or. Empty(EXL->EXL_LFFA) .Or. Empty(EXL->EXL_PAFA))
         nOpcAux := EXCLUIR
      Else
         nOpcAux := nOpc
      EndIf
      aCab   := MontaCapa("FA",nOpcAux,cProc)
      aItens := MontaItens("FA",nOpcAux,cCodDesp,cProc)
      aDocs  := MontaDocs("FA",nOpcAux,cCodDesp,cProc) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
      //Se estiver alterando o embarque incluindo um valor da despesa, ou seja, processo ainda não gerado no SIGAESS, o sistema já entende que é uma inclusão
      If nOpcAux <> EXCLUIR .And. !(nOpcAux == ALTERAR .And. lExistProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
         If !lMsErroAuto
            If AeGerInv("FA",nOpcAux,cProc)
               AeGerParc("FA",nOpcAux,cProc)
            EndIf
            If EJX->EJX_VL_MOE <> M->EEC_FRPCOM .and. !( AvFlags("INTEG_EEC_X_ESS_DESP_e_COMISS") .And. !Empty(EXL->EXL_MDFA) .And. !Empty(EXL->EXL_SMOEFA) .And. EXL->EXL_MDFA <>  EXL->EXL_SMOEFA )  //LRS - 28/07/2014 - Correção de Valores caso a moeda de despesa seja diferente da moeda do embarque
            	CorrSaldo(cProc,aItens[1][12][2]/aItens[1][13][2],aItens[1][12][2],aCab[3][2],aItens[1][2][2])                                                                                         //NCF - 15/10/2015 - Não corrigir saldo quando moeda da despesa for diferente da moeda do Fornecedor
            EndIF
         EndIf
      //Caso seja uma exclusão ou alteração de despesa que já possui um processo no SIGAESS, deve atualizar a invoice primeiro
      ElseIf nOpcAux == EXCLUIR .And. AeGerParc("FA",nOpcAux,cProc) .And. AeGerInv("FA",nOpcAux,cProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,nOpcAux)
      ElseIf nOpcAux <> EXCLUIR .And. AeGerInv("FA",nOpcAux,cProc) .And. AeGerParc("FA",nOpcAux,cProc)
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
      EndIf
      aCab    := {}
      aItens  := {}
   EndIf
EndIf
///NCF - 06/10/2015 - [P2] - Verificação de Inclusão/Alteração de PAS de Comissões no SISCOSERV
//Comissões
If Empty(cEmb) .Or. ValType(nOpc) <> "N" .Or. !(EC6->(FieldPos("EC6_PRDSIS")) > 0) .Or. !EEB->(DbSeek(xFilial("EEB")+AvKey(cEmb,"EEB_PEDIDO")))
   Break
EndIf

Do While EEB->(!Eof()) .and. EEB->EEB_FILIAL == xFilial("EEB") .And. EEB->EEB_PEDIDO == AvKey(cEmb,"EEB_PEDIDO")

   Do Case
      Case EEB->EEB_TIPCOM == '1'
         cEvComiss := '120'
      Case EEB->EEB_TIPCOM == '2'
         cEvComiss := '121'
      Case EEB->EEB_TIPCOM == '3'
         cEvComiss := '122'
   End Case

   If EC6->(DbSeek(xFilial("EC6")+AvKey("EXPORT","EC6_TPMODU")+ AvKey(cEvComiss,"EC6_ID_CAM") )) //Pesquisa se existe a comissão
      cCodDesp := AllTrim(EC6->EC6_ID_CAM)
      cCodPrdEC6 := EC6->EC6_PRDSIS
   Else
      cCodDesp := ""
   EndIf
   cProc := AllTrim(      If( Empty(EEC->EEC_PREEMB), M->EEC_PREEMB,  EEC->EEC_PREEMB    ))+"/"+cCodDesp  //NCF - 07/10/2015 - [Cod. Preventivo] - Verificar porque o EEC->EEC_PREEMB está vazio neste ponto.

   If !Empty(cCodDesp)
      lExistProc := EJW->(DbSeek(xFilial("EJW")+"A"+AvKey(cProc,"EJW_PROCES"))) .And. AllTrim(EJW->EJW_ORIGEM) == "SIGAEEC"
      lAltProc   := (nOpc == ALTERAR .And. !((Empty(EEB->EEB_TOTCOM) .Or. Empty(EC6->EC6_PRDSIS) .Or. Empty(EEB->EEB_FORNEC) .Or. Empty(EEB->EEB_LOJAF)) .And. !lExistProc))

      If (nOpc == INCLUIR .And. !Empty(EEC->EEC_DTEMBA) .And. !Empty(EEB->EEB_TOTCOM) .And. !Empty(EC6->EC6_PRDSIS) .And. !Empty(EEB->EEB_FORNEC) .And. !Empty(EEB->EEB_LOJAF)) .Or. lAltProc .Or. (nOpc == EXCLUIR .And. lExistProc)
         //Caso esteja alterando o embarque retirando o valor da despesa e o processo equivalente já tiver sido cadastrado no SIGAESS, será realizada a exclusão do mesmo
         //Se estiver alterando o embarque incluindo um valor da despesa, ou seja, processo ainda não gerado no SIGAESS, o sistema já entende que é uma inclusão
         //Verifica campos obrigatórios para o Processo no SIGAESS
         If nOpc == ALTERAR .And. (Empty(EEB->EEB_TOTCOM) .Or. Empty(EC6->EC6_PRDSIS) .Or. Empty(EEB->EEB_FORNEC) .Or. Empty(EEB->EEB_LOJAF))
            nOpcAux := EXCLUIR
         Else
            nOpcAux := nOpc
         EndIf
         aCab    := MontaCapa(cEvComiss,nOpcAux,cProc)
         aItens  := MontaItens(cEvComiss,nOpcAux,cCodDesp,cProc)
         aDocs   := MontaDocs(cEvComiss,nOpcAux,cCodDesp,cProc) //WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
         If nOpcAux <> EXCLUIR .And. !(nOpcAux == ALTERAR .And. lExistProc)
            MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
            If !lMsErroAuto
               If AeGerInv(cEvComiss,nOpcAux,cProc)
                  //NCF - 07/10/2015 - [P6] - Caso seja Comissão a deduzir, acessar o câmbio do SIGAEEC e gravar dados da liquidação
                  If cEvComiss == "122"
                     aOrdEEQ  := SaveOrd("EEQ")
                     cParc    := EEQ->EEQ_PARC
                     EEQ->(DbSetOrder(5)) //EEQ_FILIAL+EEQ_NRINVO+EEQ->EEQ_PREEMB+EEQ_PARC
                     If EEQ->(DbSeek(xFilial("EEQ")+AvKey(cInvoice,"EEQ_NRINVO")+AvKey(cEvcomiss,"EEQ_EVENT") ))
                        Do While !EEQ->(Eof()) .And. EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT) == xFilial("EEQ")+AvKey(cInvoice,"EEQ_NRINVO")+AvKey(cEvComiss,"EEQ_EVENT")
                           EEQ->(RecLock("EEQ",.F.))
                           EEQ->EEQ_PGT := EEC->EEC_DTEMBA
                           EEQ->EEQ_TX  := BuscaTaxa(EEC->EEC_MOEDA,EEC->EEC_DTEMBA,,.F.)
                           EEQ->EEQ_EQVL:= EEQ->EEQ_VL * EEQ->EEQ_TX
                           EEQ->(MsUnlock())
                           EEQ->(DbSkip())
                        EndDo
                     EndIf
                     RestOrd(aOrdEEQ,.T.)
                  EndIf
                  /**/
                  //NCF - 07/10/2015 - [P7] - Caso seja Comissão a deduzir, após liquidado o câmbio do SIGAEEC, preparar dados e integrar liquidação do câmbio de serviço
                  /**/
                  AeGerParc(cEvComiss,nOpcAux,cProc)
               EndIf
               /*If EJX->EJX_VL_MOE <> M->EEC_FRPREV  //LRS - 28/07/2014 - Correção de Valores caso a moeda de despesa seja diferente da moeda do embarque
                  CorrSaldo(cProc,aItens[1][12][2]/aItens[1][13][2],aItens[1][12][2],aCab[3][2],aItens[1][2][2])
               EndIF*/
            EndIf
            //Caso seja uma exclusão ou alteração de um processo já existente no SIGAESS deve atualizar a invoice primeiro.
            //É importante alterar a invoice primeiro porque o valor da despesa pode ser menor do que o atual, no SIGAESS, não pode alterar o valor do processo
            //caso na invoice o mesmo seja maior
         ElseIf nOpcAux == EXCLUIR .And. AeGerParc(cEvComiss,nOpcAux,cProc) .And. AeGerInv(cEvComiss,nOpcAux,cProc)
            //NCF - 07/10/2015 - [P8] - Caso seja Comissão a deduzir, realizar primeiro o estorno da liquidação do câmbio de serviço

            //NCF - 07/10/2015 - [P9] - Caso seja Comissão a deduzir, após realizado o estorno da liquidação do câmbio de serviço, gravar dados de est. liquidação na parcela do SIGAEEC.

            MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,,nOpcAux)
         ElseIf nOpcAux <> EXCLUIR .And. AeGerInv(cEvComiss,nOpcAux,cProc) .And. AeGerParc(cEvComiss,nOpcAux,cProc)
            MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},aCab,aItens,aDocs,nOpcAux)
         EndIf
         aCab    := {}
         aItens  := {}
      EndIf
   EndIf

   EEB->(DbSkip())
EndDo


End Sequence
EXL->(DbGoTo(nRecEXL))
EEC->(DbGoTo(nRecEEC))
EEQ->(DbGoTo(nRecEEQ))
RestOrd(aOrd,.T.)

Return Nil

/*
Programa   : MontaCapa()
Objetivo   : Montar dados da capa do embarque para integração com o módulo SIGAESS (Easy Siscoserv) para geração do processo de aquisição e da invoice
Parâmetros : cDesp - Tipo de Despesa, nOpcAux - Tipo de Operação, cProc - Chave do Processo
Autor      : Rafael Ramos Capuano
Data       : 12/08/2013 - 11:20:00
*/

Static Function MontaCapa(cDesp,nOpcAux,cProc)
Local aCab   := {}
Local cPag := "" //LRS - 24/07/2014 - Variavel para Cod. Pag

If EasyGParam("MV_EECFAT",,.F.)  //LRS - 24/07/2014 - verificação da integração com Protheus
	SY6->(DBSETORDER(1))
	If !(cDesp $ "120/121/122")
	   SY6->(DBSEEK(XFILIAL("SY6")+&("EXL->EXL_CP"+cDesp)+STR(&("EXL->EXL_DP"+cDesp),3,0)))
	Else
	   SY6->(DbSeek(xFilial("SY6") + EEC->EEC_COND2 ))
	EndIf
	cPag := SY6->Y6_SIGSE4    // RMD - 01/09/2014
EndIF

If !Empty(cDesp)
   aAdd(aCab,{'EJW_FILIAL',xFilial("EJW")                             ,NIL})
   aAdd(aCab,{'EJW_PROCES',AvKey(cProc,"EJW_PROCES")                  ,NIL})
   aAdd(aCab,{'EJW_TPPROC',"A"                                        ,NIL})
   aAdd(aCab,{'EJW_ORIGEM',"SIGAEEC"                                  ,NIL})
   //Se for uma exclusão, não é necessário passar todos os campos da tabela
   If nOpcAux <> EXCLUIR
      If !(cDesp $ "120/121/122")
         //RMD - ROADMAP: C1 - 25/05/15 - Considera os campos específicos para fornecedor internacional
         If EXL->(FieldPos("EXL_FINT"+cDesp) > 0 .And. FieldPos("EXL_FLOJ"+cDesp) > 0 .And. !Empty(&("EXL->EXL_FINT"+cDesp)) .And. !Empty(&("EXL->EXL_FLOJ"+cDesp)))
            aAdd(aCab,{'EJW_EXPORT',&("EXL->EXL_FINT"+cDesp)                  ,NIL})
            aAdd(aCab,{'EJW_LOJEXP',&("EXL->EXL_FLOJ"+cDesp)                  ,NIL})
         Else
            aAdd(aCab,{'EJW_EXPORT',&("EXL->EXL_FO"+cDesp)                  ,NIL})
            aAdd(aCab,{'EJW_LOJEXP',&("EXL->EXL_LF"+cDesp)                  ,NIL})
         EndIf
         //RMD - ROADMAP: C1 - 30/06/15 - Campos para informar a moeda do Pedido de Serviços
         If EXL->(FieldPos("EXL_SMOE"+cDesp) > 0 .And. FieldPos("EXL_SPAR"+cDesp) > 0 .And. FieldPos("EXL_SVAL"+cDesp) > 0) .And.;
            !Empty(&("EXL->EXL_SMOE"+cDesp)) .And. &("EXL->EXL_SPAR"+cDesp) > 0 .And. &("EXL->EXL_SVAL"+cDesp) > 0
            aAdd(aCab,{'EJW_MOEDA' ,&("EXL->EXL_SMOE"+cDesp)                 ,NIL})
         Else
	        aAdd(aCab,{'EJW_MOEDA' ,&("EXL->EXL_MD"+cDesp)                  ,NIL})
	     EndIf
         //aAdd(aCab,{'EJW_DTPROC',                                      ,NIL})
         aAdd(aCab,{'EJW_CONDPG' ,cPag             					  ,NIL}) //LRS - 27/06/2014 - Colocando o Cod Pag no ESS de acordo com a despesa do EEC
         //aAdd(aCab,{'EJW_COMP' ,                                       ,NIL})
      Else
         //NCF - 06/10/2015 - [P3] - Monta a Capa para Inclusão/Alteração de PAS de Comissões no SISCOSERV
         aAdd(aCab,{'EJW_EXPORT', EEB->EEB_FORNEC                 ,NIL})
         aAdd(aCab,{'EJW_LOJEXP', EEB->EEB_LOJAF                  ,NIL})
	     aAdd(aCab,{'EJW_MOEDA' , EEC->EEC_MOEDA                  ,NIL})
         aAdd(aCab,{'EJW_CONDPG' ,cPag             				  ,NIL})
      EndIf
   EndIf
EndIf
Return aCab

/*
Programa   : MontaItens()
Objetivo   : Montar dados dos itens do embarque para integração com o módulo SIGAESS (Easy Siscoserv) para geração do processo de aquisição e da invoice
Parâmetros : cDesp - Tipo de Despesa, nOpcAux - Tipo de Operação, cCodDesp - Código da despesa que compõe o campo do Processo de Aquisição no Serviço, cProc - Chave do Processo
Autor      : Rafael Ramos Capuano
Data       : 12/08/2013 - 11:24:00
*/

Static Function MontaItens(cDesp, nOpcAux, cCodDesp, cProc)
Local aItens    := {}
Local aItensAux := {}
Local aOrd      := SaveOrd({"SA2","SYB"})
Local cPrdsis   := ""
Local cNbsComis := ""
Local nMV0030 := EasyGParam("MV_ESS0030",,2)//LRS -15/07/2017
Local cPaisBR := "105"

SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
SYB->(DbSetOrder(1)) //YB_FILIAL+YB_DESP
SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD

If !Empty(cDesp)
   aAdd(aItensAux,{'EJX_FILIAL',xFilial("EJX")                                            ,NIL})
   aAdd(aItensAux,{'EJX_SEQPRC',StrZero(1,AvSx3("EJX_SEQPRC",AV_TAMANHO))                 ,NIL})
   aAdd(aItensAux,{'EJX_PROCES',AvKey(cProc,"EJX_PROCES")                                 ,NIL})
   aAdd(aItensAux,{'EJX_TPPROC',"A"                                                       ,NIL})
   //Se for uma exclusão, não é necessário passar todos os campos da tabela
   If nOpcAux <> EXCLUIR
      If !(cDesp $ "120/121/122")
         //RMD - ROADMAP: C1 - 27/04/15 - Considera o Produto informado para a Via de Transporte
         If cDesp == "FR" .And. SYQ->(FieldPos("YQ_PRDSIS")) > 0 .And. !Empty(cPrdSis := Posicione("SYQ", 1, xFilial("SYQ")+M->EEC_VIA, "YQ_PRDSIS"))
            aAdd(aItensAux,{'EJX_ITEM'  ,cPrdSis ,NIL})
         Else
            aAdd(aItensAux,{'EJX_ITEM'  ,If(SYB->(DbSeek(xFilial("SYB")+cCodDesp)),SYB->YB_PRODUTO,""),NIL})
         EndIf

         aAdd(aItensAux,{'EJX_MODAQU',"1"                                                    ,NIL})

         //LRS - 15/07/2017 - Tratamento para o pais, de acordo com o parametro MV_ESS0030
         IF nMV0030 == 1
            aAdd(aItensAux,{'EJX_PAIS'  ,AvKey(EEC->EEC_PAISDT,"EJX_PAIS")                       ,NIL})
         ELseIF nMV0030 == 3
            aAdd(aItensAux,{'EJX_PAIS'  ,AvKey(cPaisBR,"EJX_PAIS")                       ,NIL})
         Else
            aAdd(aItensAux,{'EJX_PAIS'  ,If(SA2->(DbSeek(xFilial("SA2")+AvKey(&("EXL->EXL_FINT"+cDesp),"A2_COD")+AvKey(&("EXL->EXL_FLOJ"+cDesp),"A2_LOJA"))),SA2->A2_PAIS,""),NIL}) //País do fornecedor
         EndIF

         aAdd(aItensAux,{'EJX_NBS'   ,&("EXL->EXL_NBS"+cDesp)                                ,NIL})
         aAdd(aItensAux,{'EJX_DTINI' ,EEC->EEC_DTEMBA                                        ,NIL})
         //aAdd(aItensAux,{'EJX_DTFIM',                                                      ,NIL})
         aAdd(aItensAux,{'EJX_QTDE'  ,1                                                      ,NIL})

         //RMD - ROADMAP: C1 - 30/06/15 - Campos para informar a moeda do Pedido de Serviços
         If EXL->(FieldPos("EXL_SMOE"+cDesp) > 0 .And. FieldPos("EXL_SPAR"+cDesp) > 0 .And. FieldPos("EXL_SVAL"+cDesp) > 0) .And.;
                           !Empty(&("EXL->EXL_SMOE"+cDesp)) .And. &("EXL->EXL_SPAR"+cDesp) > 0 .And. &("EXL->EXL_SVAL"+cDesp) > 0
            aAdd(aItensAux,{'EJX_PRCUN' ,&("EXL->EXL_SVAL"+cDesp)                                 ,NIL})
            aAdd(aItensAux,{'EJX_VL_MOE',&("EXL->EXL_SVAL"+cDesp)                                 ,NIL})
            aAdd(aItensAux,{'EJX_TX_MOE',BuscaTaxa(&("EXL->EXL_SMOE"+cDesp), EEC->EEC_DTEMBA,,.F.),NIL})
         Else
            aAdd(aItensAux,{'EJX_PRCUN' ,&("EXL->EXL_VD"+cDesp)                                 ,NIL})
            aAdd(aItensAux,{'EJX_VL_MOE',&("EXL->EXL_VD"+cDesp)                                 ,NIL})
            aAdd(aItensAux,{'EJX_TX_MOE',BuscaTaxa(&("EXL->EXL_MD"+cDesp), EEC->EEC_DTEMBA,,.F.)/*&("EXL->EXL_PA"+cDesp)*/,NIL})   // RMD - 01/09/2014
	     EndIf
         //aAdd(aItensAux,{'EJX_VL_REA',&("EXL->EXL_VD"+cDesp)*&("EXL->EXL_PA"+cDesp),NIL})
      Else
         //NCF - 06/10/2015 - [P4] - Monta os Itens para Inclusão/Alteração de PAS de Comissões no SISCOSERV
         If !Empty(cPrdSis := Posicione("SYQ", 1, xFilial("SYQ")+M->EEC_VIA, "YQ_PRDSIS"))
            aAdd(aItensAux,{'EJX_ITEM'  ,cPrdSis                                                                                                       ,NIL})
         Else
            cPrdSis := cCodPrdEC6
            aAdd(aItensAux,{'EJX_ITEM'  ,cPrdSis                                                                                                       ,NIL})
         EndIf
         aAdd(aItensAux,{'EJX_MODAQU',"1"                                                                                                              ,NIL})
         aAdd(aItensAux,{'EJX_PAIS'  ,If(SA2->(DbSeek(xFilial("SA2")+AvKey(EEB->EEB_FORNEC,"A2_COD")+AvKey(EEB->EEB_LOJAF,"A2_LOJA"))),SA2->A2_PAIS,""),NIL}) //País do fornecedor
         aAdd(aItensAux,{'EJX_NBS'   ,Posicione("SB5", 1, xFilial("SB5")+AvKey(cPrdSis,"B5_COD"), "B5_NBS")                                            ,NIL})
         aAdd(aItensAux,{'EJX_DTINI' ,EEC->EEC_DTEMBA                                                                                                  ,NIL})
         aAdd(aItensAux,{'EJX_QTDE'  ,1                                                                                                                ,NIL})
         aAdd(aItensAux,{'EJX_PRCUN' ,EEB->EEB_TOTCOM                                                                                                  ,NIL})
         aAdd(aItensAux,{'EJX_VL_MOE',EEB->EEB_TOTCOM                                                                                                  ,NIL})
         aAdd(aItensAux,{'EJX_TX_MOE',BuscaTaxa(EEC->EEC_MOEDA, EEC->EEC_DTEMBA,,.F.)                                                                  ,NIL})

      EndIf
   EndIf
   aAdd(aItens,aClone(aItensAux))
EndIf

RestOrd(aOrd,.T.)
Return aItens

//WHRS 17/07/17 TE-6274 523509 [BERACA ERRO-6] - Envio de DI/RE na integração de frete/seguro
Static Function MontaDocs(cDesp, nOpcAux, cCodDesp, cProc)
Local aDocs    := {}
Local aDocsAux := {}
Local aOrd := SaveOrd({"EEC","EE9"})
Local cPrdSis := ""
Local aREs := {}, nI

EE9->(DbSetOrder(3))  //"EE9_FILIAL+EE9_PREEMB+EE9_SEQEMB"
If !EE9->(DbSeek(xFilial("EE9")+EEC->EEC_PREEMB))
   Return aDocs
EndIf
If !Empty(EEC->EEC_NRODUE)
    aAdd(aREs, EEC->EEC_NRODUE)
Else
    Do While EE9->(!Eof()) .AND. EE9->EE9_FILIAL == xFilial("EE9") .AND. EE9->EE9_PREEMB == EEC->EEC_PREEMB
        If !Empty(EE9->EE9_RE) .AND. aScan(aREs,EE9->EE9_RE) == 0
            aadd(aREs,EE9->EE9_RE)
        EndIf
        EE9->(DbSkip())
    EnDDo
EndIf
If Len(aREs) # 0
   For nI := 1 To Len(aREs)
      aDocsAux := {}
      aAdd(aDocsAux,{'EL2_FILIAL',xFilial("EL2"),NIL})
      aAdd(aDocsAux,{'EL2_PROCES',AvKey(cProc,"EL2_PROCES"),NIL})
      aAdd(aDocsAux,{'EL2_TPPROC',"A",NIL})
      aAdd(aDocsAux,{'EL2_SEQDOC',StrZero(nI,AvSx3("EL2_SEQDOC",AV_TAMANHO))  ,NIL})
      If nOpcAux <> EXCLUIR
         aAdd(aDocsAux,{'EL2_RE'    ,aREs[nI],NIL})
         If EasyGParam("MV_ESS0027",,9) >= 10
           aAdd(aDocsAux,{'EL2_SEQPRC',StrZero(1,AvSx3("EL2_SEQPRC",AV_TAMANHO))  ,NIL})
         EndIf
         aAdd(aDocsAux,{'EL2_STTSIS',"1"  ,NIL})
      EndIf
      aAdd(aDocs,aClone(aDocsAux))
   Next nI
EndIf
RestOrd(aOrd,.T.)
Return aDocs

/*
Programa   : AeGerInv()
Objetivo   : Gerar a invoice a partir do embarque quando houver integração do SIGAEEC com o SIGAESS (Easy Siscoserv) para geração do processo de aquisição e da invoice
Parâmetros : cDesp - Tipo de Despesa, nOpcAux - Operação a ser realizada, cProc - Chave do Processo
Autor      : Rafael Ramos Capuano
Data       : 09/08/2013 - 16:18:00
*/

Static Function AeGerInv(cDesp, nOpcAux, cProc)
Local aCab          := {}
Local aItens        := {}
Local aItensAux     := {}
Local aOrd          := SaveOrd({"ELA", "EEC"}) //RMD - 31/08/17 - Incluída a tabela EEC, pois a gravação da invoice/câmbio desposiciona a mesma
Local cForn         := ""
Local cLoja         := ""
Local nPos          := 0
Local nI            := 0
Local cChave        := ""
Local nModAtu := nModulo, cModAtu := cModulo //RMD - 31/08/17 - Guarda o módulo atual
//RMD - 31/08/17 - Define se as integrações financeiras do Siscoserv devem ser executadas. Na exclusão enviar nulo pois o EEC pode não estar integrado com o financeiro mas os títulos podem ter sido gerados no ESS
Local lIntFin := If(nOpcAux == EXCLUIR, Nil, .F.)

Private lMsErroAuto := .F.
Default cProc := ""

If !Empty(cDesp)
   If nOpcAux == EXCLUIR
      ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
      If !ELA->(DbSeek(xFilial("ELA")+"A"+AvKey(cProc,"ELA_PROCES")+AvKey(cProc,"ELA_NRINVO")))
         Break
      EndIf
   EndIf

   //Capa do Invoice
   aAdd(aCab,{'ELA_FILIAL',xFilial("ELA")                             ,NIL})
   aAdd(aCab,{'ELA_NRINVO',AvKey(cProc,"ELA_NRINVO")        ,NIL})
   aAdd(aCab,{'ELA_PROCES',AvKey(cProc,"ELA_PROCES")                  ,NIL})
   aAdd(aCab,{'ELA_TPPROC',"A"                                        ,NIL})
   //Campos do fornecedor e loja fazem parte da chave das tabelas ELA e ELB da invoice no SIGAESS, por isso, caso o usuário faça essa alteração no Embarque, passa
   //o conteúdo antigo para poder buscar a invoice corretamente. Posteriormente, na chamada do MsExecAuto do EICPS400, haverá a atualização dos novos dados
   //tanto no Processo como na invoice e nas demais tabelas envolvidas
   If nOpcAux <> INCLUIR
      cChave := xFilial("ELA")+"A"+AvKey(cProc,"ELA_PROCES")+AvKey(cProc,"ELA_NRINVO")
      ELA->(DbSetOrder(4)) //ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO
      If ELA->(DbSeek(cChave))
         //Busca a invoice originada do embarque
         Do While !ELA->(Eof()) .And. ELA->(ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO) == cChave .And. AllTrim(ELA->ELA_ORIGEM) <> "SIGAEEC"
            ELA->(DbSkip())
         EndDo
         If ELA->(ELA_FILIAL+ELA_TPPROC+ELA_PROCES+ELA_NRINVO) == cChave .And. AllTrim(ELA->ELA_ORIGEM) == "SIGAEEC"
            cForn := ELA->ELA_EXPORT
            cLoja := ELA->ELA_LOJEXP
         EndIf
      EndIf
   EndIf
   If !(cDesp $ "120/121/122")
      aAdd(aCab,{'ELA_EXPORT',If(!Empty(cForn),cForn, &("EXL->EXL_FO"+cDesp)) ,NIL})
      aAdd(aCab,{'ELA_LOJEXP',If(!Empty(cLoja),cLoja, &("EXL->EXL_LF"+cDesp)) ,NIL})
      aAdd(aCab,{'ELA_ORIGEM',"SIGAEEC"                                       ,NIL})
      aAdd(aCab,{'ELA_INT'   ,"S"                                             ,NIL})
      //Se for uma exclusão, não é necessário passar todos os campos da tabela
      If nOpcAux <> EXCLUIR
         aAdd(aCab,{'ELA_MOEDA' ,&("EXL->EXL_MD"+cDesp)                       ,NIL})
         aAdd(aCab,{'ELA_DTEMIS',EEC->EEC_DTEMBA                              ,NIL})
         aAdd(aCab,{'ELA_TX_MOE',BuscaTaxa(&("EXL->EXL_MD"+cDesp), EEC->EEC_DTEMBA,,.F.)/*&("EXL->EXL_PA"+cDesp)*/,NIL})    // RMD - 01/09/2014
         aAdd(aCab,{'ELA_TX_PED',&("EXL->EXL_STAX"+cDesp)                     ,NIL})
      EndIf
      //Item da Invoice
      aAdd(aItensAux,{'ELB_SEQPRC',StrZero(1,AvSx3("ELB_SEQPRC",AV_TAMANHO))  ,NIL})
      aAdd(aItensAux,{'ELB_VLCAMB',&("EXL->EXL_VD"+cDesp)                     ,NIL})
      aAdd(aItensAux,{'ELB_VLEXT' ,0                                          ,NIL})

      aAdd(aItens,aClone(aItensAux))
   Else
      //NCF - 06/10/2015 - [P5] - Monta a Invoice para Inclusão/Alteração de PAS de Comissões no SISCOSERV
      aAdd(aCab,{'ELA_EXPORT',EEB->EEB_FORNEC                                 ,NIL})
      aAdd(aCab,{'ELA_LOJEXP',EEB->EEB_LOJAF                                  ,NIL})
      aAdd(aCab,{'ELA_ORIGEM',"SIGAEEC"                                       ,NIL})
      aAdd(aCab,{'ELA_INT'   ,"S"                                             ,NIL})
      //Se for uma exclusão, não é necessário passar todos os campos da tabela
      If nOpcAux <> EXCLUIR
         aAdd(aCab,{'ELA_MOEDA' ,EEC->EEC_MOEDA                               ,NIL})
         aAdd(aCab,{'ELA_DTEMIS',EEC->EEC_DTEMBA                              ,NIL})
         aAdd(aCab,{'ELA_TX_MOE',BuscaTaxa(EEC->EEC_MOEDA,EEC->EEC_DTEMBA,,.F.),NIL})
         aAdd(aCab,{'ELA_TX_PED',BuscaTaxa(EEC->EEC_MOEDA,EEC->EEC_DTEMBA,,.F.),NIL})
      EndIf
      //Item da Invoice
      aAdd(aItensAux,{'ELB_SEQPRC',StrZero(1,AvSx3("ELB_SEQPRC",AV_TAMANHO))  ,NIL})
      aAdd(aItensAux,{'ELB_VLCAMB',EEB->EEB_TOTCOM                            ,NIL})
      aAdd(aItensAux,{'ELB_VLEXT' ,0                                          ,NIL})

      aAdd(aItens,aClone(aItensAux))
   EndIf
   //RMD - 31/08/17 - Muda o módulo para ESS antes de executar
   cModulo := "ESS"
   nModulo := 85
   //Último parâmetro possui conteúdo .F. para indicar que os títulos foram gerados inicialmente no SIGAFIN
   MsExecAuto({|a,b,c,d,e,f,g,h| ESSIS400("ELA",,,"A",aCab,aItens,nOpcAux,lIntFin)}) //RMD - 31/08/17
   cModulo := cModAtu
   nModulo := nModAtu
EndIf
RestOrd(aOrd,.T.)
Return !lMsErroAuto

/*
Programa   : AeGerParc()
Objetivo   : Gerar as parcelas de câmbio para o SIGAESS (EEQ) baseadas nas parcelas do Embarque (EEQ) de modo a criar um relacionamento com a invoice criada para a despesa no SIGAESS
Parâmetros : cDesp - Tipo de Despesa, nOpcAux - Operação a ser realizada, cProc - Chave do Processo
Autor      : Rafael Ramos Capuano
Data       : 24/09/2013 - 11:23:00
*/

Static Function AeGerParc(cDesp,nOpcAux,cProc)
Local aCab          := {}
Local aOrd          := SaveOrd({"EEQ"})
Local cInvoice      := AvKey(EEC->EEC_NRINVO,"EEQ_NRINVO")
Local cPreemb       := AvKey(EEC->EEC_PREEMB,"EEQ_PREEMB")
Local cEvento       := ""
Local cParc         := ""
Local dPgtESS       := CTOD("  \  \  ")
Local lExisteParc   := .F.
Local lExisteCamb   := .F.
Local lCont         := .T.
Local lLiq          := .F.
Local lFinan        := EasyGParam("MV_AVG0131",,.F.)
Local nRecParcESS   := 0 //Guarda o registro da EEQ correspondente ao ESS
Local nRecParcEEC   := 0 //Guarda o registro da EEQ correspondente ao EEC
Local nRecEEQ       := EEQ->(Recno())
Local nRecEEC       := EEC->(Recno()) // Guarda o registro posicionado na EEC pois após a chamada do MsExecAuto do EECAF500 estava despocionando a tabela
Local nValor        := 0  // GFP - 24/04/2014
Local cCond         := ""
Private lMsErroAuto := .F.
Default cProc := ""       //NCF - 06/10/2015
//Atribui os eventos existentes na tabela de Eventos (EC6) para cada tipo de Despesa, excessão feita a despesa do tipo "DI"(Outras Despesas Internacionais)
Do Case
   Case cDesp == "FR"
       cEvento := "102"
   Case cDesp == "SE"
       cEvento := "103"
   Case cDesp == "FA"
       cEvento := "150"
   //Case cDesp == "DI"
   Case cDesp $ "120/121/122"
       cEvento := cDesp

EndCase

Begin Sequence

If !Empty(cEvento) .And. EECFlags("FRESEGCOM")//RMD - 31/08/17 - Verifica se o ambiente está configurado para gerar câmbio antes de executar. Caso contrário, iria excluir o câmbio gerado pelo Siscoserv
   //Primeiro realiza atualização para cenário em que existe câmbio no SIGAESS, mas não existe no SIGAEEC, além de efetuar a exclusão
   If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015
      EEQ->(DbSetOrder(4)) //EEQ_FILIAL+EEQ_NRINVO+EEQ->EEQ_PREEMB+EEQ_PARC
      lExisteParc := EEQ->(DbSeek(xFilial("EEQ")+AvKey(cProc,"EEQ_NRINVO")+AvKey("A"+cProc,"EEQ_PREEMB")))
      cCond := 'EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB) == xFilial("EEQ")+AvKey(cProc,"EEQ_NRINVO")+AvKey("A'+cProc+'","EEQ_PREEMB")'                                       //NCF - 06/10/2015
   Else
      EEQ->(DbSetOrder(15)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROCES+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
      lExisteParc := EEQ->(DbSeek(xFilial("EEQ")+AvKey("A","EEQ_TPPROC")+AvKey(cProc,"EEQ_PROCES")+AvKey(cProc,"EEQ_NRINVO")))  // GFP - 26/05/2015
      cCond := 'EEQ->(EEQ_FILIAL+EEQ_TPPROC+EEQ_PROCES+EEQ_NRINVO) == xFilial("EEQ")+AvKey("A","EEQ_TPPROC")+AvKey("'+cProc+'","EEQ_PROCES")+AvKey("'+cProc+'","EEQ_NRINVO")'   //WHRS 19/07/17 TE-6277 523509 [BERACA ERRO-8] - Exclusão do Contas a Pagar Gerado Pelo Processo EEC
   EndIf                                                                                                                                                                        //NCF - 06/10/2015

   Do While !EEQ->(Eof()) .And. &cCond  // GFP - 26/05/2015
      aCab := {}
      nRecParcESS := EEQ->(Recno())
      cParc       := EEQ->EEQ_PARC
      nValor      := 0  // GFP - 24/04/2014
      //Busca EEQ do EEC
      EEQ->(DbSetOrder(4)) //EEQ_FILIAL+EEQ_NRINVO+EEQ->EEQ_PREEMB+EEQ_PARC
      lExisteCamb := EEQ->(DbSeek(xFilial("EEQ")+AvKey(cInvoice,"EEQ_NRINVO")+AvKey(cPreemb,"EEQ_PREEMB")+EEQ->EEQ_PARC))
      If lExisteCamb
         Do While !EEQ->(Eof()) .And. EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB+EEQ->EEQ_PARC) == xFilial("EEQ")+AvKey(cInvoice,"EEQ_NRINVO")+AvKey(cPreemb,"EEQ_PREEMB")+cParc
            If (lExisteCamb := (Alltrim(EEQ->EEQ_EVENT) == cEvento))
               nValor := EEQ->EEQ_VL  // GFP - 24/04/2014 - Armazenar valor da parcela de cambio do EEC.
               Exit
            EndIf
            EEQ->(DbSkip())
         EndDo
      EndIf
      //Retorna para a EEQ do ESS
      EEQ->(DbGoTo(nRecParcESS))
      If nValor <> 0 .AND. EEQ->EEQ_VL <> nValor  // GFP - 24/04/2014 - Verificar se é necessário atualizar valor da parcela de cambio do ESS.
         If EEQ->(RecLock("EEQ",.F.))
            EEQ->EEQ_VL := nValor
            EEQ->(MsUnlock())
         EndIf
      EndIf
      //Caso seja exclusão, só passará os campos da chave única e o EEQ_PROCES para identificar que é chamada do SIGAESS
      If !lExisteCamb .Or. nOpcAux == EXCLUIR
         aAdd(aCab,{'EEQ_FILIAL',xFilial("EEQ")   ,NIL})
         aAdd(aCab,{'EEQ_PREEMB',AvKey("A"+cProc,"EEQ_PREEMB")        ,NIL})
         aAdd(aCab,{'EEQ_NRINVO',AvKey(cProc,"EEQ_NRINVO")            ,NIL})
         aAdd(aCab,{'EEQ_PARC'  ,EEQ->EEQ_PARC    ,NIL})
         aAdd(aCab,{'EEQ_PROCES',AvKey(cProc,"EEQ_PROCES")            ,NIL})
         aAdd(aCab,{'EEQ_FASE'  ,"4"              ,NIL})
         aAdd(aCab,{'EEQ_TPPROC',EEQ->EEQ_TPPROC  ,NIL}) //WHRS 19/07/17 TE-6277 523509 [BERACA ERRO-8] - Exclusão do Contas a Pagar Gerado Pelo Processo EEC
         //Verifica caso em que a parcela deve ser excluída do SIGAESS porém o título está baixado, necessário fazer o estorno primeiro
         If !Empty(EEQ->EEQ_PGT)
            aAdd(aCab,{'EEQ_PGT'   ,CToD("  /  /  ") ,NIL})
            //lFinan indica se deve chamar a integração do SIGAESS com o SIGAFIN, caso o SIGAEEC já tenha gerado os títulos, será passado o valor .F.
            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aCab,ALTERAR,"A",!lFinan)
         EndIf
         If !lMsErroAuto
            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aCab,EXCLUIR,"A",!lFinan)
            If lMsErroAuto
               lCont := .F.
            EndIf
         Else
            lCont := .F.
         EndIf
      EndIf
      EEQ->(DbSkip())
   EndDo

   If nOpcAux <> EXCLUIR .And. lCont
      //Inicialmente verifica se existe algum câmbio para este processo no SIGAEEC
      EEQ->(DbSetOrder(4)) //EEQ_FILIAL+EEQ_NRINVO+EEQ->EEQ_PREEMB+EEQ_PARC
      EEQ->(DbSeek(xFilial("EEQ")+AvKey(cInvoice,"EEQ_NRINVO")+AvKey(cPreemb,"EEQ_PREEMB")))
      Do While lCont
         aCab    := {}
         dPgtESS := CTOD("  \  \  ")
         //Verifica se o item do câmbio corresponde a despesa que corresponde a um Processo de Aquisição para o SIGAESS
         EEQ->(DbSetOrder(4)) //EEQ_FILIAL+EEQ_NRINVO+EEQ->EEQ_PREEMB+EEQ_PARC
         lExisteCamb := EEQ->(!Eof()) .And. EEQ->(xFilial("EEQ")+AvKey(cInvoice,"EEQ_NRINVO")+AvKey(cPreemb,"EEQ_PREEMB")) == EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ->EEQ_PREEMB)
         Do While !EEQ->(Eof()) .And. EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB) == xFilial("EEQ")+AvKey(cInvoice,"EEQ_NRINVO")+AvKey(cPreemb,"EEQ_PREEMB")
            If (lExisteCamb := (Alltrim(EEQ->EEQ_EVENT) == cEvento))
               Exit
            EndIf
            EEQ->(DbSkip())
         EndDo

         If !lExisteCamb
            lCont := .F.
            Loop
         EndIf
         //Guarda EEQ correspondente ao EEC
         nRecParcEEC := EEQ->(Recno())
         cParc       := EEQ->EEQ_PARC
         //Verifica se a parcela já foi gravada para EEQ do ESS
         If (lExisteParc := EEQ->(DbSeek(xFilial("EEQ")+AvKey(cProc,"EEQ_NRINVO")+AvKey("A"+cProc,"EEQ_PREEMB")+cParc)))
            dPgtESS := EEQ->EEQ_PGT
         EndIf
         //Retorna a EEQ correspondente ao EEC
         EEQ->(DbGoTo(nRecParcEEC))

         aAdd(aCab,{'EEQ_FILIAL',xFilial("EEQ")   ,NIL})
         aAdd(aCab,{'EEQ_PREEMB',AvKey("A"+cProc,"EEQ_PREEMB")        ,NIL})
         aAdd(aCab,{'EEQ_NRINVO',AvKey(cProc,"EEQ_NRINVO")            ,NIL})
         aAdd(aCab,{'EEQ_PARC'  ,EEQ->EEQ_PARC    ,NIL})
         aAdd(aCab,{'EEQ_PARVIN',EEQ->EEQ_PARVIN  ,NIL})
         aAdd(aCab,{'EEQ_PROCES',AvKey(cProc,"EEQ_PROCES")            ,NIL})
         aAdd(aCab,{'EEQ_FASE'  ,"4"              ,NIL})
         aAdd(aCab,{'EEQ_EVENT' ,"001"            ,NIL})
         aAdd(aCab,{'EEQ_MOEDA' ,EEQ->EEQ_MOEDA   ,NIL})
         aAdd(aCab,{'EEQ_VCT'   ,EEQ->EEQ_VCT     ,NIL})
         aAdd(aCab,{'EEQ_PARI'  ,EEQ->EEQ_PARI    ,NIL})
         aAdd(aCab,{'EEQ_VL'    ,EEQ->EEQ_VL      ,NIL})
         aAdd(aCab,{'EEQ_VLSISC',EEQ->EEQ_VL      ,NIL})
         aAdd(aCab,{'EEQ_DECAM' ,if(Empty(EEQ->EEQ_DECAM),"1",EEQ->EEQ_DECAM)   ,NIL})   // RMD - 01/09/2014
         aAdd(aCab,{'EEQ_TIPO'  ,"P"              ,NIL})

         /*Fornecedor e loja podem ser alterados no processo, porém, primeiramente buscará pela chave antiga e depois com a atualização do Processo na chamada do EICPS400(), ocorrerá
         a atualização destas informações em todas as tabelas envolvidas, como a de parcela de câmbio*/

         aAdd(aCab,{'EEQ_FORN'  ,EEQ->EEQ_FORN    ,NIL})
         aAdd(aCab,{'EEQ_FOLOJA',EEQ->EEQ_FOLOJA  ,NIL})
         aAdd(aCab,{'EEQ_TPPROC',"A"              ,NIL})
         aAdd(aCab,{'EEQ_SOURCE',"SIGAEEC"        ,NIL})
         aAdd(aCab,{'EEQ_MODAL' ,"1"              ,NIL})
         aAdd(aCab,{'EEQ_TP_CON',"4"              ,NIL})

         If EEQ->(FieldPos("EEQ_EVTORI")) > 0
            aAdd(aCab,{'EEQ_EVTORI',EEQ->EEQ_EVENT,NIL})
         EndIf
         //Verifica caso de inclusão de parcela com o câmbio já liquidado, neste caso, primeiro inclui a parcela
         If !Empty(EEQ->EEQ_PGT) .And. !lExisteParc
            //Guarda EEQ correspondente ao EEC
            nRecParcEEC := EEQ->(Recno())
            //lFinan indica se deve chamar a integração do SIGAESS com o SIGAFIN, caso o SIGAEEC já tenha gerado os títulos, será passado o valor .F.
            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aCab,nOpcAux,"A",!lFinan)
            //Necessário retornar para EEQ do EEC
            EEQ->(DbGoTo(nRecParcEEC))
         EndIf

         If !lMsErroAuto
            //Carrega array para casos em o câmbio o próximo MsExecAuto terá como objetivo liquidar ou estornar a parcela no SIGAESS
            If !Empty(EEQ->EEQ_PGT) .Or. (lExisteParc .And. !Empty(dPgtESS))
               lLiq := !Empty(EEQ->EEQ_PGT)
               aAdd(aCab,{'EEQ_BANC'  ,If(!lLiq,"",EEQ->EEQ_BANC)  ,NIL})
               aAdd(aCab,{'EEQ_AGEN'  ,If(!lLiq,"",EEQ->EEQ_AGEN)  ,NIL})
               aAdd(aCab,{'EEQ_NCON'  ,If(!lLiq,"",EEQ->EEQ_NCON)  ,NIL})
               aAdd(aCab,{'EEQ_PGT'   ,If(!lLiq,CToD("  /  /  "),EEQ->EEQ_PGT)    ,NIL})
               aAdd(aCab,{'EEQ_NROP'  ,If(!lLiq,"",EEQ->EEQ_NROP) ,NIL})
               aAdd(aCab,{'EEQ_SOL'   ,EEQ->EEQ_SOL       ,NIL})
               aAdd(aCab,{'EEQ_DTCE'  ,EEQ->EEQ_DTCE      ,NIL})
               aAdd(aCab,{'EEQ_DTNEGO',EEQ->EEQ_DTNEGO    ,NIL})
               If lLiq .And. !Empty(EEQ->EEQ_TX)
                  aAdd(aCab,{'EEQ_TX' ,EEQ->EEQ_TX  ,NIL})
               EndIf
            EndIf
            //Guarda EEQ correspondente ao EEC
            nRecParcEEC := EEQ->(Recno())
            //lFinan indica se deve chamar a integração do SIGAESS com o SIGAFIN, caso o SIGAEEC já tenha gerado os títulos, será passado o valor .F.
            MsExecAuto({|l,y,z,w,x,k,j| EECAF500(l,y,z,w,x,k,j)},"EEQ", , ,aCab,nOpcAux,"A",!lFinan)
            //Necessário retornar para EEQ do EEC
            EEQ->(DbGoTo(nRecParcEEC))
            If lMsErroAuto
               lCont := .F.
            EndIf
         Else
            lCont := .F.
         EndIf
         EEQ->(DbSkip())
      EndDo
   EndIf
EndIf
End Sequence
EEQ->(DbGoTo(nRecEEQ))
EEC->(DbGoTo(nRecEEC))

RestOrd(aOrd,.T.)

Return !lMsErroAuto

/*
Funcao      : AE100VlDeduz()
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 09/12/13
Objetivos   : Retorna o valor total de comissão a deduzir
Parametros  : cPreemb - Código do Embarque. Se não for informado, assume que está na manutenção de embarque (valores na memória).
*/
Function EECVlDeduz(cPreemb, cFase)
Local nValor := 0
Local aOrd
Local cAlias
Default cFase := OC_EM

Begin Sequence

	If ValType(cPreemb) == "C"
		cAlias := "EEB"
		bCond := {|| !Eof() .And. EEB_FILIAL+EEB_PEDIDO+EEB_OCORRE == xFilial()+AvKey(cPreemb, "EEB_PEDIDO")+cFase }
		aOrd := SaveOrd("EEB")
		EEB->(DbSetOrder(1))
		//EEB_FILIAL+EEB_PEDIDO+EEB_OCORRE+EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM
		If !EEB->(DbSeek(xFilial()+AvKey(cPreemb, "EEB_PEDIDO")+cFase))
			Break
		EndIf
	Else
		cPreemb := M->EEC_PREEMB
		aOrd := SaveOrd("WORKAG")
		WorkAg->(DbGoTop())
		cAlias := "WORKAG"
		bCond := {|| !Eof() }
	EndIf

	While (cAlias)->(Eval(bCond))
		If (cAlias)->EEB_TIPCOM = "3"/*Deduzir da fatura*/ .And. Left((cAlias)->EEB_TIPOAG,1) = CD_AGC//Ag. Rec. Comi.
			nValor += (cAlias)->EEB_TOTCOM
		EndIf
		(cAlias)->(DbSkip())
	EndDo

End Sequence

If ValType(aOrd) == "A"
	RestOrd(aOrd, .T.)
EndIf

Return nValor

/*
Funcao     : GeraInfGerais()
Parametros : Nenhum
Retorno    : cTexto
Objetivos  : Geração do texto para o campo EEC_VMINFGER
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 0/05/2014 :: 09:52
Revisão    : 27/11/15 - NCF -  Função reescrita para otimar a apresentação das informações
*/
*--------------------------------*
Static Function GeraInfGerais()
*--------------------------------*
Local aRegs := {}  // SD, DDE, RE
Local cTexto := ""
Local i
Local nPosCh := 0   //NCF - 12/11/2014 - Evitar Repetições quando vários itens possuírem o mesmo código+data ou Ato+Seq
Local bSch_NrSD  := {|x| AvKey(Substr( x[1], 1, At( "-", x[1]  )-1 ) ,"EE9_NRSD")  ==  WorkIP->EE9_NRSD  }
Local bSch_DtAv  := {|x| CtoD( Substr( x[1], At( "-", x[1]  )+1, At( "|", x[1]  )-1 ))  ==  WorkIP->EE9_DTAVRB  }
Local bSch_DtDDE := {|x| CtoD(x[2]) ==  WorkIP->EE9_DTDDE }
Local bSch_NrRE  := {|x| AvKey(Substr( x[3], 1, At( "-", x[3]  )-1 ) ,"EE9_RE")  ==  WorkIP->EE9_RE  }
Local bSch_DtRE  := {|x| CtoD( Substr( x[3], At( "-", x[3]  )+1, At( "|", x[3]  )-1 )     )  ==  WorkIP->EE9_DTRE  }
Local bSch_NrAto := {|x| AvKey(Substr( x[4], 1, At( "-", x[4]  )-1 ),"EE9_ATOCON") == WorkIP->EE9_ATOCON }
Local bSch_SqAto := {|x| AvKey(StrTran( Substr( x[4], At( "-", x[4]  )+1, At( "|", x[4]  )-1 ) , "|",,,),"EE9_SEQED3")  ==  WorkIP->EE9_SEQED3 }
Local nRecWkIp:=0 //MCF - 13/06/2016

nRecWkIp := WorkIp->(RecNo()) //MCF - 13/06/2016

WorkIP->(DbGoTop())
Do While WorkIP->(!Eof())
   If !Empty(WorkIP->WP_FLAG)
/*      aAdd(aRegs,{AllTrim(WorkIP->EE9_NRSD) + "-" + DtoC(WorkIP->EE9_DTAVRB) + " | ",;
                  DtoC(WorkIP->EE9_DTDDE) + " | ",;
                  AllTrim(WorkIP->EE9_RE) + "-" + DtoC(WorkIP->EE9_DTRE) + " | ",;
                  AllTrim(WorkIP->EE9_ATOCON) + "-" + AllTrim(WorkIP->EE9_SEQED3) + " | "})    */
      aAdd(aRegs,{If( aScan(aRegs, bSch_NrSD  ) == 0 .Or. aScan(aRegs,bSch_DtAv) == 0 , AllTrim(WorkIP->EE9_NRSD) + "-" + DtoC(WorkIP->EE9_DTAVRB) + " | "      , ""),;
                  If( aScan(aRegs, bSch_DtDDE ) == 0                                  , DtoC(WorkIP->EE9_DTDDE) + " | "                                         , ""),;
                  If( aScan(aRegs, bSch_NrRE  ) == 0 .Or. aScan(aRegs,bSch_DtRE) == 0 , AllTrim(WorkIP->EE9_RE) + "-" + DtoC(WorkIP->EE9_DTRE) + " | "          , ""),;
                  If( aScan(aRegs, bSch_NrAto ) == 0 .Or. aScan(aRegs,bSch_SqAto)== 0 , AllTrim(WorkIP->EE9_ATOCON) + "-" + AllTrim(WorkIP->EE9_SEQED3) + " | " , "")})
   EndIf
   WorkIP->(DbSkip())
EndDo

cTexto += CHR(13)+CHR(10)//				+ ENTER  //"INFORMAÇÕES GERAIS DO PROCESSO"
cTexto += Replicate("-",50)	+ ENTER

cTexto += "SD's:  "     //"SD's:  "
For i := 1 To Len(aRegs)
   cTexto += aRegs[i][1]
Next i

cTexto += ENTER
cTexto += "DDE's:  "     //"DDE's:  "
For i := 1 To Len(aRegs)
   cTexto += aRegs[i][2]
Next i

cTexto += ENTER
cTexto += "RE's:  "     //"RE's:  "
For i := 1 To Len(aRegs)
   cTexto += aRegs[i][3]
Next i

cTexto += ENTER
cTexto += "AC's:  "     //"AC's:  "
For i := 1 To Len(aRegs)
   cTexto += aRegs[i][4]
Next i

WorkIp->(DbGoTo(nRecWkIp))

Return cTexto

/*
Funcao     : CorrSaldo()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Ajuste Valor real e valor Moeda
Autor      : Lucas Raminelli - LRS
Data/Hora  : 28/07/2014
Obs        : cProc - Processo, nVlMoe - Valor do processo/Unitario,nVlRea - Valor da moeda convertida,cTipo - tipo processo,cSeq - Seq item
*/
*-------------------*
Function CorrSaldo(cProc,nVlMoe,nVlRea,cTipo,cSeq)
*-------------------*

EJW->(DbSetOrder(2))
EJX->(DbSetOrder(1))

If EJW->(DbSeek(xFilial("EJW")+cProc))
	Reclock("EJW",.F.)
	EJW->EJW_VL_MOE :=nVlMoe
	EJW->EJW_VL_REA :=nVlRea
	EJW->( MSUnlock() )
EndIF

If EJX->(DbSeek(xFilial("EJX") + AvKey(cTipo,"EJX_TPPROC") + aVKEY(cProc,"EJX_PROCES") + AvKey(cSeq,"EJX_SEQPRC")))
	Reclock("EJX",.F.)
	EJX->EJX_PRCUN  :=nVLMoe
	EJX->EJX_VL_MOE :=nVlMoe
	EJX->EJX_VL_REA :=nVlRea
	EJX->( MSUnlock() )
EndIF

Return Nil

/*
Funcao      : PreAberto
Parametros  : Gatilho ajuste Tipo desconto de acordo com as opções selecionadas
Retorno     : NIL
Autor       : Lucas Raminelli - LRS
Data/Hora   : 27/10/2014
*/
Function AE100GatPrAb(cAlias)
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)

IF &("M->"+cAlias+"_PRECOA") == "1"
	&("M->"+cAlias+"_TPDESC") := "1"
ElseIf &("M->"+(cAlias)+"_PRECOA") == "2"
	IF lSubDesc
		&("M->"+cAlias+"_TPDESC") :="1"
	Else
		&("M->"+cAlias+"_TPDESC") :="2"
	EndIf
EndIF
//RMD - 28/10/14 - Recalcula os totais
If cAlias == "EE7"
	Ap100PrecoI(.T.)
Else
	Ae100PrecoI(.T.)
EndIf

Return &("M->"+cAlias+"_TPDESC")



/*
Funcao     : AE100GatIE()
Parametros : cCampo,nTipo
Retorno    : nRet
Objetivos  : Tratamento de gatilho do campo Imposto de Exportação
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 17/12/2015 :: 16:32
*/
*----------------------------------------*
Function AE100GatIE(cCampo,nTipo,cTabela)
*----------------------------------------*
Local nRet := 0, nTOTFOB := 0, nVLFOB := 0, nDESCONPRO := 0
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)
Local lMemoria := .T.,lEEC := .F.
Local cFlag, nSLD
Default cTabela := ""

Begin Sequence
   lMemoria := Empty(cTabela)
   lEEC := !lMemoria .AND. (cTabela == "EE9")
   If lMemoria
      If Empty(M->EE9_RE) .OR. Empty(M->EE9_DTRE)
         Break
      EndIf
   Else
      If Empty((cTabela)->EE9_RE) .OR. Empty((cTabela)->EE9_DTRE)
         Break
      EndIf
   EndIf

   Do Case
      Case nTipo == 1  // Preenche Base de Calculo

	     //AAF 22/12/2015 - Chama a precoi para calcular o valor fob quando o incoterm é CIF, CFR, etc...
		 //AAF 25/08/2017 - Work não existe quando esta função é utilizada no retorno da integração Siscomex RE.
		 If Select("WORKIP") > 0
			cFlag := WorkIP->WP_FLAG
			nSLD  := WorkIp->EE9_SLDINI
			WorkIP->WP_FLAG := cMarca
			WorkIP->EE9_SLDINI := M->EE9_SLDINI
            IF IsMemVar("lChkBoxRe") .AND. IsMemVar("lFimLoop") //LRS - 24/04/2018
               IF lChkBoxRe .AND. lFimLoop
                  Ae100PrecoI(.t., .f.)
                  lFimLoop := .F.
               EndIF
            Else
               Ae100PrecoI(.t., .f.)
            EndIF
		 EndIf

         nTOTFOB := EEC->((EEC_TOTPED+EEC_DESCON)-(EEC_FRPREV+EEC_FRPCOM+EEC_SEGPRE+EEC_DESPIN+AvGetCpo("EEC->EEC_DESP1")+AvGetCpo("EEC->EEC_DESP2")))

         IF (!lEEC .AND. M->EEC_PRECOA $ cSim) .OR. (lEEC .AND. EEC->EEC_PRECOA $ cSim).Or. EasyGParam("MV_AVG0085",,.F.)
            nDESCONPRO := If(lMemoria,(M->EE9_PRCINC/nTOTFOB)*100,((cTabela)->EE9_PRCINC/nTOTFOB)*100)    // % FOB DO TOTAL
            nDESCONPRO := ROUND((If(!lEEC,M->EEC_DESCON,EEC->EEC_DESCON)*nDESCONPRO)/100,2) // VALOR DO DESCONTO P/ O %
         ENDIF

         If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. ((!lEEC .AND. M->EEC_TPDESC $ CSIM) .OR. (lEEC .AND. EEC->EEC_TPDESC $ CSIM))) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
            nVLFOB := If(lMemoria,Round(M->EE9_PRCINC,2),Round((cTabela)->EE9_PRCINC,2))-nDESCONPRO              // VALOR NO LOCAL DO EMBARQUE COM O DESCONTO
         Else
            nVLFOB := If(lMemoria,Round(M->EE9_PRCINC,2),Round((cTabela)->EE9_PRCINC,2))+nDESCONPRO
         EndIf

         // Nos incoterms EXW, FAS, FOB e FCA - Valor Condição Venda = Valor no Local de Embarque
         IF (!lEEC .AND. M->EEC_INCOTERM $ "EXW/FAS/FOB/FCA") .OR. (lEEC .AND. EEC->EEC_INCOTERM $ "EXW/FAS/FOB/FCA")
            nVlFob := If(lMemoria,Round((M->EE9_SLDINI * M->EE9_PRECO),2),Round((cTabela)->EE9_PRCTOT,2))
         Else
            // Verifica se o valor na Condicao de Venda eh menor que o valor no Local de Embarque
            IF lMemoria
               If Round(M->EE9_PRCTOT,2) < nVlFob
                  nVlFob := Round(M->EE9_PRCTOT,2)
               EndIf
            Else
               If Select("WORKIP") > 0 //LRS - 13/12/2017
                  If Round(WorkIp->EE9_PRCTOT,2) < nVlFob
                     nVlFob := Round((cTabela)->EE9_PRCTOT,2)
                  EndIf
               EndIF
            Endif
         EndIf

         // Verifica se existe o campo FOB por item
         IF EE9->(FieldPos("EE9_FOBPIT")) > 0
            IF lMemoria
               IF M->EE9_FOBPIT > 0
                  nVlFob := M->EE9_FOBPIT
               EndIf
            Else
               IF WorkIp->EE9_FOBPIT > 0
                  nVlFob := (cTabela)->EE9_FOBPIT
               EndIf
            EndIf
         Endif

         nRet := nVlFob * BuscaTaxa(EEC->EEC_MOEDA,If(lMemoria,M->EE9_DTRE,(cTabela)->EE9_DTRE),,.F.)

		 //AAF 25/08/2017 - Work não existe quando esta função é utilizada no retorno da integração Siscomex RE.
		 If Select("WORKIP") > 0
            WorkIP->WP_FLAG := cFlag
            WorkIP->EE9_SLDINI := nSld
		 EndIf

      Case nTipo == 2  // Preenche Valor a Recolher
         If lMemoria
            nRet := M->EE9_BASIE * (M->EE9_PERIE/100)
         Else
            nRet := (cTabela)->EE9_BASIE * ((cTabela)->EE9_PERIE/100)
         EndIf

   End Case
End Sequence

Return nRet

/*
Funcao     : AE100VLRIE()
Parametros : nTipo
Retorno    : cRet
Objetivos  : Tratamento de preenchimento do campo EEC_VVLIE, presente na capa do processo.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/12/2015 :: 07:20
*/
*--------------------------*
Function AE100VLRIE(nTipo)
*--------------------------*
Local xRet:='0.0', nRecno := 0, nTotalIE := 0

Begin Sequence

   If nTipo == 1   // Gravação do campo virtual em tela
      xRet := STR0249 //"Aguardando RE's"
      If Select("WorkIp") == 0 .OR. WorkIp->(EasyRecCount("WorkIp")) == 0
         Break
      EndIf

      nRecno := WorkIp->(Recno())
      WorkIp->(dbGoTop())
      Do While WorkIp->(!Eof())
         If Empty(WorkIp->WP_FLAG)
            WorkIp->(DbSkip())
            Loop
         EndIf
         If !Empty(WorkIp->EE9_VLRIE)
            nTotalIE += WorkIp->EE9_VLRIE
         Else
            Break
         EndIf
         WorkIp->(DbSkip())
      EndDo
      WorkIp->(DbGoTo(nRecno))
      xRet := AllTrim(Transform(nTotalIE,AVSX3("EEC_VLRIE",6)))

   ElseIf nTipo == 2  // Gravação do campo real na base
      xRet := If(ValType(M->EEC_VVLIE) == 'U',;
              If(EEC->(FieldPos("EEC_VLRIE")),Alltrim(Str(EEC->EEC_VLRIE,AvSx3("EEC_VLRIE",3),AvSx3("EEC_VLRIE",4))),xRet),;
              M->EEC_VVLIE) //NCF - 12/06/2017
      xRet := STRTRAN(xRet,".","")
      xRet := STRTRAN(xRet,",",".")
      xRet := Val(xRet)
   EndIf

End Sequence

Return xRet



/*
Função     : NFRemFimEsp()
Objetivo   : Retonar se a rotina está com nova estrutura de controle de saldo
Parâmetros :
Retorno    :
Autor      : WFS
Data       : set/2016
Revisão    :
Observação : Remover esta função e suas chamadas quando a funcionalidade for publicada
             no release 12.
*/
Static Function NFRemFimEsp()
Local lRet:= .f.

   If FindFunction("NFRemNewStruct") .And. NFRemNewStruct()
      lRet:= .T.
   EndIf

Return lRet

/*
    Funcao   : atuaSaldRe()
    Autor    : Wanderson Reliquias
    Data     : 13/02/2017
    Revisao  : 13/02/2017
    Uso      : Controlar o saldo do RE
    Obs.     : TE-4715 - 504773 / MTRADE-497 - Controle de Saldo de RE;
    			 Esse calculo era feito no valid, isso gerou varios erros, então o valid ficou apenas para validação;
*/
static Function atuaSaldRe()

	Begin Sequence

              If !Empty(WorkIp->EE9_RE) .And. WorkIp->EE9_RE == M->EE9_RE
              	Break
              EndIf

           //WHRS TE-4715 - 504773 / MTRADE-497 - Controle de Saldo de RE
              If /*lConsign .And.*/ (Empty(cTipoProc) .Or. cTipoProc == PC_RC) .And. !Empty(WorkIp->EE9_RE) //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
       			If WkEY6->(DbSeek(WorkIp->EE9_RE))
                    WkEY6->WK_QTDVIN -= AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
                    If lConsign .And. cTipoProc == PC_RC
                       WkEY6->EY6_SLDATU += AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
                    Else
                       WkEY6->EY6_SLDATU += AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->WP_SLDATU, .F.)
                    EndIf
                 Else
                    WkEY6->(DbAppend())
                    EY6->(DbSeek(xFilial()+WorkIp->EE9_RE))
                    AvReplace("EY6", "WkEY6")
                    WkEY6->WK_QTDVIN -= AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
                    WkEY6->EY6_SLDATU += AvTransUnid(WorkIp->EE9_UNIDAD, WkEY6->EY6_UNIDAD, WorkIp->EE9_COD_I, WorkIp->EE9_SLDINI, .F.)
                    EER->(DbSetOrder(3))
                    EER->(DbSeek(xFilial("EER")+Left(WorkIp->EE9_RE, 3))) //MCF - 19/05/2016
                    If EER->EER_MANUAL <> "S"
                       WkEY6->WK_ALTIPO := "1"
                    EndIf
                 EndIf
              EndIf

           If !Empty(M->EE9_RE)
              If /*lConsign .And.*/ Empty(cTipoProc) .Or. cTipoProc == PC_RC //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
                 If WkEY6->(DbSeek(M->EE9_RE))
                    WkEY6->EY6_SLDATU -= AvTransUnid(M->EE9_UNIDAD, WkEY6->EY6_UNIDAD, M->EE9_COD_I, M->EE9_SLDINI, .F.)
                    WkEY6->WK_QTDVIN  += AvTransUnid(M->EE9_UNIDAD, WkEY6->EY6_UNIDAD, M->EE9_COD_I, M->EE9_SLDINI, .F.)

                    EER->(DbSetOrder(3))
                    If EER->(DbSeek(xFilial("EER")+Left(M->EE9_RE,9)))
                       M->EE9_DTRE := EER->EER_DTGERS
                    EndIf
               Else
                    EY6->(DbSetOrder(2))
                    WkEY6->(DbAppend())
                    AvReplace("EY6", "WkEY6")
                    WkEY6->WK_QTDVIN := AvTransUnid(M->EE9_UNIDAD, WkEY6->EY6_UNIDAD, M->EE9_COD_I, M->EE9_SLDINI, .F.)
                    WkEY6->EY6_SLDATU -= AvTransUnid(M->EE9_UNIDAD, WkEY6->EY6_UNIDAD, M->EE9_COD_I, M->EE9_SLDINI, .F.)


                 EndIf
              EndIf

           EndIf

	End Sequence
Return


Function XBEECAE100()
Local cRetorno := ""

If lIntDraw
    cRetorno := ConPad1(,,,"EI1",,)
Else
    EasyHelp(STR0254,STR0035)
    cRetorno := .F.
EndIf

Return cRetorno

//NCF - 06/03/2018
Static Function GetCpoIPVw()

Local aRet    := { {"EE9_SLDINI",0} , {"WP_SLDATU ",0} /*, {"EE9_QTDEM1",0} , {"EE9_PRECO ",0}*/ }
Local nRecNo  := WorkIP->(RecNo())

WorkIP->(DbGoTop())
While WorkIP->(!Eof())
   aEval( aRet, {|x| If( WorkIP->(fieldPos(x[1]))>0 , x[2] += &("WorkIP->"+x[1]) , 0 ) }  )
   WorkIP->(DbSkip())
EndDo
WorkIP->(DbGoTo(nRecNo))

Return aRet


/*
Funcao     : isDUEChange()
Parametros :
Retorno    : lRet - .T.: Existe diferença; .F. Não existe diferença
Objetivos  : Verificar se algum campo que vai no xml da DUE sofreu alteração
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 09/05/2018
*/
Static Function isDUEChange()
Local lRet      := .F.
Local lMemoTemNF:= Select("WorkNF") > 0 .And. !WorkNF->(Bof() .And. Eof()) //Verifica se o processo em gravacao tem NF
Local lHistTemNF //Verifica se o processo gravado no historico tem NF
Local cSeqHist  := "" //Sequencia do historico da DUE a ser verificada
Local lFimEspec := AvFlags("FIM_ESPECIFICO_EXP")
Local aQryCampos:= {}
Local nCountWkNF:= 0

Begin Sequence

   //Verifica se exsite DUE gerada - Tabela EK0
   cSeqHist := DUESeqHist(M->EEC_PREEMB) //Verifica se existe DUE gerada e retrona a ultima sequencia

   If Empty(cSeqHist) //Se vazio, não existe DUE gerada
      Break
   EndIf
   // se o status for Falha na Transmissao ou Embarque Cancelado não realiza comparação
   If getStatDUE(M->EEC_PREEMB,cSeqHist) $ "3|4"
      Break
   EndIf

   EK1->(dbSetOrder(1)) //EK1_FILIAL, EK1_PROCES, EK1_NUMSEQ
   EK1->(dbSeek(xFilial("EK1") + M->EEC_PREEMB + cSeqHist))
   lHistTemNF := EK1->EK1_TIPDUE == "1" //Tem NF? 1=Sim; 2=Não
   If lMemoTemNF != lHistTemNF //Verifica se teve mudança com relação a processo com NF ou sem NF
      lRet := .T.
      Break
   EndIf

   //Verifica se houve alteração em campos da capa do embarque EEC-EK1
   If DiffEECEK1(cSeqHist,lMemoTemNF) //Proura fiderencas entre as tabelas EEC e EK1
      lRet := .T.
      Break
   EndIf

   If lMemoTemNF //Se Tem Nota Fiscal
      //Verifica se a quantidade de Notas Fiscais mudou EEM-EK3
      aAdd(aQryCampos,{"EK3_FILIAL", xFilial("EK3")   })
      aAdd(aQryCampos,{"EK3_PROCES", M->EEC_PREEMB    })
      aAdd(aQryCampos,{"EK3_NUMSEQ", cSeqHist         })
      WorkNF->(dbGoTop())
      WorkNF->( dbEval( { || nCountWkNF++ } ) )
      If nCountWkNF != DUETotReg("EK3", aQryCampos)
         lRet := .T.
         Break
      EndIf

      //Verifica se alguma Nota Fiscal vinculada ao processo foi alterada com relação a DUE gerada EEM-EK3
      WorkNF->(dbGoTop())
      While WorkNF->(!Eof())
         If DiffEEMEK3(cSeqHist)
               lRet := .T.
               Break
         EndIf
         WorkNF->(dbSkip())
      End

      //Verifica se algum item do processo foi alterado com relação a DUE gerada EE9-EK2 (verifica somente os campos da EE9 comuns para quando tem NF)
      If DiffEE9EK2(cSeqHist,lMemoTemNF)
         lRet := .T.
         Break
      EndIf

      //Verifica se alguma Nota de Remessa vinculada ao processo foi alterada com relação a DUE gerada EYY-EK4
      If lFimEspec
         WK_NFRem->(dbGoTop())
         While WK_NFRem->(!Eof())
               If IsRemDiff() .And. DiffEYYEK4(cSeqHist) //Verifica se deve ou nao comparar
                  lRet := .T.
                  Break
               EndIf
               WK_NFRem->(dbSkip())
         End
      EndIf

   Else //Se Nao tem Nota Fiscal

      //Verifica se algum item do processo foi alterado com relação a DUE gerada EE9-EK2
      If DiffEE9EK2(cSeqHist,lMemoTemNF)
         lRet := .T.
         Break
      EndIf

   EndIf

End Sequence

Return lRet


/*
Funcao     : DiffEECEK1()
Parametros : cSeqHist   - Sequencia do Historico a ser compadaro;
             lTemNF     - .T. Processo com NF e .F. Processo sem NF;
Retorno    : lRet - Retorna se existe diferença entre EEC e EK1
Objetivos  : Verificar se existe diferença entre o processo que está sendo gravado e a última versão da due gerada
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 10/05/2018
*/
Static Function DiffEECEK1(cSeqHist,lTemNF)
Local lRet      := .F.
Local cQuery    := ""
Local cTmpEECDUE:= ""
Local nQtdDifDUE:= 0
Local cDBMS     := Upper(TCGETDB())
Local nSeq      := ""
// Local cVarChar  := IIF(cDBMS == "INFORMIX","LVARCHAR(4000)","VARCHAR(4000)") //THTS - 06/02/2019

// OSSME-4657 - Erro na alteração do embarque com DU-e gerada - MPG/23/04/2020 
beginsql alias "TMPEK1" 
   SELECT MAX(EK1_NUMSEQ) SEQ 
   FROM %table:EK1% EK1
   WHERE EK1.D_E_L_E_T_=' ' 
   AND   EK1.EK1_FILIAL = %exp:M->EEC_FILIAL% 
   AND   EK1.EK1_PROCES = %exp:M->EEC_PREEMB%
endsql

if TMPEK1->(!eof())
   nSeq := TMPEK1->SEQ
endif
TMPEK1->(dbcloseArea())

cTmpEECDUE := DUECriaTmp("EEC",lTemNF)

cQuery := " SELECT EEC.EEC_FILIAL,EEC.EEC_PREEMB,EEC.EEC_NRODUE,EEC.EEC_URFDSP,EEC.EEC_RECALF,EEC.EEC_EMFRRC,EEC.EEC_FOREXP, " + ENTER
if EK1->(fieldpos("EK1_ENQCOX")) > 0
   cQuery += " EEC.EEC_ENQCOX, "  + ENTER
endif
If EK1->(FieldPos("EK1_PAISET")) > 0
   cQuery += "  ISNULL((SELECT YA_PAISDUE "
   cQuery += "   FROM " + RetSQLName("SYA") + " SYA "
   cQuery += "   WHERE YA_FILIAL       = '" + xFilial("SYA") + "' "
   cQuery += "     AND YA_CODGI        = EEC.EEC_PAISET "
   cQuery += "     AND SYA.D_E_L_E_T_  = ' ' ),' ') EEC_PAISET, "  + ENTER
EndIf

cQuery += "  ISNULL((SELECT EVN_DESCRI "
cQuery += "   FROM " + RetSQLName("EVN") + " EVN "
cQuery += "   WHERE EVN_FILIAL      = '" + xFilial("EVN") + "' "
cQuery += "     AND EVN_GRUPO       = 'CUS' "
cQuery += "     AND EVN_CODIGO      = EEC.EEC_FOREXP "
cQuery += "     AND EVN.D_E_L_E_T_  = ' '),' ') EEC_DESFOR, " + ENTER

cQuery += " EEC.EEC_SITESP, " + ENTER

cQuery += "  ISNULL((SELECT EVN_DESCRI "
cQuery += "   FROM " + RetSQLName("EVN") + " EVN "
cQuery += "   WHERE EVN_FILIAL      = '" + xFilial("EVN") + "' "
cQuery += "     AND EVN_GRUPO       = 'AHZ' "
cQuery += "     AND EVN_CODIGO      = EEC.EEC_SITESP "
cQuery += "     AND EVN.D_E_L_E_T_  = ' '),' ') EEC_DESSIT, " + ENTER

cQuery += " EEC.EEC_ESPTRA, " + ENTER

cQuery += "  ISNULL((SELECT EVN_DESCRI "
cQuery += "   FROM " + RetSQLName("EVN") + " EVN "
cQuery += "   WHERE EVN_FILIAL      = '" + xFilial("EVN") + "' "
cQuery += "     AND EVN_GRUPO       = 'TRA' "
cQuery += "     AND EVN_CODIGO      = EEC.EEC_ESPTRA "
cQuery += "     AND EVN.D_E_L_E_T_  = ' '),' ') EEC_DESTRA, " + ENTER

cQuery += "  ISNULL((SELECT YF_ISO "
cQuery += "   FROM " + RetSQLName("SYF") + " SYF "
cQuery += "   WHERE YF_FILIAL       = '" + xFilial("SYF") + "' "
cQuery += "     AND YF_MOEDA        = EEC.EEC_MOEDA "
cQuery += "     AND SYF.D_E_L_E_T_  = ' '),' ') EEC_MOEDA, " + ENTER

cQuery += "       EEC.EEC_FORN,EEC.EEC_FOLOJA,A2.A2_NOME,A2.A2_CGC ,EEC.EEC_NRORUC, "
cQuery += "       EEC.EEC_INCOTE,EEC.EEC_IMPORT,EEC.EEC_IMLOJA,A1.A1_NOME, " + ENTER

cQuery += "  ISNULL((SELECT YA_PAISDUE "
cQuery += "   FROM " + RetSQLName("SYA") + " SYA "
cQuery += "   WHERE YA_FILIAL       = '" + xFilial("SYA") + "' "
cQuery += "     AND YA_CODGI        = A2.A2_PAIS "
cQuery += "     AND SYA.D_E_L_E_T_  = ' ' ),' ') EEC_PAISDU, " + ENTER

cQuery += "       A1.A1_END,EEC.EEC_ENQCOD,EEC.EEC_ENQCO1,EEC.EEC_ENQCO2,EEC.EEC_ENQCO3, "
cQuery += "       A2.A2_EST,A2.A2_END, " + ENTER

cQuery += "  ISNULL((SELECT YA_PAISDUE "
cQuery += "   FROM " + RetSQLName("SYA") + " SYA "
cQuery += "   WHERE YA_FILIAL       = '" + xFilial("SYA") + "' "
cQuery += "     AND YA_CODGI        = A1.A1_PAIS "
cQuery += "     AND SYA.D_E_L_E_T_  = ' ' ),' ') EEC_PAISIM, " + ENTER
cQuery += "       EEC.EEC_MOTDIS, " + ENTER

cQuery += "  ISNULL((SELECT EVN_DESCRI "
cQuery += "   FROM " + RetSQLName("EVN") + " EVN "
cQuery += "   WHERE EVN_FILIAL      = '" + xFilial("EVN") + "' "
cQuery += "     AND EVN_GRUPO       = 'ACG' "
cQuery += "     AND EVN_CODIGO      = EEC.EEC_MOTDIS "
cQuery += "     AND EVN.D_E_L_E_T_  = ' '),' ') EEC_DESDIS, " + ENTER

cQuery += "     EEC.EEC_VALCOM, EEC.EEC_TOTFOB " + ENTER
// cQuery += "       ISNULL(CAST(EEC_OBSFOR AS "+cVarChar+"),'') EEC_OBSFOR,
// cQuery += "       ISNULL(CAST(EEC_OBSSIT AS "+cVarChar+"),'') EEC_OBSSIT,
// cQuery += "       ISNULL(CAST(EEC_OBSTRA AS "+cVarChar+"),'') EEC_OBSTRA, "
// ISNULL(CAST(EEC_OBSPED AS "+cVarChar+"),'') EEC_OBSPED "
// OSSME-4657 - Erro na alteração do embarque com DU-e gerada - MPG/23/04/2020 
// Querys mantidas como uma alternativa a comparação de hash dos campos memos, 
// no caso do oracle não é permitido uso de campos lob em sqls com union, distinct e outros por isso a necessidade da subquery convertendo o campo de lob para char 
// if cDBMS == "ORACLE"
//    cQuery += " (SELECT to_char(EEC_OBSFOR) FROM " + TETempName("WK_EECDUE") + " TMPFOR WHERE  EEC.EEC_FILIAL = TMPFOR.EEC_FILIAL AND EEC.EEC_PREEMB = TMPFOR.EEC_PREEMB AND TMPFOR.D_E_L_E_T_=' ')  EEC_OBSFORM, " + ENTER
//    cQuery += " (SELECT to_char(EEC_OBSSIT) FROM " + TETempName("WK_EECDUE") + " TMPSIT WHERE  EEC.EEC_FILIAL = TMPSIT.EEC_FILIAL AND EEC.EEC_PREEMB = TMPSIT.EEC_PREEMB AND TMPSIT.D_E_L_E_T_=' ')  EEC_OBSSIT, " + ENTER
//    cQuery += " (SELECT to_char(EEC_OBSTRA) FROM " + TETempName("WK_EECDUE") + " TMPTRA WHERE  EEC.EEC_FILIAL = TMPTRA.EEC_FILIAL AND EEC.EEC_PREEMB = TMPTRA.EEC_PREEMB AND TMPTRA.D_E_L_E_T_=' ')  EEC_OBSTRA, " + ENTER
//    cQuery += " (SELECT to_char(EEC_OBSPED) FROM " + TETempName("WK_EECDUE") + " TMPPED WHERE  EEC.EEC_FILIAL = TMPPED.EEC_FILIAL AND EEC.EEC_PREEMB = TMPPED.EEC_PREEMB AND TMPPED.D_E_L_E_T_=' ')  EEC_OBSPED  " + ENTER
// else
//    cQuery += " (SELECT EEC_OBSFOR FROM " + TETempName("WK_EECDUE") + " TMPFOR WHERE EEC.EEC_FILIAL = TMPFOR.EEC_FILIAL AND EEC.EEC_PREEMB = TMPFOR.EEC_PREEMB AND TMPFOR.D_E_L_E_T_=' ' ) EEC_OBSFOR, " + ENTER
//    cQuery += " (SELECT EEC_OBSSIT FROM " + TETempName("WK_EECDUE") + " TMPSIT WHERE EEC.EEC_FILIAL = TMPSIT.EEC_FILIAL AND EEC.EEC_PREEMB = TMPSIT.EEC_PREEMB AND TMPSIT.D_E_L_E_T_=' ' ) EEC_OBSSIT, " + ENTER
//    cQuery += " (SELECT EEC_OBSTRA FROM " + TETempName("WK_EECDUE") + " TMPTRA WHERE EEC.EEC_FILIAL = TMPTRA.EEC_FILIAL AND EEC.EEC_PREEMB = TMPTRA.EEC_PREEMB AND TMPTRA.D_E_L_E_T_=' ' ) EEC_OBSTRA, " + ENTER
//    cQuery += " (SELECT EEC_OBSPED FROM " + TETempName("WK_EECDUE") + " TMPPED WHERE EEC.EEC_FILIAL = TMPPED.EEC_FILIAL AND EEC.EEC_PREEMB = TMPPED.EEC_PREEMB AND TMPPED.D_E_L_E_T_=' ' ) EEC_OBSPED " + ENTER
// endif
cQuery += " FROM " + TETempName("WK_EECDUE") + " EEC "
cQuery += " INNER JOIN " + RetSQLName("SA1") + " A1 ON (A1.A1_FILIAL='" + xFilial("SA1") + "' "
cQuery += "                         AND EEC.EEC_IMPORT = A1.A1_COD "
cQuery += "                         AND EEC.EEC_IMLOJA = A1.A1_LOJA) " + ENTER
cQuery += " INNER JOIN " + RetSQLName("SA2") + " A2 ON (A2.A2_FILIAL='" + xFilial("SA2") + "' "
cQuery += "                         AND EEC.EEC_FORN   = A2.A2_COD "
cQuery += "                         AND EEC.EEC_FOLOJA = A2.A2_LOJA) " + ENTER
cQuery += " WHERE EEC.EEC_FILIAL = '" + M->EEC_FILIAL + "' " //xFilial("EEC")
cQuery += "  AND EEC.EEC_PREEMB  = '" + M->EEC_PREEMB  + "' "
cQuery += "  AND EEC.D_E_L_E_T_ = ' ' "
cQuery += "  AND A1.D_E_L_E_T_ =' '   "
cQuery += "  AND A2.D_E_L_E_T_ =' '   " + ENTER

cQuery += " UNION " + ENTER

cQuery += " SELECT EK1A.EK1_FILIAL,EK1A.EK1_PROCES,EK1A.EK1_NRODUE,EK1A.EK1_URFDSP,EK1A.EK1_RECALF,EK1A.EK1_EMFRRC,EK1A.EK1_FOREXP, "
if EK1->(fieldpos("EK1_ENQCOX")) > 0
   cQuery += "        EK1A.EK1_ENQCOX, "
endif
If EK1->(FieldPos("EK1_PAISET")) > 0
    cQuery += " EK1A.EK1_PAISET, " + ENTER
EndIf
cQuery += "        EK1A.EK1_DESFOR, "
cQuery += " EK1A.EK1_SITESP,EK1A.EK1_DESSIT, "
cQuery += "        EK1A.EK1_ESPTRA,EK1A.EK1_DESTRA, "
cQuery += " EK1A.EK1_MOEDA ,EK1A.EK1_FORN  ,EK1A.EK1_FOLOJA, "
cQuery += "        EK1A.EK1_FORNDE,EK1A.EK1_CGC   ,EK1A.EK1_NRORUC,EK1A.EK1_INCOTE,EK1A.EK1_IMPORT,EK1A.EK1_IMLOJA, "
cQuery += "        EK1A.EK1_IMPODE,EK1A.EK1_PAISDU,EK1A.EK1_ENDIMP,EK1A.EK1_ENQCOD,EK1A.EK1_ENQCO1,EK1A.EK1_ENQCO2, "
cQuery += "        EK1A.EK1_ENQCO3,EK1A.EK1_FOREST,EK1A.EK1_FOREND,EK1A.EK1_PAISIM,EK1A.EK1_MOTDIS,EK1A.EK1_DESDIS, "
cQuery += "        EK1A.EK1_VALCOM,EK1A.EK1_TOTFOB " + ENTER
// cQuery += " ISNULL(CAST(EK1_OBSFOR AS "+cVarChar+"),'') EK1_OBSFOR, "
// cQuery += " ISNULL(CAST(EK1_OBSSIT AS "+cVarChar+"),'') EK1_OBSSIT, "
// cQuery += " ISNULL(CAST(EK1_OBSTRA AS "+cVarChar+"),'') EK1_OBSTRA, "
// cQuery += " ISNULL(CAST(EK1_OBSPED AS "+cVarChar+"),'') EK1_OBSPED "
// OSSME-4657 - Erro na alteração do embarque com DU-e gerada - MPG/23/04/2020 
// Querys mantidas como uma alternativa a comparação de hash dos campos memos, 
// no caso do oracle não é permitido uso de campos lob em sqls com union, distinct e outros por isso a necessidade da subquery convertendo o campo de lob para char 
// if cDBMS == "ORACLE" 
//    cQuery += " (SELECT to_char(EK1FOR.EK1_OBSFOR) FROM " + RetSQLName("EK1") + " EK1FOR WHERE  EK1FOR.EK1_FILIAL = EK1A.EK1_FILIAL AND EK1FOR.EK1_PROCES = EK1A.EK1_PROCES AND EK1FOR.D_E_L_E_T_=' ')  EK1_OBSFORM, " + ENTER
//    cQuery += " (SELECT to_char(EK1SIT.EK1_OBSSIT) FROM " + RetSQLName("EK1") + " EK1SIT WHERE  EK1SIT.EK1_FILIAL = EK1A.EK1_FILIAL AND EK1SIT.EK1_PROCES = EK1A.EK1_PROCES AND EK1SIT.D_E_L_E_T_=' ')  EK1_OBSSIT, " + ENTER
//    cQuery += " (SELECT to_char(EK1TRA.EK1_OBSTRA) FROM " + RetSQLName("EK1") + " EK1TRA WHERE  EK1TRA.EK1_FILIAL = EK1A.EK1_FILIAL AND EK1TRA.EK1_PROCES = EK1A.EK1_PROCES AND EK1TRA.D_E_L_E_T_=' ')  EK1_OBSTRA, " + ENTER
//    cQuery += " (SELECT to_char(EK1PED.EK1_OBSPED) FROM " + RetSQLName("EK1") + " EK1PED WHERE  EK1PED.EK1_FILIAL = EK1A.EK1_FILIAL AND EK1PED.EK1_PROCES = EK1A.EK1_PROCES AND EK1PED.D_E_L_E_T_=' ' )  EK1_OBSPED  " + ENTER
// else
//    cQuery += " (SELECT EK1FOR.EK1_OBSFOR FROM " + RetSQLName("EK1") + " EK1FOR WHERE  EK1FOR.EK1_FILIAL = EK1A.EK1_FILIAL AND EK1FOR.EK1_PROCES = EK1A.EK1_PROCES AND EK1FOR.D_E_L_E_T_=' ' ) EK1_OBSFOR, " + ENTER
//    cQuery += " (SELECT EK1SIT.EK1_OBSSIT FROM " + RetSQLName("EK1") + " EK1SIT WHERE  EK1SIT.EK1_FILIAL = EK1A.EK1_FILIAL AND EK1SIT.EK1_PROCES = EK1A.EK1_PROCES AND EK1SIT.D_E_L_E_T_=' ' ) EK1_OBSSIT, " + ENTER
//    cQuery += " (SELECT EK1TRA.EK1_OBSTRA FROM " + RetSQLName("EK1") + " EK1TRA WHERE  EK1TRA.EK1_FILIAL = EK1A.EK1_FILIAL AND EK1TRA.EK1_PROCES = EK1A.EK1_PROCES AND EK1TRA.D_E_L_E_T_=' ' ) EK1_OBSTRA, " + ENTER
//    cQuery += " (SELECT EK1PED.EK1_OBSPED FROM " + RetSQLName("EK1") + " EK1PED WHERE  EK1PED.EK1_FILIAL = EK1A.EK1_FILIAL AND EK1PED.EK1_PROCES = EK1A.EK1_PROCES AND EK1PED.D_E_L_E_T_=' ' ) EK1_OBSPED " + ENTER
// endif
cQuery += " FROM " + RetSQLName("EK1") + " EK1A " + ENTER
cQuery += " WHERE EK1A.D_E_L_E_T_=' ' "
cQuery += "  AND EK1A.EK1_FILIAL = '" +  M->EEC_FILIAL + "' " //xFilial("EK1")
cQuery += "  AND EK1A.EK1_PROCES  = '" + M->EEC_PREEMB  + "' "
cQuery += "  AND EK1A.EK1_NUMSEQ  = '" + nSeq + "' "

cQuery      := ChangeQuery(cQuery)
nQtdDifDUE  := EasyQryCount(cQuery)

If nQtdDifDUE > 1
    lRet := .T.
EndIf

// OSSME-4657 - Erro na alteração do embarque com DU-e gerada - MPG/23/04/2020 
if !lRet .and. EK1->(dbsetorder(1),dbseek(M->EEC_FILIAL+M->EEC_PREEMB+nSeq))
   if !(    md5(EK1->EK1_OBSFOR,2) == md5(WK_EECDUE->EEC_OBSFOR,2) ;
      .and. md5(EK1->EK1_OBSSIT,2) == md5(WK_EECDUE->EEC_OBSSIT,2) ;
      .and. md5(EK1->EK1_OBSTRA,2) == md5(WK_EECDUE->EEC_OBSTRA,2) ;
      .and. md5(EK1->EK1_OBSPED,2) == md5(WK_EECDUE->EEC_OBSPED,2))
      lRet := .T.
   endif
endif

WK_EECDUE->(E_EraseArq(cTmpEECDUE,,,,.T.))

Return lRet

/*
Funcao     : DiffEE9EK2()
Parametros : cSeqHist - Sequencia do Historico a ser compadaro
Retorno    : lRet - Retorna se existe diferença entre EE9 e EK2
Objetivos  : Verificar se existe diferença entre os itens do processo que está sendo gravado e a última versão da due gerada
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 10/05/2018
*/
Static Function DiffEE9EK2(cSeqHist,lEmbTemNF)
Local lRet      := .F.
Local cQuery    := ""
Local cTmpEE9DUE:= ""
Local nQtdDifDUE:= 0
Local cCamposEE9:= ""
Local cCamposEK2:= ""
Local cGroupEE9 := ""

If lEmbTemNF
    cCamposEE9 := " EE9_PREEMB, EE9_SEQUEN, EE9_ATOCON, EE9_PCARGA, EE9_OBSPCA, EE9_PERCOM, EE9_LPCO, EE9_VM_DES, EE9_POSIPI, EE9_UNIDAD, EE9_PEDIDO,EE9_NF, EE9_SERIE , EE9_SEQEMB, EE9_UNPES , EE9_PSLQUN" + iif( AvFlags("DESTAQ") , ", ISNULL(EYJ.EYJ_DESEXP,'') EYJ_DESEXP " , "")
    cCamposEK2 := " EK2_PROCES, EK2_SEQUEN, EK2_ATOCON, EK2_PCARGA, EK2_OBSPCA, EK2_PERCOM, EK2_LPCO ,EK2_VM_DES, EK2_POSIPI, EK2_UNIDAD, EK2_PEDIDO,EK2_NRNF, EK2_SERIE , EK2_SEQEMB, EK2_UNPES,EK2_PSLQUN" + iif( AvFlags("DESTAQ") , ", EK2_DESTAQ " , "")
    cGroupEE9  := " EE9_PREEMB, EE9_SEQUEN, EE9_ATOCON, EE9_PCARGA, EE9_OBSPCA, EE9_PERCOM, EE9_LPCO, EE9_VM_DES, EE9_POSIPI, EE9_UNIDAD, EE9_PEDIDO,EE9_NF, EE9_SERIE , EE9_SEQEMB, EE9_UNPES , EE9_PSLQUN" + iif( AvFlags("DESTAQ") , ", EYJ_DESEXP " , "")
Else
    cCamposEE9 := " EE9_PREEMB, EE9_SEQUEN, EE9_COD_I, EE9_SLDINI, EE9_PRCTOT, EE9_PRCINC, EE9_ATOCON, EE9_PCARGA, EE9_OBSPCA, EE9_PERCOM, EE9_LPCO, EE9_VM_DES, EE9_POSIPI, EE9_UNIDAD, EE9_PEDIDO, EE9_NF, EE9_SERIE , EE9_SEQEMB, EE9_UNPES, EE9_PSLQUN " + iif( AvFlags("DESTAQ") , ", ISNULL(EYJ.EYJ_DESEXP,'') EYJ_DESEXP " , "")
    cCamposEK2 := " EK2_PROCES, EK2_SEQUEN, EK2_COD_I, EK2_SLDINI, EK2_PRCTOT, EK2_PRCINC, EK2_ATOCON, EK2_PCARGA, EK2_OBSPCA, EK2_PERCOM, EK2_LPCO, EK2_VM_DES, EK2_POSIPI, EK2_UNIDAD, EK2_PEDIDO, EK2_NRNF, EK2_SERIE , EK2_SEQEMB, EK2_UNPES,EK2_PSLQUN" + iif( AvFlags("DESTAQ") , ", EK2_DESTAQ " , "")
    cGroupEE9  := " EE9_PREEMB, EE9_SEQUEN, EE9_COD_I, EE9_SLDINI, EE9_PRCTOT, EE9_PRCINC, EE9_ATOCON, EE9_PCARGA, EE9_OBSPCA, EE9_PERCOM, EE9_LPCO, EE9_VM_DES, EE9_POSIPI, EE9_UNIDAD, EE9_PEDIDO, EE9_NF, EE9_SERIE , EE9_SEQEMB, EE9_UNPES, EE9_PSLQUN " + iif( AvFlags("DESTAQ") , ", EYJ_DESEXP " , "")
EndIf

cTmpEE9DUE := DUECriaTmp("EE9",lEmbTemNF)

cQuery += " SELECT COUNT(*) QTD_REG "
cQuery += " FROM  (SELECT " + cCamposEE9 + " "
cQuery += "        FROM   " + TETempName("WK_EE9DUE") + " EE9 "
cQuery += "             LEFT JOIN " + RetSQLName("EYJ") + " EYJ "
cQuery += "             ON  EYJ.EYJ_COD     = EE9.EE9_COD_I "
cQuery += "             AND EYJ.EYJ_FILIAL  = '" + xFilial("EYJ")   + "' "
cQuery += "             AND EYJ.D_E_L_E_T_ = ' ' "

cQuery += "        WHERE  EE9_PREEMB = '" + M->EEC_PREEMB +"' "
cQuery += "               AND EE9.D_E_L_E_T_ = ' ' "
       
cQuery += " 	   UNION ALL "
       
cQuery += " 	   SELECT DISTINCT " + cCamposEK2 + " "
cQuery += "        FROM   " + RetSQLName("EK2") + " EK2 "
cQuery += "        WHERE  EK2_FILIAL     = '" + xFilial("EK2")   + "' "
cQuery += "               AND EK2_PROCES = '" + M->EEC_PREEMB + "' "
cQuery += "               AND EK2_NUMSEQ = (SELECT MAX(EK1_NUMSEQ) "
cQuery += "                                 FROM " + RetSQLName("EK1") + " EK1 "
cQuery += "                                 WHERE  EK1.EK1_FILIAL = EK2.EK2_FILIAL "
cQuery += "                                        AND EK1.EK1_PROCES = EK2.EK2_PROCES "
cQuery += "                                        AND EK1.D_E_L_E_T_ = ' ') "
cQuery += "               AND EK2.D_E_L_E_T_ = ' ') TEMPEK2DUE "
cQuery += " GROUP  BY " + cGroupEE9 + " "
cQuery += " HAVING COUNT(*) != 2 "

cQuery      := ChangeQuery(cQuery)
nQtdDifDUE  := EasyQryCount(cQuery)

If nQtdDifDUE > 0
    lRet := .T.
EndIf

WK_EE9DUE->(E_EraseArq(cTmpEE9DUE,,,,.T.))

Return lRet

/*
Funcao     : DiffEEMEK3()
Parametros : cSeqHist - Sequencia do Historico a ser compadaro
Retorno    : lRet - Retorna se existe diferença entre EEM e EK3
Objetivos  : Verificar se existe diferença entre a capa da nota do processo que está sendo gravado e a última versão da due gerada
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 10/05/2018
*/
Static Function DiffEEMEK3(cSeqHist)
Local lRet      := .F.
Local cQuery    := ""

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM " + RetSQLName("EK3") + " "
cQuery += " WHERE	EK3_FILIAL = '" + xFilial("EK3") +"' "
cQuery += " 	AND EK3_PROCES = '" + M->EEC_PREEMB +"' "
cQuery += " 	AND EK3_NUMSEQ = '" + cSeqHist +"' "

cQuery += " 	AND EK3_TIPOCA = '" + WorkNF->(EEM_TIPOCA) +"' "
cQuery += " 	AND EK3_NRNF   = '" + WorkNF->(EEM_NRNF) +"' "
cQuery += " 	AND EK3_SERIE  = '" + WorkNF->(EEM_SERIE) +"' "
cQuery += " 	AND EK3_DTNF   = '" + DtoS(WorkNF->(EEM_DTNF)) +"' "
cQuery += " 	AND EK3_CODEMI = '" + M->EEC_IMPORT +"' "
cQuery += " 	AND EK3_LOJEMI = '" + M->EEC_IMLOJA +"' "
//cQuery += " 	AND EK3_CGC    = '" + WorkNF->() +"' "
cQuery += " 	AND EK3_CHVNFE = '" + WorkNF->(EEM_CHVNFE) +"' "
cQuery += "     AND D_E_L_E_T_ = ' ' "

If Select("TMPEK3") > 0
    TMPEK3->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQuery), "TMPEK3", .T., .T.)

If TMPEK3->(EOF())
    lRet := .T.
EndIf

TMPEK3->(dbCloseArea())

Return lRet

/*
Funcao     : DiffEYYEK4()
Parametros : cSeqHist - Sequencia do Historico a ser compadaro
Retorno    : lRet - Retorna se existe diferença entre EYY e EK4
Objetivos  : Verificar se existe diferença entre as notas de Remessa vinculadas ao processo e as notas de Remessa salvas na DUE
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 10/05/2018
*/
Static Function DiffEYYEK4(cSeqHist)
Local aAreaEE9 := EE9->(getarea())
Local lRet      := .F.
Local cQuery    := ""

cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM " + RetSQLName("EK4") + " "
cQuery += " WHERE	EK4_FILIAL = '" + xFilial("EK4") +"' "
cQuery += " 	AND EK4_PROCES = '" + M->EEC_PREEMB +"' "
cQuery += " 	AND EK4_NUMSEQ = '" + cSeqHist +"' "

cQuery += " 	AND EK4_SEQUEN = '" + WK_NFRem->(EYY_SEQEMB) +"' "
cQuery += " 	AND EK4_NFENT  = '" + WK_NFRem->(EYY_NFENT) +"' "
cQuery += " 	AND EK4_SERENT = '" + WK_NFRem->(EYY_SERENT) +"' "
//cQuery += " 	AND EK4_ESPECI = '" + WK_NFRem->() +"' "
cQuery += " 	AND EK4_FORNEC = '" + WK_NFRem->(EYY_FORN) +"' "
cQuery += " 	AND EK4_LOJA   = '" + WK_NFRem->(EYY_FOLOJA) +"' "
//cQuery += " 	AND EK4_CGC    = '" + WK_NFRem->() +"' "
cQuery += " 	AND EK4_PEDIDO = '" + WK_NFRem->(EYY_PEDIDO) +"' "
cQuery += " 	AND EK4_SEQPED = '" + WK_NFRem->(EYY_SEQUEN) +"' "
cQuery += " 	AND EK4_COD_I  = '" + WK_NFRem->(EYY_D1PROD) +"' "
If AvFlags("ROTINA_VINC_FIM_ESPECIFICO_RP12.1.20")
   cQuery += " 	AND EK4_QUANT  = "  + Alltrim(Str( AVTransUnid(WK_NFRem->EYY_UNIDAD,BuscaNCM(WK_NFRem->EYY_POSIPI, "YD_UNID"),WK_NFRem->EYY_D1PROD,WK_NFRem->(EYY_QUANT)) )) +" " // WK_NFRem->(EYY_QUANT)
else
   PosEE9ItNF(xFilial("EE9")+WK_NFRem->(EYY_PREEMB+EYY_PEDIDO+EYY_SEQEMB), WK_NFRem->EYY_NFSAI , WK_NFRem->EYY_SERSAI)
   cQuery += " 	AND EK4_QUANT  = "  + Alltrim(Str( AVTransUnid(EE9->EE9_UNIDAD,BuscaNCM(EE9->EE9_POSIPI, "YD_UNID"),EE9->EE9_COD_I,EE9->EE9_SLDINI ))) +" "
endif
cQuery += " 	AND EK4_D1ITEM = '" + WK_NFRem->(EYY_D1ITEM) +"' "
cQuery += " 	AND EK4_CHVNFE = '" + WK_NFRem->(EYY_CHVNFE) +"' "
cQuery += " 	AND EK4_NFSAI  = '" + WK_NFRem->(EYY_NFSAI) +"' "
cQuery += " 	AND EK4_SERSAI = '" + WK_NFRem->(EYY_SERSAI) +"' "
cQuery += "     AND D_E_L_E_T_ = ' ' "

If Select("TMPEK4") > 0
    TMPEK4->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQuery), "TMPEK4", .T., .T.)

If TMPEK4->(EOF())
    lRet := .T.
EndIf

TMPEK4->(dbCloseArea())
restarea(aAreaEE9)

Return lRet

/*
Funcao     : DUETotReg()
Parametros : cAliasHist - Tabela a ter a quantidade de registros contatos;
             aQryCampos - Array com os campos a serem utilizados na query e os dados a serem pesquisados;
Retorno    : nRet - Retorna a quantidade de registros para a tabela
Objetivos  : Verificar quantos registros possue a tabela com base na chave informada
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 10/05/2018
*/
Static Function DUETotReg(cAliasHist,aQryCampos)
Local nRet      := 0
Local cQuery    := ""
Local nI

cQuery := " SELECT COUNT(R_E_C_N_O_) QTD_REG"
cQuery += " FROM " + RetSQLName(cAliasHist) + " "
cQuery += " WHERE "
For nI := 1 To Len(aQryCampos)
    cQuery +=       aQryCampos[nI][1] + "  = '" + aQryCampos[nI][2] + "' AND "
Next
cQuery += "     D_E_L_E_T_ = ' ' "

If Select("TMPCOUNT") > 0
    TMPCOUNT->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQuery), "TMPCOUNT", .T., .T.)

If TMPCOUNT->(!EOF())
    nRet := TMPCOUNT->(QTD_REG)
EndIf

TMPCOUNT->(dbCloseArea())

Return nRet


/*
Funcao     : IsRemDiff()
Parametros : -
Retorno    : lRet - .T. Deve realizar a comparacao com EK4; .F. Nao deve comparar com a EK4;
Objetivos  : Verifica se algum item da Work WK_NFRem precisa ser comparado com o historico da DUE
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 15/05/2018
*/
Static Function IsRemDiff()
Local lRet      := .T.

If Empty(WK_NFRem->EYY_NFENT)

    If WK_NFRem->EYY_RECNO <> 0
        EYY->(DbGoTo(WK_NFRem->EYY_RECNO))
        If Empty(EYY->EYY_NFENT)
            lRet := .F.
        EndIf
    Else
        lRet := .F.
    EndIf

EndIf

Return lRet

/*
Funcao     : DUECriaTmp()
Parametros : -
Retorno    : cRet - Nome do arquivo temporario criado no banco de dados
Objetivos  : Cria Work temporária no banco de dados
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 22/05/2018
*/
Static Function DUECriaTmp(cAliasDUE,lEmbTemNF)
Local cRet      := ""
Local aEstruDUE := {}

If cAliasDUE == "EEC"

    aAdd(aEstruDUE, {"EEC_FILIAL", AVSX3('EEC_FILIAL',AV_TIPO), AVSX3('EEC_FILIAL',AV_TAMANHO), AVSX3('EEC_FILIAL',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_PREEMB", AVSX3('EEC_PREEMB',AV_TIPO), AVSX3('EEC_PREEMB',AV_TAMANHO), AVSX3('EEC_PREEMB',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_NRODUE", AVSX3('EEC_NRODUE',AV_TIPO), AVSX3('EEC_NRODUE',AV_TAMANHO), AVSX3('EEC_NRODUE',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_URFDSP", AVSX3('EEC_URFDSP',AV_TIPO), AVSX3('EEC_URFDSP',AV_TAMANHO), AVSX3('EEC_URFDSP',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_RECALF", AVSX3('EEC_RECALF',AV_TIPO), AVSX3('EEC_RECALF',AV_TAMANHO), AVSX3('EEC_RECALF',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_EMFRRC", AVSX3('EEC_EMFRRC',AV_TIPO), AVSX3('EEC_EMFRRC',AV_TAMANHO), AVSX3('EEC_EMFRRC',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_FOREXP", AVSX3('EEC_FOREXP',AV_TIPO), AVSX3('EEC_FOREXP',AV_TAMANHO), AVSX3('EEC_FOREXP',AV_DECIMAL)})
   if EK1->(fieldpos("EK1_ENQCOX")) > 0
      aAdd(aEstruDUE, {"EEC_ENQCOX", AVSX3('EEC_ENQCOX',AV_TIPO), AVSX3('EEC_ENQCOX',AV_TAMANHO), AVSX3('EEC_ENQCOX',AV_DECIMAL)})
   endif
   If EK1->(fieldpos("EK1_PAISET")) > 0
      aAdd(aEstruDUE, {"EEC_PAISET", AVSX3('EEC_PAISET',AV_TIPO), AVSX3('EEC_PAISET',AV_TAMANHO), AVSX3('EEC_PAISET',AV_DECIMAL)})
   EndIf
    aAdd(aEstruDUE, {"EEC_OBSFOR", AVSX3('EEC_OBSFOR',AV_TIPO), AVSX3('EEC_OBSFOR',AV_TAMANHO), AVSX3('EEC_OBSFOR',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_SITESP", AVSX3('EEC_SITESP',AV_TIPO), AVSX3('EEC_SITESP',AV_TAMANHO), AVSX3('EEC_SITESP',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_OBSSIT", AVSX3('EEC_OBSSIT',AV_TIPO), AVSX3('EEC_OBSSIT',AV_TAMANHO), AVSX3('EEC_OBSSIT',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_ESPTRA", AVSX3('EEC_ESPTRA',AV_TIPO), AVSX3('EEC_ESPTRA',AV_TAMANHO), AVSX3('EEC_ESPTRA',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_OBSTRA", AVSX3('EEC_OBSTRA',AV_TIPO), AVSX3('EEC_OBSTRA',AV_TAMANHO), AVSX3('EEC_OBSTRA',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_MOEDA",  AVSX3('EEC_MOEDA' ,AV_TIPO), AVSX3('EEC_MOEDA' ,AV_TAMANHO), AVSX3('EEC_MOEDA' ,AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_FORN",   AVSX3('EEC_FORN'  ,AV_TIPO), AVSX3('EEC_FORN'  ,AV_TAMANHO), AVSX3('EEC_FORN'  ,AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_FOLOJA", AVSX3('EEC_FOLOJA',AV_TIPO), AVSX3('EEC_FOLOJA',AV_TAMANHO), AVSX3('EEC_FOLOJA',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_NRORUC", AVSX3('EEC_NRORUC',AV_TIPO), AVSX3('EEC_NRORUC',AV_TAMANHO), AVSX3('EEC_NRORUC',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_INCOTE", AVSX3('EEC_INCOTE',AV_TIPO), AVSX3('EEC_INCOTE',AV_TAMANHO), AVSX3('EEC_INCOTE',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_IMPORT", AVSX3('EEC_IMPORT',AV_TIPO), AVSX3('EEC_IMPORT',AV_TAMANHO), AVSX3('EEC_IMPORT',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_IMLOJA", AVSX3('EEC_IMLOJA',AV_TIPO), AVSX3('EEC_IMLOJA',AV_TAMANHO), AVSX3('EEC_IMLOJA',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_IMPODE", AVSX3('EEC_IMPODE',AV_TIPO), AVSX3('EEC_IMPODE',AV_TAMANHO), AVSX3('EEC_IMPODE',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_ENDIMP", AVSX3('EEC_ENDIMP',AV_TIPO), AVSX3('EEC_ENDIMP',AV_TAMANHO), AVSX3('EEC_ENDIMP',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_ENQCOD", AVSX3('EEC_ENQCOD',AV_TIPO), AVSX3('EEC_ENQCOD',AV_TAMANHO), AVSX3('EEC_ENQCOD',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_ENQCO1", AVSX3('EEC_ENQCO1',AV_TIPO), AVSX3('EEC_ENQCO1',AV_TAMANHO), AVSX3('EEC_ENQCO1',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_ENQCO2", AVSX3('EEC_ENQCO2',AV_TIPO), AVSX3('EEC_ENQCO2',AV_TAMANHO), AVSX3('EEC_ENQCO2',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_ENQCO3", AVSX3('EEC_ENQCO3',AV_TIPO), AVSX3('EEC_ENQCO3',AV_TAMANHO), AVSX3('EEC_ENQCO3',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_MOTDIS", AVSX3('EEC_MOTDIS',AV_TIPO), AVSX3('EEC_MOTDIS',AV_TAMANHO), AVSX3('EEC_MOTDIS',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_VALCOM", AVSX3('EEC_VALCOM',AV_TIPO), AVSX3('EEC_VALCOM',AV_TAMANHO), AVSX3('EEC_VALCOM',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_TOTFOB", AVSX3('EEC_TOTFOB',AV_TIPO), AVSX3('EEC_TOTFOB',AV_TAMANHO), AVSX3('EEC_TOTFOB',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EEC_OBSPED", AVSX3('EEC_OBSPED',AV_TIPO), AVSX3('EEC_OBSPED',AV_TAMANHO), AVSX3('EEC_OBSPED',AV_DECIMAL)})

    cRet := E_CriaTrab(,aEstruDUE,"WK_EECDUE",,,,,.T.)
    IndRegua("WK_EECDUE", cRet , "EEC_FILIAL + EEC_PREEMB")

    WK_EECDUE->(dbAppend())
    AvReplace("M","WK_EECDUE")
    WK_EECDUE->(dbCommit())

ElseIf cAliasDUE == "EE9"

    aAdd(aEstruDUE, {"EE9_PREEMB" , AVSX3('EE9_PREEMB',AV_TIPO), AVSX3('EE9_PREEMB',AV_TAMANHO), AVSX3('EE9_PREEMB',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_COD_I"  , AVSX3('EE9_COD_I' ,AV_TIPO), AVSX3('EE9_COD_I' ,AV_TAMANHO), AVSX3('EE9_COD_I' ,AV_DECIMAL)})

    If !lEmbTemNF //Nao tem Nota
        aAdd(aEstruDUE, {"EE9_SLDINI" , AVSX3('EE9_SLDINI',AV_TIPO), AVSX3('EE9_SLDINI',AV_TAMANHO), AVSX3('EE9_SLDINI',AV_DECIMAL)})
        aAdd(aEstruDUE, {"EE9_PRCTOT" , AVSX3('EE9_PRCTOT',AV_TIPO), AVSX3('EE9_PRCTOT',AV_TAMANHO), AVSX3('EE9_PRCTOT',AV_DECIMAL)})
        aAdd(aEstruDUE, {"EE9_PRCINC" , AVSX3('EE9_PRCINC',AV_TIPO), AVSX3('EE9_PRCINC',AV_TAMANHO), AVSX3('EE9_PRCINC',AV_DECIMAL)})
    EndIf

    aAdd(aEstruDUE, {"EE9_SEQUEN" , AVSX3('EE9_SEQUEN',AV_TIPO), AVSX3('EE9_SEQUEN',AV_TAMANHO), AVSX3('EE9_SEQUEN',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_ATOCON" , AVSX3('EE9_ATOCON',AV_TIPO), AVSX3('EE9_ATOCON',AV_TAMANHO), AVSX3('EE9_ATOCON',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_PCARGA" , AVSX3('EE9_PCARGA',AV_TIPO), AVSX3('EE9_PCARGA',AV_TAMANHO), AVSX3('EE9_PCARGA',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_OBSPCA" , AVSX3('EE9_OBSPCA',AV_TIPO), AVSX3('EE9_OBSPCA',AV_TAMANHO), AVSX3('EE9_OBSPCA',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_PERCOM" , AVSX3('EE9_PERCOM',AV_TIPO), AVSX3('EE9_PERCOM',AV_TAMANHO), AVSX3('EE9_PERCOM',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_LPCO"   , AVSX3('EE9_LPCO'  ,AV_TIPO), AVSX3('EE9_LPCO'  ,AV_TAMANHO), AVSX3('EE9_LPCO'  ,AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_VM_DES" , AVSX3('EE9_VM_DES',AV_TIPO), AVSX3('EE9_VM_DES',AV_TAMANHO), AVSX3('EE9_VM_DES',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_POSIPI" , AVSX3('EE9_POSIPI',AV_TIPO), AVSX3('EE9_POSIPI',AV_TAMANHO), AVSX3('EE9_POSIPI',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_UNIDAD" , AVSX3('EE9_UNIDAD',AV_TIPO), AVSX3('EE9_UNIDAD',AV_TAMANHO), AVSX3('EE9_UNIDAD',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_PEDIDO" , AVSX3('EE9_PEDIDO',AV_TIPO), AVSX3('EE9_PEDIDO',AV_TAMANHO), AVSX3('EE9_PEDIDO',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_NF"     , AVSX3('EE9_NF'    ,AV_TIPO), AVSX3('EE9_NF'    ,AV_TAMANHO), AVSX3('EE9_NF'    ,AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_SERIE"  , AVSX3('EE9_SERIE' ,AV_TIPO), AVSX3('EE9_SERIE' ,AV_TAMANHO), AVSX3('EE9_SERIE' ,AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_SEQEMB" , AVSX3('EE9_SEQEMB',AV_TIPO), AVSX3('EE9_SEQEMB',AV_TAMANHO), AVSX3('EE9_SEQEMB',AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_UNPES"  , AVSX3('EE9_UNPES' ,AV_TIPO), AVSX3('EE9_UNPES' ,AV_TAMANHO), AVSX3('EE9_UNPES' ,AV_DECIMAL)})
    aAdd(aEstruDUE, {"EE9_PSLQUN" , AVSX3('EE9_PSLQUN',AV_TIPO), AVSX3('EE9_PSLQUN',AV_TAMANHO), AVSX3('EE9_PSLQUN',AV_DECIMAL)})
    if AvFlags("DESTAQ")
        aAdd(aEstruDUE, {"EYJ_DESEXP" , AVSX3('EYJ_DESEXP',AV_TIPO), AVSX3('EYJ_DESEXP',AV_TAMANHO), AVSX3('EYJ_DESEXP',AV_DECIMAL)})
    endif
    cRet := E_CriaTrab(,aEstruDUE,"WK_EE9DUE",,,,,.T.)
    IndRegua("WK_EE9DUE", cRet , "EE9_PREEMB")

    WorkIP->(dbGoTop())
    While WorkIP->(!Eof())
    	If !Empty(WorkIP->WP_FLAG)
            WK_EE9DUE->(DbAppend())
            AvReplace("WorkIP", "WK_EE9DUE")
            WK_EE9DUE->(dbCommit())
        EndIf
        WorkIP->(DbSkip())
    End

EndIf

Return cRet

/*
Funcao     : DUEExistCP()
Parametros : -
Retorno    : lRet: .T. se existirem os campos da DUE; .F. se não existirem os campos da DUE
Objetivos  : Verificar se existe os campos EEC_NRODUE e EEC_NRORUC, mesmo com o AvFlag Desligado. 
             Utilizado para liberar os campos da DUE para quem nao quer utilziar a integracao, mas quer gravar os campos.
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 20/06/2018
*/
Static Function DUEExistCP()
Local lRet := .F.

If EEC->(FieldPos("EEC_NRODUE")) > 0 .And. EEC->(FieldPos("EEC_NRORUC")) > 0
    lRet := .T.
EndIf

Return lRet

/*
Funcao     : IntegAux()
Parametros : aAuto - Array com os dados complementares
Objetivos  : Integrar dados complementares do pedido recebidos via ExecAuto
Autor      : Rodrigo Mendes Diaz
*/
Static Function IntegAux(aAuto, nOpc)
Local cAlias, nPos, i, j, aItem

    For i := 1 To Len(aAuto)
        If lMsErroAuto
            Exit
        EndIf
        If !(ValType(aAuto[i]) == "A" .And. Len(aAuto[i]) == 2 .And. ValType(aAuto[i][1]) == "C" .And. ValType(aAuto[i][2]) == "A")
            EasyHelp(STR0267, STR0063) //"Falha de Integração: Foram informados dados complementares com a estrutura incorreta."###"Aviso"
            lMsErroAuto := .T.
            Loop
        EndIf
        cAlias := aAuto[i][1]
        If cAlias == "EEC" .Or. cAlias == "EE9"
            Loop
        EndIf
        If cAlias == "EXL"
            //Carrega os campos da tabela de dados complementares (EXL)
            EnchAuto("EXL",aAuto[i][2],{|| Obrigatorio(aGets,aTela)},nOpc, aCamposEXL)
            If lMsErroAuto
                Exit
            EndIf
        Else
            For j := 1 To Len(aAuto[i][2])
                aItem := aAuto[i][2][j]
                //Verifica se é uma operação de Exclusão
                If aScan(aItem, {|x| x[1] == "AUTDELETA" .And. X[2] == "S" }) > 0
                    nOpc := EXCLUIR
                Else
                    nOpc := INCLUIR//Será tratado como UPSERT na rotina correspondente
                EndIf
                //Executa a integração
                Do Case
                    Case cAlias == "EEN"
                        If (lMsErroAuto := !AP100Notify(OC_EM,nOpc,aItem))
                            Exit
                        EndIf
                    Case cAlias == "EXB"
                        If (lMsErroAuto := !AP100Agenda(OC_EM, nOpc, aItem))
                            Exit
                        EndIf
                    Case cAlias == "EEB"
                        If (lMsErroAuto := !AP100AGEN(OC_EM,nOpc,aItem))
                            Exit
                        EndIf
                    Case cAlias == "EET"//RMD - 24/02/20 - Possibilita a inclusão de despesas adicionais via rotina automática
                        If (lMsErroAuto := !AP100DespNac(OC_EM,nOpc,aItem))
                            Exit
                        EndIf
                    Otherwise
                        If cAlias <> "EEC" .And. cAlias <> "EE9"
                            EasyHelp(StrTran(STR0268, "XXX", cAlias), STR0063) //"Erro de integração: A tabela 'XXX' não está disponível para integração"###"Aviso"
                            lMsErroAuto := .T.
                        EndIf
                EndCase
            Next
        EndIf
    Next


Return !lMsErroAuto
/*
Essa função executa o que está no campo when da tabela sx3 para verificar se pode ser editável ou nao e retirar do
array da execução automática
Parâmetro:  cCampo -Campo a ser verificado na tabela sx3
Retorno :   lRetorno -Retorna .t. se o campo pode ser editável e .f. se não pode
*/
Static Function ValWhen(cCampo)
Local lretorno := .T.
SX3->(DBSETORDER(2))
SX3->(dbSeek(cCampo))
cWhen := SX3->X3_WHEN
lRetorno := &cWhen
Return iif(ValType(lRetorno) == "L", lRetorno, .T.) //Quando o cWhen está vazio retorna valtype = "U" caindo depois do else e retornando .t.

//Retira campos que não podem ser editados no EnchAuto
Static Function ValidaEnch(aAuto, aEdita)
Local i, nPos
Local aReturn := aClone(aAuto)
Local aRetira := {}

    For i := 1 To Len(aReturn)
        If aScan(aEdita, aReturn[i][1]) == 0 .or. !ValWhen(aReturn[i][1])
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

/*
Funcao     : AutFrtSeg()
Parametros : aEditaveis - Array com os campos editaveis da Enchoice
             aEECAuto   - Array com os dados enviados pela rotina automatica
Objetivos  : Verificar se foi enviado Frete e Seguro pela rotina automatica. A rotina automatica nao deve alterar os valores.
Autor      : Tiago Henrique Tudisco dos Santos - THTS
*/
Static Function AutFrtSeg(aEECCamposEditaveis)
Local nPosFrt
Local nPosSeg

If (nPosFrt := aScan(aEECCamposEditaveis, "EEC_FRPREV")) > 0
    aDel(aEECCamposEditaveis, nPosFrt)
    Asize(aEECCamposEditaveis, len(aEECCamposEditaveis)-1)
EndIf

If (nPosSeg := aScan(aEECCamposEditaveis, "EEC_SEGPRE")) > 0
    aDel(aEECCamposEditaveis, nPosSeg)
    Asize(aEECCamposEditaveis, len(aEECCamposEditaveis)-1)
EndIf

Return

/*
Funcao     : AtD1SLDEXP()
Parametros : -
Objetivos  : Restaurar o saldo do campo D1_SLDEXP ao excluir um embarque com notas de remessa vinculadas
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data       : 27/11/2018
*/
Static Function AtD1SLDEXP(cFilAux,cProcesso)
Local aAreaSD1 := SD1->(GetArea())
Local aAreaEYY := EYY->(GetArea())
Local aAreaEE9 := EE9->(GetArea())
Local cProduto := ""

EYY->(dbSetOrder(1)) //EYY_FILIAL + EYY_PREEMB + EYY_SEQEMB + EYY_NFSAI + EYY_SERSAI + EYY_D1ITEM
SD1->(DBSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
If EYY->(dbSeek(cFilAux + cProcesso))

    While EYY->(!Eof()) .And. cFilAux + cProcesso == EYY->EYY_FILIAL + EYY->EYY_PREEMB
        If !Empty(EYY->EYY_SEQEMB)
            EE9->(DBSetOrder(3)) //EE9_FILIAL + EE9_PREEMB + EE9_SEQEMB
            EE9->(DBSeek(cFilAux + cProcesso + EYY->EYY_SEQEMB))
        Else
            EE9->(DBSetOrder(2)) //EE9_FILIAL + EE9_PREEMB + EE9_PEDIDO + EE9_SEQUEN
            EE9->(DBSeek(cFilAux + cProcesso + EYY->EYY_PEDIDO + EYY->EYY_SEQUEN))
        EndIf
        If EasyGParam("MV_EEC0051",, .F.) .Or. !Empty(EYY->EYY_D1PROD)
            cProduto:= EYY->EYY_D1PROD
        Else
            cProduto:= EE9->EE9_COD_I
        EndIf

        If !Empty(EYY->EYY_NFENT) .And. !Empty(EYY->EYY_SERENT) .And. !Empty(EYY->EYY_FORN) .And. !Empty(EYY->EYY_FOLOJA) .And. !Empty(cProduto) .And. !Empty(EYY->EYY_D1ITEM)
            If SD1->(DBSeek(xFilial("SD1") + EYY->EYY_NFENT + EYY->EYY_SERENT + EYY->EYY_FORN + EYY->EYY_FOLOJA + AvKey(cProduto,"D1_COD") + AvKey(EYY->EYY_D1ITEM, "D1_ITEM")))
                If SD1->D1_SLDEXP + EYY->EYY_QUANT <= SD1->D1_QUANT
                    SD1->(RecLock("SD1", .F.))
                    SD1->D1_SLDEXP += EYY->EYY_QUANT
                    SD1->(MsUnlock())
                EndIf
            EndIf
        EndIf
        EYY->(dbSkip())
    End

EndIf

RestArea(aAreaEYY)
RestArea(aAreaSD1)
RestArea(aAreaEE9)
Return

//Liberar edição de campos conforme condições
Function AE100EdtCp(cCpo)  

Local   lRet := .F.
Default cCpo := ReadVar()

Do Case
   Case cCpo == "EE9_PRECO"
      If (EasyGParam("MV_AVG0081",,.f.) .And. !( lIntDraw .and. lOkEE9_ATO .and. !Empty(M->EE9_ATOCON) ) )
         lRet := .T.
      EndIf
EndCase

Return lRet

Static Function VldAltPEmb()

Local lRet      := .F.
Local cQuery    := ""
Local nCount603 :=0
Local nCountAg  := 0

//Verifica se exsite evento 603 (Adiantamento Pos Embarque), caso exista, nao deve permitir alteracao de valores pos-embarque
cQuery := " SELECT EEQ_EVENT"
cQuery += " FROM " + RetSQLName("EEQ") + " "
cQuery += " WHERE EEQ_FILIAL = '" + xFilial("EEQ") + "' "
cQuery += "   AND EEQ_PREEMB = '" + M->EEC_PREEMB + "' "
cQuery += "   AND EEQ_EVENT  = '603' "//Compensação pós-embarque
cQuery += "   AND D_E_L_E_T_ = ' ' "

nCount603 := EasyQryCount(cQuery)

If nCount603 > 0
    lRet := .T.
EndIf

//Verifica se existe mais de um Agente de Comissao no Embarque, Caso exista, nao deve permitir alteração de valores pos-embarque
If !lRet
    cQuery := " SELECT COUNT(EEB_CODAGE) QTD_CODAGE, EEB.EEB_CODAGE "
    cQuery += " FROM " + TeTempName("WorkAg") + " EEB "
    cQuery += " WHERE D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY EEB.EEB_CODAGE "

    nCountAg := EasyQryCount(cQuery)
    If nCountAg > 1
        lRet := .T.
    EndIf
EndIf

Return lRet

/*
Funcao     : ExibCpoAvb()
Parametros : -
Objetivos  : Habilitar exibição e edição do campo de averbação do RE quando houver DU-E
Autor      : Nilson César
Data       : 15/10/2019
*/
Static Function ExibCpoAvb() 

Local lRet := .T.
Local cTmpWorkIP,cTabWkIP,cQuery,nOldArea

IF EEC->(FieldPos("EEC_DUEAVR")) > 0
  
   cTmpWorkIP := GetNextAlias()

   cQuery := " SELECT COUNT(*) QTDREG" 
   cQuery += " FROM "+TETempName("WorkIP")
   cQuery += " WHERE EE9_PREEMB = '"+M->EEC_PREEMB+"'"
   cQuery += " AND D_E_L_E_T_ = ' '"
   cQuery += " AND EE9_DTAVRB <> ''"
   
   nOldArea   := Select()
   MPSysOpenQuery(cQuery, cTmpWorkIP)
   DbSelectArea(cTmpWorkIP)
   If (cTmpWorkIP)->QTDREG == 0
      lRet := .F.
   EnDif 
   (cTmpWorkIP)->(DbCloseArea())
   DbSelectArea(nOldArea)

EndIf

Return lRet

/*
Funcao     : TotComEEQ()
Parametros : cProcesso = Codigo do Embarque; cComissao = Codigo da comissao
Objetivos  : Retorna o valor total de comissao existente na EEQ para o processo
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 05/11/2019
*/
Static Function TotComEEQ(cProcesso,cComissao)
Local nRet      := 0
Local cTotCom   := GetNextAlias()
Local cQuery    := ""

cQuery := " SELECT EEQ_VL,EEQ_ACRESC,EEQ_DECRES,EEQ_MULTA,EEQ_JUROS,EEQ_DESCON "
cQuery += " FROM " + RetSQLName("EEQ")
cQuery += " WHERE EEQ_FILIAL = '" + xFilial("EEQ") + "' "
cQuery += "   AND EEQ_PREEMB = '" + cProcesso + "' "
cQuery += "   AND EEQ_EVENT	 = '" + cComissao + "' "
cQuery += "   AND D_E_L_E_T_=' ' "

EasyWkQuery(cQuery,cTotCom)

While (cTotCom)->(!Eof())
    nRet := (cTotCom)->(EEQ_VL + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON)
    (cTotCom)->(dbSkip())
End

(cTotCom)->(dbCloseArea())
Return nRet

/*
Funcao     : VERPEDIDOS()
Parametros : cWorkAlias - Define a work que sera utilizada para a pesquisa
Objetivos  : Retornar um array com todos os pedidos de exportação ja vinculados ao embarque
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 12/08/2020
*/
Static Function VERPEDIDOS(cWorkAlias)
Local aRet := {"TODOS"}
Local cAliasTmp := GetNextAlias()
Local cQuery    := ""

cQuery := " SELECT EE9_PEDIDO,COUNT(*) "
cQuery += " FROM " + TETempName(cWorkAlias) + " EE9 "
cQuery += " WHERE D_E_L_E_T_=' ' "
cQUery += " GROUP BY EE9.EE9_PEDIDO"

EasyWkQuery(cQuery,cAliasTmp)

While (cAliasTmp)->(!Eof())
    aAdd(aRet,(cAliasTmp)->EE9_PEDIDO)
    (cAliasTmp)->(dbSkip())
End
(cAliasTmp)->(dbCloseArea())

Return aRet

/*
Funcao     : FilBrwItem()
Parametros : cWKAlias - Define a work que sera utilizada para o filtro
             cPedido  - Pedido a ser filtrado
Objetivos  : Nil
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 12/08/2020
*/
Static Function FilBrwItem(cWKAlias,cPedido,oMark)
Local cCondicao
If cPedido == "TODOS"
   (cWKAlias)->(DbClearFilter())
   If !Empty(cUserFiltroEE9)
      (cWKAlias)->(DBSETFILTER({|| &cUserFiltroEE9 },cUserFiltroEE9 ))
      (cWKAlias)->(dbGoTop())
   EndIf
Else
   cCondicao := "EE9_PEDIDO == '"+cPedido+"' "
   If !Empty(cUserFiltroEE9)
      cCondicao += " .And. "+ cUserFiltroEE9
   EndIf
   WorkIP->(DBSETFILTER({|| &cCondicao },cCondicao))
   WorkIP->(dbGoTop())

   If lConsolida
      WorkOpos->(DbSetFilter({|| &cCondicao },cCondicao))
      WorkOpos->(dbGoTop())
      WorkGrp->(DbSetFilter({|| &cCondicao },cCondicao))
      WorkGrp->(DbGoTop())
   EndIf

EndIf

Return

/*
Funcao     : ADDPedido()
Parametros : cPedido - Codigo do Pedido digitado no get
             oMark   - Browse de itens dos pedidos ja selecionados
             oBrwPed - Browse dos Pedidos informados no embarque
             oGetPedido - Get onde digita o codigo do pedido
             aPedCampo  - Array com os pedidos apresentados no oBrwPed
Objetivos  : Nil
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 12/08/2020
*/
Static Function ADDPedido(cPedido,oMark,oBrwPed,oGetPedido,aPedCampo,lTela,cWKAlias)
Local lRet := .F.
If !Empty(cPedido) .And. ExistCpo("EE7",cPedido,1) .Or. lTela
   cPedido := AE100SLPE(cPedido,oMark,lTela)
   
   If !Empty(cPedido) .And. aScan(aPedCampo,{|x| Alltrim(x) == Alltrim(cPedido)}) == 0
      aAdd(aPedCampo,cPedido)
   EndIf
   lRet := .T.
   FilBrwItem(cWKAlias,aPedCampo[1])
   (cWKAlias)->(dbGoTop())
   oMark:oBrowse:Refresh()
   oBrwPed:GoTo(1)
   oBrwPed:Refresh()
   oGetPedido:SetFocus()
Else
   If !Empty(cPedido)
      oGetPedido:SetFocus()
   EndIf
EndIf

Return lRet

/*
Funcao     : SetFilterWk()
Parametros : lFiltra - Define se deve filtrar ou limpar o filtro
             cPedido  - Pedido a ser filtrado
Objetivos  : Nil
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 12/08/2020
*/
Static Function SetFilterWk(lFiltra,cPedido,lFiltraNF,cNota,cSerie)
Local cCondicao := ""
Default lFiltraNF := .F.
If lFiltra
   If lFiltraNF
      cCondicao := "EE9_NF == '"+cNota+"' .And. EE9_SERIE == '"+cSerie+"' "
   Else
      cCondicao := "EE9_PEDIDO == '"+cPedido+"' "
   EndIf
   
   If !Empty(cUserFiltroEE9)
      cCondicao += " .And. "+ cUserFiltroEE9
   EndIf

   cPedido := AvKey(cPedido,"EE9_PEDIDO")
   WorkIP->(DBSETFILTER({|| &cCondicao },cCondicao))
   WorkIP->(dbGoTop())

   If lConsolida
      WorkOpos->(DbSetFilter({||&cCondicao },cCondicao))
      WorkOpos->(dbGoTop())
      WorkGrp->(DbSetFilter({||&cCondicao },cCondicao))
      WorkGrp->(DbGoTop())
   EndIf

Else

   WorkIP->(dbClearFilter())
   If !Empty(cUserFiltroEE9)
      WorkIP->(DBSETFILTER({|| &cUserFiltroEE9 },cUserFiltroEE9))
   EndIf
   WorkIP->(dbGoTop())

   If lConsolida
      WorkOpos->(dbClearFilter())
      If !Empty(cUserFiltroEE9)
         WorkOpos->(DBSETFILTER({|| &cUserFiltroEE9 },cUserFiltroEE9))
      EndIf
      WorkOpos->(dbGoTop())
      WorkGrp->(dbClearFilter())
      If !Empty(cUserFiltroEE9)
         WorkGrp->(DBSETFILTER({|| &cUserFiltroEE9 },cUserFiltroEE9))
      EndIf
      WorkGrp->(DbGoTop())
   EndIf

EndIf

Return

/*
Funcao     : SelAllItens()
Parametros : aPedCampo - Array com todos os pedidos vinculados ao embarque
Objetivos  : Nil
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 12/08/2020
*/
Static Function SelAllItens(aPedCampo,nPosicao,cWKAlias)
Local nI
Local aMarcaItem := {}

If nPosicao == 1

   aMarcaItem := MarcaItens(cWKAlias) //Ao clicar no marca/desmarca, caso tenha algum item desmarcado, deve ser executad o marca para ele
   If Len(aMarcaItem) == 1
      aMarcaItem := aClone(aPedCampo)
   EndIf

   For nI := 2 To Len(aMarcaItem)
      SetFilterWk(.T.,aMarcaItem[nI])
      Ae100SelAll()
      SetFilterWk(.F.)
   Next
Else
   Ae100SelAll()
EndIf

Return

/*
Funcao     : ApuraItens()
Parametros : 
Objetivos  : Nil
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 12/08/2020
*/
Static Function ApuraItens(cIncAlt,aPedCampo,nPosicao)
Local nI

If nPosicao == 1

   For nI := 2 To Len(aPedCampo)
      SetFilterWk(.T.,aPedCampo[nI])
      AE100Apuracao(cIncAlt,aPedCampo[nI])
      SetFilterWk(.F.)
   Next
Else
   AE100Apuracao(cIncAlt)
EndIf

Return
/*
Funcao     : MarcDesmIt()
Parametros : cPedido - Codigo do pedido selecionado
             lMarca  - .T. para marcar; .F. para desmarcar
Objetivos  : Marcar os itens do pedido selecionado
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data       : 12/08/2020
*/
Static Function MarcDesmIt(cPedido,lMarca,oBrw,nPosicao)
Local nRecWorkIP
Local nRecWorkGrp
Local nRecWorkOpos

If nPosicao == 1
   nRecWorkIP := WorkIP->(Recno())
   If lConsolida
      nRecWorkGrp := WorkGrp->(Recno())
      nRecWorkOpos:= WorkOpos->(Recno())
   EndIf
   SetFilterWk(.T.,cPedido,!Empty(WorkIP->EE9_NF),WorkIP->EE9_NF,WorkIP->EE9_SERIE)
   WorkIP->(dbGoTo(nRecWorkIP))
   If lConsolida
      WorkGrp->(dbGoTo(nRecWorkGrp))
      WorkOpos->(dbGoTo(nRecWorkOpos))
   EndIf
EndIf
If lMarca
   Ae100Marca()
Else
   Ae100Desmarca()
EndIf
If nPosicao == 1
   SetFilterWk(.F.)
   WorkIP->(dbGoTo(nRecWorkIP))
   If lConsolida
      WorkGrp->(dbGoTo(nRecWorkGrp))
      WorkOpos->(dbGoTo(nRecWorkOpos))
   EndIf
EndIf
oMark:oBrowse:Refresh()

Return


Static Function MarcaItens(cWorkAlias)
Local aRet := {"TODOS"}
Local cAliasTmp := GetNextAlias()
Local cQuery    := ""

cQuery := " SELECT EE9_PEDIDO,COUNT(*) "
cQuery += " FROM " + TETempName(cWorkAlias) + " EE9 "
cQuery += " WHERE D_E_L_E_T_=' ' "
If lConsolida
   cQuery += " AND WP_FLAG = 'N' "
Else
   cQuery += " AND WP_FLAG = ' ' "
EndIf
cQUery += " GROUP BY EE9.EE9_PEDIDO"

EasyWkQuery(cQuery,cAliasTmp)

While (cAliasTmp)->(!Eof())
    aAdd(aRet,(cAliasTmp)->EE9_PEDIDO)
    (cAliasTmp)->(dbSkip())
End
(cAliasTmp)->(dbCloseArea())

Return aRet

/*
Funcao     : AE100LdEKK()
Parametros : aGetsEKK - Array 'aHeader' do objeto NewGetDados
             aColsEKK - Array 'aCols' do objeto NewGetDados
Objetivos  : Alimentar o array aHeader e aCols do objeto de tela 
             status da DUE na capa do embarque - aba "DUE" 
Autor      : NCF - Nilson César
Data       : 16/10/2020
*/
Static Function AE100LdEKK(aGetsEKK,aColsEKK)

Local cSeqEK0 := DU101SqEK0(EEC->EEC_PREEMB)
               //Campos da EKK
   aAdd(aGetsEKK,{AVSX3("EKK_DATAST",5),"EKK_DATAST",AVSX3("EKK_DATAST",6),AVSX3("EKK_DATAST",3)   ,AVSX3("EKK_DATAST",4),nil,nil,AVSX3("EKK_DATAST",2),nil,nil } )
   aAdd(aGetsEKK,{AVSX3("EKK_STATUS",5),"EKK_STATUS",AVSX3("EKK_STATUS",6),AVSX3("EKK_STATUS",3)   ,AVSX3("EKK_STATUS",4),nil,nil,AVSX3("EKK_STATUS",2),nil,nil } )

   If( Select("EKK") < 0 , ChkFile("EKK",.F.),)
   EKK->(DbSetOrder(1))  //A sequência já gravada ordenada por data dos eventos
   If Val(cSeqEK0) > 0 .And. EKK->(DbSeek(xFilial("EKK") + EEC->EEC_PREEMB + cSeqEK0 ))
      Do While EKK->(!Eof()) .And. EKK->EKK_FILIAL == xFilial("EKK") .And. EKK->EKK_PROCES == EEC->EEC_PREEMB .And. EKK->EKK_NUMSEQ == cSeqEK0
         aAdd(aColsEKK,Array(Len(aGetsEKK)+2))
         aColsEKK[Len(aColsEKK)][aScan(aGetsEKK,{|X|X[2]=="EKK_DATAST"})] := EKK->EKK_DATAST   //Data do status
         aColsEKK[Len(aColsEKK)][aScan(aGetsEKK,{|X|X[2]=="EKK_STATUS"})] := EKK->EKK_STATUS   //Status
         aColsEKK[Len(aColsEKK)][Len(aGetsEKK)+1]                         := EKK->EKK_DETAST   //Detalhes do status
         aColsEKK[Len(aColsEKK)][Len(aGetsEKK)+2] := .F.                                       //Marca como não deletado
         EKK->(DbSkip())
      EndDo
   Else
      aAdd(aColsEKK,Array(Len(aGetsEKK)+2))
      aColsEKK[Len(aColsEKK)][aScan(aGetsEKK,{|X|X[2]=="EKK_DATAST"})] := cToD("  /  /  ") //Data do status
      aColsEKK[Len(aColsEKK)][aScan(aGetsEKK,{|X|X[2]=="EKK_STATUS"})] := ""               //Status
      aColsEKK[Len(aColsEKK)][Len(aGetsEKK)+1]                         := ""               //Detalhes do status                                      
      aColsEKK[Len(aColsEKK)][Len(aGetsEKK)+2] := .F.                                      //Marca como não deletado      
   EndIf

Return .T.

/*
Funcao     : GetDtStDUE()
Parametros : oGetDadEKK - objeto de tela status da DUE 
             na capa do embarque - aba "DUE"
Objetivos  : Exibir o dado do campo em tela do EECVIEW
             e retornar o dado sem alteração.
Autor      : NCF - Nilson César
Data       : 16/10/2020
*/
Static Function GetDtStDUE( oGetDadEKK )

Local cTextCpo := oGetDadEKK:oBrowse:OMOTHER:aCols[oGetDadEKK:oBrowse:nAt][3]
EECView(cTextCpo ,"Detalhes do Status da DUE")

Return cTextCpo
*------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAE100.PRW                                                 *
*------------------------------------------------------------------------------*
