//
// Atencao RAMALHO
//
// Arquivos a ser abertos
// 	"EC2"	"EC3"	"EC5"	"EC6"	
// 	"EE7"	"EEA"	"EEC"	"EEL"
// 	"SA2"	"SW1"	"SW2"	"SW6"
//	"SWD"	"SWM"	"SY1"	"SY6"
//	"SY9"	"SYA"	"SB1"	"SWC"
//	"SWG"	"SYB"	"SYL"	"SYJ"
//  "SA1"
//	Todas funcoes comecam com AVG508 mais o alias do arquivo

Function AVG508EC2
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("EC2")
cNomeTab := FWX2Nome("EC2")
DbSelectArea("EC2")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
	EC2->EC2_FIM_CT := if(Upper(EC2->EC2_FIM_CT)=="S","1",;
                       if(Upper(EC2->EC2_FIM_CT)=="N","2",EC2->EC2_FIM_CT))
	MsRUnlock()
	DbSkip()
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.

Function AVG508EC3
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("EC3")
cNomeTab := FWX2Nome("EC3")
DbSelectArea("EC3")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
	EC3->EC3_FIM_CT := if(Upper(EC3->EC3_FIM_CT)=="S","1",;
	                   if(Upper(EC3->EC3_FIM_CT)=="N","2",EC3->EC3_FIM_CT))
	MsRUnlock()
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.
                                                   

Function AVG508EC5
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("EC5")
cNomeTab := FWX2Nome("EC5")
DbSelectArea("EC5")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    EC5->EC5_AMOS := if(Upper(EC5->EC5_AMOS)=="S","1",;
                     if(Upper(EC5->EC5_AMOS)=="N","2",EC5->EC5_AMOS))
	MsRUnlock()
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.

Function AVG508EC6
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("EC6")
cNomeTab := FWX2Nome("EC6")
DbSelectArea("EC6")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    EC6->EC6_FINANC := if(Upper(EC6->EC6_FINANC)=="S","1",;
                       if(Upper(EC6->EC6_FINANC)=="N","2",EC6->EC6_FINANC))
	MsRUnlock()
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.

Function AVG508EE7
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("EE7")
cNomeTab := FWX2Nome("EE7")
DbSelectArea("EE7")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    EE7->EE7_AMOSTR := if(Upper(EE7->EE7_AMOSTR)=="S","1",;
                       if(Upper(EE7->EE7_AMOSTR)=="N","2",EE7->EE7_AMOSTR))
    EE7->EE7_EXLIMP := if(Upper(EE7->EE7_EXLIMP)=="S","1",;
                       if(Upper(EE7->EE7_EXLIMP)=="N","2",EE7->EE7_EXLIMP))
    EE7->EE7_PRECOA := if(Upper(EE7->EE7_PRECOA)=="S","1",;
                       if(Upper(EE7->EE7_PRECOA)=="N","2",EE7->EE7_PRECOA))
    EE7->EE7_PGTANT := if(Upper(EE7->EE7_PGTANT)=="S","1",;
                       if(Upper(EE7->EE7_PGTANT)=="N","2",EE7->EE7_PGTANT))
    EE7->EE7_BRUEMB := if(Upper(EE7->EE7_BRUEMB)=="S","1",;
                       if(Upper(EE7->EE7_BRUEMB)=="N","2",EE7->EE7_BRUEMB))
    EE7->EE7_AMOSTR := if(Upper(EE7->EE7_AMOSTR)=="S","1",;
                       if(Upper(EE7->EE7_AMOSTR)=="N","2",EE7->EE7_AMOSTR))
	MsRUnlock()                       
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.

Function AVG508EEA
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("EEA")
cNomeTab := FWX2Nome("EEA")
DbSelectArea("EEA")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    EEA->EEA_CNTLIM := if(Upper(EEA->EEA_CNTLIM)=="S","1",;
                       if(Upper(EEA->EEA_CNTLIM)=="N","2",EEA->EEA_CNTLIM))
    EEA->EEA_FASE   := if(Upper(EEA->EEA_FASE)=="T","1",;
	  				   if(Upper(EEA->EEA_FASE)=="P","2",;
                       if(Upper(EEA->EEA_FASE)=="E","3",;   					   
                       if(Upper(EEA->EEA_FASE)=="F","4",EEA->EEA_FASE))))
	MsRUnlock()                       
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.    

