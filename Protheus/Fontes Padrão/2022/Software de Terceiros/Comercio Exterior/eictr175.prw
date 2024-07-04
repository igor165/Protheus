#Include "Eictr175.ch"
//#INCLUDE "FiveWin.ch"
#Include "Average.ch"
#Include "AvPrint.ch"
#Define ENTER CHR(13)+CHR(10)    

Static MARCA:= "3"
Static ATUAL:= "4"  
Static CAPA:= "7"
//CCH - 15/05/09 - DefiniÁ„o do Status dos Itens do PO
Static EMB_TOT := "Embarcado"
Static EMB_PAR := "Parcial"
Static NAO_EMB := "N„o Embarcado"                                                               


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ EICTR175 ≥ Autor ≥ AVERAGE/ALEX WALLAUER ≥ Data ≥ 12/11/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Acerto de P.O.s                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAEIC                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
*------------------*
Function EICTR175()
*------------------*
LOCAL nOldArea:=SELECT()
IF EasyGParam("MV_EIC_EAI",,.F.)          
   MSGALERT(STR0246) //"Funcionalidade n„o disponÌvel para este cen·rio de negÛcio."
   RETURN NIL
ENDIF
PRIVATE TPO_NUM:=SPACE(LEN(SW2->W2_PO_NUM)), MTotal:=0
PRIVATE cTitulo:=OemtoAnsi(STR0001) //"Acerto de P.O."
PRIVATE cProg:="PO"// OS.:0122/02 SO.:0021/02 FCD
PRIVATE cPicINLAND  :=ALLTRIM(X3PICTURE("W2_INLAND" ))
PRIVATE cPicDESCONTO:=ALLTRIM(X3PICTURE("W2_DESCONT"))
PRIVATE cPicPACKING :=ALLTRIM(X3PICTURE("W2_PACKING"))
PRIVATE cPicFRETEINT:=ALLTRIM(X3PICTURE("W2_FRETEIN"))
PRIVATE cPicQTDE    :=ALLTRIM(X3PICTURE("W3_QTDE"   ))
PRIVATE cPicSALDO_Q :=ALLTRIM(X3PICTURE("W3_SALDO_Q"))
PRIVATE cPicPRECO   :=ALLTRIM(X3PICTURE("W3_PRECO"  ))
PRIVATE cPicTOTAL   :="@E 9,999,999,999,999.99"

PRIVATE cFilSW0:=xFilial("SW0"), cFilSW1:=xFilial("SW1")
PRIVATE cFilSW2:=xFilial("SW2"), cFilSW3:=xFilial("SW3")
PRIVATE cFilSW4:=xFilial("SW4"), cFilSW5:=xFilial("SW5")
PRIVATE cFilSW6:=xFilial("SW6"), cFilSW7:=xFilial("SW7")      
PRIVATE cFilSW8:=xFilial("SW8"), cFilSW9:=xFilial("SW9")
PRIVATE cFilSWE:=xFilial("SWE"), cFilSA2:=xFilial("SA2")
PRIVATE cFilSA5:=xFilial("SA5")
PRIVATE aHeader[0], aCampos:={}, cMarca:=GetMark()//FDR - 27/06/13
//VARIAVEIS PARA A NEC AWR 20/02/1999
PRIVATE cArqRdmake:= "EICAPNEC"
PRIVATE WorkNTX   := NIL
PRIVATE lNec      := EasyEntryPoint(cArqRdmake)
Private lAltPo:= .T.
Private aSemSx3 //Passei para Private para utilizar no rdmake FCD
Private lAltDtEntr:= .F.
PRIVATE lCposAdto :=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
Private lEic_Eco := Alltrim(EasyGParam("MV_EIC_ECO",,"N"))=="S" .and. ChkFile("EC2",.F.)

// ISS - 03/02/10 - Vari·veis para guardar o fornecedor e a loja anteriores quando houver alteraÁ„o, para poder cancelar os tÌtulos.
Private cOldForn := ""
Private cOldLoja := ""
//ISS - 13/12/10 - Vari·vel necess·ria para validar a existencia de geraÁ„o de nota fiscal de despesa no sistema.
PRIVATE lCposNFDesp := (SWD->(FIELDPOS("WD_B1_COD")) # 0 .And. SWD->(FIELDPOS("WD_DOC")) # 0 .And. SWD->(FIELDPOS("WD_SERIE")) # 0;                   //NCF - Campos da Nota Fiscal de Despesas
                       .And. SWD->(FIELDPOS("WD_ESPECIE")) # 0 .And. SWD->(FIELDPOS("WD_EMISSAO")) # 0 .AND. SWD->(FIELDPOS("WD_B1_QTDE")) # 0;
                       .And. SWD->(FIELDPOS("WD_TIPONFD")) # 0)
//ISS - 13/04/11 - arrays que usados para no ExecAuto
PRIVATE cMV_EASY := EasyGParam("MV_EASY")
Private aCab  := {}
Private aItem := {}
Private lEXECAUTO_COM := /*EasyGParam("MV_EIC0008",,.F.) FIXO .T. OSSME-6437 MFR 06/12/2021.And. */ cMV_EASY $ cSim
Private lAlcada := EasyGParam("MV_AVG0170",,.F.)
Private lCpoCtCust := (EasyGParam("MV_EASY")$cSim) .And. SW3->(FIELDPOS("W3_CTCUSTO")) > 0
Private cCentroCusto := ""

AADD(aCampos,"W3_POSICAO")
AADD(aCampos,"W3_COD_I" )
AADD(aCampos,"W3_PO_NUM")

aSemSx3:={{ "WK_HORA"   ,"C",08,0 },;
          { "WK_DE"     ,"C",80,0 },;
          { "WK_DATA"   ,"D",08,0 },;
          { "WK_PARA"   ,"C",80,0 },;
          { "WK_CAMPO"  ,"C",21,0 }}

cArqImp:=E_CriaTrab(,aSemSx3,"WorkImp")

aCampos:={}

AADD(aCampos,"W2_DIAS_PA")
AADD(aCampos,"W2_COND_PA")
AADD(aCampos,"W2_INCOTER")
AADD(aCampos,"W0__POLE"  )
AADD(aCampos,"W1_CLASS"  )
AADD(aCampos,"W3_COD_I"  )
AADD(aCampos,"W3_FABR_01")
AADD(aCampos,"W3_FABR_03")
AADD(aCampos,"W3_FABR_05")
AADD(aCampos,"W3_REG"    )
AADD(aCampos,"W3_QTDE"   )
AADD(aCampos,"W3_SALDO_Q")
AADD(aCampos,"W3_CC"     )
AADD(aCampos,"W3_DT_EMB" )
AADD(aCampos,"W3_DT_ENTR")
AADD(aCampos,"W3_FABR"   )
AADD(aCampos,"W3_FABR_02")
AADD(aCampos,"W3_FABR_04")
AADD(aCampos,"W3_FORN"   )
AADD(aCampos,"W3_SEQ"    )
AADD(aCampos,"W3_PRECO"  )
AADD(aCampos,"W3_SI_NUM" )
AADD(aCampos,"W3_POSICAO")
AADD(aCampos,"A5_CODPRF" )
AADD(aCampos,"W3_PO_NUM" )

//MCF - 23/12/2015
MSGINFO(STR0247,STR0244) // "A rotina Acerto de P.O foi descontinuada, porÈm, a rotina de ManuntenÁ„o de Purchase Order
RETURN NIL               //j· esta adaptada para realizar o mesmo procedimento. Acesse a rotina em AtualizaÁıes/Purchase Order/ManutenÁ„o.,Aviso"

aSemSx3:={{ "WKDESCR"   ,"C",26,0 },;
          { "W3_FLUXO"  ,"C",01,0 },;//Este campo eh nao usado no obrigat
          { "WKRECNO"   ,"N",06,0 },;
          { "WKTEM_PLI" ,"C",01,0 },;
          { "WK_FLAG"   ,"C",02,0 },;//FDR - 28/07/13
          { "WKSTATUS"  ,"C",15,0 }} //CCH - 15/05/09 - Status do Item 
          
IF EasyEntryPoint("EICTR175")
   Execblock("EICTR175",.F.,.F.,"CRIA_WORK")   
ENDIF
        
cNomArq:=E_CriaTrab(,aSemSx3,"Work")

IndRegua("Work",cNomArq+TEOrdBagExt(),"W3_CC+W3_SI_NUM+W3_COD_I+W3_FABR+STR(W3_REG,"+Alltrim(STR(AVSX3("W3_REG",3)))+",0)")

IF lNec
   nExecute:="1"
   ExecBlock(cArqRdmake,.F.,.F.)
ENDIF

DO WHILE .T.                                               

   DBSELECTAREA("SW2")
   nOpca:= 0
   lPO_DA:=.F.

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM  9,0 TO 22,50  OF  oMainWnd
   
     oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
     oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

     @ /*2.5*/1.25, 1.0  SAY OemToAnsi( STR0002 ) OF oPanel //"Nß do P.O."    // GFP - 09/01/2013

     @ /*2.5*/1.25, 6.0  MSGET TPO_NUM F3 "SW2" PICT "@!" SIZE 60,8 OF oPanel // GFP - 09/01/2013

   ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||IF(TR175Val("PO"),(nOpca:=1,oDlg:End()),)},;
                             {|| nOpca:=0,oDlg:End()}) CENTERED
   IF nOpca = 0
      EXIT
   ELSEIF CHECKDI() .And. TR175Tela()
      LOOP
   ENDIF

   EXIT

ENDDO

Work->(E_EraseArq(cNomArq,cNomArq,WorkNTX))
WorkImp->(E_EraseArq(cArqImp))
SW8->(DBSETORDER(1))
SA5->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SW3->(DBSETORDER(1))
SW5->(DBSETORDER(1))
SW7->(DBSETORDER(1))
DBSELECTAREA(nOldArea)
RETURN NIL

*----------------------------------------------------------------------------*
FUNCTION TR175Val(PTipo,cCampo)
*----------------------------------------------------------------------------*
LOCAL MTotFob := 0, nRecno

DO CASE
   CASE PTipo == "PO"

        IF EMPTY( TPO_NUM )
           HELP("",1,"AVG0000607") //N£mero do Pedido n∆o preenchido
           RETURN .F.
        ENDIF

        IF !SW2->(DBSEEK(cFilSW2+TPO_NUM))
           HELP("",1,"AVG0000610") //N£mero do Pedido n∆o cadastrado
           RETURN .F.
        ENDIF

        SW3->(DBSETORDER(1))
        IF !SW3->(DBSEEK(cFilSW3+TPO_NUM))
           HELP("",1,"AVG0000613") //Pedido n∆o possui itens
           RETURN .F.
        ENDIF
        If !Empty(SW2->W2_HAWB_DA)//OS.:0122/02 SO.:0021/02 FCD
           cProg := "PN"
           lPO_DA:=.T.
        Endif
        nOpca:=1
        oDlg:End()

   CASE PTipo == "Class"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0000615") //Classificaá∆o n∆o preenchida
           RETURN .F.
        ENDIF

        IF EMPTY(TR175SX5(cCampo))
           HELP("",1,"AVG0000617") //Classificaá∆o n∆o cadastrada na tabela
           RETURN .F.
        ENDIF

   CASE PTipo == "Embar"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0000619") //Data de Embarque n∆o preenchida
           RETURN .F.
        ENDIF

   CASE PTipo == "Entre"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0000656") //Data de Entrega n∆o preenchida
           RETURN .F.
        ENDIF
        
        IF cCampo < WORK->W3_DT_EMB
           HELP("", 1, "AVG0000366")//'Data de entrega deve ser maior ou igual que a data de embarque'###"AtenÁ„o"
           RETURN .F.
        ENDIF   

   CASE PTipo == "Preco"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0002000") //Preáo Unit†rio n∆o preenchido
           RETURN .F.
        ENDIF

        IF cCampo < 0
           HELP("",1,"AVG0002001") //Preáo Unit†rio Negativo
           RETURN .F.
        ENDIF

   CASE PTipo == "PN"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0002002") //Part Number n∆o preenchido
           RETURN .F.
        ENDIF

   CASE PTipo == "CP"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0002003") //Condiá∆o de Pagamento n∆o preenchido
           RETURN .F.
        ENDIF

        IF !SY6->(DBSEEK(xFilial()+cCampo))
           HELP("",1,"AVG0002004") //Condiá∆o de Pagamento n∆o Cadastrada
           RETURN .F.
        ENDIF

        /*ISS - 26/04/11 - ValidaÁ„o para n„o permitir o uso de uma condiÁ„o de pagamento que n„o tenha
                           uma cond. de pag siga vinculada */
        If EasyGParam("MV_EASY",,"N") == "S"
           If Empty(SY6->Y6_SIGSE4)
              MsgInfo(STR0245,STR0244) //CondiÁ„o de pagamento n„o possui uma condiÁ„o de pagamento SIGA vinculada./Aviso
              Return .F.
           EndIf
        EndIf                              

        cCampo2 := SY6->Y6_DIAS_PA
        oCampo2:Refresh()


   CASE PTipo == "DIA"

        IF !SY6->(DBSEEK(xFilial()+cCampo))
           HELP("",1,"AVG0002005") //Dias de Pagamento n∆o Cadastrado
        ENDIF

   CASE PTipo == "IN"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0002006") //Incoterms n∆o preenchido
           RETURN .F.
        ENDIF

        IF !SYJ->(DBSEEK(xFilial()+cCampo))
           HELP("",1,"AVG0002007") //Incoterms n∆o Cadastrada
           RETURN .F.
        ENDIF

   CASE PTipo == "INLAND"

        IF cCampo < 0
           HELP("",1,"AVG0002008") //Valor de Inland charge n∆o pode ser negativo
           RETURN .F.
        ENDIF
        MTotFOB := SW2->W2_FOB_TOT + cCampo + IF(SW2->W2_FREPPCC=="PP",SW2->W2_FRETEIN,0) + SW2->W2_PACKING - SW2->W2_DESCONT
        IF MTotFOB <= 0
           HELP("",1,"AVG0002009",,IF(SW2->W2_FREPPCC=="PP","+ FRETE ","")+STR0021,2,1) //O Total do PO: FOB + INLAND + PACKING "###"- DESCONTO n∆o pode ser negativo
           RETURN .F.
        ENDIF

   CASE PTipo == "PACK"

        IF cCampo < 0
           HELP("",1,"AVG0002010") //Valor de Packing charge n∆o pode ser negativo
           RETURN .F.
        ENDIF
        MTotFOB := SW2->W2_FOB_TOT + SW2->W2_INLAND + IF(SW2->W2_FREPPCC=="PP",SW2->W2_FRETEIN,0) + cCampo - SW2->W2_DESCONT
        IF MTotFOB <= 0
            HELP("",1,"AVG0002009",,IF(SW2->W2_FREPPCC=="PP","+ FRETE ","")+STR0021,2,1) //O Total do PO: FOB + INLAND + PACKING "###"- DESCONTO n∆o pode ser negativo
           RETURN .F.
        ENDIF

   CASE PTipo == "DESC"

        IF cCampo < 0
           HELP("",1,"AVG0002011") //Valor do Desconto n∆o pode ser negativo
           RETURN .F.
        ENDIF
        MTotFOB := SW2->W2_FOB_TOT + SW2->W2_INLAND + IF(SW2->W2_FREPPCC=="PP",SW2->W2_FRETEIN,0) + SW2->W2_PACKING - cCampo
        IF MTotFOB <= 0
           HELP("",1,"AVG0002012",,IF(SW2->W2_FREPPCC=="PP","+ FRETE ","")+STR0021,2,1) //Desconto n∆o pode ser maior que FOB + INLAND + PACKING "###"
           RETURN .F.
        ENDIF

   CASE PTipo == "FRETE"

        IF cCampo < 0
           HELP("",1,"AVG0002013") //Frete Internacional n∆o pode ser negativo
           RETURN .F.
        ENDIF
        MTotFOB := SW2->W2_FOB_TOT + SW2->W2_INLAND + cCampo + SW2->W2_PACKING - SW2->W2_DESCONT
        IF MTotFOB <= 0
           HELP("",1,"AVG0002014") //O Total Pedido: FOB + INLAND + PACKING + FRETE - DESCONTO n∆o pode ser negativo
           RETURN .F.
        ENDIF

   CASE PTipo == "SQ"

        IF cCampo < 0
           HELP("",1,"AVG0002015") //Saldo de Quantidade da P.L.I. n∆o pode ser negativo
           RETURN .F.
        ENDIF

        IF cCampo = 0
           IF WorkPgi->W3_SALDO_Q == WorkPgi->W3_QTDE
              HELP("",1,"AVG0002016") //Saldo de Quantidade da P.L.I. n∆o pode ser zero
              RETURN .F.
           ENDIF
        ENDIF

   CASE PTipo == "FBFO" .OR. PTipo == "FORN"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0002017") //Fornecedor n∆o preenchido
           RETURN .F.
        ENDIF

        SA2->(DBSETORDER(1))
        IF !SA2->(DBSEEK(cFilSA2+cCampo))
           HELP("",1,"AVG0002018") //Fornecedor n∆o cadastrado
           RETURN .F.
        ENDIF

   CASE PTipo == "FFB"

        IF EMPTY(cCampo2)
           HELP("",1,"AVG0002019") //Fabricante n∆o preenchido
           RETURN .F.
        ENDIF

        SA2->(DBSETORDER(1))
        IF !SA2->(DBSEEK(cFilSA2+cCampo2))
           HELP("",1,"AVG0002020") //Fabricante n∆o cadastrado
           RETURN .F.
        ENDIF

   CASE PTipo == "FABR"

        IF EMPTY(cCampo)
           HELP("",1,"AVG0002021") //Fabricante n∆o preenchido
           RETURN .F.
        ENDIF

        SA2->(DBSETORDER(1))
        IF !SA2->(DBSEEK(cFilSA2+cCampo))
           HELP("",1,"AVG0002022") //Fabricante n∆o cadastrado
           RETURN .F.
        ENDIF

        SA5->(DBSETORDER(3))
        IF !SA5->(DBSEEK(cFilSA5+Work->W3_COD_I+cCampo+Work->W3_FORN))

           HELP("",1,"AVG0002023",,ALLTRIM(cCampo)+STR0035+ALLTRIM(Work->W3_FORN)+ENTER+;
                      STR0036+Work->W3_COD_I,1,8) //Fabr.: 
           RETURN .F.
        ENDIF

        IF cBotaoAlt = MARCA
           nRecno:=Work->(RECNO())
           Work->(DBGOTOP())
           SA5 ->(DBSETORDER(3))

           WHILE !Work->(EOF())
                 IF !Work->WK_FLAG
                    Work->(DBSKIP()); LOOP
                 ENDIF
                 IF !SA5->(DBSEEK(cFilSA5+Work->W3_COD_I+cCampo+Work->W3_FORN))

                    HELP("",1,"AVG0002024",,ALLTRIM(cCampo)+STR0035+ALLTRIM(Work->W3_FORN)+ENTER+;
                               STR0036+Work->W3_COD_I,1,8) //Forn.: 
                    Work->(DBGOTO(nRecno))
                    RETURN .F.
                 ENDIF
                 Work->(DBSKIP())
           ENDDO
           Work->(DBGOTO(nRecno))
        ENDIF

   CASE PTipo == "LE"

         IF EMPTY(cCampo)
            HELP("",1,"AVG0002025") //Local de Entrega n∆o preenchido
            RETURN .F.
         ENDIF

         SY2->(DBSETORDER(1))
         IF !SY2->(DBSEEK(xFilial()+cCampo))
            HELP("",1,"AVG0002026") //Local de Entrega n∆o cadastrado
            RETURN .F.
         ENDIF

   CASE PTipo == "CC"

         IF EMPTY(cCampo)
            HELP("",1,"AVG0002027") //Unidade Requisitante n∆o preenchida
            RETURN .F.
         ENDIF

         SY3->(DBSETORDER(1))
         IF !SY3->(DBSEEK(xFilial()+cCampo))
            HELP("",1,"AVG0002028") //Unidade Requisitante n∆o cadastrada
            RETURN .F.
         ENDIF

         SW0->(DBSETORDER(1))
         IF SW0->(DBSEEK(cFilSW0+cCampo+Work->W3_SI_NUM))
            HELP("",1,"AVG0002029") //Unidade Requisitante / S.I. j† cadastradas
            RETURN .F.
         ENDIF

ENDCASE

IF PTipo == "FBFO" .OR. PTipo == "FFB" .OR. PTipo == "FORN"

   nRecno:=Work->(RECNO())
   lValid:=.T.

   Work->(DBGOTOP())
   SA5 ->(DBSETORDER(3))

   WHILE ! Work->(EOF())
      IF !SA5->(DBSEEK(cFilSA5+Work->W3_COD_I+IF(PTipo=="FORN",Work->W3_FABR,cCampo2)+cCampo))
         HELP("",1,"AVG0002030",,ALLTRIM(cCampo)+; //"Forn.: "
               STR0038+ALLTRIM(IF(PTipo=="FORN",Work->W3_FABR,cCampo2))+ENTER+; //" / Fabr.: "
               STR0044+Work->W3_COD_I,1,8)    //STR0045            
         lValid:=.F.
         EXIT
      ENDIF
      Work->(DBSKIP())
   ENDDO

   Work->(DBGOTO(nRecno))

ENDIF

/*If !TR175ValAlt(PTipo)  //CCH - 29/05/09 - Desnecess·rio bloqueio pois o tratamento de opÁıes especÌficas por item foi desenvolvido
   Return .F.
EndIf*/
RETURN .T.

*-----------------------*
FUNCTION TR175Tela()
*-----------------------*
LOCAL nRecno:=Work->(RECNO()), lSai:=.F., lPassou:=.T.

LOCAL bProcessa:={||ProcRegua(Work->(LASTREC())),;
                    EVAL(bTodos),TR175CtrlBt("BT_ALT"),TR175CtrlBt("BT_ALTMAR")}

LOCAL bTodos:={||TR175MarkAll()}  // GFP - 09/12/2013
                
LOCAL oPanel  // ACSJ - 19/05/2004 - Ajustes de telas MDI

PRIVATE cCC:=cSI:=cCOD_I:=cFABR:=nREg:=""
PRIVATE oBtAlt,oBtAltCp,oBtAltMar 

PRIVATE lGera:=.T.
PRIVATE TB_Campos:={} //Devido a utilizacao no RDMAKE Dourado 
AADD(TB_Campos,{"WK_FLAG"   ,"", ""   })
AADD(TB_Campos,{"W3_POSICAO","", AVSX3("W3_POSICAO",05)}) //POSICAO   
AADD(TB_Campos,{"W3_CC"     ,"", AVSX3("W3_CC",05)     }) //STR0047"Uni. Requ."
AADD(TB_Campos,{"W3_SI_NUM" ,"", AVSX3("W3_SI_NUM",05) }) //OemtoAnsi(STR0048)"Nß S.I."
AADD(TB_Campos,{"W3_COD_I"  ,"", AVSX3("W3_COD_I",05)  }) //STR0049"Item"
AADD(TB_Campos,{"WKSTATUS","","Status"}) //CCH - 15/05/09 - Incluso situaÁ„o do Item no PO
AADD(TB_Campos,{"A5_CODPRF" ,"", AVSX3("A5_CODPRF",05) }) //STR0050"Part Number"
AADD(TB_Campos,{"WKDESCR"   ,"",STR0051 }) //"Descricao em Ingles"
AADD(TB_Campos,{{||IF(Work->W3_FLUXO='7',STR0052,STR0053)},"",STR0054 } ) //"Nao"###"Sim"###"Anuencia"
AADD(TB_Campos,{"W3_FORN"   ,"",STR0055    } ) //"Cod. Forn."
AADD(TB_Campos,{{||BuscaFabr_Forn(Work->W3_FORN)},"",AVSX3("W3_FORN",05)} ) //STR0056 "Fornecedor"
AADD(TB_Campos,{"W3_FABR"   ,"",STR0057    } ) //"Cod. Fabr."
AADD(TB_Campos,{{||BuscaFabr_Forn(Work->W3_FABR)},"",AVSX3("W3_FABR",05) } ) //STR0058"Fabricante"
AADD(TB_Campos,{{||TRANS(Work->W3_QTDE    ,cPicQTDE   )} ,"",AVSX3("W3_QTDE",05) } ) //STR0059"Quantidade"
AADD(TB_Campos,{{||TRANS(Work->W3_SALDO_Q ,cPicSALDO_Q)} ,"",AVSX3("W3_SALDO_Q",05) } ) //STR0060"Saldo Qtde"
AADD(TB_Campos,{{||TRANS(Work->W3_PRECO   ,cPicPRECO  )} ,"",AVSX3("W3_PRECO",05) } ) //STR0061"Preco Unit."
AADD(TB_Campos,{{||BuscaClass(Work->W1_Class)},"", AVSX3("W1_CLASS",05) } ) //STR0062"Classificacao"
AADD(TB_Campos,{"W0__POLE"  ,"", STR0063   } ) //"Cod. L. E."
AADD(TB_Campos,{{||BuscaLoc(Work->W0__POLE)},"", STR0064 } ) //"Local Entrega"
AADD(TB_Campos,{{||TRANS(Work->W2_COND_PA,'@R 9.9.999') + ' / ' + STR(W2_DIAS_PA,3)},"",AVSX3("W2_COND_PA",05) } ) //STR0065"Cond. Pagto."
AADD(TB_Campos,{"W3_DT_EMB" ,"", AVSX3("W3_DT_EMB",05)    } ) //STR0066"Dt. Emba."
AADD(TB_Campos,{"W3_DT_ENTR","", AVSX3("W3_DT_ENTR",05)   } ) //STR0067"Dt. Entr."
AADD(TB_Campos,{"W2_INCOTER","", AVSX3("W2_INCOTER",05)   } ) //STR0068"Incoterms"
AADD(TB_Campos,{"W3_FABR_01","", AVSX3("W3_FABR_01",05)   } ) //STR0069"Fabricante 1"
AADD(TB_Campos,{"W3_FABR_02","", AVSX3("W3_FABR_02",05)   } ) //STR0070"Fabricante 2"
AADD(TB_Campos,{"W3_FABR_03","", AVSX3("W3_FABR_03",05)   } ) //STR0071"Fabricante 3"
AADD(TB_Campos,{"W3_FABR_04","", AVSX3("W3_FABR_04",05)   } ) //STR0072"Fabricante 4"
AADD(TB_Campos,{"W3_FABR_05","", AVSX3("W3_FABR_05",05)   } ) //STR0073"Fabricante 5"
AADD(TB_Campos,{{||IF(Work->WKTEM_PLI="S",STR0053,STR0052)},"",STR0074}) //"Sim"###"Nao"###"Possui L.I."

