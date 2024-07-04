#INCLUDE "Ecoap400.ch"
#include "AVERAGE.CH"
                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECOAP400 ³ Autor ³ EMERSON DIB SALVADOR  ³ Data ³ 25.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao de Adiantamentos / Pagamentos Antecipados       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAECO                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*-----------------------------------------------------------------------------------------------*
Function ECOAP401()   //Pagamento Antecipado
*-----------------------------------------------------------------------------------------------*
ECOAP400("Imp")
Return .T.

*-----------------------------------------------------------------------------------------------*
Function ECOAP402()  //NF/Câmbio
*-----------------------------------------------------------------------------------------------*
ECOAP400("Exp")
Return .T.

*-------------------------*
Function ECOAP400R3(cParam,p_R4)
*-------------------------*
Return ECOAP400(cParam,.F.)

*-------------------------*
Function ECOAP400(cParam,p_R4)
*-------------------------*
Local cAliasAnt:=ALIAS(), cOrdAnt
Private aHeader[0]//E_CriaTrab utiliza
Private cTipo:= cParam, aFixos:= {}
Private lR4  := If(p_R4==NIL,.T.,p_R4)

Private aCampoECF:=;
   {{{||If(cTipo=="Imp",Work->ECF_INVOIC,Work->ECF_INVEXP)}, "", STR0001   },;  //'Invoice'
    {{||Work->ECF_SEQ}                                  , "", STR0002   },;  //'Sequencia'
    {{||Work->ECF_ID_CAM}                               , "", STR0003   },;  //"Tipo Evento"
    {{||Work->ECF_DTCONT}                               , "", STR0004   },;  //"Data Evento"
    {{||Work->ECF_NR_CON}                               , "", STR0005   },;  //"Nr.Contab."
    {{||Trans(Work->ECF_VALOR,'@E 999,999,999,999.99')} , "", STR0006   },;  //"Valor em R$"
    {{||Trans(Work->ECF_VL_MOE,'@E 999,999,999,999.99')}, "", STR0007   },;  //"Valor na Moeda"
    {{||Trans(Work->ECF_PARIDA,'@E 999,999.999999')}    , "", STR0008   },;  //"Taxa Atual"
    {{||Trans(Work->ECF_FLUTUA,'@E 999,999.999999')}    , "", STR0009   }}   //"Taxa Anterior"

If cTipo=="Exp"
   aFixos:={{AVSX3("ECG_PREEMB" ,5) ,"ECG_PREEMB"   },;
            { AVSX3("ECG_IDENTC" ,5) ,"ECG_IDENTC"  },;
            { AVSX3("ECG_DT" ,5)     ,"ECG_DT"      },;
            { AVSX3("ECG_ULT_TX" ,5) ,"ECG_ULT_TX"  }}
Else
   aFixos:={{AVSX3("ECG_HAWB" ,5)    ,"ECG_HAWB"    },;
            { AVSX3("ECG_IDENTC" ,5) ,"ECG_IDENTC"  },;
            { AVSX3("ECG_DT" ,5)     ,"ECG_DT"      },;
            { AVSX3("ECG_ULT_TX" ,5) ,"ECG_ULT_TX"  },;
            { AVSX3("ECG_FORN"   ,5) ,"ECG_FORN"    }}
Endif

Private cMesProc := AllTrim(EasyGParam("MV_MESPROC")), nOpca := 0, aDeletados:={}
Private aRotina := MenuDef(ProcName(1))
Private cCadastro:= If(cTipo == "Imp", STR0012, STR0024) //"Pagamentos Antecipados"###"N.F./Cambio"
Private cFilSA2:=xFilial("SA2") , cFilECF:=xFilial("ECF") , cFilECG:=xFilial("ECG")
Private cFilEC2:=xFilial("EC2") , cFilEC5:=xFilial("EC5"), aMostraECF:= {}, aMostraECG:= {}
Private cFilECC:=xFilial("ECC"), cFilEC6:=xFilial("EC6"), cOpPadr, cOrigem := SPACE(02), lTravaChave := .F.
Private cMarca:= GetMark(), lInverte := .F., lAlteracao:=.F., dData_Con, lLancMan := .F.
private cTPMODU := ""
private lTempTPMODU
private bTPMODUECF 
private bTPMODUECG
Private cNomArqECF

SX3->(DBSetOrder(2))
lTemTPMODU := SX3->(DbSeek("ECG_TPMODU")) .AND. SX3->(DbSeek("ECF_TPMODU"))
SX3->(DBSetOrder(1))
 
