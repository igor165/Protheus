/*
Programa        : EECAE101.PRW
Objetivo        : Manutencao Notas Fiscais
Autor           : Alexandro Wallauer
Data/Hora       : Sexta Feira 13/08/1999 10:30
*/


#INCLUDE "EECAE101.ch"
#INCLUDE "AP5MAIL.CH"
#include "EEC.CH"

#xTranslate SumTotal() => Eval(bTotal,"SOMA")
#xTranslate SubTotal() => Eval(bTotal,"SUBTRAI")

#Define EEM_DV  "5"
#Define AP_AUT_COMPROVADOS     1 //Apropria automaticamente quando há comprovação de todos os insumos
#Define AP_CONF_NAOCOMPROVADOS 2 //Exibe tela de confirmação quando não há comprovação de todos os insumos
#Define AP_AUT_NAOCOMPROVADOS  3 //Apropria automaticamente quando há comprovação para, ao menos, um insumo
#Define AP_CONF_TODOS          4 //Sempre exibe tela de confirmação

#Define SLD_COMPEXP 1  //Saldo a exportar do compromisso de exportação
#Define SLD_INSEXP  2  //Saldo a exportar do insumo no ato concessório

#define KILOGRAMA   "KG"
#define KILOGRAMA2  "10"

/*
Funcao      : AE101DetEEM(aPos)
Parametros  : Posicao do Browse
Retorno     : NIL
Objetivos   : Manutencao
Autor       : AWR
Data/Hora   : Sexta Feira 13/08/1999 10:00
Revisao     : Cristiano A. Ferreira 27/04/2000 - Protheus
*/
Function AE101DetEEM(cAlias,nReg,nOpc,cTit,aCpo,cTipEEM)

Local lRet:=.T., nOldArea := Select()
Local oDlg, nOpcA:=0 //, nTotNF:=M->EEC_VLTTNF // *By JBJ - 10/11/03 - Campo não será mais utilizado.
Local cFileBack:=CriaTrab(,.F.)

Local bOk :={||nOpcA:=1,IF(Obrigatorio(aGets,aTela),oDlg:End(),nOpcA:=0)}

// by CAF 15/01/2005 - Montar browse de NF com base no SX3.
/*
Local aNFBrowse:={ ColBrw("EEM_NRNF"  ,"WorkNF"),ColBrw("EEM_SERIE" ,"WorkNF"),;
                    ColBrw("EEM_DTNF"  ,"WorkNF"),ColBrw("EEM_TIPONF","WorkNF"),;
                    ColBrw("EEM_VLNF"  ,"WorkNF"),ColBrw("EEM_VLMERC","WorkNF"),;
                    ColBrw("EEM_VLFRET","WorkNF"),ColBrw("EEM_VLSEGU","WorkNF") }
*/
Local aNFBrowse:= {}

Private oBrw, bCancel := {|| oDlg:End() }, aButtonsNF:={}, nBarOption:=ENCH_ADD

Private aTela[0][0], aGets[0]

Begin Sequence
   
   dbSelectArea("WorkNF")
   DbGoTop() // JPM - 17/03/06 - Dar DbGoTop antes dos 'Copy To' para não gerar erro em CTree.
   
   //THTS - 09/11/2017 - Se recno da work for zero, ainda nao preencheu todas as informacoes para mostrar em tela
   If WorkNF->(WK_RECNO) != 0
      aNFBrowse := ArrayBrowse("EEM","WorkNF")
   Else
      aNFBrowse := {{"EEM_PREEMB",,AvSX3("EEM_PREEMB",5)},{"EEM_NRNF"  ,,AvSX3("EEM_NRNF",5)}  ,{"EEM_SERIE" ,,AvSX3("EEM_SERIE",5)} ,{"EEM_DTNF"  ,,AvSX3("EEM_DTNF",5)},;
                    {"EEM_VLNF"  ,,AvSX3("EEM_VLNF",5)}  ,{"EEM_VLMERC",,AvSX3("EEM_VLMERC",5)}}
   EndIf
   
   IF cTipEEM == EEM_IN
      aNFBrowse:={{"EEM_NRNF",,STR0001},{"EEM_DTNF",,STR0002}} //"Nr. Invoice"###"Dt. Invoice"
   Endif

   //WFS 03/07/09
   If AvIntEmb()
      aSize(aNfBrowse, Len(aNfBrowse) + 1)
      aIns(aNfBrowse, 1)
      aNfBrowse[1]:= ColBrw("EEM_TIPONF", "WorkNF")
   EndIf

   //FDR - 29/04/11
   aNFBrowse := AddCpoUser(aNFBrowse,"EEM","2","WorkNF")

   //copy to (cFileBack)
   TETempBackup(cFileBack) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados

   IF EasyEntryPoint("EECPEM39")
      ExecBlock("EECPEM39",.F.,.F.,{"BROWSENF",cTipEEM})
   Endif

   DEFINE MSDIALOG oDlg TITLE cTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      oEnch1 := MsMGet():New(cAlias,nReg,nOpc,,,,aCpo,PosDlgUp(oDlg)) //LBL-14/11/2013

      oEnch1:oBox:Align := CONTROL_ALIGN_TOP //LBL-14/11/2013

      oBrw := MsSelect():New("WorkNF",,,aNFBrowse,,,PosDlgDown(oDlg),"AE101Filtra('"+cTipEEM+"')","AE101Filtra('"+cTipEEM+"')")
      oBrw :oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //LBL-14/11/2013
      oBrw:bAval:={|| IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),AE101MAN(VIS_DET,cTipEEM,oBrw),AE101MAN(ALT_DET,cTipEEM,oBrw)) }

   ACTIVATE MSDIALOG oDlg ON INIT ;
        AVBar(nOpc,oDlg,bOk,bCancel,nBarOption,{|opc| AE101MAN(opc,cTipEEM,oBrw)},,aButtonsNF)

   IF nOpcA == 0 //Cancelar
      dbSelectArea("WorkNF")
      AvZap()
      append from (cFileBack)

      /* By JBJ - 10/11/03 - Campo não será mais utilizado.
      M->EEC_VLTTNF:=nTotNF
      */
   EndIf

End Sequence

Select(nOldArea)

Return lRet

/*
Funcao      : AE101Filtra(cFiltro)
Parametros  : Filtra registros do WorkNF
Retorno     :
Objetivos   :
Autor       :
Data/Hora   :
*/
Function AE101Filtra(cFiltro)
Return cFiltro

/*
Funcao      : AE101MAN(nTipo,cTipEEM,oBrw)
Parametros  : Tipo da manutencao e tipo do registro
Retorno     : NIL
Objetivos   : Manutencao
Autor       : AWR
Data/Hora   : Sexta Feira 13/08/1999 10:00
*/
Static Function AE101MAN(nTipo,cTipEEM,oBrw)

Local nAreaOld := If(Select() = 0, Select("WorkNF"), Select()), lModNF := .F.
Local oDlg, nInc, nOpcA:=0,nRecno:=WorkNF->(Recno())
Local bInit:={||CfgEnch(oDlg,cTipEEM)}
Local lRetPE := .F.

Private aTela[0][0],aGets[0]
Private aCposEnchoice
Private nTipoW := nTipo  // GFP - 30/01/2014

Begin Sequence

   IF nTipo <> INC_DET .AND. WorkNF->(Bof() .And. Eof())
      HELP(" ",1,"AVG0000632") //MsgStop("Não existe registros para manutenção","Atenção")
      Break
   Endif
   aCposEnchoice:= {}

   If EasyEntryPoint("EECAE101")
      lRetPE := ExecBlock("EECAE101",.F.,.F.,{"PE_TIPO",nTipo})
      If ValType(lRetPE) <> "L"
         lRetPE := .F.
      EndIf
   EndIf

   IF lIntegra
      IF nTipo == INC_DET .Or. nTipo == EXC_DET .Or. nTipo == ALT_DET
         IF cTipEEM == EEM_NF
            If (EEM->(FieldPos("EEM_MODNF")) # 0 .and. nTipo == ALT_DET) .or. lRetPE
               lModNF := .T. // FJH 13/02/06 - Modif. p/ permitir a modificação do modelo msmo com o EECFAT == .T.
            Else
               HELP(" ",1,"AVG0000633") //MsgInfo("A manutenção de notas deve ser feita no SIGAFAT !","Aviso")
               Break
            Endif
         Endif
      Endif
   Endif

   IF nTipo == INC_DET
      WorkNF->(dbGoBottom())
      WorkNF->(dbSkip())
   Endif

   For nInc := 1 TO WorkNF->(FCount())
      M->&(WorkNF->(FIELDNAME(nInc))) := WorkNF->(FIELDGET(nInc))
   Next nInc

   M->EEM_PREEMB := M->EEC_PREEMB
   M->EEM_TIPOCA := cTipEEM

   AADD(aCposEnchoice,"EEM_NRNF")
   AADD(aCposEnchoice,"EEM_DTNF")

   IF cTipEEM == EEM_NF
      AADD(aCposEnchoice,"EEM_SERIE")
      AADD(aCposEnchoice,"EEM_VLNF")  //Vlr nota fiscal
      AADD(aCposEnchoice,"EEM_VLMERC") //valor mercadoria
      AADD(aCposEnchoice,"EEM_VLFRET") //valor frete
      AADD(aCposEnchoice,"EEM_VLSEGU") //valor seguro
      AADD(aCposEnchoice,"EEM_TIPONF") // Tipo NF
      AADD(aCposEnchoice,"EEM_OUTROS") // Outros
      If lModNF // FJH 13/02/06
         AADD(aCposEnchoice,"EEM_MODNF") // Mododelo NF
      Endif
   Endif

   DEFINE MSDIALOG oDlg TITLE STR0003 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Nota Fiscal"

      EnChoice("EEM",,3,,,,aCposEnchoice,PosDlg(oDlg),IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{}, ;
      IF(lModNF .and. Str(nTipo,1) $ Str(ALT_DET,1) , {"EEM_MODNF"} ,)  ),3) // FJH 13/02/06
      // Botão para funcionar a exclusão
      DEFINE SBUTTON FROM 10025,187 TYPE 2 ACTION (.T.) ENABLE OF oDlg PIXEL


   ACTIVATE MSDIALOG oDlg ON INIT (Eval(bInit),;
                EnchoiceBar(oDlg,{||nOpcA:=1,If(AE101VALNF(nTipo,nRECNO,cTipEEM),oDlg:End(),nOpcA:=0)},{||oDlg:End()}))

   IF nOpcA != 0 .And. nTipo <> VIS_DET

      IF nTipo == INC_DET
         WorkNF->(DBAPPEND())
      Elseif nTipo == ALT_DET
         /* By JBJ - Campo não será mais utilizado.
         IF(cTipEEM==EEM_NF,M->EEC_VLTTNF-=WorkNF->EEM_VLNF,)
         */
      EndIf

      IF nTipo <> EXC_DET
         AVReplace("M","WorkNF")
         /* By JBJ - Campo não será mais utilizado.
         IF(cTipEEM==EEM_NF,M->EEC_VLTTNF+=WorkNF->EEM_VLNF,)
         */
      EndIf

      /* By JBJ - Campos não serão mais utilizados.
      IF cTipEEM == EEM_NF
         WorkNF->(dbGotop())
         IF(Empty(M->EEC_NRNF),M->EEC_NRNF:=WorkNF->EEM_NRNF,)
         IF(Empty(M->EEC_DTNF),M->EEC_DTNF:=WorkNF->EEM_DTNF,)
         WorkNF->(dbGoTo(nRecno))
      EndIf
      */
      oBrw:oBrowse:Refresh()
   Else
      IF nTipo == INC_DET
         WorkNF->(dbGoTo(nRecno))
      Endif
   EndIf

   IF EasyEntryPoint("EECPEM40")
      ExecBlock("EECPEM40",.F.,.F.,{nTipo,nOpcA})
   Endif

End Sequence

Select(nAreaOld) // Enchoice muda de area

Return NIL

/*
Funcao      : AE101VALNF()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Deletar despesas
Autor       : Heder M Oliveira
Data/Hora   : 05/01/99 13:30
Revisao     :
Obs.        :
*/
Function  AE101VALNF(nTipo,nRecno,cTipEEM)
   Local lRet:=.T., lRetPto

   Begin Sequence

      // ** JPM - 28/06/06
      If EasyEntryPoint("EECAE101")
         Private nPTipo := nTipo, nPRecno := nRecno, cPTipEEM := cTipEEM
         If ValType((lRetPto := ExecBlock("EECAE101",.F.,.F.,"VALIDA_NF"))) = "L" .And. !lRetPto
            lRet := .F.
            Break
         EndIf
      EndIf
      // **

      If nTipo == INC_DET .OR. nTipo == ALT_DET
         lRet:=Obrigatorio(aGets,aTela)

         If nTipo == INC_DET .AND. lRet .AND. WorkNF->(DBSEEK(cTipEEM+M->EEM_NRNF))
            IF cTIPEEM==EEM_NF
               HELP(" ",1,"AVG0000634") //MsgInfo("Nota Fiscal ja cadastrada"),1)
            ELSE
               HELP(" ",1,"AVG0000635") //MsgInfo("Invoice ja cadastrada"),1)
            ENDIF
            lRet:=.F.
         Endif

         WorkNF->(DBGOTO(nRECNO))

      ElseIf nTIPO==EXC_DET .AND. MSGNOYES(STR0004,STR0005) //'Confirma Exclusão ?'###'Atenção'

         WorkNF->(DBGOTO(nRECNO))

         //IF(cTipEEM==EEM_NF,M->EEC_VLTTNF-=WorkNF->EEM_VLNF,)
         If WorkNF->WK_RECNO # 0
            AADD(aNFDeletados,WorkNF->WK_RECNO)
         EndIf
         WorkNF->(DBDELETE())
         WorkNF->(dbGoTop())
      EndIf

   End Sequence

Return lRet

/*
Funcao      : AE101Grava(lGera,cTipo,aDeletados,lIntegracao)
Parametros  : Se gera, Tipo 'N' ou 'I', Recnos dos deletados
Retorno     : NIL
Objetivos   : GERAR
Autor       : AWR
Data/Hora   : Sexta Feira 13/08/1999 10:00
*/
Function AE101Grava(lGera,aDeletados,lIntegracao)
Local cAlias, cNota, cSerie
LOCAL nInc, nOldArea := Select()
Private lApagaItens := .T.
Default lIntegracao := .f.

IF Select("EES") > 0
   EES->( dbSetOrder( 1 ) ) // Filial + Preemb + NRNF.
Endif

Begin Sequence

   If EasyEntryPoint("EECAE101") // JPM - 19/06/06
      Private lPGera := lGera, aPDeletados := aDeletados, lPIntegracao := lIntegracao
      ExecBlock("EECAE101",.F.,.F.,"ANTES_GRAVA_NF")
   EndIf

   IF !lGera

      DBSelectArea("WorkNF")

      For nInc:=1 to LEN(aDeletados)
         EEM->(DBGOTO(aDeletados[nInc]))

         If !lIntegracao
            IncProc()
         EndIf

         If EasyEntryPoint("EECAE101")
            ExecBlock("EECAE101",.F.,.F.,{"PE_ANTES_GRV"})
         EndIf

         //** AAF 09/01/08 - Estorna a Nota Fiscal no Contábil
         If lIntCont
            AE100EstCon("ESTORNA_NF")
         EndIf
         //**

         IF Select("EES") > 0 .And. lApagaItens
            //Exclusão dos Itens da Nota Fiscal.
            EES->( dbSeek( xFilial( "EES" ) + EEM->EEM_PREEMB + EEM->EEM_NRNF ) )
            While EES->( !Eof() .and. xFilial( "EES" ) == EES_FILIAL ) .and. ;
                  EES->EES_PREEMB == EEM->EEM_PREEMB .and. EES->EES_NRNF == EEM->EEM_NRNF
               RecLock( "EES", .F. )
               EES->( dbDelete() )
               EES->( MsUnlock() )
               EES->( dbSkip() )
            End
         Endif

         RecLock("EEM",.F.)
         EEM->(DBDELETE())
         EEM->(MsUnlock())
      Next nInc

      WorkNF->(DBGOTOP())

      While ! WorkNF->(EOF())

         If WorkNF->WK_RECNO # 0
            EEM->(DBGOTO(WorkNF->WK_RECNO))
            RecLock("EEM",.F.)
         Else
            RecLock("EEM",.T.)  // bloquear e incluir registro vazio
         EndIf

         If !lIntegracao
            IncProc()
         EndIf

         AVReplace("WorkNF","EEM")

         EEM->EEM_PREEMB := M->EEC_PREEMB
         EEM->EEM_FILIAL := xFilial("EEM")
         EEM->(MsUnlock())
         WorkNF->(DBSKIP())
      Enddo

   Else
      /* WFS - 15/12/2009
         Tratamento para consistir a tabela EEM com as SF2 e SF1 quando o
         fluxo alternativo de integração com o faturamento estiver habilitado. */
      If EECFlags("INTEMB")
         If AllTrim(EEM->EEM_TIPONF) == EEM_DV //nota fiscal de devolução
            cAlias:= "SF1"
            cNota := AvKey(EEM->EEM_NRNF , "F1_DOC")
            cSerie:= AvKey(EEM->EEM_SERIE, "F1_SERIE")
         Else
            cAlias:= "SF2"
            cNota := AvKey(EEM->EEM_NRNF, "F2_DOC")
            cSerie:= AvKey(EEM->EEM_SERIE, "F2_SERIE")
         EndIf

         If Empty(M->EEC_DTEMBA)
            (cAlias)->(DBSetOrder(1))
            If !(cAlias)->(DBSeek(xFilial() + cNota + cSerie))
               FAT3DelNF(cNota, cSerie)
            Else
               AVReplace("EEM", "WorkNF")
               WorkNF->WK_RECNO := EEM->(RECNO())
            EndIf
         Else
            AVReplace("EEM", "WorkNF")
            WorkNF->WK_RECNO := EEM->(RECNO())
         EndIf
      Else
         AVReplace("EEM", "WorkNF")
         WorkNF->WK_RECNO := EEM->(RECNO())
      EndIf

   EndIf
End Sequence

Select(nOldArea)

Return Nil

/*
Funcao      : CfgEnch
Parametros  :
Retorno     :
Objetivos   :
Autor       :
Data/Hora   :
*/
Static Function CfgEnch(oMSMGet,cTipEEM)

Local nInd := 0

IF cTipEEM == EEM_IN
   aTela[1][1]:=STR0001 //"Nr. Invoice"
   aTela[1][3]:=STR0002 //"Dt. Invoice"

   nInd := aScan(aGets,{|x| Substr(x,9,10)="EEM_NRNF"})
   // *** Say
   oMSMGet:aControls[nInd*2]:cTitle := aTela[1][1]
   oMSMGet:aControls[nInd*2]:Refresh()

   nInd := aScan(aGets,{|x| Substr(x,9,10)="EEM_DTNF"})
   // *** Say
   oMSMGet:aControls[nInd*2]:cTitle := aTela[1][3]
   oMSMGet:aControls[nInd*2]:Refresh()
Endif

Return nil

/*
Função          : Conjunto de funções para Drawback
Objetivo        : Apropriação de Ato Concessório
Autor           : Gustavo Carreiro
Data/Hora       :
Obs.            :
*/
*------------------------------------*
Function AE100Apuracao(cRotina,cPedido)
*------------------------------------*
Local cPos:="", cAto, dDtVal, cCGC //, nSYTOrd:=SYT->(IndexOrd())
Local nSalRE, cPos2:="", cAto3 := "", cPos3 := ""
Local nItAlt := 0, aPrincipais, nInc
Local lTipoItem := ChkFile("ED7") .And. ED7->(FieldPos("ED7_TPITEM")) > 0 .And. ED7->(FieldPos("ED7_PD")) > 0
Local cBackFiltro

Default cPedido := ""

Private cProdOld := ""
Private nNivel1:=0, nNivel2:=0, nNivel3 := 0 //Controla novas buscas
Private lMens:=.F., lOk := .T., nQtdAux, cUnid
Private lMsgExibe := .T. //AOM - 04/07/2011
Private lApropParc := EasyGParam("MV_EDC0003",,.T.)  // PLB 02/08/07 - Define se ocorre apropriacao parcial
Private nOpcAprop,nOpcApSld, lTelaAprop:= .T.