IF lPO_DA
   cTitulo:=STR0228 //"Acerto da P.A."
ELSE
   cTitulo:=STR0001 //"Acerto de P.O."
ENDIF

IF EasyEntryPoint("EICTR175")
   Execblock("EICTR175",.F.,.F.,"GRV_TBCAMPOS")   
ENDIF

DO WHILE .T.

   IF lGera
      //Apos qq alteracao, o Work deve ser gerado novamente por causa do indice do mesmo que nao eh atualizado com sucesso
      Processa({||TR175GeraWork()},STR0075) //"Pesquisando Informacoes..."

      IF Work->(BOF()) .AND. Work->(EOF())
         HELP("",1,"AVG0002031") //N„o existe itens deste P.O. para serem alterados
         RETURN .T.
      ENDIF
      IF(!EMPTY(cCC),Work->(DBSEEK(cCC+cSI+cCOD_I+cFABR+STR(nREg,AVSX3("W1_REG",3),0))),)
   ENDIF

   nOpca := 0
   lGera :=.F.

   oMainWnd:ReadClientCoords()

   DEFINE MSDIALOG oDlg TITLE cTitulo+" - "+" Processo: "+TPO_NUM ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
    	    OF oMainWnd PIXEL  
/* ISS - 18/03/10 - AlteraÁ„o do tamanho da tela para que a mesma n„o corte o bot„o "Confirmar"    	    
     @00,00 MSPanel oPanel Prompt "" Size 60,80 of oDlg   // ACSJ - 19/05/2004 - Ajustes de telas MDI  */
     @00,00 MSPanel oPanel Prompt "" Size 60,85 of oDlg   // ACSJ - 19/05/2004 - Ajustes de telas MDI

     oMark:= MsSelect():New("Work","WK_FLAG",,TB_Campos,.F.,@cMarca,{70,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})

     oMark:bAval:={||Work->WK_FLAG:=If(Empty(Work->WK_FLAG),cMarca," "),;//FDR - 27/06/13
                     TR175CtrlBt("BT_ALT"),;
                     TR175CtrlBt("BT_ALTMAR")} //CCH - 20/05/09 - Inclus„o do controle do bot„o "Altera" na marcaÁ„o de Itens (oMark)

     TR175Say(oPanel)   // ACSJ - 19/05/2004 - Ajustes de telas MDI

     @ 18,224 BUTTON oBtAlt PROMPT STR0077 SIZE 45,11 ACTION (nOpca:=4,oDlg:End()) MESSAGE STR0234 OF oPanel PIXEL //"&Alterar" // ACSJ - 19/05/2004 - Ajustes de telas MDI
     
     @ 34,224 BUTTON oBtAltMar PROMPT STR0078 SIZE 45,11 ACTION (nOpca:=3,oDlg:End()) MESSAGE STR0235 OF oPanel PIXEL //"Alt. &Marcados" // ACSJ - 19/05/2004 - Ajustes de telas MDI

     @ 50,224 BUTTON STR0079 SIZE 45,11 ACTION (Processa(bProcessa)) MESSAGE STR0236 OF oPanel PIXEL //"Mar./Des. &Todos" // ACSJ - 19/05/2004 - Ajustes de telas MDI
    
     @ 18,280 BUTTON oBtAltCp PROMPT STR0238 SIZE 45,11 ACTION (nOpca:=7,oDlg:End()) MESSAGE STR0237 OF oPanel PIXEL //"Altera Capa // CCH - 15/05/2009 - CriaÁ„o do bot„o e objeto para utilizaÁ„o do bot„o
        
     DEFINE SBUTTON FROM 34,280 TYPE 6 ACTION (nOpca:=2,oDlg:End()) ENABLE OF oPanel    // ACSJ - 19/05/2004 - Ajustes de telas MDI

     IF lNec
        @ 034,275 BUTTON STR0080 SIZE 38,11 ACTION (nExecute:="2",; //"&Pesquisa/P.N."
        IF(ExecBlock(cArqRdmake,.F.,.F.),(nOpca:=5,oDlg:End()),)) OF oPanel PIXEL   // ACSJ - 19/05/2004 - Ajustes de telas MDI
     ENDIF
    
	oPanel:Align := CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
    oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG oDlg ON INIT ;
                (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()}),; //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
                TR175CtrlBt("BT_ALT_CAPA"),;
                TR175CtrlBt("BT_ALTMAR"))   //CCH - 20/05/09 - Inclus„o do controle do bot„o "Altera Capa" na marcaÁ„o de Itens (oMark)

   IF nOpca = 0
      lSai:=.T.; EXIT

   ELSEIF nOpca = 1
      lSai:=.F.; EXIT

   ELSEIF nOpca = 2
      lPassou:=TR175_Relatorio()
     
   ELSEIF nOpca = 7 //CCH - 15/05/09 - Inclus„o do bot„o "Altera Capa"            
   
      cBotaoAlt:=STR(nOpca,1,0)
      nRecno   :=Work->(RECNO())
      
      TR175Alt()
      Work->(DBGOTO(nRecno))

   ELSEIF nOpca = 3 .OR. nOpca = 4
      cBotaoAlt:=STR(nOpca,1,0)
      nRecno   :=Work->(RECNO())

      TR175Alt()
      Work->(DBGOTO(nRecno))

      IF(lPassou,lPassou:=!lGera,)

   ENDIF

ENDDO

IF !lPassou .AND. MsgYesNo(STR0081,STR0082) //"Deseja Imprimir o RelatÛrio de Acerto de PO ?"###"RelatÛrio"
   TR175_Relatorio()
ENDIF

IF !lPassou                    
   IF EasyEntryPoint("EICRDTR175")
      ExecBlock("EICRDTR175",.F.,.F.,"01")
   ENDIF      
ENDIF                      
     

RETURN !lSai

*------------------*
FUNCTION TR175Say(PPainel)  // ACSJ - 19/05/2004 - Ajustes de telas MDI
// Parametro criado para receber o objeto oPanel (container) para a vers„o 811
*------------------*
LOCAL nColS1:=0.5
LOCAL nColS2:=15
LOCAL nColG1:=5.5
LOCAL nColG2:=19
LOCAL nLin  :=1.4
LOCAL dDataPO     :=SW2->W2_PO_DT
LOCAL nVlrINLAND  :=TRAN(SW2->W2_INLAND ,cPicINLAND  )
LOCAL nVlrDESCONTO:=TRAN(SW2->W2_DESCONT,cPicDESCONTO)
LOCAL nVlrPACKING :=TRAN(SW2->W2_PACKING,cPicPACKING )
LOCAL nVlrFRETEINT:=TRAN(SW2->W2_FRETEIN,cPicFRETEINT)
LOCAL cTotal      :=TRAN(MTotal,cPicTOTAL)
LOCAL nTotalPO    :=TRAN(MTotal         +;
                         SW2->W2_INLAND +;
                         SW2->W2_PACKING+;
                         SW2->W2_FRETEIN-;
                         SW2->W2_DESCONT,cPicTOTAL)    
LOCAL nQtdItens := TR175TotItens(TPO_NUM)                         
                         
*********************************************************************// // ACSJ - 19/05/2004 - Ajustes de telas MDI
@ nLin  ,nColS1 SAY OemToAnsi(STR0083) of PPainel //"Nß P.O."             
@ nLin++,nColG1 MSGET TPO_NUM      WHEN .F. SIZE 60,8 OF PPainel CENTERED

@ nLin  ,nColS1 SAY STR0084 of PPainel //"Vlr. Inland"
@ nLin++,nColG1 MSGET nVlrINLAND   WHEN .F. SIZE 60,8 OF PPainel RIGHT

@ nLin  ,nColS1 SAY STR0085 of PPainel //"Vlr. Packing"
@ nLin++,nColG1 MSGET nVlrPACKING  WHEN .F. SIZE 60,8 OF PPainel RIGHT

@ nLin  ,nColS1 SAY STR0242 of PPainel //Qtd. de Itens"
@ nLin++,nColG1 MSGET nQtdItens WHEN .F. SIZE 60,8 OF PPainel RIGHT //CCH - 26/05/09 - Inclus„o do Total de Itens nos campos informativos

IF SW2->W2_FREPPCC = "PP"
   @nLin,nColS1 SAY STR0086 of PPainel //"Int'l Freight"
   @nLin,nColG1 MSGET nVlrFRETEINT WHEN .F. SIZE 60,8 OF PPainel RIGHT
ENDIF

nLin :=1.4

@ nLin  ,nColS2 SAY STR0087 of PPainel //"Data P.O."
@ nLin++,nColG2 MSGET dDataPO      WHEN .F. SIZE 65,8 OF PPainel CENTERED

@ nLin  ,nColS2 SAY STR0088 of PPainel //"Desconto"
@ nLin++,nColG2 MSGET nVlrDESCONTO WHEN .F. SIZE 65,8 OF PPainel RIGHT

@ nLin  ,nColS2 SAY STR0089 of PPainel //"F.O.B."
@ nLin++,nColG2 MSGET cTotal       WHEN .F. SIZE 65,8 OF PPainel RIGHT 

@ nLin  ,nColS2 SAY STR0090 of PPainel //"Total P.O."
@ nLin  ,nColG2 MSGET nTotalPO     WHEN .F. SIZE 65,8 OF PPainel RIGHT

/* ACSJ - 19/05/2004 - Ajustes de telas MDI */ ********************************************************************
  
RETURN NIL

*-----------------------*
FUNCTION TR175GeraWork()
*-----------------------*
LOCAL bWhile:={||SW3->W3_FILIAL = cFilSW3 .AND. SW3->W3_PO_NUM = TPO_NUM}
LOCAL bFor  :={||SW3->W3_SEQ = 0}
LOCAL nCont:= 0
LOCAL aOrdSW3:= {}
MTotal     := 0

DBSELECTAREA("Work")
AvZap()

ProcRegua(SW3->(LASTREC()))

SW0->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SW1->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW3->(DBSETORDER(1))
SW3->(DBSEEK(cFilSW3+TPO_NUM))
SW3->(DBEVAL({||nCont++},bFor,bWhile))

IF nCont = 0
   RETURN .F.
ENDIF

ProcRegua(nCont)

SW3->(DBSEEK(cFilSW3+TPO_NUM))
SW3->(DBEVAL({||TR175GravaWork()},bFor,bWhile))

Work->(DBGOTOP())

aOrdSW3:= SaveOrd({"SW3"})

//TRP - 04/01/2012 - Tratar o Status de Pedidos que possuam itens com cÛdigos repetidos.
Do While !Work->(EOF()) .AND. Work->W3_PO_NUM = TPO_NUM

   SW3->(DbSetOrder(8))
   If SW3->(DbSeek(xFilial("SW3")+TPO_NUM+Work->W3_POSICAO))
      Do While !SW3->(EOF()) .AND. SW3->W3_FILIAL == xFilial("SW3") .and. SW3->W3_PO_NUM = TPO_NUM .AND. SW3->W3_POSICAO == Work->W3_POSICAO
   
         If SW3->W3_SEQ == 1
            Work->WKSTATUS    := TR175ValStatus("SW3->W3_COD_I","SW3->W3_POSICAO","SW3->W3_PGI_NUM") 
            Exit
         Endif
         SW3->(DbSkip())
      Enddo
   Endif
   Work->(DbSkip())
Enddo

RestOrd(aOrdSW3,.T.)

Work->(DBGOTOP())

RETURN .F.

*------------------------*
FUNCTION TR175GravaWork()
*------------------------*
SB1->(DBSEEK(xFilial()+SW3->W3_COD_I))
SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))
SW1->(PesquisaClassificacao(SW3->W3_CC   ,SW3->W3_SI_NUM,;
                            SW3->W3_COD_I,SW3->W3_PO_NUM,;
                            SW3->W3_REG))//Posiciona no item da solicitacao

IncProc(STR0091+SW3->W3_COD_I) //"Processando Item: "

Work->(DBAPPEND())
Work->W0__POLE    := SW0->W0__POLE
Work->W1_CLASS    := SW1->W1_CLASS
Work->W2_DIAS_PA  := SW2->W2_DIAS_PA
Work->W2_COND_PA  := SW2->W2_COND_PA
Work->W2_INCOTER  := SW2->W2_INCOTER
Work->W3_COD_I    := SW3->W3_COD_I
Work->W3_FABR_01  := SW3->W3_FABR_01
Work->W3_FABR_02  := SW3->W3_FABR_02
Work->W3_FABR_03  := SW3->W3_FABR_03
Work->W3_FABR_04  := SW3->W3_FABR_04
Work->W3_FABR_05  := SW3->W3_FABR_05
Work->W3_REG      := SW3->W3_REG
Work->W3_QTDE     := SW3->W3_QTDE
Work->W3_SALDO_Q  := TR175BuscaSaldo("Work->W3_COD_I")
Work->W3_CC       := SW3->W3_CC
Work->W3_DT_EMB   := SW3->W3_DT_EMB
Work->W3_DT_ENTR  := SW3->W3_DT_ENTR
Work->W3_FABR     := SW3->W3_FABR
Work->W3_FORN     := SW3->W3_FORN
Work->W3_SEQ      := SW3->W3_SEQ
Work->W3_PRECO    := SW3->W3_PRECO
Work->W3_SI_NUM   := SW3->W3_SI_NUM
Work->W3_FLUXO    := IF(EMPTY(SW3->W3_FLUXO),"1",SW3->W3_FLUXO)
Work->WKTEM_PLI   := IF(SW3->W3_QTDE = SW3->W3_SALDO_Q,"N","S")
Work->WKRECNO     := SW3->(RECNO())
//Work->A5_CODPRF   := BuscaPart_N(xFilial("SA5")+Work->W3_COD_I+Work->W3_FABR+Work->W3_FORN)
Work->WKDESCR     := MSMM(SB1->B1_DESC_I,26,1)
Work->W3_POSICAO  := SW3->W3_POSICAO
//TRP - 04/01/2012
//Work->WKSTATUS    := TR175ValStatus("Work->W3_COD_I") 
Work->W3_PO_NUM   := SW3->W3_PO_NUM
                                                                                             
If SW3->(FieldPos("W3_PART_N")) # 0 //ASK 05/10/2007
   Work->A5_CODPRF := SW3->W3_PART_N
Else
   Work->A5_CODPRF := BuscaPart_N(xFilial("SA5")+Work->W3_COD_I+Work->W3_FABR+Work->W3_FORN)
EndIf   
   
IF EasyEntryPoint("EICTR175")
   Execblock("EICTR175",.F.,.F.,"GRV_WORK")   
ENDIF

MTotal += SW3->W3_QTDE * SW3->W3_PRECO

RETURN .T.

*-----------------------*
FUNCTION TR175Alt()
*-----------------------*
LOCAL lPode, Check_PLI, lMarc:=.F., A
LOCAL nRecno  :=Work->(RECNO()), cTexto, nOpcao
LOCAL aRetorno:= {}
PRIVATE nLinFim1:=IF(cBotaoAlt=ATUAL,021,10)
PRIVATE nLinFim2:=IF(cBotaoAlt=ATUAL,150,60)
PRIVATE nSize :=IF(cBotaoAlt=ATUAL,008,09)
PRIVATE aItens:={}
PRIVATE TCampo:=1  // GFP - 26/11/2013 - Alterado variavel para Private para utilizaÁ„o em Ponto de Entrada
Private cUltParc := ""  // GFP - 20/01/2014
IF lPO_DA
   nLinFim1:=IF(cBotaoAlt=ATUAL,10,08)
   nLinFim2:=IF(cBotaoAlt=ATUAL,63,35)
   nSize   :=IF(cBotaoAlt=ATUAL,08,10)
ENDIF


IF lPO_DA
   IF cBotaoAlt = MARCA
      aItens:={}
      AADD(aItens,{STR0092,01})//" Classificacao "
      AADD(aItens,{STR0100,02})//" Preco Unitario "
   ELSEIF cBotaoAlt = ATUAL
      aItens:={}
      AADD(aItens,{STR0092,01})//" Classificacao "
      AADD(aItens,{STR0100,02})//" Preco Unitario "
      AADD(aItens,{STR0095,08})//" Unidade Requisitante "
      AADD(aItens,{STR0096,09})//" Local de Entrega "
      AADD(aItens,{STR0097,10})//" Condicao de Pagto "
      AADD(aItens,{STR0099,12})//" Part Number "
   ENDIF
ELSE
   IF cBotaoAlt = MARCA
      aRetorno := TR175VerStatus("MARCA",NAO_EMB) //CCH - 18/05/2009 - Inicia Controle dos Radios de acordo com os status dos itens
      If aRetorno[1]
         If aRetorno[2] == NAO_EMB
            aItens:={} 
            AADD(aItens,{STR0092,01})//" Classificacao "
            AADD(aItens,{STR0093,03})//" Data de Embarque "
            AADD(aItens,{STR0094,04})//" Data de Entrega "
            //ISS - 26/04/11 - N„o permite a alteraÁ„o do fornecedor quando estiver integrado com o compras
            If !cMV_EASY $ cSim
               AADD(aItens,{STR0103,06})//" Fabr. / Forn. "
            EndIF   
            AADD(aItens,{STR0096,09})//" Local de Entrega "
            AADD(aItens,{STR0095,08})//" Unidade Requisitante "
         Else 
            aItens:={}
            AADD(aItens,{STR0092,01})//" Classificacao " 
            AADD(aItens,{STR0093,03})//" Data de Embarque " //TDF - 07/12/12
            AADD(aItens,{STR0094,04})//" Data de Entrega " 
            AADD(aItens,{STR0096,09})//" Local de Entrega "  
         EndIf
           
      Else   
         MsgInfo(STR0233) //
         Return .F.    
      EndIf   
   ELSEIF cBotaoAlt = ATUAL
          aRetorno := TR175VerStatus("ATUAL",NAO_EMB) 
          If aRetorno[1]
             If aRetorno[2] == NAO_EMB
                aItens:={}
                AADD(aItens,{STR0092,01})//" Classificacao "
                AADD(aItens,{STR0100,02})//" Preco Unitario "
                AADD(aItens,{STR0093,03})//" Data de Embarque "
                AADD(aItens,{STR0094,04})//" Data de Entrega "
                AADD(aItens,{STR0101,05})//" Fabricante "
                //ISS - 26/04/11 - N„o permite a alteraÁ„o do fornecedor quando estiver integrado com o compras
                If !cMV_EASY $ cSim
                   AADD(aItens,{STR0103,06})//" Fabr. / Forn. "
                   AADD(aItens,{STR0102,07})//" Fornecedor "
                EndIf   
                AADD(aItens,{STR0095,08})//" Unidade Requisitante "
                AADD(aItens,{STR0096,09})//" Local de Entrega "
                AADD(aItens,{STR0097,10})//" Condicao de Pagto "
                AADD(aItens,{STR0098,11})//" Incoterms "
                AADD(aItens,{STR0099,12})//" Part Number "
                AADD(aItens,{STR0104,13})//" Inland Charge "
                AADD(aItens,{STR0105,14})//" Packing Charge "
                AADD(aItens,{STR0106,15})//" Desconto "
                AADD(aItens,{STR0107,16})//" Int'l Freight "
                AADD(aItens,{STR0108,17})//" Saldo de Quantidade "                                                   
             Else 
                aItens:={}
                AADD(aItens,{STR0092,01})//" Classificacao "
                AADD(aItens,{STR0093,03})//" Data de Embarque "  // TDF - 07/12/12
                AADD(aItens,{STR0094,04})//" Data de Entrega "
                AADD(aItens,{STR0096,09})//" Local de Entrega "
                AADD(aItens,{STR0099,12})//" Part Number "
                AADD(aItens,{STR0108,17})//" Saldo de Quantidade "
             EndIf
          EndIf                  
                    
   ELSEIF cBotaoAlt = CAPA 
          aRetorno := TR175VerStatus("CAPA") 
          If aRetorno[1] == .T.
             //ISS - 26/04/11 - N„o permite a alteraÁ„o do fornecedor quando estiver integrado com o compras
             If !cMV_EASY $ cSim 
                AADD(aItens,{STR0102,07})//" Fornecedor "
             EndIf   
             AADD(aItens,{STR0097,10})//" Condicao de Pagto "
             AADD(aItens,{STR0098,11})//" Incoterms "
          Else
             MsgInfo(STR0232) //
             Return .F. 
          EndIf      
   ENDIF           //CCH - 18/05/2009 - Encerra Controle dos Radios de acordo com os status dos itens       
ENDIF 

//JVR - 22/10/2009 - Ponto de entrada "ANTESAITENS".
If(EasyEntryPoint("EICTR175"),Execblock("EICTR175",.F.,.F.,"ANTESAITENS"),)

aItensAux:={}
FOR A := 1 TO LEN(aItens)
    AADD( aItensAux,aItens[A,1] )
NEXT 
//Verifica se tem marcados
IF cBotaoAlt = MARCA
   //lMarc:=Work->WK_FLAG
   Work->(DBGOTOP())
   DO WHILE  !Work->(EOF())
      IF !Empty(Work->WK_FLAG)//FDR - 27/06/13
         EXIT
      ENDIF
      Work->(DBSKIP())
   ENDDO
   IF Work->(EOF())
      HELP("",1,"AVG0002032") //N„o existe registros marcados
      RETURN .T.
   ENDIF
   IF !Empty(Work->WK_FLAG)//FDR - 27/06/13 //lMarc
      Work->(DBGOTO(nRecno))
   ELSE
      nRecno:=Work->(RECNO())
   ENDIF
ENDIF

cLitItem :=OemToAnsi(STR0113+Work->W3_COD_I) //"C¢digo do Item Atual :  "
//Se algum campo do indice for alterado a variavel eh atualiza na gravacao
cCC   := Work->W3_CC
cSI   := Work->W3_SI_NUM
cCOD_I:= Work->W3_COD_I
cFABR := Work->W3_FABR
nREg  := Work->W3_REG
nOpcao:= TCampo

