#INCLUDE "Ecodi210.ch"
#include "AVERAGE.CH"
#include "AvPrint.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ECODI210 ³ Autor ³ VICTOR IOTTI          ³ Data ³ 17.12.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao de Desembaraco / Processo                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ECODI210()

ECODI210R3(.T.)
Return .t.
*-------------------*
Function ECODI210R3(p_R4)
*-------------------*
LOCAL cAliasAnt:=ALIAS()
PRIVATE aHeader[0]//E_CriaTrab utiliza
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
Private aCampoEC4:=;
   {{{||WorkEC4->EC4_ID_CAM+'-'+Di210_DesCamp(WorkEC4->EC4_ID_CAM)}, "", STR0001    },; //"Descricao do Campo"
    {{||WorkEC4->EC4_DT_PGT}                                       , "", STR0002             },; //"Dt. Pagto"
    {{||TRANS(WorkEC4->EC4_VL_CAM,'@E 999,999,999,999.99')}        , "", STR0003        },; //"Valor do Campo"
    {{||STRZERO(VAL(WorkEC4->EC4_NR_CON),4,0)}                     , "", STR0004              },; //"Nr. Cont"
    {{||WorkEC4->EC4_COM_HI}                                       , "", STR0005},; //"Historico Complementar"
    {{||IF(WorkEC4->EC4_SIS_OR='1',STR0006,STR0007)}  , "", STR0008                }} //'Integracao'###'Contabilidade'###"Origem"

Private aCampoEC8:=;
   {{{||Trans(WorkEC8->EC8_PO_NUM,_PictPo)}                , "", STR0009 },; //"Nro. P.O."
    {{||WorkEC8->EC8_INVOIC}                               , "", STR0010   },; //"Invoice"
    {{||Trans(WorkEC8->EC8_FOB_PO,'@E 999,999,999,999.99')}, "", STR0011  } } //"Vlr P.O."
    
Private aCampoEC:={}, nFobDI

PRIVATE aRotina := MenuDef()
Private nOpca := 0, aDeleEC4:={}, aDeleEC8:={}

PRIVATE cCadastro := STR0018 //"Manuten‡„o de Processos."

PRIVATE cFilEC2:=xFilial("EC2"),cFilEC4:=xFilial("EC4"),cFilEC8:=xFilial("EC8")
PRIVATE cFilEC5:=xFilial("EC5"),cFilEC6:=xFilial("EC6"),cFilSA2:=xFilial("SA2")
PRIVATE cFilECC:=xFilial("ECC"),cFilECB:=xFilial("ECB"),cFilEC3:=xFilial('EC3')
PRIVATE cFilEC7:=xFilial('EC7'),cFilEC9:=xFilial('EC9'),cFilSWB:=xFilial('SWB')
PRIVATE cFilSW6:=xFilial('SW6'),cFilSA6:=xFilial('SA6'),cFilECF
PRIVATE cFilSYF:=xFilial('SYF')
PRIVATE cMarca := GetMark(), lInverte := .F., lAlteracao:=.F., dData_Con, lAlterEC2:=.F.
Private lGrvECE := .F., lExisteFor := .F., lExisteECF := .F.
Private lR4       := If(p_R4==NIL,.F.,p_R4)  
Private cCabec

lGrvECE := EasyGParam("MV_ESTORNO", .F., .F.)
lExisteECF := EasyGParam("MV_PAGANT", .F., .F.)
If lExisteECF
   cFilECF    := xFilial('ECF')			   
Endif                    
AAdd(aCampoEC8, {{||WorkEC8->EC8_FORN + " - " + IF(SA2->(DBSEEK(xFilial("SA2")+WorkEC8->EC8_FORN)), SA2->A2_NREDUZ, "" ) },"",STR0101} )

aStruct = EC4->(DBSTRUCT())
AADD(aStruct,{"EC4_RECNO","N",6,0})

cNomArqEC4 := E_CriaTrab(, aStruct, "WorkEC4")
IF ! USED()
   E_Msg(STR0019,20) //"N„o ha area disponivel para abertura do arquivo temporario."
   RETURN .F.
ENDIF

aStruct = EC8->(DBSTRUCT())
AADD(aStruct,{"EC8_RECNO","N",6,0})

cNomArqEC8 := E_CriaTrab(,aStruct, "WorkEC8")
IF ! USED()
   E_Msg(STR0019,20) //"N„o ha area disponivel para abertura do arquivo temporario."
   RETURN .F.
ENDIF

DbSelectArea("EC2")

mBrowse( 6, 1,22,75,"EC2")


WorkEC4->(E_EraseArq(cNomArqEC4))
WorkEC8->(E_EraseArq(cNomArqEC8))
DBSELECTAREA(cAliasAnt)
Return .T.
                            

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 01/02/07 - 14:40
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0012   ,"AxPesqui", 0 , 1},; //"Pesquisar"
                    { STR0013   ,"DI210EC2", 0 , 2},; //"Visual"
                    { STR0014   ,"DI210EC2", 0 , 3},; //"Inclui"
                    { STR0015   ,"DI210EC2", 0 , 4,20},; //"Altera"
                    { STR0016   ,"DI210EC2", 0 , 5,21},; //"Exclui"
                    { STR0017   ,"DI210Est", 0 , 6,21}} //"E&stornar"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("CDI210MNU")
	aRotAdic := ExecBlock("CDI210MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina


*----------------------------------*
Function DI210EC2(cAlias,nReg,nOpc)
*----------------------------------*
LOCAL bVal_Ok,lBloqueia:=.F.,nMeio, i
Private cMoeda, l_Nao_Alterar:=.F., cAliasWork
Private cFornRed := ''
PRIVATE aTela[0][0],aGets[0],nUsado:=0
PRIVATE oEnCh //LRL 02/06/04
Private aButtons := {}   // GFP - 18/11/2011 - Alteração para EnchoiceBar

EC2->(DBSETORDER(1))
EC4->(DBSETORDER(1))
EC5->(DBSETORDER(1))
EC8->(DBSETORDER(1))

lAlterEC2:=.F.
IF nOpc = 2                 // Visual
   bVal_OK:={||oDlg:End()}
ELSEIF STR(nOpc,1)$'3,4'    // Inclui,Altera
   bVal_OK:={||nOpca:=1,If(DI210VAL('EC2').AND.Di210_TxDi(),oDlg:End(),nOpca := 0)}
   IF nOpc=4
      lAlterEC2:=.T.
   EndIf
ELSEIF nOpc = 5             // Deleta
   bVal_OK:={||nOpca:=1,If(cAliasWork='WorkEC8',.T.,Processa({||DI210DEL(),STR0020})),oDlg:End()} //"Deletando Registros."
ENDIF

bCampo   := { |nCPO| Field(nCPO) }

M->EC2_RECNO:=0
nFobDI:=0
FOR i := 1 TO EC2->(FCount())
    IF nOpc=3
       M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
    ELSE
       M->&(EVAL(bCampo,i)) := FieldGet(i)
    ENDIF
NEXT i
cMoeda := SPACE(03)
If nOpc#3
   nFobDI:=M->EC2_FOB_DI
   M->EC2_RECNO:=EC2->(RECNO())
   Di210_Moeda(.F.)
   M->AUX_TX_DI := M->EC2_TX_DI

   IF EC4->(DBSEEK(xFilial("EC4")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC+'201'))
      IF VAL(EC4->EC4_NR_CON)=0
         l_Nao_Alterar := .F.
      ELSE
         l_Nao_Alterar := .T.
      ENDIF
   ELSE
      M_Nao_Alterar := .F.
   ENDIF

   IF EMPTY(M->EC2_TX_DI)
      M->EC2_TX_DI:=Di210_TxDi(' ')
   ENDIF
Else
   M->EC2_SIS_OR:='2'
   M->EC2_FIM_CT:='2'  // Em Aberto
   //cMoeda := M->EC2_MOEDA := SPACE(3)
   M->AUX_TX_DI := 0
EndIf

WorkEC4->(avzap())
WorkEC8->(avzap())
lBloqueia:=.F.

IF M->EC2_RECNO # 0
   EC4->(DBSEEK(xFilial("EC4")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC))
   cFilEC4:= xFilial("EC4")
   DO WHILE ! EC4->(EOF()) .AND. (EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTCT)=(EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTCT) .AND. cFilEC4=EC4->EC4_FILIAL

      WorkEC4->(DBAPPEND())
      For i := 1 TO EC4->(FCount())
          If WorkEC4->(FIELDPOS(FIELDNAME(i))) # 0
             WorkEC4->(FieldPut(i,EC4->&(FIELDNAME(i))))
          EndIf
      Next
      WorkEC4->EC4_RECNO := EC4->(RECNO())

      IF VAL(EC4->EC4_NR_CON) # 0
         lBloqueia:=.T.
      ENDIF

      EC4->(DBSKIP())
   ENDDO

   EC8->(DBSEEK(xFilial("EC8")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC))                                                                                        
   cFilEC8 := xFilial("EC8") //LRL 09/12/04 - Conceito MultiFilial
   DO WHILE ! EC8->(EOF()) .AND. (EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTCT)=(EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTCT) .AND. cFilEC8=EC8->EC8_FILIAL

      WorkEC8->(DBAPPEND())
      For i := 1 TO EC8->(FCount())
          If WorkEC8->(FIELDPOS(FIELDNAME(i))) # 0
             WorkEC8->(FieldPut(i,EC8->&(FIELDNAME(i))))
          EndIf
      Next
      WorkEC8->EC8_RECNO := EC8->(RECNO())
      EC8->(DBSKIP())
   ENDDO
ENDIF

cAliasWork:='WorkEC4'
aCampoEC  := aClone(aCampoEC4)

If lBloqueia .AND. nOpc = 5
   E_Msg(STR0021,1) //'Registro j  contabilizado, n„o pode ser excluido.'
   DBSELECTAREA("EC2")
   Return Nil
EndIf

// GFP - 18/11/2011 - Alteração para EnchoiceBar
If nOpc == 2 .OR. nOpc == 5
   aAdd(aButtons,{"BMPVISUAL",{||(nOpca:=2,oDlg:End())},STR0042})  //Visualizar Item
Else
   aAdd(aButtons,{"BMPINCLUIR",{||DI210VALPO()},STR0043})  //Inclusao
   aAdd(aButtons,{"EDIT",{||(nOpca:=5,oDlg:End())},STR0044})  //Exclusao
   aAdd(aButtons,{"IC_17",{||(nOpca:=4,oDlg:End())},STR0045})  //Alteracao
EndIf

If cAliasWork == 'WorkEC4'  // Botao do P.O.
   aAdd(aButtons,{"MENURUN",{||If(Di210_TxDi(),(nOpca:=7,oDlg:End()),)},STR0046})  //P.O.
EndIf
// Fim - GFP

Do While .T.
   nOpca := 0

   (cAliasWork)->(DBGOTOP())
   If cAliasWork='WorkEC8'
      IF EC5->(DBSEEK(xFilial("EC5")+WorkEC8->EC8_FORN+WorkEC8->EC8_INVOIC))
         M->EC2_FORN := EC5->EC5_FORN
      ENDIF
   ENDIF
	
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE cCadastro ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

      nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )

      oEnCh:=MsMGet():New( 'EC2', nReg, nOpc,,,,, {15,1,nMeio-1 , (oDlg:nClientWidth-2)/2}, , 3 )
      
      aPos := PosDlg(oDlg)
      oObj:= MsSelect():New(cAliasWork,,,aCampoEC,@lInverte,@cMarca,{nMeio,aPos[2],aPos[3],aPos[4]},,,oDlg)   
