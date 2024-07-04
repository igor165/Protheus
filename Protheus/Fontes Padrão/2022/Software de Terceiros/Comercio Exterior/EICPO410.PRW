#INCLUDE "Eicpo410.ch"
//Funcao:     EICPO410  
//Autor:      AVERAGE/Regina        
//Data:       12.08.99 
//Descricao:  Cancelamento de PO via Botao
//Sintaxe:    EICPO410()
//Uso:        Protheus v507 e v508 (Alex Wallauer 04 de Setembro de 2000)

#include 'rwmake.ch' 
*--------------------------------------*
Function Eicpo410(ParamIXB) 
*--------------------------------------*

Do Case
  Case ParamIXB == 1 ; CriaRot()
  Case ParamIXB == 2 ; Motivo()
  Case ParamIXB == 3 ; Motivo()
                       GravaCan()
  Case ParamIXB == 4 ; Cancela()
EndCase

Return(nil)


*-----------------------*
Static FUNCTION CriaRot()
*-----------------------*       
IF !AvFlags("EIC_EAI")//!EasyGParam("MV_EIC_EAI",,.F.)
   AADD(aRotina,{ STR0002  ,'EICPO410(4)',0, 6  }) //"Cancela"
ENDIF

RETURN .T.
*----------------------------*
Static FUNCTION Cancela()
*----------------------------*
lCancel   :=.T.
cLitPerg  :=STR0003  //"Cancelamento"
PO400Estor(,,6)
lCancel   :=.F.
RETURN .T.
*----------------------------*
Static FUNCTION Motivo()
*----------------------------*
PRIVATE cMotivo1:= Space( 30 )
PRIVATE cMotivo2:= Space( 30 )
IF lCancel ==.F.
  RETURN .T.
ENDIF
cMotivo := ''     

DO WHILE .T.

   nOpcao  := 1

   @ 0,0 TO 145,350 DIALOG oDlg1 TITLE STR0004 //"Motivo de Cancelamento"
   
   @ 10, 06 Say STR0005  //"Motivo:"
   @ 10, 30 Get cMotivo1 Pict '@!' SIZE 120,10 
   @ 20, 30 Get cMotivo2 Pict '@!' SIZE 120,10 
   @ 45,121 BMPBUTTON TYPE 01 ACTION (nOpcao:=1,oDlg1:End())

   IF(EasyEntryPoint("EICPO410"),ExecBlock("EICPO410",.F.,.F.,"ANTES_TELA"),)  //TRP-08/05/08-Inclusão de ponto de entrada.
   ACTIVATE DIALOG oDlg1 CENTERED
    
   IF nOpcao==1
      cMotivo:= LTRIM(cMotivo1)+cMotivo2
      IF EMPTY(cMotivo)
         Help("", 1, "AVG0000403")//MSGINFO(STR0006) //"Motivo deve ser prenchido"
         LOOP
      ENDIF   
      RETURN .T.
   ENDIF

   EXIT
ENDDO   

RETURN .F.
*----------------------------*
Static FUNCTION GravaCan()
*----------------------------*
LOCAL nOldInd:=SW3->(INDEXORD())
IF lCancel == .F.
   RETURN .T.
ENDIF
cMensa := STR0003 //"Cancelamento"
nRecItPedidos:= SW3->( Recno() )
nRecWork := Work->(RECNO())

