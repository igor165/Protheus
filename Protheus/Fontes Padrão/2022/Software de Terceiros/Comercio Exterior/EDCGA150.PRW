#INCLUDE "EDCGA150.ch"                                    
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE say_tit 1
#DEFINE say_det 2
#DEFINE say_rep 3

//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EDCGA150
//Autor.....: Cleverson E. da Silva(CES)
//Data......: 19 de Junho de 2002, 17:30
//Sintaxe...: EDCGA150
//Uso.......: SIGAEDC
//Versao....: Protheus - 6.09a
//Descricao.: Relatorio de Ganhos com o Ato Concessorio(SetPrint)
//Revisão...: Gustavo Carreiro (GFC) - 05/11/02
//Revisão...: Alessandro Alves Ferreira (AAF) - 31/08/05
//------------------------------------------------------------------------------------//

*----------------------*
FUNCTION EDCGA150()
*----------------------*
Local lOk
Private cNomArq,cNomArq1, dDtIni, dDtFinal, cDespAFRMM, cDespArm, cMoeRel, cDesp
Private cMoeDolar :=EasyGParam("MV_SIMB2",,"US$"), cMoedaRel, aNroDi:= {}, cNomArq2
Private lGenerico,lSuspensao,lIntermediario, lVez:= .T., cFileDbf
Private cVarAux:=cVarAux1:=cVarAux2:=cVarAux3:=cVarAux4:=cVarAux5:=""
//Private lDiExt := EasyGParam("MV_EDCDIE",,.F.)  - NOPADO POR AOM 04/11/10
Processa({||lOk:=GA150CriaWork()})

IF !lOk
   Return .T.
ENDIF

ED0->(DBSETORDER(1))//ED0_FILIAL+ED0_PD
ED4->(DBSETORDER(1))//ED4_FILIAL+ED4_PD
SW8->(DBSETORDER(5))//W8_FILIAL+W8_AC+W8_COD_I
SW7->(DBSETORDER(4))//W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM

DO WHILE .T.

   IF ! PERGUNTE("EDCGA1",.T.)
      EXIT
   ENDIF

   cPedido   :=mv_par01
   //cDespArm  :=mv_par03
   cDesp     :=mv_par03  //+"/"+cDespArm   
   cTipo     :=mv_par04  //1-SINTETICO 2-ANALITICO
   dDtIni    :=mv_par05
   dDtFinal  :=mv_par06
   cMoeRel   :=mv_par07  //1-US$  2-R$
   //cDesp     :=Alltrim(mv_par08)+"\"+cDespArm
   lDtNF     :=mv_par08 == 2
   
   If !E_PERIODO_OK(dDtIni,dDtFinal)//!E_PERIODO_OK(@dDtIni,@dDtFinal)
      Loop
   Endif

   Processa({|| lOk:=GA150GRVWORK() })

   If !lOk
      Loop
   EndIf

   Processa({||GA150PRINT()})   
ENDDO

ED0->(DBSETORDER(1))
ED4->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW7->(DBSETORDER(1))

WORK->(E_EraseArq(cNomArq))
WORK_TOT->(E_EraseArq(cNomArq1))
W_ULTPAG->(E_EraseArq(cNomArq2))
TRB->(E_EraseArq(cFileDbf))

RETURN .T.

*----------------------*
FUNCTION GA150GRVWORK()
*----------------------*
Local cFilED0:=xFilial("ED0"),cFilED4:=xFilial("ED4"), nInd, i
Local cFilSW6:=xFilial("SW6"),cFilSW9:=xFilial("SW9"),cFilSYD:=xFilial("SYD")
Local cFilSWN:=xFilial("SWN"), cFilED2:= xFilial("ED2")
Local cFilSF1:=xFilial("SF1")
Local nCont:=0,nRegua:=5, nVlArm:=0 //, aHawb:={}
Local bWhile:={||ED0->ED0_FILIAL==cFilED0},bFor:={||},cChave:=cFilED0
Local aFrete:={}, nPesoAto, nFobAto, lPrim:= .T.
Local oDlgProc := GetWndDefault(), cViaTra:="", nRecSW8, nIndSW8
Local Ni

Private nParidade
Private aNCM:={},nAscan, cHawb, cNroDi //Usado para o Rdmake de Gravação do Arquivo de Muro
Private cFilSW7:=xFilial("SW7"), cFilSWD:=xFilial("SWD"), cFilSW8:=xFilial("SW8")
Private cFilED8:=xFilial("ED8")
Private nSomaAffrm:=nSomaArmaz:=nSomaII:=nSomaIPI:=nSomaICMS:= 0
PRIVATE lMV_PIS_EIC:=EasyGParam("MV_PIS_EIC",,.F.) .AND. SW8->(FIELDPOS("W8_BASPIS")) # 0 .AND. SYD->(FIELDPOS("YD_PER_PIS")) # 0
Private lVlUnid    := SYD->(FieldPos("YD_UM")) # 0 .AND. SW8->(FieldPos("W8_QTDE_UM")) # 0
Private nIndFor //AAF 29/08/05 - Private para ser visivel em RdMake.
Private aAux:= {} //Variavel private para utilização em RdMakes.

WORK->(avzap())
WORK_TOT->(avzap())

aNroDi:= {}

ProcRegua(nRegua)

If !Empty(cPedido)
   bWhile:={||ED0->ED0_FILIAL+ED0->ED0_PD==cFilED0+cPedido}
   cChave:=cFilED0+cPedido
Endif

SWN->(dbSetOrder(3))
ED2->(dbSetOrder(3))
SYQ->(dbSetOrder(1))
SW6->(dbSetOrder(1))
SF1->(dbSetOrder(5))

ED0->(DbSeek(cChave))

