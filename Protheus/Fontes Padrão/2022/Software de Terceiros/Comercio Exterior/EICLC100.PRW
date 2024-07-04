//Funcao    :EICLC100 
//Autor     :AVERAGE-MJBARROS      
//Data      :09/10/96
//Descricao :Cartas de Credito                                         
//Uso       :SIGAEIC   
                                                

#INCLUDE "Eiclc100.ch"   
#INCLUDE "AVERAGE.CH"
#DEFINE GI_TEM_ASTERISCO   AT( "*" , SW4->W4_GI_NUM ) # 0
#define nMEIO   INT(((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 ) + 15
*-----------------------*
Function EICLC100()
*-----------------------*
LOCAL nOldArea:=Select()

PRIVATE aCores := {}  //TRP - 14/10/2011 - Variável para criação de semáforos - Chamado 089842 

PRIVATE aRotina := MenuDef()

PRIVATE lIncPo := .F.

M->W5_PGI_NUM:=""
M->W3_PO_NUM :=""
aCampos:={}

PRIVATE aSemSX3:={{"WKRECNO"   ,"N",06,0},;
                  {"WK_VLR_EMB","N",15,2},;
                  {"TRB_ALI_WT","C",03,0},;
                  {"TRB_DESCPG","C",50,0},;
                  {"TRB_REC_WT","N",10,0}}

AADD(aCampos,"W3_PO_NUM")
AADD(aCampos,"W5_PGI_NUM")
AADD(aCampos,"WP_REGIST")
AADD(aCampos,"W4_PGI_DT")
AADD(aCampos,"WC_VLR_ABE")
AADD(aCampos,"WC_PER_FOB")
AADD(aCampos,"W4_INLAND")
AADD(aCampos,"W4_PACKING")
AADD(aCampos,"W4_FRETEIN")
AADD(aCampos,"W4_DESCONT")
AADD(aCampos,"W2_OUT_DES")
AADD(aCampos,"W2_COND_PA")
AADD(aCampos,"W2_DIAS_PA")
AADD(aCampos,"WB_PGTANT")

PRIVATE PO_GI:="2",nOpc,lBROW
PRIVATE cCadastro := STR0006 //"Cartas de Credito"
PRIVATE cTitulo   := STR0006 //"Cartas de Credito"
PRIVATE lInverte:=.F., cMarca := GetMark()

lCposAdto:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado

lBROW := .T.
IF cMODULO = "EFF"
   AADD(aSEMSX3,{"WC_VLR_ABE","N",15,2})
   IF ! EasyGParam("MV_EIC_EFF",,.F.)
      lBROW := .F.
   ENDIF
ENDIF

mBrowse( 6, 1,22,75,"SWC",,,,,,aCores)

DbSelectArea(nOldArea) // sempre deve haver uma area selecionada

Return .T.                    


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 27/01/07 - 09:45
*/
Static Function MenuDef()
Local aRotAdic := {}         
Local aRotina :=  { { STR0001,"AxPesqui"  , 0 , 1},; //"Pesquisar"
                    { STR0002,"LC100Visua", 0 , 2},; //"Visual"
                    { STR0003,"LC100Inclu", 0 , 3},; //"Inclui"
                    { STR0004,"LC100Alter", 0 , 4},; //"Altera"
                    { STR0005,"LC100Delet", 0 , 5, 21} }//"Exclui"

IIF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"MBROWSE"),)  // PLB 15/12/06
                   
// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("ILC100MNU")
	aRotAdic := ExecBlock("ILC100MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

*------------------------------------------------*
Function LC100Visua(cAlias,nReg,nOpc)
*------------------------------------------------*
LOCAL nOpca := 0, i
LOCAL oDlg, oGet
LOCAL cAlias1:="SYH", cNomArq
LOCAL aCpos := {},aPOS

PRIVATE aTELA[0][0],aGETS[0]
PRIVATE nVlr_Emb:=0, CondPagto := SPACE(05), DiasPagto :=0, cTipoCond:= SPACE(01)
PRIVATE Fornecedor:=0, Moeda, cLoja
PRIVATE aBotao:= {}

aADD(aBotao,{"Zoom",{||LCPgiZoom()},"Pesquisa"}/*"S4WB011N"*/)

lAltera:=.F.

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

FOR i := 1 TO FCount()
   M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

LC100LimpaSdo()

aHeader:={}

dbSelectArea(cAlias1)
dbSetOrder(1)
dbSeek(xFilial()+SWC->WC_LC_NUM)

LC100Colunas(aCpos)
              
LC100GeraTRB(lAltera)   

IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"VISUAL_BOTAO"),)
   
DO While .T.

      IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"VISUAL_TELA"),)
      
      dbSelectArea("TRB")
      dbGoTop()

      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE cTitulo ;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
         OF oMainWnd PIXEL                          

         aPOS := IF(lBROW,{ 15,  1, nMEIO-1 , (oDlg:nClientWidth-4)/2 },POSDLG(oDLG))
         oEnCh1 := MsMGet():New( cAlias, nReg, nOpc, , , , , aPOS, , 3 )

         IF lBROW
            
            //GFP - 18/10/2010 - 15:39
            //aCpos := AddCpoUser(aCpos,"SW3","2")
            
            oGet:= MsSelect():New("TRB",,,aCpos,.F.,"X",{nMEIO,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
            oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         ENDIF
         oEnCh1:oBox:Align := iif(lBrow,CONTROL_ALIGN_TOP,CONTROL_ALIGN_ALLCLIENT) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oDlg:lMaximized := .T.
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nopca:=2,oDlg:End()},{||oDlg:End()},,aBotao)) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      Exit

EndDO

TRB->(E_EraseArq(cNomArq))

dbSelectArea(cAlias)

Return( nOpca )

*-----------------------------------------*
Function LC100Inclu(cAlias,nReg,nOpc)
*-----------------------------------------*
LOCAL nOpca := 0,lGravaOk := .T.,i
LOCAL cAlias1:="SYH", cNomArq
LOCAL oDlg,aPOS
LOCAL aCpos := {}
LOCAL lGrvRdmInc:= .T.

PRIVATE aTela[0][0],aGets[0]
PRIVATE SvPO_GI:=NIL
PRIVATE nVlr_Emb:=0, CondPagto := SPACE(05), DiasPagto :=0, cTipoCond:= SPACE(01)
PRIVATE Fornecedor:=0, Moeda, cLoja
PRIVATE aDel := {}
PRIVATE aHeader[0]
PRIVATE aBotao:= {}

lAltera:=.F.

FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := CRIAVAR(FIELDNAME(i))
NEXT i                 

M->WC_PER_FOB:=0
M->WC_VLR_ABE:=0

LC100Colunas(aCpos)