If lTemTPMODU
   If cTipo=="Imp"
      cTPMODU:='IMPORT'
      bTPMODUECF := {|| ECF->ECF_TPMODU = 'IMPORT' }
      bTPMODUECG := {|| ECG->ECG_TPMODU = 'IMPORT' }
   Else
      cTPMODU:='EXPORT'
      bTPMODUECF := {|| ECF->ECF_TPMODU = 'EXPORT' }
      bTPMODUECG := {|| ECG->ECG_TPMODU = 'EXPORT' }
   EndIf
Else
   bTPMODUECF := {|| .T. }
   bTPMODUECG := {|| .T. }   
EndIf

If cTipo == "Imp"
   aMostraECF:= {"ECF_HAWB","ECF_IDENTC","ECF_INVOIC","ECF_FORN","ECF_DI_NUM","ECF_ID_CAM","ECF_CAM_DE",;
                 "ECF_SEQ","ECF_MOEDA","ECF_PARIDA","ECF_FLUTUA","ECF_VL_MOE","ECF_VALOR","ECF_DESCR",;
                 "ECF_NR_CON","ECF_CTA_CR","ECF_CTA_DB","ECF_TP_EVE","ECF_CONTAB"}
   aMostraECG:= {"ECG_HAWB","ECG_IDENTC","ECG_DT","ECG_SIS_OR","ECG_FORN","ECG_ULT_TX","ECG_NR_CON"}
Else
   aMostraECF:= {"ECF_PREEMB","ECF_IDENTC","ECF_INVEXP","ECF_ID_CAM","ECF_CAM_DE","ECF_SEQ","ECF_MOEDA",;
                 "ECF_PARIDA","ECF_FLUTUA","ECF_VL_MOE","ECF_VALOR","ECF_DESCR","ECF_TP_EVE","ECF_CONTRA","ECF_CONTAB"}
   aMostraECG:= {"ECG_PREEMB","ECG_IDENTC","ECG_DT","ECG_SIS_OR","ECG_ULT_TX","ECG_NR_CON"}
Endif

aAdd(aMostraECG, "ECG_DTENCE")

aStruct := ECF->(DBSTRUCT())
AADD(aStruct,{"WKRECNO","N",6,0})
//TRP - 05/02/07 - Campos do WalkThru
AADD(aStruct,{"TRB_ALI_WT","C",03,0})
AADD(aStruct,{"TRB_REC_WT","N",10,0})

cNomArqECF := E_CriaTrab(, aStruct, "Work")

IF !USED()
   E_Msg(STR0013,20)  //"Nao ha area disponivel para abertura do arquivo temporario."
   RETURN .F.
ENDIF                                

If cTipo=="Imp"
   cInd:= "ECF_INVOIC"
Else
   cInd:= "ECF_INVEXP"
Endif

IndRegua("Work",cNomArqECF+TEOrdBagExt(),cInd+"ECF_ID_CAM+ECF_SEQ+DTOS(ECF_DTCONT)",;
         "AllwaysTrue()",;
         "AllwaysTrue()",;
         STR0014)  //"Processando Arquivo Temporario..."

cMes = STRZERO(VAL(SUBSTR(cMesProc,1,2))+1,2,0)
cAno = SUBSTR(cMesProc,3,4)
IF cMes = "13"
   cMes = "01"
   cAno = STRZERO(VAL(cAno)+1,4,0)
ENDIF

dData_Con = AVCTOD("01/"+cMes+"/"+cAno) - 1

EC5->(DBSETORDER(1))
EC6->(DBSETORDER(1))
ECG->(DBSETORDER(1))
ECF->(DBSETORDER(1))
SA2->(DBSETORDER(1))

DbSelectArea("ECG")

/*
ECG->(DbSetFilter({|| If(cTipo == "Imp", ECG->ECG_ORIGEM == "IMP", ECG->ECG_ORIGEM <> "IMP")},;
"If(cTipo == 'Imp', ECG->ECG_ORIGEM == 'IMP', ECG->ECG_ORIGEM <> 'IMP')"))*/

If lTemTPMODU
   ECG->( DBSetFilter( {|| Eval(bTPMODUECG)},"Eval(bTPMODUECG)" ) )
Endif

mBrowse( 6, 1,22,75,"ECG",aFixos)

Set Filter To

Work->(E_EraseArq(cNomArqECF))
DBSELECTAREA(cAliasAnt)
Return .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 01/02/07 - 15:28
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina :=  { { STR0010 ,"AxPesqui",   0 , 1},;      //"Pesquisar"
				    { STR0030 ,"DataEnc",    0 , 1},;      // Nick 22/06/06 - Incluir a Data de Encerramento
                     { STR0011 ,"VCAP400ECG", 0 , 2},;       //"Visual"
                     { "Estornar" ,"AP400Est", 0 , 5} } //"E&stornar"

Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