Do While ED0->(!EOF()) .And. Eval(bWhile)

   If EDCGADTCORTE(dDtIni,dDtFinal,cFilSW6,cFilSF1,lDtNF) //LGS-30/05/2014
   	  ED0->(DbSkip())
   	  Loop
   EndIf

   IncProc(STR0001+ED0->ED0_AC) //"Ato Concessorio "
   nCont++
   If nCont>nRegua
      ProcRegua(nRegua)
      nCont:=0
   EndIF

   If Empty(cPedido) 
      If !Empty(ED0->ED0_DT_ENC)
         ED0->(DbSkip())
         Loop
      /*ElseIf !Empty(ED0->ED0_AC) .and. SW8->(DbSeek(cFilSW8+ED0->ED0_AC))
         ED0->(DbSkip())
         Loop*/
      EndIf
   EndIf

   lGenerico     :=IF(ED0->ED0_TIPOAC=="06",.T.,.F.)
   lSuspensao    :=IF(ED0->ED0_MODAL=="1"  ,.T.,.F.)
   lIntermediario:=If(ED0->ED0_TIPOAC=="02",.T.,.F.)

   aNCM:={}
   aHawb:={}

   //----------------------Previsto

   If cMoeRel = 2
      nTxUSD := BuscaTaxa(cMoeDolar,dDataBase,,.F.,.T.)
   Else
      nTxUSD := 1
   EndIf

   If ED4->(DbSeek(cFilED4+ED0->ED0_PD))

      nFobAto:=nPesoAto:=nTotII:=nTotIPI:=nTotPIS:=nTotCOF:=nTotArm:=nTotICMS:=nTotAFRMM:=0
      nTotFrete:=nTotSeguro:=nCalcAFRMM:=nCalPeso:=nRateio:=0
      //** PLB 12/09/06
      nSomaAffrm:= 0
      nSomaArmaz:= 0
      //**

      Do While ED4->(!Eof()) .And. ED4->ED4_FILIAL+ED4->ED4_PD==cFilED4+ED0->ED0_PD

         ED2->(dbSeek(cFilED2+ED4->ED4_PD+ED4->ED4_NCM+ED4->ED4_ITEM))
         If cTipo = 2  //Analítico
            nCalcAFRMM:= 0
         Endif
         While !ED2->(EOF()) .And. ED2->ED2_FILIAL == cFilED2 .And. ED2->ED2_PD == ED0->ED0_PD;
            .And. ED2->ED2_NCM == ED4->ED4_NCM .And. ED2->ED2_ITEM == ED4->ED4_ITEM

            If ED0->ED0_MODAL == "2" //Isenção
               If ED4->ED4_CAMB <> ED2->ED2_CAMB .Or. ED4->ED4_UMNCM <> ED2->ED2_UMNCM //.Or. STR(ED4->ED4_PERCPE,5,2) <> STR(ED2->ED2_PERCPE,5,2)
                  ED2->(dbSkip())
                  Loop
               Endif
               nCalcAFRMM+= ED2->ED2_FRETE
            Else                     //Suspensão
               EDCGA150RATEIO()
               If cTipo = 2          //Analítico
                  nCalcAFRMM:= nRateio*ED0->ED0_FRETE
               Else
                  nCalcAFRMM+= nRateio*ED0->ED0_FRETE
               Endif
            Endif
            ED2->(dbSkip())
         EndDo

         oDlgProc:SetText(STR0002)    //"Previsto"
         IncProc(STR0001+ED0->ED0_AC) //"Ato Concessorio "
         nCont++
         If nCont>nRegua
            ProcRegua(nRegua)
            nCont:=0
         EndIF

         If ( nAscan:=Ascan(aNcm,{|a|a[1]==ED4->ED4_NCM .and. a[6]==ED4->ED4_ITEM}) ) == 0             //NCF - 22/06/2017
            AADD(aNcm,{ED4->ED4_NCM,ED4->ED4_VALEMB*nTxUSD,0,0,ED0->ED0_PD,ED4->ED4_ITEM,.T.,nCalcAFRMM,ED4->ED4_PESO,0,"","","",0,0,ED4->ED4_QTDCAL})
         Else
            aNcm[nAscan,2] +=ED4->ED4_VALEMB*nTxUSD
            aNcm[nAscan,9] +=ED4->ED4_PESO
            aNcm[nAscan,8] +=nCalcAFRMM
            aNcm[nAscan,16]+=ED4->ED4_QTDCAL //para PIS e COFINS
         EndIf
         nFobAto +=ED4->ED4_VALEMB*nTxUSD
         nPesoAto+=ED4->ED4_PESO

         ED4->(DbSkip())

      EndDo

      ED2->(dbSeek(cFilED2+ED0->ED0_PD))

      For nInd:=1 To Len(aNcm)

         Work->(DbAppend())
         Work->WKAC  :=ED0->ED0_AC
         Work->WKPD  :=ED0->ED0_PD
         Work->WKTIPO:=IF(ED0->ED0_MODAL=="1",STR0003,STR0004)          //"Suspensao"###"Isencao"
         Work->WKNCM :=aNcm[nInd,1]
         Work->WKITEM:=aNcm[nInd,6]

         SYD->(DbSeek(cFilSYD+Work->WKNCM))

         nTxII  :=SYD->YD_PER_II                       
         
         nTxIPI :=SYD->YD_PER_IPI
         nTxICMS:=SYD->YD_ICMS_RE
         nVlCIF :=aNcm[nInd,2]+(aNcm[nInd,9]/nPesoAto)*(ED0->ED0_FRETE*nTxUSD)+(aNcm[nInd,2]/nFobAto)*(ED0->ED0_SEGURO*nTxUSD)

         IF SB1->(DbSeek(xFilial()+aNcm[nInd,6])) .AND. SB1->B1_IMPORT <> "N"  // LRS  26/03/2014 - Validação de produtos importados
         	Work->WKR_TXII  := nTxII
         EndIF
         
         Work->WKR_TXIPI := nTxIPI
         Work->WKR_TXICMS:= nTxICMS
         
         IF SB1->(DbSeek(xFilial()+aNcm[nInd,6])) .AND. SB1->B1_IMPORT <> "N"  // LRS  26/03/2014 - Validação de produtos importados, para calculo de II e AFRMM
	         Work->WKP_II    :=(nVlCIF*nTxII) / 100
	         
	         If cTipo = 2  //Analítico
	            Work->WKP_AFRMM:=(aNcm[nInd,8]*25)/100
	            nTotAFRMM+=Work->WKP_AFRMM
	         Endif
         EndIF
         
         Work->WKP_IPI   :=((nVlCIF+Work->WKP_II)*nTxIPI) / 100
         
         nVlrIPIEsp := 0
         nWZ_ICMSPC := 0
         IF lMV_PIS_EIC
            IF SB1->(DbSeek(xFilial()+aNcm[nInd,6])) .AND. !EMPTY(SB1->B1_TAB_IPI)
               EI6->(DBSEEK(xFilial()+SB1->B1_TAB_IPI))
               nVlrIPIEsp:=aNcm[nInd,16]*EI6->EI6_IPIUNI
            EndIf
         
            SYD->(DbSeek(cFilSYD+aNcm[nInd,1]))
            IF !EMPTY(SYD->YD_VLU_PIS)
               Work->WKP_PIS := SYD->YD_VLU_PIS * aNcm[nInd,16]
            ELSE
               Work->WKP_PIS := DI500PISCalc(nVlCIF,Work->WKP_II+Work->WKP_IPI,(nTxII/100),(nTxIPI/100),(nTxICMS/100),(SYD->YD_PER_PIS/100),(SYD->YD_PER_COF/100),(SYD->YD_RED_PIS/100),nWZ_ICMSPC) * (SYD->YD_PER_PIS/100)
            ENDIF
            IF !EMPTY(SYD->YD_VLU_COF)
               Work->WKP_COF := SYD->YD_VLU_COF * aNcm[nInd,16]
            ELSE
               Work->WKP_COF := DI500PISCalc(nVlCIF,Work->WKP_II+Work->WKP_IPI,(nTxII/100),(nTxIPI/100),(nTxICMS/100),(SYD->YD_PER_PIS/100),(SYD->YD_PER_COF/100),(SYD->YD_RED_COF/100),nWZ_ICMSPC) * (SYD->YD_PER_COF/100)
            ENDIF
            Work->WKR_TXPIS  := SYD->YD_PER_PIS
            Work->WKR_TXCOF  := SYD->YD_PER_COF
         EndIf

         //** PLB 05/02/07 - Correção do cálculo do ICMS

         //If lSuspensao .and. !lIntermediario
            //Work->WKP_ICMS:=((nVlCIF+Work->WKP_II+Work->WKP_IPI)*nTxICMS) / 100
         //EndIf

         Work->WKP_ICMS := ( ( nVlCIF+Work->(WKP_II+WKP_IPI+WKP_PIS+WKP_COF) ) / (100 - nTxICMS) ) * nTxICMS

         If !lSuspensao .Or. lIntermediario
            Work->WKP_ICMS := Work->WKP_ICMS - ( ( nVlCIF / ( 100 - nTxICMS ) ) * nTxICMS )
         Endif
         //**

         nTotII   += Work->WKP_II
         nTotIPI  += Work->WKP_IPI
         nTotPIS  += Work->WKP_PIS
         nTotCOF  += Work->WKP_COF
         nTotICMS += Work->WKP_ICMS

      Next

      If cTipo = 1 //Sintético
         Work->WKP_AFRMM:=(nCalcAFRMM*25)/100
         nTotAFRMM+=Work->WKP_AFRMM
      Endif

      WORK_TOT->(DBAPPEND())

      WORK_TOT->WKAC      := ED0->ED0_AC
      WORK_TOT->WKPD      := ED0->ED0_PD
      WORK_TOT->WKTIPO    := IF(ED0->ED0_MODAL=="1",STR0003,STR0004) //"Suspensao"###"Isencao"
      WORK_TOT->WKP_II    := nTotII
      WORK_TOT->WKP_IPI   := nTotIPI
      WORK_TOT->WKP_ICMS  := nTotICMS
      WORK_TOT->WKP_AFRMM := nTotAFRMM
      WORK_TOT->WKP_PIS   := nTotPIS
      WORK_TOT->WKP_COF   := nTotCOF
      //SVG
      WORK_TOT->WKP_TOTPR := nTotII + nTotIPI + nTotICMS+nTotAFRMM+nTotPIS + nTotCOF
   Endif
   //----------------------Realizado
   
   //If lDiExt - NOPADO POR AOM - 04/11/10
      ED8->( dbSetOrder(3) )
   //EndIf
   If !Empty(ED0->ED0_AC) .and. ( SW8->(DbSeek(cFilSW8+ED0->ED0_AC)) .OR. /*If(lDiExt,*/ED8->( dbSeek(xFilial("ED8")+ED0->ED0_AC) )/*,.F.)*/ )

      nFobAto:=nPesoAto:=nDespTot:=nFrete:=nSeguro:=nDespArm:=nDespArTot:=0
      nTotAFRMM:=nTotFrete:=nTotSeguro:=nFreteTot:=nSeguroTot:=0
      nTotII:=nTotIPI:=nTotICMS:=nTotPIS:=nTotCOF:=nCalAFRMM:=nTotArm:=nVlProc:=0
      nCalcFob:=nCalcPeso:=nCalcFAto:=nCalcPAto:=nCalcAFRMM:= 0
      aHawb:={}
      cProc:= Space(Len(SW8->W8_HAWB))
      cItem:=Space(Len(SW8->W8_COD_I))

      Do While SW8->(!Eof()) .And. SW8->W8_FILIAL+SW8->W8_AC==cFilSW8+ED0->ED0_AC      

         oDlgProc:SetText(STR0005) //"Realizado"
         IncProc(STR0001+ED0->ED0_AC) //"Ato Concessorio "
         nCont++
         If nCont>nRegua
            ProcRegua(nRegua)
            nCont:=0
         EndIF

         If ( nAscan:=Ascan(aNcm,{|a|a[1]==SW8->W8_TEC .and. a[6]==SW8->W8_COD_I}))==0
            SW8->(Dbskip())
            Loop
         Endif

         If !SW6->( dbSeek(cFilSW6+SW8->W8_HAWB) ) .OR. Empty(SW6->W6_DTREG_D)
            SW8->(Dbskip())
            Loop
         EndIf
         
         //** AAF 30/08/05 - Data de Corte por DI ou NF.
         If !Empty(dDtIni) .AND. !Empty(dDtFinal)
            If !lDtNF
               If ( SW6->W6_DTREG_D < dDtIni   ) .OR.;
                  ( SW6->W6_DTREG_D > dDtFinal )
                  SW8->(Dbskip())
                  Loop
               Endif
            Else
               SF1->( dbSeek(cFilSF1+SW8->W8_HAWB+"1") )
               
               If ( SF1->F1_EMISSAO < dDtIni  ) .OR.;
                  ( SF1->F1_EMISSAO > dDtFinal)
                  SW8->(Dbskip())
                  Loop
               Endif
            Endif
         Endif
         //**

         nTxUSD:= SW6->W6_TX_US_D
         nParidade:=1         
         
         //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
         If SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))
            Do While SW9->(!EOF()) .And. SW9->(W9_FILIAL+W9_INVOICE+W9_FORN)==cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN
               If SW9->W9_HAWB==SW8->W8_HAWB
                  If cMoeRel = 1 //US$
                     If SW9->W9_MOE_FOB<>cMoeDolar
                        nParidade:=SW9->W9_TX_FOB/nTxUSD
                     EndIf
                  Else
                     nParidade:=SW9->W9_TX_FOB
                  EndIf
                  Exit
               Endif
            EndDo
         Endif

         nRecSW8 := SW8->(RecNo())
         nIndSW8 := SW8->(IndexOrd())
         cHawb   := SW8->W8_HAWB
         SW8->(dbSetOrder(1))
         SW8->(dbSeek(cFilSW8+cHawb))
         Do While !SW8->(EOF()) .and. SW8->W8_FILIAL==cFilSW8 .and. SW8->W8_HAWB==cHawb
            If Empty(SW8->W8_AC)
               aNcm[nAscan,7] := .F.
               Exit
            EndIf
            SW8->(dbSkip())
         EndDo
         SW8->(dbSetOrder(nIndSW8))
         SW8->(dbGoTo(nRecSW8))
         
         
         nRatIPD   := DITRANS(SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-SW8->W8_DESCONT+SW8->W8_FRETEIN,2)
         nRatIPD_RS:= DITRANS(nRatIPD*nParidade,2)

         //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
         SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))
         If SW9->W9_FREINC=="1"
            nFreInv := CalcPesoDesp("FI")
         Else
            nFreInv := 0
         EndIf
         
         SW7->(DbSeek(cFilSW7+SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)))
         aNcm[nAscan,3]+=(SW8->(W8_QTDE*W8_PRECO)*nParidade)+nRatIPD_RS
         aNcm[nAscan,4]+=SW8->W8_QTDE*SW7->W7_PESO

         nFobAto+=SW8->(W8_QTDE*W8_PRECO)*nParidade+nRatIPD_RS - nFreInv
         nPesoAto+=SW8->W8_QTDE*SW7->W7_PESO

         nCalcFob:=(SW8->(W8_QTDE*W8_PRECO)*nParidade)+nRatIPD_RS - nFreInv
         nCalcPeso:=SW8->W8_QTDE*SW7->W7_PESO

         If SYQ->(DBSEEK(xFilial("SYQ")+SW6->W6_VIA_TRA))
            cViaTra:= LEFT(SYQ->YQ_COD_DI,1)
         EndIf

         If (nPos:=aScan(aFrete,{|x| x[1]==SW8->W8_HAWB })) = 0

            nPesoTot := CalcPesoDesp("P")
            nDespesa := CalcPesoDesp("D")
            nDespArm := CalcPesoDesp("A")
            
            If cMoeRel = 1 //US$
               If SW6->W6_SEGMOED = "US$"
                  nSeguro:=SW6->W6_VL_USSE
                  //** AAF 27/10/05 - Rateio deve ser feito em R$ utilizando tx. da invoice.
                  //nSeguroTot:=(nCalcFob/(SW6->W6_FOB_TOT/nTxUSD))*nSeguro
                  nSeguroTot:=(nCalcFob*SW9->W9_TX_FOB/SW6->W6_FOB_TOT)*nSeguro
                  //** 
               Else
                  nSeguro:=ConvVal(SW6->W6_SEGMOED,SW6->W6_VL_USSE,SW6->W6_DTREG_D)
                  //** AAF 27/10/05 - Rateio deve ser feito em R$ utilizando tx. da invoice.
                  //nSeguroTot:=(nCalcFob/(SW6->W6_FOB_TOT/nTxUSD))*nSeguro
                  nSeguroTot:=(nCalcFob*SW9->W9_TX_FOB/SW6->W6_FOB_TOT)*nSeguro
                  //**
               EndIf
            Else
               nSeguro:=SW6->W6_VLSEGMN
               nSeguroTot:=(nCalcFob/SW6->W6_FOB_TOT)*nSeguro
            Endif         

            nFrete:= ValorFrete(SW6->W6_HAWB,"US$",SW6->W6_DTREG_D,If(cMoeRel=1,3,1),)
            aAdd(aFrete,{SW8->W8_HAWB,nPesoTot,nFrete,nDespesa,nDespArm})
            nFreteTot  +=(SW8->W8_QTDE*SW7->W7_PESO/nPesoTot)*nFrete
            //nDespTot   +=nDespesa
            //nDespArTot +=nDespArm                           
         Else
            nFreteTot +=(SW8->W8_QTDE*SW7->W7_PESO/aFrete[nPos,2])*aFrete[nPos,3]
            //nDespTot  +=aFrete[nPos,4]
            //nDespArTot+=aFrete[nPos,5]
            nDespesa := aFrete[nPos,4]
            nDespArm := aFrete[nPos,5]
         EndIF
         
         /*
         If cMoeRel = 1
            If SW6->W6_SEGMOED = "US$"
               nSeguro:=SW6->W6_VL_USSE
               nSeguroTot+=(nCalcFob/(SW6->W6_FOB_TOT/nTxUSD))*nSeguro
            Else
               nSeguro:=ConvVal(SW6->W6_SEGMOED,SW6->W6_VL_USSE,SW6->W6_DTREG_D)
               nSeguroTot+=(nCalcFob/(SW6->W6_FOB_TOT/nTxUSD))*nSeguro
            EndIf
         Else
            nSeguro:=SW6->W6_VLSEGMN
            nSeguroTot+=(nCalcFob/SW6->W6_FOB_TOT)*nSeguro
         Endif
         */
         
         SYD->(DbSeek(cFilSYD+SW8->W8_TEC+SW8->W8_EX_NCM+SW8->W8_EX_NBM))
         AAdd(aNroDi,{SW8->W8_HAWB,SW6->W6_DI_NUM,SW8->W8_COD_I,SW8->W8_TEC,nCalcFob,nCalcPeso,0,SW8->W8_POSICAO,nFrete,nSeguro,0,0,cViaTra,lSuspensao,lIntermediario,SW8->W8_AC,SW8->W8_PO_NUM,nDespesa,nDespArm,0,0,0,nSeguroTot,SW8->W8_VLRPIS*nParidade,SW8->W8_VLRCOF*nParidade,SYD->YD_RED_PIS,SYD->YD_RED_COF,SW8->W8_QTDE,0,0,SW8->W8_INVOICE})

         nCalcFob:=nCalcPeso:=nCalcFAto:=nCalcPAto:=nVlProc:=nSeguroTot:=0

         SW8->(DbSkip())

      EndDo
