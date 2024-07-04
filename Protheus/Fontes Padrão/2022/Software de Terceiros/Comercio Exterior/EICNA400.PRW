#INCLUDE "Eicna400.ch"
#INCLUDE "Average.ch"


#Define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)-2
#Define FINAL_ENCHOICE MEIO_DIALOG-1
#Define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#Define FINAL_SELECT   (oDlg:nClientHeight-6)/2

#DEFINE EXCLUIR  4
#DEFINE ALTERAR  3
#DEFINE INCLUIR  2
#DEFINE ESTORNO  3
#DEFINE OK       1
#DEFINE SAIR     0
#DEFINE NUM_DI_NEW EVAL({|| LEFT("DA"+SW6->W6_DI_NUM,LEN(SW2->W2_PO_NUM)) })

*--------------------------------------*
Function EicNA400()
*--------------------------------------*
Private cTitulo := STR0001    // "Dados para Nacionalização da DA"
PRIVATE bSeek   :={||SW7->(DBSEEK(xFilial()+SW6->W6_HAWB)) }
PRIVATE bWhile  :={||xFilial("SW7") = SW7->W7_FILIAL .AND. ;
                		   SW7->W7_HAWB = SW6->W6_HAWB }, bFor:={||.T.}
Private lTrava := .F., MTem_Guia:=.F. // Variavel utilizada palas validações do SW2
Private cProg:="PN", lDiSimples := .F.
PRIVATE nDecimais :=AVSX3("W6_FOB_TOT",4)
Private aRotina := MenuDef()

aHeader:={}
aCampos:=ARRAY( SWN->(FCOUNT()) )

cCadastro := STR0001    // "Dados para Nacionalização da DA"

dbSelectArea("SW6")
dbSetOrder(1)

//Set Filter To Val(SW6->W6_TIPODES) >= 2 .And. Val(SW6->W6_TIPODES) <= 4
cFiltro:="W6_FILIAL='"+xFilial("SW6")+"' .AND. W6_TIPOFEC='DA'"
SET FILTER TO &cFiltro
         
//dbGoTop()
mBrowse( 6, 1,22,75,"SW6")
dbSelectArea("SW6")
Set Filter To
SW1->(dbSetOrder(1))
SW2->(dbSetOrder(1))
SW3->(dbSetOrder(1))
SW4->(dbSetOrder(1))
SW5->(dbSetOrder(1))
SW6->(dbSetOrder(1))
SW7->(dbSetOrder(1))
Return .T. 


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 26/01/07 - 14:34
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina  := { { STR0002 ,"AxPesqui"   , 0  , 1},;       // "Pesquisar"
                    { STR0003 ,"NA400VISUAL", 0  , 2},;       // "Visualiza"
                    { STR0004 ,"NA400GeraDI", 0  , 4}}        // "Nacionaliza"

If EasyEntryPoint("EICNA400")
   ExecBlock("EICNA400", .F., .F., "AROTINA")
