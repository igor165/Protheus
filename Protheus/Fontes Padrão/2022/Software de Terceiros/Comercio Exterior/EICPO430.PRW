//#INCLUDE "FIVEWIN.CH" 
#include "Average.ch"
#INCLUDE "EICPO430.CH"
#DEFINE  PICT_TX_CAMBIO      "@E 999,999.99999999"
#DEFINE  PICT_TX_DESPESAS    "@E 999,999.99999999"
#DEFINE  PICT_VL_ANTECIPADO  "@E 999,999,999,999.99"
#DEFINE  PICT_DSP_CAMBIO     "@E 999,999,999.99"
#DEFINE  PICT_CORRETAGEM     "@E 999,999,999.99" 
#DEFINE  PICT_VL_REAL        "@E 999,999,999,999,999,999.99"
#DEFINE  PICT_VL_RESERVA     "@E 999,999,999.99"



*----------------------------------------------------------------------------*
* Programa     : PO430 - Proforma / Cambio                                   *
* Autor        : Edson Ronaldo de Melo                                       *
* Data Criacao : 09:08 Fev 02,1994                                           *
* Finalidade   : SIGAEIC PROTHEUS                                            *
* Alteracao    : OS No. 0171/95 - Arthur C. D. - 11:00 Mai 17,1995           *
*              : A.C.D. - MODIFICAR LAY OUT E PF's  [JATO DE TINTA].         *
*              : OS No. 0602/98 - Cristiano A.F. - 15:00 Jun 04, 1998        *
*              :                  Converter p/ SIGAEIC                       *
*              : ALEX WALLAUER    Converteu p/ PROTHEUS 23/11/1999           *
*              : ALEX WALLAUER    Integrou com o financeiro em 21/05/2004    *
*----------------------------------------------------------------------------*
FUNCTION EICPO430()
*----------------------------------------------------------------------------*
LOCAL nOpcA:=0  
PRIVATE lEdita:=.T.
PRIVATE lFinanceiro := GetNewPar("MV_EASYFIN","N") = "S"// .AND. EasyGParam("MV_EASY",,"N") = "S"// AWR - 20/05/2004 - MP135
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
IF lFinanceiro// AWR - 20/05/2004 - MP135
   EasyHelp(STR0065,STR0066)  // GFP - 28/07/2014 - "Seu ambiente encontra-se integrado com os módulos da TOTVS, portanto, acesse a rotina de Proforma Invoice em Atualizações/Purchase Order/Proforma Invoice." ### "Aviso"
   RETURN .F.
/* Nopado por GFP - 28/07/2014 - Quando o sistema for integrado com TOTVS, o usuario deve acessar Atualizações/Purchase Order/Proforma Invoice
   PRIVATE cCadastro := STR0060 //STR0060  "Pagamento Antecipado"
   PRIVATE aRotina := MenuDef()
   SW2->(DBSETFILTER({|| PO430FILTRO()}, "PO430FILTRO()"))
   mBrowse(,,,,"SW2")
   SW2->(DBCLEARFILTER())

   RETURN .T.
*/
ENDIF

cPoNum := SW2->W2_PO_NUM

DO WHILE .T.
   nOpcA:=0  

   DEFINE MSDIALOG oDlg TITLE STR0001 From 9,0 To 20,50 OF oMainWnd //"Proforma"
   
    oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 16/07/2015
    oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

    @ 1.4,0.8 SAY OemtoAnsi(STR0002) of oPanel SIZE 30,10 //" N§ de P.O. "
    @ 1.4,6.0  MSGET cPoNum F3 "SW2" of oPanel SIZE 80,10 

   ACTIVATE MSDIALOG oDlg ON INIT ;
           EnchoiceBar(oDlg,{||If(PO430Valid("PO"),(nOpca:=1,oDlg:End()),)},;
                            {||nOpca:=0,oDlg:End()}) CENTERED

   IF nOpca = 0
      Exit
   ENDIF
   
   PO430Dados()
   
ENDDO