// P.E. utilizado para adicionar itens no Menu da mBrowse                    
If cOrigem $ "ECOAP401" //Pagamento Antecipado
   If EasyEntryPoint("CAP401MNU")
	  aRotAdic := ExecBlock("CAP401MNU",.f.,.f.)
   EndIf                            
ElseIf cOrigem $  "ECOAP402" //NF/Câmbio
   If EasyEntryPoint("CAP402MNU")
	  aRotAdic := ExecBlock("CAP402MNU",.f.,.f.)
   EndIf                              
EndIf

If ValType(aRotAdic) == "A"
   AEval(aRotAdic,{|x| AAdd(aRotina,x)})
EndIf
   
Return aRotina

*-------------------------------------*
Function VCAP400ECG(cAlias,nReg,nOpc)
*-------------------------------------*
Local cFob, bVal_Ok, i
//FSM - 18/11/2011
Local bCancel := {||oDlg:End()} 
Local aButtons := {}
//FIM FSM
Private aTela[0][0],aGets[0],nUsado:=0

DBSELECTAREA('ECG')

cOrigem := ECG->ECG_ORIGEM
FOR i := 1 TO Work->(FCount())
    M->&(FIELDNAME(i)) := ECG->(FIELDGET(i))
NEXT i

// GFP - 22/11/2011
If Select("Work") > 0
   Work->(DbCloseArea())
EndIf

TETempReopen(cNomArqECF, "Work")
// Fim GFP - 22/11/2011

AvZap()

If cTipo == "Imp"
   ECF->(DbSetOrder(3))
   ECF->(DBSEEK(cFilECF+cTPMODU+M->ECG_HAWB+M->ECG_FORN+M->ECG_IDENTC))
   
   Do While !( ECF->(EOF()) ) .AND. ( ( M->ECG_HAWB+M->ECG_FORN+M->ECG_IDENTC ) = ( ECF->ECF_HAWB+ECF->ECF_FORN+ECF->ECF_IDENTC ) ) .AND.;
   			 ( ECF->ECF_FILIAL = cFilECF ) .and. Eval(bTPMODUECF)
      If ECF->ECF_ORIGEM == "PO"
         Work->(DBAPPEND())
         For i := 1 TO ECF->(FCount())
            If Work->(FIELDPOS(FIELDNAME(i))) # 0
               Work->(FieldPut(i,ECF->&(FIELDNAME(i))))
            EndIf
         Next
         Work->WKRECNO := ECF->(RECNO())
         Work->TRB_ALI_WT:= "ECF"
         Work->TRB_REC_WT:= ECF->(Recno())
      ENDIF
      ECF->(DBSKIP())
   ENDDO
Else
   ECF->(DbSetOrder(9))
   ECF->(DBSEEK(cFilECF+cTPMODU+cOrigem+M->ECG_PREEMB))
   
   Do While !( ECF->(EOF()) ) .AND. ( (cOrigem+M->ECG_PREEMB) = (ECF->ECF_ORIGEM+ECF->ECF_PREEMB) ) .and. Eval(bTPMODUECF)
      Work->(DBAPPEND())
      For i := 1 TO ECF->(FCount())
         If Work->(FIELDPOS(FIELDNAME(i))) # 0
            Work->(FieldPut(i,ECF->&(FIELDNAME(i))))
         EndIf
      Next
      Work->WKRECNO := ECF->(RECNO())
      Work->TRB_ALI_WT:= "ECF"
      Work->TRB_REC_WT:= ECF->(Recno())
      ECF->(DBSKIP())
   EndDo   
Endif

bVal_OK:={||oDlg:End()}

//FSM - 18/11/2011
aAdd(aButtons, {"S4WB008N",  {|| Calculadora() } ,STR0016} )//"Calculadora"
aAdd(aButtons, {"S4WB016N", {|| HelProg() }      ,"Help"} )//"Help de Programa"

Do While .T.
   nOpca := 0
   Work->(DBGOTOP())
      
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cCadastro ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL

      nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )

      EnChoice('ECG', nReg, nOpc, , , , aMostraECG, {15,1,nMeio-1 , (oDlg:nClientWidth-2)/2}, , 3 )

      oObj:=MsSelect():New('Work',,,aCampoECF,@lInverte,@cMarca,{nMeio,1,(oDlg:nClientHeight-2)/2,(oDlg:nClientWidth-2)/2})
      oObj:bAval:={||(IF(nOpc=3,nOpca:=4,nOpca:=2),oDlg:End())}
      oObj:oBrowse:bwhen:={||.T.}
   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bVal_OK,bCancel,,aButtons)
   /* FSM - 18/11/2011
   Ap400Bar(nOpc,oDlg,bVal_OK,{||oDlg:End()})
   */

   IF nOpca == 0 .Or. nOpca == 1
      Exit
   Else
      VCAP400ECF(nOpca)
   Endif
