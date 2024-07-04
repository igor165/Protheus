#INCLUDE "EFFPJ160.ch"
#include "Average.ch"
#include "TOPCONN.CH"


//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EFFPJ160
//Autor.....: Cleverson E. da Silva(CES)
//Data......: 12 de Junho de 2002, 16:00
//Sintaxe...: EFFPJ160 
//Uso.......: SIGAEFF   
//Versao....: Protheus - 8.11
//Descricao.: Provisao de Juros (Utilizando SetPrint) 
//------------------------------------------------------------------------------------//

*----------------------*
FUNCTION EFFPJ160()
*----------------------*
Local i
LOCAL cDataHoje,cMesAtual
LOCAL nIndSX3 := SX3->(IndexOrd())
//ALCIR ALVES -14-02-05  CASO EXISTA NOVOS CAMPOS DA CHAVE EF1,EF2 E EF3
PRIVATE lExistBCO := iif(EF3->(FieldPos("EF3_BAN_FI")) > 0 .AND. EF3->(FieldPos("EF3_PRACA")) > 0 .AND.;
                         EF2->(FieldPos("EF2_BAN_FI")) > 0 .AND. EF2->(FieldPos("EF2_PRACA")) > 0 ,.T.,.F.) 
// ----------------------------------------------------------------------                         
PRIVATE cNomeArq,lTop,dDtIni,dDtFim,cContrato,IsEF1C:=.f.,cExist:=.F.
PRIVATE cQuery,cFilEF1:=xFilial("EF1"),cFilEF2:=xFilial("EF2"),cFilEF3:=xFilial("EF3")
Private lFilOri := SX3->( dbSeek("EF1_FILORI") .AND. dbSeek("EF1_FILORI") )      //AAF - 30/12/04 - Indica se existe o campo com filial de origem.
Private lVerOut := Posicione("SX2",1,"EF1","X2_MODO") == "E" .AND. VerSenha(115) //AAF - 30/12/04 - Indica se o usuário pode ver outras filiais.

// ACSJ - 02/03/2005 -------- INICIO - Verifica a existencia do campo EF1_ROF
SX3->(DBSetOrder(2))
Private lExistRof := SX3->(DBSEEK("EF1_ROF"))
// -------------------------- FIM                                                                             
Private cFilSX5:=xfilial("SX5")
Private cFilEEQ:=xfilial("EEQ")
Private cFilSA1:=xfilial("SA1")
Private cFilSA2:=xfilial("SA2")
SX3->(DBSetOrder(nIndSX3))
ef1->(dbsetorder(1))
ef3->(dbsetorder(1))
EF2->(DBSETORDER(2))
#IFDEF TOP
  lTop := .T.
#ElSE
  lTop := .F.
#ENDIF  

Private cFiliais := "'"
Private aFiliais := AvgSelectFil(.T.,"EF1")
//** PLB - 28/04/2006 - Nova estrutura das tabelas de financiamento - EF1_TPMODU e EF1_SEQCNT.
Private cFiltroF3Fin := "E/I"            // Variavel utilizada no F3 "EFA"
Private lEvCont := .F.                   // Variavel utilizada no F3 "EFA"
Private lCadFin := ChkFile("EF7")        // Cadastro de Tipos de Financiamento
Private cTpModu := "E"
Private cFiltroF3Rof := "E/I"
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0
Private cChSX1    := "" ,;
        cParSX1   := "" ,;
        cSeqSX1   := "" ,;
        cValidSX1 := "" 
//**

