#INCLUDE "EFFMV160.ch"
#INCLUDE 'avprint.ch'
#INCLUDE 'Average.cH'
#INCLUDE "TOPCONN.CH"
//Revisão - 04-11-05 - Alcir Alves - solução do chamado 020326 Braskem
//Revisão - 20-12-04 - Alcir Alves - tratamento de multifilial
//Revisão - 12-02-05 - Alcir Alves - gerar excel+txt e pontos de entradas
//Revisão - 03-05-06 - HVR - Adaptações para o Finimp, Novos Filtros, Pesquisa TPMODU I ou E, Quebra por TPMODU
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EFFMV160.PRW  Autor Thomaz            º Data ³  27/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Extrato de Contratos.                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaEFF                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  

*-------------------*
Function EFFMV160()
*-------------------*               
Local nOpca := 1, lRet := .F.
Local bOk:={||(nOpca:=1, oDlg:End() )}
Local bCancel:={||(nOpca:=0, oDlg:End() )}
// ACSJ - 21/03/2005
LOCAL nIndSX3
// -----------------
PRIVATE lExistBCO := iif(EF3->(FieldPos("EF3_BAN_FI")) > 0 .AND. EF3->(FieldPos("EF3_PRACA")) > 0 .AND. EF2->(FieldPos("EF2_BAN_FI")) > 0 .AND. EF2->(FieldPos("EF2_PRACA")) > 0 ,.T.,.F.) //ALCIR ALVES -14-02-05  CASO EXISTA NOVOS CAMPOS DA CHAVE EF1,EF2 E EF3
//Alcir Alves - 12-02-05   //lExistBCO:=.f.      

//HVR - Novos campos do FinImp
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0

//HVR PrePagamento - Securitização
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
//HVR***

Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9")

Private cNroCont, lImprime := .T. //EasyGParam("MV_ACC_ACE")
Private dDt_Inicio, dDt_Fim,cNomArq
Private aHeader[0],aCampos:={}, TB_Campos := {}
Private cPictCont  := AVSX3("EF3_CONTRA", 06), cPictTipo:= AVSX3("EF3_TP_EVE", 06)
Private cPictCodEve:= AVSX3("EF3_CODEVE", 06), cPictDesEve:= AVSX3("EF3_DESCEV", 06)
Private cPictInv   := AVSX3("EF3_INVOIC", 06), cPictPreem:= AVSX3("EF3_PREEMB", 06)
Private cPictParc  := AVSX3("EF3_PARC"  , 06) //HVR
Private cPictVlMoe := AVSX3("EF3_VL_MOE", 06), cPictVlRea:= AVSX3("EF3_VL_REA", 06)
Private cPictDt_Eve:= AVSX3("EF3_DT_EVE", 06), cPictTxFob:= AVSX3("EF3_TX_MOE", 06)
//Private cPictDtFix:= AVSX3("EF3_DT_", 06), //        - Alcir Alves - 16-06-05
Private cTitMoeP:= AVSX3("EF1_SLD_PM", 05)
Private cPictMoeP:= AVSX3("EF1_SLD_PM", 06), cTitMoeR := AVSX3("EF1_SLD_PR", 05)
Private cPictMoeR := AVSX3("EF1_SLD_PR", 06), cTitMoeJP:= AVSX3("EF1_SLD_JM", 05)
Private cTitMoeJR := AVSX3("EF1_SLD_JR", 05), cPictMoeJP:= AVSX3("EF1_SLD_JM", 06)
Private cPictMoeJR:= AVSX3("EF1_SLD_JR", 06), cTitMoeP2:= AVSX3("EF1_SL2_PM", 05)
Private cPictMoeP2:= AVSX3("EF1_SL2_PM", 06), cTitMoeR2:= AVSX3("EF1_SL2_PR", 05)
Private cPictMoeR2:= AVSX3("EF1_SL2_PR", 06), cTitMoe2Jp:= AVSX3("EF1_SL2_JM", 05)
Private cPicMoe2JP := AVSX3("EF1_SL2_JM", 06), cTitMoe2JR:= AVSX3("EF1_SL2_JR", 05)
Private cPicMoe2JR:= AVSX3("EF1_SL2_JR", 06)
Private cMoePRR:=AVSX3("EF1_LIQPRR", 05),cMoe2PRM:=AVSX3("EF1_LIQPRM", 05)  //Alcir Alves - 23-05-05
Private cMoeJRR:=AVSX3("EF1_LIQJRR", 05),cMoe2JRM:=AVSX3("EF1_LIQJRM", 05)  //Alcir Alves - 23-05-05
Private aTotal_p:={} //Alcir Alves - 23-05-05 - array com o total por periodo
//LRL 19/12/03
Private cImport, cForn, cExport ,cTpFin, cEvento , cLoja, cTpCamb, cSeqCNT, aFilSel:={} //Alcir Alves - 21/12/04 - conceito multifilial //HVR CTPCAMB CSEQCNT
Private cFilEF1 := xFilial("EF1")
Private cFilEF3 := xFilial("EF3")
If lCadFin
   Private cFilEF7 := xFilial("EF7") //HVR
EndIf
Private cFilSA1 := xFilial("SA1") //HVR
Private cFilSA2 := xFilial("SA2")
Private cFilEC6 := xFilial("EC6")
Private cFilSX5 := xFilial("SX5")
Private lMultiFil := Posicione("SX2",1,"EF1","X2_MODO") == "C" .AND. VerSenha(115) .and.;
                     Posicione("SX2",1,"EEQ","X2_MODO") == "E" //AAF 11/01/05 - Verifica se o ambiente é multifilial.
Private cFiltroF3Fin := "E/I", lEvCont := .F.

// ACSJ - 21/03/2005 
nIndSX3 := SX3->(IndexOrd())
                            
SX5->(DBSetOrder(1))    //Alcir Alves - 01-06-05
SA1->(DBSetOrder(1))    //HVR
EF1->(DBSetOrder(1))
If lCadFin
   EF7->(DBSetOrder(1))    //HVR
EndIf
SA2->(DBSetOrder(1))    //Alcir Alves - 01-06-05
SWB->(DBSETORDER(1))    //HVR
EEQ->(DBSETORDER(5))    //Alcir Alves - 01-06-05
SX3->(DBSetOrder(2))
lTemRof := SX3->(DBSeek("EF1_ROF"))
SX3->(DBSetOrder(nIndSX3))
// --------------------                               
Private cTypeRel := If (lTemRof,"mv_par17","mv_par16")

If lEFFTpMod
   Private cCTpCamb := If (lTemRof,"mv_par18","mv_par17") //HVR
   Private cCSeqCNT := If (lTemRof,"mv_par19","mv_par18") //HVR
   Private cCForn   := If (lTemRof,"mv_par20","mv_par19") //HVR
EndIf

Private cModAt := "X" //HVR PARA QUEBRA POR MODULO TPMODU
Private nIModulo:=0//HVR PARA QUEBRA POR MODULO TPMODU

//ASK 13/02/07 14:29 - Incluso no AtuSx do P9R1
//MV160DICIO()
aFilSel:=AvgSelectFil(.T.,"EF1") //Alcir Alves - 21/12/04 - conceito multifilial
While .T.       
   DBSelectArea("SX1")   // ACSJ - 21/03/2005-É Necessario existir uma area setada.
   EFFCriaWork()         // Deve ser criada uma Work para cada consulta.

   dDt_Inicio := dDt_Fim := cTod("")
   cNroCont := "" 
   aTotal_p := {}
   If ! Pergunte("EFFMV1",.T.)                    
        IF SELECT("WORK")>0
            WORK->(E_EraseArq(cNomArq)) 
        ENDIF
        Return .F.
   EndIf  
   IF EMPTY(mv_par01)
      mv_par01 :=CTOD("01/01/00")  
   ENDIF
   IF EMPTY(mv_par02)
      mv_par02 :=CTOD("31/12/49")  
   ENDIF
   //IF  &(cTypeRel)==1 //Alcir Alves - 12-02-05
   dDt_Inicio := mv_par01
   dDt_Fim    := mv_par02
   cNroCont   := mv_par03
   cTpFin     := Right(mv_par04,2)   //LRL 20/12/03
   cEvento    := mv_par05   //LRL 20/12/03
   cExport    := mv_par06   //LRL 19/12/03
   cImport    := mv_par10   //LRL 19/12/03
   cLoja      := mv_par07   //LRL 20/12/03
   If lEFFTpMod
      cForn      := &(cCForn)    //HVR
      cTpCamb    := Alltrim(STR(&(cCTpCamb)))    //HVR
      cSeqCNT    := &(cCSeqCNT)   //HVR
   EndIf
      
   IF  &(cTypeRel)==1 
      MsAguarde({|| lRet := EFFGeraDados()}, STR0003) //"Aguarde... Lendo Dados do Arquivo..."
/*      IF SELECT("WORK")>0 //ALCIR ALVES - 23-05-05
          Work->(dbCloseArea())      
      ENDIF
*/      
   ELSE
      MsAguarde({|| EFFGravaWork() },STR0004) //"Atualizando Arquivos..."
      If Work->(EasyRecCount("Work")) <> 0
         WORK_EXPORT(iif(&(cTypeRel)==2,.F.,.T.)) //Alcir Alves - 12-02-05
      Else
         EasyHelp(STR0058,STR0059)  //"Não há informações disponíveis para o filtro selecionado."  ## "Atenção"
      EndIf
   ENDIF
//   WORK->(E_EraseArq(cNomArq))
EndDo  
Return .T.

*--------------------------------*
STATIC FUNCTION EFFGeraDados()
*--------------------------------*                                  
Local oDlg, nOpc,oPanel ,aRelat:= {}
Local aButtons := {}
Private cMarca := GetMark(), lInverte := .F.
Private aRCampos:={}, aDados, PrimPag:=.T. 
Private cFilAtu:=iIF(lMultiFil,"-",xFilial("EF1"))