EndDo

RETURN .T.

*------------------------------------------*
Static Function VCAP400ECF(nTipo)
*------------------------------------------*
LOCAL oDlg1, dCONT1, i
PRIVATE aTela[0][0], aGets[0], nUsado:=0,  nRegWork:=Work->(Recno())

DBSELECTAREA('Work')

IF STR(nTipo,1) $ "2"
   IF Work->(EOF()) .AND. Work->(BOF())
      Msginfo(STR0028,STR0029) //"Processo não possui eventos para a Visualização!"###"Aviso"
      Return .F.
   ENDIF
ENDIF

FOR i := 1 TO Work->(FCount())
    M->&(FIELDNAME(i)) := Work->(FIELDGET(i))
NEXT i       
M->ECF_HAWB   := M->ECG_HAWB
M->ECF_ORIGEM := M->ECG_ORIGEM

EC6->(DBSEEK(cFilEC6+If(cTipo=="Imp","IMPORT",If(Empty(M->ECF_TP_EVE),"EXPORT","FIEX"+M->ECF_TP_EVE))+M->ECF_ID_CAM))
M->ECF_CAM_DE:= EC6->EC6_DESC

WHILE .T.
   nOpc1 := 0
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg1 TITLE STR0015+If(cTipo=="Imp",Work->ECF_INVOIC,Work->ECF_INVEXP) ; //'Altera‡„o de Detalhes - '###'Despesas'###'P.O.' //'Pagamento da Invoice '
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          
    
    Private aRotina:= {{"","",0,0},{"","",0,0},{"","",0,3}}
                                                                                                        
    EnChoice("ECF",nRegWork, 3, , , , aMostraECF, {15,1,(oDlg1:nClientHeight-2)/2,(oDlg1:nClientWidth-2)/2}, {} ,3)

    ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||oDlg1:End(),nOpc1:=0},{||oDlg1:End(),nOpc1:=1})

    Work->(DbGoto(nRegWork))

    IF nOpc1 == 0 .Or. nOpc1 == 1
       Exit
    Endif
EndDo
Return .T.

*------------------------------------------*
Function DataEnc()
*------------------------------------------*
LOCAL nOpca
LOCAL cDtPrev:=If(cTipo == "EFF", EasyGParam("MV_DTPREV",, dDataBase), EasyGParam("MV_DT_PREV"))
LOCAL cHoPrev:=If(cTipo == "EFF", AllTrim(EasyGParam("MV_HOPREV",, Time())), AllTrim(EasyGParam("MV_HO_PREV")))
PRIVATE nUltCont:=If(cTipo == "EFF", EasyGParam("MV_NRCONT",,1), EasyGParam("MV_NR_CONT"))
PRIVATE cDataNova:=If(cTipo == "EFF", AllTrim(EasyGParam("MV_MESPEXP",,StrZero(Month(dDataBase),2)+StrZero(Year(dDataBase),4))), EasyGParam("MV_MESPROC"))
Private cDataAnt:=cDataNova
Private dDta_Enc := ECG->ECG_DTENCE


If dDta_Enc <> CTOD('  /  /  ')
   MSGINFO(STR0042,STR0041)  //"Processo já possui data de encerramento."###"Atenção" //GFP - 23/11/2011
else
   // Criar a rotina para criar uma janela e poder realizar as devidas alterações.
   DO WHILE .T.

      nOpca:=0

      DEFINE MSDIALOG oDlg TITLE STR0031 FROM 0,0 TO 12,45 OF oMainWnd //"Incluir Data de Encerramento"

         @ 2.0,3.0 SAY  STR0032 OF oDlg // "Data de Encerramento: "
         @ 2.0,12.0 MSGET oGet Var dDta_Enc Picture "@D" SIZE /*30*/38,8 OF oDlg  //AAF 13/08/08 - Adicionada picture de data.  // GFP - 21/11/2011 - Campo cortado.
      
      ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||IF(ValDataEnc(),(nOpca:=1,oDlg:End()),)},;
                             {||nOpca:=0,oDlg:End()}) CENTERED

      If nOpca = 1
         Reclock("ECG",.F.)
         ECG->ECG_DTENCE := dDta_Enc
         ECG->(MSUNLOCK())
      EndIf
      EXIT
   ENDDO
Endif

