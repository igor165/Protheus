#INCLUDE "eecap100.ch"
#INCLUDE "AVERAGE.CH"
#include "EEC.CH"
#include "dbtree.ch"
#INCLUDE "FWBROWSE.CH"
#define PC_CF "8" //Processo de exporta��o de caf�
#define PC_CM "9" //Processo de exporta��o de commodites
#DEFINE ST_AP "N" //NCF - 11/08/2014 - Status do Pedido = "Aguardando Aprova��o da Proforma"
#DEFINE ST_PA "O" //NCF - 11/08/2014 - Status do Pedido = "Proforma Aprovada"
#define ST_PB "P" //NCF - 03/02/2015 - Proforma em Edi��o

/*
Programa        : EECAP100.PRW
Objetivo        : Manutencao de Proc. Exportacao
Autor           : Heder M Oliveira
Data/Hora       : 08/12/98 19:18
Obs.            :
*/

#COMMAND E_RESET_AREA => EE7->(DBSETORDER(1)) ;;
                          If(Select("WorkIt")  > 0, WorkIt->(EECEraseArq(cNomArq)) ,Nil) ;;
                          If(Select("WorkEm")  > 0, WorkEm->(EECEraseArq(cNomArq1)),Nil) ;;
                          If(Select("WorkAg")  > 0, WorkAg->(EECEraseArq(cNomArq2,cNomArq22)),Nil) ;;
                          If(Select("WorkIn")  > 0, WorkIn->(EECEraseArq(cNomArq3)),Nil) ;;
                          If(Select("WorkDe")  > 0, WorkDe->(EECEraseArq(cNomArq4)),Nil) ;;
                          If(Select("WorkNo")  > 0, WorkNo->(EECEraseArq(cNomArq5)),Nil) ;;
                          IF(Select("WorkDoc") > 0, WorkDoc->(EECEraseArq(cNomArq6,cNomArq62)),Nil);;
                          IF(Select("WorkGrp") > 0, WorkGrp->(EECEraseArq(cNomArq7)),Nil);;
                          If(Select("Wk_NfRem") > 0, Wk_NfRem->(EECEraseArq(cArqNFRem)),);;
                          If(Select("WORKSLD_AD") > 0,WORKSLD_AD->(EECEraseArq(cArqAdiant)),) // By JPP - 14/02/2006 - 16:00

//DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
#COMMAND E_ZAP_AREA =>EE7->(DBSETORDER(1)) ;;
                       AvZap("WorkIt")     ;;
                       AvZap("WorkEm")     ;;
                       AvZap("WorkAg")     ;;
                       AvZap("WorkIn")     ;;
                       AvZap("WorkDe")     ;;
                       AvZap("WorkNo")     ;;
                       IF(Select("WorkDoc") > 0,AvZap("WorkDoc"),) ;;
                       IF(Select("WorkGrp") > 0,AvZap("WorkGrp"),)

/*
Funcao          : EECAP100()
Parametros      : Nenhum
Retorno         : .T.
Objetivos       : Executar mbrowse
Autor           : Heder M Oliveira
Data/Hora       : 08/12/98 19:19
Revisao         : Jeferson Barros Jr - 24/07/01 13:10 - Melhoria no desempenho da manuten��o de processos.
Obs.            : "Processo de Exporta��o"
*/
Function EECAP100(xAutoCab,xAutoItens,nOpcAuto,xAutoComp)

Local lRet:=.T.,cOldArea:=select(),cAlias:="EE7"
Local nOrdemSX3 := SX3->(IndexOrd())
Local i

Local cExpFilter := ""  // PLB 03/08/07 - Filtro a ser aplicado antes do MBrowse
Local aRet_PE    := {}  // NCF 03/02/2015 - Para receber retorno do ponto de entrada
// by CAF 13/01/2005 - Abrir o EXB, na 8.11 o Protheus n�o abre os arquivos pelo menu.
dbSelectArea("EXB")
dbSelectArea("EE9")
dbSelectArea("EEQ")
dbSelectArea("EXB")
IF SX2->(dbSeek("EXL"))
   dbSelectArea("EXL")
Endif
IF SX2->(dbSeek("EXM"))
   dbSelectArea("EXM")
Endif
dbSelectArea("EEF")
AvlSX3Buffer(.T.)//RMD - 08/11/17 - Melhoria de performance
// *** Processamento via rotina autom�tica (via MsExecAuto).
Private lEE7Auto := xAutoCab <> NIL  .And. xAutoItens <> NIL
Private lEE7AutoDel := .F., lEE7AutoCan := .F.
Private aAutoCab, aAutoItens, aAutoComp, nOpcaoAuto
If Type("lSched") <> "L"
    Private lsched := lEE7Auto
EndIf
// ***

Private cCadastro:=AVTITCAD("EE7"),cIDCAPA
Private cTIPMEN:=TM_SIT,nOPCI

//definicao de identificadores para ser usados em F3 especificos
Private cWHENOD,cVIA,cWHENSA1,cWHENSA2,cCONTAT

Private lIntegra     := IsIntFat()
Private lLibCredAuto := AvFlags("LIBERACAO_CREDITO_AUTO")//EasyGParam("MV_AVG0057",,.F.)

Private lInt := lIntegra // lIntegra nao cabia no x3_when do ee9_sldini
Private lLibPes:= GetNewPar("MV_AVG0009",.F.)

Private cITEPIC:="@E 999,999,999,999",cTPEPIC:=X3PICTURE("EE7_TOTPED"),;
        cPLIPIC:=X3PICTURE("EE7_PESLIQ"),cPBRPIC:=X3PICTURE("EE7_PESBRU")

// Cria variaveis para arquivos de trabalho...
Private cNomArq, cNomArq1, cNomArq2, cNomArq22, cNomArq3, cNomArq4, cNomArq5, cNomArq6, cNomArq62, cNomArq7

Private aCampoItem, cCALLLOC:="EE7"
// Cria variaveis para agentes...
Private aAgPos, aAgBrowse
// Cria variaveis para instituicoes...
Private aInPos, aInBrowse
// Cria variaveis para Despesas ...
Private aDePos, aDeBrowse
// Cria variaveis para Notify's ...
Private aNoPos, aNoBrowse
// Cria variaveis para Agenda de Atividades ...
Private aDocBrowse
// JPM - 07/10/05 - array para o browse de agrupamentos
Private aGrpBrowse

Private cCodImport := Space(Len(EE7->EE7_IMPORT)) // Usado na funcao AP100IMPORT

// Variaveis usados para Alteracao de Status ...
Private aFieldCapa, aFieldItens

// Flag para verificacao de intermediario na geracao do pedido...
Private lIntermed :=.f.

// ** By JBJ - 13/06/2002 - 17:42
// Flag para convers�o dos pesos e pre�os na totaliza��o dos itens ...
Private lConvUnid :=.f.

// Flag para processo Commodity ...
Private lCommodity:=.f.

Private lFilter:= .T.  //TRP - 28/11/2011 - Vari�vel criada para a Kaefer (088686), que ser� utilizada em rdmake para desabilitar os filtros da mBrowse.

Private aMemos := {{"EE7_CODMAR","EE7_MARCAC"},;
                   {"EE7_CODMEM","EE7_OBS"},;
                   {"EE7_CODOBP","EE7_OBSPED"},;
                   {"EE7_DSCGEN","EE7_GENERI"}}

// ** By JBJ - 10/06/2002 - 13:42
Private aMemoItem :={{"EE8_DESC","EE8_VM_DES"}}

Private lAVSX3BUFFER := .T.
// ** By JBJ - 06/11/2002 - Flag para acionamento de Adiantamentos (pagamento antecipado)
Private lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)

// ** By JBJ - 06/12/2002 - Flag para teste nos gatilhos na manutencao de pagamento antecipado.
Private lIsPed := .t.

/* By JBJ - 24/02/2005 - Flag para habilitar/desabilitar a rotina de
                         levantamento de campos e replica��o de dados na filial de off-shore. */
Private lReplicaDados := (EasyGParam("MV_AVG0079",,.f.) .And. EEC->(FieldPos("EEC_NIOFFS") > 0))

SX3->(DbSetOrder(2))
Private lOkEVENT  := SX3->(dbSeek("EEQ_EVENT"))

// ** By EDS - 11/12/2002 - Variaveis para verifica��o de campos para estorno da contabiliza��o
Private aEstornaECF:={}, aIncluiECF:={}, cFilECF, cFilECG
Private lOkEstor:= SX3->(dbSeek("ECF_PREEMB")) .And. SX3->(dbSeek("ECF_FASE")) .And. SX3->(dbSeek("ECF_PREEMB")) .And. ;
			         SX3->(dbSeek("EEQ_FASE")) .And. SX3->(dbSeek("EEQ_EVENT")) .And. SX3->(dbSeek("EEQ_NR_CON")) .And. ;
			         SX3->(dbSeek("EET_DTDEMB"))
Private lContEst  := EasyGParam("MV_CONTEST",,.T.)   // Gera Estorno para contabiliza��o
Private lIntCont  := EasyGParam("MV_EEC_ECO",,.F.)   // Define Integra��o entre SIGAEEC - SIGAECO
Private lRecriaPed := .f., lAtuFil := .f.
Private lNRotinaLC := .f.
Private cFilBr:="",cFilEx:=""
Private aProdComDif:={}
Private lReplicacao := .f.
Private cArqNFRem
Private lNfRemNovaVersao:= .T.
Private cCodIt := ""  // GFP - 04/03/2013
Private lTotRodape := EE7->(FieldPos("EE7_TOTFOB")) # 0  .AND. EE7->(FieldPos("EE7_TOTLIQ")) # 0   // GFP - 11/04/2014
Private oUpdAtu //BAK - 22/08/11
Private lGatVia := .F. // GFP - 27/05/2014

/* RMD - 08/12/17 - Mover para o RUP
   //BAK - Tratamento para carga padr�o das tabelas EJ0, EJ1, EJ2 - 22/08/2011
   If FindFunction("AvUpdate01")
      oUpdAtu := AvUpdate01():New()
   EndIf

   If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
      If ChkFile("EJ0") .And. ChkFile("EJ1") .And. ChkFile("EJ2")
         oUpdAtu:aChamados := {{nModulo,{|o| EEDadosEJ0(o)}}}
         oUpdAtu:Init(,.T.)
      EndIf
   EndIf
*/
//RMD - 25/10/05 - Para gravar memo da descri��o da qualidade
If EECFLAGS("AMOSTRA")
   aAdd(aMemoItem, {"EE8_QUADES","EE8_DSCQUA"})
EndIf

//JPM - 23/12/04 - Define se � a nova rotina de Carta de Cr�dito
lNRotinaLC :=    (EEL->(FieldPos("EEL_SLDVNC")) # 0) ;
           .And. (EEL->(FieldPos("EEL_SLDEMB")) # 0) ;
           .And. (EEL->(FieldPos("EEL_RENOVA")) # 0)

//JPM - 01/02/05 - Define se � o tratamento de comiss�o com mais de um agente por item.
Private lTratComis := EasyGParam("MV_AVG0077",,.F.)

// ** JPM - 25/04/05 - Habilita os novos tratamentos de multi Off-Shore
Private lMultiOffShore := EasyGParam("MV_AVG0083",,.f.) .And. EEC->(FieldPos("EEC_NIOFFS")) > 0;
                                                   .And. EEC->(FieldPos("EEC_CLIENF")) > 0;
                                                   .And. EEC->(FieldPos("EEC_CLOJAF")) > 0

// ** Vari�veis utilizadas na fun��o de replica��o de dados.
Private cArqMain, cArqMain2, cArqMain3, cArqMain4

Private lIntEmb := EECFlags("INTEMB")

Private cOcorre := OC_PE

// By JPP - 14/02/2006 - 16:00 - Arquivo tempor�rio utilizado na valida��o e controle de adiantamentos.
Private cArqAdiant

If Select("Header_p") = 0
   AbreEEC()
EndIf

If lOkEstor
   cFilECF := xFilial("ECF")
   cFilECG := xFilial("ECG")
Endif

//RMD - Verifica se possui tratamentos de consigna��o
Private lConsign := EECFlags("CONSIGNACAO")
If lConsign .And. !Type("cTipoProc") == "C"
   Private cTipoProc := PC_RG
EndIf

SX3->(DBSETORDER(nOrdemSX3))

/* by jbj - 22/06/04 17:29 - Valida��es obrigat�rias para habilita��o da rotina
                             de off-shore.
                             Obs: A fun��o IsFilial() valida as filiais informadas nos
                                  par�metros MV_AVG0023 e MV_AVG0024 contra as filiais
                                  v�lidas no sigamat.emp */

/* JPM - 22/09/05 - Substitu�do por fun��o gen�rica (Inclusive joga o conte�do das vari�veis cFilBr e cFilEx
cFilBr := EasyGParam("MV_AVG0023",,"")
cFilBr := IF(ALLTRIM(cFilBr)=".","",cFilBr)
cFilEx := EasyGParam("MV_AVG0024",,"")
cFilEx := IF(ALLTRIM(cFilEx)=".","",cFilEx)

If !Empty(cFilBr) .And. !Empty(cFilEx) .And. IsFilial()
   If (EE7->(FieldPos("EE7_INTERM")) # 0) .And. (EE7->(FieldPos("EE7_COND2"))  # 0) .And.;
      (EE7->(FieldPos("EE7_DIAS2"))  # 0) .And. (EE7->(FieldPos("EE7_INCO2"))  # 0) .And.;
      (EE7->(FieldPos("EE7_PERC"))   # 0) .And. (EE8->(FieldPos("EE8_PRENEG")) # 0)
      lIntermed := .t.
   EndIf
EndIf
*/
lIntermed := EECFlags("INTERMED")

If EECFlags("INTERMED") // EECFlags("CONTROL_QTD") // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padr�o para Off-Shore
   /* JPM - 30/09/05 - Campos pelos quais os itens ser�o consolidados
      na rotina de Controle de Quantidades entre filiais Brasil e Off-Shore,
      al�m da sequ�ncia de origem (EE8_ORIGV e EE8_ORIGEM) */
   Private aConsolida := {}
   Ap104KeyX3(aConsolida) // acerta tamanho

   // Campos da work de agrupamento e da msselect
   Private aGrpCpos  := {"EE8_ORIGEM","EE8_COD_I" ,"EE8_VM_DES","EE8_PRECO" ,"EE8_UNIDAD",;
                         "EE8_SLDINI","EE8_PRCTOT","EE8_PRCINC","EE8_PSLQTO","EE8_EMBAL1",;
                         "EE8_QTDEM1","EE8_QE"    ,"EE8_PSBRTO","EE8_SLDATU"}
   Ap104KeyX3(aGrpCpos) // acerta tamanho

   // Informa��es referentes aos campos acima. "S" - Sempre igual, "N" - N�o � sempre igual, "T" - Totaliza
   // Obs.: para cada posi��o do aGrpCpos, deve ter uma posi��o correspondente no aGrpInfo
   Private aGrpInfo  := {"S","S","S","N","S",;
                         "T","T","T","T","S",;
                         "T","S","T","T"}

   Private bConsolida, cGrpFilter // vari�veis para filtro

   ASize(aGrpCpos,Len(aGrpCpos)+Len(aConsolida)) //redimensiona para colocar os campos do aConsolida.
   ASize(aGrpInfo,Len(aGrpCpos))
   For i := 1 To Len(aConsolida)
      If (nPos := AScan(aGrpCpos,aConsolida[i])) > 0
         aGrpInfo[nPos] := "S"
         ASize(aGrpCpos,Len(aGrpCpos)-1)
         ASize(aGrpInfo,Len(aGrpCpos))
      Else
         AIns(aGrpCpos,i+3)
         aGrpCpos[i+3] := aConsolida[i]
         AIns(aGrpInfo,i+3)
         aGrpInfo[i+3] := "S" // sempre igual
      EndIf

   Next
EndIf

// ** By JBJ - 13/06/2002 - 17:45
If (EE7->(FieldPos("EE7_UNIDAD")) # 0) .And. (EE8->(FieldPos("EE8_UNPES")) # 0) .And.;
   (EE8->(FieldPos("EE8_UNPRC")) # 0)
   lConvUnid :=.t.
EndIf

/* JPM - 22/09/05 - Substitu�do por fun��o gen�rica
// ** By JBJ - 25/06/2002 - 13:45
If EasyGParam("MV_AVG0029",,.F.) .And. (EE8->(FieldPos("EE8_DTCOTA"))# 0) .And. EasyGParam("MV_AVG0034",.t.) .And.; // MV_AVG0034 - 710
   (EE8->(FieldPos("EE8_DIFERE"))# 0) .And. (EE8->(FieldPos("EE8_MESFIX")) # 0).And.;
   (EE8->(FieldPos("EE8_STFIX"))# 0) .And. (EE8->(FieldPos("EE8_DTFIX"))# 0) .And.;
   (EE8->(FieldPos("EE8_QTDLOT"))# 0)

   lCommodity:=.t.
EndIf
*/
lCommodity := EECFlags("COMMODITY")

Private lNewRv := EECFlags("NEW_RV")
Private lRv11  := EasyGParam("MV_AVG0103",,.F.) // JPM - 16/11/05 - Define se ser� o tratamento de R.V. 1 para 1 (.T.) ou n�o (.F. - R.V. Desvinculada)

Private lGrade := AvFlags("GRADE")
Private oGrdExp
Private aItGrdRest:= {}
Private lIntPrePed := AVFLAGS("EEC_LOGIX_PREPED")

Private aRotina := MenuDef(.T., If(cTipoProc == PC_RG, "EECAP100", ProcName(1)))

Private aNfRemDeletados:= {}

//AOM - 26/04/2011 - Opera��o Especial
Private lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL")
Private lNfRemessa:= AvFlags("FIM_ESPECIFICO_EXP")

// BAK - variavel estava declarada na fun��o Ap102CriaWork
//Private lGrade := AvFlags("GRADE") //FSM - 05/10/2012

If EasyEntryPoint("EECAP100")
   ExecBlock("EECAP100",.F.,.F.,{ "GRV_WORK" })
Endif

/*FSM - 28/12/10 - Insere novos Incoterms na Base de Dados*/
InsNInco()

// ** Cria arquivos tempor�rios
AP102CriaWork()

Ap100AcDic()

Begin Sequence

SetKey(VK_F12,{|| a410Ativa()})

   IF (EasyEntryPoint("EECPPE06"))
      EXECBLOCK("EECPPE06",.F.,.F.)
   ENDIF

   // Verifica se o Modulo ativo eh o SIGAEEC
   IF ! AmIin(29)
      HELP(" ",1,"AVG0000624") //MsgStop("Fun��o n�o autorizada para este m�dulo !","Aviso")
      Break
   Endif

   If lConsign
      If cTipoProc == PC_RC
         cCadastro := STR0135 //"Pedido de Consigna��o - Remessa"
      ElseIf cTipoProc == PC_VC
         cCadastro := STR0136//"Pedido de Consigna��o - Venda"
      ElseIf cTipoProc == PC_BN
         cCadastro := STR0137//"Pedido de Back To Back"
      ElseIf cTipoProc == PC_BC
         cCadastro := STR0138//"Pedido de Back To Back com Consigna��o"
      ElseIf cTipoProc == PC_CF
         cCadastro := STR0176 //STR0176	"Pedido de Exporta��o de Caf�"
      ElseIf cTipoProc == PC_CM
         cCadastro := STR0177 //STR0177	"Pedido de Exporta��o de A��car"

      EndIf
   EndIf

   If !lEE7Auto
      // ** PLB 03/08/07 - Quando for TOP o filtro ser� utilizado como par�metro do MBrowse, a tabela N�O ser� filtrada com DBSetFilter()
      If lFilter
         cExpFilter := EECFilterProc("EE7", If(Type("cTipoProc") == "C", cTipoProc, Nil),  , .T. )
      Endif

      If SetMdiChild()
         AjustaDimensao()
      EndIF
      If lFilter
         SetMbrowse( cAlias, cExpFilter )
         EE7->( DBClearFilter() )
      Else
         SetMbrowse( cAlias )
      Endif
   // **
   Else
      // *** Processamento via rotina autom�tica (MsExecAuto).
      aAutoCab   := xAutoCab
      aAutoItens := xAutoItens
      aAutoComp  := xAutoComp
      nOpcaoAuto := nOpcAuto
      aRet_PE    := {}
      If EasyEntryPoint("EECAP100")
	     aRet_PE := ExecBlock("EECAP100",.F.,.F.,{ "ANTES_GRAVA_CAPA_AUTO" })
      EndIf
      If ValType(aRet_PE) == 'A' .And. Len(aRet_PE) >= 2 .And. Valtype(aRet_PE[1]) == "L" .And. !aRet_PE[1]
         //EasyHelp( If ( ValType(aRet_PE[2]) == 'C' , aRet_PE[2] , cValTochar(aRet_PE[2]) ) ,STR0059)
         AutoGRLog(AvgXMLEncoding( If (ValType(aRet_PE[2]) == 'C',aRet_PE[2],cValTochar(aRet_PE[2])) ))
         lMsErroAuto := .T.
         Break
      Else
         AvKeyAuto(aAutoCab)
         MBrowseAuto(nOpcaoAuto,Aclone(aAutoCab),"EE7",,.T.)
      EndIf
      // ***
   EndIf

End sequence

//** Apaga os arquivos tempor�rios
E_RESET_AREA


//DFS - 21/07/12 - Para conter os parametros de configura��es financeiros na rotina de cambio de exportac�o
If IsIntEnable("001")
   SetKey (VK_F12,{|a,b| AcessaPerg("FIN040",.T.)})
EndIf

dbselectarea(cOldArea)
AvlSX3Buffer(.F.)//RMD - 08/12/17 - Melhoria de Performance
Return lRet

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 03/02/07 - 16:48
*/
Static Function MenuDef(lMBrowse, cOrigem)
Local aRotAdic := {}
Local aExcCanc := {{ STR0005, "AP100CANCE" , 0 , 5,3}, { STR0014, "AP100MAN" , 0 , 5,3}} //"Cancelar" ### "Excluir"
Local aRotina  := { { STR0001, "AxPesqui" , 0 , 1},;   //"Pesquisar"
                    { STR0002, "AP100MAN" , 0 , 2},;   //"Visualizar"
                    { STR0003, "AP100MAN" , 0 , 3},;   //"Incluir"
                    { STR0004, "AP100MAN" , 0 , 4},;   //"Alterar"
                    { STR0005, "AP100MAN" , 0 , 5,3}}  //"Cancelar"

//Default lMBrowse := .F. - Nopado pois � necess�rio retornar todas as op��es da rotina. Apenas o menufuncional n�o pode exibi-las (funcao GETMENUDEF � do menu funcional).
Default lMBrowse := OrigChamada()
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   //RMD - 19/06/19 - Separa as op��es de cancelar e excluir em um submenu, se n�o for ExecAuto (Neste caso mant�m o modelo anterior)
   If !(IsMemVar("lEE7Auto") .And. lEE7Auto)
      aRotina[5] := { STR0005+"/"+STR0014, aExcCanc, 0 , 5,3} //"Cancelar/Excluir"
   EndIf

   IF lMBrowse
      //LRS - 23/05/2017 - variaveis necessarias para o MenuDef Rodar sem erro log, quando chamado do SigaCFG
      lCommodity := EECFlags("COMMODITY")
      lIntermed  := EECFlags("INTERMED")
      cFilBr     := EasyGParam("MV_AVG0023",,"")
      lIntPrePed := AVFLAGS("EEC_LOGIX_PREPED")
   EndIF

   /* A aprova��o de cr�dito ser� realizada pelo ERP */
   If !AvFlags("LIBERACAO_CREDITO_AUTO") //EasyGParam("MV_AVG0057",,.F.)//Libera��o autom�tica de cr�dito
      aAdd(aRotina,{STR0006,"AP100MAN",0,6}) //"Apr.Credito"
   EndIf

   If EasyGParam("MV_AVG0028",,.f.)//Altera��o do c�digo do pedido
      aAdd(aRotina,{ STR0088,"AP100Rename",0,7}) //"Renomear"
   EndIf

   If lMBrowse .And. lCommodity .And. (!EECFlags("NEW_RV") .Or. (lIntermed .And. xFilial("EE7") <> cFilBr))
      aAdd(aRotina,{STR0089,"AP100OpcFix",0,8}) //"Fixar Pre�o"
   EndIf

   If EasyGParam("MV_AVG0039",,.f.)//Verifica se a rotina de adiantamentos est� habilitada
      aAdd(aRotina,{STR0113,"AP100Adian",0,4}) //"Adiantamentos" //DFS - Altera��o de 8 para 4, para que posicione no registro correto
   EndIf

   //Vincula��o/Estorno de R.V.
   If lMBrowse .And. EECFlags("COMMODITY")
      IF !lIntermed .Or. cFilBr == xFilial("EEC")
         // Esta op��o s� aparece para clientes que utilizarem Commodity,
         // e se o parametro de Off-Shore estiver ativo, esta op��o s� aparece na filial Brasil
         // Al�m disso, n�o aparece nos tratamentos de R.V. 1 para 1
         IF !EasyGParam("MV_AVG0103",,.F.)
            aAdd(aRotina, {STR0119, "AP105VE_RV", 0, 9 })    //"Vinc/Estorno R.V."
         Endif
      Endif
   EndIf

   //***
   If lMBrowse .And. EECFlags("COMMODITY")
      aAdd(aRotina,{"Fixar Pre�o","AP100OpcFix",0,5})
   EndIf
   //***

   //Compra FOB
   If lMBrowse .And. EECFlags("COMPRAFOB")//.And. lIntermed .And. xFilial("EE7") == cFilEx
      aAdd(aRotina, {STR0140, "Ap106CompraFOB", 0, 10 }) //"Compra FOB"
      aAdd(aRotina, {STR0141, "Ap106CompraFOB", 0, 11 }) //"Ctr.Export."
   EndIf

   //Aprova��o da proforma - integra��o EAI
   If Type("lIntPrePed") <> "U" .And. lIntPrePed
      aAdd(aRotina, {STR0203, "AP100MAN", 0, 12}) //"Apr.Proforma"
   EndIf

   //DFS - 14/09/10 - Inclus�o de bot�o na rotina de Pedido de Exporta��o para eliminar saldos n�o utilizados
   /* Implementado o bloqueio do uso da funcionalidade. N�o existe campo para envio do saldo eliminado
      na mensagem SalesOrder e a altera��o da quantidade implica nos rec�lculos de valores, com base nas regras
      de neg�cio configuradas para a composi��o do valor unit�rio do item.*/
   If Type("lIntPrePed") == "L" .And. !lIntPrePed
      aAdd(aRotina,{STR0171, "AP100ELIMRES",0,4}) //Elimina Saldo
   EndIf

   If Type("lIntPrePed") == "L" .And. !lIntPrePed .And. AvFlags("EEC_LOGIX") .And. cOrigem $ "EECAP100"
      aAdd(aRotina,{STR0229, "AP100TPB2B",0,4}) //Converter em Back to Back
   EndIf

   If Type("lIntPrePed") == "L" .And. !lIntPrePed .And. AvFlags("EEC_LOGIX") .And. cOrigem $ "AP100B2BREG"
      aAdd(aRotina,{STR0230, "AP100EXTPB2B",0,4}) //Converter em Pedido de Exporta��o
   EndIf

   aADD(aRotina,{ STR0178, "MsDocument", 0, 4 } ) //STR0178	"Conhecimento"

   // P.E. utilizado para adicionar itens no Menu da mBrowse
   Do Case

      Case cOrigem $ "EECAP100" //Processo de Exporta��o
           If EasyEntryPoint("EAP100MNU")
	          aRotAdic := ExecBlock("EAP100MNU",.f.,.f.)
           EndIf

      Case cOrigem $ "AP100RemConsig" //Remessa de consigna��o
           If EasyEntryPoint("EPREMMNU")
	          aRotAdic := ExecBlock("EPREMMNU",.f.,.f.)
           EndIf

      Case cOrigem $ "AP100VendConsig" //Venda de consigna��o
           If EasyEntryPoint("EPVNDCNSMNU")
	          aRotAdic := ExecBlock("EPVNDCNSMNU",.f.,.f.)
           EndIf

      Case cOrigem $ "AP100B2BREG" //Back to Back regular
           If EasyEntryPoint("EPB2BRGMNU")
	          aRotAdic := ExecBlock("EPB2BRGMNU",.f.,.f.)
           EndIf

      Case cOrigem $ "AP100B2BCONSIG" // Back To Back com Consigna��o
           If EasyEntryPoint("EPB2BCMNU")
	          aRotAdic := ExecBlock("EPB2BCMNU",.f.,.f.)
           EndIf
   End Case

	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf

End Sequence

Return aRotina

/*
Funcao      : EECFilterProc()
Parametros  : cAlias -> Alias do arquivo a ser filtrado (EEC/EE7)
              cTipo  -> Indica o tipo de processo, que servir� como base para filtrar os dados
              lRetCond -> Quando .T., a fun��o retorna apenas uma string com a condi��o de filtro correta
              lExpTop -> Determina se deve ser aplicado filtro na tabela atraves de parametro do
                         MBrowse ao inves de utilizar o DBFilter(), a expressao de filtro deve ser do tipo SQL
Retorno     : Nil
Objetivos   : Filtrar a tabela de capa dos pedidos ou embarques.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
Revisao     : PLB 03/08/07 - Inclus�o do Par�metro 'lExpTop' e das variaveis 'lTop' e 'lTemFiltro'
Obs.        :
*/
*-----------------------------------------------------------*
Function EECFilterProc(cAlias, cTipo, lRetCond, lExpTop)
*-----------------------------------------------------------*
Local cFiltro := ""
Local lTemFiltro := .F.
Local lTop := .F.
Default lRetCond := .F.

//** PLB 03/08/07
Default lExpTop := .F.
#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF
//**

Begin Sequence

   If ValType(cAlias) <> "C" .Or. (cAlias <> "EEC" .And. cAlias <> "EE7")
      Break
   EndIf

   //** PLB 03/08/07
   lTemFiltro := !Empty( (cAlias)->( DBFilter() ) )

   If lExpTop
      If !lTop  .Or.  lTemFiltro  // Caso a tabela ja esteja filtrada efetua o DBFilter() normalmente
         lExpTop := .F.
      EndIf
   EndIf
   //**

   If ValType(cTipo) == "C"
      If cAlias == "EE7" .And. (cTipo == PC_VR .Or. cTipo == PC_VB)
         cTipo := PC_VC
      EndIf
      //cFiltro := cAlias+"->"+cAlias + "_TIPO == '" + cTipo + "' "
      //** PLB 03/08/07
      If lExpTop
         cFiltro := cAlias+"_TIPO = '"+AvKey(cTipo,cAlias+"_TIPO")+"' "
      Else
         cFiltro := cAlias+"->"+cAlias + "_TIPO == '" + cTipo + "' "
      EndIf
      //**
   EndIf
   /*
   If cAlias == "EE7"
      If !Empty(cFiltro)
         cFiltro += " .And. "
      EndIf
      cFiltro += " Left(EE7->EE7_PEDIDO,1) <> '*'"
   EndIf
   If cAlias == "EEC" .And. EEC->( FieldPos("EEC_TIPO") ) > 0
      cFiltro += " EEC_TIPO <> 'W'"
   EndIf
   */
   //** PLB 03/08/07
   If cAlias == "EE7"
      If !Empty(cFiltro)
         If lExpTop
            cFiltro += " AND "
         Else
            cFiltro += " .And. "
         EndIf
      EndIf
      If lExpTop
         cFiltro += " EE7_PEDIDO NOT LIKE '*%' "
      Else
         cFiltro += " Left(EE7->EE7_PEDIDO,1) <> '*'"
      EndIf
   EndIf
   If cAlias == "EEC"  .And.  EEC->( FieldPos("EEC_TIPO") ) > 0
      If !Empty(cFiltro)
         If lExpTop
            cFiltro += " AND "
         Else
            cFiltro += " .And. "
         EndIf
      EndIf
      If lExpTop
         cFiltro += " EEC_TIPO <> '"+AvKey("W","EEC_TIPO")+"' "
      Else
         cFiltro += " EEC_TIPO <> 'W' "
      EndIf
   EndIf
   //**

   //If lRetCond
   // PLB 03/08/07 - Se for expressao de filtro para o MBrowse() n�o efetua DBFilter()
   If lRetCond  .Or.  lExpTop
      cFiltro := AllTrim(Upper(cFiltro))
      Break
   EndIf

   //If Len((cAlias)->(DbFilter())) > 0
   // PLB 03/08/07
   If lTemFiltro
      cFiltro := "("+(cAlias)->(DbFilter())+") .And. ("+cFiltro+")"  // PLB 21/06/07 - Para n�o excluir filtros existentes
      (cAlias)->(DbClearFilter())
   EndIf

   If !Empty(cFiltro)
      (cAlias)->(dbSetFilter(&("{|| " + cFiltro + " }"), cFiltro))
   EndIf

End Sequence

//Return If(lRetCond, cFiltro, Nil)
// PLB 03/08/07
Return If(lRetCond .Or. lExpTop, cFiltro, Nil)


/*
Funcao      : AP100RemConsig()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manuten��o de pedidos para Pedidos de Consigna��o do Tipo Remessa
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*------------------------*
Function AP100RemConsig()
*------------------------*
Private cTipoProc := PC_RC
Return EECAP100()

/*
Funcao      : AP100VendConsig()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manuten��o de pedidos para Pedidos de Consigna��o do Tipo Venda
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*------------------------*
Function AP100VendConsig()
*------------------------*
Private cTipoProc := PC_VC
Return EECAP100()

/*
Funcao      : AP100B2BReg()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manuten��o de pedidos de back to back regular.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*---------------------*
Function AP100B2BReg()
*---------------------*
Private cTipoProc := PC_BN
Return EECAP100()

/*
Funcao      : AP100B2BConsig()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manuten��o de pedidos de back to back.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 28/04/06
*/
*------------------------*
Function AP100B2BConsig()
*------------------------*
Private cTipoProc := PC_BC
Return EECAP100()

/*
Funcao      : AP100CAFE()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manuten��o de embarque para embarques de Exporta��o de Caf�
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 26/05/08
*/
*----------------------*
Function AP100Cafe()
*----------------------*
Private cTipoProc := PC_CF
Return EECAP100()

/*
Funcao      : AP100COMM()
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Chama a manuten��o de embarque para embarques de Exporta��o de commodities
Autor       : Igor de Ara�jo Chiba
Data/Hora   :  12/06/2008
*/
*----------------------*
Function AP100COMM()
*----------------------*
Private cTipoProc := PC_CM
Return EECAP100()

/*
Funcao      : AP100MAN(cAlias,nReg,nOpc )
Parametros  : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida
Retorno     : .T.
Objetivos   : Executar enchoice
Autor       : Heder M Oliveira
Data/Hora   : 25/11/98 10:58
Revisao     : Jeferson Barros Jr. 23/07/01 15:35 - Melhoria no desempenho da manuten��o de processos.
Obs.        :
*/
*----------------------------------*
Function AP100MAN(cAlias,nReg,nOpc)
*----------------------------------*
Local lRet:=.T.,cOldArea:=Select(),oDlg,nInc //,bVal_OK := {||oDlg:End()}
Local aPos, aPosEnc, nOpc2
//Local aButtons := {}

//Local bTemReg := {|| IF(IsVazio("WorkIt"),(MsgStop("N�o Existem registros para a Manuten��o !","Aviso"),.F.),.T.) }
Local bTemReg := {|| IF(IsVazio("WorkIt"),(HELP(" ",1,"AVG0000632"),.F.),.T.) }

// CAF 19/02/2002 11:42
// Na inclus�o de processos quando tiver itens lancados, solicitar confirma��o para cancelar os dados.
Local bCancel := {|| IF(nOpc == VISUALIZAR .Or. nOpc == EXCLUIR .Or. lEE7Auto .Or. MsgYesNo(STR0061,STR0036),(nOpcA:=0,If(lEE7Auto,,oDlg:End())),) } //"Confirma cancelar entrada de dados ?"###"Aviso"

Local lFixado:=.f.
Local bMsgRem:= {|| MsgInfo(STR0179 +; //STR0179	"Esta rotina n�o poder� ser executada pois o pedido de exporta��o encontra-se com o status '"
                             Tabela("YC", M->EE7_STATUS) + "'.", STR0024)} //STR0024 	"Aten��o"

Local aOrd:=SaveOrd("EE7")
Local i:=0, j, nPos:=0//, oEnc //RMD - 14/11/12 - Alterado para privete, para possibilitar atualiza��o em outras telas

Local /*nRecNoEE7 := EE7->(RecNo()),*/ aEE7Filter := EECSaveFilter("EE7") // JPM - 02/12/05 - salva e limpa filtro no EE7
Local aOrdUpd:={} // Controle de registro para atualiza��o off-shore.
Local aAux
Local lReplicaItem:= EasyGParam("MV_AVG0060",,.F.) .And. !lEE7Auto //MCF - 01/02/2016

//RMD - 19/06/2019 - Verifica qual das sub-opera��es de exclus�o est� sendo executada e recarrega o aRotina com o array principal (quando existe um submenu o aRotina � enviado somente com o submenu para a manuten��o)
If aRotina[nOpc][4] == 5
   nOpc := nSelecao := 5
   If !IsMemVar("lAP100CANCE")
      lAP100CANCE := .F.
   EndIf
   aRotina := Menudef()
EndIf

Private lNfRemFinalizado:= .F.
Private nRecNoEE7 := EE7->(RecNo())

EE7->(DbClearFilter())
EE7->(DbGoTo(nRecNoEE7))

Private bVal_OK := {||oDlg:End()} // Disponibilizar evento de Ok nos pontos de entrada.
Private aBuffer
Private aHDEnchoice,aItemEnchoice,aAgEnchoice, aInEnchoice, aDeEnchoice, aNoEnchoice
Private oItens,oPedido,oLiquido,oBruto,oTotPedBr,oSayPesBru,oSayPesLiq,cPESQDESP
Private oSayTotFOB,oSayTotCom,oSayTotLiq,oSayTotBru,oTotFOB,oTotCom,oTotLiq // GFP - 11/04/2014
// **By JBJ - 09/08/2001 - Para uso na fun��o VIAODF3()
Private nSelecao := nOpc
// **

Private oMsSelect
Private aTela[0][0], aGets[0], nUsado:=0

Private aDeletados:={},lALTERA:=.T.,lAPROVA:=.T.,lCOMAGEN:=.F.,lAPROVAPF:=.T.
Private lDescIt := EasyGParam("MV_AVG0119",, .F.) // FJH 03/02/06

Private nOpcA:=3, aHEADER[0]

Private aAgDeletados:={}, aInDeletados:={}, aDeDeletados:={}, aNoDeletados:={}, aDocDeletados:={}
Private cStatus := "", lAlteraStatus := .f.
Private aButtons:={}

Private aEE7CamposEditaveis := {}
Private aEE8CamposEditaveis := {}

// ** AAF - 02/09/04 - Trata Back To Back ?
Private lBACKTO    := EasyGParam("MV_BACKTO",,.F.) .AND. ChkFile("EXK") ;
                     .AND. EE8->( FieldPos("EE8_INVPAG") > 0 ) .AND. EE9->( FieldPos("EE9_INVPAG") > 0  );
                     .And. (!lConsign .Or. cTipoProc $ PC_BN+PC_BC)
                     //RMD - 02/05/06 - N�o inclui o tratamento de Back To Back no processo regular quando estiver habilitada a rotina espec�fica de Back to Back.

//Guarda as invoices e os campos do Back To Back
Private aColsBtB   :={}
Private aHeaderBtB :={}

//Retorno do F3 nos Itens do Pedido
Private cRetF3BtB
Private lConsolida := EECFlags("INTERMED") .And. nOpc <> VINCULAR_RV // EECFlags("CONTROL_QTD") .And. aRotina[nOpc][4] <> VINCULAR_RV
                                                                                 // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padr�o para Off-Shore
Private aDesvinculados := {}

// JPM - 27/04/05 - Array de processos que dever�o ser atualizados ap�s a replica��o, "manualmente".(Carta de Cr�dito)
Private aAtuLC := {}

// JPM - 29/04/05 - Array de processos que dever�o ser atualizados ap�s a replica��o, "manualmente".(Gen�rico)
Private aAtuManual := {}

Private lCamposEditaveis := .f.

/*
AMS - 21/03/2005. Cria��o da variavel lValid para identicar se a valida��o dos campos no X3_VALID devem ser
                  executadas no oDlg:End().
*/
Private lValid := .T.

// O array abaixo ter� as linhas em que o pre�o negociado foi alterado.
aItAlterados := {}

If lBACKTO
   cFilEXK := xFilial("EXK")
   //Carrega Array de campos da Invoice a Pagar
   AP106Cols(OC_PE)
Endif
// **

Private aAtuQtdFil := {} /* JPM - 04/10/05 - Array com as atualiza��es que devem ser
                           feitas na filial oposta com rela��o a altera��es em quantidades */

/*ER - 28/12/05 �s 18:45 - O array abaixo ter� as linhas em que o pre�o negociado ou o Diferencial Off-Shore
                           forem alterados.*/
Private aItAlterados := {}
Private aCposAlterados := {} //JPM - 15/03/06 - Campos que devem ser replicados no caso de altera��o no item.
Private aCposCorresp   := {}
Private oEnc//RMD - 14/11/12 - Para possibilitar atualiza��o em outras telas

If lGrade
   oGrdExp:= MsMatGrade():New('oGrdExp',,"EE8_SLDINI",,"Ap102GrdValid()",,;
                            {{"EE8_SLDINI",NIL,NIL}})

   aGrdRec := {}
Endif

aAux := Array(2)
aAux[1] := {"EE8_PRENEG"}
aAux[2] := {"EE8_PRECO"}
If Type("EE8->EE8_DIFE2") <> "U"
   AAdd(aAux[1],"EE8_DIFE2")
   AAdd(aAux[2],"EE8_DIFERE")
EndIf
If Type("EE8->EE8_UNPRNG") <> "U"
   AAdd(aAux[1],"EE8_UNPRNG")
   AAdd(aAux[2],"EE8_UNPRC")
EndIf

If AvGetM0Fil() == cFilBr
   aCposAlterados := aClone(aAux[1])
   aCposCorresp   := aClone(aAux[2])
ElseIf AvGetM0Fil() == cFilEx
   aCposAlterados := aClone(aAux[2])
   aCposCorresp   := aClone(aAux[1])
EndIf

Private lUpdatepreco := .f. // Flag para recalculo de pre�os e totais de pre�o no processo da filial de off-shore.

Private lTemFixado   := .F.
Private nOpcAux      := nOpc
Private lAltFix := .F. //RMD - 05/05/08 - Indica se � poss�vel alterar itens com pre�o fixado e RV vinculada.
Private lRetPedInt   := lRet           //NCF - 12/05/2015 - para usar no ponto de entrada
Private nTotPedBr
//AOM - 26/04/2011 - Opera��o Especial
If lOperacaoEsp
   Private oOperacao :=  EASYOPESP():New() //AOM - 09/04/2011 - Inicializando a classe para tratamento de opera��es especiais
EndIf

// ** JPM - 23/01/06 - Compra FOB.
If Type("lCompraFOB") <> "L"
   lCompraFOB := .F.
EndIf

If (nSelecao = ALTERAR .Or. nSelecao = VISUALIZAR) .And. Type("EE7->EE7_CPRFOB") = "L"
   If !lCompraFOB .And. EE7->EE7_CPRFOB
      lCompraFOB := .T.
   EndIf
EndIf

Begin Sequence

   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.F.,.F.,{"AP100MAN_INICIO"})
   EndIf

   //** AAF 01/09/2015 - Bloqueio da inclus�o/exclus�o para Logix.
   If !IsInCallStack("INTEGDEF") .AND. AvFlags("EEC_LOGIX") .AND. !AvFlags("EEC_LOGIX_PREPED") .AND. (nOpc == INCLUIR .OR. nOpc == EXCLUIR) .And. !(IsInCallStack("AP100VendConsig") .OR. IsInCallStack("AP100B2BREG") .OR. IsInCallStack("AP100B2BCONSIG")) //!EE7->EE7_TIPO $ PC_VC+"/"+PC_BN+"/"+PC_BC
      EasyHelp(STR0217, STR0036) //"N�o � poss�vel efetuar esta opera��o pois o processo est� integrado com o ERP."
	  lRet:= .F.
	  Break
   EndIf
   //**

   //FSM - 05/10/2012
   If nOpc == EXCLUIR .And. !AP100ValAdiant(nOpc)
      Break
   EndIf

   nOpc := nOpcAux // Vari�vel utilizada para a altera��o da op��o do aRotina.
   // ** Limpa os arquivos tempor�rios.
   E_ZAP_AREA

   /* by jbj - Neste ponto o sistema ir� verificar se o pedido poder� ser alterado,
               em caso negativo, o sistema ir� exibir msg explicando as cr�ticas ao
               usu�rio e em seguida ir� abrir o pedido em modo de visualiza��o.  */

   If nOpc == ALTERAR
      //RMD - 19/06/2019 - Impede a altera��o de pedido cancelado
      If EE7->EE7_STATUS == ST_PC
         EasyHelp(StrTran(STR0245, "XXX", DToC(EE7->EE7_FIM_PE)), STR0246) //"Este pedido foi cancelado em 'XXX'. A opera��o ser� executada em modo de visualiza��o." ### "Opera��o Inv�lida"
         //Atualiza o cCadastro para o t�tulo da janela indicar a opera��o correta
         cCadastro := StrTran(cCadastro, Upper(STR0004), Upper(STR0002))
         Return AP100MAN(cAlias,nReg,VISUALIZAR)
      ElseIf EasyGParam("MV_AVG0090",,.t.)//JPM - 09/05/05 - define se o sistema bloqueia a edi��o do pedido quando todas as quantidades est�o embarcadas
         If !AP102CanModify(EE7->EE7_PEDIDO,.t.)
            nOpc := VISUALIZAR
            nSelecao := nOpc //JPM - 06/05/05
         EndIf
      Else //JPM
         If !AP102CanModify(EE7->EE7_PEDIDO,.f.)
            If EasyEntryPoint("EECAP100")
               ExecBlock("EECAP100",.F.,.F.,{"CAN_MODIFY"})
            EndIf
         EndIf
      EndIf
   ElseIf nOpc == APRVCRED .Or. aRotina[nOpc][4] == APRVPROF
      If !AP102CanModify(EE7->EE7_PEDIDO)
         lRet:=.f.
         Break
      EndIf
   ElseIf nOpc == EXCLUIR .And. IsMemVar("lAP100CANCE") .And. lAP100CANCE//RMD - 19/06/2019 - Impede a execu��o da opera��o de cancelamento para pedido j� cancelado
      If EE7->EE7_STATUS==ST_PC
         EasyHelp(StrTran(STR0245, "XXX", DToC(EE7->EE7_FIM_PE)), STR0246) //"Este pedido foi cancelado em 'XXX'. A opera��o ser� executada em modo de visualiza��o." ### "Opera��o Inv�lida"
         cCadastro := StrTran(cCadastro, Upper(STR0005), Upper(STR0002))
         Return AP100MAN(cAlias,nReg,VISUALIZAR)
      EndIf
   EndIf

   If Select("EXB") > 0 .And. Select("WorkDoc") > 0
      aAdd(aButtons,{"S4SB014N",{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),If(Empty(M->EE7_IMPORT),;
           MsgStop(STR0127,STR0024),AP100Agenda(OC_PE)))},STR0102/*,STR0152*/}) //"Informe o c�digo do importador."###"Aten��o"###"Agenda de Atividades/Documentos"### "Ag.At/Do"
   EndIf

   // *** EnchoiceBar ...
   IF nOpc == INCLUIR
      aAdd(aButtons,{"S4WB005N" /*"S4WB001N"*/ /* "S4WB006N"*/,{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),(AP100CopyFrom(nOpc),oMsSelect:oBrowse:Refresh())) },STR0007/*,STR0153*/}) //"Copiar Processo"### "Cop.Proc"
   Endif

   IF !EasyGParam("MV_AVG0005") .and. !EECFlags("ESTUFAGEM") // Deixar de gravar embalagens ?
      aAdd(aButtons,{"CONTAINR" /*"DBG14"*/,{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),AP100Volume()) }, STR0008}) //"Volumes"
   Endif

   // ** AAF - 31/08/04 - Adiciona bot�o da rotina de Back To Back
   If lBACKTO
      AP106EnchBar(OC_PE)
   Endif
   // **

   IF nOpc # INCLUIR  .And. nOpc # ALTERAR
      aAdd(aButtons,{"NOTE",{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),EECAA101(M->EE7_IDIOMA,,OC_PE,POSICIONE("SA1",1,XFILIAL("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA,"A1_PAIS"),,M->EE7_PEDIDO)) },STR0009/*,STR0154*/}) //"Documentos/Fax"### "Docto/Fax"
   Endif

   //IF nOpc <> VINCULAR_RV
   If nOpc <> VINCULAR_RV
      If EECFlags("FRESEGCOM")
         aAdd(aButtons,{"POSCLI",{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),AP100AGEN(OC_PE,if(lAltera,nOpc,2))) },STR0128/*,STR0155*/})//"Agentes de Comiss�o"###"Ag.Comis"
         aAdd(aButtons,{"PRECO", {|| If(Empty(M->EE7_PEDIDO), Help(" ",1,"AVG0000020"), AP100DespNac(OC_PE, nOpc)) },STR0129/*,STR0156*/})//"Despesas Nacionais"
      Else
         aAdd(aButtons,{"POSCLI",{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),AP100AGEN(OC_PE,if(lAltera,nOpc,2))) },STR0010}) //"Empresas"
         aAdd(aButtons,{"PRECO" /*"LISTA"*/,{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),(M->cPESQDESP:=M->EE7_PEDIDO,AP100DESP(OC_PE,if(lAltera,nOPC,2))))},STR0012}) //"Despesas"
      EndIf
      aAdd(aButtons,{"TABPRICE" /*"SALARIOS"*/,{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),AP100INST(OC_PE,if(lAltera,nOPC,2))) },STR0011/*,STR0157*/}) //"Institui��es Banc�rias"### "Inst.Ban"
      aAdd(aButtons,{"VENDEDOR",{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),AP100Notify(OC_PE,if(lAltera,nOpc,2)))},STR0013}) //"Notify's"
   Endif

// IF Str(nOpc,1) $ Str(VISUALIZAR,1)+Str(EXCLUIR,1)+Str(VINCULAR_RV,1)
   If Str(nOpc, 1) $ Str(VISUALIZAR,1)+Str(EXCLUIR,1)+Str(VINCULAR_RV,1)
      aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),IF(Eval(bTemReg),AP100DETMAN(VIS_DET),))},STR0002}) //"Visualizar"
   Else
      aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/, {|| ap100XDetman(INC_DET,,,lReplicaItem) } ,STR0003 }) //"Incluir"
      aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/,{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),IF(Eval(bTemReg),AP100DETMAN(ALT_DET),))},STR0004}) //"Alterar"
      aAdd(aButtons,{"EXCLUIR",{|| IF(Empty(M->EE7_PEDIDO),Help(" ",1,"AVG0000020"),IF(Eval(bTemReg),AP100DETMAN(EXC_DET),))},STR0014}) //"Excluir"
   EndIf

   //AMS - 12/04/2004 �s 15:18.
   //If nOpc == VINCULAR_RV
   If nOpc == VINCULAR_RV
      aAdd(aButtons, {"SDUPROP" /*"BMPPARAM"*/, {|| If(AP105V_RV(), oDlg:End(),) }, STR0120/*, STR0158*/}) //Vincula��o de R.V. //"Vincular R.V."### "Vinc.R.V"
   EndIf
   // ***

   If lCompraFOB // JPM - 24/01/06
      aAdd(aButtons, {"TABPRICE", {|| Ap106EditPrice() }, STR0145/*,STR0159*/}) //"Editar Pre�os de Compra"### "Ed.Pr.Com"
   EndIf

   /* WFS 19/01/2010
      Inclus�o do tratamento de nota fiscal de remessa, para atender
      ao conv�nio ICMS n.� 84 no DOU de 29/09/09. */
   If !NFRemFimEsp() .And. AvFlags("FIM_ESPECIFICO_EXP") .And. nOpc <> VISUALIZAR

      If nOpc == ALTERAR .And.;
         (EE7->EE7_STATUS == ST_FP .Or.; //faturado parcialmente
          EE7->EE7_STATUS == ST_FA .Or.; //faturado
          EE7->EE7_STATUS == ST_PE)      //lan�ado na fase de embarque

         lNfRemFinalizado:= .T.
      EndIf

      AAdd(aButtons, {"PEDIDO", {|| If(lNfRemFinalizado, Eval(bMsgRem), AE110VincNfEnt())}, STR0180/*, STR0181*/}) //STR0180"Vincular NFs de Entrada" //STR0181	NFs Entr.
   EndIf

   IF nOpc == INCLUIR
      bVal_OK:={||If(AP100LinOk(nOpc,nReg,oDlg),nOpcA:=1,nOpca:=0)}

      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next nInc
      cIDCAPA:= M->EE7_IDIOMA
      M->EE7_PESLIQ:=M->EE7_PESBRU:=M->EE7_TOTITE:=M->EE7_TOTPED:=0

      // ** BY JBJ - 27/08/01 - 15:26
      IF EMPTY(M->EE7_STATUS)
         /*
         If cTipoProc $ PC_BN+PC_BC
            M->EE7_STATUS := ST_CL //Credito Aprovado
         ElseIf lIntegra
         */
         If lIntegra
            M->EE7_STATUS := ST_AF // Aguardando Faturamento ...
         ElseIf lIntPrePed
            M->EE7_STATUS := ST_PB //Proforma em Edi��o
         Else
            M->EE7_STATUS := ST_SC  //aguardando solicitacao credito
         EndIf
      ENDIF

      // **

      // ** RMD - 28/04/06 - Tratamento para novos tipos de Pedido
      If lConsign
         M->EE7_TIPO := cTipoProc
      EndIf
      // **

      DSCSITEE7()

      // *** Cria Work's/Define variaves ...
      If !lEE7Auto
         MsAguarde({|| MsProcTxt(STR0015),; //"Preparando Dados do Processo ..."
                    EECAP102()}, STR0016) //"Processo de Exporta��o"
      Else
         EECAP102()
      EndIf

   Else

         RegToMemory("EE7",.F.,.T.,.T.)

         /*For nInc := 1 TO (cAlias)->(FCount())
            M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
         Next nInc*/

         If lCompraFOB
            M->EE7_CPRFOB := .T.
         EndIf

         cIDCAPA:= M->EE7_IDIOMA

         For nInc := 1 To Len(aMemos)
            M->&(aMemos[nInc][2]) := EasyMSMM(EE7->&(aMemos[nInc][1]),TAMSX3(aMemos[nInc][2])[1],,,LERMEMO,,,"EE7",aMemos[nInc][1])    //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
         Next


         ////////////////////////////////////////////////
         //Monta a grade com base nos itens j� gravados//
         ////////////////////////////////////////////////
         If lGrade
            Ap102GrdMonta()
         EndIf

         // *** Cria Work's/Define variaves ...
         If !lEE7Auto
            MsAguarde({|| MsProcTxt(STR0015),; //"Preparando Dados do Processo ..."
                          EECAP102(),;
                          lRet := AP100GRTRB(nOpc),;
                          Ap102WkVinc(),; // JPM - 02/01/05
                          }, STR0016) //"Processo de Exporta��o"
         Else
            EECAP102()
            lRet := AP100GRTRB(nOpc)
            Ap102WkVinc()
         EndIf

      IF ! lRet
         Break
      Endif

      //Verifica o parametro de conferencia de peso = .T., sendo ! Atribui o valor do banco.
      If EasyGParam( "MV_AVG0004" )
		 M->EE7_PESLIQ := EE7->EE7_PESLIQ
		 M->EE7_PESBRU := EE7->EE7_PESBRU
      EndIf

      // ** AAF - 09/09/04 - Carrega Dados no aColsBtB para o Back To Back
      IF lBACKTO .AND. nOpc <> INCLUIR
         AP106Dados(OC_PE)
      EndIF
      // **

      IF nOpc == VISUALIZAR
         bVal_OK:={|| If(lEE7Auto,,oDlg:End())}
         lALTERA:=.F.
         lAPROVA:=.F.
         lAPROVAPF:=.F.
      ElseIf nOpc==ALTERAR .or. nOpc == APRVCRED .or. aRotina[nOpc][4] == APRVPROF
          //AMS - 26/09/2003 �s 10:00 - Inserido RecLock no EE7.
          If !EE7->(RecLock("EE7", .F.))   // By JPP - 20/07/2005 10:15 - Inclus�o do quarto parametro.
             Break
          EndIf
          bVal_OK:={||If(AP100LinOk(nOpc,nReg,oDlg),nOpcA:=2,nOpca:=0)}
          lAPROVA:=.F.
          lAPROVAPF:=.F.

         //RMD - 21/06/19 - Valida��o movida para a antes da valida��o de possibilidade de altera��o (chamada da fun��o AP102CanModify), pois a mesma retorna mensagens fora do contexto de pedido cancelado
         /* If (M->EE7_STATUS == ST_PC)

             HELP(" ",1,"AVG0000644") //MSGINFO("Processo Cancelado/Embarcado.","Aten��o")

             /* By JBJ - 12/05/04 - Para processos cancelados, n�o permitir altera��o. Alterando a
                op��o para visualiza��o. /

             AP100MAN(cAlias,nReg,VISUALIZAR)
             Return lRet

          Else*/If aRotina[nOpc][4] == APRVCRED
             lALTERA:=.F.
             lAPROVA:=.T.
             lAPROVAPF:=.F.
          ElseIf aRotina[nOpc][4] == APRVPROF
             lALTERA  :=.F.
             lAPROVA  :=.F.
             lAPROVAPF:=.T.
          EndIf

          IF M->EE7_STATUS == ST_CL .Or. M->EE7_STATUS == ST_PA
             cStatus := M->EE7_STATUS
             aBuffer := Array(Len(aFieldCapa))
             For i:=1 To Len(aFieldCapa)
                IF Type("M->"+aFieldCapa[i]) = "U"
                   Loop
                Endif

                aBuffer[i] := Eval(MemVarBlock(aFieldCapa[i]))
             Next i
          EndIf

          IF (EasyEntryPoint("EECPPE04"))
             EXECBLOCK("EECPPE04",.F.,.F.)
          ENDIF

      ElseIf nOpc = EXCLUIR
         //AMS - 26/09/2003 �s 10:00 - Inserido RecLock no EE7.
         If !EE7->(RecLock("EE7", .F.)) // By JPP - 20/07/2005 10:15 - Inclus�o do quarto parametro. // NCF - 09/04/2019 - retirado o 4 parametro
            Break
         EndIf

         If !Ap100CanCancel()
            lRet := .f.
            Break
         EndIf

         bVal_OK:={||nOpca:=0,IF(AP100MANE(nOpc),If(lEE7Auto,nOpca:=1,(nOpca := 1, oDlg:End())),)}

      EndIf
   Endif

   //ER - 28/11/2006
   If EECFlags("BOLSAS")// .And. EECFlags("COMMODITY")
      aAdd(aHDEnchoice,"EE7_OPCFIX")
      aAdd(aEE7CamposEditaveis,"EE7_OPCFIX")
      aAdd(aHDEnchoice,"EE7_CODBOL")
      aAdd(aEE7CamposEditaveis,"EE7_CODBOL")
   Else
      If (nPos := AScan(aHDEnchoice,"EE7_CODBOL")) > 0  //CCH - 02/10/2008 - Caso exista o campo EE7_CODBOL e n�o houver BOLSAS ou COMMODITY
         ADel(aHDEnchoice,nPos)                         //deleta o campo dos arrays
         ASize(aHDEnchoice,Len(aHDEnchoice)-1)
      EndIf
      If (nPos := AScan(aEE7CamposEditaveis,"EE7_CODBOL")) > 0
         ADel(aEE7CamposEditaveis,nPos)
         ASize(aEE7CamposEditaveis,Len(aEE7CamposEditaveis)-1)
      EndIf
   EndIf

   If nOpc == APRVCRED .OR. (nOPC#INCLUIR .AND. !EMPTY(EE7->EE7_DTAPCR))
      AADD(aHDEnchoice,"EE7_DTAPCR")
   EndIf
   If lIntPrePed
      If aRotina[nOpc][4] == APRVPROF .OR. (nOPC#INCLUIR .AND. !EMPTY(EE7->EE7_DTAPPE))
         AADD(aHDEnchoice,"EE7_DTAPPE")
      EndIf
   EndIf

   If EE7->(Fieldpos("EE7_SISORI")) > 0 //THTS - 31/08/2018 - Projeto Execauto no pedido/Embarque
        aAdd(aHDEnchoice, "EE7_SISORI")
   EndIf

   // JPM - 01/02/06 - O c�digo da bolsa s� pode ser edit�vel se n�o houver item com pre�o fixado, isto por causa do c�lculo da quant. de lots.
   If lTemFixado .And. EECFlags("BOLSAS")
      If (nPos := AScan(aEE7CamposEditaveis,"EE7_CODBOL")) > 0
         ADel(aEE7CamposEditaveis,nPos)
         ASize(aEE7CamposEditaveis,Len(aEE7CamposEditaveis)-1)
      EndIf
   EndIf

   If AVFLAGS("EEC_LOGIX") .AND. nOPC # INCLUIR .And. !lEE7Auto  // GFP - 15/10/2014  //NCF - 17/10/2014 - Teste ExecAuto
      If (nPos := AScan(aEE7CamposEditaveis,"EE7_IMPORT")) > 0
         ADel(aEE7CamposEditaveis,nPos)
         ASize(aEE7CamposEditaveis,Len(aEE7CamposEditaveis)-1)
      EndIf
      If (nPos := AScan(aEE7CamposEditaveis,"EE7_IMLOJA")) > 0
         ADel(aEE7CamposEditaveis,nPos)
         ASize(aEE7CamposEditaveis,Len(aEE7CamposEditaveis)-1)
      EndIf
      If (nPos := AScan(aEE7CamposEditaveis,"EE7_IMPODE")) > 0
         ADel(aEE7CamposEditaveis,nPos)
         ASize(aEE7CamposEditaveis,Len(aEE7CamposEditaveis)-1)
      EndIf
      If (nPos := AScan(aEE7CamposEditaveis,"EE7_ENDIMP")) > 0
         ADel(aEE7CamposEditaveis,nPos)
         ASize(aEE7CamposEditaveis,Len(aEE7CamposEditaveis)-1)
      EndIf
      If (nPos := AScan(aEE7CamposEditaveis,"EE7_END2IM")) > 0
         ADel(aEE7CamposEditaveis,nPos)
         ASize(aEE7CamposEditaveis,Len(aEE7CamposEditaveis)-1)
      EndIf
   EndIf

   WorkIt->(dbGoTop())

   nOpcA:=0

   // ** JPM - 17/03/06 - Ponto de entrada antes da tela principal do pedido
   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.F.,.F.,{ "ANTES_TELA_PRINCIPAL" })
   Endif

   If !lEE7Auto

      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL

         aPosEnc:= PosDlgUp(oDlg)
         aPosEnc[3] += 30

         /* For�ar a chamada em modo de altera��o quando for aprova��o da proforma (cen�rio
            de integra��o EAI). */
         nOpc2:= nOpc
         If aRotina[nOpc][4] == APRVPROF
            nOpc2:= ALTERAR
         EndIf

         // JPM - 27/03/06 - Substituir por MsMGet para usar fun��o para validar folder.
         oEnc := MsMGet():New(cAlias, nReg, nOpc2,,,,aHDEnchoice, aPosEnc, If(Len(aEE7CamposEditaveis) <> 0 .Or. lCamposEditaveis, aEE7CamposEditaveis,),,,,,oDlg) // GFP - 12/07/2012 - Inclusao do objeto oDlg
         EECValidFolder(oEnc)

         // GFP - 12/07/2012 - Ajuste para exibi��o no modo classico
         oEnc:oBox:Align := CONTROL_ALIGN_TOP

         aPos := PosDlg(oDlg)//PosDlgDown(oDlg)  // GFP - 12/07/2012
         aPos[1] += 30
         aPos[3] -= 26

         oPanel1:=	TPanel():New(0,0, "", oDlg,, .T., ,,,0,0,,.T.)
         oPanel1:Align:= CONTROL_ALIGN_ALLCLIENT

         aPos[3] := aPos[3]/2
         aPos[4] := aPos[4]/2

         // JPM - 10/10/05 - Controle de quantidades entre filiais Brasil e Off-Shore - Consolida��o de itens
         If !lConsolida
            oMsSelect := MsSelect():New("WorkIt",,,Ap102CpoBrowse(nOpc),,,aPos,,,oPanel1)
         Else // mostra itens consolidados
            oMsSelect := MsSelect():New("WorkGrp",,,aGrpBrowse,,,aPos,,,oPanel1)
         EndIf

         oMsSelect:bAval := {|| IF(Str(nOpc, 1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1)+"/"+Str(VINCULAR_RV,1),AP100DetMan(VIS_DET),AP100DetMan(ALT_DET)) }

         /*
         Rotina de sem�foro para sinalizar itens com e sem RV.
         Objetivo    : Sinalizar img verde para itens com R.V., img vermelha para itens sem R.V.
         Autor       : Alexsander Martins dos Santos
         Data e Hora : 06/05/2004 �s 10:27.
         */
         If nOpc = VINCULAR_RV

            aSaveColumns := aClone(oMsSelect:oBrowse:aColumns)
            oMsSelect:oBrowse:aColumns := {}

            oCol         := TCColumn():New()
            oCol:lBitmap := .T.
            oCol:lNoLite := .T.
            oCol:nWidth    := 33
            oCol:bData     := {||If(!Empty(WorkIT->EE8_RV) .Or. WorkIt->EE8_SLDATU <= 0, STR0161, STR0162)}//"Sim" "N�o"
            oCol:cHeading  := STR0163//"Possui Rv?"

            oMsSelect:oBrowse:AddColumn(oCol)

            For nPos := 1 To Len(aSaveColumns)
               oMsSelect:oBrowse:AddColumn(aSaveColumns[nPos])
            Next

         EndIf
         //Fim da rotina de sem�foro.

         // GFP - 12/07/2012 - Ajuste para exibi��o no modo classico
         oMsSelect:oBrowse:Align:= CONTROL_ALIGN_TOP

         aPos[1] := aPos[3] + 1
         aPos[3] := aPos[1]+28

         // GFP - 12/07/2012 - Ajuste para exibi��o no modo classico
         oPanel2:=	TPanel():New(aPos[1],aPos[2], "", oPanel1,, .F., .F.,,, aPos[4], 40)
         oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT

         aPos[3] := aPos[3]*2
         aPos[4] := aPos[4]*2

         AP100TTELA(.T.,aPos,oPanel2)
         oDlg:lMaximized := .T.

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bVal_Ok,bCancel,,aButtons)
   Else
      // *** Execu��o via MsExecAuto

      	CheckDescon(aAutoCab, aAutoItens)
        //RMD - 13/08/18 - Faz a verifica��o da Via de Transporte
        AtuVia(aAutoCab)
        lOkItemAuto := .T.
        lOkDadosAux := .T.
        lOkEmbAuto  := .T.
        TEClearChv("EE7",aAutoCab) //NCF - 29/03/2019
		If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},nOpc, aHDEnchoice)

		    If nOpc <> EXCLUIR
                WorkIt->(DbSetOrder(1))
                nPosItem := 0
                For nInc := 1 To Len(aAutoItens)
                    AvKeyAuto(aAutoItens[nInc])
                    If !(nPosItem > 0 .AND. nPosItem <= Len(aAutoItens[nInc]) .AND. aAutoItens[nInc][nPosItem][1] == "EE8_SEQUEN") .AND. (nPosItem := aScan(aAutoItens[nInc], {|x| x[1] == "EE8_SEQUEN" .And. !Empty(x[2]) })) == 0
                        AutoGRLog("Erro - Sequ�ncia do Item n�o informada.")
                        lOkItemAuto := .F.
                        Exit
                    EndIf

                    // Checa a opera��o para o item atual
                    If /*EasySeekAuto("WorkIt", aAutoItens[nInc]) .AND.*/ WorkIt->(DbSeek(aAutoItens[nInc][nPosItem][2])) //NCF - 05/09/2013 - Compatibiliza��o de altera��o para funcionamento da integra��o SIGAEEC x LOGIX
                        //RMD - 22/12/17 - Posiciona a WorkGrp caso seja OffShore
                        If lConsolida .And. Select("WORKGRP") > 0
                            WorkGrp->(DbSeek(WorkIt->(Ap104SeqIt())))
                        EndIf
                        If aScan(aAutoItens[nInc], {|x| x[1] == "AUTDELETA" .And. Upper(x[2]) == "S" }) > 0
                            //Exclus�o de item
                            nOpcAutoItem := EXC_DET
                        Else
                            nOpcAutoItem := ALT_DET
                        EndIf
                    ElseIf aScan(aAutoItens[nInc], {|x| x[1] == "AUTDELETA" .And. Upper(x[2]) == "S" }) == 0
                        //Altera��o de item
                        nOpcAutoItem := INC_DET
                    Else
                        AutoGRLog(STR0197) // STR0197 "Item n�o encontrado na Work"
                        lOkItemAuto := .F.
                        Exit
                    EndIf

                    // *** Executa a integra��o do item
                  If !(lOkItemAuto := AP100DETMAN(nOpcAutoItem,, aAutoItens[nInc],lReplicaItem))
                        Exit
                    EndIf
                    // ***
                Next

                If lOkItemAuto .AND. Valtype(aAutoComp) == "A" //LRS - 18/10/2018
                    lOkDadosAux := IntegAux(aAutoComp)
                EndIf

               AP100PrecoI(,,.T.)
		    EndIf

            If nOpc == EXCLUIR
               If aScan(aAutoCab, {|x| x[1] == "AUTDELETA" .And. Upper(x[2]) == "S" }) > 0
                  lEE7AutoDel := .T.
               EndIf
               If aScan(aAutoCab, {|x| x[1] == "AUTCANCELA" .And. Upper(x[2]) == "S" }) > 0
                  lEE7AutoCan := .T.
               EndIf

               //Se for exclus�o e a atualiza��o autom�tica de embarque tiver sido informada, exclui o embarque antes
               If (lEE7AutoDel .Or. lEE7AutoCan) .And. aScan(aAutoCab, {|x| x[1] == "ATUEMB" .And. X[2] == "S" }) > 0
                    aEmbTables := AtuEmbArr(nOpc, aAutoCab, aAutoItens, aAutoComp)
                    If (nPosEEC := aScan(aEmbTables, {|x| x[1] == "EEC" })) > 0 .And. EasySeekAuto("EEC", aEmbTables[nPosEEC][2], 1)//Somente executa a exclus�o se o embarque existir
                        //A rotina de embarque possui works com os mesmos nomes das works da rotina de pedido, por isso faz um backup e fecha as works
                        AP104TrataWorks(.T., OC_PE)
                        MsAguarde({|| MsExecAuto({|x,y| EECAE100(,x,y)}, nOpc, aEmbTables) }, "Cancelando processo de embarque.")
                        AP104TrataWorks(.F., OC_PE)
                        If !(lOkEmbAuto := !lMsErroAuto)
                            EasyHelp(STR0231, STR0036)//"O cancelamento do pedido n�o foi poss�vel devido a erro no cancelamento autom�tico do embarque."###"Aviso"
                        EndIf
                    EndIf
               EndIf

               If !lEE7AutoDel .And. !lEE7AutoCan
                  AutoGRLog(STR0198) // STR0198 "N�o foi informada a sub-opera��o de exclus�o (Cancelar/Eliminar)"
               EndIf
            EndIf

		    If lOkItemAuto .And. lOkDadosAux .And. lOkEmbAuto .And. (nOpc <> EXCLUIR .Or. lEE7AutoDel .Or. lEE7AutoCan)
		       lMsErroAuto := .F.
               //Se n�o ocorreu erro ao integrar algum dos itens, executa as a��es do bot�o OK
		       Eval(bVal_OK) //### VER
		    Else
		       //Caso contr�rio executa a a��o do bot�o CANCELAR
		       Eval(bCancel)
		    EndIf
		EndIf
      // ***
   EndIf

   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.F.,.F.,{"FECHA_TELA_PRINCIPAL"})
   Endif

   IF nOpcA == 0
      IF nOpc == INCLUIR
         DO WHILE __lSX8
            RollBackSX8()
         ENDDO
      Endif
      lRet := .F.
      Break
   Else
      lRet := .T.
   Endif

   If lIntermed .And. lUpdatepreco
      aOrdUpd := SaveOrd("EE7")
      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))
         Ap105CallPrecoI(cFilEx)
      EndIf
      RestOrd(aOrdUpd,.t.)
   EndIf

End Sequence

//AOM - 27/04/2011
If lOperacaoEsp
   oOperacao:DeleteWork()
EndIf

dbselectarea(cOldArea)

RestOrd(aOrd,.t.)

If lIntermed .And. lReplicaDados .And. lUpdatepreco
   aOrd := SaveOrd("EE7")
   EE7->(DbSetOrder(1))
   If EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))
      Ap105CallPrecoI(cFilEx)
   EndIf
   RestOrd(aOrd,.t.)
EndIf

/* by jbj - 09/06/05 - Ir� disparar o camando MsUnLockAll() para todas as tabelas utilizadas
                       na rotina de pedido e embarque. */
Ap100UnLock()

// JPM - 02/12/05 - restaura filtro no EE7
// 18.mai.09 - UE719063 - Corre��o para o MBrowse parar no campo rec�m inclu�do - HFD
//nRecNoEE7 := EE7->(RecNo())
EECRestFilter(aEE7Filter)
EE7->(DbGoTo(nRecNoEE7))

If !lRetPedInt          //NCF - 12/05/2015 - Acata resultado do ponto de entrada "AP100MAN_INICIO"
   lRet := lRetPedInt
EndIf
                  //NCF - 09/04/2019 - Pode invalidar no bloco begin\end sequence onde a variavel fica nula.
If lEE7Auto .And. IsMemVar('lOkEmbAuto') .And. lOkEmbAuto //N�o muda o lMsErroAuto quando tiver dado erro na integra��o do embarque, pois esta opera��o n�o ir� estornar a grava��o do pedido mas precisa ser exibida ao usu�rio
   lMSErroAuto := !lRet
EndIf


Return lRet

/*
Funcao     : ap100XDetman(INC_DET,lReplicaItem)
Objetivos  : .
Autor      : 
*/
function ap100XDetman(cIncDet,lXExibe,xXAutoItem,lReplicaItem)
   local lRet := .T.

   if Empty(M->EE7_PEDIDO)
      Help(" ",1,"AVG0000020")
   else
      while lRet
         lRet := AP100DETMAN(cIncDet,lXExibe,xXAutoItem,lReplicaItem)
      endDo
   endif 

return lRet

/*
Funcao     : AP100CANCE(cAlias,nReg,nOpc)
Objetivos  : Executa a opera��o de cancelamento do pedido, criando a vari�vel lAP100CANCE para indicar a sub-opera��o do processo de exclus�o.
Autor      : Rodrigo Mendes Diaz
*/
Function AP100CANCE(cAlias,nReg,nOpc)
Private lAP100CANCE := .T.
Return AP100MAN(cAlias,nReg,nOpc)

/*
Fun��o     : Ap100CanCancel()
Objetivos  : Validar se o processo pode ser cancelado/exclu�do
Par�metros : Nenhum
Retorno    : .T./.F.
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 06/12/05 �s 13:08
Observa��o : esta fun��o tamb�m � utilizada para validar se o processo da outra filial poder� ser cancelado.
*/
*---------------------------*
Function Ap100CanCancel(cFil)
*---------------------------*
Local lRet := .t., lFixado := .f., lRv := .f., lFil := .t., cNomeFil := STR0149//"Processo da Filial"
Local aOrd := SaveOrd({"EE8","EE7","EEQ"})

If cFil = Nil
   cFil := xFilial("EE7")
   lFil := .f.
EndIf

If lIntermed .And. lFil
   If cFil = cFilBr
      cNomeFil += " " + STR0150 //"Brasil"
   Else
      cNomeFil += " " + STR0151 //"Off-Shore"
   EndIf
   cNomeFil := " - " + cNomeFil
Else
   cNomeFil := ""
EndIf

Begin Sequence

   If lCommodity
      EE8->(DbSetOrder(1))
      EE8->(DbSeek(cFil+EE7->EE7_PEDIDO))
      Do While !EE8->(EOF()) .And. cFil+EE7->EE7_PEDIDO==EE8->EE8_FILIAL+EE8->EE8_PEDIDO
         If !lFixado .And. !Empty(EE8->EE8_DTFIX)
            lFixado := .t.
         EndIf
         If !Empty(EE8->EE8_DTVCRV) // JPM - Verifica��o do R.V. - se tiver, n�o pode cancelar o pedido.
            lRv := .t.
            Exit
         EndIf
         EE8->(DbSkip())
      EndDo
   EndIf


   If lRv // JPM - 14/11/05
      EasyHelp(STR0146,STR0024 + cNomeFil) //"Este processo n�o poder� ser cancelado, pois o mesmo possui iten(s) vinculado(s) a R.V.. Fa�a o estorno da vincula��o de R.V.."###"Aten��o"
      lRet := .f.
      Break
   EndIf

   If EE8->(FieldPos("EE8_ORIGV")) > 0 // JPM - 25/11/05
      If Left(EE7->EE7_PEDIDO,1) = "*"
         EasyHelp(STR0148, STR0059 + cNomeFil) // "Este � um pedido especial para vincula��o de RV. Para cancel�-lo, v� em Atualiza��es -> Siscomex -> Gera��o de RV." ### "Aten��o"
         lRet := .f.
         Break
      EndIf
   EndIf

   If lPagtoAnte
      EEQ->(DbSetOrder(6))
      If EEQ->(DbSeek(cFil+"P"+EE7->EE7_PEDIDO))
         MsgStop(STR0114+Replic(ENTER,2)+; //"Este processo n�o pode ser cancelado ou exclu�do."
                 STR0115+ENTER+; //"Detalhes:"
                 STR0116+ENTER+; //"O processo selecionado possui adiantamento(s) lan�ado(s)."
                 STR0117,STR0024 + cNomeFil) //"Para cancelar ou excluir, primeiro estorne o(s) adiantameto(s)."###"Aten��o"
         lRet := .f.
         Break
      EndIf
   EndIf

   If lFixado
      If !MsgYesNo(STR0078,STR0024 + cNomeFil) //"Este processo possue item(ns) fixado(s). Deseja continuar o processo de cancelamento?"###"Aten��o"
         lRet := .f.
         Break
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : AP100GRTRB
Parametros  :
Retorno     : .T.
Objetivos   : Gravar TRB
Autor       : Heder M Oliveira
Data/Hora   : 18/11/98 15:09
Revisao     : WFS 23/02/2010
              Tratamentos de carga da work, quando usado o recurso grade.
Obs.        :
*/
Function AP100GRTRB(nOpc,lCopy)
   Local aOrd := SaveOrd({"EE8", "SB4"},1,)

   Local cFilItem:=XFILIAL("EE8")
   Local cSequen := ""
   Local cMascara:= EasyGParam("MV_MASCGRD")

   Local nSequencia:= 0 //RMD - 18/06/08
   Local nTamRef   := Val(Substr(cMascara,1,2))
   Local nPslqto   := 0
   Local nPsbrto   := 0
   Local nQtdEmb   := 0

   Local lRet       := .T.
   Local lAgrGrd    := .F.
   Local lExibeItGrd:= .F.

   Default lCopy := .f.


   Begin Sequence

      If Type("lTemFixado") <> "L"
         lTemFixado:= .F.
      EndIf

      SB4->(DBSetOrder(1))

      /* WFS 12/02/2010
        Por par�metro ser� informado ao sistema se o agrupamento dos itens da grade ocorrer�
        durante a visualiza��o do processo.*/
      If nOpc == VISUALIZAR
         lExibeItGrd:= EasyGParam("MV_AVG0192",, .F.)
      EndIf

      EE8->(DBSETORDER(1))
      lRet := EE8->(DBSEEK(cFilItem+M->EE7_PEDIDO))

      M->EE7_PESLIQ:=M->EE7_PESBRU:=M->EE7_TOTITE:=0

      While EE8->(!Eof() .and. EE8_FILIAL == cFilItem .and. EE8_PEDIDO == EE7->EE7_PEDIDO)

         If !lTemFixado .And. !Empty(EE8->EE8_DTFIX)
            lTemFixado := .T.
         EndIf

         If lGrade .and. EE8->EE8_GRADE == "S" .and. !Empty(EE8->EE8_ITEMGR) .And. !lExibeItGrd

            lAgrGrd := .T.

            //WFS 10/02/2010 - tratamentos para montagem da work do pedido quando itens da grade
            If EE8->EE8_SEQUEN <> cSequen

               WorkIt->(DBAppend())
               AVReplace("EE8", "WorkIt")

               // BAK - Tratamento para os campos memos da EE8
               If EE8->(FieldPos("EE8_DESC")) > 0
                  WorkIt->EE8_VM_DES := EasyMSMM(EE8->EE8_DESC,AvSX3("EE8_VM_DES",AV_TAMANHO),,,LERMEMO,,,"EE8","EE8_DESC")
               EndIf
               If EE8->(FieldPos("EE8_QUADES")) > 0 .And. WorkIt->(FieldPos("EE8_DSCQUA")) > 0                                   //NCF - 24/09/2013 - ajuste para integra��o via Mensagem �nica SIGAEEC x LOGIX
                  WorkIt->EE8_DSCQUA := EasyMSMM(EE8->EE8_QUADES,AvSX3("EE8_DSCQUA",AV_TAMANHO),,,LERMEMO,,,"EE8","EE8_QUADES")
               EndIf

               WorkIt->EE8_SLDINI:= 0
               WorkIt->EE8_SLDATU:= 0

               nPslqto:= 0
               nPsbrto:= 0
               nQtdEmb:= 0

               WorkIt->EE8_RecNo := EE8->(RecNo())

               SB4->(DBSeek(xFilial("SB4") + AvKey(WorkIt->EE8_COD_I , "B4_COD")))
               WorkIt->EE8_VM_DES:= SB4->B4_DESC

               cSequen:= EE8->EE8_SEQUEN
            EndIf

         Else
            lAgrGrd := .F.
         EndIf

         If !lAgrGrd
            WorkIt->(DBAPPEND())
            AVReplace("EE8","WorkIt")

            // BAK - Tratamento para os campos memos da EE8
            If EE8->(FieldPos("EE8_DESC")) > 0
               WorkIt->EE8_VM_DES := EasyMSMM(EE8->EE8_DESC,AvSX3("EE8_VM_DES",AV_TAMANHO),,,LERMEMO,,,"EE8","EE8_DESC")
            EndIf
            If EE8->(FieldPos("EE8_QUADES")) > 0 .And. WorkIt->(FieldPos("EE8_DSCQUA")) > 0                                  //NCF - 24/09/2013 - ajuste para integra��o via Mensagem �nica SIGAEEC x LOGIX
               WorkIt->EE8_DSCQUA := EasyMSMM(EE8->EE8_QUADES,AvSX3("EE8_DSCQUA",AV_TAMANHO),,,LERMEMO,,,"EE8","EE8_DSCQUA")
            EndIf

         Else
            WorkIt->EE8_SLDINI += EE8->EE8_SLDINI
            WorkIt->EE8_SLDATU += EE8->EE8_SLDATU
         EndIf

         If lAgrGrd .and. EE8->EE8_GRADE == "S"
            WorkIt->EE8_COD_I:= SubStr(EE8->EE8_COD_I,1,nTamRef)
         EndIf

         If lCopy .and. !lAgrGrd//RMD 18/06/08 - N�o mant�m a sequ�ncia do pedido original
            WorkIt->EE8_SEQUEN := STR(++nSequencia,TAMSX3("EE8_SEQUEN")[1])
         EndIf
         WorkIt->TRB_ALI_WT:= "EE8"

         If !lAgrGrd
            WorkIt->TRB_REC_WT:= EE8->(Recno())
         EndIf

         M->EE7_TOTITE++

         EECPPE07("PESOS_TRB")

         //WFS - 17/04/09 ---
         /*Quando a unidade de medida n�o est� preenchida na capa, o sistema assume kg como padr�o.
           A unidade dos itens devem ser convertidas para serem apresentadas na tela quando a work
           � carregada. */
         If Empty(M->EE7_UNIDAD)
            M->EE7_UNIDAD:= "KG"
         EndIf

         //Tratamento para agrupamento dos pesos
         If lAgrGrd
            //Totaliza��o dos pesos na EE7
            TotalizaPeso()

            WorkIt->EE8_PSLQTO += nPslqto
            WorkIt->EE8_PSBRTO += nPsbrto
            WorkIt->EE8_QTDEM1 += nQtdEmb
            nPslqto:= WorkIt->EE8_PSLQTO
            nPsbrto:= WorkIt->EE8_PSBRTO
            nQtdEmb:= WorkIt->EE8_QTDEM1

         Else
            //Totaliza��o dos pesos na EE7
            TotalizaPeso()
         EndIf

         If !lAgrGrd .And. AvFlags("EEC_LOGIX") .And. EE8->(FieldPos("EE8_PEDERP")) > 0 .And. WorkIt->(FieldPos("EE8_PEDERP")) > 0
            WorkIt->EE8_PEDERP  := EE8->EE8_PEDERP
         EndIf

         //Fim da rotina.
         If !lAgrGrd
            WorkIt->EE8_RECNO  := EE8->(RECNO())
         EndIf

         //AAF 16/09/04 - a copia dos campos do Back to Back
         If lBACKTO .AND. lCopy .AND. !Empty(EE8->EE8_INVPAG)
            WorkIt->EE8_INVPAG := CriaVar("EE8_INVPAG")
            WorkIt->EE8_VLPAG  := CriaVar("EE8_VLPAG")
         Endif

         //Ao copiar o processo os campos de Opera�oes especiais s�o inicializados em branco - AOM - 04/05/2011
         If lCopy .And. lOperacaoEsp
            WorkIt->EE8_CODOPE := ""
            WorkIt->EE8_CODOPE := ""
         EndIf

         EE8->(DBSKIP())

      Enddo

      AP100PrecoI(.t.) // Preco Incoterm

      // JPM - 07/10/05 - Carregar work de agrupamentos
      If EECFlags("INTERMED") .And. Select("WorkGrp") > 0 // EECFlags("CONTROL_QTD") .And. Select("WorkGrp") > 0
                                                          // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padr�o para Off-Shore
         If lCopy
            //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
            AvZap("WorkGrp")
         EndIf
         Ap104LoadGrp(.T.)
      EndIf

   End Sequence

   RestOrd(aOrd)

Return lRet

/*
Funcao      : TotalizaPeso
Objetivos   : Totalizar os pesos da capa do pedido
Parametros  :
Retorno     :
Autor       : Wilsimar Fabr�cio da Silva
Data/Hora   : 05/03/2010
Revisao     :
Obs.        :
*/
Static Function TotalizaPeso()
Begin Sequence

   If lConvUnid
      M->EE7_PESBRU += AvTransUnid(IIF(!Empty(WorkIt->EE8_UNPES),WorkIt->EE8_UNPES,"KG"), IIF(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"), WorkIt->EE8_COD_I, WorkIt->EE8_PSBRTO,.F.)
      M->EE7_PESLIQ += AvTransUnid(IIF(!Empty(WorkIt->EE8_UNPES),WorkIt->EE8_UNPES,"KG"), IIF(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"), WorkIt->EE8_COD_I, WorkIt->EE8_PSLQTO,.F.)
   Else
      M->EE7_PESBRU += WorkIt->EE8_PSBRTO
      M->EE7_PESLIQ += WorkIt->EE8_PSLQTO
   EndIf

End Sequence
Return

/*
Funcao      : AP100DETMAN(nTipo,lExibe)
Parametros  : nTipo  := VIS_DET/INC_DET/ALT_DET/EXC_DET
              lExibe := Faz a inclusao do Workit sem tela de edi��o
Retorno     : .T.
Objetivos   : Permitir manutencao de outras descricoes da moeda
Autor       : Heder M Oliveira
Data/Hora   : 25/11/98 11:47
Revisao     : Jeferson Barros Jr. 02/10/01 - 14:25
              Jo�o Pedro Macimiano Trabbold - 10/10/05 �s 11:30
Obs.        : JBJ - Habilitar a grava��o de itens sem exibir tela ...
              JPM - Tratar consolida��o de itens
*/
*---------------------------------------------*
Function AP100DETMAN(nTipo, lExibe, xAutoItem, lReplicaItem)
*---------------------------------------------*
Local lRet:=.T.,cOldArea:=Select()
Local oDlg,nInc,cNewTit,cSequencia
Local nRecno,aPos, i, j:=0
Local nCodI := 0

Local nRecOld := WorkIt->(RecNo()), aBufferIt, aBufferItIt
Local nPos

// ** By JBJ - 10/06/2002 - 15:06
Local aCodDesc:={}, aVmDesc:={} //Local cVmDes, cDesc
Local aBkp := {}
Local lBlqAltPedI := .T.
Local bDetOk   := {||nOpcA:=1,If(AP100VALDET(nTipo,nRECNO) .And. If(nTipo=ALT_DET .Or. nTipo=INC_DET,AP100Crit("EE8_PRECO"),.T.) .And. VldOpeAP100("BTN_IT_EE8",nTipo)/*AOM - 27/04/2011 - Operacao Especial*/,If(lEE8Auto,, oDlg:End()),nOpcA:=0)}
Local bCancel  := {||nOpcA:=0,If(lEE8Auto,,oDlg:End())}
//Local aButtons := {} //LRS - 13/01/2015 - Nopado para cria��o de uma variavel private.
Local oPanel1, oPanel2 // GFP - 27/05/2013
Local aGrpVerify := {} //JPM
Local aOrdSB1Auto := {}  //NCF - 31/03/2014
Local lItemDel    := .T. //NCF - 22/04/2014
Local lPedOnEmb   := .F. //NCF - 08/05/2015
Local aOrdEE9
Local lOpcPadrao:= GetNewPar("MV_REPGOPC","N") == "N" //LRS -20/10/2015
Local cAliasTab := "" //LRS -20/10/2015
Local nDecDesc  := 0
Local nDecPrc   := 0

nPosInfIt := 0
cMsgLogIt := ""
Private aButtons := {} //LRS  13/01/2015
Private lEE8Auto := xAutoItem <> NIL
Private aAutoItem := xAutoItem

Private oGetPsLiq, oGetPsBru, oGetPreco, oGetItens, oGetPrecoI, oSayPsBru, oSayPsLiq
Private aTela[0][0],aGets[0], nUsado

Default lExibe     := .F.

If Type("lConsolida") <> "L"
   lConsolida := .f.
EndIf

Private nOpcA := 0
// ** JPM - 10/10/05 - Consolida��o de itens na rotina de controle de qtds entre Br e Off-Shore
Private lConsolItem := lConsolida .And.;
                       !lExibe    .And.;
                       nTipo <> INC_DET

If EECFlags("INTERMED") // EECFlags("CONTROL_QTD") // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padr�o para Off-Shore
   Private cConsolida := Ap104StrCpos(aConsolida)
EndIf

Private oMsMGet, aObjs

Private aHeader, aTotaliza := {}, aNotEditGetDb := {}, aDifValid := {}
Private aCposDif, aCposNotShow, aCposGetDb := {}, aStruct := {}, aAllCpos := {}
Private lDelTudo := .f.
Private lPerguntou := .f.,cAuxIt
Private nOpcFolder := 1
Private cCampoBKP := "" //LRS - 20/10/2015

// **

nOPCI := nTipo

//wfs 17/10/12
If ValType(aRotina) == "A" .And. Len(aRotina) == 0
   aRotina := MenuDef(.T., If(cTipoProc == PC_RG, "EECAP100", ProcName(1)))
EndIf

Begin Sequence

   If (AVFLAGS("EEC_LOGIX") .And. !lIntPrePed) .AND. (nTipo == INC_DET .OR. nTipo == EXC_DET) .And. !lEE7Auto .And. !(IsInCallStack("AP100VendConsig") .OR. IsInCallStack("AP100B2BREG") .OR. IsInCallStack("AP100B2BCONSIG")) // GFP - 15/10/2014  //NCF - 17/10/2014 - Teste ExecAuto
      EasyHelp(STR0217,STR0036) // "N�o � poss�vel efetuar esta opera��o pois o processo est� integrado com o Logix."  ###  "Aviso"
      Return .F.
   EndIf

   If lConsolItem // JPM - 10/10/05
      Private lArtificial := .f.

      /*
      Nopado por ER em 24/11/2006.
      Os Itens que n�o possu�rem quebra de linha, n�o ser�o tratados como Consolida��o.

      Ap104TrtCampos(1) //tratamentos para o novo folder com browse de itens. (defini��o de campos, cria��o de work)
      M->EE8_TOTAL := 0 //inicializa vari�vel.
      */

      //Tratar Filtro abaixo..
      //ER - 24/11/2006
      If Ap104TrtCampos(1) //tratamentos para o novo folder com browse de itens. (defini��o de campos, cria��o de work)
         M->EE8_TOTAL := 0 //inicializa vari�vel.
      Else
         lConsolItem := .F.
         WorkIt->( DBClearFilter() )  // PLB 03/04/07
      EndIf

   EndIf

   /* by jbj - Neste ponto o sistema ir� verificar as condi��es que possibilitam
               a altera��o/exclus�o de itens no pedido de exporta��o. */
   Do Case
      Case nTipo == INC_DET
           If !Ap104CanInsert()
              lRet:=.f.
              Break
           EndIf

      Case nTipo == EXC_DET
           If !Ap104CanDel()
              lRet:=.f.
              Break
           EndIf
   EndCase

   If !lExibe //** A inclus�o ser� feita via tela de edi��o ..

      /*
      AMS - 24/06/2005. Tratamento para n�o permitir a inclus�o ou exclus�o de itens caso o pedido seja origin�rio da integra��o e
                        o parametro MV_AVG0094 estiver habilitado.
      */
      If Ap106VlIntegra(nTipo) // By JPP - 29/06/2005 - 14:00 - Esta fun��o substitui a condi��o abaixo devido a estouro de define.
         Break
      EndIf
/*      If EasyGParam("MV_AVG0094",, .F.) .and. EE7->(FieldPos("EE7_INTEGR") > 0 .and. EE7_INTEGR = "S")
         If nTipo == INC_DET .or. nTipo == EXC_DET
            MsgStop(STR0134, STR0059) //"N�o � permitida a inclus�o ou exclus�o de itens para este processo devida-a sua gera��o atrav�s da integra��o."###"Aten��o"
            Break
         EndIf
      EndIf   */

      If nTipo==INC_DET
         WorkIt->(DBGOBOTTOM())
         cSEQUENCIA := STR(VAL(WorkIt->EE8_SEQUEN)+1,TAMSX3("EE8_SEQUEN")[1])
         WorkIt->(DBSKIP())
      EndIf

      nRecno:=WorkIt->(RecNo())

      If nTipo == INC_DET
         For j:=1 TO EE8->(FCount())
            M->&(EE8->(FieldName(j))) := CriaVar(EE8->(FieldName(j)))
         Next
         For j:=1 To Len(aMemoItem)    // By JPP - 31/01/2006 - 17:00
             M->&(aMemoItem[j][2]) := ""
         Next
      Else
         For nInc := 1 TO WorkIt->(FCount())
            M->&(WorkIt->(FIELDNAME(nInc))) := WorkIt->(FIELDGET(nInc))
         Next nInc

         //AOM - 20/05/2011
         If lOperacaoEsp
            M->EE8_DESOPE := Posicione('EJ0',1,xFilial('EJ0') + M->EE8_CODOPE ,'EJ0_DESC')
         EndIf

         aAdd(aButtons,{"SDUPROP", {|| AP106HistDet() }, STR0164/*, STR0165*/}) //"Historico de Saldo"###"Hist. Saldo"
      EndIf

      cAliasTab := "EE8"

      //LRS - 20/10/2015 - Chamada da function para abrir a tela de Opcinais
      aAdd(aButtons,{, {|| AP100OPC(cAliasTab,nTIPO) }, STR0220})//Opcionais

      If nTIPO==INC_DET
         M->EE8_SEQUEN := cSequencia
         M->EE8_PEDIDO := M->EE7_PEDIDO
         M->EE8_FORN   := M->EE7_FORN
         M->EE8_FOLOJA := M->EE7_FOLOJA

         // ** By JBJ - 27/06/2002 - 09:59
         If lConvUnid .And. !Empty(M->EE7_UNIDAD)
            M->EE8_UNPES  := M->EE7_UNIDAD
         EndIf

      EndIf

      /* JPM - Valida��es dos itens, devem estar dentro do loop. Se for consolida��o, far� o Loop
               por toda a AuxIt. Se n�o, s� far� uma vez, como � o normal */
      If lConsolItem
         AuxIt->(DbGoTop())
      EndIf

      While If(lConsolItem,AuxIt->(!EoF()),.t.)

         If lConsolItem
            WorkIt->(DbGoTo(AuxIt->EE8_RECNO))
         EndIf

         If nTipo == EXC_DET
            If !Ap100VldExc()
               Break
            EndIf
         EndIf

         If !lAltFix .And. nTipo <> INC_DET .And. !lConsolItem // JPM - 11/10/05
            If lCommodity .and. !Empty(WorkIT->EE8_DTFIX) .And. nTipo = ALT_DET
               EasyHelp(STR0122 , STR0024) //"N�o � permitida a altera��o de item com pre�o fixado."###"Aten��o"
               Break
            ElseIf WorkIt->(FieldPos("EE8_RV")) > 0
               IF !Empty(WorkIT->EE8_RV) .And. nTipo <> VIS_DET
                  EasyHelp(STR0123 , STR0024) //"N�o � permitida a altera��o de item com RV."###"Aten��o"
                  Break
               ENDIF
            EndIf
         EndIf

         If lConsolItem
            AuxIt->(DbSkip())
         Else
            Exit
         EndIf
      EndDo

      cNewTit:= STR0017+AllTrim(Transf(M->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE)))+" - "+AllTrim(AVSX3("EE8_SEQUEN",AV_TITULO))+": "+AllTrim(Transf(M->EE8_SEQUEN,AVSX3("EE8_SEQUEN",AV_PICTURE))) //"Defini��o de Produtos para o Pedido "

      // ** By JBJ - 12/06/03 set dos campos referentes a agente recebedor de comiss�o.
      If EECFlags("COMISSAO")
         If nTipo == INC_DET .And. EasyGParam("MV_AVG0088",,.t.) // JPP - 02/05/2005 15:40 - Inclus�o do parametro "MV_AVG0088" na express�o.
            EECInitCmpAg()
         EndIf
      EndIf

      /*
      Rotina para manter os dados da ultima inclus�o do item.
      Autor       : Alexsander Martins dos Santos
      Data e Hora : 26/02/2004 �s 11:58.
      Observa��o  : A rotina ser� executada com o MV_AVG0060 igual .T.
      */
      If nTipo == INC_DET .and. lReplicaItem //EasyGParam("MV_AVG0060",,.F.) //MCF - 01/02/2016
         WorkIt->(dbGoBottom())
         For nInc := 1 To WorkIt->(FCount())
            If Type("M->"+WorkIt->(FieldName(nInc))) <> "U" .and. Empty(M->&(WorkIt->(FieldName(nInc))))
//             If !(WorkIt->(FieldName(nInc)) $ "EE8_ORIGEM/EE8_ORIGV /EE8_DTFIX /EE8_PRCFIX/EE8_QTDFIX/EE8_STFIX /EE8_QTDLOT/EE8_DIFERE/EE8_DTVCRV/EE8_STA_RV/EE8_SEQ_RV/EE8_MESFIX/EE8_DTCOTA/EE8_DTRV  /EE8_RV    /EE8_FATIT ")
               If !(WorkIt->(FieldName(nInc)) $ "EE8_ORIGEM/EE8_ORIGV /EE8_DTFIX /EE8_PRCFIX/EE8_QTDFIX/EE8_STFIX /EE8_QTDLOT/EE8_DTVCRV/EE8_STA_RV/EE8_SEQ_RV/EE8_DTCOTA/EE8_DTRV  /EE8_RV    /EE8_FATIT ")
                  M->&(WorkIt->(FieldName(nInc))) := WorkIt->(FieldGet(nInc))
               EndIf
            EndIf
         Next
         //ER - 29/08/2006 - N�o carrega o Item do faturmanto, para gravar um novo na confirma��o do Pedido.
         If lIntegra .and. EE8->(FieldPos("EE8_FATIT")) <> 0
            M->EE8_FATIT := ""
         EndIf
      EndIf
      //Fim da rotina.

      //** AAF - 09/09/04 - Adiciona campos do Back to back
      IF lBACKTO
         AP106ItemEnc(OC_PE)
      EndIF
      //**

      /*
      ER - 15/08/05 - 14:00
      Valida�ao para altera�ao do codigo do Item caso exista um Embarque usando essa sequencia.
      */

      aBkp := {aClone(aEE8CamposEditaveis),aClone(aItemEnchoice)}

      IF nTipo == ALT_DET .and. WorkIT->EE8_SLDINI <> WorkIT->EE8_SLDATU

         nCodI := aScan(aEE8CamposEditaveis,"EE8_COD_I")
         IF nCodI > 0
            aDel(aEE8CamposEditaveis,nCodI)
            aSize(aEE8CamposEditaveis,Len(aEE8CamposEditaveis)-1)
         EndIf
      EndIf

      If AVFLAGS("EEC_LOGIX") .AND. nTipo == ALT_DET .And. !lEE7Auto  // GFP - 15/10/2014  //NCF - 17/10/2014 - Teste ExecAuto
         IF (nPos := AScan(aEE8CamposEditaveis,"EE8_COD_I")) > 0
            aDel(aEE8CamposEditaveis,nPos)
            aSize(aEE8CamposEditaveis,Len(aEE8CamposEditaveis)-1)
         EndIf
         IF (nPos := AScan(aEE8CamposEditaveis,"EE8_SLDINI")) > 0
            aDel(aEE8CamposEditaveis,nPos)
            aSize(aEE8CamposEditaveis,Len(aEE8CamposEditaveis)-1)
         EndIf
      EndIf

      // JPM - 11/10/05 - Controle de qtds fil Br. Ex.
      If lConsolItem
         Ap104TrtCampos(2) //Tratamentos para campos edit�veis, n�o usados, etc.
      EndIf

      If !lAlteraStatus .And. (cStatus == ST_CL .Or. cStatus == ST_PA)
         aBufferIt := Array(Len(aFieldItens))
         For i:=1 to Len(aFieldItens)
            IF (lConsolItem .And. AScan(aCposDif,aFieldItens[i]) > 0) .Or. Type("M->"+aFieldItens[i]) = "U"
               Loop
            Endif
            aBufferIt[i] := Eval(MemVarBlock(aFieldItens[i]))
         Next i

         If lConsolItem // JPM
            aBufferItIt := Array(AuxIt->(EasyRecCount("AuxIt")))
            AuxIt->(DbGoTop())
            j := 0
            While AuxIt->(!EoF())
               j++
               aBufferItIt[j] := Array(Len(aFieldItens))
               For i:=1 to Len(aFieldItens)
                  IF AScan(aCposDif,aFieldItens[i]) > 0
                     Loop
                  Endif
                  aBufferItIt[j][i] := AuxIt->&(aFieldItens[i])
               Next i

               AuxIt->(DbSkip())
            EndDo
            AuxIt->(DbGoTop())
         EndIf
      Endif

      If EasyEntryPoint("EECAP100")
         ExecBlock("EECAP100", .F., .F., "DETMAN_ANTES_DIALOG")
      EndIf

      //DFS - 08/11/10 - Inclusao do terceiro par�metro
      If IsFaturado(M->EE8_PEDIDO,M->EE8_SEQUEN, .T.)
         AP100BLOQCPOS()
      Endif

      If !lEE8Auto
         DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

            aPos := PosDlg(oDlg)
            aPos[3] -= 28 // Rodape
            oMsMGet := MsMGet():New( "EE8", , IF(nTipo=INC_DET,3,If(nTipo=ALT_DET, 4, 2)), , , ,aItemEnchoice, aPos,If(Len(aEE8CamposEditaveis) <> 0, aEE8CamposEditaveis,),,,,,,,.T.)

            If lConsolItem
               aObjs := Ap104TelaIt(oMsMGet)
            EndIf

            oMsMGet:oBox:Align := CONTROL_ALIGN_TOP

            // GFP - 27/05/2013 - Ajuste para exibi��o no modo classico
            aPos2 := PosDlg(oDlg)//PosDlgDown(oDlg)  // GFP - 12/07/2012
            oPanel1:=	TPanel():New(aPos2[1],aPos2[2], "", oDlg,, .T., ,,,0,0,,.T.)
            oPanel1:Align:= CONTROL_ALIGN_ALLCLIENT

            aPos2[1] := aPos[3] + 1
            aPos2[3] := aPos[1]+28

            oPanel2:=	TPanel():New(aPos2[1],aPos2[2], "", oPanel1,, .F., .F.,,, aPos2[4], 40)
            oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT

            aPos2[1] := aPos2[3] + 1
            aPos2[3] := aPos2[1]+28

            AP100DetTela(.T.,aPos,nTipo,oPanel2)

            oDlg:lMaximized := .T.

         ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bDetOk,bCancel,,aButtons)
      Else
         //NCF - 31/03/2014 - Posicionamento para gatilhar corretamente as unidades de medidas de quantidade dos itens
         lItemDel := (nPosCmdDel := aScan(aAutoItem,{|x| x[1] == "AUTDELETA"})) > 0 .And. aAutoItem[nPosCmdDel][2] == "S"
         If !lItemDel
            aOrdSB1Auto := SaveOrd("SB1")
            SB1->(DbSetOrder(1))
            SB1->(DBSEEK( xFilial("SB1") + AvKey( aAutoItem[nPosCod_It := aScan(aAutoItem,{|x| x[1] == "EE8_COD_I"})][2], "B1_COD" )))
         EndIf 

         TEClearChv("EE8",aAutoItem) //Ap100ConsFor(aAutoItem) //NCF - 29/03/2019

         If EnchAuto("EE8", aAutoItem, {|| Obrigatorio(aGets,aTela)}, IF(nTipo=4,3,4), aItemEnchoice)
            Eval(bDetOk)
            If nOpcA == 1
               lRet := .T.
            EndIf
         Else
            //NCF - 06/03/2017 - Informa��es do Item para rastreamento no log de erro.
            nPosInfIt := 0
            cMsgLogIt := "[Pedido.....: "+ Alltrim(If( (nPosInfIt := aScan(aAutoItem,{|x| x[1] == "EE8_PEDIDO"})) > 0 ,aAutoItem[nPosInfIt][2],""))+"]" + ENTER
            cMsgLogIt += "[Sequencia..: "+ Alltrim(If( (nPosInfIt := aScan(aAutoItem,{|x| x[1] == "EE8_SEQUEN"})) > 0 ,aAutoItem[nPosInfIt][2],""))+"]" + ENTER
            cMsgLogIt += "[Cod.Item...: "+ Alltrim(If( (nPosInfIt := aScan(aAutoItem,{|x| x[1] == "EE8_COD_I" })) > 0 ,aAutoItem[nPosInfIt][2],""))+"]" + ENTER
            cMsgLogIt += "[Ref.Cliente: "+ Alltrim(If( (nPosInfIt := aScan(aAutoItem,{|x| x[1] == "EE8_REFCLI"})) > 0 ,aAutoItem[nPosInfIt][2],""))+"]" + ENTER
            AutoGrLog(cMsgLogIt)

            Eval(bCancel)
         EndIf
         If !lItemDel
            RestOrd(aOrdSB1Auto)
         EndIf
      EndIf

      aEE8CamposEditaveis := aClone(aBkp[1])
      aItemEnchoice := aClone(aBkp[2])

   Else // ** Faz a inclus�o sem tela de edi��o ...
      nRecNo := IF(nTipo==INC_DET,0,WorkIt->(RecNo()))

      SX3->(dbSetOrder(2))
      For nInc := 1 TO WorkIt->(FCount())
         If Type("M->"+WorkIt->(FIELDNAME(nInc))) = "U"
            IF SX3->(dbSeek(WorkIt->(FIELDNAME(nInc))))
               M->&(WorkIt->(FIELDNAME(nInc))):= CriaVar(WorkIt->(FIELDNAME(nInc)))
            Endif
         EndIf
      Next

      If nTipo==INC_DET
         WorkIt->(DBGOBOTTOM())
         cSEQUENCIA := STR(VAL(WorkIt->EE8_SEQUEN)+1,TAMSX3("EE8_SEQUEN")[1])
         WorkIt->(DBSKIP())
      EndIf

      // ** By JBJ - 10/06/2002 - 15:03
      //cDesc := M->EE8_DESC
      //cVmDes := M->EE8_VM_DES

      For i:=1 To Len(aMemoItem)
         If EE8->(FieldPos(aMemoItem[i][1])) > 0
            aAdd(aCodDesc,M->&(aMemoItem[i][1]))
            aAdd(aVmDesc,M->&(aMemoItem[i][2]))
         EndIf
      Next i

      // ** By JBJ - 10/06/2002 - 15:04
      //M->EE8_VM_DES  := cVmDes
      For i:=1 To Len(aMemoItem)
         If EE8->(FieldPos(aMemoItem[i][1])) > 0
            M->&(aMemoItem[i][2]):=aVmDesc[i]
         EndIf
      Next i

      M->EE8_DESC :="."

      // ** Executa todas as valida��es ...
      If(AP100VALDET(nTipo,nRecNo),nOpca:=1,"")

      // ** By JBJ - 10/06/2002 - 15:04
      //M->EE8_DESC := cDesc
      For i:=1 To Len(aMemoItem)
        If EE8->(FieldPos(aMemoItem[i][1])) > 0
           M->&(aMemoItem[i][1]):=aCodDesc[i]
        EndIf
      Next i

      M->EE8_SEQUEN := cSequencia

   EndIf

   IF nOpcA == 1 .And. !lDelTudo// Ok

      If lConsolItem
         //Ap104AuxIt(7)
         AuxIt->(DbGoTop())
      EndIf

      IF ! Str(nTipo,1) $ Str(VIS_DET,1)+Str(EXC_DET,1)
         IF ! lAlteraStatus .And. (cStatus == ST_CL .Or. cStatus == ST_PA)
            For i:=1 To Len(aFieldItens)
               IF (lConsolItem .And. AScan(aCposDif,aFieldItens[i]) > 0) .Or. Type("M->"+aFieldItens[i]) = "U"
                  Loop
               Endif

               IF aBufferIt[i] != Eval(MemVarBlock(aFieldItens[i]))
                  lAlteraStatus := .T.
                  Exit
               Endif
            Next i

            If lConsolItem // JPM
               AuxIt->(DbGoTop())
               j := 0
               While AuxIt->(!EoF())
                  j++
                  aBufferItIt[j] := Array(Len(aFieldItens))
                  For i:=1 to Len(aFieldItens)
                     IF AScan(aCposDif,aFieldItens[i]) > 0
                        Loop
                     Endif
                     IF aBufferItIt[j][i] != AuxIt->&(aFieldItens[i])
                        lAlteraStatus := .T.
                        Exit
                     Endif
                  Next i
                  AuxIt->(DbSkip())
               EndDo
               AuxIt->(DbGoTop())
            EndIf

         Endif
      EndIf
      
      If Type("lDescIt") == "U"
         lDescIt:= .T.
      EndIf

      While If(lConsolItem, AuxIt->(!Eof()), .t.)
         If lConsolItem
            If AuxIt->DBDELETE
               AuxIt->(DbSkip())
               Loop
            EndIf
            Ap104AuxIt(3,,.t.) // Simula vari�veis de mem�ria
         EndIf

         IF nTipo == INC_DET
            WorkIt->(DBAPPEND())

            // ** By JBJ - 14/06/2002 - 08:45
            If lConvUnid
               M->EE7_PESLIQ += AvTransUnid(M->EE8_UNPES,If(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),M->EE8_COD_I,M->EE8_PSLQTO,.F.)
               M->EE7_PESBRU += AvTransUnid(M->EE8_UNPES,If(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),M->EE8_COD_I,M->EE8_PSBRTO,.F.)
            Else
               M->EE7_PESLIQ += M->EE8_PSLQTO
               M->EE7_PESBRU += M->EE8_PSBRTO
            EndIf

            M->EE7_TOTITE++
            IF cStatus == ST_CL .Or. cStatus == ST_PA
               lAlteraStatus := .T.
            Endif

            /*
            Grava��o do saldo na Work e na vari�vel de mem�ria.
            Autor: Alexsander Martins dos Santos
            Data e Hora: 05/08/2004 �s 17:25.
            */
            WorkIT->EE8_SLDATU := M->EE8_SLDATU := M->EE8_SLDINI

         Elseif nTipo == ALT_DET

            //** By JBJ - 14/06/2002 - 08:46
            If lConvUnid
               M->EE7_PESLIQ -= AvTransUnid(WorkIt->EE8_UNPES,If(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),WorkIt->EE8_COD_I,WorkIt->EE8_PSLQTO,.F.)
               M->EE7_PESBRU -= AvTransUnid(WorkIt->EE8_UNPES,If(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),WorkIt->EE8_COD_I,WorkIt->EE8_PSBRTO,.F.)
               M->EE7_PESLIQ += AvTransUnid(M->EE8_UNPES,If(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),M->EE8_COD_I,M->EE8_PSLQTO,.F.)
               M->EE7_PESBRU += AvTransUnid(M->EE8_UNPES,If(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),M->EE8_COD_I,M->EE8_PSBRTO,.F.)
            Else
               M->EE7_PESLIQ -= WorkIt->EE8_PSLQTO
               M->EE7_PESBRU -= WorkIt->EE8_PSBRTO
               M->EE7_PESLIQ += M->EE8_PSLQTO
               M->EE7_PESBRU += M->EE8_PSBRTO
            EndIf
         EndIf

         IF ! Str(nTipo,1) $ Str(VIS_DET,1)+Str(EXC_DET,1)
            IF ! lAlteraStatus .And. (cStatus == ST_CL .or. cStatus == ST_PA)
               For i:=1 To Len(aFieldItens)
                   IF Type("M->"+aFieldItens[i]) = "U"
                      Loop
                   Endif

                   IF aBufferIt[i] != Eval(MemVarBlock(aFieldItens[i]))
                      lAlteraStatus := .T.
                      Exit
                   Endif
               Next i
            Endif

            /*
            Substituido a grava��o do EE8_SLDATU, para permitir a atualiza��o do saldo, pela fun��o AP104SLDEMB.
            Autor: Alexsander Martins dos Santos
            Data e Hora: 05/08/2004 �s 17:17.

            M->EE8_SLDATU := M->EE8_SLDINI
            */

            If nSelecao = INCLUIR
               WorkIT->EE8_SLDATU := M->EE8_SLDATU := M->EE8_SLDINI
            EndIf

            EECPPE07("PESOS",.t.)

            /*     //MFR 26/09/2019 OSSME-3309
            If EasyGParam("MV_AVG0119",,.F.) .and. EE8->(FieldPos("EE8_DESCON")) > 0 //Desconto no Item
                //THTS - 18/01/2019 - Quando informado desconto no item, calcula o valor a ser aplicado para que seja possivel a integracao com o faturamento
                nDecDesc:= AvSx3("D2_DESCON",AV_DECIMAL)
                nDecPrc := AvSx3("D2_PRCVEN",AV_DECIMAL)
                nNewDesc:= Round(Round(M->EE8_DESCON/AvTransUnid(M->EE8_UNIDAD, M->EE8_UNPRC, M->EE8_COD_I,M->EE8_SLDINI,.F.),nDecPrc)*AvTransUnid(M->EE8_UNIDAD, M->EE8_UNPRC, M->EE8_COD_I,M->EE8_SLDINI,.F.),nDecDesc)
                If nNewDesc <> M->EE8_DESCON
                    MSGINFO(STR0241 + Transform(M->EE8_DESCON,AvSx3("EE8_DESCON",AV_PICTURE))+ENTER+;  //"O valor de desconto informado: "
                    STR0242 + Transform(nNewDesc,AvSx3("EE8_DESCON",AV_PICTURE))+ENTER+;  //"Foi alterado para o valor: "
                    STR0243)  //"Devido a compatibiliza��o dos valores na integra��o com o Faturamento."
                    M->EE8_DESCON := nNewDesc
                EndIf
            EndIf
            */

            M->EE8_RECNO := Nil
            AVReplace("M","WorkIt")

           //LRS - 20/10/2015 - Por  motivo de problema de framework, sempre mandar o cCampoBKP para Work.
		    If EE8->(FieldPos("EE8_OPC")) > 0 .And. EE8->(FieldPos("EE8_MOP")) > 0 //LGS-03/12/2015
		       If lOpcPadrao
		          If !Empty(WorkIt->EE8_OPC) .And. !Empty(cCampoBKP)
		             WorkIT->EE8_OPC:= cCampoBKP
		          EndIF
		       Else
		          If !Empty(WorkIt->EE8_MOP) .And. !Empty(cCampoBKP)
		             WorkIT->EE8_MOP:= cCampoBKP
		          EndIF
		       EndIF
		    EndIf
            // ** By JBJ - 10/06/2002 - 13:53 ...
            //WorkIt->EE8_VM_DES := M->EE8_VM_DES

              For i:=1 To Len(aMemoItem)
                 If WorkIt->(FieldPos(aMemoItem[i][2])) > 0
                    WorkIt->&(aMemoItem[i][2]) := M->&(aMemoItem[i][2])
                 EndIf
              Next i


            // by CAF 29/02/2000 14:52 WorkIt->EE8_PRCTOT := AP100PrcTot(M->EE8_PRECO,M->EE8_SLDINI)

            // FJH - 03/02/06 - Calcula desconto da capa de acordo com o digitado nos itens
            If EasyGParam("MV_AVG0119",,.F.) .and. EE8->(FieldPos("EE8_DESCON")) > 0 .And. lDescIt
               EECCALCDESC("P")
            Endif

            //Formar preco incoterm
            AP100PrecoI()


            // ** By JBJ - 12/06/2003 - 13:48 - Atualizar o total de comiss�o do agente.
            If EECFlags("COMISSAO")
               EECTotCom()
            EndIf

         // ** Atualiza o valor das invoices de compra para os tratamentos de back to back.
            If lBackTo
               AP106VlInv(OC_PE)
            Endif

            If !lEE8Auto
               AP100TTELA(.F.)
            EndIf
         EndIf

         If !lEE8Auto
            oMsSelect:oBrowse:Refresh()
         EndIf

//         oMsSelect:oBrowse:Refresh()

         If lConsolItem
            Ap104AuxIt(4,.t.,.t.) //Restaura backup de vari�veis de mem�ria.
            AuxIt->(DbSkip())
         Else
            Exit
         EndIf
      EndDo

      /*
      Nopado por ER em 10/03/2008. A grava��o da WorkGrp ser� realizada tamb�m na altera��o do item.
      If nTipo == INC_DET .And. lConsolida // Ao incluir um item, inclui um novo registro de grupo na base
         WorkGrp->(DbAppend())
         For i := 1 To Len(aGrpCpos)
            WorkGrp->&(aGrpCpos[i]) := WorkIt->&(aGrpCpos[i])
         Next
         WorkGrp->EE8_ORIGEM := WorkIt->EE8_SEQUEN
         WorkGrp->TRB_ALI_WT := "EE8"
         WorkGrp->TRB_REC_WT := EE8->(Recno())
      EndIf
      */
      //ER - 10/03/2008. Grava��o da WorkGrp.
      If lConsolida
         If nTipo == INC_DET
            WorkGrp->(DbAppend())
            For i := 1 To Len(aGrpCpos)
               WorkGrp->&(aGrpCpos[i]) := WorkIt->&(aGrpCpos[i])
            Next
            WorkGrp->EE8_ORIGEM := WorkIt->EE8_SEQUEN
            WorkGrp->TRB_ALI_WT := "EE8"
            WorkGrp->TRB_REC_WT := EE8->(Recno())

         ElseIf nTipo == ALT_DET
            For i := 1 To Len(aGrpCpos)
               WorkGrp->&(aGrpCpos[i]) := WorkIt->&(aGrpCpos[i])
            Next
            WorkGrp->EE8_ORIGEM := WorkIt->EE8_SEQUEN
            WorkGrp->TRB_ALI_WT := "EE8"
            WorkGrp->TRB_REC_WT := EE8->(Recno())

         EndIf
      EndIf

      If lConsolItem

         // Trata itens deletados
         AuxIt->(DbGoTop())
         While AuxIt->(!Eof())
            If AuxIt->DBDELETE
               lConsolItem := .f.
               AP100ValDet(EXC_DET,AuxIt->EE8_RECNO,.t.)
               lConsolItem := .t.
            EndIf
            AuxIt->(DbSkip())
         EndDo

         Ap104AuxIt(7,.t.) // totaliza vari�veis de mem�ria.

         // Atualiza WorkGrp
         For i := 1 To Len(aGrpCpos)
            If aGrpCpos[i] = "EE8_ORIGEM"
               // � sempre o mesmo.
            ElseIf aGrpInfo[i] = "N" // se for um campo que n�o � sempre igual.. (Ex. Pre�o)
               AAdd(aGrpVerify,{aGrpCpos[i],Nil}) //Vai verificar um por um
            Else
               WorkGrp->&(aGrpCpos[i]) := M->&(aGrpCpos[i])  // quando � campo de totalizar, a mem�ria j� est� totalizada
            EndIf
         Next

         // tratamentos para campos que n�o s�o sempre iguais
         AuxIt->(DbGoTop())
         While AuxIt->(!Eof())
            If AuxIt->DBDELETE
               AuxIt->(DbSkip())
               Loop
            EndIf
            For i := 1 To Len(aGrpVerify)
               If i = 1
                  aGrpVerify[i][2] := AuxIt->&(aGrpVerify[i][1])
               Else
                  If aGrpVerify[i][2] <> AuxIt->&(aGrpVerify[i][1])
                     aGrpVerify[i][2] := CriaVar(aGrpVerify[i][1])
                  EndIf
               EndIf
            Next
            AuxIt->(DbSkip())
         EndDo

         // atualiza os campos.
         For i := 1 To Len(aGrpVerify)
            WorkGrp->&(aGrpVerify[i][1]) := aGrpVerify[i][2]
         Next

      EndIf

   Elseif nOpcA == 0 // Cancel
       lRet := .F.
       IF nTipo == INC_DET
          WorkEm->(dbSeek(M->EE7_PEDIDO+M->EE8_SEQUEN))
          While !WorkEm->(Eof()) .And. WorkEm->(EEK_PEDIDO+EEK_SEQUEN)==;
                                            M->EE7_PEDIDO+M->EE8_SEQUEN
              WorkEm->(dbDelete())
              WorkEm->(dbSkip())
          Enddo
          WorkIt->(dbGoTo(nRecOld))
       Endif

   EndIf

   //ER - 20/12/05 �s 19:20
   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.F.,.F.,{ "PE_GRVDET",nTipo})
   Endif
End Sequence

If Select("AuxIt") > 0
   AuxIt->(E_EraseArq(cAuxIt))
EndIf

If AllTrim(cOldArea) <> "SX3"
   dbSelectArea(cOldArea)
EndIf

If !lEE8Auto
   oMsSelect:oBrowse:Refresh()
EndIf

Return lRet

/*
Funcao      : AP100VALDET(nTipo,nRecno,lForcado)
Parametros  : nTipo := idem nTipo AT135SYR_MAN
              nRecno:= n.registro
              lForcado := exclus�o pela rotina de consolida��o de itens
Retorno     : .T. / .F.
Objetivos   : validar/aceitar exclusao
Autor       : Heder M Oliveira
Data/Hora   : 25/11/98 11:51
Revisao     : WFS 24/02/2010
              Inclus�o dos tratamentos de dele��o de itens para quando
              o recurso Grade est� habilitado.
Obs.        :
*/
Static Function AP100VALDET(nTipo,nRecno,lForcado)
   Local lRet:=.T.,cOldArea:=select(),cTmpPreco, cOldCodAg, aOrdAux:={}
   Local nDiferenca:=0, nVlToAtu:=0, nSldAtu := 0, nPos, nLinha, nColuna, nLinAcols
   Local cVal := "", cCpoCont, cProdGrd
   Local lAllDeleted := .t. // define se todos os itens foram deletados

   Default lForcado := .f.

   Begin Sequence
      If nTipo == INC_DET .OR. nTipo = ALT_DET

         //19.mai.2009 - UE719925 - Tratamento para data de prev. de embarque e entrega - HFD
         If M->EE8_DTENTR < M->EE8_DTPREM
            EasyHelp(STR0182,STR0036)
            lRet:=.f.
            Break
         EndIf
         If lConsolItem
            Ap104AuxIt(7)
            AuxIt->(DbGoTop())
         Else
            lAllDeleted := .f.
         EndIf

         While If(lConsolItem, AuxIt->(!EoF()), .t.)
            If lConsolItem
               If AuxIt->DBDELETE
                  AuxIt->(DbSkip())
                  Loop
               EndIf
               Ap104AuxIt(3,,.t.) // Simula vari�veis de mem�ria
               cVal := " - " + AllTrim(AvSx3("EE8_SEQUEN",AV_TITULO)) + " " + AllTrim(AuxIt->EE8_SEQUEN)
               If lAllDeleted .And. !(AuxIt->DBDELETE)
                  lAllDeleted := .f.
               EndIf
            Else
               cVal := ""
            EndIf
            // JPM - 03/08/05 - valida��o da Carta de Cr�dito
            If EECFlags("ITENS_LC")
               If !Ae107VldProd(OC_PE)
                  lRet := .f.
                  Break
               EndIf
            EndIf

            /* Neste ponto o sistema ir� realizar valida��es para criticar as altera��es na
               quantidade do item. */

            If nTipo == ALT_DET .And. lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EE7_INTERM $ cSim
               If !Ax101VldQtde(OC_PE)
                  lRet:=.f.
                  Break
               EndIf
            EndIf

            If EECFlags("COMISSAO")

               // JPM - 31/05/05 - Campo novo: tipo de comiss�o no item
                If EE8->(FieldPos("EE8_TIPCOM")) > 0 .And. !Empty(M->EE8_CODAGE) .And. Empty(M->EE8_TIPCOM)
                    EasyHelp(STR0133 + "'" + AllTrim(AvSx3("EE8_TIPCOM",AV_TITULO)) + "'",STR0036)//"Preencha o campo " ## "Aviso"
                    lRet := .f.
                    Break
                EndIf

               // ** Para o tipo 'Percentual por Item' o percentual de comissao deve ser informado.
               /* AAF 09/01/2014 - Permitir itens sem comiss�o.
			   If !Empty(M->EE8_CODAGE) .And. M->EE8_PERCOM = 0
                  //If WorkAg->(DbSeek(M->EE8_CODAGE+CD_AGC)) - JPM - 31/05/05
                  If WorkAg->(DbSeek(M->EE8_CODAGE+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+;
                                      If(EE8->(FieldPos("EE8_TIPCOM")) > 0,M->EE8_TIPCOM,"")))
                     //If WorkAg->EEB_TIPCVL $ "1/3" // Percentual/Percentual por Item.
                     If WorkAg->EEB_TIPCVL = "3"
                        If !lEE7Auto// Percentual por Item.
                           MsgInfo(STR0118,STR0036) //"O percentual de comiss�o deve ser informado!"###"Aviso"
                        Else
                           EasyHelp(STR0118)
                        EndIf
                        lRet := .f.
                        Break
                     EndIf
                  EndIf
               EndIf
               */
            EndIf


            // ** By JBJ - 25/06/2002 - 17:08
            If lCommodity
               AP100GrvStFix()
            EndIf

            IF SB1->(FieldPos("B1_REPOSIC")) > 0
               IF Posicione("SB1",1,xFILIAL("SB1")+M->EE8_COD_I,"B1_REPOSIC") $cSim
                  lAltQtd := !EMPTY(M->EE8_SLDINI)
                  lAltFor := !EMPTY(M->EE8_FORN)
                  lAltLoj := !EMPTY(M->EE8_FOLOJA)
                  lAltEmb := !EMPTY(M->EE8_EMBAL1)
                  lAltQE  := !EMPTY(M->EE8_QE)
                  lAltQem := !EMPTY(M->EE8_QTDEM1)
                  lAltNcm := !EMPTY(M->EE8_POSIPI)
                  HELP(" ",1,"AVG0000629") //MSGINFO("Este � um produto para reposi��o, os valores ser�o zerados","Aviso")
                  M->EE8_SLDINI := IF(laltQtd,M->EE8_SLDINI,1)
                  M->EE8_FORN   := IF(laltFor,M->EE8_FORN,".")
                  M->EE8_FOLOJA := IF(laltLoj,M->EE8_FOLOJA,".")
                  M->EE8_EMBAL1 := IF(laltEmb,M->EE8_EMBAL1,".")
                  M->EE8_QE     := IF(laltQE,M->EE8_QE,1)
                  M->EE8_QTDEM1 := IF(laltQem,M->EE8_QTDEM1,1)
                  M->EE8_POSIPI := IF(laltNcm,M->EE8_POSIPI,".")
                  M->EE8_PSLQUN := 1
                  M->EE8_PSBRUN := 1
                  M->EE8_PRECO  := 1
                  M->EE8_PRECOI := 1
                  M->EE8_PRCTOT := 1
                  M->EE8_PRCINC := 1
               ENDIF
            ENDIF

            If lCommodity
               cTmpPreco:=M->EE8_PRECO

               M->EE8_PRECO:=1

               lRet:=Obrigatorio(aGets,aTela)

               M->EE8_PRECO:=cTmpPreco
            Else
               lRet:=Obrigatorio(aGets,aTela)
            EndIf

            If !lRet
               Break
            EndIf

            IF SB1->(FieldPos("B1_REPOSIC")) > 0
               IF Posicione("SB1",1,xFILIAL("SB1")+M->EE8_COD_I,"B1_REPOSIC") $cSim
                  M->EE8_SLDINI := IF(laltQtd,M->EE8_SLDINI,0)
                  M->EE8_FORN   := IF(laltFor,M->EE8_FORN,"")
                  M->EE8_FOLOJA := IF(laltLoj,M->EE8_FOLOJA,"")
                  M->EE8_EMBAL1 := IF(laltEmb,M->EE8_EMBAL1,"")
                  M->EE8_QE     := IF(laltQE,M->EE8_QE,0)
                  M->EE8_QTDEM1 := IF(laltQem,M->EE8_QTDEM1,0)
                  M->EE8_POSIPI := IF(laltNcm,M->EE8_POSIPI,"")
                  M->EE8_PSLQUN := 0
                  M->EE8_PSBRUN := 0
                  M->EE8_PRECO  := 0
                  M->EE8_PRECOI := 0
                  M->EE8_PRCTOT := 0
                  M->EE8_PRCINC := 0
               ENDIF
            ENDIF

            /* by jbj - 28/06/04 11:12 - Para processos com tratamento de off-shore e ambientes com a rotina
                                         de Commodity desabilitada, o pre�o negociado a obrigat�rio. */
            If lIntermed .And. !lCommodity
               If (M->EE7_INTERM $ cSim) .And. Empty(M->EE8_PRENEG)
                  MsgStop(STR0121,STR0024) //"Para processos com tratamentos de off-shore o pre�o negociado � obrigat�rio para todos os produtos."###"Aten��o"
                  lRet:=.f.
                  Break
               EndIf
            EndIf

            /* by jbj - 19/05/05 - Neste ponto o sistema ir� realizar tratamentos para os casos em que a quantidade
                                   do item (pedido) for alterada, atendendo as seguintes regras:
                                   1) Para os casos de aumento na quantidade:
                                      a) O sistema sempre ir� aumentar somente o saldo do item no pedido, ou seja,
                                         nesta situa��o o usu�rio n�o ter� op��o de atualizar as quantidades do(s)
                                         embarque(s) onde o item foi utilizado.
                                   2) Para os casos de diminui��o na quantidade:
                                      a) Caso a diferen�a a ser abatida seja menor ou igual ao saldo da linha, o
                                         sistema ir� abater diretamente no saldo, n�o exibindo a tela de sele��o
                                         de embarques.
                                      b) Caso a diferen�a a ser abatida seja maior que o saldo, o sistema ir�  abater
                                         o saldo, e o restante ir� solicitar que o usu�rio selecione um embarque para
                                         abatimento da quantidade restante. */

            If nTipo == ALT_DET .And. M->EE8_SLDINI <> WorkIt->EE8_SLDINI .And.  !lConsolItem // JPM/JPP - na consolida��o, o saldo � atualizado sempre na hora da edi��o do browse.
               // Verifica se o item sofreu altera��o na quantidade.
               nDiferenca := (M->EE8_SLDINI - WorkIt->EE8_SLDINI)

               If nDiferenca > 0
                  M->EE8_SLDATU += nDiferenca
               Else
                  nSldAtu := M->EE8_SLDATU

                  If nSldAtu + nDiferenca < 0
                     nVlToAtu := nDiferenca + nSldAtu

                     If nVlToAtu < 0
                        If AP104ItemEmb(M->EE8_PEDIDO, M->EE8_SEQUEN) > 0

                           ///////////////////////////////////////////////////////////////////////////////////////
                           //Para a nova integra��o entre SigaEEC e SigaFAT a atualiza��o de embarque autom�tica//
                           //n�o ser� realizada.                                                                //
                           ////////////////////////////////////////////////////////////////////,///////////////////
                           If !lIntEmb
                              If !AP104SldEmb(nVlToAtu,M->EE8_PEDIDO, M->EE8_SEQUEN)
                                 lRet := .f.
                                 Break
                              EndIf
                              M->EE8_SLDATU := 0
                           Else
                              MsgStop(STR0130, STR0024) //"Qtde informada inv�lida, pois o saldo alocado em embarque � maior."###"Aten��o"
                              lRet := .f.
                              Break
                           EndIf
                        Else
                           MsgStop(STR0130, STR0024) //"Qtde informada inv�lida, pois o saldo alocado em embarque � maior."###"Aten��o"
                           lRet := .f.
                           Break
                        EndIf
                     Else
                        M->EE8_SLDATU += nDiferenca
                     EndIf
                  Else
                     M->EE8_SLDATU += nDiferenca
                  EndIf
               EndIf
            EndIf

            /*
            Rotina para valida��o da qtde. do item, verificando se o mesmo est� embarcado.
            Autor: Alexsander Martins dos Santos.
            Date e Hora: 03/08/2004 �s 15:15.
            */
            /*
            If nTipo = ALT_DET
               If AP104ItemEmb(M->EE8_PEDIDO, M->EE8_SEQUEN) > 0 // Verifica se o item foi utilizado em algum embarque.

                  // ** Verifica se o item sofreu altera��o na quantidade.
                  If M->EE8_SLDINI <> WorkIT->EE8_SLDINI

                     // ** Exibe tela para sele��o de embarque a ser realizada pelo usu�rio.
                     If !AP104SLDEMB(WorkIT->EE8_SLDINI, M->EE8_SLDINI, M->EE8_PEDIDO, M->EE8_SEQUEN)
                        lRet := .f.
                        Break
                     EndIf
                  EndIf
               Else
                  If M->EE8_SLDATU+(M->EE8_SLDINI-WorkIt->EE8_SLDINI) >= 0
                     M->EE8_SLDATU += (M->EE8_SLDINI - WorkIt->EE8_SLDINI)
                  Else
                     MsgStop(STR0130, STR0024) //"Qtde informada inv�lida, pois o saldo alocado em embarque � maior."###"Aten��o"
                     lRet := .f.
                     Break
                  EndIf
               EndIf
            EndIf
            */

            /* Neste ponto o sistema ir� carregar o array aItAlterados, para controle de altera��o do pre�o negociado
               nas linhas. */

            If lReplicaDados
               nPos := aScan(aItAlterados,{|x| x[1] == M->EE8_SEQUEN})

               If nPos > 0
                  If M->EE8_PRENEG <> aItAlterados[nPos][2]
                     aItAlterados[nPos][2] := M->EE8_PRENEG
                  EndIf
               Else
                  aOrdAux := SaveOrd({"EE8"})
                  EE8->(DbSetOrder(1))
                  If EE8->(DbSeek(xFilial("EE8")+M->EE8_PEDIDO+M->EE8_SEQUEN))
                     If EE8->EE8_PRENEG <> M->EE8_PRENEG
                        aAdd(aItAlterados,{M->EE8_SEQUEN,M->EE8_PRENEG})
                     EndIf
                  EndIf
                  RestOrd(aOrdAux,.t.)
               EndIf
            EndIf

            // LCS - 27/09/2002 - INCLUI A CHAMADA DO PONTO DE ENTRADA
            If (EasyEntryPoint("EECPPE08"))
               // By JBJ - 06/04/04 - Tratamento para retorno do ponto de entrada.
               lRet := ExecBlock("EECPPE08",.F.,.F.)
               If ValType(lRet) <> "L"
                  lRet := .t.
               Elseif ! lRet
                  Break
               Endif
            EndIf

            //** AAF - 09/09/04 - Valida��o para Back To Back
            if lBACKTO
               lRet := AP106Valid("PE_DET_OK")
            endif

            If lConsolItem
               Ap104AuxIt(4,.t.,.t.) //Restaura backup de vari�veis de mem�ria.
               AuxIt->(DbSkip()) //situa��o de consolida��o de itens: valida para cada registro da AuxIt
            Else
               Exit // situa��o normal: valida apenas uma vez
            EndIf
         EndDo

         If lAllDeleted // se todos os itens da work AuxIt foram deletados, ent�o exclui o item por inteiro.
            nTipo := EXC_DET
            If !(lRet := AP100ValDet(nTipo,nRecno))
               Break
            EndIf
         EndIf

         If lIntegra 
            If Empty(M->EE8_TES) .And. Empty(M->EE8_CF) .And. EE8->(FIELDPOS("EE8_OPER")) > 0 .And. Empty(M->EE8_OPER)
               EasyHelp(STR0253) //"Necess�rio Informar TES e Codigo de Opera��o Fiscal ou Tipo de Opera��o(TES Inteligente)"
               lRet := .F.
            ElseIf (EE8->(FIELDPOS("EE8_OPER")) > 0 .And. !Empty(M->EE8_OPER) .And. (!Empty(M->EE8_TES) .Or. !Empty(M->EE8_CF)))
               EasyHelp(STR0254) //"Ao informar o Tipo de Opera��o(TES Inteligente), n�o ser� necess�rio informar TES e Codigo de Opera��o Fiscal"
               lRet := .F.            
            ElseIf (EE8->(FIELDPOS("EE8_OPER")) > 0 .And. Empty(M->EE8_OPER) .And. (Empty(M->EE8_TES) .And. !Empty(M->EE8_CF)))
               EasyHelp(STR0256) //"Ao Informar o C�digo de Opera��o Fiscal, tamb�m ser� necess�rio informar a TES"   
               lRet := .F.
            EndIf
            If !lRet
               Break
            EndIf            
         EndIf
         
      ElseIf nTipo == EXC_DET

        // MPG - 04/01/2018 - PONTO DE ENTRADA para validar dele��o de itens
        If (EasyEntryPoint("EECAP100"))
            lRet := ExecBlock("EECAP100",.F.,.F.,{"DEL_ITEM"})
            If ValType(lRet) <> "L"
                lRet := .t.
            Elseif ! lRet
                Break
            Endif
        EndIf

         If !lForcado
            lDelTudo := .t.
         EndIf

         If lConsolItem
            AuxIt->(DbGoTop())
         Else
            WorkIt->(DbGoTo(nRecno))
         EndIf

         If lForcado .Or. lEE7Auto .Or. MSGYESNO(STR0058,STR0059) //'Confirma Exclus�o? '###'Aten��o'
            While If(lConsolItem, AuxIt->(!EoF()),.t.)

               If lConsolItem
                  WorkIt->(DbGoTo(AuxIt->EE8_RECNO))
               EndIf

               WorkEm->(dbSeek(M->EE7_PEDIDO+WorkIt->EE8_SEQUEN))
               While !WorkEm->(Eof()) .And. WorkEm->(EEK_PEDIDO+EEK_SEQUEN)==;
                                            M->EE7_PEDIDO+WorkIt->EE8_SEQUEN
                  WorkEm->(dbDelete())
                  WorkEm->(dbSkip())
               Enddo

               If WorkIt->EE8_RECNO # 0

                  //AADD(aDeletados,WorkIt->EE8_RECNO) nopado por WFS
                  //Tratamento para dele��o quando a rotina de grade est� habilitada
                  If lGrade
                     EE8->(DBSetOrder(1)) //EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN + EE8_COD_I
                     cCpoCont:= WorkIt->EE8_COD_I

                     If MatGrdPrrf(@cCpoCont)
                        nLinAcols:= Val(WorkIt->EE8_SEQUEN)
                        For nLinha:= 1 To Len(oGrdExp:aColsGrade[nLinAcols])
                           For nColuna:= 2 To Len(oGrdExp:aHeadGrade[nLinAcols])

                              cProdGrd:= oGrdExp:GetNameProd(cCpoCont, nLinha, nColuna)

                              //Verifica se o registro existe na base.
                              If EE8->(DBSeek(xFilial() + WorkIt->EE8_PEDIDO + WorkIt->EE8_SEQUEN + cProdGrd)) .And.;
                                 !Empty(EE8->EE8_ITEMGR)

                                 AAdd(aDeletados, EE8->(RecNo()))
                              EndIf


                           Next
                        Next
                     Else
                        AAdd(aDeletados, WorkIt->EE8_RECNO)
                     EndIf
                  Else
                     AAdd(aDeletados, WorkIt->EE8_RECNO)
                  EndIf
               EndIf

               //** By JBJ - 14/06/2002 - 08:50
               If lConvUnid
                  M->EE7_PESLIQ -= AvTransUnid(WorkIt->EE8_UNPES,If(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),WorkIt->EE8_COD_I,WorkIt->EE8_PSLQTO,.F.)
                  M->EE7_PESBRU -= AvTransUnid(WorkIt->EE8_UNPES,If(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),WorkIt->EE8_COD_I,WorkIt->EE8_PSBRTO,.F.)
               Else
                  M->EE7_PESLIQ -= Workit->EE8_PSLQTO
                  M->EE7_PESBRU -= WorkIt->EE8_PSBRTO
               EndIf

               M->EE7_TOTPED -= WorkIt->EE8_PRCTOT
               M->EE7_TOTITE--
               If lTotRodape  // GFP - 11/04/2014
                  M->EE7_TOTFOB -= WorkIt->EE8_PRCTOT
                  M->EE7_TOTLIQ := M->EE7_VLFOB - M->EE7_VALCOM               
               EndIf   

               If EECFlags("COMISSAO")
                  If !Empty(WorkIt->EE8_CODAGE)
                     cOldCodAg := WorkIt->EE8_CODAGE
                  EndIf
               EndIf

               WorkIt->(DBDELETE())

               If lConsolida .and. !lConsolItem
                  If WorkGrp->(!EOF()) .and. WorkGrp->(!BOF())
                     WorkGrp->(DbDelete())
                  EndIf
               EndIf

               //MFR 27/05/2019 OSSME-3013
               AP100PrecoI(.t.)    
               If !lEE7Auto
                  AP100TTELA(.F.)
               EndIf
               
               IF cStatus == ST_CL .Or. cStatus == ST_PA
                  lAlteraStatus := .t.
               Endif

               // LCS.18/05/2006.17:28
               If EasyEntryPoint("EECAP100")
                  ExecBlock("EECAP100",.F.,.F.,{"DEL_WORKIT"})
               EndIf

               // FJH 06/02/06
               If EasyGParam("MV_AVG0119",,.F.) .and. EE8->(FieldPos("EE8_DESCON")) > 0
                  EECCALCDESC("P")
               Endif

               //** By JBJ - 10/06/2003 - 10:51 (Atualizar o total de comiss�o para o agente.)
               If EECFlags("COMISSAO")
                  If !Empty(cOldCodAg)
                     EECTotCom()
                  EndIf
               EndIf

               If lConsolItem
                  AuxIt->(DbSkip())
               Else
                  Exit
               EndIf
            EndDo

            If lConsolItem
               WorkGrp->(DbDelete()) // Apaga o registro da work de consolida��o
            EndIf                     
         EndIf
      EndIf
   End Sequence

   // JPM - 14/10/05
   If lConsolItem .And. !lRet .And. (nTipo == INC_DET .Or. nTipo == ALT_DET)
      Ap104AuxIt(4,.f.,.t.) //Restaura backup de vari�veis de mem�ria.
   EndIf

   dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AP100MANE()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Excluir Registros
Autor       : Heder M Oliveira
Data/Hora   : 07/12/98 14:16
Revisao     :
Obs.        :
*/
Static Function AP100MANE()

Local lRet:=.F.,cOldArea:=select(),cFilItem:=Xfilial("EE8")
Local nOpcao:=0,oDlgID,aExecutar:={STR0018,STR0019,STR0020} //"&Cancelar"###"&Eliminar"###"&Retornar"

Local bBotao1:={||cExecutar:=aExecutar[1], nOpcao:=1/*, If(lEE7Auto,,oDLGID:END())*/}
Local bBotao2:={||cExecutar:=aExecutar[2], nOpcao:=1/*, If(lEE7Auto,,oDLGID:END())*/}
Local bBotao3:={||nOpcao:=0/*, If(lEE7Auto,,oDLGID:END())*/}

Local cTit:=STR0021+ALLTRIM(M->EE7_PEDIDO)+STR0022         //"Cancelar ou Eliminar Registro do Processo : "###" ?"
Local cExecutar:=aExecutar[3], lRetPE, lExcluiuPV :=.f.
Local lIsFilBr:=.f.
//Local cFilBr := AvKey(EasyGParam("MV_AVG0023",,""),"EE7_FILIAL"),;
//      cFilEx := AvKey(EasyGParam("MV_AVG0024",,""),"EE7_FILIAL")
Local cFil

//ER - 03/08/2006 - Verifica se est� integrado com o faturamento e � um Processo B2b ou Remessa.
Private lB2BFat := IsProcNotFat()

Begin sequence

DO WHILE .T.

  nOpcao := 0

  If !lEE7Auto

     /* RMD - 19/06/2019 - N�o exibe a tela pois a op��o j� foi definida no submenu da tela principal
     DEFINE MSDIALOG oDlgID FROM 9,10 TO 15,70  TITLE cTit OF oMAINWND

        @ 1.5,013 BUTTON aExecutar[1] SIZE 35,15 ACTION EVAL(bBotao1)
        @ 1.5,025 BUTTON aExecutar[2] SIZE 35,15 ACTION EVAL(bBotao2)
        @ 1.5,037 BUTTON aExecutar[3] SIZE 35,15 ACTION EVAL(bBotao3)

     ACTIVATE MSDIALOG oDlgID CENTERED
     */
     If IsMemVar("lAP100CANCE") .And. lAP100CANCE
        If MsgYesNo(STR0247, STR0036) //"Confirma o cancelamento do Pedido?" ### "Aviso"
           Eval(bBotao1)
        Else
           Eval(bBotao3)
        EndIf
     Else
        If MsgYesNo(STR0248, STR0036) //"Confirma a exclus�o do Pedido?" ### "Aviso"
           Eval(bBotao2)
        Else
           Eval(bBotao3)
        EndIf
     EndIf
  Else
     If lEE7AutoCan
        Eval(bBotao1)
     ElseIf lEE7AutoDel
        Eval(bBotao2)
     EndIf
  EndIf

  If nOpcao == 1

     //AOM - 27/04/2011 - Operacao Especial
     If !VldOpeAP100("BTN_EXC_PED")
       Break
     EndIf

     If lIntermed

        /* by jbj - 20/07/04 - Para processos com tratamento de intermedia��o, o sistema valida se o cancelamento
                               ou a elimina��o poder� ser realizada, visto que para a rotina de off-shore, os
                               pedidos cancelados/eliminados e uma filial s�o automaticamente cancelados ou
                               eliminados na outra filial que faz parte da intermedia��o. */
        If !Ap104CanCancel(OC_PE)
           Break
        EndIf

        If !Ap100Crit("EE7_INTERM")
           Break
        EndIf
     EndIf

     EE8->(DBSETORDER(1))

     /* Quando integrado ao ERP via EAI, a elimina��o do pedido ser� permitida apenas quando
        o pedido estiver inregrado/ gerado no ERP. */
     If lIntPrePed
        If cExecutar == aExecutar[2] .And. !Empty(EE7->EE7_PEDERP) // Eliminar.
           EasyHelp(STR0217, STR0026) //"N�o � poss�vel efetuar esta opera��o pois o processo est� integrado com o ERP." // Aten��o
           lRet:= .F.
           Break
        EndIf
     EndIf

     // Valida��o para a op��o de 'Cancelar' para processos j� cancelados.
     IF cExecutar == aExecutar[1] .AND. (EE7->EE7_STATUS==ST_PC)
        If Type("lEE7Auto") == "L" .And. lEE7Auto//Quando a fun��o � chamada da OffShore n�o tem a vari�vel declarada
           EasyHelp(STR0023+TRANSF(DTOC(M->EE7_FIM_PE),"@d"),STR0024)
           Exit
        Else
           MSGINFO(STR0023+TRANSF(DTOC(M->EE7_FIM_PE),"@d") ,STR0024) //"Processo j� Cancelado em "###"Aten��o"
           LOOP
        EndIf
     ENDIF

     /*
     ER - 26/09/05 - 14:50. Altera��o para que pedidos que fazem parte de Embarque, n�o possam ser cancelados.
     */
     //IF ! lIntegra                                //NCF - 27/01/2011 - Nopado - Verifica��o deve ser feita independente da integra��o, visando manter a
        EE9->(DbSetOrder(1))                        //                   integridade referencial uma vez que estava permitindo excluir pedido com embarque
        IF EE9->(DbSeek(cFilItem+EE7->EE7_PEDIDO))
           While EE9->(!EOF()) .and. EE9->EE9_FILIAL == cFilItem .and. EE9->EE9_PEDIDO == EE7->EE7_PEDIDO
              EEC->(DbSetOrder(1))
              EEC->(DbSeek(cFilItem+EE9->EE9_PREEMB))

              If EEC->EEC_STATUS # ST_PC
                 HELP(" ",1,"AVG0000647") //MSGINFO("Processo possui Embarque, N�o pode ser Estornado","Aten��o")
                 Break
              EndIf
              EE9->(DbSkip())
           EndDo
        EndIf
     //EndIf

     IF cExecutar == aExecutar[2] // Eliminar.
        IF EasyEntryPoint("EECPPE09")
           lRetPE := ExecBlock("EECPPE09",.F.,.F.,EE7->EE7_PEDIDO)

           IF ValType(lRetPE) == "L" .And. !lRetPE
              Break
           Endif
        Endif

     Elseif cExecutar == aExecutar[1] // Cancelar.

        If EasyEntryPoint("EECAP100")    // TRP - 26/05/2008 - Inclus�o do ponto de entrada
           lRetPE := ExecBlock("EECAP100",.F.,.F.,{ "CANCELA"})

            IF ValType(lRetPE) == "L" .And. !lRetPE
              Break
            Endif
        Endif

     Endif

     IF lIntegra
        /*
           ER - 01/09/2006
           Caso o Pedido esteja cancelado e a op��o escolhida seja Excluir, n�o exclui Pedido de Venda,
           j� que este foi excluido ao Cancelar o Pedido.
        */
        If (cExecutar == aExecutar[2] .and. EE7->EE7_STATUS <> ST_PC) .or. cExecutar <> aExecutar[2]

           lExcluiuPV := MC110Integra(5,"GRV") //cancelar

           IF !lExcluiuPV
              Break
           Endif
        EndIf
     ENDIF

     IF ! lIntegra
        IF cExecutar == aExecutar[2] .AND. EE8->(DBSEEK(cFilItem+EE7->EE7_PEDIDO))  .And.  EE7->EE7_STATUS <> ST_PC   // PLB 21/09/06 - Se j� estiver cancelado nao valida saldo
           While !EE8->(EOF()) .AND. ;
               cFilItem+EE7->EE7_PEDIDO==EE8->EE8_FILIAL+EE8->EE8_PEDIDO
               IF EE8->EE8_SLDATU # EE8->EE8_SLDINI
                  HELP(" ",1,"AVG0000647") //MSGINFO("Processo possui Embarque, N�o pode ser Estornado","Aten��o")
                  BREAK
               ENDIF
               EE8->(DBSKIP())
           Enddo
        EndIf
     Endif

     IF cExecutar == aExecutar[1] // Cancelar.
        Begin Transaction
           If lNewRv .And. lRv11
              EEY->(DbSetOrder(2))
              EEY->(DbSeek(xFilial()+EE7->EE7_PEDIDO))
              While EEY->(!EoF()) .And. (EEY->(EEY_FILIAL+EEY_PEDIDO) == xFilial("EEY")+EE7->EE7_PEDIDO)
                 EEY->(RecLock("EEY",.F.)  ,;
                       EEY_STATUS := ST_BA ,;
                       MsUnlock()          ,;
                       DbSkip())
              EndDo
           EndIf

           If EE7->(Reclock("EE7",.f.))
              EE8->(DBSETORDER(1))
              If EE8->(DBSEEK(cFilItem+EE7->EE7_PEDIDO))
                  While !EE8->(EOF()) .AND. ;
                      cFilItem+EE7->EE7_PEDIDO==EE8->EE8_FILIAL+EE8->EE8_PEDIDO
                      RECLOCK("EE8",.F.)
                      EE8->EE8_STATUS := ST_PC
                      /* ER - 09/08/05 - 13:00 - Na op��o de cancelamento de pedidos o saldo a embarcar
                                                 dos itens, dever� ser zerado visto que como o pedido n�o
                                                 poder� ser utilizado, o saldo deve ser nulo. */
                      EE8->EE8_SLDATU := 0

                      EE8->(MsUnlock())
                      EE8->(DBSKIP(1))
                  End
              EndIf
              //cancelar pedido
              EE7->EE7_FIM_PE:=dDATABASE
              EE7->EE7_STATUS:=ST_PC
              //atualizar descricao de status
              DSCSITEE7(.T.)
              EE7->(MsUnlock())

              If lIntermed
                 /* Para os processos com tratamento de off-shore, o cancelamento � realizado automaticamente
                    na filial de intermedia��o, e vice-versa. */
                 cFil := If(AvGetM0Fil()==cFilBr,cFilEx,cFilBr)
                 AP100CanPed(cFil)
              EndIf
           EndIf
           //NCF - 08/10/2013 - Efetuar Cancelamento do Pedido Integrado via Mensagem Unica
           If lIntPreped
              lRetIntMsgUn:= .T.
              If !Empty(EE7->EE7_DTAPPE) .And. !EMPTY(EE7->EE7_PEDERP)//AAF 19/11/2014 - Permitir o envio de cancelamento.
                 lRetIntMsgUn := AvStAction("083") //A��o: Cancelamento do Pedido de Exporta��o
                 If !lRetIntMsgUn
                    DisarmTransaction()
                 EndIf
              EndIf
           EndIf

        End Transaction

        lRet := IF(lIntPreped, lRetIntMsgUn ,.t.)

     Elseif cExecutar == aExecutar[2] // Eliminar.

        /* wfs - pedido integrado ao ERP via mensagem �nica (Logix) n�o pode ser exclu�do;
                 apenas cancelado*/
        If lIntPreped .And. !EMPTY(M->EE7_PEDERP)
           EasyHelp(STR0217, STR0059) //N�o � poss�vel efetuar esta opera��o pois o processo est� integrado com o ERP. // Aten��o
           lRet:= .F.
           Break
        EndIf

        If lIntermed
           /* Para os processos com tratamento de off-shore, a elimina��o � realizada automaticamente
              na filial de intermedia��o, e vice-versa. */
           lIsFilBr := (AvGetM0Fil() <> cFilEx) //AvKey(EasyGParam("MV_AVG0024"),"EE7_FILIAL"))
           AP100DelPed(lIsFilBr,nil,nil,.t.)
        Else
           AP100DelPed()
        EndIf

        lRet:=.t.
     EndIf
  EndIf

  EXIT
Enddo

End sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AP100Del(aArq)
Parametros  : aArq == {cAlias,nOrdem,cSeek,bWhile}
Retorno     : .T.
Objetivos   : Deletar detalhe de uma capa
Autor       : Alex Wallauer
Data/Hora   : 17/08/99 14:08
Revisao     : Cristiano A. Ferreira
Data/Hora   : 24/08/99 15:14
*/
Function AP100Del(aArq,bDel)

LOCAL nOrdem := (aArq[1])->(IndexOrd())
LOCAL nRecNo := (aArq[1])->(RecNo())

LOCAL bWhi:=aArq[4]
LOCAL lRet := .f.

Begin Sequence

If Type("lEE7Auto") == "L" .And. !lEE7Auto
   IncProc(STR0026) //"Excluindo Itens, Agentes, Bancos, Despesas..."
EndIf

   (aArq[1])->(dbSetOrder(aArq[2]))

   If (aArq[1])->(dbSeek(aArq[3]))
      If EasyEntryPoint("EECAP100") //By CCH - 27/05/2008 - 15:55
         ExecBlock("EECAP100",.F.,.F.,{"PE_DEL_WORK",aArq})
      EndIf
      (aArq[1])->(dbEval(bDel,,bWhi))
      lRet := .t.
   EndIf

End Sequence

(aArq[1])->(dbSetOrder(nOrdem))
(aArq[1])->(dbGoTo(nRecNo))

RETURN lRet

/*
Funcao      : AP100Grava(lGrava,lIntegracao)
Parametros  : lGrava:= .T. - append blank
                       .F. - replace
              lIntegracao := .t. - Nao exibe msgs e n�o verifica integracao com o SIGAFAT.
                             .f. - Exibe msgs e integra com o SIGAFAT.
Retorno     : .T.
Objetivos   : Gravar Header e mensagens
Autor       : Heder M Oliveira
Data/Hora   : 20/11/98 09:38
Revisao     :
Obs.        :
*/
Function AP100Grava(lGrava,lIntegracao, lAuto)
   Local lRet:=.F.,cOldArea:=select(),nInc,nYnc, i:=0, nRecAux := 0
   Local cField, nPos, nOrdEEK,nItensSC6:=0,nItensEE8:=0,nPrecoEE8:=0,nPrecoSC6:=0,nQtd:= 0
   Local lDifItens:=.f.,lDifPreco:=.f.,nTotFob:=0,nTotComis:=0,nComisItem:=0, lTemAgente:=.f.
   Local lNaoConfPreco := EasyGParam( "MV_AVG0052",, .F. )
   Local lMensaAg
   Local lFirst:=.f., nCountAg := 0, nRecEE8:=0, j:=0
   Local aAtuEmb := {}, aAtuIt:= {}, aAux := {}, cOldFil := "", aOrdEE7 := {}
   Local cSequen := ""
   Local aChaves := {}

   Local aProc   := {}//AAF 09/03/05
   Local nPesoBru := 0 //LRL 11/03/05
   Local nPesoLiq := 0 //LRL 11/03/05
   Local aOrdAux  :={}
   Local nJ := 0
   Local aOrd := SaveOrd("EE7") // By JPP - 05/08/2005 - 14:45
   Local nCont, nSeq:= 0
   Local cFilGrd := "",;
         cPedGrd := "",;
         cSeqGrd := ""

   Default lIntegracao := .f.
   Default lAuto := .F.
   If Type("lSched") <> "L"
      Private lsched := lAuto
   EndIf
   If lsched .And. Type("oEECLog") <> "O"
      Private oEECLog := EECLog():New()
   EndIf

   Private aAltProc:= {} //AAF 09/03/05 - Processos a replicar altera��es.

   Private lIntegra := IsIntFat()
   Private lB2BFat  := IsProcNotFat()

   Private lRepEmb := .F.

   Private lRetPE := .T.//Possibilita mudar o retorno via ponto de entrada

   If Type("aMemos") <> "A"
      Private aMemos := {{"EE7_CODMAR","EE7_MARCAC"},;
                         {"EE7_CODMEM","EE7_OBS"},;
                         {"EE7_CODOBP","EE7_OBSPED"},;
                         {"EE7_DSCGEN","EE7_GENERI"}}
   EndIf

   //GFP - 19/05/2011
   If AvFlags("WORKFLOW")
      aChaves := EasyGroupWF("PEDIDO EXPORT")
   EndIf

   //wfs 18/10/12
   If Type("lOperacaoEsp") <> "L"
      lOperacaoEsp := AvFlags("OPERACAO_ESPECIAL")
   EndIf

   //wfs 24/10/12
   If Type("lGrade") <> "L"
      lGrade := AvFlags("GRADE")
   EndIf

   Begin Sequence

      //Prepara objeto para receber as mensagens retornadas pelas fun��es de grava��o,
      //para n�o exibir mensagens na tela quando for chamada a partir de rotinas agendadas
      If lsched
         oEECLog:AddProc(StrTran(StrTran(STR0160, "XXX", AllTrim(M->EE7_PEDIDO)), "YYY", xFilial("EE7")))//"Grava��o do pedido n�mero: 'XXX' na filial: 'YYY'"
      EndIf

      IF AllTrim(cFilEx) == "."
         cFilEx := AvKey("","EE7_FILIAL")
      Endif

      If Type("lRecriaPed") <> "L"
         lRecriaPed := .t.
      EndIf

      If !lIntegracao
         ProcRegua(LEN(aDeletados)+M->EE7_TOTITE+;
                   LEN(aDeDeletados)+WorkDe->(EasyReccount("WorkDe"))+;
                   LEN(aAgDeletados)+WorkAg->(EasyReccount("WorkAg"))+;
                   LEN(aInDeletados)+WorkIn->(EasyReccount("WorkIn"))+;
                   LEN(aNoDeletados)+WorkNo->(EasyReccount("WorkNo"))+1)

         If !lEE7Auto
            IncProc(STR0027+Transf(M->EE7_PEDIDO,AvSx3("EE7_PEDIDO",AV_PICTURE))) //"Gravando dados do Processo: "
         EndIf
      EndIf

      // ** By JBJ - 06/08/2002 - 17:53
      IF Select("WorkDoc") > 0
         If WorkDoc->(EasyReccount("WorkDoc")) == 0
            AddTarefa(Posicione("SA1",1,xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA,"A1_PAIS"),M->EE7_IMPORT+M->EE7_IMLOJA)
         EndIf
      Endif

      If !EECFlags("COMISSAO")
         // ** By JBJ - 02/04/02 14:32 - Carrega o valor FOB e a % de comissao...
         nTotFob := (M->EE7_TOTPED+M->EE7_DESCON)-(M->EE7_FRPREV+M->EE7_FRPCOM+M->EE7_SEGPRE+M->EE7_DESPIN+AvGetCpo("M->EE7_DESP1")+AvGetCpo("M->EE7_DESP2"))
         If M->EE7_TIPCVL="1"
            nTotComis := M->EE7_VALCOM  // Percentual (Pegar direto)

         ElseIf M->EE7_TIPCVL="2"
            nTotComis := Round(100*(M->EE7_VALCOM/nTotFob),2)

         ElseIf M->EE7_TIPCVL="3" .And. EE8->(FieldPos("EE8_PERCOM")) # 0
            SetComissao(OC_PE) // ** By JBJ 25/03/03 - 15:54. (C�lculo da comissao por item).
         EndIf
      Else
         // ** Efetua rateio para calcular o percentual para os agentes com comiss�o do tipo 'Valor Fixo'.
         If !AvFlags("COMISSAO_VARIOS_AGENTES")
            EECComVlFix()
         EndIf

         // JPM - 27/01/05 - N�o s�o mais dadas mensagens referentes a agentes na grava��o quando est� ativo o
         // novo tratamento de comiss�o com mais de um agente por item, exceto quando s�o agentes de perc. p/
         // item e em nenhum item h� agentes preenchidos.

         lTemAgente := .f.
         lMensaAg := .f.
         // ** Verifica se existe algum item n�o agenciado.
         WorkAg->(DbGoTop())
         Do While WorkAg->(!Eof()) .And. !lTemAgente
            If Left(WorkAg->EEB_TIPOAG,1) = CD_AGC
               lTemAgente := .t.
               lMensaAg := .t.
               If AvFlags("COMISSAO_VARIOS_AGENTES")
                  If WorkAg->EEB_TIPCVL <> "3"
                     lMensaAg := .f.
                  Else
                     WorkIt->(DbGoTop())
                     While WorkIt->(!EoF())
                        If !Empty(WorkIt->EE8_CODAGE)
                           lMensaAg := .f.
                           Exit
                        EndIf
                        WorkIt->(DbSkip())
                     EndDo
                  EndIf
               EndIf
               If lMensaAg
                  If (EECTrataIt() .And. !AvFlags("COMISSAO_VARIOS_AGENTES"))
                     EECTotCom()
                     EECComVlFix() // ** Efetua rateio para calcular o percentual para os agentes com comiss�o do tipo 'Valor Fixo'.
                  EndIf
               EndIf
            EndIf
            WorkAg->(DbSkip())
         EndDo
         If !lEE7Auto .and. ( lMensaAg .Or. !AvFlags("COMISSAO_VARIOS_AGENTES") ) //mpg - 17/08/2018 - execauto
            // ** Verifica se existe algum agente recebedor de comissao n�o utilizado.
            EECVerifyAg()
         EndIf
         If AvFlags("COMISSAO_VARIOS_AGENTES")
            If lTemAgente
               EECTotCom()
            Else
               WorkIt->(DbGoTop())
               While WorkIt->(!EoF())
                  WorkIt->EE8_PERCOM := 0
                  WorkIt->EE8_VLCOM := 0
                  WorkIt->EE8_CODAGE := ""
                  WorkIt->(DbSkip())
               EndDo
               WorkIt->(DbGoTop())
            EndIf
         EndIf

         /* by jbj - Acumular os valores de comiss�o dos agentes e gravar no campo de valor da comissao
                     na capa do processo.
                   - Grava��o do campo EEB_FOBAGE com o valor FOB total dos itens em que o agente foi
                     vinculado.  */

         WorkAg->(DbGoTop())
         M->EE7_VALCOM := 0
         lTemAgente    := .f.
         lFirst        := .t.
         nCountAg      := 0

         Do While WorkAg->(!Eof())
            If Left(WorkAg->EEB_TIPOAG,1) = CD_AGC // Considera apenas os agentes recebedores de comissao.
               If lFirst
                  M->EE7_TIPCOM := WorkAg->EEB_TIPCOM
                  M->EE7_TIPCVL := "2" // Valor fixo.
                  M->EE7_REFAGE := WorkAg->EEB_REFAGE
                  lTemAgente := .t.
                  lFirst     := .f.
               EndIf

               // ** Acumula o total de comiss�o.
               M->EE7_VALCOM += WorkAg->EEB_TOTCOM

               If EEB->(FieldPos("EEB_FOBAGE")) > 0
                  WorkAg->EEB_FOBAGE := SumFobIt(WorkAg->EEB_CODAGE,WorkAg->EEB_TIPCOM)
               EndIf

               // ** Caso existirem agentes com tipo de comiss�o diferetes a capa do processo fica em branco..
               If M->EE7_TIPCOM <> WorkAg->EEB_TIPCOM
                  M->EE7_TIPCOM := " "
               Endif
               nCountAg += 1
            EndIf

            WorkAg->(DbSkip())
         EndDo

         /* Caso existir mais de um agente de comiss�o a refencia do agente na capa do processo
            � gravada em branco. */
         If nCountAg > 1
            M->EE7_REFAGE := ""
         Endif

         If !lTemAgente // Caso nenhum agente seja encontrado os valore de comissao da capa s�o zerados.
            M->EE7_VALCOM := 0
            M->EE7_REFAGE := ""
            M->EE7_TIPCOM := ""
            M->EE7_TIPCVL := ""
         EndIf
      EndIf

      // ** By JBJ - 07/03/2002 10:06
      /*
      IF EasyGParam("MV_AVG0004") // Conferencia dos Pesos
         EECGetPesos(OC_PE)
      Endif
      */
      If lGrava .And. EECFlags("ORD_PROC")
         M->EE7_KEY := AP101GetKey(OC_PE)
      EndIf

      //ER - 28/06/2008
      If (!lIntegra .and. (lLibCredAuto .And. lGrava)) .And.;
         Left(M->EE7_PEDIDO,1) <> "*"

         M->EE7_DTAPCR := dDataBase
         M->EE7_STATUS := "3" //Cr�dito Liberado
         M->EE7_STTDES := Tabela("YC",M->EE7_STATUS)
      EndIf

      /*
      AMS - 24/06/2005. Grava��o do campo "EE7_INTEGR" como "N" para indicar que o pedido n�o � origin�rio
                        da integra��o.
      */
      If (Type("lEE7Auto") <> "L" .Or. !lEE7Auto) .And. EasyGParam("MV_AVG0094",, .F.) .and. EE7->(FieldPos("EE7_INTEGR") > 0 .and. Empty(M->EE7_INTEGR))
         M->EE7_INTEGR := "N"
      EndIf
      If lGrava    // By JPP - 05/08/2005 - 14:45 - N�o permite Incluir processos com o mesmo C�digo.
         EE7->(DbSetOrder(1))
         Do While .t.
            If lIntegracao
               If EE7->(DbSeek(xFilial("EE7")+M->EE7_PEDIDO))
                  AP106TelaNProc(.T.)  // Exibe Mensagem de Cancelamento da grava��o no servidor
                  Break
               Else
                  Exit
               EndIf
            Else
               If EE7->(DbSeek(xFilial("EE7")+M->EE7_PEDIDO))
                  If ! AP106TelaNProc(.F.) // Exibe tela solicitando a digita��o de novo codigo para o processo.
                     Break
                  EndIf
               Else
                  Exit
               EndIf
            EndIf
         EndDo
         RestOrd(aOrd) // By JPP - 05/08/2005 - 14:45
      EndIf

      E_Grava("EE7",lGrava)
      nRecNoEE7 := EE7->(RecNo())    //// 18.mai.09 - UE719063 - Corre��o para o MBrowse parar no campo rec�m inclu�do - HFD

      IF EE7->(RecLock("EE7",.F.))
         DSCSITEE7(.T.)
      Endif

      If !lGrava // Alteracao - registros excluir
         For nInc:= 1 To Len(aMemos)
            EasyMSMM(EE7->&(aMemos[nInc][1]),,,,EXCMEMO,,,"EE7",aMemos[nInc][1])
         Next
         /*
         MSMM(EE7->EE7_CODMAR,,,,EXCMEMO)
         MSMM(EE7->EE7_CODOBP,,,,EXCMEMO)
         MSMM(EE7->EE7_CODMEM,,,,EXCMEMO)
         MSMM(EE7->EE7_DSCGEN,,,,EXCMEMO)
         */
      EndIf

      For nInc := 1 To Len(aMemos)
         EasyMSMM(,TAMSX3(aMemos[nInc][2])[1],,M->&(aMemos[nInc][2]),INCMEMO,,,"EE7",aMemos[nInc][1])
      Next

      /*
      MSMM(,TAMSX3("EE7_OBS")[1],,M->EE7_OBS,INCMEMO,,,"EE7","EE7_CODMEM")
      MSMM(,TAMSX3("EE7_MARCAC")[1],,M->EE7_MARCAC,INCMEMO,,,"EE7","EE7_CODMAR")
      MSMM(,TAMSX3("EE7_OBSPED")[1],,M->EE7_OBSPED,INCMEMO,,,"EE7","EE7_CODOBP")
      MSMM(,TAMSX3("EE7_GENERI")[1],,M->EE7_GENERI,INCMEMO,,,"EE7","EE7_DSCGEN")
      */

      If !lIntegracao
         // *** Grava Itens do Processo (EE8) ...
         For nInc:=1 to LEN(aDeletados)
            EE8->(DBGOTO(aDeletados[nInc]))
            If !lEE7Auto
               IncProc()
            EndIf

            // ** By JBJ - 10/06/2002 - 14:47 ..
            // MSMM(EE8->EE8_DESC,,,,EXCMEMO)
            For i:=1 To Len(aMemoItem)
               If EE8->(FieldPos(aMemoItem[i][1])) > 0
                  EasyMSMM(EE8->&(aMemoItem[i][1]),,,,EXCMEMO,,,"EE8",aMemoItem[i][1])
               EndIf
            Next i

            // AMS - 14/07/2003 - 18:02 / Exclus�o dos registros no EEY.
            If EE8->( FieldPos( "EE8_STA_RV" ) ) <> 0 .and. !EE8->( Empty( EE8_STA_RV ) )
               EEY->( dbSetOrder( 3 ) )
               If EEY->( dbSeek( xFilial( "EEY" ) + EE8->EE8_PEDIDO + EE8->EE8_SEQ_RV ) )
                  RecLock( "EEY", .F. )
                  EEY->( dbDelete() )
                  EEY->( MsUnlock() )
               EndIf
            EndIf

            cSequen := ""
            If lGrade
               If EE8->EE8_GRADE == "S"
                  cFilGrd := EE8->EE8_FILIAL
                  cPedGrd := EE8->EE8_PEDIDO
                  cSeqGrd := EE8->EE8_SEQUEN
               EndIf
            EndIf

            //Alcir - 25/08/04
            If EasyEntryPoint("EECAP100")
               ExecBlock("EECAP100",.F.,.F.,{ "ESTORNO_ITEM" })
            Endif
            RecLock("EE8",.F.)
            EE8->(DBDELETE())
            EE8->(MsUnlock())
         Next nInc
      EndIf

      IF !EasyGParam("MV_AVG0005") // Deixar de gravar embalagens ?
         nOrdEEK := EEK->(IndexOrd())

         EEK->(dbSetOrder(2))
         IF EEK->(dbSeek(xFilial()+OC_PE+M->EE7_PEDIDO))
            While ! EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
                  EEK->EEK_TIPO  == OC_PE .And. EEK->EEK_PEDIDO == M->EE7_PEDIDO

               EEK->(RecLock("EEK",.F.))
               EEK->(dbDelete())
               EEK->(MSUnlock())

               EEK->(dbSkip())
            Enddo
         Endif

         EEK->(dbSetOrder(nOrdEEK))
      Endif

      WorkIt->(DBGOTOP())
      While ! WorkIt->(EOF())
         If !lIntegracao // Chamada a partir das integracoes/migracoes de dados.
            If lIntegra // Integracao com o Faturamento.
               IF EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. M->EE7_GPV $ cSIM
                  nItensEE8++
                  IF GetNewPar("MV_AVG0017","S") == "S" // Na integra��o com o Faturamento, o C6_PRECO � o pre�o FOB ? (S/N)
                     nPrecoEE8+=WorkIt->EE8_PRCINC
                  Else
                     nPrecoEE8+=WorkIt->EE8_PRCTOT
                  Endif
               ENDIF
            ElseIf AVFLAGS("EEC_LOGIX")          //NCF - 24/03/2015 - Recalcular Peso bruto relativo as embalagens
               Ap101CalcPsBr(OC_PE,.T.,lLibPes)
               nPesoBru+= WorkIt->EE8_PSBRTO
               nPesoLiq+= WorkIt->EE8_PSLQTO
            EndIf
         //LRL 11/03/05-----Recalcular QtddeEmbalagens-------------------------------
         Else
            If (WorkIt->EE8_SLDINI % WorkIt->EE8_QE) != 0
               WorkIt->EE8_QTDEM1 := Int(WorkIt->EE8_SLDINI /WorkIt->EE8_QE)+1
            Else
               WorkIt->EE8_QTDEM1 := Int(WorkIt->EE8_SLDINI/WorkIt->EE8_QE)
            Endif
            Ap101CalcPsBr(OC_PE,.T.,lLibPes)
            nPesoBru+= WorkIt->EE8_PSBRTO
            nPesoLiq+= WorkIt->EE8_PSLQTO
         //-------------------------------LRL 11/03/05-----Recalcular QtddeEmbalagens
         EndIf
         If !lGrava .AND. WorkIt->EE8_RECNO # 0
            EE8->(DBGOTO(WorkIt->EE8_RECNO))
            RecLock("EE8",.F.)
         Else
            RecLock("EE8",.T.)  // bloquear e incluir registro vazio
         EndIf

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         For nYnc := 1 to EE8->(FCount())

            cField := EE8->(FieldName(nYnc))
            nPos   := WorkIt->(FieldPos(cField))

            IF nPos > 0
               EE8->(FieldPut(nYnc,WorkIt->(FieldGet(nPos))))
            Endif
         Next nYnc

         EE8->EE8_FILIAL := xFilial("EE8")
         EE8->EE8_PEDIDO := M->EE7_PEDIDO
         EE8->EE8_SLDATU := WorkIt->EE8_SLDATU //WORKIT->EE8_SLDINI

         // ** Acumula os itens que dever�o ser atualizados.
         If !Empty(WorkIt->WP_EE9REG)
            EE9->(DbGoTo(WorkIt->WP_EE9REG))
            aAdd(aAtuEmb,{EE9->EE9_FILIAL,;
                          EE9->EE9_SEQEMB,;
                          EE9->EE9_PREEMB,;
                          WorkIt->WP_EE9SLD})
         EndIf

         // ** By JBJ - 01/04/2002 - 16:59  Impede comissao maior que 100%
         If !EECFlags("COMISSAO")
            If M->EE7_TIPCVL = "1" .Or. M->EE7_TIPCVL = "2"
               If EE8->(FieldPos("EE8_PERCOM")) # 0
                  EE8->EE8_PERCOM := If(nTotComis>99.99,99.99,Round(nTotComis,AVSX3("EE8_PERCOM",AV_DECIMAL)))
               EndIf
            EndIf
         EndIf

         If !lGrava .AND. WorkIt->EE8_RECNO # 0
            // *** Alteracao de campo memo
            For i:=1 To Len(aMemoItem)
               If EE8->(FieldPos(aMemoItem[i][1])) > 0 .And. WorkIt->(FieldPos(aMemoItem[i][2])) > 0
                  EasyMSMM(EE8->&(aMemoItem[i][1]),,,,EXCMEMO,,,"EE8",aMemoItem[i][1])
                  EE8->(EasyMSMM(EE8->&(aMemoItem[i][1]),AVSX3(aMemoItem[i][2])[AV_TAMANHO],,WORKIT->&(aMemoItem[i][2]),INCMEMO,,,"EE8",aMemoItem[i][1]))
               EndIf
            Next i

            // ** By JBJ - 10/06/2002 - 13:57
            //MSMM(EE8->EE8_DESC,,,,EXCMEMO)
            //EE8->(MSMM(EE8->EE8_DESC,AVSX3("EE8_VM_DES")[AV_TAMANHO],,WORKIT->EE8_VM_DES,INCMEMO,,,"EE8","EE8_DESC"))
         Else
            // *** Inclusao de campo memo
            For i:=1 To Len(aMemoItem)
               If EE8->(FieldPos(aMemoItem[i][1])) > 0 .And. WorkIt->(FieldPos(aMemoItem[i][2])) > 0
                  EE8->(EasyMSMM(,AVSX3(aMemoItem[i][2])[AV_TAMANHO],,WORKIT->&(aMemoItem[i][2]),INCMEMO,,,"EE8",aMemoItem[i][1]))
               EndIf
            Next i

            // ** By JBJ - 10/06/2002 - 13:57
            //EE8->(MSMM(,AVSX3("EE8_VM_DES")[AV_TAMANHO],,WORKIT->EE8_VM_DES,INCMEMO,,,"EE8","EE8_DESC"))
         EndIf

         EE8->(MsUnlock())

         // *** Grava Embalagens ...
         IF !EasyGParam("MV_AVG0005") // Deixar de gravar embalagens ?
            AP100GrvEmb()
         Endif

         ///////////////////////////////////////////
         //Grava��o dos itens da grade de produtos//
         ///////////////////////////////////////////
         If lGrade
           Begin Transaction
              Ap102GrdGrava()
           End Transaction
         Else
            EE8->(RecLock("EE8", .F.))
            EE8->EE8_GRADE:= "N"
            EE8->(MsUnlock())
         EndIf

         If EasyEntryPoint("EECAP100") // By JPP - 17/11/2006 - 11:30 - Inclus�o do ponto de entrada.
            ExecBlock("EECAP100", .F., .F., {"PE_GRV_EE8"})
         EndIf

         WorkIt->(DBSKIP())
      Enddo

      //LRL-11/03/05----------------------------------------------
      If lIntegracao
         RecLock("EE7",.F.)
         EE7->EE7_PESLIQ := nPesoLiq
         EE7->EE7_PESBRU := nPesoBru
         EE7->( MsUnlock() )
         AP100PrecoI(.T.)
      ElseIf AVFLAGS("EEC_LOGIX")  //NCF - 02/04/2015
         RecLock("EE7",.F.)
         EE7->EE7_PESLIQ := nPesoLiq
         EE7->EE7_PESBRU := nPesoBru
         EE7->( MsUnlock() )
      EndIf
      //----------------------------------------------LRL-11/03/05

      If EasyGParam("MV_AVG0017",, "S") == "S"
         nPrecoEE8 -= EE7->EE7_DESCON
      EndIf

      // ** By JBJ - 01/07/03 - Novo par�metro para controle da fun��o IncProc().
      AP100DSGrava(.F.,OC_PE,lIntegracao)  // GRAVAR EET
      AP100AGGrava(.F.,OC_PE,lIntegracao)  // GRAVAR EEB
      AP100INSGrava(.F.,OC_PE,lIntegracao) // GRAVAR EEJ

      IF Select("WorkDoc") > 0 .And. Select("EXB") > 0
         If WorkDoc->(EasyReccount("WorkDoc")) <> 0
            Ap100DocGrava(.f.,OC_PE,,lIntegracao) // Gravar EXB
         Else
            // ** Carrega os documentos obrigatorios para o importador ...
            AddTarefa(Posicione("SA1",1,xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA,"A1_PAIS"),M->EE7_IMPORT+M->EE7_IMLOJA)
            If WorkDoc->(EasyReccount("WorkDoc")) <> 0
               Ap100DocGrava(.f.,OC_PE,,lIntegracao)
            EndIf
         EndIf
      Endif

      If !lIntegracao
         AP100NoGrv(.F.,OC_PE)

         // ** By JBJ 26/03/03 - 10:36 (Mostra aviso, caso as comiss�es n�o estejam corretas (Comissao por item).
         Ap100ValCom(OC_PE,.f.)
      EndIf

      If lIntermed
         AP100GerPed(lGrava)
         If !lRecriaPed .And. EECFlags("INTERMED"); // !lRecriaPed .And. EECFlags("CONTROL_QTD") // JPM - 05/10/05 - Controle de quantidades entre filiais Brasil e Off-Shore
            .And. lCommodity //WFS 08/01/09         // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padr�o para Off-Shore

            Ap104AtuFil()
            aAtuQtdFil := {} //CCH - 02/10/2008 - Esvazia array de atualiza��es para contemplar as altera��es caso seja alterado um Pedido Pr�-Existente na Base
         EndIf
      EndIf

      //** AAF - 03/09/04 - Grava��o das Invoices a Pagar em caso de Back To Back
      If lBACKTO
         AP106Grv(OC_PE)
      Endif
      //**

      If Type("lPagtoAnte") == "L" .And. lPagtoAnte     // By JPP - 14/02/2006 - 16:20
         AP105GrvEstAd()  // Grava��o do estorno dos adiantamentos do processo
      EndIf

      /* by jbj - tratamentos para replica��o de altera��o de quantidades nos itens
                  dos embarques. */

      If Len(aAtuEmb) > 0

         lRepEmb := .T.

         AP104TrataWorks()       // Salva as works para utiliza��o na fun��o de grava��o do pedido.
         aAux := aE102SetWorks() // Cria as works necess�rias da fase de embarque.

         aAtuEmb := aSort(aAtuEmb,,,{|x,y| x[4] < y[4]})

         EE9->(DbSetOrder(1))
         cOldFil := aAtuEmb[1][1]
         cOldEmb := aAtuEmb[1][3]

         For j:=1 To Len(aAtuEmb)
            aAdd(aAtuIt,{aAtuEmb[j][2],aAtuEmb[j][4]})

            If (cOldFil+cOldEmb <> aAtuEmb[j][1]+aAtuEmb[j][3] .Or. j == Len(aAtuEmb))
               Ap104ReplyChanges(cOldFil,cOldEmb,aAtuIt)

               cOldFil := aAtuEmb[1][1]
               cOldEmb := aAtuEmb[1][4]
               aAtuIt  := {}
            EndIf
         Next

         // Apaga as works criadas para atualiza��o do embarque.
         aE102DelWorks(aAux)

         // Restaura as works ap�s utiliza��o da fun��o de grava��o do pedido.
         AP104TrataWorks(.f.)

         lRepEmb := .F.

      EndIf

      /* by jbj - 12/03/2005 - Atualiza��o da filial de off-shore com os detalhes da
                               filial brasil. */

      If AvGetM0Fil() == cFilBr .And. M->EE7_INTERM $ cSim .And. !lRecriaPed
         aOrdEE7 := SaveOrd("EE7")

         EE7->(DbSetOrder(1))
         If EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))
            If EE7->(RecLock("EE7",.F.))
               EE7->EE7_IMPORT := M->EE7_CLIENT
               EE7->EE7_IMLOJA := M->EE7_CLLOJA
               EE7->EE7_IMPODE := Posicione("SA1",1,xFilial("SA1")+M->EE7_CLIENT,"A1_NOME")
               EE7->EE7_ENDIMP := EECMEND("SA1",1,M->EE7_CLIENT+M->EE7_CLLOJA,.T.,,1)
               EE7->EE7_END2IM := EECMEND("SA1",1,M->EE7_CLIENT+M->EE7_CLLOJA,.T.,,2)
               EE7->EE7_FORN   := If(!Empty(M->EE7_EXPORT),M->EE7_EXPORT,M->EE7_FORN)
               EE7->EE7_FOLOJA := If(!Empty(M->EE7_EXLOJA),M->EE7_EXLOJA,M->EE7_FOLOJA)

               If !Empty(M->EE7_COND2) .And. !Empty(M->EE7_DIAS2)
                  EE7->EE7_CONDPA := M->EE7_COND2
                  EE7->EE7_DIASPA := M->EE7_DIAS2
               EndIf

               If !Empty(M->EE7_INCO2)
                  EE7->EE7_INCOTE := M->EE7_INCO2
               EndIf

               /* Neste ponto o sistema ir� realizar os acertos necess�rios para realizar a aprova��o autom�tica na
                  filial de intermedia��o. */
               If nSelecao == APRVCRED
                  If !Empty(M->EE7_DTAPCR)
                     EE7->EE7_DTAPCR := dDataBase
                     EE7->EE7_STATUS := "3"
                     EE7->EE7_STTDES := Tabela("YC",EE7->EE7_STATUS)
                  EndIf
               EndIf
            EndIf
         EndIf


         If Len(aItAlterados) > 0
            aOrdAux := SaveOrd({"EE8"})
            EE8->(DbSetOrder(1))
            For nJ := 1 To Len(aItAlterados)
                If EE8->(DbSeek(cFilEx+M->EE7_PEDIDO+aItAlterados[nj][1]))
                   If EE8->(RecLock("EE8",.f.))
                      EE8->EE8_PRECO := aItAlterados[nj][2]
                      EE8->(MsUnLock())
                      lUpdatepreco := .t.
                   EndIf
                EndIf
            Next
            RestOrd(aOrdAux,.t.)
         EndIf
         RestOrd(aOrdEE7,.t.)

      ElseIf AvGetM0Fil() == cFilEx
         If Len(aItAlterados) > 0
            aOrdAux := SaveOrd({"EE8"})
            EE8->(DbSetOrder(1))
            For nJ := 1 To Len(aItAlterados)
                If EE8->(DbSeek(cFilBr+M->EE7_PEDIDO+aItAlterados[nj][1]))
                   EE8->(RecLock("EE8",.f.))
                   For i := 1 To Len(aCposAlterados)
                      EE8->&(aCposCorresp[i]) := aItAlterados[nJ][i+1]
                   Next
                   /* JPM - 15/03/06 - Permitir mais campos que devem ser atualizados de uma filial a outra
                   EE8->EE8_PRENEG  := aItAlterados[nj][2]
                   If EE8->(FieldPos("EE8_DIFE2")) <> 0
                      EE8->EE8_DIFE2   := aItAlterados[nj][3]
                   EndIf
                   */
                   EE8->(MsUnLock())
                   lUpdatepreco := .t.
                EndIf
            Next
            RestOrd(aOrdAux,.t.)
         EndIf

      EndIf

      If !lIntegracao
         // Alterado por Heder M Oliveira - 1/19/2000
         IF EasyEntryPoint("EECAP100")
            // by CAF 31/07/2002 - Flag para que o ponto de entrada seja executado apenas uma vez.
            lEECAP100 := .T.
            EXECBLOCK("EECAP100", .F., .F., {"PE_GRV"})
         ENDIF

         If !lIntEmb
            IF lIntegra
              IF (EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. M->EE7_GPV $ cSIM) .And. !Empty(M->EE7_FATURA)
                  // ** Verifica se nao existe falha na integridade entre o ped. exportacao e o ped. venda.
                  SC6->(dbSetOrder(1))
                  SC6->(dbSeek(xFilial()+AvKey(M->EE7_PEDFAT,"C6_NUM")))

                  // Conta o nro de itens e calcula o total do pedido.
                  Do While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. AvKey(M->EE7_PEDFAT,"C6_NUM") == SC6->C6_NUM
                     nItensSC6++
                     nPrecoSC6+=SC6->C6_VALOR
                     SC6->(DbSkip())
                  EndDo

                  //ACB - 09/11/2010 - quando o parametro MV_AVG0085 estiver ligado considera o desconto total do processo, e n�o o total rateado nos itens por item, n�o acusando diferen�a de valores.
                  SC5->(dbSetOrder(1))
                  SC5->(dbSeek(xFilial()+AvKey(M->EE7_PEDFAT,"C6_NUM")))
                  If EasyGParam("MV_AVG0085",,.F.) == .T.
                     nPrecoSC6 := nPrecoSC6 - SC5->C5_DESCONT
                  EndIf

                  //WFS 10/02/2010
                  //Recalcula a quantidade de itens com base no array aGrdRec, para consistir com o faturamento
                  If lGrade
                     nItensEE8:= 0
                     WorkIt->(DBGoTop())

                     While WorkIt->(!Eof())

                        If nSeq == Val(WorkIt->EE8_SEQUEN)
                           WorkIt->(DBSkip())
                           Loop
                        Else
                           nSeq:= Val(WorkIt->EE8_SEQUEN)
                        EndIf

                        //Se � um item tipo grade
                        nPos:= AScan(aGrdRec, {|x| x[1] == WorkIt->EE8_SEQUEN})
                        If nPos > 0 .And. Len(aGrdRec[nPos][2]) > 0
                           For nCont:= 1 To Len(aGrdRec[nPos][2])
                              If aGrdRec[nPos][2][nCont][1] <> 0
                                 nItensEE8++
                              EndIf
                           Next
                        Else
                           nItensEE8++
                        EndIf
                     EndDo
                  EndIf

                  // ** Verifica se o nro de itens do pedido � igual do faturamento.
                  If nItensEE8 <> nItensSC6
                     lDifItens:=.T.
                  EndIf

                  nPrecoEE8 := Round(nPrecoEE8, EECPreco("EE8_PRCTOT", AV_DECIMAL))

                  // AMS - 29/07/2003 �s 19:52 - Verifica se n�o deve efetuar conferencia de Pre�o.
                  If !lNaoConfPreco
                     If nPrecoEE8 <> (nPrecoSC6 + If(EasyGParam("MV_EEC0039",,.F.) .And. EE7->(FieldPos("EE7_FREEMB")) > 0, EE7->EE7_FREEMB, 0))
                        lDifPreco:=.T.
                     EndIf
                  EndIf

                  If lDifItens
                     // Exibe tela com os detalhes da falha de integridade
                     AP100Error(nItensEE8,nItensSC6,nPrecoEE8,nPrecoSC6)
                  Else
                     If lDifPreco
                        // Exibe tela com os detalhes da falha de integridade
                        AP100Error(nItensEE8,nItensSC6,nPrecoEE8,nPrecoSC6)
                     EndIf
                  EndIf
               ENDIF
            EndIf
         EndIf

         AE100Status(EE7->EE7_PEDIDO)

         /*If lIntegra -- Nopado por MCF - 11/01/2017
            If EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. M->EE7_GPV $ cSIM
               If ! MC110Integra(IF(lGrava,3,4),"MSG")
                  Break
               Endif
            EndIf
         Endif*/
      EndIf

      LRET := .T.

   End Sequence

   //Alcir - 25/08/04
   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.F.,.F.,{ "GRV_PED" })
      If !lRetPE
         lRet := .F.
      EndIf
   EndIf

   //TRP - 03/03/2011 - Tratamento de WorkFlow no Pedido de Exportac�o.
//   If AvFlags("WORKFLOW") .AND. INCLUI
//      EasyGroupWF("PEDIDO EXPORT",aChaves)
//   EndIf
   /*
   If lEasyWorkFlow
      SX2->(DbSetOrder(1))
      If SX2->(DbSeek("EJ7"))
         EJ7->(DbSetOrder(1))
         If EJ7->(DbSeek(xFilial("EJ7")+AvKey("PEDIDO","EJ7_COD"))) .AND. EJ7->EJ7_ATIVO == "1" .AND. EJ7->EJ7_OPCENV == "1"
            oWorkFlow := EasyWorkFlow():New("PEDIDO", EE7->(EE7_FILIAL+EE7_PEDIDO))
            oWorkFlow:Send()
         Endif
      Endif
   Endif
   */
   RestOrd(aOrd) // By JPP - 05/08/2005 - 14:45
   dbselectarea(cOldArea)

   /*
   Fun��o Ae107AtuProcs() - Par�metros : 1 - Armazena dados necess�rios para altera��o ap�s a grav. das replica��es.
                                         2 - Executa as altera��es necess�rias.
   */

   // AAF 09/03/05 - Replica altera��es
   If lRet .And. lReplicaDados .AND. Select("WK_MAIN") > 0//Evita recursividade.

      // JPM - 27/04/05 - Executa tratamentos espec�ficos
      Ae107AtuProcs(1)

      WK_MAIN->( dbSetOrder(2) )
      WK_MAIN->( dbGoTop() )
      Do While !WK_MAIN->( EoF() )

         aProc := AX100GrvRpl( WK_MAIN->WK_FILIAL, WK_MAIN->WK_PROC, WK_MAIN->WK_FASE )

         If Len(aProc) > 0
            aAdd(aAltProc,aProc)
         Endif

      EndDo
      WK_MAIN->( E_EraseArq(cArqMain) )
      FErase(cArqMain2+TEOrdBagExt())
      FErase(cArqMain3+TEOrdBagExt())
      FErase(cArqMain4+TEOrdBagExt())
      If !lEE7Auto
         If Len(aAltProc) > 0
            Processa({|| ProcRegua( Len(aAltProc) ),;//Acerta a base com as grava��es das altera��es replicadas para off-shore.
                         AX100GrvProcs(aAltProc),Ae107AtuProcs(2) },;
                         STR0183)//""  //STR0183	Atualizando processos relacionados
         Else
            AX100GrvProcs(aAltProc)
            Ae107AtuProcs(2)
         EndIf
      Endif
   Endif
   //**

   /* WFS 19/01/2010
      Inclus�o do tratamento de nota fiscal de remessa, para atender
      ao conv�nio ICMS n.� 84 no DOU de 29/09/09.

      Grava��o das Notas Fiscais de Remessa */
   If lRet .And. !NFRemFimEsp() .And. AvFlags("FIM_ESPECIFICO_EXP") .And. !lNfRemFinalizado .And. SELECT("Wk_NfRem") > 0
      AE110GravaNfRem(aNfRemDeletados)
   EndIf

   //Imprime log das mensagens retornadas
   If lsched
      oEECLog:PrintLog()
   EndIf

   //AOM - 27/04/2011 - Operacao Especial
   If lRet .And. lOperacaoEsp
      oOperacao:SaveOperacao()
   EndIf

// *** GFP - 30/03/2011 :: 09h49 - Tratamento de WorkFlow na liber. de credito.
If lRet .And. AvFlags("WORKFLOW")
   EasyGroupWF("PEDIDO EXPORT",aChaves)
EndIf
   /*
   EE7->(DbSetOrder(1))
   If lEasyWorkFlow
      SX2->(DbSetOrder(1))
      If SX2->(DbSeek("EJ7"))
         EJ7->(DbSetOrder(1))
         If EJ7->(DbSeek(xFilial("EJ7")+AvKey("CR","EJ7_COD"))) .AND. EJ7->EJ7_ATIVO == "1" .AND. EJ7->EJ7_OPCENV == "1"
            oWorkFlow := EasyWorkFlow():New("CR", EE7->(EE7_FILIAL+EE7_PEDIDO))
            oWorkFlow:Send()
         Endif
      Endif
   */
// ***Fim GFP

Return lRet

/*
Funcao      : AP100LINOK(nOpc,nReg,oDlg)
Parametros  : nOpc, nReg, oDlg
Retorno     : .T. /.F.
Objetivos   : Validar campos enchoice
Autor       : Heder M Oliveira
Data/Hora   : 07/01/99 16:52
Revisao     : WFS 23/02/2010
              Inclus�o dos tratamentos de preenchimento do array aGrdAux e
              atualiza��o do objeto ap�s a integra��o com o faturamento ter sido
              mal sucedida.
Obs.        :
*/
Static Function AP100LINOK(nOpc,nReg,oDlg)
   Local aOrd:=SaveOrd({"EE7","EE8"})

   Local cOldStat := M->EE7_STATUS
   Local cOldReadVar
   Local cCpoCont, cProdGrd

   Local dOldApCr := M->EE7_DTAPCR
   Local dOldApPr := If(lIntPrePed,EE7->EE7_DTAPPE,cToD("  /  /  "))
   Local lRet:=.T.,cOldArea:=select(), nRecEE7, nRec:=0, i:=0
   Local lGravaOk := .t.
   Local lTemItemFixado :=.f., lTemEmbarque := .f.

   Local nRecnoIt, nPos, nInc, nQuantDig, nCont
   //Local cFilEx:=EasyGParam("MV_AVG0024",,"")
   //Local cFilBr:=EasyGParam("MV_AVG0023",,"")

   Local oGradeAux

   Private aCampoVld :={"EE7_MARCAC"}   // JPP - 01/08/2005 16:37
   Private lFaturado := .F. // DFS - 04/01/2010 - Altera��o do valor da vari�vel, para que n�o traga status de faturado para todos os pedidos criados.

   Private lB2BFat := IsProcNotFat()
   Private nContPon := 0 //LRS - 11/11/2015 - Contador para o ponto INTEG_FAT para n�o entrar mais de uma vez.

   Begin Sequence

      IF ( WorkIT->(BOF()) .AND. WorkIT->(EOF()) )
         lRET:=.F.
         HELP(" ",1,"AVG0000070")
         BREAK
      ENDIF
      //NCF - 17/10/2014 - Teste da vari�vel e Teste ExecAuto
      If !Ap104ValProc(nOpc,OC_PE) // By JPP - 12/05/2006 - 13:30 - N�o permitir a inclus�o de processos j� cadastrados em outra filial.
         lRET := .F.
         Break
      EndIf

      //ER - 05/05/2006
      If lBackTo
         /* Fun��o que ir� verificar se existe alguma invoice que n�o tenha sido vinculada
            a itens. Em caso positivo, a fun��o ir� exibir msg de alerta ao usu�rio. */
         lRet := Ap106ChkVincInv()
         If !lRet
            Break
         EndIf
      EndIf

      /*
      Nopado por ER em 06/02/2007.
      Ser� permitido incluir Pedido de Back to Back sem Vincular Invoice a Pagar.
      Essa verifica��o ser� feita apenas no Embarque.

      //RMD - 02/05/06 - Tratamento para pedido de Back To Back
      If lConsign
         If lBackTo .And. !AP106isBackTo()
            MsgInfo(STR0139,STR0059)//"N�o ser� poss�vel continuar porque n�o foi informada nenhuma invoice a pagar para o processo de Back to Back."###"Aten��o"
            lRet := .F.
            Break
         EndIf
      EndIf
      */

      /*
      ER - 16/09/05. 11:20
      Tratamento para verificar se dois usu�rios est�o tentando incluir um pedido com o mesmo c�digo,
      ao mesmo tempo.
      */
      IF !FreeForUse("EE7",xFilial("EE7")+M->EE7_PEDIDO) 
         lRET:=.F.
         BREAK
      EndIf

      //FJH 25/08/05 Chamada da fun��o que verifica se os campos obrigatorios dos agentes
      //             de comissao vinculados ao processo est�o preenchidos.
      if(!AP106VerAgCom())
         lRet:=.F.
         Break
      Endif

      If ! (lRet:=Obrigatorio(aGets,aTela))
         Break
      EndIf

      If lAlteraStatus .And. !lLibCredAuto
         M->EE7_DTAPCR := AVCtod("")
         IF M->EE7_STATUS <> ST_RV
            M->EE7_STATUS := ST_LC
            DSCSITEE7(.F.) // Atualiza descricao do Status
         Endif
      Endif

      If EasyEntryPoint("EECAP100")    // JPP - 01/08/2005 16:37  - Inclus�o do ponto de entrada
         ExecBlock("EECAP100",.F.,.F.,{ "PE_LINOK"})
      Endif

      // ** Neste ponto o sistema executa a cr�tica dos campos novamente.
      For nInc:=1 TO LEN(aHDEnchoice)
         /* IF aHDEnchoice[nInc] == "EE7_MARCAC" // JPP - 01/08/2005 16:37
            Loop
         Endif */
         If Ascan(aCampoVld,aHDEnchoice[nInc]) > 0  // JPP - 01/08/2005 16:37
            Loop
         EndIf
         If !AP100Crit(aHDEnchoice[nInc],,.T.)
            EasyHelp(STR0131+AVSX3(aHDEnchoice[nInc], AV_TITULO)+STR0132+AVSX3(aHDEnchoice[nInc], 15)+".", STR0059) //"Verifique o campo "###" na pasta "###"Aten��o"
            lRet:=.F.
            break
         EndIf
      Next nInc

      ///////////////////////////////////////////////////
      //Gera array com os itens da grade para cada item//
      //A partir desse ponto a referencia de grade �   //
      //realizada pelo array aGrdRec e n�o mais pelo   //
      //objeto oGrdExp.                                //
      ///////////////////////////////////////////////////
      Set Deleted Off
      WorkIt->(DBGoTop())
      nCont:= 0
      While WorkIt->(!Eof())

         If lGrade
            nCont++
            Ap102GrdArray(nCont)
         EndIf
         WorkIt->(DBSkip())
      EndDo
      Set Deleted On


      nRec := WorkIt->(RecNo())
      WorkIt->(DbGoTop())
      Do While WorkIt->(!Eof())

         //MFR 06/08/2019 OSSME-3759
         //Valida��o para nao permitir salvar valor do item negativo   
         if WorkIt->EE8_PRECOI < 0 .OR. WorkIt->EE8_PRCTOT < 0 .OR. WorkIt->EE8_PRCINC < 0
            if M->EE7_PRECOA = "1" // pre�o aberto sim 
               Easyhelp(STR0249) //"Valor de um ou mais itens negativo, por favor verifique o pre�o informado e o valor do desconto"
            Else
               Easyhelp(STR0250) //"Processo com pre�o fechado resultando em valor negativo de um ou mais itens, por favor verifique o pre�o informado e o valor do desconto, frete, seguro e despesa"          
            EndIf   
            lRet:=.F.
            break
         EndIf


         If lIntegra
            If nOpc == ALTERAR

               ///////////////////////////////////////////////////////////////////////////////////////
               //Verifica se o Item est� Faturado, e com isso bloqueia a altera��o no Pre�o Unit�rio//
               ///////////////////////////////////////////////////////////////////////////////////////
               If WorkIt->EE8_RECNO > 0

                  ///////////////////////////////////////////////////////////////
                  //Verifica a altera��o do Pre�o Unit�rio para itens faturados//
                  ///////////////////////////////////////////////////////////////
                  EE8->(DbGoTo(WorkIt->EE8_RECNO))
                  If WorkIt->EE8_PRECO <> EE8->EE8_PRECO
                     If IsFaturado(EE8->EE8_PEDIDO,EE8->EE8_SEQUEN)
                        EasyHelp(STR0168 + AllTrim(WorkIt->EE8_SEQUEN) + STR0169,STR0059) //"O item "###" possui NFs geradas no Faturamento. Para alterar o Pre�o Unit�rio estorne a NF"###"Aten��o"
                        lRet := .F.
                        Break
                     Else
                        lFaturado := .F.  //DFS - Tratamento para verificar o status do processo
                     EndIf
                  EndIf

                  ////////////////////////////////////////////////////////////////////////////////////////
                  //Verifica a altera��o do Pre�o FOB para itens faturados em Pedidos com Pre�o Fechado.//
                  ////////////////////////////////////////////////////////////////////////////////////////
                  If M->EE7_PRECOA == "2" //Pre�o Fechado
                     If WorkIt->EE8_PRECOI <> EE8->EE8_PRECOI
                        If IsFaturado(EE8->EE8_PEDIDO,EE8->EE8_SEQUEN)
                           EasyHelp(STR0168 + AllTrim(WorkIt->EE8_SEQUEN) + STR0170,STR0059) //"O item "###" possui NFs geradas no Faturamento. Para alterar o Pre�o FOB estorne a NF"###"Aten��o"
                           lRet := .F.
                           Break
                        EndIf
                     EndIf
                  EndIf

               EndIf
            EndIf
         EndIf

         WorkIt->(DbSkip())
      EndDo

      WorkIt->(DbGoTo(nRec))

      // By JPP - 24/06/2005 17:15
      // Se for integra��o e existir desconto - Calcular o valor de desconto de acordo com o calculo da microsiga.
      // If lIntegra  .And. M->EE7_DESCON <> 0 .And. EE7->(FieldPos("EE7_DSCORG")) > 0 nopado por WFS em 13/05/09
      //MV_AVG0052: N�o efetua a confer�ncia do total do pedido EEC x FAT - WFS 13/05/09
      If lIntegra  .And. M->EE7_DESCON <> 0 .And. EE7->(FieldPos("EE7_DSCORG")) > 0 .And. !EasyGParam("MV_AVG0052",, .F.)
         AP106CalcDesc(nOpc,M->EE7_DESCON,.F.)
      EndIf

      /* Valida��es diversas para a rotina de Off-Shore.
         Filial Brasil & Filial de Intermedia��o */

      If (lIntermed .And. (nOpc = ALTERAR .Or. nOpc == INCLUIR .Or. nOpc == APRVCRED))

         Do Case
            Case (AvGetM0Fil() == cFilBr .And. nOpc == INCLUIR .And. !(M->EE7_INTERM $ cSim))
                /* Filial do Brasil para a op��o de inclus�o sem tratamento de off-shore,
                   o sistema verifica se existe o processo lan�ado na filial do exterior */

                If !AP105VldOffShore(nOpc)
                   lRet:=.f.
                   Break
                EndIf

            Case (AvGetM0Fil() == cFilBr .And. M->EE7_INTERM $ cSim) // ** Fil. Br com tratamento de Off-Shore.

                If !lCommodity
                   /* Para processos com tratamento de off-shore e ambiente com a rotina de Commodity
                      desabilitada, o pre�o negociado passa a ser obrigat�rio. */

                   nRec := WorkIt->(RecNo())
                   WorkIt->(DbGoTop())
                   Do While WorkIt->(!Eof())

                      If Empty(WorkIt->EE8_PRENEG)
                         MsgStop(STR0121,STR0024) //"Para processos com tratamentos de off-shore o pre�o negociado � obrigat�rio para todos os produtos."###"Aten��o"
                         WorkIt->(DbGoTo(nRec))
                         lRet:=.f.
                         Break
                      EndIf

                      WorkIt->(DbSkip())
                   EndDo
                   WorkIt->(DbGoTo(nRec))
                EndIf

                nRecEE7 := EE7->(Recno())

                // Realiza as valida��es contra o processo na fil de off-shore.
                EE7->(dBSetOrder(1))
                If EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))

                   /* by jbj - O sistema passar� a n�o recriar o pedido em nenhuma situa��o, a rotina  de  replica��o
                               de dados ir� realizar as altera��es. O sistema ir� apenas chamar a fun��o de valida��o
                               de quantidades de produtos. */

                   lRecriaPed := .f.

                   If !lReplicaDados
                      If EE7->EE7_STATUS <> ST_PC

                        /*  Verifica se na filial de intermedia��o, o processo j� possue embarque e no caso
                            da rotina de Commodity habilitada, se existe algum item com pre�o fixado.

                            Caso alguma das condi��es acima seja atendida o sistema n�o exibe msg de confirma��o
                            para recriar o processo na filial de intermedia��o. */

                         EE8->(DbSetOrder(1))
                         EE8->(DbSeek(cFilEx+EE7->EE7_PEDIDO))
                         Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFilEx .And.;
                                                      EE8->EE8_PEDIDO == EE7->EE7_PEDIDO

                            // ** Verifica se o item faz parte de algum embarque.
                            If (EE8->EE8_SLDINI <> EE8->EE8_SLDATU)
                               lTemEmbarque := .t.
                               Exit
                            EndIf

                            // ** Verifica se o item tem pre�o fixado (Rotina de Commodity Habilitada).
                            If (lCommodity .And. !lTemItemFixado .And. !Empty(EE8->EE8_DTFIX))
                               lTemItemFixado := .t.
                            EndIf

                            EE8->(DbSkip())
                         EndDo

                         /* S� ir� fazer pergunta ao usu�rio para recriar o pedido se o mesmo n�o possuir embarque
                            na filial de off-shore, e no caso da rotina de Commodity habilitada, s� ir� fazer a
                            pergunta se o processo n�o possuir nenhum item fixado na filial de off-shore. */

                         If !lTemEmbarque
                            If ((lCommodity .And. !lTemItemFixado) .Or. !lCommodity) .And. !PossuiQuebra()
                               lRecriaPed := MsgYesNo(STR0070,) // "Recriar o Pedido na Filial do Exterior ?"
                            EndIf
                         EndIf
                      EndIf
                   EndIf

                   If !lRecriaPed .And. !lReplicaDados
                      /* O pedido n�o ser� recriado na filial de off-shore, dessa forma o sistema valida
                         os campos importantes  entre as duas filiais e as quantidades entre os produtos
                         lan�ados nas filiais */

                      // Valida os campos importantes entre as filiais.
                      If !AP105VldOffShore(nOpc)
                         EE7->(DbGoTo(nRecEE7))
                         lRet:=.f.
                         Break
                      EndIf

                      /* by jbj - 11/04/05 - Substitu�do pelas novas valida��es de off-shore.
                      // Valida a quantidade entre os produtos entre as filiais.
                      If !Ap101VldQtde(OC_PE)
                         EE7->(DbGoTo(nRecEE7))
                         lRet:=.f.
                         Break
                      EndIf
                      */
                   EndIf

                   EE7->(DbGoTo(nRecEE7))
                EndIf

            Case (AvGetM0Fil() == cFilEx)

                /* by jbj - 24/02/2005. (11:13).
                   Caso a rotina de replica��o de dados esteja habilitada, neste ponto para a op��o de altera��o,
                   o sistema ir� analisar todos os campos alterados e disponibilizar op��es para que o usu�rio
                   indique onde deseja replicar as altera��es. (Pedidos e Processos de Embarques).*/

                If lReplicaDados
                   If nOpc == ALTERAR .And. (Type("lEE7Auto") <> "L" .Or. !lEE7Auto)/*RMD - 22/12/17*/
                      IF !AxFieldUpdate()
                         Break
                      Endif
                   EndIf
                Else
                   // ** Valida��es para a filial Exterior contra a filial Brasil.
                   If !AP105VldOffShore(nOpc,.f.)
                      lRet:=.f.
                      Break
                   EndIf
                EndIf
         EndCase
      EndIf

      IF EasyGParam("MV_AVG0004") // Conferencia dos Pesos
         If !EECGetPesos(OC_PE)
            lRet:=.f.
            Break
         EndIf
      Endif

      // ** By CAF - 29/04/2002 - 13:59 Corre��o no calculo do preco I (Compatibiliza��o 508)
      IF nOpc = INCLUIR .Or. nOpc = ALTERAR
         AP100PrecoI(.t.)
      EndIf

      // Integra��o com Faturamento (Valida��o)
      IF lIntegra
         IF EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. M->EE7_GPV $ cSIM
            lRet := MC110Integra(nOpc,"VLD")
         EndIf
      Endif

      IF ! lRet
         Break
      Endif

      //AAF 10/09/04 - Valida��o para Back to Back
      If lBACKTO .AND. Len(aColsBtB) > 0
         lRet := AP106Valid("PE_PED_OK")//JPM - 17/01/05 - Atribui��o do retorno da valida��o � lRet
         If !lRet
            BREAK
         EndIf
      EndIf

      // JPM - 19/07/05 - Nova rotina de L/C por item. Valida��o de saldos
      If EECFlags("ITENS_LC")
         If !Ae107ValIt(OC_PE)
            lRet := .f.
            Break
         EndIf
      EndIf

      // by CAF 03/07/2002 - Para corrigir erro de numeracao automatica da funcao GetSXENum
      IF Inclui
         bVldPedido := AVSX3("EE7_PEDIDO",AV_VALID)
         cOldReadVar := __readvar
         __readvar := "M->EE7_PEDIDO"
         lRet := Eval(bVldPedido)
         __readvar := cOldReadVar

         IF ! lRet
            Break
         Endif
      Endif

      /* by jbj - 24/02/2005. (11:13).
         Caso a rotina de replica��o de dados esteja habilitada, neste ponto para a op��o de altera��o,
         o sistema ir� analisar  todos os  campos alterados e disponibilizar op��es para que o usu�rio
         indique onde deseja replicar as altera��es. (embarques e processos de off-shore).*/

      If lReplicaDados
         If !lIntermed .Or. (lIntermed .And. AvGetM0Fil() == cFilBr)
            If nOpc == ALTERAR
               If !AxFieldUpdate()
                  Break
               Endif
            EndIf
         EndIf
      EndIf

      // by CAF 11/02/2002
      IF EasyEntryPoint("EECPEM44")
         lRet := ExecBlock("EECPEM44",.F.,.F.)
         IF ValType(lRet) <> "L"
            lRet := .T.
         Elseif ! lRet
            Break
         Endif
      Endif

      // Integra��o com Faturamento (Grava��o)
      IF lIntegra
         If (EE7->(FIELDPOS("EE7_GPV")) <> 0 .and. M->EE7_GPV $ cNao)  // GFP - 22/01/2014
            M->EE7_STATUS := ST_CL  // Cr�dito Liberado
         EndIf

         /*
            ER - 02/08/2006
            Verifica se o Pedido � Back to Back  ou Remessa, em caso Positivo n�o gera Faturamento.
         */
         IF EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. M->EE7_GPV $ cSIM


            //lRet := (nOpc == 4 .AND. EasyGParam("MV_ALTPED",,"N") == "N") .OR. MC110Integra(nOpc,"GRV")
			//LRS - 04/01/2017
			lRet := (nOpc == 4 .AND. EasyGParam("MV_ALTPED",,"N") == "N" .AND. EE7->EE7_STATUS == ST_FA ) .OR. MC110Integra(nOpc,"GRV")

            //////////////////////////////////////////////////////////////////////////////////////////
            //Verifica se o Pedido de Venda relacionado ao Pedido de Exporta��o dever� ser bloqueado//
            //de acordo com as quantidades utilizadas em Pedidos de Venda relacionados aos embarques//
            //do Pedido de Exporta��o.                                                               //
            //////////////////////////////////////////////////////////////////////////////////////////
            If lRet
               If lIntEmb
                  lRet := FAT3VerBlq(nOpc)
               EndIf
            EndIf

            IF !lRet

               /***********************************
                 Quando integrado com o Faturamento, a referencia ao objeto oGrdExp � substitu�da pela refer�ncia
                 ao objeto oGrade. Quando ocorre uma n�o conformidade na integra��o com o Faturamento,  � necess�rio
                 refazer a refer�ncia para que n�o haja perda nas informa��es editadas pelo usu�rio.
               **********************************************************************************************************/
               If lGrade

                  oGradeAux:= oGrdExp
                  oGrdExp  := MsMatGrade():New('oGrdExp',,"EE8_SLDINI",,"Ap102GrdValid()",,;
                              {{"EE8_SLDINI",NIL,NIL}})
                  Ap102GrdMonta()
                  oGrdExp  := oGradeAux
                  aGrdRec  := {}
               EndIf

               Break
            Endif
         Else
            If (EE7->(FIELDPOS("EE7_GPV")) <> 0 .and. M->EE7_GPV $ cNao) .And. !Empty(M->EE7_PEDFAT)
               If !(lRet := MC110Integra(EXCLUIR,"GRV"))
                  Break
               Else
                  nRecnoIt := WorkIt->(Recno())
                  WorkIt->(DbGoTop())
                  While WorkIt->(!Eof())
                     WorkIt->EE8_FATIT := ""
                     WorkIt->(DbSkip())
                  EndDo
                  WorkIt->(DbGoTo(nRecnoIt))
                  M->EE7_PEDFAT := ""
               EndIf
            EndIf
         ENDIF
      Endif
      
      If Type("lPagtoAnte") == "L" .And. lPagtoAnte     // By JPP - 14/02/2006 - 16:30 - Rotina de pagamento antecipado(adiantamentos) Habilitada.
         If ! AP105VldAdiant() // Se o Valor Total de adiantamento do processo for maior que o valor total do processo.
            If !lEE7Auto 
               If ! AP105AtuAdiant() // Se a tela de estorno do adiantamento do processo n�o for confirmada.
                  lRet := .f.
                  Break
               EndIf
            Else
               EasyHelp(STR0257,STR0022) //"O total de adiantamento do pedido n�o pode ser maior que o total do pedido. Os excessos dever�o ser estornados."###"Aten��o!"      
               lRet := .F.
               Break
            EndIf
         EndIf
      EndIf
     
      Do Case
         Case nOpc == INCLUIR // Inclus�o
             Begin Transaction
                If !lEE7Auto
                   Processa({|| lGravaOk:=AP100Grava(.T.)})
                Else
                   lGravaOk:=AP100Grava(.T.)
                EndIf
                If !lGravaOk
                   //DO WHILE __lSX8
                      //DFS - 06/10/12 - Chamada da fun��o para salvar no logviewer as transa��es
                      ELinkRollBackTran()
                   //ENDDO
                Else

                   While __lSX8
                      ConfirmSX8()
                   Enddo

                   //Processa Gatilhos
                   EvalTrigger()
                EndIf
             End Transaction
             
             If Select("Wk_NfRem") > 0 .And. !lEE7Auto
                Wk_NfRem->(AvZap())
             EndIf
            If lGravaOk .And. lEE7Auto .And. aScan(aAutoCab, {|x| x[1] == "ATUEMB" .And. x[2] =="S" }) > 0
                aEmbTables := AtuEmbArr(nOpc, aAutoCab, aAutoItens, aAutoComp)
                //A rotina de embarque possui works com os mesmos nomes das works da rotina de pedido, por isso faz um backup e fecha as works
                AP104TrataWorks(.T., OC_PE)
                MsAguarde({|| MsExecAuto({|x,y| EECAE100(,x,y)}, nOpc, aEmbTables) }, "Atualizando processo de embarque.")
                AP104TrataWorks(.F., OC_PE)
                If !(lOkEmbAuto := !lMsErroAuto)
                    EasyHelp(STR0232, STR0036) //"Erro na grava��o do embarque autom�tico."###"Aviso"
                EndIf
            EndIf

             If lIntegra //MCF - 11/01/2017
                If EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. M->EE7_GPV $ cSIM
                   If ! MC110Integra(3,"MSG")
                      Break
                   Endif
                EndIf
             Endif

         Case nOpc == ALTERAR .or. nOpc == APRVCRED .or. aRotina[nOpc][4] == APRVPROF // Altera��o

             /* by jbj - 11/04/05 - 17:20 - O sistema ir� executar os tratamentos para acerto das altera��es nas quantidades,
                                            a serem replicadas na filial do exterior. */
             /*
             If lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EE7_INTERM $ cSim .And. !EECFlags("CAFE")  .And.  !lCommodity  .And.  !EECFlags("NEW_RV")  // PLB 04/04/07 - Somente verifica se for Off-Shore sem possibilidade de quebra de item, incluido !lCommodity e !("NEW_RV)
                Ax101SetQtde(OC_PE)
             EndIf
             */

             IF !lAlteraStatus .And. (cStatus == ST_CL .Or. cStatus == ST_PA)

                For i:=1 to Len(aFieldCapa)
                   IF Type("M->"+aFieldCapa[i]) = "U"
                      Loop
                   Endif
                   IF aBuffer[i] != Eval(MemVarBlock(aFieldCapa[i]))
                      lAlteraStatus := .T.
                      Exit
                   Endif
                Next i

             Endif
             IF lAlteraStatus .and. !lLibCredAuto  //AMS - 15/01/2004 �s 15:04. Incluso a condi��o !lLibCredAuto, sendo .T. n�o � alterado o status.
                M->EE7_DTAPCR := AVCtod("")
                IF M->EE7_STATUS <> ST_RV
                   M->EE7_STATUS := ST_LC
                   DSCSITEE7(.F.) // Atualiza descricao do Status
                Endif
             Endif

             If nOpc == ALTERAR
                //If lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EE7_INTERM $ cSim .And. !EECFlags("CAFE")//  .And.  !lCommodity  .And.  !EECFlags("NEW_RV")  // PLB 04/04/07 - Somente verifica se for Off-Shore sem possibilidade de quebra de item, incluido !lCommodity e !("NEW_RV) // By JPP - 03/03/2008 - 17:30
                If lIntermed .And. AvGetM0Fil() == cFilBr .And. M->EE7_INTERM $ cSim .And. !EECFlags("CAFE") .And. !EECFlags("COMMODITY") // By JPP - 03/03/2008 - 17:30 - Esta fun��o n�o pode ser executada quando a rotina de commodity estiver habilitada, devido a quebra de itens por RV.
                   Ax101SetQtde(OC_PE)
                EndIf
             EndIf

             EE7->(dbgoto(nReg))
             If !lEE7Auto
                Processa({|| lGravaOk:=AP100Grava(.F.)})
             Else
                lGravaOk:=AP100Grava(.F.)
             EndIf

             If lIntegra //MCF - 11/01/2017
                If EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. M->EE7_GPV $ cSIM
                   If ! MC110Integra(4,"MSG")
                      Break
                   Endif
                EndIf
             Endif

             //*** Integra��o via Mensagem �nica
             If lIntPrePed
                If aRotina[nOpc][4] == APRVPROF .OR. nOpc == ALTERAR //AAF 19/11/2014 - Enviar altera��o de pedido.
                   If !Empty(EE7->EE7_DTAPPE)
                      lRet := AvStAction("082") //A��o: Aprovacao de Proforma do Pedido de Exporta��o
                      If !lRet
                         WorkIt->(DBGoTop())
                         Break
                      EndIf
                   EndIf
                EndIf
             EndIf

             //***

            If lGravaOk .And. lEE7Auto .And. aScan(aAutoCab, {|x| x[1] == "ATUEMB" .And. X[2] == "S" }) > 0
                aEmbTables := AtuEmbArr(nOpc, aAutoCab, aAutoItens, aAutoComp)
                nOpcEmb := nOpc
                If !((nPosEEC := aScan(aEmbTables, {|x| x[1] == "EEC" })) > 0 .And. EasySeekAuto("EEC", aEmbTables[nPosEEC][2], 1))//Verifica se o embarque existe
                    nOpcEmb := INCLUIR
                EndIf
                //A rotina de embarque possui works com os mesmos nomes das works da rotina de pedido, por isso faz um backup e fecha as works
                AP104TrataWorks(.T., OC_PE)
                MsAguarde({|| MsExecAuto({|x,y| EECAE100(,x,y)}, nOpcEmb, aEmbTables) }, "Atualizando processo de embarque.")
                AP104TrataWorks(.F., OC_PE)
                If !(lOkEmbAuto := !lMsErroAuto)
                    EasyHelp(STR0232, STR0036)//"Erro na grava��o do embarque autom�tico."###"Aviso"
                EndIf
            EndIf
      EndCase

      /* WFS 19/01/2010
      Inclus�o do tratamento de nota fiscal de remessa, para atender
      ao conv�nio ICMS n.� 84 no DOU de 29/09/09.

      Apura as Notas Fiscais de Remessa com os itens do Pedido. */

      If !NFRemFimEsp() .And. AvFlags("FIM_ESPECIFICO_EXP") .And. SELECT("Wk_NfRem") > 0
         AE110LoadNfRem()
      EndIf

      /*
      AMS - 21/03/2005. Atribui��o da variavel lValid como .F. para que o campo EE7_PEDIDO e outros n�o
                        sejam validados na execu��o do oDlg:End().
      */
      lValid := .F.

      If !lEE7Auto
         // O metodo :End() faz valida��o dos dados da Enchoice atraves dos valids do SX3, quando existem
         // informa��es inconsistentes o mesmo n�o fecha a janela.
         oDlg:End()
         IF oDlg:nResult == 2
            // N�o fechou a janela
            Break
         Endif
      EndIf

   End Sequence

   RestOrd(aOrd)

   IF !lRet
      M->EE7_STATUS := cOldStat
      M->EE7_DTAPCR := dOldApCr
      IF lIntPrePed
         M->EE7_DTAPPE := dOldApPr
      ENDIF
   Endif

   dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AP100TTELA()
Parametros  : lTela:= .T. desenha tela
                      .F. refresh gets
              aPos := {Y inicial, X inicial, Y final, X final}
Retorno     : .T.
Objetivos   : Apresentar detalhe com totais
Autor       : Heder M Oliveira
Data/Hora   : 13/01/99 10:00
Revisao     : Cristiano A. Ferreira 24/04/2000 09:37
Revisao     : Guilherme Fernandes Pilan - 12/07/2012
Obs.        :
*/
Function AP100TTELA(lTela,aPos,oPanel2)

   Local lRet:=.T.
   Local cUm_Peso := "Kg"
  

   Private oRodape
   Private nL1,nL2,nTamCol,C1,nC2,nC3,nC4
   //WFS - 17/04/09 - Para verificar se houve altera��o na unidade de medida da capa do processo
   Static cOldUn:= ""

   Begin Sequence

      // *** CAF 17/04/2001 Unidade de Medida do Peso ...
      /*IF Type("M->EE7_UNIDAD") <> "U"
         EE2->(dbSetOrder(1))
         IF EE2->(dbSeek(xFilial()+MC_TUNM+TM_GER+M->EE7_IDIOMA+M->EE7_UNIDAD)) .And.;
              !Empty(EE2->EE2_DESCMA)

            cUm_Peso := AllTrim(EE2->EE2_DESCMA)
         Elseif !Empty(M->EE7_UNIDAD)
            cUm_Peso := M->EE7_UNIDAD
         Endif
      Endif*/ //comentado por WFS - n�o � poss�vel fazer convers�o da unidade de medida considerando a descri��o da unidade  no idioma...
      cUm_Peso := M->EE7_UNIDAD

      //WFS - 17/04/09 ---
      /* Atualiza��o dos pesos na capa do pedido de exporta��o sempre que houver altera��o da unidade
         na capa do processo.*/
      If lTela .And. !Empty(M->EE7_UNIDAD)
         cOldUn:= cUm_Peso
      EndIf

      If !lTela .And. Upper(cOldUn) <> Upper(cUm_Peso)
         If AvTransUnid(IIF(!Empty(Upper(cOldUn)),Upper(cOldUn),"KG"), IIF(!Empty(Upper(cUm_Peso)),Upper(cUm_Peso),"KG"), , M->EE7_PESBRU, .T.) == Nil
            EasyHelp(STR0184 + AllTrim(cOldUn) + STR0185 + AllTrim(cUm_Peso) + STR0196 + ENTER + ; //STR0184	"A convers�o de " //STR0185	" para " // STR0196 "n�o est� cadastrada"
                    STR0186, STR0059) //Aten��o //STR0186	"Acesse Atualiza��es/ Tabelas Siscomex para realizar o cadastro." //Aten��o
            M->EE7_UNIDAD:= cOldUn
            Break
         Else
            M->EE7_PESBRU:= AvTransUnid(IIF(!Empty(Upper(cOldUn)),Upper(cOldUn),"KG"), IIF(!Empty(Upper(cUm_Peso)),Upper(cUm_Peso),'KG'), , M->EE7_PESBRU, .F.)
            M->EE7_PESLIQ:= AvTransUnid(IIF(!Empty(Upper(cOldUn)),Upper(cOldUn),"KG"), IIF(!Empty(Upper(cUm_Peso)),Upper(cUm_Peso),"KG"), , M->EE7_PESLIQ, .F.)
            cOldUn:= cUm_Peso
         EndIf
      EndIf
      // ---
      // *** CAF 17/04/2001 Unidade de Medida do Peso ...
      nTotPedBr := M->EE7_TOTPED + AE102CalcAg()
      // MFR 12/04/2020 OSSME-5384
      // Ponto de entrada que permite manipular as vari�veis de totais do rodap�   
      If(EasyEntryPoint("EECAP100"),Execblock("EECAP100",.F.,.F.,"ANTES_REFRESH_RODAPE"),)
      IF !lEE7Auto .And. lTela

         nL1:= 4//aPos[1]+6 /* 126 */
         nL2:= nL1+9 /* 135*/
         nL3:= nL2+9     // GFP - 12/07/2012 - Ajuste para exibi��o no modo classico

         nTamCol := (aPos[4]-aPos[2])/6  // GFP - 11/04/2014

         //18.mai.2009 - UE719061 - Corre��o do tamanho dos objetos na tela - HFD
         nC1:=aPos[2]+6 /* 02 */
         nC2:=nC1+nTamCol /* 50 */
         nC3:=nC2+nTamCol /* 120 */
         nC4:=nC3+nTamCol /* 162 */
         nC5:=nC4+nTamCol  // GFP - 11/04/2014
         nC6:=nC5+nTamCol  // GFP - 11/04/2014

         //@ 120,01 TO 143,310 PIXEL
        // @ aPos[1],aPos[2]+2 TO aPos[3],aPos[4]-2 PIXEL OF oPanel2//oRodape

         //ER - 31/05/2007
         If EasyEntryPoint("EECAP100")
            ExecBlock("EECAP100",.F.,.F.,{"ROD_CAPA_PED",aPos})
         EndIf

         @ nL1,nC1 SAY STR0028 PIXEL SIZE 50,7  OF oPanel2//oRodape							 // "Total Itens"
         @ nL1,nC3 SAY oSayTotFOB VAR STR0213+M->EE7_MOEDA PIXEL SIZE 50,7  OF oPanel2   //"Total FOB "
         @ nL1,nC5 SAY oSayPesLiq VAR STR0029+cUm_Peso PIXEL SIZE 50,7  OF oPanel2//oRodape   // "Peso Liquido"

         @ nL2,nC1 SAY STR0030+M->EE7_MOEDA PIXEL SIZE 50,7  OF oPanel2//oRodape			     // "Total Pedido"
         @ nL2,nC3 SAY oSayTotCom VAR STR0214+M->EE7_MOEDA PIXEL SIZE 50,7  OF oPanel2   //"Total Comiss�o "         
         @ nL2,nC5 SAY oSayPesBru VAR STR0031+cUm_Peso PIXEL SIZE 50,7  OF oPanel2//oRodape   // "Peso Bruto"

         @ nL3,nC1 SAY oSayTotBru VAR STR0244+M->EE7_MOEDA PIXEL SIZE 60,7  OF oPanel2   //"Total Pedido (Bruto)"         
         @ nL3,nC3 SAY oSayTotLiq VAR STR0215+M->EE7_MOEDA PIXEL SIZE 50,7  OF oPanel2   //"Total Liquido "   

         @ nL1,nC2 MSGET oItens   VAR M->EE7_TOTITE   PICTURE cITEPIC WHEN .F. SIZE 50,6 RIGHT PIXEL OF oPanel2//oRodape      
         @ nL2,nC2 MSGET oPedido  VAR M->EE7_TOTPED   PICTURE cTPEPIC WHEN .F. SIZE 50,6 RIGHT PIXEL OF oPanel2//oRodape        
         @ nL3,nC2 MSGET oTotPedBr VAR nTotPedBr  PICTURE cTPEPIC WHEN .F. SIZE 50,6 RIGHT PIXEL OF oPanel2//oRodape  

         @ nL1,nC4 MSGET oTotFOB  VAR M->EE7_VLFOB   PICTURE cTPEPIC WHEN .F. SIZE 50,6 RIGHT PIXEL OF oPanel2
         @ nL2,nC4 MSGET oTotCom  VAR M->EE7_VALCOM   PICTURE cTPEPIC WHEN .F. SIZE 50,6 RIGHT PIXEL OF oPanel2
         @ nL3,nC4 MSGET oTotLiq  VAR M->EE7_TOTLIQ   PICTURE cTPEPIC WHEN .F. SIZE 50,6 RIGHT PIXEL OF oPanel2  

         @ nL1,nC6 MSGET oLiquido VAR M->EE7_PESLIQ   PICTURE cPLIPIC WHEN .F. SIZE 50,6 RIGHT PIXEL OF oPanel2//oRodape
         @ nL2,nC6 MSGET oBruto   VAR M->EE7_PESBRU   PICTURE cPBRPIC WHEN .F. SIZE 50,6 RIGHT PIXEL OF oPanel2//oRodape                
         

      ElseIf !lEE7Auto
         oSayPesLiq:SetText(STR0029+cUm_Peso)
         oSayPesBru:SetText(STR0031+cUm_Peso)
         oItens:Refresh()
         oLiquido:Refresh()
         oPedido:Refresh()
         oBruto:Refresh()
         oTotPedBr:Refresh()
         oSayPesLiq:Refresh()
         oSayPesBru:Refresh()
      EndIf
   End Sequence

Return lRet

/*
Funcao      : AP100DetTela
Parametros  : lTela:= .T. desenha tela
                      .F. refresh gets
              aPos := {Y inicial, X inicial, Y final, X final}
Retorno     : .T.
Objetivos   : Apresentar detalhe com totais
Autor       : Cristiano A. Ferreira
Data/Hora   : 28/07/99 11:43
Revisao     : Cristiano A. Ferreira 24/04/2000 11:37
Obs.        :
*/
Function AP100DetTela(lTela,aPos,nTipo,oPanel2)

   Local lRet:=.T.
//MFR 08/06/2021 OSSME-5869 Calculo efetuado corretamente na rotina EECPPE07
//   Local nPRCTOI := M->EE8_PRCINC // by CAF 01/03/2000 11:04 (M->EE8_PRECOI*M->EE8_SLDINI)
   Local lReposic := Type("SB1->B1_REPOSIC") <> "U"
   Local cUm_Peso := "Kg"

   Private oRodape
   Private nL1,nL2,nTamCol,C1,nC2,nC3,nC4
   
   If Type("lConsolItem") <> "L"
      lConsolItem := .f.
   EndIf

   Begin Sequence

      If lConvUnid
         EE2->(dbSetOrder(1))
         IF EE2->(dbSeek(xFilial()+MC_TUNM+TM_GER+M->EE7_IDIOMA+M->EE8_UNPES)) .And.;
              !Empty(EE2->EE2_DESCMA)

            cUm_Peso := AllTrim(EE2->EE2_DESCMA)
         Elseif !Empty(M->EE8_UNPES)
            cUm_Peso := M->EE8_UNPES
         EndIf
      Else
         IF Type("M->EE7_UNIDAD") <> "U"
            EE2->(dbSetOrder(1))
            IF EE2->(dbSeek(xFilial()+MC_TUNM+TM_GER+M->EE7_IDIOMA+M->EE7_UNIDAD)) .And.;
                 !Empty(EE2->EE2_DESCMA)

               cUm_Peso := AllTrim(EE2->EE2_DESCMA)
            Elseif !Empty(M->EE7_UNIDAD)
               cUm_Peso := M->EE7_UNIDAD
            Endif
         Endif
      EndIf

      // GFP - 27/05/2013 - Ajuste para exibi��o no modo classico
      IF lTela
         nL1:= 4//aPos[1]+6 /* 126 */
         nL2:= nL1+9 /* 135*/

         nTamCol := (aPos[4]-aPos[2])/4

         nC1:=aPos[2]+6//+1 /* 02 */
         nC2:=nC1+nTamCol /* 50 */
         nC3:=nC2+nTamCol /* 120 */
         nC4:=nC3+nTamCol /* 162 */

         //@ 120,01 TO 143,310 PIXEL
         //@ aPos[1]-13,aPos[2] TO aPos[3]-13,aPos[4] PIXEL OF oPanel2//oRodape //LRS - 24/09/2015

         //ER - 31/05/2007
         If EasyEntryPoint("EECAP100")
            ExecBlock("EECAP100",.F.,.F.,{"ROD_ITENS_PED",aPos})
         EndIf

         // *** CAF 17/04/2001 Unidade de Medida do Peso ...
         @ nL1,nC1 SAY STR0032+M->EE7_MOEDA PIXEL SIZE 50,7 OF oPanel2//oRodape
         @ nL1,nC3 SAY oSayPsLiq VAR STR0029+cUm_Peso PIXEL SIZE 50,7 OF oPanel2//oRodape //"Peso Liquido "
         @ nL2,nC1 SAY STR0033+M->EE7_MOEDA PIXEL SIZE 50,7 OF oPanel2//oRodape //"Total Incoterm "
         @ nL2,nC3 SAY oSayPsBru VAR STR0031+cUm_Peso PIXEL SIZE 50,7 OF oPanel2//oRodape //"Peso Bruto "
         //MFR 06/02/2021         @ nL1,nC2 MSGET oGetPrecoI VAR nPRCTOI       PICTURE EECPreco("EE8_PRCINC", AV_PICTURE) WHEN .F.     SIZE 52,6 RIGHT PIXEL OF oPanel2//oRodape
         @ nL1,nC2 MSGET oGetPrecoI VAR M->EE8_PRCINC PICTURE EECPreco("EE8_PRCINC", AV_PICTURE) WHEN .F.     SIZE 52,6 RIGHT PIXEL OF oPanel2//oRodape
         @ nL1,nC4 MSGET oGetPsLiq  VAR M->EE8_PSLQTO PICTURE AVSX3("EE8_PSLQTO",6) WHEN (nTipo == ALT_DET .Or. nTipo == INC_DET) .And. lLibPes SIZE 52,6 RIGHT PIXEL VALID (Positivo() .And. AllwaysTrue(AvExecGat("EE8_PSLQTO"))) OF oPanel2//oRodape
         @ nL2,nC2 MSGET oGetPreco  VAR M->EE8_PRCTOT PICTURE EECPreco("EE8_PRCTOT", AV_PICTURE) WHEN .F.     SIZE 52,6 RIGHT PIXEL OF oPanel2//oRodape
         @ nL2,nC4 MSGET oGetPsBru  VAR M->EE8_PSBRTO PICTURE AVSX3("EE8_PSBRTO",6) WHEN (nTipo == ALT_DET .Or. nTipo == INC_DET) .And. lLibPes SIZE 52,6 RIGHT PIXEL VALID (Positivo() .And. AllwaysTrue(AvExecGat("EE8_PSBRTO"))) OF oPanel2//oRodape

         IF lReposic
            IF ! GetNewPar("MV_AVG0009",.F.)
               IF Posicione("SB1",1,xFilial("SB1")+M->EE8_COD_I,"B1_REPOSIC") $ cSim
                  lLibPes := .t.
               Else
                  lLibPes := .f.
               ENDIF
            Endif
         Endif
      Else
         If(Type("oSayPsLiq") =="O" ,oSayPsLiq:SetText(STR0029+cUm_Peso),"")
         If(Type("oSayPsBru") =="O" ,oSayPsBru:SetText(STR0031+cUm_Peso),"")
         If(Type("oGetPrecoI")=="O" ,oGetPrecoI:Refresh(),"")
         If(Type("oGetPsLiq") =="O" ,oGetPsLiq:Refresh() ,"")
         If(Type("oGetPreco") =="O" ,oGetPreco:Refresh() ,"")
         If(Type("oGetPsBru") =="O" ,oGetPsBru:Refresh() ,"") 
         If(Type("oSayPsLiq") =="O" ,oSayPsLiq:Refresh() ,"")
         If(Type("oSayPsBru") =="O" ,oSayPsBru:Refresh() ,"")
      EndIf

   End Sequence

Return lRet

/*
Funcao      : AvExecGat
Parametros  : cCpo - Nome do Campo
Retorno     : Nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 19/02/2002 13:41
Revisao     :
Obs.        :
*/
Function AvExecGat(cCpo)

Begin Sequence
   IF ExistTrigger(cCpo)
      RunTrigger(1,NIL,NIL,cCpo)
   Endif
End Sequence

Return NIL

/*
Funcao      : AP100Embalagens
Parametros  : nOpc := 2 - Visualizacao
                      3 - Inclusao
                      4 - Alteracao
                      5 - Exclusao
Retorno     : nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/07/99 15:41
Revisao     :
Obs.        :
*/
/*
FUNCTION AP100Embalagens( nOpc )

LOCAL oDlg, oMark
LOCAL aEmbCpos
LOCAL bOk, bCancel
LOCAL nSelect := Select()
local oGetPedido, oGetEmb

Private nOpcB := 0

// Gera campos para a MSSELECT ...
aEmbCpos := ArrayBrowse("EEK","WorkEm")

WorkEm->(dbSeek(M->EE7_PEDIDO+M->EE8_SEQUEN))

dbSelectArea("WorkEm")

SET FILTER TO (EEK_PEDIDO+EEK_SEQUEN == M->EE7_PEDIDO+M->EE8_SEQUEN)

dbGoTop()

While .T.
   nOpcB := 0

   DEFINE MSDIALOG oDlg TITLE "Embalagens do Processo "+M->EE7_PEDIDO ;
          FROM 9,0 TO 28,70 OF oMainWnd

   @ 1.4, .8 SAY "Pedido Export."
   @ 1.4, 08 MSGET oGetPedido VAR M->EE7_PEDIDO SIZE 50,8 OF oDlg WHEN .F.

   @ 2.2, .8 SAY "Embalagem"
   @ 2.2, 08 MSGET oGetEmb VAR M->EE8_EMBAL1 SIZE 50, 8 OF oDlg WHEN .F.

   oGetEmb:Disable()
   oGetPedido:Disable()

   oMark:= MSSELECT():New("WorkEm",,,aEmbCpos,,,{40,4,140,261})
   oMark:bAval := {|| nOpcB := 2, oDlg:End() }

   bOk     := {|| nOpcB := 1, oDlg:End() }
   bCancel := {|| nOpcB := 0, oDlg:End() }

   ACTIVATE MSDIALOG oDlg ON INIT AP102Bar(nOpc,oDlg,bOk,bCancel)

   IF nOpcB == 2
      AP100EmbQtde(nOpc)
      Loop
   Endif

   Exit
Enddo

dbSelectArea("WorkEm")
SET FILTER TO
dbGoTop()

Select(nSelect)

Return NIL
*/

/*
Funcao      : AP100EmbQtde
Parametros  :
Retorno     : nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/07/99 15:41
Revisao     :
Obs.        :
*/
/*
FUNCTION AP100EmbQtde(nOpc)

   Local oDlg,nInc,nOpcao:=0
   Local cNewTit := "Embalagens do Processo "+ALLTRIM(M->EE7_PEDIDO)+" da Embalagem "+M->EE8_EMBAL1
   Local cField, bField

   Private aTela[0][0],aGets[0]

   Begin Sequence

      IF WorkEm->(Bof() .And. Eof())
         MsgInfo("N�o existem registros para a altera��o !","Aten��o")
         Break
      Elseif WorkEm->(Bof() .Or. Eof())
         MsgInfo("N�o h� registro selecionado para a altera��o !","Aten��o")
         IF WorkEm->(Bof())
            WorkEm->(dbGoTop())
         Else
            WorkEm->(dbGoBottom())
         Endif
         Break
      Endif

      For nInc := 1 TO WorkEm->(FCount())
         M->&(WorkEm->(FIELDNAME(nInc))) := WorkEm->(FIELDGET(nInc))
      Next nInc

      DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      EnChoice("EEK", , 3, , , , , aPos2,IF(STR(nOpc,1)$'2,5',{},{"EEK_QTDE"}) , 3)

      ACTIVATE MSDIALOG oDlg;
         ON INIT (EnchoiceBar(oDlg,{||nOpcao:=1,IF(Obrigatorio(aGets,aTela),oDlg:End(),nOpcao:=0)},{||oDlg:End()}))

      IF nOpcao == 1
         For nInc := 1 To WorkEm->(FCount())
            cField := WorkEm->(FieldName(nInc))
            bField := MemVarBlock(cField)

            IF ValType(bField) == "B"
               WorkEm->(FieldPut(nInc,Eval(bField)))
            Endif
         Next
      Endif

   End Sequence


Return NIL
*/

/*
Funcao      : AP100WkrEmb
Parametros  :
Retorno     : nenhum
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/07/99 15:41
Revisao     :
Obs.        :
*/
Function AP100WkEmb(cPedido,cSequen,cEmb)

Local nRecWork := WorkEm->(RecNo())
Local aOrd := SaveOrd("EEK")
Local cEmbOld

Begin Sequence

   IF ! Inclui .And. WorkEm->(EasyReccount("WorkEm")) == 0
      // Alteracao/Visual/Exclusao, primeira vez ...

      // by CAF 21/03/2000
      // Para garantir que so entrara aqui uma vez, pois
      // na segunda vez o lastrec serah diferente de zero
      //WorkEm->(dbAppend())
      //WorkEm->(dbDelete())
      //WorkEm->(dbGoTop())
      // ***

      EEK->(dbSetOrder(2))
      EEK->(dbSeek(xFilial()+OC_PE+cPedido))

      While ! EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
            EEK->EEK_TIPO == OC_PE .And. EEK->EEK_PEDIDO == cPedido

         WorkEm->(dbAppend())

         AvReplace("EEK","WorkEm")

         EEK->(dbSkip())
      Enddo

      Break
   Endif

   IF WorkEm->(EasyReccount("WorkEm")) != 0
      IF WorkEm->(dbSeek(cPedido+cSequen)) .And.;
         WorkEm->EEK_CODIGO != cEmb

         // Usuario alterou a 1� embalagem ...
         cEmbOld := WorkEm->EEK_CODIGO
         WorkEm->(dbSeek(cPedido+cSequen+cEmbOld))
         While ! WorkEm->(Eof()) .And. WorkEm->(EEK_PEDIDO+EEK_SEQUEN+EEK_CODIGO) ==;
                                       cPedido+cSequen+cEmbOld
            WorkEm->(dbDelete())
            WorkEm->(dbSkip())
         Enddo
         WorkEm->(dbGoTop())
      Else
         WorkEm->(dbGoTo(nRecWork))
      Endif
   Endif

   IF ! WorkEm->(dbSeek(cPedido+cSequen))
      EEK->(dbSetOrder(1))
      EEK->(dbSeek(xFilial()+OC_EMBA+cEmb))

      While ! EEK->(Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
            EEK->EEK_TIPO == OC_EMBA .And. EEK->EEK_CODIGO == cEmb

         WorkEm->(dbAppend())

         AvReplace("EEK","WorkEm")

         WorkEm->EEK_PEDIDO := cPedido
         WorkEm->EEK_SEQUEN := cSequen

         EEK->(dbSkip())
      Enddo

      // ******************************************************************** \\
      // Colocar chamada do rdmake que calcula a quantidade de embalagens ...
      // ******************************************************************** \\
      //EECPPE07("EMBALA") //NOPADO - THTS - 25/10/2017 - Quantidade Ja vem preenchido do AvReplace (Estava dando erro no dbseek dentro da funcao, pois variaveis da EE8 nao estao na memoria)
   Endif
End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : AP100GrvEmb
Parametros  : nenhum
Retorno     : NIL
Objetivos   : Grava informacoes do Work de embalagens no EEK
Autor       : Cristiano A. Ferreira
Data/Hora   : 17/07/99 10:02
Revisao     :
Obs.        :
*/
Static FUNCTION AP100GrvEmb

LOCAL i
LOCAL nPos, cField

Begin Sequence

   IF WorkEm->(EasyReccount("WorkEm")) == 0 // Nao houve alteracoes no WorkEm ...
      Break
   Endif

   WorkEm->(dbSeek(M->EE7_PEDIDO+EE8->EE8_SEQUEN))

   While ! WorkEm->(Eof()) .And. WorkEm->(EEK_PEDIDO+EEK_SEQUEN) == ;
                                 M->EE7_PEDIDO+EE8->EE8_SEQUEN

      EEK->(RecLock("EEK",.T.))

      For i:=1 To EEK->(FCount())


         cField := EEK->(FieldName(i))
         nPos   := WorkEm->(FieldPos(cField))

         IF nPos > 0
            EEK->(FieldPut(i,WorkEm->(FieldGet(nPos))))
         Endif
      Next i

      EEK->EEK_TIPO   := OC_PE
      EEK->EEK_PEDIDO := M->EE7_PEDIDO
      EEK->EEK_SEQUEN := EE8->EE8_SEQUEN
      EEK->EEK_FILIAL := xFilial("EEK")  // By JPP - 12/04/2006 - 11:00

      EEK->(MSUNLOCK())

      WorkEm->(dbSkip())
   Enddo
End Sequence

Return NIL

/*
Funcao      : AP100Volume
Parametros  : nenhum
Retorno     : nenhum
Objetivos   : Apresentar os volumes do pedido
Autor       : Cristiano A. Ferreira
Data/Hora   : 20/07/99 10:10
Revisao     :
Obs.        :
*/
Function AP100Volume

Local nRecIt  := WorkIt->(RecNo())

Local cSequen, i
Local oDlg, oLbx, oMsBtn, oFont

Local aEmb    := {}
Local aLista  := {}

Local aOrd := SaveOrd({"EEK","EE5"})

Local nQtde, cEmbalagem, nPenultimo
Local nQtd_Vol, nVolume

EEK->(dbSetOrder(2))
EE5->(dbSetOrder(1))

Begin Sequence

   IF WorkIt->(Eof() .And. Bof())
      HELP(" ",1,"AVG000630") //MsgInfo("N�o h� itens cadastrados !","Aviso")
      Break
   Endif

   IF ! Empty(M->EE7_EMBAFI)
      IF M->EE7_CALCEM == "1"
         // Calculo por Volume
         IF Empty(M->EE7_CUBAGE)
            IF ! EE5->(dbSeek(xFilial()+M->EE7_EMBAFI))
               EasyHelp(STR0034+M->EE7_EMBAFI+STR0035,STR0036) //"Volume "###" n�o foi encotrado no Cadastro de Embalagens !"###"Aviso"
               Break
            Endif

            IF Empty(EE5->EE5_HALT*EE5->EE5_LLARG*EE5->EE5_CCOM)
               HELP(" ",1,"AVG0000631") //MsgInfo("Cubagem do Volume n�o foi preenchido !","Aviso")
               Break
            Endif
         Endif
      Endif
   Else
      // Forcar calculo por qtde qdo o volume da capa estiver vazio
      M->EE7_CALCEM := "2" // Calculo por Qtde
   Endif

   WorkIt->(dbGoTop())

   While ! WorkIt->(Eof())


      cSequen := WorkIt->EE8_SEQUEN

      // *** Posiciona o Work de Embalagens no ultimo item de uma
      // *** determinada sequencia do pedido atual.
      // caf 21/01/2000 11:24 IF WorkEm->(dbSeek(M->EE7_PEDIDO+cSequen,,.T.))
      IF WorkEm->(AVSeekLast(M->EE7_PEDIDO+cSequen))
         IF M->EE7_CALCEM == "2"
            IF ! Empty(M->EE7_EMBAFI)
               // *** Calculo por Quantidade
               IF WorkEm->EEK_EMB != M->EE7_EMBAFI
                  IF ! EECGetVol(StrZero(Val(WorkEm->EEK_SEQ)+1,2),WorkIt->EE8_COD_I,M->EE7_EMBAFI,WorkEm->EEK_QTDE,M->EE7_PEDIDO,WorkIt->EE8_SEQUEN,WorkIt->EE8_EMBAL1,OC_EM)
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
               cEmbalagem := WorkIt->EE8_EMBAL1
               nQtde      := WorkIt->EE8_QTDEM1
            Endif

            nVolume := nQtde/nVolume
         Else
            // *** Calculo por Volume
            IF WorkEm->EEK_EMB == EE7_EMBAFI
               WorkEm->(dbSkip(-1))
            Endif

            IF ! WorkEm->(Bof()) .And. WorkEm->EEK_SEQUEN == cSequen
               cEmbalagem := WorkEm->EEK_EMB
               nQtde      := WorkEm->EEK_QTDE
            Else
               cEmbalagem := WorkIt->EE8_EMBAL1
               nQtde      := WorkIt->EE8_QTDEM1
            Endif
         Endif
      Else
         // A embalagem digitado no item ja e a embalagem final
         cEmbalagem := WorkIt->EE8_EMBAL1
         nQtde      := WorkIt->EE8_QTDEM1

         IF M->EE7_CALCEM == "2" // Calculo por Qtde
            IF !Empty(M->EE7_EMBAFI)
               // Calculo por Quantidade
               IF ! EECGetVol(StrZero(Val(WorkEm->EEK_SEQ)+1,2),WorkIt->EE8_COD_I,M->EE7_EMBAFI,WorkEm->EEK_QTDE,M->EE7_PEDIDO,WorkIt->EE8_SEQUEN,WorkIt->EE8_EMBAL1,OC_EM)
                  Break
               Endif

               nVolume := nQtde/WorkEm->EEK_QTDE
            Else
               nVolume := WorkIt->EE8_QE
            Endif
         Endif
      Endif

      IF ! EE5->(dbSeek(xFilial()+cEmbalagem))
         MsgStop(STR0037+AllTrim(cEmbalagem)+STR0038,STR0024) //"Erro de integridade, embalagem "###" n�o encontrada no cadastro de embalagens !"###"Aten��o"
         WorkIt->(dbSkip())
         Loop
      Endif

      IF M->EE7_CALCEM == "2"
         // Calculo por Quantidade
         nQtd_Vol := nVolume
      Else
         // Calculo por Volume
         nQtd_Vol := EE5->(EE5_HALT*EE5_LLARG*EE5_CCOM)

         IF Empty(nQtd_Vol)
            EasyHelp(STR0039+AllTrim(cEmbalagem)+STR0040,STR0036) //"Cubagem da Embalagem "###" n�o foi preenchida !"###"Aviso"
            Break
         Endif
      Endif

      aAdd(aEmb,{EE5->EE5_CODEMB,AllTrim(EE5->EE5_DESC),nQtde,EE5->EE5_PESO,nQtd_Vol,WorkIt->EE8_SEQUEN,WorkIt->EE8_SLDINI,WorkIt->EE8_COD_I})

      WorkIt->(dbSkip())
   Enddo

   IF Empty(aEmb)
      Break
   Endif

   // *** Gera aLista, baseado em aEmb ...
   EECBuildList(aLista,aEmb,M->EE7_EMBAFI,M->EE7_CALCEM,M->EE7_PEDIDO,OC_PE,.F.,M->EE7_CUBAGE)

   If Len(aLista) > 0

      DEFINE FONT oFont NAME "Courier New" SIZE 0,-12

      DEFINE MSDIALOG oDlg TITLE STR0008 FROM 7,3 TO 20,75 OF oMainWnd //"Volumes"

         @ 0.5,0.6 LISTBOX oLbx ITEMS aLista SIZE 275,70 OF oDlg FONT oFont

         DEFINE SBUTTON oMsBtn FROM 80,253 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg

         // *** Disabilita o Cancel (x) da Dialog ...
         oDlg:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
         // ***

         oDlg:bStart := {|| oMsBtn:SetFocus() }

      ACTIVATE MSDIALOG oDlg CENTERED

      WorkIt->(dbGoTo(nRecIt))

      oFont:End()

   EndIf

End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : EECGetVol
Parametros  : nenhum
Retorno     : .T./.F.
Objetivos   : Cadastrar o Container na Lista de Embalagens
Autor       : Cristiano A. Ferreira
Data/Hora   : 16/09/1999 15:45
Revisao     :
Obs.        :
*/
Function EECGetVol(cSeq,cCod,cVolume,nPenultimo,cPedido,cSequen,cEmb,cOrigem)

Local oDlg, bOk, bCancel, nOpcA := 0
Local nQtde := 0
Local nY := 0.5
Local aOrd := SaveOrd("EEK",3)

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE STR0041+AllTrim(cCod)+STR0042+AllTrim(cSequen) FROM 10,12 TO 25,70 OF oMainWnd //"Embalagem Final do Item "###" - Sequ�ncia "

    oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @ nY, 1 SAY STR0043 OF oPanel SIZE 35,9 //"Sequ�ncia"
    @ nY, 7 MSGET cSeq OF oPanel WHEN .F. SIZE 11,8

    @ nY+=1.1, 1 SAY STR0044 OF oPanel SIZE 35,9 //"Embalagem"
    @ nY, 7 MSGET cVolume OF oPanel WHEN .F. SIZE 60,8

    @ nY+=1.1, 1 SAY STR0045 OF oPanel SIZE 35,9 //"Quantidade"
    @ nY, 7 MSGET nQtde OF oPanel VALID (NaoVazio(nQtde) .And. Positivo(nQtde)) SIZE 25,9 RIGHT

    bOk := {|| nOpcA := 1, oDlg:End() }
    bCancel := {|| oDlg:End() }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)

   IF nOpcA == 0
      Break
   Endif

   WorkEm->(dbAppend())
   WorkEm->EEK_SEQ  := cSeq
   WorkEm->EEK_EMB  := cVolume
   WorkEm->EEK_QTDE := nPenultimo/nQtde

   WorkEm->EEK_PEDIDO := cPedido
   WorkEm->EEK_SEQUEN := cSequen
   WorkEm->EEK_CODIGO := cEmb

   /*
   IF ! EEK->(dbSeek(xFilial()+OC_EMBA+cEmb+cVolume))
      EEK->(RecLock("EEK",.T.))
      AvReplace("WorkEm","EEK")
      EEK->EEK_PEDIDO := CriaVar("EEK_PEDIDO")
      EEK->EEK_SEQUEN := CriaVar("EEK_SEQUEN")
      EEK->EEK_QTDE   := nQtde
      EEK->EEK_TIPO   := OC_EMBA
      EEK->(MsUnlock())
   Endif */
End Sequence

RestOrd(aOrd)

Return (nOpcA == 1)

/*
Funcao      : EECBuildList(aLista,aEmb,cVolume,cTipoCalc,cPedido)
Parametros  : aLista  := Array que sera usado no list box
              aEmb[x,1] := Codigo da Embalagem
              aEmb[x,2] := Descricao da Embalagem
              aEmb[x,3] := Qtde da Embalagem
              aEmb[x,4] := Peso da Embalagem
              aEmb[x,5] := Cubagem/Qtde do Container
              aEmb[x,6] := Sequencia
              aEmb[x,7] := Qtde do Item
              aEmb[x,8] := Codigo do Item
Retorno     : nenhum
Objetivos   : Montar um Array para ser apresentado no list box
Autor       : Cristiano A. Ferreira
Data/Hora   : 20/07/99 17:00
Revisao     :
Obs.        :
*/

#xTranslate AddLista() => ;
       aEval(aContainer,bItem) ;;
       aSize(aContainer,0) ;;
       aSize(aItens,0)

Function EECBuildList(aLista,aEmb,cVolume,cTipoCalc,cPedido,cOrigem,lGravar,nCubagem)

// ***** Code Block's chamados pelo AddLista ***** \\
Local bItem   := {|x,i| Eval(bContador,i), AddEmb(aLista,cPedido,lGravar,aItens,nContainer-1,aRelacao,cOrigem,i==1,x[1])}
Local bContador := {|j| if(j==1,nContainer++,) }
// ***** /////////////////////////////////// ***** \\
Local aContainer := {}  // Array com as embalagens para um Container
Local nContainer := 0   // Nro. de Container's

Local nVolume := 0       // Cubagem do container

Local aSobra := {}
Local nSobrou := 0, nCnts:=0

Local y, i, nTotCont
Local bQtdCnt, nEmbUsada := 0
Local nQtdeIt := 0, nQtdIt_Cnt, nFatPenul, nInd:=0

Local aRelacao := {}
Local aItens := {}

Private lZero := .F.

Begin Sequence
   lCubPrim := .F.

   IF lGravar
      M->EEC_TOTVOL := 0
   Endif

   IF ValType(aEmb) != "A" .Or. Len(aEmb) == 0 .Or. Valtype(aEmb[1]) != "A"
      Break
   Endif

   IF cTipoCalc == "2"
      // Quantidade
      bQtdCnt := {||aEmb[i][5]}
   Else
      // Volume
      bQtdCnt := {|| Int(nVolume/aEmb[i][5]) }

      IF Empty(nCubagem)
         IF EE5->(dbSeek(xFilial()+cVolume))
            nVolume := EE5->(EE5_HALT*EE5_CCOM*EE5_LLARG)
         Else
            Break
         Endif
      Else
         nVolume := nCubagem
      Endif
   Endif

   // Classifica o Array aEmb, por ordem de Produto+Sequencia ...
   aEmb := aSort(aEmb,,,{|x,y| x[8]+x[6] < y[8]+y[6]})

   IF ! Empty(cVolume)
      aAdd(aLista,STR0046+cVolume) //"Volume: "

      IF lGravar
         // Inclui registro no EEO com Seq = 0,
         // o qual representa o Volume do Embarque
         GravaEEO(cPedido,TIPO_EMB,0,0,cVolume,0,,,len(aRelacao))
      Endif
   Endif

   nContainer := 1

   For i:=1 To Len(aEmb)

      IF cTipoCalc == "2"
         // Quantidade
         nCnts := aEmb[i][3]/aEmb[i][5]
      Else
         // Volume
         nCnts := aEmb[i][3]/int(nVolume/aEmb[i][5])
      Endif

      nSobrou := nCnts-Int(nCnts)
      nCnts := nCnts-nSobrou

      nQtdeIt := aEmb[i][7] // Qtde do Item

      aRelacao := MontaRelacao(cPedido,aEmb[i][6],cOrigem,cVolume)

      IF Len(aRelacao) == 1 .And. Empty(cVolume)
         // So existe uma embalagem por exemplo Sacos ...
         aItens := { {aEmb[i][6],aEmb[i][7]} }
         aAdd(aContainer,{aEmb[i][3],aEmb[i][2]})
         AddLista() // Adiciona os elementos de aContainer, em aLista e
                    // incrementa nContainer ...
         Loop
      Endif

      nFatPenul := 1
      aEval(aRelacao,{|x| nFatPenul *= x[1]})

      IF !Empty(cVolume)
         nQtdIt_Cnt := nFatPenul*Eval(bQtdCnt)
         nTotCont   := Eval(bQtdCnt)
      Else
         nQtdIt_Cnt := nFatPenul
         nTotCont   := nCnts
      Endif

      nEmbUsada := 0

      If nCnts > 999  //LBL

         MsgInfo(STR0208/*"Quantidade de volumes excedida."*/ + ENTER + STR0209/*"O volume da quantidade total de embalagens "*/ + Alltrim(Str(aEmb[i][3])) + STR0210/*" resulta em um valor muito alto de "*/ + Alltrim(Str(nCnts)) + STR0211/*" de Volume."*/ + ENTER + STR0212/*"Revise a cubagem das embalagens."*/,STR0036)//"AVISO"
         aLista := []
         Exit

      Else
         While nCnts > 0
            aItens := { {aEmb[i][6],nQtdIt_Cnt} }
            aAdd(aContainer,{nTotCont,aEmb[i][2]})
            nEmbUsada := nEmbUsada+Eval(bQtdCnt)
            nQtdeIt -= nQtdIt_Cnt
            AddLista() // Adiciona os elementos de aContainer, em aLista e
                    // incrementa nContainer ...

            nCnts --
      Enddo

      Endif

      IF nSobrou > 0
         nInd := aScan(aSobra,{|x| x[1] == aEmb[i][1] })

         IF nInd == 0
            aAdd(aSobra,{aEmb[i][1],aEmb[i][3]-nEmbUsada,nSobrou,{{aEmb[i][6],nQtdeIt}},aEmb[i][2],Eval(bQtdCnt),aClone(aRelacao)})
         Else
            // Soma quantidade da penultima embalagem
            aSobra[nInd][2] := aSobra[nInd][2]+(aEmb[i][3]-nEmbUsada)
            // Soma percentual ocupado no volume
            aSobra[nInd][3] := aSobra[nInd][3]+nSobrou

            // Verifica se o item esta na lista
            IF (y:=aScan(aSobra[nInd][4],{|a| a[1] ==aEmb[i][6]})) == 0
               aAdd(aSobra[nInd][4],{aEmb[i][6],nQtdeIt})
            Else
               aSobra[nInd][4][y][2] += nQtdeIt
            Endif

            IF aSobra[nInd][3] >= 1

               nEmbals := 0
               For y:=1 To Len(aSobra[nInd][4])
                  aAdd(aItens,aClone(aSobra[nInd][4][y]))
                  nEmbals += (aSobra[nInd][4][y][2]/nFatPenul)
                  IF nEmbals > nTotCont
                     aSobra[nInd][4][y][2]:=(nEmbals-nTotCont)*nFatPenul
                     aItens[Len(aItens)][2] -= aSobra[nInd][4][y][2]
                     Exit
                  Else
                     aSobra[nInd][4][y] := nil
                  Endif
               Next

               aAdd(aContainer,{nTotCont,aSobra[nInd][5]})
               AddLista()
               aSobra[nInd][2] := aSobra[nInd][2]-nTotCont
               aSobra[nInd][3] := aSobra[nInd][3]-1

               /*
               For y:=1 To Len(aSobra[nInd][4])
                  IF Empty(aSobra[nInd][4][y])
                     y --
                     aDel(aSobra[nInd][4],y)
                     aSize(aSobra[nInd][4],Len(aSobra[nInd][4])-1)
                  Endif
               Next
               */

               //ER - 12/10/2006 - Substitui a fun��o acima, para limpar as sobras.
               For y := Len(aSobra[nInd][4]) To 1 Step -1
                  If Empty(aSobra[nInd][4][y])
                     aDel(aSobra[nInd][4],y)
                     aSize(aSobra[nInd][4],Len(aSobra[nInd][4])-1)
                  Endif
               Next

            Endif
         Endif
      Endif

   Next i

   For nInd:=1 To Len(aSobra)
      aRelacao := aSobra[nInd][7]
      aEval(aSobra[nInd][4],{|x| aAdd(aItens,x)})
      aAdd(aContainer,{aSobra[nInd][2],aSobra[nInd][5]})
      IF Empty(cVolume)
         aContainer[Len(aContainer)][1] := aSobra[nInd][2]/aSobra[nInd][6]
      Endif
      AddLista()
   Next

End Sequence

Return NIL

/*
Funcao      : MontaRelacao
Parametros  : cPedido := Codigo do Processo ou Embarque
              cSeq    := Sequencia do Item
              cOrigem := Fase OC_PE Pedido, OC_PE Embarque
Retorno     : Relacao das Embalagens
Objetivos   : Calcular a qtde de itens para um volume
Autor       : Cristiano A. Ferreira
Data/Hora   : 27/12/1999 10:24
Revisao     :
Obs.        :
*/
Static Function MontaRelacao(cPedido,cSeq,cOrigem,cVolume)
Local aRet := {}

Local aOrd := {}, nQtdeOld := 0
Local cEmbal1, nEmbal1, nSldIni
Local cEmbal2

Begin Sequence
   IF cOrigem == OC_PE
      SaveOrd("EE5",1)
      WorkIt->(dbSeek(cSeq))
      cEmbal1 := WorkIt->EE8_EMBAL1
      nEmbal1 := WorkIt->EE8_QTDEM1
      nSldIni := WorkIt->EE8_SLDINI
   Else
      aOrd := SaveOrd({"WorkIP","EE5"})
      EE5->(dbSetOrder(1))
      WorkIP->(dbSetOrder(2))
      WorkIP->(dbSeek(cSeq))
      cEmbal1 := WorkIP->EE9_EMBAL1
      nEmbal1 := WorkIP->EE9_QTDEM1
      nSldIni := WorkIP->EE9_SLDINI
   Endif

   // caf 21/01/2000 11:25 WorkEm->(dbSeek(cPedido+cSeq+cEmbal1,,.T.))
   WorkEm->(AVSeekLast(cPedido+cSeq+cEmbal1))

   While WorkEm->(!Bof()) .And.;
      WorkEm->(EEK_PEDIDO+EEK_SEQUEN+EEK_CODIGO)==cPedido+cSeq+cEmbal1

      IF WorkEm->EEK_EMB == cVolume
         WorkEm->(dbSkip(-1))
         Loop
      Endif

      IF !Empty(nQtdeOld)
         EE5->(dbSeek(xFilial()+cEmbal2))
         aAdd(aRet,NIL)
         aIns(aRet,1)
         aRet[1] := {WorkEm->EEK_QTDE/nQtdeOld,AllTrim(EE5->EE5_DESC),0,cEmbal2}
      Endif

      nQtdeOld := WorkEm->EEK_QTDE
      cEmbal2  := WorkEm->EEK_EMB

      WorkEm->(dbSkip(-1))
   Enddo

   IF !Empty(nQtdeOld)
      EE5->(dbSeek(xFilial()+cEmbal2))
      aAdd(aRet,NIL)
      aIns(aRet,1)
      aRet[1] := {nEmbal1/nQtdeOld,AllTrim(EE5->EE5_DESC),0,cEmbal2}
   Endif

   nQtdeOld := nEmbal1
   cEmbal2  := cEmbal1

   EE5->(dbSeek(xFilial()+cEmbal2))
   aAdd(aRet,NIL)
   aIns(aRet,1)
   aRet[1] := {nSldIni/nQtdeOld,AllTrim(EE5->EE5_DESC),0,cEmbal2}

   RestOrd(aOrd)

End Sequence

Return aRet

/*
Funcao      : AddEmb
Parametros  :
Retorno     : nenhum
Objetivos   : Montar array com quantidade das embalagens
Autor       : Cristiano A. Ferreira
Data/Hora   : 09/08/1999 15:40
Revisao     :
Obs.        :
*/
Static Function AddEmb(aLista,cPedido,lGravar,aItens,nSeq,aRelacao,cOrigem,lFirst,nQtd)

Local x := "", i, n, y:=0
Local nNivel := 1
Local lPrimeiraVez := .t.

Local aPesos[Len(aRelacao)]
Local aOrd, nPesEmb := 0
Local nPesLiq, nPesBru, cDescr
Local cVolume, cEmbal1

Begin Sequence

   IF lZero
      nSeq := nSeq - 1
   Endif
   lZero := .f.

   EE5->(dbSetOrder(1))

   IF cOrigem == OC_PE
      aOrd := SaveOrd({"WorkIt","EE5"})
      WorkIt->(dbSetOrder(1))
   Else
      aOrd := SaveOrd({"WorkIP","EE5"})
      WorkIP->(dbSetOrder(2))

      IF lGravar
         cRelacao := aTail(aRelacao)[4]
      Endif
   Endif

   For i:=1 to Len(aItens)

      x := ""
      n := 1
      nPesEmb := 0

      IF cOrigem == OC_PE
         WorkIt->(dbSeek(aItens[i][1]))
         nPesLiq := WorkIt->EE8_PSLQUN
         nPesBru := WorkIt->EE8_PSBRUN
         cDescr  := STR0047+MemoLine(WorkIt->EE8_VM_DES,25,1) //" COM "
         cVolume := M->EE7_EMBAFI
         cEmbal1 := WorkIt->EE8_EMBAL1
      Else
         WorkIP->(dbSeek(aItens[i][1]))
         nPesLiq := WorkIP->EE9_PSLQUN
         nPesBru := WorkIP->EE9_PSBRUN
         cDescr  := STR0047+MemoLine(WorkIP->EE9_VM_DES,25,1) //" COM "
         cVolume := M->EEC_EMBAFI
         cEmbal1 := WorkIP->EE9_EMBAL1
      Endif

      // Verfica se a ultima embalagem da relacao eh igual a da capa ...
      // 21/01/2000 11:26 WorkEm->(dbSeek(cPedido+aItens[i][1]+cEmbal1,,.T.))
      WorkEm->(AVSeekLast(cPedido+aItens[i][1]+cEmbal1))

      IF WorkEm->EEK_EMB == cVolume
         nPesEmb := Posicione("EE5",1,xFilial("EE5")+cVolume,"EE5_PESO")
      Endif

      For y:=1 to Len(aRelacao)
         n *= aRelacao[y][1]
         aRelacao[y][3] := aItens[i][2]/n
         aRelacao[y][3] := If (aRelacao[y][3]-Int(aRelacao[y][3]) > 0 , Int(aRelacao[y][3])+1 , aRelacao[y][3] )
         EE5->(dbSeek(xFilial()+aRelacao[y][4]))
         nPesEmb += (EE5->EE5_PESO*aRelacao[y][3])
      Next

      aEval(aPesos,{|x,y| aPesos[y] := nPesEmb})

      lPrimeiraVez := .t.

      For y:=Len(aRelacao) to 1 step -1
         IF lPrimeiraVez
            lPrimeiraVez := .f.
            IF lFirst
               lFirst := .f.
               // *** CAF 07/01/2000 aAdd(aLista,Str(nSeq,3)+OemToAnsi("�")+" COM "+AllTrim(Str(nQtd,15))+" "+aRelacao[y][2]+if(y==1,cDescr,""))
               aAdd(aLista,Str(nSeq,3)+OemToAnsi(STR0048)+STR0047+AllTrim(Str(aRelacao[y][3],15))+" "+aRelacao[y][2]+if(y==1,cDescr,"")) //"�"###" COM "
            Endif
         Else
            aAdd(aLista,Space(12)+x+AllTrim(Str(aRelacao[y][3],15))+" "+aRelacao[y][2]+if(y==1,cDescr,""))
         Endif
         IF lGravar
            IF aRelacao[y,3]>0
               GravaEEO(cPedido,TIPO_EMB,nSeq,nNivel,aRelacao[y][4],aRelacao[y][3],aPesos[y]+nPesLiq*aItens[i][2],nPesLiq*aItens[i][2],len(aRelacao))
            Else
               lZero := .T.
            Endif
            nNivel ++
         Endif

         x += Space(3)
         n /= aRelacao[y][1]

         aRelacao[y][3] := 0
      Next

      IF lGravar
         IF aItens[i,2]>0
            GravaEEO(cPedido,TIPO_ITEM,nSeq,nNivel,aItens[i][1],aItens[i][2],Atail(aPesos)+nPesLiq*aItens[i][2],nPesLiq*aItens[i][2],len(aRelacao))
         Else
            lZero := .T.
         endif
         nNivel ++
      Endif
   Next

   RestOrd(aOrd)

End Sequence

Return NIL

/*
Funcao      : GravaEEO(cPedido,cTipo,nSeq,nNivel,cCodEmb,nQtde,nPesBru,nPesLiq,nQtdEmb)
Parametros  : cPedido := Numero do Processo de Embarque
              cTipo   := TIPO_EMB/TIPO_ITEM
              nSeq    := Sequencia
              nNivel  := Nivel
              cCodEmb := Codigo da Embalagem
              nQtde   := Quantidade
Retorno     : nenhum
Objetivos   : Incluir um registro no EEO
Autor       : Cristiano A. Ferreira
Data/Hora   : 30/09/1999 14:40
Revisao     :
Obs.        :
*/
Static Function GravaEEO(cPedido,cTipo,nSeq,nNivel,cCodEmb,nQtde,nPesBru,nPesLiq,nQtdEmb)

Local aOrd := SaveOrd("EE5",1)

Default nPesBru := 0, nPesLiq := 0

Begin Sequence
   IF Type("EEC_CUBAGE") == "N" .and. Mod((nNIVEL-1),(nQtdEmb+1)) == 0
         IF EMPTY(M->EEC_EMBAFI)
            IF EE5->(dbSeek(xFilial()+cRelacao))
               M->EEC_CUBAGE += nQTDE*(EE5->(EE5_HALT*EE5_LLARG*EE5_CCOM))
         Endif
      ENDIF
   Endif

   IF !EasyGParam("MV_AVG0005") // Deixar de gravar embalagens ?
      EEO->(RecLock("EEO",.T.))
      EEO->EEO_FILIAL := xFilial("EEO")
      EEO->EEO_PREEMB := cPedido
      EEO->EEO_TIPO   := cTipo
      EEO->EEO_SEQ    := Str(nSeq,AVSX3("EEO_SEQ",AV_TAMANHO))
      IF Type("EEC_TOTVOL") == "N"
         M->EEC_TOTVOL := nSeq
      Endif
      EEO->EEO_NIVEL  := Str(nNivel,AVSX3("EEO_NIVEL",AV_TAMANHO))
      EEO->EEO_CODEMB := cCodEmb
      EEO->EEO_QTDE   := nQtde
      EEO->EEO_PESBRU := nPesBru
      EEO->EEO_PESLIQ := nPesLiq
      EEO->(MsUnlock())
   ENDIF
End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : AP100CopyFrom
Parametros  : nenhum
Retorno     : nenhum
Objetivos   : Copia dados de um processo
Autor       : Cristiano A. Ferreira
Data/Hora   : 24/07/99 11:23
Revisao     :
Obs.        :
*/
Static Function AP100CopyFrom(nOpc)

Local nRecEE7 := EE7->(RecNo())
Local nSelect := Select()
Local lRet := .t.

Local cProc := M->EE7_PEDIDO
Local aOrd

Local aEE7Filter := EECSaveFilter("EE7") // JPM - 02/12/05 - salva e limpa filtro no EE7
// JPM - 02/12/05 - filtro para que os pedidos especiais n�o apare�am
Eval({|f| EE7->(DbSetFilter(&("{|| " + f + "}"),f)) },"Left(EE7->EE7_PEDIDO,1) <> '*'")
EE7->(DbGoTop())

Private lCapa := .T., lItens := .T.

Begin Sequence

   IF !AP100SelProc()
      lRet:=.f.
      Break
   Endif

   IF lItens
      // ** JBJ - 09/10/01 10:20  (Inicio)...
      If !(IsVazio("WorkIt"))
         If !MsgYesNo(STR0060,STR0024)  //"Os itens j� lan�ados ser�o apagados. Confirma a c�pia dos dados?"###"Aten��o"
            lRet := .f.
            Break
         EndIf
      EndIf
      // ** (Fim)
   Endif

   MsAguarde({|| MsProcTxt(STR0049+Transf(EE7->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE))),; //"Copiando informa��es do processo: "
              AP100Copy(cProc,nOpc) }, STR0016) //"Processo de Exporta��o"
   WorkIt->(dbGoTop())

End Sequence

Inclui := .T.

If lRet
   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.f.,.f.,{"PE_COPYPED",lCapa,lItens})
   EndIf
EndIf

// JPM - 02/12/05 - restaura filtro no EE7
EECRestFilter(aEE7Filter)

EE7->(dbGoto(nRecEE7))
Select(nSelect)

Return lRet

/*
Funcao      : AP100Copy
Parametros  : nenhum
Retorno     : nenhum
Objetivos   : Copia dados de um processo
Autor       : Cristiano A. Ferreira
Data/Hora   : 25/04/2000 11:00
Revisao     :
Obs.        :
*/
Static Function AP100Copy(cProc,nOpc)

Local k, aOrd
Local lInclui := Inclui
Local nInc

Begin Sequence
   IF lCapa
      For k:=1 To EE7->(FCount())
         IF Valtype(EE7->(FieldGet(k))) == "D"
            Loop
         Endif
         EE7->( M->&(FieldName(k)) := FieldGet(k) )
      Next k
      //Campos do tipo data que fogem a regra
      M->EE7_DTLIMP := EE7->EE7_DTLIMP

      // 25/05/2001 11:41
      // Osman Medeiros Jr.
      If EE7->(FieldPos("EE7_PROFOR")) > 0
        M->EE7_PROFOR := SPACE(AVSX3("EE7_PROFOR",AV_TAMANHO))
      EndIf

      // by CAF 28/05/2001
      M->EE7_PEDFAT := CriaVar("EE7_PEDFAT")

      cCodImport := M->EE7_IMPORT

      // by CAF 10/08/2001 11:16 Copia os Campos Virtuais
      aOrd := SaveOrd("SX3",1)
      SX3->(dbSeek("EE7"))
      While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "EE7"
         IF Upper(SX3->X3_CONTEXT) == "V"
            M->&(SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
         Endif
         SX3->(dbSkip())
      Enddo
      SX3->(DbSetOrder(2))
      SX3->(dbSeek("EE7_MOTSIT"))
      IF SX3->X3_TRIGGER $ "Ss"
         RunTrigger(1)
      Endif
      RestOrd(aOrd)

      M->EE7_DESCPA := MSMM(Posicione("SY6",1,xFilial("SY6")+M->EE7_CONDPA+STR(M->EE7_DIASPA,3),"Y6_DESC_P"),60,1)

      M->EE7_DSCGEN := ""
      M->EE7_CODOBP := ""
      M->EE7_OBSPED := ""
      M->EE7_CODMEM := ""
      M->EE7_CODMAR := "" //DFS - 27/06/11 - Ao acionar a op��o c�pia de pedido, e alterar o campo memo EE7_MARCAC, o sistema n�o altera mais o conteudo do campo do primeiro pedido.

      For nInc := 1 To Len(aMemos)
         M->&(aMemos[nInc][2]) := EasyMSMM(EE7->&(aMemos[nInc][1]),TAMSX3(aMemos[nInc][2])[1],,,LERMEMO,,,"EE7",aMemos[nInc][1])
      Next
      /*
      M->EE7_MARCAC := MSMM(EE7->EE7_CODMAR,AVSX3("EE7_MARCAC",AV_TAMANHO),,,LERMEMO)
      M->EE7_OBS    := MSMM(EE7->EE7_CODMEM,AVSX3("EE7_OBS",AV_TAMANHO),,,LERMEMO)
      M->EE7_GENERI := MSMM(EE7->EE7_DSCGEN,AVSX3("EE7_GENERI",AV_TAMANHO),,,LERMEMO)
      M->EE7_OBSPED := MSMM(EE7->EE7_CODOBP,AVSX3("EE7_OBSPED",AV_TAMANHO),,,LERMEMO)
      */

      M->EE7_PESLIQ:=M->EE7_PESBRU:=M->EE7_TOTITE:=M->EE7_TOTPED:=0

      If Type("M->EE7_CPRFOB") <> "U" //JPM - 31/01/06 - Compra FOB
         M->EE7_CPRFOB := .F.
      EndIF
      If lIntPrePed                   //NCF - 08/11/2013 - Nao copiar Pedido retornado pelo ERP Externo (LOGIX)
         M->EE7_PEDERP := ""
      EndIf

      //IF ! lItens
      //   AP100CopyCompl(cProc,.F.,nOpc)
      //Endif
   Endif

   AP100CopyCompl(cProc,lItens,nOpc)
   //MFR 14/03/2019 OSSME-2388
   WorkDe->(dbGoTop())
   WorkDe->(dbEval({|| WorkDe->EET_DOCTO := ""}))

   IF M->EE7_STATUS <> ST_RV
      /*
      If cTipoProc $ PC_BN+PC_BC
         M->EE7_STATUS := ST_CL //Credito Aprovado
      ElseIf lIntegra
      */
      If lIntegra
         M->EE7_STATUS := ST_AF  //aguardando faturamento
      Else
         M->EE7_STATUS := ST_SC  //aguardando solicitacao credito
      EndIf
   Endif

   DSCSITEE7()
   // LCS - 29/04/2002 - GRAVA OS CAMPOS DE COMISSAO APOS OS GATILHOS
   IF lCAPA
      M->EE7_TIPCOM := EE7->EE7_TIPCOM
      M->EE7_TIPCVL := EE7->EE7_TIPCVL
      M->EE7_VALCOM := EE7->EE7_VALCOM
   ENDIF

   /*
   AMS - 24/06/2005. Grava o campo flag que indica que a origem do pedido n�o foi pela integra��o.
   */
   If EasyGParam("MV_AVG0094",, .F.) .and. EE7->(FieldPos("EE7_INTEGR")) > 0
      M->EE7_INTEGR := "N"
   EndIf

End Sequence

Inclui := lInclui

Return NIL

/*
Funcao      : AP100CopyCompl
Parametros  : nenhum
Retorno     : nenhum
Objetivos   : Copiar complementos da capa do pedido de exporta��o (bot�es)
Autor       : Cristiano A. Ferreira
Data/Hora   : 15/01/2005 10:43
Revisao     :
Obs.        :
*/
Static Function AP100CopyCompl(cProc,lItens,nOpc)

Local lIncluiOld := Inclui, aCpos := {}, cPasta, aLimpa := {}, nPos
Local aOrd := {}
Local aCpyPed := {"EE8_MESFIX", "EE8_PRECO", "EE8_DIFERE"}
Local n := 1

Begin Sequence

   aOrd := If(Select("WorkDoc")>0,SaveOrd({"WorkDe","WorkAg","WorkIn","WorkNo","WorkIt","WorkEm","WorkDoc"}),;
                                  SaveOrd({"WorkDe","WorkAg","WorkIn","WorkNo","WorkIt","WorkEm"}))

   If lItens
      // ** JPM - 11/11/05 - Campos que n�o devem ser copiados - WorkIt
      cPasta := PastaFix()
      If !Empty(cPasta) // adiciona campos da pasta de fixa��o de pre�o no array aCpos (que n�o ser� copiado)
         AEval(WorkIt->(DbStruct()),{|a| If(Posicione("SX3",2,a[1],"X3_FOLDER") = cPasta,AAdd(aCpos,a[1]), ) })
      EndIf

      //DFS - Tratamento para que os campos de usu�rios sejam copiados de um processo desejado
      //      e tratamento para que n�o zere os valores de alguns campos quando copiados de um processo

      AEval(WorkIt->(DbStruct()),{|a| If(Posicione("SX3",2,a[1],"X3_PROPRI") = "U",AAdd(aCpyPed,a[1]), ) })

      // ** Fim

      aLimpa := {"EE8_ORIGV","EE8_ORIGEM","EE8_FATIT","EE8_RV","EE8_DTRV","EE8_STA_RV","EE8_SEQ_RV","EE8_DTVCRV",;
      "EE8_DTPREM", "EE8_DTENTR"}

     /* If lCommodity
         AAdd(aLimpa,"EE8_PRECO")  // DFS - Retirado tratamento que zerava o campo relacionado a Pre�o
      EndIf
      */
      If lIntPrePed                 //NCF - 08/11/2013 - Nao copiar Pedido retornado pelo ERP Externo(LOGIX)
         AAdd(aLimpa,"EE8_PEDERP")
      EndIf

      // MPG - Caso o par�metro de desconto eseteja desabilitado limpa o campo de desconto
      if ! EasyGParam("MV_AVG0119",,.F.)
         AAdd(aLimpa,"EE8_DESCON")
      endif

      // Campos que devem ser limpados
      Eval({|x, y| aSize(x, Len(x)+Len(y)),;
            aCopy(y, x,,, Len(x)-Len(y)+1 )}, aCpos, aLimpa)

      //DFS - Tratamento para que copie os campos do Embarque
      For n := 1 to Len (aCpyPed)
         If (nPos := AScan(aCpos,{|x| AllTrim(x) == aCpyPed[n] }) ) > 0
            ADel(aCpos,nPos)
            ASize(aCpos,Len(aCpos)-1)
         EndIf
      Next

      If (nPos := AScan(aCpos,{|x| AllTrim(x) == "EE8_UNPRC"}) ) > 0
         ADel(aCpos,nPos)
         ASize(aCpos,Len(aCpos)-1)
      EndIf

      //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
      AvZap("WorkEm")
      AvZap("WorkIt")
   Endif

   IF lCapa
      //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
      AvZap("WorkDe")
      AvZap("WorkAg")
      AvZap("WorkIn")
      AvZap("WorkNo")

      If Select("WorkDoc") > 0
         //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
         AvZap("WorkDoc")
      EndIf
   Endif

   Inclui := ! lCapa
   EECAP102(lItens) // Copiar dados complementares.

   Inclui := .f.
   IF lItens
      M->EE7_PEDIDO := EE7->EE7_PEDIDO
      AP100GRTRB(nOpc,.T.) // Copiar dados dos itens (EE8)

      ////////////////////////////////////////////////
      //Monta a grade com base nos itens j� gravados//
      ////////////////////////////////////////////////
      If lGrade
         Ap102GrdMonta()
      EndIf

      M->EE7_PEDIDO := cProc
   Endif

   IF lCapa
      M->EE7_PEDIDO := cProc

      WorkAg->(dbSetOrder(0))
      WorkDe->(dbSetOrder(0))
      WorkIn->(dbSetOrder(0))
      WorkNo->(dbSetOrder(0))
      WorkDoc->(dbSetOrder(0))

      WorkDe->(dbGoTop())
      WorkDe->(dbEval({||  WorkDe->EET_PEDIDO := M->EE7_PEDIDO,WorkDe->EET_RECNO:=0}))
      WorkAg->(dbGoTop())
      WorkAg->(dbEval({||  WorkAg->EEB_PEDIDO := M->EE7_PEDIDO,WorkAg->WK_RECNO:=0}))
      WorkIn->(dbGoTop())
      WorkIn->(dbEval({||  WorkIn->EEJ_PEDIDO := M->EE7_PEDIDO,WorkIn->WK_RECNO:=0}))
      WorkNo->(dbGoTop())
      WorkNo->(dbEval({||  WorkNo->EEN_PROCES := M->EE7_PEDIDO,WorkNo->WK_RECNO:=0}))

      If Select("WorkDoc") > 0
         WorkDoc->(dbSetOrder(0))
         WorkDoc->(dbGoTop())
         WorkDoc->(dbEval({||  WorkDoc->EXB_PEDIDO := M->EE7_PEDIDO, WorkDoc->WK_RECNO:=0}))
      EndIf
   Endif

   IF lItens
      //JPM - 14/11/05 - Consolidar itens
      If lConsolida
         Ap100Consolida()
      EndIf

      // AMS - 14/07/2003 - Limpeza dos campos da RV.
      WorkIt->(dbGotop())
      WorkIt->(dbEval({|| WorkIt->EE8_PEDIDO := M->EE7_PEDIDO,;
                          WorkIt->EE8_RECNO  := 0,;
                          WorkIt->EE8_DESC   := "",;
                          WorkIt->EE8_SLDATU := WorkIt->EE8_SLDINI,;
                          LimpaCampos(aCpos) }))
      WorkEm->(dbGotop())
      WorkEm->(dbEval({||  WorkEm->EEK_PEDIDO := M->EE7_PEDIDO}))

     /* If AScan(aCpos,"EE8_PRECO") > 0
         AP100PrecoI(.T.) // recalcula os pre�os.
      EndIf */ // DFS - Retirado o valor que recalculava os pre�os e zerava quando copiado de um outro processo

      If lConsolida
         WorkIt->(DbGoTop())
         //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
         AvZap("WorkGrp")
         Ap104LoadGrp()
      EndIf

   Endif

End Sequence

Inclui := lIncluiOld
RestOrd(aOrd)

Return NIL

/*
Fun��o     : Ap100Consolida
Objetivos  : Consolidar itens de acordo com campos EE8_ORIGV e EE8_ORIGEM
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 14/11/05
*/
Function Ap100Consolida()
Local nRec, i, aTotaliza := {}, nSeq := 0
Local cConsolida := Ap104StrCpos(aConsolida)

Begin Sequence

   For i := 1 To Len(aGrpCpos)
      If aGrpInfo[i] = "T"
         AAdd(aTotaliza,aGrpCpos[i])
      EndIf
   Next

   DbSelectArea("WorkIt")
   WorkGrp->(DbGoTop())
   While WorkGrp->(!EoF())
      nSeq++

      bConsolida := &("{|| WorkIt->(Ap104SeqIt() + " + cConsolida + ") }")
      cGrpFilter := WorkGrp->(EE8_ORIGEM+&(cConsolida))
      // Filtro para que s� sejam considerados os itens que perten�am � consolida��o
      DbSetFilter({|| cGrpFilter == Eval(bConsolida)}, "cGrpFilter == Eval(bConsolida)")
      DbGoTop()

      nRec := RecNo()
      // Pega os dados do Primeiro Item
      For i := 1 To FCount()
         M->&(FieldName(i)) := FieldGet(i)
      Next

      // Totaliza os dados dos demais
      DbSkip()
      While !Eof()
         For i := 1 To Len(aTotaliza)
            M->&(aTotaliza[i]) += WorkIt->&(aTotaliza[i])
         Next
         DbDelete()
         DbSkip()
      EndDo

      DbGoTo(nRec)
      // grava totaliza��es no registro da WorkIt
      AvReplace("M","WorkIt")

      EE8_SEQUEN := Str(nSeq,AvSx3("EE8_SEQUEN",AV_TAMANHO))

      DbGoTop()

      // Limpa filtro
      DbClearFilter()

      WorkGrp->(DbSkip())
   EndDo

   Ap100PrecoI()
   WorkGrp->(DbGoTop())

   M->EE7_TOTITE := nSeq

End Sequence

Return Nil

// JPM - 11/11/05 - procurar qual � a pasta de fixa��o de pre�o.
Static Function PastaFix()
   Local cPasta
   cPasta := ""
   SXA->(DbSetOrder(1))
   SXA->(DbSeek("EE8"))
   While SXA->(!EoF()) .And. SXA->XA_ALIAS == "EE8"
      If AllTrim(SXA->XA_DESCRIC) = "Diferencial de Preco"
         cPasta := SXA->XA_ORDEM
         Exit
      EndIf
      SXA->(DbSkip())
   EndDo

   SX3->(DbSetOrder(2))
   If Empty(cPasta)
      cPasta := "2"
      If SX3->(!DbSeek("EE8_DTFIX")) // Verifica se � a pasta de fixa��o mesmo...
         cPasta := ""
      ElseIf SX3->X3_FOLDER <> cPasta
         cPasta := SX3->X3_FOLDER
      EndIf
   EndIf
Return cPasta

// JPM - 11/11/05 - Limpar campos no registro da WorkIt
Static Function LimpaCampos(aCpos)
   Local i
   SX3->(DbSetOrder(2))
   For i := 1 To Len(aCpos)
      If WorkIt->(FieldPos(aCpos[i])) > 0
         WorkIt->&(aCpos[i]) := Eval({|x| If(ValType(x)$"C/M",Space(Len(x)),;
                                          If(ValType(x)="N",0,;
                                          If(ValType(x)="D",AvCToD(""),x))) },WorkIt->&(aCpos[i]))
      EndIf
   Next
Return Nil
/*
Funcao      : AP100SelProc
Parametros  : nenhum
Retorno     : Numero de Processo
Objetivos   : Copia dados de um processo
Autor       : Cristiano A. Ferreira
Data/Hora   : 24/07/99 11:23
Revisao     :
Obs.        :
*/
Static FUNCTION AP100SelProc()

Local lRet := .F.
Local oDlg,oBrwCapa, oBtnPesq
Local bOk, bCancel, nOpcA, aPos
Local aCpoEE7 := ArrayBrowse("EE7")
Local aButtons :={} //MCF - 04/04/2016

AaDD(aButtons, {"PESQUISA" ,{|| AxPesqui("EE7",EE7->(RecNo()),1),oBrwCapa:oBrowse:Refresh()},STR0051}) //"Pesquisar" //MCF - 04/04/2016

Begin Sequence

   IF ! EE7->(dbSeek(xFilial()))
      HELP(" ",1,"AVG0000622") //MsgStop("N�o existem registros para a visualiza��o !","Aviso")
      Break
   Endif

   nOpcA := 0
   If lConsign
      EECFilterProc("EE7", cTipoProc)
   EndIf
   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.f.,.f.,{"COPYPED_TELA"})
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0050 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Sele��o de Processos"

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 04/04/2016
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      aPos := PosDlg(oDlg)
      aPos[1] := 60

      oBrwCapa  := MsSelect():New("EE7",,,aCpoEE7,,,aPos,"xFilial('EE7')","xFilial('EE7')",,,,)//.T.) AST - 26/08/08 - Parametro incorreto

      //bOk     := {|| IF(!lCapa .And. !lItens,MsgStop("Para copiar o processo � necess�rio clicar em dados da capa ou dados dos itens!","Aviso"),(nOpcA := 1, oDlg:End())) }
      bOk     := {|| IF(!lCapa .And. !lItens,HELP(" ",1,"AVG0000643"),(nOpcA := 1, oDlg:End())) }
      bCancel := {|| oDlg:End() }

      oBrwCapa:bAval := bOk

      /*@ 15,1 BUTTON oBtnPesq PROMPT STR0051 ; //"&Pesquisa" //MCF - 04/04/2016 - Transferido para a ENCHOICE - Vers�o 12
             ACTION (AxPesqui("EE7",EE7->(RecNo()),1),oBrwCapa:oBrowse:Refresh()) ;
             SIZE 42,11 OF oPanel PIXEL FONT oDlg:oFont*/

      @ 13, 255 TO 28, 314 LABEL STR0052 OF oPanel PIXEL //"Copiar:"

      @ 19, 260 CHECKBOX lCapa  PROMPT STR0053 SIZE 30,08 OF oPanel PIXEL FONT oDlg:oFont //"&Capa"
      @ 19, 290 CHECKBOX lItens PROMPT STR0054 SIZE 21,08 OF oPanel PIXEL FONT oDlg:oFont //"&Itens"

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   IF nOpcA == 1
      lRet := .T.
   Endif
End Sequence

Return lRet

/*
Funcao      : EECGetPesos
Parametros  : cOrigem
Retorno     : .T./.F.
Objetivos   : Alteracao de Pesos na Gravacao do Processo
              Qdo a variavel MV_AVG0004 for iqual a True
Autor       : Cristiano A. Ferreira
Data/Hora   : 13/01/2000 17:14
Revisao     :
Obs.        :
*/
Function EECGetPesos(cOrigem)

Local cAlias  := if(cOrigem==OC_EM,"EEC","EE7")
Local oDlg, bOk, bCancel, nOpcA := 0
Local lRet

Local bPesLiq := MemVarBlock(cAlias+"_PESLIQ")
Local bPesBru := MemVarBlock(cAlias+"_PESBRU")

Local aObjPC := { "oSayPLC", "oSayPBC" },;  //Array com todos os objetos do Peso C�culado.
      aObjPD := { "oSayPLD", "oGetPLD", "oSayPBD", "oGetPBD" }    //Array com todos os objetos do Peso D�gitado.

Local cAliasWork := IF(cAlias == "EEC","WorkIP","WorkIt")
Local bSomaPeso, nRecWork := (cAliasWork)->(RecNo())
Local bCondicao // Bloco de codigo que conter� um filtro, que determinar� o calculo dos pesos totais, apenas para itens de embarque selecionados.
Local nEE7RecOld

Private lCBPesCal := .F.,;  //Valor L�gico do Objeto CheckBox Peso C�lculado.
	       nPesLC := 0,;    //Valor Num�rico do Peso L�quido C�lculado.
	       nPesBC := 0,;    //Valor Num�rico do Peso Bruto C�lculado.
        lCBPesDig := .T.    //Valor L�gico do Objeto CheckBox Peso D�gitado.

Private nPesLD := 0,; //Valor Num�rico do Peso L�quido D�gitado.
        nPesBD := 0   //Valor Num�rico do Peso Bruto D�gitado.

Private lPesLD := .T.,; // Vari�vel l�gica que definir� o modo de edi��o do campo peso l�quido digitado  // By JPP - 31/01/2006 - 10:50
        lPesBD := .T.   // Vari�vel l�gica que definir� o modo de edi��o do campo peso l�quido digitado
// Calcular os Pesos Bruto e Liquido de acordo com os Works.
IF lConvUnid
   bSomaPeso  := IF(cAlias == "EEC",{||nPesLC += AvTransUnid(IIF(!Empty(WorkIP->EE9_UNPES),WorkIP->EE9_UNPES,"KG"),IIF(!Empty(M->EEC_UNIDAD),M->EEC_UNIDAD,"KG"),WorkIP->EE9_COD_I,WorkIP->EE9_PSLQTO,.F.),;
                                       nPesBC += AvTransUnid(IIF(!Empty(WorkIP->EE9_UNPES),WorkIP->EE9_UNPES,"KG"),IIF(!Empty(M->EEC_UNIDAD),M->EEC_UNIDAD,"KG"),WorkIP->EE9_COD_I,WorkIP->EE9_PSBRTO,.F.) },;
                                    {||nPesLC += AvTransUnid(IIF(!Empty(WorkIt->EE8_UNPES),WorkIt->EE8_UNPES,"KG"),IIF(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),WorkIt->EE8_COD_I,WorkIt->EE8_PSLQTO,.F.),;
                                       nPesBC += AvTransUnid(IIF(!Empty(WorkIt->EE8_UNPES),WorkIt->EE8_UNPES,"KG"),IIF(!Empty(M->EE7_UNIDAD),M->EE7_UNIDAD,"KG"),WorkIt->EE8_COD_I,WorkIt->EE8_PSBRTO,.F.) } )
Else
//   bSomaPeso  := IF(cAlias == "EEC",{||nPesLC += WorkIt->EE8_PSLQTO,;
//                                       nPesBC += WorkIt->EE8_PSBRTO},;
//                                    {||nPesLC += WorkIP->EE9_PSLQTO,;
//                                       nPesBC += WorkIP->EE9_PSBRTO })

   bSomaPeso  := IF(cAlias == "EEC",{||nPesLC += WorkIP->EE9_PSLQTO,;
                                       nPesBC += WorkIP->EE9_PSBRTO},;
                                    {||nPesLC += WorkIt->EE8_PSLQTO,;
                                       nPesBC += WorkIt->EE8_PSBRTO })

Endif

Begin Sequence

   If cOrigem == OC_PE .AND. Type("lEE7Auto") == "L" .AND. lEE7Auto
      nOpcA := 1
      Break
   EndIf

   // By JPP - 31/08/04 11:00 - Define um filtro para Calcular o peso dos itens de embarque, calculando apenas os itens que estiverem selecionados.
   bCondicao := If(cAlias == "EEC",{|| !Empty(WORKIP->WP_FLAG)},)
   (cAliasWork)->(dbEval(bSomaPeso,bCondicao))
   (cAliasWork)->(dbGoTo(nRecWork))

   nPesLD := If( !Inclui, &(cAlias + "->" + cAlias + "_PESLIQ"), nPesLC )
   nPesBD := If( !Inclui, &(cAlias + "->" + cAlias + "_PESBRU"), nPesBC )

   // CAF - 19/05/2003 - Revisao com as novas opcoes: Calculado / Digitado
   // LCS - 20/03/2001 - TRAZER OS PESOS DO PROCESSO CASO TENHA CONFIRMACAO DE PESO
   // CAF 31/03/2001 Revisao
   If cOrigem == OC_EM .And. ! Empty(M->EEC_PEDREF) .And. Inclui
      nEE7RecOld := EE7->(Recno())
      If EE7->(dbSeek(xFilial()+M->EEC_PEDREF))
         // *** by CAF 09/08/2002 (3M - Varios Pedidos em 1 Embarque) nPesLiq := EE7->EE7_PESLIQ
         nPesBD := EE7->EE7_PESBRU
      Endif
      EE7->(dbGoTo(nEE7RecOld))
   EndIf

   // JPP - 01/09/04 - 15:36 - Inclus�o de ponto de entrada.
   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.f.,.f.,{"GETPESOS",nPesLC,nPesBC})
   EndIf

   Define MSDialog oDlg TITLE STR0055 FROM 10, 12 TO 30, 80 OF oMainWnd //"Confer�ncia de Pesos" - FSM - 26/07/2011
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 30, 80)
   //@ 00,00 MsPanel oPanel Prompt "" Size 90,165 OF oDlg
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   //Peso Calculado
   @ 2.0, 0.65 To 5.5, 16.5 of oPanel
   @ 18, 07   CheckBox oCBPesCal Var lCBPesCal Prompt STR0125 of oPanel Size 35, 08 On Click;
              ( Eval( { || lPesLD    := .F.                              ,;
                           lPesBD    := .F.                              ,;
                           lCBPesDig := .F.                              ,;
                           oCBPesDig:Refresh()                           ,;
                           oSayPLC:Enable(), oSayPBC:Enable()            ,;
                           oSayPLD:Disable(), oGetPLD:Disable(), oSayPBD:Disable(), oGetPBD:Disable()}))
                           /*aEval( aObjPD, { |x| &( x + ":Disable()" ) } ),;
                           aEval( aObjPC, { |x| &( x + ":Enable()" ) } ) } ) ) //"Calculado"*/ // MCF-17/03/2015

   @ 3.3, 1.8 Say oSayPLC   Var STR0056 of oPanel SIZE 35,9 // Objeto Say Peso L�quido C�lculado.
   @ 3.3, 6.7 MSGet oGetPLC Var nPesLC Picture AVSX3(cAlias+"_PESLIQ",AV_PICTURE) of oPanel When .F. //Objeto Get Peso L�quido C�lculado.

   @ 4.5, 1.8 Say oSayPBC   Var STR0057 of oPanel SIZE 35,9 //Objeto Say Peso Bruto C�lculado.
   @ 4.5, 6.7 MSGet oGetPBC Var nPesBC Picture AVSX3(cAlias+"_PESBRU",AV_PICTURE) of oPanel When .F. //Objeto Get Peso Bruto C�lculado.

   //Peso D�gitado
   @ 2.0, 17.0 To 5.5, 33.2 of oPanel
   @ 18, 135.9 CheckBox oCBPesDig Var lCBPesDig Prompt STR0126 of oPanel Size 30, 08 On Click;
               ( Eval( { || lPesLD    := .T.                              ,;
                            lPesBD    := .T.                              ,;
                            lCBPesCal := .F.                              ,;
                            oCBPesCal:Refresh()                           ,;
                            oSayPLC:Disable(), oSayPBC:Disable()           ,;
                            oSayPLD:Enable(), oGetPLD:Enable(), oSayPBD:Enable(), oGetPBD:Enable()}))
                            /*aEval( aObjPC, { |x| &( x + ":Disable()" ) } ),;
                            aEval( aObjPD, { |x| &( x + ":Enable()") } ) } ) ) //"D�gitado"*/ // MCF-17/03/2015

   @ 3.3, 18.0 Say oSayPLD   Var STR0056 of oPanel SIZE 35,9 //Objeto Say Peso L�quido D�gitado.
   @ 3.3, 23.0 MSGET oGetPLD Var nPesLD Picture AVSX3(cAlias+"_PESLIQ",AV_PICTURE) of oPanel When lPesLD //Objeto Get Peso L�quido D�gitado.

   @ 4.5, 18.0 SAY oSayPBD   Var STR0057 of oPanel SIZE 35,9 //Objeto Say Peso Bruto D�gitado.
   @ 4.5, 23.0 MSGET oGetPBD Var nPesBD Picture AVSX3(cAlias+"_PESBRU",AV_PICTURE) of oPanel When lPesBD //Objeto Peso Bruto D�gitado.

   If ! lCBPesCal
      aEval( aObjPC, { |x| &( x + ":Disable()" ) } )
      lPesLD := .T.
      lPesBD := .T.
   End If

   If ! lCBPesDig
      aEval( aObjPD, { |x| &( x + ":Disable()" ) } )
      lPesLD := .F.
      lPesBD := .F.
   EndIf


   bOk := {|| nOpcA := 1, oDlg:End() }
   bCancel := {|| oDlg:End() }

   Activate MSDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

   IF nOpcA == 0
      Break
   Endif

   If EasyEntryPoint("EECAP100")
      lRet := ExecBlock("EECAP100",.f.,.f.,{"GETPESOS_OK"})
      If ValType(lRet) == "L" .And. !lRet
         nOpcA := 0
      EndIf
   EndIf

   Eval( bPesLiq, If( lCBPesCal, nPesLC, nPesLD ) )
   Eval( bPesBru, If( lCBPesCal, nPesBC, nPesBD ) )

End Sequence

Return (nOpcA == 1)

/*
Funcao      : AP100Error
Parametros  : nItensEEC = Nro de itens no SigaEEC
              nItensFAT = Nro de Itens no SigaFAT
              nPrecoEEC = Valor total no SigaEEC
              nPrecoFAT = Valor total no SigaFAT
              cFase     = Fase que originou a chamada da fun��o ("PED" - Pedido, "EMB" - Embarque)
Retorno     : .T.
Objetivos   : Detalhar falha de integracao.
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/02/2002 10:31
Revisao     :
Obs.        :
*/
*----------------------------------------------------------------*
Function AP100Error(nItensEEC,nItensFAT,nPrecoEEC,nPrecoFAT,cFase)
*----------------------------------------------------------------*
Local lRet:=.t.,oDlg
Local lAuto := Type("lsched") == "L" .And. lsched

Default nItensEEC:=0,nItensFAT:=0,nPrecoEEC:=0,nPrecoFAT:=0
Default cFase := "PED"

Begin Sequence

   If !lAuto
      DEFINE MSDIALOG oDlg TITLE STR0062 FROM 10,12 TO 24,53 OF oMainWnd //"Erro de Integridade"

         @ 09,04 Say STR0063 PIXEL  //"Falha de integridade com o m�dulo de faturamento."

         @ 22,03 TO 70,160 LABEL STR0064 PIXEL //"Informa��es"

         If cFase == "EMB
           @ 30,59 Say STR0187 SIZE 40,07 PIXEL; @ 30,125 Say STR0066 SIZE 30,07 PIXEL //"Embarque"###"Ped. Venda" //STR0187	"Embarque"
         Else
           @ 30,59 Say STR0065 SIZE 40,07 PIXEL; @ 30,125 Say STR0066 SIZE 30,07 PIXEL //"Ped. Exporta��o"###"Ped. Venda"
         EndIf

         @ 39,07 Say STR0067 PIXEL //"Nro. de Itens:"

         @ 39,50 MSGET nItensEEC SIZE 50,07 PICTURE "999,999,999.99" WHEN .F. PIXEL
         @ 39,105 MSGET nItensFAT SIZE 50,07 PICTURE "999,999,999.99" WHEN .F. PIXEL

         @ 51,07 Say STR0068 PIXEL //"Valor Total:"

         @ 51,50 MSGET nPrecoEEC SIZE 50,07 PICTURE "999,999,999.99" WHEN .F. PIXEL
         @ 51,105 MSGET nPrecoFAT SIZE 50,07 PICTURE "999,999,999.99" WHEN .F. PIXEL

         @ 75,04 Say STR0069 PIXEL //"Favor entrar em contato com o suporte da Average Tecnologia."

         @ 90,130 BUTTON "OK" SIZE 30,11 ACTION oDlg:end() PIXEL

      ACTIVATE MSDIALOG oDlg CENTERED
   Else
      cMsg := STR0063 + ENTER; //"Falha de integridade com o m�dulo de faturamento."
              + STR0064 + ENTER //"Informa��es"
      If cFase == "EMB
         cMsg += Space(20) + IncSpace(STR0187, 20, .F.) + IncSpace(STR0066, 20, .F.) + ENTER //"Embarque"###"Ped. Venda" //STR0187 "Embarque"
      Else
         cMsg += Space(20) + IncSpace(STR0065, 20, .F.) + IncSpace(STR0066, 20, .F.) + ENTER //"Ped. Exporta��o"###"Ped. Venda"
      EndIf

      cMsg += IncSpace(STR0067, 20, .F.); //"Nro. de Itens:"
              + IncSpace(TransForm(nItensEEC, "999,999,999.99"), 20, .F.) + IncSpace(TransForm(nItensFAT, "999,999,999.99"), 20, .F.) + ENTER;
              + IncSpace(STR0068, 20, .F.); //"Valor Total:"
              + IncSpace(TransForm(nPrecoEEC, "999,999,999.99"), 20, .F.) + IncSpace(TransForm(nPrecoFAT, "999,999,999.99"), 20, .F.) + ENTER;
              + STR0069//"Favor entrar em contato com o suporte da Average Tecnologia."

      EECMsg(cMsg, STR0059)//"Aten��o"
   EndIf

End Sequence

Return lRet
/*
Funcao      : AP100GerPed()
Parametros  : lNewPed  => .t. Inclusao
                          .f. Alteracao
Retorno     : .T.
Objetivos   : Gerar novo pedido para filial exterior.
Autor       : Jeferson Barros Jr.
Data/Hora   : 27/05/2002 16:58
Revisao     :
Obs.        :
*/
*-----------------------------------*
Static Function AP100GerPed(lNewPed)
*-----------------------------------*
Local lRet:=.t.,aOrd:=SaveOrd({"EE7","EE8","EE9"}),nX:=0,nRec:=0,cAlias:="",nRecEE7:=0,nRecFilBr:=0, cCmp:=""
Local lIsOffShore := .f.

Local nInc

//Local cFilBr:=EasyGParam("MV_AVG0023",,""), cFilEx:=EasyGParam("MV_AVG0024",,"")
Local Alias:={},bDel

Local aCmpNotCopy :={}, i

Default lNewPed:=.t. // Inclusao
*
Begin Sequence

   nRecFilBr:=EE7->(RecNo())

   // ** Caso a filial ativa for a mesma que a filial off-shore, o pedido n�o � gerado.
   If Empty(cFilBr) .Or. Empty(cFilEx) .Or. (AvGetM0Fil() == cFilEx)
      Break
   EndIf

   // ** Verifica a flag de OffShore do processo na filial Brasil.
   lIsOffShore := (EE7->EE7_INTERM $ cSim)

   nRecEE7 := EE7->(Recno())
   EE7->(dBSetOrder(1))
   If EE7->(DbSeek(cFilEx+EE7->EE7_PEDIDO))
      If lIsOffShore .And. !lRecriaPed
         Break
      Else
         /* by jbj - 25/06/04 15:45 - Se o pedido estiver cancelado na filial de off-shore
                                      n�o elimina o pedido */
         If EE7->EE7_STATUS = ST_PC
            Break
         EndIf

         EE7->(DbGoTo(nRecEE7))

         // ** By JBJ - 27/08/03 - 11:45 (Deleta o Processo de Exporta��o na Filial Exterior.
         Ap100DelPed(.f.,.f.)
      Endif
   Else
      EE7->(DbGoto(nRecEE7))
   Endif

   If !lIsOffShore
      EE7->(DbGoto(nRecEE7))
      Break
   EndIf

   For nX := 1 TO EE7->(FCount())
       M->&(EE7->(FieldName(nX))) := EE7->(FieldGet(nX))
   Next

   M->EE7_FILIAL := cFilEx
   /*
   M->EE7_OBS    := EE7->(MSMM(EE7_CODMEM,TAMSX3("EE7_OBS")[1],,,LERMEMO))
   M->EE7_MARCAC := EE7->(MSMM(EE7_CODMAR,TAMSX3("EE7_MARCAC")[1],,,LERMEMO))
   M->EE7_OBSPED := EE7->(MSMM(EE7_CODOBP,TAMSX3("EE7_OBSPED")[1],,,LERMEMO))
   M->EE7_GENERI := EE7->(MSMM(EE7_DSCGEN,TAMSX3("EE7_GENERI")[1],,,LERMEMO))
   */
   For nInc := 1 To Len(aMemos)
      M->&(aMemos[nInc][2]) := EasyMSMM(EE7->&(aMemos[nInc][1]),TAMSX3(aMemos[nInc][2])[1],,,LERMEMO,,,"EE7",aMemos[nInc][1])
   Next

   M->EE7_IMPORT := M->EE7_CLIENT
   M->EE7_IMLOJA := M->EE7_CLLOJA
   M->EE7_IMPODE := Posicione("SA1",1,xFilial("SA1")+M->EE7_CLIENT,"A1_NOME")
   M->EE7_ENDIMP := EECMEND("SA1",1,M->EE7_CLIENT+M->EE7_CLLOJA,.T.,,1)
   M->EE7_END2IM := EECMEND("SA1",1,M->EE7_CLIENT+M->EE7_CLLOJA,.T.,,2)
   M->EE7_FORN   := If(!Empty(M->EE7_EXPORT),M->EE7_EXPORT,M->EE7_FORN)
   M->EE7_FOLOJA := If(!Empty(M->EE7_EXLOJA),M->EE7_EXLOJA,M->EE7_FOLOJA)
   M->EE7_INTERM := "2"
   M->EE7_LC_NUM := ""   // By JPP - 12/09/2005 - 14:30 - N�o replicar o n�mero da LC na filial Off-Shore.

// If !Empty(M->EE7_COND2) .And. !Empty(M->EE7_DIAS2) - AMS 01/11/2005.
   If !Empty(M->EE7_COND2)
      SY6->(DBSETORDER(1))
      SY6->(DBSEEK(XFILIAL("SY6")+M->EE7_COND2+STR(M->EE7_DIAS2,3,0)))
      M->EE7_CONDPA := M->EE7_COND2
      M->EE7_DIASPA := M->EE7_DIAS2
      M->EE7_MPGEXP := SY6->Y6_MDPGEXP
      M->EE7_COND2  := ""
      M->EE7_DIAS2  := 0
   EndIf

   If !Empty(M->EE7_INCO2)
      M->EE7_INCOTE := M->EE7_INCO2
      M->EE7_INCO2  := ""
   EndIf

   M->EE7_PERC :=0

   If EasyEntryPoint("EECAP100")
      ExecBlock("EECAP100",.F.,.F.,{"PE_OFFSHORE_GERA_CAPA"})
   Endif
   // ** Define campos que n�o ser�o copiados para a filial de off-shore nos itens
   aCmpNotCopy := {"EE8_DTFIX" , "EE8_ORIGEM", "EE8_QTDLOT",;
                   "EE8_STFIX" , "EE8_ORIGV" , "EE8_DTCOTA",;
                   "EE8_DIFERE", "EE8_MESFIX"}


   If EECFlags("COMMODITY")
      AAdd(aCmpNotCopy,"EE8_RV    ")
      AAdd(aCmpNotCopy,"EE8_DTRV  ")
      AAdd(aCmpNotCopy,"EE8_DTVCRV")
      AAdd(aCmpNotCopy,"EE8_SEQ_RV")
   EndIf

   // ** Grava os itens ...
   //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
   AvZap("WorkIt")

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial("EE8")+M->EE7_PEDIDO))

   While EE8->(!Eof()) .AND. EE8->EE8_FILIAL == xFilial("EE8") .AND. EE8->EE8_PEDIDO == M->EE7_PEDIDO
      nRec := EE8->(RecNo())

      For nX := 1 To EE8->(FCount())
         cCmp := EE8->(FieldName(nX))

         /* By JBJ - 26/04/04 - Verifica se o campo pode ser copiado para a filial
                                de off-shore. (Obedece array aCmpNotCopy) */
         If aScan(aCmpNotCopy,cCmp) = 0
            M->&(EE8->(FIELDNAME(nX))) := EE8->(FieldGet(nX))
         EndIf
      Next

      //AOM - 20/05/2011
      If lOperacaoEsp
         M->EE8_DESOPE := Posicione('EJ0',1,xFilial('EJ0') + M->EE8_CODOPE ,'EJ0_DESC')
      EndIf

      If !Empty(M->EE8_PRENEG)
         M->EE8_PRECO:=M->EE8_PRENEG
         If EECFlags("CAFE") // By JPP - 17/01/2006 - 11:25
            Ap104GatPreco("EE8_PRECO",.T.,"M")
         EndIf
      EndIf

      // JPM - 15/03/06 - Grava��o da Unidade de Medida do Pre�o Negociado
      If EE8->(FieldPos("EE8_UNPRNG")) > 0 .And. !Empty(M->EE8_UNPRNG)
         M->EE8_UNPRC := M->EE8_UNPRNG
      EndIf

      //ER - 28/12/05 �s 14:40
      If EE8->(FieldPos("EE8_DIFE2")) <> 0 .and. !Empty(M->EE8_DIFE2)
         M->EE8_DIFERE := M->EE8_DIFE2
      EndIf
      If EECFlags("ITENS_LC")  // By JPP - 12/09/2005 - 14:30 - N�o replicar o n�mero da LC na filial Off-Shore.
         M->EE8_LC_NUM := ""
         M->EE8_SEQ_LC := ""
      EndIf

      For i:=1 To Len(aMemoItem)
         If EE8->(FieldPos(aMemoItem[i][1])) > 0
            M->&(aMemoItem[i][2]) := EasyMSMM(EE8->&(aMemoItem[i][1]),TAMSX3(aMemoItem[i][2])[1],,,LERMEMO,,,"EE8",aMemoItem[i][1])  // GFP - 17/01/2014
         EndIf
      Next i

      If WorkIt->(RecLock("WorkIt", .T.))
         AVREPLACE("M","WorkIt")

         /* JPM - 24/01/06 - J� est� sendo feito acima.
         WorkIt->EE8_PRECO  := M->EE8_PRENEG
         If EE8->(FieldPos("EE8_DIFE2")) <> 0
            WorkIt->EE8_DIFERE := M->EE8_DIFE2
         EndIf

         For i:=1 To Len(aMemoItem)
            If WorkIt->(FieldPos(aMemoItem[i][2])) > 0
               WorkIt->&(aMemoItem[i][2]) := MSMM(M->&(aMemoItem[i][1]),TAMSX3(aMemoItem[i][2])[1],,,LERMEMO)
            EndIf
         Next i
         */

         WorkIt->(MsUnlock())
      Endif
      EE8->(Dbgoto(nRec))
      EE8->(DbSkip())
   EndDo

   IF EasyEntryPoint("EECPPE09")             // LCS.06/12/2005
      ExecBlock("EECPPE09",.F.,.F.,"PE_GERPED_IT")   // LCS.06/12/2005
   Endif                                 // LCS.06/12/2005
   // ** By CAF 25/06/2003 - Gravar tarefas padrao do cliente
   IF Select("WorkDoc") > 0
      aDocDeletados := {}
      //DFS - 25/10/12 - Troca de DbZap para AvZap devido ao error.log 'Zap function is not supported in DBF'
      AvZap("WorkDoc")
      AddTarefa(Posicione("SA1",1,xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA,"A1_PAIS"),M->EE7_IMPORT+M->EE7_IMLOJA)
      Ap100DocGrava(.f.,OC_PE,cFilEx)
   Endif

   AP100DadosPed("EET",cFilEx) // Grava as despesas ...
   AP100DadosPed("EEB",cFilEx) // Grava as empresas ...
   AP100DadosPed("EEJ",cFilEx) // Grava os bancos   ...
   AP100DadosPed("EEN",cFilEx) // Grava notifys     ...

   AP100PRECOI(.t.)  // Recalcula Precos ...

   // ** Grava os itens ..
   Workit->(DbGotop())
   While !WorkIt->(Eof())
      If EE8->(RecLock("EE8",.T.))
         AVReplace("WorkIt","EE8")

         EE8->EE8_FILIAL := cFilEx
         EE8->EE8_PRENEG:=0

         If EE8->(FieldPos("EE8_UNPRNG")) > 0 // JPM - 15/03/06 - Unidade de medida do pre�o negociado.
            EE8->EE8_UNPRNG := ""
         EndIf

         For i:=1 To Len(aMemoItem)
            If EE8->(FieldPos(aMemoItem[i][1])) > 0
               EasyMSMM(,TAMSX3(aMemoItem[i][2])[1],,WorkIt->&(aMemoItem[i][2]),INCMEMO,,,"EE8",aMemoItem[i][1])
            EndIf
         Next i

         EE8->(MsUnlock())
      Endif
      WorkIt->(dbSkip())
   Enddo

   // ** Grava o pedido ...
   If EE7->(RecLock("EE7", .T.))
      AvReplace("M","EE7")
      EE7->EE7_FILIAL := cFilEx

      For nInc := 1 to Len(aMemos)
         EasyMSMM(,TAMSX3(aMemos[nInc][2])[1],,M->&(aMemos[nInc][2]),INCMEMO,,,"EE7",aMemos[nInc][1])
      Next

      /*
      MSMM(,TAMSX3("EE7_OBS")[1],,M->EE7_OBS,INCMEMO,,,"EE7","EE7_CODMEM")
      MSMM(,TAMSX3("EE7_MARCAC")[1],,M->EE7_MARCAC,INCMEMO,,,"EE7","EE7_CODMAR")
      MSMM(,TAMSX3("EE7_OBSPED")[1],,M->EE7_OBSPED,INCMEMO,,,"EE7","EE7_CODOBP")
      MSMM(,TAMSX3("EE7_GENERI")[1],,M->EE7_GENERI,INCMEMO,,,"EE7","EE7_DSCGEN")
      */
      EE7->(MsUnLock())
   Endif

   //** AAF - 03/09/04 - Grava��o das Invoices a Pagar em caso de Back To Back
   //If lBACKTO
   //   AP106BtBGrv(OC_PE)
   //Endif
   //**

End Sequence

EE7->(DbGoTo(nRecFilBr))

RestOrd(aOrd)

Return lRet
/*
Funcao      : AP100CanPed(cFil)
Parametros  : cFil -> Filial para cancelamento do pedido.
Retorno     : .T.
Objetivos   : Cancelar pedido na filial do exterior
Autor       : Jeferson Barros Jr.
Data/Hora   : 28/05/2002 11:36
Revisao     :
Obs.        :
*/
*-------------------------------*
Function AP100CanPed(cFil)
*-------------------------------*
Local lRet:=.t.,lChkFilBr, aOrd:=SaveOrd("EE7")
//Local cFilEx := AvKey(EasyGParam("MV_AVG0024",,""),"EE7_FILIAL")

Begin Sequence

   IF AllTrim(cFilEx) == "."
      cFilEx := AvKey("","EE7_FILIAL")
   Endif

   EE7->(dBSetOrder(1))

   lChkFilBr := (cFil == cFilEx)
   If lChkFilBr
      If !(EE7->EE7_INTERM $ cSim)
         Break
      EndIf
   Else
      If EE7->(DbSeek(cFil+EE7->EE7_PEDIDO))
         If !(EE7->EE7_INTERM $ cSim)
            Break
         EndIf
      EndIf
   EndIf

   If EE7->(DbSeek(cFil+EE7->EE7_PEDIDO))

      Reclock("EE7",.F.)

      //eliminar descricoes
      EE8->(DbSetOrder(1))
      If EE8->(DbSeek(cFil+EE7->EE7_PEDIDO))
         While EE8->(!Eof()) .And. cFil+EE7->EE7_PEDIDO == EE8->EE8_FILIAL+EE8->EE8_PEDIDO
             RecLock("EE8",.F.)
             EE8->EE8_STATUS := ST_PC
             /* ER - 09/08/05 - 13:00 - Na op��o de cancelamento de pedidos o saldo a embarcar
                                        dos itens, dever� ser zerado visto que como o pedido n�o
                                        poder� ser utilizado, o saldo deve ser nulo. */
             EE8->EE8_SLDATU := 0

             EE8->(MsUnlock())
             EE8->(DBSKIP(1))
         End
      EndIf

      //cancelar pedido
      EE7->EE7_FIM_PE:=dDATABASE
      EE7->EE7_STATUS:=ST_PC

      //atualizar descricao de status
      DSCSITEE7(.T.)

      EE7->(MsUnlock())
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AP100DelPed(lIsFilBr, lShowMsg).
Parametros  : lIsFilBr  = .t. - Filial Brasil (Default).
                          .f. - Filial Exterior.
              lShowMsg  = .t. - Exibe Mensagens (Default).
                          .f. - N�o exibe mensagens.
              lCallPE   = .t. - Dispara o ponto de entrada eecap100 (PE_EXC) (Default).
                          .f. - N�o dispara o ponto de entrada.
              lEliminar = .t. - Chamada na rotina de elimina��o de pedidos.
                          .f. - Outras chamadas (Default).
Retorno     : .f.
Objetivos   : Deletar Processo de Exporta��o - (Tabelas Utilizadas na Manuten��o de Pedidos).
Autor       : Jeferson Barros Jr.
Data/Hora   : 27/08/2003 10:45.
Revisao     :
Obs.        :
*/
*-------------------------------------------------------*
Function AP100DelPed(lIsFilBr,lShowMsg,lCallPE,lEliminar)
*-------------------------------------------------------*
Local aOrd:=SaveOrd({"EE7","EE8"}), aAlias:={}
Local lRet:=.t., lMV_0044, cProc
Local cFilAux
Local cFilBr1 := cFilBr
//Local cFilBr:=AvKey(EasyGParam("MV_AVG0023",,""),"EE7_FILIAL"),;
//      cFilEx:=AvKey(EasyGParam("MV_AVG0024",,""),"EE7_FILIAL")
Local bDel, i
Local nInc

If Type("aMemos") <> "A"
   Private aMemos := {{"EE7_CODMAR","EE7_MARCAC"},;
                      {"EE7_CODMEM","EE7_OBS"},;
                      {"EE7_CODOBP","EE7_OBSPED"},;
                      {"EE7_DSCGEN","EE7_GENERI"}}
EndIf

Default lIsFilBr  := .t.
Default lShowMsg  := .f.
Default lCallPe   := .t.
Default lEliminar := .f.

//AMS - 15/10/2003 �s 10:40.
If Val( cFilBr1 ) = 0
   cFilBr1 := xFilial("EE7")
EndIf

Begin Sequence

   cFilAux := If(lIsFilBr,cFilBr1,cFilEx)

   aAlias:={;
           {"EE8",1,cFilAux + EE7->EE7_PEDIDO, {||cFilAux==EE8->EE8_FILIAL.AND.EE7->EE7_PEDIDO==EE8->EE8_PEDIDO}},;
           {"EEB",1,cFilAux + EE7->EE7_PEDIDO+OC_PE, {||cFilAux==EEB->EEB_FILIAL.AND.EE7->EE7_PEDIDO==EEB->EEB_PEDIDO.AND.EEB->EEB_OCORRE==OC_PE}},;
           {"EEJ",1,cFilAux + EE7->EE7_PEDIDO+OC_PE, {||cFilAux==EEJ->EEJ_FILIAL.AND.EE7->EE7_PEDIDO==EEJ->EEJ_PEDIDO.AND.EEJ->EEJ_OCORRE==OC_PE}},;
           {"EEK",2,cFilAux + OC_PE+EE7->EE7_PEDIDO, {||cFilAux==EEK->EEK_FILIAL.AND.EE7->EE7_PEDIDO==EEK->EEK_PEDIDO.AND.EEK->EEK_TIPO  ==OC_PE}},;
           {"EET",1,cFilAux + AvKey(EE7->EE7_PEDIDO,"EET_PEDIDO")+OC_PE, {||cFilAux==EET->EET_FILIAL .AND. AvKey(EE7->EE7_PEDIDO,"EET_PEDIDO")==EET->EET_PEDIDO.AND.EET->EET_OCORRE==OC_PE}},;
           {"EEN",1,cFilAux + EE7->EE7_PEDIDO+OC_PE, {||cFilAux==EEN->EEN_FILIAL .AND.EE7->EE7_PEDIDO==EEN->EEN_PROCES .AND.EEN->EEN_OCORRE==OC_PE}},;
           {"EXB",1,cFilAux + Space(AVSX3("EE7_PEDIDO",AV_TAMANHO))+EE7->EE7_PEDIDO, {||cFilAux==EXB->EXB_FILIAL .AND. EE7->EE7_PEDIDO==EXB->EXB_PEDIDO .And. Empty(EXB->EXB_PREEMB)}},;
           {"EEY",2,cFilAux + EE7->EE7_PEDIDO,{||cFilAux==EEY->EEY_FILIAL .AND. EEY->EEY_PEDIDO==EE7->EE7_PEDIDO}},;
           ;//** AAF 10/09/04 - Exclus�o do Back To Back
           {"EXK",1,cFilAux + OC_PE + EE7->EE7_PEDIDO,{||cFilAux==EXK->EXK_FILIAL .AND. EXK->EXK_TIPO == OC_PE .AND. EXK->EXK_PROC==EE7->EE7_PEDIDO}}}
           //**

   bDel:={||RecLock(Alias(),.F.),(Alias())->(DbDelete()),(Alias())->(MsUnlock())}

   /*
   bDelMemo := {|| MSMM(EE7->EE7_CODMAR,,,,EXCMEMO),;
                   MSMM(EE7->EE7_CODOBP,,,,EXCMEMO),;
                   MSMM(EE7->EE7_CODMEM,,,,EXCMEMO),;
                   MSMM(EE7->EE7_DSCGEN,,,,EXCMEMO)}
   */

   If lIsFilBr // **  Filial Brasil.

      Begin Transaction

         // ** Deleta os campos memo da capa do processo.
         //Eval(bDelMemo)
         For nInc:= 1 To Len(aMemos)
            EasyMSMM(EE7->&(aMemos[nInc][1]),,,,EXCMEMO,,,"EE7",aMemos[nInc][1])
         Next

         // ** Deleta os campos memo do(s) item(ns) do processo.
         EE8->(DbSetOrder(1))
         EE8->(DbSeek(cFilBr1+EE7->EE7_PEDIDO))
         Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFilBr1 .And. EE8->EE8_PEDIDO == EE7->EE7_PEDIDO
            For i:=1 To Len(aMemoItem)
               If EE8->(FieldPos(aMemoItem[i][1])) > 0
                  EasyMSMM(EE8->&(aMemoItem[i][1]),,,,EXCMEMO,,,"EE8",aMemoItem[i][1])
               EndIf
            Next
            EE8->(DbSkip())
         EndDo

         If Type("lEE7Auto") == "U" .OR. !lEE7Auto  // TRP - 19/07/2012
            Processa({||ProcRegua(LEN(aAlias)),;
                        AeVal(aAlias,{|aArq| If(Select(aArq[1]) > 0,AP100Del(aArq,bDel),nil)}) }, STR0025) //"Processando Estorno..."
         Else
            AeVal(aAlias,{|aArq| If(Select(aArq[1]) > 0,AP100Del(aArq,bDel),nil)})
         EndIf

         If (lIntermed .And. (EE7->EE7_INTERM $ cSim) .And. AvGetM0Fil() == cFilBr1)
            AP100DelPed(.f.,nil,nil,lEliminar)
         EndIf

         //Alcir - 25/08/04
         If EasyEntryPoint("EECAP100")
             ExecBlock("EECAP100",.F.,.F.,{ "ESTORNO_PEDIDO" })
         Endif
         EE7->(RecLock("EE7",.f.))
         EE7->(DbDelete())

      End Transaction

   Else // ** Processo de exporta��o na Filial Exterior.

      // ** Flag p/ controle de exibi��o de msgs na exclusao de processos na filial exterior.
      lMv_0044 := EasyGParam("MV_AVG0044",,.f.)

      nRecEE7  := EE7->(Recno())

      EE7->(dBSetOrder(1))
      If !EE7->(DbSeek(cFilEx+EE7->EE7_PEDIDO))
         EE7->(DbGoTo(nRecEE7))
         lRet:=.f.
         Break
      EndIf

      Begin Transaction
         // ** Deleta os campos memo da capa do processo.
         //Eval(bDelMemo)
         For nInc:= 1 To Len(aMemos)
            EasyMSMM(EE7->&(aMemos[nInc][1]),,,,EXCMEMO,,,"EE7",aMemos[nInc][1])
         Next

         // ** Deleta os campos memo do(s) item(ns) do processo.
         EE8->(DbSetOrder(1))
         EE8->(DbSeek(cFilEx+EE7->EE7_PEDIDO))
         Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFilEx .And.;
                                      EE8->EE8_PEDIDO == EE7->EE7_PEDIDO
            For i:=1 To Len(aMemoItem)
               If EE8->(FieldPos(aMemoItem[i][1])) > 0
                  EasyMSMM(EE8->&(aMemoItem[i][1]),,,,EXCMEMO,,,"EE8",aMemoItem[i][1])
               EndIf
            Next
            EE8->(DbSkip())
         EndDo

         If Type("lEE7Auto") == "U" .OR. !lEE7Auto // TRP - 19/07/2012
            Processa({||ProcRegua(LEN(aAlias)),;
                        AeVal(aAlias,{|aArq| If(Select(aArq[1]) > 0,AP100Del(aArq,bDel),nil)}) },;
                        STR0071) //"Apagando pedido na filial do exterior..."
         Else
            AeVal(aAlias,{|aArq| If(Select(aArq[1]) > 0,AP100Del(aArq,bDel),nil)})
         EndIf

         cProc := EE7->EE7_PEDIDO
         //Alcir - 25/08/04
         If EasyEntryPoint("EECAP100")
             ExecBlock("EECAP100",.F.,.F.,{ "ESTORNO_PEDIDO_EXT"} )
         Endif
         EE7->(RecLock("EE7",.f.))
         EE7->(DbDelete())

         If lEliminar
            If EE7->(DbSeek(cFilBr1+cProc))
               AP100DelPed()
            EndIf
         EndIf

      End Transaction

      EE7->(DbGoto(nRecEE7))
   EndIf

   //AOM - 27/04/2011 - Operacao Especial
   If lOperacaoEsp
      oOperacao:SaveOperacao()
   EndIf

   If lCallPe
      IF EasyEntryPoint("EECAP100")
         ExecBlock("EECAP100",.F.,.F.,{"PE_EXC"})
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AP100DadosPed()
Parametros  : cAlias => Alias do arquivo a ser pesquisado
              cFilEx => Filial do exterior
Retorno     : .T.
Objetivos   : Gravar Despesas, Bancos, Notifys e empresas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 27/05/2002 17:40
Revisao     :
Obs.        :
*/
*-----------------------------------*
Function AP100DadosPed(cAlias,cFilEx)
*-----------------------------------*
Local lRet:=.t., nRecNo:=0, nX:=0,nOldArea:=Select()
Local lRepDespNac := EasyGParam("MV_AVG0173",.F.,.T.)

Begin Sequence

   (cAlias)->(DbSeek(xFilial(cAlias)+M->EE7_PEDIDO))

   ///////////////////////////////////////////////////////////////////////////////////
   //ER - 04/11/2008                                                                //
   //Atrav�s do parametro MV_AVG0173, define se as informa��es de despesas nacionais//
   //ser�o ou n�o replicadas para a Filial Off-Shore.                               //
   ///////////////////////////////////////////////////////////////////////////////////
   If !lRepDespNac
      If cAlias == "EET"
         lRet := .F.
         Break
      EndIf
   EndIf

   While (cAlias)->(!Eof()) .And. Eval(fieldwblock(cAlias+If(cAlias # "EEN","_PEDIDO","_PROCES"),Select(cAlias))) == M->EE7_PEDIDO .And. ; //   While (cAlias)->(!Eof()) .And. (cAlias)->&(AllTrim(cAlias)+"_PEDIDO") == M->EE7_PEDIDO .And. ;
         Eval(fieldwblock(cAlias+"_FILIAL",Select(cAlias))) == xFilial(cAlias)

      ///////////////////////////////////////////////////////////////
      //ER - 04/11/2008                                            //
      //Apenas as empresas que n�o s�o do tipo "Agente de Comiss�o"//
      //ser�o gravadas na Filial Off-Shore                         //
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
   Enddo

End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : IsIntFat()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Verificar se o sistema est� integrado ou n�o com o sigafat
Autor       : Jeferson Barros Jr.
Data/Hora   : 29/05/2002 16:54
Revisao     :
Obs.        :
*/
*-------------------*
Function IsIntFat()
*-------------------*
Local lRet:=.t., cFilEx:=""

Begin Sequence

   If EasyGParam("MV_AVG0024",.T.,)
      cFilEx:=EasyGParam("MV_AVG0024",.F.,)
      IF AllTrim(cFilEx) == "."
         cFilEx := Space(Len(AvGetM0Fil()))//AvKey("","EE7_FILIAL") - RMD - 10/04/07 - Na chamada da MenuDef, o dicion�rio de dados n�o est� dispon�vel.
      Endif

      If !Empty(cFilEx)
         If cFilEx == AvGetM0Fil()
            lRet:=.f.
            Break
         EndIf
      EndIf
   EndIf

   If IsProcNotFat()
      lRet := .F.
      Break
   EndIf

   lRet:=EasyGParam("MV_EECFAT",.f.,)

End Sequence

Return lRet

/*
Funcao      : IsProcNotFat()
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Avaliar se est� sendo executada alguma das op��es de processo que n�o geram faturamento, mesmo se a integra��o estiver ligada.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 29/05/2009
*/
Function IsProcNotFat()
Local lRet := .F.

   If Type("cTipoProc") == "C"
      /*
         A exist�ncia da vari�vel Private cTipoProc indica que as op��es de processo diferenciadas (Back to Back, Remessa, etc.) est�o ativas,
         e seu conte�do indica o tipo de processo que est� sendo executado.
         Nos tipos de processo onde a mercadoria n�o circula pelo pa�s, n�o � necess�ria a gera��o de nota fiscal, portanto n�o � feita integra��o com o faturamento.
         Os processos onde a mercadoria n�o circula pelo pa�s s�o:
      */
      Do Case
         //Processo de Back to Back Regular;
         Case cTipoProc == PC_BN
            lRet := .T.

         //Remessa por consigna��o com Back To Back;
         Case cTipoProc == PC_BC
            lRet := .T.

         //Pedido de Venda por Consigna��o;
         Case cTipoProc == PC_VC
            lRet := .T.

         //Embarque de Venda Regular;
         Case cTipoProc == PC_VR
            lRet := .T.

         //Embarque de Venda com Back To Back.
         Case cTipoProc == PC_VB
            lRet := .T.
      End Case
   EndIf

Return lRet

/*
Funcao      : AP100Rename()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Renomear pedido.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/06/2002 16:04
Revisao     :
Obs.        :
*/
*---------------------*
Function AP100Rename()
*---------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EEC","EE9","EE8","EET","EEN","EEB","EEJ"})
Local cNewNroProc:="",cOldNroProc:=EE7->EE7_PEDIDO
Local nRecNo, nRecNoAtual, i

// Array com os arquivos de itens do pedido e embarque ...
Local aPedEmb:={"EE8","EE9"}

// Array com os arquivos de Despesas, Empresas, Notifys e Bancos...
Local aFiles:={"EET","EEN","EEB","EEJ"}

Begin Sequence

   EE7->(RecLock("EE7",.F.))
   cNewNroProc:=GetNewNumber()

   If Empty(cNewNroProc)
      EE7->(MsUnlock())
      Break
   EndIf

   // Atualiza o EE7 ...
   EE7->EE7_PEDIDO:=cNewNroProc

   Begin Transaction

      // Atualiza o EE8,EEC,EE9 ...
      For i:=1 To Len(aPedEmb)
         (aPedEmb[i])->(DbSetOrder(1))
         If (aPedEmb[i])->(DbSeek(xFilial(aPedEmb[i])+cOldNroProc))
            Do While (aPedEmb[i])->(!Eof()) .And.;
               (aPedEmb[i])->&(aPedEmb[i]+"_FILIAL")+(aPedEmb[i])->&(aPedEmb[i]+"_PEDIDO") == xFilial(aPedEmb[i])+cOldNroProc

               nRecNoAtual:=(aPedEmb[i])->(RecNo())
               (aPedEmb[i])->(DbSkip())
               nRecNo:=(aPedEmb[i])->(RecNo())
               (aPedEmb[i])->(DbGoTo(nRecNoAtual))

               If aPedEmb[i] == "EE9"
                  EEC->(DbSetOrder(1))
                  If EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB))
                     If EEC->EEC_PEDREF == cOldNroProc
                        EEC->(RecLock("EEC",.F.))
                        EEC->EEC_PEDREF:=cNewNroProc
                     EndIf
                  EndIf
               EndIf

               // ** Atualiza o nro do pedido
               (aPedEmb[i])->(RecLock(aPedEmb[i],.F.))
               (aPedEmb[i])->&(aPedEmb[i]+"_PEDIDO"):=cNewNroProc

               (aPedEmb[i])->(DbGoTo(nRecNo))
            EndDo
         EndIf
      Next

      // Atualiza o EET, EEN, EEB, EEJ ...
      For i:=1 To Len(aFiles)

         (aFiles[i])->(DbSetOrder(1))
         (aFiles[i])->(DbSeek(xFilial(aFiles[i])+cOldNroProc+OC_PE))

         While (aFiles[i])->(!Eof()) .And. Eval(fieldwblock(aFiles[i]+If(aFiles[i] # "EEN","_PEDIDO","_PROCES"),Select(aFiles[i]))) == cOldNroProc .And.;
               Eval(fieldwblock(aFiles[i]+"_FILIAL",Select(aFiles[i]))) == xFilial(aFiles[i]) .And.;
               (aFiles[i])->&(aFiles[i]+"_OCORRE")==OC_PE

            nRecNoAtual:=(aFiles[i])->(RecNo())
            (aFiles[i])->(DbSkip())
            nRecNo:=(aFiles[i])->(RecNo())
            (aFiles[i])->(Dbgoto(nRecNoAtual))

            (aFiles[i])->(Reclock(aFiles[i],.f.))
            (aFiles[i])->&(aFiles[i]+If(aFiles[i] # "EEN","_PEDIDO","_PROCES")):=cNewNroProc

            (aFiles[i])->(Dbgoto(nRecno))
         Enddo
      Next

   End Transaction

   MsgInfo(AllTrim(AVSX3("EE7_PEDIDO",AV_TITULO))+STR0074,STR0036) //" renomeado com sucesso."###"Aviso"

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : GetNewNumber()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Tela para entrada do novo numero do pedido.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/06/2002 15:17
Revisao     :
Obs.        :
*/
*----------------------------*
Static Function GetNewNumber()
*----------------------------*
Local cRet:="",cNewPedido:=Space(AVSX3("EE7_PEDIDO",AV_TAMANHO)),cOldPedido:="",nOpcA:=0
Local bOk := {|| nOpcA := 1, oDlg:End() }
Local bCancel := {|| oDlg:End()}
Local oDlg

Begin Sequence

   cOldPedido:=EE7->EE7_PEDIDO

   DEFINE MSDIALOG oDlg TITLE STR0075 FROM 10,12 TO 20.5,47 OF oMainWnd //"Renomear "

   @ 1.1, 0.5 TO 5.5,17 LABEL AVSX3("EE7_PEDIDO",AV_TITULO) OF oDlg

   @ 1.8, 4.5 SAY STR0076 OF oDlg SIZE 35,9 //"Nro. Antigo"
   @ 2.4, 4.5 MSGET cOldPedido  SIZE 70,07  PICTURE AVSX3("EE7_PEDIDO",AV_PICTURE) OF oDlg WHEN .f.

   @ 3.8, 4.5 SAY STR0077   OF oDlg SIZE 35,9 //"Nro. Novo"
   @ 4.4, 4.5 MSGET cNewPedido SIZE 70,07 PICTURE AVSX3("EE7_PEDIDO",AV_PICTURE) VALID ValNewNumber(cNewPedido) OF oDlg

   xx := ""
   @ 1000, 1 MSGET xx SIZE 1,1

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   If nOpca = 1
      cRet:=cNewPedido
   EndIf

End Sequence

Return cRet

Static Function ValNewNumber(cPed)
lRet := .t.
Begin Sequence

   If !(NaoVazio(cPed) .And. ExistChav("EE7",cPed,1))
      lRet := .f.
      Break
   EndIf

   If EE8->(FieldPos("EE8_ORIGV")) > 0 // JPM - 25/11/05
      If Left(cPed,1) = "*"
         EasyHelp(StrTran(STR0147,"###",AllTrim(AvSx3("EE7_PEDIDO",AV_TITULO))), STR0059) // "O ### n�o pode come�ar com '*', pois este prefixo � utilizado em controles internos do sistema." ### "Aten��o"
         lRet := .f.
         Break
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : SumFobIt()
Parametros  : cCodAge - C�digo do Agente.
Retorno     : nTotFob - Total Fob.
Objetivos   : Apurar o valor Fob total dos itens em que o agente est� vinculado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/12/2004 14:42
Revisao     :
Obs.        : JPM - Tratamento de Tipo de Comiss�o por Item - par�metro cTipCom
              Considera que est� posicionado corretamente na work de agentes
*/
*----------------------------------------*
Static Function SumFobIt(cCodAge,cTipCom)
*----------------------------------------*
//Local nTotFob:=0
Local aOrd:=SaveOrd({"WorkIt"})
Local lFobDescontado := EasyGParam("MV_AVG0086",,.f.)
Local lTipCom := EE8->(FieldPos("EE8_TIPCOM")) > 0
Private nFobTotAux := 0
Private nFobTot:= 0
Default cTipCom := ""

Begin Sequence

   If Empty(cCodAge) .Or. (lTipCom .And. Empty(cTipCom))
      Break
   EndIf

   cCodAge := AvKey(cCodAge,"EEB_CODAGE")
   cTipCom := AvKey(cTipCom,"EEB_TIPCOM")

   If !AvFlags("COMISSAO_VARIOS_AGENTES") .Or.;         // faz o loop se n�o for o tratamento de comiss�o com mais de um agente por item
      WorkAg->EEB_TIPCVL = "3"  // e se for, s� faz o loop se forem agentes de comiss�o percentual por item,
                                // pois apenas agentes deste tipo s�o vinculados a itens neste tratamento
      WorkIt->(DbGoTop())
      Do While WorkIt->(!Eof())

         If (WorkIt->EE8_CODAGE == cCodAge) .And.;
            If(lTipCom,WorkIt->EE8_TIPCOM == cTipCom,.t.)

            nFobTot += WorkIt->EE8_PRCINC - If(lFobDescontado,WorkIt->EE8_VLDESC,0)
         EndIf

         //TRP-12/09/07
         If EasyEntryPoint("EECAP100")
            nFobTotAux := 0 //ER - 03/10/2007 - Cria��o da variavel e altera��o do Local do PE, para dentro do Looping.
            ExecBlock("EECAP100",.F.,.F.,{ "CALC_FOBTOT",WorkIt->EE8_CODAGE })
            nFobTot += nFobTotAux
         Endif

         WorkIt->(DbSkip())
      EndDo

   Else
      nFobTot := EECFob(OC_PE) - If(lFobDescontado,M->EE7_DESCON,0)
   EndIf

End Sequence

RestOrd(aOrd)

Return nFobTot

/*
Funcao      : Ap100InitFil
Parametros  :
Retorno     :
Objetivos   : Inicializar (ou refresh) vari�veis cFilEx e cFilBr
Autor       : Jo�o Pedro Macimiano Trabbold
Data/Hora   : 12/03/05 - 11:44
Revisao     :
Obs.        :
*/
*----------------------------------*
Function Ap100InitFil()
*----------------------------------*
cFilBr := EasyGParam("MV_AVG0023",,"")
cFilBr := IF(ALLTRIM(cFilBr)=".","",cFilBr)
cFilEx := EasyGParam("MV_AVG0024",,"")
cFilEx := IF(ALLTRIM(cFilEx)=".","",cFilEx)

Return Nil

/*
Funcao      : Ap100UnLock().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Disparar o MsUnLockAll() para todas as tabelas utilizadas na rotina de pedidos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/06/05 - 11:15.
Revisao     :
Obs.        :
*/
*---------------------------*
Static Function Ap100UnLock()
*---------------------------*
Local lRet:=.t.
Local j:=0
Local aAlias := {}
Local nOldArea := Select()

Begin Sequence

   aAlias:={"EE7","EE8","EEB","EEJ","EEK","EET","EEN","EXB","EEY","EXK"}

   For j:=1 To Len(aAlias)
      If Select(aAlias[j]) > 0
         (aAlias[j])->(MsUnLockAll())
      EndIf
   Next

End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : Ap100VldExc().
Parametros  : Alias com base no qual ser�o feitas as valida��es
Retorno     : .t./.f.
Objetivos   : Reunir todas as fun��es (ou chamadas de fun��es) para validar exclus�o
Autor       : Jo�o Pedro Macimiano Trabbold
Data/Hora   : 14/10/05
Chamadas    : Antes de abrir a tela de detalhes, quando do tipo EXC_DET
              Ao tentar excluir uma linha na MsGetDb de consolida��o de itens (Work: AuxIt)
Obs.        :
*/
*--------------------------*
Function Ap100VldExc(cAlias)
*--------------------------*
Local lRet := .t.

Default cAlias := "WorkIt"
Default lPerguntou := .f.

Begin Sequence

   If !Ap102VldExcIt(cAlias) // By JPP - 19/08/2005 - 09:55 - N�o permitir a exclus�o de itens vinculados a embarque.
      lRet := .f.
      Break
   EndIf

   // ** By JBJ - 01/07/02 - 9:49 ...
   If !lPerguntou .And. lCommodity .And. !Empty(&(cAlias+"->EE8_DTFIX"))
      If !MsgYesNo(STR0124,STR0024) //"Item com pre�o fixado. Deseja continuar o processo de exclus�o?"###"Aten��o"
         lRet := .f.
         Break
      Else
         lPerguntou := .t.
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : Ap100AcDic()
Parametros  : Nenhum
Retorno     : Nil
Objetivos   : Atualizar dicion�rio de acordo com os tratamentos parametrizados
Autor       : Jo�o Pedro Macimiano Trabbold
Data/Hora   : 19/12/05
Obs.        :
*/

*--------------------------*
Static Function Ap100AcDic()
*--------------------------*
Local cPasta, aCpos, i
/* wfs 29/set/2017
   retirada a atribui��o � metadados

Begin Sequence
   SX3->(DbSetOrder(2))
   aCpos := {"EE8_PRECO "/*,"EE8_PRECO2","EE8_PRECO3","EE8_PRECO4","EE8_PRECO5"*//*,"EE8_UNPRC"}
                         // DFS - Nopado para que respeite o valor do conte�do do X3_FOLDER do Dicion�rio de Dados
   cPasta := PastaFix()

   If EECFlags("COMMODITY")
      For i := 1 To Len(aCpos)
         If SX3->(DbSeek(aCpos[i]))
            If cPasta <> SX3->X3_FOLDER
               SX3->(RecLock("SX3",.F.))
               SX3->X3_FOLDER := cPasta
               SX3->(MsUnlock())
            EndIf
         EndIf
      Next
   Else
      For i := 1 To Len(aCpos)
         If SX3->(DbSeek(aCpos[i]))
            If cPasta = SX3->X3_FOLDER
               SX3->(RecLock("SX3",.F.))
               SX3->X3_FOLDER := "1"
               SX3->(MsUnlock())
            EndIf
         EndIf
      Next
   EndIf
End Sequence
*/
Return Nil

/*
Fun��o     : Ap100GatPreNeg()
Objetivos  : Executar gatilho do campo de pre�o negociado.
Retorno    : Pre�o calculado de acordo com o pre�o negociado e a % Off-Shore.
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 15/03/06 - 14:05
*/
*-----------------------------*
Function Ap100GatPreNeg(cAlias)
*-----------------------------*
Local nPreco, aOrd

Default cAlias := "M"

   If Empty((nPreco := &(cAlias+"->EE8_PRENEG")))
      Return &(cAlias+"->EE8_PRECO")
   EndIf

   If M->EE7_PERC > 0
      nPreco := nPreco - nPreco * (M->EE7_PERC/100)
   EndIf

   If Type("EE8->EE8_UNPRNG") <> "U"
      nPreco := AvTransUnid(&(cAlias+"->EE8_UNPRNG"),&(cAlias+"->EE8_UNPRC"),&(cAlias+"->EE8_COD_I"), nPreco,.F.,.T.)
   EndIf

Return nPreco

/*
Fun��o     : Ap100GatPerc()
Objetivos  : Executar gatilho do campo de percentual Off-Shore.
Retorno    : .T.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 20/02/09
*/
Function Ap100GatPerc()
Local nPreco := 0

   If Select("WorkIt") > 0 .And. MsgYesNo(STR0188, STR0036) //STR0188 "Deseja atualizar o pre�o?" //STR0036	  "Aviso"
      WorkIt->(DbGoTop())
      While WorkIt->(!Eof())
         nPreco := WorkIt->EE8_PRECO + (WorkIt->EE8_PRECO * (M->EE7_PERC/100))
         If EE8->(FieldPos("EE8_UNPRNG")) > 0
            WorkIt->EE8_PRENEG := AvTransUnid(WorkIt->EE8_UNPRNG,WorkIt->EE8_UNPRC,WorkIt->EE8_COD_I, nPreco,.F.,.T.)
         Else
            WorkIt->EE8_PRENEG := nPreco
         EndIf
         WorkIt->(DbSkip())
      EndDo
   EndIf

Return .T.

/*
Fun��o     : PossuiQuebra
Objetivos  : Verificar se os itens do pedido possuem quebra
Retorno    : .T. - Possui quebra / .F. - N�o possui
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 06/05/08
*/
Static Function PossuiQuebra()
Local lRet := .F.
Local nRecIP

   If Select("WorkGrp") > 0
      nRecIP := WorkIt->(Recno())
      WorkIt->(DbGoTop())
      While WorkIt->(!Eof())
         If !Empty(WorkIt->EE8_ORIGV) .And. (WorkIt->EE8_SEQUEN <> WorkIt->EE8_ORIGV)
            lRet := .T.
            Exit
         EndIf
         WorkIt->(DbSkip())
      EndDo
   EndIf
   WorkIt->(DbGoTo(nRecIp))

Return lRet

Static Function AjustaDimensao()
   Local oGet_x, cGet_x := ""
   @3000,3000 MsGet oGet_x Var cGet_x Of oMainWnd
return nil


/*
Funcao          : AP100ELIMRES()
Parametros      : Nenhum
Retorno         : Nil
Objetivos       : Selecionar itens do pedido de exporta��o para elimina��o de saldo, incluindo saldo no pedido de venda.
Autor           : Rodrigo Mendes Diaz
Data            : 27/07/11
*/
Function AP100ELIMRES()
Local oBrowse
Local oColumn
Local oDlg
Local cCadastro		:= STR0189 //STR0189	"Selecione os itens desejados para elimina��o de saldo:"
Local bValid		:= {|| If(Len(aItens) > 0, MsgYesNo(STR0190, STR0024), (MsgInfo(STR0191, STR0036), .F.))} //STR0190	"Confirma a elimina��o de saldo dos itens selecionados?" //STR0024 	"Aten��o" //STR0191	"Selecione ao menos um item para a elimina��o de saldo." //STR0036	  "Aviso"
Local bAcao  		:= {|| (EliminaResiduo(aItens), oDlg:End()) }
Local bOk 			:= {|| If(Eval(bValid), Eval(bAcao), Nil) }
Local bCancel		:= {|| oDlg:End() }
Local aCampos		:= {"EE8_FILIAL", "EE8_PEDIDO", "EE8_SEQUEN", "EE8_COD_I", "EE8_FORN", "EE8_FOLOJA", "EE8_FABR", "EE8_FALOJA", "EE8_UNIDAD", "EE8_SLDATU", "EE8_PSLQTO", "EE8_PSBRTO"}
Local bMarca		:= {|| If((nPos := aScan(aItens, EE8_SEQUEN)) == 0, aAdd(aItens, EE8_SEQUEN), (aDel(aItens, nPos), aSize(aItens, Len(aItens)-1))) }
Local bMarcaTodos	:= {|oBrowse| If(Len(aItens) > 0, aItens := {}, aItens := GetAllItens()), oBrowse:Refresh() }
Local nInc
Private aItens		:= {}

DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL

	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "EE8" OF oDlg

		ADD MARKCOLUMN oColumn DATA { || If(aScan(aItens, EE8->EE8_SEQUEN) == 0, 'LBNO', 'LBOK') } DOUBLECLICK bMarca HEADERCLICK bMarcaTodos OF oBrowse
		For nInc := 1 To Len(aCampos)
			ADD COLUMN oColumn DATA &("{ ||" + aCampos[nInc] + " }") TITLE AvSx3(aCampos[nInc], AV_TITULO) SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse
		Next
		oBrowse:SetFilter("EE8_FILIAL+EE8_PEDIDO", xFilial("EE8")+EE7->EE7_PEDIDO, xFilial("EE8")+EE7->EE7_PEDIDO)

	ACTIVATE FWBROWSE oBrowse
	oDlg:lMaximized := .T.

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED


Return Nil

/*
Function: GetAllItens
Autor	: Rodrigo Mendes Diaz
Objetivo: Retornar array com a sequ�ncia de todos os itens do pedido posicionado no EE7.
*/
Static Function GetAllItens()
Local aItens := {}, aOrd := SaveOrd("EE8")

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial()+EE7->EE7_PEDIDO))
   While EE8->(!Eof() .And. EE8_PEDIDO == EE7->EE7_PEDIDO)
      aAdd(aItens, EE8->EE8_SEQUEN)
      EE8->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return aItens

/*----------------------------------------------------------------------------*/
/* Fun��o     : EliminaResiduo                                                */
/* Objetivos  : Verificar se os itens do pedido possuem saldo a ser eliminado */
/* Autor      : Diogo Felipe dos Santos                                       */
/* Data/Hora  : 14/09/10                                                      */
/*----------------------------------------------------------------------------*/
Static Function EliminaResiduo(aItens)

Local cMsg := ""
Local nSaldoElim:= 0
Local lAlterou := .F.
Local lTemNF := .F.
Local lTemEmb:= .F.
EE8->(DbSetOrder(1))
EE9->(DbSetOrder(1))
EE7->(dbSetOrder(1))
SD2->(dbSetORder(8))
If EE8->(DbSeek(xFilial("EE8")+EE7->EE7_PEDIDO))
   If IsIntFat()
      cMsg := STR0192+POSICIONE("SC6", 1, xFilial("SC6")+AvKey(EE7->EE7_PEDFAT,"C6_NUM"),"C6_NUM") +ENTER  //"Pedido no Faturamento: " //STR0192	"Pedido de Venda: "
      While EE8->(!EOF() .AND. EE8->EE8_FILIAL == xFilial("EE8") .And. EE8->EE8_PEDIDO == EE7->EE7_PEDIDO)
         If aScan(aItens, EE8->EE8_SEQUEN) > 0
            SC6->(dbSetOrder(1))
            nSaldoElim:= 0
            If SC6->(dbSeek(xFilial("SC6")+AvKey(EE7->EE7_PEDFAT,"C6_NUM")+AvKey(EE8->EE8_FATIT,"C6_ITEM")))
               lTemEmb := EE9->(DbSeek(xFilial("EE9")+EE8->EE8_PEDIDO+EE8->EE8_SEQUEN))
               lTemNF := !Empty(SC6->C6_NOTA) .And. (SD2->(DbSeek(xFilial("SD2")+EE7->EE7_PEDFAT+EE8->EE8_FATIT)))
               If !(lTemEmb .And. !lTemNF)
                  nSaldoElim:= SC6->C6_QTDVEN - SC6->C6_QTDENT //Saldo Faturado
                  If nSaldoElim <= EE8->EE8_SLDATU
                     If MARESDOFAT(SC6->(RecNo()), .F.,.T.)
                        
                        nSaldoElim:= IIF(EE8->EE8_SLDATU > nSaldoElim, nSaldoElim,EE8->EE8_SLDATU) 
                        EE8->(RecLock("EE8", .F.))
                        EE8->EE8_SLDATU := EE8->EE8_SLDINI - nSaldoElim
                        EE8->(MsUnlock())
                        lAlterou := .T.
                        cMsg += STR0174+Alltrim(EE8->EE8_SEQUEN)+ENTER+;                       //"Sequ�ncia do Item no Pedido de Exporta��o: "
                              STR0173+SC6->C6_ITEM+ENTER+;                                   //"Item no Pedido de Venda: "
                              STR0175+AllTrim(Transform(nSaldoElim, "999,999,999.999"+ENTER))//"Saldo Eliminado: "

                     Else
                        cMsg += (STR0193+ENTER+ENTER+; //STR0193	"O saldo n�o foi eliminado para o Item do Pedido de Venda:"
                                 STR0173+SC6->C6_ITEM+ENTER+;                                                            //"Item no Pedido de Venda: "
                                 STR0174+Alltrim(EE8->EE8_SEQUEN)+ENTER)                                                 //"Sequ�ncia do Item no Pedido de Exporta��o: "
                     Endif
                  Else
                     cMsg += (STR0251+ENTER+ENTER+; //"O saldo n�o foi eliminado, pois o saldo faturado para o pedido � menor que o saldo embarcado."
                              STR0173+SC6->C6_ITEM+ENTER+;                                                            //"Item no Pedido de Venda: "
                              STR0174+Alltrim(EE8->EE8_SEQUEN)+ENTER)  
                  EndIf
               Else
                  cMsg += (STR0252+ENTER+ENTER+; //"O saldo n�o foi eliminado, pois o pedido possui Embarque e n�o existe nenhuma nota fiscal gerada."
                              STR0173+SC6->C6_ITEM+ENTER+;                                                            //"Item no Pedido de Venda: "
                              STR0174+Alltrim(EE8->EE8_SEQUEN)+ENTER)                                                 //"Sequ�ncia do Item no Pedido de Exporta��o: "
               EndIf
            Else
               cMsg += STR0194 + AllTrim(EE8->EE8_SEQUEN) + ENTER //STR0194	"Item n�o encontrado no pedido de venda:"
            Endif
         EndIf
         EE8->(DbSkip())
      EndDo
   Else

      While EE8->(!EOF() .AND. EE8->EE8_FILIAL == xFilial("EE8") .And. EE8->EE8_PEDIDO == EE7->EE7_PEDIDO)
         If aScan(aItens, EE8->EE8_SEQUEN) > 0
            nSaldoElim:= 0
            nSaldoElim:= EE8->EE8_SLDATU
            IF nSaldoElim > 0
               EE8->(RecLock("EE8", .F.))
               EE8->EE8_SLDATU:= 0
               If EE8->(FieldPos("EE8_SLDELI") > 0)
                  EE8->EE8_SLDELI := nSaldoElim
               EndIf
               If EE8->(FieldPos("EE8_DTELIM") > 0)
                  EE8->EE8_DTELIM := dDataBase
               EndIf
               EE8->(MsUnlock())
               lAlterou := .T.
               cMsg += STR0174+Alltrim(EE8->EE8_SEQUEN)+ENTER+;                       //"Sequ�ncia do Item no Pedido de Exporta��o: "
                       STR0175+AllTrim(Transform(nSaldoElim, "999,999,999.999"+ENTER))//"Saldo Eliminado: "
               //EE7->EE7_STATUS := ST_PE
               //EE7->EE7_STTDES := Tabela("YC", EE7->EE7_STATUS)
            Else
               cMsg += (STR0206+ENTER+; //STR0193	"N�o h� saldo para ser eliminado."
                     STR0205+EE8->EE8_COD_I+ENTER+;                                                            //"Item no Pedido de Exporta��o: "
                     STR0174+Alltrim(EE8->EE8_SEQUEN)+ENTER+ENTER)                                                 //"Sequ�ncia do Item no Pedido de Exporta��o: "
            EndIf
         Else
            cMsg += (STR0204+ENTER+ENTER+; //STR0193	"O saldo n�o foi eliminado para o Item do Pedido de Exporta��o:"
                     STR0205+EE8->EE8_COD_I+ENTER+;                                                            //"Item no Pedido de Exporta��o: "
                     STR0174+Alltrim(EE8->EE8_SEQUEN)+ENTER)                                                 //"Sequ�ncia do Item no Pedido de Exporta��o: "
         EndIf
         EE8->(DbSkip())
      EndDo
   EndIf
EndIf
If lAlterou
   AE100Status(EE7->EE7_PEDIDO)
EndIf
EECView(cMsg, STR0195) //STR0195 "Resumo da opera��o:"

Return Nil

*-------------------------------------------------------------------*
* Fun��o     : AP100BLOQCPOS()                                      *
* Par�metros : Nenhum                                               *
* Retorno    : Nil                                                  *
* Objetivos  : Bloquear campos j� faturado no Pedido de Exporta��o  *
* Autor      : Diogo Felipe dos Santos                              *
* Data/Hora  : 05/11/10 - 10:10                                     *
*-------------------------------------------------------------------*

*--------------------------------*
 Static Function AP100BLOQCPOS()
*--------------------------------*
Local nI := 1
Private aBloqIt := {"EE8_COD_I", "EE8_UNIDAD", "EE8_SLDINI", "EE8_PRECO", "EE8_TES", "EE8_CF", "EE8_FORN", "EE8_FOLOJA", "EE8_UNPRC"}

If EasyGParam("MV_AVG0119",,.F.)
   AAdd(aBloqIt,"EE8_DESCONT")
EndIf

IF EasyEntryPoint("EECAP100")
   ExecBlock("EECAP100",.F.,.F.,{"AP100BLOQCPOS_ADDCPOS"})
EndIf

For nI := 1 to Len(aBloqIt)
   nPos := aScan(aEE8CamposEditaveis, aBloqIt[nI])
   If nPos > 0
      aDel(aEE8CamposEditaveis, nPos)
      ASize(aEE8CamposEditaveis,Len(aEE8CamposEditaveis)-1)
   EndIf
Next

Return Nil


/*----------------------------------------------------------------------------*/
/* Fun��o     : VldOpeAP100                                                   */
/* Objetivos  : Executar a��o da Opera��o Especial                            */
/* Parametros : cParam := Indica em qual percurso do pedido ser� executada    */
/*                          a Opera��o Especial                               */
/*              nTipo := Inclus�o,Altera��o ou Exclus�o                       */
/* Autor      : Allan Oliveira Monteiro                                       */
/* Data/Hora  : 27/04/11                                                      */
/*----------------------------------------------------------------------------*/
*---------------------------------*
Function VldOpeAP100(cParam,nTipo)
*---------------------------------*
Local lRet := .T.
Local lSeek:= .F.

Default nTipo := 3


Begin Sequence

   If !lOperacaoEsp
      Break
   EndIf

   DO CASE

      CASE cParam == "BTN_IT_EE8"

         If nTipo == ALT_DET .Or. nTipo == EXC_DET//Altera��o ou Exclus�o


            If !Empty(WorkIt->EE8_CODOPE)
               If !oOperacao:InitOperacao(WorkIt->EE8_CODOPE, "EE8", {{"EE8","WorkIt"},{"EE7","EE7"}},.F.,.T.,cParam)//Estorno
                  lRet:= .F.
                  Break
               EndIf
            EndIf

          EndIf


         If ( nTipo == INC_DET .Or. nTipo == ALT_DET ).And. !Empty(M->EE8_CODOPE)//Inclus�o
            If !oOperacao:InitOperacao(M->EE8_CODOPE, "EE8", {{"EE8","M"},{"EE7","M"}}, .T.,.T.,cParam)//Inclusao
               lRet:= .F.
               Break
            EndIf

         EndIf


      CASE cParam == "BTN_EXC_PED"

         EE8->(DbSetOrder(1))//EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN + EE8_COD_I
         WorkIt->(DbGoTop())

         While WorkIt->(!EOF())

            lSeek := EE8->(DbSeek(xFilial("EE8") + WorkIt->EE8_PEDIDO + WorkIt->EE8_SEQUEN + WorkIt->EE8_COD_I))
            If lSeek .And. !Empty(EE8->EE8_CODOPE)
               If !oOperacao:InitOperacao(EE8->EE8_CODOPE, "EE8", {{"EE8","EE8"},{"EE7","EE7"}},.F.,.T.,cParam)//Estorno
                  lRet:= .F.
                  Break
               EndIf
            EndIf

         WorkIt->(DbSkip())
         EndDo


   ENDCASE


End Sequence

Return lRet


/* ====================================================*
* Fun��o: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integra��o com Logix
* Obs:
* Autor: Felipe Sales Martinez - FSM
* Data: 13/12/2011
* Revis�o: WFS jul/2015
           Adequa��o para recebimento do processo de venda de servi�o;
           Altera��o do adapter para pr�-adapter (SORDPREREC), que realizar�
           a chamada da execu��o do adapter do pedido de exporta��o (AP100ARECB),
           bem como a chamada do adapter do processo de venda de servi�os (PV410RECEB).
           Altera��o da chamada da rotina autom�tica para uma pr�-execauto,
           possibilitando a execu��o de apenas uma das integra��es ou de ambas,
           decorrente da configura��o do ambiente. A defini��o do SetBFunction passa
           a ser realizada de dentro do adapter.
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EE7")
	oEasyIntEAI:SetModule("EEC",29)

	// *** Recebimento
	oEasyIntEAI:SetAdapter("RECEIVE", "MESSAGE",  "SORDPREREC") //PRE-ADAPTER PARA RECEBIMENTO DE BUSINESS - PEDIDO DE EXPORTA��O E PROCESSO DE AQUISI��O
	oEasyIntEAI:SetAdapter("RESPOND", "MESSAGE",  "AP100ARESB") //RESPOSTA SOBRE O RECEBIMENTO  (<-Response)

    //*** ENVIO
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AP100SENB") //ENVIO DO PEDIDO
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AP100ARESR")	//Rebimento de retorno da

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()

/* ====================================================*
* Fun��o:     AP100SENB
* Parametros: (Nenhum)
* Objetivo:   Efetua o Envio da BusinessMessage de Pedido
*             de Exportaacao via EAI para outro ERP
* Obs:        Adapter para envio ao ERP LOGIX
* Autor:      Nilson Cesar C Filho
* Data:       26/08/2013
//* =====================================================*/
   Function AP100SENB()
//* =====================================================*
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oEvent    := ENode():New()
Local oIdent    := ENode():New()
Local oRec      := ENode():New()
Local oItem     := ENode():New()
Local oItensPed := ENode():New()
Local aOrd := SaveOrd({"EE7","EE8","SY5","SB1","SA1","SY6"})
Local lCpoDscItR := .F.
Local lFrtInform := .F.
Local lTemFRete  := .F.
Local cTypeCalcFre
Local cDescItem:= ""
Local nSldEli:= 0

   SX3->(DbSetOrder(2))
   If SX3->(DbSeek("EE8_VM_DES"))
      lCpoDscItR := ( Empty(SX3->X3_CONTEXT) .Or. SX3->X3_CONTEXT == 'R' )
   EndIf

   EE8->(DbSetOrder(1))
   EEB->(DbSetOrder(1))
   SY5->(DbSetOrder(1))
   SB1->(DbSetOrder(1))
   SA1->(dbSetOrder(1))
   SY6->(dbSetOrder(1))
   SYF->(dbSetOrder(1))

   oEvent:SetField("Entity", "EECAP100")

   If Type("nEAIEvent") <> "U"
      /* wfs - tanto a a��o de inclus�o/ altera��o quando cancelamento
         executar� o evento upsert; n�o haver� exclus�o.*/
      //If nEAIEvent == 3
         oEvent:SetField("Event" ,"upsert" )
      //ElseIf nEAIEvent == 5
         //oEvent:SetField("Event" ,"delete" )
      //EndIf
   Else
      oEvent:SetField("Event" , "error")
   EndIf

   //Campos Chave para a Mensagem
   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","BranchId"))
   oKeyNode:SetField(ETag():New("" ,AvGetM0Fil()))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","CustomerOrderId"))
   oKeyNode:SetField(ETag():New("" ,EE7->EE7_PEDIDO))
   oIdent:SetField(ETag():New("key",oKeyNode))

   IF !Empty(EE7->EE7_PEDERP)
      oKeyNode   := ENode():New()
      oKeyNode:SetField(EAtt():New("name","OrderId"))
      oKeyNode:SetField(ETag():New("" ,EE7->EE7_PEDERP))
      oIdent:SetField(ETag():New("key",oKeyNode))
   ENDIF

   oEvent:SetField("Identification",oIdent)

   oBusiness:SetField("CompanyId"            , SM0->M0_CODIGO )
   oBusiness:SetField("BranchId"             , AvGetM0Fil() )

   If Empty(EE7->EE7_PEDERP)
      oBusiness:SetField("OrderId" , "0")                       //INCLUSAO
   Else
      oBusiness:SetField("OrderId" , EE7->EE7_PEDERP)           //ALTERACAO
   EndIf

   oBusiness:SetField("CustomerCode"         , EE7->EE7_IMPORT)
   oBusiness:SetField("DeliveryCustomerCode" , EE7->EE7_IMPORT)
   /* //NCF - 12/12/2013 - N�o enviar dados de Endere�o de Entrega para que no Faturamento Logix o usu�rio possa
      //                   informar os dados de endere�o manualmente.
   //TRatamentos de Dados do Importador
   SA1->(dbSeek(xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA))
   oEnd:= ENode():New()
   oEnd:SetField("Address"    ,Alltrim(EE7->EE7_ENDIMP))
   oEnd:SetField("Number"     ,"")
   oEnd:SetField("Complement" ,Alltrim(EE7->EE7_END2IM)+" - "+Alltrim(SA1->A1_BAIRRO)+" - "+Alltrim(SA1->A1_MUN)+" - "+;
                               Alltrim(SA1->A1_ESTADO) +" - "+Alltrim(E_Field("A1_PAIS","YA_DESCR")))

      oCity:= ENode():New()
      oCity:SetField("Code",SA1->A1_COD_MUN)
      oCity:SetField("Description",Alltrim(SA1->A1_MUN))
   oEnd:SetField("City",oCity)

   oEnd:SetField("District",Alltrim(SA1->A1_BAIRRO))

      oState:= ENode():New()
      oState:SetField("Code",SA1->A1_EST)
      oState:SetField("Description",Alltrim(SA1->A1_ESTADO))
   oEnd:SetField("State",oState)

      oCountry:= ENode():New()
      oCountry:SetField("Code",SA1->A1_PAIS)
      oCountry:SetField("Description",E_Field("A1_PAIS","YA_DESCR"))
   oEnd:SetField("Country",oCountry)

   oEnd:SetField("ZIPCode",SA1->A1_CEP)

   oBusiness:SetField("DeliveryAddress"      , oEnd)
   */
   oBusiness:SetField("CustomerOrderId"      , EE7->EE7_PEDIDO) //A Tag "OrderId" ser� tratado no retorno considerando o n�mero do Pedido gerado no ERP LOGIX

   /* Tratamento para Transportadora : */
   cCodTransp := ""
   EEB->(DbSeek(xFilial("EEB")+EE7->EE7_PEDIDO+"P"))
   While EEB->(EEB->(!EOF()) .and. EEB->(EEB_FILIAL+EEB_PEDIDO+EEB_OCORRE)== xFilial("EEB")+EE7->EE7_PEDIDO+"P")
      If Left(EEB->EEB_TIPOAG,1)=='B'
         SY5->(DbSeek(xFilial("SY5")+EEB->EEB_CODAGE))
         cCodTransp := AllTrim(SY5->Y5_FORNECE)
         Exit
      EndIf
      EEB->(DbSkip())
   EndDo
   If !Empty(cCodTransp)
      oBusiness:SetField("CarrierCode"    , cCodTransp)
   EndIf

   SY6->(DbSeek(xFilial("SY6")+AvKey(EE7->EE7_CONDPA,"Y6_COD")+STR(EE7->EE7_DIASPA,3,0)))
   oBusiness:SetField("PaymentTermCode", SY6->Y6_CODERP)

   /* Tratamento para Desconto Percentual do Pedido : */
   If EasyGParam("MV_EEC0026",,.T.) //Determina se envia o desconto do Processo
      If EasyGParam("MV_EEC0015",,.F.) //Determina se envia o desconto do Pedido da Capa
         oDiscount:= ENode():New()
         oDiscount:SetField("Discount"         , EE7->EE7_DESCON)
         oBusiness:SetField("Discounts"        , oDiscount  )
         //oBusiness:SetField("TotalDiscount"    , /*EE7->EE7_DESCON*/ 0  )
      Else
         oDiscount:= ENode():New()
         oDiscount:SetField("Discount"         , 0)
         oBusiness:SetField("Discounts"        , oDiscount  )
         //oBusiness:SetField("FinancialDiscount", Round( 100 * Round( 1-((EE7->EE7_TOTPED-EE7->EE7_DESCON)/EE7->EE7_TOTPED), 6 ) , 2)     )
         //oBusiness:SetField("TotalDiscount"    , 0)
      EndIf
   Else
      oDiscount:= ENode():New()
      oDiscount:SetField("Discount"         , 0)
      oBusiness:SetField("Discounts"        , oDiscount  )
   EndIf

   oBusiness:SetField("RegisterDate", EasyTimeStamp(EE7->EE7_DTPEDI,.T.,.T.) )

   dDtRequest := AP100MinDt()

   oBusiness:SetField("RequestDate", EasyTimeStamp(dDtRequest,.T.,.T.))

   cTypeCalcFre := Alltrim(EasyGParam("MV_EEC0016",,'1'))

   If cTypeCalcFre == '1'
      lFrtInform := EE7->EE7_FRPREV > 0 .Or. EE7->EE7_FRPCOM > 0
   ElseIf cTypeCalcFre == '2'
      lFrtInform := EE7->EE7_FRPREV > 0
   ElseIf cTypeCalcFre == '3'
      lFrtInform := EE7->EE7_FRPCOM > 0
   EndIf

   //CIF-> Deve estar destacado na Capa ou nos Itens e informado o valor de Frete a ser enviado
   //FOB-> Quando negada uma das suposicoes acima.
   //lTemFRete   := (EasyGParam("MV_EEC0013",,.F.) .Or. !EasyGParam("MV_EEC0017",,.F.)) .And. lFrtInform - Nopado

   lTemFRete   := If ( cTypeCalcFre == '3', AvRetInco(EE7->EE7_INCOTE,"CONTEM_FRETEN"), AvRetInco(EE7->EE7_INCOTE,"CONTEM_FRETE")  )

   /* Tratamento para Frete : */
   If lTemFrete
      oBusiness:SetField("FreightType", '1')
   Else
      oBusiness:SetField("FreightType", '2')
   EndIf

   If lTemFrete
      Do Case
         Case cTypeCalcFre == '1'
            oBusiness:SetField("FreightValue", EE7->EE7_FRPREV + EE7->EE7_FRPCOM)
         Case cTypeCalcFre == '2'
            oBusiness:SetField("FreightValue", EE7->EE7_FRPREV)
         Case cTypeCalcFre == '3'
            oBusiness:SetField("FreightValue", EE7->EE7_FRPCOM)
         Case cTypeCalcFre == '4'
            oBusiness:SetField("FreightValue", 0 )
      EndCase
   Else
      oBusiness:SetField("FreightValue", 0 )
   EndIf

   //Tratamento para Mensagem de Nota Fiscal para o Pedido
   cCpoGetMsg:= Alltrim(EasyGParam("MV_EEC0021",,""))
   cMsgNFPed := ""
   If !Empty(cCpoGetMsg)
      SX3->(DbSetOrder(2))
      If SX3->(DbSeek(cCpoGetMsg))
         If SX3->X3_TIPO == 'C'
            cMsgNFPed := &(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO)
         ElseIf SX3->X3_TIPO == 'M'
            If Empty(SX3->X3_CONTEXT) .Or. SX3->X3_CONTEXT == 'R'
               cMsgNFPed := &(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO)
            Else
               cRelacao := Alltrim(SX3->X3_RELACAO)    //Oobter o codigo do Memo se for virtual
               cCpoCodMem := SUBSTR(  cRelacao   , AT(">" , cRelacao)+1  , 10  )
               If SX3->(DbSeek(cCpoCodMem))
                  cMsgNFPed := E_MSMM( &(SX3->X3_ARQUIVO+"->"+cCpoCodMem) , AvSx3(cCpoGetMsg,3) )
               Else
                  cMsgNFPed := ""
               EndIf
            EndIf
         ElseIf SX3->X3_TIPO == 'D'
            cMsgNFPed := EasyTimeStamp(&(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO),.T.,.T.)
         ElseIf SX3->X3_TIPO == 'N'
            cMsgNFPed := Alltrim(STR(&(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO),SX3->X3_TAMANHO,SX3->X3_DECIMAL))
         Else
            cMsgNFPed := ""
         EndIf
         If Valtype(cMsgNFPed) <> NIL .And. !Empty(cMsgNFPed)
            oMsgNFPed := ENode():New()
            oMsgNFPed:SetField("InvoiceMessage" , cMsgNFPed )
            oBusiness:SetField("InvoiceMessages", oMsgNFPed)
         EndIf
      EndIf
   EndIf

   oBusiness:SetField("Finality", '2')

   If EasyGParam("MV_EEC0014",,.F.)
      oBusiness:SetField("InsuranceValue", EE7->EE7_SEGPRE )
   Else
      oBusiness:SetField("InsuranceValue", 0 )
   EndIf

   SYF->(DbSeek(xFilial("SYF")+AvKey(EE7->EE7_MOEDA,"YF_COD")))
   oBusiness:SetField("CurrencyCode",/*SYF->YF_CODVERP*/SYF->YF_CODCERP) //NCF - 28/10/2013 - Enviar a Taxa de Compra

   oBusiness:SetField("Status"  , IF( Type("nEAIEvent") <> "U" .And. nEAIEvent == 5 ,'7','1' )     )

   oItensPed:lUniqueField := .F.
   EE8->(DbSeek(xFilial('EE8')+EE7->EE7_PEDIDO))
   Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == EE7->(xFilial("EE7")) .And. ;
                                EE8->EE8_PEDIDO == EE7->EE7_PEDIDO
      oItem := ENode():New()
      oItem:SetField("CompanyId"                   , SM0->M0_CODIGO )
      oItem:SetField("BranchId"                    , EE8->EE8_FILIAL )

      oItem:SetField("OrderItem"                   , EE8->EE8_SEQUEN/*'0'*/ )
      oItem:SetField("ItemCode"                    , EE8->EE8_COD_I)

      //oItem:SetField("ItemDescription"             , If(lCpoDscItR,EE8->EE8_VM_DES,MSMM(EE8->EE8_DESC,AvSX3("EE8_VM_DES",AV_TAMANHO),,,LERMEMO)))//Ganho de Performance se o campo for Memo Real para pedidos com muitos itens
      cDescItem:= If(lCpoDscItR,EE8->EE8_VM_DES,MSMM(EE8->EE8_DESC,AvSX3("EE8_VM_DES",AV_TAMANHO),,,LERMEMO))
      oItem:SetField("ItemDescription"             ,StrTran(cDescItem, ENTER, " "))//Ganho de Performance se o campo for Memo Real para pedidos com muitos itens

      //Tratamento de convers�o de unidade
      SB1->(DbSeek(xFilial('SB1')+EE8->EE8_COD_I))
      If SB1->B1_UM <> EE8->EE8_UNIDAD
         nQtdeIt := AVTransUnid(EE8->EE8_UNIDAD,SB1->B1_UM,EE8->EE8_COD_I,EE8->EE8_SLDINI,.F.,.F.,)
      Else
         nQtdeIt := EE8->EE8_SLDINI
      EndIf
      oItem:SetField("Quantity"                    , nQtdeIt)

      //Tratamentos de pre�o unit�rio
      nPrecoItem := EE8->EE8_PRECOI
      nPrecoTot  := EE8->EE8_PRECOI*EE8->EE8_SLDINI

      //Tratamento de Despesas Internas
      If EasyGParam("MV_EEC0020",,.F.)                                //Embutir valor das despesas proporcional do item ao seu valor unitario
         nPrecoItem += Round(EE8->EE8_VLOUTR/EE8->EE8_SLDINI,6)
         nPrecoTot  += EE8->EE8_VLOUTR
      EndIf

      //Tratamentos de Frete
      nVlUnFreIte := Round(EE8->EE8_VLFRET/EE8->EE8_SLDINI,6)
      nVlTtFreIte := EE8->EE8_VLFRET

      If EasyGParam("MV_EEC0017",,.F.)                                //Embutir Valor do Frete proporcional do item ao seu valor unitario
         nPrecoItem  += nVlUnFreIte
         nPrecoTot   += nVlTtFreIte
         nVlTtFreIte := 0
      EndIf

      //Tratamentos de Seguro
      nVlUnSegIte := Round(EE8->EE8_VLSEGU/EE8->EE8_SLDINI,6)
      nVlTtSegIte := EE8->EE8_VLSEGU
      If EasyGParam("MV_EEC0018",,.F.)                               //Embutir Valor do Seguro proporcional do item ao seu valor unitario
         nPrecoItem  += nVlUnSegIte
         nPrecoTot   += nVlTtSegIte
         nVlTtSegIte := 0
      EndIf

      //Tratamentos de desconto
      nDescVlIte := 0
      nDescPcIte := 0
      If EasyGParam("MV_EEC0026",,.T.)
         If EasyGParam("MV_EEC0019",,.F.)                                   //Define se sera enviado o valor do desconto por valor no preco ou percentual destacado
            If EasyGParam("MV_AVG0119",,.F.)                                //Ativa rotina de Descontos por itens (Se .T. aplica o desconto [EE8_DESCON] diretamente no valor do item. Se .F. o desconto da capa � rateado entre os itens [EE8_PRECOI] - como as demais despesas)
               nDescVlIte := EE8->EE8_DESCON //Round( EE7->EE7_DESCON , 6 )
               nPrecoItem -= Round(EE8->EE8_DESCON/EE8->EE8_SLDINI,6)  //Para envio ao ERP Externo o desconto sera considerando como Abatimento no preco do item
               nPrecoTot  -= nDescVlIte
               nDescVlIte := 0
            Else
               nDescVlIte := EE8->EE8_VLDESC //Round( EE7->EE7_DESCON * ((EE8->EE8_PRECOI * EE8->EE8_SLDINI) / EE7->EE7_VLFOB )             , 6 )
               nPrecoItem -= Round(nDescVlIte/EE8->EE8_SLDINI,6)       // Para envio ao ERP Externo o desconto sera considerando como Abatimento no preco do item
               nPrecoTot  -= nDescVlIte
               nDescVlIte := 0  //Round( EE7->EE7_DESCON , 6 )
            EndIf
         Else
            If EasyGParam("MV_AVG0119",,.F.)
               nDescVlIte := EE8->EE8_DESCON //Round( EE8->EE8_DESCON , 6 )

               If !EasyGParam("MV_EEC0020",,.F.)
                  nDescPcIte := Round( 100 * Round( 1-(((EE8->EE8_PRECOI * EE8->EE8_SLDINI)-nDescVlIte)/(EE8->EE8_PRECOI * EE8->EE8_SLDINI)), 6 ) , 2)
               Else
                  nDescPcIte := Round( 100 * Round( 1-(((nPrecoItem * EE8->EE8_SLDINI)-nDescVlIte)/(nPrecoItem*EE8->EE8_SLDINI)), 6 ) , 2)
               EndIf
            Else
               nDescVlIte := EE8->EE8_VLDESC //Round( EE7->EE7_DESCON * ((EE8->EE8_PRECOI * EE8->EE8_SLDINI) / EE7->EE7_VLFOB )             , 6 )
               If !EasyGParam("MV_EEC0020",,.F.)
                  nDescPcIte := Round( 100 * Round( 1-(((EE8->EE8_PRECOI * EE8->EE8_SLDINI)-nDescVlIte)/(EE8->EE8_PRECOI * EE8->EE8_SLDINI)), 6 ) , 2)
               Else
                  nDescPcIte := Round( 100 * Round( 1-(((nPrecoItem * EE8->EE8_SLDINI)-nDescVlIte)/(nPrecoItem * EE8->EE8_SLDINI)), 6 ) , 2)
               EndIf
            EndIf
         EndIf
      EndIf

      oItem:SetField("UnityPrice"                  , Round(nPrecoTot/EE8->EE8_SLDINI,6) /* nPrecoItem */)
      oItem:SetField("TotalPrice"                  , nPrecoTot )
      oItem:SetField("CustomerOrderNumber"         , EE8->EE8_PEDIDO)
      //oItem:SetField("DiscountPercentage"          , nDescPcIte )
      oItDiscount:= ENode():New()
      oItDiscount:SetField("ItemDiscount"          , nDescVlIte)
      oItem:SetField("ItemDiscounts"               , oItDiscount )
      oItem:SetField("FreightValue"                , nVlTtFreIte)
      oItem:SetField("InsuranceValue"              , nVlTtSegIte)

      oItem:SetField("UnitWeight"                  , EE8->EE8_PSLQUN)

      //Tratamento para Mensagem de Nota Fiscal para o Item do Pedido
      cCpoGetMsg:= EasyGParam("MV_EEC0022",,"")
      cMsgNFIte := ""
      If !Empty(cCpoGetMsg)
         SX3->(DbSetOrder(2))
         If SX3->(DbSeek(cCpoGetMsg))
            If SX3->X3_TIPO == 'C'
               cMsgNFIte := &(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO)
            ElseIf SX3->X3_TIPO == 'M'
               If Empty(SX3->X3_CONTEXT) .Or. SX3->X3_CONTEXT == 'R'
                  cMsgNFIte := &(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO)
               Else
                  cRelacao := Alltrim(SX3->X3_RELACAO)    //Oobter o codigo do Memo se for virtual
                  cCpoCodMem := SUBSTR(  cRelacao   , AT(">" , cRelacao)+1  , 10  )
                  If SX3->(DbSeek(cCpoCodMem))
                     cMsgNFIte := E_MSMM( &(SX3->X3_ARQUIVO+"->"+cCpoCodMem) , AvSx3(cCpoGetMsg,3) )
                  Else
                     cMsgNFIte := ""
                  EndIf
               EndIf
            ElseIf SX3->X3_TIPO == 'D'
               cMsgNFIte := EasyTimeStamp(&(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO),.T.,.T.)
            ElseIf SX3->X3_TIPO == 'N'
               cMsgNFIte := Alltrim(STR(&(SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO),SX3->X3_TAMANHO,SX3->X3_DECIMAL))
            Else
               cMsgNFIte := ""
            EndIf

            If ValType(cMsgNFIte) <> NIL .And. !Empty(cMsgNFIte)
               oMsgNFIte := ENode():New()
               oMsgNFIte:SetField("ItemMessage" , cMsgNFIte )
               oItem:SetField("ItemMessages", oMsgNFIte)
            EndIf

         EndIf
      EndIf
      //oItem:SetField("ItemMessages"                ,  )
      //oItem:SetField("ListOfReturnedInputDocuments", '' )

      oItensPed:SetField("Item", oItem)

      EE8->(DbSkip())
   EndDo

   oBusiness:SetField("SalesOrderItens"  , oItensPed)
   oRec:SetField("BusinessEvent"  ,oEvent)
   oRec:SetField("BusinessContent",oBusiness)
   oXml:AddRec(oRec)

RestOrd(aOrd,.t.)

Return oXml

   /*Pre-Defini��es: A Transportadora � uma empresa associada ao Pedido que possui um c�digo de fornecedor.
                     Este fornecedor da empresa ser� enviado ao LOGIX uma vez que os cadastro de fornecedores � integrado.
                     ou
                     O Campo referente a transportadora dever� ser informado na capa do Pedido com origem [F3] no Cadastro de Fornecedores do Protheus
                     que � populado via integra��o com o LOGIX.

   /*Contexto: Criar campo EE7_TRANSP na capa do pedido;

               Posicionar na tabela de Empresas Associadas ao Pedido (EEB);
               com o c�digo da empresa (EEB_CODAGE) posicionar na tabela SY5 e obter o c�digo do fornecedor no campo Y5_FORNECE

     Pre-Definicoes: A quantidade no ERP LOGIX � somente na unidade de medida estabelecida no pedido Logix. A unidade de medida no entanto nao possui
                     tag definida para ser enviada por mensagem �nica. Com isto a quantidade da mercadoria dever� ser enviada na unidade de medida do
                     cadastro de produtos que por sua vez � integrado do LOGIX para o SIGAEEC onde a unidade de medida � informada.
     Contexto: Posicionar no cadastro de produtos (SB1);
               com o c�digo do produto, chamar a fun��o

   */

/*
Funcao Adapter: SORDPREREC
Parametros    : "oMessage" - Objeto XML com conte�do da tag "BusinessContent" recebida
Retorno       : oBatch - objeto com os aExecAuto's que ser�o executados
Objetivos     : Sales Order pr�-adapter de recebimento
                Definir a execu��o dos programas respons�veis pela montagem dos arrays usados na
                rotina autom�tica para a gera��o do pedido de exporta��o e do processo de venda.
                Na mensagem SalesOrder ser�o enviados itens que correspondem �s mercadorias, para a
                gera��o do pedido de venda, e itens que correspondem � servi�os, para gera��o do processo
                de venda de servi�os.
                A diferencia��o ser� realizada pela tag TypeOperation, que identificar� o item.
                Quando houver ambos os tipos, devem ser disparadas as duas integra��es, sendo priorizada
                a execu��o da cria��o do pedido de venda.
Autor         : WFS
Data/Hora     : Jul/2015
Revisao       :
Obs.          :
*/
Function SORDPREREC(oMessage)
Local oBusinessCont:= oMessage:GetMsgContent()
Local oBatch       := EBatch():New()
Local oExecAuto    := EExecAuto():New()
Local oXMLErro     := EXml():New()
Local oNode        := ENode():New()
Local oParams      := ERec():New()
Local lMerc        := .F.
Local lServ        := .F.
Local lTemPedido   := .F.
Local lNoIntEEC    := .F.
Local lNoIntESS    := .F.
Local cMsg         := ""

Private lExcluiProc:= .F.

Begin Sequence //Pedido de Exporta��o

   /* Na mensagem SalesOrder ser�o enviados itens de mercadoria e servi�o.
      a fun��o SetInteg() ir� setar as vari�veis lMerc e lServ, indicando se existem itens
      com tais caracter�sticas sendo integradas na mensagem. */
   SetInteg(oBusinessCont, @lMerc, @lServ)

   /* Se a intega��o n�o estiver habilitada, n�o inicia o processamento. */
   If !AvFlags("EEC_LOGIX")
      /* A mensagem ser� exibida quando estiver desabilitada a integra��o do ESS com Logix e n�o houver itens de servi�o, ou seja, s� houver mercadoria.
         Neste caso, entende-se que o cliente quer integrar com o pedido de exporta��o mas n�o habilitou a integra��o com o EEC. */
      If !AvFlags("ESS_EAI") .And. lMerc
         cMsg += "A integra��o do Easy Export Control via EAI n�o est� habilitada. Verifique o par�metro MV_EECI010."
      EndIf
      Break
   EndIf

   //NCF - 09/06/2016 - Montar o c�digo do Pedido antes de seekar pois pode estar com o par�metro MV_EEC0009 alterado
   If !(  !EasyGParam("MV_EEC0009",.T.) .Or. AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) == "#EE7_PEDIDO#" .Or. Empty(EasyGParam("MV_EEC0009",,""))  )
      cPedChk := AvKey( StrTran(AllTrim(Upper(StrTran(AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) ,"#EE7_PEDIDO#",AllTrim(EasyGetXMLinfo(, oBusinessCont, "_OrderId"))))) ,"#EE7_FORN#"  ,AllTrim(EasyGetXMLinfo("EE7_FORN", oBusinessCont, "_CompanyId"))) , "EE7_PEDIDO")
   Else
      cPedChk := AvKey(EasyGetXMLinfo(, oBusinessCont, "_OrderId"),"EE7_PEDIDO")
   EndIf

   EE7->(DBSetOrder(1)) //EE7_FILIAL+EE7_PEDIDO
   lTemPedido:= EE7->(DbSeek(xfilial("EE7")+ cPedChk )) /*EE7->(DBSeek(xFilial() + EasyGetXMLinfo("EE7_PEDIDO",oBusinessCont, "_OrderId")))*/ //flag que indica a exist�ncia do pedido de exporta��o

   /* Quando n�o houver itens de produto (mercadoria) e n�o houver pedido
	  inclu�do anteriormente, o processamento do pedido de venda ser� interrompido. */
   If !lMerc .And. !lTemPedido
      Break
   EndIf

   /* Quando n�o houver itens de produto (mercadoria) na mensagem e o pedido de exporta��o
      existir, mesmo sendo uma mensagem com evento Upsert o pedido de exporta��o dever�
      ser eliminado. A flag lExcluiProc ser� usada para for�ar a execu��o da exclus�o do pedido. */
   If !lMerc .And. lTemPedido
      lExcluiProc:= .T.
   EndIf

   /* Montagem dos dados para a gera��o do pedido de exporta��o com base no XML SALESORDER recebido. */
   oExecAuto:= AP100ARECB(@oMessage)
   oBatch:AddRec(oExecAuto)

End Sequence

Begin Sequence //Processo de Venda

   lExcluiProc:= .F.

   /* Se a intega��o n�o estiver habilitada, n�o inicia o processamento */
   If !AvFlags("ESS_EAI")
      /* A mensagem ser� exibida quando estiver desabilitada a integra��o do EEC com Logix e n�o houver item de mercadoria na mensagem, ou seja apenas servi�os.
         Neste caso, entende-se que o cliente quer integrar com o processo de venda mas n�o habilitou a integra��o com o ESS. */
      If !AvFlags("EEC_LOGIX") .And. lServ
         cMsg += "A integra��o do Easy Siscoserv via EAI n�o est� habilitada. Verifique o par�metro MV_ESS_EAI."
      EndIf
      Break
   EndIf

   EJW->(DBSetOrder(1)) //EJW_FILIAL+EJW_TPPROC+EJW_PROCES
   lTemPedido:= EJW->(DBSeek(xFilial() + AvKey("V", "EJW_TPPROC") + EasyGetXMLinfo("EJW_PROCES", oBusinessCont, "_OrderId"))) .And.;
                Upper(AllTrim(EJW->EJW_ORIGEM)) == "LOGIX" //flag que indica a exist�ncia do processo de venda

   	/* Quando n�o houver itens de servi�o e n�o houver processo inclu�do anteriormente,
	   o processamento do pedido de venda de servi�o ser� interrompido. */
   If !lServ .And. !lTemPedido
      Break
   EndIf

   /* Quando n�o houver itens de servi�o na mensagem e o processo de venda de servi�o
      existir, mesmo sendo uma mensagem com evento Upsert o processo de venda dever�
      ser eliminado. A flag lExcluiProc ser� usada para for�ar a execu��o da exclus�o do processo. */
   If !lServ .And. lTemPedido
      lExcluiProc:= .T.
   EndIf

   /* Montagem dos dados para a gera��o do processo de venda de servi�o, com base no XML SALESORDER recebido. */
   oExecAuto:= PV410RECEB(@oMessage)
   oBatch:AddRec(oExecAuto)

End Sequence

If !Empty(cMsg)
   cMsg:= AvgXMLEncoding(cMsg)
   oNode:SetField("", cMsg)
   oXMLErro:AddRec(oNode)
   oMessage:lError:= .T.
   oMessage:AddInList("RESPONSE", oXMLErro)
Else
   If Empty(oBatch:aRec)
      oParams:SetField("bFunction" , {|| AllwaysTrue()})
      oExecAuto:SetField("PARAMS", oParams)
      oBatch:AddRec(oExecAuto)
   EndIf
EndIf

Return oBatch

/*========================================================================================
Funcao Adapter: AP100ARECB
Parametros    : "oMessage" - Objeto XML com conte�do da tag "BusinessContent" recebida
Retorno       : aExecAuto onde:
                aExecAuto[1] = Array com os dados de capa para ExecAuto
                         [1][1] = Identificador de capa ("CAB")
                         [1][2] = Id do Formulario de Capa
                         [1][3] = Array com os registros para ExecAuto
                aExecAuto[2] = Array com os dados de detalhe para ExecAuto
                         [2][1] = Identificador de detalhe ("DET")
                         [2][2] = Id do Formulario de Detalhe
                         [2][3] = Array com os registros para ExecAuto
Objetivos     : Montar o Array de dados da Mensagem �nica para inser��o via ExecAuto
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 30/11/2011 - 10:00 hs
Revisao       : WFS Jul/2015
                Na mensagem SalesOrder ser�o enviados itens que correspondem �s mercadorias, para a
                gera��o do pedido de venda, e itens que correspondem � servi�os, para gera��o do processo
                de venda de servi�os.
                A diferencia��o ser� realizada pela tag TypeOperation, que identificar� o item.
                Quando houver ambos os tipos, devem ser disparadas as duas integra��es, sendo priorizada
                a execu��o da cria��o do pedido de venda.
Obs.          :
==========================================================================================*/
*------------------------------------------------*
Function AP100ARECB(oMessage)
*------------------------------------------------*
Local oBusinessCont := oMessage:GetMsgContent()
Local oExecAuto := EExecAuto():New()
Local oRec      := ERec():New()
Local oItens    := ETab():New()
Local oParams   := ERec():New()
Local lObrigat  := .T.
Local nQtdEmb := 0, nCont   := 0
Local cIdioma := "", cPais := "", cProdCod := "", cEmb := "", cCliCod := "", cCondPgt := "", cMoeda := "", cMoeERP := "", cPgtERP := "", cIncoterm := "", cVia := ""
Local aArrayItens
Local nTotDescont := 0
Local nFator := 0
Local nDesconto := 0
Local nTotPed := 0
Local cExpCod := ""
Local nOpc := 0
Local nOpcItem := 0
Local aDados := {}
Local cCod := "", cPeso := ""
Local lCondic := .F.
Local cCliente := ""
Local cPedido := ""
Local cParametro := ""
Local lPrecoAb := CriaVar("EE7_PRECOA", .T., , .F.) == "1"
Local nTotDscPrcIt := 0                                                                    //NCF-04/08/2014

Begin Sequence

    oParams:SetField("bFunction" , {|oEasyMessage| EECAP100(oEasyMessage:GetEAutoArray("EE7"),;
                                                            EasyEAutItens("EE7", "EE8", oEasyMessage:GetEAutoArray("EE7"), oEasyMessage:GetEAutoArray("EE8")),;
                                                            oEasyMessage:GetOperation())})

	aDados := EasyGetOpc("EE7","EE8",EasyGetXMLinfo("EE7_PEDIDO",oBusinessCont, "_OrderId"))
	If Empty(aDados)
	   nOpc := 3
	EndIF

    /* Tratamento para Importador*/
    cCliCod  := EasyGetXMLinfo("EE7_IMPORT", oBusinessCont, "_CustomerCode")   //Cod. Importado
    cPais   := Posicione("SA1", 1, xFilial("SA1")+AvKey(cCliCod,"A1_COD")+AvKey(".","A1_LOJA"), "A1_PAIS")  //Pais do Cliente
    cExpCod  := EasyGetXMLinfo("EE7_FORN", oBusinessCont, "_CompanyId")   //Cod. Exportador
    cExpPais := Posicione("SA2", 1, xFilial("SA2")+AvKey(cExpCod,"A2_COD")+AvKey(".","A2_LOJA"), "A2_PAIS")  //Pais do Exportador

    cPedido := EasyGetXMLinfo(, oBusinessCont, "_OrderId")
    If !Empty(cPais) .And. !Empty(cExpPais) .And. AllTrim(Upper(cPais)) == AllTrim(Upper(cExpPais))
       oMessage:Warning('O pedido ' + AllTrim(cPedido)+' possui o pa�s do cliente igual ao pa�s do exportador.')
    EndIf

    /* Tratamento para Moedas: */
    cMoeERP := EasyGetXMLinfo(,oBusinessCont, "_CurrencyCode")
    cMoeda  := EasyConvCod( cMoeERP, "SYF" )

    /* Tratamento para Cond. Pgto: */
    cPgtERP  := EasyGetXMLinfo(,oBusinessCont, "_PaymentTermCode")
    cCondPgt := EasyConvCod( cPgtERP, "SY6" )

    SY6->(DbSetOrder(1))
    If !(lCondic := SY6->(DbSeek(xFilial("SY6") + AvKey(cCondPgt,"Y6_COD") )))  .And. !Empty(EasyGParam("MV_AVG0207",,""))
       cCondPgt := EasyGParam("MV_AVG0207",,"")
    EndIf

	If nOpc == 3
       /* Tratamento para Idioma: */
       cIdioma := Posicione("SYA", 1, xFilial("SYA")+AvKey(cPais,"YA_CODGI"), "YA_IDIOMA")  //Idioma do pais do Cliente

       //INGLES caso nao tenha nenhum idioma cadastrado
       If Empty(cIdioma)
          cIdioma := EasyGParam("MV_AVG0037",,"INGLES")
       EndIf

       /* Tratamento para Via de Transporte: */
       cVia :=  Posicione("EXJ", 1, xFilial("EXJ")+ AvKey(cCliCod,"EXJ_COD")+ AvKey(".","EXJ_LOJA") , "EXJ_VIA")

       If Empty(cVia)
          cVia := EasyGParam("MV_AVG0208",,"")
       EndIf

       /* Tratamento para Incoterm: */
       cIncoterm :=  Posicione("EXJ", 1, xFilial("EXJ")+ AvKey(cCliCod,"EE7_IMPORT")+ AvKey(".","EE7_IMLOJA") , "EXJ_INCOTE")

       SYJ->(DbSetOrder(1))
       If !SYJ->(DbSeek(xFilial("SYJ") + AvKey(cIncoterm,"YJ_COD") )) .And. !Empty(EasyGParam("MV_AVG0209",,""))//Incoterm
          cIncoterm := EasyGParam("MV_AVG0209",,"")
       EndIf

    EndIf

    /* ============================= *
    * Campos Obrigatorios Capa:     *
    * ============================= */
	//AddArrayXML(oRec, "EE7_PEDIDO", oBusinessCont,"_OrderId" , lObrigat)  //Codigo

    If EE7->(FieldPos("EE7_PEDERP")) > 0
       oRec:AddField("EE7_PEDERP", AvKey(cPedido, "EE7_PEDERP"))
    EndIf

    If !EasyGParam("MV_EEC0009",.T.) .Or. AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) == "#EE7_PEDIDO#" .Or. Empty(EasyGParam("MV_EEC0009",,""))
       oRec:AddField("EE7_PEDIDO", AvKey(cPedido, "EE7_PEDIDO"))
    Else
       cPed := StrTran(AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) ,"#EE7_PEDIDO#",AllTrim(cPedido))
       cPed := StrTran(AllTrim(Upper(cPed)) ,"#EE7_FORN#"  ,AllTrim(cExpCod))
       oRec:AddField("EE7_PEDIDO", AvKey(cPed, "EE7_PEDIDO"))
    EndIf

    EE7->(DbSetOrder(1))
    IF EE7->(DbSeek(xFilial("EE7") + EasyGetXMLinfo("EE7_PEDIDO",oBusinessCont, "_OrderId")))
	   cCliente := EE7->EE7_IMPORT
	EndIf

	If !(cCliCod == cCliente)
       AddArrayXML(oRec, "EE7_IMPORT", oBusinessCont,"_CustomerCode" , lObrigat) //Cod. Importador
       oRec:AddField("EE7_IMLOJA" , AvKey(".", "EE7_IMLOJA") ) //Loja Importador
    EndIf

    AddArrayXML(oRec, "EE7_FORN", oBusinessCont,"_CompanyId" , lObrigat)  //Cod. Fornecedor

    oRec:AddField("EE7_FOLOJA" , AvKey(".","EE7_FOLOJA" ) )  //Loja do Fornecedor

    If nOpc == 3
       SYJ->(DbSetOrder(1))
       SYJ->(DbSeek(xFilial("SYJ") + AvKey(cIncoterm,"YJ_COD") ))

	   //** AAF 30/12/2013 - Verificar se o incoterm contem seguro/frete para n�o perder a informa��o
	   lTemSeg := IsCpoInXML(oBusinessCont,"_InsuranceValue") .AND. Val(oBusinessCont:_InsuranceValue:Text) > 0
	   lTemFre := IsCpoInXML(oBusinessCont,"_FreightValue") .AND. Val(oBusinessCont:_FreightValue:Text) > 0

	   If lTemSeg
	      If SYJ->YJ_CLSEGUR <> "1"
	         cIncoterm := "CIF" //Coloca um incoterm que contenha seguro para n�o perder a informa��o
		  EndIf
	   Else
	      If lTemFre
             If SYJ->YJ_CLFRETE <> "1"
	            cIncoterm := "CFR" //Coloca um incoterm que contenha frete e n�o contenha seguro para n�o perder a informa��o
	         EndIf
		  EndIf
	   EndIf
	   //**

	   oRec:AddField("EE7_INCOTE", cIncoterm)

	   If !Empty(cVia)                                                                //NCF - Se n�o vier na integra��o ou por par�metro, n�o sobrepor gatilho da via de transporte do cadastro de cliente.
          oRec:AddField("EE7_VIA"     , AvKey(cVia, "EE7_VIA")   ) //Via de transp.
       EndIf

       oRec:AddField("EE7_IDIOMA" , AvKey(cIdioma,"EE7_IDIOMA") ) //Idioma Doc.
	EndIf

	If lCondic .Or. nOpc == 3
       oRec:AddField("EE7_CONDPA" , AvKey(cCondPgt ,"EE7_CONDPA") ) //Cond. pagto
	EndIf

	If !Empty(cMoeda) //Existe o preenchimento automatico do campo com o MV_EECUSS
	   oRec:AddField("EE7_MOEDA" , AvKey(cMoeda, "EE7_MOEDA")   ) //Moeda
	EndIf

    /* ============================= *
    * Campos N�o Obrigatorios Capa: *
    * ============================= */

    //AddArrayXML(oRec, "EE7_DESCON", oBusinessCont,"_TotalDiscount")  //Desconto

    //AddArrayXML(oRec, "EE7_DTPROC", oBusinessCont,"_RegisterDate")  //Dt.Processo

    AddArrayXML(oRec, "EE7_FRPREV", oBusinessCont,"_FreightValue")  //Frete Prev.

	If IsCpoInXML(oBusinessCont,"_InsuranceValue") //.AND. Val(oBusinessCont:_InsuranceValue:Text) > 0   //NCF - 19/08/2014 - Nopado - Em caso de altera��o do valor de seguro para 0, o sistema n�o efetuava a altera��o.
	   oRec:AddField("EE7_TIPSEG", "2") //Valor Fixo
	   AddArrayXML(oRec, "EE7_SEGPRE", oBusinessCont,"_InsuranceValue")  //Seguro
    EndIf

    If IsCpoInXML(oBusinessCont,"_CustomerOrderId")
       oRec:AddField("EE7_REFIMP", oBusinessCont:_CustomerOrderId:Text)
    EndIf

   If AllTrim(Upper(oMessage:GetBsnEvent())) == "DELETE"
	   oRec:AddField("AUTDELETA", "S")
       oExecAuto:AddField("PARAMS",oParams)

   ElseIf !Empty(EasyGetXMLinfo(,oBusinessCont, "_Status")) .AND. Val(EasyGetXMLinfo(,oBusinessCont, "_Status")) == 7
	   oParams:AddField("nOpc",5)
	   oExecAuto:AddField("PARAMS",oParams)
	   oRec:AddField("AUTCANCELA", "S")

   ElseIf lExcluiProc
       /* Quando for Upsert e n�o houver itens de mercadoria para atualiza��o do pedido
          que j� exista no Easy Export, para que n�o permane�a apenas a capa do processo
          o pedido ser� exclu�do. */
	   oParams:AddField("nOpc",5)
	   oExecAuto:AddField("PARAMS",oParams)
	   oRec:AddField("AUTDELETA", "S")
    Else

        oExecAuto:AddField("PARAMS",oParams)

	    If IsCpoInXML(oBusinessCont, "_SalesOrderItens")

         If IsCpoInXML(oBusinessCont:_SalesOrderItens, "_Item") .and. ValType(oBusinessCont:_SalesOrderItens:_Item) == "A"
            aArrayItens:= oBusinessCont:_SalesOrderItens:_Item
         Else
            aArrayItens:= { oBusinessCont:_SalesOrderItens:_Item }
         EndIf

         nTotDscPrcIt := 0                                                     // Total de desconto dos itens
         nTotDescont  := Val(EasyGetXMLinfo(, oBusinessCont,"_TotalDiscount")) // Total de desconto da capa
   	   nTotPed := PrcTotItens(aArrayItens)
		   nDescontIt := DscTotItens(aArrayItens)
		   nTotDescont -= nDescontIt

		   If nTotDescont > 0
            oRatDesc := EasyRateio():New(nTotDescont,nTotPed,Len(aArrayItens),AvSx3("EE8_DESCON", AV_DECIMAL))
         Else
		      nTotDescont := 0
		   EndIf

	      For nCont := 1 To Len(aArrayItens)

	            /* Se for item de servi�o, ser� descartado */
	            If IsCpoInXML(aArrayItens[nCont], "_TypeOperation") .And.;
	               AllTrim(Upper(EasyGetXMLinfo(, aArrayItens[nCont], "_TypeOperation"))) == "S"

	               Loop
	            EndIf

	            oItem := ERec():New()

		        /* Tratamento para Qnt na Embalagem: */
		        //Nopado pois a manuten��o faz esse tratamento em gatilho do campo do produto
		        //cProdCod := EasyGetXMLinfo("B1_COD", oBusinessCont:_SalesOrderItens:_Item[nCont], "_ProductID") //Cod. Produto
		        //nQtdEmb  := Posicione("SB1", 1, xFilial("SB1")+cProdCod, "B1_QE")  //Qt.na Embal.

		        /* Tratamento para Embalagem: */
		        //cEmb     := Posicione("SB1", 1, xFilial("SB1")+cProdCod, "B1_CODEMB")  //Embalagem.

		        cChave := xFilial("EE8") + EasyGetXMLinfo("EE8_PEDIDO", aArrayItens[nCont], "_OrderId") + STR(VAL(EasyGetXMLinfo("EE8_SEQUEN", aArrayItens[nCont], "_OrderItem")),TAMSX3("EE8_SEQUEN")[1]) + AvKey("","EE8_ITEMGR")
		        If nOpc == 3 .Or. aScan(aDados, { |X|  cChave == X } ) = 0
		           nOpcItem := 3
		        EndIf

		        /* ============================= *
		        * Campos Obrigatorios Detalhes: *
		        * ============================= */
			    oItem:AddField("EE8_FILIAL", xFilial("EE8"))

		        //AddArrayXML(oItem, "EE8_PEDIDO"  , aArrayItens[nCont] , "_OrderId", lObrigat) //Codigo do Pedido
                cPedido := EasyGetXMLinfo( "EE8_PEDIDO"  , aArrayItens[nCont] , "_OrderId")
         	    If EE8->(FieldPos("EE8_PEDERP")) > 0
                   oItem:AddField("EE8_PEDERP", AvKey(cPedido, "EE8_PEDERP"))
                EndIf
         	     If !EasyGParam("MV_EEC0009",.T.) .Or. AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) == "#EE7_PEDIDO#" .Or. Empty(EasyGParam("MV_EEC0009",,""))
                   oItem:AddField("EE8_PEDIDO", AvKey(cPedido, "EE8_PEDIDO"))
                Else
                   cPed := StrTran(AllTrim(Upper(EasyGParam("MV_EEC0009",,""))) ,"#EE7_PEDIDO#",AllTrim(cPedido))
                   cPed := StrTran(AllTrim(Upper(cPed)) ,"#EE7_FORN#"  ,AllTrim(cExpCod))
                   oItem:AddField("EE8_PEDIDO", AvKey(cPed, "EE8_PEDIDO"))
                EndIf

				//AddArrayXML(oItem, "EE8_SEQUEN"  , aArrayItens[nCont], "_OrderItem", .T.)
				oItem:AddField("EE8_SEQUEN", STR(VAL(EasyGetXMLinfo("EE8_SEQUEN", aArrayItens[nCont], "_OrderItem")),TAMSX3("EE8_SEQUEN")[1]))
				oItem:AddField("EE8_ITEMGR", "")

		      AddArrayXML(oItem, "EE8_COD_I"  , aArrayItens[nCont], "_ItemCode", lObrigat) //Cod. Produto

               //RMD - 03/12/13 - N�o carrega a descri��o do pedido, para que a mesma venha do cadastro de produtos, de acordo com o Idioma selecionado.
               /*
               If nOpcItem == 3 //.AND. .F. //Trocar o .F. por um MV //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
                  AddArrayXML(oItem, "EE8_VM_DES" , aArrayItens[nCont], "_ItemDescription", lObrigat) //Desc. Produto
               EndIf
               */

		      AddArrayXML(oItem, "EE8_FORN", aArrayItens[nCont] ,"_CompanyId" , lObrigat)  //Cod. Fornecedor

		      AddArrayXML(oItem, "EE8_SLDINI"  , aArrayItens[nCont] , "_Quantity"  , lObrigat) //Quantidade

		      cCod := EasyGetXMLinfo("B1_COD", aArrayItens[nCont], "_ItemCode")
		      If !Empty(cCod) .AND. SB1->(dbSeek(xFilial()+cCod))
		           cPeso := SB1->B1_PESO
		           If nOpcItem == 3
		              If Empty(SB1->B1_CODEMB)
		                 oItem:AddField("EE8_EMBAL1" , EasyGParam("MV_AVG0206",,"")  ) //Embalagem
    		          EndIf
		              If Empty(SB1->B1_QE)
		                 oItem:AddField("EE8_QE"      , 1  ) //Qt.na Embal.
		              EndIf
		           EndIf
		        EndIf

			    //Integra��o por pre�o aberto ou pre�o fechado conforme o inicializador padr�o do campo
				If lPrecoAb
		           AddArrayXML(oItem, "EE8_PRECO"   , aArrayItens[nCont] , "_UnityPrice", lObrigat) //Pre�o aberto
				Else
				   nPrecoFech := Round(Val(EasyGetXMLinfo(, aArrayItens[nCont], "_TotalPrice"))/Val(EasyGetXMLinfo(, aArrayItens[nCont], "_Quantity")),AvSX3("EE8_PRECO",AV_DECIMAL))
				   oItem:AddField("EE8_PRECO",nPrecoFech)
				EndIf

				If IsCpoInXml(aArrayItens[nCont], "_UnitWeight")
		           AddArrayXML(oItem, "EE8_PSLQUN"  , aArrayItens[nCont] , "_UnitWeight", lObrigat) //Peso Liquido
		        ElseIf nOpcItem == 3
	               //oItem:AddField("EE8_PSLQUN", Posicione("SB1", 1, xFilial("SB1")+aArrayItens[nCont]:_ItemCode:Text, "B1_PESO"))
	               oItem:AddField("EE8_PSLQUN", cPeso)
		        EndIf
		       //NCF - 13/07/2016
		       If IsCpoInXml(aArrayItens[nCont], "_CustomerOrderNumber")
		          AddArrayXML(oItem, "EE8_REFCLI"  , aArrayItens[nCont] , "_CustomerOrderNumber", .F.)
		       EndIf

		        nVlrDscPerc := 0

		        If IsCpoInXML(aArrayItens[nCont], "_DiscountPercentage") .And. Val(EasyGetXMLinfo(, aArrayItens[nCont], "_DiscountPercentage")) > 0
		           nVlrDscPerc := ( Val(EasyGetXMLinfo(, aArrayItens[nCont], "_UnityPrice")) * Val(EasyGetXMLinfo(, aArrayItens[nCont], "_Quantity")) ) - Val(EasyGetXMLinfo(, aArrayItens[nCont], "_TotalPrice"))
		        EndIf

		        If IsCpoInXML(aArrayItens[nCont], "_ItemDiscounts") .And. IsCpoInXML(aArrayItens[nCont]:_ItemDiscounts, "_ItemDiscount")
  		           nFator := Round(Val(EasyGetXMLinfo(, aArrayItens[nCont], "_UnityPrice")),AVSX3("EE8_PRECO",AV_DECIMAL))* Val(EasyGetXMLinfo(, aArrayItens[nCont], "_Quantity"))
		           nFator := Round(nFator/nTotPed,8)
		           If EasyGParam("MV_AVG0119",,.F.)
   		              nDesconto := Val(EasyGetXMLinfo(, aArrayItens[nCont]:_ItemDiscounts, "_ItemDiscount")) * Val(EasyGetXMLinfo(, aArrayItens[nCont], "_Quantity")) + (nTotDescont * nFator)
  		              oItem:AddField( "EE8_DESCON" , nDesconto )
                   Else
                      nDesconto += Val(EasyGetXMLinfo(, aArrayItens[nCont]:_ItemDiscounts, "_ItemDiscount")) * Val(EasyGetXMLinfo(, aArrayItens[nCont], "_Quantity"))
                   EndIf
                Else
                	//If nVlrDscPerc > 0

	  		           nFator := Round(Val(EasyGetXMLinfo(, aArrayItens[nCont], "_UnityPrice")),AVSX3("EE8_PRECO",AV_DECIMAL))* Val(EasyGetXMLinfo(, aArrayItens[nCont], "_Quantity"))
			           //nFator := Round(nFator/nTotPed,8)
			           If EasyGParam("MV_AVG0119",,.F.)
	   		              nDesconto := nVlrDscPerc + If(nTotDescont > 0, oRatDesc:GetItemRateio(nFator), 0)
	  		              oItem:AddField( "EE8_DESCON" , nDesconto )
	                   Else
	                      nDesconto += nVlrDscPerc
	                   EndIf


                       //oItem:AddField( "EE8_DESCON" , nVlrDscPerc )
                	//Else
                	   //oItem:AddField( "EE8_DESCON" , 0 )
                	//EndIf
		        EndIf
		        nTotDscPrcIt += nVlrDscPerc
		       /* ================================= *
		       * Campos N�o Obrigatorios Detalhes: *
		       * ================================= */
		        //AddArrayXML(oItem, "EE8_PRCTOT"   , oBusinessCont:_SalesOrderItens:_Item[nCont] , "_TotalPrice") //Preco Total

		        //oItens:AddField("EE8", oItem)
		        oItens:AddRec(oItem)

	       Next
	    EndIf
	EndIf

	// Desconto
	If AllTrim(Upper(oMessage:GetBsnEvent())) <> "DELETE"            //NCF - 11/06/2014
	   If !EasyGParam("MV_AVG0119",,.F.)
          oRec:AddField("EE7_DESCON", nTotDescont + nDesconto)
 	   Else
 	      If nTotDscPrcIt > 0
 	         oRec:AddField("EE7_DESCON", nTotDescont + nTotDscPrcIt)
 	      Else
   	         oRec:AddField("EE7_DESCON", nTotDescont)
   	      EndIf
       EndIf
     EndIf

	oExecAuto:AddField("EE7",oRec)
	oExecAuto:AddField("EE8",oItens)

End Sequence

Return oExecAuto


*-------------------------------------------------*
Function AP100ARESB(oMessage)
*-------------------------------------------------*
Local oRespond
Local oBusinessCont := oMessage:GetMsgContent()
Local cCliCod := ""
Local cExpCod := ""
Local cPais := ""
Local cExpPais := ""
Local cOrderId:= ""

	cCliCod  := EasyGetXMLinfo(, oBusinessCont, "_CustomerCode")   //Cod. Importado
    cExpCod  := EasyGetXMLinfo(, oBusinessCont, "_CompanyId")   //Cod. Exportador
    cPais    := Posicione("SA1", 1, xFilial("SA1")+AvKey(cCliCod,"A1_COD")+AvKey(".","A1_LOJA"), "A1_PAIS")  //Pais do Cliente
    cExpPais := Posicione("SA2", 1, xFilial("SA2")+AvKey(cExpCod,"A2_COD")+AvKey(".","A2_LOJA"), "A2_PAIS")  //Pais do Exportador
    cOrderId := EasyGetXMLinfo(, oBusinessCont, "_OrderId")

    If !oMessage:HasErrors()
       /*oRespond:SetField('LOG'       ,"Pedido de Exporta��o gravado com sucesso no ERP Protheus")
       oRespond:SetField('DateTime'  ,FwTimeStamp(3))
	   oRec:SetField('Message',oRespond)
       oXml:AddRec(oRec)*/
       oRespond  := ENode():New()

       If !Empty(cPais) .And. !Empty(cExpPais) .And. AllTrim(Upper(cPais)) == AllTrim(Upper(cExpPais))
          oRespond:SetField('OrderId',"")
       Else
          //oRespond:SetField('OrderId',EE7->EE7_PEDIDO)
          oRespond:SetField('OrderId', cOrderId)
       Endif

    Else
       oRespond := oMessage:GetContentList("RESPONSE")
    EndIf

Return oRespond

Static Function PrcTotItens(aArrayItens)
Local nTotPed := 0
Local nCont

  For nCont := 1 To Len(aArrayItens)
     nTotPed += Round(Val(EasyGetXMLinfo(, aArrayItens[nCont], "_UnityPrice")),AVSX3("EE8_PRECO",AV_DECIMAL))* Val(EasyGetXMLinfo(, aArrayItens[nCont], "_Quantity"))
  Next

Return nTotPed

Static Function DscTotItens(aArrayItens)
Local nTotDsc := 0
Local nCont

  For nCont := 1 To Len(aArrayItens)
     If IsCpoInXML(aArrayItens[nCont], "_DiscountPercentage") .And. Val(EasyGetXMLinfo(, aArrayItens[nCont], "_DiscountPercentage")) > 0
        nTotDsc += ( Val(EasyGetXMLinfo(, aArrayItens[nCont], "_UnityPrice")) * Val(EasyGetXMLinfo(, aArrayItens[nCont], "_Quantity")) ) - Val(EasyGetXMLinfo(, aArrayItens[nCont], "_TotalPrice"))
	 EndIf
  Next

Return nTotDsc

/*
Funcao      : AP100ValAdiant
Objetivos   : Valida se ha algum adiantamento vinculado com um contrato de financiamento.
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 05/10/2012
*/
Static Function AP100ValAdiant(nOpc)
Local lRet := .T.
Local aOrd := SaveOrd({"EEQ"})

Begin Sequence
	If nOpc == EXCLUIR
	   EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
       If EEQ->(DbSeek(xFilial("EEQ")+"P"+AvKey(EE7->EE7_PEDIDO,"EEQ_PREEMB")))
			Do While EEQ->(!EOF()).And. EEQ->(EEQ_FILIAL+EEQ_FASE+EEQ_PREEMB) == xFilial("EEQ")+"P"+AvKey(EE7->EE7_PEDIDO,"EEQ_PREEMB")
				If EasyIsVincAdiant(nOpc, EEQ->EEQ_NRINVO, EEQ->EEQ_PARC )
					lRet := .F.
					Exit
				EndIf
				EEQ->(DBSkip())
			EndDo
       EndIf
	EndIf
End Sequence

RestOrd(aOrd)
Return lRet
/*
Funcao          : AP100Valid()
Parametros      : Nenhum
Retorno         : lRet
Objetivos       : Valida��o dos campos de dicionario
Autor           : Guilherme Fernandes Pilan - GFP
Data/Hora       : 13/11/2013 :: 14:49
*/
*-------------------------*
Function AP100Valid()
*-------------------------*
Local lRet := .T.
Local cCampo:=UPPER(READVAR())

IF Left(cCampo,3) == "M->"
   cCampo:=Subs(cCampo,4)
ENDIF

Do Case
   Case cCampo == "EE8_CF"
      If Left(AllTrim(M->EE8_CF),1) <> "7"  // CFOP deve iniciar com '7', pois trata-se de exporta��o.
         EasyHelp(STR0207,STR0059) //"O CFOP informado � inv�lido para esta opera��o. Favor informar um CFOP iniciado com '7'."  ### "Aten��o"
         lRet := .F.
      EndIf
End Case

Return lRet

/*
Funcao          : AP100FilEEA()
Parametros      : cFase - Fase do processo
Retorno         : cRet
Objetivos       : Filtro da consulta padr�o EEA
Autor           : Marcos Roberto Ramos Cavini Filho - MCF
Data/Hora       : 09/09/2015 12:00
*/
*-------------------------*
Function AP100FilEEA(cFase)
*-------------------------*
Local cRet := ""

If Alltrim(cFase) == "P"
   cRet := 'EEA->EEA_FASE=="2" .Or. EEA->EEA_FASE=="1"'
ElseIf Alltrim(cFase) == "Q"
   cRet := 'EEA->EEA_FASE=="3" .Or. EEA->EEA_FASE=="1"'
Endif

Return cRet

*------------------------------------------------*
Static Function AP100MinDt()
*------------------------------------------------*
Local dData := cToD('  /  /  ')
Local cQuery,cFrom,cWhere
Local aOrd := SaveOrd("EE8")
Local cPedido := EE7->EE7_PEDIDO
Local cFilEE8 := xFilial("EE8")
cFrom    := RetSqlName("EE8")+" EE8 "
cWhere   := iIF( TcSrvType()=="AS/400"," EE8.@DELETED@ <> '*' "," EE8.D_E_L_E_T_ <> '*'" ) + " AND EE8.EE8_FILIAL = '"+cFilEE8+"' AND EE8.EE8_PEDIDO = '"+cPedido+"'"+" AND EE8.EE8_DTENTR <> '        '"
//Menor Data entre datas de entrega dos itens
cQuery := " SELECT MIN(EE8_DTENTR) AS MINDATE FROM  "+cFrom+" WHERE "+cWhere

dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"DTENTITENS", .F., .F. )

dData:= SToD(DTENTITENS->MINDATE)

DTENTITENS->( dbCloseArea() )

DBSELECTAREA("EE8")

RestOrd(aOrd,.T.)

Return dData

*------------------------------------------------*
Function AP100ARESR(oEasyMessage)
*------------------------------------------------*
Local oBusinessCont  := oEasyMessage:GetRetContent()
Local cPedERPExt     := EasyGetXMLinfo(, oBusinessCont, "_OrderId")

If !Empty(cPedERPExt)
   EE7->(Reclock("EE7",.F.))
   EE7->EE7_PEDERP := AvKey(cPedERPExt,"EE7_PEDERP")
   EE7->(MsUnlock())

   EE8->(DbSetOrder())
   EE8->(DbSeek(xFilial("EE8")+EE7->EE7_PEDIDO))
   Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == EE7->EE7_FILIAL .And. EE8->EE8_PEDIDO == EE7->EE7_PEDIDO
      EE8->(Reclock("EE8",.F.))
      EE8->EE8_PEDERP := AvKey(cPedERPExt,"EE8_PEDERP")
      EE8->(MsUnlock())
      EE8->(DbSkip())
   EndDo

   oEasyMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})
Else
   oEasyMessage:AddInList("RECEIVE", {"Erro"    , "Codigo do Pedido do ERP Externo nao foi obtido!" , Nil})
EndIf

Return oEasyMessage

/*
Fun��o: : CheckDescon()
Objetivo: Avalia se o desconto foi informado somente na capa mesmo como o par�metro MV_AVG0119 habilitado (desconto por itens)
          caso positivo, altera a vari�vel lDescIT
Autor       : Rodrigo Mendes/Nilson Cesar
Data/Hora   : 21/02/2014 - 19:30hs
*/
Static Function CheckDescon(aCab, aItens)
Local lHasDescIt := .F.
local i

	If lDescIt
		If (nPosCab := aScan(aCab, {|x| x[1] == "EE7_DESCON" })) > 0 .And. aCab[nPosCab][2] > 0
			For i := 1 To Len(aItens)
   			   If (nPosItem := aScan(aItens[i], {|x| x[1] == "EE8_DESCON" })) > 0 .And.  aItens[i][nPosItem][2] > 0
   			      lHasDescIt := .T.
   			   EndIf
			Next

			If !lHasDescIt
				//Possui desconto na capa mas n�o possui no item
				lDescIt := .F.
			EndIf

		EndIf
	EndIf

Return lHasDescIt

/*
Funcao      : SetInteg
Objetivo    : Indicar a exist�ncia de itens de mercadorias e servi�os na mensagem Sales Order
              recebida pelo EAI.
Parametros  : oBusinessCont - Mensagem
              lMercadoria - refer�ncia da vari�vel que indica a exist�ncia de item de mercadoria para a gera��o do pedido de venda (faturamento)
              lServico - refer�ncia da vari�vel que indica a exist�ncia de item de servi�o para a gera��o do processo de venda (siscoserv)
Retorno     :
Autor       : WFS
Data/Hora   : 10/07/2015
*/

Static Function SetInteg(oBusinessCont, lMercadoria, lServico)
Local aItens:= {}
Local nCont

Begin Sequence

   If IsCpoInXML(oBusinessCont, "_SalesOrderItens")
      If IsCpoInXML(oBusinessCont:_SalesOrderItens, "_Item") .and. ValType(oBusinessCont:_SalesOrderItens:_Item) == "A"
         aItens:= oBusinessCont:_SalesOrderItens:_Item
      Else
         aItens:= { oBusinessCont:_SalesOrderItens:_Item }
      EndIf

      For nCont:= 1 To Len(aItens)

         /* Se n�o possuir a tag, ou a tag vier com "P", ser� considerada mercadoria */
         If !IsCpoInXml(aItens[nCont], "_TypeOperation") .Or. AllTrim(Upper(EasyGetXMLinfo(, aItens[nCont] , "_TypeOperation"))) == "P"
            lMercadoria:= .T.
         EndIf

         /* Se a tag vier com "S", servi�o. */
         If AllTrim(Upper(EasyGetXMLinfo(, aItens[nCont] , "_TypeOperation"))) == "S"
            lServico:= .T.
         EndIf

         /* Se j� tiverem sido identificados os dois tipos de produtos, interrompe o FOR */
         If lServico .And. lMercadoria
            Break
         EndIf

      Next
   EndIf

End Sequence

Return

/*
Funcao      : AP100EXECAUT()
Objetivo    : Pr�-execu��o da rotina autom�tica para as integra��es EAI, possibilitando
              integrar ora o pedido de exporta��o e ora o processo de venda de servi�os
Parametros  : aCab - array com o dados de capa
              aItem - array com os dados dos itens
              nOpc - opera��o
Retorno     :
Autor       : WFS
Data/Hora   : 10/07/2015
*/
/*
Function AP100ExecAut(oMsg)
//Function AP100EXECAUT(aCab, aItens, nOpc)
Local lRet:= .F.
Local aCab, aItens, nOpc

Begin Sequence


   If !lNoIntEEC
      aCab:= oMsg:GetEAutoArray("EE7")
      aItens:= EasyEAutItens("EE7", "EE8", oMsg:GetEAutoArray("EE7"), oMsg:GetEAutoArray("EE8"))
      nOpc:= oMsg:GetOperation()

      If AScan(aCab, {|x| x[1] == "EE7_PEDIDO"}) > 0
         //nModulo:= 29
         //cModulo:= "EEC"
         lRet:= EECAP100(aCab, aItens, nOpc)
      EndIf
   EndIf

   If !lNoIntESS
      aCab:= oMsg:GetEAutoArray("EJW")
      aItens:= EasyEAutItens("EJW", "EJX", oMsg:GetEAutoArray("EJW"), oMsg:GetEAutoArray("EJX"))
      nOpc:= oMsg:GetOperation()

      If AScan(aCab, {|x| x[1] == "EJW_PROCES"}) > 0
         //nModulo:= 85
         //cModulo:= "ESS"
         lRet:= ESSPV400(aCab, aItens,, nOpc)
      EndIf
   EndIf

End Sequence

Return lRet*/


/*
Funcao      : AP100OPC
Parametros  : Visualiza��o da tela de opcionais
Retorno     : NIL
Autor       : Lucas Raminelli - LRS
Data/Hora   : 20/10/2015
*/
*----------------------------*
Function AP100OPC(cAliasTab,nOpca)
*----------------------------*
local cRet := ""
Local aOrd := SaveOrd("SG1")
Local cCampo :=""
Local lOpcPadrao:= GetNewPar("MV_REPGOPC","N") == "N"

SB1->(DbSetOrder(1))

IF lOpcPadrao
	cCampo := cAliasTab+"_OPC"
Else
	cCampo := cAliasTab+"_MOP"
EndIF

IF Empty(M->EE8_COD_I)
   MsgInfo(STR0218,STR0024)//Produto n�o preenchido para a consulta de itens opcionais.;Aten��o
else
    SG1->(DbSetOrder(1))
    If SG1->(DbSeek(xFilial('SG1')+M->&(cAliasTab+"_COD_I")))
	   If ExistOPC(M->&(cAliasTab+"_COD_I")) //THTS - 10/07/2021 - Verifica se na Estrutura SG1 existe Grupo e Item de Opcionais vinculado
         IF nOpca <> 3
            SeleOpc(1,"EECAP100",M->&(cAliasTab+"_COD_I"),Nil,@cRet,M->&(cCampo),"M->"+cCampo)
         Else
            SeleOpc(1,"EECAP100",M->&(cAliasTab+"_COD_I"),Nil,@cRet,M->&(cCampo),"M->"+cCampo,.T.)
         EndIF
      Else
         EasyHelp(STR0258,STR0024,STR0259) //"A Estrutura do Produto n�o possui Grupo e Item de Opcionais."#####"Acesse o Cadastro de Estruturas do Produto e informe um Grupo e um Item de Opcionais."
      EndIf
    Else
	   MsgInfo(STR0219,STR0024)//Item n�o possui uma estrutura de opcionais cadastrados.;Aten��o
    EndIF
EndIF
//LRS - 30/10/2015 Variavel cCampoBKP esta salvando o retorno da fun��o SeleOpc, pois estava dando problema na troca de tela de itens.
cCampoBKP := M->&(cCampo)

RestOrd(aOrd,.T.)
Return nil

/*
Funcao      : ExistOPC
Parametros  : cProd - Codigo do Produto
Retorno     : .T. - Existe Grupo e Item de Opcionais para o Produto / .F. Nao existe Grupo e Item de Opcionais para o Produto
Autor       : THTS - Tiago Tudisco
Data/Hora   : 07/10/2021
*/
Static Function ExistOPC(cProd)
Local lRet  := .F.
Local cQuery:= ""

cQuery := " SELECT G1_COD "
cQuery += " FROM " + RetSqlName("SG1") + " "
cQuery += " WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
cQuery += "   AND G1_COD    = '" + cProd + "' "
cQuery += "   AND G1_GROPC	<> ' ' "
cQuery += "   AND G1_OPC	<> ' ' "
cQuery += "   AND D_E_L_E_T_= ' ' "

If EasyQryCount(cQuery) > 0
   lRet := .T.
EndIf

Return lRet

/*
Funcao      : AP100OTPB2B
Parametros  : Converter pedido em back to back
Retorno     : .T.
Autor       : Alessandro - AAF / Flavio - FDR
Data/Hora   : 13/07/2016
*/
Function AP100TPB2B()

Begin Sequence

If Empty(EE7->EE7_PEDIDO) .Or. !Empty(EE7->EE7_TIPO)
   Break
EndIf

EE9->(DbSetOrder(1))
If EE9->(DbSeek(xFilial("EE9")+EE7->EE7_PEDIDO))
	EasyHelp(STR0221) //"Pedido n�o pode ser convertido, pois j� possui embarque."
	Break
EndIf

EES->(DbSetOrder(4))
If EES->(DbSeek(xFilial("EES")+EE7->EE7_PEDIDO))
	EasyHelp(STR0226) //"Pedido n�o pode ser convertido, pois j� possui nota fiscal."
	Break
EndIf

If MsgYesNo(STR0227,STR0024) //"Confirma a convers�o do Pedido de Exporta��o para Pedido Back to Back ?, Aten��o"
   EE7->(RecLock("EE7", .F.))
   EE7->EE7_TIPO := "4"
   EE7->(MsUnlock())
   MsgInfo(STR0228,STR0036) //"Pedido convertido para Back to Back com sucesso. Acesse a manuten��o de pedidos Back to back para visualiza-lo., Aviso"
EndIf

End Sequence

Return .T.

/*
Funcao      : AP100OTPB2B
Parametros  : Converter back to back em pedido
Retorno     : .T.
Autor       : Alessandro - AAF / Flavio - FDR
Data/Hora   : 13/07/2016
*/
Function AP100EXTPB2B()

Begin Sequence

If Empty(EE7->EE7_PEDIDO) .Or. EE7->EE7_TIPO <> "4"
   Break
EndIf

EE9->(DbSetOrder(1))
If EE9->(DbSeek(xFilial("EE9")+EE7->EE7_PEDIDO))
	EasyHelp(STR0221) //"Pedido n�o pode ser convertido, pois j� possui embarque."
	Break
EndIf

If Empty(EE7->EE7_PEDERP)
   	EasyHelp(STR0222) //"Pedido originado como Back To Back n�o poder� ser convertido em Pedido de Exporta��o, pois o mesmo n�o possui integra��o com o ERP Externo."
	Break
EndIf

EXK->( dbSetOrder(1))
If EXK->( dbSeek(xFilial("EXK")+OC_PE+EE7->EE7_PEDIDO) )
	EasyHelp(STR0223) //"Pedido n�o pode ser convertido, pois j� possui invoice Back to Back."
	Break
EndIf

If MsgYesNo(STR0224,STR0024) //"Confirma a convers�o do Pedido Back to Back para Pedido de Exporta��o Regular?, Aten��o"
   EE7->(RecLock("EE7", .F.))
   EE7->EE7_TIPO := " "
   EE7->(MsUnlock())
   MsgInfo(STR0225,STR0036) //"Pedido Back to Back convertido para Pedido de Exporta��o Regular com sucesso. Acesse a manuten��o de pedido de Exporta��o para visualiza-lo., Aviso"
EndIf

End Sequence

Return .T.
/*
Fun��o     : NFRemFimEsp()
Objetivo   : Retonar se a rotina est� com nova estrutura de controle de saldo
Par�metros :
Retorno    :
Autor      : WFS
Data       : set/2016
Revis�o    :
Observa��o : Remover esta fun��o e suas chamadas quando a funcionalidade for publicada
             no release 12.
*/
Static Function NFRemFimEsp()
Local lRet:= .f.

   If FindFunction("NFRemNewStruct") .And. NFRemNewStruct()
      lRet:= .T.
   EndIf

Return lRet

/*
Funcao     : IntegAux()
Parametros : aAuto - Array com os dados complementares
Objetivos  : Integrar dados complementares do pedido recebidos via ExecAuto
Autor      : Rodrigo Mendes Diaz
*/
Static Function IntegAux(aAuto)
Local cAlias, nPos, i, j, nOpc, aItem

    For i := 1 To Len(aAuto)
        If lMsErroAuto
            Exit
        EndIf
        If !(ValType(aAuto[i]) == "A" .And. Len(aAuto[i]) == 2 .And. ValType(aAuto[i][1]) == "C" .And. ValType(aAuto[i][2]) == "A")
            EasyHelp(STR0233, STR0036)//"Falha de Integra��o: Foram informados dados complementares com a estrutura incorreta."###"Aviso"
            lMsErroAuto := .T.
            Loop
        EndIf
        cAlias := aAuto[i][1]
        If (cAlias $ "EEC|EE9")
            Loop
        EndIf
        For j := 1 To Len(aAuto[i][2])
            aItem := aAuto[i][2][j]
            //Verifica se � uma opera��o de Exclus�o
            If aScan(aItem, {|x| x[1] == "AUTDELETA" .And. X[2] == "S" }) > 0
                nOpc := EXCLUIR
            Else
                nOpc := INCLUIR//Ser� tratado como UPSERT na rotina correspondente
            EndIf
            //Executa a integra��o
            Do Case
                Case cAlias == "EEN"
                    If (lMsErroAuto := !AP100Notify(OC_PE,nOpc,aItem))
                        Exit
                    EndIf
                Case cAlias == "EXB"
                    If (lMsErroAuto := !AP100Agenda(OC_PE, nOpc, aItem))
                        Exit
                    EndIf
                Case cAlias == "EEB"
                    If (lMsErroAuto := !AP100AGEN(OC_PE,nOpc,aItem))
                        Exit
                    EndIf
                Otherwise
                    If !(cAlias $ "EEC|EE9")
                        EasyHelp(StrTran(STR0234, "XXX", cAlias), STR0036) //"Erro de integra��o: A tabela 'XXX' n�o est� dispon�vel para integra��o"###"Aviso"
                        lMsErroAuto := .T.
                    EndIf
            EndCase
        Next
    Next


Return !lMsErroAuto

/*
Funcao     : AtuVia()
Parametros : aAuto - Array com os campos de ExecAuto de Pedido
Objetivos  : Cadastrar automaticamente a Origem/Destino na via de transporte quando o par�metro ATUVIA for recebido
Autor      : Rodrigo Mendes Diaz
*/
Static Function AtuVia(aAuto)
Local nPos
Local cVia, cOrigem, cDestino, cTipTran
Local lAtuVia := .F.

    //Verifica se a op��o de atualiza��o autom�tica da via de transporte foi enviada
    If (nPos := aScan(aAuto, {|x| x[1] == "ATUVIA" })) > 0
        lAtuVia := aAuto[nPos][2]
        aDel(aAuto, nPos)
        aSize(aAuto, Len(aAuto)-1)
    EndIf
    If lAtuVia
        //Identifica os dados da via de transporte
        If (nPos := aScan(aAuto, {|x| x[1] == "EE7_VIA" })) > 0
            cVia := Avkey(aAuto[nPos][2], "YR_VIA")
        EndIf
        If (nPos := aScan(aAuto, {|x| x[1] == "EE7_ORIGEM" })) > 0
            cOrigem := Avkey(aAuto[nPos][2], "YR_ORIGEM")
        EndIf
        If (nPos := aScan(aAuto, {|x| x[1] == "EE7_DEST" })) > 0
            cDestino := Avkey(aAuto[nPos][2], "YR_DESTINO")
        EndIf
        If (nPos := aScan(aAuto, {|x| x[1] == "EE7_TIPTRA" })) > 0
            cTipTran := Avkey(aAuto[nPos][2], "YR_TIPTRAN")
        EndIf

        //Verifica se a Via Possui a Origem/Destino
        SYQ->(DBSetOrder(1))
        SYR->(DbSetOrder(1))
        If SYQ->(DBSeek(xFilial()+cVia)) .And. !SYR->(DbSeek(xFilial()+cVia+cOrigem+cDestino+cTipTran))
            
            aCabVia  := {}
            aAdd(aCabVia, {"YQ_VIA"      , cVia         , Nil})
            
            aItsVia  := {}
            aItVia   := {}
            aAdd(aItVia, {"YR_VIA"     , cVia           , Nil})
            aAdd(aItVia, {"YR_ORIGEM"  , cOrigem        , Nil})
            aAdd(aItVia, {"YR_DESTINO" , cDestino       , Nil})
            aAdd(aItVia, {"YR_TIPTRAN" , cTipTran       , Nil})
            aAdd(aItsVia, aItVia)

            //Fecha o tempor�rio "WORKAG" pois a rotina de cadastro possui um tempor�rio com o mesmo nome
            WORKAG->(dbCloseArea())
            TETempReopen(cNomArq2, "WorkAg", "WorkAgTMP")
            MsAguarde({|| MSExecAuto( {|X,Y,Z| EECCV100(X,Y,Z)},aCabVia ,aItsVia, ALTERAR) }, "Integrando Vias de transportes!")
            WORKAGTMP->(dbCloseArea())
            TETempReopen(cNomArq2, "WorkAgTMP", "WorkAg")
            Set Index To (cNomArq2+TEOrdBagExt()),(cNomArq22+TEOrdBagExt())
        EndIf
    EndIf

Return Nil

/*
Funcao     : AtuEmbArr()
Objetivos  : Prepara o array do Execauto para inclus�o/atualiza��o autom�tica do embarque
Autor      : Rodrigo Mendes Diaz
*/
Static Function AtuEmbArr(nOpc, aAutoCab, aAutoItens, aAutoComp)
Local i, j
Local aEECAuto, aEE9Auto, aEmbTables

    If ValType(aAutoComp) == "A"
        aEmbTables := aClone(aAutoComp)
    Else
        aEmbTables := {}
    EndIf

    If aScan(aAutoComp, {|x| Upper(Alltrim(x[1])) == "EEC" }) == 0
        aEECAuto := aClone(aAutoCab)
        For i := 1 To Len(aEECAuto)
            If i <= Len(aEECAuto)
                aEECAuto[i][1] := StrTran(aEECAuto[i][1], "EE7", "EEC")
                If aEECAuto[i][1] == "EEC_PEDIDO"
                    aEECAuto[i][1] := "EEC_PREEMB"
                EndIf
                If TamSX3(aEECAuto[i][1]) == Nil//Verifica se o campo existe no dicion�rio
                    aDel(aEECAuto, i)
                    aSize(aEECAuto, Len(aEECAuto) - 1)
                    i := i - 1
                EndIf
            EndIf
        Next
        If nOpc == INCLUIR .And. aScan(aEECAuto, {|x| x[1] == "EEC_PEDREF" }) == 0
            aAdd(aEECAuto, {"EEC_PEDREF", M->EE7_PEDIDO, Nil})
        EndIf
        aAdd(aEmbTables, {"EEC", aEECAuto})
    EndIf

    If aScan(aAutoComp, {|x| Upper(Alltrim(x[1])) == "EE9" }) == 0
        aEE9Auto := aClone(aAutoItens)
        i := 1
        While i <= Len(aEE9Auto)
            If i <= Len(aEE9Auto)
                j := 1
                While j <= Len(aEE9Auto[i])
                    If j <= Len(aEE9Auto[i])
                        aEE9Auto[i][j][1] := StrTran(aEE9Auto[i][j][1], "EE8", "EE9")
                        If TamSx3(aEE9Auto[i][j][1]) == Nil//Verifica se o campo existe no dicion�rio
                            aDel(aEE9Auto[i], j)
                            aSize(aEE9Auto[i], Len(aEE9Auto[i])-1)
                            j := j - 1
                        EndIf
                    EndIf
                    j++
                EndDo
                If (nPos := aScan(aEE9Auto[i], {|x| x[1] == "EE9_PEDIDO" })) == 0
                    aAdd(aEE9Auto[i], {"EE9_PEDIDO", M->EE7_PEDIDO,})
                EndIf
                EE9->(DbSetOrder(1))
                If nOpc == 4 .And. EasySeekAuto("EE9", aEE9Auto[i])
                    cPedSeq := EE9->(EE9_PEDIDO+EE9_SEQUEN)
                    EE9->(DbSkip())
                    If EE9->(EE9_PEDIDO+EE9_SEQUEN) == cPedSeq
                        EasyHelp(StrTran(STR0235, "XXX", EE9->EE9_SEQUEN), STR0036) //"N�o foi poss�vel atualizar automaticamente no embarque o item de sequ�ncia 'XXX', pois o mesmo foi dividido em mais de uma sequ�ncia de embarque."###"Aviso"
                        aDel(aEE9Auto, i)
                        aSize(aEE9Auto, Len(aEE9Auto)-1)
                        i := i - 1
                    EndIf
                EndIf
            EndIf
            i++
        EndDo
        aAdd(aEmbTables, {"EE9", aEE9Auto})
    EndIf

Return aEmbTables


Static Function Ap100ConsFor(aITens)

   If AScan(aItens, {|x| x[1] == "EE8_FORN"} ) > 0
      M->EE8_FORN := ""
      M->EE8_FOLOJA := ""
   EndIf

Return Nil

/*
Funcao          : ECAP100When()
Parametros      : Campo que ser� verificado se deve estar habilitado na tela
Retorno         : lRet
Objetivos       : Fun��o para defini��o se campo estar� ou n�o habilitado na tela
Autor           : Guilherme Fernandes Pilan - GFP
Data/Hora       : 16/03/2021
*/
*-------------------------*
Function ECAP100When(cCampo)
*-------------------------*
Local lWhen := .T.

Do Case
   Case cCampo == "EE8_OPER"
      If Empty(M->EE8_OPER) .And. (!Empty(M->EE8_TES) .Or. !Empty(M->EE8_CF)) 
         lWhen := .F.            
      EndIf   
   Case cCampo == "EE8_TES"
      If Empty(M->EE8_TES) .And. !Empty(M->EE8_OPER)
         lWhen := .F.            
      EndIf      
   Case cCampo == "EE8_CF"      
      If Empty(M->EE8_CF) .And. !Empty(M->EE8_OPER)
         lWhen := .F.            
      EndIf
EndCase

Return lWhen


/*
Funcao          : AP100DespIt
Parametros      : nPrcTotCapa: indica o valor total de referencia para o rateio
                : nPrcUnit   : indica o valor unit�rio de referencia para o rateio
                : nCountItens: indica o n�mero de itens que far�o parte do rateio
                : nDecimais  : decimais
                : nDesp      : indica o valor a ser rateado               
Retorno         : nDespesa   : retorna o valor da despesa rateada proporcional ao item em questao
Objetivos       : Fun��o para retornar o valor de uma despesa do processo proporcional ao item em questao
Autor           : Maur�cio Frison
Data/Hora       : 09/06/2021
*/
Function AP100DespIt(nPrcTotCapa,nPrcUnit,nCountItens,nDecimais,nDesp)
//Capa - work + item
Local oValor := EasyRateio():new(nDesp,nPrcTotCapa,nCountItens,nDecimais)
Local nDespesa := oValor:GetItemRateio(nPrcUnit)
return nDespesa

// Apura outras despesas interancioanis + seguro                
Function AP100getDesp(aDespesas,nPrcTotCapa,nVltotIt,nCount,nArredUnit)
Local nDespCapa := 0
Local i
For i := 1 to Len(aDespesas)
    if !(aDespesas[i][1] $ "FR/FA")
         nDespCapa+= M->&(aDespesas[i][2]) 
    Endif     
Next
Return AP100DespIt(nPrcTotCapa,nVltotIt,nCount,nArredUnit,nDespCapa) 

// Apura Frete
Function AP100getFrt(nPrcTotCapa,nVltotIt,nCount,nArredUnit,nFrtCapa,nLiqCapa,nLiqIt,nBrtCapa,nBrtIt)
Local cRATEIOFrt    := GetNewPar("MV_AVG0021","3")
Local nFrtIt
DO CASE
   case cRATEIOFrt == "1" 
        nFrtIt   := AP100DespIt(nLiqCapa,nLiqIt,nCount,nArredUnit,nFrtCapa) 
   case cRateioFrt == "2"   
        nFrtIt   := AP100DespIt(nBrtCapa,nBrtIt,nCount,nArredUnit,nFrtCapa)          
   otherwise
        nFrtIt   := AP100DespIt(nPrcTotCapa,nVltotIt,nCount,nArredUnit,nFrtCapa) 
EndCase        
Return nFrtIt

//Apura Desconto
//cTabProc dever� ser "M->EEC" ou "M->EE7"
Function AP100getD(nPrcTotCapa,nVltotIt,nCount,nArredUnit,cTabProc)
Local nDescIt
Local cTabIte  :=  if(cTAbProc=='M->EEC',"M->EE9","M->EE8")
If EasyGParam("MV_AVG0119",,.F.)//Desconto por item
   nDescIt :=  &(cTabIte + "_DESCON")  //M->EE9_DESCON
Else
   nDescIt := AP100DespIt(nPrcTotCapa,nVltotIt,nCount,nArredUnit,&(cTabProc + "_DESCON"))          
EndIf
If  (&(cTabPRoc+"_TPDESC") $ CSIM) 
    //neste caso n�o faz nada, pois o valor do desconto dever� ser subtra�do
Else 
   nDescIt := nDescIt*-1 //neste casao o valor do desconto dever� ser somado       
EndIf
return nDescIt

*-----------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAP100.PRW                                                *
*-----------------------------------------------------------------------------*