if aFiliais[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
   //Alcir Alves - 07-01-05
   IF LEN(aFiliais)==1 .AND. ALLTRIM(aFiliais[1])="" 
       IsEF1C:=.t.
       
   ENDIF
   cFiliais:=""
   for i:=1 to len(aFiliais)
      cFiliais+=iif(!empty(cFiliais),",","")+"'"+aFiliais[i]+"'"
   next    

   //DO WHILE .T.         
   
   /*   if !IsEF1C
         aEval(aFiliais,{|x,y| cFiliais += x + iIF(y == Len(aFiliais),"'","','")})
      endif
   */ 
      
      IF PERGUNTE("EFFSA1",.T.) 
         //** PLB 28/04/06
         If lEFFTpMod
            Do Case
               Case mv_par01 == 1
                  cTpModu := "E"
               Case mv_par01 == 2
                  cTpModu := "I"
            End Case
         EndIf
         //**
         cContrato  := IIF(lEFFTpMod,mv_par02,mv_par01)
         dDtIni     := IIF(EMPTY(IIF(lEFFTpMod,mv_par04,mv_par02)),CTOD("01/01/1950"),IIF(lEFFTpMod,mv_par04,mv_par02))
         dDtFim     := IIF(EMPTY(IIF(lEFFTpMod,mv_par05,mv_par03)),CTOD("01/01/2010"),IIF(lEFFTpMod,mv_par05,mv_par03))
         cDataHoje  :=DTOC(dDataBase)
         cMesAtual  :=SUBSTR(cDataHoje,4,2)
   
         IF EMPTY(dDtIni) .AND. EMPTY(dDtFim)
   
            dDtIni:=CTOD("01"+SUBSTR(cDataHoje,3))
            dDtFim:=dDtIni+30
      
            DO WHILE cMesAtual # SUBSTR(DTOC(dDtFim),4,2)
               dDtFim--
            ENDDO
      
         ELSEIF EMPTY(dDtIni) .AND. !EMPTY(dDtFim)
   
            dDtIni:=CTOD("01"+SUBSTR(DTOC(dDtFim),3))
   
         ELSEIF !EMPTY(dDtIni) .AND. EMPTY(dDtFim)
   
            dDtFim:=dDtIni+30
      
            DO WHILE SUBSTR(DTOC(dDtIni),4,2) # SUBSTR(DTOC(dDtFim),4,2)
               dDtFim--
            ENDDO                                                      
         ENDIF  
         PJ160PRINT()
      ENDIF
   ENDIF

   EF2->(DBSETORDER(1))


RETURN .T.

*---------------------*
FUNCTION PJ160PRINT()
*---------------------*
LOCAL cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
LOCAL cDesc2         := STR0002 //"Provisao de Juros"
LOCAL cDesc3         := "", cPict := "", imprime := .T.
Local cAliasOld      := Alias()
PRIVATE titulo       := STR0002 //"Provisao de Juros"
PRIVATE nLin         := 80, Cabec1 :=STR0003+DTOC(dDtIni)+STR0004+DTOC(dDtFim), Cabec2 := ""  //"Periodo de "###" a "
PRIVATE cString      := "EF1", CbTxt := "", lEnd := .F.
PRIVATE lAbortPrint  := .F., limite := 220, tamanho := "G"
PRIVATE nomeprog     := "EFFPJ160", nTipo := 18
PRIVATE aReturn      := {STR0005 , 1,STR0006, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
PRIVATE nLastKey     := 0,  cbcont := 00
PRIVATE CONTFL       := 01, m_pag := 01
PRIVATE wnrel        := "EFFPJ160" // Coloque aqui o nome do arquivo usado para impressao em disco
Private WorkFile     := ""
cbtxt := Space(10)



   //** PLB 28/04/06
   If lEFFTpMod
      cabec2 := STR0034 //"Modulo: "
      If lExistRof
         cParSX1:="mv_par16"
      Else
         cParSX1:="mv_par15"
      EndIf
   Else
      If lExistRof
         cParSX1:="mv_par14"
      Else
         cParSX1:="mv_par13"
      EndIf
   EndIf            
   //**

IF &(cParSX1)==1  //iif(lExistRof,mv_par14,mv_par13)==1 //caso destino seja impressora ALCIR ALVES - 16-02-05
   wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)
   If nLastKey = 27
      Return
   Endif
   SetDefault(aReturn,cString)
   nTipo := If(aReturn[4]==1,15,18)
   RptStatus({|lEnd| PJ160Imprime(wnRel,cString)})
ELSE
   Processa({||PJ160Imprime()})
   Erase(WorkFile+TEOrdBagExt())
   DbSelectArea(cAliasOld)
ENDIF

Return .T. 

*-------------------------*
FUNCTION PJ160Imprime()
*-------------------------*  
Local lExistEF3 := .F. // PLB 01/05/06 - Verifica se encontrou algum evento
Local nTpMod := 0      
LOCAL FilAtu:="-",cfilSA6:=xfilial("SA6") //Filial atual - Alcir Alves - 06-01-05
LOCAL cChave:=aFiliais[1]//AAF 30/12/04 - Multifiliais
Local cAliasArq:="EF1EXP",cFilSYF:=xFilial("SYF"),aContratos
LOCAL bWhile:={||EF1->EF1_FILIAL==cChave},cNomeMoeda:=" ",cTipoContrato:="",nAscan
LOCAL lFirst:=.T.,nCont,nLinRelTot:=17 //Numero de linhas usada para cada Contrato tipo fin <>1
//LOCAL aSeekEF3:={"520","521","522","640","650","999"},cMoeda:=EasyGParam("MV_SIMB1")
LOCAL aSeekEF3:={"520","521","522","550","551","640","641","642","643","644","645","646","647","648","649","650","670","671","672","673","674","675","676","677","678","679","999"}
LOCAL nLenCampo:=AVSX3("EF3_VL_MOE",3), nInd, cMoeda:=EasyGParam("MV_SIMB1")
//Varivaeis Acumulado Anterior
LOCAL nVlJPAA :=nVlRJPAA:=nVlEJPAA:=nVlREJPAA:=nVlJACEAA:=nVlRJACEAA:=nVlEJACEAA:=0
LOCAL nVlREJACEAA:=nVlTACCEAA:=nVlRTACCEAA:=nVlEACCEAA:=nVlERCCEAA:=nVlLiquiAA:=0
LOCAL nVlRLiquiAA:=nVlELiquiAA:=nVlERLiquiAA:=0,cWhile:=""
Local nFil //AAF 30/12/04 - Multifiliais

//Varivaeis Movimento Mes
LOCAL nVlJPMM :=nVlRJPMM:=nVlEJPMM:=nVlREJPMM:=nVlJACEMM:=nVlRJACEMM:=nVlEJACEMM:=0
LOCAL nVlREJACEMM:=nVlTACCEMM:=nVlRTACCEMM:=nVlEACCEMM:=nVlETRCEMM:=nVlLiquiMM:=0
LOCAL nVlRLiquiMM:=nVlELiquiMM:=nVlERLiquiMM:=0
//Totais
LOCAL nTotEsLiqui:=nTotLiqui:=nTotERACCE:=nTotTACCE:=nTotEJACE:=nTotJACE:=nTotEJP:=nTotJP:=0
LOCAL nTotREsLiqui:=nTotRLiqui:=nTotRERACCE:=nTotRTACCE:=nTotREJACE:=nTotRJACE:=nTotREJP:=nTotRJP:=0

LOCAL nCol01:=01,nCol02:=nCol01+40,nCol03:=nCol02+60,nCol04:=nCol03+60                     
LOCAL nTotGeral:=0

LOCAL nCol02m:=((nCol02+LEN(STR0007))+nCol02)/2 //"Acumulado Anterior"
LOCAL nCol02c:=nCol02m-nLenCampo-5,nCol02d:=nCol02m+3
LOCAL nCol02a:=(2*nCol02c+nLenCampo+3)/2,nCol02b:=(2*nCol02d+nLenCampo+3)/2


LOCAL nCol03m:=((nCol03+LEN(STR0008))+nCol03)*0.50 //"Movimento Mes"
LOCAL nCol03c:=nCol03m-nLenCampo-5,nCol03d:=nCol03m+3
LOCAL nCol03a:=(2*nCol03c+nLenCampo-3)/2,nCol03b:=(2*nCol03d+nLenCampo-3)/2


LOCAL nCol04m:=((nCol04+LEN(STR0009))+nCol04)*0.50 //"Acumulado Atual"
LOCAL nCol04c:=nCol04m-nLenCampo-5,nCol04d:=nCol04m+3
LOCAL nCol04a:=(2*nCol04c+nLenCampo-3)/2,nCol04b:=(2*nCol04d+nLenCampo-3)/2


LOCAL cPicture:=AVSX3("EF3_VL_MOE",6),cPictTXVAR:=AVSX3("EF2_TX_VAR",6)
LOCAL cPictTXFIX:=AVSX3("EF2_TX_FIX",6),cPictTXDIA:=AVSX3("EF2_TX_DIA",6)
LOCAL nVlContrato:=0,nVlRealCont:=0,nTaxa:=1,nLinTot:=66
LOCAL nCol01T:=01,nCol02T:=nCol01T+30,nCol03T:=nCol02T+25,nCol04T:=nCol03T+32            
LOCAL nTit01T:=nCol01T,nTit02T:=nTit01T+30,nTit03T:=nTit02T+30,nTit04T:=nTit03T+30
LOCAL lTotal := .F.

PRIVATE nLin := 99
Private cTipoModu := ""

//ALCIR ALVES - 15-02-05 - EXPORTAÇÃO PARA EXCEL OU TEXTO
//IF iif(lExistRof,mv_par14,mv_par13)==2 .or. iif(lExistRof,mv_par14,mv_par13)==3 //caso destino de impressão seja texto ou excel
IF &(cParSX1)==2 .Or. &(cParSX1)==3  // PLB 28/04/06
    Adata:= {}
    Aadd(Adata,{"FILIAL",AVSX3("EF1_FILIAL",2),4,AVSX3("EF3_FILIAL",4)}) //FILIAL
    If lEFFTpMod
       Aadd(Adata,{"TPMODU",AVSX3("EF1_TPMODU",2),AVSX3("EF1_TPMODU",3),AVSX3("EF1_TPMODU",4)}) // PLB 24/06/04  // Tipo Modulo
    EndIf
    Aadd(Adata,{"CONTRATO",AVSX3("EF1_CONTRA",2),AVSX3("EF1_CONTRA",3),AVSX3("EF1_CONTRA",4)}) //CONTRATO
    If lEFFTpMod
       Aadd(Adata,{"SEQCNT",AVSX3("EF1_SEQCNT",2),AVSX3("EF1_SEQCNT",3),AVSX3("EF1_SEQCNT",4)}) // PLB 24/06/04  // Sequencia
    EndIf
    Aadd(Adata,{"TIPO_CONTR",AVSX3("EF1_TP_FIN",2),10,0}) //TIPO DE CONTRATO
    Aadd(Adata,{"BANCO_OP",AVSX3("EF1_BAN_FI",2),AVSX3("EF1_BAN_FI",3),AVSX3("EF1_BAN_FI",4)}) //BANCO
    IF lExistBCO
        Aadd(Adata,{"PRACA",AVSX3("EF1_PRACA",2),AVSX3("EF1_PRACA",3),AVSX3("EF1_PRACA",4)}) //PRACA
    ENDIF
    Aadd(Adata,{"MOEDA",AVSX3("YF_DESC_SI",2),AVSX3("YF_DESC_SI",3),AVSX3("YF_DESC_SI",4)}) //MOEDA
    Aadd(Adata,{"VALOR_MOE",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR DO CONTRATO

    Aadd(Adata,{"JUROP_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS PRINCIPAL NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"JUROP_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS PRINCIPAL NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"JUROP_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS PRINCIPAL NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"ESTJP_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS PRINCIPAL NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"ESTJP_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS PRINCIPAL NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"ESTJP_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS PRINCIPAL NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"JACE_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS ACE NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"JACE_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS ACE EM REAL - MOVIMENTO MES
    Aadd(Adata,{"JACE_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS ACE EM REAL - ACUMULADO ATUAL
    Aadd(Adata,{"EACE_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS ACE PRINCIPAL NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"EACE_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS ACE PRINCIPAL NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"EACE_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS ACE PRINCIPAL NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"ACECC_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //TRANSFERENCIA ACC/ACE NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"ACECC_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //TRANSFERENCIA ACC/ACE NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"ACECC_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //TRANSFERENCIA ACC/ACE NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"EACEC_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //Estorno TRANSFERENCIA ACC/ACE NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"EACEC_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //Estorno TRANSFERENCIA ACC/ACE NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"EACEC_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //Estorno TRANSFERENCIA ACC/ACE NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"LIQ_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"LIQ_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"LIQ_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"ELIQ_MOE1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"ELIQ_MOE2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"ELIQ_MOE3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO NA MOEDA - ACUMULADO ATUAL


    Aadd(Adata,{"JUROP_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS PRINCIPAL NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"JUROP_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS PRINCIPAL NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"JUROP_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS PRINCIPAL NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"ESTJP_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS PRINCIPAL NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"ESTJP_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS PRINCIPAL NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"ESTJP_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS PRINCIPAL NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"JACE_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS ACE NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"JACE_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS ACE EM REAL - MOVIMENTO MES
    Aadd(Adata,{"JACE_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //JUROS ACE EM REAL - ACUMULADO ATUAL
    Aadd(Adata,{"EACE_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS ACE PRINCIPAL NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"EACE_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS ACE PRINCIPAL NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"EACE_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO JUROS ACE PRINCIPAL NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"ACECC_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //TRANSFERENCIA ACC/ACE NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"ACECC_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //TRANSFERENCIA ACC/ACE NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"ACECC_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //TRANSFERENCIA ACC/ACE NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"EACEC_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //Estorno TRANSFERENCIA ACC/ACE NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"EACEC_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //Estorno TRANSFERENCIA ACC/ACE NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"EACEC_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //Estorno TRANSFERENCIA ACC/ACE NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"LIQ_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"LIQ_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"LIQ_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //LIQUIDACAO NA MOEDA - ACUMULADO ATUAL
    Aadd(Adata,{"ELIQ_REA1",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO NA MOEDA - ACUMULADO ANTERIOR
    Aadd(Adata,{"ELIQ_REA2",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO NA MOEDA - MOVIMENTO MES
    Aadd(Adata,{"ELIQ_REA3",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //ESTORNO LIQUIDACAO NA MOEDA - ACUMULADO ATUAL
    If Select("Work") > 0
       Work->( DBCloseArea() )       
    EndIf

    WorkFile := E_CriaTrab(,Adata,"Work") //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados
ENDIF
//

IF !EMPTY(cContrato)
   cChave:=aFiliais[1]+cContrato
   bWhile:={||EF1->EF1_FILIAL+EF1->EF1_CONTRA==cChave}
Else   // ACSJ - 04/03/2005
   cChave:=aFiliais[01] //AAF - 30/12/04 - MultiFiliais
   bWhile:={||EF1->EF1_FILIAL==cChave}
ENDIF

IF lTop
   bWhile:={||.T.}
   //cAliasArq:="EF1NEW"
   //** PLB 01/05/06 - Gera uma query para cada tipo de modulo
   If lEFFTpMod
      If mv_par01==3  // Ambos
         cAliasArq:="EF1EXP" 
         PJ160QUERY("EF1EXP")
         cAliasArq:="EF1IMP"
         PJ160QUERY("EF1IMP")
      ElseIf mv_par01==1  // Exportacao
         cAliasArq:="EF1EXP" 
         PJ160QUERY("EF1EXP")
      ElseIf mv_par01==2  // Importacao
         cAliasArq:="EF1IMP"
         PJ160QUERY("EF1IMP")
      EndIf
   Else
      cAliasArq:="EF1EXP" 
      PJ160QUERY("EF1EXP")
   EndIf
   //**
ENDIF

//aContratos:={{cMoeda,nVlRJPAA,nVlRJPMM,nVlREJPAA,nVlREJPMM,nVlRJACEAA,nVlRJACEMM,;
//             nVlREJACEAA,nVlREJACEMM,nVlRTACCEAA,nVlRTACCEMM,nVlERCCEAA,nVlETRCEMM,;
//             nVlRLiquiAA,nVlRLiquiMM,nVlERLiquiAA,nVlERLiquiMM}}
             
//aFilToT := {{cMoeda,nVlRJPAA,nVlRJPMM,nVlREJPAA,nVlREJPMM,nVlRJACEAA,nVlRJACEMM,;
//             nVlREJACEAA,nVlREJACEMM,nVlRTACCEAA,nVlRTACCEMM,nVlERCCEAA,nVlETRCEMM,;
//             nVlRLiquiAA,nVlRLiquiMM,nVlERLiquiAA,nVlERLiquiMM}}

EF1->(DBSEEK(cChave))

afilSA6:=AvgSelectFil(.F.,"SA6") //CADASTRO DE BANCOS   
//** PLB 01/05/06
For nTpMod := 1  To  IIF((lEFFTpMod .And. mv_par01==3),2,1)
   If lEFFTpMod
      If  ( mv_par01==3  .And.  nTpMod == 2 ) .Or. mv_par01==2
         cAliasArq := "EF1IMPNEW"
         cTipoModu := "Importacao"
      Else
         cAliasArq := "EF1EXPNEW"
         cTipoModu := "Exportacao"
      EndIf
   Else
      cAliasArq := "EF1EXPNEW"
   EndIf
   //AAF - 03/01/05
   If lVerOut
      cFilAtu:= (cAliasArq)->EF1_FILIAL
      lToTFil:= .F.                        
   Endif
   //
   (cAliasArq)->( DBGoTop() )
   nVlJPAA :=nVlRJPAA:=nVlEJPAA:=nVlREJPAA:=nVlJACEAA:=nVlRJACEAA:=nVlEJACEAA:=0
   nVlREJACEAA:=nVlTACCEAA:=nVlRTACCEAA:=nVlEACCEAA:=nVlERCCEAA:=nVlLiquiAA:=0
   nVlRLiquiAA:=nVlELiquiAA:=nVlERLiquiAA:=0
   nVCJRAA := nRVCJRAA := nTxContAA := 0 //ASK 06/11/2007
   //Varivaeis Movimento Mes
   nVlJPMM :=nVlRJPMM:=nVlEJPMM:=nVlREJPMM:=nVlJACEMM:=nVlRJACEMM:=nVlEJACEMM:=0
   nVlREJACEMM:=nVlTACCEMM:=nVlRTACCEMM:=nVlEACCEMM:=nVlETRCEMM:=nVlLiquiMM:=0
   nVlRLiquiMM:=nVlELiquiMM:=nVlERLiquiMM:=0 
   nVCJRMM := nRVCJRMM := nTxContMM := 0 //ASK 06/11/2007
   //Totais
   nTotEsLiqui:=nTotLiqui:=nTotERACCE:=nTotTACCE:=nTotEJACE:=nTotJACE:=nTotEJP:=nTotJP:=0
   nTotREsLiqui:=nTotRLiqui:=nTotRERACCE:=nTotRTACCE:=nTotREJACE:=nTotRJACE:=nTotREJP:=nTotRJP:=0
   nVlContrato:=nVlRealCont:=0
   nTotGeral:=0
   aContratos:={{cMoeda,nVlRJPAA,nVlRJPMM,nVlREJPAA,nVlREJPMM,nVlRJACEAA,nVlRJACEMM,;
                nVlREJACEAA,nVlREJACEMM,nVlRTACCEAA,nVlRTACCEMM,nVlERCCEAA,nVlETRCEMM,;
                nVlRLiquiAA,nVlRLiquiMM,nVlERLiquiAA,nVlERLiquiMM}}
             
   aFilToT := {{cMoeda,nVlRJPAA,nVlRJPMM,nVlREJPAA,nVlREJPMM,nVlRJACEAA,nVlRJACEMM,;
                nVlREJACEAA,nVlREJACEMM,nVlRTACCEAA,nVlRTACCEMM,nVlERCCEAA,nVlETRCEMM,;
                nVlRLiquiAA,nVlRLiquiMM,nVlERLiquiAA,nVlERLiquiMM}}
   nLin := 99
   //**
   For nFil := 1 To Len(aFiliais)
   //   cChave:=aFiliais[nFil]  ACSJ - 04/03/2005
   //   EF1->(DBSEEK(cChave))   ACSJ - 04/03/2005
      cfilSA6:=iif(len(afilSA6)==1 .and. alltrim(afilSA6[1])=="",aFilSA6[1],aFiliais[nFil])
      DO WHILE (cAliasArq)->(!EOF()) .AND. EVAL(bWhile) // ACSJ - 04/03/2005 
         IF nLin >nLinTot
            Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)
            nLin:=08
         ENDIF
         IF lTop
            EF1->(DBGOTO((cAliasArq)->REGISTRO))  // PLB 01/05/06
            //EF1->(DBGOTO(EF1NEW->REGISTRO))
            //EF1->(DBSEEK((cAliasArq)->(EF1_FILIAL+EF1_CONTRA)))
         ELSEIF !EMPTY(EF1->EF1_DT_ENC)
            (cAliasArq)->(DBSKIP())
            LOOP
         ENDIF

         //** PLB 28/04/06 - Validacao dos novos Filtros
         If lEFFTpMod  
            If !Empty(mv_par01)  .And.  mv_par01 != 3  .And.  EF1->EF1_TPMODU != cTpModu  // Tipo do Modulo
               (cAliasArq)->(DBSkip())
               Loop
            EndIf
            If !Empty(mv_par03)  .And.  EF1->EF1_SEQCNT != mv_par03 // Sequencia do Contrato
               (cAliasArq)->(DBSkip())
               Loop
            EndIf
         EndIf
         //**

         //Alcir Alves - 15-02-05 - validações dos novos perguntes
         IF !empty(IIF(lEFFTpMod,mv_par06,mv_par04)) .and. EF1->EF1_TP_FIN#IIF(lEFFTpMod,mv_par06,mv_par04)    //tipo de financiamento
              (cAliasArq)->(DBSKIP())
              LOOP
         ENDIF
         IF !empty(IIF(lEFFTpMod,mv_par08,mv_par06)) .and. EF1->EF1_EXPORT#IIF(lEFFTpMod,mv_par08,mv_par06)    //Exportador
              (cAliasArq)->(DBSKIP())
              LOOP
         ENDIF

         IF !empty(IIF(lEFFTpMod,mv_par09,mv_par07)) .and. EF1->EF1_LOJA#IIF(lEFFTpMod,mv_par09,mv_par07)    //Loja
              (cAliasArq)->(DBSKIP())
              LOOP
         ENDIF
 
         IF  !empty(IIF(lEFFTpMod,mv_par14,mv_par12)) .and. EF1->EF1_BAN_FI#IIF(lEFFTpMod,mv_par14,mv_par12)  //VALIDAÇÃO DO PERGUNTE BANCO DA OPERAÇÃO
             (cAliasArq)->(DBSKIP())
             LOOP
         ENDIF      
      
         If lExistRof
            IF  !empty(IIF(lEFFTpMod,mv_par15,mv_par13)) .and. EF1->EF1_ROF#IIF(lEFFTpMod,mv_par15,mv_par13)  //VALIDAÇÃO DO PERGUNTE ROF
                (cAliasArq)->(DBSKIP())
                LOOP
            ENDIF      
         Endif

         //ALCIR ALVES - 15-02-05
         cExist:=.F.
         IF !lExistBCO //CASO NÃO EXISTA OS NOVOS CAMPOS EF2_BAN_FI E EF2_PRACA
             cExist:=(!EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA)) .OR. !EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA)))
         ELSEIf !lEFFTpMod // PLB 28/04/06 - Caso nao exista TPMODU e SEQCNT
             cExist:=(EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA)) .OR. EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA)))
         Else
             cExist:=(EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT)) .OR. EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT)))
         ENDIF 
         //
         IF !cExist
            IF lTop
               (cAliasArq)->(DBSKIP())         
            ELSE
               EF1->(DBSKIP())
            ENDIF
            LOOP
         ENDIF
      
         IF SYF->(DBSEEK(cFilSYF+EF1->EF1_MOEDA))
            cNomeMoeda:=ALLTRIM(SYF->YF_DESC_SI)
         ENDIF
      
         //ALCIR ALVES - 15-02-05
         cExist:=.F.
         IF !lExistBCO //CASO NÃO EXISTA OS NOVOS CAMPOS EF2_BAN_FI E EF2_PRACA
             cExist:=EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA+"100"))
         ELSEIf !lEFFTpMod // PLB 28/04/06 - Caso nao exista TPMODU e SEQCNT
             cExist:=EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+"100"))
         Else
             cExist:=EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+"100"))
         ENDIF 
         //
         IF cExist
            nVlContrato:=EF3->EF3_VL_MOE
            nTaxa:=BuscaTaxa(EF1->EF1_MOEDA,dDtFim,.T.,.F.,.T.)
            nVlRealCont:=nVlContrato*nTaxa
         ENDIF
   
         IF EF1->EF1_TP_FIN=="01"
            nLinRelTot:=21
         ENDIF
   
         cTipoContrato:=IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Tabela("CG",EF1->EF1_TP_FIN,.F.))
         nTotEsLiqui:=nTotLiqui:=nTotERACCE:=nTotTACCE:=nTotEJACE:=nTotJACE:=nTotEJP:=nTotJP:=0
         nTotREsLiqui:=nTotRLiqui:=nTotRERACCE:=nTotRTACCE:=nTotREJACE:=nTotRJACE:=nTotREJP:=nTotRJP:=0
   
         nVlJPAA :=nVlRJPAA:=nVlEJPAA:=nVlREJPAA:=nVlJACEAA:=nVlRJACEAA:=nVlEJACEAA:=0
         nVlREJACEAA:=nVlTACCEAA:=nVlRTACCEAA:=nVlEACCEAA:=nVlERCCEAA:=nVlLiquiAA:=0
         nVlRLiquiAA:=nVlELiquiAA:=nVlERLiquiAA:=0
         nVlJPMM :=nVlRJPMM:=nVlEJPMM:=nVlREJPMM:=nVlJACEMM:=nVlRJACEMM:=nVlEJACEMM:=0
         nVlREJACEMM:=nVlTACCEMM:=nVlRTACCEMM:=nVlEACCEMM:=nVlETRCEMM:=nVlLiquiMM:=0
         nVlRLiquiMM:=nVlELiquiMM:=nVlERLiquiMM:=0
        
         FOR nCont:=1 TO LEN(aSeekEF3)
   
            //Alcir Alves - 16/02/05
            cWhile:={|| .T. }
            IF !lExistBCO //CASO NÃO EXISTA OS NOVOS CAMPOS EF2_BAN_FI E EF2_PRACA
                 EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA+aSeekEF3[nCont]))
            ELSEIf !lEFFTpMod // PLB 28/04/06 - Caso nao exista TPMODU e SEQCNT
                 EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+aSeekEF3[nCont]))
                 cWhile:={|| EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA }
            Else
                 EF3->(DBSEEK(aFiliais[nFil]+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT+aSeekEF3[nCont]))
                 cWhile:={|| EF3->EF3_TPMODU==EF1->EF1_TPMODU .And. EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA .And. EF3->EF3_SEQCNT==EF1->EF1_SEQCNT }
            ENDIF
            //
            DO WHILE EF3->(!EOF()) .AND. EF3->EF3_FILIAL==aFiliais[nFil] .AND. EF3->EF3_CONTRA==EF1->EF1_CONTRA .AND. EF3->EF3_CODEVE==aSeekEF3[nCont] .and. eval(cWhile)
               IF EF3->EF3_DT_EVE > dDtFim
                  EF3->(DBSKIP())
                  LOOP
               ENDIF

               //Alcir Alves - 15-02-05
               IF  !empty(IIF(lEFFTpMod,mv_par10,mv_par08)) .and. EF3->EF3_PREEMB#IIF(lEFFTpMod,mv_par10,mv_par08)  //VALIDAÇÃO DO PERGUNTE EMBARQUE
                  EF3->(DBSKIP())
                  LOOP
               ENDIF      
               IF  !empty(IIF(lEFFTpMod,mv_par11,mv_par09)) .and. EF3->EF3_INVOIC#IIF(lEFFTpMod,mv_par11,mv_par09)  //VALIDAÇÃO DO PERGUNTE INVOICE
                  EF3->(DBSKIP())
                  LOOP              
                              
               ENDIF      
               IF !empty(IIF(lEFFTpMod,mv_par07,mv_par05)) .and. EF3->EF3_CODEVE#IIF(lEFFTpMod,mv_par07,mv_par05)  //evento
                  EF3->(DBSKIP())
                  LOOP
               ENDIF      
               IF !empty(IIF(lEFFTpMod,mv_par12,mv_par10)) .OR. !empty(IIF(lEFFTpMod,mv_par13,mv_par11)) //CASO O PERGUNTE IMPORTADOR OU LOJA D IMPORT NÃO ESTEJAM VAZIOS
                    IF EEC->(DBSEEK(aFiliais[nFil]+EF3->EF3_PREEMB))
                        IF !empty(IIF(lEFFTpMod,mv_par12,mv_par10)) .AND. EEC->EEC_IMPORT#IIF(lEFFTpMod,mv_par12,mv_par10) //CASO IMPORTADOR DIFERENTE
                           EF3->(DBSKIP())
                           LOOP
                        ENDIF
                        IF !empty(IIF(lEFFTpMod,mv_par13,mv_par11)) .AND. EEC->EEC_IMLOJA#IIF(lEFFTpMod,mv_par13,mv_par11)  //CASO LOJA DIFERENTE
                           EF3->(DBSKIP())
                           LOOP
                        ENDIF
                    ELSE
                        EF3->(DBSKIP())
                        LOOP
                    ENDIF
               ENDIF
               //          
         
               DO CASE
                  CASE EF3->EF3_DT_EVE < dDtIni
               
                     IF EF3->EF3_CODEVE=="520" .AND. EF3->EF3_TP_EVE<>"02"
                        nVlJPAA +=EF3->EF3_VL_MOE
                        nVlRJPAA+=EF3->EF3_VL_REA       
                     ELSEIF EF3->EF3_CODEVE=="550" .AND. EF3->EF3_TP_EVE<>"02" //ASK 06/11/2007  
                        nVlRJPAA+=EF3->EF3_VL_REA  //Soma as variações do Juros Principal ACC  
                     ELSEIF EF3->EF3_CODEVE=="551" .AND. EF3->EF3_TP_EVE<>"02" //ASK 02/01/2008
                        nVlRJPAA+=EF3->EF3_VL_REA  //Soma as variações do Juros Principal ACC  
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="520" .AND. EF3->EF3_TP_EVE<>"02"
                        nVlEJPAA +=EF3->EF3_VL_MOE
                        nVlREJPAA+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="520" .AND. EF3->EF3_TP_EVE=="02"
                        nVlJACEAA +=EF3->EF3_VL_MOE
                        nVlRJACEAA+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="550" .AND. EF3->EF3_TP_EVE=="02" //ASK 06/11/2007  
                        nRVCJRAA +=EF3->EF3_VL_REA //Soma as variações para mostrar no juros e na transferência em Reais
                     ELSEIF EF3->EF3_CODEVE=="551" .AND. EF3->EF3_TP_EVE=="02" //ASK 02/01/2008  
                        nRVCJRAA +=EF3->EF3_VL_REA //Não estava considerando V.C. DA PROVISÃO DE JUROS (Taxa Desceu)
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="520" .AND. EF3->EF3_TP_EVE=="02"
                        nVlEJACEAA +=EF3->EF3_VL_MOE
                        nVlREJACEAA+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="650" //.AND. EF3->EF3_TP_EVE=="02"
                        nVlTACCEAA +=EF3->EF3_VL_MOE
                        nVlRTACCEAA+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="650" .AND. EF3->EF3_TP_EVE=="02"
                        nVlEACCEAA +=EF3->EF3_VL_MOE
                        nVlERCCEAA +=EF3->EF3_VL_REA                  
                  ELSEIF (EF3->EF3_CODEVE $ "640/641/642/643/644/645/646/647/648/649" .or. EF3->EF3_CODEVE $ "670/671/672/673/674/675/676/677/678/679" ) .AND. EF3->EF3_TP_EVE=="02" //Alcir Alves - 25-07-05 - considera evento 670 - baixa forçada
                        nVlLiquiAA +=EF3->EF3_VL_MOE
                        nVlRLiquiAA+=EF3->EF3_VL_REA
                  ELSEIF EF3->EF3_CODEVE=="999" .AND. (EF3->EF3_EV_EST $ "640/641/642/643/644/645/646/647/648/649" .or. EF3->EF3_EV_EST $ "670/671/672/673/674/675/676/677/678/679") .AND. EF3->EF3_TP_EVE=="02" //Alcir Alves - 25-07-05 - considera evento 670 - baixa forçada
                        nVlELiquiAA+=EF3->EF3_VL_MOE
                        nVlERLiquiAA+=EF3->EF3_VL_REA
                     ENDIF
         
               CASE (EF3->EF3_DT_EVE>=dDtIni .AND. EF3->EF3_DT_EVE<=dDtFim) .or. (empty(dDtIni) .and. empty(dDtFim)) 
         
                    IF EF3->EF3_CODEVE=="520" .AND. EF3->EF3_TP_EVE<>"02"
                        nVlJPMM +=EF3->EF3_VL_MOE
                        nVlRJPMM+=EF3->EF3_VL_REA  
                    ELSEIF EF3->EF3_CODEVE=="550" .AND. EF3->EF3_TP_EVE<>"02" //ASK 06/11/2007  
                        nVlRJPMM+=EF3->EF3_VL_REA  //Soma as variações do Juros Principal ACC              
                    ELSEIF EF3->EF3_CODEVE=="551" .AND. EF3->EF3_TP_EVE<>"02" //ASK 02/01/2008  
                        nVlRJPMM+=EF3->EF3_VL_REA  //Soma as variações do Juros Principal ACC              
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="520" .AND. EF3->EF3_TP_EVE<>"02"
                        nVlEJPMM +=EF3->EF3_VL_MOE
                        nVlREJPMM+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="520" .AND. EF3->EF3_TP_EVE=="02"
                        nVlJACEMM +=EF3->EF3_VL_MOE
                        nVlRJACEMM+=EF3->EF3_VL_REA                  
                     ELSEIF EF3->EF3_CODEVE=="550" .AND. EF3->EF3_TP_EVE=="02" //ASK 06/11/2007  
                        nRVCJRMM +=EF3->EF3_VL_REA //Soma as variações para mostrar no juros e na transferência em Reais
                     ELSEIF EF3->EF3_CODEVE=="551" .AND. EF3->EF3_TP_EVE=="02" //ASK 02/01/2008
                        nRVCJRMM +=EF3->EF3_VL_REA //Soma as variações para mostrar no juros e na transferência em Reais
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="520" .AND. EF3->EF3_TP_EVE=="02"
                        nVlEJACEMM +=EF3->EF3_VL_MOE
                        nVlREJACEMM+=EF3->EF3_VL_REA                  
                     ELSEIF EF3->EF3_CODEVE=="650" //.AND. EF3->EF3_TP_EVE=="02"
                        nVlTACCEMM +=EF3->EF3_VL_MOE
                        nVlRTACCEMM+=EF3->EF3_VL_REA                  
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST=="650" .AND. EF3->EF3_TP_EVE=="02"
                        nVlEACCEMM +=EF3->EF3_VL_MOE
                        nVlETRCEMM+=EF3->EF3_VL_REA                  
                     ELSEIF (EF3->EF3_CODEVE $ "640/641/642/643/644/645/646/647/648/649" .or. EF3->EF3_CODEVE $ "670/671/672/673/674/675/676/677/678/679") .AND. EF3->EF3_TP_EVE=="02" //Alcir Alves - 25-07-05 - considera evento 670 - baixa forçada
                        nVlLiquiMM +=EF3->EF3_VL_MOE
                        nVlRLiquiMM+=EF3->EF3_VL_REA
                     ELSEIF EF3->EF3_CODEVE=="999" .AND. (EF3->EF3_EV_EST $ "640/641/642/643/644/645/646/647/648/649" .or. EF3->EF3_EV_EST $ "670/671/672/673/674/675/676/677/678/679") .AND. EF3->EF3_TP_EVE=="02" //Alcir Alves - 25-07-05 - considera evento 670 - baixa forçada
                        nVlELiquiMM+=EF3->EF3_VL_MOE
                        nVlERLiquiMM+=EF3->EF3_VL_REA
                     ENDIF                                                          
                  ENDCASE
                 lExistEF3 := .T.
                 EF3->(DBSKIP())
            ENDDO              
      
         NEXT

         //** PLB 01/05/06 - Caso nao encontre evento
         If !lExistEF3
            (cAliasArq)->(DBSkip())
            Loop
         EndIf
         //**

         //ASK 06/11/2007 - Tratamento para calcular os valores em Reais com a última contabil considerando assim variação cambial para os valores em R$
         nVCJRAA  := nVLJACEAA + nVLTACCEAA //Soma os eventos 520 e 650 na moeda
         nRVCJRAA += nVLRJACEAA + nVLRTACCEAA //Soma os eventos 520 , 650 e 550  em Reais
         nTxContAA:= nRVCJRAA / nVCJRAA 
         nVLRJACEAA := nVLJACEAA * nTxContAA
         nVLRTACCEAA := nVLTACCEAA * nTxContAA
         
         nVCJRMM  := nVLJACEMM + nVLTACCEMM //Soma os eventos 520 e 650 na moeda
         nRVCJRMM += nVLRJACEMM + nVLRTACCEMM //Soma os eventos 520 , 650 e 550  em Reais
         nTxContMM:= nRVCJRMM / nVCJRMM 
         nVLRJACEMM := nVLJACEMM * nTxContMM
         nVLRTACCEMM := nVLTACCEMM * nTxContMM

         lTotal:= .T.   
         //Primeira Posicao da Moeda Local
   
         aContratos[01,02]+=nVlRJPAA
         aContratos[01,03]+=nVlRJPMM
   
         aContratos[01,04]+=nVlREJPAA
         aContratos[01,05]+=nVlREJPMM
   
         aContratos[01,06]+=nVlRJACEAA
         aContratos[01,07]+=nVlRJACEMM
   
         aContratos[01,08]+=nVlREJACEAA
         aContratos[01,09]+=nVlREJACEMM
   
         aContratos[01,10]+=nVlRTACCEAA
         aContratos[01,11]+=nVlRTACCEMM
   
         aContratos[01,12]+=nVlERCCEAA
         aContratos[01,13]+=nVlETRCEMM
   
         aContratos[01,14]+=nVlRLiquiAA
         aContratos[01,15]+=nVlRLiquiMM
   
         aContratos[01,16]+=nVlERLiquiAA
         aContratos[01,17]+=nVlERLiquiMM
      
         //** AAF 03/01/05 - Total Por Filial
         If lVerOut
            If(nPosMoe:=aScan(aFilToT,{|x| x[1] == EF1->EF1_MOEDA}) ) == 0
               aAdd(aFilToT,{EF1->EF1_MOEDA,nVlJPAA,nVlJPMM,nVlEJPAA,nVlEJPMM,nVlJACEAA,;
                             nVlJACEMM,nVlEJACEAA,nVlEJACEMM,nVlTACCEAA,nVlTACCEMM,;
                             nVlEACCEAA,nVlEACCEMM,nVlLiquiAA,nVlLiquiMM,nVlELiquiAA,;
                             nVlELiquiMM,})
            Else      
               aFilToT[nPosMoe][02] += nVlJPAA
               aFilToT[nPosMoe][03] += nVlJPMM
               aFilToT[nPosMoe][04] += nVlEJPAA
               aFilToT[nPosMoe][05] += nVlEJPMM     
               aFilToT[nPosMoe][06] += nVlJACEAA
               aFilToT[nPosMoe][07] += nVlJACEMM      
               aFilToT[nPosMoe][08] += nVlEJACEAA
               aFilToT[nPosMoe][09] += nVlEJACEMM      
               aFilToT[nPosMoe][10] += nVlTACCEAA      
               aFilToT[nPosMoe][11] += nVlTACCEMM      
               aFilToT[nPosMoe][12] += nVlEACCEAA
               aFilToT[nPosMoe][13] += nVlEACCEMM      
               aFilToT[nPosMoe][14] += nVlLiquiAA
               aFilToT[nPosMoe][15] += nVlLiquiMM      
               aFilToT[nPosMoe][16] += nVlELiquiAA
               aFilToT[nPosMoe][17] += nVlELiquiMM            
            Endif
         Endif
         //**
      
         IF(nAscan:=ASCAN(aContratos,{|a|a[1]==EF1->EF1_MOEDA}) )==0
            AADD(aContratos,{EF1->EF1_MOEDA,nVlJPAA,nVlJPMM,nVlEJPAA,nVlEJPMM,nVlJACEAA,;
                            nVlJACEMM,nVlEJACEAA,nVlEJACEMM,nVlTACCEAA,nVlTACCEMM,;
                            nVlEACCEAA,nVlEACCEMM,nVlLiquiAA,nVlLiquiMM,nVlELiquiAA,;
                            nVlELiquiMM,})
         ELSE      
            aContratos[nAscan,02]+=nVlJPAA
            aContratos[nAscan,03]+=nVlJPMM
      
            aContratos[nAscan,04]+=nVlEJPAA
            aContratos[nAscan,05]+=nVlEJPMM
      
            aContratos[nAscan,06]+=nVlJACEAA
            aContratos[nAscan,07]+=nVlJACEMM
      
            aContratos[nAscan,08]+=nVlEJACEAA
            aContratos[nAscan,09]+=nVlEJACEMM
         
            aContratos[nAscan,10]+=nVlTACCEAA      
            aContratos[nAscan,11]+=nVlTACCEMM
      
            aContratos[nAscan,12]+=nVlEACCEAA
            aContratos[nAscan,13]+=nVlEACCEMM
      
            aContratos[nAscan,14]+=nVlLiquiAA
            aContratos[nAscan,15]+=nVlLiquiMM
      
            aContratos[nAscan,16]+=nVlELiquiAA
            aContratos[nAscan,17]+=nVlELiquiMM      
      
         ENDIF
   
         nAux:=nLin+3
         //Alcir Alves- 16-02-05 
         If lEFFTpMod // PLB 28/04/06 - Caso exista TPMODU e SEQCNT
              EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT))
              EF2->(DBEVAL({||nAux++},{||.T.},{||EF2->(EF2_FILIAL+EF2_TPMODU+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA+EF2_SEQCNT)==aFiliais[nFil]+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT}))      
         ElseIF lExistBCO
              EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA))
              EF2->(DBEVAL({||nAux++},{||.T.},{||EF2->(EF2_FILIAL+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA)==aFiliais[nFil]+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA}))      
         ELSE
              EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA))
              EF2->(DBEVAL({||nAux++},{||.T.},{||EF2->(EF2_FILIAL+EF2_CONTRA)==aFiliais[nFil]+EF1->EF1_CONTRA}))
         ENDIF
         //        
         IF nAux+nLinRelTot >=nLinTot
           Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
           nLin:=08
         ENDIF  

         //** PLB 28/04/06
         If lEFFTpMod
            If lExistRof
               cParSX1:="mv_par16"
            Else
               cParSX1:="mv_par15"
            EndIf
         Else
            If lExistRof
               cParSX1:="mv_par14"
            Else
               cParSX1:="mv_par13"
            EndIf
         EndIf            
         If &(cParSX1) == 1
         //**
         //IF iif(lExistRof,mv_par14,mv_par13)==1 //caso destino de impressão seja IMPRESSORA  - ALCIR ALVES - 15-02-05
            //Alcir Alves- 06-01-05
            //Begin comm
            IF FilAtu#aFiliais[nFil] .and. !IsEF1C
              if FilAtu#"-"
                 Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
                 nLin:=08
              endif
              @ nLin, 000 PSAY Repli("*", 218)
              nLin++       
              @nLin,0 PSAY __PrtLeft(STR0027+aFiliais[nFil]+" - "+AvgFilName({aFiliais[nFil]})[1]) //"Filial 
              nLin++
              @ nLin, 000 PSAY Repli("*", 218)
              nLin++
              FilAtu:=aFiliais[nFil]                  
            endif
            //endcom
            if (nVlJPAA+nVlJACEAA+nVlELiquiAA+nVlEJPAA+nVlEJACEAA+nVlLiquiAA+nVlEACCEAA+nVlRJPMM+nVlRJACEMM+nVlERLiquiMM+nVlREJPMM+nVlREJACEMM+nVlRLiquiMM+nVlETRCEMM)>0
            @nLin,0  PSAY __PrtFatLine()
            nLin++
            @nLin,0 PSAY __PrtLeft(STR0010+cTipoContrato+": "+EF1->EF1_CONTRA+space(5)+STR0031+EF1->EF1_BAN_FI+"-"+POSICIONE("SA6",1,cfilSA6+EF1->EF1_BAN_FI,"A6_NOME")+IIF(lExistBCO,space(5)+STR0032+EF1->EF1_PRACA,"")+IIF(lEFFTpMod,space(5)+STR0033+EF1->EF1_SEQCNT,"")) //"###"Contrato de " Alcir Alves- 06-01-05    // PLB 28/04/06 - "Sequencia: "#
            //@nLin,0 PSAY __PrtLeft(STR0027+aFiliais[nFil]+" - "+AvgFilName({aFiliais[nFil]})[1]+" "+STR0010+cTipoContrato+":"+EF1->EF1_CONTRA) //"Filial "###"Contrato de "
            nLin++
            @nLin,0 PSAY __PrtFatLine()
            nLin++
   
            @nLin,nCol01 PSAY STR0011+cNomeMoeda+": "+ALLTRIM(TRANS(nVlContrato,cPicture)) //"Valor do Contrato "
            nLin++
            cTexto:=STR0012+AllTrim(IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Tabela("CG",EF1->EF1_TP_FIN,.F.)))+", " //"Taxa(s) de Juro(s):Tipo "
      
      
            //Alcir Alves - 16/02/05
            cWhile:={|| .T. }
            IF !lExistBCO //CASO NÃO EXISTA OS NOVOS CAMPOS EF2_BAN_FI E EF2_PRACA
                EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA))
            ElseIf !lEFFTpMod // PLB 28/04/06 - Caso nao exista TPMODU e SEQCNT
                EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA))
                cWhile:={|| EF2->EF2_BAN_FI==EF1->EF1_BAN_FI .and. EF2->EF2_PRACA==EF1->EF1_PRACA }
            Else
                EF2->(DBSEEK(aFiliais[nFil]+EF1->EF1_TPMODU+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+EF1->EF1_SEQCNT))
                cWhile:={|| EF2->EF2_TPMODU==EF1->EF1_TPMODU .and. EF2->EF2_BAN_FI==EF1->EF1_BAN_FI .and. EF2->EF2_PRACA==EF1->EF1_PRACA .And. EF2->EF2_SEQCNT==EF1->EF1_SEQCNT }
            ENDIF 
            //
            DO WHILE EF2->(!EOF()) .AND. EF2->(EF2_FILIAL+EF2_CONTRA)==aFiliais[nFil]+EF1->EF1_CONTRA .AND. EVAL(cWhile)
               @nLin,nCol01 PSAY IF(lFirst,cTexto,SPACE(LEN(cTexto)))+DTOC(EF2->EF2_DT_INI)+STR0013+DTOC(EF2->EF2_DT_FIM)+; //" ate "
                           STR0014+ALLTRIM(TRANS(EF2->EF2_TX_FIX,cPictTXFIX))+; //",Taxa:"
                           STR0015+Tabela("CI",EF2->EF2_TP_VAR,.F.)+" "+EF2->EF2_TP_VAR+; //",Tipo Tx Variavel:"
                           STR0026+ALLTRIM(TRANS((EF2->EF2_TX_FIX+EF2->EF2_TX_VAR)/360,cPictTXFIX)) //",Taxa Dia:"
               nLin++
               lFirst:=.F.
               EF2->(DBSKIP())
            ENDDO 
   
            nLin++
            lFirst:=.T.
   
            @nLin,nCol02  PSAY STR0007    //"Acumulado Anterior"
            @nLin,nCol03  PSAY STR0008 //"Movimento Mes"
            @nLin,nCol04  PSAY STR0009 //"Acumulado Atual"
            nLin++
      
            @nLin,nCol02a PSAY EF1->EF1_MOEDA
            @nLin,nCol02b PSAY cMoeda
      
            @nLin,nCol03a PSAY EF1->EF1_MOEDA
            @nLin,nCol03b PSAY cMoeda
      
            @nLin,nCol04a PSAY EF1->EF1_MOEDA
            @nLin,nCol04b PSAY cMoeda
            nLin++
   
            @nLin,nCol02c PSAY REPLICATE("_",nLenCampo+3)
            @nLin,nCol02d PSAY REPLICATE("_",nLenCampo+3)
   
            @nLin,nCol03c PSAY REPLICATE("_",nLenCampo+3)
            @nLin,nCol03d PSAY REPLICATE("_",nLenCampo+3)
   
            @nLin,nCol04c PSAY REPLICATE("_",nLenCampo+3)
            @nLin,nCol04d PSAY REPLICATE("_",nLenCampo+3)
            nLin++
   
            @nLin,nCol01  PSAY  STR0016 //"Juros Principal"
            @nLin,nCol02c PSAY TRANS(nVlJPAA,cPicture)
            @nLin,nCol02d PSAY TRANS(nVlRJPAA,cPicture)
                                             
            @nLin,nCol03c PSAY TRANS(nVlJPMM,cPicture)
            @nLin,nCol03d PSAY TRANS(nVlRJPMM,cPicture)
    
            nTotJP :=nVlJPAA+nVlJPMM
            nTotRJP:=nVlRJPAA+nVlRJPMM
   
            @nLin,nCol04c PSAY TRANS(nTotJP,cPicture)
            @nLin,nCol04d PSAY TRANS(nTotRJP,cPicture)
       
            nLin++
            @nLin,nCol01 PSAY STR0017 //"Estorno Juros Principal"
            @nLin,nCol02c PSAY TRANS(nVlEJPAA,cPicture)
            @nLin,nCol02d PSAY TRANS(nVlREJPAA,cPicture)
                                              
            @nLin,nCol03c PSAY TRANS(nVlEJPMM,cPicture)
            @nLin,nCol03d PSAY TRANS(nVlREJPMM,cPicture)
   
            nTotEJP :=nVlEJPAA+nVlEJPMM
            nTotREJP:=nVlREJPAA+nVlREJPMM
   
            @nLin,nCol04c PSAY TRANS(nTotEJP,cPicture)
            @nLin,nCol04d PSAY TRANS(nTotREJP,cPicture)
            nLin++

      //IF EF1->EF1_TP_FIN=="02"
               @nLin,nCol01  PSAY STR0018 //"Juros ACE"
               @nLin,nCol02c PSAY TRANS(nVlJACEAA,cPicture)
               @nLin,nCol02d PSAY TRANS(nVlRJACEAA,cPicture)
                                              
               @nLin,nCol03c PSAY TRANS(nVlJACEMM,cPicture)
               @nLin,nCol03d PSAY TRANS(nVlRJACEMM,cPicture)
      
               nTotJACE :=nVlJACEAA+nVlJACEMM
               nTotRJACE:=nVlRJACEAA+nVlRJACEMM
      
               @nLin,nCol04c PSAY TRANS(nTotJACE,cPicture)
               @nLin,nCol04d PSAY TRANS(nTotRJACE,cPicture)
               nLin++

               @nLin,nCol01  PSAY STR0019 //"Estorno Juros ACE"
               @nLin,nCol02c PSAY TRANS(nVlEJACEAA,cPicture)
               @nLin,nCol02d PSAY TRANS(nVlREJACEAA,cPicture)
                                              
               @nLin,nCol03c PSAY TRANS(nVlEJACEMM,cPicture)
               @nLin,nCol03d PSAY TRANS(nVlREJACEMM,cPicture)
         
               nTotEJACE :=nVlEJACEAA+nVlEJACEMM
               nTotREJACE:=nVlREJACEAA+nVlREJACEMM
      
               @nLin,nCol04c PSAY TRANS(nTotEJACE,cPicture)
               @nLin,nCol04d PSAY TRANS(nTotREJACE,cPicture)
               nLin++
      
               @nLin,nCol01  PSAY STR0020 //"Transf. ACC/ACE"
               @nLin,nCol02c PSAY TRANS(nVlTACCEAA,cPicture)
               @nLin,nCol02d PSAY TRANS(nVlRTACCEAA,cPicture)
                                              
               @nLin,nCol03c PSAY TRANS(nVlTACCEMM,cPicture)
               @nLin,nCol03d PSAY TRANS(nVlRTACCEMM,cPicture)

               nTotTACCE :=nVlTACCEAA+nVlTACCEMM
               nTotRTACCE:=nVlRTACCEAA+nVlRTACCEMM
                                                                    
               @nLin,nCol04c PSAY TRANS(nTotTACCE,cPicture)
               @nLin,nCol04d PSAY TRANS(nTotRTACCE,cPicture)
               nLin++                                    
      
               @nLin,nCol01  PSAY STR0021 //"Estorno Transf. ACC/ACE"
               @nLin,nCol02c PSAY TRANS(nVlEACCEAA,cPicture)
               @nLin,nCol02d PSAY TRANS(nVlERCCEAA,cPicture)
                                              
               @nLin,nCol03c PSAY TRANS(nVlEACCEMM,cPicture)
               @nLin,nCol03d PSAY TRANS(nVlETRCEMM,cPicture)   
      
               nTotERACCE :=nVlEACCEAA+nVlEACCEMM 
               nTotRERACCE:=nVlERCCEAA+nVlETRCEMM
   
               @nLin,nCol04c PSAY TRANS(nTotERACCE,cPicture)
               @nLin,nCol04d PSAY TRANS(nTotRERACCE,cPicture)
               nLin++         
      //ELSE
      //   nVlJACEAA:=nVlJACEMM:=nVlRJACEAA:=nVlRJACEMM:=nVlEJACEAA:=nVlEJACEMM:=0
      //   nVlREJACEAA:=nVlREJACEMM:=nVlTACCEAA:=nVlTACCEMM:=nVlRTACCEAA:=nVlRTACCEMM:=0
      //   nVlEACCEAA:=nVlEACCEMM:=nVlERCCEAA:=nVlETRCEMM:=0
      //ENDIF

            @nLin,nCol01  PSAY STR0022 //"Liquidacao"
            @nLin,nCol02c PSAY TRANS(nVlLiquiAA,cPicture)
            @nLin,nCol02d PSAY TRANS(nVlRLiquiAA,cPicture)
                                              
            @nLin,nCol03c PSAY TRANS(nVlLiquiMM,cPicture)
            @nLin,nCol03d PSAY TRANS(nVlRLiquiMM,cPicture)   
                                                 
            nTotLiqui :=nVlLiquiAA+nVlLiquiMM
            nTotRLiqui:=nVlRLiquiAA+nVlRLiquiMM
   
            @nLin,nCol04c PSAY TRANS(nTotLiqui,cPicture)
            @nLin,nCol04d PSAY TRANS(nTotRLiqui,cPicture)   
            nLin++
   
            @nLin,nCol01  PSAY STR0023 //"Estorno Liquidacao"
            @nLin,nCol02c PSAY TRANS(nVlELiquiAA,cPicture)
            @nLin,nCol02d PSAY TRANS(nVlERLiquiAA,cPicture)
                                              
            @nLin,nCol03c PSAY TRANS(nVlELiquiMM,cPicture)
            @nLin,nCol03d PSAY TRANS(nVlERLiquiMM,cPicture)   
   
            nTotEsLiqui :=nVlELiquiAA+nVlELiquiMM
            nTotREsLiqui:=nVlERLiquiAA+nVlERLiquiMM
   
            @nLin,nCol04c PSAY TRANS(nTotEsLiqui,cPicture)
            @nLin,nCol04d PSAY TRANS(nTotREsLiqui,cPicture)   
            nLin++
   
            @nLin,0       PSAY " " //AAF - 09/08/04 - Pular coluna na impressão em DBF            
            @nLin,nCol02c PSAY REPLICATE("_",nLenCampo+3)
            @nLin,nCol02d PSAY REPLICATE("_",nLenCampo+3)   
   
            @nLin,nCol03c PSAY REPLICATE("_",nLenCampo+3)
            @nLin,nCol03d PSAY REPLICATE("_",nLenCampo+3)   
   
            @nLin,nCol04c PSAY REPLICATE("_",nLenCampo+3)
            @nLin,nCol04d PSAY REPLICATE("_",nLenCampo+3)   
            nLin++
      
            @nLin,nCol01  PSAY STR0024 //"Total"
            nTot1:=(nVlJPAA+nVlJACEAA+nVlELiquiAA)-(nVlEJPAA+nVlEJACEAA+nVlLiquiAA+nVlEACCEAA)  //Total anterior na moeda
            nTot2:=(nVlRJPAA+nVlRJACEAA+nVlERLiquiAA)-(nVlREJPAA+nVlREJACEAA+nVlRLiquiAA+nVlERCCEAA)  //Total anterior em real
            @nLin,nCol02c PSAY TRANS(nTot1 ,cPicture)
            @nLin,nCol02d PSAY TRANS(nTot2 ,cPicture)
  
            nTot3:=(nVlJPMM+nVlJACEMM+nVlELiquiMM)-(nVlEJPMM+nVlEJACEMM+nVlLiquiMM+nVlEACCEMM)  //Total atual na moeda
            nTot4:= (nVlRJPMM+nVlRJACEMM+nVlERLiquiMM)-(nVlREJPMM+nVlREJACEMM+nVlRLiquiMM+nVlETRCEMM)  //Total atual em real
            @nLin,nCol03c PSAY TRANS(nTot3,cPicture)
            @nLin,nCol03d PSAY TRANS(nTot4,cPicture)   
   
            //@nLin,nCol04c PSAY TRANS(nTotEsLiqui+nTotLiqui+nTotERACCE+nTotTACCE+nTotEJACE+nTotJACE+nTotEJP+nTotJP,cPicture)
            //@nLin,nCol04d PSAY TRANS(nTotREsLiqui+nTotRLiqui+nTotRERACCE+nTotRTACCE+nTotREJACE+nTotRJACE+nTotREJP+nTotRJP,cPicture)
   
            @nLin,nCol04c PSAY TRANS(nTot1+nTot3,cPicture)
            @nLin,nCol04d PSAY TRANS(nTot2+nTot4,cPicture)
            nLin++   
   
            (cAliasArq)->(DBSKIP())
            nLin+=04 
            cChave:=aFiliais[nFil] 
            If lVerOut .AND. (cAliasArq)->EF1_FILIAL <> cFilAtu .AND. Len(aFiliais) > 1
             // Alcir Alves - 07-01-05 - conceito multifilial - total filial
              nLin++
              @ nLin, 000 PSAY Repli("-", 132)
              nLin++       
              @nLin,0 PSAY __PrtLeft(STR0030+aFiliais[nFil]+" - "+AvgFilName({aFiliais[nFil]})[1]) //"Total Filial 
              nLin++
              @ nLin, 000 PSAY Repli("-", 132)
              nLin++

               //** AAF 03/01/05 - Total Por Filial
              FOR nInd:=1 TO LEN(aFilToT)

                  IF nLin>nLinTot
                     Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
                     nLin:=08
                  ENDIF

                  SYF->(DBSEEK(cFilSYF+aContratos[nInd,1]))    
                  @nLin,0  PSAY __PrtFatLine()
                  nLin++
                  @nLin,0 PSAY __PrtLeft(STR0028+ALLTRIM(SYF->YF_DESC_SI)+"("+ALLTRIM(aContratos[nInd,1])+")") //"Total da Filial em "
                  nLin++
                  @nLin,0 PSAY __PrtFatLine()
                  nLin+=2   

                  @nLin,nTit01T  PSAY RTrim(SYF->YF_DESC_SI)+"("+aContratos[nInd,1]+")"
                  @nLin,nTit02T  PSAY STR0007 //"Acumulado Anterior"
                  @nLin,nTit03T  PSAY STR0025 //"Movimento Mes "
                  @nLin,nTit04T  PSAY STR0009 //"Acumulado Atual"
                  nLin++
   
                  @nLin,nCol01T PSAY STR0016 //"Juros Principal"
                  @nLin,nCol02T PSAY TRANS(aContratos[nInd,02],cPicture)
                  @nLin,nCol03T PSAY TRANS(aContratos[nInd,03],cPicture)
                  @nLin,nCol04T PSAY TRANS(aContratos[nInd,02]+aContratos[nInd,03],cPicture)
                  nLin++
           nTotGeral+=aContratos[nInd,02]+aContratos[nInd,03]
   
                  @nLin,nCol01T PSAY STR0017 //"Estorno Juros Principal"
                  @nLin,nCol02T PSAY TRANS(aContratos[nInd,04],cPicture) 
                  @nLin,nCol03T PSAY TRANS(aContratos[nInd,05],cPicture)
                  @nLin,nCol04T PSAY TRANS(aContratos[nInd,04]+aContratos[nInd,05],cPicture)
                  nLin++
                  nTotGeral:=0
   
                  @nLin,nCol01T PSAY STR0018 //"Juros ACE"
                  @nLin,nCol02T PSAY TRANS(aContratos[nInd,06],cPicture)
                  @nLin,nCol03T PSAY TRANS(aContratos[nInd,07],cPicture)
                  @nLin,nCol04T PSAY TRANS(aContratos[nInd,06]+aContratos[nInd,07],cPicture)
                  nLin++      
                  nTotGeral+=aContratos[nInd,06]+aContratos[nInd,07]
      
                  @nLin,nCol01T PSAY STR0019    //"Estorno Juros ACE"
                  @nLin,nCol02T PSAY TRANS(aContratos[nInd,08],cPicture)
                  @nLin,nCol03T PSAY TRANS(aContratos[nInd,09],cPicture)
                  @nLin,nCol04T PSAY TRANS(aContratos[nInd,08]+aContratos[nInd,09],cPicture)
                  nLin++      
                  nTotGeral+=aContratos[nInd,08]+aContratos[nInd,09]
   
                  @nLin,nCol01T PSAY STR0020 //"Transf. ACC/ACE"
                  @nLin,nCol02T PSAY TRANS(aContratos[nInd,10],cPicture)
                  @nLin,nCol03T PSAY TRANS(aContratos[nInd,11],cPicture)
                  @nLin,nCol04T PSAY TRANS(aContratos[nInd,10]+aContratos[nInd,11],cPicture)
                  nLin++                                    
                  nTotGeral+=aContratos[nInd,10]+aContratos[nInd,11]
      
                  @nLin,nCol01T PSAY STR0021 //"Estorno Transf. ACC/ACE"
                  @nLin,nCol02T PSAY TRANS(aContratos[nInd,12],cPicture)
                  @nLin,nCol03T PSAY TRANS(aContratos[nInd,13],cPicture)
                  @nLin,nCol04T PSAY TRANS(aContratos[nInd,12]+aContratos[nInd,13],cPicture)
                  nLin++
                  nTotGeral+=aContratos[nInd,12]+aContratos[nInd,13]
  
                  IF nLin>nLinTot
                     Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
                     nLin:=08
                  ENDIF
  
                  @nLin,nCol01T PSAY STR0022 //"Liquidacao"
                  @nLin,nCol02T PSAY TRANS(aContratos[nInd,14],cPicture)
                  @nLin,nCol03T PSAY TRANS(aContratos[nInd,15],cPicture)
                  @nLin,nCol04T PSAY TRANS(aContratos[nInd,14]+aContratos[nInd,15],cPicture)
                  nLin++
                  nTotGeral+=aContratos[nInd,14]+aContratos[nInd,15]
   
                  @nLin,nCol01T PSAY STR0023 //"Estorno Liquidacao"
                  @nLin,nCol02T PSAY TRANS(aContratos[nInd,16],cPicture)
                  @nLin,nCol03T PSAY TRANS(aContratos[nInd,17],cPicture)
                  @nLin,nCol04T PSAY TRANS(aContratos[nInd,16]+aContratos[nInd,17],cPicture)   
                  nLin++
                  nTotGeral+=aContratos[nInd,16]+aContratos[nInd,17]
   
                  @nLin,nCol02T PSAY REPLICATE("_",nLenCampo+3)   
                  @nLin,nCol03T PSAY REPLICATE("_",nLenCampo+3)   
                  @nLin,nCol04T PSAY REPLICATE("_",nLenCampo+3)

                  nLin++   
   
                  @nLin,nCol01T PSAY STR0024 //"Total"
                  @nLin,nCol02T PSAY TRANS( (aContratos[nInd,02]+aContratos[nInd,06])-(aContratos[nInd,04]+aContratos[nInd,08]+aContratos[nInd,14]),cPicture)
                  @nLin,nCol03T PSAY TRANS( (aContratos[nInd,03]+aContratos[nInd,07])-(aContratos[nInd,05]+aContratos[nInd,09]+aContratos[nInd,15]),cPicture)
                  @nLin,nCol04T PSAY TRANS(nTotGeral,cPicture)
                  nLin++      
               
                  IF nLin>nLinTot
                     Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
                     nLin:=08
                  ENDIF
               Next nInd
               nVlRJPAA:=nVlRJPMM:=nVlREJPAA:=nVlREJPMM:=nVlRJACEAA:=nVlRJACEMM:=0
               nVlREJACEAA:=nVlREJACEMM:=nVlRTACCEAA:=nVlRTACCEMM:=nVlERCCEAA:=nVlETRCEMM:=0
               nVlRLiquiAA:=nVlRLiquiMM:=nVlERLiquiAA:=nVlERLiquiMM:=0
         
               aFilToT := {{cMoeda,nVlRJPAA,nVlRJPMM,nVlREJPAA,nVlREJPMM,nVlRJACEAA,nVlRJACEMM,;
                         nVlREJACEAA,nVlREJACEMM,nVlRTACCEAA,nVlRTACCEMM,nVlERCCEAA,nVlETRCEMM,;
                            nVlRLiquiAA,nVlRLiquiMM,nVlERLiquiAA,nVlERLiquiMM}}
         
               cFilAtu := EF1_FILIAL
            Endif
            else
                (cAliasArq)->(DBSKIP())
            Endif
         ELSE
         
            WORK->(RECLOCK("WORK",.T.))
            WORK->FILIAL     := aFiliais[nFil]
            WORK->CONTRATO   := EF1->EF1_CONTRA
            //** PLB 28/04/06
            If lEFFTpMod
               WORK->TPMODU     := EF1->EF1_TPMODU
               WORK->SEQCNT     := EF1->EF1_SEQCNT
            EndIf
            //**
            WORK->TIPO_CONTR := cTipoContrato
            WORK->BANCO_OP   := EF1->EF1_BAN_FI
            IF lExistBCO
                WORK->PRACA := EF1->EF1_PRACA
            ENDIF
            WORK->MOEDA:=cNomeMoeda
            WORK->VALOR_MOE:=nVlContrato
            WORK->JUROP_MOE1:=nVlJPAA
            WORK->JUROP_MOE2:=nVlJPMM
            WORK->JUROP_MOE3:=(nVlJPAA+nVlJPMM)
            WORK->ESTJP_MOE1:=nVlEJPAA
            WORK->ESTJP_MOE2:=nVlEJPMM
            WORK->ESTJP_MOE3:=(nVlEJPAA+nVlEJPMM)
            WORK->JACE_MOE1:=nVlJACEAA
            WORK->JACE_MOE2:=nVlJACEMM
            WORK->JACE_MOE3:=(nVlJACEAA+nVlJACEMM)
            WORK->EACE_MOE1:=nVlEJACEAA
            WORK->EACE_MOE2:=nVlEJACEMM
            WORK->EACE_MOE3:=(nVlEJACEAA+nVlEJACEMM)
            WORK->ACECC_MOE1:=nVlTACCEAA
            WORK->ACECC_MOE2:=nVlTACCEMM
            WORK->ACECC_MOE3:=(nVlTACCEAA+nVlTACCEMM)
            WORK->EACEC_MOE1:=nVlEACCEAA
            WORK->EACEC_MOE2:=nVlEACCEMM
            WORK->EACEC_MOE3:=(nVlEACCEAA+nVlEACCEMM )
            WORK->LIQ_MOE1:=nVlLiquiAA
            WORK->LIQ_MOE2:=nVlLiquiMM
            WORK->LIQ_MOE3:=(nVlLiquiAA+nVlLiquiMM)
            WORK->ELIQ_MOE1:=nVlELiquiAA
            WORK->ELIQ_MOE2:=nVlELiquiMM
            WORK->ELIQ_MOE3:=(nVlELiquiAA+nVlELiquiMM)

            WORK->JUROP_REA1:=nVlRJPAA
            WORK->JUROP_REA2:=nVlRJPMM
            WORK->JUROP_REA3:=(nVlRJPAA+nVlRJPMM)
            WORK->ESTJP_REA1:=nVlREJPAA
            WORK->ESTJP_REA2:=nVlREJPMM
            WORK->ESTJP_REA3:=(nVlREJPAA+nVlREJPMM)
            WORK->JACE_REA1:=nVlRJACEAA
            WORK->JACE_REA2:=nVlRJACEMM
            WORK->JACE_REA3:=(nVlRJACEAA+nVlRJACEMM)
            WORK->EACE_REA1:=nVlREJACEAA
            WORK->EACE_REA2:=nVlREJACEMM
            WORK->EACE_REA3:=(nVlREJACEAA+nVlREJACEMM)
            WORK->ACECC_REA1:=nVlRTACCEAA
            WORK->ACECC_REA2:=nVlRTACCEMM
            WORK->ACECC_REA3:=(nVlRTACCEAA+nVlRTACCEMM)
            WORK->EACEC_REA1:=nVlERCCEAA
            WORK->EACEC_REA2:=nVlETRCEMM
            WORK->EACEC_REA3:=(nVlERCCEAA+nVlETRCEMM)
            WORK->LIQ_REA1:=nVlRLiquiAA
            WORK->LIQ_REA2:=nVlRLiquiMM
            WORK->LIQ_REA3:=(nVlRLiquiAA+nVlRLiquiMM)
            WORK->ELIQ_REA1:=nVlERLiquiAA
            WORK->ELIQ_REA2:=nVlERLiquiMM
            WORK->ELIQ_REA3:=(nVlERLiquiAA+nVlERLiquiMM)
            WORK->(MSUNLOCK())
            //(cAliasArq)->(DBSKIP())
            (cAliasArq)->(DBSKIP())
         ENDIF
      ENDDO
   Next nFil
   //** PLB 28/04/06
   If !lTotal
      MsgInfo("Nao existem dados a serem impressos.")  // "Nao existem dados a serem impressos.
      Return .F.
   EndIf

   If lEFFTpMod
      If lExistRof
         cParSX1:="mv_par16"
      Else
         cParSX1:="mv_par15"
      EndIf
   Else
      If lExistRof
         cParSX1:="mv_par14"
      Else
         cParSX1:="mv_par13"
      EndIf
   EndIf            
   If &(cParSX1) == 1
   //**
   //IF iif(lExistRof,mv_par14,mv_par13)==1 //caso destino de impressão seja IMPRESSORA  - ALCIR ALVES - 16-02-05
      if nLin>9
         nLin:=99  
      endif
      If lTotal
         FOR nInd:=1 TO LEN(aContratos)
            IF nLin>nLinTot
               Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
               nLin:=08
            ENDIF
            SYF->(DBSEEK(cFilSYF+aContratos[nInd,1]))    
            @nLin,0  PSAY __PrtFatLine()
            nLin++
            @nLin,0 PSAY __PrtLeft(STR0029+" "+ALLTRIM(SYF->YF_DESC_SI)+"("+ALLTRIM(aContratos[nInd,1])+")") //"Total Geral"
            nLin++
            @nLin,0 PSAY __PrtFatLine()
            nLin+=2   

            @nLin,nTit01T  PSAY RTrim(SYF->YF_DESC_SI)+"("+aContratos[nInd,1]+")"
            @nLin,nTit02T  PSAY STR0007 //"Acumulado Anterior"
            @nLin,nTit03T  PSAY STR0025 //"Movimento Mes "
            @nLin,nTit04T  PSAY STR0009 //"Acumulado Atual"
            nLin++
   
            @nLin,nCol01T PSAY STR0016 //"Juros Principal"
            @nLin,nCol02T PSAY TRANS(aContratos[nInd,02],cPicture)
            @nLin,nCol03T PSAY TRANS(aContratos[nInd,03],cPicture)
            @nLin,nCol04T PSAY TRANS(aContratos[nInd,02]+aContratos[nInd,03],cPicture)
            nLin++
   
            @nLin,nCol01T PSAY STR0017 //"Estorno Juros Principal"
            @nLin,nCol02T PSAY TRANS(aContratos[nInd,04],cPicture) 
            @nLin,nCol03T PSAY TRANS(aContratos[nInd,05],cPicture)
            @nLin,nCol04T PSAY TRANS(aContratos[nInd,04]+aContratos[nInd,05],cPicture)
            nLin++
            nTotGeral:=0
   
            IF nLin>nLinTot
               Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
               nLin:=08
            ENDIF
   
            IF EF1->EF1_TP_FIN=="01"
               @nLin,nCol01T PSAY STR0018 //"Juros ACE"
               @nLin,nCol02T PSAY TRANS(aContratos[nInd,06],cPicture)
               @nLin,nCol03T PSAY TRANS(aContratos[nInd,07],cPicture)
               @nLin,nCol04T PSAY TRANS(aContratos[nInd,06]+aContratos[nInd,07],cPicture)
               nLin++      
               nTotGeral+=aContratos[nInd,06]+aContratos[nInd,07]
      
               @nLin,nCol01T PSAY STR0019    //"Estorno Juros ACE"
               @nLin,nCol02T PSAY TRANS(aContratos[nInd,08],cPicture)
               @nLin,nCol03T PSAY TRANS(aContratos[nInd,09],cPicture)
               @nLin,nCol04T PSAY TRANS(aContratos[nInd,08]+aContratos[nInd,09],cPicture)
               nLin++      
               nTotGeral+=aContratos[nInd,08]+aContratos[nInd,09]
   
               @nLin,nCol01T PSAY STR0020 //"Transf. ACC/ACE"
               @nLin,nCol02T PSAY TRANS(aContratos[nInd,10],cPicture)
               @nLin,nCol03T PSAY TRANS(aContratos[nInd,11],cPicture)
               @nLin,nCol04T PSAY TRANS(aContratos[nInd,10]+aContratos[nInd,11],cPicture)
               nLin++                                    
               nTotGeral+=aContratos[nInd,10]+aContratos[nInd,11]
      
               @nLin,nCol01T PSAY STR0021 //"Estorno Transf. ACC/ACE"
               @nLin,nCol02T PSAY TRANS(aContratos[nInd,12],cPicture)
               @nLin,nCol03T PSAY TRANS(aContratos[nInd,13],cPicture)
               @nLin,nCol04T PSAY TRANS(aContratos[nInd,12]+aContratos[nInd,13],cPicture)
               nLin++
               nTotGeral+=aContratos[nInd,12]+aContratos[nInd,13]
            ELSE
               aContratos[nInd,06]:=aContratos[nInd,07]:=0
               aContratos[nInd,08]:=aContratos[nInd,09]:=0
               aContratos[nInd,10]:=aContratos[nInd,11]:=0
               aContratos[nInd,12]:=aContratos[nInd,13]:=0
            ENDIF
  
            @nLin,nCol01T PSAY STR0022 //"Liquidacao"
            @nLin,nCol02T PSAY TRANS(aContratos[nInd,14],cPicture)
            @nLin,nCol03T PSAY TRANS(aContratos[nInd,15],cPicture)
            @nLin,nCol04T PSAY TRANS(aContratos[nInd,14]+aContratos[nInd,15],cPicture)
            nLin++
            nTotGeral+=aContratos[nInd,14]+aContratos[nInd,15]
   
            @nLin,nCol01T PSAY STR0023 //"Estorno Liquidacao"
            @nLin,nCol02T PSAY TRANS(aContratos[nInd,16],cPicture)
            @nLin,nCol03T PSAY TRANS(aContratos[nInd,17],cPicture)
            @nLin,nCol04T PSAY TRANS(aContratos[nInd,16]+aContratos[nInd,17],cPicture)   
            nLin++
            nTotGeral+=aContratos[nInd,16]+aContratos[nInd,17]
   
            @nLin,nCol02T PSAY REPLICATE("_",nLenCampo+3)   
            @nLin,nCol03T PSAY REPLICATE("_",nLenCampo+3)   
            @nLin,nCol04T PSAY REPLICATE("_",nLenCampo+3)

            nLin++   
   
            @nLin,nCol01T PSAY STR0024 //"Total"
            @nLin,nCol02T PSAY TRANS( (aContratos[nInd,02]+aContratos[nInd,06])-(aContratos[nInd,04]+aContratos[nInd,08]+aContratos[nInd,14]),cPicture)
            @nLin,nCol03T PSAY TRANS( (aContratos[nInd,03]+aContratos[nInd,07])-(aContratos[nInd,05]+aContratos[nInd,09]+aContratos[nInd,15]),cPicture)
            @nLin,nCol04T PSAY TRANS(nTotGeral,cPicture)
    
            nLin++      
   
            IF nLin>nLinTot
               Cabec(titulo,cabec1,cabec2+IIF(lEFFTpMod,cTipoModu,""),wnrel,Tamanho,nTipo)   	
               nLin:=08
            ENDIF
         NEXT    
      Endif
   ENDIF
