//Revisão - transcrição para 8.11 - Alcir Alves - 14-03-05
//Revisão - Novas Tabelas FinImp, Filtros - Henrique Raineire - 22/06/2006

#INCLUDE "EFFRC150.ch"
//Autor.....: Alessandro Alves Ferreira
//Programa..: EFFRC150.PRW
//Data......: 05/09/04
//Descricao.: Relatório de contratos ACC/ACE/Controle de Juros

#define ACC         "01"
#define ACE         "02"
#define PRE_PAGTO   "03"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AVERAGE.CH"

/*
Função..: RC150ACC
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Rotina de Relatório de ACC
*/
************************
Function RC150ACC()
************************

RC150Rel("ACC")

Return .T.

/*
Função..: RC150ACE
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Rotina de Relatório de ACE
*/
************************
Function RC150ACE()
************************
RC150Rel("ACE")
Return .T.

/*
Função..: RC150PJ
Autor...: Alessandro Alves Ferreira - AAF
Data....: 08/10/04
Objetivo: Rotina de Relatório de Provisão de Juros
*/
************************
Function RC150PJ()
************************
RC150Rel("Provisão de Juros")
Return .T.

/*
Função..: RC150Rel
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Rotina de Relatório de ACC/ACE/Provisão de Juros
*/
****************************
Function RC150Rel(cTipo,p_R4)
****************************
LOCAL nIndSx3   :=  SX3->(IndexOrd())        
Private cPergunte:= ""      
Private cFilEF1:= xFilial("EF1")
Private cFilEF3:= xFilial("EF3")
Private cFilEEC:= xFilial("EEC")
Private cFilECA:= xFilial("ECA")
Private cFilSEB:= xFilial("SWB")
Private cFilSW9:= xFilial("SW9")
Private aRel   := {}
Private nRelBanco      :=  1
Private nRelTpMod      :=  15 //HVR
Private nRelContra     :=  2
Private nRelSeq        :=  16  //HVR
Private nRelMoeda      :=  3
Private aProc  := {}
Private cNomArq:= ""
Private nTot   := 0
Private cTipRel
SX3->(DBSetOrder(2))     
Private lTemChave  := SX3->(DBSeek("EF1_BAN_FI")) .and. SX3->(DBSeek("EF1_PRACA")) .and.;
                      SX3->(DBSeek("EF2_BAN_FI")) .and. SX3->(DBSeek("EF2_PRACA")) .and.;
                      SX3->(DBSeek("EF3_BAN_FI")) .and. SX3->(DBSeek("EF3_PRACA")) .and.;
                      SX3->(DBSeek("EF4_BAN_FI")) .and. SX3->(DBSeek("EF4_PRACA"))

//HVR - Novos campos do FinImp
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0
SX3->(DBSetOrder(nIndSX3))
#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF

/*
RC150AcDic()//Verifica e Acerta Dicionário
*/
//Do While .T.
   
   If cTipo $ "ACC/ACE"
      cPergunte := "RC150A"
   Else
      cPergunte := "RC150B"
   Endif
   
   
   IF ! Pergunte(cPergunte,.T.)
      //exit
      return .f.
   Endif

   IF lEFFTpMod
      If cTipo $ "ACC/ACE"
         cParTpMod := mv_par07 //HVR
      Else
         cParTpMod := mv_par06 //HVR
         If !Empty(mv_par07)
            cContratos:= mv_par07
         Else
            cContratos:= 0
         EndIf
      Endif
   ENDIF
   cParBanco := mv_par01
   cParContra:= mv_par02
   dParIni   := mv_par03
   dParFinal := mv_par04
   lAnalit   := iIF( cPergunte=="RC150B", .F.     , mv_par05 == 2)
   nTipImp   := iiF( cPergunte=="RC150B", mv_par05, mv_par06     )
   cTipRel   := cTipo
  
   If nTipImp > 1
      lAnalit := .F.
   Endif
  
   //If !E_Periodo_Ok(dParIni,dParFinal) //Ambos estão preenchidos
   //   Loop
   //Endif
   
   Processa({|| iIF(lTop, RC150Query(), RC150Dbf() ) },STR0001)    //"Pesquisando Dados..."
   Processa({|| RC150Dados()},STR0002) //"Processando..."
   
   If lTop
      TRB->( dbCloseArea() )
   Else
      E_EraseArq(cNomArq)
   Endif
   
   If nTot > 0
      If nTipImp == 1
         //Impressão
            RC150Print()
      ElseIf nTipImp == 2
         //Em Arquivo
         RC150DbfImp(.F.)
      Else
         //Excel
         RC150DbfImp(.T.)
      Endif
   Else
      Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
   Endif
   
//EndDo             

Return .T.

/*
Função..: RC150Dados
Autor...: Alessandro Alves Ferreira - AAF
Data....: 26/10/04
Objetivo: Executa Query para retorno dos dados de impressão
*/
Function RC150Dados()
Local cContra, cSeqCNT, cMoeda , cBanco, cTpMod, dDtJur , nContraVl, nContraVlRs,cPraca //HVR cTpMod, cSeqCNT
Local nContraVl:=nContraVlRs:=0

//ACC
Local nVinc      := 0, nVincRs    := 0
Local nVc        := 0
Local nVincAnt   := nVincAntRs := 0
Local nVcAnt     := 0
Local aProc      := {}  
//ACE
Local nLiq       := 0, nLiqRs     := 0
Local nLiqAnt    := 0, nLiqAntRs  := 0
//Provisão de Juros
Local nPJ        := 0, nPJRs      := 0
Local nEstPJ     := 0, nEstPJRs   := 0
Local nLiqPJ     := 0, nLiqPJRs   := 0
Local nPJAnt     := 0, nPJAntRs   := 0
Local nEstPJAnt  := 0, nEstPJAntRs:= 0
Local nLiqPJAnt  := 0, nLiqPJAntRs:= 0
// ACSJ 22/04/2005 - Inicio
Local nValorLiq   := 0 
Local nValorLiqRs := 0
Local cDtLiq      := ""
// ACSJ 03/05/2005 - Inicio
Local cAntContra  := ""
Local cAntTpMod   := ""  //HVR
Local cAntBanco   := "" 
Local cAntPraca   := ""
Local aRetCalcECA := {}
// --------------- - Fim

ProcRegua( nToT )
EF3->(DBSETORDER(1))
aRel := {}
TRB->( dbGoTop() )
Do While ! TRB->( EoF() ) 

   if TRB->EF3_CODEVE == '100' 
      cContra     := TRB->EF1_CONTRA
      IF lEFFTpMod
         cSeqCNT     := TRB->EF1_SEQCNT
      ENDIF
      nContraVl   := TRB->EF3_VL_MOE // MJA 17/05/05
      nContraVlRs := TRB->EF3_VL_REA // MJA 17/05/05       
      cMoeda      := TRB->EF3_MOE_IN
      cBanco      := TRB->EF1_BAN_FI
      IF lEFFTpMod
         cTpMod      := TRB->EF1_TPMODU //HVR
      ENDIF
      dDtJur      := TRB->EF1_DT_JUR  
      nSldPr      := TRB->EF1_SLD_PR	
      nSldPm      := TRB->EF1_SLD_PM
   Endif
   if lTemChave
       cPraca:=TRB->EF1_PRACA
   endif
   If cTipRel = "ACE"
      nRelTpMod := 19
      EF1->(DBSEEK(cFilEF1+IF(lEFFTpMod,TRB->EF1_TPMODU,"")+TRB->EF1_CONTRA+Iif(lTemChave,TRB->EF1_BAN_FI+TRB->EF1_PRACA, "")+IF(lEFFTpMod,TRB->EF1_SEQCNT,"")))
      cTpEveEF1   := EF1->EF1_TP_FIN  
      cContra     := EF1->EF1_CONTRA
      cMoeda      := TRB->EF3_MOE_IN
      IF lEFFTpMod
         cSeqCNT     := EF1->EF1_SEQCNT
         cTpMod      := EF1->EF1_TPMODU //HVR
      ENDIF
      cBanco      := EF1->EF1_BAN_FI
      IF lEFFTpMod
         cPraca      := EF1->EF1_PRACA //HVR
      ENDIF
      if lTemChave
         cPraca:=TRB->EF1_PRACA
      endif
      dDtJur      := EF1->EF1_DT_JUR