EndIf                                                                         

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("INA400MNU")
	aRotAdic := ExecBlock("INA400MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina


// Gera Po de nacionalização para DA
*--------------------------------------*
Function NA400GeraDI(cAlias,nReg,nOpc)
*--------------------------------------*
Local lOk := .T.
Local cFilSW9:=xFilial("SW9")
Local cFilSY6:=xFilial("SY6")

lDiSimples := SW6->W6_DSI == "1"

If Val(SW6->W6_TIPODES) < 2 .Or. Val(SW6->W6_TIPODES) > 4
   Help(" ", 1, "AVG0000092")
   lOk := .F.
ElseIf Empty(SW6->W6_REC_ALF)
   Help(" ", 1, "AVG0000093")
   lOk := .F.
ElseIf Empty(SW6->W6_DT_DTA)
   Help(" ", 1, "AVG0000094")
   lOk := .F.
ElseIf Empty(SW6->W6_DI_NUM)
   Help(" ", 1, "AVG0000096")
   lOk := .F.
ElseIf SW2->(DBSEEK(xFilial("SW2")+ NUM_DI_NEW))
   Help(" ", 1, "AVG0000097")
   lOk := .F.
EndIf                                                   
/*  NCF - 03/01/2011 - Entreposto passa a ser permitido com cobertura cambial (Decreto nº 6759 artigo 407)
SW9->(DBSETORDER(3))
SW9->(DBSEEK(cFilSW9+SW6->W6_HAWB))
DO WHILE !SW9->(EOF())              .AND.;
          SW9->W9_FILIAL == cFilSW9 .AND.;
          SW9->W9_HAWB   == SW6->W6_HAWB .AND. lOK

   SY6->(DBSEEK(cFilSY6+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3,0)))

   IF SY6->Y6_TIPOCOB # '4'
      Help("", 1, "AVG0005368",,ALLTRIM(SW9->W9_INVOICE)+STR0022,3,40)//LRL 09/01/04 MSGSTOP(STR0021+) //"Invoice: "###", com condicao de pagamento diferente de sem cobertura."
      lOk := .F.
   ENDIF

   SW9->(DBSKIP())

ENDDO

SW9->(DBSETORDER(1))
*/
If lOk
   NA400NACIO(cAlias,nReg,nOpc)
EndIf

Return(.T.)

*--------------------------------------*
Function NA400Visual(cAlias,nReg,nOpc)
*--------------------------------------*
LOCAL nOpcao := 0 
LOCAL oDlg, oGet, i, oEnch
LOCAL cAlias1:="SW7"

PRIVATE cChave:=SW6->W6_HAWB
PRIVATE aHeader[0]

lDiSimples := SW6->W6_DSI == "1"

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

aCampos:={}
aCampos:={"W7_SEQ_LI" , "WP_REGIST" , "WP_VENCTO" ,;
          "W7_PO_NUM" , "W7_CC"     , "W7_SI_NUM" ,;
          "W7_COD_I"  , "W5_DESC_P" , "W7_POSICAO",;
          "W7_FABR"   , "W5_FABR_N" , "W7_FORN"   ,;
          "W5_FORN_N" , "W7_QTDE"   , "W7_PRECO"  ,;
          "W6_FOB_TOT", "W9_INVOICE", "W9_DT_EMIS",;
          "W7_HAWB"   , "W2_MOEDA"  , "W7_FORLOJ" ,;
          "W7_FABLOJ" }

aSemSx3 := {{"TRB_ALI_WT","C",03,0},;
            {"TRB_REC_WT","N",10,0}}

aCpos := {}
AADD(aCpos,{"W7_SEQ_LI" ,,AVSX3("W7_SEQ_LI" ,5)})         //"Seq. LI"
AADD(aCpos,{"WP_REGIST" ,,AVSX3("WP_REGIST" ,5)})         //"No. LI"
AADD(aCpos,{"WP_VENCTO" ,,AVSX3("WP_VENCTO" ,5)})         //"Vencto LI"
AADD(aCpos,{"W7_PO_NUM" ,,AVSX3("W7_PO_NUM" ,5)})         //"No. PO"
AADD(aCpos,{"W2_MOEDA"  ,,AVSX3("W2_MOEDA"  ,5)})
AADD(aCpos,{"W7_CC"     ,,AVSX3("W7_CC"     ,5)})         //"C.C"
AADD(aCpos,{"W7_SI_NUM" ,,AVSX3("W7_SI_NUM" ,5)})         //"No. SI"
AADD(aCpos,{"W7_POSICAO",,AVSX3("W7_POSICAO",5)})         //"Posicao"
AADD(aCpos,{"W7_COD_I"  ,,AVSX3("W7_COD_I"  ,5)})         //"Item"
AADD(aCpos,{"W5_DESC_P" ,,STR0005              })         //"Descrição p/ LI"
AADD(aCpos,{"W7_FABR"   ,,AVSX3("W7_FABR"   ,5)})         
AADD(aCpos,{"W7_FABLOJ" ,,AVSX3("W7_FABLOJ" ,5)})
AADD(aCpos,{"W5_FABR_N" ,,AVSX3("W5_FABR_N" ,5)})         
AADD(aCpos,{"W7_FORN"   ,,AVSX3("W7_FORN"   ,5)})
AADD(aCpos,{"W7_FORLOJ" ,,AVSX3("W7_FORLOJ" ,5)})
AADD(aCpos,{"W5_FORN_N" ,,AVSX3("W5_FORN_N" ,5)})         
AADD(aCpos,{"W7_QTDE"   ,,STR0008,AVSX3("W7_QTDE"   ,6)})//"Quantidade"
AADD(aCpos,{"W7_PRECO"  ,,STR0009,AVSX3("W7_PRECO"  ,6)})//"Preco Unitario"
AADD(aCpos,{"W6_FOB_TOT",,STR0010,AVSX3("W6_FOB_TOT",6)})//"Preco Total"
AADD(aCpos,{"W9_INVOICE",,STR0021,AVSX3("W9_INVOICE",6)}) // Invoice:
AADD(aCpos,{"W9_DT_EMIS",,STR0012})                       //"Data da Invoice"
						           
cNomArq:=E_CriaTrab(,aSemSx3)
IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
IndREgua("TRB",cNomArq+TEOrdBagExt(),"W7_HAWB+WP_REGIST+W7_CC+W7_SI_NUM+W7_COD_I")

TRB->(DBGOTOP())

FOR i := 1 TO SW6->(FCount())
    SW6->( M->&(FIELDNAME(i)) := FieldGet(i) )
NEXT

DO While .T.
   bSeek :={||SW7->(DBSEEK(xFilial()+SW6->W6_HAWB)) }
   bWhile:={|| xFilial("SW7") == W7_FILIAL .AND. SW7->W7_HAWB == SW6->W6_HAWB }
   TRB->(avzap())


   MsAguarde({|| SW7->(NA400GrWk(,bSeek,bFor,bWhile,"NA400Visual")) },;
                 STR0015) // "Pesquisa de Itens"
   
   oMainWnd:ReadClientCoords()

   DEFINE MSDIALOG oDlg TITLE cTitulo ;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL  

   oEnCh:=MsMget():New( cAlias, nReg, nOpc, , , , ,{15,1,FINAL_ENCHOICE,COLUNA_FINAL}, , 3 )
   dbSelectArea("TRB")
   dbGoTop()

   oGet:= MSSELECT():New("TRB",,,aCpos,.F.,"XX",{MEIO_DIALOG,1,FINAL_SELECT,COLUNA_FINAL})

    oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},; //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                                                    {||nOpcao:=0,oDlg:End()}))//LRL 12/04/04 - Alinhamento MDI                                          
   Exit

EndDO

TRB->(E_EraseArq(cNomArq))

DBSELECTAREA("SW6")

Return( nOpc )

*----------------------------------------------------*
FUNCTION NA400GrWk(bMsg,bSeek,bFor,bWhile,cPrograma)
*----------------------------------------------------*

SW7->(DBSETORDER(1))
EVAL(bSeek)

