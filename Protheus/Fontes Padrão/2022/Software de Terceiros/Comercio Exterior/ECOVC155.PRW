#INCLUDE "Ecovc155.ch"
#include "Average.ch"
#include "AvPrint.ch"


#define TOTREGUA 500

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOVC155 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 26.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Saldo dos Fornecedores                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------*
Function ECOVC15A
*----------------*
ECOVC155('1')
Return .T.

*----------------*
Function ECOVC15B
*----------------*
//ECOVC155('2')
ECOVC156()
Return .T.

*------------------------*
Function ECOVC155(cParam)
*------------------------*

LOCAL aWork_Stru := {{"WKFORN"    ,"C", AVSX3("A2_COD",AV_TAMANHO),0 } ,{"WKNOM_RED" ,"C", 20,0 },;
                     {"WKCC"      ,"C", 10,0 } ,{"WKHOUSE"   ,"C", AVSX3("W7_HAWB",AV_TAMANHO),0 },;
                     {"WKINVOICE" ,"C", AVSX3("W7_INVOICE",AV_TAMANHO),0 } ,{"WKFOB"     ,"N", 15,2 },;
                     {"WKSAL_ANT" ,"N", 15,2 } ,{"WKENTRADA" ,"N", 15,2 },;
                     {"WKVARIACAO","N", 15,2 } ,{"WKSALDO"   ,"N", 15,2 },;
                     {"WKCONTA"   ,"C", 15,0 } ,{"WKMOEDA"   ,"C", 03,0 },;
                     {"WKDATA"    ,"D", 08,0 } ,{"WKVAR_A"   ,"N", 15,2 }}
Local nOldArea := "SX3"

Private cFilEC5:=xFilial('EC5'),cFilEC8:=xFilial('EC8'),cFilEC9:=xFilial('EC9'),cFilSA2:=xFilial('SA2')
Private cFilEC2:=xFilial('EC2'),nParam:=Val(cParam)
PRIVATE nSAL_ANT  := nENTRADA  := nACERTO  := nSAIDA  := nVARIACAO := nVAR_A := nFOB_TOT :=0
PRIVATE nGSAL_ANT := nGFOB_TOT := nGENTRADA:= nGACERTO:= nGSAIDA   := nGVARIACAO := nGSALDO  := nGVAR_A := 0
PRIVATE nSSAL_ANT := nSFOB_TOT := nSENTRADA := nSACERTO := nSSAIDA  := nSVARIACAO := nSSALDO := nSVAR_A := 0
PRIVATE nCCSaldo  := nCCFOB_TOT := nCCENTRADA := nCCSAL_ANT := nCCSAIDA := nCCVARIACAO:= nCCVAR_A := nCCSALDO := 0
PRIVATE nMoeSaldo := nMoeFob_Tot := nMoeSALDO := nMoeSAL_ANT := nMoeENTRADA := nMoeACERTO := nMoeVARIACAO:= nMoeVAR_A:= nMoeSAIDA :=0
PRIVATE nTMoeSaldo :=  nTMoeVariacao :=  nTMoeVar_A := 0, lImp_Det := .F., cTit, lTop

Private cForn, cCcont, dTinicial, nTotEC5
Private dTfinal, cTipo_Rel, nOpca, oProcess

IF EasyEntryPoint("ECOSLFOR1")
   ExecBlock("ECOSLFOR1",.F.,.F.,"ABRIR_ARQUIVOS")
ENDIF

cNomArq := E_CriaTrab(, aWork_Stru, "Work")

IF ! USED()
   E_Msg(STR0001,20) //"N„o ha area disponivel para abertura do arquivo temporario."
   RETURN .F.
ENDIF

IndRegua("Work",cNomArq+TEOrdBagExt(),"WKFORN+WKMOEDA+WKCC",;
"AllwaysTrue()",;
"AllwaysTrue()",;
STR0002) //"Processando Arquivo Temporario..."

cNomInd2:=E_Create(aWork_Stru,.F.)
IndRegua("Work",cNomInd2+TEOrdBagExt(),"WKCONTA+WKMOEDA+WKCC",;
"AllwaysTrue()",;
"AllwaysTrue()",;
STR0002) //"Processando Arquivo Temporario..."

cNomInd3:=E_Create(aWork_Stru,.F.)
IndRegua("Work",cNomInd3+TEOrdBagExt(),"WKCC+WKHOUSE+DTOS(WKDATA)",;
"AllwaysTrue()",;
"AllwaysTrue()",;
STR0002) //"Processando Arquivo Temporario..."

SET INDEX TO (cNomArq+TEOrdBagExt()),(cNomInd2+TEOrdBagExt()),(cNomInd3+TEOrdBagExt())
SA2->(DBSETORDER(1))
EC5->(DBSETORDER(2))

#IFDEF TOP
   lTop := .T.
#ENDIF

If nParam = 1
   cTit:=(STR0003) //"Saldo de Fornecedores"
Endif

DO WHILE .T.

   cForn     := SPACE(6)
   cCcont    := SPACE(15)
   dTinicial := AVCTOD("  /  /  ")
   dTfinal   := AVCTOD("  /  /  ")
   nOpca     := 1
   Work->(avzap())
    
   DBSelectArea("WORK")
   If !Pergunte("ECOVC5",.T.)
      Exit
   EndIf

   cForn     := mv_par01
   cCcont    := mv_par02
   dTinicial := mv_par03
   dTfinal   := mv_par04
   cTipo_Rel := mv_par05

   If !E_PERIODO_OK(@dTinicial,@dTfinal)
      Loop
   Endif
   
   If nOpca==1
      If nParam = 1
         cTipo_Rel := STR(cTipo_Rel,1)
      EndIf

      cAnoMesEnc = STRZERO(YEAR(DTINICIAL),4,0) + STRZERO(MONTH(DTINICIAL),2,0)

      IF EMPTY(ALLTRIM(cFORN))
         EC5->(DBSEEK(cFilEC5))
      ELSE
         EC5->(DBSEEK(cFilEC5+cFORN,.T.))
         IF EC5->EC5_FORN # cFORN .OR. EC5->(EOF())
            E_Msg(STR0012,1) //"N„o exitem registros neste intervalo de datas."
            LOOP
         ENDIF
      ENDIF

      Work->(DBSETORDER((Val(cTipo_Rel))))
      
      ContaReg()
      oProcess:=  MsNewProcess():New({|lEnd| VC155GrWork(@lEnd) },STR0066,STR0053,.T.) //"Contábil"###"Gerando Relatório"
      oProcess:Activate()

      LOOP
   EndIf
   
   If nOpcA == 0
      Exit
   Endif