//      nContraVl   := TRB->EF3_VL_MOE MJA 17/05/05
//      nContraVlRs := TRB->EF3_VL_REA MJA 17/05/05 
      nSldPr      := EF1->EF1_SLD_PR	
      nSldPm      := EF1->EF1_SLD_PM      
   Endif 

   If TRB->EF3_DT_EVE >= dParIni
      //No Periodo
      
      If cTipRel == "ACC"
         Do Case
            Case TRB->EF3_CODEVE == '600'    //Vinculação de Parcela
               nVinc       += TRB->EF3_VL_MOE
               nVincRs     += TRB->EF3_VL_REA

               If lAnalit
                     //Adiciona no Array com os processos vinculados a este contrato.
                     aAdd(aProc,{ IF(lEFFTpMod,IF(TRB->EF3_ORIGEM="SWB",AvKey(TRB->EF3_HAWB,"EF3_PREEMB"),TRB->EF3_PREEMB), TRB->EF3_PREEMB), IF(lEFFTpMod,IF(TRB->EF3_ORIGEM="SWB",TRB->EF3_LINHA,AvKey(TRB->EF3_PARC, "EF3_LINHA")),TRB->EF3_PARC), IF(lEFFTpMod,IF(TRB->EF3_ORIGEM="SWB",Posicione("SW9",1,cFilSW9+TRB->EF3_INVIMP,"W9_MOE_FOB"),Posicione("EEC",1,cFilEEC+TRB->EF3_PREEMB,"EEC_MOEDA")),Posicione("EEC",1,cFilEEC+TRB->EF3_PREEMB,"EEC_MOEDA")), IF(lEFFTpMod, IF(TRB->EF3_ORIGEM="SWB",SW9->W9_FOB_TOT,EEC->EEC_TOTPED),EEC->EEC_TOTPED), TRB->EF3_VL_MOE }) //HVR
               Endif

            Case TRB->EF3_CODEVE $  '500/501' .and. TRB->EF3_TP_EVE = "01" //Variação Cambial
               nVc         += TRB->EF3_VL_REA

         End Case
         
      ElseIf cTipRel == "ACE"
         Do Case
            Case TRB->EF3_CODEVE == '600'    //Vinculação de Parcela
               nVinc       += TRB->EF3_VL_MOE
               nVincRs     += TRB->EF3_VL_REA

               If lAnalit
                  //Adiciona no Array com os processos vinculados a este contrato.
                  nValorLiq:= 0
                  nValorLiqRs:= 0
                  cDtLiq:= ""
                  aProc:={}
                  nEF3REc:=EF3->(RECNO())
                  nindEF3:=EF3->(indexord())
                  EF3->(DBSetOrder(1))
                  EF3->( DBSeek(cFilEf3+IF(lEFFTpMod,TRB->EF1_TPMODU,"")+TRB->EF1_CONTRA+Iif(lTemChave,TRB->EF1_BAN_FI+TRB->EF1_PRACA, "")+IF(lEFFTpMod,TRB->EF1_SEQCNT,"")+"630") )
                  Do While EF3->EF3_FILIAL = cFilEf3 .and. EF3->EF3_CONTRA = TRB->EF1_CONTRA .and.;
                           IF(lEFFTpMod, EF3->EF3_TPMODU = TRB->EF1_TPMODU,.T.) .and. IF(lEFFTpMod, EF3->EF3_SEQCNT = TRB->EF1_SEQCNT,.T.) .and.;
                           iif(lTemChave,EF3->EF3_BAN_FI = TRB->EF1_BAN_FI .and. EF3->EF3_PRACA = TRB->EF1_PRACA, .t.) .and.;                           
                           EF3->EF3_CODEVE == "630"                  //Alcir Alves - 20-05-05
                           //nValorLiq   += EF3->EF3_VL_MOE
                           //nValorLiqRs += EF3->EF3_VL_REA
                           //cDtLiq      += DtoC(EF3->EF3_DT_EVE) + " - " 
                           aAdd(aProc,{ IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", AvKey(EF3->EF3_HAWB,"EF3_PREEMB"), EF3->EF3_PREEMB) ,EF3->EF3_PREEMB), IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", EF3->EF3_LINHA, AvKey(EF3->EF3_PARC,"EF3_LINHA")) ,EF3->EF3_PARC), IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", Posicione("SW9",1,cFilSW9+EF3->EF3_INVIMP,"W9_MOE_FOB"),Posicione("EEC",1,cFilEEC+EF3->EF3_PREEMB,"EEC_MOEDA")) ,Posicione("EEC",1,cFilEEC+EF3->EF3_PREEMB,"EEC_MOEDA") ),;
                                        IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", SW9->W9_FOB_TOT, EEC->EEC_TOTPED) ,EEC->EEC_TOTPED), EF3->EF3_VL_MOE, EF3->EF3_VL_MOE, EF3->EF3_VL_REA, dtoc(EF3->EF3_DT_EVE)  })
                           EF3->(DBSkip())         
                  Enddo                                                                                                                                   
                  //Alcir Alves - 25-07-05 - considera baixa forçada evento.660 
                  EF3->( DBSeek(cFilEf3+IF(lEFFTpMod,TRB->EF1_TPMODU,"")+TRB->EF1_CONTRA+Iif(lTemChave,TRB->EF1_BAN_FI+TRB->EF1_PRACA, "")+IF(lEFFTpMod,TRB->EF1_SEQCNT,"")+"660") )
                  Do While EF3->EF3_FILIAL = cFilEf3 .and. EF3->EF3_CONTRA = TRB->EF1_CONTRA .and.;
                           IF(lEFFTpMod, EF3->EF3_TPMODU = TRB->EF1_TPMODU,.T.) .and. IF(lEFFTpMod, EF3->EF3_SEQCNT = TRB->EF1_SEQCNT,.T.) .and.;
                           iif(lTemChave,EF3->EF3_BAN_FI = TRB->EF1_BAN_FI .and. EF3->EF3_PRACA = TRB->EF1_PRACA, .t.) .and.;                           
                           EF3->EF3_CODEVE == "660"                  //Alcir Alves - 20-05-05
                           aAdd(aProc,{ IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", AvKey(EF3->EF3_HAWB,"EF3_PREEMB"), EF3->EF3_PREEMB) ,EF3->EF3_PREEMB), IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", EF3->EF3_LINHA, AvKey(EF3->EF3_PARC,"EF3_LINHA")) ,EF3->EF3_PARC), IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", Posicione("SW9",1,cFilSW9+EF3->EF3_INVIMP,"W9_MOE_FOB"),Posicione("EEC",1,cFilEEC+EF3->EF3_PREEMB,"EEC_MOEDA")) ,Posicione("EEC",1,cFilEEC+EF3->EF3_PREEMB,"EEC_MOEDA") ),;
                                        IF(lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", SW9->W9_FOB_TOT, EEC->EEC_TOTPED) ,EEC->EEC_TOTPED), EF3->EF3_VL_MOE, EF3->EF3_VL_MOE, EF3->EF3_VL_REA, dtoc(EF3->EF3_DT_EVE)  })
                           EF3->(DBSkip())         
                  Enddo                                                                                                                                   
                  ef3->(dbsetorder(nindEF3)) 
                  ef3->(dbgoto(nEF3REc))
                  nindEF3:=EF3->(indexord())
  //              cDtLiq := Substr( cDtLiq,1,(Len(cDtLiq)-1) )
                  //aAdd(aProc,{ TRB->EF3_PREEMB, TRB->EF3_PARC, Posicione("EEC",1,cFilEEC+TRB->EF3_PREEMB,"EEC_MOEDA"),;
                  //             EEC->EEC_TOTPED, TRB->EF3_VL_MOE, nValorLiq, nValorLiqRs, cDtLiq  })
               Endif
            
            Case TRB->EF3_CODEVE $  '500/501' .and. TRB->EF3_TP_EVE = "02"//Variação Cambial
               nVc         += TRB->EF3_VL_REA
//               nVc         += RC150CalcECA("ACE")               Procurar apenas na quebra de contrato
            Case TRB->EF3_CODEVE $ '630/660' .and. TRB->EF3_TP_EVE = "02"     //Alcir Alves - 25-07-05 - baixa forçada 660  //Liquidação de Parcela
               nLiq        += TRB->EF3_VL_MOE
               nLiqRs      += TRB->EF3_VL_REA

            Case lEFFTpMod .And. TRB->EF3_CODEVE $ '700/701/702/703/704/705/706/707/708/709' .and. TRB->EF1_TPMODU = "I" .and. !Empty(TRB->EF3_TX_MOE)//HVR
               nLiq        += TRB->EF3_VL_MOE
               nLiqRs      += TRB->EF3_VL_REA
               
 
         End Case

      ElseIf cTipRel == "Provisão de Juros" .AND. (cTpMod <> "E" .OR. !EasyGParam("MV_EEC_ECO",,.F.) .OR. !EMPTY(TRB->EF3_NR_CON) .OR.;
                                        If(cContratos = 2,.T.,If(cContratos = 1 .And. !EMPTY(TRB->EF3_NR_CON),.T.,If (cContratos = 3,.T.,.F.))))  //Alcir Alves - 19-10-05 - considerar do EF3 somente quando estier efetivado
         IF lEFFTpMod
            nRelTpMod := 18
         ENDIF

         Do Case
            Case lEFFTpMod .AND. TRB->EF1_TPMODU == "I" .AND. TRB->EF3_CODEVE $ '710/711/712/713/714/715/716/717/718/719';
            .OR. (!lEFFTpMod .OR. TRB->EF1_TPMODU == "E") .AND. TRB->EF3_CODEVE == '520'   //Provisão de Juros
               nPJ       += TRB->EF3_VL_MOE
               nPJRs     += if(!Empty(TRB->EF3_VL_REA),TRB->EF3_VL_REA,TRB->EF3_VL_MOE*BuscaTaxa(TRB->EF3_MOE_IN,TRB->EF3_DT_EVE,,.F.,.T.))

            Case TRB->EF3_CODEVE $  '525'   //Estorno de Provisão de Juros
               nEstPJ    += TRB->EF3_VL_MOE
               nEstPJRs  += TRB->EF3_VL_MOE

            Case TRB->EF3_CODEVE $ '550/551'//Variação Cambial da Provisão de Juros
               nVC       += TRB->EF3_VL_REA

            Case TRB->EF3_CODEVE $ "640/641/642/643/644/645/646/647/648/649/670/671/672/673/674/675/676/677/678/679"   //Liquidação de Provisão de Juros
               nLiqPJ      += TRB->EF3_VL_MOE
               nLiqPJRs    += TRB->EF3_VL_REA

            Case lEFFTpMod .And. TRB->EF1_TPMODU = "I" .AND. TRB->EF3_CODEVE $ '520'//lEFFTpMod .And. TRB->EF3_CODEVE $ '710/711/712/713/714/715/716/717/718/719' .and. TRB->EF1_TPMODU = "I"  .and. !Empty(TRB->EF3_TX_MOE)//HVR
               nLiqPJ      += TRB->EF3_VL_MOE
               nLiqPJRs    += TRB->EF3_VL_REA

         End Case

      Endif
   Else
      //Anterior ao Periodo

      If cTipRel == "ACC"
         Do Case
            Case TRB->EF3_CODEVE == '600' //.and. TRB->EF3_TP_EVE = "01"    //Vinculação de Parcela
               nVincAnt    += TRB->EF3_VL_MOE
               nVincAntRs  += TRB->EF3_VL_REA
            
            Case TRB->EF3_CODEVE $  '500/501' .and. TRB->EF3_TP_EVE = "01"//Variação Cambial
               nVcAnt      += TRB->EF3_VL_REA               
         End Case
         
      ElseIf cTipRel == "ACE"
         Do Case
            Case TRB->EF3_CODEVE == '600' //.and. TRB->EF3_TP_EVE = "02"   //Vinculação de Parcela
               nVincAnt    += TRB->EF3_VL_MOE
               nVincAntRs  += TRB->EF3_VL_REA

            Case TRB->EF3_CODEVE $ '630/660' .and. IF(lEFFTpMod,TRB->EF1_TPMODU <> "I",.T.) .and. TRB->EF3_TP_EVE = "02" //Alcir Alves - 25-07-05 - baixa forçada 660    //Liquidação de Parcela
               nLiqAnt     += TRB->EF3_VL_MOE
               nLiqAntRs   += TRB->EF3_VL_REA
            
            Case TRB->EF3_CODEVE $  '500/501' .and. TRB->EF3_TP_EVE = "02"//Variação Cambial
               nVcAnt      += TRB->EF3_VL_REA               
//               nVcAnt      += RC150CalcECA("ACE")   Procurar apenas na quebra de contrato
               // ACSJ - 22/04/2005 - Inicio
               // Pequisa variação cambial no ECA                        
               ECA->(DBSetOrder(10))
               ECA->(DBSeek( cFilECA + "FIEX02" + TRB->EF1_CONTRA + IIF(lAnalit,TRB->EF3_PREEMB +; 
                             AvKey(TRB->EF1_CC,"ECA_IDENTC"),"") ))
               
               Do While ECA->ECA_FILIAL = cFilECA .and. ECA->ECA_TPMODU = "FIEX02" .and.;
                        ECA->ECA_CONTRA = TRB->EF1_CONTRA .and. IIF(lAnalit,ECA->ECA_PREEMB = TRB->EF3_PREEMB,.T.) .and.;
                        ECA->ECA_IDENTC = AvKey(TRB->EF1_CC,"ECA_IDENTC") .and. .not. ECA->(EoF()) .And. ;
                        IIF(lEFFTpMod,ECA->(ECA_BANCO+ECA_PRACA+ECA_SEQCNT)==TRB->(EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT),.T.)
                        
                  If (ECA->ECA_ID_CAM = "500" .or. ECA->ECA_ID_CAM = "501") .and. ECA->ECA_SEQ = TRB->EF3_PARC
                     nVcAnt      += ECA->ECA_VALOR
                  Endif
                  
                  ECA->(DBSkip())                  
               Enddo
               // ----------------- - Fim
               
         End Case
               
      ElseIf cTipRel == "Provisão de Juros" .AND. (cTpMod <> "E" .OR. !EasyGParam("MV_EEC_ECO",,.F.) .OR. !EMPTY(TRB->EF3_NR_CON) .OR.;
                                         If(cContratos = 2,.T.,If(cContratos = 1 .And. !EMPTY(TRB->EF3_NR_CON),.T.,If (cContratos = 3,.T.,.F.))))  //Alcir Alves -19-10-05 considerar do EF3 somente quando estier efetivado
         Do Case
            Case lEFFTpMod .AND. TRB->EF1_TPMODU == "I" .AND. TRB->EF3_CODEVE $ '710/711/712/713/714/715/716/717/718/719';
            .OR. (!lEFFTpMod .OR. TRB->EF1_TPMODU == "E") .AND. TRB->EF3_CODEVE == '520'   //Provisão de Juros
               nPJAnt    += TRB->EF3_VL_MOE
               nPJAntRs  += if(!Empty(TRB->EF3_VL_REA),TRB->EF3_VL_REA,TRB->EF3_VL_MOE*BuscaTaxa(TRB->EF3_MOE_IN,TRB->EF3_DT_EVE,,.F.,.T.))

            Case TRB->EF3_CODEVE $  '525'   //Estorno de Provisão de Juros
               nEstPJAnt   += TRB->EF3_VL_MOE
               nEstPJAntRs += TRB->EF3_VL_MOE
               
            Case TRB->EF3_CODEVE $ '550/551'//Variação Cambial da Provisão de Juros
               nVCAnt      += TRB->EF3_VL_REA

            Case TRB->EF3_CODEVE $ "640/641/642/643/644/645/646/647/648/649/670/671/672/673/674/675/676/677/678/679"    //Liquidação de Provisão de Juros
               nLiqPJAnt     += TRB->EF3_VL_MOE
               nLiqPJAntRs   += TRB->EF3_VL_REA 

            Case lEFFTpMod .And. TRB->EF1_TPMODU = "I" .AND. TRB->EF3_CODEVE $ '520'//TRB->EF3_CODEVE $ '710/711/712/713/714/715/716/717/718/719' .and. TRB->EF1_TPMODU = "I"  .and. !Empty(TRB->EF3_TX_MOE) //HVR
               nLiqPJAnt     += TRB->EF3_VL_MOE
               nLiqPJAntRs   += TRB->EF3_VL_REA 

         End Case
               
      Endif
   Endif
   
   cLastCont:= iif(lEFFTpMod, TRB->EF1_TPMODU, "")+TRB->EF1_CONTRA+iif(lTemChave,TRB->EF1_BAN_FI+TRB->EF1_PRACA,"")+iif(lEFFTpMod, TRB->EF1_SEQCNT, "")
   IncProc(STR0002) //"Processando..."
   // ACSJ -  03/05/2005 - Inicio
   cAntContra := TRB->EF1_CONTRA
   IF lEFFTpMod
      cAntTpMod  := TRB->EF1_TPMODU //HVR
   ENDIF
   cAntBanco  := TRB->EF1_BAN_FI
   cAntPraca  := TRB->EF1_PRACA
   dAntDtCon  := TRB->EF1_DT_CON
   // ------------------ - Fim
   TRB->( dbSkip() )

   If iif(lEFFTpMod, TRB->EF1_TPMODU, "")+TRB->EF1_CONTRA+iif(lTemChave,TRB->EF1_BAN_FI+TRB->EF1_PRACA,"")+iif(lEFFTpMod, TRB->EF1_SEQCNT, "") <> cLastCont
     
      //Alcir Alves - 28-10-05
      aRetCalcECA := RC150CalcECA(cTipRel,cAntContra,cAntBanco,cAntPraca,1)               
      nVc         += aRetCalcECA[1]     
      nVcAnt      += aRetCalcECA[2]
      //calcula controle de juros
      aRetCalc2 := RC150CalcECA(cTipRel,cAntContra,cAntBanco,cAntPraca,2)                     
      nPJ    += aRetCalc2[1]     
      nPJRs  += aRetCalc2[2]     
      // ------------------ - Fim
      If cTipRel == "ACC"                              
         nSldAnt   := nContraVl-nVincAnt        
         nSldAntRs := nContraVlRs-nVincAntRs+nVcant
         nSldAntRs :=iif(nSldAnt==0,0,nSldAntRs)      
         nSldAtu   := nSldAnt - nVinc
         nSldAtuRs := nSldAntRs - nVincRs + nVc
         nSldAtuRs :=iif(nSldAtu==0,0,nSldAtuRs)
//                      1       2       3         4          5          6          7        8       9      10     11         12        13        14      15     16      17
         if nSldAnt<>0 .OR. nSldAntRs<>0  .OR. nSldAtu<>0 .OR. nSldAtuRs<>0  
               IF lEFFTpMod
                  aAdd(aRel,{ cBanco, cContra, cMoeda, nContraVl, nContraVlRs, nSldAnt, nSldAntRs, nVinc, nVincRs, nVc, nSldAtu, nSldAtuRs, dDtJur, cTpMod, cSeqCNT, cPraca, aProc } ) //HVR
               ELSE
                  aAdd(aRel,{ cBanco, cContra, cMoeda, nContraVl, nContraVlRs, nSldAnt, nSldAntRs, nVinc, nVincRs, nVc, nSldAtu, nSldAtuRs, dDtJur, aProc } )
               ENDIF
            //26/05/2022 - Ponto de Entrada para adicionar dados no array aRel para contrado ACC
            IF(EasyEntryPoint("EFFRC150"),Execblock("EFFRC150",.F.,.F.,"ADD_DADOS_ACC"),)
         endif
         nVinc      := nVincRs    := 0
         nVc        := nVincAnt   := 0
         nVincAntRs := nVcAnt     := 0
         aProc      := {}     
         nSldAnt:= nContraVl:=nVincAnt:=0        
         nSldAntRs:=nContraVlRs:=nVincAntRs:=nVcant:=0
         nSldAtu:= nSldAnt := nVinc:=0
         nSldAtuRs := nSldAntRs:=nVincRs:=nVc:=0
         
      Elseif cTipRel == "ACE" 
         //Saldo Anterior (Vl. Contrato - Vinculações - Liquidações)      
//         nSldAnt   := nContraVl   - nVincAnt - nLiqAnt
//         nSldAntRs := nContraVlRs - nVincAntRs - nLiqAntRs + nVcAnt           
// ACSJ - 06/05/2005 - Inicio
//        Quando for ACE gerado apartir da vinculação de um ACE
         if cTpEveEF1 = '01'  //ACC
            nContraVl   := nVinc + nVincAnt
            nContraVlRs := nVincRs + nVincAntRs
            //nVinc       := 0
            //nVincRS     := 0  
         Endif
// ACSJ - 05/05/2005   - Inicio              	
         if nContraVl<=0 
           if EF3->(DBSeek(cFilEf3+iif(lEFFTpMod, cTpMod, "")+cContra+Iif(lTemChave,cbanco+cPraca, "")+iif(lEFFTpMod, cSeqCNT, "")+"100"))
               nContraVl:=EF3->EF3_VL_MOE
               nContraVlRs:=EF3->EF3_VL_REA
           endif
         endif

         nSldAnt   := nVincAnt-nLiqAnt
         nSldAntRs := nVincAntRs-nLiqAntRs+nVcant
//         nSldAnt   := nContraVl-nLiqAnt             // - nLiqAnt
//         nSldAntRs := nContraVlRs-nLiqAntRs +nVcant // - nLiqAntRs         
         nSldAntRs :=iif(nSldAnt==0,0,nSldAntRs)
         //nVc:=  nVincRs - nLiqRs 
         //nSldAtu   := nSldAnt - nLiq + nVinc
         //nSldAtuRs := nSldAntRs - nLiqRs + nVc + nVincRs
         nSldAtu   := nSldAnt + nVinc - nLiq
         nSldAtuRs := nSldAntRs + nVincRs - nLiqRs + nVc   
//         nSldAtu   := nVinc - nLiq  
//         nSldAtuRs := nVincRs - nLiqRs + nVc   
         nSldAtuRs :=iif(nSldAtu==0,0,nSldAtuRs)
//-------------------- - Fim            
   
         //Saldo Atual (Saldo Anterior - Vinculações - Liquidações)
//          nSldAtu   := iif(nSldAnt=0,nContraVl,nSldAnt) - nVinc
//          nSldAtuRs := iif(nSldAntRS=0,nContraVlRs,nSldAntRs) - nVincRs // + nVc
//                          1        2       3         4          5          6         7        8        9       10      11    12     13       14        15     16      17        18      19      20     21
         if nSldAnt<>0 .OR. nSldAntRs<>0  .OR. nSldAtu<>0 .OR. nSldAtuRs<>0  
            IF lEFFTpMod
               aAdd(aRel,{ cBanco, cContra, cMoeda, nContraVl, nContraVlRs, nSldAnt, nSldAntRs, nVinc, nVincRs, nLiq, nLiqRs, nVc, nSldAtu, nSldAtuRs, dDtJur, nSldPm, nSldPr, cTpMod, cSeqCNT, cPraca, aProc  } )  //HVR
            ELSE 
               aAdd(aRel,{ cBanco, cContra, cMoeda, nContraVl, nContraVlRs, nSldAnt, nSldAntRs, nVinc, nVincRs, nLiq, nLiqRs, nVc, nSldAtu, nSldAtuRs, dDtJur, nSldPm, nSldPr, aProc  } )
            ENDIF
            //26/05/2022 - Ponto de Entrada para adicionar dados no array aRel para contrado ACC
            IF(EasyEntryPoint("EFFRC150"),Execblock("EFFRC150",.F.,.F.,"ADD_DADOS_ACE"),)
         endif
         nVinc      := nVincRs    := 0
         nLiq       := nLiqRs     := 0
         nVc        := nVcAnt     := 0
         nVincAnt   := nVincAntRs := 0
         nLiqAnt    := nLiqAntRs  := 0
         aProc      := {}
         nSldAnt    := nContraVl := nLiqAnt := 0
         nSldAntRs :=  nContraVlRs := nLiqAntRs:=0
         nVcant:=0  // - nLiqAntRs         
         

      Elseif cTipRel == "Provisão de Juros" .AND. (cTpMod <> "E" .OR. !EasyGParam("MV_EEC_ECO",,.F.) .OR. !EMPTY(TRB->EF3_NR_CON) .OR.;
                                        If(cContratos = 2,.T.,If(cContratos = 1 .And. !EMPTY(TRB->EF3_NR_CON),.T.,If (cContratos = 3,.T.,.F.)))) //Alcir Alves - 19-10-05 - considerar do EF3 somente quando estier efetivado
         //Saldo Anterior (Provisão de Juros Anterior - Estornos de Provisão de Juros Anterior - Liquidações de Provisões de Juros Anterior)
         nSldAnt   := nPJAnt   - nEstPJAnt   - nLiqPJAnt
         nSldAntRs := nPJAntRs - nEstPJAntRs - nLiqPJAntRs + nVcAnt
         nSldAntRs :=iif(nSldAnt==0,0,nSldAntRs)
         //Saldo Atual (Saldo Anterior de Provisão de Juros + Provisões de Juros - Estornos de Provisão de Juros - Liquidações de Provisão de Juros)
         nSldAtu   := nSldAnt   + nPJ   - nEstPJ   - nLiqPJ
         nSldAtuRs := nSldAntRs + nPJRs - nEstPJRs - nLiqPJRs + nVc
         nSldAtuRs :=iif(nSldAtu==0,0,nSldAtuRs)
         if nSldAnt<>0 .OR. nSldAntRs<>0  .OR. nSldAtu<>0 .OR. nSldAtuRs<>0  
     //                     1        2        3         4         5           6         7       8      9     10       11        12       13     14     15        16       17      18      19       20
     	      IF lEFFTpMod
               aAdd(aRel,{ cBanco, cContra, cMoeda, nContraVl, nContraVlRs, nSldAnt, nSldAntRs, nPJ, nPJRs, nEstPJ, nEstPJRs, nLiqPJ, nLiqPJRs, nVc, nSldAtu, nSldAtuRs, dDtJur, cTpMod, cSeqCNT, cPraca} ) //HVR
            ELSE
               aAdd(aRel,{ cBanco, cContra, cMoeda, nContraVl, nContraVlRs, nSldAnt, nSldAntRs, nPJ, nPJRs, nEstPJ, nEstPJRs, nLiqPJ, nLiqPJRs, nVc, nSldAtu, nSldAtuRs, dDtJur} )
            ENDIF
            //26/05/2022 - Ponto de Entrada para adicionar dados no array aRel para contrado ACC
            IF(EasyEntryPoint("EFFRC150"),Execblock("EFFRC150",.F.,.F.,"ADD_DADOS_PROV_JUROS"),)
         endif
         nPJ        := nPJRs      := 0
         nEstPJ     := nEstPJRs   := 0
         nVc        := nVcAnt     := 0
         nLiqPJ     := nLiqPJRs   := 0
         nPJAnt     := nPJAntRs   := 0
         nEstPJAnt  := nEstPJAntRs:= 0
         nLiqPJAnt  := nLiqPJAntRs:= 0
         
         nSldAnt   := nPJAnt    := nEstPJAnt := nLiqPJAnt:=0
         nSldAntRs := nPJAntRs  := nEstPJAntRs := nLiqPJAntRs := nVcAnt:=0
         nSldAtu   := nSldAnt   := nPJ := nEstPJ   := nLiqPJ:=0
         nSldAtuRs := nSldAntRs := nPJRs := nEstPJRs := nLiqPJRs := nVc:= 0
      Endif
   Endif
   
EndDo

Return .T.

/*
Função..: RC150Query
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Executa Query para retorno dos dados de impressão
*/
*************************
Function RC150Query()
*************************
Local cQuery     := ""

ProcRegua( 3 )

************************************************************************************************
//            Banco           Contrato
cCampos  := " EF1.EF1_BAN_FI, EF1.EF1_CONTRA,EF3.EF3_NR_CON, "
//            Dt. Ini. Juros  Valor US         Valor RS
cCampos  += " EF1.EF1_DT_JUR, EF3.EF3_VL_MOE,  EF3.EF3_VL_REA, "
//            Moeda           Data do Evento  Evento
cCampos  += " EF3.EF3_MOE_IN, EF3.EF3_DT_EVE, EF3.EF3_CODEVE, "
IF lTemChave //Alcir Alves
   cCampos  += "EF1.EF1_PRACA,"
ENDIF
// ACSJ - 22/04/2005 - Inicio
cCampos  += " EF1.EF1_CC, EF1.EF1_SLD_PR, EF1.EF1_SLD_PM,"  
// ACSJ - 29/04/2005 - Inicio
cCampos  += " EF3.EF3_TX_MOE"      
// ACSJ - 03/05/2005 - Inicio
   cCampos +=  ", EF3.EF3_INVOIC, EF3.EF3_TP_EVE "
// ACSJ - 05/05/2005 - Inicio
   cCampos +=  ", EF1.EF1_DT_CON "
// ----------------- - Fim         
IF lEFFTpMod
   //             Invoice Importação
   cCampos  += ", EF3.EF3_INVIMP"
EndIf

IF lEFFTpMod
   //            Tipo do Modulo  
   cCampos  += ", EF1.EF1_TPMODU "
   //            Seq. Contrato  
   cCampos  += ", EF1.EF1_SEQCNT "
EndIf



cFrom    := RetSqlName("EF1")+" EF1 ,"+ RetSqlName("EF3")+" EF3 "

cWhere   := iIF( TcSrvType()=="AS/400"," EF1.@DELETED@ <> '*' "," EF1.D_E_L_E_T_ <> '*'" ) + " AND EF1.EF1_FILIAL = '"+cFilEF1+"' "+;
            iIF( TcSrvType()=="AS/400"," AND EF3.@DELETED@ <> '*' "," AND EF3.D_E_L_E_T_ <> '*'" ) + " AND EF3.EF3_FILIAL = '"+cFilEF3+"' "+;
            "AND EF3.EF3_CONTRA = EF1.EF1_CONTRA "

If lEFFTpMod
   cWhere += " AND EF1.EF1_SEQCNT = EF3.EF3_SEQCNT "
   cWhere += " AND EF1.EF1_TPMODU = EF3.EF3_TPMODU "
   IF cParTpMod = 1
      cWhere += " AND EF1.EF1_TPMODU = 'I' "
   ELSEIF cParTpMod = 2
      cWhere += " AND EF1.EF1_TPMODU = 'E' "
   ENDIF
EndIf

If cTipRel == "ACC"
   IF lEFFTpMod
   ELSE
      cWhere += " AND EF1.EF1_TP_FIN = '01' "
   ENDIF
   cWhere += " AND EF3.EF3_CODEVE IN('100','600','500','501')"

ElseIf cTipRel == "ACE"
   IF lEFFTpMod
   ELSE
      //Alcir Alves - 25-07-05 - considera baixa forçada evento.660 
      cWhere += " AND EF3.EF3_TP_EVE = '02' "  
   ENDIF
   cWhere += " AND EF3.EF3_CODEVE IN('100','500','501','600','630','660'"
   IF lEFFTpMod
      cWhere += ",'700','701','702','703','704','705','706','707','708','709')"  //HVR 70*
   ELSE 
      cWhere += ")"
   ENDIF

ElseIf cTipRel == "Provisão de Juros"
   cWhere += " AND EF3.EF3_CODEVE IN('100','520','525','550','551','640','641','642','643','644','645','646','647','648','649','670','671','672','673','674','675','676','677','678','679'"
   IF lEFFTpMod
      cWhere += ",'710','711','712','713','714','715','716','717','718','719')" //HVR 71*
   ELSE
      cWhere += ")"
   ENDIF
Elseif lTemChave
   cWhere += "AND EF3.EF3_BAN_FI = EF1.EF1_BAN_FI AND EF3.EF3_PRACA = EF1.EF1_PRACA"
Endif

//Filtro por Contrato
If !Empty(cParContra)
   cWhere += " AND EF1.EF1_CONTRA = '"+cParContra+"'"
Endif
//Filtro por Banco
If !Empty(cParBanco)
   cWhere += " AND EF1.EF1_BAN_FI = '"+cParBanco+"'"
Endif

//Filtro Por periodo - Data Final
If !Empty(dParFinal)
   cWhere += " AND EF1.EF1_DT_JUR <= '"+DtoS(dParFinal)  +"'"
   cWhere += " AND EF3.EF3_DT_EVE <= '"+DtoS(dParFinal)  +"'"
Endif

If lEFFTpMod
   cOrder  := " EF1.EF1_TPMODU, EF1.EF1_BAN_FI, EF1.EF1_CONTRA, EF1.EF1_SEQCNT , EF3.EF3_CODEVE "
Else
   cOrder  := " EF1.EF1_BAN_FI, EF1.EF1_CONTRA , EF3.EF3_CODEVE "
Endif

If lAnalit
   cCampos += ", EF3.EF3_PREEMB , EF3.EF3_PARC "
   cOrder  += ", EF3.EF3_PREEMB , EF3.EF3_PARC "
Endif

IF lEFFTpMod
   //            Processo       LINHA
   cCampos  += ", EF3.EF3_HAWB, EF3.EF3_LINHA, EF3.EF3_ORIGEM "
   cOrder   += ", EF3.EF3_HAWB, EF3.EF3_LINHA "
EndIf

cQuery := " SELECT "+cCampos+" FROM "+cFrom+" WHERE "+cWhere+" ORDER BY "+cOrder

IncProc(STR0001)// 1/3 //"Pesquisando Dados..."

cQuery := ChangeQuery( cQuery )
IncProc(STR0001)// 2/3 //"Pesquisando Dados..."

nToT   := RC150TotReg(cQuery)
IncProc(STR0001)// 3/3 //"Pesquisando Dados..."

TcQuery cQuery ALIAS "TRB" NEW
TcSetField("TRB","EF1_DT_JUR","D")
TcSetField("TRB","EF3_DT_EVE","D")
// ACSJ - 05/05/05 - Inicio
TcSetField("TRB","EF1_DT_CON","D")
// --------------- - Fim

Return .T.

/*
Função..: RC150Dbf
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Executa Query para retorno dos dados de impressão
*/
*******************
Function RC150Dbf()
*******************
Local cTipFin := iIF(cTipRel == "ACC","01",iIF(cTipRel == "ACE","02",""))

aEstru := { { "EF1_CONTRA",AVSX3("EF1_CONTRA",2),AVSX3("EF1_CONTRA",3),AVSX3("EF1_CONTRA",4) } }
   IF lEFFTpMod
      aAdd(aEstru, { "EF1_SEQCNT",AVSX3("EF1_SEQCNT",2),AVSX3("EF1_SEQCNT",3),AVSX3("EF1_SEQCNT",4) } )
   ENDIF
   aAdd(aEstru, { "EF1_DT_JUR",AVSX3("EF1_DT_JUR",2),AVSX3("EF1_DT_JUR",3),AVSX3("EF1_DT_JUR",4) } )
   aAdd(aEstru, { "EF3_VL_MOE",AVSX3("EF3_VL_MOE",2),AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4) } )
   aAdd(aEstru, { "EF3_VL_REA",AVSX3("EF3_VL_REA",2),AVSX3("EF3_VL_REA",3),AVSX3("EF3_VL_REA",4) } )
   aAdd(aEstru, { "EF3_MOE_IN",AVSX3("EF3_MOE_IN",2),AVSX3("EF3_MOE_IN",3),AVSX3("EF3_MOE_IN",4) } )
   aAdd(aEstru, { "EF3_DT_EVE",AVSX3("EF3_DT_EVE",2),AVSX3("EF3_DT_EVE",3),AVSX3("EF3_DT_EVE",4) } )
   aAdd(aEstru, { "EF3_CODEVE",AVSX3("EF3_CODEVE",2),AVSX3("EF3_CODEVE",3),AVSX3("EF3_CODEVE",4) } )
   aAdd(aEstru, { "EF1_CC"    ,AVSX3("EF1_CC",    2),AVSX3("EF1_CC",    3),AVSX3("EF1_CC",    4) } )
   aAdd(aEstru, { "EF1_SLD_PR",AVSX3("EF1_SLD_PR",2),AVSX3("EF1_SLD_PR",3),AVSX3("EF1_SLD_PR",4) } )
   aAdd(aEstru, { "EF1_SLD_PM",AVSX3("EF1_SLD_PM",2),AVSX3("EF1_SLD_PM",2),AVSX3("EF1_SLD_PM",4) } )
   aAdd(aEstru, { "EF3_INVOIC",AVSX3("EF3_INVOIC",2),AVSX3("EF3_INVOIC",3),AVSX3("EF3_INVOIC",4) } )
   aAdd(aEstru, { "EF3_TX_MOE",AVSX3("EF3_TX_MOE",2),AVSX3("EF3_TX_MOE",3),AVSX3("EF3_TX_MOE",4) } )
   aAdd(aEstru, { "EF3_TP_EVE",AVSX3("EF3_TP_EVE",2),AVSX3("EF3_TP_EVE",3),AVSX3("EF3_TP_EVE",4) } )
   aAdd(aEstru, { "EF3_DT_CON",AVSX3("EF3_DT_CON",2),AVSX3("EF3_DT_CON",3),AVSX3("EF3_DT_CON",4) } ) 
            