//*************************************************************************************************************
//Dados do ED8
      //If lDiExt   NOPADO POR AOM - 04/11/10

         cProc:= Space(Len(ED8->ED8_DI_NUM))
         cItem:=Space(Len(ED8->ED8_COD_I))
         ED8->(DBSEEK(cFilED8+ED0->ED0_AC))
         Do While ED8->(!Eof()) .And. ED8->ED8_FILIAL+ED8->ED8_AC==cFilED8+ED0->ED0_AC      
            oDlgProc:SetText(STR0005) //"Realizado"
            IncProc(STR0001+ED0->ED0_AC) //"Ato Concessorio "
            nCont++
            If nCont>nRegua
               ProcRegua(nRegua)
               nCont:=0
            EndIF
            
            If ( nAscan:=Ascan(aNcm,{|a|a[1]==ED8->ED8_NCM .and. a[6]==ED8->ED8_COD_I}))==0
               ED8->(Dbskip())
               Loop
            Endif
            
            nTxUSD:= ED8->ED8_TX_USS
            nParidade:= If(cMoeRel == 1,1,ED8->ED8_TX_USS)//1         
            nRecED8 := ED8->(RecNo())
            nIndED8 := ED8->(IndexOrd())
            cHawb   := ED8->ED8_DI_NUM
            /*
            ED8->(dbSetOrder(4))
            
            ED8->(dbSeek(cFilED8+cHawb))
            Do While !ED8->(EOF()) .and. ED8->ED8_FILIAL==cFilED8 .and. ED8->ED8_HAWB==cHawb
               If Empty(ED8->ED8_AC)
                  aNcm[nAscan,7] := .F.
                  Exit
               EndIf
               ED8->(dbSkip())
            EndDo
            ED8->(dbSetOrder(nIndED8))
            ED8->(dbGoTo(nRecED8))
            */
            nRatIPD   := DITRANS(ED8->ED8_INLAND+ED8->ED8_PACKIN+ED8->ED8_OUTDES-ED8->ED8_DESCNT,2)
            nRatIPD_RS:= DITRANS(nRatIPD*nParidade,2)
            
            aNcm[nAscan,3]+=(ED8->ED8_VALEMB*nParidade)+nRatIPD_RS
            
            aNcm[nAscan,4]+=ED8->ED8_QTD*ED8->ED8_PESO
            
            nFobAto+=(ED8->ED8_VALEMB*nParidade)+nRatIPD_RS
            nPesoAto+=ED8->ED8_QTD*ED8->ED8_PESO
            
            nCalcFob:=((ED8->ED8_VALEMB*nParidade)+nRatIPD_RS)
            nCalcPeso:=ED8->ED8_QTD*ED8->ED8_PESO
         
            If (nPos:=aScan(aFrete,{|x| x[1]==ED8->ED8_DI_NUM })) = 0
               /*
               If SYQ->(DBSEEK(xFilial("SYQ")+SW6->W6_VIA_TRA))
                  cViaTra:= LEFT(SYQ->YQ_COD_DI,1)
               EndIf
               */
               nPesoTot :=ED8->ED8_QTD*ED8->ED8_PESO //CalcPesoDesp("P")
               nDespesa :=ED8->ED8_MRCDES/If(cMoeRel == 2,1,ED8->ED8_TX_USS) //CalcPesoDesp("D")
               nDespArm :=ED8->ED8_ARMDES/If(cMoeRel == 2,1,ED8->ED8_TX_USS) //CalcPesoDesp("A")
               
               If nDespesa > 0
                  cViaTra := "1"
               Else
                  cViaTra := "4"
               EndIf
               
               nSeguro:=ED8->ED8_SEGURO
               nSeguroTot:=(nCalcFob/ED8->ED8_VALEMB)*nSeguro
               
               nFrete:=ED8->ED8_FRETE*nParidade  //ValorFrete(SW6->W6_HAWB,"US$",SW6->W6_DTREG_D,If(cMoeRel=1,3,1),)
               aAdd(aFrete,{ED8->ED8_DI_NUM,nPesoTot,nFrete,nDespesa,nDespArm})
               nFreteTot  +=(ED8->ED8_QTD*ED8->ED8_PESO/nPesoTot)*nFrete
            Else
               nFreteTot +=(ED8->ED8_QTD*ED8->ED8_PESO/aFrete[nPos,2])*aFrete[nPos,3]
               nDespesa := aFrete[nPos,4]
               nDespArm := aFrete[nPos,5]
               If nDespesa > 0
                  cViaTra := "1"
               Else
                  cViaTra := "4"
               EndIf
            EndIF
            
            SYD->(DbSeek(cFilSYD+ED8->ED8_NCM)) 
            IF lMV_PIS_EIC
                //SW8->W8_VLRPIS*nParidade
                //SW8->W8_VLRCOF*nParidade
                nPisVal:=0
                nCofVal:=0
            else
                nPisVal:=0
                nCofVal:=0
            endif
            AAdd(aNroDi,{ED8->ED8_DI_NUM,ED8->ED8_DI_NUM,ED8->ED8_COD_I,ED8->ED8_NCM,nCalcFob,nCalcPeso,0,ED8->ED8_POSDI,nFrete,nSeguro,0,0,cViaTra,lSuspensao,lIntermediario,ED8->ED8_AC,"",nDespesa,nDespArm,0,0,0,nSeguroTot,nPisVal,nCofVal,SYD->YD_RED_PIS,SYD->YD_RED_COF,ED8->ED8_QTD,0,0,ED8->ED8_INVOIC})
            nCalcFob:=nCalcPeso:=nCalcFAto:=nCalcPAto:=nVlProc:=nSeguroTot:=0
            
            ED8->(DbSkip())         
         EndDo
      //EndIf