IndRegua("Work",cNomArq+TEOrdBagExt(),"FILIAL"+IIF(lEFFTpMod,"+EF1_TPMODU","")+"+NRO_CONT+PROC_EMB+INVOICE+DTOS(DT_EVEN)")   //Alcir Alves - 12-02-05
MsAguarde({|| EFFGravaWork() },STR0004) //"Atualizando Arquivos..."

aRCampos:={}
TB_Campos := {}
aDados :={"WORK",; 
           STR0005 ,; //"Este Relatorio irá imprimir Extrato "
           STR0006,;  //"de Contratos no período escolhido"
           "",;
           "G",;
           220,;
           "",;
           "",;
           STR0007,; //"Relatório - Extrato de Contratos"
           {STR0008, 1, STR0009 , 2, 2, 1, "",1 },;  //"ZEBRADO"###"IMPORTAÇÃO"
           "EFFMV160",;
           { {|| EFFGrvTotal() } , { || EFFGrvTotal() }  }  } 

//array do report //Alcir - 22-12-04
AADD(TB_Campos,{{ ||Transf(Work->COD_EVEN, cPictCodEve) }  , "", STR0012  } )   //"Codigo Evento"
AADD(TB_Campos,{{ ||Transf(Work->DES_EVEN, cPictDesEve) }  , "", STR0013  } )   //"Descrição Evento"
AADD(TB_Campos,{{ ||Transf(Work->INVOICE, cPictInv)     }  , "", STR0014  } )   //"Invoice"
AADD(TB_Campos,{{ ||Transf(Work->EF3_PARC, cPictParc)   }  , "", STR0055  } )   //"Parcela"  //HVR
AADD(TB_Campos,{{ ||Transf(Work->PROC_EMB, cPictPreem)  }  , "", STR0015  } )   //"Nro Proc. Embarque"
AADD(TB_Campos,{{ ||Transf(Work->VL_MOEDA, cPictVlMoe)  }  , "", STR0016  } )   //"Vl Moeda Contrato"
AADD(TB_Campos,{{ ||Transf(Work->VL_REAL, cPictVlRea )  }  , "", STR0017  } )   //"Valor R$"
AADD(TB_Campos,{{ ||Transf(Work->DT_EVEN, cPictDt_Eve)  }  , "", STR0018  } )   //"Data Evento"
AADD(TB_Campos,{{ ||Transf(Work->TX_MOEDA, cPictTxFob)  }  , "", STR0019  } )   //"Taxa Moeda"
//AADD(TB_Campos,{{ ||Transf(Work->DT_FIXA, cPictDtFix)   }  , "", STR0020  } ) //"Data Fixa"

// Adicionando botão imprimir
aAdd(aButtons, {"IMPRIMIR", {||GERAREL(aDados,aRCampos,oMark)}, STR0060, STR0060}) // Imprimir

//Alcir Alves - 12-02-05
if EasyEntryPoint("EFFMV160")
     ExecBlock("EFFMV160", .F., .F.,"RPT_ITENS")
endif
//            
aRCampos:= E_CriaRCampos(TB_Campos,"C")  //Alcir - 22-12-04
//array da MSSelect //Alcir - 22-12-04
TB_Campos:={}
IF lMultiFil //AAF 11/01/05 - Usada a Variavel lMultiFil.  //!(len(aFilSel)==1 .and. alltrim(aFilSel[1])=="") //Alcir
   AADD(TB_Campos,{{ || Work->FIL_NAME                     }  , "", STR0036     } )  //"Codigo Evento"
ENDIF

AADD(TB_Campos,{{ ||Work->NRO_CONT }  , "", STR0010 } ) //"Numero do contrato" //Alcir Alves - 19-05-05
AADD(TB_Campos,{{ ||WORK->EF1_VM_FIN }, "", STR0011 } ) //"Tipo" //Alcir Alves - 19-05-05
AADD(TB_Campos,{{ ||Transf(Work->COD_EVEN, cPictCodEve) }  , "", STR0012  } ) //"Codigo Evento"
AADD(TB_Campos,{{ ||Transf(Work->DES_EVEN, cPictDesEve) }  , "", STR0013  } ) //"Descrição Evento"
AADD(TB_Campos,{{ ||Transf(Work->INVOICE , cPictInv)    }  , "", STR0014  } ) //"Invoice" 
AADD(TB_Campos,{{ ||Transf(Work->EF3_PARC, cPictParc)   }  , "", STR0055  } ) //"Parcela" //HVR
AADD(TB_Campos,{{ ||Transf(Work->PROC_EMB, cPictPreem)  }  , "", STR0015  } ) //"Nro Proc. Embarque"
AADD(TB_Campos,{{ ||Transf(Work->VL_MOEDA, cPictVlMoe)  }  , "", STR0016  } ) //"Vl Moeda Contrato"
AADD(TB_Campos,{{ ||Transf(Work->VL_REAL, cPictVlRea )  }  , "", STR0017  } ) //"Valor R$"
AADD(TB_Campos,{{ ||Transf(Work->DT_EVEN, cPictDt_Eve)  }  , "", STR0018  } ) //"Data Evento"
AADD(TB_Campos,{{ ||Transf(Work->TX_MOEDA, cPictTxFob)  }  , "", STR0019  } ) //"Taxa Moeda"
//AADD(TB_Campos,{{ ||Transf(Work->DT_FIXA, cPictDtFix)   }  , "", STR0020  } ) //"Data Fixa"

//Alcir Alves - 12-02-05
If lTemRof
   AADD(TB_Campos,{{ || Work->ROF }, "", STR0037}) //"ROF."
EndIf
if EasyEntryPoint("EFFMV160")
    ExecBlock("EFFMV160", .F., .F.,"ADD_MSSELECT_COL")
endif
//
DBSELECTAREA("WORK")
If Work->(EasyReccount("Work")) > 0 
   Work->(DbGoTop())   
   Do While .T.
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE STR0021 ; //"Relatório - Extrato de Contratos"
           From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
	  @ 00,00 MsPanel oPanel Prompt "" Size 60,26 of oDlg			         	        
    					 
      @ 18 ,10 SAY STR0022+DTOC(dDt_Inicio)+STR0023+DTOC(dDt_Fim) //"Período de "###" ate "
			
      oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
      
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc:=1,oDlg:End()},;
 	                                                  {||nOpc:=0,oDlg:End()},;
                                                       ,aButtons),;
 	                                                  oPanel:Align := CONTROL_ALIGN_TOP ,;
                                                      oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT )
	                                                  			                                                                                                                                       			                                                                                                       		  	     
      If nOpc == 1 .Or. nOpc == 0
      //   work->(dbclosearea())
         Return .F.
      Endif
   Enddo
Else 
   Help(" ",1,"EICSEMREG")
Endif    
IF SELECT("WORK")>0
  // WORK->(E_EraseArq(cNomArq)) 
   Work->(dbCloseArea())
ENDIF
		
Return .T.

*----------------------------*
Static Function EFFCriaWork() 
*----------------------------*
aEstru := {}
AADD(aEstru,{ "NRO_CONT"   , AVSX3("EF3_CONTRA", 02), AVSX3("EF3_CONTRA", 03), AVSX3("EF3_CONTRA", 04)})
AADD(aEstru,{ "TIPO_CONT"  , AVSX3("EF1_TP_FIN", 02), AVSX3("EF1_TP_FIN", 03), AVSX3("EF1_TP_FIN", 04)})
AADD(aEstru,{ "EF1_VM_FIN" , AVSX3("EF1_VM_FIN", 02), AVSX3("EF1_VM_FIN", 03), AVSX3("EF1_VM_FIN", 04)}) //HVR DESCRIÇÃO DO TIPO DE FINANCIAMENTO
AADD(aEstru,{ "TIPO_EVEN"  , AVSX3("EF3_TP_EVE", 02), AVSX3("EF3_TP_EVE", 03), AVSX3("EF3_TP_EVE", 04)})
AADD(aEstru,{ "COD_EVEN"   , AVSX3("EF3_CODEVE", 02), AVSX3("EF3_CODEVE", 03), AVSX3("EF3_CODEVE", 04)})
AADD(aEstru,{ "DES_EVEN"   , AVSX3("EF3_DESCEV", 02), AVSX3("EF3_DESCEV", 03), AVSX3("EF3_DESCEV", 04)})
AADD(aEstru,{ "INVOICE"    , AVSX3("EF3_INVOIC", 02), AVSX3("EF3_INVOIC", 03), AVSX3("EF3_INVOIC", 04)})
AADD(aEstru,{ "EF3_PARC"   , AVSX3("EF3_PARC"  , 02), AVSX3("EF3_PARC"  , 03), AVSX3("EF3_PARC"  , 04)}) //HVR
AADD(aEstru,{ "PROC_EMB"   , AVSX3("EF3_PREEMB", 02), AVSX3("EF3_PREEMB", 03), AVSX3("EF3_PREEMB", 04)})
AADD(aEstru,{ "EF1_MOEDA"  , AVSX3("EF1_MOEDA" , 02), AVSX3("EF1_MOEDA" , 03), AVSX3("EF1_MOEDA" , 04)}) //HVR MOEDA DO CONTRATO
AADD(aEstru,{ "VL_MOEDA"   , AVSX3("EF3_VL_MOE", 02), AVSX3("EF3_VL_MOE", 03), AVSX3("EF3_VL_MOE", 04)})
AADD(aEstru,{ "VL_REAL"    , AVSX3("EF3_VL_REA", 02), AVSX3("EF3_VL_REA", 03), AVSX3("EF3_VL_REA", 04)})
AADD(aEstru,{ "DT_EVEN"    , AVSX3("EF3_DT_EVE", 02), AVSX3("EF3_DT_EVE", 03), AVSX3("EF3_DT_EVE", 04)})
AADD(aEstru,{ "TX_MOEDA"   , AVSX3("EF3_TX_MOE", 02), AVSX3("EF3_TX_MOE", 03), AVSX3("EF3_TX_MOE", 04)})
//AADD(aEstru,{ "DT_FIXA"  , AVSX3("EF3_DT_FIX", 02), AVSX3("EF3_DT_FIX", 03), AVSX3("EF3_DT_FIX", 04)})
AADD(aEstru,{ "EXPORT"     , AVSX3("EF1_EXPORT", 02), AVSX3("EF1_EXPORT", 03), AVSX3("EF1_EXPORT", 04)})
If lEFFTpMod
   AADD(aEstru,{ "EF1_FORN"   , AVSX3("EF1_FORN"  , 02), AVSX3("EF1_FORN"  , 03), AVSX3("EF1_FORN"  , 04)}) //HVR
   AADD(aEstru,{ "EF1_LOJAFO" , AVSX3("EF1_LOJAFO", 02), AVSX3("EF1_LOJAFO", 03), AVSX3("EF1_LOJAFO", 04)}) //HVR
   AADD(aEstru,{ "EF1_IMPORT" , AVSX3("EF1_IMPORT", 02), AVSX3("EF1_IMPORT", 03), AVSX3("EF1_IMPORT", 04)}) //HVR