// ACSJ - 02/05/2005 - Inicio
If lTemChave
   aAdd(aEstru,{ "EF1_BAN_FI",AVSX3("EF1_BAN_FI",2),AVSX3("EF1_BAN_FI",3),AVSX3("EF1_BAN_FI",4) } )
   aAdd(aEstru,{ "EF1_PRACA", AVSX3("EF1_PRACA",2), AVSX3("EF1_PRACA",3), AVSX3("EF1_PRACA",4)  } )
Endif                        
// ----------------- - Fim                                                                  
If lAnalit
   aAdd(aEstru,{ "EF3_PREEMB",AVSX3("EF3_PREEMB",2),AVSX3("EF3_PREEMB",3),AVSX3("EF3_PREEMB",4) } )
   aAdd(aEstru,{ "EF3_PARC"  ,IF(lEFFTpMod, AVSX3("EF3_LINHA"  ,2), AVSX3("EF3_PARC"  ,2)),IF(lEFFTpMod, AVSX3("EF3_LINHA"  ,3),AVSX3("EF3_PARC"  ,3)),IF(lEFFTpMod, AVSX3("EF3_LINHA"  ,4),AVSX3("EF3_LINHA"  ,4)) } )
   aAdd(aEstru,{ "EF1_PRACA" ,AVSX3("EF1_PRACA", 2),AVSX3("EF1_PRACA", 3),AVSX3("EF1_PRACA", 4) } )