DO WHILE ! SW7->(EOF()) .AND. EVAL(bWhile)

  MsProcTxt( STR0016+ALLTRIM(SW7->W7_COD_I) ) // "Pesquisa de Itens"

  IF ! EVAL(bFor)
     SW7->(DBSKIP()) ; LOOP
  ENDIF

  SWP->(DBSEEK(xFilial()+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
  SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))
  SB1->(DBSEEK(xFilial()+SW7->W7_COD_I))
  SA2->(DBSEEK(xFilial()+SW7->W7_FABR+SW7->W7_FABLOJ))

  IF(cPrograma=="DI410",MConta++,)
  IF(cPrograma=="DI410",MTotal+=( SW7->W7_QTDE * SW7->W7_PRECO ),)

  TRB->(DBAPPEND())
  TRB->W7_SEQ_LI := SW7->W7_SEQ_LI
  TRB->WP_REGIST := SWP->WP_REGIST
  TRB->WP_VENCTO := SWP->WP_VENCTO
  TRB->W7_COD_I  := SW7->W7_COD_I
  TRB->W5_DESC_P := MSMM( SB1->B1_DESC_GI,36,1 )
  TRB->W7_PO_NUM := SW7->W7_PO_NUM
  TRB->W2_MOEDA  := SW2->W2_MOEDA
  TRB->W7_CC     := SW7->W7_CC
  TRB->W7_SI_NUM := SW7->W7_SI_NUM
  TRB->W7_FABR   := SW7->W7_FABR
  TRB->W7_FABLOJ := SW7->W7_FABLOJ
  TRB->W7_POSICAO:= SW7->W7_POSICAO
  TRB->W5_FABR_N := SA2->A2_NREDUZ
  TRB->W7_FORN   := SW7->W7_FORN
  TRB->W7_FORLOJ := SW7->W7_FORLOJ
  SA2->(DBSEEK(xFilial() + SW7->W7_FORN + SW7->W7_FORLOJ))
  TRB->W5_FORN_N := SA2->A2_NREDUZ
  TRB->W7_QTDE   := SW7->W7_QTDE
  TRB->W7_PRECO  := SW7->W7_PRECO
  TRB->W6_FOB_TOT:= NA400Trans(SW7->W7_QTDE*SW7->W7_PRECO)
  TRB->W9_INVOICE:= SW8->(PesqIVH(SW7->W7_HAWB,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,;
                            SW7->W7_PGI_NUM,SW7->W7_SI_NUM,SW7->W7_PO_NUM,SW7->W7_CC,;
                            SW7->W7_REG))
  TRB->TRB_ALI_WT:= "SW7"
  TRB->TRB_REC_WT:= SW7->(Recno())
  
  IF !EMPTY(TRB->W9_INVOICE)
     nPos := AT("+",TRB->W9_INVOICE)
     IF nPos # 0
        SW9->(DBSEEK(xFilial("SW9")+ SUBST(TRB->W9_INVOICE,1,nPos-1)))
     ELSE
        SW9->(DBSEEK(xFilial("SW9")+ TRB->W9_INVOICE))
     ENDIF
     TRB->W9_DT_EMIS:= SW9->W9_DT_EMIS
  ENDIF

  SW7->(DBSKIP())

ENDDO

RETURN NIL

*--------------------------------------*
Function NA400Nacio(cAlias,nReg,nOpc)
*--------------------------------------*
LOCAL nOpcao := 0, i
LOCAL oDlg, oGet ,oEnch

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

aCamposSW2:={;
"W2_NR_PRO" , "W2_DT_PRO" , "W2_COND_PA", "W2_DIAS_PA", ;
"W2_VM_OBS" , "W2_REG_TRI", "W2_REFCLI" , "W2_ARMAZEM", "W2_VENCDA"}

// PERMITIR ALTERACAO
aAltSW2 := {;
"W2_NR_PRO" , "W2_DT_PRO" , "W2_COND_PA", "W2_DIAS_PA", ;
"W2_VM_OBS" , "W2_REG_TRI", "W2_REFCLI" , "W2_ARMAZEM", "W2_VENCDA"}

aAltSW2 := AddCpoUser(aAltSW2,"SW2","1")

aCampos:={"W2_PO_NUM" ,"W2_MOEDA"  ,"W2_PO_DT","W2_FORN","W2_FORLOJ","W2_FORNDES","W2_CLIENTE",;
          "W2_CLINOME","W2_CLILOJ","W2_FOB_TOT"}

cIndice:="W2_PO_NUM+W2_FORN+W2_MOEDA"

aSemSx3 := {{"TRB_ALI_WT","C",03,0},;
            {"TRB_REC_WT","N",10,0}}