EndIf
AADD(aEstru,{ "FILIAL"     , AVSX3("EF1_FILIAL", 02), AVSX3("EF1_FILIAL", 03), AVSX3("EF1_FILIAL", 04)})
AADD(aEstru,{ "FIL_NAME"   , "C",50,0})
//Alcir Alves - 12-02-05
AADD(aEstru,{ "BANCO_OP"   , AVSX3("EF1_BAN_FI", 02), AVSX3("EF1_BAN_FI", 03), AVSX3("EF1_BAN_FI", 04)})
If lTemRof  
   AADD(aEstru,{ "ROF"     , AVSX3("EF1_ROF", 02), AVSX3("EF1_ROF", 03), AVSX3("EF1_ROF", 04)})
EndIf
If lEFFTpMod //HVR
   AADD(aEstru,{ "EF1_SEQCNT" , AVSX3("EF1_SEQCNT", 02), AVSX3("EF1_SEQCNT", 03), AVSX3("EF1_SEQCNT", 04)}) //HVR
   AADD(aEstru,{ "EF1_TPMODU" , AVSX3("EF1_TPMODU", 02), AVSX3("EF1_TPMODU", 03), AVSX3("EF1_TPMODU", 04)}) //HVR
ENdIf
if EasyEntryPoint("EFFMV160")
    ExecBlock("EFFMV160", .F., .F.,"ADD_WORK_STRU")
endif
//
IF SELECT("WORK")>0
   WORK->(E_EraseArq(cNomArq)) 
//   Work->(dbCloseArea())
ENDIF
cNomArq:=E_CriaTrab(,aEstru,"Work")
Return .T.                     

*----------------------------*
Static Function EFFGravaWork()     
*----------------------------*   
Local nPos:=0 //Alcir Alves - 25-05-05
Local bF1While:={||EF1->EF1_FILIAL==cFilEF1}, cChave:="", cFilEC6:=xFilial("EC6"),nfil:=0,fil_n:={}

Private lValid:=.T. //Alcir Alves - 14-02-05 - variavel responsavel pelo retorno dos perguntes nas validaçoes

WORK->(avzap())
EC6->(dbSetOrder(1))
EEC->(dbSetOrder(1))
EF1->(DBSETORDER(1))
EF3->(DBSETORDER(1))

// Alcir Alves - 21/12/04  - tratamento de multifilial
//begincomm
aFilEF3:=AvgSelectFil(.F.,"EF3")
aFilEC6:=AvgSelectFil(.F.,"EC6")
//endcomm

IF !EMPTY(cNroCont)
   cChave:=cNroCont
   bF1While:={||EF1->EF1_FILIAL==cFilEF1 .and. EF1->EF1_CONTRA==cNroCont}
Else
   EF1->(DbSetOrder(4))         //
   If !EMPTY(cExport)           //LRL 22/12/2003
      cChave:=cExport+cLoja     //
      bF1While:={||EF1->EF1_FILIAL==cFilEF1 .and. EF1->EF1_EXPORT==cExport .AND. EF1->EF1_LOJA == cLOJA }
   EndIf
ENDIF 

For nfil=1 to len(aFilSel) //Alcir Alves - 20-12-04  - tratamento de multifilial

//Alcir Alves - 20-12-04  - tratamento de multifilial
   cFilEF1:=aFilSel[nfil]