Endif

//HVR
If lEFFTpMod
   aAdd(aEstru,{ "EF1_TPMODU",AVSX3("EF1_TPMODU",2),AVSX3("EF1_TPMODU",3),AVSX3("EF1_TPMODU",4) } )
Endif                        

Private aCampos:= Array(Len(aEstru))

If Select("TRB") > 0
   TRB->( DBCloseArea() )       
EndIf
cNomArq:= E_CriaTrab("",aEstru,"TRB")
IF lEFFTpMod
   IndRegua("TRB",cNomArq+TEOrdBagExt(),"EF1_TPMODU+EF1_BAN_FI+EF1_CONTRA+EF1_SEQCNT+EF3_CODEVE")
ELSE
   IndRegua("TRB",cNomArq+TEOrdBagExt(),"EF1_BAN_FI+EF1_CONTRA+EF3_CODEVE")
ENDIF
EF1->( dbSetOrder(1) )
EF1->( dbSeek(cFilEF1+cTipFin+IF(lEFFTpMod,cTpMod,"")) )
nCont:=0

If cTipRel     == "ACC"
   bWhile:={|| !EF1->( EoF() ) .AND. EF1->EF1_FILIAL == cFilEF1 .AND. EF1->EF1_TP_FIN == "01" }
   cEventos := "100/600/500/501" //Alcir Alves - 25-07-05 - baixa forçada 660

ElseIf cTipRel == "ACE"
   bWhile:={|| !EF1->( EoF() ) .AND. EF1->EF1_FILIAL == cFilEF1 .AND. EF1->EF1_TP_FIN == "02" }
   cEventos := "100/500/501/600/630/660" //Alcir Alves - 25-07-05 - baixa forçada 660