Function ValDataEnc()
   // ** AAF 13/08/08 - A picture já garante data válida.
   /*
   cDataNova := StrZero(Month(dDta_Enc),2)+StrZero(Year(dDta_Enc),4)
   If VAL(LEFT(cDataNova,2)) < 1 .OR. VAL(LEFT(cDataNova,2)) > 12
      Help(" ",1,"AVG0005212") //E_MSG(STR0016,1)   //"O mes deve estar entre 1(janeiro) e 12(dezembro)."
      Return .F.
   EndIf
   */
   /*
   IF SUBSTR(cDataNova,3,4) + SUBSTR(cDataNova,1,2) < SUBSTR(cDataAnt,3,4) + SUBSTR(cDataAnt,1,2) 
      Help(" ",1,"AVG0005214") //E_MSG(STR0018,1) //"Mes e ano invalido."
      Return .F.
   ENDIF
   */
   
   If Empty(dDta_Enc)
      Help(" ",1,"AVG0005214") //E_MSG(STR0018,1) //"Mes e ano invalido."
      Return .F.      
   EndIf
   // **
   
   
   
   // ** AAF 13/08/08 - Validação da Data de encerramento.
   EC1->(DBSETORDER(2))   
   IF EC1->(DBSEEK(xFilial("EC1")+"IMPORT"+STRZERO(nUltCont,4,0),.T.)) .AND. EC1->EC1_STATUS <> "E" .AND. EC1->EC1_OK = "1"
      cMes := STRZERO(VAL(EC1->EC1_MES)+1,2,0)
      cAno := EC1->EC1_ANO
      IF cMes = "13"
         cMes := "01"
         cAno := STRZERO(VAL(cAno)+1,4,0)
      Endif
      dDataUlt := AVCTOD("01/"+cMes+"/"+cAno) - 1
      
      If dDta_Enc <= dDataUlt
         MSGINFO(STR0033,STR0041) // "Data de Encerramento não pode ser menor que data da ultima contabilização." //"Atenção  //GFP - 23/11/2011
         RETURN .F.
      EndIf
   Endif
   // **
Return .T.


Return                        

// ** AAF 21/11/2008
*************************************
Function AP400Est(cAlias, nReg, nOpc)
*************************************
LOCAL cPath := AllTrim(EasyGParam("MV_PATH_CO"))
LOCAL aDbF_Stru := {{"WKHAWB"    ,"C",LEN(ECF->ECF_HAWB), 0 }  , {"WKINVOICE" ,"C",LEN(ECF->ECF_INVOIC), 0 },;
                    {"WKNR_DI"   ,AVSX3("ECF_DI_NUM",2)        , AVSX3("ECF_DI_NUM",3), 0 }, {"WKDT_LANC" ,"D",08, 0 }, ;
                    {"WKCTA_DEB" ,"C",LEN(ECF->ECF_CTA_DB), 0 }, {"WKCTA_CRE" ,"C", LEN(ECF->ECF_CTA_CR), 0 },;
                    {"WKVALOR"   ,"N",15, 2 }                  , {"WKDESCR"     ,"C", LEN(ECF->ECF_DESCR), 0 }, ;
                    {"WKIDENTCT" ,"C",LEN(ECF->ECF_IDENTC), 0 }, {"WKHOUSE"   ,"C", LEN(ECF->ECF_HAWB), 0 }, ;
                    {"WKCTACREES","C",LEN(ECF->ECF_CTA_DB), 0 }, {"WKCTADEBES","C", LEN(ECF->ECF_CTA_CR), 0 } }	                    

AAdd(aDbF_Stru, {"WKFORN","C",LEN(ECF->ECF_FORN), 0 })
AAdd(aDbF_Stru, {"WKMOEDA","C",LEN(ECF->ECF_MOEDA), 0 })

Private TB_Cols:= { {{||ECF->ECF_INVOICE},"","Invoice"},; //"Invoice"
                    {{||ECF->ECF_HAWB} ,"","Nr. Po" },; //"Nr. Po"
                    {{||ECF->ECF_MOEDA}  ,"","Moeda"  },; //"Moeda"
                    {{||TRANS(ECF->ECF_VL_MOE,"@E 9,999,999,999.99")} ,"","Valor"  }} //"Valor"
PRIVATE cTit    := "Estorno de pagamentos antecipados contabilizados"
PRIVATE cHAWB   := ECG->ECG_HAWB,cIdentct := ECG->ECG_IDENTC , cForn := ECG->ECG_FORN, cMotivo := SPACE(50)
PRIVATE cMarca  := GetMark(), lInverte := .F.