DO WHILE .T.

   aTab_PGI :={}
   aTab_HAWB:={}
   MTab_PO  :={}
   cCampo2  :=""
   nOpca    := 0
   lPode    :=.T.
   Check_PLI:=.F.
   lAlterado:=.F.
   TCampo   :=nOpcao
   Work->(DBGOTO(nRecno))
  
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM  0,0 TO nLinFim1+3,45  OF  oMainWnd

     @ 05,16 TO nLinFim2+28,110+8 LABEL OemtoAnsi(STR0114) OF oDlg PIXEL //"Escolha a Opcao p/ Alterar"

     oTipo:=TRadMenu():New(12,25,aItensAux,{|u|If(PCount()==0,TCampo,TCampo:=u)},oDlg,,,,,,,,79,nSize,,,.T.,.T.)
                                                                                               
     DEFINE SBUTTON FROM 20,140 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg

     DEFINE SBUTTON FROM 40,140 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED
   

   IF nOpca = 0
      RETURN .F.
   ENDIF
   nOpcao:=TCampo
   TCampo:=aItens[TCampo,2]

   DO CASE
      CASE TCampo = 1 // 01 - Classificacao
           TR175_1Tela("Class",Work->W1_CLASS,STR0115,REPL("!",LEN(X5DESCRI()))) //"Classificaá∆o"

      CASE TCampo = 3 // 03 - Data de Embarque
           TR175_1Tela("Embar",Work->W3_DT_EMB,STR0116,"@D") //"Data Embarque"
           lAlterado:=.T.  // GFP - 07/01/2013

      CASE TCampo = 4 // 04 - Data de Entrega
           TR175_1Tela("Entre",Work->W3_DT_ENTR,STR0117,"@D") //"Data Entrega"
           lAlterado:=.T.  // GFP - 07/01/2013

      CASE TCampo = 8 // 08 - Unidade Requisitante
           TR175_4Tela("CC",Work->W3_CC,STR0118,"SY3") //"Unidade Requisitante"

      CASE TCampo = 9 // 09 - Local de Entrega
           TR175_4Tela("LE",Work->W0__POLE,STR0119,"SY2") //"Local de Entrega"

      CASE TCampo = 10// 10 - Condicao de Pagto
           // Se existir os cpos referente a pagto antecipado, trata Seek
           // com um campo a mais o WB_PO_DI que, nas parcelas de cambio de DI tera como 
           // conteudo a letra "D".

           SWA->(DBSETORDER(1))
           cFilSWA  := xFilial("SWA")
           SW7->(DBSETORDER(2))
           SW7->(DBSEEK(cFilSW7+TPO_NUM))
           SW7->(DBEVAL({|| lPode:=.F.},{||SWA->(DBSEEK(cFilSWA+SW7->W7_HAWB+IF(lCposAdto,"D","")))},;
                   {||SW7->W7_FILIAL=cFilSW7.AND.TPO_NUM=SW7->W7_PO_NUM.AND.lPode}))

           IF !lPode
              HELP("",1,"AVG0002033",,STR0121+ALLTRIM(SW7->W7_HAWB)+STR0122,1,27)  //"P.O. j† lancado no cÉmbio"###"Estornar o Processo: "//"  do cÉmbio"
           ENDIF

           Check_PLI:=.F.
           IF lPode
              Work->(DBGOTOP())
              Work->(DBEVAL({||lPode:=!(Work->WKTEM_PLI="S".AND.Work->W3_FLUXO#"7")},,{||lPode}))
              Work->(DBGOTO(nRecno))
              Check_PLI:=.T.
           ENDIF

           IF lPode
              cCampo2:=Work->W2_DIAS_PA
              TR175_2Tela("CP",Work->W2_COND_PA,STR0123,"SY6") //"Condiá∆o Pagto."
           ELSE
              IF Check_PLI
                 HELP("",1,"AVG0002034") //AlteraÁ„o n„o pode ser efetuada pois P.O. possui Itens com L.I.
              ENDIF
              lAlterado:=.T.
           ENDIF

      CASE TCampo = 11// 11 - Incoterms

           Work->(DBGOTOP())
           Work->(DBEVAL({||lPode:=!(Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7")},,{||lPode}))
           Work->(DBGOTO(nRecno))

           IF lPode
              TR175_2Tela("IN",Work->W2_INCOTER,AVSX3("W2_INCOTER",05),"SYJ") //STR0068"Incoterms"
           ELSE
              HELP("",1,"AVG0002034") //AlteraÁ„o n„o pode ser efetuada pois P.O. possui Itens com L.I.
              lAlterado:=.T.
           ENDIF

      CASE TCampo = 12// 12 - Part Number

           If SW3->(FieldPos("W3_PART_N")) # 0  //ASK 05/10/2007
              SW3->(DbSetOrder(8))
              SW3->(Dbseek(xFilial("SW3") + TPO_NUM + WORK->W3_POSICAO))
              cPn:= SW3->W3_PART_N//BuscaPart_N(xFilial("SA5")+Work->W3_COD_I+Work->W3_FABR+Work->W3_FORN)
           Else
              cPn:= BuscaPart_N(xFilial("SA5")+Work->W3_COD_I+Work->W3_FABR+Work->W3_FORN)
           EndIf   
          // IF SA5->(EOF())
          //    HELP("",1,"AVG0002035") //Item n∆o possui cadastro no Produto X Fornecedor
          //    lAlterado:=.T.
          // ELSE
              TR175_2Tela("PN",cPn,AVSX3("A5_CODPRF",05),"") //STR0050"Part Number"
          // ENDIF

      CASE TCampo = 2 // 02 - Preco Unitario
           IF Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7"
              HELP("",1,"AVG0002036") //AlteraÁ„o efetuar· mudanÁa nas P.L.I.(s) existentes
           ENDIF
           TR175_1Tela("Preco",Work->W3_PRECO,STR0128,AVSX3("W3_PRECO",6)) //"Preáo Unit†rio"
           MTotal:=0
           Work->(DBGOTOP())
           Work->(DBEVAL({||MTotal+=W3_QTDE * W3_PRECO}))
           Work->(DBGOTO(nRecno))

      CASE TCampo = 5 // 05 - Fabricante      
           lNaoPode:= .F.
           cTexto  := STR0129 //"Pois item possui L.I."

           IF cBotaoAlt = MARCA
              Work->(DBGOTOP())
              Work->(DBEVAL({||lNaoPode:=(Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7")},{||Work->WK_FLAG},{||!lNaoPode}))
              Work->(DBGOTO(nRecno))
              cTexto:="Existe itens do PO que possuem L.I."
           ENDIF

           IF (Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7") .OR. lNaoPode
              HELP("",1,"AVG0002037",,cTexto,2,1) //Alteraá∆o n∆o pode ser efetuada
              lAlterado:=.T.
           ELSE
              HELP("",1,"AVG0002038") //Esta informaÁ„o ser· alterada em todos os itens da S.I.
              TR175_4Tela("FABR",Work->W3_FABR,AVSX3("W3_FABR",05),"")//,"YA2") //STR0058"Fabricante"
           ENDIF

      CASE TCampo = 7 // 07 - Fornecedor
            lRetCamp7 := .T.
			IF EasyEntryPoint("EICTR175")
			   lRetCamp7 :=  Execblock("EICTR175",.F.,.F.,"CHECK_FORNEC")
			ENDIF
            
           IF TR175TstFornFabr(.F.) .AND. lRetCamp7
              lPode := .T.
              cTexto:=""
              Work->(DBGOTOP())
              Work->(DBEVAL({||lPode:=!(Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7")},,{||lPode}))
              Work->(DBGOTO(nRecno))

              IF !lPode
                 cTexto:=STR0131 //"e efetuar† mudanáa nas P.L.I.(s) existentes"
              ENDIF

              HELP("",1,"AVG0002039",,cTexto,3,1) //Esta informaÁ„o ser· alterada em todos as U.R.(s), S.I. e itens deste P.O. 
              TR175_4Tela("FORN",Work->W3_FORN,AVSX3("W3_FORN",05),"")//,"YA2") //STR0056"Fornecedor"
           ENDIF

      CASE TCampo = 6 // 06 - Fabr./Forn.
            lRetCamp6 := .T.
  		    IF EasyEntryPoint("EICTR175")
			   lRetCamp6 := Execblock("EICTR175",.F.,.F.,"CHECK_FAFO")
			ENDIF
            If !lRetCamp6
               LOOP
            Endif
           lPode  := .T.
           Work->(DBGOTOP())
           Work->(DBEVAL({||lPode:=!(Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7")},,{||lPode}))
           Work->(DBGOTO(nRecno))

           IF lPode
              IF TR175TstFornFabr(.T.)
                 HELP("",1,"AVG0002039") //Esta informaÁ„o ser· alterada em todos as U.R.(s), S.I. e itens deste P.O.
                 cLiteral2:=AVSX3("W3_FABR",05) //STR0058"Fabricante"
                 cCampo2:= Work->W3_FABR
                 TR175_4Tela("FBFO",Work->W3_FORN,AVSX3("W3_FORN",05),"")//,"YA2") //STR0056"Fornecedor"
              ENDIF
           ELSE
              HELP("",1,"AVG0002034") //AlteraÁ„o n„o pode ser efetuada pois P.O. possui Itens com L.I.
           ENDIF

      CASE TCampo = 13 // 13 - Inland
           Processa({||lPode:=TR175Taxas("INLAND",,,.T.)},STR0134) //"Pesquisando..."

           IF lPode
              IF Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7"
                 HELP("",1,"AVG0002036") //AlteraÁ„o efetuar· mudanÁa nas P.L.I.(s) existentes
              ENDIF
              TR175_3Tela("INLAND",SW2->W2_INLAND,STR0135,cPicINLAND) //"Inland Charge"
           ELSE
              HELP("",1,"AVG0002040") //Valor de Inland Charge j† rateado n∆o pode ser alterado
              lAlterado:=.T.
           ENDIF

      CASE TCampo = 14 // 14 - Packing
           Processa({||lPode:=TR175Taxas("PACK",,,.T.)},STR0134) //"Pesquisando..."
           IF lPode
              IF Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7"
                 HELP("",1,"AVG0002036") //AlteraÁ„o efetuar· mudanÁa nas P.L.I.(s) existentes
              ENDIF
              TR175_3Tela("PACK",SW2->W2_PACKING,STR0137,cPicPACKING) //"Packing Charge"
           ELSE
              HELP("",1,"AVG0002041") //Valor de Packing Charge j† rateado n∆o pode ser alterado
              lAlterado:=.T.
           ENDIF

      CASE TCampo = 15 // 15 - Desconto
           Processa({||lPode:=TR175Taxas(STR0139,,,.T.)},STR0134) //"DESC"###"Pesquisando..."
           IF lPode
              IF Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7"
                 HELP("",1,"AVG0002036") //AlteraÁ„o efetuar· mudanÁa nas P.L.I.(s) existentes
              ENDIF
              TR175_3Tela("DESC",SW2->W2_DESCONT,STR0088,cPicDESCONTO) //"Desconto"
           ELSE
              HELP("",1,"AVG0002042") //Valor do Desconto j† rateado n∆o pode ser alterado
              lAlterado:=.T.
           ENDIF

      CASE TCampo = 16 // 16 - Int'l Freight
           IF SW2->W2_FREPPCC # "PP"
              HELP("",1,"AVG0002043") //P.O. Ç Collect - n∆o tem Frete Internacional
              lAlterado:=.T.
           ELSE
              Processa({||lPode:=TR175Taxas("FRETE",,,.T.)},STR0134) //"Pesquisando..."
              IF lPode
                 IF Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7"
                    HELP("",1,"AVG0002036") //AlteraÁ„o efetuar· mudanÁa nas P.L.I.(s) existentes
                 ENDIF
                 TR175_3Tela("FRETE",SW2->W2_FRETEIN,STR0086,cPicFRETEINT) //"Int'l Freight"
              ELSE
                 HELP("",1,"AVG0002044") //Valor do Frete Internacional j† rateado n∆o pode ser alterado
                 lAlterado:=.T.
              ENDIF
           ENDIF

      CASE TCampo = 17 // 17 - Saldo de Qtde.
           TR175Sdo()

           MTotal := 0
           Work->(DBGOTOP())
           Work->(DBEVAL({|| MTotal+= W3_QTDE * W3_PRECO}))
           Work->(DBGOTO(nRecno))

      OTHERWISE
          If(EasyEntryPoint("EICTR175"),Execblock("EICTR175",.F.,.F.,"EXECAITENS"),)  // GFP - 26/11/2013
   ENDCASE

   IF !lAlterado
      HELP("",1,"AVG0002045") //N„o houve alteraÁıes
   ENDIF

   IF lGera
      EXIT //Porque precisa atualizar o Work
   ENDIF

ENDDO

If lEXECAUTO_COM .AND. cMV_EASY $ cSim
    PO400GravaPC(ALTERAR)
EndIf

If lAlterado .And. EasyGParam("MV_EASYFPO") $ cSim
   
// ISS - 03/02/10 - Pega a loja do fornecedor e deleta a registro antigo, para n„o haver duplicidade de "PR" no "Financeiro"
   cOldLoja := Posicione("SA2", 1, xFilial("SA2")+cOldForn, "A2_LOJA")
   Processa({|| DeleDupEIC("EIC",SW2->W2_PO_SIGA,-1,"PR",cOldForn,cOldLoja,"SIGAEIC") })
   
   Processa({|| DeleImpDesp(SW2->W2_PO_SIGA,"PR","PO") })
   Processa({|| AVPOS_PO(TPO_NUM,"PO") }) 
   Processa({|| FI400POS_PO(TPO_NUM) })

EndIf 
RETURN .T.

*------------------------*
FUNCTION TR175Sdo()
*------------------------*
LOCAL bGrava,bFor,bWhile,cNomArq,TB_Campos:={},nCont:=0
LOCAL cTitulo:=OemToAnsi(STR0144 ) //"Seleá∆o de P.L.I. para Alteraá∆o"###"AtenÁ„o"
PRIVATE aCampos:={}

bFor  :={||Work->W3_COD_I == SW5->W5_COD_I .AND.;
           Work->W3_FABR  == SW5->W5_FABR  .AND.;
           Work->W3_FORN  == SW5->W5_FORN  .AND.;
           Work->W3_REG   == SW5->W5_REG   .AND.;
           Work->W3_CC    == SW5->W5_CC    .AND.;
           Work->W3_SI_NUM== SW5->W5_SI_NUM.AND.;
           SW5->W5_SEQ = 0}

bWhile:={||SW5->W5_FILIAL == cFilSW5 .AND.;
           SW5->W5_PO_NUM == TPO_NUM}

SW4->(DBSETORDER(1))
SW5->(DBSETORDER(3))
SW5->(DBSEEK(cFilSW5+TPO_NUM))
SW5->(DBEVAL({||nCont++},bFor,bWhile))

IF nCont = 0
   HELP("",1,"AVG0002046") //N∆o existe P.L.I. para este Item
   lAlterado:=.T.
   RETURN .F.
ENDIF

AADD(aCampos,"W5_PGI_NUM")
AADD(aCampos,"W3_COD_I"  )
AADD(aCampos,"W3_REG"    )
AADD(aCampos,"W3_QTDE"   )
AADD(aCampos,"W3_SALDO_Q")

cNomArq:=E_CriaTrab(,{{"WKRECNO"  ,"N",06,0},;
                      {"W4_GI_NUM","C",13,0}},"WorkPgi")//Campo Nao Usado no Obrigat W4_GI_NUM

IndRegua("WorkPgi",cNomArq+TEOrdBagExt(),"W5_PGI_NUM")

AADD(TB_Campos,{"W5_PGI_NUM","",OemToAnsi( STR0146)}) //"Nß P.L.I."
AADD(TB_Campos,{"W3_COD_I"  ,"", AVSX3("W3_COD_I",05)    }) //STR0049"Item"
AADD(TB_Campos,{{||TRANS(WorkPgi->W3_QTDE    ,cPicQTDE   )} ,"", AVSX3("W3_QTDE",05) } ) //STR0059"Quantidade"
AADD(TB_Campos,{{||TRANS(WorkPgi->W3_SALDO_Q ,cPicSALDO_Q)} ,"", AVSX3("W3_SALDO_Q",05) } ) //STR0060"Saldo Qtde"


bGrava:={||IncProc(STR0147+SW5->W5_PGI_NUM),; //"Atualizando P.L.I.: "
           SW4->(DBSEEK(cFilSW4+SW5->W5_PGI_NUM)) ,;
           WorkPgi->(DBAPPEND())                  ,;
           WorkPgi->W5_PGI_NUM := SW5->W5_PGI_NUM ,;
           WorkPgi->W4_GI_NUM  := SW4->W4_GI_NUM  ,;
           WorkPgi->W3_COD_I   := SW5->W5_COD_I   ,;
           WorkPgi->W3_QTDE    := SW5->W5_QTDE    ,;
           WorkPgi->W3_REG     := SW5->W5_REG     ,;
           WorkPgi->W3_SALDO_Q := SW5->W5_SALDO_Q ,;
           WorkPgi->WKRECNO    := SW5->(RECNO())}

SW4->(DBSETORDER(1))
SW5->(DBSETORDER(3))
SW5->(DBSEEK(cFilSW5+TPO_NUM))

Processa({||ProcRegua(nCont),;
            SW5->(DBEVAL(bGrava,bFor,bWhile))},STR0148) //"Pesquisando Alteracao"

IF WorkPgi->(BOF()) .AND. WorkPgi->(EOF())
   HELP("",1,"AVG0002047") //N∆o existe P.L.I. para este P.O.
   WorkPgi->(E_EraseArq(cNomArq,cNomArq))
   lAlterado:=.T.
   RETURN .F.

ENDIF

WorkPgi->(DBGOTOP())

IF Work->WKTEM_PLI = "S" .AND. Work->W3_FLUXO # "7"
   HELP("",1,"AVG0002036") //AlteraÁ„o efetuar· mudanÁa nas P.L.I.(s) existentes
ENDIF

IF WorkPgi->(LASTREC()) > 1 

   DO WHILE .T.

      nOpca:=0

      oMainWnd:ReadClientCoords()

      DEFINE MSDIALOG oDlg TITLE cTitulo ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
    	    OF oMainWnd PIXEL  

        oMark:= MsSelect():New("WorkPgi",,,TB_Campos,.F.,"X",{2,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
        
        @00,00 MSPanel oPanel Prompt "" Size 20,20 of oDlg   // ACSJ - 19/05/2004 - Ajustes de telas MDI

        DEFINE SBUTTON FROM 03,((oDlg:nClientWidth-4)/2)-85 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oPanel  // ACSJ - 19/05/2004 - Ajustes de Tela MDI 
        DEFINE SBUTTON FROM 03,((oDlg:nClientWidth-4)/2)-35 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oPanel  // ACSJ - 19/05/2004 - Ajustes de Tela MDI
        
        oDlg:lMaximized := .t.

      //ACTIVATE MSDIALOG oDlg CENTERED On Init (oPanel:Align := CONTROL_ALIGN_TOP,; //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      //                                         oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT) // ACSJ - 19/05/2004 - Ajustes de telas MDI //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oPanel:Align := CONTROL_ALIGN_TOP
	  oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      ACTIVATE MSDIALOG oDlg CENTERED
      IF nOpca = 0
         EXIT
      ENDIF

      TR175_4Tela("SQ",WorkPgi->W3_SALDO_Q,STR0150,"") //"Saldo de Quantidade"

   ENDDO

ELSE

   TR175_4Tela("SQ",WorkPgi->W3_SALDO_Q,STR0150,"") //"Saldo de Quantidade"

ENDIF

WorkPgi->(E_EraseArq(cNomArq,cNomArq))
DBSELECTAREA("Work")

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION TR175TstFornFabr(lFabFor)
*----------------------------------------------------------------------------*
LOCAL bWhile, bGrava, aTest_GI:={}, aTest_DI:={}
LOCAL cFabr, cForn, nRec
PRIVATE aTest_PO:={}

bGrava:={||IF(ASCAN(aTest_GI,SW5->W5_PGI_NUM)=0,;
              AADD(aTest_GI,SW5->W5_PGI_NUM),)}

bWhile:={||cFilSW5 == SW5->W5_FILIAL .AND.;
           TPO_NUM == SW5->W5_PO_NUM}

SW5->(DBSETORDER(3))
SW5->(DBSEEK(cFilSW5+TPO_NUM))
SW5->(DBEVAL(bGrava,,bWhile))

AEVAL(aTest_GI,{|PGI| Verif_PO(PGI,"G")})

IF TR175Msg(aTest_GI,.T.)
   RETURN .F.
ENDIF

aTest_PO:={}

IF lAltPo

			bGrava:={||IF(ASCAN(aTest_DI,SW7->W7_HAWB)=0,;
			               AADD(aTest_DI,SW7->W7_HAWB),)}
			
			bWhile:={||cFilSW7 == SW7->W7_FILIAL .AND.;
			           TPO_NUM == SW7->W7_PO_NUM}
			
			SW7->(DBSETORDER(2))
			SW7->(DBSEEK(cFilSW7+TPO_NUM))
			SW7->(DBEVAL(bGrava,,bWhile))
			
			AEVAL(aTest_DI,{|HAWB| Verif_PO(HAWB,"D")})
			
			IF TR175Msg(aTest_DI,.F.)
			   RETURN .F.
			ENDIF
ENDIF			
RETURN .T.

*----------------------------------*
FUNCTION Verif_PO(PGI_HAWB,PArquivo)  && FUNCAO PARA VERIFICAR SE EXISTE MAIS DE UM PO EM
*----------------------------------*  UMA PGI EM CASO DE ALTERACAO DE FORNECEDORES
LOCAL PAlias, PCod_I, PPO_NUM, xFil, bWhile
LOCAL bGrava:={||IF(ASCAN(aTest_PO,(PAlias)->( FIELDGET(FIELDPOS(PPO_NUM)))) = 0,;
                  AADD(aTest_PO,(PAlias)->(FIELDGET(FIELDPOS(PPO_NUM)))),)}

IF PArquivo = "G"
   bWhile  :={||cFilSW5  == SW5->W5_FILIAL .AND.;
                PGI_HAWB == SW5->W5_PGI_NUM}
   xFil    := cFilSW5
   PAlias  := "SW5"
   PPO_NUM := "W5_PO_NUM"
ELSE
   bWhile  :={||cFilSW7  == SW7->W7_FILIAL .AND.;
                PGI_HAWB == SW7->W7_HAWB}
   xFil    := cFilSW7
   PAlias  := "SW7"
   PPO_NUM := "W7_PO_NUM"
ENDIF

(PAlias)->(DBSETORDER(1))
(PAlias)->(DBSEEK(xFil+PGI_HAWB))
(PAlias)->(DBEVAL(bGrava,,bWhile))

RETURN

*----------------------------------*
FUNCTION TR175Msg(PArray,lSW5)
*----------------------------------*
LOCAL cTexto:=" ", I

IF LEN(aTest_PO) > 1

   FOR I := 1 TO LEN(PArray)
       cTexto+=ALLTRIM(PArray[I])+" ;  "
   NEXT

   IF !EMPTY(cTexto)
      cTexto:=LEFT(cTexto,(LEN(cTexto)-3))
      HELP("",1,"AVG0002048",,IF(lSW5,STR0153,STR0154)+cTexto,1,34) //"Existe mais P.O.s envolvidos nest"
   ENDIF

   lAlterado:=.T.

   RETURN .T.

ENDIF

RETURN .F.

*----------------------------------------------------------------------------*
FUNCTION TR175_4Tela(PTipo,cCampo1,cLiteral,cF3)
*----------------------------------------------------------------------------*
LOCAL cTexto:="", i
LOCAL cTitulo:=OemToAnsi(STR0155+cLiteral) //"Alteraá∆o de "
LOCAL nCol1:=9, nCol2:=18
LOCAL cPict:=IF(PTipo="SQ",cPicSALDO_Q,"@!")
LOCAL bValid:={||TR175Val(PTipo,cCampo1) .AND. lValid .AND. ;
                 IF(PTipo="FBFO",TR175Val("FFB",cCampo1),.T.)}

// ISS - 03/02/10 - Guarda o antigo fornecedor
cOldForn := IF(ValType(cCampo1) == "C",cCampo1,"") //NCF-17/03/2010 -FNC 51142010 - Valor de "cCampo1" pode vir como numÈrico

cCampoA:=cCampo1
cCampoB:=cCampo2
nOpca  := 0
lValid :=.T.


DEFINE MSDIALOG oDlg TITLE cTitulo FROM  9,0 TO 20,60  OF  oMainWnd

  @ 1.4, 0.5   SAY cLitItem
  @ 3.3, 0.5   SAY OemToAnsi(cLiteral)  OF  oDlg
  @ 2.4, nCol1 SAY STR0156    OF  oDlg //"Novo"
  @ 2.4, nCol2 SAY STR0157   OF  oDlg //"Atual"
  @ 3.3, nCol1 MSGET cCampo1 F3 cF3 VALID TR175Val(PTipo,cCampo1) SIZE  50,8 OF oDlg PICT cPict

  IF !PTipo $ "SQ,CC,LE"
     SA2->(DBSETORDER(1))
     SETKEY(VK_F4,{||TR175HLPA5(PTipo,@cCampo1,@cCampo2)})
     @ 4.2,nCol1 SAY "(F4-Help)" OF  oDlg
  ENDIF

  IF PTipo == "FBFO"
     @ 5.0, 0.5   SAY OemToAnsi(cLiteral2)  OF  oDlg
     @ 5.0, nCol1 MSGET oCampo2 VAR cCampo2 VALID TR175Val("FFB",cCampo1) SIZE  50,8 OF oDlg
     @ 5.0, nCol2 MSGET cCampoB WHEN .F. SIZE  50,8 OF oDlg
  ENDIF
  @ 3.3, nCol2 MSGET cCampoA WHEN .F. SIZE  50,8 OF oDlg PICT cPict

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||IF(EVAL(bValid),(nOpca:=1,oDlg:End()),)},;
                          {|| nOpca:=0,oDlg:End()}) CENTERED

SETKEY(VK_F4,{||.T.})

IF nOpca = 0
   RETURN .F.
ENDIF

IF cCampoA # cCampo1 .OR. (PTipo=="FBFO" .AND. cCampoB # cCampo2)

   DO CASE

      CASE PTipo == "CC" .OR. PTipo == "LE" .OR. PTipo == "FABR"

           c_CC:=c_SI:=""
           MTab_PO:={}
           IF cBotaoAlt = MARCA .AND. PTipo == "FABR"

              Work->(DBGOTOP())
              Work->(DBEVAL({||Processa({||TR175_CLF(PTipo,cCampo1)},;
                               STR0158)}            ,; //"Processando Alteracao"
                            {||Work->WK_FLAG}))
              cTexto:=""
              FOR I := 1 TO LEN(MTab_PO)
                  cTexto+=ALLTRIM(MTab_PO[I])+" ;  "
              NEXT

              IF !EMPTY(cTexto)
                 cTexto:=LEFT(cTexto,(LEN(cTexto)-3))
                 HELP("",1,"AVG0002049",,cTexto+STR0160+ALLTRIM(Work->W3_CC)+STR0161+ALLTRIM(Work->W3_SI_NUM)+STR0162,1,12) //Os PO('s): 
              ENDIF

           ELSE

              Processa({||TR175_CLF(PTipo,cCampo1)},STR0158) //"Processando Alteracao"

           ENDIF

******************************************************************************
      CASE PTipo == "FORN"

           Processa({||TR175_Forn(cCampo1)},STR0158) //"Processando Alteracao"

      CASE PTipo == "FBFO"

           Processa({||TR175_FaFo(cCampo1)},STR0158) //"Processando Alteracao"

      CASE PTipo == "SQ"

           Processa({||TR175Saldo(cCampo1,cCampoA,cPict)},STR0158) //"Processando Alteracao"

   ENDCASE

   lGera:=lAlterado:=.T.

ENDIF

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION TR175_FaFo(cCampo1)
*----------------------------------------------------------------------------*
LOCAL aInvoice:={}, cAnt_CC_si:="", nRecno:=Work->(RECNO())
LOCAL bWhile, bFor, bGrava, nCont :=0, Ind

Work->(DBGOTOP())

cFABR:=cCampo2

DO WHILE Work->(!EOF())

   nCont :=0
   bGrava:={||IncProc(STR0163+SW1->W1_COD_I),; //"Pesquisando Item: "
              SW1->(RECLOCK("SW1",.F.)),;
              IF(!EMPTY(SW1->W1_FORN),SW1->W1_FORN:=cCampo1,),;
              IF(!EMPTY(SW1->W1_FABR),SW1->W1_FABR:=cCampo2,),;
              SW1->(MSUNLOCK())}

   bFor  :={||(SW1->W1_PO_NUM = TPO_NUM .OR.;
               EMPTY(SW1->W1_PO_NUM))  .AND.;
               Work->W3_REG   == SW1->W1_REG}
   //TDF
   bWhile:={||SW1->(!EOF())                    .AND.;
              cFilSW1         == SW1->W1_FILIAL.AND.;
              Work->W3_CC     == SW1->W1_CC    .AND.;
              Work->W3_SI_NUM == SW1->W1_SI_NUM.AND.;
              Work->W3_COD_I  == SW1->W1_COD_I}

   ProcRegua(2)
   SW1->(DBSETORDER(1))
   SW1->(DBSEEK(cFilSW1+Work->W3_CC+Work->W3_SI_NUM+Work->W3_COD_I))
   SW1->(DBEVAL(bGrava,bFor,bWhile))
******************************************************************************

   IF cAnt_CC_si #  Work->W3_CC+Work->W3_SI_NUM

      cAnt_CC_si := Work->W3_CC+Work->W3_SI_NUM

      nCont :=0

      If SW3->(FieldPos("W3_CTCUSTO")) > 0
         cCentroCusto := SW3->W3_CTCUSTO
      Else
         cCentroCusto := SW3->W3_CC
      EndIf
      
      If lEXECAUTO_COM .AND. cMV_EASY $ cSim
         bGrava:={||IncProc(STR0163+SW3->W3_COD_I),; //"Pesquisando Item: "
                    SW3->(RECLOCK("SW3",.F.)),;
                    SW3->W3_FABR := cCampo2,;
                    SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM))),;
                    SW3->(MSUNLOCK())}
      Else                           
      bGrava:={||IncProc(STR0163+SW3->W3_COD_I),; //"Pesquisando Item: "
                 SW3->(RECLOCK("SW3",.F.)),;
                 SW3->W3_FORN := cCampo1,;
                 SW3->W3_FABR := cCampo2,;
                 SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM))),;
                 AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                       IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
                       SW0->W0__POLE,cCentroCusto,;
                       SW3->W3_FORN,'01',SW2->W2_PO_DT,;
                       SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                       Nil,"EICTR175",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N"),;
                 SW3->(MSUNLOCK())}
      EndIf
      //TDF
      bWhile:={||SW3->(!EOF())                     .AND.;
                 cFilSW3         == SW3->W3_FILIAL .AND.;
                 TPO_NUM         == SW3->W3_PO_NUM .AND.;
                 Work->W3_CC     == SW3->W3_CC     .AND.;
                 Work->W3_SI_NUM == SW3->W3_SI_NUM}

      ProcRegua(SW3->(LASTREC()))
      SW3->(DBSETORDER(1))
      SW3->(DBSEEK(cFilSW3+TPO_NUM+Work->W3_CC+Work->W3_SI_NUM))
      SW2->(DBSETORDER(1))
      SW2->(DBSEEK(cFilSW2+SW3->W3_PO_NUM))
      SW0->(DBSETORDER(1))
      SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))   

      SW3->(DBEVAL(bGrava,,bWhile))

******************************************************************************      
bGrava:={||IncProc(STR0163+SW2->W2_PO_NUM),; //"Pesquisando Item: "
                 SW2->(RECLOCK("SW2",.F.)),;
                 SW2->W2_FORN := cCampo1,;
                 SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM))),;
                 SW2->(MSUNLOCK())}
//TDF
bWhile:={||SW2->(!EOF())            .AND.;
           cFilSW2== SW2->W2_FILIAL .AND.;
           TPO_NUM   == SW2->W2_PO_NUM}

      ProcRegua(SW2->(LASTREC()))
      SW3->(DBSETORDER(1))
      SW3->(DBSEEK(cFilSW3+TPO_NUM+Work->W3_CC+Work->W3_SI_NUM))
      SW2->(DBSETORDER(1))
      SW2->(DBSEEK(cFilSW2+SW3->W3_PO_NUM))
      SW0->(DBSETORDER(1))
      SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))         
      
      SW2->(DBEVAL(bGrava,,bWhile))          
      
      
          

******************************************************************************
      nCont :=0
      bGrava:={||IncProc(STR0163+SW5->W5_COD_I),; //"Pesquisando Item: "
                 SW5->(RECLOCK("SW5",.F.)),;
                 SW5->W5_FORN := cCampo1,;
                 SW5->W5_FABR := cCampo2,;
                 SW5->(MSUNLOCK())}
      bFor  :={||TPO_NUM         == SW5->W5_PO_NUM}
      //TDF
      bWhile:={||SW5->(!EOF())                     .AND.;
                 cFilSW5         == SW5->W5_FILIAL .AND.;
                 Work->W3_CC     == SW5->W5_CC     .AND.;
                 Work->W3_SI_NUM == SW5->W5_SI_NUM}

      SW5->(DBSETORDER(4))
      SW5->(DBSEEK(cFilSW5+Work->W3_CC+Work->W3_SI_NUM))
      SW5->(DBEVAL(bGrava,bFor,bWhile))
******************************************************************************
      IF lAltPo
			
			      MTab_HAWB:={ }
			      nCont    := 0
			      bGrava:={||IncProc(STR0163+SW7->W7_COD_I),; //"Pesquisando Item: "
			                 IF(ASCAN(MTab_HAWB,SW7->W7_HAWB)=0,AADD(MTab_HAWB,;
			                 SW7->W7_HAWB),),;
			                 SW7->(RECLOCK("SW7",.F.)),;
			                 SW7->W7_FORN := cCampo1,;
			                 SW7->W7_FABR := cCampo2,;
			                 SW7->(MSUNLOCK())}
			      bFor  :={||TPO_NUM         == SW7->W7_PO_NUM}
			     //TDF
			      bWhile:={||SW7->(!EOF())                     .AND.;
			                 cFilSW7         == SW7->W7_FILIAL .AND.;
			                 Work->W3_CC     == SW7->W7_CC     .AND.;
			                 Work->W3_SI_NUM == SW7->W7_SI_NUM}
			
			      SW7->(DBSETORDER(3))
			      SW7->(DBSEEK(cFilSW7+Work->W3_CC+Work->W3_SI_NUM))
			      SW7->(DBEVAL(bGrava,bFor,bWhile))
      ENDIF
******************************************************************************
      IF lAltPo
			      FOR Ind := 1 TO LEN(MTab_HAWB)
			
			          aInvoice:={}
			          nCont :=0
			          /*bGrava:={||IncProc(STR0164+SW8->W8_COD_I),; //"Atualizando Item: "
			                     IF(ASCAN(aInvoice,{|Invoice| Invoice[1] == SW8->W8_INVOICE .AND.;
			                     Invoice[2] == SW8->W8_FORN}) = 0,;
			                     AADD(aInvoice,{SW8->W8_INVOICE,SW8->W8_FORN}),),;
			                     SW8->(RECLOCK("SW8",.F.)),;
			                     SW8->W8_FORN := cCampo1,;
			                     SW8->W8_FABR := cCampo2,;
			                     SW8->(MSUNLOCK())}
			
			          bFor  :={||TPO_NUM         == SW8->W8_PO_NUM.AND.;
			                     Work->W3_CC     == SW8->W8_CC    .AND.;
			                     Work->W3_SI_NUM == SW8->W8_SI_NUM}
			
			          //TDF 
			          bWhile:={||SW8->(!EOF()) .AND.;
			                     cFilSW8         == SW8->W8_FILIAL .AND.;
			                     MTab_HAWB[Ind]  == SW8->W8_HAWB}*/
			
			          ProcRegua(SW8->(LASTREC()))
			          SW8->(DBSETORDER(3))
			          SW8->(DBSEEK(cFilSW8+MTab_HAWB[Ind]))
			          
			          While SW8->(!EOF()) .AND. cFilSW8 == SW8->W8_FILIAL .AND.;
			                      MTab_HAWB[Ind]  == SW8->W8_HAWB
			                     
			             If TPO_NUM == SW8->W8_PO_NUM     .AND.;
			                Work->W3_CC     == SW8->W8_CC .AND.;
			                Work->W3_SI_NUM == SW8->W8_SI_NUM 
			                
			                IncProc(STR0164+SW8->W8_COD_I)//"Atualizando Item: "
			                IF(ASCAN(aInvoice,{|Invoice| Invoice[1] == SW8->W8_INVOICE .AND. Invoice[2] == SW8->W8_FORN}) = 0)
			                   AADD(aInvoice,{SW8->W8_INVOICE,SW8->W8_FORN})
			                EndIf
			                
			             W8->(RECLOCK("SW8",.F.))
			             SW8->W8_FORN := cCampo1
			             SW8->W8_FABR := cCampo2
			             SW8->(MSUNLOCK())
			                    
			             EndIf
			          
			          SW3->(DBSKIP())
			          EndDo
			          
			          //SW8->(DBEVAL(bGrava,bFor,bWhile))

			          IF cCampoA # cCampo1
			
			             /*bGrava:={||IncProc(STR0165+SW9->W9_INVOICE),;//"Atualizando Invoice: "			                        
			                        SW9->(RECLOCK("SW9",.F.)),;
			                        SW9->W9_FORN    := cCampo1,;
			                        SW9->W9_NOM_FOR := BuscaFabr_Forn(cCampo1),;
			                        SW9->(MSUNLOCK())}
			
			             bFor:={||(ASCAN(aInvoice,{|Invoice|Invoice[1] == SW9->W9_INVOICE .AND.;
			                                        Invoice[2]         == SW9->W9_FORN})) # 0}
			             //TDF
			             bWhile:={||SW9->(!EOF())           .AND.;
			                        SW9->W9_FILIAL==cFilSW9 .AND.;
			                        SW9->W9_HAWB==MTab_HAWB[Ind]}*/
			             nCont := 0
                                                  
			             SW9->(DBSETORDER(3))
			             SW9->(DBSEEK(cFilSW9+MTab_HAWB[Ind]))
			             //SW9->(DBEVAL(bGrava,bFor,bWhile))
			             
			             While SW9->(!EOF()) .AND. SW9->W9_FILIAL==cFilSW9 .AND.;
			                   SW9->W9_HAWB==MTab_HAWB[Ind]
			                
			                If (ASCAN(aInvoice,{|Invoice|Invoice[1] == SW9->W9_INVOICE .AND.;
			                          Invoice[2]== SW9->W9_FORN})) # 0
			                     
			                IncProc(STR0165+SW9->W9_INVOICE)//"Atualizando Invoice: "
			                SW9->(RECLOCK("SW9",.F.))
			                SW9->W9_FORN    := cCampo1
			                SW9->W9_NOM_FOR := BuscaFabr_Forn(cCampo1)
			                SW9->(MSUNLOCK())
			                EndIf           
			             
			             SW9->(DBSKIP())
			             EndDo
			          ENDIF
         NEXT
      ENDIF

******************************************************************************
      IF cCampoA # cCampo1
         MTexto:=STR0166+cCampoA+STR0167+cCampo1+STR0168+; //"ALT. FORN. DE "###" P/ "###" DA U.R. "
                 Work->W3_CC+STR0169+Work->W3_SI_NUM //" SI "

         Grava_Ocor(TPO_NUM, dDataBase,MTexto)
      ENDIF

      IF cCampoB # cCampo2
         MTexto:=STR0170+cCampoB+STR0167+cCampo2+STR0168+; //"ALT. FABR. DE "###" P/ "###" DA U.R. "
                 Work->W3_CC+STR0169+Work->W3_SI_NUM //" SI "

         Grava_Ocor(TPO_NUM, dDataBase,MTexto)
      ENDIF

   ENDIF
   IF EasyEntryPoint("EICTR175")
      Execblock("EICTR175",.F.,.F.,"ATUAL_EZB")   
   ENDIF

   Work->(DBSKIP())

ENDDO

IF cCampoB # cCampo2

   TR175_GrvTXT(TPO_NUM,STR0171,AVSX3("W3_FABR",05),; //"TODOS ALTERADOS"###STR0058"Fabricante"
                cCampo2+" "+BuscaF_F(cCampo2),;
                cCampoB+" "+BuscaF_F(cCampoB))
ENDIF

IF cCampoA # cCampo1

   TR175_GrvTXT(TPO_NUM,STR0171,AVSX3("W3_FORN",05),; //"TODOS ALTERADOS"###STR0056"Fornecedor"
                cCampo1+" "+BuscaF_F(cCampo1),;
                cCampoA+" "+BuscaF_F(cCampoA))

   SW2->(DBSEEK(cFilSW2+TPO_NUM))
   SW2->(RECLOCK("SW2",.F.)) 
   SW2->W2_FORN := cCampo1
   SW2->(MSUNLOCK())

ENDIF

Work->(DBGOTO(nRecno))

RETURN

*----------------------------------------------------------------------------*
FUNCTION TR175_1Tela(PTipo,cCampo1,cLiteral,cPict)
*----------------------------------------------------------------------------*
LOCAL cTitulo:=OemToAnsi(STR0155+cLiteral) //"Alteraá∆o de "
LOCAL nCol1:=7, nCol2:=17, cF3
lAltDtEntr := .F. 
cF3:=IF(PTipo="Class","EY1","")
dDtEntrNew := ""  

IF(PTipo="Class",SX5->(DBSEEK(xFilial()+"Y1"+cCampo1)),)

cCampo1:=IF(PTipo="Class",X5DESCRI(),cCampo1)
cCampo2:=IF(PTipo="Class",ALLTRIM(X5DESCRI()),cCampo1)

nOpca := 0

DEFINE MSDIALOG oDlg TITLE cTitulo FROM  9,0 TO 20,54  OF  oMainWnd

  @ 1.4, 0.5   SAY cLitItem                                
  @ 3.5, 0.7   SAY OemToAnsi(cLiteral)  OF  oDlg
  @ 2.5, nCol1 SAY STR0156    OF  oDlg //"Novo"
  @ 2.5, nCol2 SAY STR0157   OF  oDlg //"Atual"

  @ 3.5, nCol1 MSGET cCampo1 F3 cF3   SIZE  60,8 OF oDlg PICTURE cPict
  @ 3.5, nCol2 MSGET cCampo2 WHEN .F. SIZE  60,8 OF oDlg PICTURE cPict

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||IF(TR175Val(PTipo,cCampo1),(nOpca:=1,oDlg:End()),)},;
                          {|| nOpca:=0,oDlg:End()}) CENTERED

IF nOpca = 0
   RETURN .F.
ENDIF

IF PTipo = "Class"

   cCampo1:=TR175SX5(cCampo1)
   cCampo2:=TR175SX5(cCampo2)

ENDIF

IF cCampo1 # cCampo2
   // EOS Ao entrar com a data de embarque, calcular a data de entrega e perguntar se
   // deve altera-la nos itens selecionados.
   IF PTipo="Embar" 
      SYR->(DBSEEK(xFilial() + SW2->W2_TIPO_EM + SW2->W2_ORIGEM + SW2->W2_DEST))   
      SY9->(dbSetOrder(2))
      dDtEntrOld := Work->W3_DT_ENTR
      dDtEntrNew := cCampo1 + SYR->YR_TRANS_T + IF(SY9->(DBSEEK(xFilial()+SW2->W2_DEST)),(SY9->Y9_LT_DES + SY9->Y9_LT_TRA),EasyGParam("MV_LT_DESE"))
      IF EasyEntryPoint("EICTR175")
         Execblock("EICTR175",.F.,.F.,"ALTERA_DATA")     //TRP-03/09/07
      ENDIF
      SY9->(dbSetOrder(1))
      IF MsgYesNo(STR0229 + DTOC(dDtEntrNew)+ CHR(13)+CHR(10)+;
                  STR0230, STR0231) == .T.
         lAltDtEntr := .T.    
      ENDIF
   ENDIF

   IF cBotaoAlt = MARCA
      Work->(DBGOTOP())
      Work->(DBEVAL({||Processa({||TR175_CPD(PTipo,cCampo1)},;
                                STR0158)}   ,; //"Processando Alteracao"
                    {||!Empty(Work->WK_FLAG)}))  // GFP - 09/12/2013
   ELSE
      Processa({||TR175_CPD(PTipo,cCampo1)},STR0158) //"Processando Alteracao"
   ENDIF

   lGera:=lAlterado:=.T.

ENDIF

RETURN .T.

*----------------------------------------------------------------------------*
Function TR175SX5(cDescri)
*----------------------------------------------------------------------------*
Local cCod := ""

SX5->(dbSeek(xFilial()+"Y1"))
While SX5->X5_FILIAL==xFILIAL("SX5") .AND. SX5->X5_TABELA=='Y1'
   If UPPER(ALLTRIM(X5DESCRI()))=UPPER(ALLTRIM(cDescri))
      cCod := SX5->X5_CHAVE
      Exit
   Endif
   SX5->(dbSkip())
End

Return cCod

*----------------------------------------------------------------------------*
FUNCTION TR175_CPD(PTipo,cCampo1)
*----------------------------------------------------------------------------*
LOCAL MTot_IP:=0,MTot_IG:=0,MTot_R:=0,MTab_PGI:={}
LOCAL aInvoice:={}, Ocorr, Acerto, MTab_HAWB:={}
LOCAL bWhile, bFor, Ind, i
Local cAlias := Alias() // TDF - 31/03/11 - Salva ¡rea
PRIVATE bGrava//Por que o rdmake utiliza (IC023PO1)      
PRIVATE _PTipo := PTipo, _cCampo1 := cCampo1

IF PTipo = "Class" 

      ProcRegua(2)
      IncProc(STR0164+Work->W3_COD_I) //"Atualizando Item: "
      SW1->(PesquisaClassificacao(;
      Work->W3_CC   ,Work->W3_SI_NUM,;
      Work->W3_COD_I,TPO_NUM,;
      Work->W3_REG))//Posiciona no item da solicitacao

      IncProc(STR0164+SW1->W1_COD_I) //"Atualizando Item: "
      SW1->(RECLOCK("SW1",.F.))
      SW1->W1_CLASS := cCampo1
      SW1->(MSUNLOCK())

      TR175_GrvTXT(TPO_NUM,Work->W3_COD_I,AVSX3("W1_CLASS",05)  ,; //STR0062"Classificacao"
                   ALLTRIM(cCampo1)+" "+BuscaClass(cCampo1),;
                   ALLTRIM(cCampo2)+" "+BuscaClass(cCampo2))

      MTexto:=STR0172+ALLTRIM(BuscaClass(cCampo2))+; //"ALT.CLASS.DE "
              STR0173+ALLTRIM(BuscaClass(cCampo1))+; //" P/"
              "/"+Work->W3_CC+"/"+Work->W3_SI_NUM+"/"+Work->W3_COD_I

      Grava_Ocor(TPO_NUM, dDataBase,MTexto)

ELSE
******************************************************************************

   // PLB 14/09/07 - SubstituÌdo pelo ponto de entrada 'ExecBlock("EICTR175",.F.,.F.,"ATUALIZA_DTS_PRECO_SW3")'
   //IF EasyEntryPoint("INT100DtEntr")
   //   ExecBlock(INT100DtEntr,.F.,.F.)
   //ENDIF
   /*
   SW2->(DBSETORDER(1))
   SW2->(DBSEEK(cFilSW2+TPO_NUM))
   SW3->(DBSETORDER(1))
   SW3->(DBSEEK(cFilSW3+TPO_NUM+Work->W3_CC+Work->W3_SI_NUM+Work->W3_COD_I))
   SW0->(DBSETORDER(1))
   SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))   
   bGrava:={||IncProc(STR0164+SW3->W3_COD_I),; //"Atualizando Item: "
         SW3->(RECLOCK("SW3",.F.)),;
         SW3->W3_PRECO  :=IF(PTipo="Preco",cCampo1,SW3->W3_PRECO  ),;
         SW3->W3_DT_EMB :=IF(PTipo="Embar",cCampo1,SW3->W3_DT_EMB ),;
         SW3->W3_DT_ENTR:=IF(lAltDtEntr, ddtEntrNew, IF(PTipo="Entre",cCampo1,SW3->W3_DT_ENTR)),;
         SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM))),;
         IF(PTipo#"Embar" .or. lAltDtEntrega,AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                   IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
                   SW0->W0__POLE,SW3->W3_CC,;
                   SW3->W3_FORN,'01',SW2->W2_PO_DT,;
                   SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;  //ASR 12/12/2005 - DEVE PASSAR A POSI«√O DI ITEM E N√O "01" NO PARAMENTRO 13∞
                   Nil,"EICTR175",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N"),),;
         SW3->(MSUNLOCK()),IncProc(STR0164+SW3->W3_COD_I)} //"Atualizando Item: "

   IF PTipo="Entre" .AND. EasyEntryPoint("IC023PO1")       
      bGrava:={||U_IC023PO1("ACERTOPO",cCampo1)}
   ENDIF

   bFor  :={||Work->W3_FABR == SW3->W3_FABR .AND.;
              Work->W3_FORN == SW3->W3_FORN .AND.;
              Work->W3_REG  == SW3->W3_REG}

   bWhile:={||SW3->W3_FILIAL == cFilSW3        .AND.;
              SW3->W3_PO_NUM == TPO_NUM        .AND.;
              SW3->W3_CC     == Work->W3_CC    .AND.;
              SW3->W3_SI_NUM == Work->W3_SI_NUM.AND.;
              SW3->W3_COD_I  == Work->W3_COD_I}

   ProcRegua(2)

   //** PLB 14/09/07 - Ponto em substituiÁ„o do localizado acima (EasyEntryPoint("INT100DtEntr"))
   If EasyEntryPoint("EICTR175")
      ExecBlock("EICTR175",.F.,.F.,"ATUALIZA_DTS_PRECO_SW3")
   EndIf
   //**

   SW3->(DBEVAL(bGrava,bFor,bWhile))*/ 
   
   SW2->(DBSETORDER(1))
   SW2->(DBSEEK(cFilSW2+TPO_NUM))
   SW3->(DBSETORDER(1))
   SW3->(DBSEEK(cFilSW3+TPO_NUM+Work->W3_CC+Work->W3_SI_NUM+Work->W3_COD_I))
   SW0->(DBSETORDER(1))
   SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))  
   
   //** PLB 14/09/07 - Ponto em substituiÁ„o do localizado acima (EasyEntryPoint("INT100DtEntr"))
   If EasyEntryPoint("EICTR175")
      ExecBlock("EICTR175",.F.,.F.,"ATUALIZA_DTS_PRECO_SW3")
   EndIf
   //**       
       While  SW3->(!EOF()) .AND. SW3->W3_FILIAL == cFilSW3 .AND.;
              SW3->W3_PO_NUM == TPO_NUM                     .AND.;
              SW3->W3_CC     == Work->W3_CC                 .AND.;       
              SW3->W3_SI_NUM == Work->W3_SI_NUM             .AND.;
              SW3->W3_COD_I  == Work->W3_COD_I   
          
          If Work->W3_FABR == SW3->W3_FABR .AND.;
             Work->W3_FORN == SW3->W3_FORN .AND.;
             Work->W3_REG  == SW3->W3_REG              
                 
             If SW3->(FieldPos("W3_CTCUSTO")) > 0
                cCentroCusto := SW3->W3_CTCUSTO
             Else
                cCentroCusto := SW3->W3_CC
             EndIf
             
             IncProc(STR0164+SW3->W3_COD_I) //"Atualizando Item: "
             SW3->(RECLOCK("SW3",.F.))
             SW3->W3_PRECO  :=IF(PTipo="Preco",cCampo1,SW3->W3_PRECO  )
             SW3->W3_DT_EMB :=IF(PTipo="Embar",cCampo1,SW3->W3_DT_EMB )
             SW3->W3_DT_ENTR:=IF(lAltDtEntr, ddtEntrNew, IF(PTipo="Entre",cCampo1,SW3->W3_DT_ENTR))
             SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM)))
          
             IF PTipo#"Embar" .or. lAltDtEntrega .And. !lEXECAUTO_COM .AND. !cMV_EASY $ cSim
                AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                      IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
                      SW0->W0__POLE,cCentroCusto,;
                      SW3->W3_FORN,'01',SW2->W2_PO_DT,;
                      SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;  
                      Nil,"EICTR175",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N",SW3->W3_PO_NUM) //LRS 23/05/2014 - Adicionado PO_NUM pois ao alterar data, na tabela SW3 perdia o Numero PO.
             EndIf
             
            IF PTipo=="Embar" .AND. cMV_EASY $ cSim    //LRS 23/05/2014 - Caso alterar a data de embarque, atualizar o modulo Compras      
                AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                      IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
                      SW0->W0__POLE,cCentroCusto,;
                      SW3->W3_FORN,'01',SW2->W2_PO_DT,;
                      SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;  
                      Nil,"EICTR175",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N",SW3->W3_PO_NUM) 
             EndIf
             
             SW3->(MSUNLOCK())
             IncProc(STR0164+SW3->W3_COD_I)//"Atualizando Item: "
          EndIf
          SW3->(DBSKIP())
       EndDo
             
     
   

******************************************************************************

   IF PTipo="Preco"

      bGrava:={||IncProc(STR0174+SW3->W3_COD_I),; //"Somando Item: "
                 MTot_IP+=SW3->W3_QTDE * SW3->W3_PRECO}

      bFor  :={||SW3->W3_SEQ = 0}
      bWhile:={||SW3->W3_FILIAL == cFilSW3 .AND. SW3->W3_PO_NUM = TPO_NUM}
      nCont :=0
      
      ProcRegua(SW3->(LASTREC()))
      SW3->(DBSETORDER(1))
      SW3->(DBSEEK(cFilSW3+TPO_NUM))
      SW3->(DBEVAL(bGrava,bFor,bWhile))

      IF MTot_IP <> 0
         SW2->(DBSEEK(cFilSW2+TPO_NUM))
         SW2->(RECLOCK("SW2",.F.))
         SW2->W2_FOB_TOT := MTot_IP
         SW2->(MSUNLOCK())
      ENDIF


******************************************************************************
      IF lAltPo

			      /*bGrava:={||IncProc(STR0164+SW7->W7_COD_I),; //"Atualizando Item: "
			      IF(ASCAN(MTab_HAWB,SW7->W7_HAWB)=0,AADD(MTab_HAWB,SW7->W7_HAWB),),;
			      SW7->(RECLOCK("SW7",.F.)),;
			      SW7->W7_PRECO := cCampo1,;
			      SW7->(MSUNLOCK()),IncProc(STR0164+SW7->W7_COD_I)} //"Atualizando Item: "
			
			      bFor:={||Work->W3_CC   ==SW7->W7_CC   .AND.Work->W3_SI_NUM==SW7->W7_SI_NUM.AND.;
			               Work->W3_COD_I==SW7->W7_COD_I.AND.Work->W3_FABR  ==SW7->W7_FABR  .AND.;
			               Work->W3_FORN ==SW7->W7_FORN .AND.Work->W3_REG   ==SW7->W7_REG}
			
			      //TDF
			      bWhile:={||SW7->(!EOF()) .AND.;
			                 SW7->W7_FILIAL=cFilSW7.AND.;
			                 SW7->W7_PO_NUM=TPO_NUM}*/
			
			      MTab_HAWB:={}
			      nCont:=0
			
			      ProcRegua(2)
			      SW7->(DBSETORDER(2))
			      SW7->(DBSEEK(cFilSW7+TPO_NUM))
			      //SW7->(DBEVAL(bGrava,bFor,bWhile))
			      
			      While SW7->(!EOF()) .AND. SW7->W7_FILIAL=cFilSW7 .AND. SW7->W7_PO_NUM=TPO_NUM
			         If Work->W3_CC     == SW7->W7_CC      .AND.;
			            Work->W3_SI_NUM == SW7->W7_SI_NUM  .AND.;
			            Work->W3_COD_I  == SW7->W7_COD_I   .AND.;
			            Work->W3_FABR   == SW7->W7_FABR    .AND.;
			            Work->W3_FORN   == SW7->W7_FORN    .AND.;
			            Work->W3_REG    == SW7->W7_REG
			            
			            IncProc(STR0164+SW7->W7_COD_I)//"Atualizando Item: "
			            If(ASCAN(MTab_HAWB,SW7->W7_HAWB)=0)
			               AADD(MTab_HAWB,SW7->W7_HAWB)
			            EndIf
			         
			         SW7->(RECLOCK("SW7",.F.))
			         SW7->W7_PRECO := cCampo1
			         SW7->(MSUNLOCK())
			         IncProc(STR0164+SW7->W7_COD_I)//"Atualizando Item: "
			         
			         EndIf
			     			      
			      SW7->(DBSKIP())
			      EndDo
      
      ENDIF

      IF lAltPo
        FOR Ind = 1 TO LEN(MTab_HAWB)
		
	       bGrava:={||IncProc(STR0165+SW8->W8_INVOICE),; //"Atualizando Invoice: "
		   IF(ASCAN(aInvoice,{|Invoice| Invoice[1] == SW8->W8_INVOICE .AND. Invoice[2] == SW8->W8_FORN}) = 0,;
		   AADD(aInvoice,{SW8->W8_INVOICE,SW8->W8_FORN,SW8->W8_QTDE,SW8->W8_PRECO}),),;
		   SW8->(RECLOCK("SW8",.F.)),;
		   SW8->W8_PRECO := cCampo1,;
		   SW8->(MSUNLOCK()),IncProc(STR0165+SW8->W8_INVOICE)} //"Atualizando Invoice: "
			
		   bFor:={||TPO_NUM     ==SW8->W8_PO_NUM.AND. ;
		            Work->W3_CC    ==SW8->W8_CC    .AND. ;
			        Work->W3_SI_NUM==SW8->W8_SI_NUM.AND. ;
			        Work->W3_COD_I ==SW8->W8_COD_I .AND. ;
			        Work->W3_FABR  ==SW8->W8_FABR  .AND. ;
			        Work->W3_FORN  ==SW8->W8_FORN  .AND. ;
			        Work->W3_REG   ==SW8->W8_REG}
			
	      bWhile:={||SW8->W8_FILIAL==cFilSW8.AND.SW8->W8_HAWB==MTab_HAWB[Ind]}
			
		  aInvoice:={}
			
		  ProcRegua(2)
		  SW8->(DBSETORDER(1))
		  SW8->(DBSEEK(cFilSW8+MTab_HAWB[Ind]))
		  SW8->(DBEVAL(bGrava,bFor,bWhile))

			
		  bGrava:={||IncProc(STR0165+SW9->W9_INVOICE),; //"Atualizando Invoice: "
		  MTot_R += SW9->W9_FOB_TOT * SW9->W9_TX_FOB,;
		  Acerto:=VAL(SUBSTR(STR(aInvoice[Ocorr,3] * aInvoice[Ocorr,4],14,3),1,13))-;
		          VAL(SUBSTR(STR(aInvoice[Ocorr,3] * cCampo1          ,14,3),1,13)),;
		  SW9->(RECLOCK("SW9",.F.)),;
		  SW9->W9_FOB_TOT := SW9->W9_FOB_TOT - Acerto,;
		  SW9->(MSUNLOCK())}
			
		  bFor:={||(Ocorr:=ASCAN(aInvoice,{|Invoice|Invoice[1] == SW9->W9_INVOICE .AND.;
			                                        Invoice[2] == SW9->W9_FORN})) # 0}
			
		  bWhile:={||SW9->W9_FILIAL==cFilSW9.AND.SW9->W9_HAWB==MTab_HAWB[Ind]}
		  nCont  :=0
		  Ocorr  :=0
          MTot_R :=0
          
		  ProcRegua(SW9->(LASTREC()))
		  SW9->(DBSETORDER(3))
		  SW9->(DBSEEK(cFilSW9+MTab_HAWB[Ind]))
		  SW9->(DBEVAL(bGrava,bFor,bWhile))
			
		  /*bGrava :={||IncProc(STR0164+SW7->W7_COD_I)} //"Atualizando Item: "
		  bFor   :={||SW7->W7_SEQ==0}
		  //TDF
		  bWhile :={||SW7->(!EOF()) .AND.;
		              SW7->W7_FILIAL == cFilSW7 .AND.;
		              MTab_HAWB[Ind] == SW7->W7_HAWB} */
		  nCont  :=0
				
		  ProcRegua(SW7->(LASTREC()))
		  SW7->(DBSETORDER(1))
		  SW7->(DBSEEK(cFilSW7+MTab_HAWB[Ind]))
		  //SW7->(DBEVAL(bGrava,bFor,bWhile))
		  
		  While SW7->(!EOF()) .AND. SW7->W7_FILIAL == cFilSW7 .AND. MTab_HAWB[Ind] == SW7->W7_HAWB
		     If SW7->W7_SEQ == 0
		        IncProc(STR0164+SW7->W7_COD_I) //"Atualizando Item: "
		     EndIf
          SW7->(DbSkip())
		  EndDo
				
		  SW6->(DBSETORDER(1))
		  IF SW6->(DBSEEK(cFilSW6+MTab_HAWB[Ind])) .AND. MTot_R # 0
		    SW6->(RECLOCK("SW6",.F.))
			SW6->W6_FOB_TOT:=MTot_R
			SW6->(MSUNLOCK())
	     ENDIF
        NEXT
     ENDIF

   ENDIF

******************************************************************************

   /*bGrava:={||IncProc(STR0164+SW5->W5_COD_I),; //"Atualizando Item: "
   SW5->(RECLOCK("SW5",.F.)),;
   SW5->W5_PRECO  :=IF(PTipo="Preco",(IF(ASCAN(MTab_PGI,SW5->W5_PGI_NUM)=0,AADD(MTab_PGI,SW5->W5_PGI_NUM),),cCampo1),SW5->W5_PRECO),;
   SW5->W5_DT_EMB :=IF(PTipo="Embar",cCampo1,SW5->W5_DT_EMB ),;
   SW5->W5_DT_ENTR:=IF(lAltDtEntr, dDtEntrNew, IF(PTipo="Entre",cCampo1,SW5->W5_DT_ENTR)),;
   SW5->(MSUNLOCK()),IncProc(STR0164+SW5->W5_COD_I)} //"Atualizando Item: "

   bFor  :={||Work->W3_COD_I == SW5->W5_COD_I .AND.;
              Work->W3_FABR  == SW5->W5_FABR  .AND.;
              Work->W3_FORN  == SW5->W5_FORN  .AND.;
              Work->W3_REG   == SW5->W5_REG   .AND.;
              Work->W3_CC    == SW5->W5_CC    .AND.;
              Work->W3_SI_NUM== SW5->W5_SI_NUM}

   //TDF
   bWhile:={||SW5->(!EOF()) .AND.;
              SW5->W5_FILIAL==cFilSW5 .AND.;
              SW5->W5_PO_NUM=TPO_NUM} */

   ProcRegua(2)
   SW5->(DBSETORDER(3))
   SW5->(DBSEEK(cFilSW5+TPO_NUM))
   //SW5->(DBEVAL(bGrava,bFor,bWhile))
   
   While SW5->(!EOF()) .AND. SW5->W5_FILIAL==cFilSW5 .AND. SW5->W5_PO_NUM=TPO_NUM
      If Work->W3_COD_I  == SW5->W5_COD_I .AND.;
         Work->W3_FABR   == SW5->W5_FABR  .AND.;
         Work->W3_FORN   == SW5->W5_FORN  .AND.;
         Work->W3_REG    == SW5->W5_REG   .AND.;
         Work->W3_CC     == SW5->W5_CC    .AND.;
         Work->W3_SI_NUM == SW5->W5_SI_NUM
      
         IncProc(STR0164+SW5->W5_COD_I)//"Atualizando Item: "
         SW5->(RECLOCK("SW5",.F.))
         SW5->W5_PRECO  :=IF(PTipo="Preco",(IF(ASCAN(MTab_PGI,SW5->W5_PGI_NUM)=0,AADD(MTab_PGI,SW5->W5_PGI_NUM),),cCampo1),SW5->W5_PRECO)
         SW5->W5_DT_EMB :=IF(PTipo="Embar",cCampo1,SW5->W5_DT_EMB )
         SW5->W5_DT_ENTR:=IF(lAltDtEntr, dDtEntrNew, IF(PTipo="Entre",cCampo1,SW5->W5_DT_ENTR))
         SW5->(MSUNLOCK())
         IncProc(STR0164+SW5->W5_COD_I)//"Atualizando Item: "   
      EndIf
      
   SW5->(DbSkip())   
   EndDo

******************************************************************************
   SW4->(DBSETORDER(1))
   SW5->(DBSETORDER(1))
   FOR I = 1 TO LEN(MTab_PGI)

       bGrava:={||IncProc(STR0175+MTab_PGI[I]),; //"Atualizando PGI: "
              MTot_IG+=SW5->W5_QTDE * SW5->W5_PRECO}

       bFor   :={||SW5->W5_SEQ=0}
       bWhile :={||SW5->W5_FILIAL=cFilSW5 .AND. MTab_PGI[I]=SW5->W5_PGI_NUM}
       nCont  :=0
       MTot_IG:=0

       ProcRegua(SW5->(LASTREC()))
       SW5->(DBSEEK(cFilSW5+MTab_PGI[I]))
       SW5->(DBEVAL(bGrava,bFor,bWhile))

       IF SW4->(DBSEEK(cFilSW4+MTab_PGI[I])) .AND. MTot_IG <> 0
          SW4->(RECLOCK("SW4",.F.))
          SW4->W4_FOB_TOT:=MTot_IG
          SW4->(MSUNLOCK())
       ENDIF

   NEXT

******************************************************************************

   IF PTipo="Preco"

      TR175_GrvTXT(TPO_NUM,Work->W3_COD_I,STR0176,; //"Preco Unitario"
                   ALLTRIM(TRAN(cCampo1,cPicPRECO)),;
                   ALLTRIM(TRAN(cCampo2,cPicPRECO)))

      MTexto:=IF(lAltPo,"A.PR. PO/DI/GI DE ","A.PR. PO/GI DE ")+;
              ALLTRIM(TRAN(cCampo2,cPicPRECO))+" P/ "+;
              ALLTRIM(TRAN(cCampo1,cPicPRECO))+"/"+;
              Work->W3_COD_I+"/"+Work->W3_CC+"/"+Work->W3_SI_NUM

   ENDIF

******************************************************************************

   IF PTipo="Embar"

      TR175_GrvTXT(TPO_NUM,Work->W3_COD_I,STR0116,; //"Data Embarque"
                   DTOC(cCampo1),DTOC(cCampo2))

      MTexto:=IF(lAltPo,"ALT.DT.PO/DI/GI DE","ALT.DT.PO/GI DE")+DTOC(cCampo2)+" P/"+DTOC(cCampo1)+;
              "/"+Work->W3_COD_I+"/"+Work->W3_CC+"/"+Work->W3_SI_NUM

      IF lAltDtEntrega               
         TR175_GrvTXT(TPO_NUM,Work->W3_COD_I,STR0117,; //"Data Entrega"
                   DTOC(dDtEntrNew),DTOC(dDtEntrOld))

         MTexto:=IF(lAltPo,"ALT.DT.PO/DI/GI DE","ALT.DT.PO/GI DE")+DTOC(dDtEntrOld)+" P/"+DTOC(ddtEntrNew)+;
                 "/"+Work->W3_COD_I+"/"+Work->W3_CC+"/"+Work->W3_SI_NUM

      ENDIF

   ENDIF

******************************************************************************

   IF PTipo="Entre"

      TR175_GrvTXT(TPO_NUM,Work->W3_COD_I,STR0117,; //"Data Entrega"
                   DTOC(cCampo1),DTOC(cCampo2))

      MTexto:=IF(lAltPo,"ALT.DT.PO/DI/GI DE","ALT.DT.PO/GI DE")+DTOC(cCampo2)+" P/"+DTOC(cCampo1)+;
               "/"+Work->W3_COD_I+"/"+Work->W3_CC+"/"+Work->W3_SI_NUM

   ENDIF

   Grava_Ocor(TPO_NUM, dDataBase,MTexto)


ENDIF

   // TDF - 31/03/11 - Restaura ¡rea
   If !Empty(cAlias)
      DbSelectArea(cAlias)
   EndIf

RETURN

*----------------------------------------------------------------------------*
FUNCTION TR175_2Tela(PTipo,cCampo1,cLiteral,cF3)
*----------------------------------------------------------------------------*
LOCAL cTitulo:=OemToAnsi(STR0155+cLiteral) //"Alteraá∆o de "
LOCAL nCol1:=6, nCol2:=18
LOCAL cPict:=IF(PTipo="CP",'@R 9.9.999',"@!")

cCampoA:=cCampo1
cCampoB:=cCampo2
nOpca :=0

DEFINE MSDIALOG oDlg TITLE cTitulo FROM  9,0 TO 20,62  OF  oMainWnd

  @ 1.4, 0.5   SAY cLitItem
  @ 3.5, 0.5   SAY OemToAnsi(cLiteral)  OF  oDlg
  @ 2.5, nCol1 SAY STR0156    OF  oDlg //"Novo"
  @ 2.5, nCol2 SAY STR0157   OF  oDlg //"Atual"

  @ 3.5, nCol1 MSGET cCampo1 F3 cF3 VALID TR175Val(PTipo,cCampo1) SIZE  60,8 OF oDlg PICT cPict
  IF PTipo == "CP"
     @ 3.5, nCol1+9 MSGET oCampo2 VAR cCampo2 VALID TR175Val("DIA",cCampo1+STR(cCampo2,3)) SIZE  20,8 OF oDlg PICTURE "999"
     @ 3.5, nCol2+8 MSGET cCampoB WHEN .F. SIZE  20,8 OF oDlg
  ENDIF
  @ 3.5, nCol2 MSGET cCampoA WHEN .F. SIZE  60,8 OF oDlg PICT cPict

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||IF(TR175Val(PTipo,cCampo1+IF(PTipo="CP",STR(cCampo2,3),"")),(nOpca:=1,oDlg:End()),)},;
                          {|| nOpca:=0,oDlg:End()}) CENTERED