//*************************************************************************************************************
      If lPrim
         nCont:= 1
      Else
         nCont:= nContAux+1
      Endif

      For Ni:= nCont to Len(aNroDi)
         nIndFor:=Ni
         SYD->(DbSeek(cFilSYD+aNroDi[nIndFor,4]))

         nTxII  :=SYD->YD_PER_II
         nTxIPI :=SYD->YD_PER_IPI
         nTxICMS:=SYD->YD_ICMS_RE
         nTxPIS :=SYD->YD_PER_PIS
         nTxCOF :=SYD->YD_PER_COF
         
         nPos:=aScan(aFrete,{|x| x[1]==aNroDi[nIndFor,1] })
         //aNroDi[nIndFor,7]:=aNroDi[nIndFor,5]+(aNroDi[nIndFor,6]/nPesoAto)*aFrete[nPos,3]/*nFreteTot*/+(aNroDi[nIndFor,5]/nFobAto)*nSeguroTot
         aNroDi[nIndFor,7]:=aNroDi[nIndFor,5]+(aNroDi[nIndFor,6]/aFrete[nPos,2])*aFrete[nPos,3]/*nFreteTot*/+aNroDi[nIndFor,23]
         //If(aNroDi[nIndFor,13]=="1", aNroDi[nIndFor,11]:= (((aNroDi[nIndFor,6]/nPesoAto)*nFreteTot+(aNroDi[nIndFor,6]/nPesoAto)*nDespTot)*25)/100, aNroDi[nIndFor,11]:=0)
         //If(aNroDi[nIndFor,13]=="4", aNroDi[nIndFor,12]:= (aNroDi[nIndFor,5]/nFobAto)*nDespArTot, aNroDi[nIndFor,12]:=0 )
         //If(aNroDi[nIndFor,13]=="1", aNroDi[nIndFor,11]:= (((aNroDi[nIndFor,6]/nPesoAto)*aFrete[nPos,3]/*nFreteTot*/+(aNroDi[nIndFor,6]/nPesoAto)*aNroDi[nIndFor,18])*25)/100, aNroDi[nIndFor,11]:=0)
         If(aNroDi[nIndFor,13]=="1", aNroDi[nIndFor,11]:= ((((aNroDi[nIndFor,6] / aFrete[nPos,2]) * aFrete[nPos,3]) + ((aNroDi[nIndFor,6] / aFrete[nPos,2]) * aNroDi[nIndFor,18])) * 25) / 100 , aNroDi[nIndFor,11]:=0) /*nFreteTot*/
         If(aNroDi[nIndFor,13]=="4", aNroDi[nIndFor,12]:= (aNroDi[nIndFor,5]/nFobAto)*aNroDi[nIndFor,19], aNroDi[nIndFor,12]:=0 )
         lPrim:=.F.
         
         //*** GFP - 24/08/2011 - Substitui valores calculados inseridos pelo usuario na tabela ED8.
         ED8->(DbSeek(cFilED8+aNroDi[nIndFor,16]+aNroDi[nIndFor,17]))
                       
         If ED8->(FieldPos("ED8_VLII")) > 0 .AND. !Empty(ED8->ED8_VLII)
            aNroDi[nIndFor,20] := ED8->ED8_VLII
         Else
            aNroDi[nIndFor,20] := (aNroDi[nIndFor,7]*nTxII)/100                 //(nVlCIF*nTxII)/100
         EndIf
      
         If ED8->(FieldPos("ED8_VLIPI")) > 0 .AND. !Empty(ED8->ED8_VLIPI)
            aNroDi[nIndFor,21] := ED8->ED8_VLIPI 
         Else
            aNroDi[nIndFor,21] := ((aNroDi[nIndFor,7]+aNroDi[nIndFor,20])*nTxIPI)/100 //((nVlCIF+Work->WKR_II)*nTxIPI)/100
         EndIf
         //*** Fim GFP - 24/08/2011
         
         If aNroDi[nIndFor,24] > 0
            aNroDi[nIndFor,29] := aNroDi[nIndFor,24]
            aNroDi[nIndFor,30] := aNroDi[nIndFor,25]
         ElseIf lMV_PIS_EIC
            IF SB1->(DbSeek(xFilial("SB1")+aNroDi[nIndFor,3])) .AND. !EMPTY(SB1->B1_TAB_IPI)
               EI6->(DBSEEK(xFilial("EI6")+SB1->B1_TAB_IPI))
               nVlrIPIEsp:=aNroDi[nIndFor,28]*EI6->EI6_IPIUNI
            EndIf
         
            //*** GFP - 24/08/2011 - Substitui valores calculados inseridos pelo usuario na tabela ED8.
            If ED8->(FieldPos("ED8_VLRPIS")) > 0 .AND. !Empty(ED8->ED8_VLRPIS)
               aNroDi[nIndFor,29] := ED8->ED8_VLRPIS
            Else
               aNroDi[nIndFor,29] := DI500PISCalc(aNroDi[nIndFor,7],aNroDi[nIndFor,18],(nTxII/100),(nTxIPI/100),(nTxICMS/100),(nTxPIS/100),(nTxCOF/100),(aNroDi[nIndFor,26]/100),0) * (nTxPIS/100)
            EndIf
                  
            If ED8->(FieldPos("ED8_VLRCOF")) > 0 .AND. !Empty(ED8->ED8_VLRCOF)  
               aNroDi[nIndFor,30] := ED8->ED8_VLRCOF
            Else
               aNroDi[nIndFor,30] := DI500PISCalc(aNroDi[nIndFor,7],aNroDi[nIndFor,18],(nTxII/100),(nTxIPI/100),(nTxICMS/100),(nTxPIS/100),(nTxCOF/100),(aNroDi[nIndFor,27]/100),0) * (nTXCOF/100)
            EndIf
            //*** Fim GFP - 24/08/2011
         EndIf
         
         //** PLB 05/02/07 - Correção do cálculo do ICMS
         //If aNroDi[nIndFor,14] .and. !aNroDi[nIndFor,15]
            //aNroDi[nIndFor,22]:=((aNroDi[nIndFor,7]+aNroDi[nIndFor,20]+aNroDi[nIndFor,21])*nTxICMS) / 100
         //EndIf
         
         //*** GFP - 24/08/2011 - Substitui valores calculados inseridos pelo usuario na tabela ED8.
         If ED8->(FieldPos("ED8_VLICMS")) > 0 .AND. !Empty(ED8->ED8_VLICMS)
            aNroDi[nIndFor,22] := ED8->ED8_VLICMS
         Else
            aNroDi[nIndFor,22] := ( ( aNroDi[nIndFor,7]+aNroDi[nIndFor,20]+aNroDi[nIndFor,21] ;
                                     +aNroDi[nIndFor,29]+aNroDi[nIndFor,30])                  ;
                                     / (100 - nTxICMS ) ) * nTxICMS
            */
            // AAF 08/05/2017 - Substituido calculo especifico pelo calculo do EICDI154.
            aNroDi[nIndFor,22] := DI154CalcICMS(,1,nTxICMS,,aNroDi[nIndFor,7],0,,aNroDi[nIndFor,20],aNroDi[nIndFor,21],.T.,aNroDi[nIndFor,29],aNroDi[nIndFor,30],,) * (nTxICMS/100)

            //NCF - 28/06/2017 - Caso seja Drawback Isenção/Intermediário, o ganho com ICMS é a redução do valor pago por ocasião de suspensão dos outros impostos que compõem a base de cálculo deste ICMS.
            If !aNroDi[nIndFor,14] .Or. aNroDi[nIndFor,15]
               aNroDi[nIndFor,22] := aNroDi[nIndFor,22] - ( ( aNroDi[nIndFor,7] / ( 100 - nTxICMS ) ) * nTxICMS )
            Endif
         EndIf
        
         If(ED8->(FieldPos("ED8_MRCDES")) > 0 .AND. !Empty(ED8->ED8_MRCDES), aNroDi[nIndFor,11] := ED8->ED8_MRCDES,) //AFRMM
          
         If(ED8->(FieldPos("ED8_ARMDES")) > 0 .AND. !Empty(ED8->ED8_ARMDES), aNroDi[nIndFor,12] := ED8->ED8_ARMDES,) //Armazenagem
         //*** Fim GFP - 24/08/2011
   
         If cTipo = 1
            nSomaAffrm += aNroDi[nIndFor,11]
            nSomaArmaz += aNroDi[nIndFor,12]
            nTotII     += aNroDi[nIndFor,20]
            nTotIPI    += aNroDi[nIndFor,21]
            nTotICMS   += aNroDi[nIndFor,22]
            nTotPIS += aNroDi[nIndFor,29]
            nTotCOF += aNroDi[nIndFor,30]
         Endif
         
         //** AAF 27/10/05 - Ponto de Entrada para Calculos customizados.
         If(EasyEntryPoint("EDCGA150"),Execblock("EDCGA150",.F.,.F.,"APOS_CALC_IMPOSTOS"),)
         //**
         
      Next nIndFor

      nContAux:= Len(aNroDi)
      
      /*

      For nInd:=1 To Len(aNcm)

         Work->(DbSeek(aNcm[nInd,5]+aNcm[nInd,1]+aNcm[nInd,6]))

         SYD->(DbSeek(cFilSYD+Work->WKNCM))

         nTxII  :=SYD->YD_PER_II
         nTxIPI :=SYD->YD_PER_IPI
         nTxICMS:=SYD->YD_ICMS_RE
         nVlCIF :=aNcm[nInd,3]+(aNcm[nInd,4]/nPesoAto)*nFreteTot+(aNcm[nInd,3]/nFobAto)*nSeguroTot

         Work->WKR_II    :=(nVlCIF*nTxII)/100
         Work->WKR_IPI   :=((nVlCIF+Work->WKR_II)*nTxIPI)/100

         nTotII    +=Work->WKR_II
         nTotIPI   +=Work->WKR_IPI

         If lSuspensao .and. !lIntermediario
            Work->WKR_ICMS:=((nVlCIF+Work->WKR_II+Work->WKR_IPI)*nTxICMS) / 100
            nTotICMS+=Work->WKR_ICMS
         Endif

      Next
      */
      
      WORK_TOT->(DBSEEK(ED0->ED0_PD))
      WORK_TOT->WKR_II    :=Round(nTotII,2)
      WORK_TOT->WKR_IPI   :=Round(nTotIPI,2)
      WORK_TOT->WKR_ICMS  :=Round(nTotICMS,2)
      WORK_TOT->WKR_AFRMM :=Round(nSomaAffrm,2)
      WORK_TOT->WKR_PIS   :=Round(nTotPIS,2)
      WORK_TOT->WKR_COF   :=Round(nTotCOF,2)
      WORK_TOT->WKR_ARMAG :=Round(nSomaArmaz,2)

   ENDIF

   ED0->(DBSKIP())
EndDo

SWN->(dbSetOrder(1))

WORK->(DBGOTOP())

IF WORK->(EasyRecCount())==0
   Help(" ",1,"EICSEMREG")
   RETURN .F.
ENDIF

RETURN .T.

*---------------------------*
FUNCTION GA150PRINT()
*---------------------------*
LOCAL cDesc1         := STR0006 //"Este programa tem como objetivo imprimir relatorio "
LOCAL cDesc2         := STR0007 //"Relatorio Ganhos com o Ato Concessorio"
LOCAL cDesc3         := "", cPict := "", imprime := .T.
PRIVATE titulo       := STR0008 //"Ganhos com o Ato Concessorio"
PRIVATE nLin         := 80, Cabec1 :=IF(cTipo=1,STR0009,STR0010),Cabec2:="" //"SINTETICO"###"ANALITICO"
PRIVATE cString      := IF(cTipo=1,"WORK_TOT","WORK"), lEnd := .F.
PRIVATE lAbortPrint  := .F., limite := 220, tamanho := "G"
PRIVATE nomeprog     := "EDCGA150", nTipo := 18
PRIVATE aReturn      := {STR0011, 1,STR0012, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
PRIVATE nLastKey     := 0, cbtxt := Space(10), cbcont := 00
PRIVATE CONTFL       := 01, m_pag := 01
PRIVATE wnrel        := "EDCGA150" // Coloque aqui o nome do arquivo usado para impressao em disco
PRIVATE lImprime     := .F.
wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

If DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFinal) <> "31/12/99"
   Cabec1+= Space(175)+STR0033+DTOC(dDtIni)+STR0034+DTOC(dDtFinal) //"Período de "###" até "
ElseIf DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFinal) = "31/12/99"
   Cabec1+= Space(175)+STR0035+DTOC(dDtIni)  //"Período - desde "
ElseIf DTOC(dDtIni) = "01/01/50" .And. DTOC(dDtFinal) <> "31/12/99"
   Cabec1+= Space(175)+STR0036+DTOC(dDtFinal)  //"Período - até "