IF(Right(cPath,1) != "\", cPath += "\",)


ECF->(DbSetOrder(3))//ECF_FILIAL+ECF_TPMODU+ECF_HAWB+ECF_FORN+ECF_IDENTC
 
If Select("Work") > 0
   Work->(dbCloseArea())
EndIf

cNomArq := E_CriaTrab(, aDBF_Stru, "Work")
IF ! USED()
   Help(" ",1,"E_NAOHARE")
   RETURN .F.
ENDIF

ECF->(DBSEEK(xFilial("ECF")+cHAWB+cForn))

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg2 TITLE cTit ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

   nLin  := 1.4
   nColS := 1.0
   nColG := 8.0
   @ nLin  ,nColS    SAY STR0043   //"Processo"
   @ nLin++,nColS+20 SAY STR0044  //"B.U. / Unid. Req."
   @ nLin++,nColS    SAY STR0045  //"Motivo"

   nLin  := 1.4
   @ nLin  ,nColG    MSGET cHawb    WHEN .F.  SIZE 80  ,08 OF oDlg2
   @ nLin++,nColG+20 MSGET cIdentct WHEN .F.  SIZE 65  ,08 OF oDlg2
   @ nLin++,nColG    MSGET cMotivo            SIZE 230 ,08 OF oDlg2
   oMark:=MsSelect():New( 'ECF',,,TB_Cols,@lInverte,@cMarca,{45,1,Iif(SetMDIChild(), ((oDlg2:nClientHeight-2)/2) + 40, (oDlg2:nClientHeight-2)/2),(oDlg2:nClientWidth-2)/2},"AP400Filtro()","AP400Filtro()")
   nVolta:=0
ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||(nVolta:=1,oDlg2:End())},;
                                                  {||oDlg2:End()})
If nVolta == 1
   If SimNao(STR0034,STR0029 ,,,,STR0035)=='S'  //"Confirma o Estorno?" ### "Aviso" ### "Estorno"  // GFP - 21/11/2011
      Processa({||AP400Deleta()},STR0036) //"Estornando"
      //Processa({||AP400GrvW6WB()},STR0036) //"Estornando" //FSM - 24/10/2012
      Work->(DBGOTOP())
      /* RELATÓRIO REMOVIDO
      IF Work->(EOF()) .AND. Work->(BOF())
         E_MSG("Não há movimentações a serem impressas.",1)
      ELSE
         
         If (lR4 := lR4 .And. FindFunction("TRepInUse") .And. TRepInUse() ) //TRP-01/11/2006
            //TRP - 21/08/2006 - Relatório Personalizavel - Release 4
            //ReportDef cria os objetos.
            oReport := ReportDef()
         EndIf
         Processa(If(lR4, {||oReport:PrintDialog()},{||DI210Imprime()}),"Impressao") //"Impressao"
         Work->(avzap())
      ENDIF
      */
   EndIf
EndIf
//dbSelectArea("Work")
//E_EraseArq(cNomArq)

Return .T.


***************************
Function PO400RelDef()
***************************
Local cTit:=STR0037+" "+STR0038+DTOC(dDataBase)   //"RELATÓRIO DE ESTORNO DE PROCESSOS CONTABILIZADOS" ### "Data: "
lExisteECF:=.T.

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"ECF"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("ECOAP400",cTit,"",{|oReport| ReportPrint(oReport)},STR0037)  //"RELATÓRIO DE ESTORNO DE PROCESSOS CONTABILIZADOS"

// Define o relatorio como Landscape Nick 20/10/06
oReport:opage:llandscape := .T.
oReport:opage:lportrait := .F.

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,STR0039,aTabelas,aOrdem)  //"Processos Estornados"

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,STR0040,aTabelas,aOrdem)  //"Mensagem"

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WKHAWB"        ,"Work"  ,"HAWB"              ,/*Picture*/                       ,LEN(ECF->ECF_HAWB)                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKFORN"        ,"Work"  ,"Fornecedor"              ,/*Picture*/                       ,LEN(ECF->ECF_FORN)                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKMOEDA"       ,"Work"  ,"HAWB"              ,/*Picture*/                       ,LEN(ECF->ECF_MOEDA)                         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKINVOICE"     ,"Work"  ,"INVOICE"              ,/*Picture*/                       ,LEN(ECF->ECF_INVOIC)                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKNR_DI"       ,"Work"  ,"NR. DI"              ,AVSX3("EC7_DI_NUM",06)            ,AVSX3("EC7_DI_NUM",3)                       ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDT_LANC"     ,"Work"  ,"LANCTO."              ,/*Picture*/                       ,08                                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKCTA_DEB"     ,"Work"  ,"CTA.DÉBITO"              ,/*Picture*/                       ,LEN(ECF->ECF_CTA_DB)                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKCTA_CRE"     ,"Work"  ,"CTA.CRED."              ,/*Picture*/                       ,LEN(ECF->ECF_CTA_CR)                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKVALOR"       ,"Work"  ,"VALOR"              ,"@E 9,999,999,999.99"             ,15                                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDESCR"         ,"Work"  ,"HISTÓRICO"              ,/*Picture*/                       ,LEN(ECF->ECF_DESCR)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKIDENTCT"     ,"Work"  ,"B.U./UNID.REQ."              ,/*Picture*/                       ,LEN(ECF->ECF_IDENTC)                        ,/*lPixel*/,/*{|| code-block de impressao }*/)