aTB_Campos:={}
//Os dois espacos eh para forcar a coluna do numero do Pedido ficar mais larga e aparecer a sequencia
AADD(aTB_Campos,{ {|| TRANS(TRB->W2_PO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,AVSX3("W2_PO_NUM" ,5)})
AADD(aTB_Campos,{"W2_MOEDA"  ,,AVSX3("W2_MOEDA"  ,5)})
AADD(aTB_Campos,{"W2_PO_DT"  ,,AVSX3("W2_PO_DT"  ,5)})
AADD(aTB_Campos,{"W2_FORN"   ,,AVSX3("W2_FORN"   ,5)})
AADD(aTB_Campos,{"W2_FORLOJ" ,,AVSX3("W2_FORLOJ" ,5)})
AADD(aTB_Campos,{"W2_FORNDES",,AVSX3("W2_FORNDES",5)})
AADD(aTB_Campos,{"W2_FOB_TOT",,AVSX3("W2_FOB_TOT",5),AVSX3("W6_FOB_TOT",6)})
AADD(aTB_Campos,{"W2_CLIENTE",,AVSX3("W2_CLIENTE",5)})
AADD(aTB_Campos,{"W2_CLILOJ" ,,AVSX3("W2_CLILOJ" ,5)})
AADD(aTB_Campos,{"W2_CLINOME",,AVSX3("W2_CLINOME",5)})

If EasyEntryPoint("EICNA400")
   ExecBlock("EICNA400", .F., .F., "ENCHOICESW2")
EndIf

cFileTRB:=E_CriaTrab(,aSemSX3)
IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
IndRegua("TRB",cFileTRB+TEOrdBagExt(),cIndice)

PRIVATE cChave:=SW6->W6_HAWB

SW7->(DBSETORDER(1))
SW2->(DBSETORDER(1))
lOK:=.T.
If !SW7->(dbSeek(xFilial("SW7")+SW6->W6_HAWB)) .OR. ;
   !SW2->(dbSeek(xFilial("SW2")+SW7->W7_PO_NUM))
   Help(" ",1,"E_NAOHAITE")//NAO HA ITENS PARA O PROCESSAMENTO.
   lOK:=.F.
ENDIF
	
IF lOK
   FOR i := 1 TO SW2->(FCount())
       SW2->( M->&(FIELDNAME(i)) := FieldGet(i) )
   NEXT
   M->W2_HAWB_DA := SW6->W6_HAWB
   M->W2_PO_DT   := dDataBase
   M->W2_ARMAZEM := SW6->W6_REC_ALF
   M->W2_VENCDA  := SW6->W6_DT_DTA+EasyGParam("MV_VENCDA")
   M->W2_COND_PA := SPACE(LEN(SW6->W6_COND_PA))
   M->W2_DIAS_PA := 0
   M->W2_NR_PRO  := SW6->W6_NR_PRO
   M->W2_CLIENTE := SW2->W2_CLIENTE
   M->W2_CLILOJ  := SW2->W2_CLILOJ

   Processa({|| lOK:=NA400GrvTRB() })
ENDIF

DO WHILE lOK
   aTela :={}
   aGets :={}
   nOpcao:=0 
   TRB->(DBGOTOP())

   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE cTitulo ;
              FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
                OF oMainWnd PIXEL
	
     oEnCh:=MsMGet():New("SW2",SW2->(Recno()),nOpc,,,,aCamposSW2,{15,1,FINAL_ENCHOICE,COLUNA_FINAL},aAltSW2,3)
     
     //GFP 19/10/2010
     //aTB_Campos := AddCpoUser(aTB_Campos,"SW2","2")

     oGet:= MSSELECT():New("TRB",,,aTB_Campos,.F.,"XX",{MEIO_DIALOG,1,FINAL_SELECT,COLUNA_FINAL})
	
	 oEnch:oBox:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	 oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpcao:=1,oDlg:End()},;
                                                   {||nOpcao:=0,oDlg:End()})) //LRL 12/04/04 - Alinhamento MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	IF nOpcao == 0
	   EXIT
	ENDIF

	If nOpcao == 1 .AND. Obrigatorio(aGets,aTela) .AND.;
       MsgYesNo(STR0017,STR0018)//"Confirma a Nacionalizacao ? "###"Gera dados para nacionalizacao"
       nCont:=1                  
       TRB->(DBGOTOP())
       Processa({|| TRB->(DBEVAL( {|| NA400GRVPONAC() } )) },STR0019)
       EXIT
	EndIf

EndDO

TRB->(E_EraseArq(cFileTRB))

DBSELECTAREA("SW6")

Return( nOpc )
*------------------------*
Function NA400GrvTRB()
*------------------------*
LOCAL cFilSW2:= xFilial("SW2")
LOCAL cFilSW7:= xFilial("SW7")
LOCAL nSeq   := 1,I,P,nPosSW2,nPosTRB
PRIVATE aPedidos:={},lOk := .T.

ProcRegua(2)

TRB->(avzap())
SW7->(dbSeek(cFilSW7+SW6->W6_HAWB))

IncProc()

DO While !(SW7->(Eof())) .AND. cFilSW7 == SW7->W7_FILIAL .AND.;
                          SW6->W6_HAWB == SW7->W7_HAWB
   SW2->(dbSeek(cFilSW2+SW7->W7_PO_NUM))
   IF (nPos:=ASCAN(aPedidos, {|P| P[1]==SW2->W2_MOEDA .AND. P[2]==SW2->W2_FORN } )) = 0
      AADD (aPedidos, {SW2->W2_MOEDA,SW2->W2_FORN,SW7->W7_PO_NUM,NA400Trans(SW7->W7_QTDE*SW7->W7_PRECO)} )
   ELSE
      aPedidos[nPos,4]+=NA400Trans(SW7->W7_QTDE*SW7->W7_PRECO)
   ENDIF
   SW7->(DBSKIP())
ENDDO

IncProc()

ProcRegua(LEN(aPedidos))
FOR P := 1 TO LEN(aPedidos)
    IncProc()
    TRB->(DBAPPEND())
    SW2->(dbSeek(cFilSW2+aPedidos[P,3]))
    FOR I := 1 TO LEN(aCampos)//{"W2_PO_NUM","W2_MOEDA","W2_PO_DT","W2_FORN","W2_FORNDES","W2_CLIENTE","W2_CLINOME"}
        nPosSW2:= SW2->( FIELDPOS( aCampos[I] ) )
        nPosTRB:= TRB->( FIELDPOS( aCampos[I] ) )
        IF nPosSW2 # 0 .AND. nPosTRB # 0
           TRB->(FIELDPUT( nPosTRB , SW2->(FieldGet( nPosSW2 )) ))
        ENDIF
    
    NEXT
    TRB->TRB_ALI_WT:= "SW2"
    TRB->TRB_REC_WT:= SW2->(Recno())
    
    
    TRB->W2_PO_NUM := NUM_DI_NEW+"/"+STRZERO(nSeq,2)
    DO WHILE SW2->(DBSEEK(cFilSW2+TRB->W2_PO_NUM))
       nSeq++
       TRB->W2_PO_NUM:=NUM_DI_NEW+"/"+STRZERO(nSeq,2)
    ENDDO
    nSeq++
    TRB->W2_FORNDES:= BuscaF_F(TRB->W2_FORN+TRB->W2_FORLOJ,.T.)
    TRB->W2_CLINOME:= BuscacLIENTE(TRB->W2_CLIENTE,.T.)
    TRB->W2_FOB_TOT:= aPedidos[P,4]
