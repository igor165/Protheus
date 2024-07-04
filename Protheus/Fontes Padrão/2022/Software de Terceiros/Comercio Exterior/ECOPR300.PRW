#INCLUDE "Ecopr300.ch"
#include "Average.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECODI210 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 26.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controle / Cancelamento da Contabilizacao                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


*-------------------*
Function ECOPR300()
*-------------------*
LOCAL cAliasAnt:=ALIAS()

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := STR0003 //"Controle da Contabiliza‡„o."
Private lTop     := .F., cFilEC1   := xFilial("EC1")                      
Private lTemTPMODU
Private bTPMODUECF 
Private bTPMODUECG
Private bTPMODUECE

#IFDEF TOP
  IF (TcSrvType() != "AS/400") // Considerar qdo for AS/400 para que tenha o tratamento de Codbase
     lTop := .T.
  Endif
#ENDIF 


cTPMODU:='IMPORT'
bTPMODUECF := {|| ECF->ECF_TPMODU = 'IMPORT' }
bTPMODUECG := {|| ECG->ECG_TPMODU = 'IMPORT' }   
bTPMODUECE := {|| ECE->ECE_TPMODU = 'IMPORT' }      

EC1->(DBSETORDER(1))
DbSelectArea("EC1")

   EC1->(DbSetFilter({||(EC1->(!Eof()) .And. EC1->EC1_FILIAL = cFilEC1 .And. EC1->EC1_TPMODU = 'IMPORT') }, "(EC1->(!Eof()) .And. EC1->EC1_FILIAL = cFilEC1 .And. EC1->EC1_TPMODU = 'IMPORT')"))
mBrowse( 6, 1, 22, 75, "EC1")
DbSelectArea("EC1")
Set Filter To

DBSELECTAREA(cAliasAnt)