//   EF1->(dbseek(cFilEF1+cChave)) ACSJ - 22/03/2005
   EF1->(DBSeek(cFilEF1))
   Do While EF1->(!EOF()) .and. EF1->EF1_FILIAL==cFilEF1 // ACSJ - 22/03/2005
      //Alcir Alves - 11-07-05                                                     
      IF lEFFTpMod .And. !empty(cTpCamb) .AND. (EF1->EF1_TPMODU # IF(cTpCamb=="1","I",IF(cTpCamb=="2","E","A")) .And. cTpCamb # "3")  //HVR VALIDAÇÃO TIPO DO MÓDULO
          EF1->(DbSkip())
          loop
      Endif                                                     		
      IF !empty(mv_par14) .AND. EF1->EF1_CLIENT # mv_par14 //VALIDAÇÃO DO CLIENTE DO PRÉ-PAGADOR
          EF1->(DbSkip())
          loop
      Endif                                                     		
      IF !empty(mv_par15) .AND. EF1->EF1_CLLOJA # mv_par15 //VALIDAÇÃO DA LOJA DO CLIENTE
          EF1->(DbSkip())
          loop
      Endif                                                     		
      If lEFFTpMod
         IF !empty(cSeqCNT) .AND. EF1->EF1_SEQCNT # cSeqCNT //HVR VALIDAÇÃO DA SEQUENCIA DO CONTRATO
             EF1->(DbSkip())
             loop
         Endif
      EndIf         
      // ACSJ - 22/03/2005
      If .not. Empty(cNroCont) .and. EF1->EF1_CONTRA<>cNroCont
         EF1->(DbSkip())
         loop
      Endif              
      If !Empty(cExport) .and. EF1->EF1_EXPORT<>cExport
         EF1->(DbSkip())
         loop      
      Endif        
      If !Empty(cImport) .and. EF1->EF1_IMPORT<>cImport //HVR Valida Importador
         EF1->(DbSkip())
         loop      
      Endif        
      If lEFFTpMod
         If !Empty(cForn) .and. EF1->EF1_Forn <> cForn //HVR Valida Fornecedor
            EF1->(DbSkip())
            loop      
         Endif
      EndIf
      If .not. Empty(cLOJA)  .and. EF1->EF1_LOJA == cLOJA 
         EF1->(DbSkip())
         loop      
      endif
      //----------------------
      //Alcir Alves - 12-02-05                                                     
      IF !empty(mv_par12) .AND. EF1->EF1_BAN_FI#mv_par12 //VALIDAÇÃO DO BANCO DE OPERAÇAO
          EF1->(DbSkip())
          loop
      Endif                                                     		
      IF lTemRof .and. !empty(mv_par16) .AND. EF1->EF1_ROF#Mv_par16 //VALIDAÇÃO DO ROF 
          EF1->(DbSkip())
          loop
      Endif                                                     		

      lValid:=.T.
      if EasyEntryPoint("EFFMV160")  //FILTRO DE VALIDAÇÃO DO PERGUNTE NO LOOP DO EF1
          ExecBlock("EFFMV160", .F., .F.,"VALID_PERGUNT_EF1") 
      endif
      IF !lValid  //Alcir Alves - 14-02-05 - validação de retorno dos filtros customizados no lasso do EF1
          EF1->(DbSkip())
          loop
      ENDIF
      //   
      cFilEF3:=iif(len(aFilEF3)==1 .and. alltrim(aFilEF3[1])=="",aFilEF3[1],aFilSel[nfil]) //Alcir - 20-12-04  - tratamento de multifilial
      
      //Alcir Alves - 16/02/05
      cWhile:={|| .T. }
      IF !lExistBCO //CASO NÃO EXISTA OS NOVOS CAMPOS EF2_BAN_FI E EF2_PRACA
         EF3->(DBSEEK(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA)) //HVR EF1_TPMODU
      ELSE
         EF3->(DBSEEK(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")))   //HVR 03/05/06 - NOVOS CAMPOS FINIMP TPMODU
         cWhile:={|| EF3->EF3_BAN_FI==EF1->EF1_BAN_FI .and. EF3->EF3_PRACA==EF1->EF1_PRACA .and. IIF(lEFFTpMod,EF3->EF3_SEQCNT==EF1->EF1_SEQCNT,.T.) }               //HVR 03/05/06 - NOVOS CAMPOS FINIMP TPMODU
      ENDIF 
      //
      Do While !EF3->(EOF()) .And. EF3->EF3_FILIAL == cFilEF3 .AND. EF3->EF3_CONTRA == EF1->EF1_CONTRA .AND. IF(lEFFTpMod, EF3->EF3_TPMODU == EF1->EF1_TPMODU,.T.) .AND. EVAL(cWhile)  //HVR 03/05/06 - NOVOS CAMPOS FINIMP TPMODU
         If !Empty(dDt_Inicio)
	         If !Empty(EF3->EF3_DT_EVE)
		         If EF3->EF3_DT_EVE < dDt_Inicio
			         EF3->(DbSkip())
			         Loop
			      Endif
		      Endif
	      Endif
			
	      If ! Empty(dDt_Fim)
	         If !Empty(EF3->EF3_DT_EVE)
		         If EF3->EF3_DT_EVE > dDt_Fim
			         EF3->(DbSkip())
			         Loop
			      Endif
		      Endif
	      Endif
   	   //Filtro por Evento     //LRL 22/12/03
	      If ! Empty(cEvento)
	         If !Empty(EF3->EF3_CODEVE)
		         If EF3->EF3_CODEVE != cEvento
			         EF3->(DbSkip())
   			      Loop
	   		   Endif
		      Endif
   	   Endif 
        //Filtro por Tipo de Financiamento    //LRL 22/12/03
         If ! Empty(cTpFin) .and. EF3->EF3_TP_EVE != cTpFin
             EF3->(DbSkip())
             Loop
         Endif
         
         IF !empty(mv_par08) .AND. EF3->EF3_PREEMB#mv_par08 //VALIDAÇÃO DO PROCESSO
            EF3->(DbSkip())
            Loop
         Endif                                                     		
          
         IF (!empty(mv_par09) .AND. EF3->EF3_INVOIC#mv_par09) .OR. (!empty(mv_par09) .AND. EF3->EF3_INVIMP#mv_par09)//VALIDAÇÃO DO INVOICE
            EF3->(DbSkip())
            Loop
         Endif                                                     		
         
         EEC->(DBSEEK(cFilEF1+EF3->EF3_PREEMB)) //POSICIONA O PROCESSO DO ITEM DO CONTRATO
         IF !EMPTY(mv_par10) .AND. EEC->EEC_IMPORT#mv_par10 //VALIDAÇÃO DO IMPORTADOR DA CAPA DO PROCESSO
            EF3->(DbSkip())
            Loop
         ENDIF
         
         IF !EMPTY(mv_par11) .AND. EEC->EEC_IMLOJA#mv_par11 //VALIDAÇÃO DO IMPORTADOR DA CAPA DO PROCESSO  //ALCIR ALVES - 25-05-05
            EF3->(DbSkip())
            Loop
         ENDIF

         //Alcir Alves - 12-02-05
         lValid:=.T.
         if EasyEntryPoint("EFFMV160")  //FILTRO DE VALIDAÇÃO DO PERGUNTE NO LOOP DO EF3
            ExecBlock("EFFMV160", .F., .F.,"VALID_PERGUNT_EF3")
         endif
         //   
         IF !lValid  //Alcir Alves - 14-02-05 - validação de retorno dos filtros customizados no lasso do EF3
            EF3->(DbSkip())
            loop
         ENDIF
     
         Work->(RECLOCK("WORK",.T.))
         Work->FILIAL      :=cFilEF1
         fil_n             :=AvgFilName({cFilEF1})
         Work->FIL_NAME    :=cFilEF1+" - "+fil_n[1]
         Work->EXPORT      := EF1->EF1_EXPORT    //LRL 23/12/03
         If lEFFTpMod
            Work->EF1_IMPORT  := EF1->EF1_IMPORT    //HVR
            Work->EF1_LOJAFO  := EF1->EF1_LOJAFO    //HVR
            Work->EF1_FORN    := EF1->EF1_FORN      //HVR
         EndIf
         Work->EF1_MOEDA   := EF1->EF1_MOEDA     //HVR
         Work->NRO_CONT    := EF3->EF3_CONTRA
         Work->TIPO_CONT   := EF1->EF1_TP_FIN      

         If lCadFin
            //EF7->(dbSetOrder(1))
            //IF EF7->(dbSeek(cFilEF7+EF1->EF1_TP_FIN))
               //WORK->EF7_DESCRI := EF7->EF7_DESCRI
            //EndIf
            WORK->EF1_VM_FIN := Posicione("EF7",1,cFilEF7+EF1->EF1_TP_FIN,"EF7_DESCRI")
         Else
            WORK->EF1_VM_FIN := Posicione("SX5",1,cFilSX5+"CG"+EF1->EF1_TP_FIN,"X5_DESCRI")
         EndIf
         
         Work->TIPO_EVEN := EF3->EF3_TP_EVE
         Work->COD_EVEN  := EF3->EF3_CODEVE
         cFilEC6=iif(len(aFilEC6)==1 .and. alltrim(aFilEC6[1])=="",aFilEC6[1],aFilSel[nfil]) //Alcir Alves - 04-11-05 //iif(EF3->(fieldpos("EF3_FILORI"))>0,EF3->EF3_FILORI,iif(len(aFilEC6)==1 .and. alltrim(aFilEC6[1])=="",aFilEC6[1],aFilSel[nfil])) //Alcir - 20-12-04  - tratamento de multifilial
         EC6->(dbSeek(cFilEC6+IF(lEFFTpMod .And. EF1->EF1_TPMODU = "I","FIIM", "FIEX")+EF3->EF3_TP_EVE+EF3->EF3_CODEVE)) //Alcir Alves - 04-11-05 //HVR IF(EF1->EF1_TPMODU = "E", "FIEX","FIIM")
         Work->DES_EVEN  := EC6->EC6_DESC
         Work->INVOICE   := IF(lEFFTpMod .And. EF3->EF3_TPMODU == "I", EF3->EF3_INVIMP, EF3->EF3_INVOIC)
         Work->EF3_PARC  := EF3->EF3_PARC //HVR
         Work->PROC_EMB  := EF3->EF3_PREEMB
         Work->VL_MOEDA  := EF3->EF3_VL_MOE
         Work->VL_REAL   := EF3->EF3_VL_REA
         Work->DT_EVEN   := EF3->EF3_DT_EVE
         Work->TX_MOEDA  := EF3->EF3_TX_MOE
//       Work->DT_FIXA   := EF3->EF3_DT_FIX
         //Alcir Alves - 12-02-05
         Work->BANCO_OP:=EF1->EF1_BAN_FI
         
         IF lEFFTpMod //HVR
            WORK->EF1_SEQCNT := EF1->EF1_SEQCNT
            WORK->EF1_TPMODU := EF1->EF1_TPMODU 
         ENDIF
         //Alcir Alves - 25-05-05 - array com totais por contrato no periodo
         IF mv_par13=1 .or. mv_par13=3
            nPos:=aScan(aTotal_p,{|X| X[1] == (cFilEF1+EF3->EF3_CONTRA) })
         IF nPos==0
               //2 - saldo principal na moeda ACC                 //3 - saldo principal em real  ACC
               //4 - saldo juros na moeda     ACC                 //5 - saldo juros em real      ACC
               //6 - saldo principal na moeda ACE                 //7 - saldo principal em real  ACe
               //8 - saldo juros na moeda     ACe                 //9 - saldo juros em real      ACe
               //10- liquidação principal na moeda ACe            //11 - liquidação principal em real  ACe
               //12 - liquidação juros na moeda   ACe             //13 - liquidação juros em real    ACe            
               //                                                       2 3 4 5 6 7 8 9 10 11 12 13
            aadd(aTotal_p,{(cFilEF1+EF3->EF3_CONTRA),0,0,0,0,0,0,0,0,0,  0, 0, 0})
            nPos:=len(aTotal_p)
         ENDIF
       
         IF !lPrePag .Or. ( lPrePag .AND. EF1->EF1_CAMTRA == "2" .AND. IF(lEFFTpMod, EF1->EF1_TPMODU = "E",.T.) ) //HVR Se não houver parcela de pre-pagamento e o modulo for Exportação
            IF EF3->EF3_TP_EVE="01"  //ACC
               IF EF3->EF3_CODEVE="100"  //SALDO ACC
                  aTotal_p[nPos,2]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,3]+=EF3->EF3_VL_REA
               ELSEIF  EF3->EF3_CODEVE="500" .OR. EF3->EF3_CODEVE="501" //VC CAMBIAL
                  aTotal_p[nPos,3]+=EF3->EF3_VL_REA               
               ELSEIF EF3->EF3_CODEVE=="999" .AND. (EF3->EF3_EV_EST=="500" .OR. EF3->EF3_EV_EST=="501")
                  aTotal_p[nPos,3]-=EF3->EF3_VL_REA                
               ELSEIF  EF3->EF3_CODEVE="520" .OR. EF3->EF3_CODEVE="550" .OR. EF3->EF3_CODEVE="551" //JUROS
                  IF  EF3->EF3_CODEVE="520"
                     aTotal_p[nPos,4]+=EF3->EF3_VL_MOE
                  ENDIF
                  aTotal_p[nPos,5]+=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE=="999" .AND. (EF3->EF3_EV_EST="520" .OR. EF3->EF3_EV_EST="550" .OR. EF3->EF3_EV_EST="551") //JUROS
                  IF  EF3->EF3_EV_EST="520"
                     aTotal_p[nPos,4]-=EF3->EF3_VL_MOE
                  ENDIF
                  aTotal_p[nPos,5]-=EF3->EF3_VL_REA
               ELSEIF  EF3->EF3_CODEVE="640" //LIQUIDAÇÃO DE JUROS
                  aTotal_p[nPos,4]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,5]-=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST="640"               
                  aTotal_p[nPos,4]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,5]+=EF3->EF3_VL_REA
               ELSEIF  EF3->EF3_CODEVE="650"   //TRANSFERENCIA DE ACC PARA ACE JUROS
                  aTotal_p[nPos,4]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,5]-=EF3->EF3_VL_REA
                  aTotal_p[nPos,8]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,9]+=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE=="999" .AND. EF3->EF3_EV_EST="650"                              
                  aTotal_p[nPos,4]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,5]+=EF3->EF3_VL_REA
                  aTotal_p[nPos,8]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,9]-=EF3->EF3_VL_REA
               ENDIF           
            ELSE //ACE
               IF EF3->EF3_CODEVE="100"   //CONTRATO
                  aTotal_p[nPos,6]:=EF3->EF3_VL_MOE
                  aTotal_p[nPos,7]:=EF3->EF3_VL_REA
               ELSEIF  EF3->EF3_CODEVE="600"   //TRANSFERENCIA DE ACC PARA ACE
                  aTotal_p[nPos,2]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,3]-=EF3->EF3_VL_REA
                  aTotal_p[nPos,6]+=EF3->EF3_VL_MOE  //SALDO ACE
                  aTotal_p[nPos,7]+=EF3->EF3_VL_REA  //SALDO ACE
               ELSEIF  EF3->EF3_CODEVE="999" .AND. EF3->EF3_EV_EST="600"   //TRANSFERENCIA DE ACC PARA ACE
                  aTotal_p[nPos,2]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,3]+=EF3->EF3_VL_REA
                  aTotal_p[nPos,6]-=EF3->EF3_VL_MOE  //SALDO ACE
                  aTotal_p[nPos,7]-=EF3->EF3_VL_REA  //SALDO ACE
               ELSEIF EF3->EF3_CODEVE="630"  //LIQUIDACOES
                  aTotal_p[nPos,10]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,11]+=EF3->EF3_VL_REA
                  aTotal_p[nPos,6]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,7]-=EF3->EF3_VL_REA
               ELSEIF  EF3->EF3_CODEVE="999" .AND. EF3->EF3_EV_EST="630"   //TRANSFERENCIA DE ACC PARA ACE
                  aTotal_p[nPos,10]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,11]-=EF3->EF3_VL_REA
                  aTotal_p[nPos,6]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,7]+=EF3->EF3_VL_REA               
               ELSEIF EF3->EF3_CODEVE="500" .OR. EF3->EF3_CODEVE="501" //VC CAMBIALb                  aTotal_p[nPos,7]+=EF3->EF3_VL_REA  
               ELSEIF EF3->EF3_CODEVE="999" .AND. (EF3->EF3_EV_EST="500" .OR. EF3->EF3_EV_EST="501") //VC CAMBIAL
                  aTotal_p[nPos,7]-=EF3->EF3_VL_REA  
               ELSEIF EF3->EF3_CODEVE="520" .OR. EF3->EF3_CODEVE="550" .OR. EF3->EF3_CODEVE="551"  //PROVISAO DE JUROS
                  IF  EF3->EF3_CODEVE="520"
                     aTotal_p[nPos,8]+=EF3->EF3_VL_MOE
                  ENDIF
                  aTotal_p[nPos,9]+=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE="999" .AND. (EF3->EF3_EV_EST="520" .OR. EF3->EF3_EV_EST="550" .OR. EF3->EF3_EV_EST="551")  //PROVISAO DE JUROS
                  IF  EF3->EF3_EV_EST="520"
                     aTotal_p[nPos,8]-=EF3->EF3_VL_MOE
                  ENDIF
                  aTotal_p[nPos,9]-=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE="640" //LIQUIDAÇÃO DE JUROS
                  aTotal_p[nPos,8]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,9]-=EF3->EF3_VL_REA
                  aTotal_p[nPos,12]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,13]+=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE="999" .AND. EF3->EF3_EV_EST="640"
                  aTotal_p[nPos,8]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,9]+=EF3->EF3_VL_REA
                  aTotal_p[nPos,12]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,13]-=EF3->EF3_VL_REA               
               ENDIF
            ENDIF