NEXT

If EasyEntryPoint("EICNA400")
   ExecBlock("EICNA400", .F., .F., "GRAVA_TRB")
EndIf

Return lOk
*------------------------*
Function NA400GRVPONAC()
*------------------------*
Local nPosicao, aReg, nScan, i, _nx
Local nRecnoAnt, lFound, cOldAlias := Alias()
Local cPoNum   := TRB->W2_PO_NUM//NUM_DI_NEW
Local cSiNum, cPgiNum, nTotSW7:=0, nLI
LOCAL cNcmAnt := SPACE(AVSX3("B1_POSIPI",3))
Local lMVEasy := IF(EasyGParam("MV_EASY")$cSim,.T.,.F.)
LOCAL oDlgProc := GetWndDefault()
LOCAL cFilSB1:=xFilial('SB1')
LOCAL cFilSW0:=xFilial('SW0')
LOCAL cFilSW1:=xFilial('SW1')
LOCAL cFilSW2:=xFilial('SW2')
LOCAL cFilSW3:=xFilial('SW3')
LOCAL cFilSW4:=xFilial('SW4')
LOCAL cFilSW5:=xFilial('SW5')
LOCAL cFilSW7:=xFilial('SW7')
Private lAnuente := .F.

oDlgProc:SetText(STR0023+cPoNum+" - "+STRZERO(nCont,3)+" / "+STRZERO(TRB->(Easyreccount("TRB")),3)  ) //"Gravando Pedido: "
nCont++

cExNCMAnt := cExNBMAnt := SPACE(AVSX3("W3_EX_NCM",3))
cNBMAnt   := SPACE(LEN(cNCMAnt+cEXNCMANT+cExNBMAnt))

IF GetNewPar("MV_EASYFIN","N") $ cSim
   axFlDelWork:={}
   TP251CriaWork()
ENDIF

Begin Transaction

M->W2_PO_NUM:=TRB->W2_PO_NUM//Variavel de memoria usada no EICFI400
EICFI400("ANT_GRV_PO","I")

SW0->(DBSETORDER(1))                      
SW7->(DBSETORDER(1))                      
SW7->(dbSeek(cFilSW7+SW6->W6_HAWB))
ProcRegua(Easyreccount("SW7")+2)
Do While ! SW7->(EOF()) .AND. SW6->W6_HAWB=SW7->W7_HAWB .AND. cFilSW7=SW7->W7_FILIAL
   IncProc()
   nTotSW7+=1
   SW7->(DBSKIP())
EndDo

ProcRegua(nTotSW7+2)
IncProc(STR0020)
SW7->(dbSeek(xFilial()+SW6->W6_HAWB))
Do While .T.
   cSiNum := GetSxENum("SW0", "W0__NUM")
   
   /*Quando a integração via EAI estiver habilitada, a numeração da solicitação de importação de nacionalização
     será iniciada com '*' (asterisco), evitando a rejeição da integração da ordem de compra por duplicação
     da numeração.*/ 
   If AvFlags("EIC_EAI")
      cSiNum:= "*" + StrZero(Val(cSiNum), AvSx3("W1_SI_NUM", AV_TAMANHO) - 1)
   EndIf
   
   If SW0->(dbSeek(cFilSW0+SW7->W7_CC+cSiNum))
      ConfirmSx8()
   Else
      ConfirmSx8()
      Exit
   EndIf
EndDo

SW4->(dbSetOrder(1))
SW5->(dbSetOrder(8))
IncProc(STR0020)