Else
   Cabec1+= Space(175)+STR0037  //"Período de __/__/__ até __/__/__"
Endif

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|lEnd| lImprime:=GA150Imprime(wnRel,cString)})
If(lImprime, EDCGAGERADBF(), )

Return .T.

*------------------------*
FUNCTION GA150Imprime()
*------------------------*
Local nLinTot:=58,cRelPed:="",cNCM:="",cItem:="", cFilSB1:=xFilial("SB1"), lTemDi:= .F.
Local  nTotAFRMM:=0, nTotARM:=0, nInd
Local cPictProc:=AVSX3("W6_HAWB",6), cPictPon:=AVSX3("W8_PO_NUM",6)
Local cPictDi:=AVSX3("W6_DI_NUM",6), cPictPos:=AVSX3("W8_POSICAO",6)
Local cPictInv:=AVSX3("W8_INVOICE",6)
Private lLimpaView:= .T., cPictAFRMM:="@E 999,999,999.99", cPictPIS:=StrTran( AVSX3("W8_VLRPIS",6),",","" ) , cPictCOF:=StrTran( AVSX3("W8_VLRCOF",6),",","" )
Private cPictNCM:=AVSX3("ED4_NCM",6),cPictII :=AVSX3("W8_VLII",6)
Private cPicIPI :=AVSX3("W8_VLIPI",6),cPictICMS:=AVSX3("W8_VLICMS",6)
Private cPictFret:=AVSX3("W8_FRETEIN",6),cPictSeg:=AVSX3("W8_VLSEGMN",6)

Private nCol:=03, nCol1:=nCol+23, nCol2:=nCol1+25, nCol3:=nCol2+24, nCol4:=nCol3+23, nCol5:=nCol4+16
Private nCol6:=nCol5+17, nCol7:=nCol6+25, nCol8:=nCol7+27, nCol9:=nCol8+26, nCo20:=nCol9+24
Private nCo21:=nCo20+18, nCo22:=nCol9+19, nCol10:=01+25, nCol11:=nCol10+27, nCol12:=nCol11+25
Private nCol13:=nCol12+20, nCol14:=nCol13+16, nCol15:=nCol14+17, nCol16:=nCol15+27, nCol17:=nCol16+29
Private nCol18:=nCol17+27, nCol19:=nCol18+25, nCol20:=nCol19+16, nCol21:=nCol20+17

PRIVATE R_Campos:={;
                {"WKP_II"  ,,STR0013  ,cPictII},; //"II Prev."
                {"WKP_IPI" ,,STR0014,cPicIPI,},; //"IPI Prev."
                {"WKP_ICMS",,STR0015,cPictICMS},; //"ICMS Prev."
                {"WKP_AFRMM",,STR0054,cPictAFRMM},; //"AFRMM Prev."
                {"WKP_PIS",,STR0055,cPictAFRMM},; //"PIS Prev."
                {"WKP_COF",,STR0056,cPictAFRMM},; //"COFINS Prev."
                {"WKR_II"  ,,STR0019  ,cPictII},; //"II Realiz."
                {"WKR_IPI" ,,STR0020,cPicIPI,},; //"IPI Realiz."
                {"WKR_ICMS",,STR0021,cPictICMS},; //"ICMS Realiz."
                {"WKR_AFRMM" ,,STR0024,cPictAFRMM},; //"AFRMM Realiz."
                {"WKR_PIS",,STR0057,cPictAFRMM},; //"PIS Realiz."
                {"WKR_COF",,STR0058,cPictAFRMM},; //"COFINS Realiz."
                {"WKR_ARMAG" ,,STR0029,cPictAFRMM}} //"Armazenagem" 

Private R_Campos2:={{"WKP_TOTPR"  ,,"Tot Prev."  ,cPictII},; //"II Prev."
                {"WKR_TOTRE" ,,"Tot Real.",cPicIPI,}} //"IPI Prev.              

PRIVATE num_campos:=LEN(R_Campos),SpcCol,SpcIni, lWork
PRIVATE b_pos :={|valor,ind| T_Len[ind+1,2]:=T_Len[ind,2]+T_Len[ind,1]+SpcCol}
PRIVATE b_lin :={|valor,ind| GA150LER(R_Campos,ind)}, nIPI, nII, nICMS, nPIS, nCOF
PRIVATE b_lin2 :={|valor,ind| GA150LER(R_Campos2,ind)}
PRIVATE TotLen:=0, Linha:=99, l_tag:=0, T_Len[num_campos][2]
Private z //LRL 22/04/04 
R_Campos:=E_CriaRCampos(R_Campos)
AEVAL(R_Campos, b_lin)
AEVAL(R_Campos2, b_lin)
Len_Rel:= TotLen+num_campos-1
SpcCol := INT( ( Len_Rel - TotLen ) / (num_campos-1)  )
SpcCol := IF(SpcCol<1,1,SpcCol)
SpcIni := INT( ( Len_Rel - TotLen - SpcCol * ( num_campos - 1 ) ) / 2 )
SpcIni := IF( SpcIni < 1.OR.SpcIni>=2 , 1 , SpcIni )
T_Len[1,2]:=SpcIni
AEVAL(T_Len,b_pos,,num_campos-1)
nLin := 99
cPictAC :=AVSX3("ED0_AC",6)
cPictPD :=AVSX3("ED0_PD",6)

cAliasRep:=IF(cTipo=1,"WORK_TOT","WORK")

SB1->(dbSetOrder(1))

SetRegua( (cAliasRep)->(EasyRecCount()))   // Total de elementos da regua
(cAliasRep)->(DBGOTOP())
lInicio:= .T.
lBateRod:= .F.

DO WHILE (cAliasRep)->(!EOF())
   
   lCabec:= .F.   

   If cTipo = 2
      nSomaAffrm:= 0
      nSomaArmaz:= 0
      nTotII    := 0     
      nTotIPI   := 0
      nTotICMS  := 0
      nTotPIS   := 0
      nTotCOF   := 0
   Endif
   
   lTemDi:= .F.
   lWork:= .T.

   If nLin >nLinTot
       
      Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
      nLin:=08      
   
      If cRelPed<>(cAliasRep)->WKPD .And. !lInicio
         GA150CABEC("I")
         lBateRod:= .T.
         If cTipo = 2            
            GA150RODAPE()
         EndIf
      Endif

      GA150CABEC(If(lBateRod,"Q",))

      lBateRod:=.F.
      lCabec:= .T.
      lInicio:= .F.
   Endif

   If cRelPed<>(cAliasRep)->WKPD
      If cTipo = 2 .And. nLin <> 08 .And. !lCabec
         nLin -= 2
         GA150RODAPE()
      EndIf
      //Aqui
      If(!lCabec, GA150CABEC("Q"), )
      cRelPed:=(cAliasRep)->WKPD
      
   Endif  
   
   IF SB1->(dbSeek(cFilSB1+(cAliasRep)->WKITEM)) .AND. SB1->B1_IMPORT <> "N" //LRS 26/04/2014 - Descrição quando item é importado ou nacional
     cItem := "Item Import."
   else
     cItem := "Item Nacion." 
   End IF  		  

   IF cTipo=2 .And. cNCM<>(cAliasRep)->WKNCM
      nLin++
      SB1->(dbSeek(cFilSB1+(cAliasRep)->WKITEM))
      @nLin,01 PSAY STR0025+Trans((cAliasRep)->WKNCM,AVSX3("ED4_NCM",6))+Space(3)+;//AVSX3("ED4_ITEM",5)+; //"N.C.M.: " # "Item"
      				cItem+; //LRS 26/04/2014 - Variavel que define a descrição do tipo de item
                    " "+Alltrim((cAliasRep)->WKITEM)+" - "+Alltrim(SB1->B1_DESC)+"     "+;
                    "II: "+Alltrim(Trans((cAliasRep)->WKR_TXII,AVSX3("WN_IITX",6)))+;
                    "%   IPI: "+Alltrim(Trans((cAliasRep)->WKR_TXIPI,AVSX3("WN_IPITX",6)))+;
                    "%   ICMS: "+Alltrim(Trans((cAliasRep)->WKR_TXICMS,AVSX3("YD_ICMS_RE",6)))+;
                    "%   PIS: "+Alltrim(Trans((cAliasRep)->WKR_TXPIS,AVSX3("YD_PER_PIS",6)))+;
                    "%   COF: "+Alltrim(Trans((cAliasRep)->WKR_TXCOF,AVSX3("YD_PER_COF",6)))+"%"
      nLin++
   ENDIF

   IF cTipo=2 //Analítico
      For nInd:= 1 to Len(aNroDi)
         z:=nInd  //LRL 22/04/04
         If (cAliasRep)->WKAC == aNroDi[z,16] .And. (cAliasRep)->WKNCM == aNroDi[z,4];
         .And. (cAliasRep)->WKITEM == aNroDi[z,3]
            SYD->(DbSeek(xFilial("SYD")+aNroDi[z,4]))
            lTemDi:= .T.
            nLin++
            If nLin>nLinTot
               Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
               nLin:=08
               
               If cRelPed<>(cAliasRep)->WKPD .And. !lInicio
                  GA150CABEC("I")
                  lBateRod:= .T.
                  If cTipo = 2            
                     GA150RODAPE()
                  EndIf
               Endif

               GA150CABEC(If(lBateRod,"Q",))

               lBateRod:=.F.
               lCabec:= .T.
               lInicio:= .F.
               //GA150CABEC()
               //lCabec:= .T.                            
            Endif
            
            nII  := (aNroDi[z,7]*SYD->YD_PER_II)/100
            nIPI := ((aNroDi[z,7]*SYD->YD_PER_II/100 + aNroDi[z,7])*SYD->YD_PER_IPI)/100
            nPIS := aNroDi[z,29]
            nCOF := aNroDi[z,30]
            //** PLB 05/02/07 - Correção do cálculo do ICMS
            //nICMS:= If(aNroDi[z,14] .and. !aNroDi[z,15],((aNroDi[z,7]+nII+nIPI)*SYD->YD_ICMS_RE)/100, 0)
            nICMS := ( ( aNroDi[z,7]+nII+nIPI+nPIS+nCOF ) / (100-SYD->YD_ICMS_RE) ) * SYD->YD_ICMS_RE
            If !aNroDi[z,14]  .Or.  aNroDi[z,15]
               nICMS := nICMS - ( ( aNroDi[z,7] / ( 100 - SYD->YD_ICMS_RE ) ) * SYD->YD_ICMS_RE )
            EndIf
            //**

            @nLin,02 PSAY STR0038+Transf(aNroDi[z,1],cPictProc)+Space(02)+STR0039+Transf(aNroDi[z,2],cPictDi)+; //"Processo: "###"D.I.: "
            Space(02)+STR0051+Transf(aNroDi[z,17],cPictPon)+Space(02)+STR0040+Transf(aNroDi[z,8], cPictPos)+;//+; //"PO "###"Posicao: "
            Space(02)+STR0063+Transf(aNroDi[z,31], cPictInv)//"Invoice: "
            
            /* //LRS 27/06/2014 - Duplicando as linhas do relatorios
            @nLin,103 PSAY Transf(Round(nII,2)  , cPictII)
            @nLin,122 PSAY Transf(Round(nIPI,2) , cPicIPI)
            @nLin,141 PSAY Transf(Round(nICMS,2), cPictICMS)
            @nLin,160 PSAY Transf(Round(aNroDi[z,11],2), cPictAFRMM)
            @nLin,174 PSAY Transf(Round(aNroDi[z,29],2), cPictPIS)
            @nLin,189 PSAY Transf(Round(aNroDi[z,30],2), cPictCOF)
            @nLin,205 PSAY Transf(Round(aNroDi[z,12],2), cPictAFRMM)
            */
            
            nSomaAffrm+=aNroDi[z,11]
            nSomaArmaz+=aNroDi[z,12]
            nTotII    +=aNroDi[z,20]
            nTotIPI   +=aNroDi[z,21]
            nTotICMS  +=aNroDi[z,22]
            nTotPIS   +=aNroDi[z,29]
            nTotCOF   +=aNroDi[z,30]
            
            //O Layout do Arq. de Muro foi feito para o Rel. Analítico
            lWork:= .F.
            If(EasyEntryPoint("EDCGA150"),Execblock("EDCGA150",.F.,.F.,"Grv_Muro"),)

            //Usado para a Geração do DBF
            EDCGAGRVWORK()

         Endif
      Next z
   Endif
   
   IF cTipo=2 
   
	IF SB1->(dbSeek(xFilial("SB1")+(cAliasRep)->WKITEM)) .AND. SB1->B1_IMPORT <> "N"  //LRS
      (cAliasRep)->WKR_AFRMM := Round(nSomaAffrm,2)
      (cAliasRep)->WKR_II    := Round(nTotII,2)
    EndIF
      
      (cAliasRep)->WKR_ARMAG := Round(nSomaArmaz,2)
      (cAliasRep)->WKR_IPI   := Round(nTotIPI,2)
      (cAliasRep)->WKR_ICMS  := Round(nTotICMS,2)
      (cAliasRep)->WKR_PIS   := Round(nTotPIS,2)
      (cAliasRep)->WKR_COF   := Round(nTotCOF,2)
   
      WORK_TOT->(DBSEEK((cAliasRep)->WKPD))
      WORK_TOT->WKR_AFRMM+= (cAliasRep)->WKR_AFRMM //nTotAFRMM
      WORK_TOT->WKR_ARMAG+= (cAliasRep)->WKR_ARMAG //nTotArm
      WORK_TOT->WKR_II   += (cAliasRep)->WKR_II
      WORK_TOT->WKR_IPI  += (cAliasRep)->WKR_IPI
      WORK_TOT->WKR_ICMS += (cAliasRep)->WKR_ICMS
      WORK_TOT->WKR_PIS   += (cAliasRep)->WKR_PIS
      WORK_TOT->WKR_COF   += (cAliasRep)->WKR_COF
      
      WORK_TOT->WKR_TOTRE +=(cAliasRep)->WKR_II+(cAliasRep)->WKR_IPI +(cAliasRep)->WKR_ICMS+;
                            (cAliasRep)->WKR_AFRMM+(cAliasRep)->WKR_PIS+(cAliasRep)->WKR_COF+(cAliasRep)->WKR_ARMAG


      
      If lTemDi
         nLin+=2
      Endif

   Endif

   //O Layout do Arq. de Muro foi feito para o Rel. Analítico
   IF cTipo=2 .And. lWork
      If(EasyEntryPoint("EDCGA150"),Execblock("EDCGA150",.F.,.F.,"Grv_Muro"),)

      //Usado para a Geração do DBF
      EDCGAGRVWORK()
   Endif
   
   l_tag:=say_det
   AEVAL(R_CAMPOS, b_lin)
   nLin+=2
   (cAliasRep)->(DBSKIP())