//aBOTAO := {}
IF lBROW
   aBotao:={ { "EDIT"    ,{|| LCPGIManu(PO_GI,M->WC_LC_NUM,IF(M->WC_PERVAL=="2",2,1),lAltera)},STR0076,STR0086} , ; //"Inclui Pedido" -  //LRL 13/04/04 -"Inclui"
             { "EXCLUIR" ,{|| LC100DelLin(oGet) } , STR0074 ,STR0087 } } //LRL 13/04/04 -STR0087 "Exclui"
ENDIF
   
IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"INCLUI_BOTAO"),)

DO WHILE .T.
      nOpca := 0
      
      IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"INCLUI_TELA"),)
      
      dbSelectArea("TRB")
      dbGoTop()

      DEFINE MSDIALOG oDlg TITLE cTitulo ;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
          OF oMainWnd PIXEL                 

         aPOS := IF(lBROW,{ 15,  1, nMEIO-1 , (oDlg:nClientWidth-4)/2 },POSDLG(oDLG))
         oEnCh1 := MsMGet():New( cAlias, nReg, nOpc, , , , , aPOS, , 3 )

         IF lBROW
            oGet:= MsSelect():New("TRB",,,aCpos,@lInverte,@cMarca,{nMEIO,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
            oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         ENDIF
         oEnCh1:oBox:Align := iif(lBrow,CONTROL_ALIGN_TOP,CONTROL_ALIGN_ALLCLIENT) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oDlg:lMaximized := .T.
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                                      {||nOpca:=0,oDlg:End()},,aBotao)) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      If nOpcA == 1
         
         lGrvRdmInc:= IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"INCLUI_VALID"),.T.)
         
         lGravaOk:= lGrvRdmInc
         
         If ! lGravaOk
            Loop
         Endif
         
         Begin Transaction
            lGravaOk := LC100Grava(cAlias,cAlias1)
            If !lGravaOk
               Help("", 1, "AVG0003034")//"Não existem registros para a gravação !"###"Informação"
            EndIf
         End Transaction
         
         If ! lGravaOk
            Loop
         Endif
      Endif

      Exit
ENDDO

TRB->(E_EraseArq(cNomArq))
dbSelectArea(cAlias)
Return( nOpcA )
*--------------------------------------------*
Function LC100Alter(cAlias,nReg,nOpc)
*--------------------------------------------*
LOCAL nOpca := 0, i
LOCAL oDlg, cAlias1:="SYH", cNomArq
LOCAL aCpos := {},aPOS
Local lGrvRdmAlt:= .T.

PRIVATE aTELA[0][0],aGETS[0]
PRIVATE nRecnoSWC:=SWC->(RECNO()),SvPO_GI:="2"
PRIVATE nVlr_Emb:=0, CondPagto := SPACE(05), DiasPagto :=0, cTipoCond:= SPACE(01)
PRIVATE Fornecedor:=0, Moeda, cLoja 
PRIVATE aDel   := {}
PRIVATE aBotao := {}
lAltera := .T.

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

FOR i := 1 TO FCount()
   M->&(FieldName(i)) := FieldGet(i)
NEXT i

//M->WC_PER_FOB:=0
//M->WC_VLR_ABE:=0

aHeader:={}
lAltera:=.T.
dbSelectArea(cAlias1)
dbSetOrder(1)
dbSeek(xFilial()+SWC->WC_LC_NUM)


LC100Colunas(aCpos)
LC100GeraTRB(lAltera)

aBOTAO := {}
IF lBROW
   aBotao:={{"EDIT"   ,{|| LCPGIManu(PO_GI,M->WC_LC_NUM,IF(M->WC_PERVAL=="2",2,1),lAltera)},STR0076,STR0086} , ; //"Inclui Pedido" - //LRL 13/04/04 -STR0086 "Inclui"
            {"EXCLUIR",{|| LC100DelLin(oGet) } , STR0074,STR0087 } }//"Exclusao <Del>"  //LRL 13/04/04 -STR0087 -"Exclui"
ENDIF

IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"ALTERA_BOTAO"),)

DO WHILE .T.

      nOpca := 0
      
      IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"ALTERA_TELA"),)
      
      dbSelectArea("TRB")
      dbGoTop()

      DEFINE MSDIALOG oDlg TITLE cTitulo ;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
           OF oMainWnd PIXEL                 

         aPOS := IF(lBROW,{ 15,  1, nMEIO-1 , (oDlg:nClientWidth-4)/2 },POSDLG(oDLG))
         oEnCh1 := MsMGet():New( cAlias, nReg, nOpc, , , , , aPOS, , 3 )

         IF lBROW
            oGet:= MsSelect():New("TRB",,,aCpos,@lInverte,@cMarca,{nMEIO,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
            oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         ENDIF
         oEnCh1:oBox:Align := iif(lBrow, CONTROL_ALIGN_TOP, CONTROL_ALIGN_ALLCLIENT) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oDlg:lMaximized := .T.
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| nOpca:=1,oDlg:End()},;
                                                      {|| nOpca:=0,oDlg:End()},,aBotao)) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      If nOpcA == 1
         
         lGrvRdmAlt:= IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"ALTERA_VALID"),.T.)
         
         lGravaOk:= lGrvRdmAlt
         
         If ! lGravaOk
            Loop
         Endif
         
         Begin Transaction
            lGravaOk := LC100Grava(cAlias,cAlias1)
         End Transaction
         If !lGravaOk
            Help("", 1, "AVG0003034")//"Não existem registros para a gravação !"###"Informação"
            Loop
         EndIf
      Endif

      Exit
ENDDO

TRB->(E_EraseArq(cNomArq))

dbSelectArea(cAlias)

Return( nOpcA )

*-----------------------------------------------------
Function LC100DelLin( oGet )
*-----------------------------------------------------
Private lCalcula := .T.  // PLB 15/12/06

Begin Sequence
   IF TRB->(Eof() .Or. Bof())
      Help("", 1, "AVG0003035")//"Não existe registro selecionado para a exclusão !"###"Atenção"
      Break
   Endif

   IF ! MsgYesNo(STR0015,STR0014) //"Confirma exclusão do registro ?"###"Atenção"
      Break
   Endif

   IIF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"EXEC_CALC_ESTORNO"),)  // PLB 15/12/06

   If lCalcula
      nVlr_Emb-=TRB->WK_VLR_EMB
      M->WC_PER_FOB+=TRB->WC_VLR_ABE
      M->WC_VLR_ABE-=TRB->WC_VLR_ABE
   EndIf
   
   IF TRB->WKRECNO != 0
      aAdd( aDel, TRB->WKRECNO )
   Endif

   TRB->(dbDelete())
   DBSELECTAREA("TRB")
   PACK
   TRB->(dbGotop())

   oGet:oBrowse:Refresh()

   IF TRB->(Eof() .And. Bof())
      LC100LimpaSdo()
   Endif

End Sequence

Return NIL
*----------------------------------------------*
Function LC100Delet(cAlias,nReg,nOpc)
*----------------------------------------------*
LOCAL nOpca := 2, i
LOCAL cAlias1:="SYH", cNomArq
LOCAL oDlg, oGet, bOk,aPOS