//HVR 
         ElseIF IF(lEFFTpMod, EF1->EF1_TPMODU = "I",.F.)
               //2 - saldo principal na moeda ACC                 //3 - saldo principal em real  ACC
               //4 - saldo juros na moeda     ACC                 //5 - saldo juros em real      ACC
               //6 - saldo principal na moeda ACE                 //7 - saldo principal em real  ACe
               //8 - saldo juros na moeda     ACe                 //9 - saldo juros em real      ACe
               //10- liquidação principal na moeda ACe            //11 - liquidação principal em real  ACe
               //12 - liquidação juros na moeda   ACe             //13 - liquidação juros em real    ACe            
            If lPrepag .and. EF1->EF1_CAMTRA = "1"
               IF EF3->EF3_CODEVE="700" .And. Empty(EF3->EF3_TX_MOE) //SALDO
                  aTotal_p[nPos,6]+=EF3->EF3_VL_MOE
               ELSEIF  Left(EF3->EF3_CODEVE,2)="71" .and. Empty(EF3->EF3_TX_MOE)//JUROS
                  aTotal_p[nPos,8]+=EF3->EF3_VL_MOE
               ELSEIF EF3->EF3_CODEVE="700" .And. !Empty(EF3->EF3_TX_MOE) //SALDO LIQUIDADAS
                  aTotal_p[nPos,10]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,11]+=EF3->EF3_VL_REA
               EndIf
            Else
               IF EF3->EF3_CODEVE="100"   //CONTRATO
                  aTotal_p[nPos,6]:=EF3->EF3_VL_MOE
                  aTotal_p[nPos,7]:=EF3->EF3_VL_REA
               ELSEIF  EF3->EF3_CODEVE="600"   //TRANSFERENCIA DE ACC PARA ACE
                  aTotal_p[nPos,2]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,3]-=EF3->EF3_VL_REA
                  aTotal_p[nPos,6]+=EF3->EF3_VL_MOE  //SALDO ACE
                  aTotal_p[nPos,7]+=EF3->EF3_VL_REA  //SALDO ACE
               ELSEIF  EF3->EF3_CODEVE="999" .AND. EF3->EF3_EV_EST="600"   //TRANSFERENCIA DE ACC PARA ACE
                  aTotal_p[nPos,2]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,3]+=EF3->EF3_VL_REA
                  aTotal_p[nPos,6]-=EF3->EF3_VL_MOE  //SALDO ACE
                  aTotal_p[nPos,7]-=EF3->EF3_VL_REA  //SALDO ACE
               ELSEIF EF3->EF3_CODEVE="630"  //LIQUIDACOES
                  aTotal_p[nPos,10]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,11]+=EF3->EF3_VL_REA
                  aTotal_p[nPos,6]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,7]-=EF3->EF3_VL_REA
               ELSEIF  EF3->EF3_CODEVE="999" .AND. EF3->EF3_EV_EST="630"   //TRANSFERENCIA DE ACC PARA ACE
                  aTotal_p[nPos,10]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,11]-=EF3->EF3_VL_REA
                  aTotal_p[nPos,6]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,7]+=EF3->EF3_VL_REA               
               ELSEIF EF3->EF3_CODEVE="500" .OR. EF3->EF3_CODEVE="501" //VC CAMBIALb                  aTotal_p[nPos,7]+=EF3->EF3_VL_REA  
               ELSEIF EF3->EF3_CODEVE="999" .AND. (EF3->EF3_EV_EST="500" .OR. EF3->EF3_EV_EST="501") //VC CAMBIAL
                  aTotal_p[nPos,7]-=EF3->EF3_VL_REA  
               ELSEIF EF3->EF3_CODEVE="520" .OR. EF3->EF3_CODEVE="550" .OR. EF3->EF3_CODEVE="551"  //PROVISAO DE JUROS
                  IF  EF3->EF3_CODEVE="520"
                     aTotal_p[nPos,8]+=EF3->EF3_VL_MOE
                  ENDIF
                  aTotal_p[nPos,9]+=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE="999" .AND. (EF3->EF3_EV_EST="520" .OR. EF3->EF3_EV_EST="550" .OR. EF3->EF3_EV_EST="551")  //PROVISAO DE JUROS
                  IF  EF3->EF3_EV_EST="520"
                     aTotal_p[nPos,8]-=EF3->EF3_VL_MOE
                  ENDIF
                  aTotal_p[nPos,9]-=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE="640" //LIQUIDAÇÃO DE JUROS
                  aTotal_p[nPos,8]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,9]-=EF3->EF3_VL_REA
                  aTotal_p[nPos,12]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,13]+=EF3->EF3_VL_REA
               ELSEIF EF3->EF3_CODEVE="999" .AND. EF3->EF3_EV_EST="640"
                  aTotal_p[nPos,8]+=EF3->EF3_VL_MOE
                  aTotal_p[nPos,9]+=EF3->EF3_VL_REA
                  aTotal_p[nPos,12]-=EF3->EF3_VL_MOE
                  aTotal_p[nPos,13]-=EF3->EF3_VL_REA               
               ENDIF
            EndIf
         ElseIF IF(lEFFTpMod, EF1->EF1_TPMODU = "E",.F.) .AND. EF1->EF1_CAMTRA=="1"
            IF EF3->EF3_CODEVE="630" .And. EF3->EF3_EV_VIN == "700"
               aTotal_p[nPos,10]+=EF3->EF3_VL_MOE
               aTotal_p[nPos,11]+=EF3->EF3_VL_REA
            ELSEIF EF3->EF3_CODEVE="600" .And. EF3->EF3_EV_VIN == "700"
               aTotal_p[nPos,6]+=EF3->EF3_VL_MOE
               aTotal_p[nPos,7]+=EF3->EF3_VL_REA
            ELSEIF Left(EF3->EF3_CODEVE,2)="71"
               aTotal_p[nPos,4]+=EF3->EF3_SLDVIN
            ELSEIF EF3->EF3_CODEVE = "600" .And. Left(EF3->EF3_EV_VIN,2)="71"
               aTotal_p[nPos,8]+=EF3->EF3_VL_MOE
               aTotal_p[nPos,9]+=EF3->EF3_VL_REA
            ELSEIF EF3->EF3_CODEVE = "630" .And. Left(EF3->EF3_EV_VIN,2)="71"
               aTotal_p[nPos,12]+=EF3->EF3_VL_MOE
               aTotal_p[nPos,13]+=EF3->EF3_VL_REA
            ELSEIF EF3->EF3_CODEVE="700"
               aTotal_p[nPos,2]+=EF3->EF3_SLDVIN
            EndIf
         EndIf
       EndIF  