IF nOpca = 0
   RETURN .F.
ENDIF

IF cCampoA # cCampo1 .OR. (PTipo == "CP" .AND. cCampoB # cCampo2)

   Processa({||TR175_CPPN(PTipo,cCampo1)},STR0158) //"Processando Alteracao"
   lGera:=lAlterado:=.T.

ENDIF

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION TR175_CPPN(PTipo,cCampo1)
*----------------------------------------------------------------------------*

IF PTipo == "PN"

   ProcRegua(2)
   If SW3->(FieldPos("W3_PART_N")) # 0   
      SW3->(DbSetOrder(8)) //ASK
      SW3->(DbSeek(xFilial("SW3") + TPO_NUM + Work->W3_POSICAO))
      SW3->(RECLOCK("SW3",.F.))
      SW3->W3_PART_N := cCampo1
      SW3->(MSUNLOCK())
   Endif
   
   If MsgYesNo("Deseja atualizar o cadastro de Produto / Fornecedor?")
      IncProc(STR0177) //"Atualizando P.N. "
      SA5->(DbSetOrder(3))
      SA5->(DbSeek(xFilial("SA5") + Work->W3_COD_I + Work->W3_FABR + Work->W3_FORN))
      SA5->(RECLOCK("SA5",.F.))
      SA5->A5_CODPRF := cCampo1
      SA5->(MSUNLOCK())
   EndIf
   TR175_GrvTXT(TPO_NUM,Work->W3_COD_I,AVSX3("A5_CODPRF",05),cCampo1,cCampoA) //STR0050"Part Number"

   MTexto:="ALT. PART NBR."+ALLTRIM(cCampoA)+" P/ "+ALLTRIM(cCampo1)+" UR "+;
           Work->W3_CC+" SI "+Work->W3_SI_NUM+"/"+Work->W3_COD_I

   IncProc(STR0177) //"Atualizando P.N. "