ElseIf cTipRel == "Provisão de Juros"
   bWhile:={|| !EF1->( EoF() ) .AND. EF1->EF1_FILIAL == cFilEF1 }
   cEventos := "100/520/525/550/551/640/641/642/643/644/645/646/647/648/649/670/671/672/673/674/675/676/677/678/679"

Endif

//Conta Registros
EF1->( dbEval( {|| nCont++ },,bWhile,,,.T.) )

ProcRegua( nCont )

EF1->( dbSetOrder(2) )
IF lEFFTpMod
   IF cParTpMod = 3
      IF EF1->( dbSeek(cFilEF1+cTipFin+"I") ) .OR. EF1->( dbSeek(cFilEF1+cTipFin+"E") ) 
      EndIf
   ELSE
      EF1->( dbSeek(cFilEF1+cTipFin+IF(cParTpMod=1,"I","E")) )
   ENDIF    
ELSE 
   EF1->( dbSeek(cFilEF1+cTipFin))
ENDIF

Do While Eval(bWhile)

   If ( cTipRel == "ACC"  .AND. IF(lEFFTpMod,.T. , EF1->EF1_TP_FIN <> "01")      ).OR.;//Filtro para Relatório ACC
      ( cTipRel == "ACE"  .AND. IF(lEFFTpMod,.T. , EF1->EF1_TP_FIN <> "02")      ).OR.;//Filtro para Relatório ACE
      ( !Empty(cParContra).AND. EF1->EF1_CONTRA == cParContra).OR.;//Filtro por Contrato
      ( !Empty(cParBanco) .AND. EF1->EF1_BAN_FI == cParBanco ).OR.;//Filtro por Banco
      IF(lEFFTpMod, ( !Empty(cParTpMod) .AND. IF(cParTpMod = 3,.T.,IF(cParTpMod = 1,EF1->EF1_TPMODU = "I",EF1->EF1_TPMODU = "E") ) ),.T.).OR.; //Filtro por Modulo //HVR
      ( !Empty(dParFinal) .AND. EF1->EF1_DT_JUR  < dParFinal )     //Filtro por Data Final

      EF1->( dbSkip() )
      Loop
   Endif

   IF lEFFTpMod
      cTpMod  := EF1->EF1_TPMODU //HVR
   ENDIF
   cBanco  := EF1->EF1_BAN_FI
   cContra := EF1->EF1_CONTRA
IF lEFFTpMod
   cSEQCNT := EF1->EF1_SEQCNT
ENdif
   dDtJur  := EF1->EF1_DT_JUR
   
   //EF3_FILIAL+EF3_CONTRA+EF3_INVOIC+EF3_PARC
   EF3->( dbSetOrder(6) )
   EF3->( dbSeek(cFilEF3+IF(lEFFTpMod, cTpMod,"")+cContra+iif(lTemChave,EF1->EF1_BAN_FI+EF1_PRACA, "")+IF(lEFFTpMod,EF1->EF1_SEQCNT,"") ) )
   Do While !EF3->( EoF() ) .AND. EF3->EF3_FILIAL == cFilEF3 .AND. EF3->EF3_CONTRA == cContra .and. ;
            if(lEFFTpMod,EF3->EF3_TPMODU == cTpMod .and. EF3->EF3_SEQCNT = cSEQCNT,.T.) .and. ;
            Iif(lTemChave,EF3->EF3_BAN_FI == EF1->EF1_BAN_FI .and. EF3->EF3_PRACA == EF1->EF1_PRACA, .t.)

      If ( !EF3->EF3_CODEVE $ cEventos                       ).OR.; //Filtro por Data Final
         ( !Empty(dParFinal).AND.EF3->EF3_DT_EVE > dParFinal )      //Filtro por Evento
         
         EF3->( dbSkip() )
         Loop
      Endif

      TRB->( dbAppend() )
      TRB->EF1_BAN_FI := cBanco
      TRB->EF1_CONTRA := cContra
      TRB->EF1_DT_JUR := dDtJur
      
      IF lEFFTpMod
         TRB->EF1_TPMODU := cTpMod
         TRB->EF1_SEQCNT := EF3->EF3_SEQCNT
      EndIf

      TRB->EF3_VL_MOE := EF3->EF3_VL_MOE
      TRB->EF3_VL_REA := EF3->EF3_VL_REA
      TRB->EF3_MOE_IN := EF3->EF3_MOE_IN
      TRB->EF3_DT_EVE := EF3->EF3_DT_EVE
      TRB->EF3_CODEVE := EF3->EF3_CODEVE
      TRB->EF1_SLD_PR := EF1->EF1_SLD_PR
      TRB->EF1_SLD_PM := EF1->EF1_SLD_PR
      
      If lAnalit
         IF lEFFTpMod
            TRB->EF3_PREEMB := IF(EF3->EF3_ORIGEM="SWB", EF3->EF3_HAWB ,EF3->EF3_PREEMB )
            TRB->EF3_PARC   := IF(EF3->EF3_ORIGEM="SWB", EF3->EF3_LINHA,EF3->EF3_PARC )
         ELSE
            TRB->EF3_PREEMB := EF3->EF3_PREEMB
            TRB->EF3_PARC   := EF3->EF3_PARC
         ENDIF
      Endif
      
      nToT++
      EF3->( dbSkip() )
   EndDo
   
   IncProc(STR0001) //"Pesquisando Dados..."
   EF1->( dbSkip() )
EndDo

Return .T.

/*
Função..: RC150Print
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Prepara Impressão SetPrint
*/
*************************
Function RC150Print()
*************************
Local cDesc1         := STR0003 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0004+cTipRel //"de Contratos de Financiamento - "
Local cDesc3         := "", cPict := "", imprime := .T.
Private titulo       := STR0005+iIF(cTipRel=="ACC",STR0047,iIF(cTipRel=="ACE",STR0048,STR0008)) //"Contratos de Financiamento - "###"ACC"###"ACE"###"Provisão de Juros"
Private nPagina      := 0
Private nLin         := 99
Private cString      := "EF1"
Private lAbortPrint  := .F., limite := 220, tamanho := "G"
Private nomeprog     := "EFFRC150"
Private aReturn      := {STR0009, 1,STR0010, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private wnrel        := "EFFRC150"
Private lCancel      := .F.
Private m_pag        := 01

if len(aRel)>0
wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lCancel| RC150Impr()})
else
   msgstop(STR0046)
endif

Return .T. 

/*
Função..: RC150Impr
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Imprimir o Relatório de ACC/ACE
*/
************************
Function RC150Impr()
************************
Local cLastBan  := ""
Local cLastEve  := ""
Local i
Local i2
Local i3   
Local cDtLiqOk
Private cPictVl := AVSX3("EF3_VL_MOE",6)
Private nTamPic := Len(Transform( 1, cPictVl))
Private aColuna := {}
Private cMoe
Private aMoedas := {}
Private nColIni:= 0 //Coluna Inicial
Private nEspaco:= 0 //Espaço entre os campos
Private nRemPict := 0 //Quantos caracteres a remover da Picture

cPictProc := AVSX3("EF3_PREEMB",6)
cPictCont := AVSX3("EF1_CONTRA",6)
IF lEFFTpMod
   cPictSeq  := AVSX3("EF1_SEQCNT",6)
ENDIF
cPictBan  := AVSX3("EF1_BAN_FI",6)
cPictMoe  := AVSX3("EF1_MOEDA" ,6)

SetRegua(Len(aRel))

If cTipRel == "ACC"
   nColIni  := 004 //Coluna Inicial
   nEspaco  := 002 //Espaço entre os campos

   //             Cabec.   Cabec. 2 Tamanho da Coluna     Texto               Picture    Total
   aColuna := { { STR0011 ,""      ,AVSX3("EF1_CONTRA",3),{|x| aRel[x][ 2] }, cPictCont ,      } } //"Contrato"
   IF lEFFTpMod
      aAdd(aColuna,{ STR0050 ,""      ,AVSX3("EF1_SEQCNT",3),{|x| aRel[x][15] }, cPictSeq  ,      } ) //"Seq."
   EndIf
      aAdd(aColuna,{ STR0012 ,""      ,Len(STR0012)         ,{|x| aRel[x][ 3] }, cPictMoe  ,      } ) //"Moeda"###"Moeda"
      aAdd(aColuna,{ STR0013 ,STR0012 ,nTamPic              ,{|x| aRel[x][ 4] }, cPictVl   ,{}    } ) //"Valor"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][ 5] }, cPictVl   ,{}    } ) //"Em Reais"
      //aAdd(aColuna,{ iif(cTipRel= "ACC",;    // ACSJ - 06/05/2005
      //      STR0015,STR0045) ,STR0012 ,nTamPic              ,{|x| aRel[x][ 6] }, cPictVl   ,{}    } ) //"Saldo Ant. a Liquidar"###"Moeda"###"Saldo Ant. a Vincular"
      // PLB 14/09/06
      aAdd(aColuna,{ STR0015 ,STR0012 ,nTamPic              ,{|x| aRel[x][ 6] }, cPictVl   ,{}    } ) //"Saldo Ant. a Vincular"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][ 7] }, cPictVl   ,{}    } ) //"Em Reais"
      aAdd(aColuna,{ STR0016 ,STR0012 ,nTamPic              ,{|x| aRel[x][ 8] }, cPictVl   ,{}    } ) //"Vinculações"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][ 9] }, cPictVl   ,{}    } ) //"Em Reais"
      aAdd(aColuna,{ STR0017 ,STR0014 ,nTamPic              ,{|x| aRel[x][10] }, cPictVl   ,{}    } ) //"Variação Cambial"###"Em Reais"
      aAdd(aColuna,{ STR0018 ,STR0012 ,nTamPic              ,{|x| aRel[x][11] }, cPictVl   ,{}    } ) //"Saldo Atual"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][12] }, cPictVl   ,{}    } ) //"Em Reais"
      aAdd(aColuna,{ STR0019 ,""      ,AVSX3("EF1_DT_JUR",3),{|x| aRel[x][13] }, ""        ,      } ) //"Inic. Juros"

   cStrProc := STR0035 //"Processo"
   cStrParc := STR0036 //"Parcela"
   cStrMoe  := STR0037 //"Moeda"
   cStrVal  := STR0038 //"Valor"
   cStrVinc := STR0039 //"Vl. Vinculado em "

                                  	
   //              Cabeçalho      Tamanho do Texto      Texto                      Picture
   aAnalit := { { "cStrProc"     ,AVSX3("EF3_PREEMB",3),{|x,y| aRel[x][Len(aRel[i])][y][1] },cPictProc           ,.f.},;
                { "cStrParc"     ,IF(lEFFTpMod, AVSX3("EF3_LINHA" ,3),AVSX3("EF3_PARC" ,3)),{|x,y| aRel[x][Len(aRel[i])][y][2] },IF(lEFFTpMod, AVSX3("EF3_LINHA",6), AVSX3("EF3_PARC",6)),.f.},;
                { "cStrMoe"      ,AVSX3("EEC_MOEDA" ,3),{|x,y| aRel[x][Len(aRel[i])][y][3] },AVSX3("EEC_MOEDA",6),.f.},;
                { "cStrVal"      ,nTamPic              ,{|x,y| aRel[x][Len(aRel[i])][y][4] },cPictVl             ,.f.},;
                { "cStrVinc+cMoe",nTamPic              ,{|x,y| aRel[x][Len(aRel[i])][y][5] },cPictVl             ,.f.} }
                  
                