PRIVATE aTELA[0][0],aGETS[0]
lAltera:=.F.

PRIVATE nVlr_Emb:=0, CondPagto := SPACE(05), DiasPagto :=0, cTipoCond:= SPACE(01)
PRIVATE Fornecedor:=0, Moeda, cLoja
PRIVATE aBotao := {}

dbSelectArea(cAlias)
IF EasyRecCount(cAlias) == 0
   Return (.T.)
EndIf

FOR i := 1 TO FCount()
    M->&(FIELDNAME(i)) := FieldGet(i)
NEXT

LC100LimpaSdo()

aHeader:={}

aCpos:={}
LC100Colunas(aCpos)
LC100GeraTRB(lAltera)

bOk := {|| nOpcA:=1,IF(MsgNoYes(STR0015,STR0014),oDlg:End(),nOpcA:=0)} //"Confirma exclusão do registro ?"###"Atenção"

IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"EXCLUI_BOTAO"),)

DO While .T.
      dbSelectArea("TRB")
      dbGoTop()
      nOpca := 0

      IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"EXCLUI_TELA"),)
      
      DEFINE MSDIALOG oDlg TITLE cTitulo ;
         FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 ;
         OF oMainWnd PIXEL                 

         aPOS := IF(lBROW,{ 15,  1, nMEIO-1 , (oDlg:nClientWidth-4)/2 },POSDLG(oDLG))
         oEnCh1 := MsMGet():New( cAlias, nReg, nOpc, , , , , aPOS, , 3 )

         IF lBROW
            oGet:= MsSelect():New("TRB",,,aCpos,@lInverte,@cMarca,{nMEIO,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
            oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
         ENDIF
         oEnCh1:oBox:Align := iif(lBrow,CONTROL_ALIGN_TOP,CONTROL_ALIGN_ALLCLIENT) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
         oDlg:lMaximized := .T.
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,{||nOpca:=2,oDlg:End()},,aBotao)) //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      IF nOpcA == 2
         Exit
      ELSEIF nOpcA == 1
         Begin Transaction
            IF lBROW
               dbSelectArea( cAlias1 )
               dbSeek(xFilial()+SWC->WC_LC_NUM)
               DO While !Eof() .And. xFilial("SYH") == SYH->YH_FILIAL  .AND. SWC->WC_LC_NUM == SYH->YH_LC_NUM
                  SYH->(RecLock(cAlias1,.F.))
                  SYH->(dbDelete())
                  SYH->(MSUNLOCK())
                  dbSkip()
               ENDDO
            ENDIF
            dbSelectArea("SWC")
            RecLock("SWC",.F.)
            dbDelete()
            MSUNLOCK()

            dbSelectArea( cAlias1 )
         End Transaction

         Exit
      Endif
ENDDO

TRB->(E_EraseArq(cNomArq))

dbSelectArea(cAlias)

Return( nOpca )

*------------------------------------------------*
Function LC100Grava(cAlias,cAlias1)
*------------------------------------------------*
LOCAL i

dbSelectArea("TRB")

If TRB->( BOF() .AND. EOF() ) .AND. lBROW
   Return .F.
Endif

IF lAltera
   SWC->(DBGOTO(nRecnoSWC))
ENDIF

E_Grava("SWC",!lAltera)

SYH->(DBSETORDER(1))

IF lBROW
   dbSelectArea("TRB")
   TRB->(DBGOTOP())
   DO WHILE ! TRB->(EOF())
      IF TRB->WKRECNO == 0
         SYH->(RecLock(cAlias1,.T.))
         SYH->YH_FILIAL := xFilial("SYH")
      ELSE
         SYH->(dbGoTo(TRB->WKRECNO))
         SYH->(RecLock(cAlias1,.F.))
      ENDIF
      SYH->YH_LC_NUM := M->WC_LC_NUM
      SYH->YH_PO_GI  := TRB->W3_PO_NUM
      SYH->(MSUNLOCK())
      TRB->(DBSKIP())
   ENDDO
   For i:=1 To Len(aDel)
       SYH->(dbGoTo(aDel[i]))
       SYH->(RecLock("SYH",.F.))
       SYH->(dbDelete())
       SYH->(MSUnlock())
   Next
ENDIF

IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"GRAVA_CARTA"),)

SWC->(MSUNLOCK())

Return( .T. )
*-----------------------------------*
FUNCTION LC100GeraTRB(lAltera)
*-----------------------------------*
Processa({|| LC100CreateWork(M->WC_LC_NUM,PO_GI,IF(M->WC_PERVAL=="2",2,1),lAltera)},STR0016) //"Lendo Itens Carta Credito"

RETURN (TRB->(Easyreccount("TRB")) > 0 )

*-------------------------------------------------------------------------*
FUNCTION LC100CreateWork(_CartaCredito,PO_GI,Opcao,PAlteracao,pValor )
*-------------------------------------------------------------------------*
Local totAber := M->WC_VLRCART
SYH->(dbSetOrder(1))
SYH->(DBSEEK(xFilial()+_CartaCredito))
SW4->(dbSetOrder(1))
SW2->(dbSetOrder(1))

DBSELECTAREA("TRB")
AvZap()

ProcRegua(SYH->(Easyreccount("SYH")))
DBSELECTAREA("SYH")

M->WC_PER_FOB := totAber - M->WC_DESPEMB
DO WHILE ! SYH->(EOF()) .and. SYH->YH_FILIAL == xFilial("SYH") .AND. SYH->YH_LC_NUM == _CartaCredito
   IncProc(STR0017) //"Gravando Itens da Carta Credito"
  
   LC100AppendWork(_CartaCredito,PO_GI,SYH->YH_PO_GI,PAlteracao)
   IF PAlteracao
      M->WC_PER_FOB := M->WC_PER_FOB - TRB->WC_VLR_ABE
   ENDIF
   TRB->WKRECNO := SYH->(RECNO())

   SYH->(DBSKIP())
ENDDO
RETURN .T.

*----------------------------------------------------------------*
FUNCTION LC100Critica(Codigo)
*----------------------------------------------------------------*
LOCAL Texto, Letra, Confirma, SvRecno,MInd_PGI,MRec_PGI,MInd_LC,MRec_LC,MRecno
LOCAL oDlg, lProcessa:=.T.

lSair :=.F.      
lValid:=.T.
IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,Codigo),)
IF lSair
   RETURN lValid
ENDIF