RETURN .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 25/01/07 - 15:05
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0061 ,"AxPesqui"  ,0,1},;//STR0061 "Pesquisar" 
                    { STR0062 ,"PO430Dados",0,4},;//STR0062 "Pg Antecipado"
                    { STR0063 ,"AxVisual"  ,0,2}} //STR0063 "Visualizar"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("IPO430MNU")
	aRotAdic := ExecBlock("IPO430MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
                    

//PO430FILTRO - JWJ 20/08/2005
//Essa função filtra o SW2 para mostrar apenas os PO's
//que tem pagto. antecipado    

*-------------------------------------------*
FUNCTION PO430FILTRO()
*-------------------------------------------*
Local lRet := .T.

IF SY6->(DBSEEK(XFILIAL("SY6")+SW2->W2_COND_PA))
	lRet := (SY6->Y6_DIAS_PA > 900) .AND. (SY6->Y6_DIAS_01 < 0)
ENDIF

RETURN lRet


*----------------------------------------------------------------------------
FUNCTION PO430Dados()
*----------------------------------------------------------------------------
Local nLin1:=109,nCol1:=28,nLin2:=257,nCol2:=552
LOCAL nPos, nDias, cImp, oDlg, nOpcao:=0

cPoNum := SW2->W2_PO_NUM// AWR - 20/05/2004 - MP135

PRIVATE oSayVlAntecipado, oSayCorretagem, oSayTxReserva, oSayDespCambio,;
        oSayTotPed, oSayDesBanco, oSayTxCambio
PRIVATE lGets:=.F.//Usada no EICFI400.PRW
PRIVATE nReal1:=nReal2:=nReal3:=nReal4:=0

cNrProforma   := SW2->W2_NR_PRO
dDtProforma   := SW2->W2_DT_PRO
nPesoBruto    := SW2->W2_PESO_B
cBcReceb      := SW2->W2_BAN_RECB
cCustumer     := SW2->W2_CUST_TRA
cCartaCredito := SW2->W2_LC_NUM
cConCambio    := SW2->W2_NRCCAMBI
dDtLiquidado  := SW2->W2_RECCCAM
nTxCambio     := SW2->W2_TX_CAM
nVlAntecipado := SW2->W2_FOB_ANTE
nTxDespesas   := SW2->W2_TX_DESP
cMoeDespesas  := SW2->W2_MOE_DESP
nCorretagem   := SW2->W2_CORRETAG
dDtCambio     := SW2->W2_EMISCCAM
nTxReserva    := SW2->W2_TX_RESER
nDespCambio   := SW2->W2_DESP_CAM
nTotPedido    := SW2->W2_FOB_TOT+SW2->W2_Inland+SW2->W2_FRETEINT+SW2->W2_PACKING-SW2->W2_DESCONTO
dPo           := SW2->W2_PO_DT
cBanco_Agencia:= SW2->W2_BANCO+SW2->W2_AGENCIA
SA6->(DBSEEK(xFilial()+cBanco_Agencia))
cDesBanco:=SA6->A6_NOME
IF SW2->(FIELDPOS("W2_INSTFIN"))>0
   cInstFin := SW2->W2_INSTFIN
ENDIF           
/*IF SW2->(FIELDPOS("W2_PRACA"))>0
   cPraca := SW2->W2_PRACA   //LRL 22/01/04
ENDIF*/ 
       
IF SW2->W2_DIAS_PAG >= 900

   IF SY6->(DBSEEK(xFilial()+SW2->W2_COND_PAG+STR(SW2->W2_DIAS_PAG,3,0)))
      nPos  :='01'
      nDias := 0
      nPerc := 0


      DO WHILE SY6->( FIELDPOS("Y6_DIAS_"+nPos) # 0 )
            
         IF SY6->( FIELDGET(FIELDPOS("Y6_DIAS_"+nPos)) < -1 )   // Dias Negativo.
            nDias:=SY6->(FIELDGET(FIELDPOS("Y6_DIAS_"+nPos)))
            nPerc:=SY6->(FIELDGET(FIELDPOS("Y6_PERC_"+nPos)))

            IF EMPTY(SW2->W2_FOB_ANTE) .AND. nPerc > 0 .AND. nDias < -1
               nVlAntecipado += (nTotPedido * nPerc)/100
            ENDIF

         ELSE
            EXIT
         ENDIF

         nPos:=PADL(VAL(nPos)+1,2,'0')
      ENDDO

      IF nDias < -1
         //-----------| CAMBIO ANTECIPAL |------------\\
         lGets:=.T.	//LRS - 9/4/2014 - Ajustando tamanho do  dialog
		  nLin1:=000
		  nCol1:=000
		  nLin2:=450
		  nCol2:=690 
      ENDIF

   ENDIF

ENDIF
        
IF lGets .AND. lFinanceiro// AWR - 20/05/2004 - MP135
   IF SW2->(FIELDPOS("W2_CHAVEFI")) # 0// AWR - 20/05/2004 - MP135
      lEdita:=EMPTY(SW2->W2_CHAVEFI)
   ENDIF
ENDIF

//--- Carrega Importador ---\\
cImp := IF(SA2->(DBSEEK(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ"))),SA2->A2_NREDUZ,'')          
                           
DEFINE MSDIALOG oDlg FROM  nLin1,nCol1 TO nLin2,nCol2 TITLE STR0003 PIXEL OF oMainWnd //"Proforma"

   @ 21, 005 SAY STR0004            SIZE 45, 08 OF oDlg PIXEL //"Nro. P.O."
   @ 19, 129 SAY STR0005            SIZE 24, 08 OF oDlg PIXEL //"Data"
   @ 34, 005 SAY STR0006            SIZE 45, 08 OF oDlg PIXEL //"Nro. Proforma"
   @ 32, 129 SAY STR0007            SIZE 24, 08 OF oDlg PIXEL //"Data"
   @ 47, 005 SAY STR0008            SIZE 45, 08 OF oDlg PIXEL //"Peso Bruto"
   @ 60, 005 SAY oSayTotPed VAR STR0064 SIZE 63, 08 OF oDlg PIXEL //STR0064  "Tot. do Pedido" 
   IF SW2->(FIELDPOS("W2_INSTFIN"))>0
      @ 60, 167 SAY "Inst.Financ.:" SIZE 45,08 OF oDlg PIXEL
   ENDIF

   @ 20, 054 MSGET cPoNum      SIZE 058, 08 OF oDlg PIXEL WHEN .F. PICTURE (_PictPO)
   @ 20, 158 MSGET dPo         SIZE 045, 08 OF oDlg PIXEL WHEN .F.
   @ 33, 054 MSGET cNrProforma SIZE 058, 08 OF oDlg PIXEL
   @ 34, 158 MSGET dDtProforma SIZE 045, 08 OF oDlg PIXEL WHEN lEdita
   @ 46, 054 MSGET nPesoBruto  SIZE 058, 08 OF oDlg PIXEL          PICTURE AVSX3("W2_PESO_B",6)
   @ 46, 129 MSGET cImp        SIZE 103, 08 OF oDlg PIXEL WHEN .F.
   @ 59, 070 MSGET nTotPedido  SIZE 074, 08 OF oDlg PIXEL WHEN .F. PICTURE '@E 9,999,999,999.9999'
   IF SW2->(FIELDPOS("W2_INSTFIN"))>0
      @ 60, 200 MSGET cInstFin      SIZE 45,08 OF oDlg PIXEL F3 "SJ7"
   ENDIF

   //--- Carrega Moeda ---\\
   oSayTotPed:SetText( STR0064  +SW2->W2_MOEDA ) //STR0064  "Tot. do Pedido"
   
   IF lGets

      @ 73,04 TO 198, 308 LABEL "PrePaid" OF oDlg  PIXEL

      @ 082, 009 SAY STR0009          SIZE 55,08 OF oDlg PIXEL //"Peso Bruto"   
      /*IF SW2->(FIELDPOS("W2_PRACA"))>0
         @ 082, 220 SAY AVSX3("W2_PRACA",5) SIZE 24,08 OF oDlg PIXEL
      ENDIF*/ //LRL 22/01/04
      @ 094, 009 SAY STR0010          SIZE 55,08 OF oDlg PIXEL //"Bco.Recebedor"
      @ 092, 167 SAY STR0011          SIZE 45,08 OF oDlg PIXEL //"Cust.Transfer."
      @ 107, 009 SAY STR0012          SIZE 55,08 OF oDlg PIXEL //"Carta Credito"
      @ 104, 167 SAY STR0013          SIZE 42,08 OF oDlg PIXEL //"Contr. Cambio"
      @ 118, 009 SAY STR0014          SIZE 55,08 OF oDlg PIXEL //"Dt.Liquidado"
      @ 118, 167 SAY STR0015          SIZE 45,08 OF oDlg PIXEL //"Dt.Contrat"
      @ 131, 009 SAY oSayTxCambio     VAR STR0016     SIZE 55,08 OF oDlg PIXEL //"Tx.Cambio"
      @ 131, 167 SAY                  STR0017         SIZE 45,08 OF oDlg PIXEL //"Moe/Tx.Desp."
      @ 144, 009 SAY oSayVlAntecipado VAR STR0018     SIZE 55,08 OF oDlg PIXEL //"Vl.Antecipado"
      @ 145, 167 SAY                  STR0019         SIZE 45,08 OF oDlg PIXEL //"Valor R$"
      @ 158, 009 SAY oSayDespCambio   VAR STR0020     SIZE 55,08 OF oDlg PIXEL //"Desp. Cambio"
      @ 158, 167 SAY                  STR0021         SIZE 45,08 OF oDlg PIXEL //"Valor R$"
      @ 171, 009 SAY oSayCorretagem   VAR STR0022     SIZE 55,08 OF oDlg PIXEL //"Corretagem"
      @ 171, 167 SAY                  STR0023         SIZE 45,08 OF oDlg PIXEL //"Valor R$"
      @ 184, 009 SAY oSayTxReserva    VAR STR0024     SIZE 57,08 OF oDlg PIXEL //"Tx.de Reserva"
      @ 185, 167 SAY STR0025                          SIZE 45,08 OF oDlg PIXEL //"Valor R$"

      //--- Carrega Moeda ---\\
      oSayVlAntecipado:SetText(STR0026+SW2->W2_MOEDA) //"Vl.Antecipado "
      oSayDespCambio:SetText(  STR0027+cMoeDespesas ) //"Desp.Cambio "
      oSayCorretagem:SetText(  STR0051+cMoeDespesas ) //"Corretagem "
      oSayTxReserva:SetText(   STR0029+cMoeDespesas ) //"Tx.de Reserva "
      oSayTxCambio:SetText(    STR0030+SW2->W2_MOEDA) // "Tx. Cambio "
      
      @ 080, 068 MSGET cBanco_Agencia          SIZE 039, 08 OF oDlg PIXEL PICTURE "@R !!!/!!!!!" F3 "BC3" VALID(PO430Valid("BC")) 
      If(EasyEntryPoint("EICPO430"),ExecBlock("EICPO430",.F.,.F.,"PROFORMA"),)
      /*IF SW2->(FIELDPOS("W2_PRACA"))>0
         @ 080, 240 MSGET cPraca  SIZE 55,08 OF oDlg PIXEL
      ENDIF*///LRL 22/01/04
      @ 080, 118 MSGET oDesBanco Var cDesBanco SIZE 100, 08 OF oDlg PIXEL WHEN .F.
      @ 092, 069 MSGET cBcReceb                SIZE 082, 08 OF oDlg PIXEL 
      @ 093, 215 MSGET cCustumer               SIZE 082, 08 OF oDlg PIXEL 
      @ 105, 069 MSGET cCartaCredito           SIZE 045, 08 OF oDlg PIXEL PICTURE "@!" F3 "SWC"         VALID PO430Valid("CT")    
      @ 105, 215 MSGET cConCambio              SIZE 082, 08 OF oDlg PIXEL 
      @ 118, 069 MSGET dDtLiquidado            SIZE 045, 08 OF oDlg PIXEL 
      @ 118, 215 MSGET dDtCambio               SIZE 045, 08 OF oDlg PIXEL 
      @ 131, 069 MSGET nTxCambio               SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_TX_CAMBIO ) WHEN lEdita
      @ 132, 215 MSGET cMoeDespesas            SIZE 009, 08 OF oDlg PIXEL PICTURE "@!" F3 "SYF"         VALID PO430Valid("MOE")   
      @ 132, 242 MSGET nTxDespesas             SIZE 056, 08 OF oDlg PIXEL PICTURE ( PICT_TX_DESPESAS )                            
      @ 145, 069 MSGET nVlAntecipado           SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_VL_ANTECIPADO) VALID PO430Valid("VL1") WHEN lEdita  
      @ 145, 215 MSGET oReal1 Var nReal1       SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_VL_REAL )      WHEN .F.
      @ 158, 069 MSGET nDespCambio             SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_DSP_CAMBIO )   VALID PO430Valid("VL2")   
      @ 158, 215 MSGET oReal2 Var nReal2       SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_VL_REAL )      WHEN .F.
      @ 172, 069 MSGET nCorretagem             SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_CORRETAGEM )   VALID PO430Valid("VL3")   
      @ 171, 215 MSGET oReal3 Var nReal3       SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_VL_REAL )      WHEN .F.
      @ 185, 069 MSGET nTxReserva              SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_VL_RESERVA )   VALID PO430Valid("VL4")   
      @ 185, 215 MSGET oReal4 Var nReal4       SIZE 082, 08 OF oDlg PIXEL PICTURE ( PICT_VL_REAL )      WHEN .F.

      PO430Valid("VL1")
      PO430Valid("VL2")
      PO430Valid("VL3")
      PO430Valid("VL4")

   ENDIF
    