ElseIf cTipRel == "ACE"
   nColIni  := 004 //Coluna Inicial
   nEspaco  := 001 //Espaço entre os campos
   nRemPict := 004 //Quantos caracteres a remover da Picture
   
   cPictVl := "@E "+SubStr(cPictVl,4+nRemPict)//@E 999,999,999.99
   nTamPic:= Len(Transform( 1, cPictVl))

   //             Cabec.   Cabec. 2 Tamanho da Coluna     Texto               Picture    Total
   aColuna := { { STR0011 ,""      ,AVSX3("EF1_CONTRA",3),{|x| aRel[x][ 2] }, cPictCont ,      } } //"Contrato"
   IF lEFFTpMod
      aAdd(aColuna,{ STR0050 ,""      ,AVSX3("EF1_SEQCNT",3),{|x| aRel[x][19] }, cPictSeq  ,      } ) //"Seq."
   ENDIF
      aAdd(aColuna,{ STR0012 ,""      ,Len(STR0012)         ,{|x| aRel[x][ 3] }, cPictMoe  ,      } ) //"Moeda"###"Moeda"
      aAdd(aColuna,{ STR0013 ,STR0012 ,nTamPic              ,{|x| aRel[x][ 4] }, cPictVl   ,{}    } ) //"Valor"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][ 5] }, cPictVl   ,{}    } ) //"Em Reais"
      aAdd(aColuna,{ STR0045 ,STR0012 ,nTamPic              ,{|x| aRel[x][ 6] }, cPictVl   ,{}    } ) //"Saldo Anterior"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][ 7] }, cPictVl   ,{}    } ) //"Em Reais"
      aAdd(aColuna,{ STR0016 ,STR0012 ,nTamPic              ,{|x| aRel[x][ 8] }, cPictVl   ,{}    } ) //"Vinculações"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][ 9] }, cPictVl   ,{}    } ) //"Em Reais"
      aAdd(aColuna,{ STR0020 ,STR0012 ,nTamPic              ,{|x| aRel[x][10] }, cPictVl   ,{}    } ) //"Liquidação"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][11] }, cPictVl   ,{}    } ) //"Em Reais"
      aAdd(aColuna,{ STR0017 ,STR0014 ,nTamPic              ,{|x| aRel[x][12] }, cPictVl   ,{}    } ) //"Variação Cambial"###"Em Reais"
      aAdd(aColuna,{ STR0018 ,STR0012 ,nTamPic              ,{|x| aRel[x][13] }, cPictVl   ,{}    } ) //"Saldo Atual"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][14] }, cPictVl   ,{}    } ) //"Em Reais"
      aAdd(aColuna,{ STR0021 ,""      ,AVSX3("EF1_DT_JUR",3),{|x| aRel[x][15] }, ""        ,      } ) //"Ini. Juros"
                

   cStrProc := STR0035 //"Processo"
   cStrParc := STR0036 //"Parcela"
   cStrMoe  := STR0037 //"Moeda"
   cStrVal  := STR0038 //"Valor"
   cStrVinc := STR0039 //"Vl. Vinculado em "
   cStrLiq  := STR0040 // Vl. Liquidado
   cStrDtLiq:= STR0041 // Dt. Liquidação                 
   
   //              Cabeçalho      Tamanho do Texto      Texto                      Picture
   aAnalit := { { "cStrProc"     ,AVSX3("EF3_PREEMB",3),{|x,y| aRel[x][Len(aRel[i])][y][1] },cPictProc           ,.f.},;
                { "cStrParc"     ,IF(lEFFTpMod, AVSX3("EF3_LINHA" ,3),AVSX3("EF3_PARC",3)),{|x,y| aRel[x][Len(aRel[i])][y][2] },IF(lEFFTpMod, AVSX3("EF3_LINHA",6), AVSX3("EF3_PARC",6)),.f.},;
                { "cStrMoe"      ,AVSX3("EEC_MOEDA" ,3),{|x,y| aRel[x][Len(aRel[i])][y][3] },AVSX3("EEC_MOEDA",6),.f.},;
                { "cStrVal"      ,nTamPic              ,{|x,y| aRel[x][Len(aRel[i])][y][4] },cPictVl             ,.f.},;
                { "cStrLiq+cMoe" ,nTamPic              ,{|x,y| aRel[x][Len(aRel[i])][y][6] },cPictVl             ,.f.},;
                { "cStrLiq"      ,nTamPic                   ,{|x,y| aRel[x][Len(aRel[i])][y][7] },cPictVl             ,.f.},;                               
                { "cStrDtLiq"    ,100                  ,{|x,y| aRel[x][Len(aRel[i])][y][8] },"@!",.t.} } 

ElseIf cTipRel == "Provisão de Juros"
   nColIni  := 002 //Coluna Inicial
   nEspaco  := 001 //Espaço entre os campos
   nRemPict := 006 //Quantos caracteres a remover da Picture

   cPictVl2 := "@E "+SubStr(cPictVl,4+nRemPict)//@E 999,999,999.99
   nTamPic2 := Len(Transform( 1, cPictVl2))

   //             Cabec.   Cabec. 2 Tamanho da Coluna     Texto               Picture    Total
   aColuna := { { STR0011 ,""      ,AVSX3("EF1_CONTRA",3),{|x| aRel[x][ 2] }, cPictCont ,   } } //"Contrato"
   IF lEFFTpMod
      aAdd(aColuna,{ STR0050 ,""      ,AVSX3("EF1_SEQCNT",3),{|x| aRel[x][19] }, cPictSeq  ,   } ) //"Seq."
   ENDIF
      aAdd(aColuna,{ STR0012 ,""      ,AVSX3("EF1_MOEDA" ,3),{|x| aRel[x][ 3] }, cPictMoe  ,   } ) //"Moeda"
      aAdd(aColuna,{ STR0013 ,STR0012 ,nTamPic              ,{|x| aRel[x][ 4] }, cPictVl   ,{} } ) //"Valor"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic              ,{|x| aRel[x][ 5] }, cPictVl   ,{} } ) //"Em Reais"
      aAdd(aColuna,{ STR0015 ,STR0012 ,nTamPic2             ,{|x| aRel[x][ 6] }, cPictVl2  ,{} } ) //"Saldo Anterior"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic2             ,{|x| aRel[x][ 7] }, cPictVl2  ,{} } ) //"Em Reais"
      aAdd(aColuna,{ STR0008 ,STR0012 ,nTamPic2             ,{|x| aRel[x][ 8] }, cPictVl2  ,{} } ) //"Provisão de Juros"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic2             ,{|x| aRel[x][ 9] }, cPictVl2  ,{} } ) //"Em Reais"
      aAdd(aColuna,{ STR0022 ,STR0012 ,nTamPic2             ,{|x| aRel[x][10] }, cPictVl2  ,{} } ) //"Estorno de Juros"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic2             ,{|x| aRel[x][11] }, cPictVl2  ,{} } ) //"Em Reais"
      aAdd(aColuna,{ STR0023 ,STR0012 ,nTamPic2             ,{|x| aRel[x][12] }, cPictVl2  ,{} } ) //"Liquidação de Juros"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic2             ,{|x| aRel[x][13] }, cPictVl2  ,{} } ) //"Em Reais"
      aAdd(aColuna,{ STR0024 ,STR0014 ,nTamPic2             ,{|x| aRel[x][14] }, cPictVl2  ,{} } ) //"Var. Cambial"###"Em Reais"
      aAdd(aColuna,{ STR0018 ,STR0012 ,nTamPic2             ,{|x| aRel[x][15] }, cPictVl2  ,{} } ) //"Saldo Atual"###"Moeda"
      aAdd(aColuna,{         ,STR0014 ,nTamPic2             ,{|x| aRel[x][16] }, cPictVl2  ,{} } ) //"Em Reais"
      aAdd(aColuna,{ STR0021 ,""      ,AVSX3("EF1_DT_JUR",3),{|x| aRel[x][17] }, ""        ,   } ) //"Ini. Juros"

Endif
       IF lEFFTpMod
         IF cTipRel $ "ACC"
         	nRelPraca := 16
         	nRelTpMod := 14
         Else
         	nRelPraca := 20
         	nRelTpMod := 18
         Endif     
       ENDIF

Begin Sequence
   
   For i:= 1 To Len(aRel)
      
      If lCancel
         BREAK
      Endif
      
      If nLin > 56
         //Imprime cabeçalho 
         RC150RlCab()
         //nLin := 8
      Endif

//BANCO
      If i == 1 .OR. aRel[i][nRelBanco] <> aRel[i-1][nRelBanco] .OR. IF(lEFFTpMod, aRel[i][nRelTpMod] <> aRel[i-1][nRelTpMod], .F.)
         If nLin > 11 .OR. nPagina > 1
            RC150ImpTotal(i)
         Endif
      Endif
      
//Imprime o Modulo                    
   IF lEFFTpMod

      If i == 1 .OR. aRel[i][nRelTpMod] <> aRel[i-1][nRelTpMod]
         If nLin > 11 .OR. nPagina > 1
            RC150ImpTotal(i-1,.T.) 
         ENDIF

         IF nLin > 15 .OR. nPagina > 1 //HVR
            //Imprime cabeçalho 
            RC150RlCab()
            //nLin := 8
         Endif

         //Imprime o Modulo
         @ nLin,0 PSay STR0049+" - "+IF(aRel[i][nRelTpMod]="I","Importação","Exportação")//"Módulo: "
         nLin++
         @ nLin, 00 PSay __PrtThinLine()
         nLin++

         IF aRel[i][nRelTpMod]="I"
            aMoedas := {}
         ENDIF
      Endif    
   ENDIF

//BANCO
      If i == 1 .OR. aRel[i][nRelBanco] <> aRel[i-1][nRelBanco] .OR. IF(lEFFTpMod, aRel[i][nRelTpMod] <> aRel[i-1][nRelTpMod], .F.)
         //Imprime o Banco
         @ nLin,0 PSay STR0025 + aRel[i][nRelBanco]+"-"+posicione("SA6",1,XFILIAL("SA6")+aRel[i][nRelBanco],"A6_NOME")+IF(lEFFTpMod, " Praça: "+aRel[i][nRelPraca],"") //"Banco: "+ Praca
         nLin++
      Endif


      //Imprime os dados do Contrato
      RC150ImpLin(i)
      nLin++                                                                    

      
// ACSJ - 22/04/2005 - Inicio       
//Mostra o saldo atual de ACC somente quando for ACE
      If cTipRel == "ACE"
         @nLin,4 PSay STR0044  // Saldo Atual ACC
         @nLin,028 PSay Transform(aRel[i,16],cPictVl)
         @nLin,044 PSay Transform(aRel[i,17],cPictVl)
         nLin++
      Endif
// ----------------- - Fim
      
      If lAnalit
         For i2:= 1 To Len(aRel[i][Len(aRel[i])])
            If i2 == 1
               cMoe := aRel[i][nRelMoeda]
               RC150RlCab(.T.)
            Endif

            nColuna := nColIni * 2
            For i3:= 1 To Len(aAnalit)
               cSay := Transform( Eval(aAnalit[i3][3],i,i2), aAnalit[i3][4] )

               If Len(cSay) > 0
                  @ nLin,nColuna+10 PSay cSay
               Endif

               //Soma o Espaco Impresso
               nColuna += iIF( Len(cSay) > Len(&(aAnalit[i3][1])), Len(cSay), Len(&(aAnalit[i3][1])) ) + nEspaco
            Next

            nLin++
         Next
         //nLin++
      Endif
      nLin++
      IncRegua()
   Next
   
   //Imprime o Total do Ultimo Banco
   RC150ImpTotal(i-1)

   //Imprime o Total do Módulo
   RC150ImpTotal(i-1,.T.) 

   
   Set Printer To
   OurSpool(wnrel)

End Sequence

MS_FLUSH()

Return .T.       

/*
Função..: RC150ImpTotal
Autor...: Alessandro Alves Ferreira - AAF
Data....: 14/10/04
Objetivo: Imprimir Totais do Relatório
*/
Function RC150ImpTotal(nContr, lGeral)
Local i2
If !lGeral
   //Imprime o Total por Banco por Moeda
   @ nLin,0 PSay STR0026 //"Total do Banco: "
   For i2:= 1 To Len(aMoedas)
      nCol    := nColIni
      nPosMoe := aScan(aColuna,{|X| X[1] == STR0012})//"Moeda"
      aEval(aColuna,{|X,Y| iIF( Y < nPosMoe , nCol += aColuna[Y][3]+nEspaco,.F.) }) 

      @ nLin,nCol PSay Transform( aMoedas[i2], aColuna[nPosMoe][5] )
      RC150ImpLin(nContr,.T.,aMoedas[i2])

      nLin++
   Next

   @ nLin,0 PSay __PrtThinLine()
   nLin++