DO CASE
   CASE Codigo == "1"
        IF EMPTY( M->WC_LC_NUM )
           Help("", 1, "AVG0003036")//"N£mero da Carta de Cr‚dito NÆo Preenchido
           RETURN .F.
        ENDIF
        IF lAltera
           IF M->WC_LC_NUM <> SWC->WC_LC_NUM
              SvRecno := SWC->(RECNO())
              IF SWC->(DBSEEK(xFilial()+M->WC_LC_NUM))
                 Help("", 1, "AVG0003037")//"Carta de Cr‚dito j  Cadastrada com este n£mero
                 SWC->(DBGOTO(SvRecno))
                 M->WC_LC_NUM:=SWC->WC_LC_NUM
                 RETURN .F.
              ENDIF

              SWC->(DBGOTO(SvRecno))
              Confirma:= MSGYESNO("Confirma Alteracao do Numero da Carta de Credito (S/N)?","CONFIRMA")
              IF Confirma == .F.      //$ 'Nn'
                 M->WC_LC_NUM:=SWC->WC_LC_NUM
                 RETURN .T.
              ENDIF

              SWB->(DBSETORDER(2))
              SWB->(DBSEEK(xFilial()+SWC->WC_LC_NUM))
              Processa({|lEnd|LC100AltCarta()},STR0022) //"Controle de Cƒmbio"
           ENDIF
        ELSE
           IF SWC->(DBSEEK(xFilial()+M->WC_LC_NUM))
              Help("", 1, "AVG0003037")//"Carta de Cr‚dito j  Cadastrada com este N£mero 
              RETURN .F.
           ENDIF
        ENDIF

   CASE Codigo == "2"
        IF EMPTY( M->WC_DT_EMI )
           Help("", 1, "AVG0003038")//"Data de EmissÆo nÆo Preenchida 
           RETURN .F.
        ENDIF

   CASE Codigo == "3"
        IF ! EMPTY( M->WC_DT_VEN )
           IF M->WC_DT_VEN  < M->WC_DT_EMI
	             Help("", 1, "AVG0003039")//"Data de Vencimento ‚ menor que a Data de EmissÆo 
              RETURN .F.
           ENDIF
           IF(!lAltera,M->WC_DT_NEG:=M->WC_DT_VEN,)
        ENDIF

   CASE Codigo == "4"
        IF ! lAltera
           IF ! EMPTY(M->WC_PRORROG)
              Help("", 1, "AVG0003040")//"Aten‡Æo este Campo nÆo poder  ser Preenchido na InclusÆo 
              M->WC_PRORROG :=" "
              RETURN .F.
           ENDIF
        ENDIF
        IF M->WC_PRORROG > "2"
           Help("", 1, "AVG0003041")//"Esta Carta nÆo pode ser Prorrogada por mais de duas vezes
           RETURN .F.
        ENDIF

   CASE Codigo == "5"
        IF EMPTY( M->WC_DT_NEG )
           Help("", 1, "AVG0003042")//"Negocia‡Æo nÆo Preenchida 
           RETURN .F.
        ENDIF

   CASE Codigo == "6"
        IF ! EMPTY( M->WC_DT_VEN ) .AND. EMPTY( M->WC_DT_EMB )
           Help("", 1, "AVG0003043")//"Data de Embarque nÆo Preenchida 
           RETURN .F.
        ENDIF

        IF M->WC_DT_EMB > M->WC_DT_VEN .AND. ! EMPTY( M->WC_DT_VEN )
           Help("", 1, "AVG0003044")//"Data de Embarque nÆo pode ser maior que a data de Vencimento"###"Informa‡Æo"
           RETURN .F.
        ENDIF

   CASE Codigo == "7"
        IF ! EMPTY( M->WC_DT_VEN ) .AND. EMPTY( M->WC_TRANSB )
           Help("", 1, "AVG0003045")//"Transbordo nÆo Preenchido 
           RETURN .F.
        ENDIF

        IF ! M->WC_TRANSB $ cSim+cNao .AND. ! EMPTY( M->WC_DT_VEN )
           Help("", 1, "AVG0003047")//'Transbordo <> "S-Sim" ou "N-NÆo" 
           RETURN .F.
        ENDIF

   CASE Codigo == "8"
        IF ! EMPTY( M->WC_DT_VEN ) .AND. EMPTY( M->WC_EMB_PAR )
           Help("", 1, "AVG0003046")//"Embarque Parcial NÆo Preenchido 
           RETURN .F.
        ENDIF

        IF ! M->WC_EMB_PAR $ cSim+cNao  .AND. ! EMPTY( M->WC_DT_VEN )
           Help("", 1, "AVG0003048")//'Embarque Parcial <> "S-Sim" ou "N-NÆo"
           RETURN .F.
        ENDIF

   CASE Codigo == "9"
        IF EMPTY( M->WC_BANCO ) .AND. ! EMPTY( M->WC_DT_VEN )
           Help("", 1, "AVG0003049")//"Banco nÆo Preenchido 
           RETURN .F.
        ENDIF

        IF ! EMPTY( M->WC_BANCO)//M->WC_DT_VEN 
           IF ! SA6->(DBSEEK(xFilial()+M->WC_BANCO))
              Help("", 1, "AVG0003050")//"Banco nÆo encontrado com este c¢digo
              RETURN .F.
           ENDIF
           M->WC_VM_BANC := SA6->A6_NREDUZ
        ELSE   
           M->WC_VM_BANC := ""
        ENDIF

        lRefresh := .T.

   CASE Codigo == "10"
        IF EMPTY( M->WC_AGENCIA ) .AND. ! EMPTY( M->WC_DT_VEN )
           Help("", 1, "AVG0003051")//"Agˆncia nÆo preenchida 
           RETURN .F.
        ENDIF

        IF ! EMPTY( M->WC_DT_VEN )
           IF ! SA6->(DBSEEK(xFilial()+M->WC_BANCO+M->WC_AGENCIA))
              Help("", 1, "AVG0003052")//"Banco nÆo encontrado com esta Agˆncia 
              RETURN .F.
           ENDIF
           M->WC_VM_BANC := SA6->A6_NREDUZ
           lRefresh := .T.
        ENDIF

   CASE Codigo == "12"
        lIncPo := .T.
        Campo  := IF(PO_GI=="2",M->W3_PO_NUM,M->W5_PGI_NUM)
        Posicao:= PO_GI
        Texto  := IF(PO_GI=="2","P.O.","P.L.I.")
        Letra  := IF(PO_GI=="2","O","A")
        PCarta := M->WC_LC_NUM

        IF EMPTY( Campo )
           MSGINFO(Texto+STR0037+Letra,STR0019) //"NÇO PREENCHID"###"Informa‡Æo"
           RETURN .F.
        ENDIF

        MRecno := TRB->(RECNO())
        IF TRB->(DBSEEK(Campo))
           MSGINFO(Texto+STR0038+Letra,STR0019) //"Jµ CADASTRAD"###"Informa‡Æo"
           TRB->(DBGOTO(MRecno))
           RETURN .F.
        ENDIF
        TRB->(DBGOTO(MRecno))

        SYH->(DBSETORDER(2))
        IF SYH->(DBSEEK(xFilial()+Campo))
           MInd_LC:=SWC->(INDEXORD())
           MRec_LC:=SWC->(RECNO())
           SWC->(DBSETORDER(1))
           IF SWC->(DBSEEK(xFilial()+SYH->YH_LC_NUM)) .And. SWC->WC_LC_NUM != M->WC_LC_NUM
              IF Posicao == "2"//SWC->WC_BASE
                 MSGINFO(Texto+STR0039+Letra+STR0040+TRAN(SWC->WC_LC_NUM,AllTrim(X3Picture("WC_LC_NUM"))),STR0019) //" Jµ CADASTRAD"###" NA CARTA DE CREDITO Nr. "###"Informa‡Æo"
                 SYH->(DBSETORDER(1))
                 SWC->(DBSETORDER(MInd_LC))
                 SWC->(DBGOTO(MRec_LC))
                 RETURN .F.
              ENDIF
           ENDIF

           SYH->(DBSETORDER(1))
           SWC->(DBSETORDER(MInd_LC))
           SWC->(DBGOTO(MRec_LC))
        ENDIF
        SYH->(DBSETORDER(1))

           IF !SW2->(DBSEEK(xFilial()+Campo))
              Help("", 1, "AVG0003053")//"P.O. NÇO CADASTRADO 
              RETURN .F.
           ELSE
              MInd_PGI:=SW5->(INDEXORD())
              MRec_PGI:=SW5->(RECNO())
              SW5->(DBSETORDER(3))
              IF SW5->(DBSEEK(xFilial()+Campo))
                 MAbandona:= .F.
                 Processa({||;
                 SW5->(DBEVAL({ || LC100Ver(SW5->W5_PGI_NUM,PCarta,lProcessa)},;
                              { || SW5->W5_SEQ=0},;
                              { || ! SW5->(EOF()) .AND. SW5->W5_FILIAL == xFilial("SW5") .AND. Campo = SW5->W5_PO_NUM .AND. LC100Ver(SW5->W5_PGI_NUM,PCarta,lProcessa)} ))},STR0042) //"Apurando as LI's"

                 IF MAbandona
                    SW5->(DBSETORDER(MInd_PGI))
                    SW5->(DBGOTO(MRec_PGI))
                    Help("", 1, "AVG0003054")//"ESTE P.O. CONTM P.L.I. EM OUTRA CARTA DE CRDITO
                    RETURN .F.
                 ENDIF
              ENDIF
              SW5->(DBSETORDER(MInd_PGI))
              SW5->(DBGOTO(MRec_PGI))
           ENDIF

           SY6->(DbSetOrder(1))
           SY6->(DbSeek(xFilial("SY6")+SW2->W2_COND_PA))  //TRP-29/04/08
           IF EMPTY(CondPagto) .OR. ( TRB->(BOF()) .AND. TRB->(EOF()) )
              CondPagto := SW2->W2_COND_PA
              DiasPagto := SW2->W2_DIAS_PA
              Moeda     := SW2->W2_MOEDA
              Fornecedor:= SW2->W2_FORN
              IF EICLOJA()
                 cLoja       := SW2->W2_FORLOJ
              ENDIF
              cTipoCond := SY6->Y6_TIPO
           ENDIF

          
           IF (SW2->W2_COND_PA+PADL(SW2->W2_DIAS_PA,3,"0") <> CondPagto+PADL(DiasPagto,3,"0") .AND. M->WC_EMB_PAR $ cNao)   //TRP-29/04/08
              Help("", 1, "AVG0003057")//"CONDI€ÇO DE PAGTO DIFERE DOS REGISTROS Jµ CADASTRADOS 
              RETURN .F.
           ENDIF
           
           IF (M->WC_EMB_PAR $ cSim .AND. SY6->Y6_TIPO <> cTipoCond)  //TRP-29/04/08
              Help("", 1, "AVG0003057")//"CONDI€ÇO DE PAGTO DIFERE DOS REGISTROS Jµ CADASTRADOS 
              RETURN .F.
           ENDIF

        IF SW2->W2_MOEDA <> Moeda
           Help("", 1, "AVG0003058")//"MOEDA DIFERE DOS REGISTROS Jµ CADASTRADOS
           RETURN .F.
        ENDIF

           IF EICLOJA()
              IF SW2->W2_FORN+SW2->W2_FORLOJ <> Fornecedor+cLoja
                 Help("", 1, "AVG0003059")//"FORNECEDOR DIFERE DOS REGISTROS Jµ CADASTRADOS 
                 RETURN .F.
              ENDIF
           ELSE
              IF SW2->W2_FORN <> Fornecedor
                 Help("", 1, "AVG0003059")//"FORNECEDOR DIFERE DOS REGISTROS Jµ CADASTRADOS 
                 RETURN .F.
              ENDIF
           ENDIF
        
           //TDF - 16/07/2011
           IF EICLOJA()
              IF SW2->W2_FORLOJ <> cLoja  // GFP - 07/10/2011
                 MsgInfo("Loja difere dos registros já cadastrados")
                 Return .F.
              ENDIF
           ENDIF
        
        //nFOB_PO:= (SW2->W2_FOB_TOT * (1-(xPerc/100)))//+SW2->W2_INLAND+SW2->W2_FRETEINT+SW2->W2_PACKING-SW2->W2_DESCONTO
        nFOB_PO:= LC100Adiant(SW2->W2_FOB_TOT) + TotalDesp() //TRP-22/07/08

        IF (nFOB_PO+M->WC_VLR_ABE) > (M->WC_VLRCART-M->WC_DESPEMB)
           MSGINFO(STR0083+ALLTRIM(TRANS(nFOB_PO,AVSX3("W2_FOB_TOT",6)))+STR0084,STR0019) //"Informa‡Æo" //"Somado o valor deste Pedido: "###", ultrapassa o Saldo da Carta."
           RETURN .F.
        ENDIF

        lSair :=.F.      
        lValid:=.T.
        IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"VALIDA_PO"),)
        IF lSair
           RETURN lValid
        ENDIF

   CASE Codigo == "14"
        IF !M->WC_PERVAL $ cSim+cNao+",PV"
           Help("", 1, "AVG0003060")//"Codigo Difere de (P)-Percentual (V)-Valor"###"Informa‡Æo"
           RETURN .F.
        ENDIF

   CASE Codigo == "15"
        IF !Positivo(M->WC_VLRCART)
           RETURN .F.
        ENDIF
        IF M->WC_VLRCART < M->WC_VLR_ABE + M->WC_DESPEMB .AND. TRB->(Easyreccount("TRB")) # 0 
           MSGINFO(STR0080,STR0019) //"Vlr Abertura deve ser maior ou igual ao Vlr Pedidos."
           RETURN .F.
        ENDIF
         IF (M->WC_VLRCART - M->WC_DESPEMB - M->WC_VLR_ABE) < 0
            MSGINFO(STR0088,STR0019) //""Valor de abertura deve ser maior que a soma dos pedidos e despesas.""
            RETURN .F.
         ENDIF
        M->WC_PER_FOB:= M->WC_VLRCART - M->WC_DESPEMB - M->WC_VLR_ABE
        lRefresh := .T.
        RETURN .T.

   CASE Codigo == "16"
        IF !Positivo(M->WC_DESPEMB)
           RETURN .F.
        ENDIF

         IF (M->WC_VLRCART - M->WC_DESPEMB - M->WC_VLR_ABE) < 0
            MSGINFO(STR0085,STR0019) //"Valor das despesas ultrapassou o Saldo da Carta."
            RETURN .F.
         ENDIF
         M->WC_PER_FOB := M->WC_VLRCART - M->WC_DESPEMB - M->WC_VLR_ABE 
         lRefresh := .T.
         RETURN .T.


