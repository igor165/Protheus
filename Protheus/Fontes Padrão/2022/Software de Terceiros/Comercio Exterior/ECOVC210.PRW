#INCLUDE "Ecovc210.ch"
#include "AVERAGE.CH"


*-------------------*
Function ECOVC210( )
*-------------------*
LOCAL cAliasAnt:=ALIAS(), cOrdAnt
PRIVATE aHeader[0]//E_CriaTrab utiliza
Private aCampoEC9:=;
   {{{||Work->EC9_ID_CAM}                               , "", STR0001   },; //"Tipo Evento"
    {{||Work->EC9_DTCONT}                               , "", STR0002   },; //"Data Evento"
    {{||Work->EC9_NR_CON}                               , "", STR0046   },; //"Nr.Contab."
    {{||Trans(Work->EC9_VALOR,'@E 999,999,999,999.99')} , "", STR0003   },; //"Valor em R$"
    {{||Trans(Work->EC9_VL_MOE,'@E 999,999,999,999.99')}, "", STR0004},; //"Valor na Moeda"
    {{||Trans(Work->EC9_PARIDA,'@E 999,999.999999')}    , "", STR0005 },; //"Taxa na Moeda"
    {{||Trans(Work->EC9_FLUTUA,'@E 999,999.999999')}    , "", STR0006   },; //"Taxa do US$"
    {{||Work->EC9_DTCONV}                               , "", STR0007 },; //"Data de Conv."
    {{||Work->EC9_DESCR}                                , "", STR0008     } } //"Descricao"
Private cMesProc := AllTrim(EasyGParam("MV_MESPROC")), nOpca := 0, aDeletados:={}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := STR0012 //"Cadastro de pagamento ao fornecedor."
PRIVATE cFilSA2:=xFilial("SA2");cFilEC9:=xFilial("EC9");cFilECC:=xFilial("ECC");cFilEC6:=xFilial("EC6")
PRIVATE cMarca    := GetMark(), lInverte := .F., lAlteracao:=.F., dData_Con, cOpPadr

aStruct = EC9->(DBSTRUCT())
AADD(aStruct,{"WKRECNO","N",6,0})

//TRP - 01/02/07 - Campos do WalkThru
AADD(aStruct,{"TRB_ALI_WT","C",03,0})
AADD(aStruct,{"TRB_REC_WT","N",10,0})

cNomArqEC9 := E_CriaTrab(, aStruct, "Work")
IF ! USED()
   E_Msg(STR0013,20) //"N„o ha area disponivel para abertura do arquivo temporario."
   RETURN .F.
ENDIF                                

IndRegua("Work",cNomArqEC9+TEOrdBagExt(),"EC9_ID_CAM+DTOS(EC9_DTCONT)",;
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0014) //"Processando Arquivo Temporario..."

cMes = STRZERO(VAL(SUBSTR(cMesProc,1,2))+1,2,0)
cAno = SUBSTR(cMesProc,3,4)
IF cMes = "13"
   cMes = "01"
   cAno = STRZERO(VAL(cAno)+1,4,0)
ENDIF

dData_Con = AVCTOD("01/"+cMes+"/"+cAno) - 1

EC5->(DBSETORDER(1))
EC6->(DBSETORDER(1))
EC9->(DBSETORDER(1))
SA2->(DBSETORDER(1))

SX3->(DBSETORDER(2))
IF SX3->(DbSeek("EC9_LANCMA"))
   cOpPadr:= (Alltrim(SX3->X3_RELACAO))
Endif

AAdd(aCampoEC9,{ {||If(Work->EC9_LANCMA='1',STR0044,STR0045)}, "", STR0043})  //"Lanc.Manu" # Sim # Nao

DbSelectArea("EC5")

mBrowse( 6, 1,22,75,"EC5")

//SETKEY(1,{||.T.})
//SETKEY(5,{||.T.})
//SETKEY(16,{||.T.})
//SETKEY(22,{||.T.})