//   oObj:=MsSelect():New(cAliasWork,,,aCampoEC,@lInverte,@cMarca,{nMeio,1,iif(SetMDIChild(), ((oDlg:nClientHeight-2)/2) + 40,(oDlg:nClientHeight-2)/2),(oDlg:nClientWidth-2)/2})
      oObj:bAval:={||(IF(nOpc=3,nOpca:=4,nOpca:=2),oDlg:End())}
      oObj:oBrowse:bwhen:={||(dbSelectArea(cAliasWork),.t.)}

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bVal_OK,{||oDlg:End()},,aButtons) CENTERED
// ACTIVATE MSDIALOG oDlg ON INIT (DI210BAR(nOpc,oDlg,bVal_OK,{||oDlg:End()}),;
//                                 oEnCh:oBox:Align:=CONTROL_ALIGN_TOP,;    // LRL
//                              oObj:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT)// 02/06/04
// SETKEY(1,{||.T.})
// SETKEY(5,{||.T.})
// SETKEY(16,{||.T.})
// SETKEY(22,{||.T.})

   M->EC2_FOB_DI:=nFobDI
   If nOpca == 0
      If cAliasWork = 'WorkEC8'
         nOpca := 6
      Else
         EXIT
      EndIf
   EndIf

   If nOpca == 1
      If cAliasWork = 'WorkEC8'
         nOpca := 6
      Else
         If nOpc#5
            //IF ! (WorkEC8->(EOF()) .AND. WorkEC8->(BOF()))
               Processa({||DI210Grava()},STR0022) //"Gravando Arquivo."
            //If lAlterEC2 //.AND. (WorkEC8->(EOF()) .AND. WorkEC8->(BOF()))
            //   Processa({||DI210DEL(),STR0020}) //"Deletando Registros."
            //ELSEIF  WorkEC8->(EOF()) .AND. WorkEC8->(BOF())
            //   MSGINFO(STR0023,STR0024) //"Não foram incluidos Pedidos"###"Informação"
            //EndIf
         EndIf
         EXIT
      EndIf
   Elseif STR(nOpca,1)$'2,3,4,5'
      DI210EC(nOpca)
   EndIf

   If nOpca == 6
      cAliasWork:='WorkEC4'
      aCampoEC  := aClone(aCampoEC4)
   ElseIf nOpca == 7
      cAliasWork:='WorkEC8'
      aCampoEC  := aClone(aCampoEC8)
   ENDIF
   M->EC2_FOB_DI:=nFobDI
EndDo
DBSELECTAREA("EC2")
RETURN Nil

*-----------------------*
PROCEDURE DI210EC(nTipo)
*-----------------------*
LOCAL oDlg1, dCONT1, nCont:=0,i, oEnch

PRIVATE aTela[0][0],aGets[0],nUsado:=0, nRegWork:=(cAliasWork)->(RECNO()), cAliasEc:=''

DBSELECTAREA(cAliasWork)

IF STR(nTipo,1) $ "2,4,5"
   IF (cAliasWork)->(EOF()) .AND. (cAliasWork)->(BOF())
      MSGSTOP(STR0025+If(nTipo=2,STR0026,If(ntipo=4,STR0027,STR0028+".")),STR0029) //"N„o exixtem registros a serem "###"visualizados"###"alterados"###"excluidos"###"Aviso"
      Return .F.
   ENDIF
ENDIF

If nTipo = 3
   (cAliasWork)->(DBGOBOTTOM())
   nRegWork:=(cAliasWork)->(RECNO())+1
   (cAliasWork)->(DBSKIP())
EndIf

FOR i := 1 TO (cAliasWork)->(FCount())
    M->&(FIELDNAME(i)) := (cAliasWork)->(FIELDGET(i))
NEXT i

If nTipo = 3
   lAlteracao:=.F.
   If cAliasWork='WorkEC4'
      M->EC4_HAWB   := M->EC2_HAWB
      M->EC4_IDENTC := M->EC2_IDENTC
      M->EC4_SIS_OR := '2'
      M->EC4_NR_CON := '0000'
	  M->EC4_MOEDA  := M->EC2_MOEDA
  	  M->EC4_FORN   := M->EC2_FORN
   Else
      M->EC8_HAWB   := M->EC2_HAWB
      M->EC8_IDENTC := M->EC2_IDENTC
      M->EC8_FOB_PO := 0
      M->EC8_MOEDA  := M->EC8_MOEDA
      M->EC8_FORN   := M->EC8_FORN
   EndIf