ACTIVATE MSDIALOG oDlg ON INIT ;
      EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},;
                       {||nOpcao:=0,oDlg:End()}) CENTERED

IF nOpcao = 1
   SW2->(PO430GravaTela())
ENDIF

Return( Nil )

*-----------------------------*
FUNCTION PO430Valid(pTipo)
*-----------------------------*
DO CASE

   CASE pTipo == 'PO'

        IF EMPTY(cPoNum)
           Help("", 1, "AVG0000419")//"Pedido nÆo preenchido"
           Return .F.
        ENDIF

        SW2->(DBSETORDER(1))
        If ! SW2->(DBSEEK(xFilial()+cPoNum))
           Help("", 1, "AVG0000420")//"Pedido nÆo cadastrado"
           Return .F.
        Endif

   CASE pTipo == 'BC'           // Banco + Agencia.
  
        IF EMPTY(Substr(cBanco_Agencia,1,3))
           RETU .T.
        ENDIF

        IF !EMPTY(SUBSTR(cBanco_Agencia,4))
           IF ! SA6->(DBSEEK(xFilial()+cBanco_Agencia))
              Help("", 1, "AVG0000421")//"BANCO/AGÒNCIA NÇO CADASTRADO"
              RETURN .F.
           ENDIF
        ELSEIF ! EMPTY(cBanco_Agencia)
           IF ! SA6->(DBSEEK(xFilial()+cBanco_Agencia))
              Help("", 1, "AVG0000422")//"BANCO NÇO CADASTRADO"
              RETURN .F.
           ENDIF
        ENDIF

        cDesBanco:=SA6->A6_NOME
        oDesBanco:Refresh()
 
   CASE pTipo == 'CT'           // Carta de Credito.

        IF ! EMPTY(cCartaCredito)
           IF ! SWC->(DBSEEK(xFilial()+cCartaCredito))           
              Help("", 1, "AVG0000423")//"CARTA DE CREDITO NÇO CADASTRADA"
              RETURN .F.
           ENDIF
        ENDIF

   CASE pTipo == 'DT_C'         // Data de cambio.

        IF ! EMPTY(dDtCambio) .AND. dDtCambio < SW2->W2_PO_DT
           Help("", 1, "AVG0000424")//"DATA DE CÁMBIO NÃO PODE SER MENOR QUE A DATA DO P.O."
           RETURN .F.
        ENDIF

   CASE pTipo == 'LIQ'          // Data Liquidado.

        IF ! EMPTY(dDtLiquidado)  .AND. dDtLiquidado < SW2->W2_PO_DT
           Help("", 1, "AVG0000425")//"DATA LIQUIDADO NãO PODE SER MENOR QUE DATA DO P.O."
           RETURN .F.
        ENDIF        

   CASE pTipo == 'MOE'
       
        IF EMPTY(cMoeDespesas)
           Help("", 1, "AVG0000426")//"MOEDA NO PREENCHIDA"
           RETURN .F.
        ELSE 
           IF ! SYF->(DBSEEK(xFilial()+cMoeDespesas))             
              Help("", 1, "AVG0000427")//"MOEDA NÇO CADASTRADA"
              RETURN .F.
           ENDIF
        ENDIF  
        
        oSayVlAntecipado:SetText(STR0049+SW2->W2_MOEDA) //"Vl.Antecipado "
        oSayDespCambio:SetText(STR0050+cMoeDespesas) //"Desp.Cambio "
        oSayCorretagem:SetText(STR0051+cMoeDespesas) //"Corretagem "
        oSayTxReserva:SetText(STR0052+cMoeDespesas) //"Tx.de Reserva "

   CASE pTipo == 'VL1'          // Valor real Antecipado.

        nReal1:= (nVlAntecipado * nTxCambio)
        oReal1:Refresh()

   CASE pTipo == 'VL2'          // Valor Real de Despesa de Cambio.

        nReal2:= (nDespCambio * nTxDespesas)
        oReal2:Refresh()

   CASE pTipo == 'VL3'          // Valor real de Corretagem.

        nReal3:= (nCorretagem * nTxDespesas)
        oReal3:Refresh()
 
   CASE pTipo == 'VL4'          // Valor Real de Reserva.

        nReal4:= (nTxReserva * nTxDespesas)
        oReal4:Refresh()