EI5->( DBSEEK( xFilial('EI5')+TPO_NUM ) )
Work->(DBGOTOP()) 
SW3->( DBSEEK( xFilial('SW3')+TPO_NUM ) )
DO WHILE !Work->(EOF()) 

  IF Work->WKFLAGWIN == Space(2)
      Work->(DBSKIP())
      LOOP
   ENDIF

  SW3->(DBSETORDER(8))
  IF SW3->(DBSEEK(xFilial('SW3')+TPO_NUM+Work->WKPOSICAO))

     EI5->(RecLock('EI5',.T.))
     EI5->EI5_FILIAL := xFilial('EI5')
     AvReplace("SW3","EI5")
     EI5->EI5_PO_NUM := SW3->W3_PO_NUM
     EI5->EI5_CC     := SW3->W3_CC
     EI5->EI5_SI_NUM := SW3->W3_SI_NUM
     EI5->EI5_COD_I  := SW3->W3_COD_I
     EI5->EI5_FLUXO  := SW3->W3_FLUXO 
     EI5->EI5_SEQ    := SW3->W3_SEQ
     EI5->EI5_REG    := SW3->W3_REG
     EI5->EI5_FABR   := SW3->W3_FABR
     EI5->EI5_FORN   := SW3->W3_FORN
     EI5->EI5_QTDE   := Work->WKSALDO_Q
     EI5->EI5_PRECO  := SW3->W3_PRECO
     EI5->EI5_SALDO  := SW3->W3_SALDO_Q
     EI5->EI5_DT_EMB := SW3->W3_DT_EMB
     EI5->EI5_DT_ENT := SW3->W3_DT_ENTR
     EI5->EI5_POSICA := SW3->W3_POSICAO
     EI5->EI5_REG_TR := SW3->W3_REG_TRI
     EI5->EI5_TEC    := SW3->W3_TEC
     EI5->EI5_EX_NCM := SW3->W3_EX_NCM
     EI5->EI5_EX_NBM := SW3->W3_EX_NBM
     EI5->EI5_DT_CAN := dDatabase
     EI5->EI5_MOTIVO := cMotivo
     //ASK 09/10/2007 - Gravação dos campos Part Number no SW3, update UI059544 
     If EI5->(FieldPos("EI5_PART_N")) # 0 .And. SW3->(FieldPos("W3_PART_N")) # 0 .And. !Empty(SW3->W3_PART_N)
        EI5->EI5_PART_N := SW3->W3_PART_N
     EndIf
     EI5->(MsUnlock())
  ENDIF   
  Work->(DBSKIP())
ENDDO
IF !EI4->( DBSEEK( xFilial('EI4')+SW2->W2_PO_NUM ) )
   EI4->(RecLock('EI4',.T.))
ELSE
  EI4->(RecLock('EI4',.F.))
ENDIF