ElseIf STR(nTipo,1) $ '45'
   If nTipo = 4
      lAlteracao:=.T.
   Else
      lAlteracao:=.F.
   EndIf

   If cAliasWork='WorkEC4'
      IF VAL(WorkEC4->EC4_NR_CON) # 0
         E_Msg(STR0030+If(nTipo=4,STR0031,STR0032)+'.',1) //'Registro j  contabilizado, n„o pode ser '###'alterado'###'excluido'
         Return .F.
      ENDIF

      IF WorkEC4->EC4_ID_CAMP = '201'
         Help(" ",1,"AVG0005307") //E_Msg(STR0033,1) //'Registro do c¢digo 201 n„o pode ser alterado.'
         Return .F.
      ENDIF
      EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+M->EC4_ID_CAM))
      M->EC4_CAM_DE := EC6->EC6_DESC
   ELSE
      If nTipo = 5
         nCont:=0
         WorkEC8->(DBGOTOP())
         WorkEC8->(DBEVAL({||nCont++},,,,,.T.))
         WorkEC8->(DBGOTO(nRegWork))
         IF nCont = 1
            WorkEC4->(DBGOTOP())
            M_Dele = .T.
            WorkEC4->(DBEVAL({||If(VAL(EC4_NR_CONT)#0,M_Dele:=.F.,)},,,,,.T.))
            IF ! M_Dele
               E_Msg(STR0034,1) //'Deve haver pelo menos um registro de PO para este processo.'
               RETURN .F.
            EndIF
         ENDIF
      EndIf
   ENDIF
EndIf

If cAliasWork='WorkEC4'
   cAliasEc:='EC4'
Else
   cAliasEc:='EC8'
   EC5->(DBSEEK(xFilial("EC5")+M->EC8_FORN+M->EC8_INVOIC+M->EC8_IDENTC))
   IF SA2->(DBSEEK(xFilial("SA2")+EC5->EC5_FORN))
      cFornRed := M->EC8_FORNDE := SA2->A2_NREDUZ
   ELSE
      cFornRed := M->EC8_FORNDE := SPACE(20)
   ENDIF
EndIf

WHILE .T.
    nOpc1 := 0
   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg1 TITLE STR0035+If(cAliasWork='WorkEC4',STR0036,STR0037) ; //'Altera‡„o de Detalhes - '###'Despesas'###'P.O.'
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

    oEnCh:=MsMGET():New(RIGHT(cAliasWork,3),nRegWork,3,,,,,{15,1,(oDlg1:nClientHeight-2)/2,(oDlg1:nClientWidth-2)/2},If(Str(nTipo,1)$'2,5',{},),3)
	oEnch:oBox:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

    ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1,{||nOpc1:=1,IF(DI210VALEC(nTipo,nRegWork,cAliasEc),oDlg1:End(),nOpc1:=0)},{||oDlg1:End()})) //LRL 02/06/04 //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

    IF nOpc1 == 0
       EXIT
    ENDIF

    If nTipo = 3
       (cAliasWork)->(DBAPPEND())
    ELSE
       (cAliasWork)->(DBGOTO(nRegWork))
    EndIf

    If ! (STR(nTipo,1,0)$'25')
       If cAliasWork='WorkEC8'
          nFobDI := nFobDI - WorkEC8->EC8_FOB_PO + M->EC8_FOB_PO
          Di210_Moeda(.T.)
       EndIf
       For i := 1 TO (cAliasWork)->(FCount())
           (cAliasWork)->(FieldPut(i,M->&(FIELDNAME(i))))
       Next
    EndIf
    EXIT
EndDo
Return .T.

*-------------------------------------------*
FUNCTION DI210VALEC(nTipo,nRegWork,cAliasEc)
*-------------------------------------------*
LOCAL lRet:=.T.
IF nTipo # 5
   IF nTipo # 2
      lRet:=Obrigatorio(aGets,aTela)
      IF lRet
         lRet:=DI210Val(cAliasEc)
      ENDIF
   ENDIF
ELSE
   (cAliasWork)->(DBGOTO(nRegWork))
   IF SimNao(STR0038,,,,,STR0039) = "S" //'Confirma `a Exclusao ? '###'Excluir'
      IF cAliasWork='WorkEC4' .AND. WorkEC4->EC4_RECNO # 0
         AADD(aDeleEC4,WorkEC4->EC4_RECNO)
      ELSEIF cAliasWork='WorkEC8' .AND. WorkEC8->EC8_RECNO # 0
         AADD(aDeleEC8,WorkEC8->EC8_RECNO)
         nFobDI -= WorkEC8->EC8_FOB_PO
      ENDIF
      (cAliasWork)->(DBDELETE())
   ENDIF
ENDIF
RETURN lRet

*--------------------------*
FUNCTION Di210_Moeda(lFlag)
*--------------------------*
//cMoeda := M->EC2_MOEDA := SPACE(03)
IF ! lFlag
   IF EC8->(DBSEEK(xFilial("EC8")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC))
      IF EC5->(DBSEEK(xFilial("EC5")+EC8->EC8_FORN+EC8->EC8_INVOIC))
         cMoeda := M->EC2_MOEDA := EC5->EC5_MOE_FO
      ENDIF
   ENDIF
ELSE
   IF EC5->(DBSEEK(xFilial("EC5")+M->EC8_FORN+M->EC8_INVOIC))
      cMoeda := M->EC2_MOEDA := EC5->EC5_MOE_FO
   ENDIF
ENDIF

RETURN NIL

*-------------------*
FUNCTION Di210_TxDi
*-------------------*
LOCAL n_Valor

IF PCOUNT() > 0
   n_Valor := M->EC2_TX_DI

   IF EMPTY(M->EC2_TX_DI) .AND. ! EMPTY(M->EC2_DT)
      IF EC8->(DBSEEK(xFilial("EC8")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC))
         IF EC5->(DBSEEK(xFilial("EC5")+EC8->EC8_FORN+EC8->EC8_INVOIC))
            cMoeda := M->EC2_MOEDA := EC5->EC5_MOE_FO
            n_Valor:=ECOBuscaTaxa(EC5->EC5_MOE_FO, M->EC2_DT)
         ENDIF
      Else
         IF EC5->(DBSEEK(xFilial("EC5")+WorkEC8->EC8_FORN+WorkEC8->EC8_INVOIC))
            cMoeda := M->EC2_MOEDA := EC5->EC5_MOE_FO
            n_Valor:=ECOBuscaTaxa(EC5->EC5_MOE_FO, M->EC2_DT)
         EndIf
      ENDIF
   ENDIF
   RETURN n_Valor

ELSE
   IF EMPTY(M->EC2_TX_DI) .AND. ! EMPTY(M->EC2_DI_NUM) .AND. ! (WorkEC8->(EOF()) .AND. WorkEC8->(BOF()))
      Help(" ",1,"AVG0005308") //E_Msg(STR0049,1) //'Taxa da D.I. n„o preenchida.'
      RETURN .F.
   ENDIF
   IF M->AUX_TX_DI # M->EC2_TX_DI .AND. ! EMPTY(M->EC2_TX_DI)
      W_W_Recno:=WorkEC4->(RECNO())
      WorkEC4->(DBGOTOP())
      l_Achou := .F.
      DO WHILE ! WorkEC4->(EOF())

         IF WorkEC4->EC4_ID_CAM = '201'
            WorkEC4->EC4_DT_PGT := M->EC2_DT
            WorkEC4->EC4_VL_CAM := M->EC2_TX_DI * nFobDi
            l_Achou := .T.
            EXIT
         ENDIF
         WorkEC4->(DBSKIP())
      ENDDO

      IF ! l_Achou
         WorkEC4->(DBAPPEND())
         WorkEC4->EC4_DT_PGT := M->EC2_DT
         WorkEC4->EC4_VL_CAM := M->EC2_TX_DI * nFobDI
         WorkEC4->EC4_ID_CAMP:= '201'
         WorkEC4->EC4_SIS_ORI:= '2'
//       WorkEC4->EC4_RECNO  := WorkEC4->EC4_RECNO
         WorkEC4->EC4_HAWB   := M->EC2_HAWB
         WorkEC4->EC4_IDENTC := M->EC2_IDENTC
         WorkEC4->EC4_FORN   := M->EC2_FORN
         WorkEC4->EC4_MOEDA  := M->EC2_MOEDA         

      ENDIF
      WorkEC4->(DBGOTO(W_W_Recno))
      M->AUX_TX_DI := M->EC2_TX_DI
      oObj:oBrowse:Refresh()
   ENDIF

   RETURN .T.

ENDIF

*-------------------------*
Function DI210_WHEN(cTipo)
*-------------------------*
LOCAL cCampo:=Upper(READVAR())
Do Case
   Case cTipo = 'DI'
        Return ! l_Nao_Alterar
   Case cTipo = 'DTDI' 
        If Empty(M->EC2_DI_NUM)
           IF cCampo == "M->EC2_DT"
              Help(" ",1,"AVG0005309") //E_Msg(STR0050,1) //'N£mero da DI deve ser preenchido.'
           ENDIF   
           RETURN .F.
        EndIf
        Return ! l_Nao_Alterar

   Case cTipo = 'TXDI'
        If Empty(M->EC2_DI_NUM)
           IF cCampo == "M->EC2_TX_DI"
              Help(" ",1,"AVG0005309") //E_Msg(STR0050,1) //'N£mero da DI deve ser preenchido.'
           ENDIF   
           RETURN .F.
        EndIf
        If ! (WorkEC8->(EOF()) .AND. WorkEC8->(BOF())) .AND. ! l_Nao_Alterar
           M->EC2_TX_DI:=Di210_TxDi(' ')
           Return .T.
        EndIf
        Return (M->EC2_RECNO#0 .AND. ! l_Nao_Alterar)

   Case cTipo = 'NFCOM'
        If EMPTY(M->EC2_NF_ENT)
           IF cCampo == "M->EC2_NF_COM"
              Help(" ",1,"AVG0005310") //E_Msg(STR0051,1) //'Nota fiscal complementar n„o pode ser preenchida(NF entrega em branco).'
           ENDIF   
           RETURN .F.
        EndIf
EndCase

Return .T.

*-----------------------*
Function DI210Val(cTipo)
*-----------------------*
LOCAL nRecNo

If cTipo = 'DI' .OR. cTipo = 'EC2'
   
   /*********************************************************************************************/
   // AAF - 26/07/04 - INICIO - Valida se o Envento Contabil 201 existe para a Unidade Requesitante atual.
   if cTipo == 'EC2'            
      WorkEC4->(DBGOTOP())
      WorkEC8->(DBGOTOP())
      DO WHILE ! WorkEC4->(EOF())
         IF WorkEC4->EC4_ID_CAM == '201' .AND. !EC6->(DbSeek(xFilial("EC6")+"IMPORT"+"201"+M->EC2_IDENTC))
            MsgStop(STR0110+M->EC2_IDENTC) //"Evento contabil não cadastrado para Unidade Requesitante "
            Return .F.
         endif
         IF WorkEC4->EC4_IDENTC <> M->EC2_IDENTC
            IF EC6->( DbSeek(xFilial("EC6")+"IMPORT"+WorkEC4->EC4_ID_CAM+WorkEC4->EC4_IDENTC) )
               MsgStop(STR0112+EC6->EC6_DESC)//"Unidade Requesitante da despesa difere da capa. Despesa: "
            Endif
            Return .F.
         endif
         IF WorkEC4->EC4_FORN <> M->EC2_FORN
            IF EC6->( DbSeek(xFilial("EC6")+"IMPORT"+WorkEC4->EC4_ID_CAM+WorkEC4->EC4_IDENTC) )
               MsgStop(STR0113+EC6->EC6_DESC)//"Fornecedor da despesa difere da capa. Despesa: "
            Endif
            Return .F.
         endif                  
         IF WorkEC4->EC4_MOEDA <> M->EC2_MOEDA
            IF EC6->( DbSeek(xFilial("EC6")+"IMPORT"+WorkEC4->EC4_ID_CAM+WorkEC4->EC4_IDENTC) )
               MsgStop(STR0114+EC6->EC6_DESC)//"Moeda da despesa difere da capa. Despesa: "
            Endif
            Return .F.
         endif         
         IF WorkEC4->EC4_HAWB <> M->EC2_HAWB
            WorkEC4->EC4_HAWB := M->EC2_HAWB
         endif
         WorkEC4->( dbskip() )
      enddo          
   endif
   DO WHILE ! WorkEC8->(EOF())   
         IF WorkEC8->EC8_IDENTC <> M->EC2_IDENTC
               MsgStop(STR0115+EC8_PO_NUM)//"Unidade Requesitante do P.O. difere da capa. P.O.: "
            Return .F.
         endif
         IF WorkEC8->EC8_FORN <> M->EC2_FORN
            IF EC6->( DbSeek(xFilial("EC6")+"IMPORT"+"201"+WorkEC8->EC8_IDENTC) )
               MsgStop(STR0116+EC8_PO_NUM)//"Fornecedor do P.O. difere da capa. P.O.: "
            Endif
            Return .F.
         endif                  
         IF WorkEC8->EC8_MOEDA <> M->EC2_MOEDA
            IF EC6->( DbSeek(xFilial("EC6")+"IMPORT"+"201"+WorkEC8->EC8_IDENTC) )
               MsgStop(STR0117+EC8_PO_NUM)//"Moeda do P.O. difere da capa. P.O.: "
            Endif
            Return .F.
         endif         
         IF WorkEC8->EC8_HAWB <> M->EC2_HAWB
            WorkEC8->EC8_HAWB := M->EC2_HAWB
         endif   
         WorkEC8->( Dbskip() )
   enddo
   /*AAF - 27/07/04 - FIM ***********************************************************************/
   
   IF Empty(M->EC2_DI_NUM)
      M->EC2_DT    := AVCTOD(SPACE(08))
      M->EC2_TX_DI := 0
      W_W_Recno := WorkEC4->(RECNO())
      WorkEC4->(DBGOTOP())
      DO WHILE ! WorkEC4->(EOF())

         IF WorkEC4->EC4_ID_CAM = '201'
            WorkEC4->(DBDELETE())
            WorkEC4->(DBGOTOP())
            lRefresh:=.t.

            oObj:oBrowse:Refresh()
            EXIT
         ENDIF
         WorkEC4->(DBSKIP())
      ENDDO
      WorkEC4->(DBGOTO(W_W_Recno))
      Return .T.
   ENDIF
   
   EC2->(DBSETORDER(2))
   EC2->(DBSEEK(xFilial("EC2")+TRANS(M->EC2_DI_NUM,"@!")))
   EC2->(DBSETORDER(1))
   IF ! EC2->(EOF())
      IF M->EC2_RECNO=0 .OR. (M->EC2_RECNO#0 .AND. EC2->(RECNO())#M->EC2_RECNO .AND. EC2->EC2_HAWB#M->EC2_HAWB)
         E_Msg(STR0052,1) //'DI j  cadastrada para outro processo.'
      ELSEIF M->EC2_RECNO#0 .AND. EC2->(RECNO())=M->EC2_RECNO .AND. EC2->EC2_HAWB#M->EC2_HAWB
         EC2->(DBSKIP())
         IF ! EC2->(EOF()) .AND. EC2->EC2_DI_NUM = M->EC2_DI_NUM
            E_Msg(STR0052,1) //'DI j  cadastrada para outro processo.'
         ENDIF
      ENDIF
   ENDIF  
EndIf

If cTipo = 'DT_DI' .OR. cTipo = 'EC2'
   IF EMPTY(M->EC2_DT) .AND. ! EMPTY(M->EC2_DI_NUM)
      Help(" ",1,"AVG0005311") //E_Msg(STR0053,1) //'Data da DI n„o preenchida.'
      RETURN .F.
   ENDIF
EndIf

If cTipo = 'PROCESSO' .OR. cTipo = 'EC2'
   If ! EMPTY(M->EC2_HAWB)              // .AND. ! EMPTY(M->EC2_IDENTC)
      If EC2->(DBSEEK(xFilial("EC2")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC)) .AND. EC2->(RECNO())#M->EC2_RECNO
         Help(" ",1,"AVG0005312") //E_Msg(STR0054,1) //'Processo j  cadastrado.'
         Return .F.
      EndIf
   EndIf
EndIf

If cTipo = 'CC' .OR. cTipo = 'EC2'
   IF ! ECC->(DBSEEK(xFilial("ECC")+M->EC2_IDENTC))
      Help(" ",1,"AVG0005303")  //E_Msg(STR0055,1) //"B.U. / Unid.Req. n„o cadastrado."
      RETURN .F.
   ENDIF

   If ! EMPTY(M->EC2_HAWB)             // .AND. ! EMPTY(M->EC2_IDENTC)
      If EC2->(DBSEEK(xFilial("EC2")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC)) .AND. EC2->(RECNO())#M->EC2_RECNO
         Help(" ",1,"AVG0005312") //E_Msg(STR0054,1) //'Processo j  cadastrado.'
         Return .F.
      EndIf
   EndIf
ENDIF

If cTipo = 'FOR' 
   IF ! SA2->(DBSEEK(xFilial("SA2")+M->EC2_FORN))
      Help(" ",1,"AVG0005302") //E_Msg(STR0102,1) //"Fornecedor nao cadastrado
      RETURN .F.
   ENDIF
   If ! EMPTY(M->EC2_HAWB)             // .AND. ! EMPTY(M->EC2_IDENTC)
      If EC2->(DBSEEK(xFilial("EC2")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC)) .AND. EC2->(RECNO())#M->EC2_RECNO
         Help(" ",1,"AVG0005312") //E_Msg(STR0054,1) //'Processo j  cadastrado.'
         Return .F.
      EndIf
   EndIf
ENDIF

If cTipo = 'MOEDA' 
   IF ! SYF->(DBSEEK(xFilial('SYF')+M->EC2_MOEDA))
      Help(" ",1,"AVG0005313") //E_Msg(STR0104,1) //"Moeda não cadastrada"
      RETURN .F.
   ENDIF
   If ! EMPTY(M->EC2_HAWB)             // .AND. ! EMPTY(M->EC2_IDENTC)
      If EC2->(DBSEEK(xFilial("EC2")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC)) .AND. EC2->(RECNO())#M->EC2_RECNO
         Help(" ",1,"AVG0005312") //E_Msg(STR0054,1) //'Processo j  cadastrado.'
         Return .F.
      EndIf
   EndIf
ENDIF

IF cTipo = 'ID_CAMP' .OR. cTipo = 'EC4'

   IF M->EC4_ID_CAM = '201'
      E_Msg(STR0056,1) //'Campo 201 n„o pode ser incluido.'
      RETURN .F.
   ENDIF

   IF M->EC4_ID_CAM = '4' .AND. EMPTY(M->EC2_NF_ENT)
      E_Msg(STR0057,1) //'C¢digo 4xx n„o pode ser incluido sem n£mero de N.F. de entrada.'
      RETURN .F.
   ENDIF

   IF ! EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+M->EC4_ID_CAM))
      E_Msg(STR0058,1) //'Campo n„o cadastrado no arquivo de link.'
      RETURN .F.
   ENDIF
   
   M->EC4_CAM_DE := EC6->EC6_DESC

   IF LEFT(M->EC4_ID_CAM,1) = '2'
      IF ! EMPTY(M->EC2_DI_NUM) .AND. ! EMPTY(M->EC2_DT) .AND. cTipo # 'EC4'
         M->EC4_DT_PGT := M->EC2_DT
      ENDIF
   ENDIF

   IF LEFT(M->EC4_ID_CAM,1) = '4'
      IF ! EMPTY(M->EC2_TX_DI) .AND. cTipo # 'EC4'
         M->EC4_DT_PGT := M->EC2_DT
         M->EC4_VL_CAM := VAL(STR(nFobDI*M->EC2_TX_DI,15,2))
      ENDIF
   ENDIF
   *IF SUBST( TId_Camp,1,1 ) = '1'
   *   @ L1+05, C1+2  SAY "Data da DI.........:"
   *IF SUBST( TId_Camp,1,1 ) = '2'
   *   @ L1+05, C1+2  SAY "Data da Provisao...:"
   *IF SUBST( TId_Camp,1,1 ) = '3'
   *   @ L1+05, C1+2  SAY "Data do Pagamento..:"
   *IF SUBST( TId_Camp,1,1 ) = '4'
   *   @ L1+05, C1+2  SAY "Data da N.F........:"
EndIf

If cTipo = 'DT_PGTO' .OR. cTipo = 'EC4'
   IF M->EC4_DT_PGT < M->EC2_DT
      Help(" ",1,"AVG0005314") //E_Msg(STR0059,1) //'A data de pagto n„o pode ser menor que a data da D.I.'
   ENDIF
EndIf

If cTipo = 'INVOICE' .OR. cTipo = 'EC8'
   If ! EMPTY(ALLTRIM(M->EC8_INVOIC)) .AND. If(EMPTY(ALLTRIM(M->EC8_FORN)),.F.,.T.) .AND. ! EMPTY(ALLTRIM(M->EC2_IDENTC))
      IF ! EC5->(DBSEEK(xFilial("EC5")+M->EC8_FORN+M->EC8_INVOIC+M->EC2_IDENTC))
         Help(" ",1,"AVG0005315") //E_Msg(STR0060,1) //'Invoice n„o cadastrada.'
         RETURN .F.
      ENDIF
   Endif
   
   IF EC5->EC5_MOE_FO # cMOEDA .AND. ! EMPTY(cMoeda) .And. If(EMPTY(ALLTRIM(M->EC8_FORN)),.F.,.T.)
      Help(" ",1,"AVG0005316") //E_Msg(STR0061,1) //'Esta Invoice ‚ de uma moeda diferente.'
      RETURN .F.
   ENDIF

   IF EC5->EC5_FORN # M->EC2_FORN .AND. ! EMPTY(M->EC2_FORN) //.And. !lExisteFor
      Help(" ",1,"AVG0005317") //E_Msg(STR0062,1) //'Esta Invoice ‚ de um fornecedor diferente.'
      RETURN .F.
   ENDIF

   EC8->(DBSETORDER(2))
   If EC8->(DBSEEK(xFilial("EC8")+M->EC8_FORN+M->EC8_INVOIC+M->EC2_IDENTC)) .AND. EC8->EC8_HAWB#M->EC2_HAWB
      Help(" ",1,"AVG0005318",,EC8->EC8_HAWB,2,01) //E_Msg(STR0063+EC8->EC8_HAWB,1) //'Esta Invoice j  pertence ao processo - '
      EC8->(DBSETORDER(1))
      Return .F.
   EndIf
   EC8->(DBSETORDER(1))

   nRecNo:=WorkEC8->(RECNO())
   WorkEC8->(DBGOTOP())
   Do while ! WorkEC8->(EOF())

      If M->EC8_INVOIC == WorkEC8->EC8_INVOIC .And. M->EC8_FORN == WorkEC8->EC8_FORN
         Help(" ",1,"AVG0005319") //E_Msg(STR0064,1) //'Esta Invoice j  foi incluida neste processo.'
         WorkEC8->(DBGOTO(nRecNo))
         Return .F.
      EndIf
      WorkEC8->(DBSKIP())
   EndDo
   WorkEC8->(DBGOTO(nRecNo))

   If cTipo # 'EC8'
      M->EC8_FOB_PO := EC5->EC5_FOB_TO
   EndIf

   IF SA2->(DBSEEK(xFilial("SA2")+EC5->EC5_FORN))
      M->EC8_FORNDE := SA2->A2_NREDUZ
      M->EC8_FORN   := EC5->EC5_FORN
   ELSE
      M->EC8_FORNDE := SPACE(20)
   ENDIF
EndIf

If cTipo = "ESTORNO"
   If EMPTY(cMotivo)
      Help(" ",1,"AVG0005320") //E_Msg(STR0065,1) //"O motivo deve ser preenchido."
      RETURN .F.
   EndIf
EndIf

If cTipo = 'FORNEC'                            

   IF SA2->(DBSEEK(xFilial("SA2")+M->EC8_FORN))
      M->EC8_FORNDE := cFornRed := SA2->A2_NREDUZ
   ELSE         
      M->EC8_FORNDE := cFornRed := SPACE(20)
      Help(" ",1,"AVG0005302") //E_Msg(STR0102,1) //'Fornecedor nao Cadastrado.'
      RETURN .F.
   ENDIF
   If ! EMPTY(ALLTRIM(M->EC8_INVOIC)) .AND. If(EMPTY(ALLTRIM(M->EC8_FORN)),.F.,.T.) .AND. ! EMPTY(ALLTRIM(M->EC2_IDENTC))
      IF ! EC5->(DBSEEK(xFilial("EC5")+M->EC8_FORN+M->EC8_INVOIC+M->EC2_IDENTC))
         Help(" ",1,"AVG0005315") //E_Msg(STR0060,1) //'Invoice n„o cadastrada.'
         RETURN .F.
      ENDIF
   Endif
Endif

If cTipo = 'MOEINV'                            
   IF !SYF->(DBSEEK(xFilial('SYF')+M->EC8_MOEDA))
      Help(" ",1,"AVG0005313") //E_Msg(STR0104,1) //'Moeda nao Cadastrada.'
      RETURN .F.
   ENDIF
   If ! EMPTY(ALLTRIM(M->EC8_INVOIC)) .AND. If(EMPTY(ALLTRIM(M->EC8_FORN)),.F.,.T.) .AND. ! EMPTY(ALLTRIM(M->EC2_IDENTC))
      IF ! EC5->(DBSEEK(xFilial("EC5")+M->EC8_FORN+M->EC8_INVOIC+M->EC2_IDENTC))
         Help(" ",1,"AVG0005313") //E_Msg(STR0104,1) //'Moeda n„o cadastrada.'
         RETURN .F.
      ENDIF
   Endif
Endif


lRefresh:=.t.

Return .T.
*---------------------------*
Static Function DI210Grava()
*---------------------------*
Local i, nI
Begin Transaction
ProcRegua(EC2->(FCount())+1)
IncProc(STR0066) //"Gravando Processos..."

IF ! lAlterEC2
   RecLock('EC2',.T.)
Else
   EC2->(DBGOTO(M->EC2_RECNO))
   RecLock('EC2',.F.)
EndIf
For i := 1 TO EC2->(FCount())
    IncProc()
    If EC2->(FIELDPOS(FIELDNAME(i))) # 0
       EC2->(FieldPut(i,M->&(FIELDNAME(i))))
    EndIf
Next
EC2->EC2_FILIAL:=xFilial("EC2")
EC2->(MSUNLOCK())

ProcRegua(WorkEC4->(LASTREC())+LEN(aDeleEC4)+1)
IncProc(STR0067) //"Gravando Despesas..."

FOR nI=1 to LEN(aDeleEC4)
    IncProc()
    EC4->(DBGOTO(aDeleEC4[nI]))
    RecLock("EC4",.F.)
    EC4->(DBDELETE())
    EC4->(MSUNLOCK())
NEXT

If M->EC2_TX_DI == 0
   WorkEC4->(DBGOTOP())
   DO WHILE ! WorkEC4->(EOF())

      IF WorkEC4->EC4_ID_CAM = '201'
         WorkEC4->(DBDELETE())
         EXIT
      ENDIF
      WorkEC4->(DBSKIP())
   ENDDO
EndIf

WorkEC4->(DBGOTOP())
Do While ! WorkEC4->(EOF())
   IncProc()
   IF lAlterEC2 .AND. WorkEC4->EC4_RECNO # 0
      EC4->(DBGOTO(WorkEC4->EC4_RECNO))
      RecLock('EC4',.F.)
          nNR_ContGrv:=WorkEC4->EC4_NR_CON
   ELSE
      RecLock('EC4',.T.)  // bloqueia e incluir registro vazio
          nNR_ContGrv:='0000'
   ENDIF

   For i := 1 TO EC4->(FCount())
       If EC4->(FIELDPOS(FIELDNAME(i))) # 0
          EC4->(FieldPut(i,WorkEC4->&(FIELDNAME(i))))
       EndIf
   Next
   EC4->EC4_NR_CON:=nNR_ContGrv
   EC4->EC4_FILIAL:=xFilial("EC4")
   EC4->(MSUNLOCK())
   WorkEC4->(DBSKIP())
Enddo

ProcRegua(WorkEC8->(LASTREC())+LEN(aDeleEC8)+1)
IncProc(STR0068) //"Gravando P.O.'s..."

FOR nI=1 to LEN(aDeleEC8)
    IncProc()
    EC8->(DBGOTO(aDeleEC8[nI]))

    IF EC5->(DBSEEK(xFilial("EC5")+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC))
       RecLock('EC5',.F.)
       EC5->EC5_HAWB := ""
       EC5->(MSUNLOCK())
    ENDIF

    RecLock("EC8",.F.)
    EC8->(DBDELETE())
    EC8->(MSUNLOCK())
NEXT

WorkEC8->(DBGOTOP())
Do While ! WorkEC8->(EOF())
   IncProc()

   IF EC5->(DBSEEK(xFilial("EC5")+WorkEC8->EC8_FORN+WorkEC8->EC8_INVOIC+WorkEC8->EC8_IDENTC))
      RecLock('EC5',.F.)
      EC5->EC5_HAWB := EC2->EC2_HAWB
      EC5->(MSUNLOCK())
   ENDIF

   IF lAlterEC2 .AND. WorkEC8->EC8_RECNO # 0
      EC8->(DBGOTO(WorkEC8->EC8_RECNO))
      RecLock('EC8',.F.)
   ELSE
      RecLock('EC8',.T.)  // bloqueia e incluir registro vazio
   ENDIF

   For i := 1 TO EC8->(FCount())
       If EC8->(FIELDPOS(FIELDNAME(i))) # 0
          EC8->(FieldPut(i,WorkEC8->&(FIELDNAME(i))))
       EndIf
   Next
   EC8->EC8_FILIAL:=xFilial("EC8")
   EC8->(MSUNLOCK())
   WorkEC8->(DBSKIP())
Enddo
COMMIT
End Transaction
Return .T.

*-----------------------------*
FUNCTION Di210_DesCamp(cCampo)
*-----------------------------*
PRIVATE cDescr

IF EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+cCampo))
   cDescr = EC6->EC6_DESC