Return .T.                  

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 01/02/07 - 15:16
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0001  ,"AxPesqui", 0 , 1},; //"Pesquisar"
                    { STR0002  ,"PR300CAN", 0 , 6} } //"Cancela"
                 
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("CPR300MNU")
	aRotAdic := ExecBlock("CPR300MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina                    

*-------------------*
Function PR300CAN()
*-------------------*
LOCAL nNroVld := EasyGParam("MV_NR_CONT"), nRegAtu
Private nNR_Cont := EasyGParam("MV_NR_CONT"), lContab := .F., lPR300:=.T., cFilEC9:=xFilial("EC9") , cFilEC3:=xFilial("EC3")
Private cFilEC5:=xFilial("EC5"), cFilEC4:=xFilial("EC4"), cFilEC7:=xFilial("EC7"), cFilECA:=xFilial("ECA"), cFilECE:=xFilial("ECE")
Private lExisteECE := .F., lExisteECF := .F., lExisteECG := .F.
Private nContECA := 0    // Variavel usada na funcao PRCONTAREG

// Verifica a existencia da rotina de Estorno
lExisteECE := EasyGParam("MV_ESTORNO", .F., .F.)

// Verifica se existe o arquivo de pagamento antecipado ECF/ECG
lExisteECF := EasyGParam("MV_PAGANT", .F., .F.)
If lExisteECF 
   cFilECF    := xFilial('ECF')			
   lExisteECG := .T.   
   cFilECG    := xFilial('ECG')			
Endif                                   

// ACSJ - 26/07/2004 - Acha ultima contabilização valida. |--------------------------------------------------------
nRegAtu := EC1->(Recno())   // Registro Selecionado
EC1->(DBGoBottom())      

Do While .not. EC1->(Bof())  
   if EC1->EC1_STATUS <> "E"   // Se não for processo estornado             
      nNroVld := Val(EC1->EC1_NR_CON)   // Numero da ultima contabilização valida
      Exit
   Endif
   EC1->(DBSkip(-1))
Enddo

EC1->(DBGoTo(nRegAtu))   // Retorna o ponteiro do arquivo para a posição selecionada
// ---------------------------------------------------------------------------------------------| ACSJ - 26/07/2004

//IF VAL(EC1->NR_CON) # nNR_Cont  --  ACSJ - 26/07/2004

If VAL(EC1->EC1_NR_CON) # nNroVld
   Help(" ",1,"AVG0005337") //E_Msg(STR0004,1) //"S¢ pode ser cancelado a ultima contabiliza‡„o."
   RETURN .F.
ELSEIF EC1->EC1_STATUS = "E"
   Help(" ",1,"AVG0005338") //E_Msg(STR0005,1) //"Existe contabiliza‡„o em aberto, cancelamento n„o autorizado."
   RETURN .F.
EndIf

If SimNao(STR0006,STR0007,,,,STR0007)#'S' //"Confirma cancelamento da contabiliza‡„o ?"###"Questao ?"###"Questao ?"   // GFP - 22/11/2011
   Return .F.
EndIf


If EasyEntryPoint("ECOPPR01")
   If !ExecBlock("ECOPPR01")
  	  Return .F.
   EndIf
EndIf
/*
Processa({||PR300Can_IVC(nNR_Cont)},STR0008) //"Cancelando Invoices e Processos."
Processa({||PR300Can_VCF(nNR_Cont)},STR0009) //"Cancelando Eventos das Invoices."
Processa({||PR300Can_EC3(nNR_Cont)},STR0010) //"Cancelando Historico dos Processos."
If lExisteECE
   Processa({||PR300CanECE(nNR_Cont)},STR0010) //"Cancelando Processos Estornados."
Endif   
If lExisteECF
   Processa({||PR300ECFCan(nNR_Cont)},STR0028) //"Cancelando Pagamentos Antecipados"
   Processa({||PR300ECGCan(nNR_Cont)},STR0028) //"Cancelando Pagamentos Antecipados"
Endif   */
 
Processa({||PR300Can_IVC(nNroVld)},STR0008) //"Cancelando Invoices e Processos."
Processa({||PR300Can_VCF(nNroVld)},STR0009) //"Cancelando Eventos das Invoices."
Processa({||PR300Can_EC3(nNroVld)},STR0010) //"Cancelando Historico dos Processos."
If lExisteECE
   Processa({||PR300CanECE(nNroVld)},STR0010) //"Cancelando Processos Estornados."
Endif   
If lExisteECF
   Processa({||PR300ECFCan(nNroVld)},STR0028) //"Cancelando Pagamentos Antecipados"
   Processa({||PR300ECGCan(nNroVld)},STR0028) //"Cancelando Pagamentos Antecipados"
Endif   


IF ! EC1->(EOF())
   Reclock('EC1',.F.)
   EC1->EC1_STATUS := "E"
   EC1->(MSUNLOCK())
EndIf

  
IF lTop                                      
  IF (TcSrvType() != "AS/400")
     Processa({||ApagaECA()},STR0017) // 'Aguarde... Apurando Dados'
  Else      
//     MsAguarde({||PRContaReg(5,nNR_Cont)},STR0016)  // 'Aguarde... Apurando Dados' 
     MsAguarde({||PRContaReg(5,nNroVld)},STR0016)  // 'Aguarde... Apurando Dados' 
     Processa({||ApagaECA()},STR0017)
  Endif  
ENDIF 

IF !lTop                                                
//  MsAguarde({||PRContaReg(5,nNR_Cont)},STR0017)  // 'Aguarde... Apurando Dados'  
  MsAguarde({||PRContaReg(5,nNroVld)},STR0017)  // 'Aguarde... Apurando Dados' 
  Processa({||ApagaECA()},STR0017)
ENDIF

IF ! lContab
   AvE_Msg(STR0011,1) //"N£mero de contabiliza‡„o n„o encontrado."
ENDIF

Return .T.
*-----------------------------*
FUNCTION PR300Can_IVC(nNRCont)            // Chamada pelo programa ECOPR999
*-----------------------------*
LOCAL MRecno
Private nContEC5:=0, nContEC4:=0, nContEC7:=0  // Variaveis usadas na funcao PRCONTAREG

EC5->(DBSETORDER(3))
EC4->(DBSETORDER(2))
EC7->(DBSETORDER(3))

MsAguarde({||PRContaReg(1,nNRCont)},STR0016)  //'Aguarde... Apurando Dados'
ProcRegua(nContEC5+1)
Pr300Men(If(lPR300,STR0018,STR0021))   
   
EC5->(DBSEEK(cFilEC5+STRZERO(nNRCont,4,0)))
DO WHILE ! EC5->(EOF()) .AND. nNRCont = VAL(EC5->EC5_NR_CON) .AND. EC5->EC5_FILIAL = cFilEC5
   
   
   IncProc(STR0022+EC5->EC5_HAWB) //'Cancelando Processos ' ## 'Lendo Processos '
   
   lRefresh:=.t.
   lContab = .T.
   EC5->(DBSKIP())
   MRecno = EC5->(RECNO())
   EC5->(DBSKIP(-1))
   Reclock('EC5',.F.)
   EC5->EC5_NR_CON := '0000'
   EC5->EC5_VCFMES := ""
   EC5->EC5_VCFANO := ""
   IF  VAL(EC5->EC5_T_D_NR) = nNRCont  && LAB 17.06.98 para voltar ao status anterior
       DO  CASE
           CASE  EC5->EC5_T_D = "E"
                 EC9->(DBSETORDER(2))
                 EC9->(DBSEEK(cFilEC9+EC5->EC5_FORN+EC5->EC5_INVOIC+"6"))
                 IF EC9->(EOF()) .OR. VAL(EC9->EC9_NR_CON) > nNRCont
                    EC5->EC5_T_D := 'T'
                 ELSE
                    EC5->EC5_T_D := 'D'
                 ENDIF
                 EC5->EC5_T_D_NR := '0000'
           CASE  EC5->EC5_T_D = "D"
                 EC5->EC5_T_D    := 'T'
                 EC5->EC5_T_D_NR := '0000'
       ENDCASE
   ENDIF
   EC5->(MSUNLOCK())
   EC5->(DBGOTO(MRecno))
ENDDO

ProcRegua(nContEC4+1)

EC4->(DBSEEK(cFilEC4+STRZERO(nNRCont,4,0)))
Pr300Men(If(lPR300,STR0026,STR0027) )       

DO WHILE ! EC4->(EOF()) .AND. nNRCont = VAL(EC4->EC4_NR_CON) .AND. EC4->EC4_FILIAL=cFilEC4
   
   IncProc(STR0022 + EC4->EC4_HAWB) //'Cancelando Processos ' ## 'Lendo Processos '
      
   lRefresh:=.t.
   lContab = .T.
   EC4->(DBSKIP())
   MRecno = EC4->(RECNO())
   EC4->(DBSKIP(-1))
   Reclock('EC4',.F.)
   EC4->EC4_NR_CON := '0000'
   EC4->(MSUNLOCK())
   EC4->(DBGOTO(MRecno))
ENDDO

ProcRegua(nContEC7+1)   

EC7->(DBSEEK(cFilEC7+STRZERO(nNRCont,4,0)))
Pr300Men(If(lPR300,STR0024,STR0025))

DO WHILE ! EC7->(EOF()) .AND. nNRCont = VAL(EC7->EC7_NR_CON) .AND. EC7->EC7_FILIAL=cFilEC7
           
			IncProc(STR0022 + EC7->EC7_HAWB) //'Cancelando Movimentacao da Conta ' ## 'Lendo Movimentacao da Conta '
        
   lRefresh:=.t.
   lContab = .T.
   EC7->(DBSKIP())
   MRecno = EC7->(RECNO())
   EC7->(DBSKIP(-1))
   Reclock('EC7',.F.)
   EC7->(DBDELETE())
   EC7->(MSUNLOCK())
   EC7->(DBGOTO(MRecno))
ENDDO

Return .T.
*-----------------------------*
FUNCTION PR300Can_VCF(nNrCont)            // Chamada pelo programa ECOPR999
*-----------------------------*
LOCAL nRecnoEC9:=0
Private nContEC9 := 0    // Variavel usada na funcao PRCONTAREG
Private lDeletaEC9  //Define se vai remover ou não do registro do EC9 posicionado

EC9->(DBSETORDER(3))
MsAguarde({||PRContaReg(2,nNRCont)},STR0016)  //'Aguarde... Apurando Dados'
ProcRegua(nContEC9+1)

EC9->(DBSEEK(cFilEC9+STRZERO(nNrCont,4,0)))
Pr300Men(If(lPR300,STR0013,STR0020))

DO WHILE ! EC9->(EOF()) .AND. nNrCont = VAL(EC9->EC9_NR_CON) .AND. EC9->EC9_FILIAL = cFilEC9
   IncProc(STR0023 + EC9->EC9_INVOIC) //'Cancelando Eventos da Invoice ' ## 'Lendo Eventos da Invoice '
   lRefresh:=.t.
   lContab := .T.   
   EC9->(DBSKIP())
   nRecnoEC9 := EC9->(RECNO())
   EC9->(DBSKIP(-1))
   lDeletaEC9 := .t.   
   Reclock('EC9',.F.)
   
   If EasyEntryPoint("ECOPPR02")
      ExecBlock("ECOPPR02")
   EndIf
   
   // Nick - 11/04/2006 - Para quando rodar a prévia nao exclua os lancamentos do evento 603
   IF SUBSTR(EC9->EC9_ID_CAM,1,1) = "6"
      EC9->EC9_NR_CON := '0000'
      
      //** AAF 12/03/09 - Limpar termino da variacao cambial
      nRecEC5 := EC5->(RecNo())
      nOrdEC5 := EC5->(IndexOrd())
      
      EC5->( dbSetOrder(1) ) //EC5_FILIAL+EC5_FORN+EC5_INVOIC+EC5_IDENTC
      
      EC5->( dbSeek(xFilial("EC5")+EC9->(EC9_FORN+EC9_INVOIC+EC9_IDENTC)) )
      Do While EC5->( !EoF() .AND. EC5_FILIAL+EC5_FORN+EC5_INVOIC+EC5_IDENTC == xFilial("EC5")+EC9->(EC9_FORN+EC9_INVOIC+EC9_IDENTC))
         
		 EC5->(RECLOCK("EC5",.F.))
		 EC5->EC5_VCFMES := ""
		 EC5->EC5_VCFANO := ""  
		 EC5->(MSUnlock())
         
         EC5->(dbSkip())
      EndDo
      
      EC5->(dbSetOrder(nOrdEC5))
      EC5->(dbGoTo(nRecEC5))
      //**
      
   ELSE
      if lDeletaEC9
         EC9->(DBDELETE())
      endif
   Endif   

   EC9->(MSUNLOCK())
   EC9->(DBGOTO(nRecnoEC9))
ENDDO
EC9->(DBSETORDER(1))

Return .T.        
*-----------------------------*
FUNCTION PR300Can_EC3(nNrCont)
*-----------------------------*
Private nContEC3:=0    // Variavel usada na funcao PRCONTAREG

// Rotina p/ contagem de registros
MsAguarde({||PRContaReg(3,nNRCont)},STR0016)  // 'Aguarde... Apurando Dados'
ProcRegua(nContEC3+1)
Pr300Men(STR0012)

EC3->(DBSEEK(cFilEC3+STRZERO(nNRCont,4,0)))
DO WHILE ! EC3->(EOF()) .AND. nNRCont = VAL(EC3->EC3_NR_CON) .AND. EC3->EC3_FILIAL = cFilEC3
   IncProc(STR0012)    //'Cancelando Historicos dos Processos.'
   Reclock('EC3',.F.)
   EC3->(DBDELETE())
   EC3->(MSUNLOCK())
   EC3->(DBSKIP())
ENDDO

Return .T.
*-----------------------------*
FUNCTION PR300CanECE(nNrCont)            
*-----------------------------*
LOCAL nRecnoECE := 0
Private nContECE:=0   // Variavel usada na funcao PRCONTAREG

ECE->(DBSETORDER(2))

MsAguarde({||PRContaReg(4,nNRCont)},STR0016)  //'Aguarde... Apurando Dados'
ProcRegua(nContECE+1)
Pr300Men(STR0015)       // 'Cancelando Proc.Estornados '

ECE->(DBSEEK(cFilECE+cTPMODU+STRZERO(nNrCont,4,0)))
DO WHILE ! ECE->(EOF()) .AND. nNrCont = VAL(ECE->ECE_NR_CON) .AND. ECE->ECE_FILIAL = cFilECE .and. Eval(bTPMODUECE)
   
   IncProc(STR0022+ECE->ECE_HAWB)    // 'Cancelando Proc.Estornados :'   
      
   lRefresh:=.t.
   lContab := .T.
   Reclock('ECE',.F.)
   ECE->ECE_NR_CON := '0000'   
   ECE->(MSUNLOCK())
   ECE->(DBSEEK(cFilECE+cTPMODU+STRZERO(nNrCont,4,0)))
ENDDO
ECE->(DBSETORDER(1))

Return .T.
*-----------------------------*
FUNCTION PR300ECFCan(nNrCont)            // Chamada pelo programa ECOPR999
*-----------------------------*
Private nContECF := 0    // Variavel usada na funcao PRCONTAREG

ECF->(DBSETORDER(4))
MsAguarde({||PRContaReg(6,nNRCont)},STR0016)  //'Aguarde... Apurando Dados'
ProcRegua(nContECF+1)

ECF->(DBSEEK(cFilECF+cTPMODU+STRZERO(nNrCont,4,0)))
Pr300Men(STR0028)   // Cancelando pagamentos antecipados

ECG->(DBSETORDER(1))

DO WHILE ! ECF->(EOF()) .AND. nNrCont = VAL(ECF->ECF_NR_CON) .AND. ECF->ECF_FILIAL = cFilECF .and. Eval(bTPMODUECF)
        
   IncProc(If(ECF->ECF_ORIGEM="PO",STR0029,STR0023) + " " + ECF->ECF_INVOIC) //Invoice: 
// If (lPR300 .And. (SUBSTR(ECF->ECF_ID_CAM,1,2) # '60' .And. ECF->ECF_ORIGEM # "PR")) .OR.;
//    (SUBSTR(ECF->ECF_ID_CAM,1,2) # '60' .And. ECF->ECF_ORIGEM == "PR") .OR.;
   If ECF->ECF_ID_CAM $ ("108/109/510/511/512/513/508/509/667/668/677/678") .OR. (ECF->ECF_ID_CAM $ "101" .AND. ECF->ECF_ORIGEM = "PR")
      lContab = .T.
      // Se nao for pagamento
      //FSM - 24/10/2012
      If (ECF->ECF_HAWB == ECG->ECG_HAWB .AND. ECG->ECG_ORIGEM == ECF->ECF_ORIGEM .AND. ECF->ECF_IDENTC == ECG->ECG_IDENTC .AND. ECF->ECF_FORN == ECG->ECG_FORN ;
         .OR. ECG->(DbSeek(cFilECG+cTPMODU+ECF->ECF_HAWB+ECF->ECF_FORN+ECF->ECF_IDENTC+ECF->ECF_ORIGEM))) .AND. ECG->ECG_ULT_TX # ECF->ECF_FLUTUA
         
         Reclock('ECG',.F.)
         ECG->ECG_ULT_TX := ECF->ECF_FLUTUA
         ECG->ECG_DTENCE := CTOD('  /  /  ')
         ECG->(MSUNLOCK())
      EndIf
      Reclock('ECF',.F.)
      ECF->(DBDELETE())
      ECF->(MSUNLOCK())
   Else
      lContab := .T. 
      Reclock('ECF',.F.)
      ECF->ECF_NR_CON := '9999'   
      ECF->(MSUNLOCK())
   ENDIF
   ECF->(DBSEEK(cFilECF+cTPMODU+STRZERO(nNrCont,4,0)))
ENDDO
ECF->(DBSETORDER(1))

Return .T.
*-----------------------------*
FUNCTION PR300ECGCan(nNrCont)            
*-----------------------------*
LOCAL nRecnoECG  := 0
Private nContECG := 0    // Variavel usada na funcao PRCONTAREG
                                        
MsAguarde({||PRContaReg(8,nNRCont)},STR0016)  //'Aguarde... Apurando Dados'
ProcRegua(nContECG+1)
ECG->(DBSETORDER(3))
ECG->(DBSEEK(cFilECG+cTPMODU+StrZero(nNrCont,4,0)))
Pr300Men(STR0028)        // Cancelando pagamentos antecipados

DO WHILE ! ECG->(EOF()) .AND. ECG->ECG_FILIAL = cFilECG .AND. nNrCont = Val(ECG->ECG_NR_CON) .and. Eval(bTPMODUECG)
   IncProc(STR0022 + " " + ECG->ECG_HAWB) //Processo:    
   lContab = .T.
   Reclock('ECG',.F.)
   ECG->ECG_DTENCE := CTOD('/  / ')
   ECG->ECG_NR_CON := '9999'
   ECG->(MSUNLOCK())
   ECG->(DBSEEK(cFilECG+cTPMODU+StrZero(nNrCont,4,0))) //** GFC - 20/02/06 - Retirado -> ECG->(DbSkip())
ENDDO
ECG->(DBSETORDER(1))

Return .T.        
*--------------------------------------------------------------------------------------
 STATIC FUNCTION PRContaReg(nOpcao, nNRCont)
*--------------------------------------------------------------------------------------

Local cQueryEC3, cQueryEC4, cQueryEC5, cQueryEC7, cQueryEC9, cQueryECA
Local cAliasEC3, cAliasEC4, cAliasEC5, cAliasEC7, cAliasEC9, cAliasECA  
Local cQuery                
Local cQueryECE, cAliasECE
Local cQueryECF, cAliasECF
Local cQueryECG, cAliasECG

If lTop 
   
 cAliasEC3 := "EC3TMP"
 cAliasEC4 := "EC4TMP"
 cAliasEC5 := "EC5TMP"
 cAliasEC7 := "EC7TMP"
 cAliasEC9 := "EC9TMP" 
 cAliasECA := "ECATMP"
 
 If lExisteECE
    cAliasECE := "ECETMP"
 Endif   
 If lExisteECF
    cAliasECF := "ECFTMP"
 Endif   
 If lExisteECG
    cAliasECG := "ECGTMP"
 Endif   
  
 // Querys Padrao
 IF (TcSrvType() != "AS/400")  
    cQrPadrEC3 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC3")+ " WHERE EC3_FILIAL='"+ cFilEC3 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrEC4 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC4")+ " WHERE EC4_FILIAL='"+ cFilEC4 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrEC5 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC5")+ " WHERE EC5_FILIAL='"+ cFilEC5 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrEC7 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC7")+ " WHERE EC7_FILIAL='"+ cFilEC7 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrEC9 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC9")+ " WHERE EC9_FILIAL='"+ cFilEC9 +"' AND D_E_L_E_T_ <> '*' "
    cQrPadrECA := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECA")+ " WHERE ECA_FILIAL='"+ cFilECA +"' AND D_E_L_E_T_ <> '*' AND ECA_TPMODU = 'IMPORT' "
    If lExisteECE
       cQrPadrECE := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECE")+ " WHERE ECE_FILIAL='"+ cFilECE +"' AND D_E_L_E_T_ <> '*' "    
    Endif   
    If lExisteECF
       cQrPadrECF := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECF")+ " WHERE ECF_FILIAL='"+ cFilECF +"' AND D_E_L_E_T_ <> '*' "    
    Endif   
    If lExisteECG
       cQrPadrECG := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECG")+ " WHERE ECG_FILIAL='"+ cFilECG +"' AND D_E_L_E_T_ <> '*' "    
    Endif   
 Else
    cQrPadrEC3 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC3")+ " WHERE EC3_FILIAL='"+ cFilEC3 +"' " 
    cQrPadrEC4 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC4")+ " WHERE EC4_FILIAL='"+ cFilEC4 +"' " 
    cQrPadrEC5 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC5")+ " WHERE EC5_FILIAL='"+ cFilEC5 +"' " 
    cQrPadrEC7 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC7")+ " WHERE EC7_FILIAL='"+ cFilEC7 +"' " 
    cQrPadrEC9 := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("EC9")+ " WHERE EC9_FILIAL='"+ cFilEC9 +"' " 
    cQrPadrECA := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECA")+ " WHERE ECA_FILIAL='"+ cFilECA +"' AND ECA_TPMODU = 'IMPORT' "
    If lExisteECE
       cQrPadrECE := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECE")+ " WHERE ECE_FILIAL='"+ cFilECE +"' "    
    Endif   
    If lExisteECF
       cQrPadrECF := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECF")+ " WHERE ECF_FILIAL='"+ cFilECF +"' "    
    Endif
    If lExisteECG
       cQrPadrECG := "SELECT COUNT(*) TOTALREG FROM "+RetSqlName("ECG")+ " WHERE ECG_FILIAL='"+ cFilECG +"' "    
    Endif   
 Endif     
                                  
 If nOpcao == 1         // Parametro vindo da funcao PR300CAN_IVC  
     
   *--------> EC4           
   cQueryEC4 := cQrPadrEC4
   cQueryEC4 += "AND EC4_NR_CON = '" + STRZERO(nNRCont,Len(EC4->EC4_NR_CON)) + "'" 
   PRExecQry(cQueryEC4, cAliasEC4)               
   If Select(cAliasEC4) > 0
      nContEC4  := (cAliasEC4)->TOTALREG
      (cAliasEC4)->(DbCloseArea())
   Else
      nContEC4  := 0   
   Endif   
   
   *--------> EC5         
   cQueryEC5 := cQrPadrEC5
   cQueryEC5 += "AND EC5_NR_CON = '" + STRZERO(nNRCont,Len(EC5->EC5_NR_CON)) + "'"  
   PRExecQry(cQueryEC5, cAliasEC5)               
   If Select(cAliasEC5) > 0
      nContEC5  := (cAliasEC5)->TOTALREG
      (cAliasEC5)->(DbCloseArea())
   Else
      nContEC5  := 0
   Endif   
      
   *--------> EC7         
   cQueryEC7 := cQrPadrEC7
   cQueryEC7 += "AND EC7_NR_CON = '" + STRZERO(nNRCont,Len(EC7->EC7_NR_CON)) + "'"  
   PRExecQry(cQueryEC7, cAliasEC7)               
   If Select(cAliasEC7) > 0
      nContEC7  := (cAliasEC7)->TOTALREG
      (cAliasEC7)->(DbCloseArea())
   Else
      nContEC7  := 0
   Endif   
   
 Elseif nOpcao == 2         // Parametro vindo da funcao PR300CAN_VCF  
    
   *--------> EC9         
   cQueryEC9 := cQrPadrEC9
   cQueryEC9 += "AND EC9_NR_CON = '" + STRZERO(nNRCont,Len(EC9->EC9_NR_CON)) + "'"
   PRExecQry(cQueryEC9, cAliasEC9)               
   If Select(cAliasEC9) > 0 
      nContEC9  := (cAliasEC9)->TOTALREG
      (cAliasEC9)->(DbCloseArea())
   Else
      nContEC9  := 0
   Endif  
  
   
 Elseif nOpcao == 3         // Parametro vindo da funcao PR300CAN_EC3        
         
   *--------> EC3           
   cQueryEC3 := cQrPadrEC3
   cQueryEC3 += "AND EC3_NR_CON = '" + STRZERO(nNRCont,Len(EC3->EC3_NR_CON)) + "'"   
   PRExecQry(cQueryEC3, cAliasEC3)               
   If Select(cAliasEC3) > 0 
      nContEC3  := (cAliasEC3)->TOTALREG
      (cAliasEC3)->(DbCloseArea())
   Else
      nContEC3  := 0
   Endif
   
 Elseif nOpcao == 4     // Parametro vindo da funcao PR300CANECE
   
   *--------> ECE                                     
   If lExisteECE
      cQueryECE := cQrPadrECE
      cQueryECE += "AND ECE_NR_CON = '" + STRZERO(nNRCont,Len(ECE->ECE_NR_CON)) + "'"  
      PRExecQry(cQueryECE, cAliasECE)               
      If Select(cAliasECE) > 0 
         nContECE  := (cAliasECE)->TOTALREG
         (cAliasECE)->(DbCloseArea())
      Else
         nContECE  := 0
      Endif   
   Endif   
   
 Elseif nOpcao == 5   // Parametro vindo da funcao PR300Can       

   *--------> ECA           
   cQueryECA := cQrPadrECA
   PRExecQry(cQueryECA, cAliasECA)               
   If Select(cAliasECA) > 0 
      nContECA  := (cAliasECA)->TOTALREG
      (cAliasECA)->(DbCloseArea())            
   Else
      nContECA  := 0
   Endif   
 
 Elseif nOpcao == 6     // Parametro vindo da funcao PR300CAN_ecf
   
   *--------> ECF                                     
   If lExisteECF
      cQueryECF := cQrPadrECF
      cQueryECF += "AND ECF_NR_CON = '" + STRZERO(nNRCont,Len(ECF->ECF_NR_CON)) + "'"  
      PRExecQry(cQueryECF, cAliasECF)               
      If Select(cAliasECF) > 0 
         nContECF  := (cAliasECF)->TOTALREG
         (cAliasECF)->(DbCloseArea())
      Else
         nContECF  := 0
      Endif   
   Endif       
   
 Elseif nOpcao == 8     // Parametro vindo da funcao PR300CANECG
   
   *--------> ECG                                     
   If lExisteECG
      cQueryECG := cQrPadrECG
      cQueryECG += "AND ECG_NR_CON = '" + STRZERO(nNRCont,Len(ECG->ECG_NR_CON)) + "'"  
      PRExecQry(cQueryECG, cAliasECG)               
      If Select(cAliasECG) > 0 
         nContECG  := (cAliasECG)->TOTALREG
         (cAliasECG)->(DbCloseArea())
      Else
         nContECG  := 0
      Endif   
   Endif          
 Endif
 