If cPaisLoc == "BRA"
   EI4->EI4_FILIAL := xFilial('EI4')
   AvReplace("SW2","EI4")
   EI4->EI4_PO_NUM := SW2->W2_PO_NUM
   EI4->EI4_PO_DT  := SW2->W2_PO_DT
   EI4->EI4_NR_ALT := SW2->W2_NR_ALTE
   EI4->EI4_DT_ALT := SW2->W2_DT_ALTE
   EI4->EI4_FORN   := SW2->W2_FORN  
   EI4->EI4_CLIENT := SW2->W2_CLIENTE
   EI4->EI4_FOB_TO := SW2->W2_FOB_TOT
   EI4->EI4_INLAND := SW2->W2_INLAND
   EI4->EI4_DESCON := SW2->W2_DESCONT
   EI4->EI4_PACKIN := SW2->W2_PACKING
   EI4->EI4_OUT_DE := SW2->W2_OUT_DES
   EI4->EI4_DT_IMP := SW2->W2_DT_IMP
   EI4->EI4_NR_PRO := SW2->W2_NR_PRO
   EI4->EI4_DT_PRO := SW2->W2_DT_PRO
   EI4->EI4_TIPO_E := SW2->W2_TIPO_EM
   EI4->EI4_ORIGEM := SW2->W2_ORIGEM
   EI4->EI4_DEST   := SW2->W2_DEST  
   EI4->EI4_FREPPC := SW2->W2_FREPPCC
   EI4->EI4_FRETEI := SW2->W2_FRETEIN
   EI4->EI4_COND_P := SW2->W2_COND_PA
   EI4->EI4_DIAS_P := SW2->W2_DIAS_PA
   EI4->EI4_AGENTE := SW2->W2_AGENTE
   EI4->EI4_COMPRA := SW2->W2_COMPRA
   EI4->EI4_PESO_B := SW2->W2_PESO_B
   EI4->EI4_MOEDA  := SW2->W2_MOEDA 
   EI4->EI4_DT_PAR := SW2->W2_DT_PAR
   EI4->EI4_PARID  := SW2->W2_PARID_U 
   EI4->EI4_FORWAR := SW2->W2_FORWARD
   EI4->EI4_INCOTE := SW2->W2_INCOTER
   EI4->EI4_IMPORT := SW2->W2_IMPORT
   EI4->EI4_CONSIG := SW2->W2_CONSIG
   EI4->EI4_OBS    := SW2->W2_OBS   
   EI4->EI4_EMITID := SW2->W2_EMITIDO
   EI4->EI4_DT_PC  := SW2->W2_DT_PC 
   EI4->EI4_TAB_PC := SW2->W2_TAB_PC
   EI4->EI4_STAT_P := SW2->W2_STAT_PC
   EI4->EI4_DT_INT := SW2->W2_DT_INTE
   EI4->EI4_EMISCC := SW2->W2_EMISCCA
   EI4->EI4_NRCCAM := SW2->W2_NRCCAMB
   EI4->EI4_RECCCA := SW2->W2_RECCCAM
   EI4->EI4_BAN_RE := SW2->W2_BAN_REC
   EI4->EI4_ENCARG := SW2->W2_ENCARGO
   EI4->EI4_CORRET := SW2->W2_CORRETA
   EI4->EI4_CUST_T := SW2->W2_CUST_TR
   EI4->EI4_BANCO  := SW2->W2_BANCO 
   EI4->EI4_AGENCI := SW2->W2_AGENCIA
   EI4->EI4_TX_CAM := SW2->W2_TX_CAM
   EI4->EI4_TX_DES := SW2->W2_TX_DESP
   EI4->EI4_TX_RES := SW2->W2_TX_RESE
   EI4->EI4_DESP_C := SW2->W2_DESP_CA
   EI4->EI4_MOE_DE := SW2->W2_MOE_DES
   EI4->EI4_FOB_AN := SW2->W2_FOB_ANT
   EI4->EI4_LC_NUM := SW2->W2_LC_NUM
   EI4->EI4_DES_IP := SW2->W2_DES_IPI
   EI4->EI4_OK     := SW2->W2_OK    
   EI4->EI4_CONF_P := SW2->W2_CONF_PE
   EI4->EI4_EXPORT := SW2->W2_EXPORTA
   EI4->EI4_COND_E := SW2->W2_COND_EX
   EI4->EI4_DIAS_E := SW2->W2_DIAS_EX
   EI4->EI4_E_LC   := SW2->W2_E_LC  
   EI4->EI4_COMIS  := SW2->W2_COMIS 
   EI4->EI4_TIP_CO := SW2->W2_TIP_COM
   EI4->EI4_VAL_CO := SW2->W2_VAL_COM
   EI4->EI4_PER_CO := SW2->W2_PER_COM
   EI4->EI4_OUT_CO := SW2->W2_OUT_COM
   EI4->EI4_COMPL  := SW2->W2_COMPL_I 
   EI4->EI4_MT3    := SW2->W2_MT3   
   EI4->EI4_REFCLI := SW2->W2_REFCLI
   EI4->EI4_INTEGR := SW2->W2_INTEGRA  
   EI4->(MsUnlock())