ENDCASE

RETURN .T.

*-----------------------*
FUNCTION PO430When(pTipo)
*-----------------------*
DO CASE 
   CASE pTipo == 'VL1'
        oVlAntecipado:SetText( STR0053+SW2->W2_MOEDA )//"Vl.Antecipado "

   CASE pTipo == 'VL2'
        oDespCambio:SetText( STR0054+cMoeDespesas ) //"Desp.Cambio "

   CASE pTipo == 'VL3'
        oCorretagem:SetText( STR0055+cMoeDespesas ) //"Corretagem "

   CASE pTipo == 'VL4'
        oTxReserva:SetText( STR0056+cMoeDespesas ) //"Tx.de Reserva "
        
ENDCASE

RETURN .T.

*-----------------------*
FUNCTION PO430GravaTela()
*-----------------------*
IF lGets .AND. lFinanceiro// AWR - 20/05/2004 - MP135
   lPO430Sair := .F.
   EICFI400("EICPO430")
   IF lPO430Sair
      RETURN .F.
   ENDIF
ELSE
   IF !MsgYesNo(STR0057,STR0058) //'Confirma as informações da Proforma ?'###"Proforma"
      RETURN .F.
   ENDIF
ENDIF

SW2->(RecLock("SW2",.F.))
SW2->W2_NR_PRO   := cNrProforma  
SW2->W2_DT_PRO   := dDtProforma  
SW2->W2_PESO_B   := nPesoBruto   
IF lGets
   SW2->W2_BANCO    := Substr(cBanco_Agencia,1,3)
   SW2->W2_AGENCIA  := Substr(cBanco_Agencia,4)
   SW2->W2_BAN_RECB := cBcReceb      
   SW2->W2_CUST_TRA := cCustumer    
   SW2->W2_LC_NUM   := cCartaCredito
   SW2->W2_NRCCAMBI := cConCambio   
   SW2->W2_RECCCAM  := dDtLiquidado 
   SW2->W2_TX_CAM   := nTxCambio    
   SW2->W2_FOB_ANTE := nVlAntecipado
   SW2->W2_TX_DESP  := nTxDespesas  
   SW2->W2_MOE_DESP := cMoeDespesas 
   SW2->W2_CORRETAG := nCorretagem   
   SW2->W2_EMISCCAM := dDtCambio     
   SW2->W2_TX_RESER := nTxReserva    
   SW2->W2_DESP_CAM := nDespCambio
   IF SW2->(FIELDPOS("W2_INSTFIN"))>0
      SW2->W2_INSTFIN := cInstFin
   ENDIF           
   /*IF SW2->(FIELDPOS("W2_PRACA"))>0
      SW2->W2_PRACA := cPraca 
   ENDIF */ //LRL 22/01/04
ENDIF 
SW2->(MSUNLOCK())

IF !EMPTY(dDtProforma)
   Grava_Ocor(cPoNum,dDataBase,STR0059 +DTOC(dDtProforma)) //"DATA DE CHEGADA DA PROFORMA "
ENDIF

RETURN ( .T. )

//-------------------> FIM DO PO430.PRG <----------------------\\