ENDDO

If cTipo = 2
   nLin -= 2
   GA150RODAPE()
EndIf

If cTipo = 2 .And. Empty(cPedido)
   SOMARODAPE()
Endif

nLin++
@nLin,03 PSAY " "

If(EasyEntryPoint("EDCGA150"),Execblock("EDCGA150",.F.,.F.,"Fecha_View"),)

SET PRINTER TO
COMMIT
OURSPOOL(wnrel)

MS_FLUSH()

RETURN .T.

*----------------------------*
FUNCTION GA150CABEC(cParam)
*----------------------------*
cMoedaRel := If(cMoeRel=1,cMoeDolar,"R$")

If cParam == "I"
   Work->(dbSkip(-1))
Endif                

If nLin > 58
   Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
   nLin:=08
   /*
   l_tag:=say_tit
   AEVAL(R_CAMPOS, b_lin)

   nLin++
   l_tag:=say_rep
   AEVAL(R_CAMPOS, b_lin)
   nLin++
   */
Endif

@nLin,0 PSAY __PrtThinLine()
nLin++
@nLin,1 PSAY __PrtLeft(STR0032+Transf((cAliasRep)->WKPD,cPictPD)+Space(05)+STR0026+;
Transf((cAliasRep)->WKAC,cPictAc)+Space(05)+STR0027+(cAliasRep)->WKTIPO)+; //"Ato Concessório: "
Space(05)+STR0030+Alltrim(cMoedaRel) //"Pedido: "###"  Tipo: "#" Moeda: "
nLin++
@nLin,0 PSAY __PrtThinLine()
nLin++

If cParam <> "Q" //Quando a Quebra não for no meio da Página.
   l_tag:=say_tit
   AEVAL(R_CAMPOS, b_lin)

   nLin++
   l_tag:=say_rep
   AEVAL(R_CAMPOS, b_lin)
   nLin++
Endif

If cParam == "I"
   Work->(dbSkip(1))
Endif           

RETURN .T.

*----------------------------------------------------------------------------
FUNCTION GA150LER(R_Campos,lin)
*----------------------------------------------------------------------------
LOCAL  valor, tipo_val, c_len, alinhamento
STATIC savevalor
PRIVATE xVal:=R_Campos[lin,1]