Begin Sequence

   If EasyEntryPoint("EECAE101")
      ExecBlock("EECAE101",.F.,.F.,"AE100APURACAO_OPCAPROPRIACAO")
   EndIf

   If lTelaAprop
      If !OpcApropAutomatica(cPedido)
         Break
      EndIf
   EndIf

   SA5->(dbSetOrder(3))
   cCGC := BuscaCGCFor(M->EEC_FORN,M->EEC_FOLOJA)

   //** PLB 09/08/07 - Ponto de Entrada para trocar o CGC
   If EasyEntryPoint("EECAE101")
      cNewCNPJ := ExecBlock("EECAE101",.F.,.F.,"TROCA_CNPJ")
      If ValType(cNewCNPJ) == "C"
        cCGC := cNewCNPJ
      EndIf
   EndIf
   //**

   // := WorkIp->(DbFilter()) // By JPP - 21/12/2006 - 11:50 - Isso se faz necessário para restabelecer o
   //WorkIp->(DbClearFilter())           // filtro original da tabela WorkIp, corrindo o erro que ocorria na
   //WorkIp->(DbSetFilter(&("{|| " + cBackFiltro + " }"), cBackFiltro)) // instrução WORKIP->(DbGoTop()).

   WorkIP->(dbGoTop())
   Do While !WorkIP->(EOF())
      cPos:="" ; cPos2:=""; lOk:=.T.
      If cRotina == "A" .and. !Empty(WorkIP->EE9_ATOCON)
         WorkIP->(dbSkip())
         Loop
      EndIf
      If WorkIP->WP_FLAG <> cMarca
         WorkIP->(dbSkip())
         Loop
      EndIf
      If !Empty(WorkIP->EE9_ATOCON)
         //ED3->(dbSetOrder(2))
         //ED3->(dbSeek(cFilED3+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3))
         //ED3->(msUnlock())
         If lMUserEDC
            oMUserEDC:Solta("EMBARQUE_EXP","ALTERA_ATO")  // PLB 05/12/06
         EndIf
         DelSaldoAC()
         WorkIP->(RecLock("WorkIP",.F.))
         WorkIP->EE9_ATOCON := ""
         WorkIP->EE9_SEQED3 := ""
         WorkIP->EE9_QT_AC  := 0
         WorkIP->EE9_VL_AC  := 0
         WorkIP->(msUnlock())
      EndIf
      ED3->(dbSetOrder(3))
      ED3->(dbSeek(cFilED3+cCGC+WorkIP->EE9_COD_I+DtoS(dDataBase),.T.))  //SoftSeek
      If nNivel1 > 0
         ED3->(dbSkip(nNivel1))
      EndIf
      If ED0->ED0_AC <> ED3->ED3_AC .or. ED0->ED0_FILIAL <> cFilED0
         ED0->(dbSeek(cFilED0+ED3->ED3_AC))
      EndIf
      If ED3->ED3_FILIAL==cFilED3 .and. ED3->ED3_CNPJIM==cCGC .and. ED3->ED3_PROD==WorkIP->EE9_COD_I
         If !Empty(ED3->ED3_AC) .and. ED3->ED3_SALDO > 0 .and. Empty(ED0->ED0_DT_ENC) .and.;
         ED0->ED0_MODAL<>"2" .and. If(nOpcApSld <> SLD_INSEXP,VerSaldoAC(1),.T.) .and.;//AOM - 15/09/2011
         if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
            cPos    := ED3->ED3_SEQSIS
            cAto    := ED3->ED3_AC
            dDtVal  := ED3->ED3_DT_VAL
            nSalRE  := ED3->ED3_SALDO
         Else
            nNivel1 += 1
         EndIf
      Else
         nNivel1 := 0
      EndIf

      ED3->(dbSetOrder(4))
      ED3->(dbSeek(cFilED3+cCGC+WorkIP->EE9_POSIPI+Space(Len(ED3->ED3_PROD))+DtoS(dDataBase),.T.))  //SoftSeek
      If nNivel2 > 0
         ED3->(dbSkip(nNivel2))
      EndIf
      If ED0->ED0_AC <> ED3->ED3_AC .or. ED0->ED0_FILIAL <> cFilED0
         ED0->(dbSeek(cFilED0+ED3->ED3_AC))
      EndIf
      If ED3->ED3_FILIAL==cFilED3 .and. ED3->ED3_CNPJIM==cCGC .and. ED3->ED3_NCM==WorkIP->EE9_POSIPI .and. ED3->ED3_PROD==Space(Len(ED3->ED3_PROD))
         If !Empty(ED3->ED3_AC) .and. ED3->ED3_SALDO > 0 .and. Empty(ED0->ED0_DT_ENC) .and.;
            ED0->ED0_MODAL<>"2" .and. If(nOpcApSld <> SLD_INSEXP,VerSaldoAC(1),.T.) .and.;//AOM - 15/09/2011
            if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido

            cPos2 := ED3->ED3_SEQSIS
         Else
            nNivel2 += 1
         EndIf
      Else
         nNivel2 := 0
      EndIf

      If !Empty(cPos) .and. !Empty(cPos2)
         If MelhorAC(dDtVal,nSalRE)
            ED3->(dbSetOrder(2))
            ED3->(dbSeek(cFilED3+cAto+cPos))
         EndIf
      ElseIf Empty(cPos) .and. Empty(cPos2)
         lOk := .F.
      ElseIf Empty(cPos2)
         ED3->(dbSetOrder(2))
         ED3->(dbSeek(cFilED3+cAto+cPos))
      EndIf

      //RMD - 16/11/06 - Verifica se existe algum ato concessório melhor para algum item alternativo em relação ao item em questão
      If lTipoItem .And. Len(aPrincipais := IG400AllItens("E", WorkIp->EE9_COD_I)) > 0
         //cPos2     := ED3->ED3_SEQSIS
         //cAto      := ED3->ED3_AC
         For nInc := 1 To Len(aPrincipais)
            //Guarda dados do item anterior
            nRecnoED3 := ED3->(Recno())
            //dDtVal    := ED3->ED3_DT_VAL
            //nSalRE    := ED3->ED3_SALDO
            If !Empty(aPrincipais[nInc][2])
               ED3->(DbSetOrder(8))    //[2] - Pedido, [1] - Produto
               If ED3->(DbSeek(cFilED3+aPrincipais[nInc][2]+aPrincipais[nInc][1]))
                  If nNivel3 > 0
                     ED3->(dbSkip(nNivel3))
                  EndIf
                  If ED0->ED0_AC <> ED3->ED3_AC .or. ED0->ED0_FILIAL <> cFilED0
                     ED0->(DbSeek(cFilED0+ED3->ED3_AC))
                  EndIf
                  If ED3->ED3_FILIAL == cFilED3 .and. ED3->ED3_CNPJIM == cCGC .and. ED3->ED3_PROD == aPrincipais[nInc][1]
                     If !Empty(ED3->ED3_AC) .and. ED3->ED3_SALDO > 0 .and. Empty(ED0->ED0_DT_ENC) .and.;
                        ED0->ED0_MODAL<>"2" .and. If(nOpcApSld <> SLD_INSEXP,VerSaldoAC(1),.T.) .and.;//AOM - 15/09/2011
                        if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
                        //Verifica se o ato encontrado é melhor que o anterior e verifica a estrutura do item principal e do item alternativo
                        If lOK  .And.  ( MelhorAC(dDtVal,nSalRE) .Or. !AvCompEstr(aPrincipais[nInc][1], WorkIp->EE9_COD_I, ED3->ED3_PD, .F., .T., , .T.))
                           ED3->(DbGoTo(nRecnoED3))
                        Else
                           cAto3   := ED3->ED3_AC
                           cPos3   := ED3->ED3_SEQSIS
                           dDtVal    := ED3->ED3_DT_VAL
                           nSalRE    := ED3->ED3_SALDO
                           nRecnoED3 := ED3->(Recno())
                           nItAlt := nInc
                           lOk := .T.
                        EndIf
                     Else
                        nNivel3 += 1
                     EndIf
                  Else
                     nNivel3 := 0
                  EndIf
               EndIf
            Else
               ED3->(dbSetOrder(3))
               ED3->(dbSeek(cFilED3+cCGC+aPrincipais[nInc][1]+DtoS(dDataBase),.T.))
               If nNivel3 > 0
                  ED3->(dbSkip(nNivel3))
               EndIf
               If ED0->ED0_AC <> ED3->ED3_AC .or. ED0->ED0_FILIAL <> cFilED0
                  ED0->(dbSeek(cFilED0+ED3->ED3_AC))
               EndIf
               If ED3->ED3_FILIAL == cFilED3 .And. ED3->ED3_CNPJIM == cCGC .And. ED3->ED3_PROD == aPrincipais[nInc][1]
                  If !Empty(ED3->ED3_AC) .And. ED3->ED3_SALDO > 0 .And. Empty(ED0->ED0_DT_ENC) .And.;
                     ED0->ED0_MODAL <> "2" .And. If(nOpcApSld <> SLD_INSEXP,VerSaldoAC(1),.T.) .and.;//AOM - 15/09/2011
                     if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
                     //** PLB 21/06/07
                     //Verifica se o ato encontrado é melhor que o anterior e verifica a estrutura do item principal e do item alternativo
                     If lOK .And. ( MelhorAC(dDtVal,nSalRE) .Or. !AvCompEstr(aPrincipais[nInc][1], WorkIp->EE9_COD_I, ED3->ED3_PD, .F., .T., , .T.))
                        ED3->(DbGoTo(nRecnoED3))
                     Else
                        cAto3   := ED3->ED3_AC
                        cPos3   := ED3->ED3_SEQSIS
                        dDtVal  := ED3->ED3_DT_VAL
                        nSalRE  := ED3->ED3_SALDO
                        nRecnoED3 := ED3->(Recno())
                        nItAlt := nInc
                        lOK := .T.
                     EndIf
                     //**
                  Else
                     nNivel3 += 1
                  EndIf
               Else
                  nNivel3 := 0
               EndIf
            EndIf
            ED3->(DbGoTo(nRecnoED3))
         Next
      EndIf

      //A exibição da mensagem dependerá da opção de apropriação automática
      lMsgExibe:= (nOpcAprop == AP_CONF_NAOCOMPROVADOS .Or. nOpcAprop == AP_CONF_TODOS)

      //AOM - 05/07/2011 - Chamado 087822
      If EasyEntryPoint("EECAE101")
         ExecBlock("EECAE101",.F.,.F.,"AE100APURACAO_EXIBEMSG")
      EndIf

      If lOk
         /* RMD - Passa a utilizar a unidade de medida do ato na função verificaqtd
         If nItAlt > 0
            //Caso tenha sido utilizado um item alternativo, troca temporariamente o código do item
            cProdOld := WorkIp->EE9_COD_I
            WorkIp->EE9_COD_I := aPrincipais[nItAlt][1]
            nItAlt := 0
         EndIf
         */
         //If !VerificaQTD(.T.,ED3->ED3_AC,ED3->ED3_SEQSIS) .And. lMsgExibe - RMD - 20/11/12 - Força o Loop mesmo quando lMsgExibe estiver .F.
         If !VerificaQTD(.T.,ED3->ED3_AC,ED3->ED3_SEQSIS)
         	If lMsgExibe
               MsgInfo(STR0021+Alltrim(ED3->ED3_AC)+STR0022+Alltrim(WorkIP->EE9_COD_I)+" "+STR0023+Alltrim(WorkIP->EE9_SEQUEN)+STR0024)//"O Melhor A.C. (" # ") para o produto " # "Sequencia: " # "nao podera ser utilizado pois nao existe conversao entre as unidades de medida do A.C e do Produto."
            EndIf
            WorkIp->(DbSkip())
            Loop
         EndIf



         If ED3->ED3_SALDO >= nQtdAux .and. If(nOpcApSld <> SLD_INSEXP,VerSaldoAC(3),.T.)//AOM - 15/09/2011
            If lExistEDD  //GFC - 18/07/2003 - Drawback Anterioridade
               If !AeApSldAC(ED3->ED3_AC,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,nQtdAux,WorkIP->EE9_PEDIDO,ED3->ED3_SALDO < nQtdAux, WorkIP->EE9_SEQEMB,/*cPos*/,/*lBotao*/,.T.,.F.)/*AOM - 26/08/2011*/
                  //Apropria(.T.)  - NOPADO POR AOM - 26/08/2011
               //Else
                  If !Empty(cAto3)
                     nNivel3 += 1
                  ElseIf !Empty(ED3->ED3_PROD)
                     nNivel1 += 1
                  Else
                     nNivel2 += 1
                  EndIf
               EndIf
            Else
               Apropria(.T.)
            EndIf
         Else
            /*
            If lExistEDD  //GFC - 18/07/2003 - Drawback Anterioridade
               If AeApSldAC(ED3->ED3_AC,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,nQtdAux,WorkIP->EE9_PEDIDO)
                  ConfirmaAC(ED3->ED3_AC,ED3->ED3_SEQSIS,.T.)
               Else
                  If !Empty(cAto3)
                     nNivel3 += 1
                  ElseIf !Empty(ED3->ED3_PROD)
                     nNivel1 += 1
                  Else
                     nNivel2 += 1
                  EndIf
               EndIf
            Else
               ConfirmaAC(ED3->ED3_AC,ED3->ED3_SEQSIS,.T.)
            EndIf
            */
            //** PLB 02/08/07 - Define se ocorre apropriacao parcial
            If lApropParc  .And.  lExistEDD // .Or.  AeApSldAC(ED3->ED3_AC,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,nQtdAux,WorkIP->EE9_PEDIDO,ED3->ED3_SALDO < nQtdAux,WorkIP->EE9_SEQEMB,ED3->ED3_SEQSIS,.T.,/*lApro*/,.T.) )/*AOM - 26/08/2011*/
               //ConfirmaAC(ED3->ED3_AC,ED3->ED3_SEQSIS,.T.)- NOPADO POR AOM - 26/08/2011
            //Else
               If !AeApSldAC(ED3->ED3_AC,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,nQtdAux,WorkIP->EE9_PEDIDO,ED3->ED3_SALDO < nQtdAux,WorkIP->EE9_SEQEMB,ED3->ED3_SEQSIS,/*lApro*/,.T.,.T.)
                  If !Empty(cAto3)
                     nNivel3 += 1
                  ElseIf !Empty(ED3->ED3_PROD)
                     nNivel1 += 1
                  Else
                     nNivel2 += 1
                  EndIf

               EndIf
            Else

               If !Empty(cAto3)
                  nNivel3 += 1
               ElseIf !Empty(ED3->ED3_PROD)
                  nNivel1 += 1
               Else
                  nNivel2 += 1
               EndIf

            EndIf
            //**

         EndIf
         If !Empty(cProdOld)
            //Restaura o código do item
            WorkIp->EE9_COD_I := cProdOld
            cProdOld          := ""
         EndIf
         If nNivel1 > 0 .or. nNivel2 > 0 .Or. nNivel3 > 0
            Loop
         EndIf
      Else
         If nNivel1 > 0 .or. nNivel2 > 0 .Or. nNivel3 > 0
            Loop
         ElseIf lMsgExibe
            MsgInfo(STR0025+Alltrim(WorkIP->EE9_COD_I)+" "+STR0023+Alltrim(WorkIP->EE9_SEQEMB)+".") //"Nenhum Ato Concessorio encontrado para o Produto " # "Sequencia: "
         EndIf
      EndIf

      //TRP - 07/06/2011 - Chamado 087322
      If EasyEntryPoint("EECAE101")
         ExecBlock("EECAE101",.F.,.F.,"AE100Apuracao_Apropria")
      EndIf

      WorkIP->(dbSkip())
   EndDo

   If lMens
      MsgInfo(STR0026)//"Alguns produtos nao puderam ser apropriados pois o A.C. estava sendo usado para outro processo."
   EndIf

   SA5->(dbSetOrder(1))
   ED3->(dbSetOrder(1))
   WorkIP->(dbGoTop())

End Sequence
Return .T.

*--------------------------*
Function DelSaldoAC()
*--------------------------*
nAPos := ASCAN(aApropria,{|X| X[1]==WorkIP->EE9_ATOCON .and. X[2]=WorkIP->EE9_SEQED3})
If nAPos > 0
   aApropria[nAPos,3] -= WorkIP->EE9_QT_AC
   aApropria[nAPos,4] -= WorkIP->EE9_VL_AC
   If aApropria[nAPos,3] <= 0
      ADEL(aApropria,nAPos)
      ASIZE(aApropria,LEN(aApropria)-1)
   EndIf
EndIf

Return .T.

*-------------------------------*
Function VerSaldoAC(nTipo)
*-------------------------------*
Local nAPos

If nTipo = 1
   nAPos := ASCAN(aApropria,{|X| X[1]==ED3->ED3_AC .and. X[2]=ED3->ED3_SEQSIS})
   If nAPos > 0
      If (ED3->ED3_SALDO - aApropria[nAPos,3]) <= 0
         Return .F.
      EndIf
   EndIf
ElseIf nTipo = 2
   nAPos := ASCAN(aApropria,{|X| X[1]==ED3->ED3_AC .and. X[2]=ED3->ED3_SEQSIS})
   If nAPos > 0
      If M->EEC_COBCAM == "1"
         If (ED3->ED3_SAL_CO - aApropria[nAPos,4]) <= 0
            Return .F.
         EndIf
      Else
         If (ED3->ED3_SAL_SE - aApropria[nAPos,4] - aApropria[nApos,5]) <= 0
            Return .F.
         EndIf
      EndIf
   EndIf
ElseIf nTipo = 3
   nAPos := ASCAN(aApropria,{|X| X[1]==ED3->ED3_AC .and. X[2]=ED3->ED3_SEQSIS})
   If nAPos > 0
      If (ED3->ED3_SALDO - (aApropria[nAPos,3]+nQtdAux)) < 0
         Return .F.
      EndIf
   EndIf
EndIf

Return .T.

*-------------------------------------*
Function MelhorAC(dDtVal,nSalRE)
*-------------------------------------*
Local lRet:=.F.

If ED3->ED3_DT_VAL > dDtVal
   lRet := .T.
ElseIf ED3->ED3_DT_VAL == dDtVal .and. ED3->ED3_SALDO > nSalRE
   lRet := .F.
EndIf

Return lRet

*-------------------------------------------*
Function VerificaQTD(lBotao,cAto,cPos)
*-------------------------------------------*
If (lBotao .and. Empty(WorkIP->EE9_UNIDAD)) .or. (!lBotao .and. Empty(M->EE9_UNIDAD))
   If SA5->A5_PRODUTO<>WorkIP->EE9_COD_I .or. SA5->A5_FABR<>WorkIP->EE9_FABR .or. SA5->A5_FORNECE<>WorkIP->EE9_FORN
      SA5->(dbSetOrder(3))
      SA5->(dbSeek(cFilSA5+WorkIP->EE9_COD_I+WorkIP->EE9_FABR+WorkIP->EE9_FORN))
      SA5->(dbSetOrder(1))
   EndIf
   If Empty(SA5->A5_UNID)
      If SB1->B1_COD <> WorkIP->EE9_COD_I
         SB1->(dbSeek(cFilSB1+WorkIP->EE9_COD_I))
      EndIf
      cUnid := SB1->B1_UM
   Else
      cUnid := SA5->A5_UNID
   EndIf
Else
   cUnid := If(lBotao,WorkIP->EE9_UNIDAD,M->EE9_UNIDAD)
EndIf
If cUnid <> ED3->ED3_UMPROD
   nQtdAux := AVTransUnid(cUnid,ED3->ED3_UMPROD,ED3->ED3_PROD,If(lBotao,WorkIP->EE9_SLDINI,M->EE9_SLDINI),.T.)
Else
   nQtdAux := If(lBotao,WorkIP->EE9_SLDINI,M->EE9_SLDINI)
EndIf
If nQtdAux == NIL
   If lBotao
      If !Empty(ED3->ED3_PROD)
         nNivel1 += 1
      Else
         nNivel2 += 1
      EndIf
   Else
      MsgStop(STR0063+;//"Não é possivel fazer a comprovação deste Ato Concessório,"
              STR0064+ED3->ED3_UMPROD+STR0065+"("+cUnid+")."+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;//" pois não existe conversão entre U.M. NCM("###") e U.M. Venda"
              STR0066)//"Atualize o Cadastro de Conversão de Unidades de Medida."
   EndIf
   Return .F.
EndIf

Return .T.

*------------------------------*
Function Apropria(lBotao,nQtd,nQtdSld)
*------------------------------*
Local lAutQtde:=.F., nPreco, nSldQuebra, cCodI := ""
Private nPercent  //LRL 28/05/04

Default nQtd := nQtdSld := 0

If nQtd == 0 .And. nQtdSld == 0
  nQtd    := nQtdAux
  nQtdSld := ED3->ED3_SALDO
EndIf

If ED3->ED3_NCM <> WorkIP->EE9_POSIPI .and. Left(ED3->ED3_NCM,8) <> "99999999"
	   MsgInfo(STR0027+Alltrim(ED3->ED3_AC)+STR0028+Alltrim(WorkIP->EE9_SEQUEN)+STR0029) //"NCM do Produto no Ato Concessorio " # " é diferente da NCM do Produto da Posicao " # " no Embarque. A.C. nao podera ser utilizado."

      //AAF 17/10/05 - Limpa o Ato já que não pode ser apropriado.
      WorkIP->EE9_ATOCON := ""
      WorkIP->EE9_SEQED3 := ""
   If(lBotao,nNivel1 += 1,)
   Return .F.
EndIf

//If !SoftLock("ED3")
If lMUserEDC  .And.  !oMUserEDC:Reserva("EMBARQUE_EXP","APROPRIA")  // PLB 05/12/06 - Tenta bloquear registros referentes Ato Concessorio
   If !lBotao
      MsgInfo(STR0030) //"Produto do Ato Concessorio esta sendo utilizado em outro processo e nao podera ser apropriado."
   Else
      lMens := .T.
      If !Empty(ED3->ED3_PROD)
         nNivel1 += 1
      Else
         nNivel2 += 1
      EndIf
   EndIf
   Return .F.
EndIf

nPreco := ConvVal(M->EEC_MOEDA,WorkIP->EE9_PRCINC,If(!Empty(WorkIP->EE9_DTRE),WorkIP->EE9_DTRE,dDataBase)) //GFc - 09/12/04
If lItFabric  // By JPP - 14/11/2007 - 14:00
   nPreco -= AE109VLDif() // By JPP - 14/11/2007 - 14:00
EndIf
If (M->EEC_COBCAM=="2" .and. ED3->ED3_SAL_SE < nPreco) .or. (M->EEC_COBCAM=="1" .and. ED3->ED3_SAL_CO < nPreco) .or. !VerSaldoAC(2)
   MsgInfo(STR0031+CHR(13)+CHR(10)+STR0032+Alltrim(WorkIP->EE9_COD_I)+" US$"+;  //"Valor total do Produto maior que saldo em valor do A.C." # "Valor do Produto "
   Trans(nPreco,AVSX3("ED3_SAL_CO",6))+CHR(13)+CHR(10)+STR0033+Alltrim(ED3->ED3_AC)+" US$"+;  //"Saldo no A.C. "
   Trans(If(M->EEC_COBCAM=="1",ED3->ED3_SAL_CO,ED3->ED3_SAL_SE),AVSX3("ED3_SAL_CO",6)))
EndIf

If !(nQtdSld >= nQtd .and. If(nOpcApSld <> SLD_INSEXP,VerSaldoAC(3),.T.))////AOM - 15/09/2011
   lAutQtde := .T.
   If lExistEDD
      If lBotao
         AEDelWkAnt(ED3->ED3_AC,WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIP->EE9_SEQEMB/*AOM - 26/08/2011*/)
      Else
         AEDelWkAnt(ED3->ED3_AC,M->EE9_PEDIDO,M->EE9_SEQUEN,M->EE9_SEQEMB/*AOM - 26/08/2011*/)
      EndIf
   EndIf
EndIf

WorkIP->(RecLock("WorkIP",.F.))
WorkIP->EE9_ATOCON := ED3->ED3_AC
/*
If(!lBotao, M->EE9_SEQED3 := ED3->ED3_SEQSIS , WorkIP->EE9_SEQED3 := ED3->ED3_SEQSIS )
If(!lBotao,M->EE9_QT_AC := nQtdAux, WorkIP->EE9_QT_AC := nQtdAux)
If(!lBotao,M->EE9_VL_AC := nPreco, WorkIP->EE9_VL_AC := nPreco)
*/
//AAF 26/07/05 - Atualiza pela Work.
WorkIP->EE9_SEQED3 := ED3->ED3_SEQSIS
WorkIP->EE9_QT_AC := nQtd
WorkIP->EE9_VL_AC := nPreco

WorkIP->(msUnlock())
If lAutQtde
   nSldQuebra := AVTransUnid(ED3->ED3_UMPROD,cUnid,WorkIP->EE9_COD_I,nQtdSld)
   SubTotal()
   nPercent:=AjustaPeso(nSldQuebra,If(!lBotao,M->EE9_SLDINI,WorkIP->EE9_SLDINI),lBotao) //LRL 28/05/04
   If Type("cProdOld") == "C" .And. !Empty(cProdOld)
      cCodI := WorkIp->EE9_COD_I
      WorkIp->EE9_COD_I := cProdOld
   EndIf
   QuebraItem(nSldQuebra,lBotao)
   If !Empty(cCodI)
      WorkIp->EE9_COD_I := cCodI
      cCodI := ""
   EndIf
   WorkIP->(RecLock("WorkIP",.F.))
   /*
   If(!lBotao,M->EE9_SLDINI := nSldQuebra, WorkIP->EE9_SLDINI := nSldQuebra)
   If(!lBotao,M->EE9_QT_AC  := ED3->ED3_SALDO, WorkIP->EE9_QT_AC := ED3->ED3_SALDO)
   If(!lBotao,M->EE9_VL_AC  := If(M->EEC_COBCAM="1",ED3->ED3_SAL_CO,ED3->ED3_SAL_SE), WorkIP->EE9_VL_AC := If(M->EEC_COBCAM="1",ED3->ED3_SAL_CO,ED3->ED3_SAL_SE))
   If(!lBotao,M->EE9_PRCTOT := M->EE9_PRECO*M->EE9_SLDINI, WorkIP->EE9_PRCTOT := WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI)
   If(!lBotao,M->EE9_PSLQTO := M->EE9_PSLQUN*M->EE9_SLDINI, WorkIP->EE9_PSLQTO := WorkIP->EE9_PSLQUN*WorkIP->EE9_SLDINI)
   If(!lBotao,M->EE9_QTDEM1 := M->EE9_SLDINI/M->EE9_QE, WorkIP->EE9_QTDEM1 := WorkIP->EE9_SLDINI/WorkIP->EE9_QE)
   If(!lBotao,M->EE9_PSBRTO := M->EE9_PSBRTO*nPercent, WorkIP->EE9_PSBRTO := WorkIP->EE9_PSBRTO*nPercent)
   If(!lBotao,M->WP_SLDATU  := 0, WorkIP->WP_SLDATU := 0)
   IF !EMPTY(If(!lBotao,M->EE9_QE,WorkIP->EE9_QE))
      IF (!lBotao .and. (M->EE9_SLDINI%M->EE9_QE)==0) .or. ;
      (lBotao .and. (WorkIP->EE9_SLDINI%WorkIP->EE9_QE)==0)
         If(!lBotao,M->EE9_QTDEM1:=Int(M->EE9_SLDINI/M->EE9_QE),WorkIP->EE9_QTDEM1:=Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE)) //QUANT.DE EMBAL.
      Else
         If(!lBotao,M->EE9_QTDEM1:=Int(M->EE9_SLDINI/M->EE9_QE)+1,WorkIP->EE9_QTDEM1:=Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE)+1) //QUANT.DE EMBAL.
      ENDIF
   EndIf
   */
   //** AAF 26/07/05 - Apropriação com quebra sempre atualiza na work.
   WorkIP->EE9_SLDINI := nSldQuebra
   WorkIP->EE9_QT_AC  := AVTransUnid(If(!lBotao,M->EE9_UNIDAD,WorkIP->EE9_UNIDAD),ED3->ED3_UMPROD,If(!lBotao,M->EE9_COD_I,WorkIP->EE9_COD_I),nSldQuebra) //AAF 29/09/05 - Convertido para U.M. do A.C. //ED3->ED3_SALDO
   WorkIP->EE9_VL_AC  := WorkIP->EE9_QT_AC*ConvVal(M->EEC_MOEDA,WorkIP->EE9_PRECO,If(!Empty(WorkIP->EE9_DTRE),WorkIP->EE9_DTRE,dDataBase)) //AAF 26/07/05 - Utiliza valor do Item. //If(M->EEC_COBCAM="1",ED3->ED3_SAL_CO,ED3->ED3_SAL_SE)
   WorkIP->EE9_PRCTOT := WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI
   WorkIP->EE9_PSLQTO := WorkIP->EE9_PSLQUN*WorkIP->EE9_SLDINI

   //WorkIP->EE9_QTDEM1 := WorkIP->EE9_SLDINI/WorkIP->EE9_QE
   //AAF 26/07/05 - Quantidade de embalagem deve ser inteira.
   IF WorkIP->EE9_SLDINI%WorkIP->EE9_QE == 0
      WorkIP->EE9_QTDEM1:= WorkIP->EE9_SLDINI/WorkIP->EE9_QE        //QUANT.DE EMBAL.
   Else
      WorkIP->EE9_QTDEM1:= Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE)+1 //QUANT.DE EMBAL.
   EndIf

   WorkIP->EE9_PSBRTO := WorkIP->EE9_PSBRTO*nPercent
   WorkIP->WP_SLDATU  := 0
   //**

   WorkIP->(msUnlock())
   SumTotal()
   AE100PrecoI()
   If lExistEDD
      If lBotao
         AEGrvWKAnt(ED3->ED3_AC,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,nSldQuebra,WorkIP->EE9_PEDIDO,,WorkIP->EE9_SEQEMB/*AOM - 26/08/2011*/, lMsgExibe)
      Else
         AEGrvWKAnt(ED3->ED3_AC,M->EE9_COD_I,M->EE9_SEQUEN,M->EEC_DTEMBA,nSldQuebra,M->EE9_PEDIDO,,M->EE9_SEQEMB/*AOM - 26/08/2011*/)
      EndIf
   EndIf