Work->(E_EraseArq(cNomArqEC9))
DBSELECTAREA(cAliasAnt)
Return .T.                  


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 02/02/07 - 15:58
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0009   ,"AxPesqui", 0 , 1},; //"Pesquisar"
                    { STR0010   ,"VC210EC5", 0 , 2},; //"Visual"
                    { STR0011   ,"VC210EC5", 0 , 4, 20 } } //"Altera"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("CVC210MNU")
	aRotAdic := ExecBlock("CVC210MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*-------------------------------------*
Function VC210EC5(cAlias,nReg,nOpc)
*-------------------------------------*
LOCAL cFob, bVal_Ok, i
Private oPanel //LRL 02/06/04
Private nSaldo:=0
Private aButtons:= {}  // GFP - 17/11/2011 - Substituição por EnchoiceBar

//GFP - 17/11/2011 - Carrega botões para EnchoiceBar
aAdd(aButtons,{"S4WB008N",{||Calculadora()},STR0029})  //Calculadora
If nOpc == 2  //Visualizar
   bVal_OK:={||oDlg:End()}
   aAdd(aButtons,{"BMPVISUAL",{||(nOpca:=2,oDlg:End())},STR0031})  //Visualizar Item
Else
   bVal_OK:={||(nOpca:=1,oDlg:End())}
   aAdd(aButtons,{"BMPINCLUIR",{||(nOpca:=3,oDlg:End())},STR0032})   //Inclusao
   aAdd(aButtons,{"EDIT",{||(nOpca:=5,oDlg:End())},STR0033})    //Exclusao
   aAdd(aButtons,{"IC_17",{||(nOpca:=4,oDlg:End())},STR0034})   //Alteracao
EndIf

IF ! SA2->(DBSEEK(xFilial("SA2")+EC5->EC5_FORN))
   Help(" ",1,"AVG0005302") //E_MSG(STR0015,1) //"Fornecedor não cadastrado no arquivo de fornecedores."
   Return .F.
ENDIF

If ! ECC->(DBSEEK(xFilial("ECC")+EC5->EC5_IDENTC))
   Help(" ",1,"AVG0005303") //E_Msg(STR0016,1) //"B.U. / Unid.Req. n„o cadastrado."
   RETURN .F.
EndIf

DBSELECTAREA("Work")
AvZap()

EC9->(DBSEEK(xFilial("EC9")+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
nSaldo := EC5->EC5_FOB_TO
cFilEC9:= xFilial("EC9")
Do While ! EC9->(EOF()) .AND. EC9->EC9_FORN=EC5->EC5_FORN .AND. EC9->EC9_INVOIC=EC5->EC5_INVOIC .AND. EC9->EC9_IDENTC=EC5->EC5_IDENTC .AND. EC9->EC9_FILIAL=cFilEC9
   Work->(DBAPPEND())
   For i := 1 TO EC9->(FCount())
       If Work->(FIELDPOS(FIELDNAME(i))) # 0
          Work->(FieldPut(i,EC9->&(FIELDNAME(i))))
       EndIf
   Next
   Work->WKRECNO := EC9->(RECNO())
   Work->TRB_ALI_WT:= "EC9"
   Work->TRB_REC_WT:= EC9->(Recno())
   // Inicia o campo de acordo o X3_RELACAO   

   If Work->EC9_LANCMA # '1'
      Work->EC9_LANCMA := '2'                 
   Endif    
   
   If LEFT(EC9->EC9_ID_CAM,1) = "6"
      nSaldo = nSaldo - EC9->EC9_VL_MOE
   EndIf
   EC9->(DBSKIP())
ENDDO
aDeletados:={}
Do While .T.
   nOpca := 0
   Work->(DBGOTOP())

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
// DEFINE MSDIALOG oDlg TITLE cCadastro ;
//        FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
//        TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL
      //@ 00,00 MsPanel oPanel Prompt "" Size 60,40 of oDlg
      nLin  := 1.5 //0.7 - GFP - 18/11/2011
      nColS := 0.8
      nColG := 6.0
      nColS2:= 21.0
      nColG2:= 25.0
      cFob  := EC5->EC5_MOE_FO+" "+ALLTRIM(TRANS(EC5->EC5_FOB_TO,'@E 9,999,999,999.9999'))+" "+ECondPgto(EC5->EC5_CD_PGT)
      M->EC5_INVOIC:=EC5->EC5_INVOIC
      M->A2_NREDUZ :=EC5->EC5_FORN+'-'+SA2->A2_NREDUZ
      M->EC5_IDENTC:=EC5->EC5_IDENTC+'-'+ECC->ECC_DESCR

      @ nLin  ,nColS  SAY STR0017 of oDlg //oPanel //"Invoice"
      @ nLin++,nColS2 SAY STR0018 of oDlg //oPanel //"Moeda"
      @ nLin  ,nColS  SAY STR0019 of oDlg //oPanel //"B.U./Unid.Req."
      @ nLin  ,nColS2 SAY STR0020 of oDlg //oPanel //"Fornecedor"
      nLin  := 1.5 //0.7 - GFP - 18/11/2011
      @ nLin  ,nColG  MSGET M->EC5_INVOIC WHEN .F. SIZE 40,08 OF oDlg //oPanel
      @ nLin++,nColG2 MSGET cFob          WHEN .F. SIZE 100,08 OF oDlg //oPanel
      @ nLin  ,nColG  MSGET M->EC5_IDENTC WHEN .F. SIZE 110,08 OF oDlg //oPanel
      @ nLin  ,nColG2 MSGET M->A2_NREDUZ  WHEN .F. SIZE 100,08 OF oDlg //oPanel
      
      aPos := PosDlg(oDlg)
      oObj:= MsSelect():New("Work",,,aCampoEC9,@lInverte,@cMarca,{47,aPos[2],aPos[3],aPos[4]},,,oDlg)   
 //  oObj:=MsSelect():New("Work",,,aCampoEC9,@lInverte,@cMarca,{47,1,iif(SetMDIChild(), ((oDlg:nHeight-30)/2)+55, (oDlg:nHeight-30)/2),(oDlg:nClientWidth-4)/2},,,oDlg)
      oObj:bAval:={||(IF(nOpc=3,nOpca:=4,nOpca:=2),oDlg:End())}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bVal_OK,{||oDlg:End()},,aButtons) CENTERED
   /*
   ACTIVATE MSDIALOG oDlg ON INIT (VC210BAR(nOpc,oDlg,bVal_OK,{||oDlg:End()}),;
                             oPanel:Align:=CONTROL_ALIGN_TOP,;            //LRL 
                             oObj:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT) //02/06/04
  */
// SETKEY(1,{||.T.})
// SETKEY(5,{||.T.})
// SETKEY(16,{||.T.})
// SETKEY(22,{||.T.})

   IF nOpca == 0
      EXIT
   ElseIf nOpca == 1
      Processa({||VC210Grava()},STR0021) //"Gravando Arq. de Eventos..."
      EXIT
   Elseif STR(nOpca,1)$'2,3,4,5'
      VC210EC9(nOpca)
   ENDIF
EndDo

RETURN .T.

*------------------------*
PROCEDURE VC210EC9(nTipo)
*------------------------*
LOCAL oDlg1,oEnch, dCONT1, aCampos := {}, i
Local lExisteECF := EasyGParam("MV_PAGANT", .F., .F.)
SX3->(DbSetOrder(2))
                    	
PRIVATE aTela[0][0],aGets[0],nUsado:=0, nRegWork:=Work->(RECNO())

// Verifica quais campos irao ser exibidos na enchoice
For i := 1 TO EC9->(FCount())
    SX3->(DbSeek(ALLTRIM(EC9->(FIELDNAME(I)))))
    If X3USO(SX3->X3_USADO) .AND. (lExisteECF .Or. (!lExisteECF .And. ALLTRIM(EC9->(FIELDNAME(I))) # "EC9_PAGANT" .AND. ;
									ALLTRIM(EC9->(FIELDNAME(I))) # "EC9_SEQ" .AND. ;
									ALLTRIM(EC9->(FIELDNAME(I))) # "EC9_NRCON2" ))   
       AAdd(aCampos,EC9->(FIELDNAME(I)))
    EndIf
Next
SX3->(DbSetOrder(1))

DBSELECTAREA('Work')

IF STR(nTipo,1) $ "2,4,5"
   IF Work->(EOF()) .AND. Work->(BOF())
      Help(" ",1,"AVG0005304") //MSGSTOP(STR0022,STR0023) //"Invoice nÆo possui eventos."###"Aviso"
      Return .F.
   ENDIF
ENDIF

If nTipo = 3
   Work->(DBGOBOTTOM())
   nRegWork:=Work->(RECNO())+1
   Work->(DBSKIP())
Else
   If Left(Work->EC9_ID_CAM,1) = "6"
      nSaldo = nSaldo + Work->EC9_VL_MOE
   EndIf
EndIf

FOR i := 1 TO Work->(FCount())
    M->&(FIELDNAME(i)) := Work->(FIELDGET(i))
NEXT i
        
If nTipo = 2

   M->EC9_LANCMA := If(Empty(Work->EC9_LANCMA),'2',Work->EC9_LANCMA)

Elseif nTipo = 3
   EC9->(DBSEEK(xFilial("EC9")+EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC))
   FOR i := 1 TO EC9->(FCount())
       M->&(FIELDNAME(i)) := EC9->(FIELDGET(i))
   NEXT i
   M->EC9_INVOIC := EC5->EC5_INVOIC
   M->EC9_IDENTC := EC5->EC5_IDENTC
   M->EC9_PARIDA := M->EC9_FLUTUA:= 0
   M->EC9_NR_CON := '0000'
   M->EC9_DTCONT :=AVCTOD('  /  /  ')
   M->EC9_VL_MOE :=nSaldo
   M->EC9_ID_CAM :=IF(EC5->EC5_CD_PGT="1","602","603")
   M->EC9_DESCR  := SPAC(LEN(EC9->EC9_DESCR))   
   M->EC9_FORN   := EC5->EC5_FORN      // -- ACSJ - 25/03/2004
  // M->EC9_DESCR :=  EC5->EC5_FORN    // -- ACSJ - 25/03/2004
   
   // Inicia o campo de acordo o X3_RELACAO
   M->EC9_LANCMA := &(cOpPadr)
   
   lAlteracao:=.F.

ElseIf STR(nTipo,1) $ '45'
   M->EC9_LANCMA := If(Empty(Work->EC9_LANCMA),'2',Work->EC9_LANCMA)
                                 
   If nTipo = 4
      lAlteracao:=.T.
   Else
      lAlteracao:=.F.
   EndIf
// EC9->(DBSETORDER(2))
// EC9->(DBSEEK(cFilEC9+EC5->EC5_INVOIC+EC5->EC5_IDENTC+"6",.T.))
// EC9->(DBSKIP(-1))
// IF (EC5->EC5_INVOIC+EC5->EC5_IDENTC)#(EC9->EC9_INVOIC+EC9->EC9_IDENTC) .OR. EC9->(BOF()) .OR. EC9->(EOF()) .OR. cFilEC9#EC9->EC9_FILIAL
//    dCONT1 := AVCTOD("  /  /  ")
// ELSE
//    dCONT1 := EC9->EC9_DTCONT
// ENDIF
// EC9->(DBSETORDER(1))

//   IF !(Work->EC9_DTCONT > dCONT1 .OR. VAL(EC9->EC9_NR_CON)=0 .OR. VAL(EC9->EC9_NR_CON)=9999)
   IF VAL(M->EC9_NR_CON)# 0 .AND. VAL(M->EC9_NR_CON)# 9999
      If nTipo = 4
         E_MSG(STR0024,1) //"Lan‡amento n„o pode ser alterado."
      Else
         E_MSG(STR0025,1) //"Lan‡amento n„o pode ser excluido."
      EndIf
      RETURN .F.
   EndIf
   
EndIf

EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+M->EC9_ID_CAM))

M->EC9_CAM_DE:= EC6->EC6_DESC
M->EC9_MOEDA := EC5->EC5_MOE_FO

WHILE .T.
    nOpc1 := 0

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg1 TITLE STR0026+Work->EC9_INVOIC ; //'Evento da Invoice '
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
            TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

    oEnCh:=MsMGet():New("EC9",nRegWork,3,,,,aCampos,{15,1,(oDlg1:nHeight-30)/2,(oDlg1:nClientWidth-4)/2},If(Str(nTipo,1)$'2,5',{},),3)
    oEnCh:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	
	
    ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1,{||nOpc1:=1,IF(VC210EC9MAN(nTipo,nRegWork),oDlg1:End(),nOpc1:=0)},{||oDlg1:End()}))//LRL 02/06/05  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                             
    Work->(DBGOTO(nRegWork))

    IF nOpc1 == 0
       EXIT
    ENDIF

    If ! (STR(nTipo,1,0)$'25')
       If M->EC9_ID_CAM = "6"
          nSaldo = nSaldo - M->EC9_VL_MOE
       EndIf
    EndIf

    If nTipo = 3
       Work->(DBAPPEND())
    EndIf

    If ! STR(nTipo) $ '2,5'
       For i := 1 TO Work->(FCount())
           Work->(FieldPut(i,M->&(FIELDNAME(i))))
       Next
       Work->EC9_DT_LAN:=dData_Con
       Work->TRB_ALI_WT:= "EC9"
       Work->TRB_REC_WT:= EC9->(Recno())
    EndIf
    EXIT
