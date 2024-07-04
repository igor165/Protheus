#INCLUDE "ECOUpdate.CH"
/*
Programa : ECOUpdate
Autor    : Victor Iotti
Data     : 17/12/03 10:30.
Uso      : Funções diversas - Update.
Revisao  : 
*/

/*
Funcao      : ECOEC5()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do código do fornecedor e moeda.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOEC5()
*----------------------------*
Local cFilECA:=xFilial("ECA"), cFilEC8:=xFilial("EC8"), cFilEC2:=xFilial("EC2"),;
      cFilEC5:=xFilial("EC5"), cFilEC9:=xFilial("EC9"), cFilSW9:=xFilial("SW9"),;
      nProx:=0, nAtual :=0, nProxPrin:=0, nAtualPrin :=0
EC2->(DbSetOrder(1))         
EC5->(DbSetOrder(1))
SW9->(DbSetOrder(1))
EC8->(DbSetOrder(1))
EC9->(DbSetOrder(1))
ECA->(DbSetOrder(1))
UpdSet01(EC5->(LastRec())+ECA->(LastRec()))

ECA->(DBSEEK(cFilECA))
DO WHILE ECA->(!EOF()) .AND. ECA->ECA_FILIAL==cFilECA .And. Empty(ECA->ECA_TPMODU)
   UpdInc01(STR0001+AllTrim(ECA->ECA_HAWB)) // "Ajuste da Tabela Contábel Imp./Exp.: "
   // Grava no campo ECA_TPMODU o flag 'IMPORT'
   RECLOCK("ECA",.F.)
   ECA->ECA_TPMODU :='IMPORT'      
   ECA->(MSUNLOCK())
   ECA->(DBSEEK(cFilECA))
ENDDO               
   
ECA->(DbSetOrder(3))
EC5->(DBSEEK(cFilEC5))
DO WHILE EC5->(!EOF()) .AND. EC5->EC5_FILIAL==cFilEC5 
   UpdInc01(STR0002+AllTrim(EC5->EC5_INVOIC)) // "Ajustes Contábeis Imp./Exp. Inv.: "
   nProxPrin  := 0
   nAtualPrin := 0
   
   If Empty(EC5->EC5_FORN) .or. Empty(EC5->EC5_MOE_FO)
      If SW9->(DBSEEK(cFilSW9+EC5->EC5_INVOIC))
         Do While ! SW9->(EOF()) .And. EC5->EC5_INVOIC = SW9->W9_INVOICE .And. cFilSW9 = SW9->W9_FILIAL
            If Alltrim(EC5->EC5_HAWB) = Alltrim(SW9->W9_HAWB)
               nAtualPrin := EC5->(RECNO())
               EC5->(DBSKIP())
               nProxPrin  := EC5->(RECNO())
               EC5->(DBGOTO(nAtualPrin))
               RECLOCK("EC5",.F.)
               EC5->EC5_FORN   := SW9->W9_FORN
               EC5->EC5_MOE_FO := SW9->W9_MOE_FOB
               EC5->(MSUNLOCK())
               EXIT
            EndIf
            SW9->(DBSKIP())
         EndDo
      EndIf
   EndIf

   // Atualiza o EC2
   IF EC2->(DBSEEK(cFilEC2+EC5->EC5_HAWB))
//      (EC2->EC2_FORN+EC2->EC2_MOEDA) # (EC5->EC5_FORN+EC5->EC5_MOE_FO) 
      If Empty(EC2->EC2_FORN) .or. Empty(EC2->EC2_MOEDA)
         RECLOCK("EC2",.F.)
         EC2->EC2_FORN :=EC5->EC5_FORN
         EC2->EC2_MOEDA:=EC5->EC5_MOE_FO
         EC2->(MSUNLOCK())
      EndIf
   ENDIF             
   
   If !Empty(EC5->EC5_FORN) .Or. !Empty(EC5->EC5_MOE_FO)
      // Atualiza o EC8
      
      EC8->(DBSEEK(cFilEC8+EC5->EC5_HAWB+SPACE(LEN(EC5->EC5_FORN)+LEN(EC5->EC5_MOE_FO))))                             
      If EC8->(Eof())
         EC8->(DBSEEK(cFilEC8+EC5->EC5_HAWB+SPACE(LEN(EC5->EC5_FORN))+EC5->EC5_MOE_FO))                             
      EndIf
      If EC8->(Eof())
         EC8->(DBSEEK(cFilEC8+EC5->EC5_HAWB+EC5->EC5_FORN+SPACE(LEN(EC5->EC5_MOE_FO))))
      EndIf
      Do While EC8->(!Eof()) .And. EC8->EC8_HAWB == EC5->EC5_HAWB
         nAtual:=0
         nProx:=0
         If (EC8->EC8_FORN+EC8->EC8_MOEDA) # (EC5->EC5_FORN+EC5->EC5_MOE_FO) .and.;
            (Empty(EC8->EC8_FORN) .or. Empty(EC8->EC8_MOEDA))
            nAtual:= EC8->(RECNO())
            EC8->(DBSKIP())        
            nProx:=EC8->(RECNO())  
            EC8->(DBGOTO(nAtual))          
            RECLOCK("EC8",.F.)
            EC8->EC8_FORN :=EC5->EC5_FORN
            EC8->EC8_MOEDA:=EC5->EC5_MOE_FO   
            EC8->(MSUNLOCK())     
         EndIf
         If nProx # 0
            EC8->(DBGOTO(nProx))          
         Else
            EC8->(Dbskip())
         EndIf         
      Enddo
   
      // Atualiza o ECA  
      ECA->(DBSEEK(cFilECA+'IMPORT'+Space(Len(EC5->EC5_FORN))+EC5->EC5_INVOIC))
      Do While ECA->(!Eof()) .And. ECA->ECA_FILIAL = cFilECA .And. ECA->ECA_FORN+ECA->ECA_INVOIC == Space(Len(EC5->EC5_FORN))+EC5->EC5_INVOIC
         RECLOCK("ECA",.F.)
         ECA->ECA_FORN   := EC5->EC5_FORN
         ECA->ECA_MOEDA  := EC5->EC5_MOE_FO
         ECA->(MSUNLOCK())             
         ECA->(DbGotop())        
         ECA->(DBSEEK(cFilECA+Space(Len(EC5->EC5_FORN))+EC5->EC5_INVOIC)) 
      Enddo
   Endif
   
   If !Empty(EC5->EC5_FORN)   
      // Atualiza o EC9  
      EC9->(DBSEEK(cFilEC9+Space(Len(EC5->EC5_FORN))+EC5->EC5_INVOIC)) 
      Do While EC9->(!Eof()) .And. EC9->EC9_FILIAL = cFilEC9 .And. EC9->EC9_FORN+EC9->EC9_INVOIC == Space(Len(EC5->EC5_FORN))+EC5->EC5_INVOIC                          
         RECLOCK("EC9",.F.)
         EC9->EC9_FORN :=EC5->EC5_FORN
         EC9->(MSUNLOCK())       
         EC9->(DbGotop())                       
         EC9->(DBSEEK(cFilEC9+Space(Len(EC5->EC5_FORN))+EC5->EC5_INVOIC)) 
      Enddo   
   Endif   

   If nProxPrin # 0
      EC5->(DBGOTO(nProxPrin))
   Else
      EC5->(DBSKIP())
   EndIf
ENDDO   
ECA->(DbSetOrder(1))   
RETURN .T.

/*
Funcao      : ECOEC2()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do código do fornecedor e moeda.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOEC2()
*----------------------------*
Local cFilEC3:=xFilial("EC3"), cFilEC4:=xFilial("EC4"), cFilEC7:=xFilial("EC7"),;
      cFilEC2:=xFilial("EC2"), nAtual:=0, nProx:=0
EC2->(DbSetOrder(1))         
EC3->(DbSetOrder(3))                                           
EC4->(DbSetOrder(1))                                           
EC7->(DbSetOrder(2))
UpdSet01(EC2->(LastRec()))
EC2->(DBSEEK(cFilEC2))
DO WHILE EC2->(!EOF()) .AND. EC2->EC2_FILIAL==cFilEC2 
   UpdInc01(STR0003+AllTrim(EC2->EC2_HAWB)) // "Ajustes Contábeis Imp./Exp. Processo.: "
   If !Empty(EC2->EC2_FORN) .OR. !Empty(EC2->EC2_MOEDA)                                                                                 
      // Atualiza o EC3
      EC3->(DBSEEK(cFilEC3+EC2->EC2_HAWB+SPACE(LEN(EC2->EC2_FORN)+Len(EC2->EC2_MOEDA))))
      If EC3->(Eof())
         EC3->(DBSEEK(cFilEC3+EC2->EC2_HAWB+SPACE(LEN(EC2->EC2_FORN))+EC2->EC2_MOEDA)) 
      EndIf
      If EC3->(Eof())
         EC3->(DBSEEK(cFilEC3+EC2->EC2_HAWB+EC2->EC2_FORN+SPACE(Len(EC2->EC2_MOEDA))))
      EndIf
      Do While EC3->(!Eof()) .And. EC3->EC3_FILIAL = cFilEC3 .And. EC3->EC3_HAWB == EC2->EC2_HAWB
         nAtual:=0
         nProx :=0
         If (EC3->EC3_FORN+EC3->EC3_MOEDA) # (EC2->EC2_FORN+EC2->EC2_MOEDA) .and.;
            (Empty(EC3->EC3_FORN) .or. Empty(EC3->EC3_MOEDA))
            nAtual:= EC3->(RECNO())
            EC3->(DBSKIP())        
            nProx:=EC3->(RECNO())  
            EC3->(DBGOTO(nAtual))          
            RECLOCK("EC3",.F.)
            EC3->EC3_FORN :=EC2->EC2_FORN
            EC3->EC3_MOEDA:=EC2->EC2_MOEDA   
            EC3->(MSUNLOCK())                          
         EndIf             
         If nProx # 0
            EC3->(DBGOTO(nProx))          
         Else
            EC3->(Dbskip())
         EndIf
      ENDDO
   
      // Atualiza o EC4                 
      
      EC4->(DBSEEK(cFilEC4+EC2->EC2_HAWB+SPACE(LEN(EC2->EC2_FORN))+SPACE(LEN(EC2->EC2_MOEDA)))) 
      If EC4->(Eof())
         EC4->(DBSEEK(cFilEC4+EC2->EC2_HAWB+SPACE(LEN(EC2->EC2_FORN))+EC2->EC2_MOEDA))
      EndIf
      If EC4->(Eof())
         EC4->(DBSEEK(cFilEC4+EC2->EC2_HAWB+EC2->EC2_FORN+SPACE(LEN(EC2->EC2_MOEDA)))) 
      EndIf      
      Do While EC4->(!Eof()) .And. EC4->EC4_FILIAL = cFilEC4 .And. EC4->EC4_HAWB == EC2->EC2_HAWB
         nAtual:=0
         nProx :=0
         If (EC4->EC4_FORN+EC4->EC4_MOEDA) # (EC2->EC2_FORN+EC2->EC2_MOEDA) .and.;
            (Empty(EC4->EC4_FORN) .or. Empty(EC4->EC4_MOEDA))         
            nAtual:= EC4->(RECNO())
            EC4->(DBSKIP())        
            nProx:=EC4->(RECNO())  
            EC4->(DBGOTO(nAtual))          
            RECLOCK("EC4",.F.)
            EC4->EC4_FORN :=EC2->EC2_FORN
            EC4->EC4_MOEDA:=EC2->EC2_MOEDA   
            EC4->(MSUNLOCK())       
         EndIf
         If nProx # 0
            EC4->(DBGOTO(nProx))          
         Else
            EC4->(Dbskip())
         EndIf
      ENDDO            
                  
      //Atualiza o EC7                                                                
      EC7->(DBSEEK(cFilEC7+EC2->EC2_HAWB+SPACE(LEN(EC2->EC2_FORN))+SPACE(LEN(EC2->EC2_MOEDA)))) 
      If EC7->(Eof())
         EC7->(DBSEEK(cFilEC7+EC2->EC2_HAWB+SPACE(LEN(EC2->EC2_FORN))+EC2->EC2_MOEDA))
      EndIf
      If EC7->(Eof())
         EC7->(DBSEEK(cFilEC7+EC2->EC2_HAWB+EC2->EC2_FORN+SPACE(LEN(EC2->EC2_MOEDA)))) 
      EndIf
      Do While EC7->(!Eof()) .And. EC7->EC7_FILIAL = cFilEC7 .And. EC7->EC7_HAWB == EC2->EC2_HAWB
         nAtual:=0
         nProx :=0
         If (EC7->EC7_FORN+EC7->EC7_MOEDA) # (EC2->EC2_FORN+EC2->EC2_MOEDA) .and.;
            (Empty(EC7->EC7_FORN) .or. Empty(EC7->EC7_MOEDA))
            nAtual:= EC7->(RECNO())
            EC7->(DBSKIP())        
            nProx:=EC7->(RECNO())  
            EC7->(DBGOTO(nAtual))          
            RECLOCK("EC7",.F.)
            EC7->EC7_FORN :=EC2->EC2_FORN
            EC7->EC7_MOEDA:=EC2->EC2_MOEDA   
            EC7->(MSUNLOCK())       
         EndIf
         If nProx # 0
            EC7->(DBGOTO(nProx))          
         Else
            EC7->(Dbskip())
         EndIf
      ENDDO               
   Endif   
   
   EC2->(DBSKIP())
ENDDO   
EC3->(DbSetOrder(1))
EC7->(DbSetOrder(1))
RETURN .T. 

/*
Funcao      : ECOEC6()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do módulo.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOEC6()
*----------------------------*                                                      
Local cFilEC6:=xFilial("EC6")
EC6->(DbSetOrder(1))
UpdSet01(EC6->(LastRec()))   
EC6->(DBSEEK(cFilEC6))
DO WHILE EC6->(!EOF()) .AND. EC6->EC6_FILIAL==cFilEC6 .And. Empty(EC6->EC6_TPMODU)
   UpdInc01(STR0004+AllTrim(EC6->EC6_ID_CAM)) // "Ajuste dos Eventos Contábeis Imp./Exp.: "
   // Grava no campo EC6_TPMODU o flag 'IMPORT'
   RECLOCK("EC6",.F.)
   EC6->EC6_TPMODU :='IMPORT'      
   If Empty(EC6->EC6_CONTAB)
      EC6->EC6_CONTAB :='1'      
   EndIf
   If Empty(EC6->EC6_DIAMES)
      EC6->EC6_DIAMES :='2'      
   EndIf
   If Empty(EC6->EC6_TXCV)
      EC6->EC6_TXCV :='1'      
   EndIf
   EC6->(MSUNLOCK())
   EC6->(DBSEEK(cFilEC6))
ENDDO   
RETURN .T.     

/*
Funcao      : ECOEC1()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do módulo.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOEC1()
*----------------------------*
Local cFilEC1:=xFilial("EC1")
EC1->(DbSetOrder(1))
UpdSet01(EC1->(LastRec()))      
EC1->(DBSEEK(cFilEC1))
DO WHILE EC1->(!EOF()) .AND. EC1->EC1_FILIAL==cFilEC1 .And. Empty(EC1->EC1_TPMODU)
   UpdInc01(STR0005+AllTrim(EC1->EC1_MES)+"/"+AllTrim(EC1->EC1_ANO)) // "Ajuste dos Saldos Contábeis Imp./Exp.: "
   // Grava no campo EC1_TPMODU o flag 'IMPORT'
   RECLOCK("EC1",.F.)
   EC1->EC1_TPMODU :='IMPORT'      
   EC1->(MSUNLOCK())
   EC1->(DBSEEK(cFilEC1))
ENDDO   
RETURN .T.     

/*
Funcao      : ECOSYS()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do módulo.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOSYS()
*----------------------------*
Local cFilSYS:=xFilial("SYS")
SYS->(DbSetOrder(1))
UpdSet01(SYS->(LastRec()))      
SYS->(DBSEEK(cFilSYS))
DO WHILE SYS->(!EOF()) .AND. SYS->YS_FILIAL==cFilSYS .And. Empty(SYS->YS_TPMODU)     
   UpdInc01(STR0006+AllTrim(SYS->YS_HAWB)) // "Ajuste dos Rateios Contábeis Imp./Exp.: "
   // Grava no campo YS_TPMODU o flag 'I'
   RECLOCK("SYS",.F.)
   SYS->YS_TPMODU :='I'      
   SYS->(MSUNLOCK())
   SYS->(DBSEEK(cFilSYS))
ENDDO     
RETURN .T.     

/*
Funcao      : ECOECE()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do módulo.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOECE()
*----------------------------*
Local cFilECE:=xFilial("ECE")
ECE->(DbSetOrder(1))        
UpdSet01(ECE->(LastRec()))
ECE->(DBSEEK(cFilECE))
DO WHILE ECE->(!EOF()) .AND. ECE->ECE_FILIAL==cFilECE .And. Empty(ECE->ECE_TPMODU)
   UpdInc01(STR0007+AllTrim(ECE->ECE_HAWB)) // "Ajuste dos Estornos Contábeis Imp./Exp.: "
   // Grava no campo ECE_TPMODU o flag 'IMPORT'
   RECLOCK("ECE",.F.)
   ECE->ECE_TPMODU :='IMPORT'      
   ECE->(MSUNLOCK())
   ECE->(DBSEEK(cFilECE))
ENDDO   
RETURN .T.     
                        
/*
Funcao      : ECOECF()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do módulo.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOECF()
*----------------------------*
Local cFilECF:=xFilial("ECF")
ECF->(DbSetOrder(1))        
UpdSet01(ECF->(LastRec()))
ECF->(DBSEEK(cFilECF))
DO WHILE ECF->(!EOF()) .AND. ECF->ECF_FILIAL==cFilECF .And. Empty(ECF->ECF_TPMODU)
   UpdInc01(STR0008+AllTrim(ECF->ECF_HAWB))  // "Ajuste dos Adiantamentos Contábeis Imp./Exp.: "
   // Grava no campo ECF_TPMODU o flag 'IMPORT'
   RECLOCK("ECF",.F.)
   ECF->ECF_TPMODU :='IMPORT'      
   ECF->(MSUNLOCK())
   ECF->(DBSEEK(cFilECF))
ENDDO   
RETURN .T.     

/*
Funcao      : ECOECG()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do módulo.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOECG()
*----------------------------*
Local cFilECG:=xFilial("ECG")
ECG->(DbSetOrder(1))        
UpdSet01(ECG->(LastRec()))   
ECG->(DBSEEK(cFilECG))
DO WHILE ECG->(!EOF()) .AND. ECG->ECG_FILIAL==cFilECG .And. Empty(ECG->ECG_TPMODU)
   UpdInc01(STR0009+AllTrim(ECG->ECG_HAWB))  // "Ajuste dos Itens dos Adiant. Contábeis Imp./Exp.: "
   // Grava no campo ECG_TPMODU o flag 'IMPORT'
   RECLOCK("ECG",.F.)
   ECG->ECG_TPMODU :='IMPORT'      
   ECG->(MSUNLOCK())
   ECG->(DBSEEK(cFilECG))
ENDDO   
RETURN .T.     
                        
/*
Funcao      : ECOECH()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do módulo.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOECH()
*----------------------------*
Local cFilECH:=xFilial("ECH")
ECH->(DbSetOrder(1))        
UpdSet01(ECH->(LastRec()))
ECH->(DBSEEK(cFilECH))
DO WHILE ECH->(!EOF()) .AND. ECH->ECH_FILIAL==cFilECH .And. Empty(ECH->ECH_TPMODU)
   UpdInc01(STR0010+AllTrim(ECH->ECH_CONTA))  // "Ajuste dos Históricos Contábeis Imp./Exp.: "
   // Grava no campo ECH_TPMODU o flag 'IMPORT'
   RECLOCK("ECH",.F.)
   ECH->ECH_TPMODU :='IMPORT'      
   ECH->(MSUNLOCK())
   ECH->(DBSEEK(cFilECH))
ENDDO   
RETURN .T.     

/*
Funcao      : ECOEEQ()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do evento 101 e a invoice.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/

*----------------------------*
USER FUNCTION ECOEEQ()
*----------------------------*
Local cFilEEC:=xFilial("EEC"), cFilEEQ:=xFilial("EEQ")
EEC->(DbSetOrder(1))                  
EEQ->(DbSetOrder(1))        
UpdSet01(EEQ->(LastRec()))
EEQ->(DBSEEK(cFilEEQ))
DO WHILE EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL==cFilEEQ 
   UpdInc01(STR0011+AllTrim(EEQ->EEQ_PREEMB)) // "Ajuste do Câmbio p/Eventos Contábeis Exp.: "
   // Grava no campo EEQ_EVENT 101 para a invoice e o campo invoice.
   If Empty(EEQ->EEQ_EVENT) .or. Empty(EEQ->EEQ_NRINVO)
      RECLOCK("EEQ",.F.)
      If Empty(EEQ->EEQ_EVENT)
         EEQ->EEQ_EVENT := '101'           
      EndIf
      If Empty(EEQ->EEQ_NRINVO)
         If EEC->(DBSEEK(cFilEEC+EEQ->EEQ_PREEMB))
            EEQ->EEQ_NRINVO := EEC->EEC_NRINVO
         EndIf
      EndIf
      EEQ->(MSUNLOCK())
   EndIf
   EEQ->(DBSKIP())
ENDDO   
RETURN .T.     

/*
Funcao      : ECOSW8()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do unidade de medida.
Autor       : Victor Iotti
Data        : 17/12/03 10:30.
Revisao     : 
*/
           