EndIf

nAPos := ASCAN(aApropria,{|X| X[1]==WorkIP->EE9_ATOCON .and. X[2]=If(!lBotao,M->EE9_SEQED3,WorkIP->EE9_SEQED3) })
If nAPos > 0
   aApropria[nAPos,3] += If(!lBotao,M->EE9_QT_AC,WorkIP->EE9_QT_AC)
   aApropria[nAPos,4] += If(!lBotao,M->EE9_VL_AC,WorkIP->EE9_VL_AC)
Else
   AADD(aApropria,{WorkIP->EE9_ATOCON,WorkIP->EE9_SEQED3,WorkIP->EE9_QT_AC,WorkIP->EE9_VL_AC,WorkIP->EE9_VLSCOB})
EndIf

If lBotao
   nNivel1 := 0
   nNivel2 := 0
EndIf

Return .T.

*-----------------------------------------------------------*
Function ConfirmaAC(cAto,cPos,lBotao,lApro,nQtd,nQtdSld)
*-----------------------------------------------------------*
Local oDlg, nOp:=0, oBtnOK, oBtnNO
Local lRet := .T.
lApro:=If(lApro=NIL,lBotao,lApro)

Default nQtd := nQtdSld := 0  //AOM - 05/09/2011

//AOM - 05/09/2011
If nQtd == 0  .And. nQtdSld == 0
   nQtd    := nQtdAux
   nQtdSld := ED3->ED3_SALDO
EndIf

If nOpcAprop == AP_AUT_NAOCOMPROVADOS .Or. !lMsgExibe

   nOp:= 1
Else
   DEFINE MSDIALOG oDlg TITLE STR0034 ; //"Confirmacao de Apropriacao"
          FROM 15,03 To 30,47 OF oMainWnd

      @0.5,0.5  SAY STR0035 //"O melhor Ato Concessorio para este produto possui Saldo menor que "
      @1,0.5  SAY STR0036 //"Quantidade do Item na unidade de medida do item no A.C."
      @2,3  SAY AVSX3(If(!Empty(ED3->ED3_PROD),"ED3_PROD","ED3_NCM"),5) SIZE 50,8
      @2,9  MSGET If(!Empty(ED3->ED3_PROD),ED3->ED3_PROD,ED3->ED3_NCM) PICTURE If(!Empty(ED3->ED3_PROD),"@!",AVSX3("ED3_NCM",6)) WHEN .F. SIZE 60,7
      @3,3  SAY AVSX3("ED0_AC",5) SIZE 50,8
      @3,9  MSGET ED3->ED3_AC PICTURE "@!" WHEN .F. SIZE 60,7
      @4,3  SAY AVSX3("EE9_SLDINI",5) SIZE 50,8
      @4,9  MSGET nQtd PICTURE AVSX3("EE9_SLDINI",6) WHEN .F. SIZE 60,7//AOM - 05/09/2011
      @5,3  SAY AVSX3("ED3_SALDO",5) SIZE 50,8
      @5,9  MSGET nQtdSld PICTURE AVSX3("ED3_SALDO",6) WHEN .F. SIZE 60,7//AOM - 05/09/2011
      @8,7  BUTTON oBtnOK PROMPT STR0037 SIZE 40,13 ACTION (nOp:=1,oDlg:End()) OF oDlg //"Confirma A.C."
      If lBotao
         @8,19 BUTTON oBtnNO PROMPT STR0038 SIZE 55,13 ACTION (nOp:=2,oDlg:End()) OF oDlg //"Apropria outro A.C."
      Else
         @8,19 BUTTON oBtnNO PROMPT STR0039 SIZE 50,13 ACTION (nOp:=0,oDlg:End()) OF oDlg //"Cancelar"
      EndIf

ACTIVATE MSDIALOG oDlg CENTERED
EndIf

If nOp=1 .AND. !Apropria(lApro,nQtd,nQtdSld)
   nOp:= 0//AAF 26/07/05 - Limpar o ato que se não poder ser apropriado.
ElseIf nOp=2
   If !Empty(ED3->ED3_PROD)
      nNivel1 += 1
   Else
      nNivel2 += 1
   EndIf
Endif

If nOp=0
   //M->EE9_ATOCON := WorkIP->EE9_ATOCON

   //AAF 23/05/05 - Limpa o Ato já que não pode ser apropriado.
   WorkIP->EE9_ATOCON := ""
   WorkIP->EE9_SEQED3 := ""
   //** PLB 02/08/07
   WorkIP->EE9_VL_AC := 0
   WorkIP->EE9_QT_AC := 0
   lRet := .F.
   //**

EndIf

nOp:=0

Return lRet

*--------------------------*
Function AE101ValAto(cCampo)
*--------------------------*
Local lRet:=.T., cCGC, nOldED3Rec, i, cCGCAuxs:=""
Local nOldIPRec, cSequen, cProdPrinc := ""
Private cProdOld := ""
Private nQtdAux
Private lTipoItem := ChkFile("ED7") .And. ED7->(FieldPos("ED7_TPITEM")) > 0 .And. ED7->(FieldPos("ED7_PD")) > 0

Begin Sequence

If lIntDraw
   nOldED3Rec := ED3->(RecNo())
   Do Case
      Case cCampo == "EE9_ATOCON" .And. !Empty(M->EE9_ATOCON)
         If ExistCpo("ED0", M->EE9_ATOCON,2)
            If Posicione("ED0",2,xFilial("ED0")+M->EE9_ATOCON,"ED0_MODAL") == "1" .and.;//AAF 19/04/05 - Verifica se a modalidade é suspensão.
            if(EasyGParam("MV_EDC0005",,.F.), Posicione("ED0",2,xFilial("ED0")+M->EE9_ATOCON,"ED0_STATUS") != "6", .F.)  // ALS - 12/12/2007 - Caso esteja habilitado o envio para o Siscomex Web o Status deve ser Deferido
               EasyHelp(STR0098 +" ("+Alltrim(M->EE9_ATOCON)+")." + ENTER + STR0099) //"Ato concessório não deferido" ####"Para prosseguir, verifique se o campo Situação foi atualizado com a integração com o Easy Drawback Web"
               lRet:=.F.
            EndIf
         Else
            lRet := .F.
         EndIf
      Case cCampo == "TELA"
         If !Empty(M->EE9_ATOCON) .and. Empty(M->EE9_SEQED3)
            MsgInfo(STR0048) //"Necessário preencher a Seq. do Ato Concessório."
            lRet:=.F.
         ElseIf Empty(M->EE9_ATOCON) .and. !Empty(M->EE9_SEQED3)
            MsgInfo(STR0049) //"A Seq. do Ato não pode ser informada para Ato Concessório vazio."
            lRet:=.F.
         //** PLB 19/04/06 - Valida Ato Concessorio e Sequencia antes de fechar a tela
         ElseIf !AE101ValAto("EE9_SEQED3")
            lRet:=.F.
         //**
         EndIf
      Case cCampo == "EE9_SEQED3" .And. !Empty(M->EE9_SEQED3)
         cCGC := BuscaCGCFor(M->EEC_FORN,M->EEC_FOLOJA)
         //** PLB 09/08/07 - Ponto de Entrada para trocar o CGC
         If EasyEntryPoint("EECAE101")
            cNewCNPJ := ExecBlock("EECAE101",.F.,.F.,"TROCA_CNPJ")
            If ValType(cNewCNPJ) == "C"
               cCGC := cNewCNPJ
            EndIf
         EndIf
         //**
         //If !Empty(M->EE9_SEQED3) .And. (Empty(M->EE9_ATOCON) .or. ExistCpo("ED0", M->EE9_ATOCON)) //HVR 08/03/2006 - Adicionado !Empty(M->EE9_SEQED3) para validação do campo quando não for preenchida
         If ExistCpo("ED3", M->EE9_ATOCON + M->EE9_SEQED3,2)
            If (Empty(M->EE9_ATOCON) .or. (if(EasyGParam("MV_EDC0005",,.F.), Posicione("ED0",2,xFilial("ED0")+M->EE9_ATOCON,"ED0_STATUS") == "6", .T.) )  ) // ALS - 12/12/2007 - Caso o envio para siscomex web esteja ativado verifica se o Status é Deferido
               ED3->(dbSetOrder(2))
               If M->EE9_ATOCON<>WorkIP->EE9_ATOCON .or. M->EE9_SEQED3<>WorkIP->EE9_SEQED3
                  If !Empty(M->EE9_ATOCON) .and. !Empty(M->EE9_SEQED3)
                     If ED0->ED0_AC <> M->EE9_ATOCON
                        ED0->(dbSeek(cFilED0+M->EE9_ATOCON))
                     EndIf
                     If ED0->ED0_MODAL <> "2"  .and. if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS == "6", .T.)  // ALS - 12/12/2007 - Caso o envio para siscomex web esteja ativado verifica se o Status é Deferido
                        If ED3->ED3_AC <> M->EE9_ATOCON .or. ED3->ED3_SEQSIS <> M->EE9_SEQED3
                           ED3->(dbSeek(cFilED3+M->EE9_ATOCON+M->EE9_SEQED3))
                        EndIf
                        //** PLB 19/04/06 - Carrega CNPJ's Aux. do DrawBack e verifica com CNPJ do Fornecedor da Exportacao
                        For i := 1  to  ED0->(FCount())
                           If "CNPJ" $ ED0->(FieldName(i))  .And.  !Empty( ED0->&(FieldName(i)) )
                              cCGCAuxs += ED0->(FieldGet(i))+"/"
                           EndIf
                        Next i
                        If ED3->ED3_CNPJIM<>cCGC .And. !(cCGC $ cCGCAuxs)    // PLB 19/04/06 - Inclusao de verificacao de CNPJ's auxiliares
                           MsgInfo(STR0091) //STR0091	"O CNPJ do Fornecedor é diferente dos CNPJ's do Ato Concessorio."
                           lRet := .F.
                        //**
                        ElseIf !Empty(ED3->ED3_PROD)
                           If ED3->ED3_FILIAL<>cFilED3 .or. ED3->ED3_PROD<>M->EE9_COD_I .or. ED3->ED3_SALDO <= 0 .or. !Empty(ED0->ED0_DT_ENC)// - AOM - 14/09/2011 .or. !VerSaldoAC(1)  // .or. ED3->ED3_CNPJIM<>cCGC
                              /* RMD - 14/11/06
                                 Caso o item seja diferente do item na tabela ED3, verifica se é um item alternativo. Se for, caso o item
                                 principal for igual ao item da tabela ED3, compara as estruturas do principal, do alternativo e do ato concessório.
                                 Em caso de estrutura inválida, exibe as divergências ao usuário e pergunta se ele deseja continuar. Se continuar,
                                 o código do item principal é atribuído temporáriamente ao item alternativo e a função de validação é chamada
                                 novamente, para fazer a validação completa.
                              */
                              //**
                              If lTipoItem .And. Empty(cProdOld) .And. ED3->ED3_PROD <> M->EE9_COD_I .And. ((cProdPrinc := IG400BuscaItem("E", M->EE9_COD_I, ED3->ED3_PD)) == ED3->ED3_PROD)
                                 //Compara estrutura
                                 If AvCompEstr(cProdPrinc, M->EE9_COD_I, ED3->ED3_PD, .F., .T., , .T.)
                                    cProdOld := M->EE9_COD_I
                                    M->EE9_COD_I := cProdPrinc
                                    lRet := Ae101ValAto("EE9_SEQED3")
                                    M->EE9_COD_I := cProdOld
                                 EndIf
                                 Break
                              //**
                              Else
                                 If Empty(ED0->ED0_DT_ENC)
                                    MsgInfo(STR0040) //"Produto do Ato Concessorio nao serve para o Produto. Tente selecionar outro produto através da tecla <F3>."
                                 Else
                                    MsgInfo(STR0041) //"Ato Concessorio Encerrado."
                                 EndIf
                                 lRet := .F.
                                 ED3->(dbGoTo(nOldED3Rec))
                              EndIf
                           EndIf
                        Else
                           If ED3->ED3_FILIAL<>cFilED3  .or. ED3->ED3_NCM<>M->EE9_POSIPI .or. ED3->ED3_PROD<>Space(Len(ED3->ED3_PROD)) .or. ED3->ED3_SALDO <= 0 .or. !Empty(ED0->ED0_DT_ENC)//  - AOM - 14/09/2011 .or. !VerSaldoAC(1)  // .or. ED3->ED3_CNPJIM<>cCGC
                              If Empty(ED0->ED0_DT_ENC)
                                 MsgInfo(STR0040) //"Produto do Ato Concessorio nao serve para o Produto. Tente selecionar outro produto através da tecla <F3>."
                              Else
                                 MsgInfo(STR0041) //"Ato Concessorio Encerrado."
                              EndIf
                              lRet := .F.
                              ED3->(dbGoTo(nOldED3Rec))
                           EndIf
                        EndIf
                     ElseIf ED0->ED0_MODAL == "2"
                        MsgInfo(STR0042) //"A.C. nao pode ser utilizado pois sua modalidade e Isencao. Selecione um A.C. de Suspensao."
                        lRet := .F.
                        ED3->(dbGoTo(nOldED3Rec))

                     ElseIf if(EasyGParam("MV_EDC0005",,.F.), ED0->ED0_STATUS <> "6", .F.)  // ALS - 12/12/2007 - Caso o envio para siscomex web esteja ativado verifica se o Status é Deferido
                        MsgInfo(STR0069) //"A.C. não pode ser utilizado pois seu Status não é Deferido. Selecione um outro A.C."
                        lRet := .F.
                        ED3->(dbGoTo(nOldED3Rec))

                     EndIf
                     If lRet
                        If !VerificaQTD(.F.,,)
                           MsgInfo(STR0043) //"Nao e possivel apropriar este item ao Ato Concessorio pois item nao possui nao existe conversao entre as Unidades de Medida. Cadastre uma conversao para as unidades de medida."
                           lRet := .F.
                           ED3->(dbGoTo(nOldED3Rec))
                        /* NOPADO POR AOM - 04/07/2011 - Ja esta granvanda a anterioridade do drawback em outro momento.ElseIf lExistEDD .and. lIntDraw .and. !AeApSldAC(ED3->ED3_AC,M->EE9_COD_I,M->EE9_SEQUEN,M->EEC_DTEMBA,M->EE9_SLDINI,M->EE9_PEDIDO) // GFC - 18/07/2003 - Drawback Anterioridade
                           lRet := .F.
                           ED3->(dbGoTo(nOldED3Rec))*/
                        ElseIf ED3->ED3_DT_VAl < dDataBase
                           MsgInfo(STR0044) //"Ato Concessorio escolhido esta com a Data de Validade expirada."
                        EndIf
                     EndIf
                  Else
                     AEAntMarca(2)
                  EndIf
               EndIf
               ED3->(dbSetOrder(1))
            ElseIf !Empty(M->EE9_SEQED3)
               EasyHelp(STR0098 + " ("+Alltrim(M->EE9_ATOCON)+")." + ENTER + STR0099) //"Ato concessório não deferido" ####"Para prosseguir, verifique se o campo Situação foi atualizado com a integração com o Easy Drawback Web"
               lRet := .F.
               ED3->(dbGoTo(nOldED3Rec))
            EndIf
         Else
            lRet := .F.
         EndIf
      Case cCampo  == "WHEN"
         If !Inclui .and. !Empty(WorkIP->EE9_ATOCON)
            lRet := .F.
         ElseIf !Empty(M->EE9_ATOCON)
            ED0->(dbSeek(cFilED0+M->EE9_ATOCON))
            If ED0->ED0_MODAL == "2"
               lRet := .F.
            EndIf
         EndIf
      Case cCampo  == "WSEQ"
         If Empty(M->EE9_ATOCON) .or. !AE100ValAto("WHEN")
            // M->EE9_SEQED3 := Space(Len(EE9->EE9_SEQED3))
            lRet := .F.
         EndIf
      Case cCampo == "EE9_UNIDAD"
         If lIntDraw .and. !Empty(M->EE9_ATOCON) .and. WorkIP->EE9_UNIDAD <> M->EE9_UNIDAD
            MsgInfo(STR0045) //"Unidade de Medida nao pode ser alterada pois ja existe Ato Concessorio apropriado para este produto. Desaproprie o A.C."
            lRet := .F.
         EndIf
      Case cCampo == "EE9_SLDINI"
         If lIntDraw .and. !Empty(WorkIP->EE9_ATOCON) .and. M->EE9_SLDINI > WorkIP->WP_OLDINI
            nOldIPRec := WorkIP->(RecNo())
            cSequen   := WorkIP->EE9_SEQUEN
            WorkIP->(dbSkip())
            If WorkIP->EE9_SEQUEN == cSequen
               Help(" ",1,"AVG0000636")
               lRet := .F.
            EndIf
            WorkIP->(dbGoTo(nOldIPRec))
         EndIf
   EndCase
EndIf

End Sequence

Return lRet

*--------------------------*
Function AE100AtuAC(lVerif)
*--------------------------*
Local nOldED3Rec:=ED3->(RecNo())
Local lAutQtd:= !Empty(WorkIP->WP_OLDINI) .AND. WorkIP->WP_OLDINI <> M->EE9_SLDINI //AAF 25/11/09 - Verificar se WorkIP->WP_OLDINI está preenchida.

Private cUnid

Private lApropParc := EasyGParam("MV_EDC0003",,.T.)  // PLB 02/08/07 - Define se ocorre apropriacao parcial

If Type("nOpcApSld") == "U"
   _SetOwnerPrvt("nOpcApSld", EasyGParam("MV_EEC0004",,0))//AOM - 29/08/2011
EndIf

If Type("nOpcAprop") == "U"
   _SetOwnerPrvt("nOpcAprop", EasyGParam("MV_EEC0005",,0))//AOM - 29/08/2011
EndIf



Begin Sequence

If lVerif
   If M->EE9_ATOCON<>WorkIP->EE9_ATOCON .or. M->EE9_SEQED3<>WorkIP->EE9_SEQED3 .or. lAutQtd
      If !Empty(WorkIP->EE9_ATOCON)
         //nOldED3Rec := ED3->(RecNo())
         //ED3->(dbSeek(cFilED3+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3))
         //ED3->(msUnlock())
         If lMUserEDC
            oMUserEDC:Solta("EMBARQUE_EXP","ALTERA_ATO")  // PLB 05/12/06
         EndIf
         DelSaldoAC()
         //ED3->(dbGoTo(nOldED3Rec))
      EndIf
      lAtuAc := .T.
   ElseIf lExistEDD .and. !Empty(M->EE9_ATOCON) .and. (Empty(EE9->EE9_ATOCON) .or. M->EE9_ATOCON <> EE9->EE9_ATOCON)
      WorkAnt->(dbSetOrder(1))
      If !WorkAnt->(dbSeek(M->EE9_ATOCON+M->EEC_PREEMB+M->EE9_PEDIDO+M->EE9_SEQUEN+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,M->EE9_SEQEMB,"")))//AOM - 26/08/2011
         AeApSldAC(M->EE9_ATOCON,M->EE9_COD_I,M->EE9_SEQUEN,M->EEC_DTEMBA,M->EE9_SLDINI,M->EE9_PEDIDO,,M->EE9_SEQEMB,,,,.F./*AOM - 26/08/2011*/)
      EndIf
   EndIf
Else
   lMsgExibe := If(Type("lMsgExibe") == "U",.F.,lMsgExibe)  // GFP - 04/09/2014
   If !Empty(M->EE9_ATOCON) .and. (Empty(EE9->EE9_ATOCON) .or. M->EE9_ATOCON <> EE9->EE9_ATOCON)
      VerificaQTD(.F.) //AAF - 21/05/05 - False pois não acionado pelo botão. //.T.  //.F.
      If nQtdAux <> NIL
         If !OpcApropAutomatica()//AOM - 30/08/2011
            Break
         EndIf
         If ED3->ED3_SALDO >= nQtdAux .and. If(nOpcApSld <> SLD_INSEXP,VerSaldoAC(3),.T.)//AOM - 15/09/2011
            If lExistEDD  //GFC - 18/07/2003 - Drawback Anterioridade
               //** AAF 20/06/05
               EDD->(dbSetOrder(3))
               If !EDD->(dbSeek(cFilEDD+M->EEC_PREEMB+WorkIP->EE9_PEDIDO+WorkIP->EE9_SEQUEN+WorkIP->EE9_COD_I+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,WorkIP->EE9_SEQEMB,"")))//AOM - 26/08/2011
                  If !AeApSldAC(ED3->ED3_AC,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,nQtdAux,WorkIP->EE9_PEDIDO,,WorkIP->EE9_SEQEMB,/*cPos*/,/*lBotao*/,.F.,.F./*AOM - 26/08/2011*/) //.OR.;
                     //!Apropria(.F.)//AAF - 21/05/05 - False pois não acionado pelo botão. //.T. //.F.- NOPADO POR AOM - 26/08/2011

                     WorkIP->EE9_ATOCON := ""
                     WorkIP->EE9_SEQED3 := ""
                     WorkIP->EE9_VL_AC  := 0
                     WorkIP->EE9_QT_AC  := 0
                  Endif
               EndIf
               //**
            Else
               Apropria(.F.) //.T. //.F.
            EndIf
         ElseIf If(nOpcApSld <> SLD_INSEXP,VerSaldoAC(3),.T.) //AOM - 15/09/2011
            If lExistEDD  //GFC - 18/07/2003 - Drawback Anterioridade
               //** AAF 20/06/05
               EDD->(dbSetOrder(3))
               If !EDD->(dbSeek(cFilEDD+M->EEC_PREEMB+WorkIP->EE9_PEDIDO+WorkIP->EE9_SEQUEN+WorkIP->EE9_COD_I+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3+ If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,WorkIP->EE9_SEQEMB,"")))//AOM - 26/08/2011
                  // PLB 02/08/07 - Define se ocorre apropriacao parcial
                  If lApropParc  //.And.  AeApSldAC(ED3->ED3_AC,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,nQtdAux,WorkIP->EE9_PEDIDO,ED3->ED3_SALDO < nQtdAux,WorkIP->EE9_SEQEMB,/*cPos*/,.F.,.T.,.T./*AOM - 26/08/2011*/)
                     //ConfirmaAC(WorkIP->EE9_ATOCON,0,.F.,.F.) - NOPADO POR AOM - 26/08/2011
                     If !AeApSldAC(ED3->ED3_AC,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,nQtdAux,WorkIP->EE9_PEDIDO,ED3->ED3_SALDO < nQtdAux,WorkIP->EE9_SEQEMB,/*cPos*/,.F.,.F.,.T./*AOM - 26/08/2011*/)
                        WorkIP->EE9_ATOCON := ""
                        WorkIP->EE9_SEQED3 := ""
                        WorkIP->EE9_VL_AC  := 0
                        WorkIP->EE9_QT_AC  := 0
                        // PLB 02/08/07
                        If !lApropParc
                           MsgInfo(STR0068)  // "Ato Concessório não possui Saldo suficiente para Apropriação."
                        EndIf
                     EndIf
                  Else
                     WorkIP->EE9_ATOCON := ""
                     WorkIP->EE9_SEQED3 := ""
                     WorkIP->EE9_VL_AC  := 0
                     WorkIP->EE9_QT_AC  := 0
                     // PLB 02/08/07
                     If !lApropParc
                        MsgInfo(STR0068)  // "Ato Concessório não possui Saldo suficiente para Apropriação."
                     EndIf
                  Endif
               EndIf
               //**
            Else
               //ConfirmaAC(WorkIP->EE9_ATOCON,0,.F.,.T.)
               //** PLB 02/08/07 - Define se ocorre apropriacao parcial
               If lApropParc
                  ConfirmaAC(WorkIP->EE9_ATOCON,0,.F.,.T.)
               Else
                  WorkIP->EE9_ATOCON := ""
                  WorkIP->EE9_SEQED3 := ""
                  WorkIP->EE9_VL_AC  := 0
                  WorkIP->EE9_QT_AC  := 0
                  MsgInfo(STR0068)  // "Ato Concessório não possui Saldo suficiente para Apropriação."
               EndIf
               //**
            EndIf
         Else
            //AAF 02/08/05 - Não permite apropriação caso não haja saldo.
            MsgStop(STR0067)//"Não há saldo de exportação a comprovar deste produto neste Ato Concessório."
            WorkIP->EE9_ATOCON := ""
            WorkIP->EE9_SEQED3 := ""
         EndIf
      Else
         WorkIP->EE9_ATOCON := ""
         WorkIP->EE9_SEQED3 := ""
         WorkIP->EE9_VL_AC  := 0
         WorkIP->EE9_QT_AC  := 0
      Endif
   Else  //If !Empty(WorkIP->EE9_ATOCON)
      WorkIP->EE9_ATOCON := ""
      WorkIP->EE9_SEQED3 := ""
      WorkIP->EE9_VL_AC  := 0
      WorkIP->EE9_QT_AC  := 0
   EndIf
