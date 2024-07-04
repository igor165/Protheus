#INCLUDE "EFFEX401.ch" 
#INCLUDE "AVERAGE.ch"
#INCLUDE "TOPCONN.CH"

#define VISUALIZAR 2
#define INCLUIR    3
#define ALTERAR    4
#define ESTORNAR   5

#define MOEDA_REAIS     "R$ "
#define ACC             "01"
#define ACE             "02"
#define PRE_PAGTO       "03"
#define SECURITIZACAO   "04"
#define EV_PRINC        "100"
#define EV_PRINC2       "101"
#define EV_EMBARQUE     "600"
#define EV_PJ           "520"
#define EV_EST_PJ       "510"  //525
#define EV_TJ           "650"
#define EV_VC_PJ1       "550"
#define EV_VC_PJ2       "569"
#define EV_JUR_CNT      "620"  //NCF - 07/01/2015
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
#define EV_EST_JR_ANT   "690"  //Estorno de Pagamento de Juros antecipado
// **
#define EV_ENC_PRC      "180"  //AAF - 01/11/05 - Encerramento.
#define EV_TRANS_PRC    "190"  //AAF - 01/11/05 - Transferência.

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define FINAL_ENCHOICE MEIO_DIALOG-1
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define FINAL_SELECT   (oDlg:nClientHeight-6)/2

#define ORDEM_BROWSE    8

#define EXP "E"
#define IMP "I"

/*
Programa        : EFFEX401.PRW
Objetivo        : Manutenção do Financiamento da Exportação
Autor           : Gustavo Carreiro
Data/Hora       :
*/

// ** GFC - Pré-Pagamento/Securitização.
*------------------------------------------------------------------------------------------------------*
Function EX401Recalc(nQtComprom, nVlComprom,lCalcVencto,lCalcPrinc,lPergunta)
*------------------------------------------------------------------------------------------------------*
Local dDtVenc:=M->EF1_DT_JUR, ni:=0, cSeqEF3, nMes:=0, nAno:=0, aParcelas:={}
Local aTx_Jr:={}, nValJuros:=0, aJuros:={}, nInd:=0, nx, dDtFim:=AvCtoD(""), nPos, nz
Local nValPrinc:=0, nt, nTotalParc:=0, lPrinc:=.T., nParcPr:=1, aParcJr:={}, nParcJr:=1
Local lIncParc:=.T., aCodJur:={}
Local aSaiJur:={}, dDtVencAux:=AvCtoD("")
Local aParcJrAux:={}, nParcPrAux:=1, nPosAux, aParcPrAux:={}
Local nValPrincAux := 0, nPosValPriAux := 0, nValTotAux:=0, nQtdParcAux:=0
Local nResiduo := 0
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Local nDecTaxa  := AVSX3("EF3_TX_MOE",4)
Default lCalcVencto:= .T.
Default lCalcPrinc := .T.
Default lPergunta  := .T.

WorkEF3->( DBSetOrder(2) )

// ** PLB 26/10/06 - nQtComprom -> Quant de parcelas já comprometidas (vinculadas e/ou liquidadas)
//                  nVlComprom -> Valor de parcelas já comprometidas (vinculadas e/ou liquidadas)
If nQtComprom == NIL  .Or.  nVlComprom == NIL
   nQtComprom := 0
   nVlComprom := 0
   If cMod == IMP
      If WorkEF3->( DBSeek(EV_PRINC_PREPAG) )
         Do While !WorkEF3->( EoF() )  .And.  WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG
            If WorkEF3->EF3_TX_MOE > 0
               nQtComprom += 1
               nVlComprom += WorkEF3->EF3_VL_MOE
            EndIf
            WorkEF3->( DBSkip() )
         EndDo
      EndIf
   Else
      If WorkEF3->( DBSeek(EV_PRINC_PREPAG) )
         Do While !WorkEF3->( EoF() )  .And.  WorkEF3->EF3_CODEVE = EV_PRINC_PREPAG
            If WorkEF3->( EF3_TX_MOE > 0  .Or.  EF3_VL_MOE != EF3_SLDVIN )
               nQtComprom += 1
               nVlComprom += WorkEF3->EF3_VL_MOE
            EndIf
            WorkEF3->( DBSkip() )
         EndDo
      EndIf
   EndIf
EndIf
// **

If WorkEF3->(dbSeek(EV_PRINC_PREPAG)) .AND. lPergunta
   lCalcVencto := MsgYesNo(STR0001, STR0117) //# "Deseja recalcular os vencimentos das parcelas?" ##"Aviso"  //FSM - 02/05/2012
   lCalcPrinc  := MsgYesNo(STR0002, STR0117) //# "Deseja recalcular os valores do principal?" ##"Aviso"  //FSM - 02/05/2012
EndIf

ProcRegua(M->EF1_PARCPR+M->EF1_PARCJR)

//Exclui parcelas caso já existam
EX401ExcPrePag("3",.F.,"M","WorkEF3",lCalcVencto,lCalcPrinc)

// ** GFC - 13/02/06
cSeqEF3:=BuscaEF3Seq()
// **

nValTotAux  := M->EF1_VL_MOE
nQtdParcAux := M->EF1_PARCPR

//Parcelas do Principal
For ni:=1 to M->EF1_PARCPR
   IncProc(STR0003+Alltrim(Str(ni))+STR0004) //"Gerando parcela " # " do principal."
   nMes:=0
   nAno:=0
   lIncParc:=.T.
   // ** PLB 26/10/06 - Subtrair a soma das parcelas já comprometidas (vinculadas e/ou liquidadas)
   If nQtComprom > 0  .And.  nVlComprom > 0
      nValPrincAux := ( nValTotAux - nVlComprom ) / ( nQtdParcAux - nQtComprom )
   Else
      nValPrincAux := (nValTotAux / nQtdParcAux)
   EndIf
   // **

   // PLB 26/10/06 - Distribui o residuo de saldo entre as últimas parcelas
   nResiduo := ( nValPrincAux - Round(nValPrincAux,2) ) * ( nQtdParcAux - nQtComprom )
   If ni >= ( nQtdParcAux + 1 - ABS(nResiduo * 100) )
      If nResiduo > 0
         nValPrincAux += 0.01
      ElseIf nResiduo < 0
         nValPrincAux -= 0.01
      EndIf
   EndIf

   If WorkEF3->(dbSeek(EV_PRINC_PREPAG+Space(Len(EF3->EF3_INVOIC))+StrZero(ni,AvSX3("EF3_PARC",3),0)))
      If !lCalcVencto
         dDtVenc := WorkEF3->EF3_DT_EVE
         If WorkEF3->EF3_VL_MOE > 0
            lIncParc:=.F.
            aAdd(aParcPrAux,{WorkEF3->EF3_CODEVE, Val(WorkEF3->EF3_PARC)})
         EndIf
      Else
         If Empty(WorkEF3->EF3_DT_EVE)
            lIncParc := .T.
         Else
            dDtVenc := WorkEF3->EF3_DT_EVE
            lIncParc := .F.
            aAdd(aParcPrAux,{WorkEF3->EF3_CODEVE, Val(WorkEF3->EF3_PARC)})
         EndIf
      EndIf
      If !lCalcPrinc .And. WorkEF3->EF3_VL_MOE > 0         // VI
         nValPrincAux := (WorkEF3->EF3_VL_MOE)
         nValTotAux := nValTotAux - WorkEF3->EF3_VL_MOE
         nQtdParcAux := nQtdParcAux - 1
         If !(lCalcVencto .and. Empty(WorkEF3->EF3_DT_EVE))
            nPosValPriAux := aScan(aParcPrAux,{|x| x[1]==WorkEF3->EF3_CODEVE .and. x[2]=Val(WorkEF3->EF3_PARC)})
            lIncParc:=.F.
            If nPosValPriAux = 0
               aAdd(aParcPrAux,{WorkEF3->EF3_CODEVE, Val(WorkEF3->EF3_PARC)})
            EndIf
         EndIf
      EndIf
   EndIf
   If lCalcVencto .and. lIncParc
      If ni = 1
         If M->EF1_TPCAPR = "1"
            dDtVenc += M->EF1_CAREPR
         Else
            nMes := Month(dDtVenc) + M->EF1_CAREPR
            Do While nMes > 12
               nAno += 1
               nMes := nMes - 12
            EndDo
            dDtVenc := AvCtoD(StrZero(Day(dDtVenc),2,0)+"/"+StrZero(nMes,4,0)+"/"+StrZero(Year(dDtVenc)+nAno,4,0))
         EndIf
      Else
         If M->EF1_TPPEPR = "1"
            dDtVenc += M->EF1_PERIPR
         Else
            nMes := Month(dDtVenc) + M->EF1_PERIPR
            Do While nMes > 12
               nAno += 1
               nMes := nMes - 12
            EndDo
            dDtVenc := AvCtoD(StrZero(Day(dDtVenc),2,0)+"/"+StrZero(nMes,4,0)+"/"+StrZero(Year(dDtVenc)+nAno,4,0))
         EndIf
      EndIf
   EndIf
   // ** PLB 23/03/07 - Adiciona em aParcelas os valores das parcelas comprometidas para que o Juros seja calculado corretamente
   If ni <= nQtComprom
      WorkEF3->( DBSeek(EV_PRINC_PREPAG) )
      If ni > 1
         WorkEF3->( DBSkip(ni-1) )
      EndIf
      aAdd(aParcelas,{"1",EV_PRINC_PREPAG,dDtVenc, WorkEF3->EF3_VL_MOE , WorkEF3->EF3_VL_MOE, lIncParc })
   Else
      aAdd(aParcelas,{"1",EV_PRINC_PREPAG,dDtVenc, nValPrincAux , nValPrincAux, lIncParc })
   EndIf
   // **
Next ni

If lEF2_TIPJUR
   aJuros := EX400BusJur("WorkEF2","M")
Else
   aJuros := {"0"}
EndIf

//Parcelas de Juros
dDtVenc := M->EF1_DT_JUR
M->EF1_SLD_JM := 0
For nInd:=1 to M->EF1_PARCJR
   IncProc(STR0003+Alltrim(Str(nInd))+STR0005) //"Gerando parcela " # " do juros."
   nMes:=0
   nAno:=0
   aCodJur  := {}
   For nx:=1 to len(aJuros)
      WorkEF3->(dbSeek(Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx])))+Space(Len(EF3->EF3_INVOIC))+StrZero(nInd,AvSX3("EF3_PARC",3),0)),.T.)
      Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE==Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx]))) .and.;
      WorkEF3->EF3_INVOIC==Space(Len(EF3->EF3_INVOIC)) .and. WorkEF3->EF3_PARC==StrZero(nInd,AvSX3("EF3_PARC",3),0)

         If !lCalcVencto
            If WorkEF3->EF3_VL_MOE > 0
               Aadd(aCodJur,{WorkEF3->EF3_CODEVE,WorkEF3->EF3_DT_EVE,.F.})
               aAdd(aParcJrAux,{WorkEF3->EF3_CODEVE, Val(WorkEF3->EF3_PARC)})
            Else
               Aadd(aCodJur,{WorkEF3->EF3_CODEVE,WorkEF3->EF3_DT_EVE,.T.})
            EndIf
         Else
            Aadd(aCodJur,{WorkEF3->EF3_CODEVE,WorkEF3->EF3_DT_EVE,.F.})
            aAdd(aParcJrAux,{WorkEF3->EF3_CODEVE, Val(WorkEF3->EF3_PARC)})
         EndIf

         WorkEF3->(dbSkip())
      EndDo
   Next nx
   If nInd = 1
      If M->EF1_TPCAJR = "1"
         dDtVenc += M->EF1_CAREJR
      Else
         nMes := Month(dDtVenc) + M->EF1_CAREJR
         Do While nMes > 12
            nAno += 1
            nMes := nMes - 12
         EndDo
         dDtVenc := AvCtoD(StrZero(Day(dDtVenc),2,0)+"/"+StrZero(nMes,4,0)+"/"+StrZero(Year(dDtVenc)+nAno,4,0))
      EndIf
   Else
      If M->EF1_TPPEJR = "1"
         dDtVenc += M->EF1_PERIJR
      Else
         nMes := Month(dDtVenc) + M->EF1_PERIJR
         Do While nMes > 12
            nAno += 1
            nMes := nMes - 12
         EndDo
         dDtVenc := AvCtoD(StrZero(Day(dDtVenc),2,0)+"/"+StrZero(nMes,4,0)+"/"+StrZero(Year(dDtVenc)+nAno,4,0))
      EndIf
   EndIf

   //Ordena as parcelas por Data + Tipo(1-principal ou 2-juros)
   aSort(aParcelas,,, {|x, y| dtos(x[3])+x[1] < dtos(y[3])+y[1] })

   aSaiJur:={}
   dDtVencAux := dDtVenc
   For ni:=Len(aParcelas) to 1 Step -1
      For nx:=1 to len(aJuros)   //Verifica todos os tipos de juros
         If (nPos := aScan(aCodJur,{|x| x[1]==Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx])))})) > 0// .and. aCodJur[nPos,3]
            dDtVenc:=aCodJur[nPos,2]
         Else
            dDtVenc := dDtVencAux
         EndIf
         If (aParcelas[ni,3] < dDtVenc .or. ni=1) .and. aScan(aSaiJur,Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx])))) = 0
            aAdd(aSaiJur,Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx]))))

            //If nPos = 0 .or. aCodJur[nPos,3]
               nValPrinc:=0
               For nz:=ni to 1 Step -1
                  If aParcelas[nz,1] == "1" .and. dDtVenc > aParcelas[nz,3]
                     nValPrinc += aParcelas[nz,4]
                  EndIf
               Next nz

               If aParcelas[ni,1] == "2"
                  aTx_Jr := EX400BusTx(M->EF1_TP_FIN,dDtVenc,aParcelas[ni,3],"M","WorkEF2",aJuros[nx])
                  nValJuros := 0
                  For nz:=1 to If(M->EF1_PERFIX<>0 .and. M->EF1_TPPEJR=="2" .and. Len(aTx_Jr) > 0,1,Len(aTx_Jr))
                     nValJuros += If(M->EF1_PERFIX<>0 .and. M->EF1_TPPEJR=="2",M->EF1_PERFIX,aTx_Jr[nz,2]) * (aTx_Jr[nz,1] / 100) * (M->EF1_VL_MOE - nValPrinc)
                  Next nz
                  aAdd(aParcelas,{"2",Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx]))),dDtVenc, nValJuros , nValJuros , nPos = 0 .or. aCodJur[nPos,3]})
                  If aParcelas[Len(aParcelas)][6]
                     M->EF1_SLD_JM += Round( nValJuros , AvSX3("EF1_SLD_JM",4) )
                  EndIf
               Else
                  dDtFim := dDtVenc
                  nTotalParc := 0
                  lPrinc := .T.
                  For nt:=ni+IIF((aParcelas[ni,3] < dDtVenc),1,0) to 1 Step -1   // PLB 12/06/06 - Adiciona um se a primeira parcela de juros for apos a primeira parcela de pagamento
                     aTx_Jr := EX400BusTx(M->EF1_TP_FIN,If(nt==1 .and. aParcelas[nt,3]<dDtFim .and. lPrinc,aParcelas[nt,3],dDtFim),If(nt==1 .and. lPrinc,M->EF1_DT_JUR,aParcelas[IIF(nt==1,1,nt-1),3]),"M","WorkEF2",aJuros[nx],IF(NT=1,.T.,.F.))  // PLB 12/06/06 - Se estiver calculando o juros da data do primeiro juros ate a data do primeiro principal
                     nValJuros := 0
                     For nz:=1 to If(M->EF1_PERFIX<>0 .and. M->EF1_TPPEJR=="2" .and. Len(aTx_Jr) > 0,1,Len(aTx_Jr))
                        nValJuros += If(M->EF1_PERFIX<>0 .and. M->EF1_TPPEJR=="2",M->EF1_PERFIX,aTx_Jr[nz,2]) * (aTx_Jr[nz,1] / 100) * (M->EF1_VL_MOE - IIF(nt==1,0,nValPrinc))  // PLB 12/06/06 - Calcula sobre o saldo total se estiver calculando o juros da data de inicio de juros ate a data do primeiro principal
                     Next nz
                     nTotalParc += Round(nValJuros,2)
                     If aParcelas[IIF(nt==1,1,nt-1),1] == "2"  // PLB 12/06/06
                        Exit
                     ElseIf nt <> 1  // PLB 12/06/06
                        dDtFim := aParcelas[nt-1,3]
                        nValPrinc -= aParcelas[nt-1,4]
                        If !(aParcelas[nt-1,2] == EV_PRINC_PREPAG)   // PLB 12/06/06
                           lPrinc := .F.
                        EndIf
                     EndIf
                  Next nt
                  aAdd(aParcelas,{"2",Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx]))),dDtVenc, nTotalParc , nTotalParc , nPos = 0 .or. aCodJur[nPos,3]})
                  If aParcelas[Len(aParcelas)][6]
                     M->EF1_SLD_JM += Round( nTotalParc , AvSX3("EF1_SLD_JM",4) )
                  EndIf
               EndIf
            //EndIf
            ni:=Len(aParcelas)
         EndIf
      Next nx
      If Len(aSaiJur) = Len(aJuros)
         Exit
      EndIf
   Next ni
Next nInd
M->EF1_SLD_JR := ( M->EF1_SLD_PR / M->EF1_SLD_PM ) * M->EF1_SLD_JM

//Ordena as parcelas por Data + Tipo(1-principal ou 2-juros) + Código do Evento
aSort(aParcelas,,, {|x, y| dtos(x[3])+x[1]+x[2] < dtos(y[3])+y[1]+y[2] })

//Grava todas as parcelas
For ni:=1 to Len(aParcelas)

   If aParcelas[ni,6]

      If aParcelas[ni,2] == EV_PRINC_PREPAG
         nPosAux := aScan(aParcPrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=nParcPr})
         Do While nPosAux > 0
            nParcPr ++
            nPosAux := aScan(aParcPrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=nParcPr})
         EndDo
         If WorkEF3->(dbSeek(EV_PRINC_PREPAG+Space(Len(EF3->EF3_INVOIC))+StrZero(nParcPr,AvSX3("EF3_PARC",3),0)))
            WorkEF3->(RecLock("WorkEF3",.F.))
         Else
            WorkEF3->(RecLock("WorkEF3",.T.))
         EndIf
      Else
         If (nPos := aScan(aParcJr,{|x| x[1]==aParcelas[ni,2]})) > 0
            nParcJr := aParcJr[nPos,2]
            nPosAux := aScan(aParcJrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=aParcJr[nPos,2]})
            Do While nPosAux > 0
               nParcJr ++
               nPosAux := aScan(aParcJrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=nParcJr})
            EndDo
            aParcJr[nPos,2] := nParcJr + 1
         Else
            nParcJr := 1
            nPosAux := aScan(aParcJrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=nParcJr})
            Do While nPosAux > 0
               nParcJr ++
               nPosAux := aScan(aParcJrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=nParcJr})
            EndDo
            aAdd(aParcJr,{aParcelas[ni,2],nParcJr+1})
         EndIf
         If WorkEF3->(dbSeek(aParcelas[ni,2]+Space(Len(EF3->EF3_INVOIC))+StrZero(nParcJr,AvSX3("EF3_PARC",3),0)))
            WorkEF3->(RecLock("WorkEF3",.F.))
         Else
            WorkEF3->(RecLock("WorkEF3",.T.))
         EndIf
      EndIf
      WorkEF3->EF3_CODEVE := aParcelas[ni,2]
      If (lCalcVencto .and. lCalcPrinc .and. aParcelas[ni,2] == EV_PRINC_PREPAG) .or.;
      (lCalcVencto .and. aParcelas[ni,2] <> EV_PRINC_PREPAG)
         WorkEF3->EF3_SEQ    := cSeqEF3
      EndIf
      WorkEF3->EF3_DT_EVE := aParcelas[ni,3]
      WorkEF3->EF3_MOE_IN := M->EF1_MOEDA
      WorkEF3->EF3_VL_MOE := Round(aParcelas[ni,4],nDecValor)
      WorkEF3->EF3_SLDLIQ := If(cMod <> IMP, Round(aParcelas[ni,5],nDecValor), 0) //AAF 12/04/06 - FINIMP não utiliza este saldo.
      WorkEF3->EF3_SLDVIN := If(cMod <> IMP, WorkEF3->EF3_VL_MOE, 0)                          //AAF 12/04/06 - FINIMP não utiliza este saldo.
      If aParcelas[ni,2] == EV_PRINC_PREPAG
         WorkEF3->EF3_PARC   := StrZero(nParcPr,AvSX3("EF3_PARC",3),0)
      Else
         WorkEF3->EF3_PARC   := StrZero(nParcJr,AvSX3("EF3_PARC",3),0)
      EndIf
      //FSM - 28/03/2012
      WorkEF3->EF3_DESCEV := BuscaDescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)
      WorkEF3->(msUnlock())

      If lCadFin
         EX401GrEncargos("WorkEF3")
      EndIf

      If (lCalcVencto .and. lCalcPrinc .and. aParcelas[ni,2] == EV_PRINC_PREPAG) .or.;
      (lCalcVencto .and. aParcelas[ni,2] <> EV_PRINC_PREPAG)
         cSeqEF3 := StrZero(Val(cSeqEF3) + 1,4,0)
      EndIf
      If(nPosAux=0 .and. aParcelas[ni,2] == EV_PRINC_PREPAG,nParcPr ++,)

   EndIf

Next ni

WorkEF3->(dbSetOrder(ORDEM_BROWSE))
//WorkEF3->(dbGoTop())

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato.
EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

Return .T.

*------------------------------------------------------------------------------------------------------*
Function EX401AltPrePag(nParc,dDtJur,cAliasEF1,cAliasEF3, lCalcPrinc)
// nParc     -> Parcela de juros que foi alterada
// dDtJur    -> Data que deve ser considerada para a parcela de juros alterada
// cAliasEF1 -> Alias para considerar o EF1 (M ou EF1)
// cAliasEF3 -> Alias para considerar o EF3 (WorkEF3 ou EF3)
*------------------------------------------------------------------------------------------------------*
Local dDtVenc:=If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR), ni:=0, nMes:=0, nAno:=0
Local cSeqEF3:=BuscaEF3Seq(cAliasEF3,If(cAliasEF1=="M",M->EF1_CONTRA,(cAliasEF1)->EF1_CONTRA),If(cAliasEF1=="M",M->EF1_BAN_FI,(cAliasEF1)->EF1_BAN_FI),If(cAliasEF1=="M",M->EF1_PRACA,(cAliasEF1)->EF1_PRACA),If(lEFFTpMod,If(cAliasEF1=="M",M->EF1_TPMODU,(cAliasEF1)->EF1_TPMODU),),If(lEFFTpMod,If(cAliasEF1=="M",M->EF1_SEQCNT,(cAliasEF1)->EF1_SEQCNT),))
Local aTx_Jr:={}, nValJuros:=0, aJuros:={}, nInd:=0, nx, dDtFim:=AvCtoD(""), nPos, nz, aParcJr:={}, aParcelas:={}
Local nValPrinc:=0, nt, nTotalParc:=0, lPrinc:=.T., nOldOrd:=(cAliasEF3)->(IndexOrd()), nParcJr:=1
Local aCodJur:={}, lCalcVencto := .T., /*lCalcPrinc := .F.,*/ aParcJrAux:={}, nPosAux, dDtVencAux:=AvCtoD(""), aSaiJur:={}
Local nResiduo := 0 //, nLastParcPr := 1
Local nValPrincAux := 0, nQtdParcAux := 0, aPosPrinc := {}  // PLB 26/10/06

If(nParc=NIL,nParc:=0,)

If cAliasEF3 == "EF3"
   (cAliasEF3)->(dbSetOrder(1))
Else
   (cAliasEF3)->(dbSetOrder(2))
EndIf

lCalcVencto := .F. //NCF - 17/04/2018 - Não recalcular principais e vencimentos na liquidação do Evento 700 
lCalcPrinc  := .F.

ProcRegua(If(cAliasEF1=="M",M->EF1_PARCPR+M->EF1_PARCJR,(cAliasEF1)->EF1_PARCPR+(cAliasEF1)->EF1_PARCJR))

//Deleta as parcelas de juros
EX401ExcPrePag("2",.F.,cAliasEF1,cAliasEF3, lCalcVencto, lCalcPrinc)

//FSM - 19/03/2012
aParcelas := EX401ParcAjusta(aParcelas,lCalcVencto,cAliasEF3)

//Carrega as parcelas do principal p/ o array
(cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+EV_PRINC_PREPAG))
Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3") .and. If(lEFFTpMod,EF3->EF3_TPMODU == (cAliasEF1)->EF1_TPMODU,.T.) .AND.;
EF3->EF3_CONTRA==(cAliasEF1)->EF1_CONTRA .and. EF3->EF3_BAN_FI==(cAliasEF1)->EF1_BAN_FI .and.;
EF3->EF3_PRACA==(cAliasEF1)->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == (cAliasEF1)->EF1_SEQCNT,.T.),.T.) .and. (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG
   If aScan(aParcelas, {|x| x[7] == (cAliasEF3)->(RecNo())} ) == 0
      aAdd(aParcelas,{"1",EV_PRINC_PREPAG,(cAliasEF3)->EF3_DT_EVE,(cAliasEF3)->EF3_VL_MOE,(cAliasEF3)->EF3_VL_MOE,.T.,(cAliasEF3)->(RecNo())})
   EndIf
   (cAliasEF3)->(dbSkip())
EndDo

//Carrega tipos de juros
If lEF2_TIPJUR
   aJuros := EX400BusJur(If(cAliasEF1=="M","WorkEF2","EF2"),cAliasEF1)
Else
   aJuros := {"0"}
EndIf

//Grava Parcelas de Juros
M->EF1_SLD_JM := 0
For nInd:=1 to If(cAliasEF1=="M",M->EF1_PARCJR,(cAliasEF1)->EF1_PARCJR)
   IncProc(STR0003+Alltrim(Str(nInd))+STR0005) //"Gerando parcela " # " do juros."
   nMes:=0
   nAno:=0
   aCodJur  := {}
   For nx:=1 to len(aJuros)
      (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx])))+If(cAliasEF3=="WorkEF3",Space(Len(EF3->EF3_INVOIC)),"")+StrZero(nInd,AvSX3("EF3_PARC",3),0)),.T.)
      Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3") .and. If(lEFFTpMod,EF3->EF3_TPMODU == (cAliasEF1)->EF1_TPMODU,.T.) .AND.;
      EF3->EF3_CONTRA==(cAliasEF1)->EF1_CONTRA .and. EF3->EF3_BAN_FI==(cAliasEF1)->EF1_BAN_FI .and.;
      EF3->EF3_PRACA==(cAliasEF1)->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == (cAliasEF1)->EF1_SEQCNT,.T.),.T.) .and. Left((cAliasEF3)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2) .and.;
      If(cAliasEF3=="WorkEF3",(cAliasEF3)->EF3_INVOIC==Space(Len(EF3->EF3_INVOIC)),.T.) .and.;
      (cAliasEF3)->EF3_PARC==StrZero(nInd,AvSX3("EF3_PARC",3),0)

         If !lCalcVencto
            If (cAliasEF3)->EF3_VL_MOE > 0  .And. IF( AvFlags("EEC_LOGIX"), Empty((cAliasEF3)->EF3_TITFIN) .And. Empty((cAliasEF3)->EF3_SEQBX), .T.)              //NCF - 04/05/2015 - Não recalcular o valor de parcelas com título gerado e liquidado
               Aadd(aCodJur,{(cAliasEF3)->EF3_CODEVE,,.F.})                                                                                                       //                   quando integrado a ERP Externo
               aAdd(aParcJrAux,{(cAliasEF3)->EF3_CODEVE, Val(If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_PARC,(cAliasEF3)->EF3_LINHA))})
            Else
               Aadd(aCodJur,{(cAliasEF3)->EF3_CODEVE,(cAliasEF3)->EF3_DT_EVE,.T.})
            EndIf
         Else
            Aadd(aCodJur,{(cAliasEF3)->EF3_CODEVE,,.F.})
            aAdd(aParcJrAux,{(cAliasEF3)->EF3_CODEVE, Val(If(!lEFFTpMod .OR. (cAliasEF3)->EF3_ORIGEM == "EEQ",(cAliasEF3)->EF3_PARC,(cAliasEF3)->EF3_LINHA))})
         EndIf

         (cAliasEF3)->(dbSkip())
      EndDo
   Next nx
   If nParc > 0 .and. nInd = nParc
      dDtVenc := dDtJur
   Else
      If nInd = 1
         If If(cAliasEF1=="M",M->EF1_TPCAJR,(cAliasEF1)->EF1_TPCAJR) = "1"
            dDtVenc += If(cAliasEF1=="M",M->EF1_CAREJR,(cAliasEF1)->EF1_CAREJR)
         Else
            nMes := Month(dDtVenc) + If(cAliasEF1=="M",M->EF1_CAREJR,(cAliasEF1)->EF1_CAREJR)
            Do While nMes > 12
               nAno += 1
               nMes := nMes - 12
            EndDo
            dDtVenc := AvCtoD(StrZero(Day(dDtVenc),2,0)+"/"+StrZero(nMes,4,0)+"/"+StrZero(Year(dDtVenc)+nAno,4,0))
         EndIf
      Else
         If If(cAliasEF1=="M",M->EF1_TPPEJR,(cAliasEF1)->EF1_TPPEJR) = "1"
            dDtVenc += If(cAliasEF1=="M",M->EF1_PERIJR,(cAliasEF1)->EF1_PERIJR)
         Else
            nMes := Month(dDtVenc) + If(cAliasEF1=="M",M->EF1_PERIJR,(cAliasEF1)->EF1_PERIJR)
            Do While nMes > 12
               nAno += 1
               nMes := nMes - 12
            EndDo
            dDtVenc := AvCtoD(StrZero(Day(dDtVenc),2,0)+"/"+StrZero(nMes,4,0)+"/"+StrZero(Year(dDtVenc)+nAno,4,0))
         EndIf
      EndIf
   EndIf

   //Ordena as parcelas por Data + Tipo(1-principal ou 2-juros)
   aSort(aParcelas,,, {|x, y| dtos(x[3])+x[1] < dtos(y[3])+y[1] })

   aSaiJur:={}
   dDtVencAux := dDtVenc

   For ni:=Len(aParcelas) to 1 Step -1

      For nx:=1 to len(aJuros)   //Verifica todos os tipos de juros
         If (nPos := aScan(aCodJur,{|x| x[1]==Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx])))})) > 0 .and. aCodJur[nPos,3]
            dDtVenc:=aCodJur[nPos,2]
         Else
            dDtVenc := dDtVencAux
         EndIf
         If (aParcelas[ni,3] < dDtVenc .or. ni=1) .and. aScan(aSaiJur,Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx])))) = 0
            aAdd(aSaiJur,Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx]))))

            //If nPos = 0 .or. aCodJur[nPos,3]
               nValPrinc:=0
               For nz:=ni to 1 Step -1
                  If aParcelas[nz,1] == "1" .and. dDtVenc > aParcelas[nz,3]
                     nValPrinc += aParcelas[nz,4]
                  EndIf
               Next nz

               If aParcelas[ni,1] == "2"
                  aTx_Jr := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),dDtVenc,aParcelas[ni,3],cAliasEF1,If(cAliasEF1=="M","WorkEF2","EF2"),aJuros[nx])
                  nValJuros := 0
                  For nz:=1 to If(If(cAliasEF1=="M",M->EF1_PERFIX,(cAliasEF1)->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,(cAliasEF1)->EF1_TPPEJR)=="2",1,Len(aTx_Jr))
                     nValJuros += If(If(cAliasEF1=="M",M->EF1_PERFIX,(cAliasEF1)->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,(cAliasEF1)->EF1_TPPEJR)=="2",If(cAliasEF1=="M",M->EF1_PERFIX,(cAliasEF1)->EF1_PERFIX),aTx_Jr[nz,2]) * (aTx_Jr[nz,1] / 100) * (If(cAliasEF1=="M",M->EF1_VL_MOE,(cAliasEF1)->EF1_VL_MOE) - nValPrinc)
                  Next nz
                  aAdd(aParcelas,{"2",Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx]))),dDtVenc, nValJuros , nValJuros, nPos = 0 .or. aCodJur[nPos,3]})
                  If aParcelas[Len(aParcelas)][6]
                     M->EF1_SLD_JM += Round( nValJuros , AvSX3("EF1_SLD_JM",4) )
                  EndIf
               Else
                  dDtFim := dDtVenc
                  nTotalParc := 0
                  lPrinc := .T.
                  For nt:=ni+IIF((aParcelas[ni,3] < dDtVenc),1,0) to 1 Step -1   // PLB 12/06/06 - Adiciona um se a primeira parcela de juros for apos a primeira parcela de pagamento
                     aTx_Jr := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN),If(nt=1 .and. aParcelas[nt,3]<dDtFim .and. lPrinc,aParcelas[nt,3],dDtFim),If(nt=1 .and. lPrinc,If(cAliasEF1=="M",M->EF1_DT_JUR,(cAliasEF1)->EF1_DT_JUR),aParcelas[IIF(nt==1,1,nt-1),3]),cAliasEF1,If(cAliasEF1=="M","WorkEF2","EF2"),aJuros[nx],If(nt=1,.T.,.F.))  // PLB 12/06/06 - Se estiver calculando o juros da data do primeiro juros ate a data do primeiro principal
                     nValJuros := 0
                     For nz:=1 to If(If(cAliasEF1=="M",M->EF1_PERFIX,(cAliasEF1)->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,(cAliasEF1)->EF1_TPPEJR)=="2",1,Len(aTx_Jr))
                        nValJuros += If(If(cAliasEF1=="M",M->EF1_PERFIX,(cAliasEF1)->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,(cAliasEF1)->EF1_TPPEJR)=="2",If(cAliasEF1=="M",M->EF1_PERFIX,(cAliasEF1)->EF1_PERFIX),aTx_Jr[nz,2]) * (aTx_Jr[nz,1] / 100) * (If(cAliasEF1=="M",M->EF1_VL_MOE,(cAliasEF1)->EF1_VL_MOE) - IIF(nt==1,0,nValPrinc))  // PLB 12/06/06 - Calcula sobre o saldo total se estiver calculando o juros da data de inicio de juros ate a data do primeiro principal
                     Next nz
                     nTotalParc += Round(nValJuros,2)
                     If aParcelas[IIF(nt==1,1,nt-1),1] == "2"  // PLB 12/06/06
                        Exit
                     ElseIf nt <> 1  // PLB 12/06/06
                        dDtFim := aParcelas[nt-1,3]
                        nValPrinc -= aParcelas[nt-1,4]
                        If !(aParcelas[nt-1,2] == EV_PRINC_PREPAG)   // PLB 12/06/06
                           lPrinc := .F.
                        EndIf
                     EndIf
                  Next nt
                  aAdd(aParcelas,{"2",Left(EV_JUROS_PREPAG,2)+Alltrim(Str(Val(aJuros[nx]))),dDtVenc, nTotalParc , nTotalParc , nPos = 0 .or. aCodJur[nPos,3]})
                  If aParcelas[Len(aParcelas)][6]
                     M->EF1_SLD_JM += Round( nTotalParc , AvSX3("EF1_SLD_JM",4) )
                  EndIf
               EndIf
            //EndIf
            ni:=Len(aParcelas)
         EndIf
      Next nx
      If Len(aSaiJur) = Len(aJuros)
         Exit
      EndIf
   Next ni
Next nInd
If cAliasEF1<>"M"
   (cAliasEF1)->EF1_SLD_JR := ( (cAliasEF1)->EF1_SLD_PR / (cAliasEF1)->EF1_SLD_PM ) * (cAliasEF1)->EF1_SLD_JM
Else
   M->EF1_SLD_JR := ( M->EF1_SLD_PR / M->EF1_SLD_PM ) * M->EF1_SLD_JM
EndIf

//Ordena as parcelas por Data + Tipo(1-principal ou 2-juros) + Código do Evento
aSort(aParcelas,,, {|x, y| dtos(x[3])+x[1]+x[2] < dtos(y[3])+y[1]+y[2] })

// ** PLB 26/10/06 - Grava array com as posições das parcelas do principal no array aParcelas
For ni := 1  To  Len(aParcelas)
   If aParcelas[ni][1] == "1"
      AAdd(aPosPrinc,ni)
   EndIf
Next ni
// **

//Grava todas as parcelas
ni := 0
Do While ni  < Len(aParcelas)
   ni++
   lLiq := .F.

   If aParcelas[ni,2] <> EV_PRINC_PREPAG
         If (nPos := aScan(aParcJr,{|x| x[1]==aParcelas[ni,2]})) > 0
            nParcJr := aParcJr[nPos,2]
            nPosAux := aScan(aParcJrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=aParcJr[nPos,2]})
            Do While nPosAux > 0
               nParcJr ++
               nPosAux := aScan(aParcJrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=nParcJr})
            EndDo
            aParcJr[nPos,2] := nParcJr + 1
         Else
            nParcJr := 1
            nPosAux := aScan(aParcJrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=nParcJr})
            Do While nPosAux > 0
               nParcJr ++
               nPosAux := aScan(aParcJrAux,{|x| x[1]==aParcelas[ni,2] .and. x[2]=nParcJr})
            EndDo
            aAdd(aParcJr,{aParcelas[ni,2],nParcJr+1})
         EndIf
   EndIf
   
   If aParcelas[ni,6]

      If aParcelas[ni,2] <> EV_PRINC_PREPAG
         If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+aParcelas[ni,2]+If(cAliasEF3=="WorkEF3",Space(Len(EF3->EF3_INVOIC)),"")+StrZero(nParcJr,AvSX3("EF3_PARC",3),0)))
            
            If (lLiq := !Empty((cAliasEF3)->EF3_VL_REA)) .AND. Round(aParcelas[ni,4],AvSX3("EF3_VL_MOE",4)) <> (cAliasEF3)->EF3_VL_MOE
               aParcelas := EX401AcPaPP(aParcelas,ni,cAliasEF3)
               loop
            Else
               (cAliasEF3)->(RecLock(cAliasEF3,.F.))
            EndIf
         Else
            (cAliasEF3)->(RecLock(cAliasEF3,.T.))
         EndIf
      EndIf
      If aParcelas[ni,1] == "2"
         (cAliasEF3)->EF3_CODEVE := aParcelas[ni,2]
         (cAliasEF3)->EF3_SEQ    := If( !Empty( (cAliasEF3)->EF3_SEQ ) , (cAliasEF3)->EF3_SEQ , cSeqEF3 ) //FSM - 19/03/2012
         (cAliasEF3)->EF3_DT_EVE := aParcelas[ni,3]
         (cAliasEF3)->EF3_MOE_IN := If(cAliasEF1=="M",M->EF1_MOEDA,(cAliasEF1)->EF1_MOEDA)
         (cAliasEF3)->EF3_VL_MOE := Round(aParcelas[ni,4],AvSX3("EF3_VL_MOE",4))
         (cAliasEF3)->EF3_SLDLIQ := Round(aParcelas[ni,5],AvSX3("EF3_VL_MOE",4))
         (cAliasEF3)->EF3_SLDVIN := (cAliasEF3)->EF3_VL_MOE
         If cAliasEF3 == "EF3"
            (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
            If lEFFTpMod
               (cAliasEF3)->EF3_TPMODU := If(cAliasEF1=="M",M->EF1_TPMODU,(cAliasEF1)->EF1_TPMODU)
            EndIf
            (cAliasEF3)->EF3_CONTRA := If(cAliasEF1=="M",M->EF1_CONTRA,(cAliasEF1)->EF1_CONTRA)
            (cAliasEF3)->EF3_TP_EVE := If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN)
            If lTemChave
               EF3->EF3_BAN_FI := If(cAliasEF1=="M",M->EF1_BAN_FI,EF1->EF1_BAN_FI)
               EF3->EF3_AGENFI := If(cAliasEF1=="M",M->EF1_AGENFI,EF1->EF1_AGENFI)
               EF3->EF3_NCONFI := If(cAliasEF1=="M",M->EF1_NCONFI,EF1->EF1_NCONFI)
               EF3->EF3_PRACA  := If(cAliasEF1=="M",M->EF1_PRACA,EF1->EF1_PRACA)
               If lEFFTpMod
                  (cAliasEF3)->EF3_SEQCNT := If(cAliasEF1=="M",M->EF1_SEQCNT,(cAliasEF1)->EF1_SEQCNT)
               EndIf
            EndIf
         EndIf
         (cAliasEF3)->EF3_PARC   := StrZero(nParcJr,AvSX3("EF3_PARC",3),0)
         (cAliasEF3)->(msUnlock())

         If aParcelas[ni,2] <> EV_PRINC_PREPAG .AND. !(cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+aParcelas[ni,2]+If(cAliasEF3=="WorkEF3",Space(Len(EF3->EF3_INVOIC)),"")+StrZero(nParcJr,AvSX3("EF3_PARC",3),0)))
            If lCadFin
               EX401GrEncargos(cAliasEF3)
            EndIf
         EndIf
      Else
         (cAliasEF3)->(dbGoTo(aParcelas[ni,7]))
         (cAliasEF3)->(RecLock(cAliasEF3,.F.))
         (cAliasEF3)->EF3_SEQ    := If( !Empty( (cAliasEF3)->EF3_SEQ ) , (cAliasEF3)->EF3_SEQ , cSeqEF3 ) //FSM - 19/03/2012
         If lCalcPrinc

            // ** PLB 26/10/06 - Distribui o residuo de saldo entre as últimas parcelas
            nQtdParcAux  := IIF(cAliasEF1=="M",M->EF1_PARCPR,(cAliasEF1)->EF1_PARCPR)
            nValPrincAux := IIF(cAliasEF1=="M",M->EF1_VL_MOE,(cAliasEF1)->EF1_VL_MOE) / nQtdParcAux
            nResiduo     := ( nValPrincAux - Round(nValPrincAux,2) ) * nQtdParcAux
            (cAliasEF3)->EF3_VL_MOE := If(cAliasEF1=="M",M->EF1_VL_MOE,(cAliasEF1)->EF1_VL_MOE) / nQtdParcAux
            If AScan(aPosPrinc,{|x| x == ni }) >= ( nQtdParcAux + 1 - ABS(nResiduo * 100) )
               If nResiduo > 0
                  (cAliasEF3)->EF3_VL_MOE += 0.01
               ElseIf nResiduo < 0
                  (cAliasEF3)->EF3_VL_MOE -= 0.01
               EndIf
            EndIf
            (cAliasEF3)->EF3_SLDVIN := (cAliasEF3)->EF3_VL_MOE
         Endif
         (cAliasEF3)->(msUnlock())
      EndIf
      cSeqEF3 := StrZero(Val(cSeqEF3) + 1,4,0)

   EndIf

EndDo

(cAliasEF3)->(dbSetOrder(nOldOrd))
//WorkEF3->(dbGoTop())

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato.
EX401Saldo(cAliasEF1,IIF(lEFFTpMod,cMod,),&(cAliasEF1+"->EF1_CONTRA"),IIF(lTemChave,&(cAliasEF1+"->EF1_BAN_FI"),),IIF(lTemChave,&(cAliasEF1+"->EF1_PRACA"),),IIF(lEFFTpMod,&(cAliasEF1+"->EF1_SEQCNT"),),cAliasEF3,.T.)


Return .T.

*------------------------------------------------------------------------------------------------------*
Function EX401ExcPrePag(cTipo,lSalvaSeq,cAliasEF1,cAliasEF3,lCalcVencto, lCalcPrinc)
// cTipo       -> "1"-Principal, "2"-Juros, "3"-Ambos
// lSalvaSeq   -> Define se a função retornará as seqüências dos registros excluídos
// cAliasEF1   -> Alias para considerar o EF1 (M ou EF1)
// cAliasEF3   -> Alias para considerar o EF3 (WorkEF3 ou EF3)
// lCalcVencto -> Indica se será ou não alterado o vencimento das parcelas
// lCalcPrinc  -> Indica se será ou não alterado o valor do principal
*------------------------------------------------------------------------------------------------------*
Local ni:=1, aSeqs:={}, nOldRec, cCodEveAux, cParcAux, lVinc:=.F., cSeq:="", nOrd
Local aDelWorkEF3 := {}

If cTipo == "3"
   ProcRegua(If(cAliasEF1=="M",M->EF1_PARCPR+M->EF1_PARCJR,(cAliasEF1)->EF1_PARCPR+(cAliasEF1)->EF1_PARCJR))
ElseIf cTipo == "1"
   ProcRegua(If(cAliasEF1=="M",M->EF1_PARCPR,(cAliasEF1)->EF1_PARCPR))
Else
   ProcRegua(If(cAliasEF1=="M",M->EF1_PARCJR,(cAliasEF1)->EF1_PARCJR))
EndIf

//Exclui as parcelas do principal
If cTipo == "1" .or. cTipo == "3"
   (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+EV_PRINC_PREPAG))
   Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3") .and.;
   If(lEFFTpMod,EF3->EF3_TPMODU == (cAliasEF1)->EF1_TPMODU,.T.) .AND. EF3->EF3_CONTRA==(cAliasEF1)->EF1_CONTRA .and. EF3->EF3_BAN_FI==(cAliasEF1)->EF1_BAN_FI .and.;
   EF3->EF3_PRACA==(cAliasEF1)->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == (cAliasEF1)->EF1_SEQCNT,.T.),.T.) .and. (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG
      IncProc(STR0006+(cAliasEF3)->EF3_PARC+STR0004) //"Excluindo parcela " # " do principal."

      //Verifica se houve vinculação ou liquidação a cada parcela
      nOldRec    := (cAliasEF3)->(RecNo())
      cCodEveAux := (cAliasEF3)->EF3_CODEVE
      cParcAux   := (cAliasEF3)->EF3_PARC
      If (cAliasEF3)->EF3_TX_MOE > 0
         lVinc := .T.
      ElseIf (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+EV_EMBARQUE))
         lVinc:=.F.
         Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3") .and. If(lEFFTpMod,EF3->EF3_TPMODU == (cAliasEF1)->EF1_TPMODU,.T.) .AND.;
         EF3->EF3_CONTRA==(cAliasEF1)->EF1_CONTRA .and. EF3->EF3_BAN_FI==(cAliasEF1)->EF1_BAN_FI .and.;
         EF3->EF3_PRACA==(cAliasEF1)->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == (cAliasEF1)->EF1_SEQCNT,.T.),.T.) .and. (cAliasEF3)->EF3_CODEVE == EV_EMBARQUE
            If (cAliasEF3)->EF3_EV_VIN == cCodEveAux .and. (cAliasEF3)->EF3_PARVIN==cParcAux
               lVinc:=.T.
               Exit
            EndIf
            (cAliasEF3)->(dbSkip())
         EndDo
      EndIf
      (cAliasEF3)->(dbGoTo(nOldRec))

      If lCalcVencto .And. lCalcPrinc
         If !lVinc
            aAdd(aSeqs,{"1",ni,(cAliasEF3)->EF3_SEQ})
            If cAliasEF3 == "WorkEF3"
               aAdd(aDelEF3,(cAliasEF3)->EF3_RECNO)
            EndIf
            cSeq := (cAliasEF3)->EF3_SEQ
            (cAliasEF3)->(RecLock(cAliasEF3,.F.,.T.))
            (cAliasEF3)->(DBDELETE())
            (cAliasEF3)->(MSUnlock())

            //JWJ 02/02/07: Estorna eventos de encargos associados à parcela
            nOldRec := (cAliasEF3)->(RECNO())
            nOrd    := (cAliasEF3)->(IndexOrd())
            (cAliasEF3)->(dbSetOrder(4))
            (cAliasEF3)->(dbSeek(cSeq))
            Do While !(cAliasEF3)->(EOF()) .and. (cAliasEF3)->EF3_SEQ == cSeq
               If (cAliasEF3)->EF3_CODEVE <> EV_ESTORNO
                  If !Empty((cAliasEF3)->EF3_NR_CON)
                     (cAliasEF3)->(RecLock(cAliasEF3,.F.))
                     If cAliasEF3 == "WorkEF3"
                        aAdd(aDelWkEF3,(cAliasEF3)->(RecNo()))
                     Endif
                     (cAliasEF3)->EF3_EV_EST := (cAliasEF3)->EF3_CODEVE //(cAliasEF3)->(DBDELETE())
                     (cAliasEF3)->EF3_DT_EST := dDataBase //AAF 24/07/05 - Grava a Data do Evento Estornado.
                     (cAliasEF3)->EF3_CODEVE := EV_ESTORNO
                     (cAliasEF3)->EF3_NR_CON := Space(Len((cAliasEF3)->EF3_NR_CON))
                     (cAliasEF3)->(MSUnlock())
                  Else
                     If cAliasEF3 == "WorkEF3"
                        aAdd(aDelEF3,WorkEF3->EF3_RECNO)
                     Endif
                     aAdd(aDelWorkEF3, (cAliasEF3)->(RECNO()) )
                  EndIf

               EndIf
               (cAliasEF3)->(dbSkip())
            EndDo
            (cAliasEF3)->(dbSetOrder(nOrd))
            (cAliasEF3)->(dbGoto(nOldRec))

            ni++
         EndIf
      Else
         If !lVinc
            (cAliasEF3)->(RecLock(cAliasEF3,.F.))
            If lCalcVencto
               (cAliasEF3)->EF3_DT_EVE := CTOD("")
            EndIf
            If lCalcPrinc
               (cAliasEF3)->EF3_VL_MOE := 0
            EndIf
            (cAliasEF3)->(MSUnlock())
         EndIf
      EndIf
      (cAliasEF3)->(dbSkip())
   EndDo
EndIf

//JWJ 02/02/07
For ni := 1 To Len(aDelWorkEF3)
   (cAliasEF3)->(DBGOTO(aDelWorkEF3[ni]))
   RECLOCK(cAliasEF3, .F.)
   (cAliasEF3)->(DBDELETE())
   (cAliasEF3)->(MSUNLOCK())
Next

aDelWorkEF3 := {}
ni:=1

//Exclui as parcelas do juros
If cTipo == "2" .or. cTipo == "3"
   (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+Left(EV_JUROS_PREPAG,2)))
   Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3") .and. If(lEFFTpMod,EF3->EF3_TPMODU == (cAliasEF1)->EF1_TPMODU,.T.) .AND.;
   EF3->EF3_CONTRA==(cAliasEF1)->EF1_CONTRA .and. EF3->EF3_BAN_FI==(cAliasEF1)->EF1_BAN_FI .and.;
   EF3->EF3_PRACA==(cAliasEF1)->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == (cAliasEF1)->EF1_SEQCNT,.T.),.T.) .and. Left((cAliasEF3)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)
      IncProc(STR0006+(cAliasEF3)->EF3_PARC+STR0005) //"Excluindo parcela " # " do juros."

      //Verifica se houve vinculação ou liquidação a cada parcela
      nOldRec    := (cAliasEF3)->(RecNo())
      cCodEveAux := (cAliasEF3)->EF3_CODEVE
      cParcAux   := (cAliasEF3)->EF3_PARC
      If (cAliasEF3)->EF3_TX_MOE > 0
         lVinc := .T.
      ElseIf (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+EV_EMBARQUE))
         lVinc:=.F.
         Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3") .and. If(lEFFTpMod,EF3->EF3_TPMODU == (cAliasEF1)->EF1_TPMODU,.T.) .AND.;
         EF3->EF3_CONTRA==(cAliasEF1)->EF1_CONTRA .and. EF3->EF3_BAN_FI==(cAliasEF1)->EF1_BAN_FI .and.;
         EF3->EF3_PRACA==(cAliasEF1)->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == (cAliasEF1)->EF1_SEQCNT,.T.),.T.) .and. (cAliasEF3)->EF3_CODEVE == EV_EMBARQUE
            If (cAliasEF3)->EF3_EV_VIN == cCodEveAux .and. (cAliasEF3)->EF3_PARVIN==cParcAux
               lVinc:=.T.
               Exit
            EndIf
            (cAliasEF3)->(dbSkip())
         EndDo
      EndIf
      (cAliasEF3)->(dbGoTo(nOldRec))

      If lCalcVencto
         If !lVinc
            aAdd(aSeqs,{"2",ni,(cAliasEF3)->EF3_SEQ})
            If cAliasEF3 == "WorkEF3"
               aAdd(aDelEF3,(cAliasEF3)->EF3_RECNO)
            EndIf

            //Atualiza saldo do contrato
            If(cAliasEF1<>"M",EF1->(RecLock("EF1",.F.)),)
            //LRL 11/06/05 - If(cAliasEF1=="M",M->EF1_SLD_JM,EF1->EF1_SLD_JM) -= (cAliasEF3)->EF3_VL_MOE
            //LRL 11/06/05 - If(cAliasEF1=="M",M->EF1_SLD_JR,EF1->EF1_SLD_JR) -= (cAliasEF3)->EF3_VL_REA
            If(cAliasEF1<>"M",EF1->(msUnlock()),)

            // ** GFC - 24/10/05 - Excluir junto as parcelas de IR
            EX401LocIR(cAliasEF3,(cAliasEF3)->EF3_CODEVE,(cAliasEF3)->EF3_INVOIC,(cAliasEF3)->EF3_PARC,1,If(lEFFTpMod,(cAliasEF3)->EF3_TPMODU,))
            // **
            cSeq := (cAliasEF3)->EF3_SEQ
            (cAliasEF3)->(RecLock(cAliasEF3,.F.,.T.))
            (cAliasEF3)->(DBDELETE())
            (cAliasEF3)->(MSUnlock())

            //JWJ 02/02/07: Estorna eventos de encargos associados ao juros
            nOldRec := (cAliasEF3)->(RECNO())
            nOrd    := (cAliasEF3)->(IndexOrd())
            (cAliasEF3)->(dbSetOrder(4))
            (cAliasEF3)->(dbSeek(cSeq))
            Do While !(cAliasEF3)->(EOF()) .and. (cAliasEF3)->EF3_SEQ == cSeq
               If (cAliasEF3)->EF3_CODEVE <> EV_ESTORNO
                  If !Empty((cAliasEF3)->EF3_NR_CON)
                     (cAliasEF3)->(RecLock(cAliasEF3,.F.))
                     If cAliasEF3 == "WorkEF3"
                        aAdd(aDelWkEF3,(cAliasEF3)->(RecNo()))
                     Endif
                     (cAliasEF3)->EF3_EV_EST := (cAliasEF3)->EF3_CODEVE //(cAliasEF3)->(DBDELETE())
                     (cAliasEF3)->EF3_DT_EST := dDataBase //AAF 24/07/05 - Grava a Data do Evento Estornado.
                     (cAliasEF3)->EF3_CODEVE := EV_ESTORNO
                     (cAliasEF3)->EF3_NR_CON := Space(Len((cAliasEF3)->EF3_NR_CON))
                     (cAliasEF3)->(MSUnlock())
                  Else
                     If cAliasEF3 == "WorkEF3"
                        aAdd(aDelEF3,WorkEF3->EF3_RECNO)
                     Endif
                     aAdd(aDelWorkEF3, (cAliasEF3)->(RECNO()) )
                  EndIf

               EndIf
               (cAliasEF3)->(dbSkip())
            EndDo
            (cAliasEF3)->(dbSetOrder(nOrd))
            (cAliasEF3)->(dbGoto(nOldRec))

            ni++
         EndIf
      Else
         If !lVinc
            (cAliasEF3)->(RecLock(cAliasEF3,.F.))
            (cAliasEF3)->EF3_VL_MOE := 0
            (cAliasEF3)->(MSUnlock())

            // ** GFC - 24/10/05 - Excluir junto as parcelas de IR
            EX401LocIR(cAliasEF3,(cAliasEF3)->EF3_CODEVE,(cAliasEF3)->EF3_INVOIC,(cAliasEF3)->EF3_PARC,1,If(lEFFTpMod,(cAliasEF3)->EF3_TPMODU,))
            // **
         EndIf
      EndIf
      lVinc := .F.
      (cAliasEF3)->(dbSkip())
   EndDo
EndIf

//JWJ 02/02/07
For ni := 1 To Len(aDelWorkEF3)
   (cAliasEF3)->(DBGOTO(aDelWorkEF3[ni]))
   RECLOCK(cAliasEF3, .F.)
   (cAliasEF3)->(DBDELETE())
   (cAliasEF3)->(MSUNLOCK())
Next

Return If(lSalvaSeq,aSeqs,.T.)


*------------------------------------------------------------------------------------------------------*
Function EXPosPrePag(cAliasEF3,cContra,cBanFi,cPraca,lRetSaldo,cTipoVinc,cTpModu,cSeqCon)
// cAliasEF3 -> Alias do arquivo EF3 (EF3 ou WorkEF3)
// cContra   -> Contrato
// cBanFi    -> Banco
// cPraca    -> Parcela
// lRetSaldo -> Indica se deverá retornar o saldo restante oou se irá apenas posicionar na primeira
//              parcela que possuir saldo
// cTipoVinc -> Indica se a invoice será vinculada a uma parcela do principal (1) ou a uma parcela
//              de juros (2)
//AAF 07/03/06 - Novos Parâmetros:
// cTpModu   -> Tipo de Modulo "E" - Exportação e "I" - Importação.
// cSeqCon   -> Sequência do Contrato.
*------------------------------------------------------------------------------------------------------*
Local nRecEf3, cParcVin, cEvVin, nSomaVin:=0, nOrd:=(cAliasEF3)->(IndexOrd())
Local lOkVinc:=.F., cAliasEF2, cAliasEF1, lLoop:=.F.

If cTpModu == NIL
   cTpModu := EXP
EndIf

If cAliasEF3 == "EF3"
   cAliasEF2 := "EF2"
   cAliasEF1 := "EF1"
   (cAliasEF3)->(dbSetOrder(1))
Else
   cAliasEF2 := "WorkEF2"
   cAliasEF1 := "M"
   (cAliasEF3)->(dbSetOrder(2))
EndIf

(cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContra+cBanFi+cPraca+If(lEFFTpMod,cSeqCon,""),"")+If(cTipoVinc=="1",EV_PRINC_PREPAG,Left(EV_JUROS_PREPAG,2))))

If cTipoVinc=="2"
   If cAliasEF3=="EF3"
      (cAliasEF3)->(dbSetOrder(4))
   Else
      (cAliasEF3)->(dbSetOrder(1))
   EndIf
EndIf
Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3") .AND. If(lEFFTpMod,EF3->EF3_TPMODU == cTpModu,.T.) .AND.;
EF3->EF3_CONTRA==cContra .and. EF3->EF3_BAN_FI==cBanFi .and. EF3->EF3_PRACA==cPraca .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == cSeqCon,.T.),.T.) .and.;
If(cTipoVinc=="1",(cAliasEF3)->EF3_CODEVE==EV_PRINC_PREPAG,.T.)

   If cTipoVinc == "2" .and. Left((cAliasEF3)->EF3_CODEVE,2) <> Left(EV_JUROS_PREPAG,2)
      (cAliasEF3)->(dbSkip())
   EndIf

   nRecEF3  := (cAliasEF3)->(RecNo())
   If (cAliasEF3)->EF3_TX_MOE = 0
      cParcVin := (cAliasEF3)->EF3_PARC
      cEvVin   := (cAliasEF3)->EF3_CODEVE

      //Soma os eventos de embarque linkados a essa parcela
      If cTipoVinc == "2"
         If cAliasEF3 == "EF3"
            (cAliasEF3)->(dbSetOrder(1))
         Else
            (cAliasEF3)->(dbSetOrder(2))
         EndIf
      EndIf
      nSomaVin:=0
      (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContra+cBanFi+cPraca+If(lEFFTpMod,cSeqCon,""),"")+EV_EMBARQUE))
      Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3") .and. If(lEFFTpMod,EF3->EF3_TPMODU == cTpModu,.T.) .AND.;
      EF3->EF3_CONTRA==cContra .and. EF3->EF3_BAN_FI==cBanFi .and. EF3->EF3_PRACA==cPraca .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == cSeqCon,.T.),.T.) .and.;
      (cAliasEF3)->EF3_CODEVE == EV_EMBARQUE
         If (cAliasEF3)->EF3_PARVIN == cParcVin .and. (cAliasEF3)->EF3_EV_VIN == cEvVin
            nSomaVin += (cAliasEF3)->EF3_VL_MOE
         EndIf
         (cAliasEF3)->(dbSkip())
      EndDo
      If cTipoVinc=="2"
         If cAliasEF3=="EF3"
            (cAliasEF3)->(dbSetOrder(4))
         Else
            (cAliasEF3)->(dbSetOrder(1))
         EndIf
      EndIf

      (cAliasEF3)->(dbGoTo(nRecEF3))
      If nSomaVin < (cAliasEF3)->EF3_VL_MOE

         If cTipoVinc == "2"
            If cAliasEF3=="EF3"
               EF3->(dbSetOrder(7))
               EF2->(dbSetOrder(2))
            Else
               WorkEF3->(dbSetOrder(8))
            EndIf

            lOkVinc := .F.
            Do While !(cAliasEF3)->(EOF()) .and. !lOkVinc

               //Verifica se é para vincular a este tipo de juros (posicionado) neste período
               If cAliasEF2 == "EF2"
                  (cAliasEF2)->(dbSeek(xFilial("EF2")+If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA,If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA)+;
                                iif(lTemChave, iif(cAliasEF1=="M",M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA)+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,""),"")+;
                                If(lEF2_INVOIC,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC)),"")+;
                                If(cAliasEF1=="EF1",EF1->EF1_TP_FIN,M->EF1_TP_FIN)+If(lEF2_TIPJUR,Right((cAliasEF3)->EF3_CODEVE,1),"")+DtoS((cAliasEF3)->EF3_DT_EVE),.T.))
               Else
                  (cAliasEF2)->(dbSeek(If(lEF2_INVOIC,Space(Len(EF2->EF2_FILORI+EF2->EF2_INVOIC+EF2->EF2_PARC)),"")+If(cAliasEF1=="EF1",EF1->EF1_TP_FIN,M->EF1_TP_FIN)+If(lEF2_TIPJUR,Right((cAliasEF3)->EF3_CODEVE,1),"")+DtoS((cAliasEF3)->EF3_DT_EVE),.T.))
               EndIf

               If (cAliasEF2)->(Eof()) .or. If(lEFFTpMod,(cAliasEF2)->EF2_TPMODU,"")+(cAliasEF2)->EF2_CONTRA <> If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA,If(lEFFTpMod,EF1->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA) .or.;
               (cAliasEF2)->EF2_TP_FIN <> If(cAliasEF1=="EF1",EF1->EF1_TP_FIN,M->EF1_TP_FIN) .or. iif(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA+If(lEFFTpMod,(cAliasEF2)->EF2_SEQCNT,"")<>iif(cAliasEF1=="M",M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,"")),.F.) .or.;
               If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR<>Right((cAliasEF3)->EF3_CODEVE,1),.F.)
                  (cAliasEF2)->(dbSkip(-1))
               EndIf

               If (cAliasEF2)->EF2_DT_INI > (cAliasEF3)->EF3_DT_EVE
                  (cAliasEF2)->(dbSkip(-1))

                  If (cAliasEF2)->(BOF()) .or.;
                  If(lEFFTpMod,(cAliasEF2)->EF2_TPMODU,"")+(cAliasEF2)->EF2_CONTRA <> If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA,If(lEFFTpMod,(cAliasEF2)->EF2_TPMODU,"")+(cAliasEF1)->EF1_CONTRA) .or.;
                  (cAliasEF2)->EF2_TP_FIN <> If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) .or. iif(lTemChave,(cAliasEF2)->EF2_BAN_FI+(cAliasEF2)->EF2_PRACA+If(lEFFTpMod,(cAliasEF2)->EF2_SEQCNT,"")<>iif(cAliasEF1=="M",M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA)+If(lEFFTpMod,EF1->EF1_SEQCNT,""),.F.) .or.;
                  If(lEF2_TIPJUR,(cAliasEF2)->EF2_TIPJUR<>Right((cAliasEF3)->EF3_CODEVE,1),.F.)
                     (cAliasEF3)->(dbSkip())
                     Loop
                  ElseIf ((cAliasEF2)->EF2_DT_INI > (cAliasEF3)->EF3_DT_EVE .or. (cAliasEF2)->EF2_DT_FIM < (cAliasEF3)->EF3_DT_EVE) .or.;
                  (cAliasEF2)->EF2_USEINV == "2"
                     (cAliasEF3)->(dbSkip())
                     Loop
                  Else
                     lOkVinc:=.T.
                  Endif
               ElseIf (cAliasEF2)->EF2_DT_INI > (cAliasEF3)->EF3_DT_EVE .or. (cAliasEF2)->EF2_DT_FIM < (cAliasEF3)->EF3_DT_EVE .or.;
               (cAliasEF2)->EF2_USEINV == "2"
                  (cAliasEF3)->(dbSkip())
                  Loop
               Else
                  lOkVinc:=.T.
               EndIf
            EndDo
            If cAliasEF2=="EF2"
               EF2->(dbSetOrder(1))
            EndIf
         EndIf
         If cTipoVinc == "2"
            If lOkVinc
               If !lLoop
                  lLoop := .T.
                  Loop
               Else
                  lLoop := .F.
                  Exit
               EndIf
            EndIf
         Else
            Exit
         EndIf
      EndIf
   Else
      (cAliasEF3)->(dbGoTo(nRecEF3))
   EndIf
   //(cAliasEF3)->(dbSetOrder(2))
   lLoop := .F.
   (cAliasEF3)->(dbSkip())

EndDo

(cAliasEF3)->(dbSetOrder(nOrd))

Return If(lRetSaldo,If(cTpModu == "E",(cAliasEF3)->EF3_VL_MOE-nSomaVin,If(Len(cAliasEF3)>3,M->EF1_VL_MOE,EF1->EF1_VL_MOE)),.T.)

*------------------------------------------------------------------------------------------------------*
Function EXParcPrePag(nDif)
// nDif -> Diferença entre o valor anterior e o novo valor
*------------------------------------------------------------------------------------------------------*
Local ni, aNovaParc:={}, cSeqEF3:=BuscaEF3Seq(), nRecEF3_1:=0, nRecEF3_2:=0, nParcPr:=1
Local nOrd := WorkEF3->(IndexOrd()), nValTot:=0
Local lCalcPrinc := .T. //FSM - 28/03/2012

   If (lCalcPrinc := MsgYesNo(STR0002)) //"Deseja recalcular os valores do principal?"
      //Atualiza os valores das parcelas
      WorkEF3->(dbSetOrder(2))
      WorkEF3->(dbSkip())
      If !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG
         WorkEF3->(RecLock("WorkEF3",.F.))
         WorkEF3->EF3_VL_MOE += nDif
         WorkEF3->(msUnlock())
      Else
         nRecEF3_1 := WorkEF3->(RecNo())
         WorkEF3->(dbSeek(EV_PRINC_PREPAG))
         Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE==EV_PRINC_PREPAG
            nValTot += WorkEF3->EF3_VL_MOE
            WorkEF3->(dbSkip())
         EndDo
         If nValTot <> M->EF1_VL_MOE
            MsgInfo(STR0007) //"A somatoria das parcelas do principal difere do total do contrato."
         EndIf
         WorkEF3->(dbGoTo(nRecEF3_1))
      EndIf
   EndIf

   Processa({|| EX401AltPrePag(,,"M","WorkEF3", lCalcPrinc) } ,STR0008) //"Recalculando parcelas de juros..." //FSM - 28/03/2012

WorkEF3->(dbSetOrder(nOrd))

Return .T.


*-------------------------------------------------------------------------------------------------------*
Function EX401SelLiq(lBlock,lAutomatico,cSeq,cInv,cParc,cPreemb,cChamada,lEstorno, cAliasEF1)
*-------------------------------------------------------------------------------------------------------*
Local nSelecao, oPanel, aSelCposLiq, aSelCposVinc, oScrBox, nLin:=10, nOldRec, dOldData
Local nOldOrd, nCol1:= 5, nCol2:= 62, nCol3:= 192, nCol4:= 262
Local nCol5:= 332 , nCol6:= 400 , oMark3, oMark4, cAliasAux:="WorkEF3"
Local nRecWKEF3
Local aLabels := {}
Local aSemSX3Liq := { {"EF3_FILIAL","C",AVSX3("EF3_FILIAL",3),0} ,;
                      {"EF3_CONTRA","C",AVSX3("EF3_CONTRA",3),0}  }
Local nTxDiaSug
Local nEFF0002:=EasyGParam("MV_EFF0002",,0)
Local lCpoDtLqEv

// ** GFC - 24/08/05 - IR
Local nVlIR := 0, nVlIR_Old := 0, aAchouIR := {}
// **

Local lLocked:= .F.

//AAF 23/05/2006 - Define como padrão a manutenção de contratos.
//Default cChamada := "MANUT1"
Default cChamada := "MANUT2"//wfs

// ** GFC - 03/05/06
If !(cChamada $ "CAMB/FFC")// PLB 10/05/06
   aHeaderAux := aClone(aHeader)
   aColsAux   := aClone(aCols)
ElseIf lEFFTpMod
   M->EF1_TPMODU := EF1->EF1_TPMODU
EndIf
// **

Default lBlock     := .T.
Default lAutomatico:= .F.
Default lEstorno   := .F.
Default cAliasEF1  := "M"

Private aHeader[0] //, aCampos:=Array(EF1->(fCount()))  //E_CriaTrab utiliza #### THTS - 27/09/2017 - Quando nao existe o aCampos, o E_CriaTrab o cria.
Private nRecLastEF3
Private aBotoes :={} //LDB 15/05/2006 - Para ser utilizado na EnchoiceBar

// ** GFC - 27/07/05 - Caso seja chamado do câmbio deve-se criar esra variável
aSelCpos := BrowseCpos("EF3","WorkEF3")
AcertaCpos("2")
aSelCposVinc := aClone(aSelCpos)

aSelCpos := BrowseCpos("EF3","WorkEF3")
AcertaCpos("3")
aSelCposLiq := aClone(aSelCpos)
// **

If !lAutomatico
   nOldOrd := WORKEF3->(IndexOrd())
Else
   cAliasAux:="EF3"
EndIf

nRecWKEF3 := (cAliasAux)->( recno() )

lCpoDtLqEv := (cAliasAux)->(FieldPos("EF3_DTOREV")) > 0

If lTemChave
   aAdd(aSemSX3Liq,{"EF3_BAN_FI","C",AVSX3("EF3_BAN_FI",3),0})
   aAdd(aSemSX3Liq,{"EF3_AGENFI","C",AVSX3("EF3_AGENFI",3),0})
   aAdd(aSemSX3Liq,{"EF3_NCONFI","C",AVSX3("EF3_NCONFI",3),0})
   aAdd(aSemSX3Liq,{"EF3_PRACA", "C",AVSX3("EF3_PRACA", 3),0})
   If lEFFTpMod
      aAdd(aSemSX3Liq,{"EF3_SEQCNT", "C",AVSX3("EF3_SEQCNT", 3),0})
   EndIf
EndIf
aAdd(aSemSX3Liq,{"EF3_TP_EVE","C",AVSX3("EF3_TP_EVE",3),0})
aAdd(aSemSX3Liq,{"EF3_SEQ"   ,"C",AVSX3("EF3_SEQ"   ,3),0})
aAdd(aSemSX3Liq,{"EF3_PARC"  ,"C",AVSX3("EF3_PARC"  ,3),0})

//If lEF3_EV_FO
   aAdd(aSemSX3Liq,{"EF3_EV_FO" ,"C",AVSX3("EF3_EV_FO" ,3),0})
//EndIf
If lPrePag
   aAdd(aSemSX3Liq,{"EF3_SLDLIQ","N",AVSX3("EF3_SLDLIQ",3),AVSX3("EF3_SLDLIQ",4)})
   aAdd(aSemSX3Liq,{"EF3_LIQ_RS","N",AVSX3("EF3_LIQ_RS",3),AVSX3("EF3_LIQ_RS",4)})
EndIf
aAdd(aSemSX3Liq,{"EF3_RECNO" ,"N",10,0})
If LMultiFil
   Aadd(aSemSX3Liq,{"EF3_FILORI",AVSX3("EF3_FILIAL",2),AVSX3("EF3_FILIAL",3),AVSX3("EF3_FILIAL",4)})
EndIF
// ** AAF - 07/11/05 - Transferência de Contrato.
If EF3->(FieldPos("EF3_CTDEST")) > 0 .and. EF3->(FieldPos("EF3_PRDEST")) > 0
   aAdd(aSemSX3Liq,{"EF3_CTDEST",AVSX3("EF3_CTDEST",2),AVSX3("EF3_CTDEST",3),AVSX3("EF3_CTDEST",4)})
   aAdd(aSemSX3Liq,{"EF3_PRDEST",AVSX3("EF3_PRDEST",2),AVSX3("EF3_PRDEST",3),AVSX3("EF3_PRDEST",4)})
EndIf
// **
// ** FSM - 08/02/2012 - Inclusao dos campos na Work
If EF3->(FieldPos("EF3_TITFIN")) > 0
   AAdd( aSemSX3Liq, { "EF3_NUMTIT", AVSX3("EF3_NUMTIT", AV_TIPO), AVSX3("EF3_NUMTIT", AV_TAMANHO), AVSX3("EF3_NUMTIT", AV_DECIMAL) } )
   AAdd( aSemSX3Liq, { "EF3_PARTIT", AVSX3("EF3_PARTIT", AV_TIPO), AVSX3("EF3_PARTIT", AV_TAMANHO), AVSX3("EF3_PARTIT", AV_DECIMAL) } )
   AAdd( aSemSX3Liq, { "EF3_TITFIN", AVSX3("EF3_TITFIN", AV_TIPO), AVSX3("EF3_TITFIN", AV_TAMANHO), AVSX3("EF3_TITFIN", AV_DECIMAL) } )
EndIf

//LRS - 37/04/2016
If EF3->(FieldPos("EF3_TPTIT")) > 0
   AAdd( aSemSX3Liq, { "EF3_TPTIT", AVSX3("EF3_TPTIT", AV_TIPO), AVSX3("EF3_TPTIT", AV_TAMANHO), AVSX3("EF3_TPTIT", AV_DECIMAL) } )
EndIF

If EF3->(FieldPos("EF3_PREFIX")) > 0
   AAdd( aSemSX3Liq, { "EF3_PREFIX", AVSX3("EF3_PREFIX", AV_TIPO), AVSX3("EF3_PREFIX", AV_TAMANHO), AVSX3("EF3_PREFIX", AV_DECIMAL) } )
EndIF

If EF3->(FieldPos("EF3_RELACA")) > 0
   AAdd( aSemSX3Liq, { "EF3_RELACA", AVSX3("EF3_RELACA", AV_TIPO), AVSX3("EF3_RELACA", AV_TAMANHO), AVSX3("EF3_RELACA", AV_DECIMAL) } )
EndIF

FWorkLiq  := E_CriaTrab("EF3",aSemSX3Liq,"WorkLiq" ,,.F.)
IndRegua("WorkLiq",FWorkLiq+TEOrdBagExt() ,"EF3_EV_VIN+EF3_PARVIN")

fWorkVinc := E_CriaTrab("EF3",aSemSX3Liq,"WorkVinc" ,,.F.)
IndRegua("WorkVinc",FWorkVinc+TEOrdBagExt() ,"EF3_EV_VIN+EF3_PARVIN")

//Grava Work de parcelas com as parcelas de pré-pagamento e securitização e de liquidação com os eventos 630
//de cada invoice
//If !lBxJuros
   ExGrvWkLiq(cAliasAux)
//EndIf
   If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"ANTES_TELA_LIQUIDACAO"),) //LDB 15/05/2006
nSelecao:=0
DEFINE MSDIALOG oDlg TITLE IIF(lEstorno,STR0145,STR0012) FROM oMainWnd:nTop+5,oMainWnd:nLeft+14 TO oMainWnd:nBottom-If(cMod == EXP,76,oMainWnd:nClientHeight/2.5),If(cMod == EXP,oMainWnd:nRight-14,oMainWnd:nRight-400) OF oMainWnd PIXEL //"Liquidação"  "Estorno da Liquidação"

   If cMod == EXP
      aLabels := { {oDlg:nTop + 14      , oDlg:nLeft-8, (oDlg:nBottom/2)-174, (oDlg:nRight/2)-8, STR0009},;//"Dados do Pagamento"
                   {(oDlg:nBottom/2)-172, oDlg:nLeft-8, (oDlg:nBottom/2)-101, (oDlg:nRight/2)-8, STR0010},;//"Invoices Vinculadas"
                   {(oDlg:nBottom/2)-98 , oDlg:nLeft-8, (oDlg:nBottom/2)-14 , (oDlg:nRight/2)-8, STR0011}} //"Invoices Liquidadas"
   Else
      aLabels := { {oDlg:nTop-5, oDlg:nLeft-8, (oDlg:nBottom/2)-38.5, (oDlg:nRight/2)-12, STR0009} } //"Dados do Pagamento"
   EndIf

   //Labels
   If !cMod == EXP
      @ aLabels[1][1] ,aLabels[1][2] TO aLabels[1][3],aLabels[1][4] Label aLabels[1][5] of oDlg Pixel
   Endif

   //ScrollBox
   If cMod == EXP
	  oPanel := TPanel():New(0, 0, ,oDlg, , .F., .F., , , 10, 10, , )
	  oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	  nA := 24
	  oScrBox := TScrollBox():New(oDlg,nA,oDlg:nLeft-6,(oDlg:nBottom/2)-197,(oDlg:nRight/2)-14,.T.,.T.,.T.)//Cria controles dentro do scrollbox
	  oScrBox:Align := CONTROL_ALIGN_TOP
   Else
      oScrBox := TScrollBox():New(oDlg,32,oDlg:nLeft-12,(oDlg:nBottom/2)-70,(oDlg:nRight/2)-13,.T.,.T.,.T.)//Cria controles dentro do scrollbox
   EndIf

   //Carrega Valores
   M->EF3_VL_MOE := (cAliasAux)->EF3_VL_MOE
   If (nTxDiaSug := BuscaTaxa( (cAliasAux)->EF3_MOE_IN , dDataBase ,        ,.T.       ,         ,       , '1') ) <> NIL
      M->EF3_TX_MOE := nTxDiaSug
      M->EF3_VL_REA := Round(M->EF3_VL_MOE * nTxDiaSug, 2)
   EndIf

   M->EF3_DT_EVE := (cAliasAux)->EF3_DT_EVE
   dOldData      := (cAliasAux)->EF3_DT_EVE
   If lTemChave
      M->EF3_BANC   := (cAliasAux)->EF3_BANC
      M->EF3_AGEN   := (cAliasAux)->EF3_AGEN
      M->EF3_NCON   := (cAliasAux)->EF3_NCON
      M->EF3_OBS    := (cAliasAux)->EF3_OBS
      M->EF3_NROP   := (cAliasAux)->EF3_NROP
   EndIf
   If cChamada $ "CAMB/FFC"
      M->EF3_CONTRA := (cAliasAux)->EF3_CONTRA
      If lEFFTpMod
         M->EF3_SEQCNT := (cAliasAux)->EF3_SEQCNT
      EndIf
      If lTemChave
         M->EF3_PRACA := (cAliasAux)->EF3_PRACA
      EndIf
   EndIf
   //M->EF3_DT_EVE := WorkEF3->EF3_DT_EVE
   If lCpoDtLqEv
      M->EF3_DTOREV := (cAliasAux)->EF3_DTOREV //CTOD("  /  /  ")
   EndIf

   If !lCadFin      // PLB 31/07/06 - IR passou a ser um encargo
      // ** GFC - 24/08/05 - IR
      aAchouIR  := EX401LocIR(cAliasAux,(cAliasAux)->EF3_CODEVE,(cAliasAux)->EF3_INVOIC,(cAliasAux)->EF3_PARC,,If(lEFFTpMod,(cAliasAux)->EF3_TPMODU,))
      If aAchouIR[1]
         nVlIr  := aAchouIR[2]
      Else
         nVlIr  := EX401VlIR(If(cAliasAux=="EF3","EF1","M"),M->EF3_VL_MOE)
      EndIf
      nVlIR_Old := nVlIr
      dDtIR     := M->EF3_DT_EVE
      nTxIR     := BuscaTaxa((cAliasAux)->EF3_MOE_IN,dDtIR,,.F.,.T.)
      nVlIR_Real:= Round(nVlIr * nTxIR,2)
      // **
   EndIf

   // PLB 31/07/06 - Exibe dados do contrato caso liquidacao seja pelo Cambio ou FFC
   If cChamada $ "CAMB/FFC"
      @ nLin, nCol1 SAY   AvSX3("EF3_CONTRA",5) of oScrBox Pixel SIZE 120,08
      @ nLin, nCol2 MSGET M->EF3_CONTRA Picture AvSX3("EF3_CONTRA",6) SIZE 115,08 Pixel of oScrBox When .F.
      If lTemChave
         @ nLin, nCol3 SAY   AvSX3("EF3_PRACA",5) of oScrBox Pixel SIZE 120,08
         @ nLin, nCol4 MSGET M->EF3_PRACA Picture AvSX3("EF3_PRACA",6) SIZE 115,08 Pixel of oScrBox When .F.
      EndIf
      nLin += 15
      If lEFFTpMod
         @ nLin, nCol1 SAY   AvSX3("EF3_SEQCNT",5) of oScrBox Pixel SIZE 120,08
         @ nLin, nCol2 MSGET M->EF3_SEQCNT Picture AvSX3("EF3_SEQCNT",6) SIZE 15,08 Pixel of oScrBox When .F.
         nLin += 15
      EndIf
   EndIf

   @ nLin, nCol1 SAY   AvSX3("EF3_VL_MOE",5) of oScrBox Pixel SIZE 120,08
   @ nLin, nCol2 MSGET M->EF3_VL_MOE Picture AvSX3("EF3_VL_MOE",6) SIZE 115,08 Pixel of oScrBox When .F.
   @ nLin, nCol3 SAY   AvSX3("EF3_TX_MOE",5) of oScrBox Pixel SIZE 120,08
   @ nLin, nCol4 MSGET M->EF3_TX_MOE Picture AvSX3("EF3_TX_MOE",6) Valid(IIF(M->EF3_TX_MOE<=0,(Help(" ",1,"AVG0005247"),.F.),If(M->EF3_TX_MOE<>0,M->EF3_VL_REA:=M->EF3_VL_MOE*M->EF3_TX_MOE,))) SIZE 115,08 Pixel of oScrBox When /*lBxJuros .or. */lBlock    //"Valor deve ser maior que zero."

   nLin += 15

   @ nLin, nCol1 SAY   AvSX3("EF3_VL_REA",5) of oScrBox Pixel SIZE 120,08
   @ nLin, nCol2 MSGET M->EF3_VL_REA Picture AvSX3("EF3_VL_REA",6) Valid(IIF(M->EF3_VL_REA<=0,(Help(" ",1,"AVG0005247"),.F.),.T.)) SIZE 115,08 Pixel of oScrBox When /*lBxJuros .Or. */lBlock
   @ nLin, nCol3 SAY   AvSX3("EF3_DT_EVE",5) of oScrBox Pixel SIZE 120,08
   @ nLin, nCol4 MSGET M->EF3_DT_EVE Picture AvSX3("EF3_DT_EVE",6) SIZE 115,08 Pixel of oScrBox When .F./*lBxJuros .or. *//*lBlock */

   If lTemChave
      nLin += 15

      @ nLin, nCol1      SAY   AvSX3("EF3_NROP",5) of oScrBox Pixel SIZE 120,08
      @ nLin, nCol2      MSGET M->EF3_NROP Picture AvSX3("EF3_NROP",6) SIZE 60,08  Pixel of oScrBox When /*lBxJuros .or.*/ lBlock

	  If lCpoDtLqEv
	     @ nLin, nCol3 SAY   AvSX3("EF3_DTOREV",5) of oScrBox Pixel SIZE 120,08
         @ nLin, nCol4 MSGET M->EF3_DTOREV Picture AvSX3("EF3_DTOREV",6) SIZE 115,08 Pixel of oScrBox When lBlock
	  Endif
      nLin += 15

      @ nLin, nCol1      SAY   AvSX3("EF3_BANC",5) of oScrBox Pixel SIZE 120,08
      @ nLin, nCol2      MSGET M->EF3_BANC Picture AvSX3("EF3_BANC",6) SIZE 15,08 F3 AvSx3("EF3_BANC",8) Valid ;
                               If ( !Empty(M->EF3_BANC) ,IF (  ExistCpo("SA6"),;
                               If (M->EF3_BANC = SA6->A6_COD, Eval({|| M->EF3_AGEN := SA6->A6_AGENCIA, M->EF3_NCON :=SA6->A6_NUMCON }),Eval({|| M->EF3_AGEN := Posicione("SA6",1,xFilial("SA6")+M->EF3_BANC,"A6_AGENCIA"), M->EF3_NCON :=SA6->A6_NUMCON }));
                               ,.F.),.T.) Pixel of oScrBox  When lBlock /*.or. lBxJuros*/
      @ nLin, nCol3 -88  SAY   AvSX3("EF3_AGEN",5) of oScrBox Pixel SIZE 120,08
      @ nLin, nCol4 -132 GET M->EF3_AGEN Picture AvSX3("EF3_AGEN",6) SIZE 30,08 Pixel of oScrBox When lBlock /*.or. lBxJuros*/
      @ nLin, nCol3      SAY   AvSX3("EF3_NCON",5) of oScrBox Pixel SIZE 120,08
      @ nLin, nCol4      MSGET M->EF3_NCON Picture AvSX3("EF3_NCON",6) SIZE 115,08 Pixel of oScrBox When  lBlock /*.or. lBxJuros*/

      nLin += 15

      @ nLin, nCol1      SAY   AvSX3("EF3_OBS",5) of oScrBox Pixel SIZE 120,08
      @ nLin, nCol2      MSGET M->EF3_OBS Picture AvSX3("EF3_OBS",6) SIZE 320,08 Pixel of oScrBox When lBlock /*.or. lBxJuros*/
   EndIf

   // ** GFC - 25/09/05 - IR
   If /*lBxJuros .or.*/ (lAutomatico .and. Left((cAliasAux)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))  .And.  !lCadFin  // PLB 31/07/06 - IR passou a ser um encargo
      nLin += 15

      @ nLin, nCol1 SAY   STR0025 of oScrBox Pixel SIZE 120,08 //"Valor do IR"
      @ nLin, nCol2 MSGET nVlIr Picture AvSX3("EF3_VL_INV",6) SIZE 115,08 Pixel of oScrBox Valid(If(Positivo(nVlIR) .and. (nVlIR_Real:=Round(nVlIr * nTxIR,2))>=0, .T., .F.)) When /*lBxJuros .or.*/ (lAutomatico .and. Left((cAliasAux)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))

      @ nLin, nCol3 SAY   STR0026 of oScrBox Pixel SIZE 120,08 //"Data do IR"
      @ nLin, nCol4 MSGET dDtIR Picture AvSX3("EF1_INI_IR",6) SIZE 115,08 Pixel of oScrBox Valid(If ((nTxIR:=BuscaTaxa((cAliasAux)->EF3_MOE_IN,dDtIR,,.F.,.T.))>=0 .and. (nVlIR_Real:=Round(nVlIr * nTxIR,2))>=0, .T., .F.)) When /*lBxJuros .or.*/ (lAutomatico .and. Left((cAliasAux)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))

      nLin += 15

      @ nLin, nCol1 SAY   STR0027 of oScrBox Pixel SIZE 120,08 //"Taxa do IR"
      @ nLin, nCol2 MSGET nTxIR Picture AvSX3("EF3_TX_MOE",6) SIZE 115,08 Pixel of oScrBox Valid(Positivo(nTxIR)) When /*lBxJuros .or.*/ (lAutomatico .and. Left((cAliasAux)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))

      @ nLin, nCol3 SAY   STR0028 of oScrBox Pixel SIZE 120,08 //"Valor do IR em R$"
      @ nLin, nCol4 MSGET nVlIr_Real Picture AvSX3("EF3_VL_INV",6) SIZE 115,08 Pixel of oScrBox Valid(Positivo(nVlIR_Real)) When /*lBxJuros .or.*/ (lAutomatico .and. Left((cAliasAux)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2))
   EndIf

If cMod == EXP
   oSay1:= TSay():New(0, 5,&("{|| '"+aLabels[2][5]+"'}"),oPanel,,,,,,.T.,,, 50, 8)
   oSay1:Align := CONTROL_ALIGN_TOP

   oPanel2 := TPanel():New(0, 0, ,oPanel, , .F., .F., , , 10, 10, , )
   oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

   oMark3:= MsSelect():New("WorkVinc",,,aSelCposVinc,@lInverte,@cMarca,{(oDlg:nBottom/2)-164,oDlg:nLeft-4,(oDlg:nBottom/2)-105,(oDlg:nRight/2)-12},,,oPanel2)
   oMark3:oBrowse:Align := CONTROL_ALIGN_TOP
EndIf

If cMod == EXP
   oPanel3 := TPanel():New(0, 0, ,oPanel2, , .F., .F., , , 10, 10, , )
   oPanel3:Align := CONTROL_ALIGN_ALLCLIENT

   oSay2:= TSay():New(0, 5,&("{|| '"+aLabels[3][5]+"'}"),oPanel3,,,,,,.T.,,, 50, 8)
   oSay2:Align := CONTROL_ALIGN_TOP

   oMark4:= MsSelect():New("WorkLiq" ,,,aSelCposLiq,@lInverte,@cMarca,{(oDlg:nBottom/2)-91,oDlg:nLeft-4,(oDlg:nBottom/2)-17,(oDlg:nRight/2)-12},,,oPanel3)
   oMark4:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
EndIf
oDlg:lMaximized := .T.
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nSelecao:=1,oDlg:End()},{||nSelecao:=0,oDlg:End()},,aBotoes) CENTERED

If !(cChamada $ "CAMB/FFC")// PLB 10/05/06
   aHeader := aClone(aHeaderAux)
   aCols   := aClone(aColsAux)
EndIf

If nSelecao = 1

      If lBlock

            /* WFS set-16 */
            lLocked:= .F.
            If !IsLocked()
            (cAliasAux)->(RecLock(cAliasAux, .F.))
            lLocked:= .T.
            EndIf

            If AvFlags("EEC_LOGIX")                                                  //NCF - 11/09/2014
            AF200BkPInt( cAliasAux , "EFF_INBX_ALT",,{'EF1',EF1->(Recno())},,)
            EndIf

            If lCpoDtLqEv
                  If (cAliasAux)->EF3_DTOREV < M->EF3_DT_EVE
                        PTipo := "LQ_JR_ANT"                                                  //NCF - 21/05/2014 - Liquidacao de Juros Antecipado(sem reapuração de valor)
                  Else
                        PTipo := "LQ_JR_NRM"
                  EndIf

                  If PTipo == "LQ_JR_ANT"
                        (cAliasAux)->EF3_DTOREV := M->EF3_DTOREV             //NCF - 21/08/2014 - Tratamento do campo removido para dentro do bloco que valida se o mesmo existe.
                  Else
                        //RMD - 01/12/14 - Considerar a data de liquidação digitada na tela.
                        //WORKEF3->EF3_DTOREV := If( !Empty(aCols[i,GdFieldPos("EF3_DT_EVE")]) , aCols[i,GdFieldPos("EF3_DT_EVE")], dDataBase)
                        (cAliasAux)->EF3_DTOREV := If(!Empty(M->EF3_DTOREV) , M->EF3_DTOREV , M->EF3_DT_EVE)
                  EndIf
            EndIf

            If lTemChave
                  (cAliasAux)->EF3_BANC   := M->EF3_BANC
                  (cAliasAux)->EF3_AGEN   := M->EF3_AGEN
                  (cAliasAux)->EF3_NCON   := M->EF3_NCON
                  (cAliasAux)->EF3_OBS    := M->EF3_OBS
                  (cAliasAux)->EF3_NROP   := M->EF3_NROP
            EndIf


            /* WFS set-16 */
            If lLocked
                  (cAliasAux)->(MsUnlock())
            EndIf
            If cAliasEF1 == "EF1"
                  RegToMemory(cAliasEF1)
            EndIf
            If lAutomatico .AND. ValType(nRecLastEF3) == "N"
                  (cAliasAux)->(dbGoTo(nRecLastEF3))
            EndIf

            //If !lBxJuros
            nOldRec := (cAliasAux)->(RecNo())

            If !( (cAliasAux)->EF3_CODEVE == EV_PRINC_PREPAG  .Or.  Left((cAliasAux)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2) )  // ** PLB 23/06/06
                  (cAliasAux)->(dbGoTo(nRecLastEF3))

                  EX400Liquida(M->EF1_CONTRA,(cAliasAux)->EF3_INVOIC,(cAliasAux)->EF3_PARC,(cAliasAux)->EF3_PREEMB,If((cAliasAux)->EF3_CODEVE==EV_LIQ_PRC,(cAliasAux)->EF3_VL_INV,(cAliasAux)->EF3_VL_MOE),;
                              (cAliasAux)->EF3_MOE_IN,M->EF1_MOEDA,/*"M"*/cAliasEF1,cAliasAux,/*"MANUT2"*/cChamada,M->EF3_TX_MOE,M->EF3_DT_EVE,M->EF3_DT_EVE,/*M->EF3_DT_EVE*/M->EF3_DTOREV,If(lMultiFil,(cAliasAux)->EF3_FILORI,),,,,,;
                              If(lTemChave,M->EF1_BAN_FI,),If(lTemChave,M->EF1_AGENFI,),If(lTemChave,M->EF1_NCONFI,),;
                              If(lTemChave,M->EF1_PRACA,),,M->EF3_VL_REA,NIL,NIL, If(lAutomatico, nRecLastEF3, 0),If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,""),; //cSeqCon
                              ,;//cOrigem
                              ,;//cForn
                              ,;//cLojaFo
                              ,;//cPo_Di
                              ,;//nVlMoeLiq
                              ,;//lEveRefi
                              lAutomatico)//lExecLiq)
            Else

                  EX400Liquida(M->EF1_CONTRA,/*WorkEF3->EF3_INVIMP*/"",/*WorkEF3->EF3_LINHA*/"",/*WorkEF3->EF3_HAWB*/"",(cAliasAux)->EF3_VL_MOE,;
                              (cAliasAux)->EF3_MOE_IN,M->EF1_MOEDA,/*"M"*/cAliasEF1,cAliasAux,/*"MANUT2"*/cChamada,M->EF3_TX_MOE,M->EF3_DT_EVE,,/*M->EF3_DT_EVE*/M->EF3_DTOREV,If(lMultiFil,(cAliasAux)->EF3_FILORI,),,,,,;
                              If(lTemChave,M->EF1_BAN_FI,),If(lTemChave,M->EF1_AGENFI,),If(lTemChave,M->EF1_NCONFI,),;
                              If(lTemChave,M->EF1_PRACA,),,M->EF3_VL_REA,NIL,NIL, If(lAutomatico, nRecLastEF3, 0),If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,""),;
                              /*If(cMod==IMP,WorkEF3->EF3_ORIGEM,)*/"",/*If(cMod==IMP,WorkEF3->EF3_FORN,)*/"",/*If(cMod==IMP,WorkEF3->EF3_LOJAFO,)*/"",/*If(cMod==IMP,WorkEF3->EF3_PO_DI,)*/"",;//)  // PLB 13/06/06 - Esta posicionado no evento 700, por isso nao passa parametros comentados
                              ,;//nVlMoeLiq
                              lAutomatico)//lExecLiq)
            EndIf
            (cAliasAux)->(dbGoTo(nOldRec))

            If M->EF1_TP_FIN == "05" .AND. lRefinimp //LRS - 01/12/2017
                  aAdd(aRefinimp,{"LIQ",(cAliasAux)->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVIMP+EF3_LINHA),(cAliasAux)->EF3_TX_MOE,(cAliasAux)->EF3_VL_REA,M->EF1_MOEDA})
            EndIf

            If AvFlags("EEC_LOGIX")                                                  //NCF - 11/09/2014
                  AF200BkPInt( cAliasAux , "EFF_INBX_INC",,{'EF1',EF1->(Recno())},,)
            EndIf

            // ** GFC - 17/08/05 - Caso o saldo restante do contrato esteja menor que o valor informado no MV_EFF0002
            //                    deve preencher a data de encerramento automaticamente.
            //If M->EF1_SLD_PM < nEFF0002 .and. IIF(lEFFTpMod .And. M->EF1_CAMTRA == "1" ,M->EF1_SLD_JM == 0,!EX401JrOpen("M",cAliasAux))
               //EX401Encerra(M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,M->EF1_SLD_PM,"M",M->EF3_DT_EVE,NIL,NIL,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
            //EndIf
      // **
      ElseIf lAutomatico .and. Left((cAliasAux)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2)
            // ** GFC - 25/09/05 - IR
            /*EX401GrvIR("EF3","EF1",nVlIR, nVlIR_Old, dDtIR, nTxIR, nVlIR_Real,EF1->EF1_CONTRA,cInv,;
            cParc,cPreemb,EF3->EF3_MOE_IN,EF3->EF3_CODEVE,EF3->EF3_PARC,;
            EF3->EF3_NROP,cSeq,If(lTemChave,EF3->EF3_BANC,""),If(lTemChave,EF3->EF3_AGEN,""),;
            If(lTemChave,EF3->EF3_NCON,""),If(lTemChave,EF3->EF3_PRACA,""),If(lMultiFil,EF3->EF3_FILORI,),;
            EF3->EF3_CODEVE,aAchouIR[1],If(lEFFTpMod,EF3->EF3_TPMODU,""),If(lEFFTpMod,EF3->EF3_SEQCNT,""))*/
            // **

   // **  PLB 23/10/06 - Verifica se é estorno de parcela de pagamento
      ElseIf lEstorno  .And.  ( (cAliasAux)->EF3_CODEVE == EV_PRINC_PREPAG  .Or.  Left((cAliasAux)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2) )
            nRecParc := (cAliasAux)->( RecNo() )
            If lRefinimp .AND. (cAliasAux) == "WorkEF3"  // GFP - 09/10/2015
                  aAdd(aRefinimp,{"EST",(cAliasAux)->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVIMP+EF3_LINHA)+EV_LIQ_PRC})
            EndIf
            EX400EstEv( (cAliasAux)->EF3_SEQ , "LIQ" , .T.)
            If cAliasAux == "WorkEF3"
                  WorkEF3->( DBSetOrder(5) )
                  WorkEF3->( DBSeek(EV_PRINC) )
                  nTx100 := WorkEF3->EF3_TX_MOE
                  WorkEF3->( DBSetOrder(1) )
            ElseIf cAliasAux == "EF3"
                  If EF3->( DBSeek(EF3_FILIAL+IIF(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+IIF(lTemChave,EF3_BAN_FI+EF3_PRACA,"")+IIF(lEFFTpMod,EF3_SEQCNT,"")+EV_PRINC) )
                        nTx100 := EF3->EF3_TX_MOE
                  EndIf
            EndIf
            (cAliasAux)->( DBGoTo(nRecParc) )
            RecLock(cAliasAux,.F.)
            If (cAliasAux)->EF3_CODEVE == EV_PRINC_PREPAG
                  M->EF1_SLD_PM += (cAliasAux)->EF3_VL_MOE
                  M->EF1_SLD_PR := M->EF1_SLD_PM * nTx100
                  M->EF1_LIQPRM -= (cAliasAux)->EF3_VL_MOE
                  M->EF1_LIQPRR -= (cAliasAux)->EF3_VL_REA
            ElseIf Left((cAliasAux)->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)
                  M->EF1_SLD_JM += (cAliasAux)->EF3_VL_MOE
                  M->EF1_SLD_JR := M->EF1_SLD_JM * nTx100
                  M->EF1_LIQJRM -= (cAliasAux)->EF3_VL_MOE
                  M->EF1_LIQJRR -= (cAliasAux)->EF3_VL_REA
            EndIf
            (cAliasAux)->EF3_TX_MOE := 0
            (cAliasAux)->EF3_VL_REA := 0
            (cAliasAux)->EF3_SLDLIQ := (cAliasAux)->EF3_VL_MOE
            (cAliasAux)->EF3_LIQ_RS := 0
            //NCF - 25/03/2014 - Limpa a data de liquidação de juros antecip. PPE no estorno desta liquidacao
            If (cAliasAux)->(FieldPos("EF3_DTOREV")) > 0 .And. !Empty((cAliasAux)->EF3_DTOREV)
                  (cAliasAux)->EF3_DTOREV := Ctod("  /  /  ")
            EndIf
            (cAliasAux)->( MSUnLock() )
            If cAliasAux == "WorkEF3"
                  oMark:oBrowse:Refresh()
            EndIf
      // **
      EndIf

      // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
      if cAliasAux == "WorkEF3" .and. WorkEF3->( fieldpos("ALTERADO") ) > 0
            WorkEF3->( dbgoto(nRecWKEF3))
            WorkEF3->ALTERADO := .T.
      endif

ElseIf lAutomatico .and. Left((cAliasAux)->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2)

      // ** GFC - 25/09/05 - IR
      /*EX401GrvIR("EF3","EF1",nVlIR, nVlIR_Old, dDtIR, nTxIR, nVlIR_Real,EF1->EF1_CONTRA,cInv,;
      cParc,cPreemb,EF3->EF3_MOE_IN,EF3->EF3_CODEVE,EF3->EF3_PARC,;
      EF3->EF3_NROP,cSeq,If(lTemChave,EF3->EF3_BANC,""),If(lTemChave,EF3->EF3_AGEN,""),;
      If(lTemChave,EF3->EF3_NCON,""),If(lTemChave,EF3->EF3_PRACA,""),If(lMultiFil,EF3->EF3_FILORI,),;
      EF3->EF3_CODEVE,aAchouIR[1],If(lEFFTpMod,EF3->EF3_TPMODU,""),If(lEFFTpMod,EF3->EF3_SEQCNT,""))*/
      // **

EndIf

If !lAutomatico
   (cAliasAux)->(dbSetOrder(ORDEM_BROWSE))
EndIf

If Select("WorkVinc") <> 0
   WorkVinc->(dbCloseArea())
   FErase(fWorkVinc)
EndIf
If Select("WorkLiq") <> 0
   WorkLiq->(dbCloseArea())
   FErase(fWorkLiq)
EndIf

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato
If !lAutomatico
   EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),cAliasAux,.T.)
EndIf

Return .T.

*------------------------------------------------------------------------------------------------------*
Function ExGrvWkLiq(cAliasAux)
*------------------------------------------------------------------------------------------------------*
Local ni, nOrd:=(cAliasAux)->(IndexOrd()), cEvVin:=(cAliasAux)->EF3_CODEVE, cParcVin:=(cAliasAux)->EF3_PARC
Local nRec:=(cAliasAux)->(RecNo())

If cAliasAux == "WorkEF3"
   WorkEF3->(dbSetOrder(2))
EndIf

(cAliasAux)->(dbSeek(If(cAliasAux=="EF3",xFilial('EF3')+If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),"")+EV_EMBARQUE))
Do While !(cAliasAux)->(EOF()) .and. If(cAliasAux=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and. If(lEFFTpMod,EF3->EF3_TPMODU == EF1->EF1_TPMODU,.T.) .AND.;
EF3->EF3_CONTRA==EF1->EF1_CONTRA .and. EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == EF1->EF1_SEQCNT,.T.),.T.) .and.;
(cAliasAux)->EF3_CODEVE == EV_EMBARQUE
   If (cAliasAux)->EF3_EV_VIN == cEvVin .and. (cAliasAux)->EF3_PARVIN == cParcVin
      dbSelectArea("WorkVinc")
      WorkVinc->(reclock("WorkVinc",.T.))
      FOR ni := 1 TO FCount()
         If !FIELDNAME(ni) $ ("EF3_DESCEV/EF3_RECNO/") .AND. (cAliasAux)->(FieldPos(WorkVinc->(FieldName(ni)))) > 0
            //WorkVinc->&(FIELDNAME(ni)) := (cAliasAux)->&(WorkVinc->(FIELDNAME(ni)))
            WorkVinc->(FieldPut(ni,(cAliasAux)->(FieldGet(FieldPos(WorkVinc->(FieldName(ni)))))))
         EndIf
      NEXT ni
   EndIf
   (cAliasAux)->(dbSkip())
EndDo

If cEvVin == EV_PRINC_PREPAG
   (cAliasAux)->(dbSeek(If(cAliasAux=="EF3",xFilial('EF3')+If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),"")+EV_LIQ_PRC))
   Do While !(cAliasAux)->(EOF()) .and. If(cAliasAux=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and. If(lEFFTpMod,EF3->EF3_TPMODU == EF1->EF1_TPMODU,.T.) .AND.;
   EF3->EF3_CONTRA==EF1->EF1_CONTRA .and. EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == EF1->EF1_SEQCNT,.T.),.T.) .and.;
   (cAliasAux)->EF3_CODEVE == EV_LIQ_PRC
      If (cAliasAux)->EF3_EV_VIN == cEvVin .and. (cAliasAux)->EF3_PARVIN == cParcVin
         dbSelectArea("WorkLiq")
         nRecLastEF3 := (cAliasAux)->(RecNo())
         WorkLiq->(reclock("WorkLiq",.T.))
         FOR ni := 1 TO FCount()
            If !FIELDNAME(ni) $ ("EF3_DESCEV/EF3_RECNO/") .AND. (cAliasAux)->(FieldPos(WorkLiq->(FieldName(ni)))) > 0
               //WorkLiq->&(FIELDNAME(ni)) := (cAliasAux)->&(WorkLiq->(FIELDNAME(ni)))
               WorkLiq->(FieldPut(ni,(cAliasAux)->(FieldGet(FieldPos(WorkLiq->(FieldName(ni)))))))
            EndIf
         NEXT ni
      EndIf
      (cAliasAux)->(dbSkip())
   EndDo
Else
   (cAliasAux)->(dbSeek(If(cAliasAux=="EF3",xFilial('EF3')+If(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+If(lEFFTpMod,EF1->EF1_SEQCNT,""),"")+Left(EV_LIQ_JUR,2)))
   Do While !(cAliasAux)->(EOF()) .and. If(cAliasAux=="EF3",EF3->EF3_FILIAL==xFilial('EF3') .and. If(lEFFTpMod,EF3->EF3_TPMODU == EF1->EF1_TPMODU,.T.) .AND.;
   EF3->EF3_CONTRA==EF1->EF1_CONTRA .and. EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA .AND. If(lEFFTpMod,EF3->EF3_SEQCNT == EF1->EF1_SEQCNT,.T.),.T.) .and.;
   Left((cAliasAux)->EF3_CODEVE,2) ==Left(EV_LIQ_JUR,2)
      If (cAliasAux)->EF3_EV_VIN == cEvVin .and. (cAliasAux)->EF3_PARVIN == cParcVin
         dbSelectArea("WorkLiq")
         nRecLastEF3 := (cAliasAux)->(RecNo())
         WorkLiq->(reclock("WorkLiq",.T.))
         FOR ni := 1 TO FCount()
            If !FIELDNAME(ni) $ ("EF3_DESCEV/EF3_RECNO/EF3_NUMTIT/EF3_PARTIT")
               //WorkLiq->&(FIELDNAME(ni)) := (cAliasAux)->&(WorkLiq->(FIELDNAME(ni)))
               WorkLiq->(FieldPut(ni,(cAliasAux)->(FieldGet(FieldPos(WorkLiq->(FieldName(ni)))))))
            EndIf
         NEXT ni
      EndIf
      (cAliasAux)->(dbSkip())
   EndDo
EndIf

WorkVinc->(dbGoTop())
WorkLiq->(dbGoTop())

(cAliasAux)->(dbSetOrder(nOrd))
(cAliasAux)->(dbGoTo(nRec))

Return .T.

*----------------------------------------------------------------------------------------------------*
Function EX401Copia()
*----------------------------------------------------------------------------------------------------*
EX400Manut("EF1",EF1->(RecNo()),3,,.T.)
Return .T.

*---------------------------------------------------------------------------------------------------*
Function EX401BxForc(lEnc)
*---------------------------------------------------------------------------------------------------*
Local oPanel, nSelecao:=0
Local cInvoic:=WorkEF3->EF3_INVOIC, cParc:=WorkEF3->EF3_PARC, cPreemb:=WorkEF3->EF3_PREEMB
Local nVl:=WorkEF3->EF3_VL_MOE, cMoeInv:=WorkEF3->EF3_MOE_IN
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Private nTaxa:=0, dDtCe:=AVCtoD("  /  /  "), dDtNe:=AVCtoD("  /  /  ")
Private dDtPgt:=AVCtoD("  /  /  "), cNrOp:=WorkEF3->EF3_NROP
If lEFFTpMod
   Private dDtCnt     := WorkEF3->EF3_DT_CNT        ,;
           cBcMov     := WorkEF3->EF3_BC_MOV        ,;
           cDescBCMov := Space(Len(SA6->A6_NREDUZ)) ,;
           cAgMov     := WorkEF3->EF3_AG_MOV        ,;
           cCcMov     := WorkEF3->EF3_CC_MOV        ,;
           dDtDes     := WorkEF3->EF3_DT_DES
EndIf
Private nVlMoe:=WorkEF3->EF3_VL_MOE, nVlRea:=WorkEF3->EF3_VL_REA

If lTemChave
   Private cBanco:=Space(Len(EF3->EF3_BANC)), cAgencia:=Space(Len(EF3->EF3_AGEN))
   Private cConta:=Space(Len(EF3->EF3_NCON)), cDescBanco:=Space(Len(SA6->A6_NREDUZ))
//   Private cPraca:=Space(Len(EF3->EF3_PRACA)), cDescPraca:=Space(Len(EF5->EF5_DESCRI))
EndIf
Private LnFinal:=24, cLin:=39, oDlg //LnFinal:=21 - FSM - 10/04/2012
Private cGetCust1:="", cGetCust2:="", cGetCust3:="", cGetCust4:="", cGetCust5:=""
Private dGetCust1
Private lEncargo := lEnc

If lEncargo = NIL
   lEncargo := .F.
ElseIf lEncargo
   LnFinal := 36
EndIf

If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"ANTES_BAIXA_VINCULAÇÃO"),)

DEFINE MSDIALOG oDlg TITLE If(!lEncargo,STR0013,"Baixa de encargo") ; //"Baixa da Vinculação"
FROM 12,05 TO LnFinal,75 OF oMainWnd //PIXEL

   If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"TELA_BAIXA_VINCULAÇÃO1"),)

   If !lEncargo
      @cLin,5 SAY AVSX3("EF3_TX_MOE",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,50 MSGET nTaxa PICTURE AVSX3("EF3_TX_MOE",6) Valid (BxFrcValid("TAXA")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EEQ_DTCE",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,198 MSGET dDtCe PICTURE AVSX3("EEQ_DTCE",6) Valid (BxFrcValid("DTCE")) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EEQ_DTNEGO",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET dDtNe PICTURE AVSX3("EEQ_DTNEGO",6) Valid (BxFrcValid("DTNEGO")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EEQ_PGT",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,198 MSGET dDtPgt PICTURE AVSX3("EEQ_PGT",6) Valid (BxFrcValid("DT_PGT")) SIZE 65,08 PIXEL of oDlg
      cLin += 11
   EndIf

   If lTemChave
      @cLin,5 SAY AVSX3("EF3_BANC",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,50 MSGET cBanco PICTURE AVSX3("EF3_BANC",6) F3 "BC6" Valid (BxFrcValid("BANCO")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_AGEN",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET cAgencia PICTURE AVSX3("EF3_AGEN",6) Valid (BxFrcValid("AGENCIA")) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_NCON",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET cConta PICTURE AVSX3("EF3_NCON",6) Valid (BxFrcValid("CONTA")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("A6_NREDUZ",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET cDescBanco PICTURE AVSX3("A6_NREDUZ",6) Valid (BxFrcValid("DESC_BANCO")) SIZE 65,08 PIXEL of oDlg
      cLin += 11

   EndIf

   If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"TELA_BAIXA_VINCULAÇÃO2"),)

   If lEncargo
      @cLin,5 SAY AVSX3("EF3_NROP",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET cNrOp PICTURE AVSX3("EF3_NROP",6) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_DT_CNT",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET dDtCnt PICTURE AVSX3("EF3_DT_CNT",6) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_DT_DES",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET dDtDes PICTURE AVSX3("EF3_DT_DES",6) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"TELA_BAIXA_VINCULAÇÃO3"),)

      @cLin,5 SAY AVSX3("WB_CA_DT",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,50 MSGET dDtPgt PICTURE AVSX3("EEQ_DTCE",6) Valid (BxFrcValid("DT_PGT")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_TX_MOE",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,198 MSGET nTaxa PICTURE AVSX3("EF3_TX_MOE",6) F3 "E18" Valid (BxFrcValid("TAXA")) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_VL_MOE",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET nVlMoe PICTURE AVSX3("EF3_VL_MOE",6) When .F. SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_VL_REA",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET nVlRea PICTURE AVSX3("EF3_VL_REA",6) When .F. SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_BC_MOV",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,50 MSGET cBcMov PICTURE AVSX3("EF3_BC_MOV",6) F3 "BC6" Valid (BxFrcValid("BC_MOV")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_AG_MOV",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET cAgMov PICTURE AVSX3("EF3_AG_MOV",6) When .F. SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_CC_MOV",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET cCcMov PICTURE AVSX3("EF3_CC_MOV",6) When .F. SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY STR0083 SIZE 40,8 PIXEL of oDlg  //"Descr Banco"
      @cLin,198 MSGET cDescBcMov When .F. SIZE 65,08 PIXEL of oDlg
      cLin += 11
   EndIf

   If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"TELA_BAIXA_VINCULAÇÃO4"),)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(BxFrcValid("GRAVA") ,Eval({||nSelecao:=1,oDlg:End()}),)},{||nSelecao:=0,oDlg:End()}) CENTERED

If nSelecao = 1
   If !lEncargo
      EX400Liquida(M->EF1_CONTRA,cInvoic,cParc,cPreemb,nVl,;
      cMoeInv,M->EF1_MOEDA,"M","WorkEF3","BXFORC",nTaxa,dDtCe,If(!Empty(dDtNe),dDtNe,dDtPgt),dDtPgt,If(lMultiFil,WorkEF3->EF3_FILORI,),;
      ,,,,If(lTemChave,cBanco,),If(lTemChave,cAgencia,),If(lTemChave,cConta,),If(lTemChave,M->EF1_PRACA,),.T.,NIL,NIL,NIL,NIL,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
   Else
      WorkEF3->EF3_DT_EVE := If(!lEncargo, dDtCe, dDtPgt)
      WorkEF3->EF3_TX_MOE := nTaxa
      WorkEF3->EF3_VL_REA := Round(WorkEF3->EF3_VL_MOE * nTaxa, nDecValor)
      WorkEF3->EF3_BANC   := cBanco
      WorkEF3->EF3_AGEN   := cAgencia
      WorkEF3->EF3_NCON   := cConta

      WorkEF3->EF3_NROP   := cNrOp
      WorkEF3->EF3_DT_CNT := dDtCnt
      WorkEF3->EF3_BC_MOV := cBcMov
      WorkEF3->EF3_AG_MOV := cAgMov
      WorkEF3->EF3_CC_MOV := cCcMov

      // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
      if WorkEF3->( fieldpos("ALTERADO") ) > 0
            WorkEF3->ALTERADO := .T.
      endif

      If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"GRAVA_BAIXA_VINCULAÇÃO_ENCARGO"),)
   EndIf
      
      If WorkEF3->(FieldPos("EF3_DTOREV")) > 0
         WorkEF3->EF3_DTOREV := WorkEF3->EF3_DT_EVE
      EndIf

EndIf

WorkEF3->(dbSetOrder(ORDEM_BROWSE))

Return .T.

*-------------------------------------------------------------------------------------------*
Static Function BxFrcValid(cCampo)
*-------------------------------------------------------------------------------------------*
Private lRet:=.T., cCpoValid:=cCampo

Do Case
   Case cCampo == "TAXA"
      If !Positivo(nTaxa)
         lRet:=.F.
      Else
         nVlRea := nVlMoe * nTaxa
      EndIf

   Case cCampo == "DTCE"
      If !Empty(dDtNe) .and. !Empty(dDtCe) .and. dDtNe < dDtCe
         MsgInfo(STR0014) //"Data de Negociação não pode ser menor que a Data de Crédito no Exterior."
         lRet := .F.
      EndIf

   Case cCampo == "DTNEGO"
      If !Empty(dDtNe) .and. !Empty(dDtCe) .and. dDtNe < dDtCe
         MsgInfo(STR0014) //"Data de Negociação não pode ser menor que a Data de Crédito no Exterior."
         lRet := .F.
      ElseIf !Empty(dDtPgt) .and. !Empty(dDtNe) .and. dDtPgt < dDtNe
         MsgInfo(STR0015) //"Data de Liquidação não pode ser menor que a Data de Negociação."
         lRet := .F.
      EndIf

   Case cCampo == "DT_PGT"
      If !Empty(dDtPgt) .and. !Empty(dDtNe) .and. dDtPgt < dDtNe
         MsgInfo(STR0015) //"Data de Liquidação não pode ser menor que a Data de Negociação"
         lRet := .F.
      ElseIf lEncargo .AND. !Empty(WorkEF3->EF3_DT_EVE) .and. dDtPgt < WorkEF3->EF3_DT_EVE
         MsgInfo("A Data de Liquidação não pode ser menor que a data do encargo.")
         lRet := .F.
      ElseIf !lEncargo .AND. !Empty(WorkEF3->EF3_DT_EVE) .and. dDtPgt < WorkEF3->EF3_DT_EVE
         MsgInfo(STR0033) //"A Data de Liquidação não pode ser menor que a data de vinculação."
         lRet := .F.
      ElseIf dDtPgt > dDataBase
         MsgInfo(STR0034) //"A Data de Liquidação não pode ser maior que a data corrente do sistema."
         lRet := .F.
      Else
         nTaxa := BuscaTaxa(M->EF1_MOEDA,dDtPgt,,.F.,.T.)
      EndIf

   Case cCampo == "BANCO"
      If !Empty(cBanco) .and. !SA6->(dbSeek(xFilial("SA6")+cBanco+If(!Empty(cAgencia),cAgencia,"")+iif(!Empty(cConta),cConta,"")))
         MsgInfo(STR0084+If(!Empty(cAgencia),STR0085,"")+If(!Empty(cConta),STR0086,"")+STR0087)  //"Banco " "+ Agencia " "+ Conta " "não encontrado."
         lRet := .F.
      ElseIf !Empty(cBanco) .and. Empty(cAgencia)
         cAgencia   := SA6->A6_AGENCIA
         cConta     := SA6->A6_NUMCON
         cDescBanco := SA6->A6_NREDUZ
      EndIf

      // MPG - 26/10/2018 - VALIDAÇÃO PARA QUE NÃO PERMITA O CADASTRO DE UM BANCO COM AS MOEDAS DIFERENTES DE ACORDO COM MÓDULOS E PARÂMETROS
      if SYF->( dbsetorder(1),dbseek(xfilial("SYF")+SA6->A6_MOEEASY) ) .and. SA6->A6_MOEDA <> SYF->YF_MOEFAT
            lRet := .F.
            msgstop(STR0197,STR0117) //"Esse banco não pode ser ultilizado, pois os campos de moeda não podem estar diferentes um do outro.","Aviso"
      endif

   Case cCampo == "AGENCIA"
      If !Empty(cBanco) .and. !Empty(cAgencia) .and. !SA6->(dbSeek(xFilial("SA6")+cBanco+;
      If(!Empty(cAgencia),cAgencia,"")+If(!Empty(cConta),cConta,"")))
         MsgInfo(STR0084+If(!Empty(cAgencia),STR0085,"")+If(!Empty(cConta),STR0086,"")+STR0087)  //"Banco " "+ Agencia " "+ Conta " "não encontrado."
         lRet := .F.
      EndIf

   Case cCampo == "CONTA"
      If !Empty(cBanco) .and. !Empty(cAgencia) .and. !Empty(cConta) .and.;
      !SA6->(dbSeek(xFilial("SA6")+cBanco+If(!Empty(cAgencia),cAgencia,"")+If(!Empty(cConta),cConta,"")))
         MsgInfo(STR0084+If(!Empty(cAgencia),STR0085,"")+If(!Empty(cConta),STR0086,"")+STR0087)  //"Banco " "+ Agencia " "+ Conta " "não encontrado."
         lRet := .F.
      EndIf

   Case cCampo == "BC_MOV"
      If !Empty(cBcMov) .and. !SA6->(dbSeek(xFilial("SA6")+cBcMov+If(!Empty(cAgMov),cAgMov,"")+;
      If(!Empty(cCcMov),cCcMov,"")))
         MsgInfo(STR0084+If(!Empty(cAgMov),STR0085,"")+If(!Empty(cCcMov),STR0086,"")+STR0087)  //"Banco " "+ Agencia " "+ Conta " "não encontrado."
         lRet := .F.
      ElseIf !Empty(cBcMov) .and. Empty(cAgMov)
         cAgMov     := SA6->A6_AGENCIA
         cCcMov     := SA6->A6_NUMCON
         cDescBcMov := SA6->A6_NREDUZ
      ElseIf Empty(cBcMov)
         cAgMov     := Space(Len(SA6->A6_AGENCIA))
         cCcMov     := Space(Len(SA6->A6_NUMCON))
         cDescBcMov := Space(Len(SA6->A6_NREDUZ))
      EndIf

   Case cCampo == "GRAVA"
      If nTaxa = 0
         MsgInfo(STR0016) //"A taxa de conversão deve ser informada para a baixa forçada."
         lRet := .F.
      ElseIf Empty(dDtCe) .and. !lEncargo
         MsgInfo(STR0017) //"A Data de Crédito no Exterior deve ser preenchida para a baixa forçada."
         lRet := .F.
      ElseIf Empty(dDtPgt)
         MsgInfo(STR0018) //"A Data de Liquidação deve ser preenchida para a baixa forçada."
         lRet := .F.
      ElseIf Empty(cBanco)
         MsgInfo(STR0019) //"O Banco deve ser preenchido para a baixa forçada."
         lRet := .F.
      ElseIf !Positivo(nTaxa)
         lRet:=.F.
      ElseIf !Empty(dDtNe) .and. !Empty(dDtCe) .and. dDtNe < dDtCe
         MsgInfo(STR0014) //"Data de Negociação não pode ser menor que a Data de Crédito no Exterior"
         lRet := .F.
      ElseIf !Empty(dDtPgt) .and. !Empty(dDtNe) .and. dDtPgt < dDtNe
         MsgInfo(STR0015) //"Data de Liquidação não pode ser menor que a Data de Negociação"
         lRet := .F.
      ElseIf !Empty(cBanco) .and. !SA6->(dbSeek(xFilial("SA6")+cBanco+If(!Empty(cAgencia),cAgencia,"")+;
      If(!Empty(cConta),cConta,"")))
         MsgInfo(STR0084+If(!Empty(cAgencia),STR0085,"")+If(!Empty(cConta),STR0086,"")+STR0087)  //"Banco " "+ Agencia " "+ Conta " "não encontrado."
         lRet := .F.
      ElseIf lEFFTpMod .And. !Empty(cBcMov) .and. !SA6->(dbSeek(xFilial("SA6")+cBcMov+If(!Empty(cAgMov),cAgMov,"")+;
      If(!Empty(cCcMov),cCcMov,"")))
         MsgInfo(STR0084+If(!Empty(cAgMov),STR0085,"")+If(!Empty(cCcMov),STR0086,"")+STR0087)  //"Banco " "+ Agencia " "+ Conta " "não encontrado."
         lRet := .F.
      EndIf

EndCase

If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"BxForcValid"),)

Return lRet

*-------------------------------------------------------------------------------------------*
Function EX401DelBxF()
*-------------------------------------------------------------------------------------------*
Local nOrdEF3
Private cInv:=WorkEF3->EF3_INVOIC, cParc:=WorkEF3->EF3_PARC, cPreemb:=WorkEF3->EF3_PREEMB
Private cMoeIn:=WorkEF3->EF3_MOE_IN, nTxMoe:=WorkEF3->EF3_TX_MOE, dDtEve:=WorkEF3->EF3_DT_EVE
Private nVlInv:=WorkEF3->EF3_VL_INV, cSeqAux:=WorkEF3->EF3_SEQ

If If(!Empty(WorkEF3->EF3_NR_CON),MsgYesNo(STR0020),.T.) //"ATENÇÃO! Evento já contabilizado. Confirma exclusão?"
   EX400EstEV(WorkEF3->EF3_SEQ)
   If dDataBase > WorkEF3->EF3_DT_EVE .and. !Empty(WorkEF3->EF3_NR_CON)// Gera V.C refentes ao periodo em que houve liquidaçao
      EX400GeraE("ESTORNO_BX_FORC")     
   Endif
EndIf

nOrdEF3:= WorkEF3->(IndexOrd())
WorkEF3->(dbSetOrder(2))
//If lEF3_EV_FO
   If WorkEF3->(dbSeek(EV_EMBARQUE+cInv+cParc))  //600
      WorkEF3->EF3_EV_FO := ""
   EndIf
//EndIf
WorkEF3->(dbSetOrder(nOrdEF3))

Return .T.

*-------------------------------------------------------------------------------------------------------------------------*
Function EX401Encerra(cContrato,cBanco,cPraca,nSaldo,cAliasEF1,dDtEnc,lMostraJur,lPergunta,cTpMod,cSeqCon,nSaldoJur)
*-------------------------------------------------------------------------------------------------------------------------*
Local nLin := 0  // PLB - 08/06/06
Local oDlgEnc, nOpc:=0, lReturn:=.T.
Local nPosEncContra := 0
If(lMostraJur=NIL, lMostraJur:=.F.,)
If(lPergunta=NIL , lPergunta :=.T.,)

nLin := 2.0

if IsMemVar("lExecAuto") .and. lExecAuto
   if (nPosEncContra := ascan( aAutoItens , {|x| x[1]=="AUTENCERRACONTRA"} )) > 0
      if aAutoItens[nPosEncContra][2] == "N"
         nOpc := 0
      else
         nOpc := 1
      endif
   else
      nOpc := 1
   endif
else
	DEFINE MSDIALOG oDlgEnc TITLE STR0021 ; //"Encerramento do processo."
	FROM 15,03 To 32,47 OF oMainWnd

	   If lPergunta
		  @0.5,0.5  SAY STR0022 //"O Contrato de financiamento pode ser encerrado?"
	   Else
		  @0.5,0.5  SAY STR0023 //"Usuário sem autorização para encerrar contratos com saldo."
	   EndIf
	   @nLin,3    SAY AVSX3("EF1_CONTRA",5) SIZE 50,8
	   @nLin,10.5 MSGET cContrato PICTURE "@!" WHEN .F. SIZE 60,7
	   nLin += 1.0  // PLB 08/06/06
	   @nLin,3    SAY AVSX3("EF1_BAN_FI",5) SIZE 50,8
	   @nLin,10.5 MSGET cBanco PICTURE "@!" WHEN .F. SIZE 60,7
	   nLin += 1.0  // PLB 08/06/06
	   @nLin,3    SAY AVSX3("EF1_PRACA",5) SIZE 50,8
	   @nLin,10.5 MSGET cPraca PICTURE "@!" WHEN .F. SIZE 60,7
	   // ** PLB 08/06/06
	   If lEFFTpMod
		  nLin += 1.0
		  @nLin,3    SAY AVSX3("EF1_SEQCNT",5) SIZE 50,8
		  @nLin,10.5 MSGET cSeqCon PICTURE "@!" WHEN .F. SIZE 60,7
	   EndIf
	   // **
	   nLin += 1.0  // PLB 08/06/06
	   If IIF(lEFFTpMod,IIF(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA)=="1",lPrePag  .And.  IIF(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04") )
		  @nLin,3    SAY AVSX3("EF1_SLD_PM",5) SIZE 50,8
		  @nLin,10.5 MSGET nSaldo PICTURE AVSX3("EF1_SLD_PM",6) WHEN .F. SIZE 60,7
	   Else
		  @nLin,3    SAY AVSX3("EF1_SL2_PM",5) SIZE 50,8
		  @nLin,10.5 MSGET nSaldo PICTURE AVSX3("EF1_SL2_PM",6) WHEN .F. SIZE 60,7
	   EndIf
	   If lMostraJur
		  nLin += 1.0  // PLB 08/06/06
		  @nLin,3    SAY AVSX3("EF1_SL2_JM",5) SIZE 50,8
		  @nLin,10.5 MSGET nSaldoJur PICTURE AVSX3("EF1_SLD_PM",6) WHEN .F. SIZE 60,7
	   EndIf

	   If lPergunta
		  DEFINE SBUTTON FROM (nLin*10)+40,50 TYPE 1 ACTION(nOpc:=1,oDlgEnc:End()) ENABLE OF oDlgEnc
	   EndIf
	   DEFINE SBUTTON FROM (nLin*10)+40,90 TYPE 2 ACTION(nOpc:=0,oDlgEnc:End()) ENABLE OF oDlgEnc

	ACTIVATE MSDIALOG oDlgEnc CENTERED
endif

If nOpc = 1
   If cAliasEF1 == "M"
      M->EF1_DT_ENC := dDtEnc
   Else
      (cAliasEF1)->EF1_DT_ENC := dDtEnc
   EndIf
   lReturn := .T.

   //** AAF 27/01/2015 - Encerramento da provisão total de juros (620).
   IF cAliasEF1=="M"
      EX401EncJr(.T.,dDtEnc,BuscaEF3Seq())
   EndIf
   //**

Else
   lReturn := .F.
EndIf

Return lReturn

*-----------------------------------------------------------------------------------------------*
Function EX401JrOpen(cAliasEF1,cAliasEF3,lRetSaldo)
*-----------------------------------------------------------------------------------------------*
Local lRet:=.F., nOldRec:=(cAliasEF3)->(RecNo()), nOldOrd:=(cAliasEF3)->(IndexOrd())
If(lRetSaldo=NIL, lRetSaldo:=.F.,)

If cAliasEF3 == "EF3"
   (cAliasEF3)->(dbSetOrder(1))
Else
   (cAliasEF3)->(dbSetOrder(2))
EndIf

If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial('EF3')+If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,"")),"")+Left(EV_LIQ_JUR,2)))
   Do While !(cAliasEF3)->(EOF()) .and.;
   If(cAliasEF3=="EF3",(cAliasEF3)->EF3_FILIAL+If(lEFFTpMod,(cAliasEF3)->EF3_TPMODU,"")+(cAliasEF3)->EF3_CONTRA+(cAliasEF3)->EF3_BAN_FI+(cAliasEF3)->EF3_PRACA+If(lEFFTpMod,(cAliasEF3)->EF3_SEQCNT,"")==;
                        xFilial('EF3')+If(cAliasEF1=="M",If(lEFFTpMod,M->EF1_TPMODU,"")+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+If(lEFFTpMod,M->EF1_SEQCNT,""),If(lEFFTpMod,(cAliasEF1)->EF1_TPMODU,"")+(cAliasEF1)->EF1_CONTRA+(cAliasEF1)->EF1_BAN_FI+(cAliasEF1)->EF1_PRACA+If(lEFFTpMod,(cAliasEF1)->EF1_SEQCNT,"")),.T.) .and.;
                        Left((cAliasEF3)->EF3_CODEVE,2)==Left(EV_LIQ_JUR,2)
      If Empty((cAliasEF3)->EF3_TX_MOE)
         lRet := .T.
         If !lRetSaldo
            Exit
         Else
            nSaldoJur += (cAliasEF3)->EF3_VL_MOE
         EndIf
      EndIf
      (cAliasEF3)->(dbSkip())
   EndDo
EndIf

(cAliasEF3)->(dbSetOrder(nOldOrd))
(cAliasEF3)->(dbGoTo(nOldRec))

Return lRet

*-----------------------------------------------------------------------------------------------*
Function EX401ValEnc()
*-----------------------------------------------------------------------------------------------*
Local lRetorno := .T., nEFF0002:=EasyGParam("MV_EFF0002",,0)
Local aEvEncContr := {}
Local lEvEncLiq   := .F.
Local lEF3TitFin := .F. //MCF - 15/06/2016
Private nSaldoJur:=0

If !Empty(M->EF1_DT_ENC)
   If M->EF1_DT_ENC < dDataBase
      MsgInfo(STR0024) //"A data de encerramento não pode ser anterior a data corrente do sistema."
      lRetorno := .F.
   ElseIf !(M->EF1_SLD_PM < nEFF0002  .and. IIF(lEFFTpMod .And. M->EF1_CAMTRA == "1" ,M->EF1_SLD_JM == 0,!EX401JrOpen("M","WorkEF3",.T.)))
      If cNivel < 9
         EX401Encerra(M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,M->EF1_SLD_PM,"M",M->EF1_DT_ENC,.T.,.F.)
         lRetorno := .F.
      Else
         If !EX401Encerra(M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,M->EF1_SLD_PM,"M",M->EF1_DT_ENC,.T.)
            lRetorno := .F.
         EndIf
      EndIf
   Else
      EX401EncJr(.T.,M->EF1_DT_ENC,BuscaEF3Seq())
   EndIf
Else

   WorkEF3->(DbSetOrder(5))
   aEvEncContr := {{'670',.F.,.F.}}                    // NCF - 05/12/2014 - {Evento,lTemTitulo,lEstaLiquidado}
   If lGerTitEvEnc
      aAdd(aEvEncContr,{'180',.F.,.F.})
      aAdd(aEvEncContr,{'190',.F.,.F.})
   EndIf

   lEF3TitFin := IF(AvFlags("SIGAEFF_SIGAFIN"),!Empty(WorkEF3->EF3_TITFIN),.F.) //MCF - 15/06/2016
   If WorkEF3->(FieldPos("EF3_SEQBX"))
      aEval(aEvEncContr,{|x| If(  WorkEF3->(DbSeek(x[1])) ,  If( x[2] := lEF3TitFin, x[3] := !Empty(WorkEF3->EF3_SEQBX) , ) , ) })
   EndIf

   If (nPosEvEncLiq := aScan(aEvEncContr, {|x| x[2] .and. x[3] } )) > 0  // Verifica se existe um dos eventos do array com título já liquidado
      lEvEncLiq   := .T.
   EndIf

   EX401EncJr(.T.,,,.T.)

   If !lEvEncLiq
      // ** PLB 13/10/06 - Verifica se o contrato possui evento de encerramento
      WorkEF3->( DBSetOrder(5) )
      If WorkEF3->( DBSeek(EV_ENC_PRC) )
         If (lRetorno := MsgYesNo(STR0144))  //"Este contrato possui evento de encerramento. Deseja excluir este evento?"
            EX400EVManut(5)
            If !lRetContr
               lRetorno := .F.
               lRetContr := .T.
            EndIf
         EndIf
      EndIf
      WorkEF3->( DBSetOrder(ORDEM_BROWSE))
      WorkEF3->( DBGoTop())
      oMark:oBrowse:Refresh()
   Else
      MsgStop('A data de encerramento não pode ser retirada pois o evento '+aEvEncContr[nPosEvEncLiq][1]+' está liquidado.','Aviso')
      lRetorno := .F.
   EndIf
// **
EndIf

Return lRetorno

/*
Função      : EX401GrvIR
Objetivo    : Gera os eventos de IR. Caso o valor de IR digitado seja menor que o calculado, o sistema irá gerar o valor
              de estorno com a diferença. Caso a diferença seja a maior, o sistema irá gerar um
              evento de provisão
Parametro   : nVlIR     -> Valor de IR digitado
              nVlIR_Old -> Valor de IR calculado pelo sistema
Retorno     : Lógico, sempre .T.
Autor       : Gustavo Fabro da Costa Carreiro
Data e Hora : 08/2005.
*/
*-------------------------------------------------------------------------------------------------*
Function EX401GrvIR(cAliasEF3,cAliasEF1,nVlIR, nVlIR_Old, dDtIR, nTxIR, nVlIR_Real,cContrato,cInvoice,;
         cParc,cPreemb,cMoeInv,cEvVin,cParcVin,cNrOp,cSeq,cBanco,cAgencia,cConta,cPraca,cFilOri,;
         cCodEve,lAchouIR,cTpModu,cSeqCon)
*-------------------------------------------------------------------------------------------------*
Local nVlDif := nVlIR_Old - nVlIR, nOrd
Local nDecValor := AVSX3("EF3_VL_MOE",4)

If lAchouIR
   lAchouIR:=.F.
   nOrd := (cAliasEF3)->(IndexOrd())
   (cAliasEF3)->(dbSetOrder(2))
   (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3")+If(lEFFTpMod,cTpModu,""),"")+Left(EV_IR,2)+Right(cCodEve,1)+cInvoice+cParc))
   (cAliasEF3)->(dbSetOrder(nOrd))
Else
   lAchouIR:=.T.
EndIf

//Grava IR - 780
(cAliasEF3)->(RecLock(cAliasEF3,lAchouIR))   //.T.
(cAliasEF3)->EF3_FILIAL := xFilial("EF3")
If ValType(cFilOri) == "C"
   (cAliasEF3)->EF3_FILORI := cFilOri
EndIf
If lEFFTpMod
   (cAliasEF3)->EF3_TPMODU := cTpModu
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

(cAliasEF3)->EF3_INVOIC := cInvoice
(cAliasEF3)->EF3_PREEMB := cPreemb
(cAliasEF3)->EF3_MOE_IN := cMoeInv
(cAliasEF3)->EF3_PARC   := cParc
(cAliasEF3)->EF3_CODEVE := Left(EV_IR,2)+Right(cCodEve,1)
(cAliasEF3)->EF3_VL_MOE := nVlIR
(cAliasEF3)->EF3_VL_REA := nVlIR_Real
(cAliasEF3)->EF3_TX_MOE := nTxIR
(cAliasEF3)->EF3_DT_EVE := dDtIR
(cAliasEF3)->EF3_DT_CIN := dDtIR
// ** GFC - Pré-Pagamento/Securitização
If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
   (cAliasEF3)->EF3_PARVIN := cParcVin
   (cAliasEF3)->EF3_EV_VIN := cEvVin
EndIf
// **
(cAliasEF3)->EF3_NROP   := cNrOp
(cAliasEF3)->EF3_SEQ    := cSeq
(cAliasEF3)->(msUnlock())

If lAchouIR  .And. lCadFin
   EX401GrEncargos(cAliasEF3)
EndIf

If  nVlDif < 0
   //Grava Provisão de IR - 770
   (cAliasEF3)->(RecLock(cAliasEF3,.T.))
   (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
   If ValType(cFilOri) == "C"
      (cAliasEF3)->EF3_FILORI := cFilOri
   EndIf
   If lEFFTpMod
      (cAliasEF3)->EF3_TPMODU := cTpModu
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

   (cAliasEF3)->EF3_INVOIC := cInvoice
   (cAliasEF3)->EF3_PREEMB := cPreemb
   (cAliasEF3)->EF3_MOE_IN := cMoeInv
   (cAliasEF3)->EF3_PARC   := cParc
   (cAliasEF3)->EF3_CODEVE := Left(EV_PROV_IR,2)+Right(cCodEve,1)
   (cAliasEF3)->EF3_VL_MOE := nVlDif * -1
   (cAliasEF3)->EF3_VL_REA := Round(nVlDif * nTxIR * -1,nDecValor)
   (cAliasEF3)->EF3_TX_MOE := nTxIR
   (cAliasEF3)->EF3_DT_EVE := dDtIR
   (cAliasEF3)->EF3_DT_CIN := dDtIR
   // ** GFC - Pré-Pagamento/Securitização
   If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
      (cAliasEF3)->EF3_PARVIN := cParcVin
      (cAliasEF3)->EF3_EV_VIN := cEvVin
   EndIf
   // **
   (cAliasEF3)->EF3_NROP   := cNrOp
   (cAliasEF3)->EF3_SEQ    := cSeq
   (cAliasEF3)->(msUnlock())

   If lCadFin
      EX401GrEncargos(cAliasEF3)
   EndIf

ElseIf nVlDif > 0
   //Grava Estorno de provisão de IR - 790
   (cAliasEF3)->(RecLock(cAliasEF3,.T.))
   (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
   If ValType(cFilOri) == "C"
      (cAliasEF3)->EF3_FILORI := cFilOri
   EndIf
   If lEFFTpMod
      (cAliasEF3)->EF3_TPMODU := cTpModu
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

   (cAliasEF3)->EF3_INVOIC := cInvoice
   (cAliasEF3)->EF3_PREEMB := cPreemb
   (cAliasEF3)->EF3_MOE_IN := cMoeInv
   (cAliasEF3)->EF3_PARC   := cParc
   (cAliasEF3)->EF3_CODEVE := Left(EV_EST_IR,2)+Right(cCodEve,1)
   (cAliasEF3)->EF3_VL_MOE := nVlDif
   (cAliasEF3)->EF3_VL_REA := Round(nVlDif * nTxIR,nDecValor)
   (cAliasEF3)->EF3_TX_MOE := nTxIR
   (cAliasEF3)->EF3_DT_EVE := dDtIR
   (cAliasEF3)->EF3_DT_CIN := dDtIR
   // ** GFC - Pré-Pagamento/Securitização
   If lPrePag .and. If(cAliasEF1=="M",M->EF1_CAMTRA,(cAliasEF1)->EF1_CAMTRA) == "1"//If(cAliasEF1=="M",M->EF1_TP_FIN,(cAliasEF1)->EF1_TP_FIN) $ ("03/04")
      (cAliasEF3)->EF3_PARVIN := cParcVin
      (cAliasEF3)->EF3_EV_VIN := cEvVin
   EndIf
   // **
   (cAliasEF3)->EF3_NROP   := cNrOp
   (cAliasEF3)->EF3_SEQ    := cSeq
   (cAliasEF3)->(msUnlock())

   If lCadFin
      EX401GrEncargos(cAliasEF3)
   EndIf
EndIf

Return .T.

/*
Função      : EX401DtIR
Objetivo    : Caso exista uma alteração na data final do IR do contrato, o sistema deverá estornar
              todas as provisões de IR para as parcelas de juros que estiverem fora do período.
Parametro   : -
Retorno     : Lógico, sempre .T.
Autor       : Gustavo Fabro da Costa Carreiro
Data e Hora : 08/2005.
*/
*-------------------------------------------------------------------------------------------------*
Function EX401DtIR()
*-------------------------------------------------------------------------------------------------*
WorkEF3->(dbSetOrder(2))
WorkEF3->(dbSeek(EV_PROV_IR,.T.))
Do While !WorkEF3->(EOF()) .and. WorkEF3->EF3_CODEVE $ (EV_IR+"/"+EV_PROV_IR+"/"+EV_EST_IR)
   If WorkEF3->EF3_DT_EVE > M->EF1_FIM_IR
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
   EndIf
   WorkEF3->(dbSkip())
EndDo
WorkEF3->(dbSetOrder(ORDEM_BROWSE))

Return .T.

/*
Função      : EX401ProvJr()
Objetivo    : Calcular o valor da provisão de juros baseada no saldo, para o pré-pagamento
Parametro   : -
Retorno     : Numérico, valor da provisão.
Autor       : Gustavo Fabro da Costa Carreiro
Data e Hora : 08/2005.
*/
*-------------------------------------------------------------------------------------------------*
Function EX401ProvJr(cContrato,cBanco,cPraca,cAliasEF3,dDtVenc,dDtUltProv,cEveJur,cTpModu,cSeqCon)
*-------------------------------------------------------------------------------------------------*
Local nRecEF3:=(cAliasEF3)->(RecNo()), nOrdEF3:=(cAliasEF3)->(IndexOrd()), dDtVencAux:=AvCtoD("")
Local aSaiJur:={}, nValPrinc := 0, ni:=0, nz:=0, nt:=0, cAliasEF1, cAliasEF2, nTotalParc:=0
Local aParcelas:={}

EX401Var("lEFFTpMod")

// ** AAF 01/04/08 - Adicionado parâmetro para o inicio da provisão.
If ValType(dDtUltProv) <> "D"
   dDtUltProv := If(cAliasEF1=="M",M->EF1_DT_JUR,EF1->EF1_DT_JUR)
EndIf
// **

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

Do While !(cAliasEF3)->(EOF()) .and.;
If(cAliasEF3=="EF3",(cAliasEF3)->(EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,""))==xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),.T.)
   If (cAliasEF3)->EF3_DT_EVE >= dDtUltProv
      If (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG
         aAdd(aParcelas,{"1",EV_PRINC_PREPAG,(cAliasEF3)->EF3_DT_EVE, (cAliasEF3)->EF3_VL_MOE , (cAliasEF3)->EF3_VL_MOE, .F. })
      ElseIf (cAliasEF3)->EF3_CODEVE == cEveJur .and. (cAliasEF3)->EF3_DT_EVE <> dDtVenc
         aAdd(aParcelas,{"2",cEveJur,(cAliasEF3)->EF3_DT_EVE, (cAliasEF3)->EF3_VL_MOE , (cAliasEF3)->EF3_VL_MOE , .F.})
      EndIf
   EndIf
   (cAliasEF3)->(dbSkip())
EndDo

//Ordena as parcelas por Data + Tipo(1-principal ou 2-juros)
aSort(aParcelas,,, {|x, y| dtos(x[3])+x[1] < dtos(y[3])+y[1] })

aSaiJur:={}
For ni:=Len(aParcelas) to 1 Step -1
   If (aParcelas[ni,3] < dDtVenc .or. ni=1) .and. aScan(aSaiJur,cEveJur) = 0
      aAdd(aSaiJur,cEveJur)

      nValPrinc:=0
      For nz:=ni to 1 Step -1
         If aParcelas[nz,1] == "1" .and. dDtVenc > aParcelas[nz,3]
            nValPrinc += aParcelas[nz,4]
         EndIf
      Next nz

      If aParcelas[ni,1] == "2"
         aTx_Jr := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN),dDtVenc,aParcelas[ni,3],cAliasEF1,cAliasEF2,Right(cEveJur,1))
         nValJuros := 0
         For nz:=1 to If(If(cAliasEF1=="M",M->EF1_PERFIX,EF1->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,EF1->EF1_TPPEJR)=="2",1,Len(aTx_Jr))
            nValJuros += If(If(cAliasEF1=="M",M->EF1_PERFIX,EF1->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,EF1->EF1_TPPEJR)=="2",If(cAliasEF1=="M",M->EF1_PERFIX,EF1->EF1_PERFIX),aTx_Jr[nz,2]) * (aTx_Jr[nz,1] / 100) * (If(cAliasEF1=="M",M->EF1_VL_MOE,EF1->EF1_VL_MOE) - nValPrinc)
         Next nz
         nValJuros := Round(nValJuros,2)
      Else
         dDtFim := dDtVenc
         nTotalParc := 0
         lPrinc := .T.
         For nt:=ni+IIF((aParcelas[ni,3] < dDtVenc),1,0) to 1 Step -1   // PLB 12/06/06 - Adiciona um se a primeira parcela de juros for apos a primeira parcela de pagamento
            aTx_Jr := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN),If(nt=1 .and. aParcelas[nt,3]<dDtFim .and. lPrinc,aParcelas[nt,3],dDtFim),If(nt=1 .and. lPrinc,dDtUltProv,aParcelas[IIF(nt==1,1,nt-1),3]),cAliasEF1,cAliasEF2,Right(cEveJur,1),IF(NT=1,.T.,.F.))  // PLB 12/06/06 - Se estiver calculando o juros da data do primeiro juros ate a data do primeiro principal
            nValJuros := 0
            For nz:=1 to If(If(cAliasEF1=="M",M->EF1_PERFIX,EF1->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,EF1->EF1_TPPEJR)=="2",1,Len(aTx_Jr))
               nValJuros += If(If(cAliasEF1=="M",M->EF1_PERFIX,EF1->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,EF1->EF1_TPPEJR)=="2",If(cAliasEF1=="M",M->EF1_PERFIX,EF1->EF1_PERFIX),aTx_Jr[nz,2]) * (aTx_Jr[nz,1] / 100) * (If(cAliasEF1=="M",M->EF1_VL_MOE,EF1->EF1_VL_MOE) - IIF(nt==1,0,nValPrinc))  // PLB 12/06/06 - Calcula sobre o saldo total se estiver calculando o juros da data de inicio de juros ate a data do primeiro principal
            Next nz
            nTotalParc += Round(nValJuros,2)
            If aParcelas[IIF(nt==1,1,nt-1),1] == "2"  // PLB 12/06/06
               Exit
            ElseIf nt <> 1  // PLB 12/06/06
               dDtFim := aParcelas[nt-1,3]
               nValPrinc -= aParcelas[nt-1,4]
               If !(aParcelas[nt-1,2] == EV_PRINC_PREPAG)   // PLB 12/06/06
                  lPrinc := .F.
               EndIf
            EndIf
         Next nt
         nValJuros := nTotalParc
      EndIf
      ni:=Len(aParcelas)
   EndIf
   If Len(aSaiJur) = 1
      Exit
   EndIf
Next ni

(cAliasEF3)->(dbSetOrder(nOrdEF3))
(cAliasEF3)->(dbGoTo(nRecEF3))

Return nValJuros

*-------------------------------------------------------------------------------------------*
Function EX401VlIR(cAliasEF1,nVlBase)
*-------------------------------------------------------------------------------------------*
Local nVlIR

If If(cAliasEF1=="M",M->EF1_REAJIR,EF1->EF1_REAJIR) == "1"
   nVlIR := nVlBase * (((If(cAliasEF1=="M",M->EF1_PERCIR,EF1->EF1_PERCIR)/((100-If(cAliasEF1=="M",M->EF1_PERCIR,EF1->EF1_PERCIR))/100))/100)+1) * (If(cAliasEF1=="M",M->EF1_PERCIR,EF1->EF1_PERCIR)/100)
Else
   nVlIR := (nVlBase * If(cAliasEF1=="M",M->EF1_PERCIR,EF1->EF1_PERCIR)) / 100
EndIf

Return nVlIR

*-------------------------------------------------------------------------------------------*
Function EX401QuebraEEQ(nVlOri,nVlNovo,cFilOri,cPreemb,cInvoice,cParcela,nRecAux,cChamada)
*-------------------------------------------------------------------------------------------*
Local nPos, aParcela:={}, nVlAjuste := nVlOri - nVlNovo, cParcOri:=cParcela
Local lRollBack := .F. //FSM - 07/03/2012
Local lIsAdiantamento := EX401IsAdiant(cInvoice, cPreemb, cParcela) //FSM - 05/10/2012
Local cOldOperacao := "" //FSM - 15/10/2012
Local aOldModulo := {cModulo,nModulo} //FSM - 18/12/2012
Local aOrdEEC     := EEC->(getArea())
Local cBkpFilAnt  := cFilAnt
Local nComisReme  := 0
Local nComisGraf  := 0
Local nComisDedu  := 0
Local nDesconto   := 0
Local nAcrescimo  := 0
Local nDecrescimo := 0
IIF(cChamada == NIL, cChamada := "" , )

// ** FSM - 18/12/2012 - Tratamento para que os titulos sejam gerados apenas como EEC
cModulo := "EEC"
nModulo := 29
If !Empty(cFilOri)
      cFilAnt := cFilOri
EndIf

Begin Sequence

   EEC->(dbSetOrder(1)) //EEC_FILIAL + EEC_PREEMB
   EEC->(dbSeek(cFilOri + cPreemb))
   /*
   É criada uma parcela igual a alterada com o valor do ajuste.
   */
   For nPos := 1 To EEQ->(fCount())
      aAdd(aParcela, EEQ->(FieldGet(nPos)))
   Next

   EEQ->(RecLock("EEQ",.F.))
   //EEQ->EEQ_VL := nVlNovo

   //FSM - 15/10/2012
   If lIsAdiantamento
      EEQ->EEQ_SALDO := nVlNovo
      cOldOperacao := EEQ->EEQ_NROP
   EndIf


   // ** PLB 02/05/07 - Ajuste para quebra de parcelas com Comissao
   If EECFlags("FRESEGCOM")
      EX401AjCom( nVlNovo/nVlOri, "EEQ" )
      nVlAjuste := Round(EEQ->EEQ_VL*(nVlNovo/nVlOri),2)
      EEQ->EEQ_VL := nVlAjuste
   EndIf
   // **

   EEQ->(msUnlock())

   //THTS - 13/11/2018 - Armazena os valores calculados das comissoes para deduzir da proxima parcela que esta sendo quebrada, para evitar diferenca de arredondamento.
   nComisReme  := EEQ->EEQ_AREMET
   nComisGraf  := EEQ->EEQ_CGRAFI
   nComisDedu  := EEQ->EEQ_ADEDUZ
   nDesconto   := EEQ->EEQ_DESCON
   nAcrescimo  := EEQ->EEQ_ACRESC
   nDecrescimo := EEQ->EEQ_DECRES

   //RMD - 26/02/13 - Não altera a parcela quando o tratamento TIT_PARCELAS estiver habilitado, pois neste caso os títulos 'filhos' mantém a referência do título original
   If !AvFlags("EEC_LOGIX") .And. !EECFlags("ALT_EASYLINK") .And. IsReceita(EEQ->EEQ_EVENT) .And. !lIsAdiantamento .AND. !(EasyVerModal("EEQ") .and. !Empty(EEQ->EEQ_DTCE))
      If !AvStAction("006")//Alteração de título a receber no SIGAFIN
         lRollBack := .T.
         Break
      EndIf
   EndIf

   cParcela := EX401EEQParc("EEQ",SomaIt(cParcela),cPreemb,EEQ->EEQ_FILIAL,IIF(cChamada == "PREVIN",,"WorkEF3"))

   EEQ->(RecLock("EEQ",.T.))

   /*
   A parcela criada, irá conter os dados sem alteração da parcela de alterada.
   */
   For nPos := 1 To Len(aParcela)
      EEQ->(FieldPut(nPos, aParcela[nPos]))
   Next

   EEQ->(EEQ_VL     -= nVlAjuste,;
         EEQ_PARC   := cParcela,;
         EEQ_ORIGEM := cParcOri)
  
   If EEQ->(FieldPos("EEQ_FINNUM")) > 0 //If EasyGParam("MV_AVG0131",,.T.) //LRS - 25/09/2013 - Verifica se tem a integração entre o EEC e o FIN
      If !(AvFlags("EEC_LOGIX"))
         If (!EECFlags("TIT_PARCELAS") .And. !EECFlags("ALT_EASYLINK")) //RMD - 06/10/12 - Mantem a referencia do titulo original quando possuir tratamento de parcelas.
         //RMD - 03/02/17 - Caso seja movimento no exterior e já tenha crédito no exterior, o título já foi baixado e deverá ser mantido na parcela do resíduo.
	        If !EasyVerModal("EEQ") .Or. Empty(EEQ->EEQ_DTCE)
                  EEQ->EEQ_FINNUM := ""
              EndIf
         EndIf
      EndIf
   EndIf
   // ** PLB 02/05/07 - Ajuste para quebra de parcelas com Comissao
  If EECFlags("FRESEGCOM")
      //EX401AjCom( nVlAjuste/nVlOri, "EEQ" )
      EEQ->EEQ_AREMET -= nComisReme
      EEQ->EEQ_CGRAFI -= nComisGraf
      EEQ->EEQ_ADEDUZ -= nComisDedu
      EEQ->EEQ_DESCON -= nDesconto
      EEQ->EEQ_ACRESC -= nAcrescimo
      EEQ->EEQ_DECRES -= nDecrescimo
      //EEQ->EEQ_VL += EEQ->EEQ_CGRAFI
  EndIf
   /*
   Inicio da gravação da parcela de financiamento.
   */
   EEQ->EEQ_NROP   := ""
   EEQ->EEQ_VL_PAR := 0
   EEQ->EEQ_FI_TOT := ""
   EEQ->EEQ_PARFIN := EEQ->EEQ_PARC

   //FSM - 15/10/2012
   If lIsAdiantamento
      EEQ->EEQ_NROP  := cOldOperacao
      EEQ->EEQ_SALDO := EEQ->EEQ_SALDO-nVlNovo
   EndIf
   /*
   Final da gravação da parcela de financiamento.
   */
   EEQ->(msUnlock())

   If Empty(EEQ->EEQ_FINNUM) .And. IsReceita(EEQ->EEQ_EVENT) .And. !lIsAdiantamento .AND. !(EasyVerModal("EEQ") .and. !Empty(EEQ->EEQ_DTCE))//FSM - 07/03/2012 //FSM - 05/10/2012
      If !AvStAction("005")//Inclusão de título a receber no SIGAFIN
         lRollBack := .T.
         Break
      EndIf
   EndIf

   RestArea(aOrdEEC)

End Sequence

If lRollBack//FSM - 07/03/2012
   MsgInfo(STR0184)//"A gravação não ocorreu devido à impossibilidade de integração com o módulo Financeiro. Verifique o Log Viewer."
   //RollBackDelTran("")
EndIf

// **FSM - 29/02/2012 - Tratamento para correta baixa de titulo no financeiro
cModulo := aOldModulo[1]
nModulo := aOldModulo[2]
cFilAnt := cBkpFilAnt

Return .T.

****************************************************************************
Function EX401QSWB(nVlOri,nVlNovo,cFilOri,cPreemb,cInvoice,cParcela,nRecAux)
****************************************************************************
Local nPos, aParcela:={}, nVlAjuste := nVlOri - nVlNovo, cParcOri:=cParcela

/*
É criada uma parcela igual a alterada com o valor do ajuste.
*/

For nPos := 1 To SWB->( FCount() )
   aAdd(aParcela, SWB->(FieldGet(nPos)) )
Next

SWB->(RecLock("SWB",.F.))
SWB->WB_FOBMOE := nVlNovo
SWB->(msUnlock())

cParcela := EX401SWBParc("SWB",SomaIt(cParcela),cPreemb,SWB->WB_FILIAL,"WorkEF3")

SWB->(RecLock("SWB",.T.))

/*
A parcela criada, irá conter os dados sem alteração da parcela de alterada.
*/
For nPos := 1 To Len(aParcela)
   SWB->(FieldPut(nPos, aParcela[nPos]))
Next

SWB->( WB_FOBMOE := nVlAjuste,;
       WB_LINHA  := cParcela ,;
       WB_ORIGEM := cParcOri  )

//AjustaComissao(nVlAjuste/nVlOri, "EEQ")

/*
Inicio da gravação da parcela de financiamento.
*/
SWB->WB_CA_NUM := ""
SWB->WB_NR_ROF := ""
SWB->WB_PARFIN := ""  // SWB->WB_LINHA   // PLB 13/06/06 - Limpa PARFIN da nova parcela do SWB

/*
Final da gravação da parcela de financiamento.
*/
SWB->( MsUnLock() )

Return .T.

*---------------------------------------------------------------------------------------------------*
Function EX401EEQParc(cAlias,cParcela,cPreemb,cFilOriEEQ,cAliasEF3)
*---------------------------------------------------------------------------------------------------*
 Local nRec:=(cAlias)->(RecNo()), nOrd:=(cAlias)->(IndexOrd())

 Local nRecEF3 := 0 ,;
       nOrdEF3 := 0

   If(cFilOriEEQ=NIL, cFilOriEEQ:="", )

   If(cAliasEF3 == NIL, cAliasEF3:="", )

   // PLB 19/07/06
   If cAliasEF3 == "WorkEF3"
      nRecEF3 := (cAliasEF3)->( RecNo() )
      nOrdEF3 := (cAliasEF3)->( IndexOrd() )
      (cAliasEF3)->( DBSetOrder(2) )
   EndIf

   (cAlias)->(dbSetOrder(1))

   (cAlias)->(AvSeekLast(If(cAlias=="EEQ",If(!Empty(cFilOriEEQ),cFilOriEEQ,xFilial("EEQ")),"")+cPreemb))

   If !(cAlias)->(EOF())
      cParcela := SomaIt((cAlias)->EEQ_PARC)
   EndIf

   // ** PLB 19/07/06
   If cAliasEF3 == "WorkEF3"
      (cAliasEF3)->( AvSeekLast(EV_EMBARQUE+WorkInv->EF3_INVOIC) )
      If !(cAliasEF3)->( EoF() )  .And.  Val((cAliasEF3)->EF3_PARC) >= Val(cParcela)
         cParcela := SomaIt((cAliasEF3)->EF3_PARC)
      EndIf
      (cAliasEF3)->( DBSetOrder(nOrdEF3) )
      (cAliasEF3)->( DBGoTo(nRecEF3)     )
   EndIf
   // **

   (cAlias)->(dbGoTo(nRec))
   (cAlias)->(dbSetOrder(nOrd))

Return cParcela

*---------------------------------------------------------------------------------------------------*
Function EX401SWBParc(cAlias,cParcela,cChave,cFilOriSWB,cAliasEF3)
*---------------------------------------------------------------------------------------------------*
 Local nRec:=(cAlias)->(RecNo()), nOrd:=(cAlias)->(IndexOrd())
 Local nRecEF3 := 0 ,;
       nOrdEF3 := 0

   If(cFilOriSWB=NIL, cFilOriSWB:="", )

   // PLB 19/07/06
   IIF(cAliasEF3 == NIL, cAliasEF3:="", )
   If cAliasEF3 == "WorkEF3"
      nRecEF3 := (cAliasEF3)->( RecNo() )
      nOrdEF3 := (cAliasEF3)->( IndexOrd() )
      (cAliasEF3)->( DBSetOrder(2) )
   EndIf

   (cAlias)->(dbSetOrder(1))

   (cAlias)->(AvSeekLast(If(cAlias=="SWB",If(!Empty(cFilOriSWB),cFilOriSWB,xFilial("SWB")),"")+cChave))

   If !(cAlias)->(EOF())
      cParcela := SomaIt((cAlias)->WB_LINHA)
   EndIf

   // ** PLB 19/07/06
   If cAliasEF3 == "WorkEF3"
      (cAliasEF3)->( DBSeek(EV_EMBARQUE) )
      Do While !(cAliasEF3)->( EoF() )  .And.  (cAliasEF3)->EF3_CODEVE == EV_EMBARQUE ;
               .And.  (cAliasEF3)->(EF3_HAWB+EF3_PO_DI+EF3_INVIMP+EF3_FORN+EF3_LOJAFO+EF3_LINHA) == cChave
         If Val((cAliasEF3)->EF3_LINHA) >= Val(cParcela)
            cParcela := SomaIt((cAliasEF3)->EF3_LINHA)
         EndIf
      EndDo
      (cAliasEF3)->( DBSetOrder(nOrdEF3) )
      (cAliasEF3)->( DBGoTo(nRecEF3) )
   EndIf
   // **

   (cAlias)->(dbGoTo(nRec))
   (cAlias)->(dbSetOrder(nOrd))

Return cParcela

*---------------------------------------------------------------------------------------------------*
Function EX401LocIR(cAliasEF3,cCodEve,cInvoice,cParcela,nExclui,cTpModu)
*---------------------------------------------------------------------------------------------------*
Local nOrdEF3:=(cAliasEF3)->(IndexOrd()), nRecEF3:=(cAliasEF3)->(RecNo()), aAchouIR:={.F.,0,0,0}
If(nExclui=NIL,nExclui:=0,)

(cAliasEF3)->(dbSetOrder(2))

If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3")+If(lEFFTpMod,cTpModu,""),"")+Left(EV_IR,2)+Right(cCodEve,1)+cInvoice+cParcela))
   aAchouIR:={.T.,(cAliasEF3)->EF3_VL_MOE,nRecEF3,nOrdEF3}
Else
   aAchouIR:={.F.,0,nRecEF3,nOrdEF3}
EndIf

If nExclui <> 0
   If nExclui = 1 .and. aAchouIR[1]
      If cAliasEF3 == "WorkEF3"
         aAdd(aDelEF3,(cAliasEF3)->EF3_RECNO)
      EndIf
      (cAliasEF3)->(RecLock(cAliasEF3,.F.,.T.))
      (cAliasEF3)->(DBDELETE())
      (cAliasEF3)->(MSUnlock())
   EndIf

   If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3")+If(lEFFTpMod,cTpModu,""),"")+Left(EV_PROV_IR,2)+Right(cCodEve,1)+cInvoice+cParcela))
      If nExclui = 1
         If cAliasEF3 == "WorkEF3"
            aAdd(aDelEF3,(cAliasEF3)->EF3_RECNO)
         EndIf
         (cAliasEF3)->(RecLock(cAliasEF3,.F.,.T.))
         (cAliasEF3)->(DBDELETE())
         (cAliasEF3)->(MSUnlock())
      EndIf
   EndIf

   If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3")+If(lEFFTpMod,cTpModu,""),"")+Left(EV_EST_IR,2)+Right(cCodEve,1)+cInvoice+cParcela))
      If nExclui = 1
         If cAliasEF3 == "WorkEF3"
            aAdd(aDelEF3,(cAliasEF3)->EF3_RECNO)
         EndIf
         (cAliasEF3)->(RecLock(cAliasEF3,.F.,.T.))
         (cAliasEF3)->(DBDELETE())
         (cAliasEF3)->(MSUnlock())
      EndIf
   EndIf
EndIf

(cAliasEF3)->(dbSetOrder(nOrdEF3))
(cAliasEF3)->(dbGoTo(nRecEF3))

Return aAchouIR

*---------------------------------------------------------------------------------------------------*
Function EX401ValPer(cValid,nOpca)
*---------------------------------------------------------------------------------------------------*
Local lRet:=.T.

Do Case
   Case cValid == "OK"
      If lEF2_INVOIC .and. !Empty(M->EF2_INVOIC) .and. Empty(M->EF2_PARC)
         MsgInfo(STR0029) //"A Parcela deve ser preenchida."
         lRet := .F.
      ElseIf lEF2_INVOIC .and. Empty(M->EF2_INVOIC) .and. !Empty(M->EF2_PARC)
         MsgInfo(STR0030) //"A Invoice deve ser preenchida."
         lRet := .F.
      //ElseIf lMultifil .and. lEF2_INVOIC .and. !Empty(M->EF2_INVOIC) .and. Empty(M->EF2_FILORI)
         //MsgInfo(STR0032) //"A Filial Original deve ser preenchida."
         //lRet := .F.
      ElseIf lMultifil .and. lEF2_INVOIC .and. Empty(M->EF2_INVOIC) .and. !Empty(M->EF2_FILORI)
         MsgInfo(STR0030) //"A Invoice deve ser preenchida."
         lRet := .F.
      ElseIf lEF2_INVOIC .and. !Empty(M->EF2_INVOIC) .and. !Empty(M->EF2_PARC) //.and.;
      //If(lMultiFil,!Empty(M->EF2_FILORI),.T.)
         If lIntExp
            //EEQ->(dbSetOrder(4))
            lRet := .F.
            EEQ->(dbSetOrder(5))
            If lMultiFil
               //lRet := EEQ->(DBSEEK(M->EF2_FILORI+M->EF2_INVOIC+M->EF2_INVOIC+M->EF2_PARC+EV_PRINC2))
               // ** PLB 25/08/06
               EEQ->(DBSEEK(M->EF2_FILORI+M->EF2_INVOIC+EV_PRINC2))
               Do While !EEQ->( EoF() )  .And.  EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT) == M->(EF2_FILORI+EF2_INVOIC)+EV_PRINC2
                  If EEQ->EEQ_PARC == M->EF2_PARC
                     lRet := .T.
                     Exit
                  EndIf
                  EEQ->( DBSkip() )
               EndDo
               // **
               If !lRet
                  MsgInfo(STR0031) //"Invoice não encontrada"
               EnDIf
            Else
               // ** PLB 25/08/06
               EEQ->(dbSeek(cFilEEQ+M->EF2_INVOIC+EV_PRINC2))
               Do While !EEQ->( EoF() )  .And.  EEQ->(EEQ_FILIAL+EEQ_NRINVO+EEQ_EVENT) == cFilEEQ+M->EF2_INVOIC+EV_PRINC2
                  If EEQ->EEQ_PARC == M->EF2_PARC
                     lRet := .T.
                     Exit
                  EndIf
                  EEQ->( DBSkip() )
               EndDo
               // **
               If !lRet  //!EEQ->(dbSeek(xFilial("EEQ")+M->EF2_INVOIC+M->EF2_INVOIC+M->EF2_PARC+EV_PRINC2))
                  MsgInfo(STR0031) //"Invoice não encontrada"
                  //lRet := .F.
               EndIf
            EnDIF
            EEQ->(dbSetOrder(1))
         EndIf
      EndIf
      If lRet  .And.  !Empty(M->EF1_DT_JUR)
         lRet := EX401VerJur("EF2_DT_INI",nOpca)  // PLB 18/07/06
      EndIf
      //FSM - 29/03/2012
      If lRet .And. !Empty(M->EF1_DT_JUR)
         lRet := MsgYesNo(STR0185, STR0117)//#"Deseja realmente salvar este evento?" ##"Aviso"
      EndIf
EndCase

Return lRet

/*
Função..: EX401BxCon()
Data....: 31/10/05
Autor...: Alessandro Alves Ferreira (AAF)
Objetivo: Encerramento/Transferência de Contratos.
*/
*---------------------------------------------------------------------------------------------------*
Function EX401BxCon()
*---------------------------------------------------------------------------------------------------*
Local cFilter      := EF1->(DBFILTER())
Local nRecWKEF3 := WorkEF3->( recno() )
Private oRadio, oGetCon, oGetVlTran
Private cFilEF1    := xFilial("EF1"), cFilEF3 := xFilial("EF3")
Private nRadOpc    := 1
Private dDtEvent   := Max(Max(dDataBase,M->EF1_DT_JUR),M->EF1_DT_CTB)
Private cContrDest := CriaVar("EF1_CONTRA")
Private nVlrTransf := EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)[1]
Private lOK        := .F.
Private bCancel    := {||lOK:=.F.,oDlgEnc:End()}
Private bOK        := {||EX401VBxCon("OK") .AND. (lOK:=.T.,oDlgEnc:End())}
Private nRecContr  := EF1->( RecNo() )

DEFINE MSDIALOG oDlgEnc TITLE STR0088;  //"Encerramento/Transferência de Contrato"
FROM 10,10 TO 25,55 OF oMainWnd //20 - FSM - 10/04/2012

   @ 35,13 RADIO oRadOpc VAR nRadOpc ITEMS STR0089,STR0090 SIZE 100,15 ON CHANGE EX401GetCon() OF oDlgEnc PIXEL //"Encerramento do Contrato" "Transferência para outro contrato"

   @ 65,13 SAY AVSX3("EF3_DT_EVE",5) SIZE 40,8 PIXEL Of oDlgEnc
   @ 65,50 MSGET dDtEvent PICTURE "@D" Valid EX401VBxCon("DTEVENT") SIZE 65,08 PIXEL of oDlgEnc

   @ 80,50 MSGET oGetCon VAR cContrDest PICTURE AVSX3("EF1_CONTRA",6) F3 "EF4" Valid (Empty(cContrDest) .OR. EX401VBxCon("EF1_CONTRA")) SIZE 65,08 PIXEL of oDlgEnc

   @ 95,50 MSGET oGetVlTran VAR nVlrTransf PICTURE AVSX3("EF1_VL_MOE",6) Valid ( EX401VBxCon("EF1_VL_MOE") ) SIZE 65,08 PIXEL of oDlgEnc
   Ex401GetCon()

ACTIVATE MSDIALOG oDlgEnc ON INIT EnchoiceBar(oDlgEnc,bOK,bCancel) CENTERED

If lOk
   EX401EncCon(nRadOpc == 2, cContrDest, nVlrTransf )
   WorkEF3->( dbgoto(nRecWKEF3))
      // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
      if WorkEF3->( fieldpos("ALTERADO") ) > 0
            WorkEF3->ALTERADO := .T.
      endif
Endif

//ASK - 19/03/07 Filtro por Contratos de Exportação, a consulta padrão EF4 estava limpando o filtro.
//EF1->( dbSetFilter({||&cFilter},cFilter) )
If Empty(cFilter)
   EF1->(DbClearFilter())
Else
   EF1->(DbSetFilter(&("{||"+cFilter+"}"),cFilter))
EndIf
Return .T.

/*
Função..: EX401GetCon()
Data....: 31/10/05
Autor...: Alessandro Alves Ferreira (AAF)
Objetivo: Mostra Get para digitação do contrato, em caso de transferência.
*/
*---------------------------------------------------------------------------------------------------*
Function Ex401GetCon()
*---------------------------------------------------------------------------------------------------*

If nRadOpc == 1
   @ 80,13 SAY AVSX3("EF1_CONTRA",5) SIZE 40,8 PIXEL Of oDlgEnc
   @ 95,13 SAY AVSX3("EF1_SLD_PM",5) SIZE 40,8 PIXEL Of oDlgEnc                  //NCF - 17/03/2016
   oGetCon:Disable()
   oGetVlTran:Disable()
Else
   @ 80,13 SAY AVSX3("EF1_CONTRA",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE Of oDlgEnc
   @ 95,13 SAY AVSX3("EF1_SLD_PM",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE Of oDlgEnc
   oGetCon:Enable()
   oGetVlTran:Enable()
Endif

oGetCon:Refresh()
oGetVlTran:Refresh()
oDlgEnc:Refresh()

Return .T.

/*
Função..: EX401VBxCon()
Data....: 31/10/05
Autor...: Alessandro Alves Ferreira (AAF)
Objetivo: Validação da Baixa ACC
*/
*---------------------------------------------------------------------------------------------------*
Function EX401VBxCon(cCampo)
*---------------------------------------------------------------------------------------------------*
Local lRet:= .T., nRec, nInd, nOrdEF1

Do Case
   Case cCampo == "ENCERRAMENTO"

      nRec := WorkEF3->(RecNo())
      nInd := WorkEF3->(IndexOrd())
      WorkEF3->(dbSetOrder(2))
      WorkEF3->( dbSetOrder(nInd) )
      WorkEF3->( dbGoTo(nRec) )

   Case cCampo == "EF1_CONTRA"
      nOrdEF1:= EF1->( IndexOrd() )

      EF1->( dbSetOrder(1) )
      If !EF1->( dbSeek(cFilEF1+If(lEFFTpMod,M->EF1_TPMODU,"")+cContrDest) )
         MsgStop(STR0169) //ASK - 19/03/07 Validação de contrato.
         lRet := .F.
      ElseIf EF1->EF1_CONTRA == M->EF1_CONTRA
         MsgStop(STR0094)  //"Transferência não pode ser realizada para o próprio contrato."
         cContrDest := CriaVar("EF1_CONTRA")
         lRet:= .F.
      ElseIf !Empty(EF1->EF1_DT_ENC)
         MsgStop(STR0095+EF1->EF1_CONTRA+STR0096)  //"Contrato " ## " já está encerrado."
         cContrDest := CriaVar("EF1_CONTRA")
         lRet:= .F.
      ElseIf (EF1->EF1_VL_MOE - EF1->EF1_VLTRAN) < EX400Conv(M->EF1_MOEDA,EF1->EF1_MOEDA, (/*M->EF1_VL_MOE*/nVlrTransf - M->EF1_LIQPRM - M->EF1_SL2_PM - Ex401TotEve("190") ), dDtEvent)
         MsgStop(STR0097+AllTrim(EF1->EF1_CONTRA)+STR0098)  //"O Valor do Contrato " ## " é menor do que o valor a ser transferido."
         cContrDest := CriaVar("EF1_CONTRA")
         lRet:= .F.
      EndIf

      EF1->( dbSetOrder(nOrdEF1) )
      EF1->( dbGoTo(nRecContr) )
      oGetCon:Refresh()
   Case cCampo == "DTEVENT"
      If M->EF1_DT_JUR > dDtEvent
         If nRadOpc == 1
            MsgStop(STR0099+STR0101)  //"Data de Fechamento" " não pode ser menor que a Data de Inicio dos Juros."
         Else
            MsgStop(STR0100+STR0101)  //"Data de Transferência" " não pode ser menor que a Data de Inicio dos Juros."
         Endif
         lRet:= .F.
      ElseIf !Empty(M->EF1_DT_CTB)  .And.  lIsContab  .And.  M->EF1_DT_CTB > dDtEvent
         If nRadOpc == 1
            MsgStop(STR0099+STR0102)  //"Data de Fechamento" " não pode ser menor que a Data da ultima Contabilização."
         Else
            MsgStop(STR0100+STR0102)  //"Data de Transferência" " não pode ser menor que a Data da ultima Contabilização."
         Endif
         lRet:= .F.
      Endif
   Case cCampo == "OK"
      If nRadOpc == 2
         If Empty(cContrDest)
            MsgStop(STR0103)  //"Preencha o contrato de destino."
            lRet:= .F.
         Endif
         If nVlrTransf <= 0
            MsgStop("Preencha o valor a transferir!")
            lRet:= .F.
         EndIf
      Endif
   Case cCampo == "EF1_VL_MOE"
      If nRadOpc == 2
         If nVlrTransf <= 0
            MsgStop("Valor a transferir não pode ser inferior ou igual a zero!")
         ElseIf nVlrTransf > EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)[1]
            MsgStop("Valor a transferir não pode ser maior que o saldo em aberto do contrato!")
         EndIf
      EndIf

EndCase

Return lRet

/*
Função...: EX401EncCon()
Data.....: 01/11/05
Autor....: Alessandro Alves Ferreira (AAF)
Objetivo.: Gera o Encerramento do Principal.
Parametro: lTransf - .T./.F. - Indica se é uma transferência para outro contrato.
           cContrDest - Código do contrato de destino para onde será tranferido o saldo
           nValTransf - Saldo a ser tranferido
Alteração: Nilson César - 17/03/2016 - Permitir transferência parcial do saldo
*/
*------------------------------------------------------------------------------------------------*
Function EX401EncCon(lTransf, cContrDest, nValTransf)
*------------------------------------------------------------------------------------------------*
Local nI, nInd, nMV_EFF0003 := 1 //EasyGParam("MV_EFF0003",,0)             //NCF - 18/03/2016 - Fixar independente de parâmerto, conforme EFFEX400.
Local nVlRea, nVlMoe, nTxMoe180, nTxMoe190, nTxMoe520, nTxMoe670, nRec
Local cSeq, nOrdEF1, nValAux, nVal670, dDtUlt520, nTxUlt520, nVal520
Local aJuros, aTaxa, aTxLiq, dContab
Local nDecValor := AVSX3("EF3_VL_MOE",4)

EC6->(DbSetOrder(6))

EX401Saldo("M",if(lEFFTpMod,M->EF1_TPMODU,),M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,if(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

// ** Taxas
If !lTransf
   EC6->( dbSeek(xFilial("EC6")+"FIEX"+M->EF1_TP_FIN+'180') )
   nTxMoe180:= BuscaTaxa(M->EF1_MOEDA, dDtEvent,,.T.,,,EC6->EC6_TXCV)
Else
   EC6->( dbSeek(xFilial("EC6")+"FIEX"+M->EF1_TP_FIN+'190') )
   nTxMoe190:= BuscaTaxa(M->EF1_MOEDA, dDtEvent,,.T.,,,EC6->EC6_TXCV)
Endif

EC6->( dbSeek(xFilial("EC6")+"FIEX"+M->EF1_TP_FIN+'520'))
nTxMoe520:= BuscaTaxa(M->EF1_MOEDA, dDtEvent,,.T.,,,EC6->EC6_TXCV)

EC6->( dbSeek(xFilial("EC6")+"FIEX"+M->EF1_TP_FIN+'670'))
nTxMoe670:= BuscaTaxa(M->EF1_MOEDA, dDtEvent,,.T.,,,EC6->EC6_TXCV)
// **

aJuros   := EX400BusJur("WorkEF2","M")
//dContab  := If(M->EF1_DT_CTB == M->EF1_DT_JUR,M->EF1_DT_JUR-nMV_EFF0003,M->EF1_DT_CTB)
// PLB 13/06/07
dContab  := If(Empty(M->EF1_DT_CTB) .Or. !lIsContab,M->EF1_DT_JUR-nMV_EFF0003,M->EF1_DT_CTB)

// ** Taxas para V.C. do Principal
EC6->( dbSeek(xFilial("EC6")+"FIEX"+M->EF1_TP_FIN+'500'))
nTx500Atu:= BuscaTaxa(M->EF1_MOEDA, dDtEvent,,.T.,,,EC6->EC6_TXCV)
//nTx500Old:= BuscaTaxa(M->EF1_MOEDA, dContab ,,.T.,,,EC6->EC6_TXCV)
// **

nOrdEF3:= WorkEF3->(IndexOrd())

WorkEF3->( dbSetOrder(2) )
WorkEF3->( dbSeek(EV_PRINC) )//100

nVlMoe := If( Valtype(nValTransf) <> NIL, nValTransf , (M->EF1_VL_MOE - M->EF1_LIQPRM - M->EF1_SL2_PM) )                            //NCF - 17/03/2016
EC6->( dbSeek(xFilial("EC6")+"FIEX"+M->EF1_TP_FIN+'100'))
//RMD 01/12/14 - Posiciona no evento 100
WorkEF3->(dbSeek(EV_PRINC))
nTxMoe := WorkEF3->EF3_TX_MOE//BuscaTaxa(M->EF1_MOEDA, dDtEvent,,.T.,,,EC6->EC6_TXCV) //Considera a taxa do evento 100
cSeq   := BuscaEF3Seq("WorkEF3",M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))

If Empty(M->EF1_DT_CTB)  .Or.  !lIsContab
   nTx500Old := nTxMoe
Else
   nTx500Old := M->EF1_TX_CTB
Endif

// ** Gera Variação Cambial do Principal (500/501)
WorkEF3->(RecLock("WorkEF3",.T.))
WorkEF3->EF3_FILIAL := xFilial("EF3")
WorkEF3->EF3_CODEVE := EV_VC_PRC
WorkEF3->EF3_CONTRA := M->EF1_CONTRA
If lEFFTpMod
   WorkEF3->EF3_TPMODU := M->EF1_TPMODU
EndIf
WorkEF3->EF3_BAN_FI := M->EF1_BAN_FI
WorkEF3->EF3_AGENFI := M->EF1_AGENFI
WorkEF3->EF3_NCONFI := M->EF1_NCONFI
WorkEF3->EF3_PRACA  := M->EF1_PRACA
If lEFFTpMod
   WorkEF3->EF3_SEQCNT := M->EF1_SEQCNT
EndIf
WorkEF3->EF3_TP_EVE := M->EF1_TP_FIN
WorkEF3->EF3_VL_REA := Round(nVlMoe * nTx500Atu,nDecValor) - Round(nVlMoe * nTx500Old,nDecValor) //(M->EF1_VL_MOE * nTx500Atu) - (M->EF1_VL_MOE * nTx500Old)
WorkEF3->EF3_TX_MOE := nTx500Atu
WorkEF3->EF3_DT_EVE := dDtEvent
WorkEF3->EF3_DT_CIN := dDtEvent
WorkEF3->EF3_SEQ    := cSeq

//M->EF1_SLD_PR += WorkEF3->EF3_VL_REA

If WorkEF3->EF3_VL_REA <= 0
   WorkEF3->EF3_CODEVE := EV_VC_PRC1
   //WorkEF3->EF3_VL_REA := - (WorkEF3->EF3_VL_REA) //RMD - 01/12/14 - VC Ativa mantém o valor negativo.
Else
   WorkEF3->EF3_CODEVE := EV_VC_PRC
EndIf

//FSM - 10/04/2012
WorkEF3->EF3_DESCEV := BuscaDescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

WorkEF3->( MsUnLock() )
// **
If AvFlags("EEC_LOGIX") .And. Type('lGerTitEvEnc') == 'L' .And. lGerTitEvEnc
   AF200BkPInt("WORKEF3" , "ENC_MNCT_INC",,{'EF1',EF1->(Recno())},,)
EndIf

If lCadFin
   EX401GrEncargos("WorkEF3")
EndIf

// ** Grava Evento 180/190 - Encerramento do Principal/Transferência.
WorkEF3->(RecLock("WorkEF3",.T.))
WorkEF3->EF3_FILIAL := xFilial("EF3")
WorkEF3->EF3_CONTRA := M->EF1_CONTRA
If lEFFTpMod
   WorkEF3->EF3_TPMODU := M->EF1_TPMODU
EndIf
WorkEF3->EF3_BAN_FI := M->EF1_BAN_FI
WorkEF3->EF3_AGENFI := M->EF1_AGENFI
WorkEF3->EF3_NCONFI := M->EF1_NCONFI
WorkEF3->EF3_PRACA  := M->EF1_PRACA
If lEFFTpMod
   WorkEF3->EF3_SEQCNT := M->EF1_SEQCNT
EndIf
WorkEF3->EF3_TP_EVE := M->EF1_TP_FIN
WorkEF3->EF3_VL_MOE := nVlMoe

If lTransf
   //Transferência
   nVlRea := Round(nVlMoe * nTxMoe190,nDecValor)
   WorkEF3->EF3_CODEVE := EV_TRANS_PRC
   WorkEF3->EF3_VL_REA := nVlRea
   WorkEF3->EF3_TX_MOE := nTxMoe190

   nOrdEF1:= EF1->( IndexOrd() )

   EF1->( dbSetOrder(1) )
   EF1->( dbSeek(cFilEF1+If(lEFFTpMod,M->EF1_TPMODU,"")+cContrDest) )

   WorkEF3->EF3_CTDEST := cContrDest
   WorkEF3->EF3_PRDEST := EF1->EF1_PRACA

   EF1->( dbSetOrder(nOrdEF1) )
   EF1->( dbGoTo(nRecContr) )
Else
   //Encerramento
   nVlRea := Round(nVlMoe * nTxMoe180,nDecValor)
   WorkEF3->EF3_CODEVE := EV_ENC_PRC
   If !lGerTitEvEnc
      WorkEF3->EF3_VL_REA := nVlRea
      WorkEF3->EF3_TX_MOE := nTxMoe180
   EndIf
Endif

WorkEF3->EF3_DT_EVE := dDtEvent
WorkEF3->EF3_SEQ    := cSeq

M->EF1_SLD_PM := 0 //nVlMoe
M->EF1_SLD_PR := 0 //nVlRea
M->EF1_SLD_JM := 0
M->EF1_SLD_JR := 0

If !lTransf  // ** Só vai atualizar esse saldo na gravação geral quando for transferencia.
   M->EF1_LIQPRM += nVlMoe
EndIf
M->EF1_LIQPRR += nVlRea

//FSM - 10/04/2012
WorkEF3->EF3_DESCEV := BuscaDescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

WorkEF3->( msUnLock() )
// **
If AvFlags("EEC_LOGIX")
   AF200BkPInt("WORKEF3" , "ENC_MNCT_INC",,{'EF1',EF1->(Recno())},,)
EndIf

If lCadFin
   EX401GrEncargos("WorkEF3")
EndIf

// ** DATA DE ENCERRAMENTO
If M->EF1_LIQPRM >= M->EF1_VL_MOE
   M->EF1_DT_ENC := dDtEvent

   EX401EncJr(.T.,dDtEvent,BuscaEF3Seq())
EndIf
// **

If Type('lGerTitEvEnc') <> 'L'
   lGerTitEvEnc:= .F.
EndIf

For nI:=1 To Len(aJuros)
   aTaxa  := EX400BusTx(M->EF1_TP_FIN,dDtEvent,dContab        ,"M","WorkEF2",aJuros[nI])//RMD - 28/11/14 - Considerar um dia a mais //AAF 28/08/2015 - mas só na data de inicio de juros
   aTxLiq := EX400BusTx(M->EF1_TP_FIN,dDtEvent,M->EF1_DT_JUR-1,"M","WorkEF2",aJuros[nI])//RMD - 28/11/14 - Considerar um dia a mais //AAF 28/08/2015 - mas só na data de inicio de juros

   WorkEF3->( dbSeek(Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))) )

   nTxUlt520 := 0
   dDtUlt520 := CTOD("  /  /  ")
   Do While !WorkEF3->( EoF() ) .AND. WorkEF3->EF3_CODEVE == Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))
      If Empty(WorkEF3->EF3_INVOIC) .AND. (nTxUlt520 == 0 .OR. dDtUlt520 < WorkEF3->EF3_DT_EVE)
         nTxUlt520 := WorkEF3->EF3_TX_MOE
         dDtUlt520 := WorkEF3->EF3_DT_EVE
      EndIf

      WorkEF3->(dbSkip())
   EndDo

   //Grava Evento 520 - Provisão de Juros
   WorkEF3->(RecLock("WorkEF3",.T.))
   WorkEF3->EF3_FILIAL := xFilial("EF3")
   WorkEF3->EF3_CONTRA := M->EF1_CONTRA
   If lEFFTpMod
      WorkEF3->EF3_TPMODU := M->EF1_TPMODU
   EndIf
   WorkEF3->EF3_BAN_FI := M->EF1_BAN_FI
   WorkEF3->EF3_AGENFI := M->EF1_AGENFI
   WorkEF3->EF3_NCONFI := M->EF1_NCONFI
   WorkEF3->EF3_PRACA  := M->EF1_PRACA
   If lEFFTpMod
      WorkEF3->EF3_SEQCNT := M->EF1_SEQCNT
   EndIf
   WorkEF3->EF3_TP_EVE := M->EF1_TP_FIN
   WorkEF3->EF3_CODEVE := Left(EV_PJ,2)+Alltrim(Str(Val(aJuros[ni])))

   nValAux := 0
   For nInd := 1 to Len(aTaxa)
      nValAux += Round((nVlMoe * aTaxa[nInd,1] * aTaxa[nInd,2]) /100,nDecValor)
   Next nInd
   nVal520 := nValAux
   WorkEF3->EF3_VL_MOE := nValAux
   WorkEF3->EF3_VL_REA := Round(nValAux * nTxMoe520,nDecValor)
   WorkEF3->EF3_TX_MOE := nTxMoe520
   WorkEF3->EF3_DT_EVE := dDtEvent
   WorkEF3->EF3_SEQ    := cSeq

   //FSM - 10/04/2012
   WorkEF3->EF3_DESCEV := BuscaDescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

   WorkEF3->( msUnLock() )

   IF AvFlags("EEC_LOGIX") .And. lGerTitEvEnc
      AF200BkPInt("WORKEF3" , "ENC_MNCT_INC",,{'EF1',EF1->(Recno())},,)
   EndIf

   If lCadFin
      EX401GrEncargos("WorkEF3")
   EndIf

	//RMD - 28/11/14 - Não cria o evento já liquidado.
   nTxMoe670 := 0

   //Grava Evento 670 - Liquidação Forçada de Juros
   WorkEF3->(RecLock("WorkEF3",.T.))
   WorkEF3->EF3_FILIAL := xFilial("EF3")
   WorkEF3->EF3_TP_EVE := M->EF1_TP_FIN
   WorkEF3->EF3_CODEVE := Left(EV_LIQ_JUR_FC,2)+Alltrim(Str(Val(aJuros[nI])))
   WorkEF3->EF3_CONTRA := M->EF1_CONTRA
   If lEFFTpMod
      WorkEF3->EF3_TPMODU := M->EF1_TPMODU
   EndIf
   WorkEF3->EF3_BAN_FI := M->EF1_BAN_FI
   WorkEF3->EF3_AGENFI := M->EF1_AGENFI
   WorkEF3->EF3_NCONFI := M->EF1_NCONFI
   WorkEF3->EF3_PRACA  := M->EF1_PRACA
   If lEFFTpMod
      WorkEF3->EF3_SEQCNT := M->EF1_SEQCNT
   EndIf

   nValaux := 0
   For nInd:=1 to Len(aTxLiq)
      nValAux += Round((nVlMoe * aTxLiq[nInd,1] * aTxLiq[nInd,2]) /100,nDecValor)
   Next nInd
   nVal670 := nValAux
   WorkEF3->EF3_VL_MOE := nValAux
   WorkEF3->EF3_VL_REA := Round(nValAux * nTxMoe670,nDecValor)
   WorkEF3->EF3_TX_MOE := nTxMoe670
   WorkEF3->EF3_DT_EVE := dDtEvent
   WorkEF3->EF3_SEQ    := cSeq

   M->EF1_LIQJRM += WorkEF3->EF3_VL_MOE
   M->EF1_LIQJRR += WorkEF3->EF3_VL_REA

   WorkEF3->EF3_DESCEV := BuscaDescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

   WorkEF3->( MsUnLock() )

   If AvFlags("EEC_LOGIX")
      AF200BkPInt("WORKEF3" , "ENC_MNCT_INC",,{'EF1',EF1->(Recno())},,)
   EndIf

   If lCadFin
      EX401GrEncargos("WorkEF3")
   EndIf

   nVal550 := (nVal670 - nVal520) * nTxMoe520  - (nVal670 - nVal520) * nTxUlt520

   //Gera Variação Cambial da Provisão de Juros
   If nVal550 <> 0 .AND. nTxUlt520 <> 0
      WorkEF3->(RecLock("WorkEF3",.T.))
      WorkEF3->EF3_FILIAL := xFilial("EF3")
      WorkEF3->EF3_CONTRA := M->EF1_CONTRA
      If lEFFTpMod
         WorkEF3->EF3_TPMODU := M->EF1_TPMODU
      EndIf
      WorkEF3->EF3_BAN_FI := M->EF1_BAN_FI
      WorkEF3->EF3_AGENFI := M->EF1_AGENFI
      WorkEF3->EF3_NCONFI := M->EF1_NCONFI
      WorkEF3->EF3_PRACA  := M->EF1_PRACA
      If lEFFTpMod
         WorkEF3->EF3_SEQCNT := M->EF1_SEQCNT
      EndIf
      WorkEF3->EF3_TP_EVE := M->EF1_TP_FIN
      WorkEF3->EF3_VL_REA := nVal550
      WorkEF3->EF3_TX_MOE := nTx500Atu
      WorkEF3->EF3_DT_EVE := dDtEvent
      WorkEF3->EF3_DT_CIN := dDtEvent
      WorkEF3->EF3_SEQ    := cSeq
      nEvento := Val(EV_VC_PJ1) + 2 * Val(aJuros[ni])

      If WorkEF3->EF3_VL_REA <= 0
         nEvento ++
         //WorkEF3->EF3_VL_REA := - (WorkEF3->EF3_VL_REA)
      EndIf

      WorkEF3->EF3_CODEVE := AllTrim(Str(nEvento))

      WorkEF3->EF3_DESCEV := BuscaDescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)

      WorkEF3->( MsUnLock() )
      //WorkEF3->( dbGoTo(nRec) )

      If lCadFin
         EX401GrEncargos("WorkEF3")
      EndIf
   EndIf

Next nI

WorkEF3->( dbSetOrder(nOrdEF3) )

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato
EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

Return .T.

/*
Função..: EX401AtuCon()
Data....: 04/11/05
Autor...: Alessandro Alves Ferreira (AAF)
Objetivo: Gera o Encerramento do Principal.
*/
Function EX401AtuCon(nOpc)
Local cContrDest, nVlTrans, dDtEvent, nRec, nOrdEF1

//Evento de Transferência
cContrDest := EF3->EF3_CTDEST
dDtEvent   := EF3->EF3_DT_EVE

//Guarda Registro
nRec    := EF1->( RecNo() )
nOrdEF1 := EF1->( IndexOrd() )

//Contrato de Destino
EF1->( dbSetOrder(1) )
If EF1->( dbSeek(cFilEF1+If(lEFFTpMod,M->EF1_TPMODU,"")+cContrDest) )
   nVlTrans   := EX400Conv(M->EF1_MOEDA,EF1->EF1_MOEDA, EF3->EF3_VL_MOE, dDtEvent)

   //Taxa
   // ** Grava Valor Transferido no Contrato Destino **
   EF1->( RecLock("EF1",.F.) )

   If nOpc == INCLUIR
      EF1->EF1_VLTRAN += nVlTrans
   Else
      EF1->EF1_VLTRAN -= nVlTrans
   Endif

   EF1->( MsUnLock() )
   // **
Endif

EF1->( dbSetOrder(nOrdEF1) )
EF1->( dbGoTo(nRec) )

// ** Atualiza o saldo liquidado na moeda
If nOpc == INCLUIR
   EF1->( RecLock("EF1",.F.) )
   EF1->EF1_LIQPRM += nVlTrans //M->EF1_VL_MOE //LRS - 11/09/2017 - Alteracao do valor correto para salvar
   EF1->(msUnlock())
EndIf
// **

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato
EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

Return .T.

*--------------------------------------------------------------------------------------------------------------*
//AAF 23/02/06 - Adicionados os parâmetros:
//               cSeqCon - Sequência do Contrato.
//               cTpModu - Modulo "E" - Exportação e "I" - Importação
Function EX401AltTaxa(cAliasEF1,cAliasEF2,cAliasEF3,cInvoice,cParcela,dDtIni,cContrato,cBanco,cPraca,cTpJur,;
                      nAtuTx,nOldTx,nRecEF2,cTpModu,cSeqCon)
*--------------------------------------------------------------------------------------------------------------*
Local nRecEve, cSeq, dContab, i, nValAux:=0, aEvento:={}, nVal600:=0, lLiq:=.F., aTx_Ctb:={}
Local nDif:=0, nValOld:=0, aTx_Old:={}, lProvACC:=.F.
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Local dDtCont := CToD("  /  /  ")

(cAliasEF3)->(dbSetOrder(2))

If cAliasEF1=="EF1"
   EF1->(dbSeek(xFilial("EF1")+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+if(lEFFTpMod,cSeqCon,"")))
EndIf

// ** PLB 13/06/07 - Verifica se o Contrato está contabilizado
If !Empty(cTpModu)  .And.  cTpModu == EXP
   lIsContab := EX401IsCtb(cContrato,IIF(lTemChave,cBanco,""),IIF(lTemChave,cPraca,""),IIF(lEFFTpMod,cSeqCon,""))
Else
   lIsContab := .F.
EndIf
// **

//Pesquisa eventos de Provisão de Juros (520)
(cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3"),"")+Left(EV_PJ,2)+cTpJur+cInvoice+cParcela, .T.))
Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",EF3->EF3_FILIAL==xFilial("EF3"),.T.) .and.;
(cAliasEF3)->EF3_CODEVE==Left(EV_PJ,2)+cTpJur .and. (cAliasEF3)->EF3_INVOIC==cInvoice .and. (cAliasEF3)->EF3_PARC==cParcela

   nRecEve := (cAliasEF3)->(RecNo())
   lLiq    := (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3"),"")+EV_LIQ_PRC+cInvoice+cParcela)) .or.;
              (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3"),"")+EV_LIQ_PRC_FC+cInvoice+cParcela))
   (cAliasEF3)->(dbGoTo(nRecEve))

   If (cAliasEF3)->EF3_CONTRA==cContrato .and. If(lTemChave,(cAliasEF3)->EF3_BAN_FI==cBanco .and. (cAliasEF3)->EF3_PRACA==cPraca,.T.) .and.;
   (cAliasEF3)->EF3_DT_EVE > dDtIni .and. (cAliasEF3)->EF3_DT_EVE <> dDataBase .and. !lLiq
      cSeq    := (cAliasEF3)->EF3_SEQ
      If cAliasEF3=="WorkEF3"
         (cAliasEF3)->(dbSetOrder(1))
      Else
         (cAliasEF3)->(dbSetOrder(4))
      EndIf
      If (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3", xFilial("EF3")+cContrato+cBanco+cPraca, "")+cSeq+EV_EMBARQUE))
         nVal600 := (cAliasEF3)->EF3_VL_MOE
         (cAliasEF3)->(dbGoTo(nRecEve))

         //Calcula valores com a taxa antiga
         If cAliasEF2 == "EF2"
            (cAliasEF2)->(RecLock(cAliasEF2,.F.))
         EndIf
         (cAliasEF2)->EF2_TX_FIX := nOldTx
         aTx_Old := EX400BusTx(&(cAliasEF1+"->EF1_TP_FIN"),(cAliasEF3)->EF3_DT_EVE,&(cAliasEF1+"->EF1_DT_JUR"),If(cAliasEF3=="EF3","EF1","M"),If(cAliasEF3=="EF3","EF2","WorkEF2"),Right((cAliasEF3)->EF3_CODEVE,1),,(cAliasEF3)->EF3_FILORI,cInvoice,cParcela)
         For i:=1 to Len(aTx_Old)
            nValOld += Round((nVal600 * aTx_Old[i,1] * aTx_Old[i,2]) /100,nDecValor)
         Next i
         If cAliasEF2 == "EF2"
            (cAliasEF2)->(msUnlock())
         EndIf

         //Calcula valores com a taxa atual
         (cAliasEF2)->(dbGoTo(nRecEF2))
         If cAliasEF2 == "EF2"
            (cAliasEF2)->(RecLock(cAliasEF2,.F.))
         EndIf
         (cAliasEF2)->EF2_TX_FIX := nAtuTx
         aTx_Ctb := EX400BusTx(&(cAliasEF1+"->EF1_TP_FIN"),(cAliasEF3)->EF3_DT_EVE,&(cAliasEF1+"->EF1_DT_JUR"),If(cAliasEF3=="EF3","EF1","M"),If(cAliasEF3=="EF3","EF2","WorkEF2"),Right((cAliasEF3)->EF3_CODEVE,1),,(cAliasEF3)->EF3_FILORI,cInvoice,cParcela)
         For i:=1 to Len(aTx_Ctb)
            nValAux += Round((nVal600 * aTx_Ctb[i,1] * aTx_Ctb[i,2]) /100,nDecValor)
         Next i
         If cAliasEF2 == "EF2"
            (cAliasEF2)->(msUnlock())
         EndIf

         //Carrega valores do evento para o array
         FOR i := 1 TO (cAliasEF3)->(FCount())
             aAdd(aEvento,(cAliasEF3)->(FieldGet(i)))
         NEXT i

         If nValAux > nValOld

            //Grava Evento 520 - Provisão de Juros
            (cAliasEF3)->(RecLock(cAliasEF3,.T.))
            FOR i := 1 TO (cAliasEF3)->(FCount())
               (cAliasEF3)->&(FieldName(i)) := aEvento[i]
            NEXT i
            (cAliasEF3)->EF3_VL_MOE := nValAux - nValOld
            //(cAliasEF3)->EF3_TX_MOE := &(cAliasEF1+"->EF1_TX_CTB")
            (cAliasEF3)->EF3_VL_REA := Round((cAliasEF3)->EF3_VL_MOE * (cAliasEF3)->EF3_TX_MOE,nDecValor)
            (cAliasEF3)->EF3_DT_EVE := dDataBase
            (cAliasEF3)->(msUnlock())

            If lCadFin
               EX401GrEncargos(cAliasEF3)
            EndIf

            If cAliasEF1 == "M"
               M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
               M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
            Else
               (cAliasEF1)->(RecLock(cAliasEF1,.F.))
               (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
               (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
               (cAliasEF1)->(msUnlock())
            EndIf

         ElseIf nValAux < nValOld

            //Grava Evento 510 - Estorno da Provisão de Juros
            (cAliasEF3)->(RecLock(cAliasEF3,.T.))
            FOR i := 1 TO (cAliasEF3)->(FCount())
               (cAliasEF3)->&(FieldName(i)) := aEvento[i]
            NEXT i
            (cAliasEF3)->EF3_CODEVE := Left(EV_EST_PJ,2)+cTpJur
            //(cAliasEF3)->EF3_TX_MOE := &(cAliasEF1+"->EF1_TX_CTB")
            (cAliasEF3)->EF3_VL_MOE := nValOld - nValAux
            (cAliasEF3)->EF3_VL_REA := Round((cAliasEF3)->EF3_VL_MOE * (cAliasEF3)->EF3_TX_MOE,nDecValor)
            (cAliasEF3)->EF3_DT_EVE := dDataBase
            (cAliasEF3)->(msUnlock())

            If lCadFin
               EX401GrEncargos(cAliasEF3)
            EndIf

            If cAliasEF1 == "M"
               M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
               M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
            Else
               (cAliasEF1)->(RecLock(cAliasEF1,.F.))
               (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
               (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
               (cAliasEF1)->(msUnlock())
            EndIf

         EndIf

      ElseIf (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3", xFilial("EF3")+cContrato+cBanco+cPraca, "")+cSeq+EV_LIQ_PRC)) .or.;
      (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3", xFilial("EF3")+cContrato+cBanco+cPraca, "")+cSeq+EV_LIQ_PRC_FC))
         (cAliasEF3)->(dbGoTo(nRecEve))

      ElseIf !lProvACC
         (cAliasEF3)->(dbGoTo(nRecEve))

         lProvACC := .T.

         //Calcula valores com a taxa antiga
         If cAliasEF2 == "EF2"
            (cAliasEF2)->(RecLock(cAliasEF2,.F.))
         EndIf
         (cAliasEF2)->EF2_TX_FIX := nOldTx
         //aTx_Old := EX400BusTx(&(cAliasEF1+"->EF1_TP_FIN"),&(cAliasEF1+"->EF1_DT_CTB"),&(cAliasEF1+"->EF1_DT_JUR"),If(cAliasEF3=="EF3","EF1","M"),If(cAliasEF3=="EF3","EF2","WorkEF2"),Right((cAliasEF3)->EF3_CODEVE,1),,(cAliasEF3)->EF3_FILORI,cInvoice,cParcela)
         // ** PLB 13/06/07
         If Empty(&(cAliasEF1+"->EF1_DT_CTB"))  .Or.  !lIsContab
            dDtCont := &(cAliasEF1+"->EF1_DT_JUR")
         Else
            dDtCont := &(cAliasEF1+"->EF1_DT_CTB")
         EndIf
         aTx_Old := EX400BusTx(&(cAliasEF1+"->EF1_TP_FIN"),dDtCont,&(cAliasEF1+"->EF1_DT_JUR"),If(cAliasEF3=="EF3","EF1","M"),If(cAliasEF3=="EF3","EF2","WorkEF2"),Right((cAliasEF3)->EF3_CODEVE,1),,if(lMultiFil,(cAliasEF3)->EF3_FILORI,),cInvoice,cParcela)//AAF 03/02/2017 - Testa o multifilial
         // **
         For i:=1 to Len(aTx_Old)
            nValOld += Round((nVal600 * aTx_Old[i,1] * aTx_Old[i,2]) /100,nDecValor)
         Next i
         If cAliasEF2 == "EF2"
            (cAliasEF2)->(msUnlock())
         EndIf

         //Calcula valores com a taxa atual
         (cAliasEF2)->(dbGoTo(nRecEF2))
         If cAliasEF2 == "EF2"
            (cAliasEF2)->(RecLock(cAliasEF2,.F.))
         EndIf
         (cAliasEF2)->EF2_TX_FIX := nAtuTx
         //aTx_Ctb := EX400BusTx(&(cAliasEF1+"->EF1_TP_FIN"),&(cAliasEF1+"->EF1_DT_CTB"),&(cAliasEF1+"->EF1_DT_JUR"),If(cAliasEF3=="EF3","EF1","M"),If(cAliasEF3=="EF3","EF2","WorkEF2"),Right((cAliasEF3)->EF3_CODEVE,1),,(cAliasEF3)->EF3_FILORI,cInvoice,cParcela)
         // PLB 13/06/07
         aTx_Ctb := EX400BusTx(&(cAliasEF1+"->EF1_TP_FIN"),dDtCont,&(cAliasEF1+"->EF1_DT_JUR"),If(cAliasEF3=="EF3","EF1","M"),If(cAliasEF3=="EF3","EF2","WorkEF2"),Right((cAliasEF3)->EF3_CODEVE,1),,if(lMultifil,(cAliasEF3)->EF3_FILORI,),cInvoice,cParcela)
         For i:=1 to Len(aTx_Ctb)
            nValAux += Round((nVal600 * aTx_Ctb[i,1] * aTx_Ctb[i,2]) /100,nDecValor)
         Next i
         If cAliasEF2 == "EF2"
            (cAliasEF2)->(msUnlock())
         EndIf

         //Carrega valores do evento para o array
         FOR i := 1 TO (cAliasEF3)->(FCount())
             aAdd(aEvento,(cAliasEF3)->(FieldGet(i)))
         NEXT i

         If nValAux > nValOld

            //Grava Evento 520 - Provisão de Juros
            (cAliasEF3)->(RecLock(cAliasEF3,.T.))
            FOR i := 1 TO (cAliasEF3)->(FCount())
               (cAliasEF3)->&(FieldName(i)) := aEvento[i]
            NEXT i
            (cAliasEF3)->EF3_VL_MOE := nValAux - nValOld
            (cAliasEF3)->EF3_TX_MOE := &(cAliasEF1+"->EF1_TX_CTB")
            (cAliasEF3)->EF3_VL_REA := Round((cAliasEF3)->EF3_VL_MOE * (cAliasEF3)->EF3_TX_MOE,nDecValor)
            (cAliasEF3)->EF3_DT_EVE := dDataBase
            (cAliasEF3)->(msUnlock())

            If lCadFin
               EX401GrEncargos(cAliasEF3)
            EndIf

            If cAliasEF1 == "M"
               M->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
               M->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
            Else
               (cAliasEF1)->(RecLock(cAliasEF1,.F.))
               (cAliasEF1)->EF1_SLD_JM += (cAliasEF3)->EF3_VL_MOE
               (cAliasEF1)->EF1_SLD_JR += (cAliasEF3)->EF3_VL_REA
               (cAliasEF1)->(msUnlock())
            EndIf

         ElseIf nValAux < nValOld

            //Grava Evento 510 - Estorno da Provisão de Juros
            (cAliasEF3)->(RecLock(cAliasEF3,.T.))
            FOR i := 1 TO (cAliasEF3)->(FCount())
               (cAliasEF3)->&(FieldName(i)) := aEvento[i]
            NEXT i
            (cAliasEF3)->EF3_CODEVE := Left(EV_EST_PJ,2)+cTpJur
            (cAliasEF3)->EF3_TX_MOE := &(cAliasEF1+"->EF1_TX_CTB")
            (cAliasEF3)->EF3_VL_MOE := nValOld - nValAux
            (cAliasEF3)->EF3_VL_REA := Round((cAliasEF3)->EF3_VL_MOE * (cAliasEF3)->EF3_TX_MOE,nDecValor)
            (cAliasEF3)->EF3_DT_EVE := dDataBase
            (cAliasEF3)->(msUnlock())

            If lCadFin
               EX401GrEncargos(cAliasEF3)
            EndIf

            If cAliasEF1 == "M"
               M->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
               M->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
            Else
               (cAliasEF1)->(RecLock(cAliasEF1,.F.))
               (cAliasEF1)->EF1_SL2_JM -= (cAliasEF3)->EF3_VL_MOE
               (cAliasEF1)->EF1_SL2_JR -= (cAliasEF3)->EF3_VL_REA
               (cAliasEF1)->(msUnlock())
            EndIf

         EndIf

      EndIf
   EndIf

   (cAliasEF3)->(dbSetOrder(2))
   (cAliasEF3)->(dbGoTo(nRecEve))
   (cAliasEF3)->(dbSkip())
EndDo

nValAux:=0

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato
EX401Saldo("M",IIF(lEFFTpMod,cMod,),M->EF1_CONTRA,IIF(lTemChave,M->EF1_BAN_FI,),IIF(lTemChave,M->EF1_PRACA,),IIF(lEFFTpMod,M->EF1_SEQCNT,),"WorkEF3",.T.)

Return .T.

*--------------------------------------------------------------------------------------------------------------*
Function EX401VlJRA()
*--------------------------------------------------------------------------------------------------------------*
Local lRet:=.T., nrecAux
Local cAliasEF1 := "M"       //NCF - 10/03/2016
Local cAliasEF3 := "WorkEF3" //NCF - 14/03/2016
WorkEF3->(dbSetOrder(2))

If !Inclui
   If M->EF1_JR_ANT == "1"
      nRecAux := WorkEF3->(RecNo())
      If WorkEF3->(dbSeek(EV_LIQ_PRC))
         MsgInfo(STR0104+STR0105)  //"Não é possível alterar o pagamento de juros antecipados pois já existem liquidações."
         lRet:=.F.
      Else
         WorkEF3->(dbGoTo(nRecAux))
         EX401GrvJA("M","WorkEF2","WorkEF3",M->EF1_DT_JUR,,M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,NIL,NIL,NIL,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,))
      EndIf
   ElseIf M->EF1_JR_ANT == "2" 
      //If WorkEF3->(dbSeek(EV_JR_ANT))
      While lRet  .And.  WorkEF3->( DBSeek(Left(EV_JR_ANT,2)) )
         nRecAux := WorkEF3->(RecNo())
         If WorkEF3->(dbSeek(EV_LIQ_PRC))
            MsgInfo(STR0104+STR0105)  //"Não é possível alterar o pagamento de juros antecipados pois já existem liquidações."
            lRet:=.F.
         Else
            WorkEF3->(dbGoTo(nRecAux))
            cEvVinEF3 := WorkEF3->EF3_CODEVE
            If Empty(WorkEF3->EF3_NR_CON)
               WorkEF3->( DBGoTop() )  // PLB 30/08/06 - Exclui encargos e arruma saldo
               While !WorkEF3->( EoF() )
                  If nRecAux == WorkEF3->(RecNo())  .Or.  cEvVinEF3 == WorkEF3->EF3_EV_VIN
                     aAdd(aDelEF3,WorkEF3->EF3_RECNO)
                     WorkEF3->(RecLock("WorkEF3",.F.,.T.))
                     WorkEF3->(DBDELETE())
                     WorkEF3->(MSUnlock())
                     If Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JR_ANT,2)
                        M->EF1_SLD_JM -= WorkEF3->EF3_VL_MOE
                        M->EF1_SLD_JR -= WorkEF3->EF3_VL_REA
                     EndIf
                  EndIf
                  WorkEF3->( DBSkip() )
               EndDo
            Else
               MsgInfo(STR0104+STR0106)  //"Não é possível alterar o pagamento de juros antecipados pois já foi contabilizado."
               lRet:=.F.
            EndIf
         EndIf
      EndDo
      WorkEF3->(dbGoTop())
      oMark:oBrowse:Refresh()
      //EndIf
   EndIf
ElseIf M->EF1_JR_ANT == "1"
   MsgInfo(STR0107)  //"O Juros antecipado será gerado na confirmação do contrato."
EndIf

//AAF 18/07/2015 - Garantir a correção dos saldos do contrato
EX401Saldo(cAliasEF1,IIF(lEFFTpMod,cMod,),&(cAliasEF1+"->EF1_CONTRA"),IIF(lTemChave,&(cAliasEF1+"->EF1_BAN_FI"),),IIF(lTemChave,&(cAliasEF1+"->EF1_PRACA"),),IIF(lEFFTpMod,&(cAliasEF1+"->EF1_SEQCNT"),),cAliasEF3,.T.)

Return lRet

*-----------------------------------------------------------------------------------------------------------*
//AAF 23/02/06 - Adicionado o campo sequência do contrato e Modulo "E" - Exportação e "I" - Importação.
Function EX401GrvJA(cAliasEF1,cAliasEF2,cAliasEF3,dDtIni,dDtFim,cContrato,cBanco,cPraca,nTxMoe,dDtEve,aJuros,cTpModu,cSeqCon)
*-----------------------------------------------------------------------------------------------------------*
Local ni, nx, nValJur, dDtFimAux:=dDtFim
Local nDecValor := AVSX3("EF3_VL_MOE",4)

If aJuros = NIL
   If lEF2_TIPJUR
      aJuros := EX400BusJur(cAliasEF2,cAliasEF1)
   Else
      aJuros := {"0"}
   EndIf
EndIf

If nTxMoe = NIL
   (cAliasEF3)->(dbSetOrder(2))
   (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3"),"")+EV_PRINC))  //100
   nTxMoe := (cAliasEF3)->EF3_TX_MOE
   dDtEve := (cAliasEF3)->EF3_DT_EVE
   cSeq   := (cAliasEF3)->EF3_SEQ
Else
   cSeq   := BuscaEF3Seq(cAliasEF3,cContrato,cBanco,cPraca,If(lEFFTpMod,cTpModu,),If(lEFFTpMod,cSeqCon,))
EndIf

For nx:=1 to Len(aJuros)
   nValJur := 0

   If dDtFimAux = NIL
      (cAliasEF2)->(AvSeekLast(If(lEF2_INVOIC,Space(Len((cAliasEF2)->(EF2_FILORI+EF2_INVOIC+EF2_PARC))),"")+&(cAliasEF1+"->EF1_TP_FIN")+If(lEF2_TIPJUR,aJuros[nx],"")))
      If !(cAliasEF2)->(EOF()) .and. !(cAliasEF2)->(BOF())
         dDtFim := (cAliasEF2)->EF2_DT_FIM
      Else
         dDtFim := dDataBase
      EndIf
   EndIf

   aTx_Jr := EX400BusTx(&(cAliasEF1+"->EF1_TP_FIN"),dDtFim,dDtIni,cAliasEF1,cAliasEF2,aJuros[nx])
   For ni:=1 to Len(aTx_Jr)
      nValJur += Round((&(cAliasEF1+"->EF1_VL_MOE") * aTx_Jr[ni,1] * (aTx_Jr[ni,2]+1)) /100,nDecValor) // NCF - 12/01/2021 - Adicionado dia a mais para cálculo semelhante a geração do 620 com a data de iníco de juros preenchida.
   Next ni

   //Grava Evento 680 - Juros Antecipado
   (cAliasEF3)->(RecLock(cAliasEF3,.T.))
   (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
   (cAliasEF3)->EF3_CONTRA := cContrato

   If lEFFTpMod
      (cAliasEF3)->EF3_TPMODU := cTpModu
   EndIf

   // ACSJ - 06/02/2005
   If lTemChave
      (cAliasEF3)->EF3_BAN_FI := cBanco
      (cAliasEF3)->EF3_AGENFI := &(cAliasEF1+"->EF1_AGENFI")
      (cAliasEF3)->EF3_NCONFI := &(cAliasEF1+"->EF1_NCONFI")
      (cAliasEF3)->EF3_PRACA  := cPraca
      If lEFFTpMod
         (cAliasEF3)->EF3_SEQCNT := cSeqCon
      EndIf
   Endif

   (cAliasEF3)->EF3_CODEVE := Left(EV_JR_ANT,2)+Alltrim(Str(Val(aJuros[nx])))   
   (cAliasEF3)->EF3_DESCEV := BuscaDescEv(cAliasEF1, "WorkEF3",  (cAliasEF3)->EF3_CODEVE)   
   (cAliasEF3)->EF3_MOE_IN := &(cAliasEF1+"->EF1_MOEDA")
   (cAliasEF3)->EF3_VL_MOE := nValJur
   (cAliasEF3)->EF3_VL_REA := Round(nValJur * nTxMoe,nDecValor)
   (cAliasEF3)->EF3_TX_MOE := nTxMoe
   (cAliasEF3)->EF3_DT_EVE := dDtEve
   (cAliasEF3)->EF3_SEQ    := cSeq
   (cAliasEF3)->EF3_TP_EVE := &(cAliasEF1+"->EF1_TP_FIN")

   If cAliasEF1 == "EF1"
      (cAliasEF1)->(RecLock(cAliasEF1,.F.))
   EndIf
   &(cAliasEF1+"->EF1_SLD_JM") += (cAliasEF3)->EF3_VL_MOE
   &(cAliasEF1+"->EF1_SLD_JR") += (cAliasEF3)->EF3_VL_REA
   If cAliasEF1 == "EF1"
      (cAliasEF1)->(msUnlock())
   EndIf

   (cAliasEF3)->(msUnlock())

   If lCadFin
      EX401GrEncargos(cAliasEF3)
   EndIf
Next nx

Return .T.

//Função que gera a variação cambial do juros antecipado
*-----------------------------------------------------------------------------------------------------------*
Function EX401VarJA(cAliasEF1,cAliasEF3,dDataVar,cContrato,cBanco,cPraca,nTxMoe,cJuros,cTpModu,cSeqCon)
*-----------------------------------------------------------------------------------------------------------*
Local nVariacao:=0, nRec680, cCodEve:="", nEstTaxa:=0, lPositiva := .F.
Local nRecOld:=(cAliasEF3)->(RecNo()), nOldOrd:=(cAliasEF3)->(IndexOrd())
Local nDecValor := AVSX3("EF3_VL_MOE",4)

(cAliasEF3)->(dbSetOrder(2))
(cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3",xFilial("EF3"),"")+Left(EV_JR_ANT,2)+cJuros))  //680
Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3",(cAliasEF3)->EF3_FILIAL==xFilial("EF3"),.T.) .and.;
(cAliasEF3)->EF3_CODEVE == Left(EV_JR_ANT,2)+cJuros
   nRec680   := (cAliasEF3)->(RecNo())
   nVariacao := Round((cAliasEF3)->EF3_VL_MOE * nTxMoe,nDecValor) - Round((cAliasEF3)->EF3_VL_MOE * (cAliasEF3)->EF3_TX_MOE,nDecValor)
   cSeq      := (cAliasEF3)->EF3_SEQ

   If nVariacao < 0
      cCodEve   := Alltrim(StrZero(51+(Val(cJuros)*2),3))
      nVariacao := nVariacao * -1

      //Informar a taxa do Estorno de Juros Antecipado
      nEstTaxa := GetEstTaxa(nTxMoe,STR0108,,dDataVar)  //"Informe a taxa do Est. de Jr. Ant."

      //Gerar variação cambial caso necessário
      If nEstTaxa <> nTxMoe
         //050 - Variação Cambial de Juros Antecipado
         (cAliasEF3)->(RecLock(cAliasEF3,.T.))
         (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
         (cAliasEF3)->EF3_CONTRA := cContrato

         If lEFFTpMod
            (cAliasEF3)->EF3_TPMODU := cTpModu
         EndIf

         If lTemChave
            (cAliasEF3)->EF3_BAN_FI := cBanco
            (cAliasEF3)->EF3_AGENFI := &(cAliasEF1+"->EF1_AGENFI")
            (cAliasEF3)->EF3_NCONFI := &(cAliasEF1+"->EF1_NCONFI")
            (cAliasEF3)->EF3_PRACA  := cPraca
            If lEFFTpMod
               (cAliasEF3)->EF3_SEQCNT := cSeqCon
            EndIf
         Endif

         (cAliasEF3)->EF3_CODEVE := If(nEstTaxa>nTxMoe, Alltrim(StrZero(50+(Val(cJuros)*2),3)), Alltrim(StrZero(51+(Val(cJuros)*2),3)))
         (cAliasEF3)->EF3_MOE_IN := &(cAliasEF1+"->EF1_MOEDA")
         (cAliasEF3)->EF3_VL_MOE := 0
         (cAliasEF3)->EF3_VL_REA := Abs(nVariacao - Round(nVariacao / nEstTaxa * nTxMoe,nDecValor))
         (cAliasEF3)->EF3_TX_MOE := nEstTaxa
         (cAliasEF3)->EF3_DT_EVE := dDataVar
         (cAliasEF3)->EF3_SEQ    := cSeq
         (cAliasEF3)->EF3_TP_EVE := &(cAliasEF1+"->EF1_TP_FIN")
         (cAliasEF3)->(msUnlock())

         If lCadFin
            EX401GrEncargos(cAliasEF3)
         EndIf

         If cAliasEF1 == "EF1"
            (cAliasEF1)->(RecLock(cAliasEF1,.F.))
         EndIf
         If lPositiva
            &(cAliasEF1+"->EF1_SL2_JR") += (cAliasEF3)->EF3_VL_REA
         Else
            &(cAliasEF1+"->EF1_SL2_JR") += (cAliasEF3)->EF3_VL_REA
         EndIf
         If cAliasEF1 == "EF1"
            (cAliasEF1)->(msUnlock())
         EndIf
      EndIf

      //690 - Estorno de Juros Antecipados
      (cAliasEF3)->(RecLock(cAliasEF3,.T.))
      (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
      (cAliasEF3)->EF3_CONTRA := cContrato

      If lEFFTpMod
         (cAliasEF3)->EF3_TPMODU := cTpModu
      EndIf

      If lTemChave
         (cAliasEF3)->EF3_BAN_FI := cBanco
         (cAliasEF3)->EF3_AGENFI := &(cAliasEF1+"->EF1_AGENFI")
         (cAliasEF3)->EF3_NCONFI := &(cAliasEF1+"->EF1_NCONFI")
         (cAliasEF3)->EF3_PRACA  := cPraca
         If lEFFTpMod
            (cAliasEF3)->EF3_SEQCNT := cSeqCon
         EndIf
      Endif

      (cAliasEF3)->EF3_CODEVE := Left(EV_EST_JR_ANT,2)+cJuros
      (cAliasEF3)->EF3_MOE_IN := &(cAliasEF1+"->EF1_MOEDA")
      (cAliasEF3)->EF3_VL_MOE := Round(nVariacao / nEstTaxa,nDecValor)
      (cAliasEF3)->EF3_VL_REA := Round((cAliasEF3)->EF3_VL_MOE * nEstTaxa,nDecValor)
      (cAliasEF3)->EF3_TX_MOE := nEstTaxa
      (cAliasEF3)->EF3_DT_EVE := dDataVar
      (cAliasEF3)->EF3_SEQ    := cSeq
      (cAliasEF3)->EF3_TP_EVE := &(cAliasEF1+"->EF1_TP_FIN")
      (cAliasEF3)->(msUnlock())

      If lCadFin
         EX401GrEncargos(cAliasEF3)
      EndIf

      If cAliasEF1 == "EF1"
         (cAliasEF1)->(RecLock(cAliasEF1,.F.))
      EndIf
      &(cAliasEF1+"->EF1_SL2_JR") += (cAliasEF3)->EF3_VL_REA
      If cAliasEF1 == "EF1"
         (cAliasEF1)->(msUnlock())
      EndIf
   Else
      cCodEve   := Alltrim(StrZero(50+(Val(cJuros)*2),3))
      lPositiva := .T.
   EndIf

   //050 - Variação Cambial de Juros Antecipado
   (cAliasEF3)->(RecLock(cAliasEF3,.T.))
   (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
   (cAliasEF3)->EF3_CONTRA := cContrato

   If lEFFTpMod
      (cAliasEF3)->EF3_TPMODU := cTpModu
   EndIf

   If lTemChave
      (cAliasEF3)->EF3_BAN_FI := cBanco
      (cAliasEF3)->EF3_AGENFI := &(cAliasEF1+"->EF1_AGENFI")
      (cAliasEF3)->EF3_NCONFI := &(cAliasEF1+"->EF1_NCONFI")
      (cAliasEF3)->EF3_PRACA  := cPraca
      If lEFFTpMod
         (cAliasEF3)->EF3_SEQCNT := cSeqCon
      EndIf
   Endif

   (cAliasEF3)->EF3_CODEVE := cCodEve
   (cAliasEF3)->EF3_MOE_IN := &(cAliasEF1+"->EF1_MOEDA")
   (cAliasEF3)->EF3_VL_MOE := 0
   (cAliasEF3)->EF3_VL_REA := nVariacao
   (cAliasEF3)->EF3_TX_MOE := nTxMoe
   (cAliasEF3)->EF3_DT_EVE := dDataVar
   (cAliasEF3)->EF3_SEQ    := cSeq
   (cAliasEF3)->EF3_TP_EVE := &(cAliasEF1+"->EF1_TP_FIN")
   (cAliasEF3)->(msUnlock())

   If lCadFin
      EX401GrEncargos(cAliasEF3)
   EndIf

   If cAliasEF1 == "EF1"
      (cAliasEF1)->(RecLock(cAliasEF1,.F.))
   EndIf
   If lPositiva
      &(cAliasEF1+"->EF1_SL2_JR") += (cAliasEF3)->EF3_VL_REA
   Else
      &(cAliasEF1+"->EF1_SL2_JR") += (cAliasEF3)->EF3_VL_REA
   EndIf
   If cAliasEF1 == "EF1"
      (cAliasEF1)->(msUnlock())
   EndIf

   (cAliasEF3)->(dbGoTo(nRec680))
   (cAliasEF3)->(dbSkip())
EndDo

(cAliasEF3)->(dbGoTo(nRecOld))
(cAliasEF3)->(dbSetOrder(nOldOrd))

Return .T.

*-----------------------------------------------------------------------------------------------------------*
Static Function GetEstTaxa(nTaxa,cMensagem,cEve,dData,lAltTaxa)
*-----------------------------------------------------------------------------------------------------------*
Local oDlgEstTaxa
Local oPanel
Local nOpcao:=0, bOk := {||nOpcao:=1,oDlgEstTaxa:End()}, nOldTaxa:=nTaxa
Default lAltTaxa := .F.

DEFINE MSDIALOG oDlgEstTaxa TITLE cMensagem;
       FROM 12,05 TO 27,48 OF GetWndDefault() //FSM - 02/03/2012
       
   oPanel:= TPanel():New(0, 0, "", oDlgEstTaxa,, .F., .F.,,, 90, 165) 
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

   If !Empty(cEve)
      @02,02 SAY   STR0109+Alltrim(cEve) of oPanel  //"Evento "
      @02,08 SAY   STR0110+DtoC(dData) of oPanel      //"Data"
   Else
      @02,02 SAY   STR0110+DtoC(dData) of oPanel      //"Data"
   EndIf
   @03,02 SAY   STR0111 of oPanel                      //"Taxa"
   @03,08 MSGET nTaxa  PICT AVSX3("EF3_TX_MOE",6) Valid (nTaxa > 0) SIZE 60,8 of oPanel

ACTIVATE MSDIALOG oDlgEstTaxa ON INIT EnchoiceBar(oDlgEstTaxa,{|| If(!Empty(nTaxa),Eval(bOk),MsgInfo(STR0112))},{||nOpcao:=0,oDlgEstTaxa:End()}) CENTERED  //"A taxa deve ser informada"

If nOpcao == 0
   If lAltTaxa
      nTaxa := 0
   Else
      nTaxa := nOldTaxa
   EndIf
EndIf

Return nTaxa

*-----------------------------------------------------------------------------------------------------------*
Function EX401LiqPer()
*-----------------------------------------------------------------------------------------------------------*
Local lRet:=.T.

WorkEF3->(dbSetOrder(2))

If M->EF1_LIQPER == "1"
   WorkEF2->(dbSeek(If(lEF2_INVOIC,Space(Len(EF2->(EF2_FILORI+EF2_INVOIC+EF2_PARC))),"")+M->EF1_TP_FIN))
   Do While !WorkEF2->(EOF()) .and. If(lEF2_INVOIC,WorkEF2->(EF2_FILORI+EF2_INVOIC+EF2_PARC)==Space(Len(EF2->(EF2_FILORI+EF2_INVOIC+EF2_PARC))),.T.) .and.;
   WorkEF2->EF2_TP_FIN==M->EF1_TP_FIN
      If IIF(lLiqPeriodo,!EX401PELiq(),.T.)
         EX401GrvLP("M","WorkEF2","WorkEF3",M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,WorkEF2->EF2_DT_INI,WorkEF2->EF2_DT_FIM,If(lEF2_TIPJUR,WorkEF2->EF2_TIPJUR,"0"),INCLUIR,If(lEFFTpMod,M->EF1_TPMODU,),If(lEFFTpMod,M->EF1_SEQCNT,),.F.,) //FSM - 02/03/2012
      EndIf
      WorkEF2->(dbSkip())
   EndDo
ElseIf M->EF1_LIQPER == "2"
   WorkEF3->(dbSeek(EV_LIQ_JUR+Space(Len(EF3->EF3_INVOIC+EF3->EF3_PARC)),.T.))
   Do While !WorkEF3->(EOF()) .and. Left(WorkEF3->EF3_CODEVE,2)==Left(EV_LIQ_JUR,2) .and. Empty(WorkEF3->EF3_INVOIC) .and.;
   Empty(WorkEF3->EF3_PARC)
      EX400AtuSaldos("LJP","M","WorkEF3","EFF")
      If Empty(WorkEF3->EF3_NR_CON)
         If WorkEF3->EF3_TX_MOE == 0
            aAdd(aDelEF3,WorkEF3->EF3_RECNO)
            WorkEF3->(RecLock("WorkEF3",.F.,.T.))
            WorkEF3->(DBDELETE())
            WorkEF3->(MSUnlock())
         EndIf
      Else
         aAdd(aDelWkEF3,WorkEF3->(RecNo()))
         WorkEF3->(RecLock("WorkEF3",.F.))
         WorkEF3->EF3_EV_EST := WorkEF3->EF3_CODEVE
         WorkEF3->EF3_DT_EST := dDataBase
         WorkEF3->EF3_CODEVE := EV_ESTORNO
         WorkEF3->EF3_NR_CON := Space(Len(WorkEF3->EF3_NR_CON))
         WorkEF3->(msUnlock())
      EndIf
      WorkEF3->(dbSkip())
   EndDo
EndIf

WorkEF3->(dbSetOrder(ORDEM_BROWSE))
WorkEF3->(dbGoTop())
oMark:oBrowse:Refresh()

Return lRet

*-------------------------------------------------------------------------------------------------------------------------------------*
//AAF 23/02/06 - Adicionado o campo sequência do contrato e Modulo "E" - Exportação e "I" - Importação.
Function EX401GrvLP(cAliasEF1,cAliasEF2,cAliasEF3,cContrato,cBanco,cPraca,dDtIni,dDtFim,cJuros,nTipo,cTpModu,cSeqCon,lLiquida,cEvento)
*-------------------------------------------------------------------------------------------------------------------------------------*
Local aTx_Jr:={}, nValJur:=0, ni, nTxMoe:=0, cSeq
Local nDecValor  := AVSX3("EF3_VL_MOE",4)
Local lDesabIntg := .F.
Local aOrdAliasEF3    := SaveOrd(cAliasEF3)
Local nTxEve100  := 0
Local dDtEve100  := cTod("  /  /  ")
Default lLiquida := .T.
Default cEvento  := EV_LIQ_JUR

If EC6->(dbSeek(xFilial("EC6")+If(!lEFFTpMod .OR. M->EF1_TPMODU <> IMP,"FIEX","FIIM")+M->EF1_TP_FIN+cEvento))
   lDesabIntg := EC6->(FieldPos("EC6_DESINT")) > 0 .And. EC6->EC6_DESINT == '1'
EndIf

If cAliasEF3 == 'EF3'
   (cAliasEF3)->(dbSetOrder(1))
   EF3->(DbSeek( xFilial("EF3") + EF1->( EF1_TPMODU + EF1_CONTRA + EF1_BAN_FI + EF1_PRACA + EF1_SEQCNT ) + EV_PRINC ))
Else
   (cAliasEF3)->(dbSetOrder(2))
   (cAliasEF3)->(dbSeek(EV_PRINC))  //100
EndIf

nTxEve100 := (cAliasEF3)->EF3_TX_MOE
dDtEve100 := (cAliasEF3)->EF3_DT_EVE
RestOrd(aOrdAliasEF3,.T.)

If nTipo = ESTORNAR
   (cAliasEF3)->(dbSetOrder(2))
   (cAliasEF3)->(dbSeek(If(cAliasEF3=="EF3", xFilial("EF3")+If(lEFFTpMod,cTpModu,""), "")+Left(EV_LIQ_JUR,2)+cJuros+Space(Len(EF3->EF3_INVOIC+EF3->EF3_PARC))))
   Do While !(cAliasEF3)->(EOF()) .and. If(cAliasEF3=="EF3", EF3->EF3_FILIAL==xFilial("EF3"), .T.) .and.;
   (cAliasEF3)->EF3_CODEVE==Left(cEvento,2)+cJuros .and. Empty((cAliasEF3)->EF3_INVOIC) .and.;
   Empty((cAliasEF3)->EF3_PARC)
      If (cAliasEF3)->EF3_DT_EVE == dDtFim
         EX400AtuSaldos("LJP",cAliasEF1,cAliasEF3,"EFF")
         If Empty((cAliasEF3)->EF3_NR_CON)
            If cAliasEF3=="WorkEF3"
               aAdd(aDelEF3,(cAliasEF3)->EF3_RECNO)
            EndIf
            (cAliasEF3)->(RecLock(cAliasEF3,.F.,.T.))
            (cAliasEF3)->(DBDELETE())
            (cAliasEF3)->(MSUnlock())
         Else
            If cAliasEF3=="WorkEF3"
               aAdd(aDelWkEF3,(cAliasEF3)->(RecNo()))
            EndIf
            (cAliasEF3)->(RecLock(cAliasEF3,.F.))
            (cAliasEF3)->EF3_EV_EST := (cAliasEF3)->EF3_CODEVE
            (cAliasEF3)->EF3_DT_EST := dDataBase
            (cAliasEF3)->EF3_CODEVE := EV_ESTORNO
            (cAliasEF3)->EF3_NR_CON := Space(Len((cAliasEF3)->EF3_NR_CON))
            (cAliasEF3)->(msUnlock())
         EndIf
      EndIf
      (cAliasEF3)->(dbSkip())
   EndDo
   If cAliasEF3=="WorkEF3"
     WorkEF3->(dbSetOrder(ORDEM_BROWSE))
     WorkEF3->(dbGoTop())
     oMark:oBrowse:Refresh()
   EndIf
Else
   If lLiquida
      nTxMoe := BuscaTaxa(&(cAliasEF1+"->EF1_MOEDA"),dDtFim,,.F.,.T.,,cTX_100)
      nTxMoe := GetEstTaxa(nTxMoe,STR0113,Left(cEvento,2)+cJuros,dDtFim,.T.)  //"Informe a taxa da Liquidação de Juros por período."
   Else
      If lDesabIntg
         nTxMoe := nTxEve100
      Else
         nTxMoe := 0
      EndIf
   EndIf
   cSeq   := BuscaEF3Seq(cAliasEF3,cContrato,cBanco,cPraca,cTpModu,cSeqCon)

   aTx_Jr := EX400BusTx(&(cAliasEF1+"->EF1_TP_FIN"),dDtFim,dDtIni,cAliasEF1,cAliasEF2,cJuros)
   For ni:=1 to Len(aTx_Jr)
      /* wfs 20/05/16: quando for contrato ACE, usar o campo SL2 */
      If M->EF1_TP_FIN == ACE
         nValJur += Round((&(cAliasEF1+"->EF1_SL2_PM") * aTx_Jr[ni,1] * (aTx_Jr[ni,2]+1) ) /100,nDecValor)
      Else
         nValJur += Round((&(cAliasEF1+"->EF1_SLD_PM") * aTx_Jr[ni,1] * (aTx_Jr[ni,2]+1) ) /100,nDecValor)
      EndIf
   Next ni

   //Grava Evento 640 - Liq. Juros ou 620 - Juros do contrato
   (cAliasEF3)->(RecLock(cAliasEF3,.T.))
   (cAliasEF3)->EF3_FILIAL := xFilial("EF3")
   (cAliasEF3)->EF3_CONTRA := cContrato

   If lEFFTpMod
      (cAliasEF3)->EF3_TPMODU  := cTpModu
   EndIf

   If lTemChave
      (cAliasEF3)->EF3_BAN_FI := cBanco
      (cAliasEF3)->EF3_AGENFI := &(cAliasEF1+"->EF1_AGENFI")
      (cAliasEF3)->EF3_NCONFI := &(cAliasEF1+"->EF1_NCONFI")
      (cAliasEF3)->EF3_PRACA  := cPraca
      If lEFFTpMod
         (cAliasEF3)->EF3_SEQCNT  := cSeqCon
      EndIf
   Endif

   (cAliasEF3)->EF3_CODEVE := Left(cEvento,2)+cJuros
   (cAliasEF3)->EF3_MOE_IN := &(cAliasEF1+"->EF1_MOEDA")
   (cAliasEF3)->EF3_VL_MOE := nValJur
   (cAliasEF3)->EF3_VL_REA := Round(nValJur * nTxMoe,nDecValor)
   (cAliasEF3)->EF3_TX_MOE := nTxMoe

   If lDesabIntg                                               //NCF - 09/01/2014
      (cAliasEF3)->EF3_DT_EVE := dDtEve100
   Else
      (cAliasEF3)->EF3_DT_EVE := dDtFim
   EndIf

   (cAliasEF3)->EF3_SEQ    := cSeq
   (cAliasEF3)->EF3_TP_EVE := &(cAliasEF1+"->EF1_TP_FIN")
   If lLiqPeriodo
      (cAliasEF3)->EF3_SEQPER := (cAliasEF2)->EF2_SEQPER
   EndIf

   If UPPER(cAliasEF3) == "WORKEF3"
      WorkEF3->EF3_DESCEV := BuscaDescEv(cAliasEF1, "WorkEF3", WorkEF3->EF3_CODEVE)
   EndIf

   (cAliasEF3)->(msUnlock())

   If lCadFin
      EX401GrEncargos(cAliasEF3)
   EndIf

   If cAliasEF1 == "EF1"
      (cAliasEF1)->(RecLock(cAliasEF1,.F.))
   EndIf
   If nTxMoe > 0
      //ASK 23/10/2007 - Verifica o tipo do evento 01 - ACC / 02 - ACE para atualizar o saldo correto.
      If (cAliasEF3)->EF3_TP_EVE == "01"
         &(cAliasEF1+"->EF1_SLD_JM") -= (cAliasEF3)->EF3_VL_MOE
         &(cAliasEF1+"->EF1_SLD_JR") -= (cAliasEF3)->EF3_VL_REA
      Else
         &(cAliasEF1+"->EF1_SL2_JM") -= (cAliasEF3)->EF3_VL_MOE
         &(cAliasEF1+"->EF1_SL2_JR") -= (cAliasEF3)->EF3_VL_REA
      EndIf
      &(cAliasEF1+"->EF1_LIQJRM") += (cAliasEF3)->EF3_VL_MOE
      &(cAliasEF1+"->EF1_LIQJRR") += (cAliasEF3)->EF3_VL_REA
   EndIf
   If cAliasEF1 == "EF1"
      (cAliasEF1)->(msUnlock())
   EndIf
EndIf

Return .T.

*********************
Function EX401CInvs()
*********************
Local nInd
Local lOk := .F.
Local aBotao := { {"LBTIK",{|| MarcaTInvs() }, STR0114,STR0114} }  //"Marca/Desmarca Todas"
Local aHeaderAux := aClone(aHeader)
Local aColsAux   := aClone(aCols)
aCposTInv := {}

aAdd(aCposTInv,{"MARCA",,""})
aAdd(aCposTInv,{"PERMITE",,STR0115})  //"Permite?"
aAdd(aCposTInv,{"EF3_SEQCNT",,AVSX3("EF3_SEQCNT",5),AVSX3("EF3_SEQCNT",6)})
aAdd(aCposTInv,{"EF3_FORN"  ,,AVSX3("EF3_FORN",5)  ,AVSX3("EF3_FORN",6)  })
aAdd(aCposTInv,{"EF3_LOJAFO",,AVSX3("EF3_LOJAFO",5),AVSX3("EF3_LOJAFO",6)})
aAdd(aCposTInv,{"EF3_HAWB"  ,,AVSX3("EF3_HAWB",5)  ,AVSX3("EF3_HAWB",6)  })
aAdd(aCposTInv,{"EF3_INVOIC",,AVSX3("EF3_INVOIC",5),AVSX3("EF3_INVOIC",6)})
aAdd(aCposTInv,{"EF3_LINHA" ,,AVSX3("EF3_LINHA",5) ,AVSX3("EF3_LINHA",6) })
aAdd(aCposTInv,{"EF3_MOE_IN",,AVSX3("EF3_MOE_IN",5),AVSX3("EF3_MOE_IN",6)})
aAdd(aCposTInv,{"EF3_VL_INV",,AVSX3("EF3_VL_INV",5),AVSX3("EF3_VL_INV",6)})
aAdd(aCposTInv,{"EF3_VL_MOE",,AVSX3("EF3_VL_MOE",5),AVSX3("EF3_VL_MOE",6)})
aAdd(aCposTInv,{"EF3_TX_MOE",,AVSX3("EF3_TX_MOE",5),AVSX3("EF3_TX_MOE",6)})
aAdd(aCposTInv,{"EF3_VL_REA",,AVSX3("EF3_VL_REA",5),AVSX3("EF3_VL_REA",6)})
aAdd(aCposTInv,{"EF3_DT_EVE",,AVSX3("EF3_DT_EVE",5),AVSX3("EF3_DT_EVE",6)})

EF3->( dbSetOrder(1) )//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC
EF1->( dbSetOrder(1) )//EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT

EF3->( AvSeekLast(xFilial("EF3")+M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA) )
cLastSeq := EF3->EF3_SEQCNT

cFilEF3  := xFilial("EF3")
cFilEF1  := xFilial("EF1")

WorkTInv->( dbSetOrder(2) )

If WorkTInv->( Eof() .AND. BoF() )
   For nInd := 0 To Val(cLastSeq)
      cSeqCnt := StrZero(nInd,AvSX3("EF3_SEQCNT",3))

      If cSeqCnt <> M->EF1_SEQCNT

         EF3->( dbSeek(cFilEF3+M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+cSeqCnt+EV_LIQ_PRC) )
         Do While EF3->( !EoF() .AND. EF3_FILIAL == cFilEF3 .AND. EF3_TPMODU == M->EF1_TPMODU .AND. EF3_CONTRA == M->EF1_CONTRA .AND. EF3_BAN_FI == M->EF1_BAN_FI .AND. EF3_PRACA == M->EF1_PRACA .AND.;
                         EF3_SEQCNT == cSeqCnt .AND. EF3_CODEVE == EV_LIQ_PRC )

            WorkTInv->( reclock("WorkTInv",.T.) )

            If EF3->EF3_ORIGEM == "EEQ" .AND. !WorkEF3->( dbSetOrder(6), dbSeek(EF3->(EF3_INVOIC+EF3_PARC+EV_EMBARQUE)) ) .OR.;
               EF3->EF3_ORIGEM == "SWB" .AND. !WorkEF3->( dbSetOrder(9), dbSeek(EF3->(EV_LIQ_PRC+EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA)) )

               WorkTInv->MARCA      := ""
            Else

               WorkTInv->MARCA      := cMarca
            EndIf

            EF1->( dbSeek(cFilEF1+IMP+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+cSeqCnt) )

            If Empty(EF1->EF1_DT_JUR)
               WorkTInv->PERMITE    := "SIM"
            Else
               WorkTInv->PERMITE    := "NÃO"
            EndIf

            WorkTInv->EF3_SEQCNT := EF3->EF3_SEQCNT
            WorkTInv->EF3_FORN   := EF3->EF3_FORN
            WorkTInv->EF3_LOJAFO := EF3->EF3_LOJAFO
            WorkTInv->EF3_HAWB   := EF3->EF3_HAWB
            WorkTInv->EF3_INVOIC := EF3->EF3_INVOIC
            WorkTInv->EF3_PARC   := EF3->EF3_PARC
            WorkTInv->EF3_INVIMP := EF3->EF3_INVIMP
            WorkTInv->EF3_LINHA  := EF3->EF3_LINHA
            WorkTInv->EF3_MOE_IN := EF3->EF3_MOE_IN
            WorkTInv->EF3_VL_INV := EF3->EF3_VL_INV
            WorkTInv->EF3_VL_MOE := EF3->EF3_VL_MOE
            WorkTInv->EF3_TX_MOE := EF3->EF3_TX_MOE
            WorkTInv->EF3_VL_REA := EF3->EF3_VL_REA
            WorkTInv->EF3_DT_EVE := EF3->EF3_DT_EVE
            WorkTInv->EF3_ORIGEM := EF3->EF3_ORIGEM
            WorkTInv->RECNO      := EF3->( RecNo() )

            EF3->( dbSkip() )
         EndDo
      EndIf
   Next
EndIf

Begin Sequence

   If WorkTInv->( EoF() .AND. BoF() )
      MsgInfo(STR0116,STR0117)  // "Não existem invoices liquidadas que podem ser transferidas para este contrato." "Aviso"
      BREAK
   EndIf

   WorkTInv->( dbGoTop() )

   Define MsDialog oDlgTInv Title STR0118 From oMainWnd:nTop+200,oMainWnd:nLeft +1 To oMainWnd:nBottom-100,oMainWnd:nRight-100 Of oMainWnd Pixel  //"Transferência de Invoices"

      oMarkInvs := MsSelect():New("WorkTInv","MARCA",,aCposTInv,@lInverte,@cMarca,{12,01,202,400})
      oMarkInvs:bAval := {|| If(WorkTInv->PERMITE == "SIM",WorkTInv->( MARCA:=If(MARCA==cMarca,"",cMarca) ),MsgInfo(STR0119,STR0117)) }  // "O Contrato desta invoice já está fechado." "Aviso"
      oMarkInvs:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   Activate MsDialog oDlgTInv On Init EnchoiceBar(oDlgTInv, {||lOk:=.T.,oDlgTInv:End()}, {||oDlgTInv:End()}, , aBotao) Centered

   If lOk

      WorkTInv->( dbSetOrder(1), dbGoTop() )
      Do While WorkTInv->( !Eof() )

         If WorkTInv->MARCA == cMarca

            If WorkTInv->EF3_ORIGEM == "EEQ" .AND. !WorkEF3->( dbSetOrder(6), dbSeek(WorkTInv->(EF3_INVOIC+EF3_PARC+EV_EMBARQUE)) ) .OR.;
               WorkTInv->EF3_ORIGEM == "SWB" .AND. !WorkEF3->( dbSetOrder(9), dbSeek(WorkTInv->(EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA)) )

               EF3->( dbGoTo(WorkTInv->RECNO) )

               cSeq := BuscaEF3Seq()
               //cChave := xFilial("EF3")+IMP+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+WorkTInv->EF3_SEQCNT+EF3->EF3_SEQ
               cChave := EF3->( cFilEF3+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_INVOIC+EF3_PARC+EF3_INVIMP+EF3_LINHA )

               EF3->( dbSetOrder(6) )//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_INVOIC+EF3_PARC+EF3_INVIMP+EF3_LINHA
               EF3->( dbSeek(cChave) )
               Do While !EF3->( EoF() ) .AND. EF3->(EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_INVOIC+EF3_PARC+EF3_INVIMP+EF3_LINHA) == cChave

                  dbSelectArea("WorkEF3")
                  WorkEF3->( reclock("WorkEF3",.T.) )
                  FOR nInd := 1 TO FCount()
                     cCampo := FieldName(nInd)
                     If EF3->( FieldPos(cCampo) ) > 0
                        WorkEF3->&(cCampo) := EF3->&(cCampo)
                     EndIf
                  Next

                  WorkEF3->EF3_SEQCNT := M->EF1_SEQCNT
                  WorkEF3->EF3_SEQ    := cSeq

                  EF3->( dbSkip() )
               EndDo
               WorkTInv->( dbSkip() )
            EndIf

         Else

            If WorkTInv->EF3_ORIGEM == "EEQ" .AND. WorkEF3->( dbSetOrder(6), dbSeek(WorkTInv->(EF3_INVOIC+EF3_PARC+EV_EMBARQUE)) ) .OR.;
               WorkTInv->EF3_ORIGEM == "SWB" .AND. WorkEF3->( dbSetOrder(9), dbSeek(WorkTInv->(EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA)) )

               WorkEF3->( dbSetOrder(9) )//"EF3_CODEVE+EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA"

               If WorkEF3->( dbSeek(EV_EMBARQUE+WorkTInv->( EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA )) )
                  WorkEF3->( dbDelete() )
               EndIf

               If WorkEF3->( dbSeek(EV_LIQ_PRC+WorkTInv->( EF3_FORN+EF3_LOJAFO+EF3_INVIMP+EF3_LINHA )) )
                  WorkEF3->( dbDelete() )
               EndIf

            EndIf
         EndIf

         WorkTInv->( dbSkip() )
      EndDo

   Else
      WorkTInv->( dbGoTop(), dbEval({|| MARCA := ""}), dbGoTop() )
   EndIf

End Sequence

WorkTInv->( dbSetOrder(2) )
WorkEF3->(dbSetOrder(ORDEM_BROWSE))

aHeader := aClone(aHeaderAux)
aCols   := aClone(aColsAux)

Return .T.

*********************
Function MarcaTInvs()
*********************
Local nRec  := WorkTInv->( RecNo() )
Local lOk   := .F.
Local bCond

dDataFlt := dDataBase

Define MsDialog oDlgFlt Title STR0120 From 12,05 To 17,50 Of GetWndDefault()  //"Seleção por Data"

   @01.5,02 SAY STR0110 of oDlgFlt  //"Data"
   @01.5,08 MSGET dDataFlt PICT "@D" SIZE 60,8 Of oDlgFlt

Activate MsDialog oDlgFlt On Init EnchoiceBar(oDlgFlt,{||lOk:=.T.,oDlgFlt:End()},{||lOk:=.F.,oDlgFlt:End()}) Centered

If lOk .AND. !Empty(dDataFlt)
   bCond := {|| WorkTInv->EF3_DT_EVE == dDataFlt }
EndIf

WorkTInv->( dbSetOrder(1) )

If WorkTInv->( dbSeek(cMarca) ) .AND. !WorkTInv->( dbSeek(Space(2)) )
   WorkTInv->( dbSetOrder(0) )
   WorkTInv->( dbGoTop(), dbEval({|| MARCA := ""    },bCond), dbGoTo(nRec) )
Else
   WorkTInv->( dbSetOrder(0) )
   WorkTInv->( dbGoTop(), dbEval({|| MARCA := cMarca},bCond), dbGoTo(nRec) )
EndIf

Return .T.

*****************************
Function EX401GetLiq(aTxLiq)
*****************************
Local   i      := 0

Private nRet   := 0
Private aAltera := {}
Private aHeader := {}
Private aCols   := {}

   AAdd( aHeader, { AVSX3("EF3_CONTRA",05) , "EF3_CONTRA", AVSX3("EF3_CONTRA", 06), AVSX3("EF3_CONTRA", 03) , AVSX3("EF3_CONTRA", 04) , "" , NIL , AVSX3("EF3_CONTRA", 02) , NIL , NIL} ) // "Contrato"
   AAdd( aHeader, { AVSX3("EF3_BANC"  ,05) , "EF3_BANC"  , AVSX3("EF3_BANC"  , 06), AVSX3("EF3_BANC"  , 03) , AVSX3("EF3_BANC"  , 04) , "" , NIL , AVSX3("EF3_BANC"  , 02) , NIL , NIL} ) // "Banco"
   AAdd( aHeader, { AVSX3("EF3_PRACA" ,05) , "EF3_PRACA" , AVSX3("EF3_PRACA" , 06), AVSX3("EF3_PRACA" , 03) , AVSX3("EF3_PRACA" , 04) , "" , NIL , AVSX3("EF3_PRACA" , 02) , NIL , NIL} ) // "Praca"
   AAdd( aHeader, { AVSX3("EF3_SEQCNT",05) , "EF3_SEQCNT", AVSX3("EF3_SEQCNT", 06), AVSX3("EF3_SEQCNT", 03) , AVSX3("EF3_SEQCNT", 04) , "" , NIL , AVSX3("EF3_SEQCNT", 02) , NIL , NIL} ) // "Sequencia do Contrato"
   AAdd( aHeader, { AVSX3("EF3_INVOIC",05) , "EF3_INVOIC", AVSX3("EF3_INVOIC", 06), AVSX3("EF3_INVOIC", 03) , AVSX3("EF3_INVOIC", 04) , "" , NIL , AVSX3("EF3_INVOIC", 02) , NIL , NIL} ) // "Invoice"
   AAdd( aHeader, { AVSX3("EF3_PARC"  ,05) , "EF3_PARC"  , AVSX3("EF3_PARC"  , 06), AVSX3("EF3_PARC"  , 03) , AVSX3("EF3_PARC"  , 04) , "" , NIL , AVSX3("EF3_PARC"  , 02) , NIL , NIL} ) // "Parcela"
   AAdd( aHeader, { STR0110+STR0012        , "WB_DT_EVE" , AVSX3("EF3_DT_EVE", 06), AVSX3("EF3_DT_EVE", 03) , AVSX3("EF3_DT_EVE", 04) , "" , NIL , AVSX3("EF3_DT_EVE", 02) , NIL , NIL} ) // "Data Liquidacao"
   AAdd( aHeader, { AVSX3("EF3_MOE_IN",05) , "EF3_MOE_IN", AVSX3("EF3_MOE_IN", 06), AVSX3("EF3_MOE_IN", 03) , AVSX3("EF3_MOE_IN", 04) , "" , NIL , AVSX3("EF3_MOE_IN", 02) , NIL , NIL} ) // "Moeda Invoice"
   AAdd( aHeader, { STR0111+STR0012        , "EF3_TX_MOE", AVSX3("EF3_TX_MOE", 06), AVSX3("EF3_TX_MOE", 03) , AVSX3("EF3_TX_MOE", 04) , "" , NIL , AVSX3("EF3_TX_MOE", 02) , NIL , NIL} ) // "Taxa Invoice"
   AAdd( aHeader, { AVSX3("EF3_VL_INV",05) , "EF3_VL_INV", AVSX3("EF3_VL_INV", 06), AVSX3("EF3_VL_INV", 03) , AVSX3("EF3_VL_INV", 04) , "" , NIL , AVSX3("EF3_VL_INV", 02) , NIL , NIL} ) // "Vl. Moeda Invoice"
   AAdd( aHeader, { STR0121+STR0122        , "EF1_MOEDA" , AVSX3("EF1_MOEDA" , 06), AVSX3("EF1_MOEDA" , 03) , AVSX3("EF1_MOEDA" , 04) , "" , NIL , AVSX3("EF1_MOEDA" , 02) , NIL , NIL} ) // "Moeda Contrato"
   AAdd( aHeader, { STR0111+STR0122        , "TAXA"      , AVSX3("EF3_TX_MOE", 06), AVSX3("EF3_TX_MOE", 03) , AVSX3("EF3_TX_MOE", 04) , "" , NIL , AVSX3("EF3_TX_MOE", 02) , NIL , NIL} ) // "Taxa Liquidacao"
   AAdd( aHeader, { STR0123+STR0122        , "EF3_VL_MOE", AVSX3("EF3_VL_MOE", 06), AVSX3("EF3_VL_MOE", 03) , AVSX3("EF3_VL_MOE", 04) , "" , NIL , AVSX3("EF3_VL_MOE", 02) , NIL , NIL} ) // "Vl. Moeda Contrato"

   AAdd( aAltera , "EF3_VL_MOE" )

   aNoFields := {}
   SX3->( DBSetOrder(2) )
   SX3->( DBSeek("EF3") )
   Do While SX3->( !EoF()  .And.  X3_ARQUIVO == "EF3" )
      AAdd( aNoFields, AllTrim(SX3->X3_CAMPO) )
      SX3->( DBSkip() )
   EndDo
   cSeek     := ""
   cWhile    := ""
   FillGetDados(4,"EF3",1,cSeek,{||&cWhile},{||.T.},aNoFields,,,,{ || EX401aCols(aTxLiq) },,,,,,,)

   DEFINE MSDIALOG oDlg TITLE STR0124 FROM oMainWnd:nTop + 100, oMainWnd:nLeft + 1 TO oMainWnd:nHeight-100, oMainWnd:nWidth-40 OF oMainWnd PIXEL  // "Taxas da Liquidacao - Financiamento"

   oGetMS:= MsGetDados():New(66,1,150,(oDlg:nClientWidth-4)/2, 4 , "AllwaysTrue()" ,"AllwaysTrue()" ,"AllwaysTrue()" , .F. , aAltera, , , Len(aCols), "EX401MGDOk()" )
   oGetMS:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
   oGetMS:oBROWSE:bADD    := {|| oGetMS:LCHGFIELD := .F.}
   oGetMS:oBrowse:bDelete := {|| .F.}
  	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nRet:=1, oDlg:End()},{||oDlg:End(),nRet:=0},,)

   If nRet == 1
      aTxLiq := AClone( aCols )
      For i := 1 to Len(aTxLiq)
         ASize( aTxLiq[i] , Len(aTxLiq[i])-1 )
      Next i
   EndIf

   aHeader := {}
   aCols   := {}
   aAltera := {}

Return aTxLiq


******************************
Function EX401aCols(aTxLiq)
******************************

 Local i := 1        ,;
       nOrdEF3 := 0  ,;
       nRecEF3 := 0  ,;
       cFilEF3 := ""

   nOrdEF3 := EF3->( IndexOrd() )
   nRecEF3 := EF3->( RecNo() )
   cFilEF3 := xFilial("EF3")

   EF3->( DBSetOrder(1) )
   aTxLiq := ASort( aTxLiq , , , {|x,y| x[1]+x[2]+x[3]+IIF(lEFFTpMod,x[4],"") < y[1]+y[2]+y[3]+IIF(lEFFTpMod,y[4],"") } )
   aCols := AClone( aTxLiq )
   For i := 1  to  Len(aCols)
      EF3->( DBSeek(cFilEF3+IMP+aCols[i][GDFieldPos("EF3_CONTRA")]+aCols[i][GDFieldPos("EF3_BANC")]+aCols[i][GDFieldPos("EF3_PRACA")]+aCols[i][GDFieldPos("EF3_SEQCNT")]+EV_EMBARQUE) )
      AAdd( aCols[i] , "EF3" )
      AAdd( aCols[i] , EF3->( RecNo() ) )
      AAdd( aCols[i] , .F. )
   Next i

   EF3->( DBSetOrder(nOrdEF3) )
   EF3->( DBGoTo(nRecEF3) )

Return


*********************
Function EX401MGDOk()
*********************

   If M->EF3_VL_MOE <= 0
      MsgStop(STR0125)  // "Digite um valor maior que zero."
      Return .F.
   Else
      //Valor Contrato := ( Valor Invoice * Taxa Invoice ) / Taxa Contrato
      GDFieldPut( "TAXA" , ( GDFieldGet("EF3_VL_INV",n) * GDFieldGet("EF3_TX_MOE",n) ) / M->EF3_VL_MOE , n )
   EndIf

Return .T.

********************************
Function EX401GrEncargos(cAlias)
********************************
Local nInd, nInd2, nValAux
Local aCpoAux:= {}
Local nOrdEF3:= (cAlias)->( IndexOrd() )
Local cSeq := ""
Local lLoadEF1 as logical 

EX401Var("lEFFTpMod",.T.)

If Upper(cAlias) == "WORKEF3"

   nPos  := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_CODEAS"})
   nPos2 := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_CODEVE"})
   nPos3 := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_DESEVE"})
   nPos4 := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_TIP_EV"})
   nPos5 := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_VL_PCT"})
   nPos6 := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_CODEBA"})
   nPos7 := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_LIQ"   })
   nPos8 := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_PCT_RJ"})
   nPos9 := aScan(aHeader,{|X| Alltrim(X[2]) == "EF8_TP_REL"})

   cCodEve := WorkEF3->EF3_CODEVE
   nValMoe := WorkEF3->EF3_VL_MOE

   For nInd2:=1 to WorkEF3->(FCount())
      aAdd(aCpoAux,WorkEF3->( FieldGet(nInd2) ))
   Next nInd2

   For nInd := 1 To Len(aCols)

      //If !Empty(aCols[nInd][nPos]) .and. aCols[nInd][nPos] == cCodEve .and. aCols[nInd][nPos5] > 0 //comentado por WFS 29/11/16
      WorkEF3->(DBSetOrder(8))
      If !Empty(aCols[nInd][nPos]) .and. aCols[nInd][nPos] == cCodEve .and. aCols[nInd][nPos5] > 0 .And. !WorkEF3->(DBSeek(WorkEF3->(DtoS(EF3_DT_EVE)) + WorkEF3->EF3_CODEVE + aCols[nInd][nPos2]))

         WorkEF3->( reclock("WorkEF3",.T.) )
         For nInd2 := 1 to Len(aCpoAux)
            If !(FieldName(nInd2) $ "EF3_RECNO/TRB_ALI_WT/TRB_REC_WT")
               WorkEF3->&(FieldName(nInd2)) := aCpoAux[nInd2]
            EndIf
         Next nInd2

         WorkEF3->EF3_NR_CON := ""
         WorkEF3->EF3_EV_VIN := cCodEve
         WorkEF3->EF3_CODEVE := aCols[nInd][nPos2]
         WorkEF3->EF3_DESCEV := aCols[nInd][nPos3]

         If aCols[nInd][nPos4] == "1" //Valor Fixo
            WorkEF3->EF3_VL_MOE := aCols[nInd][nPos5]
         ElseIf aCols[nInd][nPos4] == "2" //Percentual

            nRecNo := WorkEF3->( RecNo() )
            cSeq   := WorkEF3->EF3_SEQ
            If aCols[nInd][nPos6] $ (EV_EMBARQUE+"/"+EV_LIQ_PRC+"/"+EV_LIQ_JUR)  // PLB 15/08/06
               cChave := WorkEF3->( EF3_INVOIC+EF3_PARC )
            Else
               cChave := ""
            EndIf
            If WorkEF3->( dbSetOrder(1), dbSeek(cSeq+aCols[nInd][nPos6]) )
               nValMoe := WorkEF3->EF3_VL_MOE
            //ElseIf WorkEF3->( dbSetOrder(5), dbSeek(aCols[nInd][nPos6]) )
            ElseIf WorkEF3->( dbSetOrder(2), dbSeek(aCols[nInd][nPos6]+cChave) )  // PLB 15/08/06
               nValMoe := WorkEF3->EF3_VL_MOE
            Else
               nValMoe := 0
            EndIf

            WorkEF3->( dbGoTo( nRecNo ) )

            If aCols[nInd][nPos8] == "2"
               WorkEF3->EF3_VL_MOE := nValMoe * aCols[nInd][nPos5] / 100
            Else

               //WorkEF3->EF3_VL_MOE := nValMoe * (((aCols[nInd][nPos5]/((100-aCols[nInd][nPos5])/100))/100)+1) * (aCols[nInd][nPos5]/100)

               // PLB 14/06/06        ( Vl Base / Percentual Reajustado do Vl. Base    ) - Vl Base
               WorkEF3->EF3_VL_MOE := ( nValMoe / ( 1 - ( aCols[nInd][nPos5] / 100 ) ) ) - nValMoe
            EndIf
         EndIf

         If aCols[nInd][nPos7] == "1"
            WorkEF3->EF3_VL_REA := WorkEF3->EF3_VL_MOE * WorkEF3->EF3_TX_MOE
         Else
            WorkEF3->EF3_TX_MOE := 0
            WorkEF3->EF3_VL_REA := 0
         EndIf

         If AvFlags("SIGAEFF_SIGAFIN")
            WorkEF3->EF3_FORN    := aCols[nInd][GDFieldPos("EF8_FORN")]
            WorkEF3->EF3_LOJAFO  := aCols[nInd][GDFieldPos("EF8_LOJA")]
         EndIf

         // ** GFC - 19/04/06
         If lEFFTpMod
            WorkEF3->EF3_ROF := M->EF1_ROF
         EndIf
         // **

      EndIf

   Next nInd

Else

   If Type("oEFFContrato") <> "O"
      lLoadEF1:= .T.
   EndIf

   cCodEve := EF3->EF3_CODEVE
   nValMoe := EF3->EF3_VL_MOE

   For nInd2:=1 to EF3->(FCount())
      aAdd(aCpoAux,EF3->( FieldGet(nInd2) ))
   Next nInd2

   cFilEF8 := xFilial("EF8")
   EF8->( dbSetOrder(2) )
   EF8->( dbSeek(cFilEF8+AvKey(EF3->(IIF(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IIF(lEFFTpMod,EF3_SEQCNT,"")),"EF8_CHAVE")+cCodEve) )
   Do While EF8->( !EoF() .AND. EF8_FILIAL+EF8_CHAVE+EF8_CODEAS == cFilEF8+AvKey(EF3->(IIF(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IIF(lEFFTpMod,EF3_SEQCNT,"")),"EF8_CHAVE")+cCodEve )

      If EF8->EF8_VL_PCT > 0
         //Gera Encargo
         RecLock("EF3",.T.)

         For nInd2 := 1 to Len(aCpoAux)
            EF3->&(FieldName(nInd2)) := aCpoAux[nInd2]
         Next nInd2

         EF3->EF3_NR_CON := ""
         EF3->EF3_EV_VIN := cCodEve
         EF3->EF3_CODEVE := EF8->EF8_CODEVE

         If EF8->EF8_TIP_EV == "1" //Valor Fixo
            EF3->EF3_VL_MOE := EF8->EF8_VL_PCT
         ElseIf EF8->EF8_TIP_EV == "2" //Percentual
            nRecNo := EF3->( RecNo() )
            cSeq   := EF3->EF3_SEQ

            cChave  := EF3->( EF3_FILIAL+IIF(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IIF(lEFFTpMod,EF3_SEQCNT,"") )
            If EF8->EF8_CODEBA $ (EV_EMBARQUE+"/"+EV_LIQ_PRC+"/"+EV_LIQ_JUR)
               cChave2 := EF3->( EF3_PARC+EF3_INVOIC+IIF(lEFFTpMod,EF3_INVIMP+EF3_LINHA,"") )
            Else
               cChave2 := ""
            EndIf
            If EF3->( dbSetOrder(4), dbSeek(cChave+cSeq+EF8->EF8_CODEBA) )  .Or.  EF3->( dbSetOrder(1), dbSeek(cChave+EF8->EF8_CODEBA+cChave2) )  // PLB 15/08/06 - Incluso Parcela Invoice no Seek quando o evento for de vinculação ou liquidacao.
               nValMoe := EF3->EF3_VL_MOE
            ElseIf EF3->( dbSetOrder(1), dbSeek(cChave+EF8->EF8_CODEBA) )
               nValMoe := EF3->EF3_VL_MOE
            Else
               nValMoe := 0
            EndIf

            EF3->( dbGoTo( nRecNo ) )

            If EF8->EF8_PCT_RJ == "2"
               EF3->EF3_VL_MOE := nValMoe * EF8->EF8_VL_PCT / 100
            Else
               EF3->EF3_VL_MOE := ( nValMoe * EF8->EF8_VL_PCT  ) / ( 100 - EF8->EF8_VL_PCT )
            EndIf
         EndIf

         If EF8->EF8_LIQ == "1"
            EF3->EF3_VL_REA := EF3->EF3_VL_MOE * EF3->EF3_TX_MOE
         Else
            EF3->EF3_TX_MOE := 0
            EF3->EF3_VL_REA := 0
         EndIf

         // ** GFC - 19/04/06
         If lEFFTpMod
            EF3->EF3_ROF := EF1->EF1_ROF
         EndIf
         // **

         If AvFlags("SIGAEFF_SIGAFIN")
            EF3->EF3_FORN    := EF8->EF8_FORN
            EF3->EF3_LOJAFO  := EF8->EF8_LOJA
         EndIf

         EF3->(msUnlock())

         If AvFlags("SIGAEFF_SIGAFIN") .AND. Left(EF3->EF3_CODEVE,1) $ "3/4"
            If lLoadEF1
               oEFFContrato := AvEFFContra():LoadEF1(EF3->EF3_TPMODU,EF3->EF3_CONTRA,EF3->EF3_BAN_FI,EF3->EF3_PRACA,EF3->EF3_SEQCNT)
               lLoadEF1:= .F.
            EndIf
            oEFFContrato:EventoEF3("INCLUSAO")
         EndIf
      EndIf

      EF8->( dbSkip() )
   EndDo

EndIf

(cAlias)->( dbSetOrder(nOrdEF3) )

Return .T.

//AAF 10/04/2006 - Totais por Contrato
**********************
Function EX401TotCon()
**********************
Local i       := 0
Local nTotal  := 0
Local nTotal2 := 0
Local nRecEF1 := 0

Private aHeader := {}
Private aCols   := {}

aAdd( aHeader, { AVSX3("EF1_CONTRA",05) , "EF1_CONTRA", AVSX3("EF1_CONTRA", 06), AVSX3("EF1_CONTRA", 03) , AVSX3("EF1_CONTRA", 04) , "" , NIL , AVSX3("EF1_CONTRA", 02) , NIL , NIL} ) // "Contrato"
aAdd( aHeader, { AVSX3("EF1_BAN_FI",05) , "EF1_BAN_FI", AVSX3("EF1_BAN_FI", 06), AVSX3("EF1_BAN_FI", 03) , AVSX3("EF1_BAN_FI", 04) , "" , NIL , AVSX3("EF1_BAN_FI", 02) , NIL , NIL} ) // "Banco"
aAdd( aHeader, { AVSX3("EF1_PRACA" ,05) , "EF1_PRACA" , AVSX3("EF1_PRACA" , 06), AVSX3("EF1_PRACA" , 03) , AVSX3("EF1_PRACA" , 04) , "" , NIL , AVSX3("EF1_PRACA" , 02) , NIL , NIL} ) // "Praca"
If lEFFTpMod
   aAdd( aHeader, { AVSX3("EF1_SEQCNT",05) , "EF1_SEQCNT", AVSX3("EF1_SEQCNT", 06), AVSX3("EF1_SEQCNT", 03) , AVSX3("EF1_SEQCNT", 04) , "" , NIL , AVSX3("EF1_SEQCNT", 02) , NIL , NIL} ) // "Sequencia do Contrato"
EndIf
aAdd( aHeader, { AVSX3("EF1_VM_FIN",05) , "EF1_VM_FIN", AVSX3("EF1_VM_FIN", 06), AVSX3("EF1_VM_FIN", 03) , AVSX3("EF1_VM_FIN", 04) , "" , NIL , AVSX3("EF1_VM_FIN", 02) , NIL , NIL} )
aAdd( aHeader, { AVSX3("EF1_DT_CON",05) , "EF1_DT_CON", AVSX3("EF1_DT_CON", 06), AVSX3("EF1_DT_CON", 03) , AVSX3("EF1_DT_CON", 04) , "" , NIL , AVSX3("EF1_DT_CON", 02) , NIL , NIL} )
aAdd( aHeader, { AVSX3("EF1_DT_JUR",05) , "EF1_DT_JUR", AVSX3("EF1_DT_JUR", 06), AVSX3("EF1_DT_JUR", 03) , AVSX3("EF1_DT_JUR", 04) , "" , NIL , AVSX3("EF1_DT_JUR", 02) , NIL , NIL} )
aAdd( aHeader, { AVSX3("EF1_MOEDA",05)  , "EF1_MOEDA" , AVSX3("EF1_MOEDA" , 06), AVSX3("EF1_MOEDA" , 03) , AVSX3("EF1_MOEDA" , 04) , "" , NIL , AVSX3("EF1_MOEDA" , 02) , NIL , NIL} ) // "Moeda Invoice"
If lEFFTpMod  .And.  cMod == IMP
   aAdd( aHeader, { STR0126 , "VL_CONT", AVSX3("EF1_VL_MOE", 06), AVSX3("EF1_VL_MOE", 03) , AVSX3("EF1_VL_MOE", 04) , "" , NIL , AVSX3("EF1_VL_MOE", 02) , NIL , NIL} ) // "Vl. Contrato"
EndIf
aAdd( aHeader, { AVSX3("EF1_VL_MOE",05) , "EF1_VL_MOE", AVSX3("EF1_VL_MOE", 06), AVSX3("EF1_VL_MOE", 03) , AVSX3("EF1_VL_MOE", 04) , "" , NIL , AVSX3("EF1_VL_MOE", 02) , NIL , NIL} ) // "Vl. Moeda Invoice"

cFilEF1 := xFilial("EF1")
nRecEF1 := EF1->( RecNo() )
If lCadFin
   cFilEF7:= xFilial("EF7")
EndIf
//EF1->( dbSeek(cFilEF1) )
cChave := EF1->( EF1_FILIAL+IIF(lEFFTpMod,EF1_TPMODU,"")+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA )
EF1->( dbSeek(cChave) )
Do While EF1->( !EoF() .AND. EF1_FILIAL == cFilEF1 )

   If cChave <> EF1->( EF1_FILIAL+IIF(lEFFTpMod,EF1_TPMODU,"")+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA )
      aAdd(aCols, Array(Len(aHeader)+1) )
      nPos   := Len(aCols)
      EF1->( dbSkip(-1) )

      If lEFFTpMod
         aCols[nPos,GDFieldPos("EF1_CONTRA")] := "TOTAL:"
      EndIf
      //aCols[nPos,GDFieldPos("EF1_VM_FIN")] := Posicione("EF7",1,cFilEF7+EF1->EF1_TP_FIN,"EF7_DESCRI")
      aCols[nPos,GDFieldPos("EF1_MOEDA")]  := EF1->EF1_MOEDA
      aCols[nPos,GDFieldPos("EF1_VL_MOE")] := nTotal
      If lEFFTpMod  .And.  cMod == IMP
         aCols[nPos,GDFieldPos("VL_CONT")] := nTotal2
      EndIf
      //EF1->( dbSkip() )
      nTotal  := 0
      nTotal2 := 0
      Exit
   EndIf

   aAdd(aCols, Array(Len(aHeader)+1) )
   nPos := Len(aCols)

   aCols[nPos,GDFieldPos("EF1_CONTRA")] := EF1->EF1_CONTRA
   aCols[nPos,GDFieldPos("EF1_BAN_FI")] := EF1->EF1_BAN_FI
   aCols[nPos,GDFieldPos("EF1_PRACA")]  := EF1->EF1_PRACA
   If lEFFTpMod
      aCols[nPos,GDFieldPos("EF1_SEQCNT")] := EF1->EF1_SEQCNT
   EndIf
   aCols[nPos,GDFieldPos("EF1_DT_CON")] := EF1->EF1_DT_CON
   aCols[nPos,GDFieldPos("EF1_DT_JUR")] := EF1->EF1_DT_JUR
   If lCadFin
      aCols[nPos,GDFieldPos("EF1_VM_FIN")] := Posicione("EF7",1,cFilEF7+EF1->EF1_TP_FIN,"EF7_DESCRI")
   Else
      aCols[nPos,GDFieldPos("EF1_VM_FIN")] := Posicione('SX5',1,xFilial('SX5')+'CG'+EF1->EF1_TP_FIN,'X5_DESCRI')
   EndIf
   aCols[nPos,GDFieldPos("EF1_MOEDA")]  := EF1->EF1_MOEDA
   If lEFFTpMod  .And.  cMod == IMP
      aCols[nPos,GDFieldPos("VL_CONT")]    := EF1->EF1_VL_MOE
      If !Empty(EF1->EF1_DT_JUR)
         aCols[nPos,GDFieldPos("EF1_VL_MOE")] := EF1->EF1_VL_MOE
      Else
         aCols[nPos,GDFieldPos("EF1_VL_MOE")] := 0
      EndIf
   Else
      aCols[nPos,GDFieldPos("EF1_VL_MOE")] := EF1->EF1_VL_MOE
   EndIf

   If !Empty(EF1->EF1_DT_JUR)
      nTotal += EF1->EF1_VL_MOE
   EndIf
   nTotal2 += EF1->EF1_VL_MOE
   cChave := EF1->( EF1_FILIAL+IIF(lEFFTpMod,EF1_TPMODU,"")+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA )

   EF1->( dbSkip() )
EndDo

Define MsDialog oDlg Title STR0127 From oMainWnd:nTop + 100, oMainWnd:nLeft + 1 To oMainWnd:nHeight-100, oMainWnd:nWidth-40 Of oMainWnd Pixel  // "Total por Contrato de Financiamento"

   oGetMS:= MsGetDados():New(66,1,150,(oDlg:nClientWidth-4)/2, 4 , "AllwaysTrue()" ,"AllwaysTrue()" ,"AllwaysTrue()" , .F. , {}, , , Len(aCols), "" )
   oGetMS:oBrowse:Align   := CONTROL_ALIGN_ALLCLIENT
   oGetMS:oBROWSE:bADD    := {|| oGetMS:LCHGFIELD := .F.}
   oGetMS:oBrowse:bDelete := {|| .F.}

Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() })

EF1->( DBGoTo(nRecEF1) )

Return .T.

**********************
Function EX401VerRof()
**********************

If lCadFin .AND. !Empty(M->EF1_ROF) .AND. EF9->( dbSetOrder(5), dbSeek(xFilial("EF9")+M->EF1_ROF) )
   MsgInfo(STR0128+EF9->EF9_ROF,STR0129)  //"Este ROF está sendo utilizado como ROF anterior para o ROF " ##  , "Atualize o ROF"
EndIf

Return .T.

*--------------------------------------------------------------------------------------------------*
Function EX401Amort(cOpcao)
*--------------------------------------------------------------------------------------------------*

/*
   nopado por RNLP pois botoes ja declarados como private no Fonte EFFEX400 - 
Local bBarOk := {||If(Obrigatorio(aGets,aTela) .and. GravaCapa(nOpc),Eval(bOk),)}
Local bBarCancel := {||If(nOpc<>VISUALIZAR .and. nOpc<>ESTORNAR,If(MsgYesNo(STR0008+Chr(13)+Chr(10)+STR0009),Eval(bCancel),),Eval(bCancel))} //"Deseja Realmente Sair?"###"Todas as alterações serão perdidas."
*/
Local aOrdRef := SaveOrd("EF3")
Private lRetContr := .T.  // PLB 13/10/06

If WorkEF3->ALTERADO
      msgstop(STR0198,STR0117) // "Existem alterações nessa parcela pendentes de gravação, salve o contrato primeiro para depois executar a ação desejada.","Aviso"
      RestOrd(aOrdRef,.T.)
      Return .T.
Else
      If cOpcao == "LIQ"
            If lRefinimp  // GFP - 09/10/2015
                  aOrdRef := SaveOrd("EF3")
                  If WorkEF3->ALTERADO
                        Help(" ",1,"EFF0000003")  //"Existem vinculações de contratos para refinanciamento pendentes de gravação." ## "É necessário salvar as alterações deste contrato antes de prosseguir."
                        RestOrd(aOrdRef,.T.)
                        Return .T.
                  Else
                        EF3->(DbSetOrder(10))  //"EF3_FILIAL+EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR+EF3_CODEVE"
                        If EF3->(DbSeek(xFilial("EF3")+WorkEF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVIMP+EF3_LINHA)))
                              If !MsgYesNo(STR0190,STR0117)  // "Essa parcela está vinculada a outro contrato para refinanciamento. Deseja prosseguir?" ## "Aviso"
                                    RestOrd(aOrdRef,.T.)
                                    Return
                              EndIf
                        EndIf
                  EndIf
                  RestOrd(aOrdRef,.T.)
            EndIf
            //FSM - 22/03/2012
            If !(lEFFTpMod .AND. M->EF1_CAMTRA == "1" .AND. M->EF1_TPMODU == "E" .OR. lPrePag .And. M->EF1_TP_FIN $ ("03/04")) .AND.;
            Empty(WorkEF3->EF3_TX_MOE) .AND. WorkEF3->EF3_CODEVE <> EV_PRINC_PREPAG .and. EX400EVJuros(WorkEF3->EF3_CODEVE) .and. ;
            iif( lGerTitEvEnc, !(WorkEF3->EF3_CODEVE $ '180|190') , .T.) /*.And. WorkEF3->EF3_DT_EVE > dDataBase*/  // GFP - 23/09/2014
                  BaixaJuros()
            ElseIf WorkEF3->EF3_CODEVE >= "300" .and. WorkEF3->EF3_CODEVE <= "499"
                  If !Empty(WorkEF3->EF3_TX_MOE)
                        MsgInfo(STR0130+STR0131)  //"Este encargo " "já foi amortizado."
                  Else
                        EX401BxForc(.T.)
                  EndIf
            ElseIf IIF(lEFFTpMod,M->EF1_CAMTRA == "1",lPrePag .And. M->EF1_TP_FIN $ ("03/04"))
                  If !Empty(WorkEF3->EF3_TX_MOE)
                        MsgInfo(STR0132+STR0131)  //"Este evento " "já foi amortizado."
                  ElseIf Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)
                        EX401SelLiq(EX400Valid("BX_JUROS"))
                  Else
                        If WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG
                              EX401SelLiq(EX400Valid("BX_FORCADA"))
                        Else
                              MsgInfo(STR0132+STR0133)  //"Este evento " "não deve ser amortizado."
                        EndIf
                  EndIf
            Else
                  If WorkEF3->EF3_CODEVE == EV_EMBARQUE
                        If EX400Valid("BX_FORCADA")
                              EX401BxForc()
                        EndIf
                  Else
                        If WorkEF3->EF3_CODEVE == EV_PRINC
                              If EX400Valid("BX_FORCADA")
                                    If EX401VBxCon("ENCERRAMENTO")
                                          EX401BxCon()
                                    EndIf
                              EndIf
                        ElseIf WorkEF3->EF3_CODEVE $ '180|190'
                              If EX400Valid("BX_ENCERRAMENTO")
                                    EX401BxEnc()
                              EndIf
                        Else
                              BaixaJuros()
                        EndIf
                  EndIf
            EndIf
      ElseIf cOpcao == "EST"
            If lRefinimp  // GFP - 09/10/2015
                  aOrdRef := SaveOrd({"EF1","EF3"})
                  EF3->(DbSetOrder(10))  //"EF3_FILIAL+EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR+EF3_CODEVE"
                  If EF3->(DbSeek(xFilial("EF3")+WorkEF3->(EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVIMP+EF3_LINHA)))
                        EF1->(DbSetOrder(1))  //"EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT"
                        If EF1->(DbSeek(xFilial("EF1")+AvKey(EF3->EF3_TPMODU,"EF1_TPMODU")+;
                                                      AvKey(EF3->EF3_CONTRA,"EF1_CONTRA")+;
                                                      AvKey(EF3->EF3_BAN_FI,"EF1_BAN_FI")+;
                                                      AvKey(EF3->EF3_PRACA,"EF1_PRACA")+;
                                                      AvKey(EF3->EF3_SEQCNT,"EF1_SEQCNT")))
                              If !Empty(EF1->EF1_DT_JUR)
                                    Help(" ",1,"EFF0000002")  //"Evento associado a um contrato de refinanciamento que já está em andamento." ## "Necessário retirar a data de inicio de juros do contrato destino para estornar a liquidação."
                                    RestOrd(aOrdRef,.T.)
                                    Return
                              Else
                                    If !MsgYesNo(STR0191,STR0117)  // "Evento liquidado em contrato de refinanciamento, tem certeza que deseja estornar a liquidação?" ## "Aviso")
                                          RestOrd(aOrdRef,.T.)
                                          Return
                                    Endif
                              EndIf
                        EndIf
                  EndIf
                  RestOrd(aOrdRef,.T.)
            EndIf
            If !Empty(WorkEF3->EF3_TX_MOE) .And. dDataBase < IF( WorkEF3->(FieldPos("EF3_DTOREV")) > 0 .And. !Empty(WorkEF3->EF3_DTOREV), WorkEF3->EF3_DTOREV ,WorkEF3->EF3_DT_EVE) .and. WorkEF3->EF3_CODEVE <> "620"
                  MsgInfo(STR0186,STR0117) //#"Esta amortização não pode ser estornada pois a data do estorno é menor que a data da liquidação." ##"Aviso"

            ElseIf ( lEsLqSldCrt := lGerTitEvEnc .and. WorkEF3->EF3_CODEVE $ '180|190') .Or. WorkEF3->EF3_CODEVE >= "300" .and. WorkEF3->EF3_CODEVE <= "499"
                  If Empty(WorkEF3->EF3_TX_MOE)
                        MsgInfo(If(lEsLqSldCrt,"Este Saldo de encerramento não foi liquidado.",STR0130+STR0134) )  //"Este encargo " "não foi amortizado."
                  ElseIf !Empty(WorkEF3->EF3_NR_CON)
                        MsgInfo(If(lEsLqSldCrt,"O pagamento deste Saldo de encerramento já foi contabilizado.",STR0135))  //"O pagamento deste encargo já foi contabilizado."
                  ElseIf MsgYesNo(If(lEsLqSldCrt,"Confirma estorno da liquidação deste Saldo de encerramento?",STR0136) )  //"Confirma estorno da amortização deste encargo?"
                        WorkEF3->EF3_BANC   := ""
                        WorkEF3->EF3_AGEN   := ""
                        WorkEF3->EF3_NCON   := ""
                        WorkEF3->EF3_TX_MOE := 0
                        WorkEF3->EF3_VL_REA := 0
                        WorkEF3->EF3_DT_CNT := AvCtoD("  /  /  ")
                        WorkEF3->EF3_NROP   := ""
                        WorkEF3->EF3_BC_MOV := ""
                        WorkEF3->EF3_AG_MOV := ""
                        WorkEF3->EF3_CC_MOV := ""
                              If WorkEF3->(FieldPos("EF3_DTOREV")) > 0
                                    WorkEF3->EF3_DTOREV := AvCtoD("  /  /  ")
                              EndIf
                  EndIf
            ElseIf WorkEF3->EF3_CODEVE == EV_LIQ_PRC_FC
                  Ex400SetaF(1)
                  EX400EVManut(2,"S",.T.)
                  SetKEY(15,bBarOk)
                  SetKEY(24,bBarCancel)
                  Ex400SetaF(2)
            ElseIf !(lPrePag .AND. M->EF1_CAMTRA == "1")
                  EstBxJuros()
            // PLB 23/10/06
            ElseIf IIF(lEFFTpMod,M->EF1_CAMTRA == "1",lPrepag .And. M->EF1_TP_FIN $ PRE_PAGTO+"/"+SECURITIZACAO)  ;
                  .And.  ( IIF(cMod == IMP,WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG,.F.)  .Or.  Left(WorkEF3->EF3_CODEVE,2)==Left(EV_JUROS_PREPAG,2) )  ;
                  .And.  !Empty(WorkEF3->EF3_TX_MOE)
                  If WorkEF3->EF3_CODEVE == EV_PRINC_PREPAG
                        If EX400Valid("EST_BX_FORCADA")
                              EX401SelLiq(.F.,,,,,,,.T.)
                        EndIf
                  ElseIf Left(WorkEF3->EF3_CODEVE,2) == Left(EV_JUROS_PREPAG,2)
                        If EX400Valid("EST_BX_JUROS")
                              EX401SelLiq(.F.,,,,,,,.T.)
                        EndIf
                  EndIf
            Else
                  MsgInfo(STR0137)  //"Esta amortização não pode ser estornada ou o evento não foi amortizado."
            EndIf
      EndIf
endif

RestOrd(aOrdRef,.T.)
Return .T.

*---------------------------------------------------------------------------------------------------*
// PLB 18/07/06 - Verifica se a Data de Inicio de Juros esta compreendida em algum periodo de Juros
*---------------------------------------------------------------------------------------------------*
Function EX401VerJur(cCampo,nOpca)
*---------------------------------------------------------------------------------------------------*
 Local lRet    := .F.  ,;
       nRecEF2 := 0

   If nOpca == NIL
      nOpca := INCLUIR
   EndIf

   nRecEF2 := WorkEF2->( RecNo() )
   WorkEF2->( DBGoTop() )
   Do While !lRet  .And.  !WorkEF2->( EoF() )
      If IIF(lEF2_INVOIC,Empty(WorkEF2->EF2_INVOIC),.T.)  .And.  !( WorkEF2->EF2_DT_INI > M->EF1_DT_JUR  .Or.  WorkEF2->EF2_DT_FIM < M->EF1_DT_JUR );
         .And. (cCampo == "EF1_DT_JUR"  .Or.  ( IIF(nOpca==ALTERAR,nRecEF2 != WorkEF2->( RecNo() ),.T.)  .And.  ( cCampo == "EF2_DT_INI"  .Or.  cCampo == "EF2_DT_FIM" ) ) )
         lRet := .T.
         Exit
      EndIf
      WorkEF2->( DBSkip() )
   EndDo
   WorkEF2->( DBGoTo(nRecEF2) )

   If !lRet
      If cCampo == "EF2_DT_INI"  .And.  nOpca == ALTERAR
         If IIF(lEF2_INVOIC,Empty(M->EF2_INVOIC),.T.)
            //If M->EF2_DT_INI > M->EF1_DT_JUR  .And.  M->EF1_DT_JUR == M->EF1_DT_CTB
            // PLB 13/06/07
            If M->EF2_DT_INI > M->EF1_DT_JUR  .And.  ( Empty(M->EF1_DT_CTB)  .Or.  !lIsContab )
               If MsgYesNo(STR0138+Transform(M->EF2_DT_INI,"@D")+"?")  //"A Data Inicial do Periodo e posterior a Data de Inicio de Juros e nao ha outro periodo que a contemple. Deseja alterar a Data de Início de Juros para "
                  cDtAux := M->EF1_DT_JUR
                  M->EF1_DT_JUR := M->EF2_DT_INI
                  If EX400Valid("EF1_DT_JUR")
                     dDtIni   := WorkEF2->EF2_DT_INI
                     dDtFim   := WorkEF2->EF2_DT_FIM
                     If lEF2_INVOIC
                        cInvoice := WorkEF2->EF2_INVOIC
                        WorkEF2->EF2_INVOIC := M->EF2_INVOIC
                     EndIf
                     WorkEF2->EF2_DT_INI := M->EF2_DT_INI
                     WorkEF2->EF2_DT_FIM := M->EF2_DT_FIM
                     If lEF2_INVOIC
                        WorkEF2->EF2_INVOIC := cInvoice
                     EndIf
                     WorkEF2->EF2_DT_INI := dDtIni
                     WorkEF2->EF2_DT_FIM := dDtFim
                     lRet := .T.
                  Else
                     M->EF1_DT_JUR := cDtAux
                     lRet := .F.
                  EndIf
               Else
                  M->EF2_DT_INI := WorkEF2->EF2_DT_INI
               EndIf
            Else
               lRet := .T.
            EndIf
         EndIf
      ElseIf cCampo == "EF2_DT_FIM"
         If IIF(lEF2_INVOIC,Empty(M->EF2_INVOIC),.T.)
            If M->EF2_DT_FIM < M->EF1_DT_JUR
               MsgInfo(STR0139+Transform(M->EF2_DT_INI,"@D")+STR0140)  //"A Data Final do Periodo e anterior a Data de Inicio de Juros (" ##
            Else
               lRet := .T.
            EndIf
         EndIf
      EndIf
   EndIf

Return lRet

*---------------------------------------------------------------------------------------------------*
// PLB 31/07/06 - Retorna o STR de acordo com o numero. Funcao criada para o EFFEX400
*---------------------------------------------------------------------------------------------------*
Function EX401STR(nSTR1,nSTR2,nSTR3)
*---------------------------------------------------------------------------------------------------*
 Local cSTR := ""  ,;
       aSTR := {}  ,;
       ni   := 1

   If nSTR1 != NIL
      AADD(aSTR,nSTR1)
   EndIf
   If nSTR2 != NIL
      AADD(aSTR,nSTR2)
   EndIf
   If nSTR3 != NIL
      AADD(aSTR,nSTR3)
   EndIf


   For ni := 1  to  Len(aSTR)
      Do Case

         Case aSTR[ni] ==  35 ;  cSTR += STR0035  //" esta Pre-Vinculada ao Contrato "
         Case aSTR[ni] ==  36 ;  cSTR += STR0036  //"Confirma a Vinculacao"
         Case aSTR[ni] ==  37 ;  cSTR += STR0037  //" Banco "
         Case aSTR[ni] ==  38 ;  cSTR += STR0038  //" Praca "
         Case aSTR[ni] ==  39 ;  cSTR += STR0039  //" Sequencia "
         Case aSTR[ni] ==  40 ;  cSTR += STR0040  //"Esta liquidacao nao ira tirar a pendencia do cliente no cambio de exportacao."
         Case aSTR[ni] ==  41 ;  cSTR += STR0041  //" Confirma a liquidacao?"
         Case aSTR[ni] ==  42 ;  cSTR += STR0042  //"Financiamento desabilitado para filiais off-shore."
         Case aSTR[ni] ==  43 ;  cSTR += STR0043  //"Data de Inicio dos Juros precisa estar compreendida em algum Periodo de Juros!"
         Case aSTR[ni] ==  44 ;  cSTR += STR0044  //"Linha de credito deve estar preenchida."
         Case aSTR[ni] ==  45 ;  cSTR += STR0045  //"Não há vinculações liquidadas neste contrato."
         Case aSTR[ni] ==  46 ;  cSTR += STR0046  //"Ha invoices vinculadas nao liquidadas."
         Case aSTR[ni] ==  47 ;  cSTR += STR0047  //"Nao ha saldo suficiente nesta Linha de Credito."
         Case aSTR[ni] ==  48 ;  cSTR += STR0048  //"Nao ha saldo suficiente neste ROF."
         Case aSTR[ni] ==  49 ;  cSTR += STR0049  //"Este ROF esta vencido."
         Case aSTR[ni] ==  50 ;  cSTR += STR0050  //"Esta Linha de Credito esta vencida.
         Case aSTR[ni] ==  51 ;  cSTR += STR0051  //"O Valor do contrato difere do valor das vinculacoes. Deseja alterar o valor do contrato para "
         Case aSTR[ni] ==  52 ;  cSTR += STR0052  //"Nao e permitido retirar a data de inicio dos juros pois existem liquidacoes."
         Case aSTR[ni] ==  53 ;  cSTR += STR0053  //"Deseja atualizar os encargos para esse tipo de financiamento?"
         Case aSTR[ni] ==  54 ;  cSTR += STR0054  //"Encargos"
         Case aSTR[ni] ==  55 ;  cSTR += STR0055  //"O evento de liquidacao do principal nao pode ser excluido. "
         Case aSTR[ni] ==  56 ;  cSTR += STR0056  //"O evento de liquidacao do juros nao pode ser excluido. "
         Case aSTR[ni] ==  57 ;  cSTR += STR0057  //"Estorne a liquidacao pela rotina de FFC ou pela manutencao de cambio"
         Case aSTR[ni] ==  58 ;  cSTR += STR0058  //" ou estorne a liquidacao do juros."
         Case aSTR[ni] ==  59 ;  cSTR += STR0059  //"Tot.p/Contrato"
         Case aSTR[ni] ==  60 ;  cSTR += STR0060  //"Valor a Vincular e maior que o valor do contrato."
         Case aSTR[ni] ==  61 ;  cSTR += STR0061  //"Deseja efetivar a vinculacao e aumentar o valor do contrato para "
         Case aSTR[ni] ==  62 ;  cSTR += STR0062  //"Calculo somente para Parcelas de Pagamento."
         Case aSTR[ni] ==  63 ;  cSTR += STR0063  //"É necessário preencher a data de início do juros para vincular invoices ao contrato."
         Case aSTR[ni] ==  64 ;  cSTR += STR0064  //"Não podem ser feitas novas vinculações neste contrato pois a data de inicio dos juros já está preenchida."
         Case aSTR[ni] ==  65 ;  cSTR += STR0065  //"Deseja atualizar os encargos para esse ROF?"
         Case aSTR[ni] ==  66 ;  cSTR += STR0066  //"Deseja atualizar os encargos para essa Linha de Crédito?"
         Case aSTR[ni] ==  67 ;  cSTR += STR0067  //"Não são permitidas alterações neste evento."
         Case aSTR[ni] ==  68 ;  cSTR += STR0068  //"Confirma estorno da baixa forçada?"
         Case aSTR[ni] ==  69 ;  cSTR += STR0069  //"Confirma o encerramente automatico dos processos?"
         Case aSTR[ni] ==  70 ;  cSTR += STR0070  //"Este programa tem como objetivo imprimir relatório de acordo com os parametros informados pelo usuário."
         Case aSTR[ni] ==  71 ;  cSTR += STR0071  //"Relatório de Estorno Contrato/Processo"
         Case aSTR[ni] ==  72 ;  cSTR += STR0072  //"Zebrado"
         Case aSTR[ni] ==  73 ;  cSTR += STR0073  //"Contabil"
         Case aSTR[ni] ==  74 ;  cSTR += STR0074  //"2 - Cambio de Importação"
         Case aSTR[ni] ==  75 ;  cSTR += STR0075  //"4 - Remessa p/ Exterior"
         Case aSTR[ni] ==  76 ;  cSTR += STR0076  //"Fornecedor"
         Case aSTR[ni] ==  77 ;  cSTR += STR0077  //"Não existe histórico para o contrato "
         Case aSTR[ni] ==  78 ;  cSTR += STR0078  //"Informações"
         Case aSTR[ni] ==  79 ;  cSTR += STR0079  //"Estorno da Vinculação"
         Case aSTR[ni] ==  80 ;  cSTR += STR0080  //"Estorno da Liquidação do FFC "
         Case aSTR[ni] ==  81 ;  cSTR += STR0081  //"Opção 4"
         Case aSTR[ni] ==  82 ;  cSTR += STR0082  //"Outra Opção"
         Case aSTR[ni] == 109 ;  cSTR += STR0109  //"Evento "
         Case aSTR[ni] == 110 ;  cSTR += STR0110  //"Data "
         Case aSTR[ni] == 141 ;  cSTR += STR0141  //"Linha de Crédito não pode ser alterada pois o contrato já possui Parcelas de Pagamento."
         Case aSTR[ni] == 142 ;  cSTR += STR0142  // "700 - Parcela do Principal"
         Case aSTR[ni] == 143 ;  cSTR += STR0143  // "710 - Parcela de Juros"
         Case aSTR[ni] == 146 ;  cSTR += STR0146  //"A Data de Vinculação não pode ser maior do que a data da primeira parcela em aberto: "
         Case aSTR[ni] == 147 ;  cSTR += STR0147  //"A Data de Vinculação não pode ser maior que a data corrente do sistema."
         Case aSTR[ni] == 148 ;  cSTR += STR0148  //"É necessário preencher a data do contrato."
         Case aSTR[ni] == 149 ;  cSTR += STR0149  //"Data de Vinculação deve ser maior que a Data do Contrato!"
         Case aSTR[ni] == 150 ;  cSTR += STR0150  //"Data de Vinculação deve ser menor ou igual a Data de Vencimento!"
         Case aSTR[ni] == 151 ;  cSTR += STR0151  //"Limpar Filtro"
         Case aSTR[ni] == 152 ;  cSTR += STR0152  //"Para alterar o Credor é necessário que os campos "
         Case aSTR[ni] == 153 ;  cSTR += STR0153  //" não estejam preenchidos."
         Case aSTR[ni] == 154 ;  cSTR += STR0154  //"Quantidade de Parcelas não pode ser alterada pois todas as Parcelas já foram vinculadas e/ou liquidadas."
         Case aSTR[ni] == 155 ;  cSTR += STR0155  //"Quantidade de Parcelas não pode ser igual à quantidade de parcelas já vinculadas e/ou liquidadas: "
         Case aSTR[ni] == 156 ;  cSTR += STR0156  //"Esta amortização não pode ser estornada pois a Parcela posterior já foi vinculada e/ou liquidada."
         Case aSTR[ni] == 157 ;  cSTR += STR0157  //"Existem Invoices com Moeda diferente da Moeda do Contrato. Deseja continuar a marcação?"
         Case aSTR[ni] == 158 ;  cSTR += STR0158  //"As Invoices que possuem Moeda diferente da Moeda do Contrato serão vinculadas com as taxas de conversão de acordo com as cotações do dia "
         Case aSTR[ni] == 159 ;  cSTR += STR0159  //"Deseja especificar outras taxas de conversão para moedas diferentes?"
         Case aSTR[ni] == 160 ;  cSTR += STR0160  //"Dados da Invoice"
         Case aSTR[ni] == 161 ;  cSTR += STR0161  //"Moeda da Invoice"
         Case aSTR[ni] == 162 ;  cSTR += STR0162  //"Dados do Contrato"
         Case aSTR[ni] == 163 ;  cSTR += STR0163  //"Moeda do Contrato"
         Case aSTR[ni] == 164 ;  cSTR += STR0164  //"Taxa ME Contrato"
         Case aSTR[ni] == 165 ;  cSTR += STR0165  //"Valor ME Contrato"
         Case aSTR[ni] == 166 ;  cSTR += STR0166  //"O Credor da Linha de Crédito selecionada não é o mesmo do Contrato.Deseja atualizar o Credor do Contrato?"
         Case aSTR[ni] == 167 ;  cSTR += STR0167  //"O Credor do Contrato deve ser o mesmo Credor da Linha de Crédito"
         Case aSTR[ni] == 168 ;  cSTR += STR0168  //"Só é permitido incluir evento entre 300 e 499"
         Case aSTR[ni] == 170 ;  cSTR += STR0170  //"Data de Vencimento deve ser maior que a Data de Início dos Juros!"
         Case aSTR[ni] == 171 ;  cSTR += STR0171  //"Data de Vencimento deve ser maior que a Data do Contrato!"
         Case aSTR[ni] == 172 ;  cSTR += STR0172  //"Preencha o campo "
         Case aSTR[ni] == 173 ;  cSTR += STR0173  //"Deseja Realmente Estornar o Contrato?"
         Case aSTR[ni] == 174 ;  cSTR += STR0174  //"Estorno do Contrato de Financiamento"
         Case aSTR[ni] == 175 ;  cSTR += STR0175  //"Marca/Des."
         Case aSTR[ni] == 176 ;  cSTR += STR0176  //"Gerar Juros do Período"
         Case aSTR[ni] == 177 ;  cSTR += STR0177  //"Ger.Jr.Per"
         Case aSTR[ni] == 178 ;  cSTR += STR0178  //"Juros do Período já foram gerados."
         Case aSTR[ni] == 179 ;  cSTR += STR0179  //"Não é possível gerar Juros de um Período referente a uma Invoice específica."
         Case aSTR[ni] == 180 ;  cSTR += STR0180  //"Os Juros do Período foram gerados com sucesso."
         Case aSTR[ni] == 181 ;  cSTR += STR0181  //"Estorne a liquidacao do juros."
         Case aSTR[ni] == 182 ;  cSTR += STR0182  //"Deseja gerar Juros referente a este Período do Contrato?"
         Case aSTR[ni] == 183 ;  cSTR += STR0183  //"Data de Vinculação não pode ser menor que a Data de Início do Contrato"
         Case aSTR[ni] == 184 ;  cSTR += STR0187  //"Relatório de Contratos"
      End Case

   Next ni

Return cSTR

*------------------------------------------------------------------------------------------------------*
// PLB 14/08/06 - Retorna soma de evento em um contrato de financiamento, EF1 precisa estar posicionado
*------------------------------------------------------------------------------------------------------*
Function EX401EvSum(cCodEve,cAliasEF3,cChave,lMoeda,bCond,aInvExp,lParcelas,cCondic)//aInvExp={cInvoice,cParc}
*------------------------------------------------------------------------------------------------------*
 Local nSum    := 0  ,;
       nRecEF3 := 0  ,;
       nOrdEF3 := 0

 Default lMoeda := .T.
 Default bCond  := {||.T.}
 Default lParcelas := .F.  //NCF - 25/06/2015
 Default cCondic := "AllwaysTrue()"
   If cAliasEF3 == NIL
      cAliasEF3 := "EF3"
   EndIf

   If cChave == NIL
      cChave := ""
   EndIf

   nRecEF3 := (cAliasEF3)->( RecNo()    )
   nOrdEF3 := (cAliasEF3)->( IndexOrd() )

   If cAliasEF3 == "WorkEF3"
      WorkEF3->( DBSetOrder(5) )
      WorkEF3->( DBSeek(cCodeve) )
      Do While !WorkEF3->( EoF() )  .And.  WorkEF3->EF3_CODEVE == cCodEve
         If Eval(bCond) .And. &(cCondic)
            If lMoeda
               nSum += WorkEF3->EF3_VL_MOE
            Else
               nSum += WorkEF3->EF3_VL_REA
            EndIf
         EndIf
         WorkEF3->( DBSkip() )
      EndDo

   ElseIf cAliasEF3 == "EF3"
      If ValType(aInvExp) == "A" .AND. Len(aInvExp) == 2
         cChaveEF3 := cChave+cCodeve+If(!lParcelas,aInvExp[2]+aInvExp[1],'')
         nOrd      := 1
      Else
         cChaveEF3 := cChave+cCodeve
         nOrd      := 1
      EndIf
      EF3->( DBSetOrder(nOrd) )
      EF3->( DBSeek(cChaveEF3) )
      Do While EF3->( !EoF() .AND. Left(&(IndexKey()),Len(cChaveEF3)) == cChaveEF3) //EF3->(EF3_FILIAL+IIF(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IIF(lEFFTpMod,EF3_SEQCNT,"")) == cChave  .And.  EF3->EF3_CODEVE == cCodeve
         If Eval(bCond).And. &(cCondic)
            If lMoeda
               nSum += EF3->EF3_VL_MOE
            Else
               nSum += EF3->EF3_VL_REA
            EndIf
         EndIf
         EF3->( DBSkip() )
      EndDo

   EndIf

   (cAliasEF3)->( DBSetOrder(nOrdEF3) )
   (cAliasEF3)->( DBGoTo(nRecEF3)     )

Return nSum

*------------------------------------------------------------------------------------------------------*
// PLB 23/08/06 - Retorna se existe tipo de Juros ACE cadastrado no Periodos do Contrato
*------------------------------------------------------------------------------------------------------*
Function EX401ExACE(cChamada,cTpJur,cFilOri,cInvoice,cParc)
*------------------------------------------------------------------------------------------------------*
 Local lRet      := .F.    ,;
       cAliasEF1 := "EF1"  ,;
       cAliasEF2 := "EF2"  ,;
       nOrdEF2   := 0      ,;
       nRecEF2   := 0

 Local lEF2_TIPJUR := EF2->(FieldPos("EF2_TIPJUR")) > 0
 Local lEF2_INVOIC := EF2->(FieldPos("EF2_INVOIC")) > 0 .and. EF2->(FieldPos("EF2_PARC")) > 0 .and.;
                      EF2->(FieldPos("EF2_FILORI")) > 0

   If cChamada $ ("CAMB/FFC")
      cAliasEF1 := "EF1"
      cAliasEF2 := "EF2"
   Else
      cAliasEF1 := "M"
      cAliasEF2 := "WorkEF2"
   EndIf

   If lEF2_INVOIC  .And.  ( !lMultiFil  .Or.  cFilOri == NIL )  // PLB 24/11/06
      cFilOri := Space(Len((cAliasEF2)->EF2_FILORI))
   EndIf

   nOrdEF2 := (cAliasEF2)->( IndexOrd() )
   nRecEF2 := (cAliasEF2)->( Recno()    )

   If cAliasEF2 == "EF2"
      EF2->( DBSetOrder(2) )
      lRet := EF2->( DBSeek(cFilEF2+IIF(lEFFTpMod,IIF(cAliasEF1=="M",M->EF1_TPMODU,(cAliasEF1)->EF1_TPMODU),"")+IIF(cAliasEF1=="M",M->EF1_CONTRA,(cAliasEF1)->EF1_CONTRA)+IIF(lTemChave,IIF(cAliasEF1=="M",M->EF1_BAN_FI,(cAliasEF1)->EF1_BAN_FI)+IIF(cAliasEF1=="M",M->EF1_PRACA,(cAliasEF1)->EF1_PRACA),"")+IIF(lEFFTpMod,IIF(cAliasEF1=="M",M->EF1_SEQCNT,(cAliasEF1)->EF1_SEQCNT),"")+IIF(lEF2_INVOIC,cFilOri+cInvoice+cParc,"")+ACE+IIF(lEF2_TIPJUR,cTpJur,"")) )

   ElseIf cAliasEF2 == "WorkEF2"
      WorkEF2->( DBSetOrder(1) )
      lRet := WorkEF2->( DBSeek(IIF(lEF2_INVOIC,cFilOri+cInvoice+cParc,"")+ACE+IIF(lEF2_TIPJUR,cTpJur,"")) )
   EndIf

   (cAliasEF2)->( DBSetOrder(nOrdEF2) )
   (cAliasEF2)->( DBGoTo(nRecEF2)     )

Return lRet


/*
Função      : EX401AjCom
Objetivo    : Ajustar os valores nos campos de tipos de comissão através do percentual de ajuste sob o valor da parcela.
Parametro   : nPercAjuste = Percentual de ajuste sob o valor da parcela.
              cAlias      = Alias da tabela que ira ser atualizada.
Retorno     : Nil
Autor       : Pedro Baroni
Data e Hora : 02/05/2007
Observação  : Caso seja uma tabela a ser atualizada, deve-se estar posicionado no registro a ser ajustado.
*/

*------------------------------------------------------------------------------------------------------*
Static Function EX401AjCom(nPercAjuste, cAlias)
*------------------------------------------------------------------------------------------------------*

 Local nPerc := 0

      &(cAlias+"->EEQ_CGRAFI") := Round(&(cAlias+"->EEQ_CGRAFI")*nPercAjuste, 2)
      &(cAlias+"->EEQ_ADEDUZ") := Round(&(cAlias+"->EEQ_ADEDUZ")*nPercAjuste, 2)
      &(cAlias+"->EEQ_AREMET") := Round(&(cAlias+"->EEQ_AREMET")*nPercAjuste, 2)

      If AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP")
            &(cAlias+"->EEQ_ACRESC") := Round(&(cAlias+"->EEQ_ACRESC") * nPercAjuste, 2)
            &(cAlias+"->EEQ_DECRES") := Round(&(cAlias+"->EEQ_DECRES") * nPercAjuste, 2)
            &(cAlias+"->EEQ_DESCON") := Round(&(cAlias+"->EEQ_DESCON") * nPercAjuste, 2)
      EndIf

Return


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/04/07 11:46:13
*/
Static Function MenuDef()
Private cAvStaticCall := "EFFEX401"

   aRotina := StaticCall(EFFEX400, MenuDef)

Return aRotina


/*
Função      : EX401PELiq
Objetivo    : Verificar se o Período de Juros está Liquidado
Parametro   :
Retorno     : lRet - Retorna o objetivo da função
Autor       : Pedro Baroni
Data e Hora : 28/05/2007
Observação  : É necessário estar posicionado no registro a ser verificado na Tabela WorkEF2
*/

*------------------------------------------------------------------------------------------------------*
Function EX401PELiq()
*------------------------------------------------------------------------------------------------------*

 Local lRet := .F.  ,;
       aOrd := {}

   aOrd := SaveOrd({"WorkEF3"})

   WorkEF3->( DBSetOrder(6) )
   lRet := WorkEF3->( DBSeek(Space(Len(EF3_INVOIC+EF3_PARC))+Left(EV_LIQ_JUR,2)+WorkEF2->EF2_TIPJUR+WorkEF2->EF2_SEQPER) )

   RestOrd(aOrd,.T.)


Return lRet


/*
Função      : EX401PEInv
Objetivo    : Verificar se o Período de Juros refere-se a uma Invoice específica
Parametro   :
Retorno     : lRet - Retorna o objetivo da função
Autor       : Pedro Baroni
Data e Hora : 28/05/2007
Observação  : É necessário estar posicionado no registro a ser verificado na Tabela WorkEF2
*/

*------------------------------------------------------------------------------------------------------*
Function EX401PEInv()
*------------------------------------------------------------------------------------------------------*

 Local lRet := .F.

    lRet := WorkEF2->( !Empty(EF2_FILORI)  .Or.  !Empty(EF2_INVOIC)  .Or.  !Empty(EF2_PARC) )


Return lRet


/*
Função      : EX401PEJur
Objetivo    : Gerar os Juros relativos a um Período de Juros
Parametro   :
Retorno     : NIL
Autor       : Pedro Baroni
Data e Hora : 28/05/2007
Observação  : É necessário estar posicionado no registro a ser verificado na Tabela WorkEF2
*/
*------------------------------------------------------------------------------------------------------*
Function EX401PEJur()
*------------------------------------------------------------------------------------------------------*
Local dDataM //LRS - 31/07/2018

IF M->EF1_DT_JUR > WorkEF2->EF2_DT_INI
   dDataM := M->EF1_DT_JUR
Else
   dDataM := WorkEF2->EF2_DT_INI
EndIF

   EX401GrvLP("M","WorkEF2","WorkEF3",M->EF1_CONTRA,M->EF1_BAN_FI,M->EF1_PRACA,dDataM,WorkEF2->EF2_DT_FIM,WorkEF2->EF2_TIPJUR,INCLUIR,M->EF1_TPMODU,M->EF1_SEQCNT,.F.,"620")
   MsgInfo(STR0180)  //"Os Juros do Período foram gerados com sucesso."

Return NIL


/*
Função      : BuscaEF2Seq
Objetivo    : Buscar qual a rpóxima sequencia de um Período de Juros (para ser gravado em EF2_SEQPER)
Parametros  : cAlias    - Alias da Tabela de Periodos de Juros do Contrato
              cContrato - Numero do Contrato de Financiamento
              cBanco    - Banco do Contrato
              cPraca    - Praca do Contrato
              cTpModu   - Tipo de Modulo do Contrato
              cSeqCon   - Sequencia do Contrato
Retorno     : cSeq - Retorno de acordo com o objetivo da função
Autor       : Pedro Baroni
Data e Hora : 28/05/2007
Observação  :
*/
*-----------------------------------------------------------------------*
Function BuscaEF2Seq(cAlias,cContrato,cBanco,cPraca,cTpModu,cSeqCon)
*-----------------------------------------------------------------------*
Local cSeq, nOldRec, nOldOrd

If(cAlias=NIL,cAlias := "WorkEF2",)
nOldRec := (cAlias)->(RecNo())
nOldOrd := (cAlias)->(IndexOrd())

If cAlias=="WorkEF2"
   (cAlias)->(dbSetOrder(2))
   (cAlias)->(dbGoBottom())
   cSeq := StrZero(Val((cAlias)->EF2_SEQPER) + 1,2,0)
Else
   (cAlias)->(dbSetOrder(4))
   If (cAlias)->(avSeekLast(xFilial("EF2")+cTpModu+cContrato+cBanco+cPraca+cSeqCon))
      cSeq := StrZero(Val((cAlias)->EF2_SEQPER) + 1,2,0)
   Else
      cSeq := StrZero(1,2,0)
   EndIf
EndIf

(cAlias)->(dbGoTo(nOldRec))
(cAlias)->(dbSetOrder(nOldOrd))

Return cSeq


/*
Função      : EX401Saldo
Objetivo    : Calcular Saldos de um Contrato de Financiamento
Parametros  : cAliasEF1 - Alias da Tabela de Contratos
              cTpModu   - Tipo de Modulo do Contrato
              cContrato - Numero do Contrato de Financiamento
              cBanco    - Banco do Contrato
              cPraca    - Praca do Contrato
              cSeqCon   - Sequencia do Contrato
              cAliasEF3 - Alias da Tabela de Eventos do Contrato
Retorno     : aSaldos - Array contendo todos os saldos do Contrato
Autor       : Pedro Baroni
Data e Hora : 28/05/2007
Observação  :
*/
*-----------------------------------------------------------------------------------------*
Function EX401Saldo(cAliasEF1,cTpModu,cContrato,cBanco,cPraca,cSeqCnt,cAliasEF3,lAtualiza)
*-----------------------------------------------------------------------------------------*
 Local lAtuSldDtB:=.T.
 Local aOrd      := {}     ,;
       aSaldos   := {}     ,;
       bWhile    := {|| }  ,;
       cCodEve   := ""     ,;
       cLeftCod  := ""     ,;
       cFilEF3   := ""     ,;
       cKeyEF3   := ""     ,;
       cMod      := ""     ,;
       lMemory   := .F.    ,;
       lWork     := .F.    ,;
       lParcPag  := .F.    ,;
       nSldPME   := 0      ,;
       nSldPRS   := 0      ,;
       nSldJME   := 0      ,;
       nSldJRS   := 0      ,;
       nSl2PME   := 0      ,;
       nSl2PRS   := 0      ,;
       nSl2JME   := 0      ,;
       nSl2JRS   := 0      ,;
       nLiqPME   := 0      ,;
       nLiqPRS   := 0      ,;
       nLiqJME   := 0      ,;
       nLiqJRS   := 0

 If(lAtualiza=NIL,lAtualiza:=.F.,) //ASK 23/10/2007 - Se .T. Atualiza os campos dos Saldos
 Default cAliasEF1 := "EF1"
 Default cAliasEF3 := "EF3"

   aOrd    := SaveOrd({cAliasEF3})
   cFilEF3 := xFilial("EF3")
   lMemory := ( Upper(cAliasEF1) == "M" )
   lWork   := ( Upper(cAliasEF3) == "WORKEF3" )

   cMod := cTpModu
   If lMemory
      lParcPag := ( M->EF1_CAMTRA == "1" )
   Else
      lParcPag := ( EF1->EF1_CAMTRA == "1" )
   EndIf

   If lWork
      bWhile := { || .T. }
      WorkEF3->( DBGoTop() )
   Else
      cKeyEF3 := cFilEF3+cTpModu+cContrato+cBanco+cPraca+cSeqCnt
      EF3->( DBSetOrder(1) )
      EF3->( DBSeek(cKeyEF3) )
      bWhile := { || EF3->( EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT ) == cKeyEF3 }
   EndIf

   If lParcPag

      If cMod == IMP
         If lMemory
            If Empty(M->EF1_DT_JUR)
               nSldPME := M->EF1_VL_MOE
            Else
               nSldPME := EX401EvSum(EV_PRINC,cAliasEF3,cKeyEF3,.T.)  //"100"
               nSldPRS := EX401EvSum(EV_PRINC,cAliasEF3,cKeyEF3,.F.)  //"100"
            EndIf
         Else
            If Empty(EF1->EF1_DT_JUR)
               nSldPME := EF1->EF1_VL_MOE
            Else
               nSldPME := EX401EvSum(EV_PRINC,cAliasEF3,cKeyEF3,.T.)  //"100"
               nSldPRS := EX401EvSum(EV_PRINC,cAliasEF3,cKeyEF3,.F.)  //"100"
            EndIf
         EndIf
      Else
         nSldPME := EX401EvSum(EV_PRINC,cAliasEF3,cKeyEF3,.T.)  //"100"
         nSldPRS := EX401EvSum(EV_PRINC,cAliasEF3,cKeyEF3,.F.)  //"100"
      EndIf

      Do While (cAliasEF3)->( !EoF() )  .And.  Eval(bWhile)
         cCodEve  := (cAliasEF3)->EF3_CODEVE
         cLeftCod := Left(cCodEve,2)
         If !( Left(cCodEve,1) $ ("3___4") )  // Encargos

            Do Case

               // "700"
               Case cCodEve == EV_PRINC_PREPAG
                  If (cAliasEF3)->EF3_TX_MOE > 0
                     //If nSldPME == (cAliasEF3)->EF3_VL_MOE
                     //   nSldPRS := 0
                     //Else
                     nSldPRS -= (cAliasEF3)->EF3_VL_REA /*Round( ( (nSldPRS/nSldPME) * (cAliasEF3)->EF3_VL_MOE ), 2 )*/
                     //EndIf
                     nSldPME -= (cAliasEF3)->EF3_VL_MOE
                     nLiqPME += (cAliasEF3)->EF3_VL_MOE
                     nLiqPRS += (cAliasEF3)->EF3_VL_REA
                  EndIf

               // "710"
               Case cLeftCod == Left(EV_JUROS_PREPAG,2)
                  If (cAliasEF3)->EF3_TX_MOE > 0
                     nLiqJME += (cAliasEF3)->EF3_VL_MOE
                     nLiqJRS += (cAliasEF3)->EF3_VL_REA

                     //AAF - 18/07/2015 - Retira o valor de juros liquidado do saldo
                     nSldJME -= (cAliasEF3)->EF3_VL_MOE
                     nSldJRS -= (cAliasEF3)->EF3_VL_REA
                /*Else                                                                         //NCF - 26/06/2015
                     nSldJME += (cAliasEF3)->EF3_VL_MOE
                     nSldJRS += Round( ( (nSldPRS/nSldPME) * (cAliasEF3)->EF3_VL_MOE ), 2 )*/
                  EndIf

               // "520"                                                                        //NCF - 26/06/2015
               Case cLeftCod == Left(EV_PJ,2) .And. lAtuSldDtB
                  nSldJME += (cAliasEF3)->EF3_VL_MOE
                  nSldJRS += (cAliasEF3)->EF3_VL_REA

               // "510"
               Case cLeftCod == Left(EV_EST_PJ,2) .AND. lAtuSldDtB                             //AAF - 18/07/2015
                  nSldJME -= (cAliasEF3)->EF3_VL_MOE
                  nSldJRS -= (cAliasEF3)->EF3_VL_REA

               // "550"                                                                        //NCF - 26/06/2015
               Case cLeftCod == Left(EV_VC_PJ1,2) .And. lAtuSldDtB
                  nSldJME += (cAliasEF3)->EF3_VL_MOE
                  nSldJRS += (cAliasEF3)->EF3_VL_REA

               // "500"                                                                        //AAF - 18/07/2015
               Case (cCodEve == EV_VC_PRC .OR. cCodEve == EV_VC_PRC1) .AND. lAtuSldDtB
                  nSldPRS += (cAliasEF3)->EF3_VL_REA

            End Case

         EndIf
         (cAliasEF3)->( DBSkip() )
      EndDo

   Else

      Do While (cAliasEF3)->( !EoF() )  .And.  Eval(bWhile)

         cCodEve  := (cAliasEF3)->EF3_CODEVE
         cLeftCod := Left(cCodEve,2)

         If !( Left(cCodEve,1) $ ("3___4") )  // Encargos

            Do Case

             // **------------------------------------------ EVENTOS DO PRINCIPAL -------------------------------------**//

               // "100"
               Case cCodEve == EV_PRINC
			      If (cAliasEF3)->EF3_TP_EVE == ACE
				     nSl2PME += (cAliasEF3)->EF3_VL_MOE
					 nSl2PRS += (cAliasEF3)->EF3_VL_REA
				  Else
                     nSldPME += (cAliasEF3)->EF3_VL_MOE
                     nSldPRS += (cAliasEF3)->EF3_VL_REA
				  EndIf

               // "600"
               Case cCodEve == EV_EMBARQUE
                  If (cAliasEF3)->EF3_TP_EVE == ACC          //NCF - 30/03/2016
                     nSldPME -= (cAliasEF3)->EF3_VL_MOE
                     nSldPRS -= (cAliasEF3)->EF3_VL_REA
                     nSl2PME += (cAliasEF3)->EF3_VL_MOE
                     nSl2PRS += (cAliasEF3)->EF3_VL_REA
                  EndIf

               // "630"
               Case cCodEve == EV_LIQ_PRC
                  nSl2PME -= (cAliasEF3)->EF3_VL_MOE
                  nSl2PRS -= (cAliasEF3)->EF3_VL_REA
                  nLiqPME += (cAliasEF3)->EF3_VL_MOE
                  nLiqPRS += (cAliasEF3)->EF3_VL_REA

               // "660"
               Case cCodEve == EV_LIQ_PRC_FC
                  nSl2PME -= (cAliasEF3)->EF3_VL_MOE
                  nSl2PRS -= (cAliasEF3)->EF3_VL_REA
                  nLiqPME += (cAliasEF3)->EF3_VL_MOE
                  nLiqPRS += (cAliasEF3)->EF3_VL_REA

               // "500 ou 501"
               Case cCodEve $ (EV_VC_PRC+"___"+EV_VC_PRC1)
                  If (cAliasEF3)->EF3_TP_EVE == ACC
                     nSldPRS += (cAliasEF3)->EF3_VL_REA
                  ElseIf (cAliasEF3)->EF3_TP_EVE == ACE
                     nSl2PRS += (cAliasEF3)->EF3_VL_REA
                  EndIf

             // **------------------------------------------- EVENTOS DE JUROS  ---------------------------------------**//

               // "520"
               Case cLeftCod == Left(EV_PJ,2)
                  If (cAliasEF3)->EF3_TP_EVE == ACC
                     nSldJME += (cAliasEF3)->EF3_VL_MOE
                     nSldJRS += (cAliasEF3)->EF3_VL_REA
                  ElseIf (cAliasEF3)->EF3_TP_EVE == ACE
                     nSl2JME += (cAliasEF3)->EF3_VL_MOE
                     nSl2JRS += (cAliasEF3)->EF3_VL_REA
                  EndIf

               // "510"
               Case cLeftCod == Left(EV_EST_PJ,2)
                  If (cAliasEF3)->EF3_TP_EVE == ACC
                     nSldJME -= (cAliasEF3)->EF3_VL_MOE
                     nSldJRS -= (cAliasEF3)->EF3_VL_REA
                  ElseIf (cAliasEF3)->EF3_TP_EVE == ACE
                     nSl2JME -= (cAliasEF3)->EF3_VL_MOE
                     nSl2JRS -= (cAliasEF3)->EF3_VL_REA
                  EndIf

               // "650"
               Case cLeftCod == Left(EV_TJ,2) //cCodEve == EV_TJ - FSM - 13/12/2012
                  If (cAliasEF3)->EF3_TP_EVE <> ACE                                  //NCF - 30/03/2016
                     nSldJME -= (cAliasEF3)->EF3_VL_MOE
                     nSldJRS -= (cAliasEF3)->EF3_VL_REA
                  EndIf
                  nSl2JME += (cAliasEF3)->EF3_VL_MOE
                  nSl2JRS += (cAliasEF3)->EF3_VL_REA

               // "640"
               Case cLeftCod == Left(EV_LIQ_JUR,2)
                  If (cAliasEF3)->EF3_TX_MOE > 0
                     //ASK 23/10/2007 - Verifica o tipo do evento 01 - ACC / 02 - ACE para atualizar o saldo correto.
                     If (cAliasEF3)->EF3_TP_EVE == "01"
                        nSldJME -= (cAliasEF3)->EF3_VL_MOE
                        nSldJRS -= (cAliasEF3)->EF3_VL_REA
                     Else
                        nSl2JME -= (cAliasEF3)->EF3_VL_MOE
                        nSl2JRS -= (cAliasEF3)->EF3_VL_REA
                     EndIf
                     nLiqJME += (cAliasEF3)->EF3_VL_MOE
                     nLiqJRS += (cAliasEF3)->EF3_VL_REA
                  EndIf

               // "670"
               Case cLeftCod == Left(EV_LIQ_JUR_FC,2)
                  If (cAliasEF3)->EF3_TX_MOE > 0
                     //RMD - 29/12/14 - Verifica o tipo do evento 01 - ACC / 02 - ACE para atualizar o saldo correto.
                     If (cAliasEF3)->EF3_TP_EVE == "01"
                        nSldJME -= (cAliasEF3)->EF3_VL_MOE
                        nSldJRS -= (cAliasEF3)->EF3_VL_REA
                     Else
                        nSl2JME -= (cAliasEF3)->EF3_VL_MOE
                        nSl2JRS -= (cAliasEF3)->EF3_VL_REA
                     EndIf

                     /*
                     nSl2JME -= (cAliasEF3)->EF3_VL_MOE
                     nSl2JRS -= (cAliasEF3)->EF3_VL_REA
                     */

                     nLiqJME += (cAliasEF3)->EF3_VL_MOE
                     nLiqJRS += (cAliasEF3)->EF3_VL_REA
                  Endif
               // "550 - 569"
               Case Val(cCodeve) >= Val(EV_VC_PJ1)  .And.  Val(cCodeve) <= Val(EV_VC_PJ2)
                  If (cAliasEF3)->EF3_TP_EVE == ACC
                     nSldJRS += (cAliasEF3)->EF3_VL_REA
                  ElseIf (cAliasEF3)->EF3_TP_EVE == ACE
                     nSl2JRS += (cAliasEF3)->EF3_VL_REA
                  EndIf

             // **-------------------------------------- EVENTOS DE JUROS ANTECIPADOS ---------------------------------**//

               // "680"
               Case cLeftCod == Left(EV_JR_ANT,2)
                  nSl2JME -= (cAliasEF3)->EF3_VL_MOE
                  nSl2JRS -= (cAliasEF3)->EF3_VL_REA
                  nLiqJME += (cAliasEF3)->EF3_VL_MOE
                  nLiqJRS += (cAliasEF3)->EF3_VL_REA

               // "050 - 069"
               Case Val(cCodeve) >= Val(EV_VC_JA1)  .And.  Val(cCodeve) <= Val(EV_VC_JA2)
                  nSldJRS += (cAliasEF3)->EF3_VL_REA
                  nSl2JRS += (cAliasEF3)->EF3_VL_REA

             // **---------------------------- EVENTOS DE ENCERRAMENTO / TRANSFERENCIA --------------------------------**//

               // "180"
               Case cCodEve == EV_ENC_PRC
                  If (cAliasEF3)->EF3_TP_EVE == ACE
				     nSl2PME -= (cAliasEF3)->EF3_VL_MOE
					 nSl2PRS -= (cAliasEF3)->EF3_VL_REA
				  Else
				     nSldPME -= (cAliasEF3)->EF3_VL_MOE
                     nSldPRS -= (cAliasEF3)->EF3_VL_REA
				  EndIf
                  nLiqPME += (cAliasEF3)->EF3_VL_MOE
                  nLiqPRS += (cAliasEF3)->EF3_VL_REA

               // "190"
               Case cCodEve == EV_TRANS_PRC
			   	  If (cAliasEF3)->EF3_TP_EVE == ACE
				     nSl2PME -= (cAliasEF3)->EF3_VL_MOE
					 nSl2PRS -= (cAliasEF3)->EF3_VL_REA
				  Else
                     nSldPME -= (cAliasEF3)->EF3_VL_MOE
                     nSldPRS -= (cAliasEF3)->EF3_VL_REA
				  EndIf

            End Case

         EndIf
         (cAliasEF3)->( DBSkip() )
      EndDo
   EndIf

   aSaldos := { nSldPME, nSldPRS, nSldJME, nSldJRS, nSl2PME, nSl2PRS, nSl2JME, nSl2JRS, nLiqPME, nLiqPRS, nLiqJME, nLiqJRS }

   If lAtualiza //ASK 23/10/2007 - Atualiza os campos de Saldo
      M->EF1_SLD_PM := aSaldos[01]
      M->EF1_SLD_PR := aSaldos[02]
      M->EF1_SLD_JM := aSaldos[03]
      M->EF1_SLD_JR := aSaldos[04]
      M->EF1_SL2_PM := aSaldos[05]
      M->EF1_SL2_PR := aSaldos[06]
      M->EF1_SL2_JM := aSaldos[07]
      M->EF1_SL2_JR := aSaldos[08]
      M->EF1_LIQPRM := aSaldos[09]
      M->EF1_LIQPRR := aSaldos[10]
      M->EF1_LIQJRM := aSaldos[11]
      M->EF1_LIQJRR := aSaldos[12]
   EndIf

   RestOrd(aOrd,.T.)

Return aSaldos

/*
Função      : EX401IsCtb
Objetivo    : Verificar se um Contrato de Financiamento está Contabilizado
Parametros  : cContrato - Numero do Contrato de Financiamento
              cBanco    - Banco do Contrato
              cPraca    - Praca do Contrato
              cSeqCnt   - Sequencia do Contrato
Retorno     : lIsContab - Resposta relativa ao Objetivo da Função
Autor       : Pedro Baroni
Data e Hora : 13/06/2007
Observação  : Esta Função verifica apenas Contratos Financiamento de Exportação
*/
*----------------------------------------------------------------------------------*
Function EX401IsCtb(cContrato,cBanco,cPraca,cSeqCnt)
*----------------------------------------------------------------------------------*
 Local aOrd        := {}  ,;
       cKeyECF     := ""  ,;
       cFilECF     := ""  ,;
       lIsContab   := .F. ,;
       lECF_SeqCnt := .F. ,;
       lECF_Banco  := .F.

   cContrato := IIF(Empty(cContrato),"",cContrato)
   cBanco    := IIF(Empty(cBanco)   ,"",cBanco)
   cPraca    := IIF(Empty(cPraca)   ,"",cPraca)
   cSeqCnt   := IIF(Empty(cSeqCnt)  ,"",cSeqCnt)

   lECF_SeqCnt := ECF->( FieldPos("ECF_SEQCNT") > 0 )
   lECF_Banco  := ECF->( FieldPos("ECF_BANCO")  > 0  .And.  FieldPos("ECF_PRACA") > 0 )

   cFilECF := xFilial("ECF")
   aOrd    := SaveOrd({"ECF"})

   ECF->( DBSetOrder(8) )

   cKeyECF := cFilECF
   cKeyECF += AvKey("EXPORT","ECF_TPMODU")
   cKeyECF += AvKey(cContrato,"ECF_CONTRA")
   cKeyECF += IIF(lECF_Banco,AvKey(cBanco,"ECF_BANCO"),"")
   cKeyECF += IIF(lECF_Banco,AvKey(cPraca,"ECF_PRACA"),"")
   cKeyECF += IIF(lECF_SeqCnt,AvKey(cSeqCnt,"ECF_SEQCNT"),"")

   lIsContab := ECF->( DBSeek(cKeyECF) )

   RestOrd(aOrd,.T.)


Return lIsContab

/*
Função      : EX401ProvTot
Objetivo    : Calcular Juros na moeda de um período para contratos Pré-Pagamento.
Parametros  : cAliasEF1 - Alias da Tabela de Contratos
              cTpModu   - Tipo de Modulo do Contrato
              cContrato - Numero do Contrato de Financiamento
              cBanco    - Banco do Contrato
              cPraca    - Praca do Contrato
              cSeqCon   - Sequencia do Contrato
              cAliasEF3 - Alias da Tabela de Eventos do Contrato
Autor       : Alessandro Alves Ferreira
Data e Hora : 08/04/2008
Observação  : Pressupõe posicionado o EF1 no Contrato desejado.
*/
******************************************************************
Function EX401ProvTot(cAliasEF1, cAliasEF3,dDtFim, dDtIni, cTpJur)
******************************************************************
Local nValProv := 0
Local nRecEF3:=(cAliasEF3)->(RecNo()), nOrdEF3:=(cAliasEF3)->(IndexOrd())
Local ni, nz
Local cContrato, cBanco, cPraca, cSeqCon, cTpModu, aParcelas, aPeriodos, nValLiq,;
      dDtIniPer, dDtFimPer, aJuros, nValor, nTxJur, nDias, nPrinc, nValJuros, nVl700Liq
Default cTpJur := "0"

EX401Var("lEFFTpMod",.T.)  //GFP - 15/03/2012 - Alterado Flag lPrivate para .T.

If ValType(dDtIni) <> "D"
   dDtIni := If(cAliasEF1=="M",M->EF1_DT_JUR,EF1->EF1_DT_JUR)
EndIf

If cAliasEF3 == "EF3"
   cContrato := EF1->EF1_CONTRA
   cBanco    := EF1->EF1_BAN_FI
   cPraca    := EF1->EF1_PRACA
   cSeqCon   := EF1->EF1_SEQCNT
   cTpModu   := EF1->EF1_TPMODU

   (cAliasEF3)->(dbSetOrder(1))
   (cAliasEF3)->(dbSeek(xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,"")))
   cAliasEF1 := "EF1"
   cAliasEF2 := "EF2"
Else
   cContrato := M->EF1_CONTRA
   cBanco    := M->EF1_BAN_FI
   cPraca    := M->EF1_PRACA
   cSeqCon   := M->EF1_SEQCNT
   cTpModu   := M->EF1_TPMODU

   (cAliasEF3)->(dbGoTop())
   cAliasEF1 := "M"

EndIf

aParcelas := {}
nVl700Liq := 0
Do While !(cAliasEF3)->(EOF()) .and.;
If(cAliasEF3=="EF3",(cAliasEF3)->(EF3_FILIAL+If(lEFFTpMod,EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+If(lEFFTpMod,EF3_SEQCNT,""))==xFilial("EF3")+If(lEFFTpMod,cTpModu,"")+cContrato+cBanco+cPraca+If(lEFFTpMod,cSeqCon,""),.T.)
   If (cAliasEF3)->EF3_DT_EVE < dDtIni .AND. (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG
      nVl700Liq += (cAliasEF3)->EF3_VL_MOE
   ElseIf (cAliasEF3)->EF3_DT_EVE <= dDtFim
      If (cAliasEF3)->EF3_CODEVE == EV_PRINC_PREPAG
         aAdd(aParcelas,{"1",EV_PRINC_PREPAG,(cAliasEF3)->EF3_DT_EVE, (cAliasEF3)->EF3_VL_MOE})
      EndIf
   EndIf
   (cAliasEF3)->(dbSkip())
EndDo

aAdd(aParcelas,{"1","100",dDtIni,nVl700Liq}) //Inicio do periodo calculado de juros

//Ordena as parcelas por Data + Tipo(1-principal ou 2-juros)
aSort(aParcelas,,, {|x, y| dtos(x[3])+x[1] < dtos(y[3])+y[1] })

aPeriodos := {}
For ni:= 1 To Len(aParcelas)
   nValLiq:=0

   For nz:=1 To ni
      If aParcelas[nz,3] < dDtFim
         nValLiq += aParcelas[nz,4]
      EndIf
   Next nz

   dDtIniPer := aParcelas[ni,3]
   dDtFimPer := If(ni == Len(aParcelas),dDtFim, Min(dDtFim,aParcelas[ni+1,3]))

   aJuros := EX400BusTx(If(cAliasEF1=="M",M->EF1_TP_FIN,EF1->EF1_TP_FIN),dDtFimPer,dDtIniPer,cAliasEF1,cAliasEF2,cTpJur)
   nValor := If(cAliasEF1=="M",M->EF1_VL_MOE,EF1->EF1_VL_MOE) - nValLiq

   aAdd(aPeriodos,{nValor, aJuros})
Next

nValJuros := 0
For ni:=1 to Len(aPeriodos)
    For nz:=1 to Len(aPeriodos[ni][2])
       nTxJur:= aPeriodos[ni][2][nz,1] / 100
       nDias := If(If(cAliasEF1=="M",M->EF1_PERFIX,EF1->EF1_PERFIX)<>0 .and. If(cAliasEF1=="M",M->EF1_TPPEJR,EF1->EF1_TPPEJR)=="2",If(cAliasEF1=="M",M->EF1_PERFIX,EF1->EF1_PERFIX),aPeriodos[ni][2][nz,2])
       nPrinc:= aPeriodos[ni][1]

       nValJuros += Round(nDias * nTxJur * nPrinc,2)
    Next nz
Next ni

(cAliasEF3)->(dbSetOrder(nOrdEF3))
(cAliasEF3)->(dbGoTo(nRecEF3))

Return nValJuros

***********************
Function EX401Var(cVar,lPrivate)
***********************
Local uValue, aCpo, i

If ValType(lPrivate) <> "L"
   lPrivate := .F.
EndIf

If Type(cVar) == "U"

   cVar := UPPER(cVar)

   Do Case
      Case cVar == "LEFFTPMOD"
         aCpo := {"EF1_TPMODU","EF1_SEQCNT","EF2_TPMODU","EF2_SEQCNT","EF3_TPMODU","EF3_SEQCNT","EF4_TPMODU","EF4_SEQCNT","EF6_SEQCNT","EF3_ORIGEM","EF3_ROF",;
                  "EF1_CAMTRA","EF1_IMPORT","EF1_LOJAIM","EF1_LINCRE","EF1_ROF","EF1_FORN","EF1_LOJAFO","EF3_FORN","EF3_LOJAFO","EF3_HAWB","EF3_PO_DI","EF3_INVIMP",;
                  "EF3_LINHA"}

         uValue := .T.

         SX3->(dbSetOrder(2))

         For i := 1 To Len(aCpo)
            uValue := uValue .AND. SX3->(dbSeek(aCpo[i])) .AND. (SX3->X3_ARQUIVO)->(FieldPos(aCpo[i])) > 0
         Next i

   End Case

   If lPrivate
      _SetOwnerPrvt(cVar,uValue)
   End If

EndIf

Return uValue


/*
Função  : EX401ParcAjusta
Autor   : Felipe S. Martinez - FSM
Data	: 28/03/12
Objetivo: Adicionar a data alterado do evento principal.
*/
Static Function EX401ParcAjusta(aParcelas, lPerido, cAliasEF3)
Local aOrd := SaveOrd({cAliasEF3})

If Type("nDiferenca") == "N" .And. Type("nRWEF3") == "N" .And. lPerido

   (cAliasEF3)->( DBGoTO(nRWEF3))
   (cAliasEF3)->( DbSkip() )
   Do While !(cAliasEF3)->(EOF())

      If Left((cAliasEF3)->EF3_CODEVE,1) $ "3/4/7"
         aAdd(aParcelas,{"1",EV_PRINC_PREPAG,(cAliasEF3)->EF3_DT_EVE+=nDiferenca,(cAliasEF3)->EF3_VL_MOE,(cAliasEF3)->EF3_VL_MOE,.T.,(cAliasEF3)->(RecNo())})
      EndIf

      (cAliasEF3)->(dbSkip())
   EndDo

EndIf

RestOrd(aOrd)

Return aParcelas

/*
Função  : EX401IsAdiant
Autor   : Felipe S. Martinez - FSM
Data	: 05/10/12
Objetivo: Verificar se o cambio é do tipo Adiantamento
*/
Function EX401IsAdiant(cInvo, cPreemb, cParc)
Local lRet := .F.
Local aOrd := SaveOrd({"EEQ"})
Default cInvo := ""
Default cPreemb := ""
Default cParc := ""

EEQ->(DBSetOrder(4)) //FILIAL + INVOICE + PREEMB + PARC
If EEQ->(DBSeek(xFilial("EEQ")+cInvo+cPreemb+cParc))
	lRet:=UPPER(AllTrim(EEQ->EEQ_TIPO))=="A"
EndIf

RestOrd(aOrd,.T.)  // GFP - 08/02/2013 - Incluido segundo parametro.
Return lRet

//RMD - 25/09/14 - Imprime o relatório de Contratos, a partir do programa EFFRELCONT.APH
Function EX401RelCont()
Local cDir := "\Comex\"
Local cFile:= "EFFRELCONT.xrp"

Begin Sequence

   If !lIsDir(cDir) .And. !(MakeDir(cDir) == 0)
      MsgInfo(StrTran(STR0188, "###", cDir),STR0117)//"Erro ao criar o diretório temporário '###'. Não será possível executar o relatório." ### "Aviso"
      lRet := .F.
      Break
   EndIf

   If File(cDir+cFile)
      FErase(cDir+cFile)
   EndIf

   If !MemoWrite(cDir+cFile, EasyExecAHU("EFFRELCONT") )
      MsgInfo(STR0189,STR0117)// "Erro na Abertura do arquivo." ### "Aviso"
      Break
   EndIf

   LoadReport(cDir+cFile)
   FErase(cDir+cFile)

End Sequence

Return .T.



*---------------------------------------------------------------------------------------------------*
Function EX401BxEnc(lEnc)
*---------------------------------------------------------------------------------------------------*
Local oPanel, nSelecao:=0
Local cInvoic:=WorkEF3->EF3_INVOIC, cParc:=WorkEF3->EF3_PARC, cPreemb:=WorkEF3->EF3_PREEMB
Local nVl:=WorkEF3->EF3_VL_MOE, cMoeInv:=WorkEF3->EF3_MOE_IN
Local nDecValor := AVSX3("EF3_VL_MOE",4)
Private nTaxa:=0, dDtCe:=AVCtoD("  /  /  "), dDtNe:=AVCtoD("  /  /  ")
Private dDtPgt:=AVCtoD("  /  /  "), cNrOp:=WorkEF3->EF3_NROP
If lEFFTpMod
   Private dDtCnt     := WorkEF3->EF3_DT_CNT        ,;
           cBcMov     := EF1->EF1_BAN_MO            ,;
           cDescBCMov := Posicione( 'SA6', 1, xfilial('SA6')+EF1->EF1_BAN_MO+EF1->EF1_AGENMO+EF1->EF1_NCONMO, 'A6_NREDUZ') ,;
           cAgMov     := EF1->EF1_AGENMO            ,;
           cCcMov     := EF1->EF1_NCONMO            ,;
           dDtDes     := WorkEF3->EF3_DT_DES
EndIf
Private nVlMoe:=WorkEF3->EF3_VL_MOE, nVlRea:=WorkEF3->EF3_VL_REA

If lTemChave
   Private cBanco:= EF1->EF1_BAN_FI, cAgencia:= EF1->EF1_AGENFI
   Private cConta:= EF1->EF1_NCONFI, cDescBanco:=Posicione( 'SA6', 1, xfilial('SA6')+EF1->EF1_BAN_FI+EF1->EF1_AGENFI+EF1->EF1_NCONFI, 'A6_NREDUZ')
//   Private cPraca:=Space(Len(EF3->EF3_PRACA)), cDescPraca:=Space(Len(EF5->EF5_DESCRI))
EndIf
Private LnFinal:=23, cLin:=35, oDlg //LnFinal:=21 - FSM - 10/04/2012
Private cGetCust1:="", cGetCust2:="", cGetCust3:="", cGetCust4:="", cGetCust5:=""
Private dGetCust1
Private lEncargo := lEnc := .T.

If lEncargo = NIL
   lEncargo := .F.
ElseIf lEncargo
   LnFinal := 35
EndIf

DEFINE MSDIALOG oDlg TITLE "Baixa do Principal de Encerramento" ;
FROM 12,05 TO LnFinal,75 OF oMainWnd //PIXEL

   If lTemChave
      @cLin,5 SAY AVSX3("EF3_BANC",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,50 MSGET cBanco PICTURE AVSX3("EF3_BANC",6) F3 "BC6" Valid (BxFrcValid("BANCO")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_AGEN",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET cAgencia PICTURE AVSX3("EF3_AGEN",6) Valid (BxFrcValid("AGENCIA")) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_NCON",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET cConta PICTURE AVSX3("EF3_NCON",6) Valid (BxFrcValid("CONTA")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("A6_NREDUZ",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET cDescBanco PICTURE AVSX3("A6_NREDUZ",6) Valid (BxFrcValid("DESC_BANCO")) SIZE 65,08 PIXEL of oDlg
      cLin += 11
   EndIf

   If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"TELA_BAIXA_VINCULAÇÃO2"),)

   If lEncargo
      @cLin,5 SAY AVSX3("EF3_NROP",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET cNrOp PICTURE AVSX3("EF3_NROP",6) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_DT_CNT",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET dDtCnt PICTURE AVSX3("EF3_DT_CNT",6) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_DT_DES",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET dDtDes PICTURE AVSX3("EF3_DT_DES",6) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      If(EasyEntryPoint("EFFEX401"),ExecBlock("EFFEX401",.F.,.F.,"TELA_BAIXA_VINCULAÇÃO3"),)

      @cLin,5 SAY AVSX3("WB_CA_DT",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,50 MSGET dDtPgt PICTURE AVSX3("EEQ_DTCE",6) Valid (BxFrcValid("DT_PGT")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_TX_MOE",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,198 MSGET nTaxa PICTURE AVSX3("EF3_TX_MOE",6) F3 "E18" Valid (BxFrcValid("TAXA")) SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_VL_MOE",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET nVlMoe PICTURE AVSX3("EF3_VL_MOE",6) When .F. SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_VL_REA",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET nVlRea PICTURE AVSX3("EF3_VL_REA",6) When .F. SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_BC_MOV",5) SIZE 40,8 PIXEL COLOR CLR_HBLUE of oDlg
      @cLin,50 MSGET cBcMov PICTURE AVSX3("EF3_BC_MOV",6) F3 "BC6" Valid (BxFrcValid("BC_MOV")) SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY AVSX3("EF3_AG_MOV",5) SIZE 40,8 PIXEL of oDlg
      @cLin,198 MSGET cAgMov PICTURE AVSX3("EF3_AG_MOV",6) When .F. SIZE 65,08 PIXEL of oDlg
      cLin += 11

      @cLin,5 SAY AVSX3("EF3_CC_MOV",5) SIZE 40,8 PIXEL of oDlg
      @cLin,50 MSGET cCcMov PICTURE AVSX3("EF3_CC_MOV",6) When .F. SIZE 65,08 PIXEL of oDlg

      @cLin,150 SAY STR0083 SIZE 40,8 PIXEL of oDlg  //"Descr Banco"
      @cLin,198 MSGET cDescBcMov When .F. SIZE 65,08 PIXEL of oDlg
      cLin += 11
   EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(BxFrcValid("GRAVA") ,Eval({||nSelecao:=1,oDlg:End()}),)},{||nSelecao:=0,oDlg:End()}) CENTERED

If nSelecao = 1

      WorkEF3->EF3_DT_EVE := dDtPgt
      WorkEF3->EF3_TX_MOE := nTaxa
      WorkEF3->EF3_VL_REA := Round(WorkEF3->EF3_VL_MOE * nTaxa, nDecValor)
      WorkEF3->EF3_BANC   := cBanco
      WorkEF3->EF3_AGEN   := cAgencia
      WorkEF3->EF3_NCON   := cConta

      WorkEF3->EF3_NROP   := cNrOp
      WorkEF3->EF3_DT_CNT := dDtCnt
      WorkEF3->EF3_BC_MOV := cBcMov
      WorkEF3->EF3_AG_MOV := cAgMov
      WorkEF3->EF3_CC_MOV := cCcMov

      If WorkEF3->(FieldPos("EF3_DTOREV")) > 0
         WorkEF3->EF3_DTOREV := WorkEF3->EF3_DT_EVE
      EndIf

      // MPG - 25/10/2018 - caso altere a parcela confirma alteração, só podendo ser desfeita após salvar o processo e abrir novamente
      if WorkEF3->( fieldpos("ALTERADO") ) > 0
            WorkEF3->ALTERADO := .T.
      endif

EndIf

WorkEF3->(dbSetOrder(ORDEM_BROWSE))

Return .T.

//AAF 27/01/2015 - Encerramento da provisão total de juros (620).
Function EX401EncJr(lManut,dDtEnc,cSeqEve,lEstorno)
Local aTpJur := {}, nPosJur, aPosEF2
Local i, nSal620, nSal620R
Local aEventosEF3 := {}
Local lRet := .T.
Default lManut := .T.

If !lManut
   aPosEF2 := EF2->({IndexOrd(),RecNo()})
   aPosEF3 := EF3->({IndexOrd(),RecNo()})

   EF2->(dbSetOrder(2))
   EF2->(dbSeek(xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT) ))
   Do While !EF2->(EoF()) .AND. EF2->(EF2_FILIAL+EF2_TPMODU+EF2_CONTRA+EF2_BAN_FI+EF2_PRACA+EF2_SEQCNT) == xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)
      If (nPosJur := aScan(aTpJur,{|X| X == EF2->EF2_TIPJUR})) == 0
         aAdd(aTpJur,EF2->EF2_TIPJUR)
      EndIf
      EF2->(dbSkip())
   EndDo

   For i := 1 To Len(aTpJur)
      EF3->(dbSetOrder(1))//EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE
      cSeekEF3 := xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)+"62"+AllTrim(Str(Val(aTpJur[i])))
	  If EF3->(dbSeek(cSeekEF3))
	     nSal620  := 0
		 nSal620R := 0

         nSal620  := EX401EvSum("62"+aTpJur[i],"EF3",xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.T.,)
		 nSal620R := EX401EvSum("62"+aTpJur[i],"EF3",xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.F.,)
         nSal620R += EX401EvSum(AllTrim(Str(580+Val(aTpJur[i])*2)),"EF3",xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.F.,)
	     nSal620R += EX401EvSum(AllTrim(Str(581+Val(aTpJur[i])*2)),"EF3",xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.F.,)

         nSal620  -= EX401EvSum("64"+aTpJur[i],"EF3",xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.T.,{|| EF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0)})
		 nSal620R -= EX401EvSum("64"+aTpJur[i],"EF3",xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.F.,{|| EF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0)})

         nSal620  -= EX401EvSum("92"+aTpJur[i],"EF3",xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.T.,)
		 nSal620R -= EX401EvSum("92"+aTpJur[i],"EF3",xFilial("EF1")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.F.,)

		 If nSal620 > 0
		    cTpTx      := Posicione("EC6",1,xFilial("EC6")+"FI"+if(EF1->EF1_TPMODU=="I","IM","EX")+EF1->EF1_TP_FIN+"92"+aTpJur[i],"EC6_TXCV")
		    nTx        := BuscaTaxa(EF1->EF1_MOEDA,dDtEnc,,.F.,.T.,,cTpTx)

			nVl920Rs   := Round(nSal620*nTx,AvSX3("EF3_VL_MOE",AV_DECIMAL))

		    aAdd(aEventosEF3,{"92"+aTpJur[i],nSal620,nTx,nVl920Rs,dDtEnc,cSeqEve,EF1->EF1_MOEDA})

			If nVl920Rs - nSal620R <> 0
			   aAdd(aEventosEF3,{AllTrim(Str(580+Val(aTpJur[i])*2)),0,nTx,nVl920Rs - nSal620R,dDtEnc,cSeqEve,EF1->EF1_MOEDA})
			EndIf

   	     EndIf
	  EndIf
   Next i

   For i := 1 To Len(aEventosEF3)
      RecLock("EF3",.T.)

	  EF3->EF3_FILIAL := xFilial("EF3")
      EF3->EF3_CONTRA := EF1->EF1_CONTRA
      EF3->EF3_TPMODU := EF1->EF1_TPMODU
      EF3->EF3_TP_EVE := EF1->EF1_TP_FIN
      EF3->EF3_CODEVE := aEventosEF3[i][1]
      EF3->EF3_BAN_FI := EF1->EF1_BAN_FI
      EF3->EF3_AGENFI := EF1->EF1_AGENFI
      EF3->EF3_NCONFI := EF1->EF1_NCONFI
      EF3->EF3_PRACA  := EF1->EF1_PRACA
      EF3->EF3_SEQCNT := EF1->EF1_SEQCNT
      EF3->EF3_ROF    := EF1->EF1_ROF
      EF3->EF3_VL_MOE := aEventosEF3[i][2]
      EF3->EF3_TX_MOE := aEventosEF3[i][3]
      EF3->EF3_VL_REA := aEventosEF3[i][4]
      EF3->EF3_DT_EVE := aEventosEF3[i][5]
      EF3->EF3_SEQ    := aEventosEF3[i][6]
      EF3->EF3_MOE_IN := aEventosEF3[i][7]

	  EF3->(MsUnLock())
   Next i

   EF2->(dbSetOrder(aPosEF2[1]),dbGoTo(aPosEF2[2]))
   EF3->(dbSetOrder(aPosEF3[1]),dbGoTo(aPosEF3[2]))
Else
   aPosEF2:= WorkEF2->({IndexOrd(),RecNo()})
   aPosEF3:= WorkEF3->({IndexOrd(),RecNo()})

   WorkEF2->(dbGoTop())
   Do While WorkEF2->(!EoF())

	  If (nPosJur := aScan(aTpJur,{|X| X == WorkEF2->EF2_TIPJUR})) == 0
         aAdd(aTpJur,WorkEF2->EF2_TIPJUR)
      EndIf

      WorkEF2->(dbSkip())
   EndDo

   For i := 1 To Len(aTpJur)
      WorkEF3->(dbSetOrder(5))//EF3_CODEVE
      If !lEstorno
	     cSeekEF3 := "62"+AllTrim(Str(Val(aTpJur[i])))
	     If WorkEF3->(dbSeek(cSeekEF3))
	        nSal620  := 0
		    nSal620R := 0

            nSal620  := EX401EvSum("62"+aTpJur[i],"WorkEF3",,.T.,)
		    nSal620R := EX401EvSum("62"+aTpJur[i],"WorkEF3",,.F.,)
            nSal620R += EX401EvSum(AllTrim(Str(580+Val(aTpJur[i])*2)),"WorkEF3",,.F.,)
	        nSal620R += EX401EvSum(AllTrim(Str(581+Val(aTpJur[i])*2)),"WorkEF3",,.F.,)

            nSal620  -= EX401EvSum("64"+aTpJur[i],"WorkEF3",,.T.,{|| WorkEF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0)})
		    nSal620R -= EX401EvSum("64"+aTpJur[i],"WorkEF3",,.F.,{|| WorkEF3->(!Empty(EF3_DT_EVE) .AND. EF3_VL_REA > 0)})

			nSal620  -= EX401EvSum("92"+aTpJur[i],"WorkEF3",,.T.,)
		    nSal620R -= EX401EvSum("92"+aTpJur[i],"WorkEF3",,.F.,)

		    If nSal620 > 0
		       cTpTx      := Posicione("EC6",1,xFilial("EC6")+"FI"+if(M->EF1_TPMODU=="I","IM","EX")+M->EF1_TP_FIN+"92"+aTpJur[i],"EC6_TXCV")
		       nTx        := BuscaTaxa(M->EF1_MOEDA,dDtEnc,,.F.,.T.,,cTpTx)

			   nVl920Rs   := Round(nSal620*nTx,AvSX3("EF3_VL_MOE",AV_DECIMAL))

		       aAdd(aEventosEF3,{"92"+aTpJur[i],nSal620,nTx,nVl920Rs,dDtEnc,cSeqEve,M->EF1_MOEDA})

			   If nVl920Rs - nSal620R <> 0
			      aAdd(aEventosEF3,{AllTrim(Str(580+Val(aTpJur[i])*2)),0,nTx,nVl920Rs - nSal620R,dDtEnc,cSeqEve,M->EF1_MOEDA})
			   EndIf

   	        EndIf
	     EndIf
	  Else
	     cSeekEF3 := "92"+AllTrim(Str(Val(aTpJur[i])))
	     If WorkEF3->(dbSeek(cSeekEF3))
		    EX400EstEV(WorkEF3->EF3_SEQ,"CTB",.F.)
		 EndIf
      EndIf
   Next i

   For i := 1 To Len(aEventosEF3)
      RecLock("WorkEF3",.T.)

      WorkEF3->EF3_FILIAL := xFilial("EF3")
      WorkEF3->EF3_CONTRA := M->EF1_CONTRA
      WorkEF3->EF3_TPMODU := M->EF1_TPMODU
      WorkEF3->EF3_BAN_FI := M->EF1_BAN_FI
      WorkEF3->EF3_AGENFI := M->EF1_AGENFI
      WorkEF3->EF3_NCONFI := M->EF1_NCONFI
      WorkEF3->EF3_PRACA  := M->EF1_PRACA
      WorkEF3->EF3_SEQCNT := M->EF1_SEQCNT
      WorkEF3->EF3_TP_EVE := M->EF1_TP_FIN
      WorkEF3->EF3_CODEVE := aEventosEF3[i][1]
      WorkEF3->EF3_VL_MOE := aEventosEF3[i][2]
      WorkEF3->EF3_TX_MOE := aEventosEF3[i][3]
      WorkEF3->EF3_VL_REA := aEventosEF3[i][4]
      WorkEF3->EF3_DT_EVE := aEventosEF3[i][5]
      WorkEF3->EF3_SEQ    := aEventosEF3[i][6]
      WorkEF3->EF3_MOE_IN := aEventosEF3[i][7]
      WorkEF3->EF3_DESCEV := BuscaDescEv("M", "WorkEF3", WorkEF3->EF3_CODEVE)
	  WorkEF3->(MsUnLock())
   Next i

   WorkEF2->(dbGoTo(aPosEF2[2]))
   WorkEF3->(dbSetOrder(aPosEF3[1]))
   WorkEF3->(dbGoTop())

   oMark:oBrowse:Refresh()
EndIf

Return lRet

*-------------------------*
Function EX401Refinim()
*-------------------------*
Local oDlg
Local aAlt := {"EF2_CONTRA", "DT_VINC", "TX_VINC"}
Local nLin := 20
Local nCol := 45
Local nOpc := 4, nOp := 0
Local nNOld, aHdOld, aClOld
Local nREcAtu

If Type("aHeader") == "A"
   aHdOld := aClone(aHeader)
EndIf
If Type("aCols") == "A"
   aClOld := aClone(aCols)
EndIf
If Type("N") == "N"
   nNOld := N
EndIf

Private aHeader := {}

Begin Sequence

   If !Empty(WorkEF3->EF3_TX_MOE)
      Help(" ",1,"EFF0000001")  //"Evento encontra-se liquidado e não é possível efetuar a vinculação solicitada." ## "Necessário estornar a liquidação do evento."
      Break
   EndIf

   WKREFINIMP->(DbSetOrder(2))  //"EF3_TPMOOR+EF3_CONTOR+EF3_BAN_OR+EF3_PRACOR+EF3_SQCNOR+EF3_CDEVOR+EF3_PARCOR+EF3_IVIMOR+EF3_LINOR"
   If !WKREFINIMP->(DbSeek(M->EF1_TPMODU+M->EF1_CONTRA+M->EF1_BAN_FI+M->EF1_PRACA+M->EF1_SEQCNT+WorkEF3->(EF3_CODEVE+EF3_PARC+EF3_INVIMP+EF3_LINHA)))
      WKREFINIMP->(reclock("WKREFINIMP",.T.))

      WKREFINIMP->EF3_TPMOOR := M->EF1_TPMODU
      WKREFINIMP->EF3_CONTOR := M->EF1_CONTRA
      WKREFINIMP->EF3_BAN_OR := M->EF1_BAN_FI
      WKREFINIMP->EF3_PRACOR := M->EF1_PRACA
      WKREFINIMP->EF3_SQCNOR := M->EF1_SEQCNT
      WKREFINIMP->EF3_CDEVOR := WorkEF3->EF3_CODEVE
      WKREFINIMP->EF3_PARCOR := WorkEF3->EF3_PARC
      WKREFINIMP->EF3_IVIMOR := WorkEF3->EF3_INVIMP
      WKREFINIMP->EF3_LINOR  := WorkEF3->EF3_LINHA
      WKREFINIMP->(msUnLock())
   EndIf

   SetHeader()

   nOpc := FiltraRef()

   DEFINE MSDIALOG oDlg TITLE STR0196 FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL  //"Vinculação de Financiamento"
      oPanel1:= TPanel():New(30, 0, "", oDlg,, .F., .F.,,, 90, 165)
      oPanel1:Align:= CONTROL_ALIGN_ALLCLIENT
      nLin :=(oPanel1:nClientHeight-49)/2
                                 //New(nTop,nLeft,nBottom,nRight,nOpc,cLinhaOk,cTudoOk,cIniCpos,lDelete,aAlter                                   ,nFreeze,lEmpty,uPar1,cTRB        ,cFieldOk,uPar2,lAppend,oWnd   ,lDisparos,uPar3,cDelOk,cSuperDel)
      oGet:=MsGetDb():New(32,1,nLin,(oPanel1:nClientWidth-4)/2  ,nOpc,        ,       ,        ,.T.    ,If(Empty(WKREFINIMP->EF2_CONTRA),aAlt,{}),       ,.F.   ,     ,"WKREFINIMP",        ,     ,.F.    ,oPanel1,   .T.   ,     ,  )

      //oGet:lCondicional := .T. // MPG - OSSME-3275
      oGet:oBROWSE:Badd := iif( nOpc == 4, {||.F.} , {||.T.} )
      oGet:oBrowse:bwhen:={|| (.T.)}
      oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oGet:ForceRefresh(.T.)
      oGet:oBrowse:Refresh(.T.)

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOp := 1, oDlg:End()},{|| nOp := 0,oDlg:End()})

   WKREFINIMP->(dbClearFilter())
   If nOp == 1
      GrvWkRefin("GRAVAR")
   Else
      GrvWkRefin("EXCLUIR")
   EndIf

End Sequence

If ValType(aHdOld) == "A"
   aHeader := aClone(aHdOld)
EndIf
If ValType(aClOld) == "A"
   aCols := aClone(aClOld)
EndIf
If ValType(nNOld) == "N"
   N := nNOld
EndIf

Return NIL

*---------------------------------------*
Static Function GrvWkRefin(cOp)
*---------------------------------------*
Local aOrd := SaveOrd("SF2")

Begin Sequence

   If cOp == "GRAVAR"
      If WKREFINIMP->DBDELETE
         WorkEF3->EF3_NROP   := ""
         WorkEF3->ALTERADO := .T.
      ElseIf !Empty(WKREFINIMP->EF2_CONTRA)
         WorkEF3->(Reclock("WorkEF3",.F.))
         WorkEF3->EF3_NROP := WKREFINIMP->EF2_CONTRA
         WorkEF3->ALTERADO := .T.
         WorkEF3->(msunlock())

         WKREFINIMP->(Reclock("WKREFINIMP",.F.))
         WKREFINIMP->EF3_TPMOOR := M->EF1_TPMODU
         WKREFINIMP->EF3_CONTOR := M->EF1_CONTRA
         WKREFINIMP->EF3_BAN_OR := M->EF1_BAN_FI
         WKREFINIMP->EF3_PRACOR := M->EF1_PRACA
         WKREFINIMP->EF3_SQCNOR := M->EF1_SEQCNT
         WKREFINIMP->EF3_CDEVOR := WorkEF3->EF3_CODEVE
         WKREFINIMP->EF3_PARCOR := WorkEF3->EF3_PARC
         WKREFINIMP->EF3_IVIMOR := WorkEF3->EF3_INVIMP
         WKREFINIMP->EF3_LINOR  := WorkEF3->EF3_LINHA
         If !( WorkEF3->EF3_MOE_IN <> WKREFINIMP->EF1_MOEDA .And. WKREFINIMP->EF1_MOEDA <> "R$ " .And. WKREFINIMP->EF3_VL_MOE > 0 )
            WKREFINIMP->EF3_VL_MOE := WorkEF3->EF3_VL_MOE
         EndIf
         WKREFINIMP->EF3_TX_MOE := WorkEF3->EF3_TX_MOE
         WKREFINIMP->EF3_MOE_IN := WorkEF3->EF3_MOE_IN
         WKREFINIMP->(msunlock())

      EndIf
   ElseIf cOp == "EXCLUIR"
      If Empty(WKREFINIMP->EF2_CONTRA) .And. WKREFINIMP->(!Eof())
         WKREFINIMP->(DbDelete())
      EndIf
   EndIf
End Sequence

RestOrd(aOrd,.T.)
Return

*------------------------------*
Static Function SetHeader()
*------------------------------*
Local i := 0
Local cCampo := ""

SX3->(DbSetOrder(2))
For i := 1 To WKREFINIMP->(FCount())
   cCampo := WKREFINIMP->(FieldName(i))
   If (cCampo $ "EF2_CONTRA/EF1_BAN_FI/EF1_PRACA/EF1_SEQCNT/DT_VINC/VL_VINC/VL_MNAC/TX_VINC/EF1_MOEDA/EF1_DT_VEN")
      If SX3->(DbSeek(cCampo))
         aAdd(aHeader,{Sx3->X3_TITULO ,;
                       Sx3->X3_CAMPO  ,;
                       Sx3->X3_PICTURE,;
                       Sx3->X3_TAMANHO,;
                       Sx3->X3_DECIMAL,;
                       If(cCampo=="EF2_CONTRA","EX401VlContr(M->EF2_CONTRA)",Sx3->X3_VALID),;
                       Sx3->X3_USADO  ,;
                       Sx3->X3_TIPO   ,;
                       "WKREFINIMP"   ,;
                       Sx3->X3_CONTEXT})
      Else
         Do Case
            Case cCampo == "DT_VINC"
               SX3->(DbSeek("EF1_DT_VEN"))

               aAdd(aHeader,{ STR0192,;  //"Dt.Vinculacao"
                             "DT_VINC",;
                             Sx3->X3_PICTURE,;
                             Sx3->X3_TAMANHO,;
                             Sx3->X3_DECIMAL,;
                             "",;
                              Sx3->X3_USADO  ,;
                              Sx3->X3_TIPO   ,;
                              "WKREFINIMP"   ,;
                              Sx3->X3_CONTEXT})

            Case cCampo == "VL_VINC"
               SX3->(DbSeek("EF3_VL_MOE"))
               aAdd(aHeader,{ STR0193,;  //"Vl.Vinc Moeda"
                             "VL_VINC",;
                             Sx3->X3_PICTURE,;
                             Sx3->X3_TAMANHO,;
                             Sx3->X3_DECIMAL,;
                             "",;
                              Sx3->X3_USADO  ,;
                              Sx3->X3_TIPO   ,;
                              "WKREFINIMP"   ,;
                              Sx3->X3_CONTEXT})

            Case cCampo == "VL_MNAC"
               SX3->(DbSeek("EF3_VL_MOE"))
               aAdd(aHeader,{ STR0194,;  //"Vl.Vinculacao"
                             "VL_MNAC",;
                             Sx3->X3_PICTURE,;
                             Sx3->X3_TAMANHO,;
                             Sx3->X3_DECIMAL,;
                             "",;
                              Sx3->X3_USADO  ,;
                              Sx3->X3_TIPO   ,;
                              "WKREFINIMP"   ,;
                              Sx3->X3_CONTEXT})

            Case cCampo == "TX_VINC"
               SX3->(DbSeek("EF3_TX_MOE"))
               aAdd(aHeader,{ STR0195,;  //"Tx.Vinculacao"
                             "TX_VINC",;
                             Sx3->X3_PICTURE,;
                             Sx3->X3_TAMANHO,;
                             Sx3->X3_DECIMAL,;
                             "Positivo() .AND. EX401CalVl()",;
                              Sx3->X3_USADO  ,;
                              Sx3->X3_TIPO   ,;
                              "WKREFINIMP"   ,;
                              Sx3->X3_CONTEXT})
         End Case
      EndIf
   EndIf
Next

Return

*-----------------------------------*
Function EX401VlContr(cChave,lAppend)
*-----------------------------------*
Local lRet := .T.
Local aOrd := SaveOrd("EF1")
Default cChave := ""
Default lAppend := .F.

Begin Sequence

   If Empty(cChave)
      Help(" ",1,"EFF0000004")  //"Número de Contrato de Financiamento de Importação inválido." ## "Informe um Número de Contrato de Financiamento de Importação válido."
      lRet := .F.
      Break
   EndIf

If lAppend .Or. WKREFINIMP->(!Eof())
   WKREFINIMP->EF2_CONTRA := ""
   WKREFINIMP->EF1_BAN_FI := ""
   WKREFINIMP->EF1_PRACA  := ""
   WKREFINIMP->EF1_SEQCNT := ""
   WKREFINIMP->DT_VINC    := dDataBase
   WKREFINIMP->VL_VINC    := 0
   WKREFINIMP->VL_MNAC    := 0
   WKREFINIMP->TX_VINC    := 0
   WKREFINIMP->EF1_MOEDA  := ""
   WKREFINIMP->EF1_DT_VEN := CTOD("")

   WKREFINIMP->EF3_TPMOOR := ""
   WKREFINIMP->EF3_CONTOR := ""
   WKREFINIMP->EF3_BAN_OR := ""
   WKREFINIMP->EF3_PRACOR := ""
   WKREFINIMP->EF3_SQCNOR := ""
   WKREFINIMP->EF3_CDEVOR := ""
   WKREFINIMP->EF3_PARCOR := ""
   WKREFINIMP->EF3_IVIMOR := ""
   WKREFINIMP->EF3_LINOR  := ""
   WKREFINIMP->EF3_VL_MOE := 0
   WKREFINIMP->EF3_TX_MOE := 0
   WKREFINIMP->EF3_MOE_IN := ""

   If M->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT) == cChave
      Help(" ",1,"EFF0000004")  //"Número de Contrato de Financiamento de Importação inválido." ## "Informe um Número de Contrato de Financiamento de Importação válido."
      lRet := .F.
      Break
   EndIf

   If EF1->EF1_CONTRA <> M->EF2_CONTRA
      EF1->(DbSetOrder(1))  //"EF1_FILIAL+EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT"
      If !EF1->(DbSeek(xFilial("EF1")+"I"+cChave))
         Help(" ",1,"EFF0000004")  //"Número de Contrato de Financiamento de Importação inválido." ## "Informe um Número de Contrato de Financiamento de Importação válido."
         lRet := .F.
         Break
      EndIf
   EndIf   

   WKREFINIMP->EF2_CONTRA := EF1->EF1_CONTRA
   WKREFINIMP->EF1_BAN_FI := EF1->EF1_BAN_FI
   WKREFINIMP->EF1_PRACA  := EF1->EF1_PRACA
   WKREFINIMP->EF1_SEQCNT := EF1->EF1_SEQCNT
   WKREFINIMP->EF1_MOEDA  := EF1->EF1_MOEDA
   WKREFINIMP->DT_VINC    := dDataBase
   WKREFINIMP->VL_VINC    := WorkEF3->EF3_VL_MOE
   WKREFINIMP->TX_VINC    := BuscaTaxa(WKREFINIMP->EF1_MOEDA,WKREFINIMP->DT_VINC,,.F.,.T.,,"")
   WKREFINIMP->VL_MNAC    := WKREFINIMP->VL_VINC * WKREFINIMP->TX_VINC
   WKREFINIMP->EF1_DT_VEN := EF1->EF1_DT_VEN
   WKREFINIMP->EF3_CDEVOR := WorkEF3->EF3_CODEVE
   WKREFINIMP->EF3_LINOR  := WorkEF3->EF3_LINHA

   WKREFINIMP->EF3_TPMOOR := M->EF1_TPMODU
   WKREFINIMP->EF3_CONTOR := M->EF1_CONTRA
   WKREFINIMP->EF3_BAN_OR := M->EF1_BAN_FI
   WKREFINIMP->EF3_PRACOR := M->EF1_PRACA
   WKREFINIMP->EF3_SQCNOR := M->EF1_SEQCNT
   WKREFINIMP->EF3_PARCOR := WorkEF3->EF3_PARC
   WKREFINIMP->EF3_IVIMOR := WorkEF3->EF3_INVIMP
      
   If WorkEF3->EF3_MOE_IN <> WKREFINIMP->EF1_MOEDA .And. WKREFINIMP->EF1_MOEDA <> MOEDA_REAIS
      //NCF - 02/12/2020 - Converte o valor em moeda conforme a paridade da moeda da invoice x moeda do contrato onde será refinanciada
      WKREFINIMP->EF3_VL_MOE := WorkEF3->EF3_VL_MOE * Round( BuscaTaxa(WorkEF3->EF3_MOE_IN,WKREFINIMP->DT_VINC,,.F.,.T.,,"") / BuscaTaxa(WKREFINIMP->EF1_MOEDA,WKREFINIMP->DT_VINC,,.F.,.T.,,"") , AvSx3("EF3_TX_MOE",4) )
   Else
      WKREFINIMP->EF3_VL_MOE := WorkEF3->EF3_VL_MOE
   EndIf

   WKREFINIMP->EF3_TX_MOE := WorkEF3->EF3_TX_MOE
   WKREFINIMP->EF3_MOE_IN := WorkEF3->EF3_MOE_IN
EndIf

End Sequence

RestOrd(aOrd,.T.)
Return lRet

*--------------------------------*
Function EX401CalVl()
*--------------------------------*
WKREFINIMP->VL_MNAC := WKREFINIMP->VL_VINC * M->TX_VINC
Return .T.

Function Ex401TotEve( cEve )

Local aOrdWkEF3 := SaveOrd("WorkEF3")
Local nTotal    := 0

WorkEF3->(DbGotop())
Do While WorkEF3->(!Eof())
   If WorkEF3->EF3_CODEVE == cEve
      nTotal += WorkEF3->EF3_VL_MOE
   EndIf
   WorkEF3->(DbSkip())
EndDo

RestOrd(aOrdWkEF3,.T.)

Return nTotal

Function EX401AcPaPP(aParc,nPos,cAliasEF3)
Local n

nDiff := Round(aParc[nPos,4],AvSX3("EF3_VL_MOE",4)) - (cAliasEF3)->EF3_VL_MOE

If nDiff > 0
   //Cria nova parcela com a diferença a maior
   aAdd(aParc,Nil)
   aIns(aParc,nPos+1)
   aParc[nPos+1] := aClone(aParc[nPos])
   aParc[nPos+1][4] := nDiff
   aParc[nPos+1][5] := nDiff
Else
   //Busca parcela com saldo para remover a diferença
   n := nPos
   Do While n <= Len(aParc) //Procura a partir da parcela liquidada
      
      If aParc[n][1] == "2" .AND. aParc[n][2] == (cAliasEF3)->EF3_CODEVE//Juros do mesmo evento
         If aParc[Len(aParc)][4] + nDiff > 0 //Se a parcela tem saldo suficiente
            aParc[Len(aParc)][4] := aParc[Len(aParc)][4]  + nDiff
            nDiff := 0
            Exit
         Else
            nDiff := nDiff + aParc[Len(aParc)][4]
            aDel(aParc,n)
            aSize(aParc,Len(aParc)-1)
            n--
         EndIf
      EndIf
      
      n++
   EndDo
EndIf

Return aParc

/*
Funcao     : BuscaDescEv()
Parametros : cAliasEF1
             cAliasEF3
             cEvento 
Retorno    : Descrição do evento contábil
Objetivos  : Verificar se a função EX400DescEv() está no repositório, para retornar a descrição do evento conforme tipo de finaciamento do evento
Autor      : WFS
Data/Hora  : out/2017
*/
Static Function BuscaDescEv(cAliasEF1, cAliasEF3, cEvento)
Local cRet:= ""
Static lFindEX400DescEv

   If ValType(lFindEX400DescEv) == "U"
      lFindEX400DescEv:= FindFunction("EX400DESCEV")
   EndIf

   If lFindEX400DescEv
      cRet:= EX400DescEv(cAliasEF1, cAliasEF3, cEvento)
   Else
      cRet:= Posicione("EC6", 1 , xFilial("EC6") + If(!lEFFTpMod .Or. If(cAliasEF1 == "M", M->EF1_TPMODU, (cAliasEF1)->EF1_TPMODU) <> IMP, "FIEX", "FIIM") + If(cAliasEF1 == "M", M->EF1_TP_FIN, (cAliasEF1)->EF1_TP_FIN) + If(cAliasEF3 == "M", M->EF3_CODEVE, (cAliasEF3)->EF3_CODEVE), "EC6_DESC")
   EndIf

Return cRet
/*
Funcao     : RetAceAcc()
Parametros : cEF3_INVOIC
Retorno    : Retorno do tipo do contrato ACC ou ACE
Objetivos  : Verificar se o registro atual tem invoice atrelada pra definir se é ACE quando tem e ACC quando não tem
Autor      : MPG
Data/Hora  : Jan/2018
*/

Function RetAceAcc(cEF3_INVOIC)
Local cRet := M->EF1_TP_FIN

If !empty(cEF3_INVOIC)
   cRet := "02"
endif

Return cRet

/*
Funcao     : FiltraRef()
Parametros : Não há.
Retorno    : Não há.
Objetivos  : Criação de função para realizar o filtro que era feito na EX401Refinim
Autor      : Thomson Reuters
Data/Hora  : Nov/2020
*/
Static Function FiltraRef()
Local cFiltRef := ""
Local nOpcF

cFiltRef := "(WKREFINIMP->EF3_TPMOOR == M->EF1_TPMODU .And. "
cFiltRef += "WKREFINIMP->EF3_CONTOR == M->EF1_CONTRA .And. "
cFiltRef += "WKREFINIMP->EF3_BAN_OR == M->EF1_BAN_FI .And. "
cFiltRef += "WKREFINIMP->EF3_PRACOR == M->EF1_PRACA  .And. "
cFiltRef += "WKREFINIMP->EF3_SQCNOR == M->EF1_SEQCNT .And. "
cFiltRef += "WKREFINIMP->EF3_CDEVOR == WorkEF3->EF3_CODEVE .And. "
cFiltRef += "WKREFINIMP->EF3_PARCOR == WorkEF3->EF3_PARC   .And. "
cFiltRef += "WKREFINIMP->EF3_IVIMOR == WorkEF3->EF3_INVIMP .And. "
cFiltRef += "WKREFINIMP->EF3_LINOR  == WorkEF3->EF3_LINHA  .OR. " //LRS - 01/12/2017
cFiltRef += "Empty(WKREFINIMP->EF3_CONTOR)) " //LRS - 01/12/2017


WKREFINIMP->(DbSetOrder(0))

WKREFINIMP->(DbSetFilter(&("{||"+cFiltRef+"}"),cFiltRef))
nOpcF := iif( Empty(WKREFINIMP->EF2_CONTRA) , 3 , 4 )
WKREFINIMP->(DbClearFilter())

Return nOpcF