Function AVG508EEC
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("EEC")
cNomeTab := FWX2Nome("EEC")
DbSelectArea("EEC")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    EEC->EEC_AMOSTR := if(Upper(EEC->EEC_AMOSTR)=="S","1",;
                       if(Upper(EEC->EEC_AMOSTR)=="N","2",EEC->EEC_AMOSTR))
    EEC->EEC_EXLIMP := if(Upper(EEC->EEC_EXLIMP)=="S","1",;
                       if(Upper(EEC->EEC_EXLIMP)=="N","2",EEC->EEC_EXLIMP))
    EEC->EEC_PRECOA := if(Upper(EEC->EEC_PRECOA)=="S","1",;
                       if(Upper(EEC->EEC_PRECOA)=="N","2",EEC->EEC_PRECOA))
    EEC->EEC_PGTANT := if(Upper(EEC->EEC_PGTANT)=="S","1",;
                       if(Upper(EEC->EEC_PGTANT)=="N","2",EEC->EEC_PGTANT))
    EEC->EEC_COBCAM := if(Upper(EEC->EEC_COBCAM)=="S","1",;
                       if(Upper(EEC->EEC_COBCAM)=="N","2",EEC->EEC_COBCAM))
    EEC->EEC_BRUEMB := if(Upper(EEC->EEC_BRUEMB)=="S","1",;
                       if(Upper(EEC->EEC_BRUEMB)=="N","2",EEC->EEC_BRUEMB))
    EEC->EEC_DECAM  := if(Upper(EEC->EEC_DECAM) =="S","1",;
                       if(Upper(EEC->EEC_DECAM) =="N","2",EEC->EEC_DECAM))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.                                  

Function AVG508EEL
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("EEL")
cNomeTab := FWX2Nome("EEL")
DbSelectArea("EEL")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    EEL->EEL_TRANSB := if(Upper(EEL->EEL_TRANSB)=="S","1",;
                       if(Upper(EEL->EEL_TRANSB)=="N","2",EEL->EEL_TRANSB))
    EEL->EEL_EMBPAR := if(Upper(EEL->EEL_EMBPAR)=="S","1",;
                       if(Upper(EEL->EEL_EMBPAR)=="N","2",EEL->EEL_EMBPAR))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.                                  

Function AVG508SA1
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SA1")
cNomeTab := FWX2Nome("SA1")
DbSelectArea("SA1")
DbGoTop()
UpdSet01(LastRec())
DO While ! eof()
	MsRLock()
	SA1->A1_TIPCLI := if(Upper(SA1->A1_TIPCLI)=="I","1",;
                      IF(Upper(SA1->A1_TIPCLI)=="C","2",;
                      IF(Upper(SA1->A1_TIPCLI)=="N","3",;
                      IF(Upper(SA1->A1_TIPCLI)=="T","4",SA1->A1_TIPCLI))))
	MsRUnlock()
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return(.t.)

Function AVG508SA2
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SA2")
cNomeTab := FWX2Nome("SA2")
DbSelectArea("SA2")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SA2->A2_ID_REPR := if(Upper(SA2->A2_ID_REPR)=="S","1",;
                       if(Upper(SA2->A2_ID_REPR)=="N","2",SA2->A2_ID_REPR))
    SA2->A2_RET_PAI := if(Upper(SA2->A2_RET_PAI)=="S","1",;
                       if(Upper(SA2->A2_RET_PAI)=="N","2",SA2->A2_RET_PAI))
 	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.                                  

Function AVG508SB1
Local cNomeTab := ""
Local cAux :=""
DbSelectArea("SX2")
DbSeek("SB1")
cNomeTab := FWX2Nome("SB1")
DbSelectArea("SB1")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SB1->B1_ANUENTE := if(Upper(SB1->B1_ANUENTE)=="S","1",;
                       if(Upper(SB1->B1_ANUENTE)=="N","2",SB1->B1_ANUENTE))
    SB1->B1_MIDIA   := if(Upper(SB1->B1_MIDIA)  =="S","1",;
                       if(Upper(SB1->B1_MIDIA)  =="N","2",SB1->B1_MIDIA))
    If FieldPos("B1_QTD_EMB") <> 0
    	SB1->B1_QE := SB1->B1_QTD_EMB
    EndIf                             
    If FieldPos("B1_CRTORG") <> 0
    	cAux := SB1->B1_ORIGEM
    	SB1->B1_ORIGEM := if(Upper(SB1->B1_CRTORG)=="1","0",;
						  if(Upper(SB1->B1_CRTORG)=="2","1",;
						  if(Upper(SB1->B1_CRTORG)=="3"," ",SB1->B1_ORIGEM)))+;
						  Substr(cAux,2,1)
    EndIf
    MsRUnlock()                       
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.    

Function AVG508SW1
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SW1")
cNomeTab := FWX2Nome("SW1")
DbSelectArea("SW1")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SW1->W1_FORECAS := if(Upper(SW1->W1_FORECAS)=="S","1",;
                       if(Upper(SW1->W1_FORECAS)=="N","2",SW1->W1_FORECAS))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t. 