EndDo
Return .T.

*-------------------------------*
FUNCTION VC210EC9MAN(nTipo,nRegWork)
*-------------------------------*
LOCAL lRet:=.T.
IF nTipo # 5
   IF nTipo # 2
      lRet:=Obrigatorio(aGets,aTela)
      IF lRet
         lRet:=VC210Val('TUDO')
      ENDIF
   ENDIF
ELSE
   Work->(DBGOTO(nRegWork))
   IF SimNao(STR0027,,,,,STR0028) = "S" //'Confirma `a Exclusao ? '###'Excluir'
      IF Work->WKRECNO # 0
         AADD(aDeletados,Work->WKRECNO)
      ENDIF
      Work->(DBDELETE())
   Else
      If Work->EC9_ID_CAM = "6"
         nSaldo = nSaldo - M->EC9_VL_MOE
      EndIf
   ENDIF
ENDIF
RETURN lRet

*-----------------------*
Function VC210Val(cTipo)
*-----------------------*

If cTipo = 'ID_CAM' .OR. cTipo = 'TUDO'

   //AAF - 23/07/04 - Validação para a unidade requesitante.
   IF cTipo = 'TUDO' .AND. !EC6->(DbSeek(xFilial("EC6")+"IMPORT"+M->EC9_ID_CAM+M->EC9_IDENTC))
      MsgStop(STR0052+M->EC5_IDENTC) //"Evento contabil não cadastrado para Unidade Requesitante "
      RETURN .F.
   ENDIF

   IF (EC5->EC5_CD_PGT = "1" .AND. M->EC9_ID_CAM # "602") .OR.;
      (EC5->EC5_CD_PGT # "1" .AND. M->EC9_ID_CAM # "603")

      Help(" ",1,"AVG0005305") //E_Msg(STR0036,1) //"Tipo de pagamento inv lido."
      RETURN .F.
   ENDIF

   IF  LEFT(M->EC9_ID_CAM,1) = "6" .AND. nSALDO <= 0
       E_Msg(STR0037,1) //"N„o h  saldo a pagar."
       RETURN .F.
   ENDIF
   EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+M->EC9_ID_CAM))
   M->EC9_CAM_DE:= EC6->EC6_DESC