ENDDO

EC5->(DBSETORDER(2))
Work->(E_EraseArq(cNomArq))

IF EasyEntryPoint("ECOSLFOR1")
   ExecBlock("ECOSLFOR1",.F.,.F.,"FECHA_ARQUIVOS")
ENDIF

// PLB 13/04/06 - Work já foi apagada anteriormente
//Work->(CloseArea())

DBSELECTAREA(nOldArea)

Return .T.

*--------------------------*
FUNCTION VC155GrWork(lEnd)
*--------------------------*
LOCAL nRecEC5:=EC5->(RECNO())
PRIVATE XIdentCT
EC2->(DBSETORDER(1))
EC8->(DBSETORDER(2))

//ProcRegua(TOTREGUA)
//IncProc(STR0014) //"Gerando Arq. Tempor rio."

cFORN_ANT = SPACE(6)
cINV_ANT  = SPACE(15)
lImp_Det  :=.F.

EC5->(DBGOTO(nRecEC5))

oProcess:SetRegua1(2)
oProcess:IncRegua1(STR0054) //"Lendo Arquivos 1 / 2 Invoices Contábeis"

oProcess:SetRegua2(nTotEC5)

DO WHILE ! EC5->(EOF()) .AND. EC5->EC5_FILIAL==cFilEC5

   //IF nCont < TOTREGUA-10
   //   IncProc()
   //   nCont ++
   //Else

   //Endif

   If lEnd
      If lEnd:=MsgYesNo(STR0055,STR0056) //"Tem certeza que deseja cancelar?"###"Atenção"
         MS_FLUSH()
         Return .F.
      EndIf
   EndIf

   EC8->(DBSEEK(cFilEC8+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
   EC2->(DBSEEK(cFilEC2+EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC))

   IF EC2->EC2_TX_DI # 0 .AND. cTipo_Rel = "3"
      EC5->(DBSKIP())
      LOOP
   ENDIF

   EC9->(DBSETORDER(1))
   IF !EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF ! EMPTY(ALLTRIM(EC5->EC5_VCFANO+EC5->EC5_VCFMES))
      IF EC5->EC5_VCFANO+EC5->EC5_VCFMES <= cAnoMesEnc
         EC5->(DBSKIP())
         LOOP
      ENDIF
   ENDIF

   IF EC5->EC5_AMOS $ cSim
      EC5->(DBSKIP())
      LOOP
   ENDIF

   IF ! EMPTY(ALLTRIM(cFORN)) .AND. EC5->EC5_FORN # cFORN
      EXIT
   ENDIF

   SA2->(DBSEEK(cFilSA2+EC5->EC5_FORN))

   IF ! EMPTY(ALLTRIM(cCCONT)) .AND. SA2->A2_CONTAB # cCCONT
      EC5->(DBSKIP())
      LOOP
   ENDIF

   oProcess:IncRegua2(STR0057+Alltrim(EC5->EC5_INVOIC)) //"1 / 1 Invoice "

   VCF155CALCULA()

   IF ! lImp_Det
      EC5->(DBSKIP())
      LOOP
   ENDIF
   
   XIdentCT:=EC5->EC5_IDENTC

   IF EasyEntryPoint("ECOSLFOR1")
      ExecBlock("ECOSLFOR1",.F.,.F.,"GRAVA_WORK_1")
   ENDIF
   Work->(DBAPPEND())
   Work->WKFORN    := EC5->EC5_FORN
   Work->WKCC      := XIdentCT
   Work->WKINVOICE := EC5->EC5_INVOIC
   Work->WKMOEDA   := EC5->EC5_MOE_FO
   Work->WKCONTA   := SA2->A2_CONTAB
   Work->WKNOM_RED := SA2->A2_NREDUZ
   Work->WKHOUSE   := EC8->EC8_HAWB
   Work->WKDATA    := IF(nParam = 1,EC5->EC5_DT_EMI,EC2->EC2_DT)

   Work->WKSAL_ANT := nSAL_ANT
   Work->WKVARIACAO:= nVARIACAO
   Work->WKVAR_A   := nVAR_A
   Work->WKFOB     := nFOB_TOT
   Work->WKENTRADA := nENTRADA+nACERTO
   Work->WKSALDO   := nSAL_ANT + nENTRADA + nACERTO + nVARIACAO + nVAR_A - nSAIDA
   EC5->(DBSKIP())
   lImp_Det:=.F.

ENDDO

/*
FOR I:=nCont To TOTREGUA
   IncProc()
Next
*/

IF (Work->(EOF()) .AND. Work->(BOF()))
   E_MSG(STR0015,1) //"N„o existe dados neste per¡odo."
   Return .F.
ENDIF

IF EasyEntryPoint("ECOSLFOR1")
   ExecBlock("ECOSLFOR1",.F.,.F.,"GERAARQ")
ENDIF
VCF155Imprime(lEnd)

Return .T.

*-----------------------*
FUNCTION VCF155Calcula()
*-----------------------*
LOCAL nSai_Moe := 0

nSAL_ANT := 0
VCF155ACUM_SALANT()

IF EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC # EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC .OR. EC9->EC9_FILIAL#cFilEC9
   EC9->(DBSKIP(-1))
ENDIF

nENTRADA  := nACERTO := nSAIDA := nVARIACAO := nVAR_A := 0

MAntes_di  := .T.
DO WHILE ! EC9->(EOF()) .AND. EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC = EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC .AND. EC9->EC9_FILIAL=cFilEC9

   IF EC9->EC9_DT_LAN >= dTINICIAL .AND. EC9->EC9_DT_LAN <= dTFINAL

      IF EC9->EC9_ID_CAM = "101"
         nENTRADA  = nENTRADA  + VCF155_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
      ENDIF

      IF EC9->EC9_ID_CAM = "201"
         nACERTO  = nACERTO + VCF155_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         MAntes_di  := .F.
      ENDIF

      IF SUBSTR(EC9->EC9_ID_CAM,1,1) = "6"
         nSAIDA  = nSAIDA + VCF155_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         nSai_Moe += EC9->EC9_VL_MOE
      ENDIF

      IF EC9->EC9_ID_CAM $ "506/507"
         nVAR_A  = nVAR_A + VCF155_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
      ENDIF

      IF EC9->EC9_ID_CAM $ "501/504/502/503/505"
         IF  MAntes_di
             nVARIACAO  = nVARIACAO + VCF155_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         ELSE
             nVAR_A  = nVAR_A + VCF155_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
         ENDIF
      ENDIF
   ENDIF

   EC9->(DBSKIP())

   IF DTOS(EC9->EC9_DT_LAN) > DTOS(dTFINAL)
      EXIT
   ENDIF
ENDDO

nFOB_TOT := EC5->EC5_FOB_TOT - IF(nParam # 1,0, nSai_Moe )
MWKSALDO  := nSAL_ANT + nENTRADA + nACERTO + nVARIACAO + nVAR_A - nSAIDA

IF VAL(STR(MWKSALDO,15,2)) < 0.10 .AND. VAL(STR(MWKSALDO,15,2)) > -0.10
   RETURN ""
ENDIF

lImp_Det = .T.

RETURN ""

*----------------------------------*
FUNCTION VCF155_Real(PValor,PData)
*----------------------------------*

LOCAL MMes,MAno,MRetorno

MMes = MONTH(dTINICIAL)
MAno = YEAR(dTINICIAL)

IF ( MMes >= 7 .AND. MAno = 1994 ) .OR. MAno >= 1995
   IF PData < AVCTOD("01/07/94")
      MRetorno = PValor / 2750
   ELSE
      MRetorno = PValor
   ENDIF
ELSE
   MRetorno = PValor
ENDIF

RETURN MRetorno

*------------------------*
FUNCTION VCF155ACUM_SALANT
*------------------------*
LOCAL nRec := EC9->(RECNO())
DO WHILE !EC9->(EOF()) .AND. EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC = EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC .AND. EC9->EC9_FILIAL=cFilEC9
   IF EC9->EC9_DT_LAN >= dTINICIAL
      EXIT
   ENDIF

   IF EC9->EC9_ID_CAM $ "101/201/501/502/503/504/505/506/507/701/702"
      nSAL_ANT = nSAL_ANT + VCF155_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
   ELSE
      nSAL_ANT = nSAL_ANT - VCF155_Real(EC9->EC9_VALOR,EC9->EC9_DT_LAN)
   ENDIF

   EC9->(DBSKIP())

ENDDO

EC9->(DBGOTO(nRec))
RETURN ""

*----------------------------*
Function VCF155Imprime(lEnd)
*----------------------------*
LOCAL  cHouse

Private cDesc1       := STR0058 //"Este programa tem como objetivo imprimir relatório de"
Private cDesc2       := STR0059 //"Saldo de Fornecedores"
Private cDesc3       := "", cPict := "", imprime := .T.
Private titulo       := STR0060 // "RELATÓRIO DE SALDO DE FORNECEDORES"
Private nLin         := 80, Cabec1 :="",Cabec2 := ""
Private cString      := "EC5"   //, lEnd := .F.
Private lAbortPrint  := .F., limite:= 220, tamanho:= "G"
Private nomeprog     := "ECOVC155", nTipo := 18
Private aReturn      :={ STR0061, 1,STR0062, 1, 2, 1, "",1 } //"Zebrado"###"Importacao"
Private nLastKey     := 0, cbtxt := Space(10), cbcont := 00
Private CONTFL       := 01, m_pag := 01, aOrd:={}
Private wnrel        := "ECOVC155" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cMoeda,cCusto,cForn,cNome

cPict:= "@E 999,999,999,999.99"

cCusto := SPACE(10) ; cHouse  := SPACE(18) ; cForn := SPACE(6) ; cMoeda := Work->WKMOEDA
nLin:= 99999; nPag:= 0; nLimPage:= 55

If cTipo_Rel == "1"
   limite:= 220
   tamanho:= "G"
Else
   limite:= 80
   tamanho:= "M"
Endif

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

Work->(DBGOTOP())

oProcess:IncRegua1(STR0063) //"Lendo Arquivos 2 / 2 Gerando Relatório"

oProcess:SetRegua2(Work->(EasyRecCount()))

IF cTipo_Rel = "1"
   nCol1_1:=0; nCol1_2:=nCol1_1+14; nCol1_3:=nCol1_2+21; nCol1_4:=nCol1_3+12
   nCol1_5:=nCol1_4+17; nCol1_6:=nCol1_5+25; nCol1_7:=nCol1_6+27; nCol1_8:=nCol1_7+25
   nCol1_9:=nCol1_8+25; nCol1_10:=nCol1_9+25
Else
   nConta := Work->WKCONTA ; cMoedA    := Work->WKMOEDA ; cCusto := Work->WKCC
   cHouse := SPACE(17)     ; lPrimeiro := .T.
   IF cTipo_Rel = "2"
      nCol2_1:= 00; nCol2_2:= nCol2_1+08; nCol2_3:= nCol2_2+17
      nCol2_4:= nCol2_3+22; nCol2_5:=nCol2_4+25; nCol2_6:=nCol2_5+24
   EndIf
EndIf

If cTipo_Rel = "1"
   Do While !WorK->(EOF())
      If nLin > nLimPage
         VCF155_CAB(cTipo_Rel,Work->WKFORN,Work->WKNOM_RED,Work->WKMOEDA)
      Endif

      If Work->WKCC # cCusto .OR. cMoeda # Work->WKMOEDA .OR. cForn # Work->WKFORN
         @ nLin,nCol1_1 PSay Work->WKCC
      EndIf

      If cHouse <> Work->WKHOUSE
         @ nLin,nCol1_2 PSay Work->WKHOUSE
         cHouse := Work->WKHOUSE
      Endif

      If lEnd
         If lEnd:=MsgYesNo(STR0055,STR0056) //"Tem certeza que deseja cancelar?"###"Atenção"
            MS_FLUSH()
            Return .F.
         EndIf
      EndIf

      oProcess:IncRegua2(STR0064+Alltrim(Work->WKFORN)+STR0065+Alltrim(Work->WKINVOICE)) //"1 / 1 Fornecedor "###" Invoice "

      @ nLin,nCol1_3  PSay DTOC(Work->WKDATA)
      @ nLin,nCol1_4  PSay Work->WKINVOICE
      @ nLin,nCol1_5  PSay TRANS(Work->WKFOB,cPict)
      @ nLin,nCol1_6  PSay TRANS(Work->WKSAL_ANT,cPict)
      @ nLin,nCol1_7  PSay TRANS(Work->WKENTRADA,cPict)
      @ nLin,nCol1_8  PSay TRANS(Work->WKVARIACAO,cPict)
      @ nLin,nCol1_9  PSay TRANS(Work->WKVAR_A,cPict)
      @ nLin,nCol1_10 PSay TRANS(Work->WKSALDO, cPict)
      nlin++

            nGFOB_TOT += Work->WKFOB
            nGSAL_ANT += Work->WKSAL_ANT
            nGENTRADA += Work->WKENTRADA
            nGVARIACAO+= Work->WKVARIACAO
            nGVAR_A   += WorK->WKVAR_A
            nGSALDO   += Work->WKSALDO

            NCcFOB_TOT += Work->WKFOB
            NccSAL_ANT += Work->WKSAL_ANT
            nCCENTRADA += Work->WKENTRADA
            nCCVARIACAO+= Work->WKVARIACAO
            nCCVAR_A   += WorK->WKVAR_A
            nCCSAldo   += Work->WKSALDO

            NmoeFOB_TOT += Work->WKFOB
            NmoeSAL_ANT += Work->WKSAL_ANT
            nmoeENTRADA += Work->WKENTRADA
            nmoeVARIACAO+= Work->WKVARIACAO
            nmoeVAR_A   += WorK->WKVAR_A
            nmoeSAldo   += Work->WKSALDO

            cCusto := Work->WKCC
            cForn  := Work->WKFORN
            cMoeda := Work->WKMOEDA
            cNome  := WorK->WKNOM_RED

            Work->(DBSKIP())

      IF Work->WKCC # cCusto .OR. cMoeda # Work->WKMOEDA .OR. cForn # Work->WKFORN
         If nLin > nLimPage
            VCF155_CAB(cTipo_Rel,cForn,cNome,cMoeda)
         ENDIF
         Tot_CC("1")
       ENDIF

       IF cMoeda # Work->WKMOEDA .OR. cForn # Work->WKFORN
          If nLin > nLimPage
             VCF155_CAB(cTipo_Rel,cForn,cNome,cMoeda)
          ENDIF
          Tot_MOE()
          IF !Work->(EOF()) .AND. Work->WKFORN = cForn
             nLin++
             @ nLin,nCol1_1 Psay STR0017+Work->WKFORN+ " - " +Work->WKNOM_RED //"Fornecedor: "
             @ nLin,nCol1_6 Psay STR0018+Work->WKMOEDA //"Moeda: "
             nLin++
             @ nLin,nCol1_1 PSay __PrtThinLine()
             nLin++
          ENDIF
       ENDIF

       IF Work->WKFORN # cForn
          If nLin > nLimPage
             VCF155_CAB(cTipo_Rel,cForn,cNome,cMoeda )
          ENDIF
          Tot_Forn()
          IF !Work->(EOF())
             nLin++
             @ nLin, nCol1_1 Psay STR0017+Work->WKFORN+ " - " +Work->WKNOM_RED //"Fornecedor: "
             @ nLin, nCol1_6 Psay STR0018+Work->WKMOEDA //"Moeda: "
             nLin++
             @ nLin,nCol1_1 PSay __PrtThinLine()
             nLin++
           ENDIF
       ENDIF

         ENDDO
         Tot_Geral()

ELSE
   nLimPage:= 69
   DO WHILE !Work->(EOF())      
      
      oProcess:IncRegua2(STR0064+Work->WKFORN+STR0065+Work->WKINVOICE) //"1 / 1 Fornecedor "###" Invoice "
      
      If nLin > nLimPage
         VCF155_CAB(cTipo_Rel)
      ENDIF

      IF Work->WKCC # cCusto .OR. cMoeda # Work->WKMOEDA .OR. nConta # Work->WKCONTA
         Tot_Cc(cTipo_Rel)
         lPrimeiro := IF(cTipo_Rel="2", .F.,.T.)
      ENDIF

      IF cMoeda # Work->WKMOEDA .OR. nConta # Work->WKCONTA
         If nLin > nLimPage
            VCF155_CAB(cTipo_Rel)
         ENDIF
         IF cTipo_Rel ="2"
            Tot_Moe()
            lPrimeiro := .T.
         ENDIF
      ENDIF

      IF nConta # Work->WKCONTA .AND. cTipo_Rel ="2"
         lPrimeiro := .T.
         If nLin > nLimPage
            VCF155_CAB(cTipo_Rel)
         ENDIF
         Tot_Geral()

         IF !Work->(EOF())
            VCF155_CAB(cTipo_Rel)
            nContA:= Work->WKCONTA
         ENDIF

      ENDIF
      
      NCcFOB_TOT += Work->WKFOB
      NccSAL_ANT += Work->WKSAL_ANT
      nCCENTRADA += Work->WKENTRADA
      nCCVARIACAO+= Work->WKVARIACAO
      nCCVAR_A   += WorK->WKVAR_A
      nCCSaldo   += Work->WKSALDO

      nMoeFob_toT+= Work->WKFOB
      nMoeSal_ant+= Work->WKSAL_ANT
      nMoeEntrada+= Work->WKENTRADA
      nMoeVariacao+=Work->WKVARIACAO
      nMoeVar_a  += WorK->WKVAR_A
      nMoeSaldo  += Work->WKSALDO

      nTMoeSaldo += Work->WKSALDO
      nTMoeVariacao +=Work->WKVARIACAO
      nTMoeVar_A += Work->WKVAR_A
      
      /*
      IF Str(cTipo_Rel,1) = "3" .AND. cHouse # Work->WKHOUSE
         If nLin > nLimPage
             VCF155_CAB(cTipo_Rel)
         ENDIF
         Tot_House()
         lPrimeiro := .F.
      ENDIF
      */
      
      cCusto := Work->WKCC
      cMoeda := Work->WKMOEDA
      cHouse := Work->WKHOUSE
      nConta := Work->WKCONTA

      Work->(DBSKIP())

      IF Work->(EOF())
         If nLin > nLimPage
            VCF155_CAB(cTipo_Rel)
         ENDIF
         Tot_Cc(cTipo_Rel)
         If nLin > nLimPage
             VCF155_CAB(cTipo_Rel)
         ENDIF
         Tot_Moe()
         If nLin > nLimPage
            VCF155_CAB(cTipo_Rel)
         ENDIF
         IF cTipo_Rel = "2"
            Tot_Geral()
         ENDIF

      ENDIF

   ENDDO

ENDIF

Set Printer To
Commit
Ourspool(wnrel)

MS_FLUSH()

Return

*---------------------------------------------*
 PROCEDURE VCF155_CAB(cRel,cFor,cNome, cMoe)
*---------------------------------------------*
cTexto2 := STR0022+ DTOC(DTINICIAL) +STR0023+ DTOC(DTFINAL) //'DATA INICIAL.: '###'   DATA FINAL.: '

cabec1:= ALLTRIM(SM0->M0_NOME)+" - "+ALLTRIM(SM0->M0_FILIAL)+Space(80)
cabec2:= "Sigaeco"+If(cTipo_Rel="1", Space(80), Space(35))+cTexto2+If(cTipo_Rel="2", Space(25)+"- Resumo", "")

Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
nLin:= 09

IF cTipo_Rel = "1"
   @ nLin,nCol1_1   Psay STR0028 //"UNID. REQ."
   @ nLin,nCol1_2   Psay STR0029 //"PROCESSO"
   @ nLin,nCol1_3   Psay STR0030 //"DATA"
   @ nLin,nCol1_4   Psay STR0031 //"INVOICE"
   @ nLin,nCol1_5+01 Psay STR0032 //"VALOR FOB (MOEDA)"
   @ nLin,nCol1_6-01 Psay STR0033 //"SALDO ANTERIOR (R$)"
   @ nLin,nCol1_7+05 Psay STR0034 //"ENTRADAS (R$)"
   @ nLin,nCol1_8-02 Psay STR0035 //"VAR. EM TRANSITO(R$)"
   @ nLin,nCol1_9-01 Psay STR0036 //"VAR.APOS RECEB.(R$)"
   @ nLin,nCol1_10+2 Psay STR0037 //"SALDO ATUAL (R$)"

   nLin++
   @ nLin,nCol1_1 PSay __PrtThinLine()
   nLin++

   @ nLin,nCol1_1 PSay STR0017+cFor+ " - " +cNome //"Fornecedor: "
   @ nLin,nCol1_6 PSay STR0018+cMoe //"Moeda: "

   nLin++
   @ nLin,nCol1_1 PSay __PrtThinLine()
   nLin++

ELSEIF cTipo_Rel = "2"
   @ nLin,nCol2_1 Psay STR0038+ALLTRIM(STR(VAL(Work->WKCONTA))) //"Conta : "
   nLin++

   @ nLin,nCol2_1   PSay __PrtThinLine()
   nLin++
   @ nLin,nCol2_1   Psay STR0039 //"MOEDA"
   @ nLin,nCol2_2   Psay STR0028 //"UNID. REQ."
   @ nLin,nCol2_3+1 Psay STR0032 //"VALOR FOB (MOEDA)"
   @ nLin,nCol2_4+2 Psay STR0037 //"SALDO ATUAL (R$)"
   @ nLin,nCol2_5-3 Psay STR0040 //"VAR. EM TRANSITO (R$)"
   @ nLin,nCol2_6-2 Psay STR0041 //"VAR. APOS RECEB.(R$)"
   nLin++
   @ nLin,nCol2_1 PSay __PrtThinLine()
   nLin++
/*     
ELSE
   oPrn:oFont:= COURIER_12
   oPrn:Say(nLin,nCol3_1,STR0028) //"UNID. REQ."
   oPrn:Say(nLin,nCol3_2,STR0029) //"PROCESSO"
   oPrn:Say(nLin,nCol3_3,STR0030) //"DATA"
   oPrn:Say(nLin,nCol3_4,STR0037) //"SALDO ATUAL (R$)"
   oPrn:oFont:= COURIER_10
   nLin+=60
   oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   nLin+=25
*/   
ENDIF
RETURN

*------------------*
FUNCTION Tot_Forn()
*------------------*
//nLin++
@ nLin,nCol1_1 PSay __PrtThinLine()
nLin++
@ nLin, nCol1_1 Psay STR0042 //"Total do Fornecedor"
@ nLin, nCol1_6 Psay TRANS(nGSAL_ANT,cPict)
@ nLin, nCol1_7 Psay TRANS(nGENTRADA,cPict)
@ nLin, nCol1_8 Psay TRANS(nGVARIACAO,cPict)
@ nLin, nCol1_9 Psay TRANS(nGVAR_A,cPict)
@ nLin, nCol1_10 Psay TRANS(nGSALDO,cPict)
nLin++
@ nLin,nCol1_1 PSay __PrtThinLine()
nLin++

//nLin++ //=40
//oPrn:Box(nLin,nColIni,nLin+1,nColFim)
//nLin+=25
nSSAL_ANT  += nGSAL_ANT
nSFOB_TOT  += nGFOB_TOT
nSENTRADA  += nGENTRADA
nSACERTO   += nGACERTO
nSSAIDA    += nGSAIDA
nSVARIACAO += nGVARIACAO
nSVAR_A    += nGVAR_A
nSSALDO    += nGSALDO
nGENTRADA  := nGACERTO := nGSAIDA := nGVARIACAO := nGVAR_A := nGSAL_ANT := nGSALDO:= nGFOB_TOT := 0

RETURN ""

*---------------------*
FUNCTION TOT_CC(cQual)
*---------------------*
IF cQual = "1"
   //nLin++
   @ nLin,nCol1_1 PSay __PrtThinLine()
   nLin++
   @nLin,nCol1_1  Psay STR0043 //"Total do Centro de Custo"
   @nLin,nCol1_5  Psay TRANS(NCcFOB_TOT,cPict)
   @nLin,nCol1_6  Psay TRANS(nCCSAL_ANT,cPict)
   @nLin,nCol1_7  Psay TRANS(nCCENTRADA,cPict)
   @nLin,nCol1_8  Psay TRANS(nCCVARIACAO,cPict)
   @nLin,nCol1_9  Psay TRANS(nCCVAR_A,cPict)
   @nLin,nCol1_10 Psay TRANS(nCCSALDO,cPict)
   nLin++
   @ nLin,nCol1_1 PSay __PrtThinLine()
   nLin++
ELSEIF cQual = "2"
   IF NcCSALDO = 0
      NccSaldo := nccFob_Tot :=nCCSALDO := nCCSAL_ANT := ncCENTRADA := nCCACERTO := nCCVARIACAO:= nCCVAR_A:= nCCSAIDA :=0
      RETURN
   ENDIF
   IF lPrimeiro
      @ nLin,nCol2_1 PSay cMoeda
   ENDIF
   @ nLin,nCol2_2 PSay cCusto
   @ nLin,nCol2_3 PSay TRANS(NCcFOB_TOT,cPict)
   @ nLin,nCol2_4 PSay TRANS(nCCSALDO,cPict)
   @ nLin,nCol2_5 PSay TRANS(nCCVARIACAO,cPict)
   @ nLin,nCol2_6 PSay TRANS(nCCVAR_A,cPict)
   nLin++ //=40
   @ nLin,nCol2_1 PSay __PrtThinLine()
   nLin++
/*   
ELSE
   oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   nLin+=25
   oPrn:Say(nLin,nColIni+30,STR0044+ cCusto) //"Total em "
   oPrn:Say(nLin,nCol3_4,TRANS(nCCSALDO,cPict))
   nLin+=40
   oPrn:Box( nLin,nColIni,nLin+1,nColFim)
   nLin+=25
*/
ENDIF
NccSaldo := nccFob_Tot :=nCCSALDO := nCCSAL_ANT := ncCENTRADA := nCCACERTO := nCCVARIACAO:= nCCVAR_A:= nCCSAIDA :=0

RETURN NIL

*--------------------*
FUNCTION TOT_MOE()
*--------------------*

IF cTipo_rel = "1"
   //nLin++
   //@ nLin,nCol1_1 PSay __PrtThinLine()
   //nLin++
   @ nLin,nCol1_1 Psay STR0045 + cMoeda //"Total em Moeda "
   @ nLin,nCol1_5 Psay TRANS(NmoeFOB_TOT,cPict)
   @ nLin,nCol1_6 Psay TRANS(nmoeSAL_ANT,cPict)
   @ nLin,nCol1_7 Psay TRANS(nmoeENTRADA,cPict)
   @ nLin,nCol1_8 Psay TRANS(nmoeVARIACAO,cPict)
   @ nLin,nCol1_9 Psay TRANS(nmoeVAR_A,cPict)
   @ nLin,nCol1_10 Psay TRANS(nmoeSALDO,cPict)
   nLin++
   @ nLin,nCol1_1 PSay __PrtThinLine()
   nLin++

   //nLin++ //=40
   /*
   oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   nLin+=25
   */
   NmoeSaldo := nmoeFob_Tot :=nmoeSALDO := nmoeSAL_ANT := nmoeENTRADA := nmoeACERTO := nmoeVARIACAO:= nmoeVAR_A:= nmoeSAIDA :=0
   RETURN ""
ENDIF

IF cTipo_rel = "2"
   IF nMoeSaldo = 0
      nMoeFob_Tot := nMoeSALDO := nMoeSAL_ANT := nMoeENTRADA := nMoeACERTO := nMoeVARIACAO:= nMoeVAR_A:= nMoeSAIDA :=0
      RETURN ""
   ENDIF

   //oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   //nLin+=25
   @ nLin,nCol2_1 PSay STR0044+ CMoeda //"Total em "
   @ nLin,nCol2_3 PSay TRANS(NMoeFOB_TOT,cpict)
   @ nLin,nCol2_4 PSay TRANS(nMoeSALDO,cpict)
   @ nLin,nCol2_5 PSay TRANS(nMoeVARIACAO,cpict)
   @ nLin,nCol2_6 PSay TRANS(nMoeVAR_A,cpict)
   nLin++ //=40
   //oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   //nLin+=25
   @ nLin,nCol2_1 PSay __PrtThinLine()
   nLin++
   nMoeFob_Tot := nMoeSALDO := nMoeSAL_ANT := nMoeENTRADA := nMoeACERTO := nMoeVARIACAO:= nMoeVAR_A:= nMoeSAIDA :=0
/*   
ELSE
   oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   nLin+=25
   oPrn:Say(nLin,nColIni+30,STR0046) //"Total : "
   oPrn:Say(nLin,nCol3_4,TRANS(nMoeSALDO,cpict))
   nLin+=40
   oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   nLin+=25
   nMoeFob_Tot := nMoeSALDO := nMoeSAL_ANT := nMoeENTRADA := nMoeACERTO := nMoeVARIACAO:= nMoeVAR_A:= nMoeSAIDA :=0
*/
ENDIF

RETURN ""

*--------------------*
FUNCTION TOT_GERAL()
*--------------------*
IF cTipo_Rel = "1"
   //nLin++
   @ nLin,nCol1_1 PSay __PrtThinLine()
   nLin++

   @ nLin,nCol1_1  Psay STR0047  //"Total Geral "
   @ nLin,nCol1_6  Psay TRANS(nSSAL_ANT,cpict)
   @ nLin,nCol1_7  Psay TRANS(nSENTRADA,cpict)
   @ nLin,nCol1_8  Psay TRANS(nSVARIACAO,cpict)
   @ nLin,nCol1_9  Psay TRANS(nSVAR_A,cpict)
   @ nLin,nCol1_10 Psay TRANS(nSSALDO,cpict)
   nLin++
   @ nLin,nCol1_1 PSay __PrtThinLine()
   nLin++

   //nLin++ //=40
   /*
   oPrn:Box(nLin,nColIni,nLin+1,nColFim)
   nLin+=25
   */
   nSSAL_ANT := nSFOB_TOT := nSENTRADA := nSACERTO := nSSAIDA  := nSVARIACAO := nSSALDO := nSVAR_A := 0
   RETURN ""
ENDIF

//oPrn:Box(nLin,nColIni,nLin+1,nColFim)
//nLin+=25

@ nLin,nCol2_1 Psay STR0048 //"Total Geral em R$ "
@ nLin,nCol2_4 Psay TRANS(nTMoeSALDO,cpict)
@ nLin,nCol2_5 Psay TRANS(nTMoeVARIACAO,cpict)
@ nLin,nCol2_6 Psay TRANS(nTMoeVAR_A,cpict)
nLin++ //=40
//oPrn:Box(nLin,nColIni,nLin+1,nColFim)
//nLin+=25
nTMoeSaldo :=  nTMoeVariacao :=  nTMoeVar_A := 0
nSSAL_ANT := nSFOB_TOT := nSENTRADA := nSACERTO := nSSAIDA  := nSVARIACAO := nSSALDO := nSVAR_A := 0

RETURN ""

*--------------------*
FUNCTION TOT_HOUSE()
*--------------------*
IF lPrimeiro
   oPrn:Say(nLin,nCol3_1,Work->WKCC)
ENDIF
oPrn:Say(nLin,nCol3_2,Work->WKHOUSE)
oPrn:Say(nLin,nCol3_3,DTOC(Work->WKDATA))
oPrn:Say(nLin,nCol3_4,TRANS(nTMoeSALDO,cpict))
nLin+=50
nTMoeSaldo := 0
RETURN ""

*-----------------------*
Function VC155Val(cTipo)
*-----------------------*
If cTipo = '1' //.OR. cTipo = 'OK'
   IF EMPTY(mv_par03)
      Help(" ",1,"AVG0005339") //E_Msg(STR0049,1) //"Data inicial n„o preenchida."
      Return .F.
   ENDIF
EndIf
If cTipo = '2' //.OR. cTipo = 'OK'
   IF EMPTY(mv_par04)
      Help(" ",1,"AVG0005340") //E_Msg(STR0050,1) //"Data final n„o preenchida."
      Return .F.
   ENDIF
EndIf
/*
If cTipo = 'OK'
   IF DTOS(DTINICIAL) > DTOS(DTFINAL)
      Help(" ",1,"AVG0005341") //E_Msg(STR0051,1) //"Data final menor que a inicial."
      Return .F.
   ENDIF
EndIf
*/
If cTipo = "FORNECEDOR" //.OR. cTipo = 'OK'
   If ! EMPTY(ALLTRIM(MV_PAR01)) .AND. ! SA2->(DBSEEK(cFilSA2+MV_PAR01))
      Help(" ",1,"AVG0005302") //E_Msg(STR0052,1) //"Fornecedor n„o cadastrado."
      Return .F.
   EndIf
EndIf

Return .T.
*--------------------------*
Static Function ContaReg()
*--------------------------*
Local cQueryEC5, cWhereEC5
Local cCondEC5:=   " AND EC5.D_E_L_E_T_ <> '*' AND EC2.D_E_L_E_T_  <> '*' AND EC8.D_E_L_E_T_  <> '*' AND EC9.D_E_L_E_T_  <> '*' AND SA2.D_E_L_E_T_  <> '*'"
Local cCondAsEC5:= " AND EC5.@DELETED@ <> '*' AND EC2.@DELETED@ <> '*' AND EC8.@DELETED@ <> '*' AND EC9.@DELETED@ <> '*' AND SA2.@DELETED@ <> '*'"

nTotEC5  := 0

IF lTop

  cAliasEC5   := "EC5TMP"

  // Where EC5
  cWhereEC5:= " EC5.EC5_FILIAL='"+ cFilEC5 +"' AND EC8.EC8_FILIAL='"+cFilEC8+"' "
  cWhereEC5+= " AND EC2.EC2_FILIAL ='"+ cFilEC2 +"' AND EC9.EC9_FILIAL ='"+ cFilEC9 +"' "
  If !Empty(cForn)
     cWhereEC5+=" AND EC5.EC5_FORN = '"+cForn+"'"
  Endif
  
  cWhereEC5+= " AND EC5.EC5_FORN = EC8.EC8_FORN "

  cWhereEC5+=" AND EC5.EC5_INVOIC = EC8.EC8_INVOIC AND EC5.EC5_IDENTC = EC8.EC8_IDENTC "
  
  cWhereEC5+=" AND EC8.EC8_HAWB = EC2.EC2_HAWB AND EC8.EC8_FORN = EC2.EC2_FORN AND EC8.EC8_MOEDA = EC2.EC2_MOEDA "
  cWhereEC5+=" AND EC8.EC8_IDENTC = EC2.EC2_IDENTC "
  
  If cTipo_Rel = "3"
     cWhereEC5+=" AND EC2.EC2_TX_DI = 0 "
  Endif
  
  cWhereEC5+= " AND EC5.EC5_FORN = EC9.EC9_FORN "

  cWhereEC5+=" AND EC5.EC5_INVOIC = EC9.EC9_INVOIC AND EC5.EC5_IDENTC = EC9.EC9_IDENTC "
  cWhereEC5+=" AND ((EC5.EC5_VCFANO = '' AND EC5.EC5_VCFMES = '') OR (EC5.EC5_VCFANO = ' 'AND EC5.EC5_VCFMES = ' ')
  cWhereEC5+=" OR (EC5.EC5_VCFANO >='"+Left(cAnoMesEnc,4)+"' AND EC5.EC5_VCFMES > '"+Right(cAnoMesEnc,2)+"' )) " 
  cWhereEC5+=" AND EC5.EC5_AMOS NOT IN('"+cSim+"')"
    
  If !Empty(cCcont)
     cWhereEC5+=" AND EC5.EC5_FORN = SA2.A2_COD AND SA2.A2_CONTAB = '"+cCcont+"'"
  Endif
 
  cWhereEC5+= If(TcSrvType()<>"AS/400",cCondEC5,cCondAsEC5)  
  
  cQueryEC5:= "SELECT DISTINCT EC8.EC8_FILIAL, EC2.EC2_FILIAL, EC9.EC9_FILIAL, EC5.EC5_FORN, EC8.EC8_FORN, EC5.EC5_INVOIC, "
  cQueryEC5+= "EC8.EC8_INVOIC, EC5.EC5_IDENTC, EC8.EC8_IDENTC, EC8.EC8_HAWB, EC2.EC2_HAWB, EC8.EC8_FORN, EC2.EC2_FORN, "
  cQueryEC5+= "EC8.EC8_MOEDA, EC2.EC2_MOEDA, EC8.EC8_IDENTC, EC2.EC2_IDENTC, EC5.EC5_FORN, EC9.EC9_FORN, EC5.EC5_INVOIC, "
  cQueryEC5+= "EC9.EC9_INVOIC, EC5.EC5_IDENTC, EC9.EC9_IDENTC, EC5.EC5_VCFANO, EC5.EC5_VCFMES, EC5.EC5_AMOS "
  cQueryEC5+= "FROM "+RetSqlName("EC5")+ " EC5, "+RetSqlName("EC2")+ " EC2, "+RetSqlName("EC8")+ " EC8, "
  cQueryEC5+= RetSqlName("EC9")+ " EC9, "+RetSqlName("SA2")+ " SA2 WHERE "+cWhereEC5
  
  // EC5
  cQueryEC5 := ChangeQuery(cQueryEC5)
  DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQueryEC5), cAliasEC5,.F.,.T.)
  
  dbSelectArea(cAliasEC5)
  Do While !(cAliasEC5)->(EOF())
     nTotEC5++
     (cAliasEC5)->(dbSkip())
  EndDo
  
  If Select(cAliasEC5) > 0  
     (cAliasEC5)->(DbCloseArea())
  Endif   
  
Else

  // EC5
  EC5->(DbSeek(cFilEC5,.T.))
  EC9->(DbSeek(cFilEC9,.T.))
  EC8->(DbSeek(cFilEC8,.T.))
  EC2->(DbSeek(cFilEC2,.T.))

  // Nick 12/04/2006 - Ajuste na Função MsAguarde pois estava pela metade
  EC5->(DBEVAL({||nTotEC5++, MsAguarde({|| MsProcTxt("Lendo Invoice "+EC5->EC5_INVOIC),},"")},,{||EC5->(!EOF()) .And. EC5->EC5_FILIAL = cFilEC5 .And.;
               If(!Empty(cForn), cForn = EC5->EC5_FORN , .T.) .And. EC5->EC5_FORN = EC8->EC8_FORN .And. EC5->EC5_INVOIC = EC8->EC8_INVOIC .And.;
               EC5->EC5_IDENTC = EC8->EC8_IDENTC .And. EC8->EC8_HAWB = EC2->EC2_HAWB .And. EC8->EC8_FORN = EC2->EC2_FORN .And.;
               EC8->EC8_MOEDA = EC2->EC2_MOEDA .And. EC8->EC8_IDENTC = EC2->EC2_IDENTC .And. If(cTipo_Rel = "3", EC2->EC2_TX_DI = 0, .T.) .And.;
               EC9->EC9_FORN = EC5->EC5_FORN .And. EC9->EC9_INVOIC = EC5->EC5_INVOIC .And. EC9->EC9_IDENTC = EC5->EC5_IDENTC .And.;
               (!Empty((EC5->EC5_VCFANO+EC5->EC5_VCFMES)) .And. (EC5->EC5_VCFANO+EC5->EC5_VCFMES)> cAnoMesEnc ) .And.;
               EC5->EC5_AMOS $ cSim })) //"Lendo Invoice "

Endif

Return .T.