EndIf

End Sequence
ED3->(dbGoTo(nOldED3Rec))

Return .T.

*--------------------------------*
Function SaldosED3(lAppend)
*--------------------------------*
Local nOldOrd:=ED3->(IndexOrd())
Local cProdOri := ""   // GFP - 18/08/2014
Private lEYUEstorno := .F.
ED3->(dbSetOrder(2))

If !Empty(WorkIP->EE9_ATOCON)
   If !Inclui .and. (WorkIP->EE9_ATOCON <> EE9->EE9_ATOCON .or. WorkIP->EE9_SEQED3 <> EE9->EE9_SEQED3)
      VoltaSaldoED3("P")
   EndIf
   If ED3->(dbSeek(xFilial("ED3")+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3)) //HVR 08/03/2006 - Adicionado If para evitar problema com Reclock nos casos de não posicionar o registro
      ED3->(dbSeek(xFilial("ED3")+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3))
      //ED3->(msUnlock()) //Libera SoftLock
      If !ED3->( IsLocked() )  // PLB 09/10/06 - Verifica se está travado.
         ED3->(RECLOCK("ED3",.F.))
      EndIf
      If !Inclui .and. EE9->EE9_ATOCON==ED3->ED3_AC .and. EE9->EE9_SEQED3==ED3->ED3_SEQSIS
         ED3->ED3_SALDO  += EE9->EE9_QT_AC
         cProdOri := IG400BuscaItem("E",EE9->EE9_COD_I)   // GFP - 18/08/2014
         //ED3->ED3_SALNCM += AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,cProdOri,EE9->EE9_QT_AC)   // GFP - 18/08/2014
         ED3->ED3_SALNCM += ConvQtdAto(ED3->ED3_UMPROD,ED3->ED3_UMNCM,cProdOri,EE9->EE9_QT_AC,"EE9")// RMD - 27/08/2014
         If(EEC->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=EE9->EE9_VL_AC,ED3->ED3_SAL_SE+=EE9->EE9_VL_AC)

         ED3->ED3_SAL_SE+=EE9->EE9_VLSCOB

         //WFS 18/12/08 - 076773
         If EasyEntryPoint("EECAE101")
            ExecBlock("EECAE101",.F.,.F.,"SALDOSED3_SOMAEE9")
         EndIf
      EndIf
      ED3->ED3_SALDO  -= WorkIP->EE9_QT_AC
      cProdOri := IG400BuscaItem("E",WorkIP->EE9_COD_I)   // GFP - 18/08/2014
      //ED3->ED3_SALNCM -= AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,cProdOri,WorkIP->EE9_QT_AC)   // GFP - 18/08/2014
      ED3->ED3_SALNCM -= ConvQtdAto(ED3->ED3_UMPROD,ED3->ED3_UMNCM,cProdOri,WorkIP->EE9_QT_AC,"WORKIP")// RMD - 27/08/2014
      If(M->EEC_COBCAM=="1",ED3->ED3_SAL_CO-=WorkIP->EE9_VL_AC,ED3->ED3_SAL_SE-=WorkIP->EE9_VL_AC)

      ED3->ED3_SAL_SE-=WorkIP->EE9_VLSCOB

      //WFS 18/12/08 - 076773
      If EasyEntryPoint("EECAE101")
         ExecBlock("EECAE101",.F.,.F.,"SALDOSED3_SUBWORKIP")
      EndIf
      ED3->(msUnlock())
   EndIf //HVR

ElseIf !Empty(EE9->EE9_ATOCON)
   VoltaSaldoED3("P")
   If lItFabric  // By JPP - 14/11/2007 - 14:00
      lEYUEstorno := .T.
   EndIf
EndIf

If lItFabric  // By JPP - 14/11/2007 - 14:00
   AE109SalED3()
EndIf

ED3->(dbSetOrder(nOldOrd))

Return.T.

*----------------------------------*
Function VoltaSaldoED3(cTipo)
*----------------------------------*
Local cProdOri := ""   // GFP - 18/08/2014
If cTipo=="E" .and. EEC->EEC_STATUS==ST_PC
   Return .T.
//ElseIf ED3->(dbSeek(cFilED3+EE9->EE9_ATOCON+EE9->EE9_SEQED3)) // AST 06/01/09 - Quando integrado com compras, ao criar uma nota de devolução, a rotina é chamada diretamente do EECAE100, sem declarar a variavel cFilED3
ElseIf ED3->(dbSeek(xFilial("ED3")+EE9->EE9_ATOCON+EE9->EE9_SEQED3))
   //ED3->(msUnlock()) //Libera SoftLock
   If !ED3->( IsLocked() )  // PLB 09/10/06 - Verifica se está travado.
      ED3->(RECLOCK("ED3",.F.))
   EndIf
   ED3->ED3_SALDO  += EE9->EE9_QT_AC
   cProdOri := IG400BuscaItem("E",EE9->EE9_COD_I)   // GFP - 18/08/2014
   //ED3->ED3_SALNCM += AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,cProdOri,EE9->EE9_QT_AC)   // GFP - 18/08/2014
   ED3->ED3_SALNCM += ConvQtdAto(ED3->ED3_UMPROD,ED3->ED3_UMNCM,cProdOri,EE9->EE9_QT_AC,"EE9")// RMD - 27/08/2014
   If(EEC->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=EE9->EE9_VL_AC,ED3->ED3_SAL_SE+=EE9->EE9_VL_AC)

   ED3->ED3_SAL_SE+=EE9->EE9_VLSCOB

   //WFS 18/12/08 - 076773
   If EasyEntryPoint("EECAE101")
      ExecBlock("EECAE101",.F.,.F.,"VOLTASALDO_ED3")
   EndIf
   ED3->(msUnlock())
   Ae101DelEDD() //AOM - 15/04/2010
EndIf

Return .T.

*---------------------------------------------------------------------------------------------*
Function AELogAnt(cRegSiscomex)
*---------------------------------------------------------------------------------------------*
Local cFrom, cTo, cCC, cSubject, cBody:="", lOk
Local cServer, cAccount, cPassword, cError
Default cRegSiscomex:= ""

cServer   := EasyGParam("MV_WFSMTP")
cAccount  := EasyGParam("MV_WFACC")
cPassword := EasyGParam("MV_WFPASSW")
cFrom     := EasyGParam("MV_WFMAIL")
cTo       := EasyGParam("MV_MAILAVI")
cCC       := "" //:= EasyGParam("MV_WFSMTP")
cSubject  := STR0006 //"Drawback Suspensão - Anterioridade"

cBody += "<HTML>"
cBody += "<BODY>"
cBody += "<P ALIGN=CENTER><FONT FACE='Courier New, monospace'>"+STR0007 //"Inconsistência na Anterioridade - Drawback Suspensão"
cBody += "</FONT>"
cBody += "</P>"
cBody += "<P ALIGN=JUSTIFY>"+STR0008+Alltrim(EDD->EDD_PROD)+STR0010+Alltrim(EDD->EDD_ITEM)+STR0009+Alltrim(EDD->EDD_AC)+". " //"O produto exportado " # " foi utilizado para comprovação de Drawback porém não possui importação para o Item " # ", de sua estrutura, que comprove anterioridade no Ato "
cBody += STR0011 //"Abaixo seguem os dados complementares."
cBody += "<BR><BR></FONT><BR>"
cBody += "</P>"
cBody += "<TABLE WIDTH=100% BORDER=1 CELLPADDING=4 CELLSPACING=3>"
cBody += "<COL WIDTH=85*>"
cBody += "<COL WIDTH=85*>"
cBody += "<COL WIDTH=85*>"
cBody += "<COL WIDTH=85*>"
cBody += "<COL WIDTH=85*>"
cBody += "<THEAD>"
cBody += "<TR BGCOLOR='#ffffff' VALIGN=TOP>"
cBody += "<TD WIDTH=20%>"
cBody += "<P ALIGN=CENTER><B>"+STR0012+"</B></P>" //"Embarque"
cBody += "</TD>"
cBody += "<TD WIDTH=20%>"
cBody += "<P ALIGN=CENTER><B>"+STR0013+"</B></P>" //"Pedido"
cBody += "</TD>"
cBody += "<TD WIDTH=20%>"
cBody += "<P ALIGN=CENTER><B>"+STR0014+"</B></P>" //"Sequência"
cBody += "</TD>"
cBody += "<TD WIDTH=20%>"
cBody += "<P ALIGN=CENTER><B>"+STR0015+"</B></P>" //"Qtd. sem Importação"
cBody += "</TD>"
cBody += "<TD WIDTH=20%>"
cBody += "<P ALIGN=CENTER><B>"+STR0016+"</B></P>" //"Data do RE"
cBody += "</TD>"
cBody += "</TR>"
cBody += "</THEAD>"
cBody += "<TBODY>"
cBody += "<TR VALIGN=TOP>"
cBody += "<TD WIDTH=20%>"
cBody += "<P>"+Alltrim(EDD->EDD_PREEMB)
cBody += "</P>"
cBody += "</TD>"
cBody += "<TD WIDTH=20%>"
cBody += "<P>"+Alltrim(EDD->EDD_PEDIDO)
cBody += "</P>"
cBody += "</TD>"
cBody += "<TD WIDTH=20%>"
cBody += "<P>"+Alltrim(EDD->EDD_SEQUEN)
cBody += "</P>"
cBody += "</TD>"
cBody += "<TD WIDTH=20%>"
cBody += "<P>"+Alltrim(Trans(EDD->EDD_QTD*-1,AVSX3("EDD_QTD",6)))
cBody += "</P>"
cBody += "</TD>"
cBody += "<TD WIDTH=20%>"
cBody += "<P>"+DtoC(EDD->EDD_DTRE)
cBody += "</P>"
cBody += "</TD>"
cBody += "</TR>"
cBody += "</TBODY>"
cBody += "</TABLE>"
cBody += "<P ALIGN=CENTER><BR><BR>"
cBody += "</P>"
cBody += "</BODY>"
cBody += "</HTML>"

If !Empty(cServer) .and. !Empty(cAccount)  //GFC - 09/12/04
   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk
   If lOk
      If !Empty(cCC)
         SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody Result lOk
      Else
         SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody Result lOk
      EndIf
      If !lOk
         GET MAIL ERROR cError
         ConOut(STR0017+cError+STR0018+cSubject+STR0019) //"Erro no envio de Email - " # " O e-mail '" # "' não pôde ser enviado."
      EndIf
   Else
      GET MAIL ERROR cError
      EECMsg(STR0020+cError+STR0018+cSubject+STR0019) //"Erro na conexão com o servidor de Email - " # " O e-mail '" # "' não pôde ser enviado."
   EndIf
   DISCONNECT SMTP SERVER
EndIf
If !IsMemVar("cFilEDE")
   cFilEDE:= xFilial("EDE")
EndIf
EDE->(RecLock("EDE",.T.))
EDE->EDE_FILIAL := cFilEDE
EDE->EDE_AC     := EDD->EDD_AC
EDE->EDE_PREEMB := EDD->EDD_PREEMB
EDE->EDE_PROD   := EDD->EDD_PROD
EDE->EDE_PEDIDO := EDD->EDD_PEDIDO
EDE->EDE_SEQUEN := EDD->EDD_SEQUEN
EDE->EDE_RE     := cRegSiscomex //EE9->EE9_RE
EDE->EDE_ITEM   := EDD->EDD_ITEM
EDE->EDE_QTD    := EDD->EDD_QTD * -1
EDE->EDE_DT     := dDataBase
EDE->EDE_USUARI := AllTrim(cUserName)  //PLB 30/01/06 - Alteração na Gravação do Campo Usuário
EDE->(msUnlock())

Return .T.

*---------------------------------------------------------------------------------------------*
Function AE101ESTAC()   //GFC - 18/07/2003 - Anterioridade Drawback
*---------------------------------------------------------------------------------------------*
Local lRET:=.T., nAPos:={}, nRecno, nVlComis := 0, oMark, aBotao:={}, lInverte := .f., ni:=0, i:=0
Local nOp:=0, cTitulo:=STR0046, aCampoPED1:={} //"Estorno do Ato"
Local lMUserEDC := FindFunction("EDCMultiUser")
Local oMUserEDC
Local aPrincipais := {}
Private cMarca := GetMark()
If lMUserEDC
   oMUserEDC := EDCMultiUser():Novo()
EndIf
If Type("lAbriuExp") = "U"
   lAbriuExp := .f.
EndIf

EE8->(dbSetOrder(1))
EE7->(dbSetOrder(1))
EE9->(dbSetOrder(2))
EE9->(dbSeek(XFILIAL()+EEC->EEC_PREEMB))

WorkIP->(AvZap())

Do While !EE9->(EOF()) .AND. EE9->EE9_FILIAL==XFILIAL("EE9") .AND.;
EE9->EE9_PREEMB == EEC->EEC_PREEMB

   If Empty(EE9->EE9_ATOCON)
      EE9->(dbSkip())
      Loop
   EndIf

   WorkIP->(RecLock("WorkIP",.T.))

   AVREPLACE("EE9","WorkIP")

   FOR I := 1 TO LEN(aMEMOITEM)
      IF WORKIP->(FIELDPOS(aMEMOITEM[i,2])) > 0
         WORKIP->&(aMEMOITEM[I,2]) := If(lAbriuExp, MSMM_DR(EE9->&(aMEMOITEM[I,1]),AVSX3(aMEMOITEM[I,2],AV_TAMANHO)), MSMM(EE9->&(aMEMOITEM[I,1]),AVSX3(aMEMOITEM[I,2],AV_TAMANHO)))
      ENDIF
   NEXT

   ///WorkIP->EE9_VM_DES := MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES")[AV_TAMANHO])

   WorkIP->WP_FLAG  := ""
   WorkIP->WP_RECNO := EE9->(RECNO())

   IF EE8->(dbSeek(XFILIAL("EE8")+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
      WorkIP->WP_SLDATU :=EE8->EE8_SLDATU
   Endif

   WorkIP->(MsUnlock())

   EE9->(DBSKIP(1))
EndDo

If WorkIP->(EasyRecCount()) > 0

   If IIF(lMUserEDC,oMUserEDC:Reserva("EMBARQUE_EXP","ESTORNA_ATO"),.T.)
      WorkIP->(dbGoTop())

      AADD(aCampoPED1,{"WP_FLAG",,""})
      For ni:=1 to Len(aCampoPED)
         AADD(aCampoPED1,aCampoPED[ni])
      Next ni


      // by CRF 21/10/2010 - 15:44
      aCampoPED1:= AddCpoUser(aCampoPED1,"EE9","2")



      Aadd(aBotao,{"LBTIK",{|| Processa({|| AEEstMarca(.T.)},STR0047),WorkIP->(dbGoTop()) },STR0047}) //"Marca/Desmarca Todos"

      DEFINE MSDIALOG oDlg TITLE cTitulo FROM oMainWnd:nTop+120,oMainWnd:nLeft+85 TO oMainWnd:nBottom-60,oMainWnd:nRight - 5 OF oMainWnd PIXEL

         nLinha :=(oDlg:nClientHeight-4)/2
         oMark:= MsSelect():New("WorkIP","WP_FLAG",,aCampoPED1,@lInverte,@cMarca,{15,1,nLinha,(oDlg:nClientWidth-4)/2},,,oDlg)
         oMark:bAval:={|| AEEstMarca(.F.)}

         oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
         oDlg:lMaximized := .T.
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},{||nOp:=0,oDlg:End()},,aBotao)// CENTERED

      If nOp = 1
         ED3->(dbSetOrder(2))
         WorkIP->(dbGoTop())
         Begin TransAction
         Do While !WorkIP->(EOF())
            If WorkIP->WP_FLAG <> cMarca
               WorkIP->(dbSkip())
               Loop
            EndIf
            EE9->(dbGoTo(WorkIP->WP_RECNO))
            VoltaSaldoED3("P")
            If lExistEDD  //GFC - 18/07/2003 - Drawback Anterioridade
               EDD->(dbSetOrder(3))
               If EDD->(dbSeek(cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EE9->EE9_COD_I+EE9->EE9_ATOCON+EE9->EE9_SEQED3+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,EE9->EE9_SEQEMB,"")))//AOM - 26/08/2011
                  ACDelAnt()
               Else
                  If Len(aPrincipais := IG400AllItens("E", EE9->EE9_COD_I)) > 0
                     For nI:=1 To Len(aPrincipais)
                        If EDD->(dbSeek(cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+AvKey(aPrincipais[nI][1],"EDD_PROD")+EE9->EE9_ATOCON+EE9->EE9_SEQED3+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,EE9->EE9_SEQEMB,"")))//AOM - 26/08/2011
                           ACDelAnt(cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+AvKey(aPrincipais[nI][1],"EDD_PROD")+EE9->EE9_ATOCON+EE9->EE9_SEQED3)
                        EndIf
                     Next
                  EndIf
               EndIf
            EndIf
            /* wfs 01/11/2019.
               Retirada a aglutinação dos itens do embarque.
               Existem cenários adicionais a serem considerados, de vinculações com o item após a quebra do item pelo ato concessório, como vinculação de notas fiscais de saída e remessas; transmissão da DU-e dentre outros.
               Como o saldo do ato concessório, que é o ponto relevante, não é impactado por este tratamento, manter a quebra gerada em virtude da apropriação do ato não terá problema para os passos
               que virão a seguir no processo.
            VoltaQuebra() */
            /* wfs 01/11/2018
               Desvincula o ato concessório do item do embarque */
            DesvincAto()

            //Apaga os registros de insumos.
            If ChkFile("EDG")
               EDG->(DbSetOrder(1))
               If EDG->(DbSeek(xFilial("EDG")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB))
                  While EDG->(!EOF()) .and. EDG->(EDG_FILIAL+EDG_PREEMB+EDG_SEQEMB) ==;
                                             xFilial("EDG")+EE9->EE9_PREEMB+EE9->EE9_SEQEMB

                     EDG->(RecLock("EDG",.F.))
                     EDG->(DbDelete())
                     EDG->(MsUnlock())

                     EDG->(DbSkip())
                  EndDo
               EndIf
            EndIf

            WorkIP->(dbSkip())
         EndDo
         End TransAction
         ED3->(dbSetOrder(1))
      EndIf
   EndIf
Else
   MsgInfo(STR0050)  //"Nenhum Item deste Embarque possui Ato Concessório."
EndIf

If lMUserEDC
   oMUserEDC:Fim()  // PLB 05/12/06 - Solta registros presos e reinicializa objeto
EndIf

Return .T.

*-----------------------------------------------------------------------------------------------*
Function AEEstMarca(lTodos)   //GFC - 18/07/2003 - Anterioridade Drawback
*-----------------------------------------------------------------------------------------------*
Local cMarcaAux:=cMarca

If lTodos
   WorkIP->(dbGoTop())
   If WorkIP->WP_FLAG == cMarca
      cMarcaAux:=""
   EndIf
   Do While !WorkIP->(EOF())
      WorkIP->WP_FLAG := cMarcaAux
      WorkIP->(dbSkip())
   EndDo
Else
   If WorkIP->WP_FLAG == cMarca
      cMarcaAux:=""
   EndIf
   WorkIP->WP_FLAG := cMarcaAux
EndIf

Return .T.

*--------------------------------------------------------------------------------------------*
Function AEGrvWKAnt(cAto,cProd,cSequen,dDtEmba,nQtdComp,cPedido,lExistQuebra,cSeqEmb,lExibeComp)  //GFC - 18/07/2003 - Anterioridade Drawback
*--------------------------------------------------------------------------------------------*
Local aSX3Ant:={}, aControle:={}, /*nTotED1:=0, RMD - 16/04/14*/ lConfirma:=.F., ni:=0, cCampo, aArrayAux:={}, nInd:=0
Local nRecAux, nQtdAux:=0, nOrdEEM:=EEM->(IndexOrd()), i:=0
Local nVlSCob:= 0  //TRP - 16/02/2009
Local lRet := .T.
Local aItNegativo := {} , aItPositivo := {}
Local cMsg := ""
Local lIndexPed := "EDD_PEDIDO" $ EDD->(IndexKey(1)) .And. "EDD_PEDIDO" $ EDD->(IndexKey(2))//AOM - 22/11/2011 - Verifica se o idice está atualizado com o campo Pedido
Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade
Local aAltern := {}, w := 0, lEDD := .F.  // GFP - 22/07/2014
Local cWkSeqMI
IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
	Private lLeadTime := EYJ->(FieldPos("EYJ_PRODUC")) > 0 .AND. EDC->(FieldPos("EDC_PRODUC")) > 0 .and.;
						 EDC->(FieldPos("EDC_LEADTI")) > 0 .AND. EasyGParam("MV_AVG0184",.F.,.F.)
Else
	Private lLeadTime := SB1->(FieldPos("B1_LEADTI")) > 0 .AND. EDC->(FieldPos("EDC_LEADTI")) > 0 .and.;
                         SB1->(FieldPos("B1_PRODUC")) > 0 .AND. EDC->(FieldPos("EDC_PRODUC")) > 0 .and.;
                         EasyGParam("MV_AVG0184",.F.,.F.)
EndIF

Private nLeadTime:=EasyGParam("MV_LEADANT",,30)
Private cAntExp := EasyGParam("MV_ANT_EXP",,"1") //AAF 18/04/05 - Indica qual data usar para verificar a anterioridade.
Private lExibeInsumo := EasyGParam("MV_EDC0007",,.F.) // ACB 21/07/2010 - Exibe insumos se não houver importação
Private lExibeMsg := .T.  // GFP - 19/12/2012

// RMD - 06/05/2014
Private nQtdCal := 0
Private lLoopED2 := .F.
Private nTotED1:=0

Default lExistQuebra:= .F.
Default cSeqEmb := Space(AVSX3("EE9_SEQEMB",AV_TAMANHO)) //AOM - 26/08/2011
Default lExibeComp := .T.

Begin Sequence

aControleAlt:= {}

If Type("lMFilEDC") == "U"
   lMFilEDC  := VerSenha(115)  ;
                .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
                .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0
EndIf


If(nOrdEEM<>2,EEM->(dbSetOrder(2)),)

If Empty(dDtEmba) .And. cAntExp == "1" .AND. EEM->(dbSeek(xFilial("EEM")+M->EEC_PREEMB+"N")) //AAF 18/04/05
   dDtEmba := EEM->EEM_DTNF
EndIf

//If(Empty(dDtEmba),dDtEmba:=dDataBase,)
If Empty(dDtEmba)
   If Type("M->EEC_ETD") <> "U" .and. !Empty(M->EEC_ETD)
      dDtEmba:=M->EEC_ETD
   Else
      dDtEmba:=dDataBase
   EndIf
EndIf

If(nOrdEEM<>2,EEM->(dbSetOrder(nOrdEEM)),)

ED0->(dbSeek(cFilED0+cAto))
If ED0->ED0_MODAL <> "1"
  Break
EndIf