ELSE
   cDescr = SPACE(20)
ENDIF

RETURN cDescr

*------------------*
FUNCTION DI210DEL()
*------------------*
LOCAL nCont:=0,bWhile
If ! lAlterEC2
   IF SimNao(STR0038,,,,,STR0039) # "S" //'Confirma `a Exclusao ? '###'Excluir'
      RETURN .T.
   ENDIF
ENDIF

//AAF 26/07/04 - Correção da deleção. Deleção 1o dos detalhes e depois da capa.
Begin Transaction

ProcRegua(1)
IncProc(STR0071) //"Deletando P.O.'s do Processo."

EC8->(DBSEEK(xFilial("EC8")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC))                                                                                       
cFilEC8:=xFilial("EC8") //LRL 09/12/04 - Conceito Multifilial
Do While ! EC8->(EOF()) .AND. (EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTCT)=(EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTCT) .AND. cFilEC8=EC8->EC8_FILIAL

   IF EC5->(DBSEEK(xFilial("EC5")+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC))
      RecLock('EC5',.F.)
      EC5->EC5_HAWB := ""
      EC5->(MSUNLOCK())
   ENDIF

   RecLock("EC8",.F.)
   dbDelete()
   MSUNLOCK()
   EC8->(DBSKIP())
Enddo