//HVR***
        //
         If lTemRof
            Work->ROF := EF1->EF1_ROF //ROF
         EndIf   
         if EasyEntryPoint("EFFMV160")
            ExecBlock("EFFMV160", .F., .F.,"GRAVA_WORK")
         endif
         //            
         Work->(MSUNLOCK())
         EF3->(DbSkip())
      EndDo                 
      EF1->(DbSkip())   
   EndDo
Next

Return .T.

*----------------------------------------------*
Static Function GERAREL(aDados,aRCampos,oMark)  
*----------------------------------------------*
Local nRecno:=RECNO()
Private cContrato ,cExportador

aDados[7]:= STR0022+DTOC(dDt_Inicio)+STR0023+DTOC(dDt_Fim) //"Período de "###" ate "

WORK->(DbGotop())

cContrato :="PRIM"  //Alcir Alves - 02-05-05
//cContrato := WORK->NRO_CONT
cModAt := "X"
niModulo := 0

E_Report(aDados,aRCampos)

DBGOTO(nRecno)

oMark:oBrowse:Refresh()

RETURN .T.                       

*-----------------------------*
Static Function EFFGrvTotal()
*-----------------------------*
//Local nPos:=0 //Alcir Alves - 23-05-05


IF EMPTY(cNroCont)
   EF1->(DBSETORDER(1))
endif


//HVR QUEBRA POR MÓDULO
IF nIModulo = 0
   If lEFFTpMod
      IF cModAt # WORK->EF1_TPMODU
         IF cModAt <> "X"
            MV160ImpSaldo()
            Linha := 69
            nIModulo:=1
         ENDIF
         If !Work->(EOF())
            PulaLinha()
            @ Linha, 000 PSAY Repli("*", 218 )
            PulaLinha()
            @ Linha, 000 PSAY STR0057+": "+IIF(WORK->EF1_TPMODU == "I", STR0050, STR0051)
            PulaLinha()
            @ Linha, 000 PSAY Repli("*", 218 )
            PulaLinha()
         EndIf
      EndIf
      cModAt := Work->EF1_TPMODU
   EndIf
EndIF
//HVR***

If cContrato =="PRIM" //Alcir Alves - 02-05-05 - primeiro contrato
   cExportador := WORK->EXPORT 
   cContrato:=WORK->NRO_CONT 

   PulaLinha()
   //HVR IMPRIME DADOS DO CONTRATO
   @Linha,001 PSay  IF(lEFFTpMod .And. WORK->EF1_TPMODU = "I", STR0040+" "+WORK->EF1_IMPORT, STR0025 + WORK->EXPORT);
                    +IIF(lEFFTpMod," "+STR0054+": " +WORK->EF1_FORN+"  "+WORK->EF1_LOJAFO,"");
                    +" "+STR0026+" " +WORK->NRO_CONT;
                    +IIF(lEFFTpMod," "+STR0053+": "+WORK->EF1_SEQCNT,"");
                    +" "+STR0027+" "+WORK->EF1_VM_FIN;
                    +" "+STR0056+": "+WORK->EF1_MOEDA;
                    +" "+STR0037+": "+WORK->ROF
   
   If lEFFTpMod                 
      cModAt := WORK->EF1_TPMODU
   EndIf   

   //Alcir Alves - 12-02-05
   if EasyEntryPoint("EFFMV160")
      ExecBlock("EFFMV160", .F., .F.,"CAPA_CONTRATO_ITENS")
   endif
   //            
Endif

If cContrato <> WORK->NRO_CONT
   MV160ImpSaldo()
Endif 

// Alcir Alves - 21/12/04  - tratamento de multifilial
//cria o cabeçalho por filial
//begincomm
if lMultiFil .AND. cFilAtu<>work->filial .AND. !EMPTY(ALLTRIM(work->filial)) 
      if !PrimPag //se não for primeira pagina força a quebra de pagina
         //Linha:=61
         //PulaLinha() //força o cabeçalho           
         MV160IMPCAB() //AAF 11/01/05 - Imprime Cabeçalho
      else
      PrimPag:=.t.      
      endif                 
      
      cFilAtu:=work->filial       
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 220)
      PulaLinha()
      filial_n:=AvgFilName({cFilAtu})
      @ Linha,00 PSAY "Filial"+" "+cFilAtu+" - "+filial_n[1] 
      PulaLinha()
      @ Linha, 000 PSAY Repli("*", 220)
      PulaLinha()
      
      cExportador := WORK->EXPORT 
      cContrato:=WORK->NRO_CONT 
      If lEFFTpMod
         cModAt := WORK->EF1_TPMODU
      EndIf
      PulaLinha()
      @Linha,001 PSay  IF(lEFFTpMod  .And.  WORK->EF1_TPMODU = "I", STR0040+" "+WORK->EF1_IMPORT, STR0025 + WORK->EXPORT);
                    +IIF(lEFFTpMod," "+STR0054+": " +WORK->EF1_FORN+"  "+WORK->EF1_LOJAFO,"");
                    +" "+STR0026+" " +WORK->NRO_CONT;
                    +IIF(lEFFTpMod," "+STR0053+": "+WORK->EF1_SEQCNT,"");
                    +" "+STR0027+" "+WORK->EF1_VM_FIN;
                    +" "+STR0056+": "+WORK->EF1_MOEDA;
                    +" "+STR0037+": "+WORK->ROF

      //Alcir Alves - 12-02-05
      If lTemRof
         @Linha,085 PSay  STR0037 + ":" + WORK->ROF  //"ROF."
      EndIf   
      if EasyEntryPoint("EFFMV160")
         ExecBlock("EFFMV160", .F., .F.,"CAPA_CONTRATO_ITENS")
      endif
      //            
endif
//endcomm


If cContrato <> WORK->NRO_CONT .AND. !WORK->(EOF()) 
   cExportador := WORK->EXPORT 
   cContrato:=WORK->NRO_CONT 
   If lEFFTpMod
      cModAt := WORK->EF1_TPMODU
   EndIf
   PulaLinha()
   @Linha,001 PSay  IF(lEFFTpMod .And. WORK->EF1_TPMODU = "I", STR0040+" "+WORK->EF1_IMPORT, STR0025 + WORK->EXPORT);
                    +IIF(lEFFTpMod," "+STR0054+": " +WORK->EF1_FORN+"  "+WORK->EF1_LOJAFO,"");
                    +" "+STR0026+" " +WORK->NRO_CONT;
                    +IIF(lEFFTpMod," "+STR0053+": "+WORK->EF1_SEQCNT,"");
                    +" "+STR0027+" "+WORK->EF1_VM_FIN;
                    +" "+STR0056+": "+WORK->EF1_MOEDA;
                    +" "+STR0037+": "+WORK->ROF

   //Alcir Alves - 12-02-05
   if EasyEntryPoint("EFFMV160")
         ExecBlock("EFFMV160", .F., .F.,"CAPA_CONTRATO_ITENS")
   endif
   //            
Endif

IF !EMPTY(cNroCont)
    EF1->(DBSETORDER(4))
endif
  
Return .T.

*--------------------------*                 
Static Function PulaLinha()           
*--------------------------*
IF Linha > 55                                                                   
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))   
   Linha := 10
Else
   Linha++
Endif   

RETURN .T.

  
*---------------------------*
Function EFFMV160VAL(cCampo)     //LRL 23/12/2003
*---------------------------*
Local lRet:=.T.
Local lAchou
IF(valtype(cCampo) = "U", cCampo:="",.T.)


If cCampo == "DATAINICIAL" .OR. Empty(cCampo)
   If !Empty(MV_PAR01) // - SVG - 02/03/2009
      If !E_Periodo_OK(@MV_PAR01,@MV_PAR02)
         lRet := .F.
      EndIf
   EndIf
ElseIf cCampo == "DATAFINAL".OR. Empty(cCampo)
   If !Empty(MV_PAR01)// - SVG - 02/03/2009
      If !E_Periodo_OK(@MV_PAR01,@MV_PAR02)
         lRet := .F.
      EndIf
   EndIf
Endif

If cCampo == "CONTRATO" .OR. Empty(cCampo)
    If !Empty(mv_par03)
       If lEFFTpMod
          IF (!EF1->( DBSeek(cFilEF1+"E"+mv_par03) )  .and.  !EF1->( DBSeek(cFilEF1+"I"+mv_par03) ))
             ///(!EF1->( DBSeek(cFilEF1+"E"+mv_par03) )  .or.  !AvgExistCpo("EF1","I"+mv_par03))
             *
             lRet:=.F.
             MSGINFO("Contrato não encontrato na Exportacao e na Importacao !","Atenção")
          ENDIF
       ///ElseIf !AvgExistCpo("EF1",mv_par03)       
       Else
          if !AvgExistCpo("EF1",mv_par03)
             lRet:=.F.
          endif
       EndIf
    EndIf
ElseIf (cCampo == "EVENTO" .OR. Empty(cCampo))  .AND. !Empty(mv_par05)
  EC6->(DbSetOrder(1))
  If !Empty(mv_par04)
    If !EC6->(DbSeek(cFILEC6+IF(lEFFTpMod .And. EF1->EF1_TPMODU = "I", "FIIM","FIEX")+mv_par04+mv_par05))  //HVR IF(EF1->EF1_TPMODU = "E", "FIEX","FIIM")
       lRet:= .F.
       MsgInfo(STR0032) //"Evento invalido"
    EndIf
  Else
      lAchou := .F.
      SX5->(dbSeek(cFilSX5+"CJ"))
       Do While !SX5->(EOF()) .And. SX5->X5_TABELA == "CJ"                                 
        If EC6->(dbSeek(cFilEC6+IF(lEFFTpMod .And. EF1->EF1_TPMODU = "I", "FIIM","FIEX")+SX5->X5_CHAVE+mv_par05))                                    
           lAchou := .T.                                                           
           Exit                                                                    
        EndIf                                                                      
        SX5->(DbSkip())                                                            
      EndDo
      If !lAchou   
       lRet:= .F.
       MsgInfo(STR0032) //"Evento invalido" 
      EndIf                                                                            
  Endif 
  