Function AVG508SW2
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SW2")
cNomeTab := FWX2Nome("SW2")
DbSelectArea("SW2")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SW2->W2_E_LC  := if(Upper(SW2->W2_E_LC) =="S","1",;
                     if(Upper(SW2->W2_E_LC) =="N","2",SW2->W2_E_LC))
    SW2->W2_COMIS := if(Upper(SW2->W2_COMIS)=="S","1",;
                     if(Upper(SW2->W2_COMIS)=="N","2",SW2->W2_COMIS))
	MsRUnlock()                  		         
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t. 

Function AVG508SW6
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SW6")
cNomeTab := FWX2Nome("SW6")
DbSelectArea("SW6")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SW6->W6_PROB_DI := if(Upper(SW6->W6_PROB_DI)=="S","1",;
                       if(Upper(SW6->W6_PROB_DI)=="N","2",SW6->W6_PROB_DI))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t. 

Function AVG508SWC
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SWC")
cNomeTab := FWX2Nome("SWC")
DbSelectArea("SWC")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SWC->WC_TRANSB  := if(Upper(SWC->WC_TRANSB) =="S","1",;
                       if(Upper(SWC->WC_TRANSB) =="N","2",SWC->WC_TRANSB))
    SWC->WC_EMB_PAR := if(Upper(SWC->WC_EMB_PAR)=="S","1",;
                       if(Upper(SWC->WC_EMB_PAR)=="N","2",SWC->WC_EMB_PAR))
    SWC->WC_BASE    := if(Upper(SWC->WC_BASE)   =="L","1",;
                       if(Upper(SWC->WC_BASE)   =="P","2",SWC->WC_BASE))
    SWC->WC_PERVAL  := if(Upper(SWC->WC_PERVAL) =="P","1",;
                       if(Upper(SWC->WC_PERVAL) =="V","2",SWC->WC_PERVAL))
    MsRUnlock()                       
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.           

Function AVG508SWD
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SWD")
cNomeTab := FWX2Nome("SWD")
DbSelectArea("SWD")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SWD->WD_BASEADI := if(Upper(SWD->WD_BASEADI)=="S","1",;
                       if(Upper(SWD->WD_BASEADI)=="N","2",SWD->WD_BASEADI))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t. 

Function AVG508SWG
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SWG")
cNomeTab := FWX2Nome("SWG")
DbSelectArea("SWG")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SWG->WG_FINANC := if(Upper(SWG->WG_FINANC)=="E","1",;
	   			      if(Upper(SWG->WG_FINANC)=="F","2",;
	   			      if(Upper(SWG->WG_FINANC)=="B","3",SWG->WG_FINANC)))
    SWG->WG_COMAGR := if(Upper(SWG->WG_COMAGR)=="S","1",;
                      if(Upper(SWG->WG_COMAGR)=="N","2",SWG->WG_COMAGR))
    SWG->WG_ESQ_JR := if(Upper(SWG->WG_ESQ_JR)=="S","1",;
                      if(Upper(SWG->WG_ESQ_JR)=="N","2",SWG->WG_ESQ_JR))
    SWG->WG_LIQUID := if(Upper(SWG->WG_LIQUID)=="S","1",;
                      if(Upper(SWG->WG_LIQUID)=="N","2",SWG->WG_LIQUID))
    MsRUnlock()                       
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.           

Function AVG508SWM
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SWM")
cNomeTab := FWX2Nome("SWM")
DbSelectArea("SWM")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SWM->WM_VINCUL := if(Upper(SWM->WM_VINCUL)=="S","1",;
                      if(Upper(SWM->WM_VINCUL)=="N","2",SWM->WM_VINCUL))
    SWM->WM_ENCERR := if(Upper(SWM->WM_ENCERR)=="S","1",;
                      if(Upper(SWM->WM_ENCERR)=="N","2",SWM->WM_ENCERR))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t. 
                                       
Function AVG508SY1
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SY1")
cNomeTab := FWX2Nome("SY1")
DbSelectArea("SY1")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SY1->Y1_PEDIDO := if(Upper(SY1->Y1_PEDIDO)=="S","1",;
                      if(Upper(SY1->Y1_PEDIDO)=="N","2",SY1->Y1_PEDIDO))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.                                     

Function AVG508SY6
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SY6")
cNomeTab := FWX2Nome("SY6")
DbSelectArea("SY6")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SY6->Y6_COM_LC  := if(Upper(SY6->Y6_COM_LC) =="S","1",;
                       if(Upper(SY6->Y6_COM_LC) =="N","2",SY6->Y6_COM_LC))
    SY6->Y6_COBERTU := if(Upper(SY6->Y6_COBERTU)=="S","1",;
                       if(Upper(SY6->Y6_COBERTU)=="N","2",SY6->Y6_COBERTU))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.                                        