ENDCASE


RETURN .T.

*-------------------------------------------------*
FUNCTION LC100Ver(PCodigo,PCarta,lProcessa)
*-------------------------------------------------*
LOCAL MOrder_Car,MRecno

IF EMPTY(PCodigo)
   RETURN .T.
ENDIF

IF lProcessa
   ProcRegua(SW5->(Easyreccount("SW5")))
   lProcessa:=.F.
ENDIF

IncProc(STR0055) //"Processando Arquivo Li's  - Aguarde..."

MOrder_Car:=SYH->(INDEXORD())
MRecno:=SYH->(RECNO())

SYH->(DBSETORDER(2))
SYH->(DBSEEK(xFilial()+PCodigo))
DO WHILE ! SYH->(EOF()) .AND. SYH->YH_PO_GI = PCodigo .AND. SYH->YH_FILIAL == xFilial("SYH")

   IF PCarta <> SYH->YH_LC_NUM
      SYH->(DBSETORDER(MOrder_Car))
      SYH->(DBGOTO(MRecno))
      MAbandona:=.T.
      SYH->(DBSETORDER(1))
      RETURN .F.
   ELSE
      SYH->(DBSETORDER(MOrder_Car))
      SYH->(DBGOTO(MRecno))
      SYH->(DBSETORDER(1))
      RETURN .T.
   ENDIF
   SYH->(DBSKIP())