*-----------------------------*
USER Function ECOSW8()
*-----------------------------*      
Local cFilSW8 := xFilial("SW8"), cFilSA5 := xFilial("SA5"), cFilSB1 := xFilial("SB1")
SB1->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SA5->(DBSETORDER(3))
UpdSet01(SW8->(LastRec()))   
SW8->(DBSEEK(cFilSW8))
Do While ! SW8->(EOF()) .And. cFilSW8 = SW8->W8_FILIAL
   UpdInc01(STR0012+AllTrim(SW8->W8_HAWB))  // "Ajuste da Unidade de Medida Imp.: "

   If Empty(SW8->W8_UNID)
      If SA5->A5_PRODUTO<>SW8->W8_COD_I .or. SA5->A5_FABR<>SW8->W8_FABR .or. SA5->A5_FORNECE<>SW8->W8_FORN
         SA5->(dbSeek(cFilSA5+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN))
      EndIf
      If Empty(SA5->A5_UNID)
         If SB1->B1_COD <> SW8->W8_COD_I
            SB1->(dbSeek(cFilSB1+SW8->W8_COD_I))
         EndIf
         cUnid := SB1->B1_UM
      Else
         cUnid := SA5->A5_UNID
      EndIf

      Reclock('SW8',.F.)
      SW8->W8_UNID  := cUnid
      SW8->(MSUNLOCK())                    
   EndIf                                   
   SW8->(DbSkip())                            
Enddo                              
SA5->(DBSETORDER(1))
Return .T.                    