Function AVG508SY9
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SY9")
cNomeTab := FWX2Nome("SY9")
DbSelectArea("SY9")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SY9->Y9_DAP := if(Upper(SY9->Y9_DAP)=="S","1",;
                   if(Upper(SY9->Y9_DAP)=="N","2",SY9->Y9_DAP))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.                             

Function AVG508SYA
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SYA")
cNomeTab := FWX2Nome("SYA")
DbSelectArea("SYA")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SYA->YA_NALADI  := if(Upper(SYA->YA_NALADI) =="S","1",;
                       if(Upper(SYA->YA_NALADI) =="N","2",SYA->YA_NALADI))
    SYA->YA_ALADI   := if(Upper(SYA->YA_ALADI)  =="S","1",;
                       if(Upper(SYA->YA_ALADI)  =="N","2",SYA->YA_ALADI))
    SYA->YA_COMUM   := if(Upper(SYA->YA_COMUM)  =="S","1",;
                       if(Upper(SYA->YA_COMUM)  =="N","2",SYA->YA_COMUM))
    SYA->YA_MERCOSU := if(Upper(SYA->YA_MERCOSU)=="S","1",;
                       if(Upper(SYA->YA_MERCOSU)=="N","2",SYA->YA_MERCOSU))
    SYA->YA_SGPC    := if(Upper(SYA->YA_SGPC)   =="S","1",;
                       if(Upper(SYA->YA_SGPC)   =="N","2",SYA->YA_SGPC))
    SYA->YA_LI      := if(Upper(SYA->YA_LI)     =="S","1",;
                       if(Upper(SYA->YA_LI)     =="N","2",SYA->YA_LI))
	MsRUnlock()                           
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.                         

Function AVG508SYB
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SYB")
cNomeTab := FWX2Nome("SYB")
DbSelectArea("SYB")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SYB->YB_OCORREN := if(Upper(SYB->YB_OCORREN)=="P","1",;
                       if(Upper(SYB->YB_OCORREN)=="E","2",SYB->YB_OCORREN))
    MsRUnlock()                       
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t. 

Function AVG508SYJ
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SYJ")
cNomeTab := FWX2Nome("SYJ")
DbSelectArea("SYJ")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
	SYJ->YJ_CLFRETE := if(Upper(SYJ->YJ_CLFRETE)=="S","1",;
                       if(Upper(SYJ->YJ_CLFRETE)=="N","2",SYJ->YJ_CLFRETE))
	SYJ->YJ_CLSEGUR := if(Upper(SYJ->YJ_CLSEGUR)=="S","1",;
                       if(Upper(SYJ->YJ_CLSEGUR)=="N","2",SYJ->YJ_CLSEGUR))
	MsRUnlock()
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t.

Function AVG508SYL
Local cNomeTab := ""
DbSelectArea("SX2")
DbSeek("SYL")
cNomeTab := FWX2Nome("SYL")
DbSelectArea("SYL")
DbGoTop()
UpdSet01(LastRec())
While .not. eof()
	MsRLock()
    SYL->YL_FORMPEQ := if(Upper(SYL->YL_FORMPEQ)=="S","1",;
                       if(Upper(SYL->YL_FORMPEQ)=="N","2",SYL->YL_FORMPEQ))
    SYL->YL_FONTEC  := if(Upper(SYL->YL_FONTEC) =="S","1",;
                       if(Upper(SYL->YL_FONTEC) =="N","2",SYL->YL_FONTEC))
    SYL->YL_ABERTO  := if(Upper(SYL->YL_ABERTO) =="S","1",;
                       if(Upper(SYL->YL_ABERTO) =="N","2",SYL->YL_ABERTO))
    SYL->YL_ENTREG  := if(Upper(SYL->YL_ENTREG) =="S","1",;
                       if(Upper(SYL->YL_ENTREG) =="N","2",SYL->YL_ENTREG))
    SYL->YL_STATUSP := if(Upper(SYL->YL_STATUSP)=="S","1",;
                       if(Upper(SYL->YL_STATUSP)=="N","2",SYL->YL_STATUSP))
    SYL->YL_SUMARIZ := if(Upper(SYL->YL_SUMARIZ)=="S","1",;
                       if(Upper(SYL->YL_SUMARIZ)=="N","2",SYL->YL_SUMARIZ))
    SYL->YL_ORIGEM  := if(Upper(SYL->YL_ORIGEM) =="S","1",;
                       if(Upper(SYL->YL_ORIGEM) =="P","2",;
	                   if(Upper(SYL->YL_ORIGEM) =="G","3",;
	    			   if(Upper(SYL->YL_ORIGEM) =="D","4",;
	    			   if(Upper(SYL->YL_ORIGEM) =="T","5",SYL->YL_ORIGEM)))))
    MsRUnlock()                       
	DbSkip()	
	UpdInc01(cNomeTab, .t.)
End                  
Return .t. 
*--------------------------------------------------------------------