ENDDO

SYH->(DBSETORDER(MOrder_Car))
SYH->(DBGOTO(MRecno))
SYH->(DBSETORDER(1))
RETURN .T.

*-------------------------------------------------------------------------*
FUNCTION LC100AltCarta()
*-------------------------------------------------------------------------*
LOCAL SvRecno
ProcRegua(SWB->(Easyreccount("SWB")))

DO WHILE ! SWB->(EOF()) .AND. SWB->WB_LC_NUM == SWC->WC_LC_NUM .AND. SWB->WB_FILIAL == xFilial("SWB")
   IncProc(STR0057+STR(SWB->(RECNO()),5)) //"Processando Registro "
  SWB->(DBSKIP())
  SvRecno := SWB->(RECNO())
  SWB->(DBSKIP(-1))
  RecLock("SWB",.F.)
  SWB->WB_LC_NUM := M->WC_LC_NUM
  SWB->(MsUnlock())
  SWB->(DBGOTO(SvRecno))
ENDDO

ProcRegua(SYH->(Easyreccount("SYH")))
SYH->(DBSEEK(xFilial()+SWC->WC_LC_NUM))
DO WHILE ! SYH->(EOF()) .AND. SYH->YH_LC_NUM==SWC->WC_LC_NUM .AND. SYH->YH_FILIAL == xFilial("SYH")
  IncProc(STR0057) //"Processando Registro"
  SYH->(DBSKIP())
  SvRecno := SYH->(RECNO())
  SYH->(DBSKIP(-1))
  RecLock("SYH",.F.)
  SYH->YH_LC_NUM :=M->WC_LC_NUM
  SYH->(MsUnlock())
  SYH->(DBGOTO(SvRecno))
ENDDO

RecLock("SWC",.F.)
SWC->WC_LC_NUM := M->WC_LC_NUM
SWC->(MsUnlock())
RETURN NIL

*--------------------------------------------------------*
FUNCTION LCPGIManu(cPO_GI,CartaCredito,Opcao,PAlteracao)
*--------------------------------------------------------*
LOCAL  Texto := IF(cPO_GI=="2",STR0058,STR0059), ; //"P.O. "###"P.L.I. "
      _Pgi_Num := CRIAVAR("W5_PGI_NUM"),_Po_Num := CRIAVAR("W2_PO_NUM"), nOpca:=0      

LOCAL bConfirma:={||IF(PO_GI=="2",M->W3_PO_NUM:=_Po_Num,M->W5_PGI_NUM:=_Pgi_Num),;
                     LC100Critica("12")}

IF EMPTY( M->WC_LC_NUM )
   Help("", 1, "AVG0003036")//"N£mero da Carta de Cr‚dito NÆo Preenchido 
   RETURN .F.
ENDIF

PO_GI := cPO_GI

IF Opcao == NIL
   Opcao:=IF(M->WC_PERVAL=="2",2,1)
ENDIF
/* ISS - 27/03/10 - Alteração no tamanho da tela para que a mesma não corte o botão "Confirmar".
DEFINE MSDIALOG oDlg TITLE cCadastro+STR0081 From 9,0 To 18,45 OF oMAINWND //" - Proforma" */
DEFINE MSDIALOG oDlg TITLE cCadastro+STR0081 From 9,0 To 23,50 OF oMAINWND //" - Proforma"
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
   
   @ 2.0,0.8 SAY Texto OF oPanel
   @ 2.0,6.5 MSGET _Po_Num F3 "SW2"  PICT AllTrim(X3Picture("W2_PO_NUM")) SIZE 70,8 OF oPanel HASBUTTON

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||nOpca:=1,IF(EVAL(bConfirma),oDlg:End(),nOpca:=0)},;
                          {||nOpca:=0,oDlg:End()}) CENTERED

IF nOpca== 0
   RETURN .F.
ENDIF

LC100AppendWork(CartaCredito,PO_GI,M->W3_PO_NUM,PAlteracao)
oGet:oBrowse:GoBottom()
oGet:oBrowse:Refresh()

RETURN .T.

*--------------------------------------------------------------------*
FUNCTION LC100AppendWork(_CartaCredito,PO_GI,cPedido,PAlteracao,pValor)
*--------------------------------------------------------------------*
LOCAL MVlr_Fob:=0, MMoeda := SPACE(03), OldRecLp := SYH->(RECNO())
LOCAL nOrder := SYH->(IndexOrd()),nVlrEmbarcado:=0
LOCAL cFilSW7 := xFilial("SW7"), i
LOCAL xFilSA2:=xFilial("SA2")
LOCAL xFilSWB:=xFilial("SWB")
LOCAL xFilSW7:=xFilial("SW7")
LOCAL xFilSW8:=xFilial("SW8")
LOCAL xFilSW9:=xFilial("SW9")