ENDIF

If cTipo = 'DTCONT' .OR. cTipo = 'ID_CAM' .OR. cTipo = 'TUDO'
   IF ! EMPTY(M->EC9_DTCONT) .AND. ! EMPTY(M->EC9_ID_CAM)
      If cTipo = 'DTCONT' .OR. cTipo = 'TUDO'
         M->EC9_FLUTUA:= ECOBuscaTaxa("US$",M->EC9_DTCONT)
      EndIf

      Work->(DBSEEK(M->EC9_ID_CAM+DTOS(M->EC9_DTCONT)))

//    IF ! Work->(EOF()) .AND. Work->(RECNO()) # nRegWork
//       E_MSG("Tipo e data de pagamento j  cadastradas.",1)
//       RETURN .F.
//    ENDIF

      IF Inclui

         EC9->(DBSETORDER(2))
         EC9->(DBSEEK(xFilial("EC9")+M->EC9_FORN+M->EC9_INVOIC+M->EC9_IDENTC+"101"))

         IF EC9->(EOF())
            //nNr_Cont := 9999                 // Verificar Victor
            IF M->EC9_DTCONT < EC5->EC5_DT_EMI //.OR. nNr_Cont <> 9999
               E_MSG(STR0039,1) //"Dt de pagto. menor que data emiss„o da inv. ou menor que data da ultima cont."
               EC9->(DBSETORDER(1))
               RETURN .F.
            ENDIF

         ELSE
            EC9->(DBSEEK(xFilial("EC9")+M->EC9_FORN+M->EC9_INVOIC+M->EC9_IDENTC+"6",.T.))
            EC9->(DBSKIP(-1))
            EC9->(DBSETORDER(1))
            IF M->EC9_DTCONT < EC9->EC9_DTCONT .AND. VAL(EC9->EC9_NR_CON) <> 9999
               E_MSG(STR0040,1) //"Data de pagto. menor que data emiss„o da inv. ou menor que data da ultima cont."
               RETURN .F.
            ENDIF

         ENDIF
      ENDIF
   ENDIF