Else
   //Imprime o Total Geral por Moeda
   nLin++
   @ nLin,( 220 / 2 ) - ( Len(STR0051+STR0049) / 2 ) PSay STR0051+STR0049 //"Total Módulo"
   nLin++
   @ nLin,0 PSay __PrtThinLine()
   nLin++
      
   For i2:= 1 To Len(aMoedas)
      nCol    := nColIni
      nPosMoe := aScan(aColuna,{|X| X[1] == STR0012}) //"Moeda"
      aEval(aColuna,{|X,Y| iIF( Y < nPosMoe , nCol += aColuna[Y][3]+nEspaco,.F.) })

      @ nLin,nCol PSay Transform( aMoedas[i2], aColuna[nPosMoe][5] )
      RC150ImpLin(nContr,.T.,aMoedas[i2],.T.)

      nLin++
   Next

   @ nLin,0 PSay __PrtThinLine()
Endif

//aMoedas:={}
//aColuna:={}

Return .T.

/*
Função..: RC150ImpLin
Autor...: Alessandro Alves Ferreira - AAF
Data....: 14/10/04
Objetivo: Imprimir uma Linha no Relatório de acordo com o aColuna
*/
Function RC150ImpLin(nContr, lTotal, cMoeda, lGeral)
Local i
Default lTotal := .F.
Default lGeral := .F.

nColuna := nColIni
For i:= 1 To Len(aColuna)
   If aColuna[i][4] <> NIL
      cSay:= ""
           
      If lTotal
         nPos:= aScan(aColuna[i][6],{|X| X[1] == cMoeda})
         If nPos > 0
            If lGeral
               //Imprimi o Total Geral
               cSay := Transform( aColuna[i][6][nPos][3], aColuna[i][5] )            
            Else
               //Imprimi o Total por Banco
               cSay := Transform( aColuna[i][6][nPos][2], aColuna[i][5] )
            Endif
         Endif
      Else
         //Imprimi o Texto- Texto                Picture
         cSay := Transform( Eval(aColuna[i][4],nContr), aColuna[i][5] )
      Endif
      
      //Soma a Diferença entre o tamanho da coluna e tamanho do texto
      //Em caso de campo numérico. Para Imprimir alinhado a direita
      If ValType(Eval(aColuna[i][4],nContr)) $ "N"
         nColuna += RC150TamCol(i,"Cabeçalho") - aColuna[i][3]
      Endif
      
      If Len(cSay) > 0
         @ nLin,nColuna PSay cSay
      Endif

      //Soma a Diferença entre o tamanho da coluna e tamanho do texto
      //Em caso de campo caracter. Para acertar a diferença para a proxima coluna.
      If ValType(Eval(aColuna[i][4],nContr)) $ "C"
         nColuna += RC150TamCol(i,"Cabeçalho") - aColuna[i][3]
      Endif

      //Soma o Espaco Impresso nessa coluna
      nColuna += aColuna[i][3] + nEspaco
            
      //Acumula o Total da Coluna
      If !lTotal
         If ValType(aColuna[i][6]) == "A"
            nPos    := aScan(aColuna[i][6],{|X| X[1] == aRel[nContr][nRelMoeda]})
            nPosMoe := aScan(aMoedas,aRel[nContr][nRelMoeda])
            
            //Adiciona no Array de Moedas
            If nPosMoe == 0
               aAdd( aMoedas,aRel[nContr][nRelMoeda])
            Endif
            
            //Adiciona no Total da Coluna
            If nPos == 0
               aAdd( aColuna[i][6],{ aRel[nContr][nRelMoeda] , Eval(aColuna[i][4],nContr), 0 })
            Else
               aColuna[i][6][nPos][2] += Eval(aColuna[i][4],nContr)
            Endif
            
         Endif
      Else
         If aColuna[i][6] <> NIL
            //Acumula Total Geral
            If !lGeral
               aColuna[i][6][nPos][3] += aColuna[i][6][nPos][2]
            Else
               aColuna[i][6][nPos][3] := 0
            Endif
            
            aColuna[i][6][nPos][2] := 0
         Endif
      Endif
      
   Endif
Next

Return .T.

/*
Função..: RC150RlCab
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Imprimir o Cabeçalho do Relatório
*/
***************************
Function RC150RlCab(lSubCab)
***************************
Local i 
Default lSubCab := .F.
Private lProcSim:=.F.

If lSubCab
   //Cabeçalho de processos
   nColuna := nColIni * 4
   For i:= 1 to Len(aAnalit)

      nColFim := nColuna+iIF(Len(&(aAnalit[i][1])) > aAnalit[i][2],Len(&(aAnalit[i][1])),aAnalit[i][2])
      lProcSim:=.T.
      RC150ImpCen(nLin,nColuna,nColFim,&(aAnalit[i][1]),aAnalit[i][5],lProcSim)
      nColuna := nColFim+nEspaco

   Next      
   nLin++
Else
/*   nPagina ++
   cTitPag := "Pagina " + StrZero(nPagina,4,0)
   @ 00, 00 PSay __PrtFatline()
   @ 01, 00 PSay DtoC(Date())+" "+Time()//Data e Hora
   @ 01, ( 220 / 2 ) - ( Len(titulo) / 2 ) PSay titulo
   @ 01, 220 - Len(cTitPag) PSay cTitPag
   @ 02, 00 PSay __PrtFatline()
   If cTipRel $ "ACC/ACE"
      @ 03, 04 PSay STR0028+iIF(lAnalit,STR0029,STR0030)+STR0031+DtoC(dParIni)+STR0032+DtoC(dParFinal) //"Relatório "###"Analítico"###"Sintético"###". Periodo de "###" até "
   Else
      @ 03, 04 PSay STR0033+DtoC(dParIni)+STR0032+DtoC(dParFinal) //" Periodo de "###" até "
   Endif
*/   
   // PLB 14/09/06 - Alteração para impressao de cabecalho pela funcao Cabec()
   If cTipRel $ "ACC/ACE"
      cPeriodo := STR0028+iIF(lAnalit,STR0029,STR0030)+STR0031+DtoC(dParIni)+STR0032+DtoC(dParFinal) //"Relatório "###"Analítico"###"Sintético"###". Periodo de "###" até "
   Else
      cPeriodo := STR0033+DtoC(dParIni)+STR0032+DtoC(dParFinal) //" Periodo de "###" até "
   Endif
   nLin := Cabec(titulo,cPeriodo,"",wnrel,tamanho) + 1

   //Cabeçalho
   //Primeira Linha
   //-----------------------------------------------------------------------------------
   nColuna := nColIni
   For i:= 1 to Len(aColuna)
      If aColuna[i][1] <> NIL
         nTamCol := RC150TamCol(i,"Cabeçalho")
         
         //aEval(aColuna,{|X,Y| iIF( Y < i , nColuna += aColuna[Y][3]+nEspaco,.F.) })
         nColFim := nColuna+nTamCol
         If i < Len(aColuna) .AND. aColuna[i+1][1] == NIL
            //Pega o Tamanho da Proxima Coluna caso ela não tenha Titulo de cabeçalho
            nColFim += nEspaco+RC150TamCol(i+1)
         Endif
         lProcSim:=.F.
         //RC150ImpCen(05,nColuna,nColFim,aColuna[i][1],lProcSim)
         RC150ImpCen(nLin,nColuna,nColFim,aColuna[i][1],lProcSim)
         nColuna := nColFim+nEspaco
      Endif
   Next
   //-----------------------------------------------------------------------------------
   //Segunda Linha
   nLin++
   nColuna := nColIni
   For i:= 1 to Len(aColuna)
      If aColuna[i][2] <> NIL
         //aEval(aColuna,{|X,Y| iIF( Y < i , nColuna += aColuna[Y][3]+nEspaco,.F.) })
         nColFim := nColuna+RC150TamCol(i,"Cabeçalho2")
         
         If aColuna[i][1] <> NIL 
            nColFim += RC150TamCol(i,"Cabeçalho") - aColuna[i][3]
         Endif 

         If i < Len(aColuna) .AND. aColuna[i+1][2] == NIL
            nColFim += nEspaco+RC150TamCol(i+1,"Cabeçalho2")
         Endif
         lProcSim:=.F.
         //RC150ImpCen(06,nColuna,nColFim,aColuna[i][2],lProcSim)
         RC150ImpCen(nLin,nColuna,nColFim,aColuna[i][2],lProcSim)

         nColuna := nColFim + nEspaco
      Endif
   Next
   nLin++
   //-----------------------------------------------------------------------------------
   @ nLin, 00 PSay __PrtThinLine()
   nLin++
Endif

Return .T.

/*
Função..: RC150TamCol
Autor...: Alessandro Alves Ferreira - AAF
Data....: 18/10/04
Objetivo: Retornar o Tamanho da Coluna
*/
***********************************
Function RC150TamCol(nCol,cCab)
***********************************
Local nRet   := aColuna[nCol][3]
Local cTexto := iIF(cCab == "Cabeçalho2",aColuna[nCol][2],aColuna[nCol][1])

If cTexto <> NIL .AND. Len(cTexto) > aColuna[nCol][3]
   If nCol < Len(aColuna) .AND. aColuna[nCol+1][1] == NIL
      //No caso da proxima coluna ser nil, calcula o espaco da outra coluna para junção
      //das colunas.
      If Len(cTexto) > aColuna[nCol][3]+aColuna[nCol+1][3]
         nRet:= Len(cTexto)         
      Endif
   Else
      nRet:= Len(cTexto)   
   Endif
Endif

Return nRet

/*
Função..: RC150DBFImp
Autor...: Alessandro Alves Ferreira - AAF
Data....: 05/10/04
Objetivo: Gera work com o relatório para exportar ao Excel
          ou salvar arquivo DBF/TXT
*/
*------------------------------------------*
Function RC150DbfImp(lExcel)
*------------------------------------------*
Local i
Local i2
Local cArquivo := CriaTrab(,.F.)
Local oExcelApp
Private cArqRc150 //THTS - 25/09/2017 - Utilizado para criacao de temporario

cDirDocs := MsDocPath()
cPath	:= AllTrim(GetTempPath())