SW5->(DBSETORDER(3))
SW7->(DBSETORDER(2))//Pedido + Processo
SY6->(DbSetOrder(1))
SW2->(DBSEEK(xFilial()+cPedido))
SY6->(DbSeek(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))  //TRP-29/04/08

MVlr_Fob:=LC100Adiant(SW2->W2_FOB_TOT + TotalDesp())//SW2->W2_INLAND+SW2->W2_FRETEINT+SW2->W2_PACKING-SW2->W2_DESCONTO

IF SW7->(DBSEEK(xFilial()+SW2->W2_PO_NUM))

   //bSdoPO := {|| nVlrEmbarcado+= (SW7->W7_SALDO_Q*SW7->W7_PRECO)}
   bSdoPO := {|| nVlrEmbarcado+= LC100Adiant(SW7->W7_SALDO_Q*SW7->W7_PRECO)}  //TRP-22/07/08

   SW7->(DBEVAL(bSdoPO,,;
               { || SW7->W7_PO_NUM == SW2->W2_PO_NUM .AND.;
                    SW7->W7_FILIAL == cFilSW7 }))

ENDIF    

TRB->(dbAppend())
TRB->W3_PO_NUM  :=cPedido
TRB->W2_COND_PA :=SW2->W2_COND_PA
TRB->W2_DIAS_PA :=SW2->W2_DIAS_PA
TRB->WB_PGTANT  :=(SW2->W2_FOB_TOT + TotalDesp()) - MVlr_Fob
TRB->TRB_DESCPG :=EasyMSMM(SY6->Y6_DESC_P,48)
TRB->W4_PGI_DT  :=SW2->W2_PO_DT
TRB->WC_VLR_ABE :=MVlr_Fob
TRB->WC_PER_FOB :=LC100Adiant(SW2->W2_FOB_TOT - nVlrEmbarcado)
TRB->WK_VLR_EMB :=nVlrEmbarcado
TRB->W4_INLAND  :=SW2->W2_INLAND
TRB->W4_PACKING :=SW2->W2_PACKING
TRB->W4_FRETEINT:=SW2->W2_FRETEIN
TRB->W4_DESCONTO:=SW2->W2_DESCONT
TRB->W2_OUT_DES := SW2->W2_OUT_DES
TRB->W5_PGI_NUM := IF(SW5->(DBSEEK(xFilial()+cPedido)),SW5->W5_PGI_NUM,' ')
IF ! GI_TEM_ASTERISCO
   SWP->(DBSEEK(xFilial()+SW5->W5_PGI_NUM))
   TRB->WP_REGIST := SWP->WP_REGIST
ENDIF
TRB->TRB_ALI_WT:= "SW2"
TRB->TRB_REC_WT:= SW2->(Recno())


CondPagto := SW2->W2_COND_PA
DiasPagto := SW2->W2_DIAS_PA
Fornecedor:= SW2->W2_FORN     
IF EICLOJA()
   cLoja      := SW2->W2_FORLOJ
ENDIF
Moeda     := SW2->W2_MOEDA
cTipoCond := SY6->Y6_TIPO

nVlrSemBaixa:=0

IF cPaisLoc=="CHI" .AND. EasyGParam("MV_EASYFIN",,"N") $ cSim
   SW7->(DBSETORDER(2))   
   IF SW7->(DBSEEK(xFilSW7+TRB->W3_PO_NUM))
      bGrava:={||IF(ASCAN(aHawb,SW7->W7_HAWB)==0,AADD(aHawb,SW7->W7_HAWB),)}
      bWhile:={||SW7->W7_FILIAL==xFilSW7 .AND. SW7->W7_PO_NUM==TRB->W3_PO_NUM}       
      SW7->(DBEVAL(bGrava,,bWhile))
   ENDIF                  

   SW8->(DBSETORDER(3))
   SW9->(DBSETORDER(1))

   FOR i:=1 TO LEN(aHawb)     
      aTitulo:={}
      
      IF SW8->(DBSEEK(xFilSW8+aHawb[i]+TRB->W5_PGI_NUM+TRB->W3_PO_NUM))
         //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
         bGrava:={||SW9->(DBSEEK(xFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ")+SW8->W8_HAWB)),;
                    SA2->(DBSEEK(xFilSA2+SW8->W8_FORN+EICRetLoja("SW8","W8_FORLOJ"))),;
                    IF(ASCAN(aTitulo,{|a|a[1]=SW9->W9_INVOICE.AND.a[2]=SW9->W9_FORN .AND. (!EICLOJA() .OR. a[3]=SA2->A2_LOJA) })==0,;
                    AADD(aTitulo,{SW9->W9_INVOICE,SW9->W9_FORN,SA2->A2_LOJA,SW9->W9_NUM}),)}
         SW8->(DBEVAL(bGrava,,{||SW8->W8_FILIAL==xFilSW8.AND.;
                                 SW8->W8_HAWB==aHawb[i] .AND.;
                                 SW8->W8_PGI_NUM==TRB->W5_PGI_NUM .AND.;
                                 SW8->W8_PO_NUM ==TRB->W3_PO_NUM}))
      ENDIF      

      IF lCposAdto
         cChavSWB := xFilSWB + aHawb[i] + "D"
         bWhilSWB := {|| SWB->WB_FILIAL==xFilSWB .AND. SWB->WB_HAWB ==aHawb[i] ;
                                                 .AND. SWB->WB_PO_DI=="D" }
      ELSE
         cChavSWB := xFilSWB + aHawb[i] 
         bWhilSWB := {|| SWB->WB_FILIAL==xFilSWB .AND. SWB->WB_HAWB ==aHawb[i] }                    
      ENDIF
      
      IF SWB->(DBSEEK(cChavSWB))
      
         Do WHILE SWB->(!EOF()) .AND. EVAL(bWhilSWB)
            lBaixa:=.F.
            IF (N:=ASCAN(aTitulo,{|a|a[1]=SWB->WB_INVOICE.AND.a[4]=SWB->WB_NUMDUP})) # 0
               IF !FI400ParcBaixada("EIC",SWB->WB_NUMDUP,"INV",aTitulo[N,2],aTitulo[N,3],SWB->WB_PARCELA)
                  nVlrSemBaixa+=SWB->WB_FOBMOE
               ENDIF
            ENDIF
           SWB->(DBSKIP())               
         ENDDO
      ENDIF      
   
   NEXT      

ENDIF

nVlr_Emb+=TRB->WK_VLR_EMB

IF !PAlteracao .OR. lIncPo
   
//   M->WC_PER_FOB-=TRB->WK_VLR_EMB
   M->WC_VLR_ABE+=TRB->WC_VLR_ABE
   M->WC_PER_FOB := M->WC_VLRCART - M->WC_DESPEMB - M->WC_VLR_ABE
   lIncPo := .F.
ENDIF

SW8->(DBSETORDER(1))
SW7->(DBSETORDER(1))


IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"GRAVA_TRB"),)

RETURN .T.