Else
   EI4->EI4_FILIAL := xFilial('EI4')
   AvReplace("SW2","EI4")
   EI4->EI4_PO_NUM := SW2->W2_PO_NUM
   EI4->EI4_PO_DT  := SW2->W2_PO_DT
   EI4->EI4_NR_ALT := SW2->W2_NR_ALTE
   EI4->EI4_DT_ALT := SW2->W2_DT_ALTE
   EI4->EI4_FORN   := SW2->W2_FORN  
   EI4->EI4_CLIENT := SW2->W2_CLIENTE
   EI4->EI4_FOB_TO := SW2->W2_FOB_TOT
   EI4->EI4_INLAND := SW2->W2_INLAND
   EI4->EI4_DESCON := SW2->W2_DESCONT
   EI4->EI4_PACKIN := SW2->W2_PACKING
   EI4->EI4_OUT_DE := SW2->W2_OUT_DES
   EI4->EI4_DT_IMP := SW2->W2_DT_IMP
   EI4->EI4_NR_PRO := SW2->W2_NR_PRO
   EI4->EI4_DT_PRO := SW2->W2_DT_PRO
   EI4->EI4_TIPO_E := SW2->W2_TIPO_EM
   EI4->EI4_ORIGEM := SW2->W2_ORIGEM
   EI4->EI4_DEST   := SW2->W2_DEST  
   EI4->EI4_FREPPC := SW2->W2_FREPPCC
   EI4->EI4_FRETEI := SW2->W2_FRETEIN
   EI4->EI4_COND_P := SW2->W2_COND_PA
   EI4->EI4_DIAS_P := SW2->W2_DIAS_PA
   EI4->EI4_AGENTE := SW2->W2_AGENTE
   EI4->EI4_COMPRA := SW2->W2_COMPRA
   EI4->EI4_PESO_B := SW2->W2_PESO_B
   EI4->EI4_MOEDA  := SW2->W2_MOEDA 
   EI4->EI4_DT_PAR := SW2->W2_DT_PAR
   EI4->EI4_PARID  := SW2->W2_PARID_U 
   EI4->EI4_FORWAR := SW2->W2_FORWARD
   EI4->EI4_INCOTE := SW2->W2_INCOTER
   EI4->EI4_IMPORT := SW2->W2_IMPORT
   EI4->EI4_CONSIG := SW2->W2_CONSIG
   EI4->EI4_OBS    := SW2->W2_OBS   
   EI4->EI4_EMITID := SW2->W2_EMITIDO
   EI4->EI4_DT_PC  := SW2->W2_DT_PC 
   EI4->EI4_TAB_PC := SW2->W2_TAB_PC
   EI4->EI4_STAT_P := SW2->W2_STAT_PC
   EI4->EI4_DT_INT := SW2->W2_DT_INTE
   EI4->EI4_EMISCC := SW2->W2_EMISCCA
   EI4->EI4_NRCCAM := SW2->W2_NRCCAMB
   EI4->EI4_RECCCA := SW2->W2_RECCCAM
   EI4->EI4_BAN_RE := SW2->W2_BAN_REC
   EI4->EI4_ENCARG := SW2->W2_ENCARGO
   EI4->EI4_CORRET := SW2->W2_CORRETA
   EI4->EI4_CUST_T := SW2->W2_CUST_TR
   EI4->EI4_BANCO  := SW2->W2_BANCO 
   EI4->EI4_AGENCI := SW2->W2_AGENCIA
   EI4->EI4_TX_CAM := SW2->W2_TX_CAM
   EI4->EI4_TX_DES := SW2->W2_TX_DESP
   EI4->EI4_TX_RES := SW2->W2_TX_RESE
   EI4->EI4_DESP_C := SW2->W2_DESP_CA
   EI4->EI4_MOE_DE := SW2->W2_MOE_DES
   EI4->EI4_FOB_AN := SW2->W2_FOB_ANT
   EI4->EI4_LC_NUM := SW2->W2_LC_NUM
   EI4->EI4_DES_IP := SW2->W2_DES_IPI
   EI4->EI4_OK     := SW2->W2_OK    
   EI4->EI4_CONF_P := SW2->W2_CONF_PE
   EI4->EI4_E_LC   := SW2->W2_E_LC  
   EI4->EI4_COMIS  := SW2->W2_COMIS 
   EI4->EI4_TIP_CO := SW2->W2_TIP_COM
   EI4->EI4_VAL_CO := SW2->W2_VAL_COM
   EI4->EI4_PER_CO := SW2->W2_PER_COM
   EI4->EI4_OUT_CO := SW2->W2_OUT_COM
   EI4->EI4_COMPL  := SW2->W2_COMPL_I 
   EI4->EI4_MT3    := SW2->W2_MT3   
   EI4->EI4_INTEGR := SW2->W2_INTEGRA   
   EI4->(MsUnlock())
Endif				
SW3->(DBSETORDER(nOldInd))
SW3->( DBGOTO( nRecItPedidos ) )
Work->(DBGOTO(nRecWork))
lCancel :=.F.
RETURN .t.