valor:= IF(l_tag = say_tit, R_Campos[lin,2] , IF(xVal<>NIL,IF(ValType(xVal)#"B",&(xVal),Eval(xVal)),' ') )
savevalor:=IF(TotLen=0," ",savevalor)

IF l_tag = say_det .OR. l_tag = say_tit
   alinhamento:=R_Campos[lin,3]
   DO CASE
      CASE alinhamento = "D"
           valor:=PADL(valor,T_Len[lin,1])
      CASE alinhamento = "C"
           valor:=PADC(valor,T_Len[lin,1])
      OTHERWISE
           valor:=PADR(valor,T_Len[lin,1])
   ENDCASE

   IF l_tag = say_det .AND. AT("*",alinhamento) # 0
      IF valor == savevalor .AND. nLin # 7
         RETURN NIL
      ELSE
         savevalor:=valor
      ENDIF
   ENDIF

   @ nLin,T_Len[lin,2] PSAY valor
   RETURN NIL
ENDIF

IF l_tag = say_rep
   @ nLin,T_Len[lin,2] PSAY REPL("=",T_Len[lin,1])
   RETURN NIL
ENDIF

tipo_val:= VALTYPE(valor)

DO CASE
   CASE tipo_val = "C"
        c_len:=LEN(valor)
   CASE tipo_val = "D"
        // *** CAF 07/04/1999 - Datas com ano de 4 digitos
        IF IsYear4()
           c_len := 10
        Else
           c_len:= 8
        Endif
   CASE tipo_val = "N"
        c_len:= LEN(STR(valor))
   OTHERWISE
        c_len:= 0
ENDCASE

Totlen+= ( T_Len[lin,1]:=MAX( c_len, LEN(R_CAMPOS[lin,2]) ) )

RETURN NIL

*-------------------------*
FUNCTION GA150CriaWork()
*-------------------------*
Private aWork
Private aDbfStru:={;
                   {"WKAC"    ,"C",AVSX3("ED0_AC",3)   ,0},;
                   {"WKPD"    ,"C",AVSX3("ED0_PD",3)   ,0},;
                   {"WKTIPO"  ,"C",10,0},;
                   {"WKNCM"   ,"C",AVSX3("ED4_NCM",3),0},;
                   {"WKITEM"  ,"C",AVSX3("ED4_ITEM",3),0},;
                   {"WKP_II"  ,"N",AVSX3("W8_VLII",3),AVSX3("W8_VLII",4)},;
                   {"WKP_IPI" ,"N",AVSX3("W8_VLIPI",3),AVSX3("W8_VLIPI",4)},;
                   {"WKP_ICMS","N",AVSX3("W8_VLICMS",3),AVSX3("W8_VLICMS",4)},;                   
                   {"WKP_AFRMM","N",AVSX3("W7_AFRMM",3)-2,AVSX3("W8_FRETEIN",4)},;
                   {"WKP_PIS","N",AVSX3("W8_VLRPIS",3),AVSX3("W8_VLRPIS",4)},;
                   {"WKP_COF","N",AVSX3("W8_VLRCOF",3),AVSX3("W8_VLRCOF",4)},;
                   {"WKR_II"  ,"N",AVSX3("W8_VLII",3),AVSX3("W8_VLII",4)},;
                   {"WKR_TXII"  ,"N",AVSX3("WN_IITX",3),AVSX3("WN_IITX",4)},;
                   {"WKR_IPI" ,"N",AVSX3("W8_VLIPI",3),AVSX3("W8_VLIPI",4)},;
                   {"WKR_TXIPI" ,"N",AVSX3("WN_IPITX",3),AVSX3("WN_IPITX",4)},;
                   {"WKR_ICMS","N",AVSX3("W8_VLICMS",3),AVSX3("W8_VLICMS",4)},;
                   {"WKR_TXICMS","N",AVSX3("YD_ICMS_RE",3),AVSX3("YD_ICMS_RE",4)},;
                   {"WKR_AFRMM" ,"N",AVSX3("W7_AFRMM",3)-2,AVSX3("W8_FRETEIN",4)},;
                   {"WKR_PIS","N",AVSX3("W8_VLRPIS",3),AVSX3("W8_VLRPIS",4)},;
                   {"WKR_TXPIS","N",AVSX3("W8_PERPIS",3),AVSX3("W8_PERPIS",4)},;
                   {"WKR_COF","N",AVSX3("W8_VLRCOF",3),AVSX3("W8_VLRCOF",4)},;
                   {"WKR_TXCOF","N",AVSX3("W8_PERCOF",3),AVSX3("W8_PERCOF",4)},;
                   {"WKR_ARMAG" ,"N",AVSX3("W7_AFRMM",3)-2,AVSX3("W8_FRETEIN",4)},;
                   {"WKP_TOTPR" ,"N",AVSX3("W9_FOB_TOT",3),AVSX3("W9_FOB_TOT",4)},;
                   {"WKR_TOTRE" ,"N",AVSX3("W9_FOB_TOT",3),AVSX3("W9_FOB_TOT",4)}}

aWork:= aClone(aDbfStru)
/*
{"WKP_SEGURO","N",AVSX3("W8_VLSEGMN",3),AVSX3("W8_VLSEGMN",4)},;
{"WKP_FRETE" ,"N",AVSX3("W8_FRETEIN",3),AVSX3("W8_FRETEIN",4)},;
{"WKR_SEGURO","N",AVSX3("W8_VLSEGMN",3),AVSX3("W8_VLSEGMN",4)},;
{"WKR_FRETE" ,"N",AVSX3("W8_FRETEIN",3),AVSX3("W8_FRETEIN",4)},;                   
*/                   

AADD(aWork,{"WKMOEDA"  ,"C",3,0})
AADD(aWork,{"WKDESC"   ,"C",AVSX3("B1_DESC",3),0})
AADD(aWork,{"WKPROC"   ,"C",AVSX3("W6_HAWB",3),0})
AADD(aWork,{"WKNRODI"  ,"C",AVSX3("W6_DI_NUM",3),0})
AADD(aWork,{"WKNROPO"  ,"C",AVSX3("W8_PO_NUM",3),0})
AADD(aWork,{"WKPOSICA" ,"C",AVSX3("W8_POSICAO",3),0})
                   
Private aCampos:={},aHeader:={}
If(EasyEntryPoint("EDCGA150"),Execblock("EDCGA150",.F.,.F.,"Work"),)
Procregua(2)

If Select("WORK") > 0
   Work->( dbCloseArea() )
EndIf

cNomArq:=E_CriaTrab(,aDbfStru,"WORK")

If !USED()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
Endif

IncProc(STR0028+"1")  //"Criando Arquivo Temporario "
IndRegua("Work",cNomArq+TEOrdBagExt(),"WKPD+WKNCM+WKITEM")

cNomArq1:=E_CriaTrab(,aDbfStru,"WORK_TOT")
cNomArq2:=E_CriaTrab(,aDbfStru,"W_ULTPAG")
cFileDbf:=E_CriaTrab(,aWork,"TRB")

If !USED()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
Endif

IncProc(STR0028+"2")  //"Criando Arquivo Temporario "
IndRegua("Work_TOT",cNomArq1+TEOrdBagExt(),"WKPD")
IndRegua("W_ULTPAG",cNomArq2+TEOrdBagExt(),"WKPD")
IndRegua("TRB",cFileDbf+TEOrdBagExt(),"WKPD+WKNCM+WKITEM")

Return .T.

*---------------------------*
Static Function GA150RODAPE()
*---------------------------*
(cAliasRep)->(dbSkip(-1))
WORK_TOT->(dbSeek((cAliasRep)->WKPD))
dbSelectArea("WORK_TOT")

If nLin+2 > 58
   Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
   nLin:=08
Endif

nLin++
@nLin,01 PSAY STR0031 //"Totais"
nLin++

l_tag:=say_det
AEVAL(R_CAMPOS, b_lin)
nLin+=2


nLin++
@nLin,01 PSAY STR0064 //"Total Prev."
@nLin,20 PSAY STR0065 //"Total Real."
nLin++

l_tag:=say_det
AEVAL(R_CAMPOS2, b_lin2)
nLin+=2

If Empty(cPedido)
   If lVez
      W_ULTPAG->(dbAppend())
      lVez:= .F.
   Endif
   
   W_ULTPAG->WKP_II    +=WORK_TOT->WKP_II
   W_ULTPAG->WKP_IPI   +=WORK_TOT->WKP_IPI
   W_ULTPAG->WKP_ICMS  +=WORK_TOT->WKP_ICMS
   W_ULTPAG->WKP_AFRMM +=WORK_TOT->WKP_AFRMM
   W_ULTPAG->WKP_PIS   +=WORK_TOT->WKP_PIS
   W_ULTPAG->WKP_COF   +=WORK_TOT->WKP_COF
   W_ULTPAG->WKR_II    +=WORK_TOT->WKR_II
   W_ULTPAG->WKR_IPI   +=WORK_TOT->WKR_IPI
   W_ULTPAG->WKR_ICMS  +=WORK_TOT->WKR_ICMS
   W_ULTPAG->WKR_AFRMM +=WORK_TOT->WKR_AFRMM
   W_ULTPAG->WKR_PIS   +=WORK_TOT->WKR_PIS
   W_ULTPAG->WKR_COF   +=WORK_TOT->WKR_COF
   W_ULTPAG->WKR_ARMAG +=WORK_TOT->WKR_ARMAG

   W_ULTPAG->WKR_TOTRE +=WORK_TOT->WKR_II+WORK_TOT->WKR_IPI +WORK_TOT->WKR_ICMS+WORK_TOT->WKR_AFRMM+WORK_TOT->WKR_PIS+WORK_TOT->WKR_COF+WORK_TOT->WKR_ARMAG
   W_ULTPAG->WKP_TOTPR +=WORK_TOT->WKP_II+WORK_TOT->WKP_IPI+WORK_TOT->WKP_ICMS+WORK_TOT->WKP_AFRMM+WORK_TOT->WKP_PIS+WORK_TOT->WKP_COF
   
Endif

dbSelectArea(cAliasRep)
(cAliasRep)->(dbSkip())

Return .T.

*--------------------------------*
Static Function EDCGA150RATEIO()
*--------------------------------*
Local nRecno, cFilED2:= xFilial("ED2")
nRecno:= ED2->(Recno())
nCalPeso:= 0
ED2->(dbSeek(cFilED2+ED0->ED0_PD))
While !ED2->(EOF()) .And. ED2->ED2_FILIAL == cFilED2 .And. ED2->ED2_PD == ED0->ED0_PD
   nCalPeso+= ED2->ED2_PESO
   ED2->(dbSkip())
EndDo
ED2->(dbGoto(nRecno))
nRateio:= ED2->ED2_PESO/nCalPeso

Return .T.

*-----------------------------------------------------------------------------------*
Static Function CalcPesoDesp(cParam)
*-----------------------------------------------------------------------------------*
Local nValAux:=0, nVlArm:=0, nRecW7:=SW7->(RecNo()), nOrdW7:=SW7->(IndexOrd())
Local nRecaux, nOrdAux, nAux:=0

If cParam == "P"
   SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB))
   DO WHILE SW7->(!EOF()) .AND. SW7->W7_HAWB == SW8->W8_HAWB   .AND.;
   SW7->W7_FILIAL  == cFilSW7
      nValAux += (SW7->W7_QTDE*SW7->W7_PESO)
      SW7->(dbSkip())
   EndDo

   SW7->(dbSetOrder(nOrdW7))
   SW7->(dbGoTo(nRecW7))
ElseIf cParam == "FI"
   nRecAux:=SW8->(RecNo())
   nOrdAux:=SW8->(IndexOrd())
   SW8->(dbSetOrder(1))
   SW8->(dbSeek(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN))
   Do While !SW8->(EOF()) .and. SW8->W8_FILIAL==cFilSW8 .and. SW8->W8_HAWB==SW9->W9_HAWB .and.;
   SW8->W8_INVOICE==SW9->W9_INVOICE .and. SW8->W8_FORN==SW9->W9_FORN
      SW7->(DbSeek(cFilSW7+SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)))
      nAux += SW8->W8_QTDE * SW7->W7_PESO
      SW8->(dbSkip())
   EndDo
   SW8->(dbSetOrder(nOrdAux))
   SW8->(dbGoTo(nRecAux))
   SW7->(DbSeek(cFilSW7+SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)))
   nValAux := ((SW8->W8_QTDE*SW7->W7_PESO) / nAux) * SW9->W9_FRETEIN
Else
   SWD->(Dbseek(cFilSWD+SW8->W8_HAWB))
   Do While SWD->(!EOF()) .And. SWD->(WD_FILIAL+WD_HAWB)==cFilSWD+SW8->W8_HAWB
      If SWD->WD_DESPESA $ cDesp
         If (!Empty(dDtIni) .and. SWD->WD_DES_ADI >= dDtIni) .or.;
         (!Empty(dDtFinal) .and. SWD->WD_DES_ADI <= dDtFinal)
            If cMoeRel = 1
               If cParam=="A" .And. SWD->WD_DESPESA == "403" //If SWD->WD_DESPESA == cDespArm .And. cParam=="A"   //Para Armazenagem
                  nVlArm+=SWD->WD_VALOR_R/nTxUSD
               ElseIf SWD->WD_DESPESA <> cDespArm
                  nValAux+=SWD->WD_VALOR_R/BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI,.T.,.F.,.T.) //nTxUSD  //Para AFRRM
               Endif
            Else
               If cParam=="A" .And. SWD->WD_DESPESA == "403" //If SWD->WD_DESPESA == cDespArm .And. cParam=="A"    //Para Armazenagem
                  nVlArm+=SWD->WD_VALOR_R
               ElseIf SWD->WD_DESPESA <> cDespArm
                  nValAux+=SWD->WD_VALOR_R         //Para AFRRM
               Endif
            EndIf
         EndIf
      Endif
      SWD->(DbSkip())
   EndDo
Endif
Return If(cParam == "A", nVlArm, nValAux)

*----------------------------*
Static Function SOMARODAPE()
*----------------------------*

// LOCAL nCo21:=nCo20+18,  nCo20:=nCol9+24   -- ACSJ - 01/12/2004 - Variavel não é usada.

dbSelectArea("W_ULTPAG")

Cabec2:= Space(92)+STR0050 //"Somatória de todos os Atos Concessórios"

Cabec(titulo,Cabec1,cabec2,wnrel,Tamanho,nTipo)
nLin:=09

@nLin,nCol  PSAY STR0041 //"Total I.I. Prev."
@nLin,nCol1 PSAY STR0042 //"Total I.P.I. Prev."
@nLin,nCol2 PSAY STR0043 //"Total I.C.M.S. Prev."
@nLin,nCol3 PSAY STR0044 //"Total AFRMM Prev."
@nLin,nCol4 PSAY STR0059 //"Total PIS Prev."
@nLin,nCol5 PSAY STR0060 //"Total COF. Prev."
@nLin,nCol6 PSAY STR0045 //"Total I.I. Realiz."
@nLin,nCol7 PSAY STR0046 //"Total I.P.I. Realiz."
@nLin,nCol8 PSAY STR0047 //"Total I.C.M.S. Realiz."
@nLin,nCol9 PSAY STR0048 //"Total AFRMM Realiz."
@nLin,nCo20 PSAY STR0061 //"Total PIS Realiz."
@nLin,nCo21 PSAY STR0062 //"Total COF. Realiz."
@nLin,nCo22 PSAY STR0049 //"Total Armaz. Realiz."
nLin++