ElseIf cTpCamb = "2" .And. (cCampo == "INVOICE" .OR. Empty(cCampo))   //HVR
   If (!Empty(mv_par09) .AND. !eeq->(dbSeek(cFilEEQ+mv_par09+"101"))) 
       lRet:=.F.
       MsgInfo(STR0048) // "Tipo de invoice inválida"
   EndIf


ElseIf cCampo == "TIPOFINC" .OR. Empty(cCampo)
   If !Empty(mv_par04) .AND. !SX5->(dbSeek(cFilSX5+"CG"+mv_par04))
       lRet:=.F.
       MsgInfo(STR0033) // "Tipo de Finaciamento Invalido"
   EndIf
//HVR
ElseIf cCampo == "TIPOFINEF7" .OR. Empty(cCampo)
   If !Empty(mv_par04)  .And.  !EF7->( DBSeek(cFilEF7+mv_par04) )
      lRet:=.F.
      MsgInfo(STR0033) // "Tipo de Finaciamento Invalido"
   EndIf
//HVR***

ElseIf cCampo == "EXPORT" .OR. Empty(cCampo)
  //IF (!Empty(mv_par06))
  //     MsgInfo(STR0034)// "O filtro por Exportador será ignorado, pois esse campo não Existe"
  //     lRet:=.F.   
   If (!Empty(mv_par06)) .AND. !SA2->(DbSeek(cFilSA2+mv_par06))     //Se exportador foi preenchido no pergunte verifica validade
      MsgInfo(STR0035)// "Exportador ou Loja invalidos"
      lRet:=.F.   
   EndIf
EndIF

RETURN lRet

//AAF 10/01/05 - Imprime o Cabeçalho de acordo com o array TB_Campos.
//             - Necessário para a quebra de pagina forçada.
*--------------------*
Function MV160IMPCAB()
*--------------------*
Local i
LINHA := 0
Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
Linha++

cCab := Space(0)
cCab2:= Space(0)
For i:= 1 To Len(aRCampos)
   cCab += Space(1) //Espaçamento entre as colunas
   cCab2+= Space(1) //Espaçamento entre as colunas
   
   nSpac1:= Int((Len(Eval(aRCampos[i][1])) - Len(aRCampos[i][2])) / 2)
   nSpac2:= Len(Eval(aRCampos[i][1])) - ( nSpac1 + Len(aRCampos[i][2]))
   
   cCab += Space(nSpac1) + aRCampos[i][2] + Space(nSpac2)
   
   cCab2+= Replicate("=",Max(Len(Eval(aRCampos[i][1])),Len(aRCampos[i][2])))
Next

@ LINHA++, 000 PSAY Left(cCab ,aDados[6])
@ LINHA++, 000 PSAY Left(cCab2,aDados[6])

Return .T.

*// Função responsavel pela exportação de works para excel ou arquivo de texto
*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
*---------------------------------------------------------------------------------------
Private aTitulos := { {AVSX3("EF3_CONTRA", AV_TITULO)   ,AVSX3("EF3_CONTRA", AV_TIPO), "", ""},;
                      {AVSX3("EF1_TP_FIN", AV_TITULO)   ,AVSX3("EF1_TP_FIN", AV_TIPO), "", ""},;
                      {"Desc. Tipo"                     ,AVSX3("EF1_VM_FIN", AV_TIPO), "", ""},;
                      {AVSX3("EF3_TP_EVE", AV_TITULO)   ,AVSX3("EF3_TP_EVE", AV_TIPO), "", ""},;
                      {AVSX3("EF3_CODEVE", AV_TITULO)   ,AVSX3("EF3_CODEVE", AV_TIPO), "", ""},;
                      {AVSX3("EF3_DESCEV", AV_TITULO)   ,AVSX3("EF3_DESCEV", AV_TIPO), "", ""},;
                      {AVSX3("EF3_INVOIC", AV_TITULO)   ,AVSX3("EF3_INVOIC", AV_TIPO), "", ""},;
                      {AVSX3("EF3_PARC"  , AV_TITULO)   ,AVSX3("EF3_PARC"  , AV_TIPO), "", ""},;
                      {AVSX3("EF3_PREEMB", AV_TITULO)   ,AVSX3("EF3_PREEMB", AV_TIPO), "", ""},;
                      {AVSX3("EF1_MOEDA" , AV_TITULO)   ,AVSX3("EF1_MOEDA" , AV_TIPO), "", ""},;
                      {AVSX3("EF3_VL_MOE", AV_TITULO)   ,AVSX3("EF3_VL_MOE", AV_TIPO), "", ""},;
                      {AVSX3("EF3_VL_REA", AV_TITULO)   ,AVSX3("EF3_VL_REA", AV_TIPO), "", ""},;
                      {AVSX3("EF3_DT_EVE", AV_TITULO)   ,AVSX3("EF3_DT_EVE", AV_TIPO), "", ""},;
                      {AVSX3("EF3_TX_MOE", AV_TITULO)   ,AVSX3("EF3_TX_MOE", AV_TIPO), "", ""},;
                      {AVSX3("EF1_EXPORT", AV_TITULO)   ,AVSX3("EF1_EXPORT", AV_TIPO), "", ""},;
                      {AVSX3("EF1_FORN"  , AV_TITULO)   ,AVSX3("EF1_FORN"  , AV_TIPO), "", ""},;
                      {AVSX3("EF1_LOJAFO", AV_TITULO)   ,AVSX3("EF1_LOJAFO", AV_TIPO), "", ""},;
                      {AVSX3("EF1_IMPORT", AV_TITULO)   ,AVSX3("EF1_IMPORT", AV_TIPO), "", ""},;
                      {AVSX3("EF3_VL_MOE", AV_TITULO)   ,AVSX3("EF3_VL_MOE", AV_TIPO), "", ""},;
                      {AVSX3("EF1_FILIAL", AV_TITULO)   ,AVSX3("EF1_FILIAL", AV_TIPO), "", ""},;
                      {AVSX3("EF1_BAN_FI", AV_TITULO)   ,AVSX3("EF1_BAN_FI", AV_TIPO), "", ""},;
                      {AVSX3("EF1_ROF"   , AV_TITULO)   ,AVSX3("EF1_ROF"   , AV_TIPO), "", ""},;
                      {AVSX3("EF1_SEQCNT", AV_TITULO)   ,AVSX3("EF1_SEQCNT", AV_TIPO), "", ""},;
                      {AVSX3("EF1_TPMODU", AV_TITULO)   ,AVSX3("EF1_TPMODU", AV_TIPO), "", ""} }

/*Private aTitulos := { {AVSX3("EF3_CONTRA", AV_TITULO)   ,"NRO_CONT"   ,"",,,"",,AVSX3("EF3_CONTRA", AV_TIPO)},;
                      {AVSX3("EF1_TP_FIN", AV_TITULO)   ,"TIPO_CONT"  ,"",,,"",,AVSX3("EF1_TP_FIN", AV_TIPO)},;
                      {"Desc. Tipo"                     ,"EF1_VM_FIN" ,"",,,"",,AVSX3("EF1_VM_FIN", AV_TIPO)},;
                      {AVSX3("EF3_TP_EVE", AV_TITULO)   ,"TIPO_EVEN"  ,"",,,"",,AVSX3("EF3_TP_EVE", AV_TIPO)},;
                      {AVSX3("EF3_CODEVE", AV_TITULO)   ,"COD_EVEN"   ,"",,,"",,AVSX3("EF3_CODEVE", AV_TIPO)},;
                      {AVSX3("EF3_DESCEV", AV_TITULO)   ,"DES_EVEN"   ,"",,,"",,AVSX3("EF3_DESCEV", AV_TIPO)},;
                      {AVSX3("EF3_INVOIC", AV_TITULO)   ,"INVOICE"    ,"",,,"",,AVSX3("EF3_INVOIC", AV_TIPO)},;
                      {AVSX3("EF3_PARC"  , AV_TITULO)   ,"EF3_PARC"   ,"",,,"",,AVSX3("EF3_PARC"  , AV_TIPO)},;
                      {AVSX3("EF3_PREEMB", AV_TITULO)   ,"PROC_EMB"   ,"",,,"",,AVSX3("EF3_PREEMB", AV_TIPO)},;
                      {AVSX3("EF1_MOEDA" , AV_TITULO)   ,"EF1_MOEDA"  ,"",,,"",,AVSX3("EF1_MOEDA" , AV_TIPO)},;
                      {AVSX3("EF3_VL_MOE", AV_TITULO)   ,"VL_MOEDA"   ,"",,,"",,AVSX3("EF3_VL_MOE", AV_TIPO)},;
                      {AVSX3("EF3_VL_REA", AV_TITULO)   ,"VL_REAL"    ,"",,,"",,AVSX3("EF3_VL_REA", AV_TIPO)},;
                      {AVSX3("EF3_DT_EVE", AV_TITULO)   ,"DT_EVEN"    ,"",,,"",,AVSX3("EF3_DT_EVE", AV_TIPO)},;
                      {AVSX3("EF3_TX_MOE", AV_TITULO)   ,"TX_MOEDA"   ,"",,,"",,AVSX3("EF3_TX_MOE", AV_TIPO)},;
                      {AVSX3("EF1_EXPORT", AV_TITULO)   ,"EXPORT"     ,"",,,"",,AVSX3("EF1_EXPORT", AV_TIPO)},;
                      {AVSX3("EF1_FORN"  , AV_TITULO)   ,"EF1_FORN"   ,"",,,"",,AVSX3("EF1_FORN"  , AV_TIPO)},;
                      {AVSX3("EF1_LOJAFO", AV_TITULO)   ,"EF1_LOJAFO" ,"",,,"",,AVSX3("EF1_LOJAFO", AV_TIPO)},;
                      {AVSX3("EF1_IMPORT", AV_TITULO)   ,"EF1_IMPORT" ,"",,,"",,AVSX3("EF1_IMPORT", AV_TIPO)},;
                      {AVSX3("EF3_VL_MOE", AV_TITULO)   ,"VL_MOEDA"   ,"",,,"",,AVSX3("EF3_VL_MOE", AV_TIPO)},;
                      {AVSX3("EF1_FILIAL", AV_TITULO)   ,"FILIAL"     ,"",,,"",,AVSX3("EF1_FILIAL", AV_TIPO)},;
                      {"Nome Filial"                    ,"FIL_NAME"   ,"",,,"",,AVSX3("EF1_FILIAL", AV_TIPO)},;
                      {AVSX3("EF1_BAN_FI", AV_TITULO)   ,"BANCO_OP"   ,"",,,"",,AVSX3("EF1_BAN_FI", AV_TIPO)},;
                      {AVSX3("EF1_ROF"   , AV_TITULO)   ,"ROF"        ,"",,,"",,AVSX3("EF1_ROF"   , AV_TIPO)},;
                      {AVSX3("EF1_SEQCNT", AV_TITULO)   ,"EF1_SEQCNT" ,"",,,"",,AVSX3("EF1_SEQCNT", AV_TIPO)},;
                      {AVSX3("EF1_TPMODU", AV_TITULO)   ,"EF1_TPMODU" ,"",,,"",,AVSX3("EF1_TPMODU", AV_TIPO)} }
	
*/	
/**SVG** - 03/03/2009 - Condição para adequação a esportação utilizando Ctree*/
   cArqOrigem := cNomArq
   cAlias     := "Work"
   lXml       := .F.   
   
   if EasyEntryPoint("EFFMV160")
      ExecBlock("EFFMV160", .F., .F.,"ADD_COLUNA_ARQUIVO")
   endif
   
   TR350Arquivo("Work",,aTitulos,STR0007,,lExcel)
   //AvExcel(cArqOrigem,cAlias,lXml)
   