//Definição das colunas de impressão da seção 2
//TRCell():New(oSecao2,  "Mensagem"          ,"",       ""           ,"@!"                   ,180        ,/*lPixel*/,{"Existem pagamentos antecipados para este processo, caso necessário estornar estorná-los na Manutenção de Pagamentos Antecipados.","")})

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

***********************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

TRPosition():New(oReport:Section(STR0039),"ECF",3,{|| xFilial("ECF")+cTpModu+cHawb+cForn+cIdentct})  //"Processos Estornados"

//oSection:Print()
oReport:SetMeter (Work->(EasyRecCount()))
Work->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section(STR0039):Init()  //"Processos Estornados"

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section(STR0040):Init()  //"Mensagem"

//Para desabilitar a impressão da página de parâmetros do pergunte
//oReport:oParamPage:Disable()

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section(STR0039):PrintLine() //Impressão da linha  //"Processos Estornados"
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

oReport:Section(STR0040):PrintLine()  //"Mensagem"

//Fim da impressão da seção 1
oReport:Section(STR0039):Finish()   //"Processos Estornados"

//Fim da impressão da seção 2
oReport:Section(STR0040):Finish() //"Mensagem"

Return .T.

*--------------------*
FUNCTION AP400Deleta()
*--------------------*

BEGIN TRANSACTION
 
 ECF->(DbSetOrder(3))//ECF_FILIAL+ECF_TPMODU+ECF_HAWB+ECF_FORN+ECF_IDENTC+ECF_ORIGEM+ECF_INVOIC+ECF_SEQ+ECF_ID_CAM
 
 ProcRegua(2)
 IncProc(STR0036)  //"Estornando"
 
 cFilECF := xFilial("ECF")
 IF ECF->(DBSEEK(cFilECF+cTpModu+cHawb+cForn+cIdentct))
    GravaLog("ECF","H:"+cHAWB+cIdentct)
    DO WHILE ECF->(!EOF() .AND. ECF_FILIAL+ECF_TPMODU+ECF_HAWB+ECF_FORN+ECF_IDENTC == cFilECF+cTpModu+cHawb+cForn+cIdentct )
  
      Work->(DBAPPEND())
      Work->WKHOUSE   := cHAWB
      Work->WKIDENTCT := cIdentct
      Work->WKHAWB    := ECF->ECF_HAWB
      Work->WKINVOICE := ECF->ECF_INVOIC
      Work->WKNR_DI   := ECF->ECF_DI_NUM
      Work->WKDT_LANC := ECF->ECF_DTCONT
      Work->WKCTA_DEB := ECF->ECF_CTA_DB
      Work->WKCTA_CRE := ECF->ECF_CTA_CR
      Work->WKVALOR   := ECF->ECF_VALOR
      WorK->WKDESCR   := ECF->ECF_DESCR
      WorK->WKFORN    := ECF->ECF_FORN
      WorK->WKMOEDA   := ECF->ECF_MOEDA
      
	  //AAF 29/09/2012 - Não registrar para estorno enquanto não estiver efetivado.
	  If ECF->ECF_NR_CON # '0000' .AND. ECF->ECF_NR_CON <> '9999'
         GravaECE()
	  EndIf
	  
      Work->WKCTADEBES := ECE->ECE_CDBEST
      Work->WKCTACREES := ECE->ECE_CCREST 
      
      //AAF 29/09/2012 - Estornar o numero da contabilizacao para pagamento pré-embarque.
      If ECF->ECF_ID_CAM $ "608/609"
         AP400GrvW6WB()
      EndIf
      
      Reclock("ECF",.F.)
      ECF->(DBDELETE())
      ECF->(MsUnLock())
      ECF->(DBSKIP())
    ENDDO
 ENDIF
 
//AP400GrvW6WB()  //FSM - 24/10/2012
 
GravaLog("ECG","H:"+cHAWB+cIdentct)
Reclock("ECG",.F.)
ECG->(DBDELETE())
ECG->(MsUnLock())
IncProc()
 
END TRANSACTION

Return Nil

*---------------------*
FUNCTION AP400GrvW6WB()
*---------------------*
Local cLoja
cFilSWB:=xFilial("SWB")

If ECG->ECG_ORIGEM == "PR"
   //AAF 29/09/2012 - Estornar o numero da contabilizacao para pagamento pré-embarque.
   cLoja := If(SWB->(FieldPos("WB_LOJA"))>0,Posicione("SA2",1,xFilial("SA2")+ECF->ECF_FORN,"A2_LOJA"),"")
   
   SWB->(dbSetOrder(1))
   If SWB->(DBSEEK(cFilSWB+ECF->ECF_HAWB+"D"+ECF->ECF_INVOIC+ECF->ECF_FORN+cLoja+ECF->ECF_SEQ))
      Reclock("SWB",.F.)
      SWB->WB_CONTAB := CTOD('  /   /  ')
      SWB->(DBSKIP())      
   EndIf