aEstru:= {}
If cTipRel == "ACC"

   aColuna := { { "BANCO"     ,AVSX3("EF1_BAN_FI", 02), AVSX3("EF1_BAN_FI", 03), AVSX3("EF1_BAN_FI", 04),{|x| aRel[x][ 1] } } }
   IF lEFFTpMod
      aAdd(aColuna,{ "PRACA   "  ,AVSX3("EF1_PRACA" , 02), AVSX3("EF1_PRACA" , 03), AVSX3("EF1_PRACA" , 04),{|x| aRel[x][16] } } ) //HVR
   ENDIF   
   aAdd(aColuna,{ "CONTRATO"  ,AVSX3("EF1_CONTRA", 02), AVSX3("EF1_CONTRA", 03), AVSX3("EF1_CONTRA", 04),{|x| aRel[x][ 2] } } )
   IF lEFFTpMod
      aAdd(aColuna,{ "SEQCNT"    ,AVSX3("EF1_SEQCNT", 02), AVSX3("EF1_SEQCNT", 03), AVSX3("EF1_SEQCNT", 04),{|x| aRel[x][15]} } ) //HVR
   ENDIF
   aAdd(aColuna,{ "MOEDA"     ,AVSX3("EF1_MOEDA" , 02), AVSX3("EF1_MOEDA" , 03), AVSX3("EF1_MOEDA" , 04),{|x| aRel[x][ 3]} } )
   aAdd(aColuna,{ "VALOR"     ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 4]} } )
   aAdd(aColuna,{ "VALORRS"   ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 5]} } )
   aAdd(aColuna,{ "SLD_ANTE"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 6]} } )
   aAdd(aColuna,{ "SLD_ANTERS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 7]} } )
   aAdd(aColuna,{ "VINCULAD"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 8]} } )
   aAdd(aColuna,{ "VINCULADRS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 9]} } )
   aAdd(aColuna,{ "VAR_CAMBIA",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][10]} } )
   aAdd(aColuna,{ "SLD_ATU"   ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][11]} } )
   aAdd(aColuna,{ "SLD_ATU_RS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][12]} } ) 
   aAdd(aColuna,{ "INI_JUROS" ,AVSX3("EF1_DT_JUR", 02), AVSX3("EF1_DT_JUR", 03), AVSX3("EF1_DT_JUR", 04),{|x| aRel[x][13]} } ) 


ElseIf cTipRel == "ACE"
 
   aColuna := { { "BANCO"     ,AVSX3("EF1_BAN_FI", 02), AVSX3("EF1_BAN_FI", 03), AVSX3("EF1_BAN_FI", 04),{|x| aRel[x][ 1] } } }
   IF lEFFTpMod
      aAdd(aColuna,{ "PRACA   "  ,AVSX3("EF1_PRACA" , 02), AVSX3("EF1_PRACA" , 03), AVSX3("EF1_PRACA" , 04),{|x| aRel[x][20] } } ) //HVR
   ENDIF   
      aAdd(aColuna,{ "CONTRATO"  ,AVSX3("EF1_CONTRA", 02), AVSX3("EF1_CONTRA", 03), AVSX3("EF1_CONTRA", 04),{|x| aRel[x][ 2] } } )
   IF lEFFTpMod
      aAdd(aColuna,{ "SEQCNT"    ,AVSX3("EF1_SEQCNT", 02), AVSX3("EF1_SEQCNT", 03), AVSX3("EF1_SEQCNT", 04),{|x| aRel[x][19]} } ) //HVR
   ENDIF
   aAdd(aColuna,{ "MOEDA"     ,AVSX3("EF1_MOEDA" , 02), AVSX3("EF1_MOEDA" , 03), AVSX3("EF1_MOEDA" , 04),{|x| aRel[x][ 3] } } ) 
   aAdd(aColuna,{ "VALOR"     ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 4] } } ) 
   aAdd(aColuna,{ "VALORRS"   ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 5] } } ) 
   aAdd(aColuna,{ "SLD_ANTE"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 6] } } ) 
   aAdd(aColuna,{ "SLD_ANTERS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 7] } } ) 
   aAdd(aColuna,{ "VINCULAD"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 8] } } ) 
   aAdd(aColuna,{ "VINCULADRS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 9] } } ) 
   aAdd(aColuna,{ "LIQUIDAD"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][10] } } ) 
   aAdd(aColuna,{ "LIQUIDADRS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][11] } } ) 
   aAdd(aColuna,{ "VAR_CAMBIA",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][12] } } ) 
   aAdd(aColuna,{ "SLD_ATU"   ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][13] } } ) 
   aAdd(aColuna,{ "SLD_ATU_RS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][14] } } ) 
   aAdd(aColuna,{ "INI_JUROS" ,AVSX3("EF1_DT_JUR", 02), AVSX3("EF1_DT_JUR", 03), AVSX3("EF1_DT_JUR", 04),{|x| aRel[x][15] } } ) 

ElseIf cTipRel == "Provisão de Juros"

   aColuna := { { "BANCO"     ,AVSX3("EF1_BAN_FI", 02), AVSX3("EF1_BAN_FI", 03), AVSX3("EF1_BAN_FI", 04),{|x| aRel[x][ 1] } } } 

   IF lEFFTpMod
      aAdd(aColuna,{ "PRACA   "  ,AVSX3("EF1_PRACA" , 02), AVSX3("EF1_PRACA" , 03), AVSX3("EF1_PRACA" , 04),{|x| aRel[x][18] } } ) //HVR
   ENDIF

   aAdd(aColuna,{ "CONTRATO"  ,AVSX3("EF1_CONTRA", 02), AVSX3("EF1_CONTRA", 03), AVSX3("EF1_CONTRA", 04),{|x| aRel[x][ 2] } } )

   IF lEFFTpMod
         aAdd(aColuna,{ "SEQCNT"    ,AVSX3("EF1_SEQCNT", 02), AVSX3("EF1_SEQCNT", 03), AVSX3("EF1_SEQCNT", 04),{|x| aRel[x][19] } } ) //HVR
   ENDIF
   
   aAdd(aColuna,{ "MOEDA"     ,AVSX3("EF1_MOEDA" , 02), AVSX3("EF1_MOEDA" , 03), AVSX3("EF1_MOEDA" , 04),{|x| aRel[x][ 3] } } )
   aAdd(aColuna,{ "VALOR"     ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 4] } } )
   aAdd(aColuna,{ "VALORRS"   ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 5] } } )
   aAdd(aColuna,{ "SLD_ANTE"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 6] } } )
   aAdd(aColuna,{ "SLD_ANTERS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 7] } } )
   aAdd(aColuna,{ "PR_JUROS"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 8] } } )
   aAdd(aColuna,{ "PR_JUROSRS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][ 9] } } )
   aAdd(aColuna,{ "ES_JUROS"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][10] } } )
   aAdd(aColuna,{ "ES_JUROSRS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][11] } } )
   aAdd(aColuna,{ "LQ_JUROS"  ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][12] } } )
   aAdd(aColuna,{ "LQ_JUROSRS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][13] } } )
   aAdd(aColuna,{ "VAR_CAMBIA",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][14] } } )
   aAdd(aColuna,{ "SLD_ATU"   ,AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][15] } } )
   aAdd(aColuna,{ "SLD_ATU_RS",AVSX3("EF1_VL_MOE", 02), AVSX3("EF1_VL_MOE", 03), AVSX3("EF1_VL_MOE", 04),{|x| aRel[x][16] } } )
   aAdd(aColuna,{ "INI_JUROS" ,AVSX3("EF1_DT_JUR", 02), AVSX3("EF1_DT_JUR", 03), AVSX3("EF1_DT_JUR", 04),{|x| aRel[x][17] } } )

Endif

//26/05/2022 - Ponto de Entrada para adicionar dados no array aColunas
IF(EasyEntryPoint("EFFRC150"),Execblock("EFFRC150",.F.,.F.,"ADD_COLUNAS"),)

//Monta Estrutura
aEstru:= {}
For i:= 1 To Len(aColuna)
   aAdd(aEstru,{ aColuna[i][1], aColuna[i][2], aColuna[i][3], aColuna[i][4] } )
Next

cArqRc150 := E_CriaTrab(,aEstru,cArquivo) //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados

For i := 1 To Len(aRel)

   (cArquivo)->( dbAppend() )
   For i2:= 1 To Len(aColuna)
       (cArquivo)->( FieldPut(i2, Eval(aColuna[i2][5],i) ) )
   Next
   (cArquivo)->( dbCommit() )
Next

if lExcel
/**SVG** - 03/03/2009 - Condição para adequação a esportação utilizando Ctree*/
   cArqOrigem := cArquivo
   cAlias     := cArquivo
   lXml       := .F.   
   
   AvExcel(cArqOrigem,cAlias,lXml)
 /*
   (cArquivo)->( dbCloseArea() )
   CpyS2T( cDirDocs+"\"+cArquivo+".DBF" , cPath, .T. )

   //Envia ao Excel
   If ! ApOleClient( 'MsExcel' )
      MsgStop(STR0034) //"MsExcel não instalado."
      RETURN .F.
   Else
      //Abre Dbf no Excel
      oExcelApp:= MsExcel():New()
      oExcelApp:WorkBooks:Open( cPath+cArquivo+".dbf" )
      oExcelApp:SetVisible(.T.)
   EndIf
*/
Else
   //Abre para criacao do arquivo TXT/DBF 
   TR350ARQUIVO(cArquivo)
   (cArquivo)->( dbCloseArea() )
endif
Erase(cArquivo+TEOrdBagExt())
Return .T.

/*
Função..: RC150ImpCen
Autor...: Alessandro Alves Ferreira - AAF
Data....: 06/10/04
Objetivo: Imprimir texto centralizado entre duas colunas
*/
Function RC150ImpCen(nLinha,nColIni,nColFim,cTexto,lNCentral,lImpProc)

Local nCol

Default lNCentral := .F.
Default lImpProc  := .F.

If ValType(cTexto) <> "C"
   cTexto := ""
Endif

If Len(cTexto) >= nColFim - nColIni .or. lNCentral
   nCol := nColIni
Else
   nCol := Round( ( nColIni + nColFim) / 2 ,0) - Round( Len(cTexto) / 2 ,0 ) //Posicão Para Imprimir no Centro entre as duas colunas
Endif

cSay := Replicate(" ", nCol - nColIni)
If Len(cSay) > 0
   @ nLinha, nColIni PSay cSay          //Imprimi traços antes do Texto
Endif

IF lImpProc
   @ nLinha, nCol             PSay cTexto  //Imprimi o Texto Sem Negrito para Cabeçalho de Processo
ELSE
   @ nLinha, nCol             PSay cTexto //__PrtCenter(cTexto)  //Imprimi o Texto em Negrito 
ENDIF

If Len(cSay) > 0
   cSay := Replicate(" ", nColFim - (nCol+Len(cTexto)))
   @ nLinha, nCol+Len(cTexto) PSay cSay //Imprimi traços depois do Texto
Endif

Return .T.

/*
Função..: RC150TotReg
Autor...: Alessandro Alves Ferreira - AAF
Data....: 08/10/04
Objetivo: Retornar o Numero de Registros retornados em uma Query
*/
Function RC150TotReg(cQuery)
Local nTotalReg

If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

cQuery := SubStr(cQuery,1,RAt("ORDER BY",cQuery) - 1)

//Total de Registros
cQuery = ChangeQuery("SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") TEMP")
TcQuery cQuery ALIAS "TOTALREG" NEW

nTotalReg:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

Return nTotalReg
// -------------------------------
// Calcula Variação cambial no ECA 
FUNCTION RC150CALCECA(PTipo,PContra,PBanco,PPraca,nTip)
// --------------------------------
// ACSJ - 22/04/2005 - Inicio
// Pequisa variação cambial no ECA                        
Local i:=0
LOCAL aRet  := {}
Local ni:=1
local nfim:=1
PRIVATE cTipo := ""

Aadd(aRet,0)
Aadd(aRet,0)
ECA->(DBSetOrder(10))
If PTipo == "ACC"
   cTipo := "FIEX01"
   ni:=1
   nfim:=1
Elseif PTipo == "ACE"
   cTipo := "FIEX02"
   ni:=2
   nfim:=2

Else // Provisão de Juros.
   cTipo:="PJUROS"
   //Return aRet
   ni:=1
   nfim:=2
Endif

if nTip==1 //variacao cambial                                      
for i:=ni to nFim
cTipo="FIEX0"+alltrim(str(i))
ECA->( DBSeek( cFilECA + cTipo + PContra ) )
Do While ECA->ECA_FILIAL == cFilECA .and. (ECA->ECA_TPMODU == cTipo) .and.;
         ECA->ECA_CONTRA == PContra .and. .not. ECA->(EoF())
   If ECA->ECA_BANCO == PBanco .or. ECA->ECA_PRACA == PPraca
      If ECA->ECA_DT_CON <= dParFinal .or. Empty(dParFinal)
         If (ECA->ECA_ID_CAM $ "550/551") .and. iif(PTipo <> "ACE" .and. PTipo <> "ACC",.t.,iif( cTipo == "FIEX01", Empty(ECA->ECA_INVEXP), .not. Empty(ECA->ECA_INVEXP) ))
            if ECA->ECA_DT_CON >= dParIni
               aRet[1] += ECA->ECA_VALOR
            else
               aRet[2] += ECA->ECA_VALOR
            Endif
         Endif    
      Endif
   Endif                 
   ECA->(DBSkip())                  
Enddo
next
else //controle de juros
for i:=ni to nFim
      cTipo="FIEX0"+alltrim(str(i))
      ECA->( DBSeek( cFilECA + cTipo + PContra ) )
      Do While ECA->ECA_FILIAL == cFilECA .and. (ECA->ECA_TPMODU == cTipo) .and. ECA->ECA_CONTRA == PContra .and. .not. ECA->(EoF())
         If ECA->ECA_BANCO == PBanco .or. ECA->ECA_PRACA == PPraca
             If ECA->ECA_DT_CON <= dParFinal .or. Empty(dParFinal)
                 //Controle de juros
                 If (ECA->ECA_ID_CAM $ "520") .and. iif(PTipo <> "ACE" .and. PTipo <> "ACC",.t.,iif( cTipo == "FIEX01", Empty(ECA->ECA_INVEXP), .not. Empty(ECA->ECA_INVEXP) ))
                     // if ECA->ECA_DT_CON >= dParIni
                          aRet[1] += ECA->ECA_VALOR/ECA->ECA_TX_USD
                          aRet[2] += ECA->ECA_VALOR
                     // else

                    //  Endif
                 Endif
            Endif
         Endif                 
         ECA->(DBSkip())                  
      Enddo
   next
endif
Return aRet
// ----------------- - Fim