ENDIF

IF PTipo == "CP"

   ProcRegua(2)
   IncProc(STR0178) //"Atualizando C.P. "
   SW2->(RECLOCK("SW2",.F.))
   SW2->W2_COND_PAG := cCampo1
   SW2->W2_DIAS_PAG := cCampo2
   SW2->(MSUNLOCK())

   IncProc(STR0178) //"Atualizando C.P. "
   MTexto:=STR0179+TRANS(cCampoA,'@R 9.9.999')+"/"+; //"ALT. COND.PAG. DE"
           STR(cCampoB,3,0)+" P/"+TRANS(cCampo1,'@R 9.9.999')+"/"+;
           STR(cCampo2,3,0)+"/"+Work->W3_CC+"/"+;
           Work->W3_SI_NUM+"/"+Work->W3_COD_I

   TR175_GrvTXT(TPO_NUM,STR0171,STR0180,; //"TODOS ALTERADOS"###"Condicao de Pagamento"
                TRAN(cCampo1,'@R 9.9.999')+"/"+STR(cCampo2,3,0),;
                TRAN(cCampoA,'@R 9.9.999')+"/"+STR(cCampoB,3,0))

ENDIF

IF PTipo == "IN"

   ProcRegua(2)
   IncProc(STR0182) //"Atualizando INCOTERMS "
   SW2->(RECLOCK("SW2",.F.))
   SW2->W2_INCOTER := cCampo1
   SW2->(MSUNLOCK())

   MTexto:=STR0183+cCampoA+" P/ "+cCampo1+" UR "+; //"ALT. INCOTERMS DE "
            Work->W3_CC+" SI "+Work->W3_SI_NUM+"/"+Work->W3_COD_I

   TR175_GrvTXT(TPO_NUM,STR0171,AVSX3("W2_INCOTER",05),cCampo1,cCampoA) //STR0068"TODOS ALTERADOS"###"Incoterms"

   IncProc(STR0182) //"Atualizando INCOTERMS "

ENDIF

Grava_Ocor(TPO_NUM, dDataBase,MTexto)

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION TR175_3Tela(PTipo,cCampo1,cLiteral,cPict)
*----------------------------------------------------------------------------*
LOCAL cTitulo:=OemToAnsi(STR0155+cLiteral) //"Alteraá∆o de "
LOCAL nCol1:=6, nCol2:=15

cCampo2:=cCampo1
nOpca  :=0

DEFINE MSDIALOG oDlg TITLE cTitulo FROM  9,0 TO 20,50  OF  oMainWnd

  @ 1.4, 0.5   SAY cLitItem
  @ 3.5, 0.7   SAY OemToAnsi(cLiteral)  OF  oDlg
  @ 2.5, nCol1 SAY STR0156    OF  oDlg //"Novo"
  @ 2.5, nCol2 SAY STR0157   OF  oDlg //"Atual"

  @ 3.5, nCol1 MSGET cCampo1 SIZE 60,8 OF oDlg PICT cPict
  @ 3.5, nCol2 MSGET cCampo2 SIZE 60,8 OF oDlg PICT cPict WHEN .F.

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||IF(TR175Val(PTipo,cCampo1),(nOpca:=1,oDlg:End()),)},;
                          {|| nOpca:=0,oDlg:End()}) CENTERED

IF nOpca = 0
   RETURN .F.
ENDIF

IF cCampo1 # cCampo2

   Processa({||TR175Taxas(PTipo,cCampo1,cPict,.F.)},STR0158) //"Processando Alteracao"
   lGera:=lAlterado:=.T.

ENDIF

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION TR175Taxas(PTipo,cCampo1,cPict,lValida)
*----------------------------------------------------------------------------*
LOCAL MConf_GI:=.T., MConf_DI:=.T.,nCont:=0 ,Ind

IF lValida

   ProcRegua(SW5->(LASTREC()))
   SW5->(DBSETORDER(3))
   SW5->(DBSEEK(cFilSW5+TPO_NUM))
   SW5->(DBEVAL({||IncProc(STR0163+SW5->W5_COD_I),; //"Pesquisando Item: "
                   IF(ASCAN(aTab_PGI,SW5->W5_PGI_NUM)=0,AADD(aTab_PGI,SW5->W5_PGI_NUM),)},,;
                {||SW5->W5_FILIAL=cFilSW5 .AND. SW5->W5_PO_NUM=TPO_NUM}))

   SW7->(DBSETORDER(2))
   SW7->(DBSEEK(cFilSW7+TPO_NUM))
   SW7->(DBEVAL({||IncProc(STR0163+SW7->W7_COD_I),; //"Pesquisando Item: "
                   IF(ASCAN(aTab_HAWB,SW7->W7_HAWB)=0,AADD(aTab_HAWB,SW7->W7_HAWB),)},,;
                {||SW7->W7_FILIAL=cFilSW7.AND.TPO_NUM=SW7->W7_PO_NUM}))

   ProcRegua(LEN(aTab_PGI)+LEN(aTab_HAWB))

   FOR Ind=1 TO LEN(aTab_PGI)

       IncProc(STR0184+aTab_PGI[Ind]) //"Pesquisando PGI: "

       SW4->(DBSETORDER(1))
       IF SW4->(DBSEEK(cFilSW4+aTab_PGI[Ind]))
          DO CASE
             CASE PTipo = "INLAND"
                  MConf_GI := SW4->W4_INLAND   == SW2->W2_INLAND

             CASE PTipo = "PACK"
                  MConf_GI := SW4->W4_PACKING  == SW2->W2_PACKING

             CASE PTipo = "DESC"
                  MConf_GI := SW4->W4_DESCONTO == SW2->W2_DESCONTO

             CASE PTipo = "FRETE"
                  MConf_GI := SW4->W4_FRETEINT == SW2->W2_FRETEINT

          ENDCASE
       ENDIF
   NEXT

   IF !MConf_GI //.OR. !MConf_DI
      RETURN .F.
   ENDIF

   RETURN .T.

ENDIF

******************************************************************************
ProcRegua(LEN(aTab_PGI)+LEN(aTab_HAWB)+2)


FOR Ind=1 TO LEN(aTab_PGI)

    IncProc(STR0186+aTab_PGI[Ind]) //"Alterando P.G.I.: "

    IF SW4->(DBSEEK(cFilSW4+aTab_PGI[Ind]))
       SW4->(RECLOCK("SW4",.F.))
       DO CASE
          CASE PTipo = "INLAND"
               IF SW4->W4_INLAND   == SW2->W2_INLAND
                  SW4->W4_INLAND   := cCampo1
               ENDIF
          CASE PTipo = "PACK"
               IF SW4->W4_PACKING  == SW2->W2_PACKING
                  SW4->W4_PACKING  := cCampo1
               ENDIF
          CASE PTipo = "DESC"
               IF SW4->W4_DESCONTO == SW2->W2_DESCONTO
                  SW4->W4_DESCONTO := cCampo1
               ENDIF
          CASE PTipo = "FRETE"
               IF SW4->W4_FRETEINT == SW2->W2_FRETEINT
                  SW4->W4_FRETEINT := cCampo1
               ENDIF
       ENDCASE
       SW4->(MSUNLOCK())
    ENDIF
NEXT

******************************************************************************
IF lAltPo

  FOR Ind=1 TO LEN(aTab_HAWB)
			
	IncProc(STR0187+aTab_HAWB[Ind]) //"Alterando Processo: "
			
	IF !SW6->(DBSEEK(cFilSW6+aTab_HAWB[Ind]))
	   SW6->(RECLOCK("SW6",.F.))
	   DO CASE
	     CASE PTipo = "INLAND"
	       IF SW6->W6_INLAND   == SW2->W2_INLAND
		     SW6->W6_INLAND   := cCampo1
		   ENDIF
		 CASE PTipo = "PACK"
		   IF SW6->W6_PACKING  == SW2->W2_PACKING
		     SW6->W6_PACKING  := cCampo1
           ENDIF
  	     CASE PTipo = "DESC"
		   IF SW6->W6_DESCONTO == SW2->W2_DESCONTO
		     SW6->W6_DESCONTO := cCampo1
		   ENDIF
		 CASE PTipo = "FRETE"
		   IF SW6->W6_FRETEINT == SW2->W2_FRETEINT
		     SW6->W6_FRETEINT := cCampo1
	       ENDIF
	    ENDCASE
	    SW6->(MSUNLOCK())
	 ELSE
       HELP("",1,"AVG0002050",,PTipo+STR0227,1,25) //Processo em andamento - 
     ENDIF
  NEXT
ENDIF
******************************************************************************

SW2->(RECLOCK("SW2",.F.))

IncProc(STR0188+TPO_NUM) //"Alterando P.O.: "

DO CASE
   CASE PTipo = "INLAND"
        SW2->W2_INLAND := cCampo1
        SW2->(MSUNLOCK())

        TR175_GrvTXT(TPO_NUM,STR0171,"INLAND CHARGE",; //"TODOS ALTERADOS"
                     ALLTRIM(TRANS(cCampo1,cPict)),;
                     ALLTRIM(TRANS(cCampo2,cPict)))

        MTexto:= "ALT. INLAND "+ALLTRIM(TRANS(cCampo2,'999,999,999,999.99'))+" PARA "+ALLTRIM(TRANS(cCampo1,'999,999,999,999.99'))+" DO PO "+TPO_NUM

   CASE PTipo = "PACK"
        SW2->W2_PACKING := cCampo1
        SW2->(MSUNLOCK())

        TR175_GrvTXT(TPO_NUM,STR0171,"PACKING CHARGE",; //"TODOS ALTERADOS"
                     ALLTRIM(TRANS(cCampo1,cPict)),;
                     ALLTRIM(TRANS(cCampo2,cPict)))

        MTexto:= "ALT. PACKING "+ALLTRIM(TRANS(cCampo2,'999,999,999,999.99'))+" PARA "+ALLTRIM(TRANS(cCampo1,'999,999,999,999.99'))+" DO PO "+TPO_NUM

   CASE PTipo = "DESC"
        SW2->W2_DESCONTO := cCampo1
        SW2->(MSUNLOCK())

        TR175_GrvTXT(TPO_NUM,STR0171,STR0088,; //"TODOS ALTERADOS"###"DESCONTO"
                     ALLTRIM(TRANS(cCampo1,cPict)),;
                     ALLTRIM(TRANS(cCampo2,cPict)))

        MTexto:= STR0189+ALLTRIM(TRANS(cCampo2,'999,999,999,999.99'))+STR0190+ALLTRIM(TRANS(cCampo1,'999,999,999,999.99'))+STR0191+TPO_NUM //"ALT. DESCONTO "###" PARA "###" DO PO "

   CASE PTipo = "FRETE"
        SW2->W2_FRETEINT := cCampo1
        SW2->(MSUNLOCK())

        TR175_GrvTXT(TPO_NUM,STR0171,STR0192,; //"TODOS ALTERADOS"###"FRETE INTERNACIONAL"
                     ALLTRIM(TRANS(cCampo1,cPict)),;
                     ALLTRIM(TRANS(cCampo2,cPict)))

        MTexto:= STR0193+ALLTRIM(TRANS(cCampo2,'999,999,999,999.99'))+" P/ "+ALLTRIM(TRANS(cCampo1,'999,999,999,999.99'))+" DO PO "+TPO_NUM //"ALT. INT'L FREIGHT "

ENDCASE