ELSE 
  
  If nOpcao == 1     // Parametro vindo da funcao PR300CAN_IVC        
  
     *--------> EC4               
     nContEC4 := 0
     EC4->(DbGotop())
     EC4->(DBSEEK(cFilEC4+STRZERO(nNRCont,4,0)))
     EC4->(DBEVAL({||nContEC4++, MsProcTxt(STR0022+EC4->EC4_HAWB) },,{||nNRCont=VAL(EC4->EC4_NR_CON).AND.EC4->EC4_FILIAL=cFilEC4},,,.T.))

     *--------> EC5               
     nContEC5 := 0
     EC5->(DbGotop())
     EC5->(DBSEEK(cFilEC5+STRZERO(nNRCont,4,0)))
     EC5->(DBEVAL({||nContEC5++, MsProcTxt(STR0022+EC5->EC5_HAWB) },,{||nNRCont=VAL(EC5->EC5_NR_CON).AND.EC5->EC5_FILIAL=cFilEC5},,,.T.))
     
     *--------> EC7               
     nContEC7 := 0
     EC7->(DbGotop())
     EC7->(DBSEEK(cFilEC7+STRZERO(nNRCont,4,0)))
     EC7->(DBEVAL({||nContEC7++, MsProcTxt(STR0022 + EC7->EC7_HAWB) },,{||nNRCont=VAL(EC7->EC7_NR_CON).AND.EC7->EC7_FILIAL=cFilEC7},,,.T.))
    
  Elseif nOpcao == 2     // Parametro vindo da funcao PR300CAN_VCF        
      
     *--------> EC9               
     nContEC9 := 0
     EC9->(DbGotop())
     EC9->(DBSEEK(cFilEC9+STRZERO(nNRCont,4,0)))
     EC9->(DBEVAL({||nContEC9++, MsProcTxt(STR0023 + EC9->EC9_INVOIC) },,{||nNRCont=VAL(EC9->EC9_NR_CON).AND.EC9->EC9_FILIAL=cFilEC9},,,.T.))

  
  Elseif nOpcao == 3         // Parametro vindo da funcao PR300CAN_ECE        
 
     *--------> EC3               
     nContEC3 := 0
     EC3->(DbGotop())
     EC3->(DBSEEK(cFilEC3+STRZERO(nNRCont,4,0)))
     EC3->(DBEVAL({||nContEC3++, MsProcTxt(STR0022+EC3->EC3_HAWB)},,{||nNRCont=VAL(EC3->EC3_NR_CON).AND.EC3->EC3_FILIAL=cFilEC3},,,.T.))
          
  Elseif nOpcao == 4     // Parametro vindo da funcao PR300CANECE           
          
     *--------> ECE               
     If lExisteECE
        nContECE := 0
        ECE->(DbGotop())
        ECE->(DBSEEK(cFilECE+cTPMODU+STRZERO(nNRCont,4,0)))
        ECE->(DBEVAL({||nContECE++, MsProcTxt(STR0022+ECE->ECE_HAWB) },,{||ECE->(!EOF()) .And. Eval(bTPMODUECE) .and. VAL(ECE->ECE_NR_CON) = 0 .And. ECE->ECE_FILIAL = cFilECE }))       
     Endif   
          
  Elseif nOpcao == 5    // Parametro vindo da funcao PR300CAN       
 
     nContECA := 0
     ECA->(DbGotop())
     ECA->(DbSeek(cFilECA+"IMPORT",.T.))
     ECA->(DBEVAL({||nContECA++, MsProcTxt(STR0022+ECA->ECA_HAWB) },,{||ECA->(!EOF()) .And. ECA->ECA_FILIAL = cFilECA .AND. ECA->ECA_TPMODU = "IMPORT"}))     
   
  Elseif nOpcao == 6     // Parametro vindo da funcao PR300ECFCAN           
          
     *--------> ECF               
     If lExisteECF
        nContECF := 0
        ECF->(DbGotop())
        ECF->(DBSEEK(cFilECF+cTPMODU+STRZERO(nNRCont,4,0)))
        ECF->(DBEVAL({||nContECF++, MsProcTxt(STR0022+ECF->ECF_HAWB) },,{||ECF->(!EOF()) .And.  Eval(bTPMODUECF) .and. VAL(ECF->ECF_NR_CON) = nNRCont .And. ECF->ECF_FILIAL = cFilECF }))       
     Endif              
     
  Elseif nOpcao == 8     // Parametro vindo da funcao PR300ECGCAN        
      
     *--------> ECG               
     nContECG := 0
     ECG->(DbGotop())
     ECG->(DBSEEK(cFilECG+cTPMODU))
     ECG->(DBEVAL({||nContECG++, MsProcTxt(STR0022 + ECG->ECG_HAWB) },,{||nNRCont=VAL(ECG->ECG_NR_CON) .AND. Eval(bTPMODUECG) .and. ECG->ECG_FILIAL=cFilECG},,,.T.))
  Endif   