cPgiNum :="*"+EasyGetMVSeq("MV_SEQ_LI")+"*"
/*
Do While .T.
   nLi := EasyGParam("MV_SEQ_LI")
   cPgiNum :="*"+StrZero(nLi,8)+"*"  	
   Do While SW4->(dbSeek(cFilSW4+cPgiNum)) .or. SW5->(dbSeek(cFilSW5+cPgiNum))
      nLi += 1
      cPgiNum :="*"+StrZero(nLi,8)+"*"  	
   EndDo

   SetMV("MV_SEQ_LI",STRZERO(nLi+1,8,0))

   Exit

EndDo
*/
SW4->(dbSetOrder(1))
SW5->(dbSetOrder(1))
nPosicao := 1
aReg     := {}
DO While !(SW7->(Eof())) .And. cFilSW7+SW6->W6_HAWB == SW7->W7_FILIAL+SW7->W7_HAWB
   IncProc()

   SW2->(dbSeek(xFilial()+SW7->W7_PO_NUM))
   IF SW2->W2_MOEDA # TRB->W2_MOEDA .OR. SW2->W2_FORN  # TRB->W2_FORN 
      SW7->(DBSKIP())
      LOOP
   ENDIF

   //DFS - 03/02/11 - Refeito tratamento para verificar se o item é anuente ou não.
   //NCF - 16/06/2011 - Modificado o tratamento para considerar os casos de itens não anuentes
   //                   que se tornam anuentes no pedido diante da obrigatoriedade do Drawback
   //                   que utiliza saldo de itens de DI de Nacionalização.
   IF EasyGParam("MV_EIC_EDC",,.F.)
      //FSM - 17/05/2012
      If EasyGParam("MV_AVG0211",,.F.) .And. SW3->(FieldPos("W3_ALTANU")) > 0
         aOrdSW3 := SaveOrd({"SW3"})
         
         SW3->(DBSetOrder(8))
         If SW3->( DBSeek(xFilial("SW3")+SW7->W7_PO_NUM+SW7->W7_POSICAO ) )
            lAnuente := If( SW3->W3_ALTANU=="2", If(  !(SB1->(dbSeek(cFilSB1+SW7->W7_COD_I)))  ,.F.,  If(SB1->B1_ANUENTE == "1", .T., .F.)  ) , If(SW7->W7_FLUXO == "1", .T.,.F.))            
         EndIf
      
         RestOrd(aOrdSW3, .T.)
         
      Else
         lAnuente := If(SW7->W7_FLUXO == "1", .T.,.F.)         
      EndIf
   
   ELSE
      lAnuente := If(  !(SB1->(dbSeek(cFilSB1+SW7->W7_COD_I)))  ,.F.,  If(SB1->B1_ANUENTE == "1", .T., .F.)  )
   ENDIF 
   // redefinição do Reg
   nScan:= Ascan(aReg, {|x| x[1] = SW7->W7_COD_I})
   If nScan == 0
      AADD(aReg, {SW7->W7_COD_I, 1})
      nScan := Len(aReg)
   Else
      aReg[nScan,2] := aReg[nScan,2] + 1
   EndIf
	
   // procurar a sequencia 0 da si para utilizar os campos de segunda unidade
    cUnid2 := " "
    nFatSegun := 1
    IF lMvEasy
      SW1->(DBSETORDER(1))
      SW1->(DBSEEK(xFilial("SW1")+SW7->W7_CC+SW7->W7_SI_NUM+SW7->W7_COD_I))
      DO WHILE ! SW1->(EOF()) .AND. xFilial("SW1") == SW1->W1_FILIAL .AND. ;
           SW1->W1_CC == SW7->W7_CC .AND.SW1->W1_SI_NUM == SW7->W7_SI_NUM .AND. ;
           SW1->W1_COD_I == SW7->W7_COD_I
        IF SW1->W1_SEQ == 0  .AND. SW1->W1_REG == SW7->W7_REG 
          nFatSegun := SW1->W1_QTSEGUM /SW1->W1_QTDE
          cUnid2 := SW1->W1_SEGUM
          EXIT
        ENDIF
        SW1->(DBSKIP())
      ENDDO
    ENDIF
			
   // Gravo dados da SI de nacionalização
   SW1->(dbSetOrder(2))
   If SW1->(dbSeek(cFilSW1+SW7->W7_PO_NUM+SW7->W7_POSICAO+SW7->W7_CC+SW7->W7_SI_NUM))
	
	  // Gravar capa SW0
   	  If !SW0->(dbSeek(cFilSW0+SW7->W7_CC+cSiNum))
         SW0->(dbSeek(cFilSW0+SW7->W7_CC+SW7->W7_SI_NUM))
//       dbSelectArea("SW0")
         FOR i := 1 TO SW0->(FCount())
       	     SW0->( M->&(FIELDNAME(i)) := SW0->(FieldGet(i) ))
         NEXT
         If SW0->(EOF())
            M->W0__CC := SW7->W7_CC
       	    M->W0_COMPRA:=SW2->W2_COMPRA
         EndIf
         M->W0_HAWB_DA := SW6->W6_HAWB
         SW0->(RecLock("SW0", .T.))
         For _nX := 1 To SW0->(fCount())
             _cCampo    := "M->"+SW0->(Field(_nX))
             _xConteudo := &_cCampo
             _nPos      := SW0->(FieldPos(SW0->(Field(_nX))))
             SW0->(FieldPut(_nPos, _xConteudo))
         Next
         SW0->W0_FILIAL := xFILIAL("SW0")
         SW0->W0__NUM := cSiNum
         SW0->W0__DT  := dDataBase
         SW0->(MsUnLock())
      EndIf
	  
	   // Replicar o registro para W1_SEQ == 0
      FOR i := 1 TO SW1->(FCount())
          SW1->( M->&(FIELDNAME(i)) := SW1->(FieldGet(i) ))
      NEXT
   	  SW1->(RecLock("SW1", .T.))
   	  For _nX := 1 To SW1->(fCount())
	      _cCampo    := "M->"+SW1->(Field(_nX))
          _xConteudo := &_cCampo
          _nPos      := SW1->(FieldPos(SW1->(Field(_nX))))
       	  SW1->(FieldPut(_nPos, _xConteudo))
   	  Next
      SW1->W1_FILIAL  := xFILIAL("SW1")
   	  SW1->W1_QTDE    := SW7->W7_QTDE
   	  SW1->W1_SALDO_Q := 0
      SW1->W1_PRECO   := SW7->W7_PRECO
   	  SW1->W1_PO_NUM  := Space(Len(SW1->W1_PO_NUM))
   	  SW1->W1_SI_NUM  := cSiNum
      SW1->W1_SEQ     := 0
   	  SW1->W1_FLUXO   := If(lAnuente, "1", "7")
   	  SW1->W1_REG     := aReg[nScan, 2]
   	  SW1->W1_POSICAO := SPACE(Len(SW1->W1_POSICAO))
          SW1->W1_QTSEGUM := SW7->W7_QTDE * nFatSegun
          SW1->W1_SEGUM   := cUnid2
   	  
   	  /*Quando integrado via mensagem única - EAI*/
   	  If AvFlags("EIC_EAI")
   	     SW1->W1_STATUS:= "F" //"Atendida - em fase de Purchase Order"
   	  EndIf
   	  
   	  SW1->(MsUnLock())
	
   	  // Replicar o registro para W1_SEQ original
   	  //dbSelectArea("SW1")
   	  SW1->(RecLock("SW1", .T.))
   	  For _nX := 1 To SW1->(fCount())
          _cCampo    := "M->"+SW1->(Field(_nX))
      	  _xConteudo := &_cCampo
      	  _nPos      := SW1->(FieldPos(SW1->(Field(_nX))))
      	  SW1->(FieldPut(_nPos, _xConteudo))
   	  Next
   	  SW1->W1_QTDE    := SW7->W7_QTDE
   	  SW1->W1_SALDO_Q := 0
   	  SW1->W1_PRECO   := SW7->W7_PRECO
   	  SW1->W1_PO_NUM  := cPoNum
   	  SW1->W1_SI_NUM  := cSiNum
   	  SW1->W1_SEQ     := 1
   	  SW1->W1_FLUXO   := If(lAnuente, "1", "7")
      SW1->W1_POSICAO := StrZero(nPosicao,LEN(SW3->W3_POSICAO))
   	  SW1->W1_REG     := aReg[nScan, 2]
   	  SW1->(MsUnLock())
   EndIf
   
   SW3->(dbSetOrder(8))
   SW3->(dbSeek(cFilSW3+SW7->W7_PO_NUM+SW7->W7_POSICAO))
   DO While !(SW3->(Eof())) .And. cFilSW3+SW7->W7_PO_NUM+SW7->W7_POSICAO ==;
	                              SW3->W3_FILIAL+SW3->W3_PO_NUM+SW3->W3_POSICAO

      If SW3->W3_SEQ == 0 .Or. (SW3->W3_SEQ > 0 .And. !lAnuente .And. SW7->W7_PGI_NUM == SW3->W3_PGI_NUM)
      
         If SW3->W3_SEQ == 0
     	    SW2->(dbSetOrder(1))
     		lFound := SW2->(dbSeek(cFilSW2+cPoNum))