ProcRegua(nCont)
IncProc(STR0070) //"Deletando Despesas do Processo."

EC4->(DBSEEK(xFilial("EC4")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC))                                                                                       
cFilEC4:=xFilial("EC4") //LRL 09/12/04Compatibilidade com o conceito multifilial
Do While ! EC4->(EOF()) .AND. (EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTCT)=(EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTCT) .AND. cFilEC4=EC4->EC4_FILIAL
   IncProc()
   RecLock("EC4",.F.)
   dbDelete()
   MSUNLOCK()
   EC4->(DBSKIP())
Enddo

nCont:=0
EC8->(DBSEEK(xFilial("EC8")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC))
cFilEC8:=xFilial("EC8") //LRL 09/12/04 - Conceiito multifilial
bWhile:={|| !EC8->(EOF()) .AND. (EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTCT)=(EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTCT) .AND. cFilEC8=EC8->EC8_FILIAL}
EC8->(DBEVAL({||nCont++},,bWhile,,,.T.))

ProcRegua(nCont)
IncProc(STR0069) //"Deletando Processos."
EC2->(DBGOTO(M->EC2_RECNO))
RecLock("EC2",.F.)
dbDelete()
MSUNLOCK()

nCont:=0
EC4->(DBSEEK(xFilial("EC4")+M->EC2_HAWB+M->EC2_FORN+M->EC2_MOEDA+M->EC2_IDENTC))                                                                                         
cFilEC4 :=xFilial("EC4") //LRL 09/12/04 onceito MultiFilial
bWhile:={|| !EC4->(EOF()) .AND. (EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTCT)=(EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTCT) .AND. cFilEC4=EC4->EC4_FILIAL}
EC4->(DBEVAL({||nCont++},,bWhile,,,.T.))