Else
   IF SWB->(DBSEEK(cFilSWB+cHAWB+"A"))
      DO WHILE SWB->(!EOF() .AND. WB_HAWB == cHAWB .AND. WB_FILIAL==cFilSWB )
         Reclock("SWB",.F.)
         SWB->WB_CONTAB := CTOD('  /   /  ')
         SWB->(DBSKIP())
      ENDDO
   ENDIF      
EndIf

SWB->(MSUNLOCKALL())
IncProc()

Return .T.

*-----------------------------*
STATIC FUNCTION GravaECE()
*-----------------------------*
Local cCtaDebEst := cCtaCreEst := Space(Len(EC6->EC6_CDBEST))
Local cContaForn := REPLI("9",LEN(EC6->EC6_CDBEST))
Local lGrv603    := .F.

//AAF 29/09/2012
If !EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+ECF->ECF_LINK+ECF->ECF_IDENTC))
   EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+ECF->ECF_LINK))
EndIf

SA2->(DBSEEK(xFilial("SA2")+ECF->ECF_FORN))

RecLock('ECE',.T.)
ECE->ECE_FILIAL := xFilial("ECE")

//** AAF 22/02/08 - Gravação do ECE_TPMODU
If ECE->(FieldPos("ECE_TPMODU")) > 0
   ECE->ECE_TPMODU := 'IMPORT'
EndIf
//**

ECE->ECE_HAWB   := ECF->ECF_HAWB
ECE->ECE_INVOIC := ECF->ECF_INVOIC
ECE->ECE_DI_NUM := ECF->ECF_DI_NUM
ECE->ECE_DT_LAN := ECF->ECF_DTCONT
ECE->ECE_CTA_DB := ECF->ECF_CTA_DB
ECE->ECE_CTA_CR := ECF->ECF_CTA_CR
ECE->ECE_VALOR  := ECF->ECF_VALOR
ECE->ECE_OBS    := ECF->ECF_DESCR
ECE->ECE_IDENTC := ECF->ECF_IDENTC
ECE->ECE_HOUSE  := ECF->ECF_HAWB
ECE->ECE_ID_CAM := '999'            // Grava evento contabil de estorno 999
ECE->ECE_LINK   := ECF->ECF_LINK
ECE->ECE_NR_CON := '0000'
ECE->ECE_DT_EST	:= Date()
ECE->ECE_MOE_FO := ECF->ECF_MOEDA
ECE->ECE_FORN   := ECF->ECF_FORN 

IF ECF->ECF_LINK = '609'
   
   cFilSWB:=xFilial('SWB')
   IF SWB->(DBSEEK(cFilSWB+ECF->ECF_HAWB+ECF->ECF_INVOIC+ECF->ECF_FORN))
      DO WHILE SWB->(!EOF() .AND. WB_HAWB == ECF->ECF_HAWB .AND. WB_FILIAL == cFilSWB ) 
         IF SWB->WB_INVOICE = ECF->ECF_INVOIC
            IF SA6->(DBSEEK(xFilial('SA6')+SWB->WB_BANCO+SWB->WB_AGENCIA))						
      	  		IF !EMPTY(SA6->A6_CONTA)												   
         		   cCtaDebEst := SA6->A6_CONTA
      			   lGrv603    := .T.
      			ENDIF
      			Exit												
      		ENDIF												
      	 ENDIF																											
	  
         SWB->(DbSkip())
      ENDDO
   ENDIF						  				                
  
   IF !lGrv603
      cCtaDebEst := ECF->ECF_CTA_CR
   Endif   
				    					
Else
   IF EC6->EC6_CDBEST == cContaForn 
      cCtaDebEst := SA2->A2_CONTAB
   Elseif EMPTY(EC6->EC6_CDBEST) 
	  cCtaDebEst := ECF->ECF_CTA_CR
   Else 
	  cCtaDebEst := EC6->EC6_CDBEST
   Endif
ENDIF

IF EC6->EC6_CCREST == cContaForn
   cCtaCreEst := SA2->A2_CONTAB
Elseif EMPTY(EC6->EC6_CCREST)
   cCtaCreEst := ECF->ECF_CTA_DB
Else
   cCtaCreEst := EC6->EC6_CCREST
EndIf

ECE->ECE_CDBEST := cCtaDebEst
ECE->ECE_CCREST := cCtaCreEst
ECE->(MSUNLOCK())

RETURN .T.

Function AP400Filtro()
Return xFilial("ECF")+cTpModu+cHawb+cForn+cIdentct //FSM - 24/10/2012