IncProc(STR0194) //"Gravando Ocorrencia"

Grava_Ocor(TPO_NUM, dDataBase,MTexto)

RETURN

*----------------------------------------------------------------------------*
FUNCTION TR175_CLF(PTipo,cCampo1)
*----------------------------------------------------------------------------*
LOCAL nCont:=0//, c_CC, c_SI, cCod_I, cReg
LOCAL MTab_HAWB:={}, aRecno:={}
LOCAL nRec, MFabr_A, MFabr
LOCAL cTexto:="", i, Ind
PRIVATE bGrava, bFor, bWhile//Para os Rdmakes


DO CASE
******************************************************************************
CASE PTipo == "LE"
******************************************************************************

   ProcRegua(2)
   SW0->(DBSETORDER(1))
   SW0->(DBSEEK(cFilSW0+Work->W3_CC+Work->W3_SI_NUM))
   SW0->(RECLOCK("SW0",.F.))
   SW0->W0__POLE := cCampo1
   SW0->(MSUNLOCK())

   IncProc(STR0195) //"Atualizando Local de Entrega..."
   TR175_GrvTXT(TPO_NUM,STR0171,STR0119,; //"TODOS ALTERADOS"###"Local de Entrega"
                cCampo1+" "+BuscaLoc(cCampo1),;
                cCampoA+" "+BuscaLoc(cCampoA))

   MTexto:=STR0196+cCampoA+" P/ "+cCampo1+" DA UR "+; //"ALT. L.E. DE "
           Work->W3_CC+" SI "+Work->W3_SI_NUM

******************************************************************************

/* nRec:= Work->(RECNO())
   c_CC := Work->W3_CC
   cSI := Work->W3_SI_NUM
   bGrava:={||Work->W0__POLE := cCampo1}
   bWhile:={||Work->W3_CC    == c_CC .AND.;
              Work->W3_SI_NUM== cSI }

   Work->(DBSEEK(c_CC+cSI))
   Work->(DBEVAL(bGrava,,bWhile))
   Work->(DBGOTO(nRec))*/
   IncProc(STR0195) //"Atualizando Local de Entrega..."

   Grava_Ocor(TPO_NUM, dDataBase,MTexto)

   RETURN .T.
******************************************************************************
CASE PTipo == "FABR"
******************************************************************************

   IF c_CC != Work->W3_CC .AND.;
      c_SI != Work->W3_SI_NUM

      cFABR:= cCampo1
      c_CC := Work->W3_CC
      c_SI := Work->W3_SI_NUM

      bGrava:={||IncProc(STR0163+SW1->W1_COD_I),; //"Pesquisando Item: "
                 IF(ASCAN(MTAB_PO,SW1->W1_PO_NUM)=0,AADD(MTab_PO,SW1->W1_PO_NUM),)}
      bFor  :={||!EMPTY(SW1->W1_PO_NUM)}
      bWhile:={||cFilSW1         == SW1->W1_FILIAL.AND.;
                 Work->W3_CC     == SW1->W1_CC    .AND.;
                 Work->W3_SI_NUM == SW1->W1_SI_NUM}

      ProcRegua(SW1->(LASTREC()))
      SW1->(DBSETORDER(1))
      SW1->(DBSEEK(cFilSW1+Work->W3_CC+Work->W3_SI_NUM))
      SW1->(DBEVAL(bGrava,bFor,bWhile))

      IF cBotaoAlt = ATUAL

         cTexto:=""
         FOR I := 1 TO LEN(MTab_PO)
             cTexto+=ALLTRIM(MTab_PO[I])+" ;  "
         NEXT

         IF !EMPTY(cTexto)
            cTexto:=LEFT(cTexto,(LEN(cTexto)-3))

            HELP("",1,"AVG0002051",,cTexto+" da U.R.: "+ALLTRIM(Work->W3_CC)+" e S.I.: "+ALLTRIM(Work->W3_SI_NUM)+STR0162,1,13) //Os PO('s):
         ENDIF

      ENDIF

   ENDIF

******************************************************************************

   nCont :=0
   bGrava:={||SW1->(RECLOCK("SW1",.F.)),;
              SW1->W1_FABR := cCampo1,;
              SW1->(MSUNLOCK())}
   bFor  :={||(SW1->W1_PO_NUM = TPO_NUM .OR.;
               EMPTY(SW1->W1_PO_NUM))  .AND.;
              !EMPTY(SW1->W1_FABR)     .AND.;
               Work->W3_REG   == SW1->W1_REG}
   bWhile:={||cFilSW1         == SW1->W1_FILIAL.AND.;
              Work->W3_CC     == SW1->W1_CC    .AND.;
              Work->W3_SI_NUM == SW1->W1_SI_NUM.AND.;
              Work->W3_COD_I  == SW1->W1_COD_I}

   ProcRegua(4)
   SW1->(DBSETORDER(1))
   SW1->(DBSEEK(cFilSW1+Work->W3_CC+Work->W3_SI_NUM+Work->W3_COD_I))
   SW1->(DBEVAL(bGrava,bFor,bWhile))

******************************************************************************

   nCont :=0
   bGrava:={||IncProc(STR0163+SW3->W3_COD_I),; //"Pesquisando Item: "
              SW3->(RECLOCK("SW3",.F.)),;
              SW3->W3_FABR := cCampo1,;
              SW3->(MSUNLOCK())}
   bFor  :={||Work->W3_REG    == SW3->W3_REG}
   bWhile:={||cFilSW3         == SW3->W3_FILIAL .AND.;
              TPO_NUM         == SW3->W3_PO_NUM .AND.;
              Work->W3_CC     == SW3->W3_CC     .AND.;
              Work->W3_SI_NUM == SW3->W3_SI_NUM .AND.;
              Work->W3_COD_I  == SW3->W3_COD_I}

   IF EasyEntryPoint("EICTR175")
      Execblock("EICTR175",.F.,.F.,"FABR_ATUAL_SW3")   
   ENDIF

   SW3->(DBSETORDER(1))
   SW3->(DBSEEK(cFilSW3+TPO_NUM+Work->W3_CC+Work->W3_SI_NUM+Work->W3_COD_I))
   SW3->(DBEVAL(bGrava,bFor,bWhile))

******************************************************************************
   nCont :=0
   bGrava:={||IncProc(STR0163+SW5->W5_COD_I),; //"Pesquisando Item: "
              SW5->(RECLOCK("SW5",.F.)),;
              SW5->W5_FABR := cCampo1,;
              SW5->(MSUNLOCK())}

   bFor  :={||Work->W3_REG    == SW5->W5_REG    .AND.;
              Work->W3_CC     == SW5->W5_CC     .AND.;
              Work->W3_SI_NUM == SW5->W5_SI_NUM}

   bWhile:={||cFilSW5         == SW5->W5_FILIAL .AND.;
              TPO_NUM         == SW5->W5_PO_NUM .AND.;
              Work->W3_COD_I  == SW5->W5_COD_I}

   SW5->(DBSETORDER(3))
   SW5->(DBSEEK(cFilSW5+TPO_NUM+Work->W3_COD_I))
   SW5->(DBEVAL(bGrava,bFor,bWhile))

******************************************************************************
   IF lAltPo

			   MTab_HAWB:={}
			   nCont    :=0
			   bGrava:={||IF(ASCAN(MTab_HAWB,SW7->W7_HAWB)=0,AADD(MTab_HAWB,SW7->W7_HAWB),),;
			              IncProc(STR0163+SW7->W7_COD_I),; //"Pesquisando Item: "
			              SW7->(RECLOCK("SW7",.F.)),;
			              SW7->W7_FABR := cCampo1,;
			              SW7->(MSUNLOCK())}
			   bFor  :={||Work->W3_REG    == SW7->W7_REG  .AND.;
			              Work->W3_COD_I  == SW7->W7_COD_I.AND.;
			              Work->W3_CC     == SW7->W7_CC   .AND.;
			              Work->W3_SI_NUM == SW7->W7_SI_NUM}
			   bWhile:={||cFilSW7 == SW7->W7_FILIAL .AND.;
			              TPO_NUM == SW7->W7_PO_NUM}
			
			   SW7->(DBSETORDER(2))
			   SW7->(DBSEEK(cFilSW7+TPO_NUM))
			   SW7->(DBEVAL(bGrava,bFor,bWhile))
			ENDIF
   ProcRegua(LEN(MTab_HAWB)+1)

   FOR Ind := 1 TO LEN(MTab_HAWB)

       nCont :=0
       /*bGrava:={||IncProc(STR0164+SW8->W8_COD_I),; //"Atualizando Item: "
                  SW8->(RECLOCK("SW8",.F.)),;
                  SW8->W8_FABR := cCampo1,;
                  SW8->(MSUNLOCK())}

       bFor  :={||TPO_NUM         == SW8->W8_PO_NUM.AND.;
                  Work->W3_COD_I  == SW8->W8_COD_I .AND.;
                  Work->W3_REG    == SW8->W8_REG   .AND.;
                  Work->W3_CC     == SW8->W8_CC    .AND.;
                  Work->W3_SI_NUM == SW8->W8_SI_NUM}

       //TDF
       bWhile:={||SW8->(!EOF()) .AND.;
                  cFilSW8         == SW8->W8_FILIAL .AND.;
                  MTab_HAWB[Ind]  == SW8->W8_HAWB}*/

       SW8->(DBSETORDER(1))
       SW8->(DBSEEK(cFilSW8+MTab_HAWB[Ind]))
       //SW8->(DBEVAL(bGrava,bFor,bWhile))
       
       While SW8->(!EOF()) .AND. cFilSW8 == SW8->W8_FILIAL .AND. MTab_HAWB[Ind] == SW8->W8_HAWB
          
          If TPO_NUM         == SW8->W8_PO_NUM.AND.;
             Work->W3_COD_I  == SW8->W8_COD_I .AND.;
             Work->W3_REG    == SW8->W8_REG   .AND.;
             Work->W3_CC     == SW8->W8_CC    .AND.;
             Work->W3_SI_NUM == SW8->W8_SI_NUM
             
             IncProc(STR0164+SW8->W8_COD_I) //"Atualizando Item: "
             SW8->(RECLOCK("SW8",.F.))
             SW8->W8_FABR := cCampo1
             SW8->(MSUNLOCK())
          EndIf
        
       SW8->(DbSkip())
       EndDo

   NEXT

******************************************************************************
   IncProc(STR0197) //"Gravando Ocorrecia"

   MFabr_A:= cCampoA+" "+BuscaF_F(cCampoA)
   MFabr  := cCampo1+" "+BuscaF_F(cCampo1)

   TR175_GrvTXT(TPO_NUM,Work->W3_COD_I,AVSX3("W3_FABR",05),; //STR0058"Fabricante"
                MFabr,MFabr_A)

   MTexto:=STR0170+cCampoA+STR0167+cCampo1+" DO UR "+; //"ALT. FABR. DE "###" P/ "
           Work->W3_CC+" SI "+Work->W3_SI_NUM

   Grava_Ocor(TPO_NUM, dDataBase,MTexto)


******************************************************************************
CASE PTipo == "CC"
******************************************************************************

   cCC:=cCampo1

   bGrava:={||IncProc(STR0163+SW1->W1_COD_I),; //"Pesquisando Item: "
              IF(ASCAN(MTAB_PO,SW1->W1_PO_NUM)=0,AADD(MTab_PO,SW1->W1_PO_NUM),)}
   bFor  :={||(AADD(aRecno,SW1->(RECNO())),.T.).AND.;
              !EMPTY(SW1->W1_PO_NUM)}
   bWhile:={||cFilSW1         == SW1->W1_FILIAL.AND.;
              Work->W3_CC     == SW1->W1_CC    .AND.;
              Work->W3_SI_NUM == SW1->W1_SI_NUM}

   ProcRegua(SW1->(LASTREC()))
   SW1->(DBSETORDER(1))
   SW1->(DBSEEK(cFilSW1+Work->W3_CC+Work->W3_SI_NUM))
   SW1->(DBEVAL(bGrava,bFor,bWhile))

   cTexto:=""
   FOR I := 1 TO LEN(MTab_PO)
       cTexto+=ALLTRIM(MTab_PO[I])+" ;  "
   NEXT

   IF !EMPTY(cTexto)
      cTexto:=LEFT(cTexto,(LEN(cTexto)-3))
      HELP("",1,"AVG0002051",,cTexto+STR0160+ALLTRIM(Work->W3_CC)+; //" Os PO('s): "###" da U.R.: "
              STR0161+ALLTRIM(Work->W3_SI_NUM)+STR0198,1,13)
   ENDIF

******************************************************************************

   ProcRegua(LEN(aRecno)+1)
   IncProc(STR0164+SW1->W1_COD_I) //"Atualizando Item: "
   SW0->(DBSETORDER(1))
   SW0->(DBSEEK(cFilSW0+Work->W3_CC+Work->W3_SI_NUM))
   SW0->(RECLOCK("SW0",.F.))
   SW0->W0__CC := cCampo1
   SW0->(MSUNLOCK())

   FOR I := 1 TO LEN(aRecno)
       IncProc(STR0164+SW1->W1_COD_I) //"Atualizando Item: "
       SW1->(DBGOTO(aRecno[I]))
       SW1->(RECLOCK("SW1",.F.))
       SW1->W1_CC := cCampo1
       SW1->(MSUNLOCK())
   NEXT

******************************************************************************
   ProcRegua(LEN(aRecno))
   aRecno:={}
   nCont :=0
   /*bGrava:={||IncProc(STR0163+SW3->W3_COD_I),; //"Pesquisando Item: "
              AADD(aRecno,SW3->(RECNO()))}
   //TDF
   bWhile:={||SW3->(!EOF()) .AND.;
              cFilSW3         == SW3->W3_FILIAL.AND.;
              Work->W3_CC     == SW3->W3_CC    .AND.;
              Work->W3_SI_NUM == SW3->W3_SI_NUM}*/

   SW3->(DBSETORDER(4))
   SW3->(DBSEEK(cFilSW3+Work->W3_CC+Work->W3_SI_NUM))
   //SW3->(DBEVAL(bGrava,,bWhile))
   
   While SW3->(!EOF())                    .AND.;
         cFilSW3         == SW3->W3_FILIAL.AND.;
         Work->W3_CC     == SW3->W3_CC    .AND.;
         Work->W3_SI_NUM == SW3->W3_SI_NUM
         
      IncProc(STR0163+SW3->W3_COD_I)//"Pesquisando Item: "
      AADD(aRecno,SW3->(RECNO()))
      
   SW3->(DbSkip())
   EndDo

******************************************************************************

   ProcRegua(LEN(aRecno)*2)
   FOR I := 1 TO LEN(aRecno)
       SW3->(DBGOTO(aRecno[I]))
       IncProc(STR0164+SW3->W3_COD_I) //"Atualizando Item: "
       SW2->(DBSETORDER(1))
       SW2->(DBSEEK(cFilSW2+SW3->W3_PO_NUM))
       SW3->(RECLOCK("SW3",.F.))
       SW3->W3_CC := cCampo1
       SW3->(MSUNLOCK())
       If SW3->(FieldPos("W3_CTCUSTO")) > 0
          cCentroCusto := SW3->W3_CTCUSTO
       Else
          cCentroCusto := SW3->W3_CC
       EndIf
       
       If lEXECAUTO_COM .AND. cMV_EASY $ cSim
          AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                   IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
                   SW0->W0__POLE,cCentroCusto,;
                   SW3->W3_FORN,'01',SW2->W2_PO_DT,;
                   SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                   Nil,"EICTR175",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N")
       EndIf            
   NEXT

******************************************************************************

   aRecno:={}
   nCont :=0
   bGrava:={||IncProc(STR0163+SW5->W5_COD_I),; //"Pesquisando Item: "
              AADD(aRecno,SW5->(RECNO()) )}
   bWhile:={||SW5->(!EOF()) .AND.;
              cFilSW5         == SW5->W5_FILIAL.AND.;
              Work->W3_CC     == SW5->W5_CC    .AND.;
              Work->W3_SI_NUM == SW5->W5_SI_NUM}

   SW5->(DBSETORDER(4))
   SW5->(DBSEEK(cFilSW5+Work->W3_CC+Work->W3_SI_NUM))
   SW5->(DBEVAL(bGrava,,bWhile))

******************************************************************************

   ProcRegua(LEN(aRecno)*2)
   FOR I := 1 TO LEN(aRecno)
       IncProc(STR0164+SW5->W5_COD_I) //"Atualizando Item: "
       SW5->(DBGOTO(aRecno[I]))
       SW5->(RECLOCK("SW5",.F.))
       SW5->W5_CC := cCampo1
       SW5->(MSUNLOCK())
   NEXT

******************************************************************************
   IF lAltPo

			   MTab_HAWB:={}
			   aRecno:={}
			   nCont :=0
			   /*bGrava:={||IncProc(STR0163+SW7->W7_COD_I),; //"Pesquisando Item: "
			              IF(ASCAN(MTab_HAWB,SW7->W7_HAWB)=0,AADD(MTab_HAWB,SW7->W7_HAWB),),;
			              AADD(aRecno,SW7->(RECNO()) )}
			   //TDF
			   bWhile:={||SW7->(!EOF()) .AND.;
			              cFilSW7         == SW7->W7_FILIAL.AND.;
			              Work->W3_CC     == SW7->W7_CC    .AND.;
			              Work->W3_SI_NUM == SW7->W7_SI_NUM}*/
			
			   SW7->(DBSETORDER(3))
			   SW7->(DBSEEK(cFilSW7+Work->W3_CC+Work->W3_SI_NUM))
			   //SW7->(DBEVAL(bGrava,,bWhile))
			   
			   While SW7->(!EOF())                     .AND.;
			         cFilSW7         == SW7->W7_FILIAL .AND.;
			         Work->W3_CC     == SW7->W7_CC     .AND.;
			         Work->W3_SI_NUM == SW7->W7_SI_NUM 
			         
			      IncProc(STR0163+SW7->W7_COD_I)//"Pesquisando Item: "
			      IF(ASCAN(MTab_HAWB,SW7->W7_HAWB)=0)
			         AADD(MTab_HAWB,SW7->W7_HAWB)
			      EndIf
			      AADD(aRecno,SW7->(RECNO()))
			      
			   SW7->(DbSkip())
			   EndDo

			   ProcRegua(LEN(aRecno))
			   FOR I := 1 TO LEN(aRecno)
			       IncProc(STR0164+SW7->W7_COD_I) //"Atualizando Item: "
			       SW7->(DBGOTO(aRecno[I]))
			       SW7->(RECLOCK("SW7",.F.))
			       SW7->W7_CC := cCampo1
			       SW7->(MSUNLOCK())
			   NEXT
			ENDIF

******************************************************************************

   IF lAltPo

			   ProcRegua(LEN(MTab_HAWB))
			   FOR Ind := 1 TO LEN(MTab_HAWB)
			
			       nCont :=0
			       /*bGrava:={||IncProc(STR0164+SW8->W8_COD_I),; //"Atualizando Item: "
			                  SW8->(RECLOCK("SW8",.F.)),;
			                  SW8->W8_CC := cCampo1,;
			                  SW8->(MSUNLOCK())}
			
			       bFor  :={||Work->W3_CC     == SW8->W8_CC     .AND.;
			                  Work->W3_SI_NUM == SW8->W8_SI_NUM}
			
			       //TDF
			       bWhile:={||SW8->(!EOF()) .AND.;
			                  cFilSW8         == SW8->W8_FILIAL .AND.;
			                  MTab_HAWB[Ind]  == SW8->W8_HAWB}*/
			
			       SW8->(DBSETORDER(1))
			       SW8->(DBSEEK(cFilSW8+MTab_HAWB[Ind]))
			       //SW8->(DBEVAL(bGrava,bFor,bWhile))
			       
			       While SW8->(!EOF()) .AND. cFilSW8 == SW8->W8_FILIAL .AND. MTab_HAWB[Ind] == SW8->W8_HAWB
			          If Work->W3_CC == SW8->W8_CC .AND. Work->W3_SI_NUM == SW8->W8_SI_NUM  
			             IncProc(STR0164+SW8->W8_COD_I)//"Atualizando Item: "
			             SW8->(RECLOCK("SW8",.F.))
			             SW8->W8_CC := cCampo1
			             SW8->(MSUNLOCK())
			          EndIf
			       
			       SW8->(DbSkip())
			       EndDo
			
			   NEXT

   ENDIF
   ProcRegua(LEN(MTab_PO))
   FOR I := 1 TO LEN(MTab_PO)

       IncProc(STR0199+MTab_PO[I]) //"Gravando ocorrencia do P.O.: "

       TR175_GrvTXT(MTab_PO[I],STR0171,STR0118,; //"TODOS ALTERADOS"###"Unidade Requisitante"
                    cCampo1+" "+BuscaCCusto(cCampo1),;
                    cCampoA+" "+BuscaCCusto(cCampoA))

       MTexto:= STR0200+cCampoA+STR0190+cCampo1+STR0201+; //"ALT. U.R. DE "###" PARA "###" DA "
                " SI "+Work->W3_SI_NUM

       Grava_Ocor(MTab_PO[I], dDataBase,MTexto)

   NEXT

ENDCASE

******************************************************************************
/*
c_CC   := Work->W3_CC
cSI   := Work->W3_SI_NUM
cCod_I:= Work->W3_COD_I
cReg  := Work->W3_REG
nRec  := Work->(RECNO())
aRecno:= { }
nCont :=  0
bGrava:={||IncProc(STR0163+Work->W3_COD_I),; //"Pesquisando Item: "
           AADD(aRecno,Work->(RECNO()) )}
bWhile:={||Work->W3_CC     == c_CC .AND.;
           Work->W3_SI_NUM == cSI}
Work->(DBSEEK(c_CC+cSI))
Work->(DBEVAL({||nCont++},,bWhile))
ProcRegua(nCont*2)
Work->(DBSEEK(c_CC+cSI))
Work->(DBEVAL(bGrava,,bWhile))
******************************************************************************
FOR I := 1 TO LEN(aRecno)
    IncProc(STR0164+Work->W3_COD_I) //"Atualizando Item: "
    Work->(DBGOTO(aRecno[I]))
    IF PTipo == "CC"
       Work->W3_CC := cCampo1
    ELSEIF PTipo  == "FABR"         .AND.;
           cCod_I == Work->W3_COD_I .AND.;
           cReg   == Work->W3_REG
       Work->W3_FABR := cCampo1
    ENDIF
NEXT
Work->(DBGOTO(nRec))  */

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION TR175_Forn(cCampo1)
*----------------------------------------------------------------------------*
LOCAL aInvoice:={}, cAnt_CC_si:="", nRecno:=Work->(RECNO())
LOCAL bWhile, bFor, bGrava, nCont :=0, Ind

Work->(DBGOTOP())

DO WHILE Work->(!EOF())

   nCont :=0
   /*bGrava:={||IncProc(STR0164+SW1->W1_COD_I),; //"Atualizando Item: "
              SW1->(RECLOCK("SW1",.F.)),;
              SW1->W1_FORN := cCampo1,;
              SW1->(MSUNLOCK())}

   bFor  :={||(SW1->W1_PO_NUM = TPO_NUM .OR.;
               EMPTY(SW1->W1_PO_NUM))  .AND.;
              !EMPTY(SW1->W1_FORN)     .AND.;
               Work->W3_REG   == SW1->W1_REG}

   //TDF
   bWhile:={||SW1->(!EOF())                    .AND.;
              cFilSW1         == SW1->W1_FILIAL.AND.;
              Work->W3_CC     == SW1->W1_CC    .AND.;
              Work->W3_SI_NUM == SW1->W1_SI_NUM.AND.;
              Work->W3_COD_I  == SW1->W1_COD_I}*/

   ProcRegua(2)
   SW1->(DBSETORDER(1))
   SW1->(DBSEEK(cFilSW1+Work->W3_CC+Work->W3_SI_NUM+Work->W3_COD_I))
   //SW1->(DBEVAL(bGrava,bFor,bWhile))
   
   While SW1->(!EOF())                     .AND.;
         cFilSW1         == SW1->W1_FILIAL .AND.;
         Work->W3_CC     == SW1->W1_CC     .AND.;
         Work->W3_SI_NUM == SW1->W1_SI_NUM .AND.;
         Work->W3_COD_I  == SW1->W1_COD_I
         
      If (SW1->W1_PO_NUM = TPO_NUM .OR.;
          EMPTY(SW1->W1_PO_NUM))   .AND.;
          !EMPTY(SW1->W1_FORN)     .AND.;
          Work->W3_REG   == SW1->W1_REG
         
         IncProc(STR0164+SW1->W1_COD_I)//"Atualizando Item: "    
         SW1->(RECLOCK("SW1",.F.))
         SW1->W1_FORN := cCampo1
         SW1->(MSUNLOCK())     
      EndIf
      
   SW1->(DbSkip())
   EndDo

******************************************************************************

   IF cAnt_CC_si #  Work->W3_CC+Work->W3_SI_NUM

      cAnt_CC_si := Work->W3_CC+Work->W3_SI_NUM

      nCont :=0
      /*bGrava:={||IncProc(STR0164+SW3->W3_COD_I),; //"Atualizando Item: "
                 SW3->(RECLOCK("SW3",.F.)),;
                 SW3->W3_FORN := cCampo1,;
                 SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM))),;
                 AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                       IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
                       SW0->W0__POLE,SW3->W3_CC,;
                       SW3->W3_FORN,'01',SW2->W2_PO_DT,;
                       SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                       Nil,"EICTR175",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N"),;
                 SW3->(MSUNLOCK())}
      //TDF
      bWhile:={||SW3->(!EOF())                     .AND.;
                 cFilSW3         == SW3->W3_FILIAL .AND.;
                 TPO_NUM         == SW3->W3_PO_NUM .AND.;
                 Work->W3_CC     == SW3->W3_CC     .AND.;
                 Work->W3_SI_NUM == SW3->W3_SI_NUM}*/


      ProcRegua(SW3->(LASTREC()))
      SW3->(DBSETORDER(1))
      SW3->(DBSEEK(cFilSW3+TPO_NUM+Work->W3_CC+Work->W3_SI_NUM))
      SW2->(DBSETORDER(1))
      SW2->(DBSEEK(cFilSW2+SW3->W3_PO_NUM))
      SW0->(DBSETORDER(1))
      SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))   
      //SW3->(DBEVAL(bGrava,,bWhile))
      
      While SW3->(!EOF())                     .AND.;
            cFilSW3         == SW3->W3_FILIAL .AND.;
            TPO_NUM         == SW3->W3_PO_NUM .AND.;
            Work->W3_CC     == SW3->W3_CC     .AND.;
            Work->W3_SI_NUM == SW3->W3_SI_NUM
            
      IncProc(STR0164+SW3->W3_COD_I)//"Atualizando Item: "
      SW3->(RECLOCK("SW3",.F.))
      SW3->W3_FORN := cCampo1
      SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM)))
      
      If SW3->(FieldPos("W3_CTCUSTO")) > 0
         cCentroCusto := SW3->W3_CTCUSTO
      Else
         cCentroCusto := SW3->W3_CC
      EndIf
      
      If lEXECAUTO_COM .AND. cMV_EASY $ cSim
         AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                   IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
                   SW0->W0__POLE,cCentroCusto,;
                   SW3->W3_FORN,'01',SW2->W2_PO_DT,;
                   SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                   Nil,"EICTR175",Nil,SW3->W3_SI_NUM,SW3->W3_REG,SW2->W2_MOEDA,"N")
      EndIf             
      
      SW3->(MSUNLOCK())
      
      SW3->(DbSkip())      
      EndDo 
      