End Transaction                              
RETURN .T.


*------------------------------------*
Function DI210Est(cAlias,nReg,nOpc)
*------------------------------------*
LOCAL cPath := AllTrim(EasyGParam("MV_PATH_CO"))
LOCAL aDbF_Stru := {{"WKHAWB"    ,"C",LEN(EC7->EC7_HAWB), 0 }  , {"WKINVOICE" ,"C",LEN(EC7->EC7_INVOIC), 0 },;
                    {"WKNR_DI"   ,AVSX3("EC7_DI_NUM",2)        , AVSX3("EC7_DI_NUM",3), 0 }, {"WKDT_LANC" ,"D",08, 0 }, ;
                    {"WKCTA_DEB" ,"C",LEN(EC7->EC7_CTA_DB), 0 }, {"WKCTA_CRE" ,"C", LEN(EC7->EC7_CTA_CR), 0 },;
                    {"WKVALOR"   ,"N",15, 2 }                  , {"WKOBS"     ,"C", LEN(EC7->EC7_OBS), 0 }, ;
                    {"WKIDENTCT" ,"C",LEN(EC7->EC7_IDENTC), 0 }, {"WKHOUSE"   ,"C", LEN(EC7->EC7_HAWB), 0 }, ;
                    {"WKCTACREES","C",LEN(EC7->EC7_CTA_DB), 0 }, {"WKCTADEBES","C", LEN(EC7->EC7_CTA_CR), 0 } }	                    

AAdd(aDbF_Stru, {"WKFORN","C",LEN(EC7->EC7_FORN), 0 })
AAdd(aDbF_Stru, {"WKMOEDA","C",LEN(EC7->EC7_MOEDA), 0 })
                     
Private TB_Cols:= { {{||EC8->EC8_INVOICE},"",STR0010},; //"Invoice"
                    {{||EC8->EC8_PO_NUM} ,"",STR0072 },; //"Nr. Po"
                    {{||DI210Moe()}      ,"",STR0073  },; //"Moeda"
                    {{||TRANS(EC8->EC8_FOB_PO,"@E 9,999,999,999.99")} ,"",STR0074  }} //"Valor"
PRIVATE cTit:=STR0075 //"Estorno de processos contabilizados"
PRIVATE cHAWB   := EC2->EC2_HAWB ,cIdentct := EC2->EC2_IDENTC , cForn := EC2->EC2_FORN, cMoeda := EC2->EC2_MOEDA, cMotivo := SPACE(50)
PRIVATE cMarca  := GetMark(), lInverte := .F.


IF(Right(cPath,1) != "\", cPath += "\",)


EC3->(DBSETORDER(3))
EC8->(DBSETORDER(1))

cNomArq := E_CriaTrab(, aDBF_Stru, "Work")
IF ! USED()
   Help(" ",1,"E_NAOHARE")
   EC3->(DBSETORDER(1))
   RETURN .F.
ENDIF

EC8->(DBSEEK(xFilial("EC8")+cHAWB+cForn+cMoeda+cIdentct))

   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg2 TITLE cTit ;
       FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
   	     OF oMainWnd PIXEL                          

   nLin  := 1.4
   nColS := 1.0
   nColG := 8.0
   @ nLin  ,nColS    SAY STR0076 //"Processo"
   @ nLin++,nColS+20 SAY STR0077 //"B.U. / Unid. Req."
   @ nLin++,nColS    SAY STR0078 //"Motivo"

   nLin  := 1.4
   @ nLin  ,nColG    MSGET cHawb    WHEN .F.  SIZE 80  ,08 OF oDlg2
   @ nLin++,nColG+20 MSGET cIdentct WHEN .F.  SIZE 65  ,08 OF oDlg2
   @ nLin++,nColG    MSGET cMotivo            SIZE 230 ,08 OF oDlg2
   oMark:=MsSelect():New( 'EC8',,,TB_Cols,@lInverte,@cMarca,{45,1,Iif(SetMDIChild(), ((oDlg2:nClientHeight-2)/2) + 40, (oDlg2:nClientHeight-2)/2),(oDlg2:nClientWidth-2)/2},"DI210Filtro()","DI210Filtro()")
   nVolta:=0
ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||If(DI210Val('ESTORNO'),(nVolta:=1,oDlg2:End()),)},;
                                                  {||oDlg2:End()})
If nVolta # 0
   If SimNao(STR0079,,,,,STR0080)=='S' //'Confirma o Estorno ? '###'Estorno'
      Processa({||DI210Deleta()},STR0081) //"Estornando"
      Processa({||GrvW6WB()},STR0081) //"Estornando"
      Work->(DBGOTOP())

      IF Work->(EOF()) .AND. Work->(BOF())
         E_MSG ( STR0082,1) //"N„o h  movimenta‡„os a serem impressas."
      ELSE
         If (lR4 := lR4 .And. FindFunction("TRepInUse") .And. TRepInUse() ) //TRP-01/11/2006
            //TRP - 21/08/2006 - Relatório Personalizavel - Release 4
            //ReportDef cria os objetos.
            oReport := ReportDef()
         EndIf
         Processa(If(lR4, {||oReport:PrintDialog()},{||DI210Imprime()}),STR0083) //"Impressao"
         Work->(avzap())
      ENDIF
   EndIf
EndIf

//IV_Ctb->(dbcloseAREA())
EC3->(DBSETORDER(1))
EC8->(DBSETORDER(2))
Work->(E_EraseArq(cNomArq))
Return Nil

*------------------*
Function DI210Moe()
*------------------*
If EC5->(DBSEEK(xFilial("EC5")+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC))
   Return EC5->EC5_MOE_FO
Else
   Return SPACE(3)
EndIf

*--------------------------*
Function DI210Filtro()
*--------------------------*
Return xFilial("EC8")+cHawb+cForn+cMoeda+cIdentct


*---------------------*
FUNCTION DI210Deleta()
*---------------------*

Local TP_EC8_FORN, TP_EC8_INVOIC, TP_EC8_IDENTC