Next nTpModu
If &(cParSX1) == 1
   Set Printer To
   Commit	
   Ourspool(wnrel)
   MS_FLUSH()
EndIf

//** PLB 28/04/06
If lEFFTpMod
   If lExistRof
      cParSX1:="mv_par16"
   Else
      cParSX1:="mv_par15"
   EndIf
Else
   If lExistRof
      cParSX1:="mv_par14"
   Else
      cParSX1:="mv_par13"
   EndIf
EndIf            
If &(cPArSX1) == 2  .Or.  &(cParSX1) == 3
//**
//ALCIR ALVES - 16-02-05 - EXPORTAÇÃO PARA EXCEL OU TEXTO
//IF iif(lExistRof,mv_par14,mv_par13)==2 .or. iif(lExistRof,mv_par14,mv_par13)==3 //caso destino de impressão seja texto ou excel
   WORK_EXPORT(IIF(&(cParSX1)==2,.F.,.T.))
ENDIF

RETURN .T.             

*-------------------------------*
FUNCTION PJ160QUERY(cTipo)
*-------------------------------*
LOCAL cAliasQuery:=cTipo+"NEW"

If Select(cAliasQuery) <> 0
   (cAliasQuery)->(DbCloseArea())
Endif

IF Left(cTipo,3)=="EF1"
   cQuery:=" SELECT "+IIF(lEFFTpMod,"EF1.EF1_TPMODU, ","")+"EF1.EF1_FILIAL,EF1.EF1_CONTRA,EF1.R_E_C_N_O_ REGISTRO FROM " + RetSQLName("EF1") + " EF1 "
   cQuery+=" WHERE EF1.EF1_FILIAL IN ("+cFiliais+") AND EF1.D_E_L_E_T_<>'*' "
   cQuery+=" AND (EF1.EF1_DT_ENC = '"+space(8)+"' OR  EF1.EF1_DT_ENC = '') "
   If lEFFTpMod
      cQuery+=" AND EF1.EF1_TPMODU = '"+IIF(cTipo=="EF1EXP","E","I")+"' "
   EndIf

   IF !EMPTY(cContrato)
      cQuery+=" AND EF1.EF1_CONTRA='"+cContrato+"'"
   ENDIF
   
   //AAF 30/12/04 - Multifiliais
   If lVerOut
      cQuery+=" ORDER BY EF1.EF1_FILIAL,EF1.EF1_CONTRA "
   Endif
   //**
	
ENDIF                         

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS (cAliasQuery) NEW

RETURN


*// Função responsavel pela exportação de works para excel ou arquivo de texto
*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
*---------------------------------------------------------------------------------------

//CCH - 05/03/2009
              //Condição para adequação a exportação utilizando Ctree*/
   cArqOrigem := WorkFile
   cAlias     := "Work"
   lXml       := .F.   
   
   AvExcel(cArqOrigem,cAlias,lXml)

/*   Local oExcelApp
   Local cDirDocs := MsDocPath()
   Local cPath	:= AllTrim(GetTempPath())
   DbSelectArea("Work")
   if lExcel
         Work->(dbCloseArea())
         CpyS2T(".\"+curdir()+WorkFile+".DBF",cPath, .T. )
         If ! ApOleClient( 'MsExcel' )
            MsgStop("Ms-Excel não instalado.")  
            RETURN .F.
         Else
            oExcelApp:= MsExcel():New()
            oExcelApp:WorkBooks:Open( cPath+WorkFile+".dbf" )
            oExcelApp:SetVisible(.T.)
         EndIf
   Else
         TR350ARQUIVO("work")   
         Work->(dbCloseArea())
   EndIf*/
Return .T.