ENDIF                                            

RETURN .T.     
*--------------------------------------------------------------------------------------
 STATIC FUNCTION PRExecQry(cQuery, cAlias)
*--------------------------------------------------------------------------------------

 cQuery := ChangeQuery(cQuery)
 DbUsearea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAlias,.F.,.T.)

RETURN .T.
*--------------------------------------------------------------------------------------
 STATIC FUNCTION APAGAECA()
*--------------------------------------------------------------------------------------
Local nCount := 0, nCont := 0, cQuery 

IF lTop                                      
  IF (TcSrvType() != "AS/400")
    IF ECA->(EasyRecCount())/1024 < 1
       nCount := 1
    Else
       nCount := Round(ECA->(EasyRecCount())/1024,0)
    EndIf
    ProcRegua(nCount)
				Pr300Men(STR0017)

    nCount:=ECA->(EasyRecCount())
    nCont := 0                   

    // APAGA A CADA 1024 PARA NÃO ENCHER O LOG DO BANCO!
    While nCont <= nCount
         IncProc(STR0017)
         cQuery := "DELETE FROM "+RetSqlName("ECA")
       	 cQuery := cQuery + " WHERE R_E_C_N_O_ between "+Str(nCont)+" AND "+Str(nCont+1024)
       	 cQuery := cQuery + " AND ECA_FILIAL = '" + cFilECA + "'"
       	 cQuery := cQuery + " AND ECA_TPMODU = 'IMPORT'"
         nCont := nCont + 1024
       	 TCSQLEXEC(cQuery)
    Enddo
  Else
    ProcRegua(nContECA)                                    
    DBSELECTAREA('ECA')
    ECA->(DBSEEK(cFilECA+"IMPORT"))
    ECA->(DBEVAL({||(Pr300Men(STR0019),IncProc(STR0022+ECA->ECA_HAWB),ECA->(Reclock('ECA',.F.)),ECA->(DBDELETE()),ECA->(MSUNLOCK()))},,{||ECA->ECA_FILIAL==cFilECA .AND. ECA->ECA_TPMODU = "IMPORT"},,,.T.))    
  Endif
ENDIF

If !lTop 
    ProcRegua(nContECA)                                    
    DBSELECTAREA('ECA')
    ECA->(DBSEEK(cFilECA+"IMPORT"))
    ECA->(DBEVAL({||(Pr300Men(STR0019),IncProc(STR0022+ECA->ECA_HAWB),ECA->(Reclock('ECA',.F.)),ECA->(DBDELETE()),ECA->(MSUNLOCK()))},,{||ECA->ECA_FILIAL==cFilECA .AND. ECA->ECA_TPMODU = "IMPORT"},,,.T.))    
ENDIF  

Return .T.

*-------------------------------------*
Function PR300Men(cMsg)
*-------------------------------------*
If Type("lScheduled") == "L" .AND. lScheduled
   AvE_MSG(cMsg,1)
Else
   oDlgProc:=GetWndDefault()
   oDlgProc:SetText(cMsg)
EndIf

RETURN .T.