//   		dbSelectArea("SW2")
     		SW2->(RecLock("SW2", !lFound))
     		If !lFound
               M->W2_FOB_TOT:=0
     		   For _nX := 1 To SW2->(fCount())
//        		   SX3->(dbSeek(Field(_nX)))
          		   If Upper(SW2->(Field(_nX))) == "W2_OBS"
            		  MSMM(M->W2_OBS,TamSx3("W2_VM_OBS")[1],,M->W2_VM_OBS,1,,,"SW2","W2_OBS")
             		  SW2->(RecLock("SW2", .F.))
        		   Else
            		  _cCampo    := "M->"+SW2->(Field(_nX))
            		  _xConteudo := &_cCampo
            		  _nPos      := SW2->(FieldPos(SW2->(Field(_nX))))
            		  SW2->(FieldPut(_nPos, _xConteudo))
          		   EndIf
        	   Next
       		   SW2->W2_PO_NUM  := cPoNum
//     		   IF !Empty(SW6->W6_COND_PA)
//       		  SW2->W2_COND_PA := SW6->W6_COND_PA
//     		   EndIf
       		   IF !Empty(SW6->W6_AGENTE)
         		   SW2->W2_AGENTE := SW6->W6_AGENTE
       		   EndIf
       		   IF !Empty(SW6->W6_VIA_TRA)
         	      SW2->W2_TIPO_EM := SW6->W6_VIA_TRA
			   EndIf
       		   IF !Empty(SW6->W6_ORIGEM)
         	      SW2->W2_ORIGEM := SW6->W6_ORIGEM
        	   EndIf
       		   IF !Empty(SW6->W6_DEST)
         	      SW2->W2_DEST := SW6->W6_DEST
       		   EndIf
       		   SW2->W2_MOEDA := TRB->W2_MOEDA
       		   SW2->W2_FORN  := TRB->W2_FORN 
       		EndIf
     		SW2->W2_FOB_TOT := TRB->W2_FOB_TOT//(SW7->W7_QTDE * SW7->W7_PRECO)
     		SW2->(MsUnLock())
   		 EndIf
      
	     FOR i := 1 TO SW3->(FCount())
             SW3->( M->&(FIELDNAME(i)) := FieldGet(i) )
         NEXT