EndIf
If cTipo = 'VL_MOE' .OR. cTipo = 'VALOR' .OR. cTipo = 'TUDO'
   If cTipo = 'VL_MOE' .OR. cTipo = 'TUDO'
      If (nSaldo-M->EC9_VL_MOE)<0
         E_MSG(STR0041,1) //"Valor ultrapassou o valor total da invoice."
         Return .F.
      EndIf
   EndIf
   If ! EMPTY(M->EC9_VL_MOE) .AND. ! EMPTY(M->EC9_VALOR)
      M->EC9_PARIDA := M->EC9_VALOR / M->EC9_VL_MOE
   EndIf
EndIf                                 

If cTipo = 'FORN' .OR. cTipo = 'TUDO'
   IF ! SA2->(DBSEEK(xFilial("SA2")+M->EC9_FORN))
      Help(" ",1,"AVG0005302") //E_Msg(STR0015,1) //"Fornecedor n„o cadastrado."
      RETURN .F.
   ENDIF
ENDIF     

lRefresh:=.t.

Return .T.

*---------------------------*
Static Function VC210Grava()
*---------------------------*
LOCAL nI

ProcRegua(Work->(LASTREC())+LEN(aDeletados)+1)
IncProc(STR0042) //"Gravando ..."

FOR nI=1 to LEN(aDeletados)
    IncProc()
    EC9->(DBGOTO(aDeletados[nI]))
    RecLock("EC9",.F.)
    EC9->(DBDELETE())
NEXT

Work->(DBGOTOP())

Do While ! Work->(EOF())
    IncProc()
    IF Work->WKRECNO # 0
       EC9->(DBGOTO(Work->WKRECNO))
       RecLock('EC9',.F.)
    ELSE
       RecLock('EC9',.T.)
    ENDIF

//  For i := 1 TO Work->(FCount())
//      If EC9->(FIELDPOS(FIELDNAME(i))) # 0
//         EC9->(FieldPut(i,Work->&(FIELDNAME(i))))
//      EndIf
//  Next
    AVREPLACE("Work","EC9")
    EC9->EC9_FILIAL:=xFilial("EC9")
	EC9->EC9_NR_CON := If(VAL(Work->EC9_NR_CON)=0,'0000',STRZERO(VAL(Work->EC9_NR_CON),4,0))
	//If lLancMan 
   	//  EC9->EC9_LANCMA := If(!Empty(Work->EC9_LANCMA),Work->EC9_LANCMA,)
   	//Endif  
    EC9->(MSUNLOCK())

    Work->(DBSKIP())
EndDo

RETURN .T.