******************************************************************************      
/*bGrava:={||IncProc(STR0163+SW3->W3_COD_I),; //"Pesquisando Item: "
                 SW2->(RECLOCK("SW2",.F.)),;
                 SW2->W2_FORN := cCampo1,;
                 SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM))),;
                 SW2->(MSUNLOCK())}
//TDF
bWhile:={||SW2->(!EOF()) .AND.;
           cFilSW2== SW2->W2_FILIAL .AND.;
           TPO_NUM   == SW2->W2_PO_NUM}*/

      ProcRegua(SW2->(LASTREC()))
      SW3->(DBSETORDER(1))
      SW3->(DBSEEK(cFilSW3+TPO_NUM+Work->W3_CC+Work->W3_SI_NUM))
      SW2->(DBSETORDER(1))
      SW2->(DBSEEK(cFilSW2+SW3->W3_PO_NUM))
      SW0->(DBSETORDER(1))
      SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))         
      //SW2->(DBEVAL(bGrava,,bWhile))
      
      While SW2->(!EOF()) .AND. cFilSW2 == SW2->W2_FILIAL .AND. TPO_NUM == SW2->W2_PO_NUM
      
         IncProc(STR0163+SW3->W3_COD_I)//"Pesquisando Item: "
         SW2->(RECLOCK("SW2",.F.))
         SW2->W2_FORN := cCampo1
         SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM)))
         SW2->(MSUNLOCK())
                 
      SW2->(DbSkip())             
      EndDo          


******************************************************************************

      nCont :=0
      /*bGrava:={||IncProc(STR0164+SW5->W5_COD_I),; //"Atualizando Item: "
                 SW5->(RECLOCK("SW5",.F.)),;
                 SW5->W5_FORN := cCampo1,;
                 SW5->(MSUNLOCK())}
      bFor  :={||TPO_NUM         == SW5->W5_PO_NUM}
      //TDF
      bWhile:={||SW5->(!EOF())                     .AND.;
                 cFilSW5         == SW5->W5_FILIAL .AND.;
                 Work->W3_CC     == SW5->W5_CC     .AND.;
                 Work->W3_SI_NUM == SW5->W5_SI_NUM}*/

      ProcRegua(SW5->(LASTREC()))
      SW5->(DBSETORDER(4))
      SW5->(DBSEEK(cFilSW5+Work->W3_CC+Work->W3_SI_NUM))
      //SW5->(DBEVAL(bGrava,bFor,bWhile))
      
      While SW5->(!EOF())                     .AND.;
            cFilSW5         == SW5->W5_FILIAL .AND.;
            Work->W3_CC     == SW5->W5_CC     .AND.;
            Work->W3_SI_NUM == SW5->W5_SI_NUM
         
         If TPO_NUM == SW5->W5_PO_NUM 
            IncProc(STR0164+SW5->W5_COD_I)//"Atualizando Item: "
            SW5->(RECLOCK("SW5",.F.))
            SW5->W5_FORN := cCampo1
            SW5->(MSUNLOCK())
         EndIf     
      SW5->(DbSkip()) 
      EndDo
      
******************************************************************************
			   IF lAltPo
			
			      MTab_HAWB:={ }
			      nCont    := 0
			      /*bGrava:={||IncProc(STR0164+SW7->W7_COD_I),; //"Atualizando Item: "
			                 IF(ASCAN(MTab_HAWB,SW7->W7_HAWB)=0,AADD(MTab_HAWB,;
			                 SW7->W7_HAWB),),;
			                 SW7->(RECLOCK("SW7",.F.)),;
			                 SW7->W7_FORN := cCampo1,;
			                 SW7->(MSUNLOCK())}
			      bFor  :={||TPO_NUM         == SW7->W7_PO_NUM}
			      //TDF
			      bWhile:={||SW7->(!EOF()) .AND.;
			                 cFilSW7         == SW7->W7_FILIAL .AND.;
			                 Work->W3_CC     == SW7->W7_CC     .AND.;
			                 Work->W3_SI_NUM == SW7->W7_SI_NUM}*/
			
			      ProcRegua(SW7->(LASTREC()))
			      SW7->(DBSETORDER(3))
			      SW7->(DBSEEK(cFilSW7+Work->W3_CC+Work->W3_SI_NUM))
			      //SW7->(DBEVAL(bGrava,bFor,bWhile))
			      
			     While SW7->(!EOF())                     .AND.;
			           cFilSW7         == SW7->W7_FILIAL .AND.;
			           Work->W3_CC     == SW7->W7_CC     .AND.;
			           Work->W3_SI_NUM == SW7->W7_SI_NUM
			        
			        If TPO_NUM == SW7->W7_PO_NUM
			           IncProc(STR0164+SW7->W7_COD_I)//"Atualizando Item: "
			           
			           IF(ASCAN(MTab_HAWB,SW7->W7_HAWB)=0)
			              AADD(MTab_HAWB,SW7->W7_HAWB)
			           EndIf
			           
			        SW7->(RECLOCK("SW7",.F.))
			        SW7->W7_FORN := cCampo1
			        SW7->(MSUNLOCK())
			        
			        EndIf
  
			      SW7->(DbSkip())
			      EndDo
			   
			   ENDIF
			