If Select("WorkAnt") = 0
   aSX3Ant :={{"EDD_AC"    ,"C",AVSX3("EDD_AC"    ,3),0},;
              {"EDD_PD"    ,"C",AVSX3("EDD_PD"    ,3),0},;
              {"EDD_HAWB"  ,"C",AVSX3("EDD_HAWB"  ,3),0},;
              {"EDD_PO_NUM","C",AVSX3("EDD_PO_NUM",3),0},;
              {"EDD_INVOIC","C",AVSX3("EDD_INVOIC",3),0},;
              {"EDD_ITEM"  ,"C",AVSX3("EDD_ITEM"  ,3),0},;
              {"EDD_POSICA","C",AVSX3("EDD_POSICA",3),0},;
              {"EDD_SEQSII","C",AVSX3("EDD_SEQSII",3),0},;
              {"EDD_PROD"  ,"C",AVSX3("EDD_PROD"  ,3),0},;
              {"EDD_PREEMB","C",AVSX3("EDD_PREEMB",3),0},;
              {"EDD_PEDIDO","C",AVSX3("EDD_PEDIDO",3),0},;
              {"EDD_SEQUEN","C",AVSX3("EDD_SEQUEN",3),0},;
              {"EDD_SEQSIE","C",AVSX3("EDD_SEQSIE",3),0},;
              {"EDD_QTD"   ,"N",AVSX3("EDD_QTD"   ,3),AVSX3("EDD_QTD"   ,4)},;
              {"EDD_DTREG" ,"D",8,0},;
              {"EDD_DTRE"  ,"D",8,0},;
              {"EDD_QTD_OR","N",AVSX3("EDD_QTD_OR",3),AVSX3("EDD_QTD_OR",4)},;
              {"EDD_QTD_EX","N",AVSX3("EDD_QTD_EX",3),AVSX3("EDD_QTD_EX",4)},;
              {"EDD_LEAD"  ,"N",AVSX3("EDD_LEAD"  ,3),AVSX3("EDD_LEAD"  ,4)},;
              {"EDD_INAT_I","C",AVSX3("EDD_INAT_I",3),0},;
              {"EDD_INAT_E","C",AVSX3("EDD_INAT_E",3),0},;
              {"EDD_PGI_NU","C",AVSX3("EDD_PGI_NU",3),0},;
              {"EDD_QTDCP" ,"N",AVSX3("EDD_QTD"   ,3),AVSX3("EDD_QTD"   ,4)},;
              {"EDD_NECESS","N",AVSX3("EDD_QTD"   ,3),AVSX3("EDD_QTD"   ,4)},;
              {"EDD_UNID"  ,AvSx3("EE9_UNIDAD", AV_TIPO),AVSX3("EE9_UNIDAD",3),AVSX3("EE9_UNIDAD",4)},;
              {"EDD_REC"   ,"N",10,0}}

   //AOM - 31/08/2011
   AAdd( aSX3Ant, {"EDD_ITFAT", AVSX3("EDD_QTD",AV_TIPO), AVSX3("EDD_QTD",AV_TAMANHO), AVSX3("EDD_QTD",AV_DECIMAL)} )
   If EDD->(FIELDPOS("EDD_SEQEMB")) > 0
      AAdd( aSX3Ant, {"EDD_SEQEMB", AVSX3("EDD_SEQEMB",AV_TIPO), AVSX3("EDD_SEQEMB",AV_TAMANHO), AVSX3("EDD_SEQEMB",AV_DECIMAL)} )
   EndIf

   //AOM - 25/06/2012
   If lTpOcor
      AAdd( aSX3Ant, {"EDD_CODOCO", AVSX3("EDD_CODOCO",AV_TIPO), AVSX3("EDD_CODOCO",AV_TAMANHO), AVSX3("EDD_CODOCO",AV_DECIMAL)} )
      AAdd( aSX3Ant, {"EDD_DESTIN", AVSX3("EDD_DESTIN",AV_TIPO), AVSX3("EDD_DESTIN",AV_TAMANHO), AVSX3("EDD_DESTIN",AV_DECIMAL)} )
   EndIf


   // ** PLB 21/06/07 - Inclui campos referente tratamento Multi-Filial do Drawback
   If lMFilEDC
      AAdd( aSX3Ant, {"EDD_FILEXP", AVSX3("EDD_FILEXP",AV_TIPO), AVSX3("EDD_FILEXP",AV_TAMANHO), AVSX3("EDD_FILEXP",AV_DECIMAL)} )
      AAdd( aSX3Ant, {"EDD_FILIMP", AVSX3("EDD_FILIMP",AV_TIPO), AVSX3("EDD_FILIMP",AV_TAMANHO), AVSX3("EDD_FILIMP",AV_DECIMAL)} )
   EndIf

   IF AvFlags("SEQMI")  // GFP - 10/11/2011
      AADD(aSX3Ant,{"EDD_SEQMI", AVSX3("EDD_SEQMI",AV_TIPO), AVSX3("EDD_SEQMI",AV_TAMANHO), AVSX3("EDD_SEQMI",AV_DECIMAL)})
   ENDIF

   // **
   If EasyEntryPoint("EECAE101")
      ExecBlock("EECAE101",.F.,.F.,"ALT_SX3ANT")
   EndIf

   FWorkAnt2 :=E_Create(,.F.)
   FWorkAnt3 :=E_Create(,.F.)
   FWorkAnt4 :=E_Create(,.F.)
   fWorkAnt5 :=E_Create(,.F.)
   
   FWorkAnt := E_CriaTrab(, aSX3Ant, "WorkAnt")

   //AOM - 26/08/2011
   IndRegua("WorkAnt",FWorkAnt+TEOrdBagExt()  ,("EDD_AC+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_SEQEMB"+iiF(lTpOcor,"+EDD_CODOCO","")))//AOM - 26/06/2012
   IndRegua("WorkAnt",FWorkAnt2+TEOrdBagExt() ,"EDD_AC+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_ITEM+DTOS(EDD_DTREG)")
   IndRegua("WorkAnt",FWorkAnt3+TEOrdBagExt() ,"EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN")
   IndRegua("WorkAnt",FWorkAnt4+TEOrdBagExt() ,"EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQMI+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN")
   IndRegua("WorkAnt",FWorkAnt5+TEOrdBagExt() ,"EDD_AC+EDD_ITEM")

   SET INDEX TO (FWorkAnt+TEOrdBagExt()),(FWorkAnt2+TEOrdBagExt()),(FWorkAnt3+TEOrdBagExt()),(FWorkAnt4+TEOrdBagExt()),(FWorkAnt5+TEOrdBagExt())

EndIf

EDD->(dbSetOrder(1))
ED1->(dbSetOrder(1))
If !ED1->(dbSeek(cFilED1+ED0->ED0_PD+AvKey(cProd,"ED1_PROD"))) .AND. AllTRim(cProd) == AllTrim(WorkIp->EE9_COD_I)
   cItem := IG400BuscaItem("E", cProd, ED0->ED0_PD)
   /*RRC - 02/01/2013 - Essa alteração permite encontrar os itens a importar da estrutura formada por um Ato Concessório em que o produto a exportar
   não tenha sido informado, pois o conteúdo vazio é necessário nas buscas que comprovam anterioridade.*/
   If !Empty(ED3->ED3_PROD) .And. AvCompEstr(cItem, WorkIp->EE9_COD_I, ED3->ED3_PD, .F., .T., , .T.)
      cProd := cItem
   ElseIf Empty(ED3->ED3_PROD)
      cProd := ""
   EndIf
   ED1->(dbSeek(cFilED1+ED0->ED0_PD+AvKey(cProd,"ED1_PROD")))
EndIf

If EasyEntryPoint("EECAE101")
   ExecBlock("EECAE101",.F.,.F.,{"GRVWKANT_PROD",cProd})
EndIf
Do While !ED1->(EOF()) .and. ED1->ED1_AC == cAto .and. AllTrim(ED1->ED1_PROD) == AllTrim(cProd)
   nTotED1 += ED1->ED1_QTD
   ED1->(dbSkip())
EndDo

SB1->(dbSetOrder(1))
ED0->(dbSetOrder(2))
ED2->(dbSetOrder(2))

//DFS - 17/10/12 - Separado o seek do produto. Para o correto funcionamento da integração com EDC
SB1->(dbSeek(xFilial("SB1")+AvKey(cProd,"ED1_PROD")))

If ED2->(dbSeek(cFilED2+ED0->ED0_PD+AvKey(cProd,"ED2_PROD")))

   WorkEDG->(DbSetOrder(1))
   If WorkEDG->(DbSeek(WorkIP->EE9_SEQEMB))
      While !WorkEDG->(Eof()) .and. WorkEDG->EDG_SEQEMB == WorkIP->EE9_SEQEMB
         If WorkEDG->EDG_RECNO <> 0
            aAdd(aDelEDG, WorkEDG->EDG_RECNO)
         Endif
         WorkEDG->(Reclock("WorkEDG",.F.))
         WorkEDG->EDG_FLAG := .F.
         //RMD - Como ele adiciona do aDelEDG, limpa o Recno
         WorkEDG->EDG_RECNO := 0
         WorkEDG->(MsUnlock())
         WorkEDG->(DbSkip())
      EndDo
   EndIf

   If lLeadTime
      IF EYJ->(FieldPos("EYJ_LEADTI")) > 0  //LRS - 11/02/2014 - Validação para o lead time dentro da tabela EYJ
         If EYJ->EYJ_LEADTI > 0 .and. EYJ->EYJ_PRODUC > 0
            nLeadTime := Int((nQtdComp * EYJ->EYJ_LEADTI)/EYJ->EYJ_PRODUC)
         ElseIf EYJ->EYJ_LEADTI > 0 .and. EYJ->EYJ_PRODUC = 0
            nLeadTime := Int((nQtdComp * EYJ->EYJ_LEADTI)/nQtdComp)
         EndIf
      Else
         If SB1->B1_LEADTI > 0 .and. SB1->B1_PRODUC > 0
            nLeadTime := Int((nQtdComp * SB1->B1_LEADTI)/SB1->B1_PRODUC)
         ElseIf SB1->B1_LEADTI > 0 .and. SB1->B1_PRODUC = 0   //TRP - 05/04/2010
            nLeadTime := Int((nQtdComp * SB1->B1_LEADTI)/nQtdComp)
         EndIf
      EndIf
   EndIF

   dDataLimite := dDtEmba - nLeadTime

   nI := 0
   Do While !ED2->(EOF()) .and. ED2->ED2_FILIAL==cFilED2 .and. ED2->ED2_PD==ED0->ED0_PD .and.;
   AllTrim(ED2->ED2_PROD)==AllTrim(cProd)
      aAltern := IG400AllItens("I",ED2->ED2_ITEM,,.T.)  // GFP - 22/07/2014
      nI := 0
      //RMD - 16/04/14
      lLoopED2 := .F.
      If EasyEntryPoint("EECAE101")
         ExecBlock("EECAE101",.F.,.F.,"LOOP_ED2")
      EndIf
      If lLoopED2
         ED2->(DbSkip())
         Loop
      EndIf

      If ED2->ED2_MARCA == "1"
         nI++
         //AAF 14/07/05 - Utilizar Quantidade Calculada para baixa de saldo.
         nQtdCal := Round(ED2->ED2_QTD * ((100 - Max(ED2->(ED2_PERCPE - ED2_PERCAP),0)) / 100 ),AvSx3("ED2_QTD",4))

		 //RMD - 16/04/14
         If EasyEntryPoint("EECAE101")
            ExecBlock("EECAE101",.F.,.F.,"ALTERA_QTDE_CALCULADA_ED2")
         EndIf

         aControle := If(Len(aAltern) # 0 .AND. Len(aControleAlt) # 0, aControleAlt, aControle)  // GFP - 19/08/2014

         If (nPos:=aScan(aControle,{|x| AllTrim(x[2])==AllTrim(ED2->ED2_ITEM)})) = 0
            aAdd(aControle,{cProd,ED2->ED2_ITEM,nQtdCal/nTotED1,.T.,(nQtdCal/nTotED1) * nQtdComp})//ED2->ED2_QTD

            If Len(aControleAlt) # 0 .And. !Empty(aControle[nI][5]) .And. Empty(aControleAlt[nI][5]) //LGS-12/09/2014
               aControleAlt[nI][5] := aControle[nI][5]
            EndIf

            WorkAnt->(dbSetOrder(5)) //EDD_AC + EDD_ITEM
            If !WorkAnt->(dbSeek(cAto + AvKey(ED2->ED2_ITEM,"EDD_ITEM"))) //.Or. !WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+ IF( lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+AvKey(ED2->ED2_ITEM,"EDD_ITEM")))//AOM - 22/11/2011

               dbSelectArea("WorkAnt")
               WorkAnt->(dbSetOrder(2))
               /* O sistema estava descartando  uso do produto principal, priorizando sempre o item alternativo.
               cItem := If(Len(aAltern) # 0,AvKey(aAltern[nI][1],"ED2_ITEM"),ED2->ED2_ITEM)  // GFP - 22/07/2014 */
               cItem:= ED2->ED2_ITEM
               lEDD := EDD->(dbSeek(cFilEDD+cAto+Space(Len(EDD->EDD_PREEMB))+ IF( lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+AvKey(cItem,"EDD_ITEM")))

               If !lEDD
                  For w := 1 To Len(aAltern)            // GFP - 29/07/2014
                     cItem := aAltern[w][1]
                     If EDD->(dbSeek(cFilEDD+cAto+Space(Len(EDD->EDD_PREEMB))+ IF( lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+AvKey(cItem,"EDD_ITEM")))
                        lEDD := .T.
                        Exit
                     EndIf
                  Next w
               EndIf

               If !lEDD .or.;//AOM - 22/11/2011
               EDD->EDD_DTREG > dDataLimite

                     If lExibeInsumo
                        If ED2->ED2_CAMB == "2" //Sem Cobertura  //EDD->(Eof()) .And.  // SVG - 01/07/2010 -
                           If WorkEDG->(DbSeek(WorkIp->EE9_SEQEMB+AvKey(cItem,"EDG_ITEM")))
                              WorkEDG->EDG_FLAG:= .T.
                           Else
                              WorkEDG->(RecLock("WorkEDG",.T.))
                              WorkEDG->EDG_SEQEMB:= WorkIp->EE9_SEQEMB
                              WorkEDG->EDG_ITEM := cItem
                              WorkEDG->EDG_NCM  := ED2->ED2_NCM
                              WorkEDG->EDG_UNID := ED2->ED2_UMITEM
                              WorkEDG->EDG_QTD  := aControle[Len(aControle)][5]
                              If ED4->(DbSeek(xFilial("ED4")+ED2->ED2_PD+ED2->ED2_NCM+cItem))
                                 WorkEDG->EDG_PRCUNI:= (ED4->ED4_VALCAL/ED4->ED4_QTDCAL)
                              Endif
                              WorkEDG->EDG_VALEMB:= (WorkEDG->EDG_QTD * WorkEDG->EDG_PRCUNI)
                              WorkEDG->EDG_FLAG:= .T.
                              WorkEDG->EDG_RECNO:= 0
                              WorkEDG->(msUnlock())
                           Endif
                           nVlSCob+= WorkEDG->EDG_VALEMB    //Acumula os valores dos insumos utilizados no produto a exportar.
                        Endif
                     EndIf

                     aControle[Len(aControle),4] := .F.
                     Do While !EDD->(EOF()) .and. EDD->EDD_FILIAL==cFilEDD .and. EDD->EDD_AC==cAto .and.;
                     Empty(EDD->EDD_PREEMB) .and. Empty(EDD->EDD_PEDIDO) .and. AllTrim(EDD->EDD_ITEM) == AllTrim(cItem); //AOM - 22/11/2011
                     .And. (!lTpOCor .Or. Empty(EDD->EDD_CODOCO) )//AOM - 26/06/2012

                        WorkAnt->(DBAPPEND())
                        FOR i := 1 TO FCount()
                           cCampo := FIELDNAME(i)
                           If EDD->(FieldPos(cCampo)) # 0
                              WorkAnt->&(cCampo) := EDD->&(cCampo)
                           EndIf
                        NEXT i
                        //AOM - 31/08/2010
                        WorkAnt->EDD_ITFAT := nQtdCal/nTotED1
                        WorkAnt->EDD_REC := EDD->(RecNo())
                        //AOM - 26/06/2012
                        If lTpOcor
                           WorkAnt->EDD_DESTIN := "EASY EXPORT CONTROL"
                        EndIf

                        EDD->(dbSkip())
                     EndDo

               Else
                  Do While !EDD->(EOF()) .and. EDD->EDD_FILIAL==cFilEDD .and. EDD->EDD_AC==cAto .and.;
                  Empty(EDD->EDD_PREEMB) .and. Empty(EDD->EDD_PEDIDO) .and. AllTrim(EDD->EDD_ITEM) == AllTrim(cItem) .And.; //AOM - 22/11/2011
                  (!lTpOcor .Or. Empty(EDD->EDD_CODOCO) )//AOM - 26/06/2012

                     /* Se tiver em uso o controle por item alternativo, há o risco do insumo estar no ato concessório como principal e ser referenciado por outro insumo, no mesmo ato,
                     como alternativo. Para não correr o risco de baixar o mesmo insumo em duplicidade, será verificado se sua inclusão foi realizada na work de anterioridade.
                     Estando na work de anterioridade, será considerado apenas uma vez para efeito de baixa no ato concessório. */
                     If !WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+IF( lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+cItem))
                        WorkAnt->(DBAPPEND())
                        FOR i := 1 TO FCount()
                           cCampo := FIELDNAME(i)
                           If EDD->(FieldPos(cCampo)) # 0
                              WorkAnt->&(cCampo) := EDD->&(cCampo)
                           EndIf
                        NEXT i
                        //AOM - 31/08/2010
                        WorkAnt->EDD_ITFAT := nQtdCal/nTotED1
                        WorkAnt->EDD_REC := EDD->(RecNo())
                        //AOM - 26/06/2012
                        If lTpOcor
                           WorkAnt->EDD_DESTIN := "EASY EXPORT CONTROL"
                        EndIf
                     Else
                        aControle[Len(aControle),4]:=  .F.
                     EndIf
                     EDD->(dbSkip())
                  EndDo
               EndIf
            EndIf
         Else
            //AAF 14/07/05 - Utilizar Quantidade Calculada para baixa de saldo.
            aControle[nPos,3] += nQtdCal/nTotED1 //ED2->ED2_QTD/nTotED1
            aControle[nPos,5] += (nQtdCal/nTotED1) * nQtdComp//(ED2->ED2_QTD/nTotED1) * nQtdComp

            If ED2->ED2_CAMB == "2" //Sem Cobertura

               If WorkEDG->(DbSeek(WorkIp->EE9_SEQEMB+AvKey(ED2->ED2_ITEM,"EDG_ITEM"))) .AND. WorkEDG->EDG_FLAG
                  WorkEDG->(RecLock("WorkEDG",.F.))
                  WorkEDG->EDG_SEQEMB:= WorkIp->EE9_SEQEMB
                  WorkEDG->EDG_ITEM := ED2->ED2_ITEM
                  WorkEDG->EDG_NCM  := ED2->ED2_NCM
                  WorkEDG->EDG_UNID := ED2->ED2_UMITEM
                  WorkEDG->EDG_QTD  := aControle[nPos][5]
                  If ED4->(DbSeek(xFilial("ED4")+ED2->ED2_PD+ED2->ED2_NCM+AvKey(ED2->ED2_ITEM,"ED4_ITEM")))
                     WorkEDG->EDG_PRCUNI:= (ED4->ED4_VALCAL/ED4->ED4_QTDCAL)
                  Endif
                  WorkEDG->EDG_VALEMB:= (WorkEDG->EDG_QTD * WorkEDG->EDG_PRCUNI)
                  WorkEDG->EDG_FLAG:= .T.
                  WorkEDG->EDG_RECNO:= 0
                  WorkEDG->(msUnlock())

                  nVlSCob+= WorkEDG->EDG_VALEMB    //Acumula os valores dos insumos utilizados no produto a exportar.
               Endif

            Endif

         EndIf
      EndIf
      ED2->(dbSkip())
   EndDo

   WorkAnt->(dbSetOrder(1))
   If !WorkAnt->(dbSeek(cAto+M->EEC_PREEMB+cPedido+cSequen+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,cSeqEmb,"")))//AOM - 26/08/2011

      WorkAnt->(dbSetOrder(2))
      For ni:=1 to Len(aControle)
         lMaior  := .F.
         nQtdAux := aControle[ni,5]
         aAltern := IG400AllItens("I",aControle[ni,2],,.T.)  // GFP - 22/07/2014
         /* O sistema estava descartando  uso do produto principal, priorizando sempre o item alternativo.
         cItem := If(Len(aAltern) <> 0,aAltern[1][1],aControle[ni,2])  // GFP - 22/07/2014*/
         cItem:= aControle[ni,2]
         lEDD := WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+IF( lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+cItem))
         If !lEDD
            For w := 1 To Len(aAltern)            // GFP - 29/07/2014
               cItem := aAltern[w][1]
               If WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+IF( lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+cItem))
                  lEDD := .T.
                  Exit
               EndIf
            Next w
         EndIf
         If !lEDD .or.;
         (WorkAnt->EDD_DTREG > dDataLimite .And. (!lTpOCor .Or. Empty(WorkAnt->EDD_CODOCO) )) //AOM 27/06/12

               //Adiciona o no array aItNegativo para apresentar a mensagem de apropriação- AOM - 26/06/201
               If (nPos:=aScan(aItNegativo,{|x| Alltrim(x[2])==Alltrim(cItem)})) == 0
                  AADD(aItNegativo,{AllTrim(cSequen),Alltrim(cProd),Alltrim(cItem),Alltrim(cAto),DToC(dDataLimite) })
               EndIf
               cWkSeqMI := WorkAnt->EDD_SEQMI //NCF - 04/05/2018

               WorkAnt->(DBAPPEND())
               WorkAnt->EDD_AC     := cAto
               WorkAnt->EDD_PD     := ED0->ED0_PD
               WorkAnt->EDD_ITEM   := cItem
               WorkAnt->EDD_PREEMB := M->EEC_PREEMB
               WorkAnt->EDD_PEDIDO := cPedido
               WorkAnt->EDD_SEQUEN := cSequen
               WorkAnt->EDD_QTD    := aControle[ni,5] * -1
               WorkAnt->EDD_DTRE   := dDtEmba
               WorkAnt->EDD_QTD_EX := nQtdComp
               WorkAnt->EDD_LEAD   := nLeadTime
               WorkAnt->EDD_PROD   := cProd
               WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
               // ** PLB 21/06/07
               If lMFilEDC
                  WorkAnt->EDD_FILEXP := cFilAnt
               EndIf
               //AOM - 31/08/2011
               WorkAnt->EDD_ITFAT := aControle[ni,3]
               If EDD->(FIELDPOS("EDD_SEQEMB")) > 0
                  WorkAnt->EDD_SEQEMB := cSeqEmb
               EndIF
               //AOM - 26/06/2012
               If lTpOcor
                  WorkAnt->EDD_DESTIN := "EASY EXPORT CONTROL"
               EndIf
               
               WorkAnt->EDD_SEQMI := cWkSeqMI

         Else
            Do While !WorkAnt->(EOF()) .and. WorkAnt->EDD_AC==cAto .and. Empty(WorkAnt->EDD_PREEMB) .and. Empty(WorkAnt->EDD_PEDIDO) .and.;
            WorkAnt->EDD_ITEM==cItem .and. WorkAnt->EDD_DTREG <= dDataLimite .and.;
            aControle[ni,5] > 0  .And. (!lTpOCor .Or. Empty(WorkAnt->EDD_CODOCO) ) //AOM 27/06/12
               If aControle[ni,5] < WorkAnt->EDD_QTD
                  aArrayAux := {}
                  nRecAux:=WorkAnt->(RecNo())
                  For nInd:=1 to WorkAnt->(FCount())
                     aAdd(aArrayAux,WorkAnt->(FieldGet(nInd)))
                  Next nInd

                  //WorkAnt->(RecLock("WorkAnt",.T.))   //Registro utilizado de acordo com anterioridade
                  WorkAnt->(DBAPPEND())
                  For nInd:=1 to Len(aArrayAux)
                     WorkAnt->&(FIELDNAME(nInd)) := aArrayAux[nInd]
                  Next nInd
                  WorkAnt->EDD_PREEMB := M->EEC_PREEMB
                  WorkAnt->EDD_PEDIDO := cPedido
                  WorkAnt->EDD_SEQUEN := cSequen
                  WorkAnt->EDD_QTD    := aControle[ni,5]
                  WorkAnt->EDD_DTRE   := dDtEmba
                  WorkAnt->EDD_QTD_EX := nQtdComp
                  //WorkAnt->EDD_LEAD   := If(lLeadTime .AND. SB1->B1_LEADTI > 0,SB1->B1_LEADTI,nLeadTime)
                  WorkAnt->EDD_LEAD   := nLeadTime
                  WorkAnt->EDD_PROD   := cProd
                  WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
                  WorkAnt->EDD_REC    := 0
                  // ** PLB 21/06/07
                  If lMFilEDC
                     WorkAnt->EDD_FILEXP := cFilAnt
                  EndIf
                  //AOM - 31/08/2011
                  WorkAnt->EDD_ITFAT := aControle[ni,3]
                  If EDD->(FIELDPOS("EDD_SEQEMB")) > 0
                     WorkAnt->EDD_SEQEMB := cSeqEmb
                  EndIF

                  //AOM - 26/06/2012
                  If lTpOcor
                     WorkAnt->EDD_DESTIN := "EASY EXPORT CONTROL"
                  EndIf
                  // **

                  //AAF 23/06/05 - Quantidade a comprovar com os outros registros.
                  nQtdAux -= aControle[ni,5]

                  WorkAnt->(dbGoTo(nRecAux))   //Registro com saldo não utilizado
                  WorkAnt->EDD_QTD    := WorkAnt->EDD_QTD - aControle[ni,5]

                  aControle[ni,5] := 0
               Else
                  aControle[ni,5] -= WorkAnt->EDD_QTD
                  lMaior := .T.
               EndIf

               //Adiciona o no array aItPositivo para apresentar a mensagem de apropriação no final - AOM - 26/06/2011
               If (nPos:=aScan(aItPositivo,{|x| Alltrim(x[3])==(cItem)})) == 0
                  AADD(aItPositivo,{AllTrim(cSequen),Alltrim(cProd),Alltrim(cItem),Alltrim(cAto),DToC(dDataLimite) })
               EndIf

               WorkAnt->(dbSkip())
            EndDo
            If aControle[ni,5] > 0

                  //Adiciona o no array aItNegativo para apresentar a mensagem de apropriação- AOM - 26/06/201
                  If (nPos:=aScan(aItNegativo,{|x| Alltrim(x[2])==Alltrim(cItem)})) == 0
                     AADD(aItNegativo,{AllTrim(cSequen),Alltrim(cProd),Alltrim(cItem),Alltrim(cAto),DToC(dDataLimite) })
                  EndIf

                  WorkAnt->(DBAPPEND())
                  WorkAnt->EDD_AC     := cAto
                  WorkAnt->EDD_PD     := ED0->ED0_PD
                  WorkAnt->EDD_ITEM   := cItem
                  WorkAnt->EDD_PREEMB := M->EEC_PREEMB
                  WorkAnt->EDD_PEDIDO := cPedido
                  WorkAnt->EDD_SEQUEN := cSequen
                  WorkAnt->EDD_QTD    := aControle[ni,5] * -1
                  WorkAnt->EDD_DTRE   := dDtEmba
                  WorkAnt->EDD_QTD_EX := nQtdComp
                  WorkAnt->EDD_LEAD   := nLeadTime
                  WorkAnt->EDD_PROD   := cProd
                  WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
                  // ** PLB 21/06/07
                  If lMFilEDC
                     WorkAnt->EDD_FILEXP := cFilAnt
                  EndIf
                  //AOM - 31/08/2011
                  WorkAnt->EDD_ITFAT := aControle[ni,3]
                  If EDD->(FIELDPOS("EDD_SEQEMB")) > 0
                     WorkAnt->EDD_SEQEMB := cSeqEmb
                  EndIF

                  //AOM - 26/06/2012
                  If lTpOcor
                     WorkAnt->EDD_DESTIN := "EASY EXPORT CONTROL"
                  EndIf

                  // **

                  //AOM - 22/11/2011
                  WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+IF(lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+cItem))
                  Do While !WorkAnt->(EOF()) .and. WorkAnt->EDD_AC==cAto .and. Empty(WorkAnt->EDD_PREEMB) .and. Empty(WorkAnt->EDD_PEDIDO) .and.;
                  WorkAnt->EDD_ITEM==cItem .and. WorkAnt->EDD_DTREG <= dDataLimite .and.;
                  nQtdAux > 0 .And. (!lTpOCor .Or. Empty(WorkAnt->EDD_CODOCO) ) //AOM 27/06/12
                     WorkAnt->EDD_PREEMB := M->EEC_PREEMB
                     WorkAnt->EDD_PEDIDO := cPedido
                     WorkAnt->EDD_SEQUEN := cSequen
                     WorkAnt->EDD_DTRE   := dDtEmba
                     WorkAnt->EDD_QTD_EX := nQtdComp
                     WorkAnt->EDD_LEAD   := nLeadTime
                     WorkAnt->EDD_PROD   := cProd
                     WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
                     // ** PLB 21/06/07
                     If lMFilEDC
                        WorkAnt->EDD_FILEXP := cFilAnt
                     EndIf
                     //AOM - 31/08/2011
                     WorkAnt->EDD_ITFAT := aControle[ni,3]
                     If EDD->(FIELDPOS("EDD_SEQEMB")) > 0
                        WorkAnt->EDD_SEQEMB := cSeqEmb
                     EndIF

                     //AOM - 26/06/2012
                     If lTpOcor
                        WorkAnt->EDD_DESTIN := "EASY EXPORT CONTROL"
                     EndIf

                     // **
                     nQtdAux -= WorkAnt->EDD_QTD
                     //AAF 20/06/05 - Procurar pois o registro atual foi desposicionado, devido a alteração em campos chave.
                     WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+IF( lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+cItem))//WorkAnt->(dbSkip())//AOM - 22/11/2011
                  EndDo

            ElseIf lMaior

               //Adiciona o no array aItPositivo para apresentar a mensagem de apropriação no final - AOM  - 26/06/2011
               If (nPos:=aScan(aItPositivo,{|x| Alltrim(x[3])==Alltrim(cItem)})) == 0
                  AADD(aItPositivo,{AllTrim(cSequen),Alltrim(cProd),Alltrim(cItem),Alltrim(cAto),DToC(dDataLimite) })
               EndIf

               //AOM - 22/11/2011
               WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+IF(lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+cItem))
               Do While !WorkAnt->(EOF()) .and. WorkAnt->EDD_AC==cAto .and. Empty(WorkAnt->EDD_PREEMB) .and. Empty(WorkAnt->EDD_PEDIDO) .and.;
               WorkAnt->EDD_ITEM==cItem .and. WorkAnt->EDD_DTREG <= dDataLimite .and.;
               nQtdAux > 0  .And. (!lTpOCor .Or. Empty(WorkAnt->EDD_CODOCO) ) //AOM 27/06/12
                  WorkAnt->EDD_PREEMB := M->EEC_PREEMB
                  WorkAnt->EDD_PEDIDO := cPedido
                  WorkAnt->EDD_SEQUEN := cSequen
                  WorkAnt->EDD_DTRE   := dDtEmba
                  WorkAnt->EDD_QTD_EX := nQtdComp
                  WorkAnt->EDD_LEAD   := nLeadTime
                  WorkAnt->EDD_PROD   := cProd
                  WorkAnt->EDD_SEQSIE := ED3->ED3_SEQSIS
                  // ** PLB 21/06/07
                  If lMFilEDC
                     WorkAnt->EDD_FILEXP := cFilAnt
                  EndIf
                  //AOM - 31/08/2011
                  WorkAnt->EDD_ITFAT := aControle[ni,3]
                  If EDD->(FIELDPOS("EDD_SEQEMB")) > 0
                     WorkAnt->EDD_SEQEMB := cSeqEmb
                  EndIF

                  //AOM - 26/06/2012
                  If lTpOcor
                     WorkAnt->EDD_DESTIN := "EASY EXPORT CONTROL"
                  EndIf

                  // **
                  nQtdAux -= WorkAnt->EDD_QTD
                  //AAF 20/06/05 - Procurar pois o registro atual foi desposicionado, devido a alteração em campos chave.
                  WorkAnt->(dbSeek(cAto+Space(Len(EDD->EDD_PREEMB))+IF( lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"")+cItem))//WorkAnt->(dbSkip())//AOM - 22/11/2011
               EndDo
            EndIf
         EndIf
      Next ni
   EndIf
   
   // GFP - 19/08/2014
   aControleAlt := aClone(aControle)

   If ED2->(dbSeek(cFilED2+ED0->ED0_PD+AvKey(cProd,"ED2_PROD")))
      Do While !ED2->(EOF()) .and. ED2->ED2_FILIAL==cFilED2 .and. ED2->ED2_PD==ED0->ED0_PD .and.;
         AllTrim(ED2->ED2_PROD)==AllTrim(cProd)
            WorkAnt->(dbSetOrder(2))
            If WorkAnt->(dbSeek(cAto+M->EEC_PREEMB+IF( lIndexPed,WorkIP->EE9_PEDIDO+WorkIP->EE9_SEQUEN,"")+AvKey(ED2->ED2_ITEM,"EDD_ITEM")))
               Do While WorkAnt->(!EOF() .And. AllTrim(EDD_ITEM) == AllTrim(ED2->ED2_ITEM))
                  If WorkAnt->EDD_AC==cAto .and.  AllTrim(WorkAnt->EDD_ITEM)==AllTrim(ED2->ED2_ITEM) .and.;
                     WorkAnt->EDD_PEDIDO == WorkIP->EE9_PEDIDO .and. WorkAnt->EDD_SEQUEN == WorkIP->EE9_SEQUEN

                     SW9->(DbSetOrder(1))
                     SY6->(DbSetOrder(1))
                     ED4->(DbSetOrder(1))
                     IF AvFlags("SEQMI") .AND. Empty(WorkAnt->EDD_HAWB)
                        ED8->(DbSetOrder(8))
                     Else
                        ED8->(DbSetOrder(3))
                     EndIf
                     If SW9->(DbSeek(xFilial("SW9")+WorkAnt->EDD_INVOIC))
                        IF SY6->(DBSEEK(xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3) )) .AND. ;
                           SY6->Y6_TIPOCOB == "4" //Somente se não tiver cob. cambial

                           If WorkEDG->(DbSeek(WorkIp->EE9_SEQEMB+WorkAnt->EDD_ITEM))
                              WorkEDG->EDG_FLAG:= .T.
                           Else

                              WorkEDG->(RecLock("WorkEDG",.T.))
                              WorkEDG->EDG_SEQEMB:= WorkIp->EE9_SEQEMB
                              WorkEDG->EDG_ITEM := WorkAnt->EDD_ITEM
                              WorkEDG->EDG_NCM  := ED2->ED2_NCM
                              WorkEDG->EDG_UNID := ED2->ED2_UMITEM
                              WorkEDG->EDG_QTD  := WorkAnt->EDD_QTD
                              If ED4->(DbSeek(xFilial("ED4")+ED2->ED2_PD+ED2->ED2_NCM+AvKey(ED2->ED2_ITEM,"ED4_ITEM")))
                                 WorkEDG->EDG_PRCUNI:= (ED4->ED4_VALCAL/ED4->ED4_QTDCAL)
                              Endif
                              WorkEDG->EDG_VALEMB:= (WorkEDG->EDG_QTD * WorkEDG->EDG_PRCUNI)
                              WorkEDG->EDG_FLAG:= .T.
                              WorkEDG->EDG_RECNO:= 0

                              WorkEDG->(msUnlock())
                           Endif

                           nVlSCob+= WorkEDG->EDG_VALEMB    //Acumula os valores dos insumos utilizados no produto a exportar.

                        Endif
                     //ISS - 10/03/11 - Validação para gravar os insumos que vierem de DI's externas
                     ElseIf ED8->(DbSeek(xFilial("ED8")+WorkAnt->EDD_AC+IF(AvFlags("SEQMI") .AND. Empty(WorkAnt->EDD_HAWB),WorkAnt->EDD_SEQMI,WorkAnt->EDD_SEQSII)))
                        If ED8->(FieldPos("ED8->ED8_CAMB")) > 0  .And. ED8->ED8_CAMB == "2" //Somente se não tiver cobertura cambial

                           If WorkEDG->(DbSeek(WorkIp->EE9_SEQEMB+WorkAnt->EDD_ITEM))
                              WorkEDG->EDG_FLAG:= .T.
                           Else

                              WorkEDG->(RecLock("WorkEDG",.T.))
                              WorkEDG->EDG_SEQEMB:= WorkIp->EE9_SEQEMB
                              WorkEDG->EDG_ITEM := WorkAnt->EDD_ITEM
                              WorkEDG->EDG_NCM  := ED2->ED2_NCM
                              WorkEDG->EDG_UNID := ED2->ED2_UMITEM
                              WorkEDG->EDG_QTD  := WorkAnt->EDD_QTD
                              If ED4->(DbSeek(xFilial("ED4")+ED2->ED2_PD+ED2->ED2_NCM+AvKey(ED2->ED2_ITEM,"ED4_ITEM")))
                                 WorkEDG->EDG_PRCUNI:= (ED4->ED4_VALCAL/ED4->ED4_QTDCAL)
                              Endif
                              WorkEDG->EDG_VALEMB:= (WorkEDG->EDG_QTD * WorkEDG->EDG_PRCUNI)
                              WorkEDG->EDG_FLAG:= .T.
                              WorkEDG->EDG_RECNO:= 0

                              WorkEDG->(msUnlock())
                           Endif

                           nVlSCob+= WorkEDG->EDG_VALEMB    //Acumula os valores dos insumos utilizados no produto a exportar.

                        EndIf
                     Endif
                  EndIf
                  WorkAnt->(DbSkip())
               Enddo
            Endif

         ED2->(DbSkip())
      Enddo
   Endif

   If Type("M->EE9_VLSCOB") <> "U"
      M->EE9_VLSCOB:= nVlSCob
   Else
      WorkIP->EE9_VLSCOB:= nVlSCob
   Endif
   nVlSCob:= 0
   WorkEDG->(DbGotop())