*-----------------------*
Function LC100LimpaSdo()
*-----------------------*
nVlr_Emb:=0
CondPagto:= SPACE(05)
DiasPagto:=0
Fornecedor:=0
Moeda:=SPACE(03)
cTipoCond:=SPACE(01)
cLoja:= SPACE(2)

//M->WC_PER_FOB:=M->WC_PER_FOB - M->WC_DESPEMB
M->WC_VLR_ABE:=0

RETURN NIL

*-------------------*
FUNCTION LCPgiZoom()
*-------------------*
LOCAL _PictPGI := ALLTRIM(X3Picture("W4_PGI_NUM")), oCbx
LOCAL PO_GI:="1"//SWC->WC_BASE
LOCAL TB_PoGi:={},Col, lCodigo, MMsg:=IF(PO_GI=="1",STR0064,; //"NAO EXISTEM MAIS P.O.s P/ ESTE P.L.I "
                                                   STR0065) //"NAO EXISTEM MAIS L.I.s P/ ESTE P.O. "

IF TRB->(Easyreccount("TRB")) <= 0
   Help("", 1, "AVG0003062")//"NÇO EXISTEM REGISTROS PARA O ZOOM 
   RETURN .F.
ENDIF

//Order  := IF( PO_GI=="1", 1, 2 ) --ACB 13/03/2010
Codigo := IF( PO_GI=="1", TRB->W5_PGI_NUM, TRB->W3_PO_NUM )

//SW5->(DBSETORDER(order)) --ACB 13/03/2010
SW5->(DBSETORDER(1))   //ACB - 13/03/2010
SW5->(DBSEEK(xFilial()+Codigo))   

DO WHILE ! SW5->(EOF()) .AND. IF(PO_GI=="1",LEFT(SW5->W5_PGI_NUM,10),SW5->W5_PO_NUM)==Codigo .AND. SW5->W5_FILIAL == xFilial("SW5")  

    IF SWP->( DBSEEK( xFilial()+SW5->W5_PGI_NUM ))

       DO WHILE ! SWP->( EOF() ) .AND. SWP->WP_FILIAL == xFilial("SWP") .AND. SWP->WP_PGI_NUM = SW5->W5_PGI_NUM

          lCodigo := TRANS( SW5->W5_PGI_NUM, '@R !!/!!!!!!!-!' )   //ACB - 13/03/2010

          IF ASCAN(TB_PoGi,lCodigo) == 0
             AADD(TB_PoGi,lCodigo)
          ENDIF
          SWP->( DBSKIP() )
       ENDDO

    ENDIF
    SW5->(DBSKIP())

ENDDO

SW5->(DBSETORDER(1)) 

IF LEN(TB_PoGi) <= 0
   Help("", 1, "AVG0003062")//"NÇO EXISTEM REGISTROS PARA O ZOOM
   RETURN .T.
ENDIF

DEFINE MSDIALOG oDlg TITLE cCadastro+STR0067 From 9,0 To 18,40 OF oMAINWND //' -  Zoom'

@ 2,2.5 SAY STR0068 //"Li's"
@ 2,5.5 COMBOBOX oCbx ITEMS TB_POGi OF oDlg SIZE 70,30
ACTIVATE MSDIALOG oDlg ON INIT ;
     EnchoiceBar(oDlg,{||oDlg:End()},;
                      {||oDlg:End()}) CENTERED

RETURN .T.

*----------------------------------------------------------------------*
FUNCTION LC100Colunas(aCpos)//AWR 27/12/01
*----------------------------------------------------------------------*
Local i

IF(EasyEntryPoint("EICLC100"),Execblock("EICLC100",.F.,.F.,"COLUNAS"),)

cNomArq:=E_CriaTrab(,aSemSX3)
IndRegua("TRB",cNomArq+TEOrdBagExt(),"W3_PO_NUM")

For i:=1 to Len(aHeader)
   IF aScan(aCampos,aHeader[i][2]) == 0
      Loop
   Endif
   IF aHeader[I][2] == "W4_PGI_DT"
      aHeader[I][1] := STR0008 //"Data da L.I"
   ENDIF
   IF aHeader[I][2] == "WC_PER_FOB"
      aHeader[I][1] := STR0075 //"Saldo Pedido"
      AADD( aCpos, { "WK_VLR_EMB",,STR0082,AVSX3("WC_VLR_ABE",6) } ) //"Vl. Embarcado"
   ENDIF

   AADD( aCpos, { aHeader[i][2],,aHeader[i][1],aHeader[i][3] } )

   IF aHeader[I][2] == "W2_DIAS_PA" // Acrescenta a descrição depois dos dias da condição de pagamento
      AADD( aCpos, { "TRB_DESCPG",,"Descr. Pagto",AVSX3("Y6_DESC_P",AV_TAMANHO) } )
   ENDIF
Next

RETURN .T.

//TRP-22/07/08- Função responsável pelo Tratamento do Valor FOB, retirando os adiantamentos realizados. 
*---------------------------------------*
Static Function LC100Adiant(nFOB)
*---------------------------------------*
LOCAL Wind, _Dias, _Perc  
LOCAL xPerc:=0   
LOCAL nValor:=0

IF SY6->(DBSEEK(xFilial("SY6")+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))
   IF SY6->Y6_DIAS_PA >= 900
      xPerc := 0
      FOR Wind := 1 TO 10

         _Dias := "Y6_DIAS_" + STRZERO(Wind,2) 
         _Dias := SY6->(FIELDGET( FIELDPOS(_Dias) ))
         _Perc := "Y6_PERC_" + STRZERO(Wind,2) 
         _Perc := SY6->(FIELDGET( FIELDPOS(_Perc) ))

         IF _Dias < 0
            xPerc+=_Perc
         ENDIF
      NEXT
   ENDIF
ENDIF

nValor:= (nFOB * (1-(xPerc/100)))

Return nValor

/*
Funcao      : TotalDesp
Parametros  : Nenhum
Retorno     : nTotal - Total do PO
Objetivos   : Verifica o valor total do PO com base no Incoterm
Autor       : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora   : 03/12/2020
*/
Static Function TotalDesp()
Local nTotal:= 0
Local nDesp := 0
   
IF SW2->W2_FREINC $ cNao .And. AvRetInco(SW2->W2_INCOTER,"CONTEM_FRETE")
   nDesp += SW2->W2_FRETEIN
EndIf
IF AvFlags("RATEIO_DESP_PO_PLI") .And. SW2->W2_SEGINC $ cNao .And. AvRetInco(SW2->W2_INCOTER,"CONTEM_SEG")
   nDesp += SW2->W2_SEGURIN
EndIf

nTotal := SW2->(W2_INLAND+W2_PACKING+W2_OUT_DES-W2_DESCONT) + nDesp

Return nTotal
//-------------------------------------------------------------------------------//
//                          FIM DO PROGRAMA EICLC100.PRW
//-------------------------------------------------------------------------------//