*****************************************************************************
			   IF lAltPo
			
			      FOR Ind := 1 TO LEN(MTab_HAWB)
			
			          aInvoice:={}
			          nCont :=0
			          /*bGrava:={||IncProc(STR0164+SW8->W8_COD_I),; //"Atualizando Item: "
			                     IF(ASCAN(aInvoice,{|Invoice| Invoice[1] == SW8->W8_INVOICE .AND.;
			                     Invoice[2] == SW8->W8_FORN}) = 0,;
			                     AADD(aInvoice,{SW8->W8_INVOICE,SW8->W8_FORN}),),;
			                     SW8->(RECLOCK("SW8",.F.)),;
			                     SW8->W8_FORN := cCampo1,;
			                     SW8->(MSUNLOCK())}
			
			          bFor  :={||TPO_NUM         == SW8->W8_PO_NUM.AND.;
			                     Work->W3_CC     == SW8->W8_CC    .AND.;
			                     Work->W3_SI_NUM == SW8->W8_SI_NUM}
			
			          //TDF
			          bWhile:={||SW8->(!EOF())                     .AND.;
			                     cFilSW8         == SW8->W8_FILIAL .AND.;
			                     MTab_HAWB[Ind]  == SW8->W8_HAWB}*/
			
			          ProcRegua(SW8->(LASTREC()))
			          SW8->(DBSETORDER(3))
			          SW8->(DBSEEK(cFilSW8+MTab_HAWB[Ind]))
			          //SW8->(DBEVAL(bGrava,bFor,bWhile))
			          
			          While SW8->(!EOF())                     .AND.;
			                cFilSW8         == SW8->W8_FILIAL .AND.;
			                MTab_HAWB[Ind]  == SW8->W8_HAWB
			                
			             If TPO_NUM         == SW8->W8_PO_NUM .AND.;
			                Work->W3_CC     == SW8->W8_CC     .AND.;
			                Work->W3_SI_NUM == SW8->W8_SI_NUM
			             
			                IncProc(STR0164+SW8->W8_COD_I)//"Atualizando Item: "
			             
			                IF(ASCAN(aInvoice,{|Invoice| Invoice[1] == SW8->W8_INVOICE .AND.;
			                   Invoice[2] == SW8->W8_FORN}) = 0)
			                   AADD(aInvoice,{SW8->W8_INVOICE,SW8->W8_FORN})
			                EndIf
			             
			                SW8->(RECLOCK("SW8",.F.))
			                SW8->W8_FORN := cCampo1
			                SW8->(MSUNLOCK())
			             EndIf
			              
			          SW8->(DbSkip()) 
			          EndDo

			
			          bGrava:={||IncProc(STR0165+SW9->W9_INVOICE),; //"Atualizando Invoice: "
			                     SW9->(RECLOCK("SW9",.F.)),;
			                     SW9->W9_FORN    := cCampo1,;
			                     SW9->W9_NOM_FOR := BuscaFabr_Forn(cCampo1),;
			                     SW9->(MSUNLOCK())}
			
			          bFor:={||(ASCAN(aInvoice,{|Invoice|Invoice[1] == SW9->W9_INVOICE .AND.;
			                                     Invoice[2]         == SW9->W9_FORN})) # 0}
			                                     
			          bWhile:={||SW9->(!EOF()) .AND.;
			                     SW9->W9_FILIAL==cFilSW9.AND.;
			                     SW9->W9_HAWB==MTab_HAWB[Ind]}
			          nCont :=0
			
			          ProcRegua(SW9->(LASTREC()))
			          SW9->(DBSETORDER(3))
			          SW9->(DBSEEK(cFilSW9+MTab_HAWB[Ind]))
			          SW9->(DBEVAL(bGrava,bFor,bWhile))
			
			      NEXT
			   ENDIF
			******************************************************************************
			   MTexto:=STR0166+cCampoA+STR0167+cCampo1+STR0168+; //"ALT. FORN. DE "###" P/ "###" DA U.R. "
			           Work->W3_CC+STR0169+Work->W3_SI_NUM //" SI "
			
			   Grava_Ocor(TPO_NUM, dDataBase,MTexto)
			
   ENDIF

   Work->(DBSKIP())

ENDDO
/*
Work->(DBGOTOP())
Work->(DBEVAL({||Work->W3_FORN:=cCampo1}))*/

TR175_GrvTXT(TPO_NUM,STR0171,AVSX3("W3_FORN",05),; //"TODOS ALTERADOS"###STR0056"Fornecedor"
             cCampo1+" "+BuscaF_F(cCampo1),;
             cCampoA+" "+BuscaF_F(cCampoA))

SW2->(DBSEEK(cFilSW2+TPO_NUM))
SW2->(RECLOCK("SW2",.F.))
SW2->W2_FORN := cCampo1
SW2->(MSUNLOCK())

Work->(DBGOTO(nRecno))

RETURN

*----------------------------------------------------------------------------*
FUNCTION TR175Saldo(TSaldo,TSaldo_A,cPict)
*----------------------------------------------------------------------------*
LOCAL MTot_IG, MTot_IP, nCont:=0
//LOCAL bGrava,bFor,bWhile

ProcRegua(SW3->(LASTREC()))//Padrao + ou -

SW5->(DBGOTO(WorkPgi->WKRECNO))
SW5->(RECLOCK("SW5",.F.))
SW5->W5_SALDO_Q := TSaldo
SW5->W5_QTDE    := SW5->W5_QTDE + (TSaldo - TSaldo_A)
SW5->(MSUNLOCK())

WorkPgi->W3_SALDO_Q := TSaldo
WorkPgi->W3_QTDE    := WorkPgi->W3_QTDE + (TSaldo - TSaldo_A)

******************************************************************************

MTot_IG:=0
/*bGrava :={||IncProc(STR0164+SW5->W5_COD_I),; //"Atualizando Item: "
            MTot_IG += SW5->W5_QTDE * SW5->W5_PRECO}
bFor   :={||SW5->W5_SEQ = 0}

//TDF
bWhile :={||SW5->(!EOF())              .AND.;
            SW5->W5_FILIAL  == cFilSW5 .AND.;
            SW5->W5_PGI_NUM == WorkPgi->W5_PGI_NUM}*/

SW5->(DBSETORDER(1))
SW5->(DBSEEK(cFilSW5+WorkPgi->W5_PGI_NUM))
//SW5->(DBEVAL(bGrava,bFor,bWhile))

While SW5->(!EOF())              .AND.;
      SW5->W5_FILIAL  == cFilSW5 .AND.;
      SW5->W5_PGI_NUM == WorkPgi->W5_PGI_NUM
   
   If SW5->W5_SEQ = 0
      IncProc(STR0164+SW5->W5_COD_I)//"Atualizando Item: "
      MTot_IG += SW5->W5_QTDE * SW5->W5_PRECO
   EndIf            

SW5->(DbSkip()) 
EndDo 


SW4->(DBSETORDER(1))
IF SW4->(DBSEEK(cFilSW4+WorkPgi->W5_PGI_NUM)) .AND. MTot_IG <> 0
   IncProc(STR0175+SW5->W5_PGI_NUM) //"Atualizando PGI: "
   SW4->(RECLOCK("SW4",.F.))
   SW4->W4_FOB_TOT:=MTot_IG
   SW4->(MSUNLOCK())
ENDIF

******************************************************************************

/*bGrava :={||IncProc(STR0164+SW3->W3_COD_I),; //"Atualizando Item: "
            SW3->(RECLOCK("SW3",.F.)),;
            SW3->W3_QTDE := SW3->W3_QTDE + (TSaldo - TSaldo_A),;
            SW3->(MSUNLOCK()),IF(EMPTY(SW3->W3_PGI_NUM),;// EMPTY(SW3->W3_PGI_NUM): Para gravar apenas
            (SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM))),;//quatidade total do item no SC7
            AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
                       IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
                       SW0->W0__POLE,SW3->W3_CC,;
                       SW3->W3_FORN,'01',SW2->W2_PO_DT,;
                       SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
                       Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG)),),;
                       DBSELECTAREA("SW3")}

bFor   :={||Work->W3_FABR       == SW3->W3_FABR   .AND.;
            Work->W3_FORN       == SW3->W3_FORN   .AND.;
            WorkPgi->W3_REG     == SW3->W3_REG    .AND.;
            (WorkPgi->W5_PGI_NUM== SW3->W3_PGI_NUM .OR.;
            EMPTY(SW3->W3_PGI_NUM))}
//TDF
bWhile :={||SW3->(!EOF())                     .AND.;
            cFilSW3         == SW3->W3_FILIAL .AND.;
            TPO_NUM         == SW3->W3_PO_NUM .AND.;
            Work->W3_CC     == SW3->W3_CC     .AND.;
            Work->W3_SI_NUM == SW3->W3_SI_NUM .AND.;
            Work->W3_COD_I  == SW3->W3_COD_I}*/

SW3->(DBSETORDER(1))
SW3->(DBSEEK(cFilSW3+TPO_NUM+Work->W3_CC+Work->W3_SI_NUM+Work->W3_COD_I))
SW2->(DBSETORDER(1))
SW2->(DBSEEK(cFilSW2+SW3->W3_PO_NUM))
SW0->(DBSETORDER(1))
SW0->(DBSEEK(cFilSW0+SW3->W3_CC+SW3->W3_SI_NUM))   
//SW3->(DBEVAL(bGrava,bFor,bWhile))

While SW3->(!EOF())                     .AND.;
      cFilSW3         == SW3->W3_FILIAL .AND.;
      TPO_NUM         == SW3->W3_PO_NUM .AND.;
      Work->W3_CC     == SW3->W3_CC     .AND.;
      Work->W3_SI_NUM == SW3->W3_SI_NUM .AND.;
      Work->W3_COD_I  == SW3->W3_COD_I
      
   If Work->W3_FABR       == SW3->W3_FABR   .AND.;
      Work->W3_FORN       == SW3->W3_FORN   .AND.;
      WorkPgi->W3_REG     == SW3->W3_REG    .AND.;
     (WorkPgi->W5_PGI_NUM== SW3->W3_PGI_NUM .OR.;
      EMPTY(SW3->W3_PGI_NUM))
      
      IncProc(STR0164+SW3->W3_COD_I)//"Atualizando Item: "
      SW3->(RECLOCK("SW3",.F.))
      SW3->W3_QTDE := SW3->W3_QTDE + (TSaldo - TSaldo_A)
      SW3->(MSUNLOCK()) 
      
      IF(EMPTY(SW3->W3_PGI_NUM))// EMPTY(SW3->W3_PGI_NUM): Para gravar apenas
         SW0->(dbSeek(xFilial("SW0")+SW3->(W3_CC+W3_SI_NUM)))//quatidade total do item no SC7
      EndIF
            
      If SW3->(FieldPos("W3_CTCUSTO")) > 0
         cCentroCusto := SW3->W3_CTCUSTO
      Else
         cCentroCusto := SW3->W3_CC
      EndIf
      
      If lEXECAUTO_COM .AND. cMV_EASY $ cSim
         AVGravaSC7(2,SW3->W3_COD_I,SW3->W3_QTDE,SW3->W3_PRECO,;
         IF(!EMPTY(ALLTRIM(SW2->W2_PO_SIGA)),SW2->W2_PO_SIGA,LEFT(SW3->W3_PO_NUM,6)),;
         SW0->W0__POLE,cCentroCusto,;
         SW3->W3_FORN,'01',SW2->W2_PO_DT,;
         SW0->W0_C1_NUM,SW3->W3_DT_ENTR,SW3->W3_POSICAO,SW3->W3_POSICAO,;
         Nil,"EICPO400",Nil,SW3->W3_SI_NUM,SW3->W3_REG)
      EndIf   
      DBSELECTAREA("SW3")
           
   EndIf
SW3->(DbSkip())             
EndDo




******************************************************************************

nCont  := 0
MTot_IP:= 0
/*bGrava :={||IncProc(STR0164+SW3->W3_COD_I),; //"Atualizando Item: "
            MTot_IP+=SW3->W3_QTDE * SW3->W3_PRECO}
bFor   :={||SW3->W3_SEQ = 0}
//TDF
bWhile :={||SW3->(!EOF()) .AND.;
            cFilSW3 = SW3->W3_FILIAL .AND.;
            TPO_NUM=SW3->W3_PO_NUM} */

SW3->(DBSEEK(cFilSW3+TPO_NUM))
//SW3->(DBEVAL(bGrava,bFor,bWhile))

While SW3->(!EOF())            .AND.;
      cFilSW3 = SW3->W3_FILIAL .AND.;
      TPO_NUM=SW3->W3_PO_NUM
   
   If SW3->W3_SEQ = 0
      IncProc(STR0164+SW3->W3_COD_I)//"Atualizando Item: "
      MTot_IP+=SW3->W3_QTDE * SW3->W3_PRECO
   EndIF

SW3->(DbSkip())
EndDo

IF MTot_IP <> 0
   IncProc(STR0202+TPO_NUM) //"Atualizando Capa PO: "
   SW2->(RECLOCK("SW2",.F.))
   SW2->W2_FOB_TOT := MTot_IP
   SW2->(MSUNLOCK())
ENDIF

******************************************************************************

/*bGrava:={||IncProc(STR0164+SW1->W1_COD_I),; //"Atualizando Item: "
           SW1->(RECLOCK("SW1",.F.))    ,;               
           nQTDE := SW1->W1_QTDE + (TSaldo - TSaldo_A),;
           SW1->W1_QTSEGUM :=( SW1->W1_QTSEGUM / SW1->W1_QTDE * nQtdE),;
           SW1->W1_QTDE := SW1->W1_QTDE + (TSaldo - TSaldo_A)    ,;
           SW1->(MSUNLOCK()) ,;
           TR175_SC1()}       

//bGrava:={||IncProc(STR0164+SW1->W1_COD_I),; //"Atualizando Item: "
          // SW1->(RECLOCK("SW1",.F.)),;
          // SW1->W1_QTDE := SW1->W1_QTDE + (TSaldo - TSaldo_A),;
          // SW1->(MSUNLOCK())}

bFor  :={||(SW1->W1_PO_NUM == TPO_NUM .OR. EMPTY(SW1->W1_PO_NUM)).AND.;
      (Work->W3_FABR  == SW1->W1_FABR .OR. EMPTY(SW1->W1_FABR))  .AND.;
      (Work->W3_FORN  == SW1->W1_FORN .OR. EMPTY(SW1->W1_FORN))  .AND.;
       WorkPgi->W3_REG== SW1->W1_REG}

bWhile :={||SW1->(!EOF())                    .AND.;
            cFilSW1         == SW1->W1_FILIAL.AND.;
            Work->W3_CC     == SW1->W1_CC    .AND.;
            Work->W3_SI_NUM == SW1->W1_SI_NUM.AND.;
            Work->W3_COD_I  == SW1->W1_COD_I}*/

SW1->(DBSETORDER(1))
SW1->(DBSEEK(cFilSW1+Work->W3_CC+Work->W3_SI_NUM+Work->W3_COD_I))
//SW1->(DBEVAL(bGrava,bFor,bWhile))  

While SW1->(!EOF())                     .AND.;
      cFilSW1         == SW1->W1_FILIAL .AND.;
      Work->W3_CC     == SW1->W1_CC     .AND.;
      Work->W3_SI_NUM == SW1->W1_SI_NUM .AND.;
      Work->W3_COD_I  == SW1->W1_COD_I
   
   If (SW1->W1_PO_NUM  == TPO_NUM     .OR. EMPTY(SW1->W1_PO_NUM)).AND.;
      (Work->W3_FABR  == SW1->W1_FABR .OR. EMPTY(SW1->W1_FABR))  .AND.;
      (Work->W3_FORN  == SW1->W1_FORN .OR. EMPTY(SW1->W1_FORN))  .AND.;
      WorkPgi->W3_REG == SW1->W1_REG
      
      IncProc(STR0164+SW1->W1_COD_I) //"Atualizando Item: "
      SW1->(RECLOCK("SW1",.F.))               
      nQTDE := SW1->W1_QTDE + (TSaldo - TSaldo_A)
      SW1->W1_QTSEGUM :=( SW1->W1_QTSEGUM / SW1->W1_QTDE * nQtdE)
      SW1->W1_QTDE := SW1->W1_QTDE + (TSaldo - TSaldo_A)
      SW1->(MSUNLOCK())
      TR175_SC1()
   
   EndIf
SW1->(DbSkip())
EndDo

******************************************************************************

IncProc(STR0164+Work->W3_COD_I) //"Atualizando Item: "

Work->W3_QTDE := Work->W3_QTDE + (TSaldo - TSaldo_A)

TR175_GrvTXT(TPO_NUM,Work->W3_COD_I,STR0203,; //"Saldo Quantidade"
             ALLTRIM(TRAN(TSaldo,cPict)),;
             ALLTRIM(TRAN(TSaldo_A,cPict)))

MTexto := STR0204+ALLTRIM(TRAN(TSaldo_A,cPict))+STR0167  +; //"ALT. SDO. QTDE. DE "###" P/ "
          ALLTRIM(TRAN(TSaldo,cPict))+STR0205+Work->W3_COD_I+"/"+Work->W3_CC+; //"/"
          "/"+Work->W3_SI_NUM +"/"+WorkPgi->W4_GI_NUM

Grava_Ocor(TPO_NUM, dDataBase,MTexto)

RETURN .T.

*-----------------------------------------------------------*
FUNCTION TR175_GrvTXT(PPO_NUM,PCod_I,PCampo,PNovo,PAntigo)
*-----------------------------------------------------------*
WorkImp->(DBAPPEND())
WorkImp->WK_HORA   :=TIME()
WorkImp->WK_DATA   :=dDataBase
WorkImp->W3_PO_NUM :=PPO_NUM
WorkImp->W3_COD_I  :=PCod_I
WorkImp->WK_CAMPO  :=PCampo
WorkImp->WK_DE     :=PAntigo
WorkImp->WK_PARA   :=PNovo
RETURN

*----------------------------------------------------------------------------*
FUNCTION TR175_Relatorio()
*----------------------------------------------------------------------------*
#DEFINE COURIER_BOLD_08 oFont1
#DEFINE COURIER_08      oFont2
#DEFINE COURIER_10      oFont3

IF WorkImp->(BOF()) .AND. WorkImp->(EOF())
   HELP("",1,"AVG0002052") //N∆o houve alteraá‰es
   RETURN .T.
ENDIF

PRINT oPrn NAME ""
      oPrn:SetLandsCape()
ENDPRINT

AVPRINT oPrn NAME cTitulo

   DEFINE FONT oFont1  NAME "Courier New" SIZE 0,08 BOLD OF  oPrn
   DEFINE FONT oFont2  NAME "Courier New" SIZE 0,08      OF  oPrn
   DEFINE FONT oFont3  NAME "Courier New" SIZE 0,10      OF  oPrn

   AVPAGE

      oPrn:oFont:=COURIER_08

      MPag    := 0
      lPrimPag:= .T.
      MLin    := 9999
      nLimPage:= 2200
      nColFim := 3100
      nColIni := 0001

//    nCol1:=nColIni      ; nCol2:=QC210xCol(17); nCol3:=QC210xCol(53)
//    nCol4:=QC210xCol(44); nCol5:=QC210xCol(65); nCol6:=QC210xCol(87)
//    nCol7:=QC210xCol(92.5)

      nCol1:=nColIni
      nCol2:=QC210xCol(17)
      nCol4:=nCol2+QC210xCol(len(WorkImp->W3_COD_I)+2)
      nCol3:=nCol4+QC210xCol(9)
      nCol5:=nCol3+QC210xCol(12)
      nCol6:=nCol5+QC210xCol(22)
      nCol7:=nCol6+QC210xCol(5.5)

      Processa({||ProcRegua(WorkImp->(LASTREC())),;
                  WorkImp->(DBEVAL({||TR175_Detalhe()}))},STR0207) //"Impressao..."

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()

RETURN .T.

*--------------------------*
FUNCTION TR175_Cabecalho()
*--------------------------*
LOCAL cTitulo1:=OemToAnsi(STR0208)+cTitulo //"Relat¢rio de "
LOCAL cTitulo2:=STR0209+ALLTRIM(cUserName) //"Usuario: "
LOCAL cC01:=STR0210 //"  Nro. Pedido"
LOCAL cC02:=STR0211 //"    Produto"
LOCAL cC03:=STR0212 //"Dt. Alt."
LOCAL cC04:=STR0213 //"Horario"
LOCAL cC05:=STR0214 //"   Campo Alterado"
LOCAL cC06:=REPL(" ",LEN(WorkImp->WK_DE)/2-5)+STR0215 //"Alteracao"

IF lPrimPag
   lPrimPag:=.F.
ELSE
   AVNEWPAGE
ENDIF

MLin:= 100
MPag++

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=25

oPrn:Say(MLin,nColIni  ,SM0->M0_NOME,COURIER_10)
oPrn:Say(MLin,nColFim/2,cTitulo1,COURIER_10,,,,2)
oPrn:Say(MLin,nColFim  ,STR0216+STR(MPag,8),COURIER_10,,,,1) //"Pagina..: "
MLin+=50

oPrn:Say(MLin,nColIni  ,STR0217,COURIER_10) //"SIGAEIC"
oPrn:Say(MLin,nColFim/2,cTitulo2,COURIER_10,,,,2)
oPrn:Say(MLin,nColFim  ,STR0218+DTOC(dDataBase),COURIER_10,,,,1) //"Emissao.: "
MLin+=50

oPrn:Box( MLin,nColIni,MLin+1,nColFim)
MLin+=50

oPrn:oFont:=COURIER_08
oPrn:Say(MLin,nCol1,cC01)
oPrn:Say(MLin,nCol2,cC02)
oPrn:Say(MLin,nCol3,cC03)
oPrn:Say(MLin,nCol4,cC04)
oPrn:Say(MLin,nCol5,cC05)
oPrn:Say(MLin,nCol6,cC06)
MLin +=20

cC01:=WorkImp->W3_PO_NUM
cC02:=WorkImp->W3_COD_I
cC03:=DTOC(WorkImp->WK_DATA)
cC04:=WorkImp->WK_HORA
cC05:=WorkImp->WK_CAMPO
cC06:=WorkImp->WK_DE //+SPACE(6)

oPrn:Say(MLin,nCol1,REPL("-",LEN(cC01)))
oPrn:Say(MLin,nCol2,REPL("-",LEN(cC02)))
oPrn:Say(MLin,nCol3,REPL("-",LEN(cC03)))
oPrn:Say(MLin,nCol4,REPL("-",LEN(cC04)))
oPrn:Say(MLin,nCol5,REPL("-",LEN(cC05)))
oPrn:Say(MLin,nCol6,REPL("-",LEN(cC06)-5))
MLin +=25

RETURN .T.

*----------------------*
FUNCTION TR175_Detalhe()
*----------------------*

IncProc(STR0219+WorkImp->W3_COD_I) //"Imprimindo Item: "

IF MLin > nLimPage
   TR175_Cabecalho()
ENDIF

oPrn:oFont:=COURIER_08
oPrn:Say(MLin,nCol1,WorkImp->W3_PO_NUM)
oPrn:Say(MLin,nCol2,WorkImp->W3_COD_I)
oPrn:Say(MLin,nCol3,DTOC(WorkImp->WK_DATA))
oPrn:Say(MLin,nCol4,WorkImp->WK_HORA)
oPrn:Say(MLin,nCol5,WorkImp->WK_CAMPO)
oPrn:Say(MLin,nCol6,STR0220) //"DE:"
oPrn:Say(MLin,nCol7,ALLTRIM(WorkImp->WK_DE))
MLin +=40
oPrn:Say(MLin,nCol6,STR0221,COURIER_BOLD_08) //"PARA:"
oPrn:Say(MLin,nCol7,ALLTRIM(WorkImp->WK_PARA))
MLin +=40

RETURN .T.


*---------------------------------------------------------------------------*
FUNCTION TR175HLPA5(PTipo,cCampo1,cCampo2)
*---------------------------------------------------------------------------*
LOCAL oDlg, cArqHlp, Tb_Campos:={}, OldArea:=SELECT()
LOCAL bAction:={||cCampo1:=Work_Hlp->A5_FORNECE,oDlg:End()}
LOCAL I:=1,W:=1,cCodigo:="",cTitulo:=""

LOCAL bGrava:={||SA2->(DBSEEK(cFilSA2+SA5->(FIELDGET(W)))) ,;
                 Work_Hlp->(DBAPPEND())                    ,;
                 Work_Hlp->A5_FORNECE := SA5->(FIELDGET(W)),;
                 Work_Hlp->A2_NOME    := SA2->A2_NOME}

LOCAL bWhile:={||cFilSA5==xFilial("SA5")           .AND.;
                 SA5->A5_PRODUTO == Work->W3_COD_I .AND.;
                 SA5->(FIELDGET(I)) == cCodigo}

IF !UPPER(ReadVar()) $ "CCAMPO1,CCAMPO2"
   RETURN .F.
ENDIF

aCampos:={}
AADD(aCampos,"A5_FORNECE")
AADD(Tb_Campos,{"A5_FORNECE",,"Codigo"})

IF PTipo="FORN"

   AADD(aCampos,"A2_NOME")
   AADD(Tb_Campos,{{||LEFT(Work_Hlp->A2_NOME,25)},,"Nome"})
   SA5->(DBSETORDER(3))
   SA5->(DBSEEK(xFilial()+Work->W3_COD_I+Work->W3_FABR))
   I:=SA5->(FIELDPOS("A5_FABR"))
   W:=SA5->(FIELDPOS("A5_FORNECE"))
   cCodigo:=Work->W3_FABR
   cTitulo:=STR0222+ALLTRIM(Work->W3_COD_I)+; //"Consulta Forn's do Item: "
            STR0038+ALLTRIM(Work->W3_FABR) //" / Fabr.: "

ELSEIF PTipo="FABR"

   AADD(aCampos,"A2_NOME")
   AADD(Tb_Campos,{{||LEFT(Work_Hlp->A2_NOME,25)},,STR0223}) //"Nome"
   SA5->(DBSETORDER(2))
   SA5->(DBSEEK(xFilial()+Work->W3_COD_I+Work->W3_FORN))
   I:=SA5->(FIELDPOS("A5_FORNECE"))
   W:=SA5->(FIELDPOS("A5_FABR"))
   cCodigo:=Work->W3_FORN
   cTitulo:=STR0224+ALLTRIM(Work->W3_COD_I)+; //"Consulta Fabr's do Item: "
            STR0035+ALLTRIM(Work->W3_FORN) //" / Forn.: "
ELSE

   Tb_Campos[1][3]:="Forn."
   AADD(Tb_Campos,{"A5_LOJA",,"Loja"})
   AADD(Tb_Campos,{"A5_FABR",,"Fabr."})
   AADD(aCampos,"A5_LOJA")
   AADD(aCampos,"A5_FABR")

   bAction:={||cCampo1:=Work_Hlp->A5_FORNECE,;
               cCampo2:=Work_Hlp->A5_FABR,oDlg:End(),;
               oCampo2:Refresh()}
   bGrava :={||Work_Hlp->(DBAPPEND())                    ,;
               Work_Hlp->A5_FORNECE := SA5->A5_FORNECE   ,;
               Work_Hlp->A5_LOJA    := SA5->A5_LOJA      ,;
               Work_Hlp->A5_FABR    := SA5->A5_FABR}
   bWhile :={||cFilSA5==xFilial("SA5")     .AND.;
               SA5->A5_PRODUTO == Work->W3_COD_I}
   SA5->(DBSETORDER(2))
   SA5->(DBSEEK(xFilial()+Work->W3_COD_I))

   cTitulo:=STR0225+ALLTRIM(Work->W3_COD_I) //"Consulta Forn. / Fabr. do Item: "


ENDIF

cArqHlp:=E_CriaTrab(,,"Work_Hlp")

SA5->(DBEVAL(bGrava,,bWhile))

Work_Hlp->(dbGoTop())

oMainWnd:ReadClientCoords()
DEFINE MSDIALOG oDlg TITLE cTitulo ;
     FROM 9,0 TO 20,60 of oMainWnd
//   FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
//   OF oMainWnd PIXEL  

    oMark:= MsSelect():New("Work_Hlp",,,TB_Campos,.F.,"X",{20,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
    oMark:baval:=bAction

    DEFINE SBUTTON FROM 05,146 TYPE 1 ACTION (EVAL(bAction)) ENABLE OF oDlg PIXEL
    DEFINE SBUTTON FROM 05,180 TYPE 2 ACTION (oDlg:End())    ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg

SA5->(DBSETORDER(1))
E_EraseArq(cArqHlp)
DBSELECTAREA(OldArea)

RETURN .T.

*-----------------------*
STATIC FUNCTION CHECKDI()
*-----------------------*
Local nOrd1,nOrd2, aHawb:={}, X

DBSELECTAREA("SF1")
SF1->(DBSETORDER(5))
DBSELECTAREA("SW6")
nOrd1:=SW6->(INDEXORD())
SW6->(DBSETORDER(1))
DBSELECTAREA("SW7")
nOrd2:=SW7->(INDEXORD())
SW7->(DBSETORDER(2))

SW7->(DBSEEK(xFILIAL("SW7")+TPO_NUM))
DO WHILE !SW7->(EOF()) .AND. xFILIAL("SW7")==SW7->W7_FILIAL .AND.;
          SW7->W7_PO_NUM == TPO_NUM
   IF !aScan(aHawb,SW7->W7_HAWB) > 0
      AADD(aHawb,{SW7->W7_HAWB})
   ENDIF
   SW7->(DBSKIP())
ENDDO
FOR X:=1 TO LEN(aHawb)
    IF SW6->(DBSEEK(xFILIAL("SW6")+aHAWB[X,1]))
       //ISS - 13/12/10 - Incluido tratamento caso o sistema tenha geraÁ„o de nota de despesa (NFD)
       IF SF1->(DBSEEK(xFILIAL("SF1")+SW6->W6_HAWB)) .AND. If(lCposNFDesp,ExistHAWBNFE(SW6->W6_HAWB),.T.)
          lAltPo:= .F.
       ELSEIF lEic_Eco .and. EC2->(DBSEEK(xFILIAL("EC2")+SW6->W6_HAWB)) 
          lAltPo:= .F.
       ENDIF
    ENDIF
NEXT                  

SW6->(DBSETORDER(nOrd1))
SW7->(DBSETORDER(nOrd2))
RETURN .T. 

*-----------------------*
FUNCTION TR175_SC1() // RJB 16/06/2004
*-----------------------*

IF SW1->W1_SEQ <> 0
   RETURN .T.
ENDIF

SW0->(DBSETORDER(1))
SW0->(DBSEEK(cFilSW1+SW1->W1_CC+SW1->W1_SI_NUM))   

If EasyGParam("MV_EASY") $ cSim .And. !Empty(SW0->W0_C1_NUM)
   If SC1->(DbSeek(xFilial('SC1')+SW0->W0_C1_NUM+RIGHT(SW1->W1_POSICAO,4)))
      SC1->(RecLock("SC1",.F.))
      IF GetNewPar("MV_UNIDCOM",2) == 2 .AND. SC1->C1_QTSEGUM <> 0 // RJB 16/06/2004
         SC1->C1_QUANT  := SW1->W1_QTSEGUM
         SC1->C1_QUJE   := SW1->W1_QTSEGUM  // QTDE NO PEDIDO
         SC1->C1_QTSEGUM:= SW1->W1_QTDE
      ELSE
         SC1->C1_QUANT  := SW1->W1_QTDE
         SC1->C1_QUJE   := SW1->W1_QTDE     // QTDE NO PEDIDO
         SC1->C1_QTSEGUM:= SW1->W1_QTSEGUM
      ENDIF
      SC1->(MsUnlock())
   Endif
Endif   

RETURN .T.                              

/*------------------------------------------------------------------------------------
Funcao      : TR175ValAlt
Parametros  : Tipo do Parametro para a validaÁ„o.
Retorno     :
Objetivos   : ValidaÁ„o do Acerto de PO
Autor       : Saimon Vinicius Gava
Data/Hora   : 03/04/09
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/
/*----------------------------* //CCH - 29/05/09 - Desnecess·rio bloqueio pois o tratamento de opÁıes especÌficas por item foi desenvolvido
FUNCTION TR175ValAlt(pTipo)
*----------------------------*
SWB->(DbSetOrder(1))
SW7->(DbSetOrder(2))

Do Case
  // Case pTipo $ "PO/PRECO/EMBAR/CP/INLAD/PACK/DESC/FRETE/SQ/FORN" CCH - 18/05/09 - Removida validaÁ„o por PO na seleÁ„o do PO
   Case pTipo $ "PRECO/EMBAR/CP/INLAD/PACK/DESC/FRETE/SQ/FORN"
      If SW7->(DbSeek(xFilial()+TPO_NUM))
         Alert("Pedido em Andamento, n„o permitido o acerto.")
         nOpca := 0
         Return .F.
      ElseIf SWB->(DbSeek(xFilial()+TPO_NUM))
         Alert("Pedido com C‚mbio, n„o permitido o acerto.")
         nOpca := 0
         Return .F.
      EndIf
   Case pTipo $ "FFB/FABR/FBFO/CC/IN"
      If SW7->(DbSeek(xFilial()+TPO_NUM))
         Alert("Pedido em Andamento, n„o permitido o acerto.")
         nOpca := 0
         Return .F.
      EndIf
EndCase


Return .T.*/
                         
/*------------------------------------------------------------------------------------
Funcao      : TR175ValStatus
Parametros  : CÛdigo do Item
Retorno     : cStatus (Embarcado/N„o Embarcado/Parcialmente Embarcado)
Objetivos   : Retornar o Status de Item do PO selecionado
Autor       : Caio CÈsar Henrique
Data/Hora   : 15/05/09
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/

Static Function TR175ValStatus(cItem,cPosicao,cPgi_Num)
               
Local cStatus := ""   
Local aOrd := {}       
Local cItPO := &cItem
Local cItPosic:= &cPosicao
Local cItPgi_Num:= &cPgi_Num     
Local nCont := 1 
Local lAnuente := .F.,;
      lExistPO := .F.,;
      lExistIa := .F.,;
      lExistIt := .F.,;
      lItem    := .F.      

aOrd := SaveOrd({"SW2","SW3","SW5","SB1"})

SW2->(DbSetOrder(1))
SW3->(DbSetOrder(8))   
SW5->(DbSetOrder(8))                
SB1->(DbSetOrder(1))

lExistPO := SW2->(DbSeek(xFilial("SW2")+AvKey(TPO_NUM,"W2_PO_NUM")))  
lExistIa := SW3->(DbSeek(xFilial("SW3")+AvKey(cItPO,"W3_COD_I")+AvKey(cItPosic,"W3_POSICAO")))
lExistIt := SW5->(DbSeek(xFilial("SW5")+AvKey(cItPgi_Num,"W5_PGI_NUM")+AvKey(TPO_NUM,"W5_PO_NUM")+AvKey(cItPosic,"W5_POSICAO")))
lItem    := SB1->(DbSeek(xFilial("SB1")+AvKey(cItPO,"B1_COD")))

If lItem 
   lAnuente := If(SW3->W3_FLUXO == "1",.T.,.F.)
EndIf   
   
If lExistPO        
   If lAnuente   
      If lExistIa //Existe Item no W3 
         If SW3->W3_SALDO_Q > 0 .and. SW3->W3_SALDO_Q == SW3->W3_QTDE .and. SW3->W3_SEQ == 0
            cStatus := NAO_EMB //"N„o Embarcado"
         ElseIf SW3->W3_SALDO_Q > 0 .and. SW3->W3_SALDO_Q <> SW3->W3_QTDE .and. SW3->W3_SEQ == 0   
                cStatus := EMB_PAR //"Emb.Parcial" 
         Else
            If SW3->W3_SEQ == 0  
               cStatus := EMB_TOT //"Embarcado"       
            EndIf   
         EndIf    
      EndIf   
   Else 
      If lExistIt //Existe item n„o anuente no W5
         If SW5->W5_SALDO_Q > 0 .and. SW5->W5_SALDO_Q == SW5->W5_QTDE .and. SW5->W5_SEQ == 0
            cStatus := NAO_EMB //"N„o Embarcado"
         ElseIf SW5->W5_SALDO_Q > 0 .and. SW5->W5_SALDO_Q <> SW5->W5_QTDE .and. SW5->W5_SEQ == 0    
                cStatus := EMB_PAR //"Emb.Parcial" 
         Else 
            If SW5->W5_SEQ == 0
               cStatus := EMB_TOT //"Embarcado"       
            EndIf   
         EndIf               
      EndIf
   EndIf    
EndIf                                      

RestOrd(aOrd,.T.)

Return cStatus  

/*------------------------------------------------------------------------------------
Funcao      : TR175VerStatus()
Parametros  : cBotao = Indica qual bot„o foi pressionado
Retorno     : lOk
Objetivos   : Retornar se todos os itens n„o foram embarcados (CAPA)
            : Retornar se todos os itens possuem status iguais (MARCA)
Autor       : Caio CÈsar Henrique
Data/Hora   : 15/05/09
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/

Static Function TR175VerStatus(cBotao,cParam)
          
Local lOk := .T.   
Local cBtSel := cBotao  
Local aStatus := {}
Local lBloqueia := .F.
Local nCont2 := 0  
Local cSituacao := cParam
Local aRet := {}
Private nRecno := Work->(Recno())

Work->(DbGoTop())      

Do Case 
   Case cBtSel == "MARCA" 
   
      If Work->(!BOF()) .AND. Work->(!EOF())
         
         Do While Work->(!EOF())
         
            If !Empty(Work->WK_FLAG) //.and. Work->WK_FLAG  
               AAdd(aStatus,Work->WKSTATUS) 
            EndIf   
            
            Work->(DbSkip())
            
         End Do         
         
         If Empty(aStatus) 
            AAdd(aRet,.F.)     
            Return aRet   
         EndIf 
            
         For nCont2 := 2 to Len(aStatus) 
            If aStatus[1] <> aStatus[nCont2]
               lBloqueia := .T. 
            EndIf   
         Next    
          
         If lBloqueia                    
            AAdd(aRet,.F.)     
            Return aRet 
         EndIf  
         
         If !Empty(cSituacao) .and. cSituacao == NAO_EMB  .and. Alltrim(aStatus[1]) == NAO_EMB 
            AAdd(aRet,.T.)     
            AAdd(aRet,NAO_EMB)
            Return aRet       
         Else 
            AAdd(aRet,.T.)
            AAdd(aRet,EMB_PAR)
            Return aRet   
         EndIf 
         
      EndIf    
   
   Case cBtSel == "CAPA"
   
      IF Work->(!BOF()) .AND. Work->(!EOF())

         Do While Work->(!EOF())
   
            If !Empty(Work->WKSTATUS) .and. Alltrim(Work->WKSTATUS) <> NAO_EMB
               lOK := .F.    
               AAdd(aRet,lOK)
               Return aRet   
            Else
               AAdd(aRet,.T.)
               Return aRet   
            EndIf  
      
         Work->(DbSkip())
      
         EndDo  
      EndIf 
      
   Case cBtSel == "ATUAL" 
   
      If Work->(!BOF()) .AND. Work->(!EOF())         
         Work->(DbGoTo(nRecno))         
      
         If !Empty(Work->WKSTATUS) .and. Alltrim(Work->WKSTATUS) == NAO_EMB
            AAdd(aRet,.T.)     
            AAdd(aRet,NAO_EMB)
            Return aRet
         Else
            AAdd(aRet,.T.)
            AAdd(aRet,EMB_PAR)
            Return aRet   
         EndIf
      EndIf                   
      
End Case         

/*------------------------------------------------------------------------------------
Funcao      : TR175CtrlBt()
Parametros  : 
Retorno     : lConf - .T. habilita / .F. desabilita
Objetivos   : Habilita/Desabilita botıes na tela de itens
Autor       : Caio CÈsar Henrique
Data/Hora   : 19/05/09
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/

Static Function TR175CtrlBt(cTipo)

Local lConf := .T. 
Local aStFlag := {}              
Local nRecno := Work->(Recno())  
Local cBotao := cTipo
Local lOK := .T.
Local nCont3 := 0

Work->(DbGoTop())
                     
Do Case 

   Case Alltrim(cBotao) == "BT_ALT" 
      If Work->(!BOF()) .AND. Work->(!EOF())
         Do While Work->(!EOF()) 
            If !Empty(Work->WK_FLAG)  // GFP - 09/12/2013
               AAdd(aStFlag,Work->WKSTATUS) 
            EndIf   
            If Len(aStFlag) > 0 
               lConf := .F.
               oBtAlt:Disable()
               oBtAlt:Refresh()
            Else 
               oBtAlt:Enable()
               oBtAlt:Refresh()
            EndIf  
      
         Work->(DbSkip())
      
         End Do
      EndIf               
    
   Case Alltrim(cBotao) == "BT_ALT_CAPA"
      If Work->(!BOF()) .AND. Work->(!EOF())

         Do While Work->(!EOF())
            If Work->WKSTATUS <> NAO_EMB
               lOK := .F.    
               oBtAltCp:Disable()
               oBtAltCp:Refresh()
            EndIf  
      
         Work->(DbSkip())
      
         EndDo  
      EndIf  
   
   Case Alltrim(cBotao) == "BT_ALTMAR"
       If Work->(!BOF()) .AND. Work->(!EOF())
       
          Do While Work->(!EOF())
             If !Empty(Work->WK_FLAG)  // GFP - 09/12/2013
                AAdd(aStFlag,Work->WKSTATUS)
             EndIf
             If Len(aStFlag) > 0 
                lConf := .T.
                oBtAltMar:Enable()
                oBtAltMar:Refresh()
             Else    
                oBtAltMar:Disable()
                oBtAltMar:Refresh()
             EndIf     
             
             For nCont3 := 2 to Len(aStFlag) 
                If aStFlag[1] <> aStFlag[nCont3]
                   oBtAltMar:Disable()
                   oBtAltMar:Refresh() 
                EndIf   
             Next    
             
          Work->(DbSkip())
          
          End Do
       End If         
   End Case
   
Work->(DbGoTo(nRecno))

Return lConf     

/*------------------------------------------------------------------------------------
Funcao      : TR175TotItens
Parametros  : cProcesso - N˙mero do Processo escolhido
Retorno     : nItens - Retorna quantidade de itens 
Objetivos   : Retorna quantidade de itens do processo selecionado
Autor       : Caio CÈsar Henrique
Data/Hora   : 26/05/09
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/

Static Function TR175TotItens(cProcesso)

Local nItens := 0
Local cQuery := ""

If Select("WorkTot") > 0
   WorkTot->(DbCloseArea())
Endif             
                  
cFrom := RetSqlName("SW3")+" SW3 "                         
cWhere := IIf(TcSrvType()=="AS/400"," SW3.@DELETED@ <> '*' "," SW3.D_E_L_E_T_ <> '*'" ) + " AND SW3.W3_FILIAL = '"+xFilial("SW3")+"' "+;
                           "AND SW3.W3_PO_NUM = '"+cProcesso+"' "+"AND SW3.W3_SEQ = 0"

cQuery := " SELECT COUNT(*) AS TOTAL FROM "+cFrom+" WHERE "+cWhere+" 

cQuery := ChangeQuery(cQuery)

dbUseArea( .t., "TopConn", TCGenQry(,,cQuery),"WorkTot", .F., .F. )

nItens:= WorkTot->Total

WorkTot->(DbCloseArea())

DbSelectArea("SW3")
DbSelectArea("SW2")

Return Trans(nItens,'@E 999,999,999,999')  

/*------------------------------------------------------------------------------------
Funcao      : TR175BuscaSaldo
Parametros  : cWkItem - Item da Work
Retorno     : nSaldo - Saldo do Item
Objetivos   : Retorna o saldo quantidade correto para o item
Autor       : Caio CÈsar Henrique
Data/Hora   : 29/05/09
Revisao     :
Obs.        :
*------------------------------------------------------------------------------------*/

Static Function TR175BuscaSaldo(cWkItem)

Local cItem := &cWkItem 
Local nSaldo := 0       
Local lExistPO := .F.
Local lExistIa := .F.
Local lExistIt := .F.   
Local lItem := .F.   
Local lAnuente:= .F.

aOrd := SaveOrd({"SW2","SW3","SW5","SB1"})

SW2->(DbSetOrder(1))
SW3->(DbSetOrder(3))   
SW5->(DbSetOrder(3))                
SB1->(DbSetOrder(1))

lExistPO := SW2->(DbSeek(xFilial("SW2")+AvKey(TPO_NUM,"W2_PO_NUM")))  
lExistIa := SW3->(DbSeek(xFilial("SW3")+AvKey(cItem,"W3_COD_I")))
lExistIt := SW5->(DbSeek(xFilial("SW5")+AvKey(TPO_NUM,"W5_PO_NUM")+AvKey(cItem,"W3_COD_I")))
lItem    := SB1->(DbSeek(xFilial("SB1")+AvKey(cItem,"B1_COD")))

If lItem 
   lAnuente := If(SB1->B1_ANUENTE == "1",.T.,.F.)
EndIf   
             
If lExistPO        
   If lAnuente   
      If lExistIa .and. SW3->W3_SEQ == 0 //Existe Item no W3 
         nSaldo := SW3->W3_SALDO_Q
      EndIf      
   Else
      If lExistIt .and. SW3->W3_SEQ == 0 //Existem Item no W5
         nSaldo := SW5->W5_SALDO_Q
      EndIf
   EndIf
EndIf

RestOrd(aOrd,.T.)

Return nSaldo

/*
Funcao      : TR175MarkAll
Parametros  : -
Retorno     : .T.
Objetivos   : MarcaÁ„o de todos os itens do processo
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 09/12/2013 :: 16:16
*/
*-----------------------------*
Static Function TR175MarkAll()
*-----------------------------*
Local nRecno:=Work->(RECNO())
LOCAL bTroca:={||IncProc(STR0046+ALLTRIM(Work->W3_COD_I)),; //"Item: "
                 Work->WK_FLAG:=If(Empty(Work->WK_FLAG)," ",cMarca)}//FDR - 27/06/13

Work->(DBGOTOP())
Do While Work->(!Eof())
   Work->WK_FLAG:=If(Empty(Work->WK_FLAG),cMarca," ")  //FDR - 27/06/13
   //Work->(DBEVAL(bTroca))
   Work->(DbSkip())
EndDo   
Work->(DBGOTO(nRecno))
oMark:OBrowse:Refresh()


Return .T.
*----------------------------------------------------------------------------*
*                        FIM DO PROGRAMA EICTR175.PRW                        *
*----------------------------------------------------------------------------*