//DFS - 17/10/12 - Inclusão de tratamento para que, caso o usuário clique em Sim, sistema faça a vinculação do ato concessório no item do embarque, mesmo sem estrutura.
Else
   If(EasyEntryPoint("EECAE101"),ExecBlock("EECAE101",.F.,.F.,"EXIBE_MENSAGEM"),)   // GFP - 19/12/2012

   If lExibeMsg   // GFP - 19/12/2012
      lRet := MsgYesNo("Não foi encontrada estrutura do produto " + Alltrim(cProd) + " no Ato Concessório " + Alltrim(cAto) +". Deseja vincular o produto ao Ato Concessório mesmo assim?")
   EndIf
   Break
EndIf

   If Type("nOpcApSld") == "U"
      _SetOwnerPrvt("nOpcApSld", EasyGParam("MV_EEC0004",,0))//AOM - 29/08/2011
   EndIf

   If Type("nOpcAprop") == "U"
      _SetOwnerPrvt("nOpcAprop", EasyGParam("MV_EEC0005",,AP_CONF_NAOCOMPROVADOS))//AOM - 29/08/2011
   EndIf

   If lExibeComp .AND. (nOpcAprop == AP_CONF_NAOCOMPROVADOS .Or. nOpcAprop == AP_CONF_TODOS)  // AAF - 23/09/2013
      // ** AAF 19/04/05
      //If Len(aControle) == 0 .AND. ED0->ED0_TIPOAC <> "06" // AAF - 07/02/06 - Não bloqueia Atos Genéricos. //wfs 07/01/13
      If (Len(aControle) == 0 .Or. (nOpcApSld == SLD_INSEXP .And. Len(aItPositivo) == 0)) .AND. ED0->ED0_TIPOAC <> "06" // AAF - 07/02/06 - Não bloqueia Atos Genéricos.
         MsgInfo(STR0062)//"Este Ato Concessório não possui importação para nenhum dos itens."
         lRet := .F.
         Break
     Endif
      // **
   EndIf

   //Se a quantidade a exportar for superior ao saldo do ato, será exibida a tela para a quebra do item.
   //A tela será exibida posteriormente.
   If !lExibeComp .OR. lExistQuebra .And. nOpcAprop <> AP_AUT_COMPROVADOS  // AAF - 23/09/2013
      lRet:= .T.
      Break
   EndIf

   //Mensagens
   If Len(aItPositivo) > 0
      cMsg:= STR0083 + AllTrim(cAto) + STR0084 //O ato concessório ### possui anterioridade comprovada para todos os insumos e está apto a ser utilizado.
   EndIf

   //Quando houver itens a comprovar, a mensagem será referente apenas a estes
   If Len(aItNegativo) > 0
      cMsg:= STR0083 + AllTrim(cAto) + STR0085 + DtoC(dDataLimite) + STR0086 //O ato concessório ### não possui importação que comprove anterioridade à data ### para todos os insumos que compõem a estrutura do item a exportar, conforme segue:
   EndIf


   //Opção de apropriar automático apenas os que tem saldo comprovado
   If !Empty(aItNegativo) .And. nOpcAprop == AP_AUT_COMPROVADOS

      AEDelWkAnt(cAto,cPedido,cSequen,cSeqEmb/*AOM - 26/08/2011*/)
      lRet:= .F.
      Break

   //Opção de exibição de tela de confirmação para os itens sem comprovação ou para todos os itens
   ElseIf lExibeComp .And. ((!Empty(aItNegativo) .And. nOpcAprop == AP_CONF_NAOCOMPROVADOS) .Or. nOpcAprop == AP_CONF_TODOS)
      If !ExibeApropriacao(cAto, cPedido, cSequen, cProd, cMsg, cSeqEmb/*AOM - 26/08/2011*/)
         //LGS-30/01/2014 - Verifica se foi marcado a opção "Sempre exibe tela de confirmação" e limpa os dados da WorkAnt
         //If nOpcAprop != 4
         	AEDelWkAnt(cAto,cPedido,cSequen,cSeqEmb/*AOM - 26/08/2011*/)
         //Else
         	//AvZap("WorkAnt")
         //EndIf
         lRet:= .F.
         Break
      EndIf
	   lMsgExibe:= .F.

   //Opção para apropriar automáticamente, mesmo quando não houver comprovação para todos os itens.
   //Se não há saldo em ao menos um item, o ato concessório não será utilizado
   Else
      If Len(aItPositivo) == 0
         AEDelWkAnt(cAto,cPedido,cSequen,cSeqEmb/*AOM - 26/08/2011*/)
         lRet:= .F.
         Break
      Else
         lRet:= .T.
      EndIf
   EndIf


End Sequence

Return lRet


*----------------------------------------------------------------------------------------------*
Function ACDelAnt(cChave)          //GFC - 18/07/2003 - Drawback Anterioridade
*----------------------------------------------------------------------------------------------*
Local nRecAux, nQtdAux:=0, nOrdEDD:=EDD->(IndexOrd()) //, aArrayAux:={}
Local lIndexPed := "EDD_PEDIDO" $ EDD->(IndexKey(1)) .And. "EDD_PEDIDO" $ EDD->(IndexKey(2))//AOM - 22/11/2011 - Verifica se o idice está atualizado com o campo Pedido
Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade

If Type("lMFilEDC") == "U"
   lMFilEDC  := VerSenha(115)  ;
                .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0  ;
                .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0
EndIf

Default cChave := cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EE9->EE9_COD_I+EE9->EE9_ATOCON+EE9->EE9_SEQED3+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,EE9->EE9_SEQEMB,"")//AOM - 26/08/2011

//Do While EDD->(dbSeek(cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EE9->EE9_COD_I+EE9->EE9_ATOCON+EE9->EE9_SEQED3))
Do While EDD->(dbSeek(cChave))
/*!EDD->(EOF()) .and. EDD->EDD_FILIAL==cFilEDD .and. EDD->EDD_PREEMB==EE9->EE9_PREEMB .and.;
EDD->EDD_PEDIDO==EE9->EE9_PEDIDO .and. EDD->EDD_SEQUEN==EE9->EE9_SEQUEN .and.;
EDD->EDD_PROD==EE9->EE9_COD_I .and. EDD->EDD_AC==EE9->EE9_ATOCON .and. EDD->EDD_SEQSIE==EE9->EE9_SEQED3*/
   If Empty(EDD->EDD_HAWB) .And. Empty(EDD->EDD_PO_NUM)
      EDD->(RecLock("EDD",.F.,.T.))

      //GFP - 10/11/2011
      IF AvFlags("SEQMI") .AND. Empty(EDD->EDD_HAWB)
         ED4->(DbSetOrder(8))  //ED4_FILIAL+ED4_AC+ED4_SEQMI
      ELSE
         //AOM - 29/09/10 -
         ED4->(DbSetOrder(2))  //ED4_FILIAL+ED4_AC+ED4_SEQSIS
      ENDIF
      //GFP - 10/11/2011 - Incluido campo SEQMI no indice

      /* AAF - ESTE TRECHO NAO FAZ SENTIDO POIS SE O EDD_HAWB ESTÁ VAZIO, NÃO HÁ IMPORTAÇÃO ASSOCIADA PARA VOLTAR O SALDO DE INSUMO NO ATO */
      //NCF - 04/05/2018 - Estorno deve ser feito para comprovações com insumos nacionais com comprovação externa feita pela rotina de compras nacionais
      If ED4->(DbSeek(xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + IF(AvFlags("SEQMI") .AND. Empty(EDD->EDD_HAWB),AvKey(EDD->EDD_SEQMI,"ED4_SEQMI"),AvKey(EDD->EDD_SEQSII,"ED4_SEQSIS")))) .And. ED4->ED4_IMPORT == "N"
         If ED4->(RecLock("ED4",.F.))
            If !Empty(EDD->EDD_PREEMB) .Or. !Empty(EDD->EDD_PEDIDO)
               ED4->ED4_SNCMEX += Abs( EDD->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL )
               ED4->ED4_SQTDEX += Abs( EDD->EDD_QTD )
            EndIf
         ED4->(MsUnlock())
         EndIf
      EndIf
      
      EDD->(dbDelete())
      EDD->(MSUnlock())
   Else
      nQtdAux := EDD->EDD_QTD
      nRecAux := EDD->(RecNo())

      //GFP - 10/11/2011
      IF AvFlags("SEQMI") .AND. Empty(EDD->EDD_HAWB) .AND. Empty(EDD->EDD_SEQSII)  // AAF - 23/09/2013
         ED4->(DbSetOrder(8))  //ED4_FILIAL+ED4_AC+ED4_SEQMI
      ELSE
         //AOM - 29/09/10 -
         ED4->(DbSetOrder(2))  //ED4_FILIAL+ED4_AC+ED4_SEQSIS
      ENDIF

      If AvFlags("SEQMI") .AND. !Empty(EDD->EDD_SEQMI) .AND. Empty(EDD->EDD_SEQSII) .OR. !Empty(EDD->EDD_SEQSII)  // AAF - 23/09/2013

         If ED4->(DbSeek(xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + IF(AvFlags("SEQMI") .AND. !Empty(EDD->EDD_SEQMI),AvKey(EDD->EDD_SEQMI,"ED4_SEQMI"),AvKey(EDD->EDD_SEQSII,"ED4_SEQSIS"))))
            If ED4->(RecLock("ED4",.F.))
               If ED4->(FieldPos("ED4_SNCMEX")) > 0  .And. ED4->(FieldPos("ED4_SQTDEX")) > 0 .And. (!Empty(EDD->EDD_PREEMB) .Or. !Empty(EDD->EDD_PEDIDO))
                  ED4->ED4_SNCMEX += EDD->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL
                  ED4->ED4_SQTDEX += EDD->EDD_QTD
               EndIf
               ED4->(MsUnlock())
            EndIf
         EndIf
      EndIf

      //GFP - 10/11/2011
      IF AvFlags("SEQMI") .AND. Empty(EDD->EDD_HAWB)
         EDD->(DbSetOrder(4))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+ EDD_SEQMI+EDD_PREEMB
      ELSE
         //AOM - 29/09/10 -
         EDD->(dbSetOrder(2))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB
      ENDIF


      If EDD->(dbSeek(cFilEDD+EDD->EDD_HAWB+EDD->EDD_INVOIC+EDD->EDD_PO_NUM+EDD->EDD_POSICA+EDD->EDD_PGI_NU+EDD->EDD_AC+IF(AvFlags("SEQMI") .AND. Empty(EDD->EDD_HAWB),EDD->EDD_SEQMI,EDD->EDD_SEQSII)+Space(Len(EDD->EDD_PREEMB))+ IF(lIndexPed,Space(Len(EDD->EDD_PEDIDO))+Space(Len(EDD->EDD_SEQUEN)),"") + If(lTpOcor,AvKey("","EDD_CODOCO"),"") ))//AOM 27/06/2012
         EDD->(RecLock("EDD",.F.))
         EDD->EDD_QTD += nQtdAux

         //AOM - 29/09/10
         /*ED4->(DbSetOrder(2))
         If ED4->(DbSeek(xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + AvKey(EDD->EDD_SEQSII,"ED4_SEQSIS")))
            If ED4->(RecLock("ED4",.F.))
               If ED4->(FieldPos("ED4_SNCMEX")) > 0  .And. ED4->(FieldPos("ED4_SQTDEX")) > 0 .And. !Empty(EDD->EDD_PREEMB)
                  ED4->ED4_SNCMEX -=  ((nQtdAux * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL) - (EDD->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL))
                  ED4->ED4_SQTDEX -=  (nQtdAux - EDD->EDD_QTD)
               EndIf
            ED4->(MsUnlock())
            EndIf
         EndIf*/

         EDD->(msUnlock())

         EDD->(dbSetOrder(nOrdEDD))

         EDD->(dbGoTo(nRecAux))
         EDD->(RecLock("EDD",.F.))

         /* movido para antes do If
         //AOM - 29/09/10 -
         ED4->(DbSetOrder(2))
         If ED4->(DbSeek(xFilial("ED4") + AvKey(EDD->EDD_AC,"ED4_AC") + AvKey(EDD->EDD_SEQSII,"ED4_SEQSIS")))
            If ED4->(RecLock("ED4",.F.))
               If ED4->(FieldPos("ED4_SNCMEX")) > 0  .And. ED4->(FieldPos("ED4_SQTDEX")) > 0 .And. !Empty(EDD->EDD_PREEMB)
                  ED4->ED4_SNCMEX += EDD->EDD_QTD * ED4->ED4_QTDNCM/ED4->ED4_QTDCAL
                  ED4->ED4_SQTDEX += EDD->EDD_QTD
               EndIf
            ED4->(MsUnlock())
            EndIf
         EndIf*/

         EDD->(dbDelete())
         EDD->(MSUnlock())
      Else
         EDD->(dbSetOrder(nOrdEDD))

         EDD->(dbGoTo(nRecAux))
         EDD->(RecLock("EDD",.F.))
         EDD->EDD_PREEMB := ""
         EDD->EDD_PEDIDO := ""
         EDD->EDD_SEQUEN := ""
         //EDD->EDD_QTD    := 0
         EDD->EDD_DTRE   := AvCtoD("  /  /  ")
         EDD->EDD_QTD_EX := 0
         EDD->EDD_LEAD   := 0
         EDD->EDD_PROD   := ""
         EDD->EDD_SEQSIE := ""
         // ** PLB 21/06/07 - Grava Filial de Origem da Exportação caso Drawback seja Multi-Filial
         If lMFilEDC
            EDD->EDD_FILEXP := ""
         EndIf
         EDD->(msUnlock())
      EndIf

   EndIf
   EDD->(dbSkip())