/*   
   Local oExcelApp
   //Local cDirDocs := MsDocPath()
   Local cPath	:= AllTrim(GetTempPath())
   DbSelectArea("Work")
  
   if lExcel
         Work->(dbCloseArea())
         CpyS2T(".\"+curdir()+cNomArq+".DBF",cPath, .T. )
         If ! ApOleClient( 'MsExcel' )
            MsgStop(STR0046)  //"Ms-Excel não instalado."
            RETURN .F.
         Else
            oExcelApp:= MsExcel():New()
            oExcelApp:WorkBooks:Open( cPath+cNomArq+".dbf" )
            oExcelApp:SetVisible(.T.)
         EndIf
   Else
         TR350ARQUIVO("work")   
         Work->(dbCloseArea())
   EndIf
*/
Return .T.

// PLB 17/07/06 - Imprime os saldos de cada contrato
*-------------------------------*
Static Function MV160ImpSaldo()
*-------------------------------*
 Local nPos := 0

   EF1->(dbsetorder(1))
   If EF1->(dbseek(cFilEF1+IF(lEFFTpMod, cModAt,"")+cContrato)) .or. (work->(recno())>=work->(EasyReccount("Work")) .and. !empty(cNroCont) )
      //ALCIR ALVES - 23-05-05   - TOTAIS POR PERIODO
      if mv_par13=1 .or. mv_par13=3
         nPos:=aScan(aTotal_p,{|X| X[1] == (cFilEF1+cContrato)})
         IF nPos>0
            PulaLinha()
            @ Linha, 000 PSAY Repli("-",189)
            Pulalinha()
            @ Linha, 000 PSAY STR0047 //"Saldos por periodo:"

            //IF !lEFFTpMod .Or. EF1->EF1_TPMODU = "E" //HVR - Não imprime qdo importação
               Pulalinha()
               @ Linha,00 PSAY Left(IIF(lCadFin,Posicione("EF7",1,xFilial("EF7")+EF1->EF1_TP_FIN,"EF7_DESCRI"),Posicione("SX5",1,xFilial("SX5")+"CG"+EF1->EF1_TP_FIN,"X5_DESCRI")),15) //HVR
               @ Linha,017 PSAY cTitMoeP 
               @ Linha,030 PSAY TRANS(aTotal_p[nPos,2], cPictMoeP)
               @ Linha,062 PSAY cTitMoeR 
               @ Linha,075 PSAY TRANS(aTotal_p[nPos,3], cPictMoeR)
               @ Linha,107 PSAY cTitMoeJP
               @ Linha,120 PSAY TRANS(aTotal_p[nPos,4] ,cPictMoeJPctVL)
               @ Linha,152 PSAY cTitMoeJR
               @ Linha,164 PSAY TRANS(aTotal_p[nPos,5], cPictMoeJRctVL)
               //Pulalinha()
            //EndIf //HVR
            
            //If lImprime .And. EF1->EF1_TP_FIN == "01"
            If !lEFFTpMod .Or. EF1->EF1_CAMTRA != "1"   // PLB 17/07/06 - Imprime se nao tiver Parcelas de Pagamento
               PulaLinha()                           
               @ Linha, 017 PSAY cTitMoeP2
               @ Linha, 030 PSAY TRANS(aTotal_p[nPos,6], cPictMoeP2)
               @ Linha, 062 PSAY cTitMoeR2
               @ Linha, 075 PSAY TRANS(aTotal_p[nPos,7], cPictMoeR2)
               @ Linha, 107 PSAY cTitMoe2Jp
               @ Linha, 120 PSAY TRANS(aTotal_p[nPos,8], cPicMoe2JP)
               @ Linha, 152 PSAY cTitMoe2JR
               @ Linha, 164 PSAY TRANS(aTotal_p[nPos,9], cPicMoe2JR)
            EndIf

               PulaLinha()
               @ Linha, 017  PSAY cMoe2PRM
               @ Linha, 030  PSAY TRANS(aTotal_p[nPos,10], cPictMoeP2)
               @ Linha, 062 PSAY cMoePRR 
               @ Linha, 075 PSAY TRANS(aTotal_p[nPos,11], cPictMoeR2)
               @ Linha, 107 PSAY cMoe2JRM
               @ Linha, 120 PSAY TRANS(aTotal_p[nPos,12], cPicMoe2JP)
               @ Linha, 152 PSAY cMoeJRR
               @ Linha, 164 PSAY TRANS(aTotal_p[nPos,13], cPicMoe2JR)
            //Endif   
            PulaLinha()
            @ Linha, 000 PSAY Repli("-",189)      

         endif
      endif
      
      if mv_par13=2 .or. mv_par13=3  //Alcir Alves - 23-05-05
      PulaLinha()
      @ Linha, 000 PSAY Repli("=",189)
      Pulalinha()
      @ Linha, 000 PSAY STR0024 //"Saldos Totais :"
     
      //IF !lEFFTpMod  .Or.  EF1->EF1_TPMODU = "E" //HVR - Não imprime qdo importação
         Pulalinha()
         @ Linha,017 PSAY cTitMoeP 
         @ Linha,030 PSAY TRANS(EF1->EF1_SLD_PM, cPictMoeP)
         @ Linha,062 PSAY cTitMoeR 
         @ Linha,075 PSAY TRANS(EF1->EF1_SLD_PR, cPictMoeR)

         @ Linha,107 PSAY cTitMoeJP
         @ Linha,120 PSAY TRANS(EF1->EF1_SLD_JM ,cPictMoeJPctVL)
         @ Linha,152 PSAY cTitMoeJR
         @ Linha,164 PSAY TRANS(EF1->EF1_SLD_JR, cPictMoeJRctVL)
         //Pulalinha()
      //EndIf

      //If lImprime .And. EF1->EF1_TP_FIN == "01"
      If !lEFFTpMod .Or. EF1->EF1_CAMTRA != "1"   // PLB 17/07/06 - Imprime se nao tiver Parcelas de Pagamento
         PulaLinha()                           
         @ Linha, 017 PSAY cTitMoeP2
         @ Linha, 030 PSAY TRANS(EF1->EF1_SL2_PM, cPictMoeP2)
         @ Linha, 062 PSAY cTitMoeR2
         @ Linha, 075 PSAY TRANS(EF1->EF1_SL2_PR, cPictMoeR2)
         @ Linha, 107 PSAY cTitMoe2Jp
         @ Linha, 120 PSAY TRANS(EF1->EF1_SL2_JM, cPicMoe2JP)
         @ Linha, 152 PSAY cTitMoe2JR
         @ Linha, 164 PSAY TRANS(EF1->EF1_SL2_JR, cPicMoe2JR)
      EndIf
         PulaLinha()
         @ Linha, 017 PSAY cMoe2PRM
         @ Linha, 030 PSAY TRANS(EF1->EF1_LIQPRM, cPictMoeR2)
         @ Linha, 062 PSAY cMoePRR
         @ Linha, 075 PSAY TRANS(EF1->EF1_LIQPRR, cPictMoeP2)
         @ Linha, 107 PSAY cMoe2JRM
         @ Linha, 120 PSAY TRANS(EF1->EF1_LIQJRM, cPicMoe2JR)
         @ Linha, 152 PSAY cMoeJRR
         @ Linha, 164 PSAY TRANS(EF1->EF1_LIQJRR, cPicMoe2JP)

     // Endif   

      PulaLinha()
      @ Linha, 000 PSAY Repli("=",189)      
      PulaLinha()
      Endif
   Endif

Return .T.