//       dbSelectArea("SW3")
   	     nRecnoAnt := SW3->(Recno())
 	     SW3->(RecLock("SW3", .T.))
   	     For _nX := 1 To SW3->(fCount())
 		     _cCampo    := "M->"+SW3->(Field(_nX))
	         _xConteudo := &_cCampo
  	         _nPos      := SW3->(FieldPos(SW3->(Field(_nX))))
	         SW3->(FieldPut(_nPos, _xConteudo))
	     Next
   	     SW3->W3_QTDE    := SW7->W7_QTDE
   	     SW3->W3_SEQ     := If(SW3->W3_SEQ=0,0,1)
	     If !lAnuente
    	    SW3->W3_SALDO_Q := 0
   	     Else
	   	    SW3->W3_SALDO_Q :=SW7->W7_QTDE
   	     EndIf
         SW3->W3_PO_DA   := SW7->W7_PO_NUM
	     SW3->W3_PGI_DA  := SW7->W7_PGI_NUM
         SW3->W3_POSI_DA := SW7->W7_POSICAO
   		 SW3->W3_PRECO   := SW7->W7_PRECO
		 SW3->W3_PO_NUM  := cPoNum
   		 SW3->W3_SI_NUM  := cSiNum
		 SW3->W3_FLUXO   := If(lAnuente, "1", "7")
   		 SW3->W3_POSICAO := StrZero(nPosicao,LEN(SW3->W3_POSICAO))
		 SW3->W3_REG     := aReg[nScan, 2]
   		 SW3->W3_DT_EMB  :=	dDataBase+1
		 SW3->W3_DT_ENTR := dDataBase+2
   		 If SW3->W3_SEQ > 0
		   	SW3->W3_PGI_NUM := cPgiNum
   		 EndIF
		 SW3->(MsUnLock())     
   		 // PARA PODER DAR LOCK , ANTES DA GRAVACAO : 
		 cNBmAnt  := Busca_NCM("SW7")
   		 cNCMAnt  := LEFT(cNBMAnt,AVSX3("B1_POSIPI",3))
		 cExNcmAnt:= SUBSTR(cNBMAnt,AVSX3("B1_POSIPI",3)+1,AVSX3("W3_EX_NCM",3))
   		 cExNBMAnt:= RIGHT(cNBMAnt,AVSX3("W3_EX_NBM",3))
         SW3->(RecLock("SW3", .F.)) // a funcao abaixo anda no sw3 e volta - rhp
		 SW3->W3_TEC    := cNcmAnt
   		 SW3->W3_EX_NCM := cExNCMAnt 
   		 SW3->W3_EX_NBM := cExNBMAnt

         If EasyEntryPoint("EICNA400")
            ExecBlock("EICNA400", .F., .F., "GRAVA_SW3")
         EndIf

		 SW3->(MsUnLock())
   		 SW3->(dbGoTo(nRecnoAnt))
			
 	  EndIf
	  SW3->(dbSkip())
   EndDo
   
   // Gravo os dados da Li (Quando não anuente E anuente com anuencia na fase de DA)
   If !lAnuente
      SW5->(dbSetOrder(8))
      SW5->(dbSeek(cFilSW5+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_POSICAO))
      DO While !(SW5->(Eof())) .And.;
         cFilSW5+SW7->W7_PGI_NUM+SW7->W7_PO_NUM+SW7->W7_POSICAO ==;
         SW5->W5_FILIAL+SW5->W5_PGI_NUM+SW5->W5_PO_NUM+SW5->W5_POSICAO
		 
		 If SW5->W5_SEQ == 0
		 
		    // Gravar capa SW4
        	lFound := SW4->(dbSeek(cFilSW4+cPgiNum))
        	SW4->(RecLock("SW4",!lFound))
        	RegToMemory("SW4",.T.,.F.) // GFP - 28/05/2015
        	If !lFound
               FOR i := 1 TO SW4->(FCount())
                   SW4->( M->&(FIELDNAME(i)) ) := SW4->(FieldGet(i))
      		   NEXT
        	   M->W4_HAWB_DA := SW6->W6_HAWB
        	   For _nX := 1 To SW4->(fCount())
         	       _cCampo    := "M->"+SW4->(Field(_nX))
                   _xConteudo := &_cCampo
                   _nPos      := SW4->(FieldPos(SW4->(Field(_nX))))
            	   SW4->(FieldPut(_nPos, _xConteudo))
          	   Next
         	   SW4->W4_PGI_NUM := cPgiNum
         	   SW4->W4_GI_NUM  := cPgiNum
                   SW4->W4_FILIAL  := cFilSW4
            EndIf
       	    SW4->W4_FOB_TOT := TRB->W2_FOB_TOT//(SW7->W7_QTDE * SW7->W7_PRECO)
       	    SW4->(MsUnLock())
		 
//      	 dbSelectArea("SW5")
            FOR i := 1 TO SW5->(FCount())
           	    SW5->( M->&(FIELDNAME(i)) := FieldGet(i) )
       		NEXT
        	nRecnoAnt := SW5->(Recno())
        	 // Replicar o registro
               				
         	SW5->(RecLock("SW5", .T.))
        	For _nX := 1 To SW5->(fCount())					
           	    _cCampo    := "M->"+SW5->(Field(_nX))
           	    _xConteudo := &_cCampo
            	_nPos      := SW5->(FieldPos(SW5->(Field(_nX))))
           		SW5->(FieldPut(_nPos, _xConteudo))
        	Next
        	SW5->W5_QTDE    := SW7->W7_QTDE
        	SW5->W5_SALDO_Q := SW7->W7_QTDE
        	SW5->W5_PRECO   := SW7->W7_PRECO
        	SW5->W5_PGI_NUM := cPgiNum
        	SW5->W5_PO_NUM  := cPoNum
        	SW5->W5_SI_NUM  := cSiNum
        	SW5->W5_FLUXO   := "7"
        	SW5->W5_POSICAO := StrZero(nPosicao,LEN(SW3->W3_POSICAO))
        	SW5->W5_REG     := aReg[nScan, 2]
        	SW5->W5_SEQ_LI  := Space(Len(SW5->W5_SEQ_LI))
        	SW5->W5_EX_NCM  := SPACE(LEN(SW5->W5_EX_NCM)) // PARA PEGAR DO PO
        	SW5->W5_EX_NBM  := SPACE(LEN(SW5->W5_EX_NBM)) // PARA PEGAR DO PO
        	SW5->(MsUnLock())
        	SW5->(dbGoTo(nRecnoAnt))
				
   	     EndIf									   
         SW5->(dbSkip())
      EndDo
   EndIf

   SW7->(dbSkip())
   nPosicao ++

EndDo
SW6->(RecLock("SW6", .F.))
SW6->W6_FILIAL := xFILIAL("SW6")
SW6->W6_NACIONA := "1"
SW6->(MsUnLock())

EICFI400("POS_GRV_PO","I")

dbSelectArea("TRB")
End Transaction   

Return(Nil)
*--------------------------------------*
STATIC Function NA400Trans(nValor,nDec)
*--------------------------------------*
IF(nDec=NIL,nDec:= nDecimais,)
RETURN ROUND(nValor,nDec)

//------------------------------------------------------------------------------------//
//                     FIM DO PROGRAMA EICNA400.PRW
//------------------------------------------------------------------------------------//