BEGIN TRANSACTION
 
 If lExisteECF
 ECF->(DbSetOrder(2))
 Endif  
 ProcRegua(6)
 EC7->(DBSETORDER(2))
 IncProc( STR0084 ) //"Estornando..."
 cFilEC7 := xFilial('EC7') //LRL 09/12/04 Conceito Multifilial
 IF EC7->(DBSEEK(cFilEC7+cHAWB+cForn+cMoeda+cIdentct))
    GravaLog("EC7","H:"+cHAWB+cIdentct)
    DO WHILE !EC7->(EOF()) .AND. (cHAWB+cForn+cMoeda+cIdentct)==(EC7->EC7_HAWB+EC7->EC7_FORN+EC7->EC7_MOEDA+EC7->EC7_IDENTC) .AND. EC7->EC7_FILIAL==cFilEC7
  
      Work->(DBAPPEND())
      Work->WKHOUSE   := cHAWB
      Work->WKIDENTCT := cIdentct
      Work->WKHAWB    := EC7->EC7_HAWB
      Work->WKINVOICE := EC7->EC7_INVOIC
      Work->WKNR_DI   := EC7->EC7_DI_NUM
      Work->WKDT_LANC := EC7->EC7_DT_LAN
      Work->WKCTA_DEB := EC7->EC7_CTA_DB
      Work->WKCTA_CRE := EC7->EC7_CTA_CR
      Work->WKVALOR   := EC7->EC7_VALOR
      WorK->WKOBS     := EC7->EC7_OBS
      WorK->WKFORN := EC7->EC7_FORN
      WorK->WKMOEDA   := EC7->EC7_MOEDA
      
      // Faz a gravacao no Arq. ECE
      If lGrvECE
         GravaECE()                                
         Work->WKCTADEBES := ECE->ECE_CDBEST
         Work->WKCTACREES := ECE->ECE_CCREST 
      Endif                     
            
      Reclock("EC7",.F.)
      EC7->(DBDELETE())
      EC7->(DBCOMMIT())             
      EC7->(DBSKIP())
   ENDDO
 ENDIF
 IncProc()
 IF EC4->(DBSEEK(xFilial("EC4")+cHAWB+cForn+cMoeda+cIdentct))
   GravaLog("EC4","H:"+cHAWB+cIdentct)
   cFilEC4 := xFilial("EC4") //LRL 09/12/04 - Conceito Multifilial
   DO WHILE !EC4->(EOF()) .AND. (EC4->EC4_HAWB+EC4->EC4_FORN+EC4->EC4_MOEDA+EC4->EC4_IDENTC)==(cHAWB+cForn+cMoeda+cIdentct) .AND. cFilEC4==EC4->EC4_FILIAL

      Reclock("EC4",.F.)
      EC4->(DBDELETE())
      EC4->(DBCOMMIT())
      EC4->(DBSKIP())
   ENDDO
 ENDIF
 IncProc()              
 cFilEC3:= xFilial('EC3')
 IF EC3->(DBSEEK(cFilEC3+cHAWB+cForn+cMoeda+cIdentct))
   GravaLog("HI000","H:"+cHAWB + cIdentct)
   DO WHILE ! EC3->(EOF()).AND. (EC3->EC3_HAWB+EC3->EC3_FORN+EC3->EC3_MOEDA+EC3->EC3_IDENTC)==(cHAWB+cForn+cMoeda+cIdentct) .AND. EC3->EC3_FILIAL==cFilEC3

      Reclock("EC3",.F.)
      EC3->(DBDELETE())
      EC3->(DBCOMMIT())
      EC3->(DBSKIP())
   ENDDO
 ENDIF
 IncProc()                
 cFilEC8:=xFilial("EC8") //LRL 09/12/04 - Conceito Multifilial
 cFilEC7:=xFilial("EC7") //LRL 09/12/04 - Conceito Multifilial
 IF EC8->(DBSEEK(xFilial("EC8")+cHAWB+cForn+cMoeda+cIdentct))
   GravaLog("EC8","H:"+cHAWB+cIdentct)

   DO WHILE !EC8->(EOF()) .AND. (EC8->EC8_HAWB+EC8->EC8_FORN+EC8->EC8_MOEDA+EC8->EC8_IDENTC)==(cHAWB+cForn+cMoeda+cIdentct) .AND. EC8->EC8_FILIAL==cFilEC8

      EC7->(DBSETORDER(1))
      IF EC7->(DBSEEK(cFilEC7+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC))
         GravaLog("EC7","I: "+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC)
         DO WHILE !EC7->(EOF()) .AND. EC8->EC8_FORN+EC8->EC8_INVOIC==EC7->EC7_FORN+EC7->EC7_INVOIC .AND. EC7->EC7_FILIAL==cFilEC7

            Work->(DBAPPEND())
            Work->WKHOUSE   := cHAWB
            Work->WKHAWB    := EC7->EC7_HAWB
            Work->WKIDENTCT := EC7->EC7_IDENTC
            Work->WKINVOICE := EC7->EC7_INVOIC
            Work->WKNR_DI   := EC7->EC7_DI_NUM
            Work->WKDT_LANC := EC7->EC7_DT_LAN
            Work->WKCTA_DEB := EC7->EC7_CTA_DB
            Work->WKCTA_CRE := EC7->EC7_CTA_CR
            Work->WKVALOR   := EC7->EC7_VALOR
            WorK->WKOBS     := EC7->EC7_OBS
            WorK->WKFORN := EC7->EC7_FORN            
        	WorK->WKMOEDA   := EC7->EC7_MOEDA      
            
            // Faz a gravacao no Arq. ECE
            If lGrvECE
               GravaECE()
               Work->WKCTADEBES := ECE->ECE_CDBEST
               Work->WKCTACREES := ECE->ECE_CCREST                        
            Endif       

            Reclock("EC7",.F.)
            EC7->(DBDELETE())
            EC7->(DBCOMMIT())                                      
            EC7->(DBSKIP())
         ENDDO
      ENDIF
//    IF IV_Ctb->(DBSEEK(EC8->EC8_INVOIC+EC8->EC8_IDENTC))
//       GravaLog("IV100", "I: "+EC8->EC8_INVOIC+EC8->EC8_IDENTC)
//       DO WHILE !IV_Ctb->(EOF()) .AND. ALLTRIM(EC8->EC8_INVOIC)=ALLTRIM(IV_CTb->IVINVOICE) .AND. ALLTRIM(EC8->EC8_IDENTC)=ALLTRIM(IV_CTb->IVIDENTCT)

//          IV_Ctb->(DBDELETE())
//          IV_Ctb->(DBCOMMIT())
//          IV_Ctb->(DBSKIP())
//       ENDDO
//    ENDIF
      cFilEC9:=xFilial('EC9')
      IF EC9->(DBSEEK(cFilEC9+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC))
         GravaLog("EC9", "I: "+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC)
         DO WHILE !EC9->(EOF()) .AND. (EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC)==(EC9->EC9_FORN+EC9->EC9_INVOIC+EC9->EC9_IDENTC) .AND. EC9->EC9_FILIAL==cFilEC9

            Reclock("EC9",.F.)
            EC9->(DBDELETE())
            EC9->(DBCOMMIT())
            EC9->(DBSKIP())
         ENDDO
      ENDIF 
      
      //AAF 28/07/04 - Alterada a ordem de exclusão devido a problemas de integridade referencial.
      TP_EC8_FORN  := EC8->EC8_FORN
      TP_EC8_INVOIC:= EC8->EC8_INVOIC
      TP_EC8_IDENTC:= EC8->EC8_IDENTC
            
      Reclock("EC8",.F.)
      EC8->(DBDELETE())
      EC8->(DBCOMMIT())
          
      IF EC5->(DBSEEK(xFilial("EC5")+TP_EC8_FORN+TP_EC8_INVOIC+TP_EC8_IDENTC))
         GravaLog("EC5","I: "+EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC)  
         cFilEC5:=xFilial("EC5")//LRL 09/12/04 - Conceito de Multifiliis
         DO WHILE !EC5->(EOF()) .AND. (EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC)==(EC5->EC5_FORN+EC5->EC5_INVOIC+EC5->EC5_IDENTC) .AND. EC5->EC5_FILIAL==cFilEC5

            Reclock("EC5",.F.)
            EC5->(DBDELETE())
            EC5->(DBCOMMIT())
            EC5->(DBSKIP())
         ENDDO
      ENDIF
      

      EC8->(DBSKIP())
  ENDDO
 ENDIF     
 IncProc()
 IF EC2->(DBSEEK(xFilial("EC2")+cHAWB+cForn+cMoeda+cIdentct))
   GravaLog("EC2","H:"+cHAWB+cIdentct)
   cFilEC2:=xFilial("EC2")
   DO WHILE ! EC2->(EOF()) .AND. (EC2->EC2_HAWB+EC2->EC2_FORN+EC2->EC2_MOEDA+EC2->EC2_IDENTC)==(cHAWB+cForn+cMoeda+cIdentct) .AND. cFilEC2==EC2->EC2_FILIAL

      Reclock("EC2",.F.)
      EC2->(DBDELETE())
      EC2->(DBCOMMIT())
      EC2->(DBSKIP())
   ENDDO
 ENDIF 
 IncProc()
 MSUNLOCKALL()
 If lExisteECF
 ECF->(DbSetOrder(1))
 Endif  

END TRANSACTION

Return Nil

*----------------------*
FUNCTION DI210Imprime()
*----------------------*
#DEFINE COURIER_07 oFont1    
#DEFINE COURIER_10 oFont2
LOCAL cHawb, cIdentct
Local TB_Campos    := {}
Local aRCampos     := {}                  
Private lInvTrans  := .F.
PRIVATE aDados := {"Work",;
                   "Este programa tem como objetivo imprimir relatorio de acordo com os parametros informados pelo usuario.",;
                   STR0087,; 
                   "",;
                   "G",;
                   132,;
                   "",;
                   "",;
                   STR0087+" "+STR0086+DTOC(dDataBase),; //"Data: "
                   { "Zebrado", 1,"Contabil", 1, 1, 1, "",1 },;
                     "ECODI210" ,;
                   { {||.T. } , {||If(lExisteECF, ImpMsg() ,.T.) } }  }
                     
Work->(DBGOTOP())
                                                                                                
AADD(TB_Campos,{{ ||Work->WKHAWB  }   											 ,"L" , STR0090    } )                 
AADD(TB_Campos,{{ ||Work->WKFORN  }   										 ,"L" , STR0101    } )                 

AADD(TB_Campos,{{ ||Work->WKMOEDA  }   										     ,"L" , STR0073    } )                 
AADD(TB_Campos,{{ ||Work->WKINVOICE  }   										 ,"L" , STR0091    } )                 
AADD(TB_Campos,{{ ||TRANS(Work->WKNR_DI,AVSX3("EC7_DI_NUM",06))}                 ,"R" , STR0092    } )               
AADD(TB_Campos,{{ ||DTOC(Work->WKDT_LANC)  }                                     ,"L" , STR0093    } )               
AADD(TB_Campos,{{ ||Work->WKCTA_DEB  }                             				 ,"L" , STR0094    } )              
AADD(TB_Campos,{{ ||Work->WKCTA_CRE  }                             				 ,"L" , STR0095    } )             
AADD(TB_Campos,{{ ||TRANS(Work->WKVALOR,"@E 9,999,999,999.99") }   				 ,"L" , STR0096    } )              
AADD(TB_Campos,{{ ||Work->WKOBS}   												 ,"L" , STR0097    } )              
AADD(TB_Campos,{{ ||Work->WKIDENTCT}    										 ,"L" , STR0098    } )                 
If lGrvECE
   AADD(TB_Campos,{{ ||Work->WKCTADEBES  }                             			 ,"L" , STR0099    } )             
   AADD(TB_Campos,{{ ||Work->WKCTACREES  }                             			 ,"L" , STR0100    } )             
Endif          
                    
aRCampos:= E_CriaRCampos(TB_CAMPOS)               
E_Report(aDados,aRCampos)

RETURN .T.

*-----------------------------*
FUNCTION GravaLog(carq,cchave)
*-----------------------------*
Reclock("ECD",.T.)
ECD->ECD_FILIAL:= xFilial("ECD")
ECD->ECD_ARQ   := carq
ECD->ECD_CHAVE := cChave
ECD->ECD_DATA  := dDataBase
ECD->ECD_USER  := cUserName
ECD->ECD_MOTIVO:= cMotivo
ECD->(MSUNLOCK())
RETURN