EndDo

Return .T.

/*
Objetivos:   validações para desmarcar um item no embarque.
*/
*--------------------------------------------------------------------------------------------*
Function AEAntVal()       //GFC - 18/07/2003 - Drawback Anterioridade
*--------------------------------------------------------------------------------------------*
/*
AMS - 16/10/2004 às 19:01. Imposto condição, na desmarcação do item, quando o mesmo possuir RE, para
                           informar e solicitar confirmação da eliminação do item no pedido.
*/
Local aFilter := {}

Private lRetVal := .T.

If Type("lConsolida") <> "L"
   lConsolida := .f.
EndIf

Begin Sequence

   //////////////////////////////////////
   //Verifica se o Item já foi Faturado//
   //////////////////////////////////////
   If EECFlags("INTEMB")
      SC6->(DbSetOrder(1))
      If SC6->(DbSeek(xFilial("SC6")+AVKey(M->EEC_PEDFAT,"C6_NUM")+AvKey(WorkIp->EE9_FATIT,"C6_ITEM")))
         If !Empty(SC6->C6_NOTA)
            MsgInfo(STR0070,STR0058)//"O Item não poderá ser desmarcado porque já existe NF gerada no módulo Faturamento (SigaFAT)"###"Atenção"
            lRetVal := .F.
            Break
         EndIf
      EndIf
   EndIf

   If lConsolida
      aFilter := Ae104GrpFilter() // seta filtro, para pegar somente os itens do registro posicionado da WorkGrp
      WorkIp->(DbGoTop())
   EndIf

   While If(lConsolida,WorkIp->(!EoF()),.t.)

      If !Empty(WorkIP->EE9_RE)
         If !MsgYesNo(STR0059 + ENTER +;               //"Este item contem um RE gerado, com a sua eliminação, deverá ser feito o mesmo"
                      STR0060 + Replicate(ENTER, 2) +; //"processo de eliminação do RE no Siscomex."
                      STR0061, STR0058 +;              //"Deseja desmarcar o item com RE?"###"Atenção"
                      If(lConsolida," - " + AllTrim(AvSx3("EE9_SEQEMB",AV_TITULO)) + ": " + AllTrim(WorkIp->EE9_SEQEMB),"") )
            lRetVal := .F.
            Break
         EndIf
      EndIf

      /* Nopado por ER - 04/09/09.
         Apenas os campos relacionados ao Ato Concessório serão bloqueados.

      If lIntDraw .And. lExistEDD
         EDD->(dbSetOrder(3))
         If !Inclui .and. !Empty(WorkIP->EE9_ATOCON) /*.and.;
            EDD->(dbSeek(cFilEDD+WorkIP->(EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN+EE9_COD_I+EE9_ATOCON)))*/
            /*
            MsgInfo(STR0056,; //"Registro não pode ser desmarcado pois possui associação anterior com Ato Concessório. Estorne o Ato a partir do menu."
                    If(lConsolida,AllTrim(AvSx3("EE9_SEQEMB",AV_TITULO)) + ": " + AllTrim(WorkIp->EE9_SEQEMB),"") )
            lRetVal := .F.
         EndIf
      EndIf
      */
      If EECFlags("ESTUFAGEM")
         If (lItEstufado := Ae110IsEstuf(M->EEC_PREEMB, WorkIp->EE9_SEQEMB))
            MsgInfo(STR0092 + ENTER +; //STR0092	"Este item já foi estufado, portanto não poderá ser desmarcado."
                    STR0093 + ENTER +;//STR0093	"Antes de confirmar a gravação do embarque, este item deve ser marcado novamente."
                    STR0094 + ENTER +; //STR0094	"Além disso, não será possível alterar as informações de quantidade e embalagem."
                    STR0095, STR0096)//STR0095	"Caso deseje desmarcar efetivamente o item ou ainda alterar alguma informação relacionada a quantidade, remova o item da relação de mercadorias estufadas." //STR0096	"Aviso"
         EndIf
      EndIf

      If lConsolida
         WorkIp->(DbSkip())
      Else
         Exit
      EndIf
   EndDo

End Sequence

If lConsolida
   EECRestFilter(aFilter[1]) //restaura o filtro anterior
EndIf

If EasyEntryPoint("EECAE101")
   ExecBlock("EECAE101",.F.,.F.,"VALIDA_DESMARCA")
EndIf

Return(lRetVal)


/*
Função : AEAntMarca()
Revisão: 03/03/16
         No cenário que está integrado com o faturamento, ao desmarcar o item, manter o ato concessório
         nos itens que foram desmarcados por pertencerem a mesma nota fiscal */
*--------------------------------------------------------------------------------------------*
Function AEAntMarca(nOpAux)       //GFC - 18/07/2003 - Drawback Anterioridade
*--------------------------------------------------------------------------------------------*

If !lIntDraw .or. !lExistEDD
   Return .T.
EndIf

If nOpAux = 1       //Marca
   If !Empty(WorkIP->EE9_ATOCON) .and.;
   !AeApSldAC(WorkIP->EE9_ATOCON,WorkIP->EE9_COD_I,WorkIP->EE9_SEQUEN,M->EEC_DTEMBA,If(WorkIP->EE9_SLDINI<>0,WorkIP->EE9_SLDINI,WorkIP->WP_SLDATU),WorkIP->EE9_PEDIDO,,WorkIP->EE9_SEQEMB,,,,.F./*AOM - 26/08/2011*/)
      Return.F.
   EndIf
ElseIf (nOpAux == 2 .Or. nOpAux == 3) .and. Select("WorkAnt")<>0 .And. WorkAnt->(EasyRecCount()) > 0 //Desmarca - wfs - acrescentado tratamento para verificar se existem registros, considerando que o processo possa ter sido gravado totalmente e, neste caso, não pode ocorrer a desvinculação do ato concessório.

   Begin Sequence

      If nOpAux == 3 .And. IsIntFat() .And. !Empty(WorkIP->EE9_NF)
         Break
      EndIf

      AEDelWkAnt(WorkIP->EE9_ATOCON,WorkIP->EE9_PEDIDO,WorkIP->EE9_SEQUEN,WorkIP->EE9_SEQEMB/*AOM - 26/08/2011*/)

      //Insumos
      WorkEDG->(DbSetOrder(1))
      If WorkEDG->(DbSeek(WorkIP->EE9_SEQEMB))
         While !WorkEDG->(Eof()) .and. WorkEDG->EDG_SEQEMB == WorkIP->EE9_SEQEMB
            If WorkEDG->EDG_RECNO <> 0
               aAdd(aDelEDG, WorkEDG->EDG_RECNO)
            Endif
            WorkEDG->(Reclock("WorkEDG",.F.))
            WorkEDG->EDG_FLAG := .F.
            WorkEDG->EDG_RECNO := 0
            WorkEDG->(MsUnlock())
            WorkEDG->(DbSkip())
         EndDo
      EndIf

      //AOM - 06/07/2011 - Ao desmarcar o item deve apagar o ato e sequencia da Work
      WorkIP->EE9_ATOCON := ""
      WorkIP->EE9_SEQED3 := ""
      WorkIP->EE9_VL_AC  := 0
      WorkIP->EE9_QT_AC  := 0

   End Sequence
EndIf

Return .T.

*--------------------------------------------------------------------------------------------*
Function AEDelWkAnt(cAc,cPed,cSeq,cSeqEmb)
*--------------------------------------------------------------------------------------------*
Local lIndexPed := "EDD_PEDIDO" $ EDD->(IndexKey(1)) .And. "EDD_PEDIDO" $ EDD->(IndexKey(2))//AOM - 22/11/2011 - Verifica se o idice está atualizado com o campo Pedido

WorkAnt->(dbSetOrder(1))
If !Empty(cAc) .and. WorkAnt->(dbSeek(cAc+M->EEC_PREEMB+cPed+cSeq+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,cSeqEmb,"")))//AOM - 26/08/2011
   Do While WorkAnt->(dbSeek(cAc+M->EEC_PREEMB+cPed+cSeq+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,cSeqEmb,"")))//AOM - 26/08/2011

      If Empty(WorkAnt->EDD_HAWB)
         WorkAnt->(dbDelete())
      Else
         nQtdAux := WorkAnt->EDD_QTD
         nRecAux := WorkAnt->(RecNo())

         IF AvFlags("SEQMI") .AND. !Empty(WorkAnt->EDD_SEQMI)
            WorkAnt->(dbSetOrder(4))
         ELSE
            WorkAnt->(dbSetOrder(3))
         ENDIF
         // GFP - 10/11/2011 - Incluido campo SEQMI no índice
         If WorkAnt->(dbSeek(WorkAnt->EDD_HAWB+WorkAnt->EDD_INVOIC+WorkAnt->EDD_PO_NUM+WorkAnt->EDD_POSICA+WorkAnt->EDD_PGI_NU+WorkAnt->EDD_AC+ IF(AvFlags("SEQMI") .AND. !Empty(WorkAnt->EDD_SEQMI),WorkAnt->EDD_SEQMI,WorkAnt->EDD_SEQSII)+Space(Len(WorkAnt->EDD_PREEMB))+ IF(lIndexPed,Space(Len(WorkAnt->EDD_PEDIDO))+Space(Len(WorkAnt->EDD_SEQUEN)),"")))
            WorkAnt->EDD_QTD += nQtdAux
            WorkAnt->(dbGoTo(nRecAux))
            WorkAnt->(dbDelete())
         Else
            WorkAnt->(dbGoTo(nRecAux))
            WorkAnt->EDD_PREEMB := ""
            WorkAnt->EDD_PEDIDO := ""
            WorkAnt->EDD_SEQUEN := ""
            //WorkAnt->EDD_QTD    := 0
            WorkAnt->EDD_DTRE   := AvCtoD("  /  /  ")
            WorkAnt->EDD_QTD_EX := 0
            WorkAnt->EDD_LEAD   := 0
            WorkAnt->EDD_PROD   := ""
            WorkAnt->EDD_SEQSIE := ""
            // ** PLB 21/06/07
            If lMFilEDC
               WorkAnt->EDD_FILEXP := ""
            EndIf
            // **
         EndIf
         WorkAnt->(dbSetOrder(1))
      EndIf

      WorkAnt->(dbSkip())
   EndDo
EndIf

Return .T.

*------------------------------------------------*
Function VoltaQuebra(nQtdApropriada,lBotao)
*------------------------------------------------*
Local nSldI, nPrcT, nPslQ, nPslB, cPree, cPed, cSeque, nPrcI, nRec1:=EE9->(RecNo()), nRec2

nSldI := EE9->EE9_SLDINI
nPrcT := EE9->EE9_PRCTOT
nPrcI := EE9->EE9_PRCINC
nPslQ := EE9->EE9_PSLQTO
nPslB := EE9->EE9_PSBRTO
cPree := EE9->EE9_PREEMB
cPed  := EE9->EE9_PEDIDO
cSeque:= EE9->EE9_SEQUEN

EE9->(dbSeek(xFilial("EE9")+cPree+cPed+cSeque))
Do While !EE9->(EOF()) .and. EE9->EE9_FILIAL==xFilial("EE9") .and. EE9->EE9_PREEMB==cPree .and.;
EE9->EE9_PEDIDO==cPed .and. EE9->EE9_SEQUEN==cSeque .and. !Empty(EE9->EE9_ATOCON)
   EE9->(dbSkip())
EndDo

If EE9->EE9_FILIAL==xFilial("EE9") .and. EE9->EE9_PREEMB==cPree .and.;
EE9->EE9_PEDIDO==cPed .and. EE9->EE9_SEQUEN==cSeque .and. Empty(EE9->EE9_ATOCON)
   nRec2 := EE9->(RecNo())

   EE9->(dbGoTo(nRec1))
   EE9->(RecLock("EE9",.F.,.T.))
   EE9->(dbDelete())
   EE9->(msUnlock())

   EE9->(dbGoTo(nRec2))
   EE9->(RecLock("EE9",.F.))
   EE9->EE9_SLDINI += nSldI
   EE9->EE9_PRCTOT += nPrcT
   EE9->EE9_PSLQTO += nPslQ
   EE9->EE9_PSBRTO += nPslB
   EE9->EE9_PRCINC += nPrcI
   IF !EMPTY(EE9->EE9_QE)
      IF (EE9->EE9_SLDINI%EE9->EE9_QE)==0
         EE9->EE9_QTDEM1:=Int(Round((EE9->EE9_SLDINI/EE9->EE9_QE),10)) //QUANT.DE EMBAL.
      Else
         EE9->EE9_QTDEM1:=Int(Round((EE9->EE9_SLDINI/EE9->EE9_QE),10))+1 //QUANT.DE EMBAL.
      EndIf
   EndIf
   EE9->(msUnlock())
Else
   EE9->(dbGoTo(nRec1))
   EE9->(RecLock("EE9",.F.))
   EE9->EE9_ATOCON := ""
   EE9->EE9_SEQED3 := ""
   EE9->EE9_QT_AC  := 0
   EE9->EE9_VL_AC  := 0
   EE9->(msUnlock())
EndIf

Return .T.

*-----------------------------------------------*
Function QuebraItem(nQtdApropriada,lBotao)
*-----------------------------------------------*
Local nOldRec:=WorkIP->(RecNo())
Local nOldOrd:=WorkIP->(IndexOrd())
Local nOldArea := Select(), i:=0
Local cSeq

dbSelectArea("WorkIP")
If lBotao
   FOR i := 1 TO FCount()
      M->&(FIELDNAME(i)) := FieldGet(i)
   NEXT i
EndIf

//** AAF 26/07/05 - Gravar SeqEmb sequencial.
WorkIP->( dbSetOrder(2) )
WorkIP->( dbGoBottom() )
cSeq := Str(Val(WorkIP->EE9_SEQEMB) + 1,AVSX3("EE9_SEQEMB",3))
//**

WorkIP->(RecLock("WorkIP",.T.))
FOR i := 1 TO FCount()
   WorkIP->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
NEXT i
WorkIp->EE9_SEQEMB := cSeq 
WorkIP->EE9_SLDINI := WorkIP->EE9_SLDINI - nQtdApropriada
WorkIP->EE9_PRCTOT := WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI
WorkIP->EE9_PSLQTO := WorkIP->EE9_PSLQUN*WorkIP->EE9_SLDINI
WorkIP->EE9_PSBRTO := WorkIP->EE9_PSBRTO*(1-nPercent) //LRL 28/05/04
/*If(!lItFabric .Or. lBotao,*/WorkIP->EE9_ATOCON := "" // NOPADO POR AOM - 05/09/2011 /*,)*/ // By JPP - 14/11/2007 - 14:00 - WFS 28/07/11 lBotao
/*If(!lItFabric .Or. lBotao,*/WorkIP->EE9_SEQED3 := "" // NOPADO POR AOM - 05/09/2011 /*,) // By JPP - 14/11/2007 - 14:00 - WFS 28/07/11 lBotao
/*If(!lItFabric .Or. lBotao,*/WorkIP->EE9_QT_AC  := 0  // NOPADO POR AOM - 05/09/2011 /*,)  // By JPP - 14/11/2007 - 14:00 - WFS 28/07/11 lBotao
/*If(!lItFabric .Or. lBotao,*/WorkIP->EE9_VL_AC  := 0  // NOPADO POR AOM - 05/09/2011 /*,)  // By JPP - 14/11/2007 - 14:00 - WFS 28/07/11 lBotao
/*If(lItFabric,*/nRegFabrIt := WorkIP->(Recno()) // NOPADO POR AOM - 05/09/2011 /*,)  // By JPP - 14/11/2007 - 14:00
//** AAF 26/07/05 - Quebrar item sempre utilizando a work.
IF !EMPTY(WorkIP->EE9_QE)
   IF WorkIP->EE9_SLDINI%WorkIP->EE9_QE == 0 //(M->EE9_SLDINI%M->EE9_QE)==0
      WorkIP->EE9_QTDEM1:= WorkIP->EE9_SLDINI/WorkIP->EE9_QE        //QUANT.DE EMBAL.
   Else
      WorkIP->EE9_QTDEM1:= Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE)+1 //QUANT.DE EMBAL.
   EndIf
EndIf
//**

WorkIP->WP_FLAG := cMarca
WorkIP->WP_RECNO := 0
WorkIP->(msUnlock())
SumTotal()
AE100PrecoI()

WorkIP->(dbSetOrder(nOldOrd))
WorkIP->(dbGoTo(nOldRec))
dbSelectArea(nOldArea)

Return .T.
*-------------------------------------------------------------*
//Funcão     : AjustaPeso
//Objetivo   : Retorna Procentagem aplicada no calculo do peso Liquido
//Parametros : nSldQuebra - Saldo Apos a Quebra
//             lBotao - Se .T. usa Work , se .F. usa M
//             nSldTot -Saldo Total, antes da Quebra
//Autor      : Lucas Rolim Rosa Lopes        Data   28/05/2004
*-------------------------------------------------------------*
Function AjustaPeso(nSldQuebra,nSldTot,lBotao)
Local   nLiqTot:=0
Local   nLiquido:=0
Local  nPorcento:=0
   nLiqTot:=If(!lBotao,(M->EE9_PSLQUN*nSldTot), (WorkIP->EE9_PSLQUN*nSldTot))
   nLiquido:=If(!lBotao,(M->EE9_PSLQUN*nSldQuebra),(WorkIP->EE9_PSLQUN*nSldQuebra))
   nPorcento:=If(!lBotao,(nLiquido*100)/nLiqTot,(nLiquido*100)/nLiqTot)
Return (nPorcento/100)

/*
Funcao      : AE101CobCamb(cCampo)
Parametros  : cCampo = Campo que chamou a função
Retorno     :
Objetivos   : Carregar automaticamente o campo Cobertura Cambial. Se a modalidade de pagamento for igual "006"
              "Sem Cobertura Cambial" Alterar o campo cobertura cambial para "Não". Se a modalidade de
              pagamento for diferente de "006", alterar o campo cobertura cambial para "Sim".
Autor       : Julio de Paula Paz
Data/Hora   : 22/09/2005 11:50
Revisao     :
Obs.        :
*/
Function AE101CobCamb(cCampo)
Local aOrd := SaveOrd("SY6"), cChave
Begin Sequence
   Do Case
      Case cCampo == "EEC_CONDPA"  // A funcao foi chamada a partir do campo "EEC_CONDPA"
           If Empty(M->EEC_DIASPA)
              cChave := XFILIAL("SY6")+M->EEC_CONDPA
           Else
              cChave := XFILIAL("SY6")+M->EEC_CONDPA+STR(M->EEC_DIASPA,AVSX3("EEC_DIASPA",AV_TAMANHO))
           EndIf

           SY6->(DbSetOrder(1)) // Filial + Condição Pagamento + Dias Pagamento

           If SY6->(DbSeek(cChave))
              If SY6->Y6_MDPGEXP == "006" .OR. M->EEC_MPGEXP == "002"// Modalidade de pagamento exportação = "Sem cobertura cambial" em "Consignação"
                 M->EEC_COBCAM := "2"  // Campo cobertura cambial = "Não"
              Else
                 M->EEC_COBCAM := "1" // Campo cobertura cambial = "Sim"
              EndIf
           Else
              cChave := XFILIAL("SY6")+M->EEC_CONDPA // Se a primeira pesquisa não for bem sucedida,
                                                     // localiza a primeira ocorrencia da condição de pagamento.
              If SY6->(DbSeek(cChave))
                 If SY6->Y6_MDPGEXP == "006" .OR. M->EEC_MPGEXP == "002" // Modalidade de pagamento exportação = "Sem cobertura cambial" em "Consignação"
                    M->EEC_COBCAM := "2"  // Campo cobertura cambial = "Não"
                 Else
                    M->EEC_COBCAM := "1" // Campo cobertura cambial = "Sim"
                 EndIf
              EndIf
           EndIf

      Case cCampo == "EEC_MPGEXP" .Or. cCampo == "CARREGA_EMB" // A funcao foi chamada a partir do campo "EEC_MPGEXP"
                                                               // ou do carregamento dos dados do pedido para o Embarque.
           If M->EEC_MPGEXP == "006" .OR. M->EEC_MPGEXP == "002"   // Modalidade de pagamento exportação = "Sem cobertura cambial" ou em "Consignação"
              M->EEC_COBCAM := "2" // Campo cobertura cambial = "Não"
           Else
              M->EEC_COBCAM := "1" // Campo cobertura cambial = "Sim"
           EndIf
   EndCase
End Sequence
RestOrd(aOrd)
Return Nil


/*
Funcao      : Ae101DelEDD
Parametros  : -
Retorno     : -
Objetivos   : Deleta os dados da tabela EDD, para efetuar o estorno no Ato Concessório no Drawback
Autor       : Allan Oliveira Monteiro
Data/Hora   : 15/04/2010 - 15:05
Revisao     :
Obs.        :
*/
****************************
Function Ae101DelEDD()
****************************
Local nI
Local aPrinc := {}

If lExistEDD  //AOM- 15/04/2010 - Drawback Anterioridade
   DbSelectArea("EDD")
   EDD->(dbSetOrder(3))
   If EDD->(dbSeek(cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+EE9->EE9_COD_I+EE9->EE9_ATOCON+EE9->EE9_SEQED3+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,EE9->EE9_SEQEMB,"")))//AOM - 26/08/2011
      ACDelAnt()
   Else
      If Len(aPrinc := IG400AllItens("E", EE9->EE9_COD_I)) > 0
         For nI:=1 To Len(aPrinc)
            If EDD->(dbSeek(cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+AvKey(aPrinc[nI][1],"EDD_PROD")+EE9->EE9_ATOCON+EE9->EE9_SEQED3+If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,EE9->EE9_SEQEMB,"")))//AOM - 26/08/2011
               ACDelAnt(cFilEDD+EE9->EE9_PREEMB+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN+AvKey(aPrinc[nI][1],"EDD_PROD")+EE9->EE9_ATOCON+EE9->EE9_SEQED3)
            EndIf
         Next
      EndIf
   EndIf
EndIf
//VoltaQuebra() //NCF - 05/10/2010 - (Nopado) Função já é chamada dentro da função AE101ESTAC(Esta chamada faz com que a linha do item no embarque seja deletada
                //                            e o saldo da mesma duplicado quando efetuado o estorno do ato na Exportação)
Return Nil


/*
Funcao      : ExibeApropriacao()
Parametros  : Ato Concessório, Pedido, Sequência, Produto e mensagem
Retorno     :
Objetivos   : Executar MsSelect para visualização dos insumos vinculados
              ao item exportado
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 26/07/11
Revisao     :
Obs.        :
*/
Static Function ExibeApropriacao(cAto,cPedido,cSequen, cProd, cMsg1, cSeqEmb)
Local aPos:= {}
Local bOk    := {|| lRet:= .T., oDlgAprop:End()},;
      bCancel:= {|| lRet:= .F., oDlgAprop:End()}
Local cFiltro:= "",;
      cMsg   := ""
Local oDlgAprop,;
      oSay,;
      oPanel1,;
      oNewGetDados

Private aHeader:= {},;
        aCols  := {}
Private lRefresh:= .F.
Private lRet:= .F., lSair := .F.