@nLin,nCol  PSAY Repli("-", Len(STR0041)) //"Total I.I. Prev."
@nLin,nCol1 PSAY Repli("-", Len(STR0042)) //"Total I.P.I. Prev."
@nLin,nCol2 PSAY Repli("-", Len(STR0043)) //"Total I.C.M.S. Prev."
@nLin,nCol3 PSAY Repli("-", Len(STR0044)) //"Total AFRMM Prev."
@nLin,nCol4 PSAY Repli("-", Len(STR0059)) //"Total PIS Prev."
@nLin,nCol5 PSAY Repli("-", Len(STR0060)) //"Total COF. Prev."
@nLin,nCol6 PSAY Repli("-", Len(STR0045)) //"Total I.I. Realiz."
@nLin,nCol7 PSAY Repli("-", Len(STR0046)) //"Total I.P.I. Realiz."
@nLin,nCol8 PSAY Repli("-", Len(STR0047)) //"Total I.C.M.S. Realiz."
@nLin,nCol9 PSAY Repli("-", Len(STR0048)) //"Total AFRMM Realiz."
@nLin,nCo20 PSAY Repli("-", Len(STR0061)) //"Total PIS Realiz."
@nLin,nCo21 PSAY Repli("-", Len(STR0062)) //"Total COF. Realiz."
@nLin,nCo22 PSAY Repli("-", Len(STR0049)) //"Total Armaz. Realiz."
nLin++

@nLin,01  PSAY Transf(W_ULTPAG->WKP_II, cPictII)
@nLin,nCol10 PSAY Transf(W_ULTPAG->WKP_IPI, cPicIPI)
@nLin,nCol11 PSAY Transf(W_ULTPAG->WKP_ICMS, cPictICMS)
@nLin,nCol12 PSAY Transf(W_ULTPAG->WKP_AFRMM, cPictAFRMM)
@nLin,nCol13 PSAY Transf(W_ULTPAG->WKP_PIS, cPictPIS)
@nLin,nCol14 PSAY Transf(W_ULTPAG->WKP_COF, cPictCOF)
@nLin,nCol15 PSAY Transf(W_ULTPAG->WKR_II, cPictII)
@nLin,nCol16 PSAY Transf(W_ULTPAG->WKR_IPI, cPicIPI)
@nLin,nCol17 PSAY Transf(W_ULTPAG->WKR_ICMS, cPictICMS)
@nLin,nCol18 PSAY Transf(W_ULTPAG->WKR_AFRMM, cPictAFRMM)
@nLin,nCol19 PSAY Transf(W_ULTPAG->WKR_PIS, cPictPIS)
@nLin,nCol20 PSAY Transf(W_ULTPAG->WKR_COF, cPictCOF)
@nLin,nCol21 PSAY Transf(W_ULTPAG->WKR_ARMAG, cPictAFRMM)

Return .T.

*--------------------*
Function GA150VALID()
*--------------------*
Local lRet:= .T.

IF !Empty(mv_par02)
   If !ExistCpo('SYB',mv_par02)     
      lRet:= .F.
   Endif
Endif   

If !Empty(MV_PAR02) .And. lRet

   Do Case
      Case MV_PAR02 <> cVarAux .And. Empty(cVarAux)
         cVarAux  := MV_PAR02
      Case MV_PAR02 <> cVarAux1 .And. Empty(cVarAux1)
         cVarAux1:= MV_PAR02
         If cVarAux1 == cVarAux
            Help(" ",1,"AVG0005293") //Msginfo("Escolha outra despesa, pois essa já foi selecionada!","Informação")
            cVarAux1:=""
            lRet:= .F.               
         Endif   
      Case MV_PAR02 <> cVarAux2 .And. Empty(cVarAux2)
         cVarAux2:= MV_PAR02
         If cVarAux2 == cVarAux1 .Or. cVarAux2 == cVarAux      
            Help(" ",1,"AVG0005293") //Msginfo("Escolha outra despesa, pois essa já foi selecionada!","Informação")
            cVarAux2:=""
            lRet:= .F.
         Endif
      Case MV_PAR02 <> cVarAux3 .And. Empty(cVarAux3)
         cVarAux3:= MV_PAR02
         If cVarAux3 == cVarAux2 .Or. cVarAux3 == cVarAux1 .Or. cVarAux3 == cVarAux
            Help(" ",1,"AVG0005293") //Msginfo("Escolha outra despesa, pois essa já foi selecionada!","Informação")
            cVarAux3:=""
            lRet:= .F.
         Endif
      Case MV_PAR02 <> cVarAux4 .And. Empty(cVarAux4)
         cVarAux4:= MV_PAR02
         If cVarAux4 == cVarAux3 .Or. cVarAux4 == cVarAux2 .Or. cVarAux4 == cVarAux1 .Or.;
            cVarAux4 == cVarAux
            Help(" ",1,"AVG0005293") //Msginfo("Escolha outra despesa, pois essa já foi selecionada!","Informação")
            cVarAux4:=""
            lRet:= .F.
         Endif
      Case MV_PAR02 <> cVarAux5 .And. Empty(cVarAux5)
         cVarAux5:= MV_PAR02
         If cVarAux5 == cVarAux4 .Or. cVarAux5 == cVarAux3 .Or. cVarAux5 == cVarAux2 .Or.;
            cVarAux5 == cVarAux1 .Or. cVarAux5 == cVarAux
            Help(" ",1,"AVG0005293") //Msginfo("Escolha outra despesa, pois essa já foi selecionada!","Informação")
            cVarAux5:=""
            lRet:= .F.
         Endif         
   EndCase

   cCont:= cVarAux+"/"+If(!Empty(cVarAux1),cVarAux1+"/","")+If(!Empty(cVarAux2),cVarAux2+"/","")+;
           If(!Empty(cVarAux3),cVarAux3+"/","")+If(!Empty(cVarAux4),cVarAux4+"/","")+;
           If(!Empty(cVarAux5),cVarAux5+"/","")

   MV_PAR03        := cCont

Endif

Return lRet

*-----------------------------*
Static Function EDCGAGRVWORK()
*-----------------------------*
TRB->(dbAppend())

TRB->WKPD      := (cAliasRep)->WKPD
TRB->WKAC      := (cAliasRep)->WKAC
TRB->WKTIPO    := (cAliasRep)->WKTIPO
TRB->WKMOEDA   := cMoedaRel
TRB->WKNCM     := (cAliasRep)->WKNCM
TRB->WKITEM    := (cAliasRep)->WKITEM
TRB->WKDESC    := Alltrim(SB1->B1_DESC)

IF SB1->(dbSeek(xFilial("SB1")+(cAliasRep)->WKITEM)) .AND. SB1->B1_IMPORT <> "N" //LRS 27/06/2014 - Caso o Item sejá nacional, não imprimir
	TRB->WKR_TXII  := (cAliasRep)->WKR_TXII
	TRB->WKP_II    := (cAliasRep)->WKP_II
	TRB->WKP_AFRMM := (cAliasRep)->WKP_AFRMM
	TRB->WKR_II    := If(lWork, (cAliasRep)->WKR_II, nII )
	TRB->WKR_AFRMM := If(lWork, (cAliasRep)->WKR_AFRMM, aNroDi[z,11] )
ENDIF

TRB->WKR_TXIPI := (cAliasRep)->WKR_TXIPI
TRB->WKR_TXICMS:= (cAliasRep)->WKR_TXICMS
TRB->WKR_TXPIS := (cAliasRep)->WKR_TXPIS
TRB->WKR_TXCOF := (cAliasRep)->WKR_TXCOF

TRB->WKP_IPI   := (cAliasRep)->WKP_IPI
TRB->WKP_ICMS  := (cAliasRep)->WKP_ICMS

TRB->WKP_PIS   := (cAliasRep)->WKP_PIS
TRB->WKP_COF   := (cAliasRep)->WKP_COF

TRB->WKR_IPI   := If(lWork, (cAliasRep)->WKR_IPI, nIPI )
TRB->WKR_ICMS  := If(lWork, (cAliasRep)->WKR_ICMS, nICMS )

TRB->WKR_PIS   := If(lWork, (cAliasRep)->WKR_PIS, nPIS )
TRB->WKR_COF   := If(lWork, (cAliasRep)->WKR_COF, nCOF )
TRB->WKR_ARMAG := If(lWork, (cAliasRep)->WKR_ARMAG, aNroDi[z,12] )

If !lWork
   TRB->WKPROC   := aNroDi[z,1]  //Processo
   TRB->WKNRODI  := aNroDi[z,2]  //Nro. DI
   TRB->WKNROPO  := aNroDi[z,17] //PO
   TRB->WKPOSICA := aNroDi[z,8]  //Posição
Endif
 
Return .T.

*------------------------------*
Static Function EDCGAGERADBF()
*------------------------------*
Local oDlg, nOp:=0, oCbx, lRet:= .T.
Private cGera:=Space(1), aGera:={"1 - Sim","2 - Não"}

DEFINE MSDIALOG oDlg TITLE STR0052; //"Geração de Arquivo DBF/TXT"
       FROM 12,05 To 20,45 OF GetwndDefault()

   @01,04 SAY STR0053 of oDlg //"Gera Arquivo"
   cGera := "1"
   @01,09 ComboBox oCbx Var cGera Items aGera Valid (!Empty(cGera)) SIZE 52,08 of oDlg

   DEFINE SBUTTON FROM 40,45 TYPE 13 ACTION (nOp:=1,oDlg:End()) ENABLE OF oDlg //Salvar Arq.
   DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg  //Cancel

ACTIVATE MSDIALOG oDlg CENTERED

If nOp = 1 .And. Left(cGera,1)=="1"
   If(cTipo=2, TR350ARQUIVO("TRB"), TR350ARQUIVO("Work_Tot"))
Else
   lRet:= .F.
EndIf

Return lRet

//LGS-30/05/2014 - Efetua a data de corte para gerar o relatorio de ganhos com AC.
*--------------------------------------------------------------*
FUNCTION EDCGADTCORTE(dDataIni,dDataFim,cFilSW6,cFilSF1,lDataNF)
*--------------------------------------------------------------*
Local lRet := .F.

Begin Sequence
	If !Empty(dDataIni) .AND. !Empty(dDataFim)
	   If SW8->(DbSeek(cFilSW8+ED0->ED0_AC))           
	      If !lDataNF //Data Corte DI   	 
	      	 If !SW6->( dbSeek(cFilSW6+SW8->W8_HAWB) ) .OR. Empty(SW6->W6_DTREG_D)
	            lRet := .T.
	            Break
	      	 EndIf
	      	 If ( SW6->W6_DTREG_D < dDtIni   ) .OR.;
	            ( SW6->W6_DTREG_D > dDtFinal )
	              lRet := .T.
	              Break
	         EndIf
	      Else //Data Corte NF
	      	 SF1->( dbSeek(cFilSF1+SW8->W8_HAWB+"1") )
	      	 If ( SF1->F1_EMISSAO < dDtIni  ) .OR.;
	         	( SF1->F1_EMISSAO > dDtFinal)
	           	  lRet := .T.
	           	  Break
	      	 Endif
	      EndIf
	   Else
	   	  lRet := .T.
	   EndIf
	EndIf   
End Sequence

Return lRet