*-----------------------------*
FUNCTION GravaECE()
*-----------------------------*
Local cCtaDebEst := cCtaCreEst := Space(Len(EC7->EC7_CTA_CR))
Local cContaForn := REPLI("9",LEN(EC7->EC7_CTA_DB))
Local lGrv603    := .F.

EC5->(DBSEEK(xFilial("EC5")+EC7->EC7_FORN+EC7->EC7_INVOIC+EC7->EC7_IDENTC))
EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+EC7->EC7_LINK+EC7->EC7_IDENTC))
SA2->(DBSEEK(xFilial("SA2")+EC5->EC5_FORN))
EC2->(DBSEEK(xFilial("EC2")+EC7->EC7_HAWB+EC7->EC7_FORN+EC7->EC7_MOEDA+EC7->EC7_IDENTC)) 

RecLock('ECE',.T.)
ECE->ECE_FILIAL := xFilial("ECE")

//** AAF 22/02/08 - Gravação do ECE_TPMODU
If ECE->(FieldPos("ECE_TPMODU")) > 0
   ECE->ECE_TPMODU := 'IMPORT'
EndIf
//**

ECE->ECE_HAWB   := EC7->EC7_HAWB
ECE->ECE_INVOIC := EC7->EC7_INVOIC
ECE->ECE_DI_NUM := EC2->EC2_DI_NUM
ECE->ECE_DT_LAN := EC7->EC7_DT_LAN
ECE->ECE_CTA_DB := EC7->EC7_CTA_DB
ECE->ECE_CTA_CR := EC7->EC7_CTA_CR
ECE->ECE_VALOR  := EC7->EC7_VALOR
ECE->ECE_OBS    := EC7->EC7_OBS
ECE->ECE_IDENTC := EC7->EC7_IDENTC
ECE->ECE_HOUSE  := EC7->EC7_HAWB
ECE->ECE_ID_CAM := '999'            // Grava evento contabil de estorno 999
ECE->ECE_LINK   := EC7->EC7_LINK
ECE->ECE_NR_CON := '0000'
ECE->ECE_DT_EST	:= Date()
ECE->ECE_MOE_FO := EC5->EC5_MOE_FO
ECE->ECE_COD_HI := EC7->EC7_COD_HI
ECE->ECE_COM_HI := IF(EC7->EC7_COM_HI $ 'EST.', EC7->EC7_COM_HI, 'EST. '+EC7->EC7_COM_HI)
ECE->ECE_FORN   := EC2->EC2_FORN 

IF EC7->EC7_LINK = '603' 
   EC9->(DbSetOrder(2))
   cFilSWB:=xFilial('SWB')
   IF EC9->(DBSEEK(xFilial('EC9')+EC7->EC7_FORN+EC7->EC7_INVOIC+EC7->EC7_IDENTC+'603'))
			IF SWB->(DBSEEK(cFilSWB+EC7->EC7_HAWB+EC7->EC7_INVOIC+EC7->EC7_FORN))
			 	 DO WHILE SWB->(!EOF()) .AND. SWB->WB_HAWB == EC7->EC7_HAWB .AND. SWB->WB_FILIAL == cFilSWB  
				  	IF SWB->WB_INVOICE = EC9->EC9_INVOIC .And. EC9->EC9_PARIDA  = SWB->WB_CA_TX 
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
   ENDIF
   EC9->(DbSetOrder(1))
   
   IF !lGrv603
      cCtaDebEst := EC7->EC7_CTA_CR
   Endif   
				    					
Else      
   IF EC6->EC6_CDBEST = cContaForn 
      cCtaDebEst := SA2->A2_CONTAB
   Elseif EMPTY(EC6->EC6_CDBEST) 
	  cCtaDebEst := EC7->EC7_CTA_CR
   Else 
	  cCtaDebEst := EC6->EC6_CDBEST
   Endif
ENDIF   

IF EC6->EC6_CCREST = cContaForn
   cCtaCreEst := SA2->A2_CONTAB
Elseif EMPTY(EC6->EC6_CCREST)
   cCtaCreEst := EC7->EC7_CTA_DB			
Else
   cCtaCreEst := EC6->EC6_CCREST
Endif

ECE->ECE_CDBEST := cCtaDebEst
ECE->ECE_CCREST := cCtaCreEst
ECE->(MSUNLOCK())

If EasyEntryPoint("ECODI210")
   ExecBlock("ECODI210",.F.,.F.,"DEPOISGRAVAECE")
Endif

RETURN .T.

*-----------------------------*
 FUNCTION GrvW6WB()
*-----------------------------*

IncProc()              
cFilSW6:=xFilial('SW6')
IF SW6->(DBSEEK(cFilSW6+cHAWB))
   DO WHILE ! SW6->(EOF()) .AND. SW6->W6_HAWB == cHAWB .AND. SW6->W6_FILIAL==cFilSW6
      Reclock("SW6",.F.)
      SW6->W6_CONTAB := CTOD('  /   /  ')
      SW6->(DBSKIP())
   ENDDO
ENDIF      
SW6->(MSUNLOCKALL())
IncProc()
cFilSWB:=xFilial('SWB')
IF SWB->(DBSEEK(cFilSWB+cHAWB))
   DO WHILE ! SWB->(EOF()) .AND. SWB->WB_HAWB == cHAWB .AND. SWB->WB_FILIAL==cFilSWB
      Reclock("SWB",.F.)
      SWB->WB_CONTAB := CTOD('  /   /  ')
      SWB->(DBSKIP())
   ENDDO
ENDIF      
SWB->(MSUNLOCKALL())
IncProc()

Return .T.
*-----------------------------*
STATIC FUNCTION ImpMsg()   // Imprime Mensagem que possui pagamento antecipado a ser estornado 
*-----------------------------*

@ PROW()+2, 10 PSAY STR0103          

RETURN .T.


//AAF - 26/07/04 - Função de validação no botão Incluir
*-----------------------------*
STATIC FUNCTION DI210ValPO()   // Verifica se o evento contabil do PO existe.
*-----------------------------*
LOCAL cRet:= .T.
//AAF - 26/07/04 - Validação para a unidade requesitante.
IF Empty(M->EC2_IDENTC)
   MsgStop(STR0111)//"Digite a Unidade Requesitante"
   cRet:= .F.
ELSEIF cAliasWork=="WorkEC8" .AND. !EC6->(DbSeek(xFilial("EC6")+"IMPORT"+"201"+M->EC2_IDENTC))
   MsgStop(STR0110+M->EC2_IDENTC) //"Evento contabil não cadastrado para Unidade Requesitante "
   cRet:= .F.
ELSE
   nOpca:=3
   oDlg:End()
ENDIF

RETURN cRet


//TRP - 21/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
Local cTit:=STR0087+" "+STR0086+DTOC(dDataBase)
lExisteECF:=.T.
cCabec:= If(lExisteECF,STR0103 ,"") 

//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"EC7"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("ECODI210",cTit,"",{|oReport| ReportPrint(oReport)},STR0087)

// Define o relatorio como Landscape Nick 20/10/06
oReport:opage:llandscape := .T.
oReport:opage:lportrait := .F.

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Processos Estornados",aTabelas,aOrdem)

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Mensagem",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1,"WKHAWB"        ,"Work"  ,STR0090              ,/*Picture*/                       ,LEN(EC7->EC7_HAWB)                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKFORN"        ,"Work"  ,STR0101              ,/*Picture*/                       ,LEN(EC7->EC7_FORN)                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKMOEDA"       ,"Work"  ,STR0073              ,/*Picture*/                       ,LEN(EC7->EC7_MOEDA)                         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKINVOICE"     ,"Work"  ,STR0091              ,/*Picture*/                       ,LEN(EC7->EC7_INVOIC)                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKNR_DI"       ,"Work"  ,STR0092              ,AVSX3("EC7_DI_NUM",06)            ,AVSX3("EC7_DI_NUM",3)                       ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKDT_LANC"     ,"Work"  ,STR0093              ,/*Picture*/                       ,08                                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKCTA_DEB"     ,"Work"  ,STR0094              ,/*Picture*/                       ,LEN(EC7->EC7_CTA_DB)                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKCTA_CRE"     ,"Work"  ,STR0095              ,/*Picture*/                       ,LEN(EC7->EC7_CTA_CR)                        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKVALOR"       ,"Work"  ,STR0096              ,"@E 9,999,999,999.99"             ,15                                          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKOBS"         ,"Work"  ,STR0097              ,/*Picture*/                       ,LEN(EC7->EC7_OBS)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"WKIDENTCT"     ,"Work"  ,STR0098              ,/*Picture*/                       ,LEN(EC7->EC7_IDENTC)                        ,/*lPixel*/,/*{|| code-block de impressao }*/)


//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,  "Mensagem"          ,"",       ""           ,"@!"                   ,180        ,/*lPixel*/,{||cCabec})


//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

***********************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Seção 1")

TRPosition():New(oReport:Section("Processos Estornados"),"EC7",1,{|| xFilial("EC7") +EC8->EC8_FORN+EC8->EC8_INVOIC+EC8->EC8_IDENTC})

//oSection:Print()
oReport:SetMeter (Work->(EasyRecCount()))
Work->( dbGoTop() )

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Processos Estornados"):Init()

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Mensagem"):Init()

//Para desabilitar a impressão da página de parâmetros do pergunte
//oReport:oParamPage:Disable()

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Processos Estornados"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

oReport:Section("Mensagem"):PrintLine()

//Fim da impressão da seção 1
oReport:Section("Processos Estornados"):Finish()

//Fim da impressão da seção 2
oReport:Section("Mensagem"):Finish() 

Return .T.