Begin Sequence

   lSair := .F.
   IF(EasyEntryPoint("EECAE101"),Execblock("EECAE101",.F.,.F.,"ANTESTELA_EXIBEAPROPRIACAO"),)
   IF lSair
      Break
   ENDIF

   //Campos que serão visualizados

   //Insumo
   AAdd(aHeader, {AvSx3("EDD_ITEM", AV_TITULO),;
                  "EDD_ITEM",;
                  AvSx3("EDD_ITEM", AV_PICTURE),;
                  AvSx3("EDD_ITEM", AV_TAMANHO),;
                  AvSx3("EDD_ITEM", AV_DECIMAL),;
                  "AllwaysTrue()",;
                  ,;
                  AvSx3("EDD_ITEM", AV_TIPO)})
   //Unidade de medida
   AAdd(aHeader, {STR0077,; //"Unid.Medida"
                  "EDD_UNID",;
                  AvSx3("EE9_UNIDAD", AV_PICTURE),;
                  AvSx3("EE9_UNIDAD", AV_TAMANHO),;
                  AvSx3("EE9_UNIDAD", AV_DECIMAL),;
                  "AllwaysTrue()",;
                  ,;
                  AvSx3("EE9_UNIDAD", AV_TIPO)})
   //Necessidade
   AAdd(aHeader, {STR0078,; //"Necessidade"
                  "EDD_NECESS",;
                  AvSx3("EDD_QTD", AV_PICTURE),;
                  AvSx3("EDD_QTD", AV_TAMANHO),;
                  AvSx3("EDD_QTD", AV_DECIMAL),;
                  "AllwaysTrue()",;
                  ,;
                  AvSx3("EDD_QTD", AV_TIPO)})
   //Quantidade comprovada
   AAdd(aHeader, {STR0079,; //"Quantidade Comprovada"
                  "EDD_QTD",;
                  AvSx3("EDD_QTD", AV_PICTURE),;
                  AvSx3("EDD_QTD", AV_TAMANHO),;
                  AvSx3("EDD_QTD", AV_DECIMAL),;
                  "AllwaysTrue()",;
                  ,;
                  AvSx3("EDD_QTD", AV_TIPO)})
   //Quantidade a comprovar
   AAdd(aHeader, {STR0080,; //"Quantidade a Comprovar"
                  "EDD_QTDCP",;
                  AvSx3("EDD_QTD", AV_PICTURE),;
                  AvSx3("EDD_QTD", AV_TAMANHO),;
                  AvSx3("EDD_QTD", AV_DECIMAL),;
                  "AllwaysTrue()",;
                  ,;
                  AvSx3("EDD_QTD", AV_TIPO)})

   //Mensagens
   cMsg:= STR0081 + AllTrim(cProd) + " - " + STR0023 + AllTrim(cSequen) +; //Produto a exportar: ### - Sequência: ### - Quantidade: "
          " - " + STR0082 + AllTrim(Str(WorkIp->EE9_SLDINI)) + " " + AllTrim(WorkIp->EE9_UNIDAD) + ENTER + cMsg1

   //AOM - 26/08/2011
   If EDD->(FIELDPOS("EDD_SEQEMB")) > 0
      //cFiltro:= "EDD_AC + EDD_PEDIDO + EDD_SEQUEN + EDD_SEQEMB == '" + cAto + cPedido + cSequen + cSeqEmb + "'"
      cFiltro:=  "EDD_AC == '" + cAto +;
                 "' .And. EDD_PEDIDO == '" + cPedido +;
                 "' .And. EDD_SEQUEN == '" + cSequen +;
                 "' .And. EDD_SEQEMB == '" + cSeqEmb + "'"
   Else
      //cFiltro:= "EDD_AC + EDD_PEDIDO + EDD_SEQUEN == '" + cAto + cPedido + cSequen + "'"
      cFiltro:=  "EDD_AC == '" + cAto +;
                 "' .And. EDD_PEDIDO == '" + cPedido +;
                 "' .And. EDD_SEQUEN == '" + cSequen + "'"
   EndIf
   WorkAnt->(DBSetFilter(&("{|| " + cFiltro + " }"), cFiltro))

   //Calcula a quatidade a comprovar
   CalcQtdComprovar()

   Define MsDialog oDlgAprop Title STR0076 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Anterioridade"

      aPos := PosDlg(oDlgAprop)

      oPanel1:=	TPanel():New(aPos[1],aPos[2], "", oDlgAprop,, .F., .F.,,, aPos[4], 40)
      oPanel1:Align:= CONTROL_ALIGN_TOP

      oSay:= TSay():New(10, 10, {|| cMsg},oPanel1,,,,,, .T.,,,,60)
      oSay:lWordWrap := .T.

      oNewGetDados:= MsNewGetDados():New(0, 0, 0, 0, 2,,,,{},,999,,,, oDlgAprop, aHeader, aCols)
      oNewGetDados:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
      oDlgAprop:lMaximized := .T.

   Activate MsDialog oDlgAprop on Init EnchoiceBar(oDlgAprop, bOk, bCancel)

   WorkAnt->(DBClearFilter())


   If lRet
      If !MsgYesNo(STR0054, STR0058) //Confirma apropriação? / Atenção
         lRet:= .F.
      EndIf
   EndIf
End Sequence

Return lRet

/*
Funcao      : CalcQtdComprovar()
Parametros  :
Retorno     :
Objetivos   : Calcula a quantidade a comprovar, para exibição na apropriação do ato concessório
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 29/07/11
Revisao     :
Obs.        :
*/

Static Function CalcQtdComprovar()
Local aOrd:= SaveOrd({"ED4", "SB1", "WorkAnt"}) // TRP - 29/10/2012
Local nQtdComprovar:= 0,;
      nPos         := 0
Local lPrimeira    := .T.
Local cUnid
Begin Sequence

   WorkAnt->(DBGoTop())

   aCols:= {}
   While WorkAnt->(!Eof())

      If !lPrimeira
         nPos:= AScan(aCols, {|x| x[1] == WorkAnt->EDD_ITEM})
      EndIf
      lPrimeira:= .F.


      If nPos > 0

         If WorkAnt->EDD_QTD < 0
            aCols[nPos][5] += Abs(WorkAnt->EDD_QTD) //Quantidade a comprovar
         Else
            aCols[nPos][4] += WorkAnt->EDD_QTD //Quantidade comprovada
         EndIf

         aCols[nPos][3] += Abs(WorkAnt->EDD_QTD) //Necessidade
      Else

         AAdd(aCols, Array(Len(aHeader) + 1))

         // GFP - 10/11/2011
         IF AvFlags("SEQMI") .AND. Empty(WorkAnt->EDD_HAWB)
            cUnid:= Posicione("ED4", 8, xFilial("ED4") + WorkAnt->EDD_AC + WorkAnt->EDD_SEQMI, "ED4_UMITEM")
         ELSE
            cUnid:= Posicione("ED4", 2, xFilial("ED4") + WorkAnt->EDD_AC + WorkAnt->EDD_SEQSII, "ED4_UMITEM")
         ENDIF

         If Empty(cUnid)
            cUnid:= Posicione("SB1", 1, xFilial("SB1") + AvKey(WorkAnt->EDD_ITEM, "B1_COD"), "B1_UM")
         EndIf

         aCols[Len(aCols)][1]:= WorkAnt->EDD_ITEM
         aCols[Len(aCols)][2]:= cUnid
         aCols[Len(aCols)][3]:= Abs(WorkAnt->EDD_QTD) //Necessidade
         aCols[Len(aCols)][6]:= .F.

         If WorkAnt->EDD_QTD >= 0
            aCols[Len(aCols)][4]:= WorkAnt->EDD_QTD //Quantidade comprovada
            aCols[Len(aCols)][5]:= 0 //Quantidade a comprovar
         Else
            aCols[Len(aCols)][4]:= 0 //Quantidade comprovada
            aCols[Len(aCols)][5]:= Abs(WorkAnt->EDD_QTD) //Quantidade a comprovar
         EndIf
         //
      EndIf

      WorkAnt->(DBSkip())
   EndDo

End Sequence

RestOrd(aOrd, .T.)
Return

/*
Funcao      : OpcApropAutomatica
Parametros  :
Retorno     : lRet - caso negativo, aborta a apropriação automática
Objetivos   : Exibir as opções de apropriação automática do ato concessório
Autor       : Wilsimar Fabrício da Silva
Revisao     : Allan Oliveira Monteiro
Data/Hora   : 27/07/11
Revisao     :
Obs.        :
*/

Static Function OpcApropAutomatica(cTitPed)
Local aOptions1:= {} , aPos := {}
Local bOk      := {|| lRet:= .T., oDlgOpc:End()},;
      bCancel  := {|| lRet:= .F., oDlgOpc:End()}
Local lRet     := .F.
Local nRadio1, nRadio2, i
Local oDlgOpc,;
      oRadio1,oRadio2,;
      oPanel1,oPanel2
Default cTitPed := ""

Begin Sequence



   aOptions1:= {STR0087,; //"Saldo a exportar do compromisso de exportação"
                STR0088}//"Saldo a exportar do insumo no ato concessório"

   aOptions2:= {STR0072,; //AP_AUT_COMPROVADOS    //"Apropria automaticamente quando há comprovação para todos os insumos"
               STR0073,; //AP_CONF_NAOCOMPROVADOS//"Exibe tela de confirmação quando não há comprovação para todos os insumos"
               STR0074,; //AP_AUT_NAOCOMPROVADOS //"Apropria automaticamente quando há comprovação para, ao menos, um insumo"
               STR0075}  //AP_CONF_TODOS         //"Sempre exibe tela de confirmação"


   nOpcApSld:= EasyGParam("MV_EEC0004",,0)
   nOpcAprop:= EasyGParam("MV_EEC0005",,0)


   //Caso as opções vierem preenchidas dos parametros, caso sim,  nao apresentar a tela  de opçoes
   If nOpcApSld <> 0 .And. nOpcAprop <> 0
      lRet := .T.
      Break
   EndIf


   Define MsDialog oDlgOpc Title STR0071 +" "+ cTitPed From 0, 0 To 400, 470 Of oMainWnd Pixel //"Opções de Apropriação Automática"

      aPos := PosDlg(oDlgOpc)

      oPanel1:= TPanel():New(10,10, /*STR0089*/, oDlgOpc,, .F., .F.,,, 100, 60)
      @ 10,04 TO 47,220 LABEL STR0089 OF oPanel1 PIXEL //"Saldo a Ser utilizado na apropriação"
      oPanel1:Align:= CONTROL_ALIGN_TOP
      oRadio1:= tRadMenu():New(20,10,aOptions1, {|u| If(PCount() > 0, nRadio1:=u, nRadio1)}, oPanel1,,,,,,,,205,80,,,,.T.)

      oPanel2:= TPanel():New(30,10, /*STR0090*/, oDlgOpc,, .F., .F.,,, 100, 60)
      @ 10,04 TO 65,220 LABEL STR0090 OF oPanel2 PIXEL//"Regra de apropriação"
      oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT
      oRadio2:= tRadMenu():New(20,10,aOptions2, {|u| If(PCount() > 0, nRadio2:=u, nRadio2)}, oPanel2,,,,,,,,205,80,,,,.T.)


      If (nOpcApSld <> 0  .And. nOpcApSld <= Len(aOptions1)) .Or. ED4->(FIELDPOS("ED4_SQTDEX")) == 0
         //Se o campo nao existe é considerado o tratamento padrao e bloqueado o campo
         nRadio1 := IF(ED4->(FIELDPOS("ED4_SQTDEX")) == 0 ,1,nOpcApSld)
         For i:= 1 to Len(aOptions1)
            oRadio1:Disable(i)
         Next i
      Else
         nRadio1 := 1
      EndIf

      If nOpcAprop <> 0  .And. nOpcAprop <= Len(aOptions2)
         nRadio2 := nOpcAprop
         For i:= 1 to Len(aOptions2)
            oRadio2:Disable(i)
         Next i
      Else
         nRadio2 := 1
      EndIf

   Activate MsDialog oDlgOpc On Init EnchoiceBar(oDlgOpc, bOk, bCancel) Centered


   If lRet
      nOpcApSld:= nRadio1
      nOpcAprop:= nRadio2
      lMsgExibe:= (nOpcAprop == AP_CONF_NAOCOMPROVADOS .Or. nOpcAprop == AP_CONF_TODOS)
   Else
      WorkIp->EE9_ATOCON := ""  // AAF - 23/09/2013
      WorkIp->EE9_SEQED3 := ""  // AAF - 23/09/2013
   EndIf

End Sequence


Return lRet



/*
Funcao      : AeApSldAC
Parametros  : cAto,cProd,cSequen,dDtEmba,nQtdComp,cPedido,lExistQuebra,cSeqEmb,cPos,lBotao,lApro,lMostraAC
Retorno     : lRet
Objetivos   : Verifica o saldo a ser utilizado para apropriação do ato, caso seja utilizado saldo a exportar
              é considero o saldo maior dos insumos na estrutura.
Autor       : Allan Oliveira Monteiro
Data/Hora   : 31/08/2011
Revisao     :
Obs.        :
*/

*----------------------------------------------------------------------------------------------------------------*
Function AeApSldAC(cAto,cProd,cSequen,dDtEmba,nQtdComp,cPedido,lExistQuebra,cSeqEmb,cPos,lBotao,lApro,lMostraAC)
*----------------------------------------------------------------------------------------------------------------*
Local lRet := .T. , lPrimeira := .T. ,lAchouWkAnt := .F. ,lSeekAnt := .T.
Local cFiltro:= ""
Local aSldAnt := {}
Local nQtdAnt := 0 , nPos := 0,nOrder := 0 , nQtdEDD := 0
Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade




Default lApro := lBotao := .F.
Default lMostraAC := .T.

If Type("nOpcApSld") == "U"
   _SetOwnerPrvt("nOpcApSld", EasyGParam("MV_EEC0004",,0))
EndIf

Default lExistQuebra := .F.
Default cSeqEmb := Space(AVSX3("EE9_SEQEMB",AV_TAMANHO))


Begin Sequence
   //Caso o tipo de apropriação automatica for compromisso de exportação
   If nOpcApSld == SLD_COMPEXP
     lRet:= AEGrvWKAnt(cAto,cProd,cSequen,dDtEmba,nQtdComp,cPedido,lExistQuebra,cSeqEmb)
     If lRet .And. ED3->ED3_SALDO >= nQtdComp
        Apropria(lApro)
     ElseIf lRet .And. !ConfirmaAC(cAto,cPos,lBotao,lApro)
        AEDelWkAnt(cAto,cPedido,cSequen,cSeqEmb)
        lRet := .F.
        Break
     EndIf
     Break
   EndIf

   If Select("WorkAnt") > 0
      nOrder := WorkAnt->(IndexOrd())
      WorkAnt->(DbSetOrder(1)) //"EDD_AC+EDD_PREEMB+EDD_PEDIDO+EDD_SEQUEN+EDD_SEQEMB+EDD_CODOCO"
      lSeekAnt := !(WorkAnt->(DbSeek(cAto + Space(AVSX3("EDD_PREEMB",AV_TAMANHO)) + Space(AVSX3("EDD_PEDIDO",AV_TAMANHO));
                                 + Space(AVSX3("EDD_SEQUEN",AV_TAMANHO)) + If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,Space(AVSX3("EDD_SEQEMB",AV_TAMANHO)),"");
                                 + IF(lTpOcor,Space(AVSX3("EDD_CODOCO",AV_TAMANHO)),"") )))//AOM 25/06/2012
      If lSeekAnt

         If WorkAnt->(DbSeek(cAto + M->EEC_PREEMB + cPedido + cSequen + cSeqEmb))
            lAchouWkAnt := .T.
            lSeekAnt    := .F.
         EndIf

      Else


         While WorkAnt->(!EOF()) .And. WorkAnt->EDD_AC == cAto .And. Empty(WorkAnt->EDD_PREEMB) .And. Empty(WorkAnt->EDD_PEDIDO);
                                 .And. Empty(WorkAnt->EDD_SEQUEN) .And. If(EDD->(FIELDPOS("EDD_SEQEMB")) > 0,Empty(WorkAnt->EDD_SEQEMB),.T.);
                                 .And. (!lTpOcor .Or. Empty(EDD->EDD_CODOCO))//AOM 25/06/2012



               nRecWkIP := WorkIp->(Recno())
               WorkIp->(DbSetOrder(1))
               WorkIp->(DbSeek(cPedido) )
               While WorkIp->(!EOF()) .And. WorkIp->EE9_PEDIDO == cPedido
                  If  !Empty(WorkIp->EE9_ATOCON) .And. !Empty(WorkIp->EE9_SEQUEN) .And. WorkIp->EE9_ATOCON == cAto .And.;
                      WorkIp->EE9_SEQUEN == cSequen .And. nQtdEDD < WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT .And. WorkIp->EE9_SEQEMB == cSeqEmb //inclusão do SeqEmb na chave de comparação

                     nQtdEDD := WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT
                     nQtdAnt := (WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT) - WorkIp->EE9_QT_AC
                     lAchouWkAnt := .T.

                  EndIf
               WorkIp->(DbSkip())
               EndDo
               WorkIp->(DbGoTo(nRecWkIP))

               If !lAchouWkAnt

                  If nQtdAnt < WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT
                     nQtdAnt := (WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT)
                     lAchouWkAnt := .T.
                  EndIf
               EndIf

            /*If WorkAnt->EDD_QTD <> WorkAnt->EDD_QTD_OR

               If nQtdAnt < WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT
                  nQtdAnt := (WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT)
                  lAchouWkAnt := .T.
               EndIf

            Else

               nRecWkIP := WorkIp->(Recno())
               WorkIp->(DbSetOrder(1))
               WorkIp->(DbSeek(cPedido) )
               While WorkIp->(!EOF()) .And. WorkIp->EE9_PEDIDO == cPedido
                  If  !Empty(WorkIp->EE9_ATOCON) .And. !Empty(WorkIp->EE9_SEQUEN) .And. WorkIp->EE9_ATOCON == cAto .And.;
                      WorkIp->EE9_SEQUEN == cSequen .And. nQtdEDD < WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT

                     nQtdEDD := WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT
                     nQtdAnt := (WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT) - WorkIp->EE9_QT_AC
                     lAchouWkAnt := .T.

                  EndIf
               WorkIp->(DbSkip())
               EndDo
               WorkIp->(DbGoTo(nRecWkIP))

            EndIf*/

         WorkAnt->(DbSkip())
         EndDo

      EndIf

   EndIf



   //Grava a anterioridade com os dados totais de compromisso de exportação
   If lSeekAnt .And. !AEGrvWKAnt(cAto,cProd,cSequen,dDtEmba,nQtdComp,cPedido,lExistQuebra,cSeqEmb, lMsgExibe)
      lRet := .F.
      Break
   EndIf

   //Filtro para WorkAnt                                                                              `
   If EDD->(FIELDPOS("EDD_SEQEMB")) > 0
      //cFiltro:= "EDD_AC + EDD_PEDIDO + EDD_SEQUEN + EDD_SEQEMB == '" + cAto + cPedido + cSequen + cSeqEmb + "'"
      cFiltro:=  "EDD_AC == '" + cAto +;
                 "' .And. EDD_PEDIDO == '" + cPedido +;
                 "' .And. EDD_SEQUEN == '" + cSequen +;
                 "' .And. EDD_SEQEMB == '" + cSeqEmb + "'"
   Else
      //cFiltro:= "EDD_AC + EDD_PEDIDO + EDD_SEQUEN == '" + cAto + cPedido + cSequen + "'"
      cFiltro:=  "EDD_AC == '" + cAto +;
                 "' .And. EDD_PEDIDO == '" + cPedido +;
                 "' .And. EDD_SEQUEN == '" + cSequen + "'"
   EndIf
   WorkAnt->(DBSetFilter(&("{|| " + cFiltro + " }"), cFiltro))

   WorkAnt->(DBGoTop())

   //Calcula o saldo a exportar maior
   While WorkAnt->(!Eof()) .And. !lAchouWkAnt

      If !lPrimeira
         nPos:= AScan(aSldAnt, {|x| x[1] == WorkAnt->EDD_ITEM})
      EndIf


      If WorkAnt->EDD_QTD > 0
         If nPos > 0
            aSldAnt[nPos,2]  += WorkAnt->EDD_QTD
            If nQtdAnt < aSldAnt[nPos,2]/aSldAnt[nPos,3]
               nQtdAnt := aSldAnt[nPos,2]/aSldAnt[nPos,3]
            EndIf
         Else
            lPrimeira:= .F.
            AADD(aSldAnt,{WorkAnt->EDD_ITEM,WorkAnt->EDD_QTD,WorkAnt->EDD_ITFAT})
            If nQtdAnt < WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT
               nQtdAnt := WorkAnt->EDD_QTD/WorkAnt->EDD_ITFAT
            EndIf
         EndIf
      EndIf



      WorkAnt->(DBSkip())
   EndDo

   WorkAnt->(DBClearFilter())

   If int(nQtdAnt) <= 0
      AEDelWkAnt(cAto,cPedido,cSequen,cSeqEmb)
      lRet := .F.
      Break
   EndIf

   //Verifica se a quantidade exportada é maior que o saldo, caso sim efetua a quebra do item
   //If nQtdComp > int(nQtdAnt) //comentado por wfs - compara quantidades considerando as mesmas condições de casas decimais
   If nQtdComp > RoundAnt(nQtdAnt)
      If lMostraAC .Or. nOpcAprop <> AP_AUT_NAOCOMPROVADOS
         //If !ConfirmaAC(cAto,cPos,lBotao,lApro,nQtdComp,int(nQtdAnt)) //comentado por wfs - quebra considerando as mesmas condições de casas decimais
         If !ConfirmaAC(cAto,cPos,lBotao,lApro,nQtdComp,RoundAnt(nQtdAnt))
            AEDelWkAnt(cAto,cPedido,cSequen,cSeqEmb)
            lRet := .F.
            Break
         EndIf
      Else
         Apropria(lApro)
      EndIf
   Else
      AEDelWkAnt(cAto,cPedido,cSequen,cSeqEmb)
      If !AEGrvWKAnt(cAto,cProd,cSequen,dDtEmba,nQtdComp,cPedido,,cSeqEmb, lMsgExibe)
         lRet := .F.
         Break
      EndIf
      WorkIp->EE9_ATOCON := ED3->ED3_AC
      WorkIp->EE9_SEQED3 := ED3->ED3_SEQSIS
      WorkIP->EE9_QT_AC  := AvTransUnid(WorkIP->EE9_UNIDAD,ED3->ED3_UMPROD,WorkIP->EE9_COD_I,nQtdComp)
      WorkIP->EE9_VL_AC  := WorkIP->EE9_QT_AC*ConvVal(M->EEC_MOEDA,WorkIP->EE9_PRECO,If(!Empty(WorkIP->EE9_DTRE),WorkIP->EE9_DTRE,dDataBase))
      nNivel1:= 0
      nNivel2:= 0
      nNivel3:= 0
   EndIf



End Sequence



Return lRet

/*
Funcao      : AE101WHEN
Parametros  : cCpo
Retorno     : lRet
Objetivos   : Validação de When dos campos da tabela EEM
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 30/01/2014 :: 16:45
*/

*------------------------*
Function AE101WHEN(cCpo)
*------------------------*
Local lRet := .T.

Do Case
   Case cCpo == "EEM_NRNF" .OR. cCpo == "EEM_SERIE" .OR. cCpo == "EEM_DTNF"
         lRet := nTipoW == INC_DET
End Case

Return lRet


/*
Verifica se a unidade de medida da NCM é KG.
Caso positivo, busca o peso do item no processo, e não a conversão entre a quantidade comercializada e a da NCM.
Autor: Rodrigo Mendes
Data: 20/08/14
*/
Function ConvQtdAto(nUMPROD,cUMNCM,cCOD_I,nQT_AC,cAlias)
Local cUnPeso

	If Empty(cUnPeso := &(cAlias+"->EE9_UNPES"))
		If !Empty(cUnPeso := If(Upper(cAlias) == "WORKIP" .OR. Upper(cAlias) == "M", M->EEC_UNIDAD, EEC->EEC_UNIDAD))  // GFP - 22/09/2014
			cUnPeso := "KG"
		EndIf
	EndIf

	If (cUMNCM == KILOGRAMA) .Or. (cUMNCM == KILOGRAMA2)
		nQtdAto := AVTransUnid(cUnPeso, cUMNCM, cCOD_I, nQT_AC * &(cAlias+"->EE9_PSLQUN"))
	Else
		nQtdAto := AVTransUnid(nUMPROD, cUMNCM, cCOD_I, nQT_AC)
	EndIf

Return nQtdAto


/*
Funcao      : RoundAnt
Parametros  : Quantidade
Retorno     : Quantidade arredondada
Objetivos   : Arredondar a quantidade comprovada da anterioridade considerando as configurações de cenário de negócio,
              equiparando a quantidade de casas decimais entre a quantidade a exportar e o saldo a exportar do ato
              concessório
Autor       : WFS
Data/Hora   : Set/2016
*/
Static Function RoundAnt(nQtd)

   If IsIntFat()
      nQtd:= Round(nQtd, AvSx3("C6_QTDVEN", AV_DECIMAL))
   Else
      nQtd:= Round(nQtd, AvSx3("EE9_SLDINI", AV_DECIMAL))
   EndIf

Return nQtd

/*/{Protheus.doc}DesvincAto
Desvincular o item do embarque do ato concessório
@author Wilsimar Fabricio da Silva
@since  01/11/2018
/*/
Static Function DesvincAto()

   EE9->(DBGoTo(WorkIP->WP_RECNO))
   EE9->(RecLock("EE9", .F.))
   EE9->EE9_ATOCON:= ""
   EE9->EE9_SEQED3:= ""
   EE9->EE9_QT_AC := 0
   EE9->EE9_VL_AC := 0
   EE9->(MSUnlock())

Return
*----------------------------------------------------------------------------*
*                    FIM DO PROGRAMA EECAE101.PRW                            *
*----------------------------------------------------------